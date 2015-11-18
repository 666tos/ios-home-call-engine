//
//  LocalyticsInterface.m
//  iO
//
//  Created by Joost de Moel on 20-02-14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import "LocalyticsInterface.h"

#import "common.h"
#import "Constants.h"
//#import "NCSController.h"
//#import "LocalyticsSession.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <math.h>
//#import "UIController.h"
#import "LocalyticsEvent.h"
#import "LocalyticsBuckets.h"
#import "ReachabilityMonitor.h"
#import "SoundPlayer.h"
//#import "iOPrivacySettings.h"
//#import "PrivacySettingChangedNotification.h"

typedef void(^LocalyticsInterfacePermissionAttributesCompletion)(NSDictionary *permissionAttributes);

@interface LocalyticsInterface () //<PrivacySettingChangedObserver>

// Object - NSMutableDictionary
@property (nonatomic, readonly) NSMutableDictionary *eventObjectsDictionary;
// A concurrent queue for working with eventObjectsDictionary in a multi read single write mode.
@property (nonatomic, readonly) dispatch_queue_t eventObjectsQueue;

@property (nonatomic) BOOL localyticsSessionOpen;

@property (nonatomic, retain) NSMutableArray * cachedEvents;
@property (nonatomic, retain) NSMutableArray * cachedScreens;

@end

@implementation LocalyticsInterface

+ (instancetype)sharedInstance
{
	static id _sharedInstance = nil;
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        _sharedInstance = [[self alloc] init];
    });
	return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _eventObjectsDictionary = [[NSMutableDictionary dictionary] retain];
        _eventObjectsQueue = dispatch_queue_create("com.swisscom.io.LocalyticsInterface.eventObjectsQueue.concurrent", DISPATCH_QUEUE_CONCURRENT);
        
        self.localyticsSessionOpen = NO;
        
        self.cachedEvents = [NSMutableArray array];
        self.cachedScreens = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    dispatch_release(_eventObjectsQueue);
    [_eventObjectsDictionary release];
    self.cachedEvents = nil;
    self.cachedScreens = nil;
    [super dealloc];
}

- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary eventKey:(id<NSCopying>)eventKey
{
    DASSERT(otherDictionary != nil);
    DASSERT(eventKey != nil);
    dispatch_barrier_async(self.eventObjectsQueue, ^
    {
        NSMutableDictionary *eventDictionary = self.eventObjectsDictionary[eventKey];
        if (eventDictionary == nil)
        {
            eventDictionary = [NSMutableDictionary dictionary];
            self.eventObjectsDictionary[eventKey] = eventDictionary;
        }
        [eventDictionary addEntriesFromDictionary:otherDictionary];
    });
}

- (NSDictionary *)allEntriesForEventKey:(id<NSCopying>)eventKey
{
    DASSERT(eventKey != nil);
    __block NSDictionary * allEntries = nil;
    dispatch_sync(self.eventObjectsQueue, ^
    {
        allEntries = self.eventObjectsDictionary[eventKey];
    });
    
    return allEntries;
}

- (void)setObject:(id)object forKey:(id<NSCopying>)key eventKey:(id<NSCopying>)eventKey
{
    DASSERT(object != nil);
    DASSERT(key != nil);
    DASSERT(eventKey != nil);
    dispatch_barrier_async(self.eventObjectsQueue, ^
    {
        NSMutableDictionary *eventDictionary = self.eventObjectsDictionary[eventKey];
        if (eventDictionary == nil)
        {
            eventDictionary = [NSMutableDictionary dictionary];
            self.eventObjectsDictionary[eventKey] = eventDictionary;
        }
        eventDictionary[key] = object;
    });
}

- (id)objectForKey:(id)key eventKey:(id)eventKey
{
    DASSERT(key != nil);
    DASSERT(eventKey != nil);
    id __block object = nil;
    dispatch_sync(self.eventObjectsQueue, ^
    {
        NSMutableDictionary *eventDictionary = self.eventObjectsDictionary[eventKey];
        object = eventDictionary[key];
    });
    return object;
}

- (void)removeObjectForKey:(id)key eventKey:(id)eventKey
{
    DASSERT(key != nil);
    DASSERT(eventKey != nil);
    dispatch_barrier_async(self.eventObjectsQueue, ^
    {
        NSMutableDictionary *eventDictionary = self.eventObjectsDictionary[eventKey];
        [eventDictionary removeObjectForKey:key];
    });
}

- (void)removeAllObjectsForEventKey:(id)eventKey
{
    DASSERT(eventKey != nil);
    dispatch_barrier_async(self.eventObjectsQueue, ^
    {
        [self.eventObjectsDictionary removeObjectForKey:eventKey];
    });
}

- (void)removeAllObjects
{
    dispatch_barrier_async(self.eventObjectsQueue, ^
    {
        [self.eventObjectsDictionary removeAllObjects];
    });
}

