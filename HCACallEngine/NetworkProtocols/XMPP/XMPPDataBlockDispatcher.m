//
//  XMPPDataBlockDispatcher.m
//  HomeCenter
//
//  Created by Maxim Malyhin on 2/4/15.
//  Copyright (c) 2015 NGTI. All rights reserved.
//

#import "XMPPDataBlockDispatcher.h"
#import "XMPPStrings.h"
#import "XMPPProtocolBase.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#endif

@interface XMPPDataBlockDispatcher () <XMPPStreamDelegate>

@property (strong, nonatomic) NSMutableDictionary *iqListeners;
@property (strong, nonatomic) HCXXMPPController *xmppController;

@property (strong, nonatomic) dispatch_queue_t listenerQueue;

@end

@implementation XMPPDataBlockDispatcher

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithXMPPController:(HCXXMPPController *)xmppController listenerQueue:(dispatch_queue_t)queue
{
    self = [self initWithDispatchQueue:nil];
    if (self)
    {
        self.listenerQueue = queue ? : dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
        self.xmppController = xmppController;
    }
    
    return self;
}

- (void)installProtocol:(XMPPProtocolBase*)protocol
{
    [self activate:self.xmppController.xmppStream];
}

- (BOOL)sendXMPPDataBlock:(XMPPDataBlock *)dataBlock
{
    if ([self.xmppStream isAuthenticated])
    {
        [self.xmppStream sendElement:dataBlock];
        return YES;
    }
    
    return NO;
}

- (BOOL)setIDAndSendIQBlock:(XMPPIQ*)iqBlock
            withRequestType:(NSUInteger)requestType
                 ofProtocol:(XMPPProtocolBase*)protocol
       withProtocolObserver:(NSObject*)observer
       withObserverArgument:(NSObject*)observerArgument
         offlineQueuePolicy:(OfflineQueuePolicy)queuePolicy
{
    DDLogDebug(@"%@ - %@, iq: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [iqBlock prettyXMLString]);
    
    __weak XMPPProtocolBase *weakProtocol = protocol;
    NSString *iqId = [self sendAndTrackIQ:iqBlock withTimeout:60 withCompletion:^(XMPPIQ *iq, NSError *error)
    {
        dispatch_async(self.listenerQueue, ^
        {
            [weakProtocol handleIqResult:iq ofRequestType:requestType withObserver:observer withArgument:observerArgument];
        });
    }];
    
    return (iqId != nil);
}

- (void)addIncomingIqQueryListener:(NSObject<XMPPIqQueryListener>*)listener forStanzasWithNamespace:(NSString*)stanzaNamespace
{
    @synchronized (self)
    {
        self.iqListeners[stanzaNamespace] = listener;
    }
}

- (void)addForwardedIqQueryListener:(NSObject<XMPPForwardedIqQueryListener> *)listener forStanzasWithNamespace:(NSString *)stanzaNamespace
{
    
}

#pragma mark - XMPPStreamDelegate

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    BOOL result = [super xmppStream:sender didReceiveIQ:iq];
    
    if (!result)
    {
        //TODO: Think about better place of this statement
        //Check if iq has already been processed
        NSString *iqId = [[iq attributeForName:@"id"] stringValue];
        
        if (![[HCMStanzaIdsStorage defaultStanzaIdsStorage] existsStanzaId:iqId])
        {
            result = [self notifyListenerIfNeedWithIQ:iq];
        }
    }
    
    return result;
}

- (BOOL)notifyListenerIfNeedWithIQ:(XMPPIQ *)iq
{
    NSString *jingleNamespace = [[[[iq elementForName:@"jingle"] namespaces] firstObject] stringValue];
    
    NSObject<XMPPIqQueryListener>* listenerForNamespace = self.iqListeners[jingleNamespace];
    
    NSObject<XMPPIqQueryListener>* listenerForNamespaceWithoutSubName = nil;
    NSRange range = [jingleNamespace rangeOfString:@"#"];
    NSString* namespaceWithoutSubname = nil;
    
    if (range.location != NSNotFound)
    {
        namespaceWithoutSubname = [jingleNamespace substringToIndex:range.location];
        listenerForNamespaceWithoutSubName = self.iqListeners[namespaceWithoutSubname];
    }
    
    if (listenerForNamespace || listenerForNamespaceWithoutSubName)
    {
        NSLog(@"-- %@ namespace: %@ listener:%@, namespaceWithoutSubname: %@ listener:%@, iq: %@", NSStringFromSelector(_cmd), jingleNamespace, listenerForNamespace, namespaceWithoutSubname, listenerForNamespaceWithoutSubName, [iq prettyXMLString]);
        
        
        NSString *iqId = [[iq attributeForName:@"id"] stringValue];
        if (iqId)
        {
            [[HCMStanzaIdsStorage defaultStanzaIdsStorage] addStanzaId:iqId];
        }
        
        XMPPIQType type = [self typeOfIq:iq];
        
        for (NSXMLElement *child in [iq children])
        {
            dispatch_async(self.listenerQueue, ^
                           {
                               [listenerForNamespace handleReceivedXMPPIqQueryBlock:iq ofType:type withNamespace:jingleNamespace ofChildNode:child];
                               [listenerForNamespaceWithoutSubName handleReceivedXMPPIqQueryBlock:iq ofType:type withNamespace:jingleNamespace ofChildNode:child];
                           });
        }
        
        return YES;
    }
    
    return NO;
}

#pragma mark - Push notifications support

- (void)subscribeForJingleEventsNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jingleEventNotificationDidReceived:) name:kHCXJingleEventDidReceiveNotificatioName object:nil];
}

- (void)unsubscribeFromJingleEventsNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHCXJingleEventDidReceiveNotificatioName object:nil];
}

- (void)jingleEventNotificationDidReceived:(NSNotification *)notification
{
    HCMJingleEventNotification *jingleNotification = notification.userInfo[kHCXJingleEventNotificationObjectKey];
    
    XMPPIQ *iq = [XMPPIQ iqFromElement:jingleNotification.xmlElement];
    
    [self notifyListenerIfNeedWithIQ:iq];
}

#pragma mark - Properties

- (HCXXMPPController *)xmppController
{
    if (!_xmppController)
    {
        _xmppController = [HCXXMPPController defaultXMPPController];
    }
    
    return _xmppController;
}

- (NSMutableDictionary *)iqListeners
{
    if (!_iqListeners)
    {
        _iqListeners = [NSMutableDictionary new];
    }
    return _iqListeners;
}

#pragma mark - Utils

- (XMPPIQType)typeOfIq:(XMPPIQ *)iq
{
    NSString* typeStr   = [iq type];
    
    XMPPIQType type = EXmppIqTypeUnknown;
    
    if ([typeStr isEqualToString:kValueError])
    {
        type = EXmppIqTypeError;
    }
    else if ([typeStr isEqualToString:kValueResult])
    {
        type = EXmppIqTypeResult;
    }
    else if ([typeStr isEqualToString:kValueSet])
    {
        type = EXmppIqTypeSet;
    }
    else if ([typeStr isEqualToString:kValueGet])
    {
        type = EXmppIqTypeGet;
    }
    
    return type;
}

@end