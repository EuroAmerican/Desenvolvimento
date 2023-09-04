#Include "Totvs.Ch"
#Include "Protheus.Ch"
#Include "RwMake.Ch"
#Include "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT125APV ºAutor  ³Microsiga           º Data ³  08/31/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PE para grupo de aprovadores do contrato de parceria       º±±
±±º          ³ Utiliza critério por centro de custos...                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Euroamerican                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT125APV()

Local cQuery    := ""
Local cGrpApv   := SC3->C3_APROV // FS - Guarda o grupo de aprovadores atual do pedido...
Local aArea     := GetArea()
Local cRetorno  := ""
Local cDefault  := GetMV("MV_CPAPROC",,"000002")
Local nLimiteCC := GetMV("MV_EQ_LACC",, 30000.00)

If Empty( cDefault )
	cDefault := "000002"
EndIf

If Empty( cGrpApv )
	cGrpApv := cDefault
EndIf

If nLimiteCC == 0
	nLimiteCC := 30000
EndIf

// ============================================================
//  Grupo Empresa - Ajuste realizado em 31.08.20 (CG)
// ============================================================

// cEmpAnt (Substituido por cFilAnt)

If (Left(cFilAnt,2) == "02" .And. SC3->C3_FORNECE $ "016442|013768") .Or. (Left(cFilAnt,2) == "08" .And. SC3->C3_FORNECE $ "014865|013768") .Or. (Left(cFilAnt,2) == "08" .And. SC3->C3_FORNECE $ "014865|016442")
	cRetorno := "000004"
Else
	cQuery := "SELECT CASE WHEN C3_MOEDA = 2 THEN SUM(C3_TOTAL * C3_TXMOEDA) ELSE SUM(C3_TOTAL) END AS VALOR " + CRLF
	cQuery += "FROM " + RetSqlName("SC3") + " AS SC3 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE C3_FILIAL = '" + xFilial("SC3") + "' " + CRLF
	cQuery += "AND C3_NUM = '" + SC3->C3_NUM + "' " + CRLF
	cQuery += "AND SC3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY C3_MOEDA " + CRLF
	
	If Select("TSC3") > 0
		TSC3->(dbCloseArea())
	EndIf
	
	TCQUERY cQuery NEW ALIAS TSC3
	dbSelectArea("TSC3")
	dbGoTop()
	
	If !TSC3->( Eof() )
		If TSC3->VALOR > nLimiteCC
			If Left(cFilAnt,2) == "02"
				cRetorno := "000005"
			Else
				cRetorno := "000001"
			EndIf
		Else
			cRetorno := SubStr( SC3->C3_CC, 2, 6)
		EndIf
	EndIf

	TSC3->( dbCloseArea() )
EndIf

// Valida existencia do grupo de aprovadores...
If !Empty( cRetorno )
	dbSelectArea("SAL")
	dbSetOrder(1)
	If !SAL->( dbSeek( xFilial("SAL") + cRetorno ) )
		ApMsgAlert( "Não foi possível calcular o Grupo de Aprovadores, efetue o cadastro conforme centro de custos", "Atenção")
		cRetorno := cGrpApv
	EndIf
Else
	cRetorno := cGrpApv
EndIf

// Atualiza grupo de aprovadores...
If !Empty( cRetorno )
	TcSqlExec("UPDATE " + RetSqlName("SC3") + " SET C3_APROV = '" + cRetorno + "' WHERE C3_FILIAL = '" + xFilial("SC3") + "' AND C3_NUM = '" + SC3->C3_NUM + "' AND D_E_L_E_T_ = ' ' ")
EndIf

RestArea( aArea )

Return (cRetorno)