#Include 'Protheus.Ch'
#Include 'Totvs.Ch'
#Include 'TopConn.Ch'

User Function EQApuZ83()

Local cTitulo    := "Gerar Apuração da Digitação das Fichas do Inventário"

Private nOpcao   := 0
Private lValido  := .T.
Private aButtons := {}
Private aSays    := {}
Private aArea    := GetArea()
Private cPerg    := "EQINVMONZZ"
Private cQuery   := ""
Private cTipoPrd := "'MP','ME','EM','PA','PI','BN','SP','PP','KT'"
Private aTipoPrd := {}
Private nTipoPrd := 0

Pergunte(cPerg, .F.)

aAdd(aSays,OemToAnsi("Esta rotina tem como objetivo apurar as contagens das fichas de inventário digitadas no"))
aAdd(aSays,OemToAnsi("período, antes da apuração, validações serão consideradas."))
aAdd(aSays,OemToAnsi("A apuração somente irá ser gerada se não houver pendências e incidências de erros."))
aAdd(aSays,OemToAnsi("Clique no botão OK para processar a Apuração."))

aAdd( aButtons, { 1,.T.,{|o| nOpcao:= 1,o:oWnd:End()} } )
aAdd( aButtons, { 2,.T.,{|o| nOpcao:= 2,o:oWnd:End()} } )
aAdd( aButtons, { 5,.T.,{| | Pergunte(cPerg,.T.)  } } )
FormBatch( cTitulo, aSays, aButtons,,200,530 )

If nOpcao == 1
	If AllTrim( cEmpAnt ) + AllTrim( cFilAnt ) $ "0107|0200|0803|0901"
		dbSelectArea("Z86")
		dbSetOrder(1)
		dbGoTop()
		Do Case
			Case AllTrim( cEmpAnt ) + AllTrim( cFilAnt ) == "0107"
				If AllTrim( Z86->Z86_0107 ) <> "S"
					lValido := .F.
					Help( ,, "EQDIGVLEMP",, "Empresa ou filial não habilitada para contagem do inventário, Verifique!", 1, 0 )
				EndIf
			Case AllTrim( cEmpAnt ) + AllTrim( cFilAnt ) == "0200"
				If AllTrim( Z86->Z86_0200 ) <> "S"
					lValido := .F.
					Help( ,, "EQDIGVLEMP",, "Empresa ou filial não habilitada para contagem do inventário, Verifique!", 1, 0 )
				EndIf
			Case AllTrim( cEmpAnt ) + AllTrim( cFilAnt ) == "0803"
				If AllTrim( Z86->Z86_0803 ) <> "S"
					lValido := .F.
					Help( ,, "EQDIGVLEMP",, "Empresa ou filial não habilitada para contagem do inventário, Verifique!", 1, 0 )
				EndIf
			Case AllTrim( cEmpAnt ) + AllTrim( cFilAnt ) == "0901"
				If AllTrim( Z86->Z86_0901 ) <> "S"
					lValido := .F.
					Help( ,, "EQDIGVLEMP",, "Empresa ou filial não habilitada para contagem do inventário, Verifique!", 1, 0 )
				EndIf
		EndCase
	Else
		lValido := .F.
		Help( ,, "EQDIGVLEMP",, "Empresa ou filial inválida para contagem do inventário, Verifique!", 1, 0 )
	EndIf
	
	If lValido
		If Z86->Z86_AF
			aAdd( aTipoPrd, {"'AF'"})
		EndIf
		If Z86->Z86_AI
			aAdd( aTipoPrd, {"'AI'"})
		EndIf
		If Z86->Z86_BN
			aAdd( aTipoPrd, {"'BN'"})
		EndIf
		If Z86->Z86_EM
			aAdd( aTipoPrd, {"'EM'"})
		EndIf
		If Z86->Z86_GG
			aAdd( aTipoPrd, {"'GG'"})
		EndIf
		If Z86->Z86_GN
			aAdd( aTipoPrd, {"'GN'"})
		EndIf
		If Z86->Z86_KT
			aAdd( aTipoPrd, {"'KT'"})
		EndIf
		If Z86->Z86_MC
			aAdd( aTipoPrd, {"'MC'"})
		EndIf
		If Z86->Z86_MD
			aAdd( aTipoPrd, {"'MD'"})
		EndIf
		If Z86->Z86_ME
			aAdd( aTipoPrd, {"'ME'"})
		EndIf
		If Z86->Z86_MO
			aAdd( aTipoPrd, {"'MO'"})
		EndIf
		If Z86->Z86_MP
			aAdd( aTipoPrd, {"'MP'"})
		EndIf
		If Z86->Z86_MS
			aAdd( aTipoPrd, {"'MS'"})
		EndIf
		If Z86->Z86_OI
			aAdd( aTipoPrd, {"'OI'"})
		EndIf
		If Z86->Z86_PA
			aAdd( aTipoPrd, {"'PA'"})
		EndIf
		If Z86->Z86_PC
			aAdd( aTipoPrd, {"'PC'"})
		EndIf
		If Z86->Z86_PI
			aAdd( aTipoPrd, {"'PI'"})
		EndIf
		If Z86->Z86_PP
			aAdd( aTipoPrd, {"'PP'"})
		EndIf
		If Z86->Z86_PR
			aAdd( aTipoPrd, {"'PR'"})
		EndIf
		If Z86->Z86_PV
			aAdd( aTipoPrd, {"'PV'"})
		EndIf
		If Z86->Z86_SP
			aAdd( aTipoPrd, {"'SP'"})
		EndIf
		If Z86->Z86_SV
			aAdd( aTipoPrd, {"'SV'"})
		EndIf
	EndIf

	If Len( aTipoPrd ) > 0
		cTipoPrd := ""
		For nTipoPrd := 1 To Len( aTipoPrd )
			If nTipoPrd == Len( aTipoPrd )
				cTipoPrd += AllTrim( aTipoPrd[nTipoPrd][01] )
			Else
				cTipoPrd += AllTrim( aTipoPrd[nTipoPrd][01] ) + ","
			EndIf
		Next
	EndIf

	If lValido
		Processa({|| fApurar()},"Aguarde a apuração das contagens de inventário...")
	EndIf
