{CompositeDisposable} = require 'atom'
FocusModeBase = require './focus-mode-base'

class FocusShadowMode extends FocusModeBase


    constructor: () ->
        super('FocusShadowMode')
        @isActivated = false
        @focusShadowMarkerCache = {}
        @focusModeShadowBodyClassName = "focus-mode-shadow"
        @shadowModeNumberOfRowsBeforeCursor = @getConfig(
            'atom-focus-mode.focusShadowModeNumberOfLinesToHighlightAboveCursor'
        ) or 2
        @shadowModeNumberOfRowsAfterCursor = @getConfig(
            'atom-focus-mode.focusShadowModeNumberOfLinesToHighlightBelowCursor'
        ) or 2
        @configSubscriptions = @registerConfigSubscriptions()


    registerConfigSubscriptions: =>
        configSubscriptions = new CompositeDisposable()
        configSubscriptions.add(atom.config.observe(
            'atom-focus-mode.focusShadowModeNumberOfLinesToHighlightAboveCursor',
            (numberOfLines) => @shadowModeNumberOfRowsBeforeCursor = numberOfLines if numberOfLines?
        ))
        configSubscriptions.add(atom.config.observe(
            'atom-focus-mode.focusShadowModeNumberOfLinesToHighlightBelowCursor',
            (numberOfLines) => @shadowModeNumberOfRowsAfterCursor = numberOfLines if numberOfLines?
        ))

        return configSubscriptions


    on: =>
        @isActivated = true
        textEditor = @getActiveTextEditor()
        cursor = textEditor.getLastCursor()
        @focusModeShadowOnCursorMove(cursor)
        @addCssClass(@getBodyTagElement(), @focusModeShadowBodyClassName)


    off: =>
        @isActivated = false
        @removeFocusModeShadowMarkers()
        @focusShadowMarkerCache = {}
        @removeCssClass(@getBodyTagElement(), @focusModeShadowBodyClassName)


    getFocusShadowBufferStartRow: (cursorBufferRow, numOfRowsToShadow) =>
        startRow = cursorBufferRow - numOfRowsToShadow
        startRow = 0 if startRow < 0

        return startRow


    getFocusShadowBufferEndRow: (cursorBufferRow, numOfRowsToShadow, bufferLineCount) =>
        # We need +1 as when atom decorates a marker as type line, it doesn't
        # include a line decoration for the endRow marker in a buffer range
        endRow = cursorBufferRow + numOfRowsToShadow + 1

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

        return [[startRow, 0], [endRow, 0]]


    createShadowModeMarker: (textEditor) =>
        cursorBufferPos = textEditor.getCursorBufferPosition()
        shadowBufferRange = @getFocusModeShadowBufferRange(
            cursorBufferPos.row, textEditor.getLineCount()
        )
        marker = textEditor.markBufferRange(shadowBufferRange)
        textEditor.decorateMarker(marker, type: 'line', class: @focusLineCssClass)

        return marker


    removeFocusModeShadowMarkers: =>
        for editor in @getAtomWorkspaceTextEditors()
            marker = @focusShadowMarkerCache[editor.id]
            marker.destroy() if marker


    getFocusShadowMarkerForEditor: (editor) =>
        marker = @focusShadowMarkerCache[editor.id]

        if not marker
            marker = @createShadowModeMarker(editor)
            @focusShadowMarkerCache[editor.id] = marker

        return marker


    focusModeShadowOnCursorMove: (cursor) =>
        editor = cursor.editor
        cursorRow = cursor.getBufferRow()
        marker = @getFocusShadowMarkerForEditor(cursor.editor)
        startRow = @getFocusShadowBufferStartRow(
            cursorRow, @shadowModeNumberOfRowsBeforeCursor
        )
        endRow = @getFocusShadowBufferEndRow(
            cursorRow, @shadowModeNumberOfRowsAfterCursor, editor.getLineCount()
        )

        marker.setTailBufferPosition([startRow, 0])
        marker.setHeadBufferPosition([endRow, 0])


    dispose: =>
        @configSubscriptions.dispose() if @configSubscriptions


module.exports = FocusShadowMode
