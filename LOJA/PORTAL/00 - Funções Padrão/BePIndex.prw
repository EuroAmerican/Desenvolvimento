#Include 'Protheus.Ch'
#Include 'Rwmake.Ch'
#Include 'ApWebex.Ch'
#Include 'TbiConn.Ch'
#Include 'TopConn.Ch'

// Programa da tela principal do portal
User Function BePIndex()

Local lSession 	:= Execblock("BePVSess",.F.,.F.) // Valida Sessão

Local cMsgHdr	 := ""
Local cMsgBody	 := ""
Local cRetfun	 := "u_BePLogin.apw"
Local cAlias	 := ""
//Local cFilFil    := "'  ','00','01','02','03','04','05','06','07','08'"
Local cAnoAtu    := StrZero( Year( MsDate() )   , 4)
Local cAnoAnt    := StrZero( Year( MsDate() ) -1, 4)
Local cAnoAn2    := StrZero( Year( MsDate() ) -2, 4)
Local aAno       := {}
Local aSts       := {}
Local aAnoAnt	 := {}
Local aAnoAtu	 := {}
Local aAprova    := {}
Local aCCDesc    := {}
Local aCCVal     := {}
Local aCC        := {}
Local nCC        := {}
Local aDesp      := {}
Local aReem      := {}
Local aAnis      := {}
Local aCred      := {}
Local aTota      := {}
Local aNome      := {}
Local aClasse    := {}
Local aDep       := {}
Local nNom       := 0
Local nAno       := 0
Local nSts       := 0
Local nClasse    := 0
Local nPosAno    := 0
Local nDep       := 0
Local nFil01     := 0
Local nFil02     := 0
Local nVlrPen    := 0
Local nQtdPenPC  := 0
Local nQtdPenNF  := 0
Local nQtdPenCP  := 0
Local nQtdPenAE  := 0
Local nQtdRep    := 0
Local nNaoEnt    := 0
Local nAprovado  := 0
Local nReprovado := 0
Local nPendente  := 0
Local nTotal     := 0
Local nDesPen    := 0
Local nCrePen    := 0
Local nReePen    := 0
Local nAniPen    := 0
Local nSeuFat    := 0
Local nSeuDes    := 0
Local nSeuDep    := 0
Local nSeuRee    := 0
Local lApvComp   := .T.
Local lApvCart   := .F.
Local lColabor   := .F.
Local cEnvServer := AllTrim( Upper( GetEnvServer() ) )

Private cHtml    := ""

WEB EXTENDED INIT cHtml

cHtml += Execblock("BePHeader",.F.,.F.)

