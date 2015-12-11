{CompositeDisposable} = require 'atom'

class FocusModeManager

    focusModeActivated = false
    focusModeSingleLine = false

    constructor: ->
        @cursorEventSubscribers = null
        @focusModeMarkersCache = {}
        @focusModeBodyCssClass = "focus-mode"
        @focusLineCssClass = "focus-line"


    didAddCursor: (cursor) =>
        if @focusModeActivated
            @focusLine(cursor)


    didChangeCursorPosition: (obj) =>
        if @focusModeActivated
            @focusLine(obj.cursor)


    getActiveTextEditor: ->
        return atom.workspace.getActiveTextEditor()


    focusLine: (cursor) =>
        bufferRow = cursor.getBufferRow()
        textEditor = @getActiveTextEditor()

        return if @bufferRowIsAlreadyFocussed(textEditor.id, bufferRow)

        @addFocusLineMarker(textEditor, bufferRow)


    bufferRowIsAlreadyFocussed: (editorId, bufferRowNumber) =>
        focusMarkers = @focusModeMarkersCache[editorId] or []
        for marker in focusMarkers
            range = marker.getBufferRange()
            rowNumber = range.getRows()

            if rowNumber[0] is bufferRowNumber
                return true

        return false


    getBufferRangeMarker: (textEditor, range) ->
        return textEditor.markBufferRange(range)


    addFocusLineMarker: (textEditor, bufferRow) =>
        range = [[bufferRow, 0], [bufferRow, 0]]
        marker = @getBufferRangeMarker(textEditor, range)
        textEditor.decorateMarker(marker, type: 'line', class: @focusLineCssClass)
        @cacheFocusModeMarker(textEditor.id, marker)


    cacheFocusModeMarker: (editorId, marker) =>
        if @focusModeMarkersCache[editorId]
            @focusModeMarkersCache[editorId].push(marker)
        else
            @focusModeMarkersCache[editorId] = [marker]


    getBodyTagElement: ->
        return document.getElementsByTagName("body")[0]


    toggleFocusMode: =>
        @focusModeActivated = !@focusModeActivated
        bodyElem = @getBodyTagElement()

        if @focusModeSingleLine
            @focusModeSingleLine = false
            @removeCssClass(bodyElem, @focusModeBodyCssClass)

        if @focusModeActivated
            @addCssClass(bodyElem, @focusModeBodyCssClass)
            @cursorEventSubscribers = @registerCursorEventHandlers()
            @focusAllCursorLines()
        else
            @focusModeOff(bodyElem)


    focusModeOff: (bodyElem) =>
        @focusModeActivated = false
        @removeCssClass(bodyElem, @focusModeBodyCssClass)
        @removeFocusLineClass()
        @focusModeMarkersCache = {}
        @cursorEventSubscribers.dispose()


    toggleFocusModeSingleLine: =>
        bodyElem = @getBodyTagElement()

        @focusModeOff(bodyElem) if @focusModeActivated

        @focusModeSingleLine = !@focusModeSingleLine

        if @focusModeSingleLine
            @addCssClass(bodyElem, @focusModeBodyCssClass)
        else
            @removeCssClass(bodyElem, @focusModeBodyCssClass)


    focusAllCursorLines: =>
        textEditor = @getActiveTextEditor()
        for cursor in textEditor.getCursors()
            @focusLine(cursor)


    getAtomWorkspaceTextEditors: ->
        return atom.workspace.getTextEditors()


    removeFocusLineClass: =>
        for editor in @getAtomWorkspaceTextEditors()
             editorLineDecorations = editor.getLineDecorations()

             for decoration in editorLineDecorations
                 decorationProperties = decoration.getProperties()

                 if decorationProperties.class and decorationProperties.class is @focusLineCssClass
                     marker = decoration.getMarker()
                     marker.destroy()


    addCssClass: (elem, cssClass) ->
        classNameValue = elem.className
        elem.className = classNameValue + " " + cssClass


    removeCssClass: (elem, cssClass) ->
        classNameValue = elem.className
        elem.className = classNameValue.replace(" " + cssClass, "")


    registerCursorEventHandlers: =>
        self = @
        subscriptions = new CompositeDisposable

        atom.workspace.observeTextEditors (editor) ->
            subscriptions.add editor.onDidAddCursor(self.didAddCursor)
            subscriptions.add editor.onDidChangeCursorPosition(self.didChangeCursorPosition)

        return subscriptions


    subscribersDispose: =>
        @cursorEventSubscribers.dispose() if @cursorEventSubscribers


module.exports = FocusModeManager
