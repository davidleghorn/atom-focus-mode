FocusShadowMode = require '../lib/focus-mode-shadow'


describe "FocusShadowMode", ->

    focusShadowMode = null
    bodyTagElem = {className: ""}

    beforeEach ->
        focusShadowMode = new FocusShadowMode()


    describe "constructor", ->

        it "should initialise properties with expected values", ->
            expect(focusShadowMode.isActivated).toEqual(false)
            expect(focusShadowMode.focusShadowMarkerCache).toEqual({})
            expect(focusShadowMode.focusModeShadowBodyClassName).toEqual("focus-mode-shadow")
            expect(focusShadowMode.shadowModeNumberOfRowsBeforeCursor).toEqual(2)
            expect(focusShadowMode.shadowModeNumberOfRowsAfterCursor).toEqual(2)

        it "should inherit from FocusModeBase", ->
            # test that focusShadowMode object contains methods from base class
            expect(focusShadowMode.getConfig).toBeDefined()
            expect(focusShadowMode.getAtomWorkspaceTextEditors).toBeDefined()
            expect(focusShadowMode.getActiveTextEditor).toBeDefined()
            expect(focusShadowMode.getBodyTagElement).toBeDefined()
            expect(focusShadowMode.addCssClass).toBeDefined()
            expect(focusShadowMode.removeCssClass).toBeDefined()
            expect(focusShadowMode.removeFocusLineClass).toBeDefined()


    describe "getNumberOfRowsToShadowBeforeCursor", ->

        it "should set shadowModeNumberOfRowsBeforeCursor to config value when value is an integer", ->
            valueFromConfig = 10
            spyOn(focusShadowMode, "getConfig").andReturn(valueFromConfig)
            focusShadowMode.getNumberOfRowsToShadowBeforeCursor()
            expect(focusShadowMode.shadowModeNumberOfRowsBeforeCursor).toEqual(valueFromConfig)

        it "should set shadowModeNumberOfRowsBeforeCursor to default value " +
            "when no value is returned from config", ->
                spyOn(focusShadowMode, "getConfig").andReturn(null)
                focusShadowMode.getNumberOfRowsToShadowBeforeCursor()
                expect(focusShadowMode.shadowModeNumberOfRowsBeforeCursor).toEqual(2)

        it "should set shadowModeNumberOfRowsBeforeCursor to default value " +
            "when value is returned from config is not an number", ->
                spyOn(focusShadowMode, "getConfig").andReturn("abcd")
                focusShadowMode.getNumberOfRowsToShadowBeforeCursor()
                expect(focusShadowMode.shadowModeNumberOfRowsBeforeCursor).toEqual(2)


    describe "getNumberOfRowsToShadowAfterCursor", ->

        it "should set shadowModeNumberOfRowsBeforeCursor to config value when value is an integer", ->
            valueFromConfig = 5
            spyOn(focusShadowMode, "getConfig").andReturn(valueFromConfig)
            focusShadowMode.getNumberOfRowsToShadowAfterCursor()
            expect(focusShadowMode.shadowModeNumberOfRowsAfterCursor).toEqual(valueFromConfig)

        it "should set shadowModeNumberOfRowsBeforeCursor to default value " +
            "when no value is returned from config", ->
                spyOn(focusShadowMode, "getConfig").andReturn(null)
                focusShadowMode.getNumberOfRowsToShadowAfterCursor()
                expect(focusShadowMode.shadowModeNumberOfRowsAfterCursor).toEqual(2)

        it "should set shadowModeNumberOfRowsBeforeCursor to default value " +
            "when value is returned from config is not an number", ->
                spyOn(focusShadowMode, "getConfig").andReturn("abcd")
                focusShadowMode.getNumberOfRowsToShadowAfterCursor()
                expect(focusShadowMode.shadowModeNumberOfRowsAfterCursor).toEqual(2)


    describe "on", ->

        cursor = {id: "a fake cursor object"}
        fakeTextEditor = {
            id: "editor1",
            getLastCursor: ->
        }

        beforeEach ->
            spyOn(fakeTextEditor, "getLastCursor").andReturn(cursor)
            spyOn(focusShadowMode, "getActiveTextEditor").andReturn(fakeTextEditor)
            spyOn(focusShadowMode, "focusModeShadowOnCursorMove").andCallFake(->)
            spyOn(focusShadowMode, "addCssClass").andCallFake(->)
            spyOn(focusShadowMode, "getBodyTagElement").andReturn(bodyTagElem)


        it "should set isActivated to true", ->
            focusShadowMode.isActivated = false
            focusShadowMode.on()
            expect(focusShadowMode.isActivated).toEqual(true)


        it "should call focusModeShadowOnCursorMove", ->
            focusShadowMode.isActivated = false
            focusShadowMode.on()
            expect(focusShadowMode.focusModeShadowOnCursorMove).toHaveBeenCalledWith(cursor)


        it "should call addCssClass", ->
            focusShadowMode.isActivated = false
            focusShadowMode.on()
            expect(focusShadowMode.addCssClass).toHaveBeenCalledWith(
                bodyTagElem, focusShadowMode.focusModeShadowBodyClassName
            )


    describe "off", ->

        beforeEach ->
            spyOn(focusShadowMode, "removeFocusModeShadowMarkers").andCallFake(->)
            spyOn(focusShadowMode, "removeCssClass")
            spyOn(focusShadowMode, "getBodyTagElement").andReturn(bodyTagElem)

        it "should set isActivated to false", ->
            focusShadowMode.isActivated = true
            focusShadowMode.off()
            expect(focusShadowMode.isActivated).toEqual(false)

        it "should call removeCssClass", ->
            focusShadowMode.isActivated = true
            focusShadowMode.off()
            expect(focusShadowMode.removeCssClass).toHaveBeenCalledWith(
                bodyTagElem, focusShadowMode.focusModeShadowBodyClassName
            )


    describe "getFocusShadowBufferStartRow", ->

        it "should return expected start row", ->
            cursorBufferRow = 5
            numOfRowsToShadow = 3
            startRow = 2
            result = focusShadowMode.getFocusShadowBufferStartRow(cursorBufferRow, numOfRowsToShadow)
            expect(result).toEqual(startRow)

        it "should return 0 if the calculated start row would be less than 0", ->
            cursorBufferRow = 2
            numOfRowsToShadow = 3
            result = focusShadowMode.getFocusShadowBufferStartRow(cursorBufferRow, numOfRowsToShadow)
            expect(result).toEqual(0)


    describe "getFocusShadowBufferEndRow", ->

        numOfRowsToShadow = 3
        lineCount = 55

        it "should return expected end row", ->
            cursorRow = 30
            result = focusShadowMode.getFocusShadowBufferEndRow(cursorRow, numOfRowsToShadow, lineCount)
            expect(result).toEqual(34)

        it "should return the last row number if the calculated end row exceeds total rows", ->
            cursorRow = 53
            result = focusShadowMode.getFocusShadowBufferEndRow(cursorRow, numOfRowsToShadow, lineCount)
            expect(result).toEqual(54)


    describe "getFocusModeShadowBufferRange", ->

        it "should return the expected buffer range", ->
            cursorRow = 33
            lineCount = 55
            startRow = 30
            endRow = 36

            spyOn(focusShadowMode, "getFocusShadowBufferStartRow").andReturn(startRow)
            spyOn(focusShadowMode, "getFocusShadowBufferEndRow").andReturn(endRow)

            result = focusShadowMode.getFocusModeShadowBufferRange(cursorRow, lineCount)

            expect(result).toEqual([[startRow, 0], [endRow, 0]])


    describe "createShadowModeMarker", ->

        cursorRow = 10
        cursorBufferPos = {row: cursorRow}
        marker = {id: "marker1"}
        fakeTextEditor = {
            decorateMarker: ->
            markBufferRange: ->
            getCursorBufferPosition: -> cursorBufferPos
            getLineCount: -> 35
        }

        beforeEach ->
            spyOn(fakeTextEditor, "decorateMarker").andCallFake(->)
            spyOn(focusShadowMode, "getFocusModeShadowBufferRange").andReturn({})
            spyOn(fakeTextEditor, "markBufferRange").andReturn(marker)

        it "should call decorate marker", ->
            focusShadowMode.createShadowModeMarker(fakeTextEditor)
            expect(fakeTextEditor.decorateMarker).toHaveBeenCalledWith(
                marker, type: 'line', class: focusShadowMode.focusLineCssClass
            )

        it "should return a marker", ->
            result = focusShadowMode.createShadowModeMarker(fakeTextEditor)
            expect(result).toEqual(marker)


    describe "removeFocusModeShadowMarkers", ->

        marker1 = { destroy: -> }
        marker2 = { destroy: -> }
        workspaceEditors = [{id: "editor1"}, {id: "editor2"}]
        shadowMarkerCache = {
            "editor1": marker1,
            "editor2": marker2
        }

        beforeEach ->
            spyOn(focusShadowMode, "getAtomWorkspaceTextEditors").andReturn(workspaceEditors)
            spyOn(marker1, "destroy")
            spyOn(marker2, "destroy")
            focusShadowMode.focusShadowMarkerCache = shadowMarkerCache

        it "should iterate over focusShadowMarkerCache and destroy each editors markers", ->
            focusShadowMode.removeFocusModeShadowMarkers()
            expect(marker1.destroy).toHaveBeenCalled()
            expect(marker2.destroy).toHaveBeenCalled()


    describe "getFocusShadowMarkerForEditor", ->

        marker1 = { id: "marker1", destroy: -> }
        marker2 = { id: "marker2", destroy: -> }
        editor1 = { id: "editor1" }
        editor2 = { id: "editor2" }

        it "should return the cached marker for the passed editor", ->
            spyOn(focusShadowMode, "createShadowModeMarker")
            focusShadowMode.focusShadowMarkerCache = {"editor1": marker1}
            result = focusShadowMode.getFocusShadowMarkerForEditor(editor1)
            expect(result).toEqual(marker1)
            expect(focusShadowMode.createShadowModeMarker).not.toHaveBeenCalled()

        it "should create a marker and add to focusShadowMarkerCache " +
            "if there is no cached marker for the editor ", ->
                spyOn(focusShadowMode, "createShadowModeMarker").andReturn(marker2)

                focusShadowMode.focusShadowMarkerCache = {"editor1": marker1}
                result = focusShadowMode.getFocusShadowMarkerForEditor(editor2)

                expect(focusShadowMode.createShadowModeMarker).toHaveBeenCalledWith(editor2)
                expect(result).toEqual(marker2)
                expect(focusShadowMode.focusShadowMarkerCache).toEqual({
                    "editor1": marker1,
                    "editor2": marker2
                })


    describe "focusModeShadowOnCursorMove", ->

        lineCount = 35
        editor = {
            getLineCount: -> lineCount
        }
        cursorRow = 2
        cursor = {
            editor: editor,
            getBufferRow: -> cursorRow
        }
        marker = {
            setTailBufferPosition: ->
            setHeadBufferPosition: ->
        }
        startRow = 2
        endRow = 4

        beforeEach ->
            spyOn(focusShadowMode, "getFocusShadowMarkerForEditor").andReturn(marker)
            spyOn(focusShadowMode, "getFocusShadowBufferStartRow").andReturn(startRow)
            spyOn(focusShadowMode, "getFocusShadowBufferEndRow").andReturn(endRow)
            spyOn(marker, "setTailBufferPosition").andCallFake(->)
            spyOn(marker, "setHeadBufferPosition").andCallFake(->)

        it "should update the markers head and tail buffer positions", ->
            focusShadowMode.focusModeShadowOnCursorMove(cursor)

            expect(marker.setTailBufferPosition).toHaveBeenCalledWith([startRow, 0])
            expect(marker.setHeadBufferPosition).toHaveBeenCalledWith([endRow, 0])
