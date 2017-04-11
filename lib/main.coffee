
{CompositeDisposable} = require 'atom'
FocusModeManager = require './focus-mode-manager'

module.exports =

    config:

        focusModeLineOpacity:
            type: 'string'
            default: '65%'
            enum: ['65%','100%']
            order: 1

         whenFocusModeIsActivated:
            type: 'object'
            order: 2
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
                hideLineWrapGuide:
                    title: "Hide Line Length Guide"
                    type: 'boolean'
                    default: false
                useLargeFontSize:
                    title: "Use Large Font Size"
                    type: 'boolean'
                    default: false
                useTypeWriterMode:
                    title: "Use Type Writer Scrolling"
                    description: "Keeps the line containing the cursor in the center of the text editor"
                    type: 'boolean'
                    default: false
                centerEditor:
                    title: "Center Editor"
                    type: "string"
                    default: ""
                    enum: [
                        {value: "", description: "Off"},
                        {value: "afm-center-editor", description: "Width 700px (Medium.com)"},
                        {value: "afm-center-editor-width-github", description: "Width 888px (Github)"},
                        {value: "afm-center-editor-width-60", description: "Width 60%"},
                        {value: "afm-center-editor-width-70", description: "Width 70%"},
                        {value: "afm-center-editor-width-80", description: "Width 80%"},
                        {value: "afm-center-editor-width-90", description: "Width 90%"}
                    ]

        focusShadowMode:
            type: 'object'
            order: 3
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
        @subscriptions.add atom.commands.add(
            'atom-workspace',
            'atom-focus-mode:exit': => @focusModeManager.exitFocusMode()
        )
        @subscriptions.add atom.commands.add(
            'atom-workspace',
            'atom-focus-mode:use-type-writer-scrolling': => @focusModeManager.toggleTypeWriterScrolling()
        )


    deactivate: ->
        @subscriptions.dispose()
        @focusModeManager.subscribersDispose()
