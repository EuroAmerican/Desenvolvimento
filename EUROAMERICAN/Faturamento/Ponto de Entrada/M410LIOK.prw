#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#include "tryexception.ch"
#include "totvs.ch"

#DEFINE ENTER chr(13) + chr(10)

// Este programa não estava no projeto, verificar o motivo depois... Adicionado Validação de OS na alteração do PV...

/*/{Protheus.doc} M410LIOK
Ponto de Entrada de validação da linha do Pedido de Venda 
@type function Ponto de Entrada.
@version  1.00
@author Fabio Sousa - Alterado por Mario 
@since 19/08/2019 - alterado em 08/09/2021
@History Ajustado fonte para tratar a comissão Qualy e unidade de expedição - 01/03/2022 - Fabio Carneiro
@History Ajustado fonte para tratar a revisao de comissão Qualy - 24/06/2022 - Fabio Carneiro
@History Ajustado em 04/07/2022 tratamento referente ao peso liquido e peso bruto - Fabio carneiro dos Santos 
@History Ajustado em 09/09/2022 tratamento referente a não considerar comissão se o item estiver zerado - Fabio carneiro dos Santos
@return Logical, permite ou nao a mudança de linha
/*/
User Function M410LIOK()

Local _lRet		    := .T.
Local _aAreaSB1     := SB1->( GetArea() )
Local _aAreaSA1     := SA1->( GetArea() )
Local _aAreaSA2     := SA1->( GetArea() )
Local _aAreaSC5     := SC5->( GetArea() )
Local _aAreaSC6     := SC6->( GetArea() )
Local _aAreaSC9     := SC9->( GetArea() )
Local _aAreaEE7     := EE7->( GetArea() )
Local _aAreaEE8     := EE8->( GetArea() )
Local _aArea        := GetArea()
// Variaveis unidade de expedição 
Local _nQtdMinima   := 0 
Local _nQtdVenda    := 0
Local _nRetMod      := 0
Local _nQtdeEmb     := 0
Local _cUnExpedicao := 0
Local _cDescProduto := "" 
Local _cUnidMedida  := ""
Local _cMsg         := ""
Local _cMsgA        := ""
Local _cC5XOPER     := SuperGetMv("QE_XOPER",.F.,"01/06/56")
Local cFilComis     := GetMv("QE_FILCOM")
Local nPosGrpEsp    := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_XGRPESP"      })
Local nPosTotPrd    := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_XQTDPRO"      })
// Variaveis projeto comissão - 23/02/2022
Local _nComissao    := 0
Local _cQueryA    	:= ""
Local _cQueryB  	:= ""
Local _cQueryC    	:= ""
Local _aLidos   	:= {}
Local _nLidos   	:= 0
Local _nPercCli     := 0
Local nPosQtdVen    := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_QTDVEN"       })
Local nPosPrcVen    := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_PRCVEN"       })
Local nPosProduto   := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_PRODUTO"      })
Local nPosTes     	:= aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_TES"          })
Local nPosTab    	:= aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_XTABCOM"      })
Local nPosCom1    	:= aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_XCOM1"        })
Local nPosComis1  	:= aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_COMIS1"       })
Local nPosComis2  	:= aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_COMIS2"       })
Local nPosComis3  	:= aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_COMIS3"       })
Local nPosComis4  	:= aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_COMIS4"       })
Local nPosComis5  	:= aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_COMIS5"       })
// Tratamento para Revisao de comissão em 24/06/2022 
Local _cUsrLibCom   := SuperGetMv("QE_XLIBCOM",.F.,"Alessandra.Monea#Thiago.Monea#Caroline.Monea#Administrador#eulalia.ramos#eristeu.junior") 
Local nPosRevCom  	:= aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_XREVCOM"      })
Local nPosDtRvc    	:= aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_XDTRVC"       })
Local nPosTpcom    	:= aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_XTPCOM"       })
Local nPosItem    	:= aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_ITEM"         })
Local _cComRev      := ""
Local _cTabCom      := ""
Local _cTipoProd    := "" 
Local _aLePAW   	:= {}
Local _nLePAW   	:= 0
Local _aLePW    	:= {}
Local _nLePW    	:= 0
//Local _nler         := 0
//variaveis projeto comissão qualy - fabio carneiro - 23/02/2022
Local cPgCliente    := ""
Local cRepreClt     := ""
Local cPgvend1      := ""
Local cVend1        := ""
// Tratamento do peso liquido e peso bruto 01/07/2022 - Fabio Carneiro 
Local _nPesoLiq     := 0
Local _nPesoBru     := 0

//³Valida Custo com Preço de Venda...			³

If _lRet
	//lRet := BeVldCusto() // Não validar agora, ver o motivo do programa não estava no projeto depois.
EndIf

// Validar se pedido e item possuem OS registradas na alteração...
If _lRet
	//lRet := fVldOrdSep()
EndIf

// Validar se produto possui NCM 
If _lRet
	_lRet := fVldNCM()
EndIf

// Validar produto especial - PROJETO : Tratativa de produtos especiais para controlar producao x pedido de vendas
If _lRet 

	If aCols[n,nPosGrpEsp] $  GETMV("QE_GRPPRES") .and.  aCols[n,nPosTotPrd] == 0
		ApMsgInfo("Este Produto é ESPECIAL!"+CRLF+"Somente podera ser alterado o pedido de vendas"+CRLF+"Apos o TERMINO do apontamento da Ordem de Producao","Produtos Especiais")
	EndIf
End

// Projeto : Unidade de medida alternativa 
// Alerta para validar se a quandidade do pedido esta repeitando a quandidade mimina de embalagem.   

If _lRet 

	If M->C5_TIPO $ "N/D/B"

		// Tratamento referente ao peso liquido e peso bruto - 01/07/2022

		_nPesoLiq   := Posicione("SB1",1,xFilial("SB1")+aCols[n,nPosProduto],"B1_PESO") 
		_nPesoBru   := Posicione("SB1",1,xFilial("SB1")+aCols[n,nPosProduto],"B1_PESBRU") 

		If aCols[n,nPosQtdVen] > 0

			If _nPesoLiq <= 0 .Or. _nPesoBru <= 0

				_cMsg := "Este produto está com o PESO LIQUIDO e PESO BRUTO do produto "+Alltrim(aCols[n,nPosProduto])+" ,sem preenchimento no cadastro de produtos!"+ENTER
				_cMsg += "Somente ápos o preenchimento no cadastro será possivel prosseguir com o pedido de vendas ! "+ENTER

				Aviso("Atencão - M410LIOK ",_cMsg, {"Ok"}, 2)
					
				_lRet := .F.

			EndIf
			
		EndIf

		If M->C5_XOPER $ _cC5XOPER

			_cUnExpedicao    := Posicione("SB1",1,xFilial("SB1")+aCols[n,nPosProduto],"B1_XUNEXP")
			_nQtdMinima      := Posicione("SB1",1,xFilial("SB1")+aCols[n,nPosProduto],"B1_XQTDEXP") 
			_cDescProduto    := Posicione("SB1",1,xFilial("SB1")+aCols[n,nPosProduto],"B1_DESC") 
			_cUnidMedida     := Posicione("SB1",1,xFilial("SB1")+aCols[n,nPosProduto],"B1_UM") 

			If !Empty(_cUnExpedicao) .And. _nQtdMinima > 0

				_nRetMod         := MOD(aCols[n,nPosQtdVen],_nQtdMinima)
				_nQtdVenda       := (aCols[n,nPosQtdVen]-_nRetMod)
				_nQtdeEmb        := (_nQtdVenda/_nQtdMinima)

			EndIf 

			If Empty(_cUnExpedicao) .Or. _nQtdMinima == 0

				_cMsgA := "Este produto "+Alltrim(aCols[n,nPosProduto])+" está sem unidade de expedição(B1_XUNEXP) e a quantidade minima de embalagem(B1_XQTDEXP) no cadastro do produto  "+ ENTER
				_cMsgA += "Verificar com os responsaveis da EXPEDIÇÃO, LABORATORIO e OPERAÇÕES para fazer o preenchimento correto destas informações." + ENTER
				_cMsgA += "Será necessario clicar no botão cancelar e após o cadastro preenchido poderá incluir ou alterar o pedido novamente !!!"
				_cMsgA += "" + ENTER
				_cMsgA += "" + ENTER
				_cMsgA += "" + ENTER
				_cMsgA += "" + ENTER
				_cMsgA += "Será Enviado um e-mail aos responsaveis para regularizar o cadastro !!!"

				Aviso("Atencão - M410LIOK ",_cMsgA, {"Ok"}, 2)
					
				_lRet := .F.

			EndIf	
				
			If !Empty(_cUnExpedicao) .And. _nQtdMinima > 0

				If aCols[n,nPosQtdVen] <>  _nQtdVenda 
						
					_cMsg := "Favor verificar a quantidade digitada do produto "+Alltrim(aCols[n,nPosProduto])+" , "
					_cMsg += "que está fora do cálculo do minimo de embalagem, foi digitado a quantidade de "+Transform(aCols[n,nPosQtdVen], "@E 999,999,999.99")+" ! "+ENTER
					_cMsg += "Portanto, para a regra do minimo de embalagem deverá alterar a quantidade para "+Transform(If(_nQtdVenda < _nQtdMinima,_nQtdMinima,_nQtdVenda), "@E 999,999,999.99")+" de acordo com o volume e espécie !"+ENTER  
					_cMsg += "Não será permitido prosseguir, sugerimos digitar a quantidade "+Transform(If(_nQtdVenda < _nQtdMinima,_nQtdMinima,_nQtdVenda), "@E 999,999,999.99")+" !"+ENTER 
					_cMsg += "Caso a quantidade "+Transform(aCols[n,nPosQtdVen], "@E 999,999,999.99")+", tenha que ser a digitada, verificar o tipo de venda no cabeçalho do pedido!"+ENTER 
						
					Aviso("Atencão - M410LIOK ",_cMsg, {"Ok"}, 2)

					_lRet := .F.

				EndIf
				
			EndIf 
			
		EndIf
		
	EndIf

