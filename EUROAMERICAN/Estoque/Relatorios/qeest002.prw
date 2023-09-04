#include 'protheus.ch'
#include 'parmtype.ch'
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"

#define ENTER chr(13) + chr(10)

/*/{Protheus.doc} QEEST002
//Rotina para extrair relatorio de saldo em estoque de lotes
@author Fabio Carneiro dos Santos 
@since 04/01/2021
@version 1.0
/*/
User Function QEEST002()

	Local aSays    := {}
	Local aButtons := {}
	Local nOpca    := 0
	Local cTitoDlg := "Listagem de Lotes Vencidos e a Vencer"
	Private _cPerg := "QESB801"

	// Prepara e executa a pergunta do relatorio

	aAdd(aSays, "Este relatorio lista o saldo dos Lotes de acordo com a data vencimento,")
	aAdd(aSays, "Este relatorio não lista saldo zerado.")
	aAdd(aSays, "Para Produtos vencidos digitar até a data base de hoje por exemplo .")
	aAdd(aSays, "Para Produtos a Vencer digitar da data de hoje ate 31/12/2049 por exemplo .")
	aAdd(aSays, "Para as MP/ME será listado a data de validade com 00/00/0000, devido não possuir lote interno.")
	aAdd(aSays, "Para MPs, esta sendo considerado o ultimo lote do fornecedor digitado na NF de entrada! ")
	aAdd(aSays, "Para MPs sem lote de fornecedor esta sendo considerado a data da ultima compra! ")
	
	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	If nOpca == 1
	
		oAjustaSx1()

		If !Pergunte(_cPerg,.T.)
			Return
		Else 
			Processa({|| QEEST01ok("Gerando relatório...")})
		Endif
		
	EndIf
	Return

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEEST01ok | Autor: | QUALY         | Data: | 04/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEEST01ok                                    |
+------------+-----------------------------------------------------------+
*/

