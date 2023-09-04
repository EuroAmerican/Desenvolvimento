#include "Totvs.ch"
#include "FwMvcDef.ch"
#include "TbiConn.ch"
#include "TopConn.ch"

User Function EQCadZ85()

Private oBrowse := FwMBrowse():New()

oBrowse:SetAlias("Z85")
oBrowse:SetDescription("Cadastro Excessões Produtos para Contagem")
oBrowse:Activate()

Return

Static Function MenuDef()

Local aMenu := {}

ADD OPTION aMenu TITLE 'Pesquisar' 	ACTION 'PesqBrw'			OPERATION 1 ACCESS 0
ADD OPTION aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.EQCadZ85'	OPERATION 2 ACCESS 0
ADD OPTION aMenu TITLE 'Incluir' 	ACTION 'VIEWDEF.EQCadZ85'	OPERATION 3 ACCESS 0
ADD OPTION aMenu TITLE 'Alterar' 	ACTION 'VIEWDEF.EQCadZ85'	OPERATION 4 ACCESS 0
ADD OPTION aMenu TITLE 'Excluir' 	ACTION 'VIEWDEF.EQCadZ85'	OPERATION 5 ACCESS 0

Return( aMenu )

Static Function ModelDef()

Local oStruct  := FwFormStruct(1,"Z85")
Local oModel

oModel	:= MpFormModel():New("PEEQCadZ85",/*Pre-Validacao*/,/*Pós-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields("ID_ENCH_Z85",/*cOwner*/,oStruct,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

oModel:SetPrimaryKey( {"Z85_FILIAL","Z85_PRODUT"} )
oModel:SetDescription("Cadastro Excessões Produtos para Contagem")
oModel:GetModel("ID_ENCH_Z85"):SetDescription("Cadastro Excessões Produtos para Contagem")

Return(oModel)

Static Function ViewDef()

Local oStruct 	:= FwFormStruct(2,"Z85")
Local oModel 	:= FwLoadModel("EQCadZ85")
Local oView		:= FwFormView():New()

oView:SetModel(oModel)
oView:AddField("ID_VIEW_Z85", oStruct, "ID_ENCH_Z85")

oView:CreateHorizontalBox("ID_HBOX", 100)
oView:SetOwnerView("ID_VIEW_Z85", "ID_HBOX")
oView:EnableTitleView("ID_VIEW_Z85")

Return( oView )