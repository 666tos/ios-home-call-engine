//
//  Constants.h
//  NGT International B.V.
//
//  Created by René Heijndijk on 6/23/08.
//  Copyright 2008 NGT International B.V. All rights reserved.
//

//TODO: Clean up constants!!

// Number to enter in dialpad screen to turn logging on
#define kLoggingSwitchNumber           @"3622532667653669" // = enableconsolenow

// Domains constants
#define kDomainIntegration             @"int.ucid.ch"
#define kDomainReference               @"refucid.ch"
#define kDomainPreProduction           @"testucid.ch"
#define kDomainProduction              @"my-io.ch"

#if defined kFixedDomain
    #define kDomain     kFixedDomain

#elif defined CONFIGURATION_Debug
    #define kDomain     kDomainIntegration
#elif defined CONFIGURATION_Release
    #define kDomain     kDomainIntegration

#elif defined CONFIGURATION_Integration_Release
    #define kDomain     kDomainIntegration
#elif defined CONFIGURATION_Integration_Debug
#define kDomain         kDomainIntegration
#elif defined CONFIGURATION_InAppPurch_Int_Debug
#define kDomain         kDomainIntegration

#elif defined CONFIGURATION_Reference_Release
    #define kDomain     kDomainReference
#elif defined CONFIGURATION_Reference_Debug
    #define kDomain     kDomainReference

#elif defined CONFIGURATION_PreProduction_Release
    #define kDomain     kDomainPreProduction
#elif defined CONFIGURATION_PreProduction_Debug
    #define kDomain     kDomainPreProduction
#elif defined CONFIGURATION_InAppPurch_Pre_Debug
#define kDomain     kDomainPreProduction

#elif defined CONFIGURATION_Production_Release
    #define kDomain     kDomainProduction
#elif defined CONFIGURATION_Production_Debug
#define kDomain         kDomainProduction
#elif defined CONFIGURATION_InAppPurch_Production_Debug
#define kDomain         kDomainProduction

#elif defined CONFIGURATION_Distribution
    #define kDomain     kDomainProduction

#elif defined CONFIGURATION_AppStore
    #define kDomain     kDomainProduction

#else
    #define kDomain     kDomainIntegration
#endif

// Crittercism
#define kCrittercismAppID_Dev       @"51b1d430a7928a1342000002"
#define kCrittercismAppID_Prod      @"51b1d36a46b7c27c57000002"

#define kCrittercismExceedKey                   @"exceed"
#define kCrittercismExceedConnectionType        @"connection_type"
#define kCrittercismErrorKey                    @"error"
#define kCrittercismErrorResponseCodeKey        @"response_code"
#define kCrittercismErrorServiceNameKey         @"service_name"

#define kCrittercismBreadcrumpIAPStatusScreenViewed         @"iaps_status_screen_viewed"
#define kCrittercismBreadcrumpIAPBuyScreenViewed            @"iaps_buy_screen_viewed"
#define kCrittercismBreadcrumpIAPCallAvailableButtonEnabled @"iaps_call_available_button_enabled"
#define kCrittercismBreadcrumpIAPPackagesButtonClicked      @"iaps_packages_button_clicked"
#define kCrittercismBreadcrumpIAPPackagesViewed             @"iaps_packages_viewed"
#define kCrittercismBreadcrumpIAPBuyButtonClicked           @"iaps_buy_button_clicked"
#define kCrittercismBreadcrumpIAPPackageActiveViewed        @"iaps_package_active_viewed"

#define kCrittercismBreadcrumpIAPStoreStartFormat           @"iaps_store_%@_start"
#define kCrittercismBreadcrumpIAPStorePurchasingFormat      @"iaps_store_%@_purchasing"
#define kCrittercismBreadcrumpIAPStorePurchasedFormat       @"iaps_store_%@_purchased"
#define kCrittercismBreadcrumpIAPStoreErrorFormat           @"iaps_store_%@_error"

#define kCrittercismBreadcrumpIAPIQSentFormat               @"iaps_%@_iq_sent"
#define kCrittercismBreadcrumpIAPIQOKFormat                 @"iaps_%@_iq_ok"
#define kCrittercismBreadcrumpIAPIQErrorFormat              @"iaps_%@_iq_error"
#define kCrittercismBreadcrumpIAPIQTimeoutFormat            @"iaps_%@_iq_timeout"

// Landline confirmation find out URL
#define kURL_LandlineConfirmationFindOut    @"https://io.swisscom.ch/news/2014/05/io-landline"

