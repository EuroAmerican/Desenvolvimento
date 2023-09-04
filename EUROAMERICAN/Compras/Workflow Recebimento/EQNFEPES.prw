#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'RwMake.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

/*
Programa: Abre tela para efetivar amarração controle de pesagens na nota fiscal...
*/

User Function EQNFEPES()

Local aArea         := GetArea()
Local dDataIni      := dDataBase - GetMV("MV_EQ_EDIA",,5)
Local dDataFin      := dDataBase + GetMV("MV_EQ_EDIA",,5)

Private lConfirma   := .F.
Private lMarcado    := .F.
Private lValido     := .F.
Private aPesagem    := {}
Private aTicket     := {}
Private oOk         := LoadBitmap( GetResources(), "LBOK"        )
Private oNo         := LoadBitmap( GetResources(), "LBNO"        )
Private oFontSald1  := TFont():New( "Courier New",,27,,.F.,,,,,.F. )
Private oFontSaldo  := TFont():New( "Courier New",,27,,.T.,,,,,.F. )
Private oFontMsg    := TFont():New( "Courier New",,14,,.T.,,,,,.F. )
Private oFontC01    := TFont():New( "Courier New",,14,,.F.,,,,,.F. )
Private oFontC02    := TFont():New( "Courier New",,14,,.T.,,,,,.F. )
Private oFontC52    := TFont():New( "Courier New",,18,,.T.,,,,,.F. )
Private oFontC51    := TFont():New( "Arial"      ,,23,,.T.,,,,,.F. )
Private oFontC50    := TFont():New( "Arial"      ,,23,,.F.,,,,,.F. )
Private oFontC12    := TFont():New( "Arial"      ,,14,,.F.,,,,,.F. )

Public aSZZxSF1     := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se tipo da nota fiscal estiver preenchido...                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cTipo)
	ApMsgAlert('Informar o tipo da Nota Fiscal', 'Atenção')
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se tipo da nota fiscal for igual a N=Normal...                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo <> 'N'
	ApMsgAlert('Importação dos produtos válida somente para nota fiscal tipo normal', 'Atenção')
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se formulario proprio estiver preenchido...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cFormul)
	ApMsgAlert('Informar o Formulário', 'Atenção')
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se formulario proprio for igual a nao, campo de nota fiscal deve ser preenchido...   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cFormul == 'N'
	If Empty(cNFiscal)
		ApMsgAlert('Informar o número da Nota Fiscal', 'Atenção')
		Return
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se o fornecedor estiver preenchido...                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cA100For)
	ApMsgAlert('Informar o Fornecedor', 'Atenção')
	Return
EndIf

cQuery := "SELECT ZZ_CODIGO, ZZ_EMISSAO, ZZ_HREMISS, ZZ_PLACA, " + CRLF
cQuery += "CASE WHEN ZZ_TIPO = 'CG' THEN 'Carga' ELSE " + CRLF
cQuery += "CASE WHEN ZZ_TIPO = 'DG' THEN 'Descarga' ELSE " + CRLF
cQuery += "CASE WHEN ZZ_TIPO = 'DV' THEN 'Devolução' ELSE " + CRLF
cQuery += "CASE WHEN ZZ_TIPO = 'RT' THEN 'Retorno' ELSE " + CRLF
cQuery += "CASE WHEN ZZ_TIPO = 'RE' THEN 'Retira' ELSE " + CRLF
cQuery += "CASE WHEN ZZ_TIPO = 'CL' THEN 'Coleta' ELSE " + CRLF
cQuery += "CASE WHEN ZZ_TIPO = 'OT' THEN 'Outros' ELSE 'Não Classificado' END END END END END END END AS TIPO, " + CRLF
cQuery += "ZZ_PESO1, ZZ_DTPES1, ZZ_USRP1, ZZ_TPDOC1, ZZ_SERIE1, ZZ_DOC1, ZZ_EMPRESA, ZZ_TRANSP, ZZ_MOTOR, " + CRLF
cQuery += "ISNULL( CONVERT( VARCHAR(5000), ZZ_OBS), '') AS OBSERVACAO, " + CRLF
cQuery += "ISNULL( CONVERT( VARCHAR(5000), ZZ_MATER), '') AS MATER, " + CRLF
cQuery += "ISNULL( CONVERT( VARCHAR(5000), ZZ_HISTCOM), '') AS HISTORICO, SZZ.R_E_C_N_O_ AS RECNOSZZ " + CRLF
cQuery += "FROM " + RetSqlName("SZZ") + " AS SZZ WITH (NOLOCK) " + CRLF
cQuery += "WHERE ZZ_FILIAL = '" + xFilial("SZZ") + "' " + CRLF

