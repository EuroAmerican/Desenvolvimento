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
#DEFINE	 NMAXLIN   	580
#DEFINE	 NMAXCOL   	820

#DEFINE	 REL_NAME	"Ordem de Produção"
#DEFINE  REL_PATH	"c:\temp\"

User Function EQOrdPr2( _cNumOP ) //U_EQOrdPr2( "010307" )

Local nY			:= 0

Private oFont06,oFont07,oFont07n,oFont08,oFont08n,oFont09,oFont09n,oFont10,oFont10n,oFont12,oFont12n,oFont14,oFont14n,oFont16,oFont16n,oFontC7,oFontC7n,oFontCAn
Private oPrn 		:= Nil
Private oSetup		:= Nil
Private cRelName    := ""
Private cPerg	    := "BENOVORDEM"
Private lPrimeiro   := .T.
Private lQualidade  := .T.
Private cNumOP      := ""

Default _cNumOP     := ""

MakeDir( "C:\Temp\" )

If Empty( _cNumOP )
	ValidPerg()
	Pergunte( cPerg, .T.)
	_cNumOP := mv_par01
EndIf

cNumOP  := AllTrim( _cNumOP )
cNumAte := AllTrim( mv_par02 )

If PrepPrint()
	RptStatus({|| ExecPrint() },"Imprimindo Ordem de Produção...")
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

Local nX	:= 0
Local lRet 	:= .T.

DEFAULT cPathDest   := REL_PATH
DEFAULT cRelName	:= REL_NAME

cRelName := "OP_" + AllTrim( cNumOP ) + "_"  + DTOS( dDataBase ) + "_" + Replace( Time(), ":", "") + ".PDF"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Instancia os objetos de fonte   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFont06  := TFont():New( "Courier New",, 06,,.F.)
oFont07n := TFont():New( "Arial",, 07,,.T.)
oFont07  := TFont():New( "Arial",, 07,,.F.)
oFont08n := TFont():New( "Arial",, 08,,.T.)
oFont08  := TFont():New( "Arial",, 08,,.F.)
oFont09  := TFont():New( "Arial",, 09,,.F.)
oFont09n := TFont():New( "Arial",, 09,,.T.)
oFont10n := TFont():New( "Arial",, 10,,.T.)
oFont10  := TFont():New( "Arial",, 10,,.F.)
oFont12n := TFont():New( "Arial",, 12,,.T.)
oFont12  := TFont():New( "Arial",, 12,,.F.)
oFont14n := TFont():New( "Arial",, 14,,.T.)
oFont14  := TFont():New( "Arial",, 14,,.F.)
oFont16n := TFont():New( "Arial",, 16,,.T.)
oFont16  := TFont():New( "Arial",, 16,,.F.)
oFontC7n := TFont():New( "Courier New",, 08,,.T.)
oFontC7  := TFont():New( "Courier New",, 08,,.F.)
oFontCAn := TFont():New( "Courier New",, 16,,.T.)
oFontC10n:= TFont():New( "Courier New",, 10,,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Instancia a Classe FwMsPrinter  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrn := FwMsPrinter():New(cRelName,IMP_PDF,.F.,cPathDest,.T.,.F.,@oPrn,,,.F.,.F.,.T.,)
oPrn:SetResolution(72)
oPrn:SetLandscape()
oPrn:SetPaperSize(DMPAPER_A4)

oPrn:cPathPDF := cPathDest 			//Caso seja utilizada impressão em IMP_PDF      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Instancia a Classe FWPrintSetup ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSetup := FWPrintSetup():New(PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION+PD_DISABLEDESTINATION+PD_DISABLEPAPERSIZE+PD_DISABLEPREVIEW ,"EQOrdPr2")
oSetup:SetUserParms({|| Pergunte(cPerg, .T.)})
oSetup:SetProperty(PD_MARGIN,{05,05,05,05})
oSetup:SetProperty(PD_DESTINATION,2) 

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

Local lProc       := .F.
Private aEmpSaldo := {}

cQuery := "SELECT * " + CRLF
cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
cQuery += "  AND B1_COD = C2_PRODUTO " + CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
cQuery += "AND C2_NUM + C2_ITEM + C2_SEQUEN BETWEEN '" + cNumOP + "' AND '" + AllTrim( cNumAte ) + "' " + CRLF
cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "ORDER BY C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO " + CRLF

TCQuery cQuery New Alias "TMPCOM"
dbSelectArea("TMPCOM")
TMPCOM->( dbGoTop() )

SetRegua( TMPCOM->( RecCount() ) )

cNumOP := TMPCOM->C2_NUM + TMPCOM->C2_ITEM + TMPCOM->C2_SEQUEN

While !TMPCOM->(EOF())
	IncRegua("Imprimindo") 
	aEmpSaldo := {}

	If TMPCOM->C2_ITEM + TMPCOM->C2_SEQUEN == "01001"
		cMsg := ""
	
		//cQuery := "SELECT D4_COD, SUM(D4_QUANT) AS QUANTIDADE, SUM(B2_QATU - B2_QEMP - B2_RESERVA) AS SALDO " + CRLF
		cQuery := "SELECT D4_COD, SUM(D4_QUANT) AS QUANTIDADE, SUM(B2_QATU) AS SALDO " + CRLF
		cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SD4") + " AS SD4 WITH (NOLOCK) ON D4_FILIAL = C2_FILIAL " + CRLF
		cQuery += "  AND D4_OP = C2_NUM + C2_ITEM + C2_SEQUEN " + CRLF
		cQuery += "  AND SC2.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
		cQuery += "  AND B1_COD = C2_PRODUTO " + CRLF
		cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) ON B2_FILIAL = C2_FILIAL " + CRLF
		cQuery += "  AND B2_COD = D4_COD " + CRLF
		cQuery += "  AND SB2.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
		cQuery += "AND C2_NUM = '" + TMPCOM->C2_NUM + "' " + CRLF
		cQuery += "AND C2_ITEM = '" + TMPCOM->C2_ITEM + "' " + CRLF
		cQuery += "AND C2_SEQUEN = '" + TMPCOM->C2_SEQUEN + "' " + CRLF
		cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "GROUP BY D4_COD " + CRLF
		//cQuery += "HAVING SUM(B2_QATU - B2_QEMP - B2_RESERVA) - SUM(D4_QUANT) < 0.00 " + CRLF
		cQuery += "HAVING SUM(B2_QATU) - SUM(D4_QUANT) < 0.00 " + CRLF

		TCQuery cQuery New Alias "TMPSC2"
		dbSelectArea("TMPSC2")
		dbGoTop()
		
		Do While !TMPSC2->( Eof() )
			cMsg += "Produto: " + TMPSC2->D4_COD + " Necessário: " + Transform( TMPSC2->QUANTIDADE, "@E 999,999.99") + " Saldo: " + Transform( TMPSC2->SALDO, "@E 999,999.99") + CRLF
			aAdd( aEmpSaldo, { TMPSC2->D4_COD })
			TMPSC2->( dbSkip() )
		EndDo
		
		If !Empty( cMsg )
			Aviso( "EQORDPR2 - Aviso", "Ordem de Produção possui componentes sem saldo suficiente disponível:" + CRLF + cMsg, {"OK"}, 3)
		EndIf
		
		TMPSC2->( dbCloseArea() )
	EndIf

	lQualidade := .T.
	RunPrint()
	lProc	   := .T.
	TMPCOM->( dbSkip() )
	If !TMPCOM->(EOF()) .And. AllTrim( cNumOP ) <> AllTrim( TMPCOM->C2_NUM )
		cNumOP := TMPCOM->C2_NUM + TMPCOM->C2_ITEM + TMPCOM->C2_SEQUEN
		//RunBarra()
		//StartPrint()
	EndIf
EndDo

If lProc
	//RunBarra()
	StartPrint()
Else
	ApMsgInfo('Não há dados!', 'Cosmotec')
EndIf

TMPCOM->( dbCloseArea() )

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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Cabeçalho da Ordem de Separação						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPixLin			:= CabPrint(nPage)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Cabeçalho dos Itens da Ordem de Separação			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPixLin := CabPrIt(nPixLin,nPixCol)

cQuery := "SELECT * "
cQuery += "FROM " + RetSqlName("SG2") + " AS SG2 WITH (NOLOCK) "
cQuery += "INNER JOIN " + RetSqlName("SH1") + " AS SH1 WITH (NOLOCK) ON H1_FILIAL = '" + xFilial("SH1") + "' "
cQuery += "  AND H1_CODIGO = G2_RECURSO "
cQuery += "  AND SH1.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN " + RetSqlName("SHB") + " AS SHB WITH (NOLOCK) ON HB_FILIAL = '" + xFilial("SHB") + "' "
cQuery += "  AND HB_COD = G2_CTRAB "
cQuery += "  AND SHB.D_E_L_E_T_ = ' ' "
cQuery += "WHERE G2_FILIAL = '" + xFilial("SG2") + "' "
cQuery += "AND G2_CODIGO = '" + TMPCOM->C2_ROTEIRO + "' " 
cQuery += "AND G2_PRODUTO = '" + TMPCOM->C2_PRODUTO + "' " 
cQuery += "AND SG2.D_E_L_E_T_ = ' ' "

TCQuery cQuery New Alias "TMPROT"
dbSelectArea("TMPROT")
dbGoTop()

Do While !TMPROT->( Eof() )
	If nPixLin > 560
		oPrn:EndPage()
		nPage += 1
		nPixLin	:= CabPrint(nPage)
		nPixLin := CabPrIt(nPixLin,nPixCol)
	EndIf

	oPrn:Box(nPixLin,nPixCol+000,nPixLin + 10,nPixCol+035)
	oPrn:Box(nPixLin,nPixCol+035,nPixLin + 10,nPixCol+185)
	oPrn:Box(nPixLin,nPixCol+185,nPixLin + 10,nPixCol+225)
	oPrn:Box(nPixLin,nPixCol+225,nPixLin + 10,nPixCol+375)
	oPrn:Box(nPixLin,nPixCol+375,nPixLin + 10,nPixCol+415)
	oPrn:Box(nPixLin,nPixCol+415,nPixLin + 10,nPixCol+575)
	oPrn:Box(nPixLin,nPixCol+575,nPixLin + 10,nPixCol+675)
	oPrn:Box(nPixLin,nPixCol+675,nPixLin + 10,NMAXCOL)

	nPixLin += 008
	oPrn:Say(nPixLin-001	,nPixCol+005	,TMPROT->G2_OPERAC										,oFont06,,)
	oPrn:Say(nPixLin-001	,nPixCol+042	,TMPROT->G2_DESCRI										,oFont06,,)
	oPrn:Say(nPixLin-001	,nPixCol+187	,TMPROT->G2_RECURSO										,oFont06,,)
	oPrn:Say(nPixLin-001	,nPixCol+227	,TMPROT->H1_DESCRI		  		 						,oFont06,,)
	oPrn:Say(nPixLin-001	,nPixCol+377	,TMPROT->G2_CTRAB										,oFont06,,)
	oPrn:Say(nPixLin-001	,nPixCol+417	,TMPROT->HB_NOME										,oFont06,,)
	oPrn:Say(nPixLin-001	,nPixCol+577	,"____/____/_______  ____:____"							,oFont06,,)
	oPrn:Say(nPixLin-001	,nPixCol+677	,"____/____/_______  ____:____"							,oFont06,,)

	TMPROT->( dbSkip() )
EndDo

TMPROT->( dbCloseArea() )

cQuery := "SELECT Z0_OPERAC, ISNULL(RTRIM(LTRIM(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),Z0_DESCRIC)))), '') AS INSTRUCAO "
cQuery += "FROM " + RetSqlName("SZ0") + " AS SZ0 WITH (NOLOCK) "
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery += "  AND B1_COD = Z0_PRODUTO "
cQuery += "  AND B1_TIPO <> 'PA' " // Não trazer PA conforme solicitação Alex
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "WHERE Z0_FILIAL = '" + xFilial("SZ0") + "' "
cQuery += "AND Z0_PRODUTO = '" + TMPCOM->C2_PRODUTO + "' "
cQuery += "AND SZ0.D_E_L_E_T_ = ' ' "

TCQuery cQuery New Alias "TMPINS"
dbSelectArea("TMPINS")
dbGoTop()

If !TMPINS->( Eof() )
	oPrn:Say(nPixLin + 02 + 14,NMINCOL + 005,"Instruções de Trabalhos",oFont14n,,CLR_BLUE)
	oPrn:Line(nPixLin+=02 + 20,nPixCol,nPixLin,NMAXCOL)

	oPrn:Box(nPixLin,nPixCol+000,nPixLin + 10,nPixCol+035)
	oPrn:Box(nPixLin,nPixCol+035,nPixLin + 10,NMAXCOL)
	
	nPixLin += 008
	oPrn:Say(nPixLin-001	,nPixCol+005	,"Item"				,oFont07n,,)
	oPrn:Say(nPixLin-001	,nPixCol+042	,"Texto Instrução"	,oFont07n,,)
EndIf

Do While !TMPINS->( Eof() )
	If nPixLin > 560
		oPrn:EndPage()
		nPage += 1
		nPixLin	:= CabPrint(nPage)
		nPixLin := CabPrIt(nPixLin,nPixCol)
	EndIf

	oPrn:Box(nPixLin,nPixCol+000,nPixLin + 10,nPixCol+035)
	oPrn:Box(nPixLin,nPixCol+035,nPixLin + 10,NMAXCOL)

	nPixLin += 008
	oPrn:Say(nPixLin-001	,nPixCol+005	,AllTrim( TMPINS->Z0_OPERAC )							,oFont06,,)
	oPrn:Say(nPixLin-001	,nPixCol+042	,AllTrim( TMPINS->INSTRUCAO)							,oFont06,,)

	TMPINS->( dbSkip() )
EndDo

TMPINS->( dbCloseArea() )

oPrn:Say(nPixLin + 02 + 14,NMINCOL + 005,"Empenho de Componentes",oFont14n,,CLR_BLUE)
oPrn:Line(nPixLin+=02 + 20,nPixCol,nPixLin,NMAXCOL)

//nPixLin += 008
oPrn:Box( nPixLin, nPixCol+000        , nPixLin+010, nPixCol+035-010    ) // Quadro 1 - TRT
oPrn:Box( nPixLin, nPixCol+035-010    , nPixLin+010, nPixCol+095-010    ) // Quadro 1 - Cod
oPrn:Box( nPixLin, nPixCol+095-010    , nPixLin+010, nPixCol+195        ) // Quadro 1 - Descrição
oPrn:Box( nPixLin, nPixCol+195        , nPixLin+010, nPixCol+225        ) // Quadro 1 - Local
oPrn:Box( nPixLin, nPixCol+225        , nPixLin+010, nPixCol+285        ) // Quadro 1 - Lote
oPrn:Box( nPixLin, nPixCol+285        , nPixLin+010, nPixCol+325        ) // Quadro 1 - UM
oPrn:Box( nPixLin, nPixCol+325        , nPixLin+010, nPixCol+395        ) // Quadro 1 - Quantidade
oPrn:Box( nPixLin, nPixCol+000+395    , nPixLin+010, nPixCol+035+395-010) // Quadro 2 - TRT
oPrn:Box( nPixLin, nPixCol+035+395-010, nPixLin+010, nPixCol+095+395-010) // Quadro 2 - Cod
oPrn:Box( nPixLin, nPixCol+095+395-010, nPixLin+010, nPixCol+195+395    ) // Quadro 2 - Descrição
oPrn:Box( nPixLin, nPixCol+195+395    , nPixLin+010, nPixCol+225+395    ) // Quadro 2 - Local
oPrn:Box( nPixLin, nPixCol+225+395    , nPixLin+010, nPixCol+285+395    ) // Quadro 2 - Lote
oPrn:Box( nPixLin, nPixCol+285+395    , nPixLin+010, nPixCol+325+395    ) // Quadro 2 - UM
oPrn:Box( nPixLin, nPixCol+325+395    , nPixLin+010, NMAXCOL            ) // Quadro 2 - Quantidade

nPixLin += 010
oPrn:Say(nPixLin-002	,nPixCol+003	    ,"TRT"				,oFont07n,,)
oPrn:Say(nPixLin-002	,nPixCol+038-010    ,"Código"			,oFont07n,,)
oPrn:Say(nPixLin-002	,nPixCol+098-010    ,"Descrição"		,oFont07n,,)
oPrn:Say(nPixLin-002	,nPixCol+198	    ,"Local"			,oFont07n,,)
oPrn:Say(nPixLin-002	,nPixCol+228	    ,"Lote"				,oFont07n,,)
oPrn:Say(nPixLin-002	,nPixCol+288	    ,"UM"				,oFont07n,,)
oPrn:Say(nPixLin-002	,nPixCol+328	    ,"Quantidade"		,oFont07n,,)
oPrn:Say(nPixLin-002	,nPixCol+003+395    ,"TRT"				,oFont07n,,)
oPrn:Say(nPixLin-002	,nPixCol+038+395-010,"Código"			,oFont07n,,)
oPrn:Say(nPixLin-002	,nPixCol+098+395-010,"Descrição"		,oFont07n,,)
oPrn:Say(nPixLin-002	,nPixCol+198+395    ,"Local"			,oFont07n,,)
oPrn:Say(nPixLin-002	,nPixCol+228+395    ,"Lote"				,oFont07n,,)
oPrn:Say(nPixLin-002	,nPixCol+288+395    ,"UM"				,oFont07n,,)
oPrn:Say(nPixLin-002	,nPixCol+328+395    ,"Quantidade"		,oFont07n,,)

cQuery := "SELECT D4_TRT, D4_COD, B1_DESC, D4_LOCAL, D4_LOTECTL, B1_UM, CASE WHEN D4_QUANT = 0 THEN D4_QTDEORI ELSE D4_QUANT END AS D4_QUANT " + CRLF
cQuery += "FROM " + RetSqlName("SD4") + " AS SD4 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
cQuery += "  AND B1_COD = D4_COD " + CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE D4_FILIAL = '" + xFilial("SD4") + "' " + CRLF
cQuery += "AND D4_OP = '" + TMPCOM->C2_NUM + TMPCOM->C2_ITEM + TMPCOM->C2_SEQUEN + "' " + CRLF
cQuery += "AND SD4.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "ORDER BY D4_LOCAL, D4_TRT, D4_COD " + CRLF

TCQuery cQuery New Alias "TMPEMP"
dbSelectArea("TMPEMP")
dbGoTop()

lQuadro1 := .T.

Do While !TMPEMP->( Eof() )
	If lQuadro1
		If nPixLin > 560
			oPrn:EndPage()
			nPage += 1
			nPixLin	:= CabPrint(nPage)
			nPixLin := CabPrIt(nPixLin,nPixCol)
		EndIf

		oPrn:Box( nPixLin, nPixCol+000        , nPixLin+010, nPixCol+035-010    ) // Quadro 1 - TRT
		oPrn:Box( nPixLin, nPixCol+035-010    , nPixLin+010, nPixCol+095-010    ) // Quadro 1 - Cod
		oPrn:Box( nPixLin, nPixCol+095-010    , nPixLin+010, nPixCol+195        ) // Quadro 1 - Descrição
		oPrn:Box( nPixLin, nPixCol+195        , nPixLin+010, nPixCol+225        ) // Quadro 1 - Local
		oPrn:Box( nPixLin, nPixCol+225        , nPixLin+010, nPixCol+285        ) // Quadro 1 - Lote
		oPrn:Box( nPixLin, nPixCol+285        , nPixLin+010, nPixCol+325        ) // Quadro 1 - UM
		oPrn:Box( nPixLin, nPixCol+325        , nPixLin+010, nPixCol+395        ) // Quadro 1 - Quantidade

		nPixLin += 010
		cFalta := ""
		If aScan( aEmpSaldo, {|x| AllTrim( TMPEMP->D4_COD ) == AllTrim( x[1] ) }) > 0
			cFalta := " [ * ]"
		EndIf
		
		oPrn:Say(nPixLin-002	,nPixCol+003	,AllTrim( TMPEMP->D4_TRT )									,oFont06,,)
		oPrn:Say(nPixLin-002	,nPixCol+038-010,AllTrim( TMPEMP->D4_COD) + cFalta							,oFont06,,)
		oPrn:Say(nPixLin-002	,nPixCol+098-010,Left( AllTrim( TMPEMP->B1_DESC), 31)						,oFont06,,)
		oPrn:Say(nPixLin-002	,nPixCol+198	,AllTrim( TMPEMP->D4_LOCAL)									,oFont06,,)
		oPrn:Say(nPixLin-002	,nPixCol+228	,AllTrim( TMPEMP->D4_LOTECTL)								,oFont06,,)
		oPrn:Say(nPixLin-002	,nPixCol+288	,AllTrim( TMPEMP->B1_UM)									,oFont06,,)
		oPrn:Say(nPixLin-002	,nPixCol+328	,Transform( TMPEMP->D4_QUANT, PesqPict("SD4","D4_QUANT",15)),oFont06,,)

		lQuadro1 := .F.
	Else
		oPrn:Box( nPixLin-010, nPixCol+000+395    , nPixLin, nPixCol+035+395-010) // Quadro 2 - TRT
		oPrn:Box( nPixLin-010, nPixCol+035+395-010, nPixLin, nPixCol+095+395-010) // Quadro 2 - Cod
		oPrn:Box( nPixLin-010, nPixCol+095+395-010, nPixLin, nPixCol+195+395    ) // Quadro 2 - Descrição
		oPrn:Box( nPixLin-010, nPixCol+195+395    , nPixLin, nPixCol+225+395    ) // Quadro 2 - Local
		oPrn:Box( nPixLin-010, nPixCol+225+395    , nPixLin, nPixCol+285+395    ) // Quadro 2 - Lote
		oPrn:Box( nPixLin-010, nPixCol+285+395    , nPixLin, nPixCol+325+395    ) // Quadro 2 - UM
		oPrn:Box( nPixLin-010, nPixCol+325+395    , nPixLin, NMAXCOL            ) // Quadro 2 - Quantidade
  
		cFalta := ""
		If aScan( aEmpSaldo, {|x| AllTrim( TMPEMP->D4_COD ) == AllTrim( x[1] ) }) > 0
			cFalta := " [ * ]"
		EndIf
		
		oPrn:Say(nPixLin-002	,nPixCol+003+395    ,AllTrim( TMPEMP->D4_TRT )									,oFont06,,)
		oPrn:Say(nPixLin-002	,nPixCol+038+395-010,AllTrim( TMPEMP->D4_COD) + cFalta							,oFont06,,)
		oPrn:Say(nPixLin-002	,nPixCol+098+395-010,Left( AllTrim( TMPEMP->B1_DESC), 31)						,oFont06,,)
		oPrn:Say(nPixLin-002	,nPixCol+198+395    ,AllTrim( TMPEMP->D4_LOCAL)									,oFont06,,)
		oPrn:Say(nPixLin-002	,nPixCol+228+395    ,AllTrim( TMPEMP->D4_LOTECTL)								,oFont06,,)
		oPrn:Say(nPixLin-002	,nPixCol+288+395    ,AllTrim( TMPEMP->B1_UM)									,oFont06,,)
		oPrn:Say(nPixLin-002	,nPixCol+328+395    ,Transform( TMPEMP->D4_QUANT, PesqPict("SD4","D4_QUANT",15)),oFont06,,)

		lQuadro1 := .T.
	EndIf

	TMPEMP->( dbSkip() )
EndDo

TMPEMP->( dbCloseArea() )

cQuery := "SELECT QPJ_ITEM, QPJ_ENSAIO, QPJ_DUNMED, UPPER(QPJ_DESENS) ENSAIO, QPJ_LINF LIMINF, QPJ_LSUP LIMSUP, QPJ_TEXTO TEXTO, CASE WHEN QP1_TIPO = 'C' THEN 'Calculado' ELSE 'Digitado' END TIPO, QP1_QTDE, QP1_METODO " + CRLF
cQuery += "FROM " + RetSqlName("QPJ") + " AS QPJ WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("QP1") + " AS QP1 WITH (NOLOCK) ON QP1_FILIAL = '" + xFilial("QP1") + "' " + CRLF
cQuery += "  AND QPJ_ENSAIO = QP1_ENSAIO " + CRLF
cQuery += "  AND QP1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE QPJ_FILIAL = '" + xFilial("QPJ") + "' " + CRLF
cQuery += "AND QPJ_PROD = '" + TMPCOM->C2_PRODUTO + "' " + CRLF
cQuery += "AND QPJ.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "ORDER BY QPJ_PROD, QPJ_ITEM " + CRLF

TCQuery cQuery New Alias "TMPQUA"
dbSelectArea("TMPQUA")
dbGoTop()

If !TMPQUA->( Eof() )
	lQualidade := .T.
	oPrn:Say(nPixLin + 02 + 14,NMINCOL + 005,"Controle de Qualidade",oFont14n,,CLR_BLUE)
	oPrn:Line(nPixLin+=02 + 20,nPixCol,nPixLin,NMAXCOL)
	
	oPrn:Box( nPixLin, nPixCol+000        , nPixLin+010, nPixCol+025        ) // Item
	oPrn:Box( nPixLin, nPixCol+025        , nPixLin+010, nPixCol+085        ) // Código
	oPrn:Box( nPixLin, nPixCol+085        , nPixLin+010, nPixCol+245        ) // Ensaio
	oPrn:Box( nPixLin, nPixCol+245        , nPixLin+010, nPixCol+305        ) // Lim. Inf.
	oPrn:Box( nPixLin, nPixCol+305        , nPixLin+010, nPixCol+365        ) // Lim. Sup.
	oPrn:Box( nPixLin, nPixCol+365        , nPixLin+010, nPixCol+445        ) // Unid. Med.
	oPrn:Box( nPixLin, nPixCol+445        , nPixLin+010, nPixCol+645        ) // Texto
	oPrn:Box( nPixLin, nPixCol+645        , nPixLin+010, nPixCol+695        ) // Tipo
	oPrn:Box( nPixLin, nPixCol+695        , nPixLin+010, nPixCol+765        ) // Qtd. Amostra
	oPrn:Box( nPixLin, nPixCol+765        , nPixLin+010, NMAXCOL            ) // Método
	
	nPixLin += 010
	oPrn:Say(nPixLin-002	,nPixCol+003	    ,"Item"				,oFont07n,,)
	oPrn:Say(nPixLin-002	,nPixCol+028        ,"Código"			,oFont07n,,)
	oPrn:Say(nPixLin-002	,nPixCol+088        ,"Ensaio"			,oFont07n,,)
	oPrn:Say(nPixLin-002	,nPixCol+248	    ,"Lim. Inf."		,oFont07n,,)
	oPrn:Say(nPixLin-002	,nPixCol+308	    ,"Lim. Sup."		,oFont07n,,)
	oPrn:Say(nPixLin-002	,nPixCol+368	    ,"Unid. Med."		,oFont07n,,)
	oPrn:Say(nPixLin-002	,nPixCol+448	    ,"Texto"			,oFont07n,,)
	oPrn:Say(nPixLin-002	,nPixCol+648        ,"Tipo"				,oFont07n,,)
	oPrn:Say(nPixLin-002	,nPixCol+698        ,"Qtd. Amostra"		,oFont07n,,)
	oPrn:Say(nPixLin-002	,nPixCol+768        ,"Método"			,oFont07n,,)
Else
	lQualidade := .F.
EndIf

Do While !TMPQUA->( Eof() )
	If nPixLin > 560
		oPrn:EndPage()
		nPage += 1
		nPixLin	:= CabPrint(nPage)
		nPixLin := CabPrIt(nPixLin,nPixCol)
	EndIf

	oPrn:Box( nPixLin, nPixCol+000        , nPixLin+010, nPixCol+025        ) // Item
	oPrn:Box( nPixLin, nPixCol+025        , nPixLin+010, nPixCol+085        ) // Código
	oPrn:Box( nPixLin, nPixCol+085        , nPixLin+010, nPixCol+245        ) // Ensaio
	oPrn:Box( nPixLin, nPixCol+245        , nPixLin+010, nPixCol+305        ) // Lim. Inf.
	oPrn:Box( nPixLin, nPixCol+305        , nPixLin+010, nPixCol+365        ) // Lim. Sup.
	oPrn:Box( nPixLin, nPixCol+365        , nPixLin+010, nPixCol+445        ) // Unid. Med.
	oPrn:Box( nPixLin, nPixCol+445        , nPixLin+010, nPixCol+645        ) // Texto
	oPrn:Box( nPixLin, nPixCol+645        , nPixLin+010, nPixCol+695        ) // Tipo
	oPrn:Box( nPixLin, nPixCol+695        , nPixLin+010, nPixCol+765        ) // Qtd. Amostra
	oPrn:Box( nPixLin, nPixCol+765        , nPixLin+010, NMAXCOL            ) // Método

	nPixLin += 010
	oPrn:Say(nPixLin-002	,nPixCol+003	,AllTrim( TMPQUA->QPJ_ITEM )								,oFont06,,)
	oPrn:Say(nPixLin-002	,nPixCol+028    ,AllTrim( TMPQUA->QPJ_ENSAIO )								,oFont06,,)
	oPrn:Say(nPixLin-002	,nPixCol+088    ,AllTrim( TMPQUA->ENSAIO )									,oFont06,,)
	oPrn:Say(nPixLin-002	,nPixCol+248	,Transform( TMPQUA->LIMINF, PesqPict("QPJ","QPJ_LINF",14))	,oFont06,,)
	oPrn:Say(nPixLin-002	,nPixCol+308	,Transform( TMPQUA->LIMSUP, PesqPict("QPJ","QPJ_LSUP",14))	,oFont06,,)
	oPrn:Say(nPixLin-002	,nPixCol+368	,AllTrim( TMPQUA->QPJ_DUNMED )								,oFont06,,)
	oPrn:Say(nPixLin-002	,nPixCol+448	,AllTrim( TMPQUA->TEXTO )									,oFont06,,)
	oPrn:Say(nPixLin-002	,nPixCol+648	,AllTrim( TMPQUA->TIPO )									,oFont06,,)
	oPrn:Say(nPixLin-002	,nPixCol+698	,Transform( TMPQUA->QP1_QTDE, PesqPict("QP1","QP1_QTDE",14)),oFont06,,)
	oPrn:Say(nPixLin-002	,nPixCol+768	,AllTrim( TMPQUA->QP1_METODO)								,oFont06,,)

	TMPQUA->( dbSkip() )
EndDo

TMPQUA->( dbCloseArea() )

If AllTrim( TMPCOM->C2_ITEM + TMPCOM->C2_SEQUEN ) <> "01001"
	oPrn:Line(nPixLin+=06,nPixCol,nPixLin,NMAXCOL)
	
	oPrn:Say(nPixLin + 02 + 14,NMINCOL + 005,"TRANSAÇÕES PARA APONTAMENTOS DE OPERAÇÕES - ORDEM DE PRODUÇÃO",oFont14n,,CLR_RED)
	oPrn:Line(nPixLin+=02 + 20,nPixCol,nPixLin,NMAXCOL)
	
	nPixLin += 010
	
	oPrn:Box( nPixLin-010, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * 1)-((NMAXCOL-NMINCOL)/4)      , nPixLin, nPixCol+(((NMAXCOL-NMINCOL)/4) * 1))
	oPrn:Box( nPixLin, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * 1)-((NMAXCOL-NMINCOL)/4)      , nPixLin+080, nPixCol+(((NMAXCOL-NMINCOL)/4) * 1))
	
	oPrn:Box( nPixLin-010, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * (2))-((NMAXCOL-NMINCOL)/4)  , nPixLin, nPixCol+(((NMAXCOL-NMINCOL)/4) * (2)))
	oPrn:Box( nPixLin, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * (2))-((NMAXCOL-NMINCOL)/4)  , nPixLin+080, nPixCol+(((NMAXCOL-NMINCOL)/4) * (2)))
	
	oPrn:Box( nPixLin-010, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * (3))-((NMAXCOL-NMINCOL)/4)  , nPixLin, nPixCol+(((NMAXCOL-NMINCOL)/4) * (3)))
	oPrn:Box( nPixLin, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * (3))-((NMAXCOL-NMINCOL)/4)  , nPixLin+080, nPixCol+(((NMAXCOL-NMINCOL)/4) * (3)))
	
	oPrn:Box( nPixLin-010, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * (4))-((NMAXCOL-NMINCOL)/4)  , nPixLin, nPixCol+(((NMAXCOL-NMINCOL)/4) * (4)))
	oPrn:Box( nPixLin, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * (4))-((NMAXCOL-NMINCOL)/4)  , nPixLin+080, nPixCol+(((NMAXCOL-NMINCOL)/4) * (4)))
	
	oPrn:Say(nPixLin-002	,nPixCol+003+(((NMAXCOL-NMINCOL)/4) * 1)-((NMAXCOL-NMINCOL)/4),"01 - Iniciar Produção",oFont07n,,CLR_RED)
	oPrn:DataMatrix(nPixCol+003+(((NMAXCOL-NMINCOL)/4) * 1)-((NMAXCOL-NMINCOL)/4) + 075, nPixLin+048, "01", 40 )
	
	oPrn:Say(nPixLin-002	,nPixCol+003+(((NMAXCOL-NMINCOL)/4) * 2)-((NMAXCOL-NMINCOL)/4),"02 - Iniciar Pausa/Parada",oFont07n,,CLR_RED)
	oPrn:DataMatrix(nPixCol+003+(((NMAXCOL-NMINCOL)/4) * 2)-((NMAXCOL-NMINCOL)/4) + 075, nPixLin+048, "02", 40 )
	
	oPrn:Say(nPixLin-002	,nPixCol+003+(((NMAXCOL-NMINCOL)/4) * 3)-((NMAXCOL-NMINCOL)/4),"02 - Finalizar Pausa/Parada",oFont07n,,CLR_RED)
	oPrn:DataMatrix(nPixCol+003+(((NMAXCOL-NMINCOL)/4) * 3)-((NMAXCOL-NMINCOL)/4) + 075, nPixLin+048, "02", 40 )
	
	//oPrn:Say(nPixLin-002	,nPixCol+003+(((NMAXCOL-NMINCOL)/4) * 4)-((NMAXCOL-NMINCOL)/4),"04 - Apontamento Operação/Produção",oFont07n,,CLR_RED)
	oPrn:Say(nPixLin-002	,nPixCol+003+(((NMAXCOL-NMINCOL)/4) * 4)-((NMAXCOL-NMINCOL)/4),"04 - Finalizar Produção",oFont07n,,CLR_RED)
	oPrn:DataMatrix(nPixCol+003+(((NMAXCOL-NMINCOL)/4) * 4)-((NMAXCOL-NMINCOL)/4) + 075, nPixLin+048, "04", 40 )
	
	nPixLin += 080

	cQuery := "SELECT * " + CRLF
	cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = C2_PRODUTO " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
	cQuery += "AND C2_NUM = '" + TMPCOM->C2_NUM + "' " + CRLF
	cQuery += "AND C2_ITEM = '" + TMPCOM->C2_ITEM + "' " + CRLF
	cQuery += "AND C2_SEQUEN = '" + TMPCOM->C2_SEQUEN + "' " + CRLF
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO " + CRLF
	
	TCQuery cQuery New Alias "BARRAS"
	dbSelectArea("BARRAS")
	BARRAS->( dbGoTop() )
	
	Do While !BARRAS->( Eof() )
		If nPixLin > 510
			oPrn:EndPage()
			nPage += 1
			nPixLin	:= NMINLIN
			nPixCol	:= NMINCOL
	
			oPrn:StartPage()
	
			oPrn:Box(nPixLin,nPixCol,NMAXLIN,NMAXCOL)
			
			oPrn:SayBitmap(nPixLin+=10,nPixCol+10, GetSrvProfString("Startpath","") + cLogo,55,35)
			oPrn:SayBitmap(nPixLin,NMAXCOL-65, GetSrvProfString("Startpath","") + cCartCorp,55,35)
			oPrn:Say(nPixLin+=15,nPixCol+100,PadC("CÓDIGOS DE BARRAS PARA COLETA DE DADOS",150),oFont14n)
			oPrn:Say(nPixLin+=15,nPixCol+075,"",oFont10n)
	
			oPrn:Line(nPixLin+=15,nPixCol,nPixLin,NMAXCOL)
			
			oPrn:Say(nPixLin+=10,nPixCol+005,"NORMA ADMINISTRATIVA / OPERACIONAL",oFont08)
			oPrn:Say(nPixLin    ,nPixCol+200,"| Documento de auxílio para coleta de dados via código de barras | QR Code",oFont08n)
			oPrn:Say(nPixLin+02 ,NMAXCOL-36,"Página: " + StrZero(nPage, 3),oFont07)
			
			oPrn:Line(nPixLin+=06,nPixCol,nPixLin,NMAXCOL)
		EndIf
	
		oPrn:Say(nPixLin + 02 + 14,NMINCOL + 005,"Ordem de Produção: " + AllTrim( BARRAS->C2_NUM ) + " - " + AllTrim( BARRAS->C2_ITEM ) + " - " + AllTrim( BARRAS->C2_SEQUEN ) + " Produto: " + AllTrim( BARRAS->C2_PRODUTO ) + " Descrição: " + AllTrim( BARRAS->B1_DESC ),oFont14n,,)
		oPrn:Line(nPixLin+=02 + 20,nPixCol,nPixLin,NMAXCOL)
	
		cQuery := "SELECT * " + CRLF
		cQuery += "FROM " + RetSqlName("SG2") + " AS SG2 WITH (NOLOCK) " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SH1") + " AS SH1 WITH (NOLOCK) ON H1_FILIAL = '" + xFilial("SH1") + "' " + CRLF
		cQuery += "  AND H1_CODIGO = G2_RECURSO " + CRLF
		cQuery += "  AND SH1.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SHB") + " AS SHB WITH (NOLOCK) ON HB_FILIAL = '" + xFilial("SHB") + "' " + CRLF
		cQuery += "  AND HB_COD = G2_CTRAB " + CRLF
		cQuery += "  AND SHB.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "WHERE G2_FILIAL = '" + xFilial("SG2") + "' " + CRLF
		cQuery += "AND G2_CODIGO = '" + BARRAS->C2_ROTEIRO + "' "  + CRLF
		cQuery += "AND G2_PRODUTO = '" + BARRAS->C2_PRODUTO + "' "  + CRLF
		cQuery += "AND SG2.D_E_L_E_T_ = ' ' " + CRLF
	
		TCQuery cQuery New Alias "OPERAC"
		dbSelectArea("OPERAC")
		OPERAC->( dbGoTop() )
	
		nQuadro := 0
		
		Do While !OPERAC->( Eof() )
			nQuadro += 1
			If nQuadro == 1
				If nPixLin > 520
					oPrn:EndPage()
					nPage += 1
					nPixLin	:= NMINLIN
					nPixCol	:= NMINCOL
			
					oPrn:StartPage()
			
					oPrn:Box(nPixLin,nPixCol,NMAXLIN,NMAXCOL)
					
					oPrn:SayBitmap(nPixLin+=10,nPixCol+10, GetSrvProfString("Startpath","") + cLogo,55,35)
					oPrn:SayBitmap(nPixLin,NMAXCOL-65, GetSrvProfString("Startpath","") + cCartCorp,55,35)
					oPrn:Say(nPixLin+=15,nPixCol+100,PadC("CÓDIGOS DE BARRAS PARA COLETA DE DADOS",150),oFont14n)
					oPrn:Say(nPixLin+=15,nPixCol+075,"",oFont10n)
			
					oPrn:Line(nPixLin+=15,nPixCol,nPixLin,NMAXCOL)
					
					oPrn:Say(nPixLin+=10,nPixCol+005,"NORMA ADMINISTRATIVA / OPERACIONAL",oFont08)
					oPrn:Say(nPixLin    ,nPixCol+200,"| Documento de auxílio para coleta de dados via código de barras | QR Code",oFont08n)
					oPrn:Say(nPixLin+02 ,NMAXCOL-36,"Página: " + StrZero(nPage, 3),oFont07)
					
					oPrn:Line(nPixLin+=06,nPixCol,nPixLin,NMAXCOL)
				EndIf
	
				nPixLin += 010
			EndIf
	
			oPrn:Box( nPixLin-010, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * nQuadro)-((NMAXCOL-NMINCOL)/4)      , nPixLin, nPixCol+(((NMAXCOL-NMINCOL)/4) * nQuadro))
			oPrn:Box( nPixLin, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * nQuadro)-((NMAXCOL-NMINCOL)/4)      , nPixLin+080, nPixCol+(((NMAXCOL-NMINCOL)/4) * nQuadro))
			oPrn:Box( nPixLin-010, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * (nQuadro+1))-((NMAXCOL-NMINCOL)/4)  , nPixLin, nPixCol+(((NMAXCOL-NMINCOL)/4) * (nQuadro+1)))
			oPrn:Box( nPixLin, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * (nQuadro+1))-((NMAXCOL-NMINCOL)/4)  , nPixLin+080, nPixCol+(((NMAXCOL-NMINCOL)/4) * (nQuadro+1)))
	
			oPrn:Say(nPixLin-002	,nPixCol+003+(((NMAXCOL-NMINCOL)/4) * nQuadro)-((NMAXCOL-NMINCOL)/4),"Operação: " + AllTrim( OPERAC->G2_OPERAC ) + " | " + AllTrim( OPERAC->G2_DESCRI )	,oFont07n,,CLR_BLUE)
			oPrn:DataMatrix(nPixCol+003+(((NMAXCOL-NMINCOL)/4) * nQuadro)-((NMAXCOL-NMINCOL)/4) + 075, nPixLin+048, OPERAC->G2_OPERAC, 40 )
			nQuadro += 1
			oPrn:Say(nPixLin-002	,nPixCol+003+(((NMAXCOL-NMINCOL)/4) * nQuadro)-((NMAXCOL-NMINCOL)/4),"Recurso: " + AllTrim( OPERAC->G2_RECURSO ) + " | " + AllTrim( OPERAC->H1_DESCRI )	,oFont07n,,CLR_GREEN)
			oPrn:DataMatrix(nPixCol+003+(((NMAXCOL-NMINCOL)/4) * nQuadro)-((NMAXCOL-NMINCOL)/4) + 075, nPixLin+048, OPERAC->G2_RECURSO, 40 )
	
			OPERAC->( dbSkip() )
	
			If nQuadro == 4 .Or. OPERAC->( Eof() )
				nQuadro := 0
				nPixLin += 080
			EndIf
		EndDo
		
		OPERAC->( dbCloseArea() )
	
		BARRAS->( dbSkip() )
	EndDo
	
	BARRAS->( dbCloseArea() )
