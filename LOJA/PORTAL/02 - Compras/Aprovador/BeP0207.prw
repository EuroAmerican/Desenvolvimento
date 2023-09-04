#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

// Programa Inicial Subordinados
User Function BeP0207()

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
	dbSelectArea("SAK")
	dbSetOrder(2)
	dbSeek(xFilial("SAK")+Alltrim(HttpSession->ccodusr))

	If Select(cAlias) <> 0
		(cAlias)->( dbCloseArea() )
	EndIf

	cQuery := "SELECT AK_FILIAL, AK_COD, AK_USER, AK_NOME, AK_LOGIN " + CRLF
	cQuery += "FROM " + RetSqlName("SAK") + " AS SAK WITH (NOLOCK) " + CRLF
	cQuery += "WHERE AK_FILIAL = '" + xFilial("SAK") + "' " + CRLF
	cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("SAK") + " WHERE AK_FILIAL = '" + xFilial("SAK") + "' AND AK_USER = '" + Alltrim( HttpSession->ccodusr ) + "' AND AK_COD = SAK.AK_APROSUP AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND SAK.D_E_L_E_T_ = ' ' " + CRLF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa Query														   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TcQuery cQuery NEW ALIAS (cAlias)
	
	cHtml += Execblock("BePMenus",.F.,.F.)
	
	cHtml += '<div class="main" style="margin-top: 50px;">'
	cHtml += '	<h2><i class="fas fa-chalkboard-teacher"></i> Aprovador: ' + AllTrim( SAK->AK_NOME ) + '</h2>'
	cHtml += '	<hr/>'
	cHtml += '	<p></p>
	cHtml += '	<div style="overflow-x:auto; width=100%; max-height:300px; overflow-y:auto">'

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-id-card fa-1x"></i> Subordinados</H3>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '  	<table id="tblscr" class="table table-striped">
	cHtml += '    		<thead>
	cHtml += '      		<tr>
	cHtml += '		  			<th>Ações</th>
	cHtml += '        			<th>Código</th>
	cHtml += '        			<th>Usuário</th>
	cHtml += '        			<th>Nome</th>
	cHtml += '        			<th>Login</th>
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
		cHtml += '    						<li><a href="u_bep0207A.apw?filexc='+(cAlias)->AK_FILIAL+'&codapr='+(cAlias)->AK_COD+'&codusr='+(cAlias)->AK_USER+'&nome='+(cAlias)->AK_NOME+'">Ausencia Temporária</a></li>
		cHtml += '  					</ul>
		cHtml += '					</div>
		cHtml += '				</td>
		cHtml += '        		<td nowrap>'+(cAlias)->AK_COD+'</td>'
		cHtml += '        		<td nowrap>'+(cAlias)->AK_USER+'</td>'
		cHtml += '        		<td nowrap>'+(cAlias)->AK_NOME+'</td>'
		cHtml += '        		<td nowrap>'+(cAlias)->AK_LOGIN+'</td>'
		cHtml += '      	</tr>
	
		(cAlias)->(dbSkip())
	EndDo
	
	cHtml += '      	<tr>
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
	cHtml += '      	</tr>

	cHtml += '    		</tbody>
	cHtml += '  	</table>
	cHtml += '	</div>'
	cHtml += '</div>'
	
Else	
	cMsgHdr		:= "BEP0207 - Sessão não Iniciada"
	cMsgBody	:= "A sessão não foi iniciada, realize o Login!"

	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 

EndIf

cHtml += Execblock("BePFooter",.F.,.F.)

WEB EXTENDED END
	
Return (EncodeUTF8(cHtml))