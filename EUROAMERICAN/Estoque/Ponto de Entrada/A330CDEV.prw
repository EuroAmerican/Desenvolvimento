
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TRYEXCEPTION.CH"

/*/{Protheus.doc} A330CDEV - Contabilização dos movimentos de devolução de compras
// Ponto de Entrada utilizado para permitir que os movimentos de devolução de compras sejam contabilizados 
// nas rotinas de Recálculo do Custo Médio (MATA330) e Contabilização do Custo Médio (MATA331). Sendo que o retorno quando T, contabiliza o lançamento padronizado 678 e quando F, não contabiliza.   
@author Fabio Carneiro dos Santos 
@since 07/10/2021
@version 1.0
/*/

User Function A330CDEV()

Local lRet := .T.

Return lRet
