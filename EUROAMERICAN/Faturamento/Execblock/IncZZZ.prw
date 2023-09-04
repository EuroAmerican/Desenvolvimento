
#include 'protheus.ch'
#include 'parmtype.ch'
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "ap5mail.ch"
#Include "Totvs.ch"
#Include "FwBrowse.ch"
#Include "FwMvcDef.ch"


User Function IncZZZ()

Private oBrowse := FwMBrowse():New()

oBrowse:SetAlias("ZZZ")
oBrowse:SetDescription("Cadastro Família")
oBrowse:Activate()

Return

Static Function MenuDef()

Local aMenu := {}

ADD OPTION aMenu TITLE 'Pesquisar' 	ACTION 'PesqBrw'			OPERATION 1 ACCESS 0
ADD OPTION aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.IncZZZ'	OPERATION 2 ACCESS 0
ADD OPTION aMenu TITLE 'Incluir' 	ACTION 'VIEWDEF.IncZZZ'	OPERATION 3 ACCESS 0
ADD OPTION aMenu TITLE 'Alterar' 	ACTION 'VIEWDEF.IncZZZ'	OPERATION 4 ACCESS 0
ADD OPTION aMenu TITLE 'Excluir' 	ACTION 'VIEWDEF.IncZZZ'	OPERATION 5 ACCESS 0

Return( aMenu )

Static Function ModelDef()

Local oStruct  := FwFormStruct(1,"ZZZ")
Local oModel

oModel	:= MpFormModel():New("PEIncZZZ",/*Pre-Validacao*/,{ |oModel| fPosValid( oModel ) }/*Pós-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields("ID_ENCH_ZZZ",/*cOwner*/,oStruct,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

oModel:SetPrimaryKey( {"ZZZ_FILIAL","ZZZ_COD"} )
oModel:SetDescription("Cadastro Família")
oModel:GetModel("ID_ENCH_ZZZ"):SetDescription("Cadastro Família")

//BLOQUEIO DO CAMPO NA ALTERAÇÃO
oStruct:SetProperty("ZZZ_COD", MODEL_FIELD_WHEN, {|| LockUnlock()})
//oStruct:SetProperty("ZZZ_COD", MODEL_FIELD_WHEN, {|| INCLUI}) // PODE SER USADO DESSA FORMA 

Return(oModel)

Static Function ViewDef()

Local oStruct 	:= FwFormStruct(2,"ZZZ")
Local oModel 	:= FwLoadModel("IncZZZ")
Local oView		:= FwFormView():New()

oView:SetModel(oModel)
oView:AddField("ID_VIEW_ZZZ", oStruct, "ID_ENCH_ZZZ")

oView:CreateHorizontalBox("ID_HBOX", 100)
oView:SetOwnerView("ID_VIEW_ZZZ", "ID_HBOX")
oView:EnableTitleView("ID_VIEW_ZZZ")

Return( oView )

Static Function fPosValid( oModel )

Local lRetorno  := .T.
//Local aArea     := GetArea()
Local oModel    := FWModelActive()
Local oView     := FWViewActive()
Local oModelZZZ := oModel:GetModel('ID_ENCH_ZZZ')
Local cCodigo   := oModelZZZ:GetValue('ZZZ_COD')
Local cQry      := ''


    If oModel:GetOperation() == MODEL_OPERATION_DELETE 
        
    cQry := "SELECT TOP 1 B1_XSUBFAM FROM "+RetSqlName("SB1")+" SB1" + CRLF
    cQry += "WHERE D_E_L_E_T_ = '' AND B1_XSUBFAM = '"+cCodigo+"'"

        TCQUERY cQry NEW ALIAS QRY


        While !QRY->(EOF())      
        If QRY->B1_XSUBFAM == cCodigo
           Help(,, "fPosValid",, "Não pode ser excluido" + CRLF + "Esse código encontra - se em uso no cadastro do produto, Verifique!", 1, 0 )
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