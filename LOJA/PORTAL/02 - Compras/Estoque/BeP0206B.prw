#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

User Function BeP0206B()

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
Local nTotEst   := 0
Local nTotLote  := 0

Private cHtml 	:= ""    

WEB EXTENDED INIT cHtml                               

cHtml += Execblock("BePHeader",.F.,.F.)

If lSession

	cHtml += Execblock("BePMenus",.F.,.F.)

	dbSelectArea("SB1")
	dbSetOrder(1)
	SB1->( dbSeek(xFilial("SB1")+HttpGet->codpro) )

	dbSelectArea("SX5")
	dbSetOrder(1)
	SX5->( dbSeek( xFilial("SX5") + "02" + SB1->B1_TIPO ) )

	cHtml += '<div class="main col-md-12" style="margin-top: 50px">'
	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '  <h2><i class="far fa-ballot-check"></i> Análise de Estoque do Produto</h2>'+CRLF
	cHtml += '  <hr/>'+CRLF
	cHtml += '	<p></p>
	cHtml += '    </div>'+CRLF
	
	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Código:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="numpc" name="numpc" value="'+SB1->B1_COD+'" readonly>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Descrição:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+SB1->B1_DESC+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Tipo:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+SB1->B1_TIPO+" - "+X5Descri()+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Grupo:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+AllTrim(SB1->B1_GRUPO)+" - "+Posicione("SBM",1,xFilial("SBM")+SB1->B1_GRUPO,"BM_DESC")+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">NCM:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+SB1->B1_POSIPI+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Unidade de Medida:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+AllTrim(SB1->B1_UM)+" - "+Posicione("SAH",1,xFilial("SAH")+SB1->B1_UM,"AH_DESCPO")+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Segunda U.M.:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+AllTrim(SB1->B1_SEGUM)+" - "+Posicione("SAH",1,xFilial("SAH")+SB1->B1_SEGUM,"AH_DESCPO")+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Fator Conversão:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+AllTrim(Str(SB1->B1_CONV))+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Tipo Conversão:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+IIf(AllTrim(SB1->B1_TIPCONV) == "D","Divisor","Multiplicador")+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Rastreabilidade:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+IIf(AllTrim(SB1->B1_RASTRO) == "L","Controla Lote",IIf(AllTrim(SB1->B1_RASTRO) == "S","Controla Sub-Lote","Não Controla"))+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Endereçamento:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+IIf(AllTrim(SB1->B1_LOCALIZ) == "S","Sim","Não")+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Qtd. Padrão Compra:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+AllTrim(Str(SB1->B1_QE))+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Ponto Pedido:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+AllTrim(Str(SB1->B1_EMIN))+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Estoque de Segurança:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+AllTrim(Str(SB1->B1_ESTSEG))+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Prazo de Entrega:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+AllTrim(Str(SB1->B1_PE))+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Tipo de Prazo:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+IIf(AllTrim(SB1->B1_TIPE) == "D","Dias",IIf(AllTrim(SB1->B1_TIPE) == "S","Semanas",IIf(AllTrim(SB1->B1_TIPE) == "H","Horas",IIf(AllTrim(SB1->B1_TIPE) == "M","Meses","Anos"))))+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Lote Econômico:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+AllTrim(Str(SB1->B1_LE))+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Lote Mínimo Produção:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+AllTrim(Str(SB1->B1_LM))+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Prazo Validade (Dias):</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+AllTrim(Str(SB1->B1_PRVALID))+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Estoque Máximo:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+AllTrim(Str(SB1->B1_EMAX))+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-money fa-1x"></i> Informações sobre Custo NET e Cálculos</H3>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Custo Standard:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+AllTrim(Str(SB1->B1_CUSTD))+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Custo NET:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+AllTrim(Str(SB1->B1_CUSTNET))+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Preço NET:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+AllTrim(Str(SB1->B1_PRCNET))+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Valor Custo TEST:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+AllTrim(Str(SB1->B1_VALOR4))+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Fator de Cálculo:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+AllTrim(Str(SB1->B1_FATOR))+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Valor R$:</label>'+CRLF
	cHtml += '      <B><input type="text" class="form-control" id="codforn" name="codforn" value="'+AllTrim(Str(SB1->B1_VAL1))+'" disabled></B>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Valor US$:</label>'+CRLF
	cHtml += '      <B><input type="text" class="form-control" id="codforn" name="codforn" value="'+AllTrim(Str(SB1->B1_VALOR2))+'" disabled></B>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Dolar Desembaraço:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+AllTrim(Str(SB1->B1_ZDOLDES))+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Impostos MP:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codforn" name="codforn" value="'+AllTrim(Str(SB1->B1_ZCSTIMP))+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	//Table
	cHtml += '	<div  class="col-md-12" style="overflow-x:auto; width=100%; overflow-y:auto;">'+CRLF

	cHtml += '    <div class="form-group" style="max-height:300px; ">'+CRLF
	cHtml += '    	<table id="table" class="table table-bordered table-striped table-condensed col-md-12">'+CRLF
	cHtml += '    		<thead>'+CRLF
	cHtml += '      		<tr>'+CRLF
	cHtml += '		  			<th>Custo Janeiro</th>'+CRLF
	cHtml += '		  			<th>Custo Fevereiro</th>'+CRLF
	cHtml += '		  			<th>Custo Março</th>'+CRLF
	cHtml += '		  			<th>Custo Abril</th>'+CRLF
	cHtml += '		  			<th>Custo Maio</th>'+CRLF
	cHtml += '		  			<th>Custo Junho</th>'+CRLF
	cHtml += '		  			<th>Custo Julho</th>'+CRLF
	cHtml += '		  			<th>Custo Agosto</th>'+CRLF
	cHtml += '		  			<th>Custo Setembro</th>'+CRLF
	cHtml += '		  			<th>Custo Outubro</th>'+CRLF
	cHtml += '		  			<th>Custo Novembro</th>'+CRLF
	cHtml += '		  			<th>Custo Dezembro</th>'+CRLF
	cHtml += '      		</tr>'+CRLF
	cHtml += '    		</thead>'+CRLF
	cHtml += '			<tbody>'+CRLF
	cHtml += '				<tr>'+CRLF
	cHtml += '        			<td><B>'+Transform(SB1->B1_CUST01,PesqPict("SB2","B2_CM1"))+'</B></td>'+CRLF
	cHtml += '        			<td><B>'+Transform(SB1->B1_CUST02,PesqPict("SB2","B2_CM1"))+'</B></td>'+CRLF
	cHtml += '        			<td><B>'+Transform(SB1->B1_CUST03,PesqPict("SB2","B2_CM1"))+'</B></td>'+CRLF
	cHtml += '        			<td><B>'+Transform(SB1->B1_CUST04,PesqPict("SB2","B2_CM1"))+'</B></td>'+CRLF
	cHtml += '        			<td><B>'+Transform(SB1->B1_CUST05,PesqPict("SB2","B2_CM1"))+'</B></td>'+CRLF
	cHtml += '        			<td><B>'+Transform(SB1->B1_CUST06,PesqPict("SB2","B2_CM1"))+'</B></td>'+CRLF
	cHtml += '        			<td><B>'+Transform(SB1->B1_CUST07,PesqPict("SB2","B2_CM1"))+'</B></td>'+CRLF
	cHtml += '        			<td><B>'+Transform(SB1->B1_CUST08,PesqPict("SB2","B2_CM1"))+'</B></td>'+CRLF
	cHtml += '        			<td><B>'+Transform(SB1->B1_CUST09,PesqPict("SB2","B2_CM1"))+'</B></td>'+CRLF
	cHtml += '        			<td><B>'+Transform(SB1->B1_CUST10,PesqPict("SB2","B2_CM1"))+'</B></td>'+CRLF
	cHtml += '        			<td><B>'+Transform(SB1->B1_CUST11,PesqPict("SB2","B2_CM1"))+'</B></td>'+CRLF
	cHtml += '        			<td><B>'+Transform(SB1->B1_CUST12,PesqPict("SB2","B2_CM1"))+'</B></td>'+CRLF
	cHtml += '      		</tr>'+CRLF
	cHtml += '    		</tbody>'+CRLF
	cHtml += '  	</table>'+CRLF
	cHtml += '	  </div>'+CRLF
	cHtml += '  </div>'+CRLF

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-money fa-1x"></i> Dados de Custos Unitários do Último Ano</H3>'+CRLF
	cHtml += '    </div>'+CRLF

	//Table
	cHtml += '	<div  class="col-md-12" style="overflow-x:auto; width=100%; overflow-y:auto;">'+CRLF

	cHtml += '    <div class="form-group" style="max-height:300px; ">'+CRLF
	cHtml += '    	<table id="table" class="table table-bordered table-striped table-condensed col-md-12">'+CRLF
	cHtml += '    		<thead>'+CRLF
	cHtml += '      		<tr>'+CRLF
	cHtml += '		  			<th>Ano</th>'+CRLF
	cHtml += '		  			<th>Armazém</th>'+CRLF
	cHtml += '		  			<th>Custo Janeiro</th>'+CRLF
	cHtml += '		  			<th>Custo Fevereiro</th>'+CRLF
	cHtml += '		  			<th>Custo Março</th>'+CRLF
	cHtml += '		  			<th>Custo Abril</th>'+CRLF
	cHtml += '		  			<th>Custo Maio</th>'+CRLF
	cHtml += '		  			<th>Custo Junho</th>'+CRLF
	cHtml += '		  			<th>Custo Julho</th>'+CRLF
	cHtml += '		  			<th>Custo Agosto</th>'+CRLF
	cHtml += '		  			<th>Custo Setembro</th>'+CRLF
	cHtml += '		  			<th>Custo Outubro</th>'+CRLF
	cHtml += '		  			<th>Custo Novembro</th>'+CRLF
	cHtml += '		  			<th>Custo Dezembro</th>'+CRLF
	cHtml += '      		</tr>'+CRLF
	cHtml += '    		</thead>'+CRLF
	cHtml += '			<tbody>'+CRLF

	cQuery := "SELECT B9_ANO, B9_LOCAL, SUM(JAN) AS JAN, SUM(FEV) AS FEV, SUM(MAR) AS MAR, SUM(ABR) AS ABR, " + CRLF
	cQuery += "                 SUM(MAI) AS MAI, SUM(JUN) AS JUN, SUM(JUL) AS JUL, SUM(AGO) AS AGO, " + CRLF
	cQuery += "				 SUM([SET]) AS [SET], SUM([OUT]) AS [OUT], SUM(NOV) AS NOV, SUM(DEZ) AS DEZ " + CRLF
	cQuery += "FROM (" + CRLF
	cQuery += "SELECT LEFT(B9_DATA, 4) AS B9_ANO, B9_LOCAL, " + CRLF
	cQuery += "       CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '01' THEN SUM(B9_CM1) ELSE 0 END AS [JAN], " + CRLF
	cQuery += "       CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '02' THEN SUM(B9_CM1) ELSE 0 END AS [FEV], " + CRLF
	cQuery += "       CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '03' THEN SUM(B9_CM1) ELSE 0 END AS [MAR], " + CRLF
	cQuery += "       CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '04' THEN SUM(B9_CM1) ELSE 0 END AS [ABR], " + CRLF
	cQuery += "       CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '05' THEN SUM(B9_CM1) ELSE 0 END AS [MAI], " + CRLF
	cQuery += "       CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '06' THEN SUM(B9_CM1) ELSE 0 END AS [JUN], " + CRLF
	cQuery += "       CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '07' THEN SUM(B9_CM1) ELSE 0 END AS [JUL], " + CRLF
	cQuery += "       CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '08' THEN SUM(B9_CM1) ELSE 0 END AS [AGO], " + CRLF
	cQuery += "       CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '09' THEN SUM(B9_CM1) ELSE 0 END AS [SET], " + CRLF
	cQuery += "       CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '10' THEN SUM(B9_CM1) ELSE 0 END AS [OUT], " + CRLF
	cQuery += "       CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '11' THEN SUM(B9_CM1) ELSE 0 END AS [NOV], " + CRLF
	cQuery += "       CASE WHEN SUBSTRING( B9_DATA, 5, 2) = '12' THEN SUM(B9_CM1) ELSE 0 END AS [DEZ] " + CRLF
	cQuery += "FROM " + RetSqlName("SB9") + " AS SB9 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = B9_COD " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B9_FILIAL = '" + xFilial("SB9") + "' " + CRLF
	cQuery += "AND B9_COD = '" + SB1->B1_COD + "' " + CRLF
	cQuery += "AND B9_DATA >= CONVERT(VARCHAR(8),DATEADD(MONTH,-12,GETDATE()), 112)  " + CRLF
	cQuery += "AND SB9.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY LEFT(B9_DATA, 4), SUBSTRING( B9_DATA, 5, 2), B9_LOCAL " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF
	cQuery += "GROUP BY B9_ANO, B9_LOCAL " + CRLF
	cQuery += "ORDER BY B9_ANO DESC, B9_LOCAL " + CRLF

	TCQuery cQuery New Alias "TMPCM1"
	dbSelectArea("TMPCM1")
	TMPCM1->( dbGoTop() )

	Do While !TMPCM1->( Eof() )
		cHtml += '				<tr>'+CRLF
		cHtml += '        			<td><B>'+TMPCM1->B9_ANO+'</B></td>'+CRLF
		cHtml += '        			<td><B>'+TMPCM1->B9_LOCAL+'</B></td>'+CRLF
		cHtml += '        			<td><B>'+IIf(SubStr(DTOS(MsDate()-93), 5, 2) >= "01" .Or. SubStr(DTOS(MsDate()), 5, 2) <= "01",'<font color=red>','<font color=blue>')+Transform(TMPCM1->JAN,PesqPict("SB2","B2_CM1"))+'</font></B></td>'+CRLF
		cHtml += '        			<td><B>'+IIf(SubStr(DTOS(MsDate()-93), 5, 2) >= "02" .Or. SubStr(DTOS(MsDate()), 5, 2) <= "02",'<font color=red>','<font color=blue>')+Transform(TMPCM1->FEV,PesqPict("SB2","B2_CM1"))+'</font></B></td>'+CRLF
		cHtml += '        			<td><B>'+IIf(SubStr(DTOS(MsDate()-93), 5, 2) >= "03" .Or. SubStr(DTOS(MsDate()), 5, 2) <= "03",'<font color=red>','<font color=blue>')+Transform(TMPCM1->MAR,PesqPict("SB2","B2_CM1"))+'</font></B></td>'+CRLF
		cHtml += '        			<td><B>'+IIf(SubStr(DTOS(MsDate()-93), 5, 2) >= "04" .Or. SubStr(DTOS(MsDate()), 5, 2) <= "04",'<font color=red>','<font color=blue>')+Transform(TMPCM1->ABR,PesqPict("SB2","B2_CM1"))+'</font></B></td>'+CRLF
		cHtml += '        			<td><B>'+IIf(SubStr(DTOS(MsDate()-93), 5, 2) >= "05" .Or. SubStr(DTOS(MsDate()), 5, 2) <= "05",'<font color=red>','<font color=blue>')+Transform(TMPCM1->MAI,PesqPict("SB2","B2_CM1"))+'</font></B></td>'+CRLF
		cHtml += '        			<td><B>'+IIf(SubStr(DTOS(MsDate()-93), 5, 2) >= "06" .Or. SubStr(DTOS(MsDate()), 5, 2) <= "06",'<font color=red>','<font color=blue>')+Transform(TMPCM1->JUN,PesqPict("SB2","B2_CM1"))+'</font></B></td>'+CRLF
		cHtml += '        			<td><B>'+IIf(SubStr(DTOS(MsDate()-93), 5, 2) >= "07" .Or. SubStr(DTOS(MsDate()), 5, 2) <= "07",'<font color=red>','<font color=blue>')+Transform(TMPCM1->JUL,PesqPict("SB2","B2_CM1"))+'</font></B></td>'+CRLF
		cHtml += '        			<td><B>'+IIf(SubStr(DTOS(MsDate()-93), 5, 2) >= "08" .Or. SubStr(DTOS(MsDate()), 5, 2) <= "08",'<font color=red>','<font color=blue>')+Transform(TMPCM1->AGO,PesqPict("SB2","B2_CM1"))+'</font></B></td>'+CRLF
		cHtml += '        			<td><B>'+IIf(SubStr(DTOS(MsDate()-93), 5, 2) >= "09" .Or. SubStr(DTOS(MsDate()), 5, 2) <= "09",'<font color=red>','<font color=blue>')+Transform(TMPCM1->SET,PesqPict("SB2","B2_CM1"))+'</font></B></td>'+CRLF
		cHtml += '        			<td><B>'+IIf(SubStr(DTOS(MsDate()-93), 5, 2) >= "10" .Or. SubStr(DTOS(MsDate()), 5, 2) <= "10",'<font color=red>','<font color=blue>')+Transform(TMPCM1->OUT,PesqPict("SB2","B2_CM1"))+'</font></B></td>'+CRLF
		cHtml += '        			<td><B>'+IIf(SubStr(DTOS(MsDate()-93), 5, 2) >= "11" .Or. SubStr(DTOS(MsDate()), 5, 2) <= "11",'<font color=red>','<font color=blue>')+Transform(TMPCM1->NOV,PesqPict("SB2","B2_CM1"))+'</font></B></td>'+CRLF
		cHtml += '        			<td><B>'+IIf(SubStr(DTOS(MsDate()-93), 5, 2) >= "12" .Or. SubStr(DTOS(MsDate()), 5, 2) < "12",'<font color=red>','<font color=blue>')+Transform(TMPCM1->DEZ,PesqPict("SB2","B2_CM1"))+'</font></B></td>'+CRLF
		cHtml += '      		</tr>'+CRLF

		TMPCM1->( dbSkip() )
	EndDo
	TMPCM1->( dbCloseArea() )

	cHtml += '    		</tbody>'+CRLF
	cHtml += '  	</table>'+CRLF
	cHtml += '	  </div>'+CRLF
	cHtml += '  </div>'+CRLF

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-bars fa-1x"></i> Saldos nos Locais de Estoque</H3>'+CRLF
	cHtml += '    </div>'+CRLF

	//Table
	cHtml += '	<div  class="col-md-12" style="overflow-x:auto; width=100%; overflow-y:auto;">'+CRLF

	cHtml += '    <div class="form-group" style="max-height:300px; ">'+CRLF
	cHtml += '    	<table id="table" class="table table-bordered table-striped table-condensed col-md-12">'+CRLF
	cHtml += '    		<thead>'+CRLF
	cHtml += '      		<tr>'+CRLF
	cHtml += '		  			<th>Filial</th>'+CRLF
	cHtml += '        			<th>Local</th>'+CRLF
	cHtml += '        			<th>Quantidade</th>'+CRLF
	cHtml += '        			<th>Empenho</th>'+CRLF
	cHtml += '        			<th>Reserva</th>'+CRLF
	cHtml += '        			<th>A Classificar</th>'+CRLF
	cHtml += '        			<th>Custo Unitário</th>'+CRLF
	cHtml += '        			<th>Custo Total</th>'+CRLF
	cHtml += '      		</tr>'+CRLF
	cHtml += '    		</thead>'+CRLF
	cHtml += '			<tbody>'+CRLF
	
	cQuery := "SELECT B2_FILIAL, B2_LOCAL, B2_QATU, B2_QEMP, B2_RESERVA, B2_QACLASS, B2_CM1, B2_VATU1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("NNR") + " AS NNR WITH (NOLOCK) ON NNR_FILIAL = '" + xFilial("NNR") + "' " + CRLF
	cQuery += "  AND NNR_CODIGO = B2_LOCAL " + CRLF
	cQuery += "  AND NNR.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND B2_COD = '" + SB1->B1_COD + "' " + CRLF
	cQuery += "AND (B2_QATU <> 0 OR B2_VATU1 <> 0) " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPSB2"
	dbSelectArea("TMPSB2")
	TMPSB2->( dbGoTop() )

	nTotEst := 0

	Do While !TMPSB2->( Eof() )
		cHtml += '				<tr>'+CRLF
		cHtml += '        			<td>'+TMPSB2->B2_FILIAL+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSB2->B2_LOCAL+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(TMPSB2->B2_QATU,PesqPict("SB2","B2_QATU"))+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(TMPSB2->B2_QEMP,PesqPict("SB2","B2_QEMP"))+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(TMPSB2->B2_RESERVA,PesqPict("SB2","B2_RESERVA"))+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(TMPSB2->B2_QACLASS,PesqPict("SB2","B2_QEMP"))+'</td>'+CRLF
		cHtml += '        			<td><B>'+Transform(TMPSB2->B2_CM1,PesqPict("SB2","B2_CM1"))+'</B></td>'+CRLF
		cHtml += '        			<td><B>'+Transform(TMPSB2->B2_VATU1,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
		cHtml += '      		</tr>'+CRLF

		nTotEst += TMPSB2->B2_QATU

		TMPSB2->( dbSkip() )
	EndDo

	TMPSB2->( dbCloseArea() )

	cHtml += '				<tr>'+CRLF
	cHtml += '        			<td><B>Total:</B></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td><B>'+Transform(nTotEst,PesqPict("SB2","B2_QATU"))+'</B></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '      		</tr>'+CRLF

	cHtml += '    		</tbody>'+CRLF
	cHtml += '  	</table>'+CRLF
	cHtml += '	  </div>'+CRLF
	cHtml += '  </div>'+CRLF

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-tasks fa-1x"></i> Saldos por Lotes</H3>'+CRLF
	cHtml += '    </div>'+CRLF

	//Table
	cHtml += '	<div  class="col-md-12" style="overflow-x:auto; width=100%; overflow-y:auto;">'+CRLF

	cHtml += '    <div class="form-group" style="max-height:300px; ">'+CRLF
	cHtml += '    	<table id="table" class="table table-bordered table-striped table-condensed col-md-12">'+CRLF
	cHtml += '    		<thead>'+CRLF
	cHtml += '      		<tr>'+CRLF
	cHtml += '		  			<th>Filial</th>'+CRLF
	cHtml += '		  			<th>Local</th>'+CRLF
	cHtml += '		  			<th>Lote</th>'+CRLF
	cHtml += '        			<th>Sub-Lote</th>'+CRLF
	cHtml += '        			<th>Lote Fornecedor</th>'+CRLF
	cHtml += '        			<th>Dt. Fabric.</th>'+CRLF
	cHtml += '        			<th>Dt. Validade</th>'+CRLF
	cHtml += '        			<th>Saldo</th>'+CRLF
	cHtml += '        			<th>Empenho</th>'+CRLF
	cHtml += '        			<th>A Classificar</th>'+CRLF
	cHtml += '      		</tr>'+CRLF
	cHtml += '    		</thead>'+CRLF
	cHtml += '			<tbody>'+CRLF
	
	cQuery := "SELECT B8_FILIAL, B8_LOCAL, B8_LOTECTL, B8_NUMLOTE, B8_LOTEFOR, B8_DFABRIC, B8_DTVALID, B8_SALDO, B8_EMPENHO, B8_QACLASS " + CRLF
	cQuery += "FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("NNR") + " AS NNR WITH (NOLOCK) ON NNR_FILIAL = '" + xFilial("NNR") + "' " + CRLF
	cQuery += "  AND NNR_CODIGO = B8_LOCAL " + CRLF
	cQuery += "  AND NNR.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B8_FILIAL = '" + xFilial("SB8") + "' " + CRLF
	cQuery += "AND B8_PRODUTO = '" + SB1->B1_COD + "' " + CRLF
	cQuery += "AND B8_SALDO <> 0 " + CRLF
	cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPSB8"
	dbSelectArea("TMPSB8")
	TMPSB8->( dbGoTop() )

	nTotLote := 0

	Do While !TMPSB8->( Eof() )
		cHtml += '				<tr>'+CRLF
		cHtml += '        			<td>'+TMPSB8->B8_FILIAL+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSB8->B8_LOCAL+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSB8->B8_LOTECTL+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSB8->B8_NUMLOTE+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSB8->B8_LOTEFOR+'</td>'+CRLF
		cHtml += '        			<td>'+DTOC(STOD(TMPSB8->B8_DFABRIC))+'</td>'+CRLF
		cHtml += '        			<td>'+DTOC(STOD(TMPSB8->B8_DTVALID))+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(TMPSB8->B8_SALDO,PesqPict("SB8","B8_SALDO"))+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(TMPSB8->B8_EMPENHO,PesqPict("SB2","B2_QEMP"))+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(TMPSB8->B8_QACLASS,PesqPict("SB2","B2_QEMP"))+'</td>'+CRLF
		cHtml += '      		</tr>'+CRLF

		nTotLote += TMPSB8->B8_SALDO

		TMPSB8->( dbSkip() )
	EndDo

	TMPSB8->( dbCloseArea() )

	cHtml += '				<tr>'+CRLF
	cHtml += '        			<td><B>Total:</B></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td><B>'+Transform(nTotLote,PesqPict("SB2","B2_QATU"))+'</B></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '      		</tr>'+CRLF
    
	cHtml += '    		</tbody>'+CRLF
	cHtml += '  	</table>'+CRLF
	cHtml += '	  </div>'+CRLF
	cHtml += '  </div>'+CRLF

	/*
    */
	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-barcode fa-1x"></i> Saldos nos Endereços</H3>'+CRLF
	cHtml += '    </div>'+CRLF

	//Table
	cHtml += '	<div  class="col-md-12" style="overflow-x:auto; width=100%; overflow-y:auto;">'+CRLF

	cHtml += '    <div class="form-group" style="max-height:300px; ">'+CRLF
	cHtml += '    	<table id="table" class="table table-bordered table-striped table-condensed col-md-12">'+CRLF
	cHtml += '    		<thead>'+CRLF
	cHtml += '      		<tr>'+CRLF
	cHtml += '		  			<th>Filial</th>'+CRLF
	cHtml += '		  			<th>Local</th>'+CRLF
	cHtml += '		  			<th>Endereço</th>'+CRLF
	cHtml += '		  			<th>Lote</th>'+CRLF
	cHtml += '        			<th>Sub-Lote</th>'+CRLF
	cHtml += '        			<th>Quantidade</th>'+CRLF
	cHtml += '        			<th>Empenho</th>'+CRLF
	cHtml += '      		</tr>'+CRLF
	cHtml += '    		</thead>'+CRLF
	cHtml += '			<tbody>'+CRLF
	
	cQuery := "SELECT BF_FILIAL, BF_LOCAL, BF_LOCALIZ, BF_LOTECTL, BF_NUMLOTE, BF_QUANT, BF_EMPENHO " + CRLF
	cQuery += "FROM " + RetSqlName("SBF") + " AS SBF WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("NNR") + " AS NNR WITH (NOLOCK) ON NNR_FILIAL = '" + xFilial("NNR") + "' " + CRLF
	cQuery += "  AND NNR_CODIGO = BF_LOCAL " + CRLF
	cQuery += "  AND NNR.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE BF_FILIAL = '" + xFilial("SBF") + "' " + CRLF
	cQuery += "AND BF_PRODUTO = '" + SB1->B1_COD + "' " + CRLF
	cQuery += "AND BF_QUANT <> 0 " + CRLF
	cQuery += "AND SBF.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPSBF"
	dbSelectArea("TMPSBF")
	TMPSBF->( dbGoTop() )

	nTotLote := 0

	Do While !TMPSBF->( Eof() )
	cQuery := "SELECT , , , , , ,  " + CRLF
		cHtml += '				<tr>'+CRLF
		cHtml += '        			<td>'+TMPSBF->BF_FILIAL+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSBF->BF_LOCAL+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSBF->BF_LOCALIZ+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSBF->BF_LOTECTL+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSBF->BF_NUMLOTE+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(TMPSBF->BF_QUANT,PesqPict("SB8","B8_SALDO"))+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(TMPSBF->BF_EMPENHO,PesqPict("SB2","B2_QEMP"))+'</td>'+CRLF
		cHtml += '      		</tr>'+CRLF

		nTotLote += TMPSBF->BF_QUANT

		TMPSBF->( dbSkip() )
	EndDo

	TMPSBF->( dbCloseArea() )

	cHtml += '				<tr>'+CRLF
	cHtml += '        			<td><B>Total:</B></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td><B>'+Transform(nTotLote,PesqPict("SB2","B2_QATU"))+'</B></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '      		</tr>'+CRLF
    
	cHtml += '    		</tbody>'+CRLF
	cHtml += '  	</table>'+CRLF
	cHtml += '	  </div>'+CRLF
	cHtml += '  </div>'+CRLF

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-pie-chart fa-1x"></i> Indicadores de Compras / Reposição</H3>'+CRLF
	cHtml += '    </div>'+CRLF


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
	cQuery += "AND B9_COD = '" + SB1->B1_COD + "' " + CRLF
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
    
/**/
	nQtdCobertura := 0
	nQtdSldAtual  := 0

	cQuery := "SELECT SUM(SALDO_ESTOQUE) AS SALDO_ESTOQUE, SUM(SAIDAS) AS SAIDAS, ABS(CASE WHEN SUM(SALDO_ESTOQUE) > 0 THEN SUM(SALDO_ESTOQUE) ELSE 1 END / (CASE WHEN SUM(SAIDAS) > 0 THEN SUM(SAIDAS) ELSE 1 END / 365)) AS COBERTURA " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT SUM(B2_QATU) AS SALDO_ESTOQUE, 0 AS SAIDAS " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND B2_COD = '" + SB1->B1_COD + "' " + CRLF
	cQuery += "AND B2_QATU <> 0 " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT 0 AS SALDO_ESTOQUE, SUM(D2_QUANT) AS SAIDAS " + CRLF
	cQuery += "FROM " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE D2_FILIAL = '" + xFilial("SD2") + "' " + CRLF
	cQuery += "AND D2_EMISSAO >= CONVERT(VARCHAR(8),DATEADD( DD, -365, GETDATE()),112) " + CRLF
	cQuery += "AND D2_COD = '" + SB1->B1_COD + "' " + CRLF
	cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("SF4") + " WITH (NOLOCK) WHERE F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = D2_TES AND F4_ESTOQUE = 'S' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND SD2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT 0 AS SALDO_ESTOQUE, SUM(D3_QUANT) AS SAIDAS " + CRLF
	cQuery += "FROM " + RetSqlName("SD3") + " AS SD3 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE D3_FILIAL = '" + xFilial("SD3") + "' " + CRLF
	cQuery += "AND D3_EMISSAO >= CONVERT(VARCHAR(8),DATEADD( DD, -365, GETDATE()),112) " + CRLF
	cQuery += "AND D3_COD = '" + SB1->B1_COD + "' " + CRLF
	cQuery += "AND D3_TM >= '500' " + CRLF
	cQuery += "AND SD3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF

	nQtdCobertura := 0

	TcQuery cQuery NEW ALIAS "TMPSB9"
	TMPSB9->( dbGoTop() )

	If !TMPSB9->( Eof() )
		nQtdCobertura := TMPSB9->COBERTURA
		nQtdSldAtual  := TMPSB9->SALDO_ESTOQUE
	EndIf

	TMPSB9->( dbCloseArea() )

	cHtml += '			<div class="col-lg-6 col-md-6">' + CRLF
	cHtml += '				<h5><i class="fa fa-bar-chart-o fa-fw"></i> Cobertura do Estoque (Em Dias)</h5>' + CRLF
	cHtml += '				<hr/>' + CRLF
	cHtml += '				<div class="panel panel-primary">' + CRLF
	cHtml += '					<div class="panel-heading">' + CRLF
	cHtml += '						<div class="row">' + CRLF
	cHtml += '							<div class="col-xs-3">' + CRLF
	cHtml += '								<i class="fa fa-calendar-check-o fa-3x"></i>' + CRLF //<i class="fa fa-tasks fa-5x"></i>
	cHtml += '							</div>' + CRLF
	cHtml += '							<div class="col-xs-9 text-right">' + CRLF
	cHtml += '								<div class="huge"><B>' + AllTrim( Str( nQtdCobertura ) ) + '</B></div>' + CRLF
	cHtml += '								<div>Dias Cobertura de Estoque</div>' + CRLF
	cHtml += '							</div>' + CRLF
	cHtml += '						</div>' + CRLF
	cHtml += '						<Hr/>' + CRLF
	cHtml += '						<div class="row">' + CRLF
	cHtml += '							<div class="col-xs-3">' + CRLF
	cHtml += '								<i class="fa fa-truck fa-3x"></i>' + CRLF
	cHtml += '							</div>' + CRLF
	cHtml += '							<div class="col-xs-9 text-right">' + CRLF
	cHtml += '								<div class="huge"><B>' + AllTrim( Str( SB1->B1_PE ) ) + " " + AllTrim( SB1->B1_TIPE ) + '</B></div>' + CRLF
	cHtml += '								<div>Lead Time</div>' + CRLF
	cHtml += '							</div>' + CRLF
	cHtml += '						</div>' + CRLF
	cHtml += '						<Hr/>' + CRLF
	cHtml += '						<div class="row">' + CRLF
	cHtml += '							<div class="col-xs-3">' + CRLF
	cHtml += '								<i class="fa fa-bars fa-3x"></i>' + CRLF
	cHtml += '							</div>' + CRLF
	cHtml += '							<div class="col-xs-9 text-right">' + CRLF
	cHtml += '								<div class="huge"><B>' + AllTrim( Str( nQtdSldAtual ) ) + '</B></div>' + CRLF
	cHtml += '								<div>Saldo em Estoque</div>' + CRLF
	cHtml += '							</div>' + CRLF
	cHtml += '						</div>' + CRLF
	cHtml += '					</div>' + CRLF
	cHtml += '				</div>' + CRLF
	cHtml += '			</div>' + CRLF

	cHtml += '			</div>' + CRLF
	cHtml += '						<Hr/>' + CRLF

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
	cQuery += "AND B9_COD = '" + SB1->B1_COD + "' " + CRLF
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


/**/
	cQuery := "SELECT ANO, CONVERT(DECIMAL(14,2),CASE WHEN SUM(SAIDAS_JAN) <> 0 THEN SUM(SAIDAS_JAN) ELSE 0.0001 END / CASE WHEN SUM(MEDIA_JAN) <> 0 THEN SUM(MEDIA_JAN) ELSE 0.1 END) AS JANEIRO, " + CRLF
	cQuery += "            CONVERT(DECIMAL(14,2),CASE WHEN SUM(SAIDAS_FEV) <> 0 THEN SUM(SAIDAS_FEV) ELSE 0.0001 END / CASE WHEN SUM(MEDIA_FEV) <> 0 THEN SUM(MEDIA_FEV) ELSE 0.1 END) AS FEVEREIRO, " + CRLF
	cQuery += "			CONVERT(DECIMAL(14,2),CASE WHEN SUM(SAIDAS_MAR) <> 0 THEN SUM(SAIDAS_MAR) ELSE 0.0001 END / CASE WHEN SUM(MEDIA_MAR) <> 0 THEN SUM(MEDIA_MAR) ELSE 0.1 END) AS MARCO, " + CRLF
	cQuery += "			CONVERT(DECIMAL(14,2),CASE WHEN SUM(SAIDAS_ABR) <> 0 THEN SUM(SAIDAS_ABR) ELSE 0.0001 END / CASE WHEN SUM(MEDIA_ABR) <> 0 THEN SUM(MEDIA_ABR) ELSE 0.1 END) AS ABRIL, " + CRLF
	cQuery += "			CONVERT(DECIMAL(14,2),CASE WHEN SUM(SAIDAS_MAI) <> 0 THEN SUM(SAIDAS_MAI) ELSE 0.0001 END / CASE WHEN SUM(MEDIA_MAI) <> 0 THEN SUM(MEDIA_MAI) ELSE 0.1 END) AS MAIO, " + CRLF
	cQuery += "			CONVERT(DECIMAL(14,2),CASE WHEN SUM(SAIDAS_JUN) <> 0 THEN SUM(SAIDAS_JUN) ELSE 0.0001 END / CASE WHEN SUM(MEDIA_JUN) <> 0 THEN SUM(MEDIA_JUN) ELSE 0.1 END) AS JUNHO, " + CRLF
	cQuery += "			CONVERT(DECIMAL(14,2),CASE WHEN SUM(SAIDAS_JUL) <> 0 THEN SUM(SAIDAS_JUL) ELSE 0.0001 END / CASE WHEN SUM(MEDIA_JUL) <> 0 THEN SUM(MEDIA_JUL) ELSE 0.1 END) AS JULHO, " + CRLF
	cQuery += "			CONVERT(DECIMAL(14,2),CASE WHEN SUM(SAIDAS_AGO) <> 0 THEN SUM(SAIDAS_AGO) ELSE 0.0001 END / CASE WHEN SUM(MEDIA_AGO) <> 0 THEN SUM(MEDIA_AGO) ELSE 0.1 END) AS AGOSTO, " + CRLF
	cQuery += "			CONVERT(DECIMAL(14,2),CASE WHEN SUM(SAIDAS_SET) <> 0 THEN SUM(SAIDAS_SET) ELSE 0.0001 END / CASE WHEN SUM(MEDIA_SET) <> 0 THEN SUM(MEDIA_SET) ELSE 0.1 END) AS SETEMBRO, " + CRLF
	cQuery += "			CONVERT(DECIMAL(14,2),CASE WHEN SUM(SAIDAS_OUT) <> 0 THEN SUM(SAIDAS_OUT) ELSE 0.0001 END / CASE WHEN SUM(MEDIA_OUT) <> 0 THEN SUM(MEDIA_OUT) ELSE 0.1 END) AS OUTUBRO, " + CRLF
	cQuery += "			CONVERT(DECIMAL(14,2),CASE WHEN SUM(SAIDAS_NOV) <> 0 THEN SUM(SAIDAS_NOV) ELSE 0.0001 END / CASE WHEN SUM(MEDIA_NOV) <> 0 THEN SUM(MEDIA_NOV) ELSE 0.1 END) AS NOVEMBRO, " + CRLF
	cQuery += "			CONVERT(DECIMAL(14,2),CASE WHEN SUM(SAIDAS_DEZ) <> 0 THEN SUM(SAIDAS_DEZ) ELSE 0.0001 END / CASE WHEN SUM(MEDIA_DEZ) <> 0 THEN SUM(MEDIA_DEZ) ELSE 0.1 END) AS DEZEMBRO " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT ANO, " + CRLF
	cQuery += "CASE WHEN MES = '01' THEN SUM(SAIDAS) ELSE 0 END AS SAIDAS_JAN, " + CRLF
	cQuery += "CASE WHEN MES = '02' THEN SUM(SAIDAS) ELSE 0 END AS SAIDAS_FEV, " + CRLF
	cQuery += "CASE WHEN MES = '03' THEN SUM(SAIDAS) ELSE 0 END AS SAIDAS_MAR, " + CRLF
	cQuery += "CASE WHEN MES = '04' THEN SUM(SAIDAS) ELSE 0 END AS SAIDAS_ABR, " + CRLF
	cQuery += "CASE WHEN MES = '05' THEN SUM(SAIDAS) ELSE 0 END AS SAIDAS_MAI, " + CRLF
	cQuery += "CASE WHEN MES = '06' THEN SUM(SAIDAS) ELSE 0 END AS SAIDAS_JUN, " + CRLF
	cQuery += "CASE WHEN MES = '07' THEN SUM(SAIDAS) ELSE 0 END AS SAIDAS_JUL, " + CRLF
	cQuery += "CASE WHEN MES = '08' THEN SUM(SAIDAS) ELSE 0 END AS SAIDAS_AGO, " + CRLF
	cQuery += "CASE WHEN MES = '09' THEN SUM(SAIDAS) ELSE 0 END AS SAIDAS_SET, " + CRLF
	cQuery += "CASE WHEN MES = '10' THEN SUM(SAIDAS) ELSE 0 END AS SAIDAS_OUT, " + CRLF
	cQuery += "CASE WHEN MES = '11' THEN SUM(SAIDAS) ELSE 0 END AS SAIDAS_NOV, " + CRLF
	cQuery += "CASE WHEN MES = '12' THEN SUM(SAIDAS) ELSE 0 END AS SAIDAS_DEZ, " + CRLF
	cQuery += "CASE WHEN MES = '01' AND SUM(SALDOINICIAL + SALDOFINAL) <> 0 THEN SUM(SALDOINICIAL + SALDOFINAL) / 2 ELSE 0 END AS MEDIA_JAN, " + CRLF
	cQuery += "CASE WHEN MES = '02' AND SUM(SALDOINICIAL + SALDOFINAL) <> 0 THEN SUM(SALDOINICIAL + SALDOFINAL) / 2 ELSE 0 END AS MEDIA_FEV, " + CRLF
	cQuery += "CASE WHEN MES = '03' AND SUM(SALDOINICIAL + SALDOFINAL) <> 0 THEN SUM(SALDOINICIAL + SALDOFINAL) / 2 ELSE 0 END AS MEDIA_MAR, " + CRLF
	cQuery += "CASE WHEN MES = '04' AND SUM(SALDOINICIAL + SALDOFINAL) <> 0 THEN SUM(SALDOINICIAL + SALDOFINAL) / 2 ELSE 0 END AS MEDIA_ABR, " + CRLF
	cQuery += "CASE WHEN MES = '05' AND SUM(SALDOINICIAL + SALDOFINAL) <> 0 THEN SUM(SALDOINICIAL + SALDOFINAL) / 2 ELSE 0 END AS MEDIA_MAI, " + CRLF
	cQuery += "CASE WHEN MES = '06' AND SUM(SALDOINICIAL + SALDOFINAL) <> 0 THEN SUM(SALDOINICIAL + SALDOFINAL) / 2 ELSE 0 END AS MEDIA_JUN, " + CRLF
	cQuery += "CASE WHEN MES = '07' AND SUM(SALDOINICIAL + SALDOFINAL) <> 0 THEN SUM(SALDOINICIAL + SALDOFINAL) / 2 ELSE 0 END AS MEDIA_JUL, " + CRLF
	cQuery += "CASE WHEN MES = '08' AND SUM(SALDOINICIAL + SALDOFINAL) <> 0 THEN SUM(SALDOINICIAL + SALDOFINAL) / 2 ELSE 0 END AS MEDIA_AGO, " + CRLF
	cQuery += "CASE WHEN MES = '09' AND SUM(SALDOINICIAL + SALDOFINAL) <> 0 THEN SUM(SALDOINICIAL + SALDOFINAL) / 2 ELSE 0 END AS MEDIA_SET, " + CRLF
	cQuery += "CASE WHEN MES = '10' AND SUM(SALDOINICIAL + SALDOFINAL) <> 0 THEN SUM(SALDOINICIAL + SALDOFINAL) / 2 ELSE 0 END AS MEDIA_OUT, " + CRLF
	cQuery += "CASE WHEN MES = '11' AND SUM(SALDOINICIAL + SALDOFINAL) <> 0 THEN SUM(SALDOINICIAL + SALDOFINAL) / 2 ELSE 0 END AS MEDIA_NOV, " + CRLF
	cQuery += "CASE WHEN MES = '12' AND SUM(SALDOINICIAL + SALDOFINAL) <> 0 THEN SUM(SALDOINICIAL + SALDOFINAL) / 2 ELSE 0 END AS MEDIA_DEZ " + CRLF
	cQuery += "FROM (" + CRLF
	cQuery += "SELECT LEFT(D2_EMISSAO, 4) AS ANO, SUBSTRING(D2_EMISSAO, 5, 2) AS MES, SUM(D2_QUANT) AS SAIDAS, 0 AS ENTRADAS, 0 AS SALDOINICIAL, 0 AS SALDOFINAL " + CRLF
	cQuery += "FROM " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE D2_FILIAL = '" + xFilial("SD2") + "' " + CRLF
	cQuery += "AND D2_COD = '" + SB1->B1_COD + "' " + CRLF
	cQuery += "AND LEFT(D2_EMISSAO, 4) BETWEEN '" + cAnoAn2 + "' AND '" + cAnoAtu + "' " + CRLF
	cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("SF4") + " WITH (NOLOCK) WHERE F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = D2_TES AND F4_ESTOQUE = 'S' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND SD2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY LEFT(D2_EMISSAO, 4), SUBSTRING(D2_EMISSAO, 5, 2) " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT LEFT(D3_EMISSAO, 4) AS ANO, SUBSTRING(D3_EMISSAO, 5, 2) AS MES, SUM(D3_QUANT) AS SAIDAS, 0 AS ENTRADAS, 0 AS SALDOINICIAL, 0 AS SALDOFINAL " + CRLF
	cQuery += "FROM " + RetSqlName("SD3") + " AS SD3 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE D3_FILIAL = '" + xFilial("SD3") + "' " + CRLF
	cQuery += "AND D3_COD = '" + SB1->B1_COD + "' " + CRLF
	cQuery += "AND LEFT(D3_EMISSAO, 4) BETWEEN '" + cAnoAn2 + "' AND '" + cAnoAtu + "' " + CRLF
	cQuery += "AND D3_TM >= '500' " + CRLF
	cQuery += "AND SD3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY LEFT(D3_EMISSAO, 4), SUBSTRING(D3_EMISSAO, 5, 2) " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT LEFT(D1_DTDIGIT, 4) AS ANO, SUBSTRING(D1_DTDIGIT, 5, 2) AS MES, 0 AS SAIDAS, SUM(D1_QUANT) AS ENTRADAS, 0 AS SALDOINICIAL, 0 AS SALDOFINAL  " + CRLF
	cQuery += "FROM " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE D1_FILIAL = '" + xFilial("SD1") + "' " + CRLF
	cQuery += "AND D1_COD = '" + SB1->B1_COD + "' " + CRLF
	cQuery += "AND LEFT(D1_DTDIGIT, 4) BETWEEN '" + cAnoAn2 + "' AND '" + cAnoAtu + "' " + CRLF
	cQuery += "AND EXISTS (SELECT * FROM SF4020 WITH (NOLOCK) WHERE F4_FILIAL = '  ' AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY LEFT(D1_DTDIGIT, 4), SUBSTRING(D1_DTDIGIT, 5, 2) " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT LEFT(D3_EMISSAO, 4) AS ANO, SUBSTRING(D3_EMISSAO, 5, 2) AS MES, 0 AS SAIDAS, SUM(D3_QUANT) AS ENTRADAS, 0 AS SALDOINICIAL, 0 AS SALDOFINAL " + CRLF
	cQuery += "FROM " + RetSqlName("SD3") + " AS SD3 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE D3_FILIAL = '" + xFilial("SD1") + "' " + CRLF
	cQuery += "AND D3_COD = '" + SB1->B1_COD + "' " + CRLF
	cQuery += "AND LEFT(D3_EMISSAO, 4) BETWEEN '" + cAnoAn2 + "' AND '" + cAnoAtu + "' " + CRLF
	cQuery += "AND D3_TM < '500' " + CRLF
	cQuery += "AND SD3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY LEFT(D3_EMISSAO, 4), SUBSTRING(D3_EMISSAO, 5, 2) " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT LEFT(B9_DATA, 4) AS ANO, SUBSTRING(B9_DATA, 5, 2) AS MES, 0 AS SAIDAS, 0 AS ENTRADAS, 0 AS SALDOINICIAL, SUM(B9_QINI) AS SALDOFINAL " + CRLF
	cQuery += "FROM " + RetSqlName("SB9") + " AS SB9 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B9_FILIAL = '" + xFilial("SB9") + "' " + CRLF
	cQuery += "AND B9_COD = '" + SB1->B1_COD + "' " + CRLF
	cQuery += "AND LEFT(B9_DATA, 4) BETWEEN '" + cAnoAn2 + "' AND '" + cAnoAtu + "' " + CRLF
	cQuery += "AND SB9.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY LEFT(B9_DATA, 4), SUBSTRING(B9_DATA, 5, 2) " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT LEFT(CONVERT(VARCHAR(8),DATEADD(DD,20,CONVERT(DATETIME,B9_DATA)),112), 4) AS ANO, SUBSTRING(CONVERT(VARCHAR(8),DATEADD(DD,20,CONVERT(DATETIME,B9_DATA)),112), 5, 2) AS MES, 0 AS SAIDAS, 0 AS ENTRADAS, SUM(B9_QINI) AS SALDOINICIAL, 0 AS SALDOFINAL " + CRLF
	cQuery += "FROM " + RetSqlName("SB9") + " AS SB9 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B9_FILIAL = '" + xFilial("SB9") + "' " + CRLF
	cQuery += "AND B9_COD = '" + SB1->B1_COD + "' " + CRLF
	cQuery += "AND LEFT(B9_DATA, 4) BETWEEN '" + cAnoAn2 + "' AND '" + cAnoAtu + "' " + CRLF
	cQuery += "AND SB9.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY B9_DATA " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF
	cQuery += "GROUP BY ANO, MES " + CRLF
	cQuery += ") AS AGPANO " + CRLF
	cQuery += "GROUP BY ANO " + CRLF

	TcQuery cQuery NEW ALIAS "TMPGIRO"
	TMPGIRO->( dbGoTop() )

	Do While !TMPGIRO->( Eof() )
		aAdd( aSts, { AllTrim( TMPGIRO->ANO ), TMPGIRO->JANEIRO, TMPGIRO->FEVEREIRO, TMPGIRO->MARCO, TMPGIRO->ABRIL, TMPGIRO->MAIO, TMPGIRO->JUNHO, TMPGIRO->JULHO, TMPGIRO->AGOSTO, TMPGIRO->SETEMBRO, TMPGIRO->OUTUBRO, TMPGIRO->NOVEMBRO, TMPGIRO->DEZEMBRO })

		TMPGIRO->( dbSkip() )
	EndDo

	If Len( aSts ) == 0
		aAdd( aSts, {Left( DTOS( dDataBase ), 4 ),0,0,0,0,0,0,0,0,0,0,0,0})
	EndIf

	TMPGIRO->( dbCloseArea() )

	cHtml += '			<div class="col-lg-6 col-md-6">' + CRLF
	cHtml += '				<h5><i class="fa fa-bar-chart-o fa-fw"></i> Giro do Estoque Análise Mensal Últimos 3 Anos</h5>' + CRLF
	cHtml += '				<hr/>' + CRLF
	cHtml += '				<div class="well well-lg">' + CRLF
	cHtml += '					<canvas class="my-4 w-100" id="myRosc" width="900" height="380"></canvas>' + CRLF
	cHtml += '					<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>' + CRLF
	cHtml += '					<script>' + CRLF
	cHtml += '						var ctx = document.getElementById("myRosc");' + CRLF
	cHtml += '						var myRosc = new Chart(ctx, {' + CRLF
	cHtml += "						type: 'bar'," + CRLF
	cHtml += '						data: {' + CRLF
	cHtml += '						labels: ["Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"],' + CRLF
	cHtml += '						datasets: [' + CRLF
	For nSts := 1 To Len( aSts )
		cHtml += '						{ ' + CRLF
		cHtml += '						data: [' + AllTrim( Str(aSts[nSts][02]) ) + ',' + AllTrim( Str(aSts[nSts][03]) ) + ',' + AllTrim( Str(aSts[nSts][04]) ) + ',' + AllTrim( Str(aSts[nSts][05]) ) + ',' + AllTrim( Str(aSts[nSts][06]) ) + ',' + AllTrim( Str(aSts[nSts][07]) ) + ',' + AllTrim( Str(aSts[nSts][08]) ) + ',' + AllTrim( Str(aSts[nSts][09]) ) + ',' + AllTrim( Str(aSts[nSts][10]) ) + ',' + AllTrim( Str(aSts[nSts][11]) ) + ',' + AllTrim( Str(aSts[nSts][12]) ) + ',' + AllTrim( Str(aSts[nSts][13]) ) + '],' + CRLF
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
    /**/
 
	cHtml += '		<Hr>' + CRLF

	/**/
	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-table fa-1x"></i> Pedido de Vendas em Aberto</H3>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '	<div  class="col-md-12" style="overflow-x:auto; width=100%; overflow-y:auto;">'+CRLF

	cHtml += '    <div class="form-group" style="max-height:300px; ">'+CRLF
	cHtml += '    	<table id="table" class="table table-bordered table-striped table-condensed col-md-12">'+CRLF
	cHtml += '    		<thead>'+CRLF
	cHtml += '      		<tr>'+CRLF
	cHtml += '		  			<th>Filial</th>'+CRLF
	cHtml += '        			<th>Pedido</th>'+CRLF
	cHtml += '        			<th>Item</th>'+CRLF
	cHtml += '        			<th>Descrição</th>'+CRLF
	cHtml += '        			<th>Quantidade</th>'+CRLF
	cHtml += '        			<th>Preço</th>'+CRLF
	cHtml += '        			<th>Valor</th>'+CRLF
	cHtml += '        			<th>TES</th>'+CRLF
	cHtml += '        			<th>Emissão</th>'+CRLF
	cHtml += '        			<th>Entrega</th>'+CRLF
	cHtml += '        			<th>Tipo</th>'+CRLF
	cHtml += '        			<th>Cliente</th>'+CRLF
	cHtml += '      		</tr>'+CRLF
	cHtml += '    		</thead>'+CRLF
	cHtml += '			<tbody>'+CRLF
	
	cQuery := "SELECT C5_FILIAL, C5_NUM, C6_ITEM, C6_DESCRI, C6_QTDVEN, C6_PRCVEN, C6_VALOR, C6_TES, C5_EMISSAO, C6_ENTREG, C5_TIPO, ISNULL( A1_NOME, A2_NOME) AS A1_NOME " + CRLF
	cQuery += "FROM " + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SC5") + " AS SC5 WITH (NOLOCK) ON C5_FILIAL = C6_FILIAL " + CRLF
	cQuery += "  AND C5_NUM = C6_NUM " + CRLF
	cQuery += "  AND C5_BLQ = '' " + CRLF
	cQuery += "  AND SC5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "LEFT JOIN " + RetSqlName("SA1") + " AS SA1 WITH (NOLOCK) ON A1_FILIAL = C5_FILIAL " + CRLF
	cQuery += "  AND A1_COD = C5_CLIENTE " + CRLF
	cQuery += "  AND A1_LOJA = C5_LOJACLI " + CRLF
	cQuery += "  AND C5_TIPO NOT IN ('D','B') " + CRLF
	cQuery += "  AND SA1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "LEFT JOIN " + RetSqlName("SA2") + " AS SA2 WITH (NOLOCK) ON A2_FILIAL = '" + xFilial("SA2") + "' " + CRLF
	cQuery += "  AND A2_COD = C5_CLIENTE " + CRLF
	cQuery += "  AND A2_LOJA = C5_LOJACLI " + CRLF
	cQuery += "  AND C5_TIPO IN ('D','B') " + CRLF
	cQuery += "  AND SA2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C6_FILIAL = '" + xFilial("SC6") + "' " + CRLF
	cQuery += "AND C6_PRODUTO = '" + SB1->B1_COD + "' " + CRLF
	cQuery += "AND C6_QTDVEN > C6_QTDENT " + CRLF
	cQuery += "AND SC6.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY C5_NUM DESC, C6_ITEM " + CRLF

	TCQuery cQuery New Alias "TMPSC6"
	dbSelectArea("TMPSC6")
	TMPSC6->( dbGoTop() )

	Do While !TMPSC6->( Eof() )
		cHtml += '				<tr>'+CRLF
		cHtml += '        			<td>'+TMPSC6->C5_FILIAL+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSC6->C5_NUM+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSC6->C6_ITEM+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSC6->C6_DESCRI+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(TMPSC6->C6_QTDVEN,PesqPict("SC6","C6_QTDVEN"))+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(TMPSC6->C6_PRCVEN,PesqPict("SC6","C6_PRCVEN"))+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(TMPSC6->C6_VALOR,PesqPict("SC6","C6_VALOR"))+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSC6->C6_TES+'</td>'+CRLF
		cHtml += '        			<td>'+DTOC(STOD(TMPSC6->C5_EMISSAO))+'</td>'+CRLF
		cHtml += '        			<td>'+DTOC(STOD(TMPSC6->C6_ENTREG))+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSC6->C5_TIPO+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSC6->A1_NOME+'</td>'+CRLF
		cHtml += '      		</tr>'+CRLF

		TMPSC6->( dbSkip() )
	EndDo

	cHtml += '    		</tbody>'+CRLF
	cHtml += '  	</table>'+CRLF
	cHtml += '	  </div>'+CRLF
	cHtml += '  </div>'+CRLF

	TMPSC6->( dbCloseArea() )

	/**/

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-list-alt fa-1x"></i> Pedido de Compras em Aberto</H3>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '	<div  class="col-md-12" style="overflow-x:auto; width=100%; overflow-y:auto;">'+CRLF

	cHtml += '    <div class="form-group" style="max-height:300px; ">'+CRLF
	cHtml += '    	<table id="table" class="table table-bordered table-striped table-condensed col-md-12">'+CRLF
	cHtml += '    		<thead>'+CRLF
	cHtml += '      		<tr>'+CRLF
	cHtml += '		  			<th>Filial</th>'+CRLF
	cHtml += '        			<th>Pedido</th>'+CRLF
	cHtml += '        			<th>Item</th>'+CRLF
	cHtml += '        			<th>Descrição</th>'+CRLF
	cHtml += '        			<th>Quantidade</th>'+CRLF
	cHtml += '        			<th>Preço</th>'+CRLF
	cHtml += '        			<th>Valor</th>'+CRLF
	cHtml += '        			<th>TES</th>'+CRLF
	cHtml += '        			<th>Emissão</th>'+CRLF
	cHtml += '        			<th>Entrega</th>'+CRLF
	cHtml += '        			<th>Fornecedor</th>'+CRLF
	cHtml += '      		</tr>'+CRLF
	cHtml += '    		</thead>'+CRLF
	cHtml += '			<tbody>'+CRLF
	
	cQuery := "SELECT C7_FILIAL, C7_NUM, C7_ITEM, C7_DESCRI, C7_QUANT, C7_PRECO, C7_TOTAL, C7_TES, C7_EMISSAO, C7_DATPRF, A2_NOME " + CRLF
	cQuery += "FROM " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SA2") + " AS SA2 WITH (NOLOCK) ON A2_FILIAL = '" + xFilial("SA2") + "' " + CRLF
	cQuery += "  AND A2_COD = C7_FORNECE " + CRLF
	cQuery += "  AND A2_LOJA = C7_LOJA " + CRLF
	cQuery += "  AND SA2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C7_FILIAL = '" + xFilial("SC7") + "' " + CRLF
	cQuery += "AND C7_PRODUTO = '" + SB1->B1_COD + "' " + CRLF
	cQuery += "AND C7_QUANT > C7_QUJE " + CRLF
	cQuery += "AND SC7.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY C7_NUM DESC, C7_ITEM " + CRLF

	TCQuery cQuery New Alias "TMPSC6"
	dbSelectArea("TMPSC6")
	TMPSC6->( dbGoTop() )

	Do While !TMPSC6->( Eof() )
		cHtml += '				<tr>'+CRLF
		cHtml += '        			<td>'+TMPSC6->C7_FILIAL+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSC6->C7_NUM+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSC6->C7_ITEM+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSC6->C7_DESCRI+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(TMPSC6->C7_QUANT,PesqPict("SC7","C7_QUANT"))+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(TMPSC6->C7_PRECO,PesqPict("SC7","C7_PRECO"))+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(TMPSC6->C7_TOTAL,PesqPict("SC7","C7_TOTAL"))+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSC6->C7_TES+'</td>'+CRLF
		cHtml += '        			<td>'+DTOC(STOD(TMPSC6->C7_EMISSAO))+'</td>'+CRLF
		cHtml += '        			<td>'+DTOC(STOD(TMPSC6->C7_DATPRF))+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSC6->A2_NOME+'</td>'+CRLF
		cHtml += '      		</tr>'+CRLF

		TMPSC6->( dbSkip() )
	EndDo

	cHtml += '    		</tbody>'+CRLF
	cHtml += '  	</table>'+CRLF
	cHtml += '	  </div>'+CRLF
	cHtml += '  </div>'+CRLF

	TMPSC6->( dbCloseArea() )
	/**/

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-list-ul fa-1x"></i> Solicitação de Compras em Aberto</H3>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '	<div  class="col-md-12" style="overflow-x:auto; width=100%; overflow-y:auto;">'+CRLF

	cHtml += '    <div class="form-group" style="max-height:300px; ">'+CRLF
	cHtml += '    	<table id="table" class="table table-bordered table-striped table-condensed col-md-12">'+CRLF
	cHtml += '    		<thead>'+CRLF
	cHtml += '      		<tr>'+CRLF
	cHtml += '		  			<th>Filial</th>'+CRLF
	cHtml += '        			<th>Solicitação</th>'+CRLF
	cHtml += '        			<th>Item</th>'+CRLF
	cHtml += '        			<th>Descrição</th>'+CRLF
	cHtml += '        			<th>Quantidade</th>'+CRLF
	cHtml += '        			<th>Preço</th>'+CRLF
	cHtml += '        			<th>Valor</th>'+CRLF
	cHtml += '        			<th>Emissão</th>'+CRLF
	cHtml += '        			<th>Entrega</th>'+CRLF
	cHtml += '        			<th>Fornecedor</th>'+CRLF
	cHtml += '      		</tr>'+CRLF
	cHtml += '    		</thead>'+CRLF
	cHtml += '			<tbody>'+CRLF
	
	cQuery := "SELECT C1_FILIAL, C1_NUM, C1_ITEM, C1_DESCRI, C1_QUANT, C1_PRECO, C1_TOTAL, C1_EMISSAO, C1_DATPRF, ISNULL(A2_NOME, '') AS A2_NOME " + CRLF
	cQuery += "FROM " + RetSqlName("SC1") + " AS SC1 WITH (NOLOCK) " + CRLF
	cQuery += "LEFT JOIN " + RetSqlName("SA2") + " AS SA2 WITH (NOLOCK) ON A2_FILIAL = '" + xFilial("SA2") + "' " + CRLF
	cQuery += "  AND A2_COD = C1_FORNECE " + CRLF
	cQuery += "  AND A2_LOJA = C1_LOJA " + CRLF
	cQuery += "  AND SA2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C1_FILIAL = '" + xFilial("SC1") + "' " + CRLF
	cQuery += "AND C1_PRODUTO = '" + SB1->B1_COD + "' " + CRLF
	cQuery += "AND  C1_QUANT > C1_QUJE " + CRLF
	cQuery += "AND SC1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY C1_NUM DESC, C1_ITEM " + CRLF

	TCQuery cQuery New Alias "TMPSC6"
	dbSelectArea("TMPSC6")
	TMPSC6->( dbGoTop() )

	Do While !TMPSC6->( Eof() )
		cHtml += '				<tr>'+CRLF
		cHtml += '        			<td>'+TMPSC6->C1_FILIAL+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSC6->C1_NUM+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSC6->C1_ITEM+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSC6->C1_DESCRI+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(TMPSC6->C1_QUANT,PesqPict("SC7","C7_QUANT"))+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(TMPSC6->C1_PRECO,PesqPict("SC7","C7_PRECO"))+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(TMPSC6->C1_TOTAL,PesqPict("SC7","C7_TOTAL"))+'</td>'+CRLF
		cHtml += '        			<td>'+DTOC(STOD(TMPSC6->C1_EMISSAO))+'</td>'+CRLF
		cHtml += '        			<td>'+DTOC(STOD(TMPSC6->C1_DATPRF))+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSC6->A2_NOME+'</td>'+CRLF
		cHtml += '      		</tr>'+CRLF

		TMPSC6->( dbSkip() )
	EndDo

	cHtml += '    		</tbody>'+CRLF
	cHtml += '  	</table>'+CRLF
	cHtml += '	  </div>'+CRLF
	cHtml += '  </div>'+CRLF

	TMPSC6->( dbCloseArea() )
	/**/

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-hand-o-right fa-1x"></i> Ordem de Produção em Aberto</H3>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '	<div  class="col-md-12" style="overflow-x:auto; width=100%; overflow-y:auto;">'+CRLF

	cHtml += '    <div class="form-group" style="max-height:300px; ">'+CRLF
	cHtml += '    	<table id="table" class="table table-bordered table-striped table-condensed col-md-12">'+CRLF
	cHtml += '    		<thead>'+CRLF
	cHtml += '      		<tr>'+CRLF
	cHtml += '		  			<th>Filial</th>'+CRLF
	cHtml += '        			<th>Ordem Produção</th>'+CRLF
	cHtml += '        			<th>Item</th>'+CRLF
	cHtml += '        			<th>Sequência</th>'+CRLF
	cHtml += '        			<th>Local</th>'+CRLF
	cHtml += '        			<th>Quantidade</th>'+CRLF
	cHtml += '        			<th>Emissão</th>'+CRLF
	cHtml += '        			<th>Previsão</th>'+CRLF
	cHtml += '      		</tr>'+CRLF
	cHtml += '    		</thead>'+CRLF
	cHtml += '			<tbody>'+CRLF

	cQuery := "SELECT C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_LOCAL, C2_QUANT, C2_EMISSAO, C2_DATPRF " + CRLF
	cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
	cQuery += "AND C2_PRODUTO = '" + SB1->B1_COD + "' " + CRLF
	cQuery += "AND C2_QUANT > C2_QUJE " + CRLF
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY C2_NUM DESC, C2_ITEM, C2_SEQUEN " + CRLF

	TCQuery cQuery New Alias "TMPSC6"
	dbSelectArea("TMPSC6")
	TMPSC6->( dbGoTop() )

	Do While !TMPSC6->( Eof() )
		cHtml += '				<tr>'+CRLF
		cHtml += '        			<td>'+TMPSC6->C2_FILIAL+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSC6->C2_NUM+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSC6->C2_ITEM+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSC6->C2_SEQUEN+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSC6->C2_LOCAL+'</td>'+CRLF
		cHtml += '        			<td>'+Transform(TMPSC6->C2_QUANT,PesqPict("SC7","C7_QUANT"))+'</td>'+CRLF
		cHtml += '        			<td>'+DTOC(STOD(TMPSC6->C2_EMISSAO))+'</td>'+CRLF
		cHtml += '        			<td>'+DTOC(STOD(TMPSC6->C2_DATPRF))+'</td>'+CRLF
		cHtml += '      		</tr>'+CRLF

		TMPSC6->( dbSkip() )
	EndDo

	cHtml += '    		</tbody>'+CRLF
	cHtml += '  	</table>'+CRLF
	cHtml += '	  </div>'+CRLF
	cHtml += '  </div>'+CRLF

	TMPSC6->( dbCloseArea() )
	cHtml += '		<Hr>' + CRLF

	If HttpGet->nopc == "1"
		cHtml += '	  <div class="form-group col-md-12">'+CRLF
		cHtml += '    	<a href="U_BeP0206.apw" class="btn btn-default">Voltar</a>'+CRLF
		cHtml += '	  </div>'+CRLF
	ElseIf HttpGet->nopc == "2"
		cHtml += '	  <div class="form-group col-md-12">'+CRLF
		cHtml += '    	<a href="U_BeP0201.apw" class="btn btn-default">Voltar</a>'+CRLF
		cHtml += '	  </div>'+CRLF
	ElseIf HttpGet->nopc == "3"
		cHtml += '	  <div class="form-group col-md-12">'+CRLF
		cHtml += '    	<a href="U_BeP0202.apw" class="btn btn-default">Voltar</a>'+CRLF
		cHtml += '	  </div>'+CRLF
	ElseIf HttpGet->nopc == "4"
		cHtml += '	  <div class="form-group col-md-12">'+CRLF
		cHtml += '    	<a href="U_BeP0203.apw" class="btn btn-default">Voltar</a>'+CRLF
		cHtml += '	  </div>'+CRLF
	ElseIf HttpGet->nopc == "5"
		cHtml += '	  <div class="form-group col-md-12">'+CRLF
		cHtml += '    	<a href="U_BeP0204.apw" class="btn btn-default">Voltar</a>'+CRLF
		cHtml += '	  </div>'+CRLF
	Else
		cHtml += '	  <div class="form-group col-md-12">'+CRLF
		cHtml += '    	<a href="U_BeP0206.apw" class="btn btn-default">Voltar</a>'+CRLF
		cHtml += '    	<a href="U_BePIndex.apw" class="btn btn-default">Home</a>'+CRLF
		cHtml += '	  </div>'+CRLF
	EndIf
 
	cHtml += '  </form>'+CRLF
	cHtml += '</div>'+CRLF

Else
	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
EndIf
	
cHtml += Execblock("BePFooter",.F.,.F.)

WEB EXTENDED END

Return (EncodeUTF8(cHtml))
