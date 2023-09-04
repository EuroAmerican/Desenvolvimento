#include "totvs.ch"
#include "FwMvcDef.ch"
#include "tbiConn.ch"
#include "topConn.ch"

/*/{Protheus.doc} BePAcess - Acesso ao portal da Loja 
@author Rodrigo Sousza 
@version 1.0
@History Ajustado para atendter o portal da loja     
@Update 
/*/

User Function BePAcess()

Private oBrowse := FwMBrowse():New()

If AllTrim( __cUserId ) <> "000000"
	PswOrder(1)

	If (PswSeek( __cUserId, .T.))
		aGrupos := Pswret(1)
		If Ascan( aGrupos[1][10], "000000") == 0
			ApMsgAlert( "Acesso permitido apenas para usuários com perfil administrador do sistema!", "Atenção")
			Return
		EndIf
	EndIf
EndIf

oBrowse:SetAlias("Z18")
oBrowse:SetDescription("Acesso Portal Protheus")
oBrowse:Activate()

Return
/*/{Protheus.doc} Manudef - Acesso ao portal da Loja 
@author Rodrigo Sousza 
@version 1.0
@History Ajustado para atendter o portal da loja     
@Update 
/*/
Static Function MenuDef()

Local aMenu := {}

ADD OPTION aMenu TITLE 'Pesquisar'	ACTION 'PesqBrw'			OPERATION 1 ACCESS 0
ADD OPTION aMenu TITLE 'Visualizar'	ACTION 'VIEWDEF.BePAcess'	OPERATION 2 ACCESS 0
ADD OPTION aMenu TITLE 'Incluir'	ACTION 'VIEWDEF.BePAcess'	OPERATION 3 ACCESS 0
ADD OPTION aMenu TITLE 'Alterar'	ACTION 'VIEWDEF.BePAcess'	OPERATION 4 ACCESS 0
ADD OPTION aMenu TITLE 'Excluir'	ACTION 'VIEWDEF.BePAcess'	OPERATION 5 ACCESS 0
ADD OPTION aMenu TITLE 'Cópia'		ACTION 'VIEWDEF.BePAcess'	OPERATION 9 ACCESS 0

Return(aMenu)
/*/{Protheus.doc} Modeldef- Acesso ao portal da Loja 
@author Rodrigo Sousza 
@version 1.0
@History Ajustado para atendter o portal da loja     
@Update 
/*/
Static Function ModelDef()

Local oStruct1 := FwFormStruct(1,"Z18",{|cCampo| BeTrataCpo(1,alltrim(cCampo)) } )
Local oStruct2 := FwFormStruct(1,"Z18",{|cCampo| BetrataCpo(2,alltrim(cCampo)) } )
Local oModel

