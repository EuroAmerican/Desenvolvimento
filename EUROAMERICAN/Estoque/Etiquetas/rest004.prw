#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} rest004
//Rotina para impressao, chamado via mta650mnu
@author mjlozzardo
@since 30/07/2018
@version 1.0
@type function
/*/
user function rest004()
	Local cAlias  := Alias()
	Local cPerg   := "rest004"
	Local cTipoBar:= ""
	Local cEof    := Chr(13) + Chr(10)
	Local aDados  := {}

	AjustSX1()

	SB1->(DbSetOrder(1))
	CB5->(DbSetOrder(1))
	CB0->(DbSetOrder(7))

	If Pergunte(cPerg, .T.)
		Pergunte(cPerg, .F.)
		If CB5->(DbSeek(xFilial("CB5") + MV_PAR01, .F.))
			If !Usacb0("01")
				cTipoBar := 'MB04'
			EndIf

			//Imprime etiqueta
			Set Century Off // IMPRESSAO COM O DOIS DiGITOS DO ANO.
			SB1->(DbSeek(xFilial("SB1") + SC2->C2_PRODUTO, .F.))

			dbSelectArea("SB8")
			dbSetOrder(3)
			If dbSeek(xFilial("SB8")+SC2->C2_PRODUTO+SC2->C2_LOCAL+Padr(SubStr(SC2->C2_NUM, 1, 6),10))
				dDtVld := SB8->B8_DTVALID
				dDtFab := SB8->B8_DFABRIC
			Else
				dDtVld := SC2->C2_XDTVALI
				dDtFab := SC2->C2_EMISSAO
			EndIf
			
			CB5SetImp(MV_PAR01)
			aDados := {}
			aAdd(aDados, IIF(!EMPTY(SB1->B1_U_DESC2),Rtrim(Substr(SB1->B1_U_DESC2,1,25)),Rtrim(Substr(SB1->B1_DESC,1,25))))	//01 descricao
			aAdd(aDados, Padr(Rtrim(SB1->B1_COD),15))	//02 codigo
			aAdd(aDados, Padr(Rtrim(SB1->B1_CODBAR),15))	//03 ean13
			aAdd(aDados, Padr(SubStr(SC2->C2_NUM, 1, 6),10))	//04  op/lote
			aAdd(aDados, Iif(MV_PAR02 <= 0, 1, MV_PAR02))  //05 quantidade
			aAdd(aDados, dDtVld)	//06 Data Validade
			aAdd(aDados, dDtFab)	//07 Data Fabricação

			If !Empty(SB1->B1_CODBAR)
				U_IACD001("005", aDados)  //IMPRIMIR QUALY media
				MscbClosePrinter()
			Else
				MsgStop("Código de barras não preenchido para o produto, solicitar cadastro!")
			EndIf
			Set Century On  //Termino da impressao

		EndIf
	EndIf
	DbSelectArea(cAlias)
	Return

Static Function AjustSX1()
	Local cAlias   := Alias()
	Local aHelpPor := {}

	//Pergunta 01
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o local de impressão")
	aAdd(aHelpPor, "das etiquetas")
	U_FATUSX1("rest004","01","Local de Impressão ?","Local de Impressão ?","Local de Impressão ?","MV_CH1","C",6,0,0,"G",'ExistCpo("CB5")',"MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","CB5","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 02
	aHelpPor := {}
	aAdd(aHelpPor, "Quantidade de etiquetas")
	U_FATUSX1("rest004","03","Qtd etiqueta ?","Qtd etiqueta ?","Qtd etiqueta ?","MV_CH2","N",3,0,0,"G",'',"MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	DbSelectArea(cAlias)
	Return