EndIf

RestArea( aArea )

Return

Static Function fApurar()

Local cStatus := "1"
Local lErro   := .F.
Local cMens1  := ""
Local cMens2  := ""

dbSelectArea("Z83")
dbSetOrder(1)
dbGoTop()

cQuery := "SELECT COUNT(*) AS CONTA " + CRLF
cQuery += "FROM " + RetSqlName("Z83") + " AS Z83 WITH (NOLOCK) " + CRLF
cQuery += "WHERE Z83_FILIAL = '" + xFilial("Z83") + "' " + CRLF
cQuery += "AND Z83_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
cQuery += "AND Z83_STATUS = '3' " + CRLF
cQuery += "AND Z83.D_E_L_E_T_ = ' ' " + CRLF

TCQuery cQuery New Alias "TMPFEITO"
dbSelectArea("TMPFEITO")
dbGoTop()

If !TMPFEITO->( Eof() ) .And. TMPFEITO->CONTA <> 0
	ApMsgAlert( "Período informado para apuração já inventariada, não é possível gerar apuração!", "Atenção" )
	TMPFEITO->( dbCloseArea() )
	Return
EndIf

TMPFEITO->( dbCloseArea() )

// Eliminar apurações anteriores para reprocessamentos...
cQuery := "UPDATE " + RetSqlName("Z83") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ " + CRLF
cQuery += "WHERE Z83_FILIAL = '" + xFilial("Z83") + "' " + CRLF
cQuery += "AND Z83_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
cQuery += "AND D_E_L_E_T_ = ' ' " + CRLF

TCSqlExec( cQuery )

