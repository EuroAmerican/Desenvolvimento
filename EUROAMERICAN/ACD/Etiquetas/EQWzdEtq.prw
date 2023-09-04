#Include "Protheus.ch"
#Include "ApWizard.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณ                    บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ															  บฑฑ
ฑฑบ          ณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function EQWzdEtq(nOrigem,aParIni)

Local oWizard                                                                           
Local oPanel
Local nTam
Local nTamDoc 	:= TamSX3("F1_DOC")[1]
Local nTamSeri	:= TamSX3("F1_SERIE")[1]
Local nTamForn	:= TamSX3("F1_FORNECE")[1]
Local nTamLoja 	:= TamSX3("F1_LOJA")[1]   
Local cLocImp	:= "000001"

Local oOrigem
Local aOrigem	:= {}

Local aParNF	:= {	{1,"Nota Fiscal",nTamDoc  ,"","","EQSF1P",If(aParIni==NIL,".T.",".F."),0,.F.},; //"Nota Fiscal"
						{1,"Serie" 		,nTamSeri ,"","",		,If(aParIni==NIL,".T.",".F."),0,.F.},; //"Serie"
						{1,"Fornecedor"	,nTamForn ,"","","SA2"	,If(aParIni==NIL,".T.",".F."),0,.F.},; //"Fornecedor"
						{1,"Loja"		,nTamLoja ,"","",		,If(aParIni==NIL,".T.",".F."),0,.F.} } //"Loja"

Local aRetNF	:= {Space(nTamDoc),Space(nTamSeri),Space(nTamForn),Space(nTamLoja)}

Local aParPR	:= {{1,"Produto" 	,Space(Tamsx3("B1_COD")[1])		,""		,""	,"SB1",If(aParIni==NIL,".T.",".F."),100,.F.},; 	// Produto
					{1,"Armazem" 	,Space(Tamsx3("B1_LOCPAD")[1])	,""		,""	,"NNR"	,If(aParIni==NIL,".T.",".F."),020,.F.},; 	// Armazem
					{1,"Lote" 		,Space(Tamsx3("B8_LOTECTL")[1])	,""		,""	,"SB8",If(aParIni==NIL,".T.",".F."),100,.F.},; 	// Lote
					{1,"Dt. Fabr." 	,Space(10)						,"@D"	,"" ,""		,If(aParIni==NIL,".T.",".F."),070,.F.},; 	// Dt. Fabrica็ใo
					{1,"Dt. Valid."	,Space(10)						,"@D"	,"" ,""		,If(aParIni==NIL,".T.",".F."),070,.F.},;	// Dt. Validade
					{1,"Peso Liq." 	,SB1->B1_PESO					,PesqPict("SB1","B1_PESO")	,"" ,""		,If(aParIni==NIL,".T.",".F."),120,.F.},; 	// Dt. Fabrica็ใo
					{1,"Peso Bruto"	,SB1->B1_PESBRU					,PesqPict("SB1","B1_PESBRU"),"" ,""		,If(aParIni==NIL,".T.",".F."),120,.F.}} 	// Dt. Fabrica็ใo
					
Local aRetPR	:= {Space(Tamsx3("B1_COD")[1]),Space(Tamsx3("B1_LOCPAD")[1]),Space(Tamsx3("B8_LOTECTL")[1]),CtoD("//"),CtoD("//"),0,0}

Local aParOP	:= {{1,"Ordem de Produ็ใo" ,Space(13),"","","SC2"	,If(aParIni==NIL,".T.",".F."),60,.F.}}
Local aRetOP	:= {Space(13)}

Local aParImp	:= {{1,"Local de Impressใo"	,cLocImp,"","","CB5"	,".T.",0,.F.}} //"Local de Impressใo"
Local aRetImp	:= {Space(6)}

Local aParam	:= {} 
Local aRetPE	:= {}

Local nx:= 1

