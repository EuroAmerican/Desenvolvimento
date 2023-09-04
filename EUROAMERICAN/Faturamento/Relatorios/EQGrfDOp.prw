#Include 'Protheus.Ch'
#Include 'Totvs.Ch'
#Include 'TopConn.Ch'
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2

User Function EQGrfDOp()

Local oChart
Local oDlg
Local aAno         := {}
Local nAno         := 0
Local aDados	   := {}
Local aQtdTipo	   := {}	
Local cQuery       := ""
Local cNomeRel     := "Rel_EQGrfDOp_"+dToS(Date())+StrTran(Time(), ':', '-')
Local cDiretorio   := GetTempPath()
Local cAlias	   := GetNextAlias()
Local cAliasTipo   := GetNextAlias()
Local nLinCab      := 025
Local nAltur       := 540 //250  (550,800)
Local nLargur      := 800 //1050

Local nTotPV	   := 0
Local nTotNF	   := 0	

Private _cRotina   := "EQGRFDOP"
Private cPerg      := _cRotina
Private cHoraEx    := Time()
Private nPagAtu    := 1
Private oPrintPvt
Private cNomeFont  := "Arial"
Private oFontRod   := TFont():New(cNomeFont, , -06, , .F.)
Private oFontTit   := TFont():New(cNomeFont, , -20, , .T.)
Private oFontSubN  := TFont():New(cNomeFont, , -17, , .T.)
Private oFont07n   := TFont():New( "Arial",, 07,,.T.)
Private oFont06    := TFont():New( "Courier New",, 06,,.F.)
Private oBrush     := TBrush():New(,CLR_CYAN,,)
//Linhas e colunas
Private nLinAtu     := 0
Private nLinFin     := 820
Private nColIni     := 010
Private nColFin     := 550
Private nColMeio    := (nColFin-nColIni)/2

ValidPerg()

If !Pergunte(cPerg,.T.)
	Return
EndIf

//Criando o objeto de impressão
oPrintPvt := FWMSPrinter():New(cNomeRel, IMP_PDF, .F., /*cStartPath*/, .T., , @oPrintPvt, , , , , .T.)
oPrintPvt:cPathPDF := GetTempPath()
oPrintPvt:SetResolution(72)
//oPrintPvt:SetLandscape()
oPrintPvt:SetPortrait()
oPrintPvt:SetPaperSize(DMPAPER_A4)
oPrintPvt:SetMargin(60, 60, 60, 60)
oPrintPvt:StartPage()

//Cabeçalho
oPrintPvt:SayAlign(nLinCab, nColIni /*nColMeio-150*/, "Gráfico de Desempenho de Separação", oFontTit, 550, 20, , PAD_LEFT, 0)

nLinCab += 35
oPrintPvt:Line(nLinCab, nColIni, nLinCab, nColFin, RGB(200, 200, 200))

oPrintPvt:SayAlign(nLinCab+=10, nColIni, "Parâmetros", oFontSubN, 450, 20, , PAD_LEFT, 0)
nLinCab += 10
oPrintPvt:SayAlign(nLinCab+=10, nColIni, "Da Data  ? " + DtoC(mv_par01)      , oFontRod , 450, 20, , PAD_LEFT, 0)
oPrintPvt:SayAlign(nLinCab+=10, nColIni, "Até Data ? " + DtoC(mv_par02)      , oFontRod , 450, 20, , PAD_LEFT, 0)

nLinCab += 15
oPrintPvt:Line(nLinCab, nColIni, nLinCab, nColFin, RGB(200, 200, 200))

nLinCab += 35
nLinAtu := nLinCab

//Se o arquivo existir, exclui ele
If File(cDiretorio+"_grafico.png")
	FErase(cDiretorio+"_grafico.png")
EndIf

