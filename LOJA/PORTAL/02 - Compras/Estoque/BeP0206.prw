#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

// Programa Inicial da Liberação do Pedido de Compra
User Function BeP0206()

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
Local nRegSM0	:= SM0->(Recno())
Local cAnoAtu   := StrZero( Year( MsDate() )   , 4)
Local cAnoAnt   := StrZero( Year( MsDate() ) -1, 4)
Local cAnoAn2   := StrZero( Year( MsDate() ) -2, 4)
Local aAno      := {}
Local nAno      := 0
Local nPosAno   := 0
Local aSts      := {}
Local nSts      := 0
Local nTotEst   := 0
Local nTotLote  := 0

Private cHtml 	:= ""    

WEB EXTENDED INIT cHtml                               

cHtml += Execblock("BePHeader",.F.,.F.)

If lSession 
	cHtml += Execblock("BePMenus",.F.,.F.)
	
	cHtml += '<div class="main" style="margin-top: 50px;">'
	cHtml += '	<h2><i class="fas fa-dolly"></i> Análises Produtos</h2>'
	cHtml += '	<hr/>'
	cHtml += '  <form method="POST" id="formpc" action="u_bep0206A.apw" class="col-md-12" style="margin-bottom: 10px;">'+CRLF

/********************************************************************************************************************************/
/********************************************************************************************************************************/

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-pie-chart fa-1x"></i> Dashboards de Fechamentos e Lotes</H3>'+CRLF
	cHtml += '    </div>'+CRLF

	//Consolidado...
	nValCReal  := 0
	nValCDolar := 0
	nValCEuro  := 0
	nValCIene  := 0

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H4><i class="fa fa-building fa-1x"></i> Custos Consolidados</H4>'+CRLF
	cHtml += '    </div>'+CRLF
	
	cQuery := "SELECT SUM(VALOR_REAL) AS VALOR_REAL, SUM(VALOR_DOLAR) AS VALOR_DOLAR, SUM(VALOR_EURO) AS VALOR_EURO, SUM(VALOR_IENE) AS VALOR_IENE " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT SUM(B2_VATU1) AS VALOR_REAL, " + CRLF
	cQuery += "       CASE WHEN ISNULL((SELECT TOP 1 M2_MOEDA2 FROM " + RetSqlName("SM2") + " WHERE M2_DATA <= '" + DTOS( dDataBase ) + "' AND M2_MOEDA2 <> 0 AND D_E_L_E_T_ = ' ' ORDER BY M2_DATA DESC),0) = 0 THEN 0 ELSE SUM(B2_VATU1) / ISNULL((SELECT TOP 1 M2_MOEDA2 FROM " + RetSqlName("SM2") + " WHERE M2_DATA <= '" + DTOS( dDataBase ) + "' AND M2_MOEDA2 <> 0 AND D_E_L_E_T_ = ' ' ORDER BY M2_DATA DESC),0) END AS VALOR_DOLAR, " + CRLF
	cQuery += "       CASE WHEN ISNULL((SELECT TOP 1 M2_MOEDA4 FROM " + RetSqlName("SM2") + " WHERE M2_DATA <= '" + DTOS( dDataBase ) + "' AND M2_MOEDA4 <> 0 AND D_E_L_E_T_ = ' ' ORDER BY M2_DATA DESC),0) = 0 THEN 0 ELSE SUM(B2_VATU1) / ISNULL((SELECT TOP 1 M2_MOEDA4 FROM " + RetSqlName("SM2") + " WHERE M2_DATA <= '" + DTOS( dDataBase ) + "' AND M2_MOEDA4 <> 0 AND D_E_L_E_T_ = ' ' ORDER BY M2_DATA DESC),0) END AS VALOR_EURO, " + CRLF
	cQuery += "       CASE WHEN ISNULL((SELECT TOP 1 M2_MOEDA5 FROM " + RetSqlName("SM2") + " WHERE M2_DATA <= '" + DTOS( dDataBase ) + "' AND M2_MOEDA5 <> 0 AND D_E_L_E_T_ = ' ' ORDER BY M2_DATA DESC),0) = 0 THEN 0 ELSE SUM(B2_VATU1) * ISNULL((SELECT TOP 1 M2_MOEDA5 FROM " + RetSqlName("SM2") + " WHERE M2_DATA <= '" + DTOS( dDataBase ) + "' AND M2_MOEDA5 <> 0 AND D_E_L_E_T_ = ' ' ORDER BY M2_DATA DESC),0) END AS VALOR_IENE " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B2_FILIAL <> '**' " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF
	
	TCQuery cQuery New Alias "VALOR"
	dbSelectArea("VALOR")
	dbGoTop()
	
	If !VALOR->( Eof() )
		nValCReal  := VALOR->VALOR_REAL
		nValCDolar := VALOR->VALOR_DOLAR
		nValCEuro  := VALOR->VALOR_EURO
		nValCIene  := VALOR->VALOR_IENE
	EndIf
	
	VALOR->( dbCloseArea() )

