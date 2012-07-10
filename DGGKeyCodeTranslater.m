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

// Created by Danny Greg on 08/7/2012

//*******************************************************************************

#import "DGGKeyCodeTranslater.h"

#import <Carbon/Carbon.h>

@implementation DGGKeyCodeTranslater

+ (NSString *)stringForKeycode:(unsigned short)keycode
{
	TISInputSourceRef keyboardLayout = TISCopyCurrentKeyboardLayoutInputSource();
	CFDataRef uchr = TISGetInputSourceProperty(keyboardLayout , kTISPropertyUnicodeKeyLayoutData);
	UniCharCount maxStringLength = 4;
	UniCharCount actualStringLength = 0;
	UniChar outChar[4];
	UInt32 deadKeyState;
	OSStatus result = UCKeyTranslate((const UCKeyboardLayout *)CFDataGetBytePtr(uchr), keycode, kUCKeyActionDisplay, 0, LMGetKbdType(), kUCKeyTranslateNoDeadKeysBit, &deadKeyState, maxStringLength, &actualStringLength, outChar);
	if (result != noErr)
		return nil;
	
	return [NSString stringWithCharacters:outChar length:actualStringLength];
}

@end