Private cCondSF1:= ' 1234567890'  // variavel utilizada na consulta sxb CBW, favor nao remover esta linha
Private oLbx
//Private aLbx	:= {{.f., Space(Tamsx3("B1_COD")[1]),0,0,Space(10),Space(10),Space(10),Space(10),Space(Tamsx3("B1_PESO")[1]),Space(Tamsx3("B1_PESBRU")[1]),Space(10),Space(20)}}
Private aLbx	:= {{.f., Space(Tamsx3("B1_COD")[1]),0,0,Space(10),Space(10),Space(10),Space(10),Space(Tamsx3("B1_PESO")[1]),Space(Tamsx3("B1_PESBRU")[1]),Space(10),Space(20),Space(20),Space(20),Space(20),Space(12)}}
Private aSvPar	:= {}
Private cOpcSel	:= ""  // variavel disponivel para infomar a opcao de origem selecionada
Private cCBNFE	:= ""

Private nOriPr	:= 0

DEFAULT nOrigem := 1

aParam:={	{"Nota Fiscal"	    ,aParNF,aRetNF,{|| AWzVNFSA()}}}//,; 	//"Nota Fiscal"
			//{"Produto"	        ,aParPR,aRetPR,{|| AWzVPR()}} ,; 	//"Produto"
			//{"Ordem de Producao",aParOP,aRetOP,{|| AWzVOP()}} } 	//"Ordem de Producao"

// carrega parametros vindo da funcao pai
If aParIni <> NIL  
	For nX := 1 to len(aParIni)              
		nTam := len( aParam[nOrigem,3,nX ] )
		aParam[nOrigem,3,nX ] := Padr(aParIni[nX],nTam )
	Next             
EndIf 

For nx:= 1 to len(aParam)                       
	aadd(aOrigem,aParam[nX,1])
Next

DEFINE 	WIZARD oWizard TITLE "Etiqueta de Produto ACD" ; //"Etiqueta de Produto ACD"
	HEADER "Rotina de Impressใo de etiquetas termica." ; //"Rotina de Impressใo de etiquetas termica."
	MESSAGE "";
	TEXT "Esta rotina tem por objetivo realizar a impressao das etiquetas termicas de identifica็ใo de produto no padrใo codigo natural/EAN conforme as opcoes disponives a seguir." ; 
	NEXT {|| .T.} ;
	FINISH {|| .T. } ;
	PANEL

   	// Primeira etapa
	CREATE PANEL oWizard ;
    	HEADER "Informe a origem das informa็๕es para impressใo" ; //"Informe a origem das informa็๕es para impressใo"
		MESSAGE "" ;
		BACK {|| .T. } ;
		NEXT {|| nc:= 0,aEval(aParam,{|| &("oP"+str(++nc,1)):Hide()} ),&("oP"+str(nOrigem,1)+":Show()"),cOpcSel:= aParam[nOrigem,1],A11WZIniPar(nOrigem,aParIni,aParam) ,.T. } ;
		FINISH {|| .F. } ;
		PANEL
   
		oPanel := oWizard:GetPanel(2)  
   
		oOrigem := TRadMenu():New(30,10,aOrigem,BSetGet(nOrigem),oPanel,,,,,,,,100,8,,,,.T.)
		If aParIni <> NIL
			oOrigem:Disable()
		EndIf	   

	// Segunda etapa
	CREATE PANEL oWizard ;
		HEADER "Preencha as solicita็๕es abaixo para a sele็ใo do produto" ; //"Preencha as solicita็๕es abaixo para a sele็ใo do produto"
		MESSAGE "" ;
		BACK {|| .T. } ;
		NEXT {|| Eval(aParam[nOrigem,4])} ;
		FINISH {|| .F. } ;
		PANEL                                  

		oPanel := oWizard:GetPanel(3)    
   
		For nx:= 1 to len(aParam)
			&("oP"+str(nx,1)) := TPanel():New( 028, 072, ,oPanel, , , , , , 120, 20, .F.,.T. )
			&("oP"+str(nx,1)):align:= CONTROL_ALIGN_ALLCLIENT                                             
        
			Do Case
				Case nx == 1
					ParamBox(aParNF,"Parโmetros...",aParam[nX,3],,,,,,&("oP"+str(nx,1)))		 //"Parโmetros..."
				Case nx == 2
					ParamBox(aParPR,"Parโmetros...",aParam[nX,3],,,,,,&("oP"+str(nx,1)))		 //"Parโmetros..."	
				Case nx == 3
					ParamBox(aParOP,"Parโmetros...",aParam[nX,3],,,,,,&("oP"+str(nx,1)))		 //"Parโmetros..."
			EndCase
					
			&("oP"+str(nx,1)):Hide()
		Next

	CREATE PANEL oWizard ;
    	HEADER "Parametriza็ใo por produto" ; //"Parametriza็ใo por produto"
		MESSAGE "Marque os produtos que deseja imprimir" ; //"Marque os produtos que deseja imprimir"
		BACK {|| .T. } ;
		NEXT {|| aRetImp  := {Space(6)},VldaLbx()} ;
		FINISH {|| .T. } ;
		PANEL

		oPanel := oWizard:GetPanel(4)       
		ListBoxMar(oPanel)

	CREATE PANEL oWizard ;
    	HEADER "Parametriza็ใo da impressora" ; //"Parametriza็ใo da impressora"
		MESSAGE "Informe o Local de Impressใo" ; //"Informe o Local de Impressใo"
		BACK {|| .T. } ;
		NEXT {|| Imprime(aParam[nOrigem,1]) } ;
		FINISH {|| .T.  } ;
		PANEL

		oPanel := oWizard:GetPanel(5)       
		ParamBox(aParImp,"Parโmetros...",aRetImp,,,,,,oPanel,"PARLOCIMP",.T.)	 //"Parโmetros..."
   
	CREATE PANEL oWizard ;
		HEADER "Impressใo Finalizada" ; //"Impressใo Finalizada"
		MESSAGE "" ;
		BACK {|| .F. } ;
		NEXT {|| .T. } ;
		FINISH {|| .T.  } ;
		PANEL

