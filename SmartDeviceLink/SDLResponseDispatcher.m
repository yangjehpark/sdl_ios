//
//  SDLResponseDispatcher.m
//  SmartDeviceLink-iOS
//
//  Created by Joel Fischer on 7/8/16.
//  Copyright © 2016 smartdevicelink. All rights reserved.
//

#import "SDLResponseDispatcher.h"

#import "NSMutableDictionary+SafeRemove.h"
#import "SDLAddCommand.h"
#import "SDLAlert.h"
#import "SDLButtonName.h"
#import "SDLDeleteCommand.h"
#import "SDLDeleteCommandResponse.h"
#import "SDLError.h"
#import "SDLOnButtonEvent.h"
#import "SDLOnButtonPress.h"
#import "SDLOnCommand.h"
#import "SDLRPCResponse.h"
#import "SDLResult.h"
#import "SDLScrollableMessage.h"
#import "SDLShow.h"
#import "SDLSoftButton.h"
#import "SDLSubscribeButton.h"
#import "SDLUnsubscribeButton.h"
#import "SDLUnsubscribeButtonResponse.h"


NS_ASSUME_NONNULL_BEGIN

@implementation SDLResponseDispatcher

- (instancetype)init {
    return [self initWithNotificationDispatcher:nil];
}

- (instancetype)initWithNotificationDispatcher:(nullable id)dispatcher {
    self = [super init];
    if (!self) {
        return nil;
    }

    _rpcResponseHandlerMap = [NSMapTable mapTableWithKeyOptions:NSMapTableCopyIn valueOptions:NSMapTableCopyIn];
    _rpcRequestDictionary = [NSMutableDictionary dictionary];
    _commandHandlerMap = [NSMapTable mapTableWithKeyOptions:NSMapTableCopyIn valueOptions:NSMapTableCopyIn];
    _buttonHandlerMap = [NSMapTable mapTableWithKeyOptions:NSMapTableCopyIn valueOptions:NSMapTableCopyIn];
    _customButtonHandlerMap = [NSMapTable mapTableWithKeyOptions:NSMapTableCopyIn valueOptions:NSMapTableCopyIn];

    // Responses
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveAddCommandResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveAddSubMenuResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveAlertResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveAlertManeuverResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveChangeRegistrationResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveCreateInteractionChoiceSetResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveDeleteCommandResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveDeleteFileResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveDeleteInteractionChoiceSetResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveDeleteSubmenuResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveDiagnosticMessageResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveDialNumberResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveEncodedSyncPDataResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveEndAudioPassThruResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveGenericResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveGetDTCsResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveGetVehicleDataResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveListFilesResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceivePerformAudioPassThruResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceivePerformInteractionResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceivePutFileResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveReadDIDResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveRegisterAppInterfaceResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveResetGlobalPropertiesResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveScrollableMessageResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveSendLocationResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveSetAppIconResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveSetDisplayLayoutResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveSetGlobalPropertiesResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveSetMediaClockTimerResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveShowConstantTBTResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveShowResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveSliderResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveSpeakResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveSubscribeButtonResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveSubscribeVehicleDataResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveSyncPDataResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveUpdateTurnListResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveUnregisterAppInterfaceResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveUnsubscribeButtonResponse object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlersForResponse:) name:SDLDidReceiveUnsubscribeVehicleDataResponse object:dispatcher];

    // Buttons and Commands
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlerForButton:) name:SDLDidReceiveButtonEventNotification object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlerForButton:) name:SDLDidReceiveButtonPressNotification object:dispatcher];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sdl_runHandlerForCommand:) name:SDLDidReceiveCommandNotification object:dispatcher];

    return self;
}


#pragma mark - Storage

- (void)storeRequest:(SDLRPCRequest *)request handler:(nullable SDLRequestCompletionHandler)handler {
    NSNumber *correlationId = request.correlationID;

    // Check for RPCs that require an extra handler
    if ([request isKindOfClass:[SDLShow class]]) {
        SDLShow *show = (SDLShow *)request;
        [self sdl_addToHandlerMapWithSoftButtons:show.softButtons];
    } else if ([request isKindOfClass:[SDLAddCommand class]]) {
        SDLAddCommand *addCommand = (SDLAddCommand *)request;
        if (!addCommand.cmdID) {
            @throw [NSException sdl_missingIdException];
        }
        if (addCommand.handler) {
            self.commandHandlerMap[addCommand.cmdID] = addCommand.handler;
        }
    } else if ([request isKindOfClass:[SDLSubscribeButton class]]) {
        // Convert SDLButtonName to NSString, since it doesn't conform to <NSCopying>
        SDLSubscribeButton *subscribeButton = (SDLSubscribeButton *)request;
        NSString *buttonName = subscribeButton.buttonName.value;
        if (!buttonName) {
            @throw [NSException sdl_missingIdException];
        }
        if (subscribeButton.handler) {
            self.buttonHandlerMap[buttonName] = subscribeButton.handler;
        }
    } else if ([request isKindOfClass:[SDLAlert class]]) {
        SDLAlert *alert = (SDLAlert *)request;
        [self sdl_addToHandlerMapWithSoftButtons:alert.softButtons];
    } else if ([request isKindOfClass:[SDLScrollableMessage class]]) {
        SDLScrollableMessage *scrollableMessage = (SDLScrollableMessage *)request;
        [self sdl_addToHandlerMapWithSoftButtons:scrollableMessage.softButtons];
    }

    // Always store the request, it's needed in some cases whether or not there was a handler (e.g. DeleteCommand).
    self.rpcRequestDictionary[correlationId] = request;
    if (handler) {
        self.rpcResponseHandlerMap[correlationId] = handler;
    }
}

