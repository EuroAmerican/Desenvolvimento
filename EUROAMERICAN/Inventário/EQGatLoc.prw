#Include "Totvs.Ch"
#Include "Protheus.Ch"
#Include "TopConn.Ch"
#Include "TbiConn.Ch"

User Function EQGatLoc()

Local cRetorno := ""
Local cQuery   := ""
Local aArea    := GetArea()
Local oMdl     := FWModelActive()
Local oModel   := oMdl:GetModel('ID_ENCH_Z82')
Local cProduto := AllTrim( oModel:GetValue('Z82_PRODUT') )
Local cLote    := AllTrim( oModel:GetValue('Z82_LOTECT') )
Local cLocal   := AllTrim( oModel:GetValue('Z82_LOCAL' ) )

If AllTrim( cLocal ) == "07" // Local de quarentena/reprocesso deve sugerir o último lote do produto...
	dbSelectArea("SB1")
	dbSetOrder(1)
	If SB1->( dbSeek( xFilial("SB1") + cProduto ) )
		If AllTrim( SB1->B1_RASTRO ) <> "N"
			cQuery := "SELECT TOP 1 B8_LOTECTL " + CRLF
			cQuery += "FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
			cQuery += "WHERE B8_FILIAL = '" + xFilial("SB8") + "' " + CRLF
			cQuery += "AND B8_PRODUTO = '" + AllTrim( cProduto ) + "' " + CRLF
			cQuery += "AND B8_LOCAL = '" + AllTrim( cLocal ) + "' " + CRLF
			cQuery += "AND B8_LOTECTL <> '' " + CRLF
			cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF

			TCQuery cQuery New Alias "TMPLOTE"
			dbSelectArea("TMPLOTE")
			dbGoTop()

			If !TMPLOTE->( Eof() )
				cRetorno := TMPLOTE->B8_LOTECTL
				oModel:SetValue('Z82_LOTECT', cRetorno )
			EndIf
			
			TMPLOTE->( dbCloseArea() )
		EndIf
	EndIf
EndIf

RestArea( aArea )

Return cRetorno