If Inclui .Or. (l103Class .Or. l103TolRec)
	lMarcado := .F.
	cQuery += "AND ZZ_EMISSAO BETWEEN '" + DTOS( dDataIni ) + "' AND '" + DTOS( dDataFin ) + "' " + CRLF
	cQuery += "AND ZZ_DTPES2 = '' " + CRLF
	cQuery += "AND ZZ_PESO2 = 0 " + CRLF
	cQuery += "AND ZZ_FLAGP1 = 'T' " + CRLF
	cQuery += "AND ZZ_FLAGP2 = 'F' " + CRLF
	cQuery += "AND NOT ISNULL( CONVERT( VARCHAR(5000), ZZ_OBS), '') LIKE '%CANCELADO%' " + CRLF
	cQuery += "AND NOT EXISTS (SELECT F1_FILIAL FROM " + RetSqlName("SF1") + " AS SF1 WITH (NOLOCK) WHERE F1_FILIAL <> '**' AND F1_TICPESA = ZZ_CODIGO AND SF1.D_E_L_E_T_ = ' ') " + CRLF
Else
	If !Empty( SF1->F1_TICPESA )
		lMarcado := .T.
		cQuery += "AND ZZ_CODIGO = '" + SF1->F1_TICPESA + "' " + CRLF
	Else
		lMarcado := .F.
		cQuery += "AND ZZ_EMISSAO BETWEEN '" + DTOS( dDataIni ) + "' AND '" + DTOS( dDataFin ) + "' " + CRLF
		cQuery += "AND ZZ_DTPES2 = '' " + CRLF
		cQuery += "AND ZZ_PESO2 = 0 " + CRLF
		cQuery += "AND ZZ_FLAGP1 = 'T' " + CRLF
		cQuery += "AND ZZ_FLAGP2 = 'F' " + CRLF
		cQuery += "AND NOT ISNULL( CONVERT( VARCHAR(5000), ZZ_OBS), '') LIKE '%CANCELADO%' " + CRLF
		cQuery += "AND NOT EXISTS (SELECT F1_FILIAL FROM " + RetSqlName("SF1") + " AS SF1 WITH (NOLOCK) WHERE F1_FILIAL <> '**' AND F1_TICPESA = ZZ_CODIGO AND SF1.D_E_L_E_T_ = ' ') " + CRLF
	EndIf
EndIf
cQuery += "AND SZZ.D_E_L_E_T_ = ' ' " + CRLF

TCQuery cQuery New Alias "TMPSZZ"
dbSelectArea("TMPSZZ")
dbGoTop()

//If TMPSZZ->( Eof() )
//	ApMsgAlert('Não há controle de pesagens pendentes no período para amarração!', 'Atenção')
//	TMPSZZ->( dbCloseArea() )
//	Return
//EndIf

Do While !TMPSZZ->( Eof() )
	aAdd( aPesagem, { lMarcado,;					// 01 - Marcar
					TMPSZZ->ZZ_CODIGO,;				// 02 - Código Pesagem
	                STOD( TMPSZZ->ZZ_EMISSAO ),;	// 03 - Emissão
	                TMPSZZ->ZZ_HREMISS,;			// 04 - Hora
	                TMPSZZ->TIPO,;					// 05 - Tipo
	                STOD( TMPSZZ->ZZ_DTPES1 ),;		// 06 - Data Pesagem
	                TMPSZZ->ZZ_PESO1,;				// 07 - 1a Peso
	                AllTrim( TMPSZZ->ZZ_USRP1 ),;	// 08 - Usuário
	                AllTrim( TMPSZZ->ZZ_SERIE1 ),;	// 09 - Série
	                AllTrim( TMPSZZ->ZZ_DOC1 ),;	// 10 - Documento
	                AllTrim( TMPSZZ->ZZ_EMPRESA ),;	// 11 - Empresa
	                AllTrim( TMPSZZ->ZZ_TRANSP ),;	// 12 - Transportadora
	                AllTrim( TMPSZZ->ZZ_TPDOC1 ),;	// 13 - Tipo Documento
	                AllTrim( TMPSZZ->ZZ_PLACA ),;	// 14 - Placa
	                AllTrim( TMPSZZ->ZZ_MOTOR ),;	// 15 - Motorista
	                AllTrim( TMPSZZ->OBSERVACAO ),;	// 16 - Observação
	                AllTrim( TMPSZZ->MATER ),;		// 17 - Materiais
	                AllTrim( TMPSZZ->HISTORICO ),;	// 18 - Histórico
	                TMPSZZ->RECNOSZZ})				// 19 - Recno

	TMPSZZ->( dbSkip() )
