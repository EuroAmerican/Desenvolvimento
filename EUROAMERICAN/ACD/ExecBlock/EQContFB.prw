#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'Colors.Ch'
#Include 'JPeg.Ch'
#Include 'HButton.Ch'
#Include 'DBTree.Ch'
#Include 'Font.Ch'
#Include 'TbiConn.Ch'
#Include 'Ap5Mail.Ch'
#Include 'FwBrowse.Ch'
#Include 'FwMvcDef.Ch'
#Include 'ParmType.Ch'
#Include 'FwCalendarWidget.Ch'
#Include 'RPTDef.Ch'
#Include 'FWPrintSetup.Ch'
#Include 'RestFul.Ch'

#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
#Define ID          1 // Id do Celula
#Define OBJETO      2 // Objeto de Tela
#Define DATADIA     3 // Data Completa da Celula
#Define DIA         4 // Dia Ref. Data da Celula
#Define MES         5 // Mes Ref. Data da Celula
#Define ANO         6 // Ano Ref. Data da Celula
#Define NSEMANO     7 // Semana do Ano Ref. Data da Celula
#Define NSEMMES     8 // Semana do Mes Ref. Data da Celula
#Define ATIVO       9 // É celula referente a um dia ativo
#Define FOOTER     10 // É celula referente ao rodape
#Define HEADER     11 // É celula referente ao Header
#Define SEMANA     12 // É celula referente a semana
#Define BGDefault  13 // Cod de BackGround da Celula santos

User Function EQContFB()

Private cPerg  := "EQCONTFB99"
Private cQuery := ""

ValidPerg()

If !Pergunte( cPerg, .T.)
	ApMsgAlert( 'Processamento Cancelado!', 'Atenção')
	Return
EndIf

If Empty( mv_par05 )
	mv_par05 := "MO"
EndIf

If Empty( mv_par06 )
	mv_par06 := "GE"
EndIf

If Empty( mv_par07 )
	mv_par07 := "GA"
EndIf

If Empty( mv_par08 )
	mv_par08 := "GG"
EndIf

If mv_par09 == 0
	mv_par09 := 10
EndIf

cQuery := "SELECT 0 AS MARCA, C2_NUM, C2_ITEM, C2_SEQUEN, " + CRLF
cQuery += "       C2_PRODUTO, " + CRLF
cQuery += "	      C2_ROTEIRO, " + CRLF
cQuery += "   	  B1_OPERPAD, " + CRLF
cQuery += "   	  C2_EMISSAO, " + CRLF
cQuery += "	      B1_TIPO, " + CRLF
cQuery += "   	  G2_OPERAC, " + CRLF
cQuery += "	      G2_DESCRI, " + CRLF
cQuery += "	      G2_LOTEPAD, " + CRLF
cQuery += "       G2_TEMPAD, " + CRLF
cQuery += "       ISNULL(H6_DATAINI, '') AS H6_DATAINI, " + CRLF
cQuery += "       ISNULL(H6_HORAINI, '  :  ') AS H6_HORAINI, " + CRLF
cQuery += "       ISNULL(H6_DATAFIN, '') AS H6_DATAFIN, " + CRLF
cQuery += "       ISNULL(H6_HORAFIN, '  :  ') AS H6_HORAFIN, " + CRLF
cQuery += "       ISNULL(H6_TEMPO, '') AS H6_TEMPO, " + CRLF
cQuery += "       ISNULL(H6_QTDPROD, 0) AS H6_QTDPROD, " + CRLF
cQuery += "       ISNULL(H6_QTDPERD, 0) AS H6_QTDPERD, " + CRLF
cQuery += "       ISNULL(CBH_RECUR, '') AS CBH_RECUR, " + CRLF
cQuery += "       ISNULL(CBH_TRANSA, '') AS CBH_TRANSA, " + CRLF
cQuery += "       ISNULL(CBH_DTINI, '') AS CBH_DTINI, " + CRLF
cQuery += "       ISNULL(CBH_HRINI, '  :  ') AS CBH_HRINI, " + CRLF
cQuery += "       ISNULL(CBH_DTFIM, '') AS CBH_DTFIM, " + CRLF
cQuery += "       ISNULL(CBH_HRFIM, '  :  ') AS CBH_HRFIM " + CRLF
cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
cQuery += "  AND B1_COD = C2_PRODUTO " + CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SG2") + " AS SG2 ON G2_FILIAL = '" + xFilial("SG2") + "' " + CRLF
cQuery += "  AND G2_PRODUTO = C2_PRODUTO " + CRLF
cQuery += "  AND G2_CODIGO = C2_ROTEIRO " + CRLF
cQuery += "  AND SG2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "LEFT JOIN " + RetSqlName("SH6") + " AS SH6 ON H6_FILIAL = C2_FILIAL " + CRLF
cQuery += "  AND H6_OP = C2_NUM + C2_ITEM + C2_SEQUEN  " + CRLF
cQuery += "  AND H6_OPERAC = G2_OPERAC " + CRLF
cQuery += "  AND SH6.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "LEFT JOIN " + RetSqlName("CBH") + " AS CBH ON CBH_FILIAL = C2_FILIAL " + CRLF
cQuery += "  AND CBH_OP = C2_NUM + C2_ITEM + C2_SEQUEN  " + CRLF
cQuery += "  AND CBH_OPERAC = G2_OPERAC " + CRLF
cQuery += "  AND CBH.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
cQuery += "AND C2_EMISSAO BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
cQuery += "AND C2_NUM + C2_ITEM + C2_SEQUEN BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' " + CRLF
cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "GROUP BY C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO, C2_ROTEIRO, B1_OPERPAD, C2_EMISSAO, B1_TIPO, G2_OPERAC, G2_DESCRI, G2_LOTEPAD, G2_TEMPAD, H6_DATAINI, H6_HORAINI, H6_DATAFIN, H6_HORAFIN, H6_TEMPO, H6_QTDPROD, H6_QTDPERD, CBH_RECUR, CBH_TRANSA, CBH_DTINI, CBH_HRINI, CBH_DTFIM, CBH_HRFIM " + CRLF
cQuery += "ORDER BY C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO, C2_ROTEIRO, B1_OPERPAD, C2_EMISSAO, B1_TIPO, G2_OPERAC, G2_DESCRI, G2_LOTEPAD, G2_TEMPAD, H6_DATAINI, H6_HORAINI, H6_DATAFIN, H6_HORAFIN, H6_TEMPO, H6_QTDPROD, H6_QTDPERD, CBH_RECUR, CBH_TRANSA, CBH_DTINI, CBH_HRINI, CBH_DTFIM, CBH_HRFIM " + CRLF

cQryChar1 := "SELECT H1_CODIGO, H1_DESCRI, MENORDATA, " + CRLF
cQryChar1 += "	     (DATEDIFF(hour, CONVERT(DATETIME, MENORDATA), GETDATE()) ) + " + CRLF
cQryChar1 += "       (DATEDIFF(minute, CONVERT(DATETIME, MENORDATA), GETDATE()) % 60) / 100.0 AS CENTESIMAL, " + CRLF
cQryChar1 += "	     CONVERT(VARCHAR(10),DATEDIFF(day, CONVERT(DATETIME, MENORDATA), GETDATE())) + ' Dias ' +  " + CRLF
cQryChar1 += "	     CONVERT(VARCHAR(10),DATEDIFF(hour, CONVERT(DATETIME, MENORDATA), GETDATE()) % 24) + ' Horas ' + " + CRLF
cQryChar1 += "       CONVERT(VARCHAR(10),DATEDIFF(minute, CONVERT(DATETIME, MENORDATA), GETDATE()) % 60) + ' Minutos' AS TEMPO " + CRLF
cQryChar1 += "FROM ( " + CRLF
cQryChar1 += "SELECT H1_CODIGO, H1_DESCRI, MIN(CBH_DTINI + ' ' + CBH_HRINI) AS MENORDATA " + CRLF
cQryChar1 += "FROM " + RetSqlName("SH1") + " AS SH1 WITH (NOLOCK) " + CRLF
cQryChar1 += "INNER JOIN " + RetSqlName("CBH") + " AS CBH WITH (NOLOCK) ON CBH_FILIAL = '" + xFilial("CBH") + "' " + CRLF
cQryChar1 += "  AND CBH_RECUR = H1_CODIGO " + CRLF
cQryChar1 += "  AND CBH_TRANSA = '01' " + CRLF
cQryChar1 += "  AND NOT EXISTS (SELECT * FROM " + RetSqlName("CBH") + " WHERE CBH_FILIAL = CBH.CBH_FILIAL AND CBH_OP = CBH.CBH_OP AND CBH_TRANSA = '04' AND D_E_L_E_T_ = ' ') " + CRLF
cQryChar1 += "  AND CBH.D_E_L_E_T_ = ' ' " + CRLF
cQryChar1 += "INNER JOIN " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) ON C2_FILIAL = CBH_FILIAL " + CRLF
cQryChar1 += "  AND C2_NUM + C2_ITEM + C2_SEQUEN = CBH_OP " + CRLF
cQryChar1 += "  AND SC2.D_E_L_E_T_ = ' ' " + CRLF
cQryChar1 += "WHERE H1_FILIAL = '" + xFilial("SH1") + "' " + CRLF
cQryChar1 += "AND EXISTS (SELECT * FROM " + RetSqlName("SG2") + " AS SG2 WITH (NOLOCK) WHERE G2_FILIAL = '" + xFilial("SG2") + "' AND G2_RECURSO = H1_CODIGO AND G2_OPERAC <> '10' AND SG2.D_E_L_E_T_ = ' ') " + CRLF
cQryChar1 += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("SH6") + " AS SH6 WITH (NOLOCK) WHERE H6_FILIAL = CBH_FILIAL AND H6_OP = CBH_OP AND H6_OPERAC = CBH_OPERAC AND SH6.D_E_L_E_T_ = ' ') " + CRLF
cQryChar1 += "AND SH1.D_E_L_E_T_ = ' ' " + CRLF
cQryChar1 += "GROUP BY H1_CODIGO, H1_DESCRI " + CRLF
cQryChar1 += ") AS AGRUPADO " + CRLF
cQryChar1 += "ORDER BY H1_CODIGO, H1_DESCRI " + CRLF

cQryChar3 := "SELECT H6_OPERAC, (SELECT TOP 1 G2_DESCRI FROM " + RetSqlName("SG2") + " WHERE G2_FILIAL = '" + xFilial("SG2") + "' AND G2_OPERAC = H6_OPERAC AND D_E_L_E_T_ = ' ' ORDER BY R_E_C_N_O_ DESC) AS DESCRICAO, SUM(CONVERT(FLOAT,LEFT(H6_TEMPO, 3)) + CONVERT(FLOAT,SUBSTRING(H6_TEMPO, 5, 2)) / 60) AS QUANTIDADE " + CRLF
cQryChar3 += "FROM " + RetSqlName("SH6") + " AS SH6 WITH (NOLOCK) " + CRLF
cQryChar3 += "WHERE H6_FILIAL = '" + xFilial("SH6") + "' " + CRLF
cQryChar3 += "AND H6_DTAPONT BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
cQryChar3 += "AND H6_OP BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' " + CRLF
cQryChar3 += "AND H6_TEMPO <> '' " + CRLF
cQryChar3 += "AND SH6.D_E_L_E_T_ = ' ' " + CRLF
cQryChar3 += "GROUP BY H6_OPERAC " + CRLF
cQryChar3 += "ORDER BY H6_OPERAC " + CRLF

cQryChar4 := "SELECT H1_CTRAB, HB_NOME, CTT_CUSTO, CTT_DESC01, SUM(CONVERT(FLOAT,LEFT(H6_TEMPO, 3)) + CONVERT(FLOAT,SUBSTRING(H6_TEMPO, 5, 2)) / 60) AS QUANTIDADE " + CRLF
cQryChar4 += "FROM " + RetSqlName("SH6") + " AS SH6 WITH (NOLOCK) " + CRLF
cQryChar4 += "INNER JOIN " + RetSqlName("SH1") + " AS SH1 WITH (NOLOCK) ON H1_FILIAL = '" + xFilial("SH1") + "' " + CRLF
cQryChar4 += "  AND H1_CODIGO = H6_RECURSO " + CRLF
cQryChar4 += "  AND SH1.D_E_L_E_T_ = ' ' " + CRLF
cQryChar4 += "INNER JOIN " + RetSqlName("SHB") + " AS SHB WITH (NOLOCK) ON HB_FILIAL = H1_FILIAL " + CRLF
cQryChar4 += "  AND HB_COD = H1_CTRAB " + CRLF
cQryChar4 += "  AND SHB.D_E_L_E_T_ = ' ' " + CRLF
cQryChar4 += "INNER JOIN " + RetSqlName("CTT") + " AS CTT WITH (NOLOCK) ON CTT_FILIAL = HB_FILIAL " + CRLF
cQryChar4 += "  AND CTT_CUSTO = HB_CC " + CRLF
cQryChar4 += "  AND CTT.D_E_L_E_T_ = ' ' " + CRLF
cQryChar4 += "WHERE H6_FILIAL = '" + xFilial("SH6") + "' " + CRLF
cQryChar4 += "AND H6_DTAPONT BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
cQryChar4 += "AND H6_OP BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' " + CRLF
cQryChar4 += "AND SH6.D_E_L_E_T_ = ' ' " + CRLF
cQryChar4 += "GROUP BY H1_CTRAB, HB_NOME, CTT_CUSTO, CTT_DESC01 " + CRLF
cQryChar4 += "ORDER BY H1_CTRAB " + CRLF