#define kURL_FAQ_format                     @"https://forum.io.swisscom.ch/categories/faq-%@?source=io"

// General purpose constants
#define kSpaceString                   @" "
#define kEmptyString                   @""
#define kSharpSymbol                   @"#"
#define kZeroDigitString               @"0"
#define kDotSymbol                     @"."
#define kAtSymbol                      @"@"
#define kSlashSymbol                   @"/"
#define kMinusSymbol                   @"-"
#define kCommaSymbol                   @","
#define kEqualSymbol                   @"="
#define kColonSymbol                   @":"
#define kPercentageSymbol              @"%"

#define kOfflineSeparator              @"$$__offline__$$"
#define kSearchSeparator               @"$$__search__$$"

#define kLoopbackAddress               @"127.0.0.1"

#ifndef DEBUG
#define kContactsAlphabeticLimit          50
#else
#define kContactsAlphabeticLimit          0
#endif

#define kValueDefaultKeepAliveTime     30   // Time interval, in seconds, used to send a keep alive space to the XMPP server

#define kMinPhoneNumberLength            1
#define kMaxPhoneNumberLength           21

#define kAttributeIP                   @"ip"

#define kLessThanSymbol                @"<"
#define kGreaterThanSymbol             @">"
#define kAmpersandSymbol               @"&"
#define kApostropheSymbol              @"'"
#define kQuoteSymbol                   @"\""
#define kNewLineSymbol                 @"\n"
#define kBackslashSymbol               @"\\"
#define kBackspaceSymbol               @"\b"
#define kFormfeedSymbol                @"\f"
#define kCarriageRetSymbol             @"\r"
#define kTabSymbol                     @"\t"

#define kLessThanXMLSymbol             @"&lt;"
#define kGreaterThanXMLSymbol          @"&gt;"
#define kAmpersandXMLSymbol            @"&amp;"
#define kApostropheXMLSymbol           @"&apos;"
#define kQuoteXMLSymbol                @"&quot;"

#define kApostropheJavascriptSymbol    @"\\'"
#define kQuoteJavascriptSymbol         @"\\\""
#define kNewLineJavascriptSymbol       @"\\n"
#define kBackslashJavascriptSymbol     @"\\\\"
#define kBackspaceJavascriptSymbol     @"\\b"
#define kFormfeedJavascriptSymbol      @"\\f"
#define kCarriageRetJavascriptSymbol   @"\\r"
#define kTabJavascriptSymbol           @"\\t"

#define kInternationalPrefix           @"+"


#define kNavigationBarHeight           44.0f
#define kNavigationBarHeight_Landscape 32.0f
#define kTabBarHeight                  49.0f
#define kStatusBarHeight               20.0
#define kKeyboardHeight                216.0f
#define kKeyboardHeight_Landscape      162.0f
#define kTableTopVerticalMargin        10.0f
//#define kHorizontalMargin			   8.0f
//#define kVerticalMargin				   6.0f


// Jingle Errors
#define kJingleErrorCodeUnknown          -1
#define kJingleErrorCodePaymentRequired 402
#define kJingleErrorCodeNotFound        404

// Chat History
// 1 hours = 60 min = 3600 sec
#define kChatHistoryTimeLimit           3600
#define kChatHistoryCheckFreq           60
// 2 weeks = 1209600 sec
// 10 years!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#define kChatHistoryOldItem             1209600 * 2 * 12 * 10
#define kChatHistoryItemsVisible        50
#define kChatHistoryItemsByPage         25
#define kChatHistoryTimestampFormat     @"yyyyMMddHHmmssSSS"

#define kChatGeneratedThumbnailJpegQuality      0.8f
#define kChatImageUploadJpegQuality             0.8f
#define kChatThumbnailUploadMaxSizeInPixels     256     // maximum for both width and height
#define kChatImageUploadMaxSizeInPixels         1024    // maximum for both width and height

// Rate iO
#define kRateiOAmountLogins        20
// 2 weeks = 1209600 sec
#define kRateiOElapsedTime         1209600

#define kiOAppID                   649895248


#define kTabIndex                       @"TabIndex"
#define kViewControllers                @"ViewControllers"
#define kVersionHasChanged              @"VersionHasChanged"


#define kVideoMaxDuration                       90.0
#define kVideoMaxFileSize                       14 * 1024 * 1024
#define kVideoPickerQualityPreset               UIImagePickerControllerQualityTypeMedium
#define kVideoExportQualityPreset               AVAssetExportPresetMediumQuality
#define kMaxAutodownloadFileSize                400 * 1024 //400 kB

