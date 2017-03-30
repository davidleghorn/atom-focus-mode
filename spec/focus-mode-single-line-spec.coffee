FocusModeSingleLine = require '../lib/focus-single-line-mode'


describe "FocusModeSingleLine", ->

    focusModeSingleLine = null
    bodyTagElem = {className: ""}

    beforeEach ->
        focusModeSingleLine = new FocusModeSingleLine()
        spyOn(focusModeSingleLine, "getBodyTagElement").andReturn(bodyTagElem)


    describe "constructor", ->

        it "should initialise properties with expected values", ->
            expect(focusModeSingleLine.isActivated).toEqual(false)

        it "should inherit from FocusModeBase", ->
            # test that focusShadowMode object contains methods from base class
            expect(focusModeSingleLine.getConfig).toBeDefined()
            expect(focusModeSingleLine.getAtomWorkspaceTextEditors).toBeDefined()
            expect(focusModeSingleLine.getActiveTextEditor).toBeDefined()
            expect(focusModeSingleLine.getBodyTagElement).toBeDefined()
            expect(focusModeSingleLine.addCssClass).toBeDefined()
            expect(focusModeSingleLine.removeCssClass).toBeDefined()
            expect(focusModeSingleLine.removeFocusLineClass).toBeDefined()

    describe "off", ->

        beforeEach ->
            spyOn(focusModeSingleLine, "removeCssClass").andCallFake(->)

        it "should set isActivated to false", ->
            focusModeSingleLine.isActivated = true
            focusModeSingleLine.off()
            expect(focusModeSingleLine.isActivated).toEqual(false)


        it "should call removeCssClass", ->
            focusModeSingleLine.isActivated = true
            focusModeSingleLine.off()
            expect(focusModeSingleLine.removeCssClass).toHaveBeenCalledWith(
                bodyTagElem, focusModeSingleLine.focusModeBodyCssClass
            )


    describe "on", ->

        beforeEach ->
            spyOn(focusModeSingleLine, "addCssClass").andCallFake(->)

        it "should set isActivated to true", ->
            focusModeSingleLine.isActivated = false
            focusModeSingleLine.on()
            expect(focusModeSingleLine.isActivated).toEqual(true)

        it "should call addCssClass", ->
            focusModeSingleLine.isActivated = false
            focusModeSingleLine.on()
            expect(focusModeSingleLine.addCssClass).toHaveBeenCalledWith(
                bodyTagElem, focusModeSingleLine.focusModeBodyCssClass
            )
