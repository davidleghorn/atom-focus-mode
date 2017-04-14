{CompositeDisposable} = require 'atom'

FocusModeBase = require './focus-mode-base'
FocusModeSettings = require './focus-mode-settings'
FocusCursorMode = require './focus-cursor-mode'
FocusScopeMode = require './focus-scope-mode'
FocusShadowMode = require './focus-shadow-mode'
FocusSingleLineMode = require './focus-single-line-mode'
TypeWriterScrollingMode = require './type-writer-scrolling-mode'

class FocusModeManager extends FocusModeBase

    constructor: ->
        super('FocusModeManager')
        @cursorEventSubscribers = null
        @focusScopeMode = new FocusScopeMode()
        @focusCursorMode = new FocusCursorMode()
        @focusShadowMode = new FocusShadowMode()
        @focusSingleLineMode = new FocusSingleLineMode()
        @focusModeSettings = new FocusModeSettings()
        @typeWriterScrollingMode = new TypeWriterScrollingMode()
        @usersScrollPastEndSetting = atom.config.get('editor.scrollPastEnd')
        key = 'atom-focus-mode.whenFocusModeIsActivated.useTypeWriterMode'
        @configSubscribers = @registerConfigSubscribers()
        @focusModes = {
            scopeFocus: "scopeFocus",
            cursorFocus: "cursorFocus",
            shadowFocus: "shadowFocus",
            singleLineFocus: "singleLineFocus"
        }


    registerConfigSubscribers: =>
        configSubscribers = new CompositeDisposable()
        configSubscribers.add(atom.config.observe(
            'atom-focus-mode.whenFocusModeIsActivated.useTypeWriterMode',
            (value) => @useTypeWriterScrollingValueChanged(value)
        ))
        return configSubscribers


    setFullScreen: =>
        atom.setFullScreen(true) if @focusModeSettings.fullScreen


    exitFullScreen: =>
        atom.setFullScreen(false) if atom.isFullScreen()


    registerCursorEventHandlers: =>
        subscriptions = new CompositeDisposable
        atom.workspace.observeTextEditors (editor) =>
            subscriptions.add editor.onDidAddCursor(@didAddCursor)
            subscriptions.add editor.onDidChangeCursorPosition(@didChangeCursorPosition)

        return subscriptions


    didAddCursor: (cursor) =>
        if @focusCursorMode.isActivated
            @focusCursorMode.focusLine(cursor)

        if @focusShadowMode.isActivated
            @focusShadowMode.shadowModeOnCursorMove(cursor)

        if @focusScopeMode.isActivated
            @focusScopeMode.scopeModeOnCursorMove(cursor)

        if @typeWriterScrollingMode.useTypeWriterScrolling and not @typeWriterScrollingMode.mouseTextSelectionInProgress
            @typeWriterScrollingMode.centerCursorRow(cursor)


    didChangeCursorPosition: (obj) =>
        if @focusCursorMode.isActivated
            @focusCursorMode.focusLine(obj.cursor)

        if @focusShadowMode.isActivated
            @focusShadowMode.shadowModeOnCursorMove(obj.cursor)

        if @focusScopeMode.isActivated
            @focusScopeMode.scopeModeOnCursorMove(obj.cursor)

        if @typeWriterScrollingMode.useTypeWriterScrolling and not @typeWriterScrollingMode.mouseTextSelectionInProgress
            @typeWriterScrollingMode.centerCursorRow(obj.cursor)


    activateFocusMode: (mode) =>
        @turnOffActivatedFocusMode()
        switch mode
            when @focusModes.scopeFocus
                @cursorEventSubscribers = @registerCursorEventHandlers()
                @focusScopeMode.on()
            when @focusModes.cursorFocus
                @cursorEventSubscribers = @registerCursorEventHandlers()
                @focusCursorMode.on()
            when @focusModes.shadowFocus
                @cursorEventSubscribers = @registerCursorEventHandlers()
                @focusShadowMode.on()
            when @focusModes.singleLineFocus
                @focusSingleLineMode.on()


    deActivateFocusMode: (mode) =>
        switch mode
            when @focusModes.scopeFocus
                @focusScopeMode.off()
            when @focusModes.cursorFocus
                @focusCursorMode.off()
            when @focusModes.shadowFocus
                @focusShadowMode.off()
            when @focusModes.singleLineFocus
                @focusSingleLineMode.off()

        @cursorEventSubscribers.dispose() if @cursorEventSubscribers


    focusModeIsActivated: ()=>
        return @focusScopeMode.isActivated or @focusCursorMode.isActivated or @focusShadowMode.isActivated


    turnOffActivatedFocusMode: ()=>
        @deActivateFocusMode(@focusModes.scopeFocus) if @focusScopeMode.isActivated
        @deActivateFocusMode(@focusModes.cursorFocus) if @focusCursorMode.isActivated
        @deActivateFocusMode(@focusModes.shadowFocus) if @focusShadowMode.isActivated
        @deActivateFocusMode(@focusModes.singleLineFocus) if @focusSingleLineMode.isActivated


    screenSetup: ()=>
        @setFullScreen()
        @typeWriterScrollingMode.on() if @typeWriterScrollingMode.useTypeWriterScrolling
        @shouldReflowEditorContent()


    toggleFocusScopeMode: =>
        if @focusScopeMode.isActivated
            @exitFocusMode()
        else
            fileType = @getActiveEditorFileType()
            if fileType in ['js', 'py', 'coffee', 'md', 'txt']
                @activateFocusMode(@focusModes.scopeFocus)
                @screenSetup()
            else
                @getAtomNotificationsInstance().addInfo("Sorry, file type #{fileType}
                 is not currently supported by Scope Focus mode.
                All other focus modes will work with this file.");


    toggleCursorFocusMode: =>
        if @focusCursorMode.isActivated
            @exitFocusMode()
        else
            @activateFocusMode(@focusModes.cursorFocus)
            @screenSetup()


    toggleFocusShadowMode: =>
        if @focusShadowMode.isActivated
            @exitFocusMode()
        else
            @activateFocusMode(@focusModes.shadowFocus)
            @screenSetup()


    toggleFocusSingleLineMode: =>
        if @focusSingleLineMode.isActivated
            @exitFocusMode()
        else
            @activateFocusMode(@focusModes.singleLineFocus)
            @screenSetup()


    exitFocusMode: =>
        @turnOffActivatedFocusMode()
        @exitFullScreen()
        @cursorEventSubscribers.dispose() if @cursorEventSubscribers
        @typeWriterScrollingMode.off()


    isCenteredEditorWithLargerFontSize: ()=>
        body = @getBodyTagElement()
        return @hasCssClass(body, @focusModeSettings.centerWidthCssClass) and @hasCssClass(body, "afm-larger-font")


    shouldReflowEditorContent: ()=>
        if @isCenteredEditorWithLargerFontSize()
            window.setTimeout(@triggerEditorReflow, 1500)


    triggerEditorReflow: () =>
        editorElem = document.querySelector("atom-text-editor.editor.is-focused")
        @addCssClass(editorElem, "reflow")
        window.setTimeout(@removeCssClass, 200, editorElem, "reflow")


    toggleTypeWriterScrolling: ()=>
        @typeWriterScrollingMode.toggle()


    useTypeWriterScrollingValueChanged: (value) =>
        if @focusModeIsActivated()
            @typeWriterScrollingMode.useTypeWriterScrolling = value
            if @typeWriterScrollingMode.useTypeWriterScrolling
                @typeWriterScrollingMode.on() if @focusModeIsActivated()
            else
                @typeWriterScrollingMode.off()


    dispose: =>
        @cursorEventSubscribers.dispose() if @cursorEventSubscribers
        @focusShadowMode.dispose()
        @configSubscribers.dispose()


module.exports = FocusModeManager
