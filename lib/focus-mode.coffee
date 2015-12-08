
{CompositeDisposable} = require 'atom'
FocusModeManager = require './focus-mode-manager'

module.exports = FocusMode =
    subscriptions: null
    focusMode: null

    # Called when package is activated
    activate: (state) ->
        @focusModeManager = new FocusModeManager()
        @subscriptions = new CompositeDisposable
        @subscriptions.add atom.commands.add 'atom-workspace', 'focus-mode:toggle': => @focusModeManager.toggleFocusMode()
        @subscriptions.add atom.commands.add 'atom-workspace', 'focus-mode:toggle-single-line': => @focusModeManager.toggleFocusModeSingleLine()


    # Called when the window is shutting down.
    deactivate: ->
        @subscriptions.dispose()
        @focusModeManager.subscribersDispose()