#define kSwisscomHelpURL                @"http://io.swisscom.ch/help"

#define kLiveChatBubbleNormalCornerWidth           6.f
#define kLiveChatBubbleNormalCornerHeight          6.f
#define kLiveChatBubbleArrowCornerWidth            18.f
#define kLiveChatBubbleArrowCornerHeight           18.f
#define kLiveChatBubbleTileWidth                   8.f
#define kLiveChatBubbleTileHeight                  8.f

//tab bar ID's for order tab bar items according to User setting
//the order of the defines is the default order of the tabs
#define kTabBarContacts                         0
#define kTabBarHistory                          1
#define kTabBarDialPad                          2
#define kTabBariO                               3
//kTabBarEnd is the amount of tabs in the tabbarcontroller
#define kTabBarEnd                              4

typedef enum
{
    NCSUnknown                =   -1,
    NCSHTTPProtocolAP         = 1021,
    NCSHTTPProtocolGeneric    = 1055,
} NCSConstants;

typedef enum
{
    NetStatusNotReachable = 0,
    NetStatusReachableViaCarrier,
    NetStatusReachableViaWiFi
} NetStatus;


typedef enum
{
    FSPOther,
    FSPAudio,
    FSPVideo,
    FSPImage,
    FSPVoiceMessage,
    FSPVCard,
    FSPAvatar
} FSPFileType;

typedef enum
{
    FSPExtendedDOC,
    FSPExtendedDOCX,
    FSPExtendedPDF,
    FSPExtendedPPT,
    FSPExtendedPPTX,
    FSPExtendedRTF,
    FSPExtendedTXT,
    FSPExtendedVCF,
    FSPExtendedXLS,
    FSPExtendedXLSX,
    FSPExtendedDefault
} FSPFileTypeExtended;


// Type of normalized phone number, added in DB version 1.37
typedef enum
{
    NormalizedPhoneNumberTypeUnknown = 0,
    NormalizedPhoneNumberTypeMobile,
    NormalizedPhoneNumberTypeLandline
} NormalizedPhoneNumberType;


typedef NS_ENUM(NSUInteger, RemoteSetting)
{
    RemoteSettingShowLastSeen = 0
};

typedef enum
{
    LiveChatClearedByButton = 0,
    LiveChatClearedByDisablingLiveChat,
    LiveChatClearedByBackspace
} LiveChatClearMethod;

#define kDefaultHighlightColor [UIColor colorWithRed:0.1372f green:0.9607f blue:1.f alpha:1.f]
// Default background color
#define kColorBackground [UIColor colorWithRed:(float)0xe0/0xff green:(float)0xe0/0xff blue:(float)0xe0/0xff alpha:1.0f]
#define kLoginCellBorderColor [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f]
#define kGradientStartColor [UIColor colorWithRed:(float)0x36/0xff green:(float)0x85/0xff blue:(float)0xC1/0xff alpha:1.0f]
#define kGradientEndColor [UIColor colorWithRed:(float)0x18/0xff green:(float)0x43/0xff blue:(float)0x7E/0xff alpha:1.0f]

// Application colors
#define kColorNavigationBar \
        [UIColor colorWithRed:(float)0x00/0xff green:(float)0x53/0xff blue:(float)0x9e/0xff alpha:1.0]
#define kColorTabBar \
        [UIColor colorWithRed:(float)0x00/0xff green:(float)0x53/0xff blue:(float)0x9e/0xff alpha:1.0]
#define kColorTabItem \
        [UIColor colorWithRed:(float)0x15/0xff green:(float)0x55/0xff blue:(float)0x91/0xff alpha:1.0]
#define kColorSearchBar \
        [UIColor colorWithRed:(float)0x00/0xff green:(float)0xac/0xff blue:(float)0xff/0xff alpha:1.0]
#define kColorMeBar \
        [UIColor colorWithRed:(float)0x00/0xff green:(float)0xac/0xff blue:(float)0xff/0xff alpha:1.0]
// iO specific colors
#define kColorGrayText \
        [UIColor colorWithRed:(float)0x68/0xff green:(float)0x68/0xff blue:(float)0x68/0xff alpha:1.0]
#define kColorLightGrayText \
        [UIColor colorWithRed:(float)0xa0/0xff green:(float)0xa0/0xff blue:(float)0xa0/0xff alpha:1.0]
