#include "rwmake.ch"   
#include "topconn.ch"
#include "tbiconn.ch"
#include "protheus.ch"

User Function F460SE1()
  local aRet:= {{"E1_VEND1",SE1->E1_VEND1} ,;
                {"E1_COMIS1",SE1->E1_COMIS1},;
                {"E1_PEDIDO",SE1->E1_PEDIDO},;
                {"E1_BASCOM1",SE1->E1_BASCOM1}}
Return aRet 
