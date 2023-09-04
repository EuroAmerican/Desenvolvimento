#include "protheus.ch"

#define XNCLIFOR	1
#define XEND		2
#define XCEP		3
#define XBAIRRO		4
#define XMUN		5
#define XEST		6
#define XNTRANSP	7

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMG05     ºAutor  ³TOTVS               º Data ³16/10/2013   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada referente a imagem de identificacao do     º±±
±±º          ³volume temporario. Padrao Zebra                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Img05()

Local cCodEmb 	:= paramixb[1]
Local cPedido 	:= paramixb[2]
Local cNota   	:= IF(len(paramixb)>=3,paramixb[3],nil)
Local cSerie  	:= IF(len(paramixb)>=4,paramixb[4],nil)
Local cNCliFor	:= ""
Local sConteudo
Local aEndRem	:= Array(7)
lOCAL lUsaFor	:= .f.

Local cDescVol	:= ""
Local lUsaFor	:= .F.
Local lRedesp	:= .F.
Local aEndRem	:= Array(7)

Local aAreaCB3	:= CB3->(GetArea())

If CB7->CB7_ORIGEM == "1" // OS por Pedido de Venda
  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no Cadastro de Clientes ou Fornecedores					³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC5")
	dbSetOrder(1)
	If dbSeek(xFilial("SC5")+CB7->CB7_PEDIDO) .And. !Empty(CB7->CB7_PEDIDO)

		If !SC5->C5_TIPO $ "D|B"
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1")+CB7->CB7_CLIENT+CB7->CB7_LOJA)

			cNCliFor := SA1->A1_NOME
		Else
			dbSelectArea("SA2")
			dbSetOrder(1)
			dbSeek(xFilial("SA2")+CB7->CB7_CLIENT+CB7->CB7_LOJA)

			cNCliFor := SA2->A2_NOME
			EndIf

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicia Impressão													³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MSCBBEGIN(1,4)

		MSCBSAY(005,005,Alltrim(cNCliFor),"N","0","025,025")

		MSCBSAY(005,011,"PEDIDO :. "+ CB7->CB7_PEDIDO,"N","0","025,025")
		MSCBSAY(005,015,"ORDEM DE SEPARACAO :. " + CB7->CB7_ORDSEP,"N","0","025,025")
		MSCBSAY(005,019,"VOLUME :. " + Alltrim(cCodEmb),"N","0","025,025")
		MSCBSAY(005,023,"ESPECIE :. " + Alltrim(CB3->CB3_DESCRI),"N","0","025,025")

		//MSCBSAYBAR(030,025,cVolume,"N","MB07",9,.F.,.T.,.F.,,2,1,.F.,.F.,"1",.T.)   	// Código de Barras 1d - 128
		MSCBWrite("^FO700,210^BXN,05,200,20^FD"+Alltrim(cCodEmb)+"^FS") 				// Código de Barras - Data Matrix

