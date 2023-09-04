#include "protheus.ch"
#include "topconn.ch"        
#include "tbiconn.ch"   
#include "rwmake.ch"    

/*
{Protheus.doc} QESTR009()
Processa a função Qestr001
@Author     FABIO BATISTA
@Since      27/05/2020
@Version    P12.25
@Project    Qualy
@Param		ETIQUETA GENERICA - ZEBRA
@Param		 
@Param		 
*/
User Function QESTR009()        

Processa( {||Qestr001() }, "Aguarde...", "Imprimindo etiquetas...",.F.)

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
Static Function Qestr001()                                 

Local cPorta  := "LPT1"
Local cModelo := "ZEBRA"
Local nX  	  := 0
Local nQtd    :=  0

Private cPerg := "QESTR009"   

If .Not. Pergunte(cPerg,.T.)
	Return
Endif                       

// qtd de etiquetas a serem impressos
nQtd := mv_par02-mv_par01 

	MSCBPRINTER(cModelo, cPorta,,10,.F.,,,,,,.F.,)
	MSCBCHKSTATUS(.F.)

	//ASORT(aVetor)   
	ProcRegua(nQtd)
	For nX := mv_par01 To mv_par02
		IncProc("Processando...")	
		MSCBBEGIN(1,6)            
		MSCBSAY(05,10,cValtochar(nX), "B","0","250,150")
		MSCBEND()
		Sleep(1000)
	Next nX
	MSCBCLOSEPRINTER()
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
	
	u_fsPutSx1(cPerg ,"01", "De numeração ? " ,'' ,'' ,"MV_C01"	,"N" , 24 ,0 , ,"G"	,""	,""	,"","","mv_par01","","","","","","","","","","","","","","","","")
	u_fsPutSx1(cPerg ,"02", "Até numeração ?" ,'' ,'' ,"MV_C02"	,"N" , 10 ,0 , ,"G"	,""	,""	,"","","mv_par02","","","","","","","","","","","","","","","","")

return