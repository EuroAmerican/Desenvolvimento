#include "protheus.ch"
#include "parmtype.ch"
#include "ap5mail.ch"
#include "totvs.ch"
#include 'topconn.ch'
#include 'tbiconn.ch'
/*/{Protheus.doc} mfatv02
//Rotina para visuliar as liberações que serão executadas 
@author Fabio carneiro dos Santos
@since 10/10/2022
@version 1.0
/*/
User Function mfatv02()
	Local aSays    := {}
	Local aButtons := {}
	Local nOpca    := {}
	Local U_FATUSX1 := {}
	Local cTitoDlg := "Visulizar Liberação de pedidos"
	Local cPerg    := "MFAT002"

	Private CNOMEARQC := ""
	Private CNOMEARQI := ""

	//Pergunta 01
	aHelpPor := {}
	aAdd(aHelpPor, "Informe a data de entrega limite")
	aAdd(aHelpPor, "para efetuar o filtro dos pedidos")
	aAdd(aHelpPor, "de vendas.")
	U_FATUSX1(cPerg, "01","Entrega Até?","Entrega Até","Entrega Até", "MV_CH1","D",8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 02
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o codigo do")
	aAdd(aHelpPor, "vendedor inicial a ser considerado")
	U_FATUSX1(cPerg, "02","Vendedor De","Vendedor De","Vendedor De","MV_CH2","C",6,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SA3","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 03
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o codigo do")
	aAdd(aHelpPor, "vendedor final a ser considerado")
	U_FATUSX1(cPerg, "03","Vendedor Ate","Vendedor Ate","Vendedor Ate","MV_CH3","C",6,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SA3","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 04
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o codigo do")
	aAdd(aHelpPor, "Cliente inicial a ser considerado")
	U_FATUSX1(cPerg, "04","Cliente De","Cliente De","Cliente De","MV_CH4","C",6,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 05
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o codigo do")
	aAdd(aHelpPor, "vendedor final a ser considerado")
	U_FATUSX1(cPerg, "05","Cliente Ate","Cliente Ate","Cliente Ate","MV_CH5","C",6,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","","","", aHelpPor, aHelpPor, aHelpPor)
	

	//Pergunta 06
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o % MINIMO por Litros de atendimento")
	aAdd(aHelpPor, "do pedido para liberacao.")
	U_FATUSX1(cPerg, "06","% Minimo/Litros","% Minimo/Litros","% Minimo/Litros","MV_CH6","N",3,0,2,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 07
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o % MINIMO por Volume de atendimento")
	aAdd(aHelpPor, "do pedido para liberacao.")
	U_FATUSX1(cPerg, "07","% Minimo/Volume","% Minimo/Volume","% Minimo/Volume","MV_CH7","N",3,0,2,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 08
	aHelpPor := {}
	aAdd(aHelpPor, "Visualiza todos os pedidos, ou apenas")
	aAdd(aHelpPor, "os pedidos que atingiram o minimo de")
	aAdd(aHelpPor, "atendimento.")
	U_FATUSX1(cPerg, "08","Mostrar Pedidos","Mostrar Pedidos","Mostrar Pedidos","MV_CH8","N",1,0,2,"C","","MV_PAR08","Todos","Todos","Todos","","","Atendidos","Atendidos","Atendidos","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 09
	aHelpPor := {}
	aAdd(aHelpPor, "Do Estado")
	aAdd(aHelpPor, "Filtrar por estado ")
	U_FATUSX1(cPerg, "09","Do Estado","Do Estado","Do Estado", "MV_CH9","C",2,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","12","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 10
	aHelpPor := {}
	aAdd(aHelpPor, "Até o Estado")
	aAdd(aHelpPor, "Filtrar por estado ")
	U_FATUSX1(cPerg, "10","Até o Estado","Até o Estado","Até o Estado", "MV_CHA","C",2,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","12","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 11
	aHelpPor := {}
	aAdd(aHelpPor, "Exclui o Estado")
	aAdd(aHelpPor, "Filtrar por estado ")
	U_FATUSX1(cPerg, "11","Exclui o Estado","Exclui o Estado","Exclui o Estado", "MV_CHB","C",2,0,0,"G","","MV_PAR11","","","","","","","","","","","","","","","","","","","","","","","","","12","","","","","", aHelpPor, aHelpPor, aHelpPor)

	aAdd(aSays, "Esta rotina tem por objetivo gerar a listagem dos pedidos de vendas")
	aAdd(aSays, "liberados pelo credito que ainda nao foram liberados pelo estoque.")
	aAdd(aSays, "Sera feita a verificacao do saldo em estoque, informando o percentual")
	aAdd(aSays, "de atendimento do pedido.")

	aAdd(aButtons,{5, .T., {|o| Pergunte(cPerg, .T.)}})
	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	If nOpca == 1
			Pergunte(cPerg, .F.)
			Processa({|| U_mfatv2ok("Aguarde. Processando pedidos...")})
	EndIf
Return

User Function mfatv2ok()
	Local aSaldos := {}
	Local cQuery  := ""
	Local nDisp   := 0

	Local aCpoTRB1 := {}
	Local aCpoTRB2 := {}
	Local cIndTRB11:= ""
	Local cIndTRB12:= ""
	Local cIndTRB21:= ""

	
	Local nTotIt  := 0
	Local nTotLt  := 0.000
	Local nItAten := 0
	Local nLtAten := 0.000
	
	Local MARCA     := ''
	
	Local nValorTot  := 0
	Local nPesoTot   := 0
	Local cValorTot  := ''
	
	Local _nValorTot := 0
	Local _nPeso     := 0
	
	Local _aProd := {}

	Private nPesoTB1 := 0

	Private aPEDIDOS := {}
	Private cNumPV  := ""

	Private cPesoTot := ''
	Private nSayPeso := 0
	Private cSayPeso := '0'
	Private cValtot  := ''
	Private nPesoSC5 := 0 

	Private lMarcar := .F.

	Private aCoors := FWGetDialogSize( oMainWnd )
	Private oDlgPrinc
	Private cCadastro := "Visualizar Liberação de Estoque"
	Private oPanelUp, oFWLayer, oPanelLeft, oPanelRight, oBrowseUp, oBrowseDown, oRelac

	//Painel superior
	aAdd(aCpoTRB1, {"MARCA"  , "C", 2, 0})// Fabio batista campo para checkbox
	aAdd(aCpoTRB1, {"DTENT"  , "D", 8, 0})
	aAdd(aCpoTRB1, {"PEDIDO" , "C", 6, 0})
	aAdd(aCpoTRB1, {"CLIENTE", "C", 6, 0})
	aAdd(aCpoTRB1, {"LOJA"   , "C", 2, 0})
	aAdd(aCpoTRB1, {"NOME"   , "C",30, 0})
	aAdd(aCpoTRB1, {"UF  "   , "C", 3, 0})
	aAdd(aCpoTRB1, {"VLTOTAL", "N",12, 2})
	aAdd(aCpoTRB1, {"CONDPAG", "C",20, 0})
	aAdd(aCpoTRB1, {"CFOP"   , "C",20, 0})
	aAdd(aCpoTRB1, {"NUMITEM", "N", 6, 0})
	aAdd(aCpoTRB1, {"QUANTID", "N",12, 3})
	aAdd(aCpoTRB1, {"LITROS" , "N",10, 3})
	aAdd(aCpoTRB1, {"ATEND"  , "N", 4, 0})
	aAdd(aCpoTRB1, {"LIBER"  , "C", 1, 0})
	aAdd(aCpoTRB1, {"ATENDN" , "N", 6, 2})
	aAdd(aCpoTRB1, {"ATENDL" , "N", 6, 2})
	aAdd(aCpoTRB1, {"VALATE" , "N", 14, 2})// Fabio batista VALOR ATENDIDO SC9
	aAdd(aCpoTRB1, {"VALPED" , "N", 14, 2})// Fabio batista VALOR PEDIDO SC6
	aAdd(aCpoTRB1, {"VALOR"  , "N", 14, 2})// Fabio batista PERCENTUAL VALOR
	aAdd(aCpoTRB1, {"PESATE" , "N", 11, 4})// Fabio batista PESO ATENDIDO SC9
	aAdd(aCpoTRB1, {"PESPED" , "N", 11, 4})// Fabio batista PEDO PEDIDO SC6
	aAdd(aCpoTRB1, {"PESO"   , "N", 11, 4})// Fabio batista PERCENTUAL PESO
	aAdd(aCpoTRB1, {"LIBPV"  , "C", 1, 0})
	CNOMEARQC := "MFAT002C" + DTOS(MSDATE())+REPLACE(TIME(),":","")
	DbCreate("\DATA\" + CNOMEARQC + ".DTC", aCpoTRB1)
	DbUseArea(.T., "CTREECDX", "\DATA\" + CNOMEARQC + ".DTC", "TRB1", .T., .F.)
	DbSelectArea("TRB1")
	DbCreateIndex("\DATA\" + CNOMEARQC + "A.IDX", "PEDIDO", {|| PEDIDO})
	DbSetOrder(1)

	//Painel inferior
	aAdd(aCpoTRB2, {"IPEDIDO", "C", 6, 0})
	aAdd(aCpoTRB2, {"ITEM"   , "C", 2, 0})
	aAdd(aCpoTRB2, {"SEQUEN" , "C", 2, 0})
	aAdd(aCpoTRB2, {"PRODUTO", "C",15, 0})
	aAdd(aCpoTRB2, {"DESCRIC", "C",40, 0})
	aAdd(aCpoTRB2, {"ALMOX"  , "C", 2, 0})
	aAdd(aCpoTRB2, {"QUANT"  , "N",12, 3})
	aAdd(aCpoTRB2, {"LITROS" , "N",10, 3})
	aAdd(aCpoTRB2, {"ATEND"  , "N", 4, 0})
	aAdd(aCpoTRB2, {"ATENDN" , "N", 6, 2})
	aAdd(aCpoTRB2, {"ATENDL" , "N", 6, 2})
	aAdd(aCpoTRB2, {"QTDLIB" , "N",12, 3})
	aAdd(aCpoTRB2, {"QTDEMB" , "N", 4, 0})
	CNOMEARQI := "MFAT002I" + DTOS(MSDATE())+REPLACE(TIME(),":","")
	DbCreate("\DATA\" + CNOMEARQI + ".DTC", aCpoTRB2)
	DbUseArea(.T., "CTREECDX", "\DATA\" + CNOMEARQI + ".DTC", "TRB2", .T., .F.)
	DbSelectArea("TRB2")
	DbCreateIndex("\DATA\" + CNOMEARQI + "A.IDX", "IPEDIDO + ITEM", {|| PEDIDO + ITEM})
	DbSetIndex("\DATA\" + CNOMEARQI + "A.IDX")
	
	cQuery := "SELECT C9_FILIAL,A1_EST,C9_PEDIDO,C9_ITEM,C9_SEQUEN,C9_CLIENTE,C9_LOJA,C9_PRODUTO,B1_DESC,B1_UM,B1_LOTVEN,C9_LOCAL,C9_QTDLIB,"+CRLF
	cQuery += "	CASE WHEN B1_TIPCONV = 'M' THEN (C9_QTDLIB * CASE WHEN B1_CONV = 0 THEN 1 ELSE B1_CONV END) "+CRLF
	cQuery += "	ELSE (C9_QTDLIB / CASE WHEN B1_CONV = 0 THEN 1 ELSE B1_CONV END) "+CRLF
	cQuery += "	END "+CRLF
	cQuery += "QTDLTS,C9_PRCVEN,(C9_QTDLIB * C9_PRCVEN) C9_TOTAL,C5_EMISSAO,C6_ENTREG,E4_DESCRI,F4_TEXTO,C5_TIPO,C6_QTDEMP, C6_PRCVEN, C6_QTDVEN, "+CRLF

	cQuery += "B1_PESBRU," + CRLF //alterado por fabio batista
    cQuery += "((C6_QTDEMP)*B1_PESBRU) PES_ATEN , " + CRLF//alterado por fabio batista
	cQuery += "(C6_QTDVEN*B1_PESBRU) PES_PED,  "+ CRLF//alterado por fabio batista
	cQuery += "((C6_QTDEMP)*C6_PRCVEN) VAL_ATEN ,"+ CRLF//alterado por fabio batista
	cQuery += "(C6_QTDVEN*C6_PRCVEN) VALOR_PED,  "+ CRLF//alterado por fabio batista
	cQuery += "C5_PBRUTO, '  ' AS MARCA " + CRLF//alterado por 
	cQuery += "FROM " + RetSqlName("SC9") + " SC9 "+CRLF
	cQuery += "INNER JOIN " + RetSqlName("SC6") + " SC6 ON C6_FILIAL = C9_FILIAL AND C6_NUM = C9_PEDIDO AND C6_ITEM = C9_ITEM AND SC6.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'AND F4_CODIGO = C6_TES AND F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = C9_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "INNER JOIN " + RetSqlName("SC5") + " SC5 ON C5_FILIAL = C9_FILIAL AND C5_NUM = C9_PEDIDO "+CRLF
	cQuery += "INNER JOIN " + RetSqlName("SE4") + " SE4 ON E4_FILIAL = '"+xFilial("SE4")+"' AND E4_CODIGO = C5_CONDPAG AND SE4.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "INNER JOIN " + RetSqlName("SA1") + " SA1 ON A1_FILIAL = C9_FILIAL AND A1_COD = C9_CLIENTE AND A1_LOJA = C9_LOJA AND SA1.D_E_L_E_T_ = ''"+CRLF
	cQuery += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' "+CRLF
	cQuery += "AND C9_BLEST NOT IN (' ', '10') "+CRLF
	cQuery += "AND C9_BLCRED = ' ' "+CRLF
	cQuery += "AND C6_ENTREG <= '" + Dtos(MV_PAR01) + "'"+CRLF
	cQuery += "AND SC9.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "AND C5_VEND1 BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' "+CRLF
	cQuery += "AND C5_CLIENTE BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "' "+CRLF
	cQuery += "AND A1_EST BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "'"+CRLF
	cQuery += "AND A1_EST NOT IN ('" + MV_PAR11 + "') "+CRLF
	cQuery += "AND SC5.D_E_L_E_T_ = ' ' "+CRLF
	
	//cQuery += "AND SC5.C5_XMARGEM != 'NAO' "+CRLF// Ajustado Fabio Batista 07/12/2020 bloqueio margem 
	
	cQuery += "ORDER BY C9_FILIAL, C9_PEDIDO"+CRLF//Ajustado Fabio Batista  

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB3", .F., .F.)
	TcSetField("TRB3", "C5_EMISSAO", "D", 08, 0)
	TcSetField("TRB3", "C6_ENTREG" , "D", 08, 0)

	SB2->(DbSetOrder(1))
	SB1->(DbSetOrder(1))

	
	nPercItens := 0 // fabio batista
	nQtdItens  := 0 // fabio batista
	nPesoSC5   := 0 // fabio batista
	nTotalPed  := 0 // Valor total pedido

	TRB3->(DbGoTop())
	cNumPV := TRB3->C9_PEDIDO
	ProcRegua(TRB3->(LastRec()))

	If !Empty(cNumPV)

	While TRB3->(!Eof()) 

			cQuery := "SELECT SUM(C6_VALOR) AS TOTAL FROM " + RetSqlName("SC6") + " WITH (NOLOCK) WHERE C6_FILIAL = '" + xFilial("SC6") + "' AND C6_NUM = '" + AllTrim(TRB3->C9_PEDIDO) + "' AND D_E_L_E_T_ = ' '"
			TCQuery cQuery New Alias "TOTPED"
			dbSelectArea("TOTPED")
			TOTPED->( dbGoTop() )
			If !TOTPED->( Eof() )
				nTotalPed  := TOTPED->TOTAL // Valor total pedido
			Else
				nTotalPed  := 0 // Valor total pedido
			EndIf
			TOTPED->( dbCloseArea() )

			If cNumPV == TRB3->C9_PEDIDO			

				_nValorTot := (((TRB3->C6_QTDEMP)*TRB3->C6_PRCVEN)/(TRB3->C6_QTDVEN*TRB3->C6_PRCVEN))*100
				_nPeso     := (((TRB3->C6_QTDEMP)*TRB3->B1_PESBRU)/(TRB3->C6_QTDVEN*TRB3->B1_PESBRU))*100 

				If TRB1->(DbSeek(cNumPV, .F.))
					TRB1->(RecLock("TRB1", .F.))
				Else
					TRB1->(RecLock("TRB1", .T.))
					TRB1->MARCA   := "  "
					TRB1->DTENT   := TRB3->C6_ENTREG
					TRB1->PEDIDO  := TRB3->C9_PEDIDO
					TRB1->CLIENTE := TRB3->C9_CLIENTE
					TRB1->LOJA    := TRB3->C9_LOJA
					If TRB3->C5_TIPO $ "B|D"
						SA2->(DbSetOrder(1))
						//SA2->(DbSeek(FWxFilial("SA2") + TRB3->C9_CLIENTE + TRB3->C9_LOJA, .F.))
						SA2->(DbSeek(xFilial("SA2") + TRB3->C9_CLIENTE + TRB3->C9_LOJA, .F.))
						TRB1->NOME := SA2->A2_NOME
					Else
						SA1->(DbSetOrder(1))
						SA1->(DbSeek(xFilial("SA1") + TRB3->C9_CLIENTE + TRB3->C9_LOJA, .F.))
						TRB1->NOME := SA1->A1_NOME
						TRB1->UF   := SA1->A1_EST
					EndIf
					TRB1->CONDPAG := TRB3->E4_DESCRI
					TRB1->CFOP    := TRB3->F4_TEXTO

				EndIf
					
				nPercItens += _nValorTot

				nQtdItens++			
				TRB1->PESO += TRB3->PES_ATEN
				
				TRB1->PESO += TRB3->PES_ATEN

				TRB1->NUMITEM += 1
				TRB1->VLTOTAL += TRB3->C9_TOTAL
				TRB1->LITROS  += TRB3->QTDLTS
				TRB1->QUANTID += TRB3->C9_QTDLIB
			
				TRB1->PESPED += TRB3->PES_PED

				TRB1->VALPED += TRB3->VALOR_PED

				TRB1->VALOR := (TRB1->VALPED / nTotalPed) * 100 

				//PAINEL INFERIOR
				TRB2->(RecLock("TRB2", .T.))
				TRB2->IPEDIDO := TRB3->C9_PEDIDO
				TRB2->ITEM    := TRB3->C9_ITEM
				TRB2->SEQUEN  := TRB3->C9_SEQUEN
				TRB2->PRODUTO := TRB3->C9_PRODUTO
				TRB2->DESCRIC := Posicione("SB1", 1, xFilial("SB1") + TRB3->C9_PRODUTO, "B1_DESC")
				TRB2->ALMOX   := TRB3->C9_LOCAL
				TRB2->QUANT   := TRB3->C9_QTDLIB
				TRB2->LITROS  := TRB3->QTDLTS
				TRB2->QTDEMB  := TRB3->B1_LOTVEN

				//VERIFICA SALDO EM ESTOQUE DO ITEM. aSaldos{produto, local, qtd.ja lib, saldo sb2}
				SB1->(DbSeek(xFilial("SB1") + TRB3->C9_PRODUTO, .F.))  //multiplo por embalagem.

				nPos := aScan(aSaldos, {|x| x[1] + x[2] == TRB3->C9_PRODUTO + TRB3->C9_LOCAL })  //MATRIZ COM OS SALDOS
				If nPos > 0
					If aSaldos[nPos, 4] - (aSaldos[nPos, 3] + TRB3->C9_QTDLIB) >= 0
						TRB1->ATEND += 1
						TRB2->ATEND := 100
						TRB2->QTDLIB:= TRB3->C9_QTDLIB
						aSaldos[nPos, 3] += TRB3->C9_QTDLIB
					Else  //liberar apenas o saldo no estoque, tratar o multiplo
						nSaldo := aSaldos[nPos, 4] - aSaldos[nPos, 3]  //saldo - ja liberado
						If nSaldo > 0  //existe saldo no estoque
							TRB1->ATEND += 1
							If SB1->B1_LOTVEN <= 1  //nao possui multiplo
								TRB2->QTDLIB:= nSaldo //aSaldos[nPos, 4]
								TRB2->ATEND := (nSaldo / TRB3->C9_QTDLIB) * 100  //(aSaldos[nPos, 4] / TRB3->C9_QTDLIB) * 100
								aSaldos[nPos, 3] += nSaldo  //aSaldos[nPos, 4]
							Else
								nResto := (nSaldo % SB1->B1_LOTVEN)
								TRB2->QTDLIB := nSaldo - nResto
								TRB2->ATEND  := ((nSaldo - nResto) / TRB3->C9_QTDLIB) * 100
								aSaldos[nPos, 3] += (nSaldo - nResto)
							EndIf
						Else
							TRB2->ATEND := 0
							TRB2->QTDLIB:= 0
						EndIf
					EndIf
				Else
					//alimenta aSaldos{produto, local, qtd.ja lib, saldo sb2}
					If SB2->(DbSeek(xFilial("SB2") + TRB3->C9_PRODUTO + TRB3->C9_LOCAL, .F.))
						If SB2->(B2_QATU - B2_RESERVA - B2_QACLASS) - TRB3->C9_QTDLIB >= 0
							TRB1->ATEND += 1
							TRB2->ATEND := 100
							TRB2->QTDLIB:= TRB3->C9_QTDLIB
							aAdd(aSaldos, {TRB3->C9_PRODUTO, TRB3->C9_LOCAL, TRB3->C9_QTDLIB, SB2->(B2_QATU - B2_RESERVA - B2_QACLASS) })
						Else
							nSaldo := SB2->(B2_QATU - B2_RESERVA - B2_QACLASS)
							If nSaldo > 0
								TRB1->ATEND += 1
								If SB1->B1_LOTVEN <= 1
									TRB2->QTDLIB:= SB2->(B2_QATU - B2_RESERVA - B2_QACLASS)
									TRB2->ATEND := (SB2->(B2_QATU - B2_RESERVA - B2_QACLASS) / TRB3->C9_QTDLIB) * 100
									aAdd(aSaldos, {TRB3->C9_PRODUTO, TRB3->C9_LOCAL, SB2->(B2_QATU - B2_RESERVA - B2_QACLASS), SB2->(B2_QATU - B2_RESERVA - B2_QACLASS) })
								Else
									nResto := (nSaldo % SB1->B1_LOTVEN)
									TRB2->QTDLIB := nSaldo - nResto
									TRB2->ATEND  := ((nSaldo - nResto) / TRB3->C9_QTDLIB) * 100
									aAdd(aSaldos, {TRB3->C9_PRODUTO, TRB3->C9_LOCAL, (nSaldo - nResto), SB2->(B2_QATU - B2_RESERVA - B2_QACLASS) })
								EndIf
							Else
								aAdd(aSaldos, {TRB3->C9_PRODUTO, TRB3->C9_LOCAL, 0, 0 })
							EndIf
						EndIf
					Else
						aAdd(aSaldos, {TRB3->C9_PRODUTO, TRB3->C9_LOCAL, 0, 0 })
						TRB2->ATEND := 0
						TRB2->QTDLIB:= 0
					EndIf
				EndIf

				nPesoSC5 := TRB3->C5_PBRUTO
				SB1->(DbSeek(xFilial("SB1") + TRB3->C9_PRODUTO, .F.))
				nTotIt  += TRB3->C9_QTDLIB
				nTotLt  += TRB3->QTDLTS
				nItAten += TRB2->QTDLIB
				nLtAten += Iif(SB1->B1_TIPCONV == "M", (TRB2->QTDLIB * SB1->B1_CONV), (TRB2->QTDLIB / SB1->B1_CONV))

				// Calcula a partir do TRB2, pois ele fez o calculo depois da query :(
				TRB1->QUANTID += TRB2->QTDLIB // TESTES
				If TRB2->QTDLIB > 0
					TRB1->PESATE  += (TRB2->QTDLIB * SB1->B1_PESBRU) //Iif(SB1->B1_TIPCONV == "M", (TRB2->QTDLIB * SB1->B1_CONV), (TRB2->QTDLIB / SB1->B1_CONV))
				EndIf
				TRB1->VALATE  += (TRB3->VAL_ATEN / TRB3->C9_QTDLIB) * TRB2->QTDLIB 
				// FS e FB
				
				TRB1->VALOR := (TRB1->VALATE / nTotalPed) * 100 //FABIO BATISTA (--> TRB1->VALPED)
				
				TRB1->(MsUnLock())
				TRB2->(MsUnLock())
				TRB3->(DbSkip())

				IncProc("Totalizando os pedidos...")

			Else  //%de atendimento
				TRB1->(RecLock("TRB1", .F.))
				TRB1->ATENDN := (TRB1->ATEND / TRB1->NUMITEM) * 100
				TRB1->ATENDL := Iif(nTotLt == nLtAten, 100, (nLtAten / nTotLt) * 100)
				
				// fabio batista percentual peso
				nPesoTB1 := TRB1->PESATE //TRB1->PESO
				If nPesoTB1 <> 0 .And. nPesoSC5 <> 0
					TRB1->PESO := nPesoTB1 / nPesoSC5 * 100.00
				EndIf

				// fabio batista percentual valor
				If nPercItens <> 0
					cValTot := cValtochar(nPercItens / nQtdItens)
				Else
					TRB1->VALOR := 0
				EndIf
				
				TRB1->(MsUnLock())

				IncProc("Totalizando os pedidos...")
				cNumPv  := TRB3->C9_PEDIDO
				nTotIt  := 0
				nTotLt  := 0
				nItAten := 0
				nLtAten := 0
				nPercItens := 0 //fabio batista
				nQtdItens  := 0 //fabio batista
				
			EndIf

		EndDo
		TRB3->(DbCloseArea())

		TRB1->(RecLock("TRB1", .F.))
			TRB1->ATENDN := (TRB1->ATEND / TRB1->NUMITEM) * 100
			TRB1->ATENDL := Iif(nTotLt == nLtAten, 100, (nLtAten / nTotLt) * 100)

			If nPercItens <> 0
				cValTot := cValtochar(nPercItens / nQtdItens)
			Else
				TRB1->VALOR := 0
			EndIf

			// fabio batista percentual peso
			nPesoTB1 := TRB1->PESO
			If nPesoTB1 <> 0 .And. nPesoSC5 <> 0
				TRB1->PESO := nPesoTB1 / nPesoSC5 * 100.00
			EndIf
		TRB1->(MsUnLock())

		DbSelectArea("TRB2")
		DbSetOrder(1)
		DbGoTop()

		DbSelectArea("TRB1")
		DbCreateIndex("\DATA\" + CNOMEARQC + "B.IDX", "DTOS(DTENT) + PEDIDO", {|| DTOS(DTENT) + PEDIDO})
		DbSetOrder(1)
		DbGoTop()

		If MV_PAR08 == 2  //filtra apenas os que atingiram o minimo para faturamento
			TRB1->(DbSetFilter({||TRB1->ATENDL >= MV_PAR06 .And. TRB1->ATENDN >= MV_PAR07},"TRB1->ATENDL >= MV_PAR06 .And. TRB1->ATENDN >= MV_PAR07"))
		EndIf

		Define MsDialog oDlgPrinc Title cCadastro From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		oFWLayer := FWLayer():New()
		oFWLayer:Init(oDlgPrinc, .F., .T.)
		oFWLayer:AddLine("UP", 40, .F.)
		oFWLayer:AddCollumn("ALL", 100, .T., "UP")
		oPanelUp := oFWLayer:GetColPanel("ALL", "UP")
		oFWLayer:AddLine("DOWN", 50, .F.)
		oFWLayer:AddCollumn("ALL", 100, .T., "DOWN")
		oPanelDown := oFWLayer:GetColPanel("ALL", "DOWN")

		oFWLayer:AddLine("CAB", 10, .F.)
		oFWLayer:AddCollumn("ALL", 100, .T., "CAB")
		oPanelCAB := oFWLayer:GetColPanel("ALL", "CAB")

		If Valtype(nValorTot) == "N"
			nValorTot := Transform(nValorTot,"9,999,999.99")
			cValorTot := cValtochar(nValorTot)
		EndIf
		//fabio batista
		If Valtype(nPesoTot) == "N" 
			Transform(nPesoTot,"999,999.9999")          
			cPesoTot := cValtochar(nPesoTot)
		EndIf 
		  
		 //fabio batista 
		oFont := TFont():New('Courier new',,-20,.T.)// usar na chamada do botão
		oSay:= TSay():New(001,010,{||''},oPanelCAB,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
		oSay3:= TSay():New(001,230,{||'Peso Total: KG: '+'0'},oPanelCAB,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
		oSay2:= TSay():New(001,450,{||'Valor Total R$: '+'0'},oPanelCAB,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)

		aColSup := {{"Entrega"       , "DTENT"  , "D", "@D"               , 1, 8 , 0},;
					{"Pedido"        , "PEDIDO" , "C", "@!"               , 1, 6 , 0},;
					{"Cliente"       , "CLIENTE", "C", "@!"               , 1, 6 , 0},;
					{"Loja"          , "LOJA"   , "C", "@!"               , 1, 2 , 0},;
					{"Nome"          , "NOME"   , "C", "@!"               , 1, 20, 0},;
					{"Vlr.Total"     , "VLTOTAL", "N", "@E 9,999,999.99"  , 2, 12, 2},;
					{"Cond.Pagto"    , "CONDPAG", "C", "@!"               , 1, 10, 0},;
					{"CFOP"          , "CFOP"   , "C", "@!"               , 1, 10, 0},;
					{"Num.Itens"     , "NUMITEM", "N", "@E 9,999.999"     , 2, 9 , 3},;
					{"Qtd.Litros"    , "LITROS" , "N", "@E 9,999.999"     , 2, 9 , 3},;
					{"%Volume"       , "ATENDL" , "N", "@E 999.99"        , 2, 6 , 2},;
					{"Valor Atendido", "VALATE" , "N", "@E 999,999,999.99", 2, 12, 2},;//fabio batista
					{"Valor Pedido"  , "VALPED" , "N", "@E 999,999,999.99", 2, 12, 2},;//fabio batista
					{"%Valor"        , "VALOR"  , "N", "@E 999,999,999.99", 2, 12, 2},;//fabio batista
					{"Peso Atendido" , "PESATE" , "N", "@E 999,999.99"  , 4, 11, 4},;//fabio batista
					{"Peso Pedido"   , "PESPED" , "N", "@E 999,999.99"  , 4, 11, 4},;//fabio batista
					{"%Peso"         , "PESO"   , "N", "@E 999,999.99"  , 4, 11, 4},;//fabio batista
					{"%Em Itens"     , "ATENDN" , "N", "@E 999.99"        , 2, 6 , 2}}

		aColInf := {{"Item"     , "ITEM"   , "C", "@!"          , 1, 2, 0},;
					{"Produto"  , "PRODUTO", "C", "@!"          , 1,15, 0},;
					{"Descricao", "DESCRIC", "C", "@!"          , 1,30, 0},;
					{"Almox"    , "ALMOX"  , "C", "@!"          , 1, 2, 0},;
					{"Quant"    , "QUANT"  , "N", "@E 9,999.999", 2, 9, 3},;
					{"Litros"   , "LITROS" , "N", "@E 9,999.999", 2, 9, 3},;
					{"Qtd.Lib"  , "QTDLIB" , "N", "@E 9,999.999", 2, 9, 3},;
					{"Qtd.Embal", "QTDEMB" , "N", "@E 9,999"    , 2, 4, 0}}

		//oBrowseUP:=FWmBrowse():New()
		oBrowseUP := FWMarkBrowse():New()
		oBrowseUp:SetOwner(oPanelUp)
		oBrowseUP:SetDescription("Liberar para Faturamento")
		oBrowseUP:SetAlias("TRB1")
		oBrowseUp:SetProfileID("1")
		
		oBrowseUp:SetFieldMark("MARCA")
		oBrowseUp:bAllMark := { || MCFG6Invert(oBrowseUp:Mark(),lMarcar := !lMarcar ), oBrowseUp:Refresh(.T.) }
		oBrowseUp:AddMarkColumns({|| fmark()})// função para marcar e desmarcar  

		oBrowseUP:DisableDetails()
		oBrowseUP:DisableLocate()
		oBrowseUP:DisableReport()
		oBrowseUP:SetFields(aColSup)
		oBrowseUp:ForceQuitButton()
		oBrowseUp:SetMenuDef("menudef")
		//-------------------------------------------------------------------------------------------------------*
		//oBrowseUP:AddButton("Liberar"   ,{||U_mfatv2ft(), oBrowseUP:Refresh(), oBrowseDown:Refresh()},,2,,.F.) |
		//-------------------------------------------------------------------------------------------------------*
		oBrowseUP:AddButton("Ver Pedido",{||U_mfatv2ve()},,2,,.F.)
		
		oBrowseUp:AddLegend("LIBER == 'S'", "DISABLE", "Liberado")
		oBrowseUp:AddLegend("ATENDL >= " + Ltrim(Str(MV_PAR06, 3, 0)) + ".AND. ATENDN >= " + Ltrim(Str(MV_PAR07, 3, 0)), "ENABLE"    , "Completo")
		oBrowseUp:AddLegend("ATENDL < "  + Ltrim(Str(MV_PAR06, 3, 0)) + ".OR. ATENDN < "  + Ltrim(Str(MV_PAR07, 3, 0)), "BR_AMARELO", "Incompleto")
		oBrowseUP:Activate()

		TRB2->(DbSetOrder(1))
		oBrowseDown:=FWmBrowse():New()
		oBrowseDown:SetOwner(oPanelDown)
		oBrowseDown:SetDescription("Itens do Pedido de venda")
		oBrowseDown:SetAlias("TRB2")
		oBrowseDown:SetProfileID("2")
		oBrowseDown:DisableDetails()
		oBrowseDown:DisableLocate()
		oBrowseDown:DisableReport()
		oBrowseDown:SetFields(aColInf)
		oBrowseDown:ForceQuitButton()
		oBrowseDown:SetMenuDef("menudef")
		oBrowseDown:AddLegend("QUANT == QTDLIB", "ENABLE" , "Completo")
		oBrowseDown:AddLegend("QUANT != QTDLIB", "BR_AMARELO", "Incompleto")
		oBrowseDown:Activate()

		oRelac:= FWBrwRelation():New()
		oRelac:AddRelation(oBrowseUp, oBrowseDown, {{"IPEDIDO", "PEDIDO"}})
		oRelac:Activate()

		Activate MsDialog oDlgPrinc Center
	Else
		TRB3->(DbCloseArea())
		MsgStop("Não foi encontrado nenhum pedido para liberação, reveja os parametros.", "SEM PEDIDO")
	EndIf

	TRB1->(DbCloseArea())
	TRB2->(DbCloseArea())

	If File("\DATA\" + CNOMEARQC + ".DTC")
		FErase( "\DATA\" + CNOMEARQC + ".DTC" )
		FErase( "\DATA\" + CNOMEARQC + "A.IDX" )
		FErase( "\DATA\" + CNOMEARQC + "B.IDX" )
	EndIf

	If File("\DATA\" + CNOMEARQI + ".DTC")
		FErase( "\DATA\" + CNOMEARQI + ".DTC" )
		FErase( "\DATA\" + CNOMEARQI + "A.IDX" )
	ENDIF

Return

Static Function menudef()
	Private aRotina := {}

Return(aRotina)

User Function mfatv2ve()
	Local cAlias := Alias()

	Private aRotina := {{"Pesquisar"    , "AxPesqui"  , 0, 1, 0,.F.},;
	{"Visualisar PV", "A410Visual", 0, 2, 0, Nil}}
	SC5->(DbSetOrder(1))
	SC6->(DbSetOrder(1))

	SC5->(DbSeek(xFilial("SC5") + TRB1->PEDIDO, .F.))
	SC6->(DbSeek(xFilial("SC6") + TRB1->PEDIDO, .F.))

	DbSelectArea("SC5")
	A410VISUAL("SC5", SC5->(RecNo()), 2)

	aRotina := {}
	DbSelectArea(cAlias)
Return

User Function mfatv2ft()
	Local cAlias := Alias()
	Local lLiber := .F.
	Local nRecTRB1 := TRB1->(RecNo())
	Local nRecTRB2 := TRB2->(RecNo())


	If Empty(TRB1->MARCA)
		Msginfo("Favor selecionar o pedido a liberar", "A T E N Ç Ã O")
		Return
	EndIf 

	If MsgYesNo("Confirma a liberação do(s) pedido(s) com indice de atendimento >= " + Ltrim(Str(MV_PAR06, 3, 0)) + "%", "ATENCAO")
		oBrowseUP:DeActivate()
		oBrowseDown:DeActivate()
		TRB1->(DbGoTop())
		While TRB1->(!Eof())
			If !Empty(TRB1->MARCA)
				If TRB1->LIBER != "S" .and. TRB1->ATENDL >= MV_PAR06 .And. TRB1->ATENDN >= MV_PAR07 
					lLiber := .F.
					DbSelectArea("TRB2")
					DbSeek(TRB1->PEDIDO, .F.)
					While TRB2->(!Eof()) .and. TRB1->PEDIDO == TRB2->IPEDIDO
						If TRB2->QTDLIB > 0
							lLiber := U_mfatv2li(TRB1->PEDIDO, TRB2->ITEM, TRB2->SEQUEN, TRB2->QTDLIB)

							If lLiber
								TRB1->(RecLock("TRB1", .F.))
								TRB1->LIBER := "S"
								TRB1->(MsUnLock())
								//MsgAlert("Pedido de venda liberado", "LIBERADO")
							EndIf

						EndIf
						DbSelectArea("TRB2")
						DbSkip()
					EndDo
				EndIf
			EndIf
			TRB1->(DbSkip())
		EndDo
		oBrowseUP:DeActivate()
		oBrowseDown:DeActivate()
	EndIf

	TRB1->(DbGoTo(nRecTRB1))
	TRB2->(DbGoTo(nRecTRB2))
	DbSelectArea(cAlias)
Return

User Function mfatv2li(cPedido, cItem, cSequen, nQuant)
	Local cAlias  := Alias()
	Local nQtdNew := nQuant
	Local nQtdAnt := 0
	Local nVlrCred:= 0
	Local aLib    := {.T.,.T.,.F.,.F.}
	Local lBlqRes := SuperGetMv("MV_FTRESBL",.F.,.T.)
	Local lLibSld := SuperGetMV("ES_MFAT02A", .F., .F.)  //gera nova liberacao do saldo nao faturado



	SC5->(DbSetOrder(1))
	SC6->(DbSetOrder(1))
	SC9->(DbSetOrder(1))

	SC5->(DbSeek(xFilial("SC5") + cPedido, .F.))
	SC6->(DbSeek(xFilial("SC6") + cPedido + cItem, .F.))
	SC9->(DbSeek(xFilial("SC9") + cPedido + cItem + cSequen, .F.))

	nVlrCred := 0
	nQtdAnt  := Iif(SC9->C9_QTDLIB - nQuant > 0, SC9->C9_QTDLIB - nQuant, 0)  //saldo para nova liberacao, tratativa para residuo.
	// FS|FB Corrigir o valor do crédito liberado para não alterar o preço...
	nVlrCred := SC6->C6_PRCVEN * SC9->C9_QTDLIB

	Begin Transaction
		//ESTORNA LIBERACAO ATUAL
		SC9->(A460Estorna(/*lMata410*/,/*lAtuEmp*/,@nVlrCred))

		  MaLibDoFat(SC6->(RecNo()), @nQtdNew, aLib[1], aLib[2], aLib[3], aLib[4], .F., .F.,/*aEmpenho*/,/*bBlock*/,/*aEmpPronto*/,/*lTrocaLot*/,/*lOkExpedicao*/,nVlrCred,/*nQtdalib2*/)
		//AJUSTA SC9
		SC6->(MaLiberOk({SC9->C9_PEDIDO},.F.))
	End Transaction
	DbSelectArea(cAlias)
Return(.T.)

//PESO DO PEDIDO texto no rodapé
Static function fmark()
	
	LOCAL nPeso :=0
	Local cPeso := ''
	Local aArea := TRB1->(Getarea())
	LOCAL nValor :=0
	Local cValor := ''
	Local nNI := 0

	dbSelectArea("TRB1")
    TRB1->(dbGoTop())
	//aPEDIDOS:={}
	Do While!TRB1->(Eof())
		If !Empty(TRB1->MARCA)
			nPeso += TRB1->PESATE //TRB1->PESPED
			nValor += TRB1->VALATE //TRB1->VALPED
		EndIf 
		 TRB1->(dbSkip())
	EndDo
	
	If !Empty(nPeso)
		cPeso := transform(nPeso,"@E 999,999.99")
		cPeso := alltrim(cPeso)

		cValor := transform(nValor,"@E 999,999.99")
		cValor := alltrim(cValor)
		oSay3:Settext('Peso Selecionado KG: '+cPeso)
		oSay2:Settext('Valor Selecionado R$: '+cValor)

	Else 
		oSay3:Settext('Peso Selecionado KG: '+"0")
		oSay2:Settext('Valor Selecionado R$: '+"0")
	EndIf

Restarea(aArea)
return

//marca e desmarca 
Static Function MCFG6Invert(cMarca,lMarcar)
    Local cAliasSD1 := 'TRB1'
    Local aAreaSD1  := (cAliasSD1)->( GetArea() )

	dbSelectArea(cAliasSD1)
    (cAliasSD1)->( dbGoTop() )

    While !(cAliasSD1)->( Eof() )
        RecLock( (cAliasSD1), .F. )
        (cAliasSD1)->MARCA := IIf( lMarcar, cMarca, '  ' )
        MsUnlock()
        (cAliasSD1)->( dbSkip() )
    EndDo
    RestArea( aAreaSD1 )
Return .T.
