{CompositeDisposable} = require 'atom'

FocusModeBase = require './focus-mode-base'
FocusModeSettings = require './focus-mode-settings'

class TypeWriterScrollingMode extends FocusModeBase

    constructor: ->
        super('TypeWriterScrollingMode')
        key = 'atom-focus-mode.whenFocusModeIsActivated.useTypeWriterMode'
        @useTypeWriterScrolling = @getConfig(key) or false
        @usersScrollPastEndSetting = @getConfig('editor.scrollPastEnd')
        @mouseTextSelectionInProgress = false


    on: () =>
        bodyElement = @getBodyTagElement()
        @setConfig('editor.scrollPastEnd', true) if not @usersScrollPastEndSetting
        bodyElement.addEventListener("mousedown", @onmouseDown)
        bodyElement.addEventListener("mouseup", @onmouseUp)
        editor = @getActiveTextEditor()
        @centerCursorRow(editor.getLastCursor()) if editor


    off: () =>
        bodyElement = @getBodyTagElement()
        @setConfig('editor.scrollPastEnd', @usersScrollPastEndSetting)
        bodyElement.removeEventListener("mousedown", @onmouseDown)
        bodyElement.removeEventListener("mouseup", @onmouseUp)


    onmouseDown: (e)=>
        @mouseTextSelectionInProgress = true


    onmouseUp: (e)=>
        @mouseTextSelectionInProgress = false


    centerCursorRow: (cursor) =>
        editor = @getActiveTextEditor()
        cursorPoint = cursor.getScreenPosition()
        screenCenterRow = @getScreenCenterRow(editor)
        if cursorPoint.row >= screenCenterRow
            editor.setScrollTop(editor.getLineHeightInPixels() * (cursorPoint.row - screenCenterRow))


    getScreenCenterRow: (editor) ->
        # -2 as getRowsPerPage doesn't seem to take top/bottom gutters into account
        return Math.floor(editor.getRowsPerPage() / 2) - 2


    toggle: ()=>
        @useTypeWriterScrolling = !@useTypeWriterScrolling
        key = "atom-focus-mode.whenFocusModeIsActivated.useTypeWriterMode"
        @setConfig(key, @useTypeWriterScrolling)
        msg = if @useTypeWriterScrolling then "Focus Mode Type Writer Scrolling On" else "Focus Mode Type Writer Scrolling Off"
        @getAtomNotificationsInstance().addInfo(msg)


module.exports = TypeWriterScrollingMode
