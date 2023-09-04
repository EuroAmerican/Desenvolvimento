#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#include "protheus.ch"
#define ENTER Chr(13)+Chr(10)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ESTX002  บAutor  ณTiago O. Beraldi    บ Data ณ  31/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ SIMULACAO DE CUSTOS                                        บฑฑ
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
User Function ESTX002()

Private cAlias    := "SMC"
Private cFilSMC   := xFilial("SMC")
Private cCadastro := "Simula็ใo de Custos"
Private aRotina   := {}
Private aCores    := {}

aAdd(aRotina, {"Pesquisar"  , "AxPesqui"  , 0, 1})
aAdd(aRotina, {"Visualizar" , "U_ESTX002V", 0, 2})
aAdd(aRotina, {"Simular"    , "U_ESTX002S", 0, 3})
aAdd(aRotina, {"Excluir"    , "U_ESTX002E", 0, 5})
aAdd(aRotina, {"Aprovar"    , "U_ESTX002A", 0, 2})
aAdd(aRotina, {"Imprimir"   , "U_ESTX002I", 0, 2})
aAdd(aRotina, {"Legenda"    , "U_ESTX002L", 0, 2})
                                                
dbSelectArea(cAlias)
dbSetOrder(1)
dbGoTop()

aAdd(aCores,{"Alltrim(SMC->MC_STATUS) == 'A'"   ,"BR_AMARELO"})
aAdd(aCores,{"Len(Alltrim(SMC->MC_STATUS)) == 0","BR_AZUL"   })
aAdd(aCores,{"Alltrim(SMC->MC_STATUS) == 'C'"   ,"BR_PRETO"  })

//Set Filter to &("@ MC_INCLUI = '" +  AllTrim(cUserName) + "' ")

mBrowse(06,01,22,75,"SMC",,,,,,aCores)

dbSelectArea("SMC")
dbSetOrder(1)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATUALIZA  บAutor  ณTiago O. Beraldi    บ Data ณ  31/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ BOTAO SIMULACAO DE CUSTOS                                  บฑฑ
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
Static Function Atualiza(lAtuCst)    

Default lAtuCst := .T.

If Mod2TudOk()
	nCusto := 0
	For nI := 1 To Len(aCols)
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + aCols[nI][2]))
		
		aCols[nI][4] := Iif(lAtuCst, SB1->B1_CUSTD, aCols[nI][4])
		nCusto        += ((aCols[nI][3] * aCols[nI][4]) / nQtdBase)
	Next nI
	
	For nI := 1 To Len(aCols)
		aCols[nI][5] := (100*((aCols[nI][3]*aCols[nI][4])/nQtdBase))/nCusto
	Next nI
	
	GetdRefresh()        
	
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ESTX002  บAutor  ณTiago O. Beraldi    บ Data ณ  31/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ VISUALIZACAO                                               บฑฑ
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
User Function ESTX002V(cAlias, nRecno, nOpcX)

Local nCnt       := 0
Local cVarTemp   := ""
Local oDlg       := Nil
Local oGet       := Nil
Local nOpcA      := 0 

Private cNum    := SMC->MC_NUM
Private cStatus := SMC->MC_STATUS
Private cDescri := SMC->MC_DESCRI
Private dData   := SMC->MC_DATA
Private nQtdBase:= SMC->MC_QTBASE
Private cInclui := SMC->MC_INCLUI
Private nCusto  := 0
Private aHeader := {}
Private aCols   := {}
Private nUsado  := 0
Private oPrn    := Nil

DEFINE FONT oFont1 NAME "Tahoma" SIZE 0,18 OF oPrn BOLD

dbSelectArea("SMC")
If RecCount() == 0
	Return .T.
Endif

dbSetOrder(1)
dbSeek(cFilSMC + cNum)

While !EOF() .And. SMC->MC_FILIAL + SMC->MC_NUM == cFilSMC + cNum
	nCnt++
	dbSkip()
End

If nCnt == 0
	Return .T.
Endif

dbSelectArea("SX3")
dbSetOrder(1)
dbGoTop()
dbSeek(cAlias)      

While !EOF() .And. X3_ARQUIVO == cAlias
	IF X3Uso(X3_USADO) .And. X3_NIVEL > 0
		nUsado++
		aAdd(aHeader,{ TRIM(X3Titulo()) ,;
		X3_CAMPO    ,;
		X3_PICTURE  ,;
		X3_TAMANHO  ,;
		X3_DECIMAL  ,;
		X3_VALID    ,;
		X3_USADO    ,;
		X3_TIPO     ,;
		X3_ARQUIVO  ,;
		X3_CONTEXT  })
	Endif
	dbSkip()
End

dbSelectArea(cAlias)
dbSeek(cFilSMC + cNum)

nCnt := 0

While !EOF() .And. SMC->MC_FILIAL + SMC->MC_NUM == cFilSMC + cNum
	
	aAdd(aCols, Array(Len(aHeader)+1))
	
	nCnt++
	nUsado:=0
	
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbGoTop()
	dbSeek(cAlias)      
	
	While !EOF() .And. X3_ARQUIVO == cAlias
		If X3Uso(X3_USADO) .And. X3_NIVEL > 0
			nUsado++
			cVarTemp := cAlias + "->" + (X3_CAMPO)
			If X3_CONTEXT # "V"
				aCols[nCnt][nUsado] := &cVarTemp
			ElseIf X3_CONTEXT == "V"
				aCols[nCnt][nUsado] := CriaVar(AllTrim(X3_CAMPO))
			Endif
		Endif
		dbSkip()
	End                                
	
	dbSelectArea(cAlias)
	dbSkip()
