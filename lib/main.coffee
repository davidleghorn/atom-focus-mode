
{CompositeDisposable} = require 'atom'
FocusModeManager = require './focus-mode-manager'

module.exports =

    config:
         whenFocusModeIsActivated:
            type: 'object'
            order: 1
            properties:
                enterFullScreen:
                    title: "Enter Full Screen"
                    type: 'boolean'
                    default: true
                hideSidePanels:
                    title: "Hide Side Panels"
                    type: 'boolean'
                    default: true
                hideTabBar:
                    title: "Hide Tab Bar"
                    type: 'boolean'
                    default: true
                hideFooterBar:
                    title: "Hide Footer Bar"
                    type: 'boolean'
                    default: true
                hideLineNumbers:
                    title: "Hide Line Numbers"
                    type: 'boolean'
                    default: true
                useLargeFontSize:
                    title: "Use Large Font Size"
                    type: 'boolean'
                    default: true

        focusShadowMode:
            type: 'object'
            order: 2
            properties:
                numberOfLinesToHighlightAboveCursor:
                    title: "Number of lines to highlight above cursor"
                    type: 'integer'
                    default: 2
                    minimum: 0

                numberOfLinesToHighlightBelowCursor:
                    title: "Number of lines to highlight below cursor"
                    type: 'integer'
                    default: 2
                    minimum: 0

        cursorFocusMode:
            type: 'object'
            order: 3
            properties:
                lineOpacity:
                    title: 'Opacity applied to Cursor Focus mode highlighted lines'
                    type: 'string'
                    default: '55%'
                    enum: ['55%','100%']



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
