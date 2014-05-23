' UTILITY METHODS

function focusTestsSetup() as Object
    globalAA = getGLobalAA()
	globalAA.focusMgr = FocusManager()
	globalAA.testsParams = {
		sceneA : CoreElement({id:"sceneA"})
		sceneB : CoreElement({id:"sceneB"})
		sceneC : CoreElement({id:"sceneC"})
		sceneD : CoreElement({id:"sceneD"})

	}
	return globalAA
end function

function focusTestsTearDown() as Void
	globalAA = getGLobalAA()
	globalAA.focusMgr.focusStack.clear()
	globalAA.focusMgr = invalid
	globalAA.testsParams = invalid
	Stage().focus = invalid
end function


' TESTS START HERE
' test SetFocus
function testSetFocusNoParams(t as Object) as Void
	globalAA = focusTestsSetup()

	globalAA.focusMgr.setFocus()

	' Passing no arguments should not change the history stack
	t.assertEqual(globalAA.focusMgr.focusStack.count(), 0)

	focusTestsTearDown()
end function

function testSetFocus(t as Object) as Void
	globalAA = focusTestsSetup()
	aScene = globalAA.testsParams.sceneA

	globalAA.focusMgr.setFocus(aScene)

	' Passing aScene should push item to the history stack and set the focus to it
	t.assertEqual(globalAA.focusMgr.focusStack.count(), 1)
	t.assertEqual(Stage().focus, aScene)

	focusTestsTearDown()
end function

function testSetFocusTwice(t as Object) as Void
	globalAA = focusTestsSetup()
	sceneA = globalAA.testsParams.sceneA
	sceneB = globalAA.testsParams.sceneB

	globalAA.focusMgr.setFocus(sceneA)
	globalAA.focusMgr.setFocus(sceneB)

	' pushing 2 scenes should increase the history size by 2 and set the focus to the top scene in stack
	t.assertEqual(globalAA.focusMgr.focusStack.count(), 2)
	t.assertEqual(Stage().focus, sceneB)

	focusTestsTearDown()
end function

' test setPreviousFocus
function testSetPreviousFocusWithEmptyStack(t as Object) as Void
	globalAA = focusTestsSetup()

	globalAA.focusMgr.setPreviousFocus()

	' restore focus with an empty stack should keep the stack empty and the focus not being set
	t.assertEqual(globalAA.focusMgr.focusStack.count(), 0)
	t.assertInvalid(Stage().focus)

	focusTestsTearDown()
end function

function testSetPreviousFocusWithOneSceneInStack(t as Object) as Void
	globalAA = focusTestsSetup()
	sceneA = globalAA.testsParams.sceneA

	globalAA.focusMgr.setFocus(sceneA)

	globalAA.focusMgr.setPreviousFocus()

	' restore focus with only 1 scene in stack should empty the stack and invalidate the focus
	t.assertEqual(globalAA.focusMgr.focusStack.count(), 0)
	t.assertInvalid(Stage().focus)

	focusTestsTearDown()
end function

function testSetPreviousFocusWithMoreThanOneSceneInStack(t as Object) as Void
	globalAA = focusTestsSetup()
	sceneA = globalAA.testsParams.sceneA
	sceneB = globalAA.testsParams.sceneB

	globalAA.focusMgr.setFocus(sceneA)
	globalAA.focusMgr.setFocus(sceneB)

	globalAA.focusMgr.setPreviousFocus()

	' restore focus with 2 (or more) scenes in stack should remove the top scene and set the focus to the previous scene in stack
	t.assertEqual(globalAA.focusMgr.focusStack.count(), 1)
	t.assertNotInvalid(Stage().focus)
	t.assertEqual(Stage().focus.id, sceneA.id)

	focusTestsTearDown()
end function

' test restoreFocus
function testRestoreFocusToSceneNoParams(t as Object) as Void
	globalAA = focusTestsSetup()

	globalAA.focusMgr.restoreFocusToScene()

	' Passing no arguments should not change the history stack
	t.assertEqual(globalAA.focusMgr.focusStack.count(), 0)

	focusTestsTearDown()
end function

function testRestoreFocusSingleWithEmptyStack(t as Object) as Void
	globalAA = focusTestsSetup()
	aScene = globalAA.testsParams.sceneA

	globalAA.focusMgr.restoreFocusToScene(aScene)

	' Passing a scene with an empty focus stack should not change the history stack and the focus reamins not set
	t.assertEqual(globalAA.focusMgr.focusStack.count(), 0)
	t.assertInvalid(Stage().focus)

	focusTestsTearDown()
end function

function testRestoreFocusSingleWithOneSceneInStack(t as Object) as Void
	globalAA = focusTestsSetup()
	aScene = globalAA.testsParams.sceneA
	globalAA.focusMgr.setFocus(aScene)

	globalAA.focusMgr.restoreFocusToScene(aScene)

	' Restoring the focus to the unique scene in stack should not change the history stack and keep the focus on the same scene
	t.assertEqual(globalAA.focusMgr.focusStack.count(), 1)
	t.assertEqual(Stage().focus, aScene)

	focusTestsTearDown()
end function