End

DEFINE MSDIALOG oDlg TITLE cCadastro From 0,0 To 36,100 OF oMainWnd

@ 15, 2 TO 55,394 LABEL "Simula็ใo de Custos" OF oDlg PIXEL

@ 24, 006 SAY "Nบ da Simula็ใo....:"                 SIZE 078,7 PIXEL OF oDlg
@ 24, 110 SAY "Descri็ใo............:"               SIZE 078,7 PIXEL OF oDlg
@ 24, 304 SAY "Data de Emissใo.....:"                SIZE 078,7 PIXEL OF oDlg

@ 39, 006 SAY "Incluํdo por............:"            SIZE 078,7 PIXEL OF oDlg
@ 39, 110 SAY "Qtde. Base..........:"                SIZE 078,7 PIXEL OF oDlg
@ 39, 304 SAY "Status......................:"        SIZE 078,7 PIXEL OF oDlg

@ 23, 053 MSGET cNum    When .F. PICTURE "999999"    SIZE 026,7 PIXEL OF oDlg
@ 23, 154 MSGET cDescri When .F. PICTURE "@!"        SIZE 120,7 PIXEL OF oDlg
@ 23, 354 MSGET dData   When .F. PICTURE "99/99/99"  SIZE 032,7 PIXEL OF oDlg

If cStatus == "A"
	cStatus := "APROVADA "
Else
	cStatus := "EM ABERTO"
Endif                                                      

@ 38, 053 MSGET cInclui  When .F. PICTURE "@!"            SIZE 48,7 PIXEL OF oDlg
@ 38, 154 MSGET nQtdBase When .F. PICTURE "@E 999,999.99" SIZE 48,7 PIXEL OF oDlg
@ 38, 354 MSGET cStatus  When .F. PICTURE "@!"            SIZE 30,7 PIXEL OF oDlg

@ 201, 2 TO 255,394 LABEL "" OF oDlg PIXEL

dbSelectArea("SMC")
dbSetOrder(1)
dbSeek(xFilial("SMC") + cNum)

While !EOF() .and. SMC->MC_NUM == cNum
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1") + SMC->MC_PROD)
	
	RecLock("SMC",.F.)
		SMC->MC_PRCUNI := SB1->B1_CUSTD
	SMC->( MsUnLock() )
	
	nCusto += (SMC->MC_QTDPRO * SMC->MC_PRCUNI)/nQtdBase
	
	dbSelectArea("SMC")
	dbSkip()
	
Enddo

dbSelectArea("SMC")
dbSetOrder(1)
dbSeek(xFilial("SMC") + cNum)

While !EOF() .And. SMC->MC_NUM == cNum
	
	nRepCus := ((100 * SMC->MC_QTDPRO * SMC->MC_PRCUNI)/nQtdBase)/nCusto
	
	RecLock("SMC",.F.)
		SMC->MC_REPCUS := Round(nRepCus, 2)
	SMC->( MsUnLock() )
	
	dbSelectArea("SMC")
	dbSkip()
	
Enddo

@ 220,095 SAY "Custo por KG do Novo Produto..........:" SIZE 150,9                          PIXEL OF oDlg FONT oFont1
@ 219,248 SAY "R$ "                                     SIZE 012,9 PICTURE "@!"             PIXEL OF oDlg FONT oFont1 COLOR CLR_HRED
@ 219,257 SAY nCusto                                    SIZE 094,9 PICTURE "@E 999,999.99"  PIXEL OF oDlg FONT oFont1 COLOR CLR_HRED

oGet := MSGetDados():New(59,3,199,393,nOpcX)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End()},{||oDlg:End()})

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ESTX002  บAutor  ณTiago O. Beraldi    บ Data ณ  31/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ APROVACAO                                                  บฑฑ
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
User Function ESTX002A( cAlias, nRecNo, nOpcX )

Local nCnt      := 0
Local cVarTemp  := ""
Local oDlg      := Nil
Local oGet      := Nil
Local nOpcA     := 0

Private cNum    := SMC->MC_NUM
Private cStatus := SMC->MC_STATUS
Private cDescri := SMC->MC_DESCRI
Private dData   := SMC->MC_DATA
Private nQtdBase:= SMC->MC_QTBASE
Private cInclui := SMC->MC_INCLUI
Private nCusto  := 0
Private aHeader := {}
Private aCols   := {}
Private nUsado  := 0
Private oPrn    := Nil  
Private nQtdAtu := 0
Private oQtdAtu  

DEFINE FONT oFont1 NAME "Tahoma" SIZE 0,18 OF oPrn BOLD

dbSelectArea("SMC")
If RecCount() == 0
	Return .T.
Endif

dbSetOrder(1)
dbSeek(cFilSMC + cNum)

While !EOF() .And. SMC->MC_FILIAL + SMC->MC_NUM == cFilSMC + cNum
	nCnt++
	dbSkip()
End

If nCnt == 0
	Return .T.
Endif

dbSelectArea("SX3")
dbSetOrder(1)
dbGoTop()
dbSeek(cAlias)      

