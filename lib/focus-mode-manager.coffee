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
        atom.setFullScreen(true)
        @focusCursorMode.on()
        @cursorEventSubscribers = @registerCursorEventHandlers()


    focusCursorModeOff: =>
        @focusCursorMode.off()
        @cursorEventSubscribers.dispose()
        if(atom.isFullScreen())
            atom.setFullScreen(false)


    focusShadowModeOff: =>
        @focusShadowMode.off()
        @cursorEventSubscribers.dispose()
        if(atom.isFullScreen())
            atom.setFullScreen(false)


    focusScopeModeOff: =>
        @focusScopeMode.off()
        @cursorEventSubscribers.dispose()
        if(atom.isFullScreen())
            atom.setFullScreen(false)


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
            if @focusShadowMode.isActivated
                @focusShadowModeOff()
        else
            @focusSingleLineMode.on()
            atom.setFullScreen(true)


    toggleFocusShadowMode: =>
        @focusCursorModeOff() if @focusCursorMode.isActivated
        @focusScopeModeOff() if @focusScopeMode.isActivated
        @focusSingleLineMode.off() if @focusSingleLineMode.isActivated

        if @focusShadowMode.isActivated
            @focusShadowModeOff()
        else
            @cursorEventSubscribers = @registerCursorEventHandlers()
            @focusShadowMode.on()
            atom.setFullScreen(true)


    toggleFocusScopeMode: =>
        @focusCursorModeOff() if @focusCursorMode.isActivated
        @focusShadowModeOff() if @focusShadowMode.isActivated
        @focusSingleLineMode.off() if @focusSingleLineMode.isActivated

        if @focusScopeMode.isActivated
            @focusScopeModeOff()
        else
            @cursorEventSubscribers = @registerCursorEventHandlers()
            @focusScopeMode.on()
            atom.setFullScreen(true)


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
