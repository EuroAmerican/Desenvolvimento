#include "parmtype.ch"
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"
#include "Colors.ch"
#include "RwMake.ch"

/*/{Protheus.doc} QECUSTNET
Calcula Custo Net e Custo Test_ 
@Autor Fabio Carneiro 
@since 10/11/2022
@version 1.0
@type user function 
/*/

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

User Function QECUSNET()

Local aSays    := {}
Local aButtons := {}
Local cTitoDlg := "Cáculo do custo Net e Custo Test"
Local nOpca    := 0
Private _cPerg := "QECUSNT"

aAdd(aSays, "Rotina para gerar o custo net dos produtos acabados e semi abados !!!")
aAdd(aSays, "Serão listados os Produtos do TIPO PA/PI/KT !")

aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})


FormBatch(cTitoDlg, aSays, aButtons)

If nOpca == 1
	
	oAjustaSx1()

	If !Pergunte(_cPerg,.T.)
		Return
	Else 
		Processa({|| QECUSMNTok()}, "Atualizando Custo Net...")
	Endif
		
EndIf

Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QECUSMNTok| Autor: | QUALY         | Data: | 08/08/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEEXPMNTok                                   |
+------------+-----------------------------------------------------------+
*/
Static Function QECUSMNTok() 

Local cQry      := ""
//Local cQry1     := ""
Local cQryA     := ""
Local cUpdate   := ""
Local _cQuery   := ""
Local _cQuery2  := ""
Local cQuery0   := "" 
Local cQuery1   := "" 
Local cQuery2   := "" 
Local cQuery3   := "" 
Local cQuery4   := "" 
Local cQuery5   := "" 
Local cQuery6   := "" 
Local cQuery7   := "" 
Local cQuery8   := "" 
Local cQuery9   := "" 
Local cQueryA   := "" 
Local cQueryB   := "" 
Local cQueryC   := "" 
Local cQueryD   := "" 
Local cQueryE   := "" 
Local cQueryF   := "" 
Local cQueryG   := "" 
Local cQueryH   := "" 
Local cQueryI   := "" 
Local cQueryJ   := "" 
Local cQueryK   := "" 
Local cQueryL   := "" 
Local cQueryM   := "" 
Local cQueryN   := "" 
Local cQueryO   := "" 
Local cQueryP   := "" 
Local cQueryQ   := "" 
Local cQueryR   := "" 
Local cQueryS   := "" 
Local cQueryT   := "" 
Local cQueryU   := "" 
Local cQueryV   := "" 
Local cQueryX   := "" 
Local cQueryZ   := "" 
Local cQueryW   := "" 
Local cQueryY   := ""

Local _aGerPrd  := {}
Local _nPrd     := 0 
Local _aGerStr  := {}
Local _nStr     := 0 
Local _aGerSg1  := {}
Local _nSg1     := 0
Local _aGerSg2  := {}
Local _nSg2     := 0
Local _aGerSg3  := {}
Local _nSg3     := 0
Local _aGerSg4  := {}
Local _nSg4     := 0
Local _aGerSg5  := {}
Local _nSg5     := 0
Local _aGerSg6  := {}
Local _nSg6     := 0
Local _aGerSg7  := {}
Local _nSg7     := 0
Local _aGerSg8  := {}
Local _nSg8     := 0
Local _aGerSg9  := {}
Local _nSg9     := 0
Local _aGerSgA  := {}
Local _nSgA     := 0
Local _aGerSgb  := {}
Local _nSgb     := 0
Local _aGerSgc  := {}
Local _nSgc     := 0
Local _aGerSgd  := {}
Local _nSgd     := 0
Local _aGerSge  := {}
Local _nSge     := 0
Local _aGerSgf  := {}
Local _nSgf     := 0
Local _aGerSgg  := {}
Local _nSgg     := 0
Local _aGerSgh  := {}
Local _nSgh     := 0
Local _aGerSgi  := {}
Local _nSgi     := 0
Local _aGerSgj  := {}
Local _nSgj     := 0
Local _aGerSgk  := {}
Local _nSgk     := 0
Local _aGerSgl  := {}
Local _nSgl     := 0
Local _aGerSgm  := {}
Local _nSgm     := 0
Local _aGerSgn  := {}
Local _nSgn     := 0
Local _aGerSgo  := {}
Local _nSgo     := 0
Local _aGerSgp  := {}
Local _nSgp     := 0
Local _aGerSgq  := {}
Local _nSgq     := 0
Local _aGerSgr  := {}
Local _nSgr     := 0
Local _aGerSgs  := {}
Local _nSgs     := 0
Local _aGerSgt  := {}
Local _nSgt     := 0
Local _aGerSgu  := {}
Local _nSgu     := 0
Local _aGerSgv  := {}
Local _nSgv     := 0
Local _aGerSgx  := {}
Local _nSgx     := 0
Local _aGerSgy  := {}
Local _nSgy     := 0
Local _aGerSgw  := {}
Local _nSgw     := 0
Local _aGerSgz  := {}
Local _nSgz     := 0

Local _nQuantItem := 0
Local _nQuantPai  := 0 
Local _nCount     := 0
Local _nQtd1      := 0
Local _cCodigo1   := ""
Local _nQtd2      := 0
Local _cCodigo2   := ""
Local _nQtd3      := 0
Local _cCodigo3   := ""
Local _nQtd4      := 0
Local _cCodigo4   := ""
Local _nQtd5      := 0
Local _cCodigo5   := ""
Local _nQtd6      := 0
Local _cCodigo6   := ""
Local _nQtd7      := 0
Local _cCodigo7   := ""
Local _nQtd8      := 0
Local _cCodigo8   := ""
Local _nQtd9      := 0
Local _cCodigo9   := ""
Local _nQtdA      := 0
Local _cCodigoA   := ""
Local _nCalcItem  := 0

/*
+--------------------------------+
| QUERY REFERENTE OS MOVIMENTOS  |
+--------------------------------+
*/
ProcRegua(RecCount()-Recno())

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf

cQuery1 := "SELECT G1_FILIAL, " + CRLF
cQuery1 += "G1_COD, " + CRLF
cQuery1 += "G1_COMP, " + CRLF
cQuery1 += "G1_QUANT " + CRLF
cQuery1 += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
cQuery1 += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL IN "+FORMATIN(AllTrim(MV_PAR03),"/")+" " + CRLF
cQuery1 += " AND B1_COD = G1_COD " + CRLF
cQuery1 += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
cQuery1 += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
cQuery1 += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
cQuery1 += " AND B1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " + CRLF
cQuery1 += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
cQuery1 += " AND B1_MSBLQL <> '1' " + CRLF
cQuery1 += " AND SB1.D_E_L_E_T_ = '' " + CRLF
cQuery1 += "ORDER BY B1_COD " + CRLF

TCQuery cQuery1 New Alias "TRB1"

TRB1->(DbGoTop())

