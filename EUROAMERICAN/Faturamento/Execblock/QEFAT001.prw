#INCLUDE "RWMAKE.CH"       
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "TOPCONN.CH" 

#DEFINE ROTINA_FILE				"QEFAT001.prw"
#DEFINE VERSAO_ROTINA			"V"+ Trim(AllToChar(GetAPOInfo(ROTINA_FILE)[04])) + "-" + Trim(AllToChar(GetAPOInfo(ROTINA_FILE)[05])) + "[" + Trim(AllToChar(GetAPOInfo(ROTINA_FILE)[03])) + "]"
	
#Define ALIAS_FORM0 			"PAA" //Informe o Alias da Tabela
#Define MODELO					"QEFAT001"
#Define ID_MODEL				"QEFATM01"
#Define TITULO_MODEL			"Cadastro Comissão de Produto" + SubStr(VERSAO_ROTINA,1,17)
#Define TITULO_VIEW				TITULO_MODEL
#Define ID_MODEL_FORM0			ALIAS_FORM0+"FORM0"
#Define ID_VIEW_FORM0			"VIEW_FORM0"
#Define PREFIXO_ALIAS_FORM0		Right(ALIAS_FORM0,03)

#DEFINE TYPE_HEADER				1
#DEFINE TYPE_ITEMS				2

#DEFINE ENTER chr(13) + chr(10)

/*/{Protheus.doc} QEFAT001 - cadastro de comissão de produtos 
Fonte Modelo de MVC - Interface Modelo 1 para cadastro de comissão de produtos   
@type function
@author fabio Caraneiro dos Santos
@since 09/02/2022
@version P12
@database MSSQL
@param [aAutoCab], Array, Array com os Dados do Cabeçalho no Formato de Rotina Automática (Vide Campos de Cabeçalho na Interface)
@param [nOperacao], Numerico, Operação a ser realizada, sendo 3=Inclusão, 4=Alteração, 5=Exclusão
/*/ 
User Function QEFAT001(aAutoCab,nOperacao)
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
		oFwMBrowse:AddLegend( cAliasForm+"_MSBLQL == '2'  ", "BR_VERDE   " , "Desbloquado" )
		oFwMBrowse:AddLegend( cAliasForm+"_MSBLQL == '1'  ", "BR_VERMELHO" , "Bloqueado" )
		
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
	Local cCpoCodigo		:= cPrefForm+"_CODTAB"
	Local cCpoRevisao		:= cPrefForm+"_REV"
	Local cCpoProduto		:= cPrefForm+"_COD"
	
	oStructForm	:= FWFormStruct( 1, cAliasForm )	

	oModel	:= MPFormModel():New(cIdModel,bPreValidacao,bPosValidacao,bCommit,/*bCancel*/)
	
	oModel:AddFields( cIDModelForm, /*cOwner*/, oStructForm,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)	
	
	// Indice alterado da tabela PAA -> PAA_FILIAL+PAA_COD+PAA_CODTAB+PAA_REV - 18/06/2022 - Fábio Carneiro dos Santos 

	oModel:SetPrimaryKey( { cCpoFilial,cCpoProduto,cCpoCodigo,cCpoRevisao} )
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
	Local cCpoCodigo		:= cPrefForm+"_CODTAB"
	Local cCpoRevisao		:= cPrefForm+"_REV"
	Local cCpoProduto		:= cPrefForm+"_COD"

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
	
    ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.' + cModelo    OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.' + cModelo    OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.' + cModelo    OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.' + cModelo    OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.' + cModelo    OPERATION 9 ACCESS 0
    ADD OPTION aRotina TITLE 'Importa Dados' 	  ACTION 'U_QEIMPCOM()'	 OPERATION 6 ACCESS 0
    ADD OPTION aRotina TITLE 'Gerar Nova Revisao' ACTION 'U_QEPROVIG()'	 OPERATION 7 ACCESS 0
    ADD OPTION aRotina TITLE 'Regrava % Comissão' ACTION 'U_QEZRDCOM()'	 OPERATION 8 ACCESS 0

Return aRotina

