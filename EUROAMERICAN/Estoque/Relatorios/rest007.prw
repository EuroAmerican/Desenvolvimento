#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} rest007
//Rotina para exportar o saldo final apos calculo do custo medio.
@author mjlozzardo
@since 07/11/2018
@version 1.0
/*/
User Function rest007()
	Local aSays    := {}
	Local aButtons := {}
	Local nOpca    := 0
	Local cTitoDlg := "Posição final após calculo do custo medio"

	aAdd(aSays, "Está rotina tem o objetivo de, gerar a relacao dos saldos finais dos itens")
	aAdd(aSays, "apos a execucao da rotina MATA330-Calculo do custo Medio.")
	aAdd(aSays, "*** ATENCAO, ESTE RELATORIO SERVE APENAS PARA CONFERENCIA ***")

	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	If nOpca == 1
		Processa({|| rest07ok("Gerando relatório...")})
	EndIf
	Return

Static Function rest07ok()
	Local cArqDst := "C:\TOTVS\REST007_EMP_" + SM0->M0_CODIGO + "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel  := FWMsExcelEX():New()
	Local cQuery  := ""
	Local cNomPla := "Empresa_" + Rtrim(SM0->M0_NOME)
	Local cTitPla := "Saldos finais para conferencia"
	Local cNomWrk := "Empresa_" + Rtrim(SM0->M0_NOME)
	Local lAbre   := .F.

	MakeDir("C:\TOTVS")

	cQuery := "SELECT '" + Rtrim(SM0->M0_NOME) + "' EMP, B2_FILIAL, B2_COD, B1_DESC, B1_TIPO, B2_LOCAL,"
	cQuery += "       B1_UM, B2_QFIM, B2_VFIM1, B2_CMFIM1"
	cQuery += " FROM " + RetSqlName("SB2") + " SB2, " + RetSqlName("SB1") + " SB1"
	cQuery += " WHERE B2_FILIAL <> ''"
	cQuery += "   AND LEFT(B2_COD, 3) <> 'MOD'"
	cQuery += "   AND (B2_QFIM <> 0 OR B2_VFIM1 <> 0)"
	cQuery += "   AND SB2.D_E_L_E_T_ = ''"
	cQuery += "   AND B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery += "   AND B1_COD = B2_COD"
	cQuery += "   AND SB1.D_E_L_E_T_ = ''"
	cQuery += " ORDER BY B2_FILIAL, B2_COD, B2_LOCAL"
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB1", .F., .F.)
	TcSetField("TRB1", "B2_QFIM"  , "N", 16, 4)
	TcSetField("TRB1", "B2_VFIM1" , "N", 16, 6)
	TcSetField("TRB1", "B2_CMFIM1", "N", 16, 4)

	oExcel:AddworkSheet(cNomWrk)
	oExcel:AddTable(cNomPla, cTitPla)
	oExcel:AddColumn(cNomPla, cTitPla, "Empresa"  , 1, 1, .F.)  //01
	oExcel:AddColumn(cNomPla, cTitPla, "Filial "  , 1, 1, .F.)  //02
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo"   , 1, 1, .F.)  //03
	oExcel:AddColumn(cNomPla, cTitPla, "Descricao", 1, 1, .F.)  //04
	oExcel:AddColumn(cNomPla, cTitPla, "Tipo"     , 1, 1, .F.)  //05
	oExcel:AddColumn(cNomPla, cTitPla, "Almox"    , 1, 1, .F.)  //06
	oExcel:AddColumn(cNomPla, cTitPla, "UM"       , 1, 1, .F.)  //07
	oExcel:AddColumn(cNomPla, cTitPla, "QtdFinal" , 3, 2, .T.)  //08
	oExcel:AddColumn(cNomPla, cTitPla, "VlrFinal" , 3, 2, .T.)  //09
	oExcel:AddColumn(cNomPla, cTitPla, "CustoUnit", 3, 2, .F.)  //10

	TRB1->(DbGoTop())
	ProcRegua(TRB1->(LastRec()))
	While TRB1->(!Eof())
		lAbre := .T.
		oExcel:AddRow(cNomPla, cTitPla, {TRB1->EMP, TRB1->B2_FILIAL, TRB1->B2_COD, TRB1->B1_DESC, ;  //01,02,03,04
		                                 TRB1->B1_TIPO, TRB1->B2_LOCAL, TRB1->B1_UM,;                //05,06,07
										 TRB1->B2_QFIM, TRB1->B2_VFIM1, TRB1->B2_CMFIM1})            //08,09,10
		TRB1->(DbSkip())
		IncProc("Gerando arquivo...")
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
