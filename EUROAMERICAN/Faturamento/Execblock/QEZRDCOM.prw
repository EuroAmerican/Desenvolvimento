#include 'protheus.ch'
#include 'parmtype.ch'
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"

#define ENTER chr(13) + chr(10)
/*/{Protheus.doc}QEZRDCOM
Permite gravar comissão nas tabelas PAA/SB1 se não houver movimentos na tabela SC6/SCK 
@type function Rotina customizada.
@author Fabio Carneiro dos Santos 
@since 11/07/2022
@version 1.0
@return character, sem retorno especificadao
/*/
User Function QEZRDCOM()

    Local aSays    := {}
	Local aButtons := {}
	Local nOpca    := 0
	Local cTitoDlg := "REGRAVA % COMISSÃO SE NÃO HOUVER MOVIMENTO SCK/SC6 - QUALY "
    Private _cPerg := "QEZRDA1"

	// Prepara e executa a pergunta do relatorio

	aAdd(aSays, "Esta rotina tem por objetivo regravar o percentual de comissão sem movimento")
    aAdd(aSays, "Será gravado somente se não houver movimento na tabela SCK/SC6")
  
	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	
    If nOpca == 1
	
		oAjustaSx1()

		If !Pergunte(_cPerg,.T.)
			Return
		Else 
			Processa({|| QEPRVZRDok("Gravando Comissão Aguarde...")})
		Endif
		
	EndIf

Return
/*
+------------+------------+--------+---------------+-------+--------------+
| Programa:  | QEPRVZRDok | Autor: | QUALY         | Data: | 12/02/22     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEPRVZRDok                                    |
+------------+------------------------------------------------------------+
*/
Static Function QEPRVZRDok()

Local _cQueryA     := ""
Local _aLidos      := {}
Local _lCheca      := .F.
Local _cMsg        := ""
 
Private TRB1       := GetNextAlias()

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf

_cQueryA := "SELECT MAX(CK_XREVCOM) AS REVCOM " + ENTER
_cQueryA += "FROM " + RetSqlName("SCK") + " AS SCK " + ENTER
_cQueryA += " WHERE CK_FILIAL = '"+xFilial("SCK")+"' " + ENTER
_cQueryA += " AND CK_PRODUTO = '"+MV_PAR01+"' " + ENTER
_cQueryA += " AND SCK.D_E_L_E_T_ = ' '  " + ENTER
_cQueryA += " UNION  " + ENTER
_cQueryA += "SELECT MAX(C6_XREVCOM) AS REVCOM " + ENTER
_cQueryA += "FROM " + RetSqlName("SC6") + " AS SC6 " + ENTER
_cQueryA += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' " + ENTER
_cQueryA += " AND C6_PRODUTO = '"+MV_PAR01+"' " + ENTER
_cQueryA += " AND SC6.D_E_L_E_T_ = ' '  " + ENTER

TcQuery _cQueryA ALIAS "TRB1" NEW

TRB1->(DbGoTop())
	
ProcRegua(TRB1->(LastRec()))
	
While TRB1->(!Eof())

	If !Empty(TRB1->REVCOM)
	
		Aadd(_aLidos,{TRB1->REVCOM})     
	
	EndIf

	TRB1->(DbSkip())

    IncProc("Gerando arquivo...")

EndDo

If Len(_aLidos) > 0
	_lCheca := .T.
EndIf

If _lCheca
	_cMsg := "Foi encontrado movimento para o produto "+Alltrim(MV_PAR01)+" !"+ENTER
	_cMsg += "Não Será possivel fazer a alteração do percentual de comissão, favor gerar uma nova revisão !"+ENTER 
	Aviso("Atencão - QEZRDCOM ",_cMsg, {"Ok"}, 2)
Else 
	_cMsg := "Não foi encontrado movimento para o produto "+Alltrim(MV_PAR01)+" !"+ENTER
	_cMsg += "Será realizado a alteração do percentual de comissão com "+Transform(MV_PAR02, "@E 999.99")+" na cadastro de revisao e produto !"+ENTER 
	Aviso("Atencão - QEZRDCOM ",_cMsg, {"Ok"}, 2)

	If Select("TRB2") > 0
		TRB2->(DbCloseArea())
	EndIf

	_cQueryB := "SELECT * " + ENTER
	_cQueryB += "FROM " + RetSqlName("PAA") + " AS PAA " + ENTER
	_cQueryB += "WHERE PAA_FILIAL = '"+xFilial("PAA")+"' " + ENTER
	_cQueryB += " AND PAA_COD = '"+MV_PAR01+"' " + ENTER
	_cQueryB += " AND PAA_MSBLQL = '2'  " + ENTER
	_cQueryB += " AND PAA.D_E_L_E_T_ = ' '  " + ENTER
	_cQueryB += " ORDER BY PAA_COD   " + ENTER

	TcQuery _cQueryB ALIAS "TRB2" NEW

	TRB2->(DbGoTop())

	While TRB2->(!Eof())
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		If SB1->(DbSeek(xFilial("SB1")+MV_PAR01))  
			RecLock("SB1",.F.)
			SB1->B1_COMIS   := MV_PAR02
			SB1->B1_XREVCOM := TRB2->PAA_REV
			SB1->B1_XTABCOM := TRB2->PAA_CODTAB
			SB1->(MsUnlock())
		EndIf
		DbSelectArea("PAA")
		PAA->(DbSetOrder(1)) // PAA_FILIAL+PAA_COD+PAA_CODTAB+PAA_REV
		If PAA->(DbSeek(xFilial("PAA")+MV_PAR01+TRB2->PAA_CODTAB+TRB2->PAA_REV))  
			RecLock("PAA",.F.)
			PAA->PAA_COMIS1  := MV_PAR02
			PAA->(MsUnlock())
		EndIf

	TRB2->(DbSkip())

	EndDo

EndIf


If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf
If Select("TRB2") > 0
	TRB2->(DbCloseArea())
EndIf
If Select("SB1") > 0
	SB1->(DbCloseArea())
EndIf
If Select("PAA") > 0
	PAA->(DbCloseArea())
EndIf

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

Aadd(_aPerg,{"Código Produto .....?"   ,"mv_ch01","C",15,0,"G","mv_par01","","","","","","SB1","","",0})
Aadd(_aPerg,{"% Comissão .........?"   ,"mv_ch02","N",05,0,"G","mv_par02","","","","","","","","",2})

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
		SX1->X1_PRESEL   := _aPerg[_ni][5]
		SX1->X1_GSC      := _aPerg[_ni][6]
		SX1->X1_VAR01    := _aPerg[_ni][7]
		SX1->X1_DEF01    := _aPerg[_ni][8]
		SX1->X1_DEF02    := _aPerg[_ni][9]
		SX1->X1_DEF03    := _aPerg[_ni][10]
		SX1->X1_DEF04    := _aPerg[_ni][11]
		SX1->X1_DEF05    := _aPerg[_ni][12]
		SX1->X1_F3       := _aPerg[_ni][13]
		SX1->X1_CNT01    := _aPerg[_ni][14]
		SX1->X1_VALID    := _aPerg[_ni][15]
		SX1->X1_DECIMAL  := _aPerg[_ni][16]
		MsUnLock()
	EndIf
Next _ni

Return


