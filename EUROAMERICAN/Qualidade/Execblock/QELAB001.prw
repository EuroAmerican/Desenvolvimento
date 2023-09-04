#INCLUDE "RWMAKE.CH"       
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "TOPCONN.CH" 

#Define ALIAS_FORM0 			"PA8" //Informe o Alias da Tabela de Cabeçalho
#Define ALIAS_GRID0 			"PA9" //Informe o Alias da Tabela de Itens
#Define MODELO					"QELAB001"
#Define ID_MODEL				"MQELAB001"
#Define TITULO_MODEL			"Cadastro Roteiro de Operação Laboratorio "
#Define TITULO_VIEW				TITULO_MODEL
#Define ID_MODEL_FORM0			ALIAS_FORM0+"FORM0"
#Define ID_MODEL_GRID0			ALIAS_GRID0+"GRID0"
#Define ID_VIEW_FORM0			"VIEW_FORM0"
#Define ID_VIEW_GRID0			"VIEW_GRID0"
#Define PREFIXO_ALIAS_FORM0		Right(ALIAS_FORM0,03)
#Define PREFIXO_ALIAS_GRID0		Right(ALIAS_GRID0,03)

#DEFINE STATUS_LIBERADO 		"2"
#DEFINE STATUS_DESBLOQUEADO		"1"

#DEFINE TYPE_HEADER				1
#DEFINE TYPE_ITEMS				2

#DEFINE ENTER chr(13) + chr(10)

/*/{Protheus.doc} QELAB001
Cadastro de roteiro de operações laboratorio modelo Modelo 3
@type function
@author Fabio Carneiro dos Santos 
@since 30/09/2022
@version P12
@database MSSQL
@param [aAutoCab], Array, Array com os Dados do Cabeçalho no Formato de Rotina Automática (Vide Campos de Cabeçalho na Interface)
@param [aAutoItens], Array, Array com os Dados dos Itens no Formato de Rotina Automática
@param [nOperacao], Numerico, Operação a ser realizada, sendo 3=Inclusão, 4=Alteração, 5=Exclusão
/*/ 
User Function QELAB001(aAutoCab,aAutoItens,nOperacao)
	Local oFwMBrowse		:= Nil
	Local cAliasForm		:= ALIAS_FORM0
	Local cModelo			:= MODELO
	Local cTitulo			:= TITULO_VIEW
	Local cIDModelForm		:= ID_MODEL_FORM0
	Local cIDModelGrid		:= ID_MODEL_GRID0
	Local bKeyCTRL_X		:= {|| }
	Local bFecharEdicao		:= {|| ( oView := FwViewActive(), Iif( Type("oView") == "O" , oView:ButtonCancelAction() , .F. ) ) }			
		
	If ValType(aAutoCab) == "A" .And. ValType(aAutoItens) == "A" 
		runAutoExecute(aAutoCab,aAutoItens,nOperacao)
	Else		
		Private aRotina 	:= MenuDef()

		oFwMBrowse := FWMBrowse():New()
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
		
		oFwMBrowse:AddLegend( cAliasForm + "_MSBLQL == '" + STATUS_DESBLOQUEADO + "'" , "RED"	, "BLOQUEADO" ) 
		oFwMBrowse:AddLegend( cAliasForm + "_MSBLQL == '" + STATUS_LIBERADO + "'" , "GREEN"	, "LIBERADO" ) 
		
		oFwMBrowse:SetAttach( .T. )
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
	Local cModelo				:= MODELO
	Local cIDModel				:= ID_MODEL
	Local cTitulo				:= TITULO_MODEL
	Local cIDModelForm			:= ID_MODEL_FORM0
	Local cIDModelGrid			:= ID_MODEL_GRID0
	Local cAliasForm 			:= ALIAS_FORM0
	Local cAliasGrid 			:= ALIAS_GRID0
	Local oStructForm 			:= Nil
	Local oStructGrid			:= Nil
	Local oModel 				:= Nil							 
	Local bActivate				:= {|oModel| activeForm(oModel) }
	Local bCommit				:= {|oModel| saveForm(oModel)}
	Local bCancel   			:= {|oModel| cancForm(oModel)}
	Local bpreValidacao			:= {|oModel| preValid(oModel)}
	Local bposValidacao			:= {|oModel| posValid(oModel)} 
	Local bLinePosVal           := {|oModel| posLineValid(oModel)}  
	Local cPrefForm				:= PREFIXO_ALIAS_FORM0
	Local cPrefGrid				:= PREFIXO_ALIAS_GRID0
	Local cCpoFormFilial		:= cPrefForm+"_FILIAL"
	Local cCpoFormReferencia	:= cPrefForm+"_ID"
	Local cCpoGridFilial		:= cPrefGrid+"_FILIAL"
	Local cCpoGridReferencia	:= cPrefGrid+"_ID"
	Local cCpoGridItemProduto	:= cPrefGrid+"_ITEM"
	Local cCpoGridProduto		:= cPrefGrid+"_COD"
	                                              
	oStructForm		:= FWFormStruct( 1, cAliasForm )
	oStructGrid 	:= FWFormStruct( 1, cAliasGrid )
	
	oModel	:= MPFormModel():New(cIdModel,bpreValidacao,bposValidacao,bCommit,bCancel)
	
	oModel:AddFields(cIDModelForm, /*cOwner*/, oStructForm,/*bpreValidacao*/,/*bposValidacao*/,/*bCarga*/)
	
	oModel:AddGrid( cIDModelGrid,cIDModelForm,oStructGrid,/*bLinePosVal*/,/*bLinePost*/,bLinePosVal,/*bLinePosVal*/)
	oModel:GetModel(cIDModelGrid):SetUniqueLine( { cCpoGridItemProduto } ) //cCpoGridProduto	
	oModel:SetRelation(cIDModelGrid,{{cCpoGridFilial,'xFilial("'+cAliasForm+'")'},{cCpoGridReferencia,cCpoFormReferencia}},(cAliasGrid)->(IndexKey(1)))	

	If !( IsBlind() )
		oModel:GetModel(cIDModelGrid):SetNoInsertLine(.F.)
		oModel:GetModel(cIDModelGrid):SetNoDeleteLine(.F.)
	Endif
	
	oModel:SetPrimaryKey( { cCpoFormFilial, cCpoFormReferencia } )
	oModel:SetActivate(bActivate)
	oModel:SetDescription(cTitulo)	
	oModel:GetModel(cIDModelForm):SetDescription(cTitulo)

