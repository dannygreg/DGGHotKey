//*******************************************************************************

// Copyright (c) 2012 Danny Greg

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// Created by Danny Greg on 29/6/2012

//*******************************************************************************

#import "DGGHotKey.h"

#import "DGGKeyCombo.h"

#import <Carbon/Carbon.h>

@interface DGGHotKey ()

@property (nonatomic) UInt32 hotKeyID;
@property (nonatomic, copy) void(^handlerBlock)();
@property (nonatomic) EventHotKeyRef carbonHotKey;

static OSStatus DGGHotKeyPressedHandler(EventHandlerCallRef inHandlerRef, EventRef inEvent, void* refCon);

@end

@implementation DGGHotKey

BOOL DGGHotKeyHandlerInstalled = NO;
UInt32 DGGLatestHotKeyID = 0;
NSMutableDictionary *DGGHotKeyBlockMap = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wfour-char-constants"
FourCharCode DGGHotKeyCarbonID = 'DGGH';
#pragma clang diagnostic pop

+ (void)initialize
{
	DGGHotKeyBlockMap = [[NSMutableDictionary alloc] init];
	EventTypeSpec keyDownSpec = {kEventClassKeyboard, kEventHotKeyPressed};
	OSStatus result = InstallEventHandler(GetEventDispatcherTarget(), DGGHotKeyPressedHandler, 1, &keyDownSpec, NULL, NULL);
	DGGHotKeyHandlerInstalled = (result == noErr);
}

+ (id)registerHotKeyForKeyCombo:(DGGKeyCombo *)combo withError:(NSError **)error usingBlock:(void(^)())handlerBlock
{
	void (^assignErrorWithCodeMessage)(NSInteger, NSString *) = ^ (NSInteger code, NSString *errorMessage) {
		if (error == NULL)
			return;
		
		*error = [NSError errorWithDomain:@"com.dannygreg.dgghotkey" code:code userInfo:@{ NSLocalizedDescriptionKey : errorMessage }];
	};
	
	if (!DGGHotKeyHandlerInstalled) {
		assignErrorWithCodeMessage(DGGHotKeyErrorNoHandler, NSLocalizedString(@"Could not initialise global hot key handler", nil));
		return nil;
	}
	
	UInt32 carbonModifierFlags = 0;
	if (combo.modifierMask & NSCommandKeyMask) carbonModifierFlags |= cmdKey;
	if (combo.modifierMask & NSAlternateKeyMask) carbonModifierFlags |= optionKey;
	if (combo.modifierMask & NSControlKeyMask) carbonModifierFlags |= controlKey;
	if (combo.modifierMask & NSShiftKeyMask) carbonModifierFlags |= shiftKey;
	
	EventHotKeyID hotKeyID = {DGGHotKeyCarbonID, ++DGGLatestHotKeyID};
	EventHotKeyRef carbonHotKey = NULL;
	OSStatus result = RegisterEventHotKey((UInt32)combo.keyCode, carbonModifierFlags, hotKeyID, GetEventDispatcherTarget(), kEventHotKeyExclusive, &carbonHotKey);
	if (result != noErr) {
		assignErrorWithCodeMessage(result, NSLocalizedString(@"Could not register global hotkey", nil));
		return nil;
	}
	
	DGGHotKey *hotKey = [[DGGHotKey alloc] init];
	hotKey.handlerBlock = handlerBlock;
	hotKey.hotKeyID = hotKeyID.id;
	hotKey.carbonHotKey = carbonHotKey;
	
	[DGGHotKeyBlockMap setObject:hotKey forKey:[NSNumber numberWithUnsignedInteger:hotKeyID.id]];
	
	return hotKey;
}

+ (BOOL)unregisterHotKeyWithIdentifier:(id)identifier
{
	if (identifier == nil)
		return YES;
	
	return (UnregisterEventHotKey([identifier carbonHotKey]) == noErr);
}

#pragma mark - Carbon Callbacks

static OSStatus DGGHotKeyPressedHandler(EventHandlerCallRef inHandlerRef, EventRef event, void* refCon)
{
	if (GetEventClass(event) != kEventClassKeyboard)
		return noErr;
	
	EventHotKeyID hotKeyID;
	OSStatus result = GetEventParameter(event, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyID), NULL, &hotKeyID);
	if (result != noErr)
		return result;
	
	if (hotKeyID.signature != DGGHotKeyCarbonID)
		return noErr;
	
	DGGHotKey *hotKey = [DGGHotKeyBlockMap objectForKey:[NSNumber numberWithUnsignedInteger:hotKeyID.id]];
	if (hotKey == nil)
		return noErr;
	
	if (hotKey.handlerBlock != nil) //It would be dumb… but let's be safe
		hotKey.handlerBlock();
	
	return noErr;
}

@end
