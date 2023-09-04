#include "protheus.ch"

// Função para montagem do Rodapé da Pagina Padrão
User Function BePFooter()

Local cRet 		:= ""
Local cNomeUsr	:= Iif(Valtype(HttpSession->username)<>"U",Capital(HttpSession->username),"")
Local cAmbAtu	:= Iif(Valtype(HttpSession->cEnvServer )<>"U",Capital(HttpSession->cEnvServer ),"")
Local dDtAtu	:=Iif(Valtype(HttpSession->cDataPC )<>"U",DtoC(HttpSession->cDataPC ),"")


/*cRet += '<div class="footer-bottom" style="background-color: #15224f;min-height: 15px;width: 100%;float:right;">
cRet += '	<div class="container">
cRet += '		<div class="row">
cRet += '			<div class="col-xs-12 col-sm-6 col-md-6 col-lg-6" style="widht:100%">
cRet += '				<div class="design" style="line-height: 15px;min-height: 15px;padding: 7px 0;text-align: right;">
cRet += '					<p style="color: #777;">Usuário: '+Alltrim(cNomeUsr)+'</p>'
cRet += '				</div>
cRet += '			</div>
cRet += '			<div class="col-xs-12 col-sm-6 col-md-6 col-lg-6" style="widht:100%">
cRet += '				<div class="design" style="line-height: 15px;min-height: 15px;padding: 7px 0;text-align: right;">
cRet += '					<p style="color: #777;">Data-Base: '+dDtAtu+'</p>'
cRet += '				</div>
cRet += '			</div>
cRet += '		</div>
cRet += '	</div>
cRet += '</div>
cRet += '<script type="text/javascript">'+CRLF
cRet += '$(document).ready(function() {'
cRet += ''
cRet += '   var docHeight = $(window).height();'
cRet += '   var footerHeight = $(".footer-bottom").height();'
cRet += '   var footerTop = $(".footer-bottom").position().top + footerHeight;
cRet += ' '
cRet += '   if (footerTop < docHeight) {
cRet += '    $(".footer-bottom").css("margin-top", 10+ (docHeight - footerTop) + "px");
cRet += '   }
cRet += '  });
cRet += '</script>
*/


cRet += '<script type="text/javascript">'+CRLF
cRet += '	function htmlbodyHeightUpdate(){'+CRLF
cRet += '		var height3 = $( window ).height()'+CRLF
cRet += '		var height1 = $(".nav").height()+50'+CRLF
cRet += '		height2 = $(".main").height()'+CRLF
cRet += '		if(height2 > height3){'+CRLF
cRet += '			$("html").height(Math.max(height1,height3,height2)+10);'+CRLF
cRet += '			$("body").height(Math.max(height1,height3,height2)+10);'+CRLF
cRet += '		}'+CRLF
cRet += '		else'+CRLF
cRet += '		{'+CRLF
cRet += '			$("html").height(Math.max(height1,height3,height2));'+CRLF
cRet += '			$("body").height(Math.max(height1,height3,height2));'+CRLF
cRet += '		}'+CRLF
cRet += '		'	+CRLF
cRet += '	}'+CRLF
cRet += '	$(document).ready(function () {'+CRLF
cRet += '		htmlbodyHeightUpdate()'+CRLF
cRet += '		$( window ).resize(function() {'+CRLF
cRet += '			htmlbodyHeightUpdate()'+CRLF
cRet += '		});'+CRLF
cRet += '		$( window ).scroll(function() {'+CRLF
cRet += '			height2 = $(".main").height()'+CRLF
cRet += '			htmlbodyHeightUpdate()'+CRLF
cRet += '		});'+CRLF
cRet += '	});'+CRLF
cRet += '</script>'+CRLF
cRet += '</body>'+CRLF
cRet += '</html>'+CRLF

Return cRet