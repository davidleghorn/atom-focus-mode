# atom-focus-mode

Helps you focus on only the lines of code you are working with, all other lines are faded into the background.<br/>
Hides editor panels and enters full screen mode for distraction free coding.

![Focus cursor mode screenshot](https://raw.githubusercontent.com/davidleghorn/atom-focus-mode/master/screenshots/focus-mode.png)

**Toggle focus modes** via atom menu bar `Packages > Focus Mode`, or `Right click menu > Focus Mode` or using `key bindings`.

| Focus Mode          | Description                            | Key bindings  |
| --------------------|----------------------------------------|-------------- |
| Scope Focus         | Automatically focus highlights lines inside the method/function/class scope that the cursor was placed inside. | `ctrl+alt+p` |
| Cursor Focus        | Focus highlights any lines that receive cursor focus and any lines that have been selected with your mouse | `ctrl+alt+o` |
| Cursor Shadow Focus | Focus highlights the cursor line and the 2 lines above and below the cursor line (configurable in package settings) | `ctrl+alt+u` |
| Single Line Focus   | Focus highlights the single line(s) that have cursor focus | `ctrl+alt+i` |
| Exit                | To exit a focus mode, press `esc` key, or<br/>Select the focus mode again (using menu or key bindings), or <br>`Packages > Focus Mode > Exit` or `Right click menu > Focus Mode > Exit` | `esc`            |

To change the key bindings used by Focus Mode `Atom > Preferences > Keybindings`.

### Package settings

| Setting                         | Default | Description |
|---------------------------------|---------|-------------|
| Focus Mode Line Opacity  | 65%   | Line opacity applied to any focus mode highlighted lines (options 65% or 100%) |
| Enter Full Screen               | true  | When focus mode is activated enter full screen mode |
| Hide Footer Bar                 | true  | When focus mode is activated hide editor footer bar |
| Hide Line Numbers               | true  | When focus mode is activated hide editor line numbers |
| Hide Line Length Guide          | false | When focus mode is activated hide the line length guide line |
| Hide Footer Bar                 | true  | When focus mode is activated hide the editor footer bar |
| Hide Side Panels                | true  | When focus mode is activated hide side panels e.g. the file explorer |
| Hide Tab Bar                    | true  | When focus mode is activated hide any opened file tabs |
| Use large font size             | false | When focus mode is activated increase font size to 18px (note: this mode also hides the line length guide)    |
| Number of lines to highlight above cursor | 2 | Number of lines above the cursor line to focus highlight in Focus Shadow mode |
| Number of lines to highlight below cursor | 2 | Number of lines below the cursor line to focus highlight in Focus Shadow mode |

### Notes

**Scope Focus mode**

* Currently supports files with ".js", ".coffee" and ".py" file extensions (more file types to follow).
* In javascript files requires correct indentation of code block closing curly braces.
* Does not focus scope when using multiple cursors.

**To configure focus mode as per version 0.8 and earlier**

In package settings:
* Set "Cursor Focus Mode Line Opacity" option to "100%"
* Set all options in the "When Focus Mode is Activated" section to false (not checked)

### Screenshots

**Scope focus mode**

![Focus scope mode screenshot](https://raw.githubusercontent.com/davidleghorn/atom-focus-mode/master/screenshots/scope-focus.png)
