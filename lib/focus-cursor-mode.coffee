{CompositeDisposable} = require 'atom'
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
                console.log("row is already focussed - ", bufferRowNumber)
                return true

        return false


    addFocusLineMarker: (editor, bufferRow, cursor) =>
        # range = [[bufferRow, 0], [bufferRow, 0]]
        # NOTE: Seems to work, except for the first soft wrapped line that is
        # focussed when focus cursor mode is activated?
        range = cursor.getCurrentLineBufferRange({includeNewLine: true}) # NEW
        console.log("line range = ", range)
        marker = editor.markBufferRange(range)
        editor.decorateMarker(marker, type: 'line', class: @focusLineCssClass)
        @cacheFocusModeMarker(editor.id, marker)


    cacheFocusModeMarker: (editorId, marker) =>
        if @focusModeMarkersCache[editorId]
            @focusModeMarkersCache[editorId].push(marker)
        else
            @focusModeMarkersCache[editorId] = [marker]

    # applies focus mode decoration to any lines user has selected/highlighted with mouse
    applyFocusModeToSelectedBufferRanges: =>
        for textEditor in @getAtomWorkspaceTextEditors()
            if textEditor
                selectedRanges = textEditor.getSelectedBufferRanges()
                if selectedRanges and selectedRanges.length > 0
                    console.log("selected ranges = ", selectedRanges)
                    for range in selectedRanges
                        marker = textEditor.markBufferRange(range)
                        textEditor.decorateMarker(marker, type: 'line', class: @focusLineCssClass)
                        @cacheFocusModeMarker(textEditor.id, marker)


module.exports = FocusCursorMode