Return oModel

/*
	Função que Cria a Interface do Cadastro
*/
Static Function ViewDef()
	Local cModelo				:= MODELO
	Local cIDModel				:= ID_MODEL
	Local cTitulo				:= TITULO_VIEW
	Local cIDModelForm			:= ID_MODEL_FORM0
	Local cIDModelGrid			:= ID_MODEL_GRID0
	Local cIDViewForm			:= ID_VIEW_FORM0
	Local cIDViewGrid			:= ID_VIEW_GRID0
	Local cAliasForm 			:= ALIAS_FORM0
	Local cAliasGrid 			:= ALIAS_GRID0
	Local oModel 				:= Nil
	Local oStructForm			:= Nil
	Local oStructGrid			:= Nil
	Local oView					:= Nil
	
	Local cPrefForm				:= PREFIXO_ALIAS_FORM0
	Local cPrefGrid				:= PREFIXO_ALIAS_GRID0
	Local cCpoGridReferencia	:= cPrefGrid+"_ID"
	//Local cCpoGridTipo			:= cPrefGrid+"_TIPO"
	Local cCposToHide			:= cCpoGridReferencia
	Local cCpoGridItem			:= cPrefGrid+"_ITEM"

	oModel 			:= FWLoadModel( cModelo )
	
	oStructForm		:= FWFormStruct( 2, cAliasForm )
	oStructGrid	 	:= FWFormStruct( 2, cAliasGrid , {|cCampo| !( AllTrim(cCampo)+"|" $ cCposToHide) })	

	oView 			:= FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField(cIDViewForm,oStructForm,cIDModelForm)
	oView:AddGrid(cIDViewGrid,oStructGrid,cIDModelGrid)
	
	oView:CreateHorizontalBox('SUPERIOR',30)
	oView:CreateHorizontalBox('INFERIOR',70)
	
	oView:SetOwnerView( cIDViewForm,'SUPERIOR' )
	oView:SetOwnerView( cIDViewGrid,'INFERIOR' )
	
	oView:SetViewProperty(cIDViewForm,"SETLAYOUT",{ FF_LAYOUT_VERT_DESCR_TOP , 5 } )
	
	oView:SetViewProperty(cIDViewGrid,"ENABLENEWGRID")
	oView:SetViewProperty(cIDViewGrid,"GRIDFILTER")
	oView:SetViewProperty(cIDViewGrid,"GRIDSEEK")	
	
	oView:AddIncrementField( cIDViewGrid, cCpoGridItem )
	
