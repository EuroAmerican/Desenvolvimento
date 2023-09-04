#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'
#Include "RESTFUL.CH"
#Include "FWMVCDEF.CH"
#Include 'APVT100.CH'

// FS - Ponto de entrada após a gravação do apontamento no ACD...

User Function AC023FMV()

Local aAreaCBH    := CBH->( GetArea() )
Local aArea       := GetArea()
Local lRetorto    := .T.
Local cOP         := IIf( Type("cOP") == "C", cOP, "")
Local cOperacao   := IIf( Type("cOperacao") == "C", cOperacao, "")
Local cRecurso    := IIf( Type("cRecurso") == "C", cRecurso, "")
Local nQuant      := IIf( Type("nQeApont") == "N", nQeApont, 0)
Local cTransac    := IIf( Type("cTransac") == "C", cTransac, "01")
Local cURL        := GetMV("MV_FB_URLE",,"http://10.0.0.90:3000") 
Local aHeader     := {}
Local oRestClient := Nil
Local oObjResult  := Nil
Local lContinua   := .T.
Local cNewRec     := Space( TamSX3("H6_RECURSO")[1] )
Local lEnvase     := .F.
Local lEnvia      := .T.
Local cQuery      := ""
Local nEnvase     := 0
Local nOPEnv      := 0

