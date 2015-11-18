//
//  XMPPProtocolBase.h
//  NGT International B.V.
//
//  Created by Joost de Moel on 10/10/12.
//  Copyright (c) 2012 NGT International B.V. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSXMLElement+NGTIAdditions.h"

@class XMPPDataBlockDispatcher;

typedef enum
{
    XmppErrorTypeUnknown,
    XmppErrorTypeCancel,
    XmppErrorTypeWait,
    XmppErrorTypeModify,
    XmppErrorTypeAuth
} XmppErrorType;

typedef enum
{
    XmppErrorUnknown,
    XmppErrorForbidden,
    XmppErrorItemNotFound,
    XmppErrorBadRequest,
    XmppErrorInternalServerError,
    XmppErrorNotAllowed,
} XmppError;


@interface XMPPProtocolBase : NSObject
{
@protected
    XMPPDataBlockDispatcher*     _dataBlockDispatcher;
}

@property (nonatomic) NSUInteger    ID;

- (id)initWithDataBlockDispatcher:(XMPPDataBlockDispatcher*)dataBlockDispatcher;

/**
 * Called when a IQ response with type 'result' is received
 * Decendants MAY override this method
 * @param response the received IQ stanza
 * @param requestType the protocol-specific request type that the protocol object passed when sending the IQ request
 * @param observer the observer of the protocol
 * @param argument the argument which was passed when the IQ request was issued. nil if none was passed
 */
- (void)handleIqResult:(XMPPDataBlock*)response ofRequestType:(NSUInteger)requestType withObserver:(NSObject*)observer withArgument:(NSObject*)argument;

/**
 * Called when a IQ response with type 'error' is received
 * Decendants MAY override this method
 * @param response the received IQ stanza
 * @param errorCode the error code (-1 if no code was specified)
 * @param requestType the protocol-specific request type that the protocol object passed when sending the IQ request
 * @param observer the observer of the protocol
 * @param argument the argument which was passed when the IQ request was issued. nil if none was passed
 */
- (void)handleIqError:(XMPPDataBlock*)response withCode:(NSInteger)errorCode ofRequestType:(NSUInteger)requestType withObserver:(NSObject*)observer withArgument:(NSObject*)argument;


/**
 * Called when an IQ request times out
 * Decendants MAY override this method
 */
- (void)handleIqResponseTimedOutWithRequestType:(NSUInteger)requestType withObserver:(NSObject*)observer withArgument:(NSObject*)argument;


- (XmppErrorType)getXmppErrorTypeFromIqError:(XMPPDataBlock*)errorNode;
- (XmppError)getXmppErrorFromDataBlock:(XMPPDataBlock*)dataBlock;

@end
