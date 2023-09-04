#include "parmtype.ch"
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"
#include "Colors.ch"
#include "RwMake.ch"

/*/{Protheus.doc} QEEXP888
Marca a 1 Separação na tabela SC9 no campo C9_ 
@Autor Fabio Carneiro 
@since 28/08/2022
@version 1.0
@type user function 
/*/

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

User Function QEEXP888()

Local aSays    := {}
Local aButtons := {}
Local cTitoDlg := "Marca os pedido para Indicadores de entrega expedição"
Local nOpca    := 0
Private _cPerg := "QEEXP88"

aAdd(aSays, "Rotina para marcar as primeiros pedidos para indicadores expedição !!!")
aAdd(aSays, "Esta rotina é apenas para marcar o campo C9_XNUMIND da expedição!")

aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})


FormBatch(cTitoDlg, aSays, aButtons)

If nOpca == 1
	
	oAjustaSx1()

	If !Pergunte(_cPerg,.T.)
		Return
	Else 
		Processa({|| QEEXPMNTok("Gerando planilha, aguarde...")})
	Endif
		
EndIf

Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEEXPMNTok| Autor: | QUALY         | Data: | 08/08/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEEXPMNTok                                   |
+------------+-----------------------------------------------------------+
*/

Static Function QEEXPMNTok()

Local cQuery1 := "" 
Local cQuery2 := ""
Local cQuery3 := ""
Local cQuery4 := ""
Local cQry    := ""
Local cQry1   := ""
/*
+--------------------------------+
| QUERY REFERENTE OS MOVIMENTOS  |
+--------------------------------+
*/
If Select("TRB8") > 0
	TRB8->(DbCloseArea())
EndIf

cQuery1 := "SELECT C9_XNUMIND AS INDICADOR, " + CRLF
cQuery1 += "C9_CLIENTE AS CLIENTE,  " + CRLF
cQuery1 += "C9_LOJA AS LOJA, " + CRLF
cQuery1 += "C9_PEDIDO AS PEDIDO, " + CRLF
cQuery1 += "C9_NFISCAL AS  NFISCAL, " + CRLF
cQuery1 += "C9_SERIENF AS SERIENF, " + CRLF
cQuery1 += "C9_DATALIB AS DATALIB " + CRLF
cQuery1 += "FROM "+RetSqlName("SC9")+" AS SC9  " + CRLF
cQuery1 += "INNER JOIN "+RetSqlName("SF2")+" AS SF2 ON F2_FILIAL = C9_FILIAL " + CRLF
cQuery1 += " AND F2_CLIENTE = C9_CLIENTE " + CRLF
cQuery1 += " AND F2_LOJA  = C9_LOJA " + CRLF
cQuery1 += " AND F2_DOC   = C9_NFISCAL " + CRLF
cQuery1 += " AND F2_SERIE = C9_SERIENF " + CRLF
cQuery1 += " AND SF2.D_E_L_E_T_ = ' ' " + CRLF
cQuery1 += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' " + CRLF
cQuery1 += " AND F2_VEND1  BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " + CRLF
cQuery1 += " AND C9_CLIENTE  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + CRLF
cQuery1 += " AND C9_LOJA BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' " + CRLF
cQuery1 += " AND C9_NFISCAL BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + CRLF
cQuery1 += " AND C9_SERIENF BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' " + CRLF
cQuery1 += " AND C9_DATALIB BETWEEN '"+Dtos(MV_PAR11)+"' AND '"+Dtos(MV_PAR12)+"' " + CRLF
cQuery1 += " AND C9_PEDIDO  BETWEEN '"+MV_PAR13+"' AND '"+MV_PAR14+"' " + CRLF
cQuery1 += " AND SC9.D_E_L_E_T_ = ' ' " + CRLF
cQuery1 += "GROUP BY C9_CLIENTE, C9_LOJA, C9_PEDIDO, C9_NFISCAL, C9_SERIENF, C9_DATALIB, C9_XNUMIND " + CRLF 
cQuery1 += "ORDER BY C9_DATALIB,C9_NFISCAL,C9_PEDIDO " + CRLF