cQryCad := "SELECT '0' AS STS, B1_COD, B1_DESC, 'Roteiro de Operações precisa da operação 30 - Completagem' AS OCORRENCIA, 'Roteiro de Operações' AS CADASTRO " + CRLF
cQryCad += "FROM " + RetSqlName("SB1") + " AS SB1 " + CRLF
cQryCad += "WHERE B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
cQryCad += "AND B1_EQ_DISP = 'N' " + CRLF
cQryCad += "AND B1_EQ_COMP <> 'N' " + CRLF
cQryCad += "AND B1_MSBLQL <> '1' " + CRLF
cQryCad += "AND EXISTS (SELECT * FROM " + RetSqlName("SB2") + " WHERE B2_FILIAL = '" + xFilial("SB2") + "' AND B2_COD = B1_COD AND D_E_L_E_T_ = ' ') " + CRLF
cQryCad += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("SG2") + " AS SG2 WHERE G2_FILIAL = '" + xFilial("SG2") + "' AND G2_PRODUTO = B1_COD AND G2_CODIGO = B1_OPERPAD AND G2_OPERAC = '30' AND SG2.D_E_L_E_T_ = ' ') " + CRLF
cQryCad += "AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQryCad += "UNION ALL " + CRLF
cQryCad += "SELECT '1' AS STS, B1_COD, B1_DESC, 'Roteiro de Operações precisa da operação 20 - Dispersão' AS OCORRENCIA, 'Roteiro de Operações' AS CADASTRO " + CRLF
cQryCad += "FROM " + RetSqlName("SB1") + " AS SB1 " + CRLF
cQryCad += "WHERE B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
cQryCad += "AND B1_EQ_DISP <> 'N' " + CRLF
cQryCad += "AND B1_EQ_COMP = 'N' " + CRLF
cQryCad += "AND B1_MSBLQL <> '1' " + CRLF
cQryCad += "AND EXISTS (SELECT * FROM " + RetSqlName("SB2") + " WHERE B2_FILIAL = '" + xFilial("SB2") + "' AND B2_COD = B1_COD AND D_E_L_E_T_ = ' ') " + CRLF
cQryCad += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("SG2") + " AS SG2 WHERE G2_FILIAL = '" + xFilial("SG2") + "' AND G2_PRODUTO = B1_COD AND G2_CODIGO = B1_OPERPAD AND G2_OPERAC = '20' AND SG2.D_E_L_E_T_ = ' ') " + CRLF
cQryCad += "AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQryCad += "UNION ALL " + CRLF
cQryCad += "SELECT '5' AS STS, B1_COD, B1_DESC, 'Tipo de Produto Não Pode ser Pai' AS OCORRENCIA, 'Estrutura de Produto' AS CADASTRO " + CRLF
cQryCad += "FROM " + RetSqlName("SB1") + " AS SB1 " + CRLF
cQryCad += "WHERE B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
cQryCad += "AND B1_TIPO NOT IN ('PA','PI','KT') " + CRLF
cQryCad += "AND B1_MSBLQL <> '1' " + CRLF
cQryCad += "AND EXISTS (SELECT * FROM " + RetSqlName("SB2") + " WHERE B2_FILIAL = '" + xFilial("SB2") + "' AND B2_COD = B1_COD AND D_E_L_E_T_ = ' ') " + CRLF
cQryCad += "AND EXISTS (SELECT * FROM " + RetSqlName("SG1") + " AS SG1 WHERE G1_FILIAL = '" + xFilial("SG1") + "' AND G1_COD = B1_COD AND SG1.D_E_L_E_T_ = ' ') " + CRLF
cQryCad += "AND SB1.D_E_L_E_T_ = ' ' " + CRLF

cQryOcor := "SELECT H6_OP AS ORDEMPROD, H6_PRODUTO, H6_OPERAC, H6_RECURSO, 'Apontamento Manual mas iniciado no Coletor' AS OCORRENCIA " + CRLF
cQryOcor += "FROM " + RetSqlName("SH6") + " AS SH6 " + CRLF
cQryOcor += "WHERE H6_FILIAL = '" + xFilial("SH6") + "' " + CRLF
cQryOcor += "AND EXISTS (SELECT * FROM " + RetSqlName("CBH") + " WHERE CBH_FILIAL = H6_FILIAL AND CBH_OP = H6_OP AND CBH_OPERAC = H6_OPERAC AND CBH_TRANSA = '01' AND D_E_L_E_T_ = ' ') " + CRLF
cQryOcor += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("CBH") + " WHERE CBH_FILIAL = H6_FILIAL AND CBH_OP = H6_OP AND CBH_OPERAC = H6_OPERAC AND CBH_TRANSA = '04' AND D_E_L_E_T_ = ' ') " + CRLF
//cQryOcor += "AND H6_DTAPONT BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
//cQryOcor += "AND H6_OP BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' " + CRLF
cQryOcor += "AND SH6.D_E_L_E_T_ = ' ' " + CRLF

FwMsgRun( ,{ || Monitor() }, , 'Selecionando Registros, Por favor aguarde' )

Return

Static Function Monitor()

Local oDlgCFG
Local oProcess
Local lEnd           := .F.
Local aSize          := MsAdvSize( .F. )
Local lAutoRef       := .F.
Local lAutoNFe       := .F. 
Local oTimeRef       := Nil
Local oDlg           := Nil
Local aPesqIdx       := {}
Local aPesqOrd       := {}
Local aSeek          := {}
Local nI             := 0

Private oProd1
Private oProd2
Private lConfirmado  := .F.
Private lCorrige     := .F.
Private oFontMsg     := TFont():New('Courier new',,-14,.T.)
Private oFontPar     := TFont():New('Arial'      ,,-13,.T.,,,,,,.F.,.T.)
Private oFontPar1    := TFont():New('Arial'      ,,-11,.T.,,,,,,.F.,.F.)
Private oFontRes1    := TFont():New('Courier new',,-11,.F.)
Private oFontRes2    := TFont():New('Courier new',,-12,.T.)
Private oFontRes3    := TFont():New('Arial'      ,,-18,.T.,,,,,,.F.,.F.)
Private oFontLeg     := TFont():New( "Verdana"   ,,012,,.T.,,,,,.F.,.F. )
Private oFontL       := TFont():New( "Verdana"   ,,008,,.T.,,,,,.F.,.F. )
Private lRetorno     := .T.
Private lPodeSair    := .T. // Se estiver em processo de atualização de tela não permite finalizar o objeto oDlg:End()
Private lSair        := .F.
Private cTitulo	     := "Monitor de Separação de Ordens de Produções | Operador Fracionamentos"
Private cCadastro    := cTitulo
Private oFont        := TFont():New( "Courier New",,14,,.T.,,,,,.F. )
Private aStat        := { "0 = Pendente Separação" , "1 = Separando" }
Private aOS          := {}
Private aAnterior    := {} // Registra anterior para não precisar gerar refresh do objeto a todo momento...
Private nLinha       := 1

