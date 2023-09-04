#include 'protheus.ch'
#include 'parmtype.ch'
#Include "Topconn.ch" 
#Include "Tbiconn.ch"

#define ENTER chr(13) + chr(10)

/*/{Protheus.doc} QEQIE001
//Rotina para extrair os laudos da qualidade para atender a auditoria da ISO
@author Fabio Carneiro dos Santos 
@since 05/02/2021
@version 1.0
@type QEQEI01ok
/*/
User Function QEQIE001()

	Local aSays    := {}
	Local aButtons := {}
	Local nOpca    := 0
	Local cTitoDlg := "Posição das Analises Qualidade "
	Private _cPerg := "QEQEI01"


	aAdd(aSays, "Está rotina tem o objetivo de, gerar a relacao da analise em excel.")
	aAdd(aSays, "Devera ser informado o Produto De/Até e Data da Analise De/Até.")
		
	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	If nOpca == 1
	
		oAjustaSx1()

		If !Pergunte(_cPerg,.T.)
			Return
		Else 
			Processa({|| QEQEI01ok("Gerando relatório...")})
		EndIf
	
	EndIf
	
Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEQEI01ok | Autor: | QUALY         | Data: | 04/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEQEI01ok                                    |
+------------+-----------------------------------------------------------+
*/
Static Function QEQEI01ok()
	
	Local cArqDst   := "C:\TOTVS\QEQIE001_EMP_" + SM0->M0_CODIGO + "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel    := FWMsExcelEX():New()
	Local cQuery    := ""
	Local cNomPla   := "Empresa_" + Rtrim(SM0->M0_NOME)
	Local cTitPla   := "Analises para Conferencia"
	Local cNomWrk   := "Empresa_" + Rtrim(SM0->M0_NOME)
	Local lAbre     := .F.
	Local cSuperior := ""
	Local cStatus   := ""

	MakeDir("C:\TOTVS")

	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf

	cQuery := "SELECT ZD_FILIAL,ZD_CODANAL, ZD_DATA, ZD_PRODUT, ZD_DESCRI, ZD_ITEM,ZD_ENSAIO, " + ENTER
	cQuery += "   ZD_DENSAI, ZD_LINF, ZD_LSUP, ZD_RNUM, ZD_RTEXTP, ZD_RTEXTO, ZD_LIMITE, " + ENTER
	cQuery += "   ZD_STATUS,ZD_ANALIS " +ENTER
	cQuery += " FROM " + RetSqlName("SZD") + " AS SZD " + ENTER
	cQuery += " WHERE SZD.ZD_FILIAL = '"+xFilial("SZD")+"' " + ENTER
	cQuery += "   AND SZD.ZD_PRODUT BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " + ENTER
	cQuery += "   AND SZD.ZD_DATA >= '20200101' " + ENTER
	cQuery += "   AND SZD.ZD_DATA BETWEEN '"+Dtos(MV_PAR03)+"' AND '"+Dtos(MV_PAR04)+"' " + ENTER
	cQuery += "   AND SZD.D_E_L_E_T_ = ' ' " + ENTER
	cQuery += "   ORDER BY ZD_CODANAL, ZD_ITEM, ZD_DATA   " + ENTER

		
	TcQuery cQuery ALIAS "TRB1" NEW
	
	oExcel:AddworkSheet(cNomWrk)
	oExcel:AddTable(cNomPla, cTitPla)
	oExcel:AddColumn(cNomPla, cTitPla, "Filial "               , 1, 1, .F.)  //01
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo Analise"        , 1, 1, .F.)  //02
	oExcel:AddColumn(cNomPla, cTitPla, "Data Analise"          , 1, 1, .F.)  //03
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo Produto"        , 1, 1, .F.)  //04
	oExcel:AddColumn(cNomPla, cTitPla, "Descrição Produto"     , 1, 1, .F.)  //05
	oExcel:AddColumn(cNomPla, cTitPla, "Item Produto"          , 1, 1, .F.)  //06
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo Ensaio"         , 1, 1, .F.)  //07
	oExcel:AddColumn(cNomPla, cTitPla, "Descrição Ensaio"      , 1, 1, .F.)  //08
	oExcel:AddColumn(cNomPla, cTitPla, "Limite Inferior"       , 3, 1, .F.)  //09
	oExcel:AddColumn(cNomPla, cTitPla, "Limite Superior"       , 3, 1, .F.)  //10
	oExcel:AddColumn(cNomPla, cTitPla, "Result. Number"        , 3, 1, .F.)  //11
	oExcel:AddColumn(cNomPla, cTitPla, "Result. Texto Padrão"  , 1, 1, .F.)  //12
	oExcel:AddColumn(cNomPla, cTitPla, "Result. Texto"         , 1, 1, .F.)  //13
	oExcel:AddColumn(cNomPla, cTitPla, "Limite Medio"          , 1, 1, .F.)  //14
	oExcel:AddColumn(cNomPla, cTitPla, "Status"                , 1, 1, .F.)  //15
	oExcel:AddColumn(cNomPla, cTitPla, "Analista Responsavel"  , 1, 1, .F.)  //16
	
    TRB1->(DbGoTop())
	ProcRegua(TRB1->(LastRec()))
	While TRB1->(!Eof())
		lAbre := .T.
		
		If TRB1->ZD_LIMITE = '1'
			cSuperior := "Intervalo"
		Elseif TRB1->ZD_LIMITE = '2'
			cSuperior := "Superior"
		ElseIf TRB1->ZD_LIMITE = '3'
			cSuperior  := "Inferior"
		Endif 

		If  TRB1->ZD_STATUS = 'A'
			cStatus :="Aprovado"
		ElseIf TRB1->ZD_STATUS = 'R'
			cStatus :="Reprovado"
		ElseIf TRB1->ZD_STATUS = 'C'
			cStatus :="Aprov. Restrição"
		EndIf 

		dData := Substr(TRB1->ZD_DATA,7,2)+"/"+Substr(TRB1->ZD_DATA,5,2)+"/"+Substr(TRB1->ZD_DATA,1,4)
                                                                                     
		
		oExcel:AddRow(cNomPla, cTitPla, {TRB1->ZD_FILIAL,TRB1->ZD_CODANAL, dData, TRB1->ZD_PRODUT, TRB1->ZD_DESCRI,;  
		                                 TRB1->ZD_ITEM,TRB1->ZD_ENSAIO,TRB1->ZD_DENSAI, TRB1->ZD_LINF, TRB1->ZD_LSUP, TRB1->ZD_RNUM,;                
										 TRB1->ZD_RTEXTP, IIF(TRB1->ZD_RTEXTO='C',"Conforme","Não Conforme"),;
										cSuperior,cStatus,TRB1->ZD_ANALIS})              
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

Aadd(_aPerg,{"Produtos De  ....?"   ,"mv_ch1","C",20,"G","mv_par01","","","","","","","","",0})
Aadd(_aPerg,{"Produtos Até ....?"   ,"mv_ch2","C",20,"G","mv_par02","","","","","","","","",0})
Aadd(_aPerg,{"Data Analise De  .?"  ,"mv_ch3","D",08,"G","mv_par03","","","","","","","","",0})
Aadd(_aPerg,{"Data Analise Até .?"  ,"mv_ch4","D",08,"G","mv_par04","","","","","","","","",0})

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


