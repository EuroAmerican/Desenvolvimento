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
x!Data             ! 17/06/2021                                              !
+------------------+--------------------------------------------------------*/

User Function EQETQPHO()

Private cDe        := Space(13)
Private cAte       := Space(13)
Private cFiltro    := "Lote"
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
Private	_cCodProd  := ""
Private	_cDescProd := ""
Private	_cDesc     := ""
Private	_cUm       := ""
Private	_cLote     := ""
Private	_nQuant    := 0
Private	_cLocal    := ""
Private	_cCodOp    := ""

_cAlias   := Alias()
_nRecno   := Recno()
_nIndex   := IndexOrd()

lRefresh    := .T.		
aButtons    := {}
aAdd(aItens,{.F.,"","","","","",""})

oFont1:= TFont():New("Arial",,-14,.T.,.T.)
oFont2:= TFont():New("Arial",,-20,.T.,.T.)
oOk   := LoaDbitmap(GetResources(),"LBTIK")	//Marca
oNo   := LoaDbitmap(GetResources(),"LBNO")	//Desmarca
oOk1  := LoaDbitmap(GetResources(),"BR_VERDE")	 //Verde
oNo1  := LoaDbitmap(GetResources(),"BR_VERMELHO")//Vermelho	

DEFINE MSDIALOG oDlgEti TITLE "Etiqueta de Materia Prima Modelo Zebra - PHOENIX " FROM 228,222 TO 700,1000 PIXEL
oPanel2 := tPanel():New(00,01,"",oDlgEti,,,,,CLR_WHITE,390,300)
oPanel  := tPanel():New(05,05,"",oPanel2,,,,,CLR_GRAY,380,35)

oFont   := TFont():New('Arial',,-14,,.T.,,,,,)
oFont2  := TFont():New('Arial',,-12,,.T.,,,,,)

oSay    := tSay():New(3,150,{|| "Dados da Impressão" },oPanel,,oFont,,,,.T.,CLR_WHITE,,100,08)

oSay2   := tSay():New(17,020,{|| "OP. De:" },oPanel,,oFont2,,,,.T.,CLR_WHITE,,25,08)
oDe     := tGet():New(15,050,{|u| if(PCount()>0,cDe:=u,cDe)},oPanel,50,008,"@!",{|| zCarrega()},,,,,,.T.,,,{|| .T.},,,,,,,"cDe",,,,.T.,.F.)

oSay3   := tSay():New(17,140,{|| "OP. Até: " },oPanel,,oFont2,,,,.T.,CLR_WHITE,,25,08)
oAte    := tGet():New(15,175,{|u| if(PCount()>0,cAte:=u,cAte)},oPanel,50,008,"@!",{|| zCarrega()},,,,,,.T.,,,{|| .T.},,,,,,,"cAte",,,,.T.,.F.)

oSayImp := tSay():New(50,310,{|| "Impressora"},oPanel2,,oFont2,,,,.T.,,,35,08)
oImpres := TComboBox():New(60,310,{|u| If(PCount()>0,cImpress:=u,cImpress)},aImpre,50,8,oPanel2,,,,,,.T.,,,,,,,,,'cImpress')

oSayPor := tSay():New(080,310,{|| "Porta" },oPanel2,,oFont2,,,,.T.,,,25,08)
oPorta  := TComboBox():New(090,310,{|u| If(PCount()>0,cPorta:=u,cPorta)},aPorta,50,8,oPanel2,,,,,,.T.,,,,,,,,,'cPorta')

oSayQtd := tSay():New(110,310,{|| "Quant.Etiquetas" },oPanel2,,oFont2,,,,.T.,,,60,08)
oQuant  := tGet():New(120,310,{|u| if(PCount()>0,nQuant:=u,nQuant)},oPanel2,050,008,"@E 999,999",{|| .t. },,,,,,.T.,,,{|| .T.},,,,,,,"nQuant",,,,.T.,.F.)

oBtn1 := TButton():New(170,310,'Imprimir',oPanel2,{|| PrtEtq() },40,10,,,,.T.)
oBtn2 := TButton():New(190,310,'Fechar',oPanel2,{|| oDlgEti:end() },40,10,,,,.T.)

@ 45,8 LISTBOX oLbx FIELDS HEADER "","Código Produto","Desc. Produto","Ordem Produção","Local","Quantidade","Lote" SIZE 280,175 NOSCROLL OF oPanel2 PIXEL ON dblClick(aItens[oLbx:nAt,1] := !aItens[oLbx:nAt,1],oLbx:Refresh())

oLbx:SetArray(aItens)
oLbx:bLine:={|| {If(aItens[oLbx:nAt,1],oOk,oNo),aItens[oLbx:nAt,2],aItens[oLbx:nAt,3],aItens[oLbx:nAt,4],aItens[oLbx:nAt,5],aItens[oLbx:nAt,6],aItens[oLbx:nAt,7]}}


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
!Data              ! 17/06/2021                                              !
+------------------+--------------------------------------------------------*/
Static Function zCarrega()

