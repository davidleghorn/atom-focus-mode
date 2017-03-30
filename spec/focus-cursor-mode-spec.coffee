FocusCursorMode = require '../lib/focus-cursor-mode'


describe "FocusCursorMode", ->

    focusMode = null
    bodyTagElem = {className: ""}

    beforeEach ->
        focusMode = new FocusCursorMode()
        spyOn(focusMode, "getBodyTagElement").andReturn(bodyTagElem)


    describe "constructor", ->

        it "should initialise properties with expected values", ->
            expect(focusMode.isActivated).toEqual(false)
            expect(focusMode.focusModeMarkersCache).toEqual({})
            expect(focusMode.appliedFocusModeLineOpacityCssClass).toEqual("")

        it "should inherit from FocusModeBase", ->
            # test that focusShadowMode object contains methods from base class
            expect(focusMode.getConfig).toBeDefined()
            expect(focusMode.getAtomWorkspaceTextEditors).toBeDefined()
            expect(focusMode.getActiveTextEditor).toBeDefined()
            expect(focusMode.getBodyTagElement).toBeDefined()
            expect(focusMode.addCssClass).toBeDefined()
            expect(focusMode.removeCssClass).toBeDefined()
            expect(focusMode.removeFocusLineClass).toBeDefined()


    describe "on", ->

        beforeEach ->
            spyOn(focusMode, "addCssClass").andCallFake(->)
            spyOn(focusMode, "applyFocusModeToSelectedBufferRanges").andCallFake(->)

        it "should set isActivated to true", ->
            focusMode.isActivated = false
            focusMode.on()
            expect(focusMode.isActivated).toEqual(true)

        it "should call addCssClass with focusModeBodyCssClass", ->
            focusMode.isActivated = false
            focusMode.on()
            expect(focusMode.addCssClass).toHaveBeenCalledWith(
                bodyTagElem, focusMode.focusModeBodyCssClass
            )

        it "should call addCssClass with focusModeLineOpacityCssClass", ->
            focusMode.isActivated = false
            focusMode.on()
            expect(focusMode.addCssClass).toHaveBeenCalledWith(
                bodyTagElem, focusMode.focusModeLineOpacityCssClass
            )

        it "should set appliedFocusModeLineOpacityCssClass to focusModeLineOpacityCssClass", ->
            focusMode.isActivated = false
            focusMode.appliedFocusModeLineOpacityCssClass = ""
            focusMode.on()
            expect(focusMode.appliedFocusModeLineOpacityCssClass).toEqual(focusMode.focusModeLineOpacityCssClass)

        it "should call applyFocusModeToSelectedBufferRanges", ->
            focusMode.isActivated = false
            focusMode.on()
            expect(focusMode.applyFocusModeToSelectedBufferRanges).toHaveBeenCalled()


    describe "off", ->

        beforeEach ->
            spyOn(focusMode, "removeCssClass").andCallFake(->)
            spyOn(focusMode, "removeFocusLineClass").andCallFake(->)

        it "should set isActivated to false", ->
            focusMode.isActivated = true
            focusMode.off()
            expect(focusMode.isActivated).toEqual(false)

        it "should call removeCssClass with focusModeBodyCssClass", ->
            focusMode.isActivated = true
            focusMode.off()
            expect(focusMode.removeCssClass).toHaveBeenCalledWith(
                bodyTagElem, focusMode.focusModeBodyCssClass
            )

        it "should call removeCssClass with appliedFocusModeLineOpacityCssClass", ->
            focusMode.isActivated = true
            focusMode.off()
            expect(focusMode.removeCssClass).toHaveBeenCalledWith(
                bodyTagElem, focusMode.appliedFocusModeLineOpacityCssClass
            )

        it "should call removeFocusLineClass", ->
            focusMode.isActivated = true
            focusMode.off()
            expect(focusMode.removeFocusLineClass).toHaveBeenCalled()

        it "should rest focusModeMarkersCache to an empty object", ->
            focusMode.focusModeMarkersCache = {"editor1": {}}
            focusMode.isActivated = true
            focusMode.off()
            expect(focusMode.focusModeMarkersCache).toEqual({})


    describe "focusLine", ->

        it "should call addFocusLineMarker if buffer row is not already focussed", ->
            bufferRow = 20
            cursor = {getBufferRow: -> bufferRow}
            activeTextEditor = {id: 1}

            spyOn(focusMode, "getActiveTextEditor").andReturn(activeTextEditor)
            spyOn(focusMode, "bufferRowIsAlreadyFocussed").andReturn(false)
            spyOn(focusMode, "addFocusLineMarker")

            focusMode.focusLine(cursor)

            expect(focusMode.addFocusLineMarker).toHaveBeenCalledWith(
                activeTextEditor, bufferRow
            )

        it "should not call addFocusLineMarker if buffer row is already focussed", ->
            activeTextEditor = {id: 1}
            cursor = {getBufferRow: -> 10}

            spyOn(focusMode, "getActiveTextEditor").andReturn(activeTextEditor)
            spyOn(focusMode, "bufferRowIsAlreadyFocussed").andReturn(true)
            spyOn(focusMode, "addFocusLineMarker")
            spyOn(focusMode, "cacheFocusModeMarker")

            focusMode.focusLine(cursor)

            expect(focusMode.addFocusLineMarker).not.toHaveBeenCalled()
            expect(focusMode.cacheFocusModeMarker).not.toHaveBeenCalled()


    describe "bufferRowIsAlreadyFocussed", ->

        it "should return true if bufferRow has already been focussed", ->
            testBufferRow = 5
            editorId = 1
            range1 = { getRows: -> }
            range2 = { getRows: -> }
            marker1 = { getBufferRange: -> range1 }
            marker2 = { getBufferRange: -> range2 }

            spyOn(marker1, "getBufferRange").andReturn(range1)
            spyOn(marker2, "getBufferRange").andReturn(range2)

            # range1 is row 11 and range2 is row 5
            spyOn(range1, "getRows").andReturn([11, 0])
            spyOn(range2, "getRows").andReturn([5, 0])

            focusMode.focusModeMarkersCache[editorId] = [marker1, marker2]

            result = focusMode.bufferRowIsAlreadyFocussed(editorId, testBufferRow)

            expect(marker1.getBufferRange).toHaveBeenCalled()
            expect(marker2.getBufferRange).toHaveBeenCalled()
            expect(range1.getRows).toHaveBeenCalled()
            expect(range2.getRows).toHaveBeenCalled()
            expect(result).toEqual(true)


        it "should return false if bufferRow has not already been focussed", ->
            testBufferRow = 5
            editorId = 1
            range1 = { getRows: -> }
            range2 = { getRows: -> }
            marker1 = { getBufferRange: -> range1 }
            marker2 = { getBufferRange: -> range2 }

            spyOn(marker1, "getBufferRange").andReturn(range1)
            spyOn(marker2, "getBufferRange").andReturn(range2)

            # range1 is row 11 and range2 is row 55
            spyOn(range1, "getRows").andReturn([11, 0])
            spyOn(range2, "getRows").andReturn([55, 0])

            focusMode.focusModeMarkersCache[editorId] = [marker1, marker2]

            result = focusMode.bufferRowIsAlreadyFocussed(editorId, testBufferRow)

            expect(marker1.getBufferRange).toHaveBeenCalled()
            expect(marker2.getBufferRange).toHaveBeenCalled()
            expect(range1.getRows).toHaveBeenCalled()
            expect(range2.getRows).toHaveBeenCalled()
            expect(result).toEqual(false)


    describe "addFocusLineMarker", ->

        bufferRow = 11
        textEditor = {
            decorateMarker: ->
            markBufferRange: ->
        }
        marker = {}

        beforeEach ->
            spyOn(textEditor, "markBufferRange").andReturn(marker)
            spyOn(textEditor, "decorateMarker").andCallFake(->)


        it "should call textEditor decorateMarker with expected parameters", ->
            focusMode.addFocusLineMarker(textEditor, bufferRow)
            expect(textEditor.decorateMarker).toHaveBeenCalledWith(
                marker, type: 'line', class: focusMode.focusLineCssClass
            )

        it "should call cacheFocusModeMarker with expected parameters", ->
            focusMode.addFocusLineMarker(textEditor, bufferRow)
            expect(textEditor.decorateMarker).toHaveBeenCalledWith(
                marker, type: 'line', class: focusMode.focusLineCssClass
            )


    describe "cacheFocusModeMarker", ->

        it "should add bufferRow to the focussed rows cache of passed editor id", ->
            bufferRow = 11
            bufferRow2 = 22
            editorId = 10

            focusMode.cacheFocusModeMarker(editorId, bufferRow)
            expect(focusMode.focusModeMarkersCache[editorId]).toEqual([bufferRow])

            focusMode.cacheFocusModeMarker(editorId, bufferRow2)
            expect(focusMode.focusModeMarkersCache[editorId]).toEqual(
                [bufferRow, bufferRow2]
            )


    describe "applyFocusModeToSelectedBufferRanges", ->

        editor = {
            id: "editor1"
            getSelectedBufferRanges: ->
            decorateMarker: ->
            markBufferRange: ->
        }
        marker = {}
        selectedRanges = [{row:10,col:30}, {row:20,col:0}, {row:21,col:0}]

        it "should do nothing if there are no atom workspace text editors", ->
            spyOn(focusMode, "getAtomWorkspaceTextEditors").andReturn([])
            spyOn(focusMode, "cacheFocusModeMarker")

            focusMode.applyFocusModeToSelectedBufferRanges()
            expect(focusMode.cacheFocusModeMarker).not.toHaveBeenCalled()


        it "should do nothing if the text editor has no selected ranges", ->
            spyOn(focusMode, "getAtomWorkspaceTextEditors").andReturn(editor)
            spyOn(editor, "getSelectedBufferRanges")
            spyOn(focusMode, "cacheFocusModeMarker")

            focusMode.applyFocusModeToSelectedBufferRanges()
            expect(editor.getSelectedBufferRanges).not.toHaveBeenCalled()
            expect(focusMode.cacheFocusModeMarker).not.toHaveBeenCalled()


        it "should call decorateMarker for each selected text range", ->
            spyOn(focusMode, "getAtomWorkspaceTextEditors").andReturn([editor])
            spyOn(editor, "getSelectedBufferRanges").andReturn(selectedRanges)
            spyOn(editor, "markBufferRange").andReturn(marker)
            spyOn(editor, "decorateMarker")

            focusMode.applyFocusModeToSelectedBufferRanges()
            expect(editor.decorateMarker).toHaveBeenCalledWith(
                marker, type: 'line', class: focusMode.focusLineCssClass
            )
            expect(editor.decorateMarker.callCount).toEqual(selectedRanges.length)


        it "should call cacheFocusModeMarker for each selected text range", ->
            spyOn(focusMode, "getAtomWorkspaceTextEditors").andReturn([editor])
            spyOn(editor, "getSelectedBufferRanges").andReturn(selectedRanges)
            spyOn(editor, "markBufferRange").andReturn(marker)
            spyOn(focusMode, "cacheFocusModeMarker")

            focusMode.applyFocusModeToSelectedBufferRanges()

            expect(focusMode.cacheFocusModeMarker).toHaveBeenCalledWith(editor.id, marker)
            expect(focusMode.cacheFocusModeMarker.callCount).toEqual(selectedRanges.length)