//- (void)resume
//{
//    self.localyticsSessionOpen = YES;
//    [[LocalyticsSession shared] resume];
//    
//    for (LocalyticsEvent * event in self.cachedEvents)
//    {
//        [[LocalyticsSession shared] tagEvent:event.name attributes:event.attributes customerValueIncrease:event.customerValueIncrease];
//    }
//    [self.cachedEvents removeAllObjects];
//    for (NSString * screen in self.cachedScreens)
//    {
//        [[LocalyticsSession shared] tagScreen:screen];
//    }
//    [self.cachedScreens removeAllObjects];
//}

//- (void)close
//{
//    self.localyticsSessionOpen = NO;
//    [[LocalyticsSession shared] close];
//}

//- (void)upload
//{
//    [[LocalyticsSession shared] upload];
//}

/**
 * Allows a session to tag a particular event as having occurred.
 */
+ (void)tagEvent:(NSString *)event
{
    [self.class tagEvent:event attributes:nil customerValueIncrease:nil];
}

/**
 * Allows a session to tag a particular event as having occurred.
 */
+ (void)tagEvent:(NSString *)event attributes:(NSDictionary *)attributes
{
    [self.class tagEvent:event attributes:attributes customerValueIncrease:nil];
}

/**
 * Allows a session to tag a particular event as having occurred.
 */
+ (void)tagEvent:(NSString *)event attributes:(NSDictionary *)attributes customerValueIncrease:(NSNumber *)customerValueIncrease
{
    [self logEvent:event attributes:attributes customerValueIncrease:customerValueIncrease];

    [[self sharedInstance] tagEvent:event attributes:attributes customerValueIncrease:customerValueIncrease];
}

/**
 * Allows tagging the flow of screens encountered during the session.
 * @param screen The name of the screen
 */
+ (void)tagScreen:(NSString *)screen
{
    /*
     {
     Localytics:
     screenflow_tag: "SU Welcome"
     }
     */
    LOG(DEFAULT, "\n{\nLocalytics:\nscreenflow_tag: \"%@\"\n}", screen);
    
    [[self sharedInstance] tagScreen:screen];
}

/**
 Sets the value of a custom dimension. Custom dimensions are dimensions
 which contain user defined data unlike the predefined dimensions such as carrier, model, and country.
 Once a value for a custom dimension is set, the device it was set on will continue to upload that value
 until the value is changed. To clear a value pass nil as the value.
 The proper use of custom dimensions involves defining a dimension with less than ten distinct possible
 values and assigning it to one of the four available custom dimensions. Once assigned this definition should
 never be changed without changing the App Key otherwise old installs of the application will pollute new data.
 */
//+ (void)setCustomDimension:(int)dimension value:(NSString *)value
//{
//    /*
//     {
//     Localytics:
//     custom_dimension: "NA" (!!!!), "mobile"
//     }
//     */
//    LOG(DEFAULT, "\n{\nLocalytics:\ncustom_dimension: \"%d\"\nvalue: \"%@\"\n}", dimension, value);
//    
//    [[LocalyticsSession shared] setCustomDimension:dimension value:value];
//}

/********************************************************************************************/
/* Specific events                                                                          */
/********************************************************************************************/

#pragma mark - Specific events

//+ (void)tagContactStatsEvent
//{
//    NSUInteger ioContacts = 0;
//    
//    NSArray * contacts = [[NCSController getInstance].contactList.contacts retain];
//    for (NSUInteger index = 0; index < contacts.count; index++)
//    {
//        Contact * contact = contacts[index];
//        if (contact.isCommunityContact)
//        {
//            ioContacts++;
//        }
//    }
//    [contacts release];
//    
//    
//    NSUInteger ratio = 0;
//    
//    if (contacts.count > 0)
//    {
//        NSUInteger total_contacts = contacts.count;
//        NSUInteger io_contacts = ioContacts;
//        float ratiof = ((float)io_contacts/total_contacts) * 100;
//        
//        // Calculate percentage in 5% ceiling classes
//        float rest = fmodf(ratiof, 5);
//        if (rest > 0.0f)
//        {
//            //ratio += rest;
//            ratiof = ratiof - rest + 5.0;
//        }
//        
//        ratio = (NSUInteger)ratiof;
//    }
//    
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                [NSString stringWithFormat:@"%ld", (long)contacts.count], kLocalyticsContactStatsKeyTotalContacts,
//                                [NSString stringWithFormat:@"%ld", (long)ioContacts], kLocalyticsContactStatsKeyIoContacts,
//                                [NSString stringWithFormat:@"%ld", (long)ratio], kLocalyticsContactStatsKeyIoRatio,
//                                nil];
//    
//    [self.class tagEvent:kLocalyticsContactStats attributes:attributes];
//}

