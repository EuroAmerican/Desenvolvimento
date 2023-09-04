#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} mpcp001
//Rotina para manutencao da tabela SZ0 - Procedimento de fabricacao
@author mjlozzardo
@since 24/01/2018
@type function
@version 1.0
/*/
User Function mpcp001()
	Private aRotina := MenuDef()

	AjustSX3()

	DbSelectArea("SZ0")
	DbSetOrder(1)
	DbGoTop()
	mBrowse(,,,,"SZ0")
	Return

Static Function MenuDef()
	Local aRet := {}

	aRet := {{"Pesquisar" , "AxPesqui" 	, 0 , 1 , , .F. },;
			 {"Visualizar", "U_mpcp01m"	, 0 , 2 , , .T. },;
			 {"Incluir"	  , "U_mpcp01m"	, 0 , 3 , , .T. },;
			 {"Alterar"	  , "U_mpcp01m"	, 0 , 4 , , .T. },;
			 {"Excluir"	  , "U_mpcp01m"	, 0 , 5 , , .T. },;
			 {"Copiar"	  , "U_mpcp01c"	, 0 , 3 , , .T. }}

	Return(aRet)

User Function mpcp01m(cAlias, nReg, nOpc)
	Local aPosObj  := {}
	Local aObjects := {}
	Local aButtons := {}
	Local aSize    := MsAdvSize()
	Local cSeek    := ""
	Local cWhile   := ""
	Local nOpcA    := 0
	Local nI       := 0
	Local nY       := 0
	Local oDlg
	Local aAlter   := {"Z0_OPERAC", "Z0_RECURSO", "Z0_REVPRC", "Z0_DESCRIC", "Z0_TPOPER", "Z0_LOTEPAD", "Z0_TEMPAD", "Z0_SEQINI", "Z0_SEQFIN"}
	Local aCposEnch:= {"NOUSER","Z0_PRODUTO", "Z0_CODIGO"} //Campos que serao exibidos na Enchoice

	Private aCols   := {}
	Private aHeader := {}
	Private oGetD
	Private aTela[0][0], aGets[0]

	If nOpc == 2 .or. nOpc == 4 .or. nOpc == 5 //Visualizar, Alterar, Excluir
		RegToMemory("SZ0", .F., .F.)
	ElseIf nOpc == 3  //Inclusao
		DbSelectArea("SZ0")
		RegToMemory("SZ0", .T., .F.)
		FillGetDados(nOpc, "SZ0", 1,,,,, aAlter,,,, .T., aHeader, aCols,,,,)
	EndIf

	If nOpc == 2 .or. nOpc == 4 .or. nOpc == 5 //Visualizar, Alterar, Excluir
		cSeek  := xFilial("SZ0") + SZ0->Z0_PRODUTO + SZ0->Z0_CODIGO
		cWhile := "SZ0->Z0_FILIAL + SZ0->Z0_PRODUTO + SZ0->Z0_CODIGO"
		FillGetDados(nOpc, "SZ0", 1, cSeek, {||&cWhile },,, aAlter,,,,, aHeader, aCols,,,,)
	EndIf

	aObjects := {}
	aAdd(aObjects, {0, 40, .T., .F. })
	aAdd(aObjects, {0, 60, .T., .T. })

	aInfo := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3}
	aPosObj := MsObjSize(aInfo, aObjects)

 	Define MsDialog oDlg Title "Procedimento de Fabricação" From aSize[7],0 To aSize[6],aSize[5] of oMainWnd Pixel
	EnChoice("SZ0", nReg, nOpc,,,, aCposEnch, aPosObj[1],,3,,,,,,.F. )
	oGetD := MsNewGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], If(nOpc == 2, 0, GD_INSERT+GD_UPDATE+GD_DELETE),.T.,.T.,/*"+PA6_ITEM"*/, aAlter,/*freeze*/,999,/*fieldok*/,/*superdel*/,.T.,,aHeader,aCols)

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{||nOpca := 1, aCols := oGetD:aCols, Obrigatorio(aGets, aTela), oGetD:TudoOk(), oDlg:End()}, {||nOpca := 2, oDlg:End()})

	If nOpca == 1 //Confirma
		SZ0->(DbSetOrder(1))
		If SZ0->(DbSeek(cSeek, .F.))
			While SZ0->(!Eof()) .and. cSeek == SZ0->(Z0_FILIAL + Z0_PRODUTO + Z0_CODIGO)
				SZ0->(RecLock("SZ0", .F.))
				SZ0->(DbDelete())
				SZ0->(MsUnLock())
				SZ0->(DbSkip())
			EndDo
		EndIf
		If nOpc == 3 .or. nOpc == 4
			For nI := 1 To Len(aCols)
				If !aCols[nI, Len(aCols[nI])]
					SZ0->(RecLock("SZ0", .T.))
					SZ0->Z0_FILIAL := xFilial("SZ0")
					SZ0->Z0_CODIGO := M->Z0_CODIGO
					SZ0->Z0_PRODUTO:= M->Z0_PRODUTO
					For nY := 1 To Len(aHeader)
						If (aHeader[nY, 10] != "V")
							SZ0->(FieldPut(FieldPos(aHeader[nY, 2]), aCols[nI, nY]))
						EndIf
					Next nY
					SZ0->(MsUnLock())
				EndIf
			Next nI
		EndIf
	EndIf
	Return

