FocusModeBase = require './focus-mode-base'

class FocusCursorMode extends FocusModeBase

    constructor: ->
        super("FocusCursorMode")
        @isActivated = false
        @focusModeMarkersCache = {}

    on: =>
        @isActivated = true
        bodyTag = @getBodyTagElement()
        editor = @getActiveTextEditor()
        cursor = editor.getLastCursor()
        @addCssClass(bodyTag, @focusModeBodyCssClass)
        @focusLine(cursor) if cursor
        @applyFocusModeToSelectedBufferRanges()


    off: =>
        @isActivated = false
        bodyTag = @getBodyTagElement()
        @removeCssClass(bodyTag, @focusModeBodyCssClass)
        @removeFocusLineClass()
        @focusModeMarkersCache = {}


    focusLine: (cursor) =>
        bufferRow = cursor.getBufferRow()
        editor = @getActiveTextEditor()

        return if @bufferRowIsAlreadyFocussed(editor.id, bufferRow)

        @addFocusLineMarker(editor, bufferRow, cursor)


    bufferRowIsAlreadyFocussed: (editorId, bufferRowNumber) =>
        focusMarkers = @focusModeMarkersCache[editorId] or []
        for marker in focusMarkers
            range = marker.getBufferRange()
            rowNumber = range.getRows()

            if rowNumber[0] is bufferRowNumber
                return true

        return false


    addFocusLineMarker: (editor, bufferRow, cursor) =>
        range = cursor.getCurrentLineBufferRange({includeNewLine: true})
        marker = editor.markBufferRange(range)
        editor.decorateMarker(marker, type: 'line', class: @focusLineCssClass)
        @cacheFocusModeMarker(editor.id, marker)


    cacheFocusModeMarker: (editorId, marker) =>
        cache = focusModeMarkersCache[editorId] ?= []
        cache.push(marker)

    # applies focus mode decoration to any lines user has selected/highlighted with mouse
    applyFocusModeToSelectedBufferRanges: =>
        for textEditor in @getAtomWorkspaceTextEditors() when textEditor
            for range in textEditor.getSelectedBufferRanges() or []
                marker = textEditor.markBufferRange(range)
                textEditor.decorateMarker(marker, type: 'line', class: @focusLineCssClass)
                @cacheFocusModeMarker(textEditor.id, marker)


module.exports = FocusCursorMode
