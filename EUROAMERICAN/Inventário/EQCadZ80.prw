#include "Totvs.ch"
#include "FwMvcDef.ch"
#include "TbiConn.ch"
#include "TopConn.ch"

User Function EQCadZ80()

Private oBrowse := FwMBrowse():New()

oBrowse:SetAlias("Z80")
oBrowse:SetDescription("Cadastro Grupos de Equipes de Inventários")
oBrowse:Activate()

Return

Static Function MenuDef()

Local aMenu := {}

ADD OPTION aMenu TITLE 'Pesquisar' 	ACTION 'PesqBrw'			OPERATION 1 ACCESS 0
ADD OPTION aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.EQCadZ80'	OPERATION 2 ACCESS 0
ADD OPTION aMenu TITLE 'Incluir' 	ACTION 'VIEWDEF.EQCadZ80'	OPERATION 3 ACCESS 0
ADD OPTION aMenu TITLE 'Alterar' 	ACTION 'VIEWDEF.EQCadZ80'	OPERATION 4 ACCESS 0
ADD OPTION aMenu TITLE 'Excluir' 	ACTION 'VIEWDEF.EQCadZ80'	OPERATION 5 ACCESS 0

Return( aMenu )

Static Function ModelDef()

Local oStruct  := FwFormStruct(1,"Z80")
Local oModel

oModel	:= MpFormModel():New("PEEQCadZ80",/*Pre-Validacao*/,/*Pós-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields("ID_ENCH_Z80",/*cOwner*/,oStruct,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

oModel:SetPrimaryKey( {"Z80_FILIAL","Z80_CODIGO"} )
oModel:SetDescription("Cadastro Grupos de Equipes de Inventários")
oModel:GetModel("ID_ENCH_Z80"):SetDescription("Cadastro Grupos de Equipes de Inventários")

Return(oModel)

Static Function ViewDef()

Local oStruct 	:= FwFormStruct(2,"Z80")
Local oModel 	:= FwLoadModel("EQCadZ80")
Local oView		:= FwFormView():New()

oView:SetModel(oModel)
oView:AddField("ID_VIEW_Z80", oStruct, "ID_ENCH_Z80")

oView:CreateHorizontalBox("ID_HBOX", 100)
oView:SetOwnerView("ID_VIEW_Z80", "ID_HBOX")
oView:EnableTitleView("ID_VIEW_Z80")

Return( oView )