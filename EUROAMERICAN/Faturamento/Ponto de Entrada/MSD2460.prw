#include "rwmake.ch"
#include "topconn.ch"        
#include "tbiconn.ch"   
#include "protheus.ch"             

#define ENTER chr(13) + chr(10)  
/*/{Protheus.doc} MSD2460
Foi feito tratativa para gravar os pesos  dos pedidos liberados parcialmente
@type function Ponto de entrada
@version  1.00
@author Emerson Paiva / modificado por Fabio Carneiro e Mario Angelo
@since 25/05/2021
@History  Alterado o pornto de entrada para tratamento da unidade de medida de expedição - 01/02/2022 - Fabio Carneiro dos Santos 
@History  Alterado o ponto de entrada para o projeto comissão qualy - fabio carneiro - 23/02/2022 - Fabio Carneiro dos Santos 
@History Ajustado em 09/09/2022 tratamento referente a não considerar comissão se o item estiver zerado - Fabio carneiro dos Santos
@return  character, sem retorno especifico
/*/

User Function MSD2460()  

Local aArea          := GetArea()
Local aAreaSB1       := SB1->(GetArea())
Local aAreaSA1       := SA1->(GetArea())
Local aAreaSA2       := SA2->(GetArea())
Local aAreaSF4       := SF4->(GetArea())
Local aAreaSD2       := SD2->(GetArea())
Local aAreaSF2       := SF2->(GetArea())
Local aAreaSC6       := SC6->(GetArea())
Local aAreaSC5       := SC5->(GetArea())
Local aAreaSC9       := SC9->(GetArea())
Local aAreaSE1       := SE1->(GetArea())
Local aAreaSE2       := SE2->(GetArea())
Local aAreaEE7       := EE7->(GetArea())
Local aAreaEE8       := EE8->(GetArea())
Local aAreaSB2       := SB2->(GetArea())
Local aAreaSB8       := SB8->(GetArea())
Local aAreaSBF       := SBF->(GetArea())
Local aAreaSD5       := SD5->(GetArea())
Local aAreaSDB       := SDB->(GetArea())
Local aAreaSFT       := SFT->(GetArea())
Local aAreaSF3       := SF3->(GetArea())
Local aAreaCD2       := CD2->(GetArea())
Local aAreas         := {aArea,aAreaSB1,aAreaSA1,aAreaSA2,aAreaSF4,aAreaSD2,aAreaSF2,aAreaSC6,aAreaSC5,aAreaSC9,aAreaSE1,aAreaSE2,;
						 aAreaEE7,aAreaEE8,aAreaSB2,aAreaSB8,aAreaSBF,aAreaSD5,aAreaSDB,aAreaSFT,aAreaSF3,aAreaCD2}
Local _nQtdVenda     := 0
Local _nVal          := 0
Local _nRetMod       := 0
Local _nQtdVol       := 0 
Local _nDifVol       := 0
Local _cUnExpedicao  := Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_XUNEXP")
Local _nQtdMinima    := Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_XQTDEXP") 
Local _nPesoBruto    := Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_PESBRU") 
Local _nPesoLiquido  := Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_PESO") 

//Variaveis projeto comissão qualy - fabio carneiro - 23/02/2022

Local _cGerFin   := "" 
Local _cTipoNota := ""
Local _cCodProd  := ""
Local cPgCliente := ""
Local cRepreClt  := ""
Local cPgvend1   := ""
Local cVend1     := ""
Local cPedido    := ""
Local _nPercCli  := 0
Local cFilComis  := GetMv("QE_FILCOM")

// Variaveis referente ao tratamento revisão de comissão - 04/07/2022
Local _cRev      := ""
Local _cTabCom   := ""
Local _aLidos    := {}
Local _nLidos    := 0
Local _cQuery    := ""
Local _cLocal    := ""
Local _cNumSeq   := ""
Local _cTes      := Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_DUPLIC")
	
