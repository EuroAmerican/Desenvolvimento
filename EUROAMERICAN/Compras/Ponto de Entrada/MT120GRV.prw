#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'Rwmake.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT120GRV  ºAutor  ³Microsiga          º Data ³  08/31/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para validar pedido de compras            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Euroamerican                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT120GRV()

Local aArea     := GetArea()
Local aAreaSC7  := SC7->( GetArea() )
Local aAreaSCR  := SCR->( GetArea() )
Local lRetorno  := .T.

Private cNumPC  := ParamIxb[1] // Numero do Pedido de Compras
Private lInclui := ParamIxb[2]
Private lAltera := ParamIxb[3]
Private cQuery  := ""
Private cTempo  := ""

If lCop .And. !lInclui .And. !lAltera 
	lInclui := .T.
	lAltera := .F.
EndIf

// Se adicionar validação, deve ser incluída antes da inclusão do processo EQProcess
// Efetua validação a respeito de cadastro de tolerância no recebimento e, caso não exista cria...
lRetorno := fVldTole()

// Valida validade do certificado ISO 9000 do fornecedor // sjustado 18/09/2020  7:09
If lRetorno .And. (lInclui .Or. lAltera)
	dbSelectArea("SA2")
	dbSetOrder(1)
	If SA2->( dbSeek( xFilial("SA2") + cA120Forn + cA120Loj ) )
		If AllTrim( SA2->A2_EQ_ISO9 ) == "S"
			If SA2->A2_EQ_ISOV < dDataBase
				ApMsgAlert( "Fornecedor possui validade do certificado ISO 9000 vencida, pedido não pode ser gravado!", "Atenção")
				lRetorno := .F.
			ElseIf SA2->A2_EQ_ISOV >= dDataBase -30 .And. SA2->A2_EQ_ISOV <= dDataBase
				ApMsgInfo( "Certificado do fornecedor está para expirar!", "Aviso")
			EndIf
		EndIf
	EndIf
EndIf

// Verificar se pedido já foi aprovado antes de permitir a aprovação...
If lRetorno .And. lAltera
	lRetorno := fVldAlter()
EndIf

// ============================================================
//  Grupo Empresa - Ajuste realizado em 31.08.20 (CG)
// ============================================================

// cEmpAnt (Substituido por cFilAnt)

// Verifica se empresa e filial controla processo de recebimentos...

If lRetorno .And. (lInclui .Or. lAltera)
	//If Left(cFilAnt,2) $ GetMv("MV_EQ_SFEM",,"02|08|") .And. Right(cFilAnt,2) $ GetMv("MV_EQ_FIWF",,"00|03|01|")
	If AllTrim( cEmpAnt ) $ GetMv("MV_EQ_SFEM",,"02|08|") .And. AllTrim( cFilAnt ) $ GetMv("MV_EQ_FIWF",,"00|03|01|")
		If (lAltera .And. !Empty( cEUWFID )) .Or. lInclui
			EQProcess()
		EndIf
	EndIf
EndIf

SCR->( RestArea( aAreaSCR ) )
SC7->( RestArea( aAreaSC7 ) )
Restarea( aArea )

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT120GRV  ºAutor  ³Microsiga           º Data ³  08/31/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Euroamerican                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function EQProcess()

Local oProcess
Local cCodProc 			:= GetMv("MV_EQ_PRWF",, "190001") // Processo recebimento...
Local cDescr			:= "PROCESSO CONTROLE DE RECEBIMENTOS"
Local cAssunto  		:= "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " Incluído"
Local cCodStatus        := "100001"
Local cTexto            := "PEDIDO DE COMPRAS INCLUIDO"
Local cDescrFase        := "Inclusão Pedido de Compras"
Local cIdWF             := ""
Local lHTML             := .T.
Local cTitulo			:= "Processo Controle de Recebimentos de Materiais"
Local cHtmlModelo   	:= ""                
Local cUsuarioProtheus	:= cUserName
Local lPrimeiro         := .T.
Local lEnvia            := .F.
Local cMailNot          := ""
Local dDataAnt          := CTOD("  /  /  ")
Local cHoraAnt          := ""
Local cTempo            := ""
Local nPosItem          := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_ITEM'})
Local nPosProd          := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_PRODUTO'})
Local nPosDesc          := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_DESCRI'})
Local nPosEntr          := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_DATPRF'})
Local nPosUM            := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_UM'})
Local nPosQuant         := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_QUANT'})
Local nLinha            := 0
Local aWorkflow         := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtra inicio de processo											   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//If !(Left(cFilAnt,2) $ GetMv("MV_EQ_SFEM",,"02|08|") .And. nTipoPed == 1 .And. Alltrim( xFilial("SC7") ) $ Alltrim(SuperGetMV("MV_EQ_FIWF",.F.,"00|01|03|",)))
If !(AllTrim( cEmpAnt ) $ GetMv("MV_EQ_SFEM",,"02|08|") .And. nTipoPed == 1 .And. Alltrim( xFilial("SC7") ) $ Alltrim(SuperGetMV("MV_EQ_FIWF",.F.,"00|01|03|",)))
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Antes de iniciar instancia, verificar usuário do Protheus               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( cUsuarioProtheus )
	If AllTrim( Upper( FunName() ) ) == "RPC"
		cUsuarioProtheus := "AUTO"
	ElseIf Empty( cUsuarioProtheus )
		cUsuarioProtheus := "Administrador"
	EndIf
