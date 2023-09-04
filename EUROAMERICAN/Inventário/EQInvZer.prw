#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

User Function EQInvZer()

Local aZerar := {}
Local nLin   := 0

If AllTrim( cEmpAnt ) == "08"
	aAdd( aZerar, {"0200.001.55    ","07","176021    ","Q03P00000      ",2})
	aAdd( aZerar, {"0500.001.55    ","07","177013    ","Q03P00000      ",40})
	aAdd( aZerar, {"0600.101.40    ","07","005379    ","Q03P00000      ",108})
	aAdd( aZerar, {"0650.500.50    ","07","176743    ","Q03P00000      ",9})
	aAdd( aZerar, {"0680.600.50    ","07","009530    ","Q03P00000      ",7})
	aAdd( aZerar, {"0710.001.15    ","07","005835    ","Q03P00000      ",61})
	aAdd( aZerar, {"0710.028.23    ","07","          ","Q03P00000      ",1})
	aAdd( aZerar, {"0710.034.23    ","07","          ","Q03P00000      ",1})
	aAdd( aZerar, {"0710.037.23    ","07","          ","Q03P00000      ",1})
	aAdd( aZerar, {"0710.042.23    ","07","          ","Q03P00000      ",1})
	aAdd( aZerar, {"0710.060.23    ","07","          ","Q03P00000      ",1})
	aAdd( aZerar, {"0710.061.23    ","07","          ","Q03P00000      ",1})
	aAdd( aZerar, {"0710.072.23    ","07","          ","Q03P00000      ",1})
	aAdd( aZerar, {"0720.029.23    ","07","          ","Q03P00000      ",1})
	aAdd( aZerar, {"0720.031.23    ","07","          ","Q03P00000      ",1})
	aAdd( aZerar, {"0720.035.23    ","07","          ","Q03P00000      ",1})
	aAdd( aZerar, {"0720.050.23    ","07","          ","Q03P00000      ",1})
	aAdd( aZerar, {"0720.072.55    ","07","          ","Q03P00000      ",4})
	aAdd( aZerar, {"0720.195.23    ","07","          ","Q03P00000      ",8})
	aAdd( aZerar, {"0720.196.23    ","07","          ","Q03P00000      ",2})
	aAdd( aZerar, {"0730.072.26    ","07","          ","Q03P00000      ",1})
	aAdd( aZerar, {"0750.001.55    ","07","          ","Q03P00000      ",1})
	aAdd( aZerar, {"0830.032.30    ","07","152046    ","Q03P00000      ",46})
	aAdd( aZerar, {"0840.081.30    ","07","152401    ","Q03P00000      ",35})
	aAdd( aZerar, {"2450.001.55    ","07","015707    ","VIRTUAL        ",8})
	aAdd( aZerar, {"2450.001.55    ","08","012107    ","Q01-A094-04    ",19})
	aAdd( aZerar, {"2450.001.55    ","08","015585    ","Q01-O025-02    ",32})
	aAdd( aZerar, {"2450.001.55    ","08","015585    ","Q01-O026-01    ",16})
	aAdd( aZerar, {"5300.001.23    ","07","176437    ","Q03P00000      ",10})
	aAdd( aZerar, {"5300.001.50    ","07","177025    ","Q03P00000      ",43})
	aAdd( aZerar, {"5300.002.50    ","07","          ","Q03P00000      ",2})
	aAdd( aZerar, {"5300.082.50    ","08","014966    ","Q01-A090-00    ",2})
	aAdd( aZerar, {"6200.001.50    ","07","013892    ","Q03P00000      ",5})
	aAdd( aZerar, {"6400.011.04    ","08","014592    ","Q01-A090-00    ",6})
	aAdd( aZerar, {"7000.001.04    ","07","176332    ","Q03P00000      ",4})
	aAdd( aZerar, {"7000.032.23    ","07","011043    ","Q03P00000      ",9})
	aAdd( aZerar, {"7000.400.23    ","07","011045    ","Q03P00000      ",36})
	aAdd( aZerar, {"7000.700.23    ","07","009245    ","Q03P00000      ",19})
	aAdd( aZerar, {"7200.070.23    ","07","006078    ","Q03P00000      ",10})
	aAdd( aZerar, {"7300.200.23    ","07","          ","Q03P00000      ",2})
	aAdd( aZerar, {"7800.033.23    ","07","164140    ","Q03P00000      ",37})
	aAdd( aZerar, {"8000.039.23    ","07","005971    ","Q03P00000      ",6})
	aAdd( aZerar, {"8000.040.55    ","07","          ","Q03P00000      ",1})
	aAdd( aZerar, {"8300.001.55    ","07","008673    ","Q03P00000      ",92})
	aAdd( aZerar, {"8300.039.55    ","07","011377    ","Q03P00000      ",41})
	aAdd( aZerar, {"8600.039.55    ","07","          ","Q03P00000      ",3})
	aAdd( aZerar, {"9100.001.23    ","07","176364    ","Q03P00000      ",3})
	aAdd( aZerar, {"9200.145.50    ","07","014211    ","Q03P00000      ",3})
	aAdd( aZerar, {"9200.145.50    ","08","176753    ","Q01-A090-00    ",10})
	aAdd( aZerar, {"9500.001.04    ","08","011858    ","Q01-A090-01    ",2})
	aAdd( aZerar, {"MP.0429        ","07","          ","VIRTUAL        ",1975})
