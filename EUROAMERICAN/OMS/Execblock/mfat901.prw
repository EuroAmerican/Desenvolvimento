#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} mfat901
//Rotina para retornar o status do romaneio de transporte no browse do PV, campo C5_XSTROMA
@author mjlozzardo
@since 24/04/2018
@version 1.0
/*/
User Function mfat901(cNumNF, cSerNF)
	Local cAlias := Alias()
	Local cStatus:= ""
	Local cChvSZF:= ""
	Local cChvSZG:= ""

	SZF->(DbSetOrder(1))  //NUM.ROMANEIO
	SZG->(DbSetOrder(2))  //Filial + EMPFIL + NOTA + SERIE

	//cChvSZG := FWxFilial("SZG") + Alltrim(SM0->M0_CODIGO) + Alltrim(SM0->M0_CODFIL) + cNumNF + cSerNF
	cChvSZG := xFilial("SZG") + Alltrim(xFilial("SC5")) + cNumNF + cSerNF
	If SZG->(DbSeek(cChvSZG, .F.))
		//While SZG->(!Eof()) .and. cChvSZG == FWxFilial("SZG") + Alltrim(SZG->ZG_EMPFIL) + SZG->ZG_NOTA + SZG->ZG_SERIE
		While SZG->(!Eof()) .and. cChvSZG == xFilial("SZG") + Alltrim(SZG->ZG_EMPFIL) + SZG->ZG_NOTA + SZG->ZG_SERIE
		  //If SZG->ZG_NUM > cChvSZF
		  	cChvSZF := SZG->ZG_NUM
		  //EndIf
		  SZG->(DbSkip())
		EndDo

		//SZF->(DbSeek(FWxFilial("SZF") + cChvSZF, .F.))
		SZF->(DbSeek(xFilial("SZF") + cChvSZF, .F.))
		If SZF->ZF_STATUS == "1"
			cStatus := "Aberto"
		ElseIf SZF->ZF_STATUS == "2"
			cStatus := "Em Separacao"
		ElseIf SZF->ZF_STATUS == "3"
			cStatus := "Veiculo Carregado"
		ElseIf SZF->ZF_STATUS == "4"
			cStatus := "Em Transito"
		ElseIf SZF->ZF_STATUS == "5" //.and. SZF->ZF_LOG == 0
			cStatus := "Entrega nao validada"
		//ElseIf SZF->ZF_STATUS == "5" //.and. SZF->ZF_LOG >= 1
		//	cStatus := "Entrega com retorno"
		ElseIf SZF->ZF_STATUS == "6"
			cStatus := "Entrega s/retorno"
		ElseIf SZF->ZF_STATUS == "7"
			cStatus := "Cancelado"
		ElseIf SZF->ZF_STATUS == "8"
			cStatus := "Roteirizado"
		Else
			cStatus := "Sem romaneio"
		EndIf
	Else
		cStatus := "Sem romaneio"
	EndIf

	DbSelectArea(cAlias)
	Return(cStatus)
