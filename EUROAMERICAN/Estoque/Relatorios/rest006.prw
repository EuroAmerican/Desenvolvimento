#include 'protheus.ch'
#include 'parmtype.ch'
User Function rest006()
	Local aSays    := {}
	Local aButtons := {}
	Local aHelpPor := {}
	Local nOpca    := 0
	Local cTitoDlg := "Relação dos empenhos em aberto"
	Local cPerg    := "REST006"

	//Pergunta 01
	aHelpPor := {}
	aAdd(aHelpPor, "Dt.Inicia a ser ")
	aAdd(aHelpPor, "considerada.")
	U_FATUSX1(cPerg, "01", "Empenho De","Empenho De","Empenho De","MV_CH1","D",8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 02
	aHelpPor := {}
	aAdd(aHelpPor, "Dt.Final a ser ")
	aAdd(aHelpPor, "considerada.")
	U_FATUSX1(cPerg, "02", "Empenho Ate","Empenho Ate","Empenho Ate","MV_CH2","D",8,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	aAdd(aSays, "Está rotina tem o objetivo de, gerar a relação dos empenhos em aberto no periodo")
	aAdd(aSays, "informado na opcao parametros.")
	aAdd(aSays, "ATENCAO, CONSIDERA APENAS OS DADOS DA EMPRESA LOGADA.")

	aAdd(aButtons,{5, .T., {|o| Pergunte(cPerg, .T.)}})
	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	If nOpca == 1
		Pergunte(cPerg, .F.)
		Processa({|| rest06ok("Gerando relatório...")})
	EndIf
	Return

Static Function rest06ok()
	Local cArqDst := "C:\TOTVS\rest006_emp_" + SM0->M0_CODIGO + "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel  := FWMsExcelEX():New()
	Local cQuery  := ""
	Local cNomPla := "Empresa_" + Rtrim(SM0->M0_NOME)
	Local cTitPla := "Relacao dos empenhos"
	Local cNomWrk := "Empresa_" + Rtrim(SM0->M0_NOME)
	Local lAbre   := .F.

	MakeDir("C:\TOTVS")

	cQuery := "SELECT D4_FILIAL, D4_COD, B1_DESC, D4_LOCAL, D4_DATA, B1_UM, SUM(D4_QUANT) D4_QUANT"
	cQuery += " FROM " + RetSqlName("SD4") + " SD4, " + RetSqlName("SB1") + " SB1"
	cQuery += " WHERE D4_DATA >= '" + Dtos(MV_PAR01) + "'"
	cQuery += "   AND D4_DATA <= '" + Dtos(MV_PAR02) + "'"
	cQuery += "   AND D4_QUANT <> 0"
	cQuery += "   AND SD4.D_E_L_E_T_ = ''"
	cQuery += "   AND B1_FILIAL = ''"
	cQuery += "   AND B1_COD = D4_COD"
	cQuery += "   AND SB1.D_E_L_E_T_ = ''"
	cQuery += " GROUP BY D4_FILIAL, D4_COD, B1_DESC, D4_LOCAL, D4_DATA, B1_UM"
	cQuery += " ORDER BY D4_FILIAL, D4_COD, D4_LOCAL"
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB1", .F., .F.)
	TcSetField("TRB1", "D4_DATA", "D", 8, 0)
	TcSetField("TRB1", "D4_DATA", "D", 8, 0)

	oExcel:AddworkSheet(cNomWrk)
	oExcel:AddTable(cNomPla, cTitPla)
	oExcel:AddColumn(cNomPla, cTitPla, "Filial"   , 1, 1, .F.)  //01
	oExcel:AddColumn(cNomPla, cTitPla, "Produto"  , 1, 1, .F.)  //02
	oExcel:AddColumn(cNomPla, cTitPla, "Descrição", 1, 1, .F.)  //03
	oExcel:AddColumn(cNomPla, cTitPla, "Almox"    , 1, 1, .F.)  //04
	oExcel:AddColumn(cNomPla, cTitPla, "Data"     , 1, 1, .F.)  //05
	oExcel:AddColumn(cNomPla, cTitPla, "UM"       , 1, 1, .F.)  //06
	oExcel:AddColumn(cNomPla, cTitPla, "Saldo"    , 3, 2, .T.)  //07

	TRB1->(DbGoTop())
	ProcRegua(TRB1->(LastRec()))
	While TRB1->(!Eof())
		lAbre := .T.
		oExcel:AddRow(cNomPla, cTitPla, {TRB1->D4_FILIAL, TRB1->D4_COD, TRB1->B1_DESC, TRB1->D4_LOCAL, ;  //01,02,03,04
										 TRB1->D4_DATA,;  //05
										 TRB1->B1_UM,;  //06
										 TRB1->D4_QUANT})  //07
		TRB1->(DbSkip())
		IncProc("Processando item " + TRB1->D4_COD + ", aguarde...")
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