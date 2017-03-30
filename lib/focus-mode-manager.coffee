{CompositeDisposable} = require 'atom'

FocusCursorMode = require './focus-cursor-mode'
FocusContextMode = require './focus-mode-context'
FocusShadowMode = require './focus-shadow-mode'
FocusSingleLineMode = require './focus-mode-single-line'

class FocusModeManager

    constructor: ->
        @cursorEventSubscribers = null
        @focusContextMode = new FocusContextMode()
        @focusCursorMode = new FocusCursorMode()
        @focusShadowMode = new FocusShadowMode()
        @focusSingleLineMode = new FocusSingleLineMode()


    didAddCursor: (cursor) =>
        if @focusCursorMode.isActivated
            @focusCursorMode.focusLine(cursor)

        if @focusShadowMode.isActivated
            @focusShadowMode.shadowModeOnCursorMove(cursor)

        if @focusContextMode.isActivated
            @focusContextMode.contextModeOnCursorMove(cursor)


    didChangeCursorPosition: (obj) =>
        if @focusCursorMode.isActivated
            @focusCursorMode.focusLine(obj.cursor)

        if @focusShadowMode.isActivated
            @focusShadowMode.shadowModeOnCursorMove(obj.cursor)

        if @focusContextMode.isActivated
            @focusContextMode.contextModeOnCursorMove(obj.cursor)


    focusCursorModeOn: =>
        @focusCursorMode.on()
        @cursorEventSubscribers = @registerCursorEventHandlers()


    focusCursorModeOff: =>
        @focusCursorMode.off()
        @cursorEventSubscribers.dispose()


    focusShadowModeOff: =>
        @focusShadowMode.off()
        @cursorEventSubscribers.dispose()


    focusContextModeOff: =>
        @focusContextMode.off()
        @cursorEventSubscribers.dispose()


    toggleCursorFocusMode: =>
        @focusSingleLineMode.off() if @focusSingleLineMode.isActivated
        @focusShadowModeOff() if @focusShadowMode.isActivated
        @focusContextModeOff() if @focusContextMode.isActivated

        if @focusCursorMode.isActivated
            @focusCursorModeOff()
        else
            @focusCursorModeOn()


    toggleFocusSingleLineMode: =>
        @focusCursorModeOff() if @focusCursorMode.isActivated
        @focusShadowModeOff() if @focusShadowMode.isActivated
        @focusContextModeOff() if @focusContextMode.isActivated

        if @focusSingleLineMode.isActivated
            @focusSingleLineMode.off()
        else
            @focusSingleLineMode.on()


    toggleFocusShadowMode: =>
        @focusCursorModeOff() if @focusCursorMode.isActivated
        @focusContextModeOff() if @focusContextMode.isActivated
        @focusSingleLineMode.off() if @focusSingleLineMode.isActivated

        if @focusShadowMode.isActivated
            @focusShadowModeOff()
        else
            @cursorEventSubscribers = @registerCursorEventHandlers()
            @focusShadowMode.on()


    toggleFocusContextMode: =>
        @focusCursorModeOff() if @focusCursorMode.isActivated
        @focusShadowModeOff() if @focusShadowMode.isActivated
        @focusSingleLineMode.off() if @focusSingleLineMode.isActivated

        if @focusContextMode.isActivated
            @focusContextModeOff()
        else
            @cursorEventSubscribers = @registerCursorEventHandlers()
            @focusContextMode.on()


    registerCursorEventHandlers: =>
        self = @
        subscriptions = new CompositeDisposable

        atom.workspace.observeTextEditors (editor) ->
            subscriptions.add editor.onDidAddCursor(self.didAddCursor)
            subscriptions.add editor.onDidChangeCursorPosition(self.didChangeCursorPosition)

        return subscriptions


    subscribersDispose: =>
        @cursorEventSubscribers.dispose() if @cursorEventSubscribers
        @focusCursorMode.dispose()
        @focusShadowMode.dispose()


module.exports = FocusModeManager
