#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MT260TOK³ Autor ³ Fabio Sousa            ³ Data ³ 29/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ponto de entrada para validar transferencia internas..     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ESTOQUE                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT260TOK()

Local cAlias     := ALIAS()
Local nOrdem     := INDEXORD()
Local nRecno     := RECNO()
Local lRet       := .T.

Private cLoteDes := ParamIXB[1]

If AllTrim( Upper( GetEnvServer() ) ) <> "FABIO"
	Return lRet
EndIf

If lRet
	lRet := BeAutori()
EndIf

If lRet
	lRet := fMotivo()
EndIf

dbSelectArea(cAlias)
dbSetorder(nOrdem)
dbGoto(nRecno)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fMotivo  º Autor ³ Fabio F Sousa      º Data ³ 03/01/2017  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Abre tela para motivo da transferencia e notifica responsá-º±±
±±º          ³ veis...                         							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BERACA SABARA                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fMotivo()

Local aArea         := GetArea()

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

If !(Upper( AllTrim( FunName() ) ) == "MATA260")
	Return lRetorno
EndIf

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

RestArea( aArea )

Return lRetorno

Static Function EnvEMail()

Local nLin := 0

cMensagem := ""
cAssunto  := "TR - Transferência: " + AllTrim( cDocto )

aCabec := {}
aAdd( aCabec, {{'<B><Font Size=4 color=white>Dados da Transferência</Font></B>', '6', 100, 6, 'C'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>Evento</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>Transferência</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Documento</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cDocto ) + '</Font>', '1', 40, 2, 'L'}})
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
aAdd( aColunas, {'U.M. Destino'				, 05	, 'C'})

cMensagem += U_BeHtmHead( '',.T.,aCabec, aColunas )

aColunas := {}

aAdd( aColunas, {AllTrim(cCodOrig)													, 12	, 'L'})
aAdd( aColunas, {AllTrim(cLocOrig)											  		, 05	, 'C'})
aAdd( aColunas, {AllTrim(cLoteDigi)							  						, 12	, 'L'})
aAdd( aColunas, {DTOC(dDtValid)														, 05	, 'C'})
aAdd( aColunas, {AllTrim(cUMOrig)											  		, 05	, 'C'})
aAdd( aColunas, {Transform(nQuant260,"@E 999,999,999.99")							, 13	, 'R'})
aAdd( aColunas, {Transform(nQuant260D,"@E 999,999,999.99")							, 13	, 'R'})
aAdd( aColunas, {AllTrim(cCodDest)													, 12	, 'L'})
aAdd( aColunas, {AllTrim(cLocDest)											  		, 05	, 'C'})
aAdd( aColunas, {AllTrim(cUMDest)											  		, 05	, 'C'})

cMensagem += U_BeHtmDet( aColunas, Mod( nLin, 2) == 0, .F. )

cMensagem += U_BeHtmRod(.T.)

U_BeSendMail( { cEmailResp, cAssunto, cMensagem} )

Return

Static Function BeAutori()

Local lRet      := .T.
Local cTipos    := GetMv( "MV_BE_TRTP",, "'PA','MP','PI','ME','EM','RV','BN','SP','PP','KT'" )
Local cLocal    := GetMv( "MV_BE_TRLC",, "'XX','  '" )
Local cLocTran  := GetMv( "MV_LOCTRAN",, "30" )
Local cTipProd  := ""
Local cUMProd   := ""

dbSelectArea("SB1")
dbSetOrder(1)
If SB1->( dbSeek( xFilial("SB1") + cCodOrig ) )
	If !(AllTrim( SB1->B1_TIPO ) $ cTipos)
		Aviso("MT260TOK / Tipo Produto!","Tipo Produto Origem: " + SB1->B1_TIPO + " não permitido efetuar transferência Mod. 1!",{"Cancela"})
		lRet := .F.
		Return lRet
	EndIf
EndIf

dbSelectArea("SB1")
dbSetOrder(1)
If SB1->( dbSeek( xFilial("SB1") + cCodDest ) )
	If !(AllTrim( SB1->B1_TIPO ) $ cTipos)
		Aviso("MT260TOK / Tipo Produto!","Tipo Produto Destino: " + SB1->B1_TIPO + " não permitido efetuar transferência Mod. 1!",{"Cancela"})
		lRet := .F.
		Return lRet
	EndIf
EndIf

If AllTrim( cLocOrig ) $ cLocal
	Aviso("MT260TOK / Armazem!","Não é permitido efetuar transferência no armazém de origem " + cLocOrig + "!",{"Cancela"})
	lRet := .F.
	Return lRet
EndIf

If AllTrim( cLocDest ) $ cLocal
	Aviso("MT260TOK / Armazem!","Não é permitido efetuar transferência nos armazém de destino " + cLocDest + "!",{"Cancela"})
	lRet := .F.
	Return lRet
EndIf

dbSelectArea("SB1")
dbSetOrder(1)
If SB1->( dbSeek( xFilial("SB1") + cCodOrig ) )
	cTipProd := AllTrim( SB1->B1_TIPO )
EndIf

dbSelectArea("SB1")
dbSetOrder(1)
If SB1->( dbSeek( xFilial("SB1") + cCodDest ) )
	If AllTrim( cTipProd ) <> AllTrim( SB1->B1_TIPO )
		Aviso("MT260TOK / Tipo de Produto!","Não é permitido efetuar transferência de produtos com tipo diferentes entre a origem e destino!",{"Cancela"})
		lRet := .F.
		Return lRet
	EndIf
EndIf

dbSelectArea("SB1")
dbSetOrder(1)
If SB1->( dbSeek( xFilial("SB1") + cCodOrig ) )
	cUMProd := AllTrim( SB1->B1_UM )
EndIf

dbSelectArea("SB1")
dbSetOrder(1)
If SB1->( dbSeek( xFilial("SB1") + cCodDest ) )
	If AllTrim( cUMProd ) <> AllTrim( SB1->B1_UM )
		Aviso("MT260TOK / Unidade de Medida!","Não é permitido efetuar transferência de produtos com unidade de medidas diferentes entre a origem e destino!",{"Cancela"})
		lRet := .F.
		Return lRet
	EndIf
EndIf

If AllTrim( cCodOrig ) <> AllTrim( cCodDest )
	Aviso("MT260TOK / Produto!","Não é permitido efetuar transferência de produto origem diferente de produto destino!",{"Cancela"})
	lRet := .F.
	Return lRet
EndIf

If AllTrim( cLocOrig ) $ cLocTran
	Aviso("MT260TOK / Armazem!","Não é permitido efetuar transferência Mod. 1 em local de estoque em trânsito!",{"Cancela"})
	lRet := .F.
	Return lRet
EndIf

If AllTrim( cLocDest ) $ cLocTran
	Aviso("MT260TOK / Armazem!","Não é permitido efetuar transferência Mod. 1 em local de estoque em trânsito!",{"Cancela"})
	lRet := .F.
	Return lRet
EndIf

Return lRet