DEFINE MSDIALOG oDlgCFG TITLE "EQContFB - Plano de Contingência Comunicação FlowBoard" FROM aSize[7],aSize[1] TO aSize[6],aSize[5] OF oMainWnd STYLE nOR( WS_VISIBLE,WS_POPUP ) PIXEL

	aTFolder := {'Dashboard','Operações para Integração','Ocupação de Recursos','Ocorrências','Calendário Ordem de Produção','Análises Analítica Produção','Análises Sintética Produção'}
	oTFolder := TFolder():New( 0,0,aTFolder,,oDlgCFG,,,,.T.,, (aSize[5] / 2), (aSize[6] / 2) - 20 )

	oFWLayer := FWLayer():New()
	oFWLayer:Init( oTFolder:aDialogs[1], .F. )

	oFWLayer:AddCollumn( "Col01", 50, .T. )
	oFWLayer:AddCollumn( "Col02", 50, .T. )

	oFWLayer:AddWindow( "Col01","Win01" , "Tempo de Uso do Recurso em Horas - Barra"				,050, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oFWLayer:AddWindow( "Col01","Win02" , "Tempo de Uso do Recurso em Horas - Pizza"				,050, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oFWLayer:AddWindow( "Col02","Win03" , "Operações no Último Mês por Hora"						,050, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oFWLayer:AddWindow( "Col02","Win04" , "Quantidade de Horas por Centro de Trabalho no Mês"		,050, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )

	oWin1 := oFWLayer:GetWinPanel( 'Col01','Win01' )
	oWin2 := oFWLayer:GetWinPanel( 'Col01','Win02' )
	oWin3 := oFWLayer:GetWinPanel( 'Col02','Win03' )
	oWin4 := oFWLayer:GetWinPanel( 'Col02','Win04' )

	// Gráfico 1
	@ 000, 000 MSPANEL oPnlTran1	SIZE 300, 000 OF oWin1 COLORS 0, 16777215
	oPnlTran1:Align	:=  CONTROL_ALIGN_ALLCLIENT

	TCQuery cQryChar1 New Alias "TMPEQUI"
	dbSelectArea("TMPEQUI")
	TMPEQUI->( dbGoTop() )

	oChart1 := FWChartBar():New()
	oChart1:init( oPnlTran1, .t. )
	Do While !TMPEQUI->( Eof() )
		oChart1:addSerie( AllTrim( TMPEQUI->H1_CODIGO ), TMPEQUI->CENTESIMAL )
		TMPEQUI->( dbSkip() )
	EndDo
	oChart1:Build()

	dbSelectArea("TMPEQUI")
	TMPEQUI->( dbGoTop() )

	// Gráfico 2
	@ 000, 000 MSPANEL oPnlTran2	SIZE 300, 000 OF oWin2 COLORS 0, 16777215
	oPnlTran2:Align	:=  CONTROL_ALIGN_ALLCLIENT

	oChart2 := FWChartPie():New()
	oChart2:init( oPnlTran2, .t. )
	Do While !TMPEQUI->( Eof() )
		oChart2:addSerie( AllTrim( TMPEQUI->H1_CODIGO ), TMPEQUI->CENTESIMAL )

		TMPEQUI->( dbSkip() )
	EndDo
	oChart2:Build()

	TMPEQUI->( dbCloseArea() )

	TCQuery cQryChar3 New Alias "TMPOPE"
	dbSelectArea("TMPOPE")
	TMPOPE->( dbGoTop() )

	// Gráfico 3
	@ 000, 000 MSPANEL oPnlTran3	SIZE 300, 000 OF oWin3 COLORS 0, 16777215
	oPnlTran3:Align	:=  CONTROL_ALIGN_ALLCLIENT
	oChart3 := FWChartFactory():New()
	oChart3:SetOwner( oPnlTran3 )
	Do While !TMPOPE->( Eof() )
		oChart3:addSerie( AllTrim( TMPOPE->H6_OPERAC ) + " " + AllTrim( TMPOPE->DESCRICAO ), TMPOPE->QUANTIDADE )
		TMPOPE->( dbSkip() )
	EndDo
	oChart3:EnableMenu(.F.)
	oChart3:SetChartDefault( FUNNELCHART )
	oChart3:Activate()
	TMPOPE->( dbCloseArea() )

	// Gráfico 4
	@ 000, 000 MSPANEL oPnlTran4	SIZE 300, 000 OF oWin4 COLORS 0, 16777215
	oPnlTran4:Align	:=  CONTROL_ALIGN_ALLCLIENT

	TCQuery cQryChar4 New Alias "TMPEQUI"
	dbSelectArea("TMPEQUI")
	TMPEQUI->( dbGoTop() )

	oChart4 := FWChartBar():New()
	oChart4:init( oPnlTran4, .t. )
	Do While !TMPEQUI->( Eof() )
		oChart4:addSerie( AllTrim( TMPEQUI->H1_CTRAB ) + " " + AllTrim( TMPEQUI->HB_NOME ), TMPEQUI->QUANTIDADE )
		TMPEQUI->( dbSkip() )
	EndDo
	oChart4:Build()

	TMPEQUI->( dbCloseArea() )

	//Browse 1
	oBrowse1 := FWBrowse():New(oTFolder:aDialogs[2])        
	oBrowse1:SetDataQuery(.T.)
	oBrowse1:SetQuery(cQuery)
	oBrowse1:SetQueryIndex({"C2_NUM+C2_ITEM+C2_SEQUEN+C2_PRODUTO+C2_ROTEIRO+B1_OPERPAD+G2_OPERAC"})
	oBrowse1:SetAlias("TMP1")              
	oBrowse1:DisableConfig()
	oBrowse1:DisableReport()
	oBrowse1:ExecuteFilter( .T. )

	//Legendas
	oBrowse1:AddLegend( "TMP1->CBH_TRANSA == '01'"                               , "GREEN" )		// Operação Iniciada
	oBrowse1:AddLegend( "TMP1->CBH_TRANSA == '04'"                               , "BLUE"  )		// Operação Finalizada
	oBrowse1:AddLegend( "TMP1->CBH_TRANSA == '02' .And. Empty(TMP1->CBH_DTFIM)"  , "BLACK" )		// Pausa Iniciada
	oBrowse1:AddLegend( "TMP1->CBH_TRANSA == '02' .And. !Empty(TMP1->CBH_DTFIM)" , "YELLOW")		// Pausa Encerrada
	oBrowse1:AddLegend( "Empty(TMP1->CBH_TRANSA)"                                , "RED"   )		// Não Iniciado

	//Colunas
	ADD MARKCOLUMN oColumn DATA { || If( TMP1->MARCA == 1,'LBOK','LBNO') } ;
	    DOUBLECLICK { |oBrowse1| RecLock("TMP1", .F.), TMP1->MARCA := IIf(Empty(TMP1->CBH_TRANSA),0,IIf(TMP1->MARCA == 1, 0, 1)), TMP1->( MsUnLock() ) } ;
	    HEADERCLICK { |oBrowse1| fInvertTudo(), oBrowse1:Refresh() } OF oBrowse1
	ADD COLUMN oColumn DATA { || TMP1->(C2_NUM+C2_ITEM+C2_SEQUEN)											}	TITLE "OP"						SIZE  015 OF oBrowse1
	ADD COLUMN oColumn DATA { || TMP1->C2_PRODUTO 															}	TITLE "Produto"					SIZE  015 OF oBrowse1
	ADD COLUMN oColumn DATA { || TMP1->C2_ROTEIRO															}	TITLE "Roteiro"					SIZE  005 OF oBrowse1
	ADD COLUMN oColumn DATA { || STOD(TMP1->C2_EMISSAO)														}	TITLE "Emissão"					SIZE  008 OF oBrowse1
	ADD COLUMN oColumn DATA { || TMP1->G2_OPERAC							   								}	TITLE "Operação"				SIZE  005 OF oBrowse1
	ADD COLUMN oColumn DATA { || TMP1->G2_DESCRI	   														}	TITLE "Descrição"				SIZE  040 OF oBrowse1
	ADD COLUMN oColumn DATA { || TMP1->H6_TEMPO								   								}	TITLE "Tempo"					SIZE  010 OF oBrowse1
	ADD COLUMN oColumn DATA { || TMP1->CBH_RECUR	   														}	TITLE "Recurso"					SIZE  008 OF oBrowse1
	ADD COLUMN oColumn DATA { || TMP1->CBH_TRANSA							   								}	TITLE "Transação"				SIZE  008 OF oBrowse1
	ADD COLUMN oColumn DATA { || IIf(Empty(TMP1->CBH_DTFIM),STOD(TMP1->CBH_DTINI),STOD(TMP1->CBH_DTFIM))	}	TITLE "Data Operação"			SIZE  008 OF oBrowse1
	ADD COLUMN oColumn DATA { || IIf(Empty(TMP1->CBH_HRFIM),TMP1->CBH_HRINI,TMP1->CBH_HRFIM)				}	TITLE "Hora Operação"			SIZE  008 OF oBrowse1

	//Ativa o Browse
	ACTIVATE FWBROWSE oBrowse1

	oBrowse1:Show()

	cQry := "SELECT H1_CODIGO, H1_DESCRI, CBH_OP, CBH_OPERAC, CBH_DTINI, CBH_HRINI " + CRLF
	cQry += "FROM " + RetSqlName("SH1") + " AS SH1 " + CRLF
	cQry += "INNER JOIN " + RetSqlName("CBH") + " AS CBH ON CBH_FILIAL = '" + xFilial("CBH") + "' " + CRLF
	cQry += "  AND CBH_RECUR = H1_CODIGO " + CRLF
	cQry += "  AND CBH_TRANSA = '01' " + CRLF
	cQry += "  AND CBH.D_E_L_E_T_ = ' ' " + CRLF
	cQry += "INNER JOIN " + RetSqlName("SC2") + " AS SC2 ON C2_FILIAL = CBH_FILIAL " + CRLF
	cQry += "  AND C2_NUM + C2_ITEM + C2_SEQUEN = CBH_OP " + CRLF
	cQry += "  AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQry += "WHERE H1_FILIAL = '" + xFilial("SH1") + "' " + CRLF
	cQry += "AND EXISTS (SELECT * FROM " + RetSqlName("SG2") + " AS SG2 WHERE G2_FILIAL = '" + xFilial("SG2") + "' AND G2_RECURSO = H1_CODIGO AND G2_OPERAC <> '10' AND SG2.D_E_L_E_T_ = ' ') " + CRLF
	cQry += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("SH6") + " AS SH6 WHERE H6_FILIAL = CBH_FILIAL AND H6_OP = CBH_OP AND H6_OPERAC = CBH_OPERAC AND SH6.D_E_L_E_T_ = ' ') " + CRLF
	cQry += "AND SH1.D_E_L_E_T_ = ' ' " + CRLF
	cQry += "ORDER BY CBH_OP, H1_CODIGO " + CRLF

	//Browse 2
	oBrowse2 := FWBrowse():New(oTFolder:aDialogs[3])
	oBrowse2:SetDataQuery(.T.)
	oBrowse2:SetQuery(cQry)
	oBrowse2:SetQueryIndex({"CBH_OP+H1_CODIGO+H1_DESCRI"})
	oBrowse2:SetAlias("TMP2")              
	oBrowse2:DisableConfig()
	oBrowse2:DisableReport()
	oBrowse2:ExecuteFilter( .T. )

	//Colunas
	ADD COLUMN oColumn DATA { || TMP2->H1_CODIGO																}	TITLE "Recurso"				SIZE  010 OF oBrowse2
	ADD COLUMN oColumn DATA { || TMP2->H1_DESCRI 																}	TITLE "Descrição"			SIZE  055 OF oBrowse2
	ADD COLUMN oColumn DATA { || TMP2->CBH_OP		  															}	TITLE "OP"					SIZE  020 OF oBrowse2
	ADD COLUMN oColumn DATA { || TMP2->CBH_OPERAC								   								}	TITLE "Operação"			SIZE  010 OF oBrowse2
	ADD COLUMN oColumn DATA { || STOD(TMP2->CBH_DTINI)															}	TITLE "Data Início"			SIZE  010 OF oBrowse2
	ADD COLUMN oColumn DATA { || TMP2->CBH_HRINI								   								}	TITLE "Hora Início"			SIZE  010 OF oBrowse2
	ADD COLUMN oColumn DATA { || DWElapTime( STOD(TMP2->CBH_DTINI), TMP2->CBH_HRINI + ":00", MsDate(), Time() )	}	TITLE "Tempo"				SIZE  020 OF oBrowse2

	//Ativa o Browse
	ACTIVATE FWBROWSE oBrowse2

	oBrowse2:Show()

	oFWOcor := FWLayer():New()
	oFWOcor:Init( oTFolder:aDialogs[4], .F. )

	oFWOcor:AddCollumn( "Col41", 100, .T. )

	oFWOcor:AddWindow( "Col41","Win41" , "Erros ou divergências de cadastros no sistema"			,050, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )
	oFWOcor:AddWindow( "Col41","Win42" , "Divergências ou Incidentes nas operações e lançamentos"	,050, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )

	oWinOcor1 := oFWOcor:GetWinPanel( 'Col41','Win41' )
	oWinOcor2 := oFWOcor:GetWinPanel( 'Col41','Win42' )

	//Browse 3
	oBrowse3 := FWBrowse():New(oWinOcor1)
	oBrowse3:SetDataQuery(.T.)
	oBrowse3:SetQuery(cQryCad)
	oBrowse3:SetQueryIndex({"STS+B1_COD+B1_DESC"})
	oBrowse3:SetAlias("TMP3")              
	oBrowse3:DisableConfig()
	oBrowse3:DisableReport()
	oBrowse3:ExecuteFilter( .T. )

	//Colunas
	ADD COLUMN oColumn DATA { || TMP3->STS																		}	TITLE "ID"					SIZE  003 OF oBrowse3
	ADD COLUMN oColumn DATA { || TMP3->B1_COD	 																}	TITLE "Produto"				SIZE  015 OF oBrowse3
	ADD COLUMN oColumn DATA { || TMP3->B1_DESC		  															}	TITLE "Descrição"			SIZE  030 OF oBrowse3
	ADD COLUMN oColumn DATA { || TMP3->OCORRENCIA								   								}	TITLE "Ocorrência"			SIZE  060 OF oBrowse3
	ADD COLUMN oColumn DATA { || TMP3->CADASTRO									   								}	TITLE "Cadastro"			SIZE  010 OF oBrowse3

	//Ativa o Browse
	ACTIVATE FWBROWSE oBrowse3

	oBrowse3:Show()

	//Browse 4
	oBrowse4 := FWBrowse():New(oWinOcor2)
	oBrowse4:SetDataQuery(.T.)
	oBrowse4:SetQuery(cQryOcor)
	oBrowse4:SetQueryIndex({"ORDEMPROD+H6_PRODUTO+H6_OPERAC+H6_RECURSO+OCORRENCIA"})
	oBrowse4:SetAlias("TMP4")              
	oBrowse4:DisableConfig()
	oBrowse4:DisableReport()
	oBrowse4:ExecuteFilter( .T. )

	//Colunas
	ADD COLUMN oColumn DATA { || TMP4->ORDEMPROD																	}	TITLE "OP"					SIZE  010 OF oBrowse4
	ADD COLUMN oColumn DATA { || TMP4->H6_PRODUTO	 																}	TITLE "Produto"				SIZE  015 OF oBrowse4
	ADD COLUMN oColumn DATA { || TMP4->H6_OPERAC		  															}	TITLE "Operação"			SIZE  005 OF oBrowse4
	ADD COLUMN oColumn DATA { || TMP4->H6_RECURSO									   								}	TITLE "Recurso"				SIZE  008 OF oBrowse4
	ADD COLUMN oColumn DATA { || TMP4->OCORRENCIA									   								}	TITLE "Ocorrência"			SIZE  060 OF oBrowse4

	//Ativa o Browse
	ACTIVATE FWBROWSE oBrowse4

	oBrowse4:Show()

	// Calendário
	aTFolCar := {'Apontamentos de Ordem de Separação por Operações e Recursos','Totais Diários por Mês','Gantt Por Operações da OP','Gantt Por Recursos para OP'}
	oTFolCar := TFolder():New( 0,0,aTFolCar,,oTFolder:aDialogs[5],,,,.T.,, (aSize[5] / 2), (aSize[6] / 2) - 20 )

	oFWCalen := FWLayer():New()
	oFWCalen:Init( oTFolCar:aDialogs[1], .F. )

	oFWCalen:AddCollumn( "Col51", 100, .T. )

	oFWCalen:AddWindow( "Col51","Win51" , "Calendário Apontamentos de Ordem de Produção por Operações",100, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )

	oWinCal := oFWCalen:GetWinPanel( 'Col51','Win51' )

    oCalend := FWCalendarWidget():New(oWinCal)
    oCalend:SetbRefresh( {|dDate| BuscaAtividades(dDate) } )
    oCalend:SetFontColor("#FF6600") 
    oCalend:SetFontName("Comic Sans MS") 
         
    oCalend:Activate()

	cMes    := StrZero( Month( mv_par02 ) , 2 )
	cAno    := StrZero( Year( mv_par02 )  , 4 )
	cMesAno := AllTrim( cMes ) + '/' + AllTrim( cAno )

	oFWAgend := FWLayer():New()
	oFWAgend:Init( oTFolCar:aDialogs[2], .F. )

	oFWAgend:AddCollumn( "Col61", 100, .T. )

	oFWAgend:AddWindow( "Col61","Win61" , "Apontamentos Realizados no Dia [" + cMesAno + "]",100, .F., .F., /*bAction*/, /*cIDLine*/, /*bGotFocus*/ )

	oWinCal2 := oFWAgend:GetWinPanel( 'Col61','Win61' )

	oTela := FWFormContainer():New( oWinCal2 )
	cIdCalen  := oTela:createHorizontalBox( 92 )
	cIdRodape := oTela:createHorizontalBox(  8 )
	cIcoCalen := oTela:createVerticalBox(  5, cIdRodape )
	cIcoBotoes:= oTela:createVerticalBox( 95, cIdRodape )
	oTela:Activate( oWinCal2, .F. )
	oTelaCaled := oTela:GetPanel( cIdCalen   )
	oTelaIcoCa := oTela:GetPanel( cIcoCalen  )
	oTelaIcoBt := oTela:GetPanel( cIcoBotoes )
	oAgenda := FWCalendar():New( VAL(cMes), VAL(cAno) )
	oAgenda:aNomeCol    := { 'Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Semana' }
	oAgenda:lWeekColumn := .F.
	oAgenda:lFooterLine := .F.
	oAgenda:Activate( oTelaCaled )

	nI := 0
	aList = Array(Len( oAgenda:aCell ))
	For nI := 1 To Len( oAgenda:aCell )
		If oAgenda:aCell[nI][ATIVO]
		ElseIf oAgenda:aCell[nI][SEMANA]
		ElseIf oAgenda:aCell[nI][FOOTER]
			oAgenda:SetInfo( oAgenda:aCell[nI][ID], 'Rodapé' )
		EndIf
		If !Empty( oAgenda:aCell[nI][DATADIA] )
			cQuery := "SELECT SUM(CONTA) AS CONTA, SUM(VALOR) AS VALOR, SUM(QUANTIDADE) AS QUANTIDADE, SUM(HORAS) AS HORAS " + CRLF
			cQuery += "FROM ( " + CRLF
			cQuery += "SELECT COUNT(*) AS CONTA, SUM(D3_CUSTO1) AS VALOR, SUM(D3_QUANT) AS QUANTIDADE, 0 AS HORAS " + CRLF
			cQuery += "FROM " + RetSqlName("SD3") + " AS SD3 WITH (NOLOCK) " + CRLF
			cQuery += "WHERE D3_FILIAL = '" + xFilial("SD3") + "' " + CRLF
			cQuery += "AND D3_EMISSAO = '" + DTOS( oAgenda:aCell[nI][DATADIA] ) + "' " + CRLF
			cQuery += "AND LEFT(D3_CF, 2) = 'PR' " + CRLF
			cQuery += "AND SD3.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += "GROUP BY D3_EMISSAO " + CRLF
			cQuery += "UNION ALL " + CRLF
			cQuery += "SELECT 0 AS CONTA, 0 AS VALOR, 0 AS QUANTIDADE, SUM(D3_QUANT) AS HORAS " + CRLF
			cQuery += "FROM " + RetSqlName("SD3") + " AS SD3 WITH (NOLOCK) " + CRLF
			cQuery += "WHERE D3_FILIAL = '" + xFilial("SD3") + "' " + CRLF
			cQuery += "AND D3_EMISSAO = '" + DTOS( oAgenda:aCell[nI][DATADIA] ) + "' " + CRLF
			cQuery += "AND LEFT(D3_CF, 2) = 'RE' " + CRLF
			cQuery += "AND D3_OP <> '' " + CRLF
			cQuery += "AND D3_UM = 'HR' " + CRLF
			cQuery += "AND LEFT( D3_COD, 2) = '" + mv_par05 + "' " + CRLF
			cQuery += "AND SD3.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += "GROUP BY D3_EMISSAO " + CRLF
			cQuery += ") AS AGRUPADO " + CRLF

			TCQuery cQuery New Alias "TOTDIA"
			dbSelectArea("TOTDIA")
			dbGoTop()

			If !TOTDIA->( Eof() )
				If TOTDIA->CONTA > 0 .Or. TOTDIA->QUANTIDADE > 0 .Or. TOTDIA->VALOR > 0 .Or. TOTDIA->HORAS > 0
					aItems := Array( 4 )
					aItems[1] := "Qtde. OPs: " + AllTrim( Str( TOTDIA->CONTA ) )
					aItems[2] := "Qtde. Produzida: " + AllTrim( Transform( TOTDIA->QUANTIDADE, "@E 9,999,999.9999") )
					aItems[3] := "Custo Produzido R$: " + AllTrim( Transform( TOTDIA->VALOR, "@E 9,999,999.99") )
					aItems[4] := "Horas Trabalhadas: " + AllTrim( Transform( TOTDIA->HORAS, "@E 9,999.99") )
					oAgenda:SetInfo( oAgenda:aCell[nI][ID], aItems )
				EndIf
			EndIf

			TOTDIA->( dbCloseArea() )
		EndIf
	Next

	oFWGantt := FWLayer():New()
	oFWGantt:Init( oTFolCar:aDialogs[3], .F. )

	oFWGantt:AddCollumn( "Col71", 100, .T. )

	oFWGantt:AddWindow( "Col71","Win71" , "Apontamentos Realizados no Dia",100, .F., .F., , , )

	oWinCal3 := oFWGantt:GetWinPanel( 'Col71','Win71' )

	cCadastro := "Operações Realizadas na Ordem de Produção"
	aGantt    := {}
	aConfig   := {1,.T.,.T.,.T.,.T.,.T.,.T.,.T.} //aConfig := {2, .T., .T., .T.}
	aCampos   := {{"Descrição", 30}, {"Início", 105}}
	dIniGnt   := mv_par01
	nBottom   := oWinCal3:nBottom-12
	nRight    := oWinCal3:nRight-10
	nTsk      := 1
	aCores    := {CLR_HBLUE, CLR_HRED,CLR_BROWN, CLR_BLACK, CLR_GREEN, CLR_GRAY}
	nCor      := 0

	aGanttAux := {}
	cQuery := "SELECT H6_OP, G2_OPERAC, G2_DESCRI, H6_DATAINI, H6_HORAINI, H6_DATAFIN, H6_HORAFIN " + CRLF
	cQuery += "FROM " + RetSqlName("SH6") + " AS SH6 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) ON C2_FILIAL = H6_FILIAL " + CRLF
	cQuery += "  AND C2_NUM + C2_ITEM + C2_SEQUEN = H6_OP " + CRLF
	cQuery += "  AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SG2") + " AS SG2 WITH (NOLOCK) ON G2_FILIAL = '" + xFilial("SG2") + "' " + CRLF
	cQuery += "  AND G2_PRODUTO = H6_PRODUTO " + CRLF
	cQuery += "  AND G2_CODIGO = C2_ROTEIRO " + CRLF
	cQuery += "  AND G2_OPERAC = H6_OPERAC " + CRLF
	cQuery += "  AND SG2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE H6_FILIAL = '" + xFilial("SH6") + "' " + CRLF
	cQuery += "AND H6_DATAINI BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
	cQuery += "AND SH6.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY H6_OP, H6_OPERAC, H6_DATAINI, H6_HORAINI " + CRLF

	TCQuery cQuery New Alias "TGANTT"
	dbSelectArea("TGANTT")
	TGANTT->( dbGoTop() )

	Do While !TGANTT->( Eof() )
		nCor++
		If nCor > 6
			nCor := 1
		EndIf

		aGanttAux  := {}
		aLinhaDesc := {}
		aAdd( aLinhaDesc, AllTrim( TGANTT->H6_OP ))
		aAdd( aGanttAux, {STOD(TGANTT->H6_DATAINI),TGANTT->H6_HORAINI,STOD(TGANTT->H6_DATAFIN),TGANTT->H6_HORAFIN,TGANTT->G2_OPERAC + " " + AllTrim( TGANTT->G2_DESCRI ),aCores[nCor],,2,CLR_BLACK})
		aAdd( aGantt, {aLinhaDesc, aGanttAux, CLR_GREEN,})

		TGANTT->( dbSkip() )
	EndDo

	TGANTT->( dbCloseArea() )

	PmsGantt(aGantt,aConfig,@dIniGnt,,oWinCal3,{14,1,(nBottom/2)-40,(nRight/2)-4},{{"Ordem Produção",160}},@nTsk)

	oFWGanRec := FWLayer():New()
	oFWGanRec:Init( oTFolCar:aDialogs[4], .F. )

	oFWGanRec:AddCollumn( "Col71", 100, .T. )

	oFWGanRec:AddWindow( "Col71","Win71" , "Apontamentos Realizados no Dia por Recurso",100, .F., .F., , , )

	oWinCal4 := oFWGanRec:GetWinPanel( 'Col71','Win71' )

	cCadastro := "Operações Realizadas na Ordem de Produção por Recursos"
	aGanRec   := {}
	aConfig   := {1,.T.,.T.,.T.,.T.,.T.,.T.,.T.} //aConfig := {2, .T., .T., .T.}
	aCampos   := {{"Descrição", 30}, {"Início", 105}}
	dIniGnt   := mv_par01
	nBottom   := oWinCal4:nBottom-12
	nRight    := oWinCal4:nRight-10
	nTsk      := 1
	aCores    := {CLR_HBLUE, CLR_HRED,CLR_BROWN, CLR_BLACK, CLR_GREEN, CLR_GRAY}
	nCor      := 0

	aGanttAux := {}
	cQuery := "SELECT RTRIM(LTRIM(H6_OP)) + ' - ' + RTRIM(LTRIM(H6_OPERAC)) AS H6_OP, H1_CODIGO, H1_DESCRI, H6_DATAINI, H6_HORAINI, H6_DATAFIN, H6_HORAFIN " + CRLF
	cQuery += "FROM " + RetSqlName("SH6") + " AS SH6 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) ON C2_FILIAL = H6_FILIAL " + CRLF
	cQuery += "  AND C2_NUM + C2_ITEM + C2_SEQUEN = H6_OP " + CRLF
	cQuery += "  AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SH1") + " AS SH1 WITH (NOLOCK) ON H1_FILIAL = '" + xFilial("SH1") + "' " + CRLF
	cQuery += "  AND H1_CODIGO = H6_RECURSO " + CRLF
	cQuery += "  AND SH1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE H6_FILIAL = '" + xFilial("SH6") + "' " + CRLF
	cQuery += "AND H6_DATAINI BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
	cQuery += "AND SH6.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY H6_OP, H6_OPERAC, H1_CODIGO, H1_DESCRI " + CRLF

	TCQuery cQuery New Alias "TGANTT"
	dbSelectArea("TGANTT")
	TGANTT->( dbGoTop() )

	Do While !TGANTT->( Eof() )
		nCor++
		If nCor > 6
			nCor := 1
		EndIf

		aGanttAux  := {}
		aLinhaDesc := {}
		aAdd( aLinhaDesc, AllTrim( TGANTT->H1_CODIGO ) )
		aAdd( aLinhaDesc, AllTrim( TGANTT->H1_DESCRI ) )
		aAdd( aGanttAux, {STOD(TGANTT->H6_DATAINI),TGANTT->H6_HORAINI,STOD(TGANTT->H6_DATAFIN),TGANTT->H6_HORAFIN,TGANTT->H6_OP,aCores[nCor],,2,CLR_BLACK})
		aAdd( aGanRec, {aLinhaDesc, aGanttAux, CLR_GREEN,})

		TGANTT->( dbSkip() )
	EndDo

	TGANTT->( dbCloseArea() )

	PmsGantt(aGanRec,aConfig,@dIniGnt,,oWinCal4,{14,1,(nBottom/2)-40,(nRight/2)-4},{{"Recurso",55},{"Descrição",105}},@nTsk)

	oFWAnaLayer := FWLayer():New()
	oFWAnaLayer:Init( oTFolder:aDialogs[6], .F. )

	oFWAnaLayer:AddCollumn( "Col01", 34, .T. )
	oFWAnaLayer:AddCollumn( "Col02", 33, .T. )
	oFWAnaLayer:AddCollumn( "Col03", 33, .T. )

	oFWAnaLayer:AddWindow( "Col01","Win01"	, "Ordens de Produções [SC2]"                                 ,050, .F., .F., , ,  )
	oFWAnaLayer:AddWindow( "Col01","Win02"	, "Movimentações da OP [SD3]"                                 ,050, .F., .F., , ,  )
	oFWAnaLayer:AddWindow( "Col02","Win03"	, "Apontamentos da OP por Operação [SH6]"                     ,050, .F., .F., , ,  )
	oFWAnaLayer:AddWindow( "Col02","Win04"	, "Empenhos da Ordem de Produção [SD4]"                       ,050, .F., .F., , ,  )
	oFWAnaLayer:AddWindow( "Col03","Win05"	, "Roteiro de Operações para a OP [SG2]"                      ,025, .F., .F., , ,  )
	oFWAnaLayer:AddWindow( "Col03","Win06"	, "Estrutura de Produtos para a OP [SG1]"                     ,025, .F., .F., , ,  )
	oFWAnaLayer:AddWindow( "Col03","Win07"	, "Totais para Tempos e Custos da OP (Realizado x Previsto)"  ,050, .F., .F., , ,  )

	oWinAna1 := oFWAnaLayer:GetWinPanel( 'Col01','Win01' )
	oWinAna2 := oFWAnaLayer:GetWinPanel( 'Col01','Win02' )
	oWinAna3 := oFWAnaLayer:GetWinPanel( 'Col02','Win03' )
	oWinAna4 := oFWAnaLayer:GetWinPanel( 'Col02','Win04' )
	oWinAna5 := oFWAnaLayer:GetWinPanel( 'Col03','Win05' )
	oWinAna6 := oFWAnaLayer:GetWinPanel( 'Col03','Win06' )
	oWinAna7 := oFWAnaLayer:GetWinPanel( 'Col03','Win07' )

	aClAna1 := {{"Numero"			, "C2_NUM"		, "C", "@!"					, 0, 6, 0},;
				{"Item"				, "C2_ITEM"		, "C", "@!"					, 0, 2, 0},;
				{"Sequência"		, "C2_SEQUEN"	, "C", "@!"					, 0, 3, 0},;
				{"Produto"			, "C2_PRODUTO"	, "C", "@!"					, 0,15, 0},;
				{"Local"			, "C2_LOCAL"	, "C", "@!"					, 0, 2, 0},;
				{"Qtd. A Produzir"	, "C2_QUANT"	, "N", "@E 9,999,999.9999"	, 2,14, 4},;
				{"Qtd. 2a UM"		, "C2_QTSEGUM"	, "N", "@E 9,999,999.9999"	, 2,14, 4},;
				{"Qtd. Produzida"	, "C2_QUJE"		, "N", "@E 9,999,999.9999"	, 2,14, 4},;
				{"Qtd. Perda"		, "C2_PERDA"	, "N", "@E 9,999,999.9999"	, 2,14, 4},;
				{"Emissão"			, "C2_EMISSAO"	, "D", ""					, 1, 8, 0},;
				{"Prev. Ini."		, "C2_DATPRI"	, "D", ""					, 1, 8, 0},;
				{"Prev. Fin."		, "C2_DATPRF"	, "D", ""					, 1, 8, 0},;
				{"Roteiro"			, "C2_ROTEIRO"	, "C", "@!"					, 0, 2, 0},;
				{"Revisão"			, "C2_REVISAO"	, "C", "@!"					, 0, 3, 0},;
				{"Filial"			, "C2_FILIAL"	, "C", "@!"					, 0, 2, 0}}

	oBrwAna1 := FWMBrowse():New()
	oBrwAna1:SetOwner(oWinAna1)
	oBrwAna1:SetAlias("SC2")
	oBrwAna1:SetProfileID("1")
	oBrwAna1:SetMenuDef("menudef")
	oBrwAna1:SetFilterDefault("SC2->C2_FILIAL == '" + xFilial("SC2") + "' .And. DTOS( SC2->C2_EMISSAO ) >= '" + DTOS( mv_par01 ) + "' .And. DTOS( SC2->C2_EMISSAO ) <= '" + DTOS( mv_par02 ) + "'")
	oBrwAna1:SetSeeAll(.F.)
	oBrwAna1:SetUseFilter(.F.)
	oBrwAna1:DisableDetails()
	oBrwAna1:DisableLocate()
	oBrwAna1:DisableReport()
	oBrwAna1:SetFields(aClAna1)
	oBrwAna1:ForceQuitButton()
	oBrwAna1:SetChange( {|| fAtuWin7() } )
	oBrwAna1:AddLegend("C2_QUANT <= (C2_QUJE+C2_PERDA)"                              , "DISABLE"   , "Baixado")
	oBrwAna1:AddLegend("C2_QUANT >  (C2_QUJE+C2_PERDA) .And. (C2_QUJE+C2_PERDA) > 0" , "BR_AZUL"   , "Parcial")
	oBrwAna1:AddLegend("C2_QUANT >  (C2_QUJE+C2_PERDA) .And. (C2_QUJE+C2_PERDA) == 0", "ENABLE"    , "Aberto" )
	oBrwAna1:Activate()

	aClAna2 := {{"TM"				, "D3_TM"		, "C", "@!"					, 0, 3, 0},;
				{"CF"				, "D3_CF"		, "C", "@!"					, 0, 3, 0},;
				{"Produto"			, "D3_COD"		, "C", "@!"					, 0,15, 0},;
				{"UM"				, "D3_UM"		, "C", "@!"					, 0, 2, 0},;
				{"Local"			, "D3_LOCAL"	, "C", "@!"					, 0, 2, 0},;
				{"Lote"				, "D3_LOTECTL"	, "C", "@!"					, 0,10, 0},;
				{"Quantidade"		, "D3_QUANT"	, "N", "@E 9,999,999.9999"	, 2,14, 4},;
				{"Custo"			, "D3_CUSTO1"	, "N", "@E 9,999,999.9999"	, 2,14, 4},;
				{"Emissão"			, "D3_EMISSAO"	, "D", ""					, 1, 8, 0},;
				{"Validade"			, "D3_DTVALID"	, "D", ""					, 1, 8, 0},;
				{"Num.Seq."			, "D3_NUMSEQ"	, "C", "@!"					, 0, 6, 0},;
				{"Seq.Calc"			, "D3_SEQCALC"	, "C", "@!"					, 0,14, 0},;
				{"Nivel"			, "D3_NIVEL"	, "C", "@!"					, 0, 2, 0},;
				{"TRT"				, "D3_TRT"		, "C", "@!"					, 0, 3, 0},;
				{"Filial"			, "D3_FILIAL"	, "C", "@!"					, 0, 2, 0}}

	oBrwAna2 := FWMBrowse():New()
	oBrwAna2:SetOwner(oWinAna2)
	oBrwAna2:SetAlias("SD3")
	oBrwAna2:SetMenuDef("menudef")
	oBrwAna2:SetSeeAll(.F.)
	oBrwAna2:SetUseFilter(.F.)
	oBrwAna2:DisableDetails()
	oBrwAna2:DisableLocate()
	oBrwAna2:DisableReport()
	oBrwAna2:SetFields(aClAna2)
	oBrwAna2:SetProfileID("2")
	oBrwAna2:ForceQuitButton()
	oBrwAna2:SetSeek(.F.)
	oBrwAna2:Activate()

	oRelac2:= FWBrwRelation():New()
	oRelac2:AddRelation(oBrwAna1, oBrwAna2, {{"D3_FILIAL", "C2_FILIAL"},{"D3_OP", "C2_NUM+C2_ITEM+C2_SEQUEN"}})
	oRelac2:Activate()

	aClAna3 := {{"Produto"			, "H6_PRODUTO"		, "C", "@!"					, 0,15, 0},;
				{"Operação"			, "H6_OPERAC"		, "C", "@!"					, 0, 2, 0},;
				{"Recurso"			, "H6_RECURSO"		, "C", "@!"					, 0, 6, 0},;
				{"Dt Inicio"		, "H6_DATAINI"		, "D", ""					, 1, 8, 0},;
				{"Hr Inicio"		, "H6_HORAINI"		, "C", "@!"					, 0, 8, 0},;
				{"Dt Final"			, "H6_DATAFIN"		, "D", ""					, 1, 8, 0},;
				{"Hr Final"			, "H6_HORAFIN"		, "C", "@!"					, 0, 8, 0},;
				{"Tempo"			, "H6_TEMPO"		, "C", "@!"					, 0, 8, 0},;
				{"Tipo"		 		, "H6_TIPO"			, "C", "@!"					, 0,10, 0},;
				{"Quantidade"		, "H6_QTDPROD"		, "N", "@E 9,999,999.9999"	, 2,14, 4},;
				{"Perda"			, "H6_QTDPERD"		, "N", "@E 9,999,999.9999"	, 2,14, 4},;
				{"Ganho"			, "H6_QTGANHO"		, "N", "@E 9,999,999.9999"	, 2,14, 4},;
				{"Maior"			, "H6_QTMAIOR"		, "N", "@E 9,999,999.9999"	, 2,14, 4},;
				{"Motivo"			, "H6_MOTIVO" 		, "C", "@!"					, 0, 3, 0},;
				{"Observação"		, "H6_OBSERVA"		, "C", "@!"					, 0,50, 0},;
				{"Filial"			, "H6_FILIAL"		, "C", "@!"					, 0, 2, 0}}

	oBrwAna3 := FWMBrowse():New()
	oBrwAna3:SetOwner(oWinAna3)
	oBrwAna3:SetAlias("SH6")
	oBrwAna3:SetMenuDef("menudef")
	oBrwAna3:SetSeeAll(.F.)
	oBrwAna3:SetUseFilter(.F.)
	oBrwAna3:DisableDetails()
	oBrwAna3:DisableLocate()
	oBrwAna3:DisableReport()
	oBrwAna3:SetFields(aClAna3)
	oBrwAna3:SetProfileID("3")
	oBrwAna3:ForceQuitButton()
	oBrwAna3:SetSeek(.F.)
	oBrwAna3:Activate()

	oRelac3:= FWBrwRelation():New()
	oRelac3:AddRelation(oBrwAna1, oBrwAna3, {{"H6_FILIAL", "C2_FILIAL"},{"H6_OP", "C2_NUM+C2_ITEM+C2_SEQUEN"}})
	oRelac3:Activate()

	aClAna4 := {{"Produto"			, "D4_COD"			, "C", "@!"					, 0,15, 0},;
				{"Local"			, "D4_LOCAL"		, "C", "@!"					, 0, 2, 0},;
				{"Lote"				, "D4_LOTECTL"		, "C", "@!"					, 0,10, 0},;
				{"Data"				, "D4_DATA"			, "D", ""					, 1, 8, 0},;
				{"Qtd. Original"	, "D4_QTDEORI"		, "N", "@E 9,999,999.9999"	, 2,14, 4},;
				{"Quantidade"		, "D4_QUANT"		, "N", "@E 9,999,999.9999"	, 2,14, 4},;
				{"Saldo"			, "D4_SLDEMP"		, "N", "@E 9,999,999.9999"	, 2,14, 4},;
				{"Filial"			, "D4_FILIAL"		, "C", "@!"					, 0, 2, 0}}

	oBrwAna4 := FWMBrowse():New()
	oBrwAna4:SetOwner(oWinAna4)
	oBrwAna4:SetAlias("SD4")
	oBrwAna4:SetMenuDef("menudef")
	oBrwAna4:SetSeeAll(.F.)
	oBrwAna4:SetUseFilter(.F.)
	oBrwAna4:DisableDetails()
	oBrwAna4:DisableLocate()
	oBrwAna4:DisableReport()
	oBrwAna4:SetFields(aClAna4)
	oBrwAna4:SetProfileID("4")
	oBrwAna4:ForceQuitButton()
	oBrwAna4:SetSeek(.F.)
	oBrwAna4:Activate()

	oRelac4:= FWBrwRelation():New()
	oRelac4:AddRelation(oBrwAna1, oBrwAna4, {{"D4_FILIAL", "C2_FILIAL"},{"D4_OP", "C2_NUM+C2_ITEM+C2_SEQUEN"}})
	oRelac4:Activate()

	aClAna5 := {{"Roteiro"			, "G2_CODIGO"		, "C", "@!"					, 0, 2, 0},;
				{"Operação"			, "G2_OPERAC"		, "C", "@!"					, 0, 2, 0},;
				{"Descrição"		, "G2_DESCRI"		, "C", "@!"					, 0,40, 0},;
				{"Recurso"			, "G2_RECURSO"		, "C", "@!"					, 0, 6, 0},;
				{"Tempo Padrão"		, "G2_TEMPAD"		, "N", "@E 999.99"	  		, 2,14, 4},;
				{"Lote Padrão"		, "G2_LOTEPAD"		, "N", "@E 9,999.9999"		, 2,14, 4},;
				{"Qtd Mão Obra"		, "G2_MAOOBRA"		, "N", "@E 999"				, 2,14, 4},;
				{"Tempo Setup"		, "G2_SETUP"		, "N", "@E 999.99"			, 2,14, 4},;
				{"Filial"			, "G2_FILIAL"		, "C", "@!"					, 0, 2, 0}}

	oBrwAna5 := FWMBrowse():New()
	oBrwAna5:SetOwner(oWinAna5)
	oBrwAna5:SetAlias("SG2")
	oBrwAna5:SetMenuDef("menudef")
	oBrwAna5:SetSeeAll(.F.)
	oBrwAna5:SetUseFilter(.F.)
	oBrwAna5:DisableDetails()
	oBrwAna5:DisableLocate()
	oBrwAna5:DisableReport()
	oBrwAna5:SetFields(aClAna5)
	oBrwAna5:SetProfileID("5")
	oBrwAna5:ForceQuitButton()
	oBrwAna5:SetSeek(.F.)
	oBrwAna5:Activate()

	oRelac5:= FWBrwRelation():New()
	oRelac5:AddRelation(oBrwAna1, oBrwAna5, {{"G2_FILIAL", "C2_FILIAL"},{"G2_CODIGO", "C2_ROTEIRO"},{"G2_PRODUTO", "C2_PRODUTO"}})
	oRelac5:Activate()

	aClAna6 := {{"Componente"			, "G1_COMP"			, "C", "@!"					, 0,15, 0},;
				{"Sequência"			, "G1_TRT"			, "C", "@!"					, 0, 3, 0},;
				{"Quantidade"			, "G1_QUANT"		, "N", "@E 999,999.99"		, 2,14, 4}}

	oBrwAna6 := FWMBrowse():New()
	oBrwAna6:SetOwner(oWinAna6)
	oBrwAna6:SetAlias("SG1")
	oBrwAna6:SetMenuDef("menudef")
	oBrwAna6:SetSeeAll(.F.)
	oBrwAna6:SetUseFilter(.F.)
	oBrwAna6:DisableDetails()
	oBrwAna6:DisableLocate()
	oBrwAna6:DisableReport()
	oBrwAna6:SetFields(aClAna6)
	oBrwAna6:SetProfileID("6")
	oBrwAna6:ForceQuitButton()
	oBrwAna6:SetSeek(.F.)
	oBrwAna6:Activate()

	oRelac6:= FWBrwRelation():New()
	oRelac6:AddRelation(oBrwAna1, oBrwAna6, {{"G1_COD", "C2_PRODUTO"}})
	oRelac6:Activate()

	dbSelectArea("SB1")
	dbSetOrder(1)
	SB1->( dbSeek( xFilial("SB1") + SC2->C2_PRODUTO ) )

	oProd1 := TSay():New(002,005,{|| "Produto: " + AllTrim( SC2->C2_PRODUTO ) + " " + AllTrim( SB1->B1_DESC ) }  ,oWinAna7,,oFontRes2,,,,.T.,CLR_BLACK,CLR_HRED)
	oProd2 := TSay():New(017,005,{|| "Roteiro: " + SC2->C2_ROTEIRO + " Revisão: " + SC2->C2_REVISAO + " Qtd. Base: " + AllTrim( Str( SB1->B1_QB ) ) }  ,oWinAna7,,oFontRes2,,,,.T.,CLR_BLACK,CLR_HRED)

	oGroup1 := TGroup():New(033,005,106,300, 'Desempenho da OP por Tempo e por Custo [Tempo e Custo Padrão Proporcional a Quantidade]', oWinAna7,,,.T.)

	nCustoReal := 0
	nCustoPrev := 0
	nCustoDif  := 0
	nTempoReal := 0
	nTempoPrev := 0
	nTempoDif  := 0

	cQuery := "SELECT SUM(CUSTOREAL) AS CUSTOREAL, SUM(CUSTOPREV) AS CUSTOPREV, SUM(TEMPOREAL) AS TEMPOREAL, SUM(TEMPOPREV) AS TEMPOPREV " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT SUM(D3_CUSTO1) AS CUSTOREAL, 0 AS CUSTOPREV, 0 AS TEMPOREAL, 0 AS TEMPOPREV " + CRLF
	cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD3") + " AS SD3 WITH (NOLOCK) ON D3_FILIAL = C2_FILIAL " + CRLF
	cQuery += "  AND D3_OP = C2_NUM + C2_ITEM + C2_SEQUEN " + CRLF
	cQuery += "  AND LEFT( D3_CF, 2) = 'PR' " + CRLF
	cQuery += "  AND SD3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
	cQuery += "AND C2_NUM = '" + SC2->C2_NUM + "' " + CRLF
	cQuery += "AND C2_ITEM = '" + SC2->C2_ITEM + "' " + CRLF
	cQuery += "AND C2_SEQUEN = '" + SC2->C2_SEQUEN + "' " + CRLF
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT 0 AS CUSTOREAL, SUM((((C2_QUANT / CASE B1_QB = 0 THEN 1 ELSE B1_QB END) * G1_QUANT) * B2_CM1)) AS CUSTOPREV, 0 AS TEMPOREAL, 0 AS TEMPOPREV " + CRLF
	cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = C2_PRODUTO " + CRLF
	//cQuery += "  AND B1_QB <> 0 " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SG1") + " AS SG1 WITH (NOLOCK) ON G1_FILIAL = '" + xFilial("SG1") + "' " + CRLF
	cQuery += "  AND G1_COD = B1_COD " + CRLF
	cQuery += "  AND C2_REVISAO >= G1_REVINI AND C2_REVISAO <= G1_REVFIM " + CRLF
	cQuery += "  AND SG1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) ON B2_FILIAL = C2_FILIAL " + CRLF
	cQuery += "  AND B2_COD = G1_COMP " + CRLF
	cQuery += "  AND B2_LOCAL IN (SELECT B1_LOCPAD FROM " + RetSqlName("SB1") + " WHERE B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "  AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
	cQuery += "AND C2_NUM = '" + SC2->C2_NUM + "' " + CRLF
	cQuery += "AND C2_ITEM = '" + SC2->C2_ITEM + "' " + CRLF
	cQuery += "AND C2_SEQUEN = '" + SC2->C2_SEQUEN + "' " + CRLF
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT 0 AS CUSTOREAL, 0 AS CUSTOPREV, SUM(D3_QUANT) AS TEMPOREAL, 0 AS TEMPOPREV " + CRLF
	cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD3") + " AS SD3 WITH (NOLOCK) ON D3_FILIAL = C2_FILIAL " + CRLF
	cQuery += "  AND D3_OP = C2_NUM + C2_ITEM + C2_SEQUEN " + CRLF
	cQuery += "  AND LEFT( D3_CF, 2) = 'RE' " + CRLF
	cQuery += "  AND D3_UM = 'HR' " + CRLF
	cQuery += "  AND LEFT( D3_COD, 2) = '" + mv_par05 + "' " + CRLF
	cQuery += "  AND SD3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
	cQuery += "AND C2_NUM = '" + SC2->C2_NUM + "' " + CRLF
	cQuery += "AND C2_ITEM = '" + SC2->C2_ITEM + "' " + CRLF
	cQuery += "AND C2_SEQUEN = '" + SC2->C2_SEQUEN + "' " + CRLF
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT 0 AS CUSTOREAL, 0 AS CUSTOPREV, 0 AS TEMPOREAL, SUM((C2_QUANT / CASE WHEN G2_LOTEPAD = 0 THEN 1 ELSE G2_LOTEPAD END) * G2_TEMPAD) AS TEMPOPREV " + CRLF
	cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SG2") + " AS SG2 WITH (NOLOCK) ON G2_FILIAL = '" + xFilial("SG2") + "' " + CRLF
	cQuery += "  AND G2_PRODUTO = C2_PRODUTO " + CRLF
	cQuery += "  AND G2_CODIGO = C2_ROTEIRO " + CRLF
	cQuery += "  AND SG2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
	cQuery += "AND C2_NUM = '" + SC2->C2_NUM + "' " + CRLF
	cQuery += "AND C2_ITEM = '" + SC2->C2_ITEM + "' " + CRLF
	cQuery += "AND C2_SEQUEN = '" + SC2->C2_SEQUEN + "' " + CRLF
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF

	TCQuery cQuery New Alias "TMPCUS"
	dbSelectArea("TMPCUS")
	dbGoTop()

	If !TMPCUS->( Eof() )
		nCustoReal := TMPCUS->CUSTOREAL
		nCustoPrev := TMPCUS->CUSTOPREV
		nCustoDif  := TMPCUS->CUSTOREAL - TMPCUS->CUSTOPREV
		nTempoReal := TMPCUS->TEMPOREAL
		nTempoPrev := TMPCUS->TEMPOPREV
		nTempoDif  := TMPCUS->TEMPOREAL - TMPCUS->TEMPOPREV
	EndIf

	TMPCUS->( dbCloseArea() )

	oTempPad := TSay():New(045,010,{|| "Tempo Padrão para Operações da OP.....: "}  ,oGroup1,,oFontRes1,,,,.T.,CLR_BLACK,CLR_HRED)
	oTempRea := TSay():New(055,010,{|| "Tempo Realizado nas Operações da OP...: "}  ,oGroup1,,oFontRes1,,,,.T.,CLR_BLACK,CLR_HRED)
	oTempDif := TSay():New(065,010,{|| "Diferença Tempo Realizado x Previsto..: "}  ,oGroup1,,oFontRes1,,,,.T.,CLR_RED  ,CLR_HRED)
	oCustPad := TSay():New(075,010,{|| "Custo Padrão para Estrutura da OP.....: "}  ,oGroup1,,oFontRes1,,,,.T.,CLR_BLACK,CLR_HRED)
	oCustRea := TSay():New(085,010,{|| "Custo Realizado para Estrutura da OP..: "}  ,oGroup1,,oFontRes1,,,,.T.,CLR_BLACK,CLR_HRED)
	oCustDif := TSay():New(095,010,{|| "Diferença Custo Realizado x Previsto..: "}  ,oGroup1,,oFontRes1,,,,.T.,CLR_RED  ,CLR_HRED)

	rTempPad := TSay():New(045,210,{|| Transform( nTempoPrev, "@E 999,999.99")}  ,oGroup1,,oFontRes1,,,,.T.,CLR_BLACK,CLR_HRED)
	rTempRea := TSay():New(055,210,{|| Transform( nTempoReal, "@E 999,999.99")}  ,oGroup1,,oFontRes1,,,,.T.,CLR_BLACK,CLR_HRED)
	rTempDif := TSay():New(065,210,{|| Transform( nTempoDif, "@E 999,999.99")}   ,oGroup1,,oFontRes1,,,,.T.,CLR_RED  ,CLR_HRED)
	rCustPad := TSay():New(075,210,{|| Transform( nCustoPrev, "@E 999,999.99")}  ,oGroup1,,oFontRes1,,,,.T.,CLR_BLACK,CLR_HRED)
	rCustRea := TSay():New(085,210,{|| Transform( nCustoReal, "@E 999,999.99")}  ,oGroup1,,oFontRes1,,,,.T.,CLR_BLACK,CLR_HRED)
	rCustDif := TSay():New(095,210,{|| Transform( nCustoDif, "@E 999,999.99")}   ,oGroup1,,oFontRes1,,,,.T.,CLR_RED  ,CLR_HRED)

	rTempPad:SetTextAlign( 1, 0 )
	rTempRea:SetTextAlign( 1, 0 )
	rTempDif:SetTextAlign( 1, 0 )
	rCustPad:SetTextAlign( 1, 0 )
	rCustRea:SetTextAlign( 1, 0 )
	rCustDif:SetTextAlign( 1, 0 )

	oGroup2 := TGroup():New(111,005,174,300, 'Composição do Custo do Produto pelas Requisições', oWinAna7,,,.T.)

	nDireto  := 0
	nMaoObra := 0
	nEnergia := 0
	nGas     := 0
	nGGF     := 0

	cQuery := "SELECT SUM(DIRETO) AS DIRETO, SUM(MAOOBRA) AS MAOOBRA, SUM(ENERGIA) AS ENERGIA, SUM(GAS) AS GAS, SUM(GGF) AS GGF " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT CASE WHEN D3_UM <> 'HR' THEN SUM(D3_CUSTO1) ELSE 0 END AS DIRETO, " + CRLF
	cQuery += "       CASE WHEN D3_UM = 'HR' AND LEFT( D3_COD, 2) = '" + mv_par05 + "' THEN SUM(D3_CUSTO1) ELSE 0 END AS MAOOBRA, " + CRLF
	cQuery += "       CASE WHEN D3_UM = 'HR' AND LEFT( D3_COD, 2) = '" + mv_par06 + "' THEN SUM(D3_CUSTO1) ELSE 0 END AS ENERGIA, " + CRLF
	cQuery += "       CASE WHEN D3_UM = 'HR' AND LEFT( D3_COD, 2) = '" + mv_par07 + "' THEN SUM(D3_CUSTO1) ELSE 0 END AS GAS, " + CRLF
	cQuery += "       CASE WHEN D3_UM = 'HR' AND LEFT( D3_COD, 2) = '" + mv_par08 + "' THEN SUM(D3_CUSTO1) ELSE 0 END AS GGF " + CRLF
	cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD3") + " AS SD3 WITH (NOLOCK) ON D3_FILIAL = C2_FILIAL " + CRLF
	cQuery += "  AND D3_OP = C2_NUM + C2_ITEM + C2_SEQUEN " + CRLF
	cQuery += "  AND LEFT( D3_CF, 2) = 'RE' " + CRLF
	cQuery += "  AND SD3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
	cQuery += "AND C2_NUM = '" + SC2->C2_NUM + "' " + CRLF
	cQuery += "AND C2_ITEM = '" + SC2->C2_ITEM + "' " + CRLF
	cQuery += "AND C2_SEQUEN = '" + SC2->C2_SEQUEN + "' " + CRLF
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY D3_UM, LEFT( D3_COD, 2) " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF

	TCQuery cQuery New Alias "TMPCUS"
	dbSelectArea("TMPCUS")
	dbGoTop()

	If !TMPCUS->( Eof() )
		nDireto  := TMPCUS->DIRETO
		nMaoObra := TMPCUS->MAOOBRA
		nEnergia := TMPCUS->ENERGIA
		nGas     := TMPCUS->GAS
		nGGF     := TMPCUS->GGF
	EndIf

	TMPCUS->( dbCloseArea() )

	oCustDir := TSay():New(123,010,{|| "Custo Direto..........................: "}  ,oGroup2,,oFontRes1,,,,.T.,CLR_BLUE ,CLR_HRED)
	oCustMod := TSay():New(133,010,{|| "Custo Mão de Obra.....................: "}  ,oGroup2,,oFontRes1,,,,.T.,CLR_BLUE ,CLR_HRED)
	oCustEne := TSay():New(143,010,{|| "Custo Energia Elétrica................: "}  ,oGroup2,,oFontRes1,,,,.T.,CLR_BLUE ,CLR_HRED)
	oCustGas := TSay():New(153,010,{|| "Custo Gás.............................: "}  ,oGroup2,,oFontRes1,,,,.T.,CLR_BLUE ,CLR_HRED)
	oCustGGF := TSay():New(163,010,{|| "Custo Gastos Gerais de Fabricação.....: "}  ,oGroup2,,oFontRes1,,,,.T.,CLR_BLUE ,CLR_HRED)

	rCustDir := TSay():New(123,210,{|| Transform( nDireto, "@E 999,999.99")}  ,oGroup2,,oFontRes1,,,,.T.,CLR_BLUE ,CLR_HRED)
	rCustMod := TSay():New(133,210,{|| Transform( nMaoObra, "@E 999,999.99")}  ,oGroup2,,oFontRes1,,,,.T.,CLR_BLUE ,CLR_HRED)
	rCustEne := TSay():New(143,210,{|| Transform( nEnergia, "@E 999,999.99")}  ,oGroup2,,oFontRes1,,,,.T.,CLR_BLUE ,CLR_HRED)
	rCustGas := TSay():New(153,210,{|| Transform( nGas, "@E 999,999.99")}  ,oGroup2,,oFontRes1,,,,.T.,CLR_BLUE ,CLR_HRED)
	rCustGGF := TSay():New(163,210,{|| Transform( nGGF, "@E 999,999.99")}  ,oGroup2,,oFontRes1,,,,.T.,CLR_BLUE ,CLR_HRED)

	rCustDir:SetTextAlign( 1, 0 )
	rCustMod:SetTextAlign( 1, 0 )
	rCustEne:SetTextAlign( 1, 0 )
	rCustGas:SetTextAlign( 1, 0 )
	rCustGGF:SetTextAlign( 1, 0 )

	oFWSinLayer := FWLayer():New()
	oFWSinLayer:Init( oTFolder:aDialogs[7], .F. )

	oFWSinLayer:AddCollumn( "Col01",100, .T. )

	oFWSinLayer:AddWindow( "Col01","Win01"	, "Análise Sintética de Variações Real vs Previsto Ordem de Produção [Custo/Tempo] - Tolerância Variação: " + AllTrim( Str( mv_par09 ) ) + "%",100, .F., .F., , ,  )

	oWinSin1 := oFWSinLayer:GetWinPanel( 'Col01','Win01' )

	cQuery := "SELECT C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO, SUM(CUSTOREAL) AS CUSTOREAL, SUM(CUSTOPREV) AS CUSTOPREV, " + CRLF
	cQuery += "       SUM(CUSTOREAL) - SUM(CUSTOPREV) AS DIF_CUSTO, " + CRLF
	cQuery += "       CONVERT(FLOAT, CONVERT(DECIMAL(5,2)," + CRLF
	cQuery += "	   100 - (" + CRLF
	cQuery += "       CASE WHEN SUM(CUSTOREAL) < SUM(CUSTOPREV) THEN (CASE WHEN SUM(CUSTOREAL) = 0 THEN 1 ELSE SUM(CUSTOREAL) END / CASE WHEN SUM(CUSTOPREV) = 0 THEN 1 ELSE SUM(CUSTOPREV) END) " + CRLF
	cQuery += "       ELSE (CASE WHEN SUM(CUSTOPREV) = 0 THEN 1 ELSE SUM(CUSTOPREV) END / CASE WHEN SUM(CUSTOREAL) = 0 THEN 1 ELSE SUM(CUSTOREAL) END) END) * 100.00 " + CRLF
	cQuery += "	   )) AS VAR_CUSTO, " + CRLF
	cQuery += "       SUM(TEMPOREAL) AS TEMPOREAL, SUM(TEMPOPREV) AS TEMPOPREV, " + CRLF
	cQuery += "       SUM(TEMPOREAL) - SUM(TEMPOPREV) AS DIF_TEMPO, " + CRLF
	cQuery += "       CONVERT(FLOAT, CONVERT(DECIMAL(5,2), " + CRLF
	cQuery += "	   100 - (" + CRLF
	cQuery += "       CASE WHEN SUM(TEMPOREAL) < SUM(TEMPOPREV) THEN (CASE WHEN SUM(TEMPOREAL) = 0 THEN 1 ELSE SUM(TEMPOREAL) END / CASE WHEN SUM(TEMPOPREV) = 0 THEN 1 ELSE SUM(TEMPOPREV) END) " + CRLF
	cQuery += "       ELSE (CASE WHEN SUM(TEMPOPREV) = 0 THEN 1 ELSE SUM(TEMPOPREV) END / CASE WHEN SUM(TEMPOREAL) = 0 THEN 1 ELSE SUM(TEMPOREAL) END) END) * 100.00 " + CRLF
	cQuery += "	   )) AS VAR_TEMPO " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO, SUM(D3_CUSTO1) AS CUSTOREAL, 0 AS CUSTOPREV, 0 AS TEMPOREAL, 0 AS TEMPOPREV " + CRLF
	cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD3") + " AS SD3 ON D3_FILIAL = C2_FILIAL " + CRLF
	cQuery += "  AND D3_OP = C2_NUM + C2_ITEM + C2_SEQUEN " + CRLF
	cQuery += "  AND LEFT( D3_CF, 2) = 'PR' " + CRLF
	cQuery += "  AND SD3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
	cQuery += "AND C2_EMISSAO BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
	cQuery += "AND C2_QUANT = (C2_QUJE + C2_PERDA) " + CRLF
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO, 0 AS CUSTOREAL, SUM((((C2_QUANT / CASE B1_QB = 0 THEN 1 ELSE B1_QB END) * G1_QUANT) * B2_CM1)) AS CUSTOPREV, 0 AS TEMPOREAL, 0 AS TEMPOPREV " + CRLF
	cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = C2_PRODUTO " + CRLF
	//cQuery += "  AND B1_QB <> 0 " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SG1") + " AS SG1 ON G1_FILIAL = '" + xFilial("SG1") + "' " + CRLF
	cQuery += "  AND G1_COD = B1_COD " + CRLF
	cQuery += "  AND C2_REVISAO >= G1_REVINI AND C2_REVISAO <= G1_REVFIM " + CRLF
	cQuery += "  AND SG1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB2") + " AS SB2 ON B2_FILIAL = C2_FILIAL " + CRLF
	cQuery += "  AND B2_COD = G1_COMP " + CRLF
	cQuery += "  AND B2_LOCAL IN (SELECT B1_LOCPAD FROM " + RetSqlName("SB1") + " WHERE B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "  AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
	cQuery += "AND C2_EMISSAO BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
	cQuery += "AND C2_QUANT = (C2_QUJE + C2_PERDA) " + CRLF
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO, 0 AS CUSTOREAL, 0 AS CUSTOPREV, SUM(D3_QUANT) AS TEMPOREAL, 0 AS TEMPOPREV " + CRLF
	cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD3") + " AS SD3 ON D3_FILIAL = C2_FILIAL " + CRLF
	cQuery += "  AND D3_OP = C2_NUM + C2_ITEM + C2_SEQUEN " + CRLF
	cQuery += "  AND LEFT( D3_CF, 2) = 'RE' " + CRLF
	cQuery += "  AND D3_UM = 'HR' " + CRLF
	cQuery += "  AND LEFT( D3_COD, 2) = 'MO' " + CRLF
	cQuery += "  AND SD3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
	cQuery += "AND C2_EMISSAO BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
	cQuery += "AND C2_QUANT = (C2_QUJE + C2_PERDA) " + CRLF
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO, 0 AS CUSTOREAL, 0 AS CUSTOPREV, 0 AS TEMPOREAL, SUM((C2_QUANT / CASE WHEN G2_LOTEPAD = 0 THEN 1 ELSE G2_LOTEPAD END) * G2_TEMPAD) AS TEMPOPREV " + CRLF
	cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SG2") + " AS SG2 ON G2_FILIAL = '" + xFilial("SG2") + "' " + CRLF
	cQuery += "  AND G2_PRODUTO = C2_PRODUTO " + CRLF
	cQuery += "  AND G2_CODIGO = C2_ROTEIRO " + CRLF
	cQuery += "  AND SG2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
	cQuery += "AND C2_EMISSAO BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
	cQuery += "AND C2_QUANT = (C2_QUJE + C2_PERDA) " + CRLF
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF
	cQuery += "GROUP BY C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO " + CRLF
	cQuery += "ORDER BY ABS( SUM(CUSTOREAL) - SUM(CUSTOPREV) ) DESC " + CRLF

	//Browse
	oBrowSint := FWBrowse():New(oWinSin1)
	oBrowSint:SetDataQuery(.T.)
	oBrowSint:SetQuery(cQuery)
	oBrowSint:SetQueryIndex({"C2_NUM+C2_ITEM+C2_SEQUEN+C2_PRODUTO"})
	oBrowSint:SetAlias("SINT1")
	oBrowSint:SetUniqueKey({"C2_NUM","C2_ITEM","C2_SEQUEN","C2_PRODUTO"})
	oBrowSint:DisableConfig()
	oBrowSint:DisableReport()
	oBrowSint:ExecuteFilter( .T. )

	//Legendas
	oBrowSint:AddLegend( "SINT1->VAR_CUSTO <= " + AllTrim( Str( mv_par09 ) ), "GREEN")		// Dentro da Tolerância
	oBrowSint:AddLegend( "SINT1->VAR_CUSTO >  " + AllTrim( Str( mv_par09 ) ), "RED")		// Fora da Tolerância

	//Colunas
	ADD COLUMN oColumn DATA { || SINT1->C2_NUM 	 										}	TITLE "Número"					SIZE  006 OF oBrowSint
	ADD COLUMN oColumn DATA { || SINT1->C2_ITEM											}	TITLE "Item"					SIZE  005 OF oBrowSint
	ADD COLUMN oColumn DATA { || SINT1->C2_SEQUEN  										}	TITLE "Sequência"				SIZE  005 OF oBrowSint
	ADD COLUMN oColumn DATA { || SINT1->C2_PRODUTO   									}	TITLE "Produto"					SIZE  010 OF oBrowSint
	ADD COLUMN oColumn DATA { || Transform( SINT1->CUSTOREAL, "@E 9,999,999.999999")	}	TITLE "Custo Real"	 			SIZE  012 OF oBrowSint
	ADD COLUMN oColumn DATA { || Transform( SINT1->CUSTOPREV, "@E 9,999,999.999999")	}	TITLE "Custo Previsto"			SIZE  012 OF oBrowSint
	ADD COLUMN oColumn DATA { || Transform( SINT1->DIF_CUSTO, "@E 9,999,999.999999")	}	TITLE "Diferença"				SIZE  012 OF oBrowSint
	ADD COLUMN oColumn DATA { || Transform( SINT1->VAR_CUSTO, "@E 999.99")				}	TITLE "Variação"				SIZE  010 OF oBrowSint
	ADD COLUMN oColumn DATA { || Transform( SINT1->TEMPOREAL, "@E 9,999,999.999999")	}	TITLE "Tempo Real"	 			SIZE  010 OF oBrowSint
	ADD COLUMN oColumn DATA { || Transform( SINT1->TEMPOPREV, "@E 9,999,999.999999")	}	TITLE "Tempo Previsto"			SIZE  010 OF oBrowSint
	ADD COLUMN oColumn DATA { || Transform( SINT1->DIF_TEMPO, "@E 9,999,999.999999")	}	TITLE "Diferença"				SIZE  010 OF oBrowSint
	ADD COLUMN oColumn DATA { || Transform( SINT1->VAR_TEMPO, "@E 999.99")				}	TITLE "Variação"				SIZE  010 OF oBrowSint

	//Ativa o Browse
	ACTIVATE FWBROWSE oBrowSint

	oTMsgBar   := TMsgBar():New(oDlgCFG, "", .F.,.F.,.F.,.F., CLR_BLACK,,oFontMsg,.F.)
	oTMsgItem1 := TMsgItem():New( oTMsgBar,'TI Euroamerican', 160,,CLR_BLACK,,.T., {||} )
	oTMsgItem2 := TMsgItem():New( oTMsgBar,AllTrim(SM0->M0_NOME) + " / " + AllTrim(SM0->M0_FILIAL), 550,,CLR_BLACK,,.T., {||} )
	oTMsgItem3 := TMsgItem():New( oTMsgBar,"Empresa: " + cEmpAnt + " Filial: " + cFilAnt + " Usuário: " + cUserName, 355,,CLR_BLACK,,.T., {||} )
	oTMsgItem4 := TMsgItem():New( oTMsgBar,"Período: " + DTOC( mv_par01 ) + " à " + DTOC( mv_par02 ), 275,,CLR_BLACK,,.T., {||} )

	@ (aSize[6] / 2) - 15, (aSize[5] / 2) - 200 Button "Imprimir"  Size C(037),C(010) Action (lConfirmado := .F.) PIXEL OF oDlgCFG
	@ (aSize[6] / 2) - 15, (aSize[5] / 2) - 150 Button "Legenda"   Size C(037),C(010) Action (U_XContFB()) PIXEL OF oDlgCFG
	@ (aSize[6] / 2) - 15, (aSize[5] / 2) - 100 Button "Cancelar"  Size C(037),C(010) Action (lConfirmado := .F., oDlgCFG:End()) PIXEL OF oDlgCFG
	@ (aSize[6] / 2) - 15, (aSize[5] / 2) - 050 Button "Confirmar" Size C(037),C(010) Action (lConfirmado := .T.,fEnvia(), oDlgCFG:End()) PIXEL OF oDlgCFG

