#include "Totvs.ch"
#include "FwMvcDef.ch"
#include "TbiConn.ch"

User Function EQXBZ82Xoc()

Local aArea      := GetArea()
Local lRetorno   := .F.
Local oMdl       := FWModelActive()
Local oModel     := oMdl:GetModel('ID_ENCH_Z82')
Local cProduto   := AllTrim( oModel:GetValue('Z82_PRODUT') )

If AllTrim( cProduto ) == AllTrim( SB2->B2_COD )
	lRetorno := .T.
EndIf

RestArea( aArea )

Return lRetorno