#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'Colors.Ch'
#Include 'JPeg.Ch'
#Include 'HButton.Ch'
#Include 'DBTree.Ch'
#Include 'Font.Ch'
#Include 'TbiConn.Ch'
#Include 'Ap5Mail.Ch'

User Function EQAceOrd()

Private aDivergencia := {}
Private aArqOrdem    := {}
Private aOrdem       := {}
Private aTabela      := {}
Private lOrdem       := .F.
Private lCorrige     := .T.
Private nOrdem       := 0
Private nTabela      := 0
Private nContSX3     := 0
Private nLimCpos     := 350 // Limite de campos do SX3 por Arquivo, máximo possível é 359
Private cChaveAnt    := ""
Private cOrdemAnt    := ""

If !ApMsgYesNo( 'Efetuou Backup da SX3 antes de executar a rotina?', 'Atenção')
	Return
EndIf

aTabela := {}

aAdd( aTabela, {'SA1'})
aAdd( aTabela, {'SB1'})
aAdd( aTabela, {'SD1'})
aAdd( aTabela, {'SD2'})
aAdd( aTabela, {'SE1'})
aAdd( aTabela, {'SF4'})
aAdd( aTabela, {'SFT'})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregar as ordens válidas para o campo X3_ORDEM                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aOrdem := {}

For nOrdem := 1 To 359
	aAdd( aOrdem, { RetAsc(AllTrim(Str(nOrdem)),2,.T.) })
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa ordens SX3 na tabela SD1                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nTabela := 1 To Len( aTabela )
	dbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	SX3->(DbGotop())
	
	If SX3->( DbSeek( AllTrim( aTabela[nTabela][01] ) ) )
		Do While !SX3->( Eof() ) .And. AllTrim( SX3->X3_ARQUIVO ) == AllTrim( aTabela[nTabela][01] )
			If AllTrim( cChaveAnt ) <> AllTrim( SX3->X3_ARQUIVO )
				If nContSX3 >= nLimCpos
					aAdd( aDivergencia, { 'SX2', cChaveAnt, nContSX3, cChaveAnt + ' Arquivo com mais de ' + AllTrim( Str( nLimCpos ) ) + ' campos, ' + AllTrim( Str( nContSX3 ) ) + ', atenção, o limite é 359'})
					nSX2++
				EndIf
				cChaveAnt := AllTrim( SX3->X3_ARQUIVO )
				cOrdemAnt := ""
				nOrdem    := 0
				nContSX3  := 0
			EndIf
		
			nOrdem++
			nContSX3++
		
			If aScan( aOrdem, {|xY| AllTrim( xY[1] ) == AllTrim( SX3->X3_ORDEM ) }) == 0
				If aScan( aArqOrdem, {|xS| AllTrim( xS[1] ) == AllTrim( SX3->X3_ARQUIVO ) }) == 0
					aAdd( aArqOrdem, { AllTrim( SX3->X3_ARQUIVO ) })
				EndIf
				lOrdem := .T.
				aAdd( aDivergencia, { 'SX3', SX3->X3_CAMPO, SX3->( Recno() ), 'Campo ' + AllTrim( SX3->X3_CAMPO ) + ' com ordem definida inválida: ' + SX3->X3_ORDEM })
				nSX3++
				If lCorrige
					RecLock("SX3", .F.)
						SX3->X3_ORDEM := "XX"
					SX3->( MsUnLock() )
				EndIf
			Else
				If AllTrim( cOrdemAnt ) == AllTrim( SX3->X3_ORDEM )
					If aScan( aArqOrdem, {|xS| AllTrim( xS[1] ) == AllTrim( SX3->X3_ARQUIVO ) }) == 0
						aAdd( aArqOrdem, { AllTrim( SX3->X3_ARQUIVO ) })
					EndIf
					lOrdem := .T.
					aAdd( aDivergencia, { 'SX3', SX3->X3_CAMPO, SX3->( Recno() ), 'Campo ' + AllTrim( SX3->X3_CAMPO ) + ' com ordem definida duplicada no dicionário de dados: ' + SX3->X3_ORDEM })
					nSX3++
				EndIf
				If AllTrim( RetAsc(AllTrim(Str(nOrdem)),2,.T.) ) <> AllTrim( SX3->X3_ORDEM )
					If aScan( aArqOrdem, {|xS| AllTrim( xS[1] ) == AllTrim( SX3->X3_ARQUIVO ) }) == 0
						aAdd( aArqOrdem, { AllTrim( SX3->X3_ARQUIVO ) })
					EndIf
					lOrdem := .T.
					aAdd( aDivergencia, { 'SX3', SX3->X3_CAMPO, SX3->( Recno() ), 'Campo ' + AllTrim( SX3->X3_CAMPO ) + ' com ordem fora da sequência correta, está: ' + SX3->X3_ORDEM + ' e devia está:' + RetAsc(AllTrim(Str(nOrdem)),2,.T.) })
					nSX3++
				EndIf
			EndIf
		
			cOrdemAnt := AllTrim( SX3->X3_ORDEM )
		
			SX3->( DbSkip() )
		EndDo
		
		If lOrdem .And. lCorrige // Refazer a ordem correta dos campos para o arquivo...
			For nArq := 1 To Len( aArqOrdem )
				dbSelectArea("SX3")
				dbSetOrder(1)
				dbSeek( AllTrim( aArqOrdem[nArq][1] ) )
		
				aCampos := {}
				nOrdem  := 0
		
				Do While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == AllTrim( aArqOrdem[nArq][1] )
					nOrdem++
		
					aAdd( aCampos, { SX3->X3_CAMPO, RetAsc(AllTrim(Str(nOrdem)),2,.T.)})
		
					SX3->( dbSkip() )
				EndDo
		
				dbSelectArea("SX3")
				dbSetOrder(2)
		
				For nOrdem := 1 To Len( aCampos )
					If SX3->( dbSeek( AllTrim( aCampos[nOrdem][1] ) ) )
						RecLock("SX3", .F.)
							SX3->X3_ORDEM := AllTrim( aCampos[nOrdem][2] )
						MsUnLock()
					EndIf
				Next
			Next
		EndIf
	EndIf
