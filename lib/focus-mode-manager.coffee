{CompositeDisposable} = require 'atom'

FocusMode = require './focus-mode'
FocusShadowMode = require './focus-mode-shadow'
FocusModeSingleLine = require './focus-mode-single-line'

class FocusModeManager

    constructor: ->
        @cursorEventSubscribers = null
        @focusMode = new FocusMode()
        @focusShadowMode = new FocusShadowMode()
        @focusModeSingleLine = new FocusModeSingleLine()


    didAddCursor: (cursor) =>
        if @focusMode.isActivated
            @focusMode.focusLine(cursor)

        if @focusShadowMode.isActivated
            @focusShadowMode.focusModeShadowOnCursorMove(cursor)


    didChangeCursorPosition: (obj) =>
        if @focusMode.isActivated
            @focusMode.focusLine(obj.cursor)

        if @focusShadowMode.isActivated
            @focusShadowMode.focusModeShadowOnCursorMove(obj.cursor)


    toggleFocusMode: =>
        @focusModeSingleLine.off() if @focusModeSingleLine.isActivated
        @focusModeShadowOff() if @focusShadowMode.isActivated

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
        @focusModeShadowOff() if @focusShadowMode.isActivated

        if @focusModeSingleLine.isActivated
            @focusModeSingleLine.off()
        else
            @focusModeSingleLine.on()


    toggleFocusShadowMode: =>
        @focusModeOff() if @focusMode.isActivated
        @focusModeSingleLine.off() if @focusModeSingleLine.isActivated

        if @focusShadowMode.isActivated
            @focusModeShadowOff()
        else
            @cursorEventSubscribers = @registerCursorEventHandlers()
            @focusShadowMode.on()


    focusModeShadowOff: =>
        @focusShadowMode.off()
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


module.exports = FocusModeManager
