#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} SF2520E
//TODO Descri��o auto-gerada.
@author erics
@since 26/12/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function SF2520E()
Local cPedido := SD2->D2_PEDIDO

// Processar PA0 -- Elimina��o de Residuo
U_ProcPA0(cPedido, 5) // inclus�o

Return