ACTIVATE MSDIALOG oDlgCFG CENTERED

Return

Static Function fEnvia()

If lConfirmado
	oProcess := MsNewProcess():New( {|lEnd| VERDIVCFG(@oProcess, @lEnd)}, "Enviando dados para o Flowboard", "Preparando registros para envios", .T.)
	oProcess:Activate()
EndIf

Return

Static Function VERDIVCFG()

Local aArea          := TMP1->( GetArea() )
Local lFez           := .F.
Local cURL           := GetMV("MV_FB_URLE",,"http://10.0.0.90:3000")
Local aHeader        := {}
Local oRestClient    := Nil	
Local oObjResult     := Nil
Local lEnvia         := .T.
Local cQuery         := ""
Local nEnvase        := 0
Local nOPEnv         := 0

TMP1->( dbGoTop() )

Do While !TMP1->( Eof() )
	If TMP1->MARCA == 1
		lFez := .T.
		// ---------------->>>>>>>>>>>>>>> Chama webservice Restfull do Flowboard...
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Adiciona Header para WS...                                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd( aHeader, "Content-Type: application/json" )
		aAdd( aHeader, "Accept: application/json" )
		aAdd( aHeader, "charset: UTF-8" )
		
		oRestClient  := FWRest():New(Alltrim(cURL))
		oRestClient:setPath("/post")
	
		cJson := '{'
		cJson += '"op" : "' + AllTrim( IIf(TMP1->G2_OPERAC <> "50", TMP1->(C2_NUM+C2_ITEM+C2_SEQUEN), TMP1->(C2_NUM+'05'+C2_SEQUEN)) ) + '",'
		If TMP1->CBH_TRANSA == "01"
			cJson += '"timestamp" : "' + Left( TMP1->CBH_DTINI, 4) + '-' + SubStr( TMP1->CBH_DTINI, 5, 2) + '-' + Right( TMP1->CBH_DTINI, 2) + ' ' + Left( TMP1->CBH_HRINI, 5) + ':00",'
		Else
			cJson += '"timestamp" : "' + Left( TMP1->CBH_DTFIM, 4) + '-' + SubStr( TMP1->CBH_DTFIM, 5, 2) + '-' + Right( TMP1->CBH_DTFIM, 2) + ' ' + Left( TMP1->CBH_HRFIM, 5) + ':00",'
		EndIf
		cJson += '"cod_recurso" : "' + AllTrim( TMP1->CBH_RECUR ) + '",'
		cJson += '"cod_operacao" : "' + AllTrim( TMP1->G2_OPERAC ) + '",' 
		cJson += '"cod_transacao" : "' + AllTrim( TMP1->CBH_TRANSA ) + '",'
		cJson += '"cod_parada" : "",'
		cJson += '"evento_parada" : ""'
		cJson += '}'
		
		oRestClient:SetPostParams(EncodeUTF8(cJson))
		
		If oRestClient:Post( aHeader )
		    cError := ""
		    nStatus := HTTPGetStatus(@cError)
		
		    If nStatus >= 200 .And. nStatus <= 299
		        If Empty(oRestClient:getResult())
		            ConOut(nStatus)
		        Else
		            ConOut(oRestClient:getResult())
		        EndIf
		    Else
		        ConOut(cError)
		    EndIf
		Else
		    ConOut(oRestClient:getLastError())
		EndIf
	EndIf

	TMP1->( dbSkip() )