If lSession
	cAlias := GetNextAlias()
	
	If Select(cAlias) <> 0
		(cAlias)->( dbCloseArea() )
	EndIf
	
	cQuery := "SELECT COUNT(*) AS CONTA " + CRLF
	cQuery += "FROM " + RetSqlName("Z18") + " AS Z18 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE Z18_FILIAL = '" + xFilial("Z18") + "' " + CRLF
	cQuery += "AND Z18_CODUSR = '" + AllTrim( HttpSession->ccodusr ) + "' " + CRLF
	cQuery += "AND Z18_CODMOD = '02' " + CRLF
	cQuery += "AND Z18_DCOMPR = 'T' " + CRLF
	cQuery += "AND LTRIM(RTRIM(UPPER(Z18_ROTINA))) = LTRIM(RTRIM(UPPER('u_BeP0201.apw'))) " + CRLF
	cQuery += "AND Z18.D_E_L_E_T_ = ' ' " + CRLF

	TcQuery cQuery NEW ALIAS (cAlias)
	(cAlias)->( dbGoTop() )

	If !(cAlias)->( Eof() )
		If (cAlias)->CONTA > 0
			lApvComp := .T.
		Else
			lApvComp := .F.
		EndIf
	Else
		lApvComp := .F.
	EndIf

	(cAlias)->( dbCloseArea() )

	If lApvComp
		aAno := {}
		aAdd( aAno, { cAnoAn2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "#8191c9" })
		aAdd( aAno, { cAnoAnt, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "#3e95cd" })
		aAdd( aAno, { cAnoAtu, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "#ff0040" })

		If Select(cAlias) <> 0
			(cAlias)->( dbCloseArea() )
		EndIf
	
		cQuery := "SELECT SUM(CR_TOTAL) AS TOTAL " + CRLF
		cQuery += "FROM ( " + CRLF
		cQuery += "SELECT CR_FILIAL, CR_NUM, CR_TOTAL " + CRLF
		cQuery += "FROM " + RetSqlName("SCR") + " AS SCR WITH (NOLOCK) " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) ON C7_FILIAL = CR_FILIAL " + CRLF
		cQuery += "  AND C7_NUM = CR_NUM " + CRLF
		cQuery += "  AND C7_ENCER <> 'E' " + CRLF
		cQuery += "  AND C7_RESIDUO <> 'S' " + CRLF
		cQuery += "  AND SC7.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SAL") + " AS SAL WITH (NOLOCK) ON AL_FILIAL = '" + xFilial("SAL") + "' " + CRLF
		cQuery += "  AND AL_COD = C7_APROV " + CRLF
		cQuery += "  AND AL_APROV = CR_APROV " + CRLF
		cQuery += "  AND AL_USER = CR_USER " + CRLF
		cQuery += "  AND SAL.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SAK") + " AS SAK WITH (NOLOCK) ON AK_FILIAL = '" + xFilial("SAK") + "' " + CRLF
		cQuery += "  AND AK_COD = AL_APROV " + CRLF
		cQuery += "  AND AK_USER = AL_USER " + CRLF
		cQuery += "  AND SAK.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "WHERE CR_FILIAL <> '**' " + CRLF
		cQuery += "AND CR_TIPO = 'PC' " + CRLF
		cQuery += "AND CR_USER = '" + AllTrim( HttpSession->ccodusr ) + "' " + CRLF
		cQuery += "AND CR_STATUS = '02' " + CRLF
		cQuery += "AND SCR.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "GROUP BY CR_FILIAL, CR_NUM, CR_TOTAL " + CRLF
		cQuery += ") AS AGRUPADO " + CRLF
	
		TcQuery cQuery NEW ALIAS (cAlias)
		(cAlias)->( dbGoTop() )
	
		If !(cAlias)->( Eof() )
			nVlrPen := (cAlias)->TOTAL
		EndIf
	
		(cAlias)->( dbCloseArea() )
	
		cQuery := "SELECT COUNT(*) AS TOTAL " + CRLF
		cQuery += "FROM ( " + CRLF
		cQuery += "SELECT CR_FILIAL, CR_NUM, CR_TOTAL " + CRLF
		cQuery += "FROM " + RetSqlName("SCR") + " AS SCR WITH (NOLOCK) " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) ON C7_FILIAL = CR_FILIAL " + CRLF
		cQuery += "  AND C7_NUM = CR_NUM " + CRLF
		cQuery += "  AND C7_TIPO = 1 " + CRLF
		cQuery += "  AND C7_ENCER <> 'E' " + CRLF
		cQuery += "  AND C7_RESIDUO <> 'S' " + CRLF
		cQuery += "  AND SC7.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SAL") + " AS SAL WITH (NOLOCK) ON AL_FILIAL = '" + xFilial("SAL") + "' " + CRLF
		cQuery += "  AND AL_COD = C7_APROV " + CRLF
		cQuery += "  AND AL_APROV = CR_APROV " + CRLF
		cQuery += "  AND AL_USER = CR_USER " + CRLF
		cQuery += "  AND SAL.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SAK") + " AS SAK WITH (NOLOCK) ON AK_FILIAL = '" + xFilial("SAK") + "' " + CRLF
		cQuery += "  AND AK_COD = AL_APROV " + CRLF
		cQuery += "  AND AK_USER = AL_USER " + CRLF
		cQuery += "  AND SAK.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "WHERE CR_FILIAL <> '**' " //IN (" + cFilFil + ") " + CRLF
		cQuery += "AND CR_TIPO = 'PC' " + CRLF
		cQuery += "AND CR_STATUS = '02' " + CRLF
		cQuery += "AND CR_USER = '" + AllTrim( HttpSession->ccodusr ) + "' " + CRLF
		cQuery += "AND SCR.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "GROUP BY CR_FILIAL, CR_NUM, CR_TOTAL " + CRLF
		cQuery += ") AS AGRUPADO " + CRLF
	
		TcQuery cQuery NEW ALIAS (cAlias)
		(cAlias)->( dbGoTop() )
	
		If !(cAlias)->( Eof() )
			nQtdPenPC := (cAlias)->TOTAL
		EndIf
		
		(cAlias)->( dbCloseArea() )
	
		cQuery := "SELECT COUNT(*) AS TOTAL " + CRLF
		cQuery += "FROM ( " + CRLF
		cQuery += "SELECT CR_FILIAL, CR_NUM, CR_TOTAL " + CRLF
		cQuery += "FROM " + RetSqlName("SCR") + " AS SCR WITH (NOLOCK) " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) ON C7_FILIAL = CR_FILIAL " + CRLF
		cQuery += "  AND C7_NUM = CR_NUM " + CRLF
		cQuery += "  AND C7_TIPO = 2 " + CRLF
		cQuery += "  AND C7_ENCER <> 'E' " + CRLF
		cQuery += "  AND C7_RESIDUO <> 'S' " + CRLF
		cQuery += "  AND SC7.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SAL") + " AS SAL WITH (NOLOCK) ON AL_FILIAL = '" + xFilial("SAL") + "' " + CRLF
		cQuery += "  AND AL_COD = C7_APROV " + CRLF
		cQuery += "  AND AL_APROV = CR_APROV " + CRLF
		cQuery += "  AND AL_USER = CR_USER " + CRLF
		cQuery += "  AND SAL.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SAK") + " AS SAK WITH (NOLOCK) ON AK_FILIAL = '" + xFilial("SAK") + "' " + CRLF
		cQuery += "  AND AK_COD = AL_APROV " + CRLF
		cQuery += "  AND AK_USER = AL_USER " + CRLF
		cQuery += "  AND SAK.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "WHERE CR_FILIAL <> '**' " + CRLF
		cQuery += "AND CR_TIPO = 'AE' " + CRLF
		cQuery += "AND CR_STATUS = '02' " + CRLF
		cQuery += "AND CR_USER = '" + AllTrim( HttpSession->ccodusr ) + "' " + CRLF
		cQuery += "AND SCR.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "GROUP BY CR_FILIAL, CR_NUM, CR_TOTAL " + CRLF
		cQuery += ") AS AGRUPADO " + CRLF
	
		TcQuery cQuery NEW ALIAS (cAlias)
		(cAlias)->( dbGoTop() )
	
		If !(cAlias)->( Eof() )
			nQtdPenAE := (cAlias)->TOTAL
		EndIf
		
		(cAlias)->( dbCloseArea() )
	
		cQuery := "SELECT COUNT(*) AS TOTAL " + CRLF
		cQuery += "FROM ( " + CRLF
		cQuery += "SELECT CR_FILIAL, CR_NUM, CR_TOTAL " + CRLF
		cQuery += "FROM " + RetSqlName("SCR") + " AS SCR WITH (NOLOCK) " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SC3") + " AS SC3 WITH (NOLOCK) ON C3_FILIAL = CR_FILIAL " + CRLF
		cQuery += "  AND C3_NUM = CR_NUM " + CRLF
		cQuery += "  AND C3_ENCER <> 'E' " + CRLF
		cQuery += "  AND C3_RESIDUO <> 'S' " + CRLF
		cQuery += "  AND SC3.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SAL") + " AS SAL WITH (NOLOCK) ON AL_FILIAL = '" + xFilial("SAL") + "' " + CRLF
		cQuery += "  AND AL_COD = C3_APROV " + CRLF
		cQuery += "  AND AL_APROV = CR_APROV " + CRLF
		cQuery += "  AND AL_USER = CR_USER " + CRLF
		cQuery += "  AND SAL.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SAK") + " AS SAK WITH (NOLOCK) ON AK_FILIAL = '" + xFilial("SAK") + "' " + CRLF
		cQuery += "  AND AK_COD = AL_APROV " + CRLF
		cQuery += "  AND AK_USER = AL_USER " + CRLF
		cQuery += "  AND SAK.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "WHERE CR_FILIAL <> '**' " + CRLF
		cQuery += "AND CR_TIPO = 'CP' " + CRLF
		cQuery += "AND CR_STATUS = '02' " + CRLF
		cQuery += "AND CR_USER = '" + AllTrim( HttpSession->ccodusr ) + "' " + CRLF
		cQuery += "AND SCR.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "GROUP BY CR_FILIAL, CR_NUM, CR_TOTAL " + CRLF
		cQuery += ") AS AGRUPADO " + CRLF
	
		TcQuery cQuery NEW ALIAS (cAlias)
		(cAlias)->( dbGoTop() )
	
		If !(cAlias)->( Eof() )
			nQtdPenCP := (cAlias)->TOTAL
		EndIf
		
		(cAlias)->( dbCloseArea() )
	
		cQuery := "SELECT COUNT(*) AS TOTAL " + CRLF
		cQuery += "FROM ( " + CRLF
		cQuery += "SELECT CR_FILIAL, CR_NUM, CR_TOTAL " + CRLF
		cQuery += "FROM " + RetSqlName("SCR") + " AS SCR WITH (NOLOCK) " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SF1") + " AS SF1 WITH (NOLOCK) ON F1_FILIAL = CR_FILIAL " + CRLF
		cQuery += "  AND F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA = CR_NUM " + CRLF
		cQuery += "  AND SF1.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SAL") + " AS SAL WITH (NOLOCK) ON AL_FILIAL = '" + xFilial("SAL") + "' " + CRLF
		cQuery += "  AND AL_COD = '" + GetMv("MV_NFAPROV",,"000002") + "' " + CRLF
		cQuery += "  AND AL_APROV = CR_APROV " + CRLF
		cQuery += "  AND AL_USER = CR_USER " + CRLF
		cQuery += "  AND SAL.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SAK") + " AS SAK WITH (NOLOCK) ON AK_FILIAL = '" + xFilial("SAK") + "' " + CRLF
		cQuery += "  AND AK_COD = AL_APROV " + CRLF
		cQuery += "  AND AK_USER = AL_USER " + CRLF
		cQuery += "  AND SAK.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "WHERE CR_FILIAL <> '**' " + CRLF
		cQuery += "AND CR_TIPO = 'NF' " + CRLF
		cQuery += "AND CR_STATUS = '02' " + CRLF
		cQuery += "AND CR_USER = '" + AllTrim( HttpSession->ccodusr ) + "' " + CRLF
		cQuery += "AND SCR.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "GROUP BY CR_FILIAL, CR_NUM, CR_TOTAL " + CRLF
		cQuery += ") AS AGRUPADO " + CRLF
	
		TcQuery cQuery NEW ALIAS (cAlias)
		(cAlias)->( dbGoTop() )
	
		If !(cAlias)->( Eof() )
			nQtdPenNF := (cAlias)->TOTAL
		EndIf
		
		(cAlias)->( dbCloseArea() )
	
		cQuery := "SELECT COUNT(*) AS TOTAL " + CRLF
		cQuery += "FROM ( " + CRLF
		cQuery += "SELECT CR_FILIAL, CR_NUM, CR_TOTAL " + CRLF
		cQuery += "FROM " + RetSqlName("SCR") + " AS SCR WITH (NOLOCK) " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) ON C7_FILIAL = CR_FILIAL " + CRLF
		cQuery += "  AND C7_NUM = CR_NUM " + CRLF
		cQuery += "  AND C7_ENCER <> 'E' " + CRLF
		cQuery += "  AND C7_RESIDUO <> 'S' " + CRLF
		cQuery += "  AND SC7.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SAL") + " AS SAL WITH (NOLOCK) ON AL_FILIAL = '" + xFilial("SAL") + "' " + CRLF
		cQuery += "  AND AL_COD = C7_APROV " + CRLF
		cQuery += "  AND AL_APROV = CR_APROV " + CRLF
		cQuery += "  AND AL_USER = CR_USER " + CRLF
		cQuery += "  AND SAL.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SAK") + " AS SAK WITH (NOLOCK) ON AK_FILIAL = '" + xFilial("SAK") + "' " + CRLF
		cQuery += "  AND AK_COD = AL_APROV " + CRLF
		cQuery += "  AND AK_USER = AL_USER " + CRLF
		cQuery += "  AND SAK.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "WHERE CR_FILIAL <> '**' " + CRLF
		cQuery += "AND CR_TIPO = 'PC' " + CRLF
		cQuery += "AND CR_STATUS = '04' " + CRLF
		cQuery += "AND CR_USER = '" + AllTrim( HttpSession->ccodusr ) + "' " + CRLF
		cQuery += "AND SCR.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "GROUP BY CR_FILIAL, CR_NUM, CR_TOTAL " + CRLF
		cQuery += ") AS AGRUPADO " + CRLF
	
		TcQuery cQuery NEW ALIAS (cAlias)
		(cAlias)->( dbGoTop() )
	
		If !(cAlias)->( Eof() )
			nQtdRep := (cAlias)->TOTAL
		EndIf
		
		(cAlias)->( dbCloseArea() )
	
		cQuery := "SELECT COUNT(*) AS TOTAL " + CRLF
		cQuery += "FROM ( " + CRLF
		cQuery += "SELECT C7_FILIAL, C7_NUM " + CRLF
		cQuery += "FROM " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) " + CRLF
		cQuery += "WHERE C7_FILIAL <> '**' " + CRLF
		cQuery += "AND C7_ENCER <> 'E' " + CRLF
		cQuery += "AND C7_QUANT > C7_QUJE " + CRLF
		cQuery += "AND C7_CONAPRO = 'L' " + CRLF
		cQuery += "AND C7_DATPRF < CONVERT(VARCHAR(8), GETDATE(), 112) " + CRLF
		cQuery += "AND C7_RESIDUO <> 'S' " + CRLF
		cQuery += "AND SC7.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "GROUP BY C7_FILIAL, C7_NUM " + CRLF
		cQuery += ") AS AGRUPADO " + CRLF
	
		TcQuery cQuery NEW ALIAS (cAlias)
		(cAlias)->( dbGoTop() )
	
		If !(cAlias)->( Eof() )
			nNaoEnt := (cAlias)->TOTAL
		EndIf
		
		(cAlias)->( dbCloseArea() )
	
		cQuery := "SELECT ANO, SUM(JANEIRO) AS JANEIRO, SUM(FEVEREIRO) AS FEVEREIRO, SUM(MARCO) AS MARCO, SUM(ABRIL) AS ABRIL, " + CRLF
		cQuery += "SUM(MAIO) AS MAIO, SUM(JUNHO) AS JUNHO, SUM(JULHO) AS JULHO, SUM(AGOSTO) AS AGOSTO, " + CRLF
		cQuery += "SUM(SETEMBRO) AS SETEMBRO, SUM(OUTUBRO) AS OUTUBRO, SUM(NOVEMBRO) AS NOVEMBRO, SUM(DEZEMBRO) AS DEZEMBRO, SUM(TOTAL) AS TOTAL " + CRLF
		cQuery += "FROM ( " + CRLF
		cQuery += "SELECT LEFT(C7_EMISSAO, 4) AS ANO, " + CRLF
		cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '01' THEN COUNT(*) ELSE 0 END AS JANEIRO, " + CRLF
		cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '02' THEN COUNT(*) ELSE 0 END AS FEVEREIRO, " + CRLF
		cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '03' THEN COUNT(*) ELSE 0 END AS MARCO, " + CRLF
		cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '04' THEN COUNT(*) ELSE 0 END AS ABRIL, " + CRLF
		cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '05' THEN COUNT(*) ELSE 0 END AS MAIO, " + CRLF
		cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '06' THEN COUNT(*) ELSE 0 END AS JUNHO, " + CRLF
		cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '07' THEN COUNT(*) ELSE 0 END AS JULHO, " + CRLF
		cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '08' THEN COUNT(*) ELSE 0 END AS AGOSTO, " + CRLF
		cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '09' THEN COUNT(*) ELSE 0 END AS SETEMBRO, " + CRLF
		cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '10' THEN COUNT(*) ELSE 0 END AS OUTUBRO, " + CRLF
		cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '11' THEN COUNT(*) ELSE 0 END AS NOVEMBRO, " + CRLF
		cQuery += "CASE WHEN SUBSTRING( C7_EMISSAO, 5, 2) = '12' THEN COUNT(*) ELSE 0 END AS DEZEMBRO, COUNT(*) AS TOTAL " + CRLF
		cQuery += "FROM ( " + CRLF
		cQuery += "SELECT C7_FILIAL, C7_NUM, C7_EMISSAO " + CRLF
		cQuery += "FROM " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) " + CRLF
		cQuery += "WHERE C7_FILIAL <> '**' " + CRLF
		cQuery += "AND C7_RESIDUO <> 'S' " + CRLF
		cQuery += "AND LEFT(C7_EMISSAO, 4) BETWEEN '" + cAnoAn2 + "' AND '" + cAnoAtu + "' " + CRLF
		cQuery += "AND SC7.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "GROUP BY C7_FILIAL, C7_NUM, C7_EMISSAO " + CRLF
		cQuery += ") AS AGRUPADO " + CRLF
		cQuery += "GROUP BY LEFT(C7_EMISSAO, 4), SUBSTRING( C7_EMISSAO, 5, 2) " + CRLF
		cQuery += ") AS AGRUPAANO " + CRLF
		cQuery += "GROUP BY ANO " + CRLF
		cQuery += "ORDER BY ANO DESC " + CRLF
	
		TcQuery cQuery NEW ALIAS (cAlias)
		(cAlias)->( dbGoTop() )
	
		Do While !(cAlias)->( Eof() )
			nPosAno := aScan( aAno, {|x| AllTrim( x[01] ) == AllTrim( (cAlias)->ANO ) })
	
			If nPosAno > 0
				aAno[nPosAno][02] := (cAlias)->JANEIRO
				aAno[nPosAno][03] := (cAlias)->FEVEREIRO
				aAno[nPosAno][04] := (cAlias)->MARCO
				aAno[nPosAno][05] := (cAlias)->ABRIL
				aAno[nPosAno][06] := (cAlias)->MAIO
				aAno[nPosAno][07] := (cAlias)->JUNHO
				aAno[nPosAno][08] := (cAlias)->JULHO
				aAno[nPosAno][09] := (cAlias)->AGOSTO
				aAno[nPosAno][10] := (cAlias)->SETEMBRO
				aAno[nPosAno][11] := (cAlias)->OUTUBRO
				aAno[nPosAno][12] := (cAlias)->NOVEMBRO
				aAno[nPosAno][13] := (cAlias)->DEZEMBRO
			EndIf
	
			(cAlias)->( dbSkip() )
		EndDo
		
		(cAlias)->( dbCloseArea() )
	
		cQuery := "SELECT SUM(BLOQUEADO) AS BLOQUEADO, SUM(AGUARDANDO) AS AGUARDANDO, SUM(APROVADO) AS APROVADO, SUM(REJEITADO) AS REJEITADO " + CRLF
		cQuery += "FROM ( " + CRLF
		cQuery += "SELECT C7_FILIAL, " + CRLF
		cQuery += "CASE WHEN STATUS = '01' THEN COUNT(*) ELSE 0 END AS BLOQUEADO, " + CRLF
		cQuery += "CASE WHEN STATUS = '02' THEN COUNT(*) ELSE 0 END AS AGUARDANDO, " + CRLF
		cQuery += "CASE WHEN STATUS = '03' THEN COUNT(*) ELSE 0 END AS APROVADO, " + CRLF
		cQuery += "CASE WHEN STATUS = '04' THEN COUNT(*) ELSE 0 END AS REJEITADO " + CRLF
		cQuery += "FROM ( " + CRLF
		cQuery += "SELECT C7_FILIAL, C7_NUM, ISNULL((SELECT TOP 1 CR_STATUS FROM " + RetSqlName("SCR") + " WITH (NOLOCK) WHERE CR_FILIAL = C7_FILIAL AND CR_NUM = C7_NUM AND CR_TIPO = 'PC' AND CR_TIPO <> '05' AND D_E_L_E_T_ = ' ' GROUP BY CR_STATUS), '02') AS STATUS " + CRLF
		cQuery += "FROM " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) " + CRLF
		cQuery += "WHERE C7_FILIAL <> '**' " + CRLF
		cQuery += "AND C7_RESIDUO <> 'S' " + CRLF
		cQuery += "AND LEFT(C7_EMISSAO, 4) IN ('" + Left( DTOS( dDataBase ), 4) + "') " + CRLF
		cQuery += "AND SC7.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "GROUP BY C7_FILIAL, C7_NUM " + CRLF
		cQuery += ") AS AGRUPADO " + CRLF
		cQuery += "GROUP BY C7_FILIAL, STATUS " + CRLF
		cQuery += ") AS AGRUPFIL " + CRLF
	
		TcQuery cQuery NEW ALIAS (cAlias)
		(cAlias)->( dbGoTop() )
	
		Do While !(cAlias)->( Eof() )

			aAdd( aSts, { "0101 - Loja de Tintas", (cAlias)->BLOQUEADO, (cAlias)->AGUARDANDO, (cAlias)->APROVADO, (cAlias)->REJEITADO })
	
	
			(cAlias)->( dbSkip() )
		EndDo
	
		If Len( aSts ) == 0
			aAdd( aSts, {"",0,0,0,0})
		EndIf
	
		(cAlias)->( dbCloseArea() )
	
		cQuery := "SELECT AK_NOME, SUM(CR_VALLIB) AS VALOR " + CRLF
		cQuery += "FROM " + RetSqlName("SCR") + " AS SCR WITH (NOLOCK) " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) ON C7_FILIAL = CR_FILIAL " + CRLF
		cQuery += "  AND C7_NUM = CR_NUM " + CRLF
		cQuery += "  AND C7_RESIDUO <> 'S' " + CRLF
		cQuery += "  AND SC7.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SAL") + " AS SAL WITH (NOLOCK) ON AL_FILIAL = '" + xFilial("SAL") + "' " + CRLF
		cQuery += "  AND AL_COD = C7_APROV " + CRLF
		cQuery += "  AND AL_APROV = CR_APROV " + CRLF
		cQuery += "  AND AL_USER = CR_USER " + CRLF
		cQuery += "  AND EXISTS (SELECT * FROM " + RetSqlName("SAL") + " WITH (NOLOCK) WHERE AL_FILIAL = SAL.AL_FILIAL AND AL_COD = C7_APROV AND AL_APROV = SAL.AL_APROV AND AL_USER = '" + AllTrim( HttpSession->ccodusr ) + "' AND D_E_L_E_T_ = ' ') " + CRLF
		cQuery += "  AND SAL.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SAK") + " AS SAK WITH (NOLOCK) ON AK_FILIAL = '" + xFilial("SAK") + "' " + CRLF
		cQuery += "  AND AK_COD = AL_APROV " + CRLF
		cQuery += "  AND AK_USER = AL_USER " + CRLF
		cQuery += "  AND SAK.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "WHERE CR_FILIAL <> '**' " + CRLF
		cQuery += "AND CR_TIPO = 'PC' " + CRLF
		cQuery += "AND LEFT( CR_DATALIB, 4) = '" + Left( DTOS( dDataBase ), 4) + "' " + CRLF
		cQuery += "AND CR_STATUS = '03' " + CRLF
		cQuery += "AND SCR.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "GROUP BY AK_NOME " + CRLF
		cQuery += "UNION ALL " + CRLF
		cQuery += "SELECT AK_NOME, 0 AS VALOR " + CRLF
		cQuery += "FROM " + RetSqlName("SAL") + " AS SAL WITH (NOLOCK) " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SAK") + " AS SAK WITH (NOLOCK) ON AK_FILIAL = AL_FILIAL " + CRLF
		cQuery += "  AND AK_COD = AL_APROV " + CRLF
		cQuery += "  AND AK_USER = AL_USER " + CRLF
		cQuery += "  AND SAK.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "WHERE AL_FILIAL = '" + xFilial("SAL") + "' " + CRLF
		cQuery += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("SCR") + " WITH (NOLOCK) WHERE CR_FILIAL <> '**' AND CR_APROV = AL_APROV AND CR_USER = AL_USER AND CR_STATUS = '03' AND D_E_L_E_T_ = ' ') " + CRLF
		cQuery += "AND SAL.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "GROUP BY AK_NOME " + CRLF
		cQuery += "ORDER BY AK_NOME " + CRLF
	
		TcQuery cQuery NEW ALIAS (cAlias)
		(cAlias)->( dbGoTop() )
	
		Do While !(cAlias)->( Eof() )
			aAdd( aAprova, { AllTrim( (cAlias)->AK_NOME ), (cAlias)->VALOR })
	
			(cAlias)->( dbSkip() )
		EndDo
	
		If Len( aAprova ) == 0
			aAdd( aAprova, { "", 0})
		EndIf
	
		(cAlias)->( dbCloseArea() )
	
		cQuery := "SELECT TOP 5 C7_CC, CTT_DESC01, SUM(C7_TOTAL) AS TOTAL " + CRLF
		cQuery += "FROM " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("CTT") + " AS CTT WITH (NOLOCK) ON CTT_FILIAL = '" + xFilial("CTT") + "' " + CRLF
		cQuery += "  AND CTT_CUSTO = C7_CC " + CRLF
		cQuery += "  AND CTT.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "WHERE C7_FILIAL <> '**' " + CRLF
		cQuery += "AND LEFT(C7_EMISSAO, 4) IN ('" + Left( DTOS( dDataBase ), 4) + "') " + CRLF
		cQuery += "AND C7_RESIDUO <> 'S' " + CRLF
		cQuery += "AND SC7.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "GROUP BY C7_CC, CTT_DESC01 " + CRLF
		cQuery += "ORDER BY SUM(C7_TOTAL) DESC " + CRLF
	
		TcQuery cQuery NEW ALIAS (cAlias)
		(cAlias)->( dbGoTop() )
	
		Do While !(cAlias)->( Eof() )
			aAdd( aCC, { AllTrim( (cAlias)->CTT_DESC01 ), (cAlias)->TOTAL })
	
			(cAlias)->( dbSkip() )
		EndDo
		
		(cAlias)->( dbCloseArea() )
	
		cHtml += Execblock("BePMenus",.F.,.F.)
		
		cHtml += '<div class="main" style="margin-top: 50px;">' + CRLF
		cHtml += '	<div id="page-wrapper">' + CRLF
		cHtml += '		<div class="row">' + CRLF
		cHtml += '			<div class="col-lg-12">' + CRLF
		cHtml += '				<h2 class="page-header"><i class="fa fa-line-chart fa-1x"></i> Dashboard de Compras</h2>' + CRLF
		cHtml += '			</div>' + CRLF
		cHtml += '			<!-- /.col-lg-12 -->' + CRLF
		cHtml += '		</div>' + CRLF
		cHtml += '		<div class="row">' + CRLF
		cHtml += '			<div class="col-lg-3 col-md-6">' + CRLF
		cHtml += '				<div class="panel panel-primary">' + CRLF
		cHtml += '					<div class="panel-heading">' + CRLF
		cHtml += '						<div class="row">' + CRLF
		cHtml += '							<div class="col-xs-3">' + CRLF
		cHtml += '								<i class="fa fa-calendar-check-o fa-5x"></i>' + CRLF //<i class="fa fa-tasks fa-5x"></i>
		cHtml += '							</div>' + CRLF
		cHtml += '							<div class="col-xs-9 text-right">' + CRLF
		cHtml += '								<div class="huge"><B>' + AllTrim( Str( nQtdPenPC ) ) + '</B></div>' + CRLF
		cHtml += '								<div>Pedidos de<Br>Compras</div>' + CRLF
		cHtml += '							</div>' + CRLF
		cHtml += '						</div>' + CRLF
		cHtml += '					</div>' + CRLF
		cHtml += '					<a href="u_BeP0201.apw">' + CRLF
		cHtml += '						<div class="panel-footer">' + CRLF
		cHtml += '							<span class="pull-left">Visualizar</span>' + CRLF
		cHtml += '							<span class="pull-right"><i class="fa fa-arrow-circle-right"></i></span>' + CRLF
		cHtml += '							<div class="clearfix"></div>' + CRLF
		cHtml += '						</div>' + CRLF
		cHtml += '					</a>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
		cHtml += '			<div class="col-lg-3 col-md-6">' + CRLF
		cHtml += '				<div class="panel panel-success">' + CRLF
		cHtml += '					<div class="panel-heading">' + CRLF
		cHtml += '						<div class="row">' + CRLF
		cHtml += '							<div class="col-xs-3">' + CRLF
		cHtml += '								<i class="fa fa-gavel fa-5x"></i>' + CRLF
		cHtml += '							</div>' + CRLF
		cHtml += '							<div class="col-xs-9 text-right">' + CRLF
		cHtml += '								<div class="huge"><B>' + AllTrim( Str( nQtdPenCP ) ) + '</B></div>' + CRLF
		cHtml += '								<div>Contratos de <Br>Parcerias</div>' + CRLF
		cHtml += '							</div>' + CRLF
		cHtml += '						</div>' + CRLF
		cHtml += '					</div>' + CRLF
		cHtml += '					<a href="u_BeP0202.apw">' + CRLF
		cHtml += '						<div class="panel-footer">' + CRLF
		cHtml += '							<span class="pull-left">Visualizar</span>' + CRLF
		cHtml += '							<span class="pull-right"><i class="fa fa-arrow-circle-right"></i></span>' + CRLF
		cHtml += '							<div class="clearfix"></div>' + CRLF
		cHtml += '						</div>' + CRLF
		cHtml += '					</a>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
		cHtml += '			<div class="col-lg-3 col-md-6">' + CRLF
		cHtml += '				<div class="panel panel-danger">' + CRLF
		cHtml += '					<div class="panel-heading">' + CRLF
		cHtml += '						<div class="row">' + CRLF
		cHtml += '							<div class="col-xs-3">' + CRLF
		cHtml += '								<i class="fa fa-truck fa-5x"></i>' + CRLF
		cHtml += '							</div>' + CRLF
		cHtml += '							<div class="col-xs-9 text-right">' + CRLF
		cHtml += '								<div class="huge"><B>' + AllTrim( Str( nQtdPenAE ) ) + '</B></div>' + CRLF
		cHtml += '								<div>Autorização<Br>de Entrega</div>' + CRLF
		cHtml += '							</div>' + CRLF
		cHtml += '						</div>' + CRLF
		cHtml += '					</div>' + CRLF
		cHtml += '					<a href="u_BeP0203.apw">' + CRLF
		cHtml += '						<div class="panel-footer">' + CRLF
		cHtml += '							<span class="pull-left">Visualizar</span>' + CRLF
		cHtml += '							<span class="pull-right"><i class="fa fa-arrow-circle-right"></i></span>' + CRLF
		cHtml += '							<div class="clearfix"></div>' + CRLF
		cHtml += '						</div>' + CRLF
		cHtml += '					</a>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
		cHtml += '			<div class="col-lg-3 col-md-6">' + CRLF
		cHtml += '				<div class="panel panel-warning">' + CRLF
		cHtml += '					<div class="panel-heading">' + CRLF
		cHtml += '						<div class="row">' + CRLF
		cHtml += '							<div class="col-xs-3">' + CRLF
		cHtml += '								<i class="fa fa-tags fa-5x"></i>' + CRLF
		cHtml += '							</div>' + CRLF
		cHtml += '							<div class="col-xs-9 text-right">' + CRLF
		cHtml += '								<div class="huge"><B>' + AllTrim( Str( nQtdPenNF ) ) + '</B></div>' + CRLF
		cHtml += '								<div>Notas Fiscais<Br>Tolerância</div>' + CRLF
		cHtml += '							</div>' + CRLF
		cHtml += '						</div>' + CRLF
		cHtml += '					</div>' + CRLF
		cHtml += '					<a href="u_BeP0204.apw">' + CRLF
		cHtml += '						<div class="panel-footer">' + CRLF
		cHtml += '							<span class="pull-left">Visualizar</span>' + CRLF
		cHtml += '							<span class="pull-right"><i class="fa fa-arrow-circle-right"></i></span>' + CRLF
		cHtml += '							<div class="clearfix"></div>' + CRLF
		cHtml += '						</div>' + CRLF
		cHtml += '					</a>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
		cHtml += '		</div>' + CRLF

