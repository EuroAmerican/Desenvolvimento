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

#DEFINE	 REL_NAME	"Ordem de Separação"
#DEFINE  REL_PATH	"C:\"

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
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³BeROrdSep ³ Autor ³ Rodrigo Sousa         ³ Data ³ 02/06/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ³±±
±±³Descri‡…o ³ Impressão da Ordem de Separação							  ³±±
±±³          ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Beraca						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BeROrdSep()

Local nY			:= 0

Private oPrn 		:= Nil
Private oSetup		:= Nil
Private oFont07,oFont07n,oFont08,oFont08n,oFont09,oFont09n,oFont10,oFont10n,oFont12,oFont12n,oFont14,oFont14n

Private cPerg		:= "ACD100"	

If !Pergunte(cPerg, .T.)
	ApMsgInfo('Relatório Cancelado!', 'Beraca')
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

Local nX	:= 0
Local lRet 	:= .T.

DEFAULT cPathDest   := REL_PATH
DEFAULT cRelName	:= REL_NAME

cRelName := "OrdSep_"+MV_PAR01+MV_PAR02

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
oFont10  := TFont():New( "Arial",, 10,,.F.)
oFont12n := TFont():New( "Arial",, 12,,.T.)
oFont12  := TFont():New( "Arial",, 12,,.F.)
oFont14n := TFont():New( "Arial",, 14,,.T.)
oFont14  := TFont():New( "Arial",, 14,,.F.)

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
oSetup := FWPrintSetup():New(PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION+PD_DISABLEDESTINATION+PD_DISABLEPAPERSIZE+PD_DISABLEPREVIEW ,"Invoice")
oSetup:SetUserParms({|| Pergunte(cPerg, .T.)})
oSetup:SetProperty(PD_MARGIN,{05,05,05,05})
oSetup:SetProperty(PD_DESTINATION,2) 
//oSetup:SetProperty(PD_PRINTTYPE,IMP_PDF)


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

SetRegua(RecCount()-Recno())

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
	ApMsgInfo('Não há dados!', 'Beraca')
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

Local cOrdSep 	:= Alltrim(CB7->CB7_ORDSEP)
Local cPedido 	:= Alltrim(CB7->CB7_PEDIDO)
Local cCliente	:= Alltrim(CB7->CB7_CLIENT)
Local cLoja   	:= Alltrim(CB7->CB7_LOJA	)
Local cNota   	:= Alltrim(CB7->CB7_NOTA)
Local cSerie  	:= Alltrim(CB7->CB7_SERIE)
Local cOP     	:= Alltrim(CB7->CB7_OP)
Local cStatus 	:= RetStatus(CB7->CB7_STATUS)
Local cAliasCF	:= ""

Local aDadosCli	:= Array(11)

Local nPixLin	:= NMINLIN
Local nPixCol	:= NMINCOL                  
Local nPage		:= 1                        

