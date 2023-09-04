#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MT242TOK บ Autor ณ Fabio F Sousa      บ Data ณ 03/01/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Ponto de entrada para valida็ใo de desmontagem de produtos บฑฑ
ฑฑบ          ณ                                 							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BERACA SABARA                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function MT242TOK()

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
Private nPosRateio  := aScan( aHeader, {|x| AllTrim(x[2]) == "D3_RATEIO"})
Private nPosCod     := aScan( aHeader, {|x| AllTrim(x[2]) == "D3_COD"})
Private nPosLocal   := aScan( aHeader, {|x| AllTrim(x[2]) == "D3_LOCAL"})
Private nPosLote    := aScan( aHeader, {|x| AllTrim(x[2]) == "D3_LOTECTL"})
Private nPosValid   := aScan( aHeader, {|x| AllTrim(x[2]) == "D3_DTVALID"})
Private nPosQuant   := aScan( aHeader, {|x| AllTrim(x[2]) == "D3_QUANT"})
Private nPosQtSeg   := aScan( aHeader, {|x| AllTrim(x[2]) == "D3_QTSEGUM"})
Private nPosMotivo  := aScan( aHeader, {|x| AllTrim(x[2]) == "D3_BE_MOTI"})
Private nPosConta   := aScan( aHeader, {|x| AllTrim(x[2]) == "D3_CONTA"})
Private nPosCC      := aScan( aHeader, {|x| AllTrim(x[2]) == "D3_CC"})

If AllTrim( Upper( GetEnvServer() ) ) <> "FABIO"
	Return lRetorno
EndIf

If l242Auto
	Return lRetorno
EndIf

lRetorno := BeAutori()

If !lRetorno
	Return lRetorno
EndIf

If lTravaUser
	If !(AllTrim( Upper( cUserName ) ) $ cUserPerm)
		Alert( "Usuแrio sem permissใo para este tipo de opera็ใo, favor contate a controladoria ou os(as) responsแveis pelo estoque!", "Aten็ใo")
		Return .F.
	EndIf
EndIf

Define MsDialog oDlg Title "Informe o motivo da desmontagem" From C(178),C(181) To C(288),C(558) Pixel

	@ C(004),C(006) Say "Descreva o motivo da desmontagem: " Size C(176),C(008) COLOR CLR_BLUE Pixel Of oDlg
	@ C(014),C(006) MsGet oMotivo Var cMotivo Size C(179),C(009) COLOR CLR_BLACK Pixel Of oDlg
	@ C(028),C(006) Say "Caso nใo informar o motivo, sua desmontagem nใo serแ realizada!" Size C(175),C(008) COLOR CLR_RED Pixel Of oDlg
	@ C(038),C(147) Button "Confirmar" Size C(037),C(012) Action (lInformado := .T., oDlg:End()) Pixel Of oDlg

Activate MsDialog oDlg Centered

If lInformado .And. !Empty( cMotivo ) // motivo ้ obrigatorio, nใo remover esta expressใo...
	EnvEMail()
Else
	lRetorno := .F.
EndIf

RestArea( aArea )

Return lRetorno

Static Function EnvEMail()

Local nLin := 0

cMensagem := ""
cAssunto  := "DE - Desmontagem: " + AllTrim( cDocumento )

aCabec := {}
aAdd( aCabec, {{'<B><Font Size=4 color=white>Dados da Desmontagem</Font></B>', '6', 100, 6, 'C'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>Evento</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>Desmontagem de Produtos</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Documento</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cDocumento ) + '</Font>', '1', 40, 2, 'L'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>Data</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + DTOC( MsDate() ) + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Hora</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + Time() + '</Font>', '1', 40, 2, 'L'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>Usuแrio</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cUserName ) + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Rotina</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + FunName() + '</Font>', '1', 40, 2, 'L'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>Filial</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( SM0->M0_CODFIL ) + ' - ' + AllTrim( SM0->M0_FILIAL ) + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Empresa</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( SM0->M0_CODIGO ) + ' - ' + AllTrim( SM0->M0_NOME ) + '</Font>', '1', 40, 2, 'L'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>Motivo</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cMotivo ) + '</Font>', '1', 90, 5, 'L'}})
aAdd( aCabec, {{'<B><Font Size=4 color=yellow>Produto Desmontado:</Font></B>', '6', 100, 6, 'C'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>Produto</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cProduto ) + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Local</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cLocOrig ) + '</Font>', '1', 40, 2, 'L'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>Lote</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cLoteDigi ) + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Validade</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + DTOC( dDtValid ) + '</Font>', '1', 40, 2, 'C'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>Quantidade</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + Transform(nQtdOrig,"@E 999,999,999.99") + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Quantidade Seg. UM</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + Transform(nQtdOrigSe,"@E 999,999,999.99") + '</Font>', '1', 40, 2, 'L'}})
aAdd( aCabec, {{'<B><Font Size=4 color=white>Desmontagem para:</Font></B>', '6', 100, 6, 'C'}})

