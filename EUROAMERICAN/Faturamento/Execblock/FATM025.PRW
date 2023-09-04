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
User Function FATM025()

Local lRet		:= .T.

Local cArqUsr	:= ""
Local cArqXml	:= "TEMP\DICICO_" + DtoS( dDataBase ) + "_" + U_NewAlias() + ".XML"

Local cError   	:= ""
Local cWarning 	:= ""

Local cMsg		:= ""
Local nX        := 0

Private aCabec	:= {}
Private aItens	:= {}
Private cItens	:= "01"

Private oXML	:= Nil

Begin Sequence

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Solicita arquivo XML                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cArqUsr := cGetFile("Arquivo XML|*.xml","Selecione arquivo XML referente ao pedido de compra DICICO",1,"G:\",.F.,GETF_LOCALHARD,.F.,.T.)

	If Empty(cArqUsr) .Or. At(".XML", Upper(cArqUsr)) == 0
		MsgStop("Selecione o arquivo XML referente ao pedido de compra da DICICO.")
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
		          "Verifique junto a Dicico porque pode existir rejeição no portal." + cError, "Atenção" )
		//Break
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Processa objeto XML                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MsgYesNo("Deseja prosseguir com a importação do pedido?", "DICICO")

		xCnpjCli	:= OXML:_PEDIDO:_CABECALHO:_CNPJ_EMISSOR:TEXT
		xPedCli		:= OXML:_PEDIDO:_CABECALHO:_NUMERO_PEDIDO:TEXT
		xIteCli		:= ""
		xCodBar		:= ""

		SA1->(dbSetOrder(3))
		SA1->(dbSeek(xFilial("SA1") + xCnpjCli))

		If SA1->(!Found())
			MsgStop("Nao foi possível encontrar o cadastro do cliente através do CNPJ ( " + xCnpjCli + " ) do arquivo.", "Atenção")
			Break
		EndIF

		aCabec := {}
		aItens := {}

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

		oItemP := XmlChildEx(oXML:_PEDIDO, '_ITENS')

		If oItemP != Nil

			If Type("oItemP:_ITEM") == "A"

				For nX := 1 To Len(oItemP:_ITEM)
					xIteCli		:= oItemP:_ITEM[nX]:_NUMERO_ITEM:TEXT
					xCodBar		:= oItemP:_ITEM[nX]:_CODIGO_BARRAS_PRODUTO:TEXT
					xDescri		:= oItemP:_ITEM[nX]:_DESCRICAO_PRODUTO:TEXT
					xQtde		:= Val(oItemP:_ITEM[nX]:_QUANTIDADE_PEDIDA:TEXT)
					xPrcUnt		:= Val(oItemP:_ITEM[nX]:_VALOR_UNITARIO_PRODUTO_BRUTO:TEXT)

					fAddSC6(xIteCli, xCodBar, xDescri, xQtde, xPrcUnt)
				Next nX

			Else
				xIteCli		:= oItemP:_ITEM:_NUMERO_ITEM:TEXT
				xCodBar		:= oItemP:_ITEM:_CODIGO_BARRAS_PRODUTO:TEXT
				xDescri		:= oItemP:_ITEM:_DESCRICAO_PRODUTO:TEXT
				xQtde		:= Val(oItemP:_ITEM:_QUANTIDADE_PEDIDA:TEXT)
				xPrcUnt		:= Val(oItemP:_ITEM:_VALOR_UNITARIO_PRODUTO_BRUTO:TEXT)

				fAddSC6(xIteCli, xCodBar, xDescri, xQtde, xPrcUnt)
			EndIf

			If Len(aItens) > 0

				lMsErroAuto := .F.
				MSExecAuto({|x,y,z| Mata410(x,y,z)}, aCabec, aItens, 3)

				If lMsErroAuto
					//Verificar política comercial para clientes Dicico A1_PCVIGOR, pedidos Dicico fogem a política padrão.
					MostraErro()
				Else

					cMsg := "Operação efetuada com sucesso! " + ENTER
					cMsg += "Pedido de Venda " + SC5->C5_NUM + "." + ENTER

					If !lMsErroAuto
						MsgInfo(cMsg, "Pedidos de Vendas")
					Else
						MsgStop("Houve erro na Geração do Pedido!", "Pedidos de Vendas")
					EndIf

				EndIf

			EndIf

		Else
			MsgStop("Este arquivo parece nao conter itens.", "Atenção")
			Break
		EndIf

	EndIf

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
Static Function fAddSC6(xIteCli, xCodBar, xDescri, xQtde, xPrcUnt)
Local cQry		:= ""
//Local cC6OPER	:= ""

BEGIN SEQUENCE

	cQry := " SELECT	C6_NUM PEDIDO " 								+ ENTER
	cQry += " FROM	" + RetSqlName("SC6")								+ ENTER
	cQry += " WHERE		D_E_L_E_T_ = '' " 								+ ENTER
	cQry += " 			AND C6_FILIAL = '" + xFilial("SC6") + "'"		+ ENTER
	cQry += " 			AND C6_NUMPCOM = '" + xPedCli + "'" 			+ ENTER
	cQry += " 			AND C6_ITEMPC = '" + xIteCli + "'" 				+ ENTER
	cQry += " 			AND C6_CLI = '" + SA1->A1_COD + "'" 			+ ENTER
	cQry += " 			AND C6_LOJA = '" + SA1->A1_LOJA + "'" 			+ ENTER

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

		//cC6OPER := "500"
		//cC6TES := U_FATX013O( SA1->A1_COD, SA1->A1_LOJA, SB1->B1_COD, /*cC6OPER,*/ "N" ,"","","","","","", SA1->A1_CONTRIB)
		cC6TES := "501"

		aAdd(aItens,{	{"C6_ITEM"    ,cItens			,Nil},;
		           		{"C6_PRODUTO" ,SB1->B1_COD		,Nil},;
		  		   		{"C6_DESCRI"  ,SB1->B1_DESC		,Nil},;
		           		{"C6_UM"      ,SB1->B1_UM		,Nil},;
				   		{"C6_QTDVEN"  ,xQtde			,Nil},;
				   		{"C6_TES"     ,cC6TES			,Nil},;
				   		{"C6_OPER"    , "01"            , Nil},;
		           		{"C6_LOCAL"   ,"08"				,Nil},;
				   		{"C6_PRCVEN"  ,xPrcUnt			,Nil},;
		           		{"C6_NUMPCOM" ,xPedCli			,Nil},;
				   		{"C6_ITEMPC"  ,xIteCli			,Nil}	})

		//Teste
		//MsgInfo("Item: " + cItens + " Prod: " + RTrim(SB1->B1_COD) + " Desc: "+SB1->B1_DESC+" Um: " + SB1->B1_UM + " Qtde: "+" Oper: " + xQtde + " Oper: "+cC6OPER +" TES: " + cC6TES + " PrcUn: "+" Ped + Item: " + xPedCli + " " + xIteCli)
		//MsgInfo(" Prod: " + RTrim(SB1->B1_COD) )


		cItens := Soma1(cItens, 2)

	Else
		MsgInfo("O produto " + RTrim(SB1->B1_COD) + " - " + RTrim(SB1->B1_DESC) + " não será incluído no pedido por nao atender a política de múltiplos.")
    EndIf

END SEQUENCE

Return




