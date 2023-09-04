#INCLUDE "RWMAKE.CH"       
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TRYEXCEPTION.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "TOPCONN.CH" 

#Define ALIAS_FORM0 			"PAY" //Informe o Alias da Tabela
#Define MODELO					"QELAB008"
#Define ID_MODEL				"QELABM08"
#Define TITULO_MODEL			"Tabela de Impressão de Etiquetas" 
#Define TITULO_VIEW				TITULO_MODEL
#Define ID_MODEL_FORM0			ALIAS_FORM0+"FORM0"
#Define ID_VIEW_FORM0			"VIEW_FORM0"
#Define PREFIXO_ALIAS_FORM0		Right(ALIAS_FORM0,03)

#DEFINE TYPE_HEADER				1
#DEFINE TYPE_ITEMS				2

#DEFINE ENTER chr(13) + chr(10)

/*/{Protheus.doc} QElab008 - Analise Impressão de Eqtiqueta 
Fonte Modelo de MVC - Interface Modelo 1 para Analise Impressão de Eqtiqueta  
@type function
@author fabio Caraneiro dos Santos
@since 07/10/2022
@version P12
@database MSSQL
@param [aAutoCab], Array, Array com os Dados do Cabeçalho no Formato de Rotina Automática (Vide Campos de Cabeçalho na Interface)
@param [nOperacao], Numerico, Operação a ser realizada, sendo 3=Inclusão, 4=Alteração, 5=Exclusão
/*/ 
User Function QELAB008(aAutoCab,nOperacao)
	Local oFwMBrowse		:= Nil
	Local cAliasForm 		:= ALIAS_FORM0
	Local cModelo			:= MODELO
	Local cTitulo			:= TITULO_MODEL
	Local cIDModelForm		:= ID_MODEL_FORM0
	Local bKeyCTRL_X		:= {|| }
	Local bFecharEdicao		:= {|| ( oView := FwViewActive(), Iif( Type("oView") == "O" , oView:ButtonCancelAction() , .F. ) ) }
	
	If ValType(aAutoCab) == "A"
		runAutoExecute(aAutoCab,nOperacao)
	Else	
		Private aRotina		:= MenuDef()

		oFwMBrowse:= FWMBrowse():New()
		oFwMBrowse:SetAlias(cAliasForm)
		oFwMBrowse:SetDescription(cTitulo)
		oFwMBrowse:SetMenuDef(cModelo)
		
		oFwMBrowse:SetLocate()	
		oFwMBrowse:SetAmbiente(.F.)
		oFwMBrowse:SetWalkthru(.T.)		
		oFwMBrowse:SetDetails(.T.)
		oFwMBrowse:SetSizeDetails(60)
		oFwMBrowse:SetSizeBrowse(40)

		oFwMBrowse:SetCacheView(.T.)
		oFwMBrowse:AddLegend( cAliasForm+"_STATUS == '1'  ", "BR_VERDE"     , "Impressao Etiqueta" )
		oFwMBrowse:AddLegend( cAliasForm+"_STATUS == '2'  ", "BR_AZUL"      , "Data por Laudo" )
		oFwMBrowse:AddLegend( cAliasForm+"_STATUS == '3'  ", "BR_LARANJA"   , "Carga de Dados" )
		
		oFwMBrowse:SetAttach( .T. ) // permite trabalhar com a Visão 
		oFwMBrowse:SetOpenChart( .T. )	
		
		bKeyCTRL_X	:= SetKey( K_CTRL_X, bFecharEdicao )
				
		oFwMBrowse:Activate()
		
		SetKey( K_CTRL_X, bKeyCTRL_X )
	Endif
	
Return

/*
	Função que Define o Modelo de Dados do Cadastro
*/
Static Function ModelDef()
	Local cModelo			:= MODELO
	Local cIDModel			:= ID_MODEL
	Local cTitulo			:= TITULO_MODEL
	Local cIDModelForm		:= ID_MODEL_FORM0
	Local cAliasForm 		:= ALIAS_FORM0
	Local oStructForm 		:= Nil
	Local oModel 			:= Nil							 
	Local bActivate			:= {|oModel| activeForm(oModel) }
	Local bCommit			:= {|oModel| saveForm(oModel)}
	Local bCancel   		:= {|oModel| cancForm(oModel)}
	Local bPreValidacao		:= {|oModel| preValid(oModel)}
	Local bPosValidacao		:= {|oModel| posValid(oModel)} 
	
	Local cPrefForm			:= PREFIXO_ALIAS_FORM0
	Local cCpoFilial		:= cPrefForm+"_FILIAL"
	Local cCpoCodigo		:= cPrefForm+"_OP"
	Local cCpoProduto		:= cPrefForm+"_PROD"
	Local dCpoCtrl   		:= cPrefForm+"_CTRL"
	
	//PAY_FILIAL+PAY_OP+PAY_PROD+PAY_CTRL
	
	oStructForm	:= FWFormStruct( 1, cAliasForm )	

	oModel	:= MPFormModel():New(cIdModel,bPreValidacao,bPosValidacao,bCommit,/*bCancel*/)
	
	oModel:AddFields( cIDModelForm, /*cOwner*/, oStructForm,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)	
	
	oModel:SetPrimaryKey( { cCpoFilial, cCpoCodigo,cCpoProduto,dCpoCtrl } )
	oModel:SetActivate(bActivate)
	oModel:SetDescription(cTitulo)	
	oModel:GetModel(cIDModelForm):SetDescription(cTitulo)

