#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

// Programa Inicial da Faturamento
User Function BeP0503()

Local cQuery	:= ""
Local cAlias	:= GetNextAlias()
Local cMsgHdr	:= ""
Local cMsgBody	:= ""
Local cRetfun	:= "u_BePLogin.apw"
Local lSession 	:= Execblock("BePVSess",.F.,.F.) // Valida Sessão
Local cFilProd  := ""
Local cFilGrupo := ""
Local aRetSaldo	:= {}
Local nSaldo	:= 0
Local nTotPed	:= 0
Local cAnoAtu   := StrZero( Year( MsDate() )   , 4)
Local cAnoAnt   := StrZero( Year( MsDate() ) -1, 4)
Local cAnoAn2   := StrZero( Year( MsDate() ) -2, 4)
Local aAno      := {}
Local nAno      := 0
Local nPosAno   := 0
Local aSts      := {}
Local aDia      := {}
Local nSts      := 0
Local nTotEst   := 0
Local nTotLote  := 0
Local cPeriodo  := ""
Local nEuro     := 0
Local nQualy    := 0
Local nJays     := 0
Local nConsol   := 0
Local aVendido  := {}

Private cHtml 	:= ""    

WEB EXTENDED INIT cHtml                               

cHtml += Execblock("BePHeader",.F.,.F.)

If lSession 
	cDataBase := HttpSession->cDataPC

	cHtml += Execblock("BePMenus",.F.,.F.)
	
	cHtml += '<div class="main" style="margin-top: 50px;">'
	cHtml += '	<h2><i class="fas fa-dolly"></i> Faturamento: Por Operações no Período</h2>'
	cHtml += '	<hr/>'
	//cHtml += '  <form method="POST" id="formpc" action="u_bep0206A.apw" class="col-md-12" style="margin-bottom: 10px;">'+CRLF

	Do Case
		Case Month( dDataBase ) == 1
			cPeriodo := "Janeiro / " + Left( DTOS( dDataBase ), 4)
		Case Month( dDataBase ) == 2
			cPeriodo := "Fevereiro / " + Left( DTOS( dDataBase ), 4)
		Case Month( dDataBase ) == 3
			cPeriodo := "Março / " + Left( DTOS( dDataBase ), 4)
		Case Month( dDataBase ) == 4
			cPeriodo := "Abril / " + Left( DTOS( dDataBase ), 4)
		Case Month( dDataBase ) == 5
			cPeriodo := "Maio / " + Left( DTOS( dDataBase ), 4)
		Case Month( dDataBase ) == 6
			cPeriodo := "Junho / " + Left( DTOS( dDataBase ), 4)
		Case Month( dDataBase ) == 7
			cPeriodo := "Julho / " + Left( DTOS( dDataBase ), 4)
		Case Month( dDataBase ) == 8
			cPeriodo := "Agosto / " + Left( DTOS( dDataBase ), 4)
		Case Month( dDataBase ) == 9
			cPeriodo := "Setembro / " + Left( DTOS( dDataBase ), 4)
		Case Month( dDataBase ) == 10
			cPeriodo := "Outubro / " + Left( DTOS( dDataBase ), 4)
		Case Month( dDataBase ) == 11
			cPeriodo := "Novembro / " + Left( DTOS( dDataBase ), 4)
		Case Month( dDataBase ) == 12
			cPeriodo := "Dezembro / " + Left( DTOS( dDataBase ), 4)
		Otherwise
			cPeriodo := Left( DTOS( dDataBase ), 4)
	EndCase

