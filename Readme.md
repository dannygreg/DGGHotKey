# DGGHotKey

A super-simple, modern interface to system hot keys in cocoa.

## Usage

The API, whilst horribly undocumented, is fairly trivial. Create a DGGKeyCombo using a keycode and modifier mask, then register it with a handler block.

Boom! Your block will be invoked whenever the hotkey is pressed.

You are returned an opaque pointer from the registration, hang onto it, you will need it if you wish to unregister the hotkey.

## All Cocoa, All the Time

You don't have to worry about Carbon types or constants. For the modifier mask, use the constants defined in `NSEvent.h`, `NSCommandKeyMask` and friends. 

## Dependencies

You need to be linking the `Carbon` framework in your project.

## Tip of the Hat

This was all inspired by PTHotKey and the superb [ShortcutRecorder](http://code.google.com/p/shortcutrecorder/).

## License

Distributed under the MIT license.
