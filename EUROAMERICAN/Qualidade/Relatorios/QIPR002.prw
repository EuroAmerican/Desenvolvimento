#include "protheus.ch"
#include "topconn.ch"        
#include "tbiconn.ch"   
#include "rwmake.ch"    
#include "colors.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQIPR002   บ Autor ณTiago O. Beraldi    บ Data ณ  01/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณIMPRESSAO DE FICHAS DE EMERGENCIA                           บฑฑ
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
User Function QIPR002()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nPage    := 1     

Private oPrn  
Private nLin     := 10000

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//| Fontes do Relatorio                                                 | 
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oFont16n := TFont():New( "Arial",,18,,.t.,,,,,.f.)
oFont13n := TFont():New( "Arial",,13,,.t.,,,,,.f.)
oFont12n := TFont():New( "Arial",,12,,.t.,,,,,.f.)
oFont12  := TFont():New( "Arial",,12,,.f.,,,,,.f.)
oFont10  := TFont():New( "Arial",,10,,.f.,,,,,.f.)
oFont08n := TFont():New( "Arial",,08,,.t.,,,,,.f.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//| Inicio da Impressao                                                 | 
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPrn:= TMSPrinter():New()      

oPrn:Say(0020, 0020, " "                 , oFont16n)    
oPrn:Box(0020, 0100, 0023, 2300 )
oPrn:Say(0100, 1200,"FICHA DE EMERGสNCIA", oFont16n,,,,2)    

cLogo := Iif(Left(cFilAnt,2) == "02", "logoeuro.bmp", Iif(Left(cFilAnt,2) == "03", "logoqual.bmp", "logoqcor.bmp"))

If Left(cFilAnt,2) == "02"
	oPrn:SayBitmap(0100, 0250, "logoeuro.bmp", 0340, 0210,,,,2)    
	oPrn:Say( 0350, 0420, "EUROAMERICAN DO BRASIL IMP IND E COM LTDA.", oFont08n,,,,2)
	oPrn:Say( 0400, 0420, "Av. Antonio Bardella, 789 ", oFont10,,,,2)
	oPrn:Say( 0430, 0420, "Jardim Sใo Luis - Jandira - SP", oFont10,,,,2)
	oPrn:Say( 0460, 0420, "Fone:(11)4619-8400   Fax:(11)4619-8409", oFont08n,,,,2)
ElseIf Left(cFilAnt,2) == "03"
	oPrn:SayBitmap(0100, 0250, "logoqual.bmp", 0340, 0210,,,,2)    
	oPrn:Say( 0350, 0420, "QUALYVINIL COMERCIAL LTDA.", oFont08n,,,,2)
	oPrn:Say( 0400, 0420, "Av. Antonio Bardela, 811", oFont10,,,,2)
	oPrn:Say( 0430, 0420, "Jardim Sใo Luis - Jandira - SP", oFont10,,,,2)
	oPrn:Say( 0460, 0420, "Fone:(11)4772-4600   Fax:(11)3675-5607", oFont08n,,,,2)    
ElseIf Left(cFilAnt,2) == "06"
	oPrn:SayBitmap(0100, 0250, "logometr.bmp", 0340, 0210,,,,2)    
	oPrn:Say( 0350, 0420, "METROPOLE COM, IMP E EXP LTDA.", oFont08n,,,,2)
	oPrn:Say( 0400, 0420, "Av Alberto de Oliveira Santos, 59 - SL 102", oFont10,,,,2)
	oPrn:Say( 0430, 0420, "Centro - Vit๓ria - ES", oFont10,,,,2)
	oPrn:Say( 0460, 0420, "Fone:(27)3026-1849 / 3211-1848", oFont08n,,,,2)	
ElseIF Left(cFilAnt,2) == "01" .and. cFilAnt <> '06'
	oPrn:SayBitmap(0100, 0250, "logoqcor.bmp", 0340, 0210,,,,2)    
	oPrn:Say( 0350, 0420, "QUALYCOR COMERCIAL LTDA.", oFont08n,,,,2)
	oPrn:Say( 0400, 0420, "Rua Nova Prata (Cinco/Perobas), 50 SL10", oFont10,,,,2)
	oPrn:Say( 0430, 0420, "Cincใo - Contagem - MG", oFont10,,,,2)
	oPrn:Say( 0460, 0420, "Fone:(31)3391-9620  / 0800-109972", oFont08n,,,,2)
ElseIF Left(cFilAnt,2) == "08"
	oPrn:SayBitmap(0100, 0250, "logoqual.bmp", 0340, 0210,,,,2)    
	oPrn:Say( 0350, 0420, "QUALYCRIL SOLUCOES PARA A CONSTRUCAO CIVIL LTDA", oFont08n,,,,2)
	oPrn:Say( 0400, 0420, "Av. Antonio Bardela, 765", oFont10,,,,2)
	oPrn:Say( 0430, 0420, "Jardim Sใo Luis - Jandira - SP", oFont10,,,,2)
	oPrn:Say( 0460, 0420, "Fone:(11)4772-4600   Fax:(11)3675-5607", oFont08n,,,,2)   
ElseIF Left(cFilAnt,2) == "09"
	//oPrn:SayBitmap(0100, 0250, "logoqual.bmp", 0340, 0210,,,,2)    
	oPrn:Say( 0350, 0420, "PHOENIX QUIMICA DO BRASIL LTDA", oFont08n,,,,2)
	oPrn:Say( 0400, 0420, "Av.Carolina Geretto DellAcqua, 500", oFont10,,,,2)
	oPrn:Say( 0430, 0420, "Centro - Ibitinga - SP", oFont10,,,,2)
	//oPrn:Say( 0460, 0420, "Fone:(11)4772-4600   Fax:(11)3675-5607", oFont08n,,,,2)   
Else
	//oPrn:SayBitmap(0100, 0250, "logodnt.bmp", 0340, 0210,,,,2)    
	oPrn:Say( 0350, 0420, "DNT Distribuicao Nacional de Tintas.", oFont08n,,,,2)
	oPrn:Say( 0400, 0420, "Rua Alziro e Oliveira , 101", oFont10,,,,2)
	oPrn:Say( 0430, 0420, "Jardim Morumbi - Braganca Paulista - SP", oFont10,,,,2)
	oPrn:Say( 0460, 0420, "Fone: 99946-9500 ", oFont08n,,,,2)
	
EndIf                                                      

oPrn:Say( 0500, 0420, "TELEFONES DE EMERGสNCIA:", oFont12n,,,,2)
oPrn:Say( 0540, 0420, "SUATRANS COTEC: 0800 707 7022", oFont12n,,,,2)
oPrn:Say( 0580, 0420, "BOMBEIROS: 193", oFont12n,,,,2)
 
dbSelectArea("SZ6")

oPrn:Say(0190, 1200, "Nome apropriado para o embarque", oFont13n,,,,2)      
                                                      
cTexto := Upper(Alltrim(SZ6->Z6_NOME2))
                              
If Len(cTexto) > 40
	nSubs := QuebraTexto(cTexto)
	oPrn:Say(0240, 1200, Subs(cTexto, 1, nSubs) , oFont13n,,,,2) 
	oPrn:Say(0290, 1200, Subs(cTexto, nSubs, Len(cTexto))   , oFont13n,,,,2) 
Else
	oPrn:Say(0240, 1200, cTexto   , oFont13n,,,,2) 
EndIf

oPrn:Say(0340, 1200, "Nome Comercial"     , oFont13n ,,,,2) 

cTexto := Upper(Alltrim(SZ6->Z6_NOME))
                              
If Len(cTexto) > 40
	nSubs := QuebraTexto(cTexto)
	oPrn:Say(0390, 1200, Subs(cTexto, 1, nSubs) , oFont13n,,,,2) 
	oPrn:Say(0440, 1200, Subs(cTexto, nSubs, Len(cTexto))   , oFont13n,,,,2) 
Else
	oPrn:Say(0390, 1200, cTexto, oFont13n ,,,,2) 
EndIf            

If Empty( SZ6->Z6_NUMRISC )
	oPrn:Say(0200, 1700, "PRODUTO NรO ENQUADRADO", oFont12n  )   
	oPrn:Say(0250, 1700, "NA PORTARIA EM VIGOR", oFont12n  ) 
	oPrn:Say(0300, 1700, "SOBRE TRANSPORTE DE", oFont12n  ) 	
	oPrn:Say(0350, 1700, "PRODUTOS PERIGOSOS", oFont12n  )
Else
	oPrn:Say(0500, 1400, "N๚mero do Risco: " , oFont12  ) 
	oPrn:Say(0500, 2100, SZ6->Z6_NUMRISC     , oFont12n ) 
	oPrn:Say(0550, 1400, "N๚mero da ONU: "   , oFont12  ) 
	oPrn:Say(0550, 2100, SZ6->Z6_ONU         , oFont12n ) 	
	oPrn:Say(0600, 1400, "Classe ou subclasse de risco: "             , oFont12 ) 
	oPrn:Say(0600, 2100, SZ6->Z6_CLSUBCL                              , oFont12n)  
	oPrn:Say(0650, 1400, "Descri็ใo da classe ou subclasse de risco: ", oFont12 ) 
	oPrn:Say(0700, 1400, SZ6->Z6_DESC                                 , oFont12n) 
	oPrn:Say(0750, 1400, "Grupo de Embalagem: "                       , oFont12 ) 
	oPrn:Say(0750, 2100, SZ6->Z6_GRPEMB                               , oFont12n) 
EndIf
	
oPrn:Box(0810, 0100, 0813, 2300)    

nLin := 850
nCol := 94  

oPrn:Say(nLin, 0100, "Aspecto: ", oFont12n) 

For nn := 1 To MlCount(SZ6->Z6_ASPECTO, nCol)
	cText := Memoline(SZ6->Z6_ASPECTO, nCol, nn)
	oPrn:Say(nLin, 0420, cText, oFont12)
	nLin += 45
Next 

nLin += 20
 
oPrn:Say(nLin, 0100, "EPI: ", oFont12n) 
                                         
oPrn:Say(nLin, 0420, "EPI de uso exclusivo da equipe de atendimento a emerg๊ncia.", oFont12n)
nLin += 45

For nn := 1 To MlCount(SZ6->Z6_EPI, nCol)
	cText := Memoline(SZ6->Z6_EPI, nCol, nn)
	oPrn:Say(nLin, 0420, cText, oFont12)
	nLin += 45
Next 

nLin += 20
oPrn:Box(nLin, 0100, nLin + 3, 2300)
nLin += 20

oPrn:Say(nLin, 1000, "RISCOS", oFont16n) 

nLin += 70
oPrn:Box(nLin, 0100, nLin + 3, 2300)
nLin += 20                 

oPrn:Say(nLin, 0100, "Fogo: ", oFont12n) 

For nn := 1 To MlCount(SZ6->Z6_RISC_FO, nCol)
	cText := Memoline( SZ6->Z6_RISC_FO, nCol, nn)
	oPrn:Say(nLin, 0420, cText, oFont12)
	nLin += 45
Next 
          
nLin += 20

oPrn:Say(nLin, 0100, "Sa๚de: ", oFont12n) 

For nn := 1 To MlCount(SZ6->Z6_RISC_SA, nCol)
	cText := Memoline(SZ6->Z6_RISC_SA, nCol, nn)
	oPrn:Say(nLin, 0420, cText, oFont12)
	nLin += 45
Next 

nLin += 20

oPrn:Say(nLin, 0100, "Meio ambiente: ", oFont12n) 

For nn := 1 To MlCount(SZ6->Z6_RISC_ME, nCol)
	cText := Memoline(SZ6->Z6_RISC_ME, nCol, nn)
	oPrn:Say(nLin, 0420, cText, oFont12)
	nLin += 45
Next 

nLin += 20
oPrn:Box(nLin, 0100, nLin + 3, 2300)
nLin += 20

oPrn:Say(nLin, 0850, "EM CASO DE ACIDENTE", oFont16n) 

nLin += 70
oPrn:Box(nLin, 0100, nLin + 3, 2300)
nLin += 20                 

oPrn:Say(nLin, 0100, "Vazamento: ", oFont12n) 
For nn := 1 To MlCount(SZ6->Z6_ACID_VA, nCol)
	cText := Memoline(SZ6->Z6_ACID_VA, nCol, nn)
	oPrn:Say(nLin, 0420, cText, oFont12)
	nLin += 45
Next 

nLin += 20

oPrn:Say(nLin, 0100, "Fogo: ", oFont12n) 
For nn := 1 To MlCount(SZ6->Z6_ACID_FO, nCol)
	cText := Memoline(SZ6->Z6_ACID_FO, nCol, nn)
	oPrn:Say(nLin, 0420, cText, oFont12)
	nLin += 45
Next 

nLin += 20

oPrn:Say(nLin, 0100, "Polui็ใo: ", oFont12n) 

For nn := 1 To MlCount(SZ6->Z6_ACID_PO, nCol)
	cText := Memoline( SZ6->Z6_ACID_PO, nCol, nn)
	oPrn:Say(nLin, 0420, cText, oFont12)
	nLin += 45
Next          

nLin += 20
oPrn:Say(nLin, 0100, "Envolvimento", oFont12n) 
nLin += 50
oPrn:Say(nLin, 0100 ,"de pessoas: ", oFont12n) 

For nn := 1 To MlCount(SZ6->Z6_ACID_PE, nCol)
	cText := Memoline(SZ6->Z6_ACID_PE, nCol, nn)
	oPrn:Say(nLin, 0420, cText, oFont12)
	nLin += 45
Next 

nLin += 20         

oPrn:Say(nLin, 0100, "Informa็๕es", oFont12n) 
nLin += 50
oPrn:Say(nLin, 0100, "ao m้dico: ", oFont12n) 

For nn := 1 To MlCount(SZ6->Z6_ACID_ME, nCol)
	cText := Memoline(SZ6->Z6_ACID_ME, nCol, nn)
	oPrn:Say(nLin, 0420, cText, oFont12)
	nLin += 45
Next 

nLin += 20

oPrn:Say(nLin, 0100, "Observa็๕es: ", oFont12n) 

For nn := 1 To MlCount(SZ6->Z6_OBS, nCol)
	cText := Memoline(SZ6->Z6_OBS, nCol, nn)
	oPrn:Say(nLin, 0420, cText, oFont12)
	nLin += 45
Next 

oPrn:Setup()   // Configurar impressora
oPrn:Preview() // Visualiza relatorio na tela

MS_FLUSH()

Return     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQIPR002   บ Autor ณTiago O. Beraldi    บ Data ณ  01/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณQUEBRA O TEXTO PARA IMPRESSAO                               บฑฑ
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
Static Function QuebraTexto(cTexto)

For i := 30 to Len(cTexto)
	If Subs(cTexto, i, 1) == " "
		nPos := i
		Exit
	EndIf
Next i

Return nPos  