While !EOF() .And. X3_ARQUIVO == cAlias
	IF X3USO(X3_USADO) .AND. X3_NIVEL > 0
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()) ,;
		X3_CAMPO    ,;
		X3_PICTURE  ,;
		X3_TAMANHO  ,;
		X3_DECIMAL  ,;
		X3_VALID    ,;
		X3_USADO    ,;
		X3_TIPO     ,;
		X3_ARQUIVO  ,;
		X3_CONTEXT  })
	Endif
	dbSkip()
End

dbSelectArea(cAlias)
dbSeek(cFilSMC + cNum)

nCnt := 0

While !EOF() .And. SMC->MC_FILIAL + SMC->MC_NUM == cFilSMC + cNum
	
	aAdd( aCols, Array(Len(aHeader)+1))
	
	nCnt++
	nUsado:=0

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbGoTop()
	dbSeek(cAlias)      
	
	While !EOF() .And. X3_ARQUIVO == cAlias
		If X3USO(X3_USADO) .AND. X3_NIVEL > 0
			nUsado++
			cVarTemp := cAlias+"->"+(X3_CAMPO)
			If X3_CONTEXT # "V"
				aCols[nCnt][nUsado] := &cVarTemp
			ElseIf X3_CONTEXT == "V"
				aCols[nCnt][nUsado] := CriaVar(AllTrim(X3_CAMPO))
			Endif
		Endif
		dbSkip()
	End   
	
	dbSelectArea(cAlias)
	dbSkip()
End

DEFINE MSDIALOG oDlg TITLE cCadastro From 0,0 To 36,100 OF oMainWnd

@ 15, 2 TO 55,394 LABEL "Simula็ใo de Custos" OF oDlg PIXEL

@ 24, 006 SAY "Nบ da Simula็ใo....:"                SIZE 078,7 PIXEL OF oDlg
@ 24, 110 SAY "Descri็ใo............:"              SIZE 078,7 PIXEL OF oDlg
@ 24, 304 SAY "Data de Emissใo.....:"               SIZE 078,7 PIXEL OF oDlg

@ 39, 006 SAY "Incluํdo por............:"           SIZE 078,7 PIXEL OF oDlg
@ 39, 110 SAY "Qtde. Base..........:"               SIZE 078,7 PIXEL OF oDlg   
@ 39, 207 SAY "Qtde. Atual.........:"               SIZE 078,7 PIXEL OF oDlg
@ 39, 304 SAY "Status......................:"       SIZE 078,7 PIXEL OF oDlg

@ 23, 053 MSGET cNum    When .F. PICTURE "999999"   SIZE 026,7 PIXEL OF oDlg
@ 23, 154 MSGET cDescri When .F. PICTURE "@!"       SIZE 120,7 PIXEL OF oDlg
@ 23, 354 MSGET dData   When .F. PICTURE "99/99/99" SIZE 032,7 PIXEL OF oDlg

If cStatus == "A"
	cStatus := "APROVADA "
Else
	cStatus := "EM ABERTO"
Endif
@ 38, 053 MSGET cInclui   When .F. PICTURE "@!"            SIZE 48,7 PIXEL OF oDlg
@ 38, 154 MSGET nQtdBase  When .F. PICTURE "@E 999,999.99" SIZE 48,7 PIXEL OF oDlg    
@ 38, 250 GET nQtdAtu  WHEN .F. OBJECT oQtdAtu PICTURE "@E 999,999.99" SIZE 48,7 
@ 38, 354 MSGET cStatus   When .F. PICTURE "@!"            SIZE 30,7 PIXEL OF oDlg

@ 201, 2 TO 255,394 LABEL "" OF oDlg PIXEL

dbSelectArea("SMC")
dbSetOrder(1)
dbSeek(xFilial("SMC") + cNum)

While !EOF() .And. SMC->MC_NUM == cNum
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1") + SMC->MC_PROD)
	
	RecLock("SMC", .F.)
		SMC->MC_PRCUNI := SB1->B1_CUSTD
	SMC->( MsUnLock() )
	
	nCusto += ((SMC->MC_QTDPRO * SMC->MC_PRCUNI) / nQtdBase)
	
	dbSelectArea("SMC")
	dbSkip()
	
Enddo

dbSelectArea("SMC")
dbSetOrder(1)
dbSeek(xFilial("SMC") + cNum)

While !EOF() .And. SMC->MC_NUM == cNum
	
	nRepCus := ((100 * SMC->MC_QTDPRO * SMC->MC_PRCUNI)/nQtdBase)/nCusto
	
	RecLock("SMC",.F.)
		SMC->MC_REPCUS := Round(nRepCus, 2)
	SMC->( MsUnLock() )
	
	dbSelectArea("SMC")
	dbSkip()
	
Enddo

@ 220,095 SAY "Custo por KG do Novo Produto..........:" SIZE 150,9 PIXEL OF oDlg                         FONT oFont1
@ 219,248 SAY "R$ "                                     SIZE 012,9 PIXEL OF oDlg PICTURE "@!"            FONT oFont1 COLOR CLR_HRED
@ 219,257 SAY nCusto                                    SIZE 094,9 PIXEL OF oDlg PICTURE "@E 999,999.99" FONT oFont1 COLOR CLR_HRED

