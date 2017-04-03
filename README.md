# atom-focus-mode

* **Helps you focus on only the lines of code you are working with, all other lines are faded into the background**
* **Hides atom panels/tabs/bars and enters full screen mode** (configurable via package settings)

### Focus Modes

Activate/de-activate focus modes - main atom menu bar ***Packages > Focus Mode***, or ***Right click menu > Focus Mode*** or use ***key bindings***.

| Focus Mode          | Description                            | Key bindings  |
| --------------------|----------------------------------------|-------------- |
| Scope Focus         | Automatically focus highlights lines inside the method/function/class scope that the cursor was placed inside. | ctrl + alt + p |
| Cursor Focus        | Focus highlights any lines that receive cursor focus and any lines that have been selected with your mouse | ctrl + alt + o |
| Cursor Shadow Focus | Focus highlights the cursor line and the 2 lines above and below the cursor line (configurable in package settings) | ctrl + alt + u |
| Single Line Focus   | Focus highlights the single line(s) that have cursor focus | ctrl + alt + i |
| Exit Focus Mode     | Press esc key<br>Select the focus mode option again (using menu or key bindings)<br>***Packages > Focus Mode > Exit*** or ***Right click menu > Focus Mode > Exit*** | esc            |

You can change the key bindings used by Focus Mode via Atom > Preferences > Keybindings.

### Package settings

| Setting                         | Default | Description |
|---------------------------------|---------|-------------|
| Cursor Focus Mode Line Opacity  | 65%   | Line opacity applied to any cursor focus mode highlighted lines. Options 65% or 100% |
| Enter Full Screen               | true  | When focus mode is activated the atom editor enters full screen mode |
| Hide Footer Bar                 | true  | When focus mode is activated hide editor footer bar |
| Hide Line Numbers               | true  | When focus mode is activated hide editor line numbers |
| Hide Line Length Guide          | false | When focus mode is activated hide the line length guide line |
| Hide Footer Bar                 | true  | When focus mode is activated hide the editor footer bar |
| Hide Side Panels                | true  | When focus mode is activated hide the file explorer panel and any panels to the right of the editor window |
| Hide Tab Bar                    | true  | When focus mode is activated hide the editor open file tabs |
| Use large font size             | false | When focus mode is activated increase font size to 18px (note: this mode also hides the line length guide)    |
| Number of lines to highlight above cursor | 2 | Number of lines above the cursor line to focus highlight in Focus Shadow mode |
| Number of lines to highlight below cursor | 2 | Number of lines below the cursor line to focus highlight in Focus Shadow mode |

### Notes

**To configure focus mode as per version 0.8 and earlier**

In package settings:
* Set "Cursor Focus Mode Line Opacity" option to "100%"
* Set all options in the "When Focus Mode is Activated" section to false (not checked)

**Scope Focus mode notes:**

* Scope focus currently supports files with ".js", ".coffee" and ".py" file extensions (more file types to follow).
* Scope focus in javascript files requires correct indentation of code block closing curly braces.
* Does not focus scope when using multiple cursors.