//+ (void)tagUserSettingsEventWithLastSeenEnabled:(OptionalBool)lastSeenEnabled
//{
//    UserAccount * userAccount = [ApplicationController getInstance].account;
//    
//    NSMutableDictionary * attributes = [self getBackgroundSettingsAttributesWithPredefinedImageName:userAccount.chatBackgroundPredefinedImageName backgroundImage:userAccount.chatBackgroundImage];
//    
//    if (lastSeenEnabled != OptionalBoolValueNone)
//    {
//        [attributes setObject:(lastSeenEnabled == OptionalBoolValueYes ? kLocalyticsAttributeValueTrue : kLocalyticsAttributeValueFalse)
//                       forKey:kLocalyticsAttributeUserSettingsShowLastSeen];
//    }
//    
//    BOOL iOinEnabled        = NO;
//    BOOL iOinVoiceEnabled   = NO;
//    BOOL iOinSmsEnabled     = NO;
//    [ApplicationController getIoInEnabled:&iOinEnabled voiceEnabled:&iOinVoiceEnabled smsEnabled:&iOinSmsEnabled];
//    
//    if (iOinEnabled)
//    {
//        [attributes setObject:(iOinVoiceEnabled ? kLocalyticsAttributeValueOn : kLocalyticsAttributeValueOff)
//                       forKey:kLocalyticsAttributeUserSettingsBreakinCalls];
//        
//        [attributes setObject:(iOinSmsEnabled ? kLocalyticsAttributeValueOn : kLocalyticsAttributeValueOff)
//                       forKey:kLocalyticsAttributeUserSettingsBreakinSms];
//    }
//    
//    for (SoundType soundType = SoundTypeFirst; soundType < SoundTypeCount; soundType++)
//    {
//        SoundID currentSoundID = [[SoundPlayer getInstance] soundIDForPreferredSoundForType:soundType];
//
//        [attributes addEntriesFromDictionary:[self getRingtoneSettingsAttributesWithSoundType:soundType soundID:currentSoundID]];
//    }
//
//    // NIPH-3929 Adding "push" attribute indicating wether the user allows notifications for iO
//    // (i.e. has turned on notifications for iO)
//    BOOL pushesEnabled = (([[iOApplication sharedApplication] io_enabledNotificationTypes] & iONotificationTypeAlert) > 0);
//    [attributes setObject:(pushesEnabled ? kLocalyticsAttributeValueOn : kLocalyticsAttributeValueOff)
//                   forKey:kLocalyticsAttributeUserSettingsPush];
//    
//    [attributes addEntriesFromDictionary:[self attributesForPermissionType:iOPermissionTypeAddressBook]];
//    [attributes addEntriesFromDictionary:[self attributesForPermissionType:iOPermissionTypeNotifications]];
//}

//+ (NSDictionary*)getRingtoneSettingsAttributesWithSoundType:(SoundType)soundType soundID:(SoundID)soundID
//{
//    NSString *type = (soundType == SoundTypeRingtone) ? kLocalyticsAttributeUserSettingsRingtone : kLocalyticsAttributeUserSettingsMessageTone;
//    NSString *soundName = [[[SoundPlayer getInstance] getFileName:soundID] stringByDeletingPathExtension];
//
//    return @{type : (soundName ? soundName : @"")};
//}

//+ (void)tagRingtoneChangedEventWithOldSounds:(NSDictionary*)oldSounds
//{
//    for (SoundType soundType = SoundTypeFirst; soundType < SoundTypeCount; soundType++)
//    {
//        SoundID currentSoundID = [[SoundPlayer getInstance] soundIDForPreferredSoundForType:soundType];
//        SoundID oldSoundID = [[oldSounds objectForKey:@(soundType)] unsignedIntegerValue];
//        
//        if (currentSoundID != oldSoundID)
//        {
//            [LocalyticsInterface tagEvent:kLocalyticsEventUserSettingsChanged
//                               attributes:[self getRingtoneSettingsAttributesWithSoundType:soundType soundID:currentSoundID]];
//        }
//    }
//}

//+ (void)tagBackgroundChangedEventWithPredefinedImageName:(NSString*)predefinedImageName backgroundImage:(UIImage *)chatBackground
//{
//    NSMutableDictionary * attributes = [self getBackgroundSettingsAttributesWithPredefinedImageName:predefinedImageName backgroundImage:chatBackground];
//    
//    [LocalyticsInterface tagEvent:kLocalyticsEventUserSettingsChanged attributes:attributes];
//}

