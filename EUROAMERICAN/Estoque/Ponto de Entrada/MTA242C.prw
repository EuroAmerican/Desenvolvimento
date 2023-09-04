#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

User Function MTA242C()

Local lRetorno  := .T.
Local lPrimeiro := .T.
Local aArea     := GetArea()
Local cQuery    := ""
Local cCodigo   := ParamIxb[1]
Local aLinha    := {}
Local nLinha    := 1
Local nPosProd  := aScan( aHeader, {|x| AllTrim( x[2] ) == "D3_COD" })

If AllTrim( Upper( GetEnvServer() ) ) <> "FABIO"
	Return lRetorno
EndIf

cQuery := "SELECT G1_COMP " + CRLF
cQuery += "FROM " + RetSqlName("SG1") + " AS SG1 WITH (NOLOCK) " + CRLF
cQuery += "WHERE G1_FILIAL = '" + xFilial("SG1") + "' " + CRLF
cQuery += "AND G1_COD = '" + AllTrim( cCodigo ) + "' " + CRLF
cQuery += "AND SG1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "GROUP BY G1_COMP " + CRLF

TCQuery cQuery New Alias "TMPEST"
dbSelectArea("TMPEST")
dbGoTop()

Do While !TMPEST->( Eof() )
	If !lPrimeiro
		aLinha := {}
		aLinha := aClone( aCols )
		aAdd( aCols, aLinha[Len(aLinha)] )
		aCols[Len(aCols)][Len(aHeader)+1] := .F.
	Else
		lPrimeiro := .F.
	EndIf

	TMPEST->( dbSkip() )
EndDo

TMPEST->( dbGoTop() )
nLinha := 1

Do While !TMPEST->( Eof() )
	aCols[nLinha][nPosProd]       := TMPEST->G1_COMP
	aCols[nLinha][Len(aHeader)+1] := .T.

	nLinha++
	TMPEST->( dbSkip() )
EndDo

//n := Len( aCols )

GetDRefresh()

TMPEST->( dbCloseArea() )

RestArea( aArea )

Return lRetorno