#define kColorLightBlueText \
        [UIColor colorWithRed:(float)0x00/0xff green:(float)0xac/0xff blue:(float)0xff/0xff alpha:1.0]
#define kColorBlueText \
        [UIColor colorWithRed:(float)0x00/0xff green:(float)0x09/0xff blue:(float)0x56/0xff alpha:1.0]
#define kColorSelectionBackground \
        [UIColor colorWithRed:(float)0x01/0xff green:(float)0xee/0xff blue:(float)0xf8/0xff alpha:1.0]
#define kColorNewContactNavItemTitle \
        [UIColor blackColor]
#define kColorNewContactNavItemText \
        [UIColor colorWithRed:0.0f green:(float)122/255 blue:(float)255/255 alpha:1.0]

#define kCellSeparatorColor [UIColor colorWithWhite:0.902f alpha:1.f]
#define kGreyBorderColor    [UIColor colorWithWhite:0.847f alpha:1.f]

#define kColorCharcoalGray [UIColor colorWithWhite:68.f/255.f alpha:1.f]
#define kColorGraySubtitle [UIColor colorWithWhite:136.f/255.f alpha:1.f]

#define kColorRedAlertText [UIColor colorWithRed:0.867f green:0.067f blue:0.086f alpha:1.f]

#define kDefaultPurpleTintColor [UIColor colorWithRed:148.f/255.f green:24.f/255.f blue:128.f/255.f alpha:1.f]
#define kBackgroundPurpleColor [UIColor colorWithRed:169.f/255.f green:35.f/255.f blue:143.f/255.f alpha:1.f]
#define kSearchBarBackgroundColor [UIColor colorWithWhite:201.f/255.f alpha:1.f]

#define kBreakOutGreenTintColor [UIColor colorWithRed:56.f/255.f green:193.f/255.f blue:56.f/255.f alpha:1.f]
#define kBackgroundBlueColor    [UIColor colorWithRed:0.149f green:0.616f blue:0.827f alpha:0.9f]
#define kBackgroundGreenColor   [UIColor colorWithRed:56.f/255.f green:193.f/255.f blue:56.f/255.f alpha:0.9f]

#define kOngoingCallBarBackgroundColor [UIColor colorWithRed:76.f/255.f green:217.f/255.f blue:100.f/255.f alpha:1.f]

#define kDefaultHeightForBlurRadius 196.f
#define kDefaultBackgroundBlurRadius 6.f


#define kCountryCodeDefaultValue @"CH"

//Remote Notification
#define kRemoteNotificationTypeKey              @"xml-type"
#define kRemoteNotificationArgsKey              @"loc-args"
#define kRemoteNotificationFromJID              @"from"
#define kRemoteNotificationAltFrom              @"altFrom"
#define kRemoteNotificationStanza               @"stanza"
#define kRemoteNotificationGroupName            @"gname"
#define kRemoteNotificationSID                  @"sid"
#define kRemoteNotificationID                   @"id"
#define kRemoteNotificationVideoEnabledKey      @"video"
#define kRemoteNotificationTypeChat             @"msg"
#define kRemoteNotificationTypeJoinAlert        @"jnotif"
#define kRemoteNotificationTypeMultimediaMsg    @"mmn"
#define kRemoteNotificationTypeMissedCall       @"mcall"
#define kRemoteNotificationTypeCall             @"call"
#define kRemoteNotificationTypeLocation         @"location"

#define kEnableLiveChatInGroupChats             NO

#define kOpenInSafariToken                          @"?open-safari"
#define kSessionExpiredURL                          @"/session-expired"

// Localytics
#define kLocalyticsAppKey_Dev           @"78750fe7495c32ec50449cc-1da9260a-a36c-11e2-f18c-0086c15f90fa"
#define kLocalyticsAppKey_Prod          @"c301c83be2e110862603219-bddc68b6-a36c-11e2-9aa1-00c76edb34ae"


