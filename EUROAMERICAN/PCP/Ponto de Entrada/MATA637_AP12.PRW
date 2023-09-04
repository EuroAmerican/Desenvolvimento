#Include 'Protheus.Ch'
#Include 'Totvs.Ch'
#Include "FwMvcDef.ch"
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

User Function MATA637()

Local oMdlSGF
Local oModelMAS
Local oModelDET
Local aArea       := GetArea()
Local lRetorno    := .T.
Local aParam      := ParamIxb
Local oObj        := aParam[1] // Objeto
Local cIdPonto    := aParam[2] // Id do Ponto de Entrada
Local nOpc        := 0
Local cProduto    := ""
Local cRoteiro    := ""
Local nItem       := 0
Local nTotQtd     := 0
Local nTotRat     := 0
Local nCalc       := 0
Local nLin        := 0
Local lValido     := .T.

Private aEstrut   := {} // 1 - Componente; 2 - Descrição; 3 - Quantidade; 4 - Qtd. Rateado; 5 - Pendente?
Private aOperacao := {} // 1 - Operacao; 2 - Descrição; 3 - Pendente?

Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validação Total do Modelo											³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cIdPonto	==	"MODELPOS"
		oMdlSGF     := oObj //FWModelActive()
		oModelMAS   := oMdlSGF:GetModel('SGFMASTER')
		oModelDET   := oMdlSGF:GetModel('SGFDETAIL')
		nOpc        := oMdlSGF:GetOperation()
		cProduto    := oModelMAS:GetValue('GF_PRODUTO')
		cRoteiro    := oModelMAS:GetValue('GF_ROTEIRO')

		If oObj:GetOperation() <> MODEL_OPERATION_DELETE
			// Varrer estrutura do produto...
			dbSelectArea("SG1")
			dbSetOrder(1)
			If SG1->( dbSeek( xFilial("SG1") + cProduto ) )
				Do While !SG1->( Eof() ) .And. SG1->G1_COD == cProduto
					dbSelectArea("SB1")
					dbSetOrder(1)
					If SB1->( dbSeek( xFilial("SB1") + SG1->G1_COMP ) )
						aAdd( aEstrut, { SG1->G1_COMP, SB1->B1_DESC, SG1->G1_QUANT, 0, .F. })
					Else
						aAdd( aEstrut, { SG1->G1_COMP, ""          , SG1->G1_QUANT, 0, .F. })
					EndIf

					SG1->( dbSkip() )
				EndDo
			EndIf

			// Varrer operações do produto...
			dbSelectArea("SG2")
			dbSetOrder(1)
			If SG2->( dbSeek( xFilial("SG2") + cProduto + cRoteiro ) )
				Do While !SG2->( Eof() ) .And. SG2->G2_PRODUTO == cProduto .And. SG2->G2_CODIGO == cRoteiro
					aAdd( aOperacao, { SG2->G2_OPERAC, SG2->G2_DESCRI, .F. })

					SG2->( dbSkip() )
				EndDo
			EndIf

			// Varre linhas do grid...
			For nItem := 1 to oModelDET:GetQtdLine()
				oModelDET:GoLine( nItem )
				If !oModelDET:IsDeleted()
					// Atualiza a estrutura...
					nLin := aScan( aEstrut, {|x| AllTrim( x[01] ) == AllTrim( oModelDET:GetValue('GF_COMP') ) })
					If nLin > 0
						aEstrut[nLin][04] += oModelDET:GetValue('GF_EQ_QUAN')
					EndIf
					If aEstrut[nLin][03] == aEstrut[nLin][04]
						aEstrut[nLin][05] := .T.
					Else
						aEstrut[nLin][05] := .F.
					EndIf

					// Atualiza a operação...
					nLin := aScan( aOperacao, {|x| AllTrim( x[01] ) == AllTrim( oModelDET:GetValue('GF_OPERAC') ) })
					If nLin > 0
						aOperacao[nLin][03] := .T.
					EndIf
				EndIf
			Next

			For nLin := 1 To Len( aEstrut )
				If !aEstrut[nLin][05]
					lValido := .F.
				EndIf
			Next

			If lValido
				For nLin := 1 To Len( aOperacao )
					If !aOperacao[nLin][03]
						lValido := .F.
					EndIf
				Next
			EndIf

			If !lValido
				lRetorno := .F.
				// Mostrar pendencias...
				fPendencia()
			EndIf
		EndIf
EndCase

RestArea( aArea )

Return lRetorno

Static Function fPendencia()

