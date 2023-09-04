#include 'protheus.ch'
#include 'parmtype.ch'
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"
#include "Colors.ch"
#include "RwMake.ch"
#Include "TOPCONN.CH" 
#Include "FWMVCDEF.CH"

#define ENTER chr(13) + chr(10)
#define CRLF  chr(13) + chr(10)

/*/{Protheus.doc} QEFAT006
@TYPE Rotina para extrair relatorio para quebra do peso  
@author Fabio Carneiro dos Santos 
@since 05/05/2021
@version 1.0
@History alterado para compor o codigo da carga e numero nota fiscal no mv_par17 - 19/01/2022 - Fabio carneiro 
@History Estava carregando as cargas de forma incorreta - 20/01/2022 - Fabio carneiro 

/*/
User Function QEFAT006()

	Local aSays    := {}
	Local aButtons := {}
	Local nOpca    := 0
	Local cTitoDlg := "Listagem de pedidos atendidos por valor e peso"
	Private _cPerg := "QEFATR6"

	// Prepara e executa a pergunta do relatorio

	aAdd(aSays, "Este relatorio lista os Pedidos de vendas Liberados com percentual atendido!")
	aAdd(aSays, "Não lista a ordem de carregamento e nem o codigo da carga .")
	
	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	
	If nOpca == 1
	
		oAjustaSx1()

		If !Pergunte(_cPerg,.T.)
			Return
		Else 
			Processa({|| QEFAT06ok("Gerando relatório...")})
		Endif
		
	EndIf
	Return

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEFAT06ok | Autor: | QUALY         | Data: | 04/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEFAT06ok                                    |
+------------+-----------------------------------------------------------+
*/