If Type("cTipo") == "U" .And. cTipIni == "1" // Inicio de Tipo da Transação
	//If Type("cRecurso") == "U" .And. Empty( cRecurso ) // Recurso deve está vazio
		If Select("CBH") <> 0 .And. CBH->CBH_TRANSA == "01" //Type("cTransac") == "U" .And. AllTrim( cTransac ) == "01" // Somente se Inicio de Transacao
			While lContinua
				If IsTelnet() .and. VtModelo() == "RF"
					VtClear()
					@ 0,00 VtSay "Informar o Recurso"
					@ 2,00 VtSay "Recurso: " 
					@ 2,10 VtGet cNewRec pict '@!' Valid ValRec(cNewRec) F3 "SH1" When Empty(cNewRec)
					VtRead
					If VtLastKey() == 27
						Exit
					EndIf
					lContinua := .F.
				EndIf
			EndDo

			CBH->( RecLock("CBH", .F.) )
				CBH->CBH_RECUR := cNewRec
			CBH->( MsUnLock() )

			lEnvase := AllTrim( CBH->CBH_TRANSA ) == "50"
			cOP     := AllTrim( CBH->CBH_OP )

			If lEnvase
				// Verifica quantidade apontada de envase
				cQuery := "SELECT SUM(ENVAPOT) AS ENVAPOT, SUM(ENVORDEM) AS ENVORDEM " + CRLF
				cQuery += "FROM ( " + CRLF
				cQuery += "SELECT COUNT(*) AS ENVAPOT, 0 AS ENVORDEM " + CRLF
				cQuery += "FROM " + RetSqlName("SH6") + " AS SH6 WITH (NOLOCK) " + CRLF
				cQuery += "WHERE H6_FILIAL = '" + xFilial("SH6") + "' " + CRLF
				cQuery += "AND LEFT( H6_OP, 6) = '" + Left( cOP, 6) + "' " + CRLF
				cQuery += "AND H6_OPERAC = '50' " + CRLF
				cQuery += "AND H6_TIPO = 'P' " + CRLF
				cQuery += "AND SH6.D_E_L_E_T_ = ' ' " + CRLF
				cQuery += "UNION ALL " + CRLF
				cQuery += "SELECT 0 AS ENVAPOT, COUNT(*) AS ENVORDEM " + CRLF
				cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
				cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
				cQuery += "  AND B1_COD = C2_PRODUTO " + CRLF
				cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
				cQuery += "INNER JOIN " + RetSqlName("SG2") + " AS SG2 WITH (NOLOCK) ON G2_FILIAL = '" + xFilial("SG2") + "' " + CRLF
				cQuery += "  AND G2_PRODUTO = C2_PRODUTO " + CRLF
				cQuery += "  AND G2_OPERAC = '50' " + CRLF
				cQuery += "  AND SG2.D_E_L_E_T_ = ' ' " + CRLF
				cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
				cQuery += "AND C2_NUM = '" + Left( cOP, 6) + "' " + CRLF
				cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
				cQuery += ") AS AGRUPADO " + CRLF
			
				TCQuery cQuery New Alias "TMPCON"
				dbSelectArea("TMPCON")
				dbGoTop()
			
				If !TMPCON->( Eof() )
					nEnvase := TMPCON->ENVAPOT
					nOPEnv  := TMPCON->ENVORDEM
				EndIf
			
				TMPCON->( dbCloseArea() )
			
				//Verificar se é início do envase e se é o primeiro...
				If CBH->CBH_TRANSA == "01"
					If nEnvase > 1
						lEnvia := .F.
					EndIf
				//Verificar se é apontamento do envase e se é o último
				ElseIf CBH->CBH_TRANSA == "04"
					If nEnvase < nOPEnv
						lEnvia := .F.
					EndIf
				EndIf
			
				// Ajusta item para 05 na OP...
				cOP := Left( cOP, 6) + "05001"
			EndIf

			// ---------------->>>>>>>>>>>>>>> Chama webservice Restfull do Flowboard...
			If lEnvia
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Adiciona Header para WS...                                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd( aHeader, "Content-Type: application/json" )
				aAdd( aHeader, "Accept: application/json" )
				aAdd( aHeader, "charset: UTF-8" )
				
				oRestClient  := FWRest():New(Alltrim(cURL))
				oRestClient:setPath("/post")
				
				cJson := '{'
				cJson += '"op" : "' + AllTrim( cOP ) + '",'
				cJson += '"timestamp" : "' + Left( DTOS( dDataBase ), 4) + '-' + SubStr( DTOS( dDataBase ), 5, 2) + '-' + Right( DTOS( dDataBase ), 2) + ' ' + Left( Time(), 5) + ':00",'
				cJson += '"cod_recurso" : "' + AllTrim( CBH->CBH_RECUR ) + '",'
				cJson += '"cod_operacao" : "' + AllTrim( CBH->CBH_OPERAC ) + '",' 
				cJson += '"cod_transacao" : "' + AllTrim( CBH->CBH_TRANSA ) + '",'
				cJson += '"cod_parada" : "",'
				cJson += '"evento_parada" : ""'
				cJson += '}'
				
				oRestClient:SetPostParams(EncodeUTF8(cJson))
				
				If oRestClient:Post( aHeader )
				    cError := ""
				    nStatus := HTTPGetStatus(@cError)
				
				    If nStatus >= 200 .And. nStatus <= 299
				        If Empty(oRestClient:getResult())
				            ConOut(nStatus)
				        Else
				            ConOut(oRestClient:getResult())
				        EndIf
				    Else
				        ConOut(cError)
				    EndIf
				Else
				    //ConOut(oRestClient:getLastError() + CRLF + oRestClient:getResult())
				    ConOut(oRestClient:getLastError())
				EndIf

				// Verificar se operação de fracionamento...
				// Se fracionamento, verificar se o produto pula operação de dispersão caso tenha operação de dispersão
				If AllTrim( CBH->CBH_OPERAC ) == "10" .And. AllTrim( CBH->CBH_TRANSA ) == "04"
					dbSelectArea("SC2")
					dbSetOrder(1)
					If SC2->( dbSeek( xFilial("SC2") + cOP ) )
						dbSelectArea("SB1")
						dbSetOrder(1)
						If SB1->( dbSeek( xFilial("SB1") + SC2->C2_PRODUTO ) )
							// Se não faz dispersão, aponta zero
							If AllTrim( SB1->B1_EQ_DISP ) == "N" // ******************************** PULA OPERAÇÃO ********************************
								// Posiciona na Operação Dispersão...
								dbSelectArea("SG2")
								dbSetOrder(1) // G2_FILIAL, G2_PRODUTO, G2_CODIGO, G2_OPERAC
								If SG2->( dbSeek( xFilial("SG2") + SC2->C2_PRODUTO + IIf(!Empty(SC2->C2_ROTEIRO), SC2->C2_ROTEIRO, SB1->B1_OPERPAD) + "20" ) )
									// Posiciona no Recurso...
									dbSelectArea("SH1")
									dbSetOrder(1)
									If SH1->( dbSeek( xFilial("SH1") + SG2->G2_RECURSO ) )
										// Apontar 0 para dispersão...
										fApontar( "20" )
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				// Verificar se operação de dispersão...
				// Se dispersão, verificar se o produto pula operação de completagem caso tenha operação de completagem no roteiro
				ElseIf AllTrim( CBH->CBH_OPERAC ) == "20" .And. AllTrim( CBH->CBH_TRANSA ) == "04"
					dbSelectArea("SC2")
					dbSetOrder(1)
					If SC2->( dbSeek( xFilial("SC2") + cOP ) )
						dbSelectArea("SB1")
						dbSetOrder(1)
						If SB1->( dbSeek( xFilial("SB1") + SC2->C2_PRODUTO ) )
							// Se não faz dispersão, aponta zero
							If AllTrim( SB1->B1_EQ_COMP ) == "N" // ******************************** PULA OPERAÇÃO ********************************
								// Posiciona na Operação Completagem...
								dbSelectArea("SG2")
								dbSetOrder(1) // G2_FILIAL, G2_PRODUTO, G2_CODIGO, G2_OPERAC
								If SG2->( dbSeek( xFilial("SG2") + SC2->C2_PRODUTO + IIf(!Empty(SC2->C2_ROTEIRO), SC2->C2_ROTEIRO, SB1->B1_OPERPAD) + "30" ) )
									// Posiciona no Recurso...
									dbSelectArea("SH1")
									dbSetOrder(1)
									If SH1->( dbSeek( xFilial("SH1") + SG2->G2_RECURSO ) )
										// Apontar 0 para completagem...
										fApontar( "30" )
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	//EndIf
EndIf

