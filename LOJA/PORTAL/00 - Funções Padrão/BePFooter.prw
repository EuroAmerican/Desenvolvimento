#include "protheus.ch"

// Função para montagem do Rodapé da Pagina Padrão
User Function BePFooter()

Local cRet 		:= ""
Local cNomeUsr	:= Iif(Valtype(HttpSession->username)<>"U",Capital(HttpSession->username),"")
Local cAmbAtu	:= Iif(Valtype(HttpSession->cEnvServer )<>"U",Capital(HttpSession->cEnvServer ),"")
Local dDtAtu	:=Iif(Valtype(HttpSession->cDataPC )<>"U",DtoC(HttpSession->cDataPC ),"")

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
