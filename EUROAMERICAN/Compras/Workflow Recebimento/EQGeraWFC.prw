#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

/*/{Protheus.doc} EQGERAWFC - Rotina padrão para geração de WF do controle
de recebimentos/compras
@Autor  Microsiga
@since 08/31/2020
@History Alterado em 30/11/2021 para tratamento da release 12.1.33
@Autor  Fabio carneiro dos Santos 
/*/

User Function EQGeraWFC( _cAssunto, _cStatus, _cTxtSts, _cHTML, _cDescrFase )

Local oProcess
Local aArea             := GetArea()
Local aAreaSC7          := SC7->( GetArea() )
Local cCodProc 			:= GetMv("MV_EQ_PRWF",, "190001") // Processo recebimento...
Local cAssunto  		:= _cAssunto
Local cStatus           := _cStatus
Local cTxtSts           := _cTxtSts
Local cDescrFase        := _cDescrFase
Local lHTML             := ( AllTrim( _cHTML ) == "1" )
Local cNumPC            := SC7->C7_NUM
Local cDescr			:= "PROCESSO CONTROLE DE RECEBIMENTOS"
Local cTitulo			:= "Processo Controle de Recebimentos de Materiais"
Local cHtmlModelo   	:= ""                
Local cUsuarioProtheus	:= cUserName
Local lPrimeiro         := .T.
Local lEnvia            := .F.
Local cHtmlModelo       := ""
Local cMailNot          := ""
Local dDataAnt          := CTOD("  /  /  ")
Local cHoraAnt          := ""
Local cTempo            := ""
Local aWorkflow         := {}
Local nLinha            := 0

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

// Caso não haja nenhum usuário para receber notificação e habilitado para enviar e-mail, somente criar processo.
If lHTML
	dbSelectArea("Z17")
	dbSetOrder(1)
	dbSeek( xFilial("Z17") + cCodProc + cStatus )

	Do While !Z17->(Eof()) .And. Z17->Z17_FILIAL == xFilial("Z17") .And. Z17->Z17_PROC == cCodProc .And. Z17->Z17_STATUS == cStatus
	    If Z17->Z17_NOTIF == '1'
			lEnvia := .T.
		EndIf
	
		Z17->(dbSkip())
	EndDo

	If !lEnvia
		lHTML := .F.
	EndIf
EndIf

