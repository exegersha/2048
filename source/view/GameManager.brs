function GameManager (properties = {} as Object) as Object

    '  This object is passed to the CoreElement constructor at the bottom of this class
    classDefinition = {

        TOSTRING: "<GameManager>"
        ' These two constants define the game matrix size for all the game (every other object should refer to these constants)
        MATRIX_ROWS: 3
        MATRIX_COLS: 3
        ANIMATION_FRAMES: 6

        msgBus: MessageBus()
        matrixXY: invalid
        ' Stores the Number objects present in each position of the game matrix
        gameMatrix: invalid
        'This is replaces at the bottom of this class from param properties
        parentContainer: invalid


        ' Store all the positions available for each reactangle (calculated from background image)
        createMatrixXY: function() as Void
            dim matrixXY[m.MATRIX_ROWS, m.MATRIX_COLS]
            ' first row
            matrixXY[0,0] = {X: 442, Y: 185}
            matrixXY[0,1] = {X: 551, Y: 185}
            matrixXY[0,2] = {X: 660, Y: 185}
            matrixXY[0,3] = {X: 770, Y: 185}
            ' second row
            matrixXY[1,0] = {X: 442, Y: 295}
            matrixXY[1,1] = {X: 551, Y: 295}
            matrixXY[1,2] = {X: 660, Y: 295}
            matrixXY[1,3] = {X: 770, Y: 295}
            ' third row
            matrixXY[2,0] = {X: 442, Y: 405}
            matrixXY[2,1] = {X: 551, Y: 405}
            matrixXY[2,2] = {X: 660, Y: 405}
            matrixXY[2,3] = {X: 770, Y: 405}
            ' fourth row
            matrixXY[3,0] = {X: 442, Y: 512}
            matrixXY[3,1] = {X: 551, Y: 512}
            matrixXY[3,2] = {X: 660, Y: 512}
            matrixXY[3,3] = {X: 770, Y: 512}

            m.matrixXY = matrixXY
        end function

        ' Initialize the matrix that stores the Number objects present in each position of the game matrix
        createGameMatrix: function() as Void
            matrix_rows = m.MATRIX_ROWS
            matrix_cols = m.MATRIX_COLS
            dim gameMatrix[matrix_rows, matrix_cols]
            for i=0 to matrix_rows
                for j=0 to matrix_cols
                    gameMatrix[i,j] = invalid
                end for
            end for
            m.gameMatrix = gameMatrix
        end function

        ' print out the gameMatrix content showing the numbers in each position - Helper for dev/debug
        dumpGameMatrix: function() as Void
            gameMatrix = m.gameMatrix
            matrix_rows = m.MATRIX_ROWS
            matrix_cols = m.MATRIX_COLS
            for i=0 to matrix_rows
                print "Row "; i
                for j=0 to matrix_cols
                    value = gameMatrix[i,j]
                    ' Extract only value from Number object to print-out
                    if (value <> invalid)
                        value = gameMatrix[i,j].value
                    end if

                    print "[";i;",";j;"]="; value
                end for
                print Chr(10)
            end for
        end function

        ' Ceates the number <valueStr> in the [rowPosition, columnPsotion] of the matrix AND save it in gameMatrix
        createNumber: function (valueStr as String, rowPosition as Integer, columnPosition as Integer) as Object
            aNumber = Number({
                parentContainer: m.parentContainer
                x: m.matrixXY[rowPosition,columnPosition].X
                y: m.matrixXY[rowPosition,columnPosition].Y
                initProperties: {
                    value: valueStr
                    i: rowPosition
                    j: columnPosition
                }
            })

            ' Add the number object to the gameMatrix for later reference
            m.gameMatrix[rowPosition, columnPosition] = aNumber
            return aNumber
        end function

        ' looks for a free cell in the gameMatrix randomly and returns the [row, col] position
        getRandomFreeCell: function() as Object
            matrix_rows = m.MATRIX_ROWS
            matrix_cols = m.MATRIX_COLS
            i = RND(matrix_rows) - 1
            j = RND(matrix_cols) - 1
            gameMatrix = m.gameMatrix
            while (gameMatrix[i,j] <> invalid)
                i = RND(matrix_rows) - 1
                j = RND(matrix_cols) - 1
            end while

            freeCell = {row: i, col: j}
            return freeCell
        end function

        tweeningDone: function() as Void
            print m.TOSTRING; " movement done!"
        end function

        onLeftPressed: function() as Void
        end function

        onRightPressed: function() as Void
        end function

        onUpPressed: function() as Void
        end function

        ' sweep in this order, 3 times to complete the full barrier movement:
        ' -> 3rd column top-down (i.e. [0,2] [1,2] [2,2] [3,2])
        ' -> 2nd column top-down (i.e. [0,1] [1,1] [2,1] [3,1])
        ' -> 1st column top-down (i.e. [0,0] [1,0] [2,0] [3,0])
        moveRight: function() as Void
            gameMatrix = m.gameMatrix
            cols = m.MATRIX_COLS - 1
            rows = m.MATRIX_ROWS
            for k=0 to cols ' repeat the sweep 3 times
                for j=cols to 0 step -1
                    for i=0 to rows
                        if (gameMatrix[i,j] <> invalid)
                            if (gameMatrix[i,j + 1] = invalid)
                                ' if cell on the right is empty move Number
                                m.moveNumber(gameMatrix[i,j], i, j+1)
                            else if (gameMatrix[i,j + 1].value = gameMatrix[i,j].value)
                                ' if cell on the right has same Number do a JOIN
                                m.joinNumber(gameMatrix[i,j], i, j+1)
                            end if
                        end if
                    end for
                end for
            end for
        end function

        ' move aNumber to the target row,col in the gameMatrix
        moveNumber: function(aNumber as Object, targetRow as Integer, targetCol as Integer) as Void
            matrixXY = m.matrixXY
            TweenManager().to(aNumber, m.ANIMATION_FRAMES, { x:matrixXY[targetRow,targetCol].X, y: matrixXY[targetRow,targetCol].Y, onComplete: {destination:m, callback:"tweeningDone"}})

            ' Update gameMatrix and Number object:
            gameMatrix = m.gameMatrix
            ' make origin position available again
            gameMatrix[aNumber.i, aNumber.j] = invalid
            ' update Number position and matrixGame[targetRow, targetCol]
            aNumber.i = targetRow
            aNumber.j = targetCol
            gameMatrix[targetRow, targetCol] = aNumber
            m.gameMatrix = gameMatrix
        end function

        ' move aNumber to the target row,col in the gameMatrix and joins it with the current number in the target position
        joinNumber: function(aNumber as Object, targetRow as Integer, targetCol as Integer) as Void
            oldTargetNumber = m.gameMatrix[targetRow, targetCol]
            jointValue = StringFromInt((aNumber.value).toint() * 2)
            print "*** jointValue="; jointValue

            m.moveNumber(aNumber, targetRow, targetCol)

            print "*** after animation"

            oldTargetNumber.dispose()
            oldTargetNumber = invalid
            aNumber.dispose()
            aNumber = invalid

            print "*** after dispose"
            aNumber = m.createNumber(jointValue, targetRow, targetCol)
        end function

        moveNumberRightOneCell: function(aNumber as Object) as Void
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

        onFocusIn: function (eventObj as Object) as Void
        end function

        onFocusOut: function (eventObj as Object) as Void
        end function

        init: function (properties = {} as Object) as Void
            m.createGameMatrix()
            m.createMatrixXY()
        end function
    }

    for each property in properties
        classDefinition.AddReplace(property, properties[property])
    end for

    this = classDefinition
    this.init(properties)

    return this

end function
