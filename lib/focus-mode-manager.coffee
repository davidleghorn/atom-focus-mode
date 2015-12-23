{CompositeDisposable} = require 'atom'

class FocusModeManager

    focusModeActivated = false
    focusModeSingleLine = false
    focusModeShadowActivated = false


    constructor: ->
        @cursorEventSubscribers = null
        @focusModeMarkersCache = {}
        @focusShadowMarkerCache = {}
        @focusModeBodyCssClass = "focus-mode"
        @focusLineCssClass = "focus-line"
        @focusModeShadowBodyClassName = "focus-mode-shadow"
        # TODO: set number of rows from config
        @shadowModeNumberOfRowsBeforeCursor = 3
        @shadowModeNumberOfRowsAfterCursor = 3


    didAddCursor: (cursor) =>
        if @focusModeActivated
            @focusLine(cursor)

        if @focusModeShadowActivated
            @focusModeShadowOnCursorMove(cursor)


    didChangeCursorPosition: (obj) =>
        if @focusModeActivated
            @focusLine(obj.cursor)

        if @focusModeShadowActivated
            @focusModeShadowOnCursorMove(obj.cursor)


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
        bodyElem = @getBodyTagElement()

        @focusModeSingleLineOff(bodyElem) if @focusModeSingleLine
        @focusModeShadowOff(bodyElem) if @focusModeShadowActivated

        if @focusModeActivated
            @focusModeOff(bodyElem)
        else
            @focusModeOn(bodyElem)


    focusModeOn: (bodyElem) =>
        @focusModeActivated = true
        @addCssClass(bodyElem, @focusModeBodyCssClass)
        @cursorEventSubscribers = @registerCursorEventHandlers()
        @focusTextSelections()


    focusModeOff: (bodyElem) =>
        @focusModeActivated = false
        @removeCssClass(bodyElem, @focusModeBodyCssClass)
        @removeFocusLineClass()
        @focusModeMarkersCache = {}
        @cursorEventSubscribers.dispose()


    focusTextSelections: =>
        for textEditor in @getAtomWorkspaceTextEditors()
            if textEditor
                selectedRanges = textEditor.getSelectedBufferRanges()
                if selectedRanges and selectedRanges.length > 0
                    for range in selectedRanges
                        marker = @getBufferRangeMarker(textEditor, range)
                        textEditor.decorateMarker(marker, type: 'line', class: @focusLineCssClass)
                        @cacheFocusModeMarker(textEditor.id, marker)


    toggleFocusModeSingleLine: =>
        bodyElem = @getBodyTagElement()

        @focusModeOff(bodyElem) if @focusModeActivated
        @focusModeShadowOff(bodyElem) if @focusModeShadowActivated

        if @focusModeSingleLine
            @focusModeSingleLineOff(bodyElem)
        else
            @focusModeSingleLineOn(bodyElem)


    focusModeSingleLineOn: (bodyElem) =>
        @focusModeSingleLine = true
        @addCssClass(bodyElem, @focusModeBodyCssClass)


    focusModeSingleLineOff: (bodyElem) =>
        @focusModeSingleLine = false
        @removeCssClass(bodyElem, @focusModeBodyCssClass)


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


    toggleFocusShadowMode: =>
        bodyTag = @getBodyTagElement()

        @focusModeOff(bodyTag) if @focusModeActivated
        @focusModeSingleLineOff(bodyTag) if @focusModeSingleLine

        if @focusModeShadowActivated
            @focusModeShadowOff(bodyTag)
        else
            @focusModeShadowOn(bodyTag)


    getFocusShadowBufferStartRow: (cursorBufferRow, numOfRowsToShadow) =>
        startRow = cursorBufferRow - numOfRowsToShadow

        if startRow < 0
            startRow = 0

        return startRow


    getFocusShadowBufferEndRow: (cursorBufferRow, numOfRowsToShadow, bufferLineCount) =>
        endRow = cursorBufferRow + numOfRowsToShadow

        if endRow > (bufferLineCount - 1)
            endRow = bufferLineCount - 1

        return endRow


    getFocusModeShadowBufferRange: (cursorBufferRow, bufferLineCount) =>
        startRow = @getFocusShadowBufferStartRow(
            cursorBufferRow, @shadowModeNumberOfRowsBeforeCursor
        )
        endRow = @getFocusShadowBufferEndRow(
            cursorBufferRow, @shadowModeNumberOfRowsAfterCursor, bufferLineCount
        )

        return [[startRow, 0], [endRow, 0]]


    createShadowModeMarker: (textEditor) =>
        cursorBufferPos = textEditor.getCursorBufferPosition()
        shadowBufferRange = @getFocusModeShadowBufferRange(
            cursorBufferPos.row, textEditor.getLineCount()
        )
        marker = @getBufferRangeMarker(textEditor, shadowBufferRange)
        textEditor.decorateMarker(marker, type: 'line', class: @focusLineCssClass)

        return marker


    focusModeShadowOn: (bodyTag) =>
        @focusModeShadowActivated = true
        textEditor = @getActiveTextEditor()
        cursor = textEditor.getLastCursor()
        @cursorEventSubscribers = @registerCursorEventHandlers()
        @focusModeShadowOnCursorMove(cursor)
        @addCssClass(bodyTag, @focusModeShadowBodyClassName)


    focusModeShadowOff: (bodyTag) =>
        @focusModeShadowActivated = false
        @removeCssClass(bodyTag, @focusModeShadowBodyClassName)
        @removeFocusModeShadowMarkers()
        @cursorEventSubscribers.dispose()
        @focusShadowMarkerCache = {}


    removeFocusModeShadowMarkers: =>
        for editor in @getAtomWorkspaceTextEditors()
            marker = @focusShadowMarkerCache[editor.id]
            marker.destroy() if marker


    getFocusShadowMarkerForEditor: (editor) =>
        marker = @focusShadowMarkerCache[editor.id]

        if not marker
            marker = @createShadowModeMarker(editor)
            @focusShadowMarkerCache[editor.id] = marker

        return marker


    focusModeShadowOnCursorMove: (cursor) =>
        editor = cursor.editor
        cursorRow = cursor.getBufferRow()
        marker = @getFocusShadowMarkerForEditor(cursor.editor)
        startRow = @getFocusShadowBufferStartRow(
            cursorRow, @shadowModeNumberOfRowsBeforeCursor
        )
        endRow = @getFocusShadowBufferEndRow(
            cursorRow, @shadowModeNumberOfRowsAfterCursor, editor.getLineCount()
        )

        marker.setTailBufferPosition([startRow, 0])
        marker.setHeadBufferPosition([endRow, 0])


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
