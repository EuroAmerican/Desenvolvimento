#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} mest002
//Rotina para manutencao das etiquetas por nota fiscal.
@author mjlozzardo
@since 19/01/2018
@version 1.0
@type function
/*/
user function mest002(cTipo)
	Local cAlias := Alias()
	Local aBkpAh := aClone(aHeader)
	Local aBkpAc := aClone(aCols)
	Local nBkpN  := N
	Local aInfo  := {}

	Local nOpc := 0
	Local cCod := aCols[N, aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_COD"})]
	Local cItem:= aCols[N, aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_ITEM"})]
	Local nQtde:= aCols[N, aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_QUANT"})]
	Local cQuery:= ""
	Local cSeek := ""

	Local oSButton1
	Local oSButton2
	Local oDlg
	Local oGetD
	Local nI
	Local aAlter := {}
	Local aDados := {}

	Private oPrn    := Nil
	Private oFont1  := Nil

	Define Font oFont1 Name "Tahoma" Size 0,30 Of oPrn Bold

	Default cTipo := "M"

	AjustSX1()

	If cTipo == "M"
		aAlter := {"Z1_VOLUME", "Z1_NUMETIQ"}

		If nQtde == 0 .or. Empty(cCod)
			MsgStop("É necessário que os campos Código e Quantidade sejam informados, reveja os dados.", "SEM INFORMAÇÃO")
			Return
		EndIf

		//Salva dados da NF
		aHeader := {}
		aCols   := {}
		N       := 1

		aAdd(aHeader, {"Seq"        , "Z1_LINHA"  , "@!", 2, 0, "", "û", "C", ""})
		aAdd(aHeader, {"NFiscal"    , "Z1_NFISCAL", "@!", 9, 0, "", "û", "C", ""})
		aAdd(aHeader, {"Serie"      , "Z1_SERIE"  , "@!", 3, 0, "", "û", "C", ""})
		aAdd(aHeader, {"Fornec"     , "Z1_FORNEC" , "@!", 6, 0, "", "û", "C", ""})
		aAdd(aHeader, {"Loja"       , "Z1_LOJA"   , "@!", 2, 0, "", "û", "C", ""})
		aAdd(aHeader, {"Item"       , "Z1_ITEM"   , "@!", 4, 0, "", "û", "C", ""})
		aAdd(aHeader, {"Codigo"     , "Z1_PRODUTO", "@!",15, 0, "", "û", "C", ""})
		aAdd(aHeader, {"Descrição"  , "Z1_DESCRIC", "@!",30, 0, "", "û", "C", ""})
		aAdd(aHeader, {"UM"         , "Z1_UM"     , "@!", 2, 0, "", "û", "C", ""})
		aAdd(aHeader, {"Qtd p/Etiq" , "Z1_VOLUME" , "@9 999,999.9999",12, 4, "", "û", "N", ""})
		aAdd(aHeader, {"Qtd de Etiq", "Z1_NUMETIQ", "@9 999"         , 3, 0, "", "û", "N", ""})

		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1") + cCod, .F.))

		SZ1->(DbSetOrder(1))
		cSeek := xFilial("SZ1") + cNfiscal + cSerie + cA100For + cLoja + cItem //+ cCod

		If SZ1->(DbSeek(cSeek, .F.))
			While SZ1->(!Eof()) .and. SZ1->(Z1_FILIAL + Z1_NFISCAL + Z1_SERIE + Z1_FORNEC + Z1_LOJA + Z1_ITEM) == cSeek
				aAdd(aCols, Array(Len(aHeader) + 1))
				aCols[Len(aCols), 1] := SZ1->Z1_LINHA
				aCols[Len(aCols), 2] := SZ1->Z1_NFISCAL
				aCols[Len(aCols), 3] := SZ1->Z1_SERIE
				aCols[Len(aCols), 4] := SZ1->Z1_FORNEC
				aCols[Len(aCols), 5] := SZ1->Z1_LOJA
				aCols[Len(aCols), 6] := SZ1->Z1_ITEM
				aCols[Len(aCols), 7] := SZ1->Z1_PRODUTO
				aCols[Len(aCols), 8] := SZ1->Z1_DESCRIC
				aCols[Len(aCols), 9] := SZ1->Z1_UM
				aCols[Len(aCols), 10]:= SZ1->Z1_VOLUME
				aCols[Len(aCols), 11]:= SZ1->Z1_NUMETIQ
				aCols[Len(aCols), Len(aHeader) + 1] := .F.
				SZ1->(DbSkip())
			EndDo
		Else
			aAdd(aCols, Array(Len(aHeader) + 1))
			aCols[Len(aCols), 1] := "01"
			aCols[Len(aCols), 2] := cNfiscal
			aCols[Len(aCols), 3] := cSerie
			aCols[Len(aCols), 4] := cA100For
			aCols[Len(aCols), 5] := cLoja
			aCols[Len(aCols), 6] := cItem
			aCols[Len(aCols), 7] := cCod
			aCols[Len(aCols), 8] := SB1->B1_DESC
			aCols[Len(aCols), 9] := SB1->B1_UM
			aCols[Len(aCols), 10]:= SB1->B1_QE
			aCols[Len(aCols), 11]:= nQtde / SB1->B1_QE
			aCols[Len(aCols), Len(aHeader) + 1] := .F.
		EndIf

		Define MsDialog oDlg Title "Etiqueta x Item NF" From 0,0 To 300,1000 Colors 0,16777215 Pixel
		oGetD := MsGetDados():New(5, 5, 120, 500, 3, "AllwaysTrue", "AllwaysTrue", "+Z1_LINHA", .T., aAlter,,,,,,,, oDlg)
		Define sButton oSButton1 From 130,010 Type 01 Of oDlg Enable Action (nOpc := 1, Iif(U_mest002Q(nQtde), oDlg:End(), nOpc := 0))
		Define sButton oSButton2 From 130,050 Type 02 Of oDlg Enable Action (oDlg:End())

		Activate MsDialog oDlg Centered

		If nOpc == 1
			//Apaga as etiquetas existentes
			cQuery := "DELETE " + RetSqlName("SZ1")
			cQuery += " WHERE Z1_FILIAL = '" + xFilial("SZ1") + "'"
			cQuery += "   AND Z1_NFISCAL = '" + cNfiscal + "'"
			cQuery += "   AND Z1_SERIE = '" + cSerie + "'"
			cQuery += "   AND Z1_FORNEC = '" + cA100For + "'"
			cQuery += "   AND Z1_LOJA = '" + cLoja + "'"
			cQuery += "   AND Z1_ITEM = '" + cItem + "'"
			TcSqlExec(cQuery)

			//Grava etiquetas
			For nI := 1 To Len(aCols)
				If !aCols[nI, 12]
					SZ1->(RecLock("SZ1", .T.))
					SZ1->Z1_FILIAL  := xFilial("SZ1")
					SZ1->Z1_LINHA   := aCols[nI, 1]
					SZ1->Z1_NFISCAL := cNfiscal
					SZ1->Z1_SERIE   := cSerie
					SZ1->Z1_FORNEC  := cA100For
					SZ1->Z1_LOJA    := cLoja
					SZ1->Z1_ITEM    := cItem
					SZ1->Z1_PRODUTO := cCod
					SZ1->Z1_DESCRIC := SB1->B1_DESC
					SZ1->Z1_UM      := SB1->B1_UM
					SZ1->Z1_VOLUME  := aCols[nI, 10]
					SZ1->Z1_NUMETIQ := aCols[nI, 11]
					SZ1->(MsUnLock())
				EndIf
			Next nI
		EndIf

	ElseIf cTipo == "G"  //Gera dados na CB0
		If MsgYesNo("Confirma a geração das etiquetas ?","GERAR ETIQUETA")  //Confirma a geracao da CB0
			cChaveSD1 := SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)
			SD1->(DbSetOrder(1))
			SD1->(DbSeek(xFilial("SD1") + cChaveSD1, .F.))

			While SD1->(!Eof()) .and. cChaveSD1 == SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA)
				//Busca informacao na SZ1 - Item da NF x Etiqueta
				If SZ1->(DbSeek(xFilial("SZ1") + SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_ITEM + D1_COD), .F.))
					While SZ1->(!Eof()) .and. SZ1->(Z1_FILIAL + Z1_NFISCAL + Z1_SERIE + Z1_FORNEC + Z1_LOJA + Z1_ITEM + Z1_PRODUTO) == SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_ITEM + D1_COD)
						If SZ1->Z1_GERCB0 != "1"
							For nI := 1 To SZ1->Z1_NUMETIQ
								aAdd(aDados, SZ1->Z1_PRODUTO)
								aAdd(aDados, SD1->D1_LOCAL)
								aAdd(aDados, SZ1->Z1_VOLUME)
								aAdd(aDados, "")  //ENDERECO
								aAdd(aDados, SD1->D1_LOTECTL)
								aAdd(aDados, SD1->D1_NUMLOTE)
								aAdd(aDados, SD1->D1_DTVALID)
								aAdd(aDados, MsDate())  //DT.GERACAO
								aAdd(aDados, SD1->D1_FORNECE)
								aAdd(aDados, SD1->D1_LOJA)
								aAdd(aDados, SD1->D1_DOC)
								aAdd(aDados, SD1->D1_SERIE)
								aAdd(aDados, SD1->D1_ITEM)
								U_mest002g(aDados)
								SZ1->(RecLock("SZ1", .F.))
								SZ1->Z1_GERCB0 := "1"
								SZ1->(MsUnLock())
								aDados := {}
							Next
						EndIf
						SZ1->(DbSkip())
					EndDo
				EndIf
				SD1->(DbSkip())
			EndDo
			MsgInfo("Finalizado", "A geração das etiquetas foi finalizada.")
		EndIf

	ElseIf cTipo == "I"
		If Pergunte("MEST002", .T.)
			Pergunte("MEST002", .F.)
			cChaveSD1 := SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)

			If SF1->F1_TIPO $ "B|D"
				SA1->(DbSetOrder(1))
				SA1->(DbSeek(xFilial("SA1") + SF1->(F1_FORNECE + F1_LOJA), .F.))
				cNome := SubStr(SA1->A1_NOME, 1, 20)
			Else
				SA2->(DbSetOrder(1))
				SA2->(DbSeek(xFilial("SA2") + SF1->(F1_FORNECE + F1_LOJA), .F.))
				cNome := SubStr(SA2->A2_NOME, 1, 20)
			EndIf

			If MV_PAR01 == 2  // Laser

				oPrn := TmsPrinter():New()
				oPrn:SetPortrait()

				SD1->(DbSetOrder(1))
				SD1->(DbSeek(xFilial("SD1") + cChaveSD1, .F.))

				While SD1->(!Eof()) .and. cChaveSD1 == SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA)
					//Busca informacao na SZ1 - Item da NF x Etiqueta
					If SZ1->(DbSeek(xFilial("SZ1") + SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_ITEM + D1_COD), .F.))
						While SZ1->(!Eof()) .and. SZ1->(Z1_FILIAL + Z1_NFISCAL + Z1_SERIE + Z1_FORNEC + Z1_LOJA + Z1_ITEM + Z1_PRODUTO) == SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_ITEM + D1_COD)
							For nI := 1 To SZ1->Z1_NUMETIQ
								// Impressao
								oPrn:StartPage()
								oPrn:Say(0685, 0900, cNome, oFont1) //Empresa
								oPrn:Say(0845, 1050, Dtoc(SD1->D1_DTDIGIT), oFont1) //Recebimento
								oPrn:Say(1005, 1000, SD1->D1_COD, oFont1) //Produto
								oPrn:Say(1165, 1020, SD1->D1_LOTEFOR, oFont1) //Lote Externo
								oPrn:Say(1325, 1020, SD1->D1_LOTECTL, oFont1) //Lote Interno
								oPrn:Say(1485, 1040, Dtoc(SD1->D1_DTVALID), oFont1) //Validade
								oPrn:Say(1645, 1040, StrZero(nI, 3, 0) + " / " + StrZero(SZ1->Z1_NUMETIQ, 3, 0), oFont1) //Volumes
								oPrn:Say(1805, 0800, TransForm(SZ1->Z1_VOLUME, "@E 999,999.99999") + " " + SD1->D1_UM, oFont1) //Quantidade
								oPrn:EndPage()
							Next nI
							SZ1->(DbSkip())
						EndDo
					EndIf
					SD1->(DbSkip())
				EndDo

				oPrn:Preview()
				oPrn:End()

			ElseIf MV_PAR01 == 1  //Termica
				If MV_PAR02 == 2 //materia prima
					CB0->(DbSetOrder(9))  //CB0_FILIAL+CB0_FORNEC+CB0_LOJAFO+CB0_CODPRO+CB0_NFENT+CB0_SERIEE+CB0_ITNFE

					SB1->(DbSetOrder(1))

					SD1->(DbSetOrder(1))
					SD1->(DbSeek(xFilial("SD1") + cChaveSD1, .F.))
					While SD1->(!Eof()) .and. cChaveSD1 == SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA)
						If CB0->(DbSeek(xFilial("CB0") + SD1->(D1_FORNECE + D1_LOJA + D1_COD + D1_DOC + D1_SERIE + D1_ITEM), .F.))
							While CB0->(!Eof()) .and. SD1->(D1_FILIAL + D1_FORNECE + D1_LOJA + D1_COD + D1_DOC + D1_SERIE + D1_ITEM) == CB0->(CB0_FILIAL + CB0_FORNEC + CB0_LOJAFO + CB0_CODPRO + CB0_NFENT + CB0_SERIEE + CB0_ITNFE)
								SB1->(DbSeek(xFilial("SB1") + CB0->CB0_CODPRO, .F.))
								aAdd(aInfo, Rtrim(CB0->CB0_CODPRO))
								aAdd(aInfo, Rtrim(SB1->B1_DESC))
								aAdd(aInfo, Rtrim(CB0->CB0_LOTE))
								aAdd(aInfo, SD1->D1_DTVALID)
								aAdd(aInfo, CB0->CB0_QTDE)
								aAdd(aInfo, cNome)
								aAdd(aInfo, CB0->CB0_CODETI)
								aAdd(aInfo, SD1->D1_NUMLOTE)
								
								CB5->(DbSeek(xFilial("CB5") + "000001" , .F.))
								If !Usacb0("01")
									cTipoBar := 'MB04'
								EndIf
				
								//Imprime etiqueta
								CB5SetImp("000001")								
								U_iacd001("002", aInfo)
								aInfo := {}
								CB0->(DbSkip())
							EndDo
						EndIf
						SD1->(DbSkip())
					EndDo
				EndIf
			EndIf
		EndIf
	EndIf

	DbSelectArea(cAlias)
	//Restaura dados da NF
	aHeader := aBkpAh
	aCols   := aBkpAc
	N       := nBkpN
	Return

User Function mest002q(nQuant)
	Local lRet := .T.
	Local nOld := N
	Local nI   := 0
	Local nQtd := 0

	For nI := 1 To Len(aCols)
		If !aCols[nI, 12]
			nQtd += (aCols[nI, 11] * aCols[nI, 10])
		EndIf
	Next nI

	If nQuant != nQtd
		MsgStop("A soma das quantidades não confere com o item da nota fiscal, reveja os dados.", "QTD DIFERENTE")
		lRet := .F.
	EndIf

	N := nOld
	Return(lRet)

User Function mest002g(aDados)
	Local cId := ""

	While .T.
		cID := Padr(CBProxCod('MV_CODCB0'), 10)
		If !CB0->(DbSeek(xFilial("CB0") + cID), .F.)
			Exit
		EndIf
	EndDo
	CB0->(RecLock("CB0", .T.))
	CB0->CB0_FILIAL := xFilial("CB0")
	CB0->CB0_CODETI := cID
	CB0->CB0_TIPO   := "01"
	CB0->CB0_CODPRO := aDados[1]
	CB0->CB0_QTDE   := aDados[3]
	CB0->CB0_USUARIO:= RetCodUsr()
	CB0->CB0_DTNASC := aDados[8]
	CB0->CB0_LOCAL  := aDados[2]
	CB0->CB0_OP     := ""
	CB0->CB0_NUMSEQ := ""
	CB0->CB0_LOTE   := aDados[5]
	CB0->CB0_SLOTE  := aDados[6]
	CB0->CB0_DTVLD  := aDados[7]
	CB0->CB0_CC     := ""
	CB0->CB0_ORIGEM := "SD1"
	CB0->CB0_FORNEC := aDados[9]
	CB0->CB0_LOJAFO := aDados[10]
	CB0->CB0_NFENT  := aDados[11]
	CB0->CB0_SERIEE := aDados[12]
	CB0->CB0_ITNFE  := aDados[13]
	CB0->(MsUnLock())
	Return

Static Function AjustSX1()
	Local cAlias   := Alias()
	Local aHelpPor := {}

	//Pergunta 01
	aHelpPor := {}
	aAdd(aHelpPor, "Indique o tipo de impressora")
	U_FATUSX1("MEST002","01","Tipo de impressao ?","Tipo de impressao ?","Tipo de impressao ?","MV_CH1","N",1,0,0,"C","","MV_PAR01","Termica","","","","","Laser","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 02
	aHelpPor := {}
	aAdd(aHelpPor, "Modelo da etiqueta, onde")
	aAdd(aHelpPor, "001- para produto acabado")
	aAdd(aHelpPor, "002- para materia prima")
	U_FATUSX1("MEST002","02","Modelo ?","Modelo ?","Modelo ?","MV_CH2","N",1,0,0,"C","","MV_PAR03","001","","","","","002","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	DbSelectArea(cAlias)
	Return