Return oView
/*
	Função que Monta o Menu da Rotina do Cadastro
*/
Static Function MenuDef()
	Local cModelo	:= MODELO 
	Local aRotina 	:= {}
	ADD OPTION aRotina TITLE "Visualizar"				ACTION "u_MOD03Manutencao(" + cValToChar(MODEL_OPERATION_VIEW)   + ")" 	OPERATION 2	ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"					ACTION "u_MOD03Manutencao(" + cValToChar(MODEL_OPERATION_INSERT) + ")" 	OPERATION 3	ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"					ACTION "u_MOD03Manutencao(" + cValToChar(MODEL_OPERATION_UPDATE) + ")" 	OPERATION 4	ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"					ACTION "u_MOD03Manutencao(" + cValToChar(MODEL_OPERATION_DELETE) + ")" 	OPERATION 5	ACCESS 0
    ADD OPTION aRotina TITLE 'Copiar'                   ACTION 'VIEWDEF.' + cModelo    OPERATION 9 ACCESS 0

Return aRotina

/*
	Rotina para Manutenção do Registro
*/
User Function MOD03Manutencao(nOperation)
	Local cModelo		:= MODELO
	Local cOperacao		:= ""
	Local bAcao			:= {|| }
	Local bCloseOnOK	:= {|| .F. }
	Local bOK			:= {|| .T. }
	Local bCancel		:= {|| .T. }
	Local lRet			:= .F.
	
	Private VISUALIZAR	:= .F.
	Private INCLUI		:= .F.
	Private ALTERA		:= .F.
	Private EXCLUI		:= .F.
	Private COPIA		:= .F.
	Private nRet		:= 0
	
	If ( nOperation == MODEL_OPERATION_VIEW )
		VISUALIZAR := .T.
		cOperacao 	:= "Visualizar"	
	ElseIf ( nOperation == MODEL_OPERATION_INSERT )
		INCLUI 		:= .T.
		cOperacao 	:= "Inclusão"
		bCloseOnOK	:= {|| .T. }
	ElseIf ( nOperation == MODEL_OPERATION_UPDATE )
		ALTERA 		:= .T.
		cOperacao 	:= "Alteração"
		bCloseOnOK	:= {|| .T. }
	ElseIf ( nOperation == MODEL_OPERATION_DELETE )
		EXCLUI 		:= .T.
		cOperacao 	:= "Exclusão"
		bCloseOnOK	:= {|| .T. }		
	ElseIf ( nOperation == MODEL_OPERATION_COPY )
		COPIA 		:= .T.
		cOperacao 	:= "Cópia"
		bCloseOnOK	:= {|| .T. }
	Endif

	bAcao := {|| nRet := FWExecView(cOperacao,'VIEWDEF.' + cModelo, nOperation,  , bCloseOnOK, bOK, , , bCancel ) }

	If ( SrvDisplay() .And. !IsBlind() )
		FwMsgRun(, bAcao, "EUROAMERICAN", "Carregando..." )
	Else
		Eval(bAcao)
	Endif
	
	If ( nRet == 0 )
		lRet := .T.
	Endif

Return lRet

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
	Local cIDModelGrid	:= ID_MODEL_GRID0
	Local oModelGrid	:= oModel:GetModel(cIDModelGrid)
	Local cPrefForm		:= PREFIXO_ALIAS_FORM0
	Local cPrefGrid		:= PREFIXO_ALIAS_GRID0
	Local lRet			:= .T.
	
Return lRet