Else
	oPrn:EndPage()
	RunBarra()
	//StartPrint()
EndIf

If nPixLin > 490
	oPrn:EndPage()
	nPage += 1
	nPixLin	:= CabPrint(nPage)
	nPixLin := CabPrIt(nPixLin,nPixCol)
EndIf

nPixLin := 500
oPrn:Box( nPixLin, nPixCol+000    , NMAXLIN, (NMAXCOL / 2))
oPrn:Box( nPixLin, (NMAXCOL / 2)  , NMAXLIN, NMAXCOL      )

oPrn:Box( nPixLin, nPixCol+000    , nPixLin+010, (NMAXCOL / 2)        )
oPrn:Box( nPixLin, (NMAXCOL / 2)  , nPixLin+010, NMAXCOL              )

nPixLin += 010
oPrn:Say(nPixLin-002	,nPixCol+003	    ,"Adições Extra-Fórmula"				,oFont07n,,CLR_RED)
If lQualidade
	oPrn:Say(nPixLin-002	,(NMAXCOL / 2)+003  ,"Aprovação"							,oFont07n,,CLR_RED)
Else
	oPrn:Say(nPixLin-002	,(NMAXCOL / 2)+003  ,"Observações (Justifique paradas não programadas e o período)", oFont07n,,CLR_RED)
