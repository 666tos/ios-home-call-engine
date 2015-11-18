//
//  NetworkProtocolJingle.h
//  iO
//
//  Created by Joost de Moel on 8/26/13.
//  Copyright (c) 2013 NGTI. All rights reserved.
//

#import "JingleStanza.h"

#import "JingleTypes.h"

/**
 * Xmpp error codes (XEP-0086)
 * Note: these are not all error codes
 */
typedef enum
{
	JingleErrorUnknown					= -1,
	JingleErrorBadRequest				= 400,
	JingleErrorNotAuthorized			= 401,
	JingleErrorForbidden				= 403,
	JingleErrorItemNotFound             = 404,
	JingleErrorNotAllowed				= 405,
	JingleErrorRegistrationRequired     = 407,
	JingleErrorConflict                 = 409,
	JingleErrorInternalServerError		= 500,
	JingleErrorFeatureNotImplemented	= 501,
	JingleErrorServiceUnavailable		= 503
} JingleErrorCode;

/**
 * Jingle error conditions according to XEP-0166 chapter 8
 */
typedef enum
{
	JingleConditionNone,
	JingleConditionOutOfOrder,
	JingleConditionUnknownSession,
	JingleConditionUnsupportedInfo
} JingleErrorCondition;


@protocol JingleStanzaResponseObserver

/**
 * Called in response of 'sendJingleStanza' when the stanza we sent was acknowledged
 */
- (void)notifyJingleActionAcknowleged:(JingleAction)action withServerTimestamp:serverTimestamp withArgument:(NSObject*)argument;

/**
 * Called in response of 'sendJingleStanza' when the stanza we sent was rejected (with an IQ type 'error')
 */
- (void)notifyJingleActionDenied:(JingleAction)action withJingleError:(JingleErrorCode)jingleError withServerTimestamp:serverTimestamp withArgument:(NSObject*)argument;

@end

@protocol IncomingJingleStanzaObserver

/**
 * Called when an incoming jingle stanza is received
 */
- (void)notifyIncomingJingleStanza:(JingleStanza*)stanza;

/**
 * Called when a forwarded jingle stanza is received
 */
- (void)notifyForwardedJingleStanza:(JingleStanza *)stanza;

@end

@protocol NetworkProtocolJingle

- (void)registerIncomingStanzaObserver:(NSObject<IncomingJingleStanzaObserver>*)observer;

- (NSString*)addressFromPhoneNumber:(NSString*)phoneNumber;

- (BOOL)sendIqResultWithID:(NSString*)iqID toUser:(NSString*)toUser;

- (BOOL)sendIqErrorWithID:(NSString*)iqID toUser:(NSString*)toUser withErrorCode:(JingleErrorCode)errorCode withErrorCondition:(JingleErrorCondition)errorCondition;

- (BOOL)sendJingleStanza:(JingleStanza*)stanza withObserver:(NSObject<JingleStanzaResponseObserver>*)observer withObserverArgument:(NSObject*)observerArgument;

@end