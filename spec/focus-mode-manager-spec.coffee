
FocusModeManager = require '../lib/focus-mode-manager'
# FocusMode = require '../lib/focus-cursor-mode'
# FocusShadowMode = require '../lib/focus-mode-shadow'
# FocusModeSingleLine = require '../lib/focus-mode-single-line'

describe "FocusModeManager", ->

    focusModeManager = null

    beforeEach ->
        focusModeManager = new FocusModeManager()

    describe "constructor", ->

        it "should initialise properties with expected values", ->
            expect(focusModeManager.cursorEventSubscribers).toEqual(null)
            expect(focusModeManager.focusCursorMode).toBeDefined()
            expect(focusModeManager.focusShadowMode).toBeDefined()
            expect(focusModeManager.focusSingleLineMode).toBeDefined()

        it "should set focusCursorMode property to a FocusCursorMode instance", ->
            # To test we have a FocusMode instance we check the object has some
            # properties/methods unique to a focusMode instance
            expect(focusModeManager.focusCursorMode.focusModeMarkersCache).toBeDefined()
            expect(focusModeManager.focusCursorMode.cacheFocusModeMarker).toBeDefined()

        it "should set focusShadowMode property to a FocusShadowMode instance", ->
            # To test we have a FocusShadowMode instance we check the object has some
            # properties/methods unique to a FocusShadowMode instance
            expect(focusModeManager.focusShadowMode.focusShadowMarkerCache).toBeDefined()
            expect(focusModeManager.focusShadowMode.focusModeShadowBodyClassName).toBeDefined()
            expect(focusModeManager.focusShadowMode.createShadowModeMarker).toBeDefined()

        it "should set focusShadowMode property to a focusSingleLineMode instance", ->
            # To test we have a focusSingleLineMode instance we check the object has some
            # the properties/methods expected on a focusSingleLineMode instance
            expect(focusModeManager.focusSingleLineMode.isActivated).toBeDefined()
            expect(focusModeManager.focusSingleLineMode.on).toBeDefined()
            expect(focusModeManager.focusSingleLineMode.off).toBeDefined()
            # and that it does not have properties unique to focusMode and focusShadowMode instances
            expect(focusModeManager.focusSingleLineMode.focusModeMarkersCache).not.toBeDefined()
            expect(focusModeManager.focusSingleLineMode.focusShadowMarkerCache).not.toBeDefined()


    describe "didAddCursor", ->

        it "should call focusCursorMode.focusLine() if focusCursorMode.isActivated is true", ->
            cursor = {}
            focusModeManager.focusCursorMode.isActivated = true
            spyOn(focusModeManager.focusCursorMode, "focusLine")
            focusModeManager.didAddCursor(cursor)
            expect(focusModeManager.focusCursorMode.focusLine).toHaveBeenCalledWith(cursor)


        it "should not call focusCursorMode.focusLine() if focusCursorMode.isActivated is false", ->
            cursor = {}
            focusModeManager.focusCursorMode.isActivated = false
            spyOn(focusModeManager.focusCursorMode, "focusLine")
            focusModeManager.didAddCursor(cursor)
            expect(focusModeManager.focusCursorMode.focusLine).not.toHaveBeenCalledWith(cursor)


    describe "didChangeCursorPosition", ->

        it "should call focusCursorMode.focusLine if focusCursorMode.isActivated is true", ->
            param = {cursor: {}}
            focusModeManager.focusCursorMode.isActivated = true
            spyOn(focusModeManager.focusCursorMode, "focusLine")
            focusModeManager.didChangeCursorPosition(param)
            expect(focusModeManager.focusCursorMode.focusLine).toHaveBeenCalledWith(param.cursor)

        it "should not call focusCursorMode.focusLine if focusCursorMode.isActivated is false", ->
            param = {cursor: {}}
            focusModeManager.focusCursorMode.isActivated = false
            spyOn(focusModeManager.focusCursorMode, "focusLine")
            focusModeManager.didChangeCursorPosition(param)
            expect(focusModeManager.focusCursorMode.focusLine).not.toHaveBeenCalledWith(param)


    describe "toggleFocusMode", ->

        it "should call focusSingleLineModeOff if focusSingleLineMode is activated", ->
            spyOn(focusModeManager.focusSingleLineMode, "off").andCallFake(->)
            focusModeManager.focusSingleLineMode.isActivated = true
            focusModeManager.toggleCursorFocusMode()
            expect(focusModeManager.focusSingleLineMode.off).toHaveBeenCalled()

        it "should call focusShadowModeOff() if isActivated is true", ->
            spyOn(focusModeManager, "focusShadowModeOff").andCallFake(->)
            focusModeManager.focusShadowMode.isActivated = true
            focusModeManager.toggleCursorFocusMode()
            expect(focusModeManager.focusShadowModeOff).toHaveBeenCalled()

        it "should call focusCursorModeOff() when focusCursorMode.isActivated is true", ->
            spyOn(focusModeManager, "focusCursorModeOff").andCallFake(->)
            focusModeManager.focusCursorMode.isActivated = true
            focusModeManager.toggleCursorFocusMode()
            expect(focusModeManager.focusCursorModeOff).toHaveBeenCalled()

        it "should call focusCursorModeOn() when focusCursorMode.isActivated is false", ->
            spyOn(focusModeManager, "focusCursorModeOn").andCallFake(->)
            focusModeManager.focusCursorMode.isActivated = false
            focusModeManager.toggleCursorFocusMode()
            expect(focusModeManager.focusCursorModeOn).toHaveBeenCalled()


    describe "focusCursorModeOn", ->

        it "should call focusCursorMode.on()", ->
            spyOn(focusModeManager.focusCursorMode, "on").andCallFake(->)
            focusModeManager.focusCursorModeOn()
            expect(focusModeManager.focusCursorMode.on).toHaveBeenCalled()

        it "should set cursorEventSubscribers", ->
            cursorEventHandlers = {}
            spyOn(focusModeManager, "registerCursorEventHandlers").andReturn(cursorEventHandlers)
            focusModeManager.focusCursorModeOn()
            expect(focusModeManager.cursorEventSubscribers).toEqual(cursorEventHandlers)


    describe "focusCursorModeOff", ->

        cursorEventSubscribers = { dispose: -> }

        beforeEach ->
            spyOn(cursorEventSubscribers, "dispose").andCallFake(->)
            spyOn(focusModeManager.focusCursorMode, "off").andCallFake(->)
            focusModeManager.cursorEventSubscribers = cursorEventSubscribers

        it "should call focusCursorMode.off()", ->
            focusModeManager.focusCursorModeOff()
            expect(focusModeManager.focusCursorMode.off).toHaveBeenCalled()

        it "should call cursorEventSubscribers.dispose()", ->
            focusModeManager.focusCursorModeOff()
            expect(cursorEventSubscribers.dispose).toHaveBeenCalled()


    describe "toggleFocusSingleLineMode", ->

        it "should call focusCursorModeOff() if focusCursorMode is activated", ->
            spyOn(focusModeManager, "focusCursorModeOff").andCallFake(->)
            focusModeManager.focusCursorMode.isActivated = true
            focusModeManager.toggleFocusSingleLineMode()
            expect(focusModeManager.focusCursorModeOff).toHaveBeenCalled()

        it "should call focusShadowModeOff() if isActivated is true", ->
            spyOn(focusModeManager, "focusShadowModeOff").andCallFake(->)
            focusModeManager.focusShadowMode.isActivated = true
            focusModeManager.toggleFocusSingleLineMode()
            expect(focusModeManager.focusShadowModeOff).toHaveBeenCalled()

        it "should call focusSingleLineMode.off() when focusSingleLineMode.isActivated is true", ->
            spyOn(focusModeManager.focusSingleLineMode, "off").andCallFake(->)
            focusModeManager.focusSingleLineMode.isActivated = true
            focusModeManager.toggleFocusSingleLineMode()
            expect(focusModeManager.focusSingleLineMode.off).toHaveBeenCalled()

        it "should call focusSingleLineMode.on() when focusSingleLineMode.isActivated is false", ->
            spyOn(focusModeManager.focusSingleLineMode, "on").andCallFake(->)
            focusModeManager.focusSingleLineMode.isActivated = false
            focusModeManager.toggleFocusSingleLineMode()
            expect(focusModeManager.focusSingleLineMode.on).toHaveBeenCalled()


    describe "toggleFocusShadowMode", ->

        cursorEventSubscribers = {dispose: ->}

        beforeEach ->
            spyOn(focusModeManager, "registerCursorEventHandlers").andReturn(cursorEventSubscribers)
            spyOn(focusModeManager.focusSingleLineMode, "off").andCallFake(->)
            spyOn(focusModeManager, "focusCursorModeOff").andCallFake(->)
            spyOn(focusModeManager, "focusShadowModeOff").andCallFake(->)
            spyOn(focusModeManager.focusShadowMode, "on").andCallFake(->)

        it "should call focusCursorModeOff() if focusMode is activated", ->
            focusModeManager.focusCursorMode.isActivated = true
            focusModeManager.toggleFocusShadowMode()
            expect(focusModeManager.focusCursorModeOff).toHaveBeenCalled()

        it "should call focusSingleLineMode.off if focusSingleLineMode is activated", ->
            focusModeManager.focusSingleLineMode.isActivated = true
            focusModeManager.toggleFocusShadowMode()
            expect(focusModeManager.focusSingleLineMode.off).toHaveBeenCalled()

        it "should call focusShadowModeOff() when focusShadowMode.isActivated", ->
            focusModeManager.focusShadowMode.isActivated = true
            focusModeManager.toggleFocusShadowMode()
            expect(focusModeManager.focusShadowModeOff).toHaveBeenCalled()

        it "should call focusShadowMode.on() when focusShadowMode.isActivated is false", ->
            focusModeManager.focusSingleLineMode.isActivated = false
            focusModeManager.toggleFocusShadowMode()
            expect(focusModeManager.focusShadowMode.on).toHaveBeenCalled()

        it "should register cursorEventSubscribers when focusShadowMode.isActivated is false", ->
            focusModeManager.focusSingleLineMode.isActivated = false
            focusModeManager.toggleFocusShadowMode()
            expect(focusModeManager.cursorEventSubscribers).toEqual(cursorEventSubscribers)


    describe "focusShadowModeOff", ->

        cursorEventSubscribers = { dispose: -> }

        beforeEach ->
            spyOn(cursorEventSubscribers, "dispose").andCallFake(->)
            spyOn(focusModeManager.focusShadowMode, "off").andCallFake(->)
            focusModeManager.cursorEventSubscribers = cursorEventSubscribers

        it "should call focusShadowMode.off()", ->
            focusModeManager.focusShadowModeOff()
            expect(focusModeManager.focusShadowMode.off).toHaveBeenCalled()

        it "should call cursorEventSubscribers.dispose()", ->
            focusModeManager.focusShadowModeOff()
            expect(cursorEventSubscribers.dispose).toHaveBeenCalled()


    describe "subscribersDispose", ->

        it("should call cursorEventSubscribers dispose if there are cursorEventSubscribers", ->
            subscriptions = { dispose: -> }
            spyOn(focusModeManager, "registerCursorEventHandlers").andReturn(subscriptions)
            spyOn(subscriptions, "dispose")

            # toggle focus mode on (to register subscribers)
            focusModeManager.toggleCursorFocusMode()
            expect(focusModeManager.cursorEventSubscribers).toEqual(subscriptions)

            focusModeManager.subscribersDispose()
            expect(subscriptions.dispose).toHaveBeenCalled()
        )

        it("should call focusShadowMode.dispose()", ->
            spyOn(focusModeManager.focusShadowMode, "dispose").andCallFake(->)
            focusModeManager.subscribersDispose()
            expect(focusModeManager.focusShadowMode.dispose).toHaveBeenCalled()
        )
