#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TRYEXCEPTION.CH"

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

/*/{Protheus.doc} M410ALOK
Executado antes de iniciar a altera��o do pedido de venda
@type function Ponto de Entrada
@version  1.00
@author Fabio Carneiro dos Santos 
@since 05/07/2022
@return character, sem retorno
/*/
User Function M410ALOK()

Local aArea      := GetArea()
Local aAreaSA1	 := SA1->(GetArea())
Local aAreaSC5	 := SC5->(GetArea())
Local aAreaSC6	 := SC6->(GetArea())
Local aAreaSC9	 := SC9->(GetArea())
Local _lRet      := .T.
Local _aLidos    := {}
Local _nLidos    := 0
Local _cQuery    := ""
Local _nComissao := 0
Local _cTes      := ""
Local _cComRev   := ""
Local _cTabCom   := ""
Local cFilComis  := GetMv("QE_FILCOM")
Local cRepreClt  := ""
Local cPgvend1   := ""
Local _nPercCli  := 0
Local _cPaaRev   := ""
Local _cPaaCom   := ""
Local _cPaaCod   := ""
/*---------------------------------------------------------------------------------------------+
| INICIO : Projeto revisao de Comiss�o especifico QUALY - 05/07/2022 - Fabio Carneiro          |
+----------------------------------------------------------------------------------------------+
| 1 - Quando ocorrer uma altera��o de revis�o ser� gravado no cadastro do produto o ultimo     |
|     % de comiss�o, codigo da tabela e ultima revis�o;                                        |
| 2 - Se a revis�o dor diferente do que esta no pedido de vendas gera tabela PAW               |
| 3 - Se o pedido de vendas for Normal e a filial estiver preenchida no parametro QE_FILCOM,   | 
|     entra na regra para fazer as devidas valida��es.                                         |      
+----------------------------------------------------------------------------------------------*/
If cfilAnt $ cFilComis

	cPgCliente  := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_XPGCOM")  // 1 = N�o / 2 = Sim
	cRepreClt   := Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_XCLT")                      // 1 = N�o / 2 = Sim
	cPgvend1    := Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_XPGCOM")                    // 1 = N�o / 2 = Sim
	_nPercCli   := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_XCOMIS1") // Percentual de Comiss�o no Cliente
	/*-----------------------------------------------------------------------+
	| a) Se for comiss�o por produto entra na regra de revis�o de comiss�o  |
	| b) N�o / Sim / sim  -  Paga comiss�o pelo Produto                     | 
	+-----------------------------------------------------------------------*/
	If cRepreClt == "1" .And. cPgCliente == "2" .And. cPgvend1 == "2" .And. _nPercCli <= 0 

		If Select("TRB1") > 0
			TRB1->(DbCloseArea())
		EndIf

		_cQuery := "SELECT * FROM "+RetSqlName("SC6")+" AS SC6 WITH (NOLOCK) "+ENTER
		_cQuery += "INNER JOIN "+RetSqlName("SF4")+" AS SF4 WITH (NOLOCK) ON F4_FILIAL = SUBSTRING(C6_FILIAL,1,2) "+ENTER
		_cQuery += " AND F4_CODIGO = C6_TES "+ENTER
		_cQuery += " AND SF4.D_E_L_E_T_ = ' ' "+ENTER
		_cQuery += "WHERE C6_FILIAL  = '"+xFilial("SC6")+"' "+ENTER
		_cQuery += " AND C6_NUM  = '"+AllTrim(SC6->C6_NUM)+"' "+ENTER 
		_cQuery += " AND C6_CLI  = '"+AllTrim(SC6->C6_CLI)+"' "+ENTER 
		_cQuery += " AND C6_LOJA = '"+AllTrim(SC6->C6_LOJA)+"' "+ENTER
    	_cQuery += " AND F4_DUPLIC = 'S' "+ENTER 
		_cQuery += " AND SC6.D_E_L_E_T_ = ' ' "+ENTER 
		_cQuery += "ORDER BY C6_PRODUTO "+ENTER 

		TcQuery _cQuery ALIAS "TRB1" NEW

		TRB1->(DbGoTop())

		While TRB1->(!Eof())
				
			_nComissao  := Posicione("SB1",1,xFilial("SB1")+TRB1->C6_PRODUTO,"B1_COMIS")
			_cTes       := Posicione("SF4",1,xFilial("SF4")+TRB1->C6_TES,"F4_DUPLIC")
			_cComRev    := Posicione("SB1",1,xFilial("SB1")+TRB1->C6_PRODUTO,"B1_XREVCOM")  
			_cTabCom    := Posicione("SB1",1,xFilial("SB1")+TRB1->C6_PRODUTO,"B1_XTABCOM")  
			_cPaaRev    := Posicione("PAA",1,xFilial("PAA")+TRB1->C6_PRODUTO+_cTabCom+_cComRev,"PAA_REV")
			_cPaaCom    := Posicione("PAA",1,xFilial("PAA")+TRB1->C6_PRODUTO+_cTabCom+_cComRev,"PAA_CODTAB")
			_cPaaCod    := Posicione("PAA",1,xFilial("PAA")+TRB1->C6_PRODUTO+_cTabCom+_cComRev,"PAA_COD")
			/*-----------------------------------------------------------------------------------------+
			| Se existir o produto cadastrado na tabela PAA com a revis�o que estiver no cadastro do   |
			| produto, valida a proxima regra.                                                         |
			+-----------------------------------------------------------------------------------------*/
			If _cPaaRev == _cComRev .And. _cPaaCom == _cTabCom .And. _cPaaCod == TRB1->C6_PRODUTO
				/*-----------------------------------------------------------------------------------------+
				| Se % de comiss�o que esta no produto � diferente do que esta no pedido de vendas ou      |
				| a revis�o � diferente do pedido de vendas ou a tabela � diferente grava no array _aLidos |
				| ira gravr as informa��es na tabela PAW para verificar na manipula��o na linha do acols   | 
				+-----------------------------------------------------------------------------------------*/
				If _nComissao <> TRB1->C6_COMIS1 .Or. TRB1->C6_XREVCOM <> _cComRev .Or. TRB1->C6_XTABCOM <> _cTabCom 
				
					Aadd(_aLidos,{TRB1->C6_FILIAL,;   // 01
								TRB1->C6_NUM,;      // 02
								TRB1->C6_CLI,;      // 03
								TRB1->C6_LOJA,;     // 04
								TRB1->C6_PRODUTO,;  // 05
								TRB1->C6_ITEM,;     // 06
								TRB1->C6_QTDVEN,;   // 07
								TRB1->C6_PRCVEN,;   // 08 
								TRB1->C6_XTABCOM,;  // 09 
								TRB1->C6_XREVCOM,;  // 10
								TRB1->C6_XDTRVC,;   // 11 
								TRB1->C6_COMIS1})   // 12
				EndIf
			
			EndIf

			TRB1->(DbSkip())

		EndDo
		/*------------------------------------------------------------------------------------+
		| Se houver conteudo no acols ser� alimentado a tabela PAW, para fazer a compara��o.  | 
		| Este ponto de entrada grava ao iniciar a altera��o.                                 | 
		+------------------------------------------------------------------------------------*/
		If Len(_aLidos) > 0

			For _nLidos:= 1 To Len(_aLidos) 
				/*------------------------------------------------------------------------------------+
				| Ser� checado se j� exiuste o registro com o status ( 1=Alterado pelo usu�rio )      | 
				| Se j� existe somente regrava para n�o criar um novo registro                        | 
				+------------------------------------------------------------------------------------*/
				DbSelectArea("PAW")
				PAW->(DbSetOrder(1)) //PAW_FILIAL+PAW_PEDIDO+PAW_COD+PAW_ITEM+PAW_CODTAB+PAW_REV+PAW_STATUS
				PAW->(DbGoTop())
				If PAW->(DbSeek(xFilial("PAW")+_aLidos[_nLidos][02]+_aLidos[_nLidos][05]+_aLidos[_nLidos][06]+_aLidos[_nLidos][09]+_aLidos[_nLidos][10]+"1"))    

					RecLock("PAW",.F.)

					PAW->PAW_FILIAL := _aLidos[_nLidos][01] 
					PAW->PAW_PEDIDO := _aLidos[_nLidos][02]
					PAW->PAW_CODCLI := _aLidos[_nLidos][03]
					PAW->PAW_LOJA   := _aLidos[_nLidos][04]
					PAW->PAW_COD    := _aLidos[_nLidos][05]
					PAW->PAW_ITEM   := _aLidos[_nLidos][06]
					PAW->PAW_QTD    := _aLidos[_nLidos][07]
					PAW->PAW_PRECO  := _aLidos[_nLidos][08]
					PAW->PAW_CODTAB := _aLidos[_nLidos][09]
					PAW->PAW_REV    := _aLidos[_nLidos][10]
					PAW->PAW_DATA   := StoD(_aLidos[_nLidos][11])
					PAW->PAW_COMIS1 := _aLidos[_nLidos][12]
					PAW->PAW_DTAREG := DDATABASE
					PAW->PAW_STATUS := "1"
					PAW->PAW_USRNOM := AllTrim(cUserName)

					PAW->(MsUnlock())

				/*------------------------------------------------------------------------------------+
				| Ser� checado se j� exiuste o registro com o status ( 2=Revisado pelo Gestor )       | 
				| Se j� existe somente regrava para n�o criar um novo registro                        | 
				+------------------------------------------------------------------------------------*/
				ElseIf PAW->(DbSeek(xFilial("PAW")+_aLidos[_nLidos][02]+_aLidos[_nLidos][05]+_aLidos[_nLidos][06]+_aLidos[_nLidos][09]+_aLidos[_nLidos][10]+"2"))    

					RecLock("PAW",.F.)

					PAW->PAW_FILIAL := _aLidos[_nLidos][01] 
					PAW->PAW_PEDIDO := _aLidos[_nLidos][02]
					PAW->PAW_CODCLI := _aLidos[_nLidos][03]
					PAW->PAW_LOJA   := _aLidos[_nLidos][04]
					PAW->PAW_COD    := _aLidos[_nLidos][05]
					PAW->PAW_ITEM   := _aLidos[_nLidos][06]
					PAW->PAW_QTD    := _aLidos[_nLidos][07]
					PAW->PAW_PRECO  := _aLidos[_nLidos][08]
					PAW->PAW_CODTAB := _aLidos[_nLidos][09]
					PAW->PAW_REV    := _aLidos[_nLidos][10]
					PAW->PAW_DATA   := StoD(_aLidos[_nLidos][11])
					PAW->PAW_COMIS1 := _aLidos[_nLidos][12]
					PAW->PAW_DTAREG := DDATABASE
					PAW->PAW_STATUS := "2"
					PAW->PAW_USRNOM := AllTrim(cUserName)

					PAW->(MsUnlock())

				/*------------------------------------------------------------------------------------+
				| Ser� checado se n�o existem o registro com o status (1=Alterado ou 2=Revisado )     | 
				| Se n�o existe grava um novo registro com os dados da ultima revis�o do produto.     | 
				+------------------------------------------------------------------------------------*/
				Else 

					RecLock("PAW",.T.)

					PAW->PAW_FILIAL := _aLidos[_nLidos][01] 
					PAW->PAW_PEDIDO := _aLidos[_nLidos][02]
					PAW->PAW_CODCLI := _aLidos[_nLidos][03]
					PAW->PAW_LOJA   := _aLidos[_nLidos][04]
					PAW->PAW_COD    := _aLidos[_nLidos][05]
					PAW->PAW_ITEM   := _aLidos[_nLidos][06]
					PAW->PAW_QTD    := _aLidos[_nLidos][07]
					PAW->PAW_PRECO  := _aLidos[_nLidos][08]
					PAW->PAW_CODTAB := _aLidos[_nLidos][09]
					PAW->PAW_REV    := _aLidos[_nLidos][10]
					PAW->PAW_DATA   := StoD(_aLidos[_nLidos][11])
					PAW->PAW_COMIS1 := _aLidos[_nLidos][12]
					PAW->PAW_DTAREG := DDATABASE
					PAW->PAW_STATUS := "1"
					PAW->PAW_USRNOM := AllTrim(cUserName)

					PAW->(MsUnlock())

				Endif 													

			Next _nLidos

		EndIf

	EndIf

EndIf

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf
If Select("PAW") > 0
	PAW->(DbCloseArea())
EndIf

RestArea(aAreaSA1)
RestArea(aAreaSC5)
RestArea(aAreaSC6)
RestArea(aAreaSC9)
RestArea(aArea)

Return _lRet  
