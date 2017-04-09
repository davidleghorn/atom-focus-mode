{CompositeDisposable} = require 'atom'

FocusModeSettings = require './focus-mode-settings'
FocusCursorMode = require './focus-cursor-mode'
FocusScopeMode = require './focus-scope-mode'
FocusShadowMode = require './focus-shadow-mode'
FocusSingleLineMode = require './focus-single-line-mode'

class FocusModeManager

    constructor: ->
        @cursorEventSubscribers = null
        @focusScopeMode = new FocusScopeMode()
        @focusCursorMode = new FocusCursorMode()
        @focusShadowMode = new FocusShadowMode()
        @focusSingleLineMode = new FocusSingleLineMode()
        @focusModeSettings = new FocusModeSettings()
        # type writer
        @keyupEventHandler = (e)=> @onKeyUp(e)
        @usersScrollPastEndSetting = atom.config.get('editor.scrollPastEnd')
        @screenCenterRow = @getScreenCenterRow()

    # -----------atom editor -----------

    getActiveTextEditor: ->
        return atom.workspace.getActiveTextEditor()

    getActiveEditorFileType: () =>
        editor = @getActiveTextEditor()
        if editor
            splitFileName = editor.getTitle().split(".")
            return if splitFileName.length > 1 then splitFileName[1] else ""

        return ""

    getAtomNotificationsInstance: ()->
        return atom.notifications

    # -------- package config settings -------

    setFullScreen: =>
        if (@focusModeSettings.fullScreen)
            atom.setFullScreen(true)

    exitFullScreen: =>
        if(@focusModeSettings.fullScreen)
            atom.setFullScreen(false)

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


    didChangeCursorPosition: (obj) =>
        console.log("didChamgePos and obj param = ", obj)
        if @focusCursorMode.isActivated
            @focusCursorMode.focusLine(obj.cursor)

        if @focusShadowMode.isActivated
            @focusShadowMode.shadowModeOnCursorMove(obj.cursor)

        if @focusScopeMode.isActivated
            @focusScopeMode.scopeModeOnCursorMove(obj.cursor)

        if @typeWriterModeSettingIsActivated()
            console.log("is on")
            @centerCursor(obj.cursor)


    # ----------------- focus cursor mode ---------------

    toggleCursorFocusMode: =>
        if @focusCursorMode.isActivated
            @focusCursorModeOff()
            @exitFullScreen()
            @typeWriterModeDeactivate() if @typeWriterModeSettingIsActivated()
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
            @typeWriterModeDeactivate() if @typeWriterModeSettingIsActivated()
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
            @typeWriterModeDeactivate() if @typeWriterModeSettingIsActivated()
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
            @typeWriterModeDeactivate() if @typeWriterModeSettingIsActivated()
        else
            fileType = @getActiveEditorFileType()
            if (['js', 'py', 'coffee', 'md', 'txt'].indexOf(fileType) > -1)
                @focusScopeModeOn()
                @setFullScreen()
                @typeWriterModeActivate() if @typeWriterModeSettingIsActivated()
            else
                @getAtomNotificationsInstance().addInfo("Sorry, file type " + fileType + " is not currently supported by Scope Focus mode. All other focus modes will work with this file.");

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
        @typeWriterModeDeactivate() if @typeWriterModeSettingIsActivated()

    turnOffAnyActivatedFocusModes: ()=>
        @focusScopeModeOff() if @focusScopeMode.isActivated
        @focusCursorModeOff() if @focusCursorMode.isActivated
        @focusShadowModeOff() if @focusShadowMode.isActivated
        @focusSingleLineMode.off() if @focusSingleLineMode.isActivated
        @typeWriterModeDeactivate() if @typeWriterModeSettingIsActivated()


    # ---------------- type writer centered cursor mode -----------------

    typeWriterModeSettingIsActivated: ()->
        return true  # TODO read from package settings config object

    typeWriterModeActivate: ()=>
        atom.config.set('editor.scrollPastEnd', true) if not @usersScrollPastEndSetting
        @screenCenterRow = @getScreenCenterRow()
        console.log("type writer on and screen center row = ", @screenCenterRow)
        # console.log("before timeout and screen center row = ", @screenCenterRow)
        # slight timeout in case activating focus mode has moved editor to full screen or hidden tabs
        # funcCall = ()=> @screenCenterRow = @getScreenCenterRow()
        # window.setTimeout(funcCall, 1000) # small wait for screen to go full screen
        # console.log("DO NOTHING - NOT ++++++ adding keyup event handler")
        # document.querySelector("body").addEventListener("keyup", @keyupEventHandler)
        # document.querySelector("body").addEventListener("click", @keyupEventHandler)

    typeWriterModeDeactivate: ()=>
        console.log("typeWriterModeDeactivate DO NOTHING with event handlers")
        atom.config.set('editor.scrollPastEnd', @usersScrollPastEndSetting)
        # console.log("------ removing keyup event handler")
        # document.querySelector("body").removeEventListener("keyup", @keyupEventHandler)
        # document.querySelector("body").removeEventListener("click", @keyupEventHandler)

    # onKeyUp: (e)=>
    #     console.log("Should not see this 2UP Key up e = ", e)
    #     @centerCursor()

    centerCursor: (cursor)=>
        console.log("Cursor move version cursor = ", cursor)
        editor = cursor.editor
        cursorPoint = cursor.getScreenPosition()
        @screenCenterRow = @getScreenCenterRow()
        if cursorPoint.row >= @screenCenterRow
            console.log("Manager cursorPoint row = ", cursorPoint.row, " screen center row = ", @screenCenterRow)
            editor.setScrollTop(editor.getLineHeightInPixels() * (cursorPoint.row - @screenCenterRow))

    getScreenCenterRow: () ->
        editor = @getActiveTextEditor()
        console.log("get screen center, rows per page = ", editor.getRowsPerPage(), " center -2 = ", Math.floor(editor.getRowsPerPage() / 2) - 2)
        # -2 as getRowsPerPage doesn't seem to take top/bottom gutters into account
        return Math.floor(editor.getRowsPerPage() / 2) - 2

    # -------------- clean up -----------

    subscribersDispose: =>
        @cursorEventSubscribers.dispose() if @cursorEventSubscribers
        @focusShadowMode.dispose()


module.exports = FocusModeManager
