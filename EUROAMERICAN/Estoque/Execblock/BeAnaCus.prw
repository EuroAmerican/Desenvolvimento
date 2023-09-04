#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'RwMake.Ch'
#Include 'TopConn.Ch'
#Include 'Colors.Ch'
#Include 'JPeg.Ch'
#Include 'HButton.Ch'
#Include 'DBTree.Ch'
#Include 'Font.Ch'
#Include 'FwMvcDef.Ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ BeAnaCus º Autor ³ Fabio F. Sousa   º Data ³  25/11/2017   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Analisa possíveis inconsistencias no Estoque...            º±±
±±º          ³ - Valor Total do Custo Negativo                            º±±
±±º          ³ - Quantidade Negativa                                      º±±
±±º          ³ - Há Quantidade com Custo Zerado                           º±±
±±º          ³ - Quantidade Zero com Valor                                º±±
±±º          ³ - Divergência Sld Estoque vs Sld Lote - Estoque: 9,99 Lote:º±±
±±º          ³   9,99 Diferença: 9,99                                     º±±
±±º          ³ - Divergência Sld Estoque vs Sld Endereço - Estoque: 9,99  º±±
±±º          ³   Endereço: 9,99 Diferença: 9,99                           º±±
±±º          ³ - Variação Valor maior que XX% em relação ao fechamento de º±±
±±º          ³   MM/AAAA: CM Set/17: 9,99 CM MM/AAAA: 9,99                º±±
±±º          ³ - Variação entre armazéns maior que XX%, Valor CM Menor:   º±±
±±º          ³   9,99 Valor CM Maior: 9,99                                º±±
±±º          ³ - Variação Filial 01 maior que XX% CM da Filial 99: 9,99   º±±
±±º          ³   com a CM da Filial 99: 9,99                              º±±
±±º          ³ - Custo Unitário acima de R$ 9.999,99 (X mil reais) e com  º±±
±±º          ³   valorização                                              º±±
±±º          ³ - Valor do Item acima de R$ 9.999,99 (X mil de reais)      º±±
±±º          ³ - Nota Fiscal de Venda em MM/AAAA com valor menor que custoº±±
±±º          ³   Documento: XXXXX Série: X Cliente: XXXXXX Emissão:       º±±
±±º          ³   AAAAMMDD Preço: 9,99                                     º±±
±±º          ³ - Última compra com valor maior que o custo, Documento:    º±±
±±º          ³   XXXXX Série: X Fornecedor: XXXXXX Emissão: AAAAMMDD      º±±
±±º          ³   Preço: 9,99                                              º±±
±±º          ³ - Seg. UM divergente com a conversão, Fator: 9,99          º±±
±±º          ³   Quantidade na Seg. UM: 9,99 Calculado: 9,99              º±±
±±º          ³ - Saldo Poder De/Em Terceiros B6_SALDO: 9,99 diferente de  º±±
±±º          ³   acumulados B2_QTNP+B2_QTER+B2_QNPT: 9,99                 º±±
±±º          ³ - Saldo De/Em Terceiros há mais de X dias                  º±±
±±º          ³ - Movimentação Estoque no Período sem sequência de cálculo º±±
±±º----------³------------------------------------------------------------º±±
±±ºDesc.     ³ Analisa execuções de processos para fechamento de estoque  º±±
±±º          ³ - MATA280 - Virada de Saldo                                º±±
±±º          ³ - MATA300 - Acerto Saldo Atual                             º±±
±±º          ³ - MATA190 - Acerto Custo de Entrada                        º±±
±±º          ³ - MATA215 - Refaz Acumulados                               º±±
±±º          ³ - MATA216 - Refaz Poder de Terceiros                       º±±
±±º          ³ - MATA330 - Recalculo Custo Médio                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grupo Sabará                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function BeAnaCus()

Local oProcess
Local oProc
Local oCheck
Local lEnd           := .F.
Local nTamUser       := TamSX3("CV8_USER")[1]

Private oDivCrit
Private oRateioCTB
Private oCtbCompra
Private oCtbFatur
Private oCtbAtivo
Private oCtbFolha
Private oPerBloq
Private oFisBloq
Private oProcRef
Private oProcFec
Private lConfirmado  := .F.
Private aDiverg      := {}
Private aProcesso    := {}
Private aCheckList   := {}
Private nDiv         := 0
Private dProxFec     := STOD(Left(DTOS(GetMv("MV_ULMES") + 32), 6) + "01") - 1
Private dUltFec      := GetMv("MV_ULMES")
Private dVirFec      := GetMv("MV_ULMES")
Private cDesUlt      := fDescMes(dUltFec)
Private cDesProx     := fDescMes(dProxFec)
Private nP3Dias      := GetMv("MV_BE_FEPD",, 365)
Private nPerVar      := GetMv("MV_BE_FEPV",, 40)
Private nLimCM       := GetMv("MV_BE_FELC",, 10000)
Private nLimValor    := GetMv("MV_BE_FELV",, 5000000)
Private cUserParam   := AllTrim( GetMv("MV_BE_FEUS",, "ADMINISTRADOR") )
Private cLimTempo    := GetMv("MV_BE_FELT",, "0000 02:00:00") // [DDDD HH:MM:SS]
Private lDivCrit     := GetMv("MV_BE_FECR",, .T.)
Private lRateioCTB   := GetMv("MV_BE_FERA",, .F.)
Private lPerBloq     := GetMv("MV_BE_FEPB",, .T.)
Private lFisBloq     := GetMv("MV_BE_FEFI",, .T.)
Private lProcFec     := GetMv("MV_BE_FEPR",, .T.)
Private lProcRef     := GetMv("MV_BE_FERR",, .T.)
Private lPodTerc     := GetMv("MV_BE_FEPT",, .F.) // Se exige refaz acumulado mas não exige poder de terceiros...
Private lCtbCompra   := GetMv("MV_BE_FECC",, .F.)
Private lCtbFatur    := GetMv("MV_BE_FECF",, .F.)
Private lCtbFolha    := GetMv("MV_BE_FEFP",, .F.)
Private lCtbAtivo    := GetMv("MV_BE_FEAT",, .F.)
Private cVirada      := ""  // Ultima execução da virada de saldos
Private lEMail       := .F. // Envia report das divergências por e-mail
Private lVlrNeg      := .T. // Valor Total do Custo Negativo
Private lQtdNeg      := .T. // Quantidade Negativa
Private lCusZero     := .T. // Há Quantidade com Custo Zerado
Private lZeroVlr     := .T. // Quantidade Zero com Valor
Private lSldLote     := .T. // Divergência Sld Estoque vs Sld Lote - Estoque: 9,99 Lote: 9,99 Diferença: 9,99
Private lSldEnde     := .T. // Divergência Sld Estoque vs Sld Endereço - Estoque: 9,99 Endereço: 9,99 Diferença: 9,99
Private lVarMes      := .T. // Variação Valor maior que XX% em relação ao fechamento de Setembro/2017: CM Set/17: 9,99 CM Out/2017: 9,99
Private lCMAcima     := .T. // Custo Unitário acima de R$ 9.999,99 (X mil reais) e com valorização
Private lVlrAcima    := .T. // Valor do Item acima de R$ 9.999,99 (X mil de reais)
Private lNFSMenor    := .T. // Nota Fiscal de Venda em Out/2017 com valor menor que custo, Documento: XXXXX Série: X Cliente: XXXXXX Emissão: AAAAMMDD Preço: 9,99
Private lNFEMaior    := .T. // Última compra com valor maior que o custo, Documento: XXXXX Série: X Fornecedor: XXXXXX Emissão: AAAAMMDD Preço: 9,99
Private lDivSeg      := .T. // Seg. UM divergente com a conversão, Fator: 9,99 Quantidade na Seg. UM: 9,99 Calculado: 9,99
Private lEPodTer     := lPodTerc // Saldo Poder De/Em Terceiros B6_SALDO: 9,99 diferente de acumulados B2_QTNP+B2_QTER+B2_QNPT: 9,99
Private lP3Dias      := lPodTerc // Saldo De/Em Terceiros há mais de X dias
Private lMovRet      := .T. // Movimentação Estoque no Período sem sequência de cálculo
Private oFontMsg     := TFont():New('Courier new',,-14,.T.)
Private oFontPar1    := TFont():New('Arial'      ,,-11,.T.,,,,,,.F.,.F.)
Private oFont14n     := TFont():New( "Courier New",,14,,.T.,,,,,.F. )
Private oFont14      := TFont():New( "Courier New",,14,,.F.,,,,,.F. )
Private oOk          := LoadBitmap( GetResources(), "CHECKED"  ) //"wfchk"  ) //
Private oNo          := LoadBitmap( GetResources(), "UNCHECKED") //"wfunchk") //
Private cBmpVir      :=cBmpSal:=cBmpEnt:=cBmpAcu:=cBmpPod:=cBmpCus := "stopproc.png"
Private cUsrVir      :=cUsrSal:=cUsrEnt:=cUsrAcu:=cUsrPod:=cUsrCus := "Pendente"
Private cHrVir       :=cHrSal :=cHrEnt :=cHrAcu :=cHrPod :=cHrCus  := ""
Private dDtVir       :=dDtSal :=dDtEnt :=dDtAcu :=dDtPod :=dDtCus  := ""
Private cParVir      :=cParSal:=cParEnt:=cParAcu:=cParPod:=cParCus := ""

