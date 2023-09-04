#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} mt450cols
//PE usado para incluir informacoes na tela de liberacao de credito manual.
@author mjlozzardo
@since 24/10/2018
@version 1.0
/*/
User Function mt450cols()
	Local cAlias := Alias()
	Local aDados := ParamIxb[2]
	Local dDtSer := Ctod("  /  /  ")

	AC9->(DbSetOrder(2))
	If AC9->(DbSeek(xFilial("AC9") + "SA1" + xFilial("AC9") + SA1->A1_COD + SA1->A1_LOJA, .F.))
		While AC9->(!Eof()) .and. xFilial("AC9") + "SA1" + xFilial("AC9") + SA1->A1_COD + SA1->A1_LOJA == AC9->(AC9_FILIAL + AC9_ENTIDA + AC9_FILENT) + Alltrim(AC9->AC9_CODENT)
			//If Alltrim(AC9->AC9_USER) = 'Juliana.Antunes'
				dDtSer := AC9->AC9_DATA
			//EndIf
			AC9->(DbSkip())
		EndDo
		If !Empty(dDtSer)
			aAdd(aDados, {"Ultimo SERASA", Space(10) + Dtoc(dDtSer), " ", " ", " ", " "})
		EndIf
	EndIf
	DbSelectArea(cAlias)
	Return(aDados)
