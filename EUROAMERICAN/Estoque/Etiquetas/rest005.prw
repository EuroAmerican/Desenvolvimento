#include 'protheus.ch'
#include 'parmtype.ch'
User Function rest005()
	Local cAlias  := Alias()
	Local cPerg   := "REST005"
	Local cTipoBar:= ""
	Local cEof    := Chr(13) + Chr(10)
	Local aDados  := {}
	Local cCodPrd := ""

	AjustSX1()

	SB1->(DbSetOrder(1))  //filial + cod
	SB5->(DbSetOrder(1))  //filial + cod

//	If SM0->M0_CODIGO $ "08|09"
		If Pergunte(cPerg, .T.)
			Pergunte(cPerg, .F.)
			If CB5->(DbSeek(xFilial("CB5") + MV_PAR01, .F.))
				If !Usacb0("01")
					cTipoBar := 'MB04'
				EndIf
				CB5SetImp(MV_PAR01)

				//Imprime etiqueta
				Set Century Off // IMPRESSAO COM O DOIS DÍGITOS DO ANO.
				SB1->(DbSeek(xFilial("SB1") + SC2->C2_PRODUTO, .F.))

				If SB5->(DbSeek(xFilial("SB5") + SC2->C2_PRODUTO, .F.))
					cEmb := "SB5->B5_EAN14" + Str(MV_PAR02, 1, 0)
					If &cEmb > 0
						nQuant := Int(SC2->C2_QUANT / &cEmb) + 1
						cBar14 := Str(MV_PAR02, 1, 0) + SubStr(Alltrim(SB1->B1_CODBAR), 1, 12)
						cBar14 := cBar14 + U_cean14(cBar14)

						aDados := {}
						aAdd(aDados, IIF(!EMPTY(SB1->B1_U_DESC2),Rtrim(Substr(SB1->B1_U_DESC2,1,25)),Rtrim(Substr(SB1->B1_DESC,1,25))))	//01 descricao
						aAdd(aDados, Rtrim(SB1->B1_COD))	//02 codigo
						aAdd(aDados, Rtrim(cBar14))	//03 ean14
						aAdd(aDados, SubStr(SC2->C2_NUM, 1, 6))	//04  op/lote
						aAdd(aDados, SubStr(Dtoc(SC2->C2_DATPRF), 4, 5))  //05 dt fab
						aAdd(aDados, SubStr(Dtoc(SC2->C2_XDTVALI), 4, 5))  //06 dt val

						aAdd(aDados, nQuant)  //07 quantidade
						aAdd(aDados, Str(&cEmb, 2, 0))	//08 und.por caixa
					Else
						Alert("A T E N Ç Ã O "+ CRLF + CRLF + "Favor preencher o campo (" + cEmb +") no complemento de produto." + CRLF +  "Esse campo está na aba ACD")
						Return
					EndIf

					U_IACD001("006", aDados)  //IMPRIMIR caixa coletiva
				EndIf
				Set Century On  //Termino da impressao
				MscbClosePrinter()
			EndIf
		EndIf
	//EndIf
	Return

Static Function AjustSX1()
	Local cAlias   := Alias()
	Local aHelpPor := {}

	//Pergunta 01
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o local de impressão")
	aAdd(aHelpPor, "das etiquetas")
	U_FATUSX1("REST005","01","Local de Impressão ?","Local de Impressão ?","Local de Impressão ?","MV_CH1","C",6,0,0,"G",'ExistCpo("CB5")',"MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","CB5","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 03
	aHelpPor := {}
	aAdd(aHelpPor, "Informe qual embalegem coletiva")
	aAdd(aHelpPor, "deve ser impressa")
	U_FATUSX1("REST005","02","Qual Embalagem","Qual Embalagem","Qual Embalagem","MV_CH2","N",1,0,0,"G",'',"MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	DbSelectArea(cAlias)
	Return