Endif

If lInclui
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicia Instancia oProcess											   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAssunto   := "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " Incluído"
	cCodStatus := "100001"
	cTexto     := "PEDIDO DE COMPRAS INCLUIDO"
	cDescrFase := "Inclusão Pedido de Compras"

	oProcess   := TWFProcess():New(cCodProc,cDescr)
	cIdWF      := oProcess:fProcessID

	cEUWFID := cIdWF
Else
	cIdWF      := cEUWFID
	oProcess   := TWFProcess():New(cCodProc,cDescr,cEUWFID)
	cAssunto   := "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " Alterado"
	cCodStatus := "100002"
	cTexto     := "PEDIDO DE COMPRAS ALTERADO"
	cDescrFase := "Alteração Pedido de Compras"
EndIf

dbSelectArea("Z17")
dbSetOrder(1)
dbSeek( xFilial("Z17") + cCodProc + cCodStatus )

Do While !Z17->(Eof()) .And. Z17->Z17_FILIAL == xFilial("Z17") .And. Z17->Z17_PROC == cCodProc .And. Z17->Z17_STATUS == cCodStatus
    If Z17->Z17_NOTIF == '1'
		lEnvia := .T.
	EndIf

	Z17->(dbSkip())
EndDo

If !lEnvia
	lHTML := .F.
EndIf

