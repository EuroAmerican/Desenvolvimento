#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} rfat003
//Relatório para gerar os pedidos aptos a gerarem ordem de separacao
@author mjlozzardo
@since 11/06/2018
@version 1.0
@type function
/*/
User Function rfat003()
	Local aSays    := {}
	Local aButtons := {}
	Local aHelpPor := {}
	Local nOpca    := 0
	Local cTitoDlg := "Pedidos liberados para gerar Ordem de Separação"
	Local cPerg    := "RFAT003"

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
	aAdd(aHelpPor, "Informe se deve considerado os ")
	aAdd(aHelpPor, "pedidos liberados parcialmente.")
	U_FATUSX1(cPerg, "03", "Lib.Parcial","Lib.Parcial","Lib.Parcial","MV_CH3","N",1,0,2,"C","","MV_PAR03","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	aAdd(aSays, "Esse relatorio gera a listagem com os pedidos aptos a gerar as Ordens de Separacao.")
	aAdd(aSays, "Apenas os pedidos já liberados Credito e Estoque serao considerados.")

	aAdd(aButtons,{5, .T., {|o| Pergunte(cPerg, .T.)}})
	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	If nOpca == 1
		Pergunte(cPerg, .F.)
		Processa({|| rfat03OK("Gerando relatório....")})
	EndIf
	Return

Static Function rfat03OK()
	Local cArqDst := "C:\TOTVS\RFAT003_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel  := FWMsExcelEX():New()
	Local cQuery  := ""
	Local cNomPla := "RFAT003"
	Local cTitPla := "Pedidos aptos a gerar Ordem de separacao"
	Local cNomWrk := "RFAT003"
	Local lAbre   := .F.
	Local aDados  := {}
	Local nI      := 0
	Local lVai    := .F.

	MakeDir("C:\TOTVS")

	cQuery := "SELECT C6_NUM, C6_ITEM, C6_PRODUTO, C6_QTDVEN, C6_TES, C6_ENTREG,"
	cQuery += " ISNULL(C9_QTDLIB, 0) C9_QTDLIB, ISNULL(C9_BLEST, 'XX') C9_BLEST,"
	cQuery += " ISNULL(C9_BLCRED, 'XX') C9_BLCRED, ISNULL(C9_ORDSEP, 'XXXXXX') C9_ORDSEP"
	cQuery += " FROM " + RetSqlName("SC6") + " SC6"
	cQuery += "  LEFT JOIN " + RetSqlName("SC9") + " SC9"
	cQuery += "    ON C9_FILIAL = '" + xFilial("SC9") + "'"
	cQuery += "   AND C9_PEDIDO = C6_NUM"
	cQuery += "   AND C9_ITEM = C6_ITEM"
	cQuery += "   AND SC9.D_E_L_E_T_ = ''"
	cQuery += " , " + RetSqlName("SC5") + " SC5, " + RetSqlName("SF4") + " SF4"
	cQuery += " WHERE C6_FILIAL = '" + xFilial("SC6") + "'"
	cQuery += "   AND C6_ENTREG >= '" + Dtos(MV_PAR01) + "'"
	cQuery += "   AND C6_ENTREG <= '" + Dtos(MV_PAR02) + "'"
	cQuery += "   AND C6_QTDENT = 0"
	cQuery += "   AND C6_BLQ = ''"
	cQuery += "   AND SC6.D_E_L_E_T_ = ''"
	cQuery += "   AND C5_FILIAL = '" + xFilial("SC5") + "'"
	cQuery += "   AND C5_NUM = C6_NUM"
	cQuery += "   AND C5_LIBEROK = 'S'"
	cQuery += "   AND SC5.D_E_L_E_T_ = ''"
	cQuery += "   AND F4_FILIAL = '" + xFilial("SF4") + "'"
	cQuery += "   AND F4_CODIGO = C6_TES"
	cQuery += "   AND F4_ESTOQUE = 'S'"
	cQuery += "   AND SF4.D_E_L_E_T_ = ''"
	cQuery += " ORDER BY C6_NUM, C6_ITEM"
  	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB1", .F., .F.)

	oExcel:AddworkSheet(cNomWrk)
	oExcel:AddTable(cNomPla, cTitPla)
	oExcel:AddColumn(cNomPla, cTitPla, "Pedido"      , 1, 1, .F.)  //01
	oExcel:AddColumn(cNomPla, cTitPla, "Cliente"     , 1, 1, .F.)  //02
	oExcel:AddColumn(cNomPla, cTitPla, "Loja"        , 1, 1, .F.)  //03
	oExcel:AddColumn(cNomPla, cTitPla, "Razao Social", 1, 1, .F.)  //04
	oExcel:AddColumn(cNomPla, cTitPla, "UF"          , 1, 1, .F.)  //05
	oExcel:AddColumn(cNomPla, cTitPla, "Cidade"      , 1, 1, .F.)  //06
	oExcel:AddColumn(cNomPla, cTitPla, "Vendedor"    , 1, 1, .F.)  //07

	TRB1->(DbGoTop())
	ProcRegua(TRB1->(LastRec()))
	cNumPV := TRB1->C6_NUM
	lVai   := .T.
	While TRB1->(!Eof())
		SF4->(DbSeek(xFilial("SF4") + TRB1->C6_TES, .F.))
		If cNumPV == TRB1->C6_NUM
			If MV_PAR03 == 1 //lib.parcial
				If !Empty(TRB1->(C9_BLEST + C9_BLCRED + C9_ORDSEP)) .and. lVai
					lVai := .F.
				EndIf
			Else
				If (TRB1->C6_QTDVEN == TRB1->C9_QTDLIB) .and. !Empty(TRB1->(C9_BLEST + C9_BLCRED + C9_ORDSEP)) .and. lVai
					lVai := .F.
				EndIf
			EndIf
			TRB1->(DbSkip())
			IncProc("Processando pedido " + cNumPV + " ,aguarde...")
			Loop
		Else
			If lVai
				aAdd(aDados, cNumPV)
			EndIf
			cNumPV := TRB1->C6_NUM
			lVai   := .T.
		EndIf
	EndDo
	TRB1->(DbCloseArea())

	SC5->(DbSetOrder(1))
	SA1->(DbSetOrder(1))
	SA3->(DbSetOrder(1))
	For nI := 1 To Len(aDados)
		SC5->(DbSeek(xFilial("SC5") + aDados[nI], .F.))
		SA1->(DbSeek(xFilial("SA1") + SC5->(C5_CLIENTE + C5_LOJAENT), .F.))
		SA3->(DbSeek(xFilial("SA3") + SC5->C5_VEND1, .F.))
		oExcel:AddRow(cNomPla, cTitPla, {SC5->C5_NUM, SC5->C5_CLIENTE, SC5->C5_LOJACLI, SA1->A1_NOME, SA1->A1_EST, SA1->A1_MUN, SA3->A3_NOME})
		lAbre := .T.
	Next nI

	If lAbre
		oExcel:Activate()
		oExcel:GetXMLFile(cArqDst)
		OPENXML(cArqDst)
		oExcel:DeActivate()
	Else
		MsgInfo("Não existe dados para serem impressos.", "SEM DADOS")
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
