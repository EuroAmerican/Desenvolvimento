#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

// PE após geração da alçada

User Function MT120F()

Local cChave  := ParamIxb
Local cQuery  := ""
Local cQueryA := ""
Local aArea   := GetArea()

dbSelectArea("SC7")
dbSetOrder(1)
If SC7->( dbSeek( cChave ) )
	If SC7->C7_TIPO == 1 // Pedido de Compras...
		// Se liberado ver se há pendência no SCR e corrige se necessário...
		If AllTrim( SC7->C7_CONAPRO ) == "L"
			cQuery := "SELECT COUNT(*) AS CONTA " + CRLF
			cQuery += "FROM " + RetSqlName("SCR") + " AS SCR WITH (NOLOCK) " + CRLF
			cQuery += "WHERE CR_FILIAL = '" + xFilial("SC7") + "' " + CRLF
			cQuery += "AND CR_TIPO = 'PC' " + CRLF
			cQuery += "AND CR_NUM = '" + SC7->C7_NUM + "' " + CRLF
			cQuery += "AND CR_STATUS <> '03' " + CRLF
			cQuery += "AND SCR.D_E_L_E_T_ = ' ' " + CRLF
	
			TCQuery cQuery New Alias "TMPSCR"
			dbSelectArea("TMPSCR")
			dbGoTop()
	
			If !TMPSCR->( Eof() )
				If TMPSCR->CONTA > 0
					cQuery := "UPDATE " + RetSqlName("SC7") + " SET C7_CONAPRO = 'B' " + CRLF
					cQuery += "WHERE C7_FILIAL = '" + xFilial("SC7") + "' " + CRLF
					cQuery += "AND C7_NUM = '" + SC7->C7_NUM + "' " + CRLF
					cQuery += "AND C7_APROV <> '' " + CRLF
					cQuery += "AND C7_QUANT > C7_QUJE " + CRLF
					cQuery += "AND C7_ENCER <> 'E' " + CRLF
					cQuery += "AND C7_RESIDUO = '' " + CRLF
					cQuery += "AND D_E_L_E_T_ = ' ' " + CRLF
	
					TCSqlExec( cQuery )
				EndIf
			EndIf
	
			TMPSCR->( dbCloseArea() )
	
		EndIf
	
		cQueryA := "UPDATE " + RetSqlName("SC7") + " SET C7_TXMOEDA = 0 " + CRLF
		cQueryA += "WHERE C7_FILIAL = '" + xFilial("SC7") + "' " + CRLF
		cQueryA += "AND C7_NUM = '" + SC7->C7_NUM + "' " + CRLF
		cQueryA += "AND C7_MOEDA <> 1 " + CRLF
		cQueryA += "AND C7_TXMOEDA <> 0 " + CRLF
		cQueryA += "AND D_E_L_E_T_ = ' ' " + CRLF
	
		TCSqlExec(cQueryA)
	
	ElseIf SC7->C7_TIPO == 2 // Autorização de Entrega...
		// Se bloqueado ver se há pendência no SCR, corrigir para liberado se não existir...
		If AllTrim( SC7->C7_CONAPRO ) == "B"
			cQuery := "SELECT COUNT(*) AS CONTA " + CRLF
			cQuery += "FROM " + RetSqlName("SCR") + " AS SCR WITH (NOLOCK) " + CRLF
			cQuery += "WHERE CR_FILIAL = '" + xFilial("SC7") + "' " + CRLF
			cQuery += "AND CR_TIPO = 'AE' " + CRLF
			cQuery += "AND CR_NUM = '" + SC7->C7_NUM + "' " + CRLF
			cQuery += "AND CR_STATUS <> '03' " + CRLF
			cQuery += "AND SCR.D_E_L_E_T_ = ' ' " + CRLF
	
			TCQuery cQuery New Alias "TMPSCR"
			dbSelectArea("TMPSCR")
			dbGoTop()
	
			If TMPSCR->( Eof() ) .Or. TMPSCR->CONTA == 0
				cQuery := "UPDATE " + RetSqlName("SC7") + " SET C7_CONAPRO = 'L' " + CRLF
				cQuery += "WHERE C7_FILIAL = '" + xFilial("SC7") + "' " + CRLF
				cQuery += "AND C7_NUM = '" + SC7->C7_NUM + "' " + CRLF
				cQuery += "AND C7_QUANT > C7_QUJE " + CRLF
				cQuery += "AND C7_ENCER <> 'E' " + CRLF
				cQuery += "AND C7_RESIDUO = '' " + CRLF
				cQuery += "AND D_E_L_E_T_ = ' ' " + CRLF

				TCSqlExec( cQuery )
	
			EndIf
	
			TMPSCR->( dbCloseArea() )
		EndIf
	EndIf
EndIf

RestArea( aArea )

Return
