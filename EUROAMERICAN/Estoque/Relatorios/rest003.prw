#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} rest003
//Relatorio conferencia de saldo.
@author mjlozzardo
@since 04/06/2018
@version 1.0
@type function
/*/
User Function rest003()
	Local aSays    := {}
	Local aButtons := {}
	Local aHelpPor := {}
	Local nOpca    := 0
	Local cTitoDlg := "Relação de itens para conferencia de saldo"
	Local cPerg    := "rest003"

	//Pergunta 01
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o produto inicial")
	aAdd(aHelpPor, "a ser considerado.")
	U_FATUSX1(cPerg, "01", "Produto De","Produto De","Produto De","MV_CH1","C",15,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 02
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o produto final")
	aAdd(aHelpPor, "a ser considerado.")
	U_FATUSX1(cPerg, "02", "Produto Ate","Produto Ate","Produto Ate","MV_CH2","C",15,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","","", aHelpPor, aHelpPor, aHelpPor)

	aAdd(aSays, "Está rotina tem o objetivo de, gerar a relação dos produtos para conferencia do")
	aAdd(aSays, "saldo fisico.")

	aAdd(aButtons,{5, .T., {|o| Pergunte(cPerg, .T.)}})
	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	If nOpca == 1
		Pergunte(cPerg, .F.)
		Processa({|| rfat03OK("Gerando relatório....")})
	EndIf

Static Function rfat03OK()
	Local cArqDst := "C:\TOTVS\rest003_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel  := FWMsExcelEX():New()
	Local cQuery  := ""
	Local cNomPla := "rest003"
	Local cTitPla := "Itens para conferencia"
	Local cNomWrk := "rest003"
	Local lAbre   := .F.

	MakeDir("C:\TOTVS")

	cQuery := "SELECT 'A' TIPO, '" + Alltrim(SM0->M0_NOME) + "' AS EMPRESA,"
	cQuery += " B8_FILIAL AS FILIAL,"
	cQuery += " B8_LOCAL AS LOCAL,"
	cQuery += " B8_PRODUTO AS COD,"
	cQuery += " B8_SALDO AS SALDO,"
	cQuery += " B8_LOTECTL AS LOTE,"
	cQuery += " B8_SALDO - B8_EMPENHO AS SLDDISP,"
	cQuery += " '' AS OP,"
	cQuery += " 0 AS QTDEMP"
	cQuery += "FROM " + RetSqlName("SB8") + " SB8"
	cQuery += "  WHERE B8_FILIAL = '" + xFilial("SB8") + "'"
	cQuery += "    AND B8_SALDO > 0"
	cQuery += "    AND B8_PRODUTO >= '" + MV_PAR01 + "'"
	cQuery += "    AND B8_PRODUTO <= '" + MV_PAR02 + "'"
	cQuery += "    AND SB8.D_E_L_E_T_ = ''"
	cQuery += "UNION ALL "
	cQuery += "SELECT 'B' TIPO, '" + Alltrim(SM0->M0_NOME) + "' AS EMPRESA,"
	cQuery += " D4_FILIAL AS FILIAL,"
	cQuery += " D4_LOCAL AS LOCAL,"
	cQuery += " D4_COD AS COD,"
	cQuery += " 0 AS SALDO,"
	cQuery += " D4_LOTECTL AS LOTE,"
	cQuery += " 0 AS SLDDISP,"
	cQuery += " D4_OP AS OP,"
	cQuery += " SUM(D4_QUANT) AS QTDEMP"
	cQuery += " FROM " + RetSqlName("SD4") + " SD4"
	cQuery += "   WHERE D4_FILIAL = '" + xFilial("SD4") + "'"
	cQuery += "     AND D4_COD >= '" + MV_PAR01 + "'"
	cQuery += "     AND D4_COD <= '" + MV_PAR02 + "'"
	cQuery += "     AND D4_QUANT > 0"
    cQuery += "     AND SD4.D_E_L_E_T_ = ''"
	cQuery += " GROUP BY D4_FILIAL, D4_LOCAL, D4_COD, D4_LOTECTL, D4_OP"
	cQuery += " ORDER BY EMPRESA, FILIAL, LOCAL, COD, TIPO"
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB1", .F., .F.)
	TcSetField("TRB1", "SALDO"  , "N", 12, 3)
	TcSetField("TRB1", "SLDDISP", "N", 12, 3)

	oExcel:AddworkSheet(cNomWrk)
	oExcel:AddTable(cNomPla, cTitPla)
	oExcel:AddColumn(cNomPla, cTitPla, "Empresa" , 1, 1, .F.)  //01
	oExcel:AddColumn(cNomPla, cTitPla, "Filial"  , 1, 1, .F.)  //02
	oExcel:AddColumn(cNomPla, cTitPla, "Almox"   , 1, 1, .F.)  //03
	oExcel:AddColumn(cNomPla, cTitPla, "Produto" , 1, 1, .F.)  //04
	oExcel:AddColumn(cNomPla, cTitPla, "Saldo"   , 3, 2, .T.)  //05
	oExcel:AddColumn(cNomPla, cTitPla, "Lote"    , 1, 1, .F.)  //06
	oExcel:AddColumn(cNomPla, cTitPla, "Disponivel", 3, 2, .T.)  //07
	oExcel:AddColumn(cNomPla, cTitPla, "OP"      , 1, 1, .F.)  //08
	oExcel:AddColumn(cNomPla, cTitPla, "Qtd.Emp" , 3, 2, .T.)  //09
	oExcel:AddColumn(cNomPla, cTitPla, "Prod.Pai", 1, 1, .F.)  //10

	TRB1->(DbGoTop())
	ProcRegua(TRB1->(LastRec()))
	cCod := TRB1->COD
	While TRB1->(!Eof())
		lAbre := .T.
		If cCod == TRB1->COD
			oExcel:AddRow(cNomPla, cTitPla, {TRB1->EMPRESA, TRB1->FILIAL, TRB1->LOCAL, TRB1->COD,;  //01,02,03,04
											 TRB1->SALDO,;  //05
											 TRB1->LOTE,;  //06
											 TRB1->SLDDISP,;  //07
											 TRB1->OP,;  //08
											 TRB1->QTDEMP,;  //09
											 Posicione("SC2",1,xFilial("SC2") + TRB1->OP, "C2_PRODUTO")})  //10
		Else
			oExcel:AddRow(cNomPla, cTitPla, {" ", " ", " ", " ", 0, " ", 0, " "})
			cCod := TRB1->COD
			Loop
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