While TRB1->(!Eof())


	If mv_par04 == 1
		Incproc( "Atualizando Custo Teste: " + TRB1->G1_COD )
	Else
		Incproc( "Atualizando Custo Standard: " + TRB1->G1_COD)
	Endif

	_aGerStr := {}
	_nStr    := 0
	_aGerSg1 := {}
	_nSg1    := 0
	_aGerSg2 := {}
	_nSg2    := 0
	_aGerSg3 := {}
	_nSg3    := 0
	_aGerSg4 := {}
	_nSg4    := 0
	_aGerSg5 := {}
	_nSg5    := 0
	_aGerSg6 := {}
	_nSg6    := 0
	_aGerSg7 := {}
	_nSg7    := 0
	_aGerSg8 := {}
	_nSg8    := 0
	_aGerSg9 := {}
	_nSg9    := 0
	_aGerSgb := {}
	_nSgb    := 0
	_nSga    := 0
	_aGerSgc := {}
	_nSgc    := 0
	_aGerSgd := {}
	_nSgd    := 0
	_aGerSge := {}
	_nSge    := 0
	_aGerSgf := {}
	_nSgf    := 0
	_aGerSgg := {}
	_nSgg    := 0
	_aGerSgh := {}
	_nSgh    := 0
	_aGerSgi := {}
	_nSgi    := 0
	_aGerSgj := {}
	_nSgj    := 0
	_aGerSgk := {}
	_nSgk    := 0
	_aGerSgl := {}
	_nSgl    := 0
	_aGerSgm := {}
	_nSgm    := 0
	_aGerSgn := {}
	_nSgn    := 0
	_aGerSgo := {}
	_nSgo    := 0
	_aGerSgp := {}
	_nSgp    := 0
	_aGerSgq := {}
	_nSgq    := 0
	_aGerSgr := {}
	_nSgr    := 0
	_aGerSgs := {}
	_nSgs    := 0
	_aGerSgt := {}
	_nSgt    := 0
	_aGerSgu := {}
	_nSgu    := 0
	_aGerSgv := {}
	_nSgv    := 0
	_aGerSgx := {}
	_nSgx    := 0
	_aGerSgz := {}
	_nSgz    := 0
	_aGerSgw := {}
	_nSgw    := 0
	_aGerSgy := {}
	_nSgy    := 0
	
	cQuery0  := "" 
	cQuery2  := "" 
	cQuery3  := "" 
	cQuery4  := "" 
	cQuery5  := "" 
	cQuery6  := "" 
	cQuery7  := "" 
	cQuery8  := "" 
	cQuery9  := "" 
	cQueryA  := "" 
	cQueryB  := "" 
	cQueryC  := "" 
	cQueryD  := "" 
	cQueryE  := "" 
	cQueryF  := "" 
	cQueryG  := "" 
	cQueryH  := "" 
	cQueryI  := "" 
	cQueryJ  := "" 
	cQueryK  := "" 
	cQueryL  := "" 
	cQueryM  := "" 
	cQueryN  := "" 
	cQueryO  := "" 
	cQueryP  := "" 
	cQueryQ  := "" 
	cQueryR  := "" 
	cQueryS  := "" 
	cQueryT  := "" 
	cQueryU  := "" 
	cQueryV  := "" 
	cQueryX  := "" 
	cQueryZ  := "" 
	cQueryW  := "" 
	cQueryY  := ""  
	
	If Select("TBR2") > 0
		TBR2->(DbCloseArea())
	EndIf

	_cQuery2 := "SELECT G1_FILIAL, " + CRLF
	_cQuery2 += "G1_COD, " + CRLF
	_cQuery2 += "G1_QUANT " + CRLF
	_cQuery2 += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
	_cQuery2 += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+TRB1->G1_FILIAL+"' " + CRLF
	_cQuery2 += " AND B1_COD = G1_COD " + CRLF
	_cQuery2 += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
	_cQuery2 += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
	_cQuery2 += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
	_cQuery2 += " AND B1_COD = '"+TRB1->G1_COD+"' " + CRLF
	_cQuery2 += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO = 'PI' AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
	_cQuery2 += " AND B1_MSBLQL <> '1' " + CRLF
	_cQuery2 += " AND SB1.D_E_L_E_T_ = '' " + CRLF
	_cQuery2 += "ORDER BY B1_COD " + CRLF

	TCQuery _cQuery2 New Alias "TBR2"

	TBR2->(DbGoTop())
			
	While TBR2->(!Eof())

		Aadd(_aGerPrd,{TBR2->G1_FILIAL,TBR2->G1_COD,TBR2->G1_QUANT})
				
		TBR2->(DbSkip())

	EndDo

	Aadd(_aGerStr,{TRB1->G1_FILIAL,TRB1->G1_COD,TRB1->G1_COMP})
	Aadd(_aGerSgA,{TRB1->G1_FILIAL,TRB1->G1_COD,TRB1->G1_COMP,TRB1->G1_COD,TRB1->G1_QUANT})


	If Len(_aGerStr) > 0

		For _nStr := 1 To Len(_aGerStr)

			If Select("TRB2") > 0
				TRB2->(DbCloseArea())
			EndIf

			cQuery2 := "SELECT G1_FILIAL, " + CRLF
			cQuery2 += "G1_COD, " + CRLF
			cQuery2 += "G1_COMP, " + CRLF
			cQuery2 += "G1_QUANT " + CRLF
			cQuery2 += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQuery2 += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerStr[_nStr][01]+"' " + CRLF
			cQuery2 += " AND B1_COD = G1_COD " + CRLF
			cQuery2 += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQuery2 += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQuery2 += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQuery2 += " AND B1_COD = '"+_aGerStr[_nStr][03]+"' " + CRLF
			cQuery2 += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQuery2 += " AND B1_MSBLQL <> '1' " + CRLF
			cQuery2 += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQuery2 += "ORDER BY B1_COD " + CRLF

			TCQuery cQuery2 New Alias "TRB2"

			TRB2->(DbGoTop())
			
			While TRB2->(!Eof())

				Aadd(_aGerSg1,{TRB2->G1_FILIAL,TRB2->G1_COD,TRB2->G1_COMP})
				Aadd(_aGerSgA,{TRB2->G1_FILIAL,TRB2->G1_COD,TRB2->G1_COMP,TRB1->G1_COD,TRB2->G1_QUANT})
				
				TRB2->(DbSkip())

			EndDo

		Next _nSg1	
	
	EndIf

	If Len(_aGerSg1) > 0

		For _nSg1 := 1 To Len(_aGerSg1)

			If Select("TRB3") > 0
				TRB3->(DbCloseArea())
			EndIf

			cQuery3 := "SELECT G1_FILIAL, " + CRLF
			cQuery3 += "G1_COD, " + CRLF
			cQuery3 += "G1_COMP, " + CRLF
			cQuery3 += "G1_QUANT " + CRLF
			cQuery3 += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQuery3 += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSg1[_nSg1][01]+"' " + CRLF
			cQuery3 += " AND B1_COD = G1_COD " + CRLF
			cQuery3 += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQuery3 += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQuery3 += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQuery3 += " AND B1_COD = '"+_aGerSg1[_nSg1][03]+"' " + CRLF
			cQuery3 += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQuery3 += " AND B1_MSBLQL <> '1' " + CRLF
			cQuery3 += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQuery3 += "ORDER BY B1_COD " + CRLF

			TCQuery cQuery3 New Alias "TRB3"

			TRB3->(DbGoTop())
			
			While TRB3->(!Eof())

				Aadd(_aGerSg2,{TRB3->G1_FILIAL,TRB3->G1_COD,TRB3->G1_COMP})
				Aadd(_aGerSgA,{TRB3->G1_FILIAL,TRB3->G1_COD,TRB3->G1_COMP,TRB1->G1_COD,TRB3->G1_QUANT})

				TRB3->(DbSkip())

			EndDo 

		Next _nSg1	
	
	EndIf

	If Len(_aGerSg2) > 0

		For _nSg2 := 1 To Len(_aGerSg2)

			If Select("TRB4") > 0
				TRB4->(DbCloseArea())
			EndIf

			cQuery4 := "SELECT G1_FILIAL, " + CRLF
			cQuery4 += "G1_COD, " + CRLF
			cQuery4 += "G1_COMP, " + CRLF
			cQuery4 += "G1_QUANT " + CRLF
			cQuery4 += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQuery4 += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSg2[_nSg2][01]+"' " + CRLF
			cQuery4 += " AND B1_COD = G1_COD " + CRLF
			cQuery4 += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQuery4 += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQuery4 += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQuery4 += " AND B1_COD = '"+_aGerSg2[_nSg2][03]+"' " + CRLF
			cQuery4 += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQuery4 += " AND B1_MSBLQL <> '1' " + CRLF
			cQuery4 += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQuery4 += "ORDER BY B1_COD " + CRLF

			TCQuery cQuery4 New Alias "TRB4"

			TRB4->(DbGoTop())
				
			While TRB4->(!Eof())

				Aadd(_aGerSg3,{TRB4->G1_FILIAL,TRB4->G1_COD,TRB4->G1_COMP})
				Aadd(_aGerSgA,{TRB4->G1_FILIAL,TRB4->G1_COD,TRB4->G1_COMP,TRB1->G1_COD,TRB4->G1_QUANT})

				TRB4->(DbSkip())

			EndDo 

		Next _nSg2	
	
	EndIf

	If Len(_aGerSg3) > 0

		For _nSg3 := 1 To Len(_aGerSg3)

			If Select("TRB5") > 0
				TRB5->(DbCloseArea())
			EndIf

			cQuery5 := "SELECT G1_FILIAL, " + CRLF
			cQuery5 += "G1_COD, " + CRLF
			cQuery5 += "G1_COMP, " + CRLF
			cQuery5 += "G1_QUANT " + CRLF
			cQuery5 += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQuery5 += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSg3[_nSg3][01]+"' " + CRLF
			cQuery5 += " AND B1_COD = G1_COD " + CRLF
			cQuery5 += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQuery5 += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQuery5 += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQuery5 += " AND B1_COD = '"+_aGerSg3[_nSg3][03]+"' " + CRLF
			cQuery5 += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQuery5 += " AND B1_MSBLQL <> '1' " + CRLF
			cQuery5 += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQuery5 += "ORDER BY B1_COD " + CRLF

			TCQuery cQuery5 New Alias "TRB5"

			TRB5->(DbGoTop())
				
			While TRB5->(!Eof())

				Aadd(_aGerSg4,{TRB5->G1_FILIAL,TRB5->G1_COD,TRB5->G1_COMP})
				Aadd(_aGerSgA,{TRB5->G1_FILIAL,TRB5->G1_COD,TRB5->G1_COMP,TRB1->G1_COD,TRB5->G1_QUANT})

				TRB5->(DbSkip())

			EndDo 

		Next _nSg3	
	
	EndIf

	If Len(_aGerSg4) > 0

		For _nSg4 := 1 To Len(_aGerSg4)

			If Select("TRB6") > 0
				TRB6->(DbCloseArea())
			EndIf

			cQuery6 := "SELECT G1_FILIAL, " + CRLF
			cQuery6 += "G1_COD, " + CRLF
			cQuery6 += "G1_COMP, " + CRLF
			cQuery6 += "G1_QUANT " + CRLF
			cQuery6 += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQuery6 += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSg4[_nSg4][01]+"' " + CRLF
			cQuery6 += " AND B1_COD = G1_COD " + CRLF
			cQuery6 += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQuery6 += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQuery6 += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQuery6 += " AND B1_COD = '"+_aGerSg4[_nSg4][03]+"' " + CRLF
			cQuery6 += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQuery6 += " AND B1_MSBLQL <> '1' " + CRLF
			cQuery6 += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQuery6 += "ORDER BY B1_COD " + CRLF

			TCQuery cQuery6 New Alias "TRB6"

			TRB6->(DbGoTop())
				
			While TRB6->(!Eof())

				Aadd(_aGerSg5,{TRB6->G1_FILIAL,TRB6->G1_COD,TRB6->G1_COMP})
				Aadd(_aGerSgA,{TRB6->G1_FILIAL,TRB6->G1_COD,TRB6->G1_COMP,TRB1->G1_COD,TRB6->G1_QUANT})

				TRB6->(DbSkip())

			EndDo 

		Next _nSg4	
	
	EndIf

	If Len(_aGerSg5) > 0

		For _nSg5 := 1 To Len(_aGerSg5)

			If Select("TRB7") > 0
				TRB7->(DbCloseArea())
			EndIf

			cQuery7 := "SELECT G1_FILIAL, " + CRLF
			cQuery7 += "G1_COD, " + CRLF
			cQuery7 += "G1_COMP, " + CRLF
			cQuery7 += "G1_QUANT " + CRLF
			cQuery7 += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQuery7 += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSg5[_nSg5][01]+"' " + CRLF
			cQuery7 += " AND B1_COD = G1_COD " + CRLF
			cQuery7 += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQuery7 += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQuery7 += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQuery7 += " AND B1_COD = '"+_aGerSg5[_nSg5][03]+"' " + CRLF
			cQuery7 += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQuery7 += " AND B1_MSBLQL <> '1' " + CRLF
			cQuery7 += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQuery7 += "ORDER BY B1_COD " + CRLF

			TCQuery cQuery7 New Alias "TRB7"

			TRB7->(DbGoTop())
				
			While TRB7->(!Eof())

				Aadd(_aGerSg6,{TRB7->G1_FILIAL,TRB7->G1_COD,TRB7->G1_COMP})
				Aadd(_aGerSgA,{TRB7->G1_FILIAL,TRB7->G1_COD,TRB7->G1_COMP,TRB1->G1_COD,TRB7->G1_QUANT})

				TRB7->(DbSkip())

			EndDo 

		Next _nSg5	
	
	EndIf

	If Len(_aGerSg6) > 0

		For _nSg6 := 1 To Len(_aGerSg6)

			If Select("TRB8") > 0
				TRB8->(DbCloseArea())
			EndIf

			cQuery8 := "SELECT G1_FILIAL, " + CRLF
			cQuery8 += "G1_COD, " + CRLF
			cQuery8 += "G1_COMP, " + CRLF
			cQuery8 += "G1_QUANT " + CRLF
			cQuery8 += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQuery8 += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSg6[_nSg6][01]+"' " + CRLF
			cQuery8 += " AND B1_COD = G1_COD " + CRLF
			cQuery8 += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQuery8 += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQuery8 += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQuery8 += " AND B1_COD = '"+_aGerSg6[_nSg6][03]+"' " + CRLF
			cQuery8 += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQuery8 += " AND B1_MSBLQL <> '1' " + CRLF
			cQuery8 += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQuery8 += "ORDER BY B1_COD " + CRLF

			TCQuery cQuery8 New Alias "TRB8"

			TRB8->(DbGoTop())
				
			While TRB8->(!Eof())

				Aadd(_aGerSg7,{TRB8->G1_FILIAL,TRB8->G1_COD,TRB8->G1_COMP})
				Aadd(_aGerSgA,{TRB8->G1_FILIAL,TRB8->G1_COD,TRB8->G1_COMP,TRB1->G1_COD,TRB8->G1_QUANT})

				TRB8->(DbSkip())

			EndDo 

		Next _nSg6	
	
	EndIf

	If Len(_aGerSg7) > 0

		For _nSg7 := 1 To Len(_aGerSg7)

			If Select("TRB9") > 0
				TRB9->(DbCloseArea())
			EndIf

			cQuery9 := "SELECT G1_FILIAL, " + CRLF
			cQuery9 += "G1_COD, " + CRLF
			cQuery9 += "G1_COMP, " + CRLF
			cQuery9 += "G1_QUANT " + CRLF
			cQuery9 += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQuery9 += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSg7[_nSg7][01]+"' " + CRLF
			cQuery9 += " AND B1_COD = G1_COD " + CRLF
			cQuery9 += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQuery9 += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQuery9 += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQuery9 += " AND B1_COD = '"+_aGerSg7[_nSg7][03]+"' " + CRLF
			cQuery9 += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQuery9 += " AND B1_MSBLQL <> '1' " + CRLF
			cQuery9 += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQuery9 += "ORDER BY B1_COD " + CRLF

			TCQuery cQuery9 New Alias "TRB9"

			TRB9->(DbGoTop())
				
			While TRB9->(!Eof())

				Aadd(_aGerSg8,{TRB9->G1_FILIAL,TRB9->G1_COD,TRB9->G1_COMP})
				Aadd(_aGerSgA,{TRB9->G1_FILIAL,TRB9->G1_COD,TRB9->G1_COMP,TRB1->G1_COD,TRB9->G1_QUANT})

				TRB9->(DbSkip())

			EndDo 

		Next _nSg7	
	
	EndIf

	If Len(_aGerSg8) > 0

		For _nSg8 := 1 To Len(_aGerSg8)

			If Select("TRBA") > 0
				TRBA->(DbCloseArea())
			EndIf

			cQueryA := "SELECT G1_FILIAL, " + CRLF
			cQueryA += "G1_COD, " + CRLF
			cQueryA += "G1_COMP, " + CRLF
			cQueryA += "G1_QUANT " + CRLF
			cQueryA += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryA += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSg8[_nSg8][01]+"' " + CRLF
			cQueryA += " AND B1_COD = G1_COD " + CRLF
			cQueryA += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryA += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryA += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryA += " AND B1_COD = '"+_aGerSg8[_nSg8][03]+"' " + CRLF
			cQueryA += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryA += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryA += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryA += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryA New Alias "TRBA"

			TRBA->(DbGoTop())
				
			While TRBA->(!Eof())

				Aadd(_aGerSg9,{TRBA->G1_FILIAL,TRBA->G1_COD,TRBA->G1_COMP})
				Aadd(_aGerSgA,{TRBA->G1_FILIAL,TRBA->G1_COD,TRBA->G1_COMP,TRB1->G1_COD,TRBA->G1_QUANT})

				TRBA->(DbSkip())

			EndDo 

		Next _nSg8	
	
	EndIf

	If Len(_aGerSg9) > 0

		For _nSg9 := 1 To Len(_aGerSg9)

			If Select("TRBB") > 0
				TRBB->(DbCloseArea())
			EndIf

			cQueryB := "SELECT G1_FILIAL, " + CRLF
			cQueryB += "G1_COD, " + CRLF
			cQueryB += "G1_COMP, " + CRLF
			cQueryB += "G1_QUANT " + CRLF
			cQueryB += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryB += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSg9[_nSg9][01]+"' " + CRLF
			cQueryB += " AND B1_COD = G1_COD " + CRLF
			cQueryB += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryB += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryB += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryB += " AND B1_COD = '"+_aGerSg9[_nSg9][03]+"' " + CRLF
			cQueryB += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryB += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryB += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryB += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryB New Alias "TRBB"

			TRBB->(DbGoTop())
				
			While TRBB->(!Eof())

				Aadd(_aGerSgb,{TRBB->G1_FILIAL,TRBB->G1_COD,TRBB->G1_COMP})
				Aadd(_aGerSgA,{TRBB->G1_FILIAL,TRBB->G1_COD,TRBB->G1_COMP,TRB1->G1_COD,TRBB->G1_QUANT})

				TRBB->(DbSkip())

			EndDo 

		Next _nSg9	
	
	EndIf

	If Len(_aGerSgb) > 0

		For _nSgb := 1 To Len(_aGerSgb)

			If Select("TRBC") > 0
				TRBC->(DbCloseArea())
			EndIf

			cQueryC := "SELECT G1_FILIAL, " + CRLF
			cQueryC += "G1_COD, " + CRLF
			cQueryC += "G1_COMP, " + CRLF
			cQueryC += "G1_QUANT " + CRLF
			cQueryC += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryC += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgb[_nSgb][01]+"' " + CRLF
			cQueryC += " AND B1_COD = G1_COD " + CRLF
			cQueryC += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryC += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryC += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryC += " AND B1_COD = '"+_aGerSgb[_nSgb][03]+"' " + CRLF
			cQueryC += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryC += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryC += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryC += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryC New Alias "TRBC"

			TRBC->(DbGoTop())
				
			While TRBC->(!Eof())

				Aadd(_aGerSgc,{TRBC->G1_FILIAL,TRBC->G1_COD,TRBC->G1_COMP})
				Aadd(_aGerSgA,{TRBC->G1_FILIAL,TRBC->G1_COD,TRBC->G1_COMP,TRB1->G1_COD,TRBC->G1_QUANT})

				TRBC->(DbSkip())

			EndDo 

		Next _nSgb	
	
	EndIf

	If Len(_aGerSgc) > 0

		For _nSgc := 1 To Len(_aGerSgc)

			If Select("TRBD") > 0
				TRBD->(DbCloseArea())
			EndIf

			cQueryD := "SELECT G1_FILIAL, " + CRLF
			cQueryD += "G1_COD, " + CRLF
			cQueryD += "G1_COMP, " + CRLF
			cQueryD += "G1_QUANT " + CRLF
			cQueryD += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryD += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgc[_nSgc][01]+"' " + CRLF
			cQueryD += " AND B1_COD = G1_COD " + CRLF
			cQueryD += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryD += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryD += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryD += " AND B1_COD = '"+_aGerSgc[_nSgc][03]+"' " + CRLF
			cQueryD += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryD += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryD += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryD += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryD New Alias "TRBD"

			TRBD->(DbGoTop())
				
			While TRBD->(!Eof())

				Aadd(_aGerSgd,{TRBD->G1_FILIAL,TRBD->G1_COD,TRBD->G1_COMP})
				Aadd(_aGerSgA,{TRBD->G1_FILIAL,TRBD->G1_COD,TRBD->G1_COMP,TRB1->G1_COD,TRBD->G1_QUANT})

				TRBD->(DbSkip())

			EndDo 

		Next _nSgc	
	
	EndIf

	If Len(_aGerSgd) > 0

		For _nSgd := 1 To Len(_aGerSgd)

			If Select("TRBE") > 0
				TRBE->(DbCloseArea())
			EndIf

			cQueryE := "SELECT G1_FILIAL, " + CRLF
			cQueryE += "G1_COD, " + CRLF
			cQueryE += "G1_COMP, " + CRLF
			cQueryE += "G1_QUANT " + CRLF
			cQueryE += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryE += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgd[_nSgd][01]+"' " + CRLF
			cQueryE += " AND B1_COD = G1_COD " + CRLF
			cQueryE += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryE += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryE += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryE += " AND B1_COD = '"+_aGerSgd[_nSgd][03]+"' " + CRLF
			cQueryE += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryE += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryE += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryE += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryE New Alias "TRBE"

			TRBE->(DbGoTop())
				
			While TRBE->(!Eof())

				Aadd(_aGerSge,{TRBE->G1_FILIAL,TRBE->G1_COD,TRBE->G1_COMP})
				Aadd(_aGerSgA,{TRBE->G1_FILIAL,TRBE->G1_COD,TRBE->G1_COMP,TRB1->G1_COD,TRBE->G1_QUANT})

				TRBE->(DbSkip())

			EndDo 

		Next _nSgd	
	
	EndIf

	If Len(_aGerSge) > 0

		For _nSge := 1 To Len(_aGerSge)

			If Select("TRBF") > 0
				TRBF->(DbCloseArea())
			EndIf

			cQueryF := "SELECT G1_FILIAL, " + CRLF
			cQueryF += "G1_COD, " + CRLF
			cQueryF += "G1_COMP, " + CRLF
			cQueryF += "G1_QUANT " + CRLF
			cQueryF += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryF += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSge[_nSge][01]+"' " + CRLF
			cQueryF += " AND B1_COD = G1_COD " + CRLF
			cQueryF += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryF += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryF += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryF += " AND B1_COD = '"+_aGerSge[_nSge][03]+"' " + CRLF
			cQueryF += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryF += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryF += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryF += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryF New Alias "TRBF"

			TRBF->(DbGoTop())
				
			While TRBF->(!Eof())

				Aadd(_aGerSgf,{TRBF->G1_FILIAL,TRBF->G1_COD,TRBF->G1_COMP})
				Aadd(_aGerSgA,{TRBF->G1_FILIAL,TRBF->G1_COD,TRBF->G1_COMP,TRB1->G1_COD,TRBF->G1_QUANT})

				TRBF->(DbSkip())

			EndDo 

		Next _nSge	
	
	EndIf

	If Len(_aGerSgf) > 0

		For _nSgf := 1 To Len(_aGerSgf)

			If Select("TRBG") > 0
				TRBG->(DbCloseArea())
			EndIf

			cQueryG := "SELECT G1_FILIAL, " + CRLF
			cQueryG += "G1_COD, " + CRLF
			cQueryG += "G1_COMP, " + CRLF
			cQueryG += "G1_QUANT " + CRLF
			cQueryG += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryG += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgf[_nSgf][01]+"' " + CRLF
			cQueryG += " AND B1_COD = G1_COD " + CRLF
			cQueryG += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryG += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryG += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryG += " AND B1_COD = '"+_aGerSgf[_nSgf][03]+"' " + CRLF
			cQueryG += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryG += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryG += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryG += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryG New Alias "TRBG"

			TRBG->(DbGoTop())
				
			While TRBG->(!Eof())

				Aadd(_aGerSgg,{TRBG->G1_FILIAL,TRBG->G1_COD,TRBG->G1_COMP})
				Aadd(_aGerSgA,{TRBG->G1_FILIAL,TRBG->G1_COD,TRBG->G1_COMP,TRB1->G1_COD,TRBG->G1_QUANT})

				TRBG->(DbSkip())

			EndDo 

		Next _nSgf	
	
	EndIf

	If Len(_aGerSgg) > 0

		For _nSgg := 1 To Len(_aGerSgg)

			If Select("TRBH") > 0
				TRBH->(DbCloseArea())
			EndIf

			cQueryH := "SELECT G1_FILIAL, " + CRLF
			cQueryH += "G1_COD, " + CRLF
			cQueryH += "G1_COMP, " + CRLF
			cQueryH += "G1_QUANT " + CRLF
			cQueryH += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryH += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgg[_nSgg][01]+"' " + CRLF
			cQueryH += " AND B1_COD = G1_COD " + CRLF
			cQueryH += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryH += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryH += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryH += " AND B1_COD = '"+_aGerSgg[_nSgg][03]+"' " + CRLF
			cQueryH += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryH += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryH += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryH += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryH New Alias "TRBH"

			TRBH->(DbGoTop())
				
			While TRBH->(!Eof())

				Aadd(_aGerSgh,{TRBH->G1_FILIAL,TRBH->G1_COD,TRBH->G1_COMP})
				Aadd(_aGerSgA,{TRBH->G1_FILIAL,TRBH->G1_COD,TRBH->G1_COMP,TRB1->G1_COD,TRBH->G1_QUANT})

				TRBH->(DbSkip())

			EndDo 

		Next _nSgg	
	
	EndIf

	If Len(_aGerSgh) > 0

		For _nSgh := 1 To Len(_aGerSgh)

			If Select("TRBI") > 0
				TRBI->(DbCloseArea())
			EndIf

			cQueryI := "SELECT G1_FILIAL, " + CRLF
			cQueryI += "G1_COD, " + CRLF
			cQueryI += "G1_COMP, " + CRLF
			cQueryI += "G1_QUANT " + CRLF
			cQueryI += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryI += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgh[_nSgh][01]+"' " + CRLF
			cQueryI += " AND B1_COD = G1_COD " + CRLF
			cQueryI += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryI += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryI += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryI += " AND B1_COD = '"+_aGerSgh[_nSgh][03]+"' " + CRLF
			cQueryI += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryI += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryI += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryI += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryI New Alias "TRBI"

			TRBI->(DbGoTop())
				
			While TRBI->(!Eof())

				Aadd(_aGerSgi,{TRBI->G1_FILIAL,TRBI->G1_COD,TRBI->G1_COMP})				
				Aadd(_aGerSgA,{TRBI->G1_FILIAL,TRBI->G1_COD,TRBI->G1_COMP,TRB1->G1_COD,TRBI->G1_QUANT})

				TRBI->(DbSkip())

			EndDo 

		Next _nSgh	
	
	EndIf

	If Len(_aGerSgi) > 0

		For _nSgi := 1 To Len(_aGerSgi)

			If Select("TRBJ") > 0
				TRBJ->(DbCloseArea())
			EndIf

			cQueryJ := "SELECT G1_FILIAL, " + CRLF
			cQueryJ += "G1_COD, " + CRLF
			cQueryJ += "G1_COMP, " + CRLF
			cQueryJ += "G1_QUANT " + CRLF
			cQueryJ += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryJ += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgi[_nSgi][01]+"' " + CRLF
			cQueryJ += " AND B1_COD = G1_COD " + CRLF
			cQueryJ += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryJ += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryJ += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryJ += " AND B1_COD = '"+_aGerSgi[_nSgi][03]+"' " + CRLF
			cQueryJ += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryJ += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryJ += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryJ += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryJ New Alias "TRBJ"

			TRBJ->(DbGoTop())
				
			While TRBJ->(!Eof())

				Aadd(_aGerSgj,{TRBJ->G1_FILIAL,TRBJ->G1_COD,TRBJ->G1_COMP})				
				Aadd(_aGerSgA,{TRBJ->G1_FILIAL,TRBJ->G1_COD,TRBJ->G1_COMP,TRB1->G1_COD,TRBJ->G1_QUANT})

				TRBJ->(DbSkip())

			EndDo 

		Next _nSgi	
	
	EndIf

	If Len(_aGerSgj) > 0

		For _nSgj := 1 To Len(_aGerSgj)

			If Select("TRBK") > 0
				TRBK->(DbCloseArea())
			EndIf

			cQueryK := "SELECT G1_FILIAL, " + CRLF
			cQueryK += "G1_COD, " + CRLF
			cQueryK += "G1_COMP, " + CRLF
			cQueryK += "G1_QUANT " + CRLF
			cQueryK += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryK += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgj[_nSgj][01]+"' " + CRLF
			cQueryK += " AND B1_COD = G1_COD " + CRLF
			cQueryK += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryK += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryK += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryK += " AND B1_COD = '"+_aGerSgj[_nSgj][03]+"' " + CRLF
			cQueryK += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryK += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryK += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryK += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryK New Alias "TRBK"

			TRBK->(DbGoTop())
				
			While TRBK->(!Eof())

				Aadd(_aGerSgk,{TRBK->G1_FILIAL,TRBK->G1_COD,TRBK->G1_COMP})				
				Aadd(_aGerSgA,{TRBK->G1_FILIAL,TRBK->G1_COD,TRBK->G1_COMP,TRB1->G1_COD,TRBK->G1_QUANT})

				TRBK->(DbSkip())

			EndDo 

		Next _nSgj	
	
	EndIf

	If Len(_aGerSgk) > 0

		For _nSgk := 1 To Len(_aGerSgk)

			If Select("TRBL") > 0
				TRBL->(DbCloseArea())
			EndIf

			cQueryL := "SELECT G1_FILIAL, " + CRLF
			cQueryL += "G1_COD, " + CRLF
			cQueryL += "G1_COMP, " + CRLF
			cQueryL += "G1_QUANT " + CRLF
			cQueryL += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryL += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgk[_nSgk][01]+"' " + CRLF
			cQueryL += " AND B1_COD = G1_COD " + CRLF
			cQueryL += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryL += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryL += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryL += " AND B1_COD = '"+_aGerSgk[_nSgk][03]+"' " + CRLF
			cQueryL += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryL += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryL += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryL += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryL New Alias "TRBL"

			TRBL->(DbGoTop())
				
			While TRBL->(!Eof())

				Aadd(_aGerSgl,{TRBL->G1_FILIAL,TRBL->G1_COD,TRBL->G1_COMP})				
				Aadd(_aGerSgA,{TRBL->G1_FILIAL,TRBL->G1_COD,TRBL->G1_COMP,TRB1->G1_COD,TRBL->G1_QUANT})

				TRBL->(DbSkip())

			EndDo 

		Next _nSgk	
	
	EndIf

	If Len(_aGerSgl) > 0

		For _nSgl := 1 To Len(_aGerSgl)

			If Select("TRBM") > 0
				TRBM->(DbCloseArea())
			EndIf

			cQueryM := "SELECT G1_FILIAL, " + CRLF
			cQueryM += "G1_COD, " + CRLF
			cQueryM += "G1_COMP, " + CRLF
			cQueryM += "G1_QUANT " + CRLF
			cQueryM += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryM += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgl[_nSgl][01]+"' " + CRLF
			cQueryM += " AND B1_COD = G1_COD " + CRLF
			cQueryM += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryM += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryM += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryM += " AND B1_COD = '"+_aGerSgl[_nSgl][03]+"' " + CRLF
			cQueryM += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryM += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryM += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryM += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryM New Alias "TRBL"

			TRBM->(DbGoTop())
				
			While TRBM->(!Eof())

				Aadd(_aGerSgm,{TRBM->G1_FILIAL,TRBM->G1_COD,TRBM->G1_COMP})				
				Aadd(_aGerSgA,{TRBM->G1_FILIAL,TRBM->G1_COD,TRBM->G1_COMP,TRB1->G1_COD,TRBM->G1_QUANT})

				TRBM->(DbSkip())

			EndDo 

		Next _nSgl	
	
	EndIf

	If Len(_aGerSgm) > 0

		For _nSgm := 1 To Len(_aGerSgm)

			If Select("TRBN") > 0
				TRBN->(DbCloseArea())
			EndIf

			cQueryN := "SELECT G1_FILIAL, " + CRLF
			cQueryN += "G1_COD, " + CRLF
			cQueryM += "G1_COMP, " + CRLF
			cQueryM += "G1_QUANT " + CRLF
			cQueryN += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryN += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgm[_nSgm][01]+"' " + CRLF
			cQueryN += " AND B1_COD = G1_COD " + CRLF
			cQueryN += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryN += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryN += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryN += " AND B1_COD = '"+_aGerSgm[_nSgm][03]+"' " + CRLF
			cQueryN += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryN += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryN += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryN += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryN New Alias "TRBN"

			TRBN->(DbGoTop())
				
			While TRBN->(!Eof())

				Aadd(_aGerSgn,{TRBN->G1_FILIAL,TRBN->G1_COD,TRBN->G1_COMP})				
				Aadd(_aGerSgA,{TRBN->G1_FILIAL,TRBN->G1_COD,TRBN->G1_COMP,TRB1->G1_COD,TRBN->G1_QUANT})

				TRBN->(DbSkip())

			EndDo 

		Next _nSgm	
	
	EndIf

	If Len(_aGerSgn) > 0

		For _nSgn := 1 To Len(_aGerSgn)

			If Select("TRBO") > 0
				TRBO->(DbCloseArea())
			EndIf

			cQueryO := "SELECT G1_FILIAL, " + CRLF
			cQueryO += "G1_COD, " + CRLF
			cQueryO += "G1_COMP, " + CRLF
			cQueryO += "G1_QUANT " + CRLF
			cQueryO += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryO += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgn[_nSgn][01]+"' " + CRLF
			cQueryO += " AND B1_COD = G1_COD " + CRLF
			cQueryO += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryO += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryO += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryO += " AND B1_COD = '"+_aGerSgn[_nSgn][03]+"' " + CRLF
			cQueryO += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryO += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryO += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryO += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryO New Alias "TRBO"

			TRBO->(DbGoTop())
				
			While TRBO->(!Eof())

				Aadd(_aGerSgo,{TRBO->G1_FILIAL,TRBO->G1_COD,TRBO->G1_COMP})				
				Aadd(_aGerSgA,{TRBO->G1_FILIAL,TRBO->G1_COD,TRBO->G1_COMP,TRB1->G1_COD,TRBO->G1_QUANT})

				TRBO->(DbSkip())

			EndDo 

		Next _nSgn	
	
	EndIf

	If Len(_aGerSgo) > 0

		For _nSgo := 1 To Len(_aGerSgo)

			If Select("TRBP") > 0
				TRBP->(DbCloseArea())
			EndIf

			cQueryP := "SELECT G1_FILIAL, " + CRLF
			cQueryP += "G1_COD, " + CRLF
			cQueryP += "G1_COMP, " + CRLF
			cQueryP += "G1_QUANT " + CRLF
			cQueryP += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryP += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgo[_nSgo][01]+"' " + CRLF
			cQueryP += " AND B1_COD = G1_COD " + CRLF
			cQueryP += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryP += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryP += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryP += " AND B1_COD = '"+_aGerSgo[_nSgo][03]+"' " + CRLF
			cQueryP += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryP += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryP += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryP += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryP New Alias "TRBP"

			TRBP->(DbGoTop())
				
			While TRBP->(!Eof())

				Aadd(_aGerSgp,{TRBP->G1_FILIAL,TRBP->G1_COD,TRBP->G1_COMP})				
				Aadd(_aGerSgA,{TRBP->G1_FILIAL,TRBP->G1_COD,TRBP->G1_COMP,TRB1->G1_COD,TRBP->G1_QUANT})

				TRBP->(DbSkip())

			EndDo 

		Next _nSgo	
	
	EndIf

	If Len(_aGerSgp) > 0

		For _nSgp := 1 To Len(_aGerSgp)

			If Select("TRBQ") > 0
				TRBQ->(DbCloseArea())
			EndIf

			cQueryQ := "SELECT G1_FILIAL, " + CRLF
			cQueryQ += "G1_COD, " + CRLF
			cQueryQ += "G1_COMP, " + CRLF
			cQueryQ += "G1_QUANT " + CRLF
			cQueryQ += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryQ += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgp[_nSgp][01]+"' " + CRLF
			cQueryQ += " AND B1_COD = G1_COD " + CRLF
			cQueryQ += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryQ += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryQ += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryQ += " AND B1_COD = '"+_aGerSgp[_nSgp][03]+"' " + CRLF
			cQueryQ += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryQ += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryQ += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryQ += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryQ New Alias "TRBQ"

			TRBQ->(DbGoTop())
				
			While TRBQ->(!Eof())

				Aadd(_aGerSgq,{TRBQ->G1_FILIAL,TRBQ->G1_COD,TRBQ->G1_COMP})				
				Aadd(_aGerSgA,{TRBQ->G1_FILIAL,TRBQ->G1_COD,TRBQ->G1_COMP,TRB1->G1_COD,TRBQ->G1_QUANT})

				TRBQ->(DbSkip())

			EndDo 

		Next _nSgp	
	
	EndIf

	If Len(_aGerSgq) > 0

		For _nSgq := 1 To Len(_aGerSgq)

			If Select("TRBR") > 0
				TRBR->(DbCloseArea())
			EndIf

			cQueryR := "SELECT G1_FILIAL, " + CRLF
			cQueryR += "G1_COD, " + CRLF
			cQueryR += "G1_COMP, " + CRLF
			cQueryR += "G1_QUANT " + CRLF
			cQueryR += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryR += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgq[_nSgq][01]+"' " + CRLF
			cQueryR += " AND B1_COD = G1_COD " + CRLF
			cQueryR += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryR += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryR += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryR += " AND B1_COD = '"+_aGerSgq[_nSgq][03]+"' " + CRLF
			cQueryR += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryR += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryR += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryR += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryR New Alias "TRBR"

			TRBR->(DbGoTop())
				
			While TRBR->(!Eof())

				Aadd(_aGerSgr,{TRBR->G1_FILIAL,TRBR->G1_COD,TRBR->G1_COMP})				
				Aadd(_aGerSgA,{TRBR->G1_FILIAL,TRBR->G1_COD,TRBR->G1_COMP,TRB1->G1_COD,TRBR->G1_QUANT})

				TRBR->(DbSkip())

			EndDo 

		Next _nSgq	
	
	EndIf

	If Len(_aGerSgr) > 0

		For _nSgr := 1 To Len(_aGerSgr)

			If Select("TRBS") > 0
				TRBS->(DbCloseArea())
			EndIf

			cQueryS := "SELECT G1_FILIAL, " + CRLF
			cQueryS += "G1_COD, " + CRLF
			cQueryS += "G1_COMP, " + CRLF
			cQueryS += "G1_QUANT " + CRLF
			cQueryS += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryS += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgr[_nSgr][01]+"' " + CRLF
			cQueryS += " AND B1_COD = G1_COD " + CRLF
			cQueryS += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryS += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryS += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryS += " AND B1_COD = '"+_aGerSgr[_nSgr][03]+"' " + CRLF
			cQueryS += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryS += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryS += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryS += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryS New Alias "TRBR"

			TRBS->(DbGoTop())
				
			While TRBS->(!Eof())

				Aadd(_aGerSgs,{TRBS->G1_FILIAL,TRBS->G1_COD,TRBS->G1_COMP})				
				Aadd(_aGerSgA,{TRBS->G1_FILIAL,TRBS->G1_COD,TRBS->G1_COMP,TRB1->G1_COD,TRBS->G1_QUANT})

				TRBS->(DbSkip())

			EndDo 

		Next _nSgr	
	
	EndIf

	If Len(_aGerSgs) > 0

		For _nSgs := 1 To Len(_aGerSgs)

			If Select("TRBT") > 0
				TRBT->(DbCloseArea())
			EndIf

			cQueryT := "SELECT G1_FILIAL, " + CRLF
			cQueryT += "G1_COD, " + CRLF
			cQueryT += "G1_COMP, " + CRLF
			cQueryT += "G1_QUANT " + CRLF
			cQueryT += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryT += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgs[_nSgs][01]+"' " + CRLF
			cQueryT += " AND B1_COD = G1_COD " + CRLF
			cQueryT += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryT += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryT += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryT += " AND B1_COD = '"+_aGerSgs[_nSgs][03]+"' " + CRLF
			cQueryT += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryT += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryT += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryT += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryT New Alias "TRBT"

			TRBT->(DbGoTop())
				
			While TRBT->(!Eof())

				Aadd(_aGerSgt,{TRBT->G1_FILIAL,TRBT->G1_COD,TRBT->G1_COMP})				
				Aadd(_aGerSgA,{TRBT->G1_FILIAL,TRBT->G1_COD,TRBT->G1_COMP,TRB1->G1_COD,TRBT->G1_QUANT})

				TRBT->(DbSkip())

			EndDo 

		Next _nSgs	
	
	EndIf

	If Len(_aGerSgt) > 0

		For _nSgt := 1 To Len(_aGerSgt)

			If Select("TRBU") > 0
				TRBU->(DbCloseArea())
			EndIf

			cQueryU := "SELECT G1_FILIAL, " + CRLF
			cQueryU += "G1_COD, " + CRLF
			cQueryU += "G1_COMP, " + CRLF
			cQueryU += "G1_QUANT " + CRLF
			cQueryU += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryU += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgt[_nSgt][01]+"' " + CRLF
			cQueryU += " AND B1_COD = G1_COD " + CRLF
			cQueryU += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryU += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryU += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryU += " AND B1_COD = '"+_aGerSgt[_nSgt][03]+"' " + CRLF
			cQueryU += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryU += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryU += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryU += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryU New Alias "TRBU"

			TRBU->(DbGoTop())
				
			While TRBU->(!Eof())

				Aadd(_aGerSgu,{TRBU->G1_FILIAL,TRBU->G1_COD,TRBU->G1_COMP})				
				Aadd(_aGerSgA,{TRBU->G1_FILIAL,TRBU->G1_COD,TRBU->G1_COMP,TRB1->G1_COD,TRBU->G1_COMP})

				TRBU->(DbSkip())

			EndDo 

		Next _nSgt	
	
	EndIf

	If Len(_aGerSgu) > 0

		For _nSgu := 1 To Len(_aGerSgu)

			If Select("TRBV") > 0
				TRBV->(DbCloseArea())
			EndIf

			cQueryV := "SELECT G1_FILIAL, " + CRLF
			cQueryV += "G1_COD, " + CRLF
			cQueryV += "G1_COMP, " + CRLF
			cQueryV += "G1_QUANT " + CRLF
			cQueryV += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryV += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgu[_nSgu][01]+"' " + CRLF
			cQueryV += " AND B1_COD = G1_COD " + CRLF
			cQueryV += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryV += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryV += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryV += " AND B1_COD = '"+_aGerSgu[_nSgu][03]+"' " + CRLF
			cQueryV += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryV += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryV += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryV += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryV New Alias "TRBV"

			TRBV->(DbGoTop())
				
			While TRBV->(!Eof())

				Aadd(_aGerSgv,{TRBV->G1_FILIAL,TRBV->G1_COD,TRBV->G1_COMP})				
				Aadd(_aGerSgA,{TRBV->G1_FILIAL,TRBV->G1_COD,TRBV->G1_COMP,TRB1->G1_COD,TRBV->G1_QUANT})

				TRBV->(DbSkip())

			EndDo 

		Next _nSgu	
	
	EndIf

	If Len(_aGerSgv) > 0

		For _nSgv := 1 To Len(_aGerSgv)

			If Select("TRBX") > 0
				TRBX->(DbCloseArea())
			EndIf

			cQueryX := "SELECT G1_FILIAL, " + CRLF
			cQueryX += "G1_COD, " + CRLF
			cQueryX += "G1_COMP, " + CRLF
			cQueryX += "G1_QUANT " + CRLF
			cQueryX += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryX += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgv[_nSgv][01]+"' " + CRLF
			cQueryX += " AND B1_COD = G1_COD " + CRLF
			cQueryX += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryX += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryX += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryX += " AND B1_COD = '"+_aGerSgv[_nSgv][03]+"' " + CRLF
			cQueryX += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryX += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryX += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryX += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryX New Alias "TRBX"

			TRBX->(DbGoTop())
				
			While TRBX->(!Eof())

				Aadd(_aGerSgx,{TRBX->G1_FILIAL,TRBX->G1_COD,TRBX->G1_COMP})				
				Aadd(_aGerSgA,{TRBX->G1_FILIAL,TRBX->G1_COD,TRBX->G1_COMP,TRB1->G1_COD,TRBX->G1_QUANT})

				TRBX->(DbSkip())

			EndDo 

		Next _nSgv	
	
	EndIf

	If Len(_aGerSgx) > 0

		For _nSgx := 1 To Len(_aGerSgx)

			If Select("TRBZ") > 0
				TRBZ->(DbCloseArea())
			EndIf

			cQueryZ := "SELECT G1_FILIAL, " + CRLF
			cQueryZ += "G1_COD, " + CRLF
			cQueryZ += "G1_COMP, " + CRLF
			cQueryZ += "G1_QUANT " + CRLF
			cQueryZ += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryZ += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgx[_nSgx][01]+"' " + CRLF
			cQueryZ += " AND B1_COD = G1_COD " + CRLF
			cQueryZ += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryZ += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryZ += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryZ += " AND B1_COD = '"+_aGerSgx[_nSgx][03]+"' " + CRLF
			cQueryZ += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryZ += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryZ += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryZ += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryZ New Alias "TRBZ"

			TRBZ->(DbGoTop())
				
			While TRBZ->(!Eof())

				Aadd(_aGerSgz,{TRBZ->G1_FILIAL,TRBZ->G1_COD,TRBZ->G1_COMP})				
				Aadd(_aGerSgA,{TRBZ->G1_FILIAL,TRBZ->G1_COD,TRBZ->G1_COMP,TRB1->G1_COD,TRBZ->G1_COMP})

				TRBZ->(DbSkip())

			EndDo 

		Next _nSgx	
	
	EndIf

	If Len(_aGerSgz) > 0

		For _nSgz := 1 To Len(_aGerSgz)

			If Select("TRBW") > 0
				TRBW->(DbCloseArea())
			EndIf

			cQueryW := "SELECT G1_FILIAL, " + CRLF
			cQueryW += "G1_COD, " + CRLF
			cQueryW += "G1_COMP, " + CRLF
			cQueryW += "G1_QUANT " + CRLF
			cQueryW += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryW += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgz[_nSgz][01]+"' " + CRLF
			cQueryW += " AND B1_COD = G1_COD " + CRLF
			cQueryW += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryW += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryW += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryW += " AND B1_COD = '"+_aGerSgz[_nSgz][03]+"' " + CRLF
			cQueryW += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryW += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryW += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryW += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryW New Alias "TRBW"

			TRBW->(DbGoTop())
				
			While TRBW->(!Eof())

				Aadd(_aGerSgw,{TRBW->G1_FILIAL,TRBW->G1_COD,TRBW->G1_COMP})				
				Aadd(_aGerSgA,{TRBW->G1_FILIAL,TRBW->G1_COD,TRBW->G1_COMP,TRB1->G1_COD,TRBW->G1_QUANT})

				TRBW->(DbSkip())

			EndDo 

		Next _nSgz	
	
	EndIf

	If Len(_aGerSgw) > 0

		For _nSgw := 1 To Len(_aGerSgw)

			If Select("TRBY") > 0
				TRBY->(DbCloseArea())
			EndIf

			cQueryY := "SELECT G1_FILIAL, " + CRLF
			cQueryY += "G1_COD, " + CRLF
			cQueryY += "G1_COMP, " + CRLF
			cQueryY += "G1_QUANT " + CRLF
			cQueryY += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQueryY += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgw[_nSgw][01]+"' " + CRLF
			cQueryY += " AND B1_COD = G1_COD " + CRLF
			cQueryY += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryY += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQueryY += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQueryY += " AND B1_COD = '"+_aGerSgw[_nSgw][03]+"' " + CRLF
			cQueryY += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQueryY += " AND B1_MSBLQL <> '1' " + CRLF
			cQueryY += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQueryY += "ORDER BY B1_COD " + CRLF

			TCQuery cQueryY New Alias "TRBY"

			TRBY->(DbGoTop())
				
			While TRBY->(!Eof())

				Aadd(_aGerSgy,{TRBY->G1_FILIAL,TRBY->G1_COD,TRBY->G1_COMP})				
				Aadd(_aGerSgA,{TRBY->G1_FILIAL,TRBY->G1_COD,TRBY->G1_COMP,TRB1->G1_COD,TRBY->G1_QUANT})

				TRBY->(DbSkip())

			EndDo 

		Next _nSgw	
	
	EndIf

	If Len(_aGerSgy) > 0

		For _nSgy := 1 To Len(_aGerSgy)

			If Select("TRB0") > 0
				TRB0->(DbCloseArea())
			EndIf

			cQuery0 := "SELECT G1_FILIAL, " + CRLF
			cQuery0 += "G1_COD, " + CRLF
			cQuery0 += "G1_COMP, " + CRLF
			cQuery0 += "G1_QUANT " + CRLF
			cQuery0 += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
			cQuery0 += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgy[_nSgy][01]+"' " + CRLF
			cQuery0 += " AND B1_COD = G1_COD " + CRLF
			cQuery0 += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
			cQuery0 += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
			cQuery0 += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
			cQuery0 += " AND B1_COD = '"+_aGerSgy[_nSgy][03]+"' " + CRLF
			cQuery0 += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCUSNT"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
			cQuery0 += " AND B1_MSBLQL <> '1' " + CRLF
			cQuery0 += " AND SB1.D_E_L_E_T_ = '' " + CRLF
			cQuery0 += "ORDER BY B1_COD " + CRLF

			TCQuery cQuery0 New Alias "TRB0"

			TRB0->(DbGoTop())
				
			While TRB0->(!Eof())

				Aadd(_aGerSgA,{TRB0->G1_FILIAL,TRB0->G1_COD,TRB0->G1_COMP,TRB1->G1_COD,TRB0->G1_QUANT})

				TRB0->(DbSkip())

			EndDo 

		Next _nSgy	
	
	EndIf

	TRB1->(DbSkip())

