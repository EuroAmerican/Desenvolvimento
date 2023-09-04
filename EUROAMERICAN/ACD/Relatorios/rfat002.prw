#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} rfat002
//Relatorio pra pre-separacao de estoque.
@author mjlozzardo
@since 04/06/2018
@version 1.0
@type function
/*/
User Function rfat002()
	Local aSays    := {}
	Local aButtons := {}
	Local aHelpPor := {}
	Local nOpca    := 0
	Local cTitoDlg := "Relação de itens para pre-separação"
	Local cPerg    := "RFAT002"

	//Pergunta 01
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o endereço de")
	aAdd(aHelpPor, "expedição")
	U_FATUSX1(cPerg, "01", "End.Expedição","End.Expedição","End.Expedição","MV_CH1","C",15,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SBE","","","","","", aHelpPor, aHelpPor, aHelpPor)

	aAdd(aSays, "Está rotina tem o objetivo de, gerar a relação dos produtos que devem ser transferidos")
	aAdd(aSays, "para o armazem de expedição. Para que as ordens de separação sempre busque primeiro nesse")
	aAdd(aSays, "endereço.")
	aAdd(aSays, "As transferencias devem ocorrer antes de gerar as ordens de separação.")

	aAdd(aButtons,{5, .T., {|o| Pergunte(cPerg, .T.)}})
	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	If nOpca == 1
		Pergunte(cPerg, .F.)
		Processa({|| rfat02OK("Gerando relatório....")})
	EndIf

Static Function rfat02OK()
	Local cArqDst := "C:\TOTVS\RFAT002_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel  := FWMsExcelEX():New()
	Local cQuery  := ""
	Local cNomPla := "RFAT002"
	Local cTitPla := "Transferencias para local de expedição"
	Local cNomWrk := "RFAT002"
	Local lAbre   := .F.
	Local aLocal  := {}

	MakeDir("C:\TOTVS")

	cQuery := "SELECT C9_PRODUTO, C9_LOCAL, B1_DESC, C9_LOTECTL, SUM(C9_QTDLIB) C9_QTDLIB,"
	cQuery += "  ISNULL((SELECT SUM(SBFA.BF_QUANT)"
    cQuery += "   FROM " + RetSqlName("SBF") + " SBFA"
	cQuery += "   WHERE SBFA.BF_FILIAL = '" + xFilial("SBF") + "'"
	cQuery += "     AND SBFA.BF_LOCAL = C9_LOCAL"
	cQuery += "     AND LEFT(SBFA.BF_LOCALIZ,3) = '" + SubStr(MV_PAR01, 1, 3) + "'"
	cQuery += "     AND SBFA.BF_PRODUTO = C9_PRODUTO"
	cQuery += "     AND SBFA.D_E_L_E_T_ = ''), 0) AS SLD_Q01,"
    cQuery += "  ISNULL((SELECT SUM(BF_QUANT)"
    cQuery += "   FROM " + RetSqlName("SBFB.SBF") + " SBFB"
	cQuery += "   WHERE SBFB.BF_FILIAL = '" + xFilial("SBF") + "'"
	cQuery += "     AND SBFB.BF_LOCAL = C9_LOCAL"
	cQuery += "     AND LEFT(SBFB.BF_LOCALIZ,3) <> '" + SubStr(MV_PAR01, 1, 3) + "'"
	cQuery += "     AND SBFB.BF_PRODUTO = C9_PRODUTO"
	cQuery += "     AND SBFB.D_E_L_E_T_ = ''), 0) AS SLD_Q03"
	cQuery += " FROM " + RetSqlName("SC9") + " SC9, " + RetSqlName("SC6") + " SC6, " + RetSqlName("SF4") + " SF4, " + RetSqlName("SB1") + " SB1"
	cQuery += " WHERE C9_FILIAL = '" + xFilial("SC9") + "'"
	cQuery += "   AND C9_BLEST = ''"
	cQuery += "   AND C9_BLCRED = ''"
	cQuery += "   AND C9_ORDSEP = ''"
	cQuery += "   AND SC9.D_E_L_E_T_ = ''"
	cQuery += "   AND C6_FILIAL = '" + xFilial("SC6") + "'"
	cQuery += "   AND C6_NUM = C9_PEDIDO"
	cQuery += "   AND C6_ITEM = C9_ITEM"
	cQuery += "   AND SC6.D_E_L_E_T_ = ''"
	cQuery += "   AND F4_FILIAL = '" + xFilial("SF4") + "'"
	cQuery += "   AND F4_CODIGO = C6_TES"
	cQuery += "   AND F4_ESTOQUE = 'S'"
	cQuery += "   AND SF4.D_E_L_E_T_ = ''"
	cQuery += "   AND B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery += "   AND B1_COD = C9_PRODUTO"
	cQuery += "   AND SB1.D_E_L_E_T_ = ''"
	cQuery += " GROUP BY C9_PRODUTO, C9_LOCAL, B1_DESC, C9_LOTECTL"
	cQuery += " ORDER BY C9_PRODUTO"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB1", .F., .F.)
	TcSetField("TRB1", "C9_QTDLIB", "N", 12, 3)
	TcSetField("TRB1", "SLD_Q01"  , "N", 12, 3)
	TcSetField("TRB1", "SLD_Q03"  , "N", 12, 3)

	oExcel:AddworkSheet(cNomWrk)
	oExcel:AddTable(cNomPla, cTitPla)
	oExcel:AddColumn(cNomPla, cTitPla, "Produto"    , 1, 1, .F.)  //01
	oExcel:AddColumn(cNomPla, cTitPla, "Descrição"  , 1, 1, .F.)  //02
	oExcel:AddColumn(cNomPla, cTitPla, "Almox"      , 1, 1, .F.)  //03
	oExcel:AddColumn(cNomPla, cTitPla, "Lote"       , 1, 1, .F.)  //04
	oExcel:AddColumn(cNomPla, cTitPla, "End.Existentes" , 1, 1, .F.)  //05
	oExcel:AddColumn(cNomPla, cTitPla, "Qtd.Lib"    , 3, 2, .T.)  //06
	oExcel:AddColumn(cNomPla, cTitPla, "Sld.Q01"    , 3, 2, .T.)  //07
	oExcel:AddColumn(cNomPla, cTitPla, "Sld.Q03"    , 3, 2, .T.)  //08
	oExcel:AddColumn(cNomPla, cTitPla, "Necessidade", 3, 2, .T.)  //09

	SBF->(DbSetOrder(2))  //produto+almox+lote+localiz
	TRB1->(DbGoTop())
	ProcRegua(TRB1->(LastRec()))
	While TRB1->(!Eof())
		If TRB1->SLD_Q01 - TRB1->C9_QTDLIB < 0
			lAbre := .T.

			cLocaliz := ""
			aLocal   := {}
			If SBF->(DbSeek(xFilial("SBF") + TRB1->(C9_PRODUTO + C9_LOCAL), .F.))
				While SBF->(!Eof()) .and. SBF->(BF_FILIAL + BF_PRODUTO + BF_LOCAL) == xFilial("SBF") + TRB1->(C9_PRODUTO + C9_LOCAL)
					If SBF->BF_QUANT > 0 .and. SBF->BF_LOTECTL == TRB1->C9_LOTECTL
						aAdd(aLocal, Rtrim(SBF->BF_LOCALIZ))
					EndIf
					SBF->(DbSkip())
				EndDo
			EndIf
			aLocal := aSort(aLocal)
			For nI := 1 To Len(aLocal)
				cLocaliz += aLocal[nI] + If(Right(aLocal[nI],1) $ "2|3", "**", "") + "|"
			Next nI

			oExcel:AddRow(cNomPla, cTitPla, {TRB1->C9_PRODUTO, TRB1->B1_DESC, TRB1->C9_LOCAL, TRB1->C9_LOTECTL, cLocaliz,;  //01,02,03,04,05
											 TRB1->C9_QTDLIB,;  //06
											 TRB1->SLD_Q01,;  //07
											 TRB1->SLD_Q03,;  //08
											 TRB1->(SLD_Q01 - C9_QTDLIB) * -1})  //09
		EndIf
		TRB1->(DbSkip())
		IncProc("Gerando arquivo, aguarde...")
	EndDo
	TRB1->(DbCloseArea())
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