ACTIVATE WIZARD oWizard CENTERED

Return                                           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณ                    บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ															  บฑฑ
ฑฑบ          ณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A11WZIniPar(nOrigem,aParIni,aParam)

Local nX                      

nOriPr	:= nOrigem

If aParIni <> NIL
	For nx:= 1 to len(aParIni)
		&( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aParIni[ nX ]
	Next
EndIf
         
For nx:= 1 to len(aParam[nOrigem,3])                                    
	&( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aParam[nOrigem,3,nX ]
Next                       

Return .t.                                     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณ                    บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ															  บฑฑ
ฑฑบ          ณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AWzVNFSA()

Local cNota := Padr(MV_PAR01,TamSx3("F1_DOC")[1])
Local cSerie:= Padr(MV_PAR02,TamSx3("F1_SERIE")[1])
Local cForn := Padr(MV_PAR03,TamSx3("F1_FORNECE")[1])
Local cLoja := Padr(MV_PAR04,TamSx3("F1_LOJA")[1])   
Local nQE
Local nQVol
Local nResto               
Local oOk	:= LoadBitmap( GetResources(), "LBOK" )   //CHECKED    //LBOK  //LBTIK
Local oNo	:= LoadBitmap( GetResources(), "LBNO" ) //UNCHECKED  //LBNO   
Local nT	:= TamSx3("D3_QUANT")[1]
Local nD	:= TamSx3("D3_QUANT")[2] 

cCBNFE		:= ""

If Empty(cNota+cSerie+cForn+cLoja)
  	MsgAlert(" Necessario informar a nota e o fornecedor. ") //" Necessario informar a nota e o fornecedor. "
 	Return .F.
EndIf
SF1->(DbSetOrder(1))
If ! SF1->(DbSeek(xFilial('SF1')+cNota+cSerie+cForn+cLoja))
  	MsgAlert(" Nota fiscal nใo encontrada. ") //" Nota fiscal nใo encontrada. "
  	Return .F.
EndIf       

dbSelectArea("SA2")
dbSetOrder(1)
dbSeek(xFilial("SA2")+cForn+cLoja)

cCBNFE	:= cNota+cSerie+cForn+cLoja

aLbx:={}
SD1->(DbSetOrder(1))
SD1->(dbSeek(xFilial('SD1')+cNota+cSerie+cForn+cLoja)	)
While SD1->(!EOF()  .and. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == xFilial('SD1')+cNota+cSerie+cForn+cLoja)
            
	SB1->(dbSeek(xFilial('SB1')+SD1->D1_COD))

	If ! CBImpEti(SB1->B1_COD)
		SD1->(dbSkip()	)
		Loop
	EndIf 
	nQE     := CBQEmbI()
	nQE	    := If(Empty(nQE),1,nQE)
	nQVol   := Int(SD1->D1_QUANT/nQE)
	nResto  := SD1->D1_QUANT%nQE
	If nResto >0
	   nQVol++
	EndIf
	SD1->(aadd(	aLbx,	{	.f., SD1->D1_COD,SD1->D1_QUANT,nQe	,Str(nResto,nT,nD)	,Str(nQVol,nT,nD)	,SD1->D1_LOTECTL,SD1->D1_DFABRIC	,SD1->D1_DTVALID	,SB1->B1_PESO	,SB1->B1_PESBRU,Space(20),"SD1",Recno(),SD1->D1_LOTEFOR, SD1->D1_SERIE+SD1->D1_DOC}))  
	SD1->(dbSkip()	)
End     

oLbx:SetArray( aLbx )
oLbx:bLine := {|| {Iif(aLbx[oLbx:nAt,1],oOk,oNo),aLbx[oLbx:nAt,2],aLbx[oLbx:nAt,3],aLbx[oLbx:nAt,4],aLbx[oLbx:nAt,5],aLbx[oLbx:nAt,6],aLbx[oLbx:nAt,7],aLbx[oLbx:nAt,8],aLbx[oLbx:nAt,9],aLbx[oLbx:nAt,10],aLbx[oLbx:nAt,11],aLbx[oLbx:nAt,12],aLbx[oLbx:nAt,15]}}
oLbx:Refresh()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณ                    บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ															  บฑฑ
ฑฑบ          ณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AWzVPR()

Local cProduto	:= Padr(MV_PAR01,Tamsx3("B1_COD")[1])
Local cLote		:= Padr(MV_PAR03,Tamsx3("D1_LOTECTL")[1])
Local dDtFabr	:= MV_PAR04
Local dDtValid	:= MV_PAR05
Local nPesoLiq	:= MV_PAR06
Local nPesoBrt	:= MV_PAR07
Local oOk		:= LoadBitmap( GetResources(), "LBOK" )   //CHECKED    //LBOK  //LBTIK
Local oNo		:= LoadBitmap( GetResources(), "LBNO" ) //UNCHECKED  //LBNO      
Local nT		:= TamSx3("D3_QUANT")[1]
Local nD		:= TamSx3("D3_QUANT")[2] 

cCBNFE		:= ""

If Empty(cProduto)
  	MsgAlert(" Necessario informar o codigo do produto. ") //" Necessario informar o codigo do produto. "
  	Return .F.
EndIf

SB1->(DbSetOrder(1))
If ! SB1->(DbSeek(xFilial('SB1')+cProduto))
  	MsgAlert(" Produto nใo encontrado ") //" Produto nใo encontrado "
  	Return .F.
EndIf    

If ! CBImpEti(SB1->B1_COD)
  	MsgAlert(" Este Produto estแ configurado para nao imprimir etiqueta ") //" Este Produto estแ configurado para nao imprimir etiqueta "
  	Return .F.
EndIf 

aLbx:={{	.f., SB1->B1_COD,0,CBQEmbI(),Str(0,nT,nD),Str(0,nT,nD),cLote,dDtFabr,dDtValid,nPesoLiq,nPesoBrt,Space(20),"SB1",SB1->(Recno()),'',''}}
oLbx:SetArray( aLbx )
oLbx:bLine := {|| {Iif(aLbx[oLbx:nAt,1],oOk,oNo),aLbx[oLbx:nAt,2],aLbx[oLbx:nAt,3],aLbx[oLbx:nAt,4],aLbx[oLbx:nAt,5],aLbx[oLbx:nAt,6],aLbx[oLbx:nAt,7],aLbx[oLbx:nAt,8],aLbx[oLbx:nAt,9],aLbx[oLbx:nAt,10],aLbx[oLbx:nAt,11],aLbx[oLbx:nAt,12]}}
oLbx:Refresh()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณ                    บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ															  บฑฑ
ฑฑบ          ณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AWzVOP()

Local cOp	:= Padr(MV_PAR01,13) 
Local oOk	:= LoadBitmap( GetResources(), "LBOK" )   //CHECKED    //LBOK  //LBTIK
Local oNo	:= LoadBitmap( GetResources(), "LBNO" ) //UNCHECKED  //LBNO
Local nQtde
Local nQE
Local nQVol
Local nResto                                            
Local nT	:= TamSx3("D3_QUANT")[1]
Local nD	:= TamSx3("D3_QUANT")[2] 

cCBNFE		:= ""

If Empty(cOP)
  	MsgAlert(" Necessario informar o codigo do ordem de produ็ใo. ") //" Necessario informar o codigo do ordem de produ็ใo. "
  	Return .F.
EndIf

SC2->(DbSetOrder(1))
If ! SC2->(DbSeek(xFilial('SC2')+cOP))
  	MsgAlert(" Ordem de Produ็ใo nใo encontrado ") //" Ordem de Produ็ใo nใo encontrado "
 	Return .F.
EndIf               

SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial("SB1")+SC2->C2_PRODUTO))
If ! CBImpEti(SB1->B1_COD)
  	MsgAlert(" Este Produto estแ configurado para nao imprimir etiqueta ") //" Este Produto estแ configurado para nao imprimir etiqueta "
  	Return .F.
