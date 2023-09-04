#INCLUDE "Protheus.ch"
#INCLUDE "RptDef.ch"  
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TopConn.ch"

#DEFINE	 IMP_DISCO 	1
#DEFINE	 IMP_SPOOL 	2
#DEFINE	 IMP_EMAIL 	3
#DEFINE	 IMP_EXCEL 	4
#DEFINE	 IMP_HTML  	5
#DEFINE	 IMP_PDF   	6 

#DEFINE	 NMINLIN	030
#DEFINE  NMINCOL	020
#DEFINE	 NMAXLIN   	800
#DEFINE	 NMAXCOL   	570

#DEFINE	 REL_NAME	"Ordem de Separação"
#DEFINE  REL_PATH	GetTempPath() 

#DEFINE	 XCOD	01
#DEFINE	 XLOJA	02
#DEFINE	 XNOME	03
#DEFINE	 XEND	04
#DEFINE	 XMUN	05
#DEFINE	 XEST	06
#DEFINE	 XINSCR	07
#DEFINE	 XCEP 	08
#DEFINE	 XCGC	09
#DEFINE	 XTEL	10
#DEFINE	 XBAIR	11
#DEFINE	 XENDENT	12
#DEFINE	 XBAIRROE	13
#DEFINE	 XMUNE		14
#DEFINE	 XESTE		15
#DEFINE	 XCEPE		16

// alterado em 20/01/2022 - fabio carneiro dos santos 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³BeROrdSep ³ Autor ³ Rodrigo Sousa         ³ Data ³ 02/06/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ³±±
±±³Descri‡…o ³ Impressão da Ordem de Separação							  ³±±
±±³          ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ 						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function EQOrdSep()

Private oPrn 		:= Nil
Private oSetup		:= Nil
Private oFont07,oFont07n,oFont08,oFont08n,oFont09,oFont09n,oFont10,oFont10n,oFont11,oFont11n,oFont12,oFont12n,oFont12c,oFont12cn,oFont14,oFont14n

Private cPerg		:= "EQOS01"	

ValidPerg()
If !Pergunte(cPerg, .T.)
	ApMsgInfo('Relatório Cancelado!', 'Atenção')
	Return
EndIf 

If PrepPrint() 
	RptStatus({|| ExecPrint() },"Imprimindo Ordem de Separação...")
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PrepPrint ³ Autor ³ Rodrigo Sousa         ³ Data ³ 02/06/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Parametros da rotina.                					   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrepPrint(cPathDest,cRelName)

Local lRet 	:= .T.

