#Include "parmtype.ch"
#Include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"
#Include "Colors.ch"
#Include "RwMake.ch"
#include 'Ap5Mail.ch'

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

/*/{Protheus.doc} QEAP0901
//Rotina via Sheduler para gravar as notas de despesas  
@author QualyCryl 
@since 02/01/2013
@version 1.0
@Update fabio carbeiro dos santos 
@history ajustado para gravar todos os itens do pedido de compra
@Since 08/03/2022
/*/

User Function QEAP0901(aParam)
//----------------------------------------------------
// Paulo Rogério:
//----------------------------------------------------
// Essa Rotina perdeu a Funcionalidade em 15/08/2022
// quanto juntamos o processamento das três empresas
// no programa QEAP0803.
// ********************** Backup gerado em 19/08/2022
//----------------------------------------------------

IF ValType(aParam) <> "U"
	WFPrepEnv(aParam[1],aParam[2])
Endif

Conout("-------------------------------------------------")
Conout("*** QEAP0901")
Conout("*** Executada em "+dtoc(dDataBase)+" as "+Time())
Conout("-------------------------------------------------")

Return 
