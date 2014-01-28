# DMTestSettings CHANGELOG

## 0.1.0

- Initial release.

## 0.1.1

- Fixed detection of shake gesture, when apps have viewcontroller/views that acts as first responders.

## 0.1.2

- Added option to GridOverlay plugin exclude status bar grid

## 0.1.3

- Added FPS plugin – shows small fps count in status bar
- ColorBlind plugin improved responsiveness
- Fixed GridOverlay plugin not excluding status bar correctly when rotating device
- Better presentation of test settings panel on iPad

## 0.2.0

- Better handling of showing overlay windows to reduce plugin overhead
- Less overhead when calling [DMTestSettings start]. Only creates a single UIWindow to catch shake gesture.
- Settings panel know shows in own UIWindow, to avoid messing with status bar style and to present above alert views, pop-ups etc.

## 0.3.0

- Added plugin for changing animation speed  
