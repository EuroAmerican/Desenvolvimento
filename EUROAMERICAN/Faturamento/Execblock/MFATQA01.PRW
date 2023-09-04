#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

Static cTitulo := "Tipo de Motivos Qualidade"
/*/{Protheus.doc} MFATQA01
description Manutencao do cadastro de tipo de motivos
@type function
@version  
@author paulo.lenzi
@since 26/05/2023
@return variant, return_description
/*/
User Function MFATQA01()
	Local aArea   := GetArea()
	Local oBrowse
	Local cFunBkp := FunName()
	SetFunName("MFATQA01")
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetAlias("ZZK")
	oBrowse:SetMenuDef("MFATQA01")
	oBrowse:Activate()
	
	SetFunName(cFunBkp)
	RestArea(aArea)
Return

/*/{Protheus.doc} MenuDef
description Definicao do Menu
@type function
@version  
@author paulo.lenzi
@since 26/05/2023
@return variant, return_description
/*/
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Pesquisar"  			Action "PesqBrw" 			OPERATION 1 ACCESS 0   //"Pesquisar"
	ADD OPTION aRotina TITLE 'Visualizar' 		    ACTION 'VIEWDEF.MFATQA01'	OPERATION 2 ACCESS 0 
	ADD OPTION aRotina Title 'Incluir'    			Action 'VIEWDEF.MFATQA01' 	OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'    			Action 'VIEWDEF.MFATQA01' 	OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Copiar'     			Action 'VIEWDEF.MFATQA01' 	OPERATION 9 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'     			Action 'VIEWDEF.MFATQA01' 	OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'    			Action 'VIEWDEF.MFATQA01' 	OPERATION 8 ACCESS 0
Return aRotina

/*/{Protheus.doc} ModelDef
description Modelagem 
@type function
@version  
@author paulo.lenzi
@since 26/05/2023
@return variant, return_description
/*/
Static Function ModelDef()
	Local oModel := Nil
	Local oStZZK := FWFormStruct(1, "ZZK")
	oModel := MPFormModel():New("UMFATQA010",/*bPre*/,/*bPos*/,/*bCommit*/,/*bCancel*/) 
	oModel:AddFields("FORMZZK",/*cOwner*/,oStZZK)
	oModel:SetPrimaryKey({'ZZK_FILIAL', 'ZZK_TIPO'})
	oModel:SetDescription(cTitulo)
	oModel:GetModel("FORMZZK"):SetDescription(cTitulo)
Return oModel

/*/{Protheus.doc} ViewDef
description Visão
@type function
@version  
@author paulo.lenzi
@since 26/05/2023
@return variant, return_description
/*/
Static Function ViewDef()
	Local oModel := FWLoadModel("MFATQA01")
	Local oStZZK := FWFormStruct(2, "ZZK") 
	Local oView := Nil
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_ZZK", oStZZK, "FORMZZK")
	oView:CreateHorizontalBox("TELA",100)
	//oView:EnableTitleView('VIEW_ZZK',cTitulo )  
	//oView:SetCloseOnOk({||.T.})
	//oView:SetOwnerView("VIEW_ZZK","TELA")
	
Return oView