EndDo

TMPSZZ->( dbCloseArea() )

// Para Tickets Utilizados...
cQuery := "SELECT ZZ_CODIGO, ZZ_EMISSAO, ZZ_HREMISS, ZZ_PLACA, " + CRLF
cQuery += "CASE WHEN ZZ_TIPO = 'CG' THEN 'Carga' ELSE " + CRLF
cQuery += "CASE WHEN ZZ_TIPO = 'DG' THEN 'Descarga' ELSE " + CRLF
cQuery += "CASE WHEN ZZ_TIPO = 'DV' THEN 'Devolução' ELSE " + CRLF
cQuery += "CASE WHEN ZZ_TIPO = 'RT' THEN 'Retorno' ELSE " + CRLF
cQuery += "CASE WHEN ZZ_TIPO = 'RE' THEN 'Retira' ELSE " + CRLF
cQuery += "CASE WHEN ZZ_TIPO = 'CL' THEN 'Coleta' ELSE " + CRLF
cQuery += "CASE WHEN ZZ_TIPO = 'OT' THEN 'Outros' ELSE 'Não Classificado' END END END END END END END AS TIPO, " + CRLF
cQuery += "ZZ_PESO1, ZZ_DTPES1, ZZ_USRP1, ZZ_TPDOC1, ZZ_SERIE1, ZZ_DOC1, ZZ_EMPRESA, ZZ_TRANSP, ZZ_MOTOR, " + CRLF
cQuery += "ISNULL( CONVERT( VARCHAR(5000), ZZ_OBS), '') AS OBSERVACAO, " + CRLF
cQuery += "ISNULL( CONVERT( VARCHAR(5000), ZZ_MATER), '') AS MATER, " + CRLF
cQuery += "ISNULL( CONVERT( VARCHAR(5000), ZZ_HISTCOM), '') AS HISTORICO, SZZ.R_E_C_N_O_ AS RECNOSZZ " + CRLF
cQuery += "FROM " + RetSqlName("SZZ") + " AS SZZ WITH (NOLOCK) " + CRLF
cQuery += "WHERE ZZ_FILIAL = '" + xFilial("SZZ") + "' " + CRLF

If Inclui .Or. (l103Class .Or. l103TolRec)
	lMarcado := .F.
	cQuery += "AND ZZ_EMISSAO BETWEEN '" + DTOS( dDataIni ) + "' AND '" + DTOS( dDataFin ) + "' " + CRLF
	cQuery += "AND ZZ_DTPES2 = '' " + CRLF
	cQuery += "AND ZZ_PESO2 = 0 " + CRLF
	cQuery += "AND ZZ_FLAGP1 = 'T' " + CRLF
	cQuery += "AND ZZ_FLAGP2 = 'F' " + CRLF
	cQuery += "AND NOT ISNULL( CONVERT( VARCHAR(5000), ZZ_OBS), '') LIKE '%CANCELADO%' " + CRLF
	cQuery += "AND EXISTS (SELECT F1_FILIAL FROM " + RetSqlName("SF1") + " AS SF1 WITH (NOLOCK) WHERE F1_FILIAL <> '**' AND F1_TICPESA = ZZ_CODIGO AND SF1.D_E_L_E_T_ = ' ') " + CRLF
