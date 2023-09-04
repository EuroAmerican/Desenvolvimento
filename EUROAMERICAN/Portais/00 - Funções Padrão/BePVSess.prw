#include 'totvs.ch'
#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'
#Include 'fileio.Ch'
// Programa de Validação da Sessão
/*
Histrico :
Correção em 26/11/2021 projeto release 12.1.33 para banco de dados 
Realizado por : Fabio Carneiro dos Santos 
*/

User Function BePVSess()
      
Local lRet		 := .F.

Local lSession  := Iif(Valtype(HttpSession->lLoginOK)<>"U",HttpSession->lLoginOK,.F.)

If lSession
	lRet := .T.

	If Select("SX5") <= 0
		RPCSetEnv(Substring(HttpSession->cEmpFil,1,2),Substring(HttpSession->cEmpFil,3,4),"","","COM","",)
		cEmpAnt := Substring(HttpSession->cEmpFil,1,2)
		cFilAnt := Substring(HttpSession->cEmpFil,3,4)
	EndIf	

	PswOrder(2) //Nome do Usuario
	If !(PswSeek(HttpSession->username,.T.) .And. PswName(HttpSession->password))
		HttpSession->lLoginOk := .F.
		lRet := .F.
	EndIf
	
EndIf

Return lRet