&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
		cHtml += '		<div class="row">' + CRLF
		cHtml += '			<div class="col-lg-3 col-md-6">' + CRLF
		cHtml += '				<div class="panel panel-primary">' + CRLF
		cHtml += '					<div class="panel-heading">' + CRLF
		cHtml += '						<div class="row">' + CRLF
		cHtml += '							<div class="col-xs-3">' + CRLF
		cHtml += '								<i class="fa fa-usd fa-5x"></i>' + CRLF //<i class="fa fa-tasks fa-5x"></i>
		cHtml += '							</div>' + CRLF
		cHtml += '							<div class="col-xs-9 text-right">' + CRLF
		cHtml += '								<div class="huge"><B>' + AllTrim( Transform( nValCReal, "@E 999,999,999,999.99") ) + '</B></div>' + CRLF
		cHtml += '								<div>Valor de Estoque<Br>R$ [REAL]</div>' + CRLF
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
		cHtml += '								<div class="huge"><B>' + AllTrim( Transform( nValCDolar, "@E 999,999,999,999.99") ) + '</B></div>' + CRLF
		cHtml += '								<div>Valor de Estoque<Br>US$ [DOLAR]</div>' + CRLF
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
		cHtml += '								<div class="huge"><B>' + AllTrim( Transform( nValCEuro, "@E 999,999,999,999.99") ) + '</B></div>' + CRLF
		cHtml += '								<div>Valor de Estoque<Br>EUR€ [EURO]</div>' + CRLF
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
		cHtml += '								<div class="huge"><B>' + AllTrim( Transform( nValCIene, "@E 999,999,999,999.99") ) + '</B></div>' + CRLF
		cHtml += '								<div>Valor de Estoque<Br>JP¥ [IENE]</div>' + CRLF
		cHtml += '							</div>' + CRLF
		cHtml += '						</div>' + CRLF
		cHtml += '					</div>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
		cHtml += '		</div>' + CRLF
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H4><i class="fa fa-building fa-1x"></i> Custos da Empresa ' + cEmpAnt + ' Filial ' + cFilAnt + ' | ' + AllTrim( SM0->M0_NOMECOM ) + '</H4>'+CRLF
	cHtml += '    </div>'+CRLF
	
	nValReal   := 0
	nValDolar  := 0
	nValEuro   := 0
	nValIene   := 0
	
	cQuery := "SELECT SUM(B2_VATU1) AS VALOR_REAL, " + CRLF
	cQuery += "       CASE WHEN ISNULL((SELECT TOP 1 M2_MOEDA2 FROM " + RetSqlName("SM2") + " WHERE M2_DATA <= '" + DTOS( dDataBase ) + "' AND M2_MOEDA2 <> 0 AND D_E_L_E_T_ = ' ' ORDER BY M2_DATA DESC),0) = 0 THEN 0 ELSE SUM(B2_VATU1) / ISNULL((SELECT TOP 1 M2_MOEDA2 FROM " + RetSqlName("SM2") + " WHERE M2_DATA <= '" + DTOS( dDataBase ) + "' AND M2_MOEDA2 <> 0 AND D_E_L_E_T_ = ' ' ORDER BY M2_DATA DESC),0) END AS VALOR_DOLAR, " + CRLF
	cQuery += "       CASE WHEN ISNULL((SELECT TOP 1 M2_MOEDA4 FROM " + RetSqlName("SM2") + " WHERE M2_DATA <= '" + DTOS( dDataBase ) + "' AND M2_MOEDA4 <> 0 AND D_E_L_E_T_ = ' ' ORDER BY M2_DATA DESC),0) = 0 THEN 0 ELSE SUM(B2_VATU1) / ISNULL((SELECT TOP 1 M2_MOEDA4 FROM " + RetSqlName("SM2") + " WHERE M2_DATA <= '" + DTOS( dDataBase ) + "' AND M2_MOEDA4 <> 0 AND D_E_L_E_T_ = ' ' ORDER BY M2_DATA DESC),0) END AS VALOR_EURO, " + CRLF
	cQuery += "       CASE WHEN ISNULL((SELECT TOP 1 M2_MOEDA5 FROM " + RetSqlName("SM2") + " WHERE M2_DATA <= '" + DTOS( dDataBase ) + "' AND M2_MOEDA5 <> 0 AND D_E_L_E_T_ = ' ' ORDER BY M2_DATA DESC),0) = 0 THEN 0 ELSE SUM(B2_VATU1) * ISNULL((SELECT TOP 1 M2_MOEDA5 FROM " + RetSqlName("SM2") + " WHERE M2_DATA <= '" + DTOS( dDataBase ) + "' AND M2_MOEDA5 <> 0 AND D_E_L_E_T_ = ' ' ORDER BY M2_DATA DESC),0) END AS VALOR_IENE " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	
	TCQuery cQuery New Alias "VALOR"
	dbSelectArea("VALOR")
	dbGoTop()
	
	If !VALOR->( Eof() )
		nValReal  := VALOR->VALOR_REAL
		nValDolar := VALOR->VALOR_DOLAR
		nValEuro  := VALOR->VALOR_EURO
		nValIene  := VALOR->VALOR_IENE
	EndIf
	
	VALOR->( dbCloseArea() )

