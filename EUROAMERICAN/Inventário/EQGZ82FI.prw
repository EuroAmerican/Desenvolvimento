#include "Totvs.ch"
#include "FwMvcDef.ch"
#include "TbiConn.ch"
#include "TopConn.ch"

User Function EQGZ82FI()

Local aArea      := GetArea()
Local oMdl       := FWModelActive()
Local oModel     := oMdl:GetModel('ID_ENCH_Z82')
Local cFicha     := AllTrim( oModel:GetValue('Z82_FICHA') )
Local cCodigo    := oModel:GetValue('Z82_CODIGO')
Local cContagem  := oModel:GetValue('Z82_CONTAG')
Local cProduto   := oModel:GetValue('Z82_PRODUT')
Local cLocal     := oModel:GetValue('Z82_LOCAL')
Local cLote      := oModel:GetValue('Z82_LOTECT')
Local nLinAtu    := oModel:GetLine()
Local cNewCont   := ""
Local cNewEnder  := ""
Local cNewGrupo  := ""

If IsNumeric( cFicha )
	cFicha := StrZero( Val( cFicha ), 6)
	oModel:SetValue('Z82_FICHA' , cFicha)

	// Verifica se ficha já foi digitada anteriormente...
	For nLinha := 1 To oModel:Length()
		oModel:GoLine( nLinha )
		If nLinha <> nLinAtu
			If !oModel:IsDeleted()
				//If cFicha + cProduto + cLocal + cLote == oModel:GetValue('Z82_FICHA') + oModel:GetValue('Z82_PRODUT') + oModel:GetValue('Z82_LOCAL') + oModel:GetValue('Z82_LOTECT')
				If cFicha == oModel:GetValue('Z82_FICHA')
					cNewGrupo := oModel:GetValue('Z82_GRUPO')
					cNewEnder := oModel:GetValue('Z82_LOCALI')
				EndIf
			EndIf
		EndIf
	Next

	cQuery := "SELECT Z82_GRUPO, Z82_LOCALI, Z82_CONTAG " + CRLF
	cQuery += "FROM " + RetSqlName("Z82") + " AS Z82 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE Z82_FILIAL = '" + xFilial("Z82") + "' " + CRLF
	cQuery += "AND Z82_CODIGO <> '" + cCodigo + "' " + CRLF
	cQuery += "AND Z82_FICHA = '" + cFicha + "' " + CRLF
	cQuery += "AND Z82_PRODUT = '" + cProduto + "' " + CRLF
	cQuery += "AND Z82_LOCAL = '" + cLocal + "' " + CRLF
	cQuery += "AND Z82_LOTECT = '" + cLote + "' " + CRLF
	cQuery += "AND Z82.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPZ82"
	dbSelectArea("TMPZ82")
	dbGoTop()

	Do While !TMPZ82->( Eof() )
		//cNewCont  += TMPZ82->Z82_CONTAG
		If Empty( cNewGrupo )
			cNewGrupo := TMPZ82->Z82_GRUPO
			cNewEnder := TMPZ82->Z82_LOCALI
		EndIf

		TMPZ82->( dbSkip() )
	EndDo

	TMPZ82->( dbCloseArea() )

	If !Empty( cNewGrupo )
		oModel:SetValue('Z82_GRUPO' , cNewGrupo)
		oModel:SetValue('Z82_LOCALI', cNewEnder)
		//If !("1" $ cNewCont)
		//	oModel:SetValue('Z82_CONTAG', "1")
		//ElseIf !("2" $ cNewCont)
		//	oModel:SetValue('Z82_CONTAG', "2")
		//ElseIf !("3" $ cNewCont)
		//	oModel:SetValue('Z82_CONTAG', "3")
		//EndIf
	EndIf
EndIf

RestArea( aArea )

Return cFicha