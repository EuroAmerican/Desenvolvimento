#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} mtseleop
//PE utilizado para apresentar ou nao a tela de selecao
//de opcionais. ParamIxb[1]=String do campo _OPC; ParamIxb[2]=Cod.Produto; ParamIxb[3]=Nome do programa
@author marcos
@since 27/10/2016
@version 1.0
@type function
/*/
User Function mtseleop()
	Local lRet := .T.

	If Rtrim(ParamIxb[3])  $ "MATA415|MATA410"
		lRet := .F.
	EndIf
	Return(lRet)