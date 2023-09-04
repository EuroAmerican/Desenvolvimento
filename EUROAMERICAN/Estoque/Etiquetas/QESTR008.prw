#include "protheus.ch"
#include "topconn.ch"        
#include "tbiconn.ch"   
#include "rwmake.ch"    

User Function QESTR008()

	Processa( {||QETIQ008() }, "Aguarde...", "Imprimindo etiquetas...",.F.)
Return

/*
{Protheus.doc} QESTR009()
Emissão de etiqueta de POTE LI
@Author     FABIO BATISTA
@Since      27/05/2020
@Version    P12.25
@Project    
@Param		 ETIQUETA NUMERACAO - ZEBRA
@Param		 cBody
@Param		 mv_par01/mv_par02
*/
STATIC Function QETIQ008()                                 

Local cPorta  := "LPT1"
Local cModelo := "ZEBRA"
Local nX  		:= 0

Local _cDesc2 	:= ""		//Descricao do produto
Local _cCod   	:= ""		//Cod do produto    
Local _cFab		:= ""		//Fabricacao
Local _cVal   	:= ""		//Validade( String )
Local _cLote  	:= ""		//Lote
Local _cCodBar	:= ""		//String do Cod de barras
Local _nQtd   	:= 0		//Qtd de etiquetas
Local _cCont 	:= ""		//Conteudo
Local _cUM      := "KG"     //Unidade de Medida    
Local _dVal		:= CtoD("")	//Validade( Date )
Local cCampo  	:= "SB1->B1_U_DESC2"
Local lSai    	:= .T.                       
Local nX  		:= 0