Else
	If !Empty( SF1->F1_TICPESA )
		lMarcado := .T.
		cQuery += "AND ZZ_CODIGO = '" + SF1->F1_TICPESA + "' " + CRLF
	Else
		lMarcado := .F.
		cQuery += "AND ZZ_EMISSAO BETWEEN '" + DTOS( dDataIni ) + "' AND '" + DTOS( dDataFin ) + "' " + CRLF
		cQuery += "AND ZZ_DTPES2 = '' " + CRLF
		cQuery += "AND ZZ_PESO2 = 0 " + CRLF
		cQuery += "AND ZZ_FLAGP1 = 'T' " + CRLF
		cQuery += "AND ZZ_FLAGP2 = 'F' " + CRLF
		cQuery += "AND NOT ISNULL( CONVERT( VARCHAR(5000), ZZ_OBS), '') LIKE '%CANCELADO%' " + CRLF
		cQuery += "AND EXISTS (SELECT F1_FILIAL FROM " + RetSqlName("SF1") + " AS SF1 WITH (NOLOCK) WHERE F1_FILIAL <> '**' AND F1_TICPESA = ZZ_CODIGO AND SF1.D_E_L_E_T_ = ' ') " + CRLF
	EndIf
EndIf
cQuery += "AND SZZ.D_E_L_E_T_ = ' ' " + CRLF

TCQuery cQuery New Alias "TMPUSU"
dbSelectArea("TMPUSU")
dbGoTop()

//If TMPUSU->( Eof() )
//	ApMsgAlert('Não há controle de pesagens pendentes no período para amarração!', 'Atenção')
//	TMPUSU->( dbCloseArea() )
//	Return
//EndIf

Do While !TMPUSU->( Eof() )
	aAdd( aTicket , { lMarcado,;					// 01 - Marcar
					TMPUSU->ZZ_CODIGO,;				// 02 - Código Pesagem
	                STOD( TMPUSU->ZZ_EMISSAO ),;	// 03 - Emissão
	                TMPUSU->ZZ_HREMISS,;			// 04 - Hora
	                TMPUSU->TIPO,;					// 05 - Tipo
	                STOD( TMPUSU->ZZ_DTPES1 ),;		// 06 - Data Pesagem
	                TMPUSU->ZZ_PESO1,;				// 07 - 1a Peso
	                AllTrim( TMPUSU->ZZ_USRP1 ),;	// 08 - Usuário
	                AllTrim( TMPUSU->ZZ_SERIE1 ),;	// 09 - Série
	                AllTrim( TMPUSU->ZZ_DOC1 ),;	// 10 - Documento
	                AllTrim( TMPUSU->ZZ_EMPRESA ),;	// 11 - Empresa
	                AllTrim( TMPUSU->ZZ_TRANSP ),;	// 12 - Transportadora
	                AllTrim( TMPUSU->ZZ_TPDOC1 ),;	// 13 - Tipo Documento
	                AllTrim( TMPUSU->ZZ_PLACA ),;	// 14 - Placa
	                AllTrim( TMPUSU->ZZ_MOTOR ),;	// 15 - Motorista
	                AllTrim( TMPUSU->OBSERVACAO ),;	// 16 - Observação
	                AllTrim( TMPUSU->MATER ),;		// 17 - Materiais
	                AllTrim( TMPUSU->HISTORICO ),;	// 18 - Histórico
	                TMPUSU->RECNOSZZ})				// 19 - Recno

	TMPUSU->( dbSkip() )
EndDo

TMPUSU->( dbCloseArea() )

If Len( aPesagem ) == 0 .And. Len( aTicket ) == 0
	ApMsgAlert('Não há controle de pesagens pendentes no período para amarração!', 'Atenção')
	Return
EndIf

If Len( aPesagem ) == 0
	aAdd( aPesagem , { .F.,;		// 01 - Marcar
					"",;			// 02 - Código Pesagem
	                STOD( "" ),;	// 03 - Emissão
	                "",;			// 04 - Hora
	                "",;			// 05 - Tipo
	                STOD( "" ),;	// 06 - Data Pesagem
	                0,;				// 07 - 1a Peso
	                "",;			// 08 - Usuário
	                "",;			// 09 - Série
	                "",;			// 10 - Documento
	                "",;			// 11 - Empresa
	                "",;			// 12 - Transportadora
	                "",;			// 13 - Tipo Documento
	                "",;			// 14 - Placa
	                "",;			// 15 - Motorista
	                "",;			// 16 - Observação
	                "",;			// 17 - Materiais
	                "",;			// 18 - Histórico
	                0})				// 19 - Recno
