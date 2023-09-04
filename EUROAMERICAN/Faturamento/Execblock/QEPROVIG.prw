#include 'protheus.ch'
#include 'parmtype.ch'
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"

#define ENTER chr(13) + chr(10)

/*/{Protheus.doc}QEPROVIG
Permite Prorrogar a comissão dos produtos com a mesma taxa de comissão!
@type function Rotina customizada.
@author Fabio Carneiro dos Santos 
@since 12/02/2022
@version 1.0
@return character, sem retorno especificadao
@History Ajustado para atender o processo de revisão de comissão - 11/07/2022
/*/

User Function QEPROVIG()

    Local aSays    := {}
	Local aButtons := {}
	Local nOpca    := 0
	Local cTitoDlg := "GERA NOVA REVISAO E NOVA VIGÊNCIA DAS COMISSÕES - QUALY "
    Private _cPerg := "QEPRVA1"

	// Prepara e executa a pergunta do relatorio

	aAdd(aSays, "Esta rotina tem por objetivo gerar nova revisão da comissão de acordo com a data final de Vigência")
    aAdd(aSays, "Será gravado somente revisão posterior ao que já existe!!!")
  	aAdd(aSays, "Esta rotina é de uso exclusivo da QUALY e não será posssivel usar em outras Filiais")
  
	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	
    If nOpca == 1
	
		oAjustaSx1()

		If !Pergunte(_cPerg,.T.)
			Return
		Else 
			Processa({|| QEPRVVIGok("Gravando Novas Vigencias Aguarde...")})
		Endif
		
	EndIf

Return
/*
+------------+------------+--------+---------------+-------+--------------+
| Programa:  | QEPRVVIGok | Autor: | QUALY         | Data: | 12/02/22     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEPRVVIGok                                    |
+------------+------------------------------------------------------------+
*/
Static Function QEPRVVIGok()

Local _cQueryA     := ""
Local _cQueryC     := ""
Local _cQry        := "" 
Local _cCODTAB     := ""
Local _cREV        := ""
Local _cCOD        := ""
Local _cDESC       := ""
Local _cTIPO       := ""
Local _cGRUPO      := ""
Local _cDSCGRP     := ""
Local _cFAMILI     := ""
Local _cDSCFAM     := ""
Local _cSUBFAM     := ""
Local _cDSCSFM     := ""
Local _cLINHA      := ""
Local _cDSCLIN     := ""

Private TRB1       := GetNextAlias()

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf

_cQueryA := "SELECT * " + ENTER
_cQueryA += " FROM " + RetSqlName("PAA") + "  AS PAA " + ENTER
_cQueryA += " WHERE PAA_FILIAL = '"+xFilial("PAA")+"' " + ENTER
_cQueryA += " AND PAA_COD    BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'   " + ENTER
_cQueryA += " AND PAA_TIPO   BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'   " + ENTER
_cQueryA += " AND PAA_GRUPO  BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'   " + ENTER
_cQueryA += " AND PAA_FAMILI BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'   " + ENTER
_cQueryA += " AND PAA_SUBFAM BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'   " + ENTER
_cQueryA += " AND PAA.D_E_L_E_T_ = ' '  " + ENTER
_cQueryA += " ORDER BY PAA_COD  " + ENTER

TcQuery _cQueryA ALIAS "TRB1" NEW

TRB1->(DbGoTop())
	
ProcRegua(TRB1->(LastRec()))
	