/*
	Função para Salvar os Dados do Cadastro usando MVC
*/ 
Static Function saveForm(oModel)

	Local nOperation	:= oModel:GetOperation()
	Local lRet 			:= .T.
	//Local _cQuery       := "" 
	
	FWModelActive(oModel)
	lRet := FWFormCommit(oModel)

	If nOperation == MODEL_OPERATION_INSERT 
	
		If lRet
			
			SB1->(DbSetOrder(1))
			SB1->(DbGoTop())
			If SB1->(DbSeek(xFilial("SB1")+M->PAA_COD))  
				RecLock("SB1",.F.)
				SB1->B1_COMIS    := M->PAA_COMIS1
				SB1->B1_XREVCOM  := M->PAA_REV
				SB1->B1_XTABCOM  := M->PAA_CODTAB
				SB1->(MsUnlock())
			EndIf
		
		EndIf		

	EndIf 

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

	If nOperation == MODEL_OPERATION_UPDATE

		If PAA->PAA_MSBLQL == "1"  
				
			lRet  := .F.

		EndIf

	EndIf


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
	Local _lPassa1      := .F.
	Local _cQueryC      := "" 
	Local _cQuery       := ""
	Local _cQueryA      := ""
	Local _aLidos       := {}
	Local _nLidos       := 0
	Local cQry          := ""

	If nOperation = 3
		
		lRet := .T.
		
		_cQueryA := ""
		_cQueryC := ""
		_cQry    := ""

		Begin Sequence

			_aLidos       := {}
			_nLidos       := 0

			If Select("TRB1") > 0
				TRB1->(DbCloseArea())
			EndIf

			_cQueryC := "SELECT MAX(PAA_REV) AS REVCOM FROM "+RetSqlName("PAA")+" AS PAA "+ENTER
			_cQueryC += "WHERE PAA_FILIAL = '"+xFilial("PAA")+"'  "+ENTER
			_cQueryC += " AND PAA_COD = '"+AllTrim(FWFldGet("PAA_COD"))+"' "+ENTER
			_cQueryC += " AND PAA_REV = '"+AllTrim(FWFldGet("PAA_REV"))+"' "+ENTER
			_cQueryC += " AND PAA.D_E_L_E_T_ = ' ' "+ENTER 

			TcQuery _cQueryC ALIAS "TRB1" NEW

			TRB1->(DbGoTop())

			While TRB1->(!Eof())
					
				Aadd(_aLidos,{TRB1->REVCOM}) 

				TRB1->(DbSkip())

			EndDo

			If Len(_aLidos) > 0

				For _nLidos:= 1 To Len(_aLidos) 

					DbSelectArea("PAA")
					PAA->(DbSetorder(1)) // PAA_FILIAL+PAA_COD+PAA_CODTAB+PAA_REV - 18/06/2022 - Fábio Carneiro dos Santos 
					PAA->(DbGotop())
					If PAA->(DbSeek(xFilial("PAA")+M->PAA_COD+M->PAA_CODTAB+_aLidos[_nLidos][01]))   

						Help(,,"HELP",,"Atenção! Este codigo ja existe com a revisão '" + AllTrim(_aLidos[_nLidos][01]) + "' já existe na base de dados para esta filial.",1,0)	
						lRet     := .F.

						PAA->(MsUnlock())
							
					EndIf 

				Next _nLidos 	

			Else 

				DbSelectArea("PAA")
				PAA->(DbSetorder(1)) // PAA_FILIAL+PAA_COD+PAA_CODTAB+PAA_REV - 18/06/2022 - Fábio Carneiro dos Santos 
				PAA->(DbGotop())
				If PAA->(DbSeek(xFilial("PAA")+M->PAA_COD+M->PAA_CODTAB+M->PAA_REV))   

					Help(,,"HELP",,"Atenção! Este codigo ja existe com a revisão '" + AllTrim(AllTrim(FWFldGet("PAA_REV"))) + "' já existe na base de dados para esta filial.",1,0)	
					lRet     := .F.

					PAA->(MsUnlock())
							
				EndIf 

			EndIf

			If lRet

				_aLidos  := {}
				_nLidos  := 0 
				_cQuery  := ""
				cQry     := ""

				SB1->(DbSetOrder(1))
				SB1->(DbGoTop())
				If SB1->(DbSeek(xFilial("SB1")+M->PAA_COD))  
					RecLock("SB1",.F.)
					SB1->B1_COMIS   := M->PAA_COMIS1
					SB1->B1_XREVCOM := M->PAA_REV
					SB1->B1_XTABCOM := M->PAA_CODTAB
					SB1->(MsUnlock())
				EndIf
			
				If Select("TRB1") > 0
					TRB1->(DbCloseArea())
				EndIf

				_cQuery := "SELECT MAX(PAA_REV) AS XREVCOM FROM "+RetSqlName("PAA")+" AS PAA "+ENTER
				_cQuery += "WHERE PAA_FILIAL = '"+xFilial("PAA")+"'  "+ENTER
				_cQuery += " AND PAA_COD    = '"+AllTrim(M->PAA_COD)+"' "+ENTER
				_cQuery += " AND PAA.D_E_L_E_T_ = ' ' "+ENTER 

				TcQuery _cQuery ALIAS "TRB1" NEW

				TRB1->(DbGoTop())

				While TRB1->(!Eof())
								
					Aadd(_aLidos,{TRB1->XREVCOM}) 

					TRB1->(DbSkip())

				EndDo

				If Len(_aLidos) > 0

					For _nLidos:= 1 To Len(_aLidos) 

						cQry := " UPDATE " + RetSqlName("PAA") + " "
						cQry += " SET PAA_DTVIG2 = '" + DtoS(dDataBase-1) + "', PAA_MSBLQL = '1' "
						cQry += " FROM " + RetSqlName("PAA") + " AS PAA "
						cQry += " WHERE PAA_FILIAL = '"+xFilial("PAA")+"' "
						cQry += " AND PAA_COD    = '" + AllTrim(M->PAA_COD) + "' "
						cQry += " AND PAA_CODTAB = '" + AllTrim(M->PAA_CODTAB) + "' "
						cQry += " AND PAA_REV    = '" + AllTrim(_aLidos[_nLidos][01]) + "' "
						cQry += " AND PAA.D_E_L_E_T_ = ' ' "

						TcSQLExec(cQry)

					Next _nLidos 	

				Endif

			EndIf 

		End Sequence

	Endif

	If nOperation = 4

		If M->PAA_MSBLQL == "1"  
			Help(,,"HELP",,"Atenção! Registro Bloquado para o codigo '" + AllTrim(PAA->PAA_COD) + "' não pode ser alterado, somente rsgirtros desbloqueados com alegenda verde! ",1,0)	
			lRet := .F.
		Else 
			lRet := .T.
		EndIf

	Endif

	If nOperation = 5
	
		_cQueryA := ""
		_cQueryC := ""
		_cQry    := ""

		Begin Sequence

			_aLidos := {}
			_nLidos := 0

			If Select("C6_PAA") > 0
				C6_PAA->(DbCloseArea())
			EndIf

			_cQueryA := "SELECT C6_PRODUTO, C6_XREVCOM "+ENTER 
			_cQueryA += "FROM "+RetSqlName("PAA")+" AS PAA "+ENTER
			_cQueryA += "INNER JOIN "+RetSqlName("SC6")+" AS SC6 ON C6_FILIAL = PAA_FILIAL "+ENTER
			_cQueryA += "AND C6_XTABCOM = PAA_CODTAB "+ENTER
			_cQueryA += "AND C6_PRODUTO = PAA_COD "+ENTER
			_cQueryA += "AND C6_XREVCOM = PAA_REV "+ENTER
			_cQueryA += "AND SC6.D_E_L_E_T_ = ' ' "+ENTER
			_cQueryA += "WHERE C6_FILIAL  = '"+xFilial("SC6")+"'   "+ENTER
			_cQueryA += "AND PAA_COD = '"+AllTrim(PAA->PAA_COD)+"' "+ENTER 
			_cQueryA += "AND PAA.D_E_L_E_T_ = ' ' "+ENTER 
			_cQueryA += "GROUP BY C6_PRODUTO, C6_XREVCOM "+ENTER

			TcQuery _cQueryA ALIAS "C6_PAA" NEW

			C6_PAA->(DbGoTop())

			While C6_PAA->(!Eof())
					
				Aadd(_aLidos,{C6_PAA->C6_PRODUTO,C6_PAA->C6_XREVCOM})

				C6_PAA->(DbSkip())

			EndDo

			For _nLidos:= 1 To Len(_aLidos) 
		
				If _aLidos[_nLidos][01] == PAA->PAA_COD .And. _aLidos[_nLidos][02] == PAA->PAA_REV
					_lPassa1 := .T.
					EXIT 	
				EndIf

			Next _nLidos 	
			
			If _lPassa1 

				Help(,,"HELP",,"Atenção! A regra informada no codigo '" + AllTrim(PAA->PAA_COD) + "' não pode ser excluida pois já existe Vigência desbloquada na base de dados para esta filial.",1,0)	
				lRet     := .F.
			
			EndIf

			If Len(_aLidos) <=0 
				
				If Posicione("SB1",1,xFilial("SB1")+PAA->PAA_COD,"B1_COMIS") == 0 .And. PAA->PAA_COMIS1 == 0 .And. PAA->PAA_MSBLQL $ "1"
					lRet     := .T.
				EndIf 
				
				If  Val(PAA->PAA_REV) > 1

					If Select("TRB2") > 0
						TRB2->(DbCloseArea())
					EndIf

					_cQueryB := "SELECT MAX(PAA_REV) AS REVCOM FROM "+RetSqlName("PAA")+" AS PAA "+ENTER
					_cQueryB += "WHERE PAA_FILIAL = '"+xFilial("PAA")+"'  "+ENTER
					_cQueryB += " AND PAA_COD    = '"+AllTrim(PAA->PAA_COD)+"' "+ENTER
					_cQueryB += " AND PAA_REV    = '"+AllTrim(StrZero(Val(PAA->PAA_REV)-1,3))+"' "+ENTER
					_cQueryB += " AND PAA.D_E_L_E_T_ = ' ' "+ENTER 

					TcQuery _cQueryB ALIAS "TRB2" NEW

					TRB2->(DbGoTop())

					While TRB2->(!Eof())

						SB1->(DbSetOrder(1)) 
						SB1->(DbGoTop())
						If SB1->(DbSeek(xFilial("SB1")+PAA->PAA_COD))  
							RecLock("SB1",.F.)
							SB1->B1_COMIS   := Posicione("PAA",1,xFilial("PAA")+PAA->PAA_COD+PAA->PAA_CODTAB+TRB2->REVCOM,"PAA_COMIS1")
							SB1->B1_XREVCOM := Posicione("PAA",1,xFilial("PAA")+PAA->PAA_COD+PAA->PAA_CODTAB+TRB2->REVCOM,"PAA_REV")
							SB1->B1_XTABCOM := Posicione("PAA",1,xFilial("PAA")+PAA->PAA_COD+PAA->PAA_CODTAB+TRB2->REVCOM,"PAA_CODTAB")
							SB1->(MsUnlock())
						EndIf

						TRB2->(DbSkip())

					EndDo
				
				Else 

					SB1->(DbSetOrder(1)) 
					SB1->(DbGoTop())
					If SB1->(DbSeek(xFilial("SB1")+PAA->PAA_COD))  
						RecLock("SB1",.F.)
						SB1->B1_COMIS   := 0
						SB1->B1_XREVCOM := ""
						SB1->B1_XTABCOM := ""
						SB1->(MsUnlock())
					EndIf

				EndIf
		
			EndIf 
		
		End Sequence

	EndIf

