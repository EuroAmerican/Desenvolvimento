#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc}SD1100E
//Ponto de Entrada antes da exclusão do item do documento de entrada.  
@author Fabio F Sousa  
@since 08/05/2019
@version 1.0
@History: Incluido para substituir o PE:MT102EXC no tratamento do campo C7_XSTATUS
        nos pedidos de compras relacionados a reembolso de despesas. O objetivo da
        flag é evitar que o PC seja reprocessado pelo JOB antes mesmo de ser 
        reavaliado pelo aprovador.
@author Paulo Rogério    
@since 15/08/2022
/*/

User Function SD1100E()
Local aArea  := GetArea()
    IF !Empty(SD1->D1_PEDIDO)
        dbSelectArea("SC7")
        dbSetOrder(1) //C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN, R_E_C_N_O_, D_E_L_E_T_
        dbSeek(xFilial("SC7")+SD1->(D1_PEDIDO+D1_ITEMPC))

        IF Found()
            RecLock("SC7", .F.)
            SC7->C7_XSTATUS  := "C"
            MsUnlock()
        Endif
    Endif

    RestArea(aArea)
Return(.T.)
