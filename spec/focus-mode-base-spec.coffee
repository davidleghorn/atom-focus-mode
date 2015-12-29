FocusModeBase = require '../lib/focus-mode-base'


describe "FocusModeBase", ->

    focusModeBase = null

    beforeEach ->
        focusModeBase = new FocusModeBase()


    describe "constructor", ->

        it "should initialise properties with expected values", ->
            expect(focusModeBase.focusLineCssClass).toEqual("focus-line")
            expect(focusModeBase.focusModeBodyCssClass).toEqual("focus-mode")


    describe "constructor", ->

        it "should initialise properties with expected values", ->
            expect(focusModeBase.focusLineCssClass).toEqual("focus-line")
            expect(focusModeBase.focusModeBodyCssClass).toEqual("focus-mode")


    describe "getConfig", ->

        it "should call atom.config.get() and return config value for passed key", ->
            config = {
                "key1": "value1"
                "key2": "value2"
            }
            spyOn(atom.config, "get").andCallFake((key) -> return config[key])

            result1 = focusModeBase.getConfig("key1")
            expect(atom.config.get).toHaveBeenCalledWith("key1")
            expect(result1).toEqual("value1")

            result2 = focusModeBase.getConfig("key2")
            expect(atom.config.get).toHaveBeenCalledWith("key2")
            expect(result2).toEqual("value2")


    describe "getAtomWorkspaceTextEditors", ->

        it "should call atom.workspace.getTextEditors() and return an array of editors", ->
            arrayOfEditors = [{id:"editor1"}, {id:"editor2"}]
            spyOn(atom.workspace, "getTextEditors").andReturn(arrayOfEditors)
            result = focusModeBase.getAtomWorkspaceTextEditors()
            expect(atom.workspace.getTextEditors).toHaveBeenCalled()
            expect(result).toEqual(arrayOfEditors)


    describe "getActiveTextEditor", ->

        it "should call atom.workspace.getActiveTextEditor() and return the active text editor", ->
            activeTextEditor = {id:"editor1"}
            spyOn(atom.workspace, "getActiveTextEditor").andReturn(activeTextEditor)
            result = focusModeBase.getActiveTextEditor()
            expect(atom.workspace.getActiveTextEditor).toHaveBeenCalled()
            expect(result).toEqual(activeTextEditor)


    describe "getBodyTagElement", ->

        it("should return a reference to the body tag DOM element", ->
            bodyTagElement = document.getElementsByTagName("body")[0]
            result = focusModeBase.getBodyTagElement()
            expect(result).toEqual(bodyTagElement)
        )


    describe "addCssClass", ->

        it("should add cssClass to elem", ->
            elem = { className: ""}
            cssClass = focusModeBase.focusModeBodyCssClass
            focusModeBase.addCssClass(elem, cssClass)
            expect(elem.className).toContain(cssClass)
        )


    describe "removeCssClass", ->

        it("should remove cssClass from elem", ->
            elem = { className: "some-class " + focusModeBase.focusModeBodyCssClass}
            focusModeBase.removeCssClass(elem, focusModeBase.focusModeBodyCssClass)
            expect(elem.className).not.toContain(focusModeBase.focusModeBodyCssClass)
            expect(elem.className).toEqual("some-class")
        )


     describe "removeFocusLineClass", ->

        markerForFocusLineDecoration = {destroy: -> }
        markerForNonFocusLineDecoration = {destroy: -> }
        decorationFocusLine = {
            getProperties: -> {class: "focus-line"}
            getMarker: -> return markerForFocusLineDecoration
        }
        decorationNotFocusLine = {
            getProperties: -> {class: "some-other-class"}
            getMarker: -> return markerForNonFocusLineDecoration
        }
        editor = {
            id: "1"
            getLineDecorations: -> return [
                decorationFocusLine, decorationNotFocusLine, decorationFocusLine
            ]
        }
        editor2 = {
            id: "2"
            getLineDecorations: -> return [
                decorationFocusLine, decorationFocusLine, decorationNotFocusLine
            ]
        }
        workspaceTextEditors = [editor, editor2]

        it "should destroy all markers for decorations with the focus-line class", ->

            spyOn(focusModeBase, "getAtomWorkspaceTextEditors").andReturn(workspaceTextEditors)
            spyOn(markerForFocusLineDecoration, "destroy")
            spyOn(markerForNonFocusLineDecoration, "destroy")

            focusModeBase.removeFocusLineClass()

            expect(markerForNonFocusLineDecoration.destroy).not.toHaveBeenCalled()
            expect(markerForFocusLineDecoration.destroy).toHaveBeenCalled()
            expect(markerForFocusLineDecoration.destroy.callCount).toEqual(4)