/*
+------------------------------------------------------------------+
| Projeto unidade de expedição - 01/02/2022 - Fabio Carneiro       |
+------------------------------------------------------------------+
*/
// Calculo referente ao multiplo de embalagens 
If SD2->D2_TIPO $ "N/D/B" .And. !Empty(_cUnExpedicao) .And. _nQtdMinima > 0

	_nRetMod            := MOD(SD2->D2_QUANT,_nQtdMinima)
	_nQtdVenda          := (SD2->D2_QUANT -_nRetMod)
	_nVal               := (_nQtdVenda / _nQtdMinima)
	_nQtdVol            := _nVal * _nQtdMinima 
	_nDifVol            := SD2->D2_QUANT-_nQtdVol

	DbSelectArea("SD2")
	SD2->(DbSetOrder(3))
	If SD2->(dbSeek(xFilial("SD2") + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA + SD2->D2_COD + SD2->D2_ITEM))

		RecLock("SD2",.F.)

		SD2->D2_XUNEXP  := _cUnExpedicao
		SD2->D2_XCLEXP  := _nVal
		SD2->D2_XMINEMB := _nQtdMinima
		SD2->D2_XQTDVOL := _nQtdVol
		SD2->D2_XDIFVOL := _nDifVol  
		SD2->D2_XPESBUT := (SD2->D2_QUANT * _nPesoBruto)
		SD2->D2_XPESLIQ := (SD2->D2_QUANT * _nPesoLiquido)
		SD2->D2_XPBRU   := _nPesoBruto
		SD2->D2_XPLIQ   := _nPesoLiquido
		SD2->D2_CUSTD   := SB1->B1_CUSTD
		SD2->D2_CUSTNET := SB1->B1_CUSTNET
		SD2->D2_FCICOD  := SC6->C6_FCICOD

		SD2->(MsUnlock())

	EndIf

