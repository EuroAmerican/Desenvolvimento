#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#include "tryexception.ch"

/*/{Protheus.doc} 
@author Fabio Carneiro dos Santos 
@since 28/04/2021
@version 1.0
/*/

User Function QEFIN003()

    Public c_Ret := getmv("MV_XSEQREM")

    c_Ret :=c_Ret+1

    PutMv("MV_XSEQREM", c_Ret)

Return(c_Ret)
