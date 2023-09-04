#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

User Function BeP0205A()

Local cQuery	:= ""
Local cAlias	:= GetNextAlias()
Local cMsgHdr	:= ""
Local cMsgBody	:= ""
Local cRetfun	:= "u_BePLogin.apw"
Local lSession 	:= Execblock("BePVSess",.F.,.F.) // Valida Sessão
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
Local nSts      := 0

Private cHtml 	:= ""    

WEB EXTENDED INIT cHtml                               

cHtml += Execblock("BePHeader",.F.,.F.)

If lSession

	cHtml += Execblock("BePMenus",.F.,.F.)

	dbSelectArea("SM0")
	dbSeek(cEmpAnt+Alltrim(HttpGet->filexc),.T.)
	cFilAnt := SM0->M0_CODFIL

	dbSelectArea("SA2")
	dbSetOrder(1)
	SA2->( dbSeek(xFilial("SA2")+Padr(HttpGet->codfor,TamSX3("A2_COD")[1])+Padr(HttpGet->lojfor,TamSX3("A2_LOJA")[1])) )

	cHtml += '<div class="main col-md-12" style="margin-top: 50px">'
	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '  <h2><i class="fa-id-card-o"></i> Análise do Fornecedor Consolidado</h2>'+CRLF
	cHtml += '  <hr/>'+CRLF
	cHtml += '	<p></p>
	cHtml += '    </div>'+CRLF
	
	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Código:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="numpc" name="numpc" value="'+SA2->A2_COD+'" readonly>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="pwd">Loja:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="dtemis" name="dtemis" value="'+SA2->A2_LOJA+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Razão Social:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+SA2->A2_NOME+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	//Linha 2	
	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="pwd">Fantasia:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codloja" name="codloja" value="'+SA2->A2_NREDUZ+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="pwd">Município:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="nomforn" name="nomforn" value="'+SA2->A2_MUN+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="pwd">Estado:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="nomforn" name="nomforn" value="'+SA2->A2_EST+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	//Linha 3
	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="pwd">Pessoa:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codloja" name="codloja" value="'+IIf(AllTrim(SA2->A2_TIPO) == "J", "Jurídica",IIf(AllTrim(SA2->A2_TIPO) == "F", "Física", "Estrangeira"))+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="pwd">CNPJ/CPF:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="nomforn" name="nomforn" value="'+SA2->A2_CGC+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="pwd">Contato:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="nomforn" name="nomforn" value="'+SA2->A2_CONTATO+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cQuery := "SELECT " + CRLF
	cQuery += "(" + CRLF
	cQuery += "SELECT CASE WHEN MIN(PRIMEIRA) = '99999999' THEN '' ELSE MIN(PRIMEIRA) END FROM (" + CRLF
	cQuery += "SELECT ISNULL(MIN(F1_EMISSAO), '99999999') AS PRIMEIRA FROM " + RetSqlName("SF1") + " WITH (NOLOCK) WHERE F1_FILIAL = '" + xFilial("SF1") + "' AND F1_TIPO = 'N' AND F1_FORNECE = A2_COD AND F1_LOJA = A2_LOJA AND D_E_L_E_T_ = ' '" + CRLF
	cQuery += ") AS AGRUP1 " + CRLF
	cQuery += ") AS PRI_COMPRA, " + CRLF
	cQuery += "(" + CRLF
	cQuery += "SELECT CASE WHEN MAX(ULTIMA) = '00000000' THEN '' ELSE MAX(ULTIMA) END FROM (" + CRLF
	cQuery += "SELECT ISNULL(MAX(F1_EMISSAO), '00000000') AS ULTIMA FROM " + RetSqlName("SF1") + " WITH (NOLOCK) WHERE F1_FILIAL = '" + xFilial("SF1") + "' AND F1_TIPO = 'N' AND F1_FORNECE = A2_COD AND F1_LOJA = A2_LOJA AND D_E_L_E_T_ = ' '" + CRLF
	cQuery += ") AS AGRUP1 " + CRLF
	cQuery += ") AS ULT_COMPRA, " + CRLF
	cQuery += "(" + CRLF
	cQuery += "SELECT SUM(CONTA) FROM (" + CRLF
	cQuery += "SELECT COUNT(*) AS CONTA FROM " + RetSqlName("SF1") + " WITH (NOLOCK) WHERE F1_FILIAL = '" + xFilial("SF1") + "' AND F1_TIPO = 'N' AND F1_FORNECE = A2_COD AND F1_LOJA = A2_LOJA AND D_E_L_E_T_ = ' '" + CRLF
	cQuery += ") AS AGRUP1 " + CRLF
	cQuery += ") AS NRO_COMPRA, " + CRLF
	cQuery += "(" + CRLF
	cQuery += "SELECT AVG(CONTA) FROM (" + CRLF
	cQuery += "SELECT DATEDIFF(DD,CONVERT(DATETIME,C7_DATPRF),CONVERT(DATETIME,D1_DTDIGIT)) AS CONTA FROM " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) INNER JOIN " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) ON C7_FILIAL = D1_FILIAL AND C7_NUM = D1_PEDIDO AND C7_ITEM = D1_ITEMPC AND C7_DATPRF < D1_DTDIGIT AND SC7.D_E_L_E_T_ = ' ' INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' ' WHERE D1_FILIAL = '" + xFilial("SD1") + "' AND D1_TIPO = 'N' AND D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += ") AS AGRUP1 " + CRLF
	cQuery += ") AS MEDIA_ATRASO, " + CRLF
	cQuery += "(" + CRLF
	cQuery += "SELECT MAX(CONTA) FROM (" + CRLF
	cQuery += "SELECT DATEDIFF(DD,CONVERT(DATETIME,C7_DATPRF),CONVERT(DATETIME,D1_DTDIGIT)) AS CONTA FROM " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) INNER JOIN " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) ON C7_FILIAL = D1_FILIAL AND C7_NUM = D1_PEDIDO AND C7_ITEM = D1_ITEMPC AND C7_DATPRF < D1_DTDIGIT AND SC7.D_E_L_E_T_ = ' ' INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' ' WHERE D1_FILIAL = '" + xFilial("SD1") + "' AND D1_TIPO = 'N' AND D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += ") AS AGRUP1 " + CRLF
	cQuery += ") AS MAIOR_ATRASO, " + CRLF
	cQuery += "(" + CRLF
	cQuery += "SELECT SUM(CONTA) FROM (" + CRLF
	cQuery += "SELECT COUNT(*) AS CONTA FROM " + RetSqlName("SF1") + " WITH (NOLOCK) WHERE F1_FILIAL = '" + xFilial("SF1") + "' AND F1_TIPO = 'N' AND F1_FORNECE = A2_COD AND F1_LOJA = A2_LOJA AND D_E_L_E_T_ = '*'" + CRLF
	cQuery += ") AS AGRUP1 " + CRLF
	cQuery += ") AS NRO_EXCLUIDAS, " + CRLF
	cQuery += "(" + CRLF
	cQuery += "SELECT MAX(MAIOR) FROM (" + CRLF
	cQuery += "SELECT ISNULL(MAX(F1_VALBRUT), 0) AS MAIOR FROM " + RetSqlName("SF1") + " WITH (NOLOCK) WHERE F1_FILIAL = '" + xFilial("SF1") + "' AND F1_TIPO = 'N' AND F1_DUPL <> '' AND F1_FORNECE = A2_COD AND F1_LOJA = A2_LOJA AND D_E_L_E_T_ = ' '" + CRLF
	cQuery += ") AS AGRUP1 " + CRLF
	cQuery += ") AS MAIOR_COMPRA, " + CRLF
	cQuery += "(" + CRLF
	cQuery += "SELECT ISNULL(SUM(TOTAL), 0) FROM (" + CRLF
	cQuery += "SELECT SUM(E2_VALOR) AS TOTAL FROM " + RetSqlName("SE2") + " WITH (NOLOCK) WHERE E2_FILIAL = '" + xFilial("SE2") + "' AND E2_TIPO NOT IN ('PA','AB-','NCF','NDF') AND E2_FORNECE = A2_COD AND E2_LOJA = A2_LOJA AND D_E_L_E_T_ = ' ' " + CRLF
	cQuery += ") AS AGRUP1 " + CRLF
	cQuery += ") AS SOMA_TITULOS, " + CRLF
	cQuery += "(" + CRLF
	cQuery += "SELECT ISNULL(SUM(TOTAL), 0) FROM (" + CRLF
	cQuery += "SELECT SUM(E2_SALDO) AS TOTAL FROM " + RetSqlName("SE2") + " WITH (NOLOCK) WHERE E2_FILIAL = '" + xFilial("SE2") + "' AND E2_TIPO = 'PA' AND E2_FORNECE = A2_COD AND E2_LOJA = A2_LOJA AND D_E_L_E_T_ = ' ' " + CRLF
	cQuery += ") AS AGRUP1 " + CRLF
	cQuery += ") AS SALDO_PAGAMENTOS_ANTECIPADOS, " + CRLF
	cQuery += "(" + CRLF
	cQuery += "SELECT ISNULL(SUM(TOTAL), 0) FROM (" + CRLF
	cQuery += "SELECT SUM(E2_SALDO) AS TOTAL FROM " + RetSqlName("SE2") + " WITH (NOLOCK) WHERE E2_FILIAL = '" + xFilial("SE2") + "' AND E2_TIPO NOT IN ('PA','AB-','NCF','NDF') AND E2_FORNECE = A2_COD AND E2_LOJA = A2_LOJA AND D_E_L_E_T_ = ' ' " + CRLF
	cQuery += ") AS AGRUP1 " + CRLF
	cQuery += ") AS SALDO_TITULOS, " + CRLF
	cQuery += "(" + CRLF
	cQuery += "SELECT ISNULL(SUM(TOTAL), 0) FROM (" + CRLF
	cQuery += "SELECT SUM(E2_SALDO) AS TOTAL FROM " + RetSqlName("SE2") + " WITH (NOLOCK) WHERE E2_FILIAL = '" + xFilial("SE2") + "' AND E2_TIPO NOT IN ('PA','AB-','NCF','NDF') AND E2_FORNECE = A2_COD AND E2_LOJA = A2_LOJA AND E2_VENCREA < CONVERT(VARCHAR(8),GETDATE(), 112) AND D_E_L_E_T_ = ' ' " + CRLF
	cQuery += ") AS AGRUP1 " + CRLF
	cQuery += ") AS SALDO_VENCIDOS " + CRLF
	cQuery += "FROM " + RetSqlName("SA2") + " AS SA2 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE A2_FILIAL = '" + xFilial("SA2") + "' " + CRLF
	cQuery += "AND A2_COD = '" + SA2->A2_COD + "' " + CRLF
	cQuery += "AND A2_LOJA = '" + SA2->A2_LOJA + "' " + CRLF
	cQuery += "AND SA2.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPSA2"
	dbSelectArea("TMPSA2")
	TMPSA2->( dbGoTop() )

	If !TMPSA2->( Eof() )
		//Linha 3
		cHtml += '    <div class="form-group col-md-4">'+CRLF
		cHtml += '      <label for="pwd">Primeira Compra:</label>'+CRLF
		cHtml += '      <input type="text" class="form-control" id="codloja" name="codloja" value="'+DTOC(STOD(TMPSA2->PRI_COMPRA))+'" disabled>'+CRLF
		cHtml += '    </div>'+CRLF
	
		cHtml += '    <div class="form-group col-md-4">'+CRLF
		cHtml += '      <label for="pwd">Última Compra:</label>'+CRLF
		cHtml += '      <input type="text" class="form-control" id="nomforn" name="nomforn" value="'+DTOC(STOD(TMPSA2->ULT_COMPRA))+'" disabled>'+CRLF
		cHtml += '    </div>'+CRLF
	
		cHtml += '    <div class="form-group col-md-4">'+CRLF
		cHtml += '      <label for="pwd">Quantidade NF:</label>'+CRLF
		cHtml += '      <input type="text" class="form-control" id="nomforn" name="nomforn" value="'+AllTrim(Transform(TMPSA2->NRO_COMPRA,"@E 999,999,999"))+'" disabled>'+CRLF
		cHtml += '    </div>'+CRLF

		cHtml += '    <div class="form-group col-md-4">'+CRLF
		cHtml += '      <label for="pwd">NF Excluídas:</label>'+CRLF
		cHtml += '      <input type="text" class="form-control" id="nomforn" name="nomforn" value="'+AllTrim(Transform(TMPSA2->NRO_EXCLUIDAS,"@E 999,999,999"))+'" disabled>'+CRLF
		cHtml += '    </div>'+CRLF

		cHtml += '    <div class="form-group col-md-4">'+CRLF
		cHtml += '      <label for="pwd">Média Atrasos (Dias):</label>'+CRLF
		cHtml += '      <input type="text" class="form-control" id="nomforn" name="nomforn" value="'+AllTrim(Transform(TMPSA2->MEDIA_ATRASO,"@E 999,999,999"))+'" disabled>'+CRLF
		cHtml += '    </div>'+CRLF

		cHtml += '    <div class="form-group col-md-4">'+CRLF
		cHtml += '      <label for="pwd">Maior Atraso (Dias):</label>'+CRLF
		cHtml += '      <input type="text" class="form-control" id="nomforn" name="nomforn" value="'+AllTrim(Transform(TMPSA2->MAIOR_ATRASO,"@E 999,999,999"))+'" disabled>'+CRLF
		cHtml += '    </div>'+CRLF

		cHtml += '    <div class="form-group col-md-4">'+CRLF
		cHtml += '      <label for="pwd">Valor Maior Compra:</label>'+CRLF
		cHtml += '      <input type="text" class="form-control" id="nomforn" name="nomforn" value="'+AllTrim(Transform(TMPSA2->MAIOR_COMPRA,"@E 999,999,999.99"))+'" disabled>'+CRLF
		cHtml += '    </div>'+CRLF

		cHtml += '    <div class="form-group col-md-4">'+CRLF
		cHtml += '      <label for="pwd">Valor Títulos Acumulados:</label>'+CRLF
		cHtml += '      <input type="text" class="form-control" id="nomforn" name="nomforn" value="'+AllTrim(Transform(TMPSA2->SOMA_TITULOS,"@E 999,999,999.99"))+'" disabled>'+CRLF
		cHtml += '    </div>'+CRLF

		cHtml += '    <div class="form-group col-md-4">'+CRLF
		cHtml += '      <label for="pwd">Saldo Pagamentos Antecipados:</label>'+CRLF
		cHtml += '      <input type="text" class="form-control" id="nomforn" name="nomforn" value="'+AllTrim(Transform(TMPSA2->SALDO_PAGAMENTOS_ANTECIPADOS,"@E 999,999,999.99"))+'" disabled>'+CRLF
		cHtml += '    </div>'+CRLF

		cHtml += '    <div class="form-group col-md-4">'+CRLF
		cHtml += '      <label for="pwd">Saldo Títulos Pendentes:</label>'+CRLF
		cHtml += '      <input type="text" class="form-control" id="nomforn" name="nomforn" value="'+AllTrim(Transform(TMPSA2->SALDO_TITULOS,"@E 999,999,999.99"))+'" disabled>'+CRLF
		cHtml += '    </div>'+CRLF

		cHtml += '    <div class="form-group col-md-4">'+CRLF
		cHtml += '      <label for="pwd">Saldo Títulos Vencidos:</label>'+CRLF
		cHtml += '      <input type="text" class="form-control" id="nomforn" name="nomforn" value="'+AllTrim(Transform(TMPSA2->SALDO_VENCIDOS,"@E 999,999,999.99"))+'" disabled>'+CRLF
		cHtml += '    </div>'+CRLF
	EndIf

	TMPSA2->( dbCloseArea() )

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-building fa-1x"></i> Outras Filiais, Lojas ou Coligadas do Fornecedor</H3>'+CRLF
	cHtml += '    </div>'+CRLF

	//Table
	cHtml += '	<div  class="col-md-12" style="overflow-x:auto; width=100%; overflow-y:auto;">'+CRLF

	cHtml += '    <div class="form-group" style="max-height:300px; ">'+CRLF
	cHtml += '    	<table id="table" class="table table-bordered table-striped table-condensed col-md-12">'+CRLF
	cHtml += '    		<thead>'+CRLF
	cHtml += '      		<tr>'+CRLF
	cHtml += '		  			<th>Código</th>'+CRLF
	cHtml += '        			<th>Loja</th>'+CRLF
	cHtml += '        			<th>Razão Social</th>'+CRLF
	cHtml += '        			<th>Fantasia</th>'+CRLF
	cHtml += '        			<th>Município</th>'+CRLF
	cHtml += '        			<th>Estado</th>'+CRLF
	cHtml += '        			<th>Tipo</th>'+CRLF
	cHtml += '        			<th>CNPJ/CPF</th>'+CRLF
	cHtml += '      		</tr>'+CRLF
	cHtml += '    		</thead>'+CRLF
	cHtml += '			<tbody>'+CRLF
	
	cQuery := "SELECT A2_COD, A2_LOJA, A2_NOME, A2_NREDUZ, A2_MUN, A2_EST, CASE WHEN A2_TIPO = 'J' THEN 'Jurídica' WHEN A2_TIPO = 'F' THEN 'Física' WHEN A2_TIPO = 'X' THEN 'Estrangeiro' ELSE 'Não Definido' END AS TIPO, A2_CGC " + CRLF
	cQuery += "FROM " + RetSqlName("SA2") + " AS SA2 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE A2_FILIAL = '  ' " + CRLF
	cQuery += "AND (" + CRLF
	//cQuery += "EXISTS (SELECT A2_FILIAL FROM SA2000 WITH (NOLOCK) WHERE A2_FILIAL = '  ' AND A2_COD = '000178' AND A2_LOJA = '01' AND A2_COD = SA2.A2_COD AND A2_LOJA <> SA2.A2_LOJA AND D_E_L_E_T_ = ' ') " + CRLF
	//cQuery += "OR " + CRLF
	//cQuery += "EXISTS (SELECT A2_FILIAL FROM SA2000 WITH (NOLOCK) WHERE A2_FILIAL = '  ' AND A2_COD = '000178' AND A2_LOJA = '01' AND A2_TIPO = 'J' AND LEFT(A2_CGC, 8) = LEFT(SA2.A2_CGC, 8) AND A2_CGC <> SA2.A2_CGC AND D_E_L_E_T_ = ' ') " + CRLF
	//cQuery += "OR " + CRLF
	//cQuery += "EXISTS (SELECT A2_FILIAL FROM SA2000 WITH (NOLOCK) WHERE A2_FILIAL = '  ' AND A2_COD = '000178' AND A2_LOJA = '01' AND (A2_NOME = SA2.A2_NOME OR A2_NREDUZ = SA2.A2_NREDUZ) AND A2_COD + A2_LOJA <> SA2.A2_COD + SA2.A2_LOJA AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "EXISTS (SELECT A2_FILIAL FROM " + RetSqlName("SA2") + " WITH (NOLOCK) WHERE A2_FILIAL = '" + xFilial("SA2") + "' AND A2_COD = '" + SA2->A2_COD + "' AND A2_LOJA = '" + SA2->A2_LOJA + "' AND A2_COD = SA2.A2_COD AND A2_LOJA <> SA2.A2_LOJA AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "OR " + CRLF
	cQuery += "EXISTS (SELECT A2_FILIAL FROM " + RetSqlName("SA2") + " WITH (NOLOCK) WHERE A2_FILIAL = '" + xFilial("SA2") + "' AND A2_COD = '" + SA2->A2_COD + "' AND A2_LOJA = '" + SA2->A2_LOJA + "' AND A2_TIPO = 'J' AND LEFT(A2_CGC, 8) = LEFT(SA2.A2_CGC, 8) AND A2_CGC <> SA2.A2_CGC AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "OR " + CRLF
	cQuery += "EXISTS (SELECT A2_FILIAL FROM " + RetSqlName("SA2") + " WITH (NOLOCK) WHERE A2_FILIAL = '" + xFilial("SA2") + "' AND A2_COD = '" + SA2->A2_COD + "' AND A2_LOJA = '" + SA2->A2_LOJA + "' AND (A2_NOME = SA2.A2_NOME OR A2_NREDUZ = SA2.A2_NREDUZ) AND A2_COD + A2_LOJA <> SA2.A2_COD + SA2.A2_LOJA AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += ")" + CRLF
	cQuery += "AND SA2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY A2_COD, A2_LOJA " + CRLF

	TCQuery cQuery New Alias "TMPSA2"
	dbSelectArea("TMPSA2")
	TMPSA2->( dbGoTop() )

	Do While !TMPSA2->( Eof() )
		cHtml += '				<tr>'+CRLF
		cHtml += '        			<td>'+TMPSA2->A2_COD+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSA2->A2_LOJA+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSA2->A2_NOME+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSA2->A2_NREDUZ+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSA2->A2_MUN+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSA2->A2_EST+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSA2->TIPO+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSA2->A2_CGC+'</td>'+CRLF
		cHtml += '      		</tr>'+CRLF

		TMPSA2->( dbSkip() )
	EndDo

	TMPSA2->( dbCloseArea() )

	cHtml += '    		</tbody>'+CRLF
	cHtml += '  	</table>'+CRLF
	cHtml += '	  </div>'+CRLF
	cHtml += '  </div>'+CRLF

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-line-chart fa-1x"></i> Dashboard do Fornecedor - ' + AllTrim( SA2->A2_NREDUZ ) + '</H3>'+CRLF
	cHtml += '    </div>'+CRLF

	aAno := {}
	aAdd( aAno, { cAnoAn2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "#8191c9" })
	aAdd( aAno, { cAnoAnt, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "#3e95cd" })
	aAdd( aAno, { cAnoAtu, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "#ff0040" })

	cQuery := "SELECT ANO, SUM(JANEIRO) AS JANEIRO, SUM(FEVEREIRO) AS FEVEREIRO, SUM(MARCO) AS MARCO, SUM(ABRIL) AS ABRIL, " + CRLF
	cQuery += "SUM(MAIO) AS MAIO, SUM(JUNHO) AS JUNHO, SUM(JULHO) AS JULHO, SUM(AGOSTO) AS AGOSTO, " + CRLF
	cQuery += "SUM(SETEMBRO) AS SETEMBRO, SUM(OUTUBRO) AS OUTUBRO, SUM(NOVEMBRO) AS NOVEMBRO, SUM(DEZEMBRO) AS DEZEMBRO, SUM(TOTAL) AS TOTAL " + CRLF
	cQuery += "FROM ( " + CRLF

	cQuery += "SELECT LEFT(C7_EMISSAO, 4) AS ANO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '01' THEN COUNT(*) ELSE 0 END AS JANEIRO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '02' THEN COUNT(*) ELSE 0 END AS FEVEREIRO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '03' THEN COUNT(*) ELSE 0 END AS MARCO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '04' THEN COUNT(*) ELSE 0 END AS ABRIL, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '05' THEN COUNT(*) ELSE 0 END AS MAIO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '06' THEN COUNT(*) ELSE 0 END AS JUNHO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '07' THEN COUNT(*) ELSE 0 END AS JULHO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '08' THEN COUNT(*) ELSE 0 END AS AGOSTO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '09' THEN COUNT(*) ELSE 0 END AS SETEMBRO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '10' THEN COUNT(*) ELSE 0 END AS OUTUBRO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '11' THEN COUNT(*) ELSE 0 END AS NOVEMBRO, " + CRLF
	cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '12' THEN COUNT(*) ELSE 0 END AS DEZEMBRO, COUNT(*) AS TOTAL " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT C7_FILIAL, C7_NUM, C7_EMISSAO " + CRLF
	cQuery += "FROM " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE C7_FILIAL = '" + xFilial("SC7") + "' " + CRLF
	cQuery += "AND C7_FORNECE = '" + SA2->A2_COD + "' " + CRLF
	cQuery += "AND C7_LOJA = '" + SA2->A2_LOJA + "' " + CRLF
	cQuery += "AND C7_RESIDUO <> 'S' " + CRLF
	cQuery += "AND LEFT(C7_EMISSAO, 4) BETWEEN '" + cAnoAn2 + "' AND '" + cAnoAtu + "' " + CRLF
	cQuery += "AND SC7.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY C7_FILIAL, C7_NUM, C7_EMISSAO " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF
	cQuery += "GROUP BY LEFT(C7_EMISSAO, 4), SUBSTRING( C7_EMISSAO, 5, 2) " + CRLF
	cQuery += ") AS AGRUPAANO " + CRLF
	cQuery += "GROUP BY ANO " + CRLF
	cQuery += "ORDER BY ANO DESC " + CRLF

	TcQuery cQuery NEW ALIAS "TMPSC7"
	TMPSC7->( dbGoTop() )

	Do While !TMPSC7->( Eof() )
		nPosAno := aScan( aAno, {|x| AllTrim( x[01] ) == AllTrim( TMPSC7->ANO ) })

		If nPosAno > 0
			aAno[nPosAno][02] := TMPSC7->JANEIRO
			aAno[nPosAno][03] := TMPSC7->FEVEREIRO
			aAno[nPosAno][04] := TMPSC7->MARCO
			aAno[nPosAno][05] := TMPSC7->ABRIL
			aAno[nPosAno][06] := TMPSC7->MAIO
			aAno[nPosAno][07] := TMPSC7->JUNHO
			aAno[nPosAno][08] := TMPSC7->JULHO
			aAno[nPosAno][09] := TMPSC7->AGOSTO
			aAno[nPosAno][10] := TMPSC7->SETEMBRO
			aAno[nPosAno][11] := TMPSC7->OUTUBRO
			aAno[nPosAno][12] := TMPSC7->NOVEMBRO
			aAno[nPosAno][13] := TMPSC7->DEZEMBRO
		EndIf

		TMPSC7->( dbSkip() )
	EndDo

	TMPSC7->( dbCloseArea() )

	cHtml += '		<div class="row">' + CRLF
	cHtml += '			<div class="col-lg-6 col-md-6">' + CRLF
	cHtml += '				<h5><i class="fa fa-bar-chart-o fa-fw"></i> Quantidade de Pedidos por Ano (<B><font color="' + aAno[1][14] + '">' + cAnoAn2 + '</font></B>,<B><font color="' + aAno[2][14] + '">' + cAnoAnt + '</font></B>,<B><font color="' + aAno[3][14] + '">' + cAnoAtu + '</font></B>)</h5>' + CRLF
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

	cQuery := "SELECT SUM(EUROAMERICAN) AS EUROAMERICAN, SUM(QUALYCRIL) AS QUALYCRIL, SUM(METROPOLE) AS METROPOLE, SUM(QUALYVINIL) AS QUALYVINIL, SUM(JAYS) AS JAYS " + CRLF
	cQuery += "FROM ( " + CRLF

	cQuery += "SELECT COUNT(*) AS EUROAMERICAN, 0 AS QUALYCRIL, 0 AS METROPOLE, 0 AS QUALYVINIL, 0 AS JAYS " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT 1 AS EUROAMERICAN, 0 AS QUALYCRIL, 0 AS METROPOLE, 0 AS QUALYVINIL, 0 AS JAYS " + CRLF
	cQuery += "FROM " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE LEFT(C7_FILIAL, 2) = '02' " + CRLF
	cQuery += "AND C7_FORNECE = '" + SA2->A2_COD + "' " + CRLF
	cQuery += "AND C7_LOJA = '" + SA2->A2_LOJA + "' " + CRLF
	cQuery += "AND C7_RESIDUO <> 'S' " + CRLF
	cQuery += "AND SC7.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY C7_FILIAL, C7_NUM, C7_EMISSAO " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF

	cQuery += "UNION ALL " + CRLF

	cQuery += "SELECT 0 AS EUROAMERICAN, COUNT(*) AS QUALYCRIL, 0 AS METROPOLE, 0 AS QUALYVINIL, 0 AS JAYS " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT 0 AS EUROAMERICAN, 1 AS QUALYCRIL, 0 AS METROPOLE, 0 AS QUALYVINIL, 0 AS JAYS " + CRLF
	cQuery += "FROM " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE LEFT(C7_FILIAL, 2) = '08' " + CRLF
	cQuery += "AND C7_FORNECE = '" + SA2->A2_COD + "' " + CRLF
	cQuery += "AND C7_LOJA = '" + SA2->A2_LOJA + "' " + CRLF
	cQuery += "AND C7_RESIDUO <> 'S' " + CRLF
	cQuery += "AND SC7.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY C7_FILIAL, C7_NUM, C7_EMISSAO " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF

	cQuery += "UNION ALL " + CRLF

	cQuery += "SELECT 0 AS EUROAMERICAN, 0 AS QUALYCRIL, COUNT(*) AS METROPOLE, 0 AS QUALYVINIL, 0 AS JAYS " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT 0 AS EUROAMERICAN, 0 AS QUALYCRIL, 1 AS METROPOLE, 0 AS QUALYVINIL, 0 AS JAYS " + CRLF
	cQuery += "FROM " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE LEFT(C7_FILIAL, 2) = '06' " + CRLF
	cQuery += "AND C7_FORNECE = '" + SA2->A2_COD + "' " + CRLF
	cQuery += "AND C7_LOJA = '" + SA2->A2_LOJA + "' " + CRLF
	cQuery += "AND C7_RESIDUO <> 'S' " + CRLF
	cQuery += "AND SC7.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY C7_FILIAL, C7_NUM, C7_EMISSAO " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF

	cQuery += "UNION ALL " + CRLF

	cQuery += "SELECT 0 AS EUROAMERICAN, 0 AS QUALYCRIL, 0 AS METROPOLE, COUNT(*) AS QUALYVINIL, 0 AS JAYS " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT 0 AS EUROAMERICAN, 0 AS QUALYCRIL, 0 AS METROPOLE, 1 AS QUALYVINIL, 0 AS JAYS " + CRLF
	cQuery += "FROM " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE LEFT(C7_FILIAL, 2) = '03' " + CRLF
	cQuery += "AND C7_FORNECE = '" + SA2->A2_COD + "' " + CRLF
	cQuery += "AND C7_LOJA = '" + SA2->A2_LOJA + "' " + CRLF
	cQuery += "AND C7_RESIDUO <> 'S' " + CRLF
	cQuery += "AND SC7.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY C7_FILIAL, C7_NUM, C7_EMISSAO " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF

	cQuery += "UNION ALL " + CRLF

	cQuery += "SELECT 0 AS EUROAMERICAN, 0 AS QUALYCRIL, 0 AS METROPOLE, 0 AS QUALYVINIL, COUNT(*) AS JAYS " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT 0 AS EUROAMERICAN, 0 AS QUALYCRIL, 0 AS METROPOLE, 0 AS QUALYVINIL, 1 AS JAYS " + CRLF
	cQuery += "FROM " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE LEFT(C7_FILIAL, 2) = '01' " + CRLF
	cQuery += "AND C7_FORNECE = '" + SA2->A2_COD + "' " + CRLF
	cQuery += "AND C7_LOJA = '" + SA2->A2_LOJA + "' " + CRLF
	cQuery += "AND C7_RESIDUO <> 'S' " + CRLF
	cQuery += "AND SC7.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY C7_FILIAL, C7_NUM, C7_EMISSAO " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF
    
	cQuery += ") AS AGRUPADO " + CRLF

	TcQuery cQuery NEW ALIAS "TMPSC7"
	TMPSC7->( dbGoTop() )

	Do While !TMPSC7->( Eof() )
		aAdd( aSts, { AllTrim( SA2->A2_NOME ), TMPSC7->EUROAMERICAN, TMPSC7->QUALYCRIL, TMPSC7->METROPOLE, TMPSC7->QUALYVINIL, TMPSC7->JAYS })

		TMPSC7->( dbSkip() )
	EndDo

	If Len( aSts ) == 0
		aAdd( aSts, {AllTrim( SA2->A2_NOME ),0,0,0,0,0})
	EndIf

	TMPSC7->( dbCloseArea() )

	cHtml += '			<div class="col-lg-6 col-md-6">' + CRLF
	cHtml += '				<h5><i class="fa fa-bar-chart-o fa-fw"></i> Quantidade Pedidos por Empresa</h5>' + CRLF
	cHtml += '				<hr/>' + CRLF
	cHtml += '				<div class="well well-lg">' + CRLF
	cHtml += '					<canvas class="my-4 w-100" id="myRosc" width="900" height="380"></canvas>' + CRLF
	cHtml += '					<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>' + CRLF
	cHtml += '					<script>' + CRLF
	cHtml += '						var ctx = document.getElementById("myRosc");' + CRLF
	cHtml += '						var myRosc = new Chart(ctx, {' + CRLF
	cHtml += "						type: 'bar'," + CRLF
	cHtml += '						data: {' + CRLF
	cHtml += '						labels: ["Euroamerican", "Qualycril", "Metropole", "Qualyvinil", "Jays"],' + CRLF
	cHtml += '						datasets: [' + CRLF
	For nSts := 1 To Len( aSts )
		cHtml += '						{ ' + CRLF
		cHtml += '						data: [' + AllTrim( Str(aSts[nSts][02]) ) + ',' + AllTrim( Str(aSts[nSts][03]) ) + ',' + AllTrim( Str(aSts[nSts][04]) ) + ',' + AllTrim( Str(aSts[nSts][05]) ) + ',' + AllTrim( Str(aSts[nSts][06]) ) + '],' + CRLF
		cHtml += '						label: "' + aSts[nSts][01] + '",' + CRLF
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
	cHtml += '		</div>'

	cHtml += '		<Hr>' + CRLF

	If HttpGet->nopc == "1"
		cHtml += '	  <div class="form-group col-md-12">'+CRLF
		cHtml += '    	<a href="U_BeP0201.apw" class="btn btn-default">Voltar</a>'+CRLF
		cHtml += '	  </div>'+CRLF
	ElseIf HttpGet->nopc == "2"
		cHtml += '	  <div class="form-group col-md-12">'+CRLF
		cHtml += '    	<a href="U_BeP0202.apw" class="btn btn-default">Voltar</a>'+CRLF
		cHtml += '	  </div>'+CRLF
	ElseIf HttpGet->nopc == "3"
		cHtml += '	  <div class="form-group col-md-12">'+CRLF
		cHtml += '    	<a href="U_BeP0203.apw" class="btn btn-default">Voltar</a>'+CRLF
		cHtml += '	  </div>'+CRLF
	ElseIf HttpGet->nopc == "4"
		cHtml += '	  <div class="form-group col-md-12">'+CRLF
		cHtml += '    	<a href="U_BeP0204.apw" class="btn btn-default">Voltar</a>'+CRLF
		cHtml += '	  </div>'+CRLF
	ElseIf HttpGet->nopc == "5"
		cHtml += '	  <div class="form-group col-md-12">'+CRLF
		cHtml += '    	<a href="U_BeP0205.apw" class="btn btn-default">Voltar</a>'+CRLF
		cHtml += '	  </div>'+CRLF
	Else
		cHtml += '	  <div class="form-group col-md-12">'+CRLF
		cHtml += '    	<a href="U_BeP0201.apw" class="btn btn-default">Voltar</a>'+CRLF
		cHtml += '	  </div>'+CRLF
	EndIf

	cHtml += '  </form>'+CRLF
	cHtml += '</div>'+CRLF

	SM0->(dbGoTo(nRegSM0))
	cFilAnt := SM0->M0_CODFIL

