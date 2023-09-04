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
±±³Funcao    ³ EQPedCom ³ Autor ³ Fabio F Sousa        ³ Data ³ 01/09/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatório de Pedido de Compras com Envio automático de     ³±±
±±³          ³ e-mail                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Euroamerican                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function EQPedCom( _cNumPC ) //U_EQPedCom( "013236" ) @

Local aArea         := GetArea()
Local aAreaSC7      := SC7->( GetArea() )
Local aAreaSCR      := SCR->( GetArea() )

Private oPrn 		:= Nil
Private oSetup		:= Nil
Private cNumPC      := ""
Private cQuery      := ""
Private cPathDest   := "\relato\"
Private cRelName    := "PC_" + AllTrim( _cNumPC ) + "_"  + DTOS( dDataBase ) + "_" + Replace( Time(), ":", "") + ".PDF"
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

Default _cNumPC     := ""

cNumPC := AllTrim( _cNumPC )

CarregaDados()

TCQuery cQuery New Alias "TMPCOM"
dbSelectArea("TMPCOM")
TMPCOM->( dbGoTop() )

If TMPCOM->( Eof() )
	lProc := .F.
EndIf

If lProc
	MsgRun("Enviando Pedido de Compras por E-mail. Aguarde.....", "Imprimindo", {|| RunImp() })
EndIf

TMPCOM->( dbCloseArea() )

SCR->( RestArea( aAreaSCR ) )
SC7->( RestArea( aAreaSC7 ) )
RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CarregaDados  ºAutor  ³Microsiga      º Data ³  08/31/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ Euroamerican                                               ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CarregaDados()

cQuery := "SELECT AK_NOME AS APROVADOR, ISNULL( Y1_NOME, '') AS COMPRADOR, ISNULL( C1_SOLICIT, '') SOLICITANTE, SC7.* " + CRLF
cQuery += "FROM " + RetSqlName("SC7") + " SC7 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SCR") + " AS SCR WITH (NOLOCK) ON CR_FILIAL = C7_FILIAL " + CRLF
cQuery += "  AND CR_TIPO = 'PC' " + CRLF
cQuery += "  AND CR_NUM = C7_NUM " + CRLF
cQuery += "  AND CR_STATUS = '03' " + CRLF
cQuery += "  AND CR_NIVEL IN (SELECT MAX( CR_NIVEL ) FROM " + RetSqlName("SCR") + " WITH (NOLOCK) WHERE CR_FILIAL = C7_FILIAL AND CR_NUM = C7_NUM AND CR_STATUS = '03' AND D_E_L_E_T_ = ' ' ) " + CRLF
cQuery += "  AND SCR.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SAK") + " AS SAK WITH (NOLOCK) ON AK_FILIAL = '" + xFilial("SAK") + "' " + CRLF
cQuery += "  AND AK_COD = CR_APROV " + CRLF
cQuery += "  AND AK_USER = CR_USERLIB " + CRLF
cQuery += "  AND SAK.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "LEFT JOIN " + RetSqlName("SY1") + " AS SY1 WITH (NOLOCK) ON Y1_FILIAL = '" + xFilial("SY1") + "' " + CRLF
cQuery += "  AND Y1_USER = C7_USER " + CRLF
cQuery += "  AND SY1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "LEFT JOIN " + RetSqlName("SC1") + " AS SC1 WITH (NOLOCK) ON C1_FILIAL = C7_FILIAL " + CRLF
cQuery += "  AND C1_NUM =  C7_NUMSC " + CRLF
cQuery += "  AND C1_ITEM = C7_ITEMSC " + CRLF
cQuery += "  AND SC1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE C7_FILIAL = '" + xFilial("SC7") + "' " + CRLF
cQuery += "AND C7_NUM = '" + cNumPC + "' " + CRLF
cQuery += "AND SC7.D_E_L_E_T_ = ' ' " + CRLF

