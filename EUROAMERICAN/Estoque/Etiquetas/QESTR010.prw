#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH" 

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
User Function QESTR010()        

Processa( {||Qestr001() }, "Aguarde...", "Imprimindo etiquetas...",.F.)

Return 

/*
{Protheus.doc} QESTR009()
Emissão de ETIQUETA TEXTO LIVRE - ZEBRA
@Author     FABIO BATISTA
@Since      27/05/2020
@Version    P12.25
@Project    Qualy
@Param		 ETIQUETA GENERICA - ZEBRA
@Param		 cBody
@Param		 mv_par01/mv_par02
*/
Static function Qestr001()

Local cPorta  := "LPT1"
Local cModelo := "ZEBRA"
Local nX      := 0

Private cPerg   := "QESTR010"

	cPergunt()
	if ! Pergunte(cPerg, .T.)
		Return nil
	endif     
 
	MSCBPRINTER(cModelo, cPorta,,10,.F.,,,,,,.F.,)
		
	mv_par01 := alltrim(mv_par01)	
	ProcRegua(mv_par02)
	For nX := 1 To mv_par02
		IncProc("Processando...")
		MSCBCHKSTATUS(.F.)
		MSCBBEGIN(1,6)
		If len(mv_par01) >= 14
			MSCBSAY(10,04,mv_par01, "B","0","095,070")
		ElseIF  len(mv_par01) == 12 .or. len(mv_par01) == 13
			MSCBSAY(10,06,mv_par01, "B","0","100,070")
		ElseIF  len(mv_par01) == 10 .or. len(mv_par01) == 11
			MSCBSAY(10,10,mv_par01, "B","0","105,072")
		ElseIF  len(mv_par01) == 09 .or. len(mv_par01) == 08
			MSCBSAY(10,04,mv_par01, "B","0","130,100")	
		ElseIf  len(mv_par01) == 07 .or. len(mv_par01) == 06
			MSCBSAY(10,15,mv_par01, "B","0","130,100")	
		Else
		  len(mv_par01) == 05 .or. len(mv_par01) == 04
		  MSCBSAY(10,20,mv_par01, "B","0","140,100")	
		EndIf
		MSCBEND()		
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
	
	u_fsPutSx1(cPerg ,"01", "Texto ?"              ,'' ,'' ,"MV_C01"	,"C" , 24                      ,0 , ,"G"	,""	,""	,"","","mv_par01","","","","","","","","","","","","","","","","")
	u_fsPutSx1(cPerg ,"02", "Quantidade de Etiq.?" ,'' ,'' ,"MV_C02"	,"N" , 10                      ,0 , ,"G"	,""	,""	,"","","mv_par02","","","","","","","","","","","","","","","","")

return