DEFINE MSDIALOG oDlgCFG TITLE "Divergências em custos, último fechamento: " + DTOC(dUltFec) + " próximo fechamento: " + DTOC(dProxFec) + " Filial: " + cFilAnt FROM 000, 000  TO 506, 785 PIXEL

	aTFolder := {'Divergências Quantidades e Custeios','Processos para Fechamento de Estoque','Check-List Processos de Virada de Saldos','Histório do Período'}
	oTFolder := TFolder():New( 0,0,aTFolder,,oDlgCFG,,,,.T.,,C(309),C(174))

	oGroup:= TGroup():New(C(003),C(005),C(130),C(303), 'Selecione a modalidade de divergência para auditoria', oTFolder:aDialogs[1],,,.T.)

	TCheckBox():New(C(010),C(010),'[Crítico] - Valor Total do Custo Negativo',bSETGET(lVlrNeg),oTFolder:aDialogs[1],380,210,,{|| ProcChec( lVlrNeg, 99, .T. )},,,CLR_RED,,,.T.,,,)
	TCheckBox():New(C(018),C(010),'[Crítico] - Quantidade Negativa',bSETGET(lQtdNeg),oTFolder:aDialogs[1],380,210,,{|| ProcChec( lQtdNeg, 99, .T. )},,,CLR_RED,,,.T.,,,)
	TCheckBox():New(C(026),C(010),'[Crítico] - Há Quantidade com Custo Zerado',bSETGET(lCusZero),oTFolder:aDialogs[1],380,210,,{|| ProcChec( lCusZero, 99, .T. )},,,CLR_RED,,,.T.,,,)
	TCheckBox():New(C(034),C(010),'[Baixo] - Quantidade Zero com Valor',bSETGET(lZeroVlr),oTFolder:aDialogs[1],380,210,,{|| ProcChec( lZeroVlr, 99, .F. )},,,CLR_GREEN,,,.T.,,,)
	TCheckBox():New(C(042),C(010),'[Crítico] - Divergência Sld Estoque vs Sld Lote - Estoque: 9,99 Lote: 9,99 Diferença: 9,99',bSETGET(lSldLote),oTFolder:aDialogs[1],380,210,,{|| ProcChec( lSldLote, 99, .T. )},,,CLR_RED,,,.T.,,,)
	TCheckBox():New(C(050),C(010),'[Crítico] - Divergência Sld Estoque vs Sld Endereço - Estoque: 9,99 Endereço: 9,99 Diferença: 9,99',bSETGET(lSldEnde),oTFolder:aDialogs[1],380,210,,{|| ProcChec( lSldEnde, 99, .T. )},,,CLR_RED,,,.T.,,,)
	TCheckBox():New(C(058),C(010),'[Atenção] - <Variação> Custo maior que [' + Transform(nPerVar,"@E 999") + ']% em relação ao fechamento anterior: CM ' + cDesUlt + ': 9,99 CM ' + cDesProx + ': 9,99',bSETGET(lVarMes),oTFolder:aDialogs[1],380,210,,{|| ProcChec( lVarMes, 99, .F. )},,,CLR_BLUE,,,.T.,,,)
	TCheckBox():New(C(066),C(010),'[Atenção] - <Custo Unitário> acima de R$ [' + Transform(nLimCM,"@E 999,999,999.99") + '] (' + AllTrim(Extenso(nLimCM, .T.)) + ') e com valorização',bSETGET(lCMAcima),oTFolder:aDialogs[1],380,210,,{|| ProcChec( lCMAcima, 99, .F. )},,,CLR_BLUE,,,.T.,,,)
	TCheckBox():New(C(074),C(010),'[Atenção] - <Valor do Item> acima de R$ [' + Transform(nLimValor,"@E 999,999,999.99") + '] (' + AllTrim(Extenso(nLimValor, .T.)) + ')',bSETGET(lVlrAcima),oTFolder:aDialogs[1],380,210,,{|| ProcChec( lVlrAcima, 99, .F. )},,,CLR_BLUE,,,.T.,,,)
	TCheckBox():New(C(082),C(010),'[Atenção] - Nota Fiscal de Venda em ' + cDesProx + ' com valor menor que custo, Documento: ... Série: ... Cliente: ... Emissão: ... Preço: 9,99',bSETGET(lNFSMenor),oTFolder:aDialogs[1],380,210,,{|| ProcChec( lNFSMenor, 99, .F. )},,,CLR_BLUE,,,.T.,,,)
	TCheckBox():New(C(090),C(010),'[Atenção] - Última compra com valor maior que o custo, Documento: ... Série: ... Fornecedor: ... Emissão: ... Preço: 9,99',bSETGET(lNFEMaior),oTFolder:aDialogs[1],380,210,,{|| ProcChec( lNFEMaior, 99, .F. )},,,CLR_BLUE,,,.T.,,,)
	TCheckBox():New(C(098),C(010),'[Baixo] - Seg. UM divergente com a conversão, Fator: 9,99 Quantidade na Seg. UM: 9,99 Calculado: 9,99',bSETGET(lDivSeg),oTFolder:aDialogs[1],380,210,,{|| ProcChec( lDivSeg, 99, .F. )},,,CLR_GREEN,,,.T.,,,)
	TCheckBox():New(C(106),C(010),'[Atenção] - Saldo Poder De/Em Terceiros B6_SALDO: 9,99 diferente de acumulados B2_QTNP+B2_QTER+B2_QNPT: 9,99',bSETGET(lEPodTer),oTFolder:aDialogs[1],380,210,,{|| ProcChec( lEPodTer, 99, .F. )},,,CLR_GREEN,,lPodTerc,.T.,,,)
	TCheckBox():New(C(114),C(010),'[Baixo] - Saldo De/Em Terceiros há mais de [' + Transform(nP3Dias,"@E 9,999") + '] dias',bSETGET(lP3Dias),oTFolder:aDialogs[1],380,210,,{|| ProcChec( lP3Dias, 99, .F. )},,,CLR_GREEN,,lPodTerc,.T.,,,)
	TCheckBox():New(C(122),C(010),'[Crítico] - Movimentação Estoque no Período sem sequência de cálculo',bSETGET(lMovRet),oTFolder:aDialogs[1],380,210,,{|| ProcChec( lMovRet, 99, .T. )},,,CLR_RED,,,.T.,,,)

	oGroup:= TGroup():New(C(132),C(005),C(158),C(303), 'Parâmetros de processamentos', oTFolder:aDialogs[1],,,.T.)

	TSay():New(C(140),C(010),{||'Limite Máximo Custo Unitário'},oTFolder:aDialogs[1],,oFontPar1,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
	TGet():New(C(139),C(100), { | u | If( PCount() == 0, nLimCM, nLimCM := u ) },oTFolder:aDialogs[1], 070, 008, "@E 999,999,999.99",{|| nLimCM >= 1 .And. nLimCM <= 100000}, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nLimCM",,,,.T.)
	TSay():New(C(140),C(160),{||'(%) Percentual de Variação Máxima'},oTFolder:aDialogs[1],,oFontPar1,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
	TGet():New(C(139),C(270), { | u | If( PCount() == 0, nPerVar, nPerVar := u ) },oTFolder:aDialogs[1], 030, 008, "@E 999",{|| nPerVar >= 1 .And. nPerVar <= 99}, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nPerVar",,,,.T.)
	TSay():New(C(150),C(010),{||'Limite Máximo Valor do Item'},oTFolder:aDialogs[1],,oFontPar1,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
	TGet():New(C(149),C(100), { | u | If( PCount() == 0, nLimValor, nLimValor := u ) },oTFolder:aDialogs[1], 070, 008, "@E 999,999,999.99",{|| nLimValor <= 10000000}, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nLimValor",,,,.T.)
	TSay():New(C(150),C(160),{||'Nr. Dias máximo De/Em Terceiros'},oTFolder:aDialogs[1],,oFontPar1,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
	TGet():New(C(149),C(270), { | u | If( PCount() == 0, nP3Dias, nP3Dias := u ) },oTFolder:aDialogs[1], 030, 008, "@E 999",{|| nP3Dias >= 1 .And. nP3Dias <= 1000}, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nP3Dias",,,,.T.)

	If lPerBloq
		aAdd( aCheckList, {.F., Padr("Período Bloqueado para Movimentações", 45), Padr("", nTamUser), DTOC( GetMv("MV_DBLQMOV") ), ""})
		If dProxFec > GetMv("MV_DBLQMOV")
			aCheckList[Len(aCheckList)][4] := DTOC( GetMv("MV_DBLQMOV") )
		Else
			aCheckList[Len(aCheckList)][1] := .T.
		EndIf
	EndIf

	If lFisBloq
		aAdd( aCheckList, {.F., Padr("Período Bloqueado Lançamentos Fiscais", 45), Padr("", nTamUser), DTOC( GetMv("MV_DATAFIS") ), ""})
		If dProxFec > GetMv("MV_DATAFIS")
			aCheckList[Len(aCheckList)][4] := DTOC( GetMv("MV_DATAFIS") )
		Else
			aCheckList[Len(aCheckList)][1] := .T.
		EndIf
	EndIf

	cQuery := "SELECT TOP 1 RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) AS CV8_PARAM, CV8_DATA, CV8_HORA, CV8_USER " + CRLF
	cQuery += "FROM " + RetSqlName("CV8") + " AS CV8 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE CV8_FILIAL = '" + xFilial("CV8") + "' " + CRLF
	cQuery += "AND CV8_PROC = 'MATA280' " + CRLF
	cQuery += "AND CV8_INFO = '1' " + CRLF
	cQuery += "AND CV8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
	
	TCQuery cQuery New Alias "TMPVIR"
	dbSelectArea("TMPVIR")
	dbGoTop()
	
	If !TMPVIR->( Eof() )
		cBmpVir := "approve.png"
		cUsrVir := TMPVIR->CV8_USER
		cHrVir  := TMPVIR->CV8_HORA
		cParVir := AllTrim( TMPVIR->CV8_PARAM )
		dDtVir  := DTOC( STOD( TMPVIR->CV8_DATA ) )
		dVirFec := STOD( TMPVIR->CV8_DATA )
		cVirada := TMPVIR->CV8_DATA + TMPVIR->CV8_HORA
	EndIf
	
	TMPVIR->( dbCloseArea() )

	cQuery := "SELECT TOP 1 RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) AS CV8_PARAM, CV8_DATA, CV8_HORA, CV8_USER " + CRLF
	cQuery += "FROM " + RetSqlName("CV8") + " AS CV8 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE CV8_FILIAL = '" + xFilial("CV8") + "' " + CRLF
	cQuery += "AND CV8_DATA >= '" + DTOS( dVirFec ) + "' " + CRLF
	cQuery += "AND CV8_PROC = 'MATA300' " + CRLF
	cQuery += "AND CV8_INFO = '1' " + CRLF
	cQuery += "AND CV8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
	
	TCQuery cQuery New Alias "TMPSAL"
	dbSelectArea("TMPSAL")
	dbGoTop()
	
	aAdd( aCheckList, {.F., Padr("Acerto Saldo Atual", 45), Padr("", nTamUser), "", ""})

	If !TMPSAL->( Eof() )
		dLanc := STOD( TMPSAL->CV8_DATA )
		cTempo := DWElapTime( dLanc, TMPSAL->CV8_HORA + ":00", MsDate(), Time() )
		If cTempo > cLimTempo
			cBmpSal := "waiting.png"
		Else
			cBmpSal := "approve.png"
			aCheckList[Len(aCheckList)][1] := .T.
		EndIf
		cUsrSal	:= TMPSAL->CV8_USER
		cHrSal	:= TMPSAL->CV8_HORA
		dDtSal	:= DTOC( STOD( TMPSAL->CV8_DATA ) )
		cParSal := TMPSAL->CV8_PARAM
		aCheckList[Len(aCheckList)][3] := Padr( Capital( cUsrSal ), nTamUser)
		aCheckList[Len(aCheckList)][4] := dDtSal
		aCheckList[Len(aCheckList)][5] := cHrSal
	EndIf
	
	TMPSAL->( dbCloseArea() )
	
	cQuery := "SELECT TOP 1 RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) AS CV8_PARAM, CV8_DATA, CV8_HORA, CV8_USER " + CRLF
	cQuery += "FROM " + RetSqlName("CV8") + " AS CV8 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE CV8_FILIAL = '" + xFilial("CV8") + "' " + CRLF
	cQuery += "AND CV8_DATA >= '" + DTOS( dVirFec ) + "' " + CRLF
	cQuery += "AND CV8_PROC = 'MATA190' " + CRLF
	cQuery += "AND CV8_INFO = '1' " + CRLF
	cQuery += "AND CV8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
	
	TCQuery cQuery New Alias "TMPENT"
	dbSelectArea("TMPENT")
	dbGoTop()
	
	aAdd( aCheckList, {.F., Padr("Acerto Custo de Entrada", 45), Padr("", nTamUser), "", ""})

	If !TMPENT->( Eof() )
		dLanc := STOD( TMPENT->CV8_DATA )
		cTempo := DWElapTime( dLanc, TMPENT->CV8_HORA + ":00", MsDate(), Time() )
		If cTempo > cLimTempo
			cBmpEnt := "waiting.png"
		Else
			cBmpEnt := "approve.png"
			aCheckList[Len(aCheckList)][1] := .T.
		EndIf
		cUsrEnt	:= TMPENT->CV8_USER
		cHrEnt	:= TMPENT->CV8_HORA
		dDtEnt	:= DTOC( STOD( TMPENT->CV8_DATA ) )
		cParEnt := TMPENT->CV8_PARAM
		aCheckList[Len(aCheckList)][3] := Padr( Capital( cUsrEnt ), nTamUser)
		aCheckList[Len(aCheckList)][4] := dDtEnt
		aCheckList[Len(aCheckList)][5] := cHrEnt
	EndIf
	
	TMPENT->( dbCloseArea() )
	
	cQuery := "SELECT TOP 1 RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) AS CV8_PARAM, CV8_DATA, CV8_HORA, CV8_USER " + CRLF
	cQuery += "FROM " + RetSqlName("CV8") + " AS CV8 WITH (NOLOCK) " + CRLF
	//cQuery += "WHERE CV8_FILIAL = '" + xFilial("CV8") + "' " + CRLF
	cQuery += "WHERE CV8_FILIAL <> '**' " + CRLF
	cQuery += "AND CV8_DATA >= '" + DTOS( dVirFec ) + "' " + CRLF
	cQuery += "AND CV8_PROC = 'MATA215' " + CRLF
	cQuery += "AND CV8_INFO = '1' " + CRLF
	cQuery += "AND CV8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
	
	TCQuery cQuery New Alias "TMPACU"
	dbSelectArea("TMPACU")
	dbGoTop()
	
	If lProcRef
		aAdd( aCheckList, {.F., Padr("Refaz Acumulados", 45), Padr("", nTamUser), "", ""})
	EndIf

	If !TMPACU->( Eof() )
		cBmpAcu := "approve.png"
		cUsrAcu	:= TMPACU->CV8_USER
		cHrAcu	:= TMPACU->CV8_HORA
		dDtAcu	:= DTOC( STOD( TMPACU->CV8_DATA ) )
		cParAcu := TMPACU->CV8_PARAM
		If lProcRef
			aCheckList[Len(aCheckList)][1] := .T.
			aCheckList[Len(aCheckList)][3] := Padr( Capital( cUsrAcu ), nTamUser)
			aCheckList[Len(aCheckList)][4] := dDtAcu
			aCheckList[Len(aCheckList)][5] := cHrAcu
		EndIf
	EndIf
	
	TMPACU->( dbCloseArea() )
	
	cQuery := "SELECT TOP 1 RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) AS CV8_PARAM, CV8_DATA, CV8_HORA, CV8_USER " + CRLF
	cQuery += "FROM " + RetSqlName("CV8") + " AS CV8 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE CV8_FILIAL = '" + xFilial("CV8") + "' " + CRLF
	cQuery += "AND CV8_DATA >= '" + DTOS( dVirFec ) + "' " + CRLF
	cQuery += "AND CV8_PROC = 'MATA216' " + CRLF
	cQuery += "AND CV8_INFO = '1' " + CRLF
	cQuery += "AND CV8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
	
	TCQuery cQuery New Alias "TMPPOD"
	dbSelectArea("TMPPOD")
	dbGoTop()

	If lProcRef .And. lPodTerc
		aAdd( aCheckList, {.F., Padr("Refaz Poder de Terceiros", 45), Padr("", nTamUser), "", ""})
	EndIf

	If !TMPPOD->( Eof() )
		cBmpPod := "approve.png"
		cUsrPod	:= TMPPOD->CV8_USER
		cHrPod	:= TMPPOD->CV8_HORA
		dDtPod	:= DTOC( STOD( TMPPOD->CV8_DATA ) )
		cParPod := TMPPOD->CV8_PARAM
		If lProcRef .And. lPodTerc
			aCheckList[Len(aCheckList)][1] := .T.
			aCheckList[Len(aCheckList)][3] := Padr( Capital( cUsrPod ), nTamUser)
			aCheckList[Len(aCheckList)][4] := dDtPod
			aCheckList[Len(aCheckList)][5] := cHrPod
		EndIf
	Else
		If !lPodTerc
			cBmpPod := "approve.png"
			cUsrPod	:= "Não Obrigatório"
		EndIf
	EndIf
	
	TMPPOD->( dbCloseArea() )
	
	cQuery := "SELECT TOP 1 RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) AS CV8_PARAM, CV8_DATA, CV8_HORA, CV8_USER " + CRLF
	cQuery += "FROM " + RetSqlName("CV8") + " AS CV8 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE CV8_FILIAL = '" + xFilial("CV8") + "' " + CRLF
	cQuery += "AND CV8_DATA >= '" + DTOS( dVirFec ) + "' " + CRLF
	cQuery += "AND CV8_PROC = 'MATA330' " + CRLF
	cQuery += "AND CV8_INFO = '1' " + CRLF
	cQuery += "AND CV8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
	
	TCQuery cQuery New Alias "TMPCUS"
	dbSelectArea("TMPCUS")
	dbGoTop()
	
	aAdd( aCheckList, {.F., Padr("Recalculo de Custo Médio", 45), Padr("", nTamUser), "", ""})

	If !TMPCUS->( Eof() )
		dLanc := STOD( TMPCUS->CV8_DATA )
		cTempo := DWElapTime( dLanc, TMPCUS->CV8_HORA + ":00", MsDate(), Time() )
		If cTempo > cLimTempo
			cBmpCus := "waiting.png"
		Else
			cBmpCus := "approve.png"
			aCheckList[Len(aCheckList)][1] := .T.
		EndIf
		cUsrCus	:= TMPCUS->CV8_USER
		cHrCus	:= TMPCUS->CV8_HORA
		dDtCus	:= DTOC( STOD( TMPCUS->CV8_DATA ) )
		cParCus := TMPCUS->CV8_PARAM
		aCheckList[Len(aCheckList)][3] := Padr( Capital( cUsrCus ), nTamUser)
		aCheckList[Len(aCheckList)][4] := dDtCus
		aCheckList[Len(aCheckList)][5] := cHrCus
	EndIf
	
	TMPCUS->( dbCloseArea() )

	//TGroup():New(C(003),C(005),C(068),C(303), 'Execução de Processos para Fechamentos - Clique no botão [?] do processo para verificar parâmetros utilizados', oTFolder:aDialogs[2],,,.T.)
	TGroup():New(C(003),C(005),C(158),C(303), 'Execução de Processos para Fechamentos - Clique no botão [?] do processo para verificar parâmetros utilizados', oTFolder:aDialogs[2],,,.T.)

	TSay():New(011,012,{|| PadC('Virada',15)   }					,oTFolder:aDialogs[2],,oFont14n,,,,.T.,CLR_HRED,CLR_HRED)
	TSay():New(018,012,{|| PadC('de Saldo',15)  }					,oTFolder:aDialogs[2],,oFont14n,,,,.T.,CLR_HRED,CLR_HRED)
	TBitmap():New(028,022,033,033,,cBmpVir,.T.,oTFolder:aDialogs[2], {|| },,.F.,.F.,,,.F.,,.T.,,.F.)
	TSay():New(054,012,{|| PadC(Capital(Alltrim(cUsrVir)),15)  }	,oTFolder:aDialogs[2],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	TSay():New(061,012,{|| PadC(dDtVir,15) }						,oTFolder:aDialogs[2],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	TSay():New(068,012,{|| PadC(cHrVir,15) }						,oTFolder:aDialogs[2],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	@ 075,030 Button "?"  Size 015,008 Action fMostPar( cParVir, "Virada de Saldo" ) PIXEL OF oTFolder:aDialogs[2]

	TSay():New(011,072,{|| PadC('Saldo',15) }						,oTFolder:aDialogs[2],,oFont14n,,,,.T.,CLR_HRED,CLR_HRED)
	TSay():New(018,072,{|| PadC('Atual',15)}						,oTFolder:aDialogs[2],,oFont14n,,,,.T.,CLR_HRED,CLR_HRED)
	TBitmap():New(028,082,033,033,,cBmpSal,.T.,oTFolder:aDialogs[2], {|| },,.F.,.F.,,,.F.,,.T.,,.F.)
	TSay():New(054,072,{|| PadC(Capital(Alltrim(cUsrSal)),15)} 		,oTFolder:aDialogs[2],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	TSay():New(061,072,{|| PadC(dDtSal,15) }						,oTFolder:aDialogs[2],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	TSay():New(068,072,{|| PadC(cHrSal,15) }						,oTFolder:aDialogs[2],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	@ 075,090 Button "?"  Size 015,008 Action fMostPar( cParSal, "Saldo Atual" ) PIXEL OF oTFolder:aDialogs[2]

	TSay():New(011,132,{|| PadC('Custo de',15) }					,oTFolder:aDialogs[2],,oFont14n,,,,.T.,CLR_HRED,CLR_HRED)
	TSay():New(018,132,{|| PadC('Entrada',15)}						,oTFolder:aDialogs[2],,oFont14n,,,,.T.,CLR_HRED,CLR_HRED)
	TBitmap():New(028,142,033,033,,cBmpEnt,.T.,oTFolder:aDialogs[2], {|| },,.F.,.F.,,,.F.,,.T.,,.F.)
	TSay():New(054,132,{|| PadC(Capital(Alltrim(cUsrEnt)),15)} 		,oTFolder:aDialogs[2],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	TSay():New(061,132,{|| PadC(dDtEnt,15) }						,oTFolder:aDialogs[2],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	TSay():New(068,132,{|| PadC(cHrEnt,15) }						,oTFolder:aDialogs[2],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	@ 075,150 Button "?"  Size 015,008 Action fMostPar( cParEnt, "Custo de Entrada" ) PIXEL OF oTFolder:aDialogs[2]

	TSay():New(011,192,{|| PadC('Refaz',15) }						,oTFolder:aDialogs[2],,oFont14n,,,,.T.,CLR_HRED,CLR_HRED)
	TSay():New(018,192,{|| PadC('Acumulados',15)}					,oTFolder:aDialogs[2],,oFont14n,,,,.T.,CLR_HRED,CLR_HRED)
	TBitmap():New(028,202,033,033,,cBmpAcu,.T.,oTFolder:aDialogs[2], {|| },,.F.,.F.,,,.F.,,.T.,,.F.)
	TSay():New(054,192,{|| PadC(Capital(Alltrim(cUsrAcu)),15)}	 	,oTFolder:aDialogs[2],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	TSay():New(061,192,{|| PadC(dDtAcu,15) }						,oTFolder:aDialogs[2],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	TSay():New(068,192,{|| PadC(cHrAcu,15) }						,oTFolder:aDialogs[2],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	@ 075,210 Button "?"  Size 015,008 Action fMostPar( cParAcu, "Refaz Acumulados" ) PIXEL OF oTFolder:aDialogs[2]

	TSay():New(011,252,{|| PadC('Poder de',15)   }					,oTFolder:aDialogs[2],,oFont14n,,,,.T.,CLR_HRED,CLR_HRED)
	TSay():New(018,252,{|| PadC('Terceiros',15)  }					,oTFolder:aDialogs[2],,oFont14n,,,,.T.,CLR_HRED,CLR_HRED)
	TBitmap():New(028,262,033,033,,cBmpPod,.T.,oTFolder:aDialogs[2], {|| },,.F.,.F.,,,.F.,,.T.,,.F.)
	TSay():New(054,252,{|| PadC(Capital(Alltrim(cUsrPod)),15) }		,oTFolder:aDialogs[2],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	TSay():New(061,252,{|| PadC(dDtPod,15) }						,oTFolder:aDialogs[2],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	TSay():New(068,252,{|| PadC(cHrPod,15) }						,oTFolder:aDialogs[2],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	@ 075,270 Button "?"  Size 015,008 Action fMostPar( cParPod, "Refaz Poder de Terceiros" ) PIXEL OF oTFolder:aDialogs[2]

	TSay():New(011,312,{|| PadC('Custo',15) }						,oTFolder:aDialogs[2],,oFont14n,,,,.T.,CLR_HRED,CLR_HRED)
	TSay():New(018,312,{|| PadC('Médio',15) }						,oTFolder:aDialogs[2],,oFont14n,,,,.T.,CLR_HRED,CLR_HRED)
	TBitmap():New(028,322,033,033,,cBmpCus,.T.,oTFolder:aDialogs[2], {|| },,.F.,.F.,,,.F.,,.T.,,.F.)
	TSay():New(054,312,{|| PadC(Capital(Alltrim(cUsrCus)),15)}	 	,oTFolder:aDialogs[2],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	TSay():New(061,312,{|| PadC(dDtCus,15) }						,oTFolder:aDialogs[2],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	TSay():New(068,312,{|| PadC(cHrCus,15) }						,oTFolder:aDialogs[2],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	@ 075,330 Button "?"  Size 015,008 Action fMostPar( cParCus, "Custo Médio" ) PIXEL OF oTFolder:aDialogs[2]

	//TGroup():New(C(070),C(005),C(158),C(303), 'Configurações Gerais [Regras para execução de processos para fechamentos de estoques]', oTFolder:aDialogs[2],,,.T.)

	oDivCrit   := TCheckBox():New(C(069),C(010),'Impedir Virada de Saldo em ' + cDesProx + ' caso haja divergências críticas',bSETGET(lDivCrit),oTFolder:aDialogs[2],380,210,,{|| ProcChec( lDivCrit, 99, .T. )},,{|| ValAdm(1)},CLR_RED,,,.T.,,,)
	oRateioCTB := TCheckBox():New(C(077),C(010),'Impedir Virada de Saldo se Rateio não processado para GGF e Mão de Obra',bSETGET(lRateioCTB),oTFolder:aDialogs[2],380,210,,{|| ProcChec( lRateioCTB, 99, .T. )},,{|| ValAdm(2)},CLR_RED,,,.T.,,,)
	oCtbCompra := TCheckBox():New(C(085),C(010),'Impedir Virada de Saldo se houver movimentações de Compras não contabilizados',bSETGET(lCtbCompra),oTFolder:aDialogs[2],380,210,,{|| ProcChec( lCtbCompra, 99, .T. )},,{|| ValAdm(3)},CLR_RED,,,.T.,,,)
	oCtbFatur  := TCheckBox():New(C(093),C(010),'Impedir Virada de Saldo se houver movimentações de Faturamentos não contabilizado',bSETGET(lCtbFatur),oTFolder:aDialogs[2],380,210,,{|| ProcChec( lCtbFatur, 99, .T. )},,{|| ValAdm(4)},CLR_RED,,,.T.,,,)
	oCtbAtivo  := TCheckBox():New(C(101),C(010),'Impedir Virada de Saldo caso Ativo Imobilizado não contabilizado',bSETGET(lCtbAtivo),oTFolder:aDialogs[2],380,210,,{|| ProcChec( lCtbAtivo, 99, .T. )},,{|| ValAdm(5)},CLR_RED,,,.T.,,,)
	oCtbFolha  := TCheckBox():New(C(109),C(010),'Impedir Virada de Saldo caso Folha de Pagamentos não contabilizado',bSETGET(lCtbFolha),oTFolder:aDialogs[2],380,210,,{|| ProcChec( lCtbFolha, 99, .T. )},,{|| ValAdm(6)},CLR_RED,,,.T.,,,)
	oPerBloq   := TCheckBox():New(C(117),C(010),'Impedir Virada de Saldo se período não bloqueado para movimentações de estoques [MV_DBLQMOV: ' + DTOC(GetMv("MV_DBLQMOV")) + ']',bSETGET(lPerBloq),oTFolder:aDialogs[2],380,210,,{|| ProcChec( lPerBloq, 99, .T. )},,{|| ValAdm(7)},CLR_RED,,,.T.,,,)
	oFisBloq   := TCheckBox():New(C(125),C(010),'Impedir Virada de Saldo se período fiscal não bloqueado para movimentações fiscais [MV_DATAFIS: ' + DTOC(GetMv("MV_DATAFIS")) + ']',bSETGET(lFisBloq),oTFolder:aDialogs[2],380,210,,{|| ProcChec( lFisBloq, 99, .T. )},,{|| ValAdm(8)},CLR_RED,,,.T.,,,)
	oProcRef   := TCheckBox():New(C(133),C(010),'Impedir Virada de Saldo se Refaz Acumulados e Poder de Terceiros pendentes de execução no Período',bSETGET(lProcRef),oTFolder:aDialogs[2],380,210,,{|| ProcChec( lProcRef, 99, .T. )},,{|| ValAdm(9)},CLR_RED,,,.T.,,,)
	oProcFec   := TCheckBox():New(C(141),C(010),'Impedir Virada de Saldo se principais processos não executados dentro do limite de tempo ou pendente',bSETGET(lProcFec),oTFolder:aDialogs[2],380,210,,{|| ProcChec( lProcFec, 99, .T. )},,{|| ValAdm(10)},CLR_RED,,,.T.,,,)

	TSay():New(C(149),C(010),{||'Limite Máximo para execução do Processo Saldo Atual, Custo de Entrada e Custo Médio antes da Virada de Saldo:'},oTFolder:aDialogs[2],,oFontPar1,,,,.T.,CLR_BLACK,CLR_WHITE,290,20)
	oLimTempo := TGet():New(C(148),C(230), { | u | If( PCount() == 0, cLimTempo, cLimTempo := u ) },oTFolder:aDialogs[2], 040, 008, "",{|| ValAdm(11)}, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cLimTempo",,,,.T.)

	/*
	TSay():New(C(131),C(010),{||'Limite Máximo para execução do Processo Saldo Atual antes da Virada de Saldo:'},oTFolder:aDialogs[2],,oFontPar1,,,,.T.,CLR_BLACK,CLR_WHITE,220,20)
	TGet():New(C(131),C(180), { | u | If( PCount() == 0, cLimTempo, cLimTempo := u ) },oTFolder:aDialogs[2], 040, 008, "",{|| }, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cLimTempo",,,,.T.)

	TSay():New(C(139),C(010),{||'Limite Máximo para execução do Processo Custo de Entrada antes da Virada de Saldo:'},oTFolder:aDialogs[2],,oFontPar1,,,,.T.,CLR_BLACK,CLR_WHITE,220,20)
	TGet():New(C(139),C(180), { | u | If( PCount() == 0, cLimTempo, cLimTempo := u ) },oTFolder:aDialogs[2], 040, 008, "",{|| }, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cLimTempo",,,,.T.)

	TSay():New(C(147),C(010),{||'Limite Máximo para execução do Processo Custo Médio antes da Virada de Saldo:'},oTFolder:aDialogs[2],,oFontPar1,,,,.T.,CLR_BLACK,CLR_WHITE,220,20)
	TGet():New(C(147),C(180), { | u | If( PCount() == 0, cLimTempo, cLimTempo := u ) },oTFolder:aDialogs[2], 040, 008, "",{|| }, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cLimTempo",,,,.T.)
	*/

	cQuery := "SELECT CV8_DATA, CV8_HORA, CV8_PROC, CV8_USER, " + CRLF
	cQuery += "CASE " + CRLF
	cQuery += "  WHEN CV8_PROC = 'MATA330' THEN 'Recalculo Custo Médio' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'MATA190' THEN 'Custo de Entrada' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'MATA300' THEN 'Acerto Saldo Atual' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'MATA215' THEN 'Refaz Acumulados' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'MATA290' THEN 'Lote Economico' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'MATA340' THEN 'Acerto de Inventário' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'MATR470' THEN 'Kardex Mod 3' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'MATR460' THEN 'Registro Inventário Mod 7' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'MATA216' THEN 'Refaz Poder de Terceiros' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'MATA710' THEN 'MRP' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'MATA280' THEN 'Virada de Saldo' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'CTBA190' THEN 'Reprocessamento Contábil' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'CTBA280' THEN 'Rateio Off-Line' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'CTBA350' THEN 'Efetivação Lançamentos' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'CTBANFE' THEN 'Contabilização Compras' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'ATFA080' THEN 'Virada Anual Ativo' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'ATFA120' THEN 'Refaz Saldo Ativo' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'ATFA200' THEN 'Bloqueio/Desbloqueio Depreciação' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'ATFA370' THEN 'Contabilização Ativo Imobilizado' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'CTBAATF' THEN 'Contabilização Ativo Imobilizado' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'GPEM110' THEN 'Contabilização Folha de Pagamentos' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'ATFA050' THEN 'Calculo Mensal Ativo' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'CTBA211' THEN 'Apuração de Resultados' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'CTBA215' THEN 'Estorno Apuração de Resultados' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'MATA320' THEN 'Custo de Reposição' " + CRLF
	cQuery += "  WHEN CV8_PROC = 'CTBANFS' THEN 'Contabilização Faturamento' END AS ROTINA, " + CRLF
	cQuery += "RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) AS CV8_PARAM " + CRLF
	cQuery += "FROM " + RetSqlName("CV8") + " AS CV8 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE CV8_FILIAL = '" + xFilial("CV8") + "' " + CRLF
	cQuery += "AND CV8_DATA + CV8_HORA > '" + AllTrim( cVirada ) + "' " + CRLF
	cQuery += "AND CV8_PROC IN ('MATA330','MATA190','MATA300','MATA215','MATA290','MATA340','MATR470','MATR460','MATA216','MATA710','MATA280','CTBA190','CTBA280','CTBA350','CTBANFE','CTBANFS','ATFA080','ATFA120','ATFA200','ATFA370','CTBAATF','CTBA211','CTBA215','MATA320','ATFA050','GPEM110') " + CRLF
	cQuery += "AND CV8_INFO = '1' " + CRLF
	cQuery += "AND CV8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF

	TCQuery cQuery New Alias "TMPPRO"
	dbSelectArea("TMPPRO")
	dbGoTop()

	If !TMPPRO->( Eof() )
		Do While !TMPPRO->( Eof() )
			aAdd( aProcesso, {	DTOC(STOD(TMPPRO->CV8_DATA)),;
								TMPPRO->CV8_HORA,;
								DWElapTime( STOD(TMPPRO->CV8_DATA), TMPPRO->CV8_HORA + ":00", MsDate(), Time() ),;
								Padr( Capital(TMPPRO->CV8_USER), nTamUser),;
								AllTrim( TMPPRO->CV8_PROC ),;
								AllTrim( TMPPRO->ROTINA ),;
								AllTrim( TMPPRO->CV8_PARAM )})

			TMPPRO->( dbSkip() )
		EndDo
	Else
		aAdd( aProcesso, {	"",;
							"00:00",;
							"0000 00:00:00",;
							Padr( "", nTamUser),;
							"",;
							"",;
							""})
	EndIf

	TMPPRO->( dbCloseArea() )

	If lCtbFatur
		cQuery := "SELECT TOP 1 RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) AS CV8_PARAM, CV8_DATA, CV8_HORA, CV8_USER " + CRLF
		cQuery += "FROM " + RetSqlName("CV8") + " AS CV8 WITH (NOLOCK) " + CRLF
		cQuery += "WHERE CV8_FILIAL = '" + xFilial("CV8") + "' " + CRLF
		cQuery += "AND CV8_DATA >= '" + DTOS( dVirFec ) + "' " + CRLF
		cQuery += "AND CV8_PROC = 'CTBANFS' " + CRLF
		cQuery += "AND CV8_INFO = '1' " + CRLF
		cQuery += "AND RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) LIKE '%" + DTOC( dProxFec ) + "%' " + CRLF
		cQuery += "AND CV8.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
		
		TCQuery cQuery New Alias "TMPNFS"
		dbSelectArea("TMPNFS")
		dbGoTop()
	
		aAdd( aCheckList, {.F., Padr("Contabilização Faturamento", 45), Padr("", nTamUser), "", ""})
	
		If !TMPNFS->( Eof() )
			aCheckList[Len(aCheckList)][1] := .T.
			aCheckList[Len(aCheckList)][3] := Padr( Capital( TMPNFS->CV8_USER ), nTamUser)
			aCheckList[Len(aCheckList)][4] := DTOC( STOD( TMPNFS->CV8_DATA ) )
			aCheckList[Len(aCheckList)][5] := TMPNFS->CV8_HORA
		EndIf
		
		TMPNFS->( dbCloseArea() )
	EndIf

	If lCtbCompra
		cQuery := "SELECT TOP 1 RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) AS CV8_PARAM, CV8_DATA, CV8_HORA, CV8_USER " + CRLF
		cQuery += "FROM " + RetSqlName("CV8") + " AS CV8 WITH (NOLOCK) " + CRLF
		cQuery += "WHERE CV8_FILIAL = '" + xFilial("CV8") + "' " + CRLF
		cQuery += "AND CV8_DATA >= '" + DTOS( dVirFec ) + "' " + CRLF
		cQuery += "AND CV8_PROC = 'CTBANFE' " + CRLF
		cQuery += "AND CV8_INFO = '1' " + CRLF
		cQuery += "AND RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) LIKE '%" + DTOC( dProxFec ) + "%' " + CRLF
		cQuery += "AND CV8.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
		
		TCQuery cQuery New Alias "TMPNFE"
		dbSelectArea("TMPNFE")
		dbGoTop()
	
		aAdd( aCheckList, {.F., Padr("Contabilização Compras", 45), Padr("", nTamUser), "", ""})
	
		If !TMPNFE->( Eof() )
			aCheckList[Len(aCheckList)][1] := .T.
			aCheckList[Len(aCheckList)][3] := Padr( Capital( TMPNFE->CV8_USER ), nTamUser)
			aCheckList[Len(aCheckList)][4] := DTOC( STOD( TMPNFE->CV8_DATA ) )
			aCheckList[Len(aCheckList)][5] := TMPNFE->CV8_HORA
		EndIf
		
		TMPNFE->( dbCloseArea() )
	EndIf

	If lCtbFolha
		cQuery := "SELECT TOP 1 RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) AS CV8_PARAM, CV8_DATA, CV8_HORA, CV8_USER " + CRLF
		cQuery += "FROM " + RetSqlName("CV8") + " AS CV8 WITH (NOLOCK) " + CRLF
		cQuery += "WHERE CV8_FILIAL = '" + xFilial("CV8") + "' " + CRLF
		cQuery += "AND CV8_DATA >= '" + DTOS( dVirFec ) + "' " + CRLF
		cQuery += "AND CV8_PROC = 'GPEM110' " + CRLF
		cQuery += "AND CV8_INFO = '1' " + CRLF
		cQuery += "AND RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) LIKE '%" + DTOC( dProxFec ) + "%' " + CRLF
		cQuery += "AND CV8.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
		
		TCQuery cQuery New Alias "TMPFOL"
		dbSelectArea("TMPFOL")
		dbGoTop()
	
		aAdd( aCheckList, {.F., Padr("Contabilização Folha de Pagamentos", 45), Padr("", nTamUser), "", ""})
	
		If !TMPFOL->( Eof() )
			aCheckList[Len(aCheckList)][1] := .T.
			aCheckList[Len(aCheckList)][3] := Padr( Capital( TMPFOL->CV8_USER ), nTamUser)
			aCheckList[Len(aCheckList)][4] := DTOC( STOD( TMPFOL->CV8_DATA ) )
			aCheckList[Len(aCheckList)][5] := TMPFOL->CV8_HORA
		EndIf
		
		TMPFOL->( dbCloseArea() )
	EndIf

	If lCtbAtivo
		cQuery := "SELECT TOP 1 RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) AS CV8_PARAM, CV8_DATA, CV8_HORA, CV8_USER " + CRLF
		cQuery += "FROM " + RetSqlName("CV8") + " AS CV8 WITH (NOLOCK) " + CRLF
		cQuery += "WHERE CV8_FILIAL = '" + xFilial("CV8") + "' " + CRLF
		cQuery += "AND CV8_DATA >= '" + DTOS( dVirFec ) + "' " + CRLF
		cQuery += "AND CV8_PROC IN ('ATFA370','CTBAATF') " + CRLF
		cQuery += "AND CV8_INFO = '1' " + CRLF
		cQuery += "AND CV8.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
		
		TCQuery cQuery New Alias "TMPATF"
		dbSelectArea("TMPATF")
		dbGoTop()
	
		aAdd( aCheckList, {.F., Padr("Contabilização Ativo Imobilizado", 45), Padr("", nTamUser), "", ""})
	
		If !TMPATF->( Eof() )
			aCheckList[Len(aCheckList)][1] := .T.
			aCheckList[Len(aCheckList)][3] := Padr( Capital( TMPATF->CV8_USER ), nTamUser)
			aCheckList[Len(aCheckList)][4] := DTOC( STOD( TMPATF->CV8_DATA ) )
			aCheckList[Len(aCheckList)][5] := TMPATF->CV8_HORA
		EndIf
		
		TMPATF->( dbCloseArea() )
	EndIf

	If lRateioCTB
		cQuery := "SELECT TOP 1 RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) AS CV8_PARAM, CV8_DATA, CV8_HORA, CV8_USER " + CRLF
		cQuery += "FROM " + RetSqlName("CV8") + " AS CV8 WITH (NOLOCK) " + CRLF
		cQuery += "WHERE CV8_FILIAL = '" + xFilial("CV8") + "' " + CRLF
		cQuery += "AND CV8_DATA >= '" + DTOS( dVirFec ) + "' " + CRLF
		cQuery += "AND CV8_PROC = 'CTBA280' " + CRLF
		cQuery += "AND CV8_INFO = '1' " + CRLF
		cQuery += "AND CV8.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
		
		TCQuery cQuery New Alias "TMPRAT"
		dbSelectArea("TMPRAT")
		dbGoTop()
	
		aAdd( aCheckList, {.F., Padr("Processamento Rateio Off-Line", 45), Padr("", nTamUser), "", ""})
	
		If !TMPRAT->( Eof() )
			aCheckList[Len(aCheckList)][1] := .T.
			aCheckList[Len(aCheckList)][3] := Padr( Capital( TMPRAT->CV8_USER ), nTamUser)
			aCheckList[Len(aCheckList)][4] := DTOC( STOD( TMPRAT->CV8_DATA ) )
			aCheckList[Len(aCheckList)][5] := TMPRAT->CV8_HORA
		EndIf
		
		TMPRAT->( dbCloseArea() )
	EndIf

	cQuery := "SELECT TOP 1 RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) AS CV8_PARAM, CV8_DATA, CV8_HORA, CV8_USER " + CRLF
	cQuery += "FROM " + RetSqlName("CV8") + " AS CV8 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE CV8_FILIAL = '" + xFilial("CV8") + "' " + CRLF
	cQuery += "AND CV8_DATA >= '" + DTOS( dVirFec ) + "' " + CRLF
	cQuery += "AND CV8_PROC = 'CTBA190' " + CRLF
	cQuery += "AND CV8_INFO = '1' " + CRLF
	cQuery += "AND CV8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
	
	TCQuery cQuery New Alias "TMPREP"
	dbSelectArea("TMPREP")
	dbGoTop()

	aAdd( aCheckList, {.F., Padr("Reprocessamento Contábil", 45), Padr("", nTamUser), "", ""})

	If !TMPREP->( Eof() )
		aCheckList[Len(aCheckList)][1] := .T.
		aCheckList[Len(aCheckList)][3] := Padr( Capital( TMPREP->CV8_USER ), nTamUser)
		aCheckList[Len(aCheckList)][4] := DTOC( STOD( TMPREP->CV8_DATA ) )
		aCheckList[Len(aCheckList)][5] := TMPREP->CV8_HORA
	EndIf
	
	TMPREP->( dbCloseArea() )

	//TGroup():New(C(003),C(005),C(101),C(303), 'Conferir Check-List de Processos', oTFolder:aDialogs[3],,,.T.)
	TGroup():New(C(003),C(005),C(158),C(303), 'Conferir Check-List de Processos', oTFolder:aDialogs[3],,,.T.)

	oCheck := TcBrowse():New(C(010),C(008),C(292),C(146),,,,oTFolder:aDialogs[3],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)

	oCheck:AddColumn( TcColumn():New(" "            ,{ || If(aCheckList[oCheck:nAt,01],oOk,oNo) }   ,"" ,,,"CENTER",,.T.,.F.,,,,.F.,) )
	oCheck:AddColumn( TcColumn():New("Processo"     ,{ || aCheckList[oCheck:nAt,02]             }   ,"" ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oCheck:AddColumn( TcColumn():New("Usuário"      ,{ || aCheckList[oCheck:nAt,03]             }   ,"" ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oCheck:AddColumn( TcColumn():New("Data"         ,{ || aCheckList[oCheck:nAt,04]             }   ,"" ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oCheck:AddColumn( TcColumn():New("Hora"         ,{ || aCheckList[oCheck:nAt,05]             }   ,"" ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )

	oCheck:SetArray( aCheckList )

	//TGroup():New(C(103),C(005),C(158),C(303), 'Históricos de Processos no Período', oTFolder:aDialogs[3],,,.T.)
	TGroup():New(C(003),C(005),C(158),C(303), 'Históricos de Processos no Período', oTFolder:aDialogs[4],,,.T.)

	//oProc := TcBrowse():New(C(110),C(008),C(292),C(046),,,,oTFolder:aDialogs[3],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)
	oProc := TcBrowse():New(C(010),C(008),C(292),C(146),,,,oTFolder:aDialogs[4],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)

	oProc:AddColumn( TcColumn():New("Data"         ,{ || aProcesso[oProc:nAt,01] }   ,"" ,,,"CENTER",,.F.,.F.,,,,.F.,) )
	oProc:AddColumn( TcColumn():New("Hora"         ,{ || aProcesso[oProc:nAt,02] }   ,"" ,,,"CENTER",,.F.,.F.,,,,.F.,) )
	oProc:AddColumn( TcColumn():New("Executado Há" ,{ || aProcesso[oProc:nAt,03] }   ,"" ,,,"CENTER",,.F.,.F.,,,,.F.,) )
	oProc:AddColumn( TcColumn():New("Usuário"      ,{ || aProcesso[oProc:nAt,04] }   ,"" ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oProc:AddColumn( TcColumn():New("Rotina"       ,{ || aProcesso[oProc:nAt,05] }   ,"" ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oProc:AddColumn( TcColumn():New("Descrição"    ,{ || aProcesso[oProc:nAt,06] }   ,"" ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )

	oProc:SetArray( aProcesso )

	oTMsgBar   := TMsgBar():New(oDlgCFG, "Estoque/Custos", .F.,.F.,.F.,.F., CLR_BLACK,,oFontMsg,.F.)
	TMsgItem():New( oTMsgBar,'TI-ERP', 160,,CLR_BLACK,,.T., {||} )
	TMsgItem():New( oTMsgBar,AllTrim(SM0->M0_NOME) + " / " + AllTrim(SM0->M0_FILIAL), 550,,CLR_BLACK,,.T., {||} )

	@ C(176),C(191) Button "Validar Virada" Size C(037),C(010) Action (lConfirmado := .F., U_A280OK())    PIXEL OF oDlgCFG
	@ C(176),C(231) Button "Cancelar"       Size C(037),C(010) Action (lConfirmado := .F., oDlgCFG:End()) PIXEL OF oDlgCFG
	@ C(176),C(271) Button "Confirmar"      Size C(037),C(010) Action (lConfirmado := .T., oDlgCFG:End()) PIXEL OF oDlgCFG

ACTIVATE MSDIALOG oDlgCFG CENTERED

If lConfirmado
	oProcess := MsNewProcess():New( {|lEnd| fEstDiverg(@oProcess, @lEnd)}, "Verificando divergências no estoque/custos", "Preparando registros para validações", .T.)
	oProcess:Activate()
EndIf

Return

Static Function ProcChec( lMarcado, nItem, lCritico )

oTFolder:aEnable( nItem, lMarcado)

Return

Static Function fDescMes( dData )

Local cRetorno := ""

Do Case
	Case Month( dData ) == 1
		cRetorno := "Jan/" + Left( DTOS(dData), 4)
	Case Month( dData ) == 2
		cRetorno := "Fev/" + Left( DTOS(dData), 4)
	Case Month( dData ) == 3
		cRetorno := "Mar/" + Left( DTOS(dData), 4)
	Case Month( dData ) == 4
		cRetorno := "Abr/" + Left( DTOS(dData), 4)
	Case Month( dData ) == 5
		cRetorno := "Mai/" + Left( DTOS(dData), 4)
	Case Month( dData ) == 6
		cRetorno := "Jun/" + Left( DTOS(dData), 4)
	Case Month( dData ) == 7
		cRetorno := "Jul/" + Left( DTOS(dData), 4)
	Case Month( dData ) == 8
		cRetorno := "Ago/" + Left( DTOS(dData), 4)
	Case Month( dData ) == 9
		cRetorno := "Set/" + Left( DTOS(dData), 4)
	Case Month( dData ) == 10
		cRetorno := "Out/" + Left( DTOS(dData), 4)
	Case Month( dData ) == 11
		cRetorno := "Nov/" + Left( DTOS(dData), 4)
	Case Month( dData ) == 12
		cRetorno := "Dez/" + Left( DTOS(dData), 4)
EndCase

Return cRetorno

Static Function fMostPar( cMsg, cTitulo )

Local nLin  := 30 // Número máximo de parâmetros registrados nos processos CV8...
Local cPerg := ""

Do Case
	Case AllTrim( cTitulo ) == "Virada de Saldo"
		cPerg := Padr( "MTA280", 10)
	Case AllTrim( cTitulo ) == "Saldo Atual"
		cPerg := Padr( "MTA300", 10)
	Case AllTrim( cTitulo ) == "Custo de Entrada"
		cPerg := Padr( "MTA190", 10)
	Case AllTrim( cTitulo ) == "Refaz Poder de Terceiros"
		cPerg := Padr( "MTA216", 10)
	Case AllTrim( cTitulo ) == "Custo Médio"
		cPerg := Padr( "MTA330", 10)
EndCase

dbSelectArea("SX1")
dbSetOrder(1)

If !Empty( cMsg )
	If AllTrim( cPerg ) == "MTA280"
		cMsg := ""
		SX1->( dbSeek( cPerg + "01" ) )
		Do While !SX1->( Eof() ) .And. AllTrim( SX1->X1_GRUPO ) == AllTrim( cPerg )
			If AllTrim( SX1->X1_GSC ) == "G"
				cMsg += AllTrim( SX1->X1_PERGUNT ) + ' : ' + AllTrim( SX1->X1_VAR01 ) + CRLF
			ElseIf AllTrim( SX1->X1_GSC ) == "C"
				If SX1->X1_PRESEL == 1
					cMsg += AllTrim( SX1->X1_PERGUNT ) + ' : ' + AllTrim( SX1->X1_DEF01 ) + CRLF
				ElseIf SX1->X1_PRESEL == 2
					cMsg += AllTrim( SX1->X1_PERGUNT ) + ' : ' + AllTrim( SX1->X1_DEF02 ) + CRLF
				ElseIf SX1->X1_PRESEL == 3
					cMsg += AllTrim( SX1->X1_PERGUNT ) + ' : ' + AllTrim( SX1->X1_DEF03 ) + CRLF
				ElseIf SX1->X1_PRESEL == 4
					cMsg += AllTrim( SX1->X1_PERGUNT ) + ' : ' + AllTrim( SX1->X1_DEF04 ) + CRLF
				ElseIf SX1->X1_PRESEL == 5
					cMsg += AllTrim( SX1->X1_PERGUNT ) + ' : ' + AllTrim( SX1->X1_DEF05 ) + CRLF
				EndIf
			EndIf

			SX1->( dbSkip() )
		EndDo
	Else
		For nLin := 30 To 1 Step -1
			If Empty( cPerg )
				If At( 'Parametro ' + StrZero( nLin, 2) + ' : ""', cMsg) <> 1
					cMsg := Replace( cMsg, 'Parametro ' + StrZero( nLin, 2) + ' : ""' + CRLF, "")
				Else
					nLin := 0
					Exit
				EndIf
			Else
				If SX1->( dbSeek( cPerg + StrZero( nLin, 2) ) )
					If AllTrim( SX1->X1_GSC ) == "G"
						cMsg := Replace( cMsg, 'Parametro ' + StrZero( nLin, 2) + ' : ', AllTrim( SX1->X1_PERGUNT ) + ' : ')
					ElseIf AllTrim( SX1->X1_GSC ) == "C"
						If At( 'Parametro ' + StrZero( nLin, 2) + ' : "1"', cMsg) <> 0
							cMsg := Replace( cMsg, 'Parametro ' + StrZero( nLin, 2) + ' : "1"', 'Parametro ' + StrZero( nLin, 2) + ' : ' + AllTrim( SX1->X1_DEF01 ))
						ElseIf At( 'Parametro ' + StrZero( nLin, 2) + ' : "2"', cMsg) <> 0
							cMsg := Replace( cMsg, 'Parametro ' + StrZero( nLin, 2) + ' : "2"', 'Parametro ' + StrZero( nLin, 2) + ' : ' + AllTrim( SX1->X1_DEF02 ))
						ElseIf At( 'Parametro ' + StrZero( nLin, 2) + ' : "3"', cMsg) <> 0
							cMsg := Replace( cMsg, 'Parametro ' + StrZero( nLin, 2) + ' : "3"', 'Parametro ' + StrZero( nLin, 2) + ' : ' + AllTrim( SX1->X1_DEF03 ))
						ElseIf At( 'Parametro ' + StrZero( nLin, 2) + ' : "4"', cMsg) <> 0
							cMsg := Replace( cMsg, 'Parametro ' + StrZero( nLin, 2) + ' : "4"', 'Parametro ' + StrZero( nLin, 2) + ' : ' + AllTrim( SX1->X1_DEF04 ))
						ElseIf At( 'Parametro ' + StrZero( nLin, 2) + ' : "5"', cMsg) <> 0
							cMsg := Replace( cMsg, 'Parametro ' + StrZero( nLin, 2) + ' : "5"', 'Parametro ' + StrZero( nLin, 2) + ' : ' + AllTrim( SX1->X1_DEF05 ))
						EndIf
						cMsg := Replace( cMsg, 'Parametro ' + StrZero( nLin, 2) + ' : ', AllTrim( SX1->X1_PERGUNT ) + ' : ')
					EndIf
				Else
					cMsg := Replace( cMsg, 'Parametro ' + StrZero( nLin, 2) + ' : ""' + CRLF, "")
				EndIf
			EndIf
		Next
	EndIf
EndIf

ApMsgInfo( AllTrim( cMsg ), "Parâmetros - " + cTitulo )

Return .T.

Static Function fEstDiverg( oProcess, lEnd )

Local _nFile
Local nCritico     := 0
Local nAtencao     := 0
Local nBaixo       := 0
Local cArquivo     := "c:\temp\Divergencia_Estoque_" + Replace(cDesUlt, "/", "") + "_" + Replace(cDesProx, "/", "") + ".xls"
Local nLin         := 0

MakeDir( "C:\TEMP\" )

If File( cArquivo )
	fErase( cArquivo )
EndIf

Private cMensagem  := ""
Private aColunas   := {}
Private aCabec     := {}
Private cAssunto   := ""

// Chama rotina para acerto de segundas unidades de medidas...
EQAcSegUM()

oProcess:SetRegua1( 15 ) // Críticas + um processo para gerar a planilha...

oProcess:IncRegua1( "Valor Total do Custo Negativo" )
Sleep( 10 )

If lVlrNeg
	cQuery := "SELECT 'Crítico' AS STATUS, 'Valor Total do Custo Negativo' AS DIVERGENCIA, B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM, B2_CMFIM1, B2_VFIM1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND B2_VFIM1 < 0.00 " + CRLF
	cQuery += "AND ABS(B2_VFIM1) > 0.009 " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT 'Crítico' AS STATUS, 'Tipo de Produto ' + B1_TIPO + ' não permitido para saldo e valor de estoque' AS DIVERGENCIA, B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM, B2_CMFIM1, B2_VFIM1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = B2_COD " + CRLF
	cQuery += "  AND B1_TIPO IN ('AI','AF','SV') " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND (ABS(B2_VFIM1) > 0.009 OR ABS(B2_QFIM) > 0.009) " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPDIV"
	dbSelectArea("TMPDIV")
	dbGoTop()

	oProcess:SetRegua2( TMPDIV->( RecCount() ) )

	Do While !TMPDIV->( Eof() )
		oProcess:IncRegua2("Produto: " + AllTrim( TMPDIV->B2_COD ) + " Local: " + AllTrim( TMPDIV->B2_LOCAL ))
		nCritico++

		aAdd( aDiverg, {TMPDIV->STATUS, TMPDIV->DIVERGENCIA, TMPDIV->B2_FILIAL, TMPDIV->B2_COD, TMPDIV->B2_LOCAL, TMPDIV->B2_QFIM, TMPDIV->B2_CMFIM1, TMPDIV->B2_VFIM1 })

		TMPDIV->( dbSkip() )
	EndDo

	TMPDIV->( dbCloseArea() )
EndIf

oProcess:IncRegua1( "Quantidade Negativa" )
Sleep( 10 )

If lQtdNeg
	cQuery := "SELECT 'Crítico' AS STATUS, 'Quantidade Negativa' AS DIVERGENCIA, B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM, B2_CMFIM1, B2_VFIM1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND B2_QFIM < 0 " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPDIV"
	dbSelectArea("TMPDIV")
	dbGoTop()

	oProcess:SetRegua2( TMPDIV->( RecCount() ) )

	Do While !TMPDIV->( Eof() )
		oProcess:IncRegua2("Produto: " + AllTrim( TMPDIV->B2_COD ) + " Local: " + AllTrim( TMPDIV->B2_LOCAL ))
		nCritico++

		aAdd( aDiverg, {TMPDIV->STATUS, TMPDIV->DIVERGENCIA, TMPDIV->B2_FILIAL, TMPDIV->B2_COD, TMPDIV->B2_LOCAL, TMPDIV->B2_QFIM, TMPDIV->B2_CMFIM1, TMPDIV->B2_VFIM1 })

		TMPDIV->( dbSkip() )
	EndDo

	TMPDIV->( dbCloseArea() )
EndIf

oProcess:IncRegua1( "Há Quantidade com Custo Zerado" )
Sleep( 10 )

If lCusZero
	cQuery := "SELECT 'Crítico' AS STATUS, 'Há Quantidade com Custo Zerado' AS DIVERGENCIA, B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM, B2_CMFIM1, B2_VFIM1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND B2_QFIM <> 0 " + CRLF
	cQuery += "AND B2_VFIM1 = 0 " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPDIV"
	dbSelectArea("TMPDIV")
	dbGoTop()

	oProcess:SetRegua2( TMPDIV->( RecCount() ) )

	Do While !TMPDIV->( Eof() )
		oProcess:IncRegua2("Produto: " + AllTrim( TMPDIV->B2_COD ) + " Local: " + AllTrim( TMPDIV->B2_LOCAL ))
		nCritico++

		aAdd( aDiverg, {TMPDIV->STATUS, TMPDIV->DIVERGENCIA, TMPDIV->B2_FILIAL, TMPDIV->B2_COD, TMPDIV->B2_LOCAL, TMPDIV->B2_QFIM, TMPDIV->B2_CMFIM1, TMPDIV->B2_VFIM1 })

		TMPDIV->( dbSkip() )
	EndDo

	TMPDIV->( dbCloseArea() )
EndIf

oProcess:IncRegua1( "Quantidade Zero com Valor" )
Sleep( 10 )

If lZeroVlr
	cQuery := "SELECT 'Baixo' AS STATUS, 'Quantidade Zero com Valor' AS DIVERGENCIA, B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM, B2_CMFIM1, B2_VFIM1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND B2_QFIM = 0 " + CRLF
	cQuery += "AND B2_VFIM1 <> 0.00 " + CRLF
	cQuery += "AND ABS(B2_VFIM1) > 0.009 " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPDIV"
	dbSelectArea("TMPDIV")
	dbGoTop()

	oProcess:SetRegua2( TMPDIV->( RecCount() ) )

	Do While !TMPDIV->( Eof() )
		oProcess:IncRegua2("Produto: " + AllTrim( TMPDIV->B2_COD ) + " Local: " + AllTrim( TMPDIV->B2_LOCAL ))
		nBaixo++

		aAdd( aDiverg, {TMPDIV->STATUS, TMPDIV->DIVERGENCIA, TMPDIV->B2_FILIAL, TMPDIV->B2_COD, TMPDIV->B2_LOCAL, TMPDIV->B2_QFIM, TMPDIV->B2_CMFIM1, TMPDIV->B2_VFIM1 })

		TMPDIV->( dbSkip() )
	EndDo

	TMPDIV->( dbCloseArea() )
EndIf

oProcess:IncRegua1( "Divergência Sld Estoque vs Sld Lote - Estoque: X Lote: X Diferença: X" )
Sleep( 10 )

If lSldLote
	cQuery := "SELECT 'Crítico' AS STATUS, 'Divergência Sld Estoque vs Sld Lote - Estoque: ' + CONVERT(VARCHAR(20),B2_QATU) + ' Lote: ' + CONVERT(VARCHAR(20),SUM(B8_SALDO)) + ' Diferença: ' + CONVERT(VARCHAR(20),ABS(CONVERT(DECIMAL(20,4),SUM(B8_SALDO) - B2_QATU))) AS DIVERGENCIA, B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM, B2_CMFIM1, B2_VFIM1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) ON B8_FILIAL = B2_FILIAL " + CRLF
	cQuery += "  AND B8_PRODUTO = B2_COD " + CRLF
	cQuery += "  AND B8_LOCAL = B2_LOCAL " + CRLF
	cQuery += "  AND SB8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = B2_COD " + CRLF
	cQuery += "  AND B1_RASTRO <> 'N' " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU, B2_QFIM, B2_CMFIM1, B2_VFIM1 " + CRLF
	cQuery += "HAVING ABS(CONVERT(DECIMAL(20,4),SUM(B8_SALDO) - B2_QATU)) > 0.00 " + CRLF

	TCQuery cQuery New Alias "TMPDIV"
	dbSelectArea("TMPDIV")
	dbGoTop()

	oProcess:SetRegua2( TMPDIV->( RecCount() ) )

	Do While !TMPDIV->( Eof() )
		oProcess:IncRegua2("Produto: " + AllTrim( TMPDIV->B2_COD ) + " Local: " + AllTrim( TMPDIV->B2_LOCAL ))
		nCritico++

		aAdd( aDiverg, {TMPDIV->STATUS, TMPDIV->DIVERGENCIA, TMPDIV->B2_FILIAL, TMPDIV->B2_COD, TMPDIV->B2_LOCAL, TMPDIV->B2_QFIM, TMPDIV->B2_CMFIM1, TMPDIV->B2_VFIM1 })

		TMPDIV->( dbSkip() )
	EndDo

	TMPDIV->( dbCloseArea() )
EndIf

oProcess:IncRegua1( "Divergência Sld Estoque vs Sld Endereço - Estoque: X Endereço: X Diferença: X" )
Sleep( 10 )

If lSldEnde //.And. AllTrim( cFilAnt ) == "01"
	/*
	cQuery := "SELECT 'Crítico' AS STATUS, B2_FILIAL, B2_COD, B2_LOCAL, SUM(B2_QATU) AS B2_QATU, SUM(B8_SALDO) AS B8_SALDO, SUM(BF_QUANT) AS BF_QUANT, SUM(DA_SALDO) AS DA_SALDO, " + CRLF
	cQuery += "'Divergência Sld Lote vs Sld Endereço - Lote: ' + CONVERT(VARCHAR(20),SUM(B8_SALDO)) + ' Endereço: ' + CONVERT(VARCHAR(20),SUM(BF_QUANT)) + ' Diferença: ' + CONVERT(VARCHAR(20),ABS(CONVERT(DECIMAL(12,4),SUM(BF_QUANT) - SUM(B8_SALDO + DA_SALDO)))) AS DIVERGENCIA " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU, 0 AS B8_SALDO, 0 AS BF_QUANT, 0 AS DA_SALDO " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = B2_COD " + CRLF
	cQuery += "  AND B1_RASTRO <> 'N' " + CRLF
	cQuery += "  AND B1_MSBLQL <> '1' " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " AS SBZ WITH (NOLOCK) ON BZ_FILIAL = B2_FILIAL " + CRLF
	cQuery += "  AND BZ_COD = B2_COD " + CRLF
	cQuery += "  AND BZ_LOCALIZ <> 'N' " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND CASE WHEN (NOT BZ_LOCALIZ IS NULL AND BZ_LOCALIZ = 'S') OR (BZ_LOCALIZ IS NULL AND B1_LOCALIZ = 'S') THEN 'SIM' ELSE 'NAO' END = 'SIM' " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT B8_FILIAL, B8_PRODUTO, B8_LOCAL, 0 AS B2_QATU, SUM(B8_SALDO) AS B8_SALDO, 0 AS BF_QUANT, 0 AS DA_SALDO " + CRLF
	cQuery += "FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = B8_PRODUTO " + CRLF
	cQuery += "  AND B1_RASTRO <> 'N' " + CRLF
	cQuery += "  AND B1_MSBLQL <> '1' " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " AS SBZ WITH (NOLOCK) ON BZ_FILIAL = B8_FILIAL " + CRLF
	cQuery += "  AND BZ_COD = B8_PRODUTO " + CRLF
	cQuery += "  AND BZ_LOCALIZ <> 'N' " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B8_FILIAL = '" + xFilial("SB8") + "' " + CRLF
	cQuery += "AND CASE WHEN (NOT BZ_LOCALIZ IS NULL AND BZ_LOCALIZ = 'S') OR (BZ_LOCALIZ IS NULL AND B1_LOCALIZ = 'S') THEN 'SIM' ELSE 'NAO' END = 'SIM' " + CRLF
	cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY B8_FILIAL, B8_PRODUTO, B8_LOCAL " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT BF_FILIAL, BF_PRODUTO, BF_LOCAL, 0 AS B2_QATU, 0 AS B8_SALDO, SUM(BF_QUANT) AS BF_QUANT, 0 AS DA_SALDO " + CRLF
	cQuery += "FROM " + RetSqlName("SBF") + " AS SBF WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = BF_PRODUTO " + CRLF
	cQuery += "  AND B1_RASTRO <> 'N' " + CRLF
	cQuery += "  AND B1_MSBLQL <> '1' " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " AS SBZ WITH (NOLOCK) ON BZ_FILIAL = BF_FILIAL " + CRLF
	cQuery += "  AND BZ_COD = BF_PRODUTO " + CRLF
	cQuery += "  AND BZ_LOCALIZ <> 'N' " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE BF_FILIAL = '" + xFilial("SBF") + "' " + CRLF
	cQuery += "AND CASE WHEN (NOT BZ_LOCALIZ IS NULL AND BZ_LOCALIZ = 'S') OR (BZ_LOCALIZ IS NULL AND B1_LOCALIZ = 'S') THEN 'SIM' ELSE 'NAO' END = 'SIM' " + CRLF
	cQuery += "AND SBF.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY BF_FILIAL, BF_PRODUTO, BF_LOCAL " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT DA_FILIAL, DA_PRODUTO, DA_LOCAL, 0 AS B2_QATU, 0 AS B8_SALDO, 0 AS BF_QUANT, SUM(DA_SALDO) AS DA_SALDO " + CRLF
	cQuery += "FROM " + RetSqlName("SDA") + " AS SDA WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = DA_PRODUTO " + CRLF
	cQuery += "  AND B1_RASTRO <> 'N' " + CRLF
	cQuery += "  AND B1_MSBLQL <> '1' " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " AS SBZ WITH (NOLOCK) ON BZ_FILIAL = DA_FILIAL " + CRLF
	cQuery += "  AND BZ_COD = DA_PRODUTO " + CRLF
	cQuery += "  AND BZ_LOCALIZ <> 'N' " + CRLF
	cQuery += "  AND SBZ.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE DA_FILIAL = '" + xFilial("SDA") + "' " + CRLF
	cQuery += "AND CASE WHEN (NOT BZ_LOCALIZ IS NULL AND BZ_LOCALIZ = 'S') OR (BZ_LOCALIZ IS NULL AND B1_LOCALIZ = 'S') THEN 'SIM' ELSE 'NAO' END = 'SIM' " + CRLF
	cQuery += "AND SDA.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY DA_FILIAL, DA_PRODUTO, DA_LOCAL " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF
	cQuery += "GROUP BY B2_FILIAL, B2_COD, B2_LOCAL " + CRLF
	cQuery += "HAVING ABS(CONVERT(DECIMAL(12,4),SUM(BF_QUANT + DA_SALDO) - SUM(B8_SALDO))) > 0.01 " + CRLF
	*/
	cQuery := "SELECT 'Crítico' AS STATUS, DA_FILIAL AS B2_FILIAL, DA_PRODUTO AS B2_COD, DA_LOCAL AS B2_LOCAL, " + CRLF
	cQuery += "'Há saldo a endereçar no período pendente - Saldo: ' + CONVERT(VARCHAR(20),DA_SALDO) + ' - Pendente Desde: ' + CONVERT(VARCHAR(10),CONVERT(DATETIME, DA_DATA), 103) AS DIVERGENCIA " + CRLF
	cQuery += "FROM " + RetSqlName("SDA") + " AS SDA WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = DA_PRODUTO " + CRLF
	cQuery += "  AND B1_RASTRO <> 'N' " + CRLF
	cQuery += "  AND B1_MSBLQL <> '1' " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " AS SBZ WITH (NOLOCK) ON BZ_FILIAL = DA_FILIAL " + CRLF
	cQuery += "  AND BZ_COD = DA_PRODUTO " + CRLF
	cQuery += "  AND BZ_LOCALIZ <> 'N' " + CRLF
	cQuery += "  AND SBZ.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE DA_FILIAL = '" + xFilial("SDA") + "' " + CRLF
	cQuery += "AND DA_DATA BETWEEN '" + DTOS( dUltFec ) + "' AND '" + DTOS( dProxFec ) + "' " + CRLF
	cQuery += "AND DA_SALDO > 0.00 " + CRLF
	cQuery += "AND SDA.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPDIV"
	dbSelectArea("TMPDIV")
	dbGoTop()

	oProcess:SetRegua2( TMPDIV->( RecCount() ) )

	Do While !TMPDIV->( Eof() )
		oProcess:IncRegua2("Produto: " + AllTrim( TMPDIV->B2_COD ) + " Local: " + AllTrim( TMPDIV->B2_LOCAL ))
		nCritico++

		aAdd( aDiverg, {TMPDIV->STATUS, TMPDIV->DIVERGENCIA, TMPDIV->B2_FILIAL, TMPDIV->B2_COD, TMPDIV->B2_LOCAL, 0, 0, 0 })

		TMPDIV->( dbSkip() )
	EndDo

	TMPDIV->( dbCloseArea() )
EndIf

oProcess:IncRegua1( "Variação Valor maior que " + Transform(nPerVar,"@E 999") + "% em relação ao fechamento anterior: CM " + cDesUlt + ": 9,99 CM " + cDesProx + ": 9,99" )
Sleep( 10 )

If lVarMes
	cQuery := "SELECT 'Atenção' AS STATUS, 'Variação Valor maior que " + Transform(nPerVar,"@E 999") + "% em relação ao fechamento anterior: CM " + cDesUlt + ": ' + RTRIM(LTRIM(CONVERT(VARCHAR(20), B9_CM1))) + ' CM " + cDesProx + ": ' + RTRIM(LTRIM(CONVERT(VARCHAR(20), B2_CMFIM1))) AS DIVERGENCIA, B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM, B2_CMFIM1, B2_VFIM1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB9") + " AS SB9 WITH (NOLOCK) ON B9_FILIAL = B2_FILIAL " + CRLF
	cQuery += "AND B9_COD = B2_COD " + CRLF
	cQuery += "AND B9_LOCAL = B2_LOCAL " + CRLF
	cQuery += "AND B9_CM1 > 0 " + CRLF
	cQuery += "AND ABS(B2_CMFIM1 - B9_CM1) > (ABS(B9_CM1) * " + AllTrim(Replace(Str(nPerVar / 100),",",".")) + ") " + CRLF
	cQuery += "AND B9_DATA = '" + DTOS( dUltFec ) + "' " + CRLF
	cQuery += "AND SB9.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPDIV"
	dbSelectArea("TMPDIV")
	dbGoTop()

	oProcess:SetRegua2( TMPDIV->( RecCount() ) )

	Do While !TMPDIV->( Eof() )
		oProcess:IncRegua2("Produto: " + AllTrim( TMPDIV->B2_COD ) + " Local: " + AllTrim( TMPDIV->B2_LOCAL ))
		nAtencao++

		aAdd( aDiverg, {TMPDIV->STATUS, TMPDIV->DIVERGENCIA, TMPDIV->B2_FILIAL, TMPDIV->B2_COD, TMPDIV->B2_LOCAL, TMPDIV->B2_QFIM, TMPDIV->B2_CMFIM1, TMPDIV->B2_VFIM1 })

		TMPDIV->( dbSkip() )
	EndDo

	TMPDIV->( dbCloseArea() )

	cQuery := "SELECT 'Atenção' AS STATUS, 'Variação entre armazéns maior que 30%, Valor CM Menor: ' + RTRIM(LTRIM(CONVERT(VARCHAR(20), MIN(B2_CMFIM1)))) + ' Valor CM Maior: ' + RTRIM(LTRIM(CONVERT(VARCHAR(20), MAX(B2_CMFIM1)))) AS DIVERGENCIA, B2_FILIAL, B2_COD, '' AS B2_LOCAL, 0 AS B2_QFIM, 0 AS B2_CMFIM1, 0 AS B2_VFIM1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND B2_QFIM <> 0 " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY B2_FILIAL, B2_COD " + CRLF
	cQuery += "HAVING COUNT(*) > 1 AND MAX(B2_CMFIM1) > (MIN(B2_CMFIM1) * " + AllTrim(Replace(Str(1 + (nPerVar / 100)),",",".")) + ") " + CRLF

	TCQuery cQuery New Alias "TMPDIV"
	dbSelectArea("TMPDIV")
	dbGoTop()

	oProcess:SetRegua2( TMPDIV->( RecCount() ) )

	Do While !TMPDIV->( Eof() )
		oProcess:IncRegua2("Produto: " + AllTrim( TMPDIV->B2_COD ) + " Local: " + AllTrim( TMPDIV->B2_LOCAL ))
		nAtencao++

		aAdd( aDiverg, {TMPDIV->STATUS, TMPDIV->DIVERGENCIA, TMPDIV->B2_FILIAL, TMPDIV->B2_COD, TMPDIV->B2_LOCAL, TMPDIV->B2_QFIM, TMPDIV->B2_CMFIM1, TMPDIV->B2_VFIM1 })

		TMPDIV->( dbSkip() )
	EndDo

	TMPDIV->( dbCloseArea() )

	cQuery := "SELECT 'Baixo' AS STATUS, 'Variação Filial 01 maior que 30% CM da Filial ' + FIL.B2_FILIAL + ': ' + RTRIM(LTRIM(CONVERT(VARCHAR(20), FIL.B2_CM1))) + ' com a CM da Filial ' + SB2.B2_FILIAL + ': ' + RTRIM(LTRIM(CONVERT(VARCHAR(20), SB2.B2_CMFIM1))) AS DIVERGENCIA, SB2.B2_FILIAL, SB2.B2_COD, SB2.B2_LOCAL, SB2.B2_QFIM, SB2.B2_CMFIM1, SB2.B2_VFIM1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB2") + " AS FIL WITH (NOLOCK) ON FIL.B2_FILIAL <> SB2.B2_FILIAL " + CRLF
	cQuery += "  AND FIL.B2_COD = SB2.B2_COD " + CRLF
	cQuery += "  AND FIL.B2_LOCAL = SB2.B2_LOCAL " + CRLF
	cQuery += "  AND FIL.B2_QATU <> 0 " + CRLF
	cQuery += "  AND ABS(FIL.B2_CM1 - SB2.B2_CMFIM1) > (ABS(SB2.B2_CMFIM1) * " + AllTrim(Replace(Str(nPerVar / 100),",",".")) + ") " + CRLF
	cQuery += "  AND EXISTS (SELECT * FROM " + RetSqlName("SB9") + " WITH (NOLOCK) WHERE B9_FILIAL = FIL.B2_FILIAL AND B9_COD = FIL.B2_COD AND B9_LOCAL = FIL.B2_LOCAL AND B9_DATA = '" + DTOS( dUltFec ) + "' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "  AND FIL.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE SB2.B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND SB2.B2_QFIM <> 0 " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPDIV"
	dbSelectArea("TMPDIV")
	dbGoTop()

	oProcess:SetRegua2( TMPDIV->( RecCount() ) )

	Do While !TMPDIV->( Eof() )
		oProcess:IncRegua2("Produto: " + AllTrim( TMPDIV->B2_COD ) + " Local: " + AllTrim( TMPDIV->B2_LOCAL ))
		nBaixo++

		aAdd( aDiverg, {TMPDIV->STATUS, TMPDIV->DIVERGENCIA, TMPDIV->B2_FILIAL, TMPDIV->B2_COD, TMPDIV->B2_LOCAL, TMPDIV->B2_QFIM, TMPDIV->B2_CMFIM1, TMPDIV->B2_VFIM1 })

		TMPDIV->( dbSkip() )
	EndDo

	TMPDIV->( dbCloseArea() )
EndIf

oProcess:IncRegua1( "Custo Unitário acima de R$ [" + Transform(nLimCM,"@E 999,999,999.99") + "] (" + AllTrim(Extenso(nLimCM, .T.)) + ") e com valorização" )
Sleep( 10 )

If lCMAcima
	cQuery := "SELECT 'Atenção' AS STATUS, 'Custo Unitário acima de R$ [" + Transform(nLimCM,"@E 999,999,999.99") + "] (" + AllTrim(Extenso(nLimCM, .T.)) + ") e com valorização' AS DIVERGENCIA, B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM, B2_CMFIM1, B2_VFIM1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND (B2_CMFIM1 >= " + AllTrim(Replace(Str(nLimCM),",",".")) + ") " + CRLF
	cQuery += "AND B2_VFIM1 <> 0 " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPDIV"
	dbSelectArea("TMPDIV")
	dbGoTop()

	oProcess:SetRegua2( TMPDIV->( RecCount() ) )

	Do While !TMPDIV->( Eof() )
		oProcess:IncRegua2("Produto: " + AllTrim( TMPDIV->B2_COD ) + " Local: " + AllTrim( TMPDIV->B2_LOCAL ))
		nAtencao++

		aAdd( aDiverg, {TMPDIV->STATUS, TMPDIV->DIVERGENCIA, TMPDIV->B2_FILIAL, TMPDIV->B2_COD, TMPDIV->B2_LOCAL, TMPDIV->B2_QFIM, TMPDIV->B2_CMFIM1, TMPDIV->B2_VFIM1 })

		TMPDIV->( dbSkip() )
	EndDo

	TMPDIV->( dbCloseArea() )
EndIf

oProcess:IncRegua1( "Valor do Item acima de R$ [" + Transform(nLimValor,"@E 999,999,999.99") + "] (" + AllTrim(Extenso(nLimValor, .T.)) + ")" )
Sleep( 10 )

If lVlrAcima
	cQuery := "SELECT 'Atenção' AS STATUS, 'Valor do Item acima de R$ [" + Transform(nLimValor,"@E 999,999,999.99") + "] (" + AllTrim(Extenso(nLimValor, .T.)) + ")' AS DIVERGENCIA, B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM, B2_CMFIM1, B2_VFIM1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND (B2_VFIM1 >= " + AllTrim(Replace(Str(nLimValor),",",".")) + ") " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPDIV"
	dbSelectArea("TMPDIV")
	dbGoTop()

	oProcess:SetRegua2( TMPDIV->( RecCount() ) )

	Do While !TMPDIV->( Eof() )
		oProcess:IncRegua2("Produto: " + AllTrim( TMPDIV->B2_COD ) + " Local: " + AllTrim( TMPDIV->B2_LOCAL ))
		nAtencao++

		aAdd( aDiverg, {TMPDIV->STATUS, TMPDIV->DIVERGENCIA, TMPDIV->B2_FILIAL, TMPDIV->B2_COD, TMPDIV->B2_LOCAL, TMPDIV->B2_QFIM, TMPDIV->B2_CMFIM1, TMPDIV->B2_VFIM1 })

		TMPDIV->( dbSkip() )
	EndDo

	TMPDIV->( dbCloseArea() )
EndIf

oProcess:IncRegua1( "Nota Fiscal de Venda em " + cDesProx + " com valor menor que custo, Documento: ... Série: ... Cliente: ... Emissão: ... Preço: 9,99" )
Sleep( 10 )

If lNFSMenor
	cQuery := "SELECT 'Atenção' AS STATUS, 'Nota Fiscal de Venda em " + cDesProx + " com valor menor que custo, Documento: ' + D2_DOC + ' Série: ' + D2_SERIE + ' Cliente: ' + D2_CLIENTE + ' Emissão: ' + D2_EMISSAO + ' Preço: ' + RTRIM(LTRIM(CONVERT(VARCHAR(20), D2_PRCVEN))) AS DIVERGENCIA, B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM, B2_CMFIM1, B2_VFIM1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) ON D2_FILIAL = B2_FILIAL " + CRLF
	cQuery += "AND D2_COD = B2_COD " + CRLF
	cQuery += "AND D2_LOCAL = B2_LOCAL " + CRLF
	cQuery += "AND D2_TIPO = 'N' " + CRLF
	cQuery += "AND LEFT(D2_EMISSAO, 6) = '" + Left(DTOS(dProxFec), 6) + "' " + CRLF
	cQuery += "AND D2_PRCVEN <= B2_CMFIM1 " + CRLF
	cQuery += "AND (SUBSTRING(D2_CF, 2, 3) = '101' OR SUBSTRING(D2_CF, 2, 3) = '102' OR SUBSTRING(D2_CF, 2, 3) = '103') " + CRLF
	cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("SF4") + " WITH (NOLOCK) WHERE F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = D2_TES AND F4_ESTOQUE = 'S' AND F4_DUPLIC = 'S' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND SD2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPDIV"
	dbSelectArea("TMPDIV")
	dbGoTop()

	oProcess:SetRegua2( TMPDIV->( RecCount() ) )

	Do While !TMPDIV->( Eof() )
		oProcess:IncRegua2("Produto: " + AllTrim( TMPDIV->B2_COD ) + " Local: " + AllTrim( TMPDIV->B2_LOCAL ))
		nAtencao++

		aAdd( aDiverg, {TMPDIV->STATUS, TMPDIV->DIVERGENCIA, TMPDIV->B2_FILIAL, TMPDIV->B2_COD, TMPDIV->B2_LOCAL, TMPDIV->B2_QFIM, TMPDIV->B2_CMFIM1, TMPDIV->B2_VFIM1 })

		TMPDIV->( dbSkip() )
	EndDo

	TMPDIV->( dbCloseArea() )
EndIf

oProcess:IncRegua1( "Última compra com valor maior que o custo, Documento: ... Série: ... Fornecedor: ... Emissão: ... Preço: 9,99" )
Sleep( 10 )

If lNFEMaior
	cQuery := "SELECT 'Atenção' AS STATUS, 'Última compra com valor maior que o custo, Documento: ' + D1_DOC + ' Série: ' + D1_SERIE + ' Fornecedor: ' + D1_FORNECE + ' Emissão: ' + D1_DTDIGIT + ' Preço: ' + RTRIM(LTRIM(CONVERT(VARCHAR(20), D1_VUNIT))) AS DIVERGENCIA, B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM, B2_CMFIM1, B2_VFIM1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) ON D1_FILIAL = B2_FILIAL " + CRLF
	cQuery += "AND SD1.R_E_C_N_O_ IN (" + CRLF
	cQuery += "SELECT MAX(ULT.R_E_C_N_O_) FROM " + RetSqlName("SD1") + " AS ULT " + CRLF
	cQuery += "WHERE D1_FILIAL = B2_FILIAL " + CRLF
	cQuery += "AND D1_COD = B2_COD " + CRLF
	cQuery += "AND D1_LOCAL = B2_LOCAL " + CRLF
	cQuery += "AND D1_TIPO = 'N' " + CRLF
	cQuery += "AND D1_DTDIGIT <= '" + DTOS(dUltFec) + "' " + CRLF
	cQuery += "AND (SUBSTRING(D1_CF, 2, 3) = '101' OR SUBSTRING(D1_CF, 2, 3) = '102' OR SUBSTRING(D1_CF, 2, 3) = '103') " + CRLF
	cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("SF4") + " WITH (NOLOCK) WHERE F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' AND F4_DUPLIC = 'S' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += ")" + CRLF
	cQuery += "AND D1_VUNIT > B2_CMFIM1 " + CRLF
	cQuery += "AND SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND B2_QFIM > 0 " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPDIV"
	dbSelectArea("TMPDIV")
	dbGoTop()

	oProcess:SetRegua2( TMPDIV->( RecCount() ) )

	Do While !TMPDIV->( Eof() )
		oProcess:IncRegua2("Produto: " + AllTrim( TMPDIV->B2_COD ) + " Local: " + AllTrim( TMPDIV->B2_LOCAL ))
		nAtencao++

		aAdd( aDiverg, {TMPDIV->STATUS, TMPDIV->DIVERGENCIA, TMPDIV->B2_FILIAL, TMPDIV->B2_COD, TMPDIV->B2_LOCAL, TMPDIV->B2_QFIM, TMPDIV->B2_CMFIM1, TMPDIV->B2_VFIM1 })

		TMPDIV->( dbSkip() )
	EndDo

	TMPDIV->( dbCloseArea() )
EndIf

oProcess:IncRegua1( "Seg. UM divergente com a conversão, Fator: 9,99 Quantidade na Seg. UM: 9,99 Calculado: 9,99" )
Sleep( 10 )

If lDivSeg
	cQuery := "SELECT 'Baixo' AS STATUS, '[SB2 - Saldo Fechamento] Seg. UM divergente com a conversão, Fator: ' + CONVERT(VARCHAR(20), B1_CONV) + ' Quantidade na Seg. UM: ' + CONVERT(VARCHAR(20), B2_QFIM2) + ' Calculado: ' + CONVERT(VARCHAR(20), CASE WHEN B1_TIPCONV = 'M' THEN B2_QFIM * B1_CONV ELSE B2_QFIM / B1_CONV END) AS DIVERGENCIA, B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM, B2_CMFIM1, B2_VFIM1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "AND B1_COD = B2_COD " + CRLF
	cQuery += "AND B1_SEGUM <> '' " + CRLF
	cQuery += "AND B1_CONV <> 0 " + CRLF
	cQuery += "AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND (B2_QFIM <> 0 OR B2_QFIM2 <> 0) " + CRLF
	cQuery += "AND CONVERT(DECIMAL(20,2), CASE WHEN B1_TIPCONV = 'M' THEN B2_QFIM * B1_CONV ELSE B2_QFIM / B1_CONV END) <> CONVERT(DECIMAL(20,2), B2_QFIM2) " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT 'Baixo' AS STATUS, '[SB2 - Saldo Atual] Seg. UM divergente com a conversão, Fator: ' + CONVERT(VARCHAR(20), B1_CONV) + ' Quantidade na Seg. UM: ' + CONVERT(VARCHAR(20), B2_QTSEGUM) + ' Calculado: ' + CONVERT(VARCHAR(20), CASE WHEN B1_TIPCONV = 'M' THEN B2_QATU * B1_CONV ELSE B2_QATU / B1_CONV END) AS DIVERGENCIA, B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU, B2_CM1, B2_VATU1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "AND B1_COD = B2_COD " + CRLF
	cQuery += "AND B1_SEGUM <> '' " + CRLF
	cQuery += "AND B1_CONV <> 0 " + CRLF
	cQuery += "AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND (B2_QATU <> 0 OR B2_QTSEGUM <> 0) " + CRLF
	cQuery += "AND CONVERT(DECIMAL(20,2), CASE WHEN B1_TIPCONV = 'M' THEN B2_QATU * B1_CONV ELSE B2_QATU / B1_CONV END) <> CONVERT(DECIMAL(20,2), B2_QTSEGUM) " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT 'Baixo' AS STATUS, '[SB9 - Fechamento Saldo] Seg. UM divergente com a conversão, Fator: ' + CONVERT(VARCHAR(20), B1_CONV) + ' Quantidade na Seg. UM: ' + CONVERT(VARCHAR(20), B9_QISEGUM) + ' Calculado: ' + CONVERT(VARCHAR(20), CASE WHEN B1_TIPCONV = 'M' THEN B9_QINI * B1_CONV ELSE B9_QINI / B1_CONV END) AS DIVERGENCIA, B9_FILIAL, B9_COD, B9_LOCAL, B9_QINI, B9_CM1, B9_VINI1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB9") + " AS SB9 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "AND B1_COD = B9_COD " + CRLF
	cQuery += "AND B1_SEGUM <> '' " + CRLF
	cQuery += "AND B1_CONV <> 0 " + CRLF
	cQuery += "AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B9_FILIAL = '" + xFilial("SB9") + "' " + CRLF
	cQuery += "AND B9_DATA = '" + DTOS(dUltFec) + "' " + CRLF
	cQuery += "AND (B9_QINI <> 0 OR B9_QISEGUM <> 0) " + CRLF
	cQuery += "AND CONVERT(DECIMAL(20,2), CASE WHEN B1_TIPCONV = 'M' THEN B9_QINI * B1_CONV ELSE B9_QINI / B1_CONV END) <> CONVERT(DECIMAL(20,2), B9_QISEGUM) " + CRLF
	cQuery += "AND SB9.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT 'Baixo' AS STATUS, '[SB8 - Saldo Lote] Seg. UM divergente com a conversão, Fator: ' + CONVERT(VARCHAR(20), B1_CONV) + ' Quantidade na Seg. UM: ' + CONVERT(VARCHAR(20), B8_SALDO2) + ' Calculado: ' + CONVERT(VARCHAR(20), CASE WHEN B1_TIPCONV = 'M' THEN B8_SALDO * B1_CONV ELSE B8_SALDO / B1_CONV END) AS DIVERGENCIA, B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_SALDO, 0 B9_CM1, 0 B9_VINI1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "AND B1_COD = B8_PRODUTO " + CRLF
	cQuery += "AND B1_SEGUM <> '' " + CRLF
	cQuery += "AND B1_CONV <> 0 " + CRLF
	cQuery += "AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B8_FILIAL = '" + xFilial("SB8") + "' " + CRLF
	cQuery += "AND (B8_SALDO <> 0 OR B8_SALDO2 <> 0) " + CRLF
	cQuery += "AND CONVERT(DECIMAL(20,2), CASE WHEN B1_TIPCONV = 'M' THEN B8_SALDO * B1_CONV ELSE B8_SALDO / B1_CONV END) <> CONVERT(DECIMAL(20,2), B8_SALDO2) " + CRLF
	cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT 'Baixo' AS STATUS, '[SBJ - Fechamento Lote] Seg. UM divergente com a conversão, Fator: ' + CONVERT(VARCHAR(20), B1_CONV) + ' Quantidade na Seg. UM: ' + CONVERT(VARCHAR(20), BJ_QISEGUM) + ' Calculado: ' + CONVERT(VARCHAR(20), CASE WHEN B1_TIPCONV = 'M' THEN BJ_QINI * B1_CONV ELSE BJ_QINI / B1_CONV END) AS DIVERGENCIA, BJ_FILIAL, BJ_COD, BJ_LOCAL, BJ_QINI, 0 B9_CM1, 0 B9_VINI1 " + CRLF
	cQuery += "FROM " + RetSqlName("SBJ") + " AS SBJ WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "AND B1_COD = BJ_COD " + CRLF
	cQuery += "AND B1_SEGUM <> '' " + CRLF
	cQuery += "AND B1_CONV <> 0 " + CRLF
	cQuery += "AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE BJ_FILIAL = '" + xFilial("SBJ") + "' " + CRLF
	cQuery += "AND BJ_DATA = '" + DTOS(dUltFec) + "' " + CRLF
	cQuery += "AND (BJ_QINI <> 0 OR BJ_QISEGUM <> 0) " + CRLF
	cQuery += "AND CONVERT(DECIMAL(20,2), CASE WHEN B1_TIPCONV = 'M' THEN BJ_QINI * B1_CONV ELSE BJ_QINI / B1_CONV END) <> CONVERT(DECIMAL(20,2), BJ_QISEGUM) " + CRLF
	cQuery += "AND SBJ.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPDIV"
	dbSelectArea("TMPDIV")
	dbGoTop()

	oProcess:SetRegua2( TMPDIV->( RecCount() ) )

	Do While !TMPDIV->( Eof() )
		oProcess:IncRegua2("Produto: " + AllTrim( TMPDIV->B2_COD ) + " Local: " + AllTrim( TMPDIV->B2_LOCAL ))
		nBaixo++

		aAdd( aDiverg, {TMPDIV->STATUS, TMPDIV->DIVERGENCIA, TMPDIV->B2_FILIAL, TMPDIV->B2_COD, TMPDIV->B2_LOCAL, TMPDIV->B2_QFIM, TMPDIV->B2_CMFIM1, TMPDIV->B2_VFIM1 })

		TMPDIV->( dbSkip() )
	EndDo

	TMPDIV->( dbCloseArea() )
EndIf

oProcess:IncRegua1( "Saldo Poder De/Em Terceiros B6_SALDO: 9,99 diferente de acumulados B2_QTNP+B2_QTER+B2_QNPT: 9,99" )
Sleep( 10 )

If lEPodTer
	cQuery := "SELECT 'Atenção' AS STATUS, 'Saldo Poder De/Em Terceiros B6_SALDO: ' + CONVERT(VARCHAR(20), SUM(B6_SALDO)) + ' diferente de acumulados B2_QTNP+B2_QTER+B2_QNPT: ' + CONVERT(VARCHAR(20), B2_QTNP+B2_QTER+B2_QNPT) AS DIVERGENCIA, B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM, B2_CMFIM1, B2_VFIM1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB6") + " AS SB6 WITH (NOLOCK) ON B6_FILIAL = B2_FILIAL " + CRLF
	cQuery += "  AND B6_PRODUTO = B2_COD " + CRLF
	cQuery += "  AND B6_LOCAL = B2_LOCAL " + CRLF
	cQuery += "  AND B6_SALDO <> 0 " + CRLF
	cQuery += "  AND SB6.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND B2_QTNP <> 0 " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU, B2_QFIM, B2_CMFIM1, B2_VFIM1, B2_QTNP, B2_QTER, B2_QNPT " + CRLF
	cQuery += "HAVING SUM(B6_SALDO) <> (B2_QTNP + B2_QTER + B2_QNPT) " + CRLF

	TCQuery cQuery New Alias "TMPDIV"
	dbSelectArea("TMPDIV")
	dbGoTop()

	oProcess:SetRegua2( TMPDIV->( RecCount() ) )

	Do While !TMPDIV->( Eof() )
		oProcess:IncRegua2("Produto: " + AllTrim( TMPDIV->B2_COD ) + " Local: " + AllTrim( TMPDIV->B2_LOCAL ))
		nAtencao++

		aAdd( aDiverg, {TMPDIV->STATUS, TMPDIV->DIVERGENCIA, TMPDIV->B2_FILIAL, TMPDIV->B2_COD, TMPDIV->B2_LOCAL, TMPDIV->B2_QFIM, TMPDIV->B2_CMFIM1, TMPDIV->B2_VFIM1 })

		TMPDIV->( dbSkip() )
	EndDo

	TMPDIV->( dbCloseArea() )
EndIf

oProcess:IncRegua1( "Saldo De/Em Terceiros há mais de [" + Transform(nP3Dias,"@E 9,999") + "] dias" )
Sleep( 10 )

If lP3Dias
	cQuery := "SELECT 'Baixo' AS STATUS, 'Saldo em Poder de Terceiros há mais de [" + Transform(nP3Dias,"@E 9,999") + "] dias (' + CONVERT(VARCHAR(20),DATEDIFF(DD, CONVERT(DATETIME,B6_EMISSAO), GETDATE())) + ' dias), Emissão: ' + B6_EMISSAO AS DIVERGENCIA, B6_FILIAL B2_FILIAL, B6_PRODUTO B2_COD, B6_LOCAL B2_LOCAL, B6_SALDO B2_QFIM, B6_CUSTO1 B2_CMFIM1, B6_QUANT * B6_CUSTO1 B2_VFIM1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB6") + " AS SB6 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B6_FILIAL = '" + xFilial("SB6") + "' " + CRLF
	cQuery += "AND B6_TIPO = 'E' " + CRLF
	cQuery += "AND CONVERT(VARCHAR(20),DATEDIFF(DD, CONVERT(DATETIME,B6_EMISSAO), GETDATE())) > " + AllTrim(Replace(Str(nP3Dias),",",".")) + " " + CRLF
	cQuery += "AND B6_SALDO <> 0 " + CRLF
	cQuery += "AND SB6.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT 'Baixo' AS STATUS, 'De Terceiros em Nosso Poder há mais de 90 dias (' + CONVERT(VARCHAR(20),DATEDIFF(DD, CONVERT(DATETIME,B6_EMISSAO), GETDATE())) + ' dias), Emissão: ' + B6_EMISSAO AS DIVERGENCIA, B6_FILIAL B2_FILIAL, B6_PRODUTO B2_COD, B6_LOCAL B2_LOCAL, B6_SALDO B2_QFIM, B6_CUSTO1 B2_CMFIM1, B6_QUANT * B6_CUSTO1 B2_VFIM1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB6") + " AS SB6 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B6_FILIAL = '" + xFilial("SB6") + "' " + CRLF
	cQuery += "AND B6_TIPO = 'D' " + CRLF
	cQuery += "AND CONVERT(VARCHAR(20),DATEDIFF(DD, CONVERT(DATETIME,B6_EMISSAO), GETDATE())) > " + AllTrim(Replace(Str(nP3Dias),",",".")) + " " + CRLF
	cQuery += "AND B6_SALDO <> 0 " + CRLF
	cQuery += "AND SB6.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPDIV"
	dbSelectArea("TMPDIV")
	dbGoTop()

	oProcess:SetRegua2( TMPDIV->( RecCount() ) )

	Do While !TMPDIV->( Eof() )
		oProcess:IncRegua2("Produto: " + AllTrim( TMPDIV->B2_COD ) + " Local: " + AllTrim( TMPDIV->B2_LOCAL ))
		nBaixo++

		aAdd( aDiverg, {TMPDIV->STATUS, TMPDIV->DIVERGENCIA, TMPDIV->B2_FILIAL, TMPDIV->B2_COD, TMPDIV->B2_LOCAL, TMPDIV->B2_QFIM, TMPDIV->B2_CMFIM1, TMPDIV->B2_VFIM1 })

		TMPDIV->( dbSkip() )
	EndDo

	TMPDIV->( dbCloseArea() )
EndIf

oProcess:IncRegua1( "Movimentação Estoque no Período sem sequência de cálculo" )
Sleep( 10 )

If lMovRet
	cQuery := "SELECT 'Crítico' AS STATUS, '[SD1] Movimentação Estoque no Período sem sequência de cálculo, Documento: ' + D1_DOC + ' Série: ' + D1_SERIE + ' Fornecedor: ' + D1_FORNECE + ' Dt. Digit.: ' + D1_DTDIGIT + ' Tipo: ' + D1_TIPO + ' TES: ' + D1_TES AS DIVERGENCIA, B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM, B2_CMFIM1, B2_VFIM1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) ON D1_FILIAL = B2_FILIAL " + CRLF
	cQuery += "  AND D1_COD = B2_COD " + CRLF
	cQuery += "  AND D1_LOCAL = B2_LOCAL " + CRLF
	cQuery += "  AND LEFT(D1_DTDIGIT, 6) = '" + Left(DTOS(dProxFec), 6) + "' " + CRLF
	cQuery += "  AND EXISTS (SELECT * FROM " + RetSqlName("SF4") + " WITH (NOLOCK) WHERE F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "  AND D1_SEQCALC = '' " + CRLF
	cQuery += "  AND SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT 'Crítico' AS STATUS, '[SD2] Movimentação Estoque no Período sem sequência de cálculo, Documento: ' + D2_DOC + ' Série: ' + D2_SERIE + ' Cliente: ' + D2_CLIENTE + ' Emissão: ' + D2_EMISSAO + ' Tipo: ' + D2_TIPO + ' TES: ' + D2_TES AS DIVERGENCIA, B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM, B2_CMFIM1, B2_VFIM1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) ON D2_FILIAL = B2_FILIAL " + CRLF
	cQuery += "  AND D2_COD = B2_COD " + CRLF
	cQuery += "  AND D2_LOCAL = B2_LOCAL " + CRLF
	cQuery += "  AND LEFT(D2_EMISSAO, 6) = '" + Left(DTOS(dProxFec), 6) + "' " + CRLF
	cQuery += "  AND EXISTS (SELECT * FROM " + RetSqlName("SF4") + " WITH (NOLOCK) WHERE F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = D2_TES AND F4_ESTOQUE = 'S' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "  AND D2_SEQCALC = '' " + CRLF
	cQuery += "  AND SD2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT 'Crítico' AS STATUS, '[SD3] Movimentação Estoque no Período sem sequência de cálculo, Documento: ' + D3_DOC + ' CF: ' + D3_CF + ' Emissão: ' + D3_EMISSAO + ' TM: ' + D3_TM AS DIVERGENCIA, B2_FILIAL, B2_COD, B2_LOCAL, B2_QFIM, B2_CMFIM1, B2_VFIM1 " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD3") + " AS SD3 WITH (NOLOCK) ON D3_FILIAL = B2_FILIAL " + CRLF
	cQuery += "  AND D3_COD = B2_COD " + CRLF
	cQuery += "  AND D3_LOCAL = B2_LOCAL " + CRLF
	cQuery += "  AND LEFT(D3_EMISSAO, 6) = '" + Left(DTOS(dProxFec), 6) + "' " + CRLF
	cQuery += "  AND D3_SEQCALC = '' " + CRLF
	cQuery += "  AND SD3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPDIV"
	dbSelectArea("TMPDIV")
	dbGoTop()

	oProcess:SetRegua2( TMPDIV->( RecCount() ) )

	Do While !TMPDIV->( Eof() )
		oProcess:IncRegua2("Produto: " + AllTrim( TMPDIV->B2_COD ) + " Local: " + AllTrim( TMPDIV->B2_LOCAL ))
		nCritico++

		aAdd( aDiverg, {TMPDIV->STATUS, TMPDIV->DIVERGENCIA, TMPDIV->B2_FILIAL, TMPDIV->B2_COD, TMPDIV->B2_LOCAL, TMPDIV->B2_QFIM, TMPDIV->B2_CMFIM1, TMPDIV->B2_VFIM1 })

		TMPDIV->( dbSkip() )
	EndDo

	TMPDIV->( dbCloseArea() )
EndIf

// Analisar se há movimentações não contabilizadas...
cQuery := "SELECT TOP 1 'Crítico' AS STATUS, '[SD3] Há movimentações não contabilizadas, execute o custo médio contabilizando' AS DIVERGENCIA, '' B2_FILIAL, '' B2_COD, '' B2_LOCAL, 0 B2_QFIM, 0 B2_CMFIM1, 0 B2_VFIM1 " + CRLF
cQuery += "FROM " + RetSqlName("SD3") + " AS SD3 WITH (NOLOCK) " + CRLF
cQuery += "WHERE D3_FILIAL = '" + xFilial("SD3") + "' " + CRLF
cQuery += "AND LEFT(D3_EMISSAO, 6) = '" + Left(DTOS(dProxFec), 6) + "' " + CRLF
//cQuery += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("CV3") + " WHERE CV3_FILIAL <> '**' AND CV3_TABORI = 'SD3' AND CV3_RECORI = SD3.R_E_C_N_O_ AND D_E_L_E_T_ = ' ') " + CRLF
cQuery += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("CV3") + " WHERE CV3_FILIAL = D3_FILIAL AND LEFT(CV3_DTSEQ, 6) = '" + Left(DTOS(dProxFec), 6) + "' AND CV3_TABORI = 'SD3' AND CV3_RECORI = SD3.R_E_C_N_O_ AND D_E_L_E_T_ = ' ') " + CRLF
cQuery += "AND D3_CUSTO1 > 0.009 " + CRLF
cQuery += "AND SD3.D_E_L_E_T_ = ' ' " + CRLF

TCQuery cQuery New Alias "TMPDIV"
dbSelectArea("TMPDIV")
dbGoTop()

Do While !TMPDIV->( Eof() )
	nCritico++

	aAdd( aDiverg, {TMPDIV->STATUS, TMPDIV->DIVERGENCIA, TMPDIV->B2_FILIAL, TMPDIV->B2_COD, TMPDIV->B2_LOCAL, TMPDIV->B2_QFIM, TMPDIV->B2_CMFIM1, TMPDIV->B2_VFIM1 })

	TMPDIV->( dbSkip() )
EndDo

TMPDIV->( dbCloseArea() )

If Len( aDiverg ) == 0
	ApMsgInfo( "Não houveram divergências encontradas para geração da planilha", "Atenção" )
Else
	oProcess:IncRegua1( "Gerando Planilha de Divergências" )
	Sleep( 10 )

	cAssunto := 'Divergências de Estoque para Fechamento: ' + cDesProx
	
	_nFile := MsFCreate( cArquivo )
		
	cMensagem := ""
	aCabec    := {}
	aColunas  := {}
	aAdd( aColunas, {'Status'			   					, 05	, 'C'})
	aAdd( aColunas, {'Descrição'		   					, 35	, 'C'})
	aAdd( aColunas, {'Filial'			   					, 05	, 'C'})
	aAdd( aColunas, {'Produto'								, 15	, 'C'})
	aAdd( aColunas, {'Local'								, 05	, 'C'})
	aAdd( aColunas, {'Qtd. Final'							, 12	, 'C'})
	aAdd( aColunas, {'C.M. Final'							, 12	, 'C'})
	aAdd( aColunas, {'Valor Final'							, 12	, 'C'})

	cMensagem += U_BeHtmHead( '',.T.,aCabec, aColunas )
	
	FlushFile(_nFile, @cMensagem, 0)

	nLin := 0
	
	For nDiv := 1 To Len( aDiverg )
		nLin++

		oProcess:IncRegua2("Ocorrência: " + AllTrim( aDiverg[nDiv][02] ) + " Produto: " + AllTrim( aDiverg[nDiv][04] ) + " Local: " + AllTrim( aDiverg[nDiv][05] ))
	
		aColunas := {}
		aAdd( aColunas, {AllTrim( aDiverg[nDiv][01] )				   									, 05	, 'L'})
		aAdd( aColunas, {AllTrim( aDiverg[nDiv][02] )				  		  							, 35	, 'L'})
		aAdd( aColunas, {AllTrim( aDiverg[nDiv][03] )		 							  				, 05	, 'L'})
		aAdd( aColunas, {AllTrim( aDiverg[nDiv][04] )	   					 		  					, 15	, 'L'})
		aAdd( aColunas, {AllTrim( aDiverg[nDiv][05] )									  				, 05	, 'L'})
		aAdd( aColunas, {Transform( aDiverg[nDiv][06], "@E 999,999,999.99" )							, 12	, 'R'})
		aAdd( aColunas, {Transform( aDiverg[nDiv][07], "@E 999,999,999.99" )							, 12	, 'R'})
		aAdd( aColunas, {Transform( aDiverg[nDiv][08], "@E 999,999,999.99" )							, 12	, 'R'})
	
		cMensagem += U_BeHtmDet( aColunas, ((nLin % 2) == 0) , .F. )
	
		FlushFile(_nFile, @cMensagem, 0)
	Next

	cMensagem += U_BeHtmRod(.T.)

	FlushFile(_nFile, @cMensagem, 0)

	FClose(_nFile)

	ShellExecute( "open", AllTrim( cArquivo ), "", "C:\temp\", 1)
EndIf

If nCritico + nAtencao + nBaixo > 0
	ApMsgInfo('Houveram divergências: ' + CRLF + 'Críticos: ' + StrZero(nCritico, 5);
	                                    + CRLF + 'Atenção : ' + StrZero(nAtencao, 5);
	                                    + CRLF + 'Baixo   : ' + StrZero(nBaixo, 5),'Atenção')
Else
	ApMsgInfo('Não há divergências','Atenção')
EndIf

PutMV("MV_BE_FEPD",nP3Dias  )
PutMV("MV_BE_FEPV",nPerVar  )
PutMV("MV_BE_FELC",nLimCM   )
PutMV("MV_BE_FELV",nLimValor)

If (AllTrim( Upper( cUserName ) ) $ AllTrim( Upper( cUserParam ) ))
	PutMV("MV_BE_FELT",cLimTempo  )
	PutMV("MV_BE_FECR",lDivCrit   )
	PutMV("MV_BE_FERA",lRateioCTB )
	PutMV("MV_BE_FEPB",lPerBloq   )
	PutMV("MV_BE_FEFI",lFisBloq   )
	PutMV("MV_BE_FEPR",lProcFec   )
	PutMV("MV_BE_FERR",lProcRef   )
	PutMV("MV_BE_FECC",lCtbCompra )
	PutMV("MV_BE_FECF",lCtbFatur  )
	PutMV("MV_BE_FEFP",lCtbFolha  )
	PutMV("MV_BE_FEAT",lCtbAtivo  )
EndIf

Return

Static Function FlushFile(_nFile, cMsg, nMaxSize)

Default nMaxSize := 50 * 1024 //50KB

FWrite(_nFile, cMsg)
cMsg := ""

Return Nil

Static Function ValAdm( nOpcChk )

Local lRet := .T.

If !(AllTrim( Upper( cUserName ) ) $ AllTrim( Upper( cUserParam ) ))
	Do Case
		Case nOpcChk == 1
			If lDivCrit <> GetMv("MV_BE_FECR",, .T.)
				lRet       := .F.
				lDivCrit   := GetMv("MV_BE_FECR",, .T.)
				oDivCrit:CtrlRefresh()
			EndIf
		Case nOpcChk == 2
			If lRateioCTB <> GetMv("MV_BE_FERA",, .F.)
				lRet       := .F.
				lRateioCTB := GetMv("MV_BE_FERA",, .F.)
				oRateioCTB:CtrlRefresh()
			EndIf
		Case nOpcChk == 3
			If lCtbCompra <> GetMv("MV_BE_FECC",, .F.)
				lRet       := .F.
				lCtbCompra := GetMv("MV_BE_FECC",, .F.)
				oCtbCompra:CtrlRefresh()
			EndIf
		Case nOpcChk == 4
			If lCtbFatur <> GetMv("MV_BE_FECF",, .F.)
				lRet       := .F.
				lCtbFatur  := GetMv("MV_BE_FECF",, .F.)
				oCtbFatur:CtrlRefresh()
			EndIf
		Case nOpcChk == 5
			If lCtbAtivo <> GetMv("MV_BE_FEAT",, .F.)
				lRet       := .F.
				lCtbAtivo  := GetMv("MV_BE_FEAT",, .F.)
				oCtbAtivo:CtrlRefresh()
			EndIf
		Case nOpcChk == 6
			If lCtbFolha <> GetMv("MV_BE_FEFP",, .F.)
				lRet       := .F.
				lCtbFolha  := GetMv("MV_BE_FEFP",, .F.)
				oCtbFolha:CtrlRefresh()
			EndIf
		Case nOpcChk == 7
			If lPerBloq <> GetMv("MV_BE_FEPB",, .T.)
				lRet       := .F.
				lPerBloq   := GetMv("MV_BE_FEPB",, .T.)
				oPerBloq:CtrlRefresh()
			EndIf
		Case nOpcChk == 8
			If lFisBloq <> GetMv("MV_BE_FEFI",, .T.)
				lRet       := .F.
				lFisBloq   := GetMv("MV_BE_FEFI",, .T.)
				oFisBloq:CtrlRefresh()
			EndIf
		Case nOpcChk == 9
			If lProcRef <> GetMv("MV_BE_FERR",, .T.)
				lRet       := .F.
				lProcRef   := GetMv("MV_BE_FERR",, .T.)
				oProcRef:CtrlRefresh()
			EndIf
		Case nOpcChk == 10
			If lProcFec <> GetMv("MV_BE_FEPR",, .T.)
				lRet       := .F.
				lProcFec   := GetMv("MV_BE_FEPR",, .T.)
				oProcFec:CtrlRefresh()
			EndIf
		Case nOpcChk == 11
			If AllTrim( cLimTempo ) <> AllTrim( GetMv("MV_BE_FELT",, "0000 02:00:00") )
				lRet       := .F.
				cLimTempo  := GetMv("MV_BE_FELT",, "0000 02:00:00")
				oLimTempo:CtrlRefresh()
			EndIf
	EndCase
	If !lRet
		ApMsgAlert( 'Alteração da regra não permitida, favor solicitar alteração para administrador do sistema!', 'Permissão de Acesso')
	EndIf
EndIf

Return lRet

Static Function EQAcSegUM()

cQuery := "UPDATE " + RetSqlName("SB2") + " SET B2_QTSEGUM = CASE WHEN B1_TIPCONV = 'D' THEN B2_QATU / B1_CONV ELSE B2_QATU * B1_CONV END 
cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = B2_COD 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE B2_FILIAL <> '**' 
cQuery += "AND ABS(B2_QTSEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN B2_QATU / B1_CONV ELSE B2_QATU * B1_CONV END)) > 0.01 
cQuery += "AND SB2.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SB2") + " SET B2_QFIM2 = CASE WHEN B1_TIPCONV = 'D' THEN B2_QFIM / B1_CONV ELSE B2_QFIM * B1_CONV END 
cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = B2_COD 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE B2_FILIAL <> '**' 
cQuery += "AND ABS(B2_QFIM2 - (CASE WHEN B1_TIPCONV = 'D' THEN B2_QFIM / B1_CONV ELSE B2_QFIM * B1_CONV END)) > 0.01 
cQuery += "AND SB2.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SB2") + " SET B2_QEMPPR2 = CASE WHEN B1_TIPCONV = 'D' THEN B2_QEMPPRJ / B1_CONV ELSE B2_QEMPPRJ * B1_CONV END 
cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = B2_COD 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE B2_FILIAL <> '**' 
cQuery += "AND ABS(B2_QEMPPR2 - (CASE WHEN B1_TIPCONV = 'D' THEN B2_QEMPPRJ / B1_CONV ELSE B2_QEMPPRJ * B1_CONV END)) > 0.01 
cQuery += "AND SB2.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SB2") + " SET B2_QEPRE2 = CASE WHEN B1_TIPCONV = 'D' THEN B2_QEMPPRE / B1_CONV ELSE B2_QEMPPRE * B1_CONV END 
cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = B2_COD 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE B2_FILIAL <> '**' 
cQuery += "AND ABS(B2_QEPRE2 - (CASE WHEN B1_TIPCONV = 'D' THEN B2_QEMPPRE / B1_CONV ELSE B2_QEMPPRE * B1_CONV END)) > 0.01 
cQuery += "AND SB2.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SB2") + " SET B2_SALPED2 = CASE WHEN B1_TIPCONV = 'D' THEN B2_SALPEDI / B1_CONV ELSE B2_SALPEDI * B1_CONV END 
cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = B2_COD 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE B2_FILIAL <> '**' 
cQuery += "AND ABS(B2_SALPED2 - (CASE WHEN B1_TIPCONV = 'D' THEN B2_SALPEDI / B1_CONV ELSE B2_SALPEDI * B1_CONV END)) > 0.01 
cQuery += "AND SB2.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SB2") + " SET B2_QPEDVE2 = CASE WHEN B1_TIPCONV = 'D' THEN B2_QPEDVEN / B1_CONV ELSE B2_QPEDVEN * B1_CONV END 
cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = B2_COD 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE B2_FILIAL <> '**' 
cQuery += "AND ABS(B2_QPEDVE2 - (CASE WHEN B1_TIPCONV = 'D' THEN B2_QPEDVEN / B1_CONV ELSE B2_QPEDVEN * B1_CONV END)) > 0.01 
cQuery += "AND SB2.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SB2") + " SET B2_QEMPN2 = CASE WHEN B1_TIPCONV = 'D' THEN B2_QEMPN / B1_CONV ELSE B2_QEMPN * B1_CONV END 
cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = B2_COD 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE B2_FILIAL <> '**' 
cQuery += "AND ABS(B2_QEMPN2 - (CASE WHEN B1_TIPCONV = 'D' THEN B2_QEMPN / B1_CONV ELSE B2_QEMPN * B1_CONV END)) > 0.01 
cQuery += "AND SB2.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SB2") + " SET B2_QEMP2 = CASE WHEN B1_TIPCONV = 'D' THEN B2_QEMP / B1_CONV ELSE B2_QEMP * B1_CONV END 
cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = B2_COD 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE B2_FILIAL <> '**' 
cQuery += "AND ABS(B2_QEMP2 - (CASE WHEN B1_TIPCONV = 'D' THEN B2_QEMP / B1_CONV ELSE B2_QEMP * B1_CONV END)) > 0.01 
cQuery += "AND SB2.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SB2") + " SET B2_RESERV2 = CASE WHEN B1_TIPCONV = 'D' THEN B2_RESERVA / B1_CONV ELSE B2_RESERVA * B1_CONV END 
cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = B2_COD 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE B2_FILIAL <> '**' 
cQuery += "AND ABS(B2_RESERV2 - (CASE WHEN B1_TIPCONV = 'D' THEN B2_RESERVA / B1_CONV ELSE B2_RESERVA * B1_CONV END)) > 0.01 
cQuery += "AND SB2.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SB8") + " SET B8_SALDO2 = CASE WHEN B1_TIPCONV = 'D' THEN B8_SALDO / B1_CONV ELSE B8_SALDO * B1_CONV END 
cQuery += "FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = B8_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE B8_FILIAL <> '**' 
cQuery += "AND ABS(B8_SALDO2 - (CASE WHEN B1_TIPCONV = 'D' THEN B8_SALDO / B1_CONV ELSE B8_SALDO * B1_CONV END)) > 0.01 
cQuery += "AND SB8.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SB8") + " SET B8_QTDORI2 = CASE WHEN B1_TIPCONV = 'D' THEN B8_QTDORI / B1_CONV ELSE B8_QTDORI * B1_CONV END 
cQuery += "FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = B8_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE B8_FILIAL <> '**' 
cQuery += "AND ABS(B8_QTDORI2 - (CASE WHEN B1_TIPCONV = 'D' THEN B8_QTDORI / B1_CONV ELSE B8_QTDORI * B1_CONV END)) > 0.01 
cQuery += "AND SB8.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SD7") + " SET D7_SALDO2 = CASE WHEN B1_TIPCONV = 'D' THEN D7_SALDO / B1_CONV ELSE D7_SALDO * B1_CONV END 
cQuery += "FROM " + RetSqlName("SD7") + " AS SD7 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = D7_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE D7_FILIAL <> '**' 
cQuery += "AND ABS(D7_SALDO2 - (CASE WHEN B1_TIPCONV = 'D' THEN D7_SALDO / B1_CONV ELSE D7_SALDO * B1_CONV END)) > 0.01 
cQuery += "AND SD7.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SD7") + " SET D7_QTSEGUM = CASE WHEN B1_TIPCONV = 'D' THEN D7_QTDE / B1_CONV ELSE D7_QTDE * B1_CONV END 
cQuery += "FROM " + RetSqlName("SD7") + " AS SD7 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = D7_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE D7_FILIAL <> '**' 
cQuery += "AND ABS(D7_QTSEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN D7_QTDE / B1_CONV ELSE D7_QTDE * B1_CONV END)) > 0.01 
cQuery += "AND SD7.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SD1") + " SET D1_QTSEGUM = CASE WHEN B1_TIPCONV = 'D' THEN D1_QUANT / B1_CONV ELSE D1_QUANT * B1_CONV END 
cQuery += "FROM " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = D1_COD 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE D1_FILIAL <> '**' 
cQuery += "AND ABS(D1_QTSEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN D1_QUANT / B1_CONV ELSE D1_QUANT * B1_CONV END)) > 0.01 
cQuery += "AND SD1.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SD2") + " SET D2_QTSEGUM = CASE WHEN B1_TIPCONV = 'D' THEN D2_QUANT / B1_CONV ELSE D2_QUANT * B1_CONV END 
cQuery += "FROM " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = D2_COD 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE D2_FILIAL <> '**' 
cQuery += "AND ABS(D2_QTSEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN D2_QUANT / B1_CONV ELSE D2_QUANT * B1_CONV END)) > 0.01 
cQuery += "AND SD2.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SD3") + " SET D3_QTSEGUM = CASE WHEN B1_TIPCONV = 'D' THEN D3_QUANT / B1_CONV ELSE D3_QUANT * B1_CONV END 
cQuery += "FROM " + RetSqlName("SD3") + " AS SD3 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = D3_COD 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE D3_FILIAL <> '**' 
cQuery += "AND ABS(D3_QTSEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN D3_QUANT / B1_CONV ELSE D3_QUANT * B1_CONV END)) > 0.01 
cQuery += "AND SD3.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SD5") + " SET D5_QTSEGUM = CASE WHEN B1_TIPCONV = 'D' THEN D5_QUANT / B1_CONV ELSE D5_QUANT * B1_CONV END 
cQuery += "FROM " + RetSqlName("SD5") + " AS SD5 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = D5_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE D5_FILIAL <> '**' 
cQuery += "AND ABS(D5_QTSEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN D5_QUANT / B1_CONV ELSE D5_QUANT * B1_CONV END)) > 0.01 
cQuery += "AND SD5.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SB6") + " SET B6_QTSEGUM = CASE WHEN B1_TIPCONV = 'D' THEN B6_QUANT / B1_CONV ELSE B6_QUANT * B1_CONV END 
cQuery += "FROM " + RetSqlName("SB6") + " AS SB6 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = B6_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE B6_FILIAL <> '**' 
cQuery += "AND ABS(B6_QTSEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN B6_QUANT / B1_CONV ELSE B6_QUANT * B1_CONV END)) > 0.01 
cQuery += "AND SB6.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SB7") + " SET B7_QTSEGUM = CASE WHEN B1_TIPCONV = 'D' THEN B7_QUANT / B1_CONV ELSE B7_QUANT * B1_CONV END 
cQuery += "FROM " + RetSqlName("SB7") + " AS SB7 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = B7_COD 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE B7_FILIAL <> '**' 
cQuery += "AND ABS(B7_QTSEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN B7_QUANT / B1_CONV ELSE B7_QUANT * B1_CONV END)) > 0.01 
cQuery += "AND SB7.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SB9") + " SET B9_QISEGUM = CASE WHEN B1_TIPCONV = 'D' THEN B9_QINI / B1_CONV ELSE B9_QINI * B1_CONV END 
cQuery += "FROM " + RetSqlName("SB9") + " AS SB9 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = B9_COD 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE B9_FILIAL <> '**' 
cQuery += "AND ABS(B9_QISEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN B9_QINI / B1_CONV ELSE B9_QINI * B1_CONV END)) > 0.01 
cQuery += "AND SB9.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SBJ") + " SET BJ_QISEGUM = CASE WHEN B1_TIPCONV = 'D' THEN BJ_QINI / B1_CONV ELSE BJ_QINI * B1_CONV END 
cQuery += "FROM " + RetSqlName("SBJ") + " AS SBJ WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = BJ_COD 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE BJ_FILIAL <> '**' 
cQuery += "AND ABS(BJ_QISEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN BJ_QINI / B1_CONV ELSE BJ_QINI * B1_CONV END)) > 0.01 
cQuery += "AND SBJ.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SCQ") + " SET CQ_QTSEGUM = CASE WHEN B1_TIPCONV = 'D' THEN CQ_QUANT / B1_CONV ELSE CQ_QUANT * B1_CONV END 
cQuery += "FROM " + RetSqlName("SCQ") + " AS SCQ WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = CQ_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE CQ_FILIAL <> '**' 
cQuery += "AND ABS(CQ_QTSEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN CQ_QUANT / B1_CONV ELSE CQ_QUANT * B1_CONV END)) > 0.01 
cQuery += "AND SCQ.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SC7") + " SET C7_QTSEGUM = CASE WHEN B1_TIPCONV = 'D' THEN C7_QUANT / B1_CONV ELSE C7_QUANT * B1_CONV END 
cQuery += "FROM " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = C7_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE C7_FILIAL <> '**' 
cQuery += "AND ABS(C7_QTSEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN C7_QUANT / B1_CONV ELSE C7_QUANT * B1_CONV END)) > 0.01 
cQuery += "AND SC7.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SC8") + " SET C8_QTSEGUM = CASE WHEN B1_TIPCONV = 'D' THEN C8_QUANT / B1_CONV ELSE C8_QUANT * B1_CONV END 
cQuery += "FROM " + RetSqlName("SC8") + " AS SC8 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = C8_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE C8_FILIAL <> '**' 
cQuery += "AND ABS(C8_QTSEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN C8_QUANT / B1_CONV ELSE C8_QUANT * B1_CONV END)) > 0.01 
cQuery += "AND SC8.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SC1") + " SET C1_QTSEGUM = CASE WHEN B1_TIPCONV = 'D' THEN C1_QUANT / B1_CONV ELSE C1_QUANT * B1_CONV END 
cQuery += "FROM " + RetSqlName("SC1") + " AS SC1 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = C1_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE C1_FILIAL <> '**' 
cQuery += "AND ABS(C1_QTSEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN C1_QUANT / B1_CONV ELSE C1_QUANT * B1_CONV END)) > 0.01 
cQuery += "AND SC1.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SC2") + " SET C2_QTSEGUM = CASE WHEN B1_TIPCONV = 'D' THEN C2_QUANT / B1_CONV ELSE C2_QUANT * B1_CONV END 
cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = C2_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE C2_FILIAL <> '**' 
cQuery += "AND ABS(C2_QTSEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN C2_QUANT / B1_CONV ELSE C2_QUANT * B1_CONV END)) > 0.01 
cQuery += "AND SC2.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SCP") + " SET CP_QTSEGUM = CASE WHEN B1_TIPCONV = 'D' THEN CP_QUANT / B1_CONV ELSE CP_QUANT * B1_CONV END 
cQuery += "FROM " + RetSqlName("SCP") + " AS SCP WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = CP_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE CP_FILIAL <> '**' 
cQuery += "AND ABS(CP_QTSEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN CP_QUANT / B1_CONV ELSE CP_QUANT * B1_CONV END)) > 0.01 
cQuery += "AND SCP.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SCY") + " SET CY_QTSEGUM = CASE WHEN B1_TIPCONV = 'D' THEN CY_QUANT / B1_CONV ELSE CY_QUANT * B1_CONV END 
cQuery += "FROM " + RetSqlName("SCY") + " AS SCY WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = CY_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE CY_FILIAL <> '**' 
cQuery += "AND ABS(CY_QTSEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN CY_QUANT / B1_CONV ELSE CY_QUANT * B1_CONV END)) > 0.01 
cQuery += "AND SCY.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SD4") + " SET D4_QTSEGUM = CASE WHEN B1_TIPCONV = 'D' THEN D4_QUANT / B1_CONV ELSE D4_QUANT * B1_CONV END 
cQuery += "FROM " + RetSqlName("SD4") + " AS SD4 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = D4_COD 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE D4_FILIAL <> '**' 
cQuery += "AND ABS(D4_QTSEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN D4_QUANT / B1_CONV ELSE D4_QUANT * B1_CONV END)) > 0.01 
cQuery += "AND SD4.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SC3") + " SET C3_QTSEGUM = CASE WHEN B1_TIPCONV = 'D' THEN C3_QUANT / B1_CONV ELSE C3_QUANT * B1_CONV END 
cQuery += "FROM " + RetSqlName("SC3") + " AS SC3 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = C3_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE C3_FILIAL <> '**' 
cQuery += "AND ABS(C3_QTSEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN C3_QUANT / B1_CONV ELSE C3_QUANT * B1_CONV END)) > 0.01 
cQuery += "AND SC3.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SC6") + " SET C6_UNSVEN = CASE WHEN B1_TIPCONV = 'D' THEN C6_QTDVEN / B1_CONV ELSE C6_QTDVEN * B1_CONV END 
cQuery += "FROM " + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = C6_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE C6_FILIAL <> '**' 
cQuery += "AND ABS(C6_UNSVEN - (CASE WHEN B1_TIPCONV = 'D' THEN C6_QTDVEN / B1_CONV ELSE C6_QTDVEN * B1_CONV END)) > 0.01 
cQuery += "AND SC6.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SC6") + " SET C6_QTDLIB2 = CASE WHEN B1_TIPCONV = 'D' THEN C6_QTDLIB / B1_CONV ELSE C6_QTDLIB * B1_CONV END 
cQuery += "FROM " + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = C6_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE C6_FILIAL <> '**' 
cQuery += "AND ABS(C6_QTDLIB2 - (CASE WHEN B1_TIPCONV = 'D' THEN C6_QTDLIB / B1_CONV ELSE C6_QTDLIB * B1_CONV END)) > 0.01 
cQuery += "AND SC6.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SC6") + " SET C6_QTDENT2 = CASE WHEN B1_TIPCONV = 'D' THEN C6_QTDENT / B1_CONV ELSE C6_QTDENT * B1_CONV END 
cQuery += "FROM " + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = C6_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE C6_FILIAL <> '**' 
cQuery += "AND ABS(C6_QTDENT2 - (CASE WHEN B1_TIPCONV = 'D' THEN C6_QTDENT / B1_CONV ELSE C6_QTDENT * B1_CONV END)) > 0.01 
cQuery += "AND SC6.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SC6") + " SET C6_QTDEMP2 = CASE WHEN B1_TIPCONV = 'D' THEN C6_QTDEMP / B1_CONV ELSE C6_QTDEMP * B1_CONV END 
cQuery += "FROM " + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = C6_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE C6_FILIAL <> '**' 
cQuery += "AND ABS(C6_QTDEMP2 - (CASE WHEN B1_TIPCONV = 'D' THEN C6_QTDEMP / B1_CONV ELSE C6_QTDEMP * B1_CONV END)) > 0.01 
cQuery += "AND SC6.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SC9") + " SET C9_QTDLIB2 = CASE WHEN B1_TIPCONV = 'D' THEN C9_QTDLIB / B1_CONV ELSE C9_QTDLIB * B1_CONV END 
cQuery += "FROM " + RetSqlName("SC9") + " AS SC9 WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = C9_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE C9_FILIAL <> '**' 
cQuery += "AND ABS(C9_QTDLIB2 - (CASE WHEN B1_TIPCONV = 'D' THEN C9_QTDLIB / B1_CONV ELSE C9_QTDLIB * B1_CONV END)) > 0.01 
cQuery += "AND SC9.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SBC") + " SET BC_QTSEGUM = CASE WHEN B1_TIPCONV = 'D' THEN BC_QUANT / B1_CONV ELSE BC_QUANT * B1_CONV END 
cQuery += "FROM " + RetSqlName("SBC") + " AS SBC WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = BC_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE BC_FILIAL <> '**' 
cQuery += "AND ABS(BC_QTSEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN BC_QUANT / B1_CONV ELSE BC_QUANT * B1_CONV END)) > 0.01 
cQuery += "AND SBC.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SBF") + " SET BF_QTSEGUM = CASE WHEN B1_TIPCONV = 'D' THEN BF_QUANT / B1_CONV ELSE BF_QUANT * B1_CONV END 
cQuery += "FROM " + RetSqlName("SBF") + " AS SBF WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = BF_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE BF_FILIAL <> '**' 
cQuery += "AND ABS(BF_QTSEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN BF_QUANT / B1_CONV ELSE BF_QUANT * B1_CONV END)) > 0.01 
cQuery += "AND SBF.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SBK") + " SET BK_QISEGUM = CASE WHEN B1_TIPCONV = 'D' THEN BK_QINI / B1_CONV ELSE BK_QINI * B1_CONV END 
cQuery += "FROM " + RetSqlName("SBK") + " AS SBK WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = BK_COD 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE BK_FILIAL <> '**' 
cQuery += "AND ABS(BK_QISEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN BK_QINI / B1_CONV ELSE BK_QINI * B1_CONV END)) > 0.01 
cQuery += "AND SBK.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SDA") + " SET DA_QTDORI2 = CASE WHEN B1_TIPCONV = 'D' THEN DA_QTDORI / B1_CONV ELSE DA_QTDORI * B1_CONV END 
cQuery += "FROM " + RetSqlName("SDA") + " AS SDA WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = DA_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE DA_FILIAL <> '**' 
cQuery += "AND ABS(DA_QTDORI2 - (CASE WHEN B1_TIPCONV = 'D' THEN DA_QTDORI / B1_CONV ELSE DA_QTDORI * B1_CONV END)) > 0.01 
cQuery += "AND SDA.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SDA") + " SET DA_QTSEGUM = CASE WHEN B1_TIPCONV = 'D' THEN DA_SALDO / B1_CONV ELSE DA_SALDO * B1_CONV END 
cQuery += "FROM " + RetSqlName("SDA") + " AS SDA WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = DA_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE DA_FILIAL <> '**' 
cQuery += "AND ABS(DA_QTSEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN DA_SALDO / B1_CONV ELSE DA_SALDO * B1_CONV END)) > 0.01 
cQuery += "AND SDA.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SDA") + " SET DA_EMP2 = CASE WHEN B1_TIPCONV = 'D' THEN DA_EMPENHO / B1_CONV ELSE DA_EMPENHO * B1_CONV END 
cQuery += "FROM " + RetSqlName("SDA") + " AS SDA WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = DA_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE DA_FILIAL <> '**' 
cQuery += "AND ABS(DA_EMP2 - (CASE WHEN B1_TIPCONV = 'D' THEN DA_EMPENHO / B1_CONV ELSE DA_EMPENHO * B1_CONV END)) > 0.01 
cQuery += "AND SDA.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SDB") + " SET DB_QTSEGUM = CASE WHEN B1_TIPCONV = 'D' THEN DB_QUANT / B1_CONV ELSE DB_QUANT * B1_CONV END 
cQuery += "FROM " + RetSqlName("SDB") + " AS SDB WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = DB_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE DB_FILIAL <> '**' 
cQuery += "AND ABS(DB_QTSEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN DB_QUANT / B1_CONV ELSE DB_QUANT * B1_CONV END)) > 0.01 
cQuery += "AND SDB.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SDB") + " SET DB_EMP2 = CASE WHEN B1_TIPCONV = 'D' THEN DB_EMPENHO / B1_CONV ELSE DB_EMPENHO * B1_CONV END 
cQuery += "FROM " + RetSqlName("SDB") + " AS SDB WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = DB_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE DB_FILIAL <> '**' 
cQuery += "AND ABS(DB_EMP2 - (CASE WHEN B1_TIPCONV = 'D' THEN DB_EMPENHO / B1_CONV ELSE DB_EMPENHO * B1_CONV END)) > 0.01 
cQuery += "AND SDB.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

cQuery := "UPDATE " + RetSqlName("SDC") + " SET DC_QTSEGUM = CASE WHEN B1_TIPCONV = 'D' THEN DC_QUANT / B1_CONV ELSE DC_QUANT * B1_CONV END 
cQuery += "FROM " + RetSqlName("SDC") + " AS SDC WITH (NOLOCK) 
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' 
cQuery += "  AND B1_COD = DC_PRODUTO 
cQuery += "  AND B1_SEGUM <> ''  
cQuery += "  AND B1_CONV <> 0 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' 
cQuery += "WHERE DC_FILIAL <> '**' 
cQuery += "AND ABS(DC_QTSEGUM - (CASE WHEN B1_TIPCONV = 'D' THEN DC_QUANT / B1_CONV ELSE DC_QUANT * B1_CONV END)) > 0.01 
cQuery += "AND SDC.D_E_L_E_T_ = ' ' 

TCSqlExec( cQuery )

Return