Local cPathDest   := GetTempPath() //REL_PATH
Local cRelName	:= "OrdSep_"+MV_PAR01+MV_PAR02

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Instancia os objetos de fonte   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFont07n := TFont():New( "Arial",, 07,,.T.)
oFont07  := TFont():New( "Arial",, 07,,.F.)
oFont08n := TFont():New( "Arial",, 08,,.T.)
oFont08  := TFont():New( "Arial",, 08,,.F.)
oFont09  := TFont():New( "Arial",, 09,,.F.)
oFont09n := TFont():New( "Arial",, 09,,.T.)
oFont10n := TFont():New( "Arial",, 10,,.T.)
oFont10  := TFont():New( "Courier New",, 10,,.F.)
oFont11  := TFont():New( "Courier New",, 11,,.F.)
oFont11n := TFont():New( "Courier New",, 11,,.T.)
oFont12c  := TFont():New( "Courier New",, 12,,.F.)
oFont12cn := TFont():New( "Courier New",, 12,,.T.)
oFont12n := TFont():New( "Arial",, 12,,.T.)
oFont12  := TFont():New( "Arial",, 12,,.F.)
oFont14n := TFont():New( "Arial",, 14,,.T.)
oFont14  := TFont():New( "Arial",, 14,,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Instancia a Classe FwMsPrinter  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrn := FwMsPrinter():New(cRelName,IMP_PDF,.F.,cPathDest,.T.,.F.,@oPrn,,,.F.,.F.,.T.,)
//oPrn 	:= FWMSPrinter():New("DANFE", IMP_PDF)
oPrn:SetResolution(72)
oPrn:SetLandscape()
oPrn:SetPortrait()
oPrn:SetPaperSize(DMPAPER_A4)

//oPrn:cPathPDF := cPathDest 			//Caso seja utilizada impressão em IMP_PDF      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Instancia a Classe FWPrintSetup ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSetup := FWPrintSetup():New(PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION+PD_DISABLEDESTINATION+PD_DISABLEPAPERSIZE+PD_DISABLEPREVIEW ,"OS")
oSetup:SetUserParms({|| Pergunte(cPerg, .T.)})
oSetup:SetProperty(PD_MARGIN,{05,05,05,05})
oSetup:SetProperty(PD_DESTINATION,2) 
oSetup:SetProperty(PD_PRINTTYPE,IMP_PDF)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ativa Tela de Setup		  	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oSetup:Activate() == 2
	lRet	:= .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ExecPrint   ³ Autor ³ Rodrigo Sousa        ³ Data ³ 02/06/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa Impressão.             		  	     				³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ExecPrint()

Local lProc			:= .T.

CB7->(DbSetOrder(1))
CB7->(DbSeek(xFilial("CB7")+MV_PAR01,.T.)) // Posiciona no 1o.reg. satisfatorio 

SetRegua(RecCount())

While ! CB7->(EOF()) .and. (CB7->CB7_ORDSEP >= MV_PAR01 .and. CB7->CB7_ORDSEP <= MV_PAR02)
	If CB7->CB7_DTEMIS < MV_PAR03 .or. CB7->CB7_DTEMIS > MV_PAR04 // Nao considera as ordens que nao tiver dentro do range de datas 
		CB7->(DbSkip())
		Loop
	Endif
	If MV_PAR05 == 2 .and. CB7->CB7_STATUS == "9" // Nao Considera as Ordens ja encerradas
		CB7->(DbSkip())
		Loop
	Endif
	CB8->(DbSetOrder(1))
	If ! CB8->(DbSeek(xFilial("CB8")+CB7->CB7_ORDSEP))
		CB7->(DbSkip())
		Loop
	EndIf
	IncRegua("Imprimindo") 
	RunPrint() 
	lProc	:= .T.
	CB7->(DbSkip())
Enddo

If lProc
	StartPrint()
Else
	ApMsgInfo('Não há dados!', 'Qualyvinil')
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RunPrint  ³ Autor ³ Rodrigo Sousa         ³ Data ³ 02/10/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Parametros da rotina.                					   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RunPrint()

Local nPixLin	:= NMINLIN
Local nPixCol	:= NMINCOL                  
Local nPage		:= 1                        

Local lSaida	:= .F.
Local aItens	:= {}
Local nX        := 0

Private cOrdSep 	:= Alltrim(CB7->CB7_ORDSEP)
Private cPedido 	:= Alltrim(CB7->CB7_PEDIDO)
Private cCliente	:= Alltrim(CB7->CB7_CLIENT)
Private cLoja   	:= Alltrim(CB7->CB7_LOJA)
Private cNota   	:= Alltrim(CB7->CB7_NOTA)
Private cSerie  	:= Alltrim(CB7->CB7_SERIE)
Private cOP     	:= Alltrim(CB7->CB7_OP)
Private cStatus 	:= RetStatus(CB7->CB7_STATUS)
Private cAliasCF	:= ""
Private cUMAtual	:= ""
Private aDadosCli	:= Array(16)
Private _cTrocaUn   := GetMV("QE_TROCAUN") // Este parametro troca a unidade de medida na impressão do item 
Private _cUnidade   := "" 

If CB7->CB7_ORIGEM $ "1|2"  
	lSaida	:= .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Itens da Nota Fiscal de Saida ou Pedido de Venda	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lSaida

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona tabelas											   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CB8->(DbSetOrder(7))
	CB8->(DbSeek(xFilial("CB8")+cOrdSep))

	dbSelectArea("SC5")
	dbSetOrder(1)
	dbSeek(xFilial("SC5")+CB8->CB8_PEDIDO)

	DbSelectArea("SA4")
	DbSetOrder(1)
	Dbseek(xFilial("SA4")+SC5->C5_TRANSP)

	DbSelectArea("SA3")
	dbSetOrder(1)
	Dbseek(xFilial("SA3")+SC5->C5_VEND1)

	DbSelectArea("SE4")
	dbSetOrder(1)
	Dbseek(xFilial("SE4")+SC5->C5_CONDPAG)

	DbSelectArea("SF2")
	dbSetOrder(1)
	DbSeek(xFilial("SF2") + CB7->(CB7_NOTA + CB7_SERIE + CB7_CLIENT + CB7_LOJA))

	cPedido := SC5->C5_NUM

	If !SC5->C5_TIPO $ "BD"
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+cCliente+cLoja)
		
		aDadosCli[XCOD]		:= SA1->A1_COD
		aDadosCli[XLOJA]	:= SA1->A1_LOJA
		aDadosCli[XNOME]	:= SA1->A1_NOME
		aDadosCli[XEND]		:= SA1->A1_END
		aDadosCli[XMUN]		:= SA1->A1_MUN
		aDadosCli[XEST]		:= SA1->A1_EST
		aDadosCli[XINSCR]	:= SA1->A1_INSCR
		aDadosCli[XCEP]		:= SA1->A1_CEP
		aDadosCli[XCGC]		:= Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
		aDadosCli[XTEL]		:= SA1->A1_TEL
		aDadosCli[XBAIR]	:= SA1->A1_BAIRRO

		aDadosCli[XENDENT]	:= SA1->A1_ENDENT
		aDadosCli[XBAIRROE]	:= SA1->A1_BAIRROE
		aDadosCli[XMUNE]	:= SA1->A1_MUNE
		aDadosCli[XESTE]	:= SA1->A1_ESTE
		aDadosCli[XCEPE]	:= SA1->A1_CEPE

	Else
		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSeek(xFilial("SA2")+cCliente+cLoja)

		aDadosCli[XCOD]		:= SA2->A2_COD
		aDadosCli[XLOJA]	:= SA2->A2_LOJA
		aDadosCli[XNOME]	:= SA2->A2_NOME
		aDadosCli[XEND]		:= SA2->A2_END
		aDadosCli[XMUN]		:= SA2->A2_MUN
		aDadosCli[XEST]		:= SA2->A2_EST
		aDadosCli[XINSCR]	:= SA2->A2_INSCR
		aDadosCli[XCEP]		:= SA2->A2_CEP
		aDadosCli[XCGC]		:= Transform(SA2->A2_CGC,"@R 99.999.999/9999-99")
		aDadosCli[XTEL]		:= SA2->A2_TEL
		aDadosCli[XBAIR]	:= SA2->A2_BAIRRO

		aDadosCli[XENDENT]	:= "" 
		aDadosCli[XBAIRROE]	:= ""
		aDadosCli[XMUNE]	:= ""
		aDadosCli[XESTE]	:= ""
		aDadosCli[XCEPE]	:= ""
    EndIf
    

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Cabeçalho da Ordem de Separação						   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPixLin			:= CabPrint(nPage,lSaida,aDadosCli)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Cabeçalho dos Itens da Ordem de Separação			   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPixLin := CabPrIt(nPixLin,nPixCol,lSaida)

	While ! CB8->(EOF()) .and. (CB8->CB8_FILIAL+CB8->CB8_ORDSEP == xFilial("CB8")+cOrdSep)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Itens da Nota Fiscal de Saida ou Pedido de Venda	   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xFilial("SC6")+CB8->CB8_PEDIDO+CB8->CB8_ITEM+CB8->CB8_PROD)

		dbSelectArea("SB8")
		dbsetorder(3)
		dbSeek(xFilial("SB8")+CB8->CB8_PROD+CB8->CB8_LOCAL+CB8->CB8_LOTECT)

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+CB8->CB8_PROD)

		If Substr(_cTrocaUn,1,11) $ Alltrim(CB8->CB8_PROD)
			_cUnidade := Substr(_cTrocaUn,13,2)   
		Else 
			_cUnidade := SB1->B1_UM 
		EndIf 
		
		aAdd(aItens,{CB8->CB8_PROD,;
					 Substr(SB1->B1_DESC,1,15)+" Eb("+Alltrim(Transform(SB1->B1_XQTDEXP,"@E 999999"))+")",;
					 Alltrim(Transform(CB8->CB8_QTDORI,"@E 9,999,999")),;
					 _cUnidade,;
					 CB8->CB8_LOCAL,;
					 CB8->CB8_LCALIZ,;
					 CB8->CB8_LOTECT,;
					 (Transform(CB8->CB8_SALDOS,"@E 999,999.999"))})

    	CB8->(dbSkip())

		 _cUnidade := ""
	
	EndDo

	For nX := 1 to Len(aItens)

		nPixLin := IncLinTb(nPixLin,nPixCol)
		oPrn:Say(nPixLin		,nPixCol+005	,aItens[nX][01]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+095	,aItens[nX][02]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+315	,aItens[nX][03]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+360	,aItens[nX][04]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+390	,aItens[nX][05]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+420	,aItens[nX][06]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+480	,aItens[nX][07]	,oFont12c,,)

		If nPixLin > 650 
			nPage := RodaImp(nPage,nPixLin,nPixCol)
			nPixLin	:= CabPrint(nPage,lSaida,aDadosCli)
			nPixLin := CabPrIt(nPixLin,nPixCol,lSaida)
        EndIf

	Next nX
	
	nPage := RodaImp(nPage,nPixLin,nPixCol)			

