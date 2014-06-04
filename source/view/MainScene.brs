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

            ' create 1st Number 2 in random position
            freeCell = gameMgr.getRandomFreeCell()
            gameMgr.createNumber("2", freeCell.row, freeCell.col)

            ' create 2nd Number 2 in random position
            freeCell = gameMgr.getRandomFreeCell()
            gameMgr.createNumber("2", freeCell.row, freeCell.col)

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


        onLeftPressed: function() as Void
        end function

        onRightPressed: function() as Void
           ' m.gameMgr.moveRight(m.number2)
        end function

        onUpPressed: function() as Void
        end function

        onBackPressed: function() as Void
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

        init: function (properties = {} as Object) as Void
            m.createUI()
        end function
    }

    for each property in properties
        classDefinition.AddReplace(property, properties[property])
    end for

    this = CoreElement(classDefinition)

    return this

end function
