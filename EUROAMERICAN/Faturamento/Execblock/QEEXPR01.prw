#include "parmtype.ch"
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"
#include "Colors.ch"
#include "RwMake.ch"

/*/{Protheus.doc} QEEXPR01
Indicadores de medição de Faturamento de Expedição 
@Autor Fabio Carneiro 
@since 22/08/2022
@version 1.0
@type user function 
/*/

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

User Function QEEXPR01()

Local aSays    := {}
Local aButtons := {}
Local cTitoDlg := "Induicadores de entrega expedição"
Local nOpca    := 0
Private _cPerg := "QEEXPR1"

aAdd(aSays, "Rotina para gerar indicadores de performance de expedição !!!")
aAdd(aSays, "Este relatório é apenas para medição de produtividade da expedição!")
aAdd(aSays, "Lista somente a primeira liberação conforme solicitado pela área")

aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})


FormBatch(cTitoDlg, aSays, aButtons)

If nOpca == 1
	
	oAjustaSx1()

	If !Pergunte(_cPerg,.T.)
		Return
	Else 
		MontaDir("C:\TOTVS\")
		Processa({|| QEEXPR01ok("Gerando planilha, aguarde...")})
	Endif
		
EndIf

Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEEXPR01ok| Autor: | QUALY         | Data: | 08/08/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QECOMR01ok                                   |
+------------+-----------------------------------------------------------+
*/

Static Function QEEXPR01ok()

Local cArqDst       := "C:\TOTVS\QEEXPR01_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
Local oExcel        := FWMsExcelEX():New()
Local cPlan         := "Empresa_" + Rtrim(SM0->M0_CODIGO) + "_Filial_" + Rtrim(SM0->M0_CODFIL)
Local cTit          := "INDICADORES DE SEPARAÇÃO POR PEDIDO DE VENDAS DE: " +Dtoc(MV_PAR11) + " ATE: " + Dtoc(MV_PAR12)
Local lAbre         := .F.
Local cQuery        := ""
Local cQueryA       := ""
Local cQuery8       := "" 
Local _cESTADO      := ""
Local _dDTNFISCAL   := ""
Local _dDTLIBERACAO := ""
Local _dDTPEDIDO    := ""
Local _dDATANF      := ""
Local _cFILIAL      := ""
Local _cCLIENTE     := ""
Local _cLOJA        := ""
Local _cNOME        := ""
Local _cPEDIDO      := ""
Local _cVENDEDOR    := ""
Local _cNOMEVEND1   := ""
Local _cNFISCAL     := ""
Local _cSERIENF     := ""
Local _nTP_QTDVEN   := 0
Local _nTP_TOTAL    := 0
Local _nNF_QTDVEN   := 0
Local _nNF_TOTAL    := 0
Local _nPQTDVEN     := 0
Local _nPTOTAL      := 0
Local _nGPQTDVEN    := 0
Local _nGPTOTAL     := 0
Local _nGNFQTDVEN   := 0
Local _nGNFTOTAL    := 0
Local _nPQTDVOL     := 0
Local _nTP_QTDVOL   := 0
Local _nGPQTDVOL    := 0
Local _nTQTDVOL     := 0
Local _nGNFQTDVOL   := 0
Local _nNF_QTDVOL   := 0
Local _nTQTDVEN     := 0
Local _nTTOTAL      := 0
Local _nGPVEN       := 0
Local _nGPTOT       := 0
Local _nGPVOL       := 0
/*
+------------------------------------------+
| DADOS NO CABEÇALHO DA PLANILHA           |
+------------------------------------------+
*/
If MV_PAR15 = 1

	oExcel:AddworkSheet(cPlan)
	oExcel:AddTable(cPlan, cTit)
	oExcel:AddColumn(cPlan, cTit, "Filial"              , 1, 1, .F.)  //01
	oExcel:AddColumn(cPlan, cTit, "Codigo Cliente"      , 1, 1, .F.)  //02
	oExcel:AddColumn(cPlan, cTit, "Loja Cliente"        , 1, 1, .F.)  //03
	oExcel:AddColumn(cPlan, cTit, "Nome Cliente"        , 1, 1, .F.)  //04
	oExcel:AddColumn(cPlan, cTit, "Pedido de Vendas"    , 1, 1, .F.)  //05
	oExcel:AddColumn(cPlan, cTit, "Cod. Vendedor"       , 1, 1, .F.)  //06
	oExcel:AddColumn(cPlan, cTit, "Nome Vend."          , 1, 1, .F.)  //07
	oExcel:AddColumn(cPlan, cTit, "Estado"              , 1, 1, .F.)  //08
	oExcel:AddColumn(cPlan, cTit, "Data do Pedido"      , 1, 1, .F.)  //09
	oExcel:AddColumn(cPlan, cTit, "Data da Liberação"   , 1, 1, .F.)  //10
	oExcel:AddColumn(cPlan, cTit, "Nota Fiscal"         , 1, 1, .F.)  //11
	oExcel:AddColumn(cPlan, cTit, "Serie Nf"            , 1, 1, .F.)  //12
	oExcel:AddColumn(cPlan, cTit, "Data Nf. "           , 1, 1, .F.)  //13
	oExcel:AddColumn(cPlan, cTit, "Quant. Nf"           , 3, 2, .F.)  //14
	oExcel:AddColumn(cPlan, cTit, "Valor Total Nf"      , 3, 2, .F.)  //15
	oExcel:AddColumn(cPlan, cTit, "Quant. Pedido"       , 3, 2, .F.)  //16
	oExcel:AddColumn(cPlan, cTit, "Valor Total Pedido"  , 3, 2, .F.)  //17
	oExcel:AddColumn(cPlan, cTit, "Quant. Vol. Nf"      , 3, 2, .F.)  //18
	oExcel:AddColumn(cPlan, cTit, "Quant. Vol. Pedido"  , 3, 2, .F.)  //19
	oExcel:AddColumn(cPlan, cTit, "% Atendido P/ Valor ", 3, 2, .F.)  //20
	oExcel:AddColumn(cPlan, cTit, "% Atendido P/ Quant.", 3, 2, .F.)  //21
	oExcel:AddColumn(cPlan, cTit, "% Atendido Volume"   , 3, 2, .F.)  //22

Else

	oExcel:AddworkSheet(cPlan)
	oExcel:AddTable(cPlan, cTit)
	oExcel:AddColumn(cPlan, cTit, "Filial"              , 1, 1, .F.)  //01
	oExcel:AddColumn(cPlan, cTit, "Data Nf. "           , 1, 1, .F.)  //02
	oExcel:AddColumn(cPlan, cTit, "Quant. Nf"           , 3, 2, .F.)  //03
	oExcel:AddColumn(cPlan, cTit, "Valor Total Nf"      , 3, 2, .F.)  //04
	oExcel:AddColumn(cPlan, cTit, "Quant. Pedido"       , 3, 2, .F.)  //05
	oExcel:AddColumn(cPlan, cTit, "Valor Total Pedido"  , 3, 2, .F.)  //06
	oExcel:AddColumn(cPlan, cTit, "Quant. Vol. Nf"      , 3, 2, .F.)  //07
	oExcel:AddColumn(cPlan, cTit, "Quant. Vol. Pedido"  , 3, 2, .F.)  //08
	oExcel:AddColumn(cPlan, cTit, "% Atendido P/ Valor ", 3, 2, .F.)  //09
	oExcel:AddColumn(cPlan, cTit, "% Atendido P/ Quant.", 3, 2, .F.)  //10
	oExcel:AddColumn(cPlan, cTit, "% Atendido Volume"   , 3, 2, .F.)  //11

EndIf
/*
+--------------------------------+
| QUERY REFERENTE OS MOVIMENTOS  |
+--------------------------------+
*/
If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf

cQuery := "SELECT D2_FILIAL AS FILIAL,  " + CRLF
cQuery += "D2_CLIENTE AS CLIENTE,  " + CRLF
cQuery += "D2_LOJA AS LOJA, " + CRLF
cQuery += "A1_NOME AS NOME, " + CRLF
cQuery += "D2_PEDIDO AS PEDIDO, " + CRLF
cQuery += "A3_COD AS VENDEDOR,  " + CRLF
cQuery += "A3_NOME AS NOMEVEND1, " + CRLF
cQuery += "A1_EST AS ESTADO, " + CRLF
cQuery += "D2_DOC AS  NFISCAL, " + CRLF
cQuery += "D2_SERIE AS SERIENF, " + CRLF
cQuery += "D2_EMISSAO AS DTNFISCAL, " + CRLF
cQuery += "C5_EMISSAO AS DTPEDIDO, " + CRLF
cQuery += "SUM(D2_QUANT) AS QTDVEN, " + CRLF
cQuery += "SUM(D2_QTSEGUM) AS QTDVOL, " + CRLF
cQuery += "SUM(D2_TOTAL-D2_VALACRS) AS TOTAL " + CRLF
cQuery += "FROM "+RetSqlName("SD2")+" AS SD2  " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SF2")+" AS SF2 ON F2_FILIAL = D2_FILIAL " + CRLF
cQuery += " AND F2_CLIENTE = D2_CLIENTE " + CRLF
cQuery += " AND F2_LOJA  = D2_LOJA " + CRLF
cQuery += " AND F2_DOC   = D2_DOC " + CRLF
cQuery += " AND F2_SERIE = D2_SERIE " + CRLF
cQuery += " AND SF2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SF4")+" AS SF4 ON F4_FILIAL = SUBSTRING(D2_FILIAL,1,2) " + CRLF
cQuery += " AND F4_CODIGO = D2_TES " + CRLF
cQuery += " AND SF4.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SA1")+" AS SA1 ON A1_FILIAL = D2_FILIAL " + CRLF
cQuery += " AND D2_CLIENTE = A1_COD  " + CRLF
cQuery += " AND D2_LOJA = A1_LOJA " + CRLF
cQuery += " AND SA1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 ON B1_COD = D2_COD " + CRLF
cQuery += " AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SC5")+" AS SC5 ON C5_FILIAL = D2_FILIAL " + CRLF
cQuery += " AND D2_CLIENTE = C5_CLIENTE " + CRLF
cQuery += " AND D2_LOJA = C5_LOJACLI " + CRLF
cQuery += " AND D2_PEDIDO = C5_NUM " + CRLF
cQuery += " AND SC5.D_E_L_E_T_ = ' ' " + CRLF 
cQuery += "INNER JOIN "+RetSqlName("SA3")+" AS SA3 ON A3_COD = F2_VEND1 " + CRLF
cQuery += " AND SA3.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE D2_FILIAL = '"+xFilial("SD2")+"' " + CRLF
cQuery += " AND F2_VEND1  BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " + CRLF
cQuery += " AND D2_CLIENTE  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + CRLF
cQuery += " AND D2_LOJA BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' " + CRLF
cQuery += " AND D2_DOC BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " + CRLF
cQuery += " AND D2_SERIE BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' " + CRLF
cQuery += " AND D2_EMISSAO BETWEEN '"+Dtos(MV_PAR11)+"' AND '"+Dtos(MV_PAR12)+"' " + CRLF
cQuery += " AND D2_PEDIDO  BETWEEN '"+MV_PAR13+"' AND '"+MV_PAR14+"' " + CRLF
// Tratamento das Coligadas o que não deve listar 
If cFilant == "0200"
	cQuery += " AND D2_CLIENTE NOT IN "+FORMATIN(GETMV("QE_CLI0200"),"/")+" " + CRLF
