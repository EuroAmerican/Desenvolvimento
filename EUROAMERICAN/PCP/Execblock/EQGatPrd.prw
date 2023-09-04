#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

User Function EQGatPrd()

Local aArea     := GetArea()
Local cQuery    := ""
Local nQuant    := 0
Local cProduto  := ""
Local cOP       := ""
Local cItem     := ""
Local oModel
Local oModelMAS

If Type("M->C2_PRODUTO") == "U"
	oModel   := FWModelActive()
	oModelMAS := oMdlSGF:GetModel('MASTER')
	cProduto  := oModelMAS:GetValue('C2_PRODUTO')
	cOP       := oModelMAS:GetValue('C2_NUM')
	cItem     := oModelMAS:GetValue('C2_ITEM')
Else
	cProduto  := M->C2_PRODUTO
	cOP       := M->C2_NUM
	cItem     := M->C2_ITEM
EndIf

cQuery := "SELECT B1_PESO, B1_CONV, B1_TIPCONV FROM " + RetSqlName("SB1") + " WITH (NOLOCK) "
cQuery += "WHERE B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery += "AND B1_COD = '" + M->C2_PRODUTO + "' "
//cQuery += "AND B1_CONV > 0 "
cQuery += "AND D_E_L_E_T_ = ' ' "

TCQuery cQuery New Alias "TMPSB1"
dbSelectArea("TMPSB1")
dbGoTop()

If !TMPSB1->( Eof() )
	cQuery := "SELECT SUM(FATOR_QG) AS FATOR_QG, SUM(QUANT_PI) AS QUANT_PI, SUM(QUANT_PA) AS QUANT_PA, SUM(QUANT_PI) - (SUM(QUANT_PA) * SUM(FATOR_QG)) AS SALDO "
	cQuery += "FROM ( "
	//cQuery += "SELECT CASE WHEN B1_PESO = 0 THEN B1_CONV ELSE B1_PESO END AS FATOR_QG, C2_QUANT AS QUANT_PI, 0 AS QUANT_PA "
	cQuery += "SELECT B1_CONV AS FATOR_QG, C2_QUANT AS QUANT_PI, 0 AS QUANT_PA "
	cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) "
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery += "  AND B1_COD = C2_PRODUTO "
	cQuery += "  AND B1_CONV <> 0 "
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' "
	cQuery += "AND C2_NUM = '" + M->C2_NUM + "' "
	cQuery += "AND C2_ITEM = '01' "
	cQuery += "AND C2_SEQUEN = '001' "
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' "
	cQuery += "UNION ALL "
	//cQuery += "SELECT 0 AS FATOR_QG, 0 AS QUANT_PI, SUM(C2_QUANT * (CASE WHEN B1_PESO = 0 THEN B1_CONV ELSE B1_PESO END)) AS QUANT_PA "
	cQuery += "SELECT 0 AS FATOR_QG, 0 AS QUANT_PI, SUM(C2_QUANT * B1_CONV) AS QUANT_PA "
	cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) "
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery += "  AND B1_COD = C2_PRODUTO "
	cQuery += "  AND B1_CONV <> 0 "
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' "
	cQuery += "AND C2_NUM = '" + M->C2_NUM + "' "
	cQuery += "AND C2_ITEM <> '01' "
	cQuery += "AND C2_SEQUEN = '001' "
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' "
	cQuery += ") AS SALDO "

	TCQuery cQuery New Alias "TMPSC2"
	dbSelectArea("TMPSC2")
	dbGoTop()
	
	If !TMPSC2->( Eof() )
		If TMPSC2->SALDO > 0 .And. TMPSC2->FATOR_QG > 0 .And. TMPSB1->B1_CONV > 0
			//nQuant := Int( ( TMPSC2->SALDO / TMPSC2->FATOR_QG ) / TMPSB1->B1_CONV )
			nQuant := Int( ( TMPSC2->SALDO / TMPSC2->FATOR_QG ) / TMPSB1->B1_PESO )
			If nQuant < 0
				nQuant := 0
			EndIf
		EndIf
	EndIf

	TMPSC2->( dbCloseArea() )
EndIf

TMPSB1->( dbCloseArea() )

RestArea( aArea )

Return nQuant