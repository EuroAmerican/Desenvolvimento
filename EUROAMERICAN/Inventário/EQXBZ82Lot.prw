#include "Totvs.ch"
#include "FwMvcDef.ch"
#include "TbiConn.ch"

User Function EQXBZ82Lot()

Local aArea      := GetArea()
Local lRetorno   := .F.
Local oMdl       := FWModelActive()
Local oModel     := oMdl:GetModel('ID_ENCH_Z82')
Local cProduto   := AllTrim( oModel:GetValue('Z82_PRODUT') )
Local cLocal     := AllTrim( oModel:GetValue('Z82_LOTECT') )

If AllTrim( cProduto ) == AllTrim( SB8->B8_PRODUTO ) .And. AllTrim( cLocal ) == AllTrim( SB8->B8_LOCAL )
	lRetorno := .T.
EndIf

RestArea( aArea )

Return lRetorno