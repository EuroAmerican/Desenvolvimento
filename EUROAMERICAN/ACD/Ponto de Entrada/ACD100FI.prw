#Include "Protheus.Ch"

User Function ACD100FI()

Local nTipo    := ParamIXB[1]
Local aRetorno := Array(2)
Local cFiltro  := ""

If nTipo == 3 // Se OS de OP somente trazar o item 01 de PI...
	cFiltro := " C2_ITEM == '01' "
else
	cFiltro := " .T. "
EndIf

aRetorno[1] := nTipo
aRetorno[2] := cFiltro

Return aRetorno
