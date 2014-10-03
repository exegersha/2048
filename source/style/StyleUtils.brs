function StyleUtils()

    if (m.styleUtils = invalid)

        theme = NowTVTheme()
        aaFonts = AppFonts()

        m.styleUtils = {

        	fonts: aaFonts

' ////////////////////////////
'           SETTINGS VIEW
' ////////////////////////////
            settingsView: {
                bgColour: theme.GREEN
            }

            score: {
                X: 699 'calulated from background.png
                Y: 70  'calulated from background.png
                colour: &hebe1d8FF
                font : aafonts.BROWN_PRO_21_BOLD
            }

            bestScore: {
                X: 793  'calulated from background.png
                Y: 70   'calulated from background.png
                colour: &hebe1d8FF
                font : aafonts.BROWN_PRO_21_BOLD
            }

        }

    end if

    return m.styleUtils

end function
