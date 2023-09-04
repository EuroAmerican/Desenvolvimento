/*/{Protheus.doc} a250prlt
O ponto de entrada MA381COLS permite manipulação / ordenação do aCols,
antes da montagem da GetDados.LOCALIZAÇÃO: Na função A381Manut(),
após a montagem do aCols.
Ordenar Empenhos Múltiplos
@author Emerson Paiva
@since 10/01/2018
@version 1.0
/*/
User Function MA381COLS()                              

Local nPosSeq := aScan(aHeader,{|x| AllTrim(x[2])=="D4_TRT"})

aCols := aClone(aSort(aCols,,,{|x,y| x[nPosSeq] < y[nPosSeq]}))      

Return