ElseIf AllTrim( cEmpAnt ) == "02"
	aAdd( aZerar, {"116.09.01000.R2","08","174945    ","",1000})
	aAdd( aZerar, {"MP.0324        ","07","          ","",207})
	aAdd( aZerar, {"MP.0620        ","07","          ","",1860})
	aAdd( aZerar, {"PI342          ","04","175613    ","",200})
EndIf

For nLin := 1 To Len( aZerar )
	dbSelectArea("SB1")
	dbSetOrder(1)
	If SB1->( dbSeek( xFilial("SB1") + aZerar[nLin][01] ) )
		RecLock("SB7", .T.)
		SB7->B7_FILIAL  := xFilial("SB7")
		SB7->B7_DOC     := "FABIO"
		SB7->B7_COD     := aZerar[nLin][01]
		SB7->B7_TIPO    := SB1->B1_TIPO
		SB7->B7_QUANT   := aZerar[nLin][05]
		SB7->B7_QTSEGUM := ConvUM( SB1->B1_COD, aZerar[nLin][05], 0, 2)
		SB7->B7_ESCOLHA := "S"
		SB7->B7_STATUS  := "1"
		SB7->B7_LOCAL   := aZerar[nLin][02]
		If SB1->B1_RASTRO <> "N"
			If !Empty( aZerar[nLin][03] )
				SB7->B7_LOTECTL := aZerar[nLin][03]
			Else
				cLote := ""

				cQuery := "SELECT TOP 1 B8_LOTECTL " + CRLF
				cQuery += "FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
				cQuery += "WHERE B8_FILIAL = '" + xFilial("SB8") + "' " + CRLF
				cQuery += "AND B8_PRODUTO = '" + AllTrim( aZerar[nLin][01] ) + "' " + CRLF
				cQuery += "AND B8_LOCAL = '" + AllTrim( aZerar[nLin][02] ) + "' " + CRLF
				cQuery += "AND B8_LOTECTL <> '' " + CRLF
				cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF
				cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
	
				TCQuery cQuery New Alias "TMPLOTE"
				dbSelectArea("TMPLOTE")
				dbGoTop()
	
				If !TMPLOTE->( Eof() )
					cLote := TMPLOTE->B8_LOTECTL
				EndIf
				
				TMPLOTE->( dbCloseArea() )
				
				If Empty( cLote )
					cQuery := "SELECT TOP 1 B8_LOTECTL, B8_LOCAL " + CRLF
					cQuery += "FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
					cQuery += "WHERE B8_FILIAL = '" + xFilial("SB8") + "' " + CRLF
					cQuery += "AND B8_PRODUTO = '" + AllTrim( aZerar[nLin][01] ) + "' " + CRLF
					cQuery += "AND B8_LOTECTL <> '' " + CRLF
					cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF
					cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
		
					TCQuery cQuery New Alias "TMPLOTE"
					dbSelectArea("TMPLOTE")
					dbGoTop()
		
					If !TMPLOTE->( Eof() )
						cLote := TMPLOTE->B8_LOTECTL
						dbSelectArea("SB8")
						dbSetOrder(1)
						RecLock( "SB8", .T.)
							SB8->B8_FILIAL  := xFilial("SB8")
							SB8->B8_PRODUTO := aZerar[nLin][01]
							SB8->B8_LOCAL   := aZerar[nLin][02]
							SB8->B8_LOTECTL := TMPLOTE->B8_LOTECTL
							SB8->B8_SALDO   := 0
							SB8->B8_EMPENHO := 0
						MsUnLock()
					EndIf
					
					TMPLOTE->( dbCloseArea() )
				EndIf

				SB7->B7_LOTECTL := cLote
			EndIf
		EndIf
		If AllTrim( SB1->B1_LOCALIZ ) == "S"
			SB7->B7_LOCALIZ := aZerar[nLin][04]
		EndIf
		SB7->B7_CONTAGE := "001"
		SB7->B7_ORIGEM  := "MATA270"
		SB7->B7_DATA    := STOD("20200731")
		MsUnLock()
	EndIf
Next

Return
