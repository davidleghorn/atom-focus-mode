# atom-focus-mode

Helps you focus on only the lines of code you are working with, all other lines are faded into the background.<br/>
Hides editor panels and enters full screen mode for distraction free coding.

![Focus cursor mode with focus mode line opacity set at 100% ](https://raw.githubusercontent.com/davidleghorn/atom-focus-mode/new-screenshots/screenshots/intro-image.png)

**To activate/de-activate focus modes:**
* atom menu bar `Packages > Focus Mode`
* `Right click menu > Focus Mode`
* Use key bindings (see table below)

Focus Mode          | Description                            
--------------------|----------------------------------------|
Scope Focus<br/>`ctrl+alt+p`| Automatically focus highlights lines inside the method/function/class scope that the cursor was placed inside.
Cursor Focus<br/>`ctrl+alt+o` | Focus highlights any lines that receive cursor focus and any lines that have been selected with your mouse
Cursor Shadow Focus<br/>`ctrl+alt+u` | Focus highlights the cursor line and the 2 lines above and below the cursor line (configurable in package settings)
Single Line Focus<br/>`ctrl+alt+i` | Focus highlights the single line(s) that have cursor focus
Exit<br/>`esc`      | To exit a focus mode, press `esc` key or select the focus mode again (using menu or key bindings).<br>From atom menu `Packages > Focus Mode > Exit` or `Right click menu > Focus Mode > Exit`

To change the key bindings used by Focus Mode, Atom > Preferences > Keybindings.

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
* Requires correct indentation of code block closing curly braces.
* Does not focus scope when using multiple cursors.

**To configure focus mode as per version 0.8 and earlier**

In package settings:
* Set "Cursor Focus Mode Line Opacity" option to "100%"
* Set all options in the "When Focus Mode is Activated" section to false (not checked)

### Screenshots

**Scope focus mode**<br/>
 Highlights lines inside the method/function/class scope that the cursor was placed inside

![Scope focus mode with focus mode line opacity set at 65%](https://raw.githubusercontent.com/davidleghorn/atom-focus-mode/new-screenshots/screenshots/scope-focus.png)


**Cursor focus mode**<br/>
 Highlights any lines you placed the cursor on or selected with your mouse

 ![Cursor focus mode with focus mode line opacity set at 65%](https://raw.githubusercontent.com/davidleghorn/atom-focus-mode/new-screenshots/screenshots/cursor-focus.png)

**Cursor shadow focus mode**<br/>
 Highlights the cursor line and 2 lines above and below the cursor line (configurable)

 ![Cursor shadow focus mode with focus mode line opacity set at 65%](https://raw.githubusercontent.com/davidleghorn/atom-focus-mode/new-screenshots/screenshots/cursor-shadow-focus.png)

**Single line focus mode**<br/>
 Highlights any line(s) that have cursor focus

 ![Cursor shadow focus mode with focus mode line opacity set at 65%](https://raw.githubusercontent.com/davidleghorn/atom-focus-mode/new-screenshots/screenshots/single-line-focus.png)
