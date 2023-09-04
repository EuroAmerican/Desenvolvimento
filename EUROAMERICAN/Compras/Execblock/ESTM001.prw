#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#Include "font.ch"

#define ENTER chr(13) + chr(10)
#define PAD_LEFT            0
#define PAD_RIGHT           1
#define PAD_CENTER          2

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณESTM001   บ Autor ณTiago O. Beraldi    บ Data ณ  12/11/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณIMPRESSAO E AUTENTICACAO DE NF ENTRADA                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑฬอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ 16-04-12 บAlexandre Marson  บ Substiuicao das funcoes USRRETGRP e     บฑฑ
ฑฑบ          บ                  บ GRPRETNAME (Chamado TOTVS - TEVELA) pelaบฑฑ
ฑฑบ          บ                  บ funcao PSWRET porque estavam retornando บฑฑ
ฑฑบ          บ                  บ nulo.                                   บฑฑ
ฑฑบ          บ                  บ                                         บฑฑ
ฑฑบ          บ                  บ                                         บฑฑ
ฑฑบ          บ                  บ                                         บฑฑ
ฑฑบ          บ                  บ                                         บฑฑ
ฑฑบ          บ                  บ                                         บฑฑ
ฑฑบ          บ                  บ                                         บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function ESTM001()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cForFld
Local cPathTXT   := "C:\Protheus12\"
Local aDirectory := Directory(cPathTXT + "*.txt")     

Private cLin     := ""
Private oDlgEnt
Private nTarget  := 0
Private nOpc     := 0
Private bOk      := {||nOpc := 1, oDlgEnt:End()}
Private bCancel  := {||nOpc := 0, oDlgEnt:End()}
Private lCheck1  := .T.
Private cNumEnt  := ""                                //Numero de Entrada (Controle Interno)
Private cNumDoc  := ""                                //Numero da NF de Entrada
Private cFornece := ""                                //Codigo + Nome do Fornecedor
Private lUserCom := .F.                               //Usuarios de Compras
Private lUserPor := .F.                               //Usuarios do Recebimento
Private lUserPCP := .F.                               //Usuarios do PCP
Private lUserAlm := .F.                               //Usuarios do Almoxarifado
Private lUserFat := .F.                               //Usuarios do Faturamento
Private cUserCom := ""                                //Usuarios de Compras
Private cUserPor := ""                                //Usuarios do Recebimento
Private cUserPCP := ""                                //Usuarios do PCP
Private lUsrAut  := .F.                               //Usuarios de Autorizacao de Entrada
Private cMsg     := ""
Private aArea    := GetArea()
//Private cPath    := "\\srv-004\pub\utils\tools\CICMsg.exe srv-004 workflow 123456"
Private aGrupos  := {}        

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Apaga arquivos do diretorio                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aEval(aDirectory, {|x| FErase(cPathTXT + x[1])}) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Valida acesso de usuario                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lUserCom := .T. //U_IsGroup("COM-X00")
lUserPor := .T. //U_IsGroup("Administradores#POR-X00")
lUserPCP := .T. //U_IsGroup("PCP-X01")
lUserAlm := .T. //U_IsGroup("Administradores#ALM-X01")
lUserFat := .T. //U_IsGroup("Administradores#FAT-X00")
lUserCtr := .T. //U_IsGroup("Administradores#CON-X00")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta Dialog                                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SF1")

// FS - Nใo permitir se NF bloqueada..
If AllTrim( SF1->F1_STATUS ) == "B"
	ApMsgAlert("Nota fiscal bloqueada, aguarde aprova็ใo para gera็ใo do Ticket de Confer๊ncia!", "Aten็ใo")
	Return
ElseIf Empty( SF1->F1_STATUS )
	ApMsgAlert("Nota fiscal nใo Classificada, aguarde a classifica็ใo da Nota Fiscal para gera็ใo do Ticket de Confer๊ncia!", "Aten็ใo")
	Return
EndIf

//Posiciona Cadastro de Cliente / Fornecedor
If SF1->F1_TIPO <> "B"
	SA2->(dbSetOrder(1))
	SA2->(dbSeek(xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA))
	cForFld := "SA2->A2_NOME"
Else
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1") + SF1->F1_FORNECE + SF1->F1_LOJA))
	cForFld := "SA1->A1_NOME"
EndIf

cNumDoc  := SF1->F1_SERIE + " " + SF1->F1_DOC
cFornece := SF1->F1_FORNECE + "-" + SF1->F1_LOJA + " / " + Subs(&cForFld,1,30)
cEmissao := DtoC(SF1->F1_EMISSAO)

DEFINE MSDIALOG oDlgEnt TITLE "Documento de Entrada" FROM 127,037 TO 330,380 PIXEL

@ 003, 006 To 059,167 TITLE "  Dados da Nota de Entrada  "
@ 010, 010 SAY "Emissใo: "
@ 010, 041 SAY cEmissao COLOR CLR_HBLUE

@ 020, 010 Say "Fornecedor: "
@ 020, 041 Say cFornece COLOR CLR_HBLUE

@ 034, 010 BUTTON "&Autentica" SIZE 50,12 ACTION ImpEnt(1)
@ 034, 060 BUTTON "Au&toriza"  SIZE 50,12 ACTION ImpEnt(2)
@ 034, 110 BUTTON "&Ticket"    SIZE 50,12 ACTION ImpEnt(3)

@ 048, 006 TO 080,167 TITLE "  Conhecimento de Frete  "

@ 055, 010 BUTTON "A&ssocia Conhec."  SIZE 50,12 ACTION ImpEnt(4)
@ 055, 060 BUTTON "Ti&cket/Autentica" SIZE 50,12 ACTION ImpEnt(6)

@ 069, 006 TO 101,167 TITLE "  Confer๊ncia  "

@ 076, 010 BUTTON "&Conf. Almox."  SIZE 50,12 ACTION ImpEnt(7)
@ 076, 060 BUTTON "&Conf. Entrd."  SIZE 50,12 ACTION ImpEnt(8)
@ 076, 110 BUTTON "&Conf. SPED  "  SIZE 50,12 ACTION ImpEnt(9)

ACTIVATE MSDIALOG oDlgEnt ON INIT EnchoiceBar(oDlgEnt,bOk,bCancel) CENTERED

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIMPENT    บ Autor ณTiago O. Beraldi    บ Data ณ  12/11/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณEXECUTA OPERACOES DE ENTRADA                                บฑฑ
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
Static Function ImpEnt(nOpc)

Local lValid    := .F.                   // Liberacao mesmo em caso de divergencia
Local lValid1   := .T.                   // Qtde Zerada
Local lValid2   := .T.                   // Qtde <> Qtde Conferida
Local lSai      := .F.
Local aWFIDs    := {}          // FS
Local nPosWS    := 0           // FS
Local nLin      := 0           // FS

Private cNumNC  := SF1->F1_COMPFT     // Numero da Nota de Complemento
Private cFornT  := SF1->F1_FORNTRP    // Numero do Fornecedor
Private nValFrt := SF1->F1_VALFRT     // Valor do Frete

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Validacoes                                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpc <= 6 .And. nOpc != 5 .And. !lUserPor
	ApMsgStop("Usuแrio nใo autorizado!")
	RestArea(aArea)
	Return
EndIf

If nOpc == 7 .And. !lUserAlm
	ApMsgStop("Usuแrio nใo autorizado!")
	RestArea(aArea)
	Return
EndIf

If nOpc == 8 .And. ( !lUserCtr .And. !lUserFat )
	ApMsgStop("Usuแrio nใo autorizado!")
	RestArea(aArea)
	Return
EndIf

If nOpc == 4 .And. !(Empty(SF1->F1_COMPFT))
	If !MsgYesNo("NFE jแ possui Conhecimento de Frete associado! Deseja alterar ?", "Documento de Entrada")
		RestArea(aArea)
		Return
	EndIf
EndIf

If nOpc == 5 .And. !(lUserCom)
	ApMsgStop("Usuแrio nใo autorizado a realizar opera็ใo!")
	RestArea(aArea)
	Return
EndIf

If nOpc == 6 .And. 	SF1->F1_AUT_COM == "F"
	If !MsgYesNo("Nota Fiscal jแ possui Conhecimento de Frete! Deseja reimprimir ?", "Documento de Entrada")
		RestArea(aArea)
		Return
	EndIf
