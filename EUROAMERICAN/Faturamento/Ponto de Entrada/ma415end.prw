#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} ma415end
//PE usado para gravar o peso liq. e bruto no orcamento de venda
@author mjlozzardo
@since 12/09/2018
@version 1.0
/*/
User Function ma415end()
	Local lConf := ParamIxb[1] == 1
	Local lExcl := ParamIxb[2] == 3
	Local cAlias := Alias()
	Local nPesLiq:= 0
	Local nPesBrt:= 0

	If !lExcl
		SCK->(DbSetOrder(1))
		SB1->(DbSetOrder(1))
		If SCK->(DbSeek(xFilial("SCK") + SCJ->CJ_NUM, .F.))
			While SCK->(!Eof()) .and. SCK->CK_NUM == SCJ->CJ_NUM
				SB1->(DbSeek(xFilial("SB1") + SCK->CK_PRODUTO, .F.))
				nPesLiq += SCK->CK_QTDVEN * SB1->B1_PESO
				nPesBrt += SCK->CK_QTDVEN * SB1->B1_PESBRU
				SCK->(DbSkip())
			EndDo
			SCJ->(RecLock("SCJ", .F.))
			SCJ->CJ_PESOL  := nPesLiq
			SCJ->CJ_PBRUTO := nPesBrt
			SCJ->(MsUnLock())
		EndIf
	EndIf
	DbSelectArea(cAlias)
	Return(.T.)