EndDo
/*----------------------------------------------------------+
| GERA AS EMBALAGENS E MATERIAS PRIMAS DO PRODUTO ACABADO   | 
+----------------------------------------------------------*/
_cQuery     := "" 
_nQuantItem := 0
_nQuantPai  := 0 
_nCount     := 0
_nQtd1      := 0
_cCodigo1   := ""
_nQtd2      := 0
_cCodigo2   := ""
_nQtd3      := 0
_cCodigo3   := ""
_nQtd4      := 0
_cCodigo4   := ""
_nQtd5      := 0
_cCodigo5   := ""
_nQtd6      := 0
_cCodigo6   := ""
_nQtd7      := 0
_cCodigo7   := ""
_nQtd8      := 0
_cCodigo8   := ""
_nQtd9      := 0
_cCodigo9   := ""
_nQtdA      := 0
_cCodigoA   := ""
_nCalcItem  := 0

If Len(_aGerPrd) > 0

	For _nPrd := 1 To Len(_aGerPrd)

		If Select("TRBP") > 0
			TRBP->(DbCloseArea())
		EndIf

		_cQuery := "SELECT G1_FILIAL, " + CRLF
		_cQuery += "G1_COD, " + CRLF
		_cQuery += "G1_COMP, " + CRLF
		_cQuery += "G1_QUANT, " + CRLF
		_cQuery += "G1_PERDA, " + CRLF
		_cQuery += "B1_FATOR, " + CRLF
		_cQuery += "G1_OPC, " + CRLF
		_cQuery += "B1_REVATU, " + CRLF
		_cQuery += "G1_FIXVAR, " + CRLF
		_cQuery += "G1_TRT, " + CRLF
		_cQuery += "G1_INI, " + CRLF
		_cQuery += "G1_FIM " + CRLF
		_cQuery += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
		_cQuery += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerPrd[_nPrd][01]+"' " + CRLF
		_cQuery += " AND B1_COD = G1_COD " + CRLF
		_cQuery += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
		_cQuery += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
		_cQuery += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
		_cQuery += " AND B1_COD = '"+_aGerPrd[_nPrd][02]+"' " + CRLF
		_cQuery += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCOMP"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
		_cQuery += " AND B1_MSBLQL <> '1' " + CRLF
		_cQuery += " AND SB1.D_E_L_E_T_ = '' " + CRLF
		_cQuery += "ORDER BY B1_COD " + CRLF

		TCQuery _cQuery New Alias "TRBP"

		TRBP->(DbGoTop())

		While TRBP->(!Eof())
			
			_nQuantPai  := Posicione("SB1",1,xFilial("SB1")+_aGerPrd[_nPrd][02],"B1_QB") 

			_nQuantItem := (TRBP->G1_QUANT/_nQuantPai) 

			DbSelectArea("PAZ")
			DbSetOrder(1) // PAZ_FILIAL+PAZ_ORDEM+PAZ_COD+PAZ_COMP+PAZ_CODPI
			If DbSeek(xFilial("PAZ")+"000001"+_aGerPrd[_nPrd][02]+TRBP->G1_COMP+TRBP->G1_COD)

				Reclock("PAZ",.F.)

				PAZ_FILIAL := TRBP->G1_FILIAL
				PAZ_ORDEM  := '000001'
				PAZ_COD    := _aGerPrd[_nPrd][02]
				PAZ_COMP   := TRBP->G1_COMP
				PAZ_CODPI  := _aGerPrd[_nPrd][02]
				PAZ_UM     := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_UM")
				PAZ_TIPO   := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_TIPO")
				PAZ_QUANT  := TRBP->G1_QUANT 
				PAZ_REV    := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COD,"B1_REVATU")
				PAZ_QB     := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_QB")
				PAZ_QTDBAS := _nQuantItem
				If cFilant $ "0803"
					PAZ_VALOR4 := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_VALOR4Q")
				ElseIf cFilant $ "0901"
					PAZ_VALOR4 := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_VALOR4P")
				Else 
					PAZ_VALOR4 := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_VALOR4")
				EndIf
				PAZ_PICM   := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_XPICM")
				PAZ_PPIS   := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_XPPIS")
				PAZ_PCOF   := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_XPCOFIN")
				PAZ_IPI    := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_IPI")
				If cFilant $ "0803"
					PAZ_CUSNET := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_CNETQUA")
				ElseIf cFilant $ "0901"
					PAZ_CUSNET := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_CNETPHO")
				Else 
					PAZ_CUSNET := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_CUSTNET")
				EndIf
				PAZ_DATA   := Ddatabase 
				PAZ_STATUS := If(MV_PAR04 = 1,"1","2")
				PAZ_MSBLQL := "2" 

				PAZ->( Msunlock() )

			Else 

				Reclock("PAZ",.T.)

				PAZ_FILIAL := TRBP->G1_FILIAL
				PAZ_ORDEM  := '000001'
				PAZ_COD    := _aGerPrd[_nPrd][02]
				PAZ_COMP   := TRBP->G1_COMP
				PAZ_CODPI  := _aGerPrd[_nPrd][02]
				PAZ_UM     := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_UM")
				PAZ_TIPO   := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_TIPO")
				PAZ_QUANT  := TRBP->G1_QUANT 
				PAZ_REV    := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COD,"B1_REVATU")
				PAZ_QB     := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_QB")
				PAZ_QTDBAS := _nQuantItem
				If cFilant $ "0803"
					PAZ_VALOR4 := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_VALOR4Q")
				ElseIf cFilant $ "0901"
					PAZ_VALOR4 := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_VALOR4P")
				Else 
					PAZ_VALOR4 := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_VALOR4")
				EndIf
				PAZ_PICM   := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_XPICM")
				PAZ_PPIS   := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_XPPIS")
				PAZ_PCOF   := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_XPCOFIN")
				PAZ_IPI    := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_IPI")
				If cFilant $ "0803"
					PAZ_CUSNET := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_CNETQUA")
				ElseIf cFilant $ "0901"
					PAZ_CUSNET := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_CNETPHO")
				Else 
					PAZ_CUSNET := Posicione("SB1",1,xFilial("SB1")+TRBP->G1_COMP,"B1_CUSTNET")
				EndIf
				PAZ_DATA   := Ddatabase 
				PAZ_STATUS := If(MV_PAR04 = 1,"1","2")
				PAZ_MSBLQL := "2" 

				PAZ->( Msunlock() )

			EndIf

			TRBP->(DbSkip())

		EndDo

	Next _nPrd	

