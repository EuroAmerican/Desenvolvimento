#Include "Protheus.ch"
#Include "RwMake.ch" 
#Include "Topconn.ch"

#define ENTER chr(13) + chr(10)
#define CRLF  chr(13) + chr(10)

/*-----------------+---------------------------------------------------------+
!Nome              ! EQETQPHO                                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Etiqueta Modelo Zebra                                   !
+------------------+---------------------------------------------------------+
!Autor             ! Fábio Carneiro dos Santos                               !
+------------------+---------------------------------------------------------!
x!Data             ! 02/03/2021                                              !
+------------------+--------------------------------------------------------*/

User Function EQETQEXP()

Private cDe        := Space(13)
Private cAte       := Space(13)
Private cFiltro    := "Pedido"
Private oDlg	  // Dialog Principal
Private aItens     := {}
Private aImpre     := {"ZEBRA"}
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
Private _cPedido   := ""
Private _cNome     := ""
Private _cEnd      := ""
Private _cCep      := ""
Private _cBairro   := ""
Private _cMunic    := ""
Private _cEst      := ""
Private _cTransp   := ""
Private _cVolumes  := ""
Private _cEspecie  := ""
Private _cDoc      := ""
Private _cSerie    := ""
Private _dDtNf     := ""
Private _cModelo   := ""

_cAlias   := Alias()
_nRecno   := Recno()
_nIndex   := IndexOrd()

lRefresh    := .T.		
aButtons    := {}
aAdd(aItens,{.F.,"","","","","","","",""})

oFont1:= TFont():New("Arial",,-14,.T.,.T.)
oFont2:= TFont():New("Arial",,-20,.T.,.T.)
oOk   := LoaDbitmap(GetResources(),"LBTIK")	//Marca
oNo   := LoaDbitmap(GetResources(),"LBNO")	//Desmarca
oOk1  := LoaDbitmap(GetResources(),"BR_VERDE")	 //Verde
oNo1  := LoaDbitmap(GetResources(),"BR_VERMELHO")//Vermelho	

DEFINE MSDIALOG oDlgEti TITLE "Etiqueta de Pedido/Nota Fiscal Modelo Zebra - GRUPO EUROAMERICAN " FROM 228,222 TO 700,1000 PIXEL
oPanel2 := tPanel():New(00,01,"",oDlgEti,,,,,CLR_WHITE,390,300)
oPanel  := tPanel():New(05,05,"",oPanel2,,,,,CLR_GRAY,380,35)

oFont   := TFont():New('Arial',,-14,,.T.,,,,,)
oFont2  := TFont():New('Arial',,-12,,.T.,,,,,)

oSay    := tSay():New(3,150,{|| "Dados da Impressão" },oPanel,,oFont,,,,.T.,CLR_WHITE,,100,08)

oSay2   := tSay():New(17,020,{|| "NF De:" },oPanel,,oFont2,,,,.T.,CLR_WHITE,,25,08)
oDe     := tGet():New(15,050,{|u| if(PCount()>0,cDe:=u,cDe)},oPanel,50,008,"@!",{|| zCarrega()},,,,,,.T.,,,{|| .T.},,,,,,,"cDe",,,,.T.,.F.)

oSay3   := tSay():New(17,140,{|| "NF Até: " },oPanel,,oFont2,,,,.T.,CLR_WHITE,,25,08)
oAte    := tGet():New(15,175,{|u| if(PCount()>0,cAte:=u,cAte)},oPanel,50,008,"@!",{|| zCarrega()},,,,,,.T.,,,{|| .T.},,,,,,,"cAte",,,,.T.,.F.)

oSayImp := tSay():New(50,310,{|| "Impressora"},oPanel2,,oFont2,,,,.T.,,,35,08)
oImpres := TComboBox():New(60,310,{|u| If(PCount()>0,cImpress:=u,cImpress)},aImpre,50,8,oPanel2,,,,,,.T.,,,,,,,,,'cImpress')

oSayPor := tSay():New(080,310,{|| "Porta" },oPanel2,,oFont2,,,,.T.,,,25,08)
oPorta  := TComboBox():New(090,310,{|u| If(PCount()>0,cPorta:=u,cPorta)},aPorta,50,8,oPanel2,,,,,,.T.,,,,,,,,,'cPorta')

