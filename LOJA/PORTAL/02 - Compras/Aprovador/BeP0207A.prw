#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

User Function BeP0207A()

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

Private cHtml 	:= ""    

WEB EXTENDED INIT cHtml                               

cHtml += Execblock("BePHeader",.F.,.F.)

If lSession

	cHtml += Execblock("BePMenus",.F.,.F.)

	cHtml += '<div class="main col-md-12" style="margin-top: 50px">'
	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '  <h2><i class="fa-id-card-o"></i> Subordinado - Ausencia Temporária</h2>'+CRLF
	cHtml += '  <hr/>'+CRLF
	cHtml += '	<p></p>
	cHtml += '    </div>'+CRLF
	cHtml += '  <form method="POST" id="formpc" action="u_bep0207B.apw" class="col-md-12" style="margin-bottom: 10px;">'+CRLF
	
	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Código:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codapr" name="codapr" value="'+HttpGet->codapr+'" readonly>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="pwd">Usuário:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="codusr" name="codusr" value="'+HttpGet->codusr+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	cHtml += '    <div class="form-group col-md-4">'+CRLF
	cHtml += '      <label for="email">Nome:</label>'+CRLF
	cHtml += '      <input type="text" class="form-control" id="nome" name="nome" value="'+HttpGet->nome+'" disabled>'+CRLF
	cHtml += '    </div>'+CRLF

	//Table
	cHtml += '	<div  class="col-md-12" style="overflow-x:auto; width=100%; overflow-y:auto;">'+CRLF

	cHtml += '    <div class="form-group" style="max-height:300px; ">'+CRLF
	cHtml += '    	<table id="table" class="table table-bordered table-striped table-condensed col-md-12">'+CRLF
	cHtml += '    		<thead>'+CRLF
	cHtml += '      		<tr>'+CRLF
	cHtml += '		  			<th>Filial</th>'+CRLF
	cHtml += '        			<th>Tipo</th>'+CRLF
	cHtml += '        			<th>Número</th>'+CRLF
	cHtml += '        			<th>Usuário</th>'+CRLF
	cHtml += '      		</tr>'+CRLF
	cHtml += '    		</thead>'+CRLF
	cHtml += '			<tbody>'+CRLF
	
	cQuery := "SELECT CR_FILIAL, CR_TIPO, CR_NUM, CR_USER, R_E_C_N_O_ " + CRLF
	cQuery += "FROM " + RetSqlName("SCR") + " AS SCR WITH (NOLOCK) " + CRLF
	cQuery += "WHERE CR_FILIAL = '" + xFilial("SCR") + "' " + CRLF
	cQuery += "AND CR_APROV = '" + HttpGet->codapr + "' " + CRLF
	cQuery += "AND (CR_STATUS='02' OR CR_STATUS='04') " + CRLF
	cQuery += "AND SCR.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPSCR"
	dbSelectArea("TMPSCR")
	TMPSCR->( dbGoTop() )

	Do While !TMPSCR->( Eof() )
		cHtml += '				<tr>'+CRLF
		cHtml += '        			<td>'+TMPSCR->CR_FILIAL+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSCR->CR_TIPO+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSCR->CR_NUM+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSCR->CR_USER+'</td>'+CRLF
		cHtml += '      		</tr>'+CRLF

		TMPSCR->( dbSkip() )
	EndDo

	TMPSCR->( dbCloseArea() )

	cHtml += '    		</tbody>'+CRLF
	cHtml += '  	</table>'+CRLF
	cHtml += '	  </div>'+CRLF
	cHtml += '  </div>'+CRLF

	cHtml += '	  <div class="form-group col-md-12">'+CRLF
	cHtml += '    	<button type="submit" class="btn btn-default">Confirmar</button>'+CRLF
	cHtml += '    	<a href="U_BeP0207.apw" class="btn btn-default">Voltar</a>'+CRLF
	cHtml += '	  </div>'+CRLF

	cHtml += '  </form>'+CRLF
	cHtml += '</div>'+CRLF
Else
	cMsgHdr		:= "BEP0207 - Sessão não Iniciada"
	cMsgBody	:= "A sessão não foi iniciada, realize o Login!"
	cRetFun		:= "u_BePLogin.apw"
	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
EndIf
	
cHtml += Execblock("BePFooter",.F.,.F.)

WEB EXTENDED END

Return (EncodeUTF8(cHtml))
