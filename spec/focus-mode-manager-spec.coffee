
FocusModeManager = require '../lib/focus-mode-manager'
FocusMode = require '../lib/focus-mode'
FocusShadowMode = require '../lib/focus-mode-shadow'
FocusModeSingleLine = require '../lib/focus-mode-single-line'

describe "FocusModeManager", ->

    focusModeManager = null

    beforeEach ->
        focusModeManager = new FocusModeManager()

    describe "constructor", ->

        it "should initialise properties with expected values", ->
            expect(focusModeManager.cursorEventSubscribers).toEqual(null)
            expect(focusModeManager.focusMode).toBeDefined()
            expect(focusModeManager.focusShadowMode).toBeDefined()
            expect(focusModeManager.focusModeSingleLine).toBeDefined()

        it "should set focusMode property to a FocusMode instance", ->
            # To test we have a FocusMode instance we check the object has some
            # properties/methods unique to a focusMode instance
            expect(focusModeManager.focusMode.focusModeMarkersCache).toBeDefined()
            expect(focusModeManager.focusMode.cacheFocusModeMarker).toBeDefined()

        it "should set focusShadowMode property to a FocusShadowMode instance", ->
            # To test we have a FocusShadowMode instance we check the object has some
            # properties/methods unique to a FocusShadowMode instance
            expect(focusModeManager.focusShadowMode.focusShadowMarkerCache).toBeDefined()
            expect(focusModeManager.focusShadowMode.focusModeShadowBodyClassName).toBeDefined()
            expect(focusModeManager.focusShadowMode.createShadowModeMarker).toBeDefined()

        it "should set focusShadowMode property to a focusModeSingleLine instance", ->
            # To test we have a focusModeSingleLine instance we check the object has some
            # the properties/methods expected on a focusModeSingleLine instance
            expect(focusModeManager.focusModeSingleLine.isActivated).toBeDefined()
            expect(focusModeManager.focusModeSingleLine.on).toBeDefined()
            expect(focusModeManager.focusModeSingleLine.off).toBeDefined()
            # and that it does not have properties unique to focusMode and focusShadowMode instances
            expect(focusModeManager.focusModeSingleLine.focusModeMarkersCache).not.toBeDefined()
            expect(focusModeManager.focusModeSingleLine.focusShadowMarkerCache).not.toBeDefined()


    describe "didAddCursor", ->

        it "should call focusMode.focusLine() if focusMode.isActivated is true", ->
            cursor = {}
            focusModeManager.focusMode.isActivated = true
            spyOn(focusModeManager.focusMode, "focusLine")
            focusModeManager.didAddCursor(cursor)
            expect(focusModeManager.focusMode.focusLine).toHaveBeenCalledWith(cursor)


        it "should not call focusMode.focusLine() if focusMode.isActivated is false", ->
            cursor = {}
            focusModeManager.focusMode.isActivated = false
            spyOn(focusModeManager.focusMode, "focusLine")
            focusModeManager.didAddCursor(cursor)
            expect(focusModeManager.focusMode.focusLine).not.toHaveBeenCalledWith(cursor)


    describe "didChangeCursorPosition", ->

        it "should call focusMode.focusLine if focusMode.isActivated is true", ->
            param = {cursor: {}}
            focusModeManager.focusMode.isActivated = true
            spyOn(focusModeManager.focusMode, "focusLine")
            focusModeManager.didChangeCursorPosition(param)
            expect(focusModeManager.focusMode.focusLine).toHaveBeenCalledWith(param.cursor)

        it "should not call focusMode.focusLine if focusMode.isActivated is false", ->
            param = {cursor: {}}
            focusModeManager.focusMode.isActivated = false
            spyOn(focusModeManager.focusMode, "focusLine")
            focusModeManager.didChangeCursorPosition(param)
            expect(focusModeManager.focusMode.focusLine).not.toHaveBeenCalledWith(param)


    describe "toggleFocusMode", ->

        it "should call focusModeSingleLineOff if focusModeSingleLine is activated", ->
            spyOn(focusModeManager.focusModeSingleLine, "off").andCallFake(->)
            focusModeManager.focusModeSingleLine.isActivated = true
            focusModeManager.toggleFocusMode()
            expect(focusModeManager.focusModeSingleLine.off).toHaveBeenCalled()

        it "should call focusModeShadowOff() if isActivated is true", ->
            spyOn(focusModeManager, "focusModeShadowOff").andCallFake(->)
            focusModeManager.focusShadowMode.isActivated = true
            focusModeManager.toggleFocusMode()
            expect(focusModeManager.focusModeShadowOff).toHaveBeenCalled()

        it "should call focusModeOff() when focusModeOff.isActivated is true", ->
            spyOn(focusModeManager, "focusModeOff").andCallFake(->)
            focusModeManager.focusMode.isActivated = true
            focusModeManager.toggleFocusMode()
            expect(focusModeManager.focusModeOff).toHaveBeenCalled()

        it "should call focusModeOn() when focusModeOff.isActivated is false", ->
            spyOn(focusModeManager, "focusModeOn").andCallFake(->)
            focusModeManager.focusMode.isActivated = false
            focusModeManager.toggleFocusMode()
            expect(focusModeManager.focusModeOn).toHaveBeenCalled()


    describe "focusModeOn", ->

        it "should call focusMode.on()", ->
            spyOn(focusModeManager.focusMode, "on").andCallFake(->)
            focusModeManager.focusModeOn()
            expect(focusModeManager.focusMode.on).toHaveBeenCalled()

        it "should set cursorEventSubscribers", ->
            cursorEventHandlers = {}
            spyOn(focusModeManager, "registerCursorEventHandlers").andReturn(cursorEventHandlers)
            focusModeManager.focusModeOn()
            expect(focusModeManager.cursorEventSubscribers).toEqual(cursorEventHandlers)


    describe "focusModeOff", ->

        cursorEventSubscribers = { dispose: -> }

        beforeEach ->
            spyOn(cursorEventSubscribers, "dispose").andCallFake(->)
            spyOn(focusModeManager.focusMode, "off").andCallFake(->)
            focusModeManager.cursorEventSubscribers = cursorEventSubscribers

        it "should call focusMode.off()", ->
            focusModeManager.focusModeOff()
            expect(focusModeManager.focusMode.off).toHaveBeenCalled()

        it "should call cursorEventSubscribers.dispose()", ->
            focusModeManager.focusModeOff()
            expect(cursorEventSubscribers.dispose).toHaveBeenCalled()


    describe "toggleFocusModeSingleLine", ->

        it "should call focusModeOff() if focusMode is activated", ->
            spyOn(focusModeManager, "focusModeOff").andCallFake(->)
            focusModeManager.focusMode.isActivated = true
            focusModeManager.toggleFocusModeSingleLine()
            expect(focusModeManager.focusModeOff).toHaveBeenCalled()

        it "should call focusModeShadowOff() if isActivated is true", ->
            spyOn(focusModeManager, "focusModeShadowOff").andCallFake(->)
            focusModeManager.focusShadowMode.isActivated = true
            focusModeManager.toggleFocusModeSingleLine()
            expect(focusModeManager.focusModeShadowOff).toHaveBeenCalled()

        it "should call focusModeSingleLine.off() when focusModeSingleLine.isActivated is true", ->
            spyOn(focusModeManager.focusModeSingleLine, "off").andCallFake(->)
            focusModeManager.focusModeSingleLine.isActivated = true
            focusModeManager.toggleFocusModeSingleLine()
            expect(focusModeManager.focusModeSingleLine.off).toHaveBeenCalled()

        it "should call focusModeSingleLine.on() when focusModeSingleLine.isActivated is false", ->
            spyOn(focusModeManager.focusModeSingleLine, "on").andCallFake(->)
            focusModeManager.focusModeSingleLine.isActivated = false
            focusModeManager.toggleFocusModeSingleLine()
            expect(focusModeManager.focusModeSingleLine.on).toHaveBeenCalled()


    describe "toggleFocusShadowMode", ->

        cursorEventSubscribers = {dispose: ->}

        beforeEach ->
            spyOn(focusModeManager, "registerCursorEventHandlers").andReturn(cursorEventSubscribers)
            spyOn(focusModeManager.focusModeSingleLine, "off").andCallFake(->)
            spyOn(focusModeManager, "focusModeOff").andCallFake(->)
            spyOn(focusModeManager, "focusModeShadowOff").andCallFake(->)
            spyOn(focusModeManager.focusShadowMode, "on").andCallFake(->)

        it "should call focusModeOff() if focusMode is activated", ->
            focusModeManager.focusMode.isActivated = true
            focusModeManager.toggleFocusShadowMode()
            expect(focusModeManager.focusModeOff).toHaveBeenCalled()

        it "should call focusModeSingleLineOff if focusModeSingleLine is activated", ->
            focusModeManager.focusModeSingleLine.isActivated = true
            focusModeManager.toggleFocusShadowMode()
            expect(focusModeManager.focusModeSingleLine.off).toHaveBeenCalled()

        it "should call focusModeShadowOff() when focusShadowMode.isActivated", ->
            focusModeManager.focusShadowMode.isActivated = true
            focusModeManager.toggleFocusShadowMode()
            expect(focusModeManager.focusModeShadowOff).toHaveBeenCalled()

        it "should call focusShadowMode.on() when focusShadowMode.isActivated is false", ->
            focusModeManager.focusModeSingleLine.isActivated = false
            focusModeManager.toggleFocusShadowMode()
            expect(focusModeManager.focusShadowMode.on).toHaveBeenCalled()

        it "should register cursorEventSubscribers when focusShadowMode.isActivated is false", ->
            focusModeManager.focusModeSingleLine.isActivated = false
            focusModeManager.toggleFocusShadowMode()
            expect(focusModeManager.cursorEventSubscribers).toEqual(cursorEventSubscribers)


    describe "focusModeShadowOff", ->

        cursorEventSubscribers = { dispose: -> }

        beforeEach ->
            spyOn(cursorEventSubscribers, "dispose").andCallFake(->)
            spyOn(focusModeManager.focusShadowMode, "off").andCallFake(->)
            focusModeManager.cursorEventSubscribers = cursorEventSubscribers

        it "should call focusShadowMode.off()", ->
            focusModeManager.focusModeShadowOff()
            expect(focusModeManager.focusShadowMode.off).toHaveBeenCalled()

        it "should call cursorEventSubscribers.dispose()", ->
            focusModeManager.focusModeShadowOff()
            expect(cursorEventSubscribers.dispose).toHaveBeenCalled()


    describe "subscribersDispose", ->

        it("should call cursorEventSubscribers dispose if there are cursorEventSubscribers", ->
            subscriptions = { dispose: -> }
            spyOn(focusModeManager, "registerCursorEventHandlers").andReturn(subscriptions)
            spyOn(subscriptions, "dispose")

            # toggle focus mode on (to register subscribers)
            focusModeManager.toggleFocusMode()
            expect(focusModeManager.cursorEventSubscribers).toEqual(subscriptions)

            focusModeManager.subscribersDispose()
            expect(subscriptions.dispose).toHaveBeenCalled()
        )

        it("should call focusShadowMode.dispose()", ->
            spyOn(focusModeManager.focusShadowMode, "dispose").andCallFake(->)
            focusModeManager.subscribersDispose()
            expect(focusModeManager.focusShadowMode.dispose).toHaveBeenCalled()
        )
