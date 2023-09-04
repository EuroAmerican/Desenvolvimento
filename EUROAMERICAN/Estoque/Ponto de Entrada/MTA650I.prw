#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

User Function MTA650I()

Local cQuery := ""
Local cMsg   := ""

cQuery := "SELECT G1_COMP, (SUM(G1_QUANT) / B1_QB) * C2_QUANT AS QUANTIDADE, SUM(B2_QATU - B2_QEMP - B2_RESERVA) AS SALDO " + CRLF
cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SG1") + " AS SG1 WITH (NOLOCK) ON G1_FILIAL = '" + xFilial("SG1") + "' " + CRLF
cQuery += "  AND G1_COD = C2_PRODUTO " + CRLF
cQuery += "  AND SG1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
cQuery += "  AND B1_COD = C2_PRODUTO " + CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) ON B2_FILIAL = C2_FILIAL " + CRLF
cQuery += "  AND B2_COD = G1_COMP " + CRLF
cQuery += "  AND SB2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
cQuery += "AND C2_NUM = '" + SC2->C2_NUM + "' " + CRLF
cQuery += "AND C2_ITEM = '" + SC2->C2_ITEM + "' " + CRLF
cQuery += "AND C2_SEQUEN = '" + SC2->C2_SEQUEN + "' " + CRLF
cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "GROUP BY G1_COMP, B1_QB, C2_QUANT " + CRLF
cQuery += "HAVING ((SUM(B2_QATU - B2_QEMP - B2_RESERVA)) - ((SUM(G1_QUANT) / B1_QB) * C2_QUANT)) < 0 " + CRLF

TCQuery cQuery New Alias "TMPSC2"
dbSelectArea("TMPSC2")
dbGoTop()

Do While !TMPSC2->( Eof() )
	cMsg += "Produto: " + TMPSC2->G1_COMP + " Necessário: " + Transform( TMPSC2->QUANTIDADE, "@E 999,999.99") + " Saldo: " + Transform( TMPSC2->SALDO, "@E 999,999.99") + CRLF
	TMPSC2->( dbSkip() )
EndDo

If !Empty( cMsg )
	Aviso( "MTA650I - Aviso", "Ordem de Produção possui componentes sem saldo suficiente disponível:" + CRLF + cMsg, {"OK"}, 3)
EndIf

TMPSC2->( dbCloseArea() )

Return