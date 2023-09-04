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

User Function EQMonInv()

Local aArea         := GetArea()

Private lRetorno    := .T.
Private lValido     := .T.
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
Private aEmpresa    := {}
Private nEmp        := 1

ValidPerg()

If !Pergunte( cPerg, .T.)
	ApMsgAlert( 'Processamento Cancelado!', 'Atenção')
	Return
EndIf

If AllTrim( cEmpAnt ) + AllTrim( cFilAnt ) $ "0107|0200|0803|0901"
	dbSelectArea("Z86")
	dbSetOrder(1)
	dbGoTop()
	Do Case
		Case AllTrim( cEmpAnt ) + AllTrim( cFilAnt ) == "0107"
			If AllTrim( Z86->Z86_0107 ) <> "S"
				lValido := .F.
				Help( ,, "EQDIGVLEMP",, "Empresa ou filial não habilitada para contagem do inventário, Verifique!", 1, 0 )
			Else
				aAdd( aEmpresa, { "01", "07" })
			EndIf
		Case AllTrim( cEmpAnt ) + AllTrim( cFilAnt ) == "0200"
			If AllTrim( Z86->Z86_0200 ) <> "S"
				lValido := .F.
				Help( ,, "EQDIGVLEMP",, "Empresa ou filial não habilitada para contagem do inventário, Verifique!", 1, 0 )
			Else
				aAdd( aEmpresa, { "02", "00" })
			EndIf
		Case AllTrim( cEmpAnt ) + AllTrim( cFilAnt ) == "0803"
			If AllTrim( Z86->Z86_0803 ) <> "S"
				lValido := .F.
				Help( ,, "EQDIGVLEMP",, "Empresa ou filial não habilitada para contagem do inventário, Verifique!", 1, 0 )
			Else
				aAdd( aEmpresa, { "08", "03" })
			EndIf
		Case AllTrim( cEmpAnt ) + AllTrim( cFilAnt ) == "0901"
			If AllTrim( Z86->Z86_0901 ) <> "S"
				lValido := .F.
				Help( ,, "EQDIGVLEMP",, "Empresa ou filial não habilitada para contagem do inventário, Verifique!", 1, 0 )
			Else
				aAdd( aEmpresa, { "09", "01" })
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

cQryMon := "SELECT Z82_FICHA, Z82_PRODUT, Z82_LOCAL, Z82_LOTECT, MAX(Z82_CONTAG) AS ULTCON, Z81_STATUS, " + CRLF
cQryMon += "       SUM(QTDCONT) AS QTDCONT, SUM(QTDCON1) AS QTDCON1, SUM(QTDCON2) AS QTDCON2, SUM(QTDCON3) AS QTDCON3, " + CRLF
cQryMon += "	   CASE WHEN SUM(QTDCONT) = 1 THEN 'Pendente' ELSE " + CRLF
cQryMon += "	   CASE WHEN SUM(QTDCONT) = 3 THEN 'Liberado' ELSE " + CRLF
cQryMon += "	   CASE WHEN SUM(QTDCONT) = 2 AND SUM(QTDCON1) <> SUM(QTDCON2) THEN 'Não Bateu' ELSE 'Liberado' END END END AS STSCONTAGE, " + CRLF
cQryMon += "	   CASE WHEN SUM(QTDCONT) = 1 THEN '2' ELSE " + CRLF
cQryMon += "	   CASE WHEN SUM(QTDCONT) = 3 THEN '1' ELSE " + CRLF
cQryMon += "	   CASE WHEN SUM(QTDCONT) = 2 AND SUM(QTDCON1) <> SUM(QTDCON2) THEN '3' ELSE '1' END END END AS STSLEG " + CRLF
cQryMon += "FROM (" + CRLF
cQryMon += "SELECT Z82_FICHA, Z82_PRODUT, Z82_LOCAL, Z82_LOTECT, COUNT(*) AS QTDCONT, Z81_STATUS, " + CRLF
cQryMon += "       Z82_CONTAG, MAX(Z82.R_E_C_N_O_) AS MAXREC, " + CRLF
cQryMon += "	   CASE WHEN Z82_CONTAG = '1' THEN SUM(Z82_QUANT) ELSE 0 END AS QTDCON1, " + CRLF
cQryMon += "	   CASE WHEN Z82_CONTAG = '2' THEN SUM(Z82_QUANT) ELSE 0 END AS QTDCON2, " + CRLF
cQryMon += "	   CASE WHEN Z82_CONTAG = '3' THEN SUM(Z82_QUANT) ELSE 0 END AS QTDCON3 " + CRLF
cQryMon += "FROM " + RetSqlName("Z81") + " AS Z81 " + CRLF
cQryMon += "INNER JOIN " + RetSqlName("Z82") + " AS Z82 ON Z82_FILIAL = Z81_FILIAL " + CRLF
cQryMon += "  AND Z82_CODIGO = Z81_CODIGO " + CRLF
cQryMon += "  AND Z82_FICHA BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' " + CRLF
cQryMon += "  AND Z82_PRODUT BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' " + CRLF
cQryMon += "  AND Z82_LOCAL BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' " + CRLF
cQryMon += "  AND Z82.D_E_L_E_T_ = ' ' " + CRLF
cQryMon += "WHERE Z81_FILIAL = '" + xFilial("Z81") + "' " + CRLF
cQryMon += "AND Z81_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
cQryMon += "AND Z81.D_E_L_E_T_ = ' ' " + CRLF
cQryMon += "GROUP BY Z82_FICHA, Z82_PRODUT, Z82_LOCAL, Z82_LOTECT, Z82_CONTAG, Z81_STATUS " + CRLF
cQryMon += ") AS AGRUPADO " + CRLF
cQryMon += "GROUP BY Z82_FICHA, Z82_PRODUT, Z82_LOCAL, Z82_LOTECT, Z81_STATUS " + CRLF
cQryMon += "ORDER BY MAX(MAXREC) DESC " + CRLF

