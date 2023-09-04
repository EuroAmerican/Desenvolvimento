#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#include "tryexception.ch"

#define ENTER chr(13) + chr(10)

/*/{Protheus.doc} MTA410T
Ponto de entrada para tratamento pedido de vendas 
@type function Ponto de Entrada
@author QualyCryl 
@version 1.0
@since 02/01/2013
@History Ajustado fonte para tratar a comissão QUALY e unidade de expedição - 31/05/2022 - Fabio Carneiro 
@History Ajustado fonte para tratar peso liquido e peso bruto - 31/05/2022 - Fabio Carneiro
@History Ajustado em 09/09/2022 tratamento referente a não considerar comissão se o item estiver zerado - Fabio carneiro dos Santos
@return character, sem retorno especificadao
/*/

User Function MTA410T()

//Declaracao de variaveis 

Local aArea     := GetArea()
Local aAreaSA1  := SA1->(GetArea())
Local aAreaSA3  := SA3->(GetArea())
Local aAreaDA0  := DA0->(GetArea())
Local aAreaDA1  := DA1->(GetArea())
Local aAreaSCJ  := SCJ->(GetArea())
Local aAreaSCK  := SCK->(GetArea())
Local aAreaSC5  := SC5->(GetArea())
Local aAreaSC6  := SC6->(GetArea())
Local aAreaSC9  := SC9->(GetArea())
Local aAreaEE7  := EE7->(GetArea())
Local aAreaEE8  := EE8->(GetArea())
Local aAreaSC7  := SC7->(GetArea())

Local cPVenda   := ""
Local dEntreg   := ""

Local nComiss   := 0	//M->C5_COMIS1  Alterado 05/02/18

Local nPrvFrete := 0
Local cEstFrete := ""
Local cNumOrc   := ""

Local _aPesos   := Array(2)

Local oError	:= Nil
Local lRet      := .T.
Local _aLidos   := {}
Local _nLidos   := 0
Local _cGerFin  := "" 
Local cTipoPed  := ""
Local cQry      := ""
Local dDtaEmis   

// variaveis projeto unidade de expedição 

Local cQueryI        := "" 
Local cQueryF        := ""
Local cQueryB        := ""
Local _nPesoB   	 := 0
Local _nPesoL   	 := 0
Local _nQtdVenda     := 0
Local _nVal          := 0
Local _nRetMod       := 0
Local _nQtdVol       := 0 
Local _nDifVol       := 0
Local _nPesoBruto    := 0
Local _nPesoLiquido  := 0
Local _nQtdMinima    := 0
Local _cUnExpedicao  := ""
Local _nVol          := 0
Local _nPasVol       := 1
Local _lAtVol        := .T.
Local _nValFd        := 0
Local _nPos0         := 0
Local _nCheck        := 0 
Local _aCheck        := {} 
Local _cUnExp        := "" 
Local _dEmis         := ""
Local _cPedido       := "" 

Private _aVolumes    := Array(14, 2)

//variaveis projeto comissão qualy - fabio carneiro - 23/02/2022
Private cPgCliente := ""
Private cRepreClt  := ""
Private cPgvend1   := ""
Private cVend1     := ""
Private _cQueryB   := ""
Private _nVlComis1 := 0
Private _nVlTotal  := 0
Private _nPercCli  := 0
Private cFilComis  := GetMv("QE_FILCOM")

// Variaveis referente ao tratamento revisão de comissão - 04/07/2022
Private _cRev      := ""
Private _cTabCom   := ""
Private _cQuery    := ""
Private _cLocal    := ""
Private _cNumSeq   := ""
Private _cTipoCom  := ""
Private _cComRev   := ""
Private	_nTabComis := 0
Private _nCliente  := 0
Private _nProduto  := 0
Private _nVendedor := 0

// unidade de expedição 
For _nVol := 1 to Len(_aVolumes)
	_aVolumes[_nVol, 1] := ""
	_aVolumes[_nVol, 2] := 0
Next _nVol

_aPesos[1] := 0
_aPesos[2] := 0

DbSelectArea("SC5")

cPVenda  := SC5->C5_NUM
dEntreg  := SC5->C5_FECENT
cTipoPed := SC5->C5_TIPO
dDtaEmis := SC5->C5_EMISSAO

// Atualiza SC6 conforme Data Informada no arquivo SC5
SC6->(DbSetOrder(1))
SC6->(MsSeek(xFilial("SC6") + cPVenda))

SA3->(DbSetOrder(1))
SA3->(MsSeek(xFilial("SA3") + SC5->C5_VEND1))

nComiss   := SA3->A3_COMIS	 //Adicionado 09/04/18

nCom    := 0
nPond   := 0
nComAtu := 0
nComNew := 0

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
cPedido     := Posicione("SC5",1,xFilial("SC5")+SC5->C5_NUM,"C5_VEND1") 
cRepreClt   := Posicione("SA3",1,xFilial("SA3")+cPedido,"A3_XCLT")  
cPgvend1    := Posicione("SA3",1,xFilial("SA3")+cPedido,"A3_XPGCOM")
cVend1      := Posicione("SA3",1,xFilial("SA3")+cPedido,"A3_COD") 
cPgCliente  := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_XPGCOM") 
_nPercCli   := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_XCOMIS1") 
//FIM

While !SC6->(EOF()) .And. SC6->C6_NUM == cPVenda

	If Empty(cNumOrc)
		cNumOrc := Subs(SC6->C6_PEDCLI, 1, 6)
	EndIf

	_cPedido := SC6->C6_NUM 

	SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1") + SC6->C6_PRODUTO))
		
	//Atualiza Campos Itens Pedido Venda
	
	If SC5->C5_TIPO == "N"

		dbSelectArea("SC6")
		RecLock("SC6",.F.)
			//Atualiza Segunda Unidade de Medida
			If SB1->B1_CONV > 0 .And. SC6->C6_UNSVEN == 0
				nQtdCalc := Iif ( SB1->B1_TIPCONV == 'D', SC6->C6_QTDVEN / SB1->B1_CONV, SC6->C6_QTDVEN * SB1->B1_CONV ) 
				If nQtdCalc > 0 
					SC6->C6_UNSVEN := nQtdCalc
				EndIf
			EndIf

			If !Empty(dEntreg) .And. Empty(SC6->C6_NOTA)
				SC6->C6_ENTREG := dEntreg
			EndIf
			
			If SB1->B1_TIPO != "PA"
				If SC5->C5_TIPO == "N"
					SC6->C6_U_FATOR := 1
					SC6->C6_U_FTNET := 1
				EndIf
				SC6->C6_U_CUSTD := SC6->C6_PRCVEN
				SC6->C6_U_CTNET := SC6->C6_PRCVEN
				SC6->C6_U_PRNET := SC6->C6_PRCVEN

			Else
				If SC5->C5_TIPO == "N"
					SC6->C6_U_FATOR := Round(SC6->C6_PRCVEN/Iif(SB1->B1_CUSTD == 0 .Or. Subs(SB1->B1_GRUPO,1,1) == "X", SC6->C6_PRCVEN,(SB1->B1_CUSTD * 1.03)),2)
					SC6->C6_U_FTNET := Round(SC6->C6_PRCVEN/Iif(SB1->B1_CUSTNET == 0 .Or. Subs(SB1->B1_GRUPO,1,1) == "X", SC6->C6_PRCVEN,(SB1->B1_CUSTNET * 1.03)),2)
				EndIf
				SC6->C6_U_CUSTD := SB1->B1_CUSTD
				SC6->C6_U_CTNET := SB1->B1_CUSTNET

				If cFilAnt $ "0200#0801"
					SC6->C6_U_PRNET := SC6->C6_PRCVEN  * (1 - (AliqICMS(SA1->A1_EST, SB1->B1_POSIPI)/100 + 0.0925)) //PIS + COFINS 9,25%
				Else
					SC6->C6_U_PRNET := SC6->C6_PRCVEN  * (1 - (AliqICMS(SA1->A1_EST, SB1->B1_POSIPI)/100 + 0.0365 + 0.0228))	//Alterado 20/01/17 - PIS + COFINS 3,65% e IRPJ + CSLL 2,28%
				EndIf

				DA1->(dbSetOrder(2))
				If DA1->(MsSeek(xFilial("DA1") + SC6->C6_PRODUTO + SC5->C5_TABELA))
					SC6->C6_ZPRCXTB	:= ROUND(((SC6->C6_PRCVEN /DA1->DA1_PRCVEN)-1)*100,2)
				EndIf

				SC6->C6_ZULTPVD	:= U_GETUPRVD(SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC6->C6_PRODUTO,"V")
				SC6->C6_ZULTVND	:= U_GETUPRVD(SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC6->C6_PRODUTO,"D")
			EndIf
		SC6->( MsUnlock() )

		// FS - Aviso que produto pode ser fracionado no calculo...
		If AllTrim( SB1->B1_UM ) == "KG" .And. AllTrim( SB1->B1_SEGUM ) <> "KG" .And. SB1->B1_TIPO == "PA" .And. !Empty( SB1->B1_SEGUM ) .And. SB1->B1_CONV <> 0
			If Mod( SC6->C6_QTDVEN, SB1->B1_CONV ) <> 0
				ApMsgInfo( "O item " + SC6->C6_ITEM + " possui quantidade divergente do fator de conversãoo, que podem gerar fracionamento no estoque de PA, verifique se a quantidade informada estÃ¡ realmente correta e serÃ¡ separada em embalagem especÃ­fica e repessada!", "AtenÃ§Ã£o" )
			EndIf
		EndIf

		If SC5->C5_TIPO == "N" .And. cFilAnt $ "0200#0201#0204#0205" //.And. !(Upper(Alltrim(FunName())) $ "YFATM001#MATA440")

			If Subs(SC6->C6_PRODUTO, 1, 1) == '8' .And. Subs(SC6->C6_PRODUTO, 4, 1) == '.'

				If SA3->A3_TIPO $ "P"	//Adicionado comissÃ£o adicional para representantes (Parceiros) se venda acima preÃ§o tabela
					If SC6->C6_ZPRCXTB >= 1.2 .And. SC6->C6_ZPRCXTB < 2.4
						nCom += SC6->C6_PRCVEN * SC6->C6_QTDVEN * (1.0 / 100)
					ElseIf SC6->C6_ZPRCXTB >= 2.4
						nCom += SC6->C6_PRCVEN * SC6->C6_QTDVEN * (2.0 / 100)
					EndIf
				Else
					nCom += SC6->C6_PRCVEN * SC6->C6_QTDVEN * (0.5 / 100)
				EndIf

			ElseIf Alltrim(SC6->C6_PRODUTO) $ "ME.0044"

				nCom += 0

			Else

				nCom += SC6->C6_PRCVEN * SC6->C6_QTDVEN * (nComiss / 100)

			EndIf

			nPond += SC6->C6_PRCVEN * SC6->C6_QTDVEN


		ElseIf SC5->C5_TIPO == "N" .And. cFilAnt $ "0200#0201#0204#0205" //.And. !(Upper(Alltrim(FunName())) $ "YFATM001#MATA440")

			If SB1->B1_TIPO == "PA" //.And. ( SubStr(SB1->B1_GRUPO,1,1) == "3" .Or. SubStr(SB1->B1_GRUPO,1,2) == "13" )

				DA1->(dbSetOrder(2))
				If DA1->(MsSeek(xFilial("DA1") + SC6->C6_PRODUTO + SC5->C5_TABELA))
					dbSelectArea("SC6")
					Reclock("SC6",.F.)
						SC6->C6_PRUNIT := DA1->DA1_PRCVEN
					SC6->( MsUnlock() )
				Else
					MsgStop("Produto " + Alltrim(SB1->B1_COD) + " - " + Alltrim(SB1->B1_DESC) + " nÃ£o estÃ¡ na tabela de preÃ§os " + SC5->C5_TABELA + "." + ENTER +;
							"Verifique se a tabela de preco vinculada ao cliente esta correta ou faca a inclusÃ£o do produto na atual.")
				Endif

				If SA3->A3_COMIS >= DA1->DA1_COMISS .And. DA1->DA1_COMISS > 0	//Alterado 04/07/2017 SC6->C6_PRCVEN <= DA1->DA1_PRCMIN
					nCom += SC6->C6_PRCVEN * SC6->C6_QTDVEN * (DA1->DA1_COMISS / 100)
				Else
					nCom += SC6->C6_PRCVEN * SC6->C6_QTDVEN * (nComiss / 100) //(SA3->A3_COMIS / 100)
				Endif

				nPond += SC6->C6_PRCVEN * SC6->C6_QTDVEN

			EndIf

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
	If cfilAnt $ cFilComis 
				
		_cGerFin    := Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC")
		/*------------------------------------------+
		| Se gera financeiro faz a validação        | 
		+------------------------------------------*/
		If _cGerFin == "S" 
				
			_aLidos     := {}
			_nLidos     := 0
			_cQuery     := "" 	

			If Select("TRB2") > 0
				TRB2->(DbCloseArea())
			EndIf
			
			IF INCLUI 

				_cQuery := "SELECT C6_FILIAL, C6_PRODUTO, C6_XTABCOM, C6_XREVCOM, C6_XDTRVC, C6_XTPCOM, C6_COMIS1, C6_XCOM1, C6_TES, C6_ITEM, C6_NUM, "+ENTER
				_cQuery += " C6_VALOR, C6_PRCVEN, C6_QTDVEN, C6_CLI, C6_LOJA, A1_COD, A1_LOJA, A1_XPGCOM, A1_XCOMIS1, F4_DUPLIC  "+ENTER  
				_cQuery += "FROM "+RetSqlName("SC6")+" AS SC6 WITH (NOLOCK) "+ENTER
				_cQuery += "INNER JOIN "+RetSqlName("SF4")+" AS SF4 WITH (NOLOCK) ON F4_FILIAL = SUBSTRING(C6_FILIAL,1,2) "+ENTER
				_cQuery += " AND F4_CODIGO = C6_TES "+ENTER
				_cQuery += " AND SF4.D_E_L_E_T_ = ' ' "+ENTER
				_cQuery += "INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH (NOLOCK) ON C6_FILIAL = A1_FILIAL"+ENTER
				_cQuery += " AND A1_COD  = C6_CLI "+ENTER 
				_cQuery += " AND A1_LOJA = C6_LOJA    "+ENTER 
				_cQuery += " AND SA1.D_E_L_E_T_ = ' ' "+ENTER 
				_cQuery += "WHERE C6_FILIAL  = '"+xFilial("SC6")+"' "+ENTER
				_cQuery += " AND C6_PRODUTO = '"+AllTrim(SC6->C6_PRODUTO)+"' "+ENTER 
				_cQuery += " AND C6_NUM  = '"+AllTrim(SC6->C6_NUM)+"' "+ENTER 
				_cQuery += " AND C6_CLI  = '"+AllTrim(SC6->C6_CLI)+"' "+ENTER 
				_cQuery += " AND C6_LOJA = '"+AllTrim(SC6->C6_LOJA)+"' "+ENTER 

				/*
				_cQuery += " AND C6_ITEM    = '"+AllTrim(SC6->C6_ITEM)+"' "+ENTER 
				_cQuery += " AND C6_XREVCOM = '"+AllTrim(SC6->C6_XREVCOM)+"' "+ENTER 
				_cQuery += " AND C6_XTABCOM = '"+AllTrim(SC6->C6_XTABCOM)+"' "+ENTER 
				_cQuery += " AND C6_NUM  = '"+AllTrim(SC6->C6_NUM)+"' "+ENTER 
				_cQuery += " AND C6_CLI  = '"+AllTrim(SC6->C6_CLI)+"' "+ENTER 
				_cQuery += " AND C6_LOJA = '"+AllTrim(SC6->C6_LOJA)+"' "+ENTER 
				*/
				_cQuery += " AND F4_DUPLIC = 'S'  "+ENTER 
				_cQuery += " AND SC6.D_E_L_E_T_ = ' '  "+ENTER 
				_cQuery += "GROUP BY C6_FILIAL, C6_PRODUTO, C6_XTABCOM, C6_XREVCOM, C6_XDTRVC, C6_XTPCOM, C6_COMIS1, C6_XCOM1, C6_TES, C6_ITEM, C6_NUM, "+ENTER
				_cQuery += " C6_VALOR, C6_PRCVEN, C6_QTDVEN, C6_CLI, C6_LOJA, A1_COD, A1_LOJA, A1_XPGCOM, A1_XCOMIS1, F4_DUPLIC  "+ENTER  
				_cQuery += "ORDER BY C6_PRODUTO "+ENTER 
			
			ElseIf ALTERA

				_cQuery := "SELECT C6_FILIAL, C6_PRODUTO, C6_XTABCOM, C6_XREVCOM, C6_XDTRVC, C6_XTPCOM, C6_COMIS1, C6_XCOM1, C6_TES, C6_ITEM, C6_NUM, "+ENTER
				_cQuery += " C6_VALOR, C6_PRCVEN, C6_QTDVEN, C6_CLI, C6_LOJA, A1_COD, A1_LOJA, A1_XPGCOM, A1_XCOMIS1, F4_DUPLIC  "+ENTER  
				_cQuery += "FROM "+RetSqlName("SC6")+" AS SC6 WITH (NOLOCK) "+ENTER
				_cQuery += "INNER JOIN "+RetSqlName("SF4")+" AS SF4 WITH (NOLOCK) ON F4_FILIAL = SUBSTRING(C6_FILIAL,1,2) "+ENTER
				_cQuery += " AND F4_CODIGO = C6_TES "+ENTER
				_cQuery += " AND SF4.D_E_L_E_T_ = ' ' "+ENTER
				_cQuery += "INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH (NOLOCK) ON C6_FILIAL = A1_FILIAL"+ENTER
				_cQuery += " AND A1_COD  = C6_CLI "+ENTER 
				_cQuery += " AND A1_LOJA = C6_LOJA    "+ENTER 
				_cQuery += " AND SA1.D_E_L_E_T_ = ' ' "+ENTER 
				_cQuery += "WHERE C6_FILIAL  = '"+xFilial("SC6")+"' "+ENTER
				_cQuery += " AND C6_PRODUTO = '"+AllTrim(SC6->C6_PRODUTO)+"' "+ENTER 
				_cQuery += " AND C6_ITEM    = '"+AllTrim(SC6->C6_ITEM)+"' "+ENTER 
				_cQuery += " AND C6_XREVCOM = '"+AllTrim(SC6->C6_XREVCOM)+"' "+ENTER 
				_cQuery += " AND C6_XTABCOM = '"+AllTrim(SC6->C6_XTABCOM)+"' "+ENTER 
				_cQuery += " AND C6_NUM  = '"+AllTrim(SC6->C6_NUM)+"' "+ENTER 
				_cQuery += " AND C6_CLI  = '"+AllTrim(SC6->C6_CLI)+"' "+ENTER 
				_cQuery += " AND C6_LOJA = '"+AllTrim(SC6->C6_LOJA)+"' "+ENTER 
				_cQuery += " AND F4_DUPLIC = 'S'  "+ENTER 
				_cQuery += " AND SC6.D_E_L_E_T_ = ' '  "+ENTER 
				_cQuery += "GROUP BY C6_FILIAL, C6_PRODUTO, C6_XTABCOM, C6_XREVCOM, C6_XDTRVC, C6_XTPCOM, C6_COMIS1, C6_XCOM1, C6_TES, C6_ITEM, C6_NUM, "+ENTER
				_cQuery += " C6_VALOR, C6_PRCVEN, C6_QTDVEN, C6_CLI, C6_LOJA, A1_COD, A1_LOJA, A1_XPGCOM, A1_XCOMIS1, F4_DUPLIC  "+ENTER  
				_cQuery += "ORDER BY C6_PRODUTO "+ENTER 

			EndIf

			TcQuery _cQuery ALIAS "TRB2" NEW

			TRB2->(DbGoTop())

			While TRB2->(!Eof())
				/*-------------------------------------------------------------------------------+
				| Se vem por copia ou orçamento faz o tratamento para garantir a gravação        |
				+-------------------------------------------------------------------------------*/
				If INCLUI
					_cComRev    := Posicione("SB1",1,xFilial("SB1")+TRB2->C6_PRODUTO,"B1_XREVCOM")  // Ultima revsão cadastrada na tabela PAA
					_cTabCom    := Posicione("SB1",1,xFilial("SB1")+TRB2->C6_PRODUTO,"B1_XTABCOM")  // Ultimo codigo de tabela cadastrada na tabela PAA
					_nTabComis  := Posicione("SB1",1,xFilial("SB1")+TRB2->C6_PRODUTO,"B1_COMIS")    // Ultimo comissão gravada de acordo com a tabela PAA
				Else
					_cComRev    := TRB2->C6_XREVCOM
					_cTabCom    := TRB2->C6_XTABCOM
					_nTabComis  := TRB2->C6_XCOM1
				EndIf
				/*------------------------------------------+
				| Se o produto é igual grava array          |
				+------------------------------------------*/
				If TRB2->C6_PRODUTO == SC6->C6_PRODUTO 
					
					Aadd(_aLidos,{TRB2->C6_PRODUTO,;  // 01
								  _cTabCom,;  // 02 
								  _cComRev,;  // 03
								  If(INCLUI,DTOS(DDATABASE),TRB2->C6_XDTRVC),; // 04 
								  TRB2->C6_COMIS1,;   // 05
								  TRB2->C6_TES,;      // 06
								  TRB2->C6_CLI,;      // 07
								  TRB2->C6_LOJA,;     // 08
								  TRB2->C6_NUM,;      // 09
								  TRB2->F4_DUPLIC,;   // 10
								  TRB2->A1_XPGCOM,;   // 11
								  TRB2->A1_XCOMIS1,;  // 12
								  TRB2->C6_XTPCOM,;   // 13
								  _nTabComis,;        // 14
								  TRB2->C6_ITEM,;     // 15
								  TRB2->C6_VALOR,;    // 16
								  TRB2->C6_QTDVEN,;   // 17
								  TRB2->C6_PRCVEN})   // 18

				EndIf

				TRB2->(DbSkip())

				_cComRev    := ""
				_cTabCom    := ""
				_nTabComis  := 0

			EndDo
			/*------------------------------------------------------+
			| Se tem dados no array entra para gravar as comissões  |
			+------------------------------------------------------*/
			If Len(_aLidos) > 0

				For _nLidos:= 1 To Len(_aLidos) 
					/*------------------------------------------------------+
					| Se produto, revisão e tabela é igual entra na regra   |
					+------------------------------------------------------*/
					If _aLidos[_nLidos][01] == SC6->C6_PRODUTO .And. _aLidos[_nLidos][03] == SC6->C6_XREVCOM  .And. _aLidos[_nLidos][02] == SC6->C6_XTABCOM 

						DbSelectArea("SC6")
						SC6->(DbSetorder(1))
                        If SC6->(MsSeek(xFilial("SC6")+_aLidos[_nLidos][09]+_aLidos[_nLidos][15]+_aLidos[_nLidos][01]))
							/*----------------------------------------------------------------------------------+
							| Sim e percentual preenchido no cadastro do cliente - Paga comissão pelo Cliente   | 
							+----------------------------------------------------------------------------------*/
							If cPgCliente == "2" .And. _nPercCli > 0

								If INCLUI
									If _aLidos[_nLidos][05] > 0
										_nCliente++
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XTABCOM")
										SC6->C6_XCOM1   := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_COMIS")
										SC6->C6_COMIS1  := _nPercCli
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XREVCOM") 
										SC6->C6_XDTRVC  := DDATABASE
										SC6->C6_XTPCOM  := "01" // CLIENTE
										SC6->(Msunlock())
										_nVlComis1  += Round( (_aLidos[_nLidos][16] * _nPercCli) / 100,2)
										_nVlTotal   +=  _aLidos[_nLidos][16]
										_cTipoCom   :=  "01" // CLIENTE
									Else
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XTABCOM")
										SC6->C6_XCOM1   := 0
										SC6->C6_COMIS1  := 0
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XREVCOM")
										SC6->C6_XDTRVC  := DDATABASE
										SC6->C6_XTPCOM  := "01" // CLIENTE
										SC6->(Msunlock())
										_nVlComis1  += 0
										_nVlTotal   += 0
										_cTipoCom   :=  "01" // CLIENTE
									EndIf
								ElseIf ALTERA
									If _aLidos[_nLidos][05] > 0
										_nCliente++
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := _aLidos[_nLidos][02]
										SC6->C6_XCOM1   := _aLidos[_nLidos][05]
										SC6->C6_COMIS1  := _nPercCli
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := _aLidos[_nLidos][03]
										SC6->C6_XDTRVC  := StoD(_aLidos[_nLidos][04])
										SC6->C6_XTPCOM  := "01" // CLIENTE
										SC6->(Msunlock())
										_nVlComis1  += Round( (_aLidos[_nLidos][16] * _nPercCli) / 100,2)
										_nVlTotal   +=  _aLidos[_nLidos][16]
										_cTipoCom   :=  "01" // CLIENTE
									Else
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := _aLidos[_nLidos][02]
										SC6->C6_XCOM1   := 0
										SC6->C6_COMIS1  := 0
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := _aLidos[_nLidos][03]
										SC6->C6_XDTRVC  := StoD(_aLidos[_nLidos][04])
										SC6->C6_XTPCOM  := "01" // CLIENTE
										SC6->(Msunlock())
										_nVlComis1  += 0
										_nVlTotal   += 0
										_cTipoCom   :=  "01" // CLIENTE
									EndIf
								EndIf
							/*---------------------------------------------------------+
							|  Não / Sim / sim  -  Paga comissão pelo Produto          | 
							+---------------------------------------------------------*/
							ElseIf cRepreClt == "1" .And. cPgCliente == "2" .And. cPgvend1 == "2" .And. _nPercCli <= 0

								If INCLUI
									If _aLidos[_nLidos][05] > 0
										_nProduto++
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XTABCOM")
										SC6->C6_XCOM1   := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_COMIS")
										SC6->C6_COMIS1  := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_COMIS")
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XREVCOM")
										SC6->C6_XDTRVC  := DDATABASE
										SC6->C6_XTPCOM  := "02" // PRODUTO
										SC6->(Msunlock())
										_nVlComis1  += Round( (_aLidos[_nLidos][16] * Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_COMIS")) / 100,2)
										_nVlTotal   += _aLidos[_nLidos][16]
										_cTipoCom   :=  "02" // PRODUTO
									Else 
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XTABCOM")
										SC6->C6_XCOM1   := 0
										SC6->C6_COMIS1  := 0
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XREVCOM")
										SC6->C6_XDTRVC  := DDATABASE
										SC6->C6_XTPCOM  := "02" // PRODUTO
										SC6->(Msunlock())
										_nVlComis1  += 0
										_nVlTotal   += 0
										_cTipoCom   :=  "02" // PRODUTO
									EndIf
								Else
									If _aLidos[_nLidos][05] > 0
										_nProduto++
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := If(ALTERA,_aLidos[_nLidos][02],Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XTABCOM"))
										SC6->C6_XCOM1   := _aLidos[_nLidos][05]
										SC6->C6_COMIS1  := _aLidos[_nLidos][05]
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := _aLidos[_nLidos][03]
										SC6->C6_XDTRVC  := StoD(_aLidos[_nLidos][04])
										SC6->C6_XTPCOM  := "02" // PRODUTO
										SC6->(Msunlock())
										_nVlComis1  += Round( (_aLidos[_nLidos][16] * _aLidos[_nLidos][05]) / 100,2)
										_nVlTotal   += _aLidos[_nLidos][16]
										_cTipoCom   :=  "02" // PRODUTO
									Else 
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := _aLidos[_nLidos][02]
										SC6->C6_XCOM1   := 0
										SC6->C6_COMIS1  := 0
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := _aLidos[_nLidos][03]
										SC6->C6_XDTRVC  := StoD(_aLidos[_nLidos][04])
										SC6->C6_XTPCOM  := "02" // PRODUTO
										SC6->(Msunlock())
										_nVlComis1  += 0
										_nVlTotal   += 0
										_cTipoCom   :=  "02" // PRODUTO
									EndIf
								EndIf
							/*--------------------------------------------------------------+
							| Sim / Sim / sim -  paga comissão pelo percentual do vendedor  |           
							+--------------------------------------------------------------*/
							ElseIf cRepreClt == "2" .And. cPgCliente == "2" .And. cPgvend1 == "2" .And. _nPercCli <= 0

								If INCLUI
									If  _aLidos[_nLidos][05] > 0
										_nVendedor++
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XTABCOM")
										SC6->C6_XCOM1   := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_COMIS")
										SC6->C6_COMIS1  := Posicione("SA3",1, xFilial("SA3+")+cVend1,"A3_COMIS")
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XREVCOM")
										SC6->C6_XDTRVC  := DDATABASE
										SC6->C6_XTPCOM  := "03" // VENDEDOR
										SC6->(Msunlock())
										_nVlComis1  := Posicione("SA3",1, xFilial("SA3+")+cVend1,"A3_COMIS")
										_cTipoCom   :=  "03" // VENDEDOR
									Else
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XTABCOM")
										SC6->C6_XCOM1   := 0
										SC6->C6_COMIS1  := 0
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XREVCOM")
										SC6->C6_XDTRVC  := DDATABASE
										SC6->C6_XTPCOM  := "03" // VENDEDOR
										SC6->(Msunlock())
										_nVlComis1  += 0
										_cTipoCom   :=  "03" // VENDEDOR
									EndIf
								ElseIf ALTERA
									If  _aLidos[_nLidos][05] > 0
										_nVendedor++
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := _aLidos[_nLidos][02]
										SC6->C6_XCOM1   := _aLidos[_nLidos][05]
										SC6->C6_COMIS1  := Posicione("SA3",1, xFilial("SA3+")+cVend1,"A3_COMIS")
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := _aLidos[_nLidos][03]
										SC6->C6_XDTRVC  := StoD(_aLidos[_nLidos][04])
										SC6->C6_XTPCOM  := "03" // VENDEDOR
										SC6->(Msunlock())
										_nVlComis1  := Posicione("SA3",1, xFilial("SA3+")+cVend1,"A3_COMIS")
										_cTipoCom   :=  "03" // VENDEDOR
									Else
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := _aLidos[_nLidos][02]
										SC6->C6_XCOM1   := 0
										SC6->C6_COMIS1  := 0
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := _aLidos[_nLidos][03]
										SC6->C6_XDTRVC  := StoD(_aLidos[_nLidos][04])
										SC6->C6_XTPCOM  := "03" // VENDEDOR
										SC6->(Msunlock())
										_nVlComis1  += 0
										_cTipoCom   :=  "03" // VENDEDOR
									EndIf
								EndIf
							/*------------------------+
							| Não paga comissão       |
							+------------------------*/
							Else
								Reclock("SC6",.F.)
								SC6->C6_XTABCOM := _aLidos[_nLidos][02]
								SC6->C6_XCOM1   := 0
								SC6->C6_COMIS1  := 0
								SC6->C6_COMIS2  := 0
								SC6->C6_COMIS3  := 0
								SC6->C6_COMIS4  := 0
								SC6->C6_COMIS5  := 0
								SC6->C6_XREVCOM := _aLidos[_nLidos][03]
								SC6->C6_XDTRVC  := StoD(_aLidos[_nLidos][04])
								SC6->C6_XTPCOM  := "04" // ZERADO
								SC6->(Msunlock())
								_cTipoCom   :=  "04" // ZERADO
							EndIf
        
                        EndIf

					Else 

						DbSelectArea("SC6")
						SC6->(DbSetorder(1))
                        If SC6->(MsSeek(xFilial("SC6")+_aLidos[_nLidos][09]+_aLidos[_nLidos][15]+_aLidos[_nLidos][01]))
							/*----------------------------------------------------------------------------------+
							| Sim e percentual preenchido no cadastro do cliente - Paga comissão pelo Cliente   | 
							+----------------------------------------------------------------------------------*/
							If cPgCliente == "2" .And. _nPercCli > 0

								If INCLUI
									If _aLidos[_nLidos][05] > 0
										_nCliente++
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XTABCOM")
										SC6->C6_XCOM1   := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_COMIS")
										SC6->C6_COMIS1  := _nPercCli
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XREVCOM") 
										SC6->C6_XDTRVC  := DDATABASE
										SC6->C6_XTPCOM  := "01" // CLIENTE
										SC6->(Msunlock())
										_nVlComis1  += Round( (_aLidos[_nLidos][16] * _nPercCli) / 100,2)
										_nVlTotal   +=  _aLidos[_nLidos][16]
										_cTipoCom   :=  "01" // CLIENTE
									Else
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XTABCOM")
										SC6->C6_XCOM1   := 0
										SC6->C6_COMIS1  := 0
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XREVCOM")
										SC6->C6_XDTRVC  := DDATABASE
										SC6->C6_XTPCOM  := "01" // CLIENTE
										SC6->(Msunlock())
										_nVlComis1  += 0
										_nVlTotal   += 0
										_cTipoCom   :=  "01" // CLIENTE
									EndIf
								ElseIf ALTERA
									If _aLidos[_nLidos][05] > 0
										_nCliente++
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := _aLidos[_nLidos][02]
										SC6->C6_XCOM1   := _aLidos[_nLidos][05]
										SC6->C6_COMIS1  := _nPercCli
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := _aLidos[_nLidos][03]
										SC6->C6_XDTRVC  := StoD(_aLidos[_nLidos][04])
										SC6->C6_XTPCOM  := "01" // CLIENTE
										SC6->(Msunlock())
										_nVlComis1  += Round( (_aLidos[_nLidos][16] * _nPercCli) / 100,2)
										_nVlTotal   +=  _aLidos[_nLidos][16]
										_cTipoCom   :=  "01" // CLIENTE
									Else
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := _aLidos[_nLidos][02]
										SC6->C6_XCOM1   := 0
										SC6->C6_COMIS1  := 0
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := _aLidos[_nLidos][03]
										SC6->C6_XDTRVC  := StoD(_aLidos[_nLidos][04])
										SC6->C6_XTPCOM  := "01" // CLIENTE
										SC6->(Msunlock())
										_nVlComis1  += 0
										_nVlTotal   += 0
										_cTipoCom   :=  "01" // CLIENTE
									EndIf
								EndIf
							/*---------------------------------------------------------+
							|  Não / Sim / sim  -  Paga comissão pelo Produto          | 
							+---------------------------------------------------------*/
							ElseIf cRepreClt == "1" .And. cPgCliente == "2" .And. cPgvend1 == "2" .And. _nPercCli <= 0

								If INCLUI
									If _aLidos[_nLidos][05] > 0
										_nProduto++
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XTABCOM")
										SC6->C6_XCOM1   := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_COMIS")
										SC6->C6_COMIS1  := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_COMIS")
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XREVCOM")
										SC6->C6_XDTRVC  := DDATABASE
										SC6->C6_XTPCOM  := "02" // PRODUTO
										SC6->(Msunlock())
										_nVlComis1  += Round( (_aLidos[_nLidos][16] * Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_COMIS")) / 100,2)
										_nVlTotal   += _aLidos[_nLidos][16]
										_cTipoCom   :=  "02" // PRODUTO
									Else 
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XTABCOM")
										SC6->C6_XCOM1   := 0
										SC6->C6_COMIS1  := 0
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XREVCOM")
										SC6->C6_XDTRVC  := DDATABASE
										SC6->C6_XTPCOM  := "02" // PRODUTO
										SC6->(Msunlock())
										_nVlComis1  += 0
										_nVlTotal   += 0
										_cTipoCom   :=  "02" // PRODUTO
									EndIf
								Else
									If _aLidos[_nLidos][05] > 0
										_nProduto++
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := If(ALTERA,_aLidos[_nLidos][02],Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XTABCOM"))
										SC6->C6_XCOM1   := _aLidos[_nLidos][05]
										SC6->C6_COMIS1  := _aLidos[_nLidos][05]
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := _aLidos[_nLidos][03]
										SC6->C6_XDTRVC  := StoD(_aLidos[_nLidos][04])
										SC6->C6_XTPCOM  := "02" // PRODUTO
										SC6->(Msunlock())
										_nVlComis1  += Round( (_aLidos[_nLidos][16] * _aLidos[_nLidos][05]) / 100,2)
										_nVlTotal   += _aLidos[_nLidos][16]
										_cTipoCom   :=  "02" // PRODUTO
									Else 
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := _aLidos[_nLidos][02]
										SC6->C6_XCOM1   := 0
										SC6->C6_COMIS1  := 0
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := _aLidos[_nLidos][03]
										SC6->C6_XDTRVC  := StoD(_aLidos[_nLidos][04])
										SC6->C6_XTPCOM  := "02" // PRODUTO
										SC6->(Msunlock())
										_nVlComis1  += 0
										_nVlTotal   += 0
										_cTipoCom   :=  "02" // PRODUTO
									EndIf
								EndIf
							/*--------------------------------------------------------------+
							| Sim / Sim / sim -  paga comissão pelo percentual do vendedor  |           
							+--------------------------------------------------------------*/
							ElseIf cRepreClt == "2" .And. cPgCliente == "2" .And. cPgvend1 == "2" .And. _nPercCli <= 0
								If INCLUI
									If  _aLidos[_nLidos][05] > 0
										_nVendedor++
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XTABCOM")
										SC6->C6_XCOM1   := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_COMIS")
										SC6->C6_COMIS1  := Posicione("SA3",1, xFilial("SA3+")+cVend1,"A3_COMIS")
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XREVCOM")
										SC6->C6_XDTRVC  := DDATABASE
										SC6->C6_XTPCOM  := "03" // VENDEDOR
										SC6->(Msunlock())
										_nVlComis1  := Posicione("SA3",1, xFilial("SA3+")+cVend1,"A3_COMIS")
										_cTipoCom   :=  "03" // VENDEDOR
									Else
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XTABCOM")
										SC6->C6_XCOM1   := 0
										SC6->C6_COMIS1  := 0
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := Posicione("SB1",1,xFilial("SB1")+_aLidos[_nLidos][01],"B1_XREVCOM")
										SC6->C6_XDTRVC  := DDATABASE
										SC6->C6_XTPCOM  := "03" // VENDEDOR
										SC6->(Msunlock())
										_nVlComis1  += 0
										_cTipoCom   :=  "03" // VENDEDOR
									EndIf
								ElseIf ALTERA
									If  _aLidos[_nLidos][05] > 0
										_nVendedor++
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := _aLidos[_nLidos][02]
										SC6->C6_XCOM1   := _aLidos[_nLidos][05]
										SC6->C6_COMIS1  := Posicione("SA3",1, xFilial("SA3+")+cVend1,"A3_COMIS")
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := _aLidos[_nLidos][03]
										SC6->C6_XDTRVC  := StoD(_aLidos[_nLidos][04])
										SC6->C6_XTPCOM  := "03" // VENDEDOR
										SC6->(Msunlock())
										_nVlComis1  := Posicione("SA3",1, xFilial("SA3+")+cVend1,"A3_COMIS")
										_cTipoCom   :=  "03" // VENDEDOR
									Else
										Reclock("SC6",.F.)
										SC6->C6_XTABCOM := _aLidos[_nLidos][02]
										SC6->C6_XCOM1   := 0
										SC6->C6_COMIS1  := 0
										SC6->C6_COMIS2  := 0
										SC6->C6_COMIS3  := 0
										SC6->C6_COMIS4  := 0
										SC6->C6_COMIS5  := 0
										SC6->C6_XREVCOM := _aLidos[_nLidos][03]
										SC6->C6_XDTRVC  := StoD(_aLidos[_nLidos][04])
										SC6->C6_XTPCOM  := "03" // VENDEDOR
										SC6->(Msunlock())
										_nVlComis1  += 0
										_cTipoCom   :=  "03" // VENDEDOR
									EndIf
								EndIf
							/*------------------------+
							| Não paga comissão       |
							+------------------------*/
							Else
								Reclock("SC6",.F.)
								SC6->C6_XTABCOM := _aLidos[_nLidos][02]
								SC6->C6_XCOM1   := 0
								SC6->C6_COMIS1  := 0
								SC6->C6_COMIS2  := 0
								SC6->C6_COMIS3  := 0
								SC6->C6_COMIS4  := 0
								SC6->C6_COMIS5  := 0
								SC6->C6_XREVCOM := _aLidos[_nLidos][03]
								SC6->C6_XDTRVC  := StoD(_aLidos[_nLidos][04])
								SC6->C6_XTPCOM  := "04" // ZERADO
								SC6->(Msunlock())
								_cTipoCom   :=  "04" // ZERADO
							EndIf
        
                        EndIf

					Endif 

				Next _nLidos 	
				
			EndIf	
		
		EndIf
	
	EndIf 
	//Fim Tratamento Comissão Qualy
	
	DbSelectArea("SC6")
	SC6->(DbSkip())

	_cComRev    := ""
	_cTabCom    := ""
	_nTabComis  := 0

Enddo
//Comissao - Reajusta o valor conforme o teto
If SC5->C5_TIPO == "N" .And. 100*(nCom/nPond) > 0 
	nComiss := 100*(nCom/nPond)
EndIf
If SC5->C5_TIPO == "N" .And. cFilAnt $ "0200#0201#0204#0205" //.And. !(Upper(Alltrim(FunName())) $ "YFATM001#MATA440")

	If nComiss > 5
		nComiss := 5
	EndIf

	// Verifica Piso e Teto da Comissao
	If(SA3->A3_TPCOMIS == "T" .And. nComiss > SA3->A3_COMIS) .Or. SA3->A3_TPCOMIS == "F"
		nComiss := SA3->A3_COMIS
	ElseIf SA3->A3_COMINF != 0 .And. nComiss < SA3->A3_COMINF
		nComiss := SA3->A3_COMINF
	EndIf

EndIf

//Comissao - Verifica comissao por cliente

SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))

If SC5->C5_TIPO == "N" .And. SA1->A1_COMIS != 0 //.And. !(Upper(Alltrim(FunName())) $ "YFATM001#MATA440")
	If nComiss > SA1->A1_COMIS
		nComiss := SA1->A1_COMIS
	EndIf
EndIf

//Calcula valor do frete previsto
If SC5->C5_TIPO == "N"

	If cfilAnt $ cFilComis

		If SC5->C5_TRANSP != "000002"

			If SC5->C5_TRANSP == "000001"
				//+----------------------------------------------------------------------------
				//| NOSSO CARRO / AGREGADO
				//+----------------------------------------------------------------------------
				cEstFrete := AllTrim(Upper(SA1->A1_ESTE)) //AllTrim(Upper(SC5->C5_ESTREC))
			Else
				//+----------------------------------------------------------------------------
				//| TRANSPORTADORA / REDESPACHO
				//+----------------------------------------------------------------------------
				cEstFrete := Posicione("SA4", 1, xFilial("SA4")+SC5->C5_TRANSP, "A4_EST")
			EndIf

			//+----------------------------------------------------------------------------
			//| FRETE/KG: 0.07 - SAO PAULO | 0.12 - OUTROS ESTADOS
			//+----------------------------------------------------------------------------
			If AllTrim(Upper(cEstFrete)) == "SP"
				nPrvFrete := ( _aPesos[2] * 0.07 )
			Else
				nPrvFrete := ( _aPesos[2] * 0.12 )
			EndIf

		EndIf

	Else
		//Outras empresas
		nPrvFrete := M->C5_FRETPRV
	EndIf
	
	Reclock("SC5",.F.)
	SC5->C5_FRETPRV := nPrvFrete
	SC5->( Msunlock() )

EndIf

If cfilAnt <> cFilComis

	SC5->(Reclock("SC5",.F.))
		If !Empty(SC5->C5_VEND2) .And. nComiss > 0.5
			SC5->C5_COMIS1  := nComiss - 0.5
			SC5->C5_COMIS2  := 0.5
		Else
			SC5->C5_COMIS1  := nComiss
			SC5->C5_COMIS2  := 0
		EndIf
	SC5->( Msunlock() )

EndIf

//Solicitção Alessandra Monea 05/09/17                      

If Left(cFilAnt,2) $ "02" .And. SA3->A3_COMIS > 1.5 .And. !SC5->C5_CLIENTE$"000300#000301#000302#032729#035059#035055#" .And. !SC5->C5_VEND1 $ "000297"  //Clientes Klabin/Orsa comissÃ£o 2.5 deve estar cadastro Cliente

	BEGIN SEQUENCE

	cQry := " SELECT ISNULL(CAST((( 1 - (SUM(VALOR) / SUM(TOTPRCTBL)))*100) AS NUMERIC(7,2)),99) AS DESCONTO " + ENTER
	cQry += " FROM  " + ENTER
	cQry += " (
	cQry += "	SELECT	C6_VALOR VALOR,  " + ENTER
	cQry += "			(	SELECT DA1.DA1_PRCVEN FROM " + RetSqlName("DA1") + " DA1  " + ENTER
	cQry += " 				WHERE DA1.D_E_L_E_T_ = '' AND SC5.C5_TABELA = DA1.DA1_CODTAB AND SC5.C5_MOEDA = DA1.DA1_MOEDA AND SC6.C6_PRODUTO = DA1.DA1_CODPRO ) * C6_QTDVEN AS TOTPRCTBL " + ENTER
	cQry += " 	FROM   " + ENTER
	cQry += " 		" + RetSqlName("SC6") + " SC6 INNER JOIN  " + ENTER
	cQry += " 		" + RetSqlName("SC5") + " SC5 ON SC5.C5_NUM = SC6.C6_NUM AND SC5.C5_FILIAL = SC6.C6_FILIAL " + ENTER
	cQry += "	 WHERE   " + ENTER
	cQry += " 		SC6.D_E_L_E_T_ = ''    " + ENTER
	cQry += " 		AND SC5.D_E_L_E_T_ = ''  " + ENTER
	cQry += "		AND SC5.C5_TIPO NOT IN  ('C','I','P') " + ENTER
	cQry += " 		AND C6_FILIAL = '" + xFilial("SC6") + "'   " + ENTER
	cQry += "		AND C6_NUM = '" + SC5->C5_NUM + "'  " + ENTER
	cQry += " ) PEDIDOS  " + ENTER

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TRYEXCEPTION	//TRY EXCEPTION

	TCQUERY cQry NEW ALIAS QRY

	If !QRY->(EOF())

		If QRY->DESCONTO > 5.01 .And. QRY->DESCONTO < 10.01	//Considerando adicional 0.01 relativo a arredondamentos

			Reclock("SC5",.F.)

				SC5->C5_COMIS1  := nComiss * 0.75
				If !Empty(SC5->C5_VEND2)
					SC5->C5_COMIS2  := SC5->C5_COMIS2 * 0.75
				EndIf

			SC5->( Msunlock() )

		ElseIf QRY->DESCONTO > 10.01 .And. QRY->DESCONTO <= 50

			Reclock("SC5",.F.)

				SC5->C5_COMIS1  := nComiss * 0.5
				If !Empty(SC5->C5_VEND2)
					SC5->C5_COMIS2  := SC5->C5_COMIS2 * 0.5
				EndIf

			SC5->( Msunlock() )

		ElseIf QRY->DESCONTO > 50	//Preço de tabela não cadastrado

			Reclock("SC5",.F.)

				SC5->C5_COMIS1  := nComiss * 0.5
				If !Empty(SC5->C5_VEND2)
					SC5->C5_COMIS2  := SC5->C5_COMIS2 * 0.5
				EndIf

			SC5->( Msunlock() )

			MsgInfo("Preço de tabela não cadastrado! " + ENTER +;
						"Favor solicitar cadastramento para dar andamento no pedido! ",;
						"A comissão do vendedor zera¡ de 0% (zerada) quando não existir preço de tabela cadastrado.")

		EndIf

	EndIf

	CATCHEXCEPTION USING oError

		MsgInfo("Pedido com produto cadastrado mais de uma vez na tabela de precos, favor solicitar a correcao! COMISSAO SERA DESCONTADA EM 50% ATE CORRECAO!!!")
		lRet := .F.

		Reclock("SC5",.F.)
			SC5->C5_COMIS1  := nComiss * 0.5
			If !Empty(SC5->C5_VEND2)
				SC5->C5_COMIS2  := SC5->C5_COMIS2 * 0.5
			EndIf
		SC5->( Msunlock() )

	ENDEXCEPTION //END TRY

	END SEQUENCE

EndIf
/*
+------------------------------------------------------------------+
| Projeto UNIDADE DE EXPEDIÇÃO - 31/05/2022 - Fabio Carneiro       |
+------------------------------------------------------------------+
*/
If SC5->C5_TIPO $ "N/D/B" 

	// será gravado as unidades de expedição, diferenças e os calculos de embalagens de cada produto 

	If Select("TRBF") > 0
		TRBF->(DbCloseArea())
	EndIf

	cQueryF := "SELECT C6_FILIAL, C6_PRODUTO, C6_QTDVEN, C6_NUM, C5_TIPO, C6_CLI, C6_LOJA, "+CRLF
	cQueryF += "B1_XUNEXP, B1_XQTDEXP, C6_ITEM  "+CRLF  
	cQueryF += "FROM "+RetSqlName("SC6")+" AS SC6 WITH (NOLOCK) "+CRLF
	cQueryF += "INNER JOIN "+RetSqlName("SC5")+" AS SC5 WITH (NOLOCK) ON C5_FILIAL = C6_FILIAL "+CRLF
	cQueryF += " AND C5_NUM = C6_NUM      "+CRLF
	cQueryF += " AND C5_CLIENTE = C6_CLI  "+CRLF
	cQueryF += " AND C5_LOJACLI = C6_LOJA "+CRLF
	cQueryF += " AND SC5.D_E_L_E_T_ = ' ' "+CRLF
	cQueryF += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) ON B1_COD = C6_PRODUTO "+CRLF
	cQueryF += " AND SB1.D_E_L_E_T_ = ' ' "+CRLF
	cQueryF += "WHERE C6_FILIAL = '"+xFilial("SC6")+"' "+CRLF
	cQueryF += " AND C6_NUM     = '"+SC5->C5_NUM+"' "+CRLF
	cQueryF += " AND C6_CLI     = '"+SC5->C5_CLIENTE+"' "+CRLF
	cQueryF += " AND C6_LOJA    = '"+SC5->C5_LOJACLI+"' "+CRLF
	cQueryF += " AND C5_TIPO    = '"+SC5->C5_TIPO+"' "+CRLF
	cQueryF += " AND C5_XOPER   = '"+SC5->C5_XOPER+"' "+CRLF
	cQueryF += " AND SC6.D_E_L_E_T_ = ' ' "+CRLF 
	cQueryF += "GROUP BY C6_FILIAL, C6_PRODUTO, C6_QTDVEN, C6_NUM, C5_TIPO, C6_CLI, C6_LOJA, "+CRLF
	cQueryF += "B1_XUNEXP, B1_XQTDEXP, C6_ITEM "+CRLF  
	cQueryF += "ORDER BY B1_XUNEXP,B1_XQTDEXP,C6_NUM, C6_PRODUTO  "+CRLF

	TcQuery cQueryF ALIAS "TRBF" NEW

	TRBF->(DbGoTop())

	While TRBF->(!Eof())

		_cUnExpedicao  := Posicione("SB1",1,xFilial("SB1")+TRBF->C6_PRODUTO,"B1_XUNEXP")
		_nQtdMinima    := Posicione("SB1",1,xFilial("SB1")+TRBF->C6_PRODUTO,"B1_XQTDEXP") 

		If TRBF->C5_TIPO $ "N/D/B" .And. !Empty(_cUnExpedicao) .And. _nQtdMinima > 0 

			_nPesoBruto    := Posicione("SB1",1,xFilial("SB1")+TRBF->C6_PRODUTO,"B1_PESBRU") 
			_nPesoLiquido  := Posicione("SB1",1,xFilial("SB1")+TRBF->C6_PRODUTO,"B1_PESO") 
			_nRetMod       := MOD(TRBF->C6_QTDVEN,_nQtdMinima)
			_nQtdVenda     := (TRBF->C6_QTDVEN -_nRetMod)
			_nVal          := (_nQtdVenda / _nQtdMinima)
			_nQtdVol       := _nVal * _nQtdMinima 
			_nDifVol       := TRBF->C6_QTDVEN-_nQtdVol

			DbSelectArea("SC6")
			SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
			If SC6->(dbSeek(xFilial("SC6") + TRBF->C6_NUM + TRBF->C6_ITEM + TRBF->C6_PRODUTO))

				RecLock("SC6",.F.)

				SC6->C6_XUNEXP  := _cUnExpedicao                     // Unidade de expedição do cadastro do produto
				SC6->C6_XCLEXP  := _nVal                             // Quantidade de embalagem 
				SC6->C6_XMINEMB := _nQtdMinima                       // Minimo de Embalagem do cadastro do produto
				SC6->C6_XQTDVOL := _nQtdVol                          // Quantidade do Volume 
				SC6->C6_XDIFVOL := _nDifVol                          // Diferença de Volume menor que a embalagem minima 
				SC6->C6_XPESBUT := (TRBF->C6_QTDVEN * _nPesoBruto)   // Total de peso bruto
				SC6->C6_XPESLIQ := (TRBF->C6_QTDVEN * _nPesoLiquido) // Total de peso liquido 
				SC6->C6_XPBRU   := _nPesoBruto                       // Peso bruto do cadastro do produto para historico 
				SC6->C6_XPLIQ   := _nPesoLiquido                     // Peso Liquido do cadastro do produto para historico 
	
				SC6->(MsUnlock())

			EndIf

		EndIf

		TRBF->(dbSkip())

		_cUnExpedicao  := ""
		_nQtdMinima    := 0
		_nPesoBruto    := 0
		_nPesoLiquido  := 0
		_nRetMod       := 0
		_nQtdVenda     := 0
		_nVal          := 0
		_nQtdVol       := 0
		_nDifVol       := 0

	EndDo

	// Query para o calculo do volume, especie e peso de acordo com a unidade de expedição 

	If Select("TRBI") > 0
		TRBI->(DbCloseArea())
	EndIf

	cQueryI := "SELECT C6_FILIAL, C6_PRODUTO, SUM(C6_QTDVEN) AS C6_QTDVEN,C6_NUM,C5_TIPO,C6_CLI, C6_LOJA, "+CRLF
	cQueryI += "B1_XUNEXP, B1_XQTDEXP,B1_UM, C5_EMISSAO, B1_PESO, B1_PESBRU "+CRLF
	cQueryI += "FROM "+RetSqlName("SC6")+" AS SC6 WITH (NOLOCK) "+CRLF
	cQueryI += "INNER JOIN "+RetSqlName("SC5")+" AS SC5 WITH (NOLOCK) ON C5_FILIAL = C6_FILIAL "+CRLF
	cQueryI += " AND C5_NUM = C6_NUM      "+CRLF
	cQueryI += " AND C5_CLIENTE = C6_CLI  "+CRLF
	cQueryI += " AND C5_LOJACLI = C6_LOJA "+CRLF
	cQueryI += " AND SC5.D_E_L_E_T_ = ' ' "+CRLF
	cQueryI += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) ON B1_COD = C6_PRODUTO "+CRLF
	cQueryI += " AND SB1.D_E_L_E_T_ = ' ' "+CRLF
	cQueryI += "WHERE C6_FILIAL = '"+xFilial("SC6")+"' "+CRLF
	cQueryI += " AND C6_NUM     = '"+SC5->C5_NUM+"' "+CRLF
	cQueryI += " AND C6_CLI     = '"+SC5->C5_CLIENTE+"' "+CRLF
	cQueryI += " AND C6_LOJA    = '"+SC5->C5_LOJACLI+"' "+CRLF
	cQueryI += " AND C5_TIPO    = '"+SC5->C5_TIPO+"' "+CRLF
	cQueryI += " AND C5_XOPER   = '"+SC5->C5_XOPER+"' "+CRLF
	cQueryI += " AND SC6.D_E_L_E_T_ = ' ' "+CRLF 
	cQueryI += "GROUP BY C6_FILIAL, C6_PRODUTO, C6_NUM,C5_TIPO,C6_CLI, C6_LOJA, "+CRLF
	cQueryI += "B1_XUNEXP, B1_XQTDEXP,B1_UM, C5_EMISSAO, B1_PESO, B1_PESBRU "+CRLF  
	cQueryI += "ORDER BY B1_XUNEXP,B1_XQTDEXP,C6_NUM, C6_PRODUTO  "+CRLF

	TcQuery cQueryI ALIAS "TRBI" NEW

	TRBI->(DbGoTop())

	_cUnExpedicao  := ""
	_nQtdMinima    := 0
	_nPesoBruto    := 0
	_nPesoLiquido  := 0
	_nRetMod       := 0
	_nQtdVenda     := 0
	_nVal          := 0
	_nQtdVol       := 0
	_nDifVol       := 0

	While TRBI->(!Eof())
	
		_cUnExpedicao  := Posicione("SB1",1,xFilial("SB1")+TRBI->C6_PRODUTO,"B1_XUNEXP")
		_nQtdMinima    := Posicione("SB1",1,xFilial("SB1")+TRBI->C6_PRODUTO,"B1_XQTDEXP") 

		If TRBI->C5_TIPO $ "N/D/B" .And. !Empty(_cUnExpedicao) .And. _nQtdMinima > 0 

			_aCheck   := {}
			_cCampo   := ""
			_cFilial  := TRBI->C6_FILIAL
			_cDoc     := TRBI->C6_NUM
			_cCliente := TRBI->C6_CLI
			_cLoja    := TRBI->C6_LOJA
			_cTipo    := TRBI->C5_TIPO
			_cPedido  := TRBI->C6_NUM
			_dEmis    := Substr(TRBI->C5_EMISSAO,7,2)+"/"+Substr(TRBI->C5_EMISSAO,5,2)+"/"+Substr(TRBI->C5_EMISSAO,1,4)

			_cCampo := "TRBI->B1_UM"

			_nPos0  := Ascan(_aVolumes, {|x| &_cCampo $ x[1]})
			
			If TRBI->B1_XUNEXP == 'KG'
				_nVal := (TRBI->C6_QTDVEN * TRBI->B1_XQTDEXP)
			Else
				_nVal := TRBI->C6_QTDVEN
			EndIf
			
			If !Empty(TRBI->B1_XUNEXP) 

				_nPos1 := Ascan(_aVolumes, {|x| TRBI->B1_XUNEXP $ x[1]})
					
				If Select("TRB1") > 0
					TRB1->(DbCloseArea())
				EndIf

				cQueryB := "SELECT B1_XQTDEXP,B1_XUNEXP,B1_UM  "+CRLF
				cQueryB += "FROM "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) "+CRLF
				cQueryB += "WHERE SB1.B1_COD = '"+TRBI->C6_PRODUTO+"' "+CRLF 
				cQueryB += " AND SB1.D_E_L_E_T_ = ' '  "+CRLF
				cQueryB += "GROUP BY B1_XQTDEXP,B1_XUNEXP,B1_UM  "+CRLF
				cQueryB += "ORDER BY B1_XQTDEXP  "+CRLF

				TcQuery cQueryB ALIAS "TRB1" NEW

				TRB1->(DbGoTop())

				While TRB1->(!Eof())

					Aadd(_aCheck,{TRB1->B1_XQTDEXP,TRB1->B1_XUNEXP,TRB1->B1_UM})  
							
					TRB1->(dbSkip())

				EndDo

				For _nCheck := 1 to Len(_aCheck)
						
					// Retorna o calculo de embalagens de acordo com a unidade de expedição e unidade de medida
					If TRBI->B1_XQTDEXP == _aCheck[_nCheck][1]  .And. _aCheck[_nCheck][3] == TRBI->B1_UM
							
						_nValFd  := ((_nVal - (_nVal % _aCheck[_nCheck][1])))/_aCheck[_nCheck][1]
						_nVal    := _nVal % _aCheck[_nCheck][1]
						_cUnExp  := _aCheck[_nCheck][2]
							
					EndIf
						
				Next _nCheck

				If _nValFd > 0
					If _nPos1 == 0
						_aVolumes[_nPasVol, 1] := _cUnExp
						_aVolumes[_nPasVol, 2] := _nValFd
						_nPasVol++
					Else
						_aVolumes[_nPos1, 2] += _nValFd
					EndIf
					If _nVal > 0
						If _nPos0 == 0
							_aVolumes[_nPasVol, 1] := &(_cCampo)
							_aVolumes[_nPasVol, 2] := _nVal
							_nPasVol++
						Else
							_aVolumes[_nPos0, 2] += _nVal
						EndIf
					EndIf
				Else

					If _nVal > 0
						If _nPos0 == 0
							_aVolumes[_nPasVol, 1] := &(_cCampo)
							_aVolumes[_nPasVol, 2] := _nVal
							_nPasVol++
						Else
							_aVolumes[_nPos0, 2] += _nVal
						EndIf
					EndIf

				EndIf

			EndIf

			// Calculo do Peso liquido e peso Bruto 
			_nPesoL+=TRBI->C6_QTDVEN * TRBI->B1_PESO
			_nPesoB+=TRBI->C6_QTDVEN * TRBI->B1_PESBRU
			
		EndIf

		TRBI->(dbSkip())

		If TRBI->(EOF()) .Or. TRBI->C6_NUM <> _cDoc 

			If _lAtVol

				SC5->(dbSetOrder(1))	//C5_FILIAL+C5_NUM
				If SC5->(dbSeek(xFilial("SC5")+_cDoc))
			
					Reclock("SC5",.F.)
					SC5->C5_ESPECI1 := AllTrim(_aVolumes[1][1])
					SC5->C5_VOLUME1 := _aVolumes[1][2]
					SC5->C5_ESPECI2 := AllTrim(_aVolumes[2][1])
					SC5->C5_VOLUME2 := _aVolumes[2][2]
					SC5->C5_ESPECI3 := AllTrim(_aVolumes[3][1])
					SC5->C5_VOLUME3 := _aVolumes[3][2]
					SC5->C5_ESPECI4 := AllTrim(_aVolumes[4][1])
					SC5->C5_VOLUME4 := _aVolumes[4][2]
					SC5->C5_ESPECI5 := AllTrim(_aVolumes[5][1])
					SC5->C5_VOLUME5 := _aVolumes[5][2]
					SC5->C5_ESPECI6 := AllTrim(_aVolumes[6][1])
					SC5->C5_VOLUME6 := _aVolumes[6][2]
					SC5->C5_ESPECI7 := AllTrim(_aVolumes[7][1])
					SC5->C5_VOLUME7 := _aVolumes[7][2]
					SC5->C5_PBRUTO  := _nPesoB
					SC5->C5_PESOL   := _nPesoL
					SC5->( Msunlock() )
					
					_aCheck   := {}
					_nPasVol  := 1
					_nVol     := 0
					_nVal     := 0
					_nValFd   := 0
					_nPos0    := 0
					_nPos1    := 0
					_nPesoB   := 0
					_nPesoL   := 0 
					_cFilial  := ""
					_cDoc     := ""
					_cSerie   := ""
					_cCliente := ""
					_cLoja    := ""
					_cFormul  := ""
					_cTipo    := ""
					_cPedido  := ""
					_dEmis    := ""
					For _nVol := 1 to Len(_aVolumes)
						_aVolumes[_nVol, 1] := ""
						_aVolumes[_nVol, 2] := 0
					Next _nVol
				
				EndIf
			
			EndIf

		EndIf

	EndDo

EndIf
//FIM TRATAMENTO
/*---------------------------------------------------------------------------------------------+
| INICIO    : Projeto Comissão especifico QUALY - 31/05/2022 - Fabio Carneiro                  |
+----------------------------------------------------------------------------------------------+
| ALTERAÇÃO : Projeto revisao de Comissão especifico QUALY - 24/06/2022 - Fabio Carneiro       |
+----------------------------------------------------------------------------------------------+
| 1 - Se o pedido de vendas for Normal e a filial estiver preenchida no parametro QE_FILCOM,   | 
| entra na regra para fazer as devidas validações.                                             |
| 2 - Será gravado os pecentuais no cabeçalho do pedido de vendas e tipo de comissão           | 
| 3 - Se o produto na PAA estiver com a comissão zerada não entra na regra para calcular a     | 
|     comissão em 09/09/2022 - Fabio carneiro.                                                 |
+----------------------------------------------------------------------------------------------*/
If cfilAnt $ cFilComis
	
	DbSelectArea("SC5")
	If SC5->(DbSeek(xFilial("SC5")+cPVenda))
		/*----------------------------------------------------------------------------------+
		| Sim e percentual preenchido no cadastro do cliente - Paga comissão pelo Cliente   | 
		+----------------------------------------------------------------------------------*/
		If cPgCliente == "2" .And. _nPercCli > 0
			If _nCliente > 0
				RecLock('SC5',.F.)
				SC5->C5_COMIS1  := _nPercCli 
				SC5->C5_COMIS2  := 0
				SC5->C5_COMIS3  := 0 
				SC5->C5_COMIS4  := 0 
				SC5->C5_COMIS5  := 0 
				SC5->C5_XTPCOM  := _cTipoCom
				SC5->( MsUnlock() )
			Else
				RecLock('SC5',.F.)
				SC5->C5_COMIS1  := 0 
				SC5->C5_COMIS2  := 0
				SC5->C5_COMIS3  := 0 
				SC5->C5_COMIS4  := 0 
				SC5->C5_COMIS5  := 0 
				SC5->C5_XTPCOM  := _cTipoCom
				SC5->( MsUnlock() )
			EndIf	
		/*---------------------------------------------------------+
		|  Não / Sim / sim  -  Paga comissão pelo Produto          | 
		+---------------------------------------------------------*/
		ElseIf cRepreClt == "1" .And. cPgCliente == "2" .And. cPgvend1 == "2" .And. _nPercCli <= 0
			If _nProduto > 0
				RecLock('SC5',.F.)
				SC5->C5_COMIS1  := Round(((_nVlComis1 / _nVlTotal) * 100),2)
				SC5->C5_COMIS2  := 0
				SC5->C5_COMIS3  := 0 
				SC5->C5_COMIS4  := 0 
				SC5->C5_COMIS5  := 0 
				SC5->C5_XTPCOM  := _cTipoCom
				SC5->( MsUnlock() )
			Else 
				RecLock('SC5',.F.)
				SC5->C5_COMIS1  := 0
				SC5->C5_COMIS2  := 0
				SC5->C5_COMIS3  := 0 
				SC5->C5_COMIS4  := 0 
				SC5->C5_COMIS5  := 0 
				SC5->C5_XTPCOM  := _cTipoCom
				SC5->( MsUnlock() )
			EndIf	
		/*--------------------------------------------------------------+
		| Sim / Sim / sim -  paga comissão pelo percentual do vendedor  |           
		+--------------------------------------------------------------*/
		ElseIf cRepreClt == "2" .And. cPgCliente == "2" .And. cPgvend1 == "2" .And. _nPercCli <= 0
			If _nVendedor > 0
				RecLock('SC5',.F.)
				SC5->C5_COMIS1  := _nVlComis1 
				SC5->C5_COMIS2  := 0
				SC5->C5_COMIS3  := 0 
				SC5->C5_COMIS4  := 0 
				SC5->C5_COMIS5  := 0 
				SC5->C5_XTPCOM  := _cTipoCom
				SC5->( MsUnlock() )
			Else
				RecLock('SC5',.F.)
				SC5->C5_COMIS1  := 0 
				SC5->C5_COMIS2  := 0
				SC5->C5_COMIS3  := 0 
				SC5->C5_COMIS4  := 0 
				SC5->C5_COMIS5  := 0 
				SC5->C5_XTPCOM  := _cTipoCom
				SC5->( MsUnlock() )
			EndIf
		/*------------------------+
		| Não paga comissão       |
		+------------------------*/
		Else  
			RecLock('SC5',.F.)
			SC5->C5_COMIS1  := 0
			SC5->C5_COMIS2  := 0
			SC5->C5_COMIS3  := 0 
			SC5->C5_COMIS4  := 0 
			SC5->C5_COMIS5  := 0 
			SC5->C5_XTPCOM  := _cTipoCom
			SC5->( MsUnlock() )
		EndIf 	
			
	EndIf

	_nVlComis1 := 0
	_nVlTotal  := 0

EndIf

_nCliente  := 0
_nProduto  := 0
_nVendedor := 0

//Restaura Area de Trabalho
If Select("WK_PAA") > 0
	WK_PAA->(DbCloseArea())
EndIf
If Select("TRBA") > 0
	TRBA->(DbCloseArea())
EndIf
If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf
If Select("TRB2") > 0
	TRB2->(DbCloseArea())
EndIf
If Select("TRBI") > 0
    TRBI->(DbCloseArea())
EndIf
If Select("TRBF") > 0
	TRBF->(DbCloseArea())
EndIf

RestArea(aArea)
RestArea(aAreaSA1)
RestArea(aAreaSA3)
RestArea(aAreaDA0)
RestArea(aAreaDA1)
RestArea(aAreaSCJ)
RestArea(aAreaSCK)
RestArea(aAreaSC5)
RestArea(aAreaSC6)
RestArea(aAreaSC9)
RestArea(aAreaEE7)
RestArea(aAreaEE8)
RestArea(aAreaSC7)

Return lRet

/*
Valida recalculo de Peso e Volume peloPonto de Entrada

nTipo: 	1 = Volume / Especie
		2 = Peso Liquido e Peso Bruto
*/

Static Function EQVldAlt(_nTipo)

Local _lRet 		:= .T.

Local _cMVXEQAVol	:= GetMv("MV_XEQAVOL",,"") // Indica OperaÃ§Ãµes que nÃ£o serÃ£o considerados para recalculo de volume
Local _cMVXEQAPes	:= GetMv( "MV_XEQAPES",, "")  // Indica OperaÃ§Ãµes que nÃ£o serÃ£o considerados para recalculo de peso

Local aAreaSC5 	:= SC5->(GetArea())

If _nTipo == 1 .And. SC5->C5_XOPER $ _cMVXEQAVOL
	_lRet := .F.
ElseIf _nTipo == 2 .And. SC5->C5_XOPER $ _cMVXEQAPES
	_lRet := .F.
Endif

RestArea(aAreaSC5)

Return _lRet
