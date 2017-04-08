{CompositeDisposable} = require 'atom'
FocusModeBase = require './focus-mode-base'

class FocusScopeMode extends FocusModeBase

    constructor: () ->
        super('FocusScopeMode')
        @isActivated = false
        @focusScopeMarkerCache = {}
        @editorFileTypeCache = {}
        @focusScopeBodyClassName = "focus-scope-mode"

    on: =>
        @isActivated = true
        textEditor = @getActiveTextEditor()
        cursor = textEditor.getLastCursor()
        @scopeModeOnCursorMove(cursor)
        @addCssClass(@getBodyTagElement(), @focusScopeBodyClassName)

    off: =>
        @isActivated = false
        @removeScopeModeMarkers()
        @focusScopeMarkerCache = {}
        @removeCssClass(@getBodyTagElement(), @focusScopeBodyClassName)

    isCoffeeScriptMethodSignature: (lineText) ->
        return /:\s*\(?.*\)?\s*(=>|->)/.test(lineText)

    isPythonMethodSignature: (lineText) ->
        return /\s*def\s*.*\s*\(?.*\)?\s*:/.test(lineText)

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


    isMethodStartLine: (rowText, editor) =>
        fileType = @getFileTypeForEditor(editor)
        switch fileType
            when "coffee" then return @isCoffeeScriptMethodSignature(rowText)
            when "py" then return @isPythonMethodSignature(rowText)
            when "js"
                if (@isIfStatement(rowText) or @isForStatement(rowText) or @isWhileStatement(rowText) or @isSwitchStatement(rowText))
                    return false

                return @isJavascriptFunctionSignature(rowText) or @isEs6MethodSignature(rowText)
            else
                return false


    adjustBufferEndRow: (rowIndex, editor) =>
        index = rowIndex
        while index > 0
            index = index - 1
            lineText = editor.lineTextForBufferRow(index)
            if(!@isDecoratorLine(lineText) and !@isCommentLine(lineText))
                break;

        return index


    getScopeModeBufferStartRow: (cursorBufferRow, editor) =>
        fileType = @getFileTypeForEditor(editor)
        matchedBufferRowNumber = 0 # default to first row in file
        closingCurlyRowIndents = []
        rowIndex = cursorBufferRow
        cursorRowText = editor.lineTextForBufferRow(rowIndex)

        # if the cursor row is a method or class start line, exit as this is the scope start row
        if(@isMethodStartLine(cursorRowText, editor) or @isClassStartLine(cursorRowText))
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

            if(@isMethodStartLine(rowText, editor))
                if(fileType is "js" and closingCurlyRowIndents.indexOf(rowIndent) > -1)
                    # we matched a method/function start line but at an incorrect
                    # (too deep) scope - continue moving up file lines
                    continue
                else
                    matchedBufferRowNumber = rowIndex
                    break

            else if(fileType is "js" and @lineContainsClosingCurly(rowText))
                closingCurlyRowIndents.push(rowIndent)

        return matchedBufferRowNumber


    getScopeModeBufferEndRow: (scopeStartRow, editor) =>
        bufferRowCount = editor.getLineCount() - 1
        fileType = @getFileTypeForEditor(editor)
        bufferScopeEndRow = bufferRowCount # default to last row in buffer
        rowIndex = scopeStartRow
        scopeStartRowIndent = editor.indentationForBufferRow(scopeStartRow)

        while rowIndex < bufferRowCount
            rowIndex = rowIndex + 1
            rowText = editor.lineTextForBufferRow(rowIndex)
            rowIndent = editor.indentationForBufferRow(rowIndex)

            if(fileType is "coffee" or fileType is "py")
                if((@isMethodStartLine(rowText, editor) or @isClassStartLine(rowText)) and rowIndent <= scopeStartRowIndent)
                    bufferScopeEndRow = rowIndex
                    previousLineText = editor.lineTextForBufferRow(rowIndex - 1)
                    if(@isDecoratorLine(previousLineText) or @isCommentLine(previousLineText))
                        bufferScopeEndRow = @adjustBufferEndRow(rowIndex, editor)
                    break

            else if(fileType is "js")
                if(editor.indentationForBufferRow(rowIndex) is scopeStartRowIndent and @isClosingCurlyLine(rowText))
                    bufferScopeEndRow = rowIndex + 1 # +1 as buffer range end row isn't included in range and we also want it included/decorated
                    break

        return bufferScopeEndRow


    getScopeModeBufferRange: (bufferPosition, editor) =>
        fileType = @getFileTypeForEditor(editor)
        startRow = 0
        endRow = editor.getLineCount() - 1
        if (['md', 'txt'].indexOf(fileType) > -1)
            paragraphRange = editor.getCurrentParagraphBufferRange()
            if paragraphRange
                startRow = paragraphRange.start.row
                endRow = paragraphRange.end.row + 1
        else
            cursorBufferRow = bufferPosition.row
            startRow = @getScopeModeBufferStartRow(cursorBufferRow, editor)
            endRow = @getScopeModeBufferEndRow(startRow, editor)

        return [[startRow, 0], [endRow, 0]]


    createScopeModeMarker: (textEditor) =>
        bufferPosition = textEditor.getCursorBufferPosition()
        scopeBufferRange = @getScopeModeBufferRange(bufferPosition, textEditor)
        marker = textEditor.markBufferRange(scopeBufferRange)
        textEditor.decorateMarker(marker, type: 'line', class: @focusLineCssClass)

        return marker


    removeScopeModeMarkers: =>
        for editor in @getAtomWorkspaceTextEditors()
            marker = @focusScopeMarkerCache[editor.id]
            marker.destroy() if marker


    getScopeModeMarkerForEditor: (editor) =>
        marker = @focusScopeMarkerCache[editor.id]
        if not marker
            marker = @createScopeModeMarker(editor)
            @focusScopeMarkerCache[editor.id] = marker

        return marker


    getFileTypeForEditor: (editor) =>
        fileType = @editorFileTypeCache[editor.id]
        if not fileType
            splitFileName = editor.getTitle().split(".")
            fileType = if splitFileName.length > 1 then splitFileName[1] else ""
            @editorFileTypeCache[editor.id] = fileType

        return fileType


    scopeModeOnCursorMove: (cursor) =>
        editor = cursor.editor
        marker = @getScopeModeMarkerForEditor(editor)
        bufferPosition = editor.getCursorBufferPosition()
        range = @getScopeModeBufferRange(bufferPosition, editor)
        startRow = range[0][0]
        endRow = range[1][0]
        marker.setTailBufferPosition([startRow, 0])
        marker.setHeadBufferPosition([endRow, 0])


module.exports = FocusScopeMode
