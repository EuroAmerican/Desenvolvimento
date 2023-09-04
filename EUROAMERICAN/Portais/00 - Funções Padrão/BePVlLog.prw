#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

// Função de Validação do Login
/*
Histrico :
Correção em 26/11/2021 projeto release 12.1.33 para banco de dados 
Realizado por : Fabio Carneiro dos Santos 
*/

User Function BePVlLog()

Local cMsgHdr	:= ""
Local cMsgBody	:= ""
Local cRetfun	:= "u_BePLogin.apw"
Local cQuery    := ""
Local _cCodUsr  := ""
Local _cLogin   := ""
Local _cEmpSys  := ""
Local _cFilSys  := ""
Local cAlias	:= GetNextAlias()
Public lLogin 	:= .F.

Private cHtml := ""

WEB EXTENDED INIT cHtml

HttpSession->cEmpFil 	:= HttpPost->cEmpFil
HttpSession->username 	:= HttpPost->username
HttpSession->password 	:= HttpPost->password

PREPARE ENVIRONMENT EMPRESA Substr(HttpPost->cEmpFil,1,2) FILIAL Substr(HttpPost->cEmpFil,3,4)

ConOut( HttpPost->cEmpFil )
ConOut( HttpPost->username )
ConOut( HttpPost->password )

If Select(cAlias) <> 0
	(cAlias)->( dbCloseArea() )
EndIf

cQuery := "SELECT SYSUSR.USR_ID AS USR_ID, SYSUSR.USR_CODIGO AS USR_CODIGO, SYSUSR.USR_MSBLQL AS USR_MSBLQL, " + CRLF
cQuery += "FILIAL.USR_GRPEMP AS USR_GRPEMP, FILIAL.USR_FILIAL AS USR_FILIAL " + CRLF
cQuery += "FROM SYS_USR AS SYSUSR " + CRLF
cQuery += "INNER JOIN SYS_USR_FILIAL AS FILIAL ON FILIAL.USR_ID = SYSUSR.USR_ID " + CRLF
cQuery += "WHERE SYSUSR.USR_MSBLQL = '2' " + CRLF
cQuery += "AND FILIAL.USR_GRPEMP = '"+Substr(HttpPost->cEmpFil,1,2)+"' " + CRLF
cQuery += "AND FILIAL.USR_FILIAL = '"+Substr(HttpPost->cEmpFil,3,4)+"' " + CRLF
cQuery += "AND FILIAL.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "AND SYSUSR.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "AND SYSUSR.USR_CODIGO = '"+HttpPost->username+"' " + CRLF
cQuery += "ORDER BY SYSUSR.USR_ID " + CRLF

TcQuery cQuery NEW ALIAS (cAlias)

If (cAlias)->( Eof() ) .or. (cAlias)->( Bof() )
	lLogin 	:= .F. 
	cMsgBody	:= "Usuario ou Senha Invalido!"  
Else 
	lLogin := .T. 
	_cCodUsr  := (cAlias)->USR_ID 
	_cLogin   := (cAlias)->USR_CODIGO
	_cEmpSys  := (cAlias)->USR_GRPEMP
	_cFilSys  := (cAlias)->USR_FILIAL
	
Endif 

If lLogin

	HttpSession->lLoginOK	:= .T.
	HttpSession->ccodusr 	:= _cCodUsr
	__cUserId 	:= _cCodUsr
	dDataBase := HttpSession->cDataPC
	cHtml += '<script type="text/javascript">window.parent.location = "u_BePIndex.apw"</script>'+CRLF

Else
	
	cHtml      += Execblock("BePHeader",.F.,.F.)
	cMsgHdr	   := "Login Inválido"
	cMsgBody   := "Login Inválido"
	cHtml 	   +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
	cHtml 	   += Execblock("BePFooter",.F.,.F.)

EndIf

If Select(cAlias) <> 0
	(cAlias)->( dbCloseArea() )
EndIf

WEB EXTENDED END

RESET ENVIRONMENT

Return (EncodeUTF8(cHtml))
