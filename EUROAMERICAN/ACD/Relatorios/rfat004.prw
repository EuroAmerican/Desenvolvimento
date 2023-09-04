#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} rfat004
//Rotina para estimar a quantidade necessaria para a pre-separacao
//ajustando os pedido considerados para efetuar aprovacao automatica
//necessario criar
// campo--> C9_XPRESEP - C - 1
// inidce-> B8_FILIAL+B8_PRODUTO+B8_LOCAL+DTOS(B8_DTVALID)+B8_LOTECTL - nickname-> SB8001
@author mjlozzardo
@since 16/07/2018
@version 1.0
@type function
/*/
User Function rfat004()
	Local aSays    := {}
	Local aButtons := {}
	Local aHelpPor := {}
	Local nOpca    := 0
	Local cTitoDlg := "Relação dos itens para pre-separacao"
	Local cPerg    := "RFAT004"

	//Pergunta 01
	aHelpPor := {}
	aAdd(aHelpPor, "Informe a data de entrega inicial")
	aAdd(aHelpPor, "a ser considerada.")
	U_FATUSX1(cPerg, "01", "Entrega De","Entrega De","Entrega De","MV_CH1","D",8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 02
	aHelpPor := {}
	aAdd(aHelpPor, "Informe a data de entrega final")
	aAdd(aHelpPor, "a ser considerada.")
	U_FATUSX1(cPerg, "02", "Entrega Ate","Entrega Ate","Entrega Ate","MV_CH2","D",8,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 03
	aHelpPor := {}
	aAdd(aHelpPor, "Indica se deve ser impresso apenas")
	aAdd(aHelpPor, "os itens com necessidade de reposição.")
	U_FATUSX1(cPerg, "03", "So necessidade","So necessidade","So necessidade","MV_CH3","N",1,0,1,"C","","MV_PAR03","Sim","Sim","Sim","","","Não","Não","Não","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 04
	aHelpPor := {}
	aAdd(aHelpPor, "Indica se deve ser impresso todos")
	aAdd(aHelpPor, "os LOTES/ENDEREÇO disponiveis, ou,")
	aAdd(aHelpPor, "apenas o necessário.")
	U_FATUSX1(cPerg, "04", "Imp.Todos Lotes","Imp.Todos Lotes","Imp.Todos Lotes","MV_CH4","N",1,0,2,"C","","MV_PAR04","Sim","Sim","Sim","","","Não","Não","Não","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	aAdd(aSays, "Está rotina tem o objetivo de gerar a lista dos pedidos que estao")
	aAdd(aSays, "bloqueados no ESTOQUE para efetuar a pre-separacao.")
	aAdd(aSays, " ")
	aAdd(aSays, "Apenas itens que movimentam estoque")

	aAdd(aButtons,{5, .T., {|o| Pergunte(cPerg, .T.)}})
	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	If nOpca == 1
		Pergunte(cPerg, .F.)
		Processa({|| RFAT04OK("Gerando lista, aguarde...")})
	EndIf
	Return

Static Function rfat04ok()
	Local cArqDst := "C:\PROTHEUS12\RFAT004_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel  := FWMsExcelEX():New()
	Local cQuery  := ""

	Local cPlanA := "RFAT004A"
	Local cTitA  := "Relação de Pedidos para pre-separação - Totais"
	Local cPlanB := "RFAT004B"
	Local cTitB  := "Relação de Pedidos para pre-separação - Itens"

	Local aItens := {}
	Local aSaldos:= {}
	Local nPos   := 0
	Local nI     := 0
	Local cProd  := ""
	Local lAbre  := .F.
	Local lFirst := .T.
	Local nSld   := 0
	Local nDisp  := 0

	cQuery := "SELECT C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, C9_LOCAL, C9_QTDLIB, C9_DATALIB,"
	cQuery += " C9_DATENT, C9_BLCRED, C9_BLEST, C9_LOTECTL, C9_ORDSEP, B1_RASTRO, B1_LOCALIZ, SC9.R_E_C_N_O_ RECSC9"
	cQuery += " FROM " + RetSqlName("SC9") + " SC9, " + RetSqlName("SC6") + " SC6, " + RetSqlName("SB1") + " SB1, " + RetSqlName("SF4") + " SF4"
	cQuery += " WHERE C9_FILIAL = '" + xFilial("SC9") + "'"
	cQuery += "   AND C9_BLCRED = '  '"
	cQuery += "   AND C9_BLEST = '02'"
	cQuery += "   AND C9_DATENT BETWEEN '" + Dtos(MV_PAR01) + "' AND '" + Dtos(MV_PAR02) + "'"
	//cQuery += "   AND C9_XPRESEP = ' '"
	cQuery += "   AND SC9.D_E_L_E_T_ = ''"
	cQuery += "   AND C6_FILIAL = '" + xFilial("SC6") + "'"
	cQuery += "   AND C6_NUM = C9_PEDIDO"
	cQuery += "   AND C6_ITEM = C9_ITEM"
	cQuery += "   AND SC6.D_E_L_E_T_ = ''"
	cQuery += "   AND B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery += "   AND B1_COD = C9_PRODUTO"
	cQuery += "   AND SB1.D_E_L_E_T_ = ''"
	cQuery += "   AND F4_FILIAL = '" + xFilial("SF4") + "'"
	cQuery += "   AND F4_CODIGO = C6_TES"
	cQuery += "   AND F4_ESTOQUE = 'S'"
	cQuery += "   AND SF4.D_E_L_E_T_ = ''"
	cQuery += " ORDER BY C9_FILIAL, C9_PEDIDO, C9_PRODUTO, C9_LOCAL"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB1", .F., .F.)

	//planilha pedidos
	oExcel:AddworkSheet(cPlanB)
	oExcel:AddTable(cPlanB, cTitB)
	oExcel:AddColumn(cPlanB, cTitB, "Pedido"   , 1, 1, .F.)  //01
	oExcel:AddColumn(cPlanB, cTitB, "Item"     , 1, 1, .F.)  //02
	oExcel:AddColumn(cPlanB, cTitB, "Produto"  , 1, 1, .F.)  //03
	oExcel:AddColumn(cPlanB, cTitB, "Descrição", 1, 1, .F.)  //04
	oExcel:AddColumn(cPlanB, cTitB, "Quant."   , 3, 2, .F.)  //05
	oExcel:AddColumn(cPlanB, cTitB, "Almox."   , 1, 1, .F.)  //06

	SB1->(DbSetOrder(1))
	TRB1->(DbGoTop())
	While TRB1->(!Eof())
		SB1->(DbSeek(xFilial("SB1") + TRB1->C9_PRODUTO, .F.))

		nPos := aScan(aItens, {|x| x[1] + x[2] == TRB1->C9_PRODUTO + TRB1->C9_LOCAL})
		If nPos > 0
			aItens[nPos, 3] += TRB1->C9_QTDLIB
		Else
			aAdd(aItens, {TRB1->C9_PRODUTO, TRB1->C9_LOCAL, TRB1->C9_QTDLIB, 0, 0})  //produto, local, qtd.lib, sldbf, necessidade
		EndIf

		//marca registro para liberacao automatica - pe mt450qry
		SC9->(DbGoTo(TRB1->RECSC9))
		SC9->(RecLock("SC9", .F.))
		SC9->C9_XPRESEP := 'S'
		SC9->(MsUnLock())

		oExcel:AddRow(cPlanB, cTitB,{TRB1->C9_PEDIDO,;
		                             TRB1->C9_ITEM,;
		                             TRB1->C9_PRODUTO,;
		                             SB1->B1_DESC,;
		                             TRB1->C9_QTDLIB,;
		                             TRB1->C9_LOCAL})
	    TRB1->(DbSkip())
	    lAbre := .T.
	EndDo
	TRB1->(DbCloseArea())

	//planilha aglutinada
	oExcel:AddworkSheet(cPlanA)
	oExcel:AddTable(cPlanA, cTitA)
	oExcel:AddColumn(cPlanA, cTitA, "Produto"   , 1, 1, .F.)  //01
	oExcel:AddColumn(cPlanA, cTitA, "Descricao" , 1, 1, .F.)  //02
	oExcel:AddColumn(cPlanA, cTitA, "UM"        , 1, 1, .F.)  //03
	oExcel:AddColumn(cPlanA, cTitA, "Almox"     , 1, 1, .F.)  //04
	oExcel:AddColumn(cPlanA, cTitA, "Qtd.Total" , 3, 2, .F.)  //05
	oExcel:AddColumn(cPlanA, cTitA, "Localiz"   , 1, 1, .F.)  //06
	oExcel:AddColumn(cPlanA, cTitA, "Prior"     , 1, 1, .F.)  //07
	oExcel:AddColumn(cPlanA, cTitA, "Qtd.Disp"  , 3, 2, .F.)  //08
	oExcel:AddColumn(cPlanA, cTitA, "Lote"      , 1, 1, .F.)  //09
	oExcel:AddColumn(cPlanA, cTitA, "Dt.Val."   , 1, 1, .F.)  //10

	//Calcula necessidade, considera endereco terminado em 00|01
	SB8->(DbSetOrder(6))  //B8_FILIAL+B8_PRODUTO+B8_LOCAL+DTOS(B8_DTVALID)+B8_LOTECTL
	SBF->(DbSetOrder(2))  //BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOTECTL+BF_NUMLOTE+BF_PRIOR+BF_LOCALIZ
	aSort(aItens,,, {|x,y| x[1] + x[2] < y[1] + y[2]})  //produto+local

	ProcRegua(Len(aItens))
	For n1 := 1 To Len(aItens)
		nDisp := 0
		nQtd1 := 0
		nQtd2 := 0
		aSaldos := {}
		If SB8->(DbSeek(xFilial("SB8") + aItens[n1, 1] + aItens[n1, 2], .F.))
			While SB8->(!Eof()) .and. SB8->(B8_FILIAL + B8_PRODUTO + B8_LOCAL) == xFilial("SB8") + aItens[n1, 1] + aItens[n1, 2]
				If SB8->B8_SALDO > 0 .and. SB8->(B8_SALDO - B8_EMPENHO) > 0
					If SBF->(DbSeek(xFilial("SBF") + SB8->(B8_PRODUTO + B8_LOCAL + B8_LOTECTL), .F.))
						While SBF->(!Eof()) .and. SBF->(BF_FILIAL + BF_PRODUTO + BF_LOCAL + BF_LOTECTL) == SB8->(B8_FILIAL + B8_PRODUTO + B8_LOCAL + B8_LOTECTL)
							If SubStr(Rtrim(SBF->BF_LOCALIZ), -2) $ "00|01"
								nQtd1 += SBF->(BF_QUANT - BF_EMPENHO)
							Else
								nQtd2 += SBF->(BF_QUANT - BF_EMPENHO)
							EndIf

							aAdd(aSaldos, {SBF->BF_PRODUTO,;  //01-Produto
		                                   SBF->BF_LOCAL,;    //02-Almox
		                                   SBF->BF_LOCALIZ,;  //03-Endereco
										   SBF->BF_PRIOR,;    //04-Prioridade
										   SB8->B8_LOTECTL,;  //05-Lote
										   SB8->B8_DTVALID,;  //06-Dt.Validade
										   SBF->(BF_QUANT - BF_EMPENHO),;  //07-Saldo
										   aItens[n1, 3]})    //08-Qtd.Liberada

							SBF->(DbSkip())
						EndDo
					EndIf
				EndIf
				SB8->(DbSkip())
			EndDo
		EndIf

		If (nQtd1 + nQtd2) == 0
			aAdd(aSaldos, {aItens[n1, 1],;  //Produto
                           aItens[n1, 2],;  //Almox
                           " ",;  //Endereco
						   " ",;  //Prioridade
						   " ",;  //Lote
						   Ctod("  /  /  "),;  //Dt.Validade
						   0,;  //Saldo
						   aItens[n1, 3]})  //Qtd.Liberada

		EndIf
		If nQtd1 - aItens[n1, 3] < 0
			aSort(aSaldos,,, {|x,y| x[1] + Dtos(x[6]) + x[4] + x[3] < y[1] + Dtos(y[6]) + y[4] + y[3]})  //produto+dt.valide+endereco
			nSld := 0
			SB1->(DbSeek(xFilial("SB1") + aSaldos[1, 1], .F.))
			oExcel:AddRow(cPlanA, cTitA,{aSaldos[1, 1],;  //produto
										 SB1->B1_DESC,;    //descricao
										 SB1->B1_UM,;      //unid.medida
										 aSaldos[1, 2],;  //almoxarifado
										 aSaldos[1, 8],;  //qtd.lib
										 aSaldos[1, 3],;  //endereco
										 aSaldos[1, 4],;  //prioridade
										 aSaldos[1, 7],;  //saldo
										 aSaldos[1, 5],;  //lote
										 Dtoc(aSaldos[1, 6])})  //validade
			nSld += aSaldos[1, 7]
			For n2 := 2 To Len(aSaldos)
				oExcel:AddRow(cPlanA, cTitA,{" ",;
											 " ",;
											 SB1->B1_UM,;
											 " ",;
											 0,;
											 aSaldos[n2, 3],;
											 aSaldos[n2, 4],;
											 aSaldos[n2, 7],;
											 aSaldos[n2, 5],;
											 Dtoc(aSaldos[n2, 6])})
				nSld += aSaldos[n2, 7]
			Next n2

			oExcel:AddRow(cPlanA, cTitA,{SB1->B1_COD,;
										 SB1->B1_DESC,;
										 SB1->B1_UM,;
										 " ",;
										 0,;
										 "TOTAL DISP",;
										 " ",;
										 nSld,;
										 " ",;
										 " "})

			oExcel:AddRow(cPlanA, cTitA,{" ",;
										 " ",;
										 " ",;
										 " ",;
										 0,;
										 " ",;
										 " ",;
										 0,;
										 " ",;
										 " "})

		EndIf
		IncProc("Aguarde, gerando planilha....")
	Next n1

	//Abre o arquivo XML, necessario que a estencao esteja associada ao MS-EXCEL.
	If lAbre
		oExcel:Activate()
		oExcel:GetXMLFile(cArqDst)
		OPENXML(cArqDst)
		oExcel:DeActivate()
	EndIf
	Return

Static Function OPENXML(cArq)
	Local cDirDocs := MsDocPath()
	Local cPath	   := AllTrim(GetTempPath())

	If !ApOleClient("MsExcel")
		Aviso("Atencao", "O Microsoft Excel nao esta instalado.", {"Ok"}, 2)
	Else
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(cArq)
		oExcelApp:SetVisible(.T.)
		oExcelApp:Destroy()
	EndIf
	Return
