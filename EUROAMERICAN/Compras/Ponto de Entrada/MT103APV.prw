#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'RwMake.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

User Function MT103APV()

Local aArea    := GetArea()
Local aAreaSF1 := SF1->( GetArea() )
Local aAreaSD1 := SD1->( GetArea() )
Local aAreaSC7 := SC7->( GetArea() )
Local cGrupo   := SF1->F1_APROV
Local cDefault := GetMV("MV_EQ_NFAP",,"000022")
Local nLimite  := GetMV("MV_EQ_LVNF",,10000) // 10K
Local nAtePerc := GetMV("MV_EQ_PCNF",,10)    // 10%
Local lQtd     := .T.
Local lVlr     := .T.
Local lConsNiv := GetMV("MV_EQ_NTNF",,.T.) // Nível de tolerância permitido para compras...

If Alltrim(SF1->F1_ESPECIE) == SuperGetMv("EQ_ESPSRV",.F.,"NFSE") //Nao trata quando for NFSE - MAA 25/10/21
	Return(Space(06))
End	

If SF1->F1_VALBRUT <= nLimite .And. lConsNiv
	dbSelectArea("SD1")
	dbSetOrder(1)
	MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)

	Do While SD1->( !Eof() ) .And. SD1->D1_FILIAL == xFilial("SD1") .And. SD1->D1_DOC == SF1->F1_DOC .And. SD1->D1_SERIE == SF1->F1_SERIE ;
							 .And. SD1->D1_FORNECE == SF1->F1_FORNECE .And. SD1->D1_LOJA == SF1->F1_LOJA .And. lQtd .And. lVlr
        // Valida percentual acima do limite máximo do nível de compras para aprovação...
		If !Empty(SD1->D1_PEDIDO)
			dbSelectArea("SC7")
			dbSetOrder(1)
			MsSeek(xFilial("SC7")+SD1->D1_PEDIDO+SD1->D1_ITEMPC)
		
			If (SD1->D1_QUANT > ( SC7->C7_QUANT + ( SC7->C7_QUANT * nAtePerc) ) )
				lQtd := .F.
			ElseIf (SD1->D1_VUNIT > xMoeda(SC7->C7_PRECO+(SC7->C7_PRECO * nAtePerc),SC7->C7_MOEDA,1,SD1->D1_EMISSAO,TamSX3("D1_VUNIT")[2],SC7->C7_TXMOEDA))
				lVlr := .F.
			EndIf
		EndIf

		SD1->( dbSkip() )
	EndDo

	If lQtd .And. lVlr
		cGrupo := cDefault
	EndIf
EndIf

RestArea( aArea )
RestArea(aAreaSF1)
RestArea(aAreaSD1)
RestArea(aAreaSC7)

Return cGrupo
