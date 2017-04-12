{CompositeDisposable} = require 'atom'

FocusModeBase = require './focus-mode-base'
FocusModeSettings = require './focus-mode-settings'
FocusCursorMode = require './focus-cursor-mode'
FocusScopeMode = require './focus-scope-mode'
FocusShadowMode = require './focus-shadow-mode'
FocusSingleLineMode = require './focus-single-line-mode'

class FocusModeManager extends FocusModeBase

    constructor: ->
        super('FocusModeManager')
        @cursorEventSubscribers = null
        @focusScopeMode = new FocusScopeMode()
        @focusCursorMode = new FocusCursorMode()
        @focusShadowMode = new FocusShadowMode()
        @focusSingleLineMode = new FocusSingleLineMode()
        @focusModeSettings = new FocusModeSettings()
        @usersScrollPastEndSetting = atom.config.get('editor.scrollPastEnd')
        @useTypeWriterScrolling = @getConfig('atom-focus-mode.whenFocusModeIsActivated.useTypeWriterMode') or false
        @mouseTextSelectionInProgress = false
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

        if @useTypeWriterScrolling and not @mouseTextSelectionInProgress
            @centerCursorRow(cursor)


    didChangeCursorPosition: (obj) =>
        if @focusCursorMode.isActivated
            @focusCursorMode.focusLine(obj.cursor)

        if @focusShadowMode.isActivated
            @focusShadowMode.shadowModeOnCursorMove(obj.cursor)

        if @focusScopeMode.isActivated
            @focusScopeMode.scopeModeOnCursorMove(obj.cursor)

        if @useTypeWriterScrolling and not @mouseTextSelectionInProgress
            @centerCursorRow(obj.cursor)


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
                @cursorEventSubscribers.dispose() if @cursorEventSubscribers
            when @focusModes.cursorFocus
                @focusCursorMode.off()
                @cursorEventSubscribers.dispose() if @cursorEventSubscribers
            when @focusModes.shadowFocus
                @focusShadowMode.off()
                @cursorEventSubscribers.dispose() if @cursorEventSubscribers
            when @focusModes.singleLineFocus
                @focusSingleLineMode.off()


    focusModeIsActivated: ()=>
        return @focusScopeMode.isActivated or @focusCursorMode.isActivated or @focusShadowMode.isActivated


    turnOffActivatedFocusMode: ()=>
        @deActivateFocusMode(@focusModes.scopeFocus) if @focusScopeMode.isActivated
        @deActivateFocusMode(@focusModes.cursorFocus) if @focusCursorMode.isActivated
        @deActivateFocusMode(@focusModes.shadowFocus) if @focusShadowMode.isActivated
        @deActivateFocusMode(@focusModes.singleLineFocus) if @focusSingleLineMode.isActivated


    screenSetup: ()=>
        @setFullScreen()
        @typeWriterModeActivate() if @useTypeWriterScrolling
        @shouldReflowEditorContent()


    # --------- menu and shortcut key focus mode toggle event handlers --------

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
        @typeWriterModeDeactivate()


    # -------- text reflow fix when editor is centered with larger text ------

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


    # -------------- type writer scrolling mode -----------------

    typeWriterModeActivate: ()=>
        atom.config.set('editor.scrollPastEnd', true) if not @usersScrollPastEndSetting
        body = document.querySelector("body")
        body.addEventListener("mousedown", @onmouseDown)
        body.addEventListener("mouseup", @onmouseUp)
        @centerCursorRow(editor.getLastCursor()) if editor = @getActiveTextEditor()

    typeWriterModeDeactivate: ()=>
        atom.config.set('editor.scrollPastEnd', @usersScrollPastEndSetting)
        body = document.querySelector("body")
        body.removeEventListener("mousedown", @onmouseDown)
        body.removeEventListener("mouseup", @onmouseUp)

    onmouseDown: (e)=>
        @mouseTextSelectionInProgress = true

    onmouseUp: (e)=>
        @mouseTextSelectionInProgress = false

    centerCursorRow: (cursor)=>
        if @focusModeIsActivated()
            editor = @getActiveTextEditor()
            cursorPoint = cursor.getScreenPosition()
            screenCenterRow = @getScreenCenterRow(editor)
            if cursorPoint.row >= screenCenterRow
                editor.setScrollTop(editor.getLineHeightInPixels() * (cursorPoint.row - screenCenterRow))

    getScreenCenterRow: (editor) ->
        # -2 as getRowsPerPage doesn't seem to take top/bottom gutters into account
        return Math.floor(editor.getRowsPerPage() / 2) - 2

    # toggle type writer scrolling keyboard shortcut handler
    toggleTypeWriterScrolling: ()=>
        @useTypeWriterScrolling = !@useTypeWriterScrolling
        atom.config.set("atom-focus-mode.whenFocusModeIsActivated.useTypeWriterMode", @useTypeWriterScrolling)
        msg = if @useTypeWriterScrolling then "Focus Mode Type Writer Scrolling On" else "Focus Mode Type Writer Scrolling Off"
        atom.notifications.addInfo(msg)

    #  callback when package useTypeWriterScrolling config setting value is changed
    useTypeWriterScrollingValueChanged: (value) =>
        @useTypeWriterScrolling = value
        if @focusModeIsActivated()
            if @useTypeWriterScrolling then @typeWriterModeActivate() else @typeWriterModeDeactivate()


    subscribersDispose: =>
        @cursorEventSubscribers.dispose() if @cursorEventSubscribers
        @focusShadowMode.dispose()
        @configSubscribers.dispose() if @configSubscribers


module.exports = FocusModeManager