EndIf 
                                                        
nQtde	:= SC2->C2_QUANT // SC2->(C2_QUANT-C2_QUJE)
nQE		:= CBQEmbI()
nQE		:= If(Empty(nQE),1,nQE)
nQVol	:= Int(nQtde/nQE)
nResto  :=nQtde%nQE                                               

If nResto >0
   nQVol++
EndIf

aLbx:={{	.f., SB1->B1_COD,nQtde,nQE,Str(nResto,nT,nD),Str(nQVol,nT,nD),SC2->C2_LOTECTL,SC2->C2_DTFABRI,SC2->C2_DTVALID,SB1->B1_PESO,SB1->B1_PESBRU,Space(20),"SC2",SC2->(Recno(),'','')}}
oLbx:SetArray( aLbx )
oLbx:bLine := {|| {Iif(aLbx[oLbx:nAt,1],oOk,oNo),aLbx[oLbx:nAt,2],aLbx[oLbx:nAt,3],aLbx[oLbx:nAt,4],aLbx[oLbx:nAt,5],aLbx[oLbx:nAt,6],aLbx[oLbx:nAt,7],aLbx[oLbx:nAt,8],aLbx[oLbx:nAt,9],aLbx[oLbx:nAt,10],aLbx[oLbx:nAt,11],aLbx[oLbx:nAt,12]}}
oLbx:Refresh()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณ                    บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ															  บฑฑ
ฑฑบ          ณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ListBoxMar(oDlg)

