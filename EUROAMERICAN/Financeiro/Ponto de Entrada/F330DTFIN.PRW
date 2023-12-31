#include "rwmake.ch"   
#include "topconn.ch"
#include "tbiconn.ch"
#include "protheus.ch"
/*/{Protheus.doc} F330DTFIN
description Avisa usuario que ser� mudado o parametro 
@type function USER
@version 1.0
@author Paulo Lenzi
@since 7/20/2023
@projeto Melhorias
@return variant, return_description
/*/
User Function F330DTFIN()
   Local nRet

   IF UPPER(funName()) $ 'FINA330#FINA740'
        nRet := MsgNoYes("Calcula Comiss�es"," ATENCAO ")
        // nRet = .T. (Sim 1 ) e .F. (N�o 2)
        MV_PAR13 := IIF(nRet,1,2)
   ENDIF
RETURN
