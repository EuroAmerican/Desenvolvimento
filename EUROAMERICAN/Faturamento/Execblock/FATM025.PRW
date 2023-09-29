#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tryexception.ch"
#INCLUDE "FWLIBVERSION.CH"


//#INCLUDE'TOTVS.CH'


#define ENTER		CHR(13) + CHR(10)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FATM025   º Autor ³Alexandre Marson    º Data ³ 19/08/13    º±±
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
User Function FATM025(cTipo)

Local lRet		:= .T.
Local aArea     := GetArea()

Local cArqUsr	:= ""
Local cArqXml	:= "TEMP\DICICO_" + DtoS( dDataBase ) + "_" + U_NewAlias() + ".XML"
Local cError   	:= ""
Local cWarning 	:= ""

//Local cMsg		:= ""
//Local nX        := 0
//Local cNumPV    := ""

Private cMsg	:= ""

Private aHeader := {}
Private aCabec	:= {}
Private aItens	:= {}
Private cItens	:= "01"
Private aPrcPed := {}
Private nUsado  := 0
Private lMsErroAuto := .F.
Private lFatM025 := .T.

Private oXML	:= Nil

Begin Sequence

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Solicita arquivo XML                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cArqUsr := cGetFile("Arquivo XML|*.xml","Selecione arquivo XML referente ao pedido de compra do cliente",1,"G:\",.F.,GETF_LOCALHARD,.F.,.T.)

	If Empty(cArqUsr) .Or. At(".XML", Upper(cArqUsr)) == 0
		MsgStop("Selecione o arquivo XML referente ao pedido de compra do cliente.")
		Break
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Copia arquivo para pasta NFE                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Copy File &(cArqUsr) TO &(cArqXML)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Testa se arquivo foi copiado com sucesso                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If .Not. File(cArqXML)
		MsgStop( "Não foi possivel copiar arquivo para o servidor." + ENTER + ENTER +;
				 "Origem: " + cArqUsr + ENTER +;
				 "Destino: " + cArqXML)
		Break
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Cria objeto XML                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oXML := XmlParserFile(cArqXML,"_",@cError,@cWarning)

	If Empty(oXML) .Or. !Empty(cError)
		MsgStop( "Este arquivo não pode ser válidado!" + ENTER + ENTER +;
		         "Erro: " + cError, "Atenção" )
		Break
	EndIf

	If Val(SM0->M0_CGC) != Val(OXML:_PEDIDO:_CABECALHO:_CNPJ_FORNECEDOR:TEXT)
		MsgAlert( "Este pedido de compra não foi emitido para esta empresa." + ENTER + ENTER +;
		          "Verifique junto ao cliente, porque pode existir rejeição no portal." + cError, "Atenção" )
		//Break
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Processa objeto XML                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !MsgYesNo("Deseja prosseguir com a importação do pedido?", "IMPORTAÇÃO XML")
		Break
	Endif

	FwMsgRun( ,{ || fProcessa(cTipo) }, , 'Aguarde a importação do pedido...' )

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


Static Function fProcessa(cTipo)
Local nX        := 0
Local cNumPV    := ""

Private xCnpjCli:= Alltrim(OXML:_PEDIDO:_CABECALHO:_CNPJ_EMISSOR:TEXT)
Private xPedCli	:= Alltrim(OXML:_PEDIDO:_CABECALHO:_NUMERO_PEDIDO:TEXT)
Private xIteCli	:= ""
Private xCodBar	:= ""

	SA1->(dbSetOrder(3))
	SA1->(dbSeek(xFilial("SA1") + xCnpjCli))

	IF Len(xPedCli) > 10 
		MsgStop("O número do pedido do cliente deve ter no máximo 10 caracteres. Corrija antes de continuar!", "Atenção")
		Break
	Endif

	If SA1->(!Found())
		MsgStop("Nao foi possível encontrar o cadastro do cliente através do CNPJ ( " + xCnpjCli + " ) do arquivo.", "Atenção")
		Break
	EndIF

	// Recupera o indice por código.
	SA1->(dbSetOrder(1))

	aCabec := {}
	aItens := {}


	IF cTipo == "SC5"
		aCabec := {	{"C5_TIPO" 			,"N"											,Nil},;
					{"C5_CLIENTE"		,SA1->A1_COD	                            	,Nil},;
					{"C5_LOJACLI"		,SA1->A1_LOJA 									,Nil},;
					{"C5_LOJAENT"		,SA1->A1_LOJA 									,Nil},;
					{"C5_U_REQUI"		,"N"                                			,Nil},;
					{"C5_ENTREG"		,dDatabase+5									,Nil},;
					{"C5_EMISSAO"		,dDatabase										,Nil},;
					{"C5_MOEDA"			,1												,Nil},;
					{"C5_TIPLIB"		,"1"											,Nil},;
					{"C5_TPCARGA"		,"2"											,Nil},;
					{"C5_TIME"			,DtoC(Date()) + "-" + Time()					,Nil},;
					{"C5_PEDCLI"		,xPedCli		     							,Nil},;
					{"C5_INCLUI"		,cUserName										,Nil}}
	Else
		aCabec := {	{"CJ_CLIENTE"		,SA1->A1_COD	                            	,Nil},;
					{"CJ_LOJA"		    ,SA1->A1_LOJA 									,NIL},; //U_fTrigger()
					{"CJ_NOMCLI "		,SA1->A1_NOME	                            	,Nil},;
					{"CJ_CLIENT"		,SA1->A1_COD	                            	,Nil},;
					{"CJ_NOMCLI "		,SA1->A1_NOME	                            	,Nil},;
					{"CJ_EMISSAO"		,dDataBase 									    ,Nil},; 
					{"CJ_MOEDA"			,1												,Nil},;
					{"CJ_TIPLIB"		,"1"								 			,Nil},;
					{"CJ_TXMOEDA"		,1 								 			    ,Nil},;
					{"CJ_XPEDCLI"		,xPedCli		     							,Nil},;
					{"CJ_TPCARGA"		,"2"											,Nil},; 						
					{"CJ_TRANSP"		,IIF(!Empty(SA1->A1_TRANSP), SA1->A1_TRANSP, "000001") ,Nil},;
					{"CJ_OBS"  			,"PEDIDO DE COMPRA "+xPedCli			 		,Nil},;
					{"CJ_TIPOCLI"		,SA1->A1_TIPO	                            	,Nil}}
	Endif

	oItemP := XmlChildEx(oXML:_PEDIDO, '_ITENS')


	If oItemP != Nil

		If Type("oItemP:_ITEM") == "A"

			For nX := 1 To Len(oItemP:_ITEM)
				xIteCli		:= oItemP:_ITEM[nX]:_NUMERO_ITEM:TEXT
				xCodBar		:= oItemP:_ITEM[nX]:_CODIGO_BARRAS_PRODUTO:TEXT
				xDescri		:= oItemP:_ITEM[nX]:_DESCRICAO_PRODUTO:TEXT
				xQtde		:= Val(oItemP:_ITEM[nX]:_QUANTIDADE_PEDIDA:TEXT)
				xPrcUnt		:= Val(oItemP:_ITEM[nX]:_VALOR_UNITARIO_PRODUTO_BRUTO:TEXT)

				//IF AllTrim(oItemP:_ITEM[nX]:_CODIGO_PRODUTO_FORNECEDOR:TEXT) $ "7000.085.23/0630.001.55/0500.500.23"
				//	xpto := 0
				//ENDIF

				fAddSC6(xIteCli, xCodBar, xDescri, xQtde, xPrcUnt, cTipo)
			Next nX

		Else
			xIteCli		:= oItemP:_ITEM:_NUMERO_ITEM:TEXT
			xCodBar		:= oItemP:_ITEM:_CODIGO_BARRAS_PRODUTO:TEXT
			xDescri		:= oItemP:_ITEM:_DESCRICAO_PRODUTO:TEXT
			xQtde		:= Val(oItemP:_ITEM:_QUANTIDADE_PEDIDA:TEXT)
			xPrcUnt		:= Val(oItemP:_ITEM:_VALOR_UNITARIO_PRODUTO_BRUTO:TEXT)

			fAddSC6(xIteCli, xCodBar, xDescri, xQtde, xPrcUnt, cTipo)
		EndIf

		If Len(aItens) > 0
			//dbSelectArea("SCJ")

			lMsErroAuto := .F.
			IF cTipo == "SC5"
				MSExecAuto({|x,y,z| Mata410(x,y,z)}, aCabec, aItens, 3)
			Else
				MSExecAuto({|x,y,z| Mata415(x,y,z)}, aCabec, aItens, 3)
				//MATA415(aCabec, aItens, 3) 
			Endif

			If lMsErroAuto
				//Verificar política comercial para clientes Dicico A1_PCVIGOR, pedidos Dicico fogem a política padrão.
				MostraErro()
			Else
				//-------------------------------------------
				// Grava Percentuais de Desconto do cliente
				//-------------------------------------------
				cNumPV := U_xUpdItmOrc(xPedCli, SA1->A1_COD, SA1->A1_LOJA, cTipo)

				cMsg := "Operação efetuada com sucesso! " + ENTER
				IF cTipo == "SC5"
					cMsg += "Pedido de Venda " + cNumPV+ "." + ENTER
				ELSE
					cMsg += "Orçamento de Venda " + cNumPV + "." + ENTER
				Endif

				MsgInfo(cMsg, "Pedidos de Vendas")

			EndIf
		EndIf

	Else
		MsgStop("Este arquivo parece nao conter itens.", "Atenção")
		Break
	EndIf

Return

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
Static Function fAddSC6(xIteCli, xCodBar, xDescri, xQtde, xPrcUnt, cTipo)
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
		IF !empty(xPedCli)
			cQry := " SELECT CK_NUM PEDIDO " 								    + ENTER
			cQry += "   FROM	" + RetSqlName("SCK") + " AS SCK WITH(NOLOCK)"	+ ENTER
			cQry += "  WHERE D_E_L_E_T_ = '' " 								    + ENTER
			cQry += " 	 AND CK_FILIAL = '" + xFilial("SCK") + "'"		        + ENTER
			cQry += "  	 AND CK_PEDCLI  = '" + xPedCli + "'" 			        + ENTER
			cQry += " 	 AND CK_ITECLI  = '" + xIteCli + "'" 				    + ENTER
			cQry += " 	 AND CK_CLIENTE = '" + SA1->A1_COD + "'" 			    + ENTER
			cQry += " 	 AND CK_LOJA = '" + SA1->A1_LOJA + "'" 			        + ENTER
		Endif
	Endif

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TCQUERY cQry NEW ALIAS QRY


	If QRY->( !EoF() )
		Aviso("Pedido de Vendas", "O pedido do cliente " + xPedCli + " / " + xIteCli + " já foi processado no pedido: " + QRY->PEDIDO, {"Ok"}, 3)
		aItens := {}
		Break
	EndIf

	SB1->(dbSetOrder(5))
	SB1->(dbSeek(xFilial("SB1") + xCodBar))

	If SB1->( !Found() )
		MsgStop("Nao foi possível encontrar o cadastro do produto " + RTrim(xDescri) + " através do EAN " + xCodBar + " do arquivo.", "Atenção")
		aItens := {}
		Break
	EndIf

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

	xQtde		:= xQtde-(xQtde%nDivisor)

	If xQtde > 0
		cC6TES := "501"

		IF cTipo == "SC5"
			aAdd(aItens,{	{"C6_ITEM"    ,cItens			,Nil},;
							{"C6_PRODUTO" ,SB1->B1_COD		,Nil},; //{"C6_DESCRI"  ,SB1->B1_DESC		,Nil},;
							{"C6_QTDVEN"  ,xQtde			,Nil},; // {"C6_UM"      ,SB1->B1_UM		,Nil},;
							{"C6_PRCVEN"  ,xPrcUnt			,Nil},; // {"C6_TES"     ,cC6TES			,Nil},;
							{"C6_OPER"    ,"01"            , Nil},;
							{"C6_LOCAL"   ,"08"				,Nil},;
							{"C6_NUMPCOM" ,xPedCli			,Nil},;
							{"C6_ITEMPC"  ,xIteCli			,Nil}})

				Aadd(aPrcPed, {SB1->B1_COD, xPrcUnt})
		Else

			aAdd(aItens,{	{"CK_ITEM"    ,cItens			,Nil},;
							{"CK_PRODUTO" ,SB1->B1_COD		,Nil},;
							{"CK_QTDVEN"  ,xQtde       	    ,.F.},; 	// .f.				
							{"CK_PRCVEN"  ,xPrcUnt			,.F.},; 	// .f.	
							{"CK_VALOR"   ,xPrcUnt	* xQtde ,.F.},; 	// .f.	
							{"CK_OPER"    ,"01"   	        ,Nil},; 			   		
							{"CK_LOCAL"   ,"08"				,Nil},;
							{"CK_PEDCLI"  ,xPedCli			,Nil},; //{"CK_CULTRA"  ,Padr(AllTrim(Str(qOrig)), 10)	,Nil},;
							{"CK_XDTRVC"  ,dDataBase		,Nil},;							
							{"CK_XORGDES" ,"D"		        ,Nil},;							
							{"CK_ITECLI"  ,xIteCli			,Nil}})

			Aadd(aPrcPed, {SB1->B1_COD, xPrcUnt})
		Endif
 
		cItens := Soma1(cItens, 2)
	Else
		MsgInfo("O produto " + RTrim(SB1->B1_COD) + " - " + RTrim(SB1->B1_DESC) + " não será incluído no pedido por nao atender a política de múltiplos.")
    EndIf

END SEQUENCE

Return


/*
| Função...: xUpdItmOr()
| Autor....: Paulo Rogerio
| Data.....: 21/06/2023
| Retorno..: Nenhum
| Descricão: Calcula e Atualiza o Desconto adicional nos itens
|            do orçamento após importção do XML.
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User  Function xUpdItmOrc(cPedCli, cCliente, cLoja, cTipo)
Local cQry     := ""
Local cNumOrc  := ""
Local nDescto  := 0
Local nDescAdc := 0
Local nTotalOrc:= 0
Local nTotalAdc:= 0
//Local nPrcAtual:= 0

	//Verifica se o item do pedido de venda já foi incluido antes.
	IF cTipo == "SC5"
		cQry := " SELECT  TOP 1 C6_NUM PEDIDO " 								    + ENTER
		cQry += "   FROM	" + RetSqlName("SC6") + " AS SC6 WITH(NOLOCK)"	+ ENTER
		cQry += "  WHERE D_E_L_E_T_ = '' " 								    + ENTER
		cQry += " 	 AND C6_FILIAL = '" + xFilial("SC6") + "'"		        + ENTER
		cQry += "  	 AND C6_NUMPCOM = '" + cPedCli + "'" 			        + ENTER
		cQry += " 	 AND C6_CLI = '" + cCliente + "'" 			        + ENTER
		cQry += " 	 AND C6_LOJA = '" + cLoja + "'" 			        + ENTER
	Else
		IF !empty(xPedCli)
			cQry := " SELECT  TOP 1 CK_NUM PEDIDO " 								    + ENTER
			cQry += "   FROM	" + RetSqlName("SCK") + " AS SCK WITH(NOLOCK)"	+ ENTER
			cQry += "  WHERE D_E_L_E_T_ = '' " 								    + ENTER
			cQry += " 	 AND CK_FILIAL = '" + xFilial("SCK") + "'"		        + ENTER
			cQry += "  	 AND CK_PEDCLI  = '" + cPedCli + "'" 			        + ENTER
			cQry += " 	 AND CK_CLIENTE = '" + cCliente + "'" 			    + ENTER
			cQry += " 	 AND CK_LOJA = '" + cLoja+ "'" 			        + ENTER
		Endif
	Endif

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TCQUERY cQry NEW ALIAS QRY

	dbSelectArea("QRY")

	cNumOrc := PEDIDO
	
	//-------------------------------------------
	// Grava Percentuais de Desconto do cliente
	//-------------------------------------------
	dbSelectArea("SCJ")
	dbSetOrder(1)
	dbSeek(xFilial("SCJ")+cNumOrc)

	Reclock("SCJ", .F.)

	U_QEPCG01() 

	MsUnlock()

	dbSelectArea("SCK")
	dbSetOrder(1)
	dbSeek(xFilial("SCK")+SCJ->(CJ_NUM))

	nDescto := 0
	Do While CK_FILIAL+CK_NUM == xFilial("SCK")+SCJ->(CJ_NUM) .And. !Eof()
		nDescAdc := 0

		IF AllTrim(SCK->CK_PRODUTO) $ "7000.085.23/0630.001.55/0500.500.23"
			xpto := 0
		ENDIF

		nPesq := Ascan(aPrcPed, {|x| AllTrim(X[1]) == AllTrim(SCK->CK_PRODUTO)})

		Reclock("SCK", .F.)
		//SCK->CK_PRCVEN := aPrcPed[nPesq][2] 

		IF SCK->CK_PRUNIT > aPrcPed[nPesq][2]  //SCK->CK_PRCVEN
			// Recalcular o desconto adicional pela diferença do Preco com desconto vs Preço do pedido do cliente
			nDescto  := ((SCK->CK_PRCVEN    / SCK->CK_PRUNIT) * 100 ) // ((SCK->CK_PRUNIT / SCK->CK_PRCVEN) - 1) * 100
			nDescAdc := ((aPrcPed[nPesq][2] / SCK->CK_PRUNIT) * 100 ) // ((SCK->CK_PRUNIT / SCK->CK_PRCVEN) - 1) * 100

			nDescAdc := iif(nDescto - nDescAdc > 0, nDescto - nDescAdc, 0) // abs(nDescto - nDescAdc) 

			Reclock("SCK", .F.)
			SCK->CK_PRCVEN  := aPrcPed[nPesq][2] 
			SCK->CK_XDESADC := nDescAdc
			SCK->CK_XJUSADC := IIF(nDescAdc > 0, "O", "")
			SCK->CK_XOBSADC := IIF(nDescAdc > 0, "OBTIDO NO PC DO CLIENTE", "")
			SCK->CK_XORGDES := "D"
		Else
			SCK->CK_XORGDES := "A"
		Endif

		nTotalOrc  += SCK->CK_VALOR
		nTotalAdc  += SCK->CK_VALOR * (SCK->CK_XDESADC / 100)

		MsUnlock()

		dbskip()
	Enddo

	//----------------------------------------------------------
	// Grava / Atualiza Percentuais de Desconto do Cabeçalho
	//----------------------------------------------------------
	dbSelectArea("SCJ")

	Reclock("SCJ", .F.)
	IF nDescto > 0
		SCJ->CJ_XDESADC := iif(nTotalAdc > 0, nTotalAdc / nTotalOrc, 0) * 100
		SCJ->CJ_XJUSADC := "O"
		SCJ->CJ_XOBSADC := "** OBTIDO VIA IMPORTAÇÃO DO PC XML DO CLIENTE **"
	Endif

	U_QEPCG01()
	MsUnlock()

	// Calcular e Gravar Impostos, Custo e Margem de Contribuição dos ITENS do orçamento. 
	//U_xCalcMCItem(SCJ->CJ_CLIENTE, SCJ->CJ_LOJA, SCJ->CJ_NUM, 0)

	// Calcula a Margem de Contribuição Individual do Orçamento
	//Processa({|| U_xCalcMargem(@aMargem, SCJ->CJ_CLIENT, SCJ->CJ_LOJAENT, SCJ->CJ_NUM, 1, .T.)}, "Aguarde","Calculando Margem Individual...")

	U_M415GRV()

Return(cNumOrc)