/***** DON'T CHANGE THE FOLLOWING KEYWORDS, AS ALL LOCALYTICS DATA DEPENDS ON IT *****/
#define kLocalyticsLogin                                @"Login"                // User logged in
#define kLocalyticsReceivedPushRemote                   @"Remote push received" // Remote push notification received
#define kLocalyticsAddPhone                             @"Add phone"            // Add phone number button (call screen) pressed
#define kLocalyticsSearchContact                        @"Search contact"       // Contact search text filed entered
#define kLocalyticsOutgoingCallEvent                    @"Outgoing call"
#define kLocalyticsIncomingCallEvent                    @"Incoming_call"
#define kLocalyticsInviteRequestEvent                   @"invite_request"       // User sent an invite
#define kLocalyticsDeleteAccountEvent                   @"account_deactivated"
#define kLocalyticsDeleteAccountEventKeyClientType      @"client_type"
#define kLocalyticsJoinNotificationEvent                @"join_notification"
#define kLocalyticsContactStats                         @"contact_stats"
#define kLocalyticsContactStatsKeyTotalContacts         @"total_contacts"
#define kLocalyticsContactStatsKeyIoContacts            @"io_contacts"
#define kLocalyticsContactStatsKeyIoRatio               @"io_ratio"
#define kLocalyticsCallStatsKeyRingTime                 @"ring_time"
#define kLocalyticsCallStatsKeyLocAction                @"loc_action"
#define kLocalyticsCallStatsKeyTypeRoute                @"type_route"

#define kLocalyticsEventUserSettings                    @"user_settings"
#define kLocalyticsEventUserSettingsChanged             @"user_settings_changed"
#define kLocalyticsAttributeUserSettingsBackground      @"background"
#define kLocalyticsAttributeUserSettingsBgNone          @"none"
#define kLocalyticsAttributeUserSettingsBgUserPhoto     @"user_photo"
#define kLocalyticsAttributeUserSettingsShowLastSeen    @"showlastseen"
#define kLocalyticsAttributeValueTrue                   @"true"
#define kLocalyticsAttributeValueFalse                  @"false"

#define kLocalyticsCallStatsTypeRouteVoipCS             @"voip_cs"
#define kLocalyticsCallStatsTypeRouteVoip               @"voip_voip"

#define kLocalyticsSignUpCompleteEvent                  @"signup_complete"      // User successfully signed up
#define kLocalyticsSignUpCompleteEventCodeRequestCount  @"code_request_count"   // How many code sms were requested
#define kLocalyticsSignUpCompleteEventElapsedTime       @"elapsed_time"         // Time between start and finish of signup

#define kLocalyticsChatSent                             @"chat_sent_event"      // User sent message of any type
#define kLocalyticsChatSentDomainKey                    @"domain"
#define kLocalyticsChatSentTypeKey                      @"type"
#define kLocalyticsChatSentTypeText                     @"text"
#define kLocalyticsChatSentTypeLocation                 @"location"
#define kLocalyticsChatSentSourceKey                    @"source"
#define kLocalyticsChatSentSourceTypeInput              @"input"                // Content originated as an input from the user on the device
#define kLocalyticsChatSentSourceTypeForward            @"forward"              // Content originated as a received message that is now being forwarded
#define kLocalyticsChatSentSourceTypeCamera             @"camera"               // Content of the message originated from the camera
#define kLocalyticsChatSentSourceTypeExisting           @"existing"             // Content of the message was selected from the gallery or was already present in the device
#define kLocalyticsChatSentTriggerKey                   @"trigger"
#define kLocalyticsChatSentTriggerTypeIo                @"io"                   // The action to send the message initiated from within the application
#define kLocalyticsChatSentMediaConditionKey            @"media_condition"
#define kLocalyticsChatSentMediaConditionTypeOriginal   @"original"             // No modifications have been made to the media file sent
#define kLocalyticsChatSentMediaConditionTypeModified   @"modified"             // The media content of the message has been resized or re-encoded
#define kLocalyticsChatSentAttributeLiveChat            @"live_chat"

#define kLocalyticsCallContextDialPad                   @"dialpad"
#define kLocalyticsCallContextContactCardButton         @"contact_call_btn"
#define kLocalyticsCallContextContactCardTableCell      @"contact_phone_number"
#define kLocalyticsCallContextConversation              @"conversation_call_btn"
#define kLocalyticsVoIPBlockEvent                       @"voip_block_alert"

#define kLocalyticsEventVideoCallQualityRating          @"user_quality_rating"

#define kLocalyticsEventLiveChatSettingChanged          @"Live Chat Setting Changed"
#define kLocalyticsEventLiveChatComitted                @"Live Chat Committed"
#define kLocalyticsEventLiveChatSettingCleared          @"Live Chat Cleared"

#define kLocalyticsEventThirdPartyLaunched              @"Third Party Launched"
#define kLocalyticsEventThirdPartyRequestHandled        @"Third Party Request Handled"

