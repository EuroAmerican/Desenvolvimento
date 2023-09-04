#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#include "protheus.ch"  

#define ENTER chr(13) + chr(10)
#define CTRL chr(13) + chr(10)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ QIPX002  บ Autor ณTiago O. Beraldi    บ Data ณ  25/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ ANALISE DE PRODUCAO E ENTRADAS                             บฑฑ
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
User Function QIPX002()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cAlias    := "SZD"
Private cCadastro := "Anแlise de Produ็ใo e Entradas"
Private aCores    := {}
Private aRotina   := {}
Private oGet
Private oDlg
Private nUsado    := 0
Private nCntFor   := 0
Private nOpcA     := 0
Private aObjects  := {}
Private aPosObj   := {}
Private aSizeAut  := MsAdvSize()
Private aHeader   := {}
Private aCols     := {}
Private aGets     := {}
Private aTela     := {}   
Private lExibeReal:= SuperGetMv("MV_REALSZD",,.T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Menu                                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd( aRotina, {"Pesquisar"   	,"AxPesqui"   ,0,1})
aAdd( aRotina, {"Visualizar"  	,"U_QIPX002V" ,0,2})
aAdd( aRotina, {"Lote &PA"    	,"U_QIPX002I" ,0,3})
aAdd( aRotina, {"Alterar"     	,"U_QIPX002A" ,0,4})
aAdd( aRotina, {"Excluir"     	,"U_QIPX002E" ,0,5})
aAdd( aRotina, {"Lote &MP"    	,"U_QIPX002M" ,0,3})
aAdd( aRotina, {"Revalida็ใo" 	,"U_QIPX002R" ,0,2})
aAdd( aRotina, {"Legenda"     	,"U_QIPX002L" ,0,2})          
aAdd( aRotina, {"Conhecimento"	,"MsDocument" ,0,4})    
aAdd( aRotina, {"Configurar"	,"U_QIPX002C" ,0,4})  
aAdd( aRotina, {"Acerta Dta Fab./Val.","U_QEMNTQIP" ,0,2})

dbSelectArea(cAlias)
dbSetOrder(2)
dbGoTop()

aAdd(aCores,{"ZD_STATUS == 'R'","DISABLE"})
aAdd(aCores,{"ZD_STATUS == 'A'","ENABLE"})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao de Acessos                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

dbSelectArea("SZD")
Set Filter to 
	
mBrowse(06,01,22,75,"SZD",,,,,,aCores)

dbSelectArea("SZD")
dbSetOrder(2)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ QIPX002V บ Autor ณTiago O. Beraldi    บ Data ณ  25/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ ANALISE DE PRODUCAO - VISUALIZACAO                         บฑฑ
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
User Function QIPX002V(cAlias, nReg, nOpcX)

Local cLote   := SZD->ZD_LOTE  
Local cLoteI  := SZD->ZD_LI
Local cLoteE  := SZD->ZD_LE                                                                                        

Private aEnchoice := {"ZD_CODANAL", "ZD_ANALIS", "ZD_DTATU", "ZD_LOTE", "ZD_PRODUT", "ZD_DESCRI", "ZD_LI", "ZD_LE", "ZD_DTFABR", "ZD_FORN"}
Private oGet
Private oDlg
Private nUsado    := 0
Private nCntFor   := 0
Private nOpcA     := 0
Private aObjects  := {}
Private aPosObj   := {}
Private aSizeAut  := MsAdvSize()
Private aHeader   := {}
Private aCols     := {}
Private aGets     := {}
Private aTela     := {} 
Private aButtons  := {}

dbSelectArea("SZD") 
nFields := FCount()
dbSetOrder(2)
dbSeek(xFilial("SZD") + cLote + cLoteI)
For nCntFor := 1 To nFields  
	M->&(FieldName(nCntFor)) := CriaVar(FieldName(nCntFor))  
	M->&(FieldName(nCntFor)) := SZD->&(FieldName(nCntFor))
Next nCntFor

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAlias)
While !EOF() .And. X3_ARQUIVO == cAlias 

    If !lExibeReal .And. ( AllTrim(X3_CAMPO) == "ZD_RNUMR" .Or. AllTrim(X3_CAMPO) == "ZD_TEXTOR" )
		dbSelectArea("SX3")
		dbSkip()
		Loop
	EndIf		
	
	If X3Uso(X3_USADO) .And. X3_NIVEL > 0 
		nUsado++
		aAdd(aHeader,{ TRIM(X3Titulo()) ,;
		X3_CAMPO         ,;
		X3_PICTURE       ,;
		X3_TAMANHO       ,;
		X3_DECIMAL       ,;
		X3_VALID         ,;
		X3_USADO         ,;
		X3_TIPO          ,;
		X3_ARQUIVO       ,;
		X3_CONTEXT       })
	Endif
	dbSelectArea("SX3")
	dbSkip()
EndDo

dbSelectArea(cAlias)
dbSetOrder(2)
dbSeek(xFilial("SZD") + cLote + cLoteI)

While !EOF() .And. SZD->ZD_FILIAL + SZD->ZD_LOTE + SZD->ZD_LE + SZD->ZD_LI == xFilial("SZD") + cLote + cLoteE + cLoteI	                      
	aAdd(aCols,Array(nUsado+1))
	For nCntFor := 1 To nUsado
		If ( aHeader[nCntFor][10] != "V" )
			aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
		Else
			aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
		EndIf
		If ( AllTrim(aHeader[nCntFor][2]) == "ZD_ITEM" )
			aCols[1][nCntFor] := "01"
		EndIf
	Next nCntFor
	aCols[Len(aCols)][Len(aHeader)+1] := .F.
	dbSelectArea(cAlias)
	dbSkip()
EndDo    

dbSelectArea(cAlias)
dbSetOrder(2)
dbSeek(xFilial("SZD") + cLote + cLoteI)

aObjects := {}
aAdd(aObjects, {315,  50, .T., .T.})
aAdd(aObjects, {100, 100, .T., .T.})

aInfo   := {aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 3, 3}
aPosObj := MsObjSize(aInfo, aObjects, .T.)

DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
EnChoice(cAlias, nReg, nOpcx,,,, aEnchoice, aPosObj[1],, 3)
oGet := MSGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcx, "AllwaysTrue", "AllwaysTrue", "+ZD_ITEM", .T.)
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End()},{||oDlg:End()})      

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ QIPX002E บ Autor ณTiago O. Beraldi    บ Data ณ  25/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ ANALISE DE PRODUCAO - EXCLUSAO                             บฑฑ
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
User Function QIPX002E(cAlias, nReg, nOpcX)

Local cLote     := SZD->ZD_LOTE  
Local cLoteI    := SZD->ZD_LI
Local cLoteE    := SZD->ZD_LE

