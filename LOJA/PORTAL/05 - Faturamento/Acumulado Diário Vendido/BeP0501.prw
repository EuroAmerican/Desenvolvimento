#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

// Programa Inicial da Faturamento
User Function BeP0501()

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
Local nTotBruto := 0
Local nTotComis := 0
Local nTotLote  := 0
Local cPeriodo  := ""
Local nEuro     := 0
Local nQualy    := 0
Local nJays     := 0
Local nConsol   := 0
Local aVendido  := {}
Local aVisGer   := {}
Local aCores    := {}
Local nCor      := 0
Local aVendido  := {}
Local nVend     := 0

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
	cHtml += '	<h2><i class="fas fa-dolly"></i> Faturamento: Vendas Diárias no Período [Acumulado]</h2>'
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

	aDia := {}

	cQuery := "SELECT EMPRESA, " + CRLF
	cQuery += "SUM(DIA01) AS DIA01, SUM(DIA02) AS DIA02, SUM(DIA03) AS DIA03, SUM(DIA04) AS DIA04, SUM(DIA05) AS DIA05, SUM(DIA06) AS DIA06, " + CRLF
	cQuery += "SUM(DIA07) AS DIA07, SUM(DIA08) AS DIA08, SUM(DIA09) AS DIA09, SUM(DIA10) AS DIA10, SUM(DIA11) AS DIA11, SUM(DIA12) AS DIA12, " + CRLF
	cQuery += "SUM(DIA13) AS DIA13, SUM(DIA14) AS DIA14, SUM(DIA15) AS DIA15, SUM(DIA16) AS DIA16, SUM(DIA17) AS DIA17, SUM(DIA18) AS DIA18, " + CRLF
	cQuery += "SUM(DIA19) AS DIA19, SUM(DIA20) AS DIA20, SUM(DIA21) AS DIA21, SUM(DIA22) AS DIA22, SUM(DIA23) AS DIA23, SUM(DIA24) AS DIA24, " + CRLF
	cQuery += "SUM(DIA25) AS DIA25, SUM(DIA26) AS DIA26, SUM(DIA27) AS DIA27, SUM(DIA28) AS DIA28, SUM(DIA29) AS DIA29, SUM(DIA30) AS DIA30, SUM(DIA31) AS DIA31 " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT CASE WHEN LEFT( D2_FILIAL, 2) = '01' THEN 'Loja de Titas' ELSE 'Outra' " + CRLF
	cQuery += "END AS EMPRESA, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '01' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA01, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '02' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA02, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '03' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA03, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '04' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA04, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '05' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA05, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '06' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA06, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '07' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA07, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '08' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA08, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '09' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA09, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '10' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA10, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '11' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA11, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '12' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA12, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '13' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA13, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '14' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA14, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '15' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA15, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '16' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA16, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '17' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA17, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '18' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA18, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '19' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA19, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '20' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA20, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '21' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA21, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '22' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA22, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '23' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA23, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '24' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA24, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '25' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA25, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '26' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA26, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '27' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA27, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '28' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA28, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '29' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA29, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '30' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA30, " + CRLF
	cQuery += "CASE WHEN RIGHT(D2_EMISSAO,2) = '31' THEN SUM(D2_VALBRUT-D2_VALIPI-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_DESPESA-D2_VALFRE-D2_DESCON-D2_SEGURO-D2_ICMSRET) ELSE 0 END AS DIA31 " + CRLF
	cQuery += "FROM " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF2") + " AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL " + CRLF
	cQuery += "AND F2_DOC = D2_DOC " + CRLF
	cQuery += "AND F2_SERIE = D2_SERIE " + CRLF
	cQuery += "AND F2_CLIENTE = D2_CLIENTE " + CRLF
	cQuery += "AND F2_LOJA = D2_LOJA " + CRLF
	cQuery += "AND F2_TIPO = D2_TIPO " + CRLF
	cQuery += "AND F2_EMISSAO = D2_EMISSAO " + CRLF
	cQuery += "AND SF2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(D2_FILIAL, 2) " + CRLF
	cQuery += "AND F4_CODIGO = D2_TES " + CRLF
	cQuery += "AND F4_DUPLIC = 'S' " + CRLF
	cQuery += "AND NOT F4_CF IN ('5929','6929','5919' ) " + CRLF
	cQuery += "AND SF4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "AND B1_COD = D2_COD " + CRLF
	cQuery += "AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE D2_FILIAL <> '****' " + CRLF
	cQuery += "AND D2_TIPO = 'N' " + CRLF
	cQuery += "AND LEFT( D2_EMISSAO, 6) = '" + Left( DTOS( dDataBase ), 6) + "' " + CRLF
	cQuery += "AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = D2_FILIAL AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND SD2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY LEFT(D2_FILIAL, 2), RIGHT(D2_EMISSAO,2) " + CRLF
	
	cQuery += "UNION ALL " + CRLF
	
	cQuery += "SELECT CASE WHEN LEFT( D1_FILIAL, 2) = '01' THEN 'Loja de Tintas' ELSE 'Outra' " + CRLF
	cQuery += "END AS EMPRESA, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '01' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA01, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '02' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA02, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '03' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA03, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '04' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA04, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '05' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA05, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '06' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA06, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '07' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA07, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '08' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA08, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '09' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA09, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '10' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA10, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '11' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA11, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '12' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA12, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '13' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA13, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '14' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA14, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '15' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA15, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '16' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA16, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '17' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA17, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '18' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA18, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '19' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA19, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '20' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA20, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '21' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA21, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '22' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA22, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '23' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA23, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '24' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA24, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '25' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA25, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '26' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA26, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '27' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA27, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '28' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA28, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '29' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA29, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '30' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA30, " + CRLF
	cQuery += "CASE WHEN RIGHT(D1_DTDIGIT,2) = '31' THEN SUM((D1_TOTAL) * (-1)) ELSE 0 END AS DIA31 " + CRLF
	cQuery += "FROM " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) ON D2_FILIAL = D1_FILIAL " + CRLF
	cQuery += "AND D2_DOC = D1_NFORI " + CRLF
	cQuery += "AND D2_SERIE = D1_SERIORI " + CRLF
	cQuery += "AND D2_CLIENTE = D1_FORNECE " + CRLF
	cQuery += "AND D2_LOJA = D1_LOJA " + CRLF
	cQuery += "AND D2_ITEM = D1_ITEMORI " + CRLF
	cQuery += "AND D2_TIPO = 'N' " + CRLF
	cQuery += "AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = D2_FILIAL AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND SD2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF2") + " AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL " + CRLF
	cQuery += "AND F2_DOC = D2_DOC " + CRLF
	cQuery += "AND F2_SERIE = D2_SERIE " + CRLF
	cQuery += "AND F2_CLIENTE = D2_CLIENTE " + CRLF
	cQuery += "AND F2_LOJA = D2_LOJA " + CRLF
	cQuery += "AND F2_TIPO = D2_TIPO " + CRLF
	cQuery += "AND F2_EMISSAO = D2_EMISSAO " + CRLF
	cQuery += "AND SF2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(D2_FILIAL, 2) " + CRLF
	cQuery += "AND F4_CODIGO = D2_TES " + CRLF
	cQuery += "AND F4_DUPLIC = 'S' " + CRLF
	cQuery += "AND NOT F4_CF IN ('5929','6929','5919' ) " + CRLF
	cQuery += "AND SF4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "AND B1_COD = D2_COD " + CRLF
	cQuery += "AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE D1_FILIAL <> '****' " + CRLF
	cQuery += "AND D1_TIPO = 'D' " + CRLF
	cQuery += "AND LEFT( D1_DTDIGIT, 6) = '" + Left( DTOS( dDataBase ), 6) + "' " + CRLF
	cQuery += "AND SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY LEFT(D1_FILIAL, 2), RIGHT(D1_DTDIGIT,2) " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF
	cQuery += "GROUP BY EMPRESA " + CRLF

	TCQuery cQuery New Alias "TMP001"
	dbSelectArea("TMP001")
	TMP001->( dbGoTop() )
	
	Do While !TMP001->( Eof() )
		aAdd( aDia, { TMP001->EMPRESA, TMP001->DIA01, TMP001->DIA02, TMP001->DIA03, TMP001->DIA04, TMP001->DIA05,;
		                               TMP001->DIA06, TMP001->DIA07, TMP001->DIA08, TMP001->DIA09, TMP001->DIA10,;
		                               TMP001->DIA11, TMP001->DIA12, TMP001->DIA13, TMP001->DIA14, TMP001->DIA15,;
		                               TMP001->DIA16, TMP001->DIA17, TMP001->DIA18, TMP001->DIA19, TMP001->DIA20,;
		                               TMP001->DIA21, TMP001->DIA22, TMP001->DIA23, TMP001->DIA24, TMP001->DIA25,;
		                               TMP001->DIA26, TMP001->DIA27, TMP001->DIA28, TMP001->DIA29, TMP001->DIA30, TMP001->DIA31, "" })

		TMP001->( dbSkip() )
	EndDo

	TMP001->( dbCloseArea() )

	nPosEmp := aScan( aDia, { |x| AllTrim( x[1] ) == "Loja de Tintas" } )
	If nPosEmp <> 0
		aDia[nPosEmp][33] := "#ff0040"
	Else
		aAdd( aDia, { "Loja Tintas",  0, 0, 0, 0, 0,;
		                               0, 0, 0, 0, 0,;
		                               0, 0, 0, 0, 0,;
		                               0, 0, 0, 0, 0,;
		                               0, 0, 0, 0, 0,;
		                               0, 0, 0, 0, 0,0, "#ff0040" })
	EndIf
	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-pie-chart fa-1x"></i> Dashboards Faturamentos Período: ' + cPeriodo + '</H3>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H5>Bases de Comissões</H5>'+CRLF
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
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5919' ) " + CRLF
	cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + XFILIAL("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = D2_COD " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE D2_FILIAL <> '****' " + CRLF
	cQuery += "AND D2_TIPO = 'N' " + CRLF
	cQuery += "AND LEFT( D2_EMISSAO, 6) = '" + Left( DTOS( dDataBase ), 6) + "' " + CRLF //"AND D2_EMISSAO BETWEEN '20190801' AND '20190831' " + CRLF
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
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5919' ) " + CRLF
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
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5919' ) " + CRLF
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

	cQuery += "SELECT CASE WHEN LEFT( C6_FILIAL, 2) = '01' THEN 'Loja de Tintas' ELSE 'Outros' " + CRLF
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
				nEuro        += TMP001->BASECOM
				aSts[01][01] += TMP001->BASECOM
			EndIf
			nConsol += TMP001->BASECOM
		ElseIf AllTrim( TMP001->TIPO ) == "Devolvido"
			If AllTrim( TMP001->EMPRESA ) == "Loja de Tintas"
				nEuro        += TMP001->BASECOM
				aSts[01][01] += TMP001->BASECOM
			EndIf
			nConsol += TMP001->BASECOM
		EndIf

		aAdd( aVendido, { 	AllTrim( TMP001->EMPRESA ),;
							AllTrim( TMP001->TIPO ),;
							IIf( AllTrim( TMP001->TIPO ) == "Carteira" .Or. AllTrim( TMP001->TIPO ) == "Vendido no Dia" .Or. AllTrim( TMP001->TIPO ) == "Previsto Entrega no Dia", 0, TMP001->MARGEM_S_CUSTO),;
							IIf( AllTrim( TMP001->TIPO ) == "Carteira" .Or. AllTrim( TMP001->TIPO ) == "Vendido no Dia" .Or. AllTrim( TMP001->TIPO ) == "Previsto Entrega no Dia", 0, TMP001->FATOR_S_CUSTO),;
							IIf( AllTrim( TMP001->TIPO ) == "Carteira" .Or. AllTrim( TMP001->TIPO ) == "Vendido no Dia" .Or. AllTrim( TMP001->TIPO ) == "Previsto Entrega no Dia", 0, TMP001->MARGEM_S_STD),;
							IIf( AllTrim( TMP001->TIPO ) == "Carteira" .Or. AllTrim( TMP001->TIPO ) == "Vendido no Dia" .Or. AllTrim( TMP001->TIPO ) == "Previsto Entrega no Dia", 0, TMP001->FATOR_S_STD),;
							IIf( AllTrim( TMP001->TIPO ) == "Carteira" .Or. AllTrim( TMP001->TIPO ) == "Vendido no Dia" .Or. AllTrim( TMP001->TIPO ) == "Previsto Entrega no Dia", 0, TMP001->VALOR),;
							TMP001->VALBRUTO,;
							TMP001->BASECOM,;
							TMP001->CUSTOMEDIO })

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

	nEurBC   := 0
	nEurMC   := 0
	nEurBCCA := 0
	nEurDia  := 0
	nQuaBC   := 0
	nQuaMC   := 0
	nQuaBCCA := 0
	nQuaDia  := 0
	nJayBC   := 0
	nJayMC   := 0
	nJayBCCA := 0
	nJayDia  := 0
	nPhoBC   := 0
	nPhoMC   := 0
	nPhoBCCA := 0
	nPhoDia  := 0
	nMetBC   := 0
	nMetMC   := 0
	nMetBCCA := 0
	nMetDia  := 0
	nVinBC   := 0
	nVinMC   := 0
	nVinBCCA := 0
	nVinDia  := 0
	nConBC   := 0
	nConMC   := 0
	nConBCCA := 0
	nConDia  := 0
	nEntDia  := 0
	nValSom  := 0
	nCusSom  := 0
	nFatorC  := 0

	For nVend := 1 To Len( aVendido )
		If aVendido[nVend][02] == "Faturado"
			nConBC   += aVendido[nVend][09]
			nConMC   += aVendido[nVend][03]
			nConBCCA += aVendido[nVend][09]
			nValSom  += aVendido[nVend][07]
			nCusSom  += aVendido[nVend][10]
		ElseIf aVendido[nVend][02] == "Devolvido"
			nConBC   += aVendido[nVend][09]
			nConMC   += aVendido[nVend][03]
			nConBCCA += aVendido[nVend][09]
		ElseIf aVendido[nVend][02] == "Carteira"
			nConBCCA += aVendido[nVend][08]
		ElseIf aVendido[nVend][02] == "Vendido no Dia"
			nConDia  += aVendido[nVend][08]
		ElseIf aVendido[nVend][02] == "Previsto Entrega no Dia"
			nEntDia  += aVendido[nVend][08]
		EndIf
	Next

	If nValSom > 0 .And. nCusSom > 0
		nFatorC := 100 - ((nCusSom / nValSom) * 100)
	EndIf

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H5>Visões Consolidadas</H5>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '		<div class="row">' + CRLF
	cHtml += '			<div class="col-lg-3 col-md-6">' + CRLF
	cHtml += '				<div class="panel panel-default">' + CRLF
	cHtml += '					<div class="panel-heading">' + CRLF
	cHtml += '						<div class="row">' + CRLF
	cHtml += '							<div class="col-xs-3">' + CRLF
	cHtml += '								<i class="fa fa-usd fa-5x"></i>' + CRLF //<i class="fa fa-tasks fa-5x"></i>
	cHtml += '							</div>' + CRLF
	cHtml += '							<div class="col-xs-9 text-right">' + CRLF
	cHtml += '								<div class="huge"><B>' + AllTrim( Transform( nConBC, "@E 999,999,999,999.99") ) + '</B></div>' + CRLF
	cHtml += '								<div>Base Comissão<Br>R$ [REAL]</div>' + CRLF
	cHtml += '							</div>' + CRLF
	cHtml += '						</div>' + CRLF
	cHtml += '					</div>' + CRLF
	cHtml += '				</div>' + CRLF
	cHtml += '			</div>' + CRLF
	cHtml += '			<div class="col-lg-3 col-md-6">' + CRLF
	cHtml += '				<div class="panel panel-default">' + CRLF
	cHtml += '					<div class="panel-heading">' + CRLF
	cHtml += '						<div class="row">' + CRLF
	cHtml += '							<div class="col-xs-3">' + CRLF
	cHtml += '								<i class="fa fa-usd fa-5x"></i>' + CRLF
	cHtml += '							</div>' + CRLF
	cHtml += '							<div class="col-xs-9 text-right">' + CRLF
	cHtml += '								<div class="huge"><B>' + AllTrim( Transform( nConBCCA, "@E 999,999,999,999.99") ) + '</B></div>' + CRLF
	cHtml += '								<div>Base Comissão + Carteira<Br>R$ [REAL]</div>' + CRLF
	cHtml += '							</div>' + CRLF
	cHtml += '						</div>' + CRLF
	cHtml += '					</div>' + CRLF
	cHtml += '				</div>' + CRLF
	cHtml += '			</div>' + CRLF
	cHtml += '			<div class="col-lg-3 col-md-6">' + CRLF
	cHtml += '				<div class="panel panel-default">' + CRLF
	cHtml += '					<div class="panel-heading">' + CRLF
	cHtml += '						<div class="row">' + CRLF
	cHtml += '							<div class="col-xs-3">' + CRLF
	cHtml += '								<i class="fa fa-usd fa-5x"></i>' + CRLF
	cHtml += '							</div>' + CRLF
	cHtml += '							<div class="col-xs-9 text-right">' + CRLF
	cHtml += '								<div class="huge"><B>' + AllTrim( Transform( nConDia, "@E 999,999,999,999.99") ) + '</B></div>' + CRLF
	cHtml += '								<div>Vendido no Dia<Br>R$ [REAL]</div>' + CRLF
	cHtml += '							</div>' + CRLF
	cHtml += '						</div>' + CRLF
	cHtml += '					</div>' + CRLF
	cHtml += '				</div>' + CRLF
	cHtml += '			</div>' + CRLF
	cHtml += '			<div class="col-lg-3 col-md-6">' + CRLF
	cHtml += '				<div class="panel panel-default">' + CRLF
	cHtml += '					<div class="panel-heading">' + CRLF
	cHtml += '						<div class="row">' + CRLF
	cHtml += '							<div class="col-xs-3">' + CRLF
	cHtml += '								<i class="fa fa-usd fa-5x"></i>' + CRLF
	cHtml += '							</div>' + CRLF
	cHtml += '							<div class="col-xs-9 text-right">' + CRLF
	cHtml += '								<div class="huge"><B>' + AllTrim( Transform( nEntDia, "@E 999,999,999,999.99") ) + '</B></div>' + CRLF
	cHtml += '								<div>Previsto Entrega no Dia<Br>R$ [REAL]</div>' + CRLF
	cHtml += '							</div>' + CRLF
	cHtml += '						</div>' + CRLF
	cHtml += '					</div>' + CRLF
	cHtml += '				</div>' + CRLF
	cHtml += '			</div>' + CRLF
	cHtml += '		</div>' + CRLF
	cHtml += '		<div class="row">' + CRLF
	cHtml += '			<div class="col-lg-3 col-md-6">' + CRLF
	cHtml += '				<div class="panel panel-default">' + CRLF
	cHtml += '					<div class="panel-heading">' + CRLF
	cHtml += '						<div class="row">' + CRLF
	cHtml += '							<div class="col-xs-3">' + CRLF
	cHtml += '								<i class="fa fa-usd fa-5x"></i>' + CRLF
	cHtml += '							</div>' + CRLF
	cHtml += '							<div class="col-xs-9 text-right">' + CRLF
	cHtml += '								<div class="huge"><B>' + AllTrim( Transform( nConMC, "@E 999,999,999,999.99") ) + ' | ' + AllTrim( Transform( nFatorC, "@R 999%") ) + '</B></div>' + CRLF
	cHtml += '								<div>Margem Contribuição<Br>R$ [REAL]</div>' + CRLF
	cHtml += '							</div>' + CRLF
	cHtml += '						</div>' + CRLF
	cHtml += '					</div>' + CRLF
	cHtml += '				</div>' + CRLF
	cHtml += '			</div>' + CRLF
	cHtml += '		</div>' + CRLF

	// Vendidos no Mês (pedidos emitidos no mês)
	cQuery := "SELECT CASE WHEN LEFT( C6_FILIAL, 2) = '01' THEN 'Loja de Tintas' ELSE 'Outra' " + CRLF
	cQuery += "END AS EMPRESA, " + CRLF
	cQuery += "ISNULL(SUM(((C6_QTDVEN - C6_QTDENT) * C6_PRCVEN)), 0) AS VALOR " + CRLF
	cQuery += "FROM " + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SC5") + " AS SC5 WITH (NOLOCK) ON C5_FILIAL = C6_FILIAL " + CRLF
	cQuery += "  AND C5_NUM = C6_NUM " + CRLF
	cQuery += "  AND C5_TIPO = 'N' " + CRLF
	cQuery += "  AND LEFT( C5_EMISSAO, 6) = '" + Left( DTOS( dDataBase ), 6) + "' " + CRLF
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
	cQuery += "WHERE C6_FILIAL <> '****' " + CRLF
	cQuery += "AND C6_BLQ = '' " + CRLF
	cQuery += "AND C6_QTDVEN > C6_QTDENT " + CRLF
	cQuery += "AND SC6.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY LEFT(C6_FILIAL, 2) " + CRLF

	TCQuery cQuery New Alias "PEDDIG"
	dbSelectArea("PEDDIG")
	dbGoTop()

	nPVMEuro := 0
	nPVMQual := 0
	nPVMJays := 0
	nPVMPhoe := 0
	nPVMMetr := 0
	nPVMVini := 0
	nPVMCons := 0

	Do While !PEDDIG->( Eof() )
		If AllTrim( PEDDIG->EMPRESA ) == "Loja de Tintas"
			nPVMEuro += PEDDIG->VALOR
		EndIf
		nPVMCons += PEDDIG->VALOR

		PEDDIG->( dbSkip() )
	EndDo

	PEDDIG->( dbCloseArea() )

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H5>Carteira Em Aberto- <B>[Com Emissão no Mês]</B></H5>'+CRLF
	cHtml += '    </div>'+CRLF
	cHtml += '		<div class="row">' + CRLF
	cHtml += '			<div class="col-lg-3 col-md-6">' + CRLF
	cHtml += '				<div class="panel panel-success">' + CRLF
	cHtml += '					<div class="panel-heading">' + CRLF
	cHtml += '						<div class="row">' + CRLF
	cHtml += '							<div class="col-xs-3">' + CRLF
	cHtml += '								<i class="fa fa-usd fa-5x"></i>' + CRLF //<i class="fa fa-tasks fa-5x"></i>
	cHtml += '							</div>' + CRLF
	cHtml += '							<div class="col-xs-9 text-right">' + CRLF
	cHtml += '								<div class="huge"><B>' + AllTrim( Transform( nPVMEuro, "@E 999,999,999,999.99") ) + '</B></div>' + CRLF
	cHtml += '								<div>Loja de Tintas<Br>R$ [REAL]</div>' + CRLF
	cHtml += '							</div>' + CRLF
	cHtml += '						</div>' + CRLF
	cHtml += '					</div>' + CRLF
	cHtml += '				</div>' + CRLF
	cHtml += '			</div>' + CRLF
	cHtml += '			<div class="col-lg-3 col-md-6">' + CRLF
	cHtml += '				<div class="panel panel-success">' + CRLF
	cHtml += '					<div class="panel-heading">' + CRLF
	cHtml += '						<div class="row">' + CRLF
	cHtml += '							<div class="col-xs-3">' + CRLF
	cHtml += '								<i class="fa fa-usd fa-5x"></i>' + CRLF
	cHtml += '							</div>' + CRLF
	cHtml += '							<div class="col-xs-9 text-right">' + CRLF
	cHtml += '								<div class="huge"><B>' + AllTrim( Transform( nPVMCons, "@E 999,999,999,999.99") ) + '</B></div>' + CRLF
	cHtml += '								<div>Consolidado<Br>R$ [REAL]</div>' + CRLF
	cHtml += '							</div>' + CRLF
	cHtml += '						</div>' + CRLF
	cHtml += '					</div>' + CRLF
	cHtml += '				</div>' + CRLF
	cHtml += '			</div>' + CRLF
	cHtml += '		</div>' + CRLF
	// Vendidos no Mês (pedidos entregas no mês)
	cQuery := "SELECT CASE WHEN LEFT( C6_FILIAL, 2) = '01' THEN 'Loja de Tintas' ELSE 'Outra' " + CRLF
	cQuery += "END AS EMPRESA, " + CRLF
	cQuery += "ISNULL(SUM(((C6_QTDVEN - C6_QTDENT) * C6_PRCVEN)), 0) AS VALOR " + CRLF
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
	cQuery += "WHERE C6_FILIAL <> '****' " + CRLF
	cQuery += "AND LEFT( C6_ENTREG, 6) = '" + Left( DTOS( dDataBase ), 6) + "' " + CRLF
	cQuery += "AND C6_BLQ = '' " + CRLF
	cQuery += "AND C6_QTDVEN > C6_QTDENT " + CRLF
	cQuery += "AND SC6.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY LEFT(C6_FILIAL, 2) " + CRLF

	TCQuery cQuery New Alias "PEDDIG"
	dbSelectArea("PEDDIG")
	dbGoTop()

	nPVEEuro := 0
	nPVEQual := 0
	nPVEJays := 0
	nPVEPhoe := 0
	nPVEMetr := 0
	nPVEVini := 0
	nPVECons := 0

	Do While !PEDDIG->( Eof() )
		If AllTrim( PEDDIG->EMPRESA ) == "Loja de Tintas"
			nPVEEuro += PEDDIG->VALOR
		EndIf
		nPVECons += PEDDIG->VALOR

		PEDDIG->( dbSkip() )
	EndDo

	PEDDIG->( dbCloseArea() )

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H5>Carteira Em Aberto- <B>[Com Entrega no Mês]</B></H5>'+CRLF
	cHtml += '    </div>'+CRLF
	cHtml += '		<div class="row">' + CRLF
	cHtml += '			<div class="col-lg-3 col-md-6">' + CRLF
	cHtml += '				<div class="panel panel-info">' + CRLF
	cHtml += '					<div class="panel-heading">' + CRLF
	cHtml += '						<div class="row">' + CRLF
	cHtml += '							<div class="col-xs-3">' + CRLF
	cHtml += '								<i class="fa fa-usd fa-5x"></i>' + CRLF 
	cHtml += '							</div>' + CRLF
	cHtml += '							<div class="col-xs-9 text-right">' + CRLF
	cHtml += '								<div class="huge"><B>' + AllTrim( Transform( nPVEEuro, "@E 999,999,999,999.99") ) + '</B></div>' + CRLF
	cHtml += '								<div>Loja de Tintas<Br>R$ [REAL]</div>' + CRLF
	cHtml += '							</div>' + CRLF
	cHtml += '						</div>' + CRLF
	cHtml += '					</div>' + CRLF
	cHtml += '				</div>' + CRLF
	cHtml += '			</div>' + CRLF
	cHtml += '			<div class="col-lg-3 col-md-6">' + CRLF
	cHtml += '				<div class="panel panel-info">' + CRLF
	cHtml += '					<div class="panel-heading">' + CRLF
	cHtml += '						<div class="row">' + CRLF
	cHtml += '							<div class="col-xs-3">' + CRLF
	cHtml += '								<i class="fa fa-usd fa-5x"></i>' + CRLF
	cHtml += '							</div>' + CRLF
	cHtml += '							<div class="col-xs-9 text-right">' + CRLF
	cHtml += '								<div class="huge"><B>' + AllTrim( Transform( nPVECons, "@E 999,999,999,999.99") ) + '</B></div>' + CRLF
	cHtml += '								<div>Consolidado<Br>R$ [REAL]</div>' + CRLF
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
	cHtml += '        <H3><i class="fa fa-bars fa-1x"></i> Relatório vendido diário para acompanhamento</H3>'+CRLF
	cHtml += '    </div>'+CRLF

	//Table
	cHtml += '	<div  class="col-md-12" style="overflow-x:auto; width=100%; overflow-y:auto;">'+CRLF

	cHtml += '    <div class="form-group" style="max-height:300px; ">'+CRLF
	cHtml += '    	<table id="table" class="table table-bordered table-striped table-condensed col-md-12">'+CRLF
	cHtml += '    		<thead>'+CRLF
	cHtml += '      		<tr>'+CRLF
	cHtml += '		  			<th>Empresa</th>'+CRLF
	cHtml += '        			<th>Tipo</th>'+CRLF
	cHtml += '        			<th>Base Comissão</th>'+CRLF
	cHtml += '        			<th>Receita Bruta</th>'+CRLF
	cHtml += '        			<th>Receita Líquida</th>'+CRLF
	cHtml += '        			<th>Perc. MC</th>'+CRLF
	cHtml += '        			<th>Margem Contribuição</th>'+CRLF
	cHtml += '      		</tr>'+CRLF
	cHtml += '    		</thead>'+CRLF
	cHtml += '			<tbody>'+CRLF
	
	nTotEst   := 0
	nTotBruto := 0
	nTotComis := 0

	For nVend := 1 To Len( aVendido )
		If aVendido[nVend][07] >= 0.00
			cHtml += '				<tr>'+CRLF
			cHtml += '        			<td>'+aVendido[nVend][01]+'</td>'+CRLF
			cHtml += '        			<td>'+aVendido[nVend][02]+'</td>'+CRLF
			If AllTrim( aVendido[nVend][02] ) == "Carteira"
				cHtml += '        			<td style="text-align: right;"><B><font color="blue"></font></B></td>'+CRLF //'+Transform(aVendido[nVend][09],PesqPict("SB2","B2_VATU1"))+'
				cHtml += '        			<td style="text-align: right;"><B><font color="blue">'+Transform(aVendido[nVend][08],PesqPict("SB2","B2_VATU1"))+'</font></B></td>'+CRLF
				cHtml += '        			<td style="text-align: right;"><B></B></td>'+CRLF
				cHtml += '        			<td style="text-align: right;"></td>'+CRLF
				cHtml += '        			<td style="text-align: right;"></td>'+CRLF
			ElseIf AllTrim( aVendido[nVend][02] ) == "Vendido no Dia"
				cHtml += '        			<td style="text-align: right;"><B><font color="cyan"></font></B></td>'+CRLF //'+Transform(aVendido[nVend][09],PesqPict("SB2","B2_VATU1"))+'
				cHtml += '        			<td style="text-align: right;"><B><font color="cyan">'+Transform(aVendido[nVend][08],PesqPict("SB2","B2_VATU1"))+'</font></B></td>'+CRLF
				cHtml += '        			<td style="text-align: right;"><B></B></td>'+CRLF
				cHtml += '        			<td style="text-align: right;"></td>'+CRLF
				cHtml += '        			<td style="text-align: right;"></td>'+CRLF
			ElseIf AllTrim( aVendido[nVend][02] ) == "Previsto Entrega no Dia"
				cHtml += '        			<td style="text-align: right;"><B><font color="Teal"></font></B></td>'+CRLF //'+Transform(aVendido[nVend][09],PesqPict("SB2","B2_VATU1"))+'
				cHtml += '        			<td style="text-align: right;"><B><font color="Teal">'+Transform(aVendido[nVend][08],PesqPict("SB2","B2_VATU1"))+'</font></B></td>'+CRLF
				cHtml += '        			<td style="text-align: right;"><B></B></td>'+CRLF
				cHtml += '        			<td style="text-align: right;"></td>'+CRLF
				cHtml += '        			<td style="text-align: right;"></td>'+CRLF
			Else
				cHtml += '        			<td style="text-align: right;"><B>'+Transform(aVendido[nVend][09],PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
				cHtml += '        			<td style="text-align: right;"><B>'+Transform(aVendido[nVend][08],PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
				cHtml += '        			<td style="text-align: right;"><B>'+Transform(aVendido[nVend][07],PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
				cHtml += '        			<td style="text-align: right;">'+Transform(100 - aVendido[nVend][04],PesqPict("SB2","B2_VATU1"))+'%</td>'+CRLF
				cHtml += '        			<td style="text-align: right;">'+Transform(aVendido[nVend][03],PesqPict("SB2","B2_VATU1"))+'</td>'+CRLF
			EndIf
			cHtml += '      		</tr>'+CRLF
		Else
			cHtml += '				<tr>'+CRLF
			cHtml += '        			<td>'+aVendido[nVend][01]+'</td>'+CRLF
			cHtml += '        			<td>'+aVendido[nVend][02]+'</td>'+CRLF
			cHtml += '        			<td style="text-align: right;"><B><font color="red">'+Transform(aVendido[nVend][09],PesqPict("SB2","B2_VATU1"))+'</font></B></td>'+CRLF
			cHtml += '        			<td style="text-align: right;"><B><font color="red"></font></B></td>'+CRLF
			cHtml += '        			<td style="text-align: right;"><B><font color="red">'+Transform(aVendido[nVend][07],PesqPict("SB2","B2_VATU1"))+'</font></B></td>'+CRLF
			cHtml += '        			<td style="text-align: right;"><B><font color="red"></font></B></td>'+CRLF
			cHtml += '        			<td style="text-align: right;"><B><font color="red"></font></B></td>'+CRLF
			cHtml += '      		</tr>'+CRLF
		EndIf

		nTotEst   += aVendido[nVend][07]
		nTotComis += aVendido[nVend][09]
		If AllTrim( aVendido[nVend][02] ) == "Faturado"
			nTotBruto += aVendido[nVend][08] // Somente faturamento para receita bruta conforme solicitação Roni...
		EndIf
	Next

	cHtml += '				<tr>'+CRLF
	cHtml += '        			<td><B>Total:</B></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td style="text-align: right;"><B>'+Transform(nTotComis,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
	cHtml += '        			<td style="text-align: right;"><B>'+Transform(nTotBruto,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
	cHtml += '        			<td style="text-align: right;"><B>'+Transform(nTotEst,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '      		</tr>'+CRLF

	cHtml += '    		</tbody>'+CRLF
	cHtml += '  	</table>'+CRLF
	cHtml += '	  </div>'+CRLF

	cHtml += '  </div>'+CRLF

	//cHtml += '<div class="main" style="margin-top: 50px;">' + CRLF
	cHtml += '	<div id="page-wrapper">' + CRLF
	cHtml += '		<div class="row">' + CRLF
	cHtml += '			<div class="col-lg-12">' + CRLF
	cHtml += '				<h2 class="page-header"><i class="fa fa-line-chart fa-1x"></i> Dashboard Faturamento</h2>' + CRLF
	cHtml += '			</div>' + CRLF
	cHtml += '			<!-- /.col-lg-12 -->' + CRLF
	cHtml += '		</div>' + CRLF
	// Linha 1 dos gráficos...
	cHtml += '		<div class="row">' + CRLF

	cHtml += '			<div class="col-lg-6 col-md-6">' + CRLF
	cHtml += '				<h5><i class="fa fa-bar-chart-o fa-fw"></i> Faturamento por Empresa (<B>' + cPeriodo + '</B>)</h5>' + CRLF
	cHtml += '				<hr/>' + CRLF
	cHtml += '				<div class="well well-lg">' + CRLF
	cHtml += '					<canvas class="my-4 w-100" id="myRosc" width="900" height="380"></canvas>' + CRLF
	cHtml += '					<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>' + CRLF
	cHtml += '					<script>' + CRLF
	cHtml += '						var ctx = document.getElementById("myRosc");' + CRLF
	cHtml += '						var myRosc = new Chart(ctx, {' + CRLF
	cHtml += "						type: 'horizontalBar'," + CRLF
	cHtml += '						data: {' + CRLF
	cHtml += '						labels: ["Loja de Tintas"],' + CRLF
	cHtml += '						datasets: [' + CRLF
	For nSts := 1 To Len( aSts )
		cHtml += '						{ ' + CRLF
		cHtml += '						data: [' + AllTrim( Str(aSts[nSts][01]) ) + ',' + AllTrim( Str(aSts[nSts][02]) ) + ',' + AllTrim( Str(aSts[nSts][03]) ) + ',' + AllTrim( Str(aSts[nSts][04]) ) + '],' + CRLF
		cHtml += '						label: "' + "Consolidado" + '",' + CRLF
		cHtml += '						borderColor: "#3e95cd",' + CRLF
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
	cHtml += '				<h5><i class="fa fa-bar-chart-o fa-fw"></i> Diário por Empresa (<B><font color="' + "#ff0040" + '">' + "Loja de Tintas" + '</font></B>)</h5>' + CRLF
	cHtml += '				<hr/>' + CRLF
	cHtml += '				<div class="well well-lg">' + CRLF
	cHtml += '					<canvas class="my-4 w-100" id="myChart" width="900" height="380"></canvas>' + CRLF
	cHtml += '					<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>' + CRLF
	cHtml += '					<script>' + CRLF
	cHtml += '						var ctx = document.getElementById("myChart");' + CRLF
	cHtml += '						var myChart = new Chart(ctx, {' + CRLF
	cHtml += "						type: 'line'," + CRLF
	cHtml += '						data: {' + CRLF
	cHtml += '						labels: ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"],' + CRLF
	cHtml += '						datasets: [' + CRLF
	For nAno := 1 To Len( aDia )
		cHtml += '						{ ' + CRLF
		cHtml += '						data: [' + AllTrim( Str(aDia[nAno][02]) ) + ',' + AllTrim( Str(aDia[nAno][03]) ) + ',' + AllTrim( Str(aDia[nAno][04]) ) + ',' + AllTrim( Str(aDia[nAno][05]) ) + ',' + AllTrim( Str(aDia[nAno][06]) ) + ',' + AllTrim( Str(aDia[nAno][07]) ) + ',' + AllTrim( Str(aDia[nAno][08]) ) + ',' + AllTrim( Str(aDia[nAno][09]) ) + ',' + AllTrim( Str(aDia[nAno][10]) ) + ',' + AllTrim( Str(aDia[nAno][11]) ) + ',' + AllTrim( Str(aDia[nAno][12]) ) + ',' + AllTrim( Str(aDia[nAno][13]) ) + ',' + AllTrim( Str(aDia[nAno][14]) ) + ',' + AllTrim( Str(aDia[nAno][15]) ) + ',' + AllTrim( Str(aDia[nAno][16]) ) + ',' + AllTrim( Str(aDia[nAno][17]) ) + ',' + AllTrim( Str(aDia[nAno][18]) ) + ',' + AllTrim( Str(aDia[nAno][19]) ) + ',' + AllTrim( Str(aDia[nAno][20]) ) + ',' + AllTrim( Str(aDia[nAno][21]) ) + ',' + AllTrim( Str(aDia[nAno][22]) ) + ',' + AllTrim( Str(aDia[nAno][23]) ) + ',' + AllTrim( Str(aDia[nAno][24]) ) + ',' + AllTrim( Str(aDia[nAno][25]) ) + ',' + AllTrim( Str(aDia[nAno][26]) ) + ',' + AllTrim( Str(aDia[nAno][27]) ) + ',' + AllTrim( Str(aDia[nAno][28]) ) + ',' + AllTrim( Str(aDia[nAno][29]) ) + ',' + AllTrim( Str(aDia[nAno][30]) ) + ',' + AllTrim( Str(aDia[nAno][31]) ) + ',' + AllTrim( Str(aDia[nAno][32]) ) + '],' + CRLF
		cHtml += '						label: "' + aDia[nAno][01] + '",' + CRLF
		cHtml += '						borderColor: "' + aDia[nAno][33] + '",' + CRLF
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

////
		cHtml += '		<div class="row">' + CRLF
		cHtml += '			<div class="col-lg-2 col-md-12">' + CRLF
		cHtml += '				<div class="panel panel-primary">' + CRLF
		cHtml += '					<div class="panel-heading">' + CRLF
		cHtml += '						<div class="row">' + CRLF
		cHtml += '							  <head>' + CRLF
		cHtml += '				   <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>' + CRLF
		cHtml += '				   <script type="text/javascript">' + CRLF
		cHtml += "				      google.charts.load('current', {'packages':['gauge']});" + CRLF
		cHtml += '				      google.charts.setOnLoadCallback(drawChart);' + CRLF
		cHtml += '				      function drawChart() {' + CRLF
		cHtml += '				        var data = google.visualization.arrayToDataTable([' + CRLF
		cHtml += "				                  ['Label', 'Value']," + CRLF
		cHtml += "				                  ['Euroamerican', " + AllTrim( Str((nEuro / nConsol) * 100.00) ) +  "]" + CRLF
		cHtml += '				                ]);' + CRLF
		cHtml += '				        var options = {' + CRLF
		cHtml += '				          width: 400, height: 120,' + CRLF
		cHtml += '				          redFrom: 90, redTo: 100,' + CRLF
		cHtml += '				          yellowFrom:75, yellowTo: 90,' + CRLF
		cHtml += '				          minorTicks: 5' + CRLF
		cHtml += '				    };' + CRLF
		cHtml += "				        var chart = new google.visualization.Gauge(document.getElementById('chart_div1'));" + CRLF
		cHtml += '				        chart.draw(data, options);' + CRLF
		cHtml += '				      }' + CRLF
		cHtml += '				    </script>' + CRLF
		cHtml += '							  <body>' + CRLF
		cHtml += '							    <div id="chart_div1" style="width: 400px; height: 120px;"></div>' + CRLF
		cHtml += '							  </body>' + CRLF
		cHtml += '							  <head>' + CRLF
		cHtml += '						</div>' + CRLF
		cHtml += '					</div>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
		cHtml += '			<div class="col-lg-2 col-md-12">' + CRLF
		cHtml += '				<div class="panel panel-sucess">' + CRLF
		cHtml += '					<div class="panel-heading">' + CRLF
		cHtml += '						<div class="row">' + CRLF
		cHtml += '							  <head>' + CRLF
		cHtml += '				   <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>' + CRLF
		cHtml += '				   <script type="text/javascript">' + CRLF
		cHtml += "				      google.charts.load('current', {'packages':['gauge']});" + CRLF
		cHtml += '				      google.charts.setOnLoadCallback(drawChart);' + CRLF
		cHtml += '				      function drawChart() {' + CRLF
		cHtml += '				        var data = google.visualization.arrayToDataTable([' + CRLF
		cHtml += "				                  ['Label', 'Value']," + CRLF
		cHtml += "				                  ['Qualycril', " + AllTrim( Str((nQualy / nConsol) * 100.00) ) +  "]" + CRLF
		cHtml += '				                ]);' + CRLF
		cHtml += '				        var options = {' + CRLF
		cHtml += '				          width: 400, height: 120,' + CRLF
		cHtml += '				          redFrom: 90, redTo: 100,' + CRLF
		cHtml += '				          yellowFrom:75, yellowTo: 90,' + CRLF
		cHtml += '				          minorTicks: 5' + CRLF
		cHtml += '				    };' + CRLF
		cHtml += "				        var chart = new google.visualization.Gauge(document.getElementById('chart_div2'));" + CRLF
		cHtml += '				        chart.draw(data, options);' + CRLF
		cHtml += '				      }' + CRLF
		cHtml += '				    </script>' + CRLF
		cHtml += '							  <body>' + CRLF
		cHtml += '							    <div id="chart_div2" style="width: 400px; height: 120px;"></div>' + CRLF
		cHtml += '							  </body>' + CRLF
		cHtml += '							  <head>' + CRLF
		cHtml += '						</div>' + CRLF
		cHtml += '					</div>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
		cHtml += '			<div class="col-lg-2 col-md-12">' + CRLF
		cHtml += '				<div class="panel panel-info">' + CRLF
		cHtml += '					<div class="panel-heading">' + CRLF
		cHtml += '						<div class="row">' + CRLF
		cHtml += '							  <head>' + CRLF
		cHtml += '				   <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>' + CRLF
		cHtml += '				   <script type="text/javascript">' + CRLF
		cHtml += "				      google.charts.load('current', {'packages':['gauge']});" + CRLF
		cHtml += '				      google.charts.setOnLoadCallback(drawChart);' + CRLF
		cHtml += '				      function drawChart() {' + CRLF
		cHtml += '				        var data = google.visualization.arrayToDataTable([' + CRLF
		cHtml += "				                  ['Label', 'Value']," + CRLF
		cHtml += "				                  ['Jays', " + AllTrim( Str((nJays / nConsol) * 100.00) ) +  "]" + CRLF
		cHtml += '				                ]);' + CRLF
		cHtml += '				        var options = {' + CRLF
		cHtml += '				          width: 400, height: 120,' + CRLF
		cHtml += '				          redFrom: 90, redTo: 100,' + CRLF
		cHtml += '				          yellowFrom:75, yellowTo: 90,' + CRLF
		cHtml += '				          minorTicks: 5' + CRLF
		cHtml += '				    };' + CRLF
		cHtml += "				        var chart = new google.visualization.Gauge(document.getElementById('chart_div3'));" + CRLF
		cHtml += '				        chart.draw(data, options);' + CRLF
		cHtml += '				      }' + CRLF
		cHtml += '				    </script>' + CRLF
		cHtml += '							  <body>' + CRLF
		cHtml += '							    <div id="chart_div3" style="width: 400px; height: 120px;"></div>' + CRLF
		cHtml += '							  </body>' + CRLF
		cHtml += '							  <head>' + CRLF
		cHtml += '						</div>' + CRLF
		cHtml += '					</div>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
		cHtml += '			<div class="col-lg-2 col-md-12">' + CRLF
		cHtml += '				<div class="panel panel-danger">' + CRLF
		cHtml += '					<div class="panel-heading">' + CRLF
		cHtml += '						<div class="row">' + CRLF
		cHtml += '							  <head>' + CRLF
		cHtml += '				   <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>' + CRLF
		cHtml += '				   <script type="text/javascript">' + CRLF
		cHtml += "				      google.charts.load('current', {'packages':['gauge']});" + CRLF
		cHtml += '				      google.charts.setOnLoadCallback(drawChart);' + CRLF
		cHtml += '				      function drawChart() {' + CRLF
		cHtml += '				        var data = google.visualization.arrayToDataTable([' + CRLF
		cHtml += "				                  ['Label', 'Value']," + CRLF
		cHtml += "				                  ['Phoenix', " + AllTrim( Str((nPhoe / nConsol) * 100.00) ) +  "]" + CRLF
		cHtml += '				                ]);' + CRLF
		cHtml += '				        var options = {' + CRLF
		cHtml += '				          width: 400, height: 120,' + CRLF
		cHtml += '				          redFrom: 90, redTo: 100,' + CRLF
		cHtml += '				          yellowFrom:75, yellowTo: 90,' + CRLF
		cHtml += '				          minorTicks: 5' + CRLF
		cHtml += '				    };' + CRLF
		cHtml += "				        var chart = new google.visualization.Gauge(document.getElementById('chart_div4'));" + CRLF
		cHtml += '				        chart.draw(data, options);' + CRLF
		cHtml += '				      }' + CRLF
		cHtml += '				    </script>' + CRLF
		cHtml += '							  <body>' + CRLF
		cHtml += '							    <div id="chart_div4" style="width: 400px; height: 120px;"></div>' + CRLF
		cHtml += '							  </body>' + CRLF
		cHtml += '							  <head>' + CRLF
		cHtml += '						</div>' + CRLF
		cHtml += '					</div>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
		cHtml += '		</div>' + CRLF

		cHtml += '		<div class="row">' + CRLF
		cHtml += '			<div class="col-lg-6 col-md-6">' + CRLF
		cHtml += '				<h5><i class="fa fa-bar-chart-o fa-fw"></i> Relevância por Empresa no Faturamento</h5>' + CRLF
		cHtml += ' 				<hr/>' + CRLF
		cHtml += '				<div class="well well-lg">' + CRLF
		cHtml += '					<canvas id="doughnutChartCol"></canvas>' + CRLF
		cHtml += '					<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>' + CRLF
		cHtml += '					<script>' + CRLF
		cHtml += "						var ctxD = document.getElementById(" + '"doughnutChartCol"' + ").getContext('2d');" + CRLF
		cHtml += '						var myLineChart = new Chart(ctxD, {' + CRLF
		cHtml += "						type: 'doughnut'," + CRLF
		cHtml += '						data: {' + CRLF
		cHtml += '						labels: ["Loja de Tintas"],' + CRLF
		cHtml += '						datasets: [' + CRLF
		cHtml += '						{' + CRLF
		cHtml += '						data: [' + AllTrim( Str(nEuro) ) + '],' + CRLF
		cHtml += '						backgroundColor: ["#d7d7e0", "#7b79ce", "#5a57e5", "#2825ba"],' + CRLF
		cHtml += '						hoverBackgroundColor: ["#d7d7e0", "#7b79ce", "#5a57e5", "#2825ba"]' + CRLF
		cHtml += '						}' + CRLF
		cHtml += '						]' + CRLF
		cHtml += '						},' + CRLF
		cHtml += '						options: {' + CRLF
		cHtml += '						responsive: true' + CRLF
		cHtml += '						}' + CRLF
		cHtml += '						});' + CRLF
		cHtml += '					</script>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF

	cQuery := "SELECT '[''BR-' + RTRIM(LTRIM(A1_EST)) + ''', ' + CONVERT(VARCHAR(20),CONVERT(DECIMAL(20,0),ISNULL(SUM(D2_VALBRUT - D2_VALIPI - D2_VALICM - D2_VALIMP5 - D2_VALIMP6 - D2_DESPESA - D2_VALFRE - D2_DESCON - D2_SEGURO - D2_ICMSRET), 0))) + '], ' AS CARGA " + CRLF
	cQuery += "FROM " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SA1") + " AS SA1 WITH (NOLOCK) ON A1_FILIAL = D2_FILIAL " + CRLF
	cQuery += "  AND A1_COD = D2_CLIENTE " + CRLF
	cQuery += "  AND A1_LOJA = D2_LOJA " + CRLF
	cQuery += "  AND A1_EST <> 'EX' " + CRLF
	cQuery += "  AND A1_EST <> '' " + CRLF
	cQuery += "  AND SA1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE D2_FILIAL <> '****' " + CRLF
	cQuery += "AND LEFT( D2_EMISSAO, 6) = '" + Left( DTOS( dDataBase ), 6) + "' " + CRLF
	cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("SF4") + " WHERE LEFT(F4_FILIAL, 2) = LEFT(D2_FILIAL, 2) AND F4_CODIGO = D2_TES AND F4_DUPLIC = 'S' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND D2_TIPO = 'N' " + CRLF
	cQuery += "AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = D2_FILIAL AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND SD2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY A1_EST " + CRLF

	TCQuery cQuery New Alias "TMPEST"
	dbSelectArea("TMPEST")
	dbGoTop()

	If !TMPEST->( Eof() )
		cHtml += '			<div class="col-lg-6 col-md-6">' + CRLF
		cHtml += '				<h5><i class="fa fa-bar-chart-o fa-fw"></i> Faturamento por Estado Consolidado</h5>' + CRLF
		cHtml += ' 				<hr/>' + CRLF
		cHtml += '				<div class="well well-lg">' + CRLF
		cHtml += '				        <head>' + CRLF
		cHtml += '				    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>' + CRLF
		cHtml += '				    <script type="text/javascript">' + CRLF
		cHtml += "				          google.charts.load('current', {" + CRLF
		cHtml += "				            'packages':['geochart']," + CRLF
		cHtml += "				            'mapsApiKey': 'AIzaSyD-9tSrke72PouQMnMX-a7eZSW0jkFMBWY'" + CRLF
		cHtml += '				          });' + CRLF
		cHtml += '				          google.charts.setOnLoadCallback(drawRegionsMap);' + CRLF
		cHtml += '				          function drawRegionsMap() {' + CRLF
		cHtml += '				            var data = google.visualization.arrayToDataTable([' + CRLF
		cHtml += "				          ['State', 'Views']," + CRLF
		Do While !TMPEST->( Eof() )
			cHtml += '				          ' +  TMPEST->CARGA + CRLF
			TMPEST->( dbSkip() )
		EndDo
		cHtml += '				          ]);' + CRLF
		cHtml += '				          var view = new google.visualization.DataView(data)' + CRLF
		cHtml += '				          view.setColumns([0, 1])' + CRLF
		cHtml += '				          var options = {' + CRLF
		cHtml += "				              region: 'BR'," + CRLF
		cHtml += "				              resolution: 'provinces'," + CRLF
		cHtml += '				              width: 556,' + CRLF
		cHtml += '				              height: 347' + CRLF
		cHtml += '				          };' + CRLF
		cHtml += "				            var chart = new google.visualization.GeoChart(document.getElementById('geochart-colors'));" + CRLF
		cHtml += '				            chart.draw(data, options);' + CRLF
		cHtml += '				          };' + CRLF
		cHtml += '				        </script>' + CRLF
		cHtml += '				        </head>' + CRLF
		cHtml += '				        <body>' + CRLF
		cHtml += '				            <div id="geochart-colors" style="width: 700px; height: 433px;"></div>' + CRLF
		cHtml += '				        </body>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
	EndIf

	TMPEST->( dbCloseArea() )
		cHtml += '		</div>' + CRLF

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
