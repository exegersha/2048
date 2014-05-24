function MainScene (properties = {} as Object) as Object

    '  This object is passed to the CoreElement constructor at the bottom of this class
    classDefinition = {

        TOSTRING: "<MainScene>"
        msgBus: MessageBus()
        matrixXY: invalid
        number2: invalid

        ' Store all the positions available for each reactangle (calculated from background image)
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
            matrixXY[3,0] = {X: 443, Y: 514}
            matrixXY[3,1] = {X: 552, Y: 514}
            matrixXY[3,2] = {X: 661, Y: 514}
            matrixXY[3,3] = {X: 770, Y: 514}

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

            number2 = Number({
                parentContainer: m
                x: m.matrixXY[0,0].X
                y: m.matrixXY[0,0].Y
                initProperties: {
                    value: "2"
                    i: 0
                    j: 0
                }
            })
            m.number2 = number2

            
            number4 = Number({
                parentContainer: m
                x: m.matrixXY[0,1].X
                y: m.matrixXY[0,1].Y
                initProperties: {
                    value: "4"
                    i: 0
                    j: 1
                }
            })
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
            number2 =m.number2
            matrixXY = m.matrixXY

            if (number2.i < 3)
                if (number2.j < 3)
                    number2.j = number2.j + 1
                else
                    number2.j = 0
                    number2.i = number2.i + 1
                end if
            else
                if (number2.j < 3)
                    number2.j = number2.j + 1
                end if
            end if
            
            i = number2.i
            j = number2.j
            TweenManager().to(number2, 6, { x:matrixXY[i,j].X, y: matrixXY[i,j].Y, onComplete: {destination:m, callback:"tweeningDone"}})

            m.number2 = number2

            ' for i=0 to 3
            '     for j=0 to 3
            '         TweenManager().to(number2, 6, { x:matrixXY[i,j].X, y: matrixXY[i,j].Y, onComplete: {destination:m, callback:"tweeningDone"}})
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