EndDo

TMP1->( RestArea( aArea ) )

If lFez
	ApMsgInfo( 'Operação(ões) da OP selecionada foram reenviados para o Flowboard com sucesso!', 'Atenção' )
EndIf

Return

Static Function ValidPerg()

Local aArea := GetArea()
Local aPerg := {}

aAdd(aPerg, {cPerg, "01", "Da Dt. OP          ?", "MV_CH1" , 	"D", 08	, 0	, "G"	, "MV_PAR01", ""	,""		,""				,""				,"",""})
aAdd(aPerg, {cPerg, "02", "Até Dt. OP         ?", "MV_CH2" , 	"D", 08	, 0	, "G"	, "MV_PAR02", ""	,""		,""				,""				,"",""})
aAdd(aPerg, {cPerg, "03", "Da Ordem Produção  ?", "MV_CH3" , 	"C", 14	, 0	, "G"	, "MV_PAR03", ""	,""		,""				,""				,"",""})
aAdd(aPerg, {cPerg, "04", "Até Ordem Produção ?", "MV_CH4" , 	"C", 14	, 0	, "G"	, "MV_PAR04", ""	,""		,""				,""				,"",""})
aAdd(aPerg, {cPerg, "05", "Parte Mão de Obra  ?", "MV_CH5" , 	"C", 02	, 0	, "G"	, "MV_PAR05", ""	,""		,""				,""				,"",""})
aAdd(aPerg, {cPerg, "06", "Parte Energia      ?", "MV_CH6" , 	"C", 02	, 0	, "G"	, "MV_PAR06", ""	,""		,""				,""				,"",""})
aAdd(aPerg, {cPerg, "07", "Parte Gás          ?", "MV_CH7" , 	"C", 02	, 0	, "G"	, "MV_PAR07", ""	,""		,""				,""				,"",""})
aAdd(aPerg, {cPerg, "08", "Parte GGF          ?", "MV_CH8" , 	"C", 02	, 0	, "G"	, "MV_PAR08", ""	,""		,""				,""				,"",""})
aAdd(aPerg, {cPerg, "09", "Toler. Var. Custos ?", "MV_CH9" , 	"N", 03	, 0	, "G"	, "MV_PAR09", ""	,""		,""				,""				,"",""})

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

