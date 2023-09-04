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

/*/{Protheus.doc} EQNewOP3
Relatorio para impressão da ordem de produção
@type User function Relatorio
@version  1.00
@author fabio carneiro dos Santos
@author Paulo Rogerio
@since 20/07/2022
@param nPage, numeric, Numero da Pagina
@History relatorio foi todo modificado para trabalhar com o no layout conforme MIQE044 de 26/10/2021
@return character, sem retorno
/*/
User Function EQNewOP3()

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
	Private nLin		:= 0
	Private nCol		:= 0

	Private cLogo		:= ""
	Private cCartCorp	:= ""
	Private nSalta      := 0  // Para as opra??es 50 , ser¨¢ impresso minimo e maximo 
	Private lOrdAnalise := .F.
	Private lAssinatura := .F.

	MakeDir( "C:\Temp\" )

	ValidPerg()

	If !Pergunte(cPerg,.T.)
		Return
	EndIf

	cNumOP  := AllTrim( mv_par01 )
	cNumAte := AllTrim( mv_par02 )

	If PrepPrint()
		RptStatus({|| ExecPrint() },"Imprimindo Ordem de Produção...")
	EndIf

Return

/*/{Protheus.doc} PrepPrint
Tratamento fonte, patch e inmstancias  
@type static function Relatorio
@version  1.00
@author fabio carneiro dos Santos
@author Paulo Rogerio
@since 20/07/2022
@param nPage, numeric, Numero da Pagina
@return character, sem retorno
/*/
Static Function PrepPrint(cPathDest,cRelName)

	Local lRet 	:= .T.

	DEFAULT cPathDest := REL_PATH
	DEFAULT cRelName  := REL_NAME

	cRelName := "OP_" + AllTrim( cNumOP ) + "_"  + DTOS( dDataBase ) + "_" + Replace( Time(), ":", "") + ".PDF"

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

	//Instancia a Classe FwMsPrinter  
	oPrn := FwMsPrinter():New(cRelName,IMP_PDF,.F.,cPathDest,.T.,.F.,@oPrn,,,.F.,.F.,.T.,)
	oPrn:SetResolution(72)
	oPrn:SetPortrait()
	oPrn:SetPaperSize(DMPAPER_A4)

	oPrn:cPathPDF := cPathDest 			//Caso seja utilizada impressão em IMP_PDF      

	//Instancia a Classe FWPrintSetup 3
	oSetup := FWPrintSetup():New(PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION+PD_DISABLEDESTINATION+PD_DISABLEPAPERSIZE+PD_DISABLEPREVIEW ,"EQNewOP2")
	oSetup:SetUserParms({|| Pergunte(cPerg, .T.)})
	oSetup:SetProperty(PD_MARGIN,{05,05,05,05})
	oSetup:SetProperty(PD_DESTINATION,2) 

	//Ativa Tela de Setup
	If oSetup:Activate() == 2
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} ExecPrint
Tratamento da regra de negocio para extração 
@type Static function Relatorio
@version  1.00
@author fabio carneiro dos Santos
@author Paulo Rogerio
@since 20/07/2022
@param nPage, numeric, Numero da Pagina
@return character, sem retorno
/*/
Static Function ExecPrint()

	Local lProc       := .F.
	Private aEmpSaldo := {}

	cQuery := "SELECT * " + CRLF
	cQuery += "FROM " + RetSqlName("SC2") + " SC2 (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) " + CRLF
	cQuery += "	 ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = C2_PRODUTO " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
	cQuery += "AND C2_NUM + C2_ITEM + C2_SEQUEN BETWEEN '" + cNumOP + "' " + CRLF
	cQuery += "AND '" + AllTrim( cNumAte ) + "' " + CRLF
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO " + CRLF

	TCQuery cQuery New Alias "TMPCOM"
	dbSelectArea("TMPCOM")
	TMPCOM->( dbGoTop() )

	SetRegua( TMPCOM->( RecCount() ) )

	cNumOP := TMPCOM->(C2_NUM + C2_ITEM + C2_SEQUEN)

	While !TMPCOM->(EOF())

		If Left(cNumOP,6) != TMPCOM->C2_NUM

			cNumOP := TMPCOM->(C2_NUM + C2_ITEM + C2_SEQUEN)

			If !Empty(Mod(nPagOP,2))
				oPrn:EndPage()
				oPrn:StartPage()
				nPagOP++
			EndIf

		EndIf

		IncRegua("Imprimindo") 
		aEmpSaldo := {}

		cMsg := ""

		cQuery := "SELECT " + CRLF
		cQuery += "	D4_COD, " + CRLF
		cQuery += "	SUM(D4_QUANT) AS QUANTIDADE, " + CRLF
		cQuery += "	SUM(B2_QATU) AS SALDO " + CRLF
		cQuery += "FROM " + RetSqlName("SC2") + " SC2 (NOLOCK) " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SD4") + " SD4 (NOLOCK) " + CRLF
		cQuery += "	 ON D4_FILIAL = C2_FILIAL " + CRLF
		cQuery += "  AND D4_OP = C2_NUM + C2_ITEM + C2_SEQUEN " + CRLF
		cQuery += "  AND SC2.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) " + CRLF
		cQuery += "	 ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
		cQuery += "  AND B1_COD = C2_PRODUTO " + CRLF
		cQuery += "  AND B1_TIPO <> 'PI' " + CRLF
		cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SB2") + " SB2 (NOLOCK) " + CRLF
		cQuery += "  ON B2_FILIAL = C2_FILIAL " + CRLF
		cQuery += "  AND B2_COD = D4_COD " + CRLF
		cQuery += "  AND SB2.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "WHERE " + CRLF
		cQuery += "	C2_FILIAL 		= '" + xFilial("SC2") + "' " + CRLF
		cQuery += "	AND C2_NUM 		= '" + TMPCOM->C2_NUM + "' " + CRLF
		cQuery += "	AND C2_ITEM 	= '" + TMPCOM->C2_ITEM + "' " + CRLF
		cQuery += "	AND C2_SEQUEN 	= '" + TMPCOM->C2_SEQUEN + "' " + CRLF
		cQuery += "	AND SC2.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "GROUP BY D4_COD " + CRLF
		cQuery += "HAVING SUM(B2_QATU) - SUM(D4_QUANT) < 0.00 " + CRLF

		TCQuery cQuery New Alias "TMPSC2"
		dbSelectArea("TMPSC2")
		dbGoTop()
		
		While !TMPSC2->( Eof() )
			cMsg += "Produto: " + TMPSC2->D4_COD + " Necessário: " + Transform( TMPSC2->QUANTIDADE, "@E 999,999.99") + " Saldo: " + Transform( TMPSC2->SALDO, "@E 999,999.99") + CRLF
			aAdd( aEmpSaldo, { TMPSC2->D4_COD })
			TMPSC2->( dbSkip() )
		EndDo
		
		If !Empty( cMsg )
			Aviso( "EQNEWOP3 - Aviso", "Ordem de Produção possui componentes sem saldo suficiente disponivel:" + CRLF + cMsg, {"OK"}, 3)
		EndIf
		
		TMPSC2->( dbCloseArea() )

		lQualidade := .T.
		RunPrint()
		lProc := .T.
		TMPCOM->( dbSkip() )

	EndDo

	If lProc
		StartPrint()
	Else
		ApMsgInfo('Não há dados!', 'Cosmotec')
	EndIf

	TMPCOM->( dbCloseArea() )

Return

/*/{Protheus.doc} RunPrint
Imprime Cabeçalho da Ordem de Separaçao e Cabeçalho dos Itens da 
		Ordem de Separação 