If lHTML
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Iniciando Etapa 100200 - PEDIDO AGUARDANDO LIBERACAO					   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTexto 		:= cTxtSts
	cCodStatus 	:= cStatus // Código do cadastro de status de processo.

	If Left(cFilAnt,2) == "02"
		cHtmlModelo	:= "\workflow\HTML\wfrecebimentoeuro.html"
	Else
		cHtmlModelo	:= "\workflow\HTML\wfrecebimentoqualy.html"
	EndIf

	oProcess := TWFProcess():New(cCodProc, cDescr, SC7->C7_EUWFID)
	oProcess:NewTask(cTitulo, cHtmlModelo)
	oProcess:Track(cCodStatus, cTexto, cUsuarioProtheus) // Rastreabilidade
	oHtml:= oProcess:oHtml

	oHtml:valbyname( "cDescrFase"	, cDescrFase			)
	oHtml:valbyname( "cEmpresa"		, SM0->M0_CODIGO 		)
	oHtml:valbyname( "cCodFil"  	, SM0->M0_CODFIL 		)
	oHtml:valbyname( "cNomeFil" 	, SM0->M0_FILIAL 		)
	oHtml:valbyname( "dDtEmis" 		, DTOC(SC7->C7_EMISSAO)	)
	oHtml:valbyname( "cNumPed" 		, SC7->C7_NUM			)
	oHtml:valbyname( "cComp" 		, cUserName				)
	oHtml:valbyname( "cCodFor" 		, SC7->C7_FORNECE		)
	oHtml:valbyname( "cLoja"		, SC7->C7_LOJA			)
	oHtml:valbyname( "cNomeFor"		, Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,'A2_NREDUZ'))

	aDados := u_EQRetWFR(xFilial("SC7"),cCodProc,"100001",SC7->C7_EUWFID)
	oHtml:valbyname( "cStsInc"	, "approve.png"			)
	oHtml:valbyname( "cUsrInc"	, aDados[1]				)
	oHtml:valbyname( "dDtInc"	, aDados[2]				)
	oHtml:valbyname( "cHrInc"	, aDados[3]				)

	If cStatus >= "200001"
		aDados := u_EQRetWFR(xFilial("SC7"),cCodProc,"200001",SC7->C7_EUWFID)
		oHtml:valbyname( "cStsLib"	, "approve.png"			)
		oHtml:valbyname( "cUsrLib"	, aDados[1]				)
		oHtml:valbyname( "dDtLib"	, aDados[2]				)
		oHtml:valbyname( "cHrLib"	, aDados[3]				)
	Else
		oHtml:valbyname( "cStsLib"	, "waiting.png"			)
		oHtml:valbyname( "cUsrLib"	, ""					)
		oHtml:valbyname( "dDtLib"	, ""					)
		oHtml:valbyname( "cHrLib"	, ""					)
	EndIf

	If cStatus >= "300001"
		aDados := u_EQRetWFR(xFilial("SC7"),cCodProc,"300001",SC7->C7_EUWFID)
		oHtml:valbyname( "cStsPor"	, "approve.png"			)
		oHtml:valbyname( "cUsrPor"	, aDados[1]				)
		oHtml:valbyname( "dDtPor"	, aDados[2]				)
		oHtml:valbyname( "cHrPor"	, aDados[3]				)
	Else
		If cStatus >= "200001"
			oHtml:valbyname( "cStsPor"	, "waiting.png"			)
		Else
			oHtml:valbyname( "cStsPor"	, "stop.png"			)
		EndIf
		oHtml:valbyname( "cUsrPor"	, ""					)
		oHtml:valbyname( "dDtPor"	, ""					)
		oHtml:valbyname( "cHrPor"	, ""					)
	EndIf

	If cStatus >= "400001"
		aDados := u_EQRetWFR(xFilial("SC7"),cCodProc,"400001",SC7->C7_EUWFID)
		oHtml:valbyname( "cStsNF"	, "approve.png"			)
		oHtml:valbyname( "cUsrNF"	, aDados[1]				)
		oHtml:valbyname( "dDtNF"	, aDados[2]				)
		oHtml:valbyname( "cHrNF"	, aDados[3]				)
	Else
		If cStatus >= "300001"
			oHtml:valbyname( "cStsNF"	, "waiting.png"			)
		Else
			oHtml:valbyname( "cStsNF"	, "stop.png"			)
		EndIf
		oHtml:valbyname( "cUsrNF"	, ""					)
		oHtml:valbyname( "dDtNF"	, ""					)
		oHtml:valbyname( "cHrNF"	, ""					)
	EndIf

	If cStatus >= "400200"
		aDados := u_EQRetWFR(xFilial("SC7"),cCodProc,"400200",SC7->C7_EUWFID)
		oHtml:valbyname( "cStsCon"	, "approve.png"			)
		oHtml:valbyname( "cUsrCon"	, aDados[1]				)
		oHtml:valbyname( "dDtCon"	, aDados[2]				)
		oHtml:valbyname( "cHrCon"	, aDados[3]				)
	Else
		If cStatus >= "400001"
			oHtml:valbyname( "cStsCon"	, "waiting.png"			)
		Else
			oHtml:valbyname( "cStsCon"	, "stop.png"			)
		EndIf
		oHtml:valbyname( "cUsrCon"	, ""					)
		oHtml:valbyname( "dDtCon"	, ""					)
		oHtml:valbyname( "cHrCon"	, ""					)
	EndIf

	If cStatus >= "500001"
		aDados := u_EQRetWFR(xFilial("SC7"),cCodProc,"500001",SC7->C7_EUWFID)
		oHtml:valbyname( "cStsCam"	, "approve.png"			)
		oHtml:valbyname( "cUsrCam"	, aDados[1]				)
		oHtml:valbyname( "dDtCam"	, aDados[2]				)
		oHtml:valbyname( "cHrCam"	, aDados[3]				)
	Else
		If cStatus >= "400200"
			oHtml:valbyname( "cStsCam"	, "waiting.png"			)
		Else
			oHtml:valbyname( "cStsCam"	, "stop.png"			)
		EndIf
		oHtml:valbyname( "cUsrCam"	, ""					)
		oHtml:valbyname( "dDtCam"	, ""					)
		oHtml:valbyname( "cHrCam"	, ""					)
	EndIf

	oHtml:valbyname( "cCodUsr"	, RetCodUsr()			)
	oHtml:valbyname( "cIDWF"	, SC7->C7_EUWFID		)
	oHtml:valbyname( "cFuncao"	, FunName()				)

    dbSelectArea("SC7")
    dbSetOrder(1)
    dbSeek( xFilial("SC7") + cNumPC )
    Do While !SC7->( Eof() ) .And. SC7->C7_NUM == cNumPC
		aAdd( (oHtml:valbyname( "it.cItem" 		)), SC7->C7_ITEM   				) 
		aAdd( (oHtml:valbyname( "it.cCodProd"	)), SC7->C7_PRODUTO				) 
		aAdd( (oHtml:valbyname( "it.cDescrProd"	)), SC7->C7_DESCRI				)
		aAdd( (oHtml:valbyname( "it.dDtEntr"	)), DTOC(SC7->C7_DATPRF)		)
		aAdd( (oHtml:valbyname( "it.cUM"		)), SC7->C7_UM	    			)
		aAdd( (oHtml:valbyname( "it.nQuant"   	)), Alltrim( Transform( SC7->C7_QUANT, '@E 99,999,999.999999') ) )

    	SC7->( dbSkip() )
    EndDo

	SC7->( RestArea( aAreaSC7 ) )

	cQuery := "SELECT WF3_DATA, WF3_HORA, WF3_USU, WF3_DESC, WF3_STATUS " + CRLF
	cQuery += "FROM " + RetSqlName("WF3") + " AS WF3 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE WF3_FILIAL = '" + xFilial("WF3") + "' " + CRLF
	cQuery += "AND WF3_PROC = '" + AllTrim( GetMv("MV_EQ_PRWF",, "190001") ) + "' " + CRLF
	cQuery += "AND WF3_ID LIKE '" + AllTrim( SC7->C7_EUWFID ) + "%' " + CRLF
	cQuery += "AND WF3_USU <> '' " + CRLF
	cQuery += "AND WF3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY WF3_DATA + WF3_HORA, R_E_C_N_O_ " + CRLF // DESC

	TCQuery cQuery New Alias "TMPWF3"
	//dbSelectArea("TMPWF3")
	//dbGoTop()

	lPrimeiro := .T.
	cTempo    := "0000 00:00:00"

	Do While !TMPWF3->( Eof() )
		If Len( aWorkflow ) > 0
			cTempo := DWElapTime( aWorkflow[Len( aWorkflow )][01], aWorkflow[Len( aWorkflow )][02], STOD(TMPWF3->WF3_DATA), TMPWF3->WF3_HORA )
		EndIf

		aAdd( aWorkflow, { STOD(TMPWF3->WF3_DATA), TMPWF3->WF3_HORA, TMPWF3->WF3_USU, TMPWF3->WF3_DESC, cTempo } )

		TMPWF3->( dbSkip() )		
	EndDo

	TMPWF3->( dbCloseArea() )

	aSort( aWorkflow,,, {|x,y| DTOS( x[1] ) + x[2] > DTOS( y[1] ) + y[2] } )

	For nLinha := 1 To Len( aWorkflow )
		If nLinha < 20
			aAdd( (oHtml:valbyname( "itWF.dWFData" 		)), DTOC( aWorkflow[nLinha][01] )   				)
			aAdd( (oHtml:valbyname( "itWF.cWFHora"		)), aWorkflow[nLinha][02]							)
			aAdd( (oHtml:valbyname( "itWF.cWFUsuario"	)), aWorkflow[nLinha][03]							)
			aAdd( (oHtml:valbyname( "itWF.cWFProc"		)), aWorkflow[nLinha][04]							)
			aAdd( (oHtml:valbyname( "itWF.cWFTempo"		)), aWorkflow[nLinha][05]							)
		EndIf
    Next

	If Len( aWorkflow ) == 0
		aAdd( (oHtml:valbyname( "itWF.dWFData" 		)), ""								   				)
		aAdd( (oHtml:valbyname( "itWF.cWFHora"		)), ""												)
		aAdd( (oHtml:valbyname( "itWF.cWFUsuario"	)), ""												)
		aAdd( (oHtml:valbyname( "itWF.cWFProc"		)), ""												)
		aAdd( (oHtml:valbyname( "itWF.cWFTempo"		)), ""												)
	EndIf

	cMailNot          := U_EQGetRsp(cCodProc, cCodStatus, "")
	Sleep(1000)
	oProcess:cTo      := cMailNot
	oProcess:cCC      := ""
	oProcess:cSubject := cAssunto
	oProcess:Start()
	oProcess:Finish()
	WfSendMail()