Local oChk1
Local oChk2
Local lChk1 := .F.
Local lChk2 := .F.
Local oOk	:= LoadBitmap( GetResources(), "LBOK" )   //CHECKED    //LBOK  //LBTIK
Local oNo	:= LoadBitmap( GetResources(), "LBNO" ) //UNCHECKED  //LBNO
Local oP
Local lAlter := .T.   
Local lAltPe := .T. 
  
@ 10,10 LISTBOX oLbx FIELDS HEADER " ", "Produto", "Qtde do Item","Qtde Emb.","Resto","Qtde Volumes", "Lote","Dt. Fabr.","Dt. Valid","Peso Liq.","Peso Bruto", "Serie","Lote Forn."  SIZE 230,095 OF oDlg PIXEL ;  //"Produto"###"Qtde do Item"###"Qtde Emb."###"Resto"###"Qtde Volumes"###"Lote"###"Serie"
        ON dblClick(aLbx[oLbx:nAt,1] := !aLbx[oLbx:nAt,1])

oLbx:SetArray( aLbx )
oLbx:bLine	:= {|| {Iif(aLbx[oLbx:nAt,1],oOk,oNo),aLbx[oLbx:nAt,2],aLbx[oLbx:nAt,3],aLbx[oLbx:nAt,4],aLbx[oLbx:nAt,5],aLbx[oLbx:nAt,6],aLbx[oLbx:nAt,7],aLbx[oLbx:nAt,8],aLbx[oLbx:nAt,9],aLbx[oLbx:nAt,10],aLbx[oLbx:nAt,11],aLbx[oLbx:nAt,12],aLbx[oLbx:nAt,15]}}
oLbx:align	:= CONTROL_ALIGN_ALLCLIENT

