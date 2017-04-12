
class FocusModeBase

    constructor: ->
        @focusLineCssClass = "focus-line"
        @focusModeBodyCssClass = "focus-cursor-mode"


    getConfig: (key) ->
        return atom.config.get(key)


    setConfig: (key, value) ->
        atom.config.set(key, value)


    getAtomWorkspaceTextEditors: ->
        return atom.workspace.getTextEditors()


    getActiveTextEditor: ->
        return atom.workspace.getActiveTextEditor()


    getActiveEditorFileType: () =>
        editor = @getActiveTextEditor()
        splitFileName = editor?.getTitle().split(".") or []
        return splitFileName[1] or ""

        
    getAtomNotificationsInstance: ()->
        return atom.notifications


    getBodyTagElement: ->
        return document.getElementsByTagName("body")[0]


    addCssClass: (elem, cssClass) =>
        unless @hasCssClass(elem, cssClass)
            elem.className += " #{cssClass}"


    removeCssClass: (elem, cssClass) ->
        elem.className = elem.className.replace(///\s*#{cssClass}///g, "")


    hasCssClass: (elem, cssClass) ->
        return cssClass in elem.className


    removeFocusLineClass: =>
        for editor in @getAtomWorkspaceTextEditors()
             editorLineDecorations = editor.getLineDecorations()

             for decoration in editorLineDecorations
                 decorationProperties = decoration.getProperties()

                 if decorationProperties.class and decorationProperties.class is @focusLineCssClass
                     marker = decoration.getMarker()
                     marker.destroy()


module.exports = FocusModeBase