cQuery := "SELECT CB7_CODOPE, CB1_NOME, COUNT(CB7_ORDSEP) TOTAL_ORDSEP, SUM(TOTAL_ITEM) AS TOTAL_ITEM"+CRLF
cQuery += "FROM ("+CRLF
cQuery += "	SELECT CB7_CODOPE, CB1_NOME, CB7_ORDSEP, SUM(CB8_QTDORI) AS TOTAL_ITEM"+CRLF
cQuery += "	FROM "+RetSqlName("CB7")+" CB7 "+CRLF
cQuery += "	INNER JOIN "+RetSqlName("CB8")+" CB8 ON CB8_FILIAL = CB7_FILIAL AND CB8_ORDSEP = CB7_ORDSEP AND CB8.D_E_L_E_T_ = ''"+CRLF
cQuery += "	INNER JOIN "+RetSqlName("CB1")+" CB1 ON CB1_FILIAL = '' AND CB1_CODOPE = CB7_CODOPE AND CB1.D_E_L_E_T_ = ''"+CRLF
cQuery += "	WHERE CB7_FILIAL = '"+xFilial("CB7")+"' "+CRLF
cQuery += "	AND CB7.D_E_L_E_T_ = '' "+CRLF
cQuery += "	AND CB7_DTEMIS BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "+CRLF
cQuery += "	AND CB7_STATUS = '9' "+CRLF
cQuery += "	GROUP BY CB7_CODOPE, CB1_NOME, CB7_ORDSEP"+CRLF
cQuery += "	) AS AGRUPADO"+CRLF
cQuery += "GROUP BY  CB7_CODOPE, CB1_NOME"+CRLF
cQuery += "ORDER BY TOTAL_ITEM DESC"+CRLF

ConOut(cQuery)                                          

If Select((cAlias)) <> 0
	(cAlias)->( dbCloseArea() )
EndIf

TCQuery cQuery New Alias (cAlias)

dbSelectArea(cAlias)
dbGoTop()

Do While !(cAlias)->( Eof() )

	aAdd( aDados, { (cAlias)->CB7_CODOPE, (cAlias)->CB1_NOME, (cAlias)->TOTAL_ORDSEP, (cAlias)->TOTAL_ITEM 	})
	
	(cAlias)->( dbSkip() )
EndDo

(cAlias)->( dbCloseArea() )

cQuery := "SELECT CB7_ORIGEM, COUNT(*) AS TOTAL "+CRLF
cQuery += "FROM "+RetSqlName("CB7")+" CB7"+CRLF
cQuery += "WHERE CB7_FILIAL = '"+xFilial("CB7")+"'"+CRLF
cQuery += "AND CB7.D_E_L_E_T_ = ''"+CRLF
cQuery += "AND CB7_DTEMIS BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "+CRLF
cQuery += "AND CB7_STATUS = '9' "+CRLF
cQuery += "GROUP BY CB7_ORIGEM "+CRLF

ConOut(cQuery)                                          

If Select((cAliasTipo)) <> 0
	(cAliasTipo)->( dbCloseArea() )
EndIf

TCQuery cQuery New Alias (cAliasTipo)

dbSelectArea(cAliasTipo)
dbGoTop()

Do While !(cAliasTipo)->( Eof() )

	If (cAliasTipo)->CB7_ORIGEM == '1'
		nTotPV := (cAliasTipo)->TOTAL 
	Else
		nTotNF := (cAliasTipo)->TOTAL 
	EndIf
	
	(cAliasTipo)->( dbSkip() )
EndDo

(cAliasTipo)->( dbCloseArea() )

If Len( aDados ) == 0
	ApMsgAlert("Não há dados para geração","Atenção")
	Return
EndIf

DEFINE MSDIALOG oDlg TITLE "Gráfico de Desempenho de Separação" PIXEL FROM 10,0 TO 550,800

//oChart := FWChartLine():New()
oChart := FWChartPie():New()
oChart:init( oDlg, .t. )

For nX := 1 To Len( aDados )
	oChart:addSerie( aDados[nX][02],aDados[nX][03] )
