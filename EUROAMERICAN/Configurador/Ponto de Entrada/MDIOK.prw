#include "protheus.ch"
	
User Function MDIOK()

Local lRet

If __cUserId == "000000" 
	lRet := .T.
Else
	lRet := FwIsAdmin(__cUserId)
EndIf

If !lRet
	ApMsgAlert("Favor acessar o sistema pelo programa inicial SIGAADV. Em caso de dúvidas, entrar em contato com o departamento de TI.")
EndIf

Return lRet