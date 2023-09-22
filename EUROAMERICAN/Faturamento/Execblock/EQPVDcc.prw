#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tryexception.ch"

#define ENTER		CHR(13) + CHR(10)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma     º Autor ³    º Data ³ 19/08/13    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³IMPORTA PEDIDO DICICO - FORMATO XML                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPON                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                     A L T E R A C O E S                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ºProgramador       ºAlteracoes                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function EQPVDcc(cArqXML, cTipo)
Local lRet		:= .F.
//Local cArqUsr	:= ""
Local nX       := 0

Local cError   	:= ""
Local cWarning 	:= ""

//Local cMsg		:= ""
//Local nPosRem	:= 0
Local aArea		:= GetArea()

Private aCabec	:= {}
Private aItens	:= {}
Private cItens	:= "01"

Private oXML		:= Nil
Private oItemP  	:= Nil
Private oRemessas	:= Nil

Private lMsErroAuto := .F.

Default cArqXML	:= ""
Default cTipo   := "SCJ"

Begin Sequence
	// Cria objeto XML
	oXML := XmlParserFile(cArqXML,"_",@cError,@cWarning)

	// Valida a criação do objeto XML
	If Empty(oXML) .Or. !Empty(cError)
		aAdd(aErros,{cArqXML,cError,"",""})
		Break
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Valida CNPJ do Pedido de venda										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*If Val(SM0->M0_CGC) != Val(OXML:_PEDIDO:_CABECALHO:_CNPJ_FORNECEDOR:TEXT) .Or. ( 03294570000120 <> Val(OXML:_PEDIDO:_CABECALHO:_CNPJ_FORNECEDOR:TEXT) )
		cError := "Este pedido de compra não foi emitido para esta empresa. Verifique junto a Dicico porque pode existir rejeição no portal."
		aAdd(aErros,{cArqXML,cError})
		//MsgAlert( "Este pedido de compra não foi emitido para esta empresa." + ENTER + ENTER +;
		//          "Verifique junto a Dicico porque pode existir rejeição no portal." + cError, "Atenção" )
		Break
	EndIf*/

	//--------------------------------------                                              
	// [INICIO ] - Processa o objeto XML   
	//--------------------------------------                                              
	xCnpjCli	:= OXML:_PEDIDO:_CABECALHO:_CNPJ_EMISSOR:TEXT
	xPedCli		:= OXML:_PEDIDO:_CABECALHO:_NUMERO_PEDIDO:TEXT
	xIteCli		:= ""
	xCodBar		:= ""
	nVlrTot		:= Val(OXML:_PEDIDO:_VALORES_TOTAIS:_VALOR_TOTAL_PEDIDO:TEXT)

	/*---------------------------------------------------------------
	  Validação de faturamento mínimo Dicico, retirada em 15/09/2023
	  por solicitação da Ellen, através do chamado 1123.
	-----------------------------------------------------------------*/

	//If nVlrTot < 1000
	//	cError := "O Pedido "+xPedCli+" não foi processado pois está abaixo de R$ 1.000,00 "
	//	aAdd(aErros,{cArqXML,cError,xPedCli,""})
	//	Break	
	//EndIf
	
	// Posiciona o cadastro do cliente
	SA1->(dbSetOrder(3))
	SA1->(dbSeek(xFilial("SA1") + xCnpjCli))

	If SA1->(!Found())
		cError := "Nao foi possível encontrar o cadastro do cliente através do CNPJ ( " + xCnpjCli + " ) do arquivo."
		aAdd(aErros,{cArqXML,cError,xPedCli,""})
		Break
	EndIF

	// Zera variaveis de inclusão do pedido
	aCabec := {}
	aItens := {}

	IF cTipo == "SC5"
		aCabec := {	{"C5_TIPO" 			,"N"											,Nil},;
					{"C5_CLIENTE"		,SA1->A1_COD	                            	,Nil},;
					{"C5_LOJACLI"		,SA1->A1_LOJA 									,Nil},;
					{"C5_LOJAENT"		,SA1->A1_LOJA 									,Nil},;
					{"C5_U_REQUI"		,"N"                                			,Nil},;
					{"C5_EMISSAO"		,dDatabase										,Nil},;
					{"C5_MOEDA"			,1												,Nil},;
					{"C5_TIPLIB"		,"1"								 			,Nil},;
					{"C5_MENNOTA"		,"PEDIDO DE COMPRA "+xPedCli			 		,Nil},;
					{"C5_TPCARGA"		,"2"											,Nil}} //,;
	Else
		aCabec := {	{"CJ_CLIENTE"		,SA1->A1_COD	                            	,Nil},;
					{"CJ_LOJA"		    ,SA1->A1_LOJA 									,Nil},;
					{"CJ_CLIENT"		,SA1->A1_COD	                            	,Nil},;
					{"CJ_LOJAENT"		,SA1->A1_LOJA 									,Nil},;
					{"CJ_EMISSAO"		,dDatabase										,Nil},;
					{"CJ_MOEDA"			,1												,Nil},;
					{"CJ_TIPLIB"		,"1"								 			,Nil},;
					{"CJ_OBS"  			,"PEDIDO DE COMPRA "+xPedCli			 		,Nil},;
					{"CJ_TPCARGA"		,"2"											,Nil}} 
	Endif

	oItemP 		:= XmlChildEx(oXML:_PEDIDO, '_ITENS')
	oRemessas 	:= XmlChildEx(oXML:_PEDIDO, '_REMESSAS')

	If oItemP != Nil
		If Type("oItemP:_ITEM") == "A"
			For nX := 1 To Len(oItemP:_ITEM)
				xIteCli		:= oItemP:_ITEM[nX]:_NUMERO_ITEM:TEXT
				xCodBar		:= oItemP:_ITEM[nX]:_CODIGO_BARRAS_PRODUTO:TEXT
				xDescri		:= oItemP:_ITEM[nX]:_DESCRICAO_PRODUTO:TEXT
				xQtde		:= Val(oItemP:_ITEM[nX]:_QUANTIDADE_PEDIDA:TEXT)
				xPrcUnt		:= Val(oItemP:_ITEM[nX]:_VALOR_UNITARIO_PRODUTO_BRUTO:TEXT)

				// Tenta adicionar o item do XML no array de itens do Pedido.
				fAddSC6(xIteCli, xCodBar, xDescri, xQtde, xPrcUnt, cArqXML, cTipo)
			Next nX
		Else
			xIteCli		:= oItemP:_ITEM:_NUMERO_ITEM:TEXT
			xCodBar		:= oItemP:_ITEM:_CODIGO_BARRAS_PRODUTO:TEXT
			xDescri		:= oItemP:_ITEM:_DESCRICAO_PRODUTO:TEXT
			xQtde		:= Val(oItemP:_ITEM:_QUANTIDADE_PEDIDA:TEXT)
			xPrcUnt		:= Val(oItemP:_ITEM:_VALOR_UNITARIO_PRODUTO_BRUTO:TEXT)

			// Tenta adicionar o item do XML no array de itens do Pedido.
			fAddSC6(xIteCli, xCodBar, xDescri, xQtde, xPrcUnt, cArqXML, cTipo)
		EndIf

		// Se existem itens para inclusão do pedido de venda, executa o MsExecAuto.
		If Len(aItens) > 0
			lMsErroAuto := .F.

			IF cTipo == "SC5"
				MSExecAuto({|x,y,z| Mata410(x,y,z)}, aCabec, aItens, 3)
			Else
				Mata415(aCabec, aItens, 3)			
			Endif

			If lMsErroAuto
				cError := "Erro no ExecAuto"
				aAdd(aErros,{cArqXML,cError, xPedCli,""})
			Else
				//-------------------------------------------
				// Grava Percentuais de Desconto do cliente
				//-------------------------------------------
				cNumPV := U_xUpdItmOrc(xPedCli, SA1->A1_COD, SA1->A1_LOJA, cTipo)
					
				aAdd(aProcs,{cArqXML,"Pedido Processado", xPedCli, cNumPV})
				lRet := .T.
			EndIf
		EndIf
	Else
		cError := "Este arquivo não contem itens"
		aAdd(aErros,{cArqXML,cError,xPedCli,""})
		Break
	EndIf
	//--------------------------------------                                              
	// [TERMINO ] - Processa o objeto XML                                                 
	//--------------------------------------                                              