// Selecionar digitações dos inventários para apuração - Query deve carregar os dados semi-apurados e agrupados para gravação...
cQuery := "SELECT MAX(Z82_GRUPO) AS Z82_GRUPO, MAX(Z80_EQUIPE) Z80_EQUIPE, Z82_FICHA, Z82_PRODUT, Z82_LOCAL, Z82_LOTECT, Z82_LOCALI, MAX(Z82_CONTAG) AS ULTCON, " + CRLF
cQuery += "       SUM(QTDCONT) AS QTDCONT, SUM(QTDCON1) AS QTDCON1, SUM(QTDCON2) AS QTDCON2, SUM(QTDCON3) AS QTDCON3 " + CRLF
cQuery += "FROM (" + CRLF
cQuery += "SELECT Z82_GRUPO, Z80_EQUIPE, Z82_FICHA, Z82_PRODUT, Z82_LOCAL, Z82_LOTECT, Z82_LOCALI, COUNT(*) AS QTDCONT, Z81_STATUS, " + CRLF
cQuery += "       Z82_CONTAG, MAX(Z82.R_E_C_N_O_) AS MAXREC, " + CRLF
cQuery += "	   CASE WHEN Z82_CONTAG = '1' THEN SUM(Z82_QUANT) ELSE 0 END AS QTDCON1, " + CRLF
cQuery += "	   CASE WHEN Z82_CONTAG = '2' THEN SUM(Z82_QUANT) ELSE 0 END AS QTDCON2, " + CRLF
cQuery += "	   CASE WHEN Z82_CONTAG = '3' THEN SUM(Z82_QUANT) ELSE 0 END AS QTDCON3 " + CRLF
cQuery += "FROM " + RetSqlName("Z81") + " AS Z81 " + CRLF
cQuery += "INNER JOIN " + RetSqlName("Z82") + " AS Z82 ON Z82_FILIAL = Z81_FILIAL " + CRLF
cQuery += "  AND Z82_CODIGO = Z81_CODIGO " + CRLF
cQuery += "  AND Z82_FICHA BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' " + CRLF
cQuery += "  AND Z82_PRODUT BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' " + CRLF
cQuery += "  AND Z82_LOCAL BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' " + CRLF
cQuery += "  AND Z82.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("Z80") + " AS Z80 WITH (NOLOCK) ON Z80_FILIAL = '" + xFilial("Z80") + "' " + CRLF
cQuery += "  AND Z80_CODIGO = Z82_GRUPO " + CRLF
cQuery += "  AND Z80_EQUIPE = Z82_EQUIPE " + CRLF
cQuery += "  AND Z80.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE Z81_FILIAL = '" + xFilial("Z81") + "' " + CRLF
cQuery += "AND Z81_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
cQuery += "AND Z81.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "GROUP BY Z82_GRUPO, Z80_EQUIPE, Z82_FICHA, Z82_PRODUT, Z82_LOCAL, Z82_LOTECT, Z82_LOCALI, Z82_CONTAG, Z81_STATUS " + CRLF
cQuery += ") AS AGRUPADO " + CRLF
cQuery += "GROUP BY Z82_FICHA, Z82_PRODUT, Z82_LOCAL, Z82_LOTECT, Z82_LOCALI, Z81_STATUS " + CRLF
cQuery += "ORDER BY MAX(MAXREC) DESC " + CRLF

TCQuery cQuery New Alias "TMPAPU"
dbSelectArea("TMPAPU")
dbGoTop()

ProcRegua( TMPAPU->( RecCount() ) )

Do While !TMPAPU->( Eof() )
	IncProc( "Apurando Ficha: " + AllTrim( TMPAPU->Z82_FICHA ) + "-" + AllTrim( TMPAPU->Z82_PRODUT ) + "-" + AllTrim( TMPAPU->Z82_LOCAL ) )

	cStatus := "1"
	cMens1  := ""
	cMens2  := ""
	nQuant  := 0

	If TMPAPU->QTDCONT < 2
		cStatus := "2"
		lErro   := .T.
		cMens1  := "Há Fichas faltando contagens"
		nQuant  := 0
	ElseIf TMPAPU->QTDCONT == 2
		If TMPAPU->QTDCON1 <> TMPAPU->QTDCON2
			cStatus := "2"
			lErro   := .T.
			cMens2  := "Há Fichas com Terceira Contagem Faltando"
			nQuant  := 0
		Else
			nQuant := TMPAPU->QTDCON1
		EndIf
	Else
		nQuant := TMPAPU->QTDCON3
	EndIf

	cEndereco := "" //AllTrim( Replace( Replace( Replace( TMPAPU->Z82_LOCALI, "-",""), ".",""), "*","") )

	If AllTrim( cEmpAnt ) == "08"
		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->( dbSeek( xFilial("SB1") + TMPAPU->Z82_PRODUT ) )
			If AllTrim( SB1->B1_LOCALIZ ) == "S"
				cEndereco := AllTrim( Replace( Replace( Replace( TMPAPU->Z82_LOCALI, "-",""), ".",""), "*","") )

				dbSelectArea("SBE")
				dbSetOrder(1)
				If !SBE->( dbSeek( xFilial("SBE") + TMPAPU->Z82_LOCAL + cEndereco ) )
					If AllTrim( TMPAPU->Z82_LOCAL ) == "08"
						cEndere := "Q01P00000"
					ElseIf AllTrim( TMPAPU->Z82_LOCAL ) == "07"
						cEndere := "Q03P00000"
					ElseIf AllTrim( TMPAPU->Z82_LOCAL ) == "06"
						cEndere := "Q03P00000"
					Else
						cEndere := "Q03P00000"
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	RecLock("Z83", .T.)
	      Z83->Z83_FILIAL := xFilial("Z83")
	      Z83->Z83_DATA   := mv_par02
	      Z83->Z83_STATUS := cStatus
	      Z83->Z83_PRODUT := TMPAPU->Z82_PRODUT
	      Z83->Z83_LOCAL  := TMPAPU->Z82_LOCAL
	      Z83->Z83_LOTECT := TMPAPU->Z82_LOTECT
	      Z83->Z83_LOCALI := cEndereco
	      Z83->Z83_FICHA  := TMPAPU->Z82_FICHA
	      Z83->Z83_QTDCON := TMPAPU->QTDCONT
	      Z83->Z83_QUANTI := nQuant
	      Z83->Z83_GRUPO  := TMPAPU->Z82_GRUPO
	      Z83->Z83_EQUIPE := TMPAPU->Z80_EQUIPE
	      Z83->Z83_HIST   := AllTrim( cMens1 + " " + cMens2 )
	MsUnLock()

	TMPAPU->( dbSkip() )
