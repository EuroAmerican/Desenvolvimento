#include 'protheus.ch'
#include 'parmtype.ch'
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"

#define ENTER chr(13) + chr(10)

/*/{Protheus.doc} QEFAT089
@TYPE Rotina para extrair relatorio LAYOUT da tabela
@author Fabio Carneiro dos Santos 
@since 21/02/2021
@version 1.0
/*/
User Function QEFAT089()

Private _cPerg := "QEFAT89R"

oAjustaSx1()

If !Pergunte(_cPerg,.T.)
	Return
Else 
	Processa({|| QEFAT089ok("Gerando relatório...")})
Endif

Return

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEVDA01ok | Autor: | QUALY         | Data: | 04/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEEST01ok                                    |
+------------+-----------------------------------------------------------+
*/

Static Function QEFAT089ok()

	Local cArqDst      := "C:\TOTVS\QEFAT089_EMP_" + SM0->M0_CODIGO + "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel       := FWMsExcelEX():New()
	Local cQuery       := ""

	Local cTipoNota    := ""
	Local nCalcContrib := 0
	Local cNomPla      := "Empresa_1" + Rtrim(SM0->M0_NOME)

	Local dDataA       := ""
	Local dDataB       := ""
	
	Local cTitPla      := " "
	
	Local cNomWrk      := "Empresa_1" + Rtrim(SM0->M0_NOME)

	Local lAbre        := .F.
	
	Private TRB1       := GetNextAlias()
	
	dDataA             := Substr(DTOS(dDataBase),5,2)+"/"+Substr(DTOS(dDataBase),1,4)
	cTitPla            := "Layout Refente a Carga da Tabela de Preço "
	
	MakeDir("C:\TOTVS")

	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf
	
	cQuery  := " SELECT DA0_CODTAB , DA0_DESCRI, DA0_DATDE AS DA0_VIGINI, DA0_DATATE AS DA0_VIGFIM, DA1_CODPRO, B1_DESC, B1_TIPO, DA1_GRUPO, DA1_ZPMARG, " + ENTER
    cQuery  += " DA1_PRCVEN, B1_CUSTNET, DA1_ITEM  " + ENTER
    cQuery  += " FROM " + RetSqlName("DA0") + " AS DA0 " + ENTER
    cQuery  += " INNER JOIN " + RetSqlName("DA1") + " AS DA1 WITH (NOLOCK) ON DA0_CODTAB = DA1_CODTAB " + ENTER
    cQuery  += " INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '    '  " + ENTER
    cQuery  += "  AND B1_COD = DA1_CODPRO " + ENTER
    cQuery  += "WHERE SUBSTRING(DA1_CODTAB,1,1) = 'E' " + ENTER
    cQuery  += " AND B1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " + ENTER
    cQuery  += " AND DA0_CODTAB BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'  " + ENTER
    cQuery  += " AND B1_MSBLQL = '2'  " + ENTER
    cQuery  += " AND DA0.D_E_L_E_T_ = ' '   " + ENTER
    cQuery  += " AND DA1.D_E_L_E_T_ = ' '   " + ENTER
    cQuery  += " AND SB1.D_E_L_E_T_ = ' '   " + ENTER
    cQuery  += " GROUP BY DA0_CODTAB , DA0_DESCRI, DA0_DATDE, DA0_DATATE, DA1_CODPRO, B1_DESC, B1_TIPO, DA1_GRUPO, DA1_ZPMARG, " + ENTER
    cQuery  += " DA1_PRCVEN, B1_CUSTNET, DA1_ITEM  " + ENTER

	TcQuery cQuery ALIAS "TRB1" NEW

	
	oExcel:AddworkSheet(cNomWrk)
	oExcel:AddTable(cNomPla, cTitPla)
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo tabela"     , 1, 1, .F.)  //01
	oExcel:AddColumn(cNomPla, cTitPla, "Descrição Tabela"  , 1, 2, .F.)  //02
	oExcel:AddColumn(cNomPla, cTitPla, "Vigencia Inicial"  , 1, 2, .F.)  //03
	oExcel:AddColumn(cNomPla, cTitPla, "Vigencia Inicial"  , 1, 1, .F.)  //04
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo Produto"    , 1, 1, .F.)  //05
	oExcel:AddColumn(cNomPla, cTitPla, "Descrição Produto" , 1, 1, .F.)  //06
	oExcel:AddColumn(cNomPla, cTitPla, "Grupo Produto"     , 1, 1, .F.)  //07
    oExcel:AddColumn(cNomPla, cTitPla, "Margem"            , 3, 2, .F.)  //08
	oExcel:AddColumn(cNomPla, cTitPla, "Preço de Venda"    , 3, 2, .F.)  //09
	
	TRB1->(DbGoTop())

	ProcRegua(TRB1->(LastRec()))
	
	While TRB1->(!Eof())

		lAbre := .T.
				
		oExcel:AddRow(cNomPla, cTitPla, {TRB1->DA0_CODTAB,;
                                         TRB1->DA0_DESCRI,;    
                                         TRB1->DA0_VIGINI,;  
                                         TRB1->DA0_VIGFIM,;  
                                         TRB1->DA1_CODPRO,;  
                                         TRB1->B1_DESC,; 
                                         TRB1->DA1_GRUPO,;   
                                         TRB1->DA1_ZPMARG,;  
                                         TRB1->DA1_PRCVEN}) 
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

Aadd(_aPerg,{"Produtos De  ....?"   ,"mv_ch1","C",20,"G","mv_par01","","","","","","SB1","","",0})
Aadd(_aPerg,{"Produtos Até ....?"   ,"mv_ch2","C",20,"G","mv_par02","","","","","","SB1","","",0})

Aadd(_aPerg,{"Tabela Preço De..?"   ,"mv_ch3","C",06,"G","mv_par03","","","","","","DA0" ,"","",0})
Aadd(_aPerg,{"Tabela Preço Até.?"   ,"mv_ch4","C",06,"G","mv_par04","","","","","","DA0" ,"","",0})


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