Static Function QEEST01ok()

	Local cArqDst  := "C:\TOTVS\QEEST002_EMP_" + SM0->M0_CODIGO + "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel   := FWMsExcelEX():New()
	Local cQuery   := ""
	Local cQueryA  := ""
	Local cQueryB  := ""
	Local cNomPla  := "Empresa_1" + Rtrim(SM0->M0_NOME)
	
	Local cTitPla  := "Saldos de lotes para conferencia"
	
	Local cNomWrk  := "Empresa_1" + Rtrim(SM0->M0_NOME)

	Local lAbre   := .F.
	
	Private TRB1      := GetNextAlias()
	Private TRB2      := GetNextAlias()
	Private TRB3      := GetNextAlias()

	MakeDir("C:\TOTVS")

	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf
	
	cQuery := "SELECT '" + Rtrim(SM0->M0_NOME) + "' EMP, B8_FILIAL, B8_PRODUTO, B1_DESC, B1_TIPO, B8_LOCAL, B1_UM, " +ENTER  
	cQuery += " B8_LOTECTL, B8_DATA, B8_DTVALID, B8_SALDO, B2_CM1 " + ENTER
	cQuery += " FROM " + RetSqlName("SB8") + " SB8 " + ENTER
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_COD = B8_PRODUTO " + ENTER
	cQuery += " INNER JOIN " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) ON B1_COD = B2_COD " +ENTER
	cQuery += " WHERE SB8.B8_PRODUTO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " +ENTER
	cQuery += "   AND SB8.B8_DTVALID BETWEEN '"+Dtos(MV_PAR03)+"' AND '"+Dtos(MV_PAR04)+"' " +ENTER
	cQuery += "   AND B1_TIPO BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + ENTER
	cQuery += "   AND B8_FILIAL = B2_FILIAL " +ENTER
	cQuery += "   AND B8_LOCAL  = B2_LOCAL  " +ENTER
	cQuery += "   AND B8_SALDO > 0  " +ENTER
	cQuery += "   AND B1_RASTRO = 'L'  " + ENTER
	cQuery += "   AND SB8.D_E_L_E_T_ = ' ' " +ENTER
	cQuery += "   AND SB1.D_E_L_E_T_ = ' ' " +ENTER 
	cQuery += "   AND SB2.D_E_L_E_T_ = ' '  " +ENTER
	cQuery += "ORDER BY B8_SALDO DESC " + ENTER
	
	TcQuery cQuery ALIAS "TRB1" NEW

	If Select("TRB2") > 0
		TRB2->(DbCloseArea())
	EndIf

	cQueryA := "  SELECT '" + Rtrim(SM0->M0_NOME) + "' EMP, B2_FILIAL, B2_COD, B1_DESC, B1_TIPO, B2_LOCAL, B1_UM, " + ENTER  
	cQueryA += "   B1_UCOM, B2_QATU, B2_CM1 " + ENTER
	cQueryA += " FROM " + RetSqlName("SB2") + " AS SB2 " + ENTER 
	cQueryA += " INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_COD = B2_COD " + ENTER
	cQueryA += "  AND SB2.D_E_L_E_T_ = ' ' " + ENTER
	cQueryA += "   AND SB1.D_E_L_E_T_ = ' ' " + ENTER
	cQueryA += "  WHERE SB2.B2_COD BETWEEN    '"+MV_PAR01+"' AND '"+MV_PAR02+"'  " + ENTER
	//cQueryA += "   AND SB1.B1_UCOM BETWEEN '"+Dtos(MV_PAR05)+"' AND '"+Dtos(MV_PAR06)+"' " + ENTER
	cQueryA += "   AND B1_TIPO BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + ENTER
	cQueryA += "   AND SB2.D_E_L_E_T_ = ' ' " + ENTER
	cQueryA += "   AND SB1.D_E_L_E_T_ = ' ' " + ENTER
	cQueryA += "   AND B2_QATU > 0  " + ENTER
	cQueryA += "   AND NOT B1_RASTRO = 'L'  " + ENTER
	//cQueryA += "   AND B1_LOCALIZ  = 'N'  " + ENTER
	cQueryA += "ORDER BY B2_QATU DESC " + ENTER

	TcQuery cQueryA ALIAS "TRB2" NEW
	
	// trata lotes na tabela SB8
	
	oExcel:AddworkSheet(cNomWrk)
	oExcel:AddTable(cNomPla, cTitPla)
	oExcel:AddColumn(cNomPla, cTitPla, "Empresa"  , 1, 1, .F.)  //01
	oExcel:AddColumn(cNomPla, cTitPla, "Filial "  , 1, 1, .F.)  //02
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo"   , 1, 1, .F.)  //03
	oExcel:AddColumn(cNomPla, cTitPla, "Descricao", 1, 2, .F.)  //04
	oExcel:AddColumn(cNomPla, cTitPla, "Tipo"     , 1, 1, .F.)  //05
	oExcel:AddColumn(cNomPla, cTitPla, "Armazem"  , 1, 1, .F.)  //06
	oExcel:AddColumn(cNomPla, cTitPla, "UM"       , 1, 1, .F.)  //07
	oExcel:AddColumn(cNomPla, cTitPla, "Numero Lote"      , 1, 2, .F.)  //08
	oExcel:AddColumn(cNomPla, cTitPla, "Dt.Fabric/Ult.Comp."  , 1, 2, .F.)  //09
	oExcel:AddColumn(cNomPla, cTitPla, "Dt.Validade"  , 1, 2, .F.)  //10
	oExcel:AddColumn(cNomPla, cTitPla, "Saldo", 1, 1, .F.)  //11
	oExcel:AddColumn(cNomPla, cTitPla, "Vl. Custo Unit.", 3, 2, .F.)  //12
	oExcel:AddColumn(cNomPla, cTitPla, "Total Custo ", 3, 2, .F.)  //13

	TRB1->(DbGoTop())
	ProcRegua(TRB1->(LastRec()))
	
	While TRB1->(!Eof())
		lAbre := .T.
		
		dDataFab := Substr(TRB1->B8_DATA,7,2)+"/"+Substr(TRB1->B8_DATA,5,2)+"/"+Substr(TRB1->B8_DATA,1,4)
		dDataVal := Substr(TRB1->B8_DTVALID,7,2)+"/"+Substr(TRB1->B8_DTVALID,5,2)+"/"+Substr(TRB1->B8_DTVALID,1,4)

				
		oExcel:AddRow(cNomPla, cTitPla, {TRB1->EMP, TRB1->B8_FILIAL, TRB1->B8_PRODUTO, TRB1->B1_DESC,;      
		                                 TRB1->B1_TIPO, TRB1->B8_LOCAL, TRB1->B1_UM,;                       
										 TRB1->B8_LOTECTL,;
										  dDataFab, dDataVal,TRB1->B8_SALDO,TRB1->B2_CM1,TRB1->B8_SALDO*TRB1->B2_CM1}) 
		TRB1->(DbSkip())
		IncProc("Gerando arquivo...")
	EndDo

	TRB1->(DbCloseArea())

	TRB2->(DbGoTop())
	
	While TRB2->(!Eof())
		
		lAbre := .T.
		
		If Select("TRB3") > 0
			TRB3->(DbCloseArea())
		EndIf

		cQueryB := " SELECT MAX(D1_LOTEFOR) AS LOTEFOR FROM " + RetSqlName("SD1") + " AS SD1 " + ENTER
		cQueryB += " WHERE SD1.D_E_L_E_T_ = ' ' AND D1_COD = '"+TRB2->B2_COD+"' " + ENTER

		TcQuery cQueryB ALIAS "TRB3" NEW
		
		dDataCom := Substr(TRB2->B1_UCOM,7,2)+"/"+Substr(TRB2->B1_UCOM,5,2)+"/"+Substr(TRB2->B1_UCOM,1,4)

				
		oExcel:AddRow(cNomPla, cTitPla, {TRB2->EMP, TRB2->B2_FILIAL, TRB2->B2_COD, TRB2->B1_DESC,;      
		                                 TRB2->B1_TIPO, TRB2->B2_LOCAL, TRB2->B1_UM,;                       
										 TRB3->LOTEFOR,;
										 dDataCom, '00/00/0000',TRB2->B2_QATU,TRB2->B2_CM1,TRB2->B2_QATU*TRB2->B2_CM1}) 
		TRB2->(DbSkip())
	
	EndDo
	
	If Select("TRB2") > 0
		TRB2->(DbCloseArea())
	EndIf
	
	If Select("TRB3") > 0
		TRB3->(DbCloseArea())
	EndIf
	
	If lAbre
		oExcel:Activate()
		oExcel:GetXMLFile(cArqDst)
		OPENXML(cArqDst)
		oExcel:DeActivate()
	Else
		MsgInfo("Não existe dados para serem impressos.", "SEM DADOS")
	EndIf
	Return

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | OPENXML   | Autor: | QUALY         | Data: | 04/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - OPENXML                                      |
+------------+-----------------------------------------------------------+
*/

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

