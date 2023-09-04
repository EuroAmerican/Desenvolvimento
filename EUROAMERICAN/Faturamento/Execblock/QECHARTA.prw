
#include "parmtype.ch"
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"
#include "Colors.ch"
#include "RwMake.ch"

/*/{Protheus.doc} QECHARTA
Grafico de Indicadores de medição de Faturamento de Expedição 
@Autor Fabio Carneiro 
@since 22/08/2022
@version 1.0
@type user function 
/*/

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

User Function QECHARTA()

	Local oScroll
	Local nGrafico := LINECHART
	Private _cPerg := "QEGRAFI"
	
	Static oMonitor

	oAjustaSx1()

	If !Pergunte(_cPerg,.T.)
		Return
	Endif

	DEFINE MSDIALOG oMonitor TITLE "Grafico" FROM 0,0  TO 600,900 COLORS 0, 16777215 PIXEL 
	oScroll := TScrollArea():New(oMonitor,01,01,500,800)
	oScroll:Align := CONTROL_ALIGN_ALLCLIENT    
	
	Grafico(oScroll,nGrafico)
	
	oMenu := TBar():New( oMonitor, 48, 48, .T., , ,"CONTEUDO_BODY-FUNDO", .T. )
	DEFINE BUTTON RESOURCE "FW_PIECHART_1"		OF oMenu	ACTION Grafico(oScroll,PIECHART) 	 PROMPT " "	TOOLTIP "Pizza"			
	DEFINE BUTTON RESOURCE "FW_LINECHART_1"		OF oMenu	ACTION Grafico(oScroll,LINECHART) 	 PROMPT " "	TOOLTIP "Linha"			
	DEFINE BUTTON RESOURCE "FW_BARCHART_1"		OF oMenu	ACTION Grafico(oScroll,BARCHART) 	 PROMPT " "	TOOLTIP "Barra"			
	DEFINE BUTTON RESOURCE "FW_BARCOMPCHART_2"	OF oMenu	ACTION Grafico(oScroll,BARCOMPCHART) PROMPT " "	TOOLTIP "Barra"			
	
	ACTIVATE MSDIALOG oMonitor CENTERED