End Sequence

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Forca destruicao objeto XML                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("oXML") != "U"
	FreeObj(oXML)
	oXML := Nil
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Fecha workarea temporario caso ainda esteja aberto                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

RestArea(aArea)

Return( lRet )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AddSC6   ºAutor  ³Alexandre Marson    º Data ³  29/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Adiciona item no array utilizado no MsExecAuto MATA410     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fAddSC6(xIteCli, xCodBar, xDescri, xQtde, xPrcUnt, cArqXML, cTipo)
Local cQry		:= ""
//Local cC6OPER	:= ""

BEGIN SEQUENCE
	//Verifica se o item do pedido de venda já foi incluido antes.
	IF cTipo == "SC5"
		cQry := " SELECT C6_NUM PEDIDO " 								    + ENTER
		cQry += "   FROM	" + RetSqlName("SC6") + " AS SC6 WITH(NOLOCK)"	+ ENTER
		cQry += "  WHERE D_E_L_E_T_ = '' " 								    + ENTER
		cQry += " 	 AND C6_FILIAL = '" + xFilial("SC6") + "'"		        + ENTER
		cQry += "  	 AND C6_NUMPCOM = '" + xPedCli + "'" 			        + ENTER
		cQry += " 	 AND C6_ITEMPC = '" + xIteCli + "'" 				    + ENTER
		cQry += " 	 AND C6_CLI = '" + SA1->A1_COD + "'" 			        + ENTER
		cQry += " 	 AND C6_LOJA = '" + SA1->A1_LOJA + "'" 			        + ENTER
	Else
		cQry := " SELECT CK_NUM PEDIDO " 								    + ENTER
		cQry += "   FROM	" + RetSqlName("SCK") + " AS SCK WITH(NOLOCK)"	+ ENTER
		cQry += "  WHERE D_E_L_E_T_ = '' " 								    + ENTER
		cQry += " 	 AND CK_FILIAL = '" + xFilial("SCK") + "'"		        + ENTER
		cQry += "  	 AND CK_PEDCLI  = '" + xPedCli + "'" 			        + ENTER
		cQry += " 	 AND CK_ITECLI  = '" + xIteCli + "'" 				    + ENTER
		cQry += " 	 AND CK_CLIENTE = '" + SA1->A1_COD + "'" 			    + ENTER
		cQry += " 	 AND CK_LOJA = '" + SA1->A1_LOJA + "'" 			        + ENTER
	Endif

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TCQUERY cQry NEW ALIAS QRY

	If QRY->( !EoF() )
		cError := "O pedido do cliente " + xPedCli + " / " + xIteCli + " já foi processado no pedido: " + QRY->PEDIDO
		aAdd(aErros,{cArqXML,cError,xPedCli,xIteCli})
		aItens := {}
		Break
	EndIf

	// Verifica de o código de barras esta cadastrado no SB1.
	SB1->(dbSetOrder(5))
	SB1->(dbSeek(xFilial("SB1") + xCodBar))

	If SB1->( !Found() )
		cError := "Nao foi possível encontrar o cadastro do produto " + RTrim(xDescri) + " através do EAN " + xCodBar + " do arquivo."
		aAdd(aErros,{cArqXML,cError,xPedCli,xIteCli})
		aItens := {}
		Break
	EndIf

	// Define o divisor para calculo de volumes.
	nDivisor := xQtde

	If Subs(SB1->B1_GRUPO, 1, 1) == "3" .And. SB1->B1_UM $ "GL#PT"
		Do Case
			Case SB1->B1_UM == "GL"
				nDivisor := 4

			Case SB1->B1_UM == "PT" .And. Subs(AllTrim(SB1->B1_COD), -2) != "02"
				nDivisor := 6

			Otherwise
				nDivisor := 12
		EndCase
	EndIf

	// Calcula a quantidade de volumes.
	xQtde		:= xQtde-(xQtde%nDivisor)
	xQtde		:= Abs(xQtde) // FS e FA - pegar somente quantidade absoluta para não fracionar...

	// Adiciona o item no array de itens do pedido de venda.
	If xQtde > 0
		cC6TES := "501"

		IF cTipo == "SC5"
			aAdd(aItens,{	{"C6_ITEM"    ,cItens							,Nil},;
							{"C6_PRODUTO" ,SB1->B1_COD						,Nil},; 
							{"C6_QTDVEN"  ,xQtde							,Nil},;
							{"C6_PRCVEN"  ,xPrcUnt							,Nil},;
							{"C6_OPER"    , "01"			        	    ,Nil},; 
							{"C6_LOCAL"   ,"08"								,Nil},;
							{"C6_NUMPCOM" ,xPedCli							,Nil},; 
							{"C6_ITEMPC"  ,xIteCli							,Nil}})
		Else
			aAdd(aItens,{	{"CK_ITEM"    ,cItens			,Nil},;
							{"CK_PRODUTO" ,SB1->B1_COD		,Nil},;
							{"CK_QTDVEN"  ,xQtde       	    ,.F.},; 					
							{"CK_PRCVEN"  ,xPrcUnt			,.F.},;
							{"CK_VALOR"   ,xPrcUnt	* xQtde ,.F.},;
							{"CK_OPER"    ,"01"   	        ,Nil},; 			   		
							{"CK_LOCAL"   ,"08"				,Nil},;
							{"CK_PEDCLI"  ,xPedCli			,Nil},; 
							{"CK_XDTRVC"  ,dDataBase		,Nil},;	
							{"CK_XORGDES" ,"D"		        ,Nil},;							
							{"CK_ITECLI"  ,xIteCli			,Nil}})
		Endif

		cItens := Soma1(cItens, 2)
	Else
		// Reporta o erro na inclusão do item do PV.
		cError := "O produto " + RTrim(SB1->B1_COD) + " - " + RTrim(SB1->B1_DESC) + " não será incluído no pedido por nao atender a política de múltiplos."
		aAdd(aErros,{cArqXML,cError,xPedCli,xIteCli})
		Break
    EndIf
END SEQUENCE

Return
