
{CompositeDisposable} = require 'atom'
FocusModeManager = require './focus-mode-manager'

module.exports =

    config:
        focusShadowModeNumberOfLinesToHighlightAboveCursor:
            type: 'integer'
            default: 2
            order: 1

        focusShadowModeNumberOfLinesToHighlightBelowCursor:
            type: 'integer'
            default: 2
            order: 2


    activate: (state) ->
        @focusModeManager = new FocusModeManager()
        
        @subscriptions = new CompositeDisposable()
        @subscriptions.add atom.commands.add(
            'atom-workspace',
            'atom-focus-mode:toggle': => @focusModeManager.toggleFocusMode()
        )
        @subscriptions.add atom.commands.add(
            'atom-workspace',
            'atom-focus-mode:toggle-single-line': => @focusModeManager.toggleFocusModeSingleLine()
        )
        @subscriptions.add atom.commands.add(
            'atom-workspace',
            'atom-focus-mode:toggle-shadow-mode': => @focusModeManager.toggleFocusShadowMode()
        )


    deactivate: ->
        @subscriptions.dispose()
        @focusModeManager.subscribersDispose()