Local lSaida	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Cabeçalho da Ordem de Separação						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPixLin			:= CabPrint(nPage)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Ordem de Separação com Origem do Pedido de Venda  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CB7->CB7_ORIGEM == "1"  

	dbSelectArea("SC5")
	dbSetOrder(1)
	dbSeek(CB7->CB7_FILIAL+cPedido)

	lSaida	:= .T.

	oPrn:Say(nPixLin+=10,nPixCol+005,"Pedido de Venda: "+cPedido+" "+DtoC(SC5->C5_EMISSAO)+" - "+SC5->C5_EMISHR+Iif(!Empty(cNota)," Nota Fiscal: "+cNota+"-"+cSerie,"")+" - Status: "+cStatus,oFont07,,)
	oPrn:Line(nPixLin+=08,NMINCOL,nPixLin,NMAXCOL)
	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Ordem de Separação com Origem da Nota Fiscal de Saida  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Elseif CB7->CB7_ORIGEM == "2" 

	dbSelectArea("SC5")
	dbOrderNickName("BESC5NF")
	dbSeek(CB7->CB7_FILIAL+cNota+cSerie)

	lSaida	:= .T.

	oPrn:Say(nPixLin+=08,nPixCol+005,"Nota Fiscal: "+cNota+"-"+cSerie+Iif(!Empty(cPedido)," Pedido: "+cPedido,"")+" Status: "+cStatus,oFont07,,)
	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Ordem de Separação com Origem da Ordem de Produção	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Elseif CB7->CB7_ORIGEM == "3" // Ordem de Producao

	oPrn:Say(nPixLin+=08,nPixCol+005,"Ordem de Produção: "+cOP+" Status: "+cStatus,oFont07,,)
	oPrn:Line(nPixLin+=08,NMINCOL,nPixLin,NMAXCOL)

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Itens da Nota Fiscal de Saida ou Pedido de Venda	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lSaida

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
    EndIf
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona tabelas											   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SA4")
	DbSetOrder(1)
	Dbseek(xFilial("SA4")+SC5->C5_TRANSP)

	DbSelectArea("SA3")
	dbSetOrder(1)
	Dbseek(xFilial("SA3")+SC5->C5_VEND1)

	DbSelectArea("SE4")
	dbSetOrder(1)
	Dbseek(xFilial("SE4")+SC5->C5_CONDPAG)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Quadro Dados do Cliente e Dados do Pedido			   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrn:Line(nPixLin,nPixCol+400,nPixLin+42,nPixCol+400)
	oPrn:Say(nPixLin+=10,nPixCol+005,"DADOS DO CLIENTE",oFont07n,,)
	oPrn:Say(nPixLin,nPixCol+405,"DADOS DO PEDIDO",oFont07n,,)

	oPrn:Say(nPixLin+=008	,nPixCol+005	,"Cliente: "+Left(aDadosCli[XCOD]+"/"+aDadosCli[XLOJA]+" - "+Alltrim(aDadosCli[XNOME]),94),oFont07,,)
	oPrn:Say(nPixLin		,nPixCol+405	,"Vendedor(a): "+SA3->A3_COD+" - "+Alltrim(SA3->A3_NOME),oFont07,,)
	oPrn:Say(nPixLin		,nPixCol+650	,"Cond. Pagto.: "+SE4->E4_CODIGO+"  -  "+SE4->E4_DESCRI,oFont07,,)

	oPrn:Say(nPixLin+=008	,nPixCol+005	,"Endereço: "+Alltrim(aDadosCli[XEND])+" - "+Alltrim(aDadosCli[XBAIR])+" - "+Alltrim(aDadosCli[XMUN])+" - "+Alltrim(aDadosCli[XEST]),oFont07,,)
	oPrn:Say(nPixLin		,nPixCol+405	,"Transp.: "+Left(SA4->A4_COD+" - "+Alltrim(SA4->A4_NOME),41)+" Tel.: "+Alltrim(SA4->A4_TEL),oFont07,,)
	oPrn:Say(nPixLin		,nPixCol+650	,"Frete: "+Iif( SC5->C5_TPFRETE == "C","CIF","FOB"),oFont07,,)

	oPrn:Say(nPixLin+=008	,nPixCol+005	,"CEP: "+Alltrim(aDadosCli[XCEP])+" - CNPJ/CPF: "+Alltrim(aDadosCli[XCGC])+" - I.E. "+Alltrim(aDadosCli[XINSCR]),oFont07,,)

	If !Empty(SC5->C5_REDESP)
		DbSelectArea("SA4")
		DbSetOrder(1)
		If Dbseek(xFilial("SA4")+SC5->C5_REDESP)
			oPrn:Say(nPixLin		,nPixCol+405	,"Redesp.: "+Left(SA4->A4_COD+" - "+Alltrim(SA4->A4_NOME),41)+" Tel.: "+Alltrim(SA4->A4_TEL),oFont07,,)
			oPrn:Say(nPixLin		,nPixCol+650	,"Tipo: "+Iif( SC5->C5_BETPRED == "C","CIF","FOB"),oFont07,,)
		EndIf	

    EndIf

	oPrn:Line(nPixLin+=08,NMINCOL,nPixLin,NMAXCOL)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Cabeçalho dos Itens da Ordem de Separação			   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPixLin := CabPrIt(nPixLin,nPixCol)

	CB8->(DbSetOrder(1))
	CB8->(DbSeek(xFilial("CB8")+cOrdSep))

	While ! CB8->(EOF()) .and. (CB8->CB8_FILIAL+CB8->CB8_ORDSEP == xFilial("CB8")+cOrdSep)

		If nPixLin > 550 
			oPrn:EndPage()
			nPage += 1
			nPixLin	:= CabPrint(nPage)
			nPixLin := CabPrIt(nPixLin,nPixCol)
        EndIf
        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Itens da Nota Fiscal de Saida ou Pedido de Venda	   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xFilial("SC6")+CB8->CB8_PEDIDO+CB8->CB8_ITEM+CB8->CB8_PROD)

		dbSelectArea("SB8")
		dbsetorder(3)
		dbSeek(xFilial("SB8")+CB8->CB8_PROD+CB8->CB8_LOCAL+CB8->CB8_LOTECT)

		oPrn:Say(nPixLin+=008	,nPixCol+005	,CB8->CB8_PROD												,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+080	,SUBSTR(SC6->C6_DESCRI,1,30)								,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+230	,SC6->C6_UM													,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+260	,CB8->CB8_LOCAL												,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+290	,CB8->CB8_LCALIZ											,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+350	,CB8->CB8_LOTECT											,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+420	,DtoC(SB8->B8_DFABRIC)										,oFont07,,) //B8_DTFABRI
		oPrn:Say(nPixLin		,nPixCol+470	,DtoC(SB8->B8_DTVALID)										,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+520	,DtoC(SC6->C6_ENTREG)										,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+570	,Alltrim(Transform(CB8->CB8_QTDORI,"@E 999,999,999.99"))	,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+650	,Alltrim(Transform(CB8->CB8_SALDOS,"@E 999,999,999.99"))	,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+720	,Alltrim(Transform(CB8->CB8_SALDOE,"@E 999,999,999.99"))	,oFont07,,)

    	CB8->(dbSkip())
	EndDo


	If nPixLin > 330
		oPrn:EndPage()
		nPage += 1
		nPixLin	:= CabPrint(nPage)
    EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Termo de Responsabilidade	   						   ³
	//³ Linha 340 - Fixa					   						   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPixLin := 340
	
	oPrn:Say(nPixLin		,nPixCol+350	,"TERMO DE RESPONSABILIDADE"			,oFont09,,)
	oPrn:Say(nPixLin+=010	,nPixCol+220	,"Declaro que as mercadorias carregadas em meu veiculo, conferem com o que consta na nota fiscal e nao apresentam"	,oFont09,,)
	oPrn:Say(nPixLin+=010	,nPixCol+235	,"nenhum tipo de avaria na embalagem do produto que possa comprometer a qualidade e a entrega no cliente."			,oFont09,,)
	oPrn:Say(nPixLin+=020	,nPixCol+190	,"Coleta n. ____________________  Nota Fiscal: ____________________  Data ______ / ______ / ______  Placa do Veiculo: ____________________"			,oFont09,,)
	oPrn:Say(nPixLin+=020	,nPixCol+190	,"Nome do Motorista (legivel): __________________________________________________________  RG: ___________________________________"			,oFont09,,)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Quadro de Informações Complementeres do Pedido de Venda	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrn:Line(nPixLin+=10,NMINCOL,nPixLin,NMAXCOL)
	oPrn:Say(nPixLin+=10,nPixCol+005,"INFORMAÇÕES COMPLEMENTARES",oFont09n,,)


	oPrn:Say(nPixLin+=15,nPixCol+005,"Peso Bruto: "+Alltrim(Str(SC5->C5_PBRUTO)),oFont09,,)
	oPrn:Say(nPixLin,nPixCol+405,"Qtd. "	+Iif(SC5->C5_VOLUME1 > 0," Vol 1.: "+Alltrim(Str(SC5->C5_VOLUME1)),"");
											+Iif(SC5->C5_VOLUME2 > 0," Vol 2.: "+Alltrim(Str(SC5->C5_VOLUME2)),"");
											+Iif(SC5->C5_VOLUME3 > 0," Vol 3.: "+Alltrim(Str(SC5->C5_VOLUME3)),"");
											+Iif(SC5->C5_VOLUME4 > 0," Vol 4.: "+Alltrim(Str(SC5->C5_VOLUME4)),""),oFont09,,)


	oPrn:Say(nPixLin+=10,nPixCol+005,"Peso Liq.: "+Alltrim(Str(SC5->C5_PESOL)),oFont09,,)
	oPrn:Say(nPixLin	,nPixCol+405,"Tipo "+Iif(!Empty(SC5->C5_ESPECI1)," Vol 1.: "+Alltrim(SC5->C5_ESPECI1),"");
											+Iif(!Empty(SC5->C5_ESPECI2)," Vol 2.: "+Alltrim(SC5->C5_ESPECI2),"");
											+Iif(!Empty(SC5->C5_ESPECI3)," Vol 3.: "+Alltrim(SC5->C5_ESPECI3),"");
											+Iif(!Empty(SC5->C5_ESPECI4)," Vol 4.: "+Alltrim(SC5->C5_ESPECI4),""),oFont09,,)

	oPrn:Say(nPixLin+=20,nPixCol+005,	"Separado por: ____________________________ ";
										+"Conferido por: __________________________ ";
										+"Data ______ /______ /______ ",oFont09,,)

	oPrn:Say(nPixLin+=10,nPixCol+005,"Mensagem para N.F. 1: "+AllTrim(SC5->C5_MENNOTA)	,oFont09,,)
	oPrn:Say(nPixLin+=10,nPixCol+005,"Mensagem para N.F. 2: "+AllTrim(SC5->C5_SAMENF1)	,oFont09,,)
	oPrn:Say(nPixLin+=10,nPixCol+005,"Mensagem para Pré-Nota: "+Alltrim(SC5->C5_MENPRE)	,oFont09,,)
	oPrn:Say(nPixLin+=10,nPixCol+005,"Mensagem Padrão: "+Iif(!Empty(SC5->C5_MENPAD),SC5->C5_MENPAD+" - "+Alltrim(FORMULA(SC5->C5_MENPAD)),""),oFont09,,)
	oPrn:Say(nPixLin+=10,nPixCol+005,"Mensagem Onu: "+Iif(!Empty(SC5->C5_MENPAD2),SC5->C5_MENPAD2+" - "+Alltrim(FORMULA(SC5->C5_MENPAD2)),""),oFont09,,)
		
	If !Empty(SC5->C5_CODENTR+SC5->C5_LOJENTR)
		DbSelectArea("SA1")
		DbSetOrder(1)                                             
		DbSeek(xFilial("SA1")+SC5->C5_CODENTR+SC5->C5_LOJENTR)	

		oPrn:Say(nPixLin+=15,nPixCol+005,"Cod.Cliente Entrega: " 	+SC5->C5_CODENTR + "/" + SC5->C5_LOJENTR,oFont09,,)
		oPrn:Say(nPixLin+=10,nPixCol+005,"Informações de Entrega: "	+ALLTRIM(SA1->A1_NOME) 	+ " ";
																	+ALLTRIM(SA1->A1_END) 	+ " ";
																	+ALLTRIM(SA1->A1_MUN) 	+ "/";
																	+ALLTRIM(SA1->A1_EST),oFont09,,)
    EndIf
    
    If !Empty(SC5->C5_NFENTRE)
		oPrn:Say(nPixLin+=10,nPixCol+005,"N.F. Referente: " + SC5->C5_NFENTRE + "    - Dt. N.F. Referente : " + DTOC(SC5->C5_DTENTRE),oFont09,,)
	EndIf	

	oPrn:Say(570,nPixCol+005,"ATENÇÃO, VERIFICAR AS CONDIÇÕES FÍSICAS DO CAMINHÃO(LIMPEZA, PNEUS, EPI's, ETC.). VISTO: _______________________________ Data: ______/_____/_____",oFont09,,)

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Cabeçalho dos Itens da Ordem de Separação			   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPixLin := CabPrIt(nPixLin,nPixCol)

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
	
		oPrn:Say(nPixLin+=10,nPixCol+050,"Operação: " + TMPROT->G2_OPERAC,oFont08)
		oPrn:DataMatrix(nPixCol+050, nPixLin+56, TMPROT->G2_OPERAC , 55 )
		oPrn:Say(nPixLin    ,nPixCol+430,"Recurso: " + TMPROT->G2_RECURSO,oFont08)
		oPrn:DataMatrix(nPixCol+430, nPixLin+56, TMPROT->G2_RECURSO, 55 )
	
		oPrn:Line(nPixLin+=65,nPixCol,nPixLin,NMAXCOL)
	
		TMPROT->( dbSkip() )
	EndDo
	
	TMPROT->( dbCloseArea() )
	
	oPrn:Line(nPixLin+=10,nPixCol,nPixLin,NMAXCOL)
	
	oPrn:Say(nLin+=10,nPixCol+050,"INICIAR PRODUÇÃO",oFont08)
	oPrn:DataMatrix(nCol+050, nPixLin+56, "01" , 55 )
	oPrn:Say(nLin    ,nPixCol+430,"FINALIZAR PRODUÇÃO",oFont08)
	oPrn:DataMatrix(nCol+430, nPixLin+56, "04", 55 )
	
	CB8->(DbSetOrder(1))
	CB8->(DbSeek(xFilial("CB8")+cOrdSep))

	While ! CB8->(EOF()) .and. (CB8->CB8_FILIAL+CB8->CB8_ORDSEP == xFilial("CB8")+cOrdSep)

		If nPixLin > 550 
			oPrn:EndPage()
			nPage += 1
			nPixLin	:= CabPrint(nPage)
			nPixLin := CabPrIt(nPixLin,nPixCol)
        EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Itens da Nota Fiscal de Saida ou Pedido de Venda	   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SC2")
		dbSetOrder(1)
		dbSeek(xFilial("SC2")+cOP)

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+CB8->CB8_PROD)

		oPrn:Say(nPixLin+=008	,nPixCol+005	,CB8->CB8_PROD												,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+080	,SUBSTR(SB1->B1_DESC,1,30)									,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+230	,SC2->C2_UM													,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+260	,CB8->CB8_LOCAL												,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+290	,CB8->CB8_LCALIZ											,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+350	,CB8->CB8_LOTECT											,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+420	,DtoC(SC2->C2_EMISSAO)										,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+470	,DtoC(SC2->C2_XDTVALI)										,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+520	,DtoC(SC2->C2_DATPRF)										,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+570	,Alltrim(Transform(CB8->CB8_QTDORI,"@E 999,999,999.99"))	,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+650	,Alltrim(Transform(CB8->CB8_SALDOS,"@E 999,999,999.99"))	,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+720	,Alltrim(Transform(CB8->CB8_SALDOE,"@E 999,999,999.99"))	,oFont07,,)

    	CB8->(dbSkip())
	EndDo

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

