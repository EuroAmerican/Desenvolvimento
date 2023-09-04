#include 'Ap5Mail.ch'
#Include "Rwmake.ch"    

/*/{Protheus.doc} CPEmail
//Função de Envio de e-mail 
@author Fabio Carneiro dos Santos 
@since 27/02/2021
@version 1.0
/*/

User Function CPEmail(cRecebe,cCopia,cAssunto,cMensagem,cFile,lDisplay)

Local cServer   := GetMV("MV_RELSERV")
Local cAccount  := GetMV("MV_RELACNT")
Local cEnvia    := GetMV("MV_RELACNT")
Local cPassword := GetMV("MV_RELPSW")

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lConectou

If lConectou
	MAILAUTH(cAccount,cPassword)     //Esta função faz a autenticação no servidor
   If lDisplay
	   //Alert("Conectado com servidor - " + cServer)
   Endif
Else
	cError := ""
	GET MAIL ERROR cError
	If lDisplay
	   Alert(cError+" no Servidor SMTP")
	Endif
Endif

//Procurar e-mail do usuário
cNomeUsr := UsrRetName(RetCodUsr())
PswOrder(2) // Ordem de nome
PswSeek(cNomeUsr,.T.)
aRetUser := PswRet(1)
Email  	:= alltrim(aRetUser[1,14])
If !Empty(Email)
	cRem   := "EUROAMERICAN"/*AllTrim(cNomeUsr)*/+" <"+cEnvia+">"
	If !Email$cRecebe
		//cCopia := Email 
		cCopia := Email
	EndIf
Else
	cRem := "EUROAMERICAN"/*AllTrim(cNomeUsr)*/+" <"+GetMV("MV_RELFROM")+">"
	cCopia := "ti@euroamerican.com.br"
EndIF
If !Empty(cRem)
	cEnvia := cRem
EndIf

If !Empty(cFile) 
   SEND MAIL FROM cEnvia;
	     TO cRecebe;
	     CC cCopia ;
	     SUBJECT cAssunto;
	     BODY cMensagem;
         ATTACHMENT cFile;
	     FORMAT TEXT;
	     RESULT lEnviado
Else	     
	SEND MAIL FROM cEnvia;
	     TO cRecebe;
	     CC cCopia ;
	     SUBJECT cAssunto;
	     BODY cMensagem;
	     FORMAT TEXT;
	     RESULT lEnviado
Endif	     

If lEnviado
   If lDisplay  
   //aviso("Envio E-mail!","Enviado e-mail para analise " + cRecebe,{"OK"})
   Endif
Else
	GET MAIL ERROR cMensagem 
	If lDisplay
	   Alert(cMensagem+":"+cAssunto)
	Endif                         
	Return .F.
Endif
   
DISCONNECT SMTP SERVER Result lDisConectou

If lDisConectou
   If lDisplay
//	   Alert("Desconectado do servidor - " + cServer)
   Endif
Endif

Return  .T.