//+ (NSMutableDictionary*)getBackgroundSettingsAttributesWithPredefinedImageName:(NSString*)predefinedImageName backgroundImage:(UIImage *)chatBackground
//{
//    NSString * background;
//    
//    if (predefinedImageName)
//    {
//        background = predefinedImageName.lastPathComponent;
//    }
//    else if (chatBackground)
//    {
//        background = kLocalyticsAttributeUserSettingsBgUserPhoto;
//    }
//    else
//    {
//        background = kLocalyticsAttributeUserSettingsBgNone;
//    }
//    
//    return [NSMutableDictionary dictionaryWithDictionary:@{ kLocalyticsAttributeUserSettingsBackground : background }];
//}

//+ (void)tagLiveChatSettingChangedEventWithSource:(LiveChatSettingChangedSource)settingChangedSource liveChatEnabled:(BOOL)liveChatEnabled inputFieldCharacterCount:(NSUInteger)inputFieldCharacterCount
//{
//    NSString * charactersTypedString;
//    
//    if (inputFieldCharacterCount > 20)
//    {
//        charactersTypedString = @">20";
//    }
//    else if (inputFieldCharacterCount > 15)
//    {
//        charactersTypedString = @"16-20";
//    }
//    else if (inputFieldCharacterCount > 10)
//    {
//        charactersTypedString = @"11-15";
//    }
//    else if (inputFieldCharacterCount > 5)
//    {
//        charactersTypedString = @"6-10";
//    }
//    else if (inputFieldCharacterCount > 0)
//    {
//        charactersTypedString = @"1-5";
//    }
//    else
//    {
//        charactersTypedString = @"0";
//    }
//    
//    NSString * source = @"";
//    
//    switch (settingChangedSource)
//    {
//        case LiveChatSettingChangedSourceSingleUserChat:
//            source = kLocalyticsAttributeValueChat;
//            break;
//            
//        case LiveChatSettingChangedSourceGroupChat:
//            source = kLocalyticsAttributeValueGroup;
//            break;
//            
//        case LiveChatSettingChangedSourceLastSeenSetting:
//            source = kLocalyticsAttributeValueHideLastSeen;
//            break;
//    }
//    
//    BOOL lastSeenEnabled = YES;  // last seen is enabled by default. Note agreed with Matias & Erik to ignore the fact that lastseen could have been disabled on another device without us knowing on this device
//    
//    NSObject<RemoteSettingsInterface> * controller = [NCSController getInstance].remoteSettingsController;
//    (void) [controller getCachedValueOfBooleanSetting:RemoteSettingShowLastSeen cachedValue:&lastSeenEnabled];
//    
//    [LocalyticsInterface tagEvent:kLocalyticsEventLiveChatSettingChanged
//                       attributes:@{kLocalyticsAttributeStatus              : liveChatEnabled ? kLocalyticsAttributeValueOn : kLocalyticsAttributeValueOff,
//                                    kLocalyticsAttributeSource              : source,
//                                    kLocalyticsAttributeCharactersTyped     : charactersTypedString,
//                                    kLocalyticsAttributeShowLastSeenStatus  : lastSeenEnabled ? kLocalyticsAttributeValueOn : kLocalyticsAttributeValueOff}];
//}

//+ (void)tagLiveChatCommittedEventInSingleUserChat:(BOOL)isSingleUserChat groupSize:(NSUInteger)groupSize liveChatsOnScreen:(NSUInteger)liveChatsOnScreen messagesBelowSentItem:(NSUInteger)messagesBelowSentItem mostCharactersTyped:(NSUInteger)mostCharactersTyped liveChatActuallySent:(BOOL)liveChatActuallySent
//{
//    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
//    
//    NSString * charactersTypedString = [self getStringForMostCharactersTyped:mostCharactersTyped];
//    
//    [attributes addEntriesFromDictionary:@{kLocalyticsAttributeSource                      : (isSingleUserChat ? kLocalyticsAttributeValueChat : kLocalyticsAttributeValueGroup),
//                                           kLocalyticsAttributeLargestMessage              : charactersTypedString,
//                                           kLocalyticsAttributeLivechatBubbles             : [NSString stringWithFormat:@"%lu", (unsigned long)liveChatsOnScreen],
//                                           kLocalyticsAttributeAltSorting                  : [NSString stringWithFormat:@"%lu", (unsigned long)messagesBelowSentItem]
//                                           }];
//    
//    if (isSingleUserChat)
//    {
//        [attributes setObject:(liveChatActuallySent ? kLocalyticsAttributeValueYes: kLocalyticsAttributeValueNo) forKey:kLocalyticsAttributeContactReceivedLivechats];
//    }
//    else
//    {
//        [attributes setObject:[NSString stringWithFormat:@"%lu", (unsigned long)groupSize] forKey:kLocalyticsAttributeGroupSize];
//    }
//    
//    [LocalyticsInterface tagEvent:kLocalyticsEventLiveChatComitted attributes:attributes];
//}

