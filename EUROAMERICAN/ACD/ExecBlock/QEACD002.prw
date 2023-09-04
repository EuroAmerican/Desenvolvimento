#include 'protheus.ch'
#include 'parmtype.ch'
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"

#define ENTER chr(13) + chr(10)

/*/{Protheus.doc}QEACD001
// ATUALIZA ORDEM DE SEPARAÇÃO PARA SEPARAQÇÃO DE FORMA MANUAL 
@author Fabio Carneiro dos Santos 
@since 21/04/2021
@version 1.0
@Type User Function
/*/

User Function QEACD002()

    Local aSays    := {}
	Local aButtons := {}
	Local nOpca    := 0
	Local cTitoDlg := "GRAVA STATUS INICIAL COLETOR DE DADOS SEPARAÇÃO MANUAL"
    Private _cPerg := "QEACDRA2"

	// Prepara e executa a pergunta do relatorio

	aAdd(aSays, "Esta rotina tem por objetivo gravar status inicial da ordem de separação!")
    aAdd(aSays, "Somente para separação de forma manual por meio de pedido!")
    aAdd(aSays, "Grava ordens de separação que são geradas por meio de pedido de vendas!")
	aAdd(aSays, "***** Esta rotina não permite manipular separação por nota fiscal!*******")
 
	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	
    If nOpca == 1
	
		oAjustaSx1()

		If !Pergunte(_cPerg,.T.)
			Return
		Else 
			Processa({|| QEACDCB7ok("Gravando status da ordem de separação...")})
		Endif
		
	EndIf

Return

/*
+------------+------------+--------+---------------+-------+--------------+
| Programa:  | QEACDCB7ok | Autor: | QUALY         | Data: | 03/03/21     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEACDCB7ok                                    |
+------------+------------------------------------------------------------+
*/

Static Function QEACDCB7ok()

Local cQuery        := ""
Local cQuerya       := ""
Local cQueryB       := ""

Local lPassa        := .F.

Private TRB1        := GetNextAlias()
Private TRB2        := GetNextAlias()

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf

cQuery := "SELECT * " + ENTER
cQuery += " FROM "+RetSqlName("CB7")+" AS CB7 " + ENTER
cQuery += " WHERE CB7_FILIAL = '"+xFilial("CB7")+"' " + ENTER
cQuery += " AND CB7_ORDSEP  = '"+MV_PAR01+"'  " + ENTER
cQuery += " AND CB7_NOTA = ' ' " + ENTER  
cQuery += " AND CB7_OP   = ' ' " + ENTER  
cQuery += " AND CB7.D_E_L_E_T_ = ' '  " + ENTER

TcQuery cQuery ALIAS "TRB1" NEW

TRB1->(DbGoTop())
	
ProcRegua(TRB1->(LastRec()))
	
While TRB1->(!Eof())

	DbSelectArea("CB7")
    DbSetOrder(1)
	CB7->(DbGoTop())
    
	If DbSeek(xFilial("CB7")+TRB1->CB7_ORDSEP)
		lPassa := .T.
	EndIf

	If Select("TRB2") > 0
		TRB2->(DbCloseArea())
	EndIf

	cQueryB := "SELECT TOP 1 CB8_ORDSEP, CB8_PEDIDO " + ENTER
	cQueryB += " FROM "+RetSqlName("CB8")+" AS CB8 " + ENTER
	cQueryB += " WHERE CB8_FILIAL = '"+xFilial("CB8")+"' " + ENTER
	cQueryB += " AND CB8_ORDSEP = '"+TRB1->CB7_ORDSEP+"'  " + ENTER
	cQueryB += " AND CB8.D_E_L_E_T_ = ' '  " + ENTER

	TcQuery cQueryB ALIAS "TRB2" NEW

	TRB2->(DbGoTop())

	While TRB2->(!Eof())

		If TRB2->CB8_ORDSEP == TRB1->CB7_ORDSEP 
			_cPedvendas := TRB2->CB8_PEDIDO 
    	EndIf 

		TRB2->(DbSkip())
	
	EndDo

	If lPassa
		
		cQuerya := "UPDATE " + RetSqlName("CB7") + " SET CB7_STATUS = '0' " + ENTER
		cQuerya += "FROM " + RetSqlName("CB7") + " AS CB7 WITH (NOLOCK) " + ENTER
		cQuerya += "WHERE CB7_FILIAL = '"+xFilial("CB7")+"'   " + ENTER
		cQuerya += " AND CB7_ORDSEP = '"+TRB1->CB7_ORDSEP+"'  " + ENTER
		cQuerya += " AND CB7_NOTA = ' ' " + ENTER  
		cQuerya += " AND CB7_OP   = ' ' " + ENTER  
		cQuerya += " AND CB7.D_E_L_E_T_ = ' '  " + ENTER
		
		TCSqlExec(cQuerya)

	EndIf



    TRB1->(DbSkip())

    IncProc("Gerando arquivo...")

EndDo

If lPassa

	MsgInfo("Status Inicial Retornado Com Sucesso!!!")

EndIf 


CB7->(DbCloseArea())
TRB1->(DbCloseArea())

Return Nil

/*
+------------+------------+--------+---------------+-------+--------------+
| Programa:  | oAjustaSx1 | Autor: | QUALY         | Data: | 13/02/21     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - Perguntas                                     |
+------------+------------------------------------------------------------+
*/
Static Function oAjustaSx1()

Local _aPerg  := {}  // aRRAY 
Local _ni

Aadd(_aPerg,{"Os Para Reabrir..?"        ,"mv_ch1","C",06,"G","mv_par01","","","","","","CB7","","",0})

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


