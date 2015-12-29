FocusModeBase = require './focus-mode-base'

class FocusModeSingleLine extends FocusModeBase

    constructor: ->
        super("FocusModeSingleLine")
        @isActivated = false

    on: =>
        @isActivated = true
        @addCssClass(@getBodyTagElement(), @focusModeBodyCssClass)

    off: =>
        @isActivated = false
        @removeCssClass(@getBodyTagElement(), @focusModeBodyCssClass)


module.exports = FocusModeSingleLine