If MsgYesNo("Deseja prosseguir com a dele็ใo?", cCadastro)
	
	dbSelectArea(cAlias)
	dbSetOrder(2)
	dbSeek(xFilial("SZD") + cLote + cLoteI)
	
	While !EOF("SZD") .And. SZD->ZD_LOTE == cLote;
                      .And. SZD->ZD_LE == cLoteE;
                      .And. SZD->ZD_LI == cLoteI	                      
		dbSelectArea("SZD")
		RecLock("SZD",.F.)
			dbDelete()
		SZD->( MsUnLock() )
		dbSkip()
	EndDo
	
EndIf   

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ QIPX002A บ Autor ณTiago O. Beraldi    บ Data ณ  25/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ ANALISE DE PRODUCAO - ALTERACAO                            บฑฑ
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
User Function QIPX002A(cAlias, nReg, nOpcX)

Local cLote   := SZD->ZD_LOTE  
Local cLoteI  := SZD->ZD_LI
Local cLoteE  := SZD->ZD_LE

Private aEnchoice := {"ZD_CODANAL", "ZD_ANALIS", "ZD_DTATU", "ZD_LOTE", "ZD_PRODUT", "ZD_DESCRI", "ZD_LI", "ZD_LE", "ZD_FORN","ZD_DTFABR","ZD_DTVALID"}
Private aEdit     := {"ZD_FORN","ZD_DTFABR","ZD_DTVALID"}
Private oGet
Private oDlg
Private nUsado    := 0
Private nCntFor   := 0
Private nOpcA     := 0
Private aObjects  := {}
Private aPosObj   := {}
Private aSizeAut  := MsAdvSize()
Private aHeader   := {}
Private aCols     := {}
Private aGets     := {}
Private aTela     := {} 
Private aButtons  := {}

dbSelectArea("SZD")
dbSetOrder(2)
dbSeek(xFilial("SZD") + cLote + cLoteI)
For nCntFor := 1 To FCount()  
	M->&(FieldName(nCntFor)) := CriaVar(FieldName(nCntFor))
	M->&(FieldName(nCntFor)) := SZD->&(FieldName(nCntFor))
Next nCntFor
          
dbSetOrder(2)
dbSeek(xFilial("SZD") + cLote + cLoteI)

dbSelectArea("SX3")  
dbSetOrder(1)
dbSeek(cAlias)
While !EOF() .And. X3_ARQUIVO == cAlias  

    If !lExibeReal .And. ( AllTrim(X3_CAMPO) == "ZD_RNUMR" .Or. AllTrim(X3_CAMPO) == "ZD_TEXTOR" )
		dbSelectArea("SX3")
		dbSkip()
		Loop
	EndIf		

	If X3Uso(X3_USADO) .And. X3_NIVEL > 0
		nUsado++
		aAdd(aHeader,{ TRIM(X3Titulo()) ,;
		X3_CAMPO         ,;
		X3_PICTURE       ,;
		X3_TAMANHO       ,;
		X3_DECIMAL       ,;
		X3_VALID         ,;
		X3_USADO         ,;
		X3_TIPO          ,;
		X3_ARQUIVO       ,;
		X3_CONTEXT       })
	Endif
	dbSelectArea("SX3")
	dbSkip()
EndDo

dbSelectArea(cAlias)
dbSetOrder(2)
dbSeek(xFilial("SZD") + cLote + cLoteI)

While !EOF() .And. SZD->ZD_FILIAL + SZD->ZD_LOTE + SZD->ZD_LE + SZD->ZD_LI == xFilial("SZD") + cLote + cLoteE + cLoteI	                      
	aAdd(aCols,Array(nUsado+1))
	For nCntFor := 1 To nUsado
		If ( aHeader[nCntFor][10] != "V" )
			aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
		Else
			aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
		EndIf
		If ( AllTrim(aHeader[nCntFor][2]) == "ZD_ITEM" )
			aCols[1][nCntFor] := "01"
		EndIf
	Next nCntFor
	aCols[Len(aCols)][Len(aHeader)+1] := .F.
	dbSelectArea(cAlias)
	dbSkip()
EndDo    
         
aObjects := {}
aAdd(aObjects, {315,  50, .T., .T.})
aAdd(aObjects, {100, 100, .T., .T.})

aInfo   := {aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 3, 3}
aPosObj := MsObjSize(aInfo, aObjects, .T.)     

DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
EnChoice(cAlias, nReg, nOpcX,,,, aEnchoice, aPosObj[1], aEdit, 3)
oGet := MSGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcx, "AllwaysTrue", "AllwaysTrue", "+ZD_ITEM", .T.)
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,Iif(U_QIPX002OK(),oDlg:End(),nOpcA:=0)},{||oDlg:End()},,@aButtons)

If nOpcA == 1
	QIPX002GR(cAlias)
Endif

dbSelectArea(cAlias)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ QIPX002I บ Autor ณTiago O. Beraldi    บ Data ณ  25/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ ANALISE DE PRODUCAO - INCLUSAO PA                          บฑฑ
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
User Function QIPX002I(cAlias, nReg, nOpcX)

Private cPath     := "\\srv-004\pub\utils\tools\CICMsg.exe srv-004 workflow 123456"    
Private cRet      := ""
Private aButtons  := {}
Private aEnchoice := {"ZD_CODANAL", "ZD_ANALIS", "ZD_OP", "ZD_DTATU", "ZD_LOTE", "ZD_PRODUT", "ZD_DESCRI", "ZD_DTFABR", "ZD_DTVALID", "ZD_LE", "ZD_FORN"}
Private aEdit     := {"ZD_CODANAL", "ZD_OP","ZD_LOTE", "ZD_LE", "ZD_FORN","ZD_DTFABR", "ZD_DTVALID"}
Private oGet
Private oDlg
Private nUsado    := 0
Private nCntFor   := 0
Private nOpcA     := 0
Private aObjects  := {}
Private aPosObj   := {}
Private aSizeAut  := MsAdvSize()
Private aHeader   := {}
Private aCols     := {}
Private aGets     := {}                                                      
Private aTela     := {}   


dbSelectArea("SZD")
dbSetOrder(2)
For nCntFor := 1 To FCount()
	M->&(FieldName(nCntFor)) := CriaVar(FieldName(nCntFor))
Next nCntFor

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SZD")
While !EOF() .And. SX3->X3_ARQUIVO == "SZD"  

    If !lExibeReal .And. ( AllTrim(X3_CAMPO) == "ZD_RNUMR" .Or. AllTrim(X3_CAMPO) == "ZD_TEXTOR" )
		dbSelectArea("SX3")
		dbSkip()
		Loop
	EndIf		

	If X3Uso(SX3->X3_USADO) .And. SX3->X3_NIVEL > 0
		nUsado++
		aAdd(aHeader,{ Trim(X3Titulo()),;
                 		Trim(SX3->X3_CAMPO),;
                		SX3->X3_PICTURE,;
                		SX3->X3_TAMANHO,;
                		SX3->X3_DECIMAL,;
                		SX3->X3_VALID,;
                		SX3->X3_USADO,;
                		SX3->X3_TIPO,;
                		SX3->X3_ARQUIVO,;
                		SX3->X3_CONTEXT } )
	EndIf

	dbSelectArea("SX3")
	dbSkip()
