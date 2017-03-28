{CompositeDisposable} = require 'atom'
FocusModeBase = require './focus-mode-base'

class FocusContextMode extends FocusModeBase

    constructor: () ->
        super('FocusContextMode')
        @isActivated = false
        @focusContextMarkerCache = {}
        @focusContextBodyClassName = "focus-mode-context"
        @configSubscriptions = null #@registerConfigSubscriptions()


    on: =>
        @isActivated = true
        textEditor = @getActiveTextEditor()
        cursor = textEditor.getLastCursor()
        @contextModeOnCursorMove(cursor)
        @addCssClass(@getBodyTagElement(), @focusContextBodyClassName)


    off: =>
        @isActivated = false
        @removeContextModeMarkers()
        @focusContextMarkerCache = {}
        @removeCssClass(@getBodyTagElement(), @focusContextBodyClassName)


    # TODO: more generic isMethodStart(language) which then applies the appropraite
    # language regex ...e.g. json block where key is language and value will be regex
    # Need to identify file/language type when mode activated or new file focussed
    # could store in a cache - "editorId": "language" as per @focusContextMarkerCache approach
    isMethodStartRow: (rowText) =>
        regex = /:\s*\(.*\)\s*(=>|->)/
        console.log("isMethodStartRow rowText = ", rowText, "\nIS MATCH = ", regex.test(rowText))
        return regex.test(rowText)

    # python regex will be almost same, but no arrows at end and starts with "def "
    # e.g. def qsort(L):


    getContextModeBufferStartRow: (cursorBufferRow, editor) =>
        matchedBufferRowNumber = 0 # default to first row in file
        rowIndex = cursorBufferRow

        while rowIndex >= 0
            rowText = editor.lineTextForBufferRow(rowIndex)
            console.log("rowIndex = ", rowIndex, " row text = ", rowText)
            if(@isMethodStartRow(rowText))
                matchedBufferRowNumber = rowIndex
                console.log(">>>>>>>>was matched row = ", matchedBufferRowNumber)
                break
            else
                rowIndex = rowIndex - 1

        return matchedBufferRowNumber


    getContextModeBufferEndRow: (cursorBufferRow, editor) =>
        bufferLineCount = editor.getLineCount()
        matchedBufferRowNumber = bufferLineCount # default to last row in file
        rowIndex = cursorBufferRow

        while rowIndex <= bufferLineCount
            rowText = editor.lineTextForBufferRow(rowIndex)
            console.log("getContextModeBufferEndRow \nrowIndex = ", rowIndex, " row text = ", rowText)
            if(@isMethodStartRow(rowText))
                matchedBufferRowNumber = rowIndex
                console.log("getContextModeBufferEndRow matched row = ", matchedBufferRowNumber)
                break
            else
                rowIndex = rowIndex + 1

        return matchedBufferRowNumber - 1


    getContextModeBufferRange: (bufferPosition, editor) =>
        cursorBufferRow = bufferPosition.row
        console.log("current buffer row = ", cursorBufferRow)
        startRow = @getContextModeBufferStartRow(cursorBufferRow, editor)
        console.log("getContextModeBufferRange startRow = ", startRow)
        endRow = @getContextModeBufferEndRow(cursorBufferRow, editor)
        console.log("getContextModeBufferRange endRow = ", endRow)

        return [[startRow, 0], [endRow, 0]]


    createContextModeMarker: (textEditor) =>
        bufferPosition = textEditor.getCursorBufferPosition()
        contextBufferRange = @getContextModeBufferRange(bufferPosition, textEditor)
        marker = textEditor.markBufferRange(contextBufferRange)
        textEditor.decorateMarker(marker, type: 'line', class: @focusLineCssClass)

        return marker


    removeContextModeMarkers: =>
        for editor in @getAtomWorkspaceTextEditors()
            marker = @focusContextMarkerCache[editor.id]
            marker.destroy() if marker


    getContextModeMarkerForEditor: (editor) =>
        marker = @focusContextMarkerCache[editor.id]

        if not marker
            marker = @createContextModeMarker(editor)
            @focusContextMarkerCache[editor.id] = marker

        return marker


    contextModeOnCursorMove: (cursor) =>
        editor = cursor.editor
        marker = @getContextModeMarkerForEditor(editor)
        bufferPosition = editor.getCursorBufferPosition()
        range = @getContextModeBufferRange(bufferPosition, editor)
        console.log("contextModeOnCursorMove range = ", range)
        startRow = range[0][0]
        endRow = range[1][0]
        console.log("startRow = ", startRow, " endRow = ", endRow)

        marker.setTailBufferPosition([startRow, 0])
        marker.setHeadBufferPosition([endRow, 0])


    dispose: =>
        @configSubscriptions.dispose() if @configSubscriptions


module.exports = FocusContextMode
