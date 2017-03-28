{CompositeDisposable} = require 'atom'

FocusMode = require './focus-mode'
FocusModeContext = require './focus-mode-context'
FocusShadowMode = require './focus-mode-shadow'
FocusModeSingleLine = require './focus-mode-single-line'

class FocusModeManager

    constructor: ->
        @cursorEventSubscribers = null
        @focusMode = new FocusMode()
        @focusShadowMode = new FocusShadowMode()
        @focusModeSingleLine = new FocusModeSingleLine()
        @focusContextMode = new FocusModeContext()


    didAddCursor: (cursor) =>
        if @focusMode.isActivated
            @focusMode.focusLine(cursor)

        if @focusShadowMode.isActivated
            @focusShadowMode.shadowModeOnCursorMove(cursor)

        if @focusContextMode.isActivated
            @focusContextMode.contextModeOnCursorMove(cursor)


    didChangeCursorPosition: (obj) =>
        if @focusMode.isActivated
            @focusMode.focusLine(obj.cursor)

        if @focusShadowMode.isActivated
            @focusShadowMode.shadowModeOnCursorMove(obj.cursor)

        if @focusContextMode.isActivated
            @focusContextMode.contextModeOnCursorMove(obj.cursor)


    toggleFocusMode: =>
        @focusModeSingleLine.off() if @focusModeSingleLine.isActivated
        @focusShadowModeOff() if @focusShadowMode.isActivated

        if @focusMode.isActivated
            @focusModeOff()
        else
            @focusModeOn()


    focusModeOn: =>
        @focusMode.on()
        @cursorEventSubscribers = @registerCursorEventHandlers()


    focusModeOff: =>
        @focusMode.off()
        @cursorEventSubscribers.dispose()


    toggleFocusModeSingleLine: =>
        @focusModeOff() if @focusMode.isActivated
        @focusShadowModeOff() if @focusShadowMode.isActivated
        @focusContextModeOff() if @focusContextMode.isActivated

        if @focusModeSingleLine.isActivated
            @focusModeSingleLine.off()
        else
            @focusModeSingleLine.on()


    toggleFocusShadowMode: =>
        @focusModeOff() if @focusMode.isActivated
        @focusModeSingleLine.off() if @focusModeSingleLine.isActivated
        @focusContextModeOff() if @focusContextMode.isActivated

        if @focusShadowMode.isActivated
            @focusShadowModeOff()
        else
            @cursorEventSubscribers = @registerCursorEventHandlers()
            @focusShadowMode.on()


    focusShadowModeOff: =>
        @focusShadowMode.off()
        @cursorEventSubscribers.dispose()


    toggleFocusContextMode: =>
        @focusModeOff() if @focusMode.isActivated
        @focusShadowModeOff() if @focusShadowMode.isActivated
        @focusModeSingleLine.off() if @focusModeSingleLine.isActivated

        if @focusContextMode.isActivated
            @focusContextModeOff()
        else
            @cursorEventSubscribers = @registerCursorEventHandlers()
            @focusContextMode.on()


    focusContextModeOff: =>
        @focusContextMode.off()
        @cursorEventSubscribers.dispose()


    registerCursorEventHandlers: =>
        self = @
        subscriptions = new CompositeDisposable

        atom.workspace.observeTextEditors (editor) ->
            subscriptions.add editor.onDidAddCursor(self.didAddCursor)
            subscriptions.add editor.onDidChangeCursorPosition(self.didChangeCursorPosition)

        return subscriptions


    subscribersDispose: =>
        @cursorEventSubscribers.dispose() if @cursorEventSubscribers
        @focusMode.dispose()
        @focusShadowMode.dispose()


module.exports = FocusModeManager