Else

	//CB8->(DbSetOrder(1))
	CB8->(DbSetOrder(7))
	CB8->(DbSeek(xFilial("CB8")+cOrdSep))

	aItens := {}

	// Imprime Itens da Nota Fiscal de Saida ou Pedido de Venda
	dbSelectArea("SC2")
	dbSetOrder(1)
	dbSeek(xFilial("SC2")+cOP)
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+CB8->CB8_PROD)

	//Imprime Cabeçalho da Ordem de Separação
	nPixLin			:= CabPrint(nPage,lSaida,{})

	dbSelectArea("SC2")
	dbSetOrder(1)
	dbSeek(xFilial("SC2")+cOP)
	
	cQuery := "SELECT G2_OPERAC, G2_RECURSO, G2_DESCRI "
	cQuery += "FROM " + RetSqlName("SG2") + " AS SG2 WITH (NOLOCK) "
	cQuery += "INNER JOIN " + RetSqlName("SH1") + " AS SH1 WITH (NOLOCK) ON H1_FILIAL = '" + xFilial("SH1") + "' "
	cQuery += "  AND H1_CODIGO = G2_RECURSO "
	cQuery += "  AND SH1.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("SHB") + " AS SHB WITH (NOLOCK) ON HB_FILIAL = '" + xFilial("SHB") + "' "
	cQuery += "  AND HB_COD = G2_CTRAB "
	cQuery += "  AND SHB.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE G2_FILIAL = '" + xFilial("SG2") + "' "
	cQuery += "AND G2_CODIGO = '01' " 
	cQuery += "AND G2_OPERAC = '10' "
	cQuery += "AND G2_PRODUTO = '" + SC2->C2_PRODUTO + "' " 
	cQuery += "AND SG2.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY G2_OPERAC "
	
	TCQuery cQuery New Alias "TMPROT"
	dbSelectArea("TMPROT")
	dbGoTop()
	
	nPixLin += 008
	
	Do While !TMPROT->( Eof() )
		oPrn:Say(nPixLin+=10,nPixCol+050,PadC("OPERAÇÃO " + TMPROT->G2_OPERAC + " " + AllTrim( TMPROT->G2_DESCRI ),120),oFont14n)
	
		oPrn:Say(nPixLin+=10,nPixCol+150,"Operação: " + TMPROT->G2_OPERAC,oFont08)
		oPrn:DataMatrix(nPixCol+150, nPixLin+56, TMPROT->G2_OPERAC , 55 )
		oPrn:Say(nPixLin    ,nPixCol+430,"Recurso: " + TMPROT->G2_RECURSO,oFont08)
		oPrn:DataMatrix(nPixCol+430, nPixLin+56, TMPROT->G2_RECURSO, 55 )
	
		oPrn:Line(nPixLin+=65,nPixCol,nPixLin,NMAXCOL)
	
		TMPROT->( dbSkip() )
	EndDo
	
	TMPROT->( dbCloseArea() )
	
 
	//Imprime Cabeçalho dos Itens da Ordem de Separação
	nPixLin := CabPrIt(nPixLin,nPixCol,lSaida)

	nPixLin += 08

	While !CB8->(EOF()) .and. (CB8->CB8_FILIAL+CB8->CB8_ORDSEP == xFilial("CB8")+cOrdSep)

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+CB8->CB8_PROD)

		If Substr(_cTrocaUn,1,11) $ AllTrim(CB8->CB8_PROD)
			_cUnidade := Substr(_cTrocaUn,13,2)   
		Else 
			_cUnidade := SB1->B1_UM 
		EndIf 
		
		aAdd(aItens,{CB8->CB8_PROD,;
					 Substr(SB1->B1_DESC,1,15)+" Eb("+Alltrim(Transform(SB1->B1_XQTDEXP,"@E 999999"))+")",;
					 Alltrim(Transform(CB8->CB8_QTDORI,"@E 999,999.999")),;
					 _cUnidade,;
					 CB8->CB8_LOCAL,;
					 CB8->CB8_LCALIZ,;
					 CB8->CB8_LOTECT,;
					 (Transform(CB8->CB8_SALDOS,"@E 999,999.999"))})

    
		CB8->(dbSkip())
		
		 _cUnidade := ""
	
	EndDo

	For nX := 1 to Len(aItens)
		nPixLin := IncLinTb(nPixLin,nPixCol)
		oPrn:Say(nPixLin		,nPixCol+005	,aItens[nX][01]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+095	,aItens[nX][02]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+315	,aItens[nX][03]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+360	,aItens[nX][04]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+390	,aItens[nX][05]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+420	,aItens[nX][06]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+480	,aItens[nX][07]	,oFont12c,,)

		If nPixLin > 650 
			nPage := RodaImp(nPage,nPixLin,nPixCol)
			nPixLin	:= CabPrint(nPage,lSaida,{})
			nPixLin := CabPrIt(nPixLin,nPixCol,lSaida)
        EndIf
	Next nX
	
	nPage := RodaImp(nPage,nPixLin,nPixCol)			
