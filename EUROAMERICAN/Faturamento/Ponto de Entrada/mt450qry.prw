#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} mt450qry
//PE usado para filtar os pedidos que foram listados
//na pre-separacao.
//necessario criar
// campo--> C9_XPRESEP - C - 1
@author mjlozzardo
@since 16/07/2018
@version 1.0
@type function
/*/
User Function mt450qry()
	Local cFiltro := ParamIxb[1]

	If SM0->M0_CODIGO $ "08|99"	//"08|99"
		cFiltro += " AND C9_XPRESEP = 'S' "
	EndIf

	Return(cFiltro)