oGet := MSGetDados():New(59, 3, 199, 393, nOpcX)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End()},{||oDlg:End()})

If nOpcA == 1
	
	dbSelectArea("SMC")
	dbSetOrder(1)
	dbSeek(xFilial("SMC") + cNum)
	
	While !EOF() .And. SMC->MC_NUM == cNum
		
		RecLock("SMC",.F.)
			SMC->MC_STATUS := "A"
		SMC->( MsUnLock() )
		
		dbSelectArea("SMC")
		dbSkip()
		
	Enddo
	
Endif

Return          

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ESTX002  บAutor  ณTiago O. Beraldi    บ Data ณ  31/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ SIMULACAO                                                  บฑฑ
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
User Function ESTX002S(cAlias, nRecNo, nOpcX)

Local nCnt      := 0
Local cVarTemp  := ""
Local oDlg      := Nil
Local oGet      := Nil
Local nOpcA     := 0
Private cNum    := GetSX8Num("SMC", "MC_NUM")
Private cStatus := "EM ABERTO"
Private cDescri := Space(Len(SMC->MC_DESCRI))
Private dData   := dDataBase
Private nQtdBase:= 0
Private cInclui := Subs(cUsuario, 7, 15)
Private nCusto  := 0
Private aHeader := {}
Private aCols   := {}
Private nUsado  := 0
Private oPrn    := Nil     
Private nQtdAtu := 0
Private oQtdAtu	:= Nil

DEFINE FONT oFont1 NAME "Tahoma" SIZE 0,18 OF oPrn BOLD

dbSelectArea("SX3")
dbSetOrder(1)
dbGoTop()
dbSeek(cAlias)      

While !EOF() .And. X3_ARQUIVO == cAlias
	IF X3USO(X3_USADO) .AND. X3_NIVEL > 0
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()) ,;
		X3_CAMPO    ,;
		X3_PICTURE  ,;
		X3_TAMANHO  ,;
		X3_DECIMAL  ,;
		X3_VALID    ,;
		X3_USADO    ,;
		X3_TIPO     ,;
		X3_ARQUIVO  ,;
		X3_CONTEXT  })
	Endif
	dbSkip()
End

aAdd( aCols,Array(Len(aHeader)+1))

dbSelectArea("SX3")
dbSetOrder(1)
dbGoTop()
dbSeek(cAlias)      

nUsado:=0
While !EOF() .And. X3_ARQUIVO == cAlias
	IF X3USO(X3_USADO) .AND. X3_NIVEL > 0
		nUsado++
		IF Empty(X3_VALID)
			IF X3_TIPO == "C"
				If Trim(aHeader[nUsado][2]) == "MC_ITEM"
					aCols[1][nUsado] := "01"
				Else
					aCols[1][nUsado] := SPACE(x3_tamanho)
				Endif
			ELSEIF X3_TIPO == "N"
				aCols[1][nUsado] := 0
			ELSEIF X3_TIPO == "D"
				aCols[1][nUsado] := dDataBase
			ELSEIF X3_TIPO == "M"
				aCols[1][nUsado] := CriaVar(AllTrim(X3_CAMPO))
			ELSE
				aCols[1][nUsado] := .F.
			Endif
			If X3_CONTEXT == "V"
				aCols[1][nUsado] := CriaVar(AllTrim(X3_CAMPO))
			Endif
		Endif
	Endif
	dbSkip()
End

dbSelectArea("SMC")
dbSetOrder(1)

aCols[1][nUsado+1] := .F.

DEFINE MSDIALOG oDlg TITLE cCadastro From 0,0 To 36,100 OF oMainWnd

@ 15, 2 TO 55,394 LABEL "Simula็ใo de Custos" OF oDlg PIXEL

@ 24, 006 SAY "Nบ da Simula็ใo....:"                SIZE 078,7 PIXEL OF oDlg
@ 24, 110 SAY "Descri็ใo............:"              SIZE 078,7 PIXEL OF oDlg
@ 24, 304 SAY "Data de Emissใo.....:"               SIZE 078,7 PIXEL OF oDlg

@ 39, 006 SAY "Incluํdo por............:"           SIZE 078,7 PIXEL OF oDlg
@ 39, 110 SAY "Qtde. Base..........:"               SIZE 078,7 PIXEL OF oDlg
@ 39, 207 SAY "Qtde. Atual.........:"               SIZE 078,7 PIXEL OF oDlg
@ 39, 304 SAY "Status......................:"       SIZE 078,7 PIXEL OF oDlg

@ 23, 053 MSGET cNum    When .F. PICTURE "999999"   SIZE 026,7 PIXEL OF oDlg
@ 23, 154 MSGET cDescri          PICTURE "@!"       SIZE 120,7 PIXEL OF oDlg
@ 23, 354 MSGET dData   When .F. PICTURE "99/99/99" SIZE 032,7 PIXEL OF oDlg

If cStatus == "A"
	cStatus := "APROVADA "
Endif

@ 38, 053 MSGET cInclui  When .F. PICTURE "@!"            SIZE 48,7 PIXEL OF oDlg
@ 38, 154 MSGET nQtdBase         PICTURE "@E 999,999.99" SIZE 48,7 PIXEL OF oDlg
@ 38, 250 GET nQtdAtu  WHEN .F. OBJECT oQtdAtu PICTURE "@E 999,999.99" SIZE 48,7 
@ 38, 354 MSGET cStatus  When .F. PICTURE "@!"            SIZE 30,7 PIXEL OF oDlg

