#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} a250prlt
//PE utilizado para carregar o numero de lote/validade automaticamente
//no momento da producao.
@author euroamerican                                                                                    


@since 06/12/2017
@version 1.0
/*/
User Function a250prlt()
	Local aLote := {}
	Local lMostra := SuperGetMV("ES_A250PRL", .T., .F.)  //parametro para mostrar ou nao a tela para digitar o lote/validade
	Local nPrazo  := Posicione("SB1", 1, xFilial("SB1") + SC2->C2_PRODUTO, "B1_PRVALID")  //data de validade

	aAdd(aLote, SC2->C2_NUM)  //numero do lote
	aAdd(aLote, LastDay(dDataBase + nPrazo,2))  //data de validade
	aAdd(aLote, lMostra)  //Nao mostra tela para informar o lote/validade

	Return(aLote)