If Select("W1_PAA") > 0
	W1_PAA->(DbCloseArea())
EndIf
If Select("C6_PAA") > 0
	C6_PAA->(DbCloseArea())
EndIf
If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf
If Select("TRB2") > 0
	TRB2->(DbCloseArea())
EndIf

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
	Local _cMsg             := ""

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
		If Type("oQEFAT001") == "O"
			oClassMVCAuto:setObjectModel(oQEFAT001)
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

/*
	Função de Validação no gatilho da tabela PAA no campo PAA_COD - 19/06/2022 - Fábio Carneiro dos Santos 
*/

User Function QEGAT001(_cProduto)

	Local _cQuery      := "" 
	Local _aLidos      := {}
	Local _nLidos      := 0
	Local _cRev        := ""

	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf

	_cQuery := "SELECT MAX(PAA_REV) AS REVCOM FROM "+RetSqlName("PAA")+" AS PAA "+ENTER
	_cQuery += "WHERE PAA_FILIAL = '"+xFilial("PAA")+"'  "+ENTER
	_cQuery += " AND PAA_COD    = '"+AllTrim(_cProduto)+"' "+ENTER
	_cQuery += " AND PAA.D_E_L_E_T_ = ' ' "+ENTER 

	TcQuery _cQuery ALIAS "TRB1" NEW

	TRB1->(DbGoTop())

	While TRB1->(!Eof())
					
		Aadd(_aLidos,{TRB1->REVCOM}) 

		TRB1->(DbSkip())

	EndDo

	If Len(_aLidos) > 0

		For _nLidos:= 1 To Len(_aLidos) 

			_cRev := StrZero(Val(_aLidos[_nLidos][01])+1,3)		

		Next _nLidos 	

	Else 

		_cRev := "001"

	Endif

	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf


Return(_cRev)


