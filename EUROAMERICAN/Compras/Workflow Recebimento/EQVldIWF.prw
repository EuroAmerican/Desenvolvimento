#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EQVldIWF ³ Autor ³ Fabio Sousa			 ³ Data ³ 02/03/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para validação se pedido de venda ou pedido de com-³±±
±±³          ³ pra controlará seu Processo de Expedição/ Recebimento       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Euroamerican...                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function EQVldIWF( lCompra, cNumPed )

Local lRet			:= .F.
Local lEmp01		:= SM0->M0_CODIGO $ GetMv("MV_EQ_SFEM",,"02|08|")
Local cFilUsaWF	    := Alltrim(SuperGetMV("MV_EQ_FIWF",.F.,"00|01|03|",)) // Filiais habilitadas para utilização do controle de processo
Local aArea 		:= GetArea()
Local aAreaSC5 		:= {}
Local aAreaSC6 		:= {}
Local aAreaSC7 		:= {}
Local aAreaSF4		:= {}

If lCompra
	aAreaSC7 := SC7->(GetArea())

	If lEmp01 .And. Alltrim( xFilial("SC7") ) $ cFilUsaWF // Por enquanto, somente tipo PC, AE será tratado depois... (.And. SC7->C7_TIPO == 1) todos...
		lRet := .T.
	EndIf

	SC7->( RestArea( aAreaSC7 ) )
Else
	aAreaSC5 := SC5->(GetArea())
	aAreaSC6 := SC6->(GetArea())
	aAreaSF4 := SF4->(GetArea())

	If lEmp01 .And. SC5->C5_TIPO == "N" .And. Alltrim(SC5->C5_FILIAL) $ cFilUsaWF //.And. Empty( SC5->C5_PEDEXP )
		
		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xFilial("SC6")+SC5->C5_NUM)
	
		Do While !SC6->(Eof()) .and. SC6->C6_FILIAL == SC5->C5_FILIAL .And. SC6->C6_NUM == SC5->C5_NUM
	
			dbSelectArea("SF4")
			dbSetOrder(1)
			If dbSeek(xFilial("SF4")+SC6->C6_TES)
			
				If AllTrim( GetMv( "MV_BEWFPEX",, "2") ) == "1"
					lRet := .T.
					Exit
				ElseIf AllTrim( GetMv( "MV_BEWFPEX",, "2") ) == "2"
					If SF4->F4_ESTOQUE == 'S'
						lRet := .T.
						Exit
		            EndIf
				Else
					If SF4->F4_DUPLIC == 'S' .And. SF4->F4_ESTOQUE == 'S'
						lRet := .T.
						Exit
		            EndIf
	            EndIf
			EndIf
			    	
			SC6->(dbSkip())
		EndDo
	EndIf

	SC5->( RestArea( aAreaSC5 ) )
	SC6->( RestArea( aAreaSC6 ) )
	SF4->( RestArea( aAreaSF4 ) )
EndIf

RestArea( aArea )

Return lRet