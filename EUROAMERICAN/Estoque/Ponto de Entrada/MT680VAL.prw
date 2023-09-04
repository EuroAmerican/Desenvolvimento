#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT680VAL º Autor ³ Fabio    	         º Data ³ 23/12/2017  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ponto de entrada para validação de apontamento produção    º±±
±±º          ³ PCP Mod 1 e 2                   							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grupo Sabará                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MT680VAL()

Local aArea    := GetArea()
Local lValido  := .T.

If AllTrim( cEmpAnt ) == "08" .Or. (AllTrim( cEmpAnt ) == "10" .And. AllTrim( cFilAnt ) == "0803") // Tratar somente Qualy por enquanto, a Euro trata PA por quilo e fica díficil automatizar processo...
	lValido := BeVldEmb()
EndIf

RestArea(aArea)

Return lValido

Static Function BeVldEmb() // Valida Componente embalagem ( Ajusta empenho da OP na embalagem automático se quantidade diferente )

Local aArea     := GetArea()
Local lRetorno  := .T.
Local cOP       := M->H6_OP
Local cProd     := M->H6_PRODUTO
Local nQuant    := M->H6_QTDPROD
Local cRecurso  := M->H6_RECURSO
Local cDtIni    := M->H6_DATAINI
Local cHrIni    := M->H6_HORAINI
Local cDtFin    := M->H6_DATAFIN
Local cHrFin    := M->H6_HORAFIN
Local aVetor    := {}
Local aEmpen    := {}
Local aMata682  := {} // Apontar horas improdutivas caso encavalado com outra OP no mesmo recurso do mesmo lote
Local nOpc      := 4  //Alteração

Private lFez    := .F.