/*
+------------+------------+--------+---------------+-------+--------------+
| Programa:  | oAjustaSx1 | Autor: | QUALY         | Data: | 04/02/21     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - Perguntas                                     |
+------------+------------------------------------------------------------+
*/
Static Function oAjustaSx1()

Local _aPerg  := {}  // aRRAY 
Local _ni

Aadd(_aPerg,{"Produtos De  ....?"         ,"mv_ch1","C",20,"G","mv_par01","","","","","","SB1","","",0})
Aadd(_aPerg,{"Produtos Até ....?"         ,"mv_ch2","C",20,"G","mv_par02","","","","","","SB1","","",0})
Aadd(_aPerg,{"Dta Venc. Lote De  ....?"   ,"mv_ch3","D",08,"G","mv_par03","","","","","","","","",0})
Aadd(_aPerg,{"Dta Venc. Lote De Até .?"   ,"mv_ch4","D",08,"G","mv_par04","","","","","","","","",0})
Aadd(_aPerg,{"Dta Ult.Compra De ..?"      ,"mv_ch5","D",08,"G","mv_par05","","","","","","","","",0})
Aadd(_aPerg,{"Dta Ult.Compra Até .?"      ,"mv_ch6","D",08,"G","mv_par06","","","","","","","","",0})
Aadd(_aPerg,{"Tipo Produto De..?"         ,"mv_ch7","C",02,"G","mv_par07","","","","","","02" ,"","",0})
Aadd(_aPerg,{"Tipo Produto Até.?"         ,"mv_ch8","C",02,"G","mv_par08","","","","","","02" ,"","",0})

dbSelectArea("SX1")
For _ni := 1 To Len(_aPerg)
	If !dbSeek(_cPerg+ SPACE( LEN(SX1->X1_GRUPO) - LEN(_cPerg))+StrZero(_ni,2))
		RecLock("SX1",.T.)
		SX1->X1_GRUPO    := _cPerg
		SX1->X1_ORDEM    := StrZero(_ni,2)
		SX1->X1_PERGUNT  := _aPerg[_ni][1]
		SX1->X1_VARIAVL  := _aPerg[_ni][2]
		SX1->X1_TIPO     := _aPerg[_ni][3]
		SX1->X1_TAMANHO  := _aPerg[_ni][4]
		SX1->X1_GSC      := _aPerg[_ni][5]
		SX1->X1_VAR01    := _aPerg[_ni][6]
		SX1->X1_DEF01    := _aPerg[_ni][7]
		SX1->X1_DEF02    := _aPerg[_ni][8]
		SX1->X1_DEF03    := _aPerg[_ni][9]
		SX1->X1_DEF04    := _aPerg[_ni][10]
		SX1->X1_DEF05    := _aPerg[_ni][11]
		SX1->X1_F3       := _aPerg[_ni][12]
		SX1->X1_CNT01    := _aPerg[_ni][13]
		SX1->X1_VALID    := _aPerg[_ni][14]
		SX1->X1_DECIMAL  := _aPerg[_ni][15]
		MsUnLock()
	EndIf
Next _ni

Return

