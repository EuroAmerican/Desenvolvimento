#include "protheus.ch"
#include "topconn.ch"

User Function MTA455P()    

Local _lRetorno := .T.    
Local _nOpcao   := ParamIXB[1]
Local cPermite := Alltrim(SuperGetMV("QE_MTA455P",.T.,"")) 

If _nOpcao == 2

	IF !AllTrim( cUsername ) $ cPermite
		_lRetorno := .F.
		ApMsgAlert("Usu�rio sem permiss�o para usar Liebera��o Manual, Favor usar a Libera��o Automatica.","Aten��o - MTA455P")
	Endif

Endif

Return(_lRetorno)