@type Static function Relatorio
@version 1.00
@author fabio carneiro dos Santos
@author Paulo Rogerio
@since 20/07/2022
@param nPage, numeric, Numero da Pagina
@return character, sem retorno
/*/
Static Function RunPrint()

	Local nPixLin := NMINLIN
	Local nPixCol := NMINCOL
	
	nPixLin := fImprime(nPage) //Imprime Cabeçalho da Ordem de Separaçao
	nPixLin := CabPrIt(nPixLin,nPixCol) //Imprime Cabeçalho dos Itens da Ordem de Separação

	//Fiinaliza a Pagina
	oPrn:EndPage()   		

Return

/*/{Protheus.doc} fImprime
Cabecalho do Relatorio e regra de negocio
@type function Relatorio
@version  1.00
@author fabio carneiro dos Santos
@author Paulo Rogerio
@since 20/07/2022
@param nPage, numeric, Numero da Pagina
@return character, sem retorno
/*/
Static Function fImprime(nPage)

	Local _cidPa8 	:= ""
	Local _cInst1 	:= ""
	Local _cInst2 	:= ""
	Local _cTrt 	:= ""
	Local _cItm     := ""
	Local nQtdLinha := 0
	
	If TMPCOM->(C2_ITEM + C2_SEQUEN) == "01001"
		cQuery := "SELECT G2_OPERAC, G2_RECURSO, G2_DESCRI, "+CRLF
		cQuery += "	ISNULL(RTRIM(LTRIM(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),Z0_DESCRIC)))),'') INSTRUCAO, "+CRLF
		cQuery += "	Z0_SEQINI, Z0_SEQFIN "+CRLF
		cQuery += "FROM " + RetSqlName("SG2") + " SG2 (NOLOCK) "+CRLF
		cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) "+CRLF
		cQuery += "	 ON B1_FILIAL = '" + xFilial("SB1") + "' "+CRLF
		cQuery += "  AND B1_COD = G2_PRODUTO "+CRLF
		cQuery += "  AND ((B1_EQ_DISP <> 'N' AND B1_EQ_COMP <> 'N') OR (B1_EQ_DISP = 'N' AND B1_EQ_COMP = 'N')) "+CRLF
		cQuery += "  AND SB1.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "INNER JOIN " + RetSqlName("SH1") + " SH1 (NOLOCK) "+CRLF
		cQuery += "	 ON H1_FILIAL = '" + xFilial("SH1") + "' "+CRLF
		cQuery += "  AND H1_CODIGO = G2_RECURSO "+CRLF
		cQuery += "  AND SH1.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "INNER JOIN " + RetSqlName("SHB") + " SHB (NOLOCK) "+CRLF
		cQuery += "  ON HB_FILIAL = '" + xFilial("SHB") + "' "+CRLF
		cQuery += "  AND HB_COD = G2_CTRAB "+CRLF
		cQuery += "  AND SHB.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "INNER JOIN " + RetSqlName("SZ0") + " SZ0 (NOLOCK) "+CRLF
		cQuery += "  ON Z0_FILIAL = '" + xFilial("SZ0") + "' "+CRLF
		cQuery += "  AND Z0_PRODUTO = G2_PRODUTO "+CRLF
		cQuery += "  AND Z0_OPERAC = G2_OPERAC "+CRLF
		cQuery += "  AND SZ0.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "WHERE G2_FILIAL = '" + xFilial("SG2") + "' "+CRLF
		cQuery += "	AND G2_CODIGO = '" + TMPCOM->C2_ROTEIRO + "' " +CRLF
		cQuery += "	AND G2_PRODUTO = '" + TMPCOM->C2_PRODUTO + "' " +CRLF
		cQuery += "	AND SG2.D_E_L_E_T_ = ' ' "+CRLF
		
		cQuery += "UNION ALL "+CRLF
		
		cQuery += "SELECT G2_OPERAC, G2_RECURSO, G2_DESCRI, "+CRLF
		cQuery += "	ISNULL(RTRIM(LTRIM(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),Z0_DESCRIC)))),'') INSTRUCAO, "+CRLF
		cQuery += "	'001' AS Z0_SEQINI, Z0_SEQFIN "+CRLF
		cQuery += "FROM " + RetSqlName("SG2") + " SG2 (NOLOCK) "+CRLF
		cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) "+CRLF
		cQuery += "	 ON B1_FILIAL = '" + xFilial("SB1") + "' "+CRLF
		cQuery += "  AND B1_COD = G2_PRODUTO "+CRLF
		cQuery += "  AND B1_EQ_DISP = 'N' "+CRLF
		cQuery += "  AND B1_EQ_COMP <> 'N' "+CRLF
		cQuery += "  AND SB1.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "INNER JOIN " + RetSqlName("SH1") + " SH1 (NOLOCK) "+CRLF
		cQuery += "  ON H1_FILIAL = '" + xFilial("SH1") + "' "+CRLF
		cQuery += "  AND H1_CODIGO = G2_RECURSO "+CRLF
		cQuery += "  AND SH1.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "INNER JOIN " + RetSqlName("SHB") + " SHB (NOLOCK) "+CRLF
		cQuery += "  ON HB_FILIAL = '" + xFilial("SHB") + "' "+CRLF
		cQuery += "  AND HB_COD = G2_CTRAB "+CRLF
		cQuery += "  AND SHB.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "INNER JOIN " + RetSqlName("SZ0") + " SZ0 (NOLOCK) "+CRLF
		cQuery += "  ON Z0_FILIAL = '" + xFilial("SZ0") + "' "+CRLF
		cQuery += "  AND Z0_PRODUTO = G2_PRODUTO "+CRLF
		cQuery += "  AND Z0_OPERAC = G2_OPERAC "+CRLF
		cQuery += "  AND Z0_OPERAC <> '20' "+CRLF
		cQuery += "  AND Z0_OPERAC <> '40' "+CRLF
		cQuery += "  AND SZ0.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "WHERE G2_FILIAL = '" + xFilial("SG2") + "' "+CRLF
		cQuery += "	AND G2_CODIGO = '" + TMPCOM->C2_ROTEIRO + "' " +CRLF
		cQuery += "	AND G2_PRODUTO = '" + TMPCOM->C2_PRODUTO + "' " +CRLF
		cQuery += "	AND SG2.D_E_L_E_T_ = ' ' "+CRLF
		
		cQuery += "UNION ALL "+CRLF
		
		cQuery += "SELECT G2_OPERAC, G2_RECURSO, G2_DESCRI, "+CRLF
		cQuery += "	ISNULL(RTRIM(LTRIM(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),Z0_DESCRIC)))),'') INSTRUCAO, "+CRLF
		cQuery += "	Z0_SEQINI, '099' AS Z0_SEQFIN "+CRLF
		cQuery += "FROM " + RetSqlName("SG2") + " SG2 (NOLOCK) "+CRLF
		cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) "+CRLF
		cQuery += "	 ON B1_FILIAL = '" + xFilial("SB1") + "' "+CRLF
		cQuery += "  AND B1_COD = G2_PRODUTO "+CRLF
		cQuery += "  AND B1_EQ_DISP <> 'N' "+CRLF
		cQuery += "  AND B1_EQ_COMP = 'N' "+CRLF
		cQuery += "  AND SB1.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "INNER JOIN " + RetSqlName("SH1") + " SH1 (NOLOCK) "+CRLF
		cQuery += "  ON H1_FILIAL = '" + xFilial("SH1") + "' "+CRLF
		cQuery += "  AND H1_CODIGO = G2_RECURSO "+CRLF
		cQuery += "  AND SH1.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "INNER JOIN " + RetSqlName("SHB") + " SHB (NOLOCK) "+CRLF
		cQuery += "  ON HB_FILIAL = '" + xFilial("SHB") + "' "+CRLF
		cQuery += "  AND HB_COD = G2_CTRAB "+CRLF
		cQuery += "  AND SHB.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "INNER JOIN " + RetSqlName("SZ0") + " SZ0 (NOLOCK) "+CRLF
		cQuery += "  ON Z0_FILIAL = '" + xFilial("SZ0") + "' "+CRLF
		cQuery += "  AND Z0_PRODUTO = G2_PRODUTO "+CRLF
		cQuery += "  AND Z0_OPERAC = G2_OPERAC "+CRLF
		cQuery += "  AND Z0_OPERAC NOT IN ('30','40') "+CRLF		
		cQuery += "  AND SZ0.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "WHERE G2_FILIAL = '" + xFilial("SG2") + "' "+CRLF
		cQuery += "	AND G2_CODIGO = '" + TMPCOM->C2_ROTEIRO + "' " +CRLF
		cQuery += "	AND G2_PRODUTO = '" + TMPCOM->C2_PRODUTO + "' " +CRLF
		cQuery += "	AND SG2.D_E_L_E_T_ = ' ' "+CRLF

		cQuery += "UNION ALL "+CRLF
		
		cQuery += "SELECT G2_OPERAC, G2_RECURSO, G2_DESCRI, "+CRLF
		cQuery += "	ISNULL(RTRIM(LTRIM(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),Z0_DESCRIC)))),'') INSTRUCAO, "+CRLF
		cQuery += "	Z0_SEQINI AS Z0_SEQINI, Z0_SEQFIN "+CRLF
		cQuery += "FROM " + RetSqlName("SG2") + " SG2 (NOLOCK) "+CRLF
		cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) "+CRLF
		cQuery += "	 ON B1_FILIAL = '" + xFilial("SB1") + "' "+CRLF
		cQuery += "  AND B1_COD = G2_PRODUTO "+CRLF
		cQuery += "  AND ((B1_EQ_DISP = 'N' AND B1_EQ_COMP <> 'N') "+CRLF
		cQuery += "  OR (B1_EQ_DISP <> 'N' AND B1_EQ_COMP = 'N')) "+CRLF
		cQuery += "  AND SB1.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "INNER JOIN " + RetSqlName("SH1") + " SH1 (NOLOCK) "+CRLF
		cQuery += "	 ON H1_FILIAL = '" + xFilial("SH1") + "' "+CRLF
		cQuery += "  AND H1_CODIGO = G2_RECURSO "+CRLF
		cQuery += "  AND SH1.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "INNER JOIN " + RetSqlName("SHB") + " SHB (NOLOCK) "+CRLF
		cQuery += "  ON HB_FILIAL = '" + xFilial("SHB") + "' "+CRLF
		cQuery += "  AND HB_COD = G2_CTRAB "+CRLF
		cQuery += "  AND SHB.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "INNER JOIN " + RetSqlName("SZ0") + " SZ0 (NOLOCK) "+CRLF
		cQuery += "	 ON Z0_FILIAL = '" + xFilial("SZ0") + "' "+CRLF
		cQuery += "  AND Z0_PRODUTO = G2_PRODUTO "+CRLF
		cQuery += "  AND Z0_OPERAC = G2_OPERAC "+CRLF
		cQuery += "  AND Z0_OPERAC NOT IN ('20','30') "+CRLF
		cQuery += "  AND SZ0.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "WHERE G2_FILIAL = '" + xFilial("SG2") + "' "+CRLF
		cQuery += "	AND G2_CODIGO = '" + TMPCOM->C2_ROTEIRO + "' " +CRLF
		cQuery += "	AND G2_PRODUTO = '" + TMPCOM->C2_PRODUTO + "' " +CRLF
		cQuery += "	AND SG2.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "ORDER BY G2_OPERAC "+CRLF
	Else
		cQuery := "SELECT G2_OPERAC, G2_RECURSO, G2_DESCRI, "+CRLF
		cQuery += "	ISNULL(RTRIM(LTRIM(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),Z0_DESCRIC)))),'Envase Manual') INSTRUCAO, "+CRLF
		cQuery += "	ISNULL( Z0_SEQINI, '001') AS Z0_SEQINI, ISNULL( Z0_SEQFIN, '999') Z0_SEQFIN "+CRLF
		cQuery += "FROM " + RetSqlName("SG2") + " SG2 (NOLOCK) "+CRLF
		cQuery += "INNER JOIN " + RetSqlName("SH1") + " SH1 (NOLOCK) "+CRLF
		cQuery += "	 ON H1_FILIAL = '" + xFilial("SH1") + "' "+CRLF
		cQuery += "  AND H1_CODIGO = G2_RECURSO "+CRLF
		cQuery += "  AND SH1.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "INNER JOIN " + RetSqlName("SHB") + " SHB (NOLOCK) "+CRLF
		cQuery += "  ON HB_FILIAL = '" + xFilial("SHB") + "' "+CRLF
		cQuery += "  AND HB_COD = G2_CTRAB "+CRLF
		cQuery += "  AND SHB.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "LEFT JOIN " + RetSqlName("SZ0") + " SZ0 (NOLOCK) "+CRLF
		cQuery += "	 ON Z0_FILIAL = '" + xFilial("SZ0") + "' "+CRLF
		cQuery += "  AND Z0_PRODUTO = G2_PRODUTO "+CRLF
		cQuery += "  AND Z0_OPERAC = G2_OPERAC "+CRLF
		cQuery += "  AND SZ0.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "WHERE G2_FILIAL = '" + xFilial("SG2") + "' "+CRLF
		cQuery += "	AND G2_CODIGO = '" + TMPCOM->C2_ROTEIRO + "' " +CRLF
		cQuery += "	AND G2_PRODUTO = '" + TMPCOM->C2_PRODUTO + "' " +CRLF
		cQuery += "	AND SG2.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "ORDER BY G2_OPERAC "+CRLF
	EndIf

	TCQuery cQuery New Alias "TMPROT"
	dbSelectArea("TMPROT")
	dbGoTop()

	// Cabeçalho
	IF TMPROT->G2_OPERAC == '50'
		fPrintCab("1",.F.,.T.)
	Else
		fPrintCab("1",.T.,.F.)
	EndIf

	nLin += 010

	lOrdAnalise := .F.
	lAssinatura := .T.

	While TMPROT->( !Eof() )
	
		nLin += 005

		// Quando conter a operação 50 ira incrementar a numerário 
		If TMPROT->G2_OPERAC == '50' 
			nSalta++
		EndIf 

		If TMPROT->G2_OPERAC == '40'
			lOrdAnalise := .T. 
		EndIf 

		oPrn:Say(nLin += 10,nCol+050,"Operação: " + TMPROT->G2_OPERAC,oFont08)
		oPrn:DataMatrix(nCol+050, nLin+56, TMPROT->G2_OPERAC , 55 )

		If mv_par03 == 1 .Or. AllTrim(TMPROT->G2_OPERAC) == "40"
			oPrn:Say(nLin,nCol+430,"Recurso: "+TMPROT->G2_RECURSO,oFont08)
			oPrn:DataMatrix(nCol+430, nLin+56, TMPROT->G2_RECURSO, 55 )
		Else
			oPrn:Say(nLin,nCol+430,"Recurso Sugerido: "+TMPROT->G2_RECURSO,oFont08)
			oPrn:Box(nLin+10,nCol+430,nLin+48,nCol+500)
			oPrn:FillRect({nLin+12,nCol+432,nLin+46,nCol+498},oBrusCin)
			oPrn:Say(nLin+21,nCol+435,"Coletar QR",oFont10n,,CLR_WHITE)
			oPrn:Say(nLin+31,nCol+435,"Code no Quadro",oFont10n,,CLR_WHITE)
			oPrn:Say(nLin+41,nCol+435,"do Recurso",oFont10n,,CLR_WHITE)
		EndIf

		oPrn:Say(nLin+10,nCol+050,PadC("OPERAÇÃO "+TMPROT->G2_OPERAC+" "+AllTrim( TMPROT->G2_DESCRI ),120),oFont14n)
		oPrn:Say(nLin+20,nCol+230,"Seq. Inicial: "+TMPROT->Z0_SEQINI+" Seq. Final: "+AllTrim( TMPROT->Z0_SEQFIN ),oFont08)

		oPrn:Line(nLin+=65,nCol,nLin,NMAXCOL)

		oPrn:Say(nLin+=10,nCol+005,TMPROT->INSTRUCAO,oFont08)

 		oPrn:Line(nLin+=10,nCol,nLin,NMAXCOL)

		oPrn:Box(nLin,nCol+000,nLin+20,nCol+035) // TRT
		oPrn:Box(nLin,nCol+035,nLin+20,nCol+095) // Codigo
		oPrn:Box(nLin,nCol+095,nLin+20,nCol+325) // Descrição
		oPrn:Box(nLin,nCol+325,nLin+20,nCol+425) // Quantidade
		oPrn:Box(nLin,nCol+425,nLin+20,nCol+515) // Lote
		oPrn:Box(nLin,nCol+515,nLin+20,NMAXCOL)  // Qtd. Real

		nLin += 016
		oPrn:Say(nLin-005,nCol+005,"TRT"				,oFont10n,,)
		oPrn:Say(nLin-005,nCol+040,"Código"				,oFont10n,,)
		oPrn:Say(nLin-005,nCol+100,"Descrição"			,oFont10n,,)
		oPrn:Say(nLin-005,nCol+330,"Quantidade Prev."	,oFont10n,,)
		oPrn:Say(nLin-005,nCol+430,"Lote"				,oFont10n,,)
		oPrn:Say(nLin-005,nCol+520,"Qtd. Real"			,oFont10n,,)

		cQuery := "SELECT "+CRLF
		cQuery += "	D4_PRODUTO, "+CRLF
		cQuery += "	D4_TRT, "+CRLF
		cQuery += "	D4_COD, "+CRLF
		cQuery += "	B1_DESC, "+CRLF
		cQuery += "	CASE WHEN D4_QUANT = 0 THEN D4_QTDEORI ELSE D4_QUANT END D4_QUANT, "+CRLF
		cQuery += "	D4_LOTECTL "+CRLF
		cQuery += "FROM " + RetSqlName("SD4") + " SD4 (NOLOCK) "+CRLF
		cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) "+CRLF
		cQuery += "	 ON B1_FILIAL = '" + xFilial("SB1") + "' "+CRLF
		cQuery += "  AND B1_COD = D4_COD "+CRLF
		cQuery += "  AND SB1.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "WHERE D4_FILIAL = '" + xFilial("SD4") + "' "+CRLF
		cQuery += "	AND D4_OP = '" + TMPCOM->(C2_NUM + C2_ITEM + C2_SEQUEN ) + "' "+CRLF
		cQuery += "	AND D4_TRT BETWEEN '" + TMPROT->Z0_SEQINI + "' AND '" + TMPROT->Z0_SEQFIN + "' "+CRLF
		cQuery += "	AND SD4.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "ORDER BY D4_TRT, D4_COD "+CRLF

		TCQuery cQuery New Alias "TMPSD4"
		dbSelectArea("TMPSD4")
		dbGoTop()
		
		nQtdItem := 0

		While !TMPSD4->( Eof() )

			/*
			da Mata - 21/03/2023 - Carrega os dados do Roteiro de Operações 
			Específico do Laboratório
			*/

			If TMPROT->G2_OPERAC == "20"

				_cidPa8 := Posicione("PA8",2,xFilial("PA8")+TMPROT->G2_OPERAC+TMPSD4->D4_PRODUTO+Posicione("SB1",1,xFilial("SB1")+TMPSD4->D4_PRODUTO,"B1_REVATU"),"PA8_ID")
				_cTrt 	:= AllTrim(Posicione("PA9",1,xFilial("PA9")+_cidPa8+TMPSD4->(D4_COD+D4_TRT),"PA9_TRT"))
				_cItm   := AllTrim(Posicione("PA9",1,xFilial("PA9")+_cidPa8+TMPSD4->(D4_COD+D4_TRT),"PA9_COD"))

				If 	AllTrim(TMPSD4->D4_TRT) == _cTrt .AND. AllTrim(TMPSD4->D4_COD) == _cItm
	
					_cInst1 := AllTrim(Posicione("PA9",1,xFilial("PA9")+_cidPa8+TMPSD4->(D4_COD+D4_TRT),"PA9_INST1"))
					_cInst2 := AllTrim(Posicione("PA9",1,xFilial("PA9")+_cidPa8+TMPSD4->(D4_COD+D4_TRT),"PA9_INST2"))
					
					oPrn:Box(nLin,nCol+000,nLin+21,NMAXCOL)
					oPrn:Say(nLin+=10,nCol+005,_cInst1,oFont10n,,)

					If !Empty(_cInst2)
						oPrn:Say(nLin+=10,nCol+044,_cInst2,oFont10n,,)
					EndIf

				EndIf

			EndIf

			oPrn:Box(nLin,nCol+000,nLin+21,nCol+035) // TRT
			oPrn:Box(nLin,nCol+035,nLin+21,nCol+095) // Codigo
			oPrn:Box(nLin,nCol+095,nLin+21,nCol+325) // Descrição
			oPrn:Box(nLin,nCol+325,nLin+21,nCol+425) // Quantidade
			oPrn:Box(nLin,nCol+425,nLin+21,nCol+515) // Lote
			oPrn:Box(nLin,nCol+515,nLin+21,NMAXCOL)  // Qtd. Real

			cFalta := ""

			If aScan(aEmpSaldo,{|x| AllTrim(TMPSD4->D4_COD)==AllTrim(x[1])}) > 0
				cFalta := " [ * ]"
			EndIf

			nQtdItem++

			nLin += 018

			oPrn:Say(nLin-005,nCol+005,TMPSD4->D4_TRT									 ,oFont08,,)
			oPrn:Say(nLin-005,nCol+040,AllTrim( TMPSD4->D4_COD ) + cFalta				 ,oFont08,,)
			oPrn:Say(nLin-005,nCol+100,TMPSD4->B1_DESC									 ,oFont08,,)
			oPrn:Say(nLin-005,nCol+345,Transform( TMPSD4->D4_QUANT, "@E 999,999.999999"),oFontC7,,)
			oPrn:Say(nLin-005,nCol+430,TMPSD4->D4_LOTECTL								 ,oFont08,,)
			oPrn:Say(nLin-005,nCol+520,""												 ,oFont08,,)
			
			TMPSD4->( dbSkip() )

			If nLin > 684
			
				oPrn:EndPage()
			
				nLin := NMINLIN
				nCol := NMINCOL

				fPrintCab("1",.F.)
			
			EndIf

		EndDo

		If TMPROT->G2_OPERAC == '50' // se for operaão 50 e contiver 1 na variavel nSalta, fazer apenas 1 impressão  
			nAltCel := 18
			nLin += nAltCel
			nCol := NMINCOL

			oPrn:Box(nLin         ,nCol+050,nLin+036,nCol+050+120)
			oPrn:Line(nLin+nAltCel,nCol+050,nLin+nAltCel,nCol+050+120)
			oPrn:Say(nLin+10      ,nCol+080,"Peso Mínimo:",oFont08n)

			nCol  := NMAXCOL - 250

			oPrn:Box(nLin         ,nCol+050,nLin+036,nCol+050+120)
			oPrn:Line(nLin+nAltCel,nCol+050,nLin+nAltCel,nCol+050+120)
			oPrn:Say(nLin+10      ,nCol+080,"Peso Maximo:",oFont08n)
			
			nLin  += 036
			nCol  := NMINCOL

			nLin  += 010
			lAssinatura := .F.

		EndIf 

		TMPSD4->( dbCloseArea() )
		TMPROT->( dbSkip() )

	EndDo

	// INICIO - FAZ TRATAMENTO PARA OP SEM OPERAÇÕES

	// Informar se há operação sem sequencia de fabricação
	cQuery := "SELECT G2_OPERAC, G2_DESCRI "+CRLF
	cQuery += "FROM " + RetSqlName("SG2") + " SG2 (NOLOCK) "+CRLF
	cQuery += "INNER JOIN " + RetSqlName("SH1") + " SH1 (NOLOCK) "+CRLF
	cQuery += "  ON H1_FILIAL = '" + xFilial("SH1") + "' "+CRLF
	cQuery += "  AND H1_CODIGO = G2_RECURSO "+CRLF
	cQuery += "  AND SH1.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "INNER JOIN " + RetSqlName("SHB") + " SHB (NOLOCK) "+CRLF
	cQuery += "	 ON HB_FILIAL = '" + xFilial("SHB") + "' "+CRLF
	cQuery += "  AND HB_COD = G2_CTRAB "+CRLF
	cQuery += "  AND SHB.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "WHERE G2_FILIAL = '" + xFilial("SG2") + "' "+CRLF
	cQuery += "	AND G2_CODIGO = '" + TMPCOM->C2_ROTEIRO + "' "+CRLF 
	cQuery += "	AND G2_PRODUTO = '" + TMPCOM->C2_PRODUTO + "' "+CRLF 
	cQuery += "	AND NOT EXISTS "+CRLF 
	cQuery += "(SELECT * FROM " + RetSqlName("SZ0") + " SZ0 (NOLOCK) "+CRLF
	cQuery += "			WHERE Z0_FILIAL = '" + xFilial("SZ0") + "' "+CRLF
	cQuery += "			AND Z0_PRODUTO = G2_PRODUTO "+CRLF
	cQuery += "			AND Z0_OPERAC  = G2_OPERAC "+CRLF
	cQuery += "			AND D_E_L_E_T_ = ' ') "+CRLF 
	cQuery += "	AND G2_OPERAC NOT IN ('10','50') "+CRLF
	cQuery += "	AND SG2.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "ORDER BY G2_OPERAC "+CRLF

	TCQuery cQuery New Alias "SEMOPE"
	dbSelectArea("SEMOPE")
	dbGoTop()

	If !SEMOPE->( Eof() )
		oPrn:Say(nLin+14,nCol+155,"*** Produto possui Operações sem Sequência de Fabricação ***",oFont10n,,CLR_HRED)
	EndIf

	n10 := 12

	While !SEMOPE->( Eof() )
		
		oPrn:Say(nLin+14+n10,nCol+155,"Operação: "+SEMOPE->G2_OPERAC+" "+SEMOPE->G2_DESCRI,oFont08,,CLR_HRED)
		n10 += 10
		SEMOPE->( dbSkip() )

	EndDo

	SEMOPE->( dbCloseArea() )

	// TERMINO - FAZ TRATAMENTO PARA OP SEM OPERAÇÕES

	// INICIO - QUADRO DE ASSINATURAS NO RODAPÉ
	IF lAssinatura

		nAltura := 80
		nAltCel := 18

		IF nLin + nAltura + 30 > 730  // 630
			
			oPrn:EndPage()
			nLin := NMINLIN
			nCol := NMINCOL

			fPrintCab("1",.F.)

		EndIf

		nLin += 30

		IF nLin < 635
			nLin := 635
		EndIf

		oPrn:Box(nLin ,nCol+002,nLin+nAltura,nCol+460)
		oPrn:Line(nLin,nCol+100,nLin+nAltura,nCol+100)	
		oPrn:Line(nLin,nCol+330,nLin+nAltura,nCol+330)

		oPrn:Say(nLin-003,nCol+005,"Assinaturas:",oFont08n)
		oPrn:Say(nLin-003,nCol+350,"     Data:  ",oFont08n)
		nLin += nAltCel

		oPrn:Say(nLin,nCol+005,"Separador:  ",oFont08n)
		oPrn:Say(nLin,nCol+350,"       /         /",oFont08n)
		oPrn:Line(nLin+003,nCol+002,nLin+001,nCol+460)
		nLin += nAltCel

		oPrn:Say(nLin,nCol+005,"Operador:   ",oFont08n)
		oPrn:Say(nLin,nCol+350,"       /         /",oFont08n)
		oPrn:Line(nLin+003,nCol+002,nLin+001,nCol+460)
		nLin += nAltCel

		oPrn:Say(nLin,nCol+005,"Colorista:  ",oFont08n)
		oPrn:Say(nLin,nCol+350,"       /         /",oFont08n)
		oPrn:Line(nLin+003,nCol+002,nLin+001,nCol+460)
		nLin += nAltCel

		oPrn:Say(nLin,nCol+005,"Lider:      ",oFont08n)
		oPrn:Say(nLin,nCol+350,"       /         /",oFont08n)
		nLin +=  nAltCel

		// FIM - QUADRO DE ASSINATURAS NO RODAPÉ

	EndIf

	nLin := 735

	// IMPRESSÂO QR-CODE 
	oPrn:Line(nLin,nCol,nLin,NMAXCOL)
	nLin += 10

	oPrn:Say(nLin, nCol+050,"INICIAR PRODUÇÃO  ",oFont08)
	oPrn:Say(nLin, nCol+430,"FINALIZAR PRODUÇÃO",oFont08)
	nLin += 05

	oPrn:Line(nLin,nCol,nLin,NMAXCOL)
	nLin += 60

	oPrn:DataMatrix(nCol+060,nLin,"01",55)
	oPrn:DataMatrix(nCol+440,nLin,"04",55)

	If 	lOrdAnalise 
		// Cabeçalho
		nLin := NMINLIN
		nCol := NMINCOL
		fPrintCab("2",.F.)

		// INICIO - NOVO QUADRO - RESULTADO DE ANALISE

		nLenCel  := 50 //55                 // Largura da Celula
		nAltCel  := 18                      // Largura da Linha
		nTotLin  := 11                      // Total de Linhas
		nAltura  := nAltCel * nTotLin       // Altura do Quadro (Onze linhas com 20 de altura)
		nLinIni  := 0                       // Linha Inicial     
		nLinFim  := 0                       // Linha Final do Box
		nPonta   := 2 * nAltCel             // Ponta da Linhas
		nLinDados:= 0                       // Linha Inicial para Impressão dos Dados

		nLin += nAltCel
		oPrn:Say(nLin,nCol+255,"RESULTADOS DE ANÁLISE",oFont08n)
		nLin += 005
		
		oPrn:Box(nLin,nCol+000,nLin+nAltura,NMAXCOL)                          // Box Externo
		nLinIni := nLin

		// Titulo e Linhas Verticais até a 3a. Amostra
		oPrn:Box(nLin,nCol+000,nLin+nAltCel,NMAXCOL-000)                          // Box dos Titulos

		oPrn:Say(nLin+012,nCol+005,"Ensaios    ",oFont08n)
		nCol += nLenCel + 38
		
		oPrn:Line(nLinIni,nCol+000,nLinIni+nAltura+nPonta,nCol+000)					   // Linha de separação das colunas - 1
		oPrn:Say(nLin+012,nCol+005,"Limites    ",oFont08n)
		nCol += nLenCel + 10
		
		oPrn:Line(nLinIni,nCol+000,nLinIni+nAltura,nCol+000)					       // Linha de separação das colunas - 2
		nLenCel := 60 // 66

		oPrn:Say(nLin+012,nCol+008,"1a. Amostra",oFont08n)
		nCol += nLenCel
		
		oPrn:Line(nLinIni,nCol+000,nLinIni+nAltura+nPonta,nCol+000)					   // Linha de separação das colunas - 3
		oPrn:Say(nLin+012,nCol+008,"2a. Amostra",oFont08n)
		nCol += nLenCel
		
		oPrn:Line(nLinIni,nCol+000,nLinIni+nAltura+nPonta,nCol+000)					   // Linha de separação das colunas - 4
		oPrn:Say(nLin+012,nCol+008,"3a. Amostra",oFont08n)
		nCol += nLenCel
		
		oPrn:Line(nLinIni,nCol+000,nLinIni+nAltura,nCol+000)					       // Linha de separação das colunas - 5
		oPrn:Say(nLin+012,nCol+085,"Observação LCQ",oFont08n)

		nCol      += nLenCel
		nLinDados := nLin+012                                                          // Linha Inicial para Impressão dos Dados
		nLenCel   := 58 

		// Linhas Verticais abaixo da "Observação LCQ"
		oPrn:Line(nLinIni+nAltCel,nCol+000,nLinIni+nAltura,nCol+000)
		nCol += nLenCel
		
		oPrn:Line(nLinIni+nAltCel,nCol+000,nLinIni+nAltura,nCol+000)
		nCol += nLenCel
		
		oPrn:Line(nLinIni+nAltCel,nCol+000,nLinIni+nAltura,nCol+000)
		nCol += nLenCel

		// Linhas Horizontais do quadro
		nLinIni += nAltCel * 2
		nCol    := NMINCOL

		For nQtdLinha := 1 to nTotLin - 2
			oPrn:Line(nLinIni,nCol+000,nLinIni,NMAXCOL)
			nLinIni += nAltCel
		Next nQtdLinha

		// Rodapé do quadro de Resultados da Analise
		nLin    := nLinIni
		nLenCel := 55
		nTotLin := 2
		nAltura := nAltCel * nTotLin // Onze linhas com 20 de altura
		nLinIni := 0   

		oPrn:Line(nLin+nAltura,nCol+000,nLin+nAltura,NMAXCOL)                         
		nLinIni := nLin

		// Titulo e Linhas Verticais até a 3a. Amostra              
		oPrn:Say(nLin+012,nCol+005,"Data Inicio:",oFont08n) 
		nCol += nLenCel + 35

		nLenCel := 66 		
		oPrn:Say(nLin+012,nCol+005,"               /               / ",oFont08n)
		nCol += 120    
		
		oPrn:Say(nLin+012,nCol+005,"Analista Resp:",oFont08n)
		nCol += nLenCel

		nLin    += nAltCel
		nLenCel := 55
		nCol    := NMINCOL

		oPrn:Line(nLin,nCol+000,nLin,NMAXCOL)
		oPrn:Say(nLin+012,nCol+005,"Data Final:",oFont08n)
		nCol += nLenCel + 35
		
		nLenCel := 66 
		oPrn:Say(nLin+012,nCol+005,"               /               / ",oFont08n)
		
		nCol += 120    
		oPrn:Say(nLin+012,nCol+005,"Supervisor:",oFont08n)
		
		nCol += nLenCel
		nLinFim := nLin + nAltCel

		// TERMINO - NOVO QUADRO - RESULTADO DE ANALISE

		//---------------------------------------------------
		// Impressão dos daados no Resultado da Analise
		//---------------------------------------------------
		cQuery := "SELECT QPJ_ITEM, QPJ_ENSAIO, QPJ_DUNMED, " + CRLF
		cQuery += "       UPPER(QPJ_DESENS) ENSAIO,QPJ_LINF LIMINF, " + CRLF
		cQuery += "       QPJ_LSUP LIMSUP, QPJ_TEXTO TEXTO, " + CRLF
		cQuery += "       CASE WHEN QP1_TIPO = 'C' " + CRLF
		cQuery += "       THEN 'Calculado' ELSE 'Digitado' END TIPO, " + CRLF
		cQuery += "       QP1_QTDE, QP1_METODO " + CRLF
		cQuery += "FROM " + RetSqlName("QPJ") + " QPJ (NOLOCK) " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("QP1") + " QP1 (NOLOCK) " + CRLF
		cQuery += "	 ON QP1_FILIAL = '" + xFilial("QP1") + "' " + CRLF
		cQuery += "  AND QPJ_ENSAIO = QP1_ENSAIO " + CRLF
		cQuery += "  AND QP1.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "WHERE QPJ_FILIAL = '" + xFilial("QPJ") + "' " + CRLF
		cQuery += "	AND QPJ_PROD = '" + TMPCOM->C2_PRODUTO + "' " + CRLF
		cQuery += "AND QPJ.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "ORDER BY QPJ_PROD, QPJ_ITEM " + CRLF

		TCQuery cQuery New Alias "TMPQUA"
		dbSelectArea("TMPQUA")
		dbGoTop()

		If !TMPQUA->( Eof() )  
			lQualidade := .T.
		Else
			lQualidade := .F.
		EndIf

		nLin    := nLinDados+nAltCel
		nLenCel := 45

		While !TMPQUA->( Eof() ) 

			nCol    := NMINCOL

			cLimite := AllTrim(Transform( TMPQUA->LIMINF, PesqPict("QPJ","QPJ_LINF",14))) + " - " 
			cLimite += AllTrim(Transform( TMPQUA->LIMSUP, PesqPict("QPJ","QPJ_LSUP",14)))
			cLimite := Padl(cLimite, 15)

			cEnsaio := Lower(AllTrim(TMPQUA->ENSAIO))
			cEnsaio := Upper(Subs(cEnsaio, 1, 1)) + Subs(cEnsaio, 2, 50)
			cEnsaio := Padr(cEnsaio, 20)

			oPrn:Say(nLin,nCol+005,cEnsaio,oFont08n)
			nCol += nLenCel + 41
			
			oPrn:Say(nLin,nCol+005,cLimite,oFont08n)
			nCol += nLenCel

			nLin += nAltCel

			TMPQUA->( dbSkip() )

		EndDo

		TMPQUA->( dbCloseArea() )

		// INICIO  - NOVO QUADRO - EDIÇÃO EXTRA FÓRMULA
		nLenCel := 55
		nTotLin := 13
		nAltura := nAltCel * nTotLin // Onze linhas com 20 de altura
		nLinIni := nLinFim           // Recomeça a partir da linha final do box anterior

		nCol := NMINCOL
		nLin := nLinIni + nAltCel

		oPrn:Box(nLin    , nCol+000,nLin+nAltura,NMAXCOL)                          // Box Externo
		oPrn:Say(nLin+012, nCol+255,"EDIÇÃO EXTRA FÓRMULA",oFont08n)

		nLin    += nAltCel
		nLinIni := nLin

		oPrn:Say(nLin+012, nCol+005,"EXTRA",oFont08n)
		nCol += nLenCel
		
		oPrn:Line(nLinIni,nCol+000,nLinIni+nAltura,nCol)
		oPrn:Say(nLin+012, nCol+005,"TRT",oFont08n)
		nCol += nLenCel
		
		oPrn:Line(nLinIni,nCol+000,nLinIni+nAltura,nCol)
		nLenCel := 66

		oPrn:Say(nLin+012, nCol+005,"CÓDIGO",oFont08n)
		nCol += nLenCel
		
		oPrn:Line(nLinIni,nCol+000,nLinIni+nAltura,nCol)
		nLenCel := 196
		
		oPrn:Say(nLin+012, nCol+005,"DESCRIÇÃO",oFont08n)
		nCol += nLenCel
		
		oPrn:Line(nLinIni,nCol+000,nLinIni+nAltura,nCol)
		nLenCel := 66
		
		oPrn:Say(nLin+012, nCol+005,"LOTE",oFont08n)
		nCol += nLenCel
		
		oPrn:Line(nLinIni,nCol+000,nLinIni+nAltura,nCol)
		oPrn:Say(nLin+012, nCol+005,"1o. Ajuste",oFont08n)
		nCol += nLenCel
		
		oPrn:Line(nLinIni,nCol+000,nLinIni+nAltura,nCol)
		oPrn:Say(nLin+012, nCol+005,"2o. Ajuste",oFont08n)

		// Linhas Horizontais do quadro
		nCol := NMINCOL

		For nQtdLinha := 1 to nTotLin + 1
			oPrn:Line(nLin,nCol+000,nLin,NMAXCOL)
			nLin += nAltCel
		Next nQtdLinha

		// TERMINO - NOVO QUADRO - EDIÇÃO EXTRA FÓRMULA

		nLin := 735
		nCol := NMINCOL

		// IMPRESSÂO QR-CODE 
		oPrn:Say(nLin, nCol+050,"INICIAR PRODUÇÃO  ",oFont08)
		oPrn:Say(nLin, nCol+430,"FINALIZAR PRODUÇÃO",oFont08)
		nLin += 05

		oPrn:Line(nLin,nCol,nLin,NMAXCOL)
		nLin += 60

		oPrn:DataMatrix(nCol+060, nLin, "01" , 55 )
		oPrn:DataMatrix(nCol+440, nLin, "04" , 55 )
	EndIf

	TMPROT->( dbCloseArea() )

	// Salta pagina
	oPrn:EndPage()
	nLin := NMINLIN
	nCol := NMINCOL

