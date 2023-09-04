#include 'protheus.ch'
#include 'parmtype.ch'

/*{Protheus.doc} mt010inc
//PE utilizado para gerar o EAN 13 na inclusao do produto
@author 
@since 07/02/2018
@version 1.0
@type function
*/
   
User Function EQCodBar()

Local cAlias := Alias()
Local aAreaB1:= SB1->(GetArea())
Local cTipo  := SuperGetMV("ES_MTA010A", .T., "KT|PA|PV")
Local cSeq   := ""
Local cEan   := ""
Local nRegB1 := SB1->(RecNo())

//Sequência contratada Qualyvinil 789825824 + 3 dígitos + 1 dígito verificador

If SB1->B1_TIPO $ cTipo .and. Empty(SB1->B1_CODBAR) .and. !Empty(SB1->B1_GRUPO) .And. SB1->B1_MSBLQL <> '1'

	If MsgYesNo("Confirma a geração do Código de Barras para o Produto = "+SB1->B1_COD)

		SZ2->(DbSetOrder(2))
		SZ2->(DbSeek(xFilial("SZ2") + SB1->B1_GRUPO, .T.))
		If SB1->B1_GRUPO >= SZ2->Z2_GRPDE .and. SB1->B1_GRUPO <= SZ2->Z2_GRPATE
			cSeq := Soma1(SZ2->Z2_SEQ)
			SB1->(DbSetOrder(5))
			While .T.
				cEan := (SZ2->Z2_MATRIZ + cSeq) + Rtrim(EanDigito(SZ2->Z2_MATRIZ + cSeq))
				If SB1->(DbSeek(xFilial("SB1") + cEan, .F.))
					cSeq := Soma1(cSeq)
					Loop
				Else
					SZ2->(RecLock("SZ2", .F.))
					SZ2->Z2_SEQ := cSeq
					SZ2->(MsUnLock())
    	
					SB1->(DbGoTo(nRegB1))
					SB1->(RecLock("SB1", .F.))
					SB1->B1_CODBAR := cEan
					SB1->(MsUnLock())

					MsgAlert("Atenção", "Código de Barras Gerado Com Sucesso!")

					Exit
				EndIf
			EndDo
		Else
			MsgAlert("Atenção", "Não foi localizada a configuração EAN, favor informar o TI.")
		EndIf
    EndIf
Else
	MsgAlert("Não é permitida a geração do codigo de barras para esse produto. Verifique se o produto está bloqueado, o tipo do produto e o grupo.","Atenção" )
EndIf

DbSelectArea(cAlias)
RestArea(aAreaB1)

Return