dbSelectArea("SB1")
SB1->( dbSetOrder(1) )
If SB1->( dbSeek( xFilial("SB1") + cProd ) )
	If AllTrim( SB1->B1_TIPO ) $ "PA|KT"
		dbSelectArea("SC2")
		dbSetOrder(1)
		If SC2->( dbSeek( xFilial("SC2") + AllTrim( cOP ) ) )
			If SC2->C2_QUANT <> nQuant
				dbSelectArea("SG1")
				dbSetOrder(1)
				If SG1->( dbSeek( xFilial("SG1") + cProd ) )
					Do While !SG1->( Eof() ) .And. AllTrim( SG1->G1_COD ) == AllTrim( cProd )
						If SB1->( dbSeek( xFilial("SB1") + SG1->G1_COMP ) )
							If AllTrim( SB1->B1_TIPO ) $ "EM|ME" .And. SG1->G1_QUANT == 1
								dbSelectArea("SD4")
								dbSetOrder(2) // D4_FILIAL, D4_OP, D4_COD, D4_LOCAL
								If SD4->( dbSeek( xFilial("SD4") + M->H6_OP + SG1->G1_COMP ) )
									If SD4->D4_QUANT <> nQuant //.And. SD4->D4_QUANT == SC2->C2_QUANT
										RecLock("SD4", .F.)
											SD4->D4_QUANT   := nQuant
											SD4->D4_QTDEORI := nQuant
											SD4->D4_SLDEMP  := nQuant
										MsUnLock()
										lMsErroAuto := .F.
										 
										aVetor:={   {"D4_COD"     ,SD4->D4_COD		,Nil},;
										            {"D4_LOCAL"   ,SD4->D4_LOCAL	,Nil},;
										            {"D4_OP"      ,SD4->D4_OP		,Nil},;
										            {"D4_QTDEORI" ,nQuant           ,Nil},;
										            {"D4_QUANT"   ,nQuant           ,Nil},;
										            {"D4_TRT"     ,SD4->D4_TRT		,Nil}}
										             
										AADD(aEmpen,{   nQuant		,;
										                .F.}) 
										 
										MSExecAuto({|x,y,z| mata380(x,y,z)},aVetor,nOpc,aEmpen) 
										 
										If lMsErroAuto
										    Alert("Erro")
										    MostraErro()
										EndIf
									EndIf
								EndIf
							// Fabio... tratar empenho da PI (Forçar consumo total da PI produzida, se maior, requisitar menos para atender total)
							//          este deverá ser retirado quando houver integração com as balanças de dispersores e completagem 
							//          para buscar a produção da PI exata, enquanto não temos a integração, é impossível identificar o peso produzido 
							//          antes de finalizar todas as envases, ou seja, gerando problemas de acuracidade.
							ElseIf AllTrim( SB1->B1_TIPO ) $ "PI"
								nQtdSaida := 0

								// Não permitir consumir mais empenho da PI do que o apontado na OP Base...
								cQuery := "SELECT C2_QUANT, SUM(D4_QTDEORI) AS QUANTIDADE, SUM(D4_SLDEMP) AS QTDPENDENTE, " + CRLF
								cQuery += "       ISNULL((SELECT COUNT(*) FROM " + RetSqlName("SC2") + " WITH (NOLOCK) WHERE C2_FILIAL = '" + xFilial("SC2") + "' AND C2_NUM = '" + Left( SD4->D4_OP, 6) + "' AND C2_ITEM <> '01' AND C2_QUANT = (C2_QUJE + C2_PERDA) AND D_E_L_E_T_ = ' '), 0) AS QTDPAENV, 
								cQuery += "       ISNULL((SELECT COUNT(*) FROM " + RetSqlName("SC2") + " WITH (NOLOCK) WHERE C2_FILIAL = '" + xFilial("SC2") + "' AND C2_NUM = '" + Left( SD4->D4_OP, 6) + "' AND C2_ITEM <> '01' AND D_E_L_E_T_ = ' '), 0) AS QTDPAABE 
								cQuery += "FROM " + RetSqlName("SD4") + " AS SD4 WITH (NOLOCK) " + CRLF
								cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
								cQuery += "  AND B1_COD = D4_PRODUTO " + CRLF
								cQuery += "  AND B1_TIPO = 'PA' " + CRLF
								cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
								cQuery += "INNER JOIN " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) ON C2_FILIAL = D4_FILIAL " + CRLF
								cQuery += "  AND C2_NUM = LEFT(D4_OP, 6) " + CRLF
								cQuery += "  AND C2_ITEM = '01' " + CRLF
								cQuery += "  AND C2_SEQUEN = '001' " + CRLF
								cQuery += "  AND SC2.D_E_L_E_T_ = ' ' " + CRLF
								cQuery += "WHERE D4_FILIAL = '" + xFilial("SD4") + "' " + CRLF
								cQuery += "AND D4_OP LIKE '" + Left( SD4->D4_OP, 6) + "%' " + CRLF
								cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("SB1") + " WITH (NOLOCK) WHERE B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = D4_COD AND B1_TIPO = 'PI' AND D_E_L_E_T_ = ' ') " + CRLF
								cQuery += "AND SD4.D_E_L_E_T_ = ' ' " + CRLF
								cQuery += "GROUP BY C2_QUANT " + CRLF
								cQuery += "HAVING SUM(D4_QTDEORI) > C2_QUANT " + CRLF

								TCQuery cQuery New Alias "TMPPI"
								dbSelectArea("TMPPI")
								TMPPI->( dbGoTop() )

								If TMPPI->QUANTIDADE > TMPPI->C2_QUANT
									nQtdSaida := TMPPI->QTDPENDENTE - (TMPPI->C2_QUANT - TMPPI->QUANTIDADE)
								Else
									If (TMPPI->QTDPAABE - TMPPI->QTDPAENV) == 1
										nQtdSaida := TMPPI->QTDPENDENTE - (TMPPI->C2_QUANT - TMPPI->QUANTIDADE)
									EndIf
								EndIf

								TMPPI->( dbCloseArea() )

								dbSelectArea("SD4")
								dbSetOrder(2) // D4_FILIAL, D4_OP, D4_COD, D4_LOCAL
								If SD4->( dbSeek( xFilial("SD4") + M->H6_OP + SG1->G1_COMP ) )
									If nQtdSaida > 0 //.And. SD4->D4_QUANT == SC2->C2_QUANT
										RecLock("SD4", .F.)
											SD4->D4_QUANT   := nQtdSaida
											SD4->D4_QTDEORI := nQtdSaida
											SD4->D4_SLDEMP  := nQtdSaida
										MsUnLock()
										lMsErroAuto := .F.
										 
										aVetor:={   {"D4_COD"     ,SD4->D4_COD		,Nil},;
										            {"D4_LOCAL"   ,SD4->D4_LOCAL	,Nil},;
										            {"D4_OP"      ,SD4->D4_OP		,Nil},;
										            {"D4_QTDEORI" ,nQtdSaida        ,Nil},;
										            {"D4_QUANT"   ,nQtdSaida        ,Nil},;
										            {"D4_TRT"     ,SD4->D4_TRT		,Nil}}
										             
										AADD(aEmpen,{   nQtdSaida		,;
										                .F.}) 
										 
										MSExecAuto({|x,y,z| mata380(x,y,z)},aVetor,nOpc,aEmpen) 
										 
										If lMsErroAuto
										    Alert("Erro")
										    MostraErro()
										EndIf
									ElseIf nQtdSaida < 0
										RecLock("SD4", .F.)
											SD4->D4_QUANT   := D4_SLDEMP + (nQtdSaida * (-1))
											SD4->D4_QTDEORI := D4_SLDEMP + (nQtdSaida * (-1))
											SD4->D4_SLDEMP  := D4_SLDEMP + (nQtdSaida * (-1))
										MsUnLock()
										lMsErroAuto := .F.
										 
										aVetor:={   {"D4_COD"     ,SD4->D4_COD		,Nil},;
										            {"D4_LOCAL"   ,SD4->D4_LOCAL	,Nil},;
										            {"D4_OP"      ,SD4->D4_OP		,Nil},;
										            {"D4_QTDEORI" ,D4_SLDEMP + (nQtdSaida * (-1))        ,Nil},;
										            {"D4_QUANT"   ,D4_SLDEMP + (nQtdSaida * (-1))        ,Nil},;
										            {"D4_TRT"     ,SD4->D4_TRT		,Nil}}
										             
										AADD(aEmpen,{   D4_SLDEMP + (nQtdSaida * (-1))		,;
										                .F.}) 
										 
										MSExecAuto({|x,y,z| mata380(x,y,z)},aVetor,nOpc,aEmpen) 
										 
										If lMsErroAuto
										    Alert("Erro")
										    MostraErro()
										EndIf
									EndIf
								EndIf
								// Força empenho no SB8 para garantia da integridade
								cQuery := "UPDATE " + RetSqlName("SB8") + " SET B8_EMPENHO = B8_SALDO, B8_EMPENH2 = B8_SALDO2 WHERE B8_FILIAL = '" + xFilial("SB8") + "' AND B8_PRODUTO = '" + SC2->C2_PRODUTO + "' AND B8_LOTECTL = '" + AllTrim( SC2->C2_NUM ) + "' AND D_E_L_E_T_ = ' '"
								TCSqlExec( cQuery )
							EndIf
						EndIf

						SG1->( dbSkip() )
					EndDo
				EndIf
			EndIf
		EndIf
		/*
		If !Empty( cLoteCTL )
			cQuery := "SELECT COUNT(*) AS CONTA FROM " + RetSqlName("SB8") + " WHERE B8_FILIAL = '" + xFilial("SB8") + "' AND B8_PRODUTO = '" + AllTrim( cProd ) + "' AND B8_LOTECTL = '" + AllTrim( cLoteCTL ) + "' AND D_E_L_E_T_ = ' '"
			TCQuery cQuery New Alias "TMPLOTE"
			dbSelectArea("TMPLOTE")
			TMPLOTE->( dbGoTop() )
			If !TMPLOTE->( Eof() ) .And. TMPLOTE->CONTA > 0
				//ApMsgAlert("Lote informado já utilizado para este produto!", "LOTE UNICO")
				//lRetorno := .F.
			EndIf
			TMPLOTE->( dbCloseArea() )
		EndIf
		*/
	EndIf