Static Function QEFAT06ok()

	Local cArqDst     := "C:\TOTVS\QEFAT006_EMP_" + SM0->M0_CODIGO + "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel      := FWMsExcelEX():New()
	Local cQuery      := ""
	Local cQueryG     := ""
	Local cQueryP     := ""
	Local cQueryQ     := ""
	Local cQueryR     := ""

	Local cNomPla     := "Empresa_1" + Rtrim(SM0->M0_NOME)

	Local dDataA      := "" 

	Local dDataEmis   := "" 
	Local _cPedido    := ""
	Local _cOrdSep    := "" 
	Local _dDataOs    
	Local _dDtEmiss   := "" 
	Local _cCodCli    := ""
	Local _cNome      := "" 
	Local _cUF        := ""
	Local _nPesbru    := 0
	Local _nValTotal  := 0
	Local _nQPesbru   := 0
	Local _nQValTotal := 0
	Local _nQQtdTotal := 0
	Local _nRPesbru   := 0
	Local _nRValTotal := 0
	Local _nRQtdTotal := 0
	Local _nCalc1     := 0 
	Local _nCalc2     := 0
	Local _nCalc3     := 0
	Local _nCalc4     := 0

	Local _cCodCarga  := "" 
	Local _cPedCarga  := "" 
	Local _cHoraCarga := "" 
	Local _dDataCarga := ""  
	Local _dDtCarga 
	Local _cNFiscal   := ""
	Local _cSerieNf   := ""
	
	Local cTitPla     := " "
	
	Local cNomWrk     := "Empresa_1" + Rtrim(SM0->M0_NOME)

	Local lAbre      := .F.
	
	Private TRB1     := GetNextAlias()
	Private TRBP     := GetNextAlias()
	Private TRBQ     := GetNextAlias()
	Private TRBR     := GetNextAlias()
	Private TRBG     := GetNextAlias()
	
	dDataA           := Substr(DTOS(dDataBase),7,2)+"/"+Substr(DTOS(dDataBase),5,2)+"/"+Substr(DTOS(dDataBase),1,4)

	cTitPla          := "Listagem de Percentual atendido dos pedidos liberados - Data de Emissao em "+dDataA+"  "

	MakeDir("C:\TOTVS")

	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf
		
    cQuery := "SELECT C9_FILIAL,A1_EST,C9_PEDIDO,C9_CLIENTE,C9_LOJA,C9_QTDLIB, C9_ORDSEP, A1_COD, A1_LOJA, A1_NOME, A1_EST, C5_VEND1, "+CRLF
    cQuery += "C6_XPESLIQ, C6_XPESBUT, C6_QTDVEN, C9_PRCVEN ,C6_QTDEMP, C9_ITEM, B1_TIPO,C9_PRCVEN,(C9_QTDLIB * C9_PRCVEN) C9_TOTAL,C5_EMISSAO,C6_ENTREG,E4_DESCRI,F4_TEXTO,C5_TIPO, "+CRLF
    cQuery += "B1_PESBRU, C5_EMISSAO, C5_NUM, C9_DATALIB, C9_NFISCAL, C9_SERIENF "+CRLF
	cQuery += "FROM " + RetSqlName("SC9") + " SC9 "+CRLF
	cQuery += "INNER JOIN " + RetSqlName("SC6") + " SC6 ON C6_FILIAL = C9_FILIAL AND C6_NUM = C9_PEDIDO AND C6_ITEM = C9_ITEM AND SC6.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'AND F4_CODIGO = C6_TES AND SF4.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = C9_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "INNER JOIN " + RetSqlName("SC5") + " SC5 ON C5_FILIAL = C9_FILIAL AND C5_NUM = C9_PEDIDO "+CRLF
	cQuery += "INNER JOIN " + RetSqlName("SE4") + " SE4 ON E4_FILIAL = '"+xFilial("SE4")+"' AND E4_CODIGO = C5_CONDPAG AND SE4.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "INNER JOIN " + RetSqlName("SA1") + " SA1 ON A1_FILIAL = C9_FILIAL AND A1_COD = C9_CLIENTE AND A1_LOJA = C9_LOJA AND SA1.D_E_L_E_T_ = ''"+CRLF
	cQuery += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' "+CRLF
	If mv_par17 == 1
		cQuery += "AND C9_BLEST IN (' ', '10') "+CRLF
		cQuery += "AND C9_BLCRED = ' ' "+CRLF
	ElseIf mv_par17 == 2
		cQuery += "AND C9_BLEST  IN (' ', '10') "+CRLF
		cQuery += "AND C9_BLCRED IN (' ', '10') "+CRLF
	EndIf
	cQuery += "AND C6_ENTREG  BETWEEN '" + Dtos(MV_PAR01) + "'  AND '" + Dtos(MV_PAR02) + "'   "+CRLF
	cQuery += "AND C9_DATALIB BETWEEN '" + Dtos(MV_PAR03) + "'  AND '" + Dtos(MV_PAR04) + "'   "+CRLF
	cQuery += "AND C5_VEND1 BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "+CRLF
	cQuery += "AND C5_CLIENTE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "+CRLF
	cQuery += "AND C5_LOJACLI BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "+CRLF
	cQuery += "AND C5_NUM BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "+CRLF
	cQuery += "AND A1_EST BETWEEN '" + MV_PAR13 + "' AND '" + MV_PAR14 + "'"+CRLF
	cQuery += "AND A1_EST NOT IN ('" + MV_PAR15 + "') "+CRLF
	If mv_par16 == 2
		cQuery += "AND F4_ESTOQUE = 'S' "+CRLF
	EndIf
	cQuery += "AND SC5.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "AND SC9.D_E_L_E_T_ = ' ' "+CRLF
    cQuery += "ORDER BY C9_FILIAL, C9_ORDSEP, C9_PEDIDO"+CRLF
    	
	TcQuery cQuery ALIAS "TRB1" NEW
	
	oExcel:AddworkSheet(cNomWrk)
	oExcel:AddTable(cNomPla, cTitPla)
	oExcel:AddColumn(cNomPla, cTitPla, "Filial "           , 1, 1, .F.)  //01
	oExcel:AddColumn(cNomPla, cTitPla, "Num. PV"           , 1, 1, .F.)  //02
	oExcel:AddColumn(cNomPla, cTitPla, "Dt. Lib. Pv"       , 1, 1, .F.)  //03
	oExcel:AddColumn(cNomPla, cTitPla, "Num. O.S"          , 1, 1, .F.)  //04
	oExcel:AddColumn(cNomPla, cTitPla, "Dt. O.S"           , 1, 1, .F.)  //05
	
	oExcel:AddColumn(cNomPla, cTitPla, "Num. Carga"        , 1, 1, .F.)  //06
	oExcel:AddColumn(cNomPla, cTitPla, "Dt. Carga"         , 1, 1, .F.)  //07
	oExcel:AddColumn(cNomPla, cTitPla, "Hr. Carga"         , 1, 1, .F.)  //08

	oExcel:AddColumn(cNomPla, cTitPla, "Num. Nf"           , 1, 1, .F.)  //09
	oExcel:AddColumn(cNomPla, cTitPla, "Serie Nf"          , 1, 1, .F.)  //10

	oExcel:AddColumn(cNomPla, cTitPla, "Cod. Cliente"      , 1, 1, .F.)  //11
	oExcel:AddColumn(cNomPla, cTitPla, "Nome Cliente"      , 1, 1, .F.)  //12
	oExcel:AddColumn(cNomPla, cTitPla, "Estado"            , 1, 1, .F.)  //13

	oExcel:AddColumn(cNomPla, cTitPla, "Qtd. PV"           , 3, 2, .F.)  //14
	oExcel:AddColumn(cNomPla, cTitPla, "Qtd. LIb."         , 3, 2, .F.)  //15
	oExcel:AddColumn(cNomPla, cTitPla, "Vl. Total PV"      , 3, 2, .F.)  //16
	oExcel:AddColumn(cNomPla, cTitPla, "Peso Bruto PV"     , 3, 2, .F.)  //17
	oExcel:AddColumn(cNomPla, cTitPla, "Peso Atend."       , 3, 2, .F.)  //18
	oExcel:AddColumn(cNomPla, cTitPla, "Vl. Atend."        , 3, 2, .F.)  //19
	oExcel:AddColumn(cNomPla, cTitPla, "% Atend. VL"       , 3, 2, .F.)  //20
	oExcel:AddColumn(cNomPla, cTitPla, "% Atend. Peso"     , 3, 2, .F.)  //21

	TRB1->(DbGoTop())

	ProcRegua(TRB1->(LastRec()))
	
	While TRB1->(!Eof())
		
		lAbre := .T.
	
		_cCodCarga  := ""
		_dDataCarga := ""
		_cHoraCarga := "" 
		_cNFiscal   := ""
		_cSerieNf   := ""

		_cFILIAL    := TRB1->C9_FILIAL
		_cPedido    := TRB1->C5_NUM
		dDataEmis   := Substr(TRB1->C9_DATALIB,7,2)+"/"+Substr(TRB1->C9_DATALIB,5,2)+"/"+Substr(TRB1->C9_DATALIB,1,4)
		_cOrdSep    := TRB1->C9_ORDSEP
		_dDataOs    := Posicione("CB7",1,xFilial("CB7")+TRB1->C9_ORDSEP,"CB7_DTEMIS")
		_dDtEmiss   := Substr(DtoS(_dDataOs),7,2)+"/"+Substr(DtoS(_dDataOs),5,2)+"/"+Substr(DtoS(_dDataOs),1,4)
		_cCodCli    := TRB1->A1_COD
		_cNome      := TRB1->A1_NOME
		_cUF        := TRB1->A1_EST
		_cNFiscal   := TRB1->C9_NFISCAL
		_cSerieNf   := TRB1->C9_SERIENF

		If Select("TRBG") > 0
			TRBG->(DbCloseArea())
		EndIf

		cQueryG := "SELECT DAK_COD AS CARGA, DAI_PEDIDO AS PEDCARGA, DAI_DATA AS DTCARGA, DAI_HORA AS HRCARGA  " +CRLF
		cQueryG += " FROM "+RetSqlName("DAK")+" AS DAK WITH (NOLOCK) " +CRLF
		cQueryG += "INNER JOIN "+RetSqlName("DAI")+" AS DAI WITH (NOLOCK) ON DAK_FILIAL = DAI_FILIAL "+CRLF
		cQueryG += " AND DAK_COD = DAI_COD  "+CRLF
		cQueryG += " AND DAI.D_E_L_E_T_ = ' '  "+CRLF
		cQueryG += " WHERE DAK_FILIAL   = '"+xFilial("DAK")+"' "+CRLF
		cQueryG += " AND DAI_PEDIDO     =  '"+_cPedido+"'  "+CRLF
		cQueryG += " AND DAK.D_E_L_E_T_ = ' '  "+CRLF
		cQueryG += " ORDER BY DAI_COD, DAI_SEQUEN  "+CRLF

		TcQuery cQueryG ALIAS "TRBG" NEW

		TRBG->(DbGoTop())
			
		While TRBG->(!Eof())

			_cCodCarga    := TRBG->CARGA     // Codigo da Carga
			_cPedCarga    := TRBG->PEDCARGA  // Numero do Pedido de Vendas
			_dDtCarga     := TRBG->DTCARGA   // Data da Carga 
			_dDataCarga   := StoD(TRBG->DTCARGA)   
			_cHoraCarga   := TRBG->HRCARGA   // Hora da geração da carga
				
			TRBG->(DbSkip())
			
		EndDo

		TRB1->(DbSkip())
				
		If TRB1->(EOF()) .Or. If(Empty(_cOrdSep), TRB1->C5_NUM <> _cPedido, TRB1->C9_ORDSEP <> _cOrdSep)    

			If Select("TRBP") > 0
				TRBP->(DbCloseArea())
			EndIf

			cQueryP := "SELECT SUM(C6_XPESBUT) AS PESOBRU, SUM(C6_QTDVEN * C6_PRCVEN) AS VLTOTAL,  " +CRLF
			cQueryP += " SUM(C6_QTDVEN) AS QTTOTAL  " +CRLF
			cQueryP += " FROM "+RetSqlName("SC6")+" AS SC6  " +CRLF
			cQueryP += "WHERE C6_FILIAL = '"+xFilial("SC6")+"' "+CRLF
			cQueryP += " AND C6_NUM  = '"+_cPedido+"'   "+CRLF
			cQueryP += " AND SC6.D_E_L_E_T_ = ' '  "

			TcQuery cQueryP ALIAS "TRBP" NEW

			TRBP->(DbGoTop())
			
			While TRBP->(!Eof())

				_nPesbru   := TRBP->PESOBRU // Peso do pedido 
				_nValTotal := TRBP->VLTOTAL // Valor do pedido 
				_nQtdTotal := TRBP->QTTOTAL // Quantidade do Pedido

				TRBP->(DbSkip())

			EndDo

			If Select("TRBQ") > 0
				TRBQ->(DbCloseArea())
			EndIf

			cQueryQ := "SELECT SUM(C9_QTDLIB * B1_PESBRU) AS PESOBRU, SUM(C9_QTDLIB * C9_PRCVEN) AS VLTOTAL,  " +CRLF
			cQueryQ += " SUM(C9_QTDLIB) AS QTTOTAL  " +CRLF
			cQueryQ += " FROM "+RetSqlName("SC6")+" AS SC6  " +CRLF
			cQueryQ += "INNER JOIN "+RetSqlName("SC9")+" AS SC9 ON C6_FILIAL = C9_FILIAL "+CRLF
			cQueryQ += " AND C6_NUM     = C9_PEDIDO  "+CRLF
			cQueryQ += " AND C6_PRODUTO = C9_PRODUTO    "+CRLF
			cQueryQ += " AND C6_LOCAL   = C9_LOCAL   "+CRLF
			cQueryQ += " AND SC9.D_E_L_E_T_ = ' '  "+CRLF
			cQueryQ += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 ON C9_PRODUTO = B1_COD "+CRLF
			cQueryQ += " AND SB1.D_E_L_E_T_ = ' ' "+CRLF
			cQueryQ += "WHERE C6_FILIAL = '"+xFilial("SC6")+"' "+CRLF
			cQueryQ += " AND C9_BLEST IN (' ', '10') "+CRLF
			cQueryQ += " AND C9_BLCRED = ' ' "+CRLF
			cQueryQ += " AND C6_NUM  = '"+_cPedido+"'   "+CRLF
			cQueryQ += " AND SC6.D_E_L_E_T_ = ' '  "

			TcQuery cQueryQ ALIAS "TRBQ" NEW

			TRBQ->(DbGoTop())
			
			While TRBQ->(!Eof())

				_nQPesbru   := TRBQ->PESOBRU // peso bruto liberado  
				_nQValTotal := TRBQ->VLTOTAL // valor total do pedido liberado 
				_nQQtdTotal := TRBQ->QTTOTAL // quantidade digitada no pedido  liberada

				TRBQ->(DbSkip())

			EndDo

			If Select("TRBR") > 0
				TRBR->(DbCloseArea())
			EndIf

			cQueryR := "SELECT SUM(CB8_QTDORI * B1_PESBRU) AS PESOBRU, SUM(CB8_QTDORI * C6_PRCVEN) AS VLTOTAL,   " +CRLF
			cQueryR += " SUM(CB8_QTDORI) AS QTTOTAL  " +CRLF
			cQueryR += " FROM "+RetSqlName("SC6")+" AS SC6  " +CRLF
			cQueryR += "INNER JOIN "+RetSqlName("CB8")+" AS CB8 ON C6_FILIAL = CB8_FILIAL "+CRLF
			cQueryR += " AND C6_NUM     = CB8_PEDIDO  "+CRLF
			cQueryR += " AND C6_PRODUTO = CB8_PROD    "+CRLF
			cQueryR += " AND C6_LOCAL   = CB8_LOCAL   "+CRLF
			cQueryR += " AND CB8.D_E_L_E_T_ = ' '  "+CRLF
			cQueryR += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 ON C6_PRODUTO = B1_COD "+CRLF
			cQueryR += " AND SB1.D_E_L_E_T_ = ' ' "+CRLF		
			cQueryR += "WHERE CB8_FILIAL = '"+xFilial("CB8")+"' "+CRLF
			cQueryR += " AND CB8_PEDIDO  = '"+_cPedido+"'     "+CRLF
			cQueryR += " AND CB8_ORDSEP  = '"+_cOrdSep+"' "+CRLF
			cQueryR += " AND SC6.D_E_L_E_T_ = ' '  "

			TcQuery cQueryR ALIAS "TRBR" NEW

			TRBR->(DbGoTop())
			
			While TRBR->(!Eof())

				_nRPesbru   := TRBR->PESOBRU // peso bruto liberado com ordem de separação  
				_nRValTotal := TRBR->VLTOTAL // valor total do pedido liberado  ordem de separação
				_nRQtdTotal := TRBR->QTTOTAL // quantidade digitada no pedido  liberada ordem de separação

				TRBR->(DbSkip())
			EndDo
			 
			_nCalc1 := If(Empty(_cOrdSep),_nQQtdTotal,_nRQtdTotal)  
			_nCalc2 := If(Empty(_cOrdSep),_nQPesbru,_nRPesbru)  
			_nCalc3 := If(Empty(_cOrdSep),_nQValTotal,_nRValTotal)
			_nCalc4 := If(Empty(_cOrdSep),_nQPesbru,_nRPesbru)
			_nCalc5 := (_nCalc3/_nValTotal)*100
			_ncalc6 := (_nCalc4/_nPesbru)*100

			oExcel:AddRow(cNomPla, cTitPla,{_cFILIAL,;  
											_cPedido,;  
											dDataEmis,; 
											_cOrdSep,;  
											If(Empty(_dDataOs),"",_dDtEmiss),; 
											_cCodCarga,;
											_dDataCarga,;
											_cHoraCarga,; 
											_cNFiscal,;
											_cSerieNf,;
											_cCodCli,;  
											_cNome,;
											_cUF,;    
											_nQtdTotal,;  
											_nCalc1,;  
											_nValTotal,;  
											_nPesbru,; 
											_nCalc2,;  
											_nCalc3,;
											_nCalc5,;
											_nCalc6})

			_cCodCarga  := ""
			_dDataCarga := ""
			_cHoraCarga := "" 
			_cNFiscal   := ""
			_cSerieNf   := ""
			_nQtdTotal  := 0  
			_nQQtdTotal := 0  
			_nValTotal  := 0  
			_nPesbru    := 0 
			_nQPesbru   := 0
			_nQValTotal := 0
			_nRPesbru   := 0 
			_nRValTotal := 0
			_nRQtdTotal := 0
			_nCalc1     := 0
			_nCalc2     := 0
			_nCalc3     := 0   
			_nCalc4     := 0 

		Endif

		IncProc("Gerando arquivo...")
	
	EndDo

	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
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

	If Select("TRBG") > 0
		TRBG->(DbCloseArea())
	EndIf

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

