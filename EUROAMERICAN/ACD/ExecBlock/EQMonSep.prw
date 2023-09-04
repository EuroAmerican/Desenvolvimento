#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "FwBrowse.ch"
#Include "TopConn.ch"
#Include "FwMvcDef.ch"
#Include "ParmType.ch"
#Include 'FwCalendarWidget.ch'

/*
Fabio 25/05/2020: Tela para monitoramento da separação de ordem de produção para Fracionamentos...
*/

User Function EQMonSep()

Local aArea         := GetArea()

Private lRetorno    := .T.
Private lPodeSair   := .T. // Se estiver em processo de atualização de tela não permite finalizar o objeto oDlg:End()
Private lSair       := .F.
Private cTitulo	    := "Monitor de Separação de Ordens de Produções | Operador Fracionamentos"
Private cCadastro   := cTitulo
Private cQryMon     := ""
Private cQryOP      := ""
Private cQuery      := ""
Private oFont       := TFont():New( "Courier New",,14,,.T.,,,,,.F. )
Private aStat       := { "0 = Pendente Separação" , "1 = Separando" }
Private aOS         := {}
Private aAnterior   := {} // Registra anterior para não precisar gerar refresh do objeto a todo momento...
Private nLinha      := 1

aAdd( aOS, {"", ""})
aAdd( aOS, {"", ""})
aAdd( aOS, {"", ""})
aAdd( aAnterior, {"", ""})
aAdd( aAnterior, {"", ""})
aAdd( aAnterior, {"", ""})

// Query default para monitoramento da ordem de separação (somente as OSs que iniciaram a separação)...
cQryMon := "SELECT CB8_FILIAL, CB7_ORDSEP, CB7_OP, CB7_STATUS, CB7_STATPA, CB7_DTINIS, CB7_HRINIS, CB8_ITEM, CB8_OCOSEP, CB8_PROD, CB8_LOCAL, CB8_LOTECT, CB8_LCALIZ, CB8_QTDORI, CB8_SALDOS, CB8_NUMLOT, CB8_NUMSER " + CRLF
cQryMon += "FROM " + RetSqlName("CB7") + " AS CB7 " + CRLF
cQryMon += "INNER JOIN " + RetSqlName("CB8") + " AS CB8 ON CB8_FILIAL = CB7_FILIAL " + CRLF
cQryMon += "  AND CB8_ORDSEP = CB7_ORDSEP " + CRLF
cQryMon += "  AND CB8.D_E_L_E_T_ = ' ' " + CRLF
cQryMon += "WHERE CB7_FILIAL = '" + xFilial("CB7") + "' " + CRLF
cQryMon += "AND CB7_DTEMIS >= '20200101' " + CRLF
cQryMon += "AND CB7_STATUS = '1' " + CRLF
cQryMon += "AND CB7_ORIGEM = '3' " + CRLF
cQryMon += "AND EXISTS (SELECT C2_FILIAL FROM " + RetSqlName("SC2") + " WHERE C2_FILIAL = CB7_FILIAL AND C2_NUM + C2_ITEM + C2_SEQUEN = CB7_OP AND C2_QUANT > (C2_QUJE + C2_PERDA) AND D_E_L_E_T_ = ' ') " + CRLF
cQryMon += "AND CB7.D_E_L_E_T_ = ' ' " + CRLF
cQryMon += "ORDER BY CB8_FILIAL, CB7_ORDSEP, CB8_LOCAL, CB8_LCALIZ, CB8_PROD, CB8_LOTECT, CB8_NUMLOT, CB8_NUMSER, CB8_ITEM "

