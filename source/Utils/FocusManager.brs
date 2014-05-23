function FocusManager() as Object

    if (m.focusManager = invalid )
        m.focusManager = {

            TOSTRING: "<FocusManager>"
            focusStack: []

            ' Push a scene into the stack and set the focus to it
            setFocus: function (aScene = invalid as Object) as Void
                if (aScene <> invalid)
                    m.focusStack.push(aScene)
                    Stage().setFocus(aScene)
                end if
            end function

            ' Restore focus to previous scene in stack (if there's any previous)
            setPreviousFocus: function () as Object
                sceneInFocus = invalid

                ' remove top scene from stack and remove its focus
                topScene = m.focusStack.pop()
                if (topScene <> invalid and topScene.id <> invalid)
                    Stage().removeFocus(topScene.id)
                end if

                ' set focus to top scene in current stack
                if (m.focusStack.count() > 0)
                    sceneInFocus = m.focusStack.peek()
                    Stage().setFocus(sceneInFocus)
                end if
                return sceneInFocus
            end function

            ' reset the history stack.
            ' This should be called along with setFocus() immediately after to reset the focus stack + Add Unit Test
            clearFocusStack: function() as Void
                m.focusStack.clear()
            end function

            ' Restore the focus to the specified scene IF it's already in stack, updating stack history.
            restoreFocusToScene: function(aScene=invalid as Object) as Void
                if (aScene <> invalid AND m.isInStack(aScene))
                    m.unstackTill(aScene)
                    Stage().setFocus(aScene)
                end if
            end function

            ' Remove the specified scene from the stack history
            removeFromStack: function(aScene=invalid as Object) as Void
                if (aScene <> invalid AND m.isInStack(aScene))
                    ' If aScene is in focus (top element), the focus is restored to previous scene in stack.
                    if (AssociativeArrayEqual(m.focusStack.peek(), aScene))
                        m.setPreviousFocus()
                    else
                        auxStack = []
                        for i=0 to m.focusStack.count()-1
                            if (NOT AssociativeArrayEqual(m.focusStack[i], aScene))
                                auxStack.push(m.focusStack[i])
                            end if
                        end for
                        m.focusStack = auxStack
                    end if
                end if
            end function

            ' PRIVATE METHODS
            isInStack: function(aScene as Object) as Boolean
                for i=0 to m.focusStack.count()-1
                    if (AssociativeArrayEqual(m.focusStack[i], aScene))
                        return true
                    end if
                end for
                return false
            end function

            unstackTill: function(aScene as Object) as Void
                while (NOT AssociativeArrayEqual(m.focusStack.peek(), aScene) AND m.focusStack.count()>0)
                    m.focusStack.pop()
                end while
            end function


        }
    end if

    return m.focusManager

end function
