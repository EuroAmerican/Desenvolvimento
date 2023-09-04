#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'

// Apresenta Tela de Modal de acordo com os Parametros
// Apresenta Modal 
//cPar1 = Mensagem Cabeçalho
//cPar2 = Mensagem no Corpo do Modal
//cPar3 = Função de Retorno do Modal

User Function BePModal()

Local cRet	:= ""

Local cMsgHdr 	:= PARAMIXB[1]
Local cMsgBody	:= PARAMIXB[2]
Local cRetFun 	:= PARAMIXB[3]

cHtml += '  <!-- Modal -->
cHtml += '  <div class="modal fade" id="myModal" role="dialog">
cHtml += '    <div class="modal-dialog">
cHtml += ''    
cHtml += '      <!-- Modal content-->
cHtml += '      <div class="modal-content">
cHtml += '        <div class="modal-header">
cHtml += '          <button onClick="Retornar()" type="button" class="close" data-dismiss="modal">&times;</button>
cHtml += '          <h4 class="modal-title">'+cMsgHdr+'</h4>
cHtml += '        </div>
cHtml += '        <div class="modal-body">
cHtml += '          <p>'+cMsgBody+'</p>'
cHtml += '        </div>'
cHtml += '        <div class="modal-footer">'
cHtml += '         	<button onClick="Retornar()" type="button" class="btn btn-default" data-dismiss="modal" type="submit">Ok</button>'
cHtml += '        </div>'          
cHtml += '      </div>'
cHtml += '    </div>'
cHtml += '  </div>'	
cHtml += '</div>'
cHtml += '<script type="text/javascript"> $("#myModal").modal("show")</script>'
cHtml += '<script>function Retornar() {
cHtml += '	window.parent.location = "'+cRetFun+'"'
cHtml += '}'
cHtml += '</script>'
cHtml += '<script>
//cHtml += '$(document).ready(function(){
//cHtml += '        $("#myModal").on("hidden.bs.modal", function () {
//cHtml += '            window.parent.location = "u_portallog.apw";
//cHtml += '});
cHtml += '</script>

cHtml += Execblock("BePFooter",.F.,.F.)

Return cRet
