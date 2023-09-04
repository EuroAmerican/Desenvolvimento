#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A261TOK  º Autor ³ Fabio F Sousa      º Data ³ 03/01/2017  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ponto de entrada para validação de transferências internas º±±
±±º          ³ modelo 2                        							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BERACA SABARA                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function A261TOK()

Local aArea         := GetArea()
Local lRetorno      := .T.

If AllTrim( Upper( GetEnvServer() ) ) <> "FABIO"
	Return lRetorno
EndIf

If lAutoma261
	Return lRetorno
EndIf

lRetorno := fValida()

If lRetorno
	lRetorno := BeAutori()
EndIf

If lRetorno
	lRetorno := fMotivo()
EndIf

RestArea( aArea )

Return lRetorno

Static Function fValida() // Efetuar validações como está na rotina de transferencia modelo 1, pois não havia tratamento para modelo 2

Local lValido       := .T.
Local nLin          := 0

Private nPosCodOri  := 1																		//Codigo do Produto Origem
Private nPosUMOri   := 3																		//Unidade de Medida Origem
Private nPosLocOri  := 4																		//Armazem Origem
Private nPosLotCTL  := Iif(!__lPyme .Or. (FindFunction("LocalizS3") .And. LocalizS3()),12,9)	//Lote de Controle
Private nPosDTVAL   := Iif(!__lPyme .Or. (FindFunction("LocalizS3") .And. LocalizS3()),14,11)	//Data Valida
Private nPosQUANT   := Iif(!__lPyme .Or. (FindFunction("LocalizS3") .And. LocalizS3()),16,13)	//Quantidade
Private nPosQTSEG   := Iif(!__lPyme .Or. (FindFunction("LocalizS3") .And. LocalizS3()),17,14)	//Quantidade na 2a. Unidade de Medida
Private nPosCodDes  := Iif(!__lPyme .Or. (FindFunction("LocalizS3") .And. LocalizS3()),6,5) 	//Codigo do Produto Destino
Private nPosUMDes   := Iif(!__lPyme .Or. (FindFunction("LocalizS3") .And. LocalizS3()),8,7)		//Unidade de Medida Destino
Private nPosLocDes  := Iif(!__lPyme .Or. (FindFunction("LocalizS3") .And. LocalizS3()),9,8)		//Armazem Destino
Private nPosLotDes  := Iif(!__lPyme .Or. (FindFunction("LocalizS3") .And. LocalizS3()),20,17) 	//Lote Destino
Private nPosDtVldD  := Iif(!__lPyme .Or. (FindFunction("LocalizS3") .And. LocalizS3()),21,18)	//Data Valida de Destino

For nLin := 1 To Len( aCols )
	If AllTrim( aCols[nLin][nPosUMOri] ) <> AllTrim( aCols[nLin][nPosUMDes] )
		Aviso("Unidade de Medida!","Unidade de Medida Origem e Destino devem ser a mesma!",{"Cancela"})
		lValido := .F.
		Exit
	EndIf
Next

Return lValido

Static Function fMotivo()

Private oDlg
Private oMotivo
Private cMotivo     := Space(250)
Private lRetorno    := .T.
Private lInformado  := .F.
Private lTravaUser  := GetMV("MV_EQ_TUMI",,.F.)
Private cUserPerm   := AllTrim( GetMV( "MV_BE_UPMI",,"ADMINISTRADOR") ) + "/ADMINISTRADOR"
Private cEmailResp  := AllTrim( GetMV( "MV_BE_ERMI",,"roni.martins@euroamerican.com.br;lucas.santos@euroamerican.com.br") )
Private cMensagem   := ""
Private cAssunto    := ""
Private nPosCodOri  := 1																		//Codigo do Produto Origem
Private nPosUMOri   := 3																		//Unidade de Medida Origem
Private nPosLocOri  := 4																		//Armazem Origem
Private nPosLotCTL  := Iif(!__lPyme .Or. (FindFunction("LocalizS3") .And. LocalizS3()),12,9)	//Lote de Controle
Private nPosDTVAL   := Iif(!__lPyme .Or. (FindFunction("LocalizS3") .And. LocalizS3()),14,11)	//Data Valida
Private nPosQUANT   := Iif(!__lPyme .Or. (FindFunction("LocalizS3") .And. LocalizS3()),16,13)	//Quantidade
Private nPosQTSEG   := Iif(!__lPyme .Or. (FindFunction("LocalizS3") .And. LocalizS3()),17,14)	//Quantidade na 2a. Unidade de Medida
Private nPosCodDes  := Iif(!__lPyme .Or. (FindFunction("LocalizS3") .And. LocalizS3()),6,5) 	//Codigo do Produto Destino
Private nPosUMDes   := Iif(!__lPyme .Or. (FindFunction("LocalizS3") .And. LocalizS3()),8,7)		//Unidade de Medida Destino
Private nPosLocDes  := Iif(!__lPyme .Or. (FindFunction("LocalizS3") .And. LocalizS3()),9,8)		//Armazem Destino
Private nPosLotDes  := Iif(!__lPyme .Or. (FindFunction("LocalizS3") .And. LocalizS3()),20,17) 	//Lote Destino
Private nPosDtVldD  := Iif(!__lPyme .Or. (FindFunction("LocalizS3") .And. LocalizS3()),21,18)	//Data Valida de Destino