User Function mpcp01c(cAlias, nReg, nOpc)
	Local aPosObj  := {}
	Local aObjects := {}
	Local aButtons := {}
	Local aSize    := MsAdvSize()
	Local cSeek    := ""
	Local cWhile   := ""
	Local nOpcA    := 0
	Local nI       := 0
	Local nY       := 0
	Local oDlg
	Local aAlter   := {"Z0_OPERAC", "Z0_RECURSO", "Z0_REVPRC", "Z0_DESCRIC", "Z0_TPOPER", "Z0_LOTEPAD", "Z0_TEMPAD", "Z0_SEQINI", "Z0_SEQFIN"}
	Local aCposEnch:= {"NOUSER","Z0_PRODUTO", "Z0_CODIGO"} //Campos que serao exibidos na Enchoice

	Private aCols   := {}
	Private aHeader := {}
	Private oGetD
	Private aTela[0][0], aGets[0]

	RegToMemory("SZ0", .F., .F.)
	cSeek  := xFilial("SZ0") + SZ0->Z0_PRODUTO + SZ0->Z0_CODIGO
	cWhile := "SZ0->Z0_FILIAL + SZ0->Z0_PRODUTO + SZ0->Z0_CODIGO"
	FillGetDados(nOpc, "SZ0", 1, cSeek, {||&cWhile },,, aAlter,,,,, aHeader, aCols,,,,)

	M->Z0_CODIGO  := Space(TamSX3("Z0_CODIGO")[1])
	M->Z0_PRODUTO := Space(TamSX3("Z0_PRODUTO")[1])

	aObjects := {}
	aAdd(aObjects, {0, 40, .T., .F. })
	aAdd(aObjects, {0, 60, .T., .T. })

	aInfo := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3}
	aPosObj := MsObjSize(aInfo, aObjects)

 	Define MsDialog oDlg Title "Procedimento de Fabricação" From aSize[7],0 To aSize[6],aSize[5] of oMainWnd Pixel
	EnChoice("SZ0", nReg, nOpc,,,, aCposEnch, aPosObj[1],,3,,,,,,.F. )
	oGetD := MsNewGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], If(nOpc == 2, 0, GD_INSERT+GD_UPDATE+GD_DELETE),.T.,.T.,/*"+PA6_ITEM"*/, aAlter,/*freeze*/,999,/*fieldok*/,/*superdel*/,.T.,,aHeader,aCols)

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{||nOpca := 1, aCols := oGetD:aCols, Obrigatorio(aGets, aTela), oGetD:TudoOk(), oDlg:End()}, {||nOpca := 2, oDlg:End()})

	If nOpca == 1 //Confirma
		For nI := 1 To Len(aCols)
			If !aCols[nI, Len(aCols[nI])]
				SZ0->(RecLock("SZ0", .T.))
				SZ0->Z0_FILIAL := xFilial("SZ0")
				SZ0->Z0_CODIGO := M->Z0_CODIGO
				SZ0->Z0_PRODUTO:= M->Z0_PRODUTO
				For nY := 1 To Len(aHeader)
					If (aHeader[nY, 10] != "V")
						SZ0->(FieldPut(FieldPos(aHeader[nY, 2]), aCols[nI, nY]))
					EndIf
				Next nY
				SZ0->(MsUnLock())
			EndIf
		Next nI
	EndIf
	nOpc := 1
	Return

User Function mpcp01v(cChave)
	Local cAlias   := Alias()
	Local aAreaSZ0 := SZ0->(GetArea())
	Local lRet     := .T.

	If !Empty(cChave)
		SZ0->(DbSetOrder(1))
		If SZ0->(DbSeek(xFilial("SZ0") + cChave, .F.))
			MsgStop("Já existe", "Atenção, já existe uma sequencia de produção para esse produto.")
			lRet := .F.
		EndIf
	EndIf

	SZ0->(RestArea(aAreaSZ0))
	DbSelectArea(cAlias)
	Return(lRet)

Static Function AjustSX3()
	SX3->(DbSetOrder(1))
	SX3->(DbSeek("SZ0", .F.))
	While SX3->(!Eof()) .and. SX3->X3_ARQUIVO == "SZ0"
		SX3->(RecLock("SX3", .F.))
		SX3->X3_VALID   := ""
		SX3->X3_RELACAO := ""
		SX3->X3_VLDUSER := ""

		If SX3->X3_CAMPO == "Z0_CODIGO "
			SX3->X3_VLDUSER := "U_mpcp01v(M->Z0_PRODUTO + M->Z0_CODIGO)"
		EndIf

		If SX3->X3_CAMPO == "Z0_PRODUTO"
			SX3->X3_VALID   := "ExistCpo('SB1')"
			SX3->X3_VLDUSER := "U_mpcp01v(M->Z0_PRODUTO + M->Z0_CODIGO)"
		EndIf

		SX3->(MsUnLock())
		SX3->(DbSkip())
	EndDo
	Return
