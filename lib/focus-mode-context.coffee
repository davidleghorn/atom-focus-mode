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


    isCoffeeScriptMethodStart: (rowText) =>
        regex = /:\s*\(.*\)\s*(=>|->)/
        console.log("isCoffeeScriptMethodStart rowText = ", rowText, "\nIS MATCH = ", regex.test(rowText))
        return regex.test(rowText)


    getContextModeBufferStartRow: (cursorBufferRow, editor) =>
        matchedBufferRowNumber = 0 # default to first row in file
        rowIndex = cursorBufferRow
        matched = false

        while rowIndex >= 0 and !matched
            rowText = editor.lineTextForBufferRow(rowIndex)
            console.log("rowIndex = ", rowIndex, " row text = ", rowText)
            if(@isCoffeeScriptMethodStart(rowText))
                matched = true
                matchedBufferRowNumber = rowIndex
                console.log("was matched row = ", matchedBufferRowNumber)
                break
            else
                rowIndex = rowIndex - 1

        return matchedBufferRowNumber


    getContextModeBufferEndRow: (cursorBufferRow, bufferLineCount) =>
        # We need +1 as when atom decorates a marker as type line, it doesn't
        # include a line decoration for the endRow marker in a buffer range
        endRow = cursorBufferRow

        if endRow > (bufferLineCount - 1)
            endRow = bufferLineCount - 1

        return endRow


    getContextModeBufferRange: (bufferPosition, editor) =>
        cursorBufferRow = bufferPosition.row
        console.log("current buffer row = ", cursorBufferRow)
        startRow = @getContextModeBufferStartRow(cursorBufferRow, editor)
        console.log("getContextModeBufferRange startRow = ", startRow)
        endRow = 150 #@getContextModeBufferEndRow(cursorBufferRow, bufferLineCount)
        # console.log("buffer position = ", bufferPosition)
        # descriptor = editor.scopeDescriptorForBufferPosition(bufferPosition)
        # console.log("descriptor = ", descriptor)
        # return [[startRow, 0], [endRow, 0]]
        # # scope = ['source.js', 'meta.function.js', 'entity.name.function.js']
        # scope = 'entity.name.function.js'
        # range = editor.bufferRangeForScopeAtCursor("meta.method-call.js")
        # console.log("range = ", range)
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
        # cursorRow = cursor.getBufferRow()
        marker = @getContextModeMarkerForEditor(editor)
        bufferPosition = editor.getCursorBufferPosition()
        range = @getContextModeBufferRange(bufferPosition, editor)
        console.log("contextModeOnCursorMove range = ", range)
        # startRow = @getContextModeBufferStartRow(cursorRow)
        # endRow = 150 #@getContextModeBufferEndRow(cursorRow, editor.getLineCount())
        startRow = range[0][0]
        endRow = range[1][0]
        console.log("startRow = ", startRow, " endRow = ", endRow)

        marker.setTailBufferPosition([startRow, 0])
        marker.setHeadBufferPosition([endRow, 0])


    dispose: =>
        @configSubscriptions.dispose() if @configSubscriptions


module.exports = FocusContextMode