If lHTML
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Iniciando Etapa 100200 - PEDIDO AGUARDANDO LIBERACAO					   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Left(cFilAnt,2) == "02"
		cHtmlModelo	:= "\workflow\HTML\wfrecebimentoeuro.html"
	Else
		cHtmlModelo	:= "\workflow\HTML\wfrecebimentoqualy.html"
	EndIf
	oProcess:NewTask(cTitulo, cHtmlModelo)
	oProcess:Track(cCodStatus, cTexto, cUsuarioProtheus) // Rastreabilidade
	oHtml:= oProcess:oHtml

	oHtml:valbyname( "cDescrFase"	, cDescrFase			)
	oHtml:valbyname( "cEmpresa"		, SM0->M0_CODIGO 		)
	oHtml:valbyname( "cCodFil"  	, SM0->M0_CODFIL 		)
	oHtml:valbyname( "cNomeFil" 	, SM0->M0_FILIAL 		)
	oHtml:valbyname( "dDtEmis" 		, DTOC(dA120Emis)		)
	oHtml:valbyname( "cNumPed" 		, cA120Num				)
	oHtml:valbyname( "cComp" 		, cUserName				)
	oHtml:valbyname( "cCodFor" 		, cA120Forn				)
	oHtml:valbyname( "cLoja"		, cA120Loj				)
	oHtml:valbyname( "cNomeFor"		, Posicione("SA2",1,xFilial("SA2")+cA120Forn+cA120Loj,'A2_NREDUZ'))

	aDados := u_EQRetWFR(xFilial("SC7"),cCodProc,"100001",cIdWF)
	oHtml:valbyname( "cStsInc"	, "approve.png"			)
	oHtml:valbyname( "cUsrInc"	, aDados[1]				)
	oHtml:valbyname( "dDtInc"	, aDados[2]				)
	oHtml:valbyname( "cHrInc"	, aDados[3]				)

	oHtml:valbyname( "cStsLib"	, "waiting.png"			)
	oHtml:valbyname( "cUsrLib"	, ""					)
	oHtml:valbyname( "dDtLib"	, ""					)
	oHtml:valbyname( "cHrLib"	, ""					)

	oHtml:valbyname( "cStsPor"	, "stop.png"			)
	oHtml:valbyname( "cUsrPor"	, ""					)
	oHtml:valbyname( "dDtPor"	, ""					)
	oHtml:valbyname( "cHrPor"	, ""					)

	oHtml:valbyname( "cStsNF"	, "stop.png"			)
	oHtml:valbyname( "cUsrNF"	, ""					)
	oHtml:valbyname( "dDtNF"	, ""					)
	oHtml:valbyname( "cHrNF"	, ""					)

	oHtml:valbyname( "cStsCon"	, "stop.png"			)
	oHtml:valbyname( "cUsrCon"	, ""					)
	oHtml:valbyname( "dDtCon"	, ""					)
	oHtml:valbyname( "cHrCon"	, ""					)

	oHtml:valbyname( "cStsCam"	, "stop.png"			)
	oHtml:valbyname( "cUsrCam"	, ""					)
	oHtml:valbyname( "dDtCam"	, ""					)
	oHtml:valbyname( "cHrCam"	, ""					)

	oHtml:valbyname( "cCodUsr"	, RetCodUsr()			)
	oHtml:valbyname( "cIDWF"	, cIdWF					)
	oHtml:valbyname( "cFuncao"	, FunName()				)

	For nLinha := 1 To Len( aCols )
		aAdd( (oHtml:valbyname( "it.cItem" 		)), aCols[nLinha][nPosItem]   				) 
		aAdd( (oHtml:valbyname( "it.cCodProd"	)), aCols[nLinha][nPosProd]					) 
		aAdd( (oHtml:valbyname( "it.cDescrProd"	)), aCols[nLinha][nPosDesc]					)
		aAdd( (oHtml:valbyname( "it.dDtEntr"	)), DTOC(aCols[nLinha][nPosEntr])			)
		aAdd( (oHtml:valbyname( "it.cUM"		)), aCols[nLinha][nPosUM]	    			)
		aAdd( (oHtml:valbyname( "it.nQuant"   	)), Alltrim( Transform( aCols[nLinha][nPosQuant], '@E 99,999,999.999999') ) )
	Next

	cQuery := "SELECT WF3_DATA, WF3_HORA, WF3_USU, WF3_DESC, WF3_STATUS " + CRLF
	cQuery += "FROM " + RetSqlName("WF3") + " AS WF3 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE WF3_FILIAL = '" + xFilial("WF3") + "' " + CRLF
	cQuery += "AND WF3_PROC = '" + AllTrim( GetMv("MV_EQ_PRWF",, "190001") ) + "' " + CRLF
	cQuery += "AND WF3_ID LIKE '" + AllTrim( cIdWF ) + "%' " + CRLF
	cQuery += "AND WF3_USU <> '' " + CRLF
	cQuery += "AND WF3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY WF3_DATA + WF3_HORA, R_E_C_N_O_ " + CRLF // DESC

	TCQuery cQuery New Alias "TMPWF3"
	dbSelectArea("TMPWF3")
	dbGoTop()

	lPrimeiro := .T.
	cTempo    := "0000 00:00:00"

	Do While !TMPWF3->( Eof() )
		If Len( aWorkflow ) > 0
			cTempo := DWElapTime( aWorkflow[Len( aWorkflow )][01], aWorkflow[Len( aWorkflow )][02], STOD(TMPWF3->WF3_DATA), TMPWF3->WF3_HORA )
		EndIf

		aAdd( aWorkflow, { STOD( TMPWF3->WF3_DATA ), TMPWF3->WF3_HORA, TMPWF3->WF3_USU, TMPWF3->WF3_DESC, cTempo } )

		TMPWF3->( dbSkip() )		
	EndDo

	TMPWF3->( dbCloseArea() )

	aSort( aWorkflow,,, {|x,y| DTOS( x[1] ) + x[2] > DTOS( y[1] ) + y[2] } )

	For nLinha := 1 To Len( aWorkflow )
		aAdd( (oHtml:valbyname( "itWF.dWFData" 		)), DTOC( aWorkflow[nLinha][01] )   				)
		aAdd( (oHtml:valbyname( "itWF.cWFHora"		)), aWorkflow[nLinha][02]							)
		aAdd( (oHtml:valbyname( "itWF.cWFUsuario"	)), aWorkflow[nLinha][03]							)
		aAdd( (oHtml:valbyname( "itWF.cWFProc"		)), aWorkflow[nLinha][04]							)
		aAdd( (oHtml:valbyname( "itWF.cWFTempo"		)), aWorkflow[nLinha][05]							)
    Next

	If Len( aWorkflow ) == 0
		aAdd( (oHtml:valbyname( "itWF.dWFData" 		)), ""								   				)
		aAdd( (oHtml:valbyname( "itWF.cWFHora"		)), ""												)
		aAdd( (oHtml:valbyname( "itWF.cWFUsuario"	)), ""												)
		aAdd( (oHtml:valbyname( "itWF.cWFProc"		)), ""												)
		aAdd( (oHtml:valbyname( "itWF.cWFTempo"		)), ""												)
	EndIf

	cMailNot          := U_EQGetRsp(cCodProc, cCodStatus, "")
	oProcess:cTo      := cMailNot
	oProcess:cCC      := ""
	oProcess:cSubject := cAssunto
	oProcess:Start()
	oProcess:Finish()
	WfSendMail()