&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
		cHtml += '		<div class="row">' + CRLF
		cHtml += '			<div class="col-lg-3 col-md-6">' + CRLF
		cHtml += '				<div class="panel panel-danger">' + CRLF
		cHtml += '					<div class="panel-heading">' + CRLF
		cHtml += '						<div class="row">' + CRLF
		cHtml += '							<div class="col-xs-3">' + CRLF
		cHtml += '								<i class="fa fa-usd fa-5x"></i>' + CRLF //<i class="fa fa-tasks fa-5x"></i>
		cHtml += '							</div>' + CRLF
		cHtml += '							<div class="col-xs-9 text-right">' + CRLF
		cHtml += '								<div class="huge"><B>' + AllTrim( Transform( nValReal, "@E 999,999,999,999.99") ) + '</B></div>' + CRLF
		cHtml += '								<div>Valor de Estoque<Br>R$ [REAL]</div>' + CRLF
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
		cHtml += '								<div class="huge"><B>' + AllTrim( Transform( nValDolar, "@E 999,999,999,999.99") ) + '</B></div>' + CRLF
		cHtml += '								<div>Valor de Estoque<Br>US$ [DOLAR]</div>' + CRLF
		cHtml += '							</div>' + CRLF
		cHtml += '						</div>' + CRLF
		cHtml += '					</div>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
		cHtml += '			<div class="col-lg-3 col-md-6">' + CRLF
		cHtml += '				<div class="panel panel-primary">' + CRLF
		cHtml += '					<div class="panel-heading">' + CRLF
		cHtml += '						<div class="row">' + CRLF
		cHtml += '							<div class="col-xs-3">' + CRLF
		cHtml += '								<i class="fa fa-usd fa-5x"></i>' + CRLF
		cHtml += '							</div>' + CRLF
		cHtml += '							<div class="col-xs-9 text-right">' + CRLF
		cHtml += '								<div class="huge"><B>' + AllTrim( Transform( nValEuro, "@E 999,999,999,999.99") ) + '</B></div>' + CRLF
		cHtml += '								<div>Valor de Estoque<Br>EUR€ [EURO]</div>' + CRLF
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
		cHtml += '								<div class="huge"><B>' + AllTrim( Transform( nValIene, "@E 999,999,999,999.99") ) + '</B></div>' + CRLF
		cHtml += '								<div>Valor de Estoque<Br>JP¥ [IENE]</div>' + CRLF
		cHtml += '							</div>' + CRLF
		cHtml += '						</div>' + CRLF
		cHtml += '					</div>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
		cHtml += '		</div>' + CRLF
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
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

	aAno := {}
	aAdd( aAno, { cAnoAn2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "#8191c9" })
	aAdd( aAno, { cAnoAnt, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "#3e95cd" })
	aAdd( aAno, { cAnoAtu, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "#ff0040" })

	cQuery := "SELECT ANO, SUM(JANEIRO) AS JANEIRO, SUM(FEVEREIRO) AS FEVEREIRO, SUM(MARCO) AS MARCO, SUM(ABRIL) AS ABRIL, " + CRLF
	cQuery += "SUM(MAIO) AS MAIO, SUM(JUNHO) AS JUNHO, SUM(JULHO) AS JULHO, SUM(AGOSTO) AS AGOSTO, " + CRLF
	cQuery += "SUM(SETEMBRO) AS SETEMBRO, SUM(OUTUBRO) AS OUTUBRO, SUM(NOVEMBRO) AS NOVEMBRO, SUM(DEZEMBRO) AS DEZEMBRO " + CRLF
	cQuery += "FROM ( " + CRLF

	cQuery += "SELECT LEFT(B9_DATA, 4) AS ANO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '01' THEN SUM(B9_QINI) ELSE 0 END AS JANEIRO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '02' THEN SUM(B9_QINI) ELSE 0 END AS FEVEREIRO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '03' THEN SUM(B9_QINI) ELSE 0 END AS MARCO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '04' THEN SUM(B9_QINI) ELSE 0 END AS ABRIL, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '05' THEN SUM(B9_QINI) ELSE 0 END AS MAIO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '06' THEN SUM(B9_QINI) ELSE 0 END AS JUNHO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '07' THEN SUM(B9_QINI) ELSE 0 END AS JULHO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '08' THEN SUM(B9_QINI) ELSE 0 END AS AGOSTO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '09' THEN SUM(B9_QINI) ELSE 0 END AS SETEMBRO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '10' THEN SUM(B9_QINI) ELSE 0 END AS OUTUBRO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '11' THEN SUM(B9_QINI) ELSE 0 END AS NOVEMBRO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '12' THEN SUM(B9_QINI) ELSE 0 END AS DEZEMBRO " + CRLF
	cQuery += "FROM " + RetSqlName("SB9") + " AS SB9 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B9_FILIAL = '" + xFilial("SB9") + "' " + CRLF
	cQuery += "AND LEFT(B9_DATA, 4) BETWEEN '" + cAnoAn2 + "' AND '" + cAnoAtu + "' " + CRLF
	cQuery += "AND SB9.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY LEFT(B9_DATA, 4), SUBSTRING( B9_DATA, 5, 2) " + CRLF

	cQuery += ") AS AGRUPAANO " + CRLF
	cQuery += "GROUP BY ANO " + CRLF
	cQuery += "ORDER BY ANO DESC " + CRLF

	TcQuery cQuery NEW ALIAS "TMPSB9"
	TMPSB9->( dbGoTop() )

	Do While !TMPSB9->( Eof() )
		nPosAno := aScan( aAno, {|x| AllTrim( x[01] ) == AllTrim( TMPSB9->ANO ) })

		If nPosAno > 0
			aAno[nPosAno][02] := TMPSB9->JANEIRO
			aAno[nPosAno][03] := TMPSB9->FEVEREIRO
			aAno[nPosAno][04] := TMPSB9->MARCO
			aAno[nPosAno][05] := TMPSB9->ABRIL
			aAno[nPosAno][06] := TMPSB9->MAIO
			aAno[nPosAno][07] := TMPSB9->JUNHO
			aAno[nPosAno][08] := TMPSB9->JULHO
			aAno[nPosAno][09] := TMPSB9->AGOSTO
			aAno[nPosAno][10] := TMPSB9->SETEMBRO
			aAno[nPosAno][11] := TMPSB9->OUTUBRO
			aAno[nPosAno][12] := TMPSB9->NOVEMBRO
			aAno[nPosAno][13] := TMPSB9->DEZEMBRO
		EndIf

		TMPSB9->( dbSkip() )
	EndDo

	TMPSB9->( dbCloseArea() )

	cHtml += '		<div class="row">' + CRLF
	cHtml += '			<div class="col-lg-6 col-md-6">' + CRLF
	cHtml += '				<h5><i class="fa fa-bar-chart-o fa-fw"></i> Saldos de Fechamentos por Ano (<B><font color="' + aAno[1][14] + '">' + cAnoAn2 + '</font></B>,<B><font color="' + aAno[2][14] + '">' + cAnoAnt + '</font></B>,<B><font color="' + aAno[3][14] + '">' + cAnoAtu + '</font></B>)</h5>' + CRLF
	cHtml += '				<hr/>' + CRLF
	cHtml += '				<div class="well well-lg">' + CRLF
	cHtml += '					<canvas class="my-4 w-100" id="myChart" width="900" height="380"></canvas>' + CRLF
	cHtml += '					<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>' + CRLF
	cHtml += '					<script>' + CRLF
	cHtml += '						var ctx = document.getElementById("myChart");' + CRLF
	cHtml += '						var myChart = new Chart(ctx, {' + CRLF
	cHtml += "						type: 'line'," + CRLF
	cHtml += '						data: {' + CRLF
	cHtml += '						labels: ["Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"],' + CRLF
	cHtml += '						datasets: [' + CRLF
	For nAno := 1 To Len( aAno )
		cHtml += '						{ ' + CRLF
		cHtml += '						data: [' + AllTrim( Str(aAno[nAno][02]) ) + ',' + AllTrim( Str(aAno[nAno][03]) ) + ',' + AllTrim( Str(aAno[nAno][04]) ) + ',' + AllTrim( Str(aAno[nAno][05]) ) + ',' + AllTrim( Str(aAno[nAno][06]) ) + ',' + AllTrim( Str(aAno[nAno][07]) ) + ',' + AllTrim( Str(aAno[nAno][08]) ) + ',' + AllTrim( Str(aAno[nAno][09]) ) + ',' + AllTrim( Str(aAno[nAno][10]) ) + ',' + AllTrim( Str(aAno[nAno][11]) ) + ',' + AllTrim( Str(aAno[nAno][12]) ) + ',' + AllTrim( Str(aAno[nAno][13]) ) + '],' + CRLF
		cHtml += '						label: "' + aAno[nAno][01] + '",' + CRLF
		cHtml += '						borderColor: "' + aAno[nAno][14] + '",' + CRLF
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
    
	aAno := {}
	aAdd( aAno, { cAnoAn2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "#8191c9" })
	aAdd( aAno, { cAnoAnt, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "#3e95cd" })
	aAdd( aAno, { cAnoAtu, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "#ff0040" })

	cQuery := "SELECT ANO, SUM(JANEIRO) AS JANEIRO, SUM(FEVEREIRO) AS FEVEREIRO, SUM(MARCO) AS MARCO, SUM(ABRIL) AS ABRIL, " + CRLF
	cQuery += "SUM(MAIO) AS MAIO, SUM(JUNHO) AS JUNHO, SUM(JULHO) AS JULHO, SUM(AGOSTO) AS AGOSTO, " + CRLF
	cQuery += "SUM(SETEMBRO) AS SETEMBRO, SUM(OUTUBRO) AS OUTUBRO, SUM(NOVEMBRO) AS NOVEMBRO, SUM(DEZEMBRO) AS DEZEMBRO " + CRLF
	cQuery += "FROM ( " + CRLF

	cQuery += "SELECT LEFT(B9_DATA, 4) AS ANO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '01' THEN SUM(B9_VINI1) ELSE 0 END AS JANEIRO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '02' THEN SUM(B9_VINI1) ELSE 0 END AS FEVEREIRO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '03' THEN SUM(B9_VINI1) ELSE 0 END AS MARCO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '04' THEN SUM(B9_VINI1) ELSE 0 END AS ABRIL, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '05' THEN SUM(B9_VINI1) ELSE 0 END AS MAIO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '06' THEN SUM(B9_VINI1) ELSE 0 END AS JUNHO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '07' THEN SUM(B9_VINI1) ELSE 0 END AS JULHO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '08' THEN SUM(B9_VINI1) ELSE 0 END AS AGOSTO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '09' THEN SUM(B9_VINI1) ELSE 0 END AS SETEMBRO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '10' THEN SUM(B9_VINI1) ELSE 0 END AS OUTUBRO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '11' THEN SUM(B9_VINI1) ELSE 0 END AS NOVEMBRO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '12' THEN SUM(B9_VINI1) ELSE 0 END AS DEZEMBRO " + CRLF
	cQuery += "FROM " + RetSqlName("SB9") + " AS SB9 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B9_FILIAL = '" + xFilial("SB9") + "' " + CRLF
	cQuery += "AND LEFT(B9_DATA, 4) BETWEEN '" + cAnoAn2 + "' AND '" + cAnoAtu + "' " + CRLF
	cQuery += "AND SB9.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY LEFT(B9_DATA, 4), SUBSTRING( B9_DATA, 5, 2) " + CRLF

	cQuery += ") AS AGRUPAANO " + CRLF
	cQuery += "GROUP BY ANO " + CRLF
	cQuery += "ORDER BY ANO DESC " + CRLF

	TcQuery cQuery NEW ALIAS "TMPSB9"
	TMPSB9->( dbGoTop() )

	Do While !TMPSB9->( Eof() )
		nPosAno := aScan( aAno, {|x| AllTrim( x[01] ) == AllTrim( TMPSB9->ANO ) })

		If nPosAno > 0
			aAno[nPosAno][02] := TMPSB9->JANEIRO
			aAno[nPosAno][03] := TMPSB9->FEVEREIRO
			aAno[nPosAno][04] := TMPSB9->MARCO
			aAno[nPosAno][05] := TMPSB9->ABRIL
			aAno[nPosAno][06] := TMPSB9->MAIO
			aAno[nPosAno][07] := TMPSB9->JUNHO
			aAno[nPosAno][08] := TMPSB9->JULHO
			aAno[nPosAno][09] := TMPSB9->AGOSTO
			aAno[nPosAno][10] := TMPSB9->SETEMBRO
			aAno[nPosAno][11] := TMPSB9->OUTUBRO
			aAno[nPosAno][12] := TMPSB9->NOVEMBRO
			aAno[nPosAno][13] := TMPSB9->DEZEMBRO
		EndIf

		TMPSB9->( dbSkip() )
	EndDo

	TMPSB9->( dbCloseArea() )

	cHtml += '		<div class="row">' + CRLF
	cHtml += '			<div class="col-lg-6 col-md-6">' + CRLF
	cHtml += '				<h5><i class="fa fa-bar-chart-o fa-fw"></i> Valor do Estoque de Fechamentos por Ano (<B><font color="' + aAno[1][14] + '">' + cAnoAn2 + '</font></B>,<B><font color="' + aAno[2][14] + '">' + cAnoAnt + '</font></B>,<B><font color="' + aAno[3][14] + '">' + cAnoAtu + '</font></B>)</h5>' + CRLF
	cHtml += '				<hr/>' + CRLF
	cHtml += '				<div class="well well-lg">' + CRLF
	cHtml += '					<canvas class="my-4 w-100" id="myCharR" width="900" height="380"></canvas>' + CRLF
	cHtml += '					<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>' + CRLF
	cHtml += '					<script>' + CRLF
	cHtml += '						var ctx = document.getElementById("myCharR");' + CRLF
	cHtml += '						var myCharR = new Chart(ctx, {' + CRLF
	cHtml += "						type: 'line'," + CRLF
	cHtml += '						data: {' + CRLF
	cHtml += '						labels: ["Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"],' + CRLF
	cHtml += '						datasets: [' + CRLF
	For nAno := 1 To Len( aAno )
		cHtml += '						{ ' + CRLF
		cHtml += '						data: [' + AllTrim( Str(aAno[nAno][02]) ) + ',' + AllTrim( Str(aAno[nAno][03]) ) + ',' + AllTrim( Str(aAno[nAno][04]) ) + ',' + AllTrim( Str(aAno[nAno][05]) ) + ',' + AllTrim( Str(aAno[nAno][06]) ) + ',' + AllTrim( Str(aAno[nAno][07]) ) + ',' + AllTrim( Str(aAno[nAno][08]) ) + ',' + AllTrim( Str(aAno[nAno][09]) ) + ',' + AllTrim( Str(aAno[nAno][10]) ) + ',' + AllTrim( Str(aAno[nAno][11]) ) + ',' + AllTrim( Str(aAno[nAno][12]) ) + ',' + AllTrim( Str(aAno[nAno][13]) ) + '],' + CRLF
		cHtml += '						label: "' + aAno[nAno][01] + '",' + CRLF
		cHtml += '						borderColor: "' + aAno[nAno][14] + '",' + CRLF
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

	cHtml += '			</div>' + CRLF

	cHtml += '  <Hr/>'+CRLF

	aLoteValid := {}
	aAdd( aLoteValid, { 0, 0, 0, 0, 0, 0, 0})

	cQuery := "SELECT SUM(VENCIDO_365) AS VENCIDO_365, SUM(VENCIDO_180) AS VENCIDO_180, SUM(VENCIDO) AS VENCIDO, SUM(AVENCER_M30) AS AVENCER_M30, SUM(AVENCER_M180) AS AVENCER_M180, SUM(AVENCER_M365) AS AVENCER_M365, SUM(AVENCER_M) AS AVENCER_M " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT CASE WHEN DATEDIFF(DD, GETDATE(), CONVERT(DATETIME,B8_DTVALID)) < -365 THEN COUNT(*) ELSE 0 END AS VENCIDO_365, " + CRLF
	cQuery += "       CASE WHEN DATEDIFF(DD, GETDATE(), CONVERT(DATETIME,B8_DTVALID)) BETWEEN -365 AND -180 THEN COUNT(*) ELSE 0 END AS VENCIDO_180, " + CRLF
	cQuery += "	      CASE WHEN DATEDIFF(DD, GETDATE(), CONVERT(DATETIME,B8_DTVALID)) BETWEEN -179 AND 0  THEN COUNT(*) ELSE 0 END AS VENCIDO, " + CRLF
	cQuery += "	      CASE WHEN DATEDIFF(DD, GETDATE(), CONVERT(DATETIME,B8_DTVALID)) BETWEEN 1 AND 30  THEN COUNT(*) ELSE 0 END AS AVENCER_M30, " + CRLF
	cQuery += "	      CASE WHEN DATEDIFF(DD, GETDATE(), CONVERT(DATETIME,B8_DTVALID)) BETWEEN 31 AND 180  THEN COUNT(*) ELSE 0 END AS AVENCER_M180, " + CRLF
	cQuery += "	      CASE WHEN DATEDIFF(DD, GETDATE(), CONVERT(DATETIME,B8_DTVALID)) BETWEEN 181 AND 365  THEN COUNT(*) ELSE 0 END AS AVENCER_M365, " + CRLF
	cQuery += "	      CASE WHEN DATEDIFF(DD, GETDATE(), CONVERT(DATETIME,B8_DTVALID)) > 365  THEN COUNT(*) ELSE 0 END AS AVENCER_M " + CRLF
	cQuery += "FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B8_FILIAL = '" + xFilial("SB8") + "' " + CRLF
	cQuery += "AND B8_SALDO > 0 " + CRLF
	cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY B8_DTVALID " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF

	TCQuery cQuery New Alias "TMPVEN"
	dbSelectArea("TMPVEN")
	dbGoTop()

	Do While !TMPVEN->( Eof() )
		aLoteValid[01][01] += TMPVEN->VENCIDO_365
		aLoteValid[01][02] += TMPVEN->VENCIDO_180
		aLoteValid[01][03] += TMPVEN->VENCIDO
		aLoteValid[01][04] += TMPVEN->AVENCER_M30
		aLoteValid[01][05] += TMPVEN->AVENCER_M180
		aLoteValid[01][06] += TMPVEN->AVENCER_M365
		aLoteValid[01][07] += TMPVEN->AVENCER_M

		TMPVEN->( dbSkip() )
	EndDo
	
	TMPVEN->( dbCloseArea() )

	cHtml += '	<div class="row">' + CRLF
	cHtml += '		<div class="col-lg-6 col-md-6">' + CRLF
	cHtml += '			<h5><i class="fa fa-bar-chart-o fa-fw"></i> Quantidade de Lotes Vencidos e À Vencer</h5>' + CRLF
	cHtml += '			<hr/>' + CRLF
	cHtml += '			<div class="well well-lg">' + CRLF
	cHtml += '				<canvas id="doughnutChartCol"></canvas>' + CRLF
	cHtml += '				<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>' + CRLF
	cHtml += '				<script>' + CRLF
	cHtml += "					var ctxD = document.getElementById(" + '"doughnutChartCol"' + ").getContext('2d');" + CRLF
	cHtml += '					var myLineChart = new Chart(ctxD, {' + CRLF
	cHtml += "					type: 'doughnut'," + CRLF
	cHtml += '					data: {' + CRLF
	cHtml += '					labels: ["Vencido à mais de 365 dias", "Vencidos de 180 à 365 dias", "Vencidos até 365 dias", "À Vencer até 30 dias", "À Vencer de 31 à 180 dias", "À Vencer de 180 à 365 dias", "À Vencer acima de 365 dias"],' + CRLF
	cHtml += '					datasets: [' + CRLF
	cHtml += '					{' + CRLF
	cHtml += '					data: [' + AllTrim( Str(aLoteValid[1][01]) ) + ', ' + AllTrim( Str(aLoteValid[1][02]) ) + ', ' + AllTrim( Str(aLoteValid[1][03]) ) + ', ' + AllTrim( Str(aLoteValid[1][04]) ) + ', ' + AllTrim( Str(aLoteValid[1][05]) ) + ', ' + AllTrim( Str(aLoteValid[1][06]) ) + ', ' + AllTrim( Str(aLoteValid[1][07]) ) + '],' + CRLF
	cHtml += '					backgroundColor: ["#d7d7e0", "#7b79ce", "#5a57e5", "#2825ba", "#3e95cd", "#080654", "#050423"],' + CRLF
	cHtml += '					hoverBackgroundColor: ["#d7d7e0", "#7b79ce", "#5a57e5", "#2825ba", "#3e95cd", "#080654", "#050423"]' + CRLF
	cHtml += '					}' + CRLF
	cHtml += '					]' + CRLF
	cHtml += '					},' + CRLF
	cHtml += '					options: {' + CRLF
	cHtml += '					responsive: true' + CRLF
	cHtml += '					}' + CRLF
	cHtml += '					});' + CRLF
	cHtml += '				</script>' + CRLF
	cHtml += '			</div>' + CRLF
	cHtml += '		</div>' + CRLF
