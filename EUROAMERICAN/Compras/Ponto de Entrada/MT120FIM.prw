#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'Rwmake.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT120FIM ºAutor  ³Microsiga           º Data ³  08/31/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada executado após a restauração do filtro    º±±
±±º          ³ da FilBrowse depois de fechar a operação realizada no      º±±
±±º          ³ pedido de compras, é a ultima instrução da função          º±±
±±º          ³ A120Pedido                                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Euroamerican                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT120FIM()

Local aArea    := GetArea()
Local aAreaSC7 := SC7->( GetArea() )
Local aAreaSCR := SCR->( GetArea() )
Local nOpcao   := ParamIxb[1] // Opção Escolhida pelo usuario
Local nOpcA    := ParamIxb[3] // Indica se a ação foi Cancelada = 0  ou Confirmada = 1

Private lInc   := ((nOpcao == 3) .Or. lCop)
Private lAlt   := (nOpcao == 4)
Private cNumPC := ParamIxb[2] // Numero do Pedido de Compras
Private cQuery := ""
Private cTempo := ""

// ============================================================
//  Grupo Empresa - Ajuste realizado em 31.08.20 (CG)
// ============================================================

// cEmpAnt (Substituido por cFilAnt)

If nOpcA == 1
	// Verifica se empresa e filial controla processo de recebimentos...
	//If Left(cFilAnt,2) $ GetMv("MV_EQ_SFEM",,"02|08|") .And. Left(cFilAnt,2) $ GetMv("MV_EQ_FIWF",,"00|03|01|")
	If AllTrim( cEmpAnt ) $ GetMv("MV_EQ_SFEM",,"02|08|") .And. AllTrim( cFilAnt ) $ GetMv("MV_EQ_FIWF",,"00|03|01|")
		EQProcess()
	EndIf
EndIf

SCR->( RestArea( aAreaSCR ) )
SC7->( RestArea( aAreaSC7 ) )
Restarea( aArea )

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EQProcess ºAutor  ³Microsiga          º Data ³  08/31/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Euroamerican                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function EQProcess()

Local oProcess
Local cCodProc 	:= GetMv("MV_EQ_PRWF",, "190001") // Processo recebimento...
Local cDescr	:= "PROCESSO CONTROLE DE RECEBIMENTOS"

If lInc .And. Empty( SC7->C7_EUWFID )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtra inicio de processo											   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !u_EQVldIWF( .T., cNumPC )
		Return
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicia Instancia oProcess											   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oProcess := TWFProcess():New(cCodProc,cDescr)
	
	dbSelectArea("SC7")
	dbSetOrder(1)
	dbSeek( xFilial("SC7") + cNumPC )
	Do While !SC7->( Eof() ) .And. SC7->C7_NUM == cNumPC
		RecLock("SC7", .F.)
		SC7->C7_EUWFID := oProcess:fProcessID
		MsUnLock()
		
		SC7->( dbSkip() )
	EndDo
	
	dbSelectArea("SC7")
	dbSetOrder(1)
	dbSeek( xFilial("SC7") + cNumPC )
	
	If !lCop
		U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " Incluído",;
		"100001",;
		"PEDIDO DE COMPRAS INCLUIDO",;
		"1",;
		"Pedido de Compras Incluído" )
	Else
		U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " Incluído",;
		"100001",;
		"PEDIDO DE COMPRAS INCLUIDO " + IIf( SC7->C7_TIPO == 1, "[ UTILIZOU COPIA ]", ""),;
		"1",;
		"Pedido de Compras Incluído" )
	EndIf
	
	If AllTrim( SC7->C7_CONAPRO ) == "L" //.And. Empty( SC7->C7_APROV )
		U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " Aguardando Aprovação",;
		"100200",;
		"PEDIDO AGUARDANDO APROVACAO",;
		"2",;
		"Pedido de Compras Aguardando Aprovação" )
		
		U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " Aprovado",;
		"200001",;
		"PEDIDO APROVADO",;
		"2",;
		"Pedido de Compras Aprovado" )
		
		U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " Aguardando Chegada da Mercadoria",;
		"200200",;
		"PEDIDO AGUARDANDO CHEGADA",;
		"1",;
		"Pedido de Compras Aguardando Chegada" )
	EndIf
ElseIf lInc .And. !Empty( SC7->C7_EUWFID )
	If AllTrim( SC7->C7_CONAPRO ) == "L" //.And. Empty( SC7->C7_APROV )
		If Empty( SC7->C7_APROV )
			U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " Aguardando Aprovação",;
			"100200",;
			"PEDIDO AGUARDANDO APROVACAO",;
			"2",;
			"Pedido de Compras Aguardando Aprovação" )
		EndIf
		U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " Aprovado",;
		"200001",;
		"PEDIDO APROVADO",;
		"2",;
		"Pedido de Compras Aprovado" )
		U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " Aguardando Chegada da Mercadoria",;
		"200200",;
		"PEDIDO AGUARDANDO CHEGADA",;
		"1",;
		"Pedido de Compras Aguardando Chegada" )
	EndIf
ElseIf lAlt .And. !Empty( SC7->C7_EUWFID )
	If Empty( SC7->C7_APROV )
		U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " Alterado",;
		"100002",;
		"PEDIDO DE COMPRAS ALTERADO",;
		"1",;
		"Pedido de Compras Alterado" )
	EndIf
	If AllTrim( SC7->C7_CONAPRO ) == "L" //.And. Empty( SC7->C7_APROV )
		U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " Aguardando Aprovação",;
		"100200",;
		"PEDIDO AGUARDANDO APROVACAO",;
		"2",;
		"Pedido de Compras Aguardando Aprovação" )
		U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " Aprovado",;
		"200001",;
		"PEDIDO APROVADO",;
		"2",;
		"Pedido de Compras Aprovado" )
		
		U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " Aguardando Chegada da Mercadoria",;
		"200200",;
		"PEDIDO AGUARDANDO CHEGADA",;
		"1",;
		"Pedido de Compras Aguardando Chegada" )
	EndIf
ElseIf !lInc .And. !lAlt
	U_EQJustES( "P", "X", "E", cNumPC, "", "", AllTrim( Str( SC7->C7_TIPO ) ), SC7->C7_FORNECE, SC7->C7_LOJA, SC7->C7_EMISSAO, SC7->C7_EMISSAO )
	
	If !Empty( SC7->C7_EUWFID )
		U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " excluído",;
		"100901",;
		"PEDIDO DE COMPRAS EXCLUIDO",;
		"1",;
		"Pedido de Compras Excluído" )
	EndIf
EndIf

Return .T.