/*
	Função para Validar os Dados Após Confirmação da Tela de Cadastro - Verifica se pode incluir
*/
Static Function posValid(oModel)

	Local nOperation	:= oModel:GetOperation()
	Local cIDModelGrid	:= ID_MODEL_GRID0
	Local oModelGrid	:= oModel:GetModel(cIDModelGrid)
	Local lRet			:= .T.
	
	If nOperation = 3

		Begin Sequence

			If (AllTrim(FWFldGet("PA8_OPERAC")) <> AllTrim(Posicione("SG2",11,xFilial("SG2")+FWFldGet("PA8_OPERAC"),"G2_OPERAC")))

				Help(,,"HELP",,"Atenção! Este codigo não existe com a operação '" + AllTrim(FWFldGet("PA8_OPERAC")) + "' na base de dados para esta filial.",1,0)	
				lRet := .F.

			Endif

			If (AllTrim(FWFldGet("PA8_COD")) <> AllTrim(Posicione("SB1",1,xFilial("SB1")+FWFldGet("PA8_COD"),"B1_COD")))

				Help(,,"HELP",,"Atenção! Este codigo de produto '" + AllTrim(FWFldGet("PA8_COD")) + "' não existe na base de dados.",1,0)	
				lRet := .F.

			Endif

		End Sequence

	EndIf

	If nOperation = 4

		Begin Sequence

			If (AllTrim(FWFldGet("PA8_OPERAC")) <> AllTrim(Posicione("SG2",11,xFilial("SG2")+FWFldGet("PA8_OPERAC"),"G2_OPERAC")))

				Help(,,"HELP",,"Atenção! Este codigo não existe com a operação '" + AllTrim(FWFldGet("PA8_OPERAC")) + "' na base de dados para esta filial.",1,0)	
				lRet := .F.

			Endif

			If (AllTrim(FWFldGet("PA8_COD")) <> AllTrim(Posicione("SB1",1,xFilial("SB1")+FWFldGet("PA8_COD"),"B1_COD")))

				Help(,,"HELP",,"Atenção! Este codigo de produto '" + AllTrim(FWFldGet("PA8_COD")) + "' não existe na base de dados.",1,0)	
				lRet := .F.

			Endif

		End Sequence

	EndIf

	If nOperation = 5

		lRet     := .T.
	
	EndIf

Return lRet

/*
	Função para Validar os Dados Após Confirmação da Tela de Cadastro - Verifica se pode incluir
*/
Static Function posLineValid(oModel)

	Local nOperation	:= oModel:GetOperation()
	Local lRet			:= .T.
	Local nI            := 0
	
	If nOperation = 3

		Begin Sequence

			For nI := 1 To oModel:GetQtdLine()

				If(AllTrim(FWFldGet("PA9_COD")) <> AllTrim(Posicione("SB1",1,xFilial("SB1")+FWFldGet("PA9_COD"),"B1_COD")))

					Help(,,"HELP",,"Atenção! Este codigo de produto '" + AllTrim(oModel:GetValue('PA9_COD')) + "' não existe na base de dados.",1,0)	
					lRet := .F.
				
				EndIf

				If(AllTrim(FWFldGet("PA9_COD")) <> AllTrim(Posicione("SG1",2,xFilial("SG1")+FWFldGet("PA9_COD")+FWFldGet("PA8_COD"),"G1_COMP") ) )
				
					Help(,,"HELP",,"Atenção! Este codigo de produto '" + AllTrim(oModel:GetValue('PA9_COD')) + "' não existe na estrutura do produto '"+AllTrim(FWFldGet("PA8_COD"))+"' ",1,0)	
					lRet := .F.

				EndIf

			Next

		End Sequence

	EndIf

	If nOperation = 4

		Begin Sequence

			For nI := 1 To oModel:GetQtdLine()

				If(AllTrim(FWFldGet("PA9_COD")) <> AllTrim(Posicione("SB1",1,xFilial("SB1")+FWFldGet("PA9_COD"),"B1_COD")))

					Help(,,"HELP",,"Atenção! Este codigo de produto '" + AllTrim(oModel:GetValue('PA9_COD')) + "' não existe na base de dados.",1,0)	
					lRet := .F.
				
				EndIf

				If(AllTrim(FWFldGet("PA9_COD")) <> AllTrim(Posicione("SG1",2,xFilial("SG1")+FWFldGet("PA9_COD")+FWFldGet("PA8_COD"),"G1_COMP") ) )
				
					Help(,,"HELP",,"Atenção! Este codigo de produto '" + AllTrim(oModel:GetValue('PA9_COD')) + "' não existe na estrutura do produto '"+AllTrim(FWFldGet("PA8_COD"))+"' ",1,0)	
					lRet := .F.

				EndIf

			Next

		End Sequence

	EndIf

Return lRet

