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

    lineIsClosingCurly: (lineText) ->
        return /^\s*}.*/.test(lineText)

    lineContainsClosingCurly: (lineText) ->
        console.log("lineContainsClosingCurly = ", /^.*}.*/.test(lineText)," lineText = ", lineText)
        return /^.*}.*/.test(lineText)

    lineContainsOpeningCurly: (lineText) ->
        console.log("lineContainsOpeningCurly = ", /^.*}.*/.test(lineText)," lineText = ", lineText)
        return /^.*{.*/.test(lineText)

    lineIsDecorator: (lineText) ->
        console.log(">>>>> lineText = ", lineText, " isDecorator = ", /^\s*@{1}[a-zA-Z0-9_-]*\s*/.test(lineText))
        return /^\s*@{1}[a-zA-Z0-9_-]*\s*/.test(lineText)

    lineIsComment: (lineText) ->
        console.log(">>>>> lineText = ", lineText, " is comment = ", /^\s*(#|\/\/|\/\*).*$/.test(lineText))
        return /^\s*(#|\/\/|\/\*).*$/.test(lineText)

    isClassStartLine: (lineText) ->
        console.log(">>>>> lineText = ", lineText, " isClassStartLine = ", /^\s*class\s+.*$/.test(lineText))
        return /^\s*class\s+.*$/.test(lineText)

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
            if(!@lineIsDecorator(lineText) and !@lineIsComment(lineText)) # and !@isClassStartLine(lineText))
                break;

        console.log("first non decorator or comment row is index = ", index)
        return index

    getAtomNotificationsInstance: ()->
        return atom.notifications

    moveBackToFirstEmptyLine: (rowIndex, editor)->
        index = rowIndex
        while index > 0
            index = index - 1
            if(/^\s*$/.test(editor.lineTextForBufferRow(index)))
                break;

        # console.log("moveBackToFirstEmptyLine index = ", index, " and starting rowIndex was ", rowIndex)
        return index

    findClosestOpeningCurly: (startRowIndex, editor)->
        index = startRowIndex
        while index > 0
            index = index - 1
            if(@lineContainsOpeningCurly(editor.lineTextForBufferRow(index)))
                break;

        # console.log("moveBackToFirstEmptyLine index = ", index, " and starting rowIndex was ", rowIndex)
        return index

    getContextModeBufferStartRow: (cursorBufferRow, editor) =>
        fileType = @getFileTypeForEditor(editor)
        matchedBufferRowNumber = 0 # default to first row in file
        closingCurlyRowIndents = []
        rowIndex = cursorBufferRow
        bufferRowText = editor.lineTextForBufferRow(rowIndex)
        # if the cursor row is the method start row or a class start line return row number and exit
        if(@isMethodStartRow(bufferRowText, editor) or @isClassStartLine(bufferRowText))
            console.log("buffer row ", rowIndex, " is the method start line - exit")
            return rowIndex

        while rowIndex > 0
            rowIndex = rowIndex - 1
            rowText = editor.lineTextForBufferRow(rowIndex)
            rowIndent = editor.indentationForBufferRow(rowIndex)
            if(@isMethodStartRow(rowText, editor))
                if(fileType is "js" and closingCurlyRowIndents.indexOf(rowIndent) > -1)
                    # we matched a method/function start row but at incorrect (too deep) scope - continue up file lines
                    continue
                else
                    matchedBufferRowNumber = rowIndex
                    break
            else if(fileType is "js" and @lineContainsClosingCurly(rowText))
                closingCurlyRowIndents.push(rowIndent)

        console.log("buffer start row = ", matchedBufferRowNumber)
        return matchedBufferRowNumber


    getContextModeBufferEndRow: (methodStartRow, editor) =>
        fileLineCount = editor.getLineCount()  # TODO Should this be buffer line count?
        console.log("XXXXXXXX fileLineCount = ", fileLineCount)
        fileType = @getFileTypeForEditor(editor)
        matchedBufferRowNumber = fileLineCount - 1 # default to last row in buffer
        rowIndex = methodStartRow
        methodStartRowIndent = editor.indentationForBufferRow(methodStartRow)

        while rowIndex < (fileLineCount - 1)
            rowIndex = rowIndex + 1
            rowText = editor.lineTextForBufferRow(rowIndex)
            rowIndent = editor.indentationForBufferRow(rowIndex)

            if(fileType is "coffee" or fileType is "py")
                # finds end of method body by finding next method start or end of file
                console.log("Coffee/py rowIndex = ", rowIndex, " rowText = ", rowText)
                if((@isMethodStartRow(rowText, editor) or @isClassStartLine(rowText)) and rowIndent <= methodStartRowIndent)
                    matchedBufferRowNumber = rowIndex
                    previousLineText = editor.lineTextForBufferRow(rowIndex - 1)
                    if(@lineIsDecorator(previousLineText) or @lineIsComment(previousLineText))
                        matchedBufferRowNumber = @adjustBufferEndRow(rowIndex, editor)
                        console.log("MATCHED DECORATOR or comment or class line >>>> adjustBufferEndRow = ", matchedBufferRowNumber)
                    break

            else if(fileType is "js")
                # finds a closing curly on same level of indentation as function/method start row
                if(editor.indentationForBufferRow(rowIndex) is methodStartRowIndent and @lineIsClosingCurly(rowText))
                    matchedBufferRowNumber = rowIndex + 1 # +1 as buffer range end row isn't included in range and we also want it decorated
                    break

        console.log("getContextModeBufferEndRow fileType is ", fileType, " and matched end row = ", matchedBufferRowNumber)
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
