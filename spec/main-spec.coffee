
focusModePackage = require '../lib/main'
FocusModeManager = require '../lib/focus-mode-manager'

describe "Main", ->

    describe "activate", ->

        it "should create and instance of the FocusModeManager class", ->
            focusModePackage.activate()

            expect(focusModePackage.focusModeManager).not.toBeNull()
            expect(focusModePackage.focusModeManager.constructor).toEqual(FocusModeManager)

        it "should add four focus mode keyboard commands to subscriptions", ->
            focusModePackage.activate()

            expect(focusModePackage.subscriptions).not.toBeNull()
            expect(focusModePackage.subscriptions.disposables.size).toEqual(6)


    describe "when the 'atom-focus-mode:toggle-cursor-focus' event is triggered", ->

        it "should call focus mode method toggleCursorFocusMode()", ->
            workspaceElement = atom.views.getView(atom.workspace)
            focusModePackage.activate()

            spyOn(focusModePackage.focusModeManager, "toggleCursorFocusMode")

            atom.commands.dispatch workspaceElement, 'atom-focus-mode:toggle-cursor-focus'

            expect(focusModePackage.focusModeManager.toggleCursorFocusMode).toHaveBeenCalled()


    describe "when the 'atom-focus-mode:toggle-single-line-focus' event is triggered", ->

        it "should call focus mode method toggleFocusSingleLineMode()", ->
            workspaceElement = atom.views.getView(atom.workspace)
            focusModePackage.activate()

            spyOn(focusModePackage.focusModeManager, "toggleFocusSingleLineMode")

            atom.commands.dispatch workspaceElement, 'atom-focus-mode:toggle-single-line-focus'

            expect(focusModePackage.focusModeManager.toggleFocusSingleLineMode).toHaveBeenCalled()


    describe "when the 'atom-focus-mode:toggle-shadow-focus' event is triggered", ->

        it "should call focus mode method toggleFocusShadowMode()", ->
            workspaceElement = atom.views.getView(atom.workspace)
            focusModePackage.activate()

            spyOn(focusModePackage.focusModeManager, "toggleFocusShadowMode")

            atom.commands.dispatch workspaceElement, 'atom-focus-mode:toggle-shadow-focus'

            expect(focusModePackage.focusModeManager.toggleFocusShadowMode).toHaveBeenCalled()


    describe "deactivate", ->

        it "should dispose subscribers", ->
            focusModePackage.activate()

            spyOn(focusModePackage.subscriptions, "dispose")
            spyOn(focusModePackage.focusModeManager, "subscribersDispose")

            focusModePackage.deactivate()

            expect(focusModePackage.subscriptions.dispose).toHaveBeenCalled()
            expect(focusModePackage.focusModeManager.subscribersDispose).toHaveBeenCalled()