+ (void)tagLiveChatClearedEventInSingleUserChat:(BOOL)inSingleUserChat method:(LiveChatClearMethod)method mostCharactersTyped:(NSUInteger)mostCharactersTyped liveChatActuallySent:(BOOL)liveChatActuallySent
{
    NSString * methodValue;
    
    switch (method)
    {
        case LiveChatClearedByBackspace:
            methodValue = kLocalyticsAttributeValueBack;
            break;
            
        case LiveChatClearedByDisablingLiveChat:
            methodValue = kLocalyticsAttributeValueDisable;
            break;
            
        case LiveChatClearedByButton:
            methodValue = kLocalyticsAttributeValueClear;
            break;
    }
    
    NSString * charactersTypedString = [self getStringForMostCharactersTyped:mostCharactersTyped];

    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    
    [attributes addEntriesFromDictionary:@{kLocalyticsAttributeSource                      : (inSingleUserChat ? kLocalyticsAttributeValueChat : kLocalyticsAttributeValueGroup),
                                           kLocalyticsAttributeClearMethod                 : methodValue,
                                           kLocalyticsAttributeLargestMessage              : charactersTypedString}];
    
    if (inSingleUserChat)
    {
        [attributes setObject:(liveChatActuallySent ? kLocalyticsAttributeValueYes: kLocalyticsAttributeValueNo) forKey:kLocalyticsAttributeContactReceivedLivechats];
    }
    
    
    [LocalyticsInterface tagEvent:kLocalyticsEventLiveChatSettingCleared
                       attributes:attributes];
}

+(void)tagThirdPartyLaunchedWithAppName:(NSString *)appName availableOnDevice:(BOOL)available downloadApp:(BOOL)download
{
    NSString *downloadValue = kLocalyticsAttributeValueNotAvailable;
    
    if (! available)
    {
        // If the app is not available, this value indicates if the user wanted to download the app or not.
        downloadValue = download ? kLocalyticsAttributeValueYes : kLocalyticsAttributeValueNo;
    }
    
    [LocalyticsInterface tagEvent:kLocalyticsEventThirdPartyLaunched
                       attributes:@{kLocalyticsAttributeApp         : appName,
                                    kLocalyticsAttributeAvailable   : available ? kLocalyticsAttributeValueYes : kLocalyticsAttributeValueNo,
                                    kLocalyticsAttributeDownload    : downloadValue }];
}

+(void)tagThirdPartyRequestHandledWithSourceAppName:(NSString *)sourceAppName withAction:(NSString *)action
{
    [LocalyticsInterface tagEvent:kLocalyticsEventThirdPartyRequestHandled
                       attributes:@{kLocalyticsAttributeSourceApp   : sourceAppName,
                                    kLocalyticsAttributeAction      : action }];
}

+ (void)beginCapturingLoginAttemptedEventAtrributes
{
    // Just for the sake of cleanness
    [[LocalyticsInterface sharedInstance] removeAllObjectsForEventKey:kLocalyticsLoginAttemptedEvent];
    
    [[LocalyticsInterface sharedInstance] setObject:[NSDate date] forKey:@"totalTimeStart" eventKey:kLocalyticsLoginAttemptedEvent];
    [[LocalyticsInterface sharedInstance] setObject:[NSDate date] forKey:@"initTimeStart" eventKey:kLocalyticsLoginAttemptedEvent];
}

