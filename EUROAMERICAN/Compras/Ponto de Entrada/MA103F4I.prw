/*/{Protheus.doc} ma103f4i
//PE permite adicionar campos no array com registros da SC7 utilizados na seleção do pedido de compras. Executado uma vez para cada item do pedido de compras.
//Este Ponto de Entrada deve ser utilizado em conjunto com o MA103F4H.
@author Emerson Paiva
@since 30/01/2018
@version 1.0
@type function
/*/
#Include 'Protheus.ch'

User Function MA103F4I()

Local aRet := {}

aRet := { SC7->C7_DATPRF }

Return(aRet)
