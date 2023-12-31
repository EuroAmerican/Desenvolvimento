#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

// Programa Inicial da Faturamento
User Function BeP0502()

Local cQuery	:= ""
Local cAlias	:= GetNextAlias()
Local cMsgHdr	:= ""
Local cMsgBody	:= ""
Local cRetfun	:= "u_BePLogin.apw"
Local lSession 	:= Execblock("BePVSess",.F.,.F.) // Valida Sess�o
Local cFilProd  := ""
Local cFilGrupo := ""
Local aRetSaldo	:= {}
Local nSaldo	:= 0
Local nTotPed	:= 0
Local nRegSM0	:= SM0->(Recno())
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
//Local lGerente  := .F.
Local cCodGer   := ""
Local aVisGer   := {}
Local aVendedor := {}
Local aCores    := {}
Local nCor      := 0

Private cHtml 	:= ""    

aAdd( aCores, {'#6A5ACD'})
aAdd( aCores, {'#836FFF'})
aAdd( aCores, {'#6959CD'})
aAdd( aCores, {'#483D8B'})
aAdd( aCores, {'#191970'})
aAdd( aCores, {'#000080'})
aAdd( aCores, {'#00008B'})
aAdd( aCores, {'#0000CD'})
aAdd( aCores, {'#0000FF'})
aAdd( aCores, {'#6495ED'})
aAdd( aCores, {'#4169E1'})
aAdd( aCores, {'#1E90FF'})
aAdd( aCores, {'#00BFFF'})
aAdd( aCores, {'#87CEFA'})
aAdd( aCores, {'#87CEEB'})
aAdd( aCores, {'#ADD8E6'})
aAdd( aCores, {'#4682B4'})
aAdd( aCores, {'#B0C4DE'})
aAdd( aCores, {'#708090'})
aAdd( aCores, {'#778899'})

WEB EXTENDED INIT cHtml                               

cHtml += Execblock("BePHeader",.F.,.F.)

