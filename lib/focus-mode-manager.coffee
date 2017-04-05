{CompositeDisposable} = require 'atom'

FocusModeSettings = require './focus-mode-settings'
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
        @focusModeSettings = new FocusModeSettings()


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


    toggleCursorFocusMode: =>
        if @focusCursorMode.isActivated
            @focusCursorModeOff()
            @exitFullScreen()
        else
            @focusCursorModeOn()
            @setFullScreen()


    focusCursorModeOn: =>
        @turnOffAnyActivatedFocusModes()
        @cursorEventSubscribers = @registerCursorEventHandlers()
        @focusCursorMode.on()


    focusCursorModeOff: =>
        @focusCursorMode.off()
        @cursorEventSubscribers.dispose() if @cursorEventSubscribers


    toggleFocusSingleLineMode: =>
        if @focusSingleLineMode.isActivated
            @focusSingleLineMode.off()
            @exitFullScreen()
        else
            @turnOffAnyActivatedFocusModes()
            @focusSingleLineMode.on()
            @setFullScreen()


    toggleFocusShadowMode: =>
        if @focusShadowMode.isActivated
            @focusShadowModeOff()
            @exitFullScreen()
        else
            @focusShadowModeOn()
            @setFullScreen()


    focusShadowModeOff: =>
        @focusShadowMode.off()
        @cursorEventSubscribers.dispose() if @cursorEventSubscribers


    focusShadowModeOn: =>
        @turnOffAnyActivatedFocusModes()
        @cursorEventSubscribers = @registerCursorEventHandlers()
        @focusShadowMode.on()


    toggleFocusScopeMode: =>
        if @focusScopeMode.isActivated
            @focusScopeModeOff()
            @exitFullScreen()
        else
            @focusScopeModeOn()
            @setFullScreen()


    focusScopeModeOn: =>
        @turnOffAnyActivatedFocusModes()
        @cursorEventSubscribers = @registerCursorEventHandlers()
        @focusScopeMode.on()

    focusScopeModeOff: =>
        @focusScopeMode.off()
        @cursorEventSubscribers.dispose() if @cursorEventSubscribers


    exitFocusMode: =>
        @turnOffAnyActivatedFocusModes()
        @exitFullScreen()
        @cursorEventSubscribers.dispose() if @cursorEventSubscribers


    registerCursorEventHandlers: =>
        self = @
        subscriptions = new CompositeDisposable

        atom.workspace.observeTextEditors (editor) ->
            subscriptions.add editor.onDidAddCursor(self.didAddCursor)
            subscriptions.add editor.onDidChangeCursorPosition(self.didChangeCursorPosition)

        return subscriptions


    setFullScreen: =>
        if (@focusModeSettings.fullScreen)
            atom.setFullScreen(true)


    exitFullScreen: =>
        if(@focusModeSettings.fullScreen)
            atom.setFullScreen(false)


    turnOffAnyActivatedFocusModes: ()=>
        @focusScopeModeOff() if @focusScopeMode.isActivated
        @focusCursorModeOff() if @focusCursorMode.isActivated
        @focusShadowModeOff() if @focusShadowMode.isActivated
        @focusSingleLineMode.off() if @focusSingleLineMode.isActivated


    subscribersDispose: =>
        @cursorEventSubscribers.dispose() if @cursorEventSubscribers
        @focusShadowMode.dispose()


module.exports = FocusModeManager