EndIf

/*---------------------------------------------------------------------------------------------+
| INICIO    : Projeto Comissão especifico QUALY - 31/05/2022 - Fabio Carneiro                  |
+----------------------------------------------------------------------------------------------+
| ALTERAÇÃO : Projeto revisao de Comissão especifico QUALY - 24/06/2022 - Fabio Carneiro       |
+----------------------------------------------------------------------------------------------+
| 1 - Somente se for alteração entra na regra para validar a linha acols com a tabela PAW;     |
| 2 - Verifica se a revisão é diferente para fazer a comparação;                               |
| 3 - Verifica se a comissão que esta na linha do acols e maior que a tabela PAW;              |
| 4 - Verifica se o Preço que esta na linha do acols e maior que a tabela PAW;                 |
| 5 - Verifica se a Quantidade que esta na linha do acols e maior que a tabela PAW;            |
| 6 - Se os valores PREÇO, QUANTIDADE e % COMISSÃO forem maior, somente se o usuário estiver   |
|     Preenchido no parametro QE_LIBCOM, podera prosseguir com a alteração, devido a ter uma   |
|     nova revisão implementada na tabela PAA do produto que esta no acols send validado;      |
| 7 - Quando ocorrer uma alteração de revisão será gravado no cadastro do produto o ultimo     |
|     % de comissão, codigo da tabela e ultima revisão;                                        |
| 8 - Se o pedido de vendas for Normal e a filial estiver preenchida no parametro QE_FILCOM,   | 
|     entra na regra para fazer as devidas validações.                                         |
| 9 - Se o produto na PAA estiver com a comissão zerada não entra na regra para calcular a     | 
|     comissão em 09/09/2022 - Fabio carneiro.                                                 |
+----------------------------------------------------------------------------------------------*/
If cfilAnt $ cFilComis .AND. !M->C5_TIPO $ "D"

	_cMsg       := ""
	_nComissao  := Posicione("SB1",1,xFilial("SB1")+aCols[n,nPosProduto],"B1_COMIS")          // Comissão no cadastro de produtos  
	_cTes       := Posicione("SF4",1,xFilial("SF4")+aCols[n,nPosTes],"F4_DUPLIC")             // TES do acols  
	cPgCliente  := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_XPGCOM")  // 1 = Não / 2 = Sim
	cRepreClt   := Posicione("SA3",1,xFilial("SA3")+M->C5_VEND1,"A3_XCLT")                    // 1 = Não / 2 = Sim
	cPgvend1    := Posicione("SA3",1,xFilial("SA3")+M->C5_VEND1,"A3_XPGCOM")                  // 1 = Não / 2 = Sim
	cVend1      := Posicione("SA3",1,xFilial("SA3")+M->C5_VEND1,"A3_COD")                     // Codigo do vendedor Cadastro 
	_nPercCli   := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_XCOMIS1") // Percentual de Comissão no Cliente
	_cComRev    := Posicione("SB1",1,xFilial("SB1")+aCols[n,nPosProduto],"B1_XREVCOM")        // Ultima revsão cadastrada na tabela PAA
	_cTabCom    := Posicione("SB1",1,xFilial("SB1")+aCols[n,nPosProduto],"B1_XTABCOM")        // Ultima tabela cadastrada na tabela PAA
	_cTipoProd  := Posicione("SB1",1,xFilial("SB1")+aCols[n,nPosProduto],"B1_TIPO")           // Tipo de produto 
	/*---------------------------------------------------------------------------------------------------------------+
	| Se a TES movinta financeiro e o cliente paga comissão será realizado a validação para o calculo de comissao    | 
	+---------------------------------------------------------------------------------------------------------------*/
	If _cTes == "S" .And. cPgCliente == "2" .And. cPgvend1 == "2"
		/*---------------------------------------------------------------------------------------------------------------+
		| a tabela PAA contem as a comissão, vigencias e as revisões que é replicado para o cadastro de produto          |
		+---------------------------------------------------------------------------------------------------------------*/
		If Select("WK_PAA") > 0
			WK_PAA->(DbCloseArea())
		EndIf

		_cQueryB := "SELECT * FROM "+RetSqlName("PAA")+" AS PAA "+ENTER
		_cQueryB += "WHERE PAA_FILIAL = '"+xFilial("PAA")+"' "+ENTER
		_cQueryB += " AND PAA_COD  = '"+AllTrim(aCols[n,nPosProduto])+"'  "+ENTER 
		_cQueryB += " AND PAA_REV  = '"+AllTrim(_cComRev)+"'  "+ENTER 
		_cQueryB += " AND PAA_CODTAB = '"+AllTrim(_cTabCom)+"' "+ENTER 
		_cQueryB += " AND PAA.D_E_L_E_T_ = ' ' "+ENTER 
		_cQueryB += " ORDER BY  PAA_DTVIG1, PAA_DTVIG2 "+ENTER 

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

				_lAchou := .T.
				/*----------------------------------------------------------+
				| Se produto é igual ao que esta no array, entra na regra   | 
				+----------------------------------------------------------*/
				If _aLidos[_nLidos][01] == aCols[n,nPosProduto] 
					/*----------------------------------------------------------------------------------+
					| Sim e percentual preenchido no cadastro do cliente - Paga comissão pelo Cliente   | 
					+----------------------------------------------------------------------------------*/
					If cPgCliente == "2" .And. _nPercCli > 0  
						
						If _aLidos[_nLidos][05] > 0 
							aCols[n,nPosTab]    := _cTabCom
							aCols[n,nPosCom1]   := _nComissao
							aCols[n,nPosComis1] := _nPercCli
							aCols[n,nPosComis2] := 0
							aCols[n,nPosComis3] := 0
							aCols[n,nPosComis4] := 0
							aCols[n,nPosComis5] := 0
							aCols[n,nPosRevCom] := AllTrim(_cComRev)
							aCols[n,nPosDtRvc]  := DDATABASE
							aCols[n,nPosTpcom]  := "01" // CLIENTE
						Else 
							aCols[n,nPosTab]    := _cTabCom
							aCols[n,nPosCom1]   := 0
							aCols[n,nPosComis1] := 0
							aCols[n,nPosComis2] := 0
							aCols[n,nPosComis3] := 0
							aCols[n,nPosComis4] := 0
							aCols[n,nPosComis5] := 0
							aCols[n,nPosRevCom] := AllTrim(_cComRev)
							aCols[n,nPosDtRvc]  := DDATABASE
							aCols[n,nPosTpcom]  := "01" // Zerada
						EndIf
					/*---------------------------------------------------------+
					|  Não / Sim / sim  -  Paga comissão pelo Produto          | 
					+---------------------------------------------------------*/
					ElseIf cRepreClt == "1" .And. cPgCliente == "2" .And. cPgvend1 == "2" .And. _nPercCli <= 0 
						/*----------------------------------------------------------------------------------------------+
						| A tabela PAW armazena quando há uma nova revisão criada e somente é criada no ponto MT410ALOK |
						+----------------------------------------------------------------------------------------------*/
						If Select("WK_PAW") > 0
							WK_PAW->(DbCloseArea())
						EndIf
						_cQueryA := "SELECT * FROM "+RetSqlName("PAW")+" AS PAW "+ENTER
						_cQueryA += "WHERE PAW_FILIAL = '"+xFilial("PAW")+"' "+ENTER
						_cQueryA += " AND PAW_PEDIDO = '"+AllTrim(M->C5_NUM)+"' "+ENTER 
						_cQueryA += " AND PAW_CODCLI = '"+AllTrim(M->C5_CLIENTE)+"' "+ENTER 
						_cQueryA += " AND PAW_LOJA   = '"+AllTrim(M->C5_LOJACLI)+"' "+ENTER
						_cQueryA += " AND PAW_COD    = '"+AllTrim(aCols[n,nPosProduto])+"' "+ENTER
						_cQueryA += " AND PAW_ITEM   = '"+AllTrim(aCols[n,nPosItem])+"' "+ENTER
						_cQueryA += " AND PAW.D_E_L_E_T_ = ' ' "+ENTER 
						_cQueryA += " ORDER BY PAW_COD "+ENTER 
						
						TcQuery _cQueryA ALIAS "WK_PAW" NEW
						WK_PAW->(DbGoTop())

						While WK_PAW->(!Eof())
							/*---------------------------------------------------------------+
							|  Se o produto do acols é igual a tabela PAW, faz as validações | 
							+---------------------------------------------------------------*/
							If  aCols[n,nPosProduto] == WK_PAW->PAW_COD
								/*-----------------------------------------------------------------------------------------+
								| Se o preco de venda unitario, quantidade ou % de comissão é maior do que esta no acols,  |
								| aliementa o array (_aLePAW) para vaidação das regras.                                    |  
								+-----------------------------------------------------------------------------------------*/
								If aCols[n,nPosPrcVen] <> WK_PAW->PAW_PRECO .Or. aCols[n,nPosQtdVen] <>  WK_PAW->PAW_QTD; 
								.Or. aCols[n,nPosComis1] <> WK_PAW->PAW_COMIS1     
										
									Aadd(_aLePAW,{WK_PAW->PAW_COD,;  // 01
												WK_PAW->PAW_CODTAB,; // 02 
												WK_PAW->PAW_REV,;    // 03
												WK_PAW->PAW_COMIS1,; // 04 
												WK_PAW->PAW_PRECO,;  // 05
												WK_PAW->PAW_QTD,;	 // 06	
												WK_PAW->PAW_ITEM,;   // 07
												WK_PAW->PAW_DATA,;	 // 08	
												WK_PAW->PAW_STATUS}) // 09

								EndIf
								
							EndIf
					
							WK_PAW->(DbSkip())
					
						EndDo

						/*--------------------------------------------------------------------------------------------+
						| Se houver conteudo na tabela PAW entra na regra para validar a linha acols com a tabela PAW;|
						+--------------------------------------------------------------------------------------------*/
						If Len(_aLePAW) > 0
							/*-----------------------------------------------------------------------------------------+
							| Somente se for alteração entra na regra para validar a linha acols com a tabela PAW;     |
							+-----------------------------------------------------------------------------------------*/
							If ALTERA 

								For _nLePAW:= 1 To Len(_aLePAW) 
									/*----------------------------------------------------------------------------------------------+
									| Se o produto é igual e a revisão é diferente, entra nas regras de validação do array _aLePAW  |  
									+----------------------------------------------------------------------------------------------*/
									If _aLidos[_nLidos][01] == _aLePAW[_nLePAW][01] .And. _aLidos[_nLidos][04] == _aLePAW[_nLePAW][02] .And. _aLidos[_nLidos][06] <> _aLePAW[_nLePAW][03]   
										/*-----------------------------------------------------------------------------------------------+
										| Se a comissão do acols é maior que esta na tabela PAW, será exibido a mensagem para o usuário  |
										+-----------------------------------------------------------------------------------------------*/
										If aCols[n,nPosComis1] > _aLePAW[_nLePAW][04]   
											
											_cMsg := ""
											_cMsg := "O percentual de comissão entre produto e a tabela de (Vigência/Revisão) está divergente para o produto  "+Alltrim(aCols[n,nPosProduto])+" com a revisão "+AllTrim(aCols[n,nPosRevCom])+" !"+ENTER
											_cMsg += "No pedido de vendas foi alterado para o % de "+Transform(Posicione("SB1",1, xFilial("SB1")+aCols[n,nPosProduto],"B1_COMIS"), "@E 999.99")+", e no pedido de vendas estava com % "+Transform(_aLePAW[_nLePAW][04], "@E 999.99")+" !"+ENTER 
											_cMsg += "Portanto, não será permitido prosseguir sem o produto ajustado na tabela de Vigência/Revisão e cadastro de produto!"+ENTER 
											_cMsg += "Favor contatar o gestor para ajustar o pedido com a nova revisão e percentual novo!"+ENTER 
													
											Aviso("Atencão - M410LIOK ",_cMsg, {"Ok"}, 2)
											/*-------------------------------------------------------------------------------------------+
											| Se o usuario estiver no parametro QE_XLIBCOM e o status estiver com 1=Alterado/2=Revisado, |
											| será possivel alterar a quantidade e preço , porém a comissão será mantida a mesma.        | 
											| Ser o usuário não estiver no parametro, não permite saltar linha do acols                  |
											+-------------------------------------------------------------------------------------------*/
											If AllTrim(cUserName) $  _cUsrLibCom 
												aCols[n,nPosTab]    := _aLePAW[_nLePAW][02]
												aCols[n,nPosCom1]   := _aLePAW[_nLePAW][04]
												aCols[n,nPosComis1] := _aLePAW[_nLePAW][04]
												aCols[n,nPosComis2] := 0
												aCols[n,nPosComis3] := 0
												aCols[n,nPosComis4] := 0
												aCols[n,nPosComis5] := 0
												aCols[n,nPosRevCom] := _aLePAW[_nLePAW][03]
												aCols[n,nPosDtRvc]  := StoD(_aLePAW[_nLePAW][08])
												aCols[n,nPosTpcom]  := "02" // Produto
												cQry := " UPDATE "+RetSqlName("PAW")+" "+ENTER
												cQry += " SET PAW_STATUS = '2'  "+ENTER
												cQry += " FROM " + RetSqlName("PAW") + " AS PAW "+ENTER
												cQry += " WHERE PAW_FILIAL = '"+xFilial("PAW")+"' "+ENTER
												cQry += " AND PAW_PEDIDO = '"+AllTrim(M->C5_NUM)+"' "+ENTER 
												cQry += " AND PAW_CODCLI = '"+AllTrim(M->C5_CLIENTE)+"' "+ENTER 
												cQry += " AND PAW_LOJA   = '"+AllTrim(M->C5_LOJACLI)+"' "+ENTER
												cQry += " AND PAW_COD    = '"+AllTrim(aCols[n,nPosProduto])+"' "+ENTER
												cQry += " AND PAW_CODTAB = '"+AllTrim(aCols[n,nPosTab])+"' "+ENTER
												cQry += " AND PAW.D_E_L_E_T_ = ' ' "+ENTER 
													
												TcSQLExec(cQry)
												_lRet := .T.
											Else
												aCols[n,nPosTab]    := _aLePAW[_nLePAW][02]
												aCols[n,nPosCom1]   := _aLePAW[_nLePAW][04]
												aCols[n,nPosComis1] := _aLePAW[_nLePAW][04]
												aCols[n,nPosComis2] := 0
												aCols[n,nPosComis3] := 0
												aCols[n,nPosComis4] := 0
												aCols[n,nPosComis5] := 0
												aCols[n,nPosRevCom] := _aLePAW[_nLePAW][03]
												aCols[n,nPosDtRvc]  := StoD(_aLePAW[_nLePAW][08])
												aCols[n,nPosTpcom]  := "02" // Produto
												cQry := " UPDATE "+RetSqlName("PAW")+" "+ENTER
												cQry += " SET PAW_STATUS = '1'  "+ENTER
												cQry += " FROM " + RetSqlName("PAW") + " AS PAW "+ENTER
												cQry += " WHERE PAW_FILIAL = '"+xFilial("PAW")+"' "+ENTER
												cQry += " AND PAW_PEDIDO = '"+AllTrim(M->C5_NUM)+"' "+ENTER 
												cQry += " AND PAW_CODCLI = '"+AllTrim(M->C5_CLIENTE)+"' "+ENTER 
												cQry += " AND PAW_LOJA   = '"+AllTrim(M->C5_LOJACLI)+"' "+ENTER
												cQry += " AND PAW_COD    = '"+AllTrim(aCols[n,nPosProduto])+"' "+ENTER
												cQry += " AND PAW.D_E_L_E_T_ = ' ' "+ENTER 
													
												TcSQLExec(cQry)
												_lRet := .F.
											
											EndIf  
										/*-------------------------------------------------------------------------------------------+
										| Se a comissão é menor do que esta gravado ma tabela PAW, não será necessario intervenção   |
										| do usuário preenchido no parametro QE_XLIBCOM.                                             |
										+-------------------------------------------------------------------------------------------*/
										ElseIf aCols[n,nPosComis1] < _aLePAW[_nLePAW][04] 
											aCols[n,nPosTab]    := _aLePAW[_nLePAW][02]
											aCols[n,nPosCom1]   := _aLePAW[_nLePAW][04]
											aCols[n,nPosComis1] := _aLePAW[_nLePAW][04]
											aCols[n,nPosComis2] := 0
											aCols[n,nPosComis3] := 0
											aCols[n,nPosComis4] := 0
											aCols[n,nPosComis5] := 0
											aCols[n,nPosRevCom] := _aLePAW[_nLePAW][03]
											aCols[n,nPosDtRvc]  := StoD(_aLePAW[_nLePAW][08])
											aCols[n,nPosTpcom]  := "02" // Produto
											cQry := " UPDATE "+RetSqlName("PAW")+" "+ENTER
											cQry += " SET PAW_STATUS = '1'  "+ENTER
											cQry += " FROM " + RetSqlName("PAW") + " AS PAW "+ENTER
											cQry += " WHERE PAW_FILIAL = '"+xFilial("PAW")+"' "+ENTER
											cQry += " AND PAW_PEDIDO = '"+AllTrim(M->C5_NUM)+"' "+ENTER 
											cQry += " AND PAW_CODCLI = '"+AllTrim(M->C5_CLIENTE)+"' "+ENTER 
											cQry += " AND PAW_LOJA   = '"+AllTrim(M->C5_LOJACLI)+"' "+ENTER
											cQry += " AND PAW_COD    = '"+AllTrim(aCols[n,nPosProduto])+"' "+ENTER
											cQry += " AND PAW.D_E_L_E_T_ = ' ' "+ENTER 
													
											TcSQLExec(cQry)
											_lRet := .T.
										EndIf
										/*-----------------------------------------------------------------------------------------------+
										| Se a Preço no acols é maior que esta na tabela PAW, será exibido a mensagem para o usuário     |
										+-----------------------------------------------------------------------------------------------*/
										If aCols[n,nPosPrcVen] > _aLePAW[_nLePAW][05]  
											
											_cMsg := ""
											_cMsg := "O valor deste produto "+Alltrim(aCols[n,nPosProduto])+" com a revisão "+ AllTrim(_aLidos[_nLidos][06])+" esta maior que o negociado na revisao anterior!"+ENTER
											_cMsg += "O preço estava em "+Transform(_aLePAW[_nLePAW][05], "@E 999,999,999.99")+", e no pedido de vendas está com "+Transform(aCols[n,nPosPrcVen], "@E 999,999,999.99")+" !"+ENTER 
											_cMsg += "Será necessario solicitar para o gestor ajustar o pedido para o preço acordado!"+ENTER 
												
											Aviso("Atencão - M410LIOK ",_cMsg, {"Ok"}, 2)
											/*-------------------------------------------------------------------------------------------+
											| Se o usuario estiver no parametro QE_XLIBCOM e o status estiver com 1=Alterado/2=Revisado, |
											| será possivel alterar a quantidade e preço , porém a comissão será mantida a mesma.        | 
											| Ser o usuário não estiver no parametro, não permite saltar linha do acols                  |
											+-------------------------------------------------------------------------------------------*/
											If AllTrim(cUserName) $  _cUsrLibCom
												aCols[n,nPosTab]    := _aLePAW[_nLePAW][02]
												aCols[n,nPosCom1]   := _aLePAW[_nLePAW][04]
												aCols[n,nPosComis1] := _aLePAW[_nLePAW][04]
												aCols[n,nPosComis2] := 0
												aCols[n,nPosComis3] := 0
												aCols[n,nPosComis4] := 0
												aCols[n,nPosComis5] := 0
												aCols[n,nPosRevCom] := _aLePAW[_nLePAW][03]
												aCols[n,nPosDtRvc]  := StoD(_aLePAW[_nLePAW][08])
												aCols[n,nPosTpcom]  := "02" // Produto
												cQry := " UPDATE "+RetSqlName("PAW")+" "+ENTER
												cQry += " SET PAW_STATUS = '2'  "+ENTER
												cQry += " FROM " + RetSqlName("PAW") + " AS PAW "+ENTER
												cQry += " WHERE PAW_FILIAL = '"+xFilial("PAW")+"' "+ENTER
												cQry += " AND PAW_PEDIDO = '"+AllTrim(M->C5_NUM)+"' "+ENTER 
												cQry += " AND PAW_CODCLI = '"+AllTrim(M->C5_CLIENTE)+"' "+ENTER 
												cQry += " AND PAW_LOJA   = '"+AllTrim(M->C5_LOJACLI)+"' "+ENTER
												cQry += " AND PAW_COD    = '"+AllTrim(aCols[n,nPosProduto])+"' "+ENTER
												cQry += " AND PAW_ITEM    = '"+AllTrim(aCols[n,nPosItem])+"' "+ENTER
												cQry += " AND PAW.D_E_L_E_T_ = ' ' "+ENTER 
													
												TcSQLExec(cQry)
												_lRet := .T.
											Else
												aCols[n,nPosTab]    := _aLePAW[_nLePAW][02]
												aCols[n,nPosCom1]   := _aLePAW[_nLePAW][04]
												aCols[n,nPosComis1] := _aLePAW[_nLePAW][04]
												aCols[n,nPosComis2] := 0
												aCols[n,nPosComis3] := 0
												aCols[n,nPosComis4] := 0
												aCols[n,nPosComis5] := 0
												aCols[n,nPosRevCom] := _aLePAW[_nLePAW][03]
												aCols[n,nPosDtRvc]  := StoD(_aLePAW[_nLePAW][08])
												aCols[n,nPosTpcom]  := "02" // Produto
												cQry := " UPDATE "+RetSqlName("PAW")+" "+ENTER
												cQry += " SET PAW_STATUS = '1'  "+ENTER
												cQry += " FROM " + RetSqlName("PAW") + " AS PAW "+ENTER
												cQry += " WHERE PAW_FILIAL = '"+xFilial("PAW")+"' "+ENTER
												cQry += " AND PAW_PEDIDO = '"+AllTrim(M->C5_NUM)+"' "+ENTER 
												cQry += " AND PAW_CODCLI = '"+AllTrim(M->C5_CLIENTE)+"' "+ENTER 
												cQry += " AND PAW_LOJA   = '"+AllTrim(M->C5_LOJACLI)+"' "+ENTER
												cQry += " AND PAW_COD    = '"+AllTrim(aCols[n,nPosProduto])+"' "+ENTER
												cQry += " AND PAW.D_E_L_E_T_ = ' ' "+ENTER 
													
												TcSQLExec(cQry)
												_lRet := .F.
												
											EndIf  
										/*-------------------------------------------------------------------------------------------+
										| Se a comissão é menor do que esta gravado ma tabela PAW, não será necessario intervenção   |
										| do usuário preenchido no parametro QE_XLIBCOM.                                             |
										+-------------------------------------------------------------------------------------------*/
										ElseIf aCols[n,nPosPrcVen] < _aLePAW[_nLePAW][05] 
											aCols[n,nPosTab]    := _aLePAW[_nLePAW][02]
											aCols[n,nPosCom1]   := _aLePAW[_nLePAW][04]
											aCols[n,nPosComis1] := _aLePAW[_nLePAW][04]
											aCols[n,nPosComis2] := 0
											aCols[n,nPosComis3] := 0
											aCols[n,nPosComis4] := 0
											aCols[n,nPosComis5] := 0
											aCols[n,nPosRevCom] := _aLePAW[_nLePAW][03]
											aCols[n,nPosDtRvc]  := StoD(_aLePAW[_nLePAW][08])
											aCols[n,nPosTpcom]  := "02" // Produto
											cQry := " UPDATE "+RetSqlName("PAW")+" "+ENTER
											cQry += " SET PAW_STATUS = '1'  "+ENTER
											cQry += " FROM " + RetSqlName("PAW") + " AS PAW "+ENTER
											cQry += " WHERE PAW_FILIAL = '"+xFilial("PAW")+"' "+ENTER
											cQry += " AND PAW_PEDIDO = '"+AllTrim(M->C5_NUM)+"' "+ENTER 
											cQry += " AND PAW_CODCLI = '"+AllTrim(M->C5_CLIENTE)+"' "+ENTER 
											cQry += " AND PAW_LOJA   = '"+AllTrim(M->C5_LOJACLI)+"' "+ENTER
											cQry += " AND PAW_COD    = '"+AllTrim(aCols[n,nPosProduto])+"' "+ENTER
											cQry += " AND PAW.D_E_L_E_T_ = ' ' "+ENTER 
													
											TcSQLExec(cQry)
											_lRet := .T.
										EndIf
										/*------------------------------------------------------------------------------------------------+
										| Se a Quantidade no acols é maior que esta na tabela PAW, será exibido a mensagem para o usuário |
										+------------------------------------------------------------------------------------------------*/
										If aCols[n,nPosQtdVen] > _aLePAW[_nLePAW][06]  
											
											_cMsg := ""
											_cMsg := "Não será permitido alterar a quantidade do produto  "+Alltrim(aCols[n,nPosProduto])+" com a revisão "+AllTrim(aCols[n,nPosRevCom])+" !"+ENTER
											If AllTrim(_aLidos[_nLidos][06]) <> AllTrim(aCols[n,nPosRevCom])
												_cMsg += "Este produto possui uma revisão nova que é "+AllTrim(_aLidos[_nLidos][06])+" !"+ENTER 
											EndIf
											_cMsg += "Favor contatar o gestor que tem permissão para fazer esta tratativa no sistema com a revisão anterior ou atual !"+ENTER 
													
											Aviso("Atencão - M410LIOK ",_cMsg, {"Ok"}, 2)
											/*-------------------------------------------------------------------------------------------+
											| Se o usuario estiver no parametro QE_XLIBCOM e o status estiver com 1=Alterado/2=Revisado, |
											| será possivel alterar a quantidade e preço , porém a comissão será mantida a mesma.        | 
											| Ser o usuário não estiver no parametro, não permite saltar linha do acols                  |
											+-------------------------------------------------------------------------------------------*/
											If AllTrim(cUserName) $  _cUsrLibCom
												aCols[n,nPosTab]    := _aLePAW[_nLePAW][02]
												aCols[n,nPosCom1]   := _aLePAW[_nLePAW][04]
												aCols[n,nPosComis1] := _aLePAW[_nLePAW][04]
												aCols[n,nPosComis2] := 0
												aCols[n,nPosComis3] := 0
												aCols[n,nPosComis4] := 0
												aCols[n,nPosComis5] := 0
												aCols[n,nPosRevCom] := _aLePAW[_nLePAW][03]
												aCols[n,nPosDtRvc]  := StoD(_aLePAW[_nLePAW][08])
												aCols[n,nPosTpcom]  := "02" // Produto
												cQry := " UPDATE "+RetSqlName("PAW")+" "+ENTER
												cQry += " SET PAW_STATUS = '2'  "+ENTER
												cQry += " FROM " + RetSqlName("PAW") + " AS PAW "+ENTER
												cQry += " WHERE PAW_FILIAL = '"+xFilial("PAW")+"' "+ENTER
												cQry += " AND PAW_PEDIDO = '"+AllTrim(M->C5_NUM)+"' "+ENTER 
												cQry += " AND PAW_CODCLI = '"+AllTrim(M->C5_CLIENTE)+"' "+ENTER 
												cQry += " AND PAW_LOJA   = '"+AllTrim(M->C5_LOJACLI)+"' "+ENTER
												cQry += " AND PAW_COD    = '"+AllTrim(aCols[n,nPosProduto])+"' "+ENTER
												cQry += " AND PAW_ITEM    = '"+AllTrim(aCols[n,nPosItem])+"' "+ENTER
												cQry += " AND PAW.D_E_L_E_T_ = ' ' "+ENTER 
													
												TcSQLExec(cQry)
												_lRet := .T.
											Else
												aCols[n,nPosTab]    := _aLePAW[_nLePAW][02]
												aCols[n,nPosCom1]   := _aLePAW[_nLePAW][04]
												aCols[n,nPosComis1] := _aLePAW[_nLePAW][04]
												aCols[n,nPosComis2] := 0
												aCols[n,nPosComis3] := 0
												aCols[n,nPosComis4] := 0
												aCols[n,nPosComis5] := 0
												aCols[n,nPosRevCom] := _aLePAW[_nLePAW][03]
												aCols[n,nPosDtRvc]  := StoD(_aLePAW[_nLePAW][08])
												aCols[n,nPosTpcom]  := "02" // Produto
												cQry := " UPDATE "+RetSqlName("PAW")+" "+ENTER
												cQry += " SET PAW_STATUS = '1'  "+ENTER
												cQry += " FROM " + RetSqlName("PAW") + " AS PAW "+ENTER
												cQry += " WHERE PAW_FILIAL = '"+xFilial("PAW")+"' "+ENTER
												cQry += " AND PAW_PEDIDO = '"+AllTrim(M->C5_NUM)+"' "+ENTER 
												cQry += " AND PAW_CODCLI = '"+AllTrim(M->C5_CLIENTE)+"' "+ENTER 
												cQry += " AND PAW_LOJA   = '"+AllTrim(M->C5_LOJACLI)+"' "+ENTER
												cQry += " AND PAW_COD    = '"+AllTrim(aCols[n,nPosProduto])+"' "+ENTER
												cQry += " AND PAW.D_E_L_E_T_ = ' ' "+ENTER 
													
												TcSQLExec(cQry)
												_lRet := .F.
											
											EndIf  
										/*-------------------------------------------------------------------------------------------+
										| Se a comissão é menor do que esta gravado ma tabela PAW, não será necessario intervenção   |
										| do usuário preenchido no parametro QE_XLIBCOM.                                             |
										+-------------------------------------------------------------------------------------------*/
										ElseIf aCols[n,nPosQtdVen] < _aLePAW[_nLePAW][06]
											aCols[n,nPosTab]    := _aLePAW[_nLePAW][02]
											aCols[n,nPosCom1]   := _aLePAW[_nLePAW][04]
											aCols[n,nPosComis1] := _aLePAW[_nLePAW][04]
											aCols[n,nPosComis2] := 0
											aCols[n,nPosComis3] := 0
											aCols[n,nPosComis4] := 0
											aCols[n,nPosComis5] := 0
											aCols[n,nPosRevCom] := _aLePAW[_nLePAW][03]
											aCols[n,nPosDtRvc]  := StoD(_aLePAW[_nLePAW][08])
											aCols[n,nPosTpcom]  := "02" // Produto
											cQry := " UPDATE "+RetSqlName("PAW")+" "+ENTER
											cQry += " SET PAW_STATUS = '1'  "+ENTER
											cQry += " FROM " + RetSqlName("PAW") + " AS PAW "+ENTER
											cQry += " WHERE PAW_FILIAL = '"+xFilial("PAW")+"' "+ENTER
											cQry += " AND PAW_PEDIDO = '"+AllTrim(M->C5_NUM)+"' "+ENTER 
											cQry += " AND PAW_CODCLI = '"+AllTrim(M->C5_CLIENTE)+"' "+ENTER 
											cQry += " AND PAW_LOJA   = '"+AllTrim(M->C5_LOJACLI)+"' "+ENTER
											cQry += " AND PAW_COD    = '"+AllTrim(aCols[n,nPosProduto])+"' "+ENTER
											cQry += " AND PAW.D_E_L_E_T_ = ' ' "+ENTER 
													
											TcSQLExec(cQry)
											_lRet := .T.
									
										EndIf
									
									EndIf	
									
								Next _nLePAW 
							
							EndIf	
						
						Else
							/*------------------------------------------------------------------------------------+
							| Se a comissão é igual a tabela PAA e a revisão e igual ao que esta no produto e a   | 
							| tabela PAA e igual a revisão que estver no produto entra na regra                   |
							+------------------------------------------------------------------------------------*/
							If _aLidos[_nLidos][05] == _nComissao .And.  _aLidos[_nLidos][06] == _cComRev .And. _aLidos[_nLidos][04] == _cTabCom
								/*------------------------------------------------------------------------------+
								| Na inclusão pega a ultima revisão que esta no cadastro de produto e carrega   |
								| na linha de preenchimento do acols.                                           |  
								+------------------------------------------------------------------------------*/
								If INCLUI 
									
									If _aLidos[_nLidos][05] > 0
										aCols[n,nPosTab]    := Posicione("SB1",1, xFilial("SB1")+aCols[n,nPosProduto],"B1_XTABCOM")
										aCols[n,nPosCom1]   := Posicione("SB1",1, xFilial("SB1")+aCols[n,nPosProduto],"B1_COMIS")
										aCols[n,nPosComis1] := Posicione("SB1",1, xFilial("SB1")+aCols[n,nPosProduto],"B1_COMIS")
										aCols[n,nPosComis2] := 0
										aCols[n,nPosComis3] := 0
										aCols[n,nPosComis4] := 0
										aCols[n,nPosComis5] := 0
										aCols[n,nPosRevCom] := Posicione("SB1",1, xFilial("SB1")+aCols[n,nPosProduto],"B1_XREVCOM")
										aCols[n,nPosDtRvc]  := DDATABASE
										aCols[n,nPosTpcom]  := "02" // Produto
									Else
										aCols[n,nPosTab]    := Posicione("SB1",1, xFilial("SB1")+aCols[n,nPosProduto],"B1_XTABCOM")
										aCols[n,nPosCom1]   := 0
										aCols[n,nPosComis1] := 0
										aCols[n,nPosComis2] := 0
										aCols[n,nPosComis3] := 0
										aCols[n,nPosComis4] := 0
										aCols[n,nPosComis5] := 0
										aCols[n,nPosRevCom] := Posicione("SB1",1, xFilial("SB1")+aCols[n,nPosProduto],"B1_XREVCOM")
										aCols[n,nPosDtRvc]  := DDATABASE
										aCols[n,nPosTpcom]  := "02" // Produto
									EndIf
								Else 
									/*-------------------------------------------------------------------------------------------------+
									| Na alteração de uma nova linha no acols será verificado se já existe o produto na                |
									| tabela PAW e exibir a mensagem para o usuário que já existe em outra linha.                      |
									| Esta regra é para alertar o usuário que será gravado o mesmo produto com a revisão mais recente. |
									| Caso seja incluido pelo usuário no parametro QE_LIBCOM, permanece a mesma revisão!               | 
									+-------------------------------------------------------------------------------------------------*/
									_aLePW := {}
									_nLePW := 0
									
									If Select("WK_PW") > 0
										WK_PW->(DbCloseArea())
									EndIf
									_cQueryC := "SELECT * FROM "+RetSqlName("PAW")+" AS PAW "+ENTER
									_cQueryC += "WHERE PAW_FILIAL = '"+xFilial("PAW")+"' "+ENTER
									_cQueryC += " AND PAW_PEDIDO = '"+AllTrim(M->C5_NUM)+"' "+ENTER 
									_cQueryC += " AND PAW_CODCLI = '"+AllTrim(M->C5_CLIENTE)+"' "+ENTER 
									_cQueryC += " AND PAW_LOJA   = '"+AllTrim(M->C5_LOJACLI)+"' "+ENTER
									_cQueryC += " AND PAW_COD    = '"+AllTrim(aCols[n,nPosProduto])+"' "+ENTER
									_cQueryC += " AND PAW.D_E_L_E_T_ = ' ' "+ENTER 
									_cQueryC += " ORDER BY PAW_COD "+ENTER 
									TcQuery _cQueryC ALIAS "WK_PW" NEW
									WK_PW->(DbGoTop())
									While WK_PW->(!Eof())
										/*------------------------------------------------------------------------------------+
										| Se o produto for o mesmo que estiber na tabela PAW, será adicionado no array _aLePW |  
										+------------------------------------------------------------------------------------*/
										If  aCols[n,nPosProduto] == WK_PW->PAW_COD .And. _aLidos[_nLidos][04] == WK_PW->PAW_CODTAB    
												
											Aadd(_aLePW,{WK_PW->PAW_COD,;  // 01
														WK_PW->PAW_CODTAB,; // 02 
														WK_PW->PAW_REV,;    // 03
														WK_PW->PAW_COMIS1,; // 04 
														WK_PW->PAW_PRECO,;  // 05
														WK_PW->PAW_QTD,;	// 06	
														WK_PW->PAW_ITEM,;   // 07
														WK_PW->PAW_DATA,;	// 08	
														WK_PW->PAW_STATUS}) // 09
												
										EndIf
										WK_PW->(DbSkip())
									EndDo
										
									If Len(_aLePW) > 0
								
										For _nLePW:= 1 To Len(_aLePW) 
											/*------------------------------------------------------------------------------------+
											| Se o produto for o mesmo que estiber na tabela PAW, e o item no acols for diferente |
											| será exibido a mensagem para usuário que já existe este produto com outro item.     |
											| A mensagem é somemnte um alerta, porém o usuario podera prosseguir                  |   
											+------------------------------------------------------------------------------------*/
											If _aLePW[_nLePW][01] == aCols[n,nPosProduto] .And. aCols[n,nPosItem] <> _aLePW[_nLePW][07] 
												_cMsg := ""
												_cMsg := "Para este produto  "+Alltrim(aCols[n,nPosProduto])+" com a revisão "+AllTrim(_aLePW[_nLePW][03])+" , já existe no item "+AllTrim(_aLePW[_nLePW][07])+" !"+ENTER
												If AllTrim(_aLidos[_nLidos][06]) <> AllTrim(_aLePW[_nLePW][03])
													_cMsg += "Neste caso será incluido com a revisão atual que é "+AllTrim(_aLidos[_nLidos][06])+" !"+ENTER 
												EndIf
												_cMsg += "Caso deseje que este produto que fique com o mesmo percentual e valores da revisão anterior, contatar o gestor que tem permissão para fazer esta tratativa no sistema !"+ENTER 
															
												Aviso("Alerta - M410LIOK ",_cMsg, {"Ok"}, 2)
												/*-------------------------------------------------------------------------------------------+
												| Se o usuario estiver no parametro QE_XLIBCOM e o status estiver com 1=Alterado/2=Revisado, |
												| será possivel alterar a quantidade e preço , porém a comissão será mantida a mesma.        | 
												| Ser o usuário não estiver no parametro, será gravado os dados com a nova revisão.          |
												+-------------------------------------------------------------------------------------------*/
												If AllTrim(cUserName) $  _cUsrLibCom
													aCols[n,nPosTab]    := _aLePW[_nLePW][02]
													aCols[n,nPosCom1]   := _aLePW[_nLePW][04]
													aCols[n,nPosComis1] := _aLePW[_nLePW][04]
													aCols[n,nPosComis2] := 0
													aCols[n,nPosComis3] := 0
													aCols[n,nPosComis4] := 0
													aCols[n,nPosComis5] := 0
													aCols[n,nPosRevCom] := _aLePW[_nLePW][03]
													aCols[n,nPosDtRvc]  := StoD(_aLePW[_nLePW][08])
													aCols[n,nPosTpcom]  := "02" // Produto
													cQry := " UPDATE "+RetSqlName("PAW")+" "+ENTER
													cQry += " SET PAW_STATUS = '2'  "+ENTER
													cQry += " FROM " + RetSqlName("PAW") + " AS PAW "+ENTER
													cQry += " WHERE PAW_FILIAL = '"+xFilial("PAW")+"' "+ENTER
													cQry += " AND PAW_PEDIDO = '"+AllTrim(M->C5_NUM)+"' "+ENTER 
													cQry += " AND PAW_CODCLI = '"+AllTrim(M->C5_CLIENTE)+"' "+ENTER 
													cQry += " AND PAW_LOJA   = '"+AllTrim(M->C5_LOJACLI)+"' "+ENTER
													cQry += " AND PAW_COD    = '"+AllTrim(aCols[n,nPosProduto])+"' "+ENTER
													cQry += " AND PAW_ITEM    = '"+AllTrim(aCols[n,nPosItem])+"' "+ENTER
													cQry += " AND PAW.D_E_L_E_T_ = ' ' "+ENTER 
															
													TcSQLExec(cQry)
													_lRet := .T.
													
												Else
													aCols[n,nPosTab]    := _aLidos[_nLidos][04]
													aCols[n,nPosCom1]   := _aLidos[_nLidos][05]
													aCols[n,nPosComis1] := Posicione("SB1",1, xFilial("SB1")+aCols[n,nPosProduto],"B1_COMIS")
													aCols[n,nPosComis2] := 0
													aCols[n,nPosComis3] := 0
													aCols[n,nPosComis4] := 0
													aCols[n,nPosComis5] := 0
													aCols[n,nPosRevCom] := AllTrim(_cComRev)
													aCols[n,nPosDtRvc]  := DDATABASE
													aCols[n,nPosTpcom]  := "02" // Produto
													cQry := " UPDATE "+RetSqlName("PAW")+" "+ENTER
													cQry += " SET PAW_STATUS = '1'  "+ENTER
													cQry += " FROM " + RetSqlName("PAW") + " AS PAW "+ENTER
													cQry += " WHERE PAW_FILIAL = '"+xFilial("PAW")+"' "+ENTER
													cQry += " AND PAW_PEDIDO = '"+AllTrim(M->C5_NUM)+"' "+ENTER 
													cQry += " AND PAW_CODCLI = '"+AllTrim(M->C5_CLIENTE)+"' "+ENTER 
													cQry += " AND PAW_LOJA   = '"+AllTrim(M->C5_LOJACLI)+"' "+ENTER
													cQry += " AND PAW_COD    = '"+AllTrim(aCols[n,nPosProduto])+"' "+ENTER
													cQry += " AND PAW.D_E_L_E_T_ = ' ' "+ENTER 
															
													TcSQLExec(cQry)
													_lRet := .T.
												
												EndIf	
											/*------------------------------------------------------------------------------------+
											| Se o produto for o mesmo que estiber na tabela PAW, e o item no acols for igual     |
											| não será exibido a mensagem para usuário que já existe este produto com outro item. |
											| Será gravado os mesmos dados gravados na tabela PAW.                                |   
											+------------------------------------------------------------------------------------*/
											ElseIf _aLePW[_nLePW][01] == aCols[n,nPosProduto] .And. aCols[n,nPosItem] == _aLePW[_nLePW][07] 
												aCols[n,nPosTab]    := _aLePW[_nLePW][02]
												aCols[n,nPosCom1]   := _aLePW[_nLePW][04]
												aCols[n,nPosComis1] := _aLePW[_nLePW][04]
												aCols[n,nPosComis2] := 0
												aCols[n,nPosComis3] := 0
												aCols[n,nPosComis4] := 0
												aCols[n,nPosComis5] := 0
												aCols[n,nPosRevCom] := _aLePW[_nLePW][03]
												aCols[n,nPosDtRvc]  := StoD(_aLePW[_nLePW][08])
												aCols[n,nPosTpcom]  := "02" // Produto
												aCols[n,nPosPrcVen] := _aLePW[_nLePW][05]
												aCols[n,nPosQtdVen] := _aLePW[_nLePW][06]
												cQry := " UPDATE "+RetSqlName("PAW")+" "+ENTER
												cQry += " SET PAW_STATUS = '1'  "+ENTER
												cQry += " FROM " + RetSqlName("PAW") + " AS PAW "+ENTER
												cQry += " WHERE PAW_FILIAL = '"+xFilial("PAW")+"' "+ENTER
												cQry += " AND PAW_PEDIDO = '"+AllTrim(M->C5_NUM)+"' "+ENTER 
												cQry += " AND PAW_CODCLI = '"+AllTrim(M->C5_CLIENTE)+"' "+ENTER 
												cQry += " AND PAW_LOJA   = '"+AllTrim(M->C5_LOJACLI)+"' "+ENTER
												cQry += " AND PAW_COD    = '"+AllTrim(aCols[n,nPosProduto])+"' "+ENTER
												cQry += " AND PAW.D_E_L_E_T_ = ' ' "+ENTER 
															
												TcSQLExec(cQry)
												_lRet := .T.
												
											EndIf
											
										Next _nLePW	
									Else 
										/*-------------------------------------------------------------------------------+
										| Se entrar nesta regra é porque o produto não possui alteração na tabela PAW    |
										| Será gravado os dados na linha do acols com a ultima revisão e comissão de     |
										| acorco com o cadastro de produtos.                                             |     
										+-------------------------------------------------------------------------------*/
										If _aLidos[_nLidos][05] > 0
											aCols[n,nPosTab]    := _aLidos[_nLidos][04]
											aCols[n,nPosCom1]   := _aLidos[_nLidos][05]
											aCols[n,nPosComis1] := Posicione("SB1",1, xFilial("SB1")+aCols[n,nPosProduto],"B1_COMIS")
											aCols[n,nPosComis2] := 0
											aCols[n,nPosComis3] := 0
											aCols[n,nPosComis4] := 0
											aCols[n,nPosComis5] := 0
											aCols[n,nPosRevCom] := AllTrim(_cComRev)
											aCols[n,nPosDtRvc]  := DDATABASE
											aCols[n,nPosTpcom]  := "02" // Produto
										Else 
											aCols[n,nPosTab]    := _aLidos[_nLidos][04]
											aCols[n,nPosCom1]   := 0
											aCols[n,nPosComis1] := 0
											aCols[n,nPosComis2] := 0
											aCols[n,nPosComis3] := 0
											aCols[n,nPosComis4] := 0
											aCols[n,nPosComis5] := 0
											aCols[n,nPosRevCom] := AllTrim(_cComRev)
											aCols[n,nPosDtRvc]  := DDATABASE
											aCols[n,nPosTpcom]  := "02" // Produto
										EndIf

									EndIf

								EndIf
								
							EndIf 
							
						EndIf
					/*--------------------------------------------------------------+
					| Sim / Sim / sim -  paga comissão pelo percentual do vendedor  |           
					+--------------------------------------------------------------*/
					ElseIf cRepreClt == "2" .And. cPgCliente == "2" .And. cPgvend1 == "2" .And. _nPercCli <= 0 

						If _aLidos[_nLidos][05] > 0
							aCols[n,nPosTab]    := _aLidos[_nLidos][04]
							aCols[n,nPosCom1]   := _aLidos[_nLidos][05]
							aCols[n,nPosComis1] := Posicione("SA3",1, xFilial("SA3+")+cVend1,"A3_COMIS")
							aCols[n,nPosComis2] := 0
							aCols[n,nPosComis3] := 0
							aCols[n,nPosComis4] := 0
							aCols[n,nPosComis5] := 0
							aCols[n,nPosRevCom] := AllTrim(_cComRev)
							aCols[n,nPosDtRvc]  := DDATABASE
							aCols[n,nPosTpcom]  := "03" // Vendedor
						Else 
							aCols[n,nPosTab]    := _aLidos[_nLidos][04]
							aCols[n,nPosCom1]   := 0
							aCols[n,nPosComis1] := 0
							aCols[n,nPosComis2] := 0
							aCols[n,nPosComis3] := 0
							aCols[n,nPosComis4] := 0
							aCols[n,nPosComis5] := 0
							aCols[n,nPosRevCom] := AllTrim(_cComRev)
							aCols[n,nPosDtRvc]  := DDATABASE
							aCols[n,nPosTpcom]  := "03" // Zerada
						EndIf
					/*--------------------------------------------------------------+
					| Não / Sim / Não    -    Não paga comissão                     |
					+--------------------------------------------------------------*/
					Else
						aCols[n,nPosTab]    := _aLidos[_nLidos][04]
						aCols[n,nPosCom1]   := 0
						aCols[n,nPosComis1] := 0
						aCols[n,nPosComis2] := 0
						aCols[n,nPosComis3] := 0
						aCols[n,nPosComis4] := 0
						aCols[n,nPosComis5] := 0
						aCols[n,nPosRevCom] := AllTrim(_cComRev)
						aCols[n,nPosDtRvc]  := DDATABASE
						aCols[n,nPosTpcom]  := "04" // Zerada
					EndIf
							
				EndIf

			Next _nLidos 	

		Else 
			/*----------------------------------------------------------------------------+
			| Se entrar nesta regra é porque o produto não possui cadastro na tabela PAA  |
			| e a revisão cadastrada no produto para tipo PA e TES que gera duplicata.    |
			+----------------------------------------------------------------------------*/
			If _cTes == "S" .And. _cTipoProd == "PA"
				_cMsg := ""
				_cMsg := "Não existe tabela de vigência e revisão cadastrado para o produto  "+Alltrim(aCols[n,nPosProduto])+" , "
				_cMsg += "Portanto, não será permitido prosseguir sem o produto devidamente cadastrado na tabela de Vigência/Revisão de comissão!"+ENTER 
				_cMsg += "Favor contatar o seu gestor para regularizar o cadastro!"+ENTER 
				
				Aviso("Atencão - M410LIOK ",_cMsg, {"Ok"}, 2)
				_lRet := .F.
			
			EndIf
			
		EndIf
		
	Else
		/*----------------------------------------------------------------------------+
		| Se entrar nesta regra é porque os cadastros estão errados, ou realmente não |
		| será pago nenhuma comissão ao vendedor                                      |
		+----------------------------------------------------------------------------*/
		If _cTes == "S" .And. INCLUI

			_cQueryB := ""

			If Select("WK_PAA") > 0
				WK_PAA->(DbCloseArea())
			EndIf

			//IF AllTrim(aCols[n,nPosProduto]) $ "0291.054.04"
			//	xpto := 2
			//Endif

			_cQueryB := "SELECT * FROM "+RetSqlName("PAA")+" AS PAA "+ENTER
			_cQueryB += "WHERE PAA_FILIAL = '"+xFilial("PAA")+"' "+ENTER
			_cQueryB += " AND PAA_COD  = '"+AllTrim(aCols[n,nPosProduto])+"'  "+ENTER 
			_cQueryB += " AND PAA_REV  = '"+AllTrim(_cComRev)+"'  "+ENTER 
			_cQueryB += " AND PAA_CODTAB = '"+AllTrim(_cTabCom)+"' "+ENTER 
			_cQueryB += " AND PAA.D_E_L_E_T_ = ' ' "+ENTER 
			_cQueryB += " ORDER BY  PAA_DTVIG1, PAA_DTVIG2 "+ENTER 

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

			If Len(_aLidos) > 0 //-- AQUI

				For _nLidos:= 1 To Len(_aLidos) 

					If _aLidos[_nLidos][01] == aCols[n,nPosProduto] 

						aCols[n,nPosTab]    := _cTabCom
						aCols[n,nPosCom1]   := _nComissao
						aCols[n,nPosComis1] := 0
						aCols[n,nPosComis2] := 0
						aCols[n,nPosComis3] := 0
						aCols[n,nPosComis4] := 0
						aCols[n,nPosComis5] := 0
						aCols[n,nPosRevCom] := AllTrim(_cComRev)
						aCols[n,nPosDtRvc]  := DDATABASE
						aCols[n,nPosTpcom]  := "99" // Acertar Cadartro
					
					EndIf				
				
				Next _nLidos
			
			Else 
				/*----------------------------------------------------------------------------+
				| Se entrar nesta regra é porque o produto não possui cadastro na tabela PAA  |
				| e a revisão cadastrada no produto para tipo PA e TES que gera duplicata.    |
				+----------------------------------------------------------------------------*/
				//IF AllTrim(aCols[n,nPosProduto]) $ "0291.054.04"
				//	xpto := 2
				//Endif

				If _cTes == "S" .And. _cTipoProd == "PA"
					_cMsg := ""
					_cMsg := "Não existe tabela de vigência e revisão cadastrado para o produto  "+Alltrim(aCols[n,nPosProduto])+" , "
					_cMsg += "Portanto, não será permitido prosseguir sem o produto devidamente cadastrado na tabela de Vigência/Revisão de comissão!"+ENTER 
					_cMsg += "Favor contatar o seu gestor para regularizar o cadastro!"+ENTER 
					
					Aviso("Atencão - M410LIOK ",_cMsg, {"Ok"}, 2)
					_lRet := .F.
				
				EndIf
			
			EndIf

		EndIf	
	
	EndIf 