Else
	If HttpGet->nopc == "1"
		cMsgHdr		:= "BEP0201 - Sessão não Iniciada"
		cMsgBody	:= "A sessão não foi iniciada, realize o Login!"
		cRetFun		:= "u_BePLogin.apw"
	ElseIf HttpGet->nopc == "2"
		cMsgHdr		:= "BEP0202 - Sessão não Iniciada"
		cMsgBody	:= "A sessão não foi iniciada, realize o Login!"
		cRetFun		:= "u_BePLogin.apw"
	ElseIf HttpGet->nopc == "3"
		cMsgHdr		:= "BEP0203 - Sessão não Iniciada"
		cMsgBody	:= "A sessão não foi iniciada, realize o Login!"
		cRetFun		:= "u_BePLogin.apw"
	ElseIf HttpGet->nopc == "4"
		cMsgHdr		:= "BEP0204 - Sessão não Iniciada"
		cMsgBody	:= "A sessão não foi iniciada, realize o Login!"
		cRetFun		:= "u_BePLogin.apw"
	Else
		cMsgHdr		:= "BEP0205 - Sessão não Iniciada"
		cMsgBody	:= "A sessão não foi iniciada, realize o Login!"
		cRetFun		:= "u_BePLogin.apw"
	EndIf

	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
EndIf
	
cHtml += Execblock("BePFooter",.F.,.F.)

WEB EXTENDED END

Return (EncodeUTF8(cHtml))
