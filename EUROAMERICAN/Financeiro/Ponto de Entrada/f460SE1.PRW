#include "rwmake.ch"   
#include "topconn.ch"
#include "tbiconn.ch"
#include "protheus.ch"
/*/{Protheus.doc} F460SE1
description Ponto de entrada que passa dados do titulo a receber para o desdobrado
@type function User
@version  1
@author paulo.lenzi
@since 7/20/2023
@return variant, return_description
/*/
User Function F460SE1()
  local aRet:= {{"E1_VEND1",SE1->E1_VEND1} ,;
                {"E1_COMIS1",SE1->E1_COMIS1},;
                {"E1_PEDIDO",SE1->E1_PEDIDO},;
                {"E1_BASCOM1",SE1->E1_BASCOM1}}
Return aRet 