// Query default para ordem de produção aguardando início da separação (somente as OSs que não iniciaram a separação)...
cQryOP := "SELECT RTRIM( LTRIM( CB7_OP ) ) AS CB7_OP " + CRLF
cQryOP += "FROM " + RetSqlName("CB7") + " AS CB7 " + CRLF
cQryOP += "WHERE CB7_FILIAL = '" + xFilial("CB7") + "' " + CRLF
cQryOP += "AND CB7_DTEMIS >= '20200101' " + CRLF
cQryOP += "AND CB7_STATUS = '0' " + CRLF
cQryOP += "AND CB7_ORIGEM = '3' " + CRLF
cQryOP += "AND NOT EXISTS (SELECT CB7_FILIAL FROM " + RetSqlName("CB7") + " WHERE CB7_FILIAL = '" + xFilial("CB7") + "' AND CB7_OP = CB7.CB7_OP AND CB7_STATUS <> '0' AND D_E_L_E_T_ = ' ') " + CRLF
cQryOP += "AND EXISTS (SELECT C2_FILIAL FROM " + RetSqlName("SC2") + " WHERE C2_FILIAL = CB7_FILIAL AND C2_NUM + C2_ITEM + C2_SEQUEN = CB7_OP AND C2_QUANT > (C2_QUJE + C2_PERDA) AND D_E_L_E_T_ = ' ') " + CRLF
cQryOP += "AND CB7.D_E_L_E_T_ = ' ' " + CRLF
cQryOP += "GROUP BY CB7_OP " + CRLF
cQryOP += "ORDER BY CB7_OP " + CRLF

FwMsgRun( ,{ || Monitor() }, , 'Selecionando Registros, Por favor aguarde' )

RestArea( aArea )

Return Nil

Static Function Monitor()

Local oFontLeg  := TFont():New( "Verdana",,012,,.T.,,,,,.F.,.F. )
Local oFontL    := TFont():New( "Verdana",,008,,.T.,,,,,.F.,.F. )
Local aSize     := MsAdvSize( .F. )
Local lAutoRef  := .F.
Local lAutoNFe  := .F. 
Local oTimeRef  := Nil
Local oDlg      := Nil
Local aPesqIdx  := {}
Local aPesqOrd  := {}
Local aSeek     := {}
Local nI        := 0

cQuery := "SELECT TOP 3 CB7_ORDSEP, CB7_OP " + CRLF
cQuery += "FROM " + RetSqlName("CB7") + " AS CB7 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("CB8") + " AS CB8 WITH (NOLOCK) ON CB8_FILIAL = CB7_FILIAL " + CRLF
cQuery += "  AND CB8_ORDSEP = CB7_ORDSEP " + CRLF
cQuery += "  AND CB8.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE CB7_FILIAL = '" + xFilial("CB7") + "' " + CRLF
cQuery += "AND CB7_DTEMIS >= '20200101' " + CRLF
cQuery += "AND CB7_STATUS = '1' " + CRLF
cQuery += "AND CB7_ORIGEM = '3' " + CRLF
cQuery += "AND EXISTS (SELECT C2_FILIAL FROM " + RetSqlName("SC2") + " WHERE C2_FILIAL = CB7_FILIAL AND C2_NUM + C2_ITEM + C2_SEQUEN = CB7_OP AND C2_QUANT > (C2_QUJE + C2_PERDA) AND D_E_L_E_T_ = ' ') " + CRLF
cQuery += "AND CB7.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "GROUP BY CB7_ORDSEP, CB7_OP " + CRLF
cQuery += "ORDER BY CB7_ORDSEP " + CRLF

TCQuery cQuery New Alias "TMPOS"
dbSelectArea("TMPOS")
dbGoTop()

Do While !TMPOS->( Eof() )
	aOS[nLinha][01]       := TMPOS->CB7_ORDSEP
	aOS[nLinha][02]       := TMPOS->CB7_OP
	aAnterior[nLinha][01] := TMPOS->CB7_ORDSEP
	aAnterior[nLinha][02] := TMPOS->CB7_OP
	nLinha++

	TMPOS->( dbSkip() )
EndDo

TMPOS->( dbCloseArea() )