//+ (void)tagLoginAttemptedEvent
//{
//    NSString * const eventKey = kLocalyticsLoginAttemptedEvent;
//    LocalyticsInterface *instance = [[self class] sharedInstance];
//    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
//    
//    // attempt_no
//    NSNumber *attemptNumber = [instance objectForKey:kLocalyticsLoginAttemptedAttributeAttemptNumber eventKey:eventKey];
//    if (attemptNumber)
//    {
//        [attributes setObject:[NSString stringWithFormat:@"%lu", (unsigned long)[attemptNumber unsignedIntegerValue]] forKey:kLocalyticsLoginAttemptedAttributeAttemptNumber];
//    }
//    
//    // attempt_type
//    NSString *attemptTypeValue = [instance objectForKey:kLocalyticsLoginAttemptedAttributeAttemptType eventKey:eventKey];
//    if (attemptTypeValue)
//    {
//        [attributes setObject:attemptTypeValue forKey:kLocalyticsLoginAttemptedAttributeAttemptType];
//    }
//    
//    // status
//    NSString *statusValue = [[instance objectForKey:kLocalyticsLoginAttemptedAttributeStatus eventKey:eventKey] boolValue] ? @"Success" : @"Fail";
//    [attributes setObject:statusValue forKey:kLocalyticsLoginAttemptedAttributeStatus];
//    
//    // total_time
//    NSDate *totalTimeStartDate = [instance objectForKey:@"totalTimeStart" eventKey:eventKey];
//    NSDate *totalTimeEndDate = [instance objectForKey:@"totalTimeEnd" eventKey:eventKey];
//    if (totalTimeStartDate && totalTimeEndDate)
//    {
//        NSTimeInterval totalTime = [totalTimeEndDate timeIntervalSinceDate:totalTimeStartDate];
//        NSString *totalTimeBucketString = [LocalyticsBuckets exponentialBucketForTime:totalTime a:100.0f b:1.0f c:1.1f max:37823];
//        [attributes setObject:totalTimeBucketString forKey:kLocalyticsLoginAttemptedAttributeTotalTime];
//    }
//    
//    // init_time
//    NSDate *initTimeStartDate = [instance objectForKey:@"initTimeStart" eventKey:eventKey];
//    NSDate *initTimeEndDate = [instance objectForKey:@"initTimeEnd" eventKey:eventKey];
//    NSString *initTimeBucketString = @"N/A";
//    if (initTimeStartDate && initTimeEndDate)
//    {
//        NSTimeInterval initTime = [initTimeEndDate timeIntervalSinceDate:initTimeStartDate];
//        initTimeBucketString = [LocalyticsBuckets exponentialBucketForTime:initTime a:50.0f b:1.0f c:0.5f max:9731];
//    }
//    [attributes setObject:initTimeBucketString forKey:kLocalyticsLoginAttemptedAttributeInitTime];
//    
//    // socket_open_time
//    NSDate *socketOpenStartDate = [instance objectForKey:@"socketOpenTimeStart" eventKey:eventKey];
//    NSDate *socketOpenEndDate = [instance objectForKey:@"socketOpenTimeEnd" eventKey:eventKey];
//    NSString *socketOpenTimeBucketString = @"N/A";
//    if (socketOpenStartDate && socketOpenEndDate)
//    {
//        NSTimeInterval socketOpenTime = [socketOpenEndDate timeIntervalSinceDate:socketOpenStartDate];
//        socketOpenTimeBucketString = [LocalyticsBuckets exponentialBucketForTime:socketOpenTime a:50.0f b:1.0f c:0.5f max:9731];
//    }
//    [attributes setObject:socketOpenTimeBucketString forKey:kLocalyticsLoginAttemptedAttributeSocketOpenTime];
//    
//    // stream_ready_time
//    NSDate *streamReadyStartDate = [instance objectForKey:@"streamReadyTimeStart" eventKey:eventKey];
//    NSDate *streamReadyEndDate = [instance objectForKey:@"streamReadyTimeEnd" eventKey:eventKey];
//    NSString *streamReadyTimeBucketString = @"N/A";
//    if (streamReadyStartDate && streamReadyEndDate)
//    {
//        NSTimeInterval streamReadyTime = [streamReadyEndDate timeIntervalSinceDate:streamReadyStartDate];
//        streamReadyTimeBucketString = [LocalyticsBuckets exponentialBucketForTime:streamReadyTime a:50.0f b:1.0f c:0.5f max:9731];
//    }
//    [attributes setObject:streamReadyTimeBucketString forKey:kLocalyticsLoginAttemptedAttributeStreamReadyTime];
//    
//    // stream_neg_time
//    NSDate *streamNegTimeStartDate = [instance objectForKey:@"streamNegTimeStart" eventKey:eventKey];
//    NSDate *streamNegTimeEndDate = [instance objectForKey:@"streamNegTimeEnd" eventKey:eventKey];
//    NSString *streamNegTimeBucketString = @"N/A";
//    if (streamNegTimeStartDate && streamNegTimeEndDate)
//    {
//        NSTimeInterval streamNegTime = [streamNegTimeEndDate timeIntervalSinceDate:streamNegTimeStartDate];
//        streamNegTimeBucketString = [LocalyticsBuckets exponentialBucketForTime:streamNegTime a:50.0f b:1.0f c:0.5f max:9731];
//    }
//    [attributes setObject:streamNegTimeBucketString forKey:kLocalyticsLoginAttemptedAttributeStreamNegTime];
//    
//    // auth_time
//    NSDate *authStartDate = [instance objectForKey:@"authTimeStart" eventKey:eventKey];
//    NSDate *authEndDate = [instance objectForKey:@"authTimeEnd" eventKey:eventKey];
//    NSString *authTimeBucketString = @"N/A";
//    if (authStartDate && authEndDate)
//    {
//        NSTimeInterval authTime = [authEndDate timeIntervalSinceDate:authStartDate];
//        authTimeBucketString = [LocalyticsBuckets exponentialBucketForTime:authTime a:50.0f b:1.0f c:0.5f max:9731];
//    }
//    [attributes setObject:authTimeBucketString forKey:kLocalyticsLoginAttemptedAttributeAuthTime];
//    
//    // initial_presence_time
//    NSDate *initialPresenceStartDate = [instance objectForKey:@"initialPresenceTimeStart" eventKey:eventKey];
//    NSDate *initialPresenceEndDate = [instance objectForKey:@"initialPresenceTimeEnd" eventKey:eventKey];
//    NSString *initialPresenceTimeBucketString = @"N/A";
//    if (initialPresenceStartDate && initialPresenceEndDate)
//    {
//        NSTimeInterval initialPresenceTime = [initialPresenceEndDate timeIntervalSinceDate:initialPresenceStartDate];
//        initialPresenceTimeBucketString = [LocalyticsBuckets exponentialBucketForTime:initialPresenceTime a:50.0f b:1.0f c:0.5f max:9731];
//    }
//    [attributes setObject:initialPresenceTimeBucketString forKey:kLocalyticsLoginAttemptedAttributeInitialPresenceTime];
//    
//    // jwt_retrieved
//    NSNumber *tokenRetrievedNumber = [instance objectForKey:@"tokenRetrieved" eventKey:eventKey];
//    if (tokenRetrievedNumber)
//    {
//        [attributes setObject:[NSString stringWithFormat:@"%i", [tokenRetrievedNumber boolValue]] forKey:kLocalyticsLoginAttemptedAttributeTokenRetrieved];
//    }
//    
//    // token_retrieval_time
//    NSString *tokenRetrievalTimeBucketString = @"N/A";
//    if ([tokenRetrievedNumber boolValue])
//    {
//        NSDate *tokenRetrievalStartDate = [instance objectForKey:@"tokenRetrievalTimeStart" eventKey:eventKey];
//        NSDate *tokenRetrievalEndDate = [instance objectForKey:@"tokenRetrievalTimeEnd" eventKey:eventKey];
//        if (tokenRetrievalStartDate && tokenRetrievalEndDate)
//        {
//            NSTimeInterval tokenRetrievalTime = [tokenRetrievalEndDate timeIntervalSinceDate:tokenRetrievalStartDate];
//            tokenRetrievalTimeBucketString = [LocalyticsBuckets exponentialBucketForTime:tokenRetrievalTime a:50.0f b:1.0f c:0.5f max:9731];
//        }
//    }
//    [attributes setObject:tokenRetrievalTimeBucketString forKey:kLocalyticsLoginAttemptedAttributeTokenRetrievalTime];
//    
//    // network_type
//    [attributes setObject:[LocalyticsInterface localyticsNetworkType] forKey:kLocalyticsLoginAttemptedAttributeNetworkType];
//    
//    // address_book_size
//    NSString *addressBookSize = nil;
//    
//    ABAddressBookRef addressBook = [AddressBookController newAddressBookRef];
//    if (addressBook)
//    {
//        CFIndex personCount = ABAddressBookGetPersonCount(addressBook);
//        addressBookSize = [NSString stringWithFormat:@"%li", personCount];
//        
//        CFRelease(addressBook);
//    }
//    else
//    {
//        addressBookSize = @"N/A";
//    }
//    
//    if (addressBookSize)
//    {
//        [attributes setObject:addressBookSize forKey:kLocalyticsLoginAttemptedAttributeAddressBookSize];
//    }
//    
//    // chat_history_count
//    NSUInteger chatHistoryCount = [[UIController getUIController].backend.conversationManager totalMessageCount];
//    [attributes setObject:[NSString stringWithFormat:@"%lu", (unsigned long)chatHistoryCount] forKey:kLocalyticsLoginAttemptedAttributeChatHistoryCount];
//    
//    [[self class] tagEvent:kLocalyticsLoginAttemptedEvent attributes:attributes];
//    
//    [instance removeAllObjectsForEventKey:eventKey];
//}

