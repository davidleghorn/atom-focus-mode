{CompositeDisposable} = require 'atom'
FocusModeBase = require './focus-mode-base'

class FocusContextMode extends FocusModeBase

    constructor: () ->
        super('FocusContextMode')
        @isActivated = false
        @focusContextMarkerCache = {}
        @editorFileTypeCache = {}
        @focusContextBodyClassName = "focus-mode-context"

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


    isCoffeeScriptMethodSignature: (lineText) ->
        return /:\s*\(.*\)\s*(=>|->)/.test(lineText)


    isPythonMethodSignature: (lineText) ->
        return /\s*def\s*.*\s*\(.*\)\s*:/.test(lineText)


    isJavascriptFunctionSignature: (rowText) ->
        return /^.*\s*\(?function\s*([a-zA-Z0-9_-]*)?\s*\({1}.*\){1}\s*{\s*$/.test(rowText)

    isIfStatement: (lineText) ->
        isIf = /^\s*if*\s*\({1}.*/.test(lineText)
        console.log("lineText = ", lineText, " isIf = ", isIf)
        return isIf

    isSwitchStatement: (lineText) ->
        isSwitch = /^\s*switch*\s*\({1}.*/.test(lineText)
        console.log("lineText = ", lineText, " isSwitch = ", isSwitch)
        return isSwitch

    isWhileStatement: (lineText) ->
        iswhile = /^\s*while*\s*\({1}.*/.test(lineText)
        console.log("lineText = ", lineText, " isWhile = ", iswhile)
        return iswhile

    isEs6MethodSignature: (lineText) =>
        es6MethodRegex = /^\s*[a-zA-Z0-9_-]*\s*\({1}.*\){1}\s*{\s*$/
        # as regex will also match if, while and switch statements, test first that line is neither if nor switch
        if (@isIfStatement(lineText) or @isSwitchStatement(lineText) or @isWhileStatement(lineText))
            return false

        return es6MethodRegex.test(lineText)


    lineIsClosingCurly: (lineText) ->
        console.log("NEW line text = ", lineText, " is a clsoing curly = ", /^\s*}\s*$/.test(lineText))
        return /^\s*}.*/.test(lineText)


    isMethodStartRow: (rowText, editor) =>
        switch @getFileTypeForEditor(editor)
            when "coffee" then return @isCoffeeScriptMethodSignature(rowText)
            when "py" then return @isPythonMethodSignature(rowText)
            when "js" then return @isJavascriptFunctionSignature(rowText) or @isEs6MethodSignature(rowText)
            else
                console.log("isMethodStartRow FILE TYPE NOT MATCHED fileType = ", fileType)
                return false


    # Get method/function start line/buffer row
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


    # Get method/function end line/buffer row
    getContextModeBufferEndRow: (methodStartRow, editor) =>
        bufferLineCount = editor.getLineCount()
        fileType = @getFileTypeForEditor(editor)
        matchedBufferRowNumber = bufferLineCount # default to last row in file
        rowIndex = methodStartRow
        startRowIndent = editor.indentationForBufferRow(methodStartRow)
        console.log("methodStartRow row indentation = ", startRowIndent)

        while rowIndex <= bufferLineCount
            rowIndex = rowIndex + 1
            rowText = editor.lineTextForBufferRow(rowIndex)

            if(fileType is "coffee" or fileType is "py")
                # finds end of method body by finding next method start or end of file, then moves back up 1 line
                if(@isMethodStartRow(rowText, editor) and editor.indentationForBufferRow(rowIndex) <= startRowIndent)
                    matchedBufferRowNumber = rowIndex # -1
                    break

            else if(fileType is "js")
                # finds a closing curly on same level of indentation as function/method start row
                if(editor.indentationForBufferRow(rowIndex) is startRowIndent and @lineIsClosingCurly(rowText))
                    matchedBufferRowNumber = rowIndex + 1 # +1 as buffer range end row isn't included in range and we also want it decorated
                    break

        console.log("getContextModeBufferEndRow fileType is ", fileType, " and matched row = ", matchedBufferRowNumber)

        return matchedBufferRowNumber


    getContextModeBufferRange: (bufferPosition, editor) =>
        cursorBufferRow = bufferPosition.row
        startRow = @getContextModeBufferStartRow(cursorBufferRow, editor)
        endRow = @getContextModeBufferEndRow(startRow, editor)
        console.log("getContextModeBufferRange cursorBufferRow = ", cursorBufferRow, " startRow = ", startRow, " and endRow = ", endRow)

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


    # dispose: =>
    #     @configSubscriptions.dispose() if @configSubscriptions

module.exports = FocusContextMode