EndIf
/*---------------------------------------------------------------+
| GERA AS EMBALAGENS E MATERIAS PRIMAS DO PRODUTO INTERMEDIARIO  | 
+---------------------------------------------------------------*/
_cQuery     := "" 
_nQuantItem := 0
_nQuantPai  := 0 
_nCount     := 0
_nQtd1      := 0
_cCodigo1   := ""
_nQtd2      := 0
_cCodigo2   := ""
_nQtd3      := 0
_cCodigo3   := ""
_nQtd4      := 0
_cCodigo4   := ""
_nQtd5      := 0
_cCodigo5   := ""
_nQtd6      := 0
_cCodigo6   := ""
_nQtd7      := 0
_cCodigo7   := ""
_nQtd8      := 0
_cCodigo8   := ""
_nQtd9      := 0
_cCodigo9   := ""
_nQtdA      := 0
_cCodigoA   := ""
_nCalcItem  := 0

If Len(_aGerSgA) > 0

	For _nSgA := 1 To Len(_aGerSgA)
			
		If Select("TRBA") > 0
			TRBA->(DbCloseArea())
		EndIf

		_cQuery := "SELECT G1_FILIAL, " + CRLF
		_cQuery += "G1_COD, " + CRLF
		_cQuery += "G1_COMP, " + CRLF
		_cQuery += "G1_QUANT, " + CRLF
		_cQuery += "G1_PERDA, " + CRLF
		_cQuery += "B1_FATOR, " + CRLF
		_cQuery += "G1_OPC, " + CRLF
		_cQuery += "B1_REVATU, " + CRLF
		_cQuery += "G1_FIXVAR, " + CRLF
		_cQuery += "G1_TRT, " + CRLF
		_cQuery += "G1_INI, " + CRLF
		_cQuery += "G1_FIM " + CRLF
		_cQuery += "FROM "+RetSqlName("SB1")+" AS SB1 " + CRLF
		_cQuery += "INNER JOIN "+RetSqlName("SG1")+" AS SG1 ON G1_FILIAL = '"+_aGerSgA[_nSgA][01]+"' " + CRLF
		_cQuery += " AND B1_COD = G1_COD " + CRLF
		_cQuery += " AND SG1.D_E_L_E_T_ = ' ' " + CRLF
		_cQuery += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
		_cQuery += " AND B1_REVATU BETWEEN G1_REVINI AND G1_REVFIM " + CRLF
		_cQuery += " AND B1_COD = '"+_aGerSgA[_nSgA][03]+"' " + CRLF
		_cQuery += " AND EXISTS (SELECT * FROM "+RetSqlName("SB1")+" WHERE B1_TIPO IN "+FORMATIN(GETMV("QE_TPCOMP"),"/")+" AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ' ) " + CRLF
		_cQuery += " AND B1_MSBLQL <> '1' " + CRLF
		_cQuery += " AND SB1.D_E_L_E_T_ = '' " + CRLF
		_cQuery += "ORDER BY B1_COD " + CRLF

		TCQuery _cQuery New Alias "TRBA"

		TRBA->(DbGoTop())

		While TRBA->(!Eof())
			
			_nQuantPai  := Posicione("SB1",1,xFilial("SB1")+_aGerSgA[_nSgA][04],"B1_QB")
			
			If len(_aGerSgA) > 0
				
				For _nCount := 1 To len(_aGerSgA)
					If _nCount = 1
						If Posicione("SB1",1,xFilial("SB1")+_aGerSgA[_nCount][04],"B1_TIPO") $ FORMATIN(GETMV("QE_TPCUSNT"),"/")
							_nQtd1    := _aGerSgA[_nCount][05]
							_cCodigo1 := _aGerSgA[_nCount][03]
						EndIf			
					Endif	
					If _nCount = 2
						If Posicione("SB1",1,xFilial("SB1")+_aGerSgA[_nCount][04],"B1_TIPO") $ FORMATIN(GETMV("QE_TPCUSNT"),"/")
							_nQtd2    := _aGerSgA[_nCount][05]
							_cCodigo2 := _aGerSgA[_nCount][03]
						EndIf			
					Endif	
					If _nCount = 3
						If Posicione("SB1",1,xFilial("SB1")+_aGerSgA[_nCount][04],"B1_TIPO") $ FORMATIN(GETMV("QE_TPCUSNT"),"/")
							_nQtd3    := _aGerSgA[_nCount][05]
							_cCodigo3 := _aGerSgA[_nCount][03]
						EndIf			
					Endif	
					If _nCount = 4
						If Posicione("SB1",1,xFilial("SB1")+_aGerSgA[_nCount][04],"B1_TIPO") $ FORMATIN(GETMV("QE_TPCUSNT"),"/")
							_nQtd4    := _aGerSgA[_nCount][05]
							_cCodigo4 := _aGerSgA[_nCount][03]
						EndIf			
					Endif	
					If _nCount = 5
						If Posicione("SB1",1,xFilial("SB1")+_aGerSgA[_nCount][04],"B1_TIPO") $ FORMATIN(GETMV("QE_TPCUSNT"),"/")
							_nQtd5    := _aGerSgA[_nCount][05]
							_cCodigo5 := _aGerSgA[_nCount][03]
						EndIf			
					Endif	
					If _nCount = 6
						If Posicione("SB1",1,xFilial("SB1")+_aGerSgA[_nCount][04],"B1_TIPO") $ FORMATIN(GETMV("QE_TPCUSNT"),"/")
							_nQtd6    := _aGerSgA[_nCount][05]
							_cCodigo6 := _aGerSgA[_nCount][03]
						EndIf			
					Endif	
					If _nCount = 7
						If Posicione("SB1",1,xFilial("SB1")+_aGerSgA[_nCount][04],"B1_TIPO") $ FORMATIN(GETMV("QE_TPCUSNT"),"/")
							_nQtd7    := _aGerSgA[_nCount][05]
							_cCodigo7 := _aGerSgA[_nCount][03]
						EndIf			
					Endif	
					If _nCount = 8
						If Posicione("SB1",1,xFilial("SB1")+_aGerSgA[_nCount][04],"B1_TIPO") $ FORMATIN(GETMV("QE_TPCUSNT"),"/")
							_nQtd8    := _aGerSgA[_nCount][05]
							_cCodigo8 := _aGerSgA[_nCount][03]
						EndIf			
					Endif	
					If _nCount = 9
						If Posicione("SB1",1,xFilial("SB1")+_aGerSgA[_nCount][04],"B1_TIPO") $ FORMATIN(GETMV("QE_TPCUSNT"),"/")
							_nQtd9    := _aGerSgA[_nCount][05]
							_cCodigo9 := _aGerSgA[_nCount][03]
						EndIf			
					Endif	
					If _nCount = 10
						If Posicione("SB1",1,xFilial("SB1")+_aGerSgA[_nCount][04],"B1_TIPO") $ FORMATIN(GETMV("QE_TPCUSNT"),"/")
							_nQtdA    := _aGerSgA[_nCount][05]
							_cCodigoA := _aGerSgA[_nCount][03]
						EndIf			
					Endif	

				NExt _nCount 

			EndIf 		

			If _cCodigo1 = _aGerSgA[_nSgA][03]
				_nQuantItem := (TRBA->G1_QUANT*_nQtd1/100)	
			EndIf 
			If _cCodigo2 = _aGerSgA[_nSgA][03]
				_nCalcItem := (_nQtd1*_nQtd2/100)
				_nQuantItem := (TRBA->G1_QUANT*_nCalcItem/100)	
			EndIf 		
			If _cCodigo3 = _aGerSgA[_nSgA][03]
				_nCalcItem := (_nQtd2*_nQtd3/100)
				_nQuantItem := (TRBA->G1_QUANT*_nCalcItem/100)	
			EndIf 		
			If _cCodigo4 = _aGerSgA[_nSgA][03]
				_nCalcItem := (_nQtd3*_nQtd4/100)
				_nQuantItem := (TRBA->G1_QUANT*_nCalcItem/100)	
			EndIf 		
			If _cCodigo5 = _aGerSgA[_nSgA][03]
				_nCalcItem := (_nQtd4*_nQtd5/100)
				_nQuantItem := (TRBA->G1_QUANT*_nCalcItem/100)	
			EndIf 		
			If _cCodigo6 = _aGerSgA[_nSgA][03]
				_nCalcItem := (_nQtd5*_nQtd6/100)
				_nQuantItem := (TRBA->G1_QUANT*_nCalcItem/100)	
			EndIf 		
			If _cCodigo7 = _aGerSgA[_nSgA][03]
				_nCalcItem := (_nQtd6*_nQtd7/100)
				_nQuantItem := (TRBA->G1_QUANT*_nCalcItem/100)	
			EndIf 		
			If _cCodigo8 = _aGerSgA[_nSgA][03]
				_nCalcItem := (_nQtd7*_nQtd8/100)
				_nQuantItem := (TRBA->G1_QUANT*_nCalcItem/100)	
			EndIf 		
			If _cCodigo9 = _aGerSgA[_nSgA][03]
				_nCalcItem := (_nQtd8*_nQtd9/100)
				_nQuantItem := (TRBA->G1_QUANT*_nCalcItem/100)	
			EndIf 		
			If _cCodigoA = _aGerSgA[_nSgA][03]
				_nCalcItem := (_nQtd9*_nQtdA/100)
				_nQuantItem := (TRBA->G1_QUANT*_nCalcItem/100)	
			EndIf 		
			
			DbSelectArea("PAZ")
			DbSetOrder(1) // PAZ_FILIAL+PAZ_ORDEM+PAZ_COD+PAZ_COMP+PAZ_CODPI
			If DbSeek(xFilial("PAZ")+"000001"+_aGerSgA[_nSgA][04]+TRBA->G1_COMP+TRBA->G1_COD)

				Reclock("PAZ",.F.)

				PAZ_FILIAL := TRBA->G1_FILIAL
				PAZ_ORDEM  := '000001'
				PAZ_COD    := _aGerSgA[_nSgA][04]
				PAZ_COMP   := TRBA->G1_COMP
				PAZ_CODPI  := _aGerSgA[_nSgA][03]
				PAZ_UM     := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_UM")
				PAZ_TIPO   := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_TIPO")
				PAZ_QUANT  := TRBA->G1_QUANT
				PAZ_REV    := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COD,"B1_REVATU")
				PAZ_QB     := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_QB")
				PAZ_QTDBAS := _nQuantItem
				If cFilant $ "0803"
					PAZ_VALOR4 := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_VALOR4Q")
				ElseIf cFilant $ "0901"
					PAZ_VALOR4 := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_VALOR4P")
				Else 
					PAZ_VALOR4 := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_VALOR4")
				EndIf
				PAZ_PICM   := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_XPICM")
				PAZ_PPIS   := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_XPPIS")
				PAZ_PCOF   := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_XPCOFIN")
				PAZ_IPI    := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_IPI")
				If cFilant $ "0803"
					PAZ_CUSNET := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_CNETQUA")
				ElseIf cFilant $ "0901"
					PAZ_CUSNET := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_CNETPHO")
				Else 
					PAZ_CUSNET := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_CUSTNET")
				EndIf
				PAZ_DATA   := Ddatabase 
				PAZ_STATUS := If(MV_PAR04 = 1,"1","2")
				PAZ_MSBLQL := "2" 

				PAZ->( Msunlock() )

			Else 

				Reclock("PAZ",.T.)

				PAZ_FILIAL := TRBA->G1_FILIAL
				PAZ_ORDEM  := '000001'
				PAZ_COD    := _aGerSgA[_nSgA][04]
				PAZ_COMP   := TRBA->G1_COMP
				PAZ_CODPI  := _aGerSgA[_nSgA][03]
				PAZ_UM     := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_UM")
				PAZ_TIPO   := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_TIPO")
				PAZ_QUANT  := TRBA->G1_QUANT
				PAZ_REV    := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COD,"B1_REVATU")
				PAZ_QB     := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_QB")
				PAZ_QTDBAS := _nQuantItem
				If cFilant $ "0803"
					PAZ_VALOR4 := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_VALOR4Q")
				ElseIf cFilant $ "0901"
					PAZ_VALOR4 := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_VALOR4P")
				Else 
					PAZ_VALOR4 := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_VALOR4")
				EndIf
				PAZ_PICM   := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_XPICM")
				PAZ_PPIS   := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_XPPIS")
				PAZ_PCOF   := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_XPCOFIN")
				PAZ_IPI    := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_IPI")
				If cFilant $ "0803"
					PAZ_CUSNET := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_CNETQUA")
				ElseIf cFilant $ "0901"
					PAZ_CUSNET := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_CNETPHO")
				Else 
					PAZ_CUSNET := Posicione("SB1",1,xFilial("SB1")+TRBA->G1_COMP,"B1_CUSTNET")
				EndIf
				PAZ_DATA   := Ddatabase 
				PAZ_STATUS := If(MV_PAR04 = 1,"1","2")
				PAZ_MSBLQL := "2" 

				PAZ->( Msunlock() )

			EndIf

			TRBA->(DbSkip())

		EndDo

	Next _nSgA	

