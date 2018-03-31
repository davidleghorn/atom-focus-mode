# atom-focus-mode

Focus modes that help you focus on only the lines of code you are working with, all other lines are faded into the background.<br/>
Hides editor panels and enters full screen mode for distraction free coding.<br/>
Typewriter mode keeps the cursor line positioned in the center of the editor.

![Focus cursor mode with focus mode line opacity set at 100% ](https://raw.githubusercontent.com/davidleghorn/atom-focus-mode/master/screenshots/focus-mode.png)

**To activate/de-activate focus modes:**
* atom menu bar `Packages > Focus Mode`
* `Right click menu > Focus Mode`
* Use key bindings (see table below)

Focus Mode          | Description                            | Key bindings
------------------- | -------------------------------------- | -------------
Scope Focus         | Automatically focus highlights lines inside the method/function/class scope that the cursor was placed inside.<br/><br/>In ".txt" and ".md" files, scope focus highlights text blocks that the cursor was placed inside - any text surrounded by blank lines is considered a text block. | `ctrl-alt-p`
Cursor Focus        | Focus highlights any lines that receive cursor focus and any lines that have been selected with your mouse | `ctrl-alt-o`
Cursor Shadow Focus | Focus highlights the cursor line and the 2 lines above and below the cursor line (configurable in package settings) | `ctrl-alt-u`
Single Line Focus   | Focus highlights the single line(s) that have cursor focus | `ctrl-alt-i`
Exit    | To exit a focus mode, press `ctrl-alt-cmd` keys or select the focus mode again (using menu or key bindings).<br>From atom menu `Packages > Focus Mode > Exit` or `Right click menu > Focus Mode > Exit` | `ctrl-alt-cmd`

To change the key bindings used by Focus Mode `Atom > Preferences > Keybindings`.

### Package settings

Setting                         | Default  | Description
------------------------------- | -------- | ----------------
Focus Mode Line Opacity  | 65% | Line opacity applied to any focus mode highlighted lines (options 65% or 100%)
Enter Full Screen | true  | When focus mode is activated enter full screen mode
Center Editor | Off | Hides side panels and centers the editor. Editor width options - "700px" (Medium.com article width), "888px" (github content/ReadMe width), "60%", "70%", "80%" and "90%".
Hide Footer Bar | true | When focus mode is activated hide editor footer bar
Hide Line Numbers | true | When focus mode is activated hide editor line numbers
Hide Line Length Guide | false | When focus mode is activated hide the line length guide line
Hide Side Panels | true  | When focus mode is activated hide side panels e.g. the file explorer
Hide Tab Bar | false  | When focus mode is activated hide the top tab bar containing open file tabs
Use large font size | false | When focus mode is activated increase font size to 18px (note: this mode also hides the line length guide)
Number of lines to highlight above cursor | 2 | Number of lines above the cursor line to focus highlight in Focus Shadow mode
Number of lines to highlight below cursor | 2 | Number of lines below the cursor line to focus highlight in Focus Shadow mode

### Notes

**Scope Focus mode**

* Currently supports files with ".js", ".coffee", ".py", ".rb", ".txt" and ".md" file extensions (more file types to follow).
* Requires correct indentation of code block closing curly braces.
* Does not focus scope when using multiple cursors.

**Typewriter mode**

* Keeps the line containing the cursor in the center of the text editor.
* Typewriter mode can be toggled on/off using keyboard shortcut `ctrl-alt-t` or via the focus mode menu.

**To configure focus mode as per version 0.8 and earlier**

In package settings:
* Set "Cursor Focus Mode Line Opacity" option to "100%".
* Set all options in the "When Focus Mode is Activated" section to false (not checked).

### Screenshots

**Scope focus mode**<br/>
 Highlights lines inside the method/function/class scope that the cursor was placed inside

![Scope focus mode with focus mode line opacity set at 65%](https://raw.githubusercontent.com/davidleghorn/atom-focus-mode/master/screenshots/scope-focus.png)


**Cursor focus mode**<br/>
 Highlights any lines you placed the cursor on or selected with your mouse

 ![Cursor focus mode with focus mode line opacity set at 65%](https://raw.githubusercontent.com/davidleghorn/atom-focus-mode/master/screenshots/cursor-focus.png)

**Cursor shadow focus mode**<br/>
 Highlights the cursor line and 2 lines above and below the cursor line (configurable)

 ![Cursor shadow focus mode with focus mode line opacity set at 65%](https://raw.githubusercontent.com/davidleghorn/atom-focus-mode/master/screenshots/cursor-shadow-focus.png)

**Single line focus mode**<br/>
 Highlights any line(s) that have cursor focus

 ![Cursor shadow focus mode with focus mode line opacity set at 65%](https://raw.githubusercontent.com/davidleghorn/atom-focus-mode/master/screenshots/single-line-focus.png)

 Screenshots are using the atom theme [nord-atom-ui](https://atom.io/themes/nord-atom-ui)