Return
/*
+------------------+-----------+---------------+-------+--------------+
| Static Function  | Grafico   |  QUALY        | Data: | 23/08/22     |
+------------------+-----------+---------------+-------+--------------+
| Descrição:       | Manutenção - Grafico                             |
+------------------+--------------------------------------------------+
*/
Static Function Grafico(oScroll,nGrafico)

	Local oChart
	Local cQuery        := ""
	Local cQueryA       := ""
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

	If Valtype(oChart)=="O"
		FreeObj(@oChart) //Usando a função FreeObj liberamos o objeto para ser recriado novamente, gerando um novo gráfico
	Endif
	
	oChart := FWChartFactory():New()
	oChart := oChart:getInstance( nGrafico ) 
	oChart:init( oScroll )
	oChart:SetTitle("Indicadores de Separação Diário", CONTROL_ALIGN_LEFT)
	If MV_PAR15 = 1
		oChart:SetMask( "R$ *@*")
	Elseif MV_PAR15 = 2
		oChart:SetMask( "*@*")
	Elseif MV_PAR15 = 3
		oChart:SetMask( "*@*")
	Elseif MV_PAR15 = 4
		oChart:SetMask( "*@* %")
	EndIf
	oChart:SetPicture("@E 999,999,999.99")
	oChart:setColor("Random") //Deixamos o protheus definir as cores do gráfico
	If nGrafico == PIECHART //se o gráfico tipo pizza, deixamos a legenda no rodapé
		oChart:SetLegend( CONTROL_ALIGN_BOTTOM )
	Endif	
	oChart:nTAlign := CONTROL_ALIGN_ALLCLIENT

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
	If cFilAnt == "0200"
		cQuery += " AND D2_CLIENTE NOT IN "+FORMATIN(GETMV("QE_CLI0200"),"/")+" " + CRLF
	ElseIf cFilAnt == "0803"
		cQuery += " AND D2_CLIENTE NOT IN "+FORMATIN(GETMV("QE_CLI0803"),"/")+" " + CRLF
	ElseIf cFilAnt == "0901"
		cQuery += " AND D2_CLIENTE NOT IN "+FORMATIN(GETMV("QE_CLI0901"),"/")+" " + CRLF
	EndIf
	cQuery += " AND F4_DUPLIC  = 'S' " + CRLF
	cQuery += " AND D2_XNUMIND = '1' " + CRLF
	cQuery += " AND SD2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY D2_FILIAL, D2_CLIENTE, D2_LOJA, A1_NOME, D2_PEDIDO, A3_COD, A3_NOME, A1_EST, D2_DOC, " + CRLF 
	cQuery += "D2_SERIE, D2_EMISSAO, C5_EMISSAO " + CRLF
	cQuery += "ORDER BY DTNFISCAL,NFISCAL,PEDIDO " + CRLF

	TCQuery cQuery New Alias "TRB1"

	TRB1->(DbGoTop())

	If TRB1->(!EOF())

		While TRB1->(!Eof())

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
			_dDTNFISCAL   := TRB1->DTNFISCAL
			_dDTLIBERACAO := TRB1->DTNFISCAL
			_dDTPEDIDO    := TRB1->DTPEDIDO

			// Tratamento totais por data 
			_nNF_QTDVEN    := TRB1->QTDVEN
			_nNF_TOTAL     := TRB1->TOTAL
			_nNF_QTDVOL    := TRB1->QTDVOL

			_nTQTDVEN      += TRB1->QTDVEN
			_nTTOTAL       += TRB1->TOTAL
			_nTQTDVOL      += TRB1->QTDVOL

			_nGNFQTDVEN    += TRB1->QTDVEN
			_nGNFTOTAL     += TRB1->TOTAL
			_nGNFQTDVOL    += TRB1->QTDVOL

			TRB1->(DbSkip())
		
			If TRB1->(EOF()) .Or. TRB1->NFISCAL <> _cNFISCAL   

				_nTP_QTDVEN   += _nTPVEN
				_nTP_TOTAL    += _nTPTOT
				_nTP_QTDVOL   += _nTPVOL

				_nGPQTDVEN    += _nGPVEN 
				_nGPTOTAL     += _nGPTOT
				_nGPQTDVOL    += _nGPVOL

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

				If nGrafico==LINECHART .OR. nGrafico==BARCOMPCHART 
					//Neste dois tipos de graficos temos:
					//(Titulo, {{ Descrição, Valor }})
					If MV_PAR15 = 1
						oChart:addSerie( "Valores Nota Fiscal",{{DTOC(STOD(_dDTNFISCAL)),(_nTTOTAL)}})
						oChart:addSerie( "Valores Pedido Vendas",{{DTOC(STOD(_dDTLIBERACAO)),(_nTP_TOTAL)}})
					ElseIf MV_PAR15 = 2
						oChart:addSerie( "Quantidade Nota Fiscal",{{DTOC(STOD(_dDTNFISCAL)),(_nTQTDVEN)}})
						oChart:addSerie( "Quantidade Pedido Vendas",{{DTOC(STOD(_dDTLIBERACAO)),(_nTP_QTDVEN)}})
					ElseIf MV_PAR15 = 3
						oChart:addSerie( "Volume Nota Fiscal",{{DTOC(STOD(_dDTNFISCAL)),(_nTQTDVOL)}})
						oChart:addSerie( "Volume Pedido Vendas",{{DTOC(STOD(_dDTLIBERACAO)),(_nTP_QTDVOL)}})
					ElseIf MV_PAR15 = 4
						oChart:addSerie( "% Valor NF x PV",{{DTOC(STOD(_dDTNFISCAL)),ABS((_nTTOTAL/_nTP_TOTAL)*100)}})
						oChart:addSerie( "% Itens NF X PV",{{DTOC(STOD(_dDTLIBERACAO)),ABS((_nTQTDVEN/_nTP_QTDVEN)*100)}})
						oChart:addSerie( "% Por Volume",{{DTOC(STOD(_dDTLIBERACAO)),ABS((_nTQTDVOL/_nTP_QTDVOL)*100)}})
					EndIf

				Else
					//Aqui temos:
					//(Titulo, Valor)
					If MV_PAR15 = 1
						oChart:addSerie("R$ NF "+DTOC(STOD(_dDTNFISCAL)),(_nTTOTAL))
						oChart:addSerie("R$ PV "+DTOC(STOD(_dDTLIBERACAO)),(_nTP_TOTAL))
					ElseIf MV_PAR15 = 2
						oChart:addSerie("Qt.NF "+DTOC(STOD(_dDTNFISCAL)),(_nTQTDVEN))
						oChart:addSerie("Qt.PV "+DTOC(STOD(_dDTLIBERACAO)),(_nTP_QTDVEN))
					ElseIf MV_PAR15 = 3
						oChart:addSerie("Vol.NF "+DTOC(STOD(_dDTNFISCAL)),(_nTQTDVOL))
						oChart:addSerie("Vol.PV "+DTOC(STOD(_dDTLIBERACAO)),(_nTP_QTDVOL))
					ElseIf MV_PAR15 = 4
						oChart:addSerie("% Vl. "+DTOC(STOD(_dDTNFISCAL)),ABS((_nTTOTAL/_nTP_TOTAL)*100))
						oChart:addSerie("% It. "+DTOC(STOD(_dDTLIBERACAO)),ABS((_nTQTDVEN/_nTP_QTDVEN)*100))
						oChart:addSerie("% Vol "+DTOC(STOD(_dDTLIBERACAO)),ABS((_nTQTDVOL/_nTP_QTDVOL)*100))
					EndIf

				EndIf

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

		oChart:build()

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

Aadd(_aPerg,{"Gráfico Por ........?","mv_chf","C",01,"C","mv_par15","Valor","Quantidade","Volume","Percentual","","","","",0})


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

