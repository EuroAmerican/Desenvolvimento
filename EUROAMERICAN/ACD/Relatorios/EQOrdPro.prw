#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "RptDef.ch"
#Include "FWPrintSetup.ch"
#Include "TopConn.ch"
#Include 'TbiConn.Ch'
#Include 'Totvs.Ch'
#Include 'Ap5Mail.Ch'

#Define	 IMP_DISCO 	1
#Define	 IMP_SPOOL 	2
#Define	 IMP_EMAIL 	3
#Define	 IMP_EXCEL 	4
#Define	 IMP_HTML  	5
#Define	 IMP_PDF   	6

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ EQOrdPro ³ Autor ³ Fabio F Sousa        ³ Data ³ 01/09/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatório de Ordem de Produção...                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Qualycril                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function EQOrdPro( _cNumOP ) //U_EQOrdPro( "010308" )

Local aArea         := GetArea()
Local aAreaSC2      := SC2->( GetArea() )

Private oPrn 		:= Nil
Private oSetup		:= Nil
Private cNumOP      := ""
Private cQuery      := ""
Private cPathDest   := "c:\temp\"
Private cRelName    := "OP_" + AllTrim( _cNumOP ) + "_"  + DTOS( dDataBase ) + "_" + Replace( Time(), ":", "") + ".PDF"
Private cPedCompr	:= ""
Private	cPedSolic	:= ""
Private	cPedAprov	:= ""
Private cPedVisto	:= ""
Private nTotGeral	:= 0
Private ini     	:= 050
Private nLin    	:= 050
Private int     	:= 050
Private nCenter 	:= 0
Private nPag		:= 1
Private nLinFimIt	:= 2300
Private nLinFim		:= 2000
Private lProc       := .T.
Private cPerg	    := "BENOVORDEM"
Private lPrimeiro   := .T.

Default _cNumOP     := ""