EndIf

If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Autorizacao                                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpc == 2 
	lUsrAut  := .T. 	//U_IsGroup("Administradores#PCP-X00")
	If lUsrAut
		dbSelectArea("SF1")
		RecLock("SF1",.F.)
		SF1->F1_DOCENT := AllTrim(cUserName) + "-" + DtoC(dDataBase) + "-" + Time()
		SF1->F1_HORA   := Time()
		SF1->( MsUnLock() )
		ApMsgInfo("Autoriza็ใo efetuada!")
	Else
		MsgInfo("Usuแrio nใo autorizado a utilizar a rotina!")
	EndIf
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Autenticacao                                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf nOpc == 1 .And. MsgBox("Efetua autentica็ใo?", "Documento de Entrada", "YESNO")
	
	SD1->(dbSetOrder(1))
	SD1->(dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
	
	//Liberacao irrestrita
	If !(Empty(SF1->F1_DOCENT)) .Or. SF1->F1_TIPO $ "C#D"
		lValid := .T.
	EndIf
	
	//Validacao de Quantidade
	While !EOF("SD1") .And. SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA ==;
		SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA
		
		dbSelectArea("AIC")
		dbOrderNickName("AIC1")
		dbSeek(xFilial("AIC") + SD1->D1_COD)
		
		nTolerA := (1 + (AIC->AIC_PQTDE / 100))
		nTolerB := (1 - (AIC->AIC_PQTDE / 100))
		
		If (SD1->D1_QTDCOF > (SD1->D1_QUANT * nTolerA)) .Or.;
			(SD1->D1_QTDCOF < (SD1->D1_QUANT * nTolerB)) .And. SD1->D1_TP $ "MP#ME"
			lValid2 := .F.
		EndIf
		      
		If SD1->D1_QTDCOF == 0 .And. SD1->D1_TP $ "MP#ME"
			lValid1 := .F.
		EndIf
		
		nQuant  := 0
		cCodigo := SD1->D1_COD
		
		dbSelectArea("SD1")
		aAreaSD1 := SD1->(GetArea())
		
		dbSelectArea("SD1")
		dbSkip()
		
	EndDo
	
	If !lValid1 .And. !lValid 
		MsgInfo("Hแ itens da NF de entrada sem conferir. Autentica็ใo cancelada!")
		Return
	EndIf
	
	If !lValid2 .And. !lValid
		MsgInfo("Hแ itens da NF de entrada divergentes. Autentica็ใo cancelada!")
		RestArea(aArea)
		Return
	EndIf
	
	OkGeraTxt(nOpc)                                //Gera o arquivo TXT
	__COPYFILE("C:\Protheus12\estm001.txt", "LPT1")  //Executa autenticacao
	
	//Altera status de conferencia
	RecLock("SF1", .F.)
		SF1->F1_STATCON := "1"
		SF1->F1_HORA    := Time()
	SF1->( MsUnLock() )
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Associa Conhecimento de Frete                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf nOpc == 4
	
	oDlg1  := MSDialog():New( 377,343,490,544,"Conhecimento de Frete",,,.F.,,,,,,.T.,,,.T. )
	oGrp1  := TGroup():New( 001,001,044,100,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay1  := TSay():New( 010,006,{||"Conhecimento"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oGet1  := TGet():New( 008,046,{|u| If(PCount()>0,cNumNC:=u,cNumNC)},oGrp1,042,009,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cNumNC",,)
	oSay2  := TSay():New( 020,006,{||"Fornecedor"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oGet2  := TGet():New( 018,046,{|u| If(PCount()>0,cFornT:=u,cFornT)},oGrp1,042,009,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SA2","cFornT",,)
	oSay3  := TSay():New( 030,006,{||"Valor"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oGet4  := TGet():New( 028,046,{|u| If(PCount()>0,nValFrt:=u,nValFrt)},oGrp1,042,009,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nValFrt",,)
	oSBtn1 := SButton():New( 045,048,1,{||oDlg1:End()},oDlg1,,"", )
	oSBtn2 := SButton():New( 045,074,2,{||oDlg1:End(), lSai := .T.},oDlg1,,"", )
	
	oDlg1:Activate(,,,.T.)
	
	If lSai
		RestArea(aArea)
		Return
	EndIf
	
	If Empty(cNumNC) .Or. Empty(cFornT)
		ApMsgStop("Os campos Fornecedor e Conhecimento nใo podem ser vazios")
		RestArea(aArea)
		Return
	EndIf
	
	//Grava associacao
	If MsgYesNo("Confirma grava็ใo do conhecimento de frete ?")
		RecLock("SF1", .F.)
			SF1->F1_COMPFT  := cNumNC
			SF1->F1_FORNTRP := cFornT
			SF1->F1_VALFRT  := nValFrt
			SF1->F1_HORA    := Time()
		SF1->( MsUnLock() )
	EndIf
	
	MsgInfo("Associa็ใo relizada com sucesso!")
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Conhecimento de Frete - Ticket Autentica                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf nOpc == 6
	
	OkGeraTxt(nOpc)                                 //Gera o arquivo TXT
	__COPYFILE( "C:\Protheus12\estm001.txt", "LPT1" ) //Executa impressao do ticket
	
	If MsgBox("Efetua autentica็ใo?","NF-Conhecimento de Frete","YESNO")
		OkGeraTxt(1)                                  //Gera o arquivo TXT
		__COPYFILE("C:\Protheus12\estm001.txt", "LPT1") //Executa autenticacao
	EndIf
	
	RecLock("SF1",.F.)
		SF1->F1_AUT_COM := "F"
		SF1->F1_HORA    := Time()
	SF1->( MsUnLock() )
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ticket                                                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf nOpc == 3       
      
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//|Atualiza historico do ticket de pesagem referente a NF Entrada    	ณ
	//|** Abertura do Ticket de Conferencia do Material                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(SF1->F1_TICPESA)
		U_ESTX003H(SF1->F1_TICPESA, 4)
	EndIf

	//+----------------------------------------------------------------------------
	//| Gera arquivo TXT para emissao do ticket de conferencia do material
	//+----------------------------------------------------------------------------
	OkGeraTxt(nOpc)
   
	//+----------------------------------------------------------------------------
	//| Envia arquivo para porta de impressao ( LPT1 )
	//+----------------------------------------------------------------------------
	__COPYFILE( "C:\Protheus12\estm001.txt", "LPT1" )	//Impressao do Ticket
	
	//+----------------------------------------------------------------------------
	//| Workflow - Entrada de Material
	//+----------------------------------------------------------------------------
	////WinExec(cPath + Space(1) + U_getUserGp("PCP-X01", "C", 3, ",") + ',' + U_getUserGp("COM-X00", "C", 3, ",") + Space(1) + '"' + cMsg + '"',0)
	//WinExec(cPath + Space(1) + 'GUSTAVO.DIAS' + ',' + 'SUZI.ALCANTRA,FABIO.RAMIRES' + Space(1) + '"' + cMsg + '"',0)

	cQuery := "SELECT D1_PEDIDO " + CRLF
	cQuery += "FROM " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SF1") + " AS SF1 WITH (NOLOCK) ON F1_FILIAL = D1_FILIAL " + CRLF
	cQuery += "  AND F1_DOC = D1_DOC " + CRLF
	cQuery += "  AND F1_SERIE = D1_SERIE " + CRLF
	cQuery += "  AND F1_FORNECE = D1_FORNECE " + CRLF
	cQuery += "  AND F1_LOJA = D1_LOJA " + CRLF
	cQuery += "  AND F1_TIPO = D1_TIPO " + CRLF
	cQuery += "  AND F1_TICPESA = '" + SF1->F1_TICPESA + "' " + CRLF
	cQuery += "  AND SF1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE D1_FILIAL = '" + xFilial("SD1") + "' " + CRLF
	cQuery += "AND D1_DOC = '" + SF1->F1_DOC + "' " + CRLF
	cQuery += "AND D1_SERIE = '" + SF1->F1_SERIE + "' " + CRLF
	cQuery += "AND D1_FORNECE = '" + SF1->F1_FORNECE + "' " + CRLF
	cQuery += "AND D1_LOJA = '" + SF1->F1_LOJA + "' " + CRLF
	cQuery += "AND D1_TIPO = '" + SF1->F1_TIPO + "' " + CRLF
	cQuery += "AND SD1.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPPES"
	dbSelectArea("TMPPES")
	dbGoTop()
	
	Do While !TMPPES->( Eof() )
		dbSelectArea("SC7")
		dbSetOrder(1)
		If SC7->( dbSeek( xFilial("SC7") + TMPPES->D1_PEDIDO ) )
			If aScan( aWFIDs, {|nLin| AllTrim( nLin[1] ) == AllTrim( SC7->C7_EUWFID ) }) == 0
				aAdd( aWFIDs, { AllTrim( SC7->C7_EUWFID ), SC7->C7_NUM })
			EndIf
		EndIf
	
		TMPPES->( dbSkip() )
	EndDo
	
	TMPPES->( dbCloseArea() )

	// Atualiza os processos da NF...
	For nPosWF := 1 To Len( aWFIDs )
		dbSelectArea("SC7")
		dbSetOrder(1)
		If SC7->( dbSeek( xFilial("SC7") + aWFIDs[nPosWF][2] ) )
			U_EQGeraWFC( "Protheus - Ticket da Confer๊ncia: " + AllTrim( SF1->F1_DOC ) + "|" + AllTrim( SF1->F1_SERIE ) + " Emitida. Pedido: " + AllTrim( SC7->C7_NUM ),;
			 			 "400050",;
						 "TICKET ETIQUETA CONFERENCIA",;
				         "1",;
						 "Emissใo Etiqueta Ticket de Confer๊ncia" )

			U_EQGeraWFC( "Protheus - Ticket: " + AllTrim( SF1->F1_DOC ) + "|" + AllTrim( SF1->F1_SERIE ) + " Aguardando Confer๊ncia. Pedido: " + AllTrim( SC7->C7_NUM ),;
			 			 "400051",;
						 "AGUARDANDO CONFERENCIA",;
				         "1",;
						 "Aguardando Confer๊ncia de Mercadoria" )
		EndIf
	Next
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Conferencia Almoxarifado                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf nOpc == 7
	
	_oDlg     := Nil
	_oOk      := LoadBitmap(GetResources(), "ENABLE")
	_oNo      := LoadBitmap(GetResources(), "DISABLE")
	_oCq      := LoadBitmap(GetResources(), "BR_AMARELO")
	_aHeader  := {}
	_aItens   := {}
	_aColumns := {}
	_lChk     := .F.
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//| Estrutura do MarkBrowse                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aAdd(_aHeader , { "", "Documento", "Emissใo", "Produto", "Qtd Liberada", "Qtd Rejeitada", "Qtd Conferida", "Fornecedor", "Lote Fornecedor", "Lote Interno", "Dt Validade", "Dt. Transfer", "Usr Confer"})
	aAdd(_aColumns, { 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10})
	
	cQry := " SELECT D1_PEDIDO, D1_SERIE SERIE, D1_DOC DOCUMENTO, " + ENTER
	cQry += " 		D1_EMISSAO EMISSAO, " + ENTER
	cQry += " 		D1_DTDIGIT DTDIGIT, " + ENTER
	//cQry += " 		D1_COD CODPROD, D1_DESCRI DESCPROD, " + ENTER
	cQry += " 		D1_COD CODPROD, SB1.B1_DESC DESCPROD, " + ENTER	
	cQry += " 		(SELECT	SUM(CASE WHEN D7_TIPO = '1' THEN D7_QTDE ELSE 0 END - CASE WHEN D7_TIPO = '6' THEN D7_QTDE ELSE 0 END) QTDLIB " + ENTER
	cQry += " 		FROM	" + RetSqlName("SD7") + " " + ENTER
	cQry += " 		WHERE	D_E_L_E_T_ <> '*' " + ENTER
	cQry += " 				AND D7_DOC = D1_DOC " + ENTER
	cQry += " 				AND D7_SERIE = D1_SERIE " + ENTER
	cQry += " 				AND D7_FORNECE = D1_FORNECE " + ENTER
	cQry += " 				AND D7_LOJA = D1_LOJA " + ENTER
	cQry += " 				AND D7_NUMERO = D1_NUMCQ " + ENTER
	cQry += " 				AND D7_PRODUTO = D1_COD " + ENTER
	cQry += " 				AND D7_TIPO IN ('1', '6') " + ENTER
	cQry += " 		GROUP BY D7_DOC, D7_SERIE, D7_FORNECE, D7_LOJA) QTDLIB, " + ENTER
	cQry += " 		(SELECT	SUM(CASE WHEN D7_TIPO = '2' THEN D7_QTDE ELSE 0 END - CASE WHEN D7_TIPO = '7' THEN D7_QTDE ELSE 0 END) QTDREJ " + ENTER
	cQry += " 		FROM	" + RetSqlName("SD7") + " " + ENTER
	cQry += " 		WHERE	D_E_L_E_T_ <> '*' " + ENTER
	cQry += " 				AND D7_DOC = D1_DOC " + ENTER
	cQry += " 				AND D7_SERIE = D1_SERIE " + ENTER
	cQry += " 				AND D7_FORNECE = D1_FORNECE " + ENTER
	cQry += " 				AND D7_LOJA = D1_LOJA " + ENTER
	cQry += " 				AND D7_NUMERO = D1_NUMCQ " + ENTER
	cQry += " 				AND D7_PRODUTO = D1_COD " + ENTER
	cQry += " 				AND D7_TIPO IN ('2', '7') " + ENTER
	cQry += " 		GROUP BY D7_DOC, D7_SERIE, D7_FORNECE, D7_LOJA) QTDREJ, " + ENTER
	cQry += " 		D1_QTDCOF QTDCOF, " + ENTER
	cQry += " 		A2_COD + '-' + A2_NOME FORNECEDOR, " + ENTER
	cQry += " 		D1_LOTEFOR LOTEFOR, " + ENTER
	cQry += " 		D1_LOTECTL LOTEINT, " + ENTER
	cQry += " 		D1_DTVALID DTVALID, " + ENTER
	cQry += " 		D1_ITEM ITEM, " + ENTER
	cQry += " 		D1_FORNECE + D1_LOJA CODFOR, " + ENTER
	cQry += " 		(SELECT B1_RASTRO FROM " + RetSqlName("SB1") + " WHERE D_E_L_E_T_ <> '*' AND B1_COD = D1_COD) RASTRO, " + ENTER
	cQry += " 		D1_DTTRANS DTTRANS, " + ENTER
	cQry += " 		D1_USRCONF USRCONF " + ENTER
	cQry += " FROM	" + RetSqlName("SD1") + " SD1, " + RetSqlName("SA2") + " SA2,  " + RetSqlName("SB1") + " SB1  " + ENTER
	cQry += " WHERE	SD1.D_E_L_E_T_ <> '*' " + ENTER
	cQry += " 		AND SA2.D_E_L_E_T_ <> '*' " + ENTER
	cQry += " 		AND SB1.D_E_L_E_T_ <> '*' " + ENTER
	cQry += " 		AND SB1.B1_COD = SD1.D1_COD " + ENTER
	cQry += " 		AND D1_DOC = '" + SF1->F1_DOC + "' " + ENTER
	cQry += " 		AND D1_SERIE = '" + SF1->F1_SERIE + "' " + ENTER
	cQry += " 		AND D1_FORNECE = '" + SF1->F1_FORNECE + "' " + ENTER
	cQry += " 		AND D1_LOJA = '" + SF1->F1_LOJA + "' " + ENTER
	cQry += " 		AND A2_COD = D1_FORNECE " + ENTER
	cQry += " 		AND A2_LOJA = D1_LOJA " + ENTER
	cQry += " ORDER BY D1_COD " + ENTER
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,, cQry), "QRY", .F., .T.)
	TCSetField("QRY", "EMISSAO", "D")
	TCSetField("QRY", "DTVALID", "D")
	TCSetField("QRY", "DTTRANS", "D")
	TCSetField("QRY", "DTDIGIT", "D")
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//| Grava dados no Array                                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("QRY")
	dbGoTop()
	
	While !EOF("QRY")
		
		aAdd(_aItens, {QRY->DTTRANS,;
		QRY->DOCUMENTO,;
		QRY->EMISSAO,;
		QRY->CODPROD,;
		QRY->QTDLIB,;
		QRY->QTDREJ,;
		QRY->QTDCOF,;
		QRY->FORNECEDOR,;
		QRY->LOTEFOR,;
		QRY->LOTEINT,;
		QRY->DTVALID,;
		QRY->ITEM,;
		QRY->SERIE,;
		QRY->CODFOR,;
		QRY->RASTRO,;
		QRY->USRCONF,;
		QRY->DESCPROD,;
		QRY->DTDIGIT,;
		QRY->D1_PEDIDO})
		
		dbSelectArea("QRY")
		dbSkip()
	EndDo
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//| Fecha Query                                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf
	
	If Empty(_aItens)
		MsgAlert("Nใo foram encontrados dados para a consulta!", "Aten็ใo")
		RestArea(aArea)
		Return
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//| Apresenta o MarkBrowse para o usuario                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	_oDlg           := MSDialog():New(000, 000, 273, 800, "Confer๊ncia de NFE",,,,,,,, oMainWnd, .T.)
	_oDlg:lCentered := .T.
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Desenha os GroupBoxes                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	_oGrpo1 := TGroup():New(003, 003, 115, 398,, _oDlg,,, .T.)
	_oGrpo2 := TGroup():New(116, 003, 135, 398,, _oDlg,,, .T.)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Desenha os Botoes.                                                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	_oBtn1 := TButton():New(118, 075, 'Conferir'           , _oDlg,{|| ConferOpc(1), _oDlg:End(),} , 50, 15,,,,.T.)
	_oBtn2 := TButton():New(118, 125, 'Transferir'         , _oDlg,{|| ConferOpc(2)}                , 50, 15,,,,.T.)
	_oBtn4 := TButton():New(118, 175, 'R๓tulo Prd/Lib'     , _oDlg,{|| U_ESTM001A()}                , 50, 15,,,,.T.)
	_oBtn6 := TButton():New(118, 225, 'R๓tulo Reprova'     , _oDlg,{|| U_ESTM001B()}                , 50, 15,,,,.T.)
	_oBtn3 := TButton():New(118, 275, 'Legenda'            , _oDlg,{|| ConferOpc(3)}                , 50, 15,,,,.T.)
	_oBtn5 := TButton():New(118, 325, 'Sair'               , _oDlg,{|| _oDlg:End()}                 , 50, 15,,,,.T.)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Desenha o MarkBrowse.                                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oBrw3 := TWBrowse():New(008, 008, 389, 103,, _aHeader[1], _aColumns[1], _oDlg,,,,,,,,,,,,,, .T.)
	oBrw3:SetArray(_aItens)
	oBrw3:bLine := {|| {;
	Iif(_aItens[oBrw3:nAt][05] == 0 .And. _aItens[oBrw3:nAt][06] == 0 .And. _aItens[oBrw3:nAt][15] != "N", _oCq, If(Empty(_aItens[oBrw3:nAt][01]), _oOk, _oNo)),;
	_aItens[oBrw3:nAt][13] + "-" + _aItens[oBrw3:nAt][02],;
	AllTrim(_aItens[oBrw3:nAt][03]) + "-" + AllTrim(_aItens[oBrw3:nAt][17]),;
	_aItens[oBrw3:nAt][04],;
	Transform(_aItens[oBrw3:nAt][05], "@E 9,999,999.99"),;
	Transform(_aItens[oBrw3:nAt][06], "@E 9,999,999.99"),;
	Transform(_aItens[oBrw3:nAt][07], "@E 9,999,999.99"),;
	_aItens[oBrw3:nAt][08],;
	_aItens[oBrw3:nAt][09],;
	_aItens[oBrw3:nAt][10],;
	_aItens[oBrw3:nAt][11],;
	_aItens[oBrw3:nAt][01],;
	_aItens[oBrw3:nAt][16]}}
	
	oBrw3:lAdJustColSize := .F.
	oBrw3:lColDrag       := .F.
	oBrw3:lMChange       := .F.
	oBrw3:bLDblClick     := {|| fCriaSX1("PCPX001"), Pergunte("PCPX001", .F.), mv_par01 := 0, mv_par02 := _aItens[oBrw3:nAt][09], mv_par03 := _aItens[oBrw3:nAt][11],Pergunte("PCPX001", .T.), _aItens[oBrw3:nAt][07] := mv_par01, _aItens[oBrw3:nAt][09] := mv_par02, _aItens[oBrw3:nAt][11] := mv_par03, oBrw3:Refresh()}
	
	_oDlg:Activate(,,,.T.)
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Conferencia Faturamento                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf nOpc == 8
	
	If MsgYesNo("Confirma confer๊ncia do Documento de Entrada?")
		RecLock("SF1", .F.)
			SF1->F1_CONFFAT:= dDataBase
		SF1->( MsUnLock() )
	EndIf   

ElseIf nOpc == 9
	      
    aPBoxPerg := {}     
    aPBoxRet  := {}
	aAdd(aPBoxPerg,{1, "Chave NFE", SF1->F1_CHVNFE, "@!", "", "",, 120, .F.}) 
	If ParamBox(aPBoxPerg, "Confirma Chave NFE ?", @aPBoxRet,,,,,,,,.F.,.F.)  
		RecLock("SF1", .F.)
			SF1->F1_CHVNFE := aPBoxRet[1]
		SF1->( MsUnLock() )
	EndIf	

EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOKGERATXT บ Autor ณTiago O. Beraldi    บ Data ณ  12/11/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณGERA ARQUIVO DE TEXTO                                       บฑฑ
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
Static Function OkGeraTxt(nOpc)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria o arquivo texto                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cArqTxt := "C:\Protheus12\estm001.txt"
Private nHdl    := fCreate(cArqTxt)

If nHdl == -1
	ApMsgAlert("O arquivo de nome " + cArqTxt + " nao pode ser executado! Verifique os parametros.", "Atencao!")
	Return
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicializa a regua de processamento                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Processa({|| RunCont(nOpc) },"Processando...")

If fWrite(nHdl, cLin, Len(cLin)) != Len(cLin)
	MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?", "Atencao!")
Endif

fClose(nHdl)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOKGERATXT บ Autor ณTiago O. Beraldi    บ Data ณ  12/11/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณPROCESSA ARQUIVO TEXTO                                      บฑฑ
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
Static Function RunCont(nOpc)

Local  cQry   := ""
Local  cSolic := ""
Local  nTotal := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Autenticacao                                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

// ============================================================
//  Grupo Empresa - Ajuste realizado em 31.08.20 (CG)
// ============================================================

// cEmpAnt (Substituido por cFilAnt)

If nOpc == 1
	cLin := chr(27) + chr(64)
	cLin += chr(27) + chr(126) + "1"
	cLin += "NF: " + cNumDoc + " DATA: " + DtoC(dDataBase)  + "-" + Time() + " EMP: " + AllTrim(cFilAnt) + chr(13) + chr(10)
	cLin += chr(27) + chr(126) + "0"
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Conhecimento de Frete - Ticket Autentica                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf nOpc == 6
	
	dbSelectArea("SF1")
	cLin := chr(27) + chr(64)
	cLin += chr(27) + chr(15)
	
	cLin += "------------------------------------------------------------" + chr(13) + chr(10)
	cLin += PadC(SM0->M0_NOMECOM, 60) + chr(13) + chr(10)
	cLin += "------------------------------------------------------------" + chr(13) + chr(10)
	cLin += "      TICKET DE ENTRADA DE NF - CONHECTO. DE FRETE          " + chr(13) + chr(10)
	cLin += "------------------------------------------------------------" + chr(13) + chr(10)
	cLin += "NF/NC: " + SF1->F1_SERIE + "-" + SF1->F1_DOC + "/" + SF1->F1_COMPFT +;
	"         DATA: " + DtoC(dDataBase)  + "-" + Time() + chr(13) + chr(10)
	If SF1->F1_TIPO == "B"
		cLin += PadL("FORN: " + Subs(Posicione("SA1", 1, xFilial("SA1") + SF1->F1_FORNECE + SF1->F1_LOJA, "A1_NOME"), 1, 40), 60) + chr(13) + chr(10)
	Else
		cLin += PadL("FORN: " + Subs(Posicione("SA2", 1, xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA, "A2_NOME"), 1, 40), 60) + chr(13) + chr(10)
	EndIf
	
	cLin += "------------------------------------------------------------" + chr(13) + chr(10)
	cLin += "PRODUTO                              QTDE.        V.UNIT.   " + chr(13) + chr(10)
	cLin += "------------------------------------------------------------" + chr(13) + chr(10)
	
	//Seleciona Itens
	cQry := " SELECT SUBSTRING((SELECT SB1.B1_DESC FROM " + RetSqlName("SB1")  + " SB1 WHERE SB1.D_E_L_E_T_ = '' AND SB1.B1_COD = D1_COD ),1,30) DESCRI, " + chr(13) + chr(10)
	cQry += "       D1_QUANT QUANT, " + chr(13) + chr(10)
	cQry += "       D1_VUNIT VALOR, " + chr(13) + chr(10)
	cQry += "       (SELECT C1_SOLICIT FROM " + RetSqlName("SC1") + " WHERE D_E_L_E_T_ <> '*' AND C1_FILIAL = '" + xFilial("SC1") + "' AND C1_NUM + C1_ITEM IN " +;
	"       (SELECT C7_NUMSC + C7_ITEMSC FROM " + RetSqlName("SC7") + " WHERE D_E_L_E_T_ <> '*' AND C7_FILIAL = '" + xFilial("SC7") + "' AND C7_NUM = D1_PEDIDO AND C7_ITEM = D1_ITEMPC AND C7_PRODUTO = D1_COD) GROUP BY C1_SOLICIT) SOLIC "  + chr(13) + chr(10)
	cQry += " FROM " + RetSqlName("SD1") + chr(13) + chr(10)
	cQry += " WHERE D_E_L_E_T_ <> '*' " + chr(13) + chr(10)  
	cQry += "       AND D1_FILIAL = '" + xFilial("SD1") + "' " + chr(13) + chr(10)
	cQry += "       AND D1_DOC = '"  + SF1->F1_DOC + "' " + chr(13) + chr(10)
	cQry += "       AND D1_SERIE = '"  + SF1->F1_SERIE + "' " + chr(13) + chr(10)
	cQry += "       AND D1_FORNECE = '"  + SF1->F1_FORNECE + "' " + chr(13) + chr(10)
	cQry += "       AND D1_LOJA = '"  + SF1->F1_LOJA + "' " + chr(13) + chr(10)
	cQry += " ORDER BY D1_ITEM " + chr(13) + chr(10)
	
	MemoWrite("estm001.sql", cQry)
	
	TCQUERY cQry NEW ALIAS QRY
	
	While !EOF("QRY")
		//Solicitante
		If !(QRY->SOLIC $ cSolic) .And. Empty(cSolic)
			cSolic := AllTrim(QRY->SOLIC)
		ElseIf !(AllTrim(QRY->SOLIC) $ cSolic)
			cSolic += "/" + AllTrim(QRY->SOLIC)
		EndIf
		
		cLin += PadL(QRY->DESCRI + Transform(QUANT, "@E 999,999.99") + Space(3)+ Transform(SD1->D1_VUNIT,"@E 99,999.99"),60) + chr(13) + chr(10)
		
		dbSelectArea("QRY")
		dbSkip()
	EndDo
	
	QRY->(dbCloseArea())
	
	cTotal := Transform(SF1->F1_VALFRT, "@E 999,999.99")
	cLin += "------------------------------------------------------------" + chr(13) + chr(10)
	cLin += PadL("TOTAL DA NF: R$ " + cTotal, 60) + chr(13) + chr(10)
	cLin += "------------------------------------------------------------" + chr(13) + chr(10)
	cLin += PadL("SOLICITANTE: " + cSolic, 60) + chr(13) + chr(10)
	cLin += "------------------------------------------------------------" + chr(13) + chr(10)
	cLin += Space(60) + chr(13) + chr(10)
	cLin += "COMPRAS:                                                    " + chr(13) + chr(10)
	cLin += "------------------------------------------------------------" + chr(13) + chr(10)
	cLin += Space(60) + chr(13) + chr(10)
	cLin += "DIRETORIA:                                                  " + chr(13) + chr(10)
	cLin += "------------------------------------------------------------" + chr(13) + chr(10)
	cLin += chr(13) + chr(10) + chr(13) + chr(10) + chr(13) + chr(10) + chr(13) + chr(10)
	cLin += chr(13) + chr(10) + chr(13) + chr(10) + chr(13) + chr(10) + chr(13) + chr(10)
	cLin += chr(13) + chr(10) + chr(13) + chr(10) + chr(13)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Ticket                                                              ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf nOpc == 3
	
	dbSelectArea("SF1")
	cLin := chr(27) + chr(64)
	cLin += chr(27) + chr(15)
	
	cFornec := "( " + SF1->F1_FORNECE + "-" + SF1->F1_LOJA + " ) " +;
	           IIf(SF1->F1_TIPO $ "B#D",;
	           Subs(Posicione("SA1", 1, xFilial("SA1") + SF1->F1_FORNECE + SF1->F1_LOJA, "A1_NOME"), 1, 40),;
	           Subs(Posicione("SA2", 1, xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA, "A2_NOME"), 1, 40))
										
	cLin += "------------------------------------------------------------" + chr(13) + chr(10)
	cLin += PadC(SM0->M0_NOMECOM, 60) + chr(13) + chr(10)
	cLin += "------------------------------------------------------------" + chr(13) + chr(10)
	cLin += "                 TICKET DE ENTRADA DE NF                    " + chr(13) + chr(10)
	cLin += "------------------------------------------------------------" + chr(13) + chr(10)
	cLin += "NF: " + SF1->F1_SERIE + "-" + SF1->F1_DOC + "                       DATA: " + DtoC(dDataBase)  + "-" + Time() + chr(13) + chr(10)
	cLin += "FORN: " + cFornec + "              " + chr(13) + chr(10)
	cLin += "------------------------------------------------------------" + chr(13) + chr(10)
	cLin += "CODIGO - PRODUTO                                            " + chr(13) + chr(10)
	cLin += "------------------------------------------------------------" + chr(13) + chr(10)
	
	cEmisNF := DtoC(SF1->F1_EMISSAO)
	cSolic  := ""
	cPagto  := ""
	cPagtd  := ""
	cMsg    := "(Workflow)Entrou NF !" + chr(13) + chr(10)
	
	//Seleciona Itens
	//cQry := " SELECT D1_DESCRI DESCRI, " + chr(13) + chr(10)
	cQry := " SELECT SB1.B1_DESC DESCRI, " + chr(13) + chr(10)	
	cQry += "       D1_COD CODIGO, " + chr(13) + chr(10)
	cQry += "       D1_UM UNIDADE, " + chr(13) + chr(10)
	cQry += "       D1_LOTECTL LOTE, " + chr(13) + chr(10)
	cQry += "       D1_LOTEFOR LOTEFOR, " + chr(13) + chr(10)
	cQry += "       D1_DTVALID DTVALID, " + chr(13) + chr(10)
	cQry += "       D1_QUANT QUANT, " + chr(13) + chr(10)
	cQry += "       D1_VUNIT VALOR, " + chr(13) + chr(10)
	cQry += "    	(SELECT C7_COND FROM " + RetSqlName("SC7") + " WHERE D_E_L_E_T_ = '' AND C7_FILIAL = '" + xFilial("SC7") + "' AND C7_NUM = '" + SD1->D1_PEDIDO + "' GROUP BY C7_COND) COND, " + chr(13) + chr(10)
	cQry += "       (SELECT MAX(C1_SOLICIT) FROM " + RetSqlName("SC1") + " WHERE D_E_L_E_T_ = '' AND C1_FILIAL = '" + xFilial("SC1") + "' AND C1_NUM + C1_ITEM IN (SELECT C7_NUMSC + C7_ITEMSC FROM " + RetSqlName("SC7") + " WHERE D_E_L_E_T_ = '' AND C7_FILIAL = '" + xFilial("SC7") + "' AND C7_NUM = D1_PEDIDO AND C7_ITEM = D1_ITEMPC AND C7_PRODUTO = D1_COD)) SOLIC, "  + chr(13) + chr(10)
	cQry += "       D1_NFORI, " + chr(13) + chr(10)
	cQry += "       D1_SERIORI, " + chr(13) + chr(10)
	cQry += "       D1_ITEMORI, " + chr(13) + chr(10)
	cQry += "       D1_U_IDRNC, " + chr(13) + chr(10)
	cQry += "       D1_U_ITRNC, " + chr(13) + chr(10)
	cQry += "       CASE WHEN UI_MOTDEVO = '1' THEN 'AVARIA' " + chr(13) + chr(10)
	cQry += "       	 WHEN UI_MOTDEVO = '2' THEN 'PROBLEMA TECNICO' " + chr(13) + chr(10)
	cQry += "       	 WHEN UI_MOTDEVO = '3' THEN 'DESACORDO COMERCIAL' " + chr(13) + chr(10)
	cQry += "       	 WHEN UI_MOTDEVO = '4' THEN 'CONSIGNACAO' " + chr(13) + chr(10)
	cQry += "       END MOTDEVO, " + chr(13) + chr(10)
	cQry += "       UI_AUTORIZ AUTDEVO " + chr(13) + chr(10)
	//
	cQry += " FROM " + RetSqlName("SD1") + " SD1 " + chr(13) + chr(10)
	//
	cQry += " LEFT JOIN " + RetSqlName("SUI") + " SUI " + chr(13) + chr(10)
	cQry += " ON		SUI.D_E_L_E_T_ = '' "  + chr(13) + chr(10)
	cQry += " AND		UI_FILIAL = '" + xFILIAL("SUI") + "' " + chr(13) + chr(10)
	cQry += " AND		UI_CODIGO = D1_U_IDRNC " + chr(13) + chr(10)
	cQry += " INNER JOIN " + RetSqlName("SB1") + " SB1 " + chr(13) + chr(10)
	cQry += " ON		SB1.D_E_L_E_T_ = '' AND SB1.B1_COD = SD1.D1_COD "  + chr(13) + chr(10)
	//
	cQry += " WHERE SD1.D_E_L_E_T_ = '' " + chr(13) + chr(10)   
	cQry += "       AND D1_FILIAL = '"  + xFilial("SD1") + "' " + chr(13) + chr(10)
	cQry += "       AND D1_DOC = '"  + SF1->F1_DOC + "' " + chr(13) + chr(10)
	cQry += "       AND D1_SERIE = '"  + SF1->F1_SERIE + "' " + chr(13) + chr(10)
	cQry += "       AND D1_FORNECE = '"  + SF1->F1_FORNECE + "' " + chr(13) + chr(10)
	cQry += "       AND D1_LOJA = '"  + SF1->F1_LOJA + "' " + chr(13) + chr(10)
	//
	cQry += " ORDER BY D1_ITEM " + chr(13) + chr(10)
	
	MemoWrite("estm001.sql", cQry)
	
	TCQUERY cQry NEW ALIAS QRY
	
	TCSetField("QRY", "DTVALID", "D")
	
	QRY->(dbGoTop())
	
	While !EOF("SD1")
		//Solicitante
		If !(QRY->SOLIC $ cSolic) .And. Empty(cSolic)
			cSolic := AllTrim(QRY->SOLIC)
		ElseIf !(AllTrim(QRY->SOLIC) $ cSolic)
			cSolic += "/" + AllTrim(QRY->SOLIC)
		EndIf
		
		//Condicao de pagamento
		If !(QRY->COND $ cPagto) .And. Empty(cPagto)
			cPagto := AllTrim(QRY->COND)
			cPagtd := AllTrim(Posicione("SE4", 1, xFilial("SE4") + QRY->COND, "E4_DESCRI"))
		ElseIf !(Alltrim(QRY->SOLIC) $ cSolic)
			cPagto += "/" + AllTrim(QRY->COND)
			cPagtd += "/" + AllTrim(Posicione("SE4", 1, xFilial("SE4") + QRY->COND, "E4_DESCRI"))
		EndIf
		
		cLin += Subs(QRY->CODIGO, 1, 8) + "-" + Subs(QRY->DESCRI,1,46) + " - " + QRY->UNIDADE + chr(13) + chr(10)
		cLin += PadR("LOTE: " + AllTrim(QRY->LOTE), 60) + chr(13) + chr(10)
		cLin += PadR("QTDE: ", 60) + chr(13) + chr(10)
		cLin += PadR("LOTE FORNEC. " + QRY->LOTEFOR + " LOTE FISICO: ___________________", 60) + chr(13) + chr(10)
		IF DtoC(QRY->DTVALID) == '31/12/49' .Or. DtoC(QRY->DTVALID) == '  /  /  '
			cLin += "PZ.VAL. " + "INDETERMINADO"    + Space(12) + "PZ.VAL. FISICO: ________________" + chr(13) + chr(10)
		Else 
			cLin += "PZ.VAL. " + DtoC(QRY->DTVALID) + Space(12) + "PZ.VAL. FISICO: ________________" + chr(13) + chr(10)
		EndIf

		If SF1->F1_TIPO == "D"
		
			cLin += chr(13) + chr(10)
			cLin += Replicate(".", 80) + chr(13) + chr(10)		
			cLin += "RNC/ATENDIMENTO: " + QRY->D1_U_IDRNC + chr(13) + chr(10)
			cLin += "MOTIVO.........: " + QRY->MOTDEVO + chr(13) + chr(10)
			cLin += "AUTORIZACAO....: " + QRY->AUTDEVO + chr(13) + chr(10)
			cLin += "NF ORIGINAL....: " + QRY->D1_SERIORI + QRY->D1_NFORI + chr(13) + chr(10)
			cLin += Replicate(".", 80) + chr(13) + chr(10)		
			cLin += chr(13) + chr(10)		
		
		EndIf
		
		cMsg += AllTrim(Subs(QRY->CODIGO,1,8)) + "-" + AllTrim(Subs(QRY->DESCRI, 1, 46)) + "-" + Transform(QRY->QUANT,"@E 999,999,999.99") + " Lote : " + QRY->LOTE + chr(13) + chr(10)
		
		dbSelectArea("QRY")
		dbSkip()
	EndDo
	
	QRY->(dbCloseArea())
	
	cDatPag := "EMIS.N.FISCAL: " + cEmisNF + "   COND. PAG. - " + cPagtd
	
	cLin += "------------------------------------------------------------" + chr(13) + chr(10)
	cLin += PadR(cDatPag, 60) + chr(13) + chr(10)
	cLin += "------------------------------------------------------------" + chr(13) + chr(10)
	cLin += PadR("SOLICITANTE: " + cSolic, 60) + chr(13) + chr(10)
	cLin += "------------------------------------------------------------" + chr(13) + chr(10)
	cLin += "CONFERENTE:                                                 " + chr(13) + chr(10)
	cLin += "DATA:_____/_____/_____                                      " + chr(13) + chr(10)
	cLin += "------------------------------------------------------------" + chr(13) + chr(10)
	cLin += "REC. FISCAL:                                                " + chr(13) + chr(10)
	cLin += "DATA:_____/_____/_____                                      " + chr(13) + chr(10)
	cLin += "------------------------------------------------------------" + chr(13) + chr(10)
	cLin += "OBS.:_______________________________________________________" + chr(13) + chr(10)
	cLin += "____________________________________________________________" + chr(13) + chr(10)
	cLin += Replicate("x", 60) + CHR(13) + CHR(10)
	cLin += chr(13) + chr(10) + chr(13) + chr(10) + chr(13) + chr(10) + chr(13) + chr(10)
	cLin += chr(13) + chr(10) + chr(13) + chr(10) + chr(13) + chr(10) + chr(13) + chr(10)
	cLin += chr(13) + chr(10) + chr(13) + chr(10) + chr(13)
	
EndIf                

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFCRIASX1  บ Autor ณTiago O. Beraldi    บ Data ณ  17/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณGERA DICIONARIO DE PERGUNTAS                                บฑฑ
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

Local cKey := ""
Local aHelpEng := {}
Local aHelpPor := {}
Local aHelpSpa := {}

PutSX1(cPerg,"01","Quantidade Conferida ?", "", "", "mv_ch1", "N", 14, 2, 0, "N", "", "", "", "", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
PutSX1(cPerg,"02","Lote Fornecedor      ?", "", "", "mv_ch2", "C", 14, 0, 0, "G", "", "", "", "", "mv_par02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
PutSX1(cPerg,"03","Data Validade        ?", "", "", "mv_ch3", "D", 08, 0, 0, "G", "", "", "", "", "mv_par03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")

cKey     := "P." + cPerg + "01."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe a Quantidade Conferida.")
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
aAdd(aHelpPor,"Informe o Lote do Fornecedor.")
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
aAdd(aHelpPor,"Informe a Validade do Lote Fornecedor.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ ESTM001A ณ Autor ณ Tiago Oliveira Beraldiณ Data ณ11/10/05  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Emisso da Etiqueta Liberado                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Euroamerican                                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function ESTM001A()

LOCAL oDlg := NIL

PRIVATE cTitulo := "Impressใo - R๓tulos de Etiqueta Liberado"
PRIVATE oPrn    := NIL
PRIVATE oFont1  := NIL
PRIVATE oFont2  := NIL
PRIVATE oFont3  := NIL
PRIVATE cPerg   := "ESTM1A"

DEFINE FONT oFont1 NAME "Tahoma" SIZE 0,30 OF oPrn BOLD
DEFINE FONT oFont2 NAME "Tahoma" SIZE 0,26 OF oPrn BOLD
DEFINE FONT oFont3 NAME "Tahoma" SIZE 0,18 OF oPrn BOLD

CriaSX1(cPerg)
Pergunte(cPerg,.F.)

DEFINE MSDIALOG oDlg FROM 264,182 TO 441,613 TITLE cTitulo OF oDlg PIXEL
@ 004,010 TO 082,157 LABEL "" OF oDlg PIXEL

@ 015,017 SAY "Esta rotina tem por objetivo imprimir" OF oDlg PIXEL Size 150,010 FONT oFont3 COLOR CLR_HBLUE
@ 030,017 SAY "os r๓tulos de produtos.      " OF oDlg PIXEL Size 150,010 FONT oFont3 COLOR CLR_HBLUE

@  6,167 BUTTON "&Imprime"    SIZE 036,012 ACTION Imprimir() OF oDlg PIXEL
@ 27,167 BUTTON "&Parametros" SIZE 036,012 ACTION Pergunte(cPerg,.T.) OF oDlg PIXEL
@ 48,167 BUTTON "Sai&r"       SIZE 036,012 ACTION oDlg:End() OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ ESTM001A ณ Autor ณ Tiago Oliveira Beraldiณ Data ณ11/10/05  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Emisso da Etiqueta para Producao                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Euroamerican                                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function Imprimir()

oPrn := TMSPrinter():New()
LayOutSup()
oPrn:Preview()
oPrn:End()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ ESTM001A ณ Autor ณ Tiago Oliveira Beraldiณ Data ณ11/10/05  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Emisso da Etiqueta para Producao                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Euroamerican                                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function LayOutSup()

oPrn:SetPortrait()
For x:= 1 to Len(_aItens)
	// Impressao
	oPrn:StartPage()
	                       
	oPrn:Say(0685, 1760, AllTrim(_aItens[x,8])                               , oFont1,,,, PAD_RIGHT) //Empresa
	oPrn:Say(0845, 1760, AllTrim(Transform(_aItens[x,18], "@E 99/99/9999"))  , oFont1,,,, PAD_RIGHT) //Recebimento
	oPrn:Say(1005, 1760, AllTrim(_aItens[x,4])                               , oFont1,,,, PAD_RIGHT) //Produto
	oPrn:Say(1165, 1760, AllTrim(_aItens[x,9])                               , oFont2,,,, PAD_RIGHT) //Lote Externo
	oPrn:Say(1325, 1760, AllTrim(_aItens[x,10])                              , oFont1,,,, PAD_RIGHT) //Lote Interno
	oPrn:Say(1485, 1760, AllTrim(Transform(_aItens[x,11], "@E 99/99/9999"))  , oFont1,,,, PAD_RIGHT) //Validade
	oPrn:Say(1645, 1760, AllTrim(mv_par01)                                    , oFont1,,,, PAD_RIGHT) //Volumes
	oPrn:Say(1805, 1760, AllTrim(Transform(mv_par02,"@E 999,999.99")+" kg")  , oFont1,,,, PAD_RIGHT) //Peso
	
	oPrn:EndPage()
Next x

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ ESTM001A ณ Autor ณ Tiago Oliveira Beraldiณ Data ณ11/10/05  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ CriaSX1                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Euroamerican                                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function CriaSX1(cPerg)
Local aRegs     := {}
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ           Grupo  Ordem Pergunta Portugues     Pergunta Espanhol  Pergunta Ingles Variavel Tipo Tamanho Decimal Presel  GSC Valid                              Var01      Def01             DefSPA1   DefEng1 Cnt01             Var02  Def02    		 DefSpa2  DefEng2	Cnt02  Var03 Def03      DefSpa3    DefEng3  Cnt03  Var04  Def04     DefSpa4    DefEng4  Cnt04  Var05  Def05       DefSpa5	 DefEng5   Cnt05  XF3   GrgSxg ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
aAdd(aRegs,{cPerg,'01' ,'Qtde. Volumes      ?',''               ,''             ,'mv_ch1','C'  ,20     ,0      ,0     ,'G','                                ','mv_par01','           '  ,''        ,''     ,'                ',''   ,'           ',''     ,''      ,''    ,''   ,'        ' ,''      ,''       ,''    ,''    ,'       ',''       ,''      ,''    ,''    ,''        ,''        ,''        ,''    ,'',''})
aAdd(aRegs,{cPerg,'02' ,'Peso (kg)          ?',''				 ,''			 ,'mv_ch2','N'  ,10     ,2      ,0     ,'G','                                ','mv_par02','           '  ,''		 ,''	 ,'                ',''   ,'           ',''   	 ,''   	  ,''	 ,''   ,'        ' ,''   	 ,''   	  ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'',''})
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Carrega as Perguntas no SX1                                  ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
ValidPerg(aRegs,cPerg)

Return NIL
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณESTM001B  บ Autor ณTiago O. Beraldi    บ Data ณ  20/08/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณIMPRESSAO DE ETIQUETA DE MATERIAL REPROVADO                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAEST                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function ESTM001B()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//|Declaracao de variaveis                                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local oDlg := Nil

Private cTitulo := "Impressใo - R๓tulo de Produto Reprovado"
Private oPrn    := Nil
Private oFont1  := Nil
Private oFont2  := Nil
Private oFont3  := Nil
Private cPerg    := "ESTM1A"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//|Declaracao de fontes                                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE FONT oFont1 NAME "Tahoma" SIZE 0,36 OF oPrn BOLD
DEFINE FONT oFont2 NAME "Tahoma" SIZE 0,14 OF oPrn BOLD
DEFINE FONT oFont3 NAME "Tahoma" SIZE 0,18 OF oPrn BOLD

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//|Verifica dicioanrio de perguntas                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Pergunte(cPerg,.F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//|Monta Dialog                                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlg FROM 264,182 TO 441,613 TITLE cTitulo OF oDlg PIXEL
@ 004,010 TO 082,157 LABEL "" OF oDlg PIXEL

@ 015,017 SAY "Esta rotina tem por objetivo imprimir " OF oDlg PIXEL Size 150,010 FONT oFont3  COLOR CLR_HBLUE
@ 030,017 SAY "os r๓tulos de produtos.               " OF oDlg PIXEL Size 150,010 FONT oFont3  COLOR CLR_HBLUE

@  6,167 BUTTON "&Imprime"    SIZE 036,012 ACTION fImprimir() OF oDlg PIXEL
@ 27,167 BUTTON "&Parametros" SIZE 036,012 ACTION Pergunte(cPerg,.T.) OF oDlg PIXEL
@ 48,167 BUTTON "Sai&r"       SIZE 036,012 ACTION oDlg:End() OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIMPRIMIR บ Autor ณTiago O. Beraldi    บ Data ณ  20/08/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณIMPRESSAO DE ETIQUETA DE MATERIAL REPROVADO                 บฑฑ
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
Static Function fImprimir()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//|Inicializa impressao                                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPrn := TMSPrinter():New()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//|Monta LayOut                                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
fLayOut()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//|Exibe impressao                                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPrn:Preview()
oPrn:End()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFLAYOUT   บ Autor ณTiago O. Beraldi    บ Data ณ  20/08/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณLAYOUT DA ETIQUETA                                          บฑฑ
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
Static Function fLayOut()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//|Configura Impressao Retrato                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPrn:SetPortrait()

For y:= 1 to Len(_aItens)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//|Impressao                                                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oPrn:StartPage()
	oPrn:Say(0670,0850,_aItens[y,4],oFont1)    //Produto
	oPrn:Say(0670,1560,DtoC(dDataBase),oFont1) //Data
	oPrn:Say(0870,1080,_aItens[y,10],oFont1)   //Lote
	oPrn:Say(1060,1080," ",oFont1)             //Devolucao
	oPrn:Say(1260,1080,mv_par01,oFont1)        //Volumes
	oPrn:Say(1440,1290,Transform(_aItens[y,18], "@E 99/99/9999"),oFont1) //Data Receb.
	oPrn:EndPage()
	
Next i

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCONFEROPC บ Autor ณTiago O. Beraldi    บ Data ณ  17/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณPROCESSAMENTO DE OPCOES DE CONFERENCIA                      บฑฑ
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
Static Function ConferOpc(nOpc)

Local aArea     := GetArea()
Local aAreaSD1  := SD1->(GetArea())
Local aWFIDs    := {}          // FS
Local nPosWS    := 0           // FS
Local nLin      := 0           // FS

//Grava conferencia
If nOpc == 1
	
	If MsgYesNo("Confirma grava็ใo de confer๊ncia ?")
		For i := 1 to Len(_aItens)
			dbSelectArea("SC7")
			dbSetOrder(1)
			If SC7->( dbSeek( xFilial("SC7") + _aItens[i,19] ) )
				If !Empty( SC7->C7_EUWFID )
					If aScan( aWFIDs, {|nLin| AllTrim( nLin[1] ) == AllTrim( SC7->C7_EUWFID ) }) == 0
						aAdd( aWFIDs, { AllTrim( SC7->C7_EUWFID ), SC7->C7_NUM })
					EndIf
				EndIf
			EndIf
			
			dbSelectArea("SD1")
			dbSetOrder(1)
			MsSeek(xFilial("SD1") + _aItens[i,2] + _aItens[i,13] +  _aItens[i,14] + _aItens[i,4] + _aItens[i,12])

			//Efetua inclusao da transferencia
			dbSelectArea("SD1")
			RecLock("SD1", .F.)
				If Empty( SD1->D1_LOTEFOR ) .And. !Empty( _aItens[i,9] )
					//SD1->D1_LOTEFOR := _aItens[i,9]
				EndIf
				If Empty( SD1->D1_DTVALID ) .And. !Empty( _aItens[i,11] )
					//SD1->D1_DTVALID := _aItens[i,11]
				EndIf
				SD1->D1_QTDCOF  := SD1->D1_QUANT //_aItens[i,7]
				SD1->D1_USRCONF := cUserName   
				SD1->D1_DTTRANS := dDataBase
			SD1->( MsUnLock() )
		Next i

		// Atualiza os processos da NF...
		For nPosWF := 1 To Len( aWFIDs )
			dbSelectArea("SC7")
			dbSetOrder(1)
			If SC7->( dbSeek( xFilial("SC7") + aWFIDs[nPosWF][2] ) )
				U_EQGeraWFC( "Protheus - Confer๊ncia Fํsica: " + AllTrim( SF1->F1_DOC ) + "|" + AllTrim( SF1->F1_SERIE ) + " Realizada. Pedido: " + AllTrim( SC7->C7_NUM ),;
				 			 "400200",;
							 "CONFERENCIA FISICA DA MERCADORIA",;
					         "1",;
							 "Confer๊ncia Fํsica Nota Fiscal de Entrada" )

				U_EQGeraWFC( "Protheus - Ticket: " + AllTrim( SF1->F1_DOC ) + "|" + AllTrim( SF1->F1_SERIE ) + " Aguardando Libera็ใo Caminhใo. Pedido: " + AllTrim( SC7->C7_NUM ),;
				 			 "400250",;
							 "AGUARDANDO LIBERACAO CAMINHAO",;
					         "1",;
							 "Aguardando Libera็ใo do Caminhใo" )
			EndIf
		Next
	EndIf
	
	//Transferencia ao almoxarifado
ElseIf nOpc == 2
	
	If MsgYesNo("Confirma grava็ใo da transfer๊ncia ?")
		
		For i := 1 to Len(_aItens)
			dbSelectArea("SC7")
			dbSetOrder(1)
			If SC7->( dbSeek( xFilial("SC7") + _aItens[i,19] ) )
				If aScan( aWFIDs, {|nLin| AllTrim( nLin[1] ) == AllTrim( SC7->C7_EUWFID ) }) == 0
					aAdd( aWFIDs, { AllTrim( SC7->C7_EUWFID ), SC7->C7_NUM })
				EndIf
			EndIf
			
			dbSelectArea("SD1")
			dbSetOrder(1)
			MsSeek(xFilial("SD1") + _aItens[i,2] + _aItens[i,13] +  _aItens[i,14] + _aItens[i,4] + _aItens[i,12])

			RecLock("SD1", .F.)
				SD1->D1_QTDCOF  := SD1->D1_QUANT
				SD1->D1_USRCONF := cUserName   
				SD1->D1_DTTRANS := dDataBase
			SD1->( MsUnLock() )

			// Efetuar desbloqueio do lote caso tes atualiza estoque...
			dbSelectArea("SF4")
			dbSetOrder(1)
			If SF4->( dbSeek( xFilial("SF4") + SD1->D1_TES ) )
				If AllTrim( SF4->F4_ESTOQUE ) == "S"
					dbSelectArea("SB1")
					dbSetOrder(1)
					SB1->( dbSeek( xFilial("SB1") + SD1->D1_COD ) )

					If SB1->B1_RASTRO <> "N"
						dbSelectArea("SB8")
						dbSetOrder(3) //B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_NUMLOTE, B8_DTVALID

						/*
						If SB8->( dbSeek( xFilial("SB8") + SD1->D1_COD + SD1->D1_LOCAL + SD1->D1_LOTECTL + SD1->D1_NUMLOTE ) )
							dbSelectArea('SDD')
							dbSetOrder(2) //DD_FILIAL, DD_PRODUTO, DD_LOCAL, DD_LOTECTL, DD_NUMLOTE, DD_MOTIVO

							If SDD->( dbSeek( xFilial("SDD") + SB8->B8_PRODUTO + SB8->B8_LOCAL + SB8->B8_LOTECTL + SB8->B8_NUMLOTE + "CO" ) )
								Reclock("SDD", .F.)
									SDD->DD_SALDO   := 0
									SDD->DD_SALDO2  := 0
								MsUnLock()

								ProcSDD(.T.)
							EndIf
						EndIf
						*/
					EndIf
				EndIf
			EndIf
		Next i
		
		// Atualiza os processos da NF...
		For nPosWF := 1 To Len( aWFIDs )
			dbSelectArea("SC7")
			dbSetOrder(1)
			If SC7->( dbSeek( xFilial("SC7") + aWFIDs[nPosWF][2] ) )
				U_EQGeraWFC( "Protheus - Confer๊ncia Fํsica: " + AllTrim( SF1->F1_DOC ) + "|" + AllTrim( SF1->F1_SERIE ) + " Realizada. Pedido: " + AllTrim( SC7->C7_NUM ),;
				 			 "400200",;
							 "CONFERENCIA FISICA DA MERCADORIA",;
					         "1",;
							 "Confer๊ncia Fํsica Nota Fiscal de Entrada" )

				U_EQGeraWFC( "Protheus - Ticket: " + AllTrim( SF1->F1_DOC ) + "|" + AllTrim( SF1->F1_SERIE ) + " Aguardando Libera็ใo Caminhใo. Pedido: " + AllTrim( SC7->C7_NUM ),;
				 			 "400250",;
							 "AGUARDANDO LIBERACAO CAMINHAO",;
					         "1",;
							 "Aguardando Libera็ใo do Caminhใo" )
			EndIf
		Next
	EndIf
	
ElseIf nOpc == 3
	
	BrwLegenda("Confer๊ncia de Entrada","Legenda",{{"ENABLE"    	,"Nใo Transferido"},;
	{"BR_AMARELO" 	,"Em Anแlise"},;
	{"DISABLE"   	,"Transferido"}})
	
EndIf

RestArea(aAreaSD1)
RestArea(aArea)

Return
