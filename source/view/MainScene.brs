function MainScene (properties = {} as Object) as Object

    '  This object is passed to the CoreElement constructor at the bottom of this class
    classDefinition = {

        TOSTRING: "<MainScene>"
        msgBus: MessageBus()
        gameMgr: GameManager({
                parentContainer: properties.parentContainer
                })
        ' number2: invalid

        createUI: function () as Void
            ' Load background image
            bgImage = Image()
            m.addChild(bgImage)
            bgImage.addEventListener({context: m, eventType: "onLoaded", handler: "onImageLoadedHandler"})
            bgImage.addEventListener({context: m, eventType: "onFailed", handler: "onImageLoadFailedHandler"})
            m.bgImage = bgImage
            m.bgImage.load("pkg://images/background.png")


            gameMgr = m.gameMgr
            gameMgr.restoreGameMatrix()
            gameMgr.restoreScore()

            ' create 1st Number 2 in random position
            ' freeCell = gameMgr.getRandomFreeCell()
            ' gameMgr.createNumber("2", freeCell.row, freeCell.col)

            ' gameMgr.createNumber("2", 0, 2)
            ' gameMgr.createNumber("2", 0, 3)
            ' gameMgr.createNumber("2", 0, 1)
            ' gameMgr.createNumber("2", 0, 0)

            ' gameMgr.createNumber("2", 1, 2)
            ' gameMgr.createNumber("2", 1, 3)
            ' gameMgr.createNumber("2", 1, 1)e
            ' gameMgr.createNumber("2", 1, 0)

            ' gameMgr.createNumber("2", 2, 2)
            ' gameMgr.createNumber("2", 2, 3)
            ' gameMgr.createNumber("2", 2, 1)
            ' gameMgr.createNumber("2", 2, 0)

            ' gameMgr.createNumber("2", 3, 2)
            ' gameMgr.createNumber("2", 3, 3)
            ' gameMgr.createNumber("2", 3, 1)
            ' gameMgr.createNumber("2", 3, 0)



            ' create 2nd Number 2 in random position
            ' freeCell = gameMgr.getRandomFreeCell()
            ' gameMgr.createNumber("2", freeCell.row, freeCell.col)


            ' initialize game to analize UI/Style
            ' m.number2 = gameMgr.createNumber("2", 0, 0)
            ' gameMgr.createNumber("4", 0, 1)
            ' gameMgr.createNumber("8", 0, 2)
            ' gameMgr.createNumber("16", 0, 3)

            ' gameMgr.createNumber("32", 1, 0)
            ' gameMgr.createNumber("64", 1, 1)
            ' gameMgr.createNumber("128", 1, 2)
            ' gameMgr.createNumber("256", 1, 3)

            ' gameMgr.createNumber("512", 2, 0)
            ' gameMgr.createNumber("64", 2, 1)
            ' gameMgr.createNumber("2048", 2, 2)

            ' gameMgr.createNumber("16", 3, 0)
            ' gameMgr.createNumber("1024", 3, 1)
            ' gameMgr.createNumber("32", 3, 2)

            ' gameMgr.dumpGameMatrix()
        end function

        onImageLoadedHandler: function(eventObj as Object) as Void
        end function

        onImageLoadFailedHandler: function(eventObj as Object) as Void
            print m.TOSTRING; " onImageLoadFailedHandler"
            m.onBackPressed()
        end function

        onInfoPressed: function() as Void
            m.bgImage.load("pkg://images/background.png")
            m.gameMgr.startNewGame()
        end function

        onLeftPressed: function() as Void
            gameMgr = m.gameMgr
            if (gameMgr.allowNewMove)
                ' Deny new moves until this flag is reset when adding a new tile to the game OR move update is done.
                gameMgr.allowNewMove = False

                gameMgr.moveLeft()
            end if
        end function

        onRightPressed: function() as Void
            gameMgr = m.gameMgr
            if (gameMgr.allowNewMove)
                ' Deny new moves until this flag is reset when adding a new tile to the game OR move update is done.
                gameMgr.allowNewMove = False

                gameMgr.moveRight()
            end if
        end function

        onUpPressed: function() as Void
            gameMgr = m.gameMgr
            if (gameMgr.allowNewMove)
                ' Deny new moves until this flag is reset when adding a new tile to the game OR move update is done.
                gameMgr.allowNewMove = False

                gameMgr.moveUp()
            end if
        end function

        onDownPressed: function() as Void
            gameMgr = m.gameMgr
            if (gameMgr.allowNewMove)
                ' Deny new moves until this flag is reset when adding a new tile to the game OR move update is done.
                gameMgr.allowNewMove = False

                gameMgr.moveDown()
            end if
        end function

        onBackPressed: function() as Void
            m.gameMgr.exitGame()

            ' Close the app!
            m.msgBus.dispatchEvent(Event({
                eventType: "closeApp",
                target: m
            }))

            m.dispose()
        end function

        onFocusIn: function (eventObj as Object) as Void
        end function

        onFocusOut: function (eventObj as Object) as Void
        end function

        onGameOverHandler: function(eventObj as Object) as Void
            m.bgImage.load("pkg://images/background_game_over.png")
        end function

        onWinHandler: function(eventObj as Object) as Void
            m.bgImage.load("pkg://images/background_win.png")
        end function

        registerListeners: function () as Void
            m.msgBus.addEventListener({
                eventType: "onGameOver",
                handler: "onGameOverHandler",
                context: m
            })
            m.msgBus.addEventListener({
                eventType: "onWin",
                handler: "onWinHandler",
                context: m
            })
        end function

        init: function (properties = {} as Object) as Void
            m.registerListeners()
            m.createUI()
        end function
    }

    for each property in properties
        classDefinition.AddReplace(property, properties[property])
    end for

    this = CoreElement(classDefinition)

    return this

end function
