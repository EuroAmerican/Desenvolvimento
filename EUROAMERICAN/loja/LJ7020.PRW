#INCLUDE 'totvs.ch'
/*/{Protheus.doc} LJ7020
Ponto de entrada para remover duplicidade de botao PIX
@type function Ponto de entrada
@version  1.00
@author mario.antonaccio
@since 01/11/2021
@return Character, o botao que nao sera mostrado
/*/
User Function LJ7020()

Return ! ( ParamIXB[01] =="PIX")