/********************************************************************************************/
/* Private                                                                                  */
/********************************************************************************************/

#pragma mark - Private

//- (void)tagScreen:(NSString *)screen
//{
//    if (self.localyticsSessionOpen)
//    {
//        [[LocalyticsSession shared] tagScreen:screen];
//    }
//    else
//    {
//        [self.cachedScreens addObject:screen];
//    }
//}

//- (void)tagEvent:(NSString *)eventName attributes:(NSDictionary *)attributes customerValueIncrease:(NSNumber *)customerValueIncrease
//{
//    if (self.localyticsSessionOpen)
//    {
//        [[LocalyticsSession shared] tagEvent:eventName attributes:attributes customerValueIncrease:customerValueIncrease];
//    }
//    else
//    {
//        LocalyticsEvent * event = [LocalyticsEvent new];
//        event.name                  = eventName;
//        event.attributes            = attributes;
//        event.customerValueIncrease = customerValueIncrease;
//        
//        [self.cachedEvents addObject:event];
//        
//        [event release];
//    }
//}

+ (NSString*)getStringForMostCharactersTyped:(NSUInteger)mostCharactersTyped
{
    if (mostCharactersTyped > 75)
    {
        return @">75";
    }
    else if (mostCharactersTyped > 35)
    {
        return @"36-75";
    }
    else if (mostCharactersTyped > 15)
    {
        return @"16-35";
    }
    else if (mostCharactersTyped > 5)
    {
        return @"6-15";
    }
    else if (mostCharactersTyped > 0)
    {
        return @"1-5";
    }
    
    return @"0";
}