MakeDir( "C:\Temp\" )

If Empty( _cNumOP )
	ValidPerg()
	Pergunte( cPerg, .T.)
	_cNumOP := mv_par01
EndIf

cNumOP := AllTrim( _cNumOP )

CarregaDados()

TCQuery cQuery New Alias "TMPCOM"
dbSelectArea("TMPCOM")
TMPCOM->( dbGoTop() )

If TMPCOM->( Eof() )
	lProc := .F.
EndIf

If lProc
	MsgRun("Gerando Impressão da Ordem de Produção. Aguarde.....", "Imprimindo", {|| RunImp() })
EndIf

TMPCOM->( dbCloseArea() )

SC2->( RestArea( aAreaSC2 ) )
RestArea( aArea )

Return

Static Function CarregaDados()

cQuery := "SELECT * " + CRLF
cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
cQuery += "  AND B1_COD = C2_PRODUTO " + CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
cQuery += "AND C2_NUM = '" + cNumOP + "' " + CRLF
cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "ORDER BY C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO " + CRLF

Return cQuery

Static Function RunImp()

// Define Variaveis de Objeto
oFont06  := TFont():New( "Courier New",, 10,,.F.)
oFont08  := TFont():New( "Arial",, 10,,.F.)
oFont08n := TFont():New( "Arial",, 10,,.T.)
oFont10  := TFont():New( "Arial",, 12,,.F.)
oFont10n := TFont():New( "Arial",, 12,,.T.)
oFont10c := TFont():New( "Courier New",, 12,,.F.)
oFont12  := TFont():New( "Arial",, 14,,.F.)
oFont12n := TFont():New( "Arial",, 14,,.T.)
oFont13  := TFont():New( "Arial",, 15,,.F.)
oFont13n := TFont():New( "Arial",, 15,,.T.)
oFont14  := TFont():New( "Arial",, 16,,.F.)
oFont14n := TFont():New( "Arial",, 16,,.T.)
oFontCAc := TFont():New( "Courier New",, 20,,.F.)
oFontCAn := TFont():New( "Courier New",, 20,,.T.)
oFont0   := TFont():New( "Courier New",, 10,, .F.,,,,, .F.)

//oPrn := FwMsPrinter():New(cRelName,IMP_PDF,.T.,cPathDest,.T.,.F.,@oPrn,,,.F.,.F.,.T.,)
oPrn := FwMsPrinter():New(cRelName,IMP_PDF,.F.,cPathDest,.T.,.F.,@oPrn,,,.F.,.F.,.T.,)
oPrn:SetResolution(75)
oPrn:SetLandscape() 			//SetPortrait()
oPrn:SetPaperSize(DMPAPER_A4)
oPrn:SetMargin(00,00,00,00)		//nEsquerda, nSuperior, nDireita, nInferior
oPrn:cPathPDF := cPathDest		//Caso seja utilizada impressão em IMP_PDF

oPrn:StartPage()

PCCabec()
PCForn()
PCCabIt()
//PCItem()
//PCTotal()

oPrn:EndPage()
oPrn:Print()

If File( AllTrim( cPathDest ) + AllTrim( cRelName ) )
	//PCEmail()
EndIf

Return

Static Function PCCabec()

Local cPCLogo := ""

If cEmpAnt == "02"
	cPCLogo := "logoeuro.bmp"
Else
	cPCLogo := "logoqualy.bmp"
EndIf

nLin      := 50
ini       := 050
int       := 050
nCenter   := 0
nLinFimIt := 2300
nLinFim   := 2000

oPrn:Line(nLin,ini,nLin,3100)
oPrn:SayBitmap(75,ini+20,cPCLogo,560,193, , .T. )

//NextLine(2,.f.)
//oPrn:Say(nLin-10,ini+2600,"Data:",oFont10n,100)
//oPrn:Say(nLin-10,ini+2740, dtoc(MsDate())	,oFont10,100)

cRevisao := fBuscaRev( TMPCOM->C2_NUM )

NextLine(1,.f.)
oPrn:Say(nLin-10,ini+2600,"Revisão:",oFont10n,100)
oPrn:Say(nLin-10,ini+2740, cRevisao	,oFont10n,100)

NextLine(1,.f.)
oPrn:Say(nLin-10,ini+2600,"Data:",oFont10n,100)
oPrn:Say(nLin-10,ini+2740, dtoc(MsDate())	,oFont10,100)

NextLine(1,.f.)
oPrn:Say(nLin-10,ini+1200+nCenter,"ORDEM DE PRODUÇÃO No. " + TMPCOM->C2_NUM ,oFont14n,100)
oPrn:Say(nLin-10,ini+2600,"Hora:",oFont10n,100)
oPrn:Say(nLin-10,ini+2740, Time()	,oFont10,100)

NextLine(1,.f.)
oPrn:Say(nLin-10,ini+2600,"Página:",oFont10n,100)
oPrn:Say(nLin-10,ini+2740, cValtoChar(nPag)	,oFont10,100)

NextLine(1,.T.)

Return

Static Function PCForn()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Box 1 - Dados Fornecedor e Filial                    									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//oPrn:Line(nLin,ini+1525,nLin+300,ini+1525) // Linha Vertical     180

NextLine(1,.f.)

oPrn:Say(nLin+10,ini+0020,Capital(SM0->M0_NOMECOM),oFont12,100)  // Nome da Filial
//oPrn:DataMatrix(780,135, Alltrim( TMPCOM->C2_NUM ), 60 )

/*
NextLine(1,.f.)

oPrn:Say(nLin+10,ini+0020,Capital(AllTrim(SM0->M0_ENDENT))+" - "+Capital(AllTrim(SM0->M0_BAIRENT)),oFont12,100)  // End Entrega da Filial

NextLine(1,.f.)

oPrn:Say(nLin+10,ini+0020,"CEP: "+Trans(SM0->M0_CEPENT,"@R 99999-999")+" - "+Capital(AllTrim(SM0->M0_CIDENT))+" - "+SM0->M0_ESTENT,oFont12,100)

NextLine(1,.f.)

oPrn:Say(nLin+10,ini+0020,"TEL/FAX: "+SM0->M0_TEL,oFont12,100)
*/
//NextLine(1,.f.)

Return

Static Function PCCabIt()

//oPrn:Line(nLin,ini+1525,nLin+300,ini+1525) // Linha Vertical     180

dbSelectArea("TMPCOM")
TMPCOM->( dbGoTop() )

nBar := 135

Do While !TMPCOM->( Eof() )
	NextLine(1,.T.)
	
	NextLine(1,.F.)
	
	If nLin > 2300 .Or. !lPrimeiro
		NextLine(1,.t.)
		oPrn:EndPage()
		oPrn:StartPage()
		nPag := nPag + 1
		nBar      := 135
		nLin      := 50
		ini       := 050
		int       := 050
		nCenter   := 0
		nLinFimIt := 2300
		nLinFim   := 2000
		//PCCabec()
		PCForn()
		PCCabIt()
	EndIf

	nBar += 30
	oPrn:DataMatrix(795, nBar, TMPCOM->C2_NUM + TMPCOM->C2_ITEM + TMPCOM->C2_SEQUEN, 60 )
	nBar += 45
	
	oPrn:Say(nLin+10,ini+0020,"ORDEM DE PRODUÇÃO: " + TMPCOM->C2_NUM + " ITEM: " + TMPCOM->C2_ITEM + " SEQUÊNCIA: " + TMPCOM->C2_SEQUEN, oFont12n,100)
	NextLine(1,.F.)
	
	oPrn:Say(nLin+10,ini+0020,"Produto: " + TMPCOM->C2_PRODUTO + " Descrição: " + TMPCOM->B1_DESC + " Local: " + TMPCOM->C2_LOCAL + " | Prev. Início: " + DTOC(STOD( TMPCOM->C2_DATPRI )) + " Prev. Final: " + DTOC( STOD( TMPCOM->C2_DATPRF ) ),oFont12,100)  // End Entrega da Filial

	NextLine(1,.F.)

	//oPrn:Say(nLin+10,ini+0020,"Quantidade: " + Transform( TMPCOM->C2_QUANT, PesqPict("SC2","C2_QUANT")) + " | U.M.: " + AllTrim( TMPCOM->B1_UM ) + " | Qtd. 2a. UM: " + Transform( TMPCOM->C2_QTSEGUM, PesqPict("SC2","C2_QTSEGUM")) + " | 2a. U.M.: " + AllTrim( TMPCOM->B1_SEGUM ) + " | Fator: " + Transform( TMPCOM->B1_CONV, PesqPict("SB1","B1_CONV")),oFont12,100)
	oPrn:Say(nLin+10,ini+0020,"Quantidade: " + Transform( TMPCOM->C2_QUANT, PesqPict("SC2","C2_QUANT")) + " | U.M.: " + AllTrim( TMPCOM->B1_UM ) + " | 2a. U.M.: " + AllTrim( TMPCOM->B1_SEGUM ) + " | Fator: " + Transform( TMPCOM->B1_CONV, PesqPict("SB1","B1_CONV")),oFont12,100)

	NextLine(1,.F.)

	If !Empty( TMPCOM->C2_ROTEIRO )
		oPrn:Say(nLin+10,ini+0020,"Roteiro de Operação: " + AllTrim( TMPCOM->C2_ROTEIRO ),oFont12n,100)
	
		NextLine(1,.F.)
	
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
			nBar += 25

			oPrn:Say(nLin+10,ini+0020,"Operação.: " + TMPROT->G2_OPERAC + " | " + TMPROT->G2_DESCRI, oFont10c, 100)
			oPrn:Say(nLin+10,ini+1020,"Recurso..: " + TMPROT->G2_RECURSO + " | " + TMPROT->H1_DESCRI, oFont10c, 100)
			oPrn:Say(nLin+10,ini+1940,"Ct Trab..: " + TMPROT->G2_CTRAB + " | " + TMPROT->HB_NOME, oFont10c, 100)

			NextLine(1,.F.)

			oPrn:Say(nLin+10,ini+0020,"Dt/Hr Início.: ____/____/____  ____:____", oFont10c, 100)
			oPrn:Say(nLin+10,ini+1540,"Dt/Hr Fim:     ____/____/____  ____:____", oFont10c, 100)

			NextLine(1,.f.)

			TMPROT->( dbSkip() )
		EndDo

		TMPROT->( dbCloseArea() )

		cQuery := "SELECT Z0_OPERAC, ISNULL(RTRIM(LTRIM(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),Z0_DESCRIC)))), '') AS INSTRUCAO "
		cQuery += "FROM " + RetSqlName("SZ0") + " AS SZ0 WITH (NOLOCK) "
		cQuery += "WHERE Z0_FILIAL = '" + xFilial("SZ0") + "' "
		cQuery += "AND Z0_PRODUTO = '" + TMPCOM->C2_PRODUTO + "' "
		cQuery += "AND SZ0.D_E_L_E_T_ = ' ' "

		TCQuery cQuery New Alias "TMPINS"
		dbSelectArea("TMPINS")
		dbGoTop()

		If !TMPINS->( Eof() )
			oPrn:Say(nLin+10,ini+0020,"Instrução de Trabalhos:",oFont12n,100)
			NextLine(1,.F.)
		EndIf
		
		Do While !TMPINS->( Eof() )
			nBar += 10

			oPrn:Say(nLin+10,ini+0020,"Item: " + AllTrim( TMPINS->Z0_OPERAC ) + " | " + AllTrim( TMPINS->INSTRUCAO), oFont10c, 100)

			TMPINS->( dbSkip() )

			If !TMPINS->( Eof() )
				NextLine(1,.F.)
			EndIf
		EndDo

		TMPINS->( dbCloseArea() )
	EndIf

	lPrimeiro := .F.

    TMPCOM->( dbSkip() )
EndDo

NextLine(1,.T.)

/*
oPrn:Say(nLin-10,ini+0020,"Item"		,oFont10n,100)
oPrn:Say(nLin-10,ini+0120,"Código"		,oFont10n,100)
oPrn:Say(nLin-10,ini+0350,"Descrição"	,oFont10n,100)
oPrn:Say(nLin-10,ini+1000,"Observações"	,oFont10n,100)
oPrn:Say(nLin-10,ini+1600,"1°UM"		,oFont10n,100)
oPrn:Say(nLin-10,ini+1700,"Qtde."		,oFont10n,100)
oPrn:Say(nLin-10,ini+1900,"2°UM"		,oFont10n,100)
oPrn:Say(nLin-10,ini+2000,"Qtde."		,oFont10n,100)
oPrn:Say(nLin-10,ini+2300,"Valor Unit."	,oFont10n,100)
oPrn:Say(nLin-10,ini+2600,"Valor Total"	,oFont10n,100)
oPrn:Say(nLin-10,ini+2900,"Entrega"		,oFont10n,100)
*/

Return

Static Function PCItem()

dbSelectArea("TMPCOM")
TMPCOM->( dbGoTop() )

While !TMPCOM->(Eof())

	NextLine(1,.f.)

	oPrn:Say(nLin-10,ini+0020,TMPCOM->C7_ITEM														,oFont08,100)
	oPrn:Say(nLin-10,ini+0120,TMPCOM->C7_PRODUTO													,oFont08,100)
	oPrn:Say(nLin-10,ini+0350,SubStr(AllTrim(TMPCOM->C7_DESCRI),1,35)								,oFont08,100)
	oPrn:Say(nLin-10,ini+1000,SubStr(AllTrim(TMPCOM->C7_OBS),1,35)									,oFont08,100)
	oPrn:Say(nLin-10,ini+1600,TMPCOM->C7_UM															,oFont08,100)
	oPrn:Say(nLin-10,ini+1700,Transform(TMPCOM->C7_QUANT,PesqPict("SC7","C7_QUANT"))	   			,oFont08,100)
	oPrn:Say(nLin-10,ini+1900,TMPCOM->C7_SEGUM														,oFont08,100)
	oPrn:Say(nLin-10,ini+2000,Transform(TMPCOM->C7_QTSEGUM,PesqPict("SC7","C7_QTSEGUM")) 			,oFont08,100)
	oPrn:Say(nLin-10,ini+2300,Transform(TMPCOM->C7_PRECO,PesqPict("SC7","C7_PRECO"))				,oFont08,100)
	oPrn:Say(nLin-10,ini+2600,Transform(TMPCOM->C7_TOTAL ,PesqPict("SC7","C7_TOTAL"))				,oFont08,100)
	oPrn:Say(nLin-10,ini+2900,DtoC(STOD(TMPCOM->C7_DATPRF))											,oFont08,100)

	/*
	If nLin > nLinFimIt
		nPag := nPag + 1
		NextLine(1,.t.)
		oPrn:EndPage()
		oPrn:StartPage()
		PCCabec()
		PCForn()
		PCCabIt()
	EndIf
	*/

	cAux := AllTrim(SubStr(TMPCOM->C7_DESCRI,36))
	cAux1:= AllTrim(SubStr(TMPCOM->C7_OBS,36))
	While !Empty(cAux) .Or. !Empty(cAux1)

		NextLine(1,.f.)
		oPrn:Say(nLin-10,ini+0350,Substr(cAux ,1,36),oFont08,100)
		oPrn:Say(nLin-10,ini+1000,Substr(cAux1,1,36),oFont08,100)


		cAux := SubStr(cAux,35)
		cAux1 := SubStr(cAux1,35)
		If nLin > nLinFimIt .and. (!Empty(cAux) .or. !Empty(cAux1))
			nPag := nPag + 1
			NextLine(1,.t.)
			oPrn:EndPage()
			oPrn:StartPage()
			PCCabec()
			PCForn()
			PCCabIt()
		EndIf
	EndDo

    TMPCOM->(dbSkip())
EndDo

NextLine(1,.t.)

Return

Static function PCTotal()

Local cAssComp	:= "" // Assinatura Digitalizada do Comprador
Local cAssAprv	:= "" // Assinatura Digitalizada do Aprovador

nTotGeral 	:= 0
nTotMerc	:= 0
nTotFrete 	:= 0
nTotDespe 	:= 0
nTotSegur 	:= 0
nTotIpi		:= 0
nTotDesc	:= 0

dbSelectArea("TMPCOM")
TMPCOM->(dbGoTop())

While !TMPCOM->(Eof())
	nTotMerc  	+= TMPCOM->C7_TOTAL
	nTotFrete 	+= TMPCOM->C7_VALFRE
	nTotDespe 	+= TMPCOM->C7_DESPESA
	nTotSegur 	+= TMPCOM->C7_SEGURO
	nTotDesc  	+= TMPCOM->C7_VLDESC
	nTotIpi 	+= TMPCOM->C7_VALIPI

	TMPCOM->(dbSkip())
EndDo

TMPCOM->(dbGoTop())

cPedSolic	:= AllTrim(TMPCOM->SOLICITANTE)
cPedCompr	:= AllTrim(TMPCOM->COMPRADOR)
cPedAprov	:= AllTrim(TMPCOM->APROVADOR)
nTotGeral	:= (nTotMerc+nTotIpi+nTotFrete+nTotDespe+nTotSegur) - nTotDesc

If nLin > nLinFim
	nPag := nPag + 1
	oPrn:EndPage()
	oPrn:StartPage()
	PCCabec()
	PCForn()
EndIf

oPrn:Line(nLin,ini,nLin,3100)

NextLine(1,.F.)

oPrn:Say(nLin,ini+0010,"Total das Mercadorias: " + Transform(nTotMerc,"@E 999,999,999.99") + "    IPI: " + Transform(nTotIpi,"@E 999,999,999.99") + "    Frete: " + Transform(nTotFrete,"@E 999,999,999.99") + "    Despesas: " + Transform(nTotDespe,"@E 999,999,999.99") + "    Seguro: " + Transform(nTotSegur,"@E 999,999,999.99") + "    Desconto: " + Transform(nTotDesc,"@E 999,999,999.99"),oFont10,100)
oPrn:Say(nLin,ini+2410,"Total Geral:" 							,oFont10n,100)
oPrn:Say(nLin,ini+2810,Transform(nTotGeral,"@E 999,999,999.99")	,oFont10n,100)

NextLine(1,.T.)

If nLin > nLinFim
	nPag := nPag + 1
	oPrn:EndPage()
	oPrn:StartPage()
	PCCabec()
	PCForn()
EndIf

//oPrn:Line(nLin,ini+0765,nLin+350,ini+0765)
//oPrn:Line(nLin,ini+1525,nLin+350,ini+1525)
//oPrn:Line(nLin,ini+2285,nLin+350,ini+2285)
oPrn:Line(nLin,ini+1525,nLin+350,ini+1525)

NextLine(1,.F.)

//oPrn:Say(nLin,ini+0020,"Solicitante"	,oFont10n,100)
//oPrn:Say(nLin,ini+0780,"Comprador"		,oFont10n,100)
//oPrn:Say(nLin,ini+1540,"Visto"			,oFont10n,100)
//oPrn:Say(nLin,ini+2300,"Aprovador"		,oFont10n,100)
oPrn:Say(nLin,ini+0020,"Comprador:"		,oFont10n,100)
//oPrn:Say(nLin,ini+2300,"Aprovador:"		,oFont10n,100)
oPrn:Say(nLin,ini+1540,"Aprovador:"		,oFont10n,100)

NextLine(1,.F.)
//oPrn:Say(nLin,ini+0020,SubStr(cPedSolic,1,35)		,oFont08,100)
//oPrn:Say(nLin,ini+0780,SubStr(cPedCompr,1,35)		,oFont08,100)
//oPrn:Say(nLin,ini+1540,SubStr(cPedVisto,1,35)		,oFont08,100)
//oPrn:Say(nLin,ini+2300,Upper(SubStr(cPedAprov,1,35)),oFont08,100)
oPrn:Say(nLin,ini+0020,SubStr(cPedCompr,1,35)		,oFont08,100)
//oPrn:Say(nLin,ini+2300,SubStr(cPedAprov,1,35)		,oFont08,100)
oPrn:Say(nLin,ini+1540,SubStr(cPedAprov,1,35)		,oFont08,100)
oPrn:Say(nLin+40,ini+1540,"Aprovado em: " + DTOC( MsDate() ) + " " + Time()		,oFont08,100)

If !Empty(cPedCompr)
	//oPrn:SayBitmap(nLin+10,ini+0780,cAssComp,560,193, , .T. )
	cAssComp := "ass_default.png"
	//oPrn:SayBitmap(nLin+10,ini+0020,cAssComp,560,193, , .T. )
	oPrn:SayBitmap(nLin+10,ini+0780,cAssComp,560,193, , .T. )
EndIF

If !Empty(cPedAprov)
	cAssAprv := "ass_default.png"
	oPrn:SayBitmap(nLin+10,ini+2300,cAssAprv,560,193, , .T. )
EndIf

NextLine(4,.F.)
NextLine(1,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Box - Obervações                   		 												³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nLin + 500 > nLinFim
	nPag := nPag + 1
	oPrn:EndPage()
	oPrn:StartPage()
	PCCabec()
	PCForn()
EndIf

NextLine(1,.F.)
oPrn:Say(nLin,ini+0020,"Observações"																																										,oFont12n,100)
NextLine(1,.f.)
oPrn:Say(nLin,ini+0020,"Não será permitido receber produtos não previsto neste documento e fora da tolerância."																								,oFont10,100)
NextLine(1,.f.)
oPrn:Say(nLin,ini+0020,"Somente aceitaremos a mercadoria se na sua Nota Fiscal constar o numero Pedido, Item, Lote, Dt.Fabric., Dt.Validade"																,oFont10,100)
NextLine(1,.f.)
oPrn:Say(nLin,ini+0020,"* Horario para entrega das 08:00 as 11:30 e 13:30 as 16:00 [Observação: Fornecimento de cargas a granel líquida deve ocorrer até às 12:00 horas]"									,oFont10,100)
NextLine(1,.f.)
oPrn:Say(nLin,ini+0020,"* Não aceitaremos mat. em desacordo com as qtds, qualidades e especif., todo mat. recebido no local de entrega, fica, ainda sujeito a aprovacao definitiva, podendo caso desacordo"	,oFont10,100)
NextLine(1,.f.)
oPrn:Say(nLin,ini+0020,"  com o pedido ser rejeitado e posto a disposicao do forn., correndo neste caso, por conta de risco deste todas as despesas disso decorrentes."										,oFont10,100)
NextLine(1,.f.)
oPrn:Say(nLin,ini+0020,"  Caso cancelado pelo forn. após aceite este resp. pelos danos."																													,oFont10,100)
NextLine(1,.f.)
oPrn:Say(nLin,ini+0020,"* Não serão aceitas e pagas, nenhum tipo de despesas, caso não esteja combinada e descrita no pedido de compras."																	,oFont10,100)
NextLine(1,.f.)
oPrn:Say(nLin,ini+0020,"* Não serão aceitos títulos negociados com terceiros."																																,oFont10,100)
NextLine(1,.f.)
oPrn:Say(nLin,ini+0020,"* Prezado Fornecedor: Ao emitir sua Nota Fiscal Eletrônica(NF-E )favor enviar a mesma via e-mail para sua respectiva filial de faturamento."										,oFont10,100)
NextLine(1,.t.)

Return

Static Function NextLine(nNumLin,lLinHor)

oPrn:Line(nLin,ini,nLin+( int * nNumLin ),ini)
oPrn:Line(nLin,ini+3050,nLin + ( int * nNumLin ),ini+3050)

nLin := nLin + ( int * nNumLin )

If lLinHor
	oPrn:Line(nLin,ini,nLin,ini+3050)
EndIf

Return

Static Function PCEmail()

Local aAreaSC7  := SC7->( GetArea() )
Local cSrvMail  := AllTrim(GetMV("MV_RELSERV"))
Local cUserAut  := AllTrim(GetMV("MV_RELACNT")) 
Local cPassAut  := AllTrim(GetMV("MV_RELPSW")) 
Local cAuthent	:= AllTrim(GetMV("MV_RELAUTH"))    
Local lOK       := .T.
Local aCabec	:= {}
Local aColunas	:= {}
Local cMensagem	:= "Abrir anexo."
Local cNomEmp   := IIf( AllTrim( cEmpAnt ) == "01", "QUALYCRIL", IIf( AllTrim( cEmpAnt ) == "02", "EUROAMERICAN", IIf( AllTrim( cEmpAnt ) == "03", "QUALYVINIL", "QUALYCRIL")))
Local cAssunto	:= cNomEmp + " - Pedido de Compras: " + AllTrim( cNumOP ) + " Aprovado"
Local cMailTo	:= GetMv( "MV_BE_PCEM",, "fabio@xisinformatica.com.br;rodrigo.ferreira@euroamerican.com.br" )
Local cDe		:= cUserAut
Local cPara		:= GetMv( "MV_BE_PCEM",, "fabio@xisinformatica.com.br;rodrigo.ferreira@euroamerican.com.br" )
Local cCc		:= ""
Local cCco		:= ""
Local cSubject  := cAssunto
Local cBody		:= cMensagem
Local cAnexo    := cPathDest + cRelName

dbSelectArea("SC7")
dbSetOrder(1)
dbSeek( xFilial("SC7") + cNumOP )

dbSelectArea("SA2")
dbSetOrder(1)
dbSeek( xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA )

cMensagem := ""

cMens1 := "</B><BR><BR><BR>Caro(a) " + AllTrim( SC7->C7_CONTATO ) + ",<BR><BR>"
cMens1 += "</B>À " + AllTrim( SA2->A2_NOME ) + "<BR><BR>"
cMens1 += "Nosso pedido de compras " + AllTrim( cNumOP ) + " foi aprovado para fornecimento conforme acordado em relacionamento no processo de cotação<BR><BR>"
cMens1 += "Maiores detalhes sobre produtos e serviços, data programada para entrega e condições para pagamentos visualizar no documento anexo.<BR><BR>"
cMens2 := "Faturar exclusivamente para os dados da empresa abaixo:<BR><BR>"
cMens2 += "<B>Razão Social:</B> " + AllTrim( SM0->M0_NOMECOM ) + "<BR>"
cMens2 += "<B>Endereço:</B> " + AllTrim( SM0->M0_ENDENT ) + "<BR>"
cMens2 += "<B>Bairro:</B> " + AllTrim( SM0->M0_BAIRENT ) + "<BR>"
cMens2 += "<B>Cidade:</B> " + AllTrim( SM0->M0_CIDENT ) + "<BR>"
cMens2 += "<B>UF:</B> " + AllTrim( SM0->M0_ESTENT ) + "<BR>"
cMens2 += "<B>CEP:</B> " + AllTrim( SM0->M0_CEPENT ) + "<BR>"
cMens2 += "<B>CNPJ:</B> " + AllTrim( SM0->M0_CGC ) + "<BR>"
cMens2 += "<B>Insc. Estadual:</B> " + AllTrim( SM0->M0_INSC ) + "<BR>"

aCabec := {}
aAdd( aCabec, {{'<B><Font Size=6 color=white>Pedido de Compras</Font></B>', '6', 100, 6, 'C'}})
aAdd( aCabec, {{'<B><Font Size=2 color=blue>' + cMens1 + '</Font></B>', '1', 100, 6, 'L'}})
aAdd( aCabec, {{'<B><Font Size=5 color=black>Número:</Font></B>', '2', 50, 3, 'L'}, {'<Font Size=5 color=green>' + AllTrim( cNumOP ) + '</Font>', '2', 50, 3, 'R'}})

aAdd( aCabec, {{'<B><Font Size=2 color=black></Font></B>', '1', 100, 6, 'L'}})

aAdd( aCabec, {{'<B><Font Size=3 color=black>Item</Font></B>', '1', 15, 0, 'C'}, {'<B><Font Size=3 color=black>Produto</Font></B>', '1', 50, 2, 'C'}, {'<B><Font Size=3 color=black>U.M.</Font></B>', '1', 05, 0, 'C'}, {'<B><Font Size=3 color=black>Quantidade</Font></B>', '1', 15, 0, 'C'}, {'<B><Font Size=3 color=black>Entrega</Font></B>', '1', 15, 0, 'C'}})

Do While !SC7->( Eof() ) .And. SC7->C7_NUM == cNumOP
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek( xFilial("SB1") + SC7->C7_PRODUTO )

	aAdd( aCabec, {{'<B><Font Size=2 color=green>' + SC7->C7_ITEM + '</Font></B>', '2', 15, 0, 'R'}, {'<Font Size=2 color=green><B>' + AllTrim( SB1->B1_COD ) + '</B> ' + AllTrim( SB1->B1_DESC ) + '</Font>', '2', 50, 2, 'C'}, {'<Font Size=2 color=green>' + AllTrim( SC7->C7_UM ) + '</Font>', '2', 05, 0, 'C'}, {'<Font Size=2 color=green>' + Transform( SC7->C7_QUANT, "@E 999,999,999.99") + '</Font>', '2', 15, 0, 'R'}, {'<Font Size=2 color=green>' + DTOC( SC7->C7_DATPRF ) + '</Font>', '2', 15, 0, 'R'}})

	SC7->( dbSkip() )
EndDo

aAdd( aCabec, {{'<B><Font Size=4 color=white>COMUNICADO RECEBIMENTO</Font></B>', '6', 100, 6, 'C'}})

aAdd( aCabec, {{'<B><Font Size=2 color=black></Font></B>', '1', 100, 6, 'L'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>' + cMens2 + '</Font></B>', '1', 100, 6, 'L'}})

If AllTrim( cEmpAnt ) == "02"
	cMensagem += U_BeHtmMod2( '', aColunas, .F., aCabec, "http://qualyvinil.com.br/assets/images/nav/logo_qv1.png", 50 )
Else
	cMensagem += U_BeHtmMod2( '', aColunas, .F., aCabec, "http://qualyvinil.com.br/assets/images/nav/logo_qv1.png", 50 )
EndIf

aColunas := {}
cMensagem += U_BeHtmDet( aColunas, .F., .F. )
cMensagem += U_BeHtmRod(.T.)

cBody := cMensagem

//+----------------------------------------------------------------------------
//| Define objeto de email
//+----------------------------------------------------------------------------
CONNECT SMTP SERVER cSrvMail ACCOUNT cUserAut PASSWORD cPassAut TIMEOUT 60 RESULT lOk

If (lOk)
	MAILAUTH(cUserAut, cPassAut)

	SEND MAIL FROM cDe TO cPara ;
	BCC cCco ;
	CC cCc ;
	SUBJECT cSubject ;
	BODY cBody ;  
	ATTACHMENT cAnexo;
	RESULT lOK
	DISCONNECT SMTP SERVER
EndIf

//U_BeSendMail( { cMailTo, cAssunto , cMensagem, "", "", cPathDest + cRelName } )
SC7->( RestArea( aAreaSC7 ) )

Return

Static Function fBuscaRev( _cPedido )

cRetorno := "001"

Return cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ValidPerg ³ Autor ³ Rodrigo Sousa  		³ Data ³ 15.08.12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Parametros da rotina.                					   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValidPerg()

Local aArea := GetArea()
Local aPerg := {}

cPerg := Padr(cPerg, 10)

aAdd(aPerg, {cPerg, "01", "Ordem Produção?" , "MV_CH1" , "C", 06	, 0	, "G"	, "MV_PAR01", "SC2"	,""		,""				,""				,"",""})

DbSelectArea("SX1")
DbSetOrder(1)

For i := 1 To Len(aPerg)
	IF  !DbSeek(aPerg[i,1]+aPerg[i,2])
		RecLock("SX1",.T.)
	Else
		RecLock("SX1",.F.)
	EndIF
	Replace X1_GRUPO   with aPerg[i,01]
	Replace X1_ORDEM   with aPerg[i,02]
	Replace X1_PERGUNT with aPerg[i,03]
	Replace X1_VARIAVL with aPerg[i,04]
	Replace X1_TIPO	   with aPerg[i,05]
	Replace X1_TAMANHO with aPerg[i,06]
	Replace X1_PRESEL  with aPerg[i,07]
	Replace X1_GSC	   with aPerg[i,08]
	Replace X1_VAR01   with aPerg[i,09]
	Replace X1_F3	   with aPerg[i,10]
	Replace X1_DEF01   with aPerg[i,11]
	Replace X1_DEF02   with aPerg[i,12]
	Replace X1_DEF03   with aPerg[i,13]
	Replace X1_DEF04   with aPerg[i,14]
	Replace X1_DEF05   with aPerg[i,15]
	MsUnlock()
Next i

RestArea(aArea)

Return(.T.)