EndIf

//Fiinaliza a Pagina
oPrn:EndPage()   		

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CabPrint	³ Autor ³ Rodrigo Sousa         ³ Data ³ 02/06/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Cabeçalho do Relatório							   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CabPrint(nPage,lSaida,aDadosCli)

Local nLin			 := NMINLIN
Local nCol			 := NMINCOL

Local cStatus 		 := RetStatus(CB7->CB7_STATUS)
Local cQuery 		 := ""
Local cQueryP   	 := ""
Local cQueryA   	 := ""
Local cQueryB        := ""
Local cAlias		 := ""
Local _cVolumes      := "" 
Local _aVolumes      := Array(14, 2)
Local _lAtVol   	 := .T.
Local _cESPECI1 	 := ""
Local _nVOLUME1 	 := 0
Local _cESPECI2 	 := ""
Local _nVOLUME2 	 := 0
Local _cESPECI3 	 := ""
Local _nVOLUME3 	 := 0
Local _cESPECI4 	 := ""
Local _nVOLUME4 	 := 0
Local _cESPECI5 	 := ""
Local _nVOLUME5 	 := 0
Local _cESPECI6 	 := ""
Local _nVOLUME6 	 := 0
Local _cESPECI7 	 := ""
Local _nVOLUME7 	 := 0
Local _nPbruto       := 0
Local _nVal          := 0
Local _nVol          := 0
Local _nPasVol       := 1
Local _nValFd        := 0
Local _nPos0         := 0
Local _nCheck        := 0 
Local _aCheck        := {} 
Local _cUnExp        := "" 

For _nVol := 1 to Len(_aVolumes)
	_aVolumes[_nVol, 1] := ""
	_aVolumes[_nVol, 2] := 0
Next _nVol

DEFAULT nPage		 := 1
DEFAULT lSaida		 := .F.
DEFAULT aDadosCli	 := {}

//Inicializa a pagina

oPrn:StartPage()	

oPrn:Box(nLin,nCol,NMAXLIN,NMAXCOL)

If cEmpAnt == '08'
	oPrn:SayBitmap(nLin+=15,nCol+10,"logoqualy.bmp",115,35)	
ElseIf cEmpAnt == '02'
	oPrn:SayBitmap(nLin+=15,nCol+10,"logoeuro.bmp",90,35)	
Else
	nLin += 15
EndIf	

oPrn:Say(nLin+=15,nCol+50,PadC("O R D E M  D E  S E P A R A Ç Ã O",125),oFont14n)
oPrn:Say(nLin+=15,nCol+270,Alltrim(CB7->CB7_ORDSEP),oFont12n)

oPrn:DataMatrix(500,090,Alltrim(CB7->CB7_ORDSEP), 60 )

oPrn:Line(nLin+=15,nCol,90,NMAXCOL)