Else
	oProcess := TWFProcess():New(cCodProc, cDescr, cIdWF)
	oProcess:NewTask(cTitulo, cHtmlModelo)
	oProcess:Track(cCodStatus, cTexto, cUsuarioProtheus) // Rastreabilidade
	oProcess:Finish()
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fVldTole ºAutor  ³Microsiga           º Data ³  08/31/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Euroamerican                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fVldTole()

Local lRetorno    := .T.
Local lTolerancia := .T.
Local nPosProd    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_PRODUTO'})
Local cCodToler   := ""
Local nTolQuant   := GetMV( "MV_EQ_TPQT",, 2) // Tolerância Quantidade Padrão Euroamerican
Local nTolPreco   := GetMV( "MV_EQ_TPPR",, 5) // Tolerância Preço Padrão Euroamerican
Local nTolDias    := GetMV( "MV_EQ_TPAT",,99) // Tolerância Dias Atrasos Padrão Euroamerican

// Verifica se há tolerância para o fornecedore e produto; caso não haja, criar...
For nLinha := 1 To Len( aCols )
	// -- Executar a funcao MaAvalToler passando o 12o parametro como .T., permite saber se ha tolerancia cadastrada para o Fornecedor/Produto sem
	// -- avaliar o bloqueio. O bloqueio sera analisado posteriormente. 
	lTolerancia := MaAvalToler( cA120Forn, cA120Loj, aCols[nLinha][nPosProd],,,,,,,,,.T.)[1]
	If !lTolerancia
		dbSelectArea("AIC")
		dbSetOrder(2)
		If !AIC->( dbSeek( xFilial("AIC") + cA120Forn + cA120Loj ) )
			ApMsgInfo( "Não há tolerância de recebimento cadastrado para fornecedor/produto/grupo, será criado automaticamente uma tolerância padrão para o fornecedor para posterior avaliação!", "Atenção")

			cCodToler := GetSXENum("AIC","AIC_CODIGO")

			TCQuery "SELECT MAX(AIC_CODIGO) AS CODIGO FROM " + RetSqlName("AIC") + " WHERE D_E_L_E_T_ = ' '" New Alias "MAXAIC"
			dbSelectArea("MAXAIC")
			dbGoTop()
			
			If !MAXAIC->( Eof() )
				cCodToler := Soma1( MAXAIC->CODIGO )
			EndIf
			
			MAXAIC->( dbCloseArea() )

			RecLock("AIC", .T.)
				AIC->AIC_FILIAL := xFilial("AIC")
				AIC->AIC_CODIGO := cCodToler
				AIC->AIC_FORNEC := cA120Forn
				AIC->AIC_LOJA   := cA120Loj
				AIC->AIC_PQTDE  := nTolQuant
				AIC->AIC_PPRECO := nTolPreco
				AIC->AIC_TOLENT := nTolDias
			MsUnLock()

			AIC->( ConfirmSX8() )
		EndIf
		Exit
	EndIf
Next

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fVldAlter  ºAutor  ³Microsiga         º Data ³  08/31/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Euroamerican                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fVldAlter()

Local lRet := .T.

dbSelectArea("SC7")
dbSetOrder(1)
If SC7->( dbSeek( xFilial("SC7") + cNumPC ) )
	If AllTrim( SC7->C7_CONAPRO ) == "L"
		cQuery := "SELECT COUNT(*) AS CONTA "
		cQuery += "FROM " + RetSqlName("SCR") + " AS SCR WITH (NOLOCK) "
		cQuery += "WHERE CR_FILIAL = '" + xFilial("SC7") + "' "
		cQuery += "AND CR_TIPO = 'PC' "
		cQuery += "AND CR_NUM = '" + SC7->C7_NUM + "' "
		cQuery += "AND CR_STATUS <> '03' "
		cQuery += "AND SCR.D_E_L_E_T_ = ' ' "

		TCQuery cQuery New Alias "QTDAPV"
		dbSelectArea("QTDAPV")
		dbGoTop()

		If !QTDAPV->( Eof() )
			If QTDAPV->CONTA > 0
				//ApMsgAlert( "Pedido de compras " + SC7->C7_NUM + " não pode ser alterado pois já passou por aprovação" + CRLF + "Solicitar ao(s) aprovador(es) o estorno da aprovação.", "Atenção")
				//lRet := .F.
			EndIf
		EndIf

		QTDAPV->( dbCloseArea() )
	EndIf
EndIf

Return lRet
