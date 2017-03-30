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
        return /^\s*if*\s*\({1}.*/.test(lineText)

    isSwitchStatement: (lineText) ->
        return /^\s*switch*\s*\({1}.*/.test(lineText)

    isWhileStatement: (lineText) ->
        return /^\s*while*\s*\({1}.*/.test(lineText)

    isForStatement: (lineText) ->
        return /^\s*for*\s*\({1}.*/.test(lineText)

    isEs6MethodSignature: (lineText) =>
        return /^\s*[a-zA-Z0-9_-]*\s*\({1}.*\){1}\s*{\s*$/.test(lineText)

    isClosingCurlyLine: (lineText) ->
        return /^\s*}.*/.test(lineText)

    lineContainsClosingCurly: (lineText) ->
        return /^.*}.*/.test(lineText)

    lineContainsOpeningCurly: (lineText) ->
        return /^.*{.*/.test(lineText)

    isDecoratorLine: (lineText) ->
        return /^\s*@{1}[a-zA-Z0-9_-]*\s*/.test(lineText)

    isCommentLine: (lineText) ->
        return /^\s*(#|\/\/|\/\*).*$/.test(lineText)

    isClassStartLine: (lineText) ->
        return /^\s*class\s+.*$/.test(lineText)

    getAtomNotificationsInstance: ()->
        return atom.notifications


    isMethodStartRow: (rowText, editor) =>
        fileType = @getFileTypeForEditor(editor)
        switch fileType
            when "coffee" then return @isCoffeeScriptMethodSignature(rowText)
            when "py" then return @isPythonMethodSignature(rowText)
            when "js"
                if (@isIfStatement(rowText) or @isForStatement(rowText) or @isWhileStatement(rowText) or @isSwitchStatement(rowText))
                    return false

                return @isJavascriptFunctionSignature(rowText) or @isEs6MethodSignature(rowText)
            else
                @getAtomNotificationsInstance().addInfo("Sorry, " + fileType + " files are not supported by Context Focus mode.\n\nContext focus mode currently supports js, coffee and py file extensions.");
                return false


    adjustBufferEndRow: (rowIndex, editor) =>
        index = rowIndex
        while index > 0
            index = index - 1
            lineText = editor.lineTextForBufferRow(index)
            if(!@isDecoratorLine(lineText) and !@isCommentLine(lineText))
                break;

        return index


    getContextModeBufferStartRow: (cursorBufferRow, editor) =>
        fileType = @getFileTypeForEditor(editor)
        matchedBufferRowNumber = 0 # default to first row in file
        closingCurlyRowIndents = []
        rowIndex = cursorBufferRow
        cursorRowText = editor.lineTextForBufferRow(rowIndex)

        # if the cursor row is a method or class start line, exit as this is the context start row
        if(@isMethodStartRow(cursorRowText, editor) or @isClassStartLine(cursorRowText))
            return rowIndex

        # prevents traversal up file and matching of previous method scope
        # when cursor row is a python method decorator
        if(fileType is "py" and @isDecoratorLine(cursorRowText))
            return rowIndex

        # start traversing up file looking for the cursor line's
        # enclosing scope (method or class start line)
        while rowIndex > 0
            rowIndex = rowIndex - 1
            rowText = editor.lineTextForBufferRow(rowIndex)
            rowIndent = editor.indentationForBufferRow(rowIndex)

            if(@isClassStartLine(rowText))
                matchedBufferRowNumber = rowIndex
                break

            if(@isMethodStartRow(rowText, editor))
                if(fileType is "js" and closingCurlyRowIndents.indexOf(rowIndent) > -1)
                    # we matched a method/function start row but at an incorrect
                    # (too deep) scope - continue moving up file lines
                    continue
                else
                    matchedBufferRowNumber = rowIndex
                    break

            else if(fileType is "js" and @lineContainsClosingCurly(rowText))
                closingCurlyRowIndents.push(rowIndent)

        return matchedBufferRowNumber


    getContextModeBufferEndRow: (methodStartRow, editor) =>
        bufferRowCount = editor.getLineCount() - 1
        fileType = @getFileTypeForEditor(editor)
        bufferContextEndRow = bufferRowCount # default to last row in buffer
        rowIndex = methodStartRow
        methodStartRowIndent = editor.indentationForBufferRow(methodStartRow)

        while rowIndex < bufferRowCount
            rowIndex = rowIndex + 1
            rowText = editor.lineTextForBufferRow(rowIndex)
            rowIndent = editor.indentationForBufferRow(rowIndex)

            if(fileType is "coffee" or fileType is "py")
                # finds end of method body by finding next method start or end of file
                if((@isMethodStartRow(rowText, editor) or @isClassStartLine(rowText)) and rowIndent <= methodStartRowIndent)
                    bufferContextEndRow = rowIndex
                    previousLineText = editor.lineTextForBufferRow(rowIndex - 1)
                    if(@isDecoratorLine(previousLineText) or @isCommentLine(previousLineText))
                        bufferContextEndRow = @adjustBufferEndRow(rowIndex, editor)
                    break

            else if(fileType is "js")
                # finds a closing curly on same level of indentation as function/method start row
                if(editor.indentationForBufferRow(rowIndex) is methodStartRowIndent and @isClosingCurlyLine(rowText))
                    bufferContextEndRow = rowIndex + 1 # +1 as buffer range end row isn't included in range and we also want it included/decorated
                    break

        return bufferContextEndRow


    getContextModeBufferRange: (bufferPosition, editor) =>
        cursorBufferRow = bufferPosition.row
        startRow = @getContextModeBufferStartRow(cursorBufferRow, editor)
        endRow = @getContextModeBufferEndRow(startRow, editor)
        # console.log("getContextModeBufferRange cursorBufferRow = ", cursorBufferRow, " startRow = ", startRow, " and endRow = ", endRow)

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
        if not fileType
            splitFileName = editor.getTitle().split(".")
            fileType = if splitFileName.length > 1 then splitFileName[1] else ""
            @editorFileTypeCache[editor.id] = fileType

        return fileType


    contextModeOnCursorMove: (cursor) =>
        editor = cursor.editor
        marker = @getContextModeMarkerForEditor(editor)
        bufferPosition = editor.getCursorBufferPosition()
        range = @getContextModeBufferRange(bufferPosition, editor)
        startRow = range[0][0]
        endRow = range[1][0]
        marker.setTailBufferPosition([startRow, 0])
        marker.setHeadBufferPosition([endRow, 0])


module.exports = FocusContextMode
