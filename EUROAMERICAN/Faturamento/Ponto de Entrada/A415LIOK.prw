#Include "protheus.ch"
#Include 'parmtype.ch'
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "ap5mail.ch"
#Include "RwMake.Ch"

#DEFINE ENTER chr(13) + chr(10)
/*/{Protheus.doc} A415LIOK 
Rotina para validar a quantidade minima de venda sugerida de acordo com a unidade de expedição e comissões 
@type function Ponto de Entrada
@author QualyCril 
@since 15/04/2022
@version 1.0
@History Ajustado em 30/01/2022 para o projeto unidade de expedição 
@History Ajustado fonte para tratar unidade de expedição e comissão QUALY - 01/03/2022 - Fabio Carneiro 
@History Ajustado fonte para tratar revisão de comissão QUALY - 24/06/2022 - Fabio Carneiro 
@History Ajustado em 04/07/2022 tratamento referente ao peso liquido e peso bruto - Fabio carneiro dos Santos
@History Ajustado em 09/09/2022 tratamento referente a não considerar comissão se o item estiver zerado - Fabio carneiro dos Santos
@return Logical, permite ou nao a mudança de linha
/*/

User Function A415LIOK()

Local aArea         := GetArea()
Local aAreaSA1      := SA1->(GetArea())
Local aAreaSB1      := SB1->(GetArea())
Local aAreaSCK      := SCK->(GetArea())
Local aAreaSCJ      := SCJ->(GetArea())
Local aAreaSC6      := SC6->(GetArea())
Local aAreaSC5      := SC5->(GetArea())
Local _lRet         := .T.
//variaveis projeto comissão qualy - fabio carneiro - 23/02/2022
Local _cQueryB  	:= "" 
Local _aLidos   	:= {}
Local _nLidos   	:= 0
Local _nPercCli     := 0
Local cPgCliente    := ""
Local cRepreClt     := ""
Local cPgvend1      := ""
Local cVend1        := ""
Local _cComRev      := ""
Local _cTabCom      := ""
Local _cTes         := ""
Local _cTipoProd    := ""
Local cFilComis     := GetMv("QE_FILCOM")
//variaveis projeto unidade de expedição - fabio carneiro - 11/01/2022
Local _nQtdMinima   := 0 
Local _nQtdVenda    := 0
Local _nRetMod      := 0
Local _nQtdeEmb     := 0
Local _cUnExpedicao := 0
Local _cDescProduto := "" 
Local _cUnidMedida  := ""
Local _cMsg         := ""
Local _cMsgA        := ""
// Tratamento do peso liquido e peso bruto 01/07/2022 - Fabio Carneiro 
Local _nPesoLiq     := 0
Local _nPesoBru     := 0

If cModulo=="LOJ"  //  Se For loja nao executa = MAA 01/11/2021
	Return _lRet
