#Include 'Protheus.Ch'
#Include 'Totvs.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

User Function EQVldSGF( _cCampo )

Local lRetorno  := .T.
Local cCampo    := AllTrim( Upper( _cCampo ) )
Local aArea     := GetArea()
Local oMdlSGF   := FWModelActive()
Local oModelMAS := oMdlSGF:GetModel('SGFMASTER')
Local oModelDET := oMdlSGF:GetModel('SGFDETAIL')
Local nOpc      := oMdlSGF:GetOperation()
Local cProduto  := oModelMAS:GetValue('GF_PRODUTO')
Local cRoteiro  := oModelMAS:GetValue('GF_ROTEIRO')
Local cOperacao := oModelDET:GetValue('GF_OPERAC')
Local cTRT      := oModelDET:GetValue('GF_TRT')
Local cCompon   := oModelDET:GetValue('GF_COMP')
Local nQuant    := oModelDET:GetValue('GF_EQ_QUAN')
Local nRateio   := oModelDET:GetValue('GF_EQ_RATE')
Local nLinha    := oModelDET:GetLine()
Local nItem     := 0
Local nTotQtd   := 0
Local nTotRat   := 0
Local nCalc     := 0

dbSelectArea("SG1")
dbSetOrder(1)
If !SG1->( dbSeek( xFilial("SG1") + cProduto + cCompon + cTRT ) )
	ApMsgAlert( 'Informe o Produto e o Componente antes de classificar a quantidade e rateio!', 'Atenção' )
	lRetorno := .F.
EndIf

If lRetorno
	Do Case
		Case AllTrim( cCampo ) == "GF_EQ_QUAN"
			If nQuant > SG1->G1_QUANT
				ApMsgAlert( 'A quantidade informada para requisição nesta operação é superior ao limite da estrutura para este componente: ' + Transform( SG1->G1_QUANT, "@E 999,999,999.9999") + CRLF + 'Efetue este cadastro baseado na estrutura!', 'Atenção' )
				lRetorno := .F.
			Else
				// Achar o % do rateio:
				nCalc := (nQuant / SG1->G1_QUANT) * 100
				oModelDET:LoadValue("GF_EQ_RATE", nCalc)
			EndIf

		Case AllTrim( cCampo ) == "GF_EQ_RATE"
			If nRateio > 100
				ApMsgAlert( 'Percentual de rateio não pode ser superior a 100%!', 'Atenção' )
				lRetorno := .F.
			Else
				// Achar a quantidade do rateio no componente
				nCalc := SG1->G1_QUANT * (nRateio / 100.0)
				oModelDET:LoadValue("GF_EQ_QUAN", nCalc)
			EndIf
	EndCase
EndIf

// Verificar todas as linhas para as operações que utilizam o componente...
nTotQtd := 0
nTotRat := 0

For nItem := 1 to oModelDET:GetQtdLine()
	oModelDET:GoLine( nItem )
	If !oModelDET:IsDeleted()
		If AllTrim( cCompon ) == AllTrim( oModelDET:GetValue('GF_COMP') )
			nTotQtd += oModelDET:GetValue('GF_EQ_QUAN')
			nTotRat += oModelDET:GetValue('GF_EQ_RATE')
		EndIf
	EndIf
Next

If nTotQtd > SG1->G1_QUANT
	ApMsgAlert( 'A quantidade total informada no componente ' + AllTrim( cCompon ) + ' é superior ao cadastro baseado na estrutura!', 'Atenção' )
	lRetorno := .F.
ElseIf nTotRat > 100
	ApMsgAlert( 'Percentual total de rateio do componente ' + AllTrim( cCompon ) + ' é superior a 100%!', 'Atenção' )
	lRetorno := .F.
EndIf

// Volta a linha original
oModelDET:GoLine( nLinha )

RestArea( aArea )

Return lRetorno