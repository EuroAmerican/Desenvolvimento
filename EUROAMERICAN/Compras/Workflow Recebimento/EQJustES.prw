#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'
              
/*
Autor   : Fabio F Sousa
Data    : 23/04/2019
Objetivo: Gravar Log de Interação na geração de NF de entradas e saídas 
          e justificativas e motivos de exclusão ou devolução de NF
          U_BeJustNF( "P", "E", "E", "C", "N", "N", "N", "N", "N", 19/12/2016, 19/12/2016 )
*/

User Function EQJustES( _cObjeto, _cEvento, _cTipoNF, _cPedido, _cDoc, _cSerie, _cTipo, _cCliFor, _cLoja, _dEmissao, _dDigit )

Local aArea    := GetArea()
Local cObjeto  := IIf( _cObjeto == NIL, "", _cObjeto)
Local cEvento  := IIf( _cEvento == NIL, "", _cEvento)
Local cTipoNF  := IIf( _cTipoNF == NIL, "", _cTipoNF)
Local cPedido  := IIf( _cPedido == NIL, "", _cPedido)
Local cDoc     := IIf( _cDoc == NIL, "", _cDoc)
Local cSerie   := IIf( _cSerie == NIL, "", _cSerie)
Local cTipo    := IIf( _cTipo == NIL, "", _cTipo)
Local cCliFor  := IIf( _cCliFor == NIL, "", _cCliFor)
Local cLoja    := IIf( _cLoja == NIL, "", _cLoja)
Local dEmissao := IIf( _dEmissao == NIL, CTOD("  /  /    "), _dEmissao)
Local dDigit   := IIf( _dDigit == NIL, CTOD("  /  /    "), _dDigit)

Private oDlg
Private cMotivo := ""
Private cJust   := Space(3)
Private cCodMot := Space(3)
Private lMotivo := .T.

//If AllTrim( cEvento ) == "E" .Or. cTipo == "D"
	Do While lMotivo

		DEFINE MSDIALOG oDlg TITLE "Informe o Motivo e Justificativa para Estorno/Modificação" FROM C(178),C(181) TO C(551),C(872) PIXEL

			@ C(002),C(002) TO C(164),C(341) LABEL "Digite um motivo válido para confirmação" PIXEL OF oDlg

			@ C(013),C(006) Say "Justificativa:" Size C(032),C(008) COLOR CLR_RED PIXEL OF oDlg
			@ C(013),C(038) MsGet oJust Var cJust F3 "Z2" Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
			@ C(023),C(006) Say "Motivo:" Size C(032),C(008) COLOR CLR_RED PIXEL OF oDlg
			@ C(023),C(038) GET oMemo1 Var cMotivo MEMO Size C(299),C(129) PIXEL OF oDlg
			@ C(167),C(303) Button "Confirmar" Size C(037),C(012) Action (oDlg:End()) PIXEL OF oDlg

			oJust:bValid := {|| !Empty( cJust ) .And. fGat(1) }
		
		ACTIVATE MSDIALOG oDlg CENTERED

		If Len( AllTrim( cMotivo ) ) > 4
			lMotivo := .F.
		Else
			ApMsgAlert('Informe um motivo válido!', 'Atenção')
		EndIf

		If !lMotivo
			If Empty( Tabela("Z2", cJust) )
				ApMsgAlert('Selecione uma Justificativa válido!', 'Atenção')
				lMotivo := .T.
			EndIf
		EndIf
	EndDo
//EndIf

RecLock( "Z20", .T.)
	Z20->Z20_FILIAL := xFilial("Z20")
	Z20->Z20_EVENTO := cEvento
	Z20->Z20_TIPONF := cTipoNF
	Z20->Z20_USUARI := cUserName
	Z20->Z20_OBJETO := cObjeto
	Z20->Z20_PEDIDO := cPedido
	Z20->Z20_DATA   := MsDate()
	Z20->Z20_HORA   := Time()
	Z20->Z20_DOC    := cDoc
	Z20->Z20_SERIE  := cSerie
	Z20->Z20_TIPO   := cTipo
	Z20->Z20_CLIFOR := cCliFor
	Z20->Z20_LOJA   := cLoja
	Z20->Z20_EMISSA := dEmissao
	Z20->Z20_DTDIGI := dDigit
	Z20->Z20_MOTIVO := cMotivo
	Z20->Z20_JUSTIF := cJust
MsUnLock()

