#include 'protheus.ch'
#include 'parmtype.ch'
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "ap5mail.ch"
#Include "Totvs.ch"
#Include "FwBrowse.ch"
#Include "FwMvcDef.ch"


User Function IncZZX()

Private oBrowse := FwMBrowse():New()

oBrowse:SetAlias("ZZX")
oBrowse:SetDescription("Cadastro Sub Família")
oBrowse:Activate()

Return

Static Function MenuDef()

Local aMenu := {}

ADD OPTION aMenu TITLE 'Pesquisar' 	ACTION 'PesqBrw'			OPERATION 1 ACCESS 0
ADD OPTION aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.IncZZX'	OPERATION 2 ACCESS 0
ADD OPTION aMenu TITLE 'Incluir' 	ACTION 'VIEWDEF.IncZZX'	OPERATION 3 ACCESS 0
ADD OPTION aMenu TITLE 'Alterar' 	ACTION 'VIEWDEF.IncZZX'	OPERATION 4 ACCESS 0
ADD OPTION aMenu TITLE 'Excluir' 	ACTION 'VIEWDEF.IncZZX'	OPERATION 5 ACCESS 0

Return( aMenu )

Static Function ModelDef()

Local oStruct  := FwFormStruct(1,"ZZX")
Local oModel

oModel	:= MpFormModel():New("PEIncZZX",/*Pre-Validacao*/,{ |oModel| fPosValid( oModel ) }/*Pós-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields("ID_ENCH_ZZX",/*cOwner*/,oStruct,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

oModel:SetPrimaryKey( {"ZZX_FILIAL","ZZX_CODIGO"} )
oModel:SetDescription("Cadastro Sub Família")
oModel:GetModel("ID_ENCH_ZZX"):SetDescription("Cadastro Sub Família")

//BLOQUEIO DO CAMPO NA ALTERAÇÃO
oStruct:SetProperty("ZZX_CODIGO", MODEL_FIELD_WHEN, {|| LockUnlock()})
//oStruct:SetProperty("ZZX_CODIGO", MODEL_FIELD_WHEN, {|| INCLUI}) // PODE SER USADO DESSA FORMA 

Return(oModel)

Static Function ViewDef()

Local oStruct 	:= FwFormStruct(2,"ZZX")
Local oModel 	:= FwLoadModel("IncZZX")
Local oView		:= FwFormView():New()

oView:SetModel(oModel)
oView:AddField("ID_VIEW_ZZX", oStruct, "ID_ENCH_ZZX")

oView:CreateHorizontalBox("ID_HBOX", 100)
oView:SetOwnerView("ID_VIEW_ZZX", "ID_HBOX")
oView:EnableTitleView("ID_VIEW_ZZX")

Return( oView )

Static Function fPosValid( oModel )

Local lRetorno  := .T.
//Local aArea     := GetArea()
Local oModel    := FWModelActive()
Local oView     := FWViewActive()
Local oModelZZX := oModel:GetModel('ID_ENCH_ZZX')
Local cCodigo   := oModelZZX:GetValue('ZZX_CODIGO')
Local cQry      := ''


    If oModel:GetOperation() == MODEL_OPERATION_DELETE 
        
    cQry := "SELECT TOP 1 B1_XFAMILI FROM SB1000 WHERE D_E_L_E_T_ = '' AND B1_XFAMILI = '"+cCodigo+"'"

        TCQUERY cQry NEW ALIAS QRY


        While !QRY->(EOF())      
        If QRY->B1_XFAMILI == cCodigo
           Help( ,, "fPosValid",, "Não pode ser excluido" + CRLF + "Esse código encontra - se em uso no cadastro do produto, Verifique!", 1, 0 )
            lRetorno := .F.
            Exit
        EndIf  
        QRY->(DBSkip())
        EndDo
    QRY->(dbCloseArea())
    EndIf    
    
//RestArea( aArea )

Return lRetorno


// FUNÇÃO PARA VALIDAÇÃO
Static Function LockUnlock(oModel)
    Local oModel    := FWModelActive()
    Local oView     := FWViewActive()
    Local lLock := .T.

    If  oModel:GetOperation() == MODEL_OPERATION_UPDATE
        lLock := .F.
    EndIf
Return (lLock)