EndIf

oPrn:Box( nPixLin, nPixCol+000        , nPixLin+010, nPixCol+055        )
oPrn:Box( nPixLin, nPixCol+055        , nPixLin+010, nPixCol+185        )
oPrn:Box( nPixLin, nPixCol+185        , nPixLin+010, nPixCol+255        )
oPrn:Box( nPixLin, nPixCol+255        , nPixLin+010, nPixCol+305        )
oPrn:Box( nPixLin, nPixCol+305        , nPixLin+010, (NMAXCOL / 2)      )

nPixLin += 010
oPrn:Say(nPixLin-002	,nPixCol+003	    ,"Código"				,oFont07n,,)
oPrn:Say(nPixLin-002	,nPixCol+058	    ,"Descrição"			,oFont07n,,)
oPrn:Say(nPixLin-002	,nPixCol+188	    ,"Quantidade"			,oFont07n,,)
oPrn:Say(nPixLin-002	,nPixCol+258	    ,"UM"					,oFont07n,,)
oPrn:Say(nPixLin-002	,nPixCol+308	    ,"Lote"					,oFont07n,,)

oPrn:Box( nPixLin    , nPixCol+000        , nPixLin+010, nPixCol+055        )
oPrn:Box( nPixLin    , nPixCol+055        , nPixLin+010, nPixCol+185        )
oPrn:Box( nPixLin    , nPixCol+185        , nPixLin+010, nPixCol+255        )
oPrn:Box( nPixLin    , nPixCol+255        , nPixLin+010, nPixCol+305        )
oPrn:Box( nPixLin    , nPixCol+305        , nPixLin+010, (NMAXCOL / 2)      )
oPrn:Box( nPixLin+010, nPixCol+000        , nPixLin+020, nPixCol+055        )
oPrn:Box( nPixLin+010, nPixCol+055        , nPixLin+020, nPixCol+185        )
oPrn:Box( nPixLin+010, nPixCol+185        , nPixLin+020, nPixCol+255        )
oPrn:Box( nPixLin+010, nPixCol+255        , nPixLin+020, nPixCol+305        )
oPrn:Box( nPixLin+010, nPixCol+305        , nPixLin+020, (NMAXCOL / 2)      )
oPrn:Box( nPixLin+020, nPixCol+000        , nPixLin+030, nPixCol+055        )
oPrn:Box( nPixLin+020, nPixCol+055        , nPixLin+030, nPixCol+185        )
oPrn:Box( nPixLin+020, nPixCol+185        , nPixLin+030, nPixCol+255        )
oPrn:Box( nPixLin+020, nPixCol+255        , nPixLin+030, nPixCol+305        )
oPrn:Box( nPixLin+020, nPixCol+305        , nPixLin+030, (NMAXCOL / 2)      )
oPrn:Box( nPixLin+030, nPixCol+000        , nPixLin+040, nPixCol+055        )
oPrn:Box( nPixLin+030, nPixCol+055        , nPixLin+040, nPixCol+185        )
oPrn:Box( nPixLin+030, nPixCol+185        , nPixLin+040, nPixCol+255        )
oPrn:Box( nPixLin+030, nPixCol+255        , nPixLin+040, nPixCol+305        )
oPrn:Box( nPixLin+030, nPixCol+305        , nPixLin+040, (NMAXCOL / 2)      )
oPrn:Box( nPixLin+040, nPixCol+000        , nPixLin+050, nPixCol+055        )
oPrn:Box( nPixLin+040, nPixCol+055        , nPixLin+050, nPixCol+185        )
oPrn:Box( nPixLin+040, nPixCol+185        , nPixLin+050, nPixCol+255        )
oPrn:Box( nPixLin+040, nPixCol+255        , nPixLin+050, nPixCol+305        )
oPrn:Box( nPixLin+040, nPixCol+305        , nPixLin+050, (NMAXCOL / 2)      )
oPrn:Box( nPixLin+050, nPixCol+000        , nPixLin+060, nPixCol+055        )
oPrn:Box( nPixLin+050, nPixCol+055        , nPixLin+060, nPixCol+185        )
oPrn:Box( nPixLin+050, nPixCol+185        , nPixLin+060, nPixCol+255        )
oPrn:Box( nPixLin+050, nPixCol+255        , nPixLin+060, nPixCol+305        )
oPrn:Box( nPixLin+050, nPixCol+305        , nPixLin+060, (NMAXCOL / 2)      )

