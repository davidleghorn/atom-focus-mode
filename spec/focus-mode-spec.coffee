# # Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
# # To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# # or `fdescribe`). Remove the `f` to unfocus the block.

FocusMode = require '../lib/focus-mode'
FocusModeManager = require '../lib/focus-mode-manager'

describe "FocusMode", ->

    focusModePackage = FocusMode

    describe "activate", ->

        it "should create and instance of the FocusModeManager class", ->
            focusModePackage.activate()

            expect(focusModePackage.focusModeManager).not.toBeNull()
            expect(focusModePackage.focusModeManager.constructor).toEqual(FocusModeManager)

        it "should add two focus mode keyboard commands to subscriptions", ->
            focusModePackage.activate()

            expect(focusModePackage.subscriptions).not.toBeNull()
            expect(focusModePackage.subscriptions.disposables.size).toEqual(2)


    describe "when the 'focus-mode:toggle' event is triggered", ->

        it "should call focus mode method toggleFocusMode()", ->
            workspaceElement = atom.views.getView(atom.workspace)
            focusModePackage = FocusMode
            focusModePackage.activate()

            spyOn(focusModePackage.focusModeManager, "toggleFocusMode")

            atom.commands.dispatch workspaceElement, 'focus-mode:toggle'

            expect(focusModePackage.focusModeManager.toggleFocusMode).toHaveBeenCalled()


    describe "when the 'focus-mode:toggle-single-line' event is triggered", ->

        it "should call focus mode method toggleFocusModeSingleLine()", ->
            workspaceElement = atom.views.getView(atom.workspace)
            focusModePackage = FocusMode
            focusModePackage.activate()

            spyOn(focusModePackage.focusModeManager, "toggleFocusModeSingleLine")

            atom.commands.dispatch workspaceElement, 'focus-mode:toggle-single-line'

            expect(focusModePackage.focusModeManager.toggleFocusModeSingleLine).toHaveBeenCalled()


    describe "deactivate", ->

        it "should dispose subscribers", ->
            focusModePackage = FocusMode
            focusModePackage.activate()

            spyOn(focusModePackage.subscriptions, "dispose")
            spyOn(focusModePackage.focusModeManager, "subscribersDispose")

            focusModePackage.deactivate()

            expect(focusModePackage.subscriptions.dispose).toHaveBeenCalled()
            expect(focusModePackage.focusModeManager.subscribersDispose).toHaveBeenCalled()
