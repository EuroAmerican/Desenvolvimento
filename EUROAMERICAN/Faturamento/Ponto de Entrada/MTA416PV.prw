#include 'protheus.ch'
#include 'parmtype.ch'
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "ap5mail.ch"
#Include "RwMake.Ch"

/*/{Protheus.doc} MATASC5
//Rotina PE para alimentar margem na 
efetivação do orçamento
@author Fabio Batista
@since 11/03/2021
@version 1.0
/*/

User Function MTA416PV()

M->C5_TRANSP	:= SCJ->CJ_TRANSP
M->C5_OBS		:= SCJ->CJ_OBS     

// Atualiza margem no pedido de venda
    If SCJ->CJ_XMARGEM <> ''
        M->C5_XMARGEM := SCJ->CJ_XMARGEM
    EndIf

    If SCJ->CJ_XVALMAR > 0 
        M->C5_XVALMAR := SCJ->CJ_XVALMAR
    EndIf 

Return 