EndIf
/*---------------------------------------------------------------------------------------------+
| INICIO    : Projeto Comissão especifico QUALY - 31/05/2022 - Fabio Carneiro                  |
+----------------------------------------------------------------------------------------------+
| ALTERAÇÃO : Projeto revisao de Comissão especifico QUALY - 24/06/2022 - Fabio Carneiro       |
+----------------------------------------------------------------------------------------------+
| 1 - Se o pedido de vendas for Normal e a filial estiver preenchida no parametro QE_FILCOM,   | 
| entra na regra para fazer as devidas validações.                                             |
| 2 - Será gravado os pecentuais do pedido de vendas conforme liberação realizada.             |      
| 3 - Se o produto na PAA estiver com a comissão zerada não entra na regra para calcular a     | 
|     comissão em 09/09/2022 - Fabio carneiro.                                                 |
+----------------------------------------------------------------------------------------------*/
If cfilAnt $ cFilComis .And. _cTes = "S"

	_aLidos     := {}
	_cQuery     := "" 	
	
	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf

	_cQuery := "SELECT C6_FILIAL, C6_PRODUTO, C6_XTABCOM, C6_XREVCOM, C6_XDTRVC, C6_XTPCOM, C6_COMIS1, C6_XCOM1, D2_TES, D2_COD,  "+ENTER
	_cQuery += " D2_TIPO, D2_CLIENTE, D2_LOJA, D2_PEDIDO, F4_DUPLIC, D2_QUANT, D2_PRCVEN, D2_TOTAL, A1_COD, A1_LOJA, A1_XPGCOM,  "+ENTER  
	_cQuery += " A1_XCOMIS1, D2_LOCAL, D2_NUMSEQ "+ENTER
	_cQuery += "FROM "+RetSqlName("SC6")+" AS SC6 WITH (NOLOCK) "+ENTER
	_cQuery += "INNER JOIN "+RetSqlName("SF4")+" AS SF4 WITH (NOLOCK) ON F4_FILIAL = SUBSTRING(C6_FILIAL,1,2) "+ENTER
	_cQuery += " AND F4_CODIGO = C6_TES "+ENTER
	_cQuery += " AND SF4.D_E_L_E_T_ = ' ' "+ENTER
	_cQuery += "INNER JOIN "+RetSqlName("SD2")+" AS SD2 WITH (NOLOCK) ON D2_FILIAL = C6_FILIAL"+ENTER
	_cQuery += " AND C6_PRODUTO = D2_COD  "+ENTER 
	_cQuery += " AND C6_NUM  = D2_PEDIDO  "+ENTER 
	_cQuery += " AND C6_CLI  = D2_CLIENTE "+ENTER 
	_cQuery += " AND C6_LOJA = D2_LOJA    "+ENTER 
	_cQuery += " AND SD2.D_E_L_E_T_ = ' ' "+ENTER 
	_cQuery += "INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH (NOLOCK) ON D2_FILIAL = A1_FILIAL"+ENTER
	_cQuery += " AND A1_COD  = D2_CLIENTE "+ENTER 
	_cQuery += " AND A1_LOJA = D2_LOJA    "+ENTER 
	_cQuery += " AND SA1.D_E_L_E_T_ = ' ' "+ENTER 
	_cQuery += "WHERE C6_FILIAL  = '"+xFilial("SC6")+"' "+ENTER
	_cQuery += " AND C6_PRODUTO = '"+AllTrim(SD2->D2_COD)+"' "+ENTER 
	_cQuery += " AND C6_NUM  = '"+AllTrim(SD2->D2_PEDIDO)+"' "+ENTER 
	_cQuery += " AND C6_CLI  = '"+AllTrim(SD2->D2_CLIENTE)+"' "+ENTER 
	_cQuery += " AND C6_LOJA = '"+AllTrim(SD2->D2_LOJA)+"' "+ENTER 
   	_cQuery += " AND F4_DUPLIC = 'S'  "+ENTER 
	_cQuery += " AND SC6.D_E_L_E_T_ = ' '  "+ENTER 
	_cQuery += "GROUP BY C6_FILIAL, C6_PRODUTO, C6_XTABCOM, C6_XREVCOM, C6_XDTRVC, C6_XTPCOM, C6_COMIS1, C6_XCOM1, D2_TES, D2_COD,  "+ENTER
	_cQuery += " D2_TIPO, D2_CLIENTE, D2_LOJA, D2_PEDIDO, F4_DUPLIC, D2_QUANT, D2_PRCVEN, D2_TOTAL, A1_COD, A1_LOJA, A1_XPGCOM,  "+ENTER  
	_cQuery += " A1_XCOMIS1, D2_LOCAL, D2_NUMSEQ "+ENTER
	_cQuery += "ORDER BY C6_PRODUTO "+ENTER 

	TcQuery _cQuery ALIAS "TRB1" NEW

	TRB1->(DbGoTop())

	While TRB1->(!Eof())
				
		If TRB1->D2_COD == SD2->D2_COD 
			
			cPedido     := Posicione("SC5",1,xFilial("SC5")+TRB1->D2_PEDIDO,"C5_VEND1") 
			cRepreClt   := Posicione("SA3",1,xFilial("SA3")+cPedido,"A3_XCLT")  
			cPgvend1    := Posicione("SA3",1,xFilial("SA3")+cPedido,"A3_XPGCOM")
			cVend1      := Posicione("SA3",1,xFilial("SA3")+cPedido,"A3_COD") 
			
			Aadd(_aLidos,{TRB1->C6_PRODUTO,;    // 01
						  TRB1->C6_XTABCOM,;    // 02 
						  TRB1->C6_XREVCOM,;    // 03
						  TRB1->C6_XDTRVC,;     // 04 
						  TRB1->C6_COMIS1,;     // 05
  						  TRB1->D2_TES,;        // 06
						  TRB1->D2_COD,;        // 07
						  TRB1->D2_TIPO,;       // 08
						  TRB1->D2_CLIENTE,;    // 09
						  TRB1->D2_LOJA,;       // 10
						  TRB1->D2_PEDIDO,;     // 11
						  TRB1->F4_DUPLIC,;     // 12
						  TRB1->A1_XPGCOM,;     // 13
						  TRB1->A1_XCOMIS1,;    // 14
						  cRepreClt,;           // 15 
						  cPgvend1,;            // 16
						  cVend1,;              // 17 
						  TRB1->D2_LOCAL,;      // 18
						  TRB1->D2_NUMSEQ,;     // 19
						  TRB1->C6_XTPCOM,;     // 20
						  TRB1->C6_XCOM1})      // 21
		EndIf

		TRB1->(DbSkip())

	EndDo

	If Len(_aLidos) > 0

		For _nLidos:= 1 To Len(_aLidos) 
	
			_cGerFin    := ""
			_cCodProd   := ""
			_cLocal     := ""
			_cNumSeq    := ""
			_cTipoNota  := ""
			cPgCliente  := ""
			cRepreClt   := ""
			cPgvend1    := ""
			cVend1      := ""
			_nPercCli   := 0
			_cRev       := ""
			_cTabCom    := ""

			_cGerFin    := Posicione("SF4",1,xFilial("SF4")+_aLidos[_nLidos][06],"F4_DUPLIC") // Tes que gera financeiro 
			_cCodProd   := _aLidos[_nLidos][07] // Codigo do produto 
			_cLocal     := _aLidos[_nLidos][18] // Codigo do Armazen  
			_cNumSeq    := _aLidos[_nLidos][19] // Sequencia   
			_cTipoNota  := _aLidos[_nLidos][08] // Tipo de nota fiscal  
			cPgCliente  := _aLidos[_nLidos][13] // Cliente paga comissão Sim / Não  
			cRepreClt   := _aLidos[_nLidos][15] // Paga Comissão pelo cadastro do vendedor 
			cPgvend1    := _aLidos[_nLidos][16] // Vendedor recebe Comissão Sim / Não 
			cVend1      := _aLidos[_nLidos][17] // Codigo do Vendedor 
			_nPercCli   := _aLidos[_nLidos][14] // Percentual preenchido no cadastro do cliente 
			_cRev       := _aLidos[_nLidos][03] // Revisão da Comissão no pedido de vendas 
			_cTabCom    := _aLidos[_nLidos][02] // Tabela que foi cadastrada no pedido de vendas 
			/*------------------------------------------+
			| Se gera financeiro e o tipo for normal    | 
			+------------------------------------------*/
			If _cGerFin == "S" .And. _cTipoNota == "N"
								
				DbSelectArea("SD2")
				SD2->(DbSetorder(1)) // D2_FILIAL+D2_COD+D2_LOCAL+D2_NUMSEQ
				If SD2->(MsSeek(xFilial("SD2")+_cCodProd+_cLocal+_cNumSeq))
					/*----------------------------------------------------------------------------------+
					| Sim e percentual preenchido no cadastro do cliente - Paga comissão pelo Cliente   | 
					+----------------------------------------------------------------------------------*/
					If cPgCliente == "2" .And. _nPercCli > 0
						/*-------------------------------------------------------------------------------------+
						| Se no item do pedido esta preenchido com o percentual de comissão, entra na regra    | 
						+-------------------------------------------------------------------------------------*/
						If _aLidos[_nLidos][05] > 0

							Reclock("SD2",.F.)
							SD2->D2_XTABCOM := _aLidos[_nLidos][02]
							SD2->D2_XCOM1   := _aLidos[_nLidos][05]
							SD2->D2_COMIS1  := _nPercCli
							SD2->D2_COMIS2  := 0
							SD2->D2_COMIS3  := 0
							SD2->D2_COMIS4  := 0
							SD2->D2_COMIS5  := 0
							SD2->D2_XREVCOM := _aLidos[_nLidos][03]
							SD2->D2_XDTRVC  := StoD(_aLidos[_nLidos][04])
							SD2->D2_XTPCOM  := "01" // CLIENTE
							SD2->(Msunlock())
						
						Else
							
							Reclock("SD2",.F.)
							SD2->D2_XTABCOM := _aLidos[_nLidos][02]
							SD2->D2_XCOM1   := 0
							SD2->D2_COMIS1  := 0
							SD2->D2_COMIS2  := 0
							SD2->D2_COMIS3  := 0
							SD2->D2_COMIS4  := 0
							SD2->D2_COMIS5  := 0
							SD2->D2_XREVCOM := _aLidos[_nLidos][03]
							SD2->D2_XDTRVC  := StoD(_aLidos[_nLidos][04])
							SD2->D2_XTPCOM  := "01" // cliente com a comissão Zerada
							SD2->(Msunlock())
						
						EndIf					
					/*---------------------------------------------------------+
					|  Não / Sim / sim  -  Paga comissão pelo Produto          | 
					+---------------------------------------------------------*/
					ElseIf cRepreClt == "1" .And. cPgCliente == "2" .And. cPgvend1 == "2" .And. _nPercCli <= 0
							
						Reclock("SD2",.F.)
						SD2->D2_XTABCOM := _aLidos[_nLidos][02]
						SD2->D2_XCOM1   := _aLidos[_nLidos][21]
						SD2->D2_COMIS1  := _aLidos[_nLidos][05]
						SD2->D2_COMIS2  :=  0
						SD2->D2_COMIS3  :=  0
						SD2->D2_COMIS4  :=  0
						SD2->D2_COMIS5  :=  0
						SD2->D2_XREVCOM := _aLidos[_nLidos][03]
						SD2->D2_XDTRVC  := StoD(_aLidos[_nLidos][04])
						SD2->D2_XTPCOM  := "02" // PRODUTO

						SD2->(Msunlock())

					/*--------------------------------------------------------------+
					| Sim / Sim / sim -  paga comissão pelo percentual do vendedor  |           
					+--------------------------------------------------------------*/
					ElseIf cRepreClt == "2" .And. cPgCliente == "2" .And. cPgvend1 == "2" .And. _nPercCli <= 0
											
						If _aLidos[_nLidos][05] > 0
						
							Reclock("SD2",.F.)
							SD2->D2_XTABCOM := _aLidos[_nLidos][02]
							SD2->D2_XCOM1   := _aLidos[_nLidos][05]
							SD2->D2_COMIS1  := Posicione("SA3",1, xFilial("SA3")+cVend1,"A3_COMIS")
							SD2->D2_COMIS2  :=  0
							SD2->D2_COMIS3  :=  0
							SD2->D2_COMIS4  :=  0
							SD2->D2_COMIS5  :=  0
							SD2->D2_XREVCOM := _aLidos[_nLidos][03]
							SD2->D2_XDTRVC  := StoD(_aLidos[_nLidos][04])
							SD2->D2_XTPCOM  := "03" // VENDEDOR
							SD2->(Msunlock())
						
						Else
						
							Reclock("SD2",.F.)
							SD2->D2_XTABCOM := _aLidos[_nLidos][02]
							SD2->D2_XCOM1   :=  0
							SD2->D2_COMIS1  :=  0
							SD2->D2_COMIS2  :=  0
							SD2->D2_COMIS3  :=  0
							SD2->D2_COMIS4  :=  0
							SD2->D2_COMIS5  :=  0
							SD2->D2_XREVCOM := _aLidos[_nLidos][03]
							SD2->D2_XDTRVC  := StoD(_aLidos[_nLidos][04])
							SD2->D2_XTPCOM  := "03" // vendedor com comissão Zerada
							SD2->(Msunlock())

						EndIf
					/*------------------------+
					| Não paga comissão       |
					+------------------------*/
					Else

						Reclock("SD2",.F.)
						SD2->D2_XTABCOM := _aLidos[_nLidos][02]
						SD2->D2_XCOM1   := _aLidos[_nLidos][05]
						SD2->D2_COMIS1  :=  0
						SD2->D2_COMIS2  :=  0
						SD2->D2_COMIS3  :=  0
						SD2->D2_COMIS4  :=  0
						SD2->D2_COMIS5  :=  0
						SD2->D2_XREVCOM := _aLidos[_nLidos][03]
						SD2->D2_XDTRVC  := StoD(_aLidos[_nLidos][04])
						SD2->D2_XTPCOM  := "04" // ZERADA
						SD2->(Msunlock())
										
					EndIf
					
				EndIf
											
			EndIf

		Next _nLidos 
	
	Endif					

Endif 

//Fim Tratamento Comissão Qualy

AEval(aAreas, {|uArea| RestArea(uArea)})

Return( Nil )
