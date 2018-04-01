{CompositeDisposable} = require 'atom'

FocusModeBase = require './focus-mode-base'
FocusModeSettings = require './focus-mode-settings'

class TypeWriterScrollingMode extends FocusModeBase

    constructor: ->
        super('TypeWriterScrollingMode')
        @isActivated = false
        @usersScrollPastEndSetting = @getConfig('editor.scrollPastEnd')
        @mouseTextSelectionInProgress = false


    getTypeWriterModeConfigSetting: ()->
        key = 'atom-focus-mode.whenFocusModeIsActivated.useTypeWriterMode'
        @getConfig(key) or false


    on: () =>
        if not @isActivated
            @isActivated = true
            bodyElement = @getBodyTagElement()
            bodyElement.addEventListener("mousedown", @onmouseDown)
            bodyElement.addEventListener("mouseup", @onmouseUp)
            editor = @getActiveTextEditor()
            @centerCursorRow(editor.getLastCursor()) if editor
            @getAtomNotificationsInstance().addInfo("Typewriter mode on")


    off: () =>
        if @isActivated
            @isActivated = false
            bodyElement = @getBodyTagElement()
            bodyElement.removeEventListener("mousedown", @onmouseDown)
            bodyElement.removeEventListener("mouseup", @onmouseUp)
            @getAtomNotificationsInstance().addInfo("Typewriter mode off")


    onmouseDown: (e)=>
        @mouseTextSelectionInProgress = true


    onmouseUp: (e)=>
        @mouseTextSelectionInProgress = false


    centerCursorRow: (cursor) =>
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