+ (void)logEvent:(NSString *)event attributes:(NSDictionary *)attributes customerValueIncrease:(NSNumber *)customerValueIncrease
{
    /*
     {
     Localytics:
     event_name: "Login"
     clv: "empty"
     attributes: "tries":"3", "total_time":"86", "jwt_retrieved":"1"
     }
     */
    
    NSMutableString * attributesString = [NSMutableString string];
    
    if (attributes != nil && attributes.count > 0)
    {
        BOOL first = YES;
        
        for (NSString * attributeName in attributes.allKeys)
        {
            if (!first)
            {
                [attributesString appendString:@", "];
            }
            [attributesString appendFormat:@"\"%@\":\"%@\"", attributeName, [attributes objectForKey:attributeName]];
            
            first = NO;
        }
    }
    else
    {
        [attributesString appendString:@"empty"];
    }

    NSString * clvValue;
    
    if (customerValueIncrease != nil)
    {
        clvValue = [NSString stringWithFormat:@"%ld", (long)customerValueIncrease.integerValue];
    }
    else
    {
        clvValue = @"empty";
    }
    
    LOG(DEFAULT, "\n{\nLocalytics:\nevent_name: \"%@\"\nclv: \"%@\"\nattributes: %@\n}", event, clvValue, attributesString);
}

+ (NSString *)localyticsNetworkType
{
    NSString *networkType = @"OTHER";
    // network_type
    if ([[ReachabilityMonitor getInstance] internetConnectionStatus] == NetStatusReachableViaWiFi)
    {
        networkType = @"WIFI";
    }
    else
    {
        CTTelephonyNetworkInfo *telephonyNetworkInfo = [CTTelephonyNetworkInfo new];
        NSString* radioAccessTechnology = telephonyNetworkInfo.currentRadioAccessTechnology;
        
        if (radioAccessTechnology)
        {
            if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS])
            {
                networkType = @"G";
            }
            else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge])
            {
                networkType = @"E";
            }
            else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x] ||
                     [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
                     [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||
                     [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA])
            {
                networkType = @"3G";
            }
            else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] ||
                     [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA] ||
                     [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA] ||
                     [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD])
            {
                networkType = @"3.5G";
            }
            else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE])
            {
                networkType = @"4G";
            }
        }
        
        [telephonyNetworkInfo release];
    }
    
    return networkType;
}

#pragma mark -
#pragma mark Permissions

//+ (NSDictionary *)attributesForPermissionType:(iOPermissionType)permissionType
//{
//    iOPermissionStatus status = [[iOPrivacySettings instance] statusForPermission:permissionType];
//    
//    return [self attributesForPermissionType:permissionType status:status];
//}
//
//+ (NSDictionary *)attributesForPermissionType:(iOPermissionType)permissionType status:(iOPermissionStatus)status
//{
//    NSString *statusString = kLocalyticsAttributeValueUnknown;
//    if (status == iOPermissionStatusAccessGranted)
//    {
//        statusString = kLocalyticsAttributeValueOn;
//    }
//    else if (status == iOPermissionStatusNoAccess)
//    {
//        statusString = kLocalyticsAttributeValueOff;
//    }
//    
//    NSString *permissionString = @"";
//    
//    switch (permissionType)
//    {
//        case iOPermissionTypeCamera:
//            permissionString = kLocalyticsAttributeUserSettingsPermissionCamera;
//            break;
//            
//        case iOPermissionTypePhotoLibrary:
//            permissionString = kLocalyticsAttributeUserSettingsPermissionPhotos;
//            break;
//            
//        case iOPermissionTypeAddressBook:
//            permissionString = kLocalyticsAttributeUserSettingsPermissionContacts;
//            break;
//            
//        case iOPermissionTypeMicrophone:
//            permissionString = kLocalyticsAttributeUserSettingsPermissionMicrophone;
//            break;
//            
//        case iOPermissionTypeLocation:
//            permissionString = kLocalyticsAttributeUserSettingsPermissionLocation;
//            break;
//            
//        case iOPermissionTypeNotifications:
//            permissionString = kLocalyticsAttributeUserSettingsPermissionNotifications;
//            break;
//            
//        case iOPermissionTypeCount:
//            break;
//    }
//    
//    return @{permissionString : statusString};
//}
//
//- (void)privacySettingChanged:(PrivacySettingChangedNotification *)notification
//{
//    [LocalyticsInterface tagEvent:kLocalyticsEventUserSettingsChanged
//                       attributes:[LocalyticsInterface attributesForPermissionType:notification.permissionType status:notification.permissionStatus]];
//}

@end
