
FocusModeManager = require '../lib/focus-mode-manager'

describe "FocusModeManager", ->

    focusMode = null

    beforeEach ->
        focusMode = new FocusModeManager()

    describe "constructor", ->

        it "should initialise properties with expected values", ->
            expect(focusMode.cursorEventSubscribers).toEqual(null)
            expect(focusMode.focusModeMarkersCache).toEqual({})
            expect(focusMode.focusLineCssClass).toEqual("focus-line")
            expect(focusMode.focusModeBodyCssClass).toEqual("focus-mode")
            expect(focusMode.focusModeShadowBodyClassName).toEqual("focus-mode-shadow")
            expect(focusMode.shadowModeNumberOfRowsBeforeCursor).toEqual(3)
            expect(focusMode.shadowModeNumberOfRowsAfterCursor).toEqual(3)


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


    describe "toggleFocusMode", ->

        fakeBodyTagElem = {fakeBodyTag: {}}

        beforeEach ->
            spyOn(focusMode, "registerCursorEventHandlers").andCallFake( -> )
            spyOn(focusMode, "focusTextSelections").andCallFake( -> )
            spyOn(focusMode, "getBodyTagElement").andReturn(fakeBodyTagElem)

        it "should call focusModeSingleLineOff if focusModeSingleLine is activated", ->
            spyOn(focusMode, "focusModeSingleLineOff").andCallFake( -> )
            focusMode.focusModeSingleLine = true
            focusMode.toggleFocusMode()
            expect(focusMode.focusModeSingleLineOff).toHaveBeenCalledWith(fakeBodyTagElem)

        it "should call focusModeShadowOff() if focusModeShadowActivated is true", ->
            spyOn(focusMode, "focusModeShadowOff").andCallFake( -> )
            focusMode.focusModeShadowActivated = true
            focusMode.toggleFocusMode()
            expect(focusMode.focusModeShadowOff).toHaveBeenCalledWith(fakeBodyTagElem)

        it "should set focusModeActivated to true when focusModeActivated is false", ->
            focusMode.focusModeActivated = false
            focusMode.toggleFocusMode()
            expect(focusMode.focusModeActivated).toEqual(true)

        it "should call addCssClass() when focusModeActivated is true", ->
            spyOn(focusMode, "addCssClass").andCallFake( -> )
            focusMode.focusModeActivated = false
            focusMode.toggleFocusMode()
            expect(focusMode.addCssClass).toHaveBeenCalledWith(
                fakeBodyTagElem, focusMode.focusModeBodyCssClass
            )

        it "should call registerCursorEventHandlers() when focusModeActivated is true", ->
            focusMode.focusModeActivated = false
            focusMode.toggleFocusMode()
            expect(focusMode.registerCursorEventHandlers).toHaveBeenCalled()

        it "should call focusTextSelections() when focusModeActivated is true", ->
            focusMode.focusModeActivated = false
            focusMode.toggleFocusMode()
            expect(focusMode.focusTextSelections).toHaveBeenCalled()

        it "should call focusModeOn when focusModeActivated is false", ->
            spyOn(focusMode, "focusModeOn")
            focusMode.focusModeActivated = false
            focusMode.toggleFocusMode()
            expect(focusMode.focusModeOn).toHaveBeenCalledWith(fakeBodyTagElem)

        it "should call focusModeOff when focusModeActivated is true", ->
            spyOn(focusMode, "focusModeOff")
            focusMode.focusModeActivated = true
            focusMode.toggleFocusMode()
            expect(focusMode.focusModeOff).toHaveBeenCalledWith(fakeBodyTagElem)


    describe "focusModeOn", ->

        beforeEach ->
            spyOn(focusMode, "registerCursorEventHandlers").andCallFake( -> )
            spyOn(focusMode, "focusTextSelections").andCallFake( -> )

            it "should set focusModeActivated to true", ->
                focusMode.focusModeActivated = false
                focusMode.focusModeOn(fakeBodyTagElem)
                expect(focusMode.focusModeActivated).toEqual(true)

            it "should call addCssClass()", ->
                focusMode.focusModeOn(fakeBodyTagElem)
                expect(focusMode.addCssClass).toHaveBeenCalledWith(
                    fakeBodyTagElem, focusMode.focusModeBodyCssClass
                )

            it "should call registerCursorEventHandlers()", ->
                focusMode.focusModeOn(fakeBodyTagElem)
                expect(focusMode.registerCursorEventHandlers).toHaveBeenCalled()

            it "should call focusTextSelections()", ->
                focusMode.focusModeOn(fakeBodyTagElem)
                expect(focusMode.focusTextSelections).toHaveBeenCalled()


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

        it "should set focusModeMarkersCache to an empty object", ->
            focusMode.focusModeMarkersCache = {"1": [1,3,5,7,8]}
            focusMode.focusModeOff(fakeBodyTagElem)
            expect(focusMode.focusModeMarkersCache).toEqual({})

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

        it "should call focusModeShadowOff() if focusModeShadowActivated is true", ->
            spyOn(focusMode, "focusModeShadowOff")
            focusMode.focusModeShadowActivated = true
            focusMode.toggleFocusModeSingleLine()
            expect(focusMode.focusModeShadowOff).toHaveBeenCalledWith(fakeBodyTagElem)

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


    describe "focusTextSelections", ->

        it "should do nothing if there are no atom workspace text editors", ->
            spyOn(focusMode, "getAtomWorkspaceTextEditors").andReturn([])
            spyOn(focusMode, "cacheFocusModeMarker")
            focusMode.focusTextSelections()
            expect(focusMode.cacheFocusModeMarker).not.toHaveBeenCalled()

        it "should do nothing if the text editor has no selected ranges", ->
            editor = {
                getSelectedBufferRanges: ->
            }
            spyOn(focusMode, "getAtomWorkspaceTextEditors").andReturn(editor)
            spyOn(editor, "getSelectedBufferRanges")
            spyOn(focusMode, "cacheFocusModeMarker")
            focusMode.focusTextSelections()
            expect(editor.getSelectedBufferRanges).not.toHaveBeenCalled()
            expect(focusMode.cacheFocusModeMarker).not.toHaveBeenCalled()

        it "should call decorateMarker for each selected text range", ->
            editor = {
                id: "editor1"
                getSelectedBufferRanges: ->
                decorateMarker: ->
            }
            marker = {}
            selectedRanges = [{row:10,col:30}, {row:20,col:0}, {row:21,col:0}]

            spyOn(focusMode, "getAtomWorkspaceTextEditors").andReturn([editor])
            spyOn(editor, "getSelectedBufferRanges").andReturn(selectedRanges)
            spyOn(focusMode, "getBufferRangeMarker").andReturn(marker)
            spyOn(editor, "decorateMarker")

            focusMode.focusTextSelections()

            expect(editor.decorateMarker).toHaveBeenCalledWith(
                marker, type: 'line', class: focusMode.focusLineCssClass
            )
            expect(editor.decorateMarker.callCount).toEqual(selectedRanges.length)

        it "should call cacheFocusModeMarker for each selected text range", ->
            editor = {
                id: "editor1"
                getSelectedBufferRanges: ->
                decorateMarker: ->
            }
            marker = {}
            selectedRanges = [{row:10,col:30}, {row:20,col:0}, {row:21,col:0}]

            spyOn(focusMode, "getAtomWorkspaceTextEditors").andReturn([editor])
            spyOn(editor, "getSelectedBufferRanges").andReturn(selectedRanges)
            spyOn(focusMode, "getBufferRangeMarker").andReturn(marker)
            spyOn(focusMode, "cacheFocusModeMarker")

            focusMode.focusTextSelections()

            expect(focusMode.cacheFocusModeMarker).toHaveBeenCalledWith(editor.id, marker)
            expect(focusMode.cacheFocusModeMarker.callCount).toEqual(selectedRanges.length)


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


    describe "subscribersDispose", ->

        it("should call cursorEventSubscribers dispose if there are cursorEventSubscribers", ->
            subscriptions = { dispose: -> }
            fakeBodyTagElem = {fakeBodyTag: {}}

            spyOn(focusMode, "getBodyTagElement").andReturn(fakeBodyTagElem)
            spyOn(focusMode, "registerCursorEventHandlers").andReturn(subscriptions)
            spyOn(focusMode, "focusTextSelections").andCallFake( -> )
            spyOn(subscriptions, "dispose")

            # toggle focus mode on (to register subscribers)
            focusMode.toggleFocusMode()
            expect(focusMode.cursorEventSubscribers).toEqual(subscriptions)

            focusMode.subscribersDispose()
            expect(subscriptions.dispose).toHaveBeenCalled()
        )


        describe "toggleFocusShadowMode", ->

            fakeBodyTagElem = {fakeBodyTag: {}}

            beforeEach ->
                spyOn(focusMode, "getBodyTagElement").andReturn(fakeBodyTagElem)
                spyOn(focusMode, "focusModeShadowOff").andCallFake( -> )
                spyOn(focusMode, "focusModeShadowOn").andCallFake( -> )

            it "should call focusModeSingleLineOff if focusModeSingleLine is activated", ->
                spyOn(focusMode, "focusModeSingleLineOff").andCallFake( -> )
                focusMode.focusModeSingleLine = true
                focusMode.toggleFocusShadowMode()
                expect(focusMode.focusModeSingleLineOff).toHaveBeenCalledWith(fakeBodyTagElem)

            it "should call focusModeOff() if focusModeActivated is true", ->
                spyOn(focusMode, "focusModeOff").andCallFake( -> )
                focusMode.focusModeActivated = true
                focusMode.toggleFocusShadowMode()
                expect(focusMode.focusModeOff).toHaveBeenCalledWith(fakeBodyTagElem)

            it "should call focusModeShadowActivated when focusModeShadowActivated is true", ->
                focusMode.focusModeShadowActivated = true
                focusMode.toggleFocusShadowMode()
                expect(focusMode.focusModeShadowOff).toHaveBeenCalledWith(fakeBodyTagElem)

            it "should call focusModeShadowOn when focusModeShadowActivated is false", ->
                focusMode.focusModeShadowActivated = false
                focusMode.toggleFocusShadowMode()
                expect(focusMode.focusModeShadowOn).toHaveBeenCalledWith(fakeBodyTagElem)


        describe "getFocusShadowBufferStartRow", ->

            it "should return expected start row", ->
                cursorBufferRow = 5
                numOfRowsToShadow = 3
                startRow = 2
                result = focusMode.getFocusShadowBufferStartRow(cursorBufferRow, numOfRowsToShadow)
                expect(result).toEqual(startRow)

            it "should return 0 if the calculated start row would be less than 0", ->
                cursorBufferRow = 2
                numOfRowsToShadow = 3
                result = focusMode.getFocusShadowBufferStartRow(cursorBufferRow, numOfRowsToShadow)
                expect(result).toEqual(0)


        describe "getFocusShadowBufferEndRow", ->

            numOfRowsToShadow = 3
            lineCount = 55

            it "should return expected end row", ->
                cursorRow = 30
                result = focusMode.getFocusShadowBufferEndRow(cursorRow, numOfRowsToShadow, lineCount)
                expect(result).toEqual(33)

            it "should return the last row number if the calculated end row exceeds total rows", ->
                cursorRow = 53
                result = focusMode.getFocusShadowBufferEndRow(cursorRow, numOfRowsToShadow, lineCount)
                expect(result).toEqual(54)


        describe "getFocusModeShadowBufferRange", ->

            it "should return the expected buffer range", ->
                cursorRow = 33
                lineCount = 55
                startRow = 30
                endRow = 36

                spyOn(focusMode, "getFocusShadowBufferStartRow").andReturn(startRow)
                spyOn(focusMode, "getFocusShadowBufferEndRow").andReturn(endRow)

                result = focusMode.getFocusModeShadowBufferRange(cursorRow, lineCount)

                expect(result).toEqual([[startRow, 0], [endRow, 0]])


        describe "createShadowModeMarker", ->

            cursorRow = 10
            cursorBufferPos = {row: cursorRow}
            marker = {id: "marker1"}
            textEditor = {
                decorateMarker: ->
                getCursorBufferPosition: -> cursorBufferPos
                getLineCount: -> 35
            }

            beforeEach ->
                spyOn(textEditor, "decorateMarker").andCallFake(->)
                spyOn(focusMode, "getFocusModeShadowBufferRange").andReturn({})
                spyOn(focusMode, "getBufferRangeMarker").andReturn(marker)

            it "should call decorate marker", ->
                focusMode.createShadowModeMarker(textEditor)
                expect(textEditor.decorateMarker).toHaveBeenCalledWith(
                    marker, type: 'line', class: focusMode.focusLineCssClass
                )

            it "should return a marker", ->
                result = focusMode.createShadowModeMarker(textEditor)
                expect(result).toEqual(marker)


        describe "focusModeShadowOn", ->

            bodyTag = {}
            cursor = {getBufferRow: ->}
            textEditor = {id: 1, getLastCursor: -> cursor}
            subscribers = {name: "a fake subscribers object"}

            beforeEach ->
                spyOn(focusMode, "getActiveTextEditor").andReturn(textEditor)
                spyOn(textEditor, "getLastCursor").andReturn(cursor)
                spyOn(focusMode, "registerCursorEventHandlers").andReturn(subscribers)
                spyOn(focusMode, "focusModeShadowOnCursorMove").andCallFake(->)
                spyOn(focusMode, "addCssClass").andCallFake(->)

            it "should set focusModeShadowActivated to true", ->
                focusMode.focusModeShadowActivated = false
                focusMode.focusModeShadowOn(bodyTag)
                expect(focusMode.focusModeShadowActivated).toEqual(true)

            it "should call getActiveTextEditor()", ->
                focusMode.focusModeShadowOn(bodyTag)
                expect(focusMode.getActiveTextEditor).toHaveBeenCalled()

            it "should call getLastCursor()", ->
                focusMode.focusModeShadowOn(bodyTag)
                expect(textEditor.getLastCursor).toHaveBeenCalled()

            it "should set cursorEventSubscribers", ->
                focusMode.cursorEventSubscribers = null
                focusMode.focusModeShadowOn(bodyTag)
                expect(focusMode.registerCursorEventHandlers).toHaveBeenCalled()
                expect(focusMode.cursorEventSubscribers).toEqual(subscribers)

            it "should call focusModeShadowOnCursorMove()", ->
                focusMode.focusModeShadowOn(bodyTag)
                expect(focusMode.focusModeShadowOnCursorMove).toHaveBeenCalledWith(cursor)

            it "should call addCssClass()", ->
                focusMode.focusModeShadowOn(bodyTag)
                expect(focusMode.addCssClass).toHaveBeenCalledWith(
                    bodyTag, focusMode.focusModeShadowBodyClassName
                )


        describe "focusModeShadowOff", ->

            bodyTag = {}
            eventSubscribers = {dispose: ->}

            beforeEach ->
                spyOn(focusMode, "removeFocusModeShadowMarkers").andCallFake(->)
                spyOn(focusMode, "removeCssClass").andCallFake(->)
                spyOn(eventSubscribers, "dispose").andCallFake(->)
                focusMode.cursorEventSubscribers = eventSubscribers

            it "should set focusModeShadowActivated to false", ->
                focusMode.focusModeShadowActivated = true
                focusMode.focusModeShadowOff(bodyTag)
                expect(focusMode.focusModeShadowActivated).toEqual(false)

            it "should call removeCssClass()", ->
                focusMode.focusModeShadowOff(bodyTag)
                expect(focusMode.removeCssClass).toHaveBeenCalledWith(
                    bodyTag, focusMode.focusModeShadowBodyClassName
                )

            it "should call removeFocusModeShadowMarkers()", ->
                focusMode.focusModeShadowOff(bodyTag)
                expect(focusMode.removeFocusModeShadowMarkers).toHaveBeenCalled()

            it "should call cursorEventSubscribers dispose()", ->
                focusMode.focusModeShadowOff(bodyTag)
                expect(eventSubscribers.dispose).toHaveBeenCalled()

            it "should set focusShadowMarkerCache to an empty object", ->
                focusMode.focusShadowMarkerCache = { "someEditorId": "someMarkerObj"}
                focusMode.focusModeShadowOff(bodyTag)
                expect(focusMode.focusShadowMarkerCache).toEqual({})


        describe "removeFocusModeShadowMarkers", ->

            marker1 = { destroy: -> }
            marker2 = { destroy: -> }
            workspaceEditors = [{id: "editor1"}, {id: "editor2"}]
            shadowMarkerCache = {
                "editor1": marker1,
                "editor2": marker2
            }

            beforeEach ->
                spyOn(focusMode, "getAtomWorkspaceTextEditors").andReturn(workspaceEditors)
                spyOn(marker1, "destroy")
                spyOn(marker2, "destroy")
                focusMode.focusShadowMarkerCache = shadowMarkerCache

            it "should iterate over focusShadowMarkerCache and destroy each editors markers", ->
                focusMode.removeFocusModeShadowMarkers()
                expect(marker1.destroy).toHaveBeenCalled()
                expect(marker2.destroy).toHaveBeenCalled()


        describe "getFocusShadowMarkerForEditor", ->

            marker1 = { id: "marker1", destroy: -> }
            marker2 = { id: "marker2", destroy: -> }
            editor1 = { id: "editor1" }
            editor2 = { id: "editor2" }

            it "should return the cached marker for the passed editor", ->
                spyOn(focusMode, "createShadowModeMarker")
                focusMode.focusShadowMarkerCache = {"editor1": marker1}
                result = focusMode.getFocusShadowMarkerForEditor(editor1)
                expect(result).toEqual(marker1)
                expect(focusMode.createShadowModeMarker).not.toHaveBeenCalled()

            it "should create a marker and add to focusShadowMarkerCache " +
                "if there is no cached marker for the editor ", ->
                    spyOn(focusMode, "createShadowModeMarker").andReturn(marker2)

                    focusMode.focusShadowMarkerCache = {"editor1": marker1}
                    result = focusMode.getFocusShadowMarkerForEditor(editor2)

                    expect(focusMode.createShadowModeMarker).toHaveBeenCalledWith(editor2)
                    expect(result).toEqual(marker2)
                    expect(focusMode.focusShadowMarkerCache).toEqual({
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
                spyOn(focusMode, "getFocusShadowMarkerForEditor").andReturn(marker)
                spyOn(focusMode, "getFocusShadowBufferStartRow").andReturn(startRow)
                spyOn(focusMode, "getFocusShadowBufferEndRow").andReturn(endRow)
                spyOn(marker, "setTailBufferPosition").andCallFake(->)
                spyOn(marker, "setHeadBufferPosition").andCallFake(->)

            it "should update the markers head and tail buffer positions", ->
                focusMode.focusModeShadowOnCursorMove(cursor)

                expect(marker.setTailBufferPosition).toHaveBeenCalledWith([startRow, 0])
                expect(marker.setHeadBufferPosition).toHaveBeenCalledWith([endRow, 0])