EndDo

aAdd(aCols, Array(nUsado+1))

For nCntFor := 1 To nUsado
	aCols[1][nCntFor] := CriaVar(aHeader[nCntFor][2])
	If ( AllTrim(aHeader[nCntFor][2]) == "ZD_ITEM" )
		aCols[1][nCntFor] := "01"
	EndIf
Next nCntFor     

aCols[Len(aCols)][Len(aHeader)+1] := .F.

aObjects := {}
aAdd(aObjects, {315,  50, .T., .T.})
aAdd(aObjects, {100, 100, .T., .T.})

aInfo   := {aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 3, 3}
aPosObj := MsObjSize(aInfo, aObjects, .T.)     

aAdd( aButtons, {"HISTORIC", {|| Atualiza()}, "Especifica็ใo...", "Especifica็ใo", {|| .T.}})     

DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
EnChoice(cAlias, nReg, nOpcx,,,, aEnchoice, aPosObj[1], aEdit, 3)
oGet := MSGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcx, "AllwaysTrue", "AllwaysTrue", "+ZD_ITEM", .T.)
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,Iif(U_QIPX002OK(), oDlg:End(), nOpcA:=0)},{||oDlg:End()},,@aButtons)

If nOpcA == 1  

	QIPX002GR(cAlias)
                       
	cLote := AllTrim(M->ZD_LOTE)
	dbSelectArea("SC2")
	dbSetOrder(1)
	If dbSeek(xFilial("SC2") + cLote)     
	
		While !SC2->(EOF()) .And. SC2->C2_NUM == cLote  
		    
		    // Posiciona registro de Produto
		    SB1->(dbSetOrder(1))
		    SB1->(dbSeek(xFilial("SB1") + SC2->C2_PRODUTO))
		    
		    // Envia Mensagem para PCP
			cMsg := '"(Anแlise de Produ็ใo - ' + SC2->C2_NUM + '.' + SC2->C2_ITEM + '.' + SC2->C2_SEQUEN + ')' + chr(13) + chr(10) 
			cMsg += 'De: ' + cUserName + chr(13) + chr(10) 
			cMsg += 'PRODUTO: ' + Alltrim(SC2->C2_PRODUTO) + ' - ' + AllTrim(SB1->B1_DESC) + chr(13) + chr(10) 
			cMsg += 'QUANTID: ' + Transform(SC2->C2_QUJE, "@E 999,999,999.99") + ' " ' 
			//WinExec(cPath + Space(1) + U_getUserGp("PCP-X01") + Space(1) + cMsg, 0)
										
			// Avanca para o proximo registro
			SC2->(dbSkip())
			
		EndDo
	
	EndIf    
	
Endif

dbSelectArea(cAlias)

Return      

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ QIPX002M บ Autor ณTiago O. Beraldi    บ Data ณ  25/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ ANALISE DE PRODUCAO - INCLUSAO MP                          บฑฑ
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
User Function QIPX002M(cAlias, nReg, nOpcX)
                  
Private aButtons  := {}
Private aEnchoice := {"ZD_CODANAL", "ZD_ANALIS", "ZD_DTATU", "ZD_LI", "ZD_LE", "ZD_DTFABR", "ZD_DTVALID", "ZD_PRODUT", "ZD_DESCRI", "ZD_FORN"}
Private aEdit     := {"ZD_CODANAL", "ZD_PRODUT","ZD_LE", "ZD_FORN","ZD_DTFABR","ZD_DTVALID"}
Private oGet
Private oDlg
Private nUsado    := 0
Private nCntFor   := 0
Private nOpcA     := 0
Private aObjects  := {}
Private aPosObj   := {}
Private aSizeAut  := MsAdvSize()
Private aHeader   := {}
Private aCols     := {}
Private aGets     := {}
Private aTela     := {} 
                               
dbSelectArea("SZD")
dbSetOrder(2)
For nCntFor := 1 To FCount()
	M->&(FieldName(nCntFor)) := CriaVar(FieldName(nCntFor))
Next nCntFor

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SZD")
While !EOF() .And. SX3->X3_ARQUIVO == "SZD"   

    If !lExibeReal .And. ( AllTrim(X3_CAMPO) == "ZD_RNUMR" .Or. AllTrim(X3_CAMPO) == "ZD_TEXTOR" )
		dbSelectArea("SX3")
		dbSkip()
		Loop
	EndIf		

	If X3Uso(SX3->X3_USADO) .And. SX3->X3_NIVEL > 0 
		nUsado++
		aAdd(aHeader,{ Trim(X3Titulo()),;
                 		Trim(SX3->X3_CAMPO),;
                		SX3->X3_PICTURE,;
                		SX3->X3_TAMANHO,;
                		SX3->X3_DECIMAL,;
                		SX3->X3_VALID,;
                		SX3->X3_USADO,;
                		SX3->X3_TIPO,;
                		SX3->X3_ARQUIVO,;
                		SX3->X3_CONTEXT } )
	EndIf

	dbSelectArea("SX3")
	dbSkip()
EndDo

aAdd(aCols, Array(nUsado+1))

For nCntFor := 1 To nUsado
	aCols[1][nCntFor] := CriaVar(aHeader[nCntFor][2])
	If ( AllTrim(aHeader[nCntFor][2]) == "ZD_ITEM" )
		aCols[1][nCntFor] := "01"
	EndIf
Next nCntFor     

aCols[Len(aCols)][Len(aHeader)+1] := .F.

aObjects := {}
aAdd(aObjects, {315,  50, .T., .T.})
aAdd(aObjects, {100, 100, .T., .T.})

aInfo   := {aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 3, 3}
aPosObj := MsObjSize(aInfo, aObjects, .T.)

aAdd( aButtons, {"HISTORIC", {|| Atualiza()}, "Especifica็ใo...", "Especifica็ใo", {|| .T.}})     

DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

EnChoice(cAlias, nReg, nOpcx,,,, aEnchoice, aPosObj[1],aEdit, 3)
oGet := MSGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcx, "AllwaysTrue", "AllwaysTrue", "+ZD_ITEM", .T.)
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,Iif(U_QIPX002OK(),oDlg:End(),nOpcA:=0)},{||oDlg:End()},,@aButtons)

If nOpcA == 1
	QIPX002GR(cAlias)
Endif

