#Include 'Totvs.Ch'

User Function EQTST090()

Local aUser := {}
Local nLin  := 0
Local nGru  := 0

aUser := ALLUSERS()

For nLin := 1 To Len( aUser )
	For nGru := 1 To Len( aUser[nLin][1][10] )
		If AllTrim( aUser[nLin][1][10][nGru] ) $ "000030|000015|000017|000062|000018|000069|000076|000088"
			ConOut("@@@@ -> " + aUser[nLin][1][1] + " - " + aUser[nLin][1][2])
		EndIf
	Next
Next

Return