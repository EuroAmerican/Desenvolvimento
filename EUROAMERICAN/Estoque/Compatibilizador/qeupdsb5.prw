#include 'protheus.ch'
#include 'parmtype.ch'
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"

#define ENTER chr(13) + chr(10)

/*/{Protheus.doc}QEUPDSB5
//compatibilizador para acertar os produtos que não constam na SB5 e contem na sb1
@author Fabio Carneiro dos Santos 
@since 03/03/2021
@version 1.0
/*/

User Function QEUPDSB5()

    Local aSays    := {}
	Local aButtons := {}
	Local nOpca    := 0
	Local cTitoDlg := "GRAVA COMPLEMENTO DE PRODUTO INEXISTENTE"
    Private _cPerg := "QEUPDB5"

	// Prepara e executa a pergunta do relatorio

	aAdd(aSays, "Esta rotina tem por objetivo compatibilizar a tabela SB1 com a SB5")
    aAdd(aSays, "Será gravado os dadaos codigo do produto, descrição")
    aAdd(aSays, "Somente grava os produtos do TIPO PA, sem bloqueio!")
    aAdd(aSays, "Serão Produtos que existem na tabela SB1, e não existem na tabela SB5")
	aAdd(aSays, "***Esta atualização é por Filial, Necessario rodar logado na Filial***")

	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	
    If nOpca == 1
	
		oAjustaSx1()

		If !Pergunte(_cPerg,.T.)
			Return
		Else 
			Processa({|| QEUPDSB5ok("Gravando Tabela Complemento de Produto...")})
		Endif
		
	EndIf
	Return

/*
+------------+------------+--------+---------------+-------+--------------+
| Programa:  | QEUPDSB5ok | Autor: | QUALY         | Data: | 03/03/21     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEUPDSB5ok                                    |
+------------+------------------------------------------------------------+
*/

Static Function QEUPDSB5ok()

Local aCab          := {}
Local cQueryA       := ""
Local cQueryB       := ""
Local cQueryC       := ""
Local lPassa        := .T.

Private lMsErroAuto := .F.
Private TRB1        := GetNextAlias()

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf

cQueryA := "SELECT B1_COD, B1_DESC, B1_TIPO, B1_MSBLQL " + ENTER
cQueryA += " FROM " + RetSqlName("SB1") + "  AS SB1 " + ENTER
cQueryA += " WHERE B1_TIPO = 'PA' " + ENTER
cQueryA += " AND SB1.B1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'   " + ENTER
cQueryA += " AND SB1.B1_MSBLQL = '2' " + ENTER  
cQueryA += " AND SB1.D_E_L_E_T_ = ' '  " + ENTER
cQueryA += " ORDER BY B1_COD  " + ENTER

TcQuery cQueryA ALIAS "TRB1" NEW

TRB1->(DbGoTop())
	
ProcRegua(TRB1->(LastRec()))
	
While TRB1->(!Eof())

	lPassa := .T.
	
	dbSelectArea("SB5")
    dbSetOrder(1)
	SB5->(DbGoTop())
    
	If DbSeek(xFilial("SB5")+TRB1->B1_COD)
		lPassa := .F.
	EndIf

	If lPassa
	
	   aCab:= {{"B5_COD"   ,TRB1->B1_COD  ,Nil},;               
               {"B5_CEME"  ,TRB1->B1_DESC ,Nil},;
			   {"B5_UMIND" ,'1'           ,Nil}}    
    
		MSExecAuto({|x,y| Mata180(x,y)},aCab,3) //Inclusão 
    	
    	If lMsErroAuto    
        	cErro:=MostraErro()
    	Endif
	
	EndIf

    TRB1->(DbSkip())

    IncProc("Gerando arquivo...")

EndDo

If MV_PAR03 = 2

	cQueryB := "UPDATE " + RetSqlName("SB5") + " SET B5_CONVDIP = B1_PESO, B5_UMDIPI = 'KG' " + ENTER
	cQueryB += " FROM " + RetSqlName("SB1") + " AS SB1 " + ENTER
	cQueryB += " INNER JOIN " + RetSqlName("SB5") + " AS SB5 WITH (NOLOCK) ON B5_COD = B1_COD " + ENTER
	cQueryB += " WHERE B5_FILIAL = '"+xFilial("SB5")+"' " + ENTER
	cQueryB += " AND B1_TIPO = 'PA' " + ENTER
	cQueryB += " AND B1_MSBLQL = '2'  " + ENTER
	cQueryB += " AND SB1.B1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'   " + ENTER
	cQueryB += " AND SB1.D_E_L_E_T_ = ' '  " + ENTER
	cQueryB += " AND SB5.D_E_L_E_T_ = ' '  " + ENTER

	TCSqlExec( cQueryB )

	cQueryC := "UPDATE " + RetSqlName("SB1") + " SET B1_CODGTIN = '000000000000000'  " + ENTER
	cQueryC += " FROM " + RetSqlName("SB1") + " AS SB1 " + ENTER
	cQueryC += " WHERE B1_TIPO = 'PA' " + ENTER
	cQueryC += " AND B1_MSBLQL = '2'  " + ENTER
	cQueryC += " AND SB1.B1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'   " + ENTER
	cQueryC += " AND SB1.D_E_L_E_T_ = ' '  " + ENTER

	TCSqlExec( cQueryC )

EndIf

SB5->(DbCloseArea())
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

Aadd(_aPerg,{"Produtos De  ....?"        ,"mv_ch1","C",15,"G","mv_par01","","","","","","SB1","","",0})
Aadd(_aPerg,{"Produtos Até ....?"        ,"mv_ch2","C",15,"G","mv_par02","","","","","","SB1","","",0})
Aadd(_aPerg,{"Grava GTIN/DIPI..?"        ,"mv_ch3","C",01,"C","mv_par03","Não","Sim","","","",""   ,"","",0})

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


