#include "Totvs.ch"
#include "FwMvcDef.ch"
#include "TbiConn.ch"
#include "TopConn.ch"

User Function EQParInv()

Private oBrowse := FwMBrowse():New()

oBrowse:SetAlias("Z86")
oBrowse:SetDescription("Parâmetros do Inventário")
oBrowse:Activate()

Return

Static Function MenuDef()

Local aMenu := {}

ADD OPTION aMenu TITLE 'Pesquisar' 	ACTION 'PesqBrw'			OPERATION 1 ACCESS 0
ADD OPTION aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.EQParInv'	OPERATION 2 ACCESS 0
ADD OPTION aMenu TITLE 'Incluir' 	ACTION 'VIEWDEF.EQParInv'	OPERATION 3 ACCESS 0
ADD OPTION aMenu TITLE 'Alterar' 	ACTION 'VIEWDEF.EQParInv'	OPERATION 4 ACCESS 0
ADD OPTION aMenu TITLE 'Excluir' 	ACTION 'VIEWDEF.EQParInv'	OPERATION 5 ACCESS 0

Return( aMenu )

Static Function ModelDef()

Local oStruct  := FwFormStruct(1,"Z86")
Local oModel

oModel	:= MpFormModel():New("PEEQParInv",/*Pre-Validacao*/,/*Pós-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields("ID_ENCH_Z86",/*cOwner*/,oStruct,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

oModel:SetPrimaryKey( {"Z86_FILIAL","Z86_DATAIN"} )
oModel:SetDescription("Parâmetros do Inventário")
oModel:GetModel("ID_ENCH_Z86"):SetDescription("Parâmetros do Inventário")

Return(oModel)

Static Function ViewDef()

Local oStruct 	:= FwFormStruct(2,"Z86")
Local oModel 	:= FwLoadModel("EQParInv")
Local oView		:= FwFormView():New()

oView:SetModel(oModel)
oView:AddField("ID_VIEW_Z86", oStruct, "ID_ENCH_Z86")

oView:CreateHorizontalBox("ID_HBOX", 100)
oView:SetOwnerView("ID_VIEW_Z86", "ID_HBOX")
oView:EnableTitleView("ID_VIEW_Z86")

Return( oView )