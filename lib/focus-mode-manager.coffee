{CompositeDisposable} = require 'atom'

class FocusModeManager

    focusModeActivated = false
    focusModeSingleLine = false
    focusModeShadowActivated = false


    constructor: ->
        @cursorEventSubscribers = null
        @focusModeMarkersCache = {}
        @focusShadowMarkerCache = {}
        #TODO: these could maybe go outside constructor as will apply to all instances?
        @focusModeBodyCssClass = "focus-mode"
        @focusLineCssClass = "focus-line"
        @focusModeShadowBodyClassName = "focus-mode-shadow"
        # TODO: set from config
        @shadowModeNumberOfRowsBeforeCursor = 3
        @shadowModeNumberOfRowsAfterCursor = 3


    didAddCursor: (cursor) =>
        if @focusModeActivated
            @focusLine(cursor)

        if @focusModeShadowActivated
            console.log("didAddCursor called")
            @focusModeShadowOnCursorMove(cursor)


    didChangeCursorPosition: (obj) =>
        console.log("didChangeCursorPosition @focusModeActivated = ", @focusModeActivated,
        "focusModeShadowActivated = ", @focusModeShadowActivated)
        if @focusModeActivated
            console.log("focus mode focusLine called")
            @focusLine(obj.cursor)

        if @focusModeShadowActivated
            console.log("didChangeCursorPosition focus shadow mode focusModeShadowOnCursorMove called")
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
        @focusModeActivated = !@focusModeActivated
        bodyElem = @getBodyTagElement()

        if @focusModeSingleLine
            @focusModeSingleLine = false
            @removeCssClass(bodyElem, @focusModeBodyCssClass)

        if @focusModeShadowActivated
            @focusModeShadowActivated = false
            @focusModeShadowOff(bodyElem)

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
        @focusModeShadowOff(bodyElem) if @focusModeShadowActivated

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


    # =========== FOCUS SHADOW MODE START =========

    toggleFocusShadowMode: =>
        bodyTag = @getBodyTagElement()

        @focusModeOff(bodyTag) if @focusModeActivated

        if @focusModeSingleLine
            @removeCssClass(bodyTag, @focusModeBodyCssClass)
            @focusModeSingleLine = false

        @focusModeShadowActivated = !@focusModeShadowActivated

        if @focusModeShadowActivated
            @focusModeShadowOn(bodyTag)
        else
            @focusModeShadowOff(bodyTag)


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

        console.log("getFocusModeShadowBufferRange cursor row = ", cursorBufferRow,
        "bufferLineCount = ", bufferLineCount, " startRow = ", startRow, " endRow = ", endRow)

        return [[startRow, 0], [endRow, 0]]


    createShadowModeMarker: (textEditor) =>
        cursorBufferPos = textEditor.getCursorBufferPosition()
        console.log("cursorBufferPos = ", cursorBufferPos)
        shadowBufferRange = @getFocusModeShadowBufferRange(
            cursorBufferPos.row, textEditor.getLineCount()
        )
        console.log("testEditor = ", textEditor, "  shadowBufferRange = ", shadowBufferRange)
        marker = @getBufferRangeMarker(textEditor, shadowBufferRange)
        console.log("marker  = ", marker)
        textEditor.decorateMarker(marker, type: 'line', class: @focusLineCssClass)

        return marker


    focusModeShadowOn: (bodyTag) =>
        # create focus mode shadow marker and cache
        console.log("focusModeShadowOn")
        textEditor = @getActiveTextEditor()
        cursor = textEditor.getLastCursor()
        @cursorEventSubscribers = @registerCursorEventHandlers()
        @focusModeShadowOnCursorMove(cursor)
        @addCssClass(bodyTag, @focusModeShadowBodyClassName)


    focusModeShadowOff: (bodyTag) =>
        @removeCssClass(bodyTag, @focusModeShadowBodyClassName)
        @removeFocusModeShadowMarkers()
        @cursorEventSubscribers.dispose()
        @focusShadowMarkerCache = {}


    removeFocusModeShadowMarkers: =>
        for editor in @getAtomWorkspaceTextEditors()
            marker = @focusShadowMarkerCache[editor.id]
            marker.destroy() if marker


    getEditorFocusShadowMarker: (editor) =>
        marker = @focusShadowMarkerCache[editor.id]

        if not marker
            marker = @createShadowModeMarker(editor) if not marker
            @focusShadowMarkerCache[editor.id] = marker

        return marker


    focusModeShadowOnCursorMove: (cursor) =>
        #TODO: exit of cursor new and old row is the same
        console.log("moveFocusModeShadow cursor = ", cursor)
        editor = cursor.editor
        cursorRow = cursor.getBufferRow()
        console.log("editor = ", editor, " cursorRow = ", cursorRow)
        marker = @getEditorFocusShadowMarker(cursor.editor)
        console.log("marker = ", marker)
        startRow = @getFocusShadowBufferStartRow(
            cursorRow, @shadowModeNumberOfRowsBeforeCursor
        )
        endRow = @getFocusShadowBufferEndRow(
            cursorRow, @shadowModeNumberOfRowsAfterCursor, editor.getLineCount()
        )

        marker.setTailBufferPosition([startRow, 0])
        marker.setHeadBufferPosition([endRow, 0])

        console.log("marker.bufferMarker.properties = ", marker.bufferMarker.properties)

# =========== FOCUS SHADOW MODE END =========


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