EndIf

If Len( aTicket ) == 0
	aAdd( aTicket , { .F.,;			// 01 - Marcar
					"",;			// 02 - Código Pesagem
	                STOD( "" ),;	// 03 - Emissão
	                "",;			// 04 - Hora
	                "",;			// 05 - Tipo
	                STOD( "" ),;	// 06 - Data Pesagem
	                0,;				// 07 - 1a Peso
	                "",;			// 08 - Usuário
	                "",;			// 09 - Série
	                "",;			// 10 - Documento
	                "",;			// 11 - Empresa
	                "",;			// 12 - Transportadora
	                "",;			// 13 - Tipo Documento
	                "",;			// 14 - Placa
	                "",;			// 15 - Motorista
	                "",;			// 16 - Observação
	                "",;			// 17 - Materiais
	                "",;			// 18 - Histórico
	                0})				// 19 - Recno
EndIf

DEFINE MSDIALOG oDlgAdiant TITLE "Controle de Pesagem" FROM 000, 000  TO 296, 785 PIXEL

	aTFolder := {'Controle de Pesagem','Ticket Utilizado'}
	oTFolder := TFolder():New( 0,0,aTFolder,,oDlgAdiant,,,,.T.,,C(309),C(094))

	oGroup:= TGroup():New(C(003),C(005),C(077),C(303), 'Duplo-Clique | Selecione um controle de pesagem válido para amarração', oTFolder:aDialogs[1],,,.T.)

	oLbx := TcBrowse():New(C(010),C(010),C(289),C(066),,,,oTFolder:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)

	oLbx:AddColumn( TCColumn():New(" "                  ,{ || If(aPesagem[oLbx:nAt,01] .And. !Empty(aPesagem[oLbx:nAt,02]),oOk,oNo) },                           ,,,        ,,.T.,.F.,,,,.F.,) )
	oLbx:AddColumn( TcColumn():New("Código"             ,{ || aPesagem[oLbx:nAt,02] }   ,""                                  ,,,"CENTER",,.F.,.F.,,,,.F.,) )
	oLbx:AddColumn( TcColumn():New("Emissão"            ,{ || aPesagem[oLbx:nAt,03] }   ,""                                  ,,,"CENTER",,.F.,.F.,,,,.F.,) )
	oLbx:AddColumn( TcColumn():New("Hora"               ,{ || aPesagem[oLbx:nAt,04] }   ,""                                  ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oLbx:AddColumn( TcColumn():New("Tipo"               ,{ || aPesagem[oLbx:nAt,05] }   ,""                                  ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oLbx:AddColumn( TcColumn():New("Documento"          ,{ || aPesagem[oLbx:nAt,10] }   ,""                                  ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oLbx:AddColumn( TcColumn():New("Série"              ,{ || aPesagem[oLbx:nAt,09] }   ,"@!"                                ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oLbx:AddColumn( TcColumn():New("Peso 1"             ,{ || aPesagem[oLbx:nAt,07] }   ,"@E 999,999,999.99"                 ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )
	oLbx:AddColumn( TcColumn():New("Usuário"            ,{ || aPesagem[oLbx:nAt,08] }   ,""                                  ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oLbx:AddColumn( TcColumn():New("Empresa"            ,{ || aPesagem[oLbx:nAt,11] }   ,"@!"                                ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oLbx:AddColumn( TcColumn():New("Transportadora"     ,{ || aPesagem[oLbx:nAt,12] }   ,"@!"                                ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )

	oLbx:SetArray( aPesagem )
	oLbx:bLDblClick := {|| aPesagem[oLbx:nAt][1] := !aPesagem[oLbx:nAt][1], oLbx:DrawSelect() }

	oLbx:GoTop()

	oGroup1:= TGroup():New(C(003),C(005),C(077),C(303), 'Duplo-Clique | Selecione um controle de pesagem válido para amarração', oTFolder:aDialogs[2],,,.T.)

	oLbx1 := TcBrowse():New(C(010),C(010),C(289),C(066),,,,oTFolder:aDialogs[2],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)

	oLbx1:AddColumn( TCColumn():New(" "                  ,{ || If(aTicket[oLbx1:nAt,01] .And. !Empty(aTicket[oLbx1:nAt,02]),oOk,oNo) },                           ,,,        ,,.T.,.F.,,,,.F.,) )
	oLbx1:AddColumn( TcColumn():New("Código"             ,{ || aTicket[oLbx1:nAt,02] }   ,""                                  ,,,"CENTER",,.F.,.F.,,,,.F.,) )
	oLbx1:AddColumn( TcColumn():New("Emissão"            ,{ || aTicket[oLbx1:nAt,03] }   ,""                                  ,,,"CENTER",,.F.,.F.,,,,.F.,) )
	oLbx1:AddColumn( TcColumn():New("Hora"               ,{ || aTicket[oLbx1:nAt,04] }   ,""                                  ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oLbx1:AddColumn( TcColumn():New("Tipo"               ,{ || aTicket[oLbx1:nAt,05] }   ,""                                  ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oLbx1:AddColumn( TcColumn():New("Documento"          ,{ || aTicket[oLbx1:nAt,10] }   ,""                                  ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oLbx1:AddColumn( TcColumn():New("Série"              ,{ || aTicket[oLbx1:nAt,09] }   ,"@!"                                ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oLbx1:AddColumn( TcColumn():New("Peso 1"             ,{ || aTicket[oLbx1:nAt,07] }   ,"@E 999,999,999.99"                 ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )
	oLbx1:AddColumn( TcColumn():New("Usuário"            ,{ || aTicket[oLbx1:nAt,08] }   ,""                                  ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oLbx1:AddColumn( TcColumn():New("Empresa"            ,{ || aTicket[oLbx1:nAt,11] }   ,"@!"                                ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oLbx1:AddColumn( TcColumn():New("Transportadora"     ,{ || aTicket[oLbx1:nAt,12] }   ,"@!"                                ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )

	oLbx1:SetArray( aTicket )
	oLbx1:bLDblClick := {|| aTicket[oLbx1:nAt][1] := !aTicket[oLbx1:nAt][1], oLbx1:DrawSelect() }

	oLbx1:GoTop()

	@ 122, 335 Button "Amarrar"    Size 28, 10 Action ( lConfirma := .T., lValido := fValPesagem(), IIf( lValido, oDlgAdiant:End(), lValido := .F.) )
	@ 122, 365 Button "Sair"       Size 28, 10 Action ( lConfirma := .F., oDlgAdiant:End() )

	oTMsgBar   := TMsgBar():New(oDlgAdiant, AllTrim(SM0->M0_NOME) + "/" + AllTrim(SM0->M0_FILIAL), .F.,.F.,.F.,.F., ,,oFontMsg,.F.)
	oTMsgItem1 := TMsgItem():New( oTMsgBar,"Documento: " + AllTrim( cNFiscal ) + " | Código Fornecedor: " + AllTrim( cA100For ), 500,, ,,.T., {||} )

ACTIVATE MSDIALOG oDlgAdiant CENTERED

If lConfirma .And. lValido
	For nLinha := 1 To Len( aPesagem )
		If aPesagem[nLinha][01]
			aSZZxSF1 := {}
			aAdd( aSZZxSF1, { aPesagem[nLinha][02], aPesagem[nLinha][19] })
		EndIf
	Next
	For nLinha := 1 To Len( aTicket )
		If aTicket[nLinha][01]
			aSZZxSF1 := {}
			aAdd( aSZZxSF1, { aTicket[nLinha][02], aTicket[nLinha][19] })
		EndIf
	Next
EndIf

RestArea( aArea )

Return

Static Function fValPesagem()

Local lRet := .F.
Local nLin := 0
Local nMar := 0

For nLin := 1 To Len( aPesagem )
	If aPesagem[nLin][01]
		lRet := .T.
		nMar++
	EndIf
Next

For nLin := 1 To Len( aTicket )
	If aTicket[nLin][01]
		lRet := .T.
		nMar++
	EndIf
Next

If !lRet
	ApMsgAlert( "Selecione uma pesagem para confirmar a Amarração", "Atenção" )
EndIf

If lRet .And. nMar > 1
	ApMsgAlert( "Não é possível duas cargas para uma nota fiscal, selecione somente um controle de pesagem!", "Atenção" )
	lRet := .T.
EndIf

Return lRet