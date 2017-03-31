{CompositeDisposable} = require 'atom'

FocusCursorMode = require './focus-cursor-mode'
FocusScopeMode = require './focus-scope-mode'
FocusShadowMode = require './focus-shadow-mode'
FocusSingleLineMode = require './focus-single-line-mode'

class FocusModeManager

    constructor: ->
        @cursorEventSubscribers = null
        @focusScopeMode = new FocusScopeMode()
        @focusCursorMode = new FocusCursorMode()
        @focusShadowMode = new FocusShadowMode()
        @focusSingleLineMode = new FocusSingleLineMode()


    didAddCursor: (cursor) =>
        if @focusCursorMode.isActivated
            @focusCursorMode.focusLine(cursor)

        if @focusShadowMode.isActivated
            @focusShadowMode.shadowModeOnCursorMove(cursor)

        if @focusScopeMode.isActivated
            @focusScopeMode.scopeModeOnCursorMove(cursor)


    didChangeCursorPosition: (obj) =>
        if @focusCursorMode.isActivated
            @focusCursorMode.focusLine(obj.cursor)

        if @focusShadowMode.isActivated
            @focusShadowMode.shadowModeOnCursorMove(obj.cursor)

        if @focusScopeMode.isActivated
            @focusScopeMode.scopeModeOnCursorMove(obj.cursor)


    focusCursorModeOn: =>
        @focusCursorMode.on()
        @cursorEventSubscribers = @registerCursorEventHandlers()


    focusCursorModeOff: =>
        @focusCursorMode.off()
        @cursorEventSubscribers.dispose()


    focusShadowModeOff: =>
        @focusShadowMode.off()
        @cursorEventSubscribers.dispose()


    focusScopeModeOff: =>
        @focusScopeMode.off()
        @cursorEventSubscribers.dispose()


    toggleCursorFocusMode: =>
        @focusSingleLineMode.off() if @focusSingleLineMode.isActivated
        @focusShadowModeOff() if @focusShadowMode.isActivated
        @focusScopeModeOff() if @focusScopeMode.isActivated

        if @focusCursorMode.isActivated
            @focusCursorModeOff()
        else
            @focusCursorModeOn()


    toggleFocusSingleLineMode: =>
        @focusCursorModeOff() if @focusCursorMode.isActivated
        @focusShadowModeOff() if @focusShadowMode.isActivated
        @focusScopeModeOff() if @focusScopeMode.isActivated

        if @focusSingleLineMode.isActivated
            @focusSingleLineMode.off()
        else
            @focusSingleLineMode.on()


    toggleFocusShadowMode: =>
        @focusCursorModeOff() if @focusCursorMode.isActivated
        @focusScopeModeOff() if @focusScopeMode.isActivated
        @focusSingleLineMode.off() if @focusSingleLineMode.isActivated

        if @focusShadowMode.isActivated
            @focusShadowModeOff()
        else
            @cursorEventSubscribers = @registerCursorEventHandlers()
            @focusShadowMode.on()


    toggleFocusScopeMode: =>
        @focusCursorModeOff() if @focusCursorMode.isActivated
        @focusShadowModeOff() if @focusShadowMode.isActivated
        @focusSingleLineMode.off() if @focusSingleLineMode.isActivated

        if @focusScopeMode.isActivated
            @focusScopeModeOff()
        else
            @cursorEventSubscribers = @registerCursorEventHandlers()
            @focusScopeMode.on()


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