If lQualidade
	oPrn:Box( nPixLin    , (NMAXCOL / 2)  , nPixLin+030, NMAXCOL              )

	oPrn:Say(nPixLin-003	,(NMAXCOL / 2)+003	,"APROVADO [   ]  REPROVADO [   ]  APROVADO COM RESTRIÇÕES [   ]  REPROCESSAR [   ]  ACERTO  COMERCIAL [   ]",oFont07n,,)
	oPrn:Say(nPixLin-002+012,(NMAXCOL / 2)+003  ,"Observações (Justifique paradas não programadas e o período)", oFont07n,,CLR_RED)
	oPrn:Say(nPixLin-003+040,(NMAXCOL / 2)+003  ,"Assinaturas Analista e Responsável"	,oFont07n,,CLR_RED)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fiinaliza a Pagina				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
Static Function CabPrint(nPage)

Local nLin		:= NMINLIN
Local nCol		:= NMINCOL
Local nZ		:= 0
Local cLogo		:= ""
Local cCartCorp	:= ""

DEFAULT nPage	:= 1

If cEmpAnt == "02"
	cLogo     := "logoeuro.bmp"
	cCartCorp := "coletor.jfif"
Else
	cLogo     := "logoqualy.bmp"
	cCartCorp := "coletor.jfif"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa a pagina    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrn:StartPage()	