If lSaida

	If CB7->CB7_ORIGEM == "1"
		oPrn:Say(nLin+=12,nCol+005,Left(Iif(!Empty(SC5->C5_NUM)," Pedido: "+SC5->C5_NUM + " (" + Dtoc(SC5->C5_EMISSAO) + ")","")+" Status: "+cStatus,90),oFont12c,,)
    Else
		oPrn:Say(nLin+=12,nCol+005,Left("Nota Fiscal: "+CB7->CB7_NOTA+"-"+CB7->CB7_SERIE + "(" + Dtoc(SF2->F2_EMISSAO) + ") "+Iif(!Empty(SC5->C5_NUM)," Pedido: "+SC5->C5_NUM + " (" + Dtoc(SC5->C5_EMISSAO) + ")","")+" Status: "+cStatus,90),oFont12c,,)
	EndIf

	oPrn:Line(nLin+=10,NMINCOL,nLin,NMAXCOL)

	//Imprime Quadro Dados do Cliente e Dados do Pedido
	
	oPrn:Say(nLin+=012	,nCol+005	,"Cliente......: "+Left(aDadosCli[XCOD]+"/"+aDadosCli[XLOJA]+" - "+Alltrim(aDadosCli[XNOME]),94),oFont12c,,)
	oPrn:Say(nLin+=012	,nCol+005	,"Vendedor(a)..: "+Left(SA3->A3_COD+" - "+Alltrim(SA3->A3_NOME),45),oFont12c,,)
	
	oPrn:Say(nLin+=012	,nCol+005	,"Endereço.....: "+Left(Alltrim(aDadosCli[XEND])+" - "+Alltrim(aDadosCli[XBAIR])+" - "+Alltrim(aDadosCli[XMUN])+" - "+Alltrim(aDadosCli[XEST])+" - "+TransForm(Alltrim(aDadosCli[XCEP]), "@R 99999-999"),80),oFont12c,,)
	oPrn:Say(nLin+=012	,nCol+005	,"End. Entr....: "+Left(Alltrim(aDadosCli[XENDENT])+" - "+Alltrim(aDadosCli[XBAIRROE])+" - "+Alltrim(aDadosCli[XMUNE])+" - "+Alltrim(aDadosCli[XESTE])+" - "+Transform(Alltrim(aDadosCli[XCEPE]),"@R 99999-999"),80),oFont12c,,)
	oPrn:Say(nLin+=012	,nCol+005	,"Transportador: "+Left(SA4->A4_COD+" - "+Alltrim(SA4->A4_NOME),41)+" Tel.: "+Alltrim(SA4->A4_TEL),oFont12c,,)
	oPrn:Say(nLin+=012	,nCol+005	,"End. Transp..: "+Left(AllTrim(SA4->A4_END)+" - "+ AllTrim(SA4->A4_MUN) + " - " + SA4->A4_EST + " - " + TransForm(SA4->A4_CEP, "@R 99999-999"),80),oFont12c,,)

	oPrn:Say( nLin+=012, nCol+005	,"Observações..: " + MemoLine(SC5->C5_OBS, 80, 1) , oFont12c,,,,)
	For  _nVol := 2 To MlCount(SC5->C5_OBS, 80)
		If Empty(AllTrim(MemoLine(SC5->C5_OBS, 80,  _nVol)))
			oPrn:Say( nLin+=012,nCol+045, Space(15) + AllTrim(MemoLine(SC5->C5_OBS, 80,  _nVol)), oFont12c,,,,)
		EndIf	
	Next

	If !Empty(SA1->A1_U_ENTRG)
				oPrn:Say( nLin+=012, nCol+015, Space(15) + "*** " + AllTrim(SA1->A1_U_ENTRG) + " ***", oFont12c,,,,)
	EndIf

	If AllTrim(SA1->A1_LAUDO) == "S"
		oPrn:Say( nLin+=020, nCol+045, Space(15) + "*** ACOMPANHA LAUDO ***", oFont12cn,,,,)
	EndIf


	If CB7->CB7_ORIGEM == "2"
	
		_cVolumes := Iif(SF2->F2_VOLUME1 > 0,Transform(SF2->F2_VOLUME1,"@E 9,999") + " " + AllTrim(SF2->F2_ESPECI1),"");
				  + Iif(SF2->F2_VOLUME2 > 0,Transform(SF2->F2_VOLUME2,"@E 9,999") + " " + AllTrim(SF2->F2_ESPECI2),"");
				  + Iif(SF2->F2_VOLUME3 > 0,Transform(SF2->F2_VOLUME3,"@E 9,999") + " " + AllTrim(SF2->F2_ESPECI3),"");
				  + Iif(SF2->F2_VOLUME4 > 0,Transform(SF2->F2_VOLUME4,"@E 9,999") + " " + AllTrim(SF2->F2_ESPECI4),"");
				  + Iif(SF2->F2_VOLUME5 > 0,Transform(SF2->F2_VOLUME5,"@E 9,999") + " " + AllTrim(SF2->F2_ESPECI5),"");
				  + Iif(SF2->F2_VOLUME6 > 0,Transform(SF2->F2_VOLUME6,"@E 9,999") + " " + AllTrim(SF2->F2_ESPECI6),"");
				  + Iif(SF2->F2_VOLUME7 > 0,Transform(SF2->F2_VOLUME7,"@E 9,999") + " " + AllTrim(SF2->F2_ESPECI7),"")
	
		oPrn:Say( nLin+=020, nCol+005,  "Volumes......: " + _cVolumes, oFont12c,,,,)

		oPrn:Say( nLin+=020,nCol+005, "Peso Bruto...: " + Transform(SF2->F2_PBRUTO, "@E 999,999,999.99") + " KG         Valor..........: R$ " + AllTrim(Transform(SF2->F2_VALMERC, "@E 999,999,999.99")), oFont12c,,,,)
	Else
		
		cAlias := GetNextAlias()
				
		If Select(cAlias) > 0
			(cAlias)->(dbCloseArea())
		EndIf
		
		cQuery := "SELECT SUM(ROUND(C6_PRCVEN * CB8_QTDORI,2)) AS TOTAL FROM "+RetSqlName("SC6")+" AS SC6 "+CRLF
		cQuery += "INNER JOIN "+RetSqlName("CB8")+" CB8 ON CB8_FILIAL = C6_FILIAL AND CB8_PEDIDO = C6_NUM AND CB8_ITEM = C6_ITEM AND CB8_NOTA = '' AND CB8.D_E_L_E_T_ = '' "+CRLF
		cQuery += "INNER JOIN "+RetSqlName("CB7")+" CB7 ON CB7_FILIAL = CB8_FILIAL AND CB7_ORDSEP = CB8_ORDSEP AND CB7_ORIGEM = '1' AND CB7.D_E_L_E_T_ = '' "+CRLF
		cQuery += "WHERE SC6.D_E_L_E_T_ = ''"+CRLF
		cQuery += "AND C6_FILIAL = '"+xFilial("SC6")+"'"+CRLF
		cQuery += "AND CB7_ORIGEM = '1'"+CRLF
		cQuery += "AND CB7_ORDSEP = '"+CB7->CB7_ORDSEP+"'"+CRLF
		
		TcQuery cQuery NEW ALIAS (cAlias)
		
		nTotal := (cAlias)->TOTAL

		(cAlias)->(dbCloseArea())

		// Tratamento referente a liberação parcial do Pedido de vendas em 25/04/2021 - Fabio Carneiro 

		If Select("TRB1") > 0
			TRB1->(DbCloseArea())
		EndIf

		cQueryA := "SELECT CB8_FILIAL, CB8_PROD, CB8_ITEM, CB8_PEDIDO, CB8_LOCAL, CB8_LOTECT, SUM(CB8_QTDORI) AS CB8_QTDORI, "+CRLF
		cQueryA += "CB8_ORDSEP, CB8_PEDIDO, B1_XUNEXP, B1_XQTDEXP, B1_UM, B1_PESO, B1_PESBRU  "+CRLF
		cQueryA += "FROM "+RetSqlName("CB8")+" AS CB8 WITH (NOLOCK) "+CRLF
		cQueryA += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) ON B1_COD = CB8_PROD "+CRLF
		cQueryA += " AND SB1.D_E_L_E_T_ = ' '  "+CRLF
		cQueryA += "WHERE CB8_FILIAL = '"+xFilial("CB8")+"' "+CRLF
		cQueryA += " AND CB8_PEDIDO = '"+SC5->C5_NUM+"'     "+CRLF
		cQueryA += " AND CB8_ORDSEP = '"+CB7->CB7_ORDSEP+"' "+CRLF
		cQueryA += " AND CB8.D_E_L_E_T_ = ' '  "+CRLF
		cQueryA += "GROUP BY CB8_FILIAL, CB8_PROD, CB8_ITEM, CB8_PEDIDO, CB8_LOCAL, CB8_LOTECT, "+CRLF
		cQueryA += "CB8_ORDSEP, CB8_PEDIDO, B1_XUNEXP, B1_XQTDEXP, B1_UM, B1_PESO, B1_PESBRU "+CRLF
		cQueryA += "ORDER BY B1_XUNEXP,B1_XQTDEXP,CB8_ORDSEP,CB8_PROD  "+CRLF
		
		TcQuery cQueryA ALIAS "TRBI" NEW

		TRBI->(DbGoTop())

		While TRBI->(!Eof())

			_aCheck        := {}
			_cCampo        := ""
	        _cDoc          := TRBI->CB8_ORDSEP

			_cCampo := "TRBI->B1_UM"

			_nPos0  := Ascan(_aVolumes, {|x| &_cCampo $ x[1]})
				
			If TRBI->B1_XUNEXP == 'KG'
				_nVal := (TRBI->CB8_QTDORI * TRBI->B1_XQTDEXP)
			Else
				_nVal := TRBI->CB8_QTDORI
			EndIf
				
			If !Empty(TRBI->B1_XUNEXP) 

				_nPos1 := Ascan(_aVolumes, {|x| TRBI->B1_XUNEXP $ x[1]})
					
				If Select("TRB1") > 0
					TRB1->(DbCloseArea())
				EndIf

				cQueryB := "SELECT B1_XQTDEXP,B1_XUNEXP,B1_UM  "+CRLF
				cQueryB += "FROM "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) "+CRLF
				cQueryB += "WHERE SB1.B1_COD = '"+TRBI->CB8_PROD+"' "+CRLF 
				cQueryB += " AND SB1.D_E_L_E_T_ = ' '  "+CRLF
				cQueryB += "GROUP BY B1_XQTDEXP,B1_XUNEXP,B1_UM  "+CRLF
				cQueryB += "ORDER BY B1_XQTDEXP  "+CRLF

				TcQuery cQueryB ALIAS "TRB1" NEW

				TRB1->(DbGoTop())

				While TRB1->(!Eof())

					Aadd(_aCheck,{TRB1->B1_XQTDEXP,TRB1->B1_XUNEXP,TRB1->B1_UM})  
								
					TRB1->(dbSkip())

				EndDo

				For _nCheck := 1 to Len(_aCheck)
							
					If TRBI->B1_XQTDEXP == _aCheck[_nCheck][1]  .And. _aCheck[_nCheck][3] == TRBI->B1_UM
								
						_nValFd  := ((_nVal - (_nVal % _aCheck[_nCheck][1])))/_aCheck[_nCheck][1]
						_nVal    := _nVal % _aCheck[_nCheck][1]
						_cUnExp  := _aCheck[_nCheck][2]
							
					EndIf
							
				Next _nCheck

				If _nValFd > 0
					If _nPos1 == 0
						_aVolumes[_nPasVol, 1]     := _cUnExp
						_aVolumes[_nPasVol, 2]     := _nValFd
						_nPasVol++
					Else
						_aVolumes[_nPos1, 2] += _nValFd
					EndIf
					If _nVal > 0
						If _nPos0 == 0
							_aVolumes[_nPasVol, 1]     := &(_cCampo)
							_aVolumes[_nPasVol, 2]     := _nVal
							_nPasVol++
						Else
							_aVolumes[_nPos0, 2] += _nVal
						EndIf
					EndIf
					
				Else 

					If _nVal > 0
						If _nPos0 == 0
							_aVolumes[_nPasVol, 1] := &(_cCampo)
							_aVolumes[_nPasVol, 2] := _nVal
							_nPasVol++
						Else
							_aVolumes[_nPos0, 2] += _nVal
						EndIf
					EndIf

				EndIf

			EndIf
				
			TRBI->(dbSkip())

			If TRBI->(EOF()) .Or. TRBI->CB8_ORDSEP <> _cDoc 
	
				_aCheck   := {}
				_nPasVol  := 1
				_nVol     := 0
				_nVal     := 0
				_nValFd   := 0
				_nPos0    := 0
				_nPos1    := 0
				_cDoc     := ""
					
			EndIf

		EndDo
		
		If _lAtVol

			_cESPECI1 := _aVolumes[1][1]
			_nVOLUME1 := _aVolumes[1][2]
			_cESPECI2 := _aVolumes[2][1]
			_nVOLUME2 := _aVolumes[2][2]
			_cESPECI3 := _aVolumes[3][1]
			_nVOLUME3 := _aVolumes[3][2]
			_cESPECI4 := _aVolumes[4][1]
			_nVOLUME4 := _aVolumes[4][2]
			_cESPECI5 := _aVolumes[5][1]
			_nVOLUME5 := _aVolumes[5][2]
			_cESPECI6 := _aVolumes[6][1]
			_nVOLUME6 := _aVolumes[6][2]
			_cESPECI7 := _aVolumes[7][1]
			_nVOLUME7 := _aVolumes[7][2]
		
		EndIf
		
		// Neste caso esta limitado a 7 volumes conforme o que conta na nota fiscal de saida 
		// Projeto unidade de expedição - 25/01/2022

		If Select("TRBP") > 0
			TRBP->(DbCloseArea())
		EndIf

		cQueryP := "SELECT SUM(CB8_QTDORI * B1_PESBRU) AS PESOBRU   " +CRLF
		cQueryP += " FROM "+RetSqlName("CB8")+" AS CB8 WITH (NOLOCK) " +CRLF
		cQueryp += "INNER JOIN "+RetSqlName("SB1")+" AS SB1  WITH (NOLOCK) ON CB8_PROD = B1_COD "+CRLF
		cQueryP += " AND SB1.D_E_L_E_T_ = ' ' "+CRLF		
		cQueryP += "WHERE CB8_FILIAL = '"+xFilial("CB8")+"' "+CRLF
		cQueryP += " AND CB8_PEDIDO  = '"+SC5->C5_NUM+"'     "+CRLF
		cQueryP += " AND CB8_ORDSEP  = '"+CB7->CB7_ORDSEP+"' "+CRLF
		cQueryP += " AND CB8.D_E_L_E_T_ = ' '  "

		TcQuery cQueryP ALIAS "TRBP" NEW

		TRBP->(DbGoTop())

		While TRBP->(!Eof())

			_nPesbru   := TRBP->PESOBRU // Peso do pedido 

			TRBP->(DbSkip())

		EndDo
		
		If _lAtVol

			_nPbruto  := _nPesbru

		EndIf
	
		_cVolumes := Iif(_nVOLUME1 > 0,Transform(_nVOLUME1,"@E 9,999") + " " + AllTrim(_cESPECI1),"");
				   + Iif(_nVOLUME2 > 0,Transform(_nVOLUME2,"@E 9,999") + " " + AllTrim(_cESPECI2),"");
			  	   + Iif(_nVOLUME3 > 0,Transform(_nVOLUME3,"@E 9,999") + " " + AllTrim(_cESPECI3),"");
				   + Iif(_nVOLUME4 > 0,Transform(_nVOLUME4,"@E 9,999") + " " + AllTrim(_cESPECI4),"");
				   + Iif(_nVOLUME5 > 0,Transform(_nVOLUME5,"@E 9,999") + " " + AllTrim(_cESPECI5),"");
				   + Iif(_nVOLUME6 > 0,Transform(_nVOLUME6,"@E 9,999") + " " + AllTrim(_cESPECI6),"");
				   + Iif(_nVOLUME7 > 0,Transform(_nVOLUME7,"@E 9,999") + " " + AllTrim(_cESPECI7),"")

		oPrn:Say( nLin+=020, nCol+005,"Volumes......: " +Alltrim(_cVolumes), oFont12c,,,,)

		oPrn:Say( nLin+=020,nCol+005, "Peso Bruto...: " + Transform(_nPbruto, "@E 999,999,999.99") + " KG         Valor..........: R$ " + AllTrim(Transform(nTotal, "@E 999,999,999.99")), oFont12c,,,,)
	
	EndIf
	
	oPrn:Line(nLin+=10,NMINCOL,nLin,NMAXCOL)
