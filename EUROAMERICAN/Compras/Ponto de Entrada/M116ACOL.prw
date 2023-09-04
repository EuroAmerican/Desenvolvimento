#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

User Function M116ACOL()

Local aArea     := GetArea()
Local cAliasSD1 := PARAMIXB[1] //-- Alias arq. NF Entrada itens
Local nX        := PARAMIXB[2] //-- Número da linha do aCols correspondente
Local aDoc      := PARAMIXB[3] //-- Vetor contendo o documento, série, fornecedor, loja e itens do documento
Local nPosProd  := aScan( aHeader, {|x| "D1_COD"     $ x[2] })
Local nPosLocal := aScan( aHeader, {|x| "D1_LOCAL"   $ x[2] })
Local nPosLote  := aScan( aHeader, {|x| "D1_LOTECTL" $ x[2] })
Local cQuery    := ""

cQuery := "SELECT D7_LIBERA, D7_LOCDEST " + CRLF
cQuery += "FROM " + RetSqlName("SD7") + " AS SD7 WITH (NOLOCK) " + CRLF
cQuery += "WHERE D7_FILIAL = '" + xFilial("SD7") + "' " + CRLF
cQuery += "AND D7_DOC = '" + AllTrim( aDoc[1] ) + "' " + CRLF
cQuery += "AND D7_SERIE = '" + AllTrim( aDoc[2] ) + "' " + CRLF
cQuery += "AND D7_FORNECE = '" + AllTrim( aDoc[3] ) + "' " + CRLF
cQuery += "AND D7_LOJA = '" + AllTrim( aDoc[4] ) + "' " + CRLF
cQuery += "AND D7_PRODUTO = '" + AllTrim( aCols[nX][nPosProd] ) + "' " + CRLF
cQuery += "AND D7_LOCAL = '" + AllTrim( aCols[nX][nPosLocal] ) + "' " + CRLF
//cQuery += "AND D7_LOTECTL = '" + AllTrim( aCols[nX][nPosLote] ) + "' " + CRLF
cQuery += "AND D7_LOCAL <> D7_LOCDEST " + CRLF
cQuery += "AND D7_LIBERA = 'S' " + CRLF
cQuery += "AND D_E_L_E_T_ = ' ' " + CRLF

TCQuery cQuery New Alias "TMPQUA"
dbSelectArea("TMPQUA")
dbGoTop()

Do While !TMPQUA->( Eof() )
	If AllTrim( TMPQUA->D7_LIBERA ) == "S"
		aCols[nX][nPosLocal] := TMPQUA->D7_LOCDEST
	EndIf

	TMPQUA->( dbSkip() )
EndDo

TMPQUA->( dbCloseArea() )

RestArea( aArea )

Return Nil