DEFINE MSDIALOG oDlg TITLE cTitulo FROM aSize[7],aSize[1] TO aSize[6],aSize[5] OF oMainWnd STYLE nOR( WS_VISIBLE,WS_POPUP ) PIXEL

	oDlg:lEscClose := .F.
	oFont := TFont():New('Courier new',,-10,.T.)

	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlg, .F. )

	oFWLayer:AddCollumn( "Col01", 12, .T. )
	oFWLayer:AddCollumn( "Col02", 44, .T. )
	oFWLayer:AddCollumn( "Col03", 44, .T. )

	oFWLayer:AddWindow( "Col01","Win01"	, "Açoes"                     ,025, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oFWLayer:AddWindow( "Col01","Win06"	, "Legenda"                   ,025, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oFWLayer:AddWindow( "Col01","Win07"	, "OPs para Seperar"          ,050, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oFWLayer:AddWindow( "Col02","Win02" , IIf( Empty( aOS[01][01] ), "Balança Desocupada", "Ordem de Separação: " + aOS[01][01] + " | Ordem de Produção: " + aOS[01][02])	,050, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oFWLayer:AddWindow( "Col02","Win03" , IIf( Empty( aOS[03][01] ), "Balança Desocupada", "Ordem de Separação: " + aOS[03][01] + " | Ordem de Produção: " + aOS[03][02])	,050, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oFWLayer:AddWindow( "Col03","Win04" , IIf( Empty( aOS[02][01] ), "Balança Desocupada", "Ordem de Separação: " + aOS[02][01] + " | Ordem de Produção: " + aOS[02][02])	,050, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oFWLayer:AddWindow( "Col03","Win05" , "Calendário de Ordens de Produções Separadas / Fracionadas",050, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )

	oWin1 := oFWLayer:GetWinPanel( 'Col01','Win01' )
	oWin2 := oFWLayer:GetWinPanel( 'Col02','Win02' )
	oWin3 := oFWLayer:GetWinPanel( 'Col02','Win03' )
	oWin4 := oFWLayer:GetWinPanel( 'Col03','Win04' )
	oWin5 := oFWLayer:GetWinPanel( 'Col03','Win05' )
	oWin6 := oFWLayer:GetWinPanel( 'Col01','Win06' )
	oWin7 := oFWLayer:GetWinPanel( 'Col01','Win07' )

	cColorBackGround 	:= "#FFFFFF"
	cColorSeparator 	:= "#C0C0C0"
	cGradientTop 		:= "#57A2EE"
	cGradientBottom 	:= "#2BD0F7"	// Gradiente inicial do botao selecionado
	cColorText			:= "#000000"	// Gradiente final do botao selecionado
	oTrackMenu  		:= TTrackMenu():New( oWin1, 000, 000, 000, 000, { |o, cID| FuncTrack( o, cId , oDlg, oBrowse1, @lAutoRef ,oTimeRef, @lAutoNFe ) }, 40, cColorBackGround, cColorSeparator, cGradientTop, cGradientBottom, oFontL, cColorText )
	oTrackMenu:Align	:= CONTROL_ALIGN_ALLCLIENT

	oTrackMenu:Add( "ID001", "Refresh"					, "RELOAD.PNG"     	, "BTNOFF.jpg"	)
	oTrackMenu:Add( "ID099", "Sair"						, "FINAL.PNG"						)

	//Legendas
	@ 000,005 BITMAP oBmp RESNAME "BR_VERDE"  	SIZE 16,16 NOBORDER OF oWin6 PIXEL
	@ 008,005 BITMAP oBmp RESNAME "BR_VERMELHO"	SIZE 16,16 NOBORDER OF oWin6 PIXEL
	@ 000, 015 SAY oSay PROMPT "Separado"		SIZE 080, 007 OF oWin6 COLORS 0, 16777215 PIXEL FONT oFontLeg
	@ 008, 015 SAY oSay PROMPT "Pendente"		SIZE 080, 007 OF oWin6 COLORS 0, 16777215 PIXEL FONT oFontLeg

	//Painel esquerdo da tela principal
	@ 000, 000 MSPANEL oPnlTran1	SIZE 300, 000 OF oWin2 COLORS 0, 16777215
	oPnlTran1:Align	:=  CONTROL_ALIGN_ALLCLIENT

	//Browse
	oBrowse1 := FWBrowse():New(oPnlTran1)        
	oBrowse1:SetDataQuery(.T.)
	oBrowse1:SetQuery(cQryMon)
	oBrowse1:SetQueryIndex({"CB7_ORDSEP+CB8_LOCAL+CB8_ITEM+CB8_PROD"})
	oBrowse1:SetAlias("TMP1")              
	oBrowse1:SetUniqueKey({"CB7_ORDSEP","CB8_LOCAL","CB8_ITEM","CB8_PROD"})
	oBrowse1:DisableConfig()
	oBrowse1:DisableReport()
	oBrowse1:SetFilterDefault( " AllTrim( TMP1->CB7_ORDSEP ) == '" + AllTrim( aOS[01][01] ) + "' " )
	oBrowse1:ExecuteFilter( .T. )

	//Legendas
	oBrowse1:AddLegend( "TMP1->CB8_SALDOS == 0", "GREEN")		// Separado
	oBrowse1:AddLegend( "TMP1->CB8_SALDOS <> 0" , "RED")		// Pendente

	//Colunas
	ADD COLUMN oColumn DATA { || TMP1->CB8_ITEM 									}	TITLE "Item"					SIZE  006 OF oBrowse1
	ADD COLUMN oColumn DATA { || TMP1->CB8_PROD										}	TITLE "Produto"					SIZE  014 OF oBrowse1
	ADD COLUMN oColumn DATA { || TMP1->CB8_LOCAL   									}	TITLE "Local"					SIZE  006 OF oBrowse1
	ADD COLUMN oColumn DATA { || TMP1->CB8_LOTECT   								}	TITLE "Lote"					SIZE  010 OF oBrowse1
	ADD COLUMN oColumn DATA { || Transform( TMP1->CB8_QTDORI, "@E 9,999,999.9999")	}	TITLE "Qtd. Original"			SIZE  015 OF oBrowse1
	ADD COLUMN oColumn DATA { || Transform( TMP1->CB8_SALDOS, "@E 9,999,999.9999")	}	TITLE "Saldo a Separar"			SIZE  015 OF oBrowse1

	//Ativa o Browse
	ACTIVATE FWBROWSE oBrowse1

	If !Empty( aOS[01][01] )
		oBrowse1:Show()
	Else
		oBrowse1:Hide()
	EndIf

	@ 000, 000 MSPANEL oPnlTran2	SIZE 300, 000 OF oWin4 COLORS 0, 16777215
	oPnlTran2:Align	:=  CONTROL_ALIGN_ALLCLIENT

	//Browse
	oBrowse2 := FWBrowse():New(oPnlTran2)        
	oBrowse2:SetDataQuery(.T.)
	oBrowse2:SetQuery(cQryMon)
	oBrowse2:SetQueryIndex({"CB7_ORDSEP+CB8_LOCAL+CB8_ITEM+CB8_PROD"})
	oBrowse2:SetAlias("TMP2")
	oBrowse2:SetUniqueKey({"CB7_ORDSEP","CB8_LOCAL","CB8_ITEM","CB8_PROD"})
	oBrowse2:DisableConfig()
	oBrowse2:DisableReport()
	oBrowse2:SetFilterDefault( " AllTrim( TMP2->CB7_ORDSEP ) == '" + AllTrim( aOS[02][01] ) + "' " )
	oBrowse2:ExecuteFilter( .T. )

	//Legendas
	oBrowse2:AddLegend( "TMP2->CB8_SALDOS == 0", "GREEN")		// Separado
	oBrowse2:AddLegend( "TMP2->CB8_SALDOS <> 0" , "RED")		// Pendente

	//Colunas
	ADD COLUMN oColumn DATA { || TMP2->CB8_ITEM 									}	TITLE "Item"					SIZE  006 OF oBrowse2
	ADD COLUMN oColumn DATA { || TMP2->CB8_PROD										}	TITLE "Produto"					SIZE  014 OF oBrowse2
	ADD COLUMN oColumn DATA { || TMP2->CB8_LOCAL   									}	TITLE "Local"					SIZE  006 OF oBrowse2
	ADD COLUMN oColumn DATA { || TMP2->CB8_LOTECT   								}	TITLE "Lote"					SIZE  010 OF oBrowse2
	ADD COLUMN oColumn DATA { || Transform( TMP2->CB8_QTDORI, "@E 9,999,999.9999")	}	TITLE "Qtd. Original"			SIZE  015 OF oBrowse2
	ADD COLUMN oColumn DATA { || Transform( TMP2->CB8_SALDOS, "@E 9,999,999.9999")	}	TITLE "Saldo a Separar"			SIZE  015 OF oBrowse2

	//Ativa o Browse
	ACTIVATE FWBROWSE oBrowse2

	If !Empty( aOS[02][01] )
		oBrowse2:Show()
	Else
		oBrowse2:Hide()
	EndIf

	@ 000, 000 MSPANEL oPnlTran3	SIZE 300, 000 OF oWin3 COLORS 0, 16777215
	oPnlTran3:Align	:=  CONTROL_ALIGN_ALLCLIENT

	//Browse
	oBrowse3 := FWBrowse():New(oPnlTran3)
	oBrowse3:SetDataQuery(.T.)
	oBrowse3:SetQuery(cQryMon)
	oBrowse3:SetQueryIndex({"CB7_ORDSEP+CB8_LOCAL+CB8_ITEM+CB8_PROD"})
	oBrowse3:SetAlias("TMP3")
	oBrowse3:SetUniqueKey({"CB7_ORDSEP","CB8_LOCAL","CB8_ITEM","CB8_PROD"})
	oBrowse3:DisableConfig()
	oBrowse3:DisableReport()
	oBrowse3:SetFilterDefault( " AllTrim( TMP3->CB7_ORDSEP ) == '" + AllTrim( aOS[03][01] ) + "' " )
	oBrowse3:ExecuteFilter( .T. )

	//Legendas
	oBrowse3:AddLegend( "TMP3->CB8_SALDOS == 0", "GREEN")		// Separado
	oBrowse3:AddLegend( "TMP3->CB8_SALDOS <> 0" , "RED")		// Pendente

	//Colunas
	ADD COLUMN oColumn DATA { || TMP3->CB8_ITEM 									}	TITLE "Item"					SIZE  006 OF oBrowse3
	ADD COLUMN oColumn DATA { || TMP3->CB8_PROD										}	TITLE "Produto"					SIZE  014 OF oBrowse3
	ADD COLUMN oColumn DATA { || TMP3->CB8_LOCAL   									}	TITLE "Local"					SIZE  006 OF oBrowse3
	ADD COLUMN oColumn DATA { || TMP3->CB8_LOTECT   								}	TITLE "Lote"					SIZE  010 OF oBrowse3
	ADD COLUMN oColumn DATA { || Transform( TMP3->CB8_QTDORI, "@E 9,999,999.9999")	}	TITLE "Qtd. Original"			SIZE  015 OF oBrowse3
	ADD COLUMN oColumn DATA { || Transform( TMP3->CB8_SALDOS, "@E 9,999,999.9999")	}	TITLE "Saldo a Separar"			SIZE  015 OF oBrowse3

	//Ativa o Browse
	ACTIVATE FWBROWSE oBrowse3

	If !Empty( aOS[03][01] )
		oBrowse3:Show()
	Else
		oBrowse3:Hide()
	EndIf

	@ 000, 000 MSPANEL oPnlTran4	SIZE 300, 000 OF oWin5 COLORS 0, 16777215
	oPnlTran4:Align	:=  CONTROL_ALIGN_ALLCLIENT

	@ 000, 000 MSPANEL oPnlTran5	SIZE 300, 000 OF oWin7 COLORS 0, 16777215
	oPnlTran5:Align	:=  CONTROL_ALIGN_ALLCLIENT

	//Browse
	oBrowse4 := FWBrowse():New(oPnlTran5)
	oBrowse4:SetDataQuery(.T.)
	oBrowse4:SetQuery(cQryOP)
	oBrowse4:SetQueryIndex({"CB7_OP"})
	oBrowse4:SetAlias("TMP4")              
	oBrowse4:SetUniqueKey({"CB7_OP"})
	oBrowse4:DisableConfig()
	oBrowse4:DisableReport()
	oBrowse4:ExecuteFilter( .T. )

	//Colunas
	ADD COLUMN oColumn DATA { || AllTrim( TMP4->CB7_OP ) } TITLE "Ordem Produção" SIZE 006 OF oBrowse4

	//Ativa o Browse
	ACTIVATE FWBROWSE oBrowse4

    oCalend := FWCalendarWidget():New(oPnlTran4)
    oCalend:SetbRefresh( {|dDate| BuscaAtividades(dDate) } )
    oCalend:SetFontColor("#FF6600") 
    oCalend:SetFontName("Comic Sans MS") 
         
    oCalend:Activate()

    oTimeRef := TTimer():New(5000, {|| ConsRet() }, oDlg )
    oTimeRef:Activate()
 
	ACTIVATE MSDIALOG oDlg CENTERED

Return Nil

Static Function FuncTrack( oTrackMenu, cId, oDlg, oBrowse1, lAutoRef, oTimeRef, lAutoNFe )

Local aKeys 		:= GetKeys()
Local lRetorno		:= .T.
Local aArea	:= GetArea()

If cId == "ID001"
	lAutoRef := !lAutoRef

	If !lAutoRef
		oTrackMenu:SetImage( "ID001", "BTNOFF.jpg"	)
		oTimeRef:lActive	:= .F.
	Else
		oTrackMenu:SetImage( "ID001", "BTNON.jpg"	)
		oTimeRef:lActive	:= .T.
	EndIf
ElseIf cId == "ID099"
	If !lPodeSair
		lSair := .T.
	Else
		oDlg:End()
		Return
	EndIf
EndIf

Return Nil

Static Function ConsRet() // oTimeRef 

Local nLinBrw := 0

lPodeSair := .F.

aOS    := {}
nLinha := 1

aAdd( aOS, {"", ""})
aAdd( aOS, {"", ""})
aAdd( aOS, {"", ""})

cQuery := "SELECT TOP 3 CB7_ORDSEP, CB7_OP " + CRLF
cQuery += "FROM " + RetSqlName("CB7") + " AS CB7 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("CB8") + " AS CB8 WITH (NOLOCK) ON CB8_FILIAL = CB7_FILIAL " + CRLF
cQuery += "  AND CB8_ORDSEP = CB7_ORDSEP " + CRLF
cQuery += "  AND CB8.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE CB7_FILIAL = '" + xFilial("CB7") + "' " + CRLF
cQuery += "AND CB7_DTEMIS >= '20200101' " + CRLF
cQuery += "AND CB7_STATUS = '1' " + CRLF
cQuery += "AND CB7_ORIGEM = '3' " + CRLF
cQuery += "AND EXISTS (SELECT C2_FILIAL FROM " + RetSqlName("SC2") + " WHERE C2_FILIAL = CB7_FILIAL AND C2_NUM + C2_ITEM + C2_SEQUEN = CB7_OP AND C2_QUANT > (C2_QUJE + C2_PERDA) AND D_E_L_E_T_ = ' ') " + CRLF
cQuery += "AND CB7.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "GROUP BY CB7_ORDSEP, CB7_OP " + CRLF
cQuery += "ORDER BY CB7_ORDSEP " + CRLF

TCQuery cQuery New Alias "TMPOS"
dbSelectArea("TMPOS")
dbGoTop()

Do While !TMPOS->( Eof() )
	If nLinha < 4
		aOS[nLinha][01] := TMPOS->CB7_ORDSEP
		aOS[nLinha][02] := TMPOS->CB7_OP
		nLinha++
	EndIf

	TMPOS->( dbSkip() )
EndDo

TMPOS->( dbCloseArea() )

If AllTrim( aOS[01][01] ) <> AllTrim( aAnterior[01][01] )
	If !Empty( aOS[01][01] )
		oBrowse1:DeActivate( .T. )
		oBrowse1:SetDataQuery(.T.)
		oBrowse1:SetQuery(cQryMon)
		oBrowse1:SetQueryIndex({"CB7_ORDSEP+CB8_LOCAL+CB8_ITEM+CB8_PROD"})
		oBrowse1:SetAlias("TMP1")
		oBrowse1:SetUniqueKey({"CB7_ORDSEP","CB8_LOCAL","CB8_ITEM","CB8_PROD"})
		oBrowse1:SetFilterDefault( " AllTrim( TMP1->CB7_ORDSEP ) == '" + AllTrim( aOS[01][01] ) + "' " )
		oBrowse1:ExecuteFilter( .T. )
		oBrowse1:Activate( .T. )
		oBrowse1:GoBottom()
		oBrowse1:GoTo(1,.T.)
		oBrowse1:Refresh(.T.)
		oBrowse1:Show()
	Else
		oBrowse1:Hide()
	EndIf
ElseIf !Empty( aOS[01][01] )
	nLinBrw := 1

	cQuery := cQryMon + CRLF
	//cQuery += "ORDER BY CB7_ORDSEP, CB8_LOCAL, CB8_ITEM, CB8_PROD "

	TCQuery cQuery New Alias "TMPLIN"
	dbSelectArea("TMPLIN")
	dbGoTop()
	
	Do While !TMPLIN->( Eof() )
		If TMPLIN->CB7_ORDSEP == AllTrim( aOS[01][01] )
			If TMPLIN->CB8_SALDOS == 0
				nLinBrw++
			Else
				Exit
			EndIf
		Else
			nLinBrw++
		EndIf

		TMPLIN->( dbSkip() )
	EndDo

	TMPLIN->( dbCloseArea() )

	oBrowse1:GoTo(nLinBrw,.T.)
EndIf

If AllTrim( aOS[02][01] ) <> AllTrim( aAnterior[02][01] )
	If !Empty( aOS[02][01] )
		oBrowse2:DeActivate( .T. )
		oBrowse2:SetDataQuery(.T.)
		oBrowse2:SetQuery(cQryMon)
		oBrowse2:SetQueryIndex({"CB7_ORDSEP+CB8_LOCAL+CB8_ITEM+CB8_PROD"})
		oBrowse2:SetAlias("TMP2")
		oBrowse2:SetUniqueKey({"CB7_ORDSEP","CB8_LOCAL","CB8_ITEM","CB8_PROD"})
		oBrowse2:SetFilterDefault( " AllTrim( TMP2->CB7_ORDSEP ) == '" + AllTrim( aOS[02][01] ) + "' " )
		oBrowse2:ExecuteFilter( .T. )
		oBrowse2:Activate( .T. )
		oBrowse2:GoBottom()
		oBrowse2:GoTo(1,.T.)
		oBrowse2:Refresh(.T.)
		oBrowse2:Show()
	Else
		oBrowse2:Hide()
	EndIf
ElseIf !Empty( aOS[02][01] )
	nLinBrw := 1

	cQuery := cQryMon + CRLF
	//cQuery += "ORDER BY CB7_ORDSEP, CB8_LOCAL, CB8_ITEM, CB8_PROD "

	TCQuery cQuery New Alias "TMPLIN"
	dbSelectArea("TMPLIN")
	dbGoTop()
	
	Do While !TMPLIN->( Eof() )
		If TMPLIN->CB7_ORDSEP == AllTrim( aOS[02][01] )
			If TMPLIN->CB8_SALDOS == 0
				nLinBrw++
			Else
				Exit
			EndIf
		Else
			nLinBrw++
		EndIf

		TMPLIN->( dbSkip() )
	EndDo

	TMPLIN->( dbCloseArea() )

	oBrowse2:GoTo(nLinBrw,.T.)
EndIf

If AllTrim( aOS[03][01] ) <> AllTrim( aAnterior[03][01] )
	If !Empty( aOS[03][01] )
		oBrowse3:DeActivate( .T. )
		oBrowse3:SetDataQuery(.T.)
		oBrowse3:SetQuery(cQryMon)
		oBrowse3:SetQueryIndex({"CB7_ORDSEP+CB8_ITEM+CB8_PROD"})
		oBrowse3:SetAlias("TMP3")
		oBrowse3:SetUniqueKey({"CB7_ORDSEP","CB8_LOCAL","CB8_ITEM","CB8_PROD"})
		oBrowse3:SetFilterDefault( " AllTrim( TMP3->CB7_ORDSEP ) == '" + AllTrim( aOS[03][01] ) + "' " )
		oBrowse3:ExecuteFilter( .T. )
		oBrowse3:Activate( .T. )
		oBrowse3:GoBottom()
		oBrowse3:GoTo(1,.T.)
		oBrowse3:Refresh(.T.)
		oBrowse3:Show()
	Else
		oBrowse3:Hide()
	EndIf
ElseIf !Empty( aOS[03][01] )
	nLinBrw := 1

	cQuery := cQryMon + CRLF
	//cQuery += "ORDER BY CB7_ORDSEP, CB8_LOCAL, CB8_ITEM, CB8_PROD "

	TCQuery cQuery New Alias "TMPLIN"
	dbSelectArea("TMPLIN")
	dbGoTop()
	
	Do While !TMPLIN->( Eof() )
		If TMPLIN->CB7_ORDSEP == AllTrim( aOS[03][01] )
			If TMPLIN->CB8_SALDOS == 0
				nLinBrw++
			Else
				Exit
			EndIf
		Else
			nLinBrw++
		EndIf

		TMPLIN->( dbSkip() )
	EndDo

	TMPLIN->( dbCloseArea() )

	oBrowse3:GoTo(nLinBrw,.T.)
EndIf

aAnterior[01][01] := aOS[01][01]
aAnterior[01][02] := aOS[01][02]
aAnterior[02][01] := aOS[02][01]
aAnterior[02][02] := aOS[02][02]
aAnterior[03][01] := aOS[03][01]
aAnterior[03][02] := aOS[03][02]

oBrowse4:DeActivate( .T. )
oBrowse4:SetDataQuery(.T.)
oBrowse4:SetQuery(cQryOP)
oBrowse4:SetQueryIndex({"CB7_OP"})
oBrowse4:SetAlias("TMP4")
oBrowse4:SetUniqueKey({"CB7_OP"})
oBrowse4:Activate( .T. )

oBrowse1:Refresh()
oPnlTran1:Refresh()
oWin2:Refresh()
oBrowse2:Refresh()
oPnlTran2:Refresh()
oWin3:Refresh()
oBrowse3:Refresh()
oPnlTran3:Refresh()
oWin4:Refresh()
oPnlTran4:Refresh()
cTitulo1 := IIf( Empty( aOS[01][01] ), "Balança Desocupada", "Ordem de Separação: " + aOS[01][01] + " | Ordem de Produção: " + aOS[01][02])
oFWLayer:setWinTitle( 'Col02','Win02' , cTitulo1 )
cTitulo2 := IIf( Empty( aOS[03][01] ), "Balança Desocupada", "Ordem de Separação: " + aOS[03][01] + " | Ordem de Produção: " + aOS[03][02])
oFWLayer:setWinTitle( 'Col02','Win03' , cTitulo2 )
cTitulo3 := IIf( Empty( aOS[02][01] ), "Balança Desocupada", "Ordem de Separação: " + aOS[02][01] + " | Ordem de Produção: " + aOS[02][02])
oFWLayer:setWinTitle( 'Col03','Win04' , cTitulo3 )
oFWLayer:Refresh()
oCalend:SetbRefresh( {|dDate| BuscaAtividades(dDate) } )
oCalend:Refresh()

lPodeSair := .T.

//If lSair
//	oDlg:End()
//EndIf

Return Nil

Static Function BuscaAtividades( dDate )

Local aArea     := GetArea()
Local aItems    := {}
Local oItem     := nil
Local aPrior    := {FWCALENDAR_PRIORITY_HIGH, FWCALENDAR_PRIORITY_MEDIUM, FWCALENDAR_PRIORITY_LOW}
Local nPrior    := 0
     
/*obs: é possivel definir a cor da atividade de duas formas.
1) utilizando o metodo SetPriority(), será definida uma cor padrao de acordo com a prioridade da tarefa passada
2) utilizando o metodo SetColor(cHexColor) e passando uma cor em hexadecimal
Se utilizar o SetColor() não utilize o SetPriority.
*/

cQuery := "SELECT CB7_ORDSEP, CB7_OP, CB7_DTINIS, CB7_HRINIS, CB7_DTFIMS, CB7_HRFIMS " + CRLF
cQuery += "FROM " + RetSqlName("CB7") + " AS CB7 " + CRLF
cQuery += "WHERE CB7_FILIAL = '" + xFilial("CB7") + "' " + CRLF
cQuery += "AND CB7_DTEMIS >= '20200101' " + CRLF
cQuery += "AND CB7_DTINIS <= '" + DTOS( dDate ) + "' AND CB7_DTFIMS >= '" + DTOS( dDate ) + "' " + CRLF
cQuery += "AND CB7_ORIGEM = '3' " + CRLF
cQuery += "AND CB7.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "ORDER BY CB7_DTFIMS, CB7_HRFIMS, CB7_ORDSEP " + CRLF

TCQuery cQuery New Alias "TMPAGE"
dbSelectArea("TMPAGE")
dbGoTop()

Do While !TMPAGE->( Eof() )
	nPrior++

	If nPrior > 3
		nPrior := 1
	EndIf

	oItem := FWCalendarActivity():New()
		oItem:SetID( TMPAGE->CB7_ORDSEP )
		oItem:SetTitle("OS: " + AllTrim( TMPAGE->CB7_ORDSEP ) )
		oItem:SetNotes("Separação da Ordem de Produção Concluída: " + AllTrim( TMPAGE->CB7_OP ) )
		oItem:SetPriority( aPrior[nPrior] )
		oItem:SetDtIni( STOD( TMPAGE->CB7_DTINIS ) )
		oItem:SetDtFin( STOD( TMPAGE->CB7_DTFIMS ) )
		oItem:SetHrIni( Transform( TMPAGE->CB7_HRINIS, "@R 99:99:99") )
		oItem:SetHrFin( Transform( TMPAGE->CB7_HRFIMS, "@R 99:99:99") )
	aAdd( aItems, oItem)

	TMPAGE->( dbSkip() )
EndDo

TMPAGE->( dbCloseArea() )

RestArea(aArea)

Return aItems