#include "Totvs.ch"
#include "FwMvcDef.ch"
#include "TbiConn.ch"
#include "TopConn.ch"

User Function EqDigZ81()

	Private oBrowse := FwMBrowse():New()
	oBrowse:SetAlias("Z81")
	oBrowse:SetDescription("Digitação Ficha de Inventário")
	oBrowse:AddLegend( "Z81_STATUS == '1'", "GREEN"		, "Pendente Apuração"		)		
	oBrowse:AddLegend( "Z81_STATUS == '2'", "YELLOW"	, "Inconsistência Apuração"	)		
	oBrowse:AddLegend( "Z81_STATUS == '3'", "RED"		, "Apurado"					)
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aMenu := {}

	ADD OPTION aMenu TITLE 'Pesquisar' 	ACTION 'PesqBrw'			OPERATION 1 ACCESS 0
	ADD OPTION aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.EqDigZ81'	OPERATION 2 ACCESS 0
	ADD OPTION aMenu TITLE 'Incluir' 	ACTION 'VIEWDEF.EqDigZ81'	OPERATION 3 ACCESS 0
	ADD OPTION aMenu TITLE 'Alterar' 	ACTION 'VIEWDEF.EqDigZ81'	OPERATION 4 ACCESS 0
	ADD OPTION aMenu TITLE 'Excluir' 	ACTION 'VIEWDEF.EqDigZ81'	OPERATION 5 ACCESS 0

Return( aMenu )

Static Function ModelDef()

	Local oStruct  := FwFormStruct(1,"Z81")
	Local oStruZ82 := FwFormStruct(1,"Z82")
	Local oModel

	oModel	:= MpFormModel():New("PEEqDigZ81",/*Pre-Validacao*/,{ |oModel| fPosValid( oModel ) }/*Pós-Validacao*/,/*Commit*/,/*Cancel*/)
	oModel:AddFields("ID_ENCH_Z81",/*cOwner*/,oStruct,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

	//oStruZ82:AddField( "", "", "ZB_LEGENDA", "C", 03, 0,,,,,{|| BeLegZ82(Z82->ZB_SITUACA)},,,.T.)

	oModel:AddGrid( 'ID_ENCH_Z82'   , 'ID_ENCH_Z81' , oStruZ82, /*bLinePre*/ , { |oModelGrid| fValLinPos( oModelGrid ) }/*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)
	oModel:SetRelation( 'ID_ENCH_Z82', { { 'Z82_FILIAL', 'xFilial( "Z82" )' }, { 'Z82_CODIGO', 'Z81_CODIGO' } }, Z82->( IndexKey( 1 ) ) )
	oModel:GetModel( 'ID_ENCH_Z82' ):SetUniqueLine( { 'Z82_ITEM' } )

	oModel:SetPrimaryKey( {"Z81_FILIAL","Z81_CODIGO"} )
	oModel:SetDescription("Digitação Ficha de Inventário")
	oModel:GetModel("ID_ENCH_Z81"):SetDescription("Digitação Ficha de Inventário")

	oModel:GetModel("ID_ENCH_Z82"):SetDescription("Itens para Digitação da Ficha de Inventário")
	oModel:GetModel("ID_ENCH_Z82"):SetNoInsertLine( .F. ) // Permite inserir linhas...
	oModel:GetModel("ID_ENCH_Z82"):SetNoUpdateLine( .F. ) // Permite alterar linhas...
	oModel:GetModel("ID_ENCH_Z82"):SetNoDeleteLine( .F. ) // Permite deletar linhas...
	oModel:GetModel("ID_ENCH_Z82"):SetOptional( .T. )     // Não exige existência de linhas...

	oStruct:SetProperty( 'Z81_DATA'  ,MODEL_FIELD_VALID,{|o| fValData()                                                           })
	oStruZ82:SetProperty('Z82_CODIGO',MODEL_FIELD_INIT ,{|o| M->Z81_CODIGO                                                        })
	oStruZ82:SetProperty('Z82_EQUIPE',MODEL_FIELD_INIT ,{|o| Posicione( "Z80", 1, xFilial("Z80") + Z82->Z82_GRUPO , "Z80_EQUIPE") })
	oStruZ82:SetProperty('Z82_DESCRI',MODEL_FIELD_INIT ,{|o| Posicione( "SB1", 1, xFilial("SB1") + Z82->Z82_PRODUT, "B1_DESC"   ) })
	oStruZ82:SetProperty('Z82_UM'    ,MODEL_FIELD_INIT ,{|o| Posicione( "SB1", 1, xFilial("SB1") + Z82->Z82_PRODUT, "B1_UM"     ) })
	oStruZ82:SetProperty('Z82_LOCAL' ,MODEL_FIELD_VALID,{|o| fValLocal()                                                          })
	oStruZ82:SetProperty('Z82_LOTECT',MODEL_FIELD_VALID,{|o| fValLote()                                                           })

Return(oModel)

Static Function ViewDef()

	Local oStruct 	:= FwFormStruct(2,"Z81")
	Local oStruZ82 	:= FwFormStruct(2,"Z82")
	Local oModel 	:= FwLoadModel("EqDigZ81")
	Local oView		:= FwFormView():New()

	oView:SetModel(oModel)
	oView:AddField("ID_VIEW_Z81", oStruct, "ID_ENCH_Z81")

	oStruZ82:RemoveField( 'Z82_CODIGO' )
	//oStruZ82:AddField("ZB_LEGENDA","","","",,"C","@BMP",,,.F.,,,,,,,,.F.)
	oView:AddGrid("ID_VIEW_Z82", oStruZ82, "ID_ENCH_Z82")
	oView:AddIncrementField( "ID_VIEW_Z82", 'Z82_ITEM')

	//oView:CreateHorizontalBox("ID_HBOX", 100)
	//oView:SetOwnerView("ID_VIEW_CDZ81", "ID_HBOX")
	//oView:EnableTitleView("ID_VIEW_CDZ81")
	oView:CreateHorizontalBox( 'SUPERIOR', 20 )
	oView:CreateHorizontalBox( 'INFERIOR', 80 )
	oView:SetOwnerView( "ID_VIEW_Z81", 'SUPERIOR' )
	oView:SetOwnerView( "ID_VIEW_Z82", 'INFERIOR' )

	oView:EnableTitleView("ID_VIEW_Z81")
	oView:EnableTitleView("ID_VIEW_Z82")

Return( oView )

Static Function BeLegZ82( cStatus )

Local cRet := "BR_BRANCO"

If AllTrim( cStatus ) == "0"
	cRet := "ENABLE"
ElseIf AllTrim( cStatus ) == "1"
	cRet := "DISABLE"
ElseIf AllTrim( cStatus ) == "2"
	cRet := "BR_PRETO"
EndIf

Return cRet

Static Function fPosValid( oModel )

Local lRetorno  := .T.
Local aArea     := GetArea()
Local oModel    := FWModelActive()
Local oView     := FWViewActive()
Local oModelZ81 := oModel:GetModel('ID_ENCH_Z81')
Local oModelZ82 := oModel:GetModel('ID_ENCH_Z82')
Local dData     := oModelZ81:GetValue('Z81_DATA')

If AllTrim( cEmpAnt ) + AllTrim( cFilAnt ) $ "0107|0200|0803|0901"
	dbSelectArea("Z86")
	dbSetOrder(1)
	dbGoTop()
	Do Case
		Case AllTrim( cEmpAnt ) + AllTrim( cFilAnt ) == "0107"
			If AllTrim( Z86->Z86_0107 ) <> "S"
				lRetorno := .F.
				Help( ,, "EQDIGVLEMP",, "Empresa ou filial não habilitada para contagem do inventário, Verifique!", 1, 0 )
			EndIf
		Case AllTrim( cEmpAnt ) + AllTrim( cFilAnt ) == "0200"
			If AllTrim( Z86->Z86_0200 ) <> "S"
				lRetorno := .F.
				Help( ,, "EQDIGVLEMP",, "Empresa ou filial não habilitada para contagem do inventário, Verifique!", 1, 0 )
			EndIf
		Case AllTrim( cEmpAnt ) + AllTrim( cFilAnt ) == "0803"
			If AllTrim( Z86->Z86_0803 ) <> "S"
				lRetorno := .F.
				Help( ,, "EQDIGVLEMP",, "Empresa ou filial não habilitada para contagem do inventário, Verifique!", 1, 0 )
			EndIf
		Case AllTrim( cEmpAnt ) + AllTrim( cFilAnt ) == "0901"
			If AllTrim( Z86->Z86_0901 ) <> "S"
				lRetorno := .F.
				Help( ,, "EQDIGVLEMP",, "Empresa ou filial não habilitada para contagem do inventário, Verifique!", 1, 0 )
			EndIf
	EndCase
Else
	lRetorno := .F.
	Help( ,, "EQDIGVLEMP",, "Empresa ou filial inválida para contagem do inventário, Verifique!", 1, 0 )
EndIf

If lRetorno
	If Empty( dData )
		lRetorno := .F.
		Help( ,, "EQDIGVLDATA",, "Informe uma data válida para digitação, Verifique!", 1, 0 )
	Else
		dbSelectArea("Z86")
		dbSetOrder(1)
		dbGoTop()
		If !(dData >= Z86->Z86_DATAIN .And. dData <= Z86->Z86_DATAFI)
			lRetorno := .F.
			Help( ,, "EQDIGVLDATA",, "Informe uma data válida para digitação, Verifique!", 1, 0 )
		EndIf
	EndIf
EndIf

RestArea( aArea )

Return lRetorno

Static Function fValLinPos( oModelLin )

Local lRetorno  := .T.
Local aArea     := GetArea()
Local oModel    := FWModelActive()
Local oView     := FWViewActive()
Local oModelZ81 := oModel:GetModel('ID_ENCH_Z81')
Local oModelZ82 := oModel:GetModel('ID_ENCH_Z82')
Local cCodigo   := oModelZ81:GetValue('Z81_CODIGO')
Local cFicha    := oModelZ82:GetValue('Z82_FICHA')
Local cContagem := oModelZ82:GetValue('Z82_CONTAG')
Local cProduto  := oModelZ82:GetValue('Z82_PRODUT')
Local cLocal    := oModelZ82:GetValue('Z82_LOCAL')
Local cLote     := oModelZ82:GetValue('Z82_LOTECT')
Local cGrupo    := oModelZ82:GetValue('Z82_GRUPO')
Local cEndereco := oModelZ82:GetValue('Z82_LOCALI')
Local nLinAtu   := oModelZ82:GetLine()
Local nLinha    := 0
Local cQuery    := ""

dbSelectArea("SB1")
dbSetOrder(1)
If SB1->( dbSeek( xFilial("SB1") + cProduto ) )
	dbSelectArea("SB2")
	dbSetOrder(1) // B2_FILIAL, B2_COD, B2_LOCAL
	If !SB2->( dbSeek( xFilial("SB2") + cProduto + cLocal ) )
		lRetorno := .F.
		Help( ,, "EQDIGVLDLOC",, "Local informado não existe para este produto, Verifique!", 1, 0 )
	EndIf
	If lRetorno
		If SB1->B1_RASTRO <> "N"
			dbSelectArea("SB8")
			dbSetOrder(3) // B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_NUMLOTE, B8_DTVALID
			If !SB8->( dbSeek( xFilial("SB8") + cProduto + cLocal + cLote ) )
				lRetorno := .F.
				Help( ,, "EQDIGVLDLOT",, "Lote informado não existe para este produto e local, Verifique!", 1, 0 )
			EndIf
		EndIf
	EndIf
EndIf

If lRetorno
	For nLinha := 1 To oModelZ82:Length()
		oModelZ82:GoLine( nLinha )
		If nLinha <> nLinAtu
			If !oModelZ82:IsDeleted()
				If cFicha + cContagem + cProduto + cLocal + cLote == oModelZ82:GetValue('Z82_FICHA') + oModelZ82:GetValue('Z82_CONTAG') + oModelZ82:GetValue('Z82_PRODUT') + oModelZ82:GetValue('Z82_LOCAL') + oModelZ82:GetValue('Z82_LOTECT')
					Help( ,, "EQDIGVLDLIN",, "Ficha para este produto e lote já informada para a contagem: " + cContagem + ", Verifique!", 1, 0 )
					lRetorno := .F.		
					oModelZ82:GoLine( nLinAtu )
					oView:Refresh()
				EndIf
				/*
				If lRetorno .And. AllTrim( cFicha ) == AllTrim( oModelZ82:GetValue('Z82_FICHA') ) .And. AllTrim( cGrupo ) <> AllTrim( oModelZ82:GetValue('Z82_GRUPO') )
					Help( ,, "EQDIGVLDLI3",, "Grupo de contagem desta ficha diferente de demais contagens da mesma ficha, Verifique!", 1, 0 )
					lRetorno := .F.		
					oModelZ82:GoLine( nLinAtu )
					oView:Refresh()
				EndIf
				*/
				If lRetorno .And. AllTrim( cFicha ) == AllTrim( oModelZ82:GetValue('Z82_FICHA') ) .And. AllTrim( cEndereco ) <> AllTrim( oModelZ82:GetValue('Z82_LOCALI') )
					Help( ,, "EQDIGVLDLI5",, "Endereço de contagem desta ficha diferente de demais contagens da mesma ficha, Verifique!", 1, 0 )
					lRetorno := .F.		
					oModelZ82:GoLine( nLinAtu )
					oView:Refresh()
				EndIf
			EndIf
		EndIf
	Next
EndIf

If lRetorno
	cQuery := "SELECT COUNT(*) AS CONTA " + CRLF
	cQuery += "FROM " + RetSqlName("Z82") + " AS Z82 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE Z82_FILIAL = '" + xFilial("Z82") + "' " + CRLF
	cQuery += "AND Z82_CODIGO <> '" + cCodigo + "' " + CRLF
	cQuery += "AND Z82_FICHA = '" + cFicha + "' " + CRLF
	cQuery += "AND Z82_CONTAG = '" + cContagem + "' " + CRLF
	cQuery += "AND Z82_PRODUT = '" + cProduto + "' " + CRLF
	cQuery += "AND Z82_LOCAL = '" + cLocal + "' " + CRLF
	cQuery += "AND Z82_LOTECT = '" + cLote + "' " + CRLF
	cQuery += "AND Z82.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPZ82"
	dbSelectArea("TMPZ82")
	dbGoTop()

	If !TMPZ82->( Eof() ) .And. TMPZ82->CONTA > 0
		Help( ,, "EQDIGVLDLI2",, "Ficha para este produto e lote já informada para a contagem: " + cContagem + ", Verifique!", 1, 0 )
		lRetorno := .F.		
		oModelZ82:GoLine( nLinAtu )
		oView:Refresh()
	EndIf

	TMPZ82->( dbCloseArea() )

	cQuery := "SELECT Z82_GRUPO " + CRLF
	cQuery += "FROM " + RetSqlName("Z82") + " AS Z82 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE Z82_FILIAL = '" + xFilial("Z82") + "' " + CRLF
	cQuery += "AND Z82_CODIGO <> '" + cCodigo + "' " + CRLF
	cQuery += "AND Z82_FICHA = '" + cFicha + "' " + CRLF
	cQuery += "AND Z82_GRUPO <> '" + cGrupo + "' " + CRLF
	cQuery += "AND Z82.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPZ82"
	dbSelectArea("TMPZ82")
	dbGoTop()

	If !TMPZ82->( Eof() )
		Help( ,, "EQDIGVLDLI4",, "Grupo de contagem desta ficha diferente de demais contagens da mesma ficha, Verifique!", 1, 0 )
		lRetorno := .F.		
		oModelZ82:GoLine( nLinAtu )
		oView:Refresh()
	EndIf

	TMPZ82->( dbCloseArea() )

	cQuery := "SELECT Z82_GRUPO " + CRLF
	cQuery += "FROM " + RetSqlName("Z82") + " AS Z82 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE Z82_FILIAL = '" + xFilial("Z82") + "' " + CRLF
	cQuery += "AND Z82_CODIGO <> '" + cCodigo + "' " + CRLF
	cQuery += "AND Z82_FICHA = '" + cFicha + "' " + CRLF
	cQuery += "AND Z82_LOCALI <> '" + cEndereco + "' " + CRLF
	cQuery += "AND Z82.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPZ82"
	dbSelectArea("TMPZ82")
	dbGoTop()

	If !TMPZ82->( Eof() )
		Help( ,, "EQDIGVLDLI6",, "Endereço de contagem desta ficha diferente de demais contagens da mesma ficha, Verifique!", 1, 0 )
		lRetorno := .F.		
		oModelZ82:GoLine( nLinAtu )
		oView:Refresh()
	EndIf

	TMPZ82->( dbCloseArea() )
EndIf

If lRetorno 
	oModelZ82:GoLine( 1 )
	oView:Refresh()
	oModelZ82:GoLine( nLinAtu )
Else
	oModelZ82:GoLine( nLinAtu )
EndIf

RestArea( aArea )

Return lRetorno

Static Function fValLocal()

Local lRetorno := .T.
Local oModel    := FWModelActive()
Local oModelZ82 := oModel:GetModel('ID_ENCH_Z82')
Local cFicha    := oModelZ82:GetValue('Z82_FICHA')
Local cContagem := oModelZ82:GetValue('Z82_CONTAG')
Local cProduto  := oModelZ82:GetValue('Z82_PRODUT')
Local cLocal    := oModelZ82:GetValue('Z82_LOCAL')

dbSelectArea("SB1")
dbSetOrder(1)
If SB1->( dbSeek( xFilial("SB1") + cProduto ) )
	dbSelectArea("SB2")
	dbSetOrder(1) // B2_FILIAL, B2_COD, B2_LOCAL
	If !SB2->( dbSeek( xFilial("SB2") + cProduto + cLocal ) )
		lRetorno := .F.
		Help( ,, "EQDIGVLDLOC",, "Local informado não existe para este produto, Verifique!", 1, 0 )
	EndIf
EndIf

Return lRetorno

Static Function fValLote()

Local lRetorno  := .T.
Local oModel    := FWModelActive()
Local oModelZ82 := oModel:GetModel('ID_ENCH_Z82')
Local cFicha    := oModelZ82:GetValue('Z82_FICHA')
Local cContagem := oModelZ82:GetValue('Z82_CONTAG')
Local cProduto  := oModelZ82:GetValue('Z82_PRODUT')
Local cLocal    := oModelZ82:GetValue('Z82_LOCAL')
Local cLote     := oModelZ82:GetValue('Z82_LOTECT')
Local dData     := oModelZ82:GetValue('Z82_DTVALI')

dbSelectArea("SB1")
dbSetOrder(1)
If SB1->( dbSeek( xFilial("SB1") + cProduto ) )
	If SB1->B1_RASTRO == "N"
		oModelZ82:SetValue('Z82_LOTECT', Space(10))
		oModelZ82:SetValue('Z82_DTVALI', CTOD("  /  /    ") )
	Else
		dbSelectArea("SB8")
		dbSetOrder(3) // B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_NUMLOTE, B8_DTVALID
		If SB8->( dbSeek( xFilial("SB8") + cProduto + cLocal + cLote ) )
			oModelZ82:SetValue('Z82_DTVALI', SB8->B8_DTVALID )
		Else
			lRetorno := .F.
			Help( ,, "EQDIGVLDLOT",, "Lote informado não existe para este produto e local, Verifique!", 1, 0 )
		EndIf
	EndIf
EndIf

Return lRetorno

Static Function fValData()

Local lRetorno  := .T.
Local aArea     := GetArea()
Local oModel    := FWModelActive()
Local oModelZ81 := oModel:GetModel('ID_ENCH_Z81')
Local dData     := oModelZ81:GetValue('Z81_DATA')                                        ´

If Empty( dData )
	lRetorno := .F.
	Help( ,, "EQDIGVLDATA",, "Informe uma data válida para digitação, Verifique!", 1, 0 )
Else
	dbSelectArea("Z86")
	dbSetOrder(1)
	dbGoTop()
		If !(dData >= Z86->Z86_DATAIN .And. dData <= Z86->Z86_DATAFI)
		lRetorno := .F.
		Help( ,, "EQDIGVLDATA",, "Informe uma data válida para digitação, Verifique!", 1, 0 )
	EndIf
EndIf

RestArea( aArea )

Return lRetorno