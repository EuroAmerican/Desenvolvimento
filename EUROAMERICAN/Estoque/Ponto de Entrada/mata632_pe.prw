#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} mata632
//PE usado para bloquear a alteracao de um roteiro de producao, caso
//exista uma OP ja cadastrada.
@author mjlozzardo
@since 21/01/2019
@version 1.0
@type function
/*/
User Function mata632()
	Local lRet       := .T.
	Local aParam     := aClone(ParamIxb)
	Local oObj       := ""
	Local cIdPonto   := ""
	Local cIdModel   := ""
	Local lIsGrid    := .F.
	Local aButtons   := {}
	Local cAlias     := Alias()

	If aParam <> NIL
		oObj       := aParam[1]
		cIdPonto   := Alltrim(aParam[2])
		cIdModel   := aParam[3]
		lIsGrid    := (Len( aParam ) > 3)

		If cIdPonto == "MODELVLDACTIVE" .and. Altera
			SC2->(DbSetOrder(11))
			If SC2->(DbSeek(xFilial("SC2") + SG2->(G2_PRODUTO + G2_CODIGO), .F.))
				//lRet := .F.
				//MsgInfo("Esse roteiro já foi utilizado em uma ordem de produção, alteração não permitida. Favor criar um novo roteiro.", "JA USADO")
			EndIf
		EndIf
	EndIf
	DbSelectArea(cAlias)
	Return(lRet)
