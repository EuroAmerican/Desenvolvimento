#Include 'Protheus.Ch'

User Function V166VLD()

Local lRetorno  := .T.
Local cEtiqueta := ParamIXB[1]
Local nQuant    := ParamIXB[2]

If nQuant <> nSaldoCB8
	VtAlert("Quantidade Diferente do Saldo Permitido para Separacao","Corrija a Quantidade",.t.,4000,4)
	lRetorno    := .F.
	nQtde       := nSaldoCB8
	nQuant      := nSaldoCB8
	ParamIXB[2] := nSaldoCB8
	VtClearGet("cEtiProd")
	VtGetSetFocus("nQtde")
EndIf

Return lRetorno