EndDo

TMPAPU->( dbCloseArea() )

If lErro // Havendo sequer um erro, não permitir geração do SB7 e solicitar ações para acertos nas contagens...
	cQuery := "UPDATE " + RetSqlName("Z81") + " SET Z81_STATUS = '2' " + CRLF
	cQuery += "FROM " + RetSqlName("Z81") + " AS Z81 " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("Z82") + " AS Z82 ON Z82_FILIAL = Z81_FILIAL " + CRLF
	cQuery += "  AND Z82_CODIGO = Z81_CODIGO " + CRLF
	cQuery += "  AND Z82_FICHA BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' " + CRLF
	cQuery += "  AND Z82_PRODUT BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' " + CRLF
	cQuery += "  AND Z82_LOCAL BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' " + CRLF
	cQuery += "  AND Z82.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE Z81_FILIAL = '" + xFilial("Z81") + "' " + CRLF
	cQuery += "AND Z81_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
	cQuery += "AND Z81_STATUS <> '3' " + CRLF
	cQuery += "AND Z81.D_E_L_E_T_ = ' ' " + CRLF

	TCSqlExec( cQuery )

	ApMsgAlert( "A apuração identificou divergências nas contagens, verifique o históricos dos erros nas contagens para correção e nova apuração!", "Atenção" )
Else // Liberar digitações e apuração para inventário...
	cQuery := "UPDATE " + RetSqlName("Z81") + " SET Z81_STATUS = '3' " + CRLF
	cQuery += "FROM " + RetSqlName("Z81") + " AS Z81 " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("Z82") + " AS Z82 ON Z82_FILIAL = Z81_FILIAL " + CRLF
	cQuery += "  AND Z82_CODIGO = Z81_CODIGO " + CRLF
	cQuery += "  AND Z82_FICHA BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' " + CRLF
	cQuery += "  AND Z82_PRODUT BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' " + CRLF
	cQuery += "  AND Z82_LOCAL BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' " + CRLF
	cQuery += "  AND Z82.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE Z81_FILIAL = '" + xFilial("Z81") + "' " + CRLF
	cQuery += "AND Z81_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
	cQuery += "AND Z81_STATUS <> '3' " + CRLF
	cQuery += "AND Z81.D_E_L_E_T_ = ' ' " + CRLF

	TCSqlExec( cQuery )

	Processa({|| fZerar()},"Zerar saldos não inventariados para apuração...")

	ApMsgInfo( "Apuração das contagens concluída com sucesso, processo liberado para gerar Inventário SB7!", "Gerar SB7")
EndIf

Return

Static Function fZerar()