Private cPerg := "QEST08" 

	cPergunt()
	if ! Pergunte(cPerg, .T.)
		Return nil
	endif                       

	If SELECT("SC2")>0
		dbSelectArea("SC2")
	EndIf
	SC2->(dbSetOrder(1))
	SC2->(DBGOTOP())

	If !SC2->(dbSeek(xFilial("SC2") + Subs(mv_par04, 1, 6)))
		ALERT("A T E N Ç Ã O" + CRLF + CRLF + "Lote inválido!" + CRLF + "Não será impresso a etiqueta" + CRLF + "Favor verificar o lote!")
		Return
	Endif

	//Codigo Alternativo
	dbSelectArea("SB1")
	dbSetOrder(1)
	If SB1->(dbSeek(xFilial("SB1")+Alltrim(SC2->C2_PRODUTO)))
		_cCodBar := Subs(SB1->B1_CODBAR, 1, 12)
	EndIf

	If Empty(_cCodBar)
		Alert(" A T E N Ç Ã O " + CRLF + CRLF + ;
		      "Codigo de barra do produto não encontra!" + CRLF +;
		      "Não será empresso a etiqueta" + CRLF + CRLF + ;
			  "Favor incluir codigo de barra no produto" + Alltrim(SC2->C2_PRODUTO))
		Return
	EndIf	
	
	If Len(Alltrim(mv_par04)) >= 11
		_cLote := Subs(mv_par04,1,6)
	Else
		_cLote := Subs(Alltrim(mv_par04),1,6)
	EndIf

	_dVal   := dDataBase + SB1->B1_PRVALID		//Validade( Date )
	_nQtd   := mv_par02							//Quantidade de Etiquetas

	_cLote  := _cLote                         	//Lote
	_cDesc2 := &cCampo							//Descricao
	_cCod   := Alltrim(SB1->B1_COD)				//Codigo
	If Alltrim(mv_par03) != ''
		_cFab := Subs(Alltrim(mv_par03),1,7)
	Else
		_cFab   := Subs(DtoC(dDatabase),4,2) + "-20" + Subs(DtoC(dDatabase),7,2) //Validade( String )
	EndIf
	_cVal   := Subs(DtoC(_dVal),4,2) + "-20" + Subs(DtoC(_dVal),7,2) //Validade( String )
	_cCont	:= RTrim(SB1->B1_U_CONTD)+" "+Lower(IIf(SB1->(FieldPos("B1_U_UMETQ"))>0,RTrim(SB1->B1_U_UMETQ),"XX"))	//Conteudo

	MSCBPRINTER(cModelo, cPorta,,10,.F.,,,,,,.F.,) // conecta na impressora

	ProcRegua(mv_par02)
	For nX := 1 To mv_par02
		IncProc("Processando...")
		MSCBCHKSTATUS(.F.)
		MSCBBEGIN(1,6)            
		If len(_cDesc2) >= 20 .or. len(_cDesc2) <= 24
			MSCBSAY(01.5,13,Alltrim(_cDesc2)        , "B","0","37,38")          //DESCRIÇÃO
		Else
			MSCBSAY(01.5,10,Alltrim(_cDesc2)        , "B","0","37,38")          //DESCRIÇÃO
		EndIf
		//LINHA PRIMEIRA - COLUNA DIREITA - LINHA BAIXO - COLUNA ESQ - LARGURA RISCO
		MSCBLineH(07,68,30,7)// COLUNA ESQUERDA
		MSCBLineH(07,62.5,30,7)// COLUNA DIREITA
			//LINHA cima baixo /tamanho linha/   clu esq        7 = ESPESSURA 
		MSCBLineV(07,                63.7,               59.3,             7)
		MSCBLineV(07,                63,               59.3,             7)
		MSCBSAY(09,63.5,"QUALYVINIL"              , "I","0","30,30")         // TEXTO
		MSCBLineV(28.3,                63.7,               59.3,             7)
		MSCBLineV(28.3,                63,               59.3,             7)
		MSCBSAY(09,37,"COD. " + Alltrim(_cCod)  , "B","0","30,28")         // CODIGO
		MSCBSAY(13,44,"LOTE " + Alltrim(_cLote) , "B","0","30,28")         // LOTE
		MSCBSAY(09,07,"FAB. " + Alltrim(_cFab)  , "B","0","30,28")          // FABRICAÇÃO
		MSCBSAY(13,07,"VAL. " + Alltrim(_cVal)  , "B","0","30,28")          // VALIDADE
		//LINHA PRIMEIRA - COLUNA DIREITA - LINHA BAIXO - COLUNA ESQ - LARGURA RISCO
		MSCBBOX(16        ,2.7              ,29,          20.5        , 7)          
		MSCBSAY(19,07,"CONTEUDO"                , "B","0","20,18")  
		MSCBSAY(23,05, Alltrim(_cCont)          , "B","0","50,50")          // VALOR
		MSCBSAYBAR(16.7,23,_cCodBar,"B","MB04",8.36,.F.,.T.,.F.,,3)	
		MSCBEND()
		
	Next
	MSCBCLOSEPRINTER()

	SB1->(DBCloseArea())
	SC2->(DBCloseArea())

Return

/*
{Protheus.doc} QESTR009()
Grupo de perguntas 
@Author     FABIO BATISTA
@Since      27/05/2020
@Version    P12.25
@Project    Qualy
@Param		 ETIQUETA GENERICA - ZEBRA
@Param		 cBody
@Param		 mv_par01/mv_par02
*/
Static function cPergunt()
	
	u_fsPutSx1(cPerg ,"01", "Produto"              ,'' ,'' ,"MV_C01"	,"C" , 24                      ,0 , ,"G"	,""	,""	,"","","mv_par01","","","","","","","","","","","","","","","","")
	u_fsPutSx1(cPerg ,"02", "Quantidade de Etiq.?" ,'' ,'' ,"MV_C02"	,"N" , 10                      ,0 , ,"G"	,""	,""	,"","","mv_par02","","","","","","","","","","","","","","","","")
	u_fsPutSx1(cPerg ,"03", "Fabricacao"           ,'' ,'' ,"MV_C03"	,"C" , 10                      ,0 , ,"G"	,""	,""	,"","","mv_par03","","","","","","","","","","","","","","","","")
	u_fsPutSx1(cPerg ,"04", "Lote"                 ,'' ,'' ,"MV_C04"	,"C" , 10                      ,0 , ,"G"	,""	,""	,"","","mv_par04","","","","","","","","","","","","","","","","")

return