If lTravaUser
	If !(AllTrim( Upper( cUserName ) ) $ cUserPerm)
		Alert( "Usuário sem permissão para este tipo de operação, favor contate a controladoria ou os(as) responsáveis pelo estoque!", "Atenção")
		Return .F.
	EndIf
EndIf

Define MsDialog oDlg Title "Informe o motivo da transferência" From C(178),C(181) To C(288),C(558) Pixel

	@ C(004),C(006) Say "Descreva o motivo da transferência: " Size C(176),C(008) COLOR CLR_BLUE Pixel Of oDlg
	@ C(014),C(006) MsGet oMotivo Var cMotivo Size C(179),C(009) COLOR CLR_BLACK Pixel Of oDlg
	@ C(028),C(006) Say "Caso não informar o motivo, sua transferência não será realizada!" Size C(175),C(008) COLOR CLR_RED Pixel Of oDlg
	@ C(038),C(147) Button "Confirmar" Size C(037),C(012) Action (lInformado := .T., oDlg:End()) Pixel Of oDlg

Activate MsDialog oDlg Centered

If lInformado .And. !Empty( cMotivo ) // motivo é obrigatorio, não remover esta expressão...
	EnvEMail()
Else
	lRetorno := .F.
EndIf

Return lRetorno

Static Function EnvEMail()

Local nLin := 0

cMensagem := ""
cAssunto  := "TR - Transferência Modelo 2: " + AllTrim( cDocumento )

aCabec := {}
aAdd( aCabec, {{'<B><Font Size=4 color=white>Dados da Transferência</Font></B>', '6', 100, 6, 'C'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>Evento</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>Transferência Modelo 2</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Documento</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cDocumento ) + '</Font>', '1', 40, 2, 'L'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>Data</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + DTOC( MsDate() ) + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Hora</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + Time() + '</Font>', '1', 40, 2, 'L'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>Usuário</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cUserName ) + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Rotina</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + FunName() + '</Font>', '1', 40, 2, 'L'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>Filial</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( SM0->M0_CODFIL ) + ' - ' + AllTrim( SM0->M0_FILIAL ) + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Empresa</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( SM0->M0_CODIGO ) + ' - ' + AllTrim( SM0->M0_NOME ) + '</Font>', '1', 40, 2, 'L'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>Motivo</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cMotivo ) + '</Font>', '1', 90, 5, 'L'}})

aAdd( aCabec, {{'<B><Font Size=4 color=white>Itens</Font></B>', '6', 100, 6, 'C'}})

aColunas := {}
aAdd( aColunas, {'Produto Origem'			, 12	, 'C'})
aAdd( aColunas, {'Local Origem'				, 05	, 'C'})
aAdd( aColunas, {'Lote Origem'				, 12	, 'C'})
aAdd( aColunas, {'Validade Origem'			, 05	, 'C'})
aAdd( aColunas, {'U.M. Origem'				, 05	, 'C'})
aAdd( aColunas, {'Quantidade'				, 10	, 'C'})
aAdd( aColunas, {'Qtde. Seg. UM'			, 10	, 'C'})
aAdd( aColunas, {'Produto Destino'			, 12	, 'C'})
aAdd( aColunas, {'Local Destino'			, 05	, 'C'})
aAdd( aColunas, {'Lote Destino'				, 12	, 'C'})
aAdd( aColunas, {'Validade Destino'			, 05	, 'C'})
aAdd( aColunas, {'U.M. Destino'				, 05	, 'C'})

cMensagem += U_BeHtmHead( '',.T.,aCabec, aColunas )

For nLin := 1 To Len( aCols )
	aColunas := {}

	aAdd( aColunas, {AllTrim(aCols[nLin][nPosCodOri])									, 12	, 'L'})
	aAdd( aColunas, {AllTrim(aCols[nLin][nPosLocOri])							  		, 05	, 'C'})
	aAdd( aColunas, {AllTrim(aCols[nLin][nPosLotCTL])				  					, 12	, 'L'})
	aAdd( aColunas, {DTOC(aCols[nLin][nPosDTVAL])										, 05	, 'C'})
	aAdd( aColunas, {AllTrim(aCols[nLin][nPosUMOri])								  	, 05	, 'C'})
	aAdd( aColunas, {Transform(aCols[nLin][nPosQUANT],"@E 999,999,999.99")				, 13	, 'R'})
	aAdd( aColunas, {Transform(aCols[nLin][nPosQTSEG],"@E 999,999,999.99")				, 13	, 'R'})
	aAdd( aColunas, {AllTrim(aCols[nLin][nPosCodDes])									, 12	, 'L'})
	aAdd( aColunas, {AllTrim(aCols[nLin][nPosLocDes])							  		, 05	, 'C'})
	aAdd( aColunas, {AllTrim(aCols[nLin][nPosLotDes])				  					, 12	, 'L'})
	aAdd( aColunas, {DTOC(aCols[nLin][nPosDtVldD])										, 05	, 'C'})
	aAdd( aColunas, {AllTrim(aCols[nLin][nPosUMDes])									, 05	, 'C'})

	cMensagem += U_BeHtmDet( aColunas, Mod( nLin, 2) == 0, .F. )