oSayQtd := tSay():New(110,310,{|| "Quant.Etiquetas" },oPanel2,,oFont2,,,,.T.,,,60,08)
oQuant  := tGet():New(120,310,{|u| if(PCount()>0,nQuant:=u,nQuant)},oPanel2,050,008,"@E 999,999",{|| .t. },,,,,,.T.,,,{|| .T.},,,,,,,"nQuant",,,,.T.,.F.)

oBtn1 := TButton():New(170,310,'Imprimir',oPanel2,{|| PrtEtq() },40,10,,,,.T.)
oBtn2 := TButton():New(190,310,'Fechar',oPanel2,{|| oDlgEti:end() },40,10,,,,.T.)

@ 45,8 LISTBOX oLbx FIELDS HEADER "","Pedido Vendas","Nota Fiscal","Serie Nota","Data Nf","Cliente","Loja","Nome Cliente","Transportadora" SIZE 280,175 NOSCROLL OF oPanel2 PIXEL ON dblClick(aItens[oLbx:nAt,1] := !aItens[oLbx:nAt,1],oLbx:Refresh())

oLbx:SetArray(aItens)
oLbx:bLine:={|| {If(aItens[oLbx:nAt,1],oOk,oNo),;
					aItens[oLbx:nAt,2],;
					aItens[oLbx:nAt,3],;
					aItens[oLbx:nAt,4],;
					aItens[oLbx:nAt,5],;
					aItens[oLbx:nAt,6],;
					aItens[oLbx:nAt,7],;
					aItens[oLbx:nAt,8],;
					aItens[oLbx:nAt,9]}}


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

