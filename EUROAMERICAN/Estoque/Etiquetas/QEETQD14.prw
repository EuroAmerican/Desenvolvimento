#Include "Protheus.ch"
#Include "RwMake.ch" 
#Include "Topconn.ch"

#define ENTER chr(13) + chr(10)
#define CRLF  chr(13) + chr(10)

/*-----------------+---------------------------------------------------------+
!Nome              ! EQETQD14                                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Etiqueta Modelo Zebra                                   !
+------------------+---------------------------------------------------------+
!Autor             ! Fábio Carneiro dos Santos                               !
+------------------+---------------------------------------------------------!
x!Data             ! 18/10/2022                                              !
+------------------+--------------------------------------------------------*/

User Function QEETQD14()

Private cDe        := Space(13)
Private cAte       := Space(13)
Private cFiltro    := "Produtos"
Private oDlg	  // Dialog Principal
Private aItens     := {}
Private aImpre     := {"ZEBRA"} // {"ZEBRA"}
Private aPorta     := {"LPT1"}
Private aFiltros   := {"Lote"}
Private cImpress   := space(10)
Private cPorta     := space(4)
Private cBusca     := space(15)
Private cLote      := space(11)
Private nQuant     := 0
Private _nSeqEmb   := 0
Private _nQtdEmb   := 0
Private lChk       := .F.
Private _cProduto  := ""
Private _cDescProd := ""
Private	_dDtfabric := ""
Private	_dDtValid  := ""
Private	_cLote     := ""
Private	_cQtdCaixa := ""
Private _cModelo   := ""

_cAlias   := Alias()
_nRecno   := Recno()
_nIndex   := IndexOrd()

lRefresh    := .T.		
aButtons    := {}
aAdd(aItens,{.F.,"","","","",""})

oFont1:= TFont():New("Arial",,-14,.T.,.T.)
oFont2:= TFont():New("Arial",,-20,.T.,.T.)
oOk   := LoaDbitmap(GetResources(),"LBTIK")	//Marca
oNo   := LoaDbitmap(GetResources(),"LBNO")	//Desmarca
oOk1  := LoaDbitmap(GetResources(),"BR_VERDE")	 //Verde
oNo1  := LoaDbitmap(GetResources(),"BR_VERMELHO")//Vermelho	

DEFINE MSDIALOG oDlgEti TITLE "Etiqueta Especifica COBASI DUN-14 - GRUPO EUROAMERICAN " FROM 228,222 TO 700,1000 PIXEL
oPanel2 := tPanel():New(00,01,"",oDlgEti,,,,,CLR_WHITE,390,300)
oPanel  := tPanel():New(05,05,"",oPanel2,,,,,CLR_GRAY,380,35)

oFont   := TFont():New('Arial',,-14,,.T.,,,,,)
oFont2  := TFont():New('Arial',,-12,,.T.,,,,,)

oSay    := tSay():New(3,150,{|| "Dados da Impressão" },oPanel,,oFont,,,,.T.,CLR_WHITE,,100,08)

oSay2   := tSay():New(17,020,{|| "Produto De:" },oPanel,,oFont2,,,,.T.,CLR_WHITE,,25,08)
oDe     := tGet():New(15,050,{|u| if(PCount()>0,cDe:=u,cDe)},oPanel,50,008,"@!",{|| zCarrega()},,,,,,.T.,,,{|| .T.},,,,,,,"cDe",,,,.T.,.F.)

oSay3   := tSay():New(17,140,{|| "Produto Até: " },oPanel,,oFont2,,,,.T.,CLR_WHITE,,25,08)
oAte    := tGet():New(15,175,{|u| if(PCount()>0,cAte:=u,cAte)},oPanel,50,008,"@!",{|| zCarrega()},,,,,,.T.,,,{|| .T.},,,,,,,"cAte",,,,.T.,.F.)

oSayImp := tSay():New(50,310,{|| "Impressora"},oPanel2,,oFont2,,,,.T.,,,35,08)
oImpres := TComboBox():New(60,310,{|u| If(PCount()>0,cImpress:=u,cImpress)},aImpre,50,8,oPanel2,,,,,,.T.,,,,,,,,,'cImpress')

