{CompositeDisposable} = require 'atom'
FocusModeBase = require './focus-mode-base'

class FocusContextMode extends FocusModeBase

    constructor: () ->
        super('FocusContextMode')
        @isActivated = false
        @focusContextMarkerCache = {}
        @editorFileTypeCache = {}
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


    isMethodStartRow: (rowText, editor) =>
        fileType = @getFileTypeForEditor(editor)
        if(fileType is "coffee")
            return /:\s*\(.*\)\s*(=>|->)/.test(rowText)
        else if(fileType is "py")
            return /\s*def\s*.*\s*\(.*\)\s*:/.test(rowText)
        else
            console.log("isMethodStartRow FILE TYPE NOT MATCHED fileType = ", fileType)


    getContextModeBufferStartRow: (cursorBufferRow, editor) =>
        matchedBufferRowNumber = 0 # default to first row in file
        rowIndex = cursorBufferRow

        while rowIndex >= 0
            rowText = editor.lineTextForBufferRow(rowIndex)
            console.log("rowIndex = ", rowIndex, " row text = ", rowText)
            if(@isMethodStartRow(rowText, editor))
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
            if(@isMethodStartRow(rowText, editor))
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


    getFileTypeForEditor: (editor) =>
        fileType = @editorFileTypeCache[editor.id]
        console.log("fileType for editor ", editor.id, " from cache = ", fileType)
        if not fileType
            splitFileName = editor.getTitle().split(".")
            fileType = if splitFileName.length > 1 then splitFileName[1] else ""
            @editorFileTypeCache[editor.id] = fileType
            console.log("fileType for editor ", editor.id, " not in cache, fileType = ", fileType)

        return fileType


    contextModeOnCursorMove: (cursor) =>
        editor = cursor.editor
        marker = @getContextModeMarkerForEditor(editor)
        fileType = @getFileTypeForEditor(editor)
        console.log("contextModeOnCursorMove fileType = ", fileType)
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