/***********************************************************************************************************************************************/
	aLoteValor := {}
	aAdd( aLoteValor, { 0, 0, 0, 0, 0, 0, 0})

	cQuery := "SELECT SUM(VENCIDO_365) AS VENCIDO_365, SUM(VENCIDO_180) AS VENCIDO_180, SUM(VENCIDO) AS VENCIDO, SUM(AVENCER_M30) AS AVENCER_M30, SUM(AVENCER_M180) AS AVENCER_M180, SUM(AVENCER_M365) AS AVENCER_M365, SUM(AVENCER_M) AS AVENCER_M " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT CASE WHEN DATEDIFF(DD, GETDATE(), CONVERT(DATETIME,B8_DTVALID)) < -365 THEN SUM(B8_SALDO * B2_CM1) ELSE 0 END AS VENCIDO_365, " + CRLF
	cQuery += "       CASE WHEN DATEDIFF(DD, GETDATE(), CONVERT(DATETIME,B8_DTVALID)) BETWEEN -365 AND -180 THEN SUM(B8_SALDO * B2_CM1) ELSE 0 END AS VENCIDO_180, " + CRLF
	cQuery += "	      CASE WHEN DATEDIFF(DD, GETDATE(), CONVERT(DATETIME,B8_DTVALID)) BETWEEN -179 AND 0  THEN SUM(B8_SALDO * B2_CM1) ELSE 0 END AS VENCIDO, " + CRLF
	cQuery += "	      CASE WHEN DATEDIFF(DD, GETDATE(), CONVERT(DATETIME,B8_DTVALID)) BETWEEN 1 AND 30  THEN SUM(B8_SALDO * B2_CM1) ELSE 0 END AS AVENCER_M30, " + CRLF
	cQuery += "	      CASE WHEN DATEDIFF(DD, GETDATE(), CONVERT(DATETIME,B8_DTVALID)) BETWEEN 31 AND 180  THEN SUM(B8_SALDO * B2_CM1) ELSE 0 END AS AVENCER_M180, " + CRLF
	cQuery += "	      CASE WHEN DATEDIFF(DD, GETDATE(), CONVERT(DATETIME,B8_DTVALID)) BETWEEN 181 AND 365  THEN SUM(B8_SALDO * B2_CM1) ELSE 0 END AS AVENCER_M365, " + CRLF
	cQuery += "	      CASE WHEN DATEDIFF(DD, GETDATE(), CONVERT(DATETIME,B8_DTVALID)) > 365  THEN SUM(B8_SALDO * B2_CM1) ELSE 0 END AS AVENCER_M " + CRLF
	cQuery += "FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) ON B2_FILIAL = B8_FILIAL " + CRLF
	cQuery += "  AND B2_COD = B8_PRODUTO " + CRLF
	cQuery += "  AND B2_LOCAL = B8_LOCAL " + CRLF
	cQuery += "  AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B8_FILIAL = '" + xFilial("SB8") + "' " + CRLF
	cQuery += "AND B8_SALDO > 0 " + CRLF
	cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY B8_DTVALID " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF

	TCQuery cQuery New Alias "TMPVEN"
	dbSelectArea("TMPVEN")
	dbGoTop()

	Do While !TMPVEN->( Eof() )
		aLoteValor[01][01] += TMPVEN->VENCIDO_365
		aLoteValor[01][02] += TMPVEN->VENCIDO_180
		aLoteValor[01][03] += TMPVEN->VENCIDO
		aLoteValor[01][04] += TMPVEN->AVENCER_M30
		aLoteValor[01][05] += TMPVEN->AVENCER_M180
		aLoteValor[01][06] += TMPVEN->AVENCER_M365
		aLoteValor[01][07] += TMPVEN->AVENCER_M

		TMPVEN->( dbSkip() )
	EndDo
	
	TMPVEN->( dbCloseArea() )

	cHtml += '	<div class="row">' + CRLF
	cHtml += '		<div class="col-lg-6 col-md-6">' + CRLF
	cHtml += '			<h5><i class="fa fa-bar-chart-o fa-fw"></i> Valores de Lotes Vencidos e À Vencer</h5>' + CRLF
	cHtml += '			<hr/>' + CRLF
	cHtml += '			<div class="well well-lg">' + CRLF
	cHtml += '				<canvas id="pieChart"></canvas>' + CRLF
	cHtml += '				<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>' + CRLF
	cHtml += '				<script>' + CRLF
	cHtml += "					var ctxD = document.getElementById(" + '"pieChart"' + ").getContext('2d');" + CRLF
	cHtml += '					var myLineChart = new Chart(ctxD, {' + CRLF
	cHtml += "					type: 'pie'," + CRLF
	cHtml += '					data: {' + CRLF
	cHtml += '					labels: ["Vencido à mais de 365 dias", "Vencidos de 180 à 365 dias", "Vencidos até 365 dias", "À Vencer até 30 dias", "À Vencer de 31 à 180 dias", "À Vencer de 180 à 365 dias", "À Vencer acima de 365 dias"],' + CRLF
	cHtml += '					datasets: [' + CRLF
	cHtml += '					{' + CRLF
	cHtml += '					data: [' + AllTrim( Str(aLoteValor[1][01]) ) + ', ' + AllTrim( Str(aLoteValor[1][02]) ) + ', ' + AllTrim( Str(aLoteValor[1][03]) ) + ', ' + AllTrim( Str(aLoteValor[1][04]) ) + ', ' + AllTrim( Str(aLoteValor[1][05]) ) + ', ' + AllTrim( Str(aLoteValor[1][06]) ) + ', ' + AllTrim( Str(aLoteValor[1][07]) ) + '],' + CRLF
	cHtml += '					backgroundColor: ["#d7d7e0", "#7b79ce", "#5a57e5", "#2825ba", "#3e95cd", "#080654", "#050423"],' + CRLF
	cHtml += '					hoverBackgroundColor: ["#d7d7e0", "#7b79ce", "#5a57e5", "#2825ba", "#3e95cd", "#080654", "#050423"]' + CRLF
	cHtml += '					}' + CRLF
	cHtml += '					]' + CRLF
	cHtml += '					},' + CRLF
	cHtml += '					options: {' + CRLF
	cHtml += '					responsive: true' + CRLF
	cHtml += '					}' + CRLF
	cHtml += '					});' + CRLF
	cHtml += '				</script>' + CRLF
	cHtml += '			</div>' + CRLF
	cHtml += '		</div>' + CRLF

		cHtml += ' </div>' + CRLF // tirar...
