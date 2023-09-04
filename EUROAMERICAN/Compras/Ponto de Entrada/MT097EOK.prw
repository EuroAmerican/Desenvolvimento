#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

#DEFINE ENTER chr(13) + chr(10) 
#DEFINE CRLF chr(13) + chr(10)

/*/{Protheus.doc}MT097EOK
//Ponto de entrada para desmarcar o status do pedido de compra para despesas  
@author Fábio Carneiro dos Santos  
@since 15/01/2022
@version 1.0
/*/

User Function MT097EOK()
//-------------------------------------------------------------
// Paulo Rogério:
//-------------------------------------------------------------
// Ponto de Entrada retirado em 15/08/22, cuja funcionalidade 
// passou a ser tratada pelo PE MT097APR.
//-------------------------------------------------------------

Return(.T.)