EndIf
//Fim projeto comissões

If Select("WK_PAA") > 0
	WK_PAA->(DbCloseArea())
EndIf
If Select("WK_PAW") > 0
	WK_PAW->(DbCloseArea())
EndIf
If Select("WK_PW") > 0
	WK_PW->(DbCloseArea())
EndIf

RestArea(_aAreaSA1)
RestArea(_aAreaSA2)
RestArea(_aAreaSB1)
RestArea(_aAreaSC5)
RestArea(_aAreaSC6)
RestArea(_aAreaSC9)
RestArea(_aAreaEE7)
RestArea(_aAreaEE8)
RestArea(_aArea)

Return _lRet

/*/{Protheus.doc} BeVldCusto
Função para avisar o usuário caso o custo do produto menor que a saída (para TES que atualiza estoque)...            
@type function Validação
@version  1.00
@author Fabio F Sousa
@since 12/05/2017
@return Logical, Valida ou nao a informação
/*/
Static Function BeVldCusto()

Local lRetorno  := .T.
Local nPosItem  := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_ITEM"    })
Local nPosProd  := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_PRODUTO" })
Local nPosLocal := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_LOCAL"   })
Local nPosPreco := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_PRCVEN"  })
Local nPosTES   := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_TES"     })
Local nPosCfop  := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_CF"      })
Local cLocTran  := AllTrim( GetMv( "MV_LOCTRAN",,"30") )
Local i as number