EndIf
/*---------------------------------------+
| ATUALIZA CUSTO NET PRODUTO ACABADO     | 
+---------------------------------------*/
cQryA := ""

If Select("TRBK") > 0
	TRBK->(DbCloseArea())
EndIf

cQryA := "SELECT PAZ_FILIAL, PAZ_COD  " + CRLF
cQryA += "FROM " + RetSqlName("PAZ") + " AS PAZ " + CRLF
cQryA += " INNER JOIN " + RetSqlName("SB1") + " AS SB1 ON B1_COD = PAZ_COD " + CRLF
cQryA += " AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQryA += "WHERE PAZ_FILIAL = '"+xFilial("PAZ")+"' " + CRLF
cQryA += " AND B1_TIPO IN "+FORMATIN(GETMV("QE_PRODPA"),"/")+" " + CRLF
cQryA += " AND PAZ_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " + CRLF
cQryA += " AND B1_MSBLQL <> '1' " + CRLF
cQryA += " AND PAZ.D_E_L_E_T_ = ' ' " + CRLF
cQryA += "GROUP BY PAZ_FILIAL,PAZ_COD " + CRLF

TCQuery cQryA New Alias "TRBK"

TRBK->(DbGoTop())

While TRBK->(!Eof())

	If Select("TRBA") > 0
		TRBA->(DbCloseArea())
	EndIf

	cQry := "SELECT PAZ_FILIAL, PAZ_COD, SUM(PAZ_QTDBAS*PAZ_CUSNET) AS TOTAL " + CRLF
	cQry += "FROM " + RetSqlName("PAZ") + " AS PAZ " + CRLF
	cQry += " INNER JOIN " + RetSqlName("SB1") + " AS SB1 ON B1_COD = PAZ_COD " + CRLF
	cQry += " AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQry += "WHERE PAZ_FILIAL = '"+TRBK->PAZ_FILIAL+"' " + CRLF
	cQry += " AND PAZ_COD = '"+TRBK->PAZ_COD+"' " + CRLF
	cQry += " AND B1_TIPO IN "+FORMATIN(GETMV("QE_PRODPA"),"/")+" " + CRLF
	cQry += " AND PAZ.D_E_L_E_T_ = ' ' " + CRLF
	cQry += " AND B1_MSBLQL <> '1' " + CRLF
	cQry += "GROUP BY PAZ_FILIAL, PAZ_COD " + CRLF

	TCQuery cQry New Alias "TRBA"

	TRBA->(DbGoTop())

	While TRBA->(!Eof())

		If cFilant $ "0803"

			DbSelectArea("SB1")
			DbSetOrder(1)
			If DbSeek(xFilial("SB1")+TRBA->PAZ_COD)  

				RecLock("SB1",.F.)

				SB1->B1_VALOR4Q  := TRBA->TOTAL
				SB1->B1_CNETQUA  := TRBA->TOTAL
				SB1->B1_XCUSTD   := TRBA->TOTAL
				SB1->B1_XDATREF  := Ddatabase
				SB1->B1_XUREV    := Ddatabase

				SB1->(MsUnlock())

			EndIf
		ElseIf cFilant $ "0901"

			DbSelectArea("SB1")
			DbSetOrder(1)
			If DbSeek(xFilial("SB1")+TRBA->PAZ_COD)  

				RecLock("SB1",.F.)

				SB1->B1_VALOR4P  := TRBA->TOTAL
				SB1->B1_CNETPHO  := TRBA->TOTAL 
				SB1->B1_XCUSTD   := TRBA->TOTAL
				SB1->B1_XDATREF  := Ddatabase
				SB1->B1_XUREV    := Ddatabase

				SB1->(MsUnlock())

			EndIf

		EndIf

		TRBA->(DbSkip())

	EndDo

	TRBK->(DbSkip())