@ 201, 2 TO 255,394 LABEL "" OF oDlg PIXEL

@ 220,095 SAY "Custo por KG do Novo Produto..........:" SIZE 150,9 PIXEL OF oDlg                         FONT oFont1
@ 219,248 SAY "R$ "                                     SIZE 012,9 PIXEL OF oDlg PICTURE "@!"            FONT oFont1 COLOR CLR_HRED
@ 219,257 SAY nCusto                                    SIZE 094,9 PIXEL OF oDlg PICTURE "@E 999,999.99" FONT oFont1 COLOR CLR_HRED
@ 215,350 BUTTON "Copiar Formula" OF oDlg PIXEL SIZE 40,15 ACTION CopiaFormula()
@ 237,350 BUTTON "Simular Custo" OF oDlg PIXEL SIZE 40,15 ACTION Atualiza(.F.)

oGet := MSGetDados():New(59,3,199,393,nOpcX,,,"+MC_ITEM",.T.)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,Iif(Mod2TudOk(),oDlg:End(),nOpcA:=0)},{||oDlg:End()})

If nOpcA == 1
	SMCGrava(cAlias)
	ConfirmSX8()
Else
	RollBackSX8()
Endif

dbSelectArea("SMC")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ESTX002  บAutor  ณTiago O. Beraldi    บ Data ณ  31/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ EXCLUSAO                                                   บฑฑ
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
User Function ESTX002E(cAlias, nRecNo, nOpcX)

Local nCnt      := 0
Local cVarTemp  := ""
Local oDlg      := Nil
Local oGet      := Nil
Local nOpcA     := 0

Private cNum    := SMC->MC_NUM
Private cStatus := SMC->MC_STATUS
Private cDescri := SMC->MC_DESCRI
Private dData   := SMC->MC_DATA
Private nQtdBase:= SMC->MC_QTBASE
Private cInclui := SMC->MC_INCLUI
Private nCusto  := 0
Private aHeader := {}
Private aCols   := {}
Private nUsado  := 0
Private oPrn    := Nil

DEFINE FONT oFont1 NAME "Tahoma" SIZE 0,18 OF oPrn BOLD

dbSelectArea("SMC")
If RecCount() == 0
	Return .T.
Endif

dbSetOrder(1)
dbSeek(cFilSMC + cNum)

While !EOF() .And. SMC->MC_FILIAL + SMC->MC_NUM == cFilSMC + cNum
	nCnt++
	dbSkip()
End

If nCnt == 0
	Return .T.
Endif

dbSelectArea("SX3")
dbSetOrder(1)
dbGoTop()
dbSeek(cAlias)      

While !EOF() .And. X3_ARQUIVO == cAlias
	IF X3USO(X3_USADO) .AND. X3_NIVEL > 0
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()) ,;
		X3_CAMPO    ,;
		X3_PICTURE  ,;
		X3_TAMANHO  ,;
		X3_DECIMAL  ,;
		X3_VALID    ,;
		X3_USADO    ,;
		X3_TIPO     ,;
		X3_ARQUIVO  ,;
		X3_CONTEXT  })
	Endif
	dbSkip()
End

dbSelectArea(cAlias)
dbSeek(cFilSMC + cNum)

nCnt := 0

While !EOF() .And. SMC->MC_FILIAL + SMC->MC_NUM == cFilSMC + cNum
	
	aAdd( aCols, Array(Len(aHeader)+1))
	
	nCnt++
	nUsado:=0

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbGoTop()
	dbSeek(cAlias)      
	
	While !EOF() .And. X3_ARQUIVO == cAlias
		If X3USO(X3_USADO) .AND. X3_NIVEL > 0
			nUsado++
			cVarTemp := cAlias+"->"+(X3_CAMPO)
			If X3_CONTEXT # "V"
				aCols[nCnt][nUsado] := &cVarTemp
			ElseIf X3_CONTEXT == "V"
				aCols[nCnt][nUsado] := CriaVar(AllTrim(X3_CAMPO))
			Endif
		Endif
		dbSkip()
	End
	dbSelectArea(cAlias)
	dbSkip()
End

DEFINE MSDIALOG oDlg TITLE cCadastro From 0,0 To 36,100 OF oMainWnd

@ 15, 2 TO 55,394 LABEL "Simula็ใo de Custos" OF oDlg PIXEL

@ 24, 006 SAY "Nบ da Simula็ใo....:"                SIZE 078,7 PIXEL OF oDlg
@ 24, 110 SAY "Descri็ใo............:"              SIZE 078,7 PIXEL OF oDlg
@ 24, 304 SAY "Data de Emissใo.....:"               SIZE 078,7 PIXEL OF oDlg

@ 39, 006 SAY "Incluํdo por............:"           SIZE 078,7 PIXEL OF oDlg
@ 39, 110 SAY "Qtde. Base..........:"               SIZE 078,7 PIXEL OF oDlg
@ 39, 304 SAY "Status......................:"       SIZE 078,7 PIXEL OF oDlg

@ 23, 053 MSGET cNum    When .F. PICTURE "999999"   SIZE 026,7 PIXEL OF oDlg
@ 23, 154 MSGET cDescri When .F. PICTURE "@!"       SIZE 120,7 PIXEL OF oDlg
@ 23, 354 MSGET dData   When .F. PICTURE "99/99/99" SIZE 032,7 PIXEL OF oDlg

