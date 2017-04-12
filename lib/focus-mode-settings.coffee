{CompositeDisposable} = require 'atom'
FocusModeBase = require './focus-mode-base'

class FocusModeSettings extends FocusModeBase

    constructor: ->
        super('FocusModeSettings')
        @fullScreen = @getConfig('atom-focus-mode.whenFocusModeIsActivated.enterFullScreen') or false
        @config = {
            "hideSidePanels": {
                "activated": @getConfig('atom-focus-mode.whenFocusModeIsActivated.hideSidePanels') or false,
                "cssClass": "afm-no-side-panels"
            },
            "hideTabBar": {
                "activated": @getConfig('atom-focus-mode.whenFocusModeIsActivated.hideTabBar') or false,
                "cssClass": "afm-no-tab-bar"
            },
            "hideFooterBar": {
                "activated": @getConfig('atom-focus-mode.whenFocusModeIsActivated.hideFooterBar') or false,
                "cssClass": "afm-no-footer"
            },
            "hideLineNumbers": {
                "activated": @getConfig('atom-focus-mode.whenFocusModeIsActivated.hideLineNumbers') or false,
                "cssClass": "afm-no-line-numbers"
            },
            "hideLineWrapGuide": {
                "activated": @getConfig('atom-focus-mode.whenFocusModeIsActivated.hideLineWrapGuide') or false,
                "cssClass": "afm-no-wrap-guide"
            },
            "useLargeFontSize": {
                "activated": @getConfig('atom-focus-mode.whenFocusModeIsActivated.useLargeFontSize') or false,
                "cssClass": "afm-larger-font"
            }
        }
        @applyConfigSettings()
        @configSubscribers = @registerConfigSubscribers()
        @centerWidthCssClass = @getConfig('atom-focus-mode.whenFocusModeIsActivated.centerEditor')
        @centerEditor(@centerWidthCssClass)


    applyConfigSettings: =>
        for key of @config when @config[key].activated
            @addCssClass(@getBodyTagElement(), @config[key].cssClass)


    registerConfigSubscribers: =>
        configSubscribers = new CompositeDisposable()

        configSubscribers.add(atom.config.observe(
            'atom-focus-mode.whenFocusModeIsActivated.enterFullScreen',
            (value) => @fullScreen = value if value?
        ))
        configSubscribers.add(atom.config.observe(
            'atom-focus-mode.whenFocusModeIsActivated.hideSidePanels',
            (value) => @applyConfigSetting("hideSidePanels", value)
        ))
        configSubscribers.add(atom.config.observe(
            'atom-focus-mode.whenFocusModeIsActivated.hideTabBar',
            (value) => @applyConfigSetting("hideTabBar", value)
        ))
        configSubscribers.add(atom.config.observe(
            'atom-focus-mode.whenFocusModeIsActivated.hideFooterBar',
            (value) => @applyConfigSetting("hideFooterBar", value)
        ))
        configSubscribers.add(atom.config.observe(
            'atom-focus-mode.whenFocusModeIsActivated.hideLineNumbers',
            (value) => @applyConfigSetting("hideLineNumbers", value)
        ))
        configSubscribers.add(atom.config.observe(
            'atom-focus-mode.whenFocusModeIsActivated.hideLineWrapGuide',
            (value) => @applyConfigSetting("hideLineWrapGuide", value)
        ))
        configSubscribers.add(atom.config.observe(
            'atom-focus-mode.whenFocusModeIsActivated.useLargeFontSize',
            (value) => @applyConfigSetting("useLargeFontSize", value)
        ))
        configSubscribers.add(atom.config.observe(
            'atom-focus-mode.focusModeLineOpacity',
            (value) => @applyFocusLineCssClass(value)
        ))
        configSubscribers.add(atom.config.observe(
            'atom-focus-mode.whenFocusModeIsActivated.centerEditor',
            (value) => @centerEditor(value)
        ))

        return configSubscribers


    applyConfigSetting: (configKey, value) =>
        @config[configKey].activated = value
        action = if @config[configKey].activated then 'addCssClass' else 'removeCssClass'
        @[action](@getBodyTagElement(), @config[configKey].cssClass)


    applyFocusLineCssClass: (opacityValue) =>
        action = if opacityValue is "100%" then 'addCssClass' else 'removeCssClass'
        @[action](@getBodyTagElement(), "line-100")


    centerEditor: (cssClass) =>
        @centerWidthCssClass = cssClass or ""
        @removeAnyCenterEditorCssClass()
        if @centerWidthCssClass isnt ""
            @addCssClass(@getBodyTagElement(), @centerWidthCssClass)


    removeAnyCenterEditorCssClass: ()=>
        bodyTag = @getBodyTagElement()
        @removeCssClass(bodyTag, "afm-center-editor-width-github")
        @removeCssClass(bodyTag, "afm-center-editor-width-60")
        @removeCssClass(bodyTag, "afm-center-editor-width-70")
        @removeCssClass(bodyTag, "afm-center-editor-width-80")
        @removeCssClass(bodyTag, "afm-center-editor-width-90")
        @removeCssClass(bodyTag, "afm-center-editor") # must be called last


    dispose: =>
        @configSubscribers.dispose() if @configSubscribers


module.exports = FocusModeSettings
