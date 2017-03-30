FocusModeBase = require './focus-mode-base'

class FocusSingleLineMode extends FocusModeBase

    constructor: ->
        super("FocusSingleLineMode")
        @isActivated = false

    on: =>
        @isActivated = true
        @addCssClass(@getBodyTagElement(), @focusModeBodyCssClass)

    off: =>
        @isActivated = false
        @removeCssClass(@getBodyTagElement(), @focusModeBodyCssClass)


module.exports = FocusSingleLineMode
