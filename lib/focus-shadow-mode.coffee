{CompositeDisposable} = require 'atom'
FocusModeBase = require './focus-mode-base'

class FocusShadowMode extends FocusModeBase

    constructor: () ->
        super('FocusShadowMode')
        @isActivated = false
        @focusShadowMarkerCache = {}
        @focusModeShadowBodyClassName = "focus-shadow-mode"
        @shadowModeNumberOfRowsBeforeCursor = @getConfig(
            'atom-focus-mode.focusShadowMode.numberOfLinesToHighlightAboveCursor'
        ) or 2
        @shadowModeNumberOfRowsAfterCursor = @getConfig(
            'atom-focus-mode.focusShadowMode.numberOfLinesToHighlightBelowCursor'
        ) or 2
        @configSubscriptions = @registerConfigSubscriptions()


    registerConfigSubscriptions: =>
        configSubscriptions = new CompositeDisposable()
        configSubscriptions.add(atom.config.observe(
            'atom-focus-mode.focusShadowMode.numberOfLinesToHighlightAboveCursor',
            (numberOfLines) => @shadowModeNumberOfRowsBeforeCursor = numberOfLines if numberOfLines?
        ))
        configSubscriptions.add(atom.config.observe(
            'atom-focus-mode.focusShadowMode.numberOfLinesToHighlightBelowCursor',
            (numberOfLines) => @shadowModeNumberOfRowsAfterCursor = numberOfLines if numberOfLines?
        ))

        return configSubscriptions


    on: =>
        @isActivated = true
        textEditor = @getActiveTextEditor()
        cursor = textEditor.getLastCursor()
        @shadowModeOnCursorMove(cursor)
        @addCssClass(@getBodyTagElement(), @focusModeShadowBodyClassName)


    off: =>
        @isActivated = false
        @removeShadowModeMarkers()
        @focusShadowMarkerCache = {}
        @removeCssClass(@getBodyTagElement(), @focusModeShadowBodyClassName)


    getShadowModeBufferStartRow: (cursorBufferRow, numOfRowsToShadow) =>
        startRow = cursorBufferRow - numOfRowsToShadow
        startRow = 0 if startRow < 0

        return startRow


    getShadowModeBufferEndRow: (cursorBufferRow, numOfRowsToShadow, bufferLineCount) =>
        # We need +1 as when atom decorates a marker as type line, it doesn't
        # include a line decoration for the endRow marker in a buffer range
        endRow = cursorBufferRow + numOfRowsToShadow + 1

        if endRow > (bufferLineCount - 1)
            endRow = bufferLineCount - 1

        return endRow


    getShadowModeBufferRange: (cursorBufferRow, bufferLineCount) =>
        startRow = @getShadowModeBufferStartRow(
            cursorBufferRow, @shadowModeNumberOfRowsBeforeCursor
        )
        endRow = @getShadowModeBufferEndRow(
            cursorBufferRow, @shadowModeNumberOfRowsAfterCursor, bufferLineCount
        )

        return [[startRow, 0], [endRow, 0]]


    createShadowModeMarker: (textEditor) =>
        cursorBufferPos = textEditor.getCursorBufferPosition()
        shadowBufferRange = @getShadowModeBufferRange(
            cursorBufferPos.row, textEditor.getLineCount()
        )
        marker = textEditor.markBufferRange(shadowBufferRange)
        textEditor.decorateMarker(marker, type: 'line', class: @focusLineCssClass)

        return marker


    removeShadowModeMarkers: =>
        for editor in @getAtomWorkspaceTextEditors()
            marker = @focusShadowMarkerCache[editor.id]
            marker.destroy() if marker


    getShadowModeMarkerForEditor: (editor) =>
        marker = @focusShadowMarkerCache[editor.id]

        if not marker
            marker = @createShadowModeMarker(editor)
            @focusShadowMarkerCache[editor.id] = marker

        return marker


    shadowModeOnCursorMove: (cursor) =>
        editor = cursor.editor
        cursorRow = cursor.getBufferRow()
        marker = @getShadowModeMarkerForEditor(cursor.editor)
        startRow = @getShadowModeBufferStartRow(
            cursorRow, @shadowModeNumberOfRowsBeforeCursor
        )
        endRow = @getShadowModeBufferEndRow(
            cursorRow, @shadowModeNumberOfRowsAfterCursor, editor.getLineCount()
        )

        marker.setTailBufferPosition([startRow, 0])
        marker.setHeadBufferPosition([endRow, 0])


    dispose: =>
        @configSubscriptions.dispose() if @configSubscriptions


module.exports = FocusShadowMode
