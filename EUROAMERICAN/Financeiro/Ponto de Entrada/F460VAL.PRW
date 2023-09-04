#include "rwmake.ch"   
#include "topconn.ch"
#include "tbiconn.ch"
#include "protheus.ch"

User Function F460VAL()
    local aCompl := aClone(PARAMIXB) 
 
    If RecLock("SE1",.F.)  
        SE1->E1_VEND1 :=    aCompl[1][2]
        SE1->E1_COMIS1 :=   aCompl[2][2]
        SE1->E1_PEDIDO :=   aCompl[3][2]
        SE1->E1_BASCOM1:=   SE1->E1_VALOR
        SE1->E1_VALCOM1:=  (SE1->E1_BASCOM1 * aCompl[2][2])/100
        SE1->(MsUnlock())
    EndIf
Return