If cStatus == "A"
	cStatus := "APROVADA "
Else
	cStatus := "EM ABERTO"
Endif

@ 38, 053 MSGET cInclui  When .F. PICTURE "@!"            SIZE 48,7 PIXEL OF oDlg
@ 38, 154 MSGET nQtdBase When .F. PICTURE "@E 999,999.99" SIZE 48,7 PIXEL OF oDlg
@ 38, 354 MSGET cStatus  When .F. PICTURE "@!"            SIZE 30,7 PIXEL OF oDlg

@ 201, 2 TO 255,394 LABEL "" OF oDlg PIXEL

dbSelectArea("SMC")
dbSetOrder(1)
dbSeek(xFilial("SMC") + cNum)

While !EOF() .And. SMC->MC_NUM == cNum
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+SMC->MC_PROD)
	
	RecLock("SMC", .F.)
		SMC->MC_PRCUNI := SB1->B1_CUSTD
	SMC->( MsUnLock() )
	
	nCusto += (SMC->MC_QTDPRO * SMC->MC_PRCUNI)/nQtdBase
	
	dbSelectArea("SMC")
	dbSkip()
	
Enddo

dbSelectArea("SMC")
dbSetOrder(1)
dbSeek(xFilial("SMC") + cNum)

While !EOF() .And. SMC->MC_NUM == cNum
	
	nRepCus := ((100 * SMC->MC_QTDPRO * SMC->MC_PRCUNI)/nQtdBase)/nCusto
	
	RecLock("SMC",.F.)
		SMC->MC_REPCUS := Round(nRepCus, 2)
	SMC->( MsUnLock() )
	
	dbSelectArea("SMC")
	dbSkip()
	
Enddo

@ 220,095 SAY "Custo por KG do Novo Produto..........:" SIZE 150,9 PIXEL OF oDlg                         FONT oFont1
@ 219,248 SAY "R$ "                                     SIZE 012,9 PIXEL OF oDlg PICTURE "@!"            FONT oFont1 COLOR CLR_HRED
@ 219,257 SAY nCusto                                    SIZE 094,9 PIXEL OF oDlg PICTURE "@E 999,999.99" FONT oFont1 COLOR CLR_HRED

oGet := MSGetDados():New(59,3,199,393,nOpcX)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End()},{||oDlg:End()})

If nOpcA == 1
	
	dbSelectArea("SMC")
	dbSetOrder(1)
	dbSeek(xFilial("SMC") + cNum)
	
	If Len(AllTrim(SMC->MC_STATUS)) == 0
		
		dbSelectArea(cAlias)
		dbSetOrder(1)
		nCnt := 0
		For nX = 1 to Len(aCols)
			dbSeek(cFilSMC + cNum + aCols[nX][Mod2Pesq("MC_ITEM")])
			RecLock(cAlias,.F.)
				dbDelete()
			(cAlias)->( MsUnLock() )
			nCnt++
		Next nX

	Else
		MsgStop("Simula็ใo ja Aprovada!")
	Endif
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ESTX002  บAutor  ณTiago O. Beraldi    บ Data ณ  31/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ VALIDA LINHA                                               บฑฑ
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
Static Function Mod2LinOk()

Local lRet := .T.
Local nY   := 0
Local nI   := 0
Local cMsg := ""

If !aCols[n][nUsado+1]
	If Empty(aCols[n][2])
		cMsg := "Informe o Produto!"
		MsgStop(cMsg)
		lRet := .F.
	Elseif aCols[n][3] == 0
		cMsg := "Informe a Quantidade!"
		MsgStop(cMsg)
		lRet := .F.
	Endif
Endif

Return lRet 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ESTX002  บAutor  ณTiago O. Beraldi    บ Data ณ  31/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ POSICAO DO CAMPO NO VETOR                                  บฑฑ
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
Static Function Mod2Pesq(cCampo)
Local nPos := 0

nPos := aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper(RTrim(cCampo))})

Return nPos

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ESTX002  บAutor  ณTiago O. Beraldi    บ Data ณ  31/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ VALIDA TUDO                                                บฑฑ
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
Static Function Mod2TudOk()

Local lRet  := Mod2LinOk()
Local nSoma := 0

For nI := 1 To Len(aCols)
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1") + aCols[nI, Mod2Pesq("MC_PROD")]))	
	
	If SB1->B1_TIPO != "MO"
		nSoma += aCols[nI,Mod2Pesq("MC_QTDPRO")]
	EndIf
Next nI

If nSoma <> nQtdBase
	
	MsgStop("Quantidades Base e dos Produtos da Estrutura divergentes!")
	nSoma := 0
	nI    := 0
	//lRet  := .F.
	
Endif

Return lRet    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ESTX002R บAutor  ณTiago O. Beraldi    บ Data ณ  31/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ ATUALIZA QUANTIDADE UTILIZADA NA FORMACAO DA ESTRUTURA     บฑฑ
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
User Function ESTX002R()
         
nQtdAtu := 0

For nI := 1 To Len(aCols)                         

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1") + aCols[nI, Mod2Pesq("MC_PROD")]))	
	
	If SB1->B1_TIPO != "MO"
		nQtdAtu += aCols[nI,Mod2Pesq("MC_QTDPRO")]
	EndIf

