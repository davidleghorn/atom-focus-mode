{CompositeDisposable} = require 'atom'

FocusModeBase = require './focus-mode-base'
FocusModeSettings = require './focus-mode-settings'

class TypeWriterScrollingMode extends FocusModeBase

    constructor: ->
        super('TypeWriterScrollingMode')
        @autoActivateTypeWriterMode = @getTypeWriterModeConfigSetting()
        @isActivated = false
        @usersScrollPastEndSetting = @getConfig('editor.scrollPastEnd')
        @mouseTextSelectionInProgress = false


    getTypeWriterModeConfigSetting: ()->
        key = 'atom-focus-mode.whenFocusModeIsActivated.useTypeWriterMode'
        @getConfig(key) or false


    on: (msg) =>
        if not @isActivated
            @isActivated = true
            bodyElement = @getBodyTagElement()
            bodyElement.addEventListener("mousedown", @onmouseDown)
            bodyElement.addEventListener("mouseup", @onmouseUp)
            editor = @getActiveTextEditor()
            @centerCursorRow(editor.getLastCursor()) if editor
            @getAtomNotificationsInstance().addInfo(msg or "Type writer mode on")


    off: () =>
        @isActivated = false
        bodyElement = @getBodyTagElement()
        bodyElement.removeEventListener("mousedown", @onmouseDown)
        bodyElement.removeEventListener("mouseup", @onmouseUp)
        @getAtomNotificationsInstance().addInfo("Type writer mode off")


    onmouseDown: (e)=>
        @mouseTextSelectionInProgress = true


    onmouseUp: (e)=>
        @mouseTextSelectionInProgress = false


    centerCursorRow: (cursor) =>
        console.log('>>>> centerCursorRow <<<<')
        editor = @getActiveTextEditor()
        cursorPoint = cursor.getScreenPosition()
        screenCenterRow = @getScreenCenterRow(editor)
        if cursorPoint.row >= screenCenterRow
            editor.element.setScrollTop(editor.getLineHeightInPixels() * (cursorPoint.row - screenCenterRow))


    getScreenCenterRow: (editor) ->
        # -2 as getRowsPerPage doesn't seem to take top/bottom gutters into account
        return Math.floor(editor.getRowsPerPage() / 2) - 2


    toggle: ()=>
        if @isActivated then @off() else @on()


module.exports = TypeWriterScrollingMode
