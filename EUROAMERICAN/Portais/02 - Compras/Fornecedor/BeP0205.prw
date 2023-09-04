#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

// Programa Inicial da Liberação do Pedido de Compra
User Function BeP0205()

Local cQuery	:= ""
Local cAlias	:= GetNextAlias()
Local cMsgHdr	:= ""
Local cMsgBody	:= ""
Local cRetfun	:= "u_BePLogin.apw"
Local lSession 	:= Execblock("BePVSess",.F.,.F.) // Valida Sessão

Private cHtml 	:= ""    

WEB EXTENDED INIT cHtml                               

cHtml += Execblock("BePHeader",.F.,.F.)

If lSession 

	If Select(cAlias) <> 0
		(cAlias)->( dbCloseArea() )
	EndIf

	cQuery += "SELECT A2_FILIAL, A2_COD, A2_LOJA, A2_NOME, A2_NREDUZ, A2_EST, A2_CGC, A2_TIPO, A2_CONTATO " + CRLF
	cQuery += "FROM " + RetSqlName("SA2") + " AS SA2 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE A2_FILIAL = '  ' " + CRLF
	cQuery += "AND A2_MSBLQL <> '1' " + CRLF
	/*
	cQuery += "AND (" + CRLF
	cQuery += "EXISTS (SELECT * FROM SD1020 WITH (NOLOCK) WHERE D1_FILIAL <> '**' AND D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND D1_DTDIGIT >= '20180531' AND EXISTS (SELECT * FROM SF4020 WHERE F4_FILIAL <> '**' AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' AND D_E_L_E_T_ = ' ') AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "OR " + CRLF
	cQuery += "EXISTS (SELECT * FROM SD1080 WITH (NOLOCK) WHERE D1_FILIAL <> '**' AND D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND D1_DTDIGIT >= '20180531' AND EXISTS (SELECT * FROM SF4080 WHERE F4_FILIAL <> '**' AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' AND D_E_L_E_T_ = ' ') AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "OR " + CRLF
	cQuery += "EXISTS (SELECT * FROM SD1060 WITH (NOLOCK) WHERE D1_FILIAL <> '**' AND D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND D1_DTDIGIT >= '20180531' AND EXISTS (SELECT * FROM SF4060 WHERE F4_FILIAL <> '**' AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' AND D_E_L_E_T_ = ' ') AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += ")" + CRLF
	*/
	cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("SD1") + " WITH (NOLOCK) WHERE D1_FILIAL <> '**' AND D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND D1_DTDIGIT >= '" + DTOS(dDataBase - 365) + "' AND EXISTS (SELECT * FROM " + RetSqlName("SF4") + " WHERE F4_FILIAL <> '**' AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' AND D_E_L_E_T_ = ' ') AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND SA2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY A2_COD, A2_LOJA " + CRLF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa Query														   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TcQuery cQuery NEW ALIAS (cAlias)
	
	cHtml += Execblock("BePMenus",.F.,.F.)
	
	cHtml += '<div class="main" style="margin-top: 50px;">'
	cHtml += '	<h2><i class="fas fa-chalkboard-teacher"></i> Fornecedores Ativos</h2>'
	cHtml += '	<hr/>'
	cHtml += '	<p></p>
	cHtml += '	<div style="overflow-x:auto; width=100%; max-height:300px; overflow-y:auto">'
	cHtml += '  	<table id="tblscr" class="table table-striped">
	cHtml += '    		<thead>
	cHtml += '      		<tr>
	cHtml += '		  			<th>Ações</th>
	cHtml += '        			<th>Código</th>
	cHtml += '        			<th>Loja</th>
	cHtml += '        			<th>Razão Social</th>
	cHtml += '        			<th>Fantasia</th>
	cHtml += '        			<th>Estado</th>
	cHtml += '        			<th>CNPJ/CPF</th>
	cHtml += '        			<th>Tipo</th>
	cHtml += '        			<th>Contato</th>
	cHtml += '      		</tr>
	cHtml += '    		</thead>
	cHtml += '			<tbody>
	
	dbSelectArea(cAlias)
	dbGoTop()
	
	Do While !(cAlias)->( Eof() )
	
		cHtml += '			<tr>'
		cHtml += '				<td>'
		cHtml += '					<div class="btn-group">'
		cHtml += ' 						<button type="button" class="btn btn-sm dropdown-toggle" data-toggle="dropdown">'
		cHtml += '    						<span class="caret"></span>'
		cHtml += '    						<span class="sr-only">Toggle Dropdown</span>'
		cHtml += '  					</button>'
		cHtml += '  					<ul class="dropdown-menu" role="menu">
		cHtml += '    						<li><a href="u_bep0205A.apw?filexc='+(cAlias)->A2_FILIAL+'&codfor='+(cAlias)->A2_COD+'&lojfor='+(cAlias)->A2_LOJA+'&nopc=5">Consultar Fornecedor</a></li>
		cHtml += '  					</ul>
		cHtml += '					</div>
		cHtml += '				</td>
		cHtml += '        		<td nowrap>'+(cAlias)->A2_COD+'</td>'
		cHtml += '        		<td nowrap>'+(cAlias)->A2_LOJA+'</td>'
		cHtml += '        		<td nowrap>'+(cAlias)->A2_NOME+'</td>'
		cHtml += '        		<td nowrap>'+(cAlias)->A2_NREDUZ+'</td>'
		cHtml += '        		<td nowrap>'+(cAlias)->A2_EST+'</td>'
		cHtml += '        		<td nowrap>'+(cAlias)->A2_CGC+'</td>'
		cHtml += '        		<td nowrap>'+(cAlias)->A2_TIPO+'</td>'
		cHtml += '        		<td nowrap>'+(cAlias)->A2_CONTATO+'</td>'
		cHtml += '      	</tr>
	
		(cAlias)->(dbSkip())
	EndDo
	
	cHtml += '      	<tr>
	cHtml += '      		<td></td>
	cHtml += '      		<td></td>
	cHtml += '      		<td></td>
	cHtml += '      		<td></td>
	cHtml += '      		<td></td>
	cHtml += '      		<td></td>
	cHtml += '      		<td></td>
	cHtml += '      		<td></td>
	cHtml += '      		<td></td>
	cHtml += '      	</tr>
	cHtml += '      	<tr>
	cHtml += '      		<td></td>
	cHtml += '      		<td></td>
	cHtml += '      		<td></td>
	cHtml += '      		<td></td>
	cHtml += '      		<td></td>
	cHtml += '      		<td></td>
	cHtml += '      		<td></td>
	cHtml += '      		<td></td>
	cHtml += '      		<td></td>
	cHtml += '      	</tr>

	cHtml += '    		</tbody>
	cHtml += '  	</table>
	cHtml += '	</div>'
	cHtml += '</div>'
	
Else	
	cMsgHdr		:= "BEP0205 - Sessão não Iniciada"
	cMsgBody	:= "A sessão não foi iniciada, realize o Login!"

	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 

EndIf

cHtml += Execblock("BePFooter",.F.,.F.)

WEB EXTENDED END
	
Return (EncodeUTF8(cHtml))