oP := TPanel():New( 028, 072, ,oDlg, , , , , , 120, 20, .F.,.T. )
oP:align:= CONTROL_ALIGN_BOTTOM


@ 5,010  BUTTON "Alterar"	 SIZE 55,11 ACTION FormProd(1) WHEN lAlter OF oP PIXEL //"Alterar"
@ 5,080  BUTTON "Copiar"	 SIZE 55,11 ACTION FormProd(2) OF oP PIXEL //"Copiar"
@ 5,160 CHECKBOX oChk1 VAR lChk1 PROMPT "Marca/Desmarca Todos" SIZE 70,7 	PIXEL OF oP ON CLICK( aEval( aLbx, {|x| x[1] := lChk1 } ),oLbx:Refresh() ) //"Marca/Desmarca Todos"
@ 5,230 CHECKBOX oChk2 VAR lChk2 PROMPT "Inverter a sele็ใo" 	SIZE 70,7 	PIXEL OF oP ON CLICK( aEval( aLbx, {|x| x[1] := !x[1] } ), oLbx:Refresh() ) //"Inverter a sele็ใo"

Return
            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณ                    บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ															  บฑฑ
ฑฑบ          ณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FormProd(nopcao)

Local oOk		:= LoadBitmap( GetResources(), "LBOK" ) //CHECKED    //LBOK  //LBTIK
Local oNo		:= LoadBitmap( GetResources(), "LBNO" ) //UNCHECKED  //LBNO
Local aRet		:= {}
Local cProduto	:= aLbx[oLbx:nAt,2]

Local nQtde		:= aLbx[oLbx:nAt,3]		 	// Qtde. do Item
Local nQEmb		:= aLbx[oLbx:nAt,4] 		// Qtde. Por Embalagem

Local cQtde		:= aLbx[oLbx:nAt,3] 	 	// Qtde. do Item
Local cQEmb		:= aLbx[oLbx:nAt,4]			// Qtde. Por Embalagem

Local nQVol		:= 0
Local nResto	:= 0
Local cLote		:= aLbx[oLbx:nAt,07]
Local dDtFabr	:= aLbx[oLbx:nAt,08]
Local dDtValid	:= aLbx[oLbx:nAt,09]
Local nPesoLiq	:= aLbx[oLbx:nAt,10]
Local nPesoBrt	:= aLbx[oLbx:nAt,11]
Local cNumSer	:= aLbx[oLbx:nAt,12]   
Local cLoteFor	:= aLbx[oLbx:nAt,15]   
Local nAt		:= oLbx:nAt  

Local nMv
Local aMvPar	:={}
Local lRastro 	:=.T. //Rastro(cProduto)
Local lEndere 	:=.F. //Localiza(cProduto) 
Local nT		:= TamSx3("D3_QUANT")[1]
Local nD		:= TamSx3("D3_QUANT")[2] 

Local cDirProf	:= "\profile\"  
Local cNomeArq	:= "BEWZDETQ"+Alltrim(Str(nAt))

If File(cDirProf+cNomeArq+".prb")
	If fErase(cDirProf+cNomeArq+".prb") == -1      
		MsgStop('Contacte o Administrador do Sistema')
	EndIf	
EndIf

aParamBox := {}  

For nMv := 1 To 40
     aAdd( aMvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )  
Next nMv                     
                       
