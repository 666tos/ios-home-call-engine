//
//  XMPPProtocolBase.m
//  NGT International B.V.
//
//  Created by Joost de Moel on 10/10/12.
//  Copyright (c) 2012 NGT International B.V. All rights reserved.
//

#import "XMPPProtocolBase.h"

#import "XMPPStrings.h"
#import "XMPPDataBlockDispatcher.h"

@interface XMPPProtocolBase()
{
@private
    NSUInteger          _protocolID;
}

@end

@implementation XMPPProtocolBase

@synthesize ID = _protocolID;

/********************************************************************************************/
/* Initialization                                                                           */
/********************************************************************************************/

#pragma mark - Initialization

- (id)initWithDataBlockDispatcher:(XMPPDataBlockDispatcher*)dataBlockDispatcher
{
    if ((self = [super init]))
    {
        _dataBlockDispatcher = dataBlockDispatcher;
        [_dataBlockDispatcher installProtocol:self];
    }
    return self;
}

/********************************************************************************************/
/* IQ Response handling                                                                     */
/********************************************************************************************/

#pragma mark - IQ Response handling

/**
 * Called when a IQ response with type 'result' is received
 * Decendants MAY override this method
 * @param response the received IQ stanza
 * @param requestType the protocol-specific request type that the protocol object passed when sending the IQ request
 * @param observer the observer of the protocol
 * @param argument the argument which was passed when the IQ request was issued. nil if none was passed
 */
- (void)handleIqResult:(XMPPDataBlock*)response ofRequestType:(NSUInteger)requestType withObserver:(NSObject*)observer withArgument:(NSObject*)argument
{
}


/**
 * Called when a IQ response with type 'error' is received
 * Decendants MAY override this method
 * @param response the received IQ stanza
 * @param errorCode the error code (-1 if no code was specified)
 * @param requestType the protocol-specific request type that the protocol object passed when sending the IQ request
 * @param observer the observer of the protocol
 * @param argument the argument which was passed when the IQ request was issued. nil if none was passed
 */
- (void)handleIqError:(XMPPDataBlock*)response withCode:(NSInteger)errorCode ofRequestType:(NSUInteger)requestType withObserver:(NSObject*)observer withArgument:(NSObject*)argument
{
}

/**
 * Called when an IQ request times out
 * Decendants MAY override this method
 */
- (void)handleIqResponseTimedOutWithRequestType:(NSUInteger)requestType withObserver:(NSObject*)observer withArgument:(NSObject*)argument
{
}


- (XmppErrorType)getXmppErrorTypeFromIqError:(XMPPDataBlock*)iqErrorNode
{
    XMPPDataBlock * errorNode = [iqErrorNode childWithName:kTagNameError];
    if (errorNode != nil)
    {
        NSString * errorType = [errorNode getAttribute:kAttributeType];
        if ([errorType isEqualToString:kValueCancel])
        {
            return XmppErrorTypeCancel;
        }
        if ([errorType isEqualToString:kValueModify])
        {
            return XmppErrorTypeModify;
        }
        if ([errorType isEqualToString:kValueWait])
        {
            return XmppErrorTypeWait;
        }
        if ([errorType isEqualToString:kValueAuth])
        {
            return XmppErrorTypeAuth;
        }
    }
    
    return XmppErrorTypeUnknown;
}


- (XmppError)getXmppErrorFromDataBlock:(XMPPDataBlock*)dataBlock
{
    XmppError errorType = XmppErrorUnknown;
    
    XMPPDataBlock * errorNode = [dataBlock childWithName:kTagNameError];
    if (errorNode != nil)
    {
        if ([errorNode childWithName:kTagNameItemNotFound] != nil)
        {
            errorType = XmppErrorItemNotFound;
        }
        else if ([errorNode childWithName:kTagNameForbidden] != nil)
        {
            errorType = XmppErrorForbidden;
        }
        else if ([errorNode childWithName:kTagNameBadRequest] != nil)
        {
            errorType = XmppErrorBadRequest;
        }
        else if ([errorNode childWithName:kTagNameInternalServerError] != nil)
        {
            errorType = XmppErrorInternalServerError;
        }
        else if ([errorNode childWithName:kTagNameNotAllowed] != nil)
        {
            errorType = XmppErrorNotAllowed;
        }
    }
    
    return errorType;
}
@end