oPrn:Box(nLin,nCol,NMAXLIN,NMAXCOL)

oPrn:SayBitmap(nLin+=10,nCol+10, GetSrvProfString("Startpath","") + cLogo,55,35)
oPrn:SayBitmap(nLin,NMAXCOL-65, GetSrvProfString("Startpath","") + cCartCorp,55,35)
oPrn:Say(nLin+=15,nCol+100,PadC("ORDEM DE PRODUÇÃO No. " + TMPCOM->C2_NUM + "-" + TMPCOM->C2_ITEM + "-" + TMPCOM->C2_SEQUEN + " PRODUTO: " + TMPCOM->C2_PRODUTO,150),oFont14n)
oPrn:Say(nLin+=15,nCol+150,PadC(Alltrim(SM0->M0_NOMECOM) + " - " + Alltrim(SM0->M0_FILIAL),150),oFont10n)
If Len( aEmpSaldo ) > 0
	oPrn:Say(nLin,nCol+060,"# Itens Sem Saldos [ * ] #",oFont10n,,CLR_HRED)
EndIf

oPrn:Line(nLin+=15,nCol,nLin,NMAXCOL)

oPrn:Say(nLin+=10,nCol+005,"NORMA ADMINISTRATIVA / OPERACIONAL",oFont08)
oPrn:Say(nLin    ,nCol+200,"| Este documento deve possuir a Ordem de Separação em anexo para cada Ordem de Produção",oFont08n)
oPrn:Say(nLin+02 ,NMAXCOL-36,"Página: " + StrZero(nPage, 3),oFont07)