Return oModel

/*
	Função que Cria a Interface do Cadastro
*/
Static Function ViewDef()
	Local cModelo			:= MODELO
	Local cIDModel			:= ID_MODEL
	Local cTitulo			:= TITULO_VIEW
	Local cIDModelForm		:= ID_MODEL_FORM0
	Local cIDViewForm		:= ID_VIEW_FORM0
	Local cAliasForm 		:= ALIAS_FORM0
	Local oModel 			:= Nil
	Local oStructForm		:= Nil
	Local oView				:= Nil
	Local nOperation		:= MODEL_OPERATION_INSERT
	Local cPrefForm			:= PREFIXO_ALIAS_FORM0
	Local cCpoFilial		:= cPrefForm+"_FILIAL"
	Local cCpoCodigo		:= cPrefForm+"_OP"
	Local cCpoProduto		:= cPrefForm+"_PROD"
	Local dCpoCtrl   		:= cPrefForm+"_CTRL"
	
	oModel 		:= FWLoadModel( cModelo )
	nOperacao	:= oModel:GetOperation()
	
	oStructForm	:= FWFormStruct( 2, cAliasForm )

	oView 		:= FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField(cIDViewForm,oStructForm,cIDModelForm)
	
	oView:SetViewProperty(cIDViewForm,"SETLAYOUT",{ FF_LAYOUT_VERT_DESCR_TOP , 5 } )	
	
	oView:CreateHorizontalBox('TOTAL',100)
	
	oView:SetOwnerView( cIDViewForm,'TOTAL' )
	
	oView:AddUserButton( 'Exportar Dados para o Excel', 'EXECUTE', {|| exportModeltoExcel(.T.) },'Exportar para Excel',VK_F9,,.F. )

Return oView

/*
	Rotina para Exportação de Dados do Modelo Ativo para o Excel
*/
Static Function exportModeltoExcel()
	Local oModel		:= FwModelActive()
	Local cIDModelForm	:= ID_MODEL_FORM0
	Local oModelForm	:= oModel:GetModel(cIDModelForm)
	Local aFormHeader	:= {}
	Local aFormData		:= {}
	Local aExport		:= {}
	Local bAcao 		:= { || }
	
	loadDataModel(oModelForm,@aFormHeader,@aFormData,.T.,TYPE_HEADER)

	aAdd( aExport, {"CABECALHO", oModelForm:GetDescription(), aFormHeader, aFormData } )
	
	bAcao 	:= { || DlgToExcel(aExport) }
	
	FwMsgRun( ,bAcao, "QUALY", "Exportando Dados para o Excel..." )
	
Return

/*
	Carrega os Dados de Estrutura do Model
*/
Static Function loadDataModel(oModel,aFields,aData,lUseTitle,nType)

	Local nRecord			:= 0
	Local nField			:= 0
	Local cField			:= ""	
	Local uContent			:= ""
	Local cAlias			:= ""
	Local aHeader			:= {}
	Local aRecord			:= {}
	Local oIpArraysObject	:= Nil
	
	Default lUseTitle		:= .T.
	
	aFields	:= {}
	aData	:= {}

	If ValType(oModel) == "O"
		If nType == TYPE_HEADER
			For nField:=1 to Len(oModel:oFormModelStruct:aFields)		
				cField 	:= oModel:oFormModelStruct:aFields[nField,03]
				
				If !Empty(cField)
					uContent	:= oModel:GetValue(cField)
					
					If lUseTitle
						cField := RetTitle(cField)
					Endif
					aAdd( aFields, cField )
					aAdd( aData, uContent )
				Endif
			Next nField
		Else	
			For nRecord:=1 to oModel:GetQtdLine()
				oModel:GoLine(nRecord)
		
				aRecord := {}
				For nField:=1 to Len(oModel:oFormModelStruct:aFields)				
					cField 		:= oModel:oFormModelStruct:aFields[nField,03]
					
					If !Empty(cField)
						uContent	:= oModel:GetValue(cField)			
				
						If nRecord == 1
							aAdd( aFields, cField )
						Endif
						aAdd( aRecord, uContent )
					Endif
				Next nField
				aAdd( aRecord, .F. )
				
				aAdd( aData , aRecord )
				
			Next nRecord
			
			oIpArraysObject := IpArraysObject():newIpArraysObject()
			aFields := oIpArraysObject:convToHeader(aFields,.T.)
			freeObj(oIpArraysObject)
		Endif
	Endif
	
