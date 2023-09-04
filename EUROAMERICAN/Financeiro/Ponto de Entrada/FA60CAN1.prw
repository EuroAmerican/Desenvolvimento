#Include 'Protheus.Ch'

User Function FA60CAN1()

Local lRetorno := .T.

Public cEURONumBc := ""

If !Empty( SE1->E1_NUMBCO )
	cEURONumBc := SE1->E1_NUMBCO
Else
	cEURONumBc := ""
EndIf

Return lRetorno

User Function FA60CAN2()

Local lRetorno := .T.

If Type("cEURONumBc") == "C"
    If !Empty( cEURONumBc )
        RecLock("SE1", .F.)
            SE1->E1_NUMBCO := cEURONumBc
        MsUnLock()
    EndIf
EndIf

Return lRetorno
