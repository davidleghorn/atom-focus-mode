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
        @screenCenterRow = @getScreenCenter()

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
            @centerCursor(obj.cursor.editor, obj.cursor)


    # ----------------- focus cursor mode ---------------

    toggleCursorFocusMode: =>
        if @focusCursorMode.isActivated
            @focusCursorModeOff()
            @exitFullScreen()
            @typeWriterModeOff() if @typeWriterModeSettingIsActivated()
        else
            @focusCursorModeOn()
            @setFullScreen()
            @typeWriterModeOn() if @typeWriterModeSettingIsActivated()

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
            @typeWriterModeOff() if @typeWriterModeSettingIsActivated()
        else
            @turnOffAnyActivatedFocusModes()
            @focusSingleLineMode.on()
            @setFullScreen()
            @typeWriterModeOn() if @typeWriterModeSettingIsActivated()


    # ----------------- focus shadow mode ---------------

    toggleFocusShadowMode: =>
        if @focusShadowMode.isActivated
            @focusShadowModeOff()
            @exitFullScreen()
            @typeWriterModeOff() if @typeWriterModeSettingIsActivated()
        else
            @focusShadowModeOn()
            @setFullScreen()
            @typeWriterModeOn() if @typeWriterModeSettingIsActivated()

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
            @typeWriterModeOff() if @typeWriterModeSettingIsActivated()
        else
            fileType = @getActiveEditorFileType()
            if (['js', 'py', 'coffee', 'md', 'txt'].indexOf(fileType) > -1)
                @focusScopeModeOn()
                @setFullScreen()
                @typeWriterModeOn() if @typeWriterModeSettingIsActivated()
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
        @typeWriterModeOff() if @typeWriterModeSettingIsActivated()

    turnOffAnyActivatedFocusModes: ()=>
        @focusScopeModeOff() if @focusScopeMode.isActivated
        @focusCursorModeOff() if @focusCursorMode.isActivated
        @focusShadowModeOff() if @focusShadowMode.isActivated
        @focusSingleLineMode.off() if @focusSingleLineMode.isActivated
        @typeWriterModeOff() if @typeWriterModeSettingIsActivated()


    # ---------------- type writer centered cursor mode -----------------

    typeWriterModeSettingIsActivated: ()->
        return true  # TODO read from package settings config object

    typeWriterModeOn: ()=>
        atom.config.set('editor.scrollPastEnd', true) if not @usersScrollPastEndSetting
        console.log("before timeout and screen center row = ", @screenCenterRow)
        # slight timeout in case activating focus mode has moved editor to full screen or hidden tabs
        funcCall = ()=> @screenCenterRow = @getScreenCenter()
        window.setTimeout(funcCall, 500) # small wait for screen to go full screen
        # console.log("DO NOTHING - NOT ++++++ adding keyup event handler")
        # document.querySelector("body").addEventListener("keyup", @keyupEventHandler)
        # document.querySelector("body").addEventListener("click", @keyupEventHandler)

    typeWriterModeOff: ()=>
        console.log("typeWriterModeOff DO NOTHING with event handlers")
        atom.config.set('editor.scrollPastEnd', @usersScrollPastEndSetting)
        # console.log("------ removing keyup event handler")
        # document.querySelector("body").removeEventListener("keyup", @keyupEventHandler)
        # document.querySelector("body").removeEventListener("click", @keyupEventHandler)

    onKeyUp: (e)=>
        console.log("Should not see this 2UP Key up e = ", e)
        @centerCursor()

    centerCursor: (editor, cursor)=>
        console.log("Cursor move version editor = ", editor, " cursor = ", cursor)
        editor = @getActiveTextEditor()
        cursor = editor.getCursorScreenPosition()
        if cursor.row > @screenCenterRow
            console.log("Manager cursor row = ", cursor.row, " screen center row = ", @screenCenterRow)
            editor.setScrollTop(editor.getLineHeightInPixels() * (cursor.row - @screenCenterRow))

    getScreenCenter: () ->
        editor = @getActiveTextEditor()
        return Math.floor(editor.getRowsPerPage() / 2)

    # -------------- clean up -----------

    subscribersDispose: =>
        @cursorEventSubscribers.dispose() if @cursorEventSubscribers
        @focusShadowMode.dispose()


module.exports = FocusModeManager
