#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc}MT103EXC
//Ponto de Entrada para confirmação de exclusão da Nota Fiscal de Endrada.  
@author Fabio F Sousa  
@since 08/05/2019
@version 1.0
@History Incluido o tratamento para ALTERAR o campo C7_XSTATUS = N, quando cancelar a nota de despesa 
@author Fabio Carneiro dos Santos   
@since 15/01/2022
/*/

User Function MT103EXC()
//------------------------------------------------
// Paulo Rogério:
//-----------------------------------------------
// Ponto de Entrada retirado em 15/08/22
// sendo substituido pelo PE SD1100E
//------------------------------------------------

Return .T.
