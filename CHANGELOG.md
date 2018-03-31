
## 0.13.0  (2017-03-31)
* Scope focus mode support added for Ruby files

## 0.12.2  (2017-02-10)
* Fix to prevent focus mode exiting full screen when atom editor is full screen and focus mode full screen setting is off
* unit test fixes

## 0.12.1  (2017-02-03)
* Fixed Odd shadow behaviour on word-wrapped lines bug

## 0.12.0  (2017-12-22)
* Fixed TextEditor.setScrollTop deprecation warning

## 0.11.0  (2017-04-12)
* Added: Type writer scrolling feature - keeps the line containing the cursor in the center of the text editor. Can be toggled on/off using a keyboard shortcut or via package settings.
* Added: Package setting to center editor when focus mode is activated.
* Enhancement: In ".txt" and ".md" files, Scope Focus highlights text blocks that the cursor was placed inside - any text surrounded by blank lines is considered a text block e.g. paragraphs.
* Enhancement/bug fix: Cursor focus now works with soft wrapped lines.

## 0.10.0  (2017-04-06)
* Breaking change: keyboard shortcut to exit focus mode is now ctrl-alt-cmd instead of esc key.
* Change: Activating scope focus mode now warns if file type is incompatible before opening scope focus mode.
* Enhancement: Atom theme gutter background colour now matches editor background colour when focus mode is activated and editor side panels are hidden.

## 0.9.0  (2017-04-04)
* Added: new package configuration settings.
* Changed: Focus mode now enters full screen and hides editor panels, bars and tabs when a focus mode is activated (configurable via package settings).
* Enhanced: Focus mode highlighted line opacity now also applies to scope focus mode. Highlighted line opacity can be configured to 65% or 100% via package settings.

## 0.8.0  (2017-03-31)
* Added: "Scope Focus" feature - focus highlights class/method/function scopes in javascript, coffee script and python files
* Changed: Menu options re-named and order changed

## 0.7.0  (2017-03-27)
* Deprecated shadow DOM selectors removed

## 0.6.0  (2016-01-07)
* Added package setting to configure focus mode highlighted line opacity

## 0.5.0  (2015-12-30)
* Implemented config observe so any changes to config values are immediately reflected.
* Updated config json schema to include minimum values
* Refactoring

## 0.4.0  (2015-12-27)
* Added package settings to configure the number of rows to highlight in focus shadow mode

## 0.3.0  (2015-12-23)
* Enhanced to highlight any text selections across multiple editors when focus mode is activated

## 0.2.0  (2015-12-21)
* Added Focus shadow mode feature

## 0.1.2  (2015-12-11)
* Fixed a bug where lines added between focus mode highlighted lines did not receive focus mode styling.
Implementation updated to cache focus line markers rather than focussed row numbers.
* Updated CSS to also fade the file explorer sidebar when focus mode is activated

## 0.1.1  (2015-12-08)
* Changed ReadMe screenshot url

## 0.1.0  (2015-12-08)
* First release