cQuery := "SELECT B2_COD, B2_LOCAL, '' AS B2_LOTECTL, '' AS B2_ENDERE, B2_QATU, " + CRLF
cQuery += "       CASE WHEN B1_RASTRO = 'N' THEN 'Não Controla' ELSE 'Controla Lote' END AS RASTRO, " + CRLF
cQuery += "	      CASE WHEN B1_LOCALIZ = 'N' THEN 'Não' ELSE 'Sim' END AS ENDERECO, " + CRLF
cQuery += "	      CASE WHEN B1_MSBLQL = '1' THEN 'Sim' ELSE 'Não' END AS BLOQ " + CRLF
cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
cQuery += "  AND B1_COD = B2_COD " + CRLF
//cQuery += "  AND B1_TIPO IN ('MP','ME','EM','PA','PI','BN','SP','PP') " + CRLF
cQuery += "  AND B1_TIPO IN (" + AllTrim( cTipoPrd ) + ") " + CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " AS SBZ ON BZ_FILIAL = B2_FILIAL " + CRLF
cQuery += "  AND BZ_COD = B2_COD " + CRLF
cQuery += "  AND SBZ.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
cQuery += "AND B2_COD BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' " + CRLF
cQuery += "AND B2_LOCAL BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' " + CRLF
cQuery += "AND B2_LOCAL IN ('02','04','08') " + CRLF
cQuery += "AND B2_QATU <> 0 " + CRLF
cQuery += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("Z82") + " AS Z82 INNER JOIN " + RetSqlName("Z81") + " AS Z81 ON Z81_FILIAL = Z82_FILIAL AND Z81_CODIGO = Z82_CODIGO AND Z81_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' AND Z81.D_E_L_E_T_ = ' ' WHERE Z82_FILIAL = B2_FILIAL AND Z82_PRODUT = B2_COD AND Z82_LOCAL = B2_LOCAL AND Z82.D_E_L_E_T_ = ' ') " + CRLF
cQuery += "AND NOT EXISTS (SELECT Z85_FILIAL FROM " + RetSqlName("Z85") + " WITH (NOLOCK) WHERE Z85_FILIAL = B2_FILIAL AND Z85_PRODUT = B2_COD AND D_E_L_E_T_ = ' ') " + CRLF
cQuery += "AND B1_RASTRO = 'N' " + CRLF
cQuery += "AND ((BZ_LOCALIZ IS NULL AND B1_LOCALIZ = 'N') OR (BZ_LOCALIZ = 'N')) " + CRLF
cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "UNION ALL " + CRLF
cQuery += "SELECT B8_PRODUTO, B8_LOCAL, B8_LOTECTL, '' AS B2_ENDERE, B8_SALDO, " + CRLF
cQuery += "       CASE WHEN B1_RASTRO = 'N' THEN 'Não Controla' ELSE 'Controla Lote' END AS RASTRO, " + CRLF
cQuery += "	      CASE WHEN B1_LOCALIZ = 'N' THEN 'Não' ELSE 'Sim' END AS ENDERECO, " + CRLF
cQuery += "	      CASE WHEN B1_MSBLQL = '1' THEN 'Sim' ELSE 'Não' END AS BLOQ " + CRLF
cQuery += "FROM " + RetSqlName("SB8") + " AS SB8 " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
cQuery += "  AND B1_COD = B8_PRODUTO " + CRLF
//cQuery += "  AND B1_TIPO IN ('MP','ME','EM','PA','PI','BN','SP','PP') " + CRLF
cQuery += "  AND B1_TIPO IN (" + AllTrim( cTipoPrd ) + ") " + CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " AS SBZ ON BZ_FILIAL = B8_FILIAL " + CRLF
cQuery += "  AND BZ_COD = B8_PRODUTO " + CRLF
cQuery += "  AND SBZ.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE B8_FILIAL = '" + xFilial("SB8") + "' " + CRLF
cQuery += "AND B8_PRODUTO BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' " + CRLF
cQuery += "AND B8_LOCAL BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' " + CRLF
cQuery += "AND B8_LOCAL IN ('02','04','08') " + CRLF
cQuery += "AND B8_SALDO <> 0 " + CRLF
cQuery += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("Z82") + " AS Z82 INNER JOIN " + RetSqlName("Z81") + " AS Z81 ON Z81_FILIAL = Z82_FILIAL AND Z81_CODIGO = Z82_CODIGO AND Z81_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' AND Z81.D_E_L_E_T_ = ' ' WHERE Z82_FILIAL = B8_FILIAL AND Z82_PRODUT = B8_PRODUTO AND Z82_LOCAL = B8_LOCAL AND Z82.D_E_L_E_T_ = ' ') " + CRLF
cQuery += "AND NOT EXISTS (SELECT Z85_FILIAL FROM " + RetSqlName("Z85") + " WITH (NOLOCK) WHERE Z85_FILIAL = B8_FILIAL AND Z85_PRODUT = B8_PRODUTO AND D_E_L_E_T_ = ' ') " + CRLF
cQuery += "AND B1_RASTRO <> 'N' " + CRLF
cQuery += "AND ((BZ_LOCALIZ IS NULL AND B1_LOCALIZ = 'N') OR (BZ_LOCALIZ = 'N')) " + CRLF
cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "UNION ALL " + CRLF
cQuery += "SELECT BF_PRODUTO, BF_LOCAL, BF_LOTECTL, BF_LOCALIZ, BF_QUANT, " + CRLF
cQuery += "       CASE WHEN B1_RASTRO = 'N' THEN 'Não Controla' ELSE 'Controla Lote' END AS RASTRO, " + CRLF
cQuery += "	      CASE WHEN B1_LOCALIZ = 'N' THEN 'Não' ELSE 'Sim' END AS ENDERECO, " + CRLF
cQuery += "	      CASE WHEN B1_MSBLQL = '1' THEN 'Sim' ELSE 'Não' END AS BLOQ " + CRLF
cQuery += "FROM " + RetSqlName("SBF") + " AS SBF " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
cQuery += "  AND B1_COD = BF_PRODUTO " + CRLF
//cQuery += "  AND B1_TIPO IN ('MP','ME','EM','PA','PI','BN','SP','PP') " + CRLF
cQuery += "  AND B1_TIPO IN (" + AllTrim( cTipoPrd ) + ") " + CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " AS SBZ ON BZ_FILIAL = BF_FILIAL " + CRLF
cQuery += "  AND BZ_COD = BF_PRODUTO " + CRLF
cQuery += "  AND SBZ.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE BF_FILIAL = '" + xFilial("SBF") + "' " + CRLF
cQuery += "AND BF_PRODUTO BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' " + CRLF
cQuery += "AND BF_LOCAL BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' " + CRLF
cQuery += "AND BF_LOCAL = '08' " + CRLF
cQuery += "AND BF_QUANT <> 0 " + CRLF
cQuery += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("Z82") + " AS Z82 INNER JOIN " + RetSqlName("Z81") + " AS Z81 ON Z81_FILIAL = Z82_FILIAL AND Z81_CODIGO = Z82_CODIGO AND Z81_DATA BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' AND Z81.D_E_L_E_T_ = ' ' WHERE Z82_FILIAL = BF_FILIAL AND Z82_PRODUT = BF_PRODUTO AND Z82_LOCAL = BF_LOCAL AND Z82.D_E_L_E_T_ = ' ') " + CRLF
cQuery += "AND NOT EXISTS (SELECT Z85_FILIAL FROM " + RetSqlName("Z85") + " WITH (NOLOCK) WHERE Z85_FILIAL = BF_FILIAL AND Z85_PRODUT = BF_PRODUTO AND D_E_L_E_T_ = ' ') " + CRLF
cQuery += "AND ((BZ_LOCALIZ IS NULL AND B1_LOCALIZ = 'S') OR (BZ_LOCALIZ = 'S')) " + CRLF
cQuery += "AND SBF.D_E_L_E_T_ = ' ' " + CRLF