Else
	cOP := Alltrim(CB7->CB7_OP)

	dbSelectArea("SC2")
	dbSetOrder(1)
	dbSeek(xFilial("SC2")+cOP)

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek( xFilial("SB1") + SC2->C2_PRODUTO )

	oPrn:Say(nLin+=08,nCol+005,"Ordem de Produção: "+cOP+" Status: "+cStatus,oFont07,,)
	oPrn:Line(nLin+=08,NMINCOL,nLin,NMAXCOL)

	oPrn:Line(nLin+=10,NMINCOL,nLin,NMAXCOL)

	oPrn:DataMatrix(025,nLin+065,cOP, 60 )

	oPrn:Say(nLin+=012	,nCol+105	,"Ordem Produção......: " + Alltrim( cOp ),oFont12c,,)
	oPrn:Say(nLin+=012	,nCol+105	,"Emissão.............: " + DTOC( SC2->C2_EMISSAO ),oFont12c,,)
	oPrn:Say(nLin+=012	,nCol+105	,"Status Separação....: " + Alltrim( cStatus ),oFont12c,,)
	oPrn:Say(nLin+=012	,nCol+105	,"Produto.............: " + Alltrim( SC2->C2_PRODUTO ) + " | " + Alltrim( SB1->B1_DESC ),oFont12c,,)
	oPrn:Say(nLin+=012	,nCol+105	,"Quantidade..........: " + Transform( SC2->C2_QUANT, "@E 999,999,999.99"),oFont12c,,)
	
	oPrn:Line(nLin+=10,NMINCOL,nLin,NMAXCOL)