Next nI     

oQtdAtu:Refresh()	  

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ESTX002  บAutor  ณTiago O. Beraldi    บ Data ณ  31/05/04   บฑฑ
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
Static Function SMCGrava(cAlias)

Local lRet := .T.
Local nI   := 0
Local nY   := 0
Local cVar := ""
Local lOk  := .T.
Local cMsg := ""

dbSelectArea("SMC")
dbSetOrder(1)

For nI := 1 To Len(aCols)
	dbSeek(cFilSMC + cNum + aCols[nI][Mod2Pesq("MC_ITEM")])
	
	If !aCols[nI][nUsado+1]
		RecLock(cAlias,.T.)
			SMC->MC_FILIAL     := cFilSMC
			SMC->MC_NUM        := cNum
			SMC->MC_STATUS     := ""
			SMC->MC_DESCRI     := cDescri
			SMC->MC_DATA       := dData
			SMC->MC_QTBASE     := nQtdBase
			SMC->MC_INCLUI     := cInclui
			
			For nY = 1 to Len(aHeader)
				If aHeader[nY][10] # "V"
					cVar := Trim(aHeader[nY][2])
					Replace &cVar. With aCols[nI][nY]
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
			cMsg := "Nao foi possivel deletar o item "+aCols[nI][Mod2Pesq("MC_ITEM")]+", o mesmo possui amarracao"
			MsgStop(cMsg)
		Endif
	Endif
	
Next nI

dbSelectArea("SMC")
dbSetOrder(1)
dbSeek(xFilial("SMC") + cNum)

Return lRet 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ESTX002  บAutor  ณTiago O. Beraldi    บ Data ณ  31/05/04   บฑฑ
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
User Function ESTX002L(nOpc)

BrwLegenda(cCadastro, "Legenda", {{"BR_AMARELO"  ,"Simula็ใo Aprovada"  },;
                                   {"BR_PRETO"    ,"Simula็ใo Cadastrada"},;
								   {"BR_AZUL"     ,"Simula็ใo em Aberto" }})

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ESTX002  บAutor  ณTiago O. Beraldi    บ Data ณ  31/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ IMPRESSAO                                                  บฑฑ
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
User Function ESTX002I()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local wnrel   := "ESTX002I"
Local tamanho :="M"
Local titulo  :="Relat๓rio de Simula็ใo"
Local cDesc1  :="Emisso do Relat๓rio de Simula็ใo"
Local cDesc2  :="conforme parโmetros estipulados."
Local cDesc3  :=""
Local CbCont,cabec1,cabec2
Local cString :="SMC"

Private aReturn  := {"Zebrado", 1, "P.C.P.", 2, 2, 1, "",0}
Private nomeprog := "ESTX002I", nLastKey := 0, nBegin := 0, aLinha := { }
Private li := 80, limite := 132, lRodape := .F.
Private nTotQtd := nTotVal := 0

If Empty(SMC->MC_STATUS)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	cbtxt    := SPACE(10)
	cbcont   := 0
	li       :=80
	m_pag    :=1
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica as perguntas selecionadas                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	wnrel:=SetPrint(cString,wnrel,,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)
	
	If nLastKey == 27
		Set Filter to
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Set Filter to
		Return
	Endif
	
	RptStatus({|lEnd| EPCP001IMP(@lEnd,wnRel,cString)},Titulo)
	
Else
	
	MsgStop("S๓ estแ habilitada a impressใo de simula็๕es em aberto. Fale com seu supervisor.")
	
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ESTX002  บAutor  ณTiago O. Beraldi    บ Data ณ  31/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ CHAMADA DE IMPRESSAO                                       บฑฑ
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
Static Function EPCP001IMP(lEnd,WnRel,cString)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local tamanho :="M"
Local titulo  :=OemToAnsi("Relat๓rio de Simula็ใo")
Local cDesc1  :=OemToAnsi("Emisso do Relat๓rio de Simula็ใo")
Local cDesc2  :=OemToAnsi("conforme parโmetros estipulados.")
Local cDesc3  :=""
Local CbCont,cabec1,cabec2
Local lContinua := .T.,	lFirst := .T.
Local cPedAnt := "   "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cbtxt    := SPACE(10)
cbcont   := 0
li       :=80
m_pag    :=1
nTipo    :=IIF(aReturn[4]==1,15,18)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao dos cabecalhos                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Titulo := " R E L A T ำ R I O   D E   S I M U L A ว ร O " //
cabec1 := ""
cabec2 := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Impressao                                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

cabec(Titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)

cNum := SMC->MC_NUM

@ li,000 Psay Replicate("*",limite)
li++
@ li,000 Psay "Simula็ใo  : "+ SMC->MC_NUM
@ li,050 Psay "Descri็ใo  : "+ SMC->MC_DESCRI
li++
li++
@ li,000 Psay "Base do Cแlculo  : "
@ li,020 Psay SMC->MC_QTBASE Picture "@E 999,999.99"
@ li,050 Psay "Custo por Kilo   : "

cCusto := 0

dbSelectArea("SMC")
dbSetOrder(1)
dbSeek(xFilial("SMC") + cNum)