oSayPor := tSay():New(080,310,{|| "Porta" },oPanel2,,oFont2,,,,.T.,,,25,08)
oPorta  := TComboBox():New(090,310,{|u| If(PCount()>0,cPorta:=u,cPorta)},aPorta,50,8,oPanel2,,,,,,.T.,,,,,,,,,'cPorta')

oSayQtd := tSay():New(110,310,{|| "Quant.Etiquetas" },oPanel2,,oFont2,,,,.T.,,,60,08)
oQuant  := tGet():New(120,310,{|u| if(PCount()>0,nQuant:=u,nQuant)},oPanel2,050,008,"@E 999,999",{|| .t. },,,,,,.T.,,,{|| .T.},,,,,,,"nQuant",,,,.T.,.F.)

oBtn1 := TButton():New(170,310,'Imprimir',oPanel2,{|| PrtEtq() },40,10,,,,.T.)
oBtn2 := TButton():New(190,310,'Fechar',oPanel2,{|| oDlgEti:end() },40,10,,,,.T.)

@ 45,8 LISTBOX oLbx FIELDS HEADER "","Codigo Produto","Desc. Produto","Data Fabricação","Data Validade","Num. Lote" SIZE 280,175 NOSCROLL OF oPanel2 PIXEL ON dblClick(aItens[oLbx:nAt,1] := !aItens[oLbx:nAt,1],oLbx:Refresh())

oLbx:SetArray(aItens)
oLbx:bLine:={|| {If(aItens[oLbx:nAt,1],oOk,oNo),;
					aItens[oLbx:nAt,2],;
					aItens[oLbx:nAt,3],;
					aItens[oLbx:nAt,4],;
					aItens[oLbx:nAt,5],;
					aItens[oLbx:nAt,6]}}


@ 210,310 CHECKBOX oChk VAR lChk PROMPT "Marca/Desmarca" SIZE 60,007 PIXEL OF oDlgEti;
ON CLICK(Iif(lChk,Marca(lChk),Marca(lChk)))


ACTIVATE MSDIALOG oDlgEti CENTERED

dbSelectArea(_cAlias)
dbSetOrder(_nIndex)
dbGoTo(_nRecno) 

Return(.F.) 

Static Function Marca(lMarca)
Local i := 0
For i := 1 To Len(aItens)
   aItens[i][1] := lMarca
Next i
oLbx:Refresh()
Return
/*-----------------+---------------------------------------------------------+
!Nome              ! zCarrega                                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Impressão de Etiqueta Produto                           !
+------------------+---------------------------------------------------------+
!Autor             ! Fábio Carneiro dos Santos                               !
+------------------+---------------------------------------------------------!
!Data              ! 02/03/2021                                              !
+------------------+--------------------------------------------------------*/
Static Function zCarrega()

Local   cQuery := ""
Local   lErro  := .F.
Private TRB1   := GetNextAlias()
aItens       :={}
_cDe         := cDe
_cAte        := If(Empty(cAte),If(Empty(cDe),"ZZZZZZZZZZZ",cDe),cAte)
lQuery       := .T.

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf

cQuery := "SELECT * " + CRLF
cQuery += "FROM " + RetSqlName("SC2") + "  AS SC2 " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 ON B1_COD = C2_PRODUTO " + CRLF
cQuery += " AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
cQuery += "AND C2_PRODUTO BETWEEN '" + AllTrim(_cDe) + "' AND '" + AllTrim(_cAte) + "' " + CRLF
cQuery += "AND C2_PRODUTO IN "+FORMATIN(GETMV("EQ_COBASI"),"/")+" " + CRLF
cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "ORDER BY C2_NUM " + CRLF

TCQuery cQuery New Alias "TRB1"

TRB1->(DbGoTop())