Aadd(_aPerg,{"Data Entrega De....?"   ,"mv_ch1","D",08,"G","mv_par01","","","","","","","","",0})
Aadd(_aPerg,{"Data Entrega Até...?"   ,"mv_ch2","D",08,"G","mv_par02","","","","","","","","",0})

Aadd(_aPerg,{"Data Liberação De....?"   ,"mv_ch3","D",08,"G","mv_par03","","","","","","","","",0})
Aadd(_aPerg,{"Data Liberação Até...?"   ,"mv_ch4","D",08,"G","mv_par04","","","","","","","","",0})

Aadd(_aPerg,{"Cod. Vendedor De...?"   ,"mv_ch5","C",06,"G","mv_par05","","","","","","SA3","","",0})
Aadd(_aPerg,{"Cod. Vendedor Até .?"   ,"mv_ch6","C",06,"G","mv_par06","","","","","","SA3","","",0})

Aadd(_aPerg,{"Cod.Cliente De...?"     ,"mv_ch7","C",06,"G","mv_par07","","","","","","SA1" ,"","",0})
Aadd(_aPerg,{"Cod.Cliente Até..?"     ,"mv_ch8","C",06,"G","mv_par08","","","","","","SA1" ,"","",0})

Aadd(_aPerg,{"Loja Cliente De..?"     ,"mv_ch9","C",02,"G","mv_par09","","","","","","SA1" ,"","",0})
Aadd(_aPerg,{"Loja Cliente Até.?"     ,"mv_chA","C",02,"G","mv_par10","","","","","","SA1" ,"","",0})

Aadd(_aPerg,{"Pedido Venda De..?"     ,"mv_chB","C",06,"G","mv_par11","","","","","","SC5" ,"","",0})
Aadd(_aPerg,{"Pedido Venda Até.?"     ,"mv_chC","C",06,"G","mv_par12","","","","","","SC5" ,"","",0})

Aadd(_aPerg,{"Estado De........?"     ,"mv_chD","C",02,"G","mv_par13","","","","","","" ,"","",0})
Aadd(_aPerg,{"Estado Até.......?"     ,"mv_chE","C",02,"G","mv_par14","","","","","","" ,"","",0})

Aadd(_aPerg,{"Não Listar a UF..?"     ,"mv_chF","C",02,"G","mv_par15","","","","","","" ,"","",0})

Aadd(_aPerg,{"TES Mov. Estoque.?"     ,"mv_chG","C",01,"C","mv_par16","Não","Sim","","","",""   ,"","",0})

Aadd(_aPerg,{"Lista C/ Nf´s ......?"  ,"mv_chH","C",01,"C","mv_par17","Não","Sim","","","",""   ,"","",0})


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
