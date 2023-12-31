#include "TOTVS.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#define ENTER CHR(13) + CHR(10)


/*
| Fun��o...: QEMA410ES()
| Autor....: Paulo Rogerio
| Data.....: 12/07/2023
| Retorno..: Nenhum
| Descric�o: Estorno da Libera��o do Pedido de Venda.
|
| Observac.: 
| Objetivo.: 
| Documenta��o: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Altera��o
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User Function QEMA410ES()
Local aArea		 := GetArea()
Local aAreaC5    := SC5->(GetArea())
Local aAreaC6	 := SC6->(GetArea())
Local aAreac9	 := SC9->(GetArea())

IF !U_xFilPComl() 
    MsgAlert("Rotina disponivel apenas para as empresas Qualy e Phoenix!", "Politicas Comerciais")
    Return
Endif

IF Aviso("Politicas Comerciais - ESTORNO LIB", "O Estorno da Libera��o retornar� o status do Pedido de Venda para 'Pendente'. Deseja Continuar? ", {"Sim","N�o"}, 2) <> 1
    Return
Endif


Processa({|| fEstornar()}, "Aguarde","Processando o Estorno da Libera��o...")


RestArea(aAreaC5)
RestArea(aAreaC6)
RestArea(aAreaC9)
RestArea(aArea)

Return


/*
| Fun��o...: fEstornar()
| Autor....: Paulo Rogerio
| Data.....: 12/07/2023
| Retorno..: Nenhum
| Descric�o: Rotina de Estorno.
|
| Observac.: 
| Objetivo.: 
| Documenta��o: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Altera��o
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
Static Function fEstornar()
dbSelectArea("SC9")
dbSetOrder(2) //C9_FILIAL, C9_CLIENTE, C9_LOJA, C9_PEDIDO, C9_ITEM, R_E_C_N_O_, D_E_L_E_T_
dbSeek(xFilial("SC9")+SC5->(C5_CLIENTE+C5_LOJACLI+C5_NUM))

Begin Transaction
    Do While SC9->(C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO) == xFilial("SC9")+SC5->(C5_CLIENTE+C5_LOJACLI+C5_NUM)
        a460Estorna()

        dbSkip()
    Enddo
End Transaction

MsgInfo("Estorno Finalizado!")
Return