Next

cMensagem += U_BeHtmRod(.T.)

U_BeSendMail( { cEmailResp, cAssunto, cMensagem} )

Return

Static Function BeAutori()

Local nProdOri   := 1
Local nLocaOri   := 4
Local nProdDest  := IIf(!__lPyme .Or. (FindFunction("LocalizS3") .And. LocalizS3()), 6, 5)
Local nLocaDest  := IIf(!__lPyme .Or. (FindFunction("LocalizS3") .And. LocalizS3()), 9, 8)
Local nPosLoTCTL := IIf(!__lPyme .Or. (FindFunction("LocalizS3") .And. LocalizS3()),12, 9)
Local nPosLotDes := IIf(!__lPyme .Or. (FindFunction("LocalizS3") .And. LocalizS3()),20,17)
Local lRet       := .T.
Local cTipos     := GetMv( "MV_BE_TRTP",, "'PA','MP','PI','ME','EM','RV','BN','SP','PP','KT'" )
Local cLocal     := GetMv( "MV_BE_TRLC",, "'XX','  '" )
Local cTipProd   := ""
Local cUMProd    := ""
Local cLocTran   := GetMv( "MV_LOCTRAN",, "30" )

For nLin := 1 To Len( aCols )
	If ! aCols[nLin,Len(aHeader)+1]	// Indica se linha esta deletada
		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->( dbSeek( xFilial("SB1") + aCols[nLin][nProdOri] ) )
			If !(AllTrim( SB1->B1_TIPO ) $ cTipos)
				Aviso("A261TOK / Tipo Produto!","Tipo Produto Origem: " + SB1->B1_TIPO + " não permitido efetuar transferência Mod. 2!",{"Cancela"})
				lRet := .F.
				Exit
			EndIf
		EndIf

		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->( dbSeek( xFilial("SB1") + aCols[nLin][nProdDest] ) )
			If !(AllTrim( SB1->B1_TIPO ) $ cTipos)
				Aviso("A261TOK / Tipo Produto!","Tipo Produto Destino: " + SB1->B1_TIPO + " não permitido efetuar transferência Mod. 2!",{"Cancela"})
				lRet := .F.
				Exit
			EndIf
		EndIf
	EndIf
Next

For nLin := 1 To Len( aCols )
	If ! aCols[nLin,Len(aHeader)+1]	// Indica se linha esta deletada
		If AllTrim( aCols[nLin][nLocaOri] ) $ cLocal
			Aviso("A261TOK / Armazem!","Não é permitido efetuar transferência Mod. 2 nos armazém " + AllTrim( aCols[nLin][nLocaOri] ) + "!",{"Cancela"})
			lRet := .F.
			Exit
		EndIf

		If AllTrim( aCols[nLin][nLocaDest] ) $ cLocal
			Aviso("A261TOK / Armazem!","Não é permitido efetuar transferência Mod. 2 nos armazém " + AllTrim( aCols[nLin][nLocaDest] ) + "!",{"Cancela"})
			lRet := .F.
			Exit
		EndIf
	EndIf
Next

For nLin := 1 To Len( aCols )
	If ! aCols[nLin,Len(aHeader)+1]	// Indica se linha esta deletada
		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->( dbSeek( xFilial("SB1") + aCols[nLin][nProdOri] ) )
			cTipProd := AllTrim( SB1->B1_TIPO )
		EndIf
	
		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->( dbSeek( xFilial("SB1") + aCols[nLin][nProdDest] ) )
			If AllTrim( cTipProd ) <> AllTrim( SB1->B1_TIPO )
				Aviso("A261TOK / Tipo de Produto!","Não é permitido efetuar transferência de produtos com tipo diferentes entre a origem e destino!",{"Cancela"})
				lRet := .F.
				Exit
			EndIf
		EndIf
	EndIf
Next

For nLin := 1 To Len( aCols )
	If ! aCols[nLin,Len(aHeader)+1]	// Indica se linha esta deletada
		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->( dbSeek( xFilial("SB1") + aCols[nLin][nProdOri] ) )
			cUMProd := AllTrim( SB1->B1_UM )
		EndIf
	
		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->( dbSeek( xFilial("SB1") + aCols[nLin][nProdDest] ) )
			If AllTrim( cUMProd ) <> AllTrim( SB1->B1_UM )
				Aviso("A261TOK / Unidade de Medida!","Não é permitido efetuar transferência de produtos com unidade de medidas diferentes entre a origem e destino!",{"Cancela"})
				lRet := .F.
				Exit
			EndIf
		EndIf
	EndIf
Next

Return lRet