TCQuery cQuery1 New Alias "TRB8"

TRB8->(DbGoTop())

While TRB8->(!Eof())

	If Select("TRB9") > 0
		TRB9->(DbCloseArea())
	EndIf

	cQuery2 := "SELECT C9_XNUMIND AS INDICADOR, " + CRLF
	cQuery2 += " C9_CLIENTE AS CLIENTE, " + CRLF
	cQuery2 += " C9_LOJA AS LOJA, " + CRLF
 	cQuery2 += " C9_NFISCAL AS NFISCAL, " + CRLF
	cQuery2 += " C9_SERIENF AS SERIENF, " + CRLF
	cQuery2 += " C9_DATALIB AS DATALIB, " + CRLF
	cQuery2 += " C9_PEDIDO AS PEDIDO " + CRLF
 	cQuery2 += "FROM "+RetSqlName("SC9")+" AS SC9 " + CRLF
 	cQuery2 += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' " + CRLF
 	cQuery2 += " AND C9_PEDIDO  =  '"+TRB8->PEDIDO+"' " + CRLF
	cQuery2 += " AND C9_CLIENTE = '"+TRB8->CLIENTE+"' " + CRLF
	cQuery2 += " AND C9_LOJA    = '"+TRB8->LOJA+"' " + CRLF
 	cQuery2 += " AND C9_NFISCAL <> ' ' " + CRLF
 	cQuery2 += " AND SC9.D_E_L_E_T_ = ' ' " + CRLF 
	cQuery2 += " GROUP BY C9_XNUMIND, C9_NFISCAL, C9_SERIENF, C9_CLIENTE, C9_LOJA, C9_DATALIB, C9_PEDIDO " + CRLF
 	cQuery2 += "ORDER BY C9_DATALIB,C9_NFISCAL,C9_PEDIDO " + CRLF

	TCQuery cQuery2 New Alias "TRB9"

	TRB9->(DbGoTop())

	While TRB9->(!Eof())

		If TRB8->PEDIDO == TRB9->PEDIDO .And. TRB8->CLIENTE == TRB9->CLIENTE;
		   .And. TRB8->LOJA == TRB9->LOJA .And. TRB8->DATALIB == TRB9->DATALIB;
		   .And. TRB8->NFISCAL == TRB9->NFISCAL .And. TRB8->SERIENF == TRB9->SERIENF 

			If Select("TRBH") > 0
				TRBH->(DbCloseArea())
			EndIf

			cQuery4 := "SELECT C9_XNUMIND AS INDICADOR, " + CRLF
			cQuery4 += " C9_NFISCAL AS NFISCAL, " + CRLF
			cQuery4 += " C9_SERIENF AS SERIENF, " + CRLF
			cQuery4 += " C9_CLIENTE AS CLIENTE, " + CRLF
			cQuery4 += " C9_LOJA AS LOJA " + CRLF
			cQuery4 += "FROM "+RetSqlName("SC9")+" AS SC9 " + CRLF
			cQuery4 += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' " + CRLF
			cQuery4 += " AND C9_NFISCAL = '"+TRB9->NFISCAL+"' " + CRLF
			cQuery4 += " AND C9_SERIENF = '"+TRB9->SERIENF+"' " + CRLF
			cQuery4 += " AND C9_CLIENTE = '"+TRB9->CLIENTE+"' " + CRLF
			cQuery4 += " AND C9_LOJA    = '"+TRB9->LOJA+"' " + CRLF
			cQuery4 += " AND C9_NFISCAL <> ' ' " + CRLF
			cQuery4 += " AND SC9.D_E_L_E_T_ = ' ' " + CRLF 
			cQuery4 += " AND C9_XNUMIND = ' ' " + CRLF
			cQuery4 += "GROUP BY C9_XNUMIND, C9_NFISCAL, C9_SERIENF, C9_CLIENTE, C9_LOJA, C9_DATALIB, C9_PEDIDO " + CRLF
			cQuery4 += "ORDER BY C9_NFISCAL,C9_DATALIB, C9_PEDIDO " + CRLF

			TCQuery cQuery4 New Alias "TRBH"

			TRBH->(DbGoTop())

			If TRBH->(!Eof())
					
				cQry1 := "UPDATE "+RetSqlName("SC9")+" " + CRLF
				cQry1 += " SET C9_XNUMIND = '1' " + CRLF
				cQry1 += "FROM "+RetSqlName("SC9")+" AS SC9 " + CRLF
				cQry1 += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' " + CRLF
				cQry1 += " AND C9_NFISCAL = '"+TRBH->NFISCAL+ "' " + CRLF
				cQry1 += " AND C9_SERIENF = '"+TRBH->SERIENF+ "' " + CRLF
				cQry1 += " AND C9_CLIENTE = '"+TRBH->CLIENTE+"' " + CRLF
				cQry1 += " AND C9_LOJA    = '"+TRBH->LOJA+"' " + CRLF
				cQry1 += " AND C9_XNUMIND = ' ' " + CRLF
				cQry1 += " AND SC9.D_E_L_E_T_ = ' ' " + CRLF

				TcSQLExec(cQry1)
			
			EndIf

		ElseIf TRB8->PEDIDO == TRB9->PEDIDO .And. TRB8->CLIENTE == TRB9->CLIENTE;
		   .And. TRB8->LOJA == TRB9->LOJA .And. TRB8->DATALIB <> TRB9->DATALIB;
		   .And. TRB8->NFISCAL == TRB9->NFISCAL  
				
			If Select("TRBG") > 0
				TRBG->(DbCloseArea())
			EndIf

			cQuery3 := "SELECT C9_XNUMIND AS INDICADOR, " + CRLF
			cQuery3 += " C9_NFISCAL AS NFISCAL, " + CRLF
			cQuery3 += " C9_SERIENF AS SERIENF, " + CRLF
			cQuery3 += " C9_CLIENTE AS CLIENTE, " + CRLF
			cQuery3 += " C9_LOJA AS LOJA " + CRLF
			cQuery3 += "FROM "+RetSqlName("SC9")+" AS SC9 " + CRLF
			cQuery3 += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' " + CRLF
			cQuery3 += " AND C9_NFISCAL = '"+TRB9->NFISCAL+"' " + CRLF
			cQuery3 += " AND C9_SERIENF = '"+TRB9->SERIENF+"' " + CRLF
			cQuery3 += " AND C9_CLIENTE = '"+TRB9->CLIENTE+"' " + CRLF
			cQuery3 += " AND C9_LOJA    = '"+TRB9->LOJA+"' " + CRLF
			cQuery3 += " AND C9_NFISCAL <> ' ' " + CRLF
			cQuery3 += " AND SC9.D_E_L_E_T_ = ' ' " + CRLF 
			cQuery3 += " AND C9_XNUMIND = ' ' " + CRLF
			cQuery3 += "GROUP BY C9_XNUMIND, C9_NFISCAL, C9_SERIENF, C9_CLIENTE, C9_LOJA, C9_DATALIB, C9_PEDIDO " + CRLF
			cQuery3 += "ORDER BY C9_NFISCAL,C9_DATALIB, C9_PEDIDO " + CRLF

			TCQuery cQuery3 New Alias "TRBG"

			TRBG->(DbGoTop())

			If TRBG->(!Eof())
					
				cQry := "UPDATE "+RetSqlName("SC9")+" " + CRLF
				cQry += " SET C9_XNUMIND = '2' " + CRLF
				cQry += "FROM "+RetSqlName("SC9")+" AS SC9 " + CRLF
				cQry += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' " + CRLF
				cQry += " AND C9_NFISCAL = '"+TRBG->NFISCAL+ "' " + CRLF
				cQry += " AND C9_SERIENF = '"+TRBG->SERIENF+ "' " + CRLF
				cQry += " AND C9_CLIENTE = '"+TRBG->CLIENTE+"' " + CRLF
				cQry += " AND C9_LOJA    = '"+TRBG->LOJA+"' " + CRLF
				cQry += " AND C9_XNUMIND = ' ' " + CRLF
				cQry += " AND SC9.D_E_L_E_T_ = ' ' " + CRLF

				TcSQLExec(cQry)
			
			EndIf


		ElseIf TRB8->PEDIDO == TRB9->PEDIDO .And. TRB8->CLIENTE == TRB9->CLIENTE;
		   .And. TRB8->LOJA == TRB9->LOJA .And. TRB8->DATALIB <> TRB9->DATALIB;
		   .And. TRB8->NFISCAL <> TRB9->NFISCAL  
				
			If Select("TRBG") > 0
				TRBG->(DbCloseArea())
			EndIf

			cQuery3 := "SELECT C9_XNUMIND AS INDICADOR, " + CRLF
			cQuery3 += " C9_NFISCAL AS NFISCAL, " + CRLF
			cQuery3 += " C9_SERIENF AS SERIENF, " + CRLF
			cQuery3 += " C9_CLIENTE AS CLIENTE, " + CRLF
			cQuery3 += " C9_LOJA AS LOJA " + CRLF
			cQuery3 += "FROM "+RetSqlName("SC9")+" AS SC9 " + CRLF
			cQuery3 += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' " + CRLF
			cQuery3 += " AND C9_NFISCAL = '"+TRB9->NFISCAL+"' " + CRLF
			cQuery3 += " AND C9_SERIENF = '"+TRB9->SERIENF+"' " + CRLF
			cQuery3 += " AND C9_CLIENTE = '"+TRB9->CLIENTE+"' " + CRLF
			cQuery3 += " AND C9_LOJA    = '"+TRB9->LOJA+"' " + CRLF
			cQuery3 += " AND C9_NFISCAL <> ' ' " + CRLF
			cQuery3 += " AND SC9.D_E_L_E_T_ = ' ' " + CRLF 
			cQuery3 += " AND C9_XNUMIND = ' ' " + CRLF
			cQuery3 += "GROUP BY C9_XNUMIND, C9_NFISCAL, C9_SERIENF, C9_CLIENTE, C9_LOJA, C9_DATALIB, C9_PEDIDO " + CRLF
			cQuery3 += "ORDER BY C9_NFISCAL,C9_DATALIB, C9_PEDIDO " + CRLF

			TCQuery cQuery3 New Alias "TRBG"

			TRBG->(DbGoTop())

			If TRBG->(!Eof())
					
				cQry := "UPDATE "+RetSqlName("SC9")+" " + CRLF
				cQry += " SET C9_XNUMIND = '2' " + CRLF
				cQry += "FROM "+RetSqlName("SC9")+" AS SC9 " + CRLF
				cQry += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' " + CRLF
				cQry += " AND C9_NFISCAL = '"+TRBG->NFISCAL+ "' " + CRLF
				cQry += " AND C9_SERIENF = '"+TRBG->SERIENF+ "' " + CRLF
				cQry += " AND C9_CLIENTE = '"+TRBG->CLIENTE+"' " + CRLF
				cQry += " AND C9_LOJA    = '"+TRBG->LOJA+"' " + CRLF
				cQry += " AND C9_XNUMIND = ' ' " + CRLF
				cQry += " AND SC9.D_E_L_E_T_ = ' ' " + CRLF

				TcSQLExec(cQry)
			
			EndIf

		ElseIf TRB8->PEDIDO == TRB9->PEDIDO .And. TRB8->CLIENTE == TRB9->CLIENTE;
		    .And. TRB8->LOJA == TRB9->LOJA .And. TRB8->NFISCAL <> TRB9->NFISCAL;
			.And. TRB8->SERIENF == TRB9->SERIENF .And. TRB8->DATALIB == TRB9->DATALIB   

			If Select("TRBH") > 0
				TRBH->(DbCloseArea())
			EndIf

			cQuery4 := "SELECT C9_XNUMIND AS INDICADOR, " + CRLF
			cQuery4 += " C9_NFISCAL AS NFISCAL, " + CRLF
			cQuery4 += " C9_SERIENF AS SERIENF, " + CRLF
			cQuery4 += " C9_CLIENTE AS CLIENTE, " + CRLF
			cQuery4 += " C9_LOJA AS LOJA " + CRLF
			cQuery4 += "FROM "+RetSqlName("SC9")+" AS SC9 " + CRLF
			cQuery4 += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' " + CRLF
			cQuery4 += " AND C9_NFISCAL = '"+TRB9->NFISCAL+"' " + CRLF
			cQuery4 += " AND C9_SERIENF = '"+TRB9->SERIENF+"' " + CRLF
			cQuery4 += " AND C9_CLIENTE = '"+TRB9->CLIENTE+"' " + CRLF
			cQuery4 += " AND C9_LOJA    = '"+TRB9->LOJA+"' " + CRLF
			cQuery4 += " AND C9_NFISCAL <> ' ' " + CRLF
			cQuery4 += " AND SC9.D_E_L_E_T_ = ' ' " + CRLF 
			cQuery4 += " AND C9_XNUMIND = ' ' " + CRLF
			cQuery4 += "GROUP BY C9_XNUMIND, C9_NFISCAL, C9_SERIENF, C9_CLIENTE, C9_LOJA, C9_DATALIB, C9_PEDIDO " + CRLF
			cQuery4 += "ORDER BY C9_NFISCAL,C9_DATALIB, C9_PEDIDO " + CRLF

			TCQuery cQuery4 New Alias "TRBH"

			TRBH->(DbGoTop())

			If TRBH->(!Eof())
					
				cQry1 := "UPDATE "+RetSqlName("SC9")+" " + CRLF
				cQry1 += " SET C9_XNUMIND = '2' " + CRLF
				cQry1 += "FROM "+RetSqlName("SC9")+" AS SC9 " + CRLF
				cQry1 += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' " + CRLF
				cQry1 += " AND C9_NFISCAL = '"+TRBH->NFISCAL+ "' " + CRLF
				cQry1 += " AND C9_SERIENF = '"+TRBH->SERIENF+ "' " + CRLF
				cQry1 += " AND C9_CLIENTE = '"+TRBH->CLIENTE+"' " + CRLF
				cQry1 += " AND C9_LOJA    = '"+TRBH->LOJA+"' " + CRLF
				cQry1 += " AND C9_XNUMIND = ' ' " + CRLF
				cQry1 += " AND SC9.D_E_L_E_T_ = ' ' " + CRLF

				TcSQLExec(cQry1)
			
			EndIf

		EndIf

		TRB9->(DbSkip())
		
	EndDo

	TRB8->(DbSkip())

	IncProc("Gerando arquivo...")	

