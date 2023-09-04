#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "FwBrowse.ch"
#Include "TopConn.ch"
#Include "FwMvcDef.ch"
#Include "ParmType.ch"
#Include 'FwCalendarWidget.ch'
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2

/*
Fabio 25/05/2020: Tela para monitoramento da contagem de Inventário...
*/

User Function EQIntZ84()

Local aArea         := GetArea()

Private lValido     := .T.
Private lRetorno    := .T.
Private lPodeSair   := .T. // Se estiver em processo de atualização de tela não permite finalizar o objeto oDlg:End()
Private lSair       := .F.
Private cTitulo	    := "Monitor para Contagem do Inventário"
Private cCadastro   := cTitulo
Private cQuery      := ""
Private oFont       := TFont():New( "Courier New",,14,,.T.,,,,,.F. )
Private aDigitacao  := {}
Private nLinha      := 1
Private cPerg	    := "EQINVMONZZ"
Private cTipoPrd    := "'MP','ME','EM','PA','PI','BN','SP','PP','KT'"
Private aTipoPrd    := {}
Private nTipoPrd    := 0

ValidPerg()

If !Pergunte( cPerg, .T.)
	ApMsgAlert( 'Processamento Cancelado!', 'Atenção')
	Return
EndIf

dbSelectArea("Z86")
dbSetOrder(1)
dbGoTop()

If AllTrim( cEmpAnt ) + AllTrim( cFilAnt ) $ "0107|0200|0803|0901"
	dbSelectArea("Z86")
	dbSetOrder(1)
	dbGoTop()
	Do Case
		Case AllTrim( cEmpAnt ) + AllTrim( cFilAnt ) == "0107"
			If AllTrim( Z86->Z86_0107 ) <> "S"
				lValido := .F.
				Help( ,, "EQDIGVLEMP",, "Empresa ou filial não habilitada para contagem do inventário, Verifique!", 1, 0 )
			EndIf
		Case AllTrim( cEmpAnt ) + AllTrim( cFilAnt ) == "0200"
			If AllTrim( Z86->Z86_0200 ) <> "S"
				lValido := .F.
				Help( ,, "EQDIGVLEMP",, "Empresa ou filial não habilitada para contagem do inventário, Verifique!", 1, 0 )
			EndIf
		Case AllTrim( cEmpAnt ) + AllTrim( cFilAnt ) == "0803"
			If AllTrim( Z86->Z86_0803 ) <> "S"
				lValido := .F.
				Help( ,, "EQDIGVLEMP",, "Empresa ou filial não habilitada para contagem do inventário, Verifique!", 1, 0 )
			EndIf
		Case AllTrim( cEmpAnt ) + AllTrim( cFilAnt ) == "0901"
			If AllTrim( Z86->Z86_0901 ) <> "S"
				lValido := .F.
				Help( ,, "EQDIGVLEMP",, "Empresa ou filial não habilitada para contagem do inventário, Verifique!", 1, 0 )
			EndIf
	EndCase
Else
	lValido := .F.
	Help( ,, "EQDIGVLEMP",, "Empresa ou filial inválida para contagem do inventário, Verifique!", 1, 0 )
EndIf

If lValido
	If Z86->Z86_AF
		aAdd( aTipoPrd, {"'AF'"})
	EndIf
	If Z86->Z86_AI
		aAdd( aTipoPrd, {"'AI'"})
	EndIf
	If Z86->Z86_BN
		aAdd( aTipoPrd, {"'BN'"})
	EndIf
	If Z86->Z86_EM
		aAdd( aTipoPrd, {"'EM'"})
	EndIf
	If Z86->Z86_GG
		aAdd( aTipoPrd, {"'GG'"})
	EndIf
	If Z86->Z86_GN
		aAdd( aTipoPrd, {"'GN'"})
	EndIf
	If Z86->Z86_KT
		aAdd( aTipoPrd, {"'KT'"})
	EndIf
	If Z86->Z86_MC
		aAdd( aTipoPrd, {"'MC'"})
	EndIf
	If Z86->Z86_MD
		aAdd( aTipoPrd, {"'MD'"})
	EndIf
	If Z86->Z86_ME
		aAdd( aTipoPrd, {"'ME'"})
	EndIf
	If Z86->Z86_MO
		aAdd( aTipoPrd, {"'MO'"})
	EndIf
	If Z86->Z86_MP
		aAdd( aTipoPrd, {"'MP'"})
	EndIf
	If Z86->Z86_MS
		aAdd( aTipoPrd, {"'MS'"})
	EndIf
	If Z86->Z86_OI
		aAdd( aTipoPrd, {"'OI'"})
	EndIf
	If Z86->Z86_PA
		aAdd( aTipoPrd, {"'PA'"})
	EndIf
	If Z86->Z86_PC
		aAdd( aTipoPrd, {"'PC'"})
	EndIf
	If Z86->Z86_PI
		aAdd( aTipoPrd, {"'PI'"})
	EndIf
	If Z86->Z86_PP
		aAdd( aTipoPrd, {"'PP'"})
	EndIf
	If Z86->Z86_PR
		aAdd( aTipoPrd, {"'PR'"})
	EndIf
	If Z86->Z86_PV
		aAdd( aTipoPrd, {"'PV'"})
	EndIf
	If Z86->Z86_SP
		aAdd( aTipoPrd, {"'SP'"})
	EndIf
	If Z86->Z86_SV
		aAdd( aTipoPrd, {"'SV'"})
	EndIf
EndIf

If Len( aTipoPrd ) > 0
	cTipoPrd := ""
	For nTipoPrd := 1 To Len( aTipoPrd )
		If nTipoPrd == Len( aTipoPrd )
			cTipoPrd += AllTrim( aTipoPrd[nTipoPrd][01] )
		Else
			cTipoPrd += AllTrim( aTipoPrd[nTipoPrd][01] ) + ","
		EndIf
	Next
EndIf

If lValido
	FwMsgRun( ,{ || Monitor() }, , 'Selecionando Registros, Por favor aguarde' )
EndIf

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

