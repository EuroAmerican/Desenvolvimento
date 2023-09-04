#include "Ap5Mail.ch"
#include "rwmake.ch"
#Include "Protheus.Ch"
#Include "Totvs.Ch"

#DEFINE CRLF CHR(13) + CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BeSendMailºAutor  ³Rodrigo Sousa       º Data ³  29/07/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Envio E-mail                                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BeSendMail(aEmail)

Local lRet := .T.
Local cMensagem 
Local cAnexo,_cAnexo2, _cAnexo3,_cAnexo4,_cAnexo5
Local cEnvia
Local cCCO  

Local oServer
Local oMessage

/*
	Posições aMail
	1 - Destinario 
	2 - Subject
	3 - Msg          	Opcional
	4 - Remetente    	Opcional
	5 - Copia Oculta  	Opcional
	6 - Anexo 1       	Opcional
	7 - Anexo 2       	Opcional 
	8 - Anexo 3       	Opcional 
	9 - Anexo 4       	Opcional 
	10- Anexo 5       	Opcional 
*/	

If Len(aEmail) > 2
   cMensagem := aEmail[3]
else 
   cMensagem := ''	   
EndIf

IF LEN(aEmail) > 3
   cEnvia    := aEmail[4]
else   
   cEnvia    := GETMV("MV_WFMAIL")
endif   

If Len( aEmail ) > 4
	cCCO 	:= aEmail[05]
Else
	cCCO 	:= ''
EndIf

IF LEN(aEmail) > 5
   cAnexo := aEmail[6]
else 
   cAnexo := ''	   
endif

IF LEN(aEmail) > 6
   	cAnexo2 := aEmail[7]
else 
   	cAnexo2 := ''	   
endif

IF LEN(aEmail) > 7
	cAnexo3 := aEmail[8]
else 
   	cAnexo3 := ''	   
endif

If Len(aEmail) > 8
	cAnexo4 := aEmail[9]
Else 
   	cAnexo4 := ''	   
Endif

If Len(aEmail) > 9
	cAnexo5 := aEmail[10]
Else 
   	cAnexo5 := ''	   
Endif

/*
cServer   := GETMV("MV_RELSERV")
cAccount  := GetMV("MV_RELACNT")
cPassword := GETMV("MV_RELPSW")

//Cria a conexão com o server SMTP ( Envio de e-mail )
oServer := TMailManager():New()
oServer:SetUseSSL(.T.)
oServer:Init( "", cServer, cAccount, cPassword, 0, 465 )

//seta um tempo de time out com servidor de 1min
If oServer:SetSmtpTimeOut( 60 ) != 0
	Conout( "Falha ao setar o time out" )
    Return .F.
EndIf

//realiza a conexão SMTP
If oServer:SmtpConnect() != 0
	Conout( "Falha ao conectar" )
    Return .F.
EndIf

///Autentica SMTP
nErro := oServer:SmtpAuth(cAccount,cPassword)
If nErro <> 0
    conout("ERROR:" + oServer:GetErrorString(nErro))
    oServer:SMTPDisconnect()
    return .F.
Endif

//Apos a conexão, cria o objeto da mensagem
oMessage := TMailMessage():New()

//Limpa o objeto
oMessage:Clear()

//Popula com os dados de envio
oMessage:cFrom              := "Workflow"
oMessage:cTo                := aEmail[01]
oMessage:cCc                := ""
oMessage:cBcc               := ""
oMessage:cSubject 	        := aEmail[2]
oMessage:cBody              := cMensagem

If oMessage:Send( oServer ) != 0
	Conout( "Erro ao enviar o e-mail" )
    Return .F.
EndIf

//Desconecta do servidor
If oServer:SmtpDisconnect() != 0
	Conout( "Erro ao desconectar do servidor SMTP" )
	Return .F.
EndIf
*/

cSrvMail := AllTrim(GetMV("MV_RELSERV"))
cUserAut := AllTrim(GetMV("MV_RELACNT")) 
cPassAut := AllTrim(GetMV("MV_RELPSW"))  
cAuthent := AllTrim(GetMV("MV_RELAUTH"))
lAuthent := GetMV("MV_RELAUTH")
cDe      := "Workflow"
cPara    := Lower(AllTrim(aEmail[01]))
cCc      := ""
cCco     := ""
cSubject := aEmail[2]
cBody    := cMensagem
cAttach  := cAnexo

CONNECT SMTP SERVER cSrvMail ACCOUNT cUserAut PASSWORD cPassAut TIMEOUT 60 RESULT lOk

If (lOk)
	If lAuthent //.Or. cAuthent == ".T." .Or. cAuthent == "T"
		MAILAUTH(cUserAut, cPassAut)
	EndIf

	SEND MAIL FROM cDe TO cPara ;
				BCC cCco ;
				CC cCc ;
				SUBJECT cSubject ;
				BODY cBody ;
				ATTACHMENT cAttach ;
				RESULT lOK

	DISCONNECT SMTP SERVER
EndIf

If !(lOk)
	ConOut("BESENDMAIL: Ocorreu uma falha ao tentar enviar a mensagem!")
Endif

Return(lRet)