ElseIf cFilant == "0803"
	cQuery += " AND D2_CLIENTE NOT IN "+FORMATIN(GETMV("QE_CLI0803"),"/")+" " + CRLF
ElseIf cFilant == "0901"
	cQuery += " AND D2_CLIENTE NOT IN "+FORMATIN(GETMV("QE_CLI0901"),"/")+" " + CRLF
EndIf
cQuery += " AND F4_DUPLIC  = 'S' " + CRLF
cQuery += " AND D2_XNUMIND = '1' " + CRLF
cQuery += " AND SD2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "GROUP BY D2_FILIAL, D2_CLIENTE, D2_LOJA, A1_NOME, D2_PEDIDO, A3_COD, A3_NOME, A1_EST, D2_DOC, " + CRLF 
cQuery += "D2_SERIE, D2_EMISSAO, C5_EMISSAO " + CRLF
cQuery += "ORDER BY D2_EMISSAO,D2_DOC,D2_PEDIDO " + CRLF

TCQuery cQuery New Alias "TRB1"

TRB1->(DbGoTop())

While TRB1->(!Eof())

	lAbre   := .T.
	
	If Select("TRBK") > 0
		TRBK->(DbCloseArea())
	EndIf

	cQuery8 := "SELECT C9_DATALIB AS DATALIB, " + CRLF
	cQuery8 += "C9_CLIENTE AS CLIENTE,  " + CRLF
	cQuery8 += "C9_LOJA AS LOJA, " + CRLF
	cQuery8 += "C9_PEDIDO AS PEDIDO, " + CRLF
	cQuery8 += "C9_NFISCAL AS NFISCAL, " + CRLF
	cQuery8 += "C9_SERIENF AS SERIENF " + CRLF
	cQuery8 += "FROM "+RetSqlName("SC9")+" AS SC9  " + CRLF
	cQuery8 += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' " + CRLF
	cQuery8 += " AND C9_CLIENTE = '"+TRB1->CLIENTE+"' " + CRLF
	cQuery8 += " AND C9_LOJA = '"+TRB1->LOJA+"' " + CRLF
	cQuery8 += " AND C9_NFISCAL = '"+TRB1->NFISCAL+"' " + CRLF
	cQuery8 += " AND C9_SERIENF = '"+TRB1->SERIENF+"' " + CRLF
	cQuery8 += " AND C9_PEDIDO  = '"+TRB1->PEDIDO+"' " + CRLF
	cQuery8 += " AND SC9.D_E_L_E_T_ = ' ' " + CRLF
	cQuery8 += "GROUP BY C9_DATALIB, C9_CLIENTE, C9_LOJA, C9_PEDIDO, C9_NFISCAL, C9_SERIENF " + CRLF
	cQuery8 += "ORDER BY C9_DATALIB,C9_NFISCAL,C9_PEDIDO " + CRLF

	TCQuery cQuery8 New Alias "TRBK"

	TRBK->(DbGoTop())

	If TRBK->(!Eof())

		If TRBK->NFISCAL == TRB1->NFISCAL .And. TRBK->SERIENF == TRB1->SERIENF;
		   .And. TRBK->CLIENTE == TRB1->CLIENTE .And. TRBK->LOJA == TRB1->LOJA 	  

			_cFILIAL      := TRB1->FILIAL
			_cESTADO      := TRB1->ESTADO
			_dDATANF      := TRB1->DTNFISCAL
			_cCLIENTE     := TRB1->CLIENTE
			_cLOJA        := TRB1->LOJA
			_cNOME        := TRB1->NOME
			_cPEDIDO      := TRB1->PEDIDO
			_cVENDEDOR    := TRB1->VENDEDOR
			_cNOMEVEND1   := TRB1->NOMEVEND1
			_cNFISCAL     := TRB1->NFISCAL 
			_cSERIENF     := TRB1->SERIENF 
			_dDATANF      := TRB1->DTNFISCAL
			_dDTNFISCAL   := Substr(TRB1->DTNFISCAL,7,2)+"/"+Substr(TRB1->DTNFISCAL,5,2)+"/"+Substr(TRB1->DTNFISCAL,1,4)
			_dDTLIBERACAO := Substr(TRBK->DATALIB,7,2)+"/"+Substr(TRBK->DATALIB,5,2)+"/"+Substr(TRBK->DATALIB,1,4)
			_dDTPEDIDO    := Substr(TRB1->DTPEDIDO,7,2)+"/"+Substr(TRB1->DTPEDIDO,5,2)+"/"+Substr(TRB1->DTPEDIDO,1,4)
			// Tratamento totais por data 
			_nNF_QTDVEN   := TRB1->QTDVEN
			_nNF_TOTAL    := TRB1->TOTAL
			_nNF_QTDVOL   := TRB1->QTDVOL
			_nTQTDVEN     += TRB1->QTDVEN
			_nTTOTAL      += TRB1->TOTAL
			_nTQTDVOL     += TRB1->QTDVOL
			_nGNFQTDVEN   += TRB1->QTDVEN
			_nGNFTOTAL    += TRB1->TOTAL
			_nGNFQTDVOL   += TRB1->QTDVOL

			If Select("TRB2") > 0
				TRB2->(DbCloseArea())
			EndIf

			cQueryA := "SELECT SUM(C6_QTDVEN) AS QTDVEN, " + CRLF
			cQueryA += "SUM(C6_VALOR * C5_TXMOEDA) AS TOTAL, " + CRLF
			cQueryA += "SUM(C6_UNSVEN) AS QTDVOL " + CRLF
			cQueryA += "FROM "+RetSqlName("SC6")+" AS SC6  " + CRLF
			cQueryA += "INNER JOIN "+RetSqlName("SA1")+" AS SA1 ON A1_FILIAL = C6_FILIAL " + CRLF
			cQueryA += " AND C6_CLI = A1_COD  " + CRLF
			cQueryA += " AND C6_LOJA = A1_LOJA " + CRLF
			cQueryA += " AND SA1.D_E_L_E_T_ = ' '  " + CRLF
			cQueryA += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 ON B1_COD = C6_PRODUTO " + CRLF
			cQueryA += " AND SB1.D_E_L_E_T_ = ' '  " + CRLF
			cQueryA += "INNER JOIN "+RetSqlName("SC5")+" AS SC5 ON C5_FILIAL = C6_FILIAL " + CRLF 
			cQueryA += " AND C6_CLI = C5_CLIENTE  " + CRLF
			cQueryA += " AND C6_LOJA = C5_LOJACLI " + CRLF
			cQueryA += " AND C6_NUM = C5_NUM " + CRLF
			cQueryA += " AND SC5.D_E_L_E_T_ = ' ' " + CRLF
			cQueryA += "INNER JOIN "+RetSqlName("SA3")+" AS SA3 ON A3_COD = C5_VEND1 " + CRLF
			cQueryA += " AND SA3.D_E_L_E_T_ = ' ' " + CRLF
			cQueryA += "WHERE C6_FILIAL = '"+xFilial("SC6")+"' " + CRLF
			cQueryA += " AND C6_NUM  = '"+TRB1->PEDIDO+"' " + CRLF
			cQueryA += " AND C6_CLI  = '"+TRB1->CLIENTE+"' " + CRLF
			cQueryA += " AND C6_LOJA = '"+TRB1->LOJA+"' " + CRLF
			cQueryA += " AND SC6.D_E_L_E_T_ = ' ' " + CRLF

			TCQuery cQueryA New Alias "TRB2"

			TRB2->(DbGoTop())

			If TRB2->(!Eof())
				// Tratamento totais por data 
				_nPQTDVEN  := TRB2->QTDVEN
				_nPTOTAL   := TRB2->TOTAL
				_nPQTDVOL  := TRB2->QTDVOL
				_nTPVEN    := TRB2->QTDVEN
				_nTPTOT    := TRB2->TOTAL
				_nTPVOL    := TRB2->QTDVOL
				_nGPVEN    := TRB2->QTDVEN   
				_nGPTOT    := TRB2->TOTAL 
				_nGPVOL    := TRB2->QTDVOL

			Endif
		
		EndIf	
	
	EndIf
	
	TRB1->(DbSkip())

	IncProc("Gerando arquivo...")	
	
	If TRB1->(EOF()) .Or. TRB1->NFISCAL <> _cNFISCAL   

		If MV_PAR15 = 1 

			_nTP_QTDVEN   += _nTPVEN
			_nTP_TOTAL    += _nTPTOT
			_nTP_QTDVOL   += _nTPVOL

			_nGPQTDVEN    += _nGPVEN 
			_nGPTOTAL     += _nGPTOT
			_nGPQTDVOL    += _nGPVOL

			oExcel:AddRow(cPlan, cTit, {_cFILIAL,;     //01 
										_cCLIENTE,;    //02
										_cLOJA,;       //03
										_cNOME,;       //04
										_cPEDIDO,;     //05
										_cVENDEDOR,;   //06 
										_cNOMEVEND1,;  //07
										_cESTADO,;     //08 
										_dDTPEDIDO,;   //09      
										_dDTLIBERACAO,;//10    
										_cNFISCAL,;    //11 
										_cSERIENF,;    //12 
										_dDTNFISCAL,;  //13  
										_nNF_QTDVEN,; //14  
										_nNF_TOTAL,;  //15 
										_nPQTDVEN,;   //16
										_nPTOTAL,;    //17
										_nNF_QTDVOL,;  //18 
										_nPQTDVOL,;   //19
			Transform(ABS((_nNF_TOTAL/_nPTOTAL)*100),"@R 999.99%"),;   //20
			Transform(ABS((_nNF_QTDVEN/_nPQTDVEN)*100),"@R 999.99%"),; //21
			Transform(ABS((_nNF_QTDVOL/_nPQTDVOL)*100),"@R 999.99%")})  //22

		Else
			
			_nTP_QTDVEN   += _nTPVEN
			_nTP_TOTAL    += _nTPTOT
			_nTP_QTDVOL   += _nTPVOL
			_nGPQTDVEN    += _nGPVEN 
			_nGPTOTAL     += _nGPTOT
			_nGPQTDVOL    += _nGPVOL

		EndIf			   

		_dDTLIBERACAO := "" 
		_dDTPEDIDO    := ""
		_nNF_QTDVEN   := 0
		_nNF_TOTAL    := 0
		_nPQTDVEN     := 0
		_nPTOTAL      := 0
		_nNF_QTDVOL   := 0
		_nPQTDVOL     := 0
		_nTPVEN       := 0
		_nTPTOT       := 0
		_nTPVOL       := 0
		_nGPVEN       := 0
		_nGPTOT       := 0
		_nGPVOL       := 0
	
	EndIf			   

	If TRB1->(EOF()) .Or. TRB1->DTNFISCAL <> _dDATANF     

		If MV_PAR15 = 1 

			oExcel:AddRow(cPlan, cTit,{"",; //01
									"",;    //02         
									"",;    //03
									"",;    //04
									"",;    //05
									"",;    //06
									"",;    //07
									"",;    //08
									"",;    //09
									"",;    //10
									"",;    //11
									"",;    //12
									"",;    //13
									"",;    //14
									"",;    //15
									"",;    //16
									"",;    //17
									"",;    //18
									"",;    //19
									"",;    //20
									"",;    //21
									""})    //22  

			oExcel:AddRow(cPlan, cTit,{"",; //01
									"",;    //02         
									"",;    //03
									"",;    //04
									"",;    //05
									"",;    //06
									"",;    //07
									"",;    //08
									"",;    //09
									"",;    //10
					  "Total do Dia->",;    //11
									"",;    //12
					  	   _dDTNFISCAL,;    //13
						     _nTQTDVEN,;    //14
						      _nTTOTAL,;    //15
						   _nTP_QTDVEN,;    //16
							_nTP_TOTAL,;    //17
						     _nTQTDVOL,;    //18
						   _nTP_QTDVOL,;    //19
			Transform(ABS((_nTTOTAL/_nTP_TOTAL)*100),"@R 999.99%"),;   //20
			Transform(ABS((_nTQTDVEN/_nTP_QTDVEN)*100),"@R 999.99%"),; //21
			Transform(ABS((_nTQTDVOL/_nTP_QTDVOL)*100),"@R 999.99%")})//22


		Else

			oExcel:AddRow(cPlan, cTit,{ _cFilial,;     //01
										_dDTNFISCAL,;  //02
									    _nTQTDVEN,;    //03
				 						_nTTOTAL,;     //04
										_nTP_QTDVEN,;  //05
										_nTP_TOTAL,;   //06  
									    _nTQTDVOL,;    //07
									    _nTP_QTDVOL,;  //08
			Transform(ABS((_nTTOTAL/_nTP_TOTAL)*100),"@R 999.99%"),;   //09
			Transform(ABS((_nTQTDVEN/_nTP_QTDVEN)*100),"@R 999.99%"),; //10
			Transform(ABS((_nTQTDVOL/_nTP_QTDVOL)*100),"@R 999.99%")})//11


		EndIf		

		If MV_PAR15 = 1

			oExcel:AddRow(cPlan, cTit,{"",; //01
									"",;    //02         
									"",;    //03
									"",;    //04
									"",;    //05
									"",;    //06
									"",;    //07
									"",;    //08
									"",;    //09
									"",;    //10
									"",;    //11
									"",;    //12
									"",;    //13
									"",;    //14
									"",;    //15
									"",;    //16
									"",;    //17
									"",;    //18
									"",;    //19
									"",;    //20
									"",;    //21
									""})    //22  
   
		Endif

		_dDTNFISCAL   := ""
		_dDTLIBERACAO := "" 
		_dDTPEDIDO    := ""
	    _nTQTDVEN     := 0
		_nTTOTAL      := 0 
		_nTP_QTDVEN   := 0
		_nTP_TOTAL    := 0    
	    _nTQTDVOL     := 0
	    _nTP_QTDVOL   := 0

		_nNF_QTDVEN   := 0
		_nNF_TOTAL    := 0
		_nPQTDVEN     := 0
		_nPTOTAL      := 0
		_nNF_QTDVOL   := 0
		_nPQTDVOL     := 0
		_nTPVEN       := 0
		_nTPTOT       := 0
		_nTPVOL       := 0
		_nGPVEN       := 0
		_nGPTOT       := 0
		_nGPVOL       := 0

	EndIf

