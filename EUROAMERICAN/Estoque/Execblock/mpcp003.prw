#include 'protheus.ch'
#include 'parmtype.ch'
User Function mpcp003()
	Local aSays    := {}
	Local aButtons := {}
	Local nOpca    := {}
	Local aHelpPor := {}
	Local cTitoDlg := "Relação de Faltas"
	Local cPerg    := "MPCP003"

	//Pergunta 01
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o numedo da OP inicial")
	aAdd(aHelpPor, "a ser considerada.")
	U_FATUSX1("MPCP003","01","Ordem De ?","Ordem De ?","Ordem De ?","MV_CH1","C",11,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SC2","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 02
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o numedo da OP final")
	aAdd(aHelpPor, "a ser considerada.")
	U_FATUSX1("MPCP003","02","Ordem Ate ?","Ordem Ate ?","Ordem Ate ?","MV_CH2","C",11,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SC2","","","","","", aHelpPor, aHelpPor, aHelpPor)

	aAdd(aSays, "Rotina para demonstrar as faltas de materiais, por ordem de producao.")
	aAdd(aSays, "Essa rotina considera o saldo atual do produto, todos os empenhos ")
	aAdd(aSays, "em aberto no sistema.")
	aAdd(aSays, "Essa rotina nao projeta o SALDO")

	aAdd(aButtons,{5, .T., {|o| Pergunte(cPerg, .T.)}})
	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	If nOpca == 1
		Pergunte(cPerg, .F.)
		Processa({|| mpcp03ok("Aguarde, processando movimentos...")})
	EndIf
	Return

Static Function mpcp03ok()
	Local cQuery := ""
	Local nSldB2 := 0
	Local nQtdD4 := 0
	Local cLocCQ := Rtrim(GetMV("MV_CQ")) + "|" + Rtrim(GetMV("MV_LOCPROC"))

	Local cArqDst := "C:\WINDOWS\TEMP\MPCP003_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local cNomPla := "Empenhos"
	Local cTitPla := "Relação dos componentes com falta de estoque"
	Local cNomWrk := "Empenhos"
	Local oExcel  := FWMsExcelEX():New()
	Local lAbre   := .F.

	oExcel:AddworkSheet(cNomWrk)
	oExcel:AddTable(cNomPla, cTitPla)
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo"   , 1, 1, .F.)  //01
	oExcel:AddColumn(cNomPla, cTitPla, "Descricao", 1, 1, .F.)  //02
	oExcel:AddColumn(cNomPla, cTitPla, "Ordem"    , 1, 1, .F.)  //03
	oExcel:AddColumn(cNomPla, cTitPla, "Quantid"  , 3, 2, .F.)  //04
	oExcel:AddColumn(cNomPla, cTitPla, "Saldo B2" , 3, 2, .F.)  //05
	oExcel:AddColumn(cNomPla, cTitPla, "Empenhos" , 3, 2, .F.)  //06
	oExcel:AddColumn(cNomPla, cTitPla, "Sld.Calc.", 3, 2, .F.)  //07

	cQuery := "SELECT SD4.D4_COD, B1_DESC, SD4.D4_OP, SUM(SD4.D4_QUANT) D4_QUANT,"
	cQuery += "  ISNULL((SELECT SUM(B2_QATU) FROM " + RetSqlName("SB2") + " SB2"
	cQuery += "   WHERE B2_FILIAL = '" + xFilial("SB2") + "'"
	cQuery += "     AND B2_COD = SD4.D4_COD"
	cQuery += "	    AND B2_LOCAL NOT IN " + FormatIn(cLocCQ, "|")
	cQuery += "	    AND SB2.D_E_L_E_T_ = ''), 0) AS SLDB2,"
	cQuery += "  ISNULL((SELECT SUM(EMP.D4_QUANT) FROM " + RetSqlName("SD4") + " EMP"
	cQuery += "   WHERE EMP.D4_FILIAL = '" + xFilial("SD4") + "'"
	cQuery += "     AND EMP.D4_COD = SD4.D4_COD"
	cQuery += "     AND EMP.D4_OP <> SD4.D4_OP"
	cQuery += "	    AND EMP.D_E_L_E_T_ = ''), 0) AS SLDD4"
	cQuery += " FROM " + RetSqlName("SD4") + " SD4, " + RetSqlName("SB1") + " SB1"
	cQuery += " WHERE SD4.D4_FILIAL = '" + xFilial("SD4") + "'"
	cQuery += "   AND LEFT(SD4.D4_OP, 6) >= '" + MV_PAR01 + "'"
	cQuery += "   AND LEFT(SD4.D4_OP, 6) <= '" + MV_PAR02 + "'"
	cQuery += "   AND SD4.D_E_L_E_T_ = ''"
	cQuery += "   AND B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery += "   AND B1_COD = SD4.D4_COD"
	cQuery += "   AND SB1.D_E_L_E_T_ = ''"
	cQuery += " GROUP BY SD4.D4_COD, B1_DESC, SD4.D4_OP"
	cQuery += " ORDER BY SD4.D4_OP, SD4.D4_COD"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB1", .F., .F.)
	TcSetField("TRB1", "D4_QUANT", "N", 17, 6)
	TcSetField("TRB1", "SLDB2"   , "N", 17, 6)
	TcSetField("TRB1", "SLDD4"   , "N", 17, 6)

	TRB1->(DbGoTop())
	ProcRegua(TRB1->(LastRec()))
	While TRB1->(!Eof())

		If (TRB1->SLDB2 - TRB1->D4_QUANT - TRB1->SLDD4) < 0
			lAbre := .T.

			oExcel:AddRow(cNomPla, cTitPla,;
			{TRB1->D4_COD,;		//01
			 TRB1->B1_DESC,;	//02
			 TRB1->D4_OP,;		//03
			 TRB1->D4_QUANT,;	//04
			 TRB1->SLDB2,;		//05
			 TRB1->SLDD4,;		//06
			 TRB1->(SLDB2 - D4_QUANT - SLDD4)})//07
		EndIf
		TRB1->(DbSkip())
		IncProc("Processando lançamentos, aguarde...")
	EndDo
	TRB1->(DbCloseArea())

	//ABRE PLANILHA
	If lAbre
		oExcel:Activate()
		oExcel:GetXMLFile(cArqDst)
		OPENXML(cArqDst)
		oExcel:DeActivate()
	EndIf
	Return Nil

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