User Function XContFB()

Local cCadastro := "Transações da Ordem de Produção"
Local aCores    := 	{{ "BR_VERDE"   , 'Operação Iniciada'  },;
					 { "BR_AZUL"    , 'Operação Finalizada'},;
					 { "BR_PRETO"   , 'Pausa Iniciada'     },;
					 { "BR_AMARELO" , 'Pausa Encerrada'    },;
					 { "BR_VERMELHO", 'Não Iniciado'       }}

BrwLegenda( cCadastro, "Legenda", aCores)

Return()

Static Function fInvertTudo()

Local aArea := TMP1->( GetArea() )

TMP1->( dbGoTop() )

Do While !TMP1->( Eof() )
	RecLock("TMP1", .F.)
		TMP1->MARCA := IIf(Empty(TMP1->CBH_TRANSA),0,IIf(TMP1->MARCA == 1, 0, 1))
	TMP1->( MsUnLock() )

	TMP1->( dbSkip() )
EndDo

TMP1->( RestArea( aArea ) )

Return

Static Function BuscaAtividades( dDate )

Local aArea     := GetArea()
Local aItems    := {}
Local oItem     := nil
Local aPrior    := {FWCALENDAR_PRIORITY_HIGH, FWCALENDAR_PRIORITY_MEDIUM, FWCALENDAR_PRIORITY_LOW}
Local nPrior    := 0
Local cQuery    := ""
     
