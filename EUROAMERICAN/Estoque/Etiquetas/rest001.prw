#include 'protheus.ch'
#include 'parmtype.ch'
User Function rest001()
	Local cAlias   := Alias()
	Local aSays    := {}
	Local aButtons := {}
	Local aHelpPor := {}
	Local cTitoDlg := "Impress�o de etiqueta"
	Local cPerg    := "REST001"
	Local nOpca    := 0

	//Pergunta 01
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o modelo a ser impresso")
	aAdd(aHelpPor, "001- Euroamerican, 002- Multicores")
	U_FATUSX1("REST001","01","Modelo","Modelo","Modelo","MV_CH1","N",1,0,1,"C","","MV_PAR01","001","","","","","002","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 02
	aHelpPor := {}
	aAdd(aHelpPor, "Informe a quantidade de etiquetas")
	aAdd(aHelpPor, "que devem ser impressas")
	U_FATUSX1("REST001","02","Quantidade","Quantidade","Quantidade","MV_CH1","N", 3, 0, 0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	aAdd(aSays, "Rotina para impress�o de etiquetas de identifica��o")
	aAdd(aSays, "de produto.")
	aAdd(aSays, "Os dados utilizados ser�o os da Ordem de Produ��o posicionada.")
	aAdd(aSays, "Rotina ajustada para utilizar apenas LPT1")

	aAdd(aButtons,{5, .T., {|o| Pergunte(cPerg, .T.)}})
	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	If nOpca == 1
		Pergunte(cPerg, .F.)
		Processa({|| rest01ok("Efetuando impress�o, aguarde...")})
	EndIf
	DbSelectArea(cAlias)
	Return

Static Function rest01ok()
	Local aDados := {}
	Local cFabric:= ""
	Local cValid := ""

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1") + SC2->C2_PRODUTO, .F.))

	If MV_PAR01 == "001"

		dbSelectArea("SB8")
		dbSetOrder(3)
		If dbSeek(xFilial("SB8")+SC2->C2_PRODUTO+SC2->C2_LOCAL+Padr(SubStr(SC2->C2_NUM, 1, 6),10))
			dDtVld := SB8->B8_DTVALID
			dDtFab := SB8->B8_DFABRIC
		Else
			dDtVld := SC2->C2_XDTVALI
			dDtFab := SC2->C2_EMISSAO
		EndIf

		aAdd(aDados, Subs(Rtrim(SB1->B1_U_DESC2),1, 25))	//Descricao do produto
		aAdd(aDados, SB1->B1_COD)		//Codigo do produto
		aAdd(aDados, SB1->B1_CODBAR)		//Codigo EAN13
		aAdd(aDados, SC2->C2_NUM)				//Numero do lote
		aAdd(aDados, dDtFab)					//Fabricacao do produto
		aAdd(aDados, dDtVld)					//Validade do produto
		aAdd(aDados, MV_PAR02)					//Numero de copias
		aAdd(aDados, "")
		u_iacd001("001", aDados)

	ElseIf MV_PAR01 == "002"  //busca dados CB0

	EndIf
	Return