If AllTrim( Upper( FunName() ) ) $ "RPC"
	Return lRetorno // Não validar se automático...
EndIf

For i := 1 To Len( aCols )
	If AllTrim( aCols[i][nPosLocal] ) == AllTrim( cLocTran )
		ApMsgAlert( 'Local informado (' + AllTrim( aCols[i][nPosLocal] ) +') específico para local em trânsito, informar o local de destino do produto!', 'Atenção' )
		lRetorno := .F.
	EndIf

	If Left( AllTrim( aCols[i][nPosCfop] ), 1) <> "7"
		SF4->(dbSetOrder(1))

		If SF4->( dbSeek( xFilial("SF4") + aCols[i][nPosTES] ) )
			If AllTrim( SF4->F4_ESTOQUE ) == "S"
				SB2->(dbSetOrder(1))
				
				If SB2->( dbSeek( xFilial("SB2") + Padr( aCols[i][nPosProd], TamSX3("B2_COD")[1]) + Padr( aCols[i][nPosLocal], TamSX3("B2_LOCAL")[1]) ) )
					If AllTrim( aCols[i][nPosCfop] ) $ "5152/6152/7152" // Se remessa de transferencia entre filiais não pode ser maior que custo...
						If aCols[i][nPosPreco] > SB2->B2_CM1 .And. SB2->B2_CM1 > 0
							Aviso("M410LIOK / BeVldCusto",	"Aviso..."  + CRLF + ;
															"Preço do item " + aCols[i][nPosItem] + " Produto: " + aCols[i][nPosProd] + " não pode ser maior que o valor de custo do produto:" + CRLF + ;
															"Custo Atual: " + Transform( SB2->B2_CM1, "@R 999,999,999.99") + CRLF + ;
															"Não será permitida a confirmação do Pedido!",{"Ok"},3)
							lRetorno := .F.
						EndIf
					Else
						If aCols[i][nPosPreco] < SB2->B2_CM1 .And. SB2->B2_CM1 > 0 .And. AllTrim( SF4->F4_DUPLIC ) == "S"
							Aviso("M410LIOK / BeVldCusto",	"Aviso..."  + CRLF + ;
															"Preço de Venda utilizada para o item " + aCols[i][nPosItem] + " Produto: " + aCols[i][nPosProd] + " Menor que o Custo Atual do Produto:" + CRLF + ;
															"Custo Atual: " + Transform( SB2->B2_CM1, "@R 999,999,999.99"),{"Ok"},3)
						ElseIf aCols[i][nPosPreco] > (SB2->B2_CM1 * 9) .And. SB2->B2_CM1 > 0
							Aviso("M410LIOK / BeVldCusto",	"Aviso..."  + CRLF + ;
															"Preço de Venda utilizada para o item " + aCols[i][nPosItem] + " Produto: " + aCols[i][nPosProd] + " Com Margem acima de 1.000% para o Produto:" + CRLF + ;
															"Custo Atual: " + Transform( SB2->B2_CM1, "@R 999,999,999.99") + CRLF + ;
															"Confirme se não é Erro ou Problema com Unidade de Medida ou Erro na Digitação ou o Custo está Indevido!",{"Ok"},3)
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Next