ElseIf CB7->CB7_ORIGEM == "2" // OS por NF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona na Nota Fiscal de Saida - SF2                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SF2")
	DbSetOrder(2)
	DbSeek(xFilial("SF2")+CB7->CB7_CLIENT+CB7->CB7_LOJA+CB7->CB7_NOTA+CB7->CB7_SERIE)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no Cadastro de Clientes ou Fornecedores					³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !SF2->F2_TIPO $ "D|B"
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+CB7->CB7_CLIENT+CB7->CB7_LOJA)
	
		aEndRem[XNCLIFOR] := Alltrim(SA1->A1_NOME)
	
	Else
		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSeek(xFilial("SA2")+CB7->CB7_CLIENT+CB7->CB7_LOJA)
	
		aEndRem[XNCLIFOR] := Alltrim(SA2->A2_NOME)
		lUsaFor	:= .T.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no Cadastro de Tipos de Embalagem - CB3					³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CB3")
	dbSetOrder(1)
	dbSeek(xFilial("CB3")+CB6->CB6_TIPVOL)
	
	cDescVol	:= Alltrim(CB3->CB3_DESCRI)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega Informações da Remessa - aEndRem							³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//dbSelectArea("SC5")
	//dbSetOrder(1)
	//If dbSeek(xFilial("SC5")+CB7->CB7_PEDIDO) .And. !Empty(CB7->CB7_PEDIDO)
	
	//dbSelectArea("SC5")
	//dbOrderNickName("BESC5NF")
	//If dbSeek(xFilial("SC5")+CB7->CB7_NOTA+CB7->CB7_SERIE)
	
		If !Empty(SF2->F2_REDESP)
		    
			lRedesp 	:= .T.
			dbSelectArea("SA4")
			dbSetOrder(1)
			dbSeek(xFilial("SA4")+SF2->F2_REDESP)
		
			aEndRem[XEND] 		:= Alltrim(SA4->A4_END)
			aEndRem[XCEP] 		:= Transform(SA4->A4_CEP,PesqPict("SA4","A4_CEP"))
			aEndRem[XBAIRRO] 	:= Alltrim(SA4->A4_BAIRRO)
			aEndRem[XMUN] 		:= Alltrim(SA4->A4_MUN)
			aEndRem[XEST] 		:= Alltrim(SA4->A4_EST)
			aEndRem[XNTRANSP] 	:= Alltrim(SA4->A4_NREDUZ)
		Else
			dbSelectArea("SA4")
			dbSetOrder(1)
			dbSeek(xFilial("SA4")+CB7->CB7_TRANSP)
	
			If !lUsaFor
	            If !Empty(SF2->F2_CLIENT+SF2->F2_LOJENT)
					
					dbSelectArea("SA1")
					dbSetOrder(1)
					dbSeek(xFilial("SA1")+SF2->F2_CLIENT+SF2->F2_LOJENT)
					
					aEndRem[XEND] 		:= Alltrim(SA1->A1_END)
					aEndRem[XCEP] 		:= Transform(SA1->A1_CEP,PesqPict("SA1","A1_CEP"))
					aEndRem[XBAIRRO] 	:= Alltrim(SA1->A1_BAIRRO)
					aEndRem[XMUN] 		:= Alltrim(SA1->A1_MUN)
					aEndRem[XEST] 		:= Alltrim(SA1->A1_EST)
	
				Else
					aEndRem[XEND] 		:= Alltrim(SA1->A1_END)
					aEndRem[XCEP] 		:= Transform(SA1->A1_CEP,PesqPict("SA1","A1_CEP"))
					aEndRem[XBAIRRO] 	:= Alltrim(SA1->A1_BAIRRO)
					aEndRem[XMUN] 		:= Alltrim(SA1->A1_MUN)
					aEndRem[XEST] 		:= Alltrim(SA1->A1_EST)
				EndIf
	
				aEndRem[XNTRANSP] 	:= Iif(SA4->(Found()), Alltrim(SA4->A4_NREDUZ),"")
			Else
				aEndRem[XEND] 		:= Alltrim(SA2->A2_END)
				aEndRem[XCEP] 		:= Transform(SA2->A2_CEP,PesqPict("SA2","A2_CEP"))
				aEndRem[XBAIRRO] 	:= Alltrim(SA2->A2_BAIRRO)
				aEndRem[XMUN] 		:= Alltrim(SA2->A2_MUN)
				aEndRem[XEST] 		:= Alltrim(SA2->A2_EST)
				aEndRem[XNTRANSP] 	:= iIF(SA4->(Found()),Alltrim(SA4->A4_NREDUZ),"")
			EndIf	
		EndIf
	//EndIf		
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia Impressão													³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MSCBBEGIN(1,4)
	
	If !Empty(CB7->CB7_PEDIDO)
		MSCBSAY(005,005,"PEDIDO "+ CB7->CB7_PEDIDO+" NF :. " + CB7->CB7_NOTA+"-"+CB7->CB7_SERIE,"N","0","025,025")
	Else
		MSCBSAY(005,005,"NF :. "+ CB7->CB7_NOTA+"-"+CB7->CB7_SERIE,"N","0","025,025")
	EndIf	
	MSCBSAY(005,009,Alltrim(aEndRem[XNCLIFOR]),"N","0","025,025")

	MSCBSAY(005,013,Iif(lRedesp,"REDESP:. ","TRANSP :. ")+Alltrim(aEndRem[XNTRANSP]),"N","0","025,025")
	MSCBSAY(005,017,"END ENTR.: " + Alltrim(aEndRem[XEND])+" - "+Alltrim(aEndRem[XCEP]),"N","0","025,025")
	MSCBSAY(005,021,Alltrim(aEndRem[XBAIRRO])+" - "+Alltrim(aEndRem[XMUN])+" - "+Alltrim(aEndRem[XEST]),"N","0","025,025")
	MSCBSAY(005,025,"ORDEM DE SEPARACAO :. "+CB7->CB7_ORDSEP,"N","0","025,025")
	MSCBSAY(005,029,"VOLUME :. " + Alltrim(cCodEmb),"N","0","025,025")
	MSCBSAY(005,033,"ESPECIE :. " + Alltrim(cDescVol),"N","0","025,025")

	MSCBWrite("^FO550,180^BXN,05,200,20^FD"+Alltrim(cCodEmb)+"^FS") 				// Código de Barras 2d - Data Matrix