dbSelectArea(cAlias)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ QIPX002GRบ Autor ณTiago O. Beraldi    บ Data ณ  25/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ GRAVACAO                                                   บฑฑ
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
Static Function QIPX002GR(cAlias)

Local cVar     := ""
Local lOk      := .T.
Local cMsg     := ""
Local cQuery   := ""
Local nPos     := aScan(aHeader, {|x|AllTrim(Upper(x[2])) == "ZD_ITEM"})
Local nPosEns  := aScan(aHeader, {|x|AllTrim(Upper(x[2])) == "ZD_ENSAIO"})
Local cProd    := M->ZD_PRODUT 
Local dDataFab := CtoD("  /  /  ")    
Local dDataVld := CtoD("  /  /  ")
Local cLote    := M->ZD_LOTE      
Local cLoteI   := Left(M->ZD_LI, 10)       
Local cLoteE   := M->ZD_LE     
Local cCombo   := M->ZD_ANALIS      
Local cCodAna  := M->ZD_CODANAL    
Local cCodFor  := M->ZD_FORN
Local cCodOP   := M->ZD_OP
Local dAnalise := Iif(Empty(M->ZD_DATA), dDataBase, M->ZD_DATA)
Local aArea    := GetArea()
Local _aLista  := {}
Local _nLista  := 0

// Projeto equaliza็ใo de laudo x etiqueta de embalagem - 12/06/2022 - Fabio Carneiro dos Santos 