function testRestoreFocusSingleWithTwoScenesInStack(t as Object) as Void
	globalAA = focusTestsSetup()
	sceneA = globalAA.testsParams.sceneA
	sceneB = globalAA.testsParams.sceneB
	globalAA.focusMgr.setFocus(sceneA)
	globalAA.focusMgr.setFocus(sceneB)

	globalAA.focusMgr.restoreFocusToScene(sceneA)

	' Restoring the focus to the 1st scene in stack should decrease the history stack and set the focus to that scene
	t.assertEqual(globalAA.focusMgr.focusStack.count(), 1)
	t.assertEqual(Stage().focus, sceneA)

	focusTestsTearDown()
end function

function testRestoreFocusTwiceWithTwoScenesInStack(t as Object) as Void
	globalAA = focusTestsSetup()
	sceneA = globalAA.testsParams.sceneA
	sceneB = globalAA.testsParams.sceneB
	globalAA.focusMgr.setFocus(sceneA)
	globalAA.focusMgr.setFocus(sceneB)

	globalAA.focusMgr.restoreFocusToScene(sceneA)
	globalAA.focusMgr.restoreFocusToScene(sceneA)

	' Restoring the focus to the 1st scene in stack should decrease the history stack and set the focus to that scene, no matter how many times restoreFocus gets called
	t.assertEqual(globalAA.focusMgr.focusStack.count(), 1)
	t.assertEqual(Stage().focus, sceneA)

	focusTestsTearDown()
end function


'TODO COMPLETE test form removeFromStack
' test removeFromStack
function testRemoveFromEmptyStackNoParams(t as Object) as Void
	globalAA = focusTestsSetup()

	globalAA.focusMgr.removeFromStack()

	' Remove from stack history with no parameter should not change the stack or the focus
	t.assertEqual(globalAA.focusMgr.focusStack.count(), 0)
	t.assertInvalid(Stage().focus)

	focusTestsTearDown()
end function

function testRemoveFromNonEmptyStackNoParams(t as Object) as Void
	globalAA = focusTestsSetup()
	sceneA = globalAA.testsParams.sceneA
	globalAA.focusMgr.setFocus(sceneA)

	globalAA.focusMgr.removeFromStack()

	' Remove from stack history with no parameter should not change the stack or the focus
	t.assertEqual(globalAA.focusMgr.focusStack.count(), 1)
	t.assertEqual(Stage().focus, sceneA)

	focusTestsTearDown()
end function

function testRemoveFromStackSingleWithEmptyStack(t as Object) as Void
	globalAA = focusTestsSetup()
	aScene = globalAA.testsParams.sceneA

	globalAA.focusMgr.removeFromStack(aScene)

	' Removing a scene from an empty focus stack should not change the history stack and the focus reamins not set
	t.assertEqual(globalAA.focusMgr.focusStack.count(), 0)
	t.assertInvalid(Stage().focus)

	focusTestsTearDown()
end function

function testRemoveFromStackSingleWithOneSceneInStack(t as Object) as Void
	globalAA = focusTestsSetup()
	aScene = globalAA.testsParams.sceneA
	globalAA.focusMgr.setFocus(aScene)

	globalAA.focusMgr.removeFromStack(aScene)

	' Removing the unique scene from the focus stack should empty the history stack and invalidate the focus
	t.assertEqual(globalAA.focusMgr.focusStack.count(), 0)
	t.assertInvalid(Stage().focus)

	focusTestsTearDown()
end function

function testRemoveFromStackSingleWithTwoScenesInStack(t as Object) as Void
	globalAA = focusTestsSetup()
	sceneA = globalAA.testsParams.sceneA
	sceneB = globalAA.testsParams.sceneB
	globalAA.focusMgr.setFocus(sceneA)
	globalAA.focusMgr.setFocus(sceneB)

	globalAA.focusMgr.removeFromStack(sceneA)

	' Removing the base scene in stack from the focus stack should decrease the history stack by 1 and keep the same top scene in focus
	t.assertEqual(globalAA.focusMgr.focusStack.count(), 1)
	t.assertEqual(Stage().focus, sceneB)

	focusTestsTearDown()
end function

function testRemoveFromStackSingleTopWithTwoScenesInStack(t as Object) as Void
	globalAA = focusTestsSetup()
	sceneA = globalAA.testsParams.sceneA
	sceneB = globalAA.testsParams.sceneB
	globalAA.focusMgr.setFocus(sceneA)
	globalAA.focusMgr.setFocus(sceneB)

	globalAA.focusMgr.removeFromStack(sceneB)

	' Removing the top scene in stack from the focus stack should decrease the history stack by 1 and set the focus to the base scene
	t.assertEqual(globalAA.focusMgr.focusStack.count(), 1)
	t.assertEqual(Stage().focus, sceneA)

	focusTestsTearDown()
end function


function testRemoveFromStackTwiceWithTwoScenesInStack(t as Object) as Void
	globalAA = focusTestsSetup()
	sceneA = globalAA.testsParams.sceneA
	sceneB = globalAA.testsParams.sceneB
	globalAA.focusMgr.setFocus(sceneA)
	globalAA.focusMgr.setFocus(sceneB)

	globalAA.focusMgr.removeFromStack(sceneA)
	globalAA.focusMgr.removeFromStack(sceneB)

	' Removing all the scenes from the focus stack should empty the history stack and invalidate the focus
	t.assertEqual(globalAA.focusMgr.focusStack.count(), 0)
	t.assertInvalid(Stage().focus)

	focusTestsTearDown()
end function
