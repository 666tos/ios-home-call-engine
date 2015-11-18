/*
 *--------------------------------------------------------------------------------------------------
 * Filename: XMPPProtocol.h
 *--------------------------------------------------------------------------------------------------
 *
 * Revision History:
 *
 *                             Modification     Tracking
 * Author                      Date             Number       Description of Changes
 * --------------------        ------------     ---------    ----------------------------------------
 * Romn Alarcn               2008-06-25                    File Created.
 * Dario Gasquez               2008-07-16                    Added setPresence method.
 *
 *
 * Copyright  2008 NGT International B.V. All rights reserved.
 */

/**
 * General Description:
 *
 *
 * @author Romn Alarcn
 */


//#import "XMPPDataBlock.h"
#import "NSXMLElement+NGTIAdditions.h"

@protocol XMPPProtocol
- (void)resetQueuedData;
- (BOOL)sendReplyToReceivedIQ:(XMPPDataBlock *)iqBlock sendError:(BOOL)sendError;
- (BOOL)sendXMPPDataBlock:(XMPPDataBlock *)dataBlock;
- (BOOL)sendXMPPDataBlock:(XMPPDataBlock *)dataBlock isAuthenticationRelated:(BOOL)isAuthenticationRelated;
- (BOOL)sendXMPPDataBlock:(XMPPDataBlock *)dataBlock attemptToSendRightAway:(BOOL)attemptToSendRightAway;
- (BOOL)sendXMPPForAuthentication:(NSString *)xmppText;
- (BOOL)sendXMPPForAuthentication:(NSString *)xmppText attemptToSendRightAway:(BOOL)attemptToSendRightAway;
@end
