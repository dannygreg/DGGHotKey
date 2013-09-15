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

#import "DGGKeyCombo.h"

#import "DGGKeyCodeTranslater.h"

NSString *const DGGKeyComboPlistRepKeyCodeKey = @"keyCode";
NSString *const DGGKeyComboPlistRepModifierMaskKey = @"modifierMask";

@implementation DGGKeyCombo

@synthesize keyCode = _keyCode;
@synthesize modifierMask = _modifierMask;

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
	
	_keyCode = NSUIntegerMax;
	_modifierMask = NSUIntegerMax;
	
    return self;
}

- (id)initWithKeyCode:(NSUInteger)keyCode modifierMask:(NSUInteger)modifierMask
{
    self = [self init];
    if (self == nil)
        return nil;
	
	_keyCode = keyCode;
	_modifierMask = modifierMask;
	
    return self;
}

- (id)initWithPlistRepresentation:(id)representation
{
    self = [self init];
    if (self == nil)
        return nil;
	
	if (representation == nil || [representation count] < 2)
		return self;
	
	_keyCode = [[representation objectForKey:DGGKeyComboPlistRepKeyCodeKey] unsignedIntegerValue];
	_modifierMask = [[representation objectForKey:DGGKeyComboPlistRepModifierMaskKey] unsignedIntegerValue];
	
    return self;
}

#pragma mark - Computed Properties

- (BOOL)isEmpty
{
	return (self.keyCode == NSUIntegerMax && self.modifierMask == NSUIntegerMax);
}

- (id)plistRepresentation
{
	return @{ DGGKeyComboPlistRepKeyCodeKey : [NSNumber numberWithUnsignedInteger:self.keyCode], DGGKeyComboPlistRepModifierMaskKey : [NSNumber numberWithUnsignedInteger:self.modifierMask] };
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object
{
	if (![object isKindOfClass:self.class])
		return NO;
	
	DGGKeyCombo *comparisonObject = object;
	return (comparisonObject.keyCode == self.keyCode && comparisonObject.modifierMask == self.modifierMask);
}

- (NSUInteger)hash
{
	return [[NSNumber numberWithUnsignedInteger:(self.keyCode + self.modifierMask)] hash];
}

#pragma mark - 

- (NSString *)description
{	
		
	BOOL commandKey = (BOOL)(self.modifierMask & NSCommandKeyMask);
	BOOL optionKey = (BOOL)(self.modifierMask & NSAlternateKeyMask);
	BOOL shiftKey = (BOOL)(self.modifierMask & NSShiftKeyMask);
	BOOL controlKey = (BOOL)(self.modifierMask & NSControlKeyMask);
	NSMutableString *returnString = [NSMutableString stringWithFormat:@"\n%@\n{", [super description]];
	[returnString appendString:@"\n"];
	if (commandKey)
		[returnString appendString:@"Command, "];
	if (optionKey)
		[returnString appendString:@"Option, "];
	if (shiftKey)
		[returnString appendString:@"Shift, "];
	if (controlKey)
		[returnString appendString:@"Control, "];
	
	NSString *keyString = [DGGKeyCodeTranslater stringForKeycode:self.keyCode];
	[returnString appendFormat:@"%@(%lu)", keyString, self.keyCode];
	[returnString appendString:@"\n}"];
	return returnString;
}

@end
