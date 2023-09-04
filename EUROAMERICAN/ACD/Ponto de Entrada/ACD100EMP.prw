#Include 'Protheus.Ch'
#Include 'Totvs.Ch'
#Include 'TopConn.Ch'

User Function ACD100EMP()

Local lRetorno := .T.
Local aArea    := GetArea()
Local cProduto := ""

//Local cProduto := "MP.1769|MP.0769|MP.0001|MP.0002|TP001|TP002|TP003|769.00.00000|664|0774|0775|0779|MP.0504|MP.0373|MP.0370|MP.0369|MP.0740|MP.0372|7.000.800|MP.0678|MP.0867|MP.0407|MP.0460|0001.005|0001.105|0001.002|0001.003|0001.006|0001.007|0001.008|0001.009|0001.010|MP.0512|MP.0807|MP.0239|MP.0511|MP.0238|MP.0424"

// Alterado os parametros conforme alinhado com Fabio em 18/12/2020 
cProduto := GETMV("MV_XPCP01",,"")
cProduto += GETMV("MV_XPCP02",,"")
cProduto += GETMV("MV_XPCP03",,"")
cProduto += GETMV("MV_XPCP04",,"")
cProduto += GETMV("MV_XPCP05",,"")

dbSelectArea("SB1")
dbSetOrder(1)

If SB1->( dbSeek( xFilial("SB1") + SD4->D4_COD ) )
	If Left( SD4->D4_COD, 2) == "ME"
		cProduto += "|" + AllTrim( SD4->D4_COD )
	ElseIf !(AllTrim( SB1->B1_TIPO ) $ "MP") //ElseIf !(AllTrim( SB1->B1_TIPO ) $ "MP|PI|PP")
		cProduto += "|" + AllTrim( SD4->D4_COD )
	EndIf
EndIf

If AllTrim( SD4->D4_COD ) $ AllTrim( cProduto )
	lRetorno := .F.
EndIf

RestArea( aArea )

Return lRetorno