&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
		nMedDol := 0
	
		cQuery := "SELECT AVG( M2_MOEDA2 ) AS MEDIADOLAR " + CRLF
		cQuery += "FROM " + RetSqlName("SM2") + " AS SM2 WITH (NOLOCK) " + CRLF
		cQuery += "WHERE LEFT( M2_DATA, 6) = LEFT( CONVERT(VARCHAR(8), DATEADD( MM, -1, GETDATE() ), 112), 6) " + CRLF
		cQuery += "AND SM2.D_E_L_E_T_ = ' ' " + CRLF
	
		TCQuery cQuery New Alias "MEDDOL"
		dbSelectArea("MEDDOL")
		dbGoTop()
	
		If !MEDDOL->( Eof() )
			nMedDol := MEDDOL->MEDIADOLAR
		EndIf
	
		MEDDOL->( dbCloseArea() )

		dbSelectArea("SM2")
		dbSetOrder(1)
		dbSeek( dDataBase )

		cHtml += '		<div class="row">' + CRLF
		cHtml += '			<div class="col-lg-6 col-md-6">' + CRLF
		cHtml += '				<div class="panel panel-default">' + CRLF
		cHtml += '					<div class="panel-heading">' + CRLF
		cHtml += '						<div class="row">' + CRLF
		cHtml += '							<div class="col-xs-9 text-right">' + CRLF
		cHtml += '								<div class="huge"><B>Taxa Média Dólar: ' + AllTrim( Transform( nMedDol, "@E 9,999.999999") ) + '</B></div>' + CRLF
		cHtml += '							</div>' + CRLF
		cHtml += '						</div>' + CRLF
		cHtml += '					</div>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
		cHtml += '			<div class="col-lg-6 col-md-6">' + CRLF
		cHtml += '				<div class="panel panel-default">' + CRLF
		cHtml += '					<div class="panel-heading">' + CRLF
		cHtml += '						<div class="row">' + CRLF
		cHtml += '							<div class="col-xs-9 text-right">' + CRLF
		cHtml += '								<div class="huge"><B>Taxa Dólar Atual: ' + AllTrim( Transform( SM2->M2_MOEDA2, "@E 9,999.999999") ) + '</B></div>' + CRLF
		cHtml += '							</div>' + CRLF
		cHtml += '						</div>' + CRLF
		cHtml += '					</div>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
		cHtml += '		</div>' + CRLF
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

		cHtml += '		<div class="row">' + CRLF
		cHtml += '			<div class="col-lg-6 col-md-6">' + CRLF
		cHtml += '				<h5><i class="fa fa-bar-chart-o fa-fw"></i> Quantidade de Pedidos por Ano (<B><font color="' + aAno[1][14] + '">' + cAnoAn2 + '</font></B>,<B><font color="' + aAno[2][14] + '">' + cAnoAnt + '</font></B>,<B><font color="' + aAno[3][14] + '">' + cAnoAtu + '</font></B>)</h5>' + CRLF
		cHtml += '				<hr/>' + CRLF
		cHtml += '				<div class="well well-lg">' + CRLF
		cHtml += '					<canvas class="my-4 w-100" id="myChart" width="900" height="380"></canvas>' + CRLF
		cHtml += '					<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>' + CRLF
		cHtml += '					<script>' + CRLF
		cHtml += '						var ctx = document.getElementById("myChart");' + CRLF
		cHtml += '						var myChart = new Chart(ctx, {' + CRLF
		cHtml += "						type: 'line'," + CRLF
		cHtml += '						data: {' + CRLF
		cHtml += '						labels: ["Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"],' + CRLF
		cHtml += '						datasets: [' + CRLF
		For nAno := 1 To Len( aAno )
			cHtml += '						{ ' + CRLF
			cHtml += '						data: [' + AllTrim( Str(aAno[nAno][02]) ) + ',' + AllTrim( Str(aAno[nAno][03]) ) + ',' + AllTrim( Str(aAno[nAno][04]) ) + ',' + AllTrim( Str(aAno[nAno][05]) ) + ',' + AllTrim( Str(aAno[nAno][06]) ) + ',' + AllTrim( Str(aAno[nAno][07]) ) + ',' + AllTrim( Str(aAno[nAno][08]) ) + ',' + AllTrim( Str(aAno[nAno][09]) ) + ',' + AllTrim( Str(aAno[nAno][10]) ) + ',' + AllTrim( Str(aAno[nAno][11]) ) + ',' + AllTrim( Str(aAno[nAno][12]) ) + ',' + AllTrim( Str(aAno[nAno][13]) ) + '],' + CRLF
			cHtml += '						label: "' + aAno[nAno][01] + '",' + CRLF
			cHtml += '						borderColor: "' + aAno[nAno][14] + '",' + CRLF
			cHtml += '						fill: false' + CRLF
			cHtml += '						},' + CRLF
		Next
		cHtml += '						]' + CRLF
		cHtml += '						},' + CRLF
		cHtml += '						options: {' + CRLF
		cHtml += '						scales: {' + CRLF
		cHtml += '						yAxes: [{' + CRLF
		cHtml += '						ticks: {' + CRLF
		cHtml += '						beginAtZero: false' + CRLF
		cHtml += '						}' + CRLF
		cHtml += '						}]' + CRLF
		cHtml += '						},' + CRLF
		cHtml += '						legend: {' + CRLF
		cHtml += '						display: false,' + CRLF
		cHtml += '						}' + CRLF
		cHtml += '						}' + CRLF
		cHtml += '						});' + CRLF
		cHtml += '					</script>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
		cHtml += '			<div class="col-lg-6 col-md-6">' + CRLF
		cHtml += '				<h5><i class="fa fa-bar-chart-o fa-fw"></i> Pedido por Status no Ano (<B>' + Left( DTOS( dDataBase ), 4) + '</B>) e Filiais</h5>' + CRLF
		cHtml += '				<hr/>' + CRLF
		cHtml += '				<div class="well well-lg">' + CRLF
		cHtml += '					<canvas class="my-4 w-100" id="myRosc" width="900" height="380"></canvas>' + CRLF
		cHtml += '					<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>' + CRLF
		cHtml += '					<script>' + CRLF
		cHtml += '						var ctx = document.getElementById("myRosc");' + CRLF
		cHtml += '						var myRosc = new Chart(ctx, {' + CRLF
		cHtml += "						type: 'bar'," + CRLF
		cHtml += '						data: {' + CRLF
		cHtml += '						labels: ["Bloqueado", "Aguardando", "Aprovado", "Rejeitado"],' + CRLF
		cHtml += '						datasets: [' + CRLF
		For nSts := 1 To Len( aSts )
			cHtml += '						{ ' + CRLF
			cHtml += '						data: [' + AllTrim( Str(aSts[nSts][02]) ) + ',' + AllTrim( Str(aSts[nSts][03]) ) + ',' + AllTrim( Str(aSts[nSts][04]) ) + ',' + AllTrim( Str(aSts[nSts][05]) ) + '],' + CRLF
			cHtml += '						label: "' + aSts[nSts][01] + '",' + CRLF
			cHtml += '						borderColor: "#3e95cd",' + CRLF
			cHtml += '						fill: false' + CRLF
			cHtml += '						},' + CRLF
		Next
		cHtml += '						]' + CRLF
		cHtml += '						},' + CRLF
		cHtml += '						options: {' + CRLF
		cHtml += '						scales: {' + CRLF
		cHtml += '						yAxes: [{' + CRLF
		cHtml += '						ticks: {' + CRLF
		cHtml += '						beginAtZero: false' + CRLF
		cHtml += '						}' + CRLF
		cHtml += '						}]' + CRLF
		cHtml += '						},' + CRLF
		cHtml += '						legend: {' + CRLF
		cHtml += '						display: false,' + CRLF
		cHtml += '						}' + CRLF
		cHtml += '						}' + CRLF
		cHtml += '						});' + CRLF
		cHtml += '					</script>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
		cHtml += '		</div>'
		cHtml += '		<Hr>' + CRLF
		cHtml += '		<div class="row">' + CRLF
		cHtml += '			<div class="col-lg-6 col-md-6">' + CRLF
		cHtml += '				<h5><i class="fa fa-bar-chart-o fa-fw"></i> Valores Aprovados no Ano (<B>' + Left( DTOS( dDataBase ), 4) + '</B>)</h5>' + CRLF
		cHtml += '				<hr/>' + CRLF
		cHtml += '				<div class="well well-lg">' + CRLF
		cHtml += '					<canvas class="my-4 w-100" id="myAprov" width="900" height="380"></canvas>' + CRLF
		cHtml += '					<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>' + CRLF
		cHtml += '					<script>' + CRLF
		cHtml += '						var ctx = document.getElementById("myAprov");' + CRLF
		cHtml += '						var myAprov = new Chart(ctx, {' + CRLF
		cHtml += "						type: 'horizontalBar'," + CRLF
		cHtml += '						data: {' + CRLF
		For nNom := 1 To Len( aAprova )
			If nNom == 1
				cHtml += '						labels: ['
			EndIf
			cHtml += '"' + AllTrim( aAprova[nNom][1] ) + '"'
			If nNom == Len( aAprova )
				cHtml += '],' + CRLF
			Else
				cHtml += ','
			EndIf
		Next
		cHtml += '						datasets: [' + CRLF
		cHtml += '						{ ' + CRLF
		For nNom := 1 To Len( aAprova )
			If nNom == 1
				cHtml += '						data: ['
			EndIf
			cHtml += '' + AllTrim( Str( aAprova[nNom][2] ) ) + ''
			If nNom == Len( aAprova )
				cHtml += '],' + CRLF
			Else
				cHtml += ','
			EndIf
		Next
		cHtml += '						label: "Valores Aprovados por Aprovador",' + CRLF
		cHtml += '						borderColor: "#3e95cd",' + CRLF
		cHtml += '						fill: false' + CRLF
		cHtml += '						},' + CRLF
		cHtml += '						]' + CRLF
		cHtml += '						},' + CRLF
		cHtml += '						options: {' + CRLF
		cHtml += '						scales: {' + CRLF
		cHtml += '						yAxes: [{' + CRLF
		cHtml += '						ticks: {' + CRLF
		cHtml += '						beginAtZero: false' + CRLF
		cHtml += '						}' + CRLF
		cHtml += '						}]' + CRLF
		cHtml += '						},' + CRLF
		cHtml += '						legend: {' + CRLF
		cHtml += '						display: false,' + CRLF
		cHtml += '						}' + CRLF
		cHtml += '						}' + CRLF
		cHtml += '						});' + CRLF
		cHtml += '					</script>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
		cHtml += '			<div class="col-lg-6 col-md-6">' + CRLF
		cHtml += '				<h5><i class="fa fa-bar-chart-o fa-fw"></i> Top 5 Centro de Custos no Ano (<B>' + Left( DTOS( dDataBase ), 4) + '</B>)</h5>' + CRLF
		cHtml += '				<hr/>' + CRLF
		cHtml += '				<div class="well well-lg">' + CRLF
		cHtml += '					<canvas id="pieChart"></canvas>' + CRLF
		cHtml += '					<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>' + CRLF
		cHtml += '					<script>' + CRLF
		cHtml += "						var ctxD = document.getElementById(" + '"pieChart"' + ").getContext('2d');" + CRLF
		cHtml += '						var myLineChart = new Chart(ctxD, {' + CRLF
		cHtml += "						type: 'pie'," + CRLF
		cHtml += '						data: {' + CRLF
		cHtml += '						labels: ['
		For nCC := 1 To Len(aCC)
			cHtml += '"' + aCC[nCC][01] + '"'
			If nCC < Len(aCC)
				cHtml += ', '
			EndIf
		Next
		cHtml += '],' + CRLF
		cHtml += '						datasets: [' + CRLF
		cHtml += '						{' + CRLF
		cHtml += '						data: ['
		For nCC := 1 To Len(aCC)
			cHtml += '"' + AllTrim( Str(aCC[nCC][02]) ) + '"'
			If nCC < Len(aCC)
				cHtml += ', '
			EndIf
		Next
		cHtml += '],' + CRLF
		cHtml += '						backgroundColor: ["#ff0040", "#FDB45C", "#3e95cd", "#4D5360", "#5e46bf"],' + CRLF
		cHtml += '						hoverBackgroundColor: ["#ff0040", "#FFC870", "#3e95cd", "#616774", "#7c61e8"]' + CRLF
		cHtml += '						}' + CRLF
		cHtml += '						]' + CRLF
		cHtml += '						},' + CRLF
		cHtml += '						options: {' + CRLF
		cHtml += '						responsive: true' + CRLF
		cHtml += '						}' + CRLF
		cHtml += '						});' + CRLF
		cHtml += '					</script>' + CRLF
		cHtml += '				</div>' + CRLF
		cHtml += '			</div>' + CRLF
    EndIf

	If !lApvComp .And. !lApvCart .And. !lColabor
		cHtml += Execblock("BePMenus",.F.,.F.)
	
		cHtml += '<style>' + CRLF
		cHtml += '	.jumbotron {' + CRLF
		cHtml += '	background-color: #15224f;' + CRLF
		cHtml += '	color: #fff;' + CRLF
		cHtml += '	margin-top: 50px;' + CRLF
		cHtml += '	}' + CRLF
		cHtml += '</style>' + CRLF

		cHtml += '<div class="main">' + CRLF
		cHtml += '	<div class="jumbotron jumbotron-fluid text-center">' + CRLF
		cHtml += '		<div class="container">' + CRLF
		cHtml += '			<div class="jumbotron text-center">' + CRLF
		cHtml += '				<h1>Bem-Vindo...</h1>' + CRLF 
		If cEnvServer == "PORTAL_LOJA"
			cHtml += '				<p>Ao Novo Portal ERP Protheus da Loja de Tintas</p>' + CRLF
		/*
		ElseIf cEnvServer == "PORTAL_QUALY"
			cHtml += '				<p>Ao Novo Portal ERP Protheus da Qualycril</p>' + CRLF
		ElseIf cEnvServer == "PORTAL_METROPOLE"
			cHtml += '				<p>Ao Novo Portal ERP Protheus da Metropole</p>' + CRLF
		ElseIf cEnvServer == "PORTAL_JAYS"
			cHtml += '				<p>Ao Novo Portal ERP Protheus da Jays</p>' + CRLF
		Else
			cHtml += '				<p>Ao Novo Portal ERP Protheus da Qualyvinil</p>' + CRLF
		*/
		EndIf
		cHtml += '			</div>' + CRLF
		cHtml += '		</div>' + CRLF
		cHtml += '	</div>' + CRLF
		cHtml += '</div>' + CRLF
	EndIf
Else
	cMsgHdr		:= "Sessão não Iniciada"
	cMsgBody	:= "A sessão não foi iniciada, realize o Login!"

	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
EndIf

cHtml += Execblock("BePFooter",.F.,.F.)

WEB EXTENDED END

Return (EncodeUTF8(cHtml))
