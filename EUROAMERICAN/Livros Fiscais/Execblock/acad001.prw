#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} acad001
//Rotina para manutenção do cadastro de NCM
@author mjlozzardo
@since 03/10/2018
@version 1.0
/*/
User Function acad001()
	Local cVldAlt := ".T."
	Local cVldExc := ".T."

	ChkFile("SYD")
	DbSelectArea("SYD")
	SYD->(dbSetOrder(1))
	AxCadastro("SYD", "Cadastro de NCM", cVldExc, cVldAlt)

	Return