Return cQuery

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RunImp ºAutor  ³Microsiga             º Data ³  08/31/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ Euroamerican                                               ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RunImp()

// Define Variaveis de Objeto
oFont06  := TFont():New( "Courier New",, 10,,.F.)
oFont08  := TFont():New( "Arial",, 10,,.F.)
oFont08n := TFont():New( "Arial",, 10,,.T.)
oFont10  := TFont():New( "Arial",, 12,,.F.)
oFont10n := TFont():New( "Arial",, 12,,.T.)
oFont12  := TFont():New( "Arial",, 14,,.F.)
oFont12n := TFont():New( "Arial",, 14,,.T.)
oFont13  := TFont():New( "Arial",, 15,,.F.)
oFont13n := TFont():New( "Arial",, 15,,.T.)
oFont14  := TFont():New( "Arial",, 16,,.F.)
oFont14n := TFont():New( "Arial",, 16,,.T.)
oFontCAc := TFont():New( "Courier New",, 20,,.F.)
oFontCAn := TFont():New( "Courier New",, 20,,.T.)

oPrn := FwMsPrinter():New(cRelName,IMP_PDF,.T.,cPathDest,.T.,.F.,@oPrn,,,.F.,.F.,.F.,)
oPrn:SetResolution(75)
oPrn:SetLandscape() 			//SetPortrait()
oPrn:SetPaperSize(DMPAPER_A4)
oPrn:SetMargin(00,00,00,00)		//nEsquerda, nSuperior, nDireita, nInferior
oPrn:cPathPDF := cPathDest		//Caso seja utilizada impressão em IMP_PDF

oPrn:StartPage()

PCCabec()
PCForn()
PCForPag()
PCCabIt()
PCItem()
PCTotal()

oPrn:EndPage()
oPrn:Print()

If File( AllTrim( cPathDest ) + AllTrim( cRelName ) )
	PCEmail()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCCabec ºAutor  ³Microsiga            º Data ³  08/31/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ Euroamerican                                               ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PCCabec()

Local cPCLogo := ""

If Left(cFilAnt,2) == "02"
	cPCLogo := "logoeuro.bmp"
Else
	Left(cFilAnt,2) := "logoqualy.bmp"
EndIf

nLin    := 50

oPrn:Line(nLin,ini,nLin,3100)
oPrn:SayBitmap(75,ini+20,cPCLogo,560,193, , .T. )

//NextLine(2,.f.)
//oPrn:Say(nLin-10,ini+2600,"Data:",oFont10n,100)
//oPrn:Say(nLin-10,ini+2740, dtoc(MsDate())	,oFont10,100)

cRevisao := fBuscaRev( TMPCOM->C7_NUM )

NextLine(1,.f.)
oPrn:Say(nLin-10,ini+2600,"Revisão:",oFont10n,100)
oPrn:Say(nLin-10,ini+2740, cRevisao	,oFont10n,100)

NextLine(1,.f.)
oPrn:Say(nLin-10,ini+2600,"Data:",oFont10n,100)
oPrn:Say(nLin-10,ini+2740, dtoc(MsDate())	,oFont10,100)

NextLine(1,.f.)
oPrn:Say(nLin-10,ini+1200+nCenter,"PEDIDO DE COMPRAS No. "+TMPCOM->C7_NUM ,oFont14n,100)
oPrn:Say(nLin-10,ini+2600,"Hora:",oFont10n,100)
oPrn:Say(nLin-10,ini+2740, Time()	,oFont10,100)

NextLine(1,.f.)
oPrn:Say(nLin-10,ini+2600,"Página:",oFont10n,100)
oPrn:Say(nLin-10,ini+2740, cValtoChar(nPag)	,oFont10,100)

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

NextLine(1,.f.)
oPrn:Say(nLin-10,ini+2600,"Média USD: " + AllTrim( Transform( nMedDol, "@E 9,999.999999") ),oFont10n,100)
oPrn:Say(nLin-10,ini+2740, cValtoChar(nPag)	,oFont10,100)

