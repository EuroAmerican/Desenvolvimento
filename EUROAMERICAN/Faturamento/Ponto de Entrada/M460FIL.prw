#include "protheus.ch"
#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Colors.ch"
#include "RwMake.ch"
#Include "FWMVCDEF.CH"

/*/{Protheus.doc} M460FIL - Ponto de entrada executado antes da exibição da tela de seleção de itens para a geração de Doc. de Saída (Markbrowse)
@author Fabio Carneiro dos Santos
@since 17/04/2021
@version 1.0
@type Function
/*/
User Function M460FIL()  

Local cFilSC9 := ""
            
Pergunte("MT461A" , .F.)

cFilSC9 := " Empty(C9_BLCRED) .And. Empty(C9_BLEST) "

Return cFilSC9  