#define kLocalyticsAttributeStatus                      @"status"
#define kLocalyticsAttributeSource                      @"source"
#define kLocalyticsAttributeClearMethod                 @"clear_method"
#define kLocalyticsAttributeCharactersTyped             @"characters_typed_before_event"
#define kLocalyticsAttributeLargestMessage              @"largest_message_before_event"
#define kLocalyticsAttributeShowLastSeenStatus          @"show_last_seen_status"
#define kLocalyticsAttributeContactReceivedLivechats    @"contact_received_livechats"
#define kLocalyticsAttributeApp                         @"app"
#define kLocalyticsAttributeAvailable                   @"available"
#define kLocalyticsAttributeDownload                    @"download"
#define kLocalyticsAttributeSourceApp                   @"source_app"
#define kLocalyticsAttributeAction                      @"action"

#define kLocalyticsAttributeValueOn                     @"on"
#define kLocalyticsAttributeValueOff                    @"off"
#define kLocalyticsAttributeValueYes                    @"yes"
#define kLocalyticsAttributeValueNo                     @"no"
#define kLocalyticsAttributeValueNotAvailable           @"na"
#define kLocalyticsAttributeValueChat                   @"chat"
#define kLocalyticsAttributeValueGroup                  @"group"
#define kLocalyticsAttributeValueHideLastSeen           @"hide last seen"
#define kLocalyticsAttributeValueClear                  @"clear"
#define kLocalyticsAttributeValueBack                   @"back"
#define kLocalyticsAttributeValueDisable                @"disable"
#define kLocalyticsAttributeValueLocalCH                @"localch"
#define kLocalyticsAttributeValueUnknown                @"unknown"
#define kLocalyticsAttributeValuePassword               @"password"
#define kLocalyticsAttributeValueCall                   @"call"
#define kLocalyticsAttributeValueNone                   @"none"

// In App Purchase
#define kLocalyticsIAPEventCallAvailableButton          @"iap_call_available_button"
#define kLocalyticsIAPEventPackagesDialogue             @"iap_packages_dialogue"
#define kLocalyticsIAPEventBuyScreen                    @"iap_buy_screen"
#define kLocalyticsIAPEventBuyClick                     @"iap_buy_click"
#define kLocalyticsIAPEventTransactionOK                @"iap_transaction_ok"
#define kLocalyticsIAPEventTransactionAborted           @"iap_transaction_aborted"

#define kLocalyticsIAPStartLocation                     @"start_location"
#define kLocalyticsIAPStartLocationKeypad               @"keypad"
#define kLocalyticsIAPStartLocationConversation         @"conversation"
#define kLocalyticsIAPStartLocationContactCard          @"contact_card"

#define kLocalyticsIAPFailureReasonUnknown              @"unknown"
#define kLocalyticsIAPFailureReasonUserCancelled        @"user_cancelled"
#define kLocalyticsIAPFailureReasonStoreIssue           @"store_issue"
#define kLocalyticsIAPFailureReasonPaymentFailed        @"payment_failed"

#define kLocalyticsIAPProductID                         @"product_id"
#define kLocalyticsIAPReason                            @"reason"
#define kLocalyticsIAPLastPurchasedProduct              @"last_purchased_product"

// Video Calling Pilot
#define kLocalyticsEventVCP                             @"Video Calling"
#define kLocalyticsAttrVCP_Initiation                   @"initiation"
#define kLocalyticsAttrVCP_ConversationTime             @"conversation_time"
#define kLocalyticsAttrVCP_NetworkType                  @"network_type"
#define kLocalyticsAttrVCP_AvgCpuLoad                   @"avg_cpu_load"
#define kLocalyticsAttrVCP_IncomingRes                  @"incoming_res"
#define kLocalyticsAttrVCP_OutgoingRes                  @"outgoing_res"
#define kLocalyticsAttrVCP_DownloadBandwidthAvg         @"download_bandwidth_avg"
#define kLocalyticsAttrVCP_DownloadBandwidthMin         @"download_bandwidth_min"
#define kLocalyticsAttrVCP_DownloadBandwidthMax         @"download_bandwidth_max"
#define kLocalyticsAttrVCP_UploadBandwidthAvg           @"upload_bandwidth_avg"
#define kLocalyticsAttrVCP_UploadBandwidthMin           @"upload_bandwidth_min"
#define kLocalyticsAttrVCP_UploadBandwidthMax           @"upload_bandwidth_max"
#define kLocalyticsAttrVCP_IncomingPacklossAvg          @"packloss_avg"
#define kLocalyticsAttrVCP_RttAvg                       @"rtt_avg"
#define kLocalyticsAttrVCP_RttMin                       @"rtt_min"
#define kLocalyticsAttrVCP_RttMax                       @"rtt_max"
#define kLocalyticsAttrVCP_QualityRating                @"quality_rating"