NextLine(1,.T.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCForn ºAutor  ³Microsiga             º Data ³  08/31/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ Euroamerican                                               ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PCForn()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Box 1 - Dados Fornecedor e Filial                    									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrn:Line(nLin,ini+1525,nLin+300,ini+1525) // Linha Vertical     180

dbSelectArea("SA2")
dbSeek(xFilial()+TMPCOM->C7_FORNECE+TMPCOM->C7_LOJA)

NextLine(1,.f.)

oPrn:Say(nLin+10,ini+0020,Capital(SM0->M0_NOMECOM),oFont12,100)  // Nome da Filial
oPrn:Say(nLin+10,ini+1540,Capital(AllTrim(SA2->A2_NOME))+" - Cnpj: "+Transform(SA2->A2_CGC,"@R 99.999.999/9999-99"),oFont12,100)  // Nome+CNPJ Fornecedor

NextLine(1,.f.)

oPrn:Say(nLin+10,ini+0020,Capital(AllTrim(SM0->M0_ENDENT))+" - "+Capital(AllTrim(SM0->M0_BAIRENT)),oFont12,100)  // End Entrega da Filial
oPrn:Say(nLin+10,ini+1540,"End.: "+Capital(AllTrim(SA2->A2_END))+" - "+Capital(AllTrim(SA2->A2_BAIRRO)),oFont12,100)  // End Fornecedor

NextLine(1,.f.)

oPrn:Say(nLin+10,ini+0020,"CEP: "+Trans(SM0->M0_CEPENT,"@R 99999-999")+" - "+Capital(AllTrim(SM0->M0_CIDENT))+" - "+SM0->M0_ESTENT,oFont12,100)
oPrn:Say(nLin+10,ini+1540,Capital(AllTrim(SA2->A2_MUN))+" - "+AllTrim(SA2->A2_EST)+" - Cep: "+Transform(SA2->A2_CEP,"@R 99999-999")+" - I.E.: "+AllTrim(SA2->A2_INSCR),oFont12,100)

NextLine(1,.f.)

oPrn:Say(nLin+10,ini+0020,"TEL/FAX: "+SM0->M0_TEL,oFont12,100)
oPrn:Say(nLin+10,ini+1540,"Contato: "+Capital(AllTrim(TMPCOM->C7_CONTATO)) + " - Fone: "+AllTrim(SA2->A2_TEL)+" - Fax: "+AllTrim(SA2->A2_FAX),oFont12,100)

NextLine(1,.f.)

dbSelectArea("SA6")
dbSeek(xFilial("SA6")+SA2->A2_BANCO)

oPrn:Say(nLin+10,ini+0020,"CGC: "+ transform(SM0->M0_CGC,"@R 99.999.999/9999-99")+" IE: "+ SM0->M0_INSC,oFont12,100)
oPrn:Say(nLin+10,ini+1540,"Banco: "+SA2->A2_BANCO+" "+AllTrim(SA6->A6_NREDUZ)+" Agência "+SA2->A2_AGENCIA+" Conta "+SA2->A2_NUMCON,oFont12,100)

NextLine(1,.T.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCForPag ºAutor  ³Microsiga           º Data ³  08/31/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ Euroamerican                                               ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PCForPag()

nTotDesc	:= 0

dbSelectArea("TMPCOM")
TMPCOM->( dbGoTop() )

While !TMPCOM->(Eof())
	nTotDesc  	+= TMPCOM->C7_VLDESC
	TMPCOM->(dbSkip())
EndDo

TMPCOM->(dbGoTop())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Box 2 - Forma de Pagamento / Descontos													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
NextLine(1,.F.)
oPrn:Say(nLin-10,ini+0020,"Forma de Pagamentos "																,oFont10n,100)
oPrn:Say(nLin-10,ini+0500,TMPCOM->C7_COND+" - "+(Posicione("SE4",1,xFilial("SE4")+TMPCOM->C7_COND,"E4_DESCRI"))	,oFont10,100)

//AllTrim( Str( SC5->C5_MOEDA ) ) + " - " + 
oPrn:Say(nLin-10,ini+1540,"Moeda "																,oFont10n,100)
oPrn:Say(nLin-10,ini+1900,AllTrim( Str( TMPCOM->C7_MOEDA ) ) + " - " + Alltrim( SuperGetMv( "MV_MOEDA" + AllTrim( Str( TMPCOM->C7_MOEDA, 2) ) ) ) + " Taxa: " + AllTrim(Transform(TMPCOM->C7_TXMOEDA,"@E 9,999.999999")),oFont10,100)

NextLine(1,.T.)
oPrn:Say(nLin-10,ini+0020,"Descontos "																						,oFont10n,100)
oPrn:Say(nLin-10,ini+0500,AllTrim(Transform(TMPCOM->C7_DESC1,"@E 99.99"))+"%"													,oFont10,100)
oPrn:Say(nLin-10,ini+0800,AllTrim(Transform(TMPCOM->C7_DESC2,"@E 99.99"))+"%"													,oFont10,100)
oPrn:Say(nLin-10,ini+1100,AllTrim(Transform(TMPCOM->C7_DESC3,"@E 99.99"))+"%"													,oFont10,100)
oPrn:Say(nLin-10,ini+1400,Transform(IIF(TMPCOM->C7_DESC1+TMPCOM->C7_DESC2+TMPCOM->C7_DESC3 > 0 ,nTotDesc, 0),"@E 999,999,999.99")	,oFont10,100)
oPrn:Say(nLin-10,ini+1900,Transform(nTotDesc,"@E 999,999,999.9999")															,oFont10,100)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCCabIt ºAutor  ³Microsiga            º Data ³  08/31/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ Euroamerican                                               ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PCCabIt()

NextLine(1,.T.)

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

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCItem ºAutor  ³Microsiga             º Data ³  08/31/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ Euroamerican                                               ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

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

	If nLin > nLinFimIt
		nPag := nPag + 1
		NextLine(1,.t.)
		oPrn:EndPage()
		oPrn:StartPage()
		PCCabec()
		PCForn()
		PCCabIt()
	EndIf

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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCTotal ºAutor  ³Microsiga            º Data ³  08/31/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ Euroamerican                                               ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ NextLine ºAutor  ³Microsiga           º Data ³  08/31/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ Euroamerican                                               ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function NextLine(nNumLin,lLinHor)

oPrn:Line(nLin,ini,nLin+( int * nNumLin ),ini)
oPrn:Line(nLin,ini+3050,nLin + ( int * nNumLin ),ini+3050)

nLin := nLin + ( int * nNumLin )

If lLinHor
	oPrn:Line(nLin,ini,nLin,ini+3050)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCEmail ºAutor  ³Microsiga            º Data ³  08/31/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ Euroamerican                                               ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

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
Local cNomEmp   := IIf( Left(cFilAnt,2) == "01", "QUALYCRIL", IIf( Left(cFilAnt,2) == "02", "EUROAMERICAN", IIf( Left(cFilAnt,2) == "03", "QUALYVINIL", "QUALYCRIL")))
Local cAssunto	:= cNomEmp + " - Pedido de Compras: " + AllTrim( cNumPC ) + " Aprovado"
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
dbSeek( xFilial("SC7") + cNumPC )

dbSelectArea("SA2")
dbSetOrder(1)
dbSeek( xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA )

cMensagem := ""

cMens1 := "</B><BR><BR><BR>Caro(a) " + AllTrim( SC7->C7_CONTATO ) + ",<BR><BR>"
cMens1 += "</B>À " + AllTrim( SA2->A2_NOME ) + "<BR><BR>"
cMens1 += "Nosso pedido de compras " + AllTrim( cNumPC ) + " foi aprovado para fornecimento conforme acordado em relacionamento no processo de cotação<BR><BR>"
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
aAdd( aCabec, {{'<B><Font Size=5 color=black>Número:</Font></B>', '2', 50, 3, 'L'}, {'<Font Size=5 color=green>' + AllTrim( cNumPC ) + '</Font>', '2', 50, 3, 'R'}})

aAdd( aCabec, {{'<B><Font Size=2 color=black></Font></B>', '1', 100, 6, 'L'}})

aAdd( aCabec, {{'<B><Font Size=3 color=black>Item</Font></B>', '1', 15, 0, 'C'}, {'<B><Font Size=3 color=black>Produto</Font></B>', '1', 50, 2, 'C'}, {'<B><Font Size=3 color=black>U.M.</Font></B>', '1', 05, 0, 'C'}, {'<B><Font Size=3 color=black>Quantidade</Font></B>', '1', 15, 0, 'C'}, {'<B><Font Size=3 color=black>Entrega</Font></B>', '1', 15, 0, 'C'}})

Do While !SC7->( Eof() ) .And. SC7->C7_NUM == cNumPC
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek( xFilial("SB1") + SC7->C7_PRODUTO )

	aAdd( aCabec, {{'<B><Font Size=2 color=green>' + SC7->C7_ITEM + '</Font></B>', '2', 15, 0, 'R'}, {'<Font Size=2 color=green><B>' + AllTrim( SB1->B1_COD ) + '</B> ' + AllTrim( SB1->B1_DESC ) + '</Font>', '2', 50, 2, 'C'}, {'<Font Size=2 color=green>' + AllTrim( SC7->C7_UM ) + '</Font>', '2', 05, 0, 'C'}, {'<Font Size=2 color=green>' + Transform( SC7->C7_QUANT, "@E 999,999,999.99") + '</Font>', '2', 15, 0, 'R'}, {'<Font Size=2 color=green>' + DTOC( SC7->C7_DATPRF ) + '</Font>', '2', 15, 0, 'R'}})

	SC7->( dbSkip() )
EndDo

aAdd( aCabec, {{'<B><Font Size=4 color=white>COMUNICADO RECEBIMENTO</Font></B>', '6', 100, 6, 'C'}})

aAdd( aCabec, {{'<B><Font Size=2 color=black></Font></B>', '1', 100, 6, 'L'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>' + cMens2 + '</Font></B>', '1', 100, 6, 'L'}})

If Left(cFilAnt,2) == "02"
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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fBuscaRev ºAutor  ³Microsiga          º Data ³  08/31/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ Euroamerican                                               ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fBuscaRev( _cPedido )

cRetorno := "001"

cQuery := "SELECT CR_NUM, CR_NIVEL, COUNT(*) AS CONTA " + CRLF
cQuery += "FROM " + RetSqlName("SCR") + " AS SCR WITH (NOLOCK) " + CRLF
cQuery += "WHERE CR_FILIAL = '" + xFilial("SC7") + "' " + CRLF
cQuery += "AND CR_NUM = '" + AllTrim( _cPedido ) + "' " + CRLF
cQuery += "AND CR_TIPO = 'PC' " + CRLF
cQuery += "AND CR_STATUS = '03' " + CRLF
cQuery += "GROUP BY CR_NUM, CR_NIVEL " + CRLF
cQuery += "ORDER BY COUNT(*) DESC " + CRLF

TCQuery cQuery New Alias "REVIS"
dbSelectArea("REVIS")
dbGoTop()

If !REVIS->( Eof() )
	If REVIS->CONTA > 1
		cRetorno := StrZero( REVIS->CONTA, 3)
	EndIf
EndIf

REVIS->( dbCloseArea() )

Return cRetorno