Local   cQuery := ""
Local   lErro  := .F.
Private TMLBAR := GetNextAlias()
aItens       :={}
_cDe         := cDe
_cAte        := If(Empty(cAte),If(Empty(cDe),"ZZZZZZZZZZZ",cDe),cAte)
lQuery       := .T.

If Select("TMLBAR") > 0
	TMLBAR->(DbCloseArea())
EndIf

cQuery := "SELECT D4_FILIAL, D4_OP, D4_COD, D4_LOCAL, D4_QUANT, D4_LOTECTL, D4_QTDEORI " + CRLF
cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SD4") + " AS SD4 WITH (NOLOCK) ON D4_FILIAL = C2_FILIAL " + CRLF
cQuery += "  AND D4_OP = C2_NUM + C2_ITEM + C2_SEQUEN " + CRLF
cQuery += "  AND SD4.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
cQuery += "AND C2_NUM BETWEEN '" + AllTrim(_cDe) + "' AND '" + AllTrim(_cAte) + "' " + CRLF 
cQuery += "AND C2_ITEM = '01' AND C2_SEQUEN = '001' " + CRLF 
cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "GROUP BY D4_FILIAL, D4_OP, D4_COD, D4_LOCAL, D4_QUANT, D4_LOTECTL, D4_QTDEORI " + CRLF
cQuery += "ORDER BY D4_FILIAL, D4_OP, D4_COD, D4_LOCAL, D4_QUANT " + CRLF  

TCQuery cQuery New Alias "TMLBAR"

TMLBAR->(DbGoTop())

While TMLBAR->(!EOF())

	aAdd(aItens,{.F.,;
				 TMLBAR->D4_COD,;
				 AllTrim(Posicione("SB1",1,xFilial("SB1")+TMLBAR->D4_COD,"B1_DESC")),;
	             TMLBAR->D4_OP,;
	             TMLBAR->D4_LOCAL,;
	             TMLBAR->D4_QTDEORI,;
				 TMLBAR->D4_LOTECTL})
		             
	TMLBAR->(DbSkip())
	
EndDo

If Len(aItens)==0
	Aviso("Atencao", "Não existem Ordens de Produção no sistema com os parâmetro informados.", {"Ok"})
	lErro := .T.
Endif

DbSelectArea("TMLBAR")
TMLBAR->(DbCloseArea())

If Len(aItens)==0
	aAdd(aItens,{.F.,"","","","","",""})
EndIf

oLbx:SetArray(aItens)
oLbx:bLine:={|| {If(aItens[oLbx:nAt,1],oOk,oNo),aItens[oLbx:nAt,2],aItens[oLbx:nAt,3],aItens[oLbx:nAt,4],aItens[oLbx:nAt,5],aItens[oLbx:nAt,6],aItens[oLbx:nAt,7]}}

oLbx:Refresh()

Return !lErro

/*-----------------+---------------------------------------------------------+
!Nome              ! PrtEtq                                                  !
+------------------+---------------------------------------------------------+
!Descrição         ! Impressão de Etiqueta Produto                           !
+------------------+---------------------------------------------------------+
!Autor             ! Fábio Carneiro dos Santos                               !
+------------------+---------------------------------------------------------!
!Data              ! 17/06/2021                                              !
+------------------+--------------------------------------------------------*/

Static Function PrtEtq()

Local nX		:= 0
Local nI		:= 0

If cPorta == "LPT1"
   _cPorta := "LPT1"
EndIf

For nX := 1 To Len(aItens)

	If aItens[nX,01]	

		_cCodProd  := aItens[nX,02]
		_cDescProd := aItens[nX,03]
		_cCodOp    := aItens[nX,04]
		_cLocal    := aItens[nX,05]
		_nQuant    := aItens[nX,06]
		_cLote     := aItens[nX,07]
		nQtdEtq    := If(nQuant==0,1,nQuant)

		For nI := 1 To nQtdEtq

			MSCBPRINTER("LPT1",_cPorta,,40,.F.)
			MSCBCHKSTATUS(.F.)
			MSCBBEGIN(1,6)
			MSCBSAY(004,008,"QUANTIDADE : " +TRANSFORM(_nQuant,"@E 999,999,999.9999"),"R","0","025,025")
			MSCBSAY(010,008,"LOTE    : " +Alltrim(_cLote),"R","0","020,020")
			MSCBSAY(016,008,"LOCAL   : " +Alltrim(_cLocal),"R","0","020,020")
			MSCBSAY(022,008,"DESC. : " +Alltrim(_cDescProd),"R","0","020,020")
			MSCBSAY(028,008,"PRODUTO : " +Alltrim(_cCodProd),"R","0","020,020")
			MSCBSAY(034,008,"ORDEM DE PRODUCAO: " +Alltrim(_cCodOp),"R","0","020,020")
 			MSCBEND() 
 			MSCBCLOSEPRINTER()
			Sleep(500)

 		Next nI

	EndIf

Next nX

Return