While TRB1->(!EOF())

	aAdd(aItens,{.F.,;               //01
		AllTrim(TRB1->C2_PRODUTO),;  //02
		AllTrim(TRB1->B1_DESC),;     //03
		Substr(TRB1->C2_DATPRF,7,2)+"/"+Substr(TRB1->C2_DATPRF,5,2)+"/"+Substr(TRB1->C2_DATPRF,1,4),;    //04
		Substr(TRB1->C2_XDTVALI,7,2)+"/"+Substr(TRB1->C2_XDTVALI,5,2)+"/"+Substr(TRB1->C2_XDTVALI,1,4),; //05
		AllTrim(TRB1->C2_NUM),; //06
		TRB1->B1_CONV}) //07


	TRB1->(DbSkip())
	
EndDo

If Len(aItens)==0
	Aviso("Atencao", "Não existem dados no sistema com os parâmetro informados.", {"Ok"})
	lErro := .T.
Endif

DbSelectArea("TRB1")
TRB1->(DbCloseArea())

If Len(aItens)==0
	aAdd(aItens,{.F.,"","","","",""})
EndIf

oLbx:SetArray(aItens)
oLbx:bLine:={|| {If(aItens[oLbx:nAt,1],oOk,oNo),;
					aItens[oLbx:nAt,2],;
					aItens[oLbx:nAt,3],;
					aItens[oLbx:nAt,4],;
					aItens[oLbx:nAt,5],;
					aItens[oLbx:nAt,6]}}

oLbx:Refresh()

Return !lErro

/*-----------------+---------------------------------------------------------+
!Nome              ! PrtEtq                                                  !
+------------------+---------------------------------------------------------+
!Descrição         ! Impressão de Etiqueta Produto                           !
+------------------+---------------------------------------------------------+
!Autor             ! Fábio Carneiro dos Santos                               !
+------------------+---------------------------------------------------------!
!Data              ! 02/03/2021                                              !
+------------------+--------------------------------------------------------*/

Static Function PrtEtq()

Local nX  := 0
Local nI  := 0

If cPorta == "LPT1"
   _cPorta := "LPT1"
EndIf

// Inicia a impressao das etiquetas.

