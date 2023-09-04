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
#DEFINE	 NMAXLIN   	820
#DEFINE	 NMAXCOL   	580

#DEFINE	 REL_NAME	"Ordem de Produção"
#DEFINE  REL_PATH	"c:\temp\"

User Function EQNewOP2( _cNumOP )

Local nY			:= 0

Private oFont06,oFont07,oFont07n,oFont08,oFont08n,oFont09,oFont09n,oFont10,oFont10n,oFont12,oFont12n,oFont14,oFont14n,oFont16,oFont16n,oFontC7,oFontC7n,oFontCAn
Private oPrn 		:= Nil
Private oSetup		:= Nil
Private cRelName    := ""
Private cPerg	    := "QEOP001"
Private lPrimeiro   := .T.
Private lQualidade  := .T.
Private cNumOP      := ""
Private oBrush      := TBrush():New(,CLR_BLUE,,)
Private oBrusCin    := TBrush():New(,CLR_HGRAY,,)
Private nPage       := 0
Private nPagina     := 0
Private nPagOP      := 0

Default _cNumOP     := ""

MakeDir( "C:\Temp\" )

ValidPerg()

If !Pergunte(cPerg,.T.)
	Return
EndIf

If Empty( _cNumOP )
	_cNumOP := mv_par01
EndIf

cNumOP  := AllTrim( _cNumOP )
cNumAte := AllTrim( mv_par02 )

If PrepPrint()
	RptStatus({|| ExecPrint() },"Imprimindo Ordem de Produção...")
EndIf

Return

/*
¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹
¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À
¡À¡À¨²?????????????????????????????????????????????????????????????????????????¡À¡À
¡À¡À3Fun?¡­o    3PrepPrint 3 Autor 3 Rodrigo Sousa         3 Data 3 02/06/20153¡À¡À
¡À¡À??????????????????????¨¢???????¨¢???????????????????????¨¢??????¨¢???????????¡ä¡À¡À
¡À¡À3Descri?¡­o 3 Parametros da rotina.                					   3¡À¡À
¡À¡À¨¤??????????¨¢?????????????????????????????????????????????????????????????¨´¡À¡À
¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À
??????????????????????????????????????????????????????????????????????????????
*/

Static Function PrepPrint(cPathDest,cRelName)

Local nX	:= 0
Local lRet 	:= .T.

DEFAULT cPathDest   := REL_PATH
DEFAULT cRelName	:= REL_NAME

cRelName := "OP_" + AllTrim( cNumOP ) + "_"  + DTOS( dDataBase ) + "_" + Replace( Time(), ":", "") + ".PDF"

//¨²?????????????????????????????????
//3Instancia os objetos de fonte   3
//¨¤????????????????????????????????¨´
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

//¨²?????????????????????????????????
//3Instancia a Classe FwMsPrinter  3
//¨¤????????????????????????????????¨´
oPrn := FwMsPrinter():New(cRelName,IMP_PDF,.F.,cPathDest,.T.,.F.,@oPrn,,,.F.,.F.,.T.,)
oPrn:SetResolution(72)
oPrn:SetPortrait()
oPrn:SetPaperSize(DMPAPER_A4)

oPrn:cPathPDF := cPathDest 			//Caso seja utilizada impress?o em IMP_PDF      

//¨²?????????????????????????????????
//3Instancia a Classe FWPrintSetup 3
//¨¤????????????????????????????????¨´
oSetup := FWPrintSetup():New(PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION+PD_DISABLEDESTINATION+PD_DISABLEPAPERSIZE+PD_DISABLEPREVIEW ,"EQNewOP2")
oSetup:SetUserParms({|| Pergunte(cPerg, .T.)})
oSetup:SetProperty(PD_MARGIN,{05,05,05,05})
oSetup:SetProperty(PD_DESTINATION,2) 

//¨²?????????????????????????????????
//3Ativa Tela de Setup		  	   3
//¨¤????????????????????????????????¨´
If oSetup:Activate() == 2
	lRet	:= .F.
EndIf

Return lRet

/*
¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹
¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À
¡À¡À¨²??????????????????????????????????????????????????????????????????????????¡À¡À
¡À¡À3Fun?¡­o    3ExecPrint   3 Autor 3 Rodrigo Sousa        3 Data 3 02/06/20153¡À¡À
¡À¡À????????????????????????¨¢???????¨¢??????????????????????¨¢??????¨¢???????????¡ä¡À¡À
¡À¡À3Descri?¡­o 3 Executa Impress?o.             		  	     				3¡À¡À
¡À¡À¨¤??????????¨¢??????????????????????????????????????????????????????????????¨´¡À¡À
¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À
???????????????????????????????????????????????????????????????????????????????
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
	If Left( cNumOP, 6) <> TMPCOM->C2_NUM
		cNumOP  := TMPCOM->C2_NUM + TMPCOM->C2_ITEM + TMPCOM->C2_SEQUEN
		nPage   := 1
		nPagina := 1
		If Mod( nPagOP, 2) <> 0
			oPrn:EndPage()
			oPrn:StartPage()
			nPagOP++
		EndIf
	Else
		nPage++
		nPagina++
	EndIf

	IncRegua("Imprimindo") 
	aEmpSaldo := {}

	cMsg := ""

	//cQuery := "SELECT D4_COD, SUM(D4_QUANT) AS QUANTIDADE, SUM(B2_QATU - B2_QEMP - B2_RESERVA) AS SALDO " + CRLF
	cQuery := "SELECT D4_COD, SUM(D4_QUANT) AS QUANTIDADE, SUM(B2_QATU) AS SALDO " + CRLF
	cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD4") + " AS SD4 WITH (NOLOCK) ON D4_FILIAL = C2_FILIAL " + CRLF
	cQuery += "  AND D4_OP = C2_NUM + C2_ITEM + C2_SEQUEN " + CRLF
	cQuery += "  AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = C2_PRODUTO " + CRLF
	cQuery += "  AND B1_TIPO <> 'PI' " + CRLF
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
		Aviso( "EQNEWOP2 - Aviso", "Ordem de Produção possui componentes sem saldo suficiente dispon¨ªvel:" + CRLF + cMsg, {"OK"}, 3)
	EndIf
	
	TMPSC2->( dbCloseArea() )

	lQualidade := .T.
	RunPrint()
	lProc	   := .T.
	TMPCOM->( dbSkip() )
	//If !TMPCOM->(EOF()) .And. AllTrim( cNumOP ) <> AllTrim( TMPCOM->C2_NUM )
	//	cNumOP := TMPCOM->C2_NUM + TMPCOM->C2_ITEM + TMPCOM->C2_SEQUEN
	//EndIf
EndDo

If lProc
	StartPrint()
Else
	ApMsgInfo('Não há dados!', 'Cosmotec')
EndIf

TMPCOM->( dbCloseArea() )

Return

/*
¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹
¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À
¡À¡À¨²?????????????????????????????????????????????????????????????????????????¡À¡À
¡À¡À3Fun?¡­o    3RunPrint  3 Autor 3 Rodrigo Sousa         3 Data 3 02/10/20113¡À¡À
¡À¡À??????????????????????¨¢???????¨¢???????????????????????¨¢??????¨¢???????????¡ä¡À¡À
¡À¡À3Descri?¡­o 3 Parametros da rotina.                					   3¡À¡À
¡À¡À¨¤??????????¨¢?????????????????????????????????????????????????????????????¨´¡À¡À
¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À
??????????????????????????????????????????????????????????????????????????????
*/
Static Function RunPrint()

Local nPixLin	:= NMINLIN
Local nPixCol	:= NMINCOL
Local lSaida	:= .F.

//¨²?????????????????????????????????????????????????????????????????
//3 Imprime Cabe?alho da Ordem de Separa??o						   3
//¨¤????????????????????????????????????????????????????????????????¨´
nPixLin			:= CabPrint(nPage)

//¨²?????????????????????????????????????????????????????????????????
//3 Imprime Cabe?alho dos Itens da Ordem de Separa??o			   3
//¨¤????????????????????????????????????????????????????????????????¨´
nPixLin := CabPrIt(nPixLin,nPixCol)

//¨²??????????????????????????????????
//3Fiinaliza a Pagina				3
//¨¤?????????????????????????????????¨´
oPrn:EndPage()   		

Return

/*
¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹
¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À
¡À¡À¨²?????????????????????????????????????????????????????????????????????????¡À¡À
¡À¡À3Fun?¡­o    3CabPrint	3 Autor 3 Rodrigo Sousa         3 Data 3 02/06/20153¡À¡À
¡À¡À??????????????????????¨¢???????¨¢???????????????????????¨¢??????¨¢???????????¡ä¡À¡À
¡À¡À3Descri?¡­o 3 Imprime Cabe?alho do Relat¨®rio							   3¡À¡À
¡À¡À¨¤??????????¨¢?????????????????????????????????????????????????????????????¨´¡À¡À
¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À
??????????????????????????????????????????????????????????????????????????????
*/
Static Function CabPrint(nPage)

Local nLin		:= NMINLIN
Local nCol		:= NMINCOL
Local nZ		:= 0
Local cLogo		:= ""
Local cCartCorp	:= ""
Local nSalta    := 0  // Para as opra??es 50 , ser¨¢ impresso minimo e maximo 

If cEmpAnt == "02"
	cLogo     := "logoeuro.bmp"
	cCartCorp := "coletor.jfif"
	cEmpresa  := "Euroamerican"
Else
	cLogo     := "logoqualy.bmp"
	cCartCorp := "coletor.jfif"
	cEmpresa  := "Qualycril"
EndIf

//¨²????????????????????????
//3Inicializa a pagina    3
//¨¤???????????????????????¨´
oPrn:StartPage()
nPagOP++

oPrn:Box(nLin+20,nCol,NMAXLIN,NMAXCOL)

oPrn:SayBitmap(nLin,nCol, GetSrvProfString("Startpath","") + cLogo,55,17)
oPrn:Say(nLin,nCol+065,AllTrim( SM0->M0_FILIAL ),oFont08)
oPrn:Say(nLin,nCol+050,PadC("ORDEM DE PRODUÇÃO",120),oFont14n)
//oPrn:Say(nLin,NMAXCOL-36,"P¨¢gina: " + StrZero(nPage, 3),oFont07)
oPrn:Say(nLin,NMAXCOL-36,"P¨¢gina: " + StrZero(nPagina, 3),oFont07)

oPrn:Say(nLin+=30,nCol+005,"PRODUTO: " + TMPCOM->C2_PRODUTO + ' ' + AllTrim(Posicione("SB1", 1, xFilial("SB1") + TMPCOM->C2_PRODUTO, "B1_DESC")),oFont08)
oPrn:Say(nLin,NMAXCOL-106,"Qtd. Prev. (KG): " + Transform( TMPCOM->C2_QUANT, "@E 999,999,999.99"),oFont08)
oPrn:Line(nLin+=10,nCol,nLin,NMAXCOL)
oPrn:Say(nLin+=10,nCol+005,"LOTE: " + TMPCOM->C2_NUM + " " + TMPCOM->C2_ITEM + " " + TMPCOM->C2_SEQUEN,oFont08)
oPrn:Say(nLin,NMAXCOL-106,"Quant. Real : ( ___________ )",oFont08)

cQuery := "SELECT CB7_ORDSEP FROM " + RetSqlName("CB7") + " WHERE CB7_FILIAL = '" + xFilial("CB7") + "' AND CB7_OP = '" + TMPCOM->C2_NUM + TMPCOM->C2_ITEM + TMPCOM->C2_SEQUEN + "' AND D_E_L_E_T_ = ' ' ORDER BY CB7_ORDSEP"
TCQuery cQuery New Alias "TMPSEP"
dbGoTop()

Do While !TMPSEP->( Eof() )
	oPrn:Say(nLin,nCol+155,"ORDEM DE SEP.: " + TMPSEP->CB7_ORDSEP,oFont08)
	TMPSEP->( dbSkip() )
EndDo

TMPSEP->( dbCloseArea() )

oPrn:Line(nLin+=10,nCol,nLin,NMAXCOL)

oPrn:Say(nLin+12,nCol+010,"# Itens Sem Saldos [ * ] #",oFont10n,,CLR_HRED)
oPrn:Say(nLin+22,nCol+010,"LOCAL: " + TMPCOM->C2_LOCAL,oFont08)
oPrn:Say(nLin+32,nCol+010,"PREV INICIAL: " + DTOC(STOD(TMPCOM->C2_DATPRI)),oFont08)
oPrn:Say(nLin+42,nCol+010,"PREV FINAL:   " + DTOC(STOD(TMPCOM->C2_DATPRI)),oFont08)

oPrn:DataMatrix(nCol+245, nLin+56, TMPCOM->C2_NUM + TMPCOM->C2_ITEM + TMPCOM->C2_SEQUEN, 55 )

oPrn:Box(nLin+10,nCol+393,nLin+48,NMAXCOL-25  )
oPrn:FillRect({nLin+12,nCol+395,nLin+46,NMAXCOL-27},oBrush)
oPrn:Say(nLin+21,nCol+410,"Etiqueta de Conferência"     ,oFont10n,,CLR_WHITE)
oPrn:Say(nLin+31,nCol+410,"Previsto vs Realizado"       ,oFont10n,,CLR_WHITE)
oPrn:Say(nLin+41,nCol+410,"    [ Colar Etiqueta ]"          ,oFont10n,,CLR_WHITE)

oPrn:Line(nLin+=60,nCol,nLin,NMAXCOL)

If TMPCOM->C2_ITEM + TMPCOM->C2_SEQUEN == "01001"
	cQuery := "SELECT G2_OPERAC, G2_RECURSO, G2_DESCRI, ISNULL(RTRIM(LTRIM(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),Z0_DESCRIC)))), '') AS INSTRUCAO, Z0_SEQINI, Z0_SEQFIN "
	cQuery += "FROM " + RetSqlName("SG2") + " AS SG2 WITH (NOLOCK) "
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery += "  AND B1_COD = G2_PRODUTO "
	cQuery += "  AND ((B1_EQ_DISP <> 'N' AND B1_EQ_COMP <> 'N') OR (B1_EQ_DISP = 'N' AND B1_EQ_COMP = 'N')) "
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("SH1") + " AS SH1 WITH (NOLOCK) ON H1_FILIAL = '" + xFilial("SH1") + "' "
	cQuery += "  AND H1_CODIGO = G2_RECURSO "
	cQuery += "  AND SH1.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("SHB") + " AS SHB WITH (NOLOCK) ON HB_FILIAL = '" + xFilial("SHB") + "' "
	cQuery += "  AND HB_COD = G2_CTRAB "
	cQuery += "  AND SHB.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("SZ0") + " AS SZ0 WITH (NOLOCK) ON Z0_FILIAL = '" + xFilial("SZ0") + "' "
	cQuery += "  AND Z0_PRODUTO = G2_PRODUTO "
	cQuery += "  AND Z0_OPERAC = G2_OPERAC "
	cQuery += "  AND SZ0.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE G2_FILIAL = '" + xFilial("SG2") + "' "
	cQuery += "AND G2_CODIGO = '" + TMPCOM->C2_ROTEIRO + "' " 
	cQuery += "AND G2_PRODUTO = '" + TMPCOM->C2_PRODUTO + "' " 
	cQuery += "AND SG2.D_E_L_E_T_ = ' ' "
	cQuery += "UNION ALL "
	cQuery += "SELECT G2_OPERAC, G2_RECURSO, G2_DESCRI, ISNULL(RTRIM(LTRIM(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),Z0_DESCRIC)))), '') AS INSTRUCAO, '001' AS Z0_SEQINI, Z0_SEQFIN "
	cQuery += "FROM " + RetSqlName("SG2") + " AS SG2 WITH (NOLOCK) "
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery += "  AND B1_COD = G2_PRODUTO "
	cQuery += "  AND B1_EQ_DISP = 'N' "
	cQuery += "  AND B1_EQ_COMP <> 'N' "
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("SH1") + " AS SH1 WITH (NOLOCK) ON H1_FILIAL = '" + xFilial("SH1") + "' "
	cQuery += "  AND H1_CODIGO = G2_RECURSO "
	cQuery += "  AND SH1.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("SHB") + " AS SHB WITH (NOLOCK) ON HB_FILIAL = '" + xFilial("SHB") + "' "
	cQuery += "  AND HB_COD = G2_CTRAB "
	cQuery += "  AND SHB.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("SZ0") + " AS SZ0 WITH (NOLOCK) ON Z0_FILIAL = '" + xFilial("SZ0") + "' "
	cQuery += "  AND Z0_PRODUTO = G2_PRODUTO "
	cQuery += "  AND Z0_OPERAC = G2_OPERAC "
	cQuery += "  AND Z0_OPERAC <> '20' "
	cQuery += "  AND Z0_OPERAC <> '40' "
	cQuery += "  AND SZ0.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE G2_FILIAL = '" + xFilial("SG2") + "' "
	cQuery += "AND G2_CODIGO = '" + TMPCOM->C2_ROTEIRO + "' " 
	cQuery += "AND G2_PRODUTO = '" + TMPCOM->C2_PRODUTO + "' " 
	cQuery += "AND SG2.D_E_L_E_T_ = ' ' "
	cQuery += "UNION ALL "
	cQuery += "SELECT G2_OPERAC, G2_RECURSO, G2_DESCRI, ISNULL(RTRIM(LTRIM(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),Z0_DESCRIC)))), '') AS INSTRUCAO, Z0_SEQINI, '099' AS Z0_SEQFIN "
	cQuery += "FROM " + RetSqlName("SG2") + " AS SG2 WITH (NOLOCK) "
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery += "  AND B1_COD = G2_PRODUTO "
	cQuery += "  AND B1_EQ_DISP <> 'N' "
	cQuery += "  AND B1_EQ_COMP = 'N' "
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("SH1") + " AS SH1 WITH (NOLOCK) ON H1_FILIAL = '" + xFilial("SH1") + "' "
	cQuery += "  AND H1_CODIGO = G2_RECURSO "
	cQuery += "  AND SH1.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("SHB") + " AS SHB WITH (NOLOCK) ON HB_FILIAL = '" + xFilial("SHB") + "' "
	cQuery += "  AND HB_COD = G2_CTRAB "
	cQuery += "  AND SHB.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("SZ0") + " AS SZ0 WITH (NOLOCK) ON Z0_FILIAL = '" + xFilial("SZ0") + "' "
	cQuery += "  AND Z0_PRODUTO = G2_PRODUTO "
	cQuery += "  AND Z0_OPERAC = G2_OPERAC "
	cQuery += "  AND Z0_OPERAC <> '30' "
	cQuery += "  AND Z0_OPERAC <> '40' "
	cQuery += "  AND SZ0.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE G2_FILIAL = '" + xFilial("SG2") + "' "
	cQuery += "AND G2_CODIGO = '" + TMPCOM->C2_ROTEIRO + "' " 
	cQuery += "AND G2_PRODUTO = '" + TMPCOM->C2_PRODUTO + "' " 
	cQuery += "AND SG2.D_E_L_E_T_ = ' ' "
	cQuery += "UNION ALL "
	cQuery += "SELECT G2_OPERAC, G2_RECURSO, G2_DESCRI, ISNULL(RTRIM(LTRIM(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),Z0_DESCRIC)))), '') AS INSTRUCAO, Z0_SEQINI AS Z0_SEQINI, Z0_SEQFIN "
	cQuery += "FROM " + RetSqlName("SG2") + " AS SG2 WITH (NOLOCK) "
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery += "  AND B1_COD = G2_PRODUTO "
	cQuery += "  AND ((B1_EQ_DISP = 'N' AND B1_EQ_COMP <> 'N') "
	cQuery += "  OR (B1_EQ_DISP <> 'N' AND B1_EQ_COMP = 'N')) "
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("SH1") + " AS SH1 WITH (NOLOCK) ON H1_FILIAL = '" + xFilial("SH1") + "' "
	cQuery += "  AND H1_CODIGO = G2_RECURSO "
	cQuery += "  AND SH1.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("SHB") + " AS SHB WITH (NOLOCK) ON HB_FILIAL = '" + xFilial("SHB") + "' "
	cQuery += "  AND HB_COD = G2_CTRAB "
	cQuery += "  AND SHB.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("SZ0") + " AS SZ0 WITH (NOLOCK) ON Z0_FILIAL = '" + xFilial("SZ0") + "' "
	cQuery += "  AND Z0_PRODUTO = G2_PRODUTO "
	cQuery += "  AND Z0_OPERAC = G2_OPERAC "
	cQuery += "  AND Z0_OPERAC <> '20' "
	cQuery += "  AND Z0_OPERAC <> '30' "
	cQuery += "  AND SZ0.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE G2_FILIAL = '" + xFilial("SG2") + "' "
	cQuery += "AND G2_CODIGO = '" + TMPCOM->C2_ROTEIRO + "' " 
	cQuery += "AND G2_PRODUTO = '" + TMPCOM->C2_PRODUTO + "' " 
	cQuery += "AND SG2.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY G2_OPERAC "
Else
	cQuery := "SELECT G2_OPERAC, G2_RECURSO, G2_DESCRI, ISNULL(RTRIM(LTRIM(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),Z0_DESCRIC)))), 'Envase Manual') AS INSTRUCAO, ISNULL( Z0_SEQINI, '001') AS Z0_SEQINI, ISNULL( Z0_SEQFIN, '999') AS Z0_SEQFIN "
	cQuery += "FROM " + RetSqlName("SG2") + " AS SG2 WITH (NOLOCK) "
	cQuery += "INNER JOIN " + RetSqlName("SH1") + " AS SH1 WITH (NOLOCK) ON H1_FILIAL = '" + xFilial("SH1") + "' "
	cQuery += "  AND H1_CODIGO = G2_RECURSO "
	cQuery += "  AND SH1.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("SHB") + " AS SHB WITH (NOLOCK) ON HB_FILIAL = '" + xFilial("SHB") + "' "
	cQuery += "  AND HB_COD = G2_CTRAB "
	cQuery += "  AND SHB.D_E_L_E_T_ = ' ' "
	cQuery += "LEFT JOIN " + RetSqlName("SZ0") + " AS SZ0 WITH (NOLOCK) ON Z0_FILIAL = '" + xFilial("SZ0") + "' "
	cQuery += "  AND Z0_PRODUTO = G2_PRODUTO "
	cQuery += "  AND Z0_OPERAC = G2_OPERAC "
	cQuery += "  AND SZ0.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE G2_FILIAL = '" + xFilial("SG2") + "' "
	cQuery += "AND G2_CODIGO = '" + TMPCOM->C2_ROTEIRO + "' " 
	cQuery += "AND G2_PRODUTO = '" + TMPCOM->C2_PRODUTO + "' " 
	cQuery += "AND SG2.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY G2_OPERAC "
EndIf

TCQuery cQuery New Alias "TMPROT"
dbSelectArea("TMPROT")
dbGoTop()

nLin += 008

Do While !TMPROT->( Eof() )
	
	If TMPROT->G2_OPERAC == '50' // Quando conter a opera??o 50 ira incrementar a numera??o 
		nSalta++
	Endif 

	oPrn:Say(nLin+=10,nCol+050,"Operação: " + TMPROT->G2_OPERAC,oFont08)
	oPrn:DataMatrix(nCol+050, nLin+56, TMPROT->G2_OPERAC , 55 )
	If mv_par03 == 1 .Or. AllTrim( TMPROT->G2_OPERAC ) == "40"
		oPrn:Say(nLin    ,nCol+430,"Recurso: " + TMPROT->G2_RECURSO,oFont08)
		oPrn:DataMatrix(nCol+430, nLin+56, TMPROT->G2_RECURSO, 55 )
	Else
		oPrn:Say(nLin    ,nCol+430,"Recurso Sugerido: " + TMPROT->G2_RECURSO,oFont08)
		oPrn:Box(nLin+10,nCol+430,nLin+48,nCol+500  )
		oPrn:FillRect({nLin+12,nCol+432,nLin+46,nCol+498},oBrusCin)
		oPrn:Say(nLin+21,nCol+435,"Coletar QR"     ,oFont10n,,CLR_WHITE)
		oPrn:Say(nLin+31,nCol+435,"Code no Quadro"       ,oFont10n,,CLR_WHITE)
		oPrn:Say(nLin+41,nCol+435,"do Recurso"          ,oFont10n,,CLR_WHITE)
		/*
oPrn:Box(nLin+10,nCol+393,nLin+48,NMAXCOL-25  )
oPrn:FillRect({nLin+12,nCol+395,nLin+46,NMAXCOL-27},oBrush)
oPrn:Say(nLin+21,nCol+410,"Etiqueta de Conferência"     ,oFont10n,,CLR_WHITE)
oPrn:Say(nLin+31,nCol+410,"Previsto vs Realizado"       ,oFont10n,,CLR_WHITE)
oPrn:Say(nLin+41,nCol+410,"    [ Colar Etiqueta ]"          ,oFont10n,,CLR_WHITE)

		*/
	EndIf
	oPrn:Say(nLin+10,nCol+050,PadC("OPERAÇÃO " + TMPROT->G2_OPERAC + " " + AllTrim( TMPROT->G2_DESCRI ),120),oFont14n)
	oPrn:Say(nLin+20,nCol+230,"Seq. Inicial: " + TMPROT->Z0_SEQINI + " Seq. Final: " + AllTrim( TMPROT->Z0_SEQFIN ),oFont08)

	oPrn:Line(nLin+=65,nCol,nLin,NMAXCOL)

	oPrn:Say(nLin+=10,nCol+005,TMPROT->INSTRUCAO,oFont08)

	oPrn:Line(nLin+=10,nCol,nLin,NMAXCOL)
    
	oPrn:Box(nLin,nCol+000,nLin + 10,nCol+035) // TRT
	oPrn:Box(nLin,nCol+035,nLin + 10,nCol+095) // C¨®digo
	oPrn:Box(nLin,nCol+095,nLin + 10,nCol+325) // Descri??o
	oPrn:Box(nLin,nCol+325,nLin + 10,nCol+425) // Quantidade
	oPrn:Box(nLin,nCol+425,nLin + 10,nCol+515) // Lote
	oPrn:Box(nLin,nCol+515,nLin + 10,NMAXCOL)  // Qtd. Real

	nLin += 008
	oPrn:Say(nLin-001	,nCol+005	,"TRT"												,oFont10n,,)
	oPrn:Say(nLin-001	,nCol+040	,"Código"											,oFont10n,,)
	oPrn:Say(nLin-001	,nCol+100	,"Descrição"										,oFont10n,,)
	oPrn:Say(nLin-001	,nCol+330	,"Quantidade"										,oFont10n,,)
	oPrn:Say(nLin-001	,nCol+430	,"Lote"												,oFont10n,,)
	oPrn:Say(nLin-001	,nCol+520	,"Qtd. Real"										,oFont10n,,)

	cQuery := "SELECT D4_TRT, D4_COD, B1_DESC, D4_QUANT, D4_LOTECTL "
	cQuery += "FROM " + RetSqlName("SD4") + " AS SD4 WITH (NOLOCK) "
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery += "  AND B1_COD = D4_COD "
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE D4_FILIAL = '" + xFilial("SD4") + "' "
	cQuery += "AND D4_OP = '" + TMPCOM->C2_NUM + TMPCOM->C2_ITEM + TMPCOM->C2_SEQUEN + "' "
	cQuery += "AND D4_TRT BETWEEN '" + TMPROT->Z0_SEQINI + "' AND '" + TMPROT->Z0_SEQFIN + "' "
	cQuery += "AND SD4.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY D4_TRT, D4_COD "

	TCQuery cQuery New Alias "TMPSD4"
	dbSelectArea("TMPSD4")
	dbGoTop()
	
	Do While !TMPSD4->( Eof() )
		oPrn:Box(nLin,nCol+000,nLin + 10,nCol+035) // TRT
		oPrn:Box(nLin,nCol+035,nLin + 10,nCol+095) // C¨®digo
		oPrn:Box(nLin,nCol+095,nLin + 10,nCol+325) // Descri??o
		oPrn:Box(nLin,nCol+325,nLin + 10,nCol+425) // Quantidade
		oPrn:Box(nLin,nCol+425,nLin + 10,nCol+515) // Lote
		oPrn:Box(nLin,nCol+515,nLin + 10,NMAXCOL)  // Qtd. Real

		cFalta := ""
		If aScan( aEmpSaldo, {|x| AllTrim( TMPSD4->D4_COD ) == AllTrim( x[1] ) }) > 0
			cFalta := " [ * ]"
		EndIf

		nLin += 008
		oPrn:Say(nLin-001	,nCol+005	,TMPSD4->D4_TRT											,oFont08,,)
		oPrn:Say(nLin-001	,nCol+040	,AllTrim( TMPSD4->D4_COD ) + cFalta						,oFont08,,)
		oPrn:Say(nLin-001	,nCol+100	,TMPSD4->B1_DESC										,oFont08,,)
		oPrn:Say(nLin-001	,nCol+345	,Transform( TMPSD4->D4_QUANT, "@E 999,999,999.999")		,oFontC7,,)
		oPrn:Say(nLin-001	,nCol+430	,TMPSD4->D4_LOTECTL										,oFont08,,)
		oPrn:Say(nLin-001	,nCol+520	,""														,oFont08,,)


		TMPSD4->( dbSkip() )

		If nLin > 684
			oPrn:EndPage()
			nPage++
			nPagina++
			nLin := NMINLIN
			nCol := NMINCOL
			oPrn:StartPage()
			nPagOP++
			oPrn:Box(nLin+20,nCol,NMAXLIN,NMAXCOL)
			oPrn:SayBitmap(nLin,nCol, GetSrvProfString("Startpath","") + cLogo,55,17)
			oPrn:Say(nLin,nCol+065,AllTrim( SM0->M0_FILIAL ),oFont08)
			oPrn:Say(nLin,nCol+050,PadC("ORDEM DE PRODUÇÃO",120),oFont14n)
			//oPrn:Say(nLin,NMAXCOL-36,"P¨¢gina: " + StrZero(nPage, 3),oFont07)
			oPrn:Say(nLin,NMAXCOL-36,"Página: " + StrZero(nPagina, 3),oFont07)
			oPrn:Say(nLin+=30,nCol+005,"PRODUTO: " + TMPCOM->C2_PRODUTO + ' ' + AllTrim(Posicione("SB1", 1, xFilial("SB1") + TMPCOM->C2_PRODUTO, "B1_DESC")),oFont08)
			oPrn:Say(nLin,NMAXCOL-106,"Qtd. Prev. (KG): " + Transform( TMPCOM->C2_QUANT, "@E 999,999,999.999"),oFont08)
			oPrn:Line(nLin+=10,nCol,nLin,NMAXCOL)
			oPrn:Say(nLin+=10,nCol+005,"LOTE: " + TMPCOM->C2_NUM + " " + TMPCOM->C2_ITEM + " " + TMPCOM->C2_SEQUEN,oFont08)
			cQuery := "SELECT CB7_ORDSEP FROM " + RetSqlName("CB7") + " WHERE CB7_FILIAL = '" + xFilial("CB7") + "' AND CB7_OP = '" + TMPCOM->C2_NUM + TMPCOM->C2_ITEM + TMPCOM->C2_SEQUEN + "' AND D_E_L_E_T_ = ' ' ORDER BY CB7_ORDSEP"
			TCQuery cQuery New Alias "TMPSEP"
			dbGoTop()
			Do While !TMPSEP->( Eof() )
				oPrn:Say(nLin,nCol+155,"ORDEM DE SEP.: " + TMPSEP->CB7_ORDSEP,oFont08)
				TMPSEP->( dbSkip() )
			EndDo
			TMPSEP->( dbCloseArea() )
			oPrn:Line(nLin+=10,nCol,nLin,NMAXCOL)
			oPrn:DataMatrix(nCol+010, nLin+56, TMPCOM->C2_NUM + TMPCOM->C2_ITEM + TMPCOM->C2_SEQUEN, 55 )
			oPrn:Say(nLin+18,nCol+155,"LOCAL: " + TMPCOM->C2_LOCAL,oFont08)
			oPrn:Say(nLin+28,nCol+155,"PREV INICIAL: " + DTOC(STOD(TMPCOM->C2_DATPRI)),oFont08)
			oPrn:Say(nLin+38,nCol+155,"PREV FINAL:   " + DTOC(STOD(TMPCOM->C2_DATPRI)),oFont08)
			oPrn:Line(nLin+=60,nCol,nLin,NMAXCOL)
			nLin  += 008
		EndIf

	EndDo

	If TMPROT->G2_OPERAC == '50' .And. nSalta == 1  // se for opera??o 50 e contiver 1 na variavel nSalta, fazer apenas 1 impress?o  

		oPrn:Say(nLin+30	,nCol+50	,"Mínimo : ______________________                                                                                          Maximo : ______________________"			,oFont08)
	
	Endif 

	TMPSD4->( dbCloseArea() )

	nLin += 008

	TMPROT->( dbSkip() )

EndDo

TMPROT->( dbCloseArea() )

If TMPCOM->C2_ITEM + TMPCOM->C2_SEQUEN == "01001"
	nLin := 694

	oPrn:Say(nLin+=05,nCol+005,"ADIÇÃO EXTRA-FÓRMULA",oFont08)

	oPrn:Line(nLin+=10,nCol,nLin,NMAXCOL)

	oPrn:Box(nLin,nCol+000,nLin + 10,nCol+095) // C¨®digo
	oPrn:Box(nLin,nCol+095,nLin + 10,nCol+325) // Descri??o
	oPrn:Box(nLin,nCol+325,nLin + 10,nCol+425) // Quantidade
	oPrn:Box(nLin,nCol+425,nLin + 10,nCol+515) // Lote
	oPrn:Box(nLin,nCol+515,nLin + 10,NMAXCOL)  // Visto

	nLin += 008
	oPrn:Say(nLin-001	,nCol+005	,"Código"											,oFont07n,,)
	oPrn:Say(nLin-001	,nCol+100	,"Descrição"										,oFont07n,,)
	oPrn:Say(nLin-001	,nCol+330	,"Quantidade"										,oFont07n,,)
	oPrn:Say(nLin-001	,nCol+430	,"Lote"												,oFont07n,,)
	oPrn:Say(nLin-001	,nCol+520	,"Visto"											,oFont07n,,)

	oPrn:Box(nLin,nCol+000,nLin + 10,NMAXCOL)
	nLin += 008
	oPrn:Box(nLin,nCol+000,nLin + 10,NMAXCOL)
	nLin += 008
EndIf

nLin := 735

oPrn:Line(nLin+=10,nCol,nLin,NMAXCOL)

oPrn:Say(nLin+=10,nCol+050,"INICIAR PRODUÇÃO",oFont08)
oPrn:DataMatrix(nCol+050, nLin+56, "01" , 55 )

// Informar se h¨¢ opera??o sem sequ¨ºncia de fabrica??o...
cQuery := "SELECT G2_OPERAC, G2_DESCRI "
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
cQuery += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("SZ0") + " WHERE Z0_FILIAL = '" + xFilial("SZ0") + "' AND Z0_PRODUTO = G2_PRODUTO AND Z0_OPERAC = G2_OPERAC AND D_E_L_E_T_ = ' ') " 
cQuery += "AND G2_OPERAC NOT IN ('10','50') " 
cQuery += "AND SG2.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY G2_OPERAC "

TCQuery cQuery New Alias "SEMOPE"
dbSelectArea("SEMOPE")
dbGoTop()

If !SEMOPE->( Eof() )
	oPrn:Say(nLin+14,nCol+155,"*** Produto possui Operações sem Sequência de Fabricação ***",oFont10n,,CLR_HRED)
EndIf

n10 := 12

Do While !SEMOPE->( Eof() )
	
	oPrn:Say(nLin+14+n10,nCol+155,"Operação: " + SEMOPE->G2_OPERAC + " " + SEMOPE->G2_DESCRI,oFont08,,CLR_HRED)

	n10 += 10

	SEMOPE->( dbSkip() )
EndDo

SEMOPE->( dbCloseArea() )

oPrn:Say(nLin    ,nCol+430,"FINALIZAR PRODUÇÃO",oFont08)
oPrn:DataMatrix(nCol+430, nLin+56, "04", 55 )

If TMPCOM->C2_ITEM + TMPCOM->C2_SEQUEN == "01001"
	// Imprimir p¨¢gina de inspe??o de processo da qualidade...
	oPrn:EndPage()
	nLin := NMINLIN
	nCol := NMINCOL
	oPrn:StartPage()
	nPagOP++
	nPage++
	nPagina++
	oPrn:Box(nLin+20,nCol,NMAXLIN,NMAXCOL)
	oPrn:SayBitmap(nLin,nCol, GetSrvProfString("Startpath","") + cLogo,55,17)
	oPrn:Say(nLin,nCol+065,AllTrim( SM0->M0_FILIAL ),oFont08)
	oPrn:Say(nLin,nCol+050,PadC("ORDEM DE PRODUÇÃO",120),oFont14n)
	//oPrn:Say(nLin,NMAXCOL-36,"P¨¢gina: " + StrZero(nPage, 3),oFont07)
	oPrn:Say(nLin,NMAXCOL-36,"Página: " + StrZero(nPagina, 3),oFont07)
	oPrn:Say(nLin+=30,nCol+005,"PRODUTO: " + TMPCOM->C2_PRODUTO + ' ' + AllTrim(Posicione("SB1", 1, xFilial("SB1") + TMPCOM->C2_PRODUTO, "B1_DESC")),oFont08)
	oPrn:Say(nLin,NMAXCOL-106,"Qtd. Prev. (KG): " + Transform( TMPCOM->C2_QUANT, "@E 999,999,999.99"),oFont08)
	oPrn:Line(nLin+=10,nCol,nLin,NMAXCOL)
	oPrn:Say(nLin+=10,nCol+005,"LOTE: " + TMPCOM->C2_NUM + " " + TMPCOM->C2_ITEM + " " + TMPCOM->C2_SEQUEN,oFont08)
	cQuery := "SELECT CB7_ORDSEP FROM " + RetSqlName("CB7") + " WHERE CB7_FILIAL = '" + xFilial("CB7") + "' AND CB7_OP = '" + TMPCOM->C2_NUM + TMPCOM->C2_ITEM + TMPCOM->C2_SEQUEN + "' AND D_E_L_E_T_ = ' ' ORDER BY CB7_ORDSEP"
	TCQuery cQuery New Alias "TMPSEP"
	dbGoTop()
	Do While !TMPSEP->( Eof() )
		oPrn:Say(nLin,nCol+155,"ORDEM DE SEP.: " + TMPSEP->CB7_ORDSEP,oFont08)
		TMPSEP->( dbSkip() )
	EndDo
	TMPSEP->( dbCloseArea() )
	oPrn:Line(nLin+=10,nCol,nLin,NMAXCOL)
	oPrn:DataMatrix(nCol+010, nLin+56, TMPCOM->C2_NUM + TMPCOM->C2_ITEM + TMPCOM->C2_SEQUEN, 55 )
	oPrn:Say(nLin+18,nCol+155,"LOCAL: " + TMPCOM->C2_LOCAL,oFont08)
	oPrn:Say(nLin+28,nCol+155,"PREV INICIAL: " + DTOC(STOD(TMPCOM->C2_DATPRI)),oFont08)
	oPrn:Say(nLin+38,nCol+155,"PREV FINAL:   " + DTOC(STOD(TMPCOM->C2_DATPRI)),oFont08)
	oPrn:Line(nLin+=60,nCol,nLin,NMAXCOL)
	nLin += 008

	oPrn:Say(nLin+10,nCol+050,PadC("INSPEÇÃO DE PROCESSO - QUALIDADE",120),oFont14n)

	nLin += 010

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

		oPrn:Say(nLin + 02 + 14,NMINCOL + 005,"Controle de Qualidade",oFont14n,,CLR_BLUE)
		oPrn:Line(nLin+=02 + 20,nCol,nLin,NMAXCOL)
		
		oPrn:Box( nLin, nCol+000        , nLin+010, nCol+025        ) // Item
		oPrn:Box( nLin, nCol+025        , nLin+010, nCol+085        ) // C¨®digo
		oPrn:Box( nLin, nCol+085        , nLin+010, nCol+245        ) // Ensaio
		oPrn:Box( nLin, nCol+245        , nLin+010, nCol+305        ) // Lim. Inf.
		oPrn:Box( nLin, nCol+305        , nLin+010, nCol+365        ) // Lim. Sup.
		oPrn:Box( nLin, nCol+365        , nLin+010, nCol+495        ) // Unid. Med.
		oPrn:Box( nLin, nCol+495        , nLin+010, NMAXCOL            ) // M¨¦todo
		
		nLin += 010
		oPrn:Say(nLin-002	,nCol+003	    ,"Item"				,oFont10n,,)
		oPrn:Say(nLin-002	,nCol+028       ,"Código"			,oFont10n,,)
		oPrn:Say(nLin-002	,nCol+088       ,"Ensaio"			,oFont10n,,)
		oPrn:Say(nLin-002	,nCol+248	    ,"Lim. Inf."		,oFont10n,,)
		oPrn:Say(nLin-002	,nCol+308	    ,"Lim. Sup."		,oFont10n,,)
		oPrn:Say(nLin-002	,nCol+368	    ,"Unid. Med."		,oFont10n,,)
		oPrn:Say(nLin-002	,nCol+498       ,"Método"			,oFont10n,,)
	Else
		lQualidade := .F.
	EndIf
	
	Do While !TMPQUA->( Eof() )
		oPrn:Box( nLin, nCol+000        , nLin+010, nCol+025        ) // Item
		oPrn:Box( nLin, nCol+025        , nLin+010, nCol+085        ) // C¨®digo
		oPrn:Box( nLin, nCol+085        , nLin+010, nCol+245        ) // Ensaio
		oPrn:Box( nLin, nCol+245        , nLin+010, nCol+305        ) // Lim. Inf.
		oPrn:Box( nLin, nCol+305        , nLin+010, nCol+365        ) // Lim. Sup.
		oPrn:Box( nLin, nCol+365        , nLin+010, nCol+495        ) // Unid. Med.
		oPrn:Box( nLin, nCol+495        , nLin+010, NMAXCOL         ) // M¨¦todo
	
		nLin += 010
		oPrn:Say(nLin-002	,nCol+003	,AllTrim( TMPQUA->QPJ_ITEM )								,oFont08,,)
		oPrn:Say(nLin-002	,nCol+028    ,AllTrim( TMPQUA->QPJ_ENSAIO )								,oFont08,,)
		oPrn:Say(nLin-002	,nCol+088    ,AllTrim( TMPQUA->ENSAIO )									,oFont08,,)
		oPrn:Say(nLin-002	,nCol+248	,Transform( TMPQUA->LIMINF, PesqPict("QPJ","QPJ_LINF",14))	,oFont08,,)
		oPrn:Say(nLin-002	,nCol+308	,Transform( TMPQUA->LIMSUP, PesqPict("QPJ","QPJ_LSUP",14))	,oFont08,,)
		oPrn:Say(nLin-002	,nCol+368	,AllTrim( TMPQUA->QPJ_DUNMED )								,oFont08,,)
		oPrn:Say(nLin-002	,nCol+498	,AllTrim( TMPQUA->QP1_METODO)								,oFont08,,)

		//nLin += 010
		oPrn:Box( nLin, nCol+000        , nLin+050, NMAXCOL        ) // Item
		oPrn:Say(nLin+=010, 0020, "Analista.....:                     DT/HR INI: ____/____/____  ____:____ DT/HR FIN: ____/____/____  ____:____", oFontC7,,)
		oPrn:Say(nLin+=010, 0020, "Texto........: " + AllTrim( TMPQUA->TEXTO ), oFontC7,,)
		oPrn:Say(nLin+=010, 0020, "Qtd. Amostra.: " + Transform( TMPQUA->QP1_QTDE, PesqPict("QP1","QP1_QTDE",14)), oFontC7,,)
		oPrn:Say(nLin+=010, 0020, "Tipo.........: " + AllTrim( TMPQUA->TIPO ) + "                           Análise 1: ________ Análise 2: ________ Análise 3: ________", oFontC7,,)
		nLin += 010

		TMPQUA->( dbSkip() )
	EndDo

	oPrn:Say(nLin+=020, 0020, "Aprovado                  (   )                               Reprocessar                 (   )             ", oFontC7,,)
	oPrn:Say(nLin+=010, 0020, "Reprovado                 (   )                               Acerto Comercial            (   )             ", oFontC7,,)
	oPrn:Say(nLin+=010, 0020, "Aprovado Com Restrições   (   )                                                                             ", oFontC7,,)
	oPrn:Say(nLin+=010, 0020, "Analista.........:___________________________________________ Responsável..........:________________________", oFontC7,,)
	oPrn:Say(nLin+=010, 0020, "N. Retenção......:___________________________________________ Observações Gerais...:________________________", oFontC7,,)
	oPrn:Say(nLin+=010, 0020, "____________________________________________________________________________________________________________", oFontC7,,)
	oPrn:Say(nLin+=010, 0020, "____________________________________________________________________________________________________________", oFontC7,,)

	oPrn:Say(nLin+=060, 0420, "__________________________________", oFontC7n,,)
	oPrn:Say(nLin+=012, 0420, "            Assinatura            ", oFontC7n,,)

	TMPQUA->( dbCloseArea() )

	nLin := 735
	
	oPrn:Line(nLin+=10,nCol,nLin,NMAXCOL)
	
	oPrn:Say(nLin+=10,nCol+050,"INICIAR PAUSA",oFont08)
	oPrn:DataMatrix(nCol+050, nLin+56, "02" , 55 )
	oPrn:Say(nLin    ,nCol+430,"FINALIZAR PAUSA",oFont08)
	oPrn:DataMatrix(nCol+430, nLin+56, "02", 55 )

	nPage++
	//nPagina++
EndIf

nLinBoxCab := nLin

Return nLin

/*
¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹
¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À
¡À¡À¨²?????????????????????????????????????????????????????????????????????????¡À¡À
¡À¡À3Fun?¡­o    3CabPrIt	3 Autor 3 Rodrigo Sousa         3 Data 3 02/06/20153¡À¡À
¡À¡À??????????????????????¨¢???????¨¢???????????????????????¨¢??????¨¢???????????¡ä¡À¡À
¡À¡À3Descri?¡­o 3 Imprime Cabe?alho do Item								   3¡À¡À
¡À¡À¨¤??????????¨¢?????????????????????????????????????????????????????????????¨´¡À¡À
¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À
??????????????????????????????????????????????????????????????????????????????
*/
Static Function CabPrIt(nLin,nCol)

Return nLin

/*
¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹¨¹
¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À
¡À¡À¨²?????????????????????????????????????????????????????????????????????????¡À¡À
¡À¡À3Fun?¡­o    3StartPrint3 Autor 3 Rodrigo Sousa         3 Data 3 02/10/20113¡À¡À
¡À¡À??????????????????????¨¢???????¨¢???????????????????????¨¢??????¨¢???????????¡ä¡À¡À
¡À¡À3Descri?¡­o 3 Parametros da rotina.                					   3¡À¡À
¡À¡À¨¤??????????¨¢?????????????????????????????????????????????????????????????¨´¡À¡À
¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À¡À
??????????????????????????????????????????????????????????????????????????????
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

aAdd(_aPerg, {cPerg, "01", "Da Ordem Produção     ?", "MV_CH1" , "C", 11	, 0	, "G", "MV_PAR01", "SC2",""           ,""               ,""               ,""     ,""})
aAdd(_aPerg, {cPerg, "02", "Até Ordem Produção    ?", "MV_CH2" , "C", 11	, 0	, "G", "MV_PAR02", "SC2",""           ,""               ,""               ,""     ,""})
aAdd(_aPerg, {cPerg, "03", "Imp. QR Code 20/30/50 ?", "MV_CH2" , "N", 01	, 0	, "C", "MV_PAR03", "   ","Sim"        ,"Não"            ,""               ,""     ,""})

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
