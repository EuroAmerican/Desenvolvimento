#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

// Programa Inicial da Liberação do Contrato de Parcerias
User Function BeP0202()

Local cQuery	:= ""
Local cAlias	:= GetNextAlias()
Local cMsgHdr	:= ""
Local cMsgBody	:= ""
Local cRetfun	:= "u_BePLogin.apw"
Local lSession 	:= Execblock("BePVSess",.F.,.F.) // Valida Sessão
Local lSuperior := .F.

Private cHtml 	:= ""    

WEB EXTENDED INIT cHtml                               

cHtml += Execblock("BePHeader",.F.,.F.)

If lSession 
	dbSelectArea("SAK")
	dbSetOrder(2)
	dbSeek(xFilial("SAK")+Alltrim(HttpSession->ccodusr))

	If !Empty( SAK->AK_APROSUP )
		lSuperior := .T.
	EndIf

	If Select(cAlias) <> 0
		(cAlias)->( dbCloseArea() )
	EndIf

	cQuery += "SELECT C3_FILIAL, C3_NUM, C3_USER, CR_USER, AK_NOME, CR_APROV, AL_COD, AL_DESC, CR_NIVEL, CR_EMISSAO, C3_FORNECE, C3_LOJA, C3_CONTATO " + CRLF
	cQuery += "FROM " + RetSqlName("SCR") + " AS SCR WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SC3") + " AS SC3 WITH (NOLOCK) ON C3_FILIAL = CR_FILIAL " + CRLF
	cQuery += "  AND C3_NUM = CR_NUM " + CRLF
	cQuery += "  AND C3_ENCER <> 'E' " + CRLF
	cQuery += "  AND C3_RESIDUO <> 'S' " + CRLF
	cQuery += "  AND SC3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SAL") + " AS SAL WITH (NOLOCK) ON AL_FILIAL = '" + xFilial("SAL") + "' " + CRLF
	cQuery += "  AND AL_COD = C3_APROV " + CRLF
	cQuery += "  AND AL_USER = CR_USER  " + CRLF
	cQuery += "  AND SAL.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SAK") + " AS SAK WITH (NOLOCK) ON AK_FILIAL = '" + xFilial("SAK") + "' " + CRLF
	cQuery += "  AND AK_USER = CR_USER " + CRLF
	cQuery += "  AND AK_COD = CR_APROV " + CRLF
	cQuery += "  AND SAK.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE CR_FILIAL <> '**' " + CRLF
	cQuery += "AND CR_STATUS = '02' " + CRLF    //-- Status da Aprovação {01 - Nível Bloqueado ; 02 - Aguardando Liberação ; 03 - Liberado ; 04 - Reprovado} 
	cQuery += "AND CR_TIPO = 'CP' " + CRLF     //-- Tipo do Documento   {PC – Pedido de Compras ; AE – Autorização de Entrega ; **CC – Cartão Corporativo ; **A1 – Cad. Clientes ; **A2 – Cad. Fornecedores ; **A3 – Cad. Vendedores ; **A4 – Cad. Transportadora ; **B1 – Cad. Produtos ; **ED – Cad. Naturezas } "
	cQuery += "AND CR_USER = '" + HttpSession->ccodusr + "' " + CRLF //-- Id do Usuário "
	cQuery += "AND SCR.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY C3_FILIAL, C3_NUM, C3_USER, CR_USER, AK_NOME, CR_APROV, AL_COD, AL_DESC, CR_NIVEL, CR_EMISSAO, C3_FORNECE, C3_LOJA, C3_CONTATO " + CRLF
	cQuery += "ORDER BY C3_FILIAL, C3_NUM " + CRLF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa Query														   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TcQuery cQuery NEW ALIAS (cAlias)
	
	cHtml += Execblock("BePMenus",.F.,.F.)
	
	cHtml += '<div class="main" style="margin-top: 50px;">'
	cHtml += '	<h2><i class="fa fa-gavel fa-1x"></i> Liberação Contrato de Parcerias</h2>'
	cHtml += '	<hr/>'
	cHtml += '	<p></p>
	cHtml += '	<div style="overflow-x:auto; width=100%; max-height:300px; overflow-y:auto">'
	cHtml += '  	<table id="tblscr" class="table table-striped">
	cHtml += '    		<thead>
	cHtml += '      		<tr>
	cHtml += '		  			<th>Ações</th>
	cHtml += '        			<th>Filial</th>
	cHtml += '        			<th>Contrato</th>
	cHtml += '        			<th>Comprador</th>
	cHtml += '        			<th>Aprovador</th>
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
		cHtml += '    						<li><a href="u_bep0202A.apw?filexc='+(cAlias)->C3_FILIAL+'&numped='+(cAlias)->C3_NUM+'&grpapr='+(cAlias)->AL_COD+'&codaprov='+(cAlias)->CR_USER+'&nivel='+(cAlias)->CR_NIVEL+'&nopc=1">Visualizar</a></li>
		cHtml += '    						<li><a href="u_bep0202A.apw?filexc='+(cAlias)->C3_FILIAL+'&numped='+(cAlias)->C3_NUM+'&grpapr='+(cAlias)->AL_COD+'&codaprov='+(cAlias)->CR_USER+'&nivel='+(cAlias)->CR_NIVEL+'&nopc=2">Liberar</a></li>
		If lSuperior
			cHtml += '    						<li><a href="u_bep0202A.apw?filexc='+(cAlias)->C3_FILIAL+'&numped='+(cAlias)->C3_NUM+'&grpapr='+(cAlias)->AL_COD+'&codaprov='+(cAlias)->CR_USER+'&nivel='+(cAlias)->CR_NIVEL+'&superior='+SAK->AK_APROSUP+'&nopc=3">Tranferir Superior</a></li>
		EndIf
		cHtml += '    						<li><a href="u_bep0205A.apw?filexc='+(cAlias)->C3_FILIAL+'&codfor='+(cAlias)->C3_FORNECE+'&lojfor='+(cAlias)->C3_LOJA+'&nopc=2">Consultar Fornecedor</a></li>
		cHtml += '  					</ul>
		cHtml += '					</div>
		cHtml += '				</td>
		cHtml += '        		<td>'+(cAlias)->C3_FILIAL+'</td>'
		cHtml += '        		<td>'+(cAlias)->C3_NUM+'</td>'
		cHtml += '        		<td nowrap>'+UsrRetName((cAlias)->C3_USER)+'</td>'
		cHtml += '        		<td nowrap>'+(cAlias)->AK_NOME+'</td>'
		cHtml += '        		<td nowrap>'+(cAlias)->C3_CONTATO+'</td>'
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
	cHtml += '      	</tr>
	cHtml += '      	<tr>
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
	cMsgHdr		:= "BEP0202 - Sessão não Iniciada"
	cMsgBody	:= "A sessão não foi iniciada, realize o Login!"

	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 

EndIf

cHtml += Execblock("BePFooter",.F.,.F.)

WEB EXTENDED END
	
Return (EncodeUTF8(cHtml))