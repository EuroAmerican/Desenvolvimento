#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

// FS - Ponto de Entrada para Bloqueio de NF após validação da tolerância no recebimento...

User Function A103BLOQ()

Local lBloqueio := ParamIxb[1]
Local lRetorno  := lBloqueio
Local aArea     := GetArea()
Local aWFIDs    := {}
Local nPosWS    := 0
Local nLin      := 0

dbSelectArea("SD1")
dbSetOrder(1)
dbSeek( xFilial("SF1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA )

Do While !SD1->( Eof() ) .And. xFilial("SF1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA == xFilial("SD1") + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA
	If !Empty( SD1->D1_PEDIDO )
		dbSelectArea("SC7")
		dbSetOrder(1)
		If SC7->( dbSeek( xFilial("SC7") + SD1->D1_PEDIDO ) )
			If !Empty( SC7->C7_EUWFID )
				If aScan( aWFIDs, {|nLin| AllTrim( nLin[1] ) == AllTrim( SC7->C7_EUWFID ) }) == 0
					aAdd( aWFIDs, { AllTrim( SC7->C7_EUWFID ), SC7->C7_NUM })
				EndIf
			EndIf
		EndIf
	EndIf

	SD1->( dbSkip() )
EndDo

If lBloqueio // Indica que houve bloqueio por tolerância de recebimento
	For nPosWF := 1 To Len( aWFIDs )
		dbSelectArea("SC7")
		dbSetOrder(1)
		If SC7->( dbSeek( xFilial("SC7") + aWFIDs[nPosWF][2] ) )
			U_EQGeraWFC( "Protheus - Nota Fiscal de Entrada: " + AllTrim( SF1->F1_DOC ) + "|" + AllTrim( SF1->F1_SERIE ) + " Bloqueado por Intolerância no Recebimento. Pedido: " + AllTrim( SC7->C7_NUM ),;
			 			 "400010",;
						 "BLOQUEIO NOTA FISCAL POR TOLERANCIA DE RECEBIMENTO",;
				         "1",;
						 "Bloqueio Nota Fiscal de Entrada por Tolerância de Recebimento" )
		EndIf
	Next
Else
	For nPosWF := 1 To Len( aWFIDs )
		dbSelectArea("SC7")
		dbSetOrder(1)
		If SC7->( dbSeek( xFilial("SC7") + aWFIDs[nPosWF][2] ) )
			U_EQGeraWFC( "Protheus - Nota Fiscal de Entrada: " + AllTrim( SF1->F1_DOC ) + "|" + AllTrim( SF1->F1_SERIE ) + " Dentro da Tolerância no Recebimento e Aprovador. Pedido: " + AllTrim( SC7->C7_NUM ),;
			 			 "400020",;
						 "APROVACAO NOTA FISCAL DE ENTRADA [DENTRO DA TOLERANCIA]",;
				         "1",;
						 "Aprovação Nota Fiscal de Entrada Automática" )
		EndIf
	Next
EndIf

RestArea( aArea )

Return lRetorno