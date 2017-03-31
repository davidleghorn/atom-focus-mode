# atom-focus-mode

Helps you focus on only the lines of code you are working with, all other lines are faded into the background.

Focus Mode has four focus modes that can be activated/de-activated via the main menu bar Packages menu, the right click context menu or using keyboard shortcuts.

### Scope Focus

Focus highlights class/method/function scopes in javascript, coffee script and python files.

To activate/de-activate scope focus mode:

* Main atom menu bar, Packages > Focus Mode > Cursor Focus
* Right click menu > Focus Mode > Cursor Focus
* Key bindings - ctrl + alt + p

Scope focus limitations:

* Scope focus in javascript files requires correct indentation of code block closing curly braces.
* Scope focus currently supports files with ".js", ".coffee" and ".py" file extensions. Compatibility with other file types to follow.
* Does not focus scope lines when using multiple cursors.


### Cursor Focus

Focus highlights any lines that have receive cursor focus and any lines that have been selected with your mouse.
Cursor focus mode can be useful for focus highlighting any lines matched by a find in file search.

To activate/de-activate cursor focus mode:

* Main atom menu bar, Packages > Focus Mode > Cursor Focus
* Right click menu > Focus Mode > Cursor Focus
* Key bindings - Ctrl + alt + o


### Cursor Shadow Focus

Focus highlights the cursor line and the 2 lines above and below the cursor line. The number of lines to highlight above and below the cursor line can be configured via package settings (defaults to 2 lines).

To activate/de-activate cursor shadow focus mode:

* Main atom menu bar, Packages > Focus Mode > Cursor Shadow Focus
* Right click menu > Focus Mode > Cursor Shadow Focus
* Key bindings - Ctrl + alt + u


### Single Line Focus

Focus highlights the single line(s) that have cursor focus.

To activate/de-activate single line focus mode:

* Main atom menu bar, Packages > Focus Mode > Single Line Focus
* Right click menu > Focus Mode > Single Line Focus
* Key bindings - Ctrl + alt + i


### Focus Mode Key Bindings

You can change the key bindings used by Focus Mode via Atom > Preferences > Keybindings.
