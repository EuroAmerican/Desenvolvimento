#Include "Totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#include "tryexception.ch"

#define ENTER chr(13) + chr(10)
/*/{Protheus.doc}M415GRV
//Ponto de entrada para tratamento OR�AMENTO 
@author QualyCryl 
@since 02/01/2013
@version 1.0
@Hystory Alterado para tratar projeto comiss�es 12/02/2022 - Fabio Carneiro 
@History Ajustado em 09/09/2022 tratamento referente a n�o considerar comiss�o se o item estiver zerado - Fabio carneiro dos Santos
@return Logical, permite ou nao a mudan�a de linha- prs - 04/09/2023 - TESTE

/*/
User Function M415GRV()

Local aArea		 := GetArea()
Local aAreaCK    := SCK->(GetArea())
Local aAreaCJ	 := SCJ->(GetArea())
Local aAreaB1	 := SB1->(GetArea())
Local aAreaA1	 := SA1->(GetArea())
Local aAreaF4	 := SF4->(GetArea())
Local aAreaA3	 := SA3->(GetArea())
Local _cQuery    := ""
Local _cQueryB   := "" 
Local _aLidos    := {}
Local _nLidos    := 0
Local _cGerFin   := "" 
Local _cCodProd  := ""
Local cPgCliente := "" 
Local cRepreClt  := ""
Local cPgvend1   := ""
Local cVend1     := ""
Local dDtaEmis   
Local cNumOrc    := ""
Local _nVlComis1 := 0
Local _nVlTotal  := 0
Local _nPercCli  := 0
Local _nCliente  := 0
Local _nProduto  := 0
Local _nVendedor := 0
Local _cComRev   := ""
Local _cTabCom   := ""
Local _cTipoCom  := ""
Local cFilComis  := GetMv("QE_FILCOM")

dDtaEmis    := SCJ->CJ_EMISSAO                                                             // Data de Emiss�o do Or�amento
cNumOrc     := SCJ->CJ_NUM                                                                 // Numero do Or�amento
cPgCliente  := Posicione("SA1",1,xFilial("SA1")+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA,"A1_XPGCOM")  // 1 = N�o / 2 = N�o
cRepreClt   := Posicione("SA3",1,xFilial("SA3")+SCJ->CJ_VEND1,"A3_XCLT")                   // 1 = N�o / 2 = N�o
cPgvend1    := Posicione("SA3",1,xFilial("SA3")+SCJ->CJ_VEND1,"A3_XPGCOM")                 // 1 = N�o / 2 = N�o
cVend1      := Posicione("SA3",1,xFilial("SA3")+SCJ->CJ_VEND1,"A3_COD")                    // Codigo do vendedor 
_nPercCli   := Posicione("SA1",1,xFilial("SA1")+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA,"A1_XCOMIS1") // Percentual de Comiss�o no Cliente