EndDo
/*-------------------------------------------------------------+
| ATUALIZA CUSTO NET / CUSTO STD / CUSTO TEST / PREÇO SUGERIDO | 
+-------------------------------------------------------------*/
If cFilant $ "0803"

	cUpdate := "  UPDATE " + RetSqlName("SB1") + ENTER
	cUpdate += "  SET B1_XCUSTD  = B1_VAL1, " + ENTER                                    
	cUpdate += "      B1_VALOR4Q = B1_VAL1, " + ENTER                                    		
	cUpdate += "      B1_CUST" + StrZero(Month(dDataBase), 2) + " = B1_VAL1, " + ENTER 
	cUpdate += "      B1_XPRV1 = B1_CNETQUA / ( (1 - 0.04 -  "
	cUpdate += "      				CASE WHEN B1_COD LIKE '8%' AND SUBSTRING(B1_COD,4,1) = '.' THEN 0.03 "  + ENTER //"Produtos Revenda
	cUpdate += "      					ELSE 0.155 END ) - ( 40 * 0.000421 ) - ( 0.0925 + 0.18 ) - 0.025 ) " + ENTER 
	cUpdate += "  WHERE	D_E_L_E_T_ <> '*' " + ENTER                                   
	cUpdate += "  		AND B1_TIPO IN "+FORMATIN(GETMV("QE_PRODPA"),"/")+" " + ENTER                           
	cUpdate += "  		AND NOT EXISTS (SELECT G1_COD FROM  " + RetSqlName("SG1") + "  WHERE D_E_L_E_T_ = '' AND G1_COD = B1_COD) " + ENTER
	cUpdate += "  		AND B1_MSBLQL <> '1' "   

	TcSQLExec(cUpdate)