- (void)clear {
    [self.rpcRequestDictionary removeAllObjects];
    [self.rpcResponseHandlerMap removeAllObjects];
    [self.commandHandlerMap removeAllObjects];
    [self.buttonHandlerMap removeAllObjects];
    [self.customButtonHandlerMap removeAllObjects];
}

- (void)sdl_addToHandlerMapWithSoftButtons:(NSMutableArray<SDLSoftButton *> *)softButtons {
    for (SDLSoftButton *sb in softButtons) {
        if (!sb.softButtonID) {
            @throw [NSException sdl_missingIdException];
        }
        if (sb.handler) {
            self.customButtonHandlerMap[sb.softButtonID] = sb.handler;
        }
    }
}


#pragma mark - Notification Handler

// Called by notifications
- (void)sdl_runHandlersForResponse:(NSNotification *)notification {
    NSAssert([notification.userInfo[SDLNotificationUserInfoObject] isKindOfClass:[SDLRPCResponse class]], @"A notification was sent with an unanticipated object");
    if (![notification.userInfo[SDLNotificationUserInfoObject] isKindOfClass:[SDLRPCResponse class]]) {
        return;
    }

    __kindof SDLRPCResponse *response = notification.userInfo[SDLNotificationUserInfoObject];

    NSError *error = nil;
    if (![response.success boolValue]) {
        error = [NSError sdl_lifecycle_rpcErrorWithDescription:response.resultCode.value andReason:response.info];
    }

    // Find the appropriate request completion handler, remove the request and response handler
    SDLRequestCompletionHandler handler = self.rpcResponseHandlerMap[response.correlationID];
    SDLRPCRequest *request = self.rpcRequestDictionary[response.correlationID];
    [self.rpcRequestDictionary safeRemoveObjectForKey:response.correlationID];
    [self.rpcResponseHandlerMap safeRemoveObjectForKey:response.correlationID];

    // Run the response handler
    if (handler) {
        handler(request, response, error);
    }

    // If we errored on the response, the delete / unsubscribe was unsuccessful
    if (error) {
        return;
    }

    // If it's a DeleteCommand or UnsubscribeButton, we need to remove handlers for the corresponding commands / buttons
    if ([response isKindOfClass:[SDLDeleteCommandResponse class]]) {
        SDLDeleteCommand *deleteCommandRequest = (SDLDeleteCommand *)request;
        NSNumber *deleteCommandId = deleteCommandRequest.cmdID;
        [self.commandHandlerMap safeRemoveObjectForKey:deleteCommandId];
    } else if ([response isKindOfClass:[SDLUnsubscribeButtonResponse class]]) {
        SDLUnsubscribeButton *unsubscribeButtonRequest = (SDLUnsubscribeButton *)request;
        NSString *unsubscribeButtonName = unsubscribeButtonRequest.buttonName.value;
        [self.buttonHandlerMap safeRemoveObjectForKey:unsubscribeButtonName];
    }
}

#pragma mark Command

- (void)sdl_runHandlerForCommand:(NSNotification *)notification {
    SDLOnCommand *onCommandNotification = notification.userInfo[SDLNotificationUserInfoObject];
    SDLRPCNotificationHandler handler = nil;

    handler = self.commandHandlerMap[onCommandNotification.cmdID];
    if (handler) {
        handler(onCommandNotification);
    }
}

#pragma mark Button

- (void)sdl_runHandlerForButton:(NSNotification *)notification {
    __kindof SDLRPCNotification *rpcNotification = notification.userInfo[SDLNotificationUserInfoObject];

    SDLRPCNotificationHandler handler = nil;
    SDLButtonName *name = nil;
    NSNumber *customID = nil;

    if ([rpcNotification isKindOfClass:[SDLOnButtonEvent class]]) {
        name = ((SDLOnButtonEvent *)rpcNotification).buttonName;
        customID = ((SDLOnButtonEvent *)rpcNotification).customButtonID;
    } else if ([rpcNotification isKindOfClass:[SDLOnButtonPress class]]) {
        name = ((SDLOnButtonPress *)rpcNotification).buttonName;
        customID = ((SDLOnButtonPress *)rpcNotification).customButtonID;
    }

    if ([name isEqual:[SDLButtonName CUSTOM_BUTTON]]) {
        handler = self.customButtonHandlerMap[customID];
    } else {
        handler = self.buttonHandlerMap[name.value];
    }

    if (handler) {
        handler(rpcNotification);
    }
}

@end

NS_ASSUME_NONNULL_END