aParamBox :={     	{1,"Produto"	      	,cProduto		,""								,"" ,""			,".F."						,0	,.F.},; 	//"Produto"
					{1,"Qtde. do Item"     	,nQtde 			,PesqPict("SD3","D3_QUANT")		,""	,""			,".T."						,050,.F.},; 	//"Quantidade"
					{1,"Qtd por Embalagem"	,nQEmb 			,PesqPict("SD3","D3_QUANT")		,""	,""			,".T."						,050,.T.},;  	//"Qtd por Embalagem"
					{1,"Lote"	          	,cLote   		,""								,"" ,""			,".F."/*If(lRastro,".T.",".F.")*/	,0	,.F.},; 	//"Lote"
					{1,"Dt. Fabr."  		,dDtFabr 		,"@D"							,""	,""			,".F."/*If(nOriPr==2,".T.",".F.")*/	,070,.F.},; 	//"Dt. Fabrica็ใo"
					{1,"Dt. Validade"  		,dDtValid		,"@D"							,""	,""			,".T."/*If(nOriPr==2,".T.",".F.")*/	,070,.T.}}//,; 	//"Validade"
//					{1,"Peso Liq."  		,nPesoLiq		,PesqPict("SB1","B1_PESO")		,""	,""			,".T."						,070,.F.},; 	//"Validade"
//					{1,"Peso Bruto"  		,nPesoBrt		,PesqPict("SB1","B1_PESBRU")	,""	,""			,".T."						,070,.F.},; 	//"Validade"
//					{1,"Serie"	          	,cNumSer 		,""								,""	,""			,If(lEndere,".T.",".F.")	,0	,.F.}} 		//"Serie"

  
If ! ParamBox(aParamBox	,If(nopcao == 1,"Alterar","Copiar")	,@aRet	,,,,,,,cNomeArq,.T.,.F.)    //"Alterar","Copiar" 

	For nMv := 1 To Len( aMvPar )
  	  &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
	Next nMv

	oLbx:SetArray( aLbx )
	oLbx:bLine := {|| {Iif(aLbx[oLbx:nAt,1],oOk,oNo),aLbx[oLbx:nAt,2],aLbx[oLbx:nAt,3],aLbx[oLbx:nAt,4],aLbx[oLbx:nAt,5],aLbx[oLbx:nAt,6],aLbx[oLbx:nAt,7],aLbx[oLbx:nAt,8],aLbx[oLbx:nAt,9],aLbx[oLbx:nAt,10],aLbx[oLbx:nAt,11],aLbx[oLbx:nAt,12]}}
	oLbx:Refresh()

	Return

EndIf

nQtde 	:= aRet[2]

If Empty(nQtde)  
	If nOpcao == 2
		MsgAlert("Para a copia a quantidade nใo pode estar em branco!") //"Para a copia a quantidade nใo pode estar em branco!"
	EndIf
	If MsgYesNo("Quantidade informada igual a zero, deseja excluir esta linha?") //"Quantidade informada igual a zero, deseja excluir esta linha?"
	   aDel(aLbx,nAt)
	   aSize(aLbx,len(albx)-1)
   EndIf
Else
	nQEmb	:= aRet[3]
	cLote 	:= aRet[4]
	dDtFabr	:= aRet[5]
	dDtValid:= aRet[6]
	//nPesoLiq:= aRet[7]
	//nPesoBrt:= aRet[8]
	//cNumSer	:= aRet[9]

	nQVol	:= Int(nQtde/nQEmb)  
	nResto	:= nQtde%nQEmb
	If nResto >0
	   nQVol++
	EndIf
	
	If nOpcao == 2
		aadd(aLbx,aClone(aLbx[nAt]))
		nAt := Len(aLbx)
	EndIf  
	aLbx[nAt,3] := nQtde
	aLbx[nAt,4] := nQEmb
	aLbx[nAt,5] := str(nResto,nT,nD) 
	aLbx[nAt,6] := str(nQVol,nT,nD) 
	
	aLbx[nAt,7] := cLote
	aLbx[nAt,8] := dDtFabr
	aLbx[nAt,9] := dDtValid  
	aLbx[nAt,10] := nPesoLiq
	aLbx[nAt,11] := nPesoBrt  
	aLbx[nAt,12] := cNumSer  
	
EndIf