Next

// ALTERA A COR PADRÃO DO GRÁFICO
oChart:oFwChartColor:SetColor("RANDOM")

oChart:setLegend( CONTROL_ALIGN_LEFT )
oChart:Build()

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (oChart:SaveToPng(0, 0, nLargur, nAltur, cDiretorio+"_grafico.png")) //, oDlg:End()

oPrintPvt:SayBitmap(nLinAtu, nColIni, cDiretorio+"_grafico.png", nLargur/2 /*nLargur/2*/,nAltur/2 /*nAltur/1.6*/)
//nLinAtu += nAltur/1.6 + 3
nLinAtu += nAltur/2 + 3

nLinAtu += 35
nLinTp	:= nLinAtu
nLinAtu := CabPrIt(nLinAtu,nColIni)

For nX := 1 To Len( aDados )
	If nLinAtu > 800
		//Impressão do Rodapé
		fImpRod()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa a pagina    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrintPvt:StartPage()
		//Cabeçalho
		oPrintPvt:SayAlign(nLinCab, nColIni /*nColMeio-150*/, "Gráfico de Desempenho de Separação", oFontTit, 550, 20, , PAD_LEFT, 0)

		nLinCab += 35
		oPrintPvt:Line(nLinCab, nColIni, nLinCab, nColFin, RGB(200, 200, 200))
		nLinAtu := nLinCab
		nLinAtu := CabPrIt(nLinAtu,nColIni)
	EndIf

	oPrintPvt:Box(nLinAtu,nColIni+000,nLinAtu + 10,nColIni+068) // Operador
	oPrintPvt:Box(nLinAtu,nColIni+068,nLinAtu + 10,nColIni+108) // Total OS
	oPrintPvt:Box(nLinAtu,nColIni+108,nLinAtu + 10,nColIni+147) // Total Itens

	nLinAtu += 010

	oPrintPvt:Say(nLinAtu-001	,nColIni+005-002,aDados[nX][02]												,oFont06,,CLR_BLACK)
	oPrintPvt:Say(nLinAtu-001	,nColIni+070-002,Transform(aDados[nX][03], "@R 9999999")					,oFont06,,CLR_BLACK)
	oPrintPvt:Say(nLinAtu-001	,nColIni+110-002,Transform(aDados[nX][04], "@R 9999999")				,oFont06,,CLR_BLACK)

Next

oPrintPvt:FillRect({nLinTp,nColIni+228,nLinTp + 12,nColIni+287},oBrush)
oPrintPvt:FillRect({nLinTp,nColIni+288,nLinTp + 12,nColIni+327},oBrush)
nLinTp += 010
oPrintPvt:Say(nLinTp-001	,nColIni+230	,"Tipo O.S."									,oFont07n,,CLR_WHITE)
oPrintPvt:Say(nLinTp-001	,nColIni+290	,"Total"									,oFont07n,,CLR_WHITE)
nLinTp += 002
// Por NF
oPrintPvt:Box(nLinTp,nColIni+228,nLinTp + 10,nColIni+287) // 
oPrintPvt:Box(nLinTp,nColIni+287,nLinTp + 10,nColIni+327) // 
nLinTp += 010
oPrintPvt:Say(nLinTp-001	,nColIni+230-001,"Nota Fiscal",oFont06,,CLR_BLACK)
oPrintPvt:Say(nLinTp-001	,nColIni+280-001,Transform(nTotNF, "@R 9999999")			,oFont06,,CLR_BLACK)
// Por Pedido
oPrintPvt:Box(nLinTp,nColIni+228,nLinTp + 10,nColIni+287) // 
oPrintPvt:Box(nLinTp,nColIni+287,nLinTp + 10,nColIni+327) // 
nLinTp += 010
oPrintPvt:Say(nLinTp-001	,nColIni+230-001,"Pedido de Venda",oFont06,,CLR_BLACK)
oPrintPvt:Say(nLinTp-001	,nColIni+280-001,Transform(nTotPV, "@R 9999999")			,oFont06,,CLR_BLACK)



