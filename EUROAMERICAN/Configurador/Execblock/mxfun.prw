#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} mxfun
//Funcoes genericas
@author mjlozzardo
@since 02/03/2017
@version undefined
@type function
/*/
User Function fAtuSX1(cGrupo, cOrdem, cPergunt, cPerSpa, cPerEng, cVar,;
					 cTipo, nTamanho, nDecimal, nPresel, cGSC, cValid,;
					 cVar01, cDef01, cDefSpa1, cDefEng1, cCnt01,;
					 cVar02, cDef02, cDefSpa2, cDefEng2, cCnt02,;
					 cVar03, cDef03, cDefSpa3, cDefEng3, cCnt03,;
					 cVar04, cDef04, cDefSpa4, cDefEng4, cCnt04,;
					 cVar05, cDef05, cDefSpa5, cDefEng5, cCnt05,;
					 cF3, cPyme, cGrpSxg, cHelp, cPicture, cIdFil,;
					 aHelpPor, aHelpEng, aHelpSpa)

	Local aArea := GetArea()
	Local cKey
	Local lPort := .F.
	Local lSpa  := .F.
	Local lIngl := .F.
	Local nI    := 0

	cKey    := "P." + AllTrim(cGrupo) + AllTrim(cOrdem) + "."
	cPyme   := Iif(cPyme == Nil, " ", cPyme)
	cF3     := Iif(cF3 == NIl, " ", cF3)
	cGrpSxg := Iif(cGrpSxg == Nil, " ", cGrpSxg)
	cCnt01  := Iif(cCnt01 == Nil, "" , cCnt01)
	cHelp	:= Iif(cHelp == Nil, "" , cHelp)

	DbSelectArea("SX1")
	DbSetOrder(1)
	cGrupo := PadR(cGrupo, Len(SX1->X1_GRUPO), " ")

	If !(DbSeek(cGrupo + cOrdem))
		cPergunt:= If(!"?" $ cPergunt .and. !Empty(cPergunt), Alltrim(cPergunt) + " ?", cPergunt)
		cPerSpa	:= If(!"?" $ cPerSpa  .and. !Empty(cPerSpa) , Alltrim(cPerSpa)  + " ?", cPerSpa)
		cPerEng	:= If(!"?" $ cPerEng  .and. !Empty(cPerEng) , Alltrim(cPerEng)  + " ?", cPerEng)

		Reclock("SX1", .T.)
		SX1->X1_GRUPO   := cGrupo
		SX1->X1_ORDEM   := cOrdem
		SX1->X1_PERGUNT := cPergunt
		SX1->X1_PERSPA  := cPerSpa
		SX1->X1_PERENG  := cPerEng
		SX1->X1_VARIAVL := cVar
		SX1->X1_TIPO    := cTipo
		SX1->X1_TAMANHO := nTamanho
		SX1->X1_DECIMAL := nDecimal
		SX1->X1_PRESEL  := nPresel
		SX1->X1_GSC     := cGSC
		SX1->X1_VALID   := cValid
		SX1->X1_VAR01   := cVar01
		SX1->X1_F3      := cF3
		SX1->X1_GRPSXG  := cGrpSxg

		If Fieldpos("X1_PYME") > 0
			If cPyme != Nil
				SX1->X1_PYME := cPyme
			Endif
		Endif

		SX1->X1_CNT01 := cCnt01
		If cGSC == "C"			// Mult Escolha
			SX1->X1_DEF01   := cDef01
			SX1->X1_DEFSPA1 := cDefSpa1
			SX1->X1_DEFENG1 := cDefEng1

			SX1->X1_DEF02   := cDef02
			SX1->X1_DEFSPA2 := cDefSpa2
			SX1->X1_DEFENG2 := cDefEng2

			SX1->X1_DEF03   := cDef03
			SX1->X1_DEFSPA3 := cDefSpa3
			SX1->X1_DEFENG3 := cDefEng3

			SX1->X1_DEF04   := cDef04
			SX1->X1_DEFSPA4 := cDefSpa4
			SX1->X1_DEFENG4 := cDefEng4

			SX1->X1_DEF05   := cDef05
			SX1->X1_DEFSPA5 := cDefSpa5
			SX1->X1_DEFENG5 := cDefEng5
		Endif
		SX1->X1_HELP := cHelp
		PutSX1Help(cKey, aHelpPor, aHelpEng, aHelpSpa)
		MsUnlock()
	Else
		lPort := !"?" $ X1_PERGUNT .and. !Empty(SX1->X1_PERGUNT)
		lSpa  := !"?" $ X1_PERSPA  .and. !Empty(SX1->X1_PERSPA)
		lIngl := !"?" $ X1_PERENG  .and. !Empty(SX1->X1_PERENG)

		If lPort .Or. lSpa .Or. lIngl
			RecLock("SX1", .F.)
			If lPort
				SX1->X1_PERGUNT := Alltrim(SX1->X1_PERGUNT) + " ?"
			EndIf
			If lSpa
				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) + " ?"
			EndIf
			If lIngl
				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) + " ?"
			EndIf
			SX1->(MsUnLock())
		EndIf
	Endif

	//Atualizacao do help
	cHelp := ""
	For nI := 1 To Len(aHelpPor)
		cHelp += Alltrim(aHelpPor[nI])
	Next nI
	NgHelp("." + cGrupo + cOrdem + ".", cHelp, .T.)

	RestArea(aArea)
	Return

User Function verferi(dData)
	Local lRet    := .F.
	Local cAlias  := Alias()
	Local aFeriado:= {}
	Local nI      := 0

	SX5->(DbSetOrder(1))
	SX5->(DbSeek(xFilial("SX5") + "63", .F.))
	While SX5->(!Eof()) .and. SX5->X5_TABELA == "63"
		cString := Alltrim(SubStr(SX5->X5_DESCRI, 1, 8))
		If Len(cString) == 8
			cString := "'" + cString + "'"
			aAdd(aFeriado, Ctod(cString))
		Else
			cString := "'" + cString + "/" + StrZero(Year(dDataBase),4,0) + "'"
			aAdd(aFeriado, Ctod(cString))
		EndIf
		SX5->(DbSkip())
	EndDo

	For nI := 1 To Len(aFeriado)
		If dData == aFeriado[nI]
			lRet := .T.
		EndIf
	Next nI

	DbSelectArea(cAlias)
	Return(lRet)

User Function cean14(cCod13)
	Local nOdd  := 0
	Local nEven := 0
	Local nI
	Local nDig
	Local nMul := 10

	For nI := 1 to 13
		If (nI%2) == 0
			nEven += val(substr(cCod13,nI,1))
		Else
			nOdd += val(substr(cCod13,nI,1))
		Endif
	Next
	nDig := nEven + (nOdd*3)
	While nMul<nDig
		nMul += 10
	Enddo
	Return strzero(nMul-nDig,1)