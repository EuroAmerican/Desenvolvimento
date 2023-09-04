#include "rwmake.ch"
#include "topconn.ch"
#Include "Protheus.Ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |MT120APV  ºAutor  ³Emerson Paiva       º Data ³  21/07/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ PE alteração Grupo de Aprovação                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                     A L T E R A C O E S                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ºProgramador       ºAlteracoes                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

// FS - Efetuado acertos nos critérios...

User Function MT120APV()

Local cQry      := ""
Local cGrpApv   := SC7->C7_APROV // FS - Guarda o grupo de aprovadores atual do pedido...
Local aArea     := GetArea()
Local aAreaSC7  := SC7->( GetArea() )
Local aAreaSCR  := SCR->( GetArea() )
Local _cRet     := ""
Local cDefault  := GetMV("MV_PCAPROC",,"000002")
Local nLimiteCC := GetMV("MV_EQ_LACC",, 30000.00)

If Empty( cDefault )
	cDefault := "000002"
EndIf

If Empty( cGrpApv )
	cGrpApv := cDefault
EndIf

/*
_cRet := Substr(SC1->C1_CC,2,6)
If	SC1->C1_RATEIO $ "1"
	_cRet	:= "000003"
EndIf
*/

_cRet := Substr(SC7->C7_CC,2,6)

If	SC7->C7_RATEIO $ "1"
	_cRet	:= "000003"
EndIf

// ============================================================
//  Grupo Empresa - Ajuste realizado em 31.08.20 (CG)
// ============================================================

// cEmpAnt (Substituido por cFilAnt)

cQry := " SELECT	CASE C7_RATEIO WHEN '1' THEN '000003' ELSE "
cQry += " 				CASE C7_MOEDA	"
cQry += " 				WHEN 2 THEN "

If Left(cFilAnt,1,2) == "02"
	cQry += " 					CASE WHEN SUM(C7_TOTAL * C7_TXMOEDA) <= " + AllTrim( Str( nLimiteCC ) ) + " THEN SUBSTRING(C7_CC,2,6) ELSE '000005'	END	 "
	cQry += " 				ELSE "
	cQry += " 					CASE WHEN SUM(C7_TOTAL) <= " + AllTrim( Str( nLimiteCC ) ) + " THEN SUBSTRING(C7_CC,2,6) ELSE '000005' END "
Else
	cQry += " 					CASE WHEN SUM(C7_TOTAL * C7_TXMOEDA) <= " + AllTrim( Str( nLimiteCC ) ) + " THEN SUBSTRING(C7_CC,2,6) ELSE '000001'	END	 "
	cQry += " 				ELSE "
	cQry += " 					CASE WHEN SUM(C7_TOTAL) <= " + AllTrim( Str( nLimiteCC ) ) + " THEN SUBSTRING(C7_CC,2,6) ELSE '000001' END "
EndIf

cQry += " 				END END AS APROVA, C7_FORNECE FORNECEDOR "
cQry += " FROM " + RetSqlName("SC7") + " SC7 "
cQry += " WHERE	D_E_L_E_T_ = '' AND C7_FILIAL = '" + xFilial("SC7") + "' "
cQry += " 		AND C7_NUM = '"+ SC7->C7_NUM + "' "
cQry += " GROUP BY C7_NUM, C7_CC, C7_MOEDA, C7_RATEIO, C7_FORNECE " // FS - Comentado para não quebrar por CC, o que pode gerar confusão no momento de acumular os valores e encontrar no limite o grupo correto...
//cQry += " GROUP BY C7_NUM, C7_MOEDA, C7_RATEIO, C7_FORNECE "

If Select("TSC7") > 0
	TSC7->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS TSC7
        
dbSelectArea("TSC7")
dbGoTop()

If !TSC7->( Eof() )
	
	If Left(cFilAnt,2) == "02" .AND. TSC7->FORNECEDOR $ "016442|013768"
		_cRet := "000004"
	ElseIf Left(cFilAnt,2) == "08" .AND. TSC7->FORNECEDOR $ "014865|013768"
		_cRet := "000004"	
	ElseIf Left(cFilAnt,2) == "09" .AND. TSC7->FORNECEDOR $ "014865|016442"
		_cRet := "000004"	
	Else
		_cRet := TSC7->APROVA	
	EndIf
	
	//FS - Comentado... Deve gravar no momento correto...
	//cQry := " UPDATE " + RetSqlName("SC7") + " "
	//cQry += " SET		C7_APROV = '" + _cRet + "' "
	//cQry += " WHERE	D_E_L_E_T_ = '' AND C7_ENCER <> 'E' AND C7_FILIAL = '" + xFilial("SC7") + "' AND C7_NUM = '" + SC7->C7_NUM + "' "
	
	//TcSqlExec(cQry)

EndIf

If SC7->C7_TIPO == 2 // Se AE definir grupo de MP somente por enquanto...
	_cRet := "A00001"
Else
	//MsgInfo("C7_APROV: " + SC7->C7_APROV + " / Resultado cRet: " + _cRet )
	// FS - Valida existencia do grupo de aprovadores...
	If !Empty( _cRet )
		dbSelectArea("SAL")
		dbSetOrder(1)
		If !SAL->( dbSeek( xFilial("SAL") + _cRet ) )
			ApMsgInfo( "Não foi possível calcular o Grupo de Aprovadores, efetue o cadastro conforme centro de custos", "Atenção")
			_cRet := cGrpApv
		EndIf
	Else
		_cRet := cGrpApv
	EndIf
EndIf

// FS - Grava aqui o grupo...
If !Empty( _cRet )
	cQry := " UPDATE " + RetSqlName("SC7") + " "
	cQry += " SET		C7_APROV = '" + _cRet + "' "
	cQry += " WHERE	D_E_L_E_T_ = '' AND C7_ENCER <> 'E' AND C7_FILIAL = '" + xFilial("SC7") + "' AND C7_NUM = '" + SC7->C7_NUM + "' "
	
	TcSqlExec(cQry)
EndIf

SCR->( RestArea( aAreaSCR ) )
SC7->( RestArea( aAreaSC7 ) )
RestArea( aArea )

Return (_cRet)