cQuery := "SELECT F2_DOC, " + CRLF
cQuery += "F2_SERIE, " + CRLF
cQuery += "F2_CLIENTE," + CRLF
cQuery += "F2_LOJA, " + CRLF
cQuery += "F2_TRANSP, " + CRLF
cQuery += "A4_NOME, " + CRLF
cQuery += "A1_NOME, " + CRLF
cQuery += "A1_ENDENT, " + CRLF
cQuery += "A1_CEPE, " + CRLF
cQuery += "A1_BAIRROE," + CRLF
cQuery += "A1_MUNE, " + CRLF
cQuery += "A1_ESTE, " + CRLF
cQuery += "F2_VOLUME1," + CRLF
cQuery += "F2_VOLUME2," + CRLF
cQuery += "F2_VOLUME3," + CRLF
cQuery += "F2_VOLUME4," + CRLF
cQuery += "F2_VOLUME5," + CRLF
cQuery += "F2_VOLUME6," + CRLF
cQuery += "F2_VOLUME7," + CRLF
cQuery += "F2_ESPECI1," + CRLF
cQuery += "F2_ESPECI2," + CRLF
cQuery += "F2_ESPECI3," + CRLF
cQuery += "F2_ESPECI4," + CRLF
cQuery += "F2_ESPECI5," + CRLF
cQuery += "F2_ESPECI6," + CRLF
cQuery += "F2_ESPECI7," + CRLF
cQuery += "F2_EMISSAO," + CRLF
cQuery += "A1_END, " + CRLF
cQuery += "A1_CEP,  " + CRLF
cQuery += "A1_BAIRRO, " + CRLF
cQuery += "A1_MUN, " + CRLF
cQuery += "A1_EST, " + CRLF
cQuery += "C5_NUM " + CRLF
cQuery += "FROM " + RetSqlName("SF2") + "  AS SF2 " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SA1") + "  AS SA1 ON F2_FILIAL = A1_FILIAL " + CRLF
cQuery += "AND F2_CLIENTE = A1_COD " + CRLF
cQuery += "AND F2_LOJA = A1_LOJA " + CRLF
cQuery += "AND SA1.D_E_L_E_T_ = ' '  " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SA4") + "  AS SA4 ON F2_TRANSP = A4_COD " + CRLF
cQuery += "AND SA4.D_E_L_E_T_ = ' '  " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SD2") + "  AS SD2 ON D2_FILIAL = F2_FILIAL " + CRLF
cQuery += "AND D2_DOC = F2_DOC " + CRLF
cQuery += "AND D2_SERIE = F2_SERIE " + CRLF
cQuery += "AND D2_CLIENTE = F2_CLIENTE " + CRLF
cQuery += "AND D2_LOJA = F2_LOJA " + CRLF
cQuery += "AND D2_EMISSAO = D2_EMISSAO " + CRLF
cQuery += "AND D2_TIPO = F2_TIPO " + CRLF
cQuery += "AND SD2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SC5") + "  AS SC5 ON C5_FILIAL = D2_FILIAL " + CRLF
cQuery += "AND C5_CLIENTE = D2_CLIENTE " + CRLF
cQuery += "AND C5_LOJACLI = D2_LOJA " + CRLF
cQuery += "AND C5_NUM = D2_PEDIDO " + CRLF
cQuery += "AND SC5.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE F2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
cQuery += "AND F2_DOC BETWEEN '" + AllTrim(_cDe) + "' AND '" + AllTrim(_cAte) + "' " + CRLF
cQuery += "AND SF2.F2_EMISSAO >= '20220201' " + CRLF
cQuery += "AND SF2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "GROUP BY " + CRLF
cQuery += "F2_DOC, " + CRLF
cQuery += "F2_SERIE, " + CRLF
cQuery += "F2_CLIENTE," + CRLF
cQuery += "F2_LOJA, " + CRLF
cQuery += "F2_TRANSP, " + CRLF
cQuery += "A4_NOME, " + CRLF
cQuery += "A1_NOME, " + CRLF
cQuery += "A1_ENDENT, " + CRLF
cQuery += "A1_CEPE, " + CRLF
cQuery += "A1_BAIRROE," + CRLF
cQuery += "A1_MUNE, " + CRLF
cQuery += "A1_ESTE, " + CRLF
cQuery += "F2_VOLUME1," + CRLF
cQuery += "F2_VOLUME2," + CRLF
cQuery += "F2_VOLUME3," + CRLF
cQuery += "F2_VOLUME4," + CRLF
cQuery += "F2_VOLUME5," + CRLF
cQuery += "F2_VOLUME6," + CRLF
cQuery += "F2_VOLUME7," + CRLF
cQuery += "F2_ESPECI1," + CRLF
cQuery += "F2_ESPECI2," + CRLF
cQuery += "F2_ESPECI3," + CRLF
cQuery += "F2_ESPECI4," + CRLF
cQuery += "F2_ESPECI5," + CRLF
cQuery += "F2_ESPECI6," + CRLF
cQuery += "F2_ESPECI7," + CRLF
cQuery += "F2_EMISSAO," + CRLF
cQuery += "A1_END, " + CRLF
cQuery += "A1_CEP,  " + CRLF
cQuery += "A1_BAIRRO, " + CRLF
cQuery += "A1_MUN, " + CRLF
cQuery += "A1_EST, " + CRLF
cQuery += "C5_NUM " + CRLF
cQuery += "ORDER BY F2_DOC, F2_EMISSAO " + CRLF

TCQuery cQuery New Alias "TRB1"

TRB1->(DbGoTop())