/*---------------------------------------------------------------------------------------------+
| INICIO    : Projeto Comiss�o especifico QUALY - 31/05/2022 - Fabio Carneiro                  |
+----------------------------------------------------------------------------------------------+
| ALTERA��O : Projeto revisao de Comiss�o especifico QUALY - 24/06/2022 - Fabio Carneiro       |
+----------------------------------------------------------------------------------------------+
| 1 - Quando for incluir ou alterar um or�amento pega a ultima revis�o que estver no cadastro  |
|     de produto contento % de comiss�o, ultima revis�o e tabela;                              |
| 2 - Se a filial estiver preenchida no parametro QE_FILCOM, entra na regra para fazer as      | 
|     devidas valida��es.                                                                      |    
| 3 - Se o produto na PAA estiver com a comiss�o zerada n�o entra na regra para calcular a     | 
|     comiss�o em 09/09/2022 - Fabio carneiro.                                                 |
+----------------------------------------------------------------------------------------------*/
If cfilAnt $ cFilComis

	If Select("WK_SCK") > 0
		WK_SCK->(DbCloseArea())
	EndIf
	/*-------------------------------------------------------------------------+
	| Ser� feito a leitura dos itens do or�amento para as devidas valida��es   | 
	+-------------------------------------------------------------------------*/
	_cQuery := "SELECT * FROM "+RetSqlName("SCK")+" AS SCK WITH (NOLOCK) "+ENTER
	_cQuery += "WHERE CK_FILIAL = '"+xFilial("SCK")+"' "+ENTER
	_cQuery += "AND CK_NUM = '"+cNumOrc+"' "+ENTER
	_cQuery += "AND SCK.D_E_L_E_T_ = ' ' "+ENTER
	_cQuery += "ORDER BY CK_ITEM "+ENTER

	TcQuery _cQuery ALIAS "WK_SCK" NEW

	WK_SCK->(DbGoTop())

	While WK_SCK->(!Eof())

		_cGerFin    := Posicione("SF4",1,xFilial("SF4")+ WK_SCK->CK_TES,"F4_DUPLIC")     // verifica se a Tes gera financeiro
		_cCodProd   := WK_SCK->CK_PRODUTO                                                // Codigo do Produto 
		_cComRev    := Posicione("SB1",1,xFilial("SB1")+WK_SCK->CK_PRODUTO,"B1_XREVCOM") // Ultima revs�o cadastrada na tabela PAA
		_cTabCom    := Posicione("SB1",1,xFilial("SB1")+WK_SCK->CK_PRODUTO,"B1_XTABCOM") // Ultimo codigo de tabela cadastrada na tabela PAA
		_aLidos     := {}  
		_nLidos     := 0
		/*---------------------------------------------------------+
		| Se gera financeiro prossegue as valida��es das comiss�es |    
		+---------------------------------------------------------*/
		If _cGerFin == "S" 
			
			If Select("WK_PAA") > 0
				WK_PAA->(DbCloseArea())
			EndIf

			_cQueryB := "SELECT * FROM "+RetSqlName("PAA")+" AS PAA "
			_cQueryB += "WHERE PAA_FILIAL = '"+xFilial("PAA")+"' ""
			_cQueryB += " AND PAA_COD = '"+AllTrim(_cCodProd)+"'  " 
			_cQueryB += " AND PAA_REV = '"+AllTrim(_cComRev)+"'  " 
			_cQueryB += " AND PAA_CODTAB = '"+AllTrim(_cTabCom)+"'  " 
			_cQueryB += " AND PAA_MSBLQL = '2' " 
			_cQueryB += " AND PAA.D_E_L_E_T_ = ' ' " 
			_cQueryB += " ORDER BY  PAA_DTVIG1, PAA_DTVIG2 " 

			TcQuery _cQueryB ALIAS "WK_PAA" NEW

			WK_PAA->(DbGoTop())

			While WK_PAA->(!Eof())
							
				Aadd(_aLidos,{WK_PAA->PAA_COD,;  // 01
							WK_PAA->PAA_DTVIG1,; // 02
							WK_PAA->PAA_DTVIG2,; // 03
							WK_PAA->PAA_CODTAB,; // 04 
							WK_PAA->PAA_COMIS1,; // 05
							WK_PAA->PAA_REV})    // 06

				WK_PAA->(DbSkip())

			EndDo

			If Len(_aLidos) > 0

				For _nLidos:= 1 To Len(_aLidos) 
					
					_cTipoCom := ""
					/*------------------------------------------------------------------------------------+
					| Se o produto, revis�o e tabela � igual ao que esta na tabela PAA, entra na regra    | 
					+------------------------------------------------------------------------------------*/
					If _aLidos[_nLidos][01] == _cCodProd .And. _cComRev == _aLidos[_nLidos][06] .And. _cTabCom == _aLidos[_nLidos][04]
						DbSelectArea("SCK")
						SCK->(DbSetorder(1))
						If SCK->(MsSeek(xFilial("SCK")+WK_SCK->CK_NUM+WK_SCK->CK_ITEM+WK_SCK->CK_PRODUTO))
							/*----------------------------------------------------------------------------------+
							| Sim e percentual preenchido no cadastro do cliente - Paga comiss�o pelo Cliente   | 
							+----------------------------------------------------------------------------------*/
							If cPgCliente == "2" .And. _nPercCli > 0
								
								If _aLidos[_nLidos][05] > 0
									_nCliente++
									Reclock("SCK",.F.)
									SCK->CK_XTABCOM := _aLidos[_nLidos][04]
									SCK->CK_XCOM1   := _aLidos[_nLidos][05]
									SCK->CK_COMIS1  := _nPercCli
									SCK->CK_XREVCOM := _aLidos[_nLidos][06]
									SCK->CK_XDTRVC  := DDATABASE
									SCK->CK_XTPCOM  := "01" // CLILENTE 
									SCK->(Msunlock())
									_nVlComis1  += Round( (SCK->CK_VALOR * _nPercCli) / 100,2)
									_nVlTotal   += SCK->CK_VALOR
									_cTipoCom   := "01" // CLILENTE
								Else
									Reclock("SCK",.F.)
									SCK->CK_XTABCOM := _aLidos[_nLidos][04]
									SCK->CK_XCOM1   := 0
									SCK->CK_COMIS1  := 0
									SCK->CK_XREVCOM := _aLidos[_nLidos][06]
									SCK->CK_XDTRVC  := DDATABASE
									SCK->CK_XTPCOM  := "01" // CLILENTE 
									SCK->(Msunlock())
									_nVlComis1  += 0
									_nVlTotal   += 0
									_cTipoCom   := "01" // CLILENTE
								EndIf
							/*---------------------------------------------------------+
							|  N�o / Sim / sim  -  Paga comiss�o pelo Produto          | 
							+---------------------------------------------------------*/
							ElseIf cRepreClt == "1" .And. cPgCliente == "2" .And. cPgvend1 == "2" .And.  _nPercCli <= 0

								If Posicione("SB1",1, xFilial("SB1")+WK_SCK->CK_PRODUTO,"B1_COMIS") == _aLidos[_nLidos][05] 

									If _aLidos[_nLidos][05] > 0
										_nProduto++
										Reclock("SCK",.F.)
										SCK->CK_XTABCOM := _aLidos[_nLidos][04]
										SCK->CK_XCOM1   := _aLidos[_nLidos][05]
										SCK->CK_COMIS1  := Posicione("SB1",1, xFilial("SB1")+_cCodProd,"B1_COMIS")
										SCK->CK_XREVCOM := _aLidos[_nLidos][06]
										SCK->CK_XDTRVC  := DDATABASE
										SCK->CK_XTPCOM  := "02" // PRODUTO 
										SCK->(Msunlock())
										_nVlComis1  += Round( (SCK->CK_VALOR * Posicione("SB1",1, xFilial("SB1")+_cCodProd,"B1_COMIS")) / 100,2)
										_nVlTotal   += SCK->CK_VALOR
										_cTipoCom   := "02" // PRODUTO
									Else 
										Reclock("SCK",.F.)
										SCK->CK_XTABCOM := _aLidos[_nLidos][04]
										SCK->CK_XCOM1   := 0
										SCK->CK_COMIS1  := 0
										SCK->CK_XREVCOM := _aLidos[_nLidos][06]
										SCK->CK_XDTRVC  := DDATABASE
										SCK->CK_XTPCOM  := "02" // PRODUTO 
										SCK->(Msunlock())
										_nVlComis1  += 0
										_nVlTotal   += 0
										_cTipoCom   := "02" // PRODUTO
									EndIf

								EndIf
							/*--------------------------------------------------------------+
							| Sim / Sim / sim -  paga comiss�o pelo percentual do vendedor  |           
							+--------------------------------------------------------------*/
							ElseIf cRepreClt == "2" .And. cPgCliente == "2" .And. cPgvend1 == "2" .And.  _nPercCli <= 0
											
								If  _aLidos[_nLidos][05] > 0
									_nVendedor++ 
									Reclock("SCK",.F.)
									SCK->CK_XTABCOM := _aLidos[_nLidos][04]
									SCK->CK_XCOM1   := _aLidos[_nLidos][05]
									SCK->CK_COMIS1  := Posicione("SA3",1, xFilial("SA3+")+cVend1,"A3_COMIS")
									SCK->CK_XREVCOM := _aLidos[_nLidos][06]
									SCK->CK_XDTRVC  := DDATABASE
									SCK->CK_XTPCOM  := "03" // VENDEDOR 
									SCK->(Msunlock())
									_nVlComis1  := Posicione("SA3",1, xFilial("SA3+")+cVend1,"A3_COMIS")
									_cTipoCom   := "03" // VENDEDOR
								Else 
									Reclock("SCK",.F.)
									SCK->CK_XTABCOM := _aLidos[_nLidos][04]
									SCK->CK_XCOM1   := 0
									SCK->CK_COMIS1  := 0
									SCK->CK_XREVCOM := _aLidos[_nLidos][06]
									SCK->CK_XDTRVC  := DDATABASE
									SCK->CK_XTPCOM  := "03" // VENDEDOR 
									SCK->(Msunlock())
									_nVlComis1  += 0
									_cTipoCom   := "03" // VENDEDOR
								EndIf
							/*--------------------------------------------------------------+
							| N�o paga comiss�o                                             |
							+--------------------------------------------------------------*/
							Else
								Reclock("SCK",.F.)
								SCK->CK_XTABCOM := _aLidos[_nLidos][04]
								SCK->CK_XCOM1   := _aLidos[_nLidos][05]
								SCK->CK_COMIS1  := 0
								SCK->CK_XREVCOM := _aLidos[_nLidos][06]
								SCK->CK_XDTRVC  := DDATABASE
								SCK->CK_XTPCOM  := "04" // COMISS�O ZERADA 
								SCK->(Msunlock())
								_nVlComis1  += 0
								_nVlTotal   += 0
								_cTipoCom   := "04" // COMISS�O ZERADA
							EndIf

						EndIf

					Else 

						DbSelectArea("SCK")
						SCK->(DbSetorder(1))
						If SCK->(MsSeek(xFilial("SCK")+WK_SCK->CK_NUM+WK_SCK->CK_ITEM+WK_SCK->CK_PRODUTO))
							Reclock("SCK",.F.)
							SCK->CK_XTABCOM := _aLidos[_nLidos][04]
							SCK->CK_XCOM1   := _aLidos[_nLidos][05]
							SCK->CK_COMIS1  := 0
							SCK->CK_XREVCOM := _aLidos[_nLidos][06]
							SCK->CK_XDTRVC  := DDATABASE
							SCK->CK_XTPCOM  := "04" // COMISS�O ZERADA 
							SCK->(Msunlock())
							_nVlComis1  += 0
							_nVlTotal   += 0
							_cTipoCom   := "04" // COMISS�O ZERADA
							
						EndIf	
						
					EndIf	

				Next _nLidos 	
			
			EndIf

		EndIf	
		
		WK_SCK->(dbSkip())

	EndDo
	/*---------------------------------------------------------------------------------+
	| Ser� gravado no cabe�alho do or�amento os tipos e os percentuais de comiss�o     |
	+---------------------------------------------------------------------------------*/
	DbSelectArea("SCJ")
	SCJ->(DbSetorder(1))
	If SCJ->(MsSeek(xFilial("SCJ")+cNumOrc))
		/*----------------------------------------------------------------------------------+
		| Sim e percentual preenchido no cadastro do cliente - Paga comiss�o pelo Cliente   | 
		+----------------------------------------------------------------------------------*/
		If cPgCliente == "2" .And. _nPercCli > 0  
		   If _nCliente > 0
				RecLock('SCJ',.F.)
				SCJ->CJ_COMIS1  := _nPercCli
				SCJ->CJ_XTPCOM  := _cTipoCom 
				SCJ->( MsUnlock() )
			Else 
				RecLock('SCJ',.F.)
				SCJ->CJ_COMIS1  := 0
				SCJ->CJ_XTPCOM  := _cTipoCom 
				SCJ->( MsUnlock() )
			EndIf
		/*---------------------------------------------------------+
		|  N�o / Sim / sim  -  Paga comiss�o pelo Produto          | 
		+---------------------------------------------------------*/
		ElseIf cRepreClt == "1" .And. cPgCliente == "2" .And. cPgvend1 == "2" .And. _nPercCli <= 0 
			If _nProduto > 0
				RecLock('SCJ',.F.)
				SCJ->CJ_COMIS1  := Round(((_nVlComis1 / _nVlTotal) * 100),2)
				SCJ->CJ_XTPCOM  := _cTipoCom 
				SCJ->( MsUnlock() )
			Else 
				RecLock('SCJ',.F.)
				SCJ->CJ_COMIS1  := 0
				SCJ->CJ_XTPCOM  := _cTipoCom 
				SCJ->( MsUnlock() )
			EndIf
		/*--------------------------------------------------------------+
		| Sim / Sim / sim -  paga comiss�o pelo percentual do vendedor  |           
		+--------------------------------------------------------------*/
		ElseIf cRepreClt == "2" .And. cPgCliente == "2" .And. cPgvend1 == "2" .And. _nPercCli <= 0
			If _nVendedor > 0
				RecLock('SCJ',.F.)
				SCJ->CJ_COMIS1  := _nVlComis1
				SCJ->CJ_XTPCOM  := _cTipoCom 
				SCJ->( MsUnlock() )
			Else 
				RecLock('SCJ',.F.)
				SCJ->CJ_COMIS1  := 0
				SCJ->CJ_XTPCOM  := _cTipoCom 
				SCJ->( MsUnlock() )
			EndIf
		/*--------------------------------------------------------------+
		| N�o paga comiss�o                                             |
		+--------------------------------------------------------------*/
		Else 
			RecLock('SCJ',.F.)
			SCJ->CJ_COMIS1  := 0
			SCJ->CJ_XTPCOM  := _cTipoCom 
			SCJ->( MsUnlock() )
		EndIf 
	
	EndIf

EndIf
_nCliente  := 0
_nProduto  := 0
_nVendedor := 0
//FIM 
If Select("WK_SCK") > 0
	WK_SCK->(DbCloseArea())
EndIf
If Select("WK_PAA") > 0
	WK_PAA->(DbCloseArea())
EndIf
RestArea(aAreaCK)
RestArea(aAreaCJ)
RestArea(aAreaB1)
RestArea(aAreaA1)
RestArea(aAreaF4)
RestArea(aAreaA3)
RestArea(aArea)

Return
