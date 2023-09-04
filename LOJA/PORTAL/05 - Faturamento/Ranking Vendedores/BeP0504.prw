#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

// Programa Inicial da Faturamento
// Portal 
// @Autor   : Fabio Carneiro 
// @History : Alteração na query para não carregar vendas com cfop 6124/5124 - Henkel
// @Date    : 14/05/2021 Documentado 
// -----------------------------------------------------------------------------
// @Autor   : Fabio Carneiro 
// @History : Alteração na veriavel cDiretor acrescentando o usuário Elalia no dia 14/05/2021
// @Date    : 14/05/2021 

User Function BeP0504()

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
//Local nRegSM0	:= SM0->(Recno())
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
Local nEuroDev  := 0
Local nQualy    := 0
Local nJays     := 0
Local nConsol   := 0
Local aVendido  := {}
Local lGerente  := .F.
Local cCodGer   := ""
Local cDiretor  := "000303|000370|000736|001028|000867|000995|000000|001245"
Local cFilUsr   := "000867|000995"
Local cSoEuro   := "000995"
Local cSoQualy  := "000867"
Local lFilUsr   := (AllTrim( HttpSession->ccodusr ) $ cFilUsr)
Local lDiretor  := (AllTrim( HttpSession->ccodusr ) $ cDiretor)
Local nEurMed   := 0
Local nQuaMed   := 0
Local nJayMed   := 0
Local nPhoMed   := 0
Local nMetMed   := 0
Local nVinMed   := 0

Private cHtml 	:= ""    

WEB EXTENDED INIT cHtml                               

cHtml += Execblock("BePHeader",.F.,.F.)