cQuery := "SELECT 'Via Coletor' AS ORIGEM, CASE WHEN DTFIM IS NULL THEN 'Aberto' ELSE 'Finalizado' END AS STSAPONTA, OP, RECURSO, OPERACAO, " + CRLF
cQuery += "       DTINI, HRINI, ISNULL( DTFIM, CONVERT(VARCHAR(8),GETDATE(),112)) AS DTFIM, ISNULL( HRFIM, '23:59') AS HRFIM " + CRLF
cQuery += "FROM (" + CRLF
cQuery += "SELECT INI.CBH_OP AS OP, INI.CBH_RECUR AS RECURSO, INI.CBH_OPERAC AS OPERACAO, INI.CBH_DTINI AS DTINI, INI.CBH_HRINI AS HRINI, FIN.CBH_DTFIM AS DTFIM, FIN.CBH_HRFIM AS HRFIM " + CRLF
cQuery += "FROM " + RetSqlName("CBH") + " AS INI WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("CBH") + " AS FIN WITH (NOLOCK) ON FIN.CBH_FILIAL = INI.CBH_FILIAL " + CRLF
cQuery += "  AND FIN.CBH_OP = INI.CBH_OP " + CRLF
cQuery += "  AND FIN.CBH_OPERAC = INI.CBH_OPERAC " + CRLF
cQuery += "  AND FIN.CBH_TRANSA = '04' " + CRLF
cQuery += "  AND FIN.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE INI.CBH_FILIAL = '" + xFilial("CBH") + "' " + CRLF
cQuery += "AND INI.CBH_TRANSA = '01' " + CRLF
cQuery += "AND INI.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "GROUP BY INI.CBH_OP, INI.CBH_RECUR, INI.CBH_OPERAC, INI.CBH_DTINI, INI.CBH_HRINI, FIN.CBH_DTFIM, FIN.CBH_HRFIM " + CRLF
cQuery += ") AS AGRUPADO " + CRLF
cQuery += "WHERE (DTINI = '" + DTOS(dDate) + "' OR DTFIM = '" + DTOS(dDate) + "') " + CRLF
cQuery += "UNION ALL " + CRLF
cQuery += "SELECT 'Manual Protheus' AS ORIGEM, 'Finalizado' AS STSAPONTA, H6_OP AS OP, H6_RECURSO AS RECURSO, H6_OPERAC AS OPERACAO, " + CRLF
cQuery += "       H6_DATAINI AS DTINI, H6_HORAINI AS HRINI, H6_DATAFIN AS DTFIM, H6_HORAFIN AS HRFIM " + CRLF
cQuery += "FROM " + RetSqlName("SH6") + " AS SH6 WITH (NOLOCK) " + CRLF
cQuery += "WHERE H6_FILIAL = '" + xFilial("SH6") + "' " + CRLF
cQuery += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("CBH") + " WITH (NOLOCK) WHERE CBH_FILIAL = H6_FILIAL AND CBH_OP = H6_OP AND CBH_TRANSA = '04' AND D_E_L_E_T_ = ' ') " + CRLF
cQuery += "AND (H6_DATAINI = '" + DTOS(dDate) + "' OR H6_DATAFIN = '" + DTOS(dDate) + "') " + CRLF
cQuery += "AND SH6.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "ORDER BY OP, OPERACAO, RECURSO, DTINI, HRINI " + CRLF

