#Include "protheus.ch"
#Include 'parmtype.ch'
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "ap5mail.ch"
#Include "RwMake.Ch"

#DEFINE ENTER chr(13) + chr(10)
/*/{Protheus.doc} A415TDOK  
Rotina para validar a quantidade minima de venda sugerida de acordo com a unidade de expedi��o 
@type function Ponto de Entrada
@author QualyCril 
@since 10/05/2020
@version 1.0
@History Ajustado em 30/01/2022 para o projeto unidade de expedi��o - F�bio Carneiro dos Santos 
@History Ajustado em 31/05/2022 para o projeto comiss�o qualy - Fabio carneiro dos Santos  
@History Ajustado em 04/07/2022 tratamento referente ao peso liquido e peso bruto - Fabio carneiro dos Santos 
@History Ajustado em 24/06/2022 para o projeto revis�o de comiss�o qualy - Fabio carneiro dos Santos 
@History Ajustado em 09/09/2022 tratamento referente a n�o considerar comiss�o se o item estiver zerado - Fabio carneiro dos Santos
@return Logical, .T.
/*/
User Function A415TDOK()

Local _aAreaCK      := SCK->(GetArea())
Local _aAreaCJ      := SCJ->(GetArea())
Local _aAreaB1      := SB1->(GetArea())
Local _lRet         := .T.
Local _nQtdMinima   := 0 
Local _nQtdVenda    := 0
Local _nRetMod      := 0
Local _nQtdeEmb     := 0
Local _cUnExpedicao := 0
Local _cDescProduto := "" 
Local _cUnidMedida  := ""
Local _cMsg         := ""
Local _cComRev      := ""
Local _cTabCom      := ""
//variaveis projeto comiss�o qualy - fabio carneiro - 23/02/2022
Local _cQueryB  	:= "" 
Local _cMsgA        := ""
Local _aLidos   	:= {}
Local _nLidos   	:= 0
Local _nPercCli     := 0
Local cPgCliente    := ""
Local cRepreClt     := ""
Local cPgvend1      := ""
Local cVend1        := ""
Local cFilComis     := GetMv("QE_FILCOM")
// Tratamento do peso liquido e peso bruto 01/07/2022 - Fabio Carneiro 
Local _nPesoLiq     := 0
Local _nPesoBru     := 0
Local lFoundSB1 	:= .F.
Local lVldPoliticas := .F.

If cModulo=="LOJ"  //  Se For loja nao executa = MAA 01/11/2021
	Return _lRet
End

DbSelectArea("TMP1")
TMP1->(dbGoTop())
	