oPrn:Line(nLin+=06,nCol,nLin,NMAXCOL)

nLinBoxCab := 60

oPrn:Box(nLin,NMINCOL,nLin + nLinBoxCab,NMINCOL + 200)
oPrn:Box(nLin,NMINCOL + 200,nLin + nLinBoxCab,NMAXCOL - 200)
oPrn:Box(nLin,NMAXCOL - 200,nLin + nLinBoxCab,NMAXCOL)

oPrn:Say(nLin+10,nCol+005,"ORDEM DE PRODUÇÃO:",oFont07n,,CLR_HRED)
oPrn:Say(nLin+20,nCol+005,"Número: " + TMPCOM->C2_NUM + " Item: " + TMPCOM->C2_ITEM + " Sequência: " + TMPCOM->C2_SEQUEN,oFont10n,,CLR_HBLUE)

cQuery := "SELECT CB7_ORDSEP FROM " + RetSqlName("CB7") + " WHERE CB7_FILIAL = '" + xFilial("CB7") + "' AND CB7_OP = '" + TMPCOM->C2_NUM + TMPCOM->C2_ITEM + TMPCOM->C2_SEQUEN + "' AND D_E_L_E_T_ = ' ' ORDER BY CB7_ORDSEP"
TCQuery cQuery New Alias "TMPSEP"
dbGoTop()

nSeqSep := 20
Do While !TMPSEP->( Eof() )
	nSeqSep += 10
	oPrn:Say(nLin+nSeqSep,nCol+005,"Ordem de Separação: " + TMPSEP->CB7_ORDSEP,oFont10,,CLR_BLUE)

	TMPSEP->( dbSkip() )
EndDo

TMPSEP->( dbCloseArea() )

oPrn:Say(nLin+10,NMINCOL + 200 + 005,"Produto:",oFont07n,,CLR_HRED)
oPrn:Say(nLin+10,NMINCOL + 200 + 080,AllTrim(TMPCOM->C2_PRODUTO),oFont07n)
oPrn:Say(nLin+20,NMINCOL + 200 + 005,"Descrição:",oFont07n,,CLR_HRED)
oPrn:Say(nLin+20,NMINCOL + 200 + 080,AllTrim(TMPCOM->B1_DESC),oFont07)
oPrn:Say(nLin+30,NMINCOL + 200 + 005,"Local:",oFont07n,,)
oPrn:Say(nLin+30,NMINCOL + 200 + 080,AllTrim(TMPCOM->C2_LOCAL),oFont07)
oPrn:Say(nLin+40,NMINCOL + 200 + 005,"Prev. Inicial:",oFont07n,,)
oPrn:Say(nLin+40,NMINCOL + 200 + 080,DTOC( STOD( TMPCOM->C2_DATPRI )),oFont07)
oPrn:Say(nLin+50,NMINCOL + 200 + 005,"Prev. Final:",oFont07n,,)
oPrn:Say(nLin+50,NMINCOL + 200 + 080,DTOC( STOD( TMPCOM->C2_DATPRF ) ),oFont07)

