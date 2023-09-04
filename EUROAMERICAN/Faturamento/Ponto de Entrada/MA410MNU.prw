#include 'protheus.ch'
/*/{Protheus.doc} MA410MNU
//Ponto de entrada disparado antes da abertura do Browse, caso Browse inicial da rotina esteja habilitado, ou antes da apresentação do
//Menu de opções, caso Browse inicial esteja desabilitado.
//http://tdn.totvs.com/display/public/PROT/MA410MNU
@author Emerson Paiva
@since 11/04/2018
@version 1.0
/*/
#define ENTER CHR(13) + CHR(10)

User Function MA410MNU
	aadd(aRotina,{'Altera Entrega' , 'U_X410ENTG', 0 , 3, 0, Nil})
	aAdd(aRotina,{'Importar Pedido', 'U_FATM025' , 0 , 3, 0, Nil})
	aAdd(aRotina,{'Historico do PV', 'U_MFAT001' , 0 , 4, 0, Nil})

Return

//Altera data entrega
User Function X410ENTG

Local aArea     := GetArea()
Local aAreaSC5  := SC5->(GetArea())
Local aAreaSC6  := SC6->(GetArea())
Local aAreaCB8	:= CB8->(GetArea())

Local lOkUsr    := .T. //Iif(AllTrim(Upper(cUserName)) $ "ADMINISTRADOR", .T., .F.)
Local lBtnOK	:= .F.
Local cGetEnt	:= SC5->C5_FECENT
Local oSay1
Local aButtons	:= {}
local oDlg
Local nItensFat	:=	0

If Empty(SC5->C5_NOTA) .And. lOkUsr

	dbSelectArea("CB8")
	dbSetOrder(2)
	dbSeek(xFilial("CB8") + SC5->C5_NUM)

	If CB8->( Found() )

		MsgStop("Item com ordem de separação gerada, não pode ser alterada data de entrega!")

	Else

		DEFINE MSDIALOG oDlg TITLE "Altera data entrega" FROM 000, 000 TO 190, 295 PIXEL

		@ 015, 002 GROUP oGroup1 TO 091, 144 OF oDlg PIXEL
	    @ 035, 006 SAY oSay1 PROMPT "Data de Entrega" SIZE 042, 007 OF oDlg PIXEL
	    @ 033, 048 MSGET oGet1 VAR cGetEnt PICTURE "99/99/99"  SIZE 091, 010 OF oDlg PIXEL

		ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||lBtnOK:=.T.,oDlg:End()},{||oDlg:End()},,@aButtons)) CENTERED

		If lBtnOK

			If SC5->C5_FECENT >= cGetEnt

				MsgStop("Data de entrega não pode ser menor que a atual!")

			Else

				dbSelectArea("SC5")
				RecLock("SC5", .F.)
					SC5->C5_FECENT := cGetEnt
					SC5->C5_OBS    := RTrim(SC5->C5_OBS) +;
					                  IIf( RTrim( SC5->C5_OBS ) != "", ENTER, "") +;
					                  "[ALTERACAO ENTREGA] " + cUserName + " Data/Hora: " + DtoC(dDataBase) + " " + Time()
				SC5->(MsUnLock())

				dbSelectArea("SC6")
				dbSetOrder(1)
				dbSeek(xFilial("SC6") + SC5->C5_NUM)

				While !EOF("SC6") .And. SC6->C6_NUM == SC5->C5_NUM

					If Empty(SC6->C6_NOTA)
						dbSelectArea("SC6")
						RecLock("SC6", .F.)
							SC6->C6_ENTREG	:= cGetEnt
						SC6->(MsUnLock())
					Else
						nItensFat	:= nItensFat + 1
					EndIf

					dbSkip()
				EndDo

				If nItensFat > 0
					MsgStop("Pedido possui " + nItensFat + " itens já faturados que não tiveram sua data de entrega alterada!")
				EndIf

				dbSelectArea("SC9")
				dbSetOrder(1)
				dbSeek(xFilial("SC9") + SC5->C5_NUM)

				While !EOF("SC9") .And. SC9->C9_PEDIDO == SC5->C5_NUM

					If Empty(SC9->C9_NFISCAL)
						//MsgStop(SC9->C9_PEDIDO + " " + SC9->C9_PRODUTO + " " + DTOC(SC9->C9_DATENT))
						dbSelectArea("SC9")
						RecLock("SC9", .F.)
							SC9->C9_DATENT	:= cGetEnt
						SC9->(MsUnLock())
					EndIf

					dbSkip()
				EndDo

				MsgStop("Data de entrega atualizada com sucesso!")

			EndIf

		EndIf

	EndIf

Else

    MsgStop("Operação não disponível para o pedido!")

EndIf

RestArea( aAreaCB8 )
RestArea( aAreaSC6 )
RestArea( aAreaSC5 )
RestArea( aArea )

Return Nil