EndDo
/*
+--------------------------------+
| TOTAL GERAL DOS MOVIMENTOS     |
+--------------------------------+
*/
If MV_PAR15 = 1

	oExcel:AddRow(cPlan, cTit,{ "",;    //01
								"",;    //02         
								"",;    //03
								"",;    //04
								"",;    //05
								"",;    //06
								"",;    //07
								"",;    //08
								"",;    //09
								"",;    //10
			  	  "Total Geral ->",;    //11
								"",;    //12
			  		            "",;    //13
				   	   _nGNFQTDVEN,;    //14
				        _nGNFTOTAL,;    //15
				        _nGPQTDVEN,;    //16
				         _nGPTOTAL,;    //17  
					   _nGNFQTDVOL,;    //18
					    _nGPQTDVOL,;    //19
	Transform(ABS((_nGNFTOTAL/_nGPTOTAL)*100),"@R 999.99%"),;   //20
	Transform(ABS((_nGNFQTDVEN/_nGPQTDVEN)*100),"@R 999.99%"),; //21
	Transform(ABS((_nGNFQTDVOL/_nGPQTDVOL)*100),"@R 999.99%")}) //22


Else
	
	oExcel:AddRow(cPlan, cTit,{"",;    //01
				               "",;    //02         
							   "",;    //03
							   "",;    //04
							   "",;    //05
							   "",;    //06
							   "",;    //07
							   "",;    //08
							   "",;    //09
							   "",;    //10
							   "" })   //11  

	oExcel:AddRow(cPlan, cTit,{ _cFilial,;  //01
			 	         "Total Geral->",;  //02
							 _nGNFQTDVEN,;  //03
				    		  _nGNFTOTAL,;  //04
				    		  _nGPQTDVEN,;  //05
				     		   _nGPTOTAL,;  //06  
	 					     _nGNFQTDVOL,;  //07
					          _nGPQTDVOL,;  //08
	Transform(ABS((_nGNFTOTAL/_nGPTOTAL)*100),"@R 999.99%"),;   //09
	Transform(ABS((_nGNFQTDVEN/_nGPQTDVEN)*100),"@R 999.99%"),; //10
	Transform(ABS((_nGNFQTDVOL/_nGPQTDVOL)*100),"@R 999.99%")}) //11

EndIf

_nGNFQTDVEN := 0
_nGNFTOTAL  := 0
_nGPQTDVEN  := 0
_nGPTOTAL   := 0
_nGPQTDVOL  := 0
_nGNFQTDVOL := 0


If lAbre

	oExcel:Activate()
	oExcel:GetXMLFile(cArqDst)
	OPENXML(cArqDst)
	oExcel:DeActivate()

Else

	MsgInfo("Não existe dados para serem impressos.", "SEM DADOS")

EndIf

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf
If Select("TRB2") > 0
	TRB2->(DbCloseArea())
EndIf
If Select("TRBK") > 0
	TRBK->(DbCloseArea())
EndIf

Return

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | OPENXML   | Autor: | QUALY         | Data: | 13/02/21     |
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

Aadd(_aPerg,{"Lista Anal. ou Sint.?","mv_chf","C",01,"C","mv_par15","Analitico","Sintetico","","","","","","",0})


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