/*
	Função de Validação executada na Ativação do Modelo
*/
Static Function activeForm(oModel)
	Local cIDModelForm		:= ID_MODEL_FORM0
	Local cIDModelGrid		:= ID_MODEL_GRID0
	Local nOperation		:= oModel:GetOperation()
	Local oModelGrid		:= oModel:GetModel(cIDModelGrid)
	Local nRecord			:= 0
	Local cPrefForm			:= PREFIXO_ALIAS_FORM0
	Local cPrefGrid			:= PREFIXO_ALIAS_GRID0
	Local cCampoReferencia	:= cPrefForm+"_ID"
	Local cReferencia		:= oModel:GetValue(cIDModelForm,cCampoReferencia)
	Local lRet				:= .T.

 	
Return lRet

/*
	Executa a Rotina Automática de Gravação
*/
Static Function runAutoExecute(aAutoCab,aAutoItens,nOperacao)
	Local cModelo 		:= MODELO
	Local cAliasForm 	:= ALIAS_FORM0
	Local cAliasGrid 	:= ALIAS_GRID0
	Local cIDModelForm 	:= cAliasForm+"FORM0"
	Local cIDModelGrid 	:= cAliasGrid+"GRID0"
	Local oClassMVCAuto := ClassMVCAuto():newClassMVCAuto()	
	Local aRet			:= {}
	Local cErro			:= ""
	Local lRet 			:= .F.
	
	Default aAutoCab	:= {}
	Default aAutoItens	:= {}
	Default nOperacao	:= 3
	
	If podeExecutar(aAutoCab,aAutoItens,@cErro)

		//Se chamado por rotina externa - Reduz a Carga de Dados do Dicionário de Dados
		If Type("oMFAMOD03") == "O"
			oClassMVCAuto:setObjectModel(oMFAMOD03)
		Endif
	
		oClassMVCAuto:setAliasForm(cAliasForm)
		oClassMVCAuto:setAliasGrid(cAliasGrid)
		oClassMVCAuto:setModelo(cModelo)
		oClassMVCAuto:setModelForm(cIDModelForm)
		oClassMVCAuto:setModelGrid(cIDModelGrid)
		
		oClassMVCAuto:setAutoCab(aAutoCab)
		oClassMVCAuto:setAutoItens(aAutoItens)
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
Static Function podeExecutar(aAutoCab,aAutoItens,cErro)
	Local lRet	:= .F.
	
	Begin Sequence
	
		If Len(aAutoCab) == 0
			cErro := "Falha na Carga dos Dados de Cabeçalho."
			Break
		Endif
		
		If Len(aAutoItens) == 0
			cErro := "Falha na Carga dos Dados dos Itens."
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
	Default lAtivaLog	:= .F.
	Default cMensagem 	:= ""
	Default cPrefixo	:= "[MFAMOD03][" + DtoC(DDATABASE) + "][" + Time() + "] "	

Return
/*
	Função de Validação no gatilho Laboratorio - 25/10/2022 - Fábio Carneiro dos Santos 
*/
User Function QELABG01(_cCod,_cComp)

	Local _cQuery      := "" 
	Local _aLidos      := {}
	Local _nLidos      := 0
	Local _cTrt        := ""

	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf

	_cQuery := "SELECT MAX(G1_TRT) AS G1_TRT FROM "+RetSqlName("SG1")+" AS SG1 "+ENTER
	_cQuery += "WHERE G1_FILIAL = '"+xFilial("SG1")+"'  "+ENTER
	_cQuery += " AND G1_COD    = '"+AllTrim(_cCod)+"' "+ENTER
	_cQuery += " AND G1_COMP   = '"+AllTrim(_cComp)+"' "+ENTER
	_cQuery += " AND SG1.D_E_L_E_T_ = ' ' "+ENTER 

	TcQuery _cQuery ALIAS "TRB1" NEW

	TRB1->(DbGoTop())

	While TRB1->(!Eof())
					
		Aadd(_aLidos,{TRB1->G1_TRT}) 

		TRB1->(DbSkip())

	EndDo

	If Len(_aLidos) > 0

		For _nLidos:= 1 To Len(_aLidos) 

			_cTrt := _aLidos[_nLidos][01]		

		Next _nLidos 	

	Else 

		_cTrt := "001"

	Endif

	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf

Return(_cTrt)

