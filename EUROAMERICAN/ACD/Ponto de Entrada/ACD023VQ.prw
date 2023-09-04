#Include 'Protheus.Ch'

User Function ACD023VQ()

Local aArea     := GetArea()
Local aAreaSC2  := SC2->( GetArea() )
Local aAreaSG1  := SG1->( GetArea() )
Local aAreaSG2  := SG2->( GetArea() )
Local aAreaSB1  := SB1->( GetArea() )
Local aAreaCBH  := CBH->( GetArea() )
Local aAreaSH6  := SH6->( GetArea() )
Local lRetorno  := .T.
Local cOP       := ParamIXB[1]
Local cOperacao := ParamIXB[2]
Local cOperador := ParamIXB[3]
Local nQTD      := ParamIXB[4]
Local lInicio   := ParamIXB[5]

If AllTrim( cOperacao ) <> "50"
	dbSelectArea("SC2")
	dbSetOrder(1)
	If SC2->( dbSeek( xFilial("SC2") + cOP ) )
		If SC2->C2_QUANT <> nQTD
			lRetorno := .F.
			CBAlert("Quantidade indevida para a operacao","Aviso",.T.,4000,2)
		EndIf
	EndIf
EndIf

SC2->( RestArea( aAreaSC2 ) )
SG1->( RestArea( aAreaSG1 ) )
SG2->( RestArea( aAreaSG2 ) )
SB1->( RestArea( aAreaSB1 ) )
CBH->( RestArea( aAreaCBH ) )
SH6->( RestArea( aAreaSH6 ) )
RestArea( aArea )

Return lRetorno
