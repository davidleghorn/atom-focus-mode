
{CompositeDisposable} = require 'atom'
FocusModeManager = require './focus-mode-manager'

module.exports =

    config:
        focusShadowModeNumberOfLinesToHighlightAboveCursor:
            type: 'integer'
            default: 2
            minimum: 0
            order: 1

        focusShadowModeNumberOfLinesToHighlightBelowCursor:
            type: 'integer'
            default: 2
            minimum: 0
            order: 2

        focusModeLineOpacity:
            description: 'Opacity applied to focus mode highlighted lines'
            type: 'string'
            default: '100%'
            enum: ['100%', '55%']
            order: 3


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
        @subscriptions.add atom.commands.add(
            'atom-workspace',
            'atom-focus-mode:toggle-context-mode': => @focusModeManager.toggleFocusContextMode()
        )


    deactivate: ->
        @subscriptions.dispose()
        @focusModeManager.subscribersDispose()
