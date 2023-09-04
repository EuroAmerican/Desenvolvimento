/*/{Protheus.doc} ma103f4h
//O Ponto de Entrada MA103F4H permite incluir novos títulos de colunas para adicionar na seleção do pedido de compra.
//Necessário utilizar em conjunto com o ponto de entrada MA103F4I.
@author Emerson Paiva
@since 30/01/2018
@version 1.0
@type function
/*/
#Include 'Protheus.ch'

User Function MA103F4H()

Local aRet := {}

aRet := { GetSx3Cache("C7_DATPRF","X3_TITULO") }

Return(aRet)