If lSession 
	cDataBase := HttpSession->cDataPC

	cHtml += Execblock("BePMenus",.F.,.F.)
	
	cHtml += '<div class="main" style="margin-top: 50px;">'
	cHtml += '	<h2><i class="fas fa-dolly"></i> Faturamento: Por Vendedores no Per�odo</h2>'
	cHtml += '	<hr/>'
	//cHtml += '  <form method="POST" id="formpc" action="u_bep0206A.apw" class="col-md-12" style="margin-bottom: 10px;">'+CRLF

	Do Case
		Case Month( dDataBase ) == 1
			cPeriodo := "Janeiro / " + Left( DTOS( dDataBase ), 4)
		Case Month( dDataBase ) == 2
			cPeriodo := "Fevereiro / " + Left( DTOS( dDataBase ), 4)
		Case Month( dDataBase ) == 3
			cPeriodo := "Mar�o / " + Left( DTOS( dDataBase ), 4)
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

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-pie-chart fa-1x"></i> Dashboards Faturamentos Per�odo: ' + cPeriodo + '</H3>'+CRLF
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
	cQuery += "'Devolvido' AS TIPO, ISNULL(SUM((D1_TOTAL)) * (-1), 0) AS VALOR, ISNULL(SUM(D1_CUSTO) * (-1), 0) AS CUSTOMEDIO, ISNULL(SUM(D1_QUANT * B1_CUSTD) * (-1),0) AS CUSTOSTANDARD, ISNULL(SUM((D1_TOTAL)) * (-1), 0) AS VALBRUTO, ISNULL(SUM((D1_TOTAL)) * (-1), 0) AS BASECOM " + CRLF
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

	cQuery += "SELECT CASE WHEN LEFT( C6_FILIAL, 2) = '01' THEN 'Loja de Tintas' ELSE 'Outra' " + CRLF
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
		cHtml += '								<div class="huge"><B>Taxa M�dia D�lar: ' + AllTrim( Transform( nMedDol, "@E 9,999.999999") ) + '</B></div>' + CRLF
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
		cHtml += '								<div class="huge"><B>Taxa D�lar Atual: ' + AllTrim( Transform( SM2->M2_MOEDA2, "@E 9,999.999999") ) + '</B></div>' + CRLF
		cHtml += '							</div>' + CRLF
		cHtml += '						</div>' + CRLF
		cHtml += '					</div>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
		cHtml += '		</div>' + CRLF

	cHtml += '		<div class="row">' + CRLF
	cHtml += '			<div class="col-lg-12">' + CRLF
	cHtml += '				<h3 class="page-header"><i class="fa fa-line-chart fa-1x"></i> Dashboard Faturamento Consolidado</h3>' + CRLF
	cHtml += '			</div>' + CRLF
	cHtml += '			<!-- /.col-lg-12 -->' + CRLF
	cHtml += '		</div>' + CRLF

	cQuery := "SELECT GERENTE, NOME, SUM(JANE) AS JANE, SUM(FEVE) AS FEVE, SUM(MARC) AS MARC, SUM(ABRI) AS ABRI, 
	cQuery += "                      SUM(MAIO) AS MAIO, SUM(JUNH) AS JUNH, SUM(JULH) AS JULH, SUM(AGOS) AS AGOS, 
	cQuery += "					  SUM(SETE) AS SETE, SUM(OUTU) AS OUTU, SUM(NOVE) AS NOVE, SUM(DEZE) AS DEZE 
	cQuery += "FROM ( 

	cQuery += "SELECT GERENTE, ISNULL((SELECT A3_NOME FROM " + RetSqlName("SA3") + " WHERE A3_FILIAL = '" + XFILIAL("SA3") + "' AND A3_COD = GERENTE AND D_E_L_E_T_ = ' '), 'Sem Gerente Definido') AS NOME, 
	cQuery += "       CASE WHEN PERIODO = '01' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS JANE, 
	cQuery += "       CASE WHEN PERIODO = '02' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS FEVE, 
	cQuery += "       CASE WHEN PERIODO = '03' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS MARC, 
	cQuery += "       CASE WHEN PERIODO = '04' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS ABRI, 
	cQuery += "       CASE WHEN PERIODO = '05' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS MAIO, 
	cQuery += "       CASE WHEN PERIODO = '06' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS JUNH, 
	cQuery += "       CASE WHEN PERIODO = '07' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS JULH, 
	cQuery += "       CASE WHEN PERIODO = '08' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS AGOS, 
	cQuery += "       CASE WHEN PERIODO = '09' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS SETE, 
	cQuery += "       CASE WHEN PERIODO = '10' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS OUTU, 
	cQuery += "       CASE WHEN PERIODO = '11' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS NOVE, 
	cQuery += "       CASE WHEN PERIODO = '12' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS DEZE 
	cQuery += "FROM (
	cQuery += "SELECT ISNULL(A3_GEREN, '') AS GERENTE, SUBSTRING(D2_EMISSAO, 5, 2) AS PERIODO, SUM(D2_VALBRUT - D2_VALIPI - D2_VALICM - D2_VALIMP5 - D2_VALIMP6 - D2_DESPESA - D2_VALFRE - D2_DESCON - D2_SEGURO - D2_ICMSRET) AS TOTAL, 0 AS DEVOLUCAO 
	cQuery += "FROM " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) 
	cQuery += "INNER JOIN " + RetSqlName("SF2") + " AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL 
	cQuery += "  AND F2_DOC = D2_DOC 
	cQuery += "  AND F2_SERIE = D2_SERIE 
	cQuery += "  AND F2_CLIENTE = D2_CLIENTE 
	cQuery += "  AND F2_LOJA = D2_LOJA 
	cQuery += "  AND F2_TIPO = D2_TIPO 
	cQuery += "  AND F2_EMISSAO = D2_EMISSAO 
	cQuery += "  AND SF2.D_E_L_E_T_ = ' ' 
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(D2_FILIAL, 2) 
	cQuery += "  AND F4_CODIGO = D2_TES 
	cQuery += "  AND F4_DUPLIC = 'S' 
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5919') " 
	cQuery += "  AND SF4.D_E_L_E_T_ = ' ' 
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + XFILIAL("SB1") + "' 
	cQuery += "  AND B1_COD = D2_COD 
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
	cQuery += "LEFT JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_FILIAL = '" + XFILIAL("SA3") + "' 
	cQuery += "  AND A3_COD = F2_VEND1 
	cQuery += "  AND SA3.D_E_L_E_T_ = ' ' 
	cQuery += "WHERE D2_FILIAL <> '****' 
	cQuery += "AND D2_TIPO = 'N' 
	cQuery += "AND LEFT( D2_EMISSAO, 4) = LEFT( CONVERT( VARCHAR(8), GETDATE(), 112), 4) 
	cQuery += "AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = D2_FILIAL AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') 
	cQuery += "AND SD2.D_E_L_E_T_ = ' ' 
	cQuery += "GROUP BY A3_GEREN, SUBSTRING(D2_EMISSAO, 5, 2) 

	cQuery += "UNION ALL 

	cQuery += "SELECT ISNULL(A3_GEREN, '') AS GERENTE, SUBSTRING(D1_DTDIGIT, 5, 2) AS PERIODO, 0 AS TOTAL, SUM((D1_TOTAL )) * (-1) AS DEVOLUCAO 
	cQuery += "FROM " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) 
	cQuery += "INNER JOIN " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) ON D2_FILIAL = D1_FILIAL 
	cQuery += "  AND D2_DOC = D1_NFORI 
	cQuery += "  AND D2_SERIE = D1_SERIORI 
	cQuery += "  AND D2_CLIENTE = D1_FORNECE 
	cQuery += "  AND D2_LOJA = D1_LOJA 
	cQuery += "  AND D2_ITEM = D1_ITEMORI 
	cQuery += "  AND D2_TIPO = 'N' 
	cQuery += "  AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = D2_FILIAL AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') 
	cQuery += "  AND SD2.D_E_L_E_T_ = ' ' 
	cQuery += "INNER JOIN " + RetSqlName("SF2") + " AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL 
	cQuery += "  AND F2_DOC = D2_DOC 
	cQuery += "  AND F2_SERIE = D2_SERIE 
	cQuery += "  AND F2_CLIENTE = D2_CLIENTE 
	cQuery += "  AND F2_LOJA = D2_LOJA 
	cQuery += "  AND F2_TIPO = D2_TIPO 
	cQuery += "  AND F2_EMISSAO = D2_EMISSAO 
	cQuery += "  AND SF2.D_E_L_E_T_ = ' ' 
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(D2_FILIAL, 2) 
	cQuery += "  AND F4_CODIGO = D2_TES 
	cQuery += "  AND F4_DUPLIC = 'S' 
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5919') " 
	cQuery += "  AND SF4.D_E_L_E_T_ = ' ' 
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + XFILIAL("SB1") + "' 
	cQuery += "  AND B1_COD = D2_COD 
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
	cQuery += "LEFT JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_FILIAL = '" + XFILIAL("SA3") + "' 
	cQuery += "  AND A3_COD = F2_VEND1 
	cQuery += "  AND SA3.D_E_L_E_T_ = ' ' 
	cQuery += "WHERE D1_FILIAL <> '****' 
	cQuery += "AND D1_TIPO = 'D' 
	cQuery += "AND LEFT( D1_DTDIGIT, 4) = LEFT( CONVERT( VARCHAR(8), GETDATE(), 112), 4) 
	cQuery += "AND SD1.D_E_L_E_T_ = ' ' 
	cQuery += "GROUP BY A3_GEREN, SUBSTRING(D1_DTDIGIT, 5, 2) 

	cQuery += ") AS AGRUPADO 
	cQuery += "GROUP BY GERENTE, PERIODO 

	cQuery += ") AS AGRUPGER 
	cQuery += "GROUP BY GERENTE, NOME 
	cQuery += "ORDER BY GERENTE 

	aVisGer := {}

	TCQuery cQuery New Alias "TMPGER"
	dbSelectArea("TMPGER")
	dbGoTop()

	Do While !TMPGER->( Eof() )
		aAdd( aVisGer, {TMPGER->GERENTE,;
		                TMPGER->NOME,;
		                TMPGER->JANE,;
		                TMPGER->FEVE,;
		                TMPGER->MARC,;
		                TMPGER->ABRI,;
		                TMPGER->MAIO,;
		                TMPGER->JUNH,;
		                TMPGER->JULH,;
		                TMPGER->AGOS,;
		                TMPGER->SETE,;
		                TMPGER->OUTU,;
		                TMPGER->NOVE,;
		                TMPGER->DEZE})

		TMPGER->( dbSkip() )
	EndDo

	TMPGER->( dbCloseArea() )

	If Len( aVisGer ) == 0
		aAdd( aVisGer, {"",;
		                "",;
		                0,;
		                0,;
		                0,;
		                0,;
		                0,;
		                0,;
		                0,;
		                0,;
		                0,;
		                0,;
		                0,;
		                0})
	EndIf

	cQuery := "SELECT TOP 10 VENDEDOR, NOME, SUM(JANE) AS JANE, SUM(FEVE) AS FEVE, SUM(MARC) AS MARC, SUM(ABRI) AS ABRI, 
	cQuery += "                       SUM(MAIO) AS MAIO, SUM(JUNH) AS JUNH, SUM(JULH) AS JULH, SUM(AGOS) AS AGOS, 
	cQuery += "				    	  SUM(SETE) AS SETE, SUM(OUTU) AS OUTU, SUM(NOVE) AS NOVE, SUM(DEZE) AS DEZE 
	cQuery += "FROM ( 
	cQuery += "SELECT VENDEDOR, NOME, 
	cQuery += "       CASE WHEN PERIODO = '01' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS JANE, 
	cQuery += "       CASE WHEN PERIODO = '02' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS FEVE, 
	cQuery += "       CASE WHEN PERIODO = '03' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS MARC, 
	cQuery += "       CASE WHEN PERIODO = '04' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS ABRI, 
	cQuery += "       CASE WHEN PERIODO = '05' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS MAIO, 
	cQuery += "       CASE WHEN PERIODO = '06' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS JUNH, 
	cQuery += "       CASE WHEN PERIODO = '07' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS JULH, 
	cQuery += "       CASE WHEN PERIODO = '08' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS AGOS, 
	cQuery += "       CASE WHEN PERIODO = '09' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS SETE, 
	cQuery += "       CASE WHEN PERIODO = '10' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS OUTU, 
	cQuery += "       CASE WHEN PERIODO = '11' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS NOVE, 
	cQuery += "       CASE WHEN PERIODO = '12' THEN SUM(TOTAL - DEVOLUCAO) ELSE 0 END AS DEZE 
	cQuery += "FROM (
	cQuery += "SELECT ISNULL(A3_COD, '') AS VENDEDOR, ISNULL(A3_NOME, 'Sem Vendedor') AS NOME, SUBSTRING(D2_EMISSAO, 5, 2) AS PERIODO, SUM(D2_VALBRUT - D2_VALIPI - D2_VALICM - D2_VALIMP5 - D2_VALIMP6 - D2_DESPESA - D2_VALFRE - D2_DESCON - D2_SEGURO - D2_ICMSRET) AS TOTAL, 0 AS DEVOLUCAO 
	cQuery += "FROM " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) 
	cQuery += "INNER JOIN " + RetSqlName("SF2") + " AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL 
	cQuery += "  AND F2_DOC = D2_DOC 
	cQuery += "  AND F2_SERIE = D2_SERIE 
	cQuery += "  AND F2_CLIENTE = D2_CLIENTE 
	cQuery += "  AND F2_LOJA = D2_LOJA 
	cQuery += "  AND F2_TIPO = D2_TIPO 
	cQuery += "  AND F2_EMISSAO = D2_EMISSAO 
	cQuery += "  AND SF2.D_E_L_E_T_ = ' ' 
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(D2_FILIAL, 2) 
	cQuery += "  AND F4_CODIGO = D2_TES 
	cQuery += "  AND F4_DUPLIC = 'S' 
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5919') " + CRLF
	cQuery += "  AND SF4.D_E_L_E_T_ = ' ' 
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + XFILIAL("SB1") + "' 
	cQuery += "  AND B1_COD = D2_COD 
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
	cQuery += "LEFT JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_FILIAL = '" + XFILIAL("SA3") + "' 
	cQuery += "  AND A3_COD = F2_VEND1 
	cQuery += "  AND SA3.D_E_L_E_T_ = ' ' 
	cQuery += "WHERE D2_FILIAL <> '****' 
	cQuery += "AND D2_TIPO = 'N' 
	cQuery += "AND LEFT( D2_EMISSAO, 4) = LEFT( CONVERT( VARCHAR(8), GETDATE(), 112), 4) 
	cQuery += "AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = D2_FILIAL AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') 
	cQuery += "AND SD2.D_E_L_E_T_ = ' ' 
	cQuery += "GROUP BY A3_COD, A3_NOME, SUBSTRING(D2_EMISSAO, 5, 2) 

	cQuery += "UNION ALL 

	cQuery += "SELECT ISNULL(A3_COD, '') AS VENDEDOR, ISNULL(A3_NOME, 'Sem Vendedor') AS NOME, SUBSTRING(D1_DTDIGIT, 5, 2) AS PERIODO, 0 AS TOTAL, SUM((D1_TOTAL)) * (-1) AS DEVOLUCAO 
	cQuery += "FROM " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) 
	cQuery += "INNER JOIN " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) ON D2_FILIAL = D1_FILIAL 
	cQuery += "  AND D2_DOC = D1_NFORI 
	cQuery += "  AND D2_SERIE = D1_SERIORI 
	cQuery += "  AND D2_CLIENTE = D1_FORNECE 
	cQuery += "  AND D2_LOJA = D1_LOJA 
	cQuery += "  AND D2_ITEM = D1_ITEMORI 
	cQuery += "  AND D2_TIPO = 'N' 
	cQuery += "  AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = D2_FILIAL AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') 
	cQuery += "  AND SD2.D_E_L_E_T_ = ' ' 
	cQuery += "INNER JOIN " + RetSqlName("SF2") + " AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL 
	cQuery += "  AND F2_DOC = D2_DOC 
	cQuery += "  AND F2_SERIE = D2_SERIE 
	cQuery += "  AND F2_CLIENTE = D2_CLIENTE 
	cQuery += "  AND F2_LOJA = D2_LOJA 
	cQuery += "  AND F2_TIPO = D2_TIPO 
	cQuery += "  AND F2_EMISSAO = D2_EMISSAO 
	cQuery += "  AND SF2.D_E_L_E_T_ = ' ' 
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(D2_FILIAL, 2) 
	cQuery += "  AND F4_CODIGO = D2_TES 
	cQuery += "  AND F4_DUPLIC = 'S' 
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5919') " + CRLF
	cQuery += "  AND SF4.D_E_L_E_T_ = ' ' 
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + XFILIAL("SB1") + "' 
	cQuery += "  AND B1_COD = D2_COD 
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
	cQuery += "LEFT JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_FILIAL = '" + XFILIAL("SA3") + "' 
	cQuery += "  AND A3_COD = F2_VEND1 
	cQuery += "  AND SA3.D_E_L_E_T_ = ' ' 
	cQuery += "WHERE D1_FILIAL <> '****' 
	cQuery += "AND D1_TIPO = 'D' 
	cQuery += "AND LEFT( D1_DTDIGIT, 4) = LEFT( CONVERT( VARCHAR(8), GETDATE(), 112), 4) 
	cQuery += "AND SD1.D_E_L_E_T_ = ' ' 
	cQuery += "GROUP BY A3_COD, A3_NOME, SUBSTRING(D1_DTDIGIT, 5, 2) 

	cQuery += ") AS AGRUPADO 
	cQuery += "GROUP BY VENDEDOR, NOME, PERIODO 
	cQuery += ") AS AGRUPGER 
	cQuery += "GROUP BY VENDEDOR, NOME 
	cQuery += "ORDER BY SUM(JANE + FEVE + MARC + ABRI + MAIO + JUNH + JULH + AGOS + SETE + OUTU + NOVE + DEZE) DESC 

	aVendedor := {}

	TCQuery cQuery New Alias "TMPVEN"
	dbSelectArea("TMPVEN")
	dbGoTop()

	Do While !TMPVEN->( Eof() )
		aAdd( aVendedor, {TMPVEN->VENDEDOR,;
		                TMPVEN->NOME,;
		                TMPVEN->JANE,;
		                TMPVEN->FEVE,;
		                TMPVEN->MARC,;
		                TMPVEN->ABRI,;
		                TMPVEN->MAIO,;
		                TMPVEN->JUNH,;
		                TMPVEN->JULH,;
		                TMPVEN->AGOS,;
		                TMPVEN->SETE,;
		                TMPVEN->OUTU,;
		                TMPVEN->NOVE,;
		                TMPVEN->DEZE})

		TMPVEN->( dbSkip() )
	EndDo

	TMPVEN->( dbCloseArea() )

	If Len( aVendedor ) == 0
		aAdd( aVendedor, {"",;
		                "",;
		                0,;
		                0,;
		                0,;
		                0,;
		                0,;
		                0,;
		                0,;
		                0,;
		                0,;
		                0,;
		                0,;
		                0})
	EndIf

	cHtml += '		<div class="row">' + CRLF

	cHtml += '			<div class="col-lg-6 col-md-6">' + CRLF
	cHtml += '				<h5><i class="fa fa-bar-chart-o fa-fw"></i> Faturamento Por Gerente Consolidado no Exerc�cio de: <B>' + Left( DTOS( dDataBase ), 4) + '</B></h5>' + CRLF
	cHtml += '				<hr/>' + CRLF
	cHtml += '				<div class="well well-lg">' + CRLF
	cHtml += '					<canvas class="my-4 w-100" id="myChartGer" width="900" height="380"></canvas>' + CRLF
	cHtml += '					<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>' + CRLF
	cHtml += '					<script>' + CRLF
	cHtml += '						var ctx = document.getElementById("myChartGer");' + CRLF
	cHtml += '						var myChartGer = new Chart(ctx, {' + CRLF
	cHtml += "						type: 'line'," + CRLF
	cHtml += '						data: {' + CRLF
	cHtml += '						labels: ["Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"],' + CRLF
	cHtml += '						datasets: [' + CRLF
	For nAno := 1 To Len( aVisGer )
		cHtml += '						{ ' + CRLF
		cHtml += '						data: [' + AllTrim( Str(aVisGer[nAno][03]) ) + ',' + AllTrim( Str(aVisGer[nAno][04]) ) + ',' + AllTrim( Str(aVisGer[nAno][05]) ) + ',' + AllTrim( Str(aVisGer[nAno][06]) ) + ',' + AllTrim( Str(aVisGer[nAno][07]) ) + ',' + AllTrim( Str(aVisGer[nAno][08]) ) + ',' + AllTrim( Str(aVisGer[nAno][09]) ) + ',' + AllTrim( Str(aVisGer[nAno][10]) ) + ',' + AllTrim( Str(aVisGer[nAno][11]) ) + ',' + AllTrim( Str(aVisGer[nAno][12]) ) + ',' + AllTrim( Str(aVisGer[nAno][13]) ) + ',' + AllTrim( Str(aVisGer[nAno][14]) ) + '],' + CRLF
		cHtml += '						label: "' + aVisGer[nAno][01] + " - " + AllTrim( aVisGer[nAno][02] ) + '",' + CRLF
		If nAno > 20
			nCor := Mod( nAno, 20)
			If nCor == 0
				nCor == 1
			EndIf
		Else
			nCor := nAno
		EndIf
		cHtml += '						borderColor: "' + aCores[nCor][1] + '",' + CRLF
		cHtml += '						fill: false' + CRLF
		cHtml += '						},' + CRLF
	Next
	cHtml += '						]' + CRLF
	cHtml += '						},' + CRLF
	cHtml += '						options: {' + CRLF
	cHtml += '						scales: {' + CRLF
	cHtml += '						yAxes: [{' + CRLF
	cHtml += '						ticks: {' + CRLF
	cHtml += '						beginAtZero: false' + CRLF
	cHtml += '						}' + CRLF
	cHtml += '						}]' + CRLF
	cHtml += '						},' + CRLF
	cHtml += '						legend: {' + CRLF
	cHtml += '						display: false,' + CRLF
	cHtml += '						}' + CRLF
	cHtml += '						}' + CRLF
	cHtml += '						});' + CRLF
	cHtml += '					</script>' + CRLF
	cHtml += '				</div>' + CRLF
	cHtml += '			</div>' + CRLF

	cHtml += '			<div class="col-lg-6 col-md-6">' + CRLF
	cHtml += '				<h5><i class="fa fa-bar-chart-o fa-fw"></i> Top 10 Vendedores Consolidado no Exerc�cio de: <B>' + Left( DTOS( dDataBase ), 4) + '</B></h5>' + CRLF
	cHtml += '				<hr/>' + CRLF
	cHtml += '				<div class="well well-lg">' + CRLF
	cHtml += '					<canvas class="my-4 w-100" id="myRosc" width="900" height="380"></canvas>' + CRLF
	cHtml += '					<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>' + CRLF
	cHtml += '					<script>' + CRLF
	cHtml += '						var ctx = document.getElementById("myRosc");' + CRLF
	cHtml += '						var myRosc = new Chart(ctx, {' + CRLF
	cHtml += "						type: 'bar'," + CRLF
	cHtml += '						data: {' + CRLF
	cHtml += '						labels: ["Consolidado"],' + CRLF
	cHtml += '						datasets: [' + CRLF
	For nAno := 1 To Len( aVendedor )
		cHtml += '						{ ' + CRLF
		cHtml += '						data: [' + AllTrim( Str(aVendedor[nAno][03] + aVendedor[nAno][04] + aVendedor[nAno][05] + aVendedor[nAno][06] + aVendedor[nAno][07] + aVendedor[nAno][08] + aVendedor[nAno][09] + aVendedor[nAno][10] + aVendedor[nAno][11] + aVendedor[nAno][12] + aVendedor[nAno][13] + aVendedor[nAno][14]) ) + '],' + CRLF
		cHtml += '						label: "' + AllTrim( aVendedor[nAno][02] ) + '",' + CRLF
		If nAno > 20
			nCor := Mod( nAno, 20)
			If nCor == 0
				nCor == 1
			EndIf
		Else
			nCor := nAno
		EndIf
		cHtml += '						borderColor: "' + aCores[nCor][1] + '",' + CRLF
		cHtml += '						fill: false' + CRLF
		cHtml += '						},' + CRLF
	Next
	cHtml += '						]' + CRLF
	cHtml += '						},' + CRLF
	cHtml += '						options: {' + CRLF
	cHtml += '						scales: {' + CRLF
	cHtml += '						yAxes: [{' + CRLF
	cHtml += '						ticks: {' + CRLF
	cHtml += '						beginAtZero: false' + CRLF
	cHtml += '						}' + CRLF
	cHtml += '						}]' + CRLF
	cHtml += '						},' + CRLF
	cHtml += '						legend: {' + CRLF
	cHtml += '						display: false,' + CRLF
	cHtml += '						}' + CRLF
	cHtml += '						}' + CRLF
	cHtml += '						});' + CRLF
	cHtml += '					</script>' + CRLF
	cHtml += '				</div>' + CRLF
	cHtml += '			</div>' + CRLF
	cHtml += '      </div>'+CRLF
	cHtml += '<HR>' + CRLF

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-bars fa-1x"></i> Posi��o do Faturamento por Vendedores - Loja de Tintas</H3>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '	<div  class="col-md-12" style="overflow-x:auto; width=100%; overflow-y:auto;">'+CRLF

	cQuery := "SELECT VENDEDOR, NOME, SUM(TOTAL) AS TOTAL, SUM(DEVOLUCAO) AS DEVOLUCAO, SUM(CARTEIRA) AS CARTEIRA, SUM(CREDITO) AS CREDITO, SUM(ESTOQUE) AS ESTOQUE, SUM(AFATURAR) AS AFATURAR, SUM(BRUTO) AS BRUTO, SUM(META) AS META, SUM(BASECOM) AS BASECOM " + CRLF
	cQuery += "FROM  ( " + CRLF
	cQuery += "SELECT ISNULL(A3_COD, '') AS VENDEDOR, ISNULL(A3_NOME, '') AS NOME, SUM(D2_VALBRUT - D2_VALIPI - D2_VALICM - D2_VALIMP5 - D2_VALIMP6 - D2_DESPESA - D2_VALFRE - D2_DESCON - D2_SEGURO - D2_ICMSRET) AS TOTAL, 0 AS DEVOLUCAO, 0 AS CARTEIRA, 0 AS CREDITO, 0 AS ESTOQUE, 0 AS AFATURAR, SUM(D2_VALBRUT) AS BRUTO, 0 AS META, ISNULL(SUM(D2_VALBRUT - D2_VALIPI - D2_ICMSRET), 0) AS BASECOM " + CRLF
	cQuery += "FROM " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF2") + " AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL " + CRLF
	cQuery += "  AND F2_DOC = D2_DOC " + CRLF
	cQuery += "  AND F2_SERIE = D2_SERIE " + CRLF
	cQuery += "  AND F2_CLIENTE = D2_CLIENTE " + CRLF
	cQuery += "  AND F2_LOJA = D2_LOJA " + CRLF
	cQuery += "  AND F2_TIPO = D2_TIPO " + CRLF
	cQuery += "  AND F2_EMISSAO = D2_EMISSAO " + CRLF
	cQuery += "  AND SF2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = '01' " + CRLF
	cQuery += "  AND F4_CODIGO = D2_TES " + CRLF
	cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5919') " + CRLF
	cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "LEFT JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_FILIAL = '" + XFILIAL("SA3") + "' " + CRLF
	cQuery += "  AND A3_COD = F2_VEND1 " + CRLF
	cQuery += "  AND SA3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE LEFT(D2_FILIAL, 2) = '01' " + CRLF
	cQuery += "AND D2_TIPO = 'N' " + CRLF
	cQuery += "AND LEFT(D2_EMISSAO, 6) = '" + Left( DTOS( dDataBase ), 6) + "' " + CRLF
	cQuery += "AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = D2_FILIAL AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND SD2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY A3_COD, A3_NOME " + CRLF

	cQuery += "UNION ALL " + CRLF

	cQuery += "SELECT ISNULL(A3_COD, '') AS VENDEDOR, ISNULL(A3_NOME, '') AS NOME, 0 AS TOTAL, SUM((D1_TOTAL)) * (-1) AS DEVOLUCAO, 0 AS CARTEIRA, 0 AS CREDITO, 0 AS ESTOQUE, 0 AS AFATURAR, SUM((D1_TOTAL)) * (-1) AS BRUTO, 0 AS META, 0 AS BASECOM " + CRLF
	cQuery += "FROM " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) ON D2_FILIAL = D1_FILIAL " + CRLF
	cQuery += "  AND D2_DOC = D1_NFORI " + CRLF
	cQuery += "  AND D2_SERIE = D1_SERIORI " + CRLF
	cQuery += "  AND D2_CLIENTE = D1_FORNECE " + CRLF
	cQuery += "  AND D2_LOJA = D1_LOJA " + CRLF
	cQuery += "  AND D2_ITEM = D1_ITEMORI " + CRLF
	cQuery += "  AND D2_TIPO = 'N' " + CRLF
	cQuery += "  AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA12") + " WITH (NOLOCK) WHERE A1_FILIAL = D2_FILIAL AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "  AND SD2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF2") + " AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL " + CRLF
	cQuery += "  AND F2_DOC = D2_DOC " + CRLF
	cQuery += "  AND F2_SERIE = D2_SERIE " + CRLF
	cQuery += "  AND F2_CLIENTE = D2_CLIENTE " + CRLF
	cQuery += "  AND F2_LOJA = D2_LOJA " + CRLF
	cQuery += "  AND F2_TIPO = D2_TIPO " + CRLF
	cQuery += "  AND F2_EMISSAO = D2_EMISSAO " + CRLF
	cQuery += "  AND SF2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = '01' " + CRLF
	cQuery += "  AND F4_CODIGO = D2_TES " + CRLF
	cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5919') " + CRLF
	cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "LEFT JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_FILIAL = '" + XFILIAL("SA3") + "' " + CRLF
	cQuery += "  AND A3_COD = F2_VEND1 " + CRLF
	cQuery += "  AND SA3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE LEFT(D1_FILIAL, 2) = '01' " + CRLF
	cQuery += "AND D1_TIPO = 'D' " + CRLF
	cQuery += "AND LEFT(D1_DTDIGIT, 6) = '" + Left( DTOS( dDataBase ), 6) + "' " + CRLF
	cQuery += "AND SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY A3_COD, A3_NOME " + CRLF
	
	cQuery += "UNION ALL " + CRLF
	
	cQuery += "SELECT ISNULL(A3_COD, '') AS VENDEDOR, ISNULL(A3_NOME, '') AS NOME, 0 AS TOTAL, 0 AS DEVOLUCAO, ISNULL(SUM(((C6_QTDVEN - C6_QTDENT ) * C6_PRCVEN)), 0) AS CARTEIRA, 0 AS CREDITO, 0 AS ESTOQUE, 0 AS AFATURAR, 0 AS BRUTO, 0 AS META, 0 AS BASECOM " + CRLF
	cQuery += "FROM " + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SC5") + " AS SC5 WITH (NOLOCK) ON C5_FILIAL = C6_FILIAL " + CRLF
	cQuery += "  AND C5_NUM = C6_NUM " + CRLF
	cQuery += "  AND C5_TIPO = 'N' " + CRLF
	cQuery += "  AND C5_LIBEROK = '' " + CRLF
	cQuery += "  AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = C5_FILIAL AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "  AND SC5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = '02' " + CRLF
	cQuery += "  AND F4_CODIGO = C6_TES " + CRLF
	cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5919') " + CRLF
	cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + XFILIAL("SA1") + "' " + CRLF
	cQuery += "  AND B1_COD = C6_PRODUTO " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) ON B2_FILIAL = C6_FILIAL " + CRLF
	cQuery += "  AND B2_COD = C6_PRODUTO " + CRLF
	cQuery += "  AND B2_LOCAL = C6_LOCAL " + CRLF
	cQuery += "  AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "LEFT JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_FILIAL = '" + XFILIAL("SA3") + "' " + CRLF
	cQuery += "  AND A3_COD = C5_VEND1 " + CRLF
	cQuery += "  AND SA3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE LEFT(C6_FILIAL, 2) = '01' " + CRLF
	cQuery += "AND C6_BLQ = '' " + CRLF
	cQuery += "AND C6_QTDVEN > C6_QTDENT " + CRLF
	cQuery += "AND SC6.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY A3_COD, A3_NOME " + CRLF
	
	cQuery += "UNION ALL " + CRLF
	
	cQuery += "SELECT ISNULL(A3_COD, '') AS VENDEDOR, ISNULL(A3_NOME, '') AS NOME, 0 AS TOTAL, 0 AS DEVOLUCAO, 0 AS CARTEIRA, SUM((C9_QTDLIB * C9_PRCVEN)) AS CREDITO, 0 AS ESTOQUE, 0 AS AFATURAR, 0 AS BRUTO, 0 AS META, 0 AS BASECOM " + CRLF
	cQuery += "FROM " + RetSqlName("SC9") + " AS SC9 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) ON C6_FILIAL = C9_FILIAL " + CRLF
	cQuery += "  AND C6_NUM = C9_PEDIDO " + CRLF
	cQuery += "  AND C6_ITEM = C9_ITEM " + CRLF
	cQuery += "  AND C6_BLQ = '' " + CRLF
	cQuery += "  AND C6_QTDVEN > C6_QTDENT " + CRLF
	cQuery += "  AND SC6.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SC5") + " AS SC5 WITH (NOLOCK) ON C5_FILIAL = C6_FILIAL " + CRLF
	cQuery += "  AND C5_NUM = C6_NUM " + CRLF
	cQuery += "  AND C5_TIPO = 'N' " + CRLF
	cQuery += "  AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = C5_FILIAL AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "  AND SC5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = '02' " + CRLF
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
	cQuery += "LEFT JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_FILIAL = '" + XFILIAL("SA3") + "' " + CRLF
	cQuery += "  AND A3_COD = C5_VEND1 " + CRLF
	cQuery += "  AND SA3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE LEFT(C6_FILIAL, 2) = '01' " + CRLF
	cQuery += "AND C9_NFISCAL = '' " + CRLF
	cQuery += "AND C9_BLCRED <> '' " + CRLF
	cQuery += "AND SC9.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY A3_COD, A3_NOME " + CRLF

	cQuery += "UNION ALL " + CRLF

	cQuery += "SELECT ISNULL(A3_COD, '') AS VENDEDOR, ISNULL(A3_NOME, '') AS NOME, 0 AS TOTAL, 0 AS DEVOLUCAO, 0 AS CARTEIRA, 0 AS CREDITO, SUM((C9_QTDLIB * C9_PRCVEN)) AS ESTOQUE, 0 AS AFATURAR, 0 AS BRUTO, 0 AS META, 0 AS BASECOM " + CRLF
	cQuery += "FROM " + RetSqlName("SC9") + " AS SC9 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) ON C6_FILIAL = C9_FILIAL " + CRLF
	cQuery += "  AND C6_NUM = C9_PEDIDO " + CRLF
	cQuery += "  AND C6_ITEM = C9_ITEM " + CRLF
	cQuery += "  AND C6_BLQ = '' " + CRLF
	cQuery += "  AND C6_QTDVEN > C6_QTDENT " + CRLF
	cQuery += "  AND SC6.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SC5") + " AS SC5 WITH (NOLOCK) ON C5_FILIAL = C6_FILIAL " + CRLF
	cQuery += "  AND C5_NUM = C6_NUM " + CRLF
	cQuery += "  AND C5_TIPO = 'N' " + CRLF
	cQuery += "  AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = C5_FILIAL AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "  AND SC5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = '01' " + CRLF
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
	cQuery += "LEFT JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_FILIAL = '" + XFILIAL("SA3") + "' " + CRLF
	cQuery += "  AND A3_COD = C5_VEND1 " + CRLF
	cQuery += "  AND SA3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE LEFT(C6_FILIAL, 2) = '01' " + CRLF
	cQuery += "AND C9_NFISCAL = '' " + CRLF
	cQuery += "AND C9_BLCRED = '' " + CRLF
	cQuery += "AND C9_BLEST <> '' " + CRLF
	cQuery += "AND SC9.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY A3_COD, A3_NOME " + CRLF

	cQuery += "UNION ALL " + CRLF

	cQuery += "SELECT ISNULL(A3_COD, '') AS VENDEDOR, ISNULL(A3_NOME, '') AS NOME, 0 AS TOTAL, 0 AS DEVOLUCAO, 0 AS CARTEIRA, 0 AS CREDITO, 0 AS ESTOQUE, SUM((C9_QTDLIB * C9_PRCVEN)) AS AFATURAR, 0 AS BRUTO, 0 AS META, 0 AS BASECOM " + CRLF
	cQuery += "FROM " + RetSqlName("SC9") + " AS SC9 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) ON C6_FILIAL = C9_FILIAL " + CRLF
	cQuery += "  AND C6_NUM = C9_PEDIDO " + CRLF
	cQuery += "  AND C6_ITEM = C9_ITEM " + CRLF
	cQuery += "  AND C6_BLQ = '' " + CRLF
	cQuery += "  AND C6_QTDVEN > C6_QTDENT " + CRLF
	cQuery += "  AND SC6.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SC5") + " AS SC5 WITH (NOLOCK) ON C5_FILIAL = C6_FILIAL " + CRLF
	cQuery += "  AND C5_NUM = C6_NUM " + CRLF
	cQuery += "  AND C5_TIPO = 'N' " + CRLF
	cQuery += "  AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = C5_FILIAL AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "  AND SC5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = '01' " + CRLF
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
	cQuery += "LEFT JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_FILIAL = '" + XFILIAL("SA3") + "' " + CRLF
	cQuery += "  AND A3_COD = C5_VEND1 " + CRLF
	cQuery += "  AND SA3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE LEFT(C6_FILIAL, 2) = '01' " + CRLF
	cQuery += "AND C9_NFISCAL = '' " + CRLF
	cQuery += "AND C9_BLCRED = '' " + CRLF
	cQuery += "AND C9_BLEST = '' " + CRLF
	cQuery += "AND SC9.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY A3_COD, A3_NOME " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT ISNULL(A3_COD, '') AS VENDEDOR, ISNULL(A3_NOME, '') AS NOME, 0 AS TOTAL, 0 AS DEVOLUCAO, 0 AS CARTEIRA, 0 AS CREDITO, 0 AS ESTOQUE, 0 AS AFATURAR, 0 AS BRUTO, SUM(CT_VALOR) AS META, 0 AS BASECOM " + CRLF
	cQuery += "FROM " + RetSqlName("SCT") + " AS SCT WITH (NOLOCK) " + CRLF
	cQuery += "LEFT JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_FILIAL = '" + XFILIAL("SA3") + "' " + CRLF
	cQuery += "  AND A3_COD = CT_VEND " + CRLF
	cQuery += "  AND SA3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE LEFT(CT_FILIAL, 2) = '01' " + CRLF
	cQuery += "AND LEFT(CT_DATA, 6) = '" + Left( DTOS( dDataBase ), 6) + "' " + CRLF
	cQuery += "AND CT_MSBLQL <> '1' " + CRLF
	cQuery += "AND SCT.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY A3_COD, A3_NOME " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF
	cQuery += "GROUP BY VENDEDOR, NOME " + CRLF
	cQuery += "ORDER BY VENDEDOR, NOME " + CRLF

	TCQuery cQuery New Alias "TMP001"
	dbSelectArea("TMP001")
	dbGoTop()

	cHtml += '    <div class="form-group" style="max-height:300px; ">'+CRLF
	cHtml += '    	<table id="table" class="table table-bordered table-striped table-condensed col-md-12">'+CRLF
	cHtml += '    		<thead>'+CRLF
	cHtml += '      		<tr>'+CRLF
	cHtml += '		  			<th>Vendedor</th>'+CRLF
	cHtml += '        			<th>Nome</th>'+CRLF
	cHtml += '        			<th>Meta</th>'+CRLF
	cHtml += '        			<th>Receita Base</th>'+CRLF //Vlr. Faturado
	cHtml += '        			<th>Vlr. Devol.</th>'+CRLF
	cHtml += '        			<th>Base Comiss�o</th>'+CRLF //Fat - Dev
	cHtml += '        			<th>% Atendido</th>'+CRLF
	cHtml += '        			<th>Pedido</th>'+CRLF
	cHtml += '      		</tr>'+CRLF
	cHtml += '    		</thead>'+CRLF
	cHtml += '			<tbody>'+CRLF
	
	nEMeta     := 0
	nEBruto    := 0
	nETotal    := 0
	nEDevol    := 0
	nECarteira := 0
	nECredito  := 0
	nEEstoque  := 0
	nEAFaturar := 0
	nEBaseCom  := 0

	Do While !TMP001->( Eof() )
		cHtml += '				<tr>'+CRLF
		cHtml += '        			<td>'+TMP001->VENDEDOR+'</td>'+CRLF
		cHtml += '        			<td>'+TMP001->NOME+'</td>'+CRLF
		cHtml += '        			<td style="text-align: right;">'+Transform(TMP001->META,PesqPict("SB2","B2_VATU1"))+'</td>'+CRLF
		cHtml += '        			<td style="text-align: right;">'+Transform(TMP001->TOTAL,PesqPict("SB2","B2_VATU1"))+'</td>'+CRLF
		cHtml += '        			<td style="text-align: right;">'+Transform(TMP001->DEVOLUCAO,PesqPict("SB2","B2_VATU1"))+'</td>'+CRLF
		cHtml += '        			<td style="text-align: right;">'+Transform(TMP001->BASECOM - IIf(TMP001->DEVOLUCAO < 0, (TMP001->DEVOLUCAO * (-1)), TMP001->DEVOLUCAO),PesqPict("SB2","B2_VATU1"))+'</td>'+CRLF
		If TMP001->META > 0 .And. TMP001->TOTAL - IIf(TMP001->DEVOLUCAO < 0, (TMP001->DEVOLUCAO * (-1)), TMP001->DEVOLUCAO) > 0
			nPercAt := (TMP001->TOTAL - IIf(TMP001->DEVOLUCAO < 0, (TMP001->DEVOLUCAO * (-1)), TMP001->DEVOLUCAO)) / TMP001->META * 100.00
			cHtml += '        			<td style="text-align: right;">'+AllTrim( Transform( nPercAt,PesqPict("SB2","B2_VATU1")) )+'%</td>'+CRLF
		Else
			cHtml += '        			<td style="text-align: right;">0%</td>'+CRLF
		EndIf
		cHtml += '        			<td style="text-align: right;">'+Transform(TMP001->CARTEIRA + TMP001->CREDITO + TMP001->ESTOQUE + TMP001->AFATURAR,PesqPict("SB2","B2_VATU1"))+'</td>'+CRLF
		cHtml += '      		</tr>'+CRLF

		nEMeta     += TMP001->META
		nEBruto    += TMP001->BRUTO
		nETotal    += TMP001->TOTAL
		nEDevol    += TMP001->DEVOLUCAO
		nECarteira += TMP001->CARTEIRA
		nECredito  += TMP001->CREDITO
		nEEstoque  += TMP001->ESTOQUE
		nEAFaturar += TMP001->AFATURAR
		nEBaseCom  += TMP001->BASECOM

		TMP001->( dbSkip() )
	EndDo

	TMP001->( dbCloseArea() )

	cHtml += '				<tr>'+CRLF
	cHtml += '        			<td><B>Total Geral:</B></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td style="text-align: right;"><B>'+Transform(nEMeta,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
	cHtml += '        			<td style="text-align: right;"><B>'+Transform(nETotal,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
	cHtml += '        			<td style="text-align: right;"><B>'+Transform(nEDevol,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
	cHtml += '        			<td style="text-align: right;"><B>'+Transform(nEBaseCom - IIf(nEDevol < 0, (nEDevol * (-1)), nEDevol),PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
	If nEMeta > 0 .And. nETotal - IIf(nEDevol < 0, (nEDevol * (-1)), nEDevol) > 0
		nPercAt := (nETotal - IIf(nEDevol < 0, (nEDevol * (-1)), nEDevol)) / nEMeta * 100.00
		cHtml += '        			<td style="text-align: right;"><B>'+AllTrim( Transform( nPercAt,PesqPict("SB2","B2_VATU1")) )+'%</B></td>'+CRLF
	Else
		cHtml += '        			<td style="text-align: right;"><B>0%</B></td>'+CRLF
	EndIf
	cHtml += '        			<td style="text-align: right;"><B>'+Transform(nECarteira + nECredito + nEEstoque + nEAFaturar,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
	cHtml += '      		</tr>'+CRLF

	cHtml += '    		</tbody>'+CRLF
	cHtml += '  	</table>'+CRLF
	cHtml += '	  </div>'+CRLF

	cHtml += '  </div>'+CRLF

		cHtml += '<HR>' + CRLF

Else	
	cMsgHdr		:= "BEP0501 - Sess�o n�o Iniciada"
	cMsgBody	:= "A sess�o n�o foi iniciada, realize o Login!"

	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 

EndIf

cHtml += Execblock("BePFooter",.F.,.F.)

WEB EXTENDED END
	
Return (EncodeUTF8(cHtml))
