
{CompositeDisposable} = require 'atom'
FocusModeManager = require './focus-mode-manager'

module.exports =

    config:

        focusModeLineOpacity:
            description: 'Opacity applied to focus mode highlighted lines'
            type: 'string'
            default: '100%'
            enum: ['100%', '55%']

        focusShadowModeNumberOfLinesToHighlightAboveCursor:
            type: 'integer'
            default: 2
            minimum: 0

        focusShadowModeNumberOfLinesToHighlightBelowCursor:
            type: 'integer'
            default: 2
            minimum: 0

         whenFocusModeIsActivated:
            type: 'object'
            properties:
                enterFullScreen:
                    description: "Full Screen"
                    type: 'boolean'
                    default: true
                hideSidePanels:
                    type: 'boolean'
                    default: true
                hideTabBar:
                    type: 'boolean'
                    default: true
                hideFooterBar:
                    type: 'boolean'
                    default: true
                hideLineNumbers:
                    type: 'boolean'
                    default: true
                useLargeFontSize:
                    type: 'boolean'
                    default: true


    activate: (state) ->
        @focusModeManager = new FocusModeManager()

        @subscriptions = new CompositeDisposable()
        @subscriptions.add atom.commands.add(
            'atom-workspace',
            'atom-focus-mode:toggle-cursor-focus': => @focusModeManager.toggleCursorFocusMode()
        )
        @subscriptions.add atom.commands.add(
            'atom-workspace',
            'atom-focus-mode:toggle-single-line-focus': => @focusModeManager.toggleFocusSingleLineMode()
        )
        @subscriptions.add atom.commands.add(
            'atom-workspace',
            'atom-focus-mode:toggle-shadow-focus': => @focusModeManager.toggleFocusShadowMode()
        )
        @subscriptions.add atom.commands.add(
            'atom-workspace',
            'atom-focus-mode:toggle-scope-focus': => @focusModeManager.toggleFocusScopeMode()
        )


    deactivate: ->
        @subscriptions.dispose()
        @focusModeManager.subscribersDispose()