cQryTer := "SELECT Z82_FICHA, Z82_PRODUT, Z82_LOCAL, Z82_LOTECT, MAX(Z82_CONTAG) AS ULTCON, " + CRLF
cQryTer += "       SUM(QTDCONT) AS QTDCONT, SUM(QTDCON1) AS QTDCON1, SUM(QTDCON2) AS QTDCON2 " + CRLF
cQryTer += "FROM (" + CRLF
cQryTer += "SELECT Z82_FICHA, Z82_PRODUT, Z82_LOCAL, Z82_LOTECT, COUNT(*) AS QTDCONT, " + CRLF
cQryTer += "       Z82_CONTAG, MAX(Z82.R_E_C_N_O_) AS MAXREC, " + CRLF
cQryTer += "	   CASE WHEN Z82_CONTAG = '1' THEN SUM(Z82_QUANT) ELSE 0 END AS QTDCON1, " + CRLF
cQryTer += "	   CASE WHEN Z82_CONTAG = '2' THEN SUM(Z82_QUANT) ELSE 0 END AS QTDCON2, " + CRLF
cQryTer += "	   CASE WHEN Z82_CONTAG = '3' THEN SUM(Z82_QUANT) ELSE 0 END AS QTDCON3 " + CRLF
cQryTer += "FROM " + RetSqlName("Z81") + " AS Z81 " + CRLF
cQryTer += "INNER JOIN " + RetSqlName("Z82") + " AS Z82 ON Z82_FILIAL = Z81_FILIAL " + CRLF
cQryTer += "  AND Z82_CODIGO = Z81_CODIGO " + CRLF
cQryTer += "  AND Z82_FICHA BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' " + CRLF
cQryTer += "  AND Z82_PRODUT BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' " + CRLF
cQryTer += "  AND Z82_LOCAL BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' " + CRLF
cQryTer += "  AND Z82.D_E_L_E_T_ = ' ' " + CRLF
cQryTer += "WHERE Z81_FILIAL = '" + xFilial("Z81") + "' " + CRLF
cQryTer += "AND Z81_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
cQryTer += "AND Z81.D_E_L_E_T_ = ' ' " + CRLF
cQryTer += "GROUP BY Z82_FICHA, Z82_PRODUT, Z82_LOCAL, Z82_LOTECT, Z82_CONTAG " + CRLF
cQryTer += ") AS AGRUPADO " + CRLF
cQryTer += "GROUP BY Z82_FICHA, Z82_PRODUT, Z82_LOCAL, Z82_LOTECT " + CRLF
cQryTer += "HAVING SUM(QTDCONT) = 2 AND SUM(QTDCON1) <> SUM(QTDCON2) " + CRLF
cQryTer += "ORDER BY MAX(MAXREC) DESC " + CRLF

