#include "protheus.ch"

/*/{Protheus.doc} FA440VLD
@type function Ponto de Entrada para não executar comissão para qualy no fina440 
@version 1.00
@author Fabio Carbeiro dos Santos  
@since 18/03/2022
@return Logical, True ou False 
/*/

User Function FA440VLD()

Local aAreaSE1   := SE1->(GetArea())
Local aAreaSE5   := SE5->(GetArea())
Local aAreaSE3   := SE3->(GetArea())
Local _lRet     := .T.
Local _cQeFil   := SUPERGETMV("QE_FIL440",,"") 

If cFilAnt $ _cQeFil

   _lRet := .F. 

EndIf 

RestArea(aAreaSE1)
RestArea(aAreaSE5)
RestArea(aAreaSE3)

Return _lRet
