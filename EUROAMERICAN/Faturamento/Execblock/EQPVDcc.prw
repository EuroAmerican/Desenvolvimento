#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tryexception.ch"

#define ENTER		CHR(13) + CHR(10)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma     บ Autor ณ    บ Data ณ 19/08/13    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณIMPORTA PEDIDO DICICO - FORMATO XML                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPON                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function EQPVDcc(cArqXML)

Local lRet		:= .F.

Local cArqUsr	:= ""

Local cError   	:= ""
Local cWarning 	:= ""

Local cMsg		:= ""
Local nPosRem	:= 0
Local aArea		:= GetArea()

Private aCabec	:= {}
Private aItens	:= {}
Private cItens	:= "01"

Private oXML		:= Nil
Private oItemP  	:= Nil
Private oRemessas	:= Nil

Private lMsErroAuto := .F.

Default cArqXML	:= ""

Begin Sequence

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//|Cria objeto XML                                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oXML := XmlParserFile(cArqXML,"_",@cError,@cWarning)

	If Empty(oXML) .Or. !Empty(cError)

		aAdd(aErros,{cArqXML,cError,"",""})
		Break
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//|Valida CNPJ do Pedido de venda										ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	/*If Val(SM0->M0_CGC) != Val(OXML:_PEDIDO:_CABECALHO:_CNPJ_FORNECEDOR:TEXT) .Or. ( 03294570000120 <> Val(OXML:_PEDIDO:_CABECALHO:_CNPJ_FORNECEDOR:TEXT) )
		cError := "Este pedido de compra nใo foi emitido para esta empresa. Verifique junto a Dicico porque pode existir rejei็ใo no portal."
		aAdd(aErros,{cArqXML,cError})
		//MsgAlert( "Este pedido de compra nใo foi emitido para esta empresa." + ENTER + ENTER +;
		//          "Verifique junto a Dicico porque pode existir rejei็ใo no portal." + cError, "Aten็ใo" )
		Break
	EndIf*/

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//|Processa objeto XML                                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	xCnpjCli	:= OXML:_PEDIDO:_CABECALHO:_CNPJ_EMISSOR:TEXT
	xPedCli		:= OXML:_PEDIDO:_CABECALHO:_NUMERO_PEDIDO:TEXT
	xIteCli		:= ""
	xCodBar		:= ""
	nVlrTot		:= Val(OXML:_PEDIDO:_VALORES_TOTAIS:_VALOR_TOTAL_PEDIDO:TEXT)

	If nVlrTot < 1000
		cError := "O Pedido "+xPedCli+" nใo foi processado pois estแ abaixo de R$ 1.000,00 "
		aAdd(aErros,{cArqXML,cError,xPedCli,""})
		Break	
	EndIf
	
	SA1->(dbSetOrder(3))
	SA1->(dbSeek(xFilial("SA1") + xCnpjCli))

	If SA1->(!Found())
		cError := "Nao foi possํvel encontrar o cadastro do cliente atrav้s do CNPJ ( " + xCnpjCli + " ) do arquivo."
		aAdd(aErros,{cArqXML,cError,xPedCli,""})
		Break
	EndIF

	aCabec := {}
	aItens := {}

	aCabec := {	{"C5_TIPO" 			,"N"											,Nil},;
				{"C5_CLIENTE"		,SA1->A1_COD	                            	,Nil},;
				{"C5_LOJACLI"		,SA1->A1_LOJA 									,Nil},;
				{"C5_LOJAENT"		,SA1->A1_LOJA 									,Nil},;
				{"C5_U_REQUI"		,"N"                                			,Nil},;
				{"C5_EMISSAO"		,dDatabase										,Nil},;
				{"C5_MOEDA"			,1												,Nil},;
				{"C5_TIPLIB"		,"1"								 			,Nil},;
				{"C5_MENNOTA"		,"PEDIDO DE COMPRA "+xPedCli			 		,Nil},;
				{"C5_TPCARGA"		,"2"											,Nil}} //,;
				/*
				{"C5_ENTREG"		,dDatabase+5									,Nil},;
				{"C5_TIME"			,DtoC(Date()) + "-" + Time()					,Nil},;
				{"C5_PEDCLI"		,xPedCli		     							,Nil},;
				{"C5_ARQEDI"		,cArqXML		     							,Nil},;
				{"C5_INCLUI"		,cUserName										,Nil}}*/

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


				fAddSC6(xIteCli, xCodBar, xDescri, xQtde, xPrcUnt, cArqXML)
				
				
			Next nX

		Else
			xIteCli		:= oItemP:_ITEM:_NUMERO_ITEM:TEXT
			xCodBar		:= oItemP:_ITEM:_CODIGO_BARRAS_PRODUTO:TEXT
			xDescri		:= oItemP:_ITEM:_DESCRICAO_PRODUTO:TEXT
			xQtde		:= Val(oItemP:_ITEM:_QUANTIDADE_PEDIDA:TEXT)
			xPrcUnt		:= Val(oItemP:_ITEM:_VALOR_UNITARIO_PRODUTO_BRUTO:TEXT)

			fAddSC6(xIteCli, xCodBar, xDescri, xQtde, xPrcUnt, cArqXML)
		EndIf

		If Len(aItens) > 0

			lMsErroAuto := .F.
			MSExecAuto({|x,y,z| Mata410(x,y,z)}, aCabec, aItens, 3)

			If lMsErroAuto
				cError := "Erro no ExecAuto"
				aAdd(aErros,{cArqXML,cError, xPedCli,""})

			Else

				aAdd(aProcs,{cArqXML,"Pedido Processado", xPedCli, SC5->C5_NUM})
				lRet := .T.

			EndIf

		EndIf

	Else

		cError := "Este arquivo nใo contem itens"
		aAdd(aErros,{cArqXML,cError,xPedCli,""})
		Break

	EndIf