oPrn:Say(nLin+10,NMINCOL + 200 + 220,"Quantidade:",oFont07n,,)
oPrn:Say(nLin+10,NMINCOL + 200 + 270,Transform( TMPCOM->C2_QUANT, PesqPict("SC2","C2_QUANT")),oFontC7n)
oPrn:Say(nLin+30,NMINCOL + 200 + 220,"Unid. Medida:",oFont07n,,)
oPrn:Say(nLin+30,NMINCOL + 200 + 270,AllTrim( TMPCOM->B1_UM ),oFont07)
oPrn:Say(nLin+40,NMINCOL + 200 + 220,"2ª U.M.:",oFont07n,,)
oPrn:Say(nLin+40,NMINCOL + 200 + 270,AllTrim( TMPCOM->B1_SEGUM ),oFont07)
oPrn:Say(nLin+50,NMINCOL + 200 + 220,"Fator:",oFont07n,,)
oPrn:Say(nLin+50,NMINCOL + 200 + 270,AllTrim( Transform( TMPCOM->B1_CONV, PesqPict("SB1","B1_CONV")) ),oFont07)

oPrn:Say(nLin+10,NMAXCOL - 200 + 005,"Código de Barras:",oFont07n,,CLR_HRED)

oPrn:DataMatrix(NMAXCOL - 125 + 005, nLin+56, TMPCOM->C2_NUM + TMPCOM->C2_ITEM + TMPCOM->C2_SEQUEN, 55 )

oPrn:Say(nLin + nLinBoxCab + 14,NMINCOL + 005,"Roteiro de Operações: " + AllTrim( TMPCOM->C2_ROTEIRO ),oFont14n,,CLR_BLUE)

oPrn:Line(nLin+=nLinBoxCab + 20,nCol,nLin,NMAXCOL)

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
Static Function CabPrIt(nLin,nCol)

oPrn:Box(nLin,nCol+000,nLin + 10,nCol+035)
oPrn:Box(nLin,nCol+035,nLin + 10,nCol+185)
oPrn:Box(nLin,nCol+185,nLin + 10,nCol+225)
oPrn:Box(nLin,nCol+225,nLin + 10,nCol+375)
oPrn:Box(nLin,nCol+375,nLin + 10,nCol+415)
oPrn:Box(nLin,nCol+415,nLin + 10,nCol+575)
oPrn:Box(nLin,nCol+575,nLin + 10,nCol+675)
oPrn:Box(nLin,nCol+675,nLin + 10,NMAXCOL)

nLin += 008
oPrn:Say(nLin-001	,nCol+005	,"Operação"			,oFont07n,,)
oPrn:Say(nLin-001	,nCol+042	,"Descrição"		,oFont07n,,)
oPrn:Say(nLin-001	,nCol+187	,"Recurso"			,oFont07n,,)
oPrn:Say(nLin-001	,nCol+227	,"Desc. Recurso"	,oFont07n,,)
oPrn:Say(nLin-001	,nCol+377	,"C. Trabalho"		,oFont07n,,)
oPrn:Say(nLin-001	,nCol+417	,"Nome"				,oFont07n,,)
oPrn:Say(nLin-001	,nCol+577	,"Dt./Hr. Início"	,oFont07n,,)
oPrn:Say(nLin-001	,nCol+677	,"Dt./Hr. Final"	,oFont07n,,)

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

Static Function ValidPerg()

Local _aArea := GetArea()
Local _aPerg := {}
Local i      := 0

cPerg := Padr( cPerg, 10)

aAdd(_aPerg, {cPerg, "01", "Da Ordem Produção  ?", "MV_CH1" , "C", 11	, 0	, "G", "MV_PAR01", "SC2",""           ,""               ,""               ,""     ,""})
aAdd(_aPerg, {cPerg, "02", "Até Ordem Produção ?", "MV_CH2" , "C", 11	, 0	, "G", "MV_PAR02", "SC2",""           ,""               ,""               ,""     ,""})

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

Static Function RunBarra()

Local nPixLin	:= NMINLIN
Local nPixCol	:= NMINCOL
Local nPage		:= 1
Local lSaida	:= .F.

If cEmpAnt == "02"
	cLogo     := "logoeuro.bmp"
	cCartCorp := "coletor.jfif"
Else
	cLogo     := "logoqualy.bmp"
	cCartCorp := "coletor.jfif"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa a pagina    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrn:StartPage()

oPrn:Box(nPixLin,nPixCol,NMAXLIN,NMAXCOL)

oPrn:SayBitmap(nPixLin+=10,nPixCol+10, GetSrvProfString("Startpath","") + cLogo,55,35)
oPrn:SayBitmap(nPixLin,NMAXCOL-65, GetSrvProfString("Startpath","") + cCartCorp,55,35)
oPrn:Say(nPixLin+=15,nPixCol+100,PadC("CÓDIGOS DE BARRAS PARA COLETA DE DADOS",150),oFont14n)
oPrn:Say(nPixLin+=15,nPixCol+075,"",oFont10n)

oPrn:Line(nPixLin+=15,nPixCol,nPixLin,NMAXCOL)

oPrn:Say(nPixLin+=10,nPixCol+005,"NORMA ADMINISTRATIVA / OPERACIONAL",oFont08)
oPrn:Say(nPixLin    ,nPixCol+200,"| Documento de auxílio para coleta de dados via código de barras | QR Code",oFont08n)
oPrn:Say(nPixLin+02 ,NMAXCOL-36,"Página: " + StrZero(nPage, 3),oFont07)

oPrn:Line(nPixLin+=06,nPixCol,nPixLin,NMAXCOL)

oPrn:Say(nPixLin + 02 + 14,NMINCOL + 005,"TRANSAÇÕES PARA APONTAMENTOS DE OPERAÇÕES - ORDEM DE PRODUÇÃO",oFont14n,,CLR_RED)
oPrn:Line(nPixLin+=02 + 20,nPixCol,nPixLin,NMAXCOL)

nPixLin += 010

oPrn:Box( nPixLin-010, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * 1)-((NMAXCOL-NMINCOL)/4)      , nPixLin, nPixCol+(((NMAXCOL-NMINCOL)/4) * 1))
oPrn:Box( nPixLin, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * 1)-((NMAXCOL-NMINCOL)/4)      , nPixLin+100, nPixCol+(((NMAXCOL-NMINCOL)/4) * 1))

oPrn:Box( nPixLin-010, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * (2))-((NMAXCOL-NMINCOL)/4)  , nPixLin, nPixCol+(((NMAXCOL-NMINCOL)/4) * (2)))
oPrn:Box( nPixLin, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * (2))-((NMAXCOL-NMINCOL)/4)  , nPixLin+100, nPixCol+(((NMAXCOL-NMINCOL)/4) * (2)))

oPrn:Box( nPixLin-010, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * (3))-((NMAXCOL-NMINCOL)/4)  , nPixLin, nPixCol+(((NMAXCOL-NMINCOL)/4) * (3)))
oPrn:Box( nPixLin, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * (3))-((NMAXCOL-NMINCOL)/4)  , nPixLin+100, nPixCol+(((NMAXCOL-NMINCOL)/4) * (3)))

oPrn:Box( nPixLin-010, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * (4))-((NMAXCOL-NMINCOL)/4)  , nPixLin, nPixCol+(((NMAXCOL-NMINCOL)/4) * (4)))
oPrn:Box( nPixLin, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * (4))-((NMAXCOL-NMINCOL)/4)  , nPixLin+100, nPixCol+(((NMAXCOL-NMINCOL)/4) * (4)))

oPrn:Say(nPixLin-002	,nPixCol+003+(((NMAXCOL-NMINCOL)/4) * 1)-((NMAXCOL-NMINCOL)/4),"01 - Iniciar Produção",oFont07n,,CLR_RED)
oPrn:DataMatrix(nPixCol+003+(((NMAXCOL-NMINCOL)/4) * 1)-((NMAXCOL-NMINCOL)/4) + 075, nPixLin+048, "01", 40 )

oPrn:Say(nPixLin-002	,nPixCol+003+(((NMAXCOL-NMINCOL)/4) * 2)-((NMAXCOL-NMINCOL)/4),"02 - Iniciar Pausa/Parada",oFont07n,,CLR_RED)
oPrn:DataMatrix(nPixCol+003+(((NMAXCOL-NMINCOL)/4) * 2)-((NMAXCOL-NMINCOL)/4) + 075, nPixLin+048, "02", 40 )

oPrn:Say(nPixLin-002	,nPixCol+003+(((NMAXCOL-NMINCOL)/4) * 3)-((NMAXCOL-NMINCOL)/4),"02 - Finalizar Pausa/Parada",oFont07n,,CLR_RED)
oPrn:DataMatrix(nPixCol+003+(((NMAXCOL-NMINCOL)/4) * 3)-((NMAXCOL-NMINCOL)/4) + 075, nPixLin+048, "02", 40 )