ElseIf cFilant $ "0901"

	cUpdate := "  UPDATE " + RetSqlName("SB1") + ENTER
	cUpdate += "  SET B1_XCUSTD = B1_VAL1, " + ENTER                                    
	cUpdate += "      B1_VALOR4P = B1_VAL1, " + ENTER                                    		
	cUpdate += "      B1_CUST" + StrZero(Month(dDataBase), 2) + " = B1_VAL1, " + ENTER 
	cUpdate += "      B1_XPRV1 = B1_CNETPHO / ( (1 - 0.04 -  "
	cUpdate += "      				CASE WHEN B1_COD LIKE '8%' AND SUBSTRING(B1_COD,4,1) = '.' THEN 0.03 "  + ENTER //"Produtos Revenda
	cUpdate += "      					ELSE 0.155 END ) - ( 40 * 0.000421 ) - ( 0.0925 + 0.18 ) - 0.025 ) " + ENTER 
	cUpdate += "  WHERE	D_E_L_E_T_ <> '*' " + ENTER                                   
	cUpdate += "  		AND B1_TIPO IN "+FORMATIN(GETMV("QE_PRODPA"),"/")+" " + ENTER                           
	cUpdate += "  		AND NOT EXISTS (SELECT G1_COD FROM  " + RetSqlName("SG1") + "  WHERE D_E_L_E_T_ = '' AND G1_COD = B1_COD) " + ENTER
	cUpdate += "  		AND B1_MSBLQL <> '1' "   

	TcSQLExec(cUpdate)