EnDif	

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf
If Select("TRB2") > 0
	TRB2->(DbCloseArea())
EndIf
If Select("TRBP") > 0
	TRBP->(DbCloseArea())
EndIf
If Select("TRBI") > 0
    TRBI->(DbCloseArea())
EndIf

Return nLin
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CabPrIt	³ Autor ³ Rodrigo Sousa         ³ Data ³ 02/06/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Cabeçalho do Item								   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CabPrIt(nLin,nCol,lSaida)

//oPrn:Say(nLin+=08,nCol+005,"DADOS DOS PRODUTOS",oFont07n,,)

If lSaida
	nLin := IncLinTb(nLin,nCol)
	oPrn:Say(nLin		,nCol+005	,"Produto"			,oFont12cn,,)
	oPrn:Say(nLin		,nCol+095	,"Descrição"		,oFont12cn,,)
	oPrn:Say(nLin		,nCol+310	,"Qtd."				,oFont12cn,,)
	oPrn:Say(nLin		,nCol+360	,"U.M."				,oFont12cn,,)
	oPrn:Say(nLin		,nCol+390	,"Arm."				,oFont12cn,,)
	oPrn:Say(nLin		,nCol+420	,"Endereço"			,oFont12cn,,)
	oPrn:Say(nLin		,nCol+480	,"Lote"				,oFont12cn,,)

