#include "Colors.ch"
#include "Protheus.ch"
#include "RwMake.ch"
#Include "TOPCONN.CH" 

#DEFINE ENTER chr(13) + chr(10) 

/*/{Protheus.doc} QECTB002  
Interface para atualizar os codigos de operações contabeis   
@type function
@author fabio Caraneiro dos Santos
@since 17/01/2022
@version P12
@database MSSQL
/*/ 
User Function QECTB002()

	Local aSays    := {}
	Local aButtons := {}
	Local nOpca    := 0
	Local cTitoDlg := "Atualiza as operações contabeis na nota fiscal de entrada e saida"
	Private _cPerg := "QECTB02"

	// Prepara e executa a pergunta do relatorio

	aAdd(aSays, "Esta rotina atualiza as operações das notas fiscais de entrada e saida!")
	aAdd(aSays, "Com base na TES, atualiza oS campos D1_XOPER e D2_XOPER")
	
	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	If nOpca == 1
	
		oAjustaSx1()

		If !Pergunte(_cPerg,.T.)
			Return
		Else 
			Processa({|| QECTB02ok("Processando as Operações...")})
		Endif
		
	EndIf
Return

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QECTB02ok | Autor: | QUALY         | Data: | 147/01/22    |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QECTB02ok                                    |
+------------+-----------------------------------------------------------+
*/

Static Function QECTB02ok()

Local cQuery       := ""
Local cQueryA      := ""
Local _dPerInicial := ""
Local _dPerFinal   := ""

cQuery := "UPDATE SD1100 SET D1_XOPER = F4_XOPER "+ENTER  
cQuery += "FROM "+RetSqlName("SD1")+" AS SD1 WITH (NOLOCK) "+ENTER
cQuery += "INNER JOIN "+RetSqlName("SF4")+" AS SF4 WITH (NOLOCK) ON F4_FILIAL = SUBSTRING(D1_FILIAL,1,2) "+ENTER 
cQuery += "AND F4_CODIGO = D1_TES "+ENTER
cQuery += "AND SF4.D_E_L_E_T_ = ' ' "+ENTER 
cQuery += "WHERE SUBSTRING(D1_FILIAL,1,2) = F4_FILIAL "+ENTER
cQuery += "AND D1_DTDIGIT BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+ENTER
cQuery += "AND SD1.D_E_L_E_T_ = ' ' "+ENTER

TCSqlExec( cQuery )

cQueryA := "UPDATE SD2100 SET D2_XOPER = F4_XOPER "+ENTER 
cQueryA += "FROM "+RetSqlName("SD2")+" AS SD2 WITH (NOLOCK) "+ENTER
cQueryA += "INNER JOIN "+RetSqlName("SF4")+" AS SF4 WITH (NOLOCK) ON F4_FILIAL = SUBSTRING(D2_FILIAL,1,2) "+ENTER 
cQueryA += "AND F4_CODIGO = D2_TES "+ENTER
cQueryA += "AND SF4.D_E_L_E_T_ = ' ' "+ENTER 
cQueryA += "WHERE SUBSTRING(D2_FILIAL,1,2) = F4_FILIAL "+ENTER
cQueryA += "AND D2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+ENTER
cQueryA += "AND SD2.D_E_L_E_T_ = ' ' "+ENTER

TCSqlExec( cQueryA )

IncProc("Aguarde...")

_dPerInicial := Substr(Dtos(MV_PAR01),7,2)+"/"+Substr(Dtos(MV_PAR01),5,2)+"/"+Substr(Dtos(MV_PAR01),1,4)
_dPerFinal   := Substr(Dtos(MV_PAR02),7,2)+"/"+Substr(Dtos(MV_PAR02),5,2)+"/"+Substr(Dtos(MV_PAR02),1,4)

Aviso("Atenção !!!" ,"Registros Atualizados Com Sucesso no Periodo de "+_dPerInicial+"  Até  "+_dPerFinal ,{"OK"})

Return

/*
+------------+------------+--------+---------------+-------+--------------+
| Programa:  | oAjustaSx1 | Autor: | QUALY         | Data: | 17/02/22     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - Perguntas                                     |
+------------+------------------------------------------------------------+
*/
Static Function oAjustaSx1()

Local _aPerg  := {}  // aRRAY 
Local _ni

Aadd(_aPerg,{"Periodo  De  ....?"        ,"mv_ch1","D",08,"G","mv_par01","","","","","",""   ,"","",0})
Aadd(_aPerg,{"Periodo Até .....?"        ,"mv_ch2","D",08,"G","mv_par02","","","","","",""   ,"","",0})

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
