#include "protheus.ch"
#include "TopConn.ch"

// Programa de Pesquisa Padrão Via Modal
User Function BePModF3(cIdMod, aIdCpos, cIdBtn, cTabela, aCampos, aCposRet, cFiltro)

Local cQuery 	:= ""
Local nX	 	:= 0
Local nCpos		:= Len(aCampos)
Local cRet		:= ""
Local cCpos		:= ""
Local cAlias	:= GetNextAlias()
Local cIdCpos	:= ""
Local cCposRet	:= ""

For nX := 1 to nCpos
	cCpos += aCampos[nX]+", "
Next nX

cCpos := Left(cCpos,Len(cCpos)-2)

cQuery += "SELECT "+cCpos+" "+CRLF
cQuery += "FROM "+RetSqlName(cTabela)+" AS "+cTabela+CRLF
cQuery += "WHERE "+CRLF
If !Empty(cFiltro)
	cQuery += Alltrim(cFiltro)+" "+CRLF
	cQuery += "AND "+CRLF
EndIf
cQuery += cTabela+".D_E_L_E_T_ = '' "+CRLF
cQuery += "ORDER BY "+cCpos

TcQuery cQuery new alias (cAlias)

//
cRet += '<!-- Modal -->'+CRLF
cRet += '<div class="modal fade" id="'+cIdMod+'" role="dialog">'+CRLF
cRet += '	<div class="modal-dialog">'+CRLF
cRet += '	'+CRLF    
cRet += '   	<!-- Modal content-->'+CRLF
cRet += '   	<div class="modal-content">'+CRLF
cRet += '       	<div class="modal-header">'+CRLF
cRet += '          		<button type="button" class="close" data-dismiss="modal">&times;</button>'+CRLF
cRet += '          		<h4 class="modal-title">Consulta Padrão</h4>'+CRLF
cRet += '        	</div>'+CRLF

// Body Modal
cRet += '			<div  class="modal-body col-md-12" style="overflow-x:auto; width=100%; overflow-y:auto;">'+CRLF
cRet += '    			<div class="form-group" style="max-height:300px; width=100%  ">'+CRLF
cRet += '    				<table align="center" id="'+cTabela+'" class="table table-bordered table-striped table-condensed col-md-12">'+CRLF
cRet += '    					<thead >'+CRLF
cRet += '      						<tr>'+CRLF
    
For nX := 1 to Len(aCampos)
	
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek(aCampos[nX])
	
	cRet += '		  						<th>'+X3Titulo()+'</th>'+CRLF

Next nX	

cRet += '      						</tr>'+CRLF
cRet += '    					</thead>'+CRLF
cRet += '						<tbody>'+CRLF

Do While !(cAlias)->(Eof())
	
	cIdCpos 	:= ""
	cCposRet	:= ""

	For nY := 1 to Len(aIdCpos)
		cIdCpos 	+= aIdCpos[nY]+";"
		cCposRet	+= (cAlias)->&(aCposRet[nY])+";"
	Next nY
	
	//cRet += '						<tr ondblclick="upd'+cTabela+'('+"'"+cCposRet+"','"+cIdCpos+"'"+')">'+CRLF 
	cRet += '						<tr>'+CRLF 

	For nX := 1 to Len(aCampos)
		dbSelectArea("SX3")
		dbSetOrder(2)
		dbSeek(aCampos[nX])

		If AllTrim( SX3->X3_TIPO ) == "D"
			cRet += '        						<td nowrap align="center"><a href="javascript:upd'+cTabela+'('+"'"+cCposRet+"','"+cIdCpos+"'"+')">'+DTOC(STOD((cAlias)->&(aCampos[nX])))+'</a></td>'+CRLF
		ElseIf AllTrim( SX3->X3_TIPO ) == "N"
			cRet += '        						<td nowrap align="right"><a href="javascript:upd'+cTabela+'('+"'"+cCposRet+"','"+cIdCpos+"'"+')">'+Transform((cAlias)->&(aCampos[nX]),"@R 999,999,999.99")+'</a></td>'+CRLF
		Else
			cRet += '        						<td nowrap align="left"><a href="javascript:upd'+cTabela+'('+"'"+cCposRet+"','"+cIdCpos+"'"+')">'+(cAlias)->&(aCampos[nX])+'</a></td>'+CRLF
		EndIf
	Next nX
	
	cRet += '      					</a></tr>'+CRLF
	
	(cAlias)->(dbSkip())
EndDo

cRet += '    					</tbody>'+CRLF
cRet += '  					</table>'+CRLF
cRet += '	  			</div>'+CRLF
cRet += '  			</div>'+CRLF
cRet += '        	<div class="modal-footer">'+CRLF
cRet += '         		<button type="button" class="btn btn-default" data-dismiss="modal" >Sair</button>'+CRLF
cRet += '       	</div>'+CRLF
cRet += '   	</div>'+CRLF
cRet += '	</div>'+CRLF
cRet += '</div>'+CRLF

cRet += '<script>'+CRLF
cRet += '$(document).ready(function(){'+CRLF
cRet += '    $("#'+cIdBtn+'").click(function(){'+CRLF
cRet += '        $("#'+cIdMod+'").modal();'+CRLF
cRet += '	});'+CRLF
cRet += '});'+CRLF

cRet += 'function upd'+cTabela+'(cCodRet, cIdCpos){'+CRLF
cRet += '   $("#'+cIdMod+'").modal("hide");'+CRLF
cRet += '	var aRet = cCodRet.split(";")'+CRLF
cRet += '	var aCampos = cIdCpos.split(";");'+CRLF
cRet += '	for(i=0; i<aCampos.length;i++){'+CRLF
cRet += '		document.getElementById(aCampos[i]).value = aRet[i];'+CRLF
cRet += '		document.getElementById(aCampos[i]).focus();'+CRLF
cRet += '   } '+CRLF
cRet += '};'+CRLF            
cRet += '</script>'+CRLF


cRet += '<script type="text/javascript" class="init">'+CRLF
cRet += '$(document).ready(function() {'+CRLF
cRet += '    $("#'+cTabela+'").DataTable( {'+CRLF
cRet += '        responsive: {'+CRLF
cRet += '            details: {'+CRLF
cRet += '                display: $.fn.dataTable.Responsive.display.modal( {'+CRLF
cRet += '                    header: function ( row ) {'+CRLF
cRet += '                        var data = row.data();'+CRLF
cRet += '                        return "Details for "+data[0]+" "+data[1];'+CRLF
cRet += '                    }'+CRLF
cRet += '                } ),'+CRLF
cRet += '                renderer: $.fn.dataTable.Responsive.renderer.tableAll( {'+CRLF
cRet += '                    tableClass: "table"'+CRLF
cRet += '                } )'+CRLF
cRet += '            }'+CRLF
cRet += '        }'+CRLF
cRet += '    } );'+CRLF
cRet += '} );'+CRLF
cRet += '</script>'+CRLF

Return cRet