Next

If Len(aDivergencia) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estrutura HTML da mensagem...                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMensagem := ''

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define dados de cabelho...                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCabec := {}
	aAdd( aCabec, {{'<B><Font Size=4 color=white>Divergências em dicionário de dados: ' + DTOC(MSDATE()) + '</Font></B>', '6', 100, 6, 'C'}})
	aAdd( aCabec, {{'<B><Font Size=2 color=black>Usuário</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim(CUSERNAME)  + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Empresa</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + cEmpAnt + ' / ' + AllTrim(SM0->M0_NOME) + '</Font>', '1', 40, 2, 'L'}})
	aAdd( aCabec, {{'<B><Font Size=2 color=black>Observação</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=green>Efetuar Backup do SX3</Font>', '1', 90, 5, 'L'}})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define colunas da tabela...                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColunas := {}
	aAdd( aColunas, {'Dicionário'				, 10	, 'C'})
	aAdd( aColunas, {'Chave'					, 20	, 'C'})
	aAdd( aColunas, {'Recno'					, 10	, 'C'})
	aAdd( aColunas, {'Descrição'				, 40	, 'C'})

	cMensagem += U_BeHtmHead( '', .T., aColunas, aCabec )

	For nDiv := 1 To Len(aDivergencia)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime linha de detalhes da tabela...                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aColunas := {}
		aAdd( aColunas, {AllTrim(aDivergencia[nDiv][1])						, 10	, 'C'})
		aAdd( aColunas, {AllTrim(aDivergencia[nDiv][2])						, 20	, 'L'})
		aAdd( aColunas, {Transform(aDivergencia[nDiv][3], "@E 999,999,999")	, 10	, 'R'})
		aAdd( aColunas, {AllTrim(aDivergencia[nDiv][4])						, 40	, 'L'})
	
		If Len( cMensagem ) < 1005572 // O máximo é 1048572
			cMensagem += U_BeHtmDet( aColunas, .T., .F. )
		EndIf
	Next
	
	cMensagem += U_BeHtmRod(.T.)
	
	cAssunto := "EQAceOrd - Acertar Ordem do Dicionário das Tabelas: SA1, SB1, SD1, SD2, SE1, SF4, SFT - Empresa: " + cEmpAnt + ' / ' + AllTrim(SM0->M0_NOME)
	cDestino := AllTrim( "fabio@xisinformatica.com.br;francisco.assis@euroamerican.com.br;fabio.batista@euroamerican.com.br" )
	
	/*==================================================================================|
	|Envia email.                                                                       |
	|==================================================================================*/
	CONNECT SMTP SERVER _cServer ACCOUNT _cAccount PASSWORD _cPassword Result _lConect
	If _lConect
		SEND MAIL FROM _cEnvia TO cDestino SUBJECT cAssunto BODY cMensagem RESULT _lEnviado
	Else
		_lEnviado := .f.
	EndIf
	DISCONNECT SMTP SERVER Result _lDisConec
EndIf

Alert('Processamento encerrado, favor executar em todas as empresas')

Return