EndDo

// Atualiza alguns pedidos que a regra não conseguiu preencher 

cQry := ""

cQry := "UPDATE "+RetSqlName("SC9")+" " + CRLF
cQry += " SET C9_XNUMIND = '2' " + CRLF
cQry += "FROM "+RetSqlName("SC9")+" AS SC9 " + CRLF
cQry += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' " + CRLF
cQry += " AND C9_NFISCAL IN ('000089346','000093679') " + CRLF
cQry += " AND SC9.D_E_L_E_T_ = ' ' " + CRLF

TcSQLExec(cQry)

// Atualiza as Notas fiscais para poder extrair o relatorio 

cQry := ""

cQry := "UPDATE "+RetSqlName("SD2")+" " + CRLF
cQry += " SET D2_XNUMIND = C9_XNUMIND " + CRLF
cQry += "FROM "+RetSqlName("SD2")+" AS SD2 " + CRLF
cQry += "INNER JOIN "+RetSqlName("SC9")+" AS SC9 ON D2_FILIAL = C9_FILIAL " + CRLF
cQry += " AND D2_COD = C9_PRODUTO " + CRLF
cQry += " AND D2_LOTECTL = C9_LOTECTL " + CRLF
cQry += " AND D2_LOCAL = C9_LOCAL " + CRLF
cQry += " AND D2_CLIENTE = C9_CLIENTE " + CRLF
cQry += " AND D2_LOJA = C9_LOJA " + CRLF
cQry += " AND D2_DOC = C9_NFISCAL " + CRLF
cQry += " AND D2_SERIE = C9_SERIENF " + CRLF
cQry += " AND D2_PEDIDO = C9_PEDIDO " + CRLF
cQry += " AND SC9.D_E_L_E_T_ = ' ' " + CRLF
cQry += "INNER JOIN "+RetSqlName("SF4")+" AS SF4 ON F4_FILIAL = SUBSTRING(D2_FILIAL,1,2) " + CRLF
cQry += " AND F4_CODIGO = D2_TES " + CRLF
cQry += " AND SF4.D_E_L_E_T_ = ' ' " + CRLF
cQry += "WHERE D2_FILIAL = '"+xFilial("SD2")+"' " + CRLF
cQry += " AND D2_CLIENTE  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + CRLF
cQry += " AND D2_LOJA BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' " + CRLF
cQry += " AND D2_DOC BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + CRLF
cQry += " AND D2_SERIE BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' " + CRLF
cQry += " AND D2_EMISSAO BETWEEN '"+Dtos(MV_PAR11)+"' AND '"+Dtos(MV_PAR12)+"' " + CRLF
cQry += " AND D2_PEDIDO  BETWEEN '"+MV_PAR13+"' AND '"+MV_PAR14+"' " + CRLF
cQry += " AND F4_DUPLIC  = 'S' " + CRLF
cQry += " AND SD2.D_E_L_E_T_ = ' ' " + CRLF