Return nLin

Static Function CabPrIt(nLin,nCol)

Return nLin

/*/{Protheus.doc} StartPrint
Objeto de impressão
@type Static function Relatorio
@version  1.00
@author fabio carneiro dos Santos
@author Paulo Rogerio
@since 20/07/2022
@param nPage, numeric, Numero da Pagina
@return character, sem retorno
/*/
Static Function StartPrint()

	If ValType(oPrn) == "O"
		oPrn:Print()
	Else
		MsgInfo('O Objeto de impressão não foi inicializado com exito')
	EndIf

Return

/*/{Protheus.doc} ValidPerg
Criação das perguntas do relatorio
@type Static function Relatorio
@version  1.00
@author fabio carneiro dos Santos
@author Paulo Rogerio
@since 20/07/2022
@param nPage, numeric, Numero da Pagina
@return character, sem retorno
/*/
Static Function ValidPerg()

	Local _aArea := GetArea()
	Local _aPerg := {}
	Local i      := 0

	cPerg := Padr( cPerg, 10)

	aAdd(_aPerg, {cPerg,"01","Da Ordem Produção     ?","MV_CH1","C",11,0,"G","MV_PAR01","SC2",""   ,""   ,"" ,"",""})
	aAdd(_aPerg, {cPerg,"02","Até Ordem Produção    ?","MV_CH2","C",11,0,"G","MV_PAR02","SC2",""   ,""   ,"" ,"",""})
	aAdd(_aPerg, {cPerg,"03","Imp. QR Code 20/30/50 ?","MV_CH2","N",01,0,"C","MV_PAR03","   ","Sim","Não","" ,"",""})

	DbSelectArea("SX1")
	DbSetOrder(1)

	For i := 1 To Len(_aPerg)

		IF  !DbSeek(_aPerg[i,1]+_aPerg[i,2])
			RecLock("SX1",.T.)
		Else
			RecLock("SX1",.F.)
		EndIf

		SX1->X1_GRUPO   := _aPerg[i,01]
		SX1->X1_ORDEM   := _aPerg[i,02]
		SX1->X1_PERGUNT := _aPerg[i,03]
		SX1->X1_VARIAVL := _aPerg[i,04]
		SX1->X1_TIPO	:= _aPerg[i,05]
		SX1->X1_TAMANHO := _aPerg[i,06]
		SX1->X1_PRESEL  := _aPerg[i,07]
		SX1->X1_GSC	    := _aPerg[i,08]
		SX1->X1_VAR01   := _aPerg[i,09]
		SX1->X1_F3	    := _aPerg[i,10]
		SX1->X1_DEF01   := _aPerg[i,11]
		SX1->X1_DEF02   := _aPerg[i,12]
		SX1->X1_DEF03   := _aPerg[i,13]
		SX1->X1_DEF04   := _aPerg[i,14]
		SX1->X1_DEF05   := _aPerg[i,15]
		MsUnlock()

	Next i

	RestArea(_aArea)

