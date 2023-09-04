#Include 'Protheus.Ch'
#Include 'Totvs.Ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EQAceWor ºAutor  ³ Fabio F Sousa      º Data ³  23/04/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna array com acessos aos processos de expedição e     º±±
±±º          ³ recebimentos em geral...									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDocumento ³ 												  			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Euroamerican...                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function EQAceWor()

Local aArea    := GetArea()
Local aRetorno := { .F., .F., .T., .T. }             // { lSeparacao, lEmbarque, lRecebimento, lCadastro }
Local aGrupos  := UsrRetGrp ( __cUserId )
Local nGrp     := 0

dbSelectArea("Z14")
dbSetOrder(1)
             
If Z14->( dbSeek( xFilial("Z14") + __cUserId ) )

	aRetorno[4] := .T.
	
	If AllTrim( Z14->Z14_PERFIL ) == "S"
		aRetorno[1] := .T.
		aRetorno[2] := .F.
		aRetorno[3] := .F.
	ElseIf AllTrim( Z14->Z14_PERFIL ) == "E"
		aRetorno[1] := .F.
		aRetorno[2] := .T.
		aRetorno[3] := .F.
	ElseIf AllTrim( Z14->Z14_PERFIL ) == "R"
		aRetorno[1] := .F.
		aRetorno[2] := .F.
		aRetorno[3] := .T.
	Else
		aRetorno[1] := .T.
		aRetorno[2] := .T.
		aRetorno[3] := .T.
	EndIf
Else
	dbSelectArea("Z14")
	dbSetOrder(2)

	For nGrp := 1 To Len( aGrupos )
		If Z14->( dbSeek( xFilial("Z14") + aGrupos[nGrp] ) )

			aRetorno[4] := .T.
	
			If AllTrim( Z14->Z14_PERFIL ) == "S"
				aRetorno[1] := .T.
				aRetorno[2] := .F.
				aRetorno[3] := .F.
			ElseIf AllTrim( Z14->Z14_PERFIL ) == "E"
				aRetorno[1] := .F.
				aRetorno[2] := .T.
				aRetorno[3] := .F.
			ElseIf AllTrim( Z14->Z14_PERFIL ) == "R"
				aRetorno[1] := .F.
				aRetorno[2] := .F.
				aRetorno[3] := .T.
			Else
				aRetorno[1] := .T.
				aRetorno[2] := .T.
				aRetorno[3] := .T.
			EndIf
		EndIf
	Next
EndIf

RestArea( aArea )

Return aRetorno