//Impressão do Rodapé
fImpRod()

//Gera o pdf para visualização
oPrintPvt:Preview()

Return

Static Function fImpRod()

Local nLinRod := nLinFin + 10
Local cTexto  := ""

//Linha Separatória
oPrintPvt:Line(nLinRod, nColIni, nLinRod, nColFin, RGB(200, 200, 200))
nLinRod += 3

//Dados da Esquerda
cTexto := "Relatório Gráfico de Desempenho de Separação | "+dToC(dDataBase)+" "+cHoraEx+" | "+FunName()+" | "+cUserName
oPrintPvt:SayAlign(nLinRod, nColIni, cTexto, oFontRod, 450, 07, , PAD_LEFT, )

//Direita
cTexto := "Página "+cValToChar(nPagAtu)
oPrintPvt:SayAlign(nLinRod, nColFin-40, cTexto, oFontRod, 040, 07, , PAD_RIGHT, )

//Finalizando a página e somando mais um
oPrintPvt:EndPage()
nPagAtu++

Return

Static Function ValidPerg()

Local _aArea := GetArea()
Local _aPerg := {}
Local i      := 0

cPerg := Padr( cPerg, 10)

aAdd(_aPerg, {cPerg, "01", "Da Data ?", "MV_CH1" , "D", 08	, 0	, "G", "MV_PAR01", "   "	,""           ,""               ,""               ,""     ,""})
aAdd(_aPerg, {cPerg, "02", "Até a Data?", "MV_CH2" , "D", 08	, 0	, "G", "MV_PAR02", "   "	,""           ,""               ,""               ,""     ,""})

DbSelectArea("SX1")
DbSetOrder(1)

For i := 1 To Len(_aPerg)
	IF  !DbSeek(_aPerg[i,1]+_aPerg[i,2])
		RecLock("SX1",.T.)
	Else
		RecLock("SX1",.F.)
	EndIF
	Replace X1_GRUPO   with _aPerg[i,01]
	Replace X1_ORDEM   with _aPerg[i,02]
	Replace X1_PERGUNT with _aPerg[i,03]
	Replace X1_VARIAVL with _aPerg[i,04]
	Replace X1_TIPO	   with _aPerg[i,05]
	Replace X1_TAMANHO with _aPerg[i,06]
	Replace X1_PRESEL  with _aPerg[i,07]
	Replace X1_GSC	   with _aPerg[i,08]
	Replace X1_VAR01   with _aPerg[i,09]
	Replace X1_F3	   with _aPerg[i,10]
	Replace X1_DEF01   with _aPerg[i,11]
	Replace X1_DEF02   with _aPerg[i,12]
	Replace X1_DEF03   with _aPerg[i,13]
	Replace X1_DEF04   with _aPerg[i,14]
	Replace X1_DEF05   with _aPerg[i,15]
	MsUnlock()
Next i

RestArea(_aArea)

Return(.T.)

Static Function CabPrIt(nLin,nCol)

oPrintPvt:FillRect({nLin,nCol+000,nLin + 12,nCol+067},oBrush)
oPrintPvt:FillRect({nLin,nCol+068,nLin + 12,nCol+107},oBrush)
oPrintPvt:FillRect({nLin,nCol+108,nLin + 12,nCol+147},oBrush)

nLin += 008
oPrintPvt:Say(nLin-001	,nCol+005	,"Operador"								,oFont07n,,CLR_WHITE)
oPrintPvt:Say(nLin-001	,nCol+070	,"Total O.S."  							,oFont07n,,CLR_WHITE)
oPrintPvt:Say(nLin-001	,nCol+110	,"Total Itens"							,oFont07n,,CLR_WHITE)

nLin += 004

Return nLin