TCQuery cQuery New Alias "TMPAGE"
dbSelectArea("TMPAGE")
dbGoTop()

Do While !TMPAGE->( Eof() )
	nPrior++

	If nPrior > 3
		nPrior := 1
	EndIf

	oItem := FWCalendarActivity():New()
		oItem:SetID( AllTrim( TMPAGE->OP ) + AllTrim( TMPAGE->OPERACAO ) + AllTrim( TMPAGE->RECURSO ) )
		oItem:SetTitle("OP: " + AllTrim( TMPAGE->OP ) + "-" + AllTrim( TMPAGE->OPERACAO ))
		oItem:SetNotes("Operação: " + AllTrim( TMPAGE->OPERACAO ) + CRLF + "Recurso: " + AllTrim( TMPAGE->RECURSO ) + CRLF + "Origem: " + AllTrim( TMPAGE->ORIGEM ) )
		oItem:SetPriority( aPrior[nPrior] )
		oItem:SetDtIni( STOD( TMPAGE->DTINI ) )
		oItem:SetDtFin( STOD( TMPAGE->DTFIM ) )
		oItem:SetHrIni( TMPAGE->HRINI + ":00" )
		oItem:SetHrFin( TMPAGE->HRFIM + ":00" )
	aAdd( aItems, oItem)

	TMPAGE->( dbSkip() )
EndDo

TMPAGE->( dbCloseArea() )

RestArea(aArea)

Return aItems

Static Function AtuBrw2()

oBrwAna2:SetFilterDefault( " AllTrim( ANA2->D3_OP ) == AllTrim( ANA1->C2_NUM + ANA1->C2_ITEM + ANA1->C2_SEQUEN ) " )
oBrwAna2:ExecuteFilter( .T. )
oBrwAna2:GoTo(1,.T.)
oBrwAna2:Refresh(.T.)

Return Nil

Static Function fAtuWin7()

Local aArea := GetArea()

If ValType( oProd1 ) == "O"
	dbSelectArea("SB1")
	dbSetOrder(1)
	SB1->( dbSeek( xFilial("SB1") + SC2->C2_PRODUTO ) )

	oProd1:SetText( "Produto: " + AllTrim( SC2->C2_PRODUTO ) + " " + AllTrim( SB1->B1_DESC ) )
	oProd1:CtrlRefresh()
	oProd2:SetText( "Roteiro: " + SC2->C2_ROTEIRO + " Revisão: " + SC2->C2_REVISAO + " Qtd. Base: " + AllTrim( Str( SB1->B1_QB ) ) )
	oProd2:CtrlRefresh()

	nCustoReal := 0
	nCustoPrev := 0
	nCustoDif  := 0
	nTempoReal := 0
	nTempoPrev := 0
	nTempoDif  := 0

	cQuery := "SELECT SUM(CUSTOREAL) AS CUSTOREAL, SUM(CUSTOPREV) AS CUSTOPREV, SUM(TEMPOREAL) AS TEMPOREAL, SUM(TEMPOPREV) AS TEMPOPREV " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT SUM(D3_CUSTO1) AS CUSTOREAL, 0 AS CUSTOPREV, 0 AS TEMPOREAL, 0 AS TEMPOPREV " + CRLF
	cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD3") + " AS SD3 WITH (NOLOCK) ON D3_FILIAL = C2_FILIAL " + CRLF
	cQuery += "  AND D3_OP = C2_NUM + C2_ITEM + C2_SEQUEN " + CRLF
	cQuery += "  AND LEFT( D3_CF, 2) = 'PR' " + CRLF
	cQuery += "  AND SD3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
	cQuery += "AND C2_NUM = '" + SC2->C2_NUM + "' " + CRLF
	cQuery += "AND C2_ITEM = '" + SC2->C2_ITEM + "' " + CRLF
	cQuery += "AND C2_SEQUEN = '" + SC2->C2_SEQUEN + "' " + CRLF
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT 0 AS CUSTOREAL, SUM((((C2_QUANT / CASE B1_QB = 0 THEN 1 ELSE B1_QB END) * G1_QUANT) * B2_CM1)) AS CUSTOPREV, 0 AS TEMPOREAL, 0 AS TEMPOPREV " + CRLF
	cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = C2_PRODUTO " + CRLF
	//cQuery += "  AND B1_QB <> 0 " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SG1") + " AS SG1 WITH (NOLOCK) ON G1_FILIAL = '" + xFilial("SG1") + "' " + CRLF
	cQuery += "  AND G1_COD = B1_COD " + CRLF
	cQuery += "  AND C2_REVISAO >= G1_REVINI AND C2_REVISAO <= G1_REVFIM " + CRLF
	cQuery += "  AND SG1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) ON B2_FILIAL = C2_FILIAL " + CRLF
	cQuery += "  AND B2_COD = G1_COMP " + CRLF
	cQuery += "  AND B2_LOCAL IN (SELECT B1_LOCPAD FROM " + RetSqlName("SB1") + " WHERE B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = G1_COMP AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "  AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
	cQuery += "AND C2_NUM = '" + SC2->C2_NUM + "' " + CRLF
	cQuery += "AND C2_ITEM = '" + SC2->C2_ITEM + "' " + CRLF
	cQuery += "AND C2_SEQUEN = '" + SC2->C2_SEQUEN + "' " + CRLF
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT 0 AS CUSTOREAL, 0 AS CUSTOPREV, SUM(D3_QUANT) AS TEMPOREAL, 0 AS TEMPOPREV " + CRLF
	cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD3") + " AS SD3 WITH (NOLOCK) ON D3_FILIAL = C2_FILIAL " + CRLF
	cQuery += "  AND D3_OP = C2_NUM + C2_ITEM + C2_SEQUEN " + CRLF
	cQuery += "  AND LEFT( D3_CF, 2) = 'RE' " + CRLF
	cQuery += "  AND D3_UM = 'HR' " + CRLF
	cQuery += "  AND LEFT( D3_COD, 2) = '" + mv_par05 + "' " + CRLF
	cQuery += "  AND SD3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
	cQuery += "AND C2_NUM = '" + SC2->C2_NUM + "' " + CRLF
	cQuery += "AND C2_ITEM = '" + SC2->C2_ITEM + "' " + CRLF
	cQuery += "AND C2_SEQUEN = '" + SC2->C2_SEQUEN + "' " + CRLF
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT 0 AS CUSTOREAL, 0 AS CUSTOPREV, 0 AS TEMPOREAL, SUM((C2_QUANT / CASE WHEN G2_LOTEPAD = 0 THEN 1 ELSE G2_LOTEPAD END) * G2_TEMPAD) AS TEMPOPREV " + CRLF
	cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SG2") + " AS SG2 WITH (NOLOCK) ON G2_FILIAL = '" + xFilial("SG2") + "' " + CRLF
	cQuery += "  AND G2_PRODUTO = C2_PRODUTO " + CRLF
	cQuery += "  AND G2_CODIGO = C2_ROTEIRO " + CRLF
	cQuery += "  AND SG2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
	cQuery += "AND C2_NUM = '" + SC2->C2_NUM + "' " + CRLF
	cQuery += "AND C2_ITEM = '" + SC2->C2_ITEM + "' " + CRLF
	cQuery += "AND C2_SEQUEN = '" + SC2->C2_SEQUEN + "' " + CRLF
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF

	TCQuery cQuery New Alias "TMPCUS"
	dbSelectArea("TMPCUS")
	dbGoTop()

	If !TMPCUS->( Eof() )
		nCustoReal := TMPCUS->CUSTOREAL
		nCustoPrev := TMPCUS->CUSTOPREV
		nCustoDif  := TMPCUS->CUSTOREAL - TMPCUS->CUSTOPREV
		nTempoReal := TMPCUS->TEMPOREAL
		nTempoPrev := TMPCUS->TEMPOPREV
		nTempoDif  := TMPCUS->TEMPOREAL - TMPCUS->TEMPOPREV
	EndIf

	TMPCUS->( dbCloseArea() )

	rTempPad:SetText( Transform( nTempoPrev, "@E 999,999.99") )
	rTempPad:CtrlRefresh()
	rTempRea:SetText( Transform( nTempoReal, "@E 999,999.99") )
	rTempRea:CtrlRefresh()
	rTempDif:SetText( Transform( nTempoDif, "@E 999,999.99") )
	rTempDif:CtrlRefresh()
	rCustPad:SetText( Transform( nCustoPrev, "@E 999,999.99") )
	rCustPad:CtrlRefresh()
	rCustRea:SetText( Transform( nCustoReal, "@E 999,999.99") )
	rCustRea:CtrlRefresh()
	rCustDif:SetText( Transform( nCustoDif, "@E 999,999.99") )
	rCustDif:CtrlRefresh()

	nDireto  := 0
	nMaoObra := 0
	nEnergia := 0
	nGas     := 0
	nGGF     := 0

	cQuery := "SELECT SUM(DIRETO) AS DIRETO, SUM(MAOOBRA) AS MAOOBRA, SUM(ENERGIA) AS ENERGIA, SUM(GAS) AS GAS, SUM(GGF) AS GGF " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT CASE WHEN D3_UM <> 'HR' THEN SUM(D3_CUSTO1) ELSE 0 END AS DIRETO, " + CRLF
	cQuery += "       CASE WHEN D3_UM = 'HR' AND LEFT( D3_COD, 2) = '" + mv_par05 + "' THEN SUM(D3_CUSTO1) ELSE 0 END AS MAOOBRA, " + CRLF
	cQuery += "       CASE WHEN D3_UM = 'HR' AND LEFT( D3_COD, 2) = '" + mv_par06 + "' THEN SUM(D3_CUSTO1) ELSE 0 END AS ENERGIA, " + CRLF
	cQuery += "       CASE WHEN D3_UM = 'HR' AND LEFT( D3_COD, 2) = '" + mv_par07 + "' THEN SUM(D3_CUSTO1) ELSE 0 END AS GAS, " + CRLF
	cQuery += "       CASE WHEN D3_UM = 'HR' AND LEFT( D3_COD, 2) = '" + mv_par08 + "' THEN SUM(D3_CUSTO1) ELSE 0 END AS GGF " + CRLF
	cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD3") + " AS SD3 WITH (NOLOCK) ON D3_FILIAL = C2_FILIAL " + CRLF
	cQuery += "  AND D3_OP = C2_NUM + C2_ITEM + C2_SEQUEN " + CRLF
	cQuery += "  AND LEFT( D3_CF, 2) = 'RE' " + CRLF
	cQuery += "  AND SD3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
	cQuery += "AND C2_NUM = '" + SC2->C2_NUM + "' " + CRLF
	cQuery += "AND C2_ITEM = '" + SC2->C2_ITEM + "' " + CRLF
	cQuery += "AND C2_SEQUEN = '" + SC2->C2_SEQUEN + "' " + CRLF
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY D3_UM, LEFT( D3_COD, 2) " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF

	TCQuery cQuery New Alias "TMPCUS"
	dbSelectArea("TMPCUS")
	dbGoTop()

	If !TMPCUS->( Eof() )
		nDireto  := TMPCUS->DIRETO
		nMaoObra := TMPCUS->MAOOBRA
		nEnergia := TMPCUS->ENERGIA
		nGas     := TMPCUS->GAS
		nGGF     := TMPCUS->GGF
	EndIf

	TMPCUS->( dbCloseArea() )

	rCustDir:SetText( Transform( nDireto, "@E 999,999.99") )
	rCustDir:CtrlRefresh()
	rCustMod:SetText( Transform( nMaoObra, "@E 999,999.99") )
	rCustMod:CtrlRefresh()
	rCustEne:SetText( Transform( nEnergia, "@E 999,999.99") )
	rCustEne:CtrlRefresh()
	rCustGas:SetText( Transform( nGas, "@E 999,999.99") )
	rCustGas:CtrlRefresh()
	rCustGGF:SetText( Transform( nGGF, "@E 999,999.99") )
	rCustGGF:CtrlRefresh()
EndIf

RestArea( aArea )

Return