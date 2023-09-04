#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'

// Programa de Validação da Sessão
User Function BePVSess()
      
Local lRet		:= .F.
Local lSession  := Iif(Valtype(HttpSession->lLoginOK)<>"U",HttpSession->lLoginOK,.F.)

If lSession
	lRet := .T.

	If Select("SX5") <= 0
		//RpcSetType(3)
		RPCSetEnv(Substring(HttpSession->cEmpFil,1,2),Substring(HttpSession->cEmpFil,3,4),"","","COM","",)
		cEmpAnt := Substring(HttpSession->cEmpFil,1,2)
		cFilAnt := Substring(HttpSession->cEmpFil,3,4)
	EndIf	

	PswOrder(2) //Nome do Usuario
	If !(PswSeek(HttpSession->username,.T.) .And. PswName(HttpSession->password))
		//RpcClearEnv()
		HttpSession->lLoginOk := .F.
		lRet := .F.
	EndIf
	/*
	dbSelectArea("SM0")
	dbSetOrder(1)
	If !dbSeek(cEmpAnt+cFilAnt) .And. lRet
		RpcClearEnv()		
		HttpSession->lLoginOk := .F.
		lRet := .F.
	EndIf
	*/
EndIf

Return lRet