EndIf

// Apontar horas improdutivas caso haja horários intercados entre as OPs de envase do mesmo lote (que é a OP na Qualy)
If lRetorno .And. !lFez
	lFez := .T.

	If Select( "TMPTEMPO" ) <> 0
		TMPTEMPO->( dbCloseArea() )
	EndIf

	cQuery := "SELECT H6_TIPO, H6_OP, H6_RECURSO, H6_DATAINI, H6_HORAINI, H6_DATAFIN, H6_HORAFIN, H6_TEMPO, H6_LOCAL " + CRLF
	cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SH6") + " AS SH6 WITH (NOLOCK) ON H6_FILIAL = C2_FILIAL " + CRLF
	cQuery += "  AND H6_OP = C2_NUM + C2_ITEM + C2_SEQUEN " + CRLF
	cQuery += "  AND H6_TIPO = 'P' " + CRLF
	cQuery += "  AND NOT EXISTS (SELECT * FROM " + RetSqlName("SH6") + " WHERE H6_FILIAL = C2_FILIAL AND H6_OP = C2_NUM + C2_ITEM + C2_SEQUEN AND H6_TIPO <> 'P' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "  AND SH6.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = C2_PRODUTO " + CRLF
	cQuery += "  AND B1_TIPO IN ('PA','KT') " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
	cQuery += "AND C2_NUM = '" + AllTrim( Left( cOP, 6) ) + "' " + CRLF
	cQuery += "AND C2_QUJE <> 0 " + CRLF
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPTEMPO"
	dbSelectArea("TMPTEMPO")
	dbGoTop()
	
	Do While !TMPTEMPO->( Eof() )
		// Se iniciou antes e terminou depois
		If TMPTEMPO->H6_DATAINI + TMPTEMPO->H6_HORAINI >= DTOS( cDtIni ) + cHrIni .And. TMPTEMPO->H6_DATAFIN + TMPTEMPO->H6_HORAFIN <= DTOS( cDtFin ) + cHrFin
			aMata682 := {}
			aAdd( aMata682, {"H6_RECURSO" ,TMPTEMPO->H6_RECURSO          ,NIL})
			aAdd( aMata682, {"H6_DATAINI" ,STOD(TMPTEMPO->H6_DATAINI)    ,NIL})
			aAdd( aMata682, {"H6_HORAINI" ,TMPTEMPO->H6_HORAINI          ,NIL})
			aAdd( aMata682, {"H6_DATAFIN" ,STOD(TMPTEMPO->H6_DATAINI)    ,NIL})
			aAdd( aMata682, {"H6_HORAFIN" ,TMPTEMPO->H6_HORAFIN          ,NIL})
			aAdd( aMata682, {"H6_TEMPO"   ,TMPTEMPO->H6_TEMPO            ,NIL})
			aAdd( aMata682, {"H6_DTAPONT" ,M->H6_DTAPONT                 ,NIL})
			aAdd( aMata682, {"H6_MOTIVO"  ,"02"                          ,NIL})
			aAdd( aMata682, {"H6_LOCAL"   ,TMPTEMPO->H6_LOCAL            ,NIL})
			//aAdd( aMata682, {"H6_CBFLAG"  ,"1"                           ,NIL}) // Flag que indica que foi gerado pelo ACD
			
			/*
			lMSErroAuto := .F.
			MsExecAuto({|x,y|MATA682(x,y)},aMata682,3)
			If lMSErroAuto
				DisarmTransaction()
				Break
			EndIf
			*/
		EndIf
	
		TMPTEMPO->( dbSkip() )
	EndDo
	
	TMPTEMPO->( dbCloseArea() )
EndIf

RestArea( aArea )

Return lRetorno