TcSQLExec(cQry)

If Select("TRB8") > 0
	TRB8->(DbCloseArea())
EndIf
If Select("TRB9") > 0
	TRB9->(DbCloseArea())
EndIf
If Select("TRBG") > 0
	TRBG->(DbCloseArea())
EndIf
If Select("TRBH") > 0
	TRBH->(DbCloseArea())
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

Aadd(_aPerg,{"Representante De  ..?","mv_ch1","C",06,"G","mv_par01","","","","","","SA3","","",0})
Aadd(_aPerg,{"Representante Até ..?","mv_ch2","C",06,"G","mv_par02","","","","","","SA3","","",0})

Aadd(_aPerg,{"Cliente De  ........?","mv_ch3","C",06,"G","mv_par03","","","","","","SA1","","",0})
Aadd(_aPerg,{"Cliente Até ........?","mv_ch4","C",06,"G","mv_par04","","","","","","SA1","","",0})

Aadd(_aPerg,{"Loja De ............?","mv_ch5","C",02,"G","mv_par05","","","","","","SA1","","",0})
Aadd(_aPerg,{"Loja Até ...........?","mv_ch6","C",02,"G","mv_par06","","","","","","SA1","","",0})

Aadd(_aPerg,{"Nota Fiscal De .....?","mv_ch7","C",09,"G","mv_par07","","","","","","","","",0})
Aadd(_aPerg,{"Nota Fiscal Até ....?","mv_ch8","C",09,"G","mv_par08","","","","","","","","",0})

Aadd(_aPerg,{"Serie Nf De ........?","mv_ch9","C",03,"G","mv_par09","","","","","","","","",0})
Aadd(_aPerg,{"Serie Nf Até .......?","mv_cha","C",03,"G","mv_par10","","","","","","","","",0})

Aadd(_aPerg,{"Data Nota Fiscal De ?","mv_chb","D",08,"G","mv_par11","","","","","","","","",0})
Aadd(_aPerg,{"Data Nota Fiscal Até?","mv_chc","D",08,"G","mv_par12","","","","","","","","",0})

Aadd(_aPerg,{"Pedido Vendas De ...?","mv_chd","C",06,"G","mv_par13","","","","","","","","",0})
Aadd(_aPerg,{"Pedido Vendas Até ..?","mv_che","C",06,"G","mv_par14","","","","","","","","",0})

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