End Sequence

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//|Forca destruicao objeto XML                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Type("oXML") != "U"
	FreeObj(oXML)
	oXML := Nil
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//|Fecha workarea temporario caso ainda esteja aberto                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

RestArea(aArea)

Return( lRet )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AddSC6   บAutor  ณAlexandre Marson    บ Data ณ  29/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Adiciona item no array utilizado no MsExecAuto MATA410     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fAddSC6(xIteCli, xCodBar, xDescri, xQtde, xPrcUnt, cArqXML)
Local cQry		:= ""
Local cC6OPER	:= ""
Local qOrig     := xQtde

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
		cError := "O pedido do cliente " + xPedCli + " / " + xIteCli + " jแ foi processado no pedido: " + QRY->PEDIDO
		aAdd(aErros,{cArqXML,cError,xPedCli,xIteCli})
		aItens := {}
		Break
	EndIf

	SB1->(dbSetOrder(5))
	SB1->(dbSeek(xFilial("SB1") + xCodBar))

	If SB1->( !Found() )
		cError := "Nao foi possํvel encontrar o cadastro do produto " + RTrim(xDescri) + " atrav้s do EAN " + xCodBar + " do arquivo."
		aAdd(aErros,{cArqXML,cError,xPedCli,xIteCli})
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
	xQtde		:= Abs(xQtde) // FS e FA - pegar somente quantidade absoluta para nใo fracionar...

	If xQtde > 0

		cC6TES := "501"

		aAdd(aItens,{	{"C6_ITEM"    ,cItens							,Nil},;
		           		{"C6_PRODUTO" ,SB1->B1_COD						,Nil},; //{"C6_DESCRI"  ,SB1->B1_DESC		,Nil},;        		{"C6_UM"      ,SB1->B1_UM		,Nil},;
		  		   		{"C6_QTDVEN"  ,xQtde							,Nil},;
				   		{"C6_PRCVEN"  ,xPrcUnt							,Nil},;
				   		{"C6_OPER"    , "01"			        	    ,Nil},; //				   		{"C6_TES"     ,"501" /*cC6TES*/	,Nil},;				   		
		           		{"C6_LOCAL"   ,"08"								,Nil},;
		           		{"C6_NUMPCOM" ,xPedCli							,Nil},;
		           		{"C6_CULTRA"  ,Padr(AllTrim(Str(qOrig)), 10)	,Nil},;
				   		{"C6_ITEMPC"  ,xIteCli							,Nil}})

		cItens := Soma1(cItens, 2)

	Else
		cError := "O produto " + RTrim(SB1->B1_COD) + " - " + RTrim(SB1->B1_DESC) + " nใo serแ incluํdo no pedido por nao atender a polํtica de m๚ltiplos."
		aAdd(aErros,{cArqXML,cError,xPedCli,xIteCli})
		Break

    EndIf

END SEQUENCE

Return
