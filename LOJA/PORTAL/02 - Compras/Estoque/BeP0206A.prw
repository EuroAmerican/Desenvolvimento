#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

User Function BeP0206A()

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
Local cFilTipo  := ""
Local cFilGrupo := ""
Local cFilProd  := ""

Private cHtml 	:= ""    

WEB EXTENDED INIT cHtml                               

cHtml += Execblock("BePHeader",.F.,.F.)

If lSession

	cHtml += Execblock("BePMenus",.F.,.F.)

	If HttpPost->opttipo <> Nil
		If HttpPost->opttipo == "1"
			cFilTipo := "AND B1_TIPO = 'PA' "
		ElseIf HttpPost->opttipo == "2"
			cFilTipo := "AND B1_TIPO = 'PI' "
		ElseIf HttpPost->opttipo == "3"
			cFilTipo := "AND B1_TIPO = 'MP' "
		ElseIf HttpPost->opttipo == "4"
			cFilTipo := "AND B1_TIPO = 'EM' "
		ElseIf HttpPost->opttipo == "5"
			cFilTipo := "AND B1_TIPO = 'ME' "
		ElseIf HttpPost->opttipo == "6"
			cFilTipo := "AND B1_TIPO = 'MC' "
		ElseIf HttpPost->opttipo == "7"
			cFilTipo := "AND B1_TIPO = 'KT' "
		Else
			cFilTipo := "AND B1_TIPO IN ('PA','PI','MP','EM','ME','MC','KT') "
		EndIf
	Else
		cFilTipo := "AND B1_TIPO IN ('PA','PI','MP','EM','ME','MC','KT') "
	EndIf

	If HttpPost->codsbm <> Nil
		If !Empty( HttpPost->codsbm )
			cFilGrupo := "AND B1_GRUPO = '" + AllTrim( HttpPost->codsbm ) + "' "
		Else
			cFilGrupo := "AND B1_GRUPO <> '' "
		EndIf
	Else
		cFilGrupo := "AND B1_GRUPO <> '' "
	EndIf

	cHtml += '<div class="main col-md-12" style="margin-top: 50px">'
	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '  <h2><i class="far fa-ballot-check"></i> Análise de Estoque de Produto</h2>'+CRLF
	cHtml += '  <hr/>'+CRLF

	cHtml += '	<p></p>
	cHtml += '    </div>'+CRLF
	
	cQuery := "SELECT B1_COD, B1_DESC, B1_TIPO, B1_GRUPO, B1_UM, B1_SEGUM, B1_CONV, B1_RASTRO, B1_LOCALIZ " + CRLF
	cQuery += "FROM " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	If !Empty( cFilProd )
		cQuery += cFilProd + CRLF
	EndIf
	cQuery += "AND B1_MSBLQL <> '1' " + CRLF
	cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("SB2") + " WITH (NOLOCK) WHERE B2_FILIAL = '" + xFilial("SB2") + "' AND B2_COD = B1_COD AND B2_LOCAL <> '' AND D_E_L_E_T_ = ' ') " + CRLF
	If !Empty( cFilTipo )
		cQuery += cFilTipo + CRLF
	EndIf
	If !Empty( cFilGrupo )
		cQuery += cFilGrupo + CRLF
	EndIf
	cQuery += "AND SB1.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPSB1"
	dbSelectArea("TMPSB1")
	TMPSB1->( dbGoTop() )

	cHtml += '    <div class="form-group col-md-12">'+CRLF
	cHtml += '        <H3><i class="fa fa-building fa-1x"></i> Produtos</H3>'+CRLF
	cHtml += '    </div>'+CRLF

	//Table
	cHtml += '	<div  class="col-md-12" style="overflow-x:auto; width=100%; overflow-y:auto;">'+CRLF

	cHtml += '    <div class="form-group" style="max-height:300px; ">'+CRLF
	cHtml += '    	<table id="table" class="table table-bordered table-striped table-condensed col-md-12">'+CRLF
	cHtml += '    		<thead>'+CRLF
	cHtml += '      		<tr>'+CRLF
	cHtml += '		  			<th>Ações</th>
	cHtml += '		  			<th>Código</th>'+CRLF
	cHtml += '        			<th>Descrição</th>'+CRLF
	cHtml += '        			<th>Tipo</th>'+CRLF
	cHtml += '        			<th>Grupo</th>'+CRLF
	cHtml += '        			<th>U.M.</th>'+CRLF
	cHtml += '        			<th>Seg. U.M.</th>'+CRLF
	cHtml += '        			<th>Fator</th>'+CRLF
	cHtml += '        			<th>Rastro?</th>'+CRLF
	cHtml += '        			<th>Endereço?</th>'+CRLF
	cHtml += '      		</tr>'+CRLF
	cHtml += '    		</thead>'+CRLF
	cHtml += '			<tbody>'+CRLF
	
	Do While !TMPSB1->( Eof() )
		cHtml += '				<tr>'+CRLF
		cHtml += '					<td>'
		cHtml += '						<div class="btn-group">'
		cHtml += ' 							<button type="button" class="btn btn-sm dropdown-toggle" data-toggle="dropdown">'
		cHtml += '    							<span class="caret"></span>'
		cHtml += '    							<span class="sr-only">Toggle Dropdown</span>'
		cHtml += '  						</button>'
		cHtml += '  						<ul class="dropdown-menu" role="menu">
		cHtml += '    							<li><a href="u_bep0206B.apw?codpro='+TMPSB1->B1_COD+'&nopc=1">Consultar Produto</a></li>
		cHtml += '  						</ul>
		cHtml += '						</div>
		cHtml += '					</td>
		cHtml += '        			<td>'+TMPSB1->B1_COD+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSB1->B1_DESC+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSB1->B1_TIPO+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSB1->B1_GRUPO+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSB1->B1_UM+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSB1->B1_SEGUM+'</td>'+CRLF
		cHtml += '        			<td>'+AllTrim(Str(TMPSB1->B1_CONV))+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSB1->B1_RASTRO+'</td>'+CRLF
		cHtml += '        			<td>'+TMPSB1->B1_LOCALIZ+'</td>'+CRLF
		cHtml += '      		</tr>'+CRLF

		TMPSB1->( dbSkip() )
	EndDo

	TMPSB1->( dbCloseArea() )

	cHtml += '    		</tbody>'+CRLF
	cHtml += '  	</table>'+CRLF
	cHtml += '	  </div>'+CRLF
	cHtml += '  </div>'+CRLF

	cHtml += '		<Hr>' + CRLF

	cHtml += '	  <div class="form-group col-md-12">'+CRLF
	cHtml += '    	<a href="U_BeP0206.apw" class="btn btn-default">Voltar</a>'+CRLF
	cHtml += '	  </div>'+CRLF

	cHtml += '  </form>'+CRLF
	cHtml += '</div>'+CRLF
Else
	cMsgHdr		:= "BEP0206A - Sessão não Iniciada"
	cMsgBody	:= "A sessão não foi iniciada, realize o Login!"
	cRetFun		:= "u_BePLogin.apw"

	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
EndIf
	
cHtml += Execblock("BePFooter",.F.,.F.)

WEB EXTENDED END

Return (EncodeUTF8(cHtml))