If AllTrim( cEvento ) == "E" .Or. cTipo == "D"
	cMensagem := ""
	If AllTrim( cEvento ) == "E"
		cAssunto := "Exclusão de Nota Fiscal, Documento: " + cDoc + " Série: " + cSerie
	Else
		cAssunto := "Devolução de Nota Fiscal, Documento: " + cDoc + " Série: " + cSerie
	EndIf

	aCabec := {}
	aAdd( aCabec, {{'<B><Font Size=4 color=white>Log do Evento</Font></B>', '6', 100, 6, 'C'}})
	aAdd( aCabec, {{'<B><Font Size=2 color=black>Evento</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + IIf( cEvento == "E", "Exclusão Nota Fiscal", IIf( cEvento == "S", "Estorno Aprovação", IIf( cEvento == "X", "Exclusão Pedido", "Alteração Pedido")))  + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Tipo NF</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + IIf( cTipoNF == "E", "Entrada", "Saída") + '</Font>', '1', 40, 2, 'L'}})
	aAdd( aCabec, {{'<B><Font Size=2 color=black>Data</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + DTOC( MsDate() ) + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Hora</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + Time() + '</Font>', '1', 40, 2, 'L'}})
	aAdd( aCabec, {{'<B><Font Size=2 color=black>Usuário</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cUserName ) + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Rotina</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + FunName() + '</Font>', '1', 40, 2, 'L'}})
	aAdd( aCabec, {{'<B><Font Size=2 color=black>Justificativa</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cJust ) + " - " + Tabela("Z2", cJust) + '</Font>', '1', 90, 5, 'L'}})
	aAdd( aCabec, {{'<B><Font Size=2 color=black>Motivo</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cMotivo ) + '</Font>', '1', 90, 5, 'L'}})

	If cObjeto == "N"
		aAdd( aCabec, {{'<B><Font Size=4 color=white>Nota Fiscal</Font></B>', '6', 100, 6, 'C'}})

		aColunas := {}
		aAdd( aColunas, {'Documento'				, 12	, 'C'})
		aAdd( aColunas, {'Série'					, 05	, 'C'})
		aAdd( aColunas, {'Tipo'						, 05	, 'C'})
		aAdd( aColunas, {'Cli-For'					, 07	, 'C'})
		aAdd( aColunas, {'Loja'						, 05	, 'C'})
		aAdd( aColunas, {'Emissão'					, 08	, 'C'})
		aAdd( aColunas, {'Digitação'				, 08	, 'C'})

		cMensagem += U_BeHtmHead( '',.T.,aCabec, aColunas )

		aColunas := {}
		aAdd( aColunas, {AllTrim(cDoc)					, 12	, 'C'})
		aAdd( aColunas, {AllTrim(cSerie)		  		, 05	, 'C'})
		aAdd( aColunas, {AllTrim(cTipo)				  	, 05	, 'C'})
		aAdd( aColunas, {AllTrim(cCliFor)			  	, 07	, 'C'})
		aAdd( aColunas, {AllTrim(cLoja)				  	, 05	, 'C'})
		aAdd( aColunas, {DTOC(dEmissao)				  	, 08	, 'C'})
		aAdd( aColunas, {DTOC(dDigit)				  	, 08	, 'C'})

		cMensagem += U_BeHtmDet( aColunas, .F. , .F. )
	Else
		aAdd( aCabec, {{'<B><Font Size=4 color=white>Pedido</Font></B>', '6', 100, 6, 'C'}})

		aColunas := {}
		aAdd( aColunas, {'Pedido'					, 12	, 'C'})
		aAdd( aColunas, {'Tipo'						, 05	, 'C'})
		aAdd( aColunas, {'Fornecedor'				, 07	, 'C'})
		aAdd( aColunas, {'Loja'						, 05	, 'C'})
		aAdd( aColunas, {'Emissão'					, 08	, 'C'})

		cMensagem += U_BeHtmHead( '',.T.,aCabec, aColunas )

		aColunas := {}
		aAdd( aColunas, {AllTrim(cPedido)				, 12	, 'C'})
		aAdd( aColunas, {IIf(AllTrim(cTipo) == "1", "Pedido de Compras","Autorização de Entrega")  	, 05	, 'C'})
		aAdd( aColunas, {AllTrim(cCliFor)			  	, 07	, 'C'})
		aAdd( aColunas, {AllTrim(cLoja)				  	, 05	, 'C'})
		aAdd( aColunas, {DTOC(dEmissao)				  	, 08	, 'C'})

		cMensagem += U_BeHtmDet( aColunas, .F. , .F. )
	EndIf

	cMensagem += U_BeHtmRod(.T.)

	U_BeSendMail( { GetMV("MV_BE_NDEX",,"fabio@xisinformatica.com.br"), cAssunto, cMensagem} )
EndIf

RestArea( aArea )

Return

Static Function fGat( nOp )

If nOp == 1
	@ C(014),C(088) Say Tabela("Z2", cJust) Size C(162),C(008) COLOR CLR_HBLUE PIXEL OF oDlg
EndIf

Return .T.