function GameManager (properties = {} as Object) as Object

    '  This object is passed to the CoreElement constructor at the bottom of this class
    classDefinition = {

        TOSTRING: "<GameManager>"
        ' These two constants define the game matrix size for all the game (every other object should refer to these constants)
        MATRIX_ROWS: 3
        MATRIX_COLS: 3
        ANIMATION_FRAMES: 6
        WIN_NUMBER: "2048"

        _score: invalid         ' stores the score of the current game
        _bestScore: invalid     ' init this value from the registry on Init()
        scoreTxt: invalid       ' Textfield()
        bestScoreTxt: invalid   ' Textfield()
        configMngr: ConfigManager()

        msgBus: MessageBus()
        
        matrixXY: invalid
        ' Stores the Number objects present in each position of the game matrix
        gameMatrix: invalid
        'This is replaces at the bottom of this class from param properties
        parentContainer: invalid

        ' delay timer to allow move animation to finish
        delayedTimer: invalid
        DELAY_IN_MSEC: 200 'milliseconds


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

        ' Initialize the matrix that stores with INVALID entries
        ' It's used for e.g. for the game matrix that stores the Number objects present in each position of the game matrix
        ' Also used to create temporal matrix to mark new JOIN numbers during a key-press move.
        createEmptyMatrix: function() as Object
            matrix_rows = m.MATRIX_ROWS
            matrix_cols = m.MATRIX_COLS
            dim gameMatrix[matrix_rows, matrix_cols]
            for i=0 to matrix_rows
                for j=0 to matrix_cols
                    gameMatrix[i,j] = invalid
                end for
            end for
            return gameMatrix
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

        ' Returns a string representig gameMaxtrix rows from left-to-right and top-down
        gameMatrixToString: function() as String
            gameMatrix = m.gameMatrix
            matrix_rows = m.MATRIX_ROWS
            matrix_cols = m.MATRIX_COLS
            str = ""
            for i=0 to matrix_rows
                for j=0 to matrix_cols
                    value = gameMatrix[i,j]
                    ' Extract only value from Number object to print-out
                    if (gameMatrix[i,j] <> invalid)
                        str = str + gameMatrix[i,j].value + ","
                    else
                        str = str + "null" + ","
                    end if
                end for
            end for
            print m.TOSTRING; " gameMatrixToString="; str
            return str
        end function

        ' Restore gameMaxtrix from string parameter, builds the matrix rows from left-to-right and top-down and updates the UI
        updateGameMatrixFromString: function (strGameMatrix as String) as Void
            listGameMatrix = strGameMatrix.Tokenize(",")
            listGameMatrix.resetIndex()

            matrix_rows = m.MATRIX_ROWS
            matrix_cols = m.MATRIX_COLS
            for i=0 to matrix_rows
                for j=0 to matrix_cols
                    listEntry = listGameMatrix.getIndex()
                    if (listEntry <> "null")
                        m.createNumber(listEntry, i, j)
                    end if
                end for
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
            matrix_rows = m.MATRIX_ROWS + 1
            matrix_cols = m.MATRIX_COLS + 1
            ' RND(<integer>) returns a number betwee 1 and <integer> inclusive (this case is RND(4)={1..4})
            i = RND(matrix_rows) - 1
            j = RND(matrix_cols) - 1
            gameMatrix = m.gameMatrix
            while (gameMatrix[i,j] <> invalid)
                i = RND(matrix_rows) - 1
                j = RND(matrix_cols) - 1
                print m.TOSTRING; " generating random cell: i="; i; " j="; j
            end while
            print m.TOSTRING; " random cell DONE!  i="; i; " j="; j
            
            freeCell = {row: i, col: j}
            return freeCell
        end function

        ' itearte the gameMatrix to dispose any number it contains
        disposeCurrentGame: function() as Void
            gameMatrix = m.gameMatrix
            matrix_rows = m.MATRIX_ROWS
            matrix_cols = m.MATRIX_COLS
            for i=0 to matrix_rows
                for j=0 to matrix_cols
                    if (gameMatrix[i,j] <> invalid)
                        gameMatrix[i,j].dispose()
                        gameMatrix[i,j] = invalid
                        RunGarbageCollector()
                    end if
                end for                
            end for
        end function

        startNewGame: function() as Void
            m.delayedTimer.reset()

            ' reset score
            m._score = 0
            ' persist _bestScore in case it was changed during this game
            m.saveScore()
            m.updateScore()

            ' dispose any number in UI from previous game and reset the gameMatrix
            m.disposeCurrentGame()
            ' persist empty gameMatrix
            m.saveGameMatrix()

            ' m.dumpGameMatrix()

            ' create 1st Number 2 in random position
            freeCell = m.getRandomFreeCell()
            m.createNumber("2", freeCell.row, freeCell.col)
        end function

        moveLeft: function() as Void
            print m.TOSTRING; " move left BEGIN"
            'stores temporarly the new numbers created from JOINTS to avoid join them again within the same move process
            newJoinNumber = m.createEmptyMatrix()

            gameMatrix = m.gameMatrix
            cols = m.MATRIX_COLS
            rows = m.MATRIX_ROWS
            moveDone = false 'flag to indicate if there's at least 1 number changing position in this move
            for k=1 to cols ' repeat the sweep 3 times
                for j=1 to cols
                    for i=0 to rows
                        if (gameMatrix[i,j] <> invalid)
                            if (gameMatrix[i, j-1] = invalid) ' if cell on the left is empty move Number
                                m.moveNumber(gameMatrix[i,j], i, j-1)
                                moveDone = true
                            else if (gameMatrix[i, j-1].value = gameMatrix[i,j].value AND newJoinNumber[i, j-1]=invalid AND newJoinNumber[i,j]=invalid)
                                'update score before disposing numbers
                                m.updateScore((gameMatrix[i,j].value).toint() * 2)
                                ' if cell on the left has same Number do a JOIN
                                m.joinNumber(gameMatrix[i,j], i, j-1)
                                ' mark target position as a new JOIN to avoid JOINING again during this move
                                newJoinNumber[i, j-1] = true
                                moveDone = true
                            end if
                        end if
                    end for
                end for
            end for
            m.gameMatrix = gameMatrix

            newJoinNumber = invalid

            m.updateGameStatus(moveDone)
            m.dumpGameMatrix()

            print m.TOSTRING; " move left END"
        end function

        moveDown: function() as Void
            print m.TOSTRING; " move down BEGIN"
            'stores temporarly the new numbers created from JOINTS to avoid join them again within the same move process
            newJoinNumber = m.createEmptyMatrix()

            gameMatrix = m.gameMatrix
            cols = m.MATRIX_COLS
            rows = m.MATRIX_ROWS
            moveDone = false 'flag to indicate if there's at least 1 number changing position in this move
            for k=1 to cols ' repeat the sweep 3 times
                for i=rows-1 to 0 step -1
                    for j=0 to cols
                        if (gameMatrix[i,j] <> invalid)
                            if (gameMatrix[i+1, j] = invalid) ' if cell below is empty move Number
                                m.moveNumber(gameMatrix[i,j], i+1, j)
                                moveDone = true
                            else if (gameMatrix[i+1, j].value = gameMatrix[i,j].value AND newJoinNumber[i+1, j]=invalid AND newJoinNumber[i,j]=invalid)
                                'update score before disposing numbers
                                m.updateScore((gameMatrix[i,j].value).toint() * 2)
                                ' if cell below has same Number do a JOIN
                                m.joinNumber(gameMatrix[i,j], i+1, j)
                                ' mark target position as a new JOIN to avoid JOINING again during this move
                                newJoinNumber[i+1, j] = true
                                moveDone = true
                            end if
                        end if
                    end for
                end for
            end for
            m.gameMatrix = gameMatrix
            
            newJoinNumber = invalid

            m.updateGameStatus(moveDone)
            m.dumpGameMatrix()

            print m.TOSTRING; " move down END"
        end function

        moveUp: function() as Void
            print m.TOSTRING; " move up BEGIN"
            'stores temporarly the new numbers created from JOINTS to avoid join them again within the same move process
            newJoinNumber = m.createEmptyMatrix()

            gameMatrix = m.gameMatrix
            cols = m.MATRIX_COLS
            rows = m.MATRIX_ROWS
            moveDone = false 'flag to indicate if there's at least 1 number changing position in this move
            for k=1 to cols ' repeat the sweep 3 times
                for i=1 to rows
                    for j=0 to cols
                        if (gameMatrix[i,j] <> invalid)
                            if (gameMatrix[i-1, j] = invalid) ' if cell above is empty move Number
                                m.moveNumber(gameMatrix[i,j], i-1, j)
                                moveDone = true
                            else if (gameMatrix[i-1, j].value = gameMatrix[i,j].value AND newJoinNumber[i-1, j]=invalid AND newJoinNumber[i,j]=invalid)
                                'update score before disposing numbers
                                m.updateScore((gameMatrix[i,j].value).toint() * 2)
                                ' if cell on above has same Number do a JOIN
                                m.joinNumber(gameMatrix[i,j], i-1, j)
                                ' mark target position as a new JOIN to avoid JOINING again during this move
                                newJoinNumber[i-1, j] = true
                                moveDone = true
                            end if
                        end if
                    end for
                end for
            end for
            m.gameMatrix = gameMatrix
            
            newJoinNumber = invalid

            m.updateGameStatus(moveDone)
            m.dumpGameMatrix()

            print m.TOSTRING; " move up END"
        end function

        ' sweep in this order, 3 times to complete the full barrier movement:
        ' -> 3rd column top-down (i.e. [0,2] [1,2] [2,2] [3,2])
        ' -> 2nd column top-down (i.e. [0,1] [1,1] [2,1] [3,1])
        ' -> 1st column top-down (i.e. [0,0] [1,0] [2,0] [3,0])
        moveRight: function() as Void
            print m.TOSTRING; " move right BEGIN"
            'stores temporarly the new numbers created from JOINTS to avoid join them again within the same move process
            newJoinNumber = m.createEmptyMatrix()

            gameMatrix = m.gameMatrix
            cols = m.MATRIX_COLS
            rows = m.MATRIX_ROWS
            moveDone = false 'flag to indicate if there's at least 1 number changing position in this move
            for k=1 to cols ' repeat the sweep 3 times
                for j=cols - 1 to 0 step -1
                    for i=0 to rows
                        if (gameMatrix[i,j] <> invalid)
                            if (gameMatrix[i, j+1] = invalid) ' if cell on the right is empty move Number
                                m.moveNumber(gameMatrix[i,j], i, j+1)
                                moveDone = true
                            else if (gameMatrix[i, j+1].value = gameMatrix[i,j].value AND newJoinNumber[i, j+1]=invalid AND newJoinNumber[i,j]=invalid)
                                'update score before disposing numbers
                                m.updateScore((gameMatrix[i,j].value).toint() * 2)
                                ' if cell on the right has same Number do a JOIN
                                m.joinNumber(gameMatrix[i,j], i, j+1)
                                ' mark target position as a new JOIN to avoid JOINING again during this move
                                newJoinNumber[i, j+1] = true
                                moveDone = true
                            end if
                        end if
                    end for
                end for
            end for
            m.gameMatrix = gameMatrix
            
            newJoinNumber = invalid

            m.updateGameStatus(moveDone)
            m.dumpGameMatrix()

            print m.TOSTRING; " move right END"
        end function

        ' check if GAME OVERs or WIN and updates _bestSscore in registry and UI accordingly
        updateGameStatus: function(moveDoneBefore as Boolean) as Void
            if (m.hasWinnerNumber())
                ' show YOU WIN screen! (show "*" to start new game)
                print m.TOSTRING; " YOU WIN !!! ***************************"
            else if (m.isGameOver())
                ' show GAME OVER screen (show "*" to start new game)
                print m.TOSTRING; " GAME OVER :( **************************"
            else if (moveDoneBefore)
                ' create next new number after the delay time to allow move animations to finish
                delayedTimer = m.delayedTimer
                delayedTimer.reset()
                delayedTimer.start()
                m.delayedTimer = delayedTimer
            end if
        end function

        onTimerCompleteHandler: function(eventObj as Object)
            ' print m.TOSTRING; " onTimerCompleteHandler: "
            m.delayedTimer.stop()
            
            ' Insert a new number in random position
            freeCell = m.getRandomFreeCell()
            m.createNumber("2", freeCell.row, freeCell.col)
        end function

        hasWinnerNumber: function() as Boolean
            gameMatrix = m.gameMatrix
            winNumber = m.WIN_NUMBER
            rows = m.MATRIX_ROWS
            cols = m.MATRIX_COLS
            for i=0 to rows
                for j=0 to cols
                    if (gameMatrix[i,j] <> invalid AND gameMatrix[i,j].value = winNumber)
                        return true
                    end if
                end for
            end for
            return false
        end function

        isGameOver: function() as Boolean
            gameMatrix = m.gameMatrix
            rows = m.MATRIX_ROWS
            cols = m.MATRIX_COLS
            for i=0 to rows
                for j=0 to cols
                    if (gameMatrix[i,j] = invalid)
                        'there is a free cell so it's possible to make a move
                        return false
                    else
                        ' Check if current number can join current one its 4 neighbors
                        current = gameMatrix[i,j].value

                        ' Upper neighbor
                        if (i > 0 AND gameMatrix[i-1,j] <> invalid AND gameMatrix[i-1,j].value = current)
                            return false
                        end if
                        ' Left neighbor
                        if (j > 0 AND gameMatrix[i,j-1] <> invalid AND gameMatrix[i,j-1].value = current)
                            return false
                        end if
                        ' Right neighbor
                        if (j < cols AND gameMatrix[i,j+1] <> invalid AND gameMatrix[i,j+1].value = current)
                            return false
                        end if
                        ' Bottom neighbor
                        if (i < rows AND gameMatrix[i+1,j] <> invalid AND gameMatrix[i+1,j].value = current)
                            return false
                        end if

                    end if
                end for
            end for
            return true
        end function

        ' updates _score & _bestScore variables and UI
        updateScore: function(addToScore=0 as Integer) as Void
            _score = m._score
            _bestScore = m._bestScore

            _score = _score + addToScore
            if (_bestScore < _score)
                _bestScore = _score
            end if

            m.scoreTxt.setText(StringFromNumber(_score))
            m.bestScoreTxt.setText(StringFromNumber(_bestScore))

            m._score = _score
            m._bestScore = _bestScore
            ' print m.TOSTRING; "updateScore: m._score=";m._score; " m._bestScore=";m._bestScore
        end function

        ' Retrieves _scrore & _bestScore from registry AND creates UI
        restoreScore: function() as Void
            currentConfig = m.configMngr.getConfig()
            _score = currentConfig.SCORE
            _bestScore = currentConfig.BEST_SCORE
            
            m._score = (_score).toint()
            m._bestScore = (_bestScore).toint()


            ' Creates UI for SCORE and BEST
            style = StyleUtils().score
            scoreTxt = TextField()
            scoreTxt.setText(_score)
            scoreTxt.setXY(style.X, style.Y)
            scoreTxt.colour = style.colour
            scoreTxt.setFont(style.font)
            m.parentContainer.addChild(scoreTxt)
            m.scoreTxt = scoreTxt

            style = StyleUtils().bestScore
            bestScoreTxt = TextField()
            bestScoreTxt.setText(_bestScore)
            bestScoreTxt.setXY(style.X, style.Y)
            bestScoreTxt.colour = style.colour
            bestScoreTxt.setFont(style.font)
            m.parentContainer.addChild(bestScoreTxt)
            m.bestScoreTxt = bestScoreTxt
        end function

        ' persist _scrore & _bestScore in registry
        saveScore: function() as Void
            newConfig = {}
            newConfig.SCORE = StringFromNumber(m._score)
            newConfig.BEST_SCORE = StringFromNumber(m._bestScore)
            m.configMngr.writeConfig(newConfig)

            print m.TOSTRING; "saveScore: m._score=";m._score; " m._bestScore=";m._bestScore
        end function

        ' persist gameMatrix in registry
        saveGameMatrix:function() as Void
            newConfig = {}
            newConfig.GAME_MATRIX = m.gameMatrixToString()
            m.configMngr.writeConfig(newConfig)
        end function

        ' restore gameMatrix from the registry if there's any, otherwise returns an empty gameMatrix
        restoreGameMatrix: function() as Void
            currentConfig = m.configMngr.getConfig()            
            m.gameMatrix = m.createEmptyMatrix()
            if (currentConfig.GAME_MATRIX <> invalid AND currentConfig.GAME_MATRIX <> "")
                m.updateGameMatrixFromString(currentConfig.GAME_MATRIX)
            end if
            ' m.dumpGameMatrix()
        end function

        ' moveNumberDone: function() as Void
        '     print m.TOSTRING; " movement done!"
        ' end function

        ' move aNumber to the target row,col in the gameMatrix
        moveNumber: function(aNumber as Object, targetRow as Integer, targetCol as Integer) as Void
            matrixXY = m.matrixXY
            TweenManager().to(aNumber, m.ANIMATION_FRAMES, { x:matrixXY[targetRow,targetCol].X, y: matrixXY[targetRow,targetCol].Y }) ', onComplete: {destination:m, callback:"moveNumberDone"}})

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
            ' print "*** jointValue="; jointValue

            m.moveNumber(aNumber, targetRow, targetCol)

            ' print "*** after animation"

            oldTargetNumber.dispose()
            oldTargetNumber = invalid
            aNumber.dispose()
            aNumber = invalid
            RunGarbageCollector()

            ' print "*** after dispose"
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
            TweenManager().to(aNumber, 6, { x:matrixXY[i,j].X, y: matrixXY[i,j].Y, onComplete: {destination:m, callback:"moveNumberDone"}})

            m.aNumber = aNumber

            ' for i=0 to 3
            '     for j=0 to 3
            '         TweenManager().to(aNumber, 6, { x:matrixXY[i,j].X, y: matrixXY[i,j].Y, onComplete: {destination:m, callback:"moveNumberDone"}})
            '     end for
            ' end for
        end function

        exitGame: function() as Void
            m.delayedTimer.reset()
            m.saveScore()
            m.saveGameMatrix()
        end function

        ' delay timer to allow move animation to finish
        initTimer: function() as Void
            delayedTimer = Timer("", m.DELAY_IN_MSEC, 1)
            delayedTimer.addEventListener({
                context: m,
                eventType: "onTimerComplete",
                handler: "onTimerCompleteHandler"
            })
            m.delayedTimer = delayedTimer
        end function

        init: function (properties = {} as Object) as Void
            m.createMatrixXY()
            m.initTimer()
        end function
    }

    for each property in properties
        classDefinition.AddReplace(property, properties[property])
    end for

    this = classDefinition
    this.init(properties)

    return this

end function
