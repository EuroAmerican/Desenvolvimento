#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"        

#define PAD_LEFT            0
#define PAD_RIGHT           1
#define PAD_CENTER          2

#define ENTER chr(13) + chr(10)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQIPR003   บ Autor ณTiago O. Beraldi    บ Data ณ  16/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณCERTIFICADO DE ANALISE                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function QIPR003()       

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local lOk		 := .T.      

Private cArq     := "" 
Private aArq     := {}

Private cPerg    := "QIPR003"
Private aArea    := GetArea()
Private aDadosC  := {}  //Matriz Cabecalho
Private aDadosI  := {}  //Matriz Itens          
Private nLin     := 150  
Private cErroLaudo := ""  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fontes utilizadas                                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private oFont0   := TFont():New( "Tahoma"            ,,12     ,,.T.,,,,,.F.) 
Private oFont1   := TFont():New( "Tahoma"            ,,10     ,,.F.,,,,,.F.) 
Private oFont2   := TFont():New( "Tahoma"            ,,10     ,,.T.,,,,,.F.) 
Private oFont3   := TFont():New( "Tahoma"            ,,08     ,,.F.,,,,,.F.) 
Private oFont4   := TFont():New( "Tahoma"            ,,08     ,,.T.,,,,,.F.) 

If Select("QRY") > 0          
	QRY->(dbCloseArea())
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica dicionario de perguntas                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//fCriaSX1(cPerg)
ValidPerg(cPerg)
Pergunte(cPerg, .F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Impressao                                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPrint   := PcoPrtIni("Certificado de Anแlise", .F., 2, .T., @lOk, cPerg) 

oProcess := MsNewProcess():New({|lEnd| fQIPR003I(@lEnd, oPrint, oProcess)},"","",.F.)
oProcess :Activate()
		
PcoPrtEnd(oPrint)           

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFQIPR003I บ Autor ณTiago O. Beraldi    บ Data ณ  16/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณIMPRESSAO                                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fQIPR003I(lEnd, oPrint, oProcess)

Local lSave 
Local nLoop

If MsgYesno("Deseja salvar os cert. anแlise?", "Impressใo de Cert. de Anแlise")
	lSave := .T.
Else
	lSave := .F.
EndIf

For nLoop := 1 to Len( Alltrim(mv_par01) ) Step 7

    nLin    := 150
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Processa dados                                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !fDataProc(Subs(mv_par01, nLoop, 6))
		MsgAlert("Parametros invแlidos!")
		Return
	EndIf                                                                    
	          
	//Verifica Validade
 	If CtoD(aDadosC[6]) <= dDataBase
		MsgStop("Lote vencido! Verifique a validade junto ao laborat๓rio.")
	    Return
	EndIf  
        
	oPrint :StartPage()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cabecalho                                                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	fCabec()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Detalhe                                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	fDetalhe()  
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Rodape                                                              ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	fRodape()    

	oPrint :EndPage()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Salva certificado e envia por e-mail para o cliente                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lSave    
	
		//cArq := Lower("L:\laudos\emp_" + AllTrim(cNumEmp) + "_NF_" + AllTrim(mv_par02) + "_LOTE_" + aDadosC[5])
		cArq := Lower("\laudos\emp_" + AllTrim(cNumEmp) + "_NF_" + AllTrim(mv_par02) + "_LOTE_" + aDadosC[5])
	
		oPrint:SaveAllAsJPEG(cArq, 900, nLin/2, 140)         
		  
		If ( SF2->F2_TIPO == "N" ) .And. ( SA1->A1_LAUDO == "S" )
			EnvEmail()
		Else
			MsgStop("Nao foi possivel enviar o laudo referente ao lote " + aDadosC[5] + " por e-mail.")
		EndIf
		
	EndIf

Next nLoop   


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfDetalhe  บ Autor ณTiago O. Beraldi    บ Data ณ  16/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณDETALHE IMPRESSAO                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fDetalhe()
Local i 
       
For i := 1 to Len(aDadosI)
	
	nLin += 75
	oPrint :Say( nLin, 0050, aDadosI[i][1], oFont1,,,, PAD_LEFT)
	oPrint :Say( nLin, 0850, aDadosI[i][2], oFont1,,,, PAD_CENTER) 
	                      
	If aDadosI[i][8] == "2"
		oPrint :Say( nLin, 1450, Iif(!Empty(aDadosI[i][5]), aDadosI[i][5],;
	            "Max. " + aDadosI[i][4]), oFont1,,,, PAD_CENTER)
	ElseIf aDadosI[i][8] == "3"
		oPrint :Say( nLin, 1450, Iif(!Empty(aDadosI[i][5]), aDadosI[i][5],;
	            "Min. " + aDadosI[i][3]), oFont1,,,, PAD_CENTER)
	Else
		oPrint :Say( nLin, 1450, Iif(!Empty(aDadosI[i][5]), aDadosI[i][5],;
                aDadosI[i][3] + " - " + aDadosI[i][4]), oFont1,,,, PAD_CENTER)
    EndIf	
	
	oPrint :Say( nLin, 2100, Iif(!Empty(aDadosI[i][5]), "OK",;
	                          aDadosI[i][7]), oFont1,,,, PAD_CENTER)
	
Next i
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfRodape   บ Autor ณTiago O. Beraldi    บ Data ณ  16/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณRODAPE DE IMPRESSAO                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fRodape()

oPrint :Say( 3000, 1170, " Documento emitido eletronicamente - dispensa assinatura ", oFont4,,,, PAD_CENTER)
oPrint :Say( 3100, 1170, " Euroamerican do Brasil Importa็ใo, Ind๚stria e Com้rcio Ltda." +;
                         " - Av. Antonio Bardella, 789 - Vl. Mแrcia - Jandira - SP", oFont3,,,, PAD_CENTER)
oPrint :Say( 3150, 1170, " Visite nossa pแgina: www.euroamerican.com.br -" +;
                         " PABX: (11)4619-8400 - Fax:(11)4619-8425", oFont3,,,, PAD_CENTER)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfCabec    บ Autor ณTiago O. Beraldi    บ Data ณ  16/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณCABECALHO DE IMPRESSAO                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fCabec()    
  
Local cLogo 	:= "EURO.BMP"
Local nCol		:= 50

oPrint :SayBitmap(nLin, 0050, cLogo, 0470, 0250)                            

nLin += 50                                                                   
oPrint :Say( nLin, 1170, " EUROAMERICAN DO BRASIL ", oFont0,,,, PAD_CENTER)

nLin += 50                                                                   
oPrint :Say( nLin, 1170, " Importa็ใo, Ind๚stria e Com้rcio Ltda ", oFont1,,,, PAD_CENTER)

nLin += 100
oPrint :Say( nLin, 1170, " CERTIFICADO DE ANมLISE ", oFont2,,,, PAD_CENTER)

nLin += 75
oPrint :Box( nLin, 0050, nLin + 3, 2350 ) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Imprime informacoes da NF/OP de acordo com parametros        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
nLin += 50
oPrint :Say( nLin, 0050, " Cliente: ", oFont2,,,, PAD_LEFT)
oPrint :Say( nLin, 0220, aDadosC[1], oFont1,,,, PAD_LEFT)
oPrint :Say( nLin, 1350, " N.F.: ", oFont2,,,, PAD_LEFT)          
oPrint :Say( nLin, 1500, aDadosC[2], oFont1,,,, PAD_LEFT)
oPrint :Say( nLin, 1850, " Ordem Compra: ", oFont2,,,, PAD_LEFT)
oPrint :Say( nLin, 2150, aDadosC[8], oFont1,,,, PAD_LEFT)

nLin += 75
oPrint :Say( nLin, 0050, " Produto: ", oFont2,,,, PAD_LEFT)
oPrint :Say( nLin, 0250, If(empty(cErroLaudo),aDadosC[4],cErroLaudo) , oFont1,,,, PAD_LEFT)
oPrint :Say( nLin, 0850, " Lote: ", oFont2,,,, PAD_LEFT)
oPrint :Say( nLin, 1000, aDadosC[5], oFont1,,,, PAD_LEFT)
oPrint :Say( nLin, 1350, " Fabrica็ใo: ", oFont2,,,, PAD_LEFT)
oPrint :Say( nLin, 1600, aDadosC[3], oFont1,,,, PAD_LEFT)
oPrint :Say( nLin, 1850, " Validade: ", oFont2,,,, PAD_LEFT)    
oPrint :Say( nLin, 2150, aDadosC[6], oFont1,,,, PAD_LEFT)
       
If !Empty(aDadosC[9])
	nLin 	+= 75 
	nCol := 850
	
	oPrint :Say( nLin, 0050, " Fabricante: ", oFont2,,,, PAD_LEFT)
	oPrint :Say( nLin, 0250, aDadosC[9], oFont1,,,, PAD_LEFT)
EndIf	

If mv_par05  > 0

	If MsgYesNo("Deseja imprimir a Quantidade no Laudo?")
		If nCol == 50
			nLin += 75
		EndIf
	
		oPrint :Say( nLin, nCol, " Quantidade: ", oFont2,,,, PAD_LEFT)
		oPrint :Say( nLin, nCol+200, Alltrim(Transform(mv_par05,"@E 999,999,999.99"))+" Kg", oFont1,,,, PAD_LEFT)

	EndIf

EndIf

nLin += 75
oPrint :Box( nLin, 0050, nLin + 3, 2350 )                      

nLin += 50
oPrint :Box( nLin - 20, 0050, nLin + 50, 2350 )                      
oPrint :Say( nLin, 0050, " Observa็๕es: ", oFont4,,,, PAD_LEFT)
oPrint :Say( nLin, 0300, " As embalagens devem ser mantidas bem fechadas" +;
                         " em ambiente ventilado, protegidas de intemp้ries.", oFont3,,,, PAD_LEFT)
nLin += 75
oPrint :Say( nLin, 0050, " Analisado por: ", oFont2,,,, PAD_LEFT)
oPrint :Say( nLin, 0350, aDadosC[7], oFont1,,,, PAD_LEFT)

nLin += 100
oPrint :Say( nLin, 0250, " Anแlises ", oFont2,,,, PAD_CENTER)
oPrint :Say( nLin, 0850, " M้todo ", oFont2,,,, PAD_CENTER)
oPrint :Say( nLin, 1450, " Especifica็๕es", oFont2,,,, PAD_CENTER)
oPrint :Say( nLin, 2100, " Resultados ", oFont2,,,, PAD_CENTER)

nLin += 50
oPrint :Say( nLin, 0250, " Fํsico Quํmica ", oFont2,,,, PAD_CENTER)
oPrint :Say( nLin, 0850, " de Anแlise ", oFont2,,,, PAD_CENTER)

nLin += 75
oPrint :Box( nLin, 0050, nLin + 3, 2350 )                      


Return           

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfDataProc บ Autor ณTiago O. Beraldi    บ Data ณ  16/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณPROCESSA DADOS                                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fDataProc(cLote)    

Local cProduto   := ""
Local cDescr     := ""
Local lRet       := .F.  
Local _dDtEtiq   := CTOD("  /  /  ")   
Local _dDtFabEtq := CTOD("  /  /  ")
Local _cOrdProd  := ""
Local lBloqLau   := SuperGetMv("QE_BLOQLAU",.F.,.T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Dados da NF                                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
aDadosC := {}  //Matriz Cabecalho
aDadosI := {}  //Matriz Itens                   

dbSelectArea("SF2")
dbSetOrder(1)
If !MsSeek(xFilial("SF2") + mv_par02 + mv_par03)
	MsgAlert("NF nใo encontrada!")
	Return .F.
EndIf     

If SF2->F2_TIPO == "B"   
	dbSelectArea("SA2")
	dbSetOrder(1)
	MsSeek(xFilial("SA2") + SF2->F2_CLIENTE + SF2->F2_LOJA)
	
	cCampo := "SA2->A2_NOME"
Else
	dbSelectArea("SA1")
	dbSetOrder(1)
	MsSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA)
	
	cCampo := "SA1->A1_NOME"
	
	If SA1->A1_LAUDO == "N"
		MsgStop("Cliente nใo habilitado para envio de Laudo!")
		Return
	EndIf

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Dados da OP                                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
If mv_par04 == 1                        

	cQry := " UPDATE " + RetSqlName("SC2")
	cQry += " SET    C2_DTETIQ = '" + DtoS(dDataBase) + "' "
	cQry += " WHERE  C2_NUM = '" + cLote + "' AND C2_DTETIQ = ''"
	
	TcSqlExec(cQry)
    
	cQry := " SELECT	MIN(C2_DTETIQ) C2_DTETIQ "
	cQry += " FROM " + RetSqlName("SC2")  
	cQry += " WHERE   D_E_L_E_T_ <> '*' "
	cQry += "         AND C2_NUM = '" + cLote + "' "
    
	TCQUERY cQry NEW ALIAS QRY        
	TcSetField("QRY", "C2_DTETIQ", "D", 8, 0)
	
	If EOF()
		MsgAlert("Lote invแlido. Lote " + cLote + "!")
		Return .F.
	EndIf
	
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Dados da Analise                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
dbSelectArea("SZD")
If mv_par04 == 1
	dbSetOrder(2)                
	If !MsSeek(xFilial("SZD") + cLote)
		MsgAlert("Lote nใo analisado. Lote: " + cLote + "!")
		Return .F.
	EndIf
Else
	dbSetOrder(3)                
	If !MsSeek(xFilial("SZD") + cLote)
		MsgAlert("Lote nใo analisado. Lote: " + cLote + "!")
		Return .F.
	EndIf
EndIf

If cFilAnt == "0200" 

	// Interven็ใo em 06/06/2022 para tratamento de data de fabrica็ใo com a data de validade - Fabio Carneiro
	_cOrdProd  := Posicione("SC2",1,xFilial("SC2")+cLote+"01"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_NUM")

	If Empty(_cOrdProd)  // Se nใo foi encrontada a OP/Lote no C2_ITEM 01 (Produ็ใo), procuro no C2_ITEM 02 (envase)
		_cOrdProd  := Posicione("SC2",1,xFilial("SC2")+cLote+"02"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_NUM")
	Endif

	If !Empty(_cOrdProd)  

		_dDtEtiq   := Posicione("SC2", 1, xFilial("SC2")+SubStr(SZD->ZD_OP,1,6)+"01"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_DTFABR")
		_dDataFab  := Posicione("SC2", 1, xFilial("SC2")+SubStr(SZD->ZD_OP,1,6)+"01"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_DTFABR")    
		_dDataVld  := Posicione("SC2", 1, xFilial("SC2")+SubStr(SZD->ZD_OP,1,6)+"01"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_XDTVALI")    
		_dDtFabEtq := Posicione("SC2", 1, xFilial("SC2")+SubStr(SZD->ZD_OP,1,6)+"01"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_DTFABR")  

		If Empty(_dDataFab)		// Se nใo foi encrontada a OP/Lote no C2_ITEM 01 (Produ็ใo), procuro no C2_ITEM 02 (envase)
			_dDtEtiq   := Posicione("SC2", 1, xFilial("SC2")+SubStr(SZD->ZD_OP,1,6)+"02"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_DTFABR")
			_dDataFab  := Posicione("SC2", 1, xFilial("SC2")+SubStr(SZD->ZD_OP,1,6)+"02"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_DTFABR")    
			_dDataVld  := Posicione("SC2", 1, xFilial("SC2")+SubStr(SZD->ZD_OP,1,6)+"02"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_XDTVALI")    
			_dDtFabEtq := Posicione("SC2", 1, xFilial("SC2")+SubStr(SZD->ZD_OP,1,6)+"02"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_DTFABR")  
		Endif
	
	Else 	

		_dDtEtiq   := Posicione("SC2", 1, xFilial("SC2")+SZD->ZD_OP+Space(TamSX3("C2_ITEMGRD")[1]),"C2_DTFABR")
		_dDataFab  := Posicione("SC2", 1, xFilial("SC2")+SZD->ZD_OP+Space(TamSX3("C2_ITEMGRD")[1]),"C2_DTFABR")    
		_dDataVld  := Posicione("SC2", 1, xFilial("SC2")+SZD->ZD_OP+Space(TamSX3("C2_ITEMGRD")[1]),"C2_XDTVALI")    
		_dDtFabEtq := Posicione("SC2", 1, xFilial("SC2")+SZD->ZD_OP+Space(TamSX3("C2_ITEMGRD")[1]),"C2_DTFABR")    

	EndIf

	If Right(Alltrim(SZD->ZD_PRODUT),5) <> "00000"	// Geronimo 20/07/2023. Segundo instru็ใo da Delma do CQ, se embalagem for caminhใo tanque (codigo de produto termina com 00000), nใo precisa de etiqueta de embalagem
		If Empty(_dDtFabEtq)   
			Help(NIL, NIL, "QIPR003-fDataProc", NIL, OemToAnsi("Este laudo nใo pode ser impresso. Falta a impressใo da etiqueta de embalagem. ")  , 1, 1, NIL, NIL, NIL, NIL, .F., { "Verifique e corrija, caso tenha ocorrido alguma das ocorr๊ncias abaixo:" +ENTER+ OemToAnsi("01-) OP Excluida") +ENTER+ OemToAnsi("02-) Na OP, o campo C2_DTFABR-Data da Fabrica็ใo estแ vazio") +ENTER+ OemToAnsi("03-) A OP foi criada porem o campo C2_ITEM (item da OP) nใo esta com conteudo 01 e nem 02")  })		
			If lBloqLau
				Return .F.
			EndIf
		EndIf 
	EndIf 

EndIf

cProduto := SZD->ZD_PRODUT

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//|Verifica Produto X NF                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
dbSelectArea("SD2")
dbSetOrder(3)
MsSeek(xFilial("SD2") + mv_par02 + mv_par03)
     
dbSelectArea("SB1")
dbSetOrder(1)                                 

If Subs(cProduto, 1, 2) == "MP"
	MsSeek(xFilial("SB1") + cProduto)                 
Else
	MsSeek(xFilial("SB1") + cProduto)
EndIf

dbSelectArea("SD2") 

cPedCom := ""

While !SD2->(EOF()) .And. (SD2->D2_DOC + SD2->D2_SERIE) == (mv_par02 + mv_par03)  

	If Subs(SD2->D2_COD, 1, 3) == Subs(cProduto, 1, 3)
		cProduto := cProduto
	EndIf

	If Subs(cProduto, 1, 2) == "MP"
		bEvalPrd := {|| SD2->D2_COD == cProduto}
	ElseIf	Subs(SD2->D2_COD, 1, 3) == "870"	//Exce็ใo linha 870 ้ envase 470
		bEvalPrd := {|| Subs(cProduto, 1, 3) $ "470#870" .Or. SD2->D2_COD == cProduto }
	Else
		bEvalPrd := {|| Subs(SD2->D2_COD, 1, 3) == Subs(cProduto, 1, 3)}
	EndIf

	// Verifica compatibilidade de Lote x NF Saida
	cQry := " SELECT 	C2_NUM " + ENTER
	cQry += " FROM 		" + RetSqlName("SC2") + " "+ ENTER
	cQry += " WHERE 	D_E_L_E_T_ = '' " + ENTER
	cQry += " 			AND C2_FILIAL = '" + XFILIAL("SC2") + "' " + ENTER
	cQry += " 			AND C2_NUM = '" + cLote + "' " + ENTER
	cQry += " 			AND C2_PRODUTO = '" + SD2->D2_COD + "' " + ENTER
	
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf
	
	TCQUERY cQry NEW ALIAS QRY

    If Eval(bEvalPrd) .And. !QRY->(EOF())
		
		dbSelectArea("SC6")
		dbSetOrder(1)
		MsSeek(SD2->D2_FILIAL + SD2->D2_PEDIDO + SD2->D2_ITEMPV + SD2->D2_COD)
		
		cDescr  := SC6->C6_DESCRI
		cPedCom += Iif(!Empty(cPedCom) .And. !Empty(SC6->C6_PEDCLI), "-", "") + SC6->C6_PEDCLI 
				
    	lRet := .T.            	
    	
    EndIf     
    
   	QRY->(dbCloseArea())
    
	dbSelectArea("SD2")
	dbSkip()
EndDo                  

If !lRet
	cErroLaudo := "Refa็a ou corrija o Laudo. ERRO no Laudo. Produto " + Alltrim(SD2->D2_COD) + ", base " + Alltrim(cProduto) + ", lote " + cLote	//Mensagem para a tela da rotina
	Help(NIL, NIL, "QIPR003-fDataProc", NIL, OemToAnsi("Refa็a ou corrija o Laudo. ERRO no Laudo. Produto " + Alltrim(SD2->D2_COD) + ", base " + Alltrim(cProduto) + ", lote " + cLote)  , 1, 1, NIL, NIL, NIL, NIL, .F., { "Identifique e corrija o erro no laudo."  })	// MsgAlert(cErroLaudo) 
	cErroLaudo := "ERRO no Laudo. Produto " + Alltrim(SD2->D2_COD) + ", base " + Alltrim(cProduto)  // Mensagem que sairแ impressa no laudo
else
	cErroLaudo := ""
EndIf	         

/************************** aDadosC	***********************
1  - Cliente 
2  - NF   
3  - Fabricacao                   
4  - Produto                    
5  - Lote                          
6  - Validade                         
7  - Analisado por       
8  - Pedido de Compra        
9  - Fabricante 
/*********************************************************/                         
dbSelectArea("SZD")
If mv_par04 == 1
	dbSetOrder(2)                
	MsSeek(xFilial("SZD") + cLote)
Else
	dbSetOrder(3)                
    MsSeek(xFilial("SZD") + cLote)
EndIf

//Matriz Vetor Cabecalho
aAdd(aDadosC, Upper(&cCampo))
aAdd(aDadosC, mv_par02)
aAdd(aDadosC, DtoC(_dDataFab) ) // Interven็ใo em 30/05/2022 para tratamento de data de fabrica็ใo com a data de validade - Fabio Carneiro
aAdd(aDadosC, Upper(cDescr))
aAdd(aDadosC, AllTrim(SZD->ZD_LE) + "(" + cLote + ")")
aAdd(aDadosC, DtoC(_dDataVld) ) // Interven็ใo em 30/05/2022 para tratamento de data de fabrica็ใo com a data de validade - Fabio Carneiro
aAdd(aDadosC, Iif(Empty(SZD->ZD_ANALIS), "Thiago Silva", SZD->ZD_ANALIS))
aAdd(aDadosC, cPedCom) 
aAdd(aDadosC, Posicione("SA2", 1, xFilial("SA2") + SZD->ZD_FORN, "A2_NOME"))

If mv_par04 == 1
	cExpr := "SZD->ZD_LOTE"
Else
	cExpr := "SZD->ZD_LI"
EndIf

While ! SZD->(EOF()) .And. TRIM(&cExpr) == cLote 

	If AllTrim(cProduto) != AllTrim(SZD->ZD_PRODUT)
		dbSelectArea("SZD")
		dbSkip()		
		Loop
	EndIf

	/************************** aDadosI	***********************
	1  - Descricao do Ensaio
	2  - Metodo de Analise   
	3  - Lim Inferior                 
	4  - Lim Superior               
	5  - Resultado texto padrao              
	6  - Resultado texto 
	7  - Resultado
	8  - Limite da medida
	/*********************************************************/
    dbSelectArea("QPJ")
    dbSetOrder(2)
    MsSeek(xFilial("QPJ") + SZD->ZD_ENSAIO + AllTrim(cProduto) + Space(15 - Len(AllTrim(cProduto))) + SZD->ZD_ITEM)
                  
    //Impede impressao de Lotes fora da especificacao
    If SZD->ZD_STATUS != "A"
   		MsgStop("O Lote " + SZD->ZD_LOTE + " apresenta item(s) de especifica็ใo reprovados. Impressใo cancelada!")
   		Return .T.
    EndIf
    
    If SZD->ZD_IMPRES != "N" 
		//Matriz Vetor Detalhe
		aAdd(aDadosI,{Posicione("QP1", 1, xFilial("QP1") + SZD->ZD_ENSAIO, "QP1_DESCPO");
	                , Upper(SZD->ZD_METODO);
		            , AllTrim(Transform(SZD->ZD_LINF, "@E 999,999.99"));
		            , AllTrim(Transform(SZD->ZD_LSUP, "@E 999,999.99"));
		            , Upper(AllTrim(SZD->ZD_RTEXTP));
	   	            , Upper(SZD->ZD_RTEXTO);
		            , AllTrim(Transform(SZD->ZD_RNUM, "@E 999,999.99"));
		            , SZD->ZD_LIMITE})
	EndIf

	dbSelectArea("SZD")
	dbSkip()
EndDo                          
                  
If Select("QRY") > 0          
	QRY->(dbCloseArea())
EndIf
   
Return .T.           

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfCriaSX1  บ Autor ณTiago O. Beraldi    บ Data ณ  10/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณDICIONARIO DE PERGUNTAS                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fCriaSX1(cPerg)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//|Declaracao de variaveis                                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cKey := ""
Local aHelpEng := {}
Local aHelpPor := {}
Local aHelpSpa := {}

PutSX1(cPerg,"01","Lotes            ? ","","","mv_ch1","C",35,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"02","Nota Fiscal      ? ","","","mv_ch2","C",09,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"03","S้rie            ? ","","","mv_ch3","C",03,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"04","Tipo             ? ","","","mv_ch4","N",01,0,0,"C","","","","","mv_par04","Prod Acabado","","","","Mat Prima","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"05","Qtde./Kg         ? ","","","mv_ch5","N",07,2,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","")

cKey     := "P." + cPerg + "01."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe os Lotes.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P." + cPerg + "02."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe a Nota Fiscal.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P." + cPerg + "03."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe a S้rie da NF.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)  

cKey     := "P." + cPerg + "04."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe o Tipo de Produto.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P." + cPerg + "05."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe a Quantidade em Kg.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณValidPerg ณ Autor ณ Rodrigo Sousa  		ณ Data ณ 15.08.12  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Parametros da rotina.                					   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidPerg(cPerg)

Local aArea := GetArea()
Local aPerg := {}
Local i 

cPerg := cPerg + Space(3)

Aadd(aPerg, {cPerg, "01", "Lotes		    ?", "MV_CH1" , 	"C", 35	, 0	, "G"	, "MV_PAR01", ""	,""		,""				,""				,"","",0})
Aadd(aPerg, {cPerg, "02", "Nota Fiscal    	?", "MV_CH2" , 	"C", 09	, 0	, "G"	, "MV_PAR02", ""	,""		,""				,""				,"","",0})
Aadd(aPerg, {cPerg, "03", "S้rie 	        ?", "MV_CH3" , 	"C", 03	, 0	, "G"	, "MV_PAR03", ""	,""		,""				,""				,"","",0})
Aadd(aPerg, {cPerg, "04", "Tipo      		?", "MV_CH4" , 	"N", 01	, 0	, "C"	, "MV_PAR04", ""	,"Prod. Acabado"		,"Materia Prima"				,""				,"","",0})
Aadd(aPerg, {cPerg, "05", "Qtde/Kg         	?", "MV_CH5" , 	"N", 12	, 0	, "G"	, "MV_PAR05", ""	,""		,""				,""				,"","",2})

DbSelectArea("SX1")
DbSetOrder(1)

For i := 1 To Len(aPerg)
	IF  !DbSeek(aPerg[i,1]+aPerg[i,2])
		RecLock("SX1",.T.)
	Else
		RecLock("SX1",.F.)
	EndIF
	Replace X1_GRUPO   with aPerg[i,01]
	Replace X1_ORDEM   with aPerg[i,02]
	Replace X1_PERGUNT with aPerg[i,03]
	Replace X1_VARIAVL with aPerg[i,04]
	Replace X1_TIPO	   with aPerg[i,05]
	Replace X1_TAMANHO with aPerg[i,06]
	Replace X1_PRESEL  with aPerg[i,07]
	Replace X1_GSC	   with aPerg[i,08]
	Replace X1_VAR01   with aPerg[i,09]
	Replace X1_F3	   with aPerg[i,10]
	Replace X1_DEF01   with aPerg[i,11]
	Replace X1_DEF02   with aPerg[i,12]
	Replace X1_DEF03   with aPerg[i,13]
	Replace X1_DEF04   with aPerg[i,14]
	Replace X1_DEF05   with aPerg[i,15]
	Replace X1_DECIMAL with aPerg[i,16]
	MsUnlock()
Next i

RestArea(aArea)

Return(.T.)



/*/
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณEnvEmail  ณ Autor ณ                       ณ Data ณ          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ															  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function EnvEmail()  
Local cSrvMail  := AllTrim(GetMV("MV_RELSERV"))
Local cUserAut  := AllTrim(GetMV("MV_RELACNT")) 
Local cPassAut  := AllTrim(GetMV("MV_RELPSW")) 
Local cAuthent	:= AllTrim(GetMV("MV_RELAUTH"))    

Local cDe		:= ""
Local cPara		:= ""
Local cCc		:= ""
Local cCco		:= "cq@euroamerican.com.br"
Local cSubject  := ""
Local cBody		:= ""
Local nX

//+----------------------------------------------------------------------------
//| Define email de remetente 
//+----------------------------------------------------------------------------   

If Left(cFilAnt,2) == "02"
	
	If AllTrim(cFilAnt) $ "00#01#04"
		cDe      := "workflow@euroamerican.com.br"
		cSubject := "Certificado de Analise - EUROAMERICAN"
		
	ElseIf AllTrim(cFilAnt) $ "03"
		cDe      := "workflow@qualyvinil.com.br"
		cSubject := "Certificado de Analise - QUALYVINIL"
		
	EndIf
	
ElseIf Left(cFilAnt,2) == "03"
	
	cDe      := "workflow@qualyvinil.com.br"
	cSubject := "Certificado de Analise - QUALYVINIL"
	
ElseIf Left(cFilAnt,2) == "01"
	
	If AllTrim(cFilAnt) $ "08"
		cDe      := "workflow@qualycor.com.br"
		cSubject := "Certificado de Analise - QUALYCOR"
		
	ElseIf AllTrim(cFilAnt) $ "07"
		cDe      := "workflow@jaystintas.com.br"
		cSubject := "Certificado de Analise - JAYS TINTAS"
		
	EndIf
	
EndIf


//+----------------------------------------------------------------------------
//| Define mensagem de corpo
//+----------------------------------------------------------------------------
cBody := "Prezado Cliente, " + ENTER + ENTER 
cBody += "Segue anexo certificado de analise do seu produto." + ENTER + ENTER 
cBody += "Este e-mail foi enviado automaticamente e nใo deve ser respondido." 


//+----------------------------------------------------------------------------
//| Define anexo 
//+----------------------------------------------------------------------------
cDir := "\Laudos\"
aArq := Directory( cArq + "*.jpg" )

If Len(aArq) <= 0
	Return
EndIf

cAnexo := cDir + aArq[1][1]
For nX := 2 to Len(aArq)
	cAnexo := cAnexo + "#" + cDir + aArq[nX][1]
Next nX

//+----------------------------------------------------------------------------
//| Define email de destino
//+----------------------------------------------------------------------------
cPara := SA1->A1_EMAIL
//cPara := "alexandre.marson@euroamerican.com.br"       

//+----------------------------------------------------------------------------
//| Define objeto de email
//+----------------------------------------------------------------------------
CONNECT SMTP SERVER cSrvMail ACCOUNT cUserAut PASSWORD cPassAut TIMEOUT 60 RESULT lOk

If (lOk)
	
	If cAuthent == ".T."
		MAILAUTH(cUserAut, cPassAut)
	EndIf
	
	SEND MAIL FROM cDe TO cPara ;
	BCC cCco ;
	CC cCc ;
	SUBJECT cSubject ;
	BODY cBody ;  
	ATTACHMENT cAnexo;
	RESULT lOK     
	DISCONNECT SMTP SERVER

	
Endif       

Return 

