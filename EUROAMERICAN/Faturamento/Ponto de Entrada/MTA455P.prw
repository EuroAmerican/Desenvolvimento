#include "protheus.ch"
#include "topconn.ch"

User Function MTA455P()    

Local _lRetorno := .T.    
Local _nOpcao   := ParamIXB[1]
Local cPermite := Alltrim(SuperGetMV("QE_MTA455P",.T.,"")) 

If _nOpcao == 2

	IF !AllTrim( cUsername ) $ cPermite
		_lRetorno := .F.
		ApMsgAlert("Usuário sem permissão para usar Lieberação Manual, Favor usar a Liberação Automatica.","Atenção - MTA455P")
	Endif

Endif

Return(_lRetorno)

