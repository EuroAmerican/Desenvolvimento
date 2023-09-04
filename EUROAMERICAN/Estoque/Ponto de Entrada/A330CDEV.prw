
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TRYEXCEPTION.CH"

/*/{Protheus.doc} A330CDEV - Contabiliza��o dos movimentos de devolu��o de compras
// Ponto de Entrada utilizado para permitir que os movimentos de devolu��o de compras sejam contabilizados 
// nas rotinas de Rec�lculo do Custo M�dio (MATA330) e Contabiliza��o do Custo M�dio (MATA331). Sendo que o retorno quando T, contabiliza o lan�amento padronizado 678 e quando F, n�o contabiliza.   
@author Fabio Carneiro dos Santos 
@since 07/10/2021
@version 1.0
/*/

User Function A330CDEV()

Local lRet := .T.

Return lRet
