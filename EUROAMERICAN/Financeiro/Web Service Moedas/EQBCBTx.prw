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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矪eWSICSTx � Autor � 				        � Data � 28.06.16 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Consumo de Web Service de atualiza玢o das taxas de cota玢o 潮�
北�			 � das moedas Dolar e Euro no Financeiro e Importa玢o		  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � Void BeWSICSTx(ExpD1)			                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpD1 = Data de Atualiza玢o da Moeda                       潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Verifico se rotina esta sendo executada via Schedule				   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If Select("SX5") <= 0
	lSchdAut := .T.
 	RPCSETENV(aParam[2],aParam[3],,,"FIN",,{"SM2","SYE"})
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矯ria Cria Diretorio caso n鉶 exista									   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪的哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
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

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矯arrega Variavel com o XML do Resultado do Get						   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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

		// Pula para pr髕ima linha  
		FT_FSKIP()

	Else	
		lErro := .T.			
		Exit
	EndIf
End

// Fecha o Arquivo
FT_FUSE()

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//砅rocessa Recebimento													   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If Len(aRetTx) > 0
	aEval(aRetTx,{|x| x[6] := Val(StrTran(x[6],",",".")) })

	lErro := BeExecProc(aRetTx, dDtExec)
EndIf

Return

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    矪eExecProc� Autor � 				        � Data � 28.06.16 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Atualiza tabelas SM2 e SYE de cota玢o das moedas conforme  潮�
北�			 � retorno do Web Service.									  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � Void BeExecProc(ExpA1, ExpD2)	                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� ExpA1 = [01] - Vers鉶 WS ICS			         	          潮�
北�          �         [02] - C骴igo da Moeda				              潮�
北�          �         [03] - Data Inicial   				              潮�
北�          �         [04] - Data Final					              潮�
北�          �         [05] - Taxa da Moeda no dia  		              潮�
北�          � ExpD2 = Data de Atualiza玢o da Moeda no Sistema 	          潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function BeExecProc(aTaxas, dDtExec)

Local lRetErro	:= .F.
Local nX		:= 0
Local nPosDol	:= aScan(aTaxas,{|x| Alltrim(x[2]) == "220" })
Local nPosEUR	:= aScan(aTaxas,{|x| Alltrim(x[2]) == "978" })

Local dDtGrv	:= dDtExec+1
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矨tualiza Moeda Financeiro											   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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
