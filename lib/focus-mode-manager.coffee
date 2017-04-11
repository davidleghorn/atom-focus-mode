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

    # -----------atom editor -----------
    #
    # getActiveTextEditor: ->
    #     return atom.workspace.getActiveTextEditor()

    getActiveEditorFileType: () =>
        editor = @getActiveTextEditor()
        if editor
            splitFileName = editor.getTitle().split(".")
            return if splitFileName.length > 1 then splitFileName[1] else ""

        return ""


    setFullScreen: =>
        if (@focusModeSettings.fullScreen)
            atom.setFullScreen(true)
            body = @getBodyTagElement()
            # if editor is centered and a larger font size option, we need to trigger a reflow
            # so atom editor correctly centres larger text content
            if @hasCssClass(body, @focusModeSettings.centerWidthCssClass) and @hasCssClass(body, "afm-larger-font")
                func = ()=> @triggerTextReflow()
                window.setTimeout(func, 1800)

    exitFullScreen: =>
        if(@focusModeSettings.fullScreen)
            atom.setFullScreen(false)


    triggerTextReflow: () =>
        @removeCssClass(@getBodyTagElement(), @focusModeSettings.centerWidthCssClass)
        func = ()=> @addCssClass(@getBodyTagElement(), @focusModeSettings.centerWidthCssClass)
        window.setTimeout(func, 200)


    # ------------- adding and moving cursors -----------

    registerCursorEventHandlers: =>
        self = @
        subscriptions = new CompositeDisposable

        atom.workspace.observeTextEditors (editor) ->
            subscriptions.add editor.onDidAddCursor(self.didAddCursor)
            subscriptions.add editor.onDidChangeCursorPosition(self.didChangeCursorPosition)

        return subscriptions


    didAddCursor: (cursor) =>
        if @focusCursorMode.isActivated
            @focusCursorMode.focusLine(cursor)

        if @focusShadowMode.isActivated
            @focusShadowMode.shadowModeOnCursorMove(cursor)

        if @focusScopeMode.isActivated
            @focusScopeMode.scopeModeOnCursorMove(cursor)

        if @typeWriterModeSettingIsActivated() and @mouseTextSelectionInProgress is false
            @centerCursorRow(obj.cursor)


    didChangeCursorPosition: (obj) =>
        if @focusCursorMode.isActivated
            @focusCursorMode.focusLine(obj.cursor)

        if @focusShadowMode.isActivated
            @focusShadowMode.shadowModeOnCursorMove(obj.cursor)

        if @focusScopeMode.isActivated
            @focusScopeMode.scopeModeOnCursorMove(obj.cursor)

        if @typeWriterModeSettingIsActivated() and @mouseTextSelectionInProgress is false
            @centerCursorRow(obj.cursor)


    # ----------------- focus cursor mode ---------------

    toggleCursorFocusMode: =>
        if @focusCursorMode.isActivated
            @focusCursorModeOff()
            @exitFullScreen()
            @typeWriterModeDeactivate() # if @typeWriterModeSettingIsActivated()
        else
            @focusCursorModeOn()
            @setFullScreen()
            @typeWriterModeActivate() if @typeWriterModeSettingIsActivated()

    focusCursorModeOn: =>
        @turnOffAnyActivatedFocusModes()
        @cursorEventSubscribers = @registerCursorEventHandlers()
        @focusCursorMode.on()

    focusCursorModeOff: =>
        @focusCursorMode.off()
        @cursorEventSubscribers.dispose() if @cursorEventSubscribers


    # ----------------- focus single line mode ---------------

    toggleFocusSingleLineMode: =>
        if @focusSingleLineMode.isActivated
            @focusSingleLineMode.off()
            @exitFullScreen()
            @typeWriterModeDeactivate() # if @typeWriterModeSettingIsActivated()
        else
            @turnOffAnyActivatedFocusModes()
            @focusSingleLineMode.on()
            @setFullScreen()
            @typeWriterModeActivate() if @typeWriterModeSettingIsActivated()


    # ----------------- focus shadow mode ---------------

    toggleFocusShadowMode: =>
        if @focusShadowMode.isActivated
            @focusShadowModeOff()
            @exitFullScreen()
            @typeWriterModeDeactivate() # if @typeWriterModeSettingIsActivated()
        else
            @focusShadowModeOn()
            @setFullScreen()
            @typeWriterModeActivate() if @typeWriterModeSettingIsActivated()

    focusShadowModeOff: =>
        @focusShadowMode.off()
        @cursorEventSubscribers.dispose() if @cursorEventSubscribers

    focusShadowModeOn: =>
        @turnOffAnyActivatedFocusModes()
        @cursorEventSubscribers = @registerCursorEventHandlers()
        @focusShadowMode.on()


    # ----------------- focus scope mode ---------------

    toggleFocusScopeMode: =>
        if @focusScopeMode.isActivated
            @focusScopeModeOff()
            @exitFullScreen()
            @typeWriterModeDeactivate()
        else
            fileType = @getActiveEditorFileType()
            if (['js', 'py', 'coffee', 'md', 'txt'].indexOf(fileType) > -1)
                @focusScopeModeOn()
                @setFullScreen()
                @typeWriterModeActivate() if @typeWriterModeSettingIsActivated()
            else
                @getAtomNotificationsInstance().addInfo("Sorry, file type " +
                fileType + " is not currently supported by Scope Focus mode." +
                " All other focus modes will work with this file.");

    focusScopeModeOn: =>
        @turnOffAnyActivatedFocusModes()
        @cursorEventSubscribers = @registerCursorEventHandlers()
        @focusScopeMode.on()

    focusScopeModeOff: =>
        @focusScopeMode.off()
        @cursorEventSubscribers.dispose() if @cursorEventSubscribers


    # ---------------- general for all focus modes --------------

    exitFocusMode: =>
        @turnOffAnyActivatedFocusModes()
        @exitFullScreen()
        @cursorEventSubscribers.dispose() if @cursorEventSubscribers
        @typeWriterModeDeactivate()

    turnOffAnyActivatedFocusModes: ()=>
        @focusScopeModeOff() if @focusScopeMode.isActivated
        @focusCursorModeOff() if @focusCursorMode.isActivated
        @focusShadowModeOff() if @focusShadowMode.isActivated
        @focusSingleLineMode.off() if @focusSingleLineMode.isActivated
        @typeWriterModeDeactivate()


    # ---------------- type writer centered cursor mode -----------------

    typeWriterModeSettingIsActivated: ()->
        return @focusModeSettings.useTypeWriterMode

    typeWriterModeActivate: ()=>
        atom.config.set('editor.scrollPastEnd', true) if not @usersScrollPastEndSetting
        editor = @getActiveTextEditor()
        @centerCursorRow(editor.getLastCursor())
        document.querySelector("body").addEventListener("mousedown", @onmouseDown)
        document.querySelector("body").addEventListener("mouseup", @onmouseUp)

    typeWriterModeDeactivate: ()=>
        atom.config.set('editor.scrollPastEnd', @usersScrollPastEndSetting)
        document.querySelector("body").removeEventListener("mousedown", @onmouseDown)
        document.querySelector("body").removeEventListener("mouseup", @onmouseUp)

    onmouseDown: (e)=>
        @mouseTextSelectionInProgress = true

    onmouseUp: (e)=>
        @mouseTextSelectionInProgress = false

    centerCursorRow: (cursor)=>
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
        if @focusSingleLineMode.isActivated
            atom.notifications.addInfo("Sorry, Focus Single Line mode does not support type writer scrolling")
        else
            newValue = !@focusModeSettings.useTypeWriterMode
            msg = if newValue then "Focus Mode Type Writer Scrolling On" else "Focus Mode Type Writer Scrolling Off"
            atom.config.set("atom-focus-mode.whenFocusModeIsActivated.useTypeWriterMode", newValue)
            atom.notifications.addInfo(msg)
            if @focusScopeMode.isActivated or @focusCursorMode.isActivated or @focusShadowMode.isActivated
                @typeWriterModeActivate() if newValue


    # ----------- clean up -----------

    subscribersDispose: =>
        @cursorEventSubscribers.dispose() if @cursorEventSubscribers
        @focusShadowMode.dispose()


module.exports = FocusModeManager