End
/*
+------------------------------------------------------------------+
| Projeto UNIDADE DE EXPEDIÇÃO - 30/01/2022 - Fabio Carneiro       |
+------------------------------------------------------------------+
*/
DbSelectArea("SB1")
DbSetOrder(1)
If DbSeek(xFilial("SB1")+TMP1->CK_PRODUTO)

	_cUnExpedicao    := Posicione("SB1",1,xFilial("SB1")+TMP1->CK_PRODUTO,"B1_XUNEXP")
	_nQtdMinima      := Posicione("SB1",1,xFilial("SB1")+TMP1->CK_PRODUTO,"B1_XQTDEXP") 
	_cDescProduto    := Posicione("SB1",1,xFilial("SB1")+TMP1->CK_PRODUTO,"B1_DESC") 
	_cUnidMedida     := Posicione("SB1",1,xFilial("SB1")+TMP1->CK_PRODUTO,"B1_UM")
	_nPesoLiq        := Posicione("SB1",1,xFilial("SB1")+TMP1->CK_PRODUTO,"B1_PESO") 
	_nPesoBru        := Posicione("SB1",1,xFilial("SB1")+TMP1->CK_PRODUTO,"B1_PESBRU") 


	If !Empty(_cUnExpedicao) .And. _nQtdMinima > 0
		_nRetMod         := MOD(TMP1->CK_QTDVEN,_nQtdMinima)
		_nQtdVenda       := (TMP1->CK_QTDVEN-_nRetMod)
		_nQtdeEmb        := (_nQtdVenda/_nQtdMinima)
	EndIf 

	If Empty(_cUnExpedicao) .Or. _nQtdMinima == 0

		_cMsgA := "Este produto "+Alltrim(TMP1->CK_PRODUTO)+" está sem unidade de expedição(B1_XUNEXP) e a quantidade minima de embalagem(B1_XQTDEXP) no cadastro do produto  "+ ENTER
		_cMsgA += "Verificar com os responsaveis da EXPEDIÇÃO, LABORATORIO e OPERAÇÕES para fazer o preenchimento correto destas informações." + ENTER
		_cMsgA += "Será necessario clicar no botão cancelar e após o cadastro preenchido poderá incluir ou alterar o pedido novamente !!!"
		_cMsgA += "" + ENTER
		_cMsgA += "" + ENTER
		_cMsgA += "" + ENTER
		_cMsgA += "" + ENTER
		_cMsgA += "Acionar o atendendente de vendas para solicitar a regularização do cadastro de produtos, para permitir digitar o orçamento de vendas !!!"

		Aviso("Atencão - A415LIOK ",_cMsgA, {"Ok"}, 2)

		_lRet := .F.

	EndIf	

	If !Empty(_cUnExpedicao) .And. _nQtdMinima > 0

		If TMP1->CK_QTDVEN <> _nQtdVenda 

			_cMsg := "Favor verificar a quantidade digitada do produto "+Alltrim(TMP1->CK_PRODUTO)+" , "
			_cMsg += "que está fora do cálculo do minimo de embalagem, foi digitado a quantidade de "+Transform(TMP1->CK_QTDVEN, "@E 999,999,999.99")+" ! "+ENTER
			_cMsg += "Portanto, para a regra do minimo de embalagem deverá alterar a quantidade para "+Transform(If(_nQtdVenda < _nQtdMinima,_nQtdMinima,_nQtdVenda), "@E 999,999,999.99")+" de acordo com o volume e espécie !"+ENTER  
			_cMsg += "Não será permitido prosseguir se estiver em desacordo com minimo de embalagem, sugerimos digitar a quantidade "+Transform(If(_nQtdVenda < _nQtdMinima,_nQtdMinima,_nQtdVenda), "@E 999,999,999.99")+" !"+ENTER 
			_cMsg += "Caso tenha que ser a quantidade "+Transform(TMP1->CK_QTDVEN, "@E 999,999,999.99")+", entrar em contato com o COMERCIAL !"+ENTER 
			
			Aviso("Atencão - A415LIOK ",_cMsg, {"Ok"}, 2)
			
			_lRet := .F.

		EndIf
	
	EndIf

	// Tratamento referente ao peso liquido e peso bruto - fabio carneiro 04/07/2022

	If _nPesoLiq <= 0 .Or. _nPesoBru <= 0

		_cMsg := "Este produto está com o peso liquido e peso bruto do produto "+Alltrim(TMP1->CK_PRODUTO)+" ,sem preenchimento no cadastro de produtos!"+ENTER
		_cMsg += "Favor solicitar a regularização com equipe de atendimento, somente ápos o preenchimento do cadastro será possivel prosseguir! "+ENTER

		Aviso("Atencão - A415LIOK ",_cMsg, {"Ok"}, 2)
			
		_lRet := .F.

	EndIf