While TRB1->(!EOF())

	aAdd(aItens,{.F.,;             //01
		AllTrim(TRB1->C5_NUM),;    //02
		AllTrim(TRB1->F2_DOC),;    //03
		AllTrim(TRB1->F2_SERIE),;  //04 
		Substr(TRB1->F2_EMISSAO,7,2)+"/"+Substr(TRB1->F2_EMISSAO,5,2)+"/"+Substr(TRB1->F2_EMISSAO,1,4),; //05
		AllTrim(TRB1->F2_CLIENTE),;//06
		AllTrim(TRB1->F2_LOJA),;   //07
		AllTrim(TRB1->A1_NOME),;   //08
		AllTrim(TRB1->A4_NOME),;   //09
		AllTrim(TRB1->A1_ENDENT),; //10  
		AllTrim(TRB1->A1_CEPE),;   //11 
		AllTrim(TRB1->A1_BAIRROE),;//12 
		AllTrim(TRB1->A1_MUNE),;   //13
		AllTrim(TRB1->A1_ESTE),;   //14
		AllTrim(TRB1->A1_END),;    //15
		AllTrim(TRB1->A1_CEP),;    //16
		AllTrim(TRB1->A1_BAIRRO),; //17 
		AllTrim(TRB1->A1_MUN),;    //18 
		AllTrim(TRB1->A1_EST),;    //19
		If(!Empty(TRB1->F2_VOLUME1),TRB1->F2_VOLUME1,0),;           //20
		If(!Empty(TRB1->F2_VOLUME2),TRB1->F2_VOLUME2,0),;           //21
		If(!Empty(TRB1->F2_VOLUME3),TRB1->F2_VOLUME3,0),; 		    //22
		If(!Empty(TRB1->F2_VOLUME4),TRB1->F2_VOLUME4,0),; 			//23
		If(!Empty(TRB1->F2_VOLUME5),TRB1->F2_VOLUME5,0),; 			//24
		If(!Empty(TRB1->F2_VOLUME6),TRB1->F2_VOLUME6,0),; 			//25
		If(!Empty(TRB1->F2_VOLUME7),TRB1->F2_VOLUME7,0),; 			//26
		If(!Empty(TRB1->F2_ESPECI1),Alltrim(TRB1->F2_ESPECI1),""),; //27
		If(!Empty(TRB1->F2_ESPECI2),Alltrim(TRB1->F2_ESPECI2),""),; //28
		If(!Empty(TRB1->F2_ESPECI3),Alltrim(TRB1->F2_ESPECI3),""),; //29
		If(!Empty(TRB1->F2_ESPECI4),Alltrim(TRB1->F2_ESPECI4),""),; //30
		If(!Empty(TRB1->F2_ESPECI5),Alltrim(TRB1->F2_ESPECI5),""),; //31
		If(!Empty(TRB1->F2_ESPECI6),Alltrim(TRB1->F2_ESPECI6),""),; //32 
		If(!Empty(TRB1->F2_ESPECI7),Alltrim(TRB1->F2_ESPECI7),"")}) //33

	TRB1->(DbSkip())
	
EndDo

If Len(aItens)==0
	Aviso("Atencao", "Não existem dados no sistema com os parâmetro informados.", {"Ok"})
	lErro := .T.
Endif

DbSelectArea("TRB1")
TRB1->(DbCloseArea())

If Len(aItens)==0
	aAdd(aItens,{.F.,"","","","","","","",""})
EndIf