Else
	nLin := IncLinTb(nLin,nCol)
	oPrn:Say(nLin		,nCol+005	,"Produto"			,oFont12cn,,)
	oPrn:Say(nLin		,nCol+095	,"Descrição"		,oFont12cn,,)
	oPrn:Say(nLin		,nCol+310	,"Qtd."				,oFont12cn,,)
	oPrn:Say(nLin		,nCol+360	,"U.M."				,oFont12cn,,)
	oPrn:Say(nLin		,nCol+390	,"Arm."				,oFont12cn,,)
	oPrn:Say(nLin		,nCol+420	,"Endereço"			,oFont12cn,,)
	oPrn:Say(nLin		,nCol+480	,"Lote"				,oFont12cn,,)

EndIf

Return nLin
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³StartPrint³ Autor ³ Rodrigo Sousa         ³ Data ³ 02/10/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Parametros da rotina.                					   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function StartPrint()

If ValType(oPrn) == "O"
  	oPrn:Print()
Else
	MsgInfo('O Objeto de impressão não foi inicializado com exito')
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³StartPrint³ Autor ³ Rodrigo Sousa         ³ Data ³ 02/10/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Parametros da rotina.                					   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetStatus(cStatus)
Local cDescri:= " "

If Empty(cStatus) .or. cStatus == "0"
	cDescri:= "Nao iniciado"
ElseIf cStatus == "1"
	cDescri:= "Em separacao"
ElseIf cStatus == "2"
	cDescri:= "Separacao finalizada"
ElseIf cStatus == "3"
	cDescri:= "Em processo de embalagem"
ElseIf cStatus == "4"
	cDescri:= "Embalagem Finalizada"
ElseIf cStatus == "5"
	cDescri:= "Nota gerada"
ElseIf cStatus == "6"
	cDescri:= "Nota impressa"
ElseIf cStatus == "7"
	cDescri:= "Volume impresso"
ElseIf cStatus == "8"
	cDescri:= "Em processo de embarque"
ElseIf cStatus == "9"
	cDescri:= "Finalizado"
EndIf

Return(cDescri)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³StartPrint³ Autor ³ Rodrigo Sousa         ³ Data ³ 02/10/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Parametros da rotina.                					   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IncLinTb(nLin,nCol)

Local nRet	:= 0

oPrn:Line(nLin,nCol+94,nLin+25,nCol+94)
oPrn:Line(nLin,nCol+309,nLin+25,nCol+309)
oPrn:Line(nLin,nCol+359,nLin+25,nCol+359)
oPrn:Line(nLin,nCol+389,nLin+25,nCol+389)
oPrn:Line(nLin,nCol+419,nLin+25,nCol+419)
oPrn:Line(nLin,nCol+479,nLin+25,nCol+479)

nRet := nLin + 20

oPrn:Line(nRet+5,NMINCOL,nRet+5,NMAXCOL)


Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ValidPerg ³ Autor ³ Rodrigo Sousa         ³ Data ³ 16/02/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Parametros da rotina.                					   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RodaImp(nPage,nPixLin,nPixCol)

Local nRet := nPage + 1 

oPrn:Say(710,nPixCol+005,"Separador: _________________________________________ Conferente: _______________________________________ Data ______ /______ /______ ",oFont09n,,)

nPixLin := 720

oPrn:Line(nPixLin+=10,nPixCol,nPixLin,NMAXCOL)
oPrn:Say(nPixLin+=10,nPixCol+050,"INICIAR PRODUÇÃO",oFont08)
oPrn:DataMatrix(nPixCol+050, nPixLin+56, "01" , 55 )
oPrn:Say(nPixLin    ,nPixCol+430,"FINALIZAR PRODUÇÃO",oFont08)
oPrn:DataMatrix(nPixCol+430, nPixLin+56, "04", 55 )

oPrn:EndPage()

Return nRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ValidPerg ³ Autor ³ Rodrigo Sousa         ³ Data ³ 16/02/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Parametros da rotina.                					   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ValidPerg()

Local _aArea := GetArea()
Local _aPerg := {}
Local i      := 0

cPerg := cPerg + Space(4)

Aadd(_aPerg, {cPerg, "01", "Ordem de Sep. De ?"	  	, "MV_CH1" ,  "C", 06	, 0	, "G"	, "MV_PAR01", "CB7"		,""		,""			,"","",""})
Aadd(_aPerg, {cPerg, "02", "Ordem de Sep. Ate ?"  	, "MV_CH2" ,  "C", 06	, 0	, "G"	, "MV_PAR02", "CB7"		,""		,""			,"","",""})
Aadd(_aPerg, {cPerg, "03", "Data de Emissao De ?" 	, "MV_CH3" ,  "D", 08	, 0	, "G"	, "MV_PAR03", ""		,""		,""			,"","",""})
Aadd(_aPerg, {cPerg, "04", "Data de Emissao Ate ?"	, "MV_CH4" ,  "D", 08	, 0	, "G"	, "MV_PAR04", ""		,""		,""			,"","",""})
Aadd(_aPerg, {cPerg, "05", "Cons.Sep.Encerradas ?"	, "MV_CH5" ,  "N", 1	, 0	, "C"	, "MV_PAR05", ""		,"Sim"		,"Não"			,"","",""})
Aadd(_aPerg, {cPerg, "06", "Imprime Cod.Barras ?"	, "MV_CH6" ,  "N", 1	, 0	, "C"	, "MV_PAR06", ""		,"Sim"		,"Não"			,"","",""})

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

Static Function EQVldAlt(nTipo)

Local lRet 		:= .T.

Local cMVXEQAVol	:= GetMv("MV_XEQAVOL",,"") // Indica OperaÃ§Ãµes que nÃ£o serÃ£o considerados para recalculo de volume
Local cMVXEQAPes	:= GetMv( "MV_XEQAPES",, "")  // Indica OperaÃ§Ãµes que nÃ£o serÃ£o considerados para recalculo de peso

Local aAreaSC5 	:= SC5->(GetArea())

If nTipo == 1 .And. SC5->C5_XOPER $ cMVXEQAVOL
	lRet := .F.
ElseIf nTipo == 2 .And. SC5->C5_XOPER $ cMVXEQAPES
	lRet := .F.
Endif

RestArea(aAreaSC5)

Return lRet

