#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#include "protheus.ch"       

#define PAD_LEFT            0
#define PAD_RIGHT           1
#define PAD_CENTER          2

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ QIPX001  บ Autor ณTiago O. Beraldi    บ Data ณ  31/01/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ CADASTRO DE BOLETIM TECNICO                                บฑฑ
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
User Function QIPX001()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de variaveis                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cAlias    := "SZE"
Private cFilial   := xFilial(cAlias)
Private cCadastro := "Cadastro de Boletim T้cnico"
Private aRotina   := {}   
Private oBrw1                          

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Funcoes do Browse                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd( aRotina, {"Pesquisar"  ,"AxPesqui"     ,0,1})
aAdd( aRotina, {"Visualizar" ,"U_QIPX01Fc(2)",0,2})
aAdd( aRotina, {"Incluir"    ,"U_QIPX01Fc(3)",0,3})
aAdd( aRotina, {"Alterar"    ,"U_QIPX01Fc(4)",0,4})
aAdd( aRotina, {"Excluir"    ,"U_QIPX01Fc(5)",0,5})
aAdd( aRotina, {"Imprimir"   ,"U_QIPX01Fc(6)",0,2})

dbSelectArea(cAlias)
dbSetOrder(1)
dbGoTop()                     

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta Browse                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
mBrowse(06, 01, 22, 75, cAlias,,,,,,)

dbSelectArea(cAlias)
dbSetOrder(1)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ QIPX01FC บ Autor ณTiago O. Beraldi    บ Data ณ  06/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ FUNCOES                                                    บฑฑ
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
User Function QIPX01Fc(nOpc)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de variaveis                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private	aHeader   := {}
Private	aCols     := {}
Private aDataC    := {}
Private noBrw1    := 0
Private aButtons  := {}

SetPrvt("oDlg1","oGrp1","oSay1","oSay2","oSay3","oSay4","oSay5","oGet1","oGet2","oGet3","oGet4","oGrp2")

If nOpc == 3
	aAdd(aDataC, {CriaVar("ZE_PRODUTO"), .T.})  // Produto                    
	aAdd(aDataC, {dDataBase            , .T.})  // Data de Revisao          
	aAdd(aDataC, {CriaVar("ZE_REVISAO"), .T.})  // Numero da Revisao
	If Left(cFilAnt,2) == "02"
		aAdd(aDataC, {CriaVar("ZE_DIVISAO"), .T.})  // Divisao do Produto
	EndIf
ElseIf nOpc == 2 .Or. nOpc == 5
	aAdd(aDataC, {SZE->ZE_PRODUTO, .F.})  // Produto                    
	aAdd(aDataC, {SZE->ZE_DTREVIS, .T.})  // Data de Revisao          
	aAdd(aDataC, {SZE->ZE_REVISAO, .T.})  // Numero da Revisao
	If Left(cFilAnt,2) == "02"
		aAdd(aDataC, {SZE->ZE_DIVISAO, .F.})  // Divisao do Produto
	EndIf
ElseIf nOpc == 4
	aAdd(aDataC, {SZE->ZE_PRODUTO, .F.})  // Produto                    
	aAdd(aDataC, {SZE->ZE_DTREVIS, .T.})  // Data de Revisao          
	aAdd(aDataC, {SZE->ZE_REVISAO, .T.})  // Numero da Revisao
	If Left(cFilAnt,2) == "02"
		aAdd(aDataC, {SZE->ZE_DIVISAO, .T.})  // Divisao do Produto
	EndIf
ElseIf nOpc == 6
	ImprimeBol()
	Return
EndIf                            

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//| Definicao do Dialog e seus conteudos                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd( aButtons, {"HISTORIC", {|| ConsEspec()()}, "Especifica็ใo...", "Especifica็ใo", {|| .T.}})     

oDlg1      := MSDialog():New( 250,310,671,906,cCadastro,,,.F.,,,,,,.T.,,,.T. )
                                                                                    
oDlg1:bInit := {||EnchoiceBar(oDlg1,{|| ExecFunc(nOpc), oDlg1:End()},{|| oDlg1:End()},.F.,@aButtons)}

oGrp1      := TGroup():New( 014,004,050,293,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )

