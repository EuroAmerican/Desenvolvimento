#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'
#Include 'Totvs.Ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT381VLD º Autor ³ Fabio    	         º Data ³ 23/12/2017  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ponto de entrada para validação de ajuste de empenhos mod2 º±±
±±º          ³                                 							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grupo Sabará                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MT381VLD()

Local aArea     := GetArea()
Local lValido   := .T.
Local lInc      := PARAMIXB[1]
Local lAlt      := PARAMIXB[2]
Local lRetorno  := .T.
Local cQuery    := ""
Local nPosProd  := aScan( aHeader, {|x| "D4_COD"     $ x[2] })
Local nPosLocal := aScan( aHeader, {|x| "D4_LOCAL"   $ x[2] })
Local nPosLote  := aScan( aHeader, {|x| "D4_LOTECTL" $ x[2] })
Local nPosSubL  := aScan( aHeader, {|x| "D4_NUMLOTE" $ x[2] })
Local nPosTRT   := aScan( aHeader, {|x| "D4_TRT"     $ x[2] })
Local nPosOP    := aScan( aHeader, {|x| "D4_OP"      $ x[2] })
Local nPosQuant := aScan( aHeader, {|x| "D4_QUANT"   $ x[2] })
Local nLinha    := 0
Local cMsg      := ""

nHeader := Len(aHeader)

/*
For nLinha := 1 To Len( aCols )
	If !( aCols[nLinha][nHeader+1] ) //Registro Deletado
		dbSelectArea("SB2")
		dbSetOrder(1)
		If SB2->( dbSeek( xFilial("SB2") + aCols[nLinha][nPosProd] ) )
			//Verificar se OP e item já está empenhado (1): D4_FILIAL, D4_COD, D4_OP, D4_TRT, D4_LOTECTL, D4_NUMLOTE
			dbSelectArea("SD4")
			dbSetOrder(1)
			If SD4->( dbSeek( xFilial("SD4") + aCols[nLinha][nPosProd] + aCols[nLinha][nPosOP] + aCols[nLinha][nPosTRT] + aCols[nLinha][nPosLote] + aCols[nLinha][nPosSubL] ) )
				If SD4->D4_QUANT < aCols[nLinha][nPosQuant]
					If aCols[nLinha][nPosQuant] > ( SB2->B2_QATU - SB2->B2_QEMP - SB2->B2_RESERVA )
						cMsg += "Produto: " + aCols[nLinha][nPosProd] + " Necessário: " + Transform( aCols[nLinha][nPosQuant], "@E 999,999.99") + " Saldo: " + Transform( ( SB2->B2_QATU - SB2->B2_QEMP - SB2->B2_RESERVA ), "@E 999,999.99") + CRLF
					EndIf
				EndIf
			Else
				If aCols[nLinha][nPosQuant] > ( SB2->B2_QATU - SB2->B2_QEMP - SB2->B2_RESERVA )
					cMsg += "Produto: " + aCols[nLinha][nPosProd] + " Necessário: " + Transform( aCols[nLinha][nPosQuant], "@E 999,999.99") + " Saldo: " + Transform( ( SB2->B2_QATU - SB2->B2_QEMP - SB2->B2_RESERVA ), "@E 999,999.99") + CRLF
				EndIf
			EndIf
		EndIf
	EndIf
Next
*/

If !Empty( cMsg )
	//Aviso( "MTA650I - Aviso", "Ordem de Produção possui componentes sem saldo suficiente disponível:" + CRLF + cMsg, {"OK"}, 3)
	//lValido := .F.
EndIf
//lValido := BeAutori()

RestArea(aArea)

Return lValido

Static Function BeAutori()

Local lRet      := .T.
Local nPosProd	:= aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D4_COD" })
Local cTipos    := GetMV( "MV_BE_AJTP",, "'PA','MP','PI','ME','EM','RV','BN','SP','PP','KT'")

For nLin := 1 To Len( aCols )
	If ! aCols[nLin,Len(aHeader)+1]	// Indica se linha esta deletada
		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->( dbSeek( xFilial("SB1") + aCols[nLin,nPosProd] ) )
			If !(AllTrim( SB1->B1_TIPO ) $ cTipos)
				Aviso("MT381VLD / Tipo Produto!","Tipo Produto: " + SB1->B1_TIPO + " não permitido efetuar ajuste de empenhos Mod. 2!",{"Cancela"})
				lRet := .F.
				Exit
			EndIf
		EndIf
	EndIf
Next

Return lRet