//If !Empty( cOP ) .And. AllTrim( cTransac ) == "01"
//	Return
//EndIf

CBH->( RestArea( aAreaCBH ) )
RestArea( aArea )

Return

Static Function ValRec( cRec )

SH1->(DbSetOrder(1))
If !SH1->( dbSeek( xFilial("SH1") + cRec ) )
	CBAlert("Recurso nao cadastrado","Aviso",.T.,3000,2,.t.)
	Return .F.
EndIf

Return .T.

Static Function fApontar( cPular )

Local cIdent  := ""
Local cNumSeq := ""
Local dData   := dDataBase
Local cHora   := Left( Time(), 5)

dbSelectArea("SH6")
dbSetOrder(1)

dbSelectArea("SD3")
dbSetOrder(1)

cIdent := ProxNum()

RecLock("SH6", .T.)
	SH6->H6_FILIAL  := xFilial("SH6")
	SH6->H6_OP      := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN
	SH6->H6_PRODUTO := SC2->C2_PRODUTO
	SH6->H6_OPERAC  := AllTrim( cPular )
	SH6->H6_RECURSO := SG2->G2_RECURSO
	SH6->H6_DATAINI := dData
	SH6->H6_HORAINI := cHora
	SH6->H6_DATAFIN := dData
	SH6->H6_HORAFIN := cHora
	SH6->H6_QTDPROD := SC2->C2_QUANT
	SH6->H6_QTDPRO2 := SC2->C2_QTSEGUM
	SH6->H6_LOCAL   := SC2->C2_LOCAL
	SH6->H6_LOTECTL := SC2->C2_NUM
	SH6->H6_IDENT   := cIdent
	SH6->H6_DTAPONT := dData
	SH6->H6_DTPROD  := dData
	SH6->H6_PT      := "T"
	SH6->H6_DESDOBR := "000"
	SH6->H6_TEMPO   := "000:00"
	SH6->H6_TIPO    := "P"
	SH6->H6_DESDOBR := "000"
	SH6->H6_TIPOTEM := 1
	SH6->H6_CBFLAG  := "1"
	SH6->H6_OPERADO := "000035"
MsUnLock()

cNumSeq := ProxNum()

RecLock("SD3", .T.)
	SD3->D3_FILIAL  := xFilial("SD3")
	SD3->D3_TM      := "999"
	SD3->D3_COD     := "MO" + AllTrim( SH1->H1_CCUSTO )
	SD3->D3_UM      := "HR"
	SD3->D3_QUANT   := 0.001
	SD3->D3_CF      := "RE1"
	SD3->D3_OP      := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN
	SD3->D3_LOCAL   := "02"
	SD3->D3_DOC     := SC2->C2_NUM
	SD3->D3_EMISSAO := dData
	SD3->D3_CC      := "1030202"
	SD3->D3_IDENT   := cIdent
	SD3->D3_NUMSEQ  := cNumSeq
	SD3->D3_TIPO    := "MO"
	SD3->D3_USUARIO := "PROD1"
	SD3->D3_CHAVE   := "E0"
	SD3->D3_EMPOP   := "N"
MsUnLock()

Return