Local cLogo		:= "logo_beraca.bmp" 
Local cPedCli	:= ""

DEFAULT nPage	:= 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa a pagina    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrn:StartPage()	

oPrn:Box(nLin,nCol,NMAXLIN,NMAXCOL)

oPrn:SayBitmap(nLin+=15,nCol+10,cLogo,145,35)	
oPrn:Say(nLin+=15,nCol+150,PadC("O R D E M  D E  S E P A R A Ç Ã O",150),oFont14n)
oPrn:Say(nLin+=15,nCol+390,Alltrim(CB7->CB7_ORDSEP),oFont10n)

oPrn:DataMatrix(760,090,Alltrim(CB7->CB7_ORDSEP), 60 )

oPrn:Line(nLin+=15,nCol,90,NMAXCOL)

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

oPrn:Say(nLin+=08,nCol+005,"DADOS DOS PRODUTOS",oFont07n,,)

oPrn:Say(nLin+=008	,nCol+005	,"Produto"			,oFont07n,,)
oPrn:Say(nLin		,nCol+080	,"Descrição"		,oFont07n,,)
oPrn:Say(nLin		,nCol+230	,"U.M."				,oFont07n,,)
oPrn:Say(nLin		,nCol+260	,"Arm."				,oFont07n,,)
oPrn:Say(nLin		,nCol+290	,"Endereço"			,oFont07n,,)
oPrn:Say(nLin		,nCol+350	,"Lote"				,oFont07n,,)
oPrn:Say(nLin		,nCol+420	,"Fabric."			,oFont07n,,)
oPrn:Say(nLin		,nCol+470	,"Validade"			,oFont07n,,)
oPrn:Say(nLin		,nCol+520	,"Entrega"			,oFont07n,,)
oPrn:Say(nLin		,nCol+570	,"Qtd. Original"	,oFont07n,,)
oPrn:Say(nLin		,nCol+650	,"Qtd. a Separar"	,oFont07n,,)
oPrn:Say(nLin		,nCol+720	,"Qtd. a Embalar"	,oFont07n,,)

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