aColunas := {}
aAdd( aColunas, {'Rateio'					, 05	, 'C'})
aAdd( aColunas, {'Produto'					, 15	, 'C'})
aAdd( aColunas, {'Quantidade'				, 13	, 'C'})
aAdd( aColunas, {'Local'					, 05	, 'C'})
aAdd( aColunas, {'Lote'						, 12	, 'C'})
aAdd( aColunas, {'Validade'					, 05	, 'C'})
aAdd( aColunas, {'Qtde. Seg. UM'			, 13	, 'C'})
aAdd( aColunas, {'Conta'					, 10	, 'C'})
aAdd( aColunas, {'CC'						, 10	, 'C'})

cMensagem += U_BeHtmHead( '',.T.,aCabec, aColunas )

For nLin := 1 To Len( aCols )
	aColunas := {}

	aAdd( aColunas, {'<Font color=red>' + Transform(aCols[nLin][nPosRateio],"@E 999.99") + '%</Font>'	, 05	, 'C'})
	aAdd( aColunas, {AllTrim(aCols[nLin][nPosCod])										, 15	, 'L'})
	aAdd( aColunas, {Transform(aCols[nLin][nPosQuant],"@E 999,999,999.99")				, 13	, 'R'})
	aAdd( aColunas, {AllTrim(aCols[nLin][nPosLocal])							  		, 05	, 'C'})
	aAdd( aColunas, {AllTrim(aCols[nLin][nPosLote])				  						, 12	, 'L'})
	aAdd( aColunas, {DTOC(aCols[nLin][nPosValid])										, 05	, 'C'})
	aAdd( aColunas, {Transform(aCols[nLin][nPosQtSeg],"@E 999,999,999.99")				, 13	, 'R'})
	aAdd( aColunas, {AllTrim(aCols[nLin][nPosConta])			  						, 10	, 'L'})
	aAdd( aColunas, {AllTrim(aCols[nLin][nPosCC])				  						, 10	, 'L'})

	If nPosMotivo > 0
		aCols[nLin][nPosMotivo] := AllTrim( cMotivo )
	EndIf

	cMensagem += U_BeHtmDet( aColunas, Mod( nLin, 2) == 0, .F. )
Next

cMensagem += U_BeHtmRod(.T.)

U_BeSendMail( { cEmailResp, cAssunto, cMensagem} )

Return

Static Function BeAutori()

Local lRet      := .T.
Local nPosProd  := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D3_COD"   })
Local nPosLoc   := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D3_LOCAL" })
Local cTipos    := GetMv( "MV_BE_BSTP",, "'MP','PI','ME','EM','BN','SP','PP'" )
Local cTipos    := GetMV( "MV_BE_BSTP",, "'XX'")

dbSelectArea("SB1")
dbSetOrder(1)
If SB1->( dbSeek( xFilial("SB1") + cProduto ) )
	If !(AllTrim( SB1->B1_TIPO ) $ "PA/PI/KT/PP/BN")
		Aviso("MT242TOK / Tipo de Produto!","Tipo Produto: " + SB1->B1_TIPO + " Nใo Permitido Efetuar Desmontagem para tipo do produto original, somente vแlido para PA, PI ou KT!",{"Cancela"})
		lRet := .F.
		Return lRet
	EndIf
EndIf

If AllTrim( SB1->B1_TIPO ) <> "PP"
	For nLin := 1 To Len( aCols )
		If ! aCols[nLin,Len(aHeader)+1]	// Indica se linha esta deletada
			dbSelectArea("SB1")
			dbSetOrder(1)
			If SB1->( dbSeek( xFilial("SB1") + aCols[nLin,nPosProd] ) )
				If !(AllTrim( SB1->B1_TIPO ) $ cTipos)
					Aviso("MT242TOK / Tipo de Produto!","Tipo Produto: " + SB1->B1_TIPO + " Nใo Permitido Efetuar Desmontagem para tipo de produtos de destinos!",{"Cancela"})
					lRet := .F.
					Exit
				EndIf
			EndIf
		EndIf
	Next
	
	For nLin := 1 To Len( aCols )
		If ! aCols[nLin,Len(aHeader)+1]	// Indica se linha esta deletada
			If AllTrim( cProduto ) == AllTrim( aCols[nLin,nPosProd] )
				Aviso("MT242TOK / C๓digo Produto!","Produto Original nใo deve ser igual ao produto(s) de destino(s)!",{"Cancela"})
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next
	
	dbSelectArea("SG1")
	dbSetOrder(1)
	
	For nLin := 1 To Len( aCols )
		If ! aCols[nLin,Len(aHeader)+1]	// Indica se linha esta deletada
			If !SG1->( dbSeek( xFilial("SG1") + Padr( cProduto, 15) + Padr( aCols[nLin,nPosProd], 15) ) )
				Aviso("MT242TOK / C๓digo Estrutura!","Produto Destino nใo pertence เ estrutura do Produto Pai!",{"Cancela"})
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next
EndIf

Return lRet