//Produto
oSay3      := TSay():New( 022,008,{||"Produto"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGet1      := TGet():New( 020,032,{|u| If(PCount()>0,aDataC[01,01]:=u,aDataC[01,01])},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,!aDataC[01,02],.F.,"SB1","aDataC[01,01]",,)
If nOpc != 5
	oGet1:bLostFocus := {|| oSay1:cCaption := Posicione("SB1",1,xFilial("SB1")+aDataC[01,01],"B1_DESC"), oSay1:Refresh()}
EndIf
oSay1     := TSay():New( 022,095,{||Posicione("SB1",1,xFilial("SB1")+aDataC[01,01],"B1_DESC")},oGrp1,,,.F.,.F.,.F.,.T.,CLR_HRED,CLR_WHITE,102,008)
oGet1:bValid := {|| !Empty(Posicione("SB1",1,xFilial("SB1")+aDataC[01,01],"B1_COD")) .And. !ExistBol(aDataC[01,01])}

//Revisao
oSay5      := TSay():New( 022,194,{||"Revisใo"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGet2      := TGet():New( 020,226,{|u| If(PCount()>0,aDataC[02,01]:=u,aDataC[02,01])},oGrp1,045,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,!aDataC[02,02],.F.,"","aDataC[02,01]",,)
oGet3      := TGet():New( 020,272,{|u| If(PCount()>0,aDataC[03,01]:=u,aDataC[03,01])},oGrp1,016,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,!aDataC[03,02],.F.,"","aDataC[03,01]",,)
         
//Divisao 
If Left(cFilAnt,2) == "02"
	oSay4      := TSay():New( 035,008,{||"Divisใo"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oGet4      := TGet():New( 033,032,{|u| If(PCount()>0,aDataC[04,01]:=u,aDataC[04,01])},oGrp1,040,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,!aDataC[04,02],.F.,"ZE","aDataC[04,01]",,)
	oGet4:bLostFocus := {|| oSay2:cCaption := Tabela("ZE", aDataC[04,01]), oSay2:Refresh()}
	oSay2     := TSay():New( 035,095,{|| Iif(Empty(aDataC[04,01]),"", Tabela("ZE", aDataC[04,01]))},oGrp1,,,.F.,.F.,.F.,.T.,CLR_HRED,CLR_WHITE,102,008)
EndIf

oGrp2      := TGroup():New( 054,004,212,294,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )

MHoBrw1(nOpc)
MCoBrw1(nOpc)    

oBrw1      := MsNewGetDados():New(062,008,197,288, Iif(nOpc == 2 .Or. nOpc == 5, GD_DELETE, GD_INSERT + GD_UPDATE),'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',oGrp2,aHeader,aCols)
oBrw1:oBrowse:lHScroll       := .F.

oDlg1:Activate(,,,.T.)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMHoBrw1() บ Autor ณTiago O. Beraldi    บ Data ณ  06/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ MONTA O AHEADER DA MSNEWGETDADOS                           บฑฑ
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
Static Function MHoBrw1(nOpc)

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SZE")

While !Eof() .and. SX3->X3_ARQUIVO == "SZE"
   If X3Uso(SX3->X3_USADO) .And. SX3->X3_NIVEL > 0
      noBrw1++
      aAdd(aHeader,{Trim(X3Titulo()),;
           SX3->X3_CAMPO,;
           SX3->X3_PICTURE,;
           SX3->X3_TAMANHO,;
           SX3->X3_DECIMAL,;
           "",;
           "",;
           SX3->X3_TIPO,;
           "",;
           "" } )
   EndIf
   dbSkip()
End

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MCoBrw1()บ Autor ณTiago O. Beraldi    บ Data ณ  06/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ MONTA O ACOLS DA MSNEWGETDADOS                             บฑฑ
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
Static Function MCoBrw1(nOpc)

Local cAux := SZE->ZE_PRODUTO          

aCols := {}
                            
If nOpc == 3 
	aAdd(aCols, Array(noBrw1 + 1))
	For nI := 1 To noBrw1
	   aCols[1][nI] := CriaVar(aHeader[nI][2])
	Next
	aCols[1][noBrw1+1] := .F.
Else         
	SZE->(dbSetOrder(1))      
	SZE->(MsSeek(xFilial("SZE") + cAux))      
	While !SZE->(EOF()) .And. SZE->ZE_PRODUTO == cAux
		aAdd(aCols,{SZE->ZE_TITULO, SZE->ZE_DESCTIT, .F.})
		SZE->(dbSkip())
	EndDo
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ExecFunc บ Autor ณTiago O. Beraldi    บ Data ณ  06/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ GRAVA DADOS NA TABELA                                      บฑฑ
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
Static Function ExecFunc(nOpc) 

Local cVar   := ""           
Local cChave := aDataC[01,01]  

dbSelectArea("SZE")
dbSetOrder(1)
dbSeek(xFilial("SZE") + cChave)

For nI := 1 To Len(oBrw1:aCols)
		
	If nOpc <> 5 .And. !oBrw1:aCols[nI,03]
		   
		If !dbSeek(xFilial("SZE") + cChave + oBrw1:aCols[nI][01]) .Or. nOpc == 3
			RecLock(cAlias, .T.)
		Else
			RecLock(cAlias, .F.)
		Endif       
		
		For nY = 1 to Len(aHeader)
			If aHeader[nY][10] # "V" 
			    cVar := Trim(aHeader[nY][2])
				&cVar := oBrw1:aCols[nI][nY]
			Endif
		Next nY  
		
		SZE->ZE_PRODUTO := aDataC[01,01]
		If Left(cFilAnt,2) == "02"
			SZE->ZE_DIVISAO := aDataC[04,01]
		EndIf
		SZE->ZE_REVISAO := aDataC[03,01]
		SZE->ZE_DTREVIS := aDataC[02,01]									
		SZE->ZE_DESC	:= Posicione("SB1",1,xFilial("SB1")+aDataC[01,01],"B1_DESC")
		
		SZE->( MsUnLock() )
		
	Else
		
		If dbSeek(xFilial("SZE") + cChave + oBrw1:aCols[nI][01])
		
			RecLock(cAlias,.F.)
				dbDelete()
			(cAlias)->( MsUnLock() )
		
		Endif
		
	Endif
	
Next nI        

oBrw1:Refresh()

dbSelectArea("SZE")
dbSetOrder(1)
dbSeek(xFilial("SZE") + cChave)

Return                                          

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ExistBol บ Autor ณTiago O. Beraldi    บ Data ณ  06/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ VERIFICA SE EXISTE BOLETIM                                 บฑฑ
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
Static Function ExistBol(cProduto)
SZE->(dbSetOrder(1))
Return SZE->(dbSeek(xFilial("SZE") + cProduto))     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImprimeBolบ Autor ณTiago O. Beraldi    บ Data ณ  06/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ VERIFICA SE EXISTE BOLETIM                                 บฑฑ
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
Static Function ImprimeBol()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de variaveis                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private nLin       := 10000
Private nPage      := 1      
Private cNomLogo   := Iif(Subs(Posicione("SB1", 1, xFilial("SB1") + SZE->ZE_PRODUTO, "B1_GRUPO"),1,1) == "3","QUALY.BMP","EURO.BMP") 
Private nLarg      := 315
Private nAlt       := 205      
Private cTitulo    := AllTrim(Posicione("SB1", 1, xFilial("SB1") + SZE->ZE_PRODUTO, "B1_DESC"))
Private cProduto   := SZE->ZE_PRODUTO  
Private dDataRev   := SZE->ZE_DTREVIS
Private cRevisao   := SZE->ZE_REVISAO

//Fontes do relatorio
oFont1 := TFont():New( "Tahoma",,08,,.t.,,,,,.f.)
oFont2 := TFont():New( "Tahoma",,08,,.f.,,,,,.f.)
oFont3 := TFont():New( "Tahoma",,14,,.t.,,,,,.f.)
oFont4 := TFont():New( "Tahoma",,10,,.f.,,,,,.f.)
oFont5 := TFont():New( "Tahoma",,10,,.t.,,,,,.f.)
oFont6 := TFont():New( "Tahoma",,06,,.f.,,,,,.f.)

//Inicializa o Objeto de impressao
oPrn   := TMSPrinter():New() 

//Inicio da Impressao
oPrn:Say( 0020, 0020, " ", oFont2, 0100)    //Startando a impressora
      
fCabec()

dbSelectArea("SZE")
dbSetOrder(1)
dbSeek(xFilial("SZE") + cProduto)

nLin := 400

While !EOF("SZE") .And. SZE->ZE_PRODUTO == cProduto

	oPrn:Say( nLin, 0100, Tabela("ZF", SZE->ZE_TITULO), oFont5,,,, PAD_LEFT) 
	nLin += 75
                  
    If SZE->ZE_TITULO <> "000002" //Especificacoes
		nCol := 130 
		For nn := 1 To MlCount(SZE->ZE_DESCTIT, nCol)
			cText := Memoline(SZE->ZE_DESCTIT, nCol, nn)
			oPrn:Say( nLin, 0100, cText, oFont4,,,, PAD_LEFT)
			nLin += 60

		    If nLin > 2700 
				fRodape()
		   		oPrn:EndPage()
				oPrn:StartPage()
				fCabec()
				nLin := 400
				nPage++
			EndIf

	    Next                                
	Else
		fDetalhe()
	EndIf
    
    nLin += 60

    If nLin > 2700 
		fRodape()
   		oPrn:EndPage()
		oPrn:StartPage()
		fCabec()
		nLin := 400
		nPage++
	EndIf

	dbSelectArea("SZE")	    	
	dbSkip()
EndDo            

fRodape()
	
oPrn:Setup()   // Configurar impressora
oPrn:Preview() // Visualiza relatorio na tela

Return

Static Function fRodape()

oPrn:Box( 2850, 0100, 2853, 2350 )
oPrn:Say( 2900, 1220, "As informa็๕es aqui descritas correspondem o melhor de nosso conhecimento sobre propriedades deste produto, nใo representando qualquer garantia de performance do produto,", oFont6,,,, PAD_CENTER)
oPrn:Say( 2940, 1220, "visto que as condi็๕es de aplica็ใo deste nใo estใo sob nosso controle. Para qualquer aplica็ใo sugerimos testes pr้vios a fim de ratificar as propriedades descritas acima", oFont6,,,, PAD_CENTER)
If cNomLogo == "EURO.BMP"
	oPrn:Say( 3040, 1220, "Euroamerican do Brasil Importa็ใo, Ind๚stria e Com้rcio Ltda. - Av. Antonio Bardella, 598 - Vl Mแrcia - Jandira - SP", oFont6,,,, PAD_CENTER)
	oPrn:Say( 3080, 1220, "Visite nossa pแgina: www.euroamerican.com.br - PABX: (11)4619-8400 - FAX: (11)4619-8425", oFont6,,,, PAD_CENTER)
Else
	oPrn:Say( 3040, 1220, "Qualyvinil Comercial Ltda. - Rua Jorge Pedroso, 95 - Jd Sใo Luํs - Jandira - SP", oFont6,,,, PAD_CENTER)
	oPrn:Say( 3080, 1220, "Visite nossa pแgina: www.qualyvinil.com.br - PABX: (11)4789-3111 - SAC: 0800-109972", oFont6,,,, PAD_CENTER)	
EndIf

oPrn:Say( 3180, 1220, "Revisใo Nบ " + cRevisao + Space(70) + " Data da Revisใo: " + MesExtenso(dDataRev) + "/" + AllTrim(Str(Year(dDataRev))) + Space(75) + " Pแgina " + StrZero(nPage, 2), oFont1,,,, PAD_CENTER)
oPrn:Box( 3220, 0100, 3223, 2350 )
Return

Static Function fCabec()
                                                                    
oPrn:Say( 0110, 0100, Iif(cNomLogo == "EURO.BMP", "Euroamerican do Brasil", "Qualyvinil"), oFont1,,,, PAD_LEFT)
oPrn:Box( 0177, 0100, 0180, 2038 )
oPrn:SayBitmap( 0033, 2070, cNomLogo, nLarg, nAlt )       
If Left(cFilAnt,2) == "02"
	If !Empty(SZE->ZE_DIVISAO)
		oPrn:Say( 0200, 0100, Capital(Tabela("ZE", SZE->ZE_DIVISAO)), oFont2,,,, PAD_LEFT)
	EndIf
EndIf
oPrn:Say( 0270, 1220 ,cTitulo, oFont3,,,, PAD_CENTER)

Return 

Static Function fDetalhe()

Local aDadosI := {}  //Matriz Itens               

dbSelectArea("QPJ")    
dbSetOrder(1)
dbSeek(xFilial("QPJ") + SZE->ZE_PRODUTO)

While !EOF("QPJ") .And. QPJ->QPJ_PROD == SZE->ZE_PRODUTO

	/************************** aDadosI	***********************
	1  - Descricao do Ensaio
	2  - Metodo de Analise   
	3  - Lim Inferior                 
	4  - Lim Superior               
	5  - Resultado texto padrao              
	6  - Limite da medida
	/*********************************************************/

	//Matriz Vetor Detalhe
	aAdd(aDadosI,{Posicione("QP1", 1, xFilial("QP1") + QPJ->QPJ_ENSAIO, "QP1_DESCPO");
                , Upper(QPJ->QPJ_METODO);
	            , AllTrim(Transform(QPJ->QPJ_LINF, "@E 999,999.99"));
	            , AllTrim(Transform(QPJ->QPJ_LSUP, "@E 999,999.99"));
	            , Upper(AllTrim(QPJ->QPJ_TEXTO));
	            , QPJ->QPJ_LIMITE})
	
	dbSelectArea("QPJ")
	dbSkip()
EndDo

       
For i := 1 to Len(aDadosI)    

	oPrn :Say( nLin, 0100, aDadosI[i][1], oFont4,,,, PAD_LEFT)
	                      
	If aDadosI[i][6] == "2"
		oPrn :Say( nLin, 1450, Iif(!Empty(aDadosI[i][5]), aDadosI[i][5],;
	            "Max. " + aDadosI[i][4]), oFont4,,,, PAD_LEFT)
	ElseIf aDadosI[i][6] == "3"
		oPrn :Say( nLin, 1450, Iif(!Empty(aDadosI[i][5]), aDadosI[i][5],;
	            "Min. " + aDadosI[i][3]), oFont4,,,, PAD_LEFT)
	Else
		oPrn :Say( nLin, 1450, Iif(!Empty(aDadosI[i][5]), aDadosI[i][5],;
                aDadosI[i][3] + " - " + aDadosI[i][4]), oFont4,,,, PAD_LEFT)
    EndIf	
    
    nLin += 60
	
Next i

nLin += 75
	
Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ QIPX001  บ Autor ณTiago O. Beraldi    บ Data ณ  31/01/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ CONSULTA ESPECIFICACAO                                     บฑฑ
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
Static Function ConsEspec()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aArea       := GetArea()   
Local oDlg1 
Local aEspec      := {}  
Local aDadosI     := {}

Private aHeader1  := {}
Private aColumns1 := {}   

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//| Alimenta vetor com especificacao                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

dbSelectArea("QPJ")    
dbSetOrder(1)
dbSeek(xFilial("QPJ") + aDataC[01,01])

While !EOF("QPJ") .And. QPJ->QPJ_PROD ==  aDataC[01,01]

	/************************** aDadosI	***********************
	1  - Descricao do Ensaio
	2  - Metodo de Analise   
	3  - Lim Inferior                 
	4  - Lim Superior               
	5  - Resultado texto padrao              
	6  - Limite da medida
	/*********************************************************/

	//Matriz Vetor Detalhe
	aAdd(aDadosI,{Posicione("QP1", 1, xFilial("QP1") + QPJ->QPJ_ENSAIO, "QP1_DESCPO");
                , Upper(QPJ->QPJ_METODO);
	            , AllTrim(Transform(QPJ->QPJ_LINF, "@E 999,999.99"));
	            , AllTrim(Transform(QPJ->QPJ_LSUP, "@E 999,999.99"));
	            , Upper(AllTrim(QPJ->QPJ_TEXTO));
	            , QPJ->QPJ_LIMITE})
	
	dbSelectArea("QPJ")
	dbSkip()
EndDo

       
For i := 1 to Len(aDadosI)    
    
	aAdd(aEspec, {"",""})
	
	aEspec[i,1] := aDadosI[i,1]
	                      
	If aDadosI[i][6] == "2"
		aEspec[i,2] :=  Iif(!Empty(aDadosI[i][5]), aDadosI[i][5], "Max. " + aDadosI[i][4])
	ElseIf aDadosI[i][6] == "3"
		aEspec[i,2] :=  Iif(!Empty(aDadosI[i][5]), aDadosI[i][5], "Min. " + aDadosI[i][3])
	Else
		aEspec[i,2] :=  Iif(!Empty(aDadosI[i][5]), aDadosI[i][5], aDadosI[i][3] + " - " + aDadosI[i][4])
    EndIf	
    
Next i

		
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//| Estrutura do MarkBrowse                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aHeader1 , {"Ensaio                        ", "Especifica็ใo                 "})
aAdd(aColumns1, {30, 30})     

If Empty(aEspec)
     MsgAlert("Nใo foram encontrados dados para a consulta!", "Aten็ใo")
     Return
EndIf                                           

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//| Apresenta o MarkBrowse para o usuario                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oDlg1           := MSDialog():New(000, 000, 231, 394, "Especifica็ใo do Produto " + aDataC[01,01],,,,,,,, oMainWnd, .T.)
oDlg1:lCentered := .T.
                                  
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Desenha os GroupBoxes                                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oGrpo1 := TGroup():New(002, 003, 115, 196,, oDlg1,,, .T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Desenha o MarkBrowse.                                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oBrw1 := TWBrowse():New(007, 007, 185, 104,, aHeader1[1], aColumns1[1], oDlg1,,,,,,,,,,,,,, .T.)
oBrw1 :SetArray(aEspec)
oBrw1 :bLine := {|| {;
                aEspec[oBrw1:nAt][01],;
                aEspec[oBrw1:nAt][02]}}               
oBrw1:lAdJustColSize := .T.
oBrw1:lMChange       := .F.

oDlg1:Activate()    

Return