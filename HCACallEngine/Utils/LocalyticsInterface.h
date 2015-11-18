//
//  LocalyticsInterface.h
//  iO
//
//  Created by Joost de Moel on 20-02-14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

typedef enum
{
    OptionalBoolValueNone,
    OptionalBoolValueNo,
    OptionalBoolValueYes
} OptionalBool;

typedef enum
{
    LiveChatSettingChangedSourceSingleUserChat,
    LiveChatSettingChangedSourceGroupChat,
    LiveChatSettingChangedSourceLastSeenSetting,
} LiveChatSettingChangedSource;

@interface LocalyticsInterface : NSObject

+ (instancetype)sharedInstance;

// This provides an in-memory key-value storage to store any intermediate data.
// Key-value pairs are organized by event keys, so the key is unique only inside its associated event.
- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary eventKey:(id<NSCopying>)eventKey;
- (NSDictionary *)allEntriesForEventKey:(id<NSCopying>)eventKey;
- (void)setObject:(id)object forKey:(id<NSCopying>)key eventKey:(id<NSCopying>)eventKey;
- (id)objectForKey:(id)key eventKey:(id)eventKey;
- (void)removeObjectForKey:(id)key eventKey:(id)eventKey;
- (void)removeAllObjectsForEventKey:(id)eventKey;
- (void)removeAllObjects;

//- (void)resume;
//- (void)close;
//- (void)upload;

/**
 * Allows a session to tag a particular event as having occurred.
 */
+ (void)tagEvent:(NSString *)event;

/**
 * Allows a session to tag a particular event as having occurred.
 */
+ (void)tagEvent:(NSString *)event attributes:(NSDictionary *)attributes;

/**
 * Allows a session to tag a particular event as having occurred.
 */
+ (void)tagEvent:(NSString *)event attributes:(NSDictionary *)attributes customerValueIncrease:(NSNumber *)customerValueIncrease;

/**
 * Allows tagging the flow of screens encountered during the session.
 * @param screen The name of the screen
 */
+ (void)tagScreen:(NSString *)screen;

//+ (void)setCustomDimension:(int)dimension value:(NSString *)value;

//Specific events
//+ (void)tagContactStatsEvent;
//+ (void)tagUserSettingsEventWithLastSeenEnabled:(OptionalBool)lastSeenEnabled;
//+ (void)tagRingtoneChangedEventWithOldSounds:(NSDictionary*)oldSounds;
//+ (void)tagBackgroundChangedEventWithPredefinedImageName:(NSString*)predefinedImageName backgroundImage:(UIImage *)chatBackground;

//+ (void)tagLiveChatSettingChangedEventWithSource:(LiveChatSettingChangedSource)source liveChatEnabled:(BOOL)liveChatEnabled inputFieldCharacterCount:(NSUInteger)inputFieldCharacterCount;
//+ (void)tagLiveChatCommittedEventInSingleUserChat:(BOOL)isSingleUserChat groupSize:(NSUInteger)groupSize liveChatsOnScreen:(NSUInteger)liveChatsOnScreen messagesBelowSentItem:(NSUInteger)messagesBelowSentItem mostCharactersTyped:(NSUInteger)mostCharactersTyped liveChatActuallySent:(BOOL)liveChatActuallySent;
+ (void)tagLiveChatClearedEventInSingleUserChat:(BOOL)inSingleUserChat method:(LiveChatClearMethod)method mostCharactersTyped:(NSUInteger)mostCharactersTyped liveChatActuallySent:(BOOL)liveChatActuallySent;
+ (void)beginCapturingLoginAttemptedEventAtrributes;
//+ (void)tagLoginAttemptedEvent;

+ (void)tagThirdPartyLaunchedWithAppName:(NSString *)appName availableOnDevice:(BOOL)available downloadApp:(BOOL)download;
+ (void)tagThirdPartyRequestHandledWithSourceAppName:(NSString *)sourceAppName withAction:(NSString *)action;

// Need this for video pilot event
+ (NSString *)localyticsNetworkType;

@end