#define kLocalyticsAttrOutgoingIncomingCall_NetworkType @"network_type"
#define kLocalyticsAttrOutgoingIncomingCall_TypeCall    @"type_call"

// Localytics screen flow tags (iPhone)
#define kiPhoneLocalyticsScreenHistory                          @"History"
#define kiPhoneLocalyticsScreenContactCard                      @"Contact card"
#define kiPhoneLocalyticsScreenContactList                      @"Contact list"
#define kiPhoneLocalyticsScreenConversation                     @"Conversation"
#define kiPhoneLocalyticsScreenKeypad                           @"Keypad"
#define kiPhoneLocalyticsScreenCall                             @"Call screen"
#define kiPhoneLocalyticsScreenIO                               @"iO"
#define kiPhoneLocalyticsScreenVideoCall                        @"Video call"
#define kiPhoneLocalyticsScreenAddContact                       @"Add contact"
#define kiPhoneLocalyticsScreenNewConversation                  @"New Conversation"
#define kiPhoneLocalyticsScreenGCConversation                   @"GC Conversation"
#define kiPhoneLocalyticsScreenGCSettings                       @"GC Settings"
#define kiPhoneLocalyticsScreenGCParticipantsList               @"GC Participant List"
#define kiPhoneLocalyticsScreenGCAddParticipants                @"GC Add Participants"
#define kiPhoneLocalyticsScreenSignUpWelcome                    @"SU Welcome"
#define kiPhoneLocalyticsScreenSignUpPhoneNumber                @"SU PN"
#define kiPhoneLocalyticsScreenSignUpCode                       @"SU Code"
#define kiPhoneLocalyticsScreenSignUpProfile                    @"SU Profile"
#define kiPhoneLocalyticsScreenSignUpError                      @"SU Error"
#define kiPhoneLocalyticsScreenSignUpNoNetwork                  @"SU No network"
#define kiPhoneLocalyticsScreenSignUpLandLinePN                 @"SUL PN"
#define kiPhoneLocalyticsScreenSignUpLandLineNumberNotEligible  @"SUL Number not eligible"
#define kiPhoneLocalyticsScreenSignUpLandLineSSI                @"SUL SSI"
#define kiPhoneLocalyticsScreenSignUpLandLineGetLandlines       @"SUL Get Landlines"
#define kiPhoneLocalyticsScreenSignUpLandLineChooseLandline     @"SUL Choose Landline"
#define kiPhoneLocalyticsScreenSignUpLandLineProfile            @"SUL Profile"
#define kiPhoneLocalyticsScreenSignUpLandLineConfirmation       @"SUL Confirmation"
#define kiPhoneLocalyticsScreenSignUpLandLineConnecting         @"SUL Connecting"
#define kiPhoneLocalyticsScreenSignUpLandLineError              @"SUL Error"
#define kiPhoneLocalyticsScreenSignUpLandLineNoNetwork          @"SUL No Network"

// Localytics screen flow tags (iPad)
#define kiPadLocalyticsScreenHistoryConversation                @"T History Conversation"
#define kiPadLocalyticsScreenContactsKeypad                     @"T Contacts Keypad"
#define kiPadLocalyticsScreenContactCard                        @"T Contact Card"
#define kiPadLocalyticsScreenCallScreen                         @"T Call Screen"
#define kiPadLocalyticsScreenIO                                 @"T iO"
#define kiPadLocalyticsScreenNewConversation                    @"T New Conversation"
#define kiPadLocalyticsScreenSignUpLandLineWalkthrough          @"T SUL Walkthrough"
#define kiPadLocalyticsScreenSignUpLandLineSSI                  @"T SUL SSI"
#define kiPadLocalyticsScreenSignUpLandLineGetLandlines         @"T SUL Get Landlines"
#define kiPadLocalyticsScreenSignUpLandLineChooseLandline       @"T SUL Choose Landline"
#define kiPadLocalyticsScreenSignUpLandLineProfile              @"T SUL Profile"
#define kiPadLocalyticsScreenSignUpLandLineConfirmation         @"T SUL Confirmation"
#define kiPadLocalyticsScreenSignUpLandLineConnecting           @"T SUL Connecting"
#define kiPadLocalyticsScreenSignUpLandLineError                @"T SUL Error"
#define kiPadLocalyticsScreenSignUpLandLineNoNetwork            @"T SUL No Network"
#define kiPadLocalyticsScreenSignUpWelcome                      @"T SU Welcome"
#define kiPadLocalyticsScreenSignUpPhoneNumber                  @"T SU PN"
#define kiPadLocalyticsScreenSignUpCode                         @"T SU Code"
#define kiPadLocalyticsScreenSignUpProfile                      @"T SU Profile"
#define kiPadLocalyticsScreenSignUpError                        @"T SU Error"
#define kiPadLocalyticsScreenSignUpNoNetwork                    @"T SU No network"