DEFINE MSDIALOG oDlg TITLE cTitulo FROM aSize[7],aSize[1] TO aSize[6],aSize[5] OF oMainWnd STYLE nOR( WS_VISIBLE,WS_POPUP ) PIXEL

	oDlg:lEscClose := .F.
	oFont := TFont():New('Courier new',,-10,.T.)

	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlg, .F. )

	oFWLayer:AddCollumn( "Col01",  100, .T. )

	oFWLayer:AddWindow( "Col01","Win01"	, "Inventário"       		,025, .T., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oFWLayer:AddWindow( "Col01","Win02"	, "Gráficos"           		,075, .T., .T., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )

	oWin1 := oFWLayer:GetWinPanel( 'Col01','Win01' )
	oWin2 := oFWLayer:GetWinPanel( 'Col01','Win02' )

	oPLayer := FWLayer():New()
	oPLayer:Init( oWin1, .F. )

	oPLayer:AddCollumn( "Col11",  30, .T. )
	oPLayer:AddCollumn( "Col12",  30, .T. )
	oPLayer:AddCollumn( "Col13",  30, .T. )
	oPLayer:AddCollumn( "Col14",  10, .T. )

	oPLayer:AddWindow( "Col11","Win11"	, "Diferença Quantidade"	,100, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oPLayer:AddWindow( "Col12","Win11"	, "Diferença de Valor" 		,100, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oPLayer:AddWindow( "Col13","Win11"	, "Percentual do Desvio"	,100, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oPLayer:AddWindow( "Col14","Win11"	, "Ações"					,100, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )

	oWin3 := oPLayer:GetWinPanel( 'Col11','Win11' ) // Diferença Quantidade
	oWin4 := oPLayer:GetWinPanel( 'Col12','Win11' ) // Diferença de Valor
	oWin5 := oPLayer:GetWinPanel( 'Col13','Win11' ) // Percentual do Desvio
	oWin6 := oPLayer:GetWinPanel( 'Col14','Win11' )

	oDLayer := FWLayer():New()
	oDLayer:Init( oWin2, .F. )

	oDLayer:AddCollumn( "Col21",  25, .T. )
	oDLayer:AddCollumn( "Col22",  25, .T. )
	oDLayer:AddCollumn( "Col23",  25, .T. )
	oDLayer:AddCollumn( "Col24",  25, .T. )

	oDLayer:AddWindow( "Col21","Win21"	, "Funil | Desvios por Equipe"							,050, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oDLayer:AddWindow( "Col22","Win21"	, "Barra | Desvios por Tipo de Produtos vs Equipes"		,050, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oDLayer:AddWindow( "Col21","Win22"	, "Radar | Quantidade Tipo de Produtos vs Equipes"		,050, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oDLayer:AddWindow( "Col22","Win22"	, "Linha | Análises Produtos Saldo Atual vs Apuração"	,050, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )

	oDLayer:AddWindow( "Col23","Win23"	, "Pizza | Quantidade por Grupo de Contagem"			,050, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oDLayer:AddWindow( "Col24","Win23"	, "Barra | Top 10 Desvios de Produtos"				 	,050, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oDLayer:AddWindow( "Col23","Win24"	, "Barra | Quantidade de Fichas por Grupos Contagens"	,050, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oDLayer:AddWindow( "Col24","Win24"	, "Linha | Produtos Saldos Atuais vs Apuração"	 		,050, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )

	oWin7 := oDLayer:GetWinPanel( 'Col21','Win21' )
	oWin8 := oDLayer:GetWinPanel( 'Col21','Win22' )
	oWin9 := oDLayer:GetWinPanel( 'Col22','Win21' )
	oWin10:= oDLayer:GetWinPanel( 'Col22','Win22' )

	oWin11:= oDLayer:GetWinPanel( 'Col23','Win23' )
	oWin12:= oDLayer:GetWinPanel( 'Col23','Win24' )
	oWin13:= oDLayer:GetWinPanel( 'Col24','Win23' )
	oWin14:= oDLayer:GetWinPanel( 'Col24','Win24' )

	cColorBackGround 	:= "#FFFFFF"
	cColorSeparator 	:= "#C0C0C0"
	cGradientTop 		:= "#57A2EE"
	cGradientBottom 	:= "#2BD0F7"	// Gradiente inicial do botao selecionado
	cColorText			:= "#000000"	// Gradiente final do botao selecionado

	@ 000, 000 MSPANEL oPnlTran1	SIZE 300, 000 OF oWin6 COLORS 0, 16777215
	oPnlTran1:Align	:=  CONTROL_ALIGN_ALLCLIENT
	oTButton1 := TButton():New( 000, 002, "Gerar Backup",oPnlTran1,{||fBackup()}        , 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )    
	oTButton2 := TButton():New( 010, 002, "Gerar SB7"   ,oPnlTran1,{||fGeraSB7()}       , 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )    
	oTButton3 := TButton():New( 020, 002, "Imprimir"    ,oPnlTran1,{||fImprimir()}      , 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )    
	oTButton4 := TButton():New( 030, 002, "Sair"        ,oPnlTran1,{||oDlg:End()}       , 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	nDifQtd := 0
	nDifCus := 0
	nPercen := 100

	cQuery := "SELECT (SUM(B2_QATU) - SUM(Z83_QUANTI)) AS DIF_QUANT, (SUM(B2_VATU1) - SUM(VALOR)) AS DIF_VALOR, 100 - ((ISNULL( SUM(VALOR), 0.01) / ISNULL( SUM(B2_VATU1), 0.01)) * 100.00) AS PERC_DESVIO " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT Z83_PRODUT, Z83_LOCAL, Z83_QUANTI, (Z83_QUANTI * ISNULL( B2_CM1, 0)) AS VALOR, ISNULL( B2_QATU, 0) AS B2_QATU, ISNULL( B2_VATU1, 0) AS B2_VATU1 " + CRLF
	cQuery += "FROM " + RetSqlName("Z83") + " AS Z83 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = Z83_PRODUT " + CRLF
//	cQuery += "  AND B1_TIPO IN ('MP','ME','EM','PA','PI','BN','SP','PP') " + CRLF
	cQuery += "  AND B1_TIPO IN (" + AllTrim( cTipoPrd ) + ") " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "LEFT JOIN " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) ON B2_FILIAL = Z83_FILIAL " + CRLF
	cQuery += "  AND B2_COD = Z83_PRODUT " + CRLF
	cQuery += "  AND B2_LOCAL = Z83_LOCAL " + CRLF
	cQuery += "  AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE Z83_FILIAL = '" + xFilial("Z83") + "' " + CRLF
	cQuery += "AND Z83_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
	//cQuery += "AND Z83_STATUS = '1' " + CRLF
	cQuery += "AND Z83.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT B2_COD, B2_LOCAL, 0 AS Z83_QUANTI, 0 AS VALOR, B2_QATU, B2_VATU1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = B2_COD " + CRLF
//	cQuery += "  AND B1_TIPO IN ('MP','ME','EM','PA','PI','BN','SP','PP') " + CRLF
	cQuery += "  AND B1_TIPO IN (" + AllTrim( cTipoPrd ) + ") " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND NOT EXISTS (SELECT Z83_FILIAL FROM " + RetSqlName("Z83") + " WITH (NOLOCK) WHERE Z83_FILIAL = B2_FILIAL AND Z83_PRODUT = B2_COD AND Z83_LOCAL = B2_LOCAL AND Z83_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND NOT EXISTS (SELECT Z85_FILIAL FROM " + RetSqlName("Z85") + " WITH (NOLOCK) WHERE Z85_FILIAL = B2_FILIAL AND Z85_PRODUT = B2_COD AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF

	TCQuery cQuery New Alias "TMPAPU"
	dbSelectArea("TMPAPU")
	dbGoTop()

	If !TMPAPU->( Eof() )
		nDifQtd := TMPAPU->DIF_QUANT
		nDifCus := TMPAPU->DIF_VALOR
		nPercen := TMPAPU->PERC_DESVIO
	EndIf

	TMPAPU->( dbCloseArea() )

	@ 000, 000 MSPANEL oPnlTran3	SIZE 300, 000 OF oWin3 COLORS 0, 16777215
	oPnlTran3:Align	:=  CONTROL_ALIGN_ALLCLIENT
	@ 000, 000 MSPANEL oPnlTran4	SIZE 300, 000 OF oWin4 COLORS 0, 16777215
	oPnlTran4:Align	:=  CONTROL_ALIGN_ALLCLIENT
	@ 000, 000 MSPANEL oPnlTran5	SIZE 300, 000 OF oWin5 COLORS 0, 16777215
	oPnlTran5:Align	:=  CONTROL_ALIGN_ALLCLIENT

	oFontFic  := tFont():New("Courier New",,-48,,.T.,,,,.T.)
	oSayFicha := tSay():New( 001, 001,{|| Transform( nDifQtd, "@E 99,999,999.99")   } , oPnlTran3,, oFontFic,,,,.T.,CLR_HRED,CLR_WHITE,200,120 )
	oSayFicha := tSay():New( 001, 001,{|| Transform( nDifCus, "@E 99,999,999.99")   } , oPnlTran4,, oFontFic,,,,.T.,CLR_RED ,CLR_WHITE,200,120 )
	oSayFicha := tSay():New( 001, 041,{|| Transform( nPercen, "@E 999.9999") + " %"   } , oPnlTran5,, oFontFic,,,,.T.,CLR_BLUE,CLR_WHITE,200,120 )

	// Gráfico 1 - Desvios por Equipe
	cQuery := "SELECT Z83_GRUPO, Z83_EQUIPE, (SUM(B2_QATU) - SUM(Z83_QUANTI)) AS DIF_QUANT, (SUM(B2_VATU1) - SUM(VALOR)) AS DIF_VALOR " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT Z83_GRUPO, Z83_EQUIPE, Z83_PRODUT, Z83_LOCAL, Z83_QUANTI, (Z83_QUANTI * ISNULL( B2_CM1, 0)) AS VALOR, ISNULL( B2_QATU, 0) AS B2_QATU, ISNULL( B2_VATU1, 0) AS B2_VATU1 " + CRLF
	cQuery += "FROM " + RetSqlName("Z83") + " AS Z83 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = Z83_PRODUT " + CRLF
//	cQuery += "  AND B1_TIPO IN ('MP','ME','EM','PA','PI','BN','SP','PP') " + CRLF
	cQuery += "  AND B1_TIPO IN (" + AllTrim( cTipoPrd ) + ") " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "LEFT JOIN " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) ON B2_FILIAL = Z83_FILIAL " + CRLF
	cQuery += "  AND B2_COD = Z83_PRODUT " + CRLF
	cQuery += "  AND B2_LOCAL = Z83_LOCAL " + CRLF
	cQuery += "  AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE Z83_FILIAL = '" + xFilial("Z83") + "' " + CRLF
	cQuery += "AND Z83_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
	cQuery += "AND Z83.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF
	cQuery += "GROUP BY Z83_GRUPO, Z83_EQUIPE " + CRLF
	cQuery += "ORDER BY Z83_GRUPO, Z83_EQUIPE " + CRLF

	TCQuery cQuery New Alias "TMPINV"
	dbSelectArea("TMPINV")
	dbGoTop()

	oChart7 := FWChartFactory():New()
	oChart7:SetOwner( oWin7 )
	
	If !TMPINV->( Eof() )
		Do While !TMPINV->( Eof() )
			oChart7:addSerie( AllTrim( TMPINV->Z83_GRUPO ) + " " + AllTrim( TMPINV->Z83_EQUIPE ), TMPINV->DIF_QUANT )

			TMPINV->( dbSkip() )
		EndDo
	Else
		oChart7:addSerie('Sem Grupo Apurado',   0 )
	EndIf
	
	TMPINV->( dbCloseArea() )

	oChart7:EnableMenu(.F.)
	oChart7:SetChartDefault( FUNNELCHART )
	oChart7:Activate()

	// Gráfico 2 - Quantidade Tipo de Produtos vs Equipe
	cQuery := "SELECT Z83_GRUPO, Z83_EQUIPE, SUM(ISNULL([MP], 0)) AS MP, SUM(ISNULL([ME], 0)) AS ME, SUM(ISNULL([EM], 0)) AS EM, SUM(ISNULL([PA], 0)) AS PA, SUM(ISNULL([PI], 0)) AS PIN, SUM(ISNULL([BN], 0)) AS BN, SUM(ISNULL([SP], 0)) AS SP, SUM(ISNULL([PP], 0)) AS PP " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT Z83_GRUPO, Z83_EQUIPE, [MP],[ME],[EM],[PA],[PI],[BN],[SP],[PP] " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT B1_TIPO, X5_DESCRI, Z83_GRUPO, Z83_EQUIPE, SUM(Z83_QUANTI) AS QUANT " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT B1_TIPO, X5_DESCRI, Z83_GRUPO, Z83_EQUIPE, Z83_PRODUT, Z83_LOCAL, Z83_QUANTI " + CRLF
	cQuery += "FROM " + RetSqlName("Z83") + " AS Z83 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = Z83_PRODUT " + CRLF
//	cQuery += "  AND B1_TIPO IN ('MP','ME','EM','PA','PI','BN','SP','PP') " + CRLF
	cQuery += "  AND B1_TIPO IN (" + AllTrim( cTipoPrd ) + ") " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SX5") + " AS SX5 WITH (NOLOCK) ON X5_FILIAL = '  ' " + CRLF
	cQuery += "  AND X5_TABELA = '02' " + CRLF
	cQuery += "  AND X5_CHAVE = B1_TIPO " + CRLF
	cQuery += "  AND SX5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "LEFT JOIN " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) ON B2_FILIAL = Z83_FILIAL " + CRLF
	cQuery += "  AND B2_COD = Z83_PRODUT " + CRLF
	cQuery += "  AND B2_LOCAL = Z83_LOCAL " + CRLF
	cQuery += "  AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE Z83_FILIAL = '" + xFilial("Z83") + "' " + CRLF
	cQuery += "AND Z83_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
	cQuery += "AND Z83.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF
	cQuery += "GROUP BY B1_TIPO, X5_DESCRI, Z83_GRUPO, Z83_EQUIPE " + CRLF
	cQuery += ") AS AGRUP2 " + CRLF
	cQuery += "PIVOT ( SUM(QUANT) FOR B1_TIPO IN ( [MP],[ME],[EM],[PA],[PI],[BN],[SP],[PP] )) AS P " + CRLF
	cQuery += ") AS AGRUP3 " + CRLF
	cQuery += "GROUP BY Z83_GRUPO, Z83_EQUIPE " + CRLF
	cQuery += "ORDER BY Z83_GRUPO, Z83_EQUIPE " + CRLF

	TCQuery cQuery New Alias "TMPINV"
	dbSelectArea("TMPINV")
	dbGoTop()

	oChart8 := FWChartFactory():New()
	oChart8:SetOwner( oWin8 )
	
	oChart8:SetXAxis( { 'MP', 'ME', 'EM', 'PA', 'PI', 'BN', 'SP', 'PP' } )
	
	If !TMPINV->( Eof() )
		Do While !TMPINV->( Eof() )
			oChart8:addSerie(AllTrim( TMPINV->Z83_GRUPO ) + " " + AllTrim( TMPINV->Z83_EQUIPE ), { TMPINV->MP, TMPINV->ME, TMPINV->EM, TMPINV->PA, TMPINV->PIN, TMPINV->BN, TMPINV->SP, TMPINV->PP } )

			TMPINV->( dbSkip() )
		EndDo
	Else
		oChart8:addSerie('Sem Contagem', { 0, 0, 0, 0, 0, 0, 0, 0 } )
	EndIf
	
	TMPINV->( dbCloseArea() )
	
	oChart8:EnableMenu(.F.)
	oChart8:SetChartDefault( RADARCHART )
	oChart8:Activate()

	// Gráfico 3 - Desvio por Equipe vs Tipo de Produto
	cQuery := "SELECT Z83_GRUPO, Z83_EQUIPE, SUM(ISNULL([MP], 0)) AS MP, SUM(ISNULL([ME], 0)) AS ME, SUM(ISNULL([EM], 0)) AS EM, SUM(ISNULL([PA], 0)) AS PA, SUM(ISNULL([PI], 0)) AS PIN, SUM(ISNULL([BN], 0)) AS BN, SUM(ISNULL([SP], 0)) AS SP, SUM(ISNULL([PP], 0)) AS PP " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT Z83_GRUPO, Z83_EQUIPE, [MP],[ME],[EM],[PA],[PI],[BN],[SP],[PP] " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT B1_TIPO, X5_DESCRI, Z83_GRUPO, Z83_EQUIPE, (SUM(B2_QATU) - SUM(Z83_QUANTI)) AS DIF_QUANT, (SUM(B2_VATU1) - SUM(VALOR)) AS DIF_VALOR " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT B1_TIPO, X5_DESCRI, Z83_GRUPO, Z83_EQUIPE, Z83_PRODUT, Z83_LOCAL, Z83_QUANTI, (Z83_QUANTI * ISNULL( B2_CM1, 0)) AS VALOR, ISNULL( B2_QATU, 0) AS B2_QATU, ISNULL( B2_VATU1, 0) AS B2_VATU1 " + CRLF
	cQuery += "FROM " + RetSqlName("Z83") + " AS Z83 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = Z83_PRODUT " + CRLF
//	cQuery += "  AND B1_TIPO IN ('MP','ME','EM','PA','PI','BN','SP','PP') " + CRLF
	cQuery += "  AND B1_TIPO IN (" + AllTrim( cTipoPrd ) + ") " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SX5") + " AS SX5 WITH (NOLOCK) ON X5_FILIAL = '  ' " + CRLF
	cQuery += "  AND X5_TABELA = '02' " + CRLF
	cQuery += "  AND X5_CHAVE = B1_TIPO " + CRLF
	cQuery += "  AND SX5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "LEFT JOIN " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) ON B2_FILIAL = Z83_FILIAL " + CRLF
	cQuery += "  AND B2_COD = Z83_PRODUT " + CRLF
	cQuery += "  AND B2_LOCAL = Z83_LOCAL " + CRLF
	cQuery += "  AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE Z83_FILIAL = '" + xFilial("Z83") + "' " + CRLF
	cQuery += "AND Z83_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
	cQuery += "AND Z83.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF
	cQuery += "GROUP BY B1_TIPO, X5_DESCRI, Z83_GRUPO, Z83_EQUIPE " + CRLF
	cQuery += ") AS AGRUP2 " + CRLF
	cQuery += "PIVOT ( SUM(DIF_QUANT) FOR B1_TIPO IN ( [MP],[ME],[EM],[PA],[PI],[BN],[SP],[PP] )) AS P " + CRLF
	cQuery += ") AS AGRUP3 " + CRLF
	cQuery += "GROUP BY Z83_GRUPO, Z83_EQUIPE " + CRLF
	cQuery += "ORDER BY Z83_GRUPO, Z83_EQUIPE " + CRLF

	TCQuery cQuery New Alias "TMPINV"
	dbSelectArea("TMPINV")
	dbGoTop()

	oChart9 := FWChartFactory():New()
	oChart9:SetOwner( oWin9 )
	
	oChart9:SetXAxis( { 'MP', 'ME', 'EM', 'PA', 'PI', 'BN', 'SP', 'PP' } )
	
	If !TMPINV->( Eof() )
		Do While !TMPINV->( Eof() )
			oChart9:addSerie(AllTrim( TMPINV->Z83_GRUPO ) + " " + AllTrim( TMPINV->Z83_EQUIPE ), { TMPINV->MP, TMPINV->ME, TMPINV->EM, TMPINV->PA, TMPINV->PIN, TMPINV->BN, TMPINV->SP, TMPINV->PP } )

			TMPINV->( dbSkip() )
		EndDo
	Else
		oChart9:addSerie('Sem Contagem', { 0, 0, 0, 0, 0, 0, 0, 0 } )
	EndIf
	
	TMPINV->( dbCloseArea() )

	oChart9:EnableMenu(.F.)
	oChart9:SetChartDefault( COLUMNCHART )
	oChart9:Activate()

	aApuMP := {}
	aAdd( aApuMP, { 0, 0})
	aApuME := {}
	aAdd( aApuME, { 0, 0})
	aApuEM := {}
	aAdd( aApuEM, { 0, 0})
	aApuPA := {}
	aAdd( aApuPA, { 0, 0})
	aApuPI := {}
	aAdd( aApuPI, { 0, 0})
	aApuBN := {}
	aAdd( aApuBN, { 0, 0})
	aApuSP := {}
	aAdd( aApuSP, { 0, 0})
	aApuPP := {}
	aAdd( aApuPP, { 0, 0})

	// Gráfico 4 - Saldo Atual vs Saldo Apurado
	cQuery := "SELECT STS, SUM(MP) AS MP, SUM(ME) AS ME, SUM(EM) AS EM, SUM(PA) AS PA, " + CRLF
	cQuery += "            SUM(PIN) AS PIN, SUM(BN) AS BN, SUM(SP) AS SP, SUM(PP) AS PP " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT 'Saldo Atual' AS STS, " + CRLF
	cQuery += "       CASE WHEN B1_TIPO = 'MP' THEN SUM(B2_QATU) ELSE 0 END AS MP, " + CRLF
	cQuery += "       CASE WHEN B1_TIPO = 'ME' THEN SUM(B2_QATU) ELSE 0 END AS ME, " + CRLF
	cQuery += "       CASE WHEN B1_TIPO = 'EM' THEN SUM(B2_QATU) ELSE 0 END AS EM, " + CRLF
	cQuery += "       CASE WHEN B1_TIPO = 'PA' THEN SUM(B2_QATU) ELSE 0 END AS PA, " + CRLF
	cQuery += "       CASE WHEN B1_TIPO = 'PI' THEN SUM(B2_QATU) ELSE 0 END AS PIN, " + CRLF
	cQuery += "       CASE WHEN B1_TIPO = 'BN' THEN SUM(B2_QATU) ELSE 0 END AS BN, " + CRLF
	cQuery += "       CASE WHEN B1_TIPO = 'SP' THEN SUM(B2_QATU) ELSE 0 END AS SP, " + CRLF
	cQuery += "       CASE WHEN B1_TIPO = 'PP' THEN SUM(B2_QATU) ELSE 0 END AS PP " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = B2_COD " + CRLF
//	cQuery += "  AND B1_TIPO IN ('MP','ME','EM','PA','PI','BN','SP','PP') " + CRLF
	cQuery += "  AND B1_TIPO IN (" + AllTrim( cTipoPrd ) + ") " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND NOT EXISTS (SELECT Z85_FILIAL FROM " + RetSqlName("Z85") + " WITH (NOLOCK) WHERE Z85_FILIAL = B2_FILIAL AND Z85_PRODUT = B2_COD AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY B1_TIPO " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT 'Contagem Apurada' AS STS, " + CRLF
	cQuery += "       CASE WHEN B1_TIPO = 'MP' THEN SUM(Z83_QUANTI) ELSE 0 END AS MP, " + CRLF
	cQuery += "       CASE WHEN B1_TIPO = 'ME' THEN SUM(Z83_QUANTI) ELSE 0 END AS ME, " + CRLF
	cQuery += "       CASE WHEN B1_TIPO = 'EM' THEN SUM(Z83_QUANTI) ELSE 0 END AS EM, " + CRLF
	cQuery += "       CASE WHEN B1_TIPO = 'PA' THEN SUM(Z83_QUANTI) ELSE 0 END AS PA, " + CRLF
	cQuery += "       CASE WHEN B1_TIPO = 'PI' THEN SUM(Z83_QUANTI) ELSE 0 END AS PIN, " + CRLF
	cQuery += "       CASE WHEN B1_TIPO = 'BN' THEN SUM(Z83_QUANTI) ELSE 0 END AS BN, " + CRLF
	cQuery += "       CASE WHEN B1_TIPO = 'SP' THEN SUM(Z83_QUANTI) ELSE 0 END AS SP, " + CRLF
	cQuery += "       CASE WHEN B1_TIPO = 'PP' THEN SUM(Z83_QUANTI) ELSE 0 END AS PP " + CRLF
	cQuery += "FROM " + RetSqlName("Z83") + " AS Z83 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = Z83_PRODUT " + CRLF
//	cQuery += "  AND B1_TIPO IN ('MP','ME','EM','PA','PI','BN','SP','PP') " + CRLF
	cQuery += "  AND B1_TIPO IN (" + AllTrim( cTipoPrd ) + ") " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE Z83_FILIAL = '" + xFilial("Z83") + "' " + CRLF
	cQuery += "AND Z83_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
	cQuery += "AND Z83.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY B1_TIPO " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF
	cQuery += "GROUP BY STS " + CRLF
	cQuery += "ORDER BY STS DESC " + CRLF

	TCQuery cQuery New Alias "TMPINV"
	dbSelectArea("TMPINV")
	dbGoTop()

	oChart10 := FWChartFactory():New()
	oChart10:SetOwner( oWin10 )
	
	oChart10:SetXAxis( { 'MP', 'ME', 'EM', 'PA', 'PI', 'BN', 'SP', 'PP' } )
	
	If !TMPINV->( Eof() )
		Do While !TMPINV->( Eof() )
			oChart10:addSerie(AllTrim( TMPINV->STS ), { TMPINV->MP, TMPINV->ME, TMPINV->EM, TMPINV->PA, TMPINV->PIN, TMPINV->BN, TMPINV->SP, TMPINV->PP } )

			If AllTrim( TMPINV->STS ) == 'Saldo Atual'
				aApuMP[01][01] := TMPINV->MP
				aApuME[01][01] := TMPINV->ME
				aApuEM[01][01] := TMPINV->EM
				aApuPA[01][01] := TMPINV->PA
				aApuPI[01][01] := TMPINV->PIN
				aApuBN[01][01] := TMPINV->BN
				aApuSP[01][01] := TMPINV->SP
				aApuPP[01][01] := TMPINV->PP
			Else
				aApuMP[01][02] := TMPINV->MP
				aApuME[01][02] := TMPINV->ME
				aApuEM[01][02] := TMPINV->EM
				aApuPA[01][02] := TMPINV->PA
				aApuPI[01][02] := TMPINV->PIN
				aApuBN[01][02] := TMPINV->BN
				aApuSP[01][02] := TMPINV->SP
				aApuPP[01][02] := TMPINV->PP
			EndIf

			TMPINV->( dbSkip() )
		EndDo
	Else
		oChart10:addSerie('Sem Contagem', { 0, 0, 0, 0, 0, 0, 0, 0 } )
	EndIf
	
	TMPINV->( dbCloseArea() )

	oChart10:EnableMenu(.F.)
	oChart10:SetChartDefault( NEWLINECHART )
	oChart10:Activate()

	// Gráfico 5 - Quantidade por Grupo
	cQuery := "SELECT Z83_GRUPO, SUM(Z83_QUANTI) AS QUANTIDADE " + CRLF
	cQuery += "FROM " + RetSqlName("Z83") + " AS Z83 " + CRLF
	cQuery += "WHERE Z83_FILIAL = '" + xFilial("Z83") + "' " + CRLF
	cQuery += "AND Z83_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
	cQuery += "AND Z83.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY Z83_GRUPO " + CRLF

	TCQuery cQuery New Alias "TMPINV"
	dbSelectArea("TMPINV")
	dbGoTop()

	oChart11 := FWChartPie():New()
	oChart11:init( oWin11, .t. )

	If !TMPINV->( Eof() )
		Do While !TMPINV->( Eof() )
			oChart11:addSerie( AllTrim( TMPINV->Z83_GRUPO ), TMPINV->QUANTIDADE )

			TMPINV->( dbSkip() )
		EndDo
	Else
		oChart11:addSerie( 'Sem Contagem', 0 )
	EndIf

	TMPINV->( dbCloseArea() )

	oChart11:setLegend( CONTROL_ALIGN_LEFT )
	oChart11:Build()

	// Gráfico 6 Quantidade de Fichas por Grupos
	cQuery := "SELECT Z82_GRUPO, SUM(PRICON) AS PRICON, SUM(SEGCON) AS SEGCON, SUM(TERCON) AS TERCON, SUM(TOTAL) AS TOTAL " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT Z82_GRUPO, " + CRLF
	cQuery += "       CASE WHEN Z82_CONTAG = '1' THEN 1 ELSE 0 END AS PRICON, " + CRLF
	cQuery += "       CASE WHEN Z82_CONTAG = '2' THEN 1 ELSE 0 END AS SEGCON, " + CRLF
	cQuery += "       CASE WHEN Z82_CONTAG = '3' THEN 1 ELSE 0 END AS TERCON, " + CRLF
	cQuery += "	   1 AS TOTAL " + CRLF
	cQuery += "FROM " + RetSqlName("Z82") + " AS Z82 " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("Z81") + " AS Z81 ON Z81_FILIAL = Z82_FILIAL " + CRLF
	cQuery += "  AND Z81_CODIGO = Z82_CODIGO " + CRLF
	cQuery += "  AND Z81_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
	cQuery += "  AND Z81.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE Z82_FILIAL = '" + xFilial("Z82") + "' " + CRLF
	cQuery += "AND Z82_FICHA BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' " + CRLF
	cQuery += "AND Z82_PRODUT BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' " + CRLF
	cQuery += "AND Z82_LOCAL BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' " + CRLF
	cQuery += "AND Z82.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY Z82_GRUPO, Z82_CONTAG " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF
	cQuery += "GROUP BY Z82_GRUPO " + CRLF

	TCQuery cQuery New Alias "TMPINV"
	dbSelectArea("TMPINV")
	dbGoTop()

	oChart12 := FWChartBarComp():New()
	oChart12:init( oWin12, .T. )

	If !TMPINV->( Eof() )
		Do While !TMPINV->( Eof() )
			oChart12:addSerie( AllTrim( TMPINV->Z82_GRUPO ), { {"1a Contagem", TMPINV->PRICON}, {"2a Contagem", TMPINV->SEGCON}, {"3a Contagem", TMPINV->TERCON}, {"Total", TMPINV->TOTAL} })

			TMPINV->( dbSkip() )
		EndDo
	Else
		oChart12:addSerie( "Sem Contagem" , { {"1a Contagem", 0}, {"2a Contagem", 0}, {"3a Contagem", 0}, {"Total", 0} })
	EndIf

	TMPINV->( dbCloseArea() )

	oChart12:setLegend( CONTROL_ALIGN_LEFT )
	oChart12:Build()

	// Gráfico 7 - Top 10 Desvios por Produtos
	cQuery := "SELECT TOP 10 Z83_PRODUT, B1_DESC, ABS(SUM(VALOR) - SUM(B2_VATU1)) AS DIFERENCA " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT Z83_PRODUT, B1_DESC, Z83_LOCAL, (Z83_QUANTI * ISNULL( B2_CM1, 0)) AS VALOR, ISNULL( B2_QATU, 0) AS B2_QATU, ISNULL( B2_VATU1, 0) AS B2_VATU1 " + CRLF
	cQuery += "FROM " + RetSqlName("Z83") + " AS Z83 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = Z83_PRODUT " + CRLF
//	cQuery += "  AND B1_TIPO IN ('MP','ME','EM','PA','PI','BN','SP','PP') " + CRLF
	cQuery += "  AND B1_TIPO IN (" + AllTrim( cTipoPrd ) + ") " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SX5") + " AS SX5 WITH (NOLOCK) ON X5_FILIAL = '  ' " + CRLF
	cQuery += "  AND X5_TABELA = '02' " + CRLF
	cQuery += "  AND X5_CHAVE = B1_TIPO " + CRLF
	cQuery += "  AND SX5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "LEFT JOIN " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) ON B2_FILIAL = Z83_FILIAL " + CRLF
	cQuery += "  AND B2_COD = Z83_PRODUT " + CRLF
	cQuery += "  AND B2_LOCAL = Z83_LOCAL " + CRLF
	cQuery += "  AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE Z83_FILIAL = '" + xFilial("Z83") + "' " + CRLF
	cQuery += "AND Z83_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
	cQuery += "AND Z83.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF
	cQuery += "GROUP BY Z83_PRODUT, B1_DESC " + CRLF
	cQuery += "ORDER BY ABS(SUM(VALOR) - SUM(B2_VATU1)) DESC " + CRLF

	TCQuery cQuery New Alias "TMPINV"
	dbSelectArea("TMPINV")
	dbGoTop()

	oChart13 := FWChartBar():New()
	oChart13:init( oWin13, .t., .t. )

	If !TMPINV->( Eof() )
		Do While !TMPINV->( Eof() )
			oChart13:addSerie( AllTrim( TMPINV->Z83_PRODUT ), TMPINV->DIFERENCA )

			TMPINV->( dbSkip() )
		EndDo
	Else
		oChart13:addSerie( "Sem Contagem", 0 )
	EndIf

	TMPINV->( dbCloseArea() )

	oChart13:setLegend( CONTROL_ALIGN_LEFT )
	oChart13:Build()

	// Gráfico 8 - Saldo Atual vs Saldo Apurado
	oChart14 := FWChartLine():New()
	oChart14:init( oWin14, .t. ) 

	oChart14:addSerie( "MP", { {"Saldo Atual", aApuMP[01][01]}, {"Saldo Apurado", aApuMP[01][02]} })
	oChart14:addSerie( "ME", { {"Saldo Atual", aApuME[01][01]}, {"Saldo Apurado", aApuME[01][02]} })
	oChart14:addSerie( "EM", { {"Saldo Atual", aApuEM[01][01]}, {"Saldo Apurado", aApuEM[01][02]} })
	oChart14:addSerie( "PA", { {"Saldo Atual", aApuPA[01][01]}, {"Saldo Apurado", aApuPA[01][02]} })
	oChart14:addSerie( "PI", { {"Saldo Atual", aApuPI[01][01]}, {"Saldo Apurado", aApuPI[01][02]} })
	oChart14:addSerie( "BN", { {"Saldo Atual", aApuBN[01][01]}, {"Saldo Apurado", aApuBN[01][02]} })
	oChart14:addSerie( "SP", { {"Saldo Atual", aApuSP[01][01]}, {"Saldo Apurado", aApuSP[01][02]} })
	oChart14:addSerie( "PP", { {"Saldo Atual", aApuPP[01][01]}, {"Saldo Apurado", aApuPP[01][02]} })

	oChart14:setLegend( CONTROL_ALIGN_LEFT )
	oChart14:Build()

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

Static Function ConsRet()

oBrowse1:Refresh()
oPnlTran1:Refresh()
oWin2:Refresh()
oBrowse2:Refresh()
oPnlTran2:Refresh()
oWin3:Refresh()
oBrowse3:Refresh()
oPnlTran3:Refresh()
oFWLayer:Refresh()

TCQuery cQryEqui New Alias "TMPEQUI"
dbSelectArea("TMPEQUI")
dbGoTop()

aAno    := {}
nFichas := 0
Do While !TMPEQUI->( Eof() )
	aAdd( aAno, {AllTrim( TMPEQUI->Z82_GRUPO ) + ' - ' + AllTrim( TMPEQUI->Z80_EQUIPE ), {"Inventário Geral: " + Left(DTOS( mv_par02 ), 4), TMPEQUI->CONTA}})
	nFichas += TMPEQUI->CONTA

	TMPEQUI->( dbSkip() )
EndDo

TMPEQUI->( dbCloseArea() )

oChart := FWChartBarComp():New()
oChart:init( oPnlTran4, .t. )
For nAno := 1 To Len( aAno )
	oChart:addSerie( aAno[nAno][1], { aAno[nAno][02] })
Next
oChart:Build()

oSayFicha:SetText( StrZero( nFichas, 4) )

aSts := {}
aAdd( aSts, {"Concluído"     , 0})
aAdd( aSts, {"Pendente"      , 0})
aAdd( aSts, {"Fazer Terceira", 0})

TCQuery cQryMon New Alias "TMPMON"
dbSelectArea("TMPMON")
dbGoTop()

Do While !TMPMON->( Eof() )
	If TMPMON->STSLEG == "1"
		aSts[1][2] += 1
	ElseIf TMPMON->STSLEG == "2"
		aSts[2][2] += 1
	ElseIf TMPMON->STSLEG == "3"
		aSts[3][2] += 1
	EndIf

	TMPMON->( dbSkip() )
EndDo

TMPMON->( dbCloseArea() )

oChart1 := FWChartPie():New()
oChart1:init( oPnlTran5, .t. )

For nSts := 1 To Len(aSts)
	oChart1:addSerie( aSts[nSts][1], aSts[nSts][2] )
Next

oChart1:Build()

Return Nil

Static Function ValidPerg()

Local aArea := GetArea()
Local aPerg := {}

aAdd(aPerg, {cPerg, "01", "Da Dt. Inventário  ?", "MV_CH1" , 	"D", 08	, 0	, "G"	, "MV_PAR01", ""	,""		,""				,""				,"",""})
aAdd(aPerg, {cPerg, "02", "Até Dt. Inventário ?", "MV_CH2" , 	"D", 08	, 0	, "G"	, "MV_PAR02", ""	,""		,""				,""				,"",""})
aAdd(aPerg, {cPerg, "03", "Da Ficha           ?", "MV_CH3" , 	"C", 06	, 0	, "G"	, "MV_PAR03", ""	,""		,""				,""				,"",""})
aAdd(aPerg, {cPerg, "04", "Até a Ficha        ?", "MV_CH4" , 	"C", 06	, 0	, "G"	, "MV_PAR04", ""	,""		,""				,""				,"",""})
aAdd(aPerg, {cPerg, "05", "Do Produto         ?", "MV_CH5" , 	"C", 15	, 0	, "G"	, "MV_PAR05", "SB1"	,""		,""				,""				,"",""})
aAdd(aPerg, {cPerg, "06", "Até o Produto      ?", "MV_CH6" , 	"C", 15	, 0	, "G"	, "MV_PAR06", "SB1"	,""		,""				,""				,"",""})
aAdd(aPerg, {cPerg, "07", "Do Local           ?", "MV_CH7" , 	"C", 02	, 0	, "G"	, "MV_PAR07", "NNR"	,""		,""				,""				,"",""})
aAdd(aPerg, {cPerg, "08", "Até o Local        ?", "MV_CH8" , 	"C", 02	, 0	, "G"	, "MV_PAR08", "NNR"	,""		,""				,""				,"",""})

DbSelectArea("SX1")
DbSetOrder(1)

For i := 1 To Len(aPerg)
	IF  !DbSeek(aPerg[i,1]+aPerg[i,2])
		RecLock("SX1",.T.)
	Else
		RecLock("SX1",.F.)
	EndIF
	Replace X1_GRUPO   with aPerg[i,01]
	Replace X1_ORDEM   with aPerg[i,02]
	Replace X1_PERGUNT with aPerg[i,03]
	Replace X1_VARIAVL with aPerg[i,04]
	Replace X1_TIPO	   with aPerg[i,05]
	Replace X1_TAMANHO with aPerg[i,06]
	Replace X1_PRESEL  with aPerg[i,07]
	Replace X1_GSC	   with aPerg[i,08]
	Replace X1_VAR01   with aPerg[i,09]
	Replace X1_F3	   with aPerg[i,10]
	Replace X1_DEF01   with aPerg[i,11]
	Replace X1_DEF02   with aPerg[i,12]
	Replace X1_DEF03   with aPerg[i,13]
	Replace X1_DEF04   with aPerg[i,14]
	Replace X1_DEF05   with aPerg[i,15]
	MsUnlock()
Next i

RestArea(aArea)

Return(.T.)

Static Function fBackup()

Local lValida := .T.

// Valida se há ocorrências na apuração
cQuery := "SELECT COUNT(*) AS CONTA " + CRLF
cQuery += "FROM " + RetSqlName("Z83") + " AS Z83 " + CRLF
cQuery += "WHERE Z83_FILIAL = '" + xFilial("Z83") + "' " + CRLF
cQuery += "AND Z83_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
cQuery += "AND Z83_STATUS = '2' " + CRLF
cQuery += "AND Z83.D_E_L_E_T_ = ' ' " + CRLF

TCQuery cQuery New Alias "TMPINV"
dbSelectArea("TMPINV")
dbGoTop()

If !TMPINV->( Eof() ) .And. TMPINV->CONTA > 0
	lValida := .F.
	ApMsgAlert( "Há ocorrências na apuração, backup não pode ser gerado!", "Atenção" )
EndIf

TMPINV->( dbCloseArea() )

// Valida se há ocorrências na apuração
cQuery := "SELECT COUNT(*) AS CONTA " + CRLF
cQuery += "FROM " + RetSqlName("Z83") + " AS Z83 " + CRLF
cQuery += "WHERE Z83_FILIAL = '" + xFilial("Z83") + "' " + CRLF
cQuery += "AND Z83_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
cQuery += "AND Z83_STATUS = '3' " + CRLF
cQuery += "AND Z83.D_E_L_E_T_ = ' ' " + CRLF

TCQuery cQuery New Alias "TMPINV"
dbSelectArea("TMPINV")
dbGoTop()

If !TMPINV->( Eof() ) .And. TMPINV->CONTA > 0
	lValida := .F.
	ApMsgAlert( "Inventário já processado e gerado SB7!", "Atenção" )
EndIf

TMPINV->( dbCloseArea() )

If lValida
	// Drop backup se já existir...
	cQuery := "DROP TABLE " + RetSqlName("SB2") + "_BKP_" + DTOS( mv_par02 ) + "_" + xFilial("SB2") + " "
	TCSqlExec( cQuery )
	cQuery := "DROP TABLE " + RetSqlName("SB8") + "_BKP_" + DTOS( mv_par02 ) + "_" + xFilial("SB8") + " "
	TCSqlExec( cQuery )
	cQuery := "DROP TABLE " + RetSqlName("SBF") + "_BKP_" + DTOS( mv_par02 ) + "_" + xFilial("SBF") + " "
	TCSqlExec( cQuery )

	cQuery := "SELECT * INTO " + RetSqlName("SB2") + "_BKP_" + DTOS( mv_par02 ) + "_" + xFilial("SB2") + " FROM " + RetSqlName("SB2") + " WHERE B2_FILIAL = '" + xFilial("SB2") + "' AND D_E_L_E_T_ = ' '"
	TCSqlExec( cQuery )
	cQuery := "SELECT * INTO " + RetSqlName("SB8") + "_BKP_" + DTOS( mv_par02 ) + "_" + xFilial("SB8") + " FROM " + RetSqlName("SB8") + " WHERE B8_FILIAL = '" + xFilial("SB8") + "' AND D_E_L_E_T_ = ' '"
	TCSqlExec( cQuery )
	cQuery := "SELECT * INTO " + RetSqlName("SBF") + "_BKP_" + DTOS( mv_par02 ) + "_" + xFilial("SBF") + " FROM " + RetSqlName("SBF") + " WHERE BF_FILIAL = '" + xFilial("SBF") + "' AND D_E_L_E_T_ = ' '"
	TCSqlExec( cQuery )

	ApMsgInfo( "Backup realizado com sucesso!!!" )
EndIf

Return

Static Function fGeraSB7()

Local lValida := .T.

// Valida se há ocorrências na apuração
cQuery := "SELECT COUNT(*) AS CONTA " + CRLF
cQuery += "FROM " + RetSqlName("Z83") + " AS Z83 " + CRLF
cQuery += "WHERE Z83_FILIAL = '" + xFilial("Z83") + "' " + CRLF
cQuery += "AND Z83_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
cQuery += "AND Z83_STATUS = '2' " + CRLF
cQuery += "AND Z83.D_E_L_E_T_ = ' ' " + CRLF

TCQuery cQuery New Alias "TMPINV"
dbSelectArea("TMPINV")
dbGoTop()

If !TMPINV->( Eof() ) .And. TMPINV->CONTA > 0
	lValida := .F.
	ApMsgAlert( "Há ocorrências na apuração, backup não pode ser gerado!", "Atenção" )
EndIf

TMPINV->( dbCloseArea() )

// Valida se há ocorrências na apuração
cQuery := "SELECT COUNT(*) AS CONTA " + CRLF
cQuery += "FROM " + RetSqlName("Z83") + " AS Z83 " + CRLF
cQuery += "WHERE Z83_FILIAL = '" + xFilial("Z83") + "' " + CRLF
cQuery += "AND Z83_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
cQuery += "AND Z83_STATUS = '3' " + CRLF
cQuery += "AND Z83.D_E_L_E_T_ = ' ' " + CRLF

TCQuery cQuery New Alias "TMPINV"
dbSelectArea("TMPINV")
dbGoTop()

If !TMPINV->( Eof() ) .And. TMPINV->CONTA > 0
	lValida := .F.
	ApMsgAlert( "Inventário já processado e gerado SB7!", "Atenção" )
EndIf

TMPINV->( dbCloseArea() )

// Valida se houve apuração correta
cQuery := "SELECT COUNT(*) AS CONTA " + CRLF
cQuery += "FROM " + RetSqlName("Z83") + " AS Z83 " + CRLF
cQuery += "WHERE Z83_FILIAL = '" + xFilial("Z83") + "' " + CRLF
cQuery += "AND Z83_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
cQuery += "AND Z83_STATUS = '1' " + CRLF
cQuery += "AND Z83.D_E_L_E_T_ = ' ' " + CRLF

TCQuery cQuery New Alias "TMPINV"
dbSelectArea("TMPINV")
dbGoTop()

If !TMPINV->( Eof() ) .And. TMPINV->CONTA == 0
	lValida := .F.
	ApMsgAlert( "Não há apuração válida para processamento!", "Atenção" )
EndIf

TMPINV->( dbCloseArea() )

/*
// Valida se foi feito backup
cQuery := "SELECT COUNT(*) AS CONTA " + CRLF
cQuery += "FROM INFORMATION_SCHEMA.TABLES " + CRLF
cQuery += "WHERE TABLE_NAME = '" + RetSqlName("SB2") + "_BKP_" + DTOS( mv_par02 ) + "_" + xFilial("SB2") + "' " + CRLF

TCQuery cQuery New Alias "TMPINV"
dbSelectArea("TMPINV")
dbGoTop()

If !TMPINV->( Eof() ) .And. TMPINV->CONTA > 0
	lValida := .F.
	ApMsgAlert( "Backup não efetuado para o período apurado!", "Atenção" )
EndIf

TMPINV->( dbCloseArea() )
*/

If lValida
	cQuery := "SELECT * " + CRLF
	cQuery += "FROM " + RetSqlName("Z83") + " AS Z83 " + CRLF
	cQuery += "WHERE Z83_FILIAL = '" + xFilial("Z83") + "' " + CRLF
	cQuery += "AND Z83_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
	cQuery += "AND Z83_STATUS = '1' " + CRLF
	cQuery += "AND Z83.D_E_L_E_T_ = ' ' " + CRLF
	
	TCQuery cQuery New Alias "TMPINV"
	dbSelectArea("TMPINV")
	dbGoTop()
	
	Do While !TMPINV->( Eof() )
		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->( dbSeek( xFilial("SB1") + TMPINV->Z83_PRODUT ) )
			RecLock("SB7", .T.)
				SB7->B7_FILIAL  := xFilial("SB7")
				SB7->B7_DOC     := TMPINV->Z83_FICHA
				SB7->B7_COD     := TMPINV->Z83_PRODUT
				SB7->B7_TIPO    := SB1->B1_TIPO
				SB7->B7_QUANT   := TMPINV->Z83_QUANTI
				SB7->B7_QTSEGUM := ConvUM( SB1->B1_COD, TMPINV->Z83_QUANTI, 0, 2)
				SB7->B7_ESCOLHA := "S"
				SB7->B7_STATUS  := "1"
				SB7->B7_LOCAL   := TMPINV->Z83_LOCAL
				SB7->B7_LOTECTL := TMPINV->Z83_LOTECT
				If SB1->B1_RASTRO <> "N"
					If !Empty( TMPINV->Z83_LOTECT )
						dbSelectArea("SB8")
						dbSetOrder(3)
						If SB8->( dbSeek( xFilial("SB8") + TMPINV->Z83_PRODUT + TMPINV->Z83_LOCAL + TMPINV->Z83_LOTECT ) )
							SB7->B7_NUMDOC  := SB8->B8_DOC
							SB7->B7_DTVALID := SB8->B8_DTVALID
							SB7->B7_NUMDOC  := SB8->B8_DOC
							SB7->B7_NUMLOTE := SB8->B8_NUMLOTE
							SB7->B7_FORNECE := SB8->B8_CLIFOR
							SB7->B7_LOJA    := SB8->B8_LOJA
						EndIf
					EndIf
				EndIf
				If AllTrim( SB1->B1_LOCALIZ ) == "S"
					SB7->B7_LOCALIZ := TMPINV->Z83_LOCALI
				EndIf
				//SB7->B7_OBS     := "INVENTARIO GERAL: " + DTOC( mv_par02 )
				SB7->B7_CONTAGE := "001"
				SB7->B7_ORIGEM  := "MATA270"
				SB7->B7_DATA    := mv_par02
			MsUnLock()
		EndIf

		cQuery := "UPDATE " + RetSqlName("Z83") + " SET Z83_STATUS = '3' " + CRLF
		cQuery += "WHERE Z83_FILIAL = '" + xFilial("Z83") + "' " + CRLF
		cQuery += "AND Z83_FICHA = '" + TMPINV->Z83_FICHA + "' " + CRLF
		cQuery += "AND Z83_PRODUT = '" + TMPINV->Z83_PRODUT + "' " + CRLF
		cQuery += "AND Z83_LOCAL = '" + TMPINV->Z83_LOCAL + "' " + CRLF
		cQuery += "AND Z83_LOTECT = '" + TMPINV->Z83_LOTECT + "' " + CRLF
		cQuery += "AND Z83_LOCALI = '" + TMPINV->Z83_LOCALI + "' " + CRLF
		cQuery += "AND Z83_DATA = '" + TMPINV->Z83_DATA + "' " + CRLF
		cQuery += "AND D_E_L_E_T_ = ' ' " + CRLF

		TCSqlExec( cQuery )

		TMPINV->( dbSkip() )
	EndDo
	
	TMPINV->( dbCloseArea() )
EndIf

Return

Static Function fImprimir()

Local oChart
Local oDlg
Local aAno         := {}
Local nAno         := 0
Local cQuery       := ""
Local cNomeRel     := "Rel_BeBarAno_"+dToS(Date())+StrTran(Time(), ':', '-')
Local cDiretorio   := "c:\temp\" // GetTempPath()
Local nLinCab      := 025
Local nAltur       := 540 //250  (550,800)
Local nLargur      := 800 //1050

Private _cRotina   := "EQINTZ8401"
Private cHoraEx    := Time()
Private nPagAtu    := 1
Private oPrintPvt
Private cNomeFont  := "Arial"
Private oFontRod   := TFont():New(cNomeFont, , -06, , .F.)
Private oFontTit   := TFont():New(cNomeFont, , -20, , .T.)
Private oFontSubN  := TFont():New(cNomeFont, , -17, , .T.)
Private oFont07n   := TFont():New( "Arial",, 07,,.T.)
Private oFont06    := TFont():New( "Courier New",, 06,,.F.)
Private oBrush     := TBrush():New(,CLR_CYAN,,)
Private nLinAtu     := 0
Private nLinFin     := 820
Private nColIni     := 010
Private nColFin     := 550
Private nColMeio    := (nColFin-nColIni)/2

//Criando o objeto de impressão
oPrintPvt := FWMSPrinter():New(cNomeRel, IMP_PDF, .F., /*cStartPath*/, .T., , @oPrintPvt, , , , , .T.)
oPrintPvt:cPathPDF := GetTempPath()
oPrintPvt:SetResolution(72)
//oPrintPvt:SetLandscape()
oPrintPvt:SetPortrait()
oPrintPvt:SetPaperSize(DMPAPER_A4)
oPrintPvt:SetMargin(60, 60, 60, 60)
oPrintPvt:StartPage()

//Cabeçalho
oPrintPvt:SayAlign(nLinCab, nColIni /*nColMeio-150*/, "Gráfico de Barras Anual de Despesas", oFontTit, 550, 20, , PAD_LEFT, 0)

nLinCab += 35
oPrintPvt:Line(nLinCab, nColIni, nLinCab, nColFin, RGB(200, 200, 200))

oPrintPvt:SayAlign(nLinCab+=10, nColIni, "Parâmetros", oFontSubN, 450, 20, , PAD_LEFT, 0)
nLinCab += 10
//oPrintPvt:SayAlign(nLinCab+=10, nColIni, "Ano de  ? " + mv_par01      , oFontRod , 450, 20, , PAD_LEFT, 0)
//oPrintPvt:SayAlign(nLinCab+=10, nColIni, "Ano até ? " + mv_par02      , oFontRod , 450, 20, , PAD_LEFT, 0)

nLinCab += 15
oPrintPvt:Line(nLinCab, nColIni, nLinCab, nColFin, RGB(200, 200, 200))

nLinCab += 35
nLinAtu := nLinCab

//Se o arquivo existir, exclui ele
If File(cDiretorio+"_grafico1.png")
	FErase(cDiretorio+"_grafico1.png")
EndIf

//oChart14:SaveToPng(0, 0, nLargur, nAltur, cDiretorio+"_grafico.png")
oChart14:saveToPng(4,4,1000,340,cDiretorio+"_grafico1.png")
    
oPrintPvt:SayBitmap(nLinAtu, nColIni, cDiretorio+"_grafico1.png", nLargur/2, nAltur/1.6)
//nLinAtu += nAltur/1.6 + 3


//Impressão do Rodapé
fImpRod()

//Gera o pdf para visualização
oPrintPvt:Preview()

Return

Static Function fImpRod()

Local nLinRod := nLinFin + 10
Local cTexto  := ""

//Linha Separatória
oPrintPvt:Line(nLinRod, nColIni, nLinRod, nColFin, RGB(200, 200, 200))
nLinRod += 3

//Dados da Esquerda
cTexto := "Relatório Gráfico de Barras Anual de Despesas Consumidas com o Cartão Corporativo | "+dToC(dDataBase)+" "+cHoraEx+" | "+FunName()+" | "+cUserName
oPrintPvt:SayAlign(nLinRod, nColIni, cTexto, oFontRod, 450, 07, , PAD_LEFT, )

//Direita
cTexto := "Página "+cValToChar(nPagAtu)
oPrintPvt:SayAlign(nLinRod, nColFin-40, cTexto, oFontRod, 040, 07, , PAD_RIGHT, )

//Finalizando a página e somando mais um
oPrintPvt:EndPage()
nPagAtu++

Return

Static Function CabPrIt(nLin,nCol)

oPrintPvt:FillRect({nLin,nCol+000,nLin + 12,nCol+067},oBrush)
oPrintPvt:FillRect({nLin,nCol+068,nLin + 12,nCol+107},oBrush)
oPrintPvt:FillRect({nLin,nCol+108,nLin + 12,nCol+147},oBrush)
oPrintPvt:FillRect({nLin,nCol+148,nLin + 12,nCol+187},oBrush)
oPrintPvt:FillRect({nLin,nCol+188,nLin + 12,nCol+227},oBrush)
oPrintPvt:FillRect({nLin,nCol+228,nLin + 12,nCol+267},oBrush)
oPrintPvt:FillRect({nLin,nCol+268,nLin + 12,nCol+307},oBrush)
oPrintPvt:FillRect({nLin,nCol+308,nLin + 12,nCol+347},oBrush)
oPrintPvt:FillRect({nLin,nCol+348,nLin + 12,nCol+387},oBrush)
oPrintPvt:FillRect({nLin,nCol+388,nLin + 12,nCol+427},oBrush)
oPrintPvt:FillRect({nLin,nCol+428,nLin + 12,nCol+467},oBrush)
oPrintPvt:FillRect({nLin,nCol+468,nLin + 12,nCol+507},oBrush)
oPrintPvt:FillRect({nLin,nCol+508,nLin + 12,nCol+550},oBrush)

nLin += 008
oPrintPvt:Say(nLin-001	,nCol+005	,"Ano"		 							,oFont07n,,CLR_WHITE)
oPrintPvt:Say(nLin-001	,nCol+070	,"Jan"		  							,oFont07n,,CLR_WHITE)
oPrintPvt:Say(nLin-001	,nCol+110	,"Fev"									,oFont07n,,CLR_WHITE)
oPrintPvt:Say(nLin-001	,nCol+150	,"Mar"									,oFont07n,,CLR_WHITE)
oPrintPvt:Say(nLin-001	,nCol+190	,"Abr"									,oFont07n,,CLR_WHITE)
oPrintPvt:Say(nLin-001	,nCol+230	,"Mai"									,oFont07n,,CLR_WHITE)
oPrintPvt:Say(nLin-001	,nCol+270	,"Jun"									,oFont07n,,CLR_WHITE)
oPrintPvt:Say(nLin-001	,nCol+310	,"Jul"		  							,oFont07n,,CLR_WHITE)
oPrintPvt:Say(nLin-001	,nCol+350	,"Ago"									,oFont07n,,CLR_WHITE)
oPrintPvt:Say(nLin-001	,nCol+390	,"Set"									,oFont07n,,CLR_WHITE)
oPrintPvt:Say(nLin-001	,nCol+430	,"Out"									,oFont07n,,CLR_WHITE)
oPrintPvt:Say(nLin-001	,nCol+470	,"Nov"									,oFont07n,,CLR_WHITE)
oPrintPvt:Say(nLin-001	,nCol+510	,"Dez"									,oFont07n,,CLR_WHITE)

nLin += 002

Return nLin