EndIf

MSCBInfoEti("Volume Temp.","80X35")

sConteudo:=MSCBEND()

RestArea(aAreaCB3)

Return sConteudo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMG05OFI  ºAutor  ³TOTVS               º Data ³16/10/2013   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada referente a imagem de identificacao do     º±±
±±º          ³volume permanente."Oficial"                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Img05Ofi

Local sConteudo
Local cDescVol	:= ""
Local nTotEti  	:= paramixb[1]
Local nAtu     	:= paramixb[2]
Local lUsaFor	:= .F.
Local lRedesp	:= .F.
Local aEndRem	:= Array(7)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona na Nota Fiscal de Saida - SF2                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SF2")
DbSetOrder(2)
DbSeek(xFilial("SF2")+CB7->CB7_CLIENT+CB7->CB7_LOJA+CB7->CB7_NOTA+CB7->CB7_SERIE)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no Cadastro de Clientes ou Fornecedores					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !SF2->F2_TIPO $ "D|B"
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+CB7->CB7_CLIENT+CB7->CB7_LOJA)

	aEndRem[XNCLIFOR] := Alltrim(SA1->A1_NOME)

Else
	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek(xFilial("SA2")+CB7->CB7_CLIENT+CB7->CB7_LOJA)

	aEndRem[XNCLIFOR] := Alltrim(SA2->A2_NOME)
	lUsaFor	:= .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no Cadastro de Tipos de Embalagem - CB3					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CB3")
dbSetOrder(1)
dbSeek(xFilial("CB3")+CB6->CB6_TIPVOL)

cDescVol	:= Alltrim(CB3->CB3_DESCRI)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Informações da Remessa - aEndRem							³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//dbSelectArea("SC5")
//dbSetOrder(1)
//If dbSeek(xFilial("SC5")+CB7->CB7_PEDIDO) .And. !Empty(CB7->CB7_PEDIDO)