If lSession 
	cDataBase := HttpSession->cDataPC

	cHtml += Execblock("BePMenus",.F.,.F.)
	
	cHtml += '<div class="main" style="margin-top: 50px;">'
	cHtml += '	<h2><i class="fas fa-dolly"></i> Faturamento: Por Vendedores no Período</h2>'
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

	// Verificar se deve ser filtrado o gerente caso usuário seja um gerente de vendas...
	If !Empty( HttpSession->ccodusr )
		lGerente := .F.
		cCodGer  := ""

		If !lDiretor
			cQuery := "SELECT A3_COD, A3_CODUSR " + CRLF
			cQuery += "FROM " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) " + CRLF
			cQuery += "WHERE A3_FILIAL = '" + xFilial("SA3") + "' " + CRLF
			cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("SA3") + " WHERE A3_FILIAL = '" + xFilial("SA3") + "' AND A3_GEREN = SA3.A3_COD AND D_E_L_E_T_ = ' ') " + CRLF
			cQuery += "AND A3_CODUSR = '" + AllTrim( HttpSession->ccodusr ) + "' " + CRLF
			cQuery += "AND D_E_L_E_T_ = ' ' " + CRLF
			cQuery += "GROUP BY A3_CODUSR, A3_COD " + CRLF
	
			TCQuery cQuery New Alias "TMPGER"
			dbSelectArea("TMPGER")
			dbGoTop()
	
			If !TMPGER->( Eof() )
				If !Empty( TMPGER->A3_COD )
					lGerente := .T.
					cCodGer  := AllTrim( TMPGER->A3_COD )
					lFilUsr  := .T.
					If AllTrim( cEmpAnt ) == "0101"
						cSoEuro  := "000001" + "|" + AllTrim( HttpSession->ccodusr )
					EndIf
				EndIf
			EndIf
	
			TMPGER->( dbCloseArea() )
		EndIf
	EndIf

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-pie-chart fa-1x"></i> Dashboards Faturamentos Período: ' + cPeriodo + '</H3>'+CRLF
	cHtml += '    </div>'+CRLF

	cQuery := "SELECT EMPRESA, TIPO, VALOR - CUSTOMEDIO AS MARGEM_S_CUSTO, CONVERT(DECIMAL(14,2),((ABS(CUSTOMEDIO) / ABS(VALOR))) * 100) AS FATOR_S_CUSTO, VALOR - CUSTOSTANDARD AS MARGEM_S_STD, CONVERT(DECIMAL(14,2),(1 + (1 - (ABS(CUSTOSTANDARD) / ABS(VALOR))))) AS FATOR_S_STD, VALOR, VALBRUTO, BASECOM, CUSTOMEDIO " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT * FROM ( " + CRLF
	cQuery += "SELECT CASE WHEN LEFT( D2_FILIAL, 2) = '01' THEN 'Loja de Tintas' ELSE 'Outra' " + CRLF
	cQuery += "END AS EMPRESA, " + CRLF
//	cQuery += "'Faturado' AS TIPO, ISNULL(SUM(D2_VALBRUT /*- D2_VALIPI - D2_VALICM - D2_VALIMP5 - D2_VALIMP6 - D2_DESPESA - D2_VALFRE - D2_DESCON - D2_SEGURO - D2_ICMSRET*/), 0) AS VALOR, ISNULL(SUM(D2_CUSTO1), 0) AS CUSTOMEDIO, ISNULL(SUM(D2_QUANT * B1_CUSTD),0) AS CUSTOSTANDARD, ISNULL(SUM(D2_VALBRUT), 0) AS VALBRUTO, ISNULL(SUM(D2_VALBRUT - D2_VALIPI - D2_ICMSRET), 0) AS BASECOM " + CRLF
	cQuery += "'Faturado' AS TIPO, ISNULL(SUM(D2_VALBRUT), 0) AS VALOR, ISNULL(SUM(D2_CUSTO1), 0) AS CUSTOMEDIO, ISNULL(SUM(D2_QUANT * B1_CUSTD),0) AS CUSTOSTANDARD, ISNULL(SUM(D2_VALBRUT), 0) AS VALBRUTO, ISNULL(SUM(D2_VALBRUT - D2_VALIPI - D2_ICMSRET), 0) AS BASECOM " + CRLF
	cQuery += "FROM " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF2") + " AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL " + CRLF
	cQuery += "  AND F2_DOC = D2_DOC " + CRLF
	cQuery += "  AND F2_SERIE = D2_SERIE " + CRLF
	cQuery += "  AND F2_CLIENTE = D2_CLIENTE " + CRLF
	cQuery += "  AND F2_LOJA = D2_LOJA " + CRLF
	cQuery += "  AND F2_TIPO = D2_TIPO " + CRLF
	cQuery += "  AND F2_EMISSAO = D2_EMISSAO " + CRLF
	If lGerente
		cQuery += "  AND EXISTS (SELECT A3_FILIAL FROM " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) WHERE A3_FILIAL = '" + XFILIAL("SA3") + "' AND A3_COD = F2_VEND1 AND A3_GEREN = '" + AllTrim( cCodGer ) + "' AND SA3.D_E_L_E_T_ = ' ') " + CRLF
	EndIf
	cQuery += "  AND SF2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(D2_FILIAL, 2) " + CRLF
	cQuery += "  AND F4_CODIGO = D2_TES " + CRLF
	cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5124','6124','5919') " + CRLF
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

	cQuery += "SELECT CASE WHEN LEFT( D1_FILIAL, 2) = '01' THEN 'Euroamerican' ELSE 'Outra' " + CRLF
	cQuery += "END AS EMPRESA, " + CRLF
	cQuery += "'Devolvido' AS TIPO, ISNULL(SUM((D1_TOTAL)) * (-1), 0) AS VALOR, ISNULL(SUM(D1_CUSTO) * (-1), 0) AS CUSTOMEDIO, ISNULL(SUM(D1_QUANT * B1_CUSTD) * (-1),0) AS CUSTOSTANDARD, 0 AS VALBRUTO, ISNULL(SUM((D1_TOTAL)) * (-1), 0) AS BASECOM  " + CRLF
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
	If lGerente
		cQuery += "  AND EXISTS (SELECT A3_FILIAL FROM " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) WHERE A3_FILIAL = '" + XFILIAL("SA3") + "' AND A3_COD = F2_VEND1 AND A3_GEREN = '" + AllTrim( cCodGer ) + "' AND SA3.D_E_L_E_T_ = ' ') " + CRLF
	EndIf
	cQuery += "  AND SF2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(D2_FILIAL, 2) " + CRLF
	cQuery += "  AND F4_CODIGO = D2_TES " + CRLF
	cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5124','6124','5919') " + CRLF
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
	
	cQuery += "SELECT CASE WHEN LEFT( C6_FILIAL, 2) = '01' THEN 'Euroamerican' ELSE 'Outra' " + CRLF
	cQuery += "END AS EMPRESA, " + CRLF
	cQuery += "'Carteira' AS TIPO, ISNULL(SUM(((C6_QTDVEN - C6_QTDENT ) * C6_PRCVEN)), 0) AS VALOR, ISNULL(SUM(((C6_QTDVEN - C6_QTDENT ) * B2_CM1)), 0) AS CUSTOMEDIO, ISNULL(SUM((C6_QTDVEN - C6_QTDENT ) * B1_CUSTD),0) AS CUSTOSTANDARD, ISNULL(SUM(((C6_QTDVEN - C6_QTDENT ) * C6_PRCVEN)), 0) AS VALBRUTO, 0 AS BASECOM " + CRLF
	cQuery += "FROM " + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SC5") + " AS SC5 WITH (NOLOCK) ON C5_FILIAL = C6_FILIAL " + CRLF
	cQuery += "  AND C5_NUM = C6_NUM " + CRLF
	cQuery += "  AND C5_TIPO = 'N' " + CRLF
	cQuery += "  AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = C5_FILIAL AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
	If lGerente
		cQuery += "  AND EXISTS (SELECT A3_FILIAL FROM " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) WHERE A3_FILIAL = '" + XFILIAL("SA3") + "' AND A3_COD = C5_VEND1 AND A3_GEREN = '" + AllTrim( cCodGer ) + "' AND SA3.D_E_L_E_T_ = ' ') " + CRLF
	EndIf
	cQuery += "  AND SC5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(C6_FILIAL, 2) " + CRLF
	cQuery += "  AND F4_CODIGO = C6_TES " + CRLF
	cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5124','6124','5919') " + CRLF
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

	cQuery += "SELECT CASE WHEN LEFT( C6_FILIAL, 2) = '01' THEN 'Euroamerican' ELSE 'Outra' " + CRLF
	cQuery += " END AS EMPRESA, " + CRLF
	cQuery += "'Vendido no Dia' AS TIPO, ISNULL(SUM(((C6_QTDVEN) * C6_PRCVEN)), 0) AS VALOR, ISNULL(SUM(((C6_QTDVEN) * B2_CM1)), 0) AS CUSTOMEDIO, ISNULL(SUM((C6_QTDVEN) * B1_CUSTD),0) AS CUSTOSTANDARD, ISNULL(SUM(((C6_QTDVEN) * C6_PRCVEN)), 0) AS VALBRUTO, 0 AS BASECOM " + CRLF
	cQuery += "FROM " + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SC5") + " AS SC5 WITH (NOLOCK) ON C5_FILIAL = C6_FILIAL " + CRLF
	cQuery += "  AND C5_NUM = C6_NUM " + CRLF
	cQuery += "  AND C5_TIPO = 'N' " + CRLF
	cQuery += "  AND C5_EMISSAO = '" + DTOS( dDataBase ) + "' " + CRLF
	cQuery += "  AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = C5_FILIAL AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
	If lGerente
		cQuery += "  AND EXISTS (SELECT A3_FILIAL FROM " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) WHERE A3_FILIAL = '" + XFILIAL("SA3") + "' AND A3_COD = C5_VEND1 AND A3_GEREN = '" + AllTrim( cCodGer ) + "' AND SA3.D_E_L_E_T_ = ' ') " + CRLF
	EndIf
	cQuery += "  AND SC5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(C6_FILIAL, 2) " + CRLF
	cQuery += "  AND F4_CODIGO = C6_TES " + CRLF
	cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5124','6124','5919') " + CRLF
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

	cQuery += "SELECT CASE WHEN LEFT( C6_FILIAL, 2) = '01' THEN 'Euroamerican' ELSE 'Outra' " + CRLF
	cQuery += " END AS EMPRESA, " + CRLF
	cQuery += "'Previsto Entrega no Dia' AS TIPO, ISNULL(SUM(((C6_QTDVEN) * C6_PRCVEN)), 0) AS VALOR, ISNULL(SUM(((C6_QTDVEN) * B2_CM1)), 0) AS CUSTOMEDIO, ISNULL(SUM((C6_QTDVEN) * B1_CUSTD),0) AS CUSTOSTANDARD, ISNULL(SUM(((C6_QTDVEN) * C6_PRCVEN)), 0) AS VALBRUTO, 0 AS BASECOM " + CRLF
	cQuery += "FROM " + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SC5") + " AS SC5 WITH (NOLOCK) ON C5_FILIAL = C6_FILIAL " + CRLF
	cQuery += "  AND C5_NUM = C6_NUM " + CRLF
	cQuery += "  AND C5_TIPO = 'N' " + CRLF
	cQuery += "  AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = C5_FILIAL AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
	If lGerente
		cQuery += "  AND EXISTS (SELECT A3_FILIAL FROM " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) WHERE A3_FILIAL = '" + XFILIAL("SA3") + "' AND A3_COD = C5_VEND1 AND A3_GEREN = '" + AllTrim( cCodGer ) + "' AND SA3.D_E_L_E_T_ = ' ') " + CRLF
	EndIf
	cQuery += "  AND SC5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(C6_FILIAL, 2) " + CRLF
	cQuery += "  AND F4_CODIGO = C6_TES " + CRLF
	cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
	cQuery += "  AND NOT SUBSTRING(F4_CF,2,3) = '124' " + CRLF
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
	nEuroDev := 0
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
		ElseIf AllTrim( TMP001->TIPO ) == "Devolvido" 
			If AllTrim( TMP001->EMPRESA ) == "Loja de Tintas"
				nEuro        += TMP001->VALOR
				aSts[01][01] += TMP001->VALOR
			EndIf
			nConsol   += TMP001->VALOR
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
	cHtml += '								<div class="huge"><B>' + AllTrim( Transform( nConsol, "@E 999,999,999,999.99") ) + '</B></div>' + CRLF
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

	If lDiretor
		cQuery := "SELECT EMPRESA, SUM(VOLUME) AS VOLUME, AVG(PRECO) AS PRECOMEDIO " + CRLF
		cQuery += "FROM (" + CRLF
		cQuery += "SELECT '01' AS FILIAL, 'Loja de Tintas' AS EMPRESA, CASE WHEN D2_SEGUM = 'KG' AND B1_CONV <> 0 THEN D2_QTSEGUM ELSE D2_QUANT END AS VOLUME, CASE WHEN B1_SEGUM = 'KG' AND B1_CONV <> 0 THEN CASE WHEN B1_TIPCONV = 'M' THEN D2_PRCVEN / B1_CONV ELSE D2_PRCVEN * B1_CONV END ELSE D2_PRCVEN END AS PRECO " + CRLF
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
		cQuery += "  AND NOT F4_CF IN ('5929','6929','5124','6124','5919') " + CRLF
		cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + XFILIAL("SB1") + "' " + CRLF
		cQuery += "  AND B1_COD = D2_COD " + CRLF
		cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "WHERE LEFT(D2_FILIAL, 2) = '01' " + CRLF
		cQuery += "AND D2_TIPO = 'N' " + CRLF
		cQuery += "AND LEFT( D2_EMISSAO, 6) = '" + Left( DTOS( dDataBase ), 6) + "' " + CRLF 
		cQuery += "AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = D2_FILIAL AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
		cQuery += "AND SD2.D_E_L_E_T_ = ' ' " + CRLF

		cQuery += ") AS AGRUPADO " + CRLF
		cQuery += "GROUP BY EMPRESA, FILIAL " + CRLF
		cQuery += "ORDER BY FILIAL " + CRLF
	
		TCQuery cQuery New Alias "VOLMED"
		dbSelectArea("VOLMED")
		dbGoTop()
	
		cHtml += '    <div class="form-group col-md-12">'+CRLF
		cHtml += '        <H3><i class="fa fa-university"></i> Volumes e Média de Preços</H3>'+CRLF
		cHtml += '    </div>'+CRLF
	
		cHtml += '	<div class="col-md-12" style="overflow-x:auto; width=100%; overflow-y:auto;">'+CRLF
		
		cHtml += '    <div class="form-group" style="max-height:300px; ">'+CRLF
		cHtml += '    	<table id="table" class="table table-bordered table-striped table-condensed col-md-12">'+CRLF
		cHtml += '    		<thead>'+CRLF
		cHtml += '      		<tr>'+CRLF
		cHtml += '		  			<th>Empresa</th>'+CRLF
		cHtml += '        			<th>Volume</th>'+CRLF
		cHtml += '        			<th>Média Preço Unitário</th>'+CRLF
		cHtml += '      		</tr>'+CRLF
		cHtml += '    		</thead>'+CRLF
		cHtml += '			<tbody>'+CRLF
	
		Do While !VOLMED->( Eof() )
			If AllTrim( VOLMED->EMPRESA ) == "Loja de Tintas"
				nEurMed := VOLMED->PRECOMEDIO
			EndIf

			cHtml += '				<tr>'+CRLF
			cHtml += '        			<td><B>' + AllTrim( VOLMED->EMPRESA ) + '</B></td>'+CRLF
			cHtml += '        			<td style="text-align: right;"><B>'+Transform(VOLMED->VOLUME,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
			cHtml += '        			<td style="text-align: right;"><B>'+Transform(VOLMED->PRECOMEDIO,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
			cHtml += '      		</tr>'+CRLF
	
			VOLMED->( dbSkip() )
		EndDo

		VOLMED->( dbCloseArea() )

		cHtml += '    		</tbody>'+CRLF
		cHtml += '  	</table>'+CRLF
		cHtml += '	  </div>'+CRLF
	
		cHtml += '  </div>'+CRLF
	EndIf

	cHtml += '<HR>' + CRLF

	If (lFilUsr .And. AllTrim( HttpSession->ccodusr ) $ cSoEuro) .Or. !lFilUsr
		cQuery := "SELECT GERENTE, VENDEDOR, NOME, SUM(TOTAL) AS TOTAL, SUM(DEVOLUCAO) AS DEVOLUCAO, SUM(CARTEIRA) AS CARTEIRA, SUM(CREDITO) AS CREDITO, SUM(ESTOQUE) AS ESTOQUE, SUM(AFATURAR) AS AFATURAR, SUM(BRUTO) AS BRUTO, SUM(META) AS META, SUM(BASECOM) AS BASECOM, SUM(VENDDIA) AS VENDDIA, SUM(CUSTO) AS CUSTO, SUM(VALOR) AS VALOR, SUM(VOLUME) AS VOLUME, AVG(PRECOMEDIO) AS PRECOMEDIO " + CRLF
		cQuery += "FROM  ( " + CRLF
		cQuery += "SELECT ISNULL(A3_GEREN, '') AS GERENTE, ISNULL(A3_COD, '') AS VENDEDOR, ISNULL(A3_NOME, '') AS NOME, SUM(D2_VALBRUT) AS TOTAL, 0 AS DEVOLUCAO, 0 AS CARTEIRA, 0 AS CREDITO, 0 AS ESTOQUE, 0 AS AFATURAR, SUM(D2_VALBRUT) AS BRUTO, 0 AS META, ISNULL(SUM(D2_VALBRUT - D2_VALIPI - D2_ICMSRET), 0) AS BASECOM, 0 AS VENDDIA, SUM(D2_CUSTO1) CUSTO, ISNULL(SUM(D2_VALBRUT), 0) AS VALOR, SUM(CASE WHEN D2_SEGUM = 'KG' AND B1_CONV <> 0 THEN D2_QTSEGUM ELSE D2_QUANT END) AS VOLUME, AVG(CASE WHEN B1_SEGUM = 'KG' AND B1_CONV <> 0 THEN CASE WHEN B1_TIPCONV = 'M' THEN D2_PRCVEN / B1_CONV ELSE D2_PRCVEN * B1_CONV END ELSE D2_PRCVEN END) AS PRECOMEDIO " + CRLF
		cQuery += "FROM " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SF2") + " AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL " + CRLF
		cQuery += "  AND F2_DOC = D2_DOC " + CRLF
		cQuery += "  AND F2_SERIE = D2_SERIE " + CRLF
		cQuery += "  AND F2_CLIENTE = D2_CLIENTE " + CRLF
		cQuery += "  AND F2_LOJA = D2_LOJA " + CRLF
		cQuery += "  AND F2_TIPO = D2_TIPO " + CRLF
		cQuery += "  AND F2_EMISSAO = D2_EMISSAO " + CRLF
		If lGerente
			cQuery += "  AND EXISTS (SELECT A3_FILIAL FROM " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) WHERE A3_FILIAL = '" + XFILIAL("SA3") + "' AND A3_COD = F2_VEND1 AND A3_GEREN = '" + AllTrim( cCodGer ) + "' AND SA3.D_E_L_E_T_ = ' ') " + CRLF
		EndIf
		cQuery += "  AND SF2.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = '01' " + CRLF
		cQuery += "  AND F4_CODIGO = D2_TES " + CRLF
		cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
		cQuery += "  AND NOT F4_CF IN ('5929','6929','5124','6124','5919') " + CRLF
		cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + XFILIAL("SB1") + "' " + CRLF
		cQuery += "  AND B1_COD = D2_COD " + CRLF
		cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "LEFT JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_FILIAL = '" + XFILIAL("SA3") + "' " + CRLF
		cQuery += "  AND A3_COD = F2_VEND1 " + CRLF
		cQuery += "  AND SA3.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "WHERE LEFT(D2_FILIAL, 2) = '01' " + CRLF
		cQuery += "AND D2_TIPO = 'N' " + CRLF
		cQuery += "AND LEFT(D2_EMISSAO, 6) = '" + Left( DTOS( dDataBase ), 6) + "' " + CRLF
		cQuery += "AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = D2_FILIAL AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
		cQuery += "AND SD2.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "GROUP BY A3_GEREN, A3_COD, A3_NOME " + CRLF
		cQuery += ") AS AGRUPADO " + CRLF
		cQuery += "GROUP BY GERENTE, VENDEDOR, NOME " + CRLF
		cQuery += "ORDER BY GERENTE, VENDEDOR, NOME " + CRLF
	
		TCQuery cQuery New Alias "TMP001"
		dbSelectArea("TMP001")
		dbGoTop()

		cHtml += '    <div class="form-group col-md-12">'+CRLF
		cHtml += '        <H3><i class="fa fa-bars fa-1x"></i> Posição do Faturamento por Vendedores - Loja de Tintas</H3>'+CRLF
		cHtml += '    </div>'+CRLF
	
		cHtml += '	<div class="col-md-12" style="overflow-x:auto; width=100%; overflow-y:auto;">'+CRLF
		
		cHtml += '    <div class="form-group" style="max-height:300px; ">'+CRLF
		cHtml += '      <table id="relatorio" class="table table-striped table-bordered table-condensed col-md-12" style="width:100%">'+CRLF
		cHtml += '    		<thead>'+CRLF
		cHtml += '      		<tr>'+CRLF
		cHtml += '		  			<th>Ações</th>
		cHtml += '		  			<th>Vendedor</th>'+CRLF
		cHtml += '        			<th>Nome</th>'+CRLF
		cHtml += '        			<th>Meta</th>'+CRLF
	//	cHtml += '        			<th>Vlr. Devol.</th>'+CRLF
		cHtml += '        			<th>Base Comissão Bruto</th>'+CRLF //Fat - Dev
		If lDiretor
			cHtml += '        			<th>% Mrg Contribuição</th>'+CRLF
		EndIf
		cHtml += '        			<th>% Atendido</th>'+CRLF
		cHtml += '        			<th>Aguard. Lib.</th>'+CRLF
		cHtml += '        			<th>Aguard. Crédito</th>'+CRLF
		cHtml += '        			<th>Aguard. Estoque</th>'+CRLF
		cHtml += '        			<th>Aguard. Faturamento</th>'+CRLF
		cHtml += '        			<th>Vendidos no Dia</th>'+CRLF
		cHtml += '        			<th>Volumes</th>'+CRLF
		cHtml += '        			<th>Prc. Médio</th>'+CRLF
		cHtml += '      		</tr>'+CRLF
		cHtml += '    		</thead>'+CRLF
		cHtml += '			<tbody>'+CRLF

		nBruto    := 0
		nTotal    := 0
		nDevol    := 0
		nCarteira := 0
		nCredito  := 0
		nEstoque  := 0
		nAFaturar := 0
		nDia      := 0
		cGerente  := "&%*$@#"
		nGerBru   := 0
		nGerTot   := 0
		nGerDev   := 0
		nGerCar   := 0
		nGerCre   := 0
		nGerEst   := 0
		nGerFat   := 0
		nGerDia   := 0
		nMeta     := 0
		nGerMet   := 0
		nBaseCom  := 0
		nGerBas   := 0
		nValor    := 0
		nGerVal   := 0
		nCusto    := 0
		nGerCus   := 0
		nVolume   := 0
		nGerVol   := 0
		nPrcMed   := 0
		nGerMed   := 0
	
		Do While !TMP001->( Eof() )
			If AllTrim( cGerente ) <> AllTrim( TMP001->GERENTE )
				If AllTrim( cGerente ) <> "&%*$@#"
					cHtml += '				<tr>'+CRLF
					cHtml += '        			<td></td>'+CRLF
					cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
					cHtml += '        			<td><B><I><font color="DimGray">Sub-Total Gerente:</font></I></B></td>'+CRLF
					cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+Transform(nGerMet,PesqPict("SB2","B2_VATU1"))+'</font></I></B></td>'+CRLF
				//	cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+Transform(nGerDev,PesqPict("SB2","B2_VATU1"))+'</font></I></B></td>'+CRLF
					cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+Transform(nGerBas - IIf(nGerDev < 0, (nGerDev * (-1)), nGerDev),PesqPict("SB2","B2_VATU1"))+'</font></I></B></td>'+CRLF
					If lDiretor
						If nGerVal > 0 .And. nGerCus > 0
							nPercAt := 100 - ((nGerCus / nGerVal) * 100)
						Else
							nPercAt := 0
						EndIf
						cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+AllTrim( Transform( nPercAt,PesqPict("SB2","B2_VATU1")) )+'%</font></I></B></td>'+CRLF
					EndIf
					nPercAt := (nGerDev * (-1))
					cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+AllTrim( Transform( nPercAt,PesqPict("SB2","B2_VATU1")) )+'%</font></I></B></td>'+CRLF
					cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+Transform(nGerCar,PesqPict("SB2","B2_VATU1"))+'</font></I></B></td>'+CRLF
					cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+Transform(nGerCre,PesqPict("SB2","B2_VATU1"))+'</font></I></B></td>'+CRLF
					cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+Transform(nGerEst,PesqPict("SB2","B2_VATU1"))+'</font></I></B></td>'+CRLF
					cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+Transform(nGerFat,PesqPict("SB2","B2_VATU1"))+'</font></I></B></td>'+CRLF
					cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+Transform(nGerDia,PesqPict("SB2","B2_VATU1"))+'</font></I></B></td>'+CRLF
					cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+Transform(nGerVol,PesqPict("SB2","B2_VATU1"))+'</font></I></B></td>'+CRLF
					cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+Transform(nGerMed,PesqPict("SB2","B2_VATU1"))+'</font></I></B></td>'+CRLF
					cHtml += '      		</tr>'+CRLF
				EndIf
	
				cGerente := AllTrim( TMP001->GERENTE )
				nGerBru  := 0
				nGerTot  := 0
				nGerDev  := 0
				nGerCar  := 0
				nGerCre  := 0
				nGerEst  := 0
				nGerFat  := 0
				nGerDia  := 0
				nGerMet  := 0
				nGerBas  := 0
				nGerVal  := 0
				nGerCus  := 0
				nGerVol  := 0
				nGerMed  := 0
				
				cHtml += '				<tr>'+CRLF
				cHtml += '        			<td></td>'+CRLF
				If Empty(cGerente)
					cHtml += '        			<td><B><I><font color="DimGray">'+"Gerente:"+'</font></I></B></td>'+CRLF
				Else
					cHtml += '        			<td><B><I><font color="DimGray">'+"Gerente: "+cGerente+'</font></I></B></td>'+CRLF
				EndIf
				If Empty(cGerente)
					If lDiretor
						cHtml += '        			<td><B><I><font color="DimGray">[Não Possui Gerente]</font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						//cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
					Else
						cHtml += '        			<td><B><I><font color="DimGray">[Não Possui Gerente]</font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						//cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
					EndIf
				Else
					If lDiretor
						cHtml += '        			<td><B><I><font color="DimGray">'+Posicione("SA3", 1, xFilial("SA3") + cGerente, "A3_NOME")+'</font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						//cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
					Else
						cHtml += '        			<td><B><I><font color="DimGray">'+Posicione("SA3", 1, xFilial("SA3") + cGerente, "A3_NOME")+'</font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						//cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
						cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
					EndIf
				EndIf
				cHtml += '      		</tr>'+CRLF
			EndIf
	
			cHtml += '				<tr>'+CRLF
			cHtml += '					<td>'
			cHtml += '						<div class="btn-group">'
			cHtml += ' 							<button type="button" class="btn btn-sm dropdown-toggle" data-toggle="dropdown">'
			cHtml += '    							<span class="caret"></span>'
			cHtml += '    							<span class="sr-only">Toggle Dropdown</span>'
			cHtml += '  						</button>'
			cHtml += '  						<ul class="dropdown-menu" role="menu">
			cHtml += '    							<li><a href="u_bep0505.apw?filexc='+cFilAnt+'&codvend='+TMP001->VENDEDOR+'&emppor=02&filpor=00&nopc=2">Detalhar</a></li>
			cHtml += '  						</ul>
			cHtml += '						</div>
			cHtml += '					</td>
			cHtml += '        			<td>'+TMP001->VENDEDOR+'</td>'+CRLF
			cHtml += '        			<td>'+TMP001->NOME+'</td>'+CRLF
			cHtml += '        			<td style="text-align: right;">'+Transform(TMP001->META,PesqPict("SB2","B2_VATU1"))+'</td>'+CRLF
			//cHtml += '        			<td style="text-align: right;">'+Transform(TMP001->DEVOLUCAO,PesqPict("SB2","B2_VATU1"))+'</td>'+CRLF
			cHtml += '        			<td style="text-align: right;">'+Transform(TMP001->BASECOM - IIf(TMP001->DEVOLUCAO < 0, (TMP001->DEVOLUCAO * (-1)), TMP001->DEVOLUCAO),PesqPict("SB2","B2_VATU1"))+'</td>'+CRLF
			
			If lDiretor
				If TMP001->VALOR > 0 .And. TMP001->CUSTO > 0
					nPercAt := 100 - ((TMP001->CUSTO / TMP001->VALOR) * 100)
				Else
					nPercAt := 0
				EndIf
				cHtml += '        			<td style="text-align: right;">'+AllTrim( Transform( nPercAt,PesqPict("SB2","B2_VATU1")) )+'%</td>'+CRLF
			EndIf
			nPercAt := (TMP001->DEVOLUCAO * (-1))
			cHtml += '        			<td style="text-align: right;">'+AllTrim( Transform( nPercAt,PesqPict("SB2","B2_VATU1")) )+'%</td>'+CRLF
			cHtml += '        			<td style="text-align: right;">'+Transform(TMP001->CARTEIRA,PesqPict("SB2","B2_VATU1"))+'</td>'+CRLF
			cHtml += '        			<td style="text-align: right;">'+Transform(TMP001->CREDITO,PesqPict("SB2","B2_VATU1"))+'</td>'+CRLF
			cHtml += '        			<td style="text-align: right;">'+Transform(TMP001->ESTOQUE,PesqPict("SB2","B2_VATU1"))+'</td>'+CRLF
			cHtml += '        			<td style="text-align: right;">'+Transform(TMP001->AFATURAR,PesqPict("SB2","B2_VATU1"))+'</td>'+CRLF
			cHtml += '        			<td style="text-align: right;">'+Transform(TMP001->VENDDIA,PesqPict("SB2","B2_VATU1"))+'</td>'+CRLF
			cHtml += '        			<td style="text-align: right;">'+Transform(TMP001->VOLUME,PesqPict("SB2","B2_VATU1"))+'</td>'+CRLF
			cHtml += '        			<td style="text-align: right;">'+Transform(TMP001->PRECOMEDIO,PesqPict("SB2","B2_VATU1"))+'</td>'+CRLF
			cHtml += '      		</tr>'+CRLF
	
			nBruto    += TMP001->BRUTO
			nTotal    += TMP001->TOTAL
			nDevol    += TMP001->DEVOLUCAO
			nCarteira += TMP001->CARTEIRA
			nCredito  += TMP001->CREDITO
			nEstoque  += TMP001->ESTOQUE
			nAFaturar += TMP001->AFATURAR
			nDia      += TMP001->VENDDIA
			nGerBru   += TMP001->BRUTO
			nGerTot   += TMP001->TOTAL
			nGerDev   += TMP001->DEVOLUCAO
			nGerCar   += TMP001->CARTEIRA
			nGerCre   += TMP001->CREDITO
			nGerEst   += TMP001->ESTOQUE
			nGerFat   += TMP001->AFATURAR
			nGerDia   += TMP001->VENDDIA
			nMeta     += TMP001->META
			nGerMet   += TMP001->META
			nBaseCom  += TMP001->BASECOM
			nGerBas   += TMP001->BASECOM
			nValor    += TMP001->VALOR
			nGerVal   += TMP001->VALOR
			nCusto    += TMP001->CUSTO
			nGerCus   += TMP001->CUSTO
			nVolume   += TMP001->VOLUME
			nGerVol   += TMP001->VOLUME
			nPrcMed   := nEurMed
	
			TMP001->( dbSkip() )
		EndDo
	
		cHtml += '				<tr>'+CRLF
		cHtml += '        			<td></td>'+CRLF
		cHtml += '        			<td><B><I><font color="DimGray"></font></I></B></td>'+CRLF
		cHtml += '        			<td><B><I><font color="DimGray">Sub-Total Gerente:</font></I></B></td>'+CRLF
		cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+Transform(nGerMet,PesqPict("SB2","B2_VATU1"))+'</font></I></B></td>'+CRLF
		//cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+Transform(nGerDev,PesqPict("SB2","B2_VATU1"))+'</font></I></B></td>'+CRLF
		cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+Transform(nGerBas - IIf(nGerDev < 0, (nGerDev * (-1)), nGerDev),PesqPict("SB2","B2_VATU1"))+'</font></I></B></td>'+CRLF
		If lDiretor
			If nGerVal > 0 .And. nGerCus > 0
				nPercAt := 100 - ((nGerCus / nGerVal) * 100)
			Else
				nPercAt := 0
			EndIf
			cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+AllTrim( Transform( nPercAt,PesqPict("SB2","B2_VATU1")) )+'%</font></I></B></td>'+CRLF
		EndIf
		nPercAt := (nGerDev * (-1))
		cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+AllTrim( Transform( nPercAt,PesqPict("SB2","B2_VATU1")) )+'%</font></I></B></td>'+CRLF
		cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+Transform(nGerCar,PesqPict("SB2","B2_VATU1"))+'</font></I></B></td>'+CRLF
		cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+Transform(nGerCre,PesqPict("SB2","B2_VATU1"))+'</font></I></B></td>'+CRLF
		cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+Transform(nGerEst,PesqPict("SB2","B2_VATU1"))+'</font></I></B></td>'+CRLF
		cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+Transform(nGerFat,PesqPict("SB2","B2_VATU1"))+'</font></I></B></td>'+CRLF
		cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+Transform(nGerDia,PesqPict("SB2","B2_VATU1"))+'</font></I></B></td>'+CRLF
		cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+Transform(nGerVol,PesqPict("SB2","B2_VATU1"))+'</font></I></B></td>'+CRLF
		cHtml += '        			<td style="text-align: right;"><B><I><font color="DimGray">'+Transform(nGerMed,PesqPict("SB2","B2_VATU1"))+'</font></I></B></td>'+CRLF
		cHtml += '      		</tr>'+CRLF
	
		TMP001->( dbCloseArea() )
	
		cHtml += '				<tr>'+CRLF
		cHtml += '        			<td></td>'+CRLF
		cHtml += '        			<td><B>Total Geral:</B></td>'+CRLF
		cHtml += '        			<td></td>'+CRLF
		cHtml += '        			<td style="text-align: right;"><B>'+Transform(nMeta,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
		//cHtml += '        			<td style="text-align: right;"><B>'+Transform(nDevol,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
		cHtml += '        			<td style="text-align: right;"><B>'+Transform(nBaseCom - IIf(nDevol < 0, (nDevol * (-1)), nDevol),PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
		If lDiretor
			If nValor > 0 .And. nCusto > 0
				nPercAt := 100 - ((nCusto / nValor) * 100)
			Else
				nPercAt := 0
			EndIf
			cHtml += '        			<td style="text-align: right;"><B>'+AllTrim( Transform( nPercAt,PesqPict("SB2","B2_VATU1")) )+'%</B></td>'+CRLF
		EndIf
		nPercAt := (nDevol * (-1))
		cHtml += '        			<td style="text-align: right;"><B>'+AllTrim( Transform( nPercAt,PesqPict("SB2","B2_VATU1")) )+'%</B></td>'+CRLF
		cHtml += '        			<td style="text-align: right;"><B>'+Transform(nCarteira,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
		cHtml += '        			<td style="text-align: right;"><B>'+Transform(nCredito,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
		cHtml += '        			<td style="text-align: right;"><B>'+Transform(nEstoque,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
		cHtml += '        			<td style="text-align: right;"><B>'+Transform(nAFaturar,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
		cHtml += '        			<td style="text-align: right;"><B>'+Transform(nDia,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
		cHtml += '        			<td style="text-align: right;"><B>'+Transform(nVolume,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
		cHtml += '        			<td style="text-align: right;"><B>'+Transform(nPrcMed,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
		cHtml += '      		</tr>'+CRLF
	
		cHtml += '    		</tbody>'+CRLF
		cHtml += '  	</table>'+CRLF
		cHtml += '	  </div>'+CRLF
	
		cHtml += '  </div>'+CRLF
	
			cHtml += '<HR>' + CRLF
	EndIf
	
	cHtml += '	</div>'
	cHtml += '</div>'

	cHtml += '							<script>' + CRLF
	cHtml += '$(document).ready(function() {
	cHtml += "    $('#relatorio').DataTable( {
	cHtml += "        dom: 'Bfrtip',
	cHtml += '        "paging":   false,
	cHtml += '        "ordering": false,
	cHtml += '        "info":     false,
	cHtml += '        buttons: [
	cHtml += '            {
	cHtml += "                extend: 'pdfHtml5',
	cHtml += "                orientation: 'landscape',
	cHtml += "                pageSize: 'LEGAL'
	cHtml += '            }
	cHtml += "        , 'excel']
	cHtml += '    } );
	cHtml += '} );
	cHtml += '							</script>' + CRLF

	cHtml += '							<script>' + CRLF
	cHtml += '						$(document).ready(function() {
	cHtml += "						    $('#relatorio1').DataTable( {
	cHtml += "        dom: 'Bfrtip',
	cHtml += '        "paging":   false,
	cHtml += '        "ordering": false,
	cHtml += '        "info":     false,
	cHtml += '        buttons: [
	cHtml += '            {
	cHtml += "                extend: 'pdfHtml5',
	cHtml += "                orientation: 'landscape',
	cHtml += "                pageSize: 'LEGAL'
	cHtml += '            }
	cHtml += "        , 'excel']
	cHtml += '						    } );
	cHtml += '						} );
	cHtml += '							</script>' + CRLF

	cHtml += '							<script>' + CRLF
	cHtml += '						$(document).ready(function() {
	cHtml += "						    $('#relatorio2').DataTable( {
	cHtml += "        dom: 'Bfrtip',
	cHtml += '        "paging":   false,
	cHtml += '        "ordering": false,
	cHtml += '        "info":     false,
	cHtml += '        buttons: [
	cHtml += '            {
	cHtml += "                extend: 'pdfHtml5',
	cHtml += "                orientation: 'landscape',
	cHtml += "                pageSize: 'LEGAL'
	cHtml += '            }
	cHtml += "        , 'excel']
	cHtml += '						    } );
	cHtml += '						} );
	cHtml += '							</script>' + CRLF
Else	
	cMsgHdr		:= "BEP0501 - Sessão não Iniciada"
	cMsgBody	:= "A sessão não foi iniciada, realize o Login!"

	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 

EndIf

cHtml += Execblock("BePFooter",.F.,.F.)

WEB EXTENDED END
	
Return (EncodeUTF8(cHtml))
