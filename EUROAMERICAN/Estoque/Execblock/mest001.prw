#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} mest001
//Rotina para gerar a CB0 de acordo com a OP.
@author mjlozzardo
@since 19/01/2018
@version 1.0
@type function
/*/
User Function mest001()
	Local cAlias  := Alias()
	Local nQtdCB0 := 0
	Local nQtdProd:= 0
	Local nI      := 0
	Local aDados  := {}
	Local lGera   := .F.
	Local lGerAdi := .F.

	If SM0->M0_CODIGO $ "08"
		MsgInfo("Essa rotina não pode ser executada nesta empresa.", "Sem autorização")
		Return
	EndIf

	SB1->(DbSetOrder(1))  //Codigo
	SB1->(DbSeek(xFilial("SB1") + SC2->C2_PRODUTO, .F.))

	CB0->(DbSetOrder(7))  //Ordem de producao
	If GETMV("MV_CBPE018")  //Indica se gera a CB0 no momento do apontamento da producao, caso positivo nao executa
		MsgAlert("Sistema configurado para gerar etiqueta no momento da produção, impressão não permitida.", "NÃO PERMITIDO")
		Return
	EndIf

	If MsgYesNo("Confirma a geração das etiquetas ?","GERAR ETIQUETA")  //Confirma a geracao da CB0
		If !CB0->(DbSeek(xFilial("CB0") + SC2->(C2_NUM + C2_ITEM + C2_SEQUEN), .F.))  //Nao existe registro na CB0
			If SB1->B1_TIPO $ "PA#PI"
				lGera := .T.
			Else
				MsgStop("Geração de etiquetas só permitida para PA e PI!")
			EndIf
		Else
			If MsgYesNo("Já existe etiqueta para essa ordem de produção, deseja gerar novas etiquetas ?", "JA EXISTE")
				lGera := .T.
				lGerAdi := .T.
			EndIf
		EndIf
	EndIf

	If lGera
		Pergunte("MEST001", .T.)  //Abre tela para informar a qtd sobressalente.
		Pergunte("MEST001", .F.)

		//Dados para gerar etiqueta
		aAdd(aDados, SC2->C2_NUM)	//Lote
		aAdd(aDados, "")			//SubLote
		aAdd(aDados, LastDay(SC2->C2_EMISSAO + SB1->B1_PRVALID, 2))  //Data validade

		//Calcula o numero de etiquetas
		If SB1->B1_UM == SB1->B1_SEGUM	//PI com etiqueta igual a quantidade produzida ou gerar etiqueta sobra
			MsgStop("Unidade de medida primária e secundária iguais, será gerado apenas 1 etiqueta!")
			nQtdCB0 := 1
		ElseIf SB1->B1_TIPO $ "PI" .And. SB1->B1_UM == "KG" .And. SB1->B1_SEGUM == "L"
			MsgStop("PI com unidade secundária Litros (sobra), será gerado apenas 1 etiqueta! Favor realizar a manutenção da etiqueta gerada informando quantidade correta")
			nQtdCB0 := 1
		Else
			nQtdCB0 := Int(Iif(SB1->B1_TIPCONV == "D", SC2->C2_QUANT / SB1->B1_CONV, SC2->C2_QUANT * SB1->B1_CONV))
		EndIf

		If !lGerAdi	//Se verdadeiro gerar somente adicionais

			CB0->(DbSetOrder(1))
			For nI := 1 To nQtdCB0
				nQtdProd += (SC2->C2_QUANT / nQtdCB0)
				If SB1->B1_UM == SB1->B1_SEGUM
					MEST001G(1, aDados)
				Else
					MEST001G((SC2->C2_QUANT / nQtdCB0), aDados)
				EndIf
			Next nI

			//Resto
			If (SC2->C2_QUANT - nQtdProd) > 0
				MEST001G(SC2->C2_QUANT - nQtdProd, aDados)
			EndIf

		EndIf

		//Sobressalente
		If MV_PAR01 > 0 //.and. SB1->B1_QE > 0
			For nI := 1 To MV_PAR01
				If SB1->B1_UM == SB1->B1_SEGUM
					MEST001G(1, aDados)
				Else
					MEST001G((SC2->C2_QUANT / nQtdCB0), aDados)
				EndIf
			Next nI
		EndIf

		MsgInfo("As etiquetas foram geradas, efetuar a impressão.", "TERMINO")
	EndIf

	DbSelectArea(cAlias)
	Return

Static Function MEST001G(nQuant, aLote)
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
	CB0->CB0_DTNASC := SC2->C2_EMISSAO
	CB0->CB0_TIPO   := "01"
	CB0->CB0_CODPRO := SC2->C2_PRODUTO
	CB0->CB0_QTDE   := nQuant
	CB0->CB0_USUARIO:= RetCodUsr()
	CB0->CB0_LOCAL  := SC2->C2_LOCAL
	CB0->CB0_OP     := SC2->(C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD)
	CB0->CB0_NUMSEQ := ""

	CB0->CB0_LOTE   := aLote[1]
	CB0->CB0_SLOTE  := aLote[2]
	CB0->CB0_DTVLD  := aLote[3]

	CB0->CB0_CC     := SC2->C2_CC
	CB0->CB0_ORIGEM := "SC2"
	CB0->(MsUnLock())
	Return