cQryEqui := "SELECT Z82_GRUPO, Z80_EQUIPE, COUNT(*) AS CONTA " + CRLF
cQryEqui += "FROM " + RetSqlName("Z82") + " AS Z82 WITH (NOLOCK) " + CRLF
cQryEqui += "INNER JOIN " + RetSqlName("Z81") + " AS Z81 WITH (NOLOCK) ON Z81_FILIAL = Z82_FILIAL " + CRLF
cQryEqui += "  AND Z81_CODIGO = Z82_CODIGO " + CRLF
cQryEqui += "  AND Z81_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
cQryEqui += "  AND Z81.D_E_L_E_T_ = ' ' " + CRLF
cQryEqui += "INNER JOIN " + RetSqlName("Z80") + " AS Z80 WITH (NOLOCK) ON Z80_FILIAL = Z82_FILIAL " + CRLF
cQryEqui += "  AND Z80_CODIGO = Z82_GRUPO " + CRLF
cQryEqui += "  AND Z80.D_E_L_E_T_ = ' ' " + CRLF
cQryEqui += "WHERE Z82_FILIAL = '" + xFilial("Z82") + "' " + CRLF
cQryEqui += "AND Z82_FICHA BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' " + CRLF
cQryEqui += "AND Z82_PRODUT BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' " + CRLF
cQryEqui += "AND Z82_LOCAL BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' " + CRLF
cQryEqui += "AND Z82.D_E_L_E_T_ = ' ' " + CRLF
cQryEqui += "GROUP BY Z82_GRUPO, Z80_EQUIPE " + CRLF
cQryEqui += "ORDER BY Z82_GRUPO, Z80_EQUIPE " + CRLF