oModel := MpFormModel():New("PEPACESS",/*Pre-Validacao*/, { |oModel| fPosValid( oModel ) },/*Commit*/,/*Cancel*/)
oModel:AddFields("ID_MODEL_ENCH_PACESS",/*cOwner*/,oStruct1,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

oModel:SetPrimaryKey({"Z18_CODUSR","Z18_CODMOD","Z18_ORDEM","Z18_ROTINA"})
oModel:SetDescription("Acesso Portal Protheus")
oModel:GetModel("ID_MODEL_ENCH_PACESS"):SetDescription("Acesso Portal Protheus")

oModel:AddGrid("ID_MODEL_GRID_PACESS","ID_MODEL_ENCH_PACESS",oStruct2,{ |oModelGrid, nLine, cAction, cField| BePreVldLin(oModelGrid, nLine, cAction, cField)},{ |oModelGrid, nLine| BePosVldLin(oModelGrid, nLine) })

oModel:GetModel("ID_MODEL_GRID_PACESS"):SetUniqueLine({"Z18_CODMOD","Z18_CODMOD","Z18_ROTINA"})
oModel:SetRelation("ID_MODEL_GRID_PACESS", { {"Z18_FILIAL",'xFilial("Z18")'},{"Z18_CODUSR","Z18_CODUSR"} }, Z18->(IndexKey()) )

Return(oModel)
/*/{Protheus.doc} ViewDef - Acesso ao portal da Loja 
@author Rodrigo Sousza 
@version 1.0
@History Ajustado para atendter o portal da loja     
@Update 
/*/
Static Function ViewDef()

Local oStruct1 	:= FwFormStruct(2,"Z18",{|cCampo| BeTrataCpo(1,alltrim(cCampo)) } )
Local oStruct2 	:= FwFormStruct(2,"Z18",{|cCampo| BeTrataCpo(2,alltrim(cCampo)) } )
Local oModel 	:= FwLoadModel("BePAcess")
Local oView		:= FwFormView():New()

oView:SetModel(oModel)
oView:AddField("ID_VIEW_ENCH_PACESS",oStruct1,"ID_MODEL_ENCH_PACESS")
oView:AddGrid("ID_VIEW_GRID_PACESS",oStruct2,"ID_MODEL_GRID_PACESS")

oView:AddIncrementField( 'ID_VIEW_GRID_PACESS', 'Z18_ORDEM' )

oView:CreateHorizontalBox("H_TOP",30)
oView:CreateHorizontalBox("H_DOWN",70)

oView:SetOwnerView("ID_VIEW_ENCH_PACESS","H_TOP")
oView:SetOwnerView("ID_VIEW_GRID_PACESS","H_DOWN")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Habilita Titulo da View 					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:EnableTitleView('ID_VIEW_ENCH_PACESS','Usuario')
oView:EnableTitleView('ID_VIEW_GRID_PACESS','Rotinas')

Return (oView)

/*/{Protheus.doc} BePosVldLin - Acesso ao portal da Loja 
@author Rodrigo Sousza 
@version 1.0
@History Ajustado para atendter o portal da loja
@param   oModelGrid,nLine   
@Update 
/*/

Static Function BePosVldLin(oModelGrid,nLine)

Local lRet			:= .T.
Local oModel 		:= oModelGrid:GetModel()
Local nOperation 	:= oModel:GetOperation()
Local cCodUsr		:= oModel:GetValue('ID_MODEL_ENCH_PACESS','Z18_CODUSR')
Local cCodMod		:= oModel:GetValue('ID_MODEL_GRID_PACESS','Z18_CODMOD')
Local cOrdem		:= oModel:GetValue('ID_MODEL_GRID_PACESS','Z18_ORDEM')
Local cRotina		:= oModel:GetValue('ID_MODEL_GRID_PACESS','Z18_ROTINA')
                                    
If nOperation == MODEL_OPERATION_INSERT
	If !ExistChav("Z18",cCodUsr+cCodMod+cOrdem+cRotina,1,"JAGRAVADO")
		lRet := .F.	
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} BePreVldLin - Acesso ao portal da Loja 
@author Rodrigo Sousza 
@version 1.0
@History Ajustado para atendter o portal da loja
@param   oModelGrid, nLine, cAction, cField   
@Update 
/*/

Static Function BePreVldLin(oModelGrid, nLine, cAction, cField)
   
Local lRet 			:= .T.     
Local oModel 		:= oModelGrid:GetModel()
Local nOperation 	:= oModel:GetOperation()  
Local cCodUsr		:= oModel:GetValue('ID_MODEL_ENCH_PACESS','Z18_CODUSR')

If cAction = 'CANSETVALUE' 
	If nOperation == MODEL_OPERATION_UPDATE .And. cField == 'Z18_CODUSR' .And. !Empty(cCodUsr)
    	lRet := .F.       
    EndIf	
EndIf

Return lRet

/*/{Protheus.doc} BeTrataCpo - Acesso ao portal da Loja 
@author Rodrigo Sousza 
@version 1.0
@History Ajustado para atendter o portal da loja
@param   nOpc,cCampo   
@Update 
/*/

Static Function BeTrataCpo(nOpc,cCampo)

Local lRet := .F.

If nOpc == 1
	lRet := cCampo $ "Z18_CODUSR|Z18_NOMUSR|Z18_DCOMPR|Z18_DAPRCC|Z18_DCOLAB"
Else	
	lRet := !cCampo $ "Z18_CODUSR|Z18_NOMUSR|Z18_DCOMPR|Z18_DAPRCC|Z18_DCOLAB"
EndIf	

Return (lRet)

Static Function fPosValid( oModel )

Local lRetorno := .T.
Local aArea     := GetArea()
Local nOpc      := oModel:GetOperation()  // Pega a operacao a ser realizada
Local cQuery    := ""
Local oModelZ18 := oModel:GetModel("ID_MODEL_ENCH_PACESS")
Local cUsuario  := oModelZ18:GetValue("Z18_CODUSR")
Local lCompras  := oModelZ18:GetValue("Z18_DCOMPR")
Local lCartao   := oModelZ18:GetValue("Z18_DAPRCC")
Local lColabor  := oModelZ18:GetValue("Z18_DCOLAB")

If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE
	cQuery := "UPDATE " + RetSqlName("Z18") + " "
	cQuery += "SET Z18_DCOMPR = '" + IIf(lCompras, "T", "F") + "', Z18_DAPRCC = '" + IIf(lCartao, "T", "F") + "', Z18_DCOLAB = '" + IIf(lColabor, "T", "F") + "' "
	cQuery += "WHERE Z18_FILIAL = '" + xFilial("Z18") + "' "
	cQuery += "AND Z18_CODUSR = '" + cUsuario + "' "
	cQuery += "AND D_E_L_E_T_ = ' ' "

	TcSqlExec( cQuery )
EndIf

Return lRetorno
