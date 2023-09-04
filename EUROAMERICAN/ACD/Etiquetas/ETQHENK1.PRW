#INCLUDE "protheus.ch"
#include "rwmake.ch"   
    
/*/{Protheus.doc} ETIQHENK
//Rotina GERAÇÃO ETIQUETA HENKEL com 5 campos peso liquido
e peso bruto
@author Fabio Batista
@since 03/02/2021
@version 1.0
/*/    
User Function ETQHENK1()

Local cPorta  := "LPT1"
Local cModelo := "ZEBRA"

//AjustSX1()

    If Pergunte("xREST91", .T.)
        If mv_par03 == 0
            nCopias := 1
        Else
            nCopias := mv_par03
        EndIf

        For nX := 1 to nCopias
            MSCBPRINTER(cModelo, cPorta,,10,.F.,,,,,,.F.,)
	        MSCBCHKSTATUS(.F.)
		    MSCBBEGIN(1,6)            

            MSCBSAY(15,147,AllTrim(mv_par01), "B","0","040,040") 
            MSCBSAY(25,147,mv_par02, "B","0","040,040") 
            MSCBSAY(33,147,DTOC(dDataBase), "B","0","040,040")
            MSCBSAY(42,147,DTOC(dDataBase+180), "B","0","040,040")
            
            MSCBEND()   
            MSCBCLOSEPRINTER()    
        Next
    EndIf