TCQuery cQuery New Alias "TMPZERA"
dbSelectArea("TMPZERA")
dbGoTop()

ProcRegua( TMPZERA->( RecCount() ) )

Do While !TMPZERA->( Eof() )
	IncProc( "Zerar: " + AllTrim( TMPZERA->B2_COD ) + "-" + AllTrim( TMPZERA->B2_LOCAL ) )

	RecLock("Z83", .T.)
	      Z83->Z83_FILIAL := xFilial("Z83")
	      Z83->Z83_DATA   := mv_par02
	      Z83->Z83_STATUS := "1"
	      Z83->Z83_PRODUT := TMPZERA->B2_COD
	      Z83->Z83_LOCAL  := TMPZERA->B2_LOCAL
	      Z83->Z83_LOTECT := TMPZERA->B2_LOTECTL
	      Z83->Z83_LOCALI := TMPZERA->B2_ENDERE
	      Z83->Z83_FICHA  := "999999" // Ficha fixa para identificar que se trata de contagem para zerar saldo...
	      Z83->Z83_QTDCON := 2
	      Z83->Z83_QUANTI := 0
	      Z83->Z83_GRUPO  := ""
	      Z83->Z83_EQUIPE := ""
	      Z83->Z83_HIST   := ""
	MsUnLock()

	TMPZERA->( dbSkip() )
EndDo

TMPZERA->( dbCloseArea() )

Return