EndIf


If Select("TRB0") > 0
	TRB0->(DbCloseArea())
EndIf
If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf
If Select("TRB2") > 0
	TRB2->(DbCloseArea())
EndIf
If Select("TRB3") > 0
	TRB3->(DbCloseArea())
EndIf
If Select("TRB4") > 0
	TRB4->(DbCloseArea())
EndIf
If Select("TRB5") > 0
	TRB5->(DbCloseArea())
EndIf
If Select("TRB6") > 0
	TRB6->(DbCloseArea())
EndIf
If Select("TRB7") > 0
	TRB7->(DbCloseArea())
EndIf
If Select("TRB8") > 0
	TRB8->(DbCloseArea())
EndIf
If Select("TRB9") > 0
	TRB9->(DbCloseArea())
EndIf
If Select("TRBA") > 0
	TRBA->(DbCloseArea())
EndIf
If Select("TRBB") > 0
	TRBB->(DbCloseArea())
EndIf
If Select("TRBC") > 0
	TRBC->(DbCloseArea())
EndIf
If Select("TRBD") > 0
	TRBD->(DbCloseArea())
EndIf
If Select("TRBF") > 0
	TRBF->(DbCloseArea())
EndIf
If Select("TRBG") > 0
	TRBG->(DbCloseArea())
EndIf
If Select("TRBH") > 0
	TRBH->(DbCloseArea())
EndIf
If Select("TRBI") > 0
	TRBI->(DbCloseArea())
EndIf
If Select("TRBJ") > 0
	TRBI->(DbCloseArea())
EndIf
If Select("TRBK") > 0
	TRBK->(DbCloseArea())
EndIf
If Select("TRBL") > 0
	TRBL->(DbCloseArea())
EndIf
If Select("TRBM") > 0
	TRBM->(DbCloseArea())
EndIf
If Select("TRBN") > 0
	TRBN->(DbCloseArea())
EndIf
If Select("TRBO") > 0
	TRBO->(DbCloseArea())
EndIf
If Select("TRBP") > 0
	TRBP->(DbCloseArea())
EndIf
If Select("TRBQ") > 0
	TRBQ->(DbCloseArea())
EndIf
If Select("TRBR") > 0
	TRBR->(DbCloseArea())
EndIf
If Select("TRBS") > 0
	TRBS->(DbCloseArea())
EndIf
If Select("TRBT") > 0
	TRBT->(DbCloseArea())
EndIf
If Select("TRBU") > 0
	TRBU->(DbCloseArea())
EndIf
If Select("TRBV") > 0
	TRBV->(DbCloseArea())
EndIf
If Select("TRBX") > 0
	TRBX->(DbCloseArea())
EndIf
If Select("TRBZ") > 0
	TRBZ->(DbCloseArea())
EndIf
If Select("TRBW") > 0
	TRBW->(DbCloseArea())
EndIf
If Select("TRBY") > 0
	TRBY->(DbCloseArea())
EndIf
If Select("TBR2") > 0
	TBR2->(DbCloseArea())
EndIf

Return
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

Aadd(_aPerg,{"Produto De ........?","mv_ch1","C",15,"G","mv_par01","","","","","","SB1","","",0})
Aadd(_aPerg,{"Produto Até........?","mv_ch2","C",15,"G","mv_par02","","","","","","SB1","","",0})
Aadd(_aPerg,{"Qual Filial .......?","mv_ch3","C",20,"G","mv_par03","","","","","","SM0","","",0})
Aadd(_aPerg,{"Tipo de Custo  ....?","mv_ch4","C",01,"C","mv_par04","Test","Stardart","","","","","","",0})


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
