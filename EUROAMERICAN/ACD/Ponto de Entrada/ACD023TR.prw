#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

User Function ACD023TR() //	ExecBlock('ACD023TR',.F.,.F.,{cOp,cOperacao,cOperador,cTransac})

Local aArea       := GetArea()
Local aAreaSC2    := SC2->( GetArea() )
Local aAreaSG1    := SG1->( GetArea() )
Local aAreaSG2    := SG2->( GetArea() )
Local aAreaSB1    := SB1->( GetArea() )
Local aAreaCBH    := CBH->( GetArea() )
Local aAreaSH6    := SH6->( GetArea() )
Local lRetorno    := .T.
Local cOP         := ParamIXB[1]
Local cOperacao   := ParamIXB[2]
Local cOperador   := ParamIXB[3]
Local cTransac    := ParamIXB[4]
Local cQuery      := ""
Local cItem       := SubStr( cOP, 7, 2) // Identifica o Item da OP, se for envase, garantir que a PI foi apontada
Local cBase       := ""
Local cMensagem   := ""

If cItem == "01"
	dbSelectArea("SC2")
	dbSetOrder(1)
	If SC2->( dbSeek( xFilial("SC2") + cOP ) )
		cQuery := "SELECT G2_OPERAC, G2_DESCRI, ISNULL((SELECT 'Sim' FROM " + RetSqlName("SH6") + " WITH (NOLOCK) WHERE H6_FILIAL = C2_FILIAL AND H6_OP = C2_NUM + C2_ITEM + C2_SEQUEN AND H6_OPERAC = G2_OPERAC AND D_E_L_E_T_ = ' '), 'Não') AS APONTADO " + CRLF
		cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SG2") + " AS SG2 WITH (NOLOCK) ON G2_FILIAL = '" + xFilial("SG2") + "' " + CRLF
		cQuery += "  AND G2_CODIGO = C2_ROTEIRO " + CRLF
		cQuery += "  AND G2_PRODUTO = C2_PRODUTO " + CRLF
		cQuery += "  AND G2_OPERAC < '" + cOperacao + "' " + CRLF
		cQuery += "  AND SG2.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
		cQuery += "AND C2_NUM + C2_ITEM + C2_SEQUEN = '" + cOP + "' " + CRLF
		cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "ORDER BY 1 " + CRLF

		TCQuery cQuery New Alias "TMPOPE"
		dbSelectArea("TMPOPE")
		dbGoTop()
		Do While !TMPOPE->( Eof() )
			If AllTrim( TMPOPE->APONTADO ) <> "Sim"
				cMensagem += "Operacao: " + TMPOPE->G2_OPERAC + " nao concluida"
			EndIf

			TMPOPE->( dbSkip() )
		EndDo
		TMPOPE->( dbCloseArea() )
	EndIf
Else
	cBase := Left( cOP, 6) + "01001"
	dbSelectArea("SC2")
	dbSetOrder(1)
	If SC2->( dbSeek( xFilial("SC2") + cBase ) )
		If SC2->C2_QUANT > (SC2->C2_QUJE + SC2->C2_PERDA)
			cMensagem += "OP Base: " + cBase + " nao concluida"
		EndIf
	EndIf
EndIf

If !Empty( cMensagem )
	lRetorno := .F.
	CBAlert(cMensagem,"Aviso",.T.,4000,2)
EndIf

SC2->( RestArea( aAreaSC2 ) )
SG1->( RestArea( aAreaSG1 ) )
SG2->( RestArea( aAreaSG2 ) )
SB1->( RestArea( aAreaSB1 ) )
CBH->( RestArea( aAreaCBH ) )
SH6->( RestArea( aAreaSH6 ) )
RestArea( aArea )

Return lRetorno