cQryFal := "SELECT B2_COD, B2_LOCAL, '' AS B2_LOTECTL, '' AS B2_ENDERE, B2_QATU, " + CRLF
cQryFal += "       CASE WHEN B1_RASTRO = 'N' THEN 'Não Controla' ELSE 'Controla Lote' END AS RASTRO, " + CRLF
cQryFal += "	   CASE WHEN B1_LOCALIZ = 'N' THEN 'Não' ELSE 'Sim' END AS ENDERECO, " + CRLF
cQryFal += "	   CASE WHEN B1_MSBLQL = '1' THEN 'Sim' ELSE 'Não' END AS BLOQ " + CRLF
cQryFal += "FROM " + RetSqlName("SB2") + " AS SB2 " + CRLF
cQryFal += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
cQryFal += "  AND B1_COD = B2_COD " + CRLF
//cQryFal += "  AND B1_MSBLQL <> '1' " + CRLF
//cQryFal += "  AND B1_RASTRO = 'N' " + CRLF
//cQryFal += "  AND B1_LOCALIZ = 'N' " + CRLF
//cQryFal += "  AND B1_TIPO IN ('MP','ME','EM','PA','PI','BN','SP','PP') " + CRLF
cQryFal += "  AND B1_TIPO IN (" + AllTrim( cTipoPrd ) + ") " + CRLF
cQryFal += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQryFal += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
cQryFal += "AND B2_COD BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' " + CRLF
cQryFal += "AND B2_LOCAL BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' " + CRLF
cQryFal += "AND B2_QATU <> 0 " + CRLF
cQryFal += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("Z82") + " AS Z82 INNER JOIN " + RetSqlName("Z81") + " AS Z81 ON Z81_FILIAL = Z82_FILIAL AND Z81_CODIGO = Z82_CODIGO AND Z81_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' AND Z81.D_E_L_E_T_ = ' ' WHERE Z82_FILIAL = B2_FILIAL AND Z82_PRODUT = B2_COD AND Z82_LOCAL = B2_LOCAL AND Z82.D_E_L_E_T_ = ' ') " + CRLF
cQryFal += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
cQryFal += "ORDER BY B2_COD, B2_LOCAL " + CRLF

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
Local oTimeEmp  := Nil
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

	oFWLayer:AddCollumn( "Col01", 12, .T. )
	oFWLayer:AddCollumn( "Col02", 44, .T. )
	oFWLayer:AddCollumn( "Col03", 44, .T. )

	oFWLayer:AddWindow( "Col01","Win01"	, "Ações"                     		,025, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oFWLayer:AddWindow( "Col01","Win06"	, "Legenda"                   		,025, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oFWLayer:AddWindow( "Col01","Win07"	, "Status Inventário"	          	,025, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oFWLayer:AddWindow( "Col01","Win08"	, "Fichas Digitadas"	          	,025, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oFWLayer:AddWindow( "Col02","Win02" , "Status das Contagens das Fichas"	,050, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oFWLayer:AddWindow( "Col02","Win03" , "Itens sem Contagens"				,050, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oFWLayer:AddWindow( "Col03","Win04" , "Necessita de Terceira Contagem"	,050, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oFWLayer:AddWindow( "Col03","Win05" , "Gráfico de Equipes"				,040, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oFWLayer:AddWindow( "Col03","Win09" , "Empresa / Filial"				,010, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )

	oWin1 := oFWLayer:GetWinPanel( 'Col01','Win01' )
	oWin2 := oFWLayer:GetWinPanel( 'Col02','Win02' )
	oWin3 := oFWLayer:GetWinPanel( 'Col02','Win03' )
	oWin4 := oFWLayer:GetWinPanel( 'Col03','Win04' )
	oWin5 := oFWLayer:GetWinPanel( 'Col03','Win05' )
	oWin6 := oFWLayer:GetWinPanel( 'Col01','Win06' )
	oWin7 := oFWLayer:GetWinPanel( 'Col01','Win07' )
	oWin8 := oFWLayer:GetWinPanel( 'Col01','Win08' )
	oWin9 := oFWLayer:GetWinPanel( 'Col03','Win09' )

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
	@ 016,005 BITMAP oBmp RESNAME "BR_AMARELO"	SIZE 16,16 NOBORDER OF oWin6 PIXEL
	@ 024,005 BITMAP oBmp RESNAME "BR_AZUL"		SIZE 16,16 NOBORDER OF oWin6 PIXEL
	@ 000, 015 SAY oSay PROMPT "Concluído"		SIZE 080, 007 OF oWin6 COLORS 0, 16777215 PIXEL FONT oFontLeg
	@ 008, 015 SAY oSay PROMPT "Pendente"		SIZE 080, 007 OF oWin6 COLORS 0, 16777215 PIXEL FONT oFontLeg
	@ 016, 015 SAY oSay PROMPT "Fazer Terceira"	SIZE 080, 007 OF oWin6 COLORS 0, 16777215 PIXEL FONT oFontLeg
	@ 024, 015 SAY oSay PROMPT "Apurado"		SIZE 080, 007 OF oWin6 COLORS 0, 16777215 PIXEL FONT oFontLeg

	//Painel esquerdo da tela principal
	@ 000, 000 MSPANEL oPnlTran1	SIZE 300, 000 OF oWin2 COLORS 0, 16777215
	oPnlTran1:Align	:=  CONTROL_ALIGN_ALLCLIENT

	//Browse
	oBrowse1 := FWBrowse():New(oPnlTran1)        
	oBrowse1:SetDataQuery(.T.)
	oBrowse1:SetQuery(cQryMon)
	oBrowse1:SetQueryIndex({"Z82_FICHA+Z82_PRODUT+Z82_LOCAL+Z82_LOTECT"})
	oBrowse1:SetAlias("TMP1")              
	oBrowse1:SetUniqueKey({"Z82_FICHA","Z82_PRODUT","Z82_LOCAL","Z82_LOTECT"})
	oBrowse1:DisableConfig()
	oBrowse1:DisableReport()
	oBrowse1:ExecuteFilter( .T. )

	//Legendas
	oBrowse1:AddLegend( "TMP1->STSLEG == '1' .And. TMP1->Z81_STATUS <> '3'" , "GREEN")			// Concluído
	oBrowse1:AddLegend( "TMP1->STSLEG == '2' .And. TMP1->Z81_STATUS <> '3'" , "RED")			// Pendente de Contagem
	oBrowse1:AddLegend( "TMP1->STSLEG == '3' .And. TMP1->Z81_STATUS <> '3'" , "YELLOW")			// Precisa de 3a Contagem
	oBrowse1:AddLegend( "TMP1->Z81_STATUS == '3'"                           , "BLUE")			// Apurado

	//Colunas
	ADD COLUMN oColumn DATA { || TMP1->STSCONTAGE 									}	TITLE "Status"					SIZE  012 OF oBrowse1
	ADD COLUMN oColumn DATA { || TMP1->Z82_FICHA 									}	TITLE "Ficha"					SIZE  006 OF oBrowse1
	ADD COLUMN oColumn DATA { || TMP1->Z82_PRODUT									}	TITLE "Produto"					SIZE  014 OF oBrowse1
	ADD COLUMN oColumn DATA { || TMP1->Z82_LOCAL   									}	TITLE "Local"					SIZE  006 OF oBrowse1
	ADD COLUMN oColumn DATA { || TMP1->Z82_LOTECT   								}	TITLE "Lote"					SIZE  010 OF oBrowse1
	ADD COLUMN oColumn DATA { || Transform( TMP1->QTDCONT, "@E 9,999,999")			}	TITLE "Qtd. Contagens"			SIZE  015 OF oBrowse1
	ADD COLUMN oColumn DATA { || Transform( TMP1->QTDCON1, "@E 9,999,999.9999")		}	TITLE "Contagem 1"				SIZE  015 OF oBrowse1
	ADD COLUMN oColumn DATA { || Transform( TMP1->QTDCON2, "@E 9,999,999.9999")		}	TITLE "Contagem 2"				SIZE  015 OF oBrowse1
	ADD COLUMN oColumn DATA { || Transform( TMP1->QTDCON3, "@E 9,999,999.9999")		}	TITLE "Contagem 3"				SIZE  015 OF oBrowse1

	//Ativa o Browse
	ACTIVATE FWBROWSE oBrowse1

	oBrowse1:Show()

	@ 000, 000 MSPANEL oPnlTran2	SIZE 300, 000 OF oWin4 COLORS 0, 16777215
	oPnlTran2:Align	:=  CONTROL_ALIGN_ALLCLIENT

	//Browse
	oBrowse2 := FWBrowse():New(oPnlTran2)        
	oBrowse2:SetDataQuery(.T.)
	oBrowse2:SetQuery(cQryTer)
	oBrowse2:SetQueryIndex({"Z82_FICHA+Z82_PRODUT+Z82_LOCAL+Z82_LOTECT"})
	oBrowse2:SetAlias("TMP2")              
	oBrowse2:SetUniqueKey({"Z82_FICHA","Z82_PRODUT","Z82_LOCAL","Z82_LOTECT"})
	oBrowse2:DisableConfig()
	oBrowse2:DisableReport()
	oBrowse2:ExecuteFilter( .T. )

	//Colunas
	ADD COLUMN oColumn DATA { || TMP2->Z82_FICHA 													}	TITLE "Ficha"					SIZE  006 OF oBrowse2
	ADD COLUMN oColumn DATA { || TMP2->Z82_PRODUT													}	TITLE "Produto"					SIZE  014 OF oBrowse2
	ADD COLUMN oColumn DATA { || TMP2->Z82_LOCAL   													}	TITLE "Local"					SIZE  006 OF oBrowse2
	ADD COLUMN oColumn DATA { || TMP2->Z82_LOTECT   												}	TITLE "Lote"					SIZE  010 OF oBrowse2
	ADD COLUMN oColumn DATA { || Transform( TMP2->QTDCON1, "@E 9,999,999.9999")						}	TITLE "Contagem 1"				SIZE  015 OF oBrowse2
	ADD COLUMN oColumn DATA { || Transform( TMP2->QTDCON2, "@E 9,999,999.9999")						}	TITLE "Contagem 2"				SIZE  015 OF oBrowse2
	ADD COLUMN oColumn DATA { || Transform( TMP2->QTDCON1 - TMP2->QTDCON2, "@E 9,999,999.9999")		}	TITLE "Diferença"				SIZE  015 OF oBrowse2

	//Ativa o Browse
	ACTIVATE FWBROWSE oBrowse2

	oBrowse2:Show()

	@ 000, 000 MSPANEL oPnlTran3	SIZE 300, 000 OF oWin3 COLORS 0, 16777215
	oPnlTran3:Align	:=  CONTROL_ALIGN_ALLCLIENT

	//Browse
	oBrowse3 := FWBrowse():New(oPnlTran3)
	oBrowse3:SetDataQuery(.T.)
	oBrowse3:SetQuery(cQryFal)
	oBrowse3:SetQueryIndex({"B2_COD+B2_LOCAL+B2_LOTECTL+B2_ENDERE+RASTRO+ENDERECO"})
	oBrowse3:SetAlias("TMP3")
	oBrowse3:SetUniqueKey({"B2_COD","B2_LOCAL","B2_LOTECTL","B2_ENDERE","RASTRO","ENDERECO"})
	oBrowse3:DisableConfig()
	oBrowse3:DisableReport()
	oBrowse3:ExecuteFilter( .T. )

	//Colunas
	ADD COLUMN oColumn DATA { || TMP3->B2_COD										}	TITLE "Produto"					SIZE  014 OF oBrowse3
	ADD COLUMN oColumn DATA { || TMP3->B2_LOCAL   									}	TITLE "Local"					SIZE  006 OF oBrowse3
	ADD COLUMN oColumn DATA { || Transform( TMP3->B2_QATU, "@E 9,999,999.9999")		}	TITLE "Saldo Atual"				SIZE  015 OF oBrowse3
	ADD COLUMN oColumn DATA { || TMP3->RASTRO		   								}	TITLE "Rastro?"					SIZE  010 OF oBrowse3
	ADD COLUMN oColumn DATA { || TMP3->ENDERECO		   								}	TITLE "Endereço?"				SIZE  010 OF oBrowse3
	ADD COLUMN oColumn DATA { || TMP3->BLOQ			   								}	TITLE "Bloqueado?"				SIZE  010 OF oBrowse3

	//Ativa o Browse
	ACTIVATE FWBROWSE oBrowse3

	oBrowse3:Show()

	@ 000, 000 MSPANEL oPnlTran4	SIZE 300, 000 OF oWin5 COLORS 0, 16777215
	oPnlTran4:Align	:=  CONTROL_ALIGN_ALLCLIENT

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
		oChart:addSerie( aAno[nAno][1], { 	aAno[nAno][02] })
	Next

	oChart:Build()

	@ 000, 000 MSPANEL oPnlTran5	SIZE 300, 000 OF oWin7 COLORS 0, 16777215
	oPnlTran5:Align	:=  CONTROL_ALIGN_ALLCLIENT

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

	@ 000, 000 MSPANEL oPnlTran6	SIZE 300, 000 OF oWin8 COLORS 0, 16777215
	oPnlTran6:Align	:=  CONTROL_ALIGN_ALLCLIENT

	oFontFic  := tFont():New("Courier New",,-50,,.T.,,,,.T.)
	oSayFicha := tSay():New( 01, 01,{|| StrZero( nFichas, 4) } , oPnlTran6,, oFontFic )

	@ 000, 000 MSPANEL oPnlTran7	SIZE 300, 000 OF oWin9 COLORS 0, 16777215
	oPnlTran7:Align	:=  CONTROL_ALIGN_ALLCLIENT

	oFontEmp := tFont():New("Courier New",,-12,,.T.,,,,.T.)
	oSayEmp  := tSay():New( 00, 00,{|| cEmpAnt+"|"+cFilAnt+" - " + AllTrim(SM0->M0_NOMECOM) } , oPnlTran7,, oFontEmp )

    oTimeRef := TTimer():New(5000, {|| ConsRet() }, oDlg )
    oTimeRef:Activate()
    oTimeEmp := TTimer():New(60000, {|| ConsEmp() }, oDlg )
    oTimeEmp:Activate()
 
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

Static Function ConsEmp()

nEmp++

If nEmp > Len( aEmpresa )
	nEmp := 1
ElseIf nEmp == 0
	nEmp := 1
EndIf

RPCSETENV(aEmpresa[nEmp][1],aEmpresa[nEmp][2],,,"EST",,)

oSayEmp:SetText( cEmpAnt+"|"+cFilAnt+" - " + AllTrim(SM0->M0_NOMECOM) )

Return