EndIf 
/*---------------------------------------------------------------------------------------------+
| INICIO    : Projeto Comissão especifico QUALY - 31/05/2022 - Fabio Carneiro                  |
+----------------------------------------------------------------------------------------------+
| ALTERAÇÃO : Projeto revisao de Comissão especifico QUALY - 24/06/2022 - Fabio Carneiro       |
+----------------------------------------------------------------------------------------------+
| 1 - Quando for incluir ou alterar um orçamento pega a ultima revisão que estver no cadastro  |
|     de produto contendo % de comissão, ultima revisão e tabela;                              |
| 2 - Se a filial estiver preenchida no parametro QE_FILCOM, entra na regra para fazer as      | 
|     devidas validações.																	   |
| 3 - Se o produto na PAA estiver com a comissão estiver zerada não entra na regra para calcu- | 
|     lar a comissão em 09/09/2022 - Fabio carneiro.                                           |
+----------------------------------------------------------------------------------------------*/
If cfilAnt $ cFilComis

	cPgCliente  := Posicione("SA1",1,xFilial("SA1")+M->CJ_CLIENTE+M->CJ_LOJA,"A1_XPGCOM")   // 1 = Não / 2 = Não
	cRepreClt   := Posicione("SA3",1,xFilial("SA3")+M->CJ_VEND1,"A3_XCLT")                  // 1 = Não / 2 = Não
	cPgvend1    := Posicione("SA3",1,xFilial("SA3")+M->CJ_VEND1,"A3_XPGCOM")                // 1 = Não / 2 = Não
	cVend1      := Posicione("SA3",1,xFilial("SA3")+M->CJ_VEND1,"A3_COD")                   // Codigo do vendedor Cadastro 
	_nPercCli   := Posicione("SA1",1,xFilial("SA1")+M->CJ_CLIENTE+M->CJ_LOJA,"A1_XCOMIS1")  // Percentual de Comissão no Cliente
	_cComRev    := Posicione("SB1",1,xFilial("SB1")+TMP1->CK_PRODUTO,"B1_XREVCOM")          // Ultima revsão cadastrada na tabela PAA
	_cTabCom    := Posicione("SB1",1,xFilial("SB1")+TMP1->CK_PRODUTO,"B1_XTABCOM")          // Ultimo codigo de tabela cadastrada na tabela PAA
	_cTes       := Posicione("SF4",1,xFilial("SF4")+TMP1->CK_TES,"F4_DUPLIC")               // TES do acols  
	_cTipoProd  := Posicione("SB1",1,xFilial("SB1")+TMP1->CK_PRODUTO,"B1_TIPO")             // Tipo de produto 

	DbSelectArea("SB1")
	DbSetOrder(1)
	If DbSeek(xFilial("SB1")+TMP1->CK_PRODUTO)

		If Select("WK_PAA") > 0
			WK_PAA->(DbCloseArea())
		EndIf

		_cQueryB := "SELECT * FROM "+RetSqlName("PAA")+" AS PAA "
		_cQueryB += "WHERE PAA_FILIAL = '"+xFilial("PAA")+"' ""
		_cQueryB += " AND PAA_COD = '"+AllTrim(TMP1->CK_PRODUTO)+"'  " 
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

		If  Len(_aLidos)  > 0

			For _nLidos:= 1 To Len(_aLidos) 
				/*------------------------------------------------------------------------------------+
				| Se o produto, revisão e tabela é igual ao que esta na tabela PAA, entra na regra    | 
				+------------------------------------------------------------------------------------*/
				If _aLidos[_nLidos][01] == TMP1->CK_PRODUTO .And. _cComRev == _aLidos[_nLidos][06] .And. _cTabCom == _aLidos[_nLidos][04]
					/*----------------------------------------------------------------------------------+
					| Sim e percentual preenchido no cadastro do cliente - Paga comissão pelo Cliente   | 
					+----------------------------------------------------------------------------------*/
					If cPgCliente == "2" .And. _nPercCli > 0 

						If _aLidos[_nLidos][05] > 0
							TMP1->CK_XTABCOM := _aLidos[_nLidos][04]
							TMP1->CK_XCOM1   := _aLidos[_nLidos][05]
							TMP1->CK_COMIS1  := _nPercCli
							TMP1->CK_XREVCOM := _aLidos[_nLidos][06]
							TMP1->CK_XDTRVC  := DDATABASE
							TMP1->CK_XTPCOM  := "01" // CLIENTE 
						Else 
							TMP1->CK_XTABCOM := _aLidos[_nLidos][04]
							TMP1->CK_XCOM1   := 0
							TMP1->CK_COMIS1  := 0
							TMP1->CK_XREVCOM := _aLidos[_nLidos][06]
							TMP1->CK_XDTRVC  := DDATABASE
							TMP1->CK_XTPCOM  := "01" // CLIENTE 
						EndIf
					/*---------------------------------------------------------+
					|  Não / Sim / sim  -  Paga comissão pelo Produto          | 
					+---------------------------------------------------------*/
					ElseIf cRepreClt == "1" .And. cPgCliente == "2" .And. cPgvend1 == "2" .And. _nPercCli <= 0

						If Posicione("SB1",1, xFilial("SB1")+TMP1->CK_PRODUTO,"B1_COMIS") == _aLidos[_nLidos][05] 

							If _aLidos[_nLidos][05] > 0
								TMP1->CK_XTABCOM := _aLidos[_nLidos][04]
								TMP1->CK_XCOM1   := _aLidos[_nLidos][05]
								TMP1->CK_COMIS1  := Posicione("SB1",1, xFilial("SB1")+TMP1->CK_PRODUTO,"B1_COMIS")
								TMP1->CK_XREVCOM := _aLidos[_nLidos][06]
								TMP1->CK_XDTRVC  := DDATABASE
								TMP1->CK_XTPCOM  := "02" // PRODUTO 
							Else 	
								TMP1->CK_XTABCOM := _aLidos[_nLidos][04]
								TMP1->CK_XCOM1   := 0
								TMP1->CK_COMIS1  := 0
								TMP1->CK_XREVCOM := _aLidos[_nLidos][06]
								TMP1->CK_XDTRVC  := DDATABASE
								TMP1->CK_XTPCOM  := "02" // PRODUTO 
							EndIf

						EndIf
					/*--------------------------------------------------------------+
					| Sim / Sim / sim -  paga comissão pelo percentual do vendedor  |           
					+--------------------------------------------------------------*/
					ElseIf cRepreClt == "2" .And. cPgCliente == "2" .And. cPgvend1 == "2" .And. _nPercCli <= 0
										
						If _aLidos[_nLidos][05] > 0
							TMP1->CK_XTABCOM := _aLidos[_nLidos][04]
							TMP1->CK_XCOM1   := _aLidos[_nLidos][05]
							TMP1->CK_COMIS1  := Posicione("SA3",1, xFilial("SA3+")+cVend1,"A3_COMIS")
							TMP1->CK_XREVCOM := _aLidos[_nLidos][06]
							TMP1->CK_XDTRVC  := DDATABASE
							TMP1->CK_XTPCOM  := "03" // VENDEDOR 
						Else 
							TMP1->CK_XTABCOM := _aLidos[_nLidos][04]
							TMP1->CK_XCOM1   := 0
							TMP1->CK_COMIS1  := 0
							TMP1->CK_XREVCOM := _aLidos[_nLidos][06]
							TMP1->CK_XDTRVC  := DDATABASE
							TMP1->CK_XTPCOM  := "03" // VENDEDOR 
						EndIf
					/*--------------------------------------+
					| Não paga comissão                     |
					+--------------------------------------*/
					Else
						TMP1->CK_XTABCOM := _aLidos[_nLidos][04]
						TMP1->CK_XCOM1   := _aLidos[_nLidos][05]
						TMP1->CK_COMIS1  := 0
						TMP1->CK_XREVCOM := _aLidos[_nLidos][06]
						TMP1->CK_XDTRVC  := DDATABASE
						TMP1->CK_XTPCOM  := "04" // ZERADA 
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
				_cMsg := "Não existe tabela de vigência e revisão cadastrado para o produto  "+Alltrim(TMP1->CK_PRODUTO)+" , "
				_cMsg += "Portanto, não será permitido prosseguir sem o produto devidamente cadastrado na tabela de Vigência/Revisão de comissão!"+ENTER 
				_cMsg += "Favor contatar o seu gestor para regularizar o cadastro!"+ENTER 
						
				Aviso("Atencão - A415LIOK ",_cMsg, {"Ok"}, 2)

				_lRet := .F.
				
			EndIf
	
		EndIf
	
	EndIf 

EndIf

RestArea(aAreaSA1)
RestArea(aAreaSB1)
RestArea(aAreaSCK)
RestArea(aAreaSCJ)
RestArea(aAreaSC5)
RestArea(aAreaSC6)
RestArea(aArea)

Return(_lRet)