//oPrn:Say(nPixLin-002	,nPixCol+003+(((NMAXCOL-NMINCOL)/4) * 4)-((NMAXCOL-NMINCOL)/4),"04 - Apontamento Operação/Produção",oFont07n,,CLR_RED)
oPrn:Say(nPixLin-002	,nPixCol+003+(((NMAXCOL-NMINCOL)/4) * 4)-((NMAXCOL-NMINCOL)/4),"04 - Finalizar Produção",oFont07n,,CLR_RED)
oPrn:DataMatrix(nPixCol+003+(((NMAXCOL-NMINCOL)/4) * 4)-((NMAXCOL-NMINCOL)/4) + 075, nPixLin+048, "04", 40 )

nPixLin += 100

cQuery := "SELECT * " + CRLF
cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
cQuery += "  AND B1_COD = C2_PRODUTO " + CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
cQuery += "AND C2_NUM = '" + cNumOP + "' " + CRLF
cQuery += "AND C2_ITEM + C2_SEQUEN = '01001' " + CRLF // Teste só com a PI na regra da Qualy...
cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "ORDER BY C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO " + CRLF

TCQuery cQuery New Alias "BARRAS"
dbSelectArea("BARRAS")
BARRAS->( dbGoTop() )

Do While !BARRAS->( Eof() )
	If nPixLin > 510
		oPrn:EndPage()
		nPage += 1
		nPixLin	:= NMINLIN
		nPixCol	:= NMINCOL

		oPrn:StartPage()

		oPrn:Box(nPixLin,nPixCol,NMAXLIN,NMAXCOL)
		
		oPrn:SayBitmap(nPixLin+=10,nPixCol+10, GetSrvProfString("Startpath","") + cLogo,55,35)
		oPrn:SayBitmap(nPixLin,NMAXCOL-65, GetSrvProfString("Startpath","") + cCartCorp,55,35)
		oPrn:Say(nPixLin+=15,nPixCol+100,PadC("CÓDIGOS DE BARRAS PARA COLETA DE DADOS",150),oFont14n)
		oPrn:Say(nPixLin+=15,nPixCol+075,"",oFont10n)

		oPrn:Line(nPixLin+=15,nPixCol,nPixLin,NMAXCOL)
		
		oPrn:Say(nPixLin+=10,nPixCol+005,"NORMA ADMINISTRATIVA / OPERACIONAL",oFont08)
		oPrn:Say(nPixLin    ,nPixCol+200,"| Documento de auxílio para coleta de dados via código de barras | QR Code",oFont08n)
		oPrn:Say(nPixLin+02 ,NMAXCOL-36,"Página: " + StrZero(nPage, 3),oFont07)
		
		oPrn:Line(nPixLin+=06,nPixCol,nPixLin,NMAXCOL)
	EndIf

	oPrn:Say(nPixLin + 02 + 14,NMINCOL + 005,"Ordem de Produção: " + AllTrim( BARRAS->C2_NUM ) + " - " + AllTrim( BARRAS->C2_ITEM ) + " - " + AllTrim( BARRAS->C2_SEQUEN ) + " Produto: " + AllTrim( BARRAS->C2_PRODUTO ) + " Descrição: " + AllTrim( BARRAS->B1_DESC ),oFont14n,,)
	oPrn:Line(nPixLin+=02 + 20,nPixCol,nPixLin,NMAXCOL)

	cQuery := "SELECT * " + CRLF
	cQuery += "FROM " + RetSqlName("SG2") + " AS SG2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SH1") + " AS SH1 WITH (NOLOCK) ON H1_FILIAL = '" + xFilial("SH1") + "' " + CRLF
	cQuery += "  AND H1_CODIGO = G2_RECURSO " + CRLF
	cQuery += "  AND SH1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SHB") + " AS SHB WITH (NOLOCK) ON HB_FILIAL = '" + xFilial("SHB") + "' " + CRLF
	cQuery += "  AND HB_COD = G2_CTRAB " + CRLF
	cQuery += "  AND SHB.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE G2_FILIAL = '" + xFilial("SG2") + "' " + CRLF
	cQuery += "AND G2_CODIGO = '" + BARRAS->C2_ROTEIRO + "' "  + CRLF
	cQuery += "AND G2_PRODUTO = '" + BARRAS->C2_PRODUTO + "' "  + CRLF
	cQuery += "AND SG2.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "OPERAC"
	dbSelectArea("OPERAC")
	OPERAC->( dbGoTop() )

	nQuadro := 0
	
	Do While !OPERAC->( Eof() )
		nQuadro += 1
		If nQuadro == 1
			If nPixLin > 520
				oPrn:EndPage()
				nPage += 1
				nPixLin	:= NMINLIN
				nPixCol	:= NMINCOL
		
				oPrn:StartPage()
		
				oPrn:Box(nPixLin,nPixCol,NMAXLIN,NMAXCOL)
				
				oPrn:SayBitmap(nPixLin+=10,nPixCol+10, GetSrvProfString("Startpath","") + cLogo,55,35)
				oPrn:SayBitmap(nPixLin,NMAXCOL-65, GetSrvProfString("Startpath","") + cCartCorp,55,35)
				oPrn:Say(nPixLin+=15,nPixCol+100,PadC("CÓDIGOS DE BARRAS PARA COLETA DE DADOS",150),oFont14n)
				oPrn:Say(nPixLin+=15,nPixCol+075,"",oFont10n)
		
				oPrn:Line(nPixLin+=15,nPixCol,nPixLin,NMAXCOL)
				
				oPrn:Say(nPixLin+=10,nPixCol+005,"NORMA ADMINISTRATIVA / OPERACIONAL",oFont08)
				oPrn:Say(nPixLin    ,nPixCol+200,"| Documento de auxílio para coleta de dados via código de barras | QR Code",oFont08n)
				oPrn:Say(nPixLin+02 ,NMAXCOL-36,"Página: " + StrZero(nPage, 3),oFont07)
				
				oPrn:Line(nPixLin+=06,nPixCol,nPixLin,NMAXCOL)
			EndIf

			nPixLin += 010
		EndIf

		oPrn:Box( nPixLin-010, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * nQuadro)-((NMAXCOL-NMINCOL)/4)      , nPixLin, nPixCol+(((NMAXCOL-NMINCOL)/4) * nQuadro))
		oPrn:Box( nPixLin, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * nQuadro)-((NMAXCOL-NMINCOL)/4)      , nPixLin+100, nPixCol+(((NMAXCOL-NMINCOL)/4) * nQuadro))
		oPrn:Box( nPixLin-010, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * (nQuadro+1))-((NMAXCOL-NMINCOL)/4)  , nPixLin, nPixCol+(((NMAXCOL-NMINCOL)/4) * (nQuadro+1)))
		oPrn:Box( nPixLin, nPixCol+000+(((NMAXCOL-NMINCOL)/4) * (nQuadro+1))-((NMAXCOL-NMINCOL)/4)  , nPixLin+100, nPixCol+(((NMAXCOL-NMINCOL)/4) * (nQuadro+1)))

		oPrn:Say(nPixLin-002	,nPixCol+003+(((NMAXCOL-NMINCOL)/4) * nQuadro)-((NMAXCOL-NMINCOL)/4),"Operação: " + AllTrim( OPERAC->G2_OPERAC ) + " | " + AllTrim( OPERAC->G2_DESCRI )	,oFont07n,,CLR_BLUE)
		oPrn:DataMatrix(nPixCol+003+(((NMAXCOL-NMINCOL)/4) * nQuadro)-((NMAXCOL-NMINCOL)/4) + 075, nPixLin+048, OPERAC->G2_OPERAC, 40 )
		nQuadro += 1
		oPrn:Say(nPixLin-002	,nPixCol+003+(((NMAXCOL-NMINCOL)/4) * nQuadro)-((NMAXCOL-NMINCOL)/4),"Recurso: " + AllTrim( OPERAC->G2_RECURSO ) + " | " + AllTrim( OPERAC->H1_DESCRI )	,oFont07n,,CLR_GREEN)
		oPrn:DataMatrix(nPixCol+003+(((NMAXCOL-NMINCOL)/4) * nQuadro)-((NMAXCOL-NMINCOL)/4) + 075, nPixLin+048, OPERAC->G2_RECURSO, 40 )

		OPERAC->( dbSkip() )

		If nQuadro == 4 .Or. OPERAC->( Eof() )
			nQuadro := 0
			nPixLin += 100
		EndIf
	EndDo
	
	OPERAC->( dbCloseArea() )

	BARRAS->( dbSkip() )
EndDo

BARRAS->( dbCloseArea() )

nPixLin := 560
oPrn:Box( nPixLin, nPixCol+000    , nPixLin+010, NMAXCOL)
nPixLin += 010
oPrn:Say(nPixLin-002	,nPixCol+003	    ,"Código para Motivos de Paradas e Pausas"	,oFont07n,,CLR_HRED)
oPrn:Box( nPixLin, nPixCol+000    , nPixLin+010, NMAXCOL)
nPixLin += 010
oPrn:Say(nPixLin-003	,nPixCol+003	    ,"PR - Parada Refeição | FT - Fim de Turno | FE - Falta Energia Elétrica | FM - Falta Matéria-Prima | FO - Falta Operador | FS - Falta de Serviço",oFont07,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fiinaliza a Pagina				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrn:EndPage()   		

Return