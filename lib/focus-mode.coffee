
{CompositeDisposable} = require 'atom'
FocusModeManager = require './focus-mode-manager'

module.exports = FocusMode =
    subscriptions: null
    focusMode: null

    activate: (state) ->
        @focusModeManager = new FocusModeManager()
        @subscriptions = new CompositeDisposable
        @subscriptions.add atom.commands.add 'atom-workspace', 'focus-mode:toggle': => @focusModeManager.toggleFocusMode()
        @subscriptions.add atom.commands.add 'atom-workspace', 'focus-mode:toggle-single-line': => @focusModeManager.toggleFocusModeSingleLine()
        @subscriptions.add atom.commands.add 'atom-workspace', 'focus-mode:toggle-shadow-mode': => @focusModeManager.toggleFocusShadowMode()


    deactivate: ->
        @subscriptions.dispose()
        @focusModeManager.subscribersDispose()
