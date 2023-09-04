#Include "Protheus.ch"  
/*/{Protheus.doc} FC010BOL
//O ponto de entrada FC010BTN permite a exibição e acionamento de um botão customizado na tela de consulta da posição de clientes.
@author emerson paiva
@since 27/03/2018
@version 1.0
/*/
User Function FC010BTN()

Local aPosObj1  := {} 
Local oScrPanel
Local aSize     := MsAdvSize( .F. )
Local oDlg

If Paramixb[1] == 1// Deve retornar o nome a ser exibido no botão

Return "Histórico"

ElseIf Paramixb[1] == 2// Deve retornar a mensagem do botão

Return "Histórico Cliente em outras empresas!"

Else            

aObjects := {} 
AAdd( aObjects, { 100, 35,  .t., .f., .t. } )
AAdd( aObjects, { 100, 100 , .t., .t. } )
AAdd( aObjects, { 100, 50 , .t., .f. } )
	
aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
aPosObj1 := MsObjSize( aInfo, aObjects) 

DEFINE FONT oBold    NAME "Arial" SIZE 0, -12 BOLD
DEFINE MSDIALOG oDlg FROM	aSize[7],0 TO aSize[6],aSize[5] TITLE cCadastro OF oMainWnd PIXEL
@ aPosObj1[1,1], aPosObj1[1,2] MSPANEL oScrPanel PROMPT "" SIZE aPosObj1[1,3],aPosObj1[1,4] OF oDlg LOWERED
@ 04,004 SAY OemToAnsi("Codigo") SIZE 025,07          OF oScrPanel PIXEL //"Codigo"
@ 12,004 SAY SA1->A1_COD  SIZE 060,09  OF oScrPanel PIXEL FONT oBold
@ 04,067 SAY OemToAnsi("Loja") SIZE 020,07          OF oScrPanel PIXEL //"Loja"
@ 12,067 SAY SA1->A1_LOJA SIZE 021,09 OF oScrPanel PIXEL FONT oBold
@ 04,090 SAY OemToAnsi("Nome") SIZE 025,07 OF oScrPanel PIXEL //"Nome"
@ 12,090 SAY SA1->A1_NOME SIZE 165,09 OF oScrPanel PIXEL FONT oBold

DEFINE SBUTTON 		FROM 04,aPosObj1[1,3]-60 TYPE  1  ENABLE OF oScrPanel ACTION ( oDlg:End() )
		
TButton():New(19, aPosObj1[1,3]-60,'Venc. TXT',oScrPanel,{|| U_FINC001({"SA1->A1_COD", "SA1->A1_COND","SA1->A1_LOJA"}, 8) },26,10,,,,.T.) 	 

/*

Grupo Empresa - Ajuste realizado em 04.09.20 (CG)

//If cEmpAnt + cFilAnt $ "0304#0200#0801#0803#0901"		
//	TButton():New(19, aPosObj1[1,3]-90,'Baixados' ,oScrPanel,{|| U_FINC001({"SA1->A1_COD", "SA1->A1_COND","SA1->A1_LOJA"}, 17) },26,10,,,,.T.) 			
//EndIf
//If cEmpAnt + cFilAnt $ "0304#0200#0801#0803#0901"		//Inclusão 22/04/16
//	TButton():New(19, aPosObj1[1,3]-120,'Em aberto' ,oScrPanel,{|| U_FINC001({"SA1->A1_COD", "SA1->A1_COND","SA1->A1_LOJA"}, 23) },26,10,,,,.T.) 			
//EndIf
*/
  
If AllTrim(cFilAnt) $ "0304#0200#0801#0803#0901"		
	TButton():New(19, aPosObj1[1,3]-90,'Baixados' ,oScrPanel,{|| U_FINC001({"SA1->A1_COD", "SA1->A1_COND","SA1->A1_LOJA"}, 17) },26,10,,,,.T.) 			
EndIf

If AllTrim(cFilAnt) $ "0304#0200#0801#0803#0901"		//Inclusão 22/04/16
	TButton():New(19, aPosObj1[1,3]-120,'Em aberto' ,oScrPanel,{|| U_FINC001({"SA1->A1_COD", "SA1->A1_COND","SA1->A1_LOJA"}, 23) },26,10,,,,.T.) 			
EndIf

DEFINE SBUTTON oBtn 	FROM 19,aPosObj1[1,3]-30 TYPE 15 ENABLE OF oScrPanel
//oBtn:bAction := bVisual
ACTIVATE MSDIALOG oDlg

Return Nil 

Endif 