Return(.T.)


/*/{Protheus.doc} fPrintCab
Impressão do Cabeçalho da Ordem de Produção
@type Static function Relatorio
@version  1.00
@author fabio carneiro dos Santos
@author Paulo Rogerio
@since 20/07/2022
@param nPage, numeric, Numero da Pagina
@return character, sem retorno
/*/
Static Function fPrintCab(cTipoCab, lPrintPMP, lEnvase)

	Local cCabecalho := "ORDEM DE PRODUÇÃO"

	nLin := NMINLIN
	nCol := NMINCOL

	Default cTipoCab  := "1"
	Default lPrintPMP := .T.
	Default lEnvase   := .T.

	cCabecalho := If(cTipoCab=="1",cCabecalho,"ORDEM DE ANÁLISE")

	If cEmpAnt == "02"
		cLogo     := "logoeuro.bmp"
		cCartCorp := "coletor.jfif"
		cEmpresa  := "Euroamerican"
	Else
		cLogo     := "logoqualy.bmp"
		cCartCorp := "coletor.jfif"
		cEmpresa  := "Qualycril"
	EndIf

	oPrn:StartPage()
	nPagOP++

	nPagina++
	nPage++

	// INICIO CABEÇALHO DO RELATORIO
	oPrn:Box(nLin+20,nCol,NMAXLIN,NMAXCOL)

	// Logo Descriçao Filial
	nLin += 25
	oPrn:SayBitmap(nLin,nCol+5,GetSrvProfString("Startpath","")+cLogo,55,17)
	nLin += 5
	oPrn:Say(nLin,nCol+70,AllTrim(SM0->M0_FILIAL),oFont06)
	oPrn:Say(nLin,NMAXCOL-40,"Página: "+StrZero(nPagina,3),oFont06)
	nLin += 5
	oPrn:Say(nLin,nCol+70,PadC(cCabecalho,120),oFont14n)

	IF lPrintPMP
		oPrn:Box(nLin+05,nCol+383,nLin+75,NMAXCOL-5  ) //Quadro   
		nLin += 15
		oPrn:Say(nLin,nCol+390,"PCP                       PMP QUALYVINIL",oFont10n,,CLR_BLACK)
		oPrn:Line(nLin+3,nCol+383,nLin+3,NMAXCOL-5)  
		nLin += 12
		oPrn:Say(nLin,nCol+390,"        Equipamento                   Sequência",oFont10n,,CLR_BLACK)
		oPrn:Line(nLin+05,nCol+383,nLin+05,NMAXCOL-05) //  Linha Horizontal
		oPrn:Line(nLin-22,nCol+420,nLin-10,nCol + 420) //  Linha Vertical 1
		oPrn:Line(nLin+05,nCol+480,nLin+32,nCol + 480) //  Linha Vertical 2
	Else
		nLin += 15
		nLin += 12
	EndIf

	IF cTipoCab == '2'
		nLin -= 15 
	EndIf

	nLin += 10  //alterado de 20 para 10 
	oPrn:Say(nLin,nCol+005,"LOTE: "+TMPCOM->C2_NUM+" "+TMPCOM->C2_ITEM+" "+TMPCOM->C2_SEQUEN,oFont08n)
	nLin += 10  //alterado de 20 para 10 
	oPrn:Say(nLin,nCol+005,"PRODUTO: "+TMPCOM->C2_PRODUTO,oFont08n)
	nLin += 10  //alterado de 20 para 10 

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1") + TMPCOM->C2_PRODUTO))
	oPrn:Say(nLin,nCol+005,"DESCRIÇÂO: " + AllTrim(SB1->B1_DESC),oFont08n)

	cQuery := "SELECT CB7_ORDSEP FROM "+RetSqlName("CB7")+" "+CRLF
	cQuery += "WHERE CB7_FILIAL = '"+xFilial("CB7")+"' "+CRLF
	cQuery += "AND CB7_OP = '"+TMPCOM->(C2_NUM+C2_ITEM+C2_SEQUEN) + "' "+CRLF
	cQuery += "AND D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "ORDER BY CB7_ORDSEP "+CRLF

	TCQuery cQuery New Alias "TMPSEP"

	dbGoTop()

	While !TMPSEP->( Eof() )
		nLin += 10
		oPrn:Say(nLin,nCol+5,"ORDEM DE SEP.: " + TMPSEP->CB7_ORDSEP,oFont08n)
		nLin += 5
		TMPSEP->( dbSkip() )
	EndDo
	
	TMPSEP->( dbCloseArea() )

	nLin := 117 

	IF cTipoCab == '1'
		oPrn:DataMatrix(nCol+250, nLin+10, TMPCOM->C2_NUM + TMPCOM->C2_ITEM + TMPCOM->C2_SEQUEN, 55 )
	EndIf

	nLin += 15

	IF lPrintPMP
	 	// Linha acima linha data do quadro
		oPrn:Line(nLin-08,nCol+383,nLin-08,NMAXCOL-5)
		oPrn:Say(nLin+5,nCol+390,"DATA:              /            /"          ,oFont10n,,CLR_BLACK)
	EndIf

	IF cTipoCab == '1'
		nLin += 20  
	Else
		nLin -= 15 
	EndIf

	IF cTipoCab == "1"

		IF lEnvase
			oPrn:Say(nLin,nCol+005,"Qtd. Prev. (KG): " + Transform( TMPCOM->C2_QUANT, "@E 999,999,999.99"),oFont08)
			oPrn:Say(nLin,nCol+200,"Quant. Calc : ( ______________ )   KG",oFont08n)
			oPrn:Say(nLin,nCol+383,"Quant. Real : ( ______________ )   KG",oFont08n)	
		Else
			oPrn:Say(nLin,nCol+005,"Qtd. Prev. (KG): " + Transform( TMPCOM->C2_QUANT, "@E 999,999,999.99"),oFont08) 
			oPrn:Say(nLin,nCol+200,"Revisão: "+Posicione("SB1", 1, xFilial("SB1") + TMPCOM->C2_PRODUTO, "B1_REVATU"),oFont08)
			oPrn:Say(nLin,nCol+393,"Quant. Real : ( ______________ )   KG",oFont08n)
		EndIf 

	EndIf

	nLin += 003
	oPrn:Line(nLin+05,nCol,nLin+05,NMAXCOL)
    
	// FIM - CABEÇALHO DO RELATORIO

Return
