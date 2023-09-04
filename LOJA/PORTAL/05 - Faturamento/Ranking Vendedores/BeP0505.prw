#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

// Programa Inicial da Faturamento
User Function BeP0505()

Local cQuery	:= ""
Local cMsgHdr	:= ""
Local cMsgBody	:= ""
Local cRetfun	:= "u_BePLogin.apw"
Local lSession 	:= Execblock("BePVSess",.F.,.F.) // Valida Sessão

Private cHtml 	:= ""    

WEB EXTENDED INIT cHtml

cHtml += Execblock("BePHeader",.F.,.F.)

If lSession 
	cHtml += Execblock("BePMenus",.F.,.F.)
	
	cHtml += '<div class="main" style="margin-top: 50px;">'
	cHtml += '	<h2><i class="fas fa-dolly"></i> Detalhes Por Nota Fiscal de Vendas por Vendedor</h2>'
	cHtml += '	<hr/>'

	dbSelectArea("SA3")
	dbSetOrder(1)
	If SA3->( dbSeek( xFilial("SA3") + HttpGet->codvend ) )
		cNomVend := AllTrim( SA3->A3_NOME )
	Else
		cNomVend := "Sem Vendedor Classificado"
	EndIf

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-pie-chart fa-1x"></i> Nome: ' + cNomVend + '</H3>'+CRLF
	cHtml += '    </div>'+CRLF

	//Table
	cHtml += '	<div  class="col-md-12" style="overflow-x:auto; width=100%; overflow-y:auto;">'+CRLF
	
	cQuery := "SELECT 'Normal' AS TIPO, D2_FILIAL, D2_DOC, D2_SERIE, D2_PEDIDO, '' AS D1_NFORI, '' AS D1_SERIORI, A1_NOME, SUM(D2_VALBRUT - D2_VALIPI - D2_VALICM - D2_VALIMP5 - D2_VALIMP6 - D2_DESPESA - D2_VALFRE - D2_DESCON - D2_SEGURO - D2_ICMSRET) AS TOTAL, SUM(D2_VALBRUT) AS BRUTO, ISNULL(SUM(D2_VALBRUT - D2_VALIPI - D2_ICMSRET), 0) AS BASECOM " + CRLF
	cQuery += "FROM " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF2") + " AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL " + CRLF
	cQuery += "  AND F2_DOC = D2_DOC " + CRLF
	cQuery += "  AND F2_SERIE = D2_SERIE " + CRLF
	cQuery += "  AND F2_CLIENTE = D2_CLIENTE " + CRLF
	cQuery += "  AND F2_LOJA = D2_LOJA " + CRLF
	cQuery += "  AND F2_TIPO = D2_TIPO " + CRLF
	cQuery += "  AND F2_EMISSAO = D2_EMISSAO " + CRLF
	cQuery += "  AND SF2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON F4_FILIAL = '" + XFILIAL("SF4") + "' " + CRLF
	cQuery += "  AND F4_CODIGO = D2_TES " + CRLF
	cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5124','6124','5919') " + CRLF
	cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SA1") + " AS SA1 WITH (NOLOCK) ON A1_FILIAL = D2_FILIAL " + CRLF
	cQuery += "  AND A1_COD = D2_CLIENTE " + CRLF
	cQuery += "  AND A1_LOJA = D2_LOJA " + CRLF
	cQuery += "  AND A1_EQ_PRRL <> '1' " + CRLF
	cQuery += "  AND SA1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE D2_FILIAL = '" + XFILIAL("SD2") + "' " + CRLF
	cQuery += "AND F2_VEND1 = '" + SA3->A3_COD + "' " + CRLF
	cQuery += "AND D2_TIPO = 'N' " + CRLF
	cQuery += "AND LEFT(D2_EMISSAO, 6) = '" + Left( DTOS( dDataBase ), 6) + "' " + CRLF
	cQuery += "AND SD2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY D2_FILIAL, D2_DOC, D2_SERIE, D2_PEDIDO, A1_NOME " + CRLF

	cQuery += "UNION ALL " + CRLF

	cQuery += "SELECT 'Devolução' AS TIPO, D1_FILIAL, D1_DOC, D1_SERIE, D2_PEDIDO, D1_NFORI, D1_SERIORI, A1_NOME, SUM((D1_TOTAL)) * (-1) AS TOTAL, SUM(D1_TOTAL) AS BRUTO, SUM(D1_TOTAL - D1_VALIPI - D1_ICMSRET) AS BASECOM " + CRLF
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
	cQuery += "  AND F2_VEND1 = '" + SA3->A3_COD + "' " + CRLF
	cQuery += "  AND SF2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON F4_FILIAL = '" + XFILIAL("SF4") + "' " + CRLF
	cQuery += "  AND F4_CODIGO = D2_TES " + CRLF
	cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
	cQuery += "  AND NOT F4_CF IN ('5929','6929','5124','6124','5919') " + CRLF
	cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SA1") + " AS SA1 WITH (NOLOCK) ON A1_FILIAL = D2_FILIAL " + CRLF
	cQuery += "  AND A1_COD = D2_CLIENTE " + CRLF
	cQuery += "  AND A1_LOJA = D2_LOJA " + CRLF
	cQuery += "  AND A1_EQ_PRRL <> '1' " + CRLF
	cQuery += "  AND SA1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE D1_FILIAL = '" + XFILIAL("SD1") + "' " + CRLF
	cQuery += "AND D1_TIPO = 'D' " + CRLF
	cQuery += "AND LEFT(D1_DTDIGIT, 6) = '" + Left( DTOS( dDataBase ), 6) + "' " + CRLF
	cQuery += "AND SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY D1_FILIAL, D1_DOC, D1_SERIE, D2_PEDIDO, D1_NFORI, D1_SERIORI, A1_NOME " + CRLF

	TCQuery cQuery New Alias "TMPNFS"
	dbSelectArea("TMPNFS")
	dbGoTop()

	cHtml += '    <div class="form-group" style="max-height:300px; ">'+CRLF
	cHtml += '    	<table id="table" class="table table-bordered table-striped table-condensed col-md-12">'+CRLF
	cHtml += '    		<thead>'+CRLF
	cHtml += '      		<tr>'+CRLF
	cHtml += '		  			<th>Tipo</th>'+CRLF
	cHtml += '        			<th>Filial</th>'+CRLF
	cHtml += '        			<th>Documento</th>'+CRLF
	cHtml += '        			<th>Série</th>'+CRLF
	cHtml += '        			<th>Pedido</th>'+CRLF //Vlr. Faturado
	cHtml += '        			<th>NF Origem</th>'+CRLF
	cHtml += '        			<th>Série Origem</th>'+CRLF //Fat - Dev
	cHtml += '        			<th>Cliente</th>'+CRLF //Fat - Dev
	cHtml += '        			<th>Base de Comissão</th>'+CRLF
	cHtml += '        			<th>Valor Bruto</th>'+CRLF
	cHtml += '        			<th>Total</th>'+CRLF
	cHtml += '      		</tr>'+CRLF
	cHtml += '    		</thead>'+CRLF
	cHtml += '			<tbody>'+CRLF

	nBruto    := 0
	nTotal    := 0
	nBaseCom  := 0

	Do While !TMPNFS->( Eof() )
		cHtml += '				<tr>'+CRLF
		cHtml += '        			<td>'+TMPNFS->TIPO+'</td>'+CRLF
		cHtml += '        			<td>'+TMPNFS->D2_FILIAL+'</td>'+CRLF
		cHtml += '        			<td>'+TMPNFS->D2_DOC+'</td>'+CRLF
		cHtml += '        			<td>'+TMPNFS->D2_SERIE+'</td>'+CRLF
		cHtml += '        			<td>'+TMPNFS->D2_PEDIDO+'</td>'+CRLF
		cHtml += '        			<td>'+TMPNFS->D1_NFORI+'</td>'+CRLF
		cHtml += '        			<td>'+TMPNFS->D1_SERIORI+'</td>'+CRLF
		cHtml += '        			<td>'+TMPNFS->A1_NOME+'</td>'+CRLF
		cHtml += '        			<td style="text-align: right;">'+Transform(TMPNFS->BASECOM,PesqPict("SB2","B2_VATU1"))+'</td>'+CRLF
		cHtml += '        			<td style="text-align: right;">'+Transform(TMPNFS->BRUTO,PesqPict("SB2","B2_VATU1"))+'</td>'+CRLF
		cHtml += '        			<td style="text-align: right;">'+Transform(TMPNFS->TOTAL,PesqPict("SB2","B2_VATU1"))+'</td>'+CRLF
		cHtml += '      		</tr>'+CRLF

		nBaseCom  += TMPNFS->BASECOM
		nBruto    += TMPNFS->BRUTO
		nTotal    += TMPNFS->TOTAL

		TMPNFS->( dbSkip() )
	EndDo

	TMPNFS->( dbCloseArea() )

	cHtml += '				<tr>'+CRLF
	cHtml += '        			<td><B>Total Geral:</B></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td></td>'+CRLF
	cHtml += '        			<td style="text-align: right;"><B>'+Transform(nBaseCom,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
	cHtml += '        			<td style="text-align: right;"><B>'+Transform(nBruto,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
	cHtml += '        			<td style="text-align: right;"><B>'+Transform(nTotal,PesqPict("SB2","B2_VATU1"))+'</B></td>'+CRLF
	cHtml += '      		</tr>'+CRLF

	cHtml += '    		</tbody>'+CRLF
	cHtml += '  	</table>'+CRLF
	cHtml += '	  </div>'+CRLF

	cHtml += '  </div>'+CRLF

	cHtml += '<HR>' + CRLF

	cHtml += '	  <div class="form-group col-md-12">'+CRLF
	cHtml += '    	<a href="U_BeP0504.apw" class="btn btn-default">Voltar</a>'+CRLF
	cHtml += '	  </div>'+CRLF

	cHtml += '	</div>'
	cHtml += '</div>'
	
Else	
	cMsgHdr		:= "BEP0505 - Sessão não Iniciada"
	cMsgBody	:= "A sessão não foi iniciada, realize o Login!"

	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun})
EndIf

cHtml += Execblock("BePFooter",.F.,.F.)

WEB EXTENDED END
	
Return (EncodeUTF8(cHtml))