//dbSelectArea("SC5")
//dbOrderNickName("BESC5NF")
//If dbSeek(xFilial("SC5")+CB7->CB7_NOTA+CB7->CB7_SERIE)

	If !Empty(SF2->F2_REDESP)
	    
		lRedesp 	:= .T.
		dbSelectArea("SA4")
		dbSetOrder(1)
		dbSeek(xFilial("SA4")+SF2->F2_REDESP)
	
		aEndRem[XEND] 		:= Alltrim(SA4->A4_END)
		aEndRem[XCEP] 		:= Transform(SA4->A4_CEP,PesqPict("SA4","A4_CEP"))
		aEndRem[XBAIRRO] 	:= Alltrim(SA4->A4_BAIRRO)
		aEndRem[XMUN] 		:= Alltrim(SA4->A4_MUN)
		aEndRem[XEST] 		:= Alltrim(SA4->A4_EST)
		aEndRem[XNTRANSP] 	:= Alltrim(SA4->A4_NREDUZ)
	Else
		dbSelectArea("SA4")
		dbSetOrder(1)
		dbSeek(xFilial("SA4")+CB7->CB7_TRANSP)

		If !lUsaFor
            If !Empty(SF2->F2_CLIENT+SF2->F2_LOJENT)
				
				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial("SA1")+SF2->F2_CLIENT+SF2->F2_LOJENT)
				
				aEndRem[XEND] 		:= Alltrim(SA1->A1_END)
				aEndRem[XCEP] 		:= Transform(SA1->A1_CEP,PesqPict("SA1","A1_CEP"))
				aEndRem[XBAIRRO] 	:= Alltrim(SA1->A1_BAIRRO)
				aEndRem[XMUN] 		:= Alltrim(SA1->A1_MUN)
				aEndRem[XEST] 		:= Alltrim(SA1->A1_EST)

			Else
				aEndRem[XEND] 		:= Alltrim(SA1->A1_END)
				aEndRem[XCEP] 		:= Transform(SA1->A1_CEP,PesqPict("SA1","A1_CEP"))
				aEndRem[XBAIRRO] 	:= Alltrim(SA1->A1_BAIRRO)
				aEndRem[XMUN] 		:= Alltrim(SA1->A1_MUN)
				aEndRem[XEST] 		:= Alltrim(SA1->A1_EST)
			EndIf

			aEndRem[XNTRANSP] 	:= Iif(SA4->(Found()), Alltrim(SA4->A4_NREDUZ),"")
		Else
			aEndRem[XEND] 		:= Alltrim(SA2->A2_END)
			aEndRem[XCEP] 		:= Transform(SA2->A2_CEP,PesqPict("SA2","A2_CEP"))
			aEndRem[XBAIRRO] 	:= Alltrim(SA2->A2_BAIRRO)
			aEndRem[XMUN] 		:= Alltrim(SA2->A2_MUN)
			aEndRem[XEST] 		:= Alltrim(SA2->A2_EST)
			aEndRem[XNTRANSP] 	:= iIF(SA4->(Found()),Alltrim(SA4->A4_NREDUZ),"")
		EndIf	
	EndIf
//EndIf		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia Impressão													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MSCBBEGIN(1,4)

MSCBSAY(005,005,"NF :. "+ CB7->CB7_NOTA+" "+CB7->CB7_SERIE,"N","0","025,025")
MSCBSAY(005,009,Alltrim(aEndRem[XNCLIFOR]),"N","0","025,025")
MSCBSAY(005,013,Iif(lRedesp,"REDESP:. ","TRANSP :. ")+Alltrim(aEndRem[XNTRANSP]),"N","0","025,025")
MSCBSAY(005,017,"END :. " + Alltrim(aEndRem[XEND])+" - "+Alltrim(aEndRem[XCEP]),"N","0","025,025")
MSCBSAY(005,021,Alltrim(aEndRem[XBAIRRO])+" - "+Alltrim(aEndRem[XMUN])+" - "+Alltrim(aEndRem[XEST]),"N","0","025,025")
MSCBSAY(005,025,"O.S. :. "+CB7->CB7_ORDSEP + " VOLUME :. " + Alltrim(CB6->CB6_VOLUME),"N","0","025,025")
MSCBSAY(005,029,"ESPECIE :. " + Alltrim(cDescVol),"N","0","020,025")
MSCBSAY(005,033,StrZero(nAtu,3)+" de "+StrZero(nTotEti,3) ,"N","0","025,025")

MSCBWrite("^FO550,180^BXN,05,200,20^FD"+Alltrim(CB6->CB6_VOLUME)+"^FS") 				// Código de Barras 2d - Data Matrix

MSCBInfoEti("Volume Ofi.","80X35")

sConteudo:= MSCBEND()

Return sConteudo