While TMP1->(!EOF())

    DbSelectArea("SB1")
    DbSetOrder(1)
    If DbSeek(xFilial("SB1")+TMP1->CK_PRODUTO)
		_cUnExpedicao    := SB1->B1_XUNEXP 	//Posicione("SB1",1,xFilial("SB1")+TMP1->CK_PRODUTO,"B1_XUNEXP")
		_nQtdMinima      := SB1->B1_XQTDEXP 	//Posicione("SB1",1,xFilial("SB1")+TMP1->CK_PRODUTO,"B1_XQTDEXP") 
		_cDescProduto    := SB1->B1_DESC 	//Posicione("SB1",1,xFilial("SB1")+TMP1->CK_PRODUTO,"B1_DESC") 
		_cUnidMedida     := SB1->B1_UM 		//Posicione("SB1",1,xFilial("SB1")+TMP1->CK_PRODUTO,"B1_UM")
		_nPesoLiq        := SB1->B1_PESO 	//Posicione("SB1",1,xFilial("SB1")+TMP1->CK_PRODUTO,"B1_PESO") 
		_nPesoBru        := SB1->B1_PESBRU 	//Posicione("SB1",1,xFilial("SB1")+TMP1->CK_PRODUTO,"B1_PESBRU") 

        If !Empty(_cUnExpedicao) .And. _nQtdMinima > 0
            _nRetMod         := MOD(TMP1->CK_QTDVEN,_nQtdMinima)
            _nQtdVenda       := (TMP1->CK_QTDVEN-_nRetMod)
            _nQtdeEmb        := (_nQtdVenda/_nQtdMinima)
        EndIf 

        If Empty(_cUnExpedicao) .Or. _nQtdMinima == 0

            _cMsgA := "Este produto "+Alltrim(TMP1->CK_PRODUTO)+" est� sem unidade de expedi��o(B1_XUNEXP) e a quantidade minima de embalagem(B1_XQTDEXP) no cadastro do produto  "+ ENTER
            _cMsgA += "Verificar com os responsaveis da EXPEDI��O, LABORATORIO e OPERA��ES para fazer o preenchimento correto destas informa��es." + ENTER
            _cMsgA += "Ser� necessario clicar no bot�o cancelar e ap�s o cadastro preenchido poder� incluir ou alterar o pedido novamente !!!"
            _cMsgA += "" + ENTER
            _cMsgA += "" + ENTER
            _cMsgA += "" + ENTER
            _cMsgA += "" + ENTER
            _cMsgA += "Acionar o atendendente de vendas para solicitar a regulariza��o do cadastro de produtos, para permitir digitar o or�amento de vendas !!!"

            Aviso("Atenc�o - A415TDOK ",_cMsgA, {"Ok"}, 2)

            _lRet := .F.
        EndIf	

        If !Empty(_cUnExpedicao) .And. _nQtdMinima > 0

            If TMP1->CK_QTDVEN <> _nQtdVenda 

                _cMsg := "Favor verificar a quantidade digitada do produto "+Alltrim(TMP1->CK_PRODUTO)+" , "
                _cMsg += "que est� fora do c�lculo do minimo de embalagem, foi digitado a quantidade de "+Transform(TMP1->CK_QTDVEN, "@E 999,999,999.99")+" ! "+ENTER
                _cMsg += "Portanto, para a regra do minimo de embalagem dever� alterar a quantidade para "+Transform(If(_nQtdVenda < _nQtdMinima,_nQtdMinima,_nQtdVenda), "@E 999,999,999.99")+" de acordo com o volume e esp�cie !"+ENTER  
                _cMsg += "N�o ser� permitido prosseguir se estiver em desacordo com minimo de embalagem, sugerimos digitar a quantidade "+Transform(If(_nQtdVenda < _nQtdMinima,_nQtdMinima,_nQtdVenda), "@E 999,999,999.99")+" !"+ENTER 
                _cMsg += "Caso tenha que ser a quantidade "+Transform(TMP1->CK_QTDVEN, "@E 999,999,999.99")+", entrar em contato com o COMERCIAL !"+ENTER 
                
                Aviso("Atenc�o - A415TDOK ",_cMsg, {"Ok"}, 2)
                
                _lRet := .F.

            EndIf
        
        EndIf

		// Tratamento referente ao peso bruto e peso liquido 01/07/2022 
		If _nPesoLiq <= 0 .Or. _nPesoBru <= 0

			_cMsg := "Este produto est� com o peso liquido e peso bruto do produto "+Alltrim(TMP1->CK_PRODUTO)+" ,sem preenchimento no cadastro de produtos!"+ENTER
			_cMsg += "Favor solicitar a regulariza��o com equipe de atendimento, somente �pos o preenchimento do cadastro ser� possivel prosseguir! "+ENTER

			Aviso("Atenc�o - A415TDOK ",_cMsg, {"Ok"}, 2)
			
			_lRet := .F.

		EndIf

    EndIf 

	/*---------------------------------------------------------------------------------------------+
	| INICIO    : Projeto de Politias Comerciais - 21/06/2023 - Paulo Rogerio                      |
	+----------------------------------------------------------------------------------------------+
	| ALTERA��O : Obrigar a digita��o da justificativo e observa��o NO ITEM do or�amento, quando   |
	|             houver desconto adicional informado.                                             |
	+----------------------------------------------------------------------------------------------*/
	IF U_xFilPComl() .And. !lVldPoliticas
		//dbSelectArea("TMP1")
		IF !Empty(TMP1->CK_XDESADC) .AND. (Empty(TMP1->CK_XJUSADC) .OR. Empty(TMP1->CK_XOBSADC))
			Aviso("Politicas Comerciais - A415TDOK ","O campo de Justificativo ou Observa��o do desconto adicional n�o foi preenchido para um ou mais itens. Corrija antes de Continuar!", {"Ok"}, 2)

			_lRet := .F.
			lVldPoliticas := .T.
		Endif
	Endif

    TMP1->(dbSkip())
EndDo

/*---------------------------------------------------------------------------------------------+
| INICIO    : Projeto de Politias Comerciais - 21/06/2023 - Paulo Rogerio                      |
+----------------------------------------------------------------------------------------------+
| ALTERA��O : Obrigar a digita��o da justificativo e observa��o no CABE�ALHO do or�amento,     |
|             quando houver desconto adicional informado.                                      |
+----------------------------------------------------------------------------------------------*/
IF U_xFilPComl() .And. !lVldPoliticas
	IF !Empty(M->CJ_XDESADC) .AND. (Empty(M->CJ_XJUSADC) .OR. Empty(M->CJ_XOBSADC))
		Aviso("Politicas Comerciais - A415TDOK ","O campo de Justificativa ou Observa��o do desconto adicional n�o foi preenchido no CABE�ALHO do Or�amento. Corrija antes de Continuar!", {"Ok"}, 2)
		_lRet := .F.
	Endif
Endif

