#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EQRetWFR ºAutor  ³ Fabio  Sousa       º Data ³  08/11/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para buscar ultima movimentação do Status 		  º±±
±±º          ³ Parametros:	cPar1 := Código da Filial					  º±±
±±º          ³ 				cPar2 := Código do Processo  				  º±±
±±º          ³ 				cPar3 := Código do Status    				  º±±
±±º          ³ 				cPar4 := Código Identificador do Processo	  º±±
±±º          ³ Retorno:		aRet1 := Nome do Usuario       				  º±±
±±º          ³ 				aRet2 := Data do Movimento 					  º±±
±±º          ³ 				aRet3 := Hora do Movimento 					  º±±
±±º          ³ 				aRet4 := Código do Status 					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function EQRetWFR(cFilWF,cProc,cStatus,cID)
                                                
Local aRet := {"","","",""} //Usuario, Data, Hora, Status

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posição WF3														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("WF3")
dbSetOrder(4)
dbSeek(cFilWF+Substr(cID,1,8))

While !WF3->(EOF()) .And. cFilWF == WF3->WF3_FILIAL .And. cProc == WF3->WF3_PROC .And. Substr(WF3->WF3_ID,1,8) == Substr(cID,1,8)

	If !Empty(cStatus)
		If cStatus == WF3->WF3_STATUS
			aRet := {WF3->WF3_USU, WF3->WF3_DATA,WF3->WF3_HORA,WF3->WF3_STATUS}
		ElseIf 	!Empty(aRet[1]) .And. Substr(cStatus,1,3)+"900" == WF3->WF3_STATUS
			aRet := {"","","",""}	
		EndIf	
	ElseIf WF3->WF3_STATUS >= '100000'
		aRet := {WF3->WF3_USU, WF3->WF3_DATA,WF3->WF3_HORA,WF3->WF3_STATUS}
	EndIf
	
	WF3->(dbSkip())
End

Return aRet