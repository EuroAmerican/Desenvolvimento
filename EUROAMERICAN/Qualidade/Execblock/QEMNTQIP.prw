#include "parmtype.ch"
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"
#include "Colors.ch"
#include "RwMake.ch"

/*/{Protheus.doc} QEMNTQIP rotina para ajuste de datas de facrição e vencimento de acordo com o laudo
//ajuste de datas de facrição e vencimento de acordo com o laudo
@Autor Fabio Carneiro 
@since 27/06/2022
@version 1.0
@type user function 
/*/

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

User Function QEMNTQIP()

Local aSays        := {}
Local aButtons     := {}
Local cTitoDlg     := "Ajusta os laudos antigos em relação a data de fabricação e validade - EURO "
Local nOpca        := 0
Private _cPerg     := "QEQIP44"
Private aPlanilha  := {}

aAdd(aSays, "Rotina para ajustar os laudos antigos em relação a data de Fabricação e Validade ")
aAdd(aSays, "Esta rotina acerta data Fab./Val. de acrodo com o laudo para impressão da etiqueta!")
aAdd(aSays, "Deverá informar somente o codigo do PI que ajusta todos envases, caso exista!")

aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

FormBatch(cTitoDlg, aSays, aButtons)

If nOpca == 1
	
	oAjustaSx1()

	If !Pergunte(_cPerg,.T.)
		Return
	Else 
		MontaDir("C:\TOTVS\")
		Processa({|| QEMNTQIPok("Gerando carga de dados, aguarde...")})
	Endif
		
EndIf

Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEMNTQIPok| Autor: | EURO          | Data: | 27/06/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEMNTQIPok                                   |
+------------+-----------------------------------------------------------+
*/

Static Function QEMNTQIPok()

Local cArqDst          := "C:\TOTVS\QEMNTQIP_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
Local oExcel           := FWMsExcelEX():New()
Local cPlan            := "Empresa_" + Rtrim(SM0->M0_CODIGO) + "_Filial_" + Rtrim(SM0->M0_CODFIL)
Local cTit             := "Conferência ajuste de laudo"

Local lAbre            := .F.
Local nPlan            := 0 
Local cQuery           := ""
Local cQry             := ""

oExcel:AddworkSheet(cPlan)
oExcel:AddTable(cPlan, cTit)
oExcel:AddColumn(cPlan, cTit, "Status"             , 1, 1, .F.)  //01
oExcel:AddColumn(cPlan, cTit, "Produto"            , 1, 1, .F.)  //02
oExcel:AddColumn(cPlan, cTit, "Desc. Produto"      , 1, 1, .F.)  //03
oExcel:AddColumn(cPlan, cTit, "Tipo Produto"       , 1, 1, .F.)  //04
oExcel:AddColumn(cPlan, cTit, "Num. Lote"          , 1, 1, .F.)  //05
oExcel:AddColumn(cPlan, cTit, "Data Fabricação"    , 1, 1, .F.)  //06
oExcel:AddColumn(cPlan, cTit, "Data Validade"      , 1, 1, .F.)  //07

If Select("TRBP") > 0
	TRBP->(DbCloseArea())
EndIf

cQuery := "SELECT C2_FILIAL, ZD_PRODUT, B1_DESC, B1_TIPO, ZD_LOTE, ZD_DTFABR, ZD_DTVALID, C2_NUM, C2_PRODUTO, C2_DTETIQ, C2_XDTVALI, C2_DTFABR, C2_DTVALID " + CRLF
cQuery += "FROM "+RetSqlName("SC2")+" AS SC2 WITH (NOLOCK) " + CRLF 
cQuery += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 ON SUBSTRING(C2_PRODUTO,1,3) = SUBSTRING(B1_COD,1,3) " + CRLF
cQuery += " AND SB1.D_E_L_E_T_ = ' '  " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SZD")+" AS SZD ON SUBSTRING(C2_FILIAL,1,2) = ZD_FILIAL " + CRLF
cQuery += " AND C2_NUM = ZD_LOTE " + CRLF
cQuery += " AND SUBSTRING(C2_PRODUTO,1,3) = SUBSTRING(ZD_PRODUT,1,3) " + CRLF
cQuery += " AND SZD.D_E_L_E_T_ = ' '  " + CRLF
cQuery += "WHERE C2_FILIAL = '"+xFilial("SC2")+"' " + CRLF
cQuery += " AND C2_PRODUTO = '"+AllTrim(MV_PAR01)+"' " + CRLF
cQuery += " AND C2_NUM     = '"+AllTrim(MV_PAR02)+"' " + CRLF
cQuery += " AND SC2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += " GROUP BY C2_FILIAL, ZD_PRODUT, B1_DESC, B1_TIPO, ZD_LOTE, ZD_DTFABR, ZD_DTVALID, C2_NUM, C2_PRODUTO, C2_DTETIQ, C2_XDTVALI, C2_DTFABR, C2_DTVALID " + CRLF 

TCQuery cQuery New Alias "TRBP"

TRBP->(DbGoTop())

While TRBP->(!Eof())

	cQry := "UPDATE "+RetSqlName("SC2")+" SET C2_DTETIQ = ZD_DTFABR, C2_XDTVALI = ZD_DTVALID, C2_DTFABR = ZD_DTFABR, C2_DTVALID = ZD_DTVALID " + CRLF
	cQry += "FROM "+RetSqlName("SC2")+" AS SC2  " + CRLF
	cQry += "INNER JOIN "+RetSqlName("SZD")+" AS SZD ON SUBSTRING(C2_FILIAL,1,2) = ZD_FILIAL  " + CRLF
	cQry += " AND C2_NUM = ZD_LOTE " + CRLF
	cQry += " AND SUBSTRING(C2_PRODUTO,1,3) = SUBSTRING(ZD_PRODUT,1,3) " + CRLF
	cQry += " AND SZD.D_E_L_E_T_ = ' ' " + CRLF
	cQry += "WHERE C2_FILIAL = '"+xFilial("SC2")+"'  " + CRLF
	cQry += " AND C2_NUM = '"+AllTrim(TRBP->C2_NUM)+"' " + CRLF
	cQry += " AND C2_PRODUTO = '"+AllTrim(TRBP->C2_PRODUTO)+"' " + CRLF
	cQry += " AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	
	TcSQLExec(cQry)

	aAdd(aPlanilha,{AllTrim("Atualizado"),;       //01
							TRBP->C2_PRODUTO,;    //02
 						    TRBP->B1_DESC,;       //03        
							TRBP->B1_TIPO,;       //04	 
							TRBP->ZD_LOTE,;       //05	 
							StoD(TRBP->ZD_DTFABR),;  //06
							StoD(TRBP->ZD_DTVALID)})  //07	     
			
	TRBP->(DbSkip())

	IncProc("Gerando arquivo...")	

EndDo

If Len(aPlanilha) > 0

	For nPlan:=1 To Len(aPlanilha)
			
		lAbre := .T.

		oExcel:AddRow(cPlan,cTit,{aPlanilha[nPlan][01],;
								aPlanilha[nPlan][02],;
								aPlanilha[nPlan][03],;
								aPlanilha[nPlan][04],;
								aPlanilha[nPlan][05],;
								aPlanilha[nPlan][06],;
								aPlanilha[nPlan][07]}) 
	Next nPlan

EndIf

If lAbre

	oExcel:Activate()
	oExcel:GetXMLFile(cArqDst)
	OPENXML(cArqDst)
	oExcel:DeActivate()

Else

	MsgInfo("Não existe dados para serem impressos.", "SEM DADOS")

EndIf

If Select("TRBP") > 0
	TRBP->(DbCloseArea())
EndIf

Return

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | OPENXML   | Autor: | EURO          | Data: | 27/06/22     |
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
| Programa:  | oAjustaSx1 | Autor: | QUALY         | Data: | 27/06/22     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - Perguntas                                     |
+------------+------------------------------------------------------------+
*/
Static Function oAjustaSx1()

Local _aPerg  := {}  // aRRAY 
Local _ni

Aadd(_aPerg,{"Cod. Produto ...?","mv_ch1","C",15,"G","mv_par01","","","","","","SB1","","",0})
Aadd(_aPerg,{"Lote Laudo .....?","mv_ch2","C",10,"G","mv_par02","","","","","","SZD","","",0})

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
// fim