Return lRetorno


/*/{Protheus.doc} fVldOrdSep
Função para avisar o usuário caso haja ordem de separação para o item que atualiza estoque no pedido...
@type function Tela
@version  1.00
@author Fabio F Sousa 
@since 25/06/2020
@return logical, validaçao ou nao a informação
/*/
Static Function fVldOrdSep()

Local lRetorno  := .T.
Local nPosNum   := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_NUM"     })
Local nPosTES   := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_TES"     })
Local i         := 0

If AllTrim( Upper( FunName() ) ) $ "RPC"
	Return lRetorno // Não validar se automático...
EndIf

For i := 1 To Len( aCols )
    SF4->(dbSetOrder(1))

    If SF4->( dbSeek( xFilial("SF4") + aCols[i][nPosTES] ) )
        If AllTrim( SF4->F4_ESTOQUE ) == "S"
            dbSelectArea("CB7")
            dbSetOrder(2)
            If CB7->( dbSeek( xFilial("CB7") + aCols[i][nPosNum] ) )
                Aviso("M410LIOK / fVldOrdSep",	"Aviso..."  + CRLF + ;
                                                "Pedido possui Ordem de Separação, ação não permitida" + CRLF + ;
                                                "Defazer separações caso feito e estornar a OS para prosseguir!",{"Ok"},3)
                lRetorno := .F.
                Exit
            EndIf
        EndIf
    EndIf
Next

Return lRetorno


/*/{Protheus.doc} fVldNCM
Função para validar se produto possui NCM preenchido...
@type function Validacao	
@version  1.00
@author Fabio F Sousa  
@since 07/02/2020
@return logical, validaçao ou nao a informação
/*/
Static Function fVldNCM()

Local lRetorno  := .T.
Local nPosProd  := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_PRODUTO"     })
Local i         := 0

If AllTrim( Upper( FunName() ) ) $ "RPC"
	Return lRetorno // Não validar se automático...
EndIf

For i := 1 To Len( aCols )
	SB1->(dbSetOrder(1))
	If !(aCols[i][nPosProd] == NIL .Or. Empty( aCols[i][nPosProd] ))
		If SB1->( dbSeek( xFilial("SB1") + aCols[i][nPosProd] ) )
			If Empty( SB1->B1_POSIPI )
				Aviso("M410LIOK / fVldNCM",	"Aviso..."  + CRLF + ;
												"Produto informado não possui NCM classificado, favor informar o fiscal." + CRLF + ;
												"Para prosseguir com a saída deste item, é necessário corrigir o produto!",{"Ok"},3)
				lRetorno := .F.
				Exit
			EndIf
		EndIf
	EndIf
Next

Return lRetorno