/***********************************************************************************************************************************************/

	cHtml += '		<Hr>' + CRLF

/********************************************************************************************************************************/
/********************************************************************************************************************************/

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-filter fa-1x"></i> Aplique o filtro abaixo para análise de produto</H3>'+CRLF
	cHtml += '    </div>'+CRLF

	//cHtml += '	<p></p>
	//cHtml += '	<div style="overflow-x:auto; width=100%; max-height:800px; overflow-y:auto">'

	cHtml += '	Marque uma opção para o Tipo do Produto'
	cHtml += '	<hr/>'

		cHtml += '    <div class="checkbox col-md-12">'+CRLF
		cHtml += '    <div class="checkbox col-md-12">'+CRLF
  		cHtml += '		<label class="form-check-label" for="opttipo"><input class="form-check-input position-static" type="radio" name="opttipo" value=1  required>Produto Acabado</label>' //"form-check-input"
		cHtml += '    </div>'+CRLF
		cHtml += '    <div class="checkbox col-md-12">'+CRLF
		cHtml += '		<label class="form-check-label" for="opttipo"><input class="form-check-input position-static" type="radio" name="opttipo" value=2          >Produto Intermediário</label>'
		cHtml += '    </div>'+CRLF
		cHtml += '    <div class="checkbox col-md-12">'+CRLF
		cHtml += '		<label class="form-check-label" for="opttipo"><input class="form-check-input position-static" type="radio" name="opttipo" value=3          >Matéria Prima</label>'
		cHtml += '    </div>'+CRLF
		cHtml += '    <div class="checkbox col-md-12">'+CRLF
		cHtml += '		<label class="form-check-label" for="opttipo"><input class="form-check-input position-static" type="radio" name="opttipo" value=4          >Embalagem</label>'
		cHtml += '    </div>'+CRLF
		cHtml += '    <div class="checkbox col-md-12">'+CRLF
		cHtml += '		<label class="form-check-label" for="opttipo"><input class="form-check-input position-static" type="radio" name="opttipo" value=5          >Mercadoria</label>'
		cHtml += '    </div>'+CRLF
		cHtml += '    <div class="checkbox col-md-12">'+CRLF
		cHtml += '		<label class="form-check-label" for="opttipo"><input class="form-check-input position-static" type="radio" name="opttipo" value=6          >Material de Consumo</label>'
		cHtml += '    </div>'+CRLF
		cHtml += '    <div class="checkbox col-md-12">'+CRLF
		cHtml += '		<label class="form-check-label" for="opttipo"><input class="form-check-input position-static" type="radio" name="opttipo" value=7          >Material Tipo KIT</label>'
		cHtml += '    </div>'+CRLF
			cHtml += '    </div>'+CRLF

	cHtml += '	<hr/>'
	cHtml += '	Selecione um Grupo de Produto [Opcional]'
	cHtml += '	<hr/>'

		cHtml += '    <div class="form-group col-md-4">'+CRLF
		cHtml += '        <label for="codsbm">Grupo de Produtos:</label>'+CRLF
		cHtml += '      <div class="input-group">'+CRLF
		cHtml += '        <input type="text" class="form-control" id="codsbm" name="codsbm" value="" readonly required>'+CRLF
		cHtml += '        <span class="input-group-btn">'+CRLF
		cHtml += '          <button class="btn btn-secondary" type="button" data-toggle="modal" id="pesqgrupo">'+CRLF
		cHtml += '            <i class="glyphicon glyphicon-search"></i>'+CRLF
		cHtml += '          </button>'+CRLF
		cHtml += '        </span>'+CRLF
		cHtml += '      </div>'+CRLF
		cHtml += '    </div>'+CRLF

		cHtml += '    <div class="form-group col-md-8">'+CRLF
		cHtml += '      <label for="descgrupo">Descrição Grupo:</label>'+CRLF
		cHtml += '      <input type="text" class="form-control" id="descgrupo" name="descgrupo" value="" readonly>'+CRLF
		cHtml += '    </div>'+CRLF

		cHtml += '	  <div class="form-group col-md-12">'+CRLF
		cHtml += '    	<button type="submit" class="btn btn-default">Confirmar</button>'+CRLF
		cHtml += '	  </div>'+CRLF

	cHtml += '	<hr/>'

		cFilGrupo := "BM_FILIAL = '" + xFilial("SBM") + "' AND EXISTS (SELECT * FROM " + RetSqlName("SB1") + " WHERE B1_FILIAL = '" + xFilial("SB1") + "' AND B1_GRUPO = BM_GRUPO AND B1_MSBLQL <> '1' AND B1_TIPO IN ('PA','PI','MP','EM','ME','MC') AND EXISTS (SELECT * FROM " + RetSqlName("SB2") + " WITH (NOLOCK) WHERE B2_FILIAL = '" + xFilial("SB2") + "' AND B2_COD = B1_COD AND B2_LOCAL <> '' AND D_E_L_E_T_ = ' ') AND D_E_L_E_T_ = ' ') "+CRLF

		cHtml += U_BePModF3(	"modsbm"									/* Id Modal */,;
								{"codsbm","descgrupo"}						/* Indique Id dos campos de retorno */,;
								"pesqgrupo"			 						/* Indique o Id do button da pesquisa */,;
								"SBM"				 						/* Alias da Pesquisa */,;
								{"BM_GRUPO","BM_DESC"}						/* Array com os campos que irão aparecer na tabela */,;
								{"BM_GRUPO","BM_DESC"}						/* Campos de Retorno, deve estar na mesma sequência do  Id de Campos */,;
								cFilGrupo		 							/* Expressão SQL para filtro */) + CRLF

	cHtml += '	</div>'
	cHtml += '</div>'
	
Else	
	cMsgHdr		:= "BEP0206 - Sessão não Iniciada"
	cMsgBody	:= "A sessão não foi iniciada, realize o Login!"

	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 

EndIf

cHtml += Execblock("BePFooter",.F.,.F.)

WEB EXTENDED END
	
Return (EncodeUTF8(cHtml))