#define kLocalyticsCustomDimensionServiceLevel  0
#define kLocalyticsCustomDimensionTelephonyType 1
#define kLocalyticsCustomDimensionDeviceType    2
#define kLocalyticsTelephonyTypeLandline        @"landline"
#define kLocalyticsTelephonyTypeMobile          @"mobile"
#define kLocalyticsDeviceTypeTablet             @"tablet"
#define kLocalyticsDeviceTypePhone              @"phone"

// Login Attempted event
#define kLocalyticsLoginAttemptedEvent                          @"Login Attempted"      // An attempt to login has been made regardless of its outcome
#define kLocalyticsLoginAttemptedAttributeAttemptNumber         @"attempt_no"
#define kLocalyticsLoginAttemptedAttributeAttemptType           @"attempt_type"
#define kLocalyticsLoginAttemptedAttributeStatus                @"status"
#define kLocalyticsLoginAttemptedAttributeTotalTime             @"total_time"
#define kLocalyticsLoginAttemptedAttributeInitTime              @"init_time"
#define kLocalyticsLoginAttemptedAttributeSocketOpenTime        @"socket_open_time"
#define kLocalyticsLoginAttemptedAttributeStreamReadyTime       @"stream_ready_time"
#define kLocalyticsLoginAttemptedAttributeStreamNegTime         @"stream_neg_time"
#define kLocalyticsLoginAttemptedAttributeAuthTime              @"auth_time"
#define kLocalyticsLoginAttemptedAttributeInitialPresenceTime   @"initial_presence_time"
#define kLocalyticsLoginAttemptedAttributeTokenRetrieved        @"token_retrieved"
#define kLocalyticsLoginAttemptedAttributeTokenRetrievalTime    @"token_retrieval_time"
#define kLocalyticsLoginAttemptedAttributeNetworkType           @"network_type"
#define kLocalyticsLoginAttemptedAttributeAddressBookSize       @"address_book_size"
#define kLocalyticsLoginAttemptedAttributeChatHistoryCount      @"chat_history_count"
#define kLocalyticsLoginAttemptedAttributeAttemptTypeConnectValue   @"Connect"
#define kLocalyticsLoginAttemptedAttributeAttemptTypeReconnectValue @"Reconnect"

/***** DON'T CHANGE THE ABOVE KEYWORDS, AS ALL LOCALYTICS DATA DEPENDS ON IT *****/


// Mime types
#define kMimeTypeVideoQuickTime                     @"video/quicktime"
#define kMimeTypeImageJPEG                          @"image/jpeg"
#define kMimeTypeTextVCard                          @"text/vcard"
#define kMimeTypeTextMedia                          @"text/media"
#define kMimeTypeAudio                              @"audio"
#define kMimeTypeApplicationOctetStream             @"application/octet-stream"
#define kMimeTypeApplicationGZip                    @"application/gzip"

// File types
// This is different from mime type, it shows how the file is used by server (timeouts, buckets and so on).
// Files with the same mime types (for example, "image/jpeg") can be used as sent message or as avatar of user.
#define kFileTypeVideo                              @"video"
#define kFileTypePicture                            @"picture"
#define kFileTypeVCard                              @"vcard"
#define kFileTypeAvatar                             @"avatar"
#define kFileTypeThumbnail                          @"thumbnail"
#define kFileTypeOther                              @"other"


// App notification bar height
#define kNotificationBarHeight                      20.0f

// DateTime formatting strings
#define kCommonISO8601DateTimeFormat        @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"

// Max number of characters for group conversation subject.
#define kMaxCharactersSubject   25

// Max number of participants that can be in a group conversation.
#define kMaxParticipantsGroupConversation   50