If cFilAnt $ "0200"

	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf

	cQuery := "SELECT * FROM "+RetSqlName("PAY")+" AS PAY WITH (NOLOCK) "+CRLF
	cQuery += "WHERE PAY_FILIAL = '"+xFilial("PAY")+"' "+CRLF
	cQuery += " AND PAY_OP = '"+SubStr(M->ZD_OP,1,6)+"01"+"001"+"' "+CRLF
	cQuery += " AND PAY_LOTE = '"+M->ZD_LOTE+"' "+CRLF
	cQuery += " AND PAY_PROD = '"+M->ZD_PRODUT+"' "+CRLF 
	cQuery += " AND PAY.D_E_L_E_T_ = ' ' "+CRLF 
	cQuery += "ORDER BY PAY_LOTE  "+CRLF

	TCQuery cQuery New Alias "TRB1"

	TRB1->(DbGoTop())

	While TRB1->(!Eof())	

		Aadd(_aLista,{PAY_FILIAL,; //01
					  PAY_CTRL,;   //02 
					  PAY_SEQ,;    //03
					  PAY_PROD,;   //04
					  PAY_OP,;     //05 
					  PAY_LOTE,;   //06
					  PAY_DTFAB,;  //07
					  PAY_DTVAL,;  //08
					  PAY_HRREG,;  //09
					  PAY_DTLAUD,; //10
					  PAY_CODANL,; //11
					  PAY_STATUS}) //12

		TRB1->(DbSkip())

	EndDo

	If Len(_aLista) > 0

		For _nLista := 1 To Len(_aLista)

			DbSelectArea("PAY")
			PAY->(DbSetOrder(1)) // PAY_FILIAL+PAY_OP+PAY_PROD+PAY_CTRL
			If PAY->(dbSeek(xFilial("PAY")+_aLista[_nLista][05]+_aLista[_nLista][04]+_aLista[_nLista][02])) 

				RecLock("PAY",.F.)
				PAY->PAY_STATUS := "2"
				PAY->PAY_DTLAUD := dAnalise
				PAY->PAY_CODANL := cCodAna 
				PAY->(MsUnlock())
						
			EndIf

			dDataFab := StoD(_aLista[_nLista][07])   
			dDataVld := StoD(_aLista[_nLista][08])    

		Next _nLista
	
	Else 
					
		DbSelectArea("PAY")
		RecLock("PAY",.T.)
		PAY->PAY_FILIAL := xFilial("PAY")
		PAY->PAY_CTRL   := "000001" 
		PAY->PAY_SEQ    := "001" 
		PAY->PAY_PROD   := SC2->C2_PRODUTO  
		PAY->PAY_OP     := SC2->C2_NUM+"01"+"001"     
		PAY->PAY_LOTE   := SC2->C2_NUM
		PAY->PAY_DTFAB  := dDataBase 
		PAY->PAY_DTVAL  := dDataBase+SB1->B1_PRVALID 
		PAY->PAY_HRREG  := time() 
		PAY->PAY_STATUS := "2"
		PAY->PAY_DTLAUD := dAnalise
		PAY->PAY_CODANL := M->ZD_CODANAL		
		PAY->(MsUnlock())
			
		dDataFab := dDataBase
		dDataVld := dDataBase+SB1->B1_PRVALID

	EndIf

	If Empty(Posicione("SC2", 1, xFilial("SC2")+Substr(M->ZD_OP,1,6)+"01"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_DTFABR"))  
					
		cQry := " UPDATE " + RetSqlName("SC2") + " "
		cQry += " SET C2_DTETIQ = '" + DtoS(dDataBase) + "', C2_XDTVALI = '" + DtoS(dDataVld) + "',  "
		cQry += " C2_DTFABR = '" + DtoS(dDataBase) + "', C2_DTVALID = '" + DtoS(dDataVld) + "'  "
		cQry += " FROM " + RetSqlName("SC2") + " AS SC2 "
		cQry += " WHERE C2_FILIAL = '"+xFilial("SC2")+"' "
		cQry += " AND C2_NUM    = '" + Substr(M->ZD_OP,1,6) + "' "
		cQry += " AND C2_ITEM   = '01' "
		cQry += " AND C2_SEQUEN = '001' "
		cQry += " AND SC2.D_E_L_E_T_ = ' ' "

		TcSQLExec(cQry)

	Else
	    
		If Empty(Posicione("SC2", 1, xFilial("SC2")+M->ZD_OP+Space(TamSX3("C2_ITEMGRD")[1]),"C2_DTFABR"))  
					
			cQry := " UPDATE " + RetSqlName("SC2") + " "
			cQry += " SET C2_DTETIQ = '" + DtoS(dDataBase) + "', C2_XDTVALI = '" + DtoS(dDataVld) + "',  "
			cQry += " C2_DTFABR = '" + DtoS(dDataBase) + "', C2_DTVALID = '" + DtoS(dDataVld) + "'  "
			cQry += " FROM " + RetSqlName("SC2") + " AS SC2 "
			cQry += " WHERE C2_FILIAL = '"+xFilial("SC2")+"' "
			cQry += " AND C2_NUM    = '" + Substr(M->ZD_OP,1,6) + "' "
			cQry += " AND SC2.D_E_L_E_T_ = ' ' "

			TcSQLExec(cQry)
		
		EndIf

	EndIf

Else 
	dDataFab := M->ZD_DTFABR    
	dDataVld := M->ZD_DTVALID    
EndIf

dbSelectArea(cAlias)   
//dbSetOrder(5) // ZD_FILIAL, ZD_LOTE, ZD_LI, ZD_LE, ZD_ENSAIO, ZD_ITEM, R_E_C_N_O_, D_E_L_E_T_             - Paulo Rog้rio - 23/01/2023
dbSetOrder(1) // ZD_FILIAL, ZD_PRODUT, ZD_LOTE, ZD_LI, ZD_LE, ZD_ITEM, ZD_ENSAIO, R_E_C_N_O_, D_E_L_E_T_    - Paulo Rog้rio - 23/01/2023

For i := 1 To Len(aCols)
	
	If !aCols[i][nUsado+1]
		//If dbSeek(xFilial("SZD") + cLote + cLoteI + cLoteE + aCols[i, nPosEns] + aCols[i, nPos])         - Paulo Rog้rio - 23/01/2023
		If dbSeek(xFilial("SZD") + cProd + cLote + cLoteI + cLoteE + aCols[i, nPos] + aCols[i, nPosEns]) //- Paulo Rog้rio - 23/01/2023
			RecLock(cAlias,.F.)
		Else
			RecLock(cAlias,.T.)
		Endif
		
		SZD->ZD_FILIAL    := xFilial("SZD")
		SZD->ZD_PRODUT    := cProd
		SZD->ZD_DESCRI    := Posicione("SB1",1,xFilial("SB1") + cProd, "B1_DESC")
		SZD->ZD_DTFABR    := dDataFab
		SZD->ZD_OP        := cCodOP      
		SZD->ZD_DTVALID   := dDataVld
		SZD->ZD_DTATU     := dDataBase
		SZD->ZD_DATA      := dAnalise
		SZD->ZD_LOTE      := cLote
		SZD->ZD_LI        := cLoteI
		SZD->ZD_LE        := cLoteE
		SZD->ZD_ANALIS    := cCombo    
		SZD->ZD_CODANAL   := cCodAna      
		SZD->ZD_FORN      := cCodFor      
				
		For nY := 1 to Len(aHeader)
			If aHeader[nY][10] # "V"
				cVar  := Trim(aHeader[nY][2])
				&cVar := Iif(Type("aCols[i][nY]") == "N", Round(aCols[i][nY], 3), aCols[i][nY])
			Endif
		Next nY    
		
		(cAlias)->( MsUnLock() )

	Else
		
		If !Found()
			Loop
		Endif
		
		If lOk
			RecLock(cAlias,.F.)
			dbDelete()
			(cAlias)->( MsUnLock() )
		Else
			cMsg := "Nao foi possivel deletar o item " + aCols[i, nPos] + ", o mesmo possui amarracao"
			MsgStop(cMsg)
		Endif
		
	Endif
	
Next i

RestArea(aArea)

Return .T.     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQIPX02DT  บ Autor ณTiago O. Beraldi    บ Data ณ  25/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ VALIDACAO ENCHOICE                                         บฑฑ
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
User Function QIPX02Dt(cLoteT)

Local aArea  := GetArea()      
Local aAreaSC2  := SC2->(GetArea())
Local aDatas := Array(2) // Fabricacao#Validade
                                        
dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1") + U_QIPX02getEspec(cLoteT))

dbSelectArea("SC2")
dbSetOrder(1)
dbSeek(xFilial("SC2") + cLoteT , .T.)

/*If Empty(SC2->C2_DTETIQ)
	aDatas[1] := dDataBase
	aDatas[2] := dDataBase + SB1->B1_PRVALID  
Else
	aDatas[1] := SC2->C2_DTETIQ
	aDatas[2] := SC2->C2_DTETIQ + SB1->B1_PRVALID  
EndIf*/
//Alterado para padrใo etiquetas produtos MEST001 27/04/18
aDatas[1] := SC2->C2_EMISSAO
aDatas[2] := LastDay(SC2->C2_EMISSAO + SB1->B1_PRVALID, 2)

RestArea(aAreaSC2)
RestArea(aArea)

Return aDatas

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQIPX002VALบ Autor ณTiago O. Beraldi    บ Data ณ  25/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ VALIDACAO ENCHOICE                                         บฑฑ
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
User Function QIPX02Valid(cLoteT, nBusca)

Local aArea		:= GetArea()
Local aAreaSC2	:= SC2->( GetArea() )
                            
// Obriga preenchimento do campo lote                                        
If Empty(cLoteT) 
	MsgStop("Lote nใo pode ser vazio!")	
	cLoteT := ""
EndIf                                

// Verifica se lote ja foi cadastrado
dbSelectArea("SZD")
dbSetOrder(nBusca)   
If MsSeek(xFilial("SZD") + cLoteT)
	MsgStop("Lote jแ cadastrado!")	
	cLoteT := ""
EndIf      
	               
RestArea( aAreaSC2 )
RestArea( aArea )

Return cLoteT

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ QIPX002L บ Autor ณTiago O. Beraldi    บ Data ณ  25/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ LEGENDA                                                    บฑฑ
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
User Function QIPX002L

BrwLegenda(cCadastro, "Legenda",  {{"ENABLE"  , "Ensaio Aprovado" },;
                                    {"DISABLE" , "Ensaio Reprovado"}})

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ATUALIZA บ Autor ณTiago O. Beraldi    บ Data ณ  25/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ CARREGA ESPECIFICACAO PADRAO DO PRODUTO                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑtualiza
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/  
Static Function Atualiza()

Local cProd    := M->ZD_PRODUT 

dbSelectArea("QPJ")
dbSetOrder(1)

cProduto := AllTrim(cProd)
cDesc    := Posicione("SB1", 1, xFilial("SB1") + SC2->C2_PRODUTO, "B1_DESC")

If dbSeek(xFilial("QPJ") + cProduto)
	
	nItem := 1  
	nZD_ITEM    := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_ITEM"})
	nZD_ENSAIO  := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_ENSAIO"})
	nZD_DENSAI  := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_DENSAI"}) 
	nZD_LINF    := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_LINF"}) 
	nZD_LSUP    := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_LSUP"})
	nZD_RNUM    := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_RNUM"})
	nZD_RNUMR   := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_RNUMR"})
	nZD_RTEXTP  := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_RTEXTP"})
	nZD_RTEXTO  := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_RTEXTO"})
	nZD_TEXTOR  := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_TEXTOR"})
	nZD_LIMITE  := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_LIMITE"})
	nZD_STATUS  := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_STATUS"})
	nZD_IMPRES  := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_IMPRES"})
	nZD_METODO  := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_METODO"})
	
	While !EOF("QPJ") .And. Alltrim(QPJ->QPJ_PROD) == cProduto
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Cria linha em branco no acols de acordo com o tamanho do aHeader ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If nItem <> 1
			Aadd(aCols, Array(Len(aHeader)+1))
			aCols[Len(aCols), Len(aHeader)+1] := .f.
		EndIf
		
		nItem++

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Preenche cada elemento da linha do aCols com seu valor ณ
		//ณ padrใo e depois copia os valores do item original.     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aCols[Len(aCols), nZD_ITEM]   := QPJ_ITEM      //Item
		aCols[Len(aCols), nZD_ENSAIO] := QPJ_ENSAIO    //Ensaio
		aCols[Len(aCols), nZD_DENSAI] := QPJ_DESENS    //Descricao do Ensaio
		aCols[Len(aCols), nZD_LINF]   := QPJ_LINF      //Limite Inferior
		aCols[Len(aCols), nZD_LSUP]   := QPJ_LSUP      //Limite Superior
		aCols[Len(aCols), nZD_RNUM]   := 0             //Resultado Numerico Verificado

		aCols[Len(aCols), nZD_RTEXTP] := QPJ_TEXTO     //Resultado Texto Padrao
		aCols[Len(aCols), nZD_RTEXTO] := "C"           //Resultado Texto Verificado
		aCols[Len(aCols), nZD_LIMITE] := QPJ_LIMITE    //Limite medida
		aCols[Len(aCols), nZD_STATUS] := ""            //Status
		aCols[Len(aCols), nZD_IMPRES] := QPJ_IMPRES    //Impressao
		aCols[Len(aCols), nZD_METODO] := QPJ_METODO    //Metodo                            
		
		If lExibeReal
			aCols[Len(aCols), nZD_RNUMR]  := 0             //Resultado Numerico Verificado Real
			aCols[Len(aCols), nZD_TEXTOR] := "C"           //Resultado Texto Verificado Real
		EndIf
			
		dbSelectArea("QPJ")
		dbSkip()
		
	EndDo

	GetdRefresh()	               

EndIf 

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ QIPX002  บ Autor ณTiago O. Beraldi    บ Data ณ  25/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ OBTEM O ITEM DA ESPECIFICACAO PADRAO (SXB "OP1")           บฑฑ
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
User Function QIPX02getEspec(cLote)
          
Local cRet     := ""                                         
Local lRet     := .T.
Local aAreaSC2 := SC2->(GetArea())
Local aArea    := GetArea()
Local cProd    := M->ZD_PRODUT 
Local cLote    := TRIM(M->ZD_LOTE)      
Local cLoteI   := M->ZD_LI        
Local cLoteE   := M->ZD_LE 
Local cProduto := " " 

SC2->(dbSetOrder(1))
SC2->(dbSeek(xFilial("SC2") + cLote))

While !SC2->(EOF()) .And. SC2->C2_NUM == cLote
	
    If Empty(cRet)
		QPJ->(dbSetOrder(1))
		If QPJ->(dbSeek(xFilial("QPJ") + SC2->C2_PRODUTO))
			cRet := SC2->C2_PRODUTO
			lRet := .F.
		EndIf
	EndIf
	
	If Empty(cRet)
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1") + PadR(AllTrim(SC2->C2_PRODUTO), 15)))
			If SB1->B1_TIPO == "PI"
				
				QPJ->(dbSetOrder(1))
				If QPJ->(dbSeek(xFilial("QPJ") + SC2->C2_PRODUTO))
					cRet := SC2->C2_PRODUTO
					lRet := .F.
				EndIf
			EndIf
		EndIf		
	EndIf
		
	// Familia A1, B1, C1, K1, BC, LM                 
	If Empty(cRet)
		cProduto := PadR(Subs(SC2->C2_PRODUTO, 1, At(".", SC2->C2_PRODUTO) - 1) + "." + Subs(SC2->C2_PRODUTO, -2), 15)              
		If Subs(SC2->C2_PRODUTO, -2) $ "A1#B1#BS#C1#D1#E1#E2#TR#I1#I2#C2#K1#BC#LM#AK#AL#MV#BV#OR#IT#OC#EC#TE#EU#IM#CO#R1#R2#R4#R6#AM#SL#V1#X1#Y1#Z1"
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1") + cProduto))
				If SB1->B1_TIPO == "PI" 
					QPJ->(dbSetOrder(1))
					If QPJ->(dbSeek(xFilial("QPJ") + cProduto)) .And. AllTrim(QPJ->QPJ_PROD) == AllTrim(cProduto)
						cRet := cProduto
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
	// Familia de Produtos - Normal
	If Empty(cRet)
		SB1->(dbSetOrder(1))                  
		If Subs(SC2->C2_GRUPO, 1, 1) == "1"
			cProduto := PadR(Subs(SC2->C2_PRODUTO, 1, At(".", SC2->C2_PRODUTO) - 1), 15)              
		Else
			If Len(AllTrim(SC2->C2_PRODUTO)) == 11
				cProduto := PadR(Subs(SC2->C2_PRODUTO, 1, 8), 15)              
			Else
				cProduto := PadR(Subs(SC2->C2_PRODUTO, 1, 9), 15)              
			EndIf
		EndIf
			
		If SB1->(dbSeek(xFilial("SB1") + cProduto))
			If SB1->B1_TIPO == "PI" 
				QPJ->(dbSetOrder(1))
				If QPJ->(dbSeek(xFilial("QPJ") + cProduto)) .And. AllTrim(QPJ->QPJ_PROD) == AllTrim(cProduto)
					cRet := cProduto
					lRet := .F.
				EndIf
			EndIf
		EndIf         
	EndIf
	SC2->(dbSkip())
EndDo

If Empty(cRet)
	If empty(cProduto)
		MsgAlert("Nใo hแ especifica็ใo para o produto, ou a OP. " + cLote + " foi excluํda. Verifique "  )
	Else
		MsgAlert("Nใo hแ especifica็ใo para o produto " + Alltrim(cProduto) + " , ou a OP. " + cLote + " foi excluํda. Verifique "  )
	Endif
EndIf    
               
RestArea(aAreaSC2)
RestArea(aArea)

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ QIPX002  บ Autor ณTiago O. Beraldi    บ Data ณ  25/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ FILTRO PARA CONSULTA OP1 (SXB)                             บฑฑ
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
User Function QIPX02SetFilter()

Local cRet := "@ "

Return cRet  


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ QIPX002  บ Autor ณTiago O. Beraldi    บ Data ณ  25/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ PREENCHE COMBO ANALISTAS                                   บฑฑ
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
Static Function QIPX02SetAnalis()

Local cRet := "" 

For i := 1 to Len(aCombo)
	cRet += ";" + AllTrim(aCombo[1]) + "=" + AllTrim(aCombo[1]) 
Next i

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEQIPX003  บAutor  ณTiago O. Beraldi    บ Data ณ  01/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida Tudo                                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Euroamerican                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function QIPX002OK()

Local lRet     := .T.    
Local nPos0    := Ascan(aHeader,{|x| "ZD_RTEXTO" $ x[2]})
Local nPos1    := Ascan(aHeader,{|x| "ZD_RTEXTP" $ x[2]})
Local nPos2    := Ascan(aHeader,{|x| "ZD_STATUS" $ x[2]})
Local cProd    := M->ZD_PRODUT 
Local cLote    := M->ZD_LOTE      
Local cLoteI   := M->ZD_LI      
Local cLoteE   := M->ZD_LE
Local cCodAna  := M->ZD_CODANAL

For n := 1 to (Len(aCols)-1)
	If Empty(aCols[n][nPos0]) .And. !Empty(aCols[n][nPos1])
		lRet := .F.
	ElseIf Empty(aCols[n][nPos2])
		lRet := .F.
	Endif
Next n       

If Empty(cProd) .Or. (Empty(cLote) .And. Empty(cLoteI)) .Or. Empty(cCodAna) 
	lRet := .F.
EndIf 

If !lRet
	cMsg := "Campos obrigat๓rios sem preenchimento!"
	MsgStop(cMsg)
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ QIPX002R บ Autor ณTiago O. Beraldi    บ Data ณ  15/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ REVALIDACAO DO LOTE DE PRODUCAO                            บฑฑ
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
User Function QIPX002R    

Local aButtons := {}
Local oGet1
Local cGet1 := ""
Local oGet2
Local cGet2 := ""
Local oSay1
Local oSay2  
Local cProduto   := SZD->ZD_PRODUT   
Local cLote      := SZD->ZD_LOTE   
Local cLoteI     := SZD->ZD_LI   
Local cLoteE     := SZD->ZD_LE   
Local lOk        := .F.
Local oDlg  
Local cQuery     := ""
Local cQueryG    := ""
Local cQry       := "" 
Local _aDados    := {}
Local _aCabec    := {} 

Private lMsErroAuto := .F.
Private TRB1        := GetNextAlias()

cGet1 := SZD->ZD_DTVALID
cGet2 := DtoC(StoD(Space(8)))

DEFINE MSDIALOG oDlg TITLE "Revalida็ใo de Lotes" FROM 100, 000  TO 300, 500 COLORS 0, 16777215 PIXEL

@ 045, 045 MSGET oGet1 VAR cGet1 WHEN .F. PICTURE "99/99/99" SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL
@ 047, 005 SAY oSay1 PROMPT "Validade Atual" SIZE 039, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 060, 045 MSGET oGet2 VAR cGet2 PICTURE "99/99/99" SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL
@ 062, 005 SAY oSay2 PROMPT "Revalida็ใo" SIZE 039, 007 OF oDlg COLORS 0, 16777215 PIXEL

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {||lOk := .T., oDlg:End()}, {||oDlg:End()},, aButtons)         
                                                                            
If lOk   

	cQry := " UPDATE " + RetSqlName("SZD") 
	cQry += " SET    ZD_DTVALID = '" + DtoS(CtoD(cGet2)) + "',ZD_DTFABR = '" + DtoS(dDataBase) + "' " 
	cQry += " WHERE  ZD_LOTE = '" + cLote + "'" 
	cQry += "        AND ZD_LI = '" + cLoteI + "'" 
	cQry += "        AND ZD_LE = '" + cLoteE + "'" 
	
	TcSQLExec(cQry)

	/*
	+-----------------------------------------------------------------+
	| ATEDIMENTO CHAMADO : 6310 - Fแbio Carneiro - 03/06/2022         |
	| Motivo: Serแ impresso na etiqueta EURO - Data de Validade na OP |
	| sera gravado na OP pelo campo C2_DTETIQ o inicio da produ็ใo    |  
	+-----------------------------------------------------------------+
	*/

	If cFilAnt == "0200"

		If Select("TRB1") > 0
			TRB1->(DbCloseArea())
		EndIf

		cQuery := "SELECT B8_FILIAL AS FILIAL, B8_PRODUTO AS PRODUTO, B1_DESC AS DESCRI, B1_TIPO AS TIPO, B8_LOCAL AS ARMAZEN, B1_UM AS UM, " +ENTER 
		cQuery += " B8_LOTECTL AS LOTE, B8_DTVALID AS VALID,'' AS LOCALIZ ,B8_SALDO AS SALDO, B8_EMPENHO AS EMPENHO, B1_RASTRO AS RASTRO, B1_LOCALIZ AS CTRLEND " +ENTER  
		cQuery += "FROM " + RetSqlName("SB8") + " AS SB8 " +ENTER  
		cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 ON B1_FILIAL = ' '  " +ENTER  
		cQuery += " AND B1_COD = B8_PRODUTO " +ENTER  
		cQuery += " AND SB1.D_E_L_E_T_ = ' '  " +ENTER  
		cQuery += "WHERE B8_FILIAL =  '"+xFilial("SB8")+"' " +ENTER  
		cQuery += " AND SB8.B8_PRODUTO = '"+AllTrim(cProduto)+"' "+ ENTER
		cQuery += " AND SB8.B8_LOCAL IN ('04','08') "+ ENTER
		cQuery += " AND B1_TIPO IN ('PA','PI') " + ENTER
		cQuery += " AND B8_LOTECTL = '"+cLote+"'  " +ENTER  
		cQuery += " AND B8_SALDO > 0   " +ENTER  
		cQuery += " AND SB8.D_E_L_E_T_ = ' '  " +ENTER  
			
		TcQuery cQuery ALIAS "TRB1" NEW
			
		TRB1->(DbGoTop())

		While TRB1->(!Eof())

			If Select("TRB3") > 0
				TRB3->(DbCloseArea())
			EndIf

			cQueryG  := "SELECT D5_FILIAL, D5_PRODUTO, D5_LOCAL, D5_LOTECTL, D5_NUMLOTE, D5_NUMSEQ, B8_SALDO, B8_EMPENHO, " + ENTER
			cQueryG  += " B8_LOTECTL, B8_NUMLOTE, B8_DTVALID " + ENTER
			cQueryG  += "FROM " + RetSqlName("SD5") + " AS SD5  " + ENTER
			cQueryG  += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_COD = D5_PRODUTO " + ENTER 
			cQueryG  += " AND SB1.D_E_L_E_T_ = ' ' " + ENTER 
			cQueryG  += "INNER JOIN " + RetSqlName("SB8") + " AS SB8 ON B8_FILIAL = D5_FILIAL " + ENTER 
			cQueryG  += " AND B8_PRODUTO = D5_PRODUTO " + ENTER 
			cQueryG  += " AND B8_LOTECTL = D5_LOTECTL " + ENTER 
			cQueryG  += " AND SB8.D_E_L_E_T_ = ' '  " + ENTER 
			cQueryG  += "WHERE D5_FILIAL = '"+xFilial("SD5")+"' " + ENTER 
			cQueryG  += " AND D5_PRODUTO  = '"+AllTrim(cProduto)+"'  " + ENTER
			cQueryG  += " AND D5_LOTECTL  = '"+AllTrim(clote)+"'  " + ENTER
			cQueryG  += " AND D5_LOCAL IN ('04','08')  " + ENTER
			cQueryG  += " AND B8_SALDO > 0 " + ENTER
			cQueryG  += " AND SD5.D_E_L_E_T_ = ' ' " + ENTER
			cQueryG  += "ORDER BY SD5.R_E_C_N_O_ DESC  " + ENTER

			TcQuery cQueryG ALIAS "TRB3" NEW
					
			TRB3->(DbGoTop())

			While TRB3->(!Eof())

				DbSelectArea("SB8")
				DbSelectArea("SD5")
				SD5->(DbSetOrder(2)) // D5_FILIAL+D5_PRODUTO+D5_LOCAL+D5_LOTECTL+D5_NUMLOTE+D5_NUMSEQ
				If SD5->(dbSeek(xFilial("SD5")+TRB3->D5_PRODUTO+TRB3->D5_LOCAL+TRB3->D5_LOTECTL+TRB3->D5_NUMLOTE+TRB3->D5_NUMSEQ))  

					Begin Transaction               
						
						_aCabec := {}  

						aadd(_aCabec,{"D5_PRODUTO",TRB3->D5_PRODUTO,NIL})       
						aadd(_aCabec,{"D5_LOCAL"  ,TRB3->D5_LOCAL  ,NIL})     
						aadd(_aCabec,{"D5_LOTECTL",TRB3->D5_LOTECTL,NIL})      
						aadd(_aCabec,{"D5_NUMLOTE",TRB3->D5_NUMLOTE,NIL})
						aadd(_aCabec,{"D5_NUMSEQ" ,TRB3->D5_NUMSEQ ,NIL})
						aadd(_aCabec,{"B8_DTVALID",CtoD(cGet2),NIL})                                

						MSExecAuto({|x,y| mata390(x,y)},_aCabec,4)               

						If lMsErroAuto         
							DisarmTransaction()
						EndIf       

					End Transaction
				
				EndIf
				
				TRB3->(DbSkip())

			EndDo

			TRB1->(DbSkip())

		EndDo

		
		If !Empty(Posicione("SC2", 1, xFilial("SC2")+AllTrim(cLote)+"01"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_DTETIQ")) 
						
			cQry := " UPDATE " + RetSqlName("SC2") + " "
			cQry += " SET C2_DTETIQ = '" + DtoS(dDataBase) + "', C2_XDTVALI = '" + DtoS(CtoD(cGet2)) + "'  "
			cQry += " FROM " + RetSqlName("SC2") + " AS SC2 "
			cQry += " WHERE C2_FILIAL = '"+xFilial("SC2")+"' "
			cQry += " AND C2_NUM    = '" + AllTrim(cLote) + "' "
			cQry += " AND C2_ITEM   = '01' "
			cQry += " AND C2_SEQUEN = '001' "
			cQry += " AND SC2.D_E_L_E_T_ = ' ' "

			TcSQLExec(cQry)

		EndIf 

	EndIf

EndIf

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf
If Select("TRB3") > 0
	TRB3->(DbCloseArea())
EndIf
If Select("SD5") > 0
	SD5->(DbCloseArea())
EndIf
If Select("SB8") > 0
	SB8->(DbCloseArea())
EndIf


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ QIPX002C บ Autor ณTiago O. Beraldi    บ Data ณ  15/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ EXIBE/OCULTA DADOS DE RESULTADO DE ANALISE ( REAL )        บฑฑ
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
User Function QIPX002C    
Local aArea		:= GetArea()
Local aAreaSX6	:= SX6->(GetArea())
Local mvPar		:= "MV_REALSZD"

Local oDlg		:= Nil
Local cPwd 		:= Space(08)
Local lRet 		:= .F.

DEFINE MSDIALOG oDlg FROM 0,0 TO 285,544 TITLE "STR0169" Of oMainWnd PIXEL
DEFINE FONT oBold NAME "Courier New" SIZE 0, -13 BOLD
DEFINE FONT oFNor NAME "Tahoma" SIZE 0, -13 

@ 0  , 0 BITMAP oBmp RESNAME "LOGIN" oF oDlg SIZE 55,200 NOBORDER WHEN .F. PIXEL
@ 0.4,08 SAY OemToAnsi("M๓dulo Configurador") 									Font oBold Color CLR_BLUE

@ 1.8,08 SAY OemToAnsi("Entre com a senha do administrador para iniciar")		Font oFNor
@ 2.4,08 SAY OemToAnsi("o assistente virtual, o qual o irแ guia-lo durante")	Font oFNor
@ 3.0,08 SAY OemToAnsi("todas as etapas deste processo.")						Font oFNor

@ 5.0,08 SAY OemToAnsi("Este processo irแ levar alguns minutos.")				Font oFNor

@ 8.0,10 SAY OemToAnsi("Senha")													Font oBold
@ 8.0,18 MSGET cPwd Picture "@!" Size 80,08 PASSWORD

DEFINE SBUTTON FROM 130,240 TYPE 1 ACTION ( IIf( cPwd == DtoS(dDatabase), ( lRet := .T., oDlg:End() ), MsgStop("Senha invแlida.") )) ENABLE OF oDlg PIXEL
DEFINE SBUTTON FROM 130,210 TYPE 2 ACTION ( lRet := .F., oDlg:End() ) ENABLE OF oDlg PIXEL
    
ACTIVATE MSDIALOG oDlg CENTERED

If lRet

	SX6->( dbSetOrder(1) )
	SX6->( dbSeek( xFilial("SX6") + mvPar ) )
	
	If SX6->( !Found() )
	
		RecLock("SX6", .T.) 
			SX6->X6_FIL		:= xFilial("SX6") 
			SX6->X6_VAR		:= mvPar 
			SX6->X6_TIPO	:= "L" 
			SX6->X6_DESCRIC	:= "Exibe/Oculta campos com resultado de analise ( REAL )" 
			SX6->X6_CONTEUD	:= ".F."
			SX6->X6_PROPRI	:= "U" 
			SX6->X6_PYME	:= "S" 
		SX6->( MsUnlock() )
	
	Else
	
		RecLock("SX6", .F.) 
			SX6->X6_CONTEUD	:= IIf( RTrim(SX6->X6_CONTEUD) == ".T.", ".F.", ".T." )
		SX6->( MsUnlock() )
	
	EndIf	
	   
	//Atualiza valor da variavel privada que controla exibicao dos campos 
	lExibeReal := ( RTrim(SX6->X6_CONTEUD) == ".T." )
	
EndIf

RestArea(aAreaSX6)
RestArea(aArea)

Return( Nil )