While !EOF() .And. SMC->MC_NUM == cNum
	
	cCusto := cCusto + ((Iif(SM0->M0_CODIGO == "05",SMC->MC_QTPRO,SMC->MC_QTDPRO)*SMC->MC_PRCUNI)/SMC->MC_QTBASE)
	
	dbSelectArea("SMC")
	dbSkip()
Enddo

@ li,070 Psay "R$ "+Transform(cCusto,"@E 999,999.99")
li++
@ li,000 PSAY __PrtFatLine()
li++
@ li,000 Psay " C O M P O N E N T E S "
li++
@ li,000 PSAY __PrtThinLine()
li++
@ li,000 Psay "C๓digo          Descri็ใo                               Quantidade       Pre็o          Rep.Custo(%)"
li++
@ li,000 PSAY __PrtFatLine()
li++

dbSelectArea("SMC")
dbSetOrder(1)
dbSeek(xFilial("SMC") + cNum)

While !EOF() .And. SMC->MC_NUM == cNum
	
	IF li > 65
		lFirst := .F.
		cabec(Titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Endif
	
	@ li,000 Psay SMC->MC_PROD

	dbSelectArea("SB1")
	dbSetorder(1)
	dbSeek(xFilial("SB1") + SMC->MC_PROD)

	@ li,016 Psay SB1->B1_DESC
	@ li,054 Psay SMC->MC_QTDPRO Picture "@E 999,999.99"
	@ li,074 Psay SMC->MC_PRCUNI
	@ li,094 Psay SMC->MC_REPCUS
	li++   
	
	@ li,000 Psay __PrtThinLine()
	li++    
	
	dbSelectArea("SMC")
	dbSkip()
	
Enddo

@ li,000 PSAY __PrtFatLine()
li++

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Restaura a Integridade dos dados                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SMC")
dbSetOrder(1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se em disco, desvia para Spool                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aReturn[5] = 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ESTX002  บAutor  ณTiago O. Beraldi    บ Data ณ  31/05/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ COPIA FORMULA                                              บฑฑ
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
Static Function CopiaFormula()

Private nItem := 1

Pergunte("ESTX002", .T.)       

If mv_par01 == 1 //Cadastro de Simulacoes
 
	SMC->(dbSetOrder(1))
	If SMC->(dbSeek(xFilial("SMC") + AllTrim(mv_par02)))
		        
		cDescri := SMC->MC_DESCRI
	    nQtdBase:= SMC->MC_QTBASE
	
		While !SMC->(EOF()) .And. AllTrim(SMC->MC_NUM) == AllTrim(mv_par02)
		
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Cria linha em branco no acols de acordo com o tamanho do aHeader ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If nItem <> 1
				Aadd(aCols, Array(Len(aHeader)+1))
				aCols[Len(aCols), Len(aHeader)+1] := .f.
			EndIf
			
			nItem++
			
			aCols[Len(aCols), Mod2Pesq("MC_ITEM")  ] := SMC->MC_ITEM
			aCols[Len(aCols), Mod2Pesq("MC_PROD")  ] := SMC->MC_PROD
			aCols[Len(aCols), Mod2Pesq("MC_QTDPRO")] := SMC->MC_QTDPRO
			aCols[Len(aCols), Mod2Pesq("MC_PRCUNI")] := SMC->MC_PRCUNI
			aCols[Len(aCols), Mod2Pesq("MC_REPCUS")] := SMC->MC_REPCUS
			
			SMC->(dbSkip()) 
			
		EndDo

	Else    
	
		ApMsgStop("Simula็ใo nใo encontrada!")
	
	EndIf    
	
Else //Cadastro de Produto

	SG1->(dbSetOrder(1))
	If SG1->(dbSeek(xFilial("SG1") + AllTrim(mv_par02)))
		        
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + AllTrim(mv_par02)))
	
		cDescri := SB1->B1_DESC
	    nQtdBase:= SB1->B1_QB
	
		While !SG1->(EOF()) .And. Alltrim(SG1->G1_COD) == AllTrim(mv_par02)
		
			If !(SG1->G1_REVINI <= mv_par03 .And. SG1->G1_REVFIM >= mv_par03)
			    SG1->(dbSkip())
			    Loop
			EndIf
		
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Cria linha em branco no acols de acordo com o tamanho do aHeader ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If nItem <> 1
				Aadd(aCols, Array(Len(aHeader)+1))
				aCols[Len(aCols), Len(aHeader)+1] := .f.
			EndIf
			              
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1") + SG1->G1_COMP))
		
			aCols[Len(aCols), Mod2Pesq("MC_ITEM")  ] := StrZero(nItem, 2)
			aCols[Len(aCols), Mod2Pesq("MC_PROD")  ] := SG1->G1_COMP
			aCols[Len(aCols), Mod2Pesq("MC_QTDPRO")] := SG1->G1_QUANT
			aCols[Len(aCols), Mod2Pesq("MC_PRCUNI")] := SB1->B1_CUSTD
			aCols[Len(aCols), Mod2Pesq("MC_REPCUS")] := 100 * ((SG1->G1_QUANT * SB1->B1_CUSTD) / nQtdBase)
						
			nItem++
			
			SG1->(dbSkip()) 
			
		EndDo

	Else    
	
		ApMsgStop("Produto nใo encontrado!")
	
	EndIf    
	
EndIf	   
                     
GetdRefresh()	               

Atualiza()

Return