While TRB1->(!Eof())

	_cQry    := "" 
	_cQueryC := ""
	_cCODTAB := TRB1->PAA_CODTAB     
	_cREV    := TRB1->PAA_REV    
	_cCOD    := TRB1->PAA_COD    
	_cDESC   := AllTrim(TRB1->PAA_DESC)   
	_cTIPO   := AllTrim(TRB1->PAA_TIPO)
	_cGRUPO  := AllTrim(TRB1->PAA_GRUPO)
	_cDSCGRP := AllTrim(TRB1->PAA_DSCGRP)
	_cFAMILI := AllTrim(TRB1->PAA_FAMILI)
	_cDSCFAM := AllTrim(TRB1->PAA_DSCFAM)
	_cSUBFAM := AllTrim(TRB1->PAA_SUBFAM)
	_cDSCSFM := AllTrim(TRB1->PAA_DSCSFM)
	_cLINHA  := AllTrim(TRB1->PAA_LINHA)   
	_cDSCLIN := AllTrim(TRB1->PAA_DSCLIN)

	TRB1->(DbSkip())

	If TRB1->(EOF()) .Or. TRB1->PAA_COD <> _cCOD 

		DbSelectArea("PAA")
		PAA->(DbSetorder(1))
		PAA->(DbGotop())
		If PAA->(DbSeek(xFilial("PAA")+_cCOD+_cCODTAB+_cREV))   
			
			If Select("W1_PAA") > 0
				W1_PAA->(DbCloseArea())
			EndIf

			_cQueryC := "SELECT MAX(PAA_REV) AS REV FROM "+RetSqlName("PAA")+" AS PAA "+ ENTER 
			_cQueryC += "WHERE PAA_FILIAL = '"+xFilial("PAA")+"' "+ ENTER
			_cQueryC += " AND PAA_COD = '"+_cCOD+"'  " + ENTER
			_cQueryC += " AND PAA_CODTAB = '"+_cCODTAB+"'  " + ENTER
			_cQueryC += " AND PAA.D_E_L_E_T_ = ' '  " + ENTER

			TcQuery _cQueryC ALIAS "W1_PAA" NEW

			W1_PAA->(DbGoTop())
			
			If W1_PAA->(!Eof()) .And. W1_PAA->(!Bof()) 
			
				_cQry := "UPDATE " + RetSqlName("PAA") + " "+ ENTER
				_cQry += " SET PAA_DTVIG2 = '" + DtoS(dDataBase-1) + "', PAA_MSBLQL = '1' "+ ENTER
				_cQry += "FROM " + RetSqlName("PAA") + " AS PAA "+ ENTER
				_cQry += "WHERE PAA_FILIAL = '"+xFilial("PAA")+"' "+ ENTER
				_cQry += " AND PAA_COD    = '" + AllTrim(_cCOD) + "' "+ ENTER
				_cQry += " AND PAA_CODTAB = '" + AllTrim(_cCODTAB) + "' "+ ENTER
				_cQry += " AND PAA_REV    = '" + AllTrim(StrZero(Val(W1_PAA->REV),3)) + "' "+ ENTER
				_cQry += " AND PAA.D_E_L_E_T_ = ' ' "

				TcSQLExec(_cQry)

				DbSelectArea("PAA")
				RecLock("PAA",.T.)
														
				PAA->PAA_FILIAL := XFilial("PAA") 
				PAA->PAA_CODTAB := _cCODTAB     
				PAA->PAA_REV    := StrZero(Val(W1_PAA->REV)+1,3)    
				PAA->PAA_COD    := _cCOD    
				PAA->PAA_DESC   := AllTrim(_cDESC)   
				PAA->PAA_TIPO   := AllTrim(_cTIPO)
				PAA->PAA_GRUPO  := AllTrim(_cGRUPO)
				PAA->PAA_DSCGRP := AllTrim(_cDSCGRP)
				PAA->PAA_FAMILI := AllTrim(_cFAMILI)
				PAA->PAA_DSCFAM := AllTrim(_cDSCFAM)
				PAA->PAA_SUBFAM := AllTrim(_cSUBFAM)
				PAA->PAA_DSCSFM := AllTrim(_cDSCSFM)
				PAA->PAA_LINHA  := AllTrim(_cLINHA)   
				PAA->PAA_DSCLIN := AllTrim(_cDSCLIN)
				PAA->PAA_MSBLQL := "2" 
				PAA->PAA_DTCARG := DDATABASE
				PAA->PAA_DTVIG1 := DDATABASE
				PAA->PAA_DTVIG2 := MV_PAR11  
				PAA->PAA_COMIS1 := MV_PAR12
				PAA->PAA_COMIS2 := 0 
				PAA->PAA_COMIS3 := 0 
				PAA->PAA_COMIS4 := 0
				PAA->PAA_COMIS5 := 0 
											
				PAA->(MsUnlock())

				SB1->(DbSetOrder(1))
				SB1->(DbGoTop())
				If SB1->(DbSeek(xFilial("SB1")+_cCOD))  
					RecLock("SB1",.F.)
					SB1->B1_COMIS   := MV_PAR12
					SB1->B1_XREVCOM := StrZero(Val(W1_PAA->REV)+1,3)
					SB1->B1_XTABCOM := _cCODTAB
					SB1->(MsUnlock())
				EndIf

				_cCODTAB := ""
				_cREV    := ""
				_cCOD    := ""
				_cDESC   := ""
				_cTIPO   := ""
				_cGRUPO  := ""
				_cDSCGRP := ""
				_cFAMILI := ""
				_cDSCFAM := ""
				_cSUBFAM := ""
				_cDSCSFM := ""
				_cLINHA  := ""
				_cDSCLIN := ""
			
			EndIf
		
		EndIf
	
	EndIf

    IncProc("Gerando arquivo...")

EndDo

PAA->(DbCloseArea())
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

Aadd(_aPerg,{"Código Produto De......?"        ,"mv_ch01","C",15,0,"G","mv_par01","","","","","","SB1","","",0})
Aadd(_aPerg,{"Código Produto Ate.....?"        ,"mv_ch02","C",15,0,"G","mv_par02","","","","","","SB1","","",0})

Aadd(_aPerg,{"Tipo de Produto De.....?"        ,"mv_ch03","C",02,0,"G","mv_par03","","","","","","02","","",0})
Aadd(_aPerg,{"Tipo de Produto Ate....?"        ,"mv_ch04","C",02,0,"G","mv_par04","","","","","","02","","",0})

Aadd(_aPerg,{"Código Grupo De........?"        ,"mv_ch05","C",04,0,"G","mv_par05","","","","","","SBM","","",0})
Aadd(_aPerg,{"Código Grupo Ate.......?"        ,"mv_ch06","C",04,0,"G","mv_par06","","","","","","SBM","","",0})

Aadd(_aPerg,{"Código Familia De......?"        ,"mv_ch07","C",03,0,"G","mv_par07","","","","","","ZZZ","","",0})
Aadd(_aPerg,{"Código Familia Ate.....?"        ,"mv_ch08","C",03,0,"G","mv_par08","","","","","","ZZZ","","",0})

Aadd(_aPerg,{"Código Sub Familia De..?"        ,"mv_ch09","C",03,0,"G","mv_par09","","","","","","ZZX","","",0})
Aadd(_aPerg,{"Código Sub Familia Ate.?"        ,"mv_ch10","C",03,0,"G","mv_par10","","","","","","ZZX","","",0})

Aadd(_aPerg,{"Data Vigência Até .....?"        ,"mv_ch12","D",08,0,"G","mv_par11","","","","","",""   ,"","",0})

Aadd(_aPerg,{"% Comissão ............?"        ,"mv_ch13","N",05,0,"G","mv_par12","","","","","",""   ,"","",2})


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