oLbx:SetArray(aItens)
oLbx:bLine:={|| {If(aItens[oLbx:nAt,1],oOk,oNo),;
					aItens[oLbx:nAt,2],;
					aItens[oLbx:nAt,3],;
					aItens[oLbx:nAt,4],;
					aItens[oLbx:nAt,5],;
					aItens[oLbx:nAt,6],;
					aItens[oLbx:nAt,7],;
					aItens[oLbx:nAt,8],;
					aItens[oLbx:nAt,9]}}

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

		_cPedido  := aItens[nX,02]
		_cNome    := aItens[nX,08]
		IF Empty(aItens[nX,10]) 
			_cEnd    := aItens[nX,10]
			_cCep    := aItens[nX,11]
			_cBairro := aItens[nX,12]
			_cMunic  := aItens[nX,13]
			_cEst    := aItens[nX,14]
		Else 
			_cEnd     := aItens[nX,15]
			_cCep     := aItens[nX,16]
			_cBairro  := aItens[nX,17]
			_cMunic   := aItens[nX,18]
			_cEst     := aItens[nX,19]
		EndIf 
			
		_cTransp  := aItens[nX,09]
		
		_cEspecie := If(aItens[nX,20] > 0,cValToChar(aItens[nX,20])+"/","")
		_cEspecie += If(!Empty(aItens[nX,27]),aItens[nX,27],"") 
		_cEspecie += If(!Empty(aItens[nX,28]),"-","") 
	
		_cEspecie += If(aItens[nX,21] > 0,cValToChar(aItens[nX,21])+"/","")
		_cEspecie += If(!Empty(aItens[nX,28]),aItens[nX,28],"") 
		_cEspecie += If(!Empty(aItens[nX,29]),"-","") 
		
		_cEspecie += If(aItens[nX,22] > 0,cValToChar(aItens[nX,22])+"/","")
		_cEspecie += If(!Empty(aItens[nX,29]),aItens[nX,29],"") 
		_cEspecie += If(!Empty(aItens[nX,30]),"-","") 
		
		_cEspecie += If(aItens[nX,23] > 0,cValToChar(aItens[nX,23])+"/","")
		_cEspecie += If(!Empty(aItens[nX,30]),aItens[nX,30],"") 
		_cEspecie += If(!Empty(aItens[nX,31]),"-","") 
		
		_cEspecie += If(aItens[nX,24] > 0,cValToChar(aItens[nX,24])+"/","")
		_cEspecie += If(!Empty(aItens[nX,31]),aItens[nX,31],"") 
		_cEspecie += If(!Empty(aItens[nX,32]),"-","") 
		
		_cEspecie += If(aItens[nX,25] > 0,cValToChar(aItens[nX,25])+"/","")
		_cEspecie += If(!Empty(aItens[nX,32]),aItens[nX,32],"") 
		_cEspecie += If(!Empty(aItens[nX,33]),"-","") 
		
		_cEspecie += If(aItens[nX,26] > 0,cValToChar(aItens[nX,26])+"/","")
		_cEspecie += If(!Empty(aItens[nX,33]),aItens[nX,33],"") 
		
		_cDoc     := aItens[nX,03]
		_cSerie   := aItens[nX,04]
		_dDtNf    := aItens[nX,05]

		nQtdEtq    := If(nQuant==0,1,nQuant)

		For nI := 1 To nQtdEtq

			MSCBPRINTER("LPT1",_cPorta,,40,.F.)
			MSCBCHKSTATUS(.F.)

			_cModelo :='CT~~CD,~CC^~CT~'
			_cModelo +='^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ'
			_cModelo +='^XA'
			_cModelo +='^MMT'
			_cModelo +='^PW719'
			_cModelo +='^LL0863'
			_cModelo +='^LS0'
			_cModelo +='^FT84,863^A0B,68,67^FH\^FDPedido de Venda ...: ^FS'
			_cModelo +='^FT84,275^A0B,68,67^FH\^FD'+Alltrim(_cPedido)+'^FS'
			_cModelo +='^FT556,163^A0B,102,100^FH\^FD/^FS'
			_cModelo +='^FT553,551^A0B,102,86^FH\^FD'+AllTrim(_cDoc)+'^FS'
			_cModelo +='^FT554,119^A0B,102,100^FH\^FD'+AllTrim(_cSerie)+'^FS'
			_cModelo +='^FT652,859^A0B,51,50^FH\^FDData N.F...:^FS'
			_cModelo +='^FT549,859^A0B,102,100^FH\^FDN.F ...:^FS'
			_cModelo +='^FT423,857^A0B,31,31^FH\^FDVol./Esp. .:^FS'
			_cModelo +='^FT302,859^A0B,34,33^FH\^FDTransportadora ...:^FS'
			_cModelo +='^FT367,860^A0B,39,38^FH\^FD'+Alltrim(_cTransp)+'^FS'
			_cModelo +='^FT649,603^A0B,51,50^FH\^FD'+_dDtNf+'^FS'
			_cModelo +='^FT425,703^A0B,31,31^FH\^FD'+Alltrim(_cEspecie)+'^FS'
			_cModelo +='^FT244,861^A0B,28,28^FH\^FDCep. ...:^FS'
			_cModelo +='^FT242,603^A0B,28,28^FH\^FD'+AllTrim(_cMunic)+" /"+_cEst+'^FS'
			_cModelo +='^FT242,754^A0B,28,28^FH\^FD'+SubStr(_cCep,1,5)+"-"+SubStr(_cCep,6,3)+'^FS'
			_cModelo +='^FT193,861^A0B,28,28^FH\^FDEnd. Ent. .:^FS'
			_cModelo +='^FT194,719^A0B,28,28^FH\^FD'+Alltrim(_cEnd)+'^FS'
			_cModelo +='^FT141,861^A0B,33,33^FH\^FDCliente..:^FS'
			_cModelo +='^FT142,732^A0B,34,33^FH\^FD'+AllTrim(_cNome)+'^FS'
			_cModelo +='^PQ1,0,1,Y^XZ'

 			MSCBWRITE(_cModelo)
 			Sleep(500)
			MSCBEND() 
			MSCBCLOSEPRINTER()
			Sleep(500)
 
 		 Next nI

	EndIf

Next nX

Return