/********************************************************************************************************************************/
/********************************************************************************************************************************/

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-pie-chart fa-1x"></i> Dashboards Faturamentos Período: ' + cPeriodo + '</H3>'+CRLF
	cHtml += '    </div>'+CRLF

	cQuery := "SELECT EMPRESA, TIPO, VALOR - CUSTOMEDIO AS MARGEM_S_CUSTO, CONVERT(DECIMAL(14,2),((ABS(CUSTOMEDIO) / ABS(VALOR))) * 100) AS FATOR_S_CUSTO, VALOR - CUSTOSTANDARD AS MARGEM_S_STD, CONVERT(DECIMAL(14,2),(1 + (1 - (ABS(CUSTOSTANDARD) / ABS(VALOR))))) AS FATOR_S_STD, VALOR, VALBRUTO, BASECOM, CUSTOMEDIO " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT * FROM ( " + CRLF
	cQuery += "SELECT CASE WHEN LEFT( D2_FILIAL, 2) = '01' THEN 'Loja de Tintas' ELSE 'Outra' " + CRLF
	cQuery += "END AS EMPRESA, " + CRLF
	cQuery += "'Faturado' AS TIPO, ISNULL(SUM(D2_VALBRUT - D2_VALIPI - D2_VALICM - D2_VALIMP5 - D2_VALIMP6 - D2_DESPESA - D2_VALFRE - D2_DESCON - D2_SEGURO - D2_ICMSRET), 0) AS VALOR, ISNULL(SUM(D2_CUSTO1), 0) AS CUSTOMEDIO, ISNULL(SUM(D2_QUANT * B1_CUSTD),0) AS CUSTOSTANDARD, ISNULL(SUM(D2_VALBRUT), 0) AS VALBRUTO, ISNULL(SUM(D2_VALBRUT - D2_VALIPI - D2_ICMSRET), 0) AS BASECOM " + CRLF
	cQuery += "FROM " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF2") + " AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL " + CRLF
	cQuery += "  AND F2_DOC = D2_DOC " + CRLF
	cQuery += "  AND F2_SERIE = D2_SERIE " + CRLF
	cQuery += "  AND F2_CLIENTE = D2_CLIENTE " + CRLF
	cQuery += "  AND F2_LOJA = D2_LOJA " + CRLF
	cQuery += "  AND F2_TIPO = D2_TIPO " + CRLF
	cQuery += "  AND F2_EMISSAO = D2_EMISSAO " + CRLF
	cQuery += "  AND SF2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(D2_FILIAL, 2) " + CRLF
	cQuery += "  AND F4_CODIGO = D2_TES " + CRLF
	cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5919') " + CRLF
	cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + XFILIAL("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = D2_COD " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE D2_FILIAL <> '****' " + CRLF
	cQuery += "AND D2_TIPO = 'N' " + CRLF
	cQuery += "AND LEFT( D2_EMISSAO, 6) = '" + Left( DTOS( dDataBase ), 6) + "' " + CRLF 
	cQuery += "AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = D2_FILIAL AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND SD2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY LEFT(D2_FILIAL, 2) " + CRLF

	cQuery += "UNION ALL " + CRLF

	cQuery += "SELECT CASE WHEN LEFT( D1_FILIAL, 2) = '01' THEN 'Loja de Tintas' ELSE 'Outra' " + CRLF
	cQuery += "END AS EMPRESA, " + CRLF
	cQuery += "'Devolvido' AS TIPO, ISNULL(SUM((D1_TOTAL)) * (-1), 0) AS VALOR, ISNULL(SUM(D1_CUSTO) * (-1), 0) AS CUSTOMEDIO, ISNULL(SUM(D1_QUANT * B1_CUSTD) * (-1),0) AS CUSTOSTANDARD, 0 AS VALBRUTO, ISNULL(SUM((D1_TOTAL)) * (-1), 0) AS BASECOM " + CRLF
	cQuery += "FROM " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) ON D2_FILIAL = D1_FILIAL " + CRLF
	cQuery += "  AND D2_DOC = D1_NFORI " + CRLF
	cQuery += "  AND D2_SERIE = D1_SERIORI " + CRLF
	cQuery += "  AND D2_CLIENTE = D1_FORNECE " + CRLF
	cQuery += "  AND D2_LOJA = D1_LOJA " + CRLF
	cQuery += "  AND D2_ITEM = D1_ITEMORI " + CRLF
	cQuery += "  AND D2_TIPO = 'N' " + CRLF
	cQuery += "  AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = D2_FILIAL AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "  AND SD2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF2") + " AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL " + CRLF
	cQuery += "  AND F2_DOC = D2_DOC " + CRLF
	cQuery += "  AND F2_SERIE = D2_SERIE " + CRLF
	cQuery += "  AND F2_CLIENTE = D2_CLIENTE " + CRLF
	cQuery += "  AND F2_LOJA = D2_LOJA " + CRLF
	cQuery += "  AND F2_TIPO = D2_TIPO " + CRLF
	cQuery += "  AND F2_EMISSAO = D2_EMISSAO " + CRLF
	cQuery += "  AND SF2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(D2_FILIAL, 2) " + CRLF
	cQuery += "  AND F4_CODIGO = D2_TES " + CRLF
	cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5919') " + CRLF
	cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + XFILIAL("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = D2_COD " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE D1_FILIAL <> '****' " + CRLF
	cQuery += "AND D1_TIPO = 'D' " + CRLF
	cQuery += "AND LEFT( D1_DTDIGIT, 6) = '" + Left( DTOS( dDataBase ), 6) + "' " + CRLF 
	cQuery += "AND SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY LEFT(D1_FILIAL, 2) " + CRLF

	cQuery += "UNION ALL " + CRLF

	cQuery += "SELECT CASE WHEN LEFT( C6_FILIAL, 2) = '01' THEN 'Loja de Tintas' ELSE 'Outra' " + CRLF
	cQuery += "END AS EMPRESA, " + CRLF
	cQuery += "'Carteira' AS TIPO, ISNULL(SUM(((C6_QTDVEN - C6_QTDENT ) * C6_PRCVEN)), 0) AS VALOR, ISNULL(SUM(((C6_QTDVEN - C6_QTDENT ) * B2_CM1)), 0) AS CUSTOMEDIO, ISNULL(SUM((C6_QTDVEN - C6_QTDENT ) * B1_CUSTD),0) AS CUSTOSTANDARD, ISNULL(SUM(((C6_QTDVEN - C6_QTDENT ) * C6_PRCVEN)), 0) AS VALBRUTO, 0 AS BASECOM " + CRLF
	cQuery += "FROM " + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SC5") + " AS SC5 WITH (NOLOCK) ON C5_FILIAL = C6_FILIAL " + CRLF
	cQuery += "  AND C5_NUM = C6_NUM " + CRLF
	cQuery += "  AND C5_TIPO = 'N' " + CRLF
	cQuery += "  AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = C5_FILIAL AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "  AND SC5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(C6_FILIAL, 2) " + CRLF
	cQuery += "  AND F4_CODIGO = C6_TES " + CRLF
	cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5919') " + CRLF
	cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + XFILIAL("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = C6_PRODUTO " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) ON B2_FILIAL = C6_FILIAL " + CRLF
	cQuery += "  AND B2_COD = C6_PRODUTO " + CRLF
	cQuery += "  AND B2_LOCAL = C6_LOCAL " + CRLF
	cQuery += "  AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C6_FILIAL <> '****' " + CRLF
	cQuery += "AND C6_BLQ = '' " + CRLF
	cQuery += "AND C6_QTDVEN > C6_QTDENT " + CRLF
	cQuery += "AND SC6.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY LEFT(C6_FILIAL, 2) " + CRLF

	cQuery += "UNION ALL " + CRLF

	cQuery += "SELECT CASE WHEN LEFT( C6_FILIAL, 2) = '01' THEN 'Loja de Tintas' ELSE 'Outra' " + CRLF
	cQuery += "END AS EMPRESA, " + CRLF
	cQuery += "'Vendido no Dia' AS TIPO, ISNULL(SUM(((C6_QTDVEN) * C6_PRCVEN)), 0) AS VALOR, ISNULL(SUM(((C6_QTDVEN) * B2_CM1)), 0) AS CUSTOMEDIO, ISNULL(SUM((C6_QTDVEN) * B1_CUSTD),0) AS CUSTOSTANDARD, ISNULL(SUM(((C6_QTDVEN) * C6_PRCVEN)), 0) AS VALBRUTO, 0 AS BASECOM " + CRLF
	cQuery += "FROM " + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SC5") + " AS SC5 WITH (NOLOCK) ON C5_FILIAL = C6_FILIAL " + CRLF
	cQuery += "  AND C5_NUM = C6_NUM " + CRLF
	cQuery += "  AND C5_TIPO = 'N' " + CRLF
	cQuery += "  AND C5_EMISSAO = '" + DTOS( dDataBase ) + "' " + CRLF
	cQuery += "  AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = C5_FILIAL AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "  AND SC5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(C6_FILIAL, 2) " + CRLF
	cQuery += "  AND F4_CODIGO = C6_TES " + CRLF
	cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5919') " + CRLF
	cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + XFILIAL("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = C6_PRODUTO " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) ON B2_FILIAL = C6_FILIAL " + CRLF
	cQuery += "  AND B2_COD = C6_PRODUTO " + CRLF
	cQuery += "  AND B2_LOCAL = C6_LOCAL " + CRLF
	cQuery += "  AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C6_FILIAL <> '****' " + CRLF
	cQuery += "AND C6_BLQ = '' " + CRLF
	cQuery += "AND SC6.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY LEFT(C6_FILIAL, 2) " + CRLF

	cQuery += "UNION ALL " + CRLF

	cQuery += "SELECT CASE WHEN LEFT( C6_FILIAL, 2) = '01' THEN 'Loja de Tintas' ELSE 'Outra' "+ CRLF
	cQuery += "END AS EMPRESA, " + CRLF
	cQuery += "'Previsto Entrega no Dia' AS TIPO, ISNULL(SUM(((C6_QTDVEN) * C6_PRCVEN)), 0) AS VALOR, ISNULL(SUM(((C6_QTDVEN) * B2_CM1)), 0) AS CUSTOMEDIO, ISNULL(SUM((C6_QTDVEN) * B1_CUSTD),0) AS CUSTOSTANDARD, ISNULL(SUM(((C6_QTDVEN) * C6_PRCVEN)), 0) AS VALBRUTO, 0 AS BASECOM " + CRLF
	cQuery += "FROM " + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SC5") + " AS SC5 WITH (NOLOCK) ON C5_FILIAL = C6_FILIAL " + CRLF
	cQuery += "  AND C5_NUM = C6_NUM " + CRLF
	cQuery += "  AND C5_TIPO = 'N' " + CRLF
	cQuery += "  AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = C5_FILIAL AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "  AND SC5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(C6_FILIAL, 2) " + CRLF
	cQuery += "  AND F4_CODIGO = C6_TES " + CRLF
	cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5919') " + CRLF
	cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + XFILIAL("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = C6_PRODUTO " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) ON B2_FILIAL = C6_FILIAL " + CRLF
	cQuery += "  AND B2_COD = C6_PRODUTO " + CRLF
	cQuery += "  AND B2_LOCAL = C6_LOCAL " + CRLF
	cQuery += "  AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C6_FILIAL <> '****' " + CRLF
	cQuery += "AND C6_BLQ = '' " + CRLF
	cQuery += "AND C6_ENTREG = '" + DTOS( dDataBase ) + "' " + CRLF
	cQuery += "AND SC6.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY LEFT(C6_FILIAL, 2) " + CRLF

	cQuery += ") AS AGRUP_SEM " + CRLF
	cQuery += "WHERE VALOR <> 0 " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF
	
	TCQuery cQuery New Alias "TMP001"
	dbSelectArea("TMP001")
	TMP001->( dbGoTop() )

	conout( "1 ******************************************************" )
	conout( cQuery )
	conout( "1 ******************************************************" )

	aVendido := {}
	aSts     := {}
	nEuro    := 0
	nQualy   := 0
	nJays    := 0
	nPhoe    := 0
	nMetro   := 0
	nVinil   := 0
	nConsol  := 0

	aAdd( aSts, { 0, 0, 0, 0, 0, 0 })

	Do While !TMP001->( Eof() )
		If AllTrim( TMP001->TIPO ) == "Faturado"
			If AllTrim( TMP001->EMPRESA ) == "Loja de Tintas"
				nEuro        += TMP001->VALOR
				aSts[01][01] += TMP001->VALOR
			EndIf
			nConsol += TMP001->VALOR
		EndIf

		aAdd( aVendido, { 	AllTrim( TMP001->EMPRESA ),;
							AllTrim( TMP001->TIPO ),;
							TMP001->MARGEM_S_CUSTO,;
							TMP001->FATOR_S_CUSTO,;
							TMP001->MARGEM_S_STD,;
							TMP001->FATOR_S_STD,;
							TMP001->VALOR })

		TMP001->( dbSkip() )
	EndDo
	
	TMP001->( dbCloseArea() )

		cHtml += '		<div class="row">' + CRLF
		cHtml += '			<div class="col-lg-3 col-md-6">' + CRLF
		cHtml += '				<div class="panel panel-primary">' + CRLF
		cHtml += '					<div class="panel-heading">' + CRLF
		cHtml += '						<div class="row">' + CRLF
		cHtml += '							<div class="col-xs-3">' + CRLF
		cHtml += '								<i class="fa fa-usd fa-5x"></i>' + CRLF //<i class="fa fa-tasks fa-5x"></i>
		cHtml += '							</div>' + CRLF
		cHtml += '							<div class="col-xs-9 text-right">' + CRLF
		cHtml += '								<div class="huge"><B>' + AllTrim( Transform( nEuro, "@E 999,999,999,999.99") ) + '</B></div>' + CRLF
		cHtml += '								<div>Loja de Tintas<Br>R$ [REAL]</div>' + CRLF
		cHtml += '							</div>' + CRLF
		cHtml += '						</div>' + CRLF
		cHtml += '					</div>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
		cHtml += '			<div class="col-lg-3 col-md-6">' + CRLF
		cHtml += '				<div class="panel panel-warning">' + CRLF
		cHtml += '					<div class="panel-heading">' + CRLF
		cHtml += '						<div class="row">' + CRLF
		cHtml += '							<div class="col-xs-3">' + CRLF
		cHtml += '								<i class="fa fa-usd fa-5x"></i>' + CRLF
		cHtml += '							</div>' + CRLF
		cHtml += '							<div class="col-xs-9 text-right">' + CRLF
		cHtml += '								<div class="huge"><B>' + AllTrim( Transform( nConsol, "@E 999,999,999,999.99") ) + '</B></div>' + CRLF
		cHtml += '								<div>Total Consolidado<Br>R$ [REAL]</div>' + CRLF
		cHtml += '							</div>' + CRLF
		cHtml += '						</div>' + CRLF
		cHtml += '					</div>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
		cHtml += '		</div>' + CRLF

		nMedDol := 0
	
		cQuery := "SELECT AVG( M2_MOEDA2 ) AS MEDIADOLAR " + CRLF
		cQuery += "FROM " + RetSqlName("SM2") + " AS SM2 WITH (NOLOCK) " + CRLF
		cQuery += "WHERE LEFT( M2_DATA, 6) = LEFT( CONVERT(VARCHAR(8), DATEADD( MM, -1, GETDATE() ), 112), 6) " + CRLF
		cQuery += "AND SM2.D_E_L_E_T_ = ' ' " + CRLF
	
		TCQuery cQuery New Alias "MEDDOL"
		dbSelectArea("MEDDOL")
		dbGoTop()
	
		If !MEDDOL->( Eof() )
			nMedDol := MEDDOL->MEDIADOLAR
		EndIf
	
		MEDDOL->( dbCloseArea() )

		dbSelectArea("SM2")
		dbSetOrder(1)
		dbSeek( dDataBase )

		cHtml += '		<div class="row">' + CRLF
		cHtml += '			<div class="col-lg-6 col-md-6">' + CRLF
		cHtml += '				<div class="panel panel-default">' + CRLF
		cHtml += '					<div class="panel-heading">' + CRLF
		cHtml += '						<div class="row">' + CRLF
		cHtml += '							<div class="col-xs-9 text-right">' + CRLF
		cHtml += '								<div class="huge"><B>Taxa Média Dólar: ' + AllTrim( Transform( nMedDol, "@E 9,999.999999") ) + '</B></div>' + CRLF
		cHtml += '							</div>' + CRLF
		cHtml += '						</div>' + CRLF
		cHtml += '					</div>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
		cHtml += '			<div class="col-lg-6 col-md-6">' + CRLF
		cHtml += '				<div class="panel panel-default">' + CRLF
		cHtml += '					<div class="panel-heading">' + CRLF
		cHtml += '						<div class="row">' + CRLF
		cHtml += '							<div class="col-xs-9 text-right">' + CRLF
		cHtml += '								<div class="huge"><B>Taxa Dólar Atual: ' + AllTrim( Transform( SM2->M2_MOEDA2, "@E 9,999.999999") ) + '</B></div>' + CRLF
		cHtml += '							</div>' + CRLF
		cHtml += '						</div>' + CRLF
		cHtml += '					</div>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
		cHtml += '		</div>' + CRLF

		cHtml += '<HR>' + CRLF

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-bars fa-1x"></i> Posição do Faturamento por Operações Consolidado</H3>'+CRLF
	cHtml += '    </div>'+CRLF

	//Table
	cHtml += '	<div  class="col-md-12" style="overflow-x:auto; width=100%; overflow-y:auto;">'+CRLF

	cQuery := "SELECT OPERACAO, DESCRICAO, " + CRLF
	cQuery += "SUM(EURO_BRU) AS EURO_BRU, SUM(EURO) AS EURO, SUM(EURO_DEV) AS EURO_DEV, " + CRLF
	cQuery += "SUM(QUALY_BRU) AS QUALY_BRU, SUM(QUALY) AS QUALY, SUM(QUALY_DEV) AS QUALY_DEV, " + CRLF
	cQuery += "SUM(JAYS_BRU) AS JAYS_BRU, SUM(JAYS) AS JAYS, SUM(JAYS_DEV) AS JAYS_DEV, " + CRLF
	cQuery += "SUM(PHOE_BRU) AS PHOE_BRU, SUM(PHOE) AS PHOE, SUM(PHOE_DEV) AS PHOE_DEV, " + CRLF
	cQuery += "SUM(METR_BRU) AS METR_BRU, SUM(METR) AS METR, SUM(METR_DEV) AS METR_DEV, " + CRLF
	cQuery += "SUM(VINI_BRU) AS VINI_BRU, SUM(VINI) AS VINI, SUM(VINI_DEV) AS VINI_DEV " + CRLF
	cQuery += "FROM  ( " + CRLF
	cQuery += "SELECT X5_CHAVE AS OPERACAO, X5_DESCRI AS DESCRICAO, " + CRLF
	cQuery += "CASE WHEN LEFT(D2_FILIAL, 2) = '01' THEN SUM(D2_TOTAL) ELSE 0 END AS EURO_BRU, " + CRLF
	cQuery += "CASE WHEN LEFT(D2_FILIAL, 2) = '01' THEN SUM(D2_VALBRUT - D2_VALIPI - D2_VALICM - D2_VALIMP5 - D2_VALIMP6 - D2_DESPESA - D2_VALFRE - D2_DESCON - D2_SEGURO - D2_ICMSRET) ELSE 0 END AS EURO, " + CRLF
	cQuery += "0 AS EURO_DEV, " + CRLF
	cQuery += "CASE WHEN LEFT(D2_FILIAL, 2) = '88' THEN SUM(D2_TOTAL) ELSE 0 END AS QUALY_BRU, " + CRLF
	cQuery += "CASE WHEN LEFT(D2_FILIAL, 2) = '88' THEN SUM(D2_VALBRUT - D2_VALIPI - D2_VALICM - D2_VALIMP5 - D2_VALIMP6 - D2_DESPESA - D2_VALFRE - D2_DESCON - D2_SEGURO - D2_ICMSRET) ELSE 0 END AS QUALY, " + CRLF
	cQuery += "0 AS QUALY_DEV, " + CRLF
	cQuery += "CASE WHEN LEFT(D2_FILIAL, 2) = '89' THEN SUM(D2_TOTAL) ELSE 0 END AS JAYS_BRU, " + CRLF
	cQuery += "CASE WHEN LEFT(D2_FILIAL, 2) = '89' THEN SUM(D2_VALBRUT - D2_VALIPI - D2_VALICM - D2_VALIMP5 - D2_VALIMP6 - D2_DESPESA - D2_VALFRE - D2_DESCON - D2_SEGURO - D2_ICMSRET) ELSE 0 END AS JAYS, " + CRLF
	cQuery += "0 AS JAYS_DEV, " + CRLF
	cQuery += "CASE WHEN LEFT(D2_FILIAL, 2) = '90' THEN SUM(D2_TOTAL) ELSE 0 END AS PHOE_BRU, " + CRLF
	cQuery += "CASE WHEN LEFT(D2_FILIAL, 2) = '91' THEN SUM(D2_VALBRUT - D2_VALIPI - D2_VALICM - D2_VALIMP5 - D2_VALIMP6 - D2_DESPESA - D2_VALFRE - D2_DESCON - D2_SEGURO - D2_ICMSRET) ELSE 0 END AS PHOE, " + CRLF
	cQuery += "0 AS PHOE_DEV, " + CRLF
	cQuery += "CASE WHEN LEFT(D2_FILIAL, 2) = '92' THEN SUM(D2_TOTAL) ELSE 0 END AS METR_BRU, " + CRLF
	cQuery += "CASE WHEN LEFT(D2_FILIAL, 2) = '93' THEN SUM(D2_VALBRUT - D2_VALIPI - D2_VALICM - D2_VALIMP5 - D2_VALIMP6 - D2_DESPESA - D2_VALFRE - D2_DESCON - D2_SEGURO - D2_ICMSRET) ELSE 0 END AS METR, " + CRLF
	cQuery += "0 AS METR_DEV, " + CRLF
	cQuery += "CASE WHEN LEFT(D2_FILIAL, 2) = '94' THEN SUM(D2_TOTAL) ELSE 0 END AS VINI_BRU, " + CRLF
	cQuery += "CASE WHEN LEFT(D2_FILIAL, 2) = '95' THEN SUM(D2_VALBRUT - D2_VALIPI - D2_VALICM - D2_VALIMP5 - D2_VALIMP6 - D2_DESPESA - D2_VALFRE - D2_DESCON - D2_SEGURO - D2_ICMSRET) ELSE 0 END AS VINI, " + CRLF
	cQuery += "0 AS VINI_DEV " + CRLF
	cQuery += "FROM " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF2") + " AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL " + CRLF
	cQuery += "  AND F2_DOC = D2_DOC " + CRLF
	cQuery += "  AND F2_SERIE = D2_SERIE " + CRLF
	cQuery += "  AND F2_CLIENTE = D2_CLIENTE " + CRLF
	cQuery += "  AND F2_LOJA = D2_LOJA " + CRLF
	cQuery += "  AND F2_TIPO = D2_TIPO " + CRLF
	cQuery += "  AND F2_EMISSAO = D2_EMISSAO " + CRLF
	cQuery += "  AND SF2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(D2_FILIAL, 2) " + CRLF
	cQuery += "  AND F4_CODIGO = D2_TES " + CRLF
	cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5919') " + CRLF
	cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SX5") + " AS SX5 WITH (NOLOCK) ON X5_FILIAL = ' ' " + CRLF
	cQuery += "  AND X5_TABELA = '13' " + CRLF
	cQuery += "  AND X5_CHAVE = '5' + SUBSTRING( F4_CF, 2, 3) " + CRLF
	cQuery += "  AND SX5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE D2_FILIAL <> '****' " + CRLF
	cQuery += "AND D2_TIPO = 'N' " + CRLF
	cQuery += "AND LEFT(D2_EMISSAO, 6) = '" + Left( DTOS( dDataBase ), 6) + "' " + CRLF
	cQuery += "AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = D2_FILIAL AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND SD2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY X5_CHAVE, X5_DESCRI, LEFT(D2_FILIAL, 2) " + CRLF

	cQuery += "UNION ALL " + CRLF

	cQuery += "SELECT X5_CHAVE AS OPERACAO, X5_DESCRI AS DESCRICAO, " + CRLF
	cQuery += "0 AS EURO_BRU, " + CRLF
	cQuery += "0 AS EURO, " + CRLF
	cQuery += "CASE WHEN LEFT(D1_FILIAL, 2) = '01' THEN SUM((D1_TOTAL)) * (-1) ELSE 0 END AS EURO_DEV, " + CRLF
	cQuery += "0 AS QUALY_BRU, " + CRLF
	cQuery += "0 AS QUALY, " + CRLF
	cQuery += "CASE WHEN LEFT(D1_FILIAL, 2) = '98' THEN SUM((D1_TOTAL )) * (-1) ELSE 0 END AS QUALY_DEV, " + CRLF
	cQuery += "0 AS JAYS_BRU, " + CRLF
	cQuery += "0 AS JAYS, " + CRLF
	cQuery += "CASE WHEN LEFT(D1_FILIAL, 2) = '91' THEN SUM((D1_TOTAL)) * (-1) ELSE 0 END AS JAYS_DEV, " + CRLF
	cQuery += "0 AS PHOE_BRU, " + CRLF
	cQuery += "0 AS PHOE, " + CRLF
	cQuery += "CASE WHEN LEFT(D1_FILIAL, 2) = '92' THEN SUM((D1_TOTAL)) * (-1) ELSE 0 END AS PHOE_DEV, " + CRLF
	cQuery += "0 AS METR_BRU, " + CRLF
	cQuery += "0 AS METR, " + CRLF
	cQuery += "CASE WHEN LEFT(D1_FILIAL, 2) = '93' THEN SUM((D1_TOTAL)) * (-1) ELSE 0 END AS METR_DEV, " + CRLF
	cQuery += "0 AS VINI_BRU, " + CRLF
	cQuery += "0 AS VINI, " + CRLF
	cQuery += "CASE WHEN LEFT(D1_FILIAL, 2) = '94' THEN SUM((D1_TOTAL)) * (-1) ELSE 0 END AS VINI_DEV " + CRLF
	cQuery += "FROM " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) ON D2_FILIAL = D1_FILIAL " + CRLF
	cQuery += "  AND D2_DOC = D1_NFORI " + CRLF
	cQuery += "  AND D2_SERIE = D1_SERIORI " + CRLF
	cQuery += "  AND D2_CLIENTE = D1_FORNECE " + CRLF
	cQuery += "  AND D2_LOJA = D1_LOJA " + CRLF
	cQuery += "  AND D2_ITEM = D1_ITEMORI " + CRLF
	cQuery += "  AND D2_TIPO = 'N' " + CRLF
	cQuery += "  AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = D2_FILIAL AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "  AND SD2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF2") + " AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL " + CRLF
	cQuery += "  AND F2_DOC = D2_DOC " + CRLF
	cQuery += "  AND F2_SERIE = D2_SERIE " + CRLF
	cQuery += "  AND F2_CLIENTE = D2_CLIENTE " + CRLF
	cQuery += "  AND F2_LOJA = D2_LOJA " + CRLF
	cQuery += "  AND F2_TIPO = D2_TIPO " + CRLF
	cQuery += "  AND F2_EMISSAO = D2_EMISSAO " + CRLF
	cQuery += "  AND SF2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(D2_FILIAL, 2) " + CRLF
	cQuery += "  AND F4_CODIGO = D2_TES " + CRLF
	cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5919') " + CRLF
	cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SX5") + " AS SX5 WITH (NOLOCK) ON X5_FILIAL = ' ' " + CRLF
	cQuery += "  AND X5_TABELA = '13' " + CRLF
	cQuery += "  AND X5_CHAVE = '5' + SUBSTRING( F4_CF, 2, 3) " + CRLF
	cQuery += "  AND SX5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE D1_FILIAL <> '****' " + CRLF
	cQuery += "AND D1_TIPO = 'D' " + CRLF
	cQuery += "AND LEFT(D1_DTDIGIT, 6) = '" + Left( DTOS( dDataBase ), 6) + "' " + CRLF
	cQuery += "AND SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY X5_CHAVE, X5_DESCRI, LEFT(D1_FILIAL, 2) " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF
	cQuery += "GROUP BY OPERACAO, DESCRICAO " + CRLF
	cQuery += "ORDER BY OPERACAO, DESCRICAO " + CRLF

	TCQuery cQuery New Alias "TMP001"
	dbSelectArea("TMP001")
	dbGoTop()

	conout( "2 ******************************************************" )
	conout( cQuery )
	conout( "2 ******************************************************" )

	cHtml += '    <div class="form-group" style="max-height:300px; ">'+CRLF
	cHtml += '    	<table id="table" class="table table-bordered table-striped table-condensed col-md-12">'+CRLF
	cHtml += '    		<thead>'+CRLF
	cHtml += '      		<tr>'+CRLF
	cHtml += '		  			<th>Operação</th>'+CRLF
	cHtml += '        			<th>Descrição</th>'+CRLF
	cHtml += '        			<th>Fat. B Loja Tinta</th>'+CRLF
	cHtml += '        			<th>Fat. L Loja Tinta</th>'+CRLF
	cHtml += '        			<th>Dev. Loja Tinta</th>'+CRLF
	cHtml += '      		</tr>'+CRLF
	cHtml += '    		</thead>'+CRLF
	cHtml += '			<tbody>'+CRLF
	
	nBEuro    := 0
	nFEuro    := 0
	nDEuro    := 0
	nBQualy   := 0
	nFQualy   := 0
	nDQualy   := 0
	nBJays    := 0
	nFJays    := 0
	nDJays    := 0
	nBPhoe    := 0
	nFPhoe    := 0
	nDPhoe    := 0
	nBMetr    := 0
	nFMetr    := 0
	nDMetr    := 0
	nBVini    := 0
	nFVini    := 0
	nDVini    := 0

	Do While !TMP001->( Eof() )
		cHtml += '				<tr>'+CRLF
		cHtml += '        			<td>'+TMP001->OPERACAO+'</td>'+CRLF
		cHtml += '        			<td>'+TMP001->DESCRICAO+'</td>'+CRLF
		cHtml += '        			<td style="text-align: right;">'+Transform(TMP001->EURO_BRU,PesqPict("SB2","B2_VATU1"))+'</td>'+CRLF
		cHtml += '        			<td style="text-align: right;">'+Transform(TMP001->EURO,PesqPict("SB2","B2_VATU1"))+'</td>'+CRLF
		cHtml += '        			<td style="text-align: right;">'+Transform(TMP001->EURO_DEV,PesqPict("SB2","B2_VATU1"))+'</td>'+CRLF
		cHtml += '      		</tr>'+CRLF

		nBEuro  += TMP001->EURO_BRU
		nFEuro  += TMP001->EURO
		nDEuro  += TMP001->EURO_DEV
		nBQualy += TMP001->QUALY_BRU
		nFQualy += TMP001->QUALY
		nDQualy += TMP001->QUALY_DEV
		nBJays  += TMP001->JAYS_BRU
		nFJays  += TMP001->JAYS
		nDJays  += TMP001->JAYS_DEV
		nBPhoe  += TMP001->PHOE_BRU
		nFPhoe  += TMP001->PHOE
		nDPhoe  += TMP001->PHOE_DEV
		nBMetr  += TMP001->METR_BRU
		nFMetr  += TMP001->METR
		nDMetr  += TMP001->METR_DEV
		nBVini  += TMP001->VINI_BRU
		nFVini  += TMP001->VINI
		nDVini  += TMP001->VINI_DEV

		TMP001->( dbSkip() )
	EndDo

	TMP001->( dbCloseArea() )

	cHtml += '				<tr>'+CRLF
	cHtml += '        			<td><B>Total:</B></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td style="text-align: right;"><B>'+Transform(nBEuro,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
	cHtml += '        			<td style="text-align: right;"><B>'+Transform(nFEuro,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
	cHtml += '        			<td style="text-align: right;"><B>'+Transform(nDEuro,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
	cHtml += '      		</tr>'+CRLF
	cHtml += '    		</tbody>'+CRLF
	cHtml += '  	</table>'+CRLF
	cHtml += '	  </div>'+CRLF

	cHtml += '  </div>'+CRLF

	cHtml += '<HR>' + CRLF

	cHtml += '	</div>'
	cHtml += '</div>'
	
Else	
	cMsgHdr		:= "BEP0501 - Sessão não Iniciada"
	cMsgBody	:= "A sessão não foi iniciada, realize o Login!"

	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 

EndIf

cHtml += Execblock("BePFooter",.F.,.F.)

WEB EXTENDED END
	
Return (EncodeUTF8(cHtml))
