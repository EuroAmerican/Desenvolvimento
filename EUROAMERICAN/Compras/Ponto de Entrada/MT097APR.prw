#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

#DEFINE ENTER chr(13) + chr(10) 
#DEFINE CRLF chr(13) + chr(10)


/*/{Protheus.doc}MT097APR
//Ponto de entrada para liberar o campo C7_XSTATUS, a fim de viabilizar  o processamento do PC via JOB.
@author QualyCryl 
@since 02/01/2013
@version 2.0
@Create fabio carbeiro dos santos 
@Update Paulo Rogério - 15/08/2022
@history ajustado para gravar todos os itens do pedido de compra
@Since 15/01/2022
/*/

User Function MT097APR()
Local aArea			:= GetArea()

// O Item do Pedido de Compra já esta posicionado no fonte padrão.
IF SUBSTRING(SC7->C7_PRODUTO,1,2) == 'RE' .And. SC7->C7_CONAPRO == "L" 
	Reclock("SC7",.F.)
	SC7->C7_XSTATUS  := 'N'
	SC7->(Msunlock()) 

	ConOut("*** PC Liberado: "+SC7->C7_NUM+" - Produto: "+SC7->C7_PRODUTO+" - Filial:"+xFilial("SC7")+" - C7_XSTATUS: "+SC7->C7_XSTATUS)
Endif

RestArea(aArea)
Return ()
