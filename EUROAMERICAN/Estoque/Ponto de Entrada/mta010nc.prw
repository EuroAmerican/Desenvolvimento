#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} mta010nc
//PE usado para indicar os campos que nao devem ser copiados.
@author mjlozzardo
@since 03/07/2018
@version 1.0
@type function
/*/
User Function mta010nc()
	Local aRetCpo := {}

	aAdd(aRetCpo, "B1_CODBAR")
	aAdd(aRetCpo, "B1_CODGTIN")

	Return(aRetCpo)