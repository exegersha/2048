function MainScene (properties = {} as Object) as Object

    '  This object is passed to the CoreElement constructor at the bottom of this class
    classDefinition = {

        TOSTRING: "<MainScene>"
        msgBus: MessageBus()
        matrixXY: invalid
        aNumber: invalid

        ' Store all the positions available for each reactangle (taken from background image)
        createMatrixXY: function() as Void
            dim matrixXY[4, 4]
            ' first row
            matrixXY[0,0] = {X: 443, Y: 185}
            matrixXY[0,1] = {X: 552, Y: 185}
            matrixXY[0,2] = {X: 661, Y: 185}
            matrixXY[0,3] = {X: 770, Y: 185}
            ' second row
            matrixXY[1,0] = {X: 443, Y: 295}
            matrixXY[1,1] = {X: 552, Y: 295}
            matrixXY[1,2] = {X: 661, Y: 295}
            matrixXY[1,3] = {X: 770, Y: 295}
            ' third row
            matrixXY[2,0] = {X: 443, Y: 405}
            matrixXY[2,1] = {X: 552, Y: 405}
            matrixXY[2,2] = {X: 661, Y: 405}
            matrixXY[2,3] = {X: 770, Y: 405}
            ' fourth row
            matrixXY[3,0] = {X: 443, Y: 515}
            matrixXY[3,1] = {X: 552, Y: 515}
            matrixXY[3,2] = {X: 661, Y: 515}
            matrixXY[3,3] = {X: 770, Y: 515}

            m.matrixXY = matrixXY
        end function

        createUI: function () as Void
            ' Load background image
            bgImage = Image()
            m.addChild(bgImage)
            bgImage.addEventListener({context: m, eventType: "onLoaded", handler: "onImageLoadedHandler"})
            bgImage.addEventListener({context: m, eventType: "onFailed", handler: "onImageLoadFailedHandler"})
            m.bgImage = bgImage
            m.bgImage.load("pkg://images/background.png")

            
            ' Move the style definitions for each number to style utils
            number2_Style = {
                minWidth: 96
                minHeight: 96
                font: StyleUtils().fonts.BROWN_PRO_48_BOLD
                active: {
                    textColour: &h776e65FF
                    backgroundColour: &heee4daFF
                }
                padding: {
                    top: 20
                    left: 30
                }
            }

            ' put a rectanlge in each position on the image-matrix
            aNumber = Button({style: number2_Style})
            aNumber.setText("2")
            aNumber.setXY(m.matrixXY[0,0].X, m.matrixXY[0,0].Y)
            ' position in matrixXY
            aNumber.i = 0
            aNumber.j = 0
            aNumber.setActive()
            m.addChild(aNumber)
            m.aNumber = aNumber

        end function

        onImageLoadedHandler: function(eventObj as Object) as Void
        end function

        onImageLoadFailedHandler: function(eventObj as Object) as Void
            print m.TOSTRING; " onImageLoadFailedHandler"
            m.onBackPressed()
        end function

        tweeningDone: function() as Void
            print m.TOSTRING; " movement done!"
        end function

        onLeftPressed: function() as Void
        end function

        onRightPressed: function() as Void
            aNumber =m.aNumber
            matrixXY = m.matrixXY

            if (aNumber.i < 3)
                if (aNumber.j < 3)
                    aNumber.j = aNumber.j + 1
                else
                    aNumber.j = 0
                    aNumber.i = aNumber.i + 1
                end if
            else
                if (aNumber.j < 3)
                    aNumber.j = aNumber.j + 1
                end if
            end if
            
            i = aNumber.i
            j = aNumber.j
            TweenManager().to(aNumber, 6, { x:matrixXY[i,j].X, y: matrixXY[i,j].Y, onComplete: {destination:m, callback:"tweeningDone"}})

            m.aNumber = aNumber

            ' for i=0 to 3
            '     for j=0 to 3
            '         TweenManager().to(aNumber, 6, { x:matrixXY[i,j].X, y: matrixXY[i,j].Y, onComplete: {destination:m, callback:"tweeningDone"}})
            '     end for
            ' end for
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
            m.createMatrixXY()
            m.createUI()
        end function
    }

    for each property in properties
        classDefinition.AddReplace(property, properties[property])
    end for

    this = CoreElement(classDefinition)

    return this

end function
