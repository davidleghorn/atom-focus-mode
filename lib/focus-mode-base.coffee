
class FocusModeBase

    constructor: ->
        @focusLineCssClass = "focus-line"
        @focusModeBodyCssClass = "focus-cursor-mode"


    getConfig: (key) ->
        return atom.config.get(key)


    getAtomWorkspaceTextEditors: ->
        return atom.workspace.getTextEditors()


    getActiveTextEditor: ->
        return atom.workspace.getActiveTextEditor()


    getBodyTagElement: ->
        return document.getElementsByTagName("body")[0]


    addCssClass: (elem, cssClass) ->
        classNameValue = elem.className
        if (classNameValue.indexOf(cssClass) is -1)
            elem.className = classNameValue + " " + cssClass


    removeCssClass: (elem, cssClass) ->
        elem.className = elem.className.replace(new RegExp("\\s*" + cssClass, "g"), "");


    removeFocusLineClass: =>
        for editor in @getAtomWorkspaceTextEditors()
             editorLineDecorations = editor.getLineDecorations()

             for decoration in editorLineDecorations
                 decorationProperties = decoration.getProperties()

                 if decorationProperties.class and decorationProperties.class is @focusLineCssClass
                     marker = decoration.getMarker()
                     marker.destroy()


module.exports = FocusModeBase