Return

/*
	Função que Monta o Menu da Rotina do Cadastro
*/
Static Function MenuDef()
	Local cModelo	:= MODELO 
	Local aRotina 	:= {}

	//aRotina := FWMVCMenu( cModelo )
	
    ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.' + cModelo    OPERATION 2 ACCESS 0

Return aRotina

/*
	Função para Salvar os Dados do Cadastro usando MVC
*/ 
Static Function saveForm(oModel)

	Local nOperation	:= oModel:GetOperation()
	Local lRet 			:= .T.

	FWModelActive(oModel)
	lRet := FWFormCommit(oModel)

Return lRet

/*
	Função executado no Cancelamento da Tela de Cadastro
*/ 
Static Function cancForm(oModel)
	Local nOperation	:= oModel:GetOperation()
	Local lRet			:= .T.

	If nOperation == MODEL_OPERATION_INSERT
		RollBackSX8()
	EndIf		

Return lRet

/*
	Função para Validar os Dados Antes da Confirmação da Tela do Cadastro
*/
Static Function preValid(oModel)
	
	Local nOperation	:= oModel:GetOperation()
	Local lRet			:= .T.

Return lRet

/*
	Função para Validar os Dados Após Confirmação da Tela de Cadastro - Verifica se pode incluir
*/
Static Function posValid(oModel)
	/*
	O retrorno do oModel:GetOperation() abaixo: 
	1 - View
    3 - Insert
    4 - Update
    5 - Delete
    6 - Only Update
	*/	
	Local nOperation	:= oModel:GetOperation()
	Local lRet			:= .T.

Return lRet

/*
	Função de Validação executada na Ativação do Modelo
*/
Static Function activeForm(oModel)
	Local cIDModelForm		:= ID_MODEL_FORM0
	Local nOperation		:= oModel:GetOperation()
	Local oModelForm		:= oModel:GetModel(cIDModelForm)
	Local aSaveLines 		:= FWSaveRows()
	Local nRecord			:= 0
	Local lRet				:= .T.

	Local cPrefForm			:= PREFIXO_ALIAS_FORM0	
	
Return lRet

/*
	Executa a Rotina Automática de Gravação
*/
Static Function runAutoExecute(aAutoCab,nOperacao)
	Local cModelo 		:= MODELO
	Local cAliasForm 	:= ALIAS_FORM0
	Local cIDModelForm 	:= cAliasForm+"FORM0"
	Local oClassMVCAuto := ClassMVCAuto():newClassMVCAuto()	
	Local aRet			:= {}
	Local cErro			:= ""
	Local lRet 			:= .F.
	
	Default aAutoCab	:= {}
	Default nOperacao	:= 3
	
	If podeExecutar(aAutoCab,@cErro)

		//Se chamado por rotina externa - Reduz a Carga de Dados do Dicionário de Dados
		If Type("oQELAB008") == "O"
			oClassMVCAuto:setObjectModel(oQECTB001)
		Endif
	
		oClassMVCAuto:setAliasForm(cAliasForm)
		oClassMVCAuto:setModelo(cModelo)
		oClassMVCAuto:setModelForm(cIDModelForm)
		
		oClassMVCAuto:setAutoCab(aAutoCab)
		oClassMVCAuto:setOperacao(nOperacao)
		oClassMVCAuto:setUseTransaction(.T.)
		
		oClassMVCAuto:setRegMemory(.T.)
		
		aRet 	:= oClassMVCAuto:execute()	
		lRet	:= aRet[01]
		cErro   := aRet[02]
	Endif
	
	If lRet
		lMsErroAuto := .F.
	Else
		lMsErroAuto := .T.
		showLogInConsole(cErro)
		Help(,,"HELP",,cErro,1,0)
	Endif

Return lRet

/*
	Verifica se pode Executar
*/
Static Function podeExecutar(aAutoCab,cErro)
	Local lRet	:= .F.
	
	Begin Sequence
	
		If Len(aAutoCab) == 0
			cErro := "Falha na Carga dos Dados de Cabeçalho."
			Break
		Endif
		
		lRet := .T.
	
	End Sequence
	
	If !lRet
		showLogInConsole(cErro)
	Endif
	
Return lRet

/*
	Apresenta a Mensagem no Console do Protheus
*/
Static Function showLogInConsole(cMensagem,lAtivaLog,cPrefixo)
	Default lAtivaLog	:= GetNewPar("ZZ_LOGS",.T.)
	Default cMensagem 	:= ""
	Default cPrefixo	:= "[QEAMOD01][" + DtoC(DDATABASE) + "][" + Time() + "] "	
Return


