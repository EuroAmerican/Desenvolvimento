#include 'protheus.ch'
#include 'parmtype.ch'
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"

#define ENTER chr(13) + chr(10)

/*/{Protheus.doc}QEFAT004
//ACERTA HORA REFERENTE AS NOTAS DE ENTRADA COM FORMULARIO PROPRIO
@author Fabio Carneiro dos Santos 
@since 03/03/2021
@version 1.0
/*/

User Function QEFAT004()

    Local aSays    := {}
	Local aButtons := {}
	Local nOpca    := 0
	Local cTitoDlg := "GRAVA HORA PARA NOTAS ENTRADA ENVIO SEFAZ"
    Private _cPerg := "QEFAT04"

	// Prepara e executa a pergunta do relatorio

	aAdd(aSays, "Esta rotina tem por objetivo acertar a hora das notas entradas para envio a SEFAZ")
    aAdd(aSays, "Será gravado os dados F1_HORA, para transmissão a Sefaz")
  
	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	
    If nOpca == 1
	
		oAjustaSx1()

		If !Pergunte(_cPerg,.T.)
			Return
		Else 
			Processa({|| QEFATSF1ok("Gravando Tabela Complemento de Produto...")})
		Endif
		
	EndIf
	Return

/*
+------------+------------+--------+---------------+-------+--------------+
| Programa:  | QEFATSF1ok | Autor: | QUALY         | Data: | 03/03/21     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEFATSF1ok                                    |
+------------+------------------------------------------------------------+
*/

Static Function QEFATSF1ok()

Local cQueryA       := ""

Private TRB1        := GetNextAlias()

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf

cQueryA := "SELECT F1_FILIAL, F1_DOC, F1_SERIE, F1_EMISSAO, F1_FORMUL, F1_FORNECE,F1_LOJA, F1_TIPO, F1_COND " + ENTER
cQueryA += " FROM " + RetSqlName("SF1") + "  AS SF1 " + ENTER
cQueryA += " WHERE F1_FILIAL = '"+xFilial("SF1")+"' " + ENTER
cQueryA += " AND F1_EMISSAO BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' " + ENTER
cQueryA += " AND F1_DOC   BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'   " + ENTER
cQueryA += " AND F1_SERIE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'   " + ENTER
cQueryA += " AND F1_FORMUL = 'S'   " + ENTER
cQueryA += " AND F1_CHVNFE = ' '  " + ENTER
cQueryA += " AND SF1.D_E_L_E_T_ = ' '  " + ENTER
cQueryA += " ORDER BY F1_DOC  " + ENTER

TcQuery cQueryA ALIAS "TRB1" NEW

TRB1->(DbGoTop())
	
ProcRegua(TRB1->(LastRec()))
	
While TRB1->(!Eof())

	dbSelectArea("SF1")
    dbSetOrder(1)
	SF1->(DbGoTop())
    
	If DbSeek(xFilial("SF1")+TRB1->F1_DOC+TRB1->F1_SERIE+TRB1->F1_FORNECE+TRB1->F1_LOJA+TRB1->F1_TIPO)

        RecLock("SF1",.F.)
           
			If Empty(TRB1->F1_COND)

				F1_COND  := "99"
			
			EndIf 

			F1_HORA  := Time()

        SF1->(MsUnlock())	

	EndIf

    TRB1->(DbSkip())

    IncProc("Gerando arquivo...")

EndDo

SF1->(DbCloseArea())
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

Aadd(_aPerg,{"Data Emissao De  ....?"        ,"mv_ch1","D",08,"G","mv_par01","","","","","","","","",0})
Aadd(_aPerg,{"Data Emissao Até ....?"        ,"mv_ch2","D",08,"G","mv_par02","","","","","","","","",0})

Aadd(_aPerg,{"Num. Nota De ........?"        ,"mv_ch3","C",09,"G","mv_par03","","","","","","","","",0})
Aadd(_aPerg,{"Num. Nota Ate........?"        ,"mv_ch4","C",09,"G","mv_par04","","","","","","","","",0})

Aadd(_aPerg,{"Serie Nota De .......?"        ,"mv_ch5","C",03,"G","mv_par05","","","","","","","","",0})
Aadd(_aPerg,{"Serie Nota Ate.......?"        ,"mv_ch6","C",03,"G","mv_par06","","","","","","","","",0})

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