For nX := 1 To Len(aItens)

	If aItens[nX,01]	

		_cProduto  := aItens[nX,02]
		_cDescProd := aItens[nX,03]
		_dDtfabric := aItens[nX,04]
		_dDtValid  := aItens[nX,05]
		_cLote     := aItens[nX,06]
		_cQtdCaixa := StrZero(aItens[nX,07],2)

		nQtdEtq    := If(nQuant==0,1,nQuant)

		For nI := 1 To nQtdEtq
			
			MSCBPRINTER("LPT1",_cPorta,,40,.F.)
			MSCBCHKSTATUS(.F.)

			If Alltrim(_cProduto) == "7790.990.13"
			
				_cModelo :='CT~~CD,~CC^~CT~'
				_cModelo +='^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ'
				_cModelo +='^XA'
				_cModelo +='^MMT'
				_cModelo +='^PW609'
				_cModelo +='^LL0406'
				_cModelo +='^LS0'
				_cModelo +='^FO32,128^GFA,11520,11520,00072,:Z64:'
				_cModelo +='eJztmcFu2kAQhscsYTlQU6mNxMFVUJ6gkXrgtlSqeubQSj30QN/AlSq1p6xpXiaPYb9BH8FPYPfIwVp3PItdDIFAM1JDtBPFO7Njf/75Wc0FABf74iNDzJCjyofHEjmaiaOYOJqJo5g4momjmDiaiaOYOJqJo5g4momjmDiaiaOYOJqJo5g4momjmDiaiaPKMsvyPDcmz7MS/3A1WVbmmaF0lZvcVLes+rhWdxnsZHmjB0CKRRFICRfxRRrKReGlWkLglVIuAy+u8mD42+Yw8ZJSglokJYRqEYPX6AEQYrEc+AJUNEzHmEN6LaIRmI5Yjmw+GKaUG+REpoecyMAYrzXH6pEJ6dGk520BqGcagJGyCCBt6/nhJQbvTBIDoU629fh+h/TMxU2jp7fSA42e63U980qP2OWP8Co9gvwRd/pjyB+z35/54f683vbH6lHkD+lBDZv+FKTn273+iAP8MUf5g+/9Z3/8Q85P/NjOz3H+2PMDT/787NBzvz/1+bl7/hzkj5s/p39+3Pxx88fNHzd/3Pxx8+cUz4+bP27+uPnj5o+bP27+nOL5cfPHzR83f9z8cfPnf8wf/IzipvB92fZnQv5M0BPM/UrPxPoT13rCtj8Pjkf6+xcLRzNxFBNHM3EUE0czcRQTRzNxFBNHM3EUE0czcRQTRzNxFBNHM3EUE0czcZ52eFNaXgGc2foXwOe6PotpD2tJW15MfXv/RozrpB/ZZb1umh38j+jabz/VxJyu+L4BKfMCgHcAb2xtm1j3cJlCF/svaetqh57Ohp7LdT0/Gz1R3e/s4HQbf0bkx5WtSSJ8AHiBHdyaUh8O8ee23q3qqNZz2dx8236qiXmtZ2Rf/gngPcBXgOfT+stEf76TRd2Q+hhfdujpN19Un94/puSvCzbrjNtPrYUX0oKf+llM9Yz8OEcLYpAzamItsCZ9nt0639JzVER10t9zkwsXR8Qf952wXg==:2A30'
				_cModelo +='^FT38,43^A0N,25,21^FH\^FDCodigo Produto ...:^FS'
				_cModelo +='^FT210,124^A0N,25,16^FH\^FDValidade ..:^FS'
				_cModelo +='^FT297,123^A0N,25,16^FH\^FD'+AllTrim(_dDtValid)+'^FS'
				_cModelo +='^FT136,123^A0N,25,14^FH\^FD'+AllTrim(_dDtfabric)+'^FS'
				_cModelo +='^FT38,123^A0N,25,16^FH\^FDFabrica\87\C6o ..:^FS'
				_cModelo +='^FT38,85^A0N,25,19^FH\^FDDesc. Produto ..:^FS'
				_cModelo +='^FT478,43^A0N,25,33^FH\^FD'+AllTrim(_cQtdCaixa)+'^FS'
				_cModelo +='^FT366,43^A0N,25,21^FH\^FDCAIXA C/ :^FS'
				_cModelo +='^FT221,43^A0N,25,24^FH\^FD'+AllTrim(_cProduto)+'^FS'
				_cModelo +='^FT183,82^A0N,25,16^FH\^FD'+AllTrim(_cDescProd)+'^FS'
				_cModelo +='^FT388,123^A0N,25,19^FH\^FDLote ...:^FS'
				_cModelo +='^FT456,123^A0N,25,19^FH\^FD'+Alltrim(_cLote)+'^FS'
				_cModelo +='^PQ1,0,1,Y^XZ'
			
			ElseIf Alltrim(_cProduto) == "7790.980.13"

				_cModelo :='CT~~CD,~CC^~CT~'
				_cModelo +='^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ'
				_cModelo +='^XA'
				_cModelo +='^MMT'
				_cModelo +='^PW609'
				_cModelo +='^LL0406'
				_cModelo +='^LS0'
				_cModelo +='^FO32,96^GFA,13824,13824,00072,:Z64:'
				_cModelo +='eJztmj9P22AQxs95ad6oQmEoEhksJWJCqZSoW7dLpX6ADm2nDvkIVGKseJ1m6cdgtqV2rRio+SaeMzFGUeT0fG/sAuE/RwXoboj92MfPj5+cbgkAWlpaWlpaWloPW58E6gNxcHH/mhLHCXFQiOOEOCjEcUIcFOI4IQ4KcZwQB4U4ToiDQhwnxEEhjhPioBDHCXFQiOOEOCjEcUIcXCwiMOPxtNk0EUYbWWbGU8gWJmpBbs205c+bG5mZvoUsN2PqaRY9eRNwRH9b+QGw9ngeWgsubWe79t0cMmcHIXHsPCzOIQw3Tuw0DFJnTdpOrTXzIKf+4xSCyg+AMSPyU4PCz5D97LOfOvvZN9BaL/zwuaGeujHkp77qx4zYT7vwY4LCj4EwWNB7sYfTfoKo8BOwHxyt+llvmqWfUeWntvQQVX7ywk962k9wJh/vBzkf9kMezuczZz+W87FX5GNukE9+q3zouXfOp/TTuSqf9Lp8/vf83C4fPz/w7Ocnums+5fzYu+dz5fxcm4/un8cwP7p/dP/o/tH9o/tH989TnB/dP7p/dP/o/tH9o/vnKc6P7h/dP7p/dP/o/tH98xTn57nun8GN5ieO+0mS9372Y4z7kwmddyeLJD7q5v1kdsTnh71fk2R22J3kSUI9vSSZdfNejMkkfv3sf68U4TghDgpxnBAHhThOiINCHCfEQSGOE+KgEMcJcVCI44Q4KMRxQhwU4jghDv65f/0Guf8/fKR1wJ9dgFpU6h2Al6yXl0jX/KWDsr92HhMM+fACYD1lTa/8HmCT9Zq/SbpOLawDH0l9xU+n5Df8wxssOl53yi4yA143Kn0Rx1DDgP20Sj+F7pR+XtGB/A74Pnh9iZ9a5WfndF5U330e1X24IB8Y8ucavb/38wXgI8BXr/lSoT/THdbFfWB9oZ/qQcsvp+N1VPrZriz5tu1LOOSn5R/u83nDOvAtpLe4JYAyn61LOI3q+6pckP6XQq3y+6PUZyvY48Mmz0ehdwH2+Hmk7ZBvfuN5aXt/J3xpdX60Hrj+Ah+blT0=:556A'
				_cModelo +='^FT38,43^A0N,25,19^FH\^FDCodigo Produto ...:^FS'
				_cModelo +='^FT223,117^A0N,25,16^FH\^FDValidade ..:^FS'
				_cModelo +='^FT310,117^A0N,25,16^FH\^FD'+AllTrim(_dDtValid)+'^FS'
				_cModelo +='^FT143,117^A0N,25,14^FH\^FD'+AllTrim(_dDtfabric)+'^FS'
				_cModelo +='^FT38,117^A0N,25,16^FH\^FDFabrica\87\C6o ..:^FS'
				_cModelo +='^FT38,80^A0N,25,16^FH\^FDDesc. Produto ..:^FS'
				_cModelo +='^FT429,43^A0N,25,33^FH\^FD'+AllTrim(_cQtdCaixa)+'^FS'
				_cModelo +='^FT332,43^A0N,25,16^FH\^FDCAIXA C/ :^FS'
				_cModelo +='^FT195,43^A0N,25,21^FH\^FD'+AllTrim(_cProduto)+'^FS'
				_cModelo +='^FT188,80^A0N,25,16^FH\^FD'+AllTrim(_cDescProd)+'^FS'
				_cModelo +='^FT406,117^A0N,25,16^FH\^FDLote ..:^FS'
				_cModelo +='^FT462,117^A0N,25,16^FH\^FD'+Alltrim(_cLote)+'^FS'
				_cModelo +='^PQ1,0,1,Y^XZ'
				
			ElseIf Alltrim(_cProduto) == "7790.000.26"

				_cModelo :='CT~~CD,~CC^~CT~'
				_cModelo +='^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ'
				_cModelo +='^XA'
				_cModelo +='^MMT'
				_cModelo +='^PW609'
				_cModelo +='^LL0406'
				_cModelo +='^LS0'
				_cModelo +='^FO32,128^GFA,13824,13824,00072,:Z64:'
				_cModelo +='eJztmj9r21AQwE96SZ4pwR4aqAeBTafgQEy3bs+FfIAObacO/ggpZCx5cv1FMkvQriVDKn8TzZoymmDknu5Zr/lrB+cocbgbLJ10/umn83FLAiAhIXE7PjPER+SY+dNjihzLxDFMHMvEMUwcy8QxTBzLxDFMHMvEMUwcy8QxTBzLxDFMHMvEMUwcy8QxTBzLxDFMHMvEMfN5DGo8njabKjZxK8/VeAr5XMVtKLWatt15s5Wr6XvISzXGmtalGsV5CWaE3/U+AFpPZpHWYLNOfqw/zCC3ehAhR8+i6hyiqHWpp1GQWa2yTqYv1WSSWbCTDALvA6DUCH1CqHyG5HNKPjvkc6qgvVv50LnCGv2QjxqRT6fyUUHloyAK5vhe5HDdJ4grn2BU+ZjRXZ/dplr4jLxPuHCIvU9Z+WTkkzmf4EZ/nI+h/pAPOtzuz4x8NPVHL+mPekR/Stef/HH9weeu3Z/ap7usP9mq/vzv+SnXmB948fMTrzk/UM+PXr8/S+dnZX9k/zyH+ZH9I/tH9o/sH9k/sn82cX5k/8j+kf0j+0f2j+yfTZwf2T+yf2T/yP6R/SP7ZxPn56Xun8Gj5idJ+mlaHv7sJybpFwWe94p5mlz0yn56dUHn54e/ivTqvFeUaYo1/auDtCjKxKRFcvDi/17JwrFMHMPEsUwcw8SxTBzDxLFMHMPEsUwcw8SxTBzDxLFMHMPEsUwcw8SxTBzz5+nxG/j+//CZxhl99gDCuM73AV5RvriEeegundX1jduYYEiHbYDdjHJ85SOAPcq33E3Md7CE8kX93h2fLn3i8xpx/aSQrlZ5t65CGXC5u7T1AEfh9wbk0659qrxb+7zGA/oOVnFC358G9eNfvzB+0H2Ir9XfjWHN33Y+XwE+AXxzOV2q8i94x+W+/l4f8D/Bvu+PV0Cft15p+Xvh9bZ7uOvPO8oDV4L5GyoJYBWn4X8vb4F56KtC7+v9b0ZwQoc9mo8qPwY4oedjrod08zvNT4f8FvWd+2kSEhISEhKbEn8BDCQ1QQ==:B930'
				_cModelo +='^FT38,43^A0N,25,16^FH\^FDCodigo Produto ...:^FS'
				_cModelo +='^FT38,88^A0N,28,16^FH\^FDDesc. Produto ..:^FS'
				_cModelo +='^FT424,47^A0N,23,33^FH\^FD'+AllTrim(_cQtdCaixa)+'^FS'
				_cModelo +='^FT332,44^A0N,23,16^FH\^FDCAIXA C/ :^FS'
				_cModelo +='^FT171,43^A0N,25,24^FH\^FD'+AllTrim(_cProduto)+'^FS'
				_cModelo +='^FT158,88^A0N,28,16^FH\^FD'+AllTrim(_cDescProd)+'^FS'
				_cModelo +='^FT223,127^A0N,25,16^FH\^FDValidade ..:^FS'
				_cModelo +='^FT310,127^A0N,25,16^FH\^FD'+AllTrim(_dDtValid)+'^FS'
				_cModelo +='^FT143,127^A0N,25,14^FH\^FD'+AllTrim(_dDtfabric)+'^FS'
				_cModelo +='^FT38,127^A0N,25,16^FH\^FDFabrica\87\C6o ..:^FS'
				_cModelo +='^FT406,127^A0N,25,16^FH\^FDLote ..:^FS'
				_cModelo +='^FT462,127^A0N,25,16^FH\^FD'+Alltrim(_cLote)+'^FS'
				_cModelo +='^PQ1,0,1,Y^XZ'

			ElseIf Alltrim(_cProduto) == "7790.100.26"

				_cModelo :='CT~~CD,~CC^~CT~'
				_cModelo +='^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ'
				_cModelo +='^XA'
				_cModelo +='^MMT'
				_cModelo +='^PW609'
				_cModelo +='^LL0406'
				_cModelo +='^LS0'
				_cModelo +='^FO32,128^GFA,10880,10880,00068,:Z64:'
				_cModelo +='eJztmcFq20AQhkdaIYnayC6kkIPBbk7BvRh6qMjFbukj9AFMn8APEBwVXww+9Bna4wrsew6NQi9+DB2NcvFxMa7c1UqrrmMpCXHTpGGGZRivl9lvfw//xQDPJ3S6Z3gA2mbPCADIX+iBHMiBHMiBHIKD2fZiETuOY2/G3cnY7Y7d5nzu2LFTWyycr8ytTCaswhr2nB+yY3tRY65bYfyoXZMcS4AgODVME86gq0G96TWal0EV1oYV9i1r2dE0jWnrhhasqwacQt9aDjrasvnFA0ty8B5hyK8QPUae2+XrZ+gA5whDiyxdMhoxwk5IcghiCHlblzB+NOuRc5imlfQgCcdhymFa4SDhIIRzsIZ2mXAMYZBwkGIOJ+c4bAZBxmFmHLwHBDmHm3HUrnMkbzkjBXoQVY/hnfX4lunR/6OHC5ke/XvpkXHcoAcr1KOa6WGxu+thGP9iPvTb5mN423zcR4/Hmw+nYD7CveajcdN8dB5wPtA/0D/QP9A/0D+e0Hygf6B/oH+gf6B/oH+gf6B/oH+gfzyl+UD/QP9A//h//GNFaRTF0+mUbujGp+cXfF1FUxpPZ1E0m63Ofd9f+fEPPzlEYxrNVnxvdeFTOnuO/78gB3IgB3I8HsevPYP30L/vGR48SNgyqwvKsxJ1kT8BHIjiYHulO4bIr+SOcb3HschHYuVFa3vnhfyY7rwt5uCte6Lo7bxR28kvS2VIgT4DtEXNs65w6HKB+FgS6Vs/iqInZcjvBkWGHT1yjvStJ8rT0/veyNqUHCV61BUl0uK9/IpzvNu+vkQPfvyDKHSFoyV2jsSmOjGvvUIZ6kKJ9DJDmQkoyjscbZFb8nc5VlZbguqyTnP574KBocZvLWZHXg==:82DC'
				_cModelo +='^FT38,43^A0N,25,19^FH\^FDCodigo Produto ...:^FS'
				_cModelo +='^FT38,88^A0N,28,19^FH\^FDDesc. Produto ..:^FS'
				_cModelo +='^FT439,44^A0N,23,33^FH\^FD'+AllTrim(_cQtdCaixa)+'^FS'
				_cModelo +='^FT332,41^A0N,23,21^FH\^FDCAIXA C/ :^FS'
				_cModelo +='^FT195,43^A0N,25,24^FH\^FD'+AllTrim(_cProduto)+'^FS'
				_cModelo +='^FT179,88^A0N,28,16^FH\^FD'+AllTrim(_cDescProd)+'^FS'
				_cModelo +='^FT223,125^A0N,25,16^FH\^FDValidade ..:^FS'
				_cModelo +='^FT310,125^A0N,25,16^FH\^FD'+AllTrim(_dDtValid)+'^FS'
				_cModelo +='^FT143,125^A0N,25,14^FH\^FD'+AllTrim(_dDtfabric)+'^FS'
				_cModelo +='^FT38,125^A0N,25,16^FH\^FDFabrica\87\C6o ..:^FS'
				_cModelo +='^FT406,125^A0N,25,16^FH\^FDLote ..:^FS'
				_cModelo +='^FT462,125^A0N,25,16^FH\^FD'+Alltrim(_cLote)+'^FS'
				_cModelo +='^PQ1,0,1,Y^XZ'

			ElseIf Alltrim(_cProduto) == "7790.200.26"

				_cModelo :='CT~~CD,~CC^~CT~'
				_cModelo +='^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ'
				_cModelo +='^XA'
				_cModelo +='^MMT'
				_cModelo +='^PW609'
				_cModelo +='^LL0406'
				_cModelo +='^LS0'
				_cModelo +='^FO32,128^GFA,10880,10880,00068,:Z64:'
				_cModelo +='eJztmrFuGkEQhmdZ4kMWwkRKpCuQDyWN5YoixSmKDIUfwEXKFDwCXVKFJTR+DJfRIUFPYc5SHmRrKsrTCUHmZm/Bd1wiRyTIIvNrddqdPc9++zMaIRkA1nNUKdhfYr2/5F/IwRxZMUdWzJEVc2R1ZBxxEMTT2Rw1iUer+2C+Dqaz0XwcrEejGJerSTC9n80n83g0Wo0xHMwCfH08SXaDGXFEAL269xCGXWchlg3o9KHlDcIq9KWIGhB+dcBteKGje0IsqxgGT3lheOIku+ARB+bw/fZQay0jGZ2DXkOyrGGOYXQFeiVx39NnuieHcQ3D0Fae1jUpIx+gTRwL5GhZDkzdNRxly9F3oO4ix6InEbNscoSh48iFSzk2HCo0HFU8GJJlDdbI0Ug4lO+eGY6oimHKgRzDyLUchX48bP3oF/uBHHk/VNaPQerHh9SPNnK0cJ360f6dH8tiPxrFfjSe7gcYP77I4fJP/NinPuJcfZzv1sd668f7f14fg1/UR+1Q9XFVXB/ec6gP5fupHwerD+4f3D+4f3D/4P7B/YP7B/cP7h/cP7h/cP/g/sH9g/sH9w/uH9w/uH/81/1jbx3Z/4H2FnNkxRxZMUdWzJGV+Ly/DveLqCepZJ5NgDuaXdAomaEo1LQbl49ff6QyPV90QdRp9hHgFa7N6FDoBsCl6GuKokSngAPPKrk0+QHwBqCCQ1mCW1onLyoamz/KCRMbjmt61k0oRyty0RyHBnlHk2/EgV8vTi2H/L5jkdRFOTr2jtd085fm5hQSTZpsUcAy53Io68clcbgKKmF6+cSPjCU7Obaq25sL64fYHP3J7qV+FHEI5PBpdgLwFr8eIYe2jLfkB96oCraKWpkcjj0rrY86+SHID8ccekPPd/QsrI+KsjNzwgXd/NR8AmavaerFbiRScHT6CVa/8R4=:7222'
				_cModelo +='^FT38,43^A0N,25,19^FH\^FDCodigo Produto ...:^FS'
				_cModelo +='^FT38,88^A0N,28,21^FH\^FDDesc. Produto ..:^FS'
				_cModelo +='^FT437,44^A0N,23,33^FH\^FD'+AllTrim(_cQtdCaixa)+'^FS'
				_cModelo +='^FT330,41^A0N,23,21^FH\^FDCAIXA C/ :^FS'
				_cModelo +='^FT193,43^A0N,25,24^FH\^FD'+AllTrim(_cProduto)+'^FS'
				_cModelo +='^FT189,88^A0N,28,16^FH\^FD'+AllTrim(_cDescProd)+'^FS'
				_cModelo +='^FT223,128^A0N,25,16^FH\^FDValidade ..:^FS'
				_cModelo +='^FT310,128^A0N,25,16^FH\^FD'+AllTrim(_dDtValid)+'^FS'
				_cModelo +='^FT143,128^A0N,25,14^FH\^FD'+AllTrim(_dDtfabric)+'^FS'
				_cModelo +='^FT38,128^A0N,25,16^FH\^FDFabrica\87\C6o ..:^FS'
				_cModelo +='^FT406,128^A0N,25,16^FH\^FDLote ..:^FS'
				_cModelo +='^FT462,128^A0N,25,16^FH\^FD'+Alltrim(_cLote)+'^FS'
				_cModelo +='^PQ1,0,1,Y^XZ'
			
			EndIf

			MSCBWRITE(_cModelo)
 			Sleep(500)
			MSCBEND() 
			MSCBCLOSEPRINTER()
			Sleep(500)
 
 		 Next nI

	EndIf

Next nX

Return