Else
	cTexto 		:= cTxtSts
	cCodStatus 	:= cStatus // Código do cadastro de status de processo.
	oProcess := TWFProcess():New(cCodProc, cDescr, SC7->C7_EUWFID)
	oProcess:NewTask(cTitulo, cHtmlModelo)
	oProcess:Track(cCodStatus, cTexto, cUsuarioProtheus) // Rastreabilidade
	oProcess:Finish()
EndIf

RestArea( aArea )

Return

/*
Processos:
	100001 - Inclusão Pedido de Compras
	100002 - Alteração Pedido de Compras
	100200 - Pedido Aguardando Aprovação
	100205 - Transferência Alçada para Nível Superior
	100290 - Alçada Excluída
	100296 - Bloqueio de Alçada
	100299 - Aprovação Rejeitada
	100901 - Exclusão Pedido de Compras
	200001 - Pedido Aprovado
	200050 - Fornecedor Alterado no Pedido Após Aprovação
	200200 - Aguardando Chegada Portaria
	200901 - Estorno Aprovação de Pedido
	300001 - Chegada na Portaria
	300200 - Pesagem Recebimento
	300290 - Pesagem Estornada
	300901 - Recebimento Recusado
	400001 - Entrada Nota Fiscal
	400010 - Bloqueio Nota Fiscal por Tolerância no Recebimento
	400011 - Aguardando Aprovação Nota Fiscal
	400019 - Aprovação Nota Fiscal Rejeitada
	400020 - Aprovação da Nota Fiscal de Entrada
	400025 - Aguardando Classificação da Nota Fiscal
	400030 - Classificação da Nota Fiscal
	400050 - Ticket Etiqueta Conferência Emitida
	400051 - Aguardando Conferência Física
	400200 - Conferência Física
	400250 - Aguardando Liberação Caminhão
	400290 - Conferência Estornada
	400901 - Exclusão Nota Fiscal
	500001 - Liberação Caminhão
	500290 - Eliminação de Resíduos
	500901 - Liberação Caminhão Estornada
*/
