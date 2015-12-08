
FocusModeManager = require '../lib/focus-mode-manager'

describe "FocusModeManager", ->

    focusMode = null

    beforeEach ->
        focusMode = new FocusModeManager()

    describe "constructor", ->

        it "should initialise properties with expected values", ->
            expect(focusMode.cursorEventSubscribers).toEqual(null)
            expect(focusMode.focussedBufferRowsCache).toEqual({})
            expect(focusMode.focusLineCssClass).toEqual("focus-line")
            expect(focusMode.focusModeBodyCssClass).toEqual("focus-mode")


    describe "didAddCursor", ->

        it "should call focusLine if focusModeActivated is true", ->
            cursor = {}
            focusMode.focusModeActivated = true
            spyOn(focusMode, "focusLine")

            focusMode.didAddCursor(cursor)

            expect(focusMode.focusLine).toHaveBeenCalledWith(cursor)


        it "should not call focusLine if focusModeActivated is false", ->
            cursor = {}
            focusMode.focusModeActivated = false
            spyOn(focusMode, "focusLine")

            focusMode.didAddCursor(cursor)

            expect(focusMode.focusLine).not.toHaveBeenCalledWith(cursor)


    describe "didChangeCursorPosition", ->

        it "should call focusLine if focusModeActivated is true", ->
            param = {cursor: {}}
            focusMode.focusModeActivated = true

            spyOn(focusMode, "focusLine")

            focusMode.didChangeCursorPosition(param)

            expect(focusMode.focusLine).toHaveBeenCalledWith(param.cursor)


        it "should not call focusLine if focusModeActivated is false", ->
            param = {cursor: {}}
            focusMode.focusModeActivated = false

            spyOn(focusMode, "focusLine")

            focusMode.didChangeCursorPosition(param)

            expect(focusMode.focusLine).not.toHaveBeenCalledWith(param)


    describe "focusLine", ->

        it "should call addFocusLineMarker if buffer row is not already focussed", ->
            bufferRow = 20
            cursor = {getBufferRow: -> bufferRow}
            activeTextEditor = {id: 1}

            spyOn(focusMode, "getActiveTextEditor").andReturn(activeTextEditor)
            spyOn(focusMode, "bufferRowIsAlreadyFocussed").andReturn(false)
            spyOn(focusMode, "addFocusLineMarker")
            spyOn(focusMode, "cacheFocussedBufferRow")

            focusMode.focusLine(cursor)

            expect(focusMode.addFocusLineMarker).toHaveBeenCalledWith(
                activeTextEditor, bufferRow
            )
            expect(focusMode.cacheFocussedBufferRow).toHaveBeenCalledWith(
                activeTextEditor.id, bufferRow
            )


        it "should not call addFocusLineMarker if buffer row is already focussed", ->
            activeTextEditor = {id: 1}
            cursor = {getBufferRow: -> 10}

            spyOn(focusMode, "getActiveTextEditor").andReturn(activeTextEditor)
            spyOn(focusMode, "bufferRowIsAlreadyFocussed").andReturn(true)
            spyOn(focusMode, "addFocusLineMarker")
            spyOn(focusMode, "cacheFocussedBufferRow")

            focusMode.focusLine(cursor)

            expect(focusMode.addFocusLineMarker).not.toHaveBeenCalled()
            expect(focusMode.cacheFocussedBufferRow).not.toHaveBeenCalled()


    describe "bufferRowIsAlreadyFocussed", ->

        it "should return true if bufferRow has already been focussed", ->
            testBufferRow = 5
            editorId = 1

            # simulate testBufferRow has already been focussed and in cache
            focusMode.focussedBufferRowsCache[editorId] = [1,2,testBufferRow]

            result = focusMode.bufferRowIsAlreadyFocussed(editorId, testBufferRow)

            expect(result).toEqual(true)


        it "should return false if bufferRow has not already been focussed", ->
            testBufferRow = 5
            editorId = 1

            # simulate a focussedBufferRowsCache that does not include the testBufferRow
            focusMode.focussedBufferRowsCache[editorId] = [1,2,3]

            result = focusMode.bufferRowIsAlreadyFocussed(editorId, testBufferRow)

            expect(result).toEqual(false)


    describe "addFocusLineMarker", ->

        it "should call textEditor decorateMarker with expected parameters", ->
            bufferRow = 11
            textEditor = {
                decorateMarker: ->
            }
            marker = {}

            spyOn(focusMode, "getBufferRangeMarker").andReturn(marker)
            spyOn(textEditor, "decorateMarker")

            focusMode.addFocusLineMarker(textEditor, bufferRow)

            expect(textEditor.decorateMarker).toHaveBeenCalledWith(
                marker, type: 'line', class: focusMode.focusLineCssClass
            )


    describe "cacheFocussedBufferRow", ->

        it "should add bufferRow to the focussed rows cache of passed editor id", ->
            bufferRow = 11
            bufferRow2 = 22
            editorId = 10

            focusMode.cacheFocussedBufferRow(editorId, bufferRow)

            expect(focusMode.focussedBufferRowsCache[editorId]).toEqual([bufferRow])

            focusMode.cacheFocussedBufferRow(editorId, bufferRow2)

            expect(focusMode.focussedBufferRowsCache[editorId]).toEqual(
                [bufferRow, bufferRow2]
            )


    describe "toggleFocusMode", ->

        fakeBodyTagElem = {fakeBodyTag: {}}

        beforeEach ->
            spyOn(focusMode, "registerCursorEventHandlers").andCallFake( -> )
            spyOn(focusMode, "focusAllCursorLines").andCallFake( -> )
            spyOn(focusMode, "getBodyTagElement").andReturn(fakeBodyTagElem)


        it "should turn off focusModeSingleLine mode if focusModeSingleLine is on", ->
            spyOn(focusMode, "removeCssClass")
            focusMode.focusModeSingleLine = true
            focusMode.focusModeActivated = false
            focusMode.toggleFocusMode()

            expect(focusMode.focusModeSingleLine).toEqual(false)
            expect(focusMode.removeCssClass).toHaveBeenCalledWith(
                fakeBodyTagElem, focusMode.focusModeBodyCssClass
            )

        # **** Toggle focus mode ON tests ****

        it "should set focusModeActivated to true when focusModeActivated is false", ->
            focusMode.focusModeActivated = false
            focusMode.toggleFocusMode()
            expect(focusMode.focusModeActivated).toEqual(true)

        it "should call addCssClass() when focusModeActivated is true", ->
            spyOn(focusMode, "addCssClass")
            focusMode.focusModeActivated = false
            focusMode.toggleFocusMode()
            expect(focusMode.addCssClass).toHaveBeenCalledWith(
                fakeBodyTagElem, focusMode.focusModeBodyCssClass
            )


        it "should call registerCursorEventHandlers() when focusModeActivated is true", ->
            focusMode.focusModeActivated = false
            focusMode.toggleFocusMode()
            expect(focusMode.registerCursorEventHandlers).toHaveBeenCalled()


        it "should call focusAllCursorLines() when focusModeActivated is true", ->
            focusMode.focusModeActivated = false
            focusMode.toggleFocusMode()
            expect(focusMode.focusAllCursorLines).toHaveBeenCalled()

        # **** Toggle focus mode OFF tests ****

        it "should set focusModeActivated to false when focusModeActivated is true", ->
            spyOn(focusMode, "focusModeOff").andCallFake( -> )
            focusMode.focusModeActivated = true
            focusMode.toggleFocusMode()
            expect(focusMode.focusModeActivated).toEqual(false)


        it "should call focusModeOff when focusModeActivated is false", ->
            spyOn(focusMode, "focusModeOff")
            focusMode.focusModeActivated = true
            focusMode.toggleFocusMode()
            expect(focusMode.focusModeOff).toHaveBeenCalledWith(fakeBodyTagElem)


    describe "focusModeOff", ->

        fakeBodyTagElem = {fakeBodyTag: {}}
        mockedCursorEventSubscribers = { dispose: -> }

        beforeEach ->
            spyOn(focusMode, "removeCssClass").andCallFake( -> )
            spyOn(focusMode, "removeFocusLineClass").andCallFake( -> )
            focusMode.cursorEventSubscribers = mockedCursorEventSubscribers


        it "should set focusModeActivated to false", ->
            focusMode.focusModeActivated = true
            focusMode.focusModeOff(fakeBodyTagElem)
            expect(focusMode.focusModeActivated).toEqual(false)


        it "should call removeCssClass()", ->
            focusMode.focusModeOff(fakeBodyTagElem)

            expect(focusMode.removeCssClass).toHaveBeenCalledWith(
                fakeBodyTagElem, focusMode.focusModeBodyCssClass
            )


        it "should call removeFocusLineClass()", ->
            focusMode.focusModeOff(fakeBodyTagElem)

            expect(focusMode.removeFocusLineClass).toHaveBeenCalled()


        it "should set focussedBufferRowsCache to an empty object", ->
            focusMode.focussedBufferRowsCache = {"1": [1,3,5,7,8]}
            focusMode.focusModeOff(fakeBodyTagElem)

            expect(focusMode.focussedBufferRowsCache).toEqual({})


        it "should call cursorEventSubscribers dispose()", ->
            spyOn(mockedCursorEventSubscribers, "dispose").andCallFake( -> )

            focusMode.cursorEventSubscribers = mockedCursorEventSubscribers
            focusMode.focusModeOff(fakeBodyTagElem)

            expect(mockedCursorEventSubscribers.dispose).toHaveBeenCalled()


    describe "toggleFocusModeSingleLine", ->

        fakeBodyTagElem = {fakeBodyTag: {}}

        beforeEach ->
            spyOn(focusMode, "getBodyTagElement").andCallFake( -> fakeBodyTagElem)
            focusMode.focusModeActivated = false

        it "should call focusModeOff() if focusModeActivated is true", ->
            spyOn(focusMode, "focusModeOff")
            focusMode.focusModeActivated = true

            focusMode.toggleFocusModeSingleLine()

            expect(focusMode.focusModeOff).toHaveBeenCalledWith(fakeBodyTagElem)


        it "should set focusModeSingleLine to true if focusModeSingleLine is false", ->
            focusMode.focusModeSingleLine = false

            focusMode.toggleFocusModeSingleLine()

            expect(focusMode.focusModeSingleLine).toEqual(true)


        it "should set focusModeSingleLine to false if focusModeSingleLine is true", ->
            focusMode.focusModeSingleLine = true

            focusMode.toggleFocusModeSingleLine()

            expect(focusMode.focusModeSingleLine).toEqual(false)


        it "should call addCssClass() if focusModeSingleLine is true", ->
            spyOn(focusMode, "addCssClass").andCallFake( -> )

            focusMode.focusModeSingleLine = false
            focusMode.toggleFocusModeSingleLine()

            expect(focusMode.addCssClass).toHaveBeenCalledWith(
                fakeBodyTagElem, focusMode.focusModeBodyCssClass
            )


        it "should call removeCssClass() if focusModeSingleLine is false", ->
            spyOn(focusMode, "removeCssClass").andCallFake( -> )

            focusMode.focusModeSingleLine = true
            focusMode.toggleFocusModeSingleLine()

            expect(focusMode.removeCssClass).toHaveBeenCalledWith(
                fakeBodyTagElem, focusMode.focusModeBodyCssClass
            )

    describe "focusAllCursorLines ", ->

        cursor = {}
        activeTextEditor = {
            id: "1"
            getCursors: -> [cursor, cursor, cursor]
        }

        beforeEach ->
            spyOn(focusMode, "getActiveTextEditor").andCallFake( -> activeTextEditor)
            spyOn(focusMode, "focusLine").andCallFake( -> )

        it "should call getActiveTextEditor()", ->
            focusMode.focusAllCursorLines()
            expect(focusMode.getActiveTextEditor).toHaveBeenCalled()


        it "should call focusLine() for each cursor in the active text editor", ->
            focusMode.focusAllCursorLines()

            expect(focusMode.focusLine).toHaveBeenCalledWith(cursor)
            expect(focusMode.focusLine.callCount).toEqual(3)


    describe "removeFocusLineClass", ->
        # Define stubbed methods and objects
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

            spyOn(focusMode, "getAtomWorkspaceTextEditors").andReturn(workspaceTextEditors)
            spyOn(markerForFocusLineDecoration, "destroy")
            spyOn(markerForNonFocusLineDecoration, "destroy")

            focusMode.removeFocusLineClass()

            expect(markerForNonFocusLineDecoration.destroy).not.toHaveBeenCalled()
            expect(markerForFocusLineDecoration.destroy).toHaveBeenCalled()
            expect(markerForFocusLineDecoration.destroy.callCount).toEqual(4)


    describe "addCssClass", ->

        it("should add cssClass to elem", ->
            elem = { className: "xxx "}
            cssClass = focusMode.focusModeBodyCssClass

            focusMode.addCssClass(elem, cssClass)

            expect(elem.className).toContain(cssClass)
        )


    describe "removeCssClass", ->

        it("should remove cssClass from elem", ->
            elem = { className: "some-class " + focusMode.focusModeBodyCssClass}

            focusMode.removeCssClass(elem, focusMode.focusModeBodyCssClass)

            expect(elem.className).not.toContain(focusMode.focusModeBodyCssClass)
            expect(elem.className).toEqual("some-class")
        )


    # describe "registerCursorEventHandlers", ->
    #     it("should return a CompositeDisposable", ->
    #         subscriptions = focusMode.registerCursorEventHandlers()
    #         expect(subscriptions).toEqual(new CompositeDisposable)
    #         subscriptions.dispose()
    #     )


    describe "subscribersDispose", ->

        it("should call cursorEventSubscribers dispose if there are cursorEventSubscribers", ->
            subscriptions = { dispose: -> }
            fakeBodyTagElem = {fakeBodyTag: {}}

            spyOn(focusMode, "getBodyTagElement").andReturn(fakeBodyTagElem)
            spyOn(focusMode, "registerCursorEventHandlers").andReturn(subscriptions)
            spyOn(focusMode, "focusAllCursorLines").andCallFake( -> )
            spyOn(subscriptions, "dispose")

            # toggle focus mode on (to register subscribers)
            focusMode.toggleFocusMode()
            expect(focusMode.cursorEventSubscribers).toEqual(subscriptions)

            focusMode.subscribersDispose()
            expect(subscriptions.dispose).toHaveBeenCalled()
        )
