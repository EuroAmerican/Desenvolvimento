#include "protheus.ch"
#include "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"

#define DATACOTAC	1
#define CODMOEDA 	2
#define TIPOMOEDA	3
#define DESCMOEDA	4
#define TXCOMPRA	5
#define TXVENDA		6
#define PARCOMPRA	7
#define PARVENDA	8

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³BeWSICSTx ³ Autor ³ 				        ³ Data ³ 28.06.16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consumo de Web Service de atualização das taxas de cotação ³±±
±±³			 ³ das moedas Dolar e Euro no Financeiro e Importação		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void BeWSICSTx(ExpD1)			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data de Atualização da Moeda                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function EQBCBTx(aParam)

Local cPathBCB	:= "\BCB\"+DtoS(msdate())+"\"
Local cArqCSV	:= ""
Local cHttpTx	:= "https://www4.bcb.gov.br/Download/fechamento/"
Local cMensagem	:= ""
Local cMailNot	:= ""

Local aRetTx	:= {}

Local dDtVld	:= CtoD("  /  /  ")

Local lErro		:= .F.

Private aErro	:= {}
Private aMsgAt	:= {}
Private dDtExec	:= CtoD("  /  /  ") 

DEFAULT aParam := {msdate(),"01","01",,}

dDtExec := aParam[01]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se rotina esta sendo executada via Schedule				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("SX5") <= 0
	lSchdAut := .T.
 	RPCSETENV(aParam[2],aParam[3],,,"FIN",,{"SM2","SYE"})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria Cria Diretorio caso não exista									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄµÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ExistDir(cPathBCB,,.F.)
	MakeDir(cPathBCB,,.F.)
EndIf

If Empty(dDtExec)
	dDtExec := msdate()
EndIf

dDtVld := DataValida(dDtExec,.F.)

cCert 	:= "\certificados\000010_all.pem"
cKey	:= "\certificados\000010_key.pem"

cArqCSV	:= cPathBCB+DtoS(dDtVld)+".csv"
nArqCSV	:= MsFCreate(cArqCSV)

FWrite(nArqCSV,Httpsget(cHttpTx+DtoS(dDtVld)+".csv",cCert,cKey,"1234")) 
FClose(nArqCSV)   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega Variavel com o XML do Resultado do Get						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHdlCSV	:= FT_FUse(cArqCSV)
cLinRet	:= ""
If nHdlCSV == -1
	Return .F.
EndIf	

// Posiciona na primeria linha
FT_FGoTop()

While !FT_FEOF()   
	cLinRet  := FT_FReadLn() 
	
	If ";" $ cLinRet

		If Substr(cLinRet,12,3) $ "220|978"
			aAdd(aRetTx,StrTokArr(cLinRet,";"))
		EndIf

		// Pula para próxima linha  
		FT_FSKIP()

	Else	
		lErro := .T.			
		Exit
	EndIf
End

// Fecha o Arquivo
FT_FUSE()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Recebimento													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aRetTx) > 0
	aEval(aRetTx,{|x| x[6] := Val(StrTran(x[6],",",".")) })

	lErro := BeExecProc(aRetTx, dDtExec)
EndIf

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³BeExecProc³ Autor ³ 				        ³ Data ³ 28.06.16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza tabelas SM2 e SYE de cotação das moedas conforme  ³±±
±±³			 ³ retorno do Web Service.									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void BeExecProc(ExpA1, ExpD2)	                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = [01] - Versão WS ICS			         	          ³±±
±±³          ³         [02] - Código da Moeda				              ³±±
±±³          ³         [03] - Data Inicial   				              ³±±
±±³          ³         [04] - Data Final					              ³±±
±±³          ³         [05] - Taxa da Moeda no dia  		              ³±±
±±³          ³ ExpD2 = Data de Atualização da Moeda no Sistema 	          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function BeExecProc(aTaxas, dDtExec)

Local lRetErro	:= .F.
Local nX		:= 0
Local nPosDol	:= aScan(aTaxas,{|x| Alltrim(x[2]) == "220" })
Local nPosEUR	:= aScan(aTaxas,{|x| Alltrim(x[2]) == "978" })

Local dDtGrv	:= dDtExec+1
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza Moeda Financeiro											   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Begin Transaction

	dbSelectArea("SM2")
	dbSetOrder(1)
	If dbSeek(dDtGrv)
		RecLock("SM2",.F.)
	Else
		RecLock("SM2",.T.)
	EndIf

	SM2->M2_DATA 	:= dDtGrv
	SM2->M2_MOEDA2  := aTaxas[nPosDol][6]
	SM2->M2_MOEDA3	:= 0
	SM2->M2_MOEDA4	:= aTaxas[nPosEUR][6] 
	SM2->M2_MOEDA5	:= 0  
	SM2->M2_INFORM	:= "S"
	SM2->(MsUnlock())

End Transaction	

Return lRetErro