/*---------------------------------------------------------------------------------------------+
| INICIO    : Projeto Comiss�o especifico QUALY - 31/05/2022 - Fabio Carneiro                  |
+----------------------------------------------------------------------------------------------+
| ALTERA��O : Projeto revisao de Comiss�o especifico QUALY - 24/06/2022 - Fabio Carneiro       |
+----------------------------------------------------------------------------------------------+
| 1 - Quando for incluir ou alterar um or�amento pega a ultima revis�o que estver no cadastro  |
|     de produto contento % de comiss�o, ultima revis�o e tabela;                              |
| 2 - Se a filial estiver preenchida no parametro QE_FILCOM, entra na regra para fazer as      | 
|     devidas valida��es.                                                                      |    
| 3 - Se o produto na PAA estiver com a comiss�o estiver zerada n�o entra na regra para calcu- | 
|     lar a comiss�o em 09/09/2022 - Fabio carneiro.                                           |
+----------------------------------------------------------------------------------------------*/
If cfilAnt $ cFilComis
	DbSelectArea("SA1")
	DbSetOrder(1)
	dbSeek(xFilial("SA1")+M->CJ_CLIENTE+M->CJ_LOJA)

	DbSelectArea("SA3")
	DbSetOrder(1)
	dbSeek(xFilial("SA3")+M->CJ_VEND1)

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+TMP1->CK_PRODUTO)

	lFoundSB1 := Found()

	cPgCliente  := SA1->A1_XPGCOM 	//Posicione("SA1",1,xFilial("SA1")+M->CJ_CLIENTE+M->CJ_LOJA,"A1_XPGCOM")   // 1 = N�o / 2 = N�o
	_nPercCli   := SA1->A1_XCOMIS1 	//Posicione("SA1",1,xFilial("SA1")+M->CJ_CLIENTE+M->CJ_LOJA,"A1_XCOMIS1")  // Percentual de Comiss�o no Cliente
	cRepreClt   := SA3->A3_XCLT 	//Posicione("SA3",1,xFilial("SA3")+M->CJ_VEND1,"A3_XCLT")                  // 1 = N�o / 2 = N�o
	cPgvend1    := SA3->A3_XPGCOM 	//Posicione("SA3",1,xFilial("SA3")+M->CJ_VEND1,"A3_XPGCOM")                // 1 = N�o / 2 = N�o
	cVend1      := SA3->A3_COD		//Posicione("SA3",1,xFilial("SA3")+M->CJ_VEND1,"A3_COD")                   // Codigo do vendedor Cadastro 
	_cComRev    := SB1->B1_XREVCOM 	//Posicione("SB1",1,xFilial("SB1")+TMP1->CK_PRODUTO,"B1_XREVCOM")          // Ultima revs�o cadastrada na tabela PAA
	_cTabCom    := SB1->B1_XTABCOM 	//Posicione("SB1",1,xFilial("SB1")+TMP1->CK_PRODUTO,"B1_XTABCOM")          // Ultimo codigo de tabela cadastrada na tabela PAA
	//_cTipoProd  := SB1->B1_TIPO		//Posicione("SB1",1,xFilial("SB1")+TMP1->CK_PRODUTO,"B1_TIPO")             // Tipo de produto 
	_cTes       := Posicione("SF4",1,xFilial("SF4")+TMP1->CK_TES,"F4_DUPLIC")               // TES do acols  



	//DbSelectArea("SB1")
	//DbSetOrder(1)
	If lFoundSB1 //DbSeek(xFilial("SB1")+TMP1->CK_PRODUTO)

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

		For _nLidos:= 1 To Len(_aLidos) 
			/*------------------------------------------------------------------------------------+
			| Se o produto, revis�o e tabela � igual ao que esta na tabela PAA, entra na regra    | 
			+------------------------------------------------------------------------------------*/
			If _aLidos[_nLidos][01] == TMP1->CK_PRODUTO .And. _cComRev == _aLidos[_nLidos][06] .And. _cTabCom == _aLidos[_nLidos][04]
				/*----------------------------------------------------------------------------------+
				| Sim e percentual preenchido no cadastro do cliente - Paga comiss�o pelo Cliente   | 
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
				|  N�o / Sim / sim  -  Paga comiss�o pelo Produto          | 
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
				| Sim / Sim / sim -  paga comiss�o pelo percentual do vendedor  |           
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
				| N�o paga comiss�o                     |
				+--------------------------------------*/
				Else

					TMP1->CK_XTABCOM := _aLidos[_nLidos][04]
					TMP1->CK_XCOM1   := 0
					TMP1->CK_COMIS1  := 0
					TMP1->CK_XREVCOM := _aLidos[_nLidos][06]
					TMP1->CK_XDTRVC  := DDATABASE
					TMP1->CK_XTPCOM  := "04" // ZERADA

				EndIf

			EndIf

		Next _nLidos 	

	EndIf 

EndIf 


RestArea(_aAreaCK)
RestArea(_aAreaCJ)
RestArea(_aAreaB1)
Return _lRet


