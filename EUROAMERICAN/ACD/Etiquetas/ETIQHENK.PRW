#INCLUDE "protheus.ch"
#include "rwmake.ch"   
    
/*/{Protheus.doc} ETIQHENK
//Rotina GERAÇÃO ETIQUETA HENKEL com 5 campos peso liquido
e peso bruto
@author Fabio Batista
@since 03/02/2021
@version 1.0
/*/    
User Function ETIQHENK()

Local cPorta  := "LPT1"
Local cModelo := "ZEBRA"

//AjustSX1()

    If Pergunte("REST992A", .T.)
        If mv_par06 == 0
            nCopias := 1
        Else
            nCopias := mv_par06
        EndIf

        For nX := 1 to nCopias
            MSCBPRINTER(cModelo, cPorta,,10,.F.,,,,,,.F.,)
	        MSCBCHKSTATUS(.F.)
		    MSCBBEGIN(1,6)            

            MSCBSAY(05,115,AllTrim(mv_par02), "B","0","040,040") 
            MSCBSAY(14,164,AllTrim(mv_par01), "B","0","040,040") 
            MSCBSAY(22,165,mv_par03, "B","0","040,040") 
            MSCBSAY(31,163,DTOC(dDataBase), "B","0","040,040")
            MSCBSAY(38,163,DTOC(dDataBase+180), "B","0","040,040")
            MSCBSAY(47,163,mv_par04, "B","0","040,040")
            MSCBSAY(56,163,mv_par05, "B","0","040,040")
        
            MSCBEND()   
            MSCBCLOSEPRINTER()    
        Next
    EndIf


Static Function AjustSX1()

	Local cAlias   := Alias()
	Local aHelpPor := {}

	
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o local de impressão")
	aAdd(aHelpPor, "das etiquetas")
	U_FATUSX1("REST992A","01","Local de impressão ?","Local de impressão ?","Local de impressão ?","MV_CH1","C",6,0,0,"G",'ExistCpo("CB5")',"MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","CB5","","","","","", aHelpPor, aHelpPor, aHelpPor)

	aHelpPor := {}
	aAdd(aHelpPor, "Imprime Descricao e IDH Henkel")
	U_FATUSX1("REST992A","02","Imprime Descricao Henkel?","Imprime Descricao Henkel?","Imprime Descricao Henkel?","MV_CH2","N",1,0,0,"C",'',"MV_PAR02","Sim","Sim","Sim","","Nï¿½o","Nï¿½o","Nï¿½o","","Produto","Produto","Produto","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	aHelpPor := {}
	aAdd(aHelpPor, "Descricao Henkel")
	U_FATUSX1("REST992A","03","Descricao","Descricao","Descricao","MV_CH3","C",80,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	aHelpPor := {}
	aAdd(aHelpPor, "IDH Henkel")
	U_FATUSX1("REST992A","04","IDH","IDH","IDH","MV_CH4","C",20,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	aHelpPor := {}
	aAdd(aHelpPor, "Nr. copias")
	U_FATUSX1("REST992A","05","Nr. copias","Nr. copias","Nr. copias","MV_CH5","N",3,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	DbSelectArea(cAlias)

Return