oLbx:SetArray( aLbx )
oLbx:bLine := {|| {Iif(aLbx[oLbx:nAt,1],oOk,oNo),aLbx[oLbx:nAt,2],aLbx[oLbx:nAt,3],aLbx[oLbx:nAt,4],aLbx[oLbx:nAt,5],aLbx[oLbx:nAt,6],aLbx[oLbx:nAt,7],aLbx[oLbx:nAt,8],aLbx[oLbx:nAt,9],aLbx[oLbx:nAt,10],aLbx[oLbx:nAt,11],aLbx[oLbx:nAt,12],aLbx[oLbx:nAt,15]}}
oLbx:Refresh()

For nMv := 1 To Len( aMvPar )
    &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
Next nMv

Return .t.          

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ VldaLbx  ณ Autor ณ      TOTVS S/A        ณ Data ณ 01/01/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Programa para Validar a parametrizacao por produto         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ VldaLbx()                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ ACDI011                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldaLbx()

Local nx
Local nMv
Local lACDI11VL := .T.

SB1->(DbSetOrder(1))
For nX := 1 to Len(aLbx)   
	If aLbx[nx,1] .and. ! Empty(aLbx[nX,3])
		exit
	EndIf	
Next
If nX > len(aLbx)
	MsgAlert("Necessario marcar pelo menos um item com quantidade para imprimir!") //"Necessario marcar pelo menos um item com quantidade para imprimir!"
	Return .f.
EndIf      

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ponto de Entrada para validacoes especificas ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aSvPar := {}
For nMv := 1 To 40
     aAdd( aSvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
Next nMv                     

Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณ                    บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ															  บฑฑ
ฑฑบ          ณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Imprime(cOrigem)

Local cLocImp := MV_PAR01
Local nX 
Local cProduto
Local nQtde
Local nQE   
Local nQVol
Local nResto
Local cAliasOri
Local nRecno    
Local cLote
Local dDtFabr
Local dDtValid
Local nPesoLiq
Local nPesoBrt
Local cNumSerie 
Local nMv
Local nOption := 0 
Local cValid

If cOpcSel == "Nota Fiscal"
	nOption := 1
ElseIf cOpcSel == "Ordem de Producao"
	nOption :=  2
Else // Produto
	nOption := 3
EndIf

If nOption == 0 
	Return .f.
EndIf

If ! CBYesNo("Confirma a Impressao de Etiquetas","Aviso")  //"Confirma a Impressao de Etiquetas"###"Aviso"
	Return .f.
EndIf

If ! CB5SetImp(cLocImp)  
	MsgAlert("Local de Impressใo "+cLocImp+" nao Encontrado!") //"Local de Impressใo "###" nao Encontrado!"
	Return .f.
Endif	

For nMv := 1 To Len( aSvPar )
    &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aSvPar[ nMv ]
Next nMv

SB1->(DbSetOrder(1))
For nX := 1 to Len(aLbx)   
	If ! aLbx[nx,1]
		Loop
	EndIf	
	cProduto:= aLbx[nx,2]
	nQtde	:= aLbx[nx,3]
	
	If Empty(nQtde)
		Loop
	EndIf	
	
	nQE		:= aLbx[nx,4]
	nResto	:= val(aLbx[nx,5])
	nQVol 	:= val(aLbx[nx,6])
	If nResto > 0 
		nQVol--
	EndIf	                 
	cLote	 	:= AllTrim(aLbx[nx,7] )
	dDtFabr		:= aLbx[nx,8]
	dDtValid	:= aLbx[nx,9]
	nPesoLiq	:= aLbx[nx,10]
	nPesoBrt	:= aLbx[nx,11]
	cNumSerie	:= aLbx[nx,12]
	cLoteFor	:= aLbx[nx,15]
	cAliasOri	:= aLbx[nx,13] 
	nRecno		:= aLbx[nx,14]      
	cNFOrig		:= aLbx[nx,16]      

	
	(cAliasOri)->(DbGoto(nRecno)) //posiciona na tabela de origem da informa็ใo

	SB1->(DbSeek(xFilial('SB1')+cProduto))
	
	If nQVol > 0
		U_EQImpMP(cProduto,nQE,nQVol,nResto,cLote,dDtFabr,dDtValid,nPesoLiq,nPesoBrt,cCBNFE,cLoteFor,cNFOrig)
	EndIf

Next

MSCBCLOSEPRINTER()             
	
Return .t.                             
