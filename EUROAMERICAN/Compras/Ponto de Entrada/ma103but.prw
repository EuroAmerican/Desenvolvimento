#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} ma103but
//PE usado para criar opcoes no menu da nota fiscal.
@author mjlozzardo
@since 19/01/2018
@version 1.0
@type function
/*/

User Function ma103but()

// ============================================================
//  Grupo Empresa - Ajuste realizado em 31.08.20 (CG)
// ============================================================

// cEmpAnt (Substituido por cFilAnt)
// Local lEmpresa := (cEmpAnt $ GetMv("MV_EQ_EENT",,"02|08")) // FS - Empresas liberadas para utilizar amarração controle de pesagem na entrada...

Local aButtons := {}
Local cUsrLib  := SuperGetMV("ES_USRETIQ", .T., "000000|000810")  //Indicar os ID's dos usuarios que podem utilizar a rotina
Local lEmpresa := (Left(cFilAnt,2) $ GetMv("MV_EQ_EENT",,"02|08")) // FS - Empresas liberadas para utilizar amarração controle de pesagem na entrada...

If __cUserId $ cUsrLib
	aAdd(aButtons,{"EDIT", {||U_mest002("M")}, "Manut.Etiqueta"   })  //informar o dados das etiquetas
	aAdd(aButtons,{"EDIT", {||U_mest002("G")}, "Gerar Etiqueta"   })  //efetua a geracao das etiquetas
	aAdd(aButtons,{"EDIT", {||U_mest002("I")}, "Imprimir Etiqueta"})  //efetua a impressao das etiquetas
EndIf

If lEmpresa
	SetKey( VK_F11, {|| U_EQNFEPES() } )
	aAdd( aButtons, {"PROJETPMS", {|| U_EQNFEPES() } , "Amarração Nota Fiscal versus Pesagem <F11>...", "Controle de Pesagem"})
EndIf

Return(aButtons)