Private oOk         := LoadBitmap( GetResources(), "ENABLE"        )
Private oNo         := LoadBitmap( GetResources(), "DISABLE"       )
Private oFontSald1  := TFont():New( "Courier New",,27,,.F.,,,,,.F. )
Private oFontSaldo  := TFont():New( "Courier New",,27,,.T.,,,,,.F. )
Private oFontMsg    := TFont():New( "Courier New",,14,,.T.,,,,,.F. )
Private oFontC01    := TFont():New( "Courier New",,14,,.F.,,,,,.F. )
Private oFontC02    := TFont():New( "Courier New",,14,,.T.,,,,,.F. )
Private oFontC52    := TFont():New( "Courier New",,18,,.T.,,,,,.F. )
Private oFontC51    := TFont():New( "Arial"      ,,23,,.T.,,,,,.F. )
Private oFontC50    := TFont():New( "Arial"      ,,23,,.F.,,,,,.F. )
Private oFontC12    := TFont():New( "Arial"      ,,14,,.F.,,,,,.F. )

DEFINE MSDIALOG oDlgAdiant TITLE "Cadastro Operações x Componentes Pendentes" FROM 000, 000  TO 496, 785 PIXEL

	aTFolder := {'Operações e Estruturas'}
	oTFolder := TFolder():New( 0,0,aTFolder,,oDlgAdiant,,,,.T.,,C(309),C(182))

	//oGroup:= TGroup():New(C(003),C(005),C(077),C(303), 'Verique as amarrações pendentes de componentes da estrutura', oTFolder:aDialogs[1],,,.T.)
	oGroup:= TGroup():New(C(003),C(005),C(108),C(303), 'Verique as amarrações pendentes de componentes da estrutura', oTFolder:aDialogs[1],,,.T.)

	oLbxEst := TcBrowse():New(C(010),C(010),C(289),C(096),,,,oTFolder:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)

	oLbxEst:AddColumn( TCColumn():New(" "                  ,{ || If(aEstrut[oLbxEst:nAt,05],oOk,oNo) },                           ,,,        ,,.T.,.F.,,,,.F.,) )
	oLbxEst:AddColumn( TcColumn():New("Componente"         ,{ || aEstrut[oLbxEst:nAt,01] }   ,""                                  ,,,"CENTER",,.F.,.F.,,,,.F.,) )
	oLbxEst:AddColumn( TcColumn():New("Descrição"          ,{ || aEstrut[oLbxEst:nAt,02] }   ,""                                  ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oLbxEst:AddColumn( TcColumn():New("Qtd. Estrutura"     ,{ || aEstrut[oLbxEst:nAt,03] }   ,"@E 999,999,999.99"                 ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )
	oLbxEst:AddColumn( TcColumn():New("Qtd. Informada"     ,{ || aEstrut[oLbxEst:nAt,04] }   ,"@E 999,999,999.99"                 ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )

	oLbxEst:SetArray( aEstrut )
	oLbxEst:GoTop()

	oGroup:= TGroup():New(C(110),C(005),C(163),C(303), 'Verique operações do produto pendente', oTFolder:aDialogs[1],,,.T.)

	oLbxOpe := TcBrowse():New(C(117),C(010),C(289),C(044),,,,oTFolder:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)

	oLbxOpe:AddColumn( TCColumn():New(" "                  ,{ || If(aOperacao[oLbxOpe:nAt,03],oOk,oNo) },                           ,,,        ,,.T.,.F.,,,,.F.,) )
	oLbxOpe:AddColumn( TcColumn():New("Operação"           ,{ || aOperacao[oLbxOpe:nAt,01] }   ,""                                  ,,,"CENTER",,.F.,.F.,,,,.F.,) )
	oLbxOpe:AddColumn( TcColumn():New("Descrição"          ,{ || aOperacao[oLbxOpe:nAt,02] }   ,""                                  ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )

	oLbxOpe:SetArray( aOperacao )
	oLbxOpe:GoTop()

	@ 222, 365 Button "Sair"       Size 28, 10 Action ( oDlgAdiant:End() )

	oTMsgBar   := TMsgBar():New(oDlgAdiant, AllTrim(SM0->M0_NOME) + "/" + AllTrim(SM0->M0_FILIAL), .F.,.F.,.F.,.F., ,,oFontMsg,.F.)
	oTMsgItem1 := TMsgItem():New( oTMsgBar,"Necessário concluir todo o processo de operações e estruturas", 500,, ,,.T., {||} )

ACTIVATE MSDIALOG oDlgAdiant CENTERED

Return