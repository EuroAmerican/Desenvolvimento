#include "rwmake.ch"   
#include "topconn.ch"
#include "tbiconn.ch"
#include "protheus.ch"
/*/{Protheus.doc} F460VAL
description Ponto de entrada que receber os dados gerados pelo F460SE1
@type function USER
@version 1 
@author paulo.lenzi
@since 7/20/2023
@return variant, return_description
/*/
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
