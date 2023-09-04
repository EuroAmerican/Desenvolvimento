#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} f70grse1
//PE apos a gravar a baixa do titulo a receber, atualizacao do historico.
@author mjlozzardo
@since 25/04/2018
@version 1.0
/*/
User Function f70grse1()
	Local cAlias := Alias()
	Local cOcorr := ParamIxb[1]

	If Rtrim(Lower(cHist070)) != "valor recebido s/ titulo"
		SE1->(RecLock("SE1", .F.))
		SE1->E1_HIST := Rtrim(SE1->E1_HIST) + Rtrim(cHist070)
		SE1->(MsUnLock())
	EndIf
	DbSelectArea(cAlias)
	Return