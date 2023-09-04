
#Include "Protheus.ch"

/*/{Protheus.doc} F380GRV
/@type function Ponto de Entrada para Flegar totilos JR/MT/Etc como conciliados 
@version 1.00
@author Paulo Rogério  
@since 29/08/2022
@return 
@History  
/*/

User Function F380GRV()
Local aTipos   := {"CM","DC","D2","JR","J2","MT","M2","VM"}
Local cChave   := ""
Local nX       := 0
Local aArea    := GetArea()
Local aAreaSE5 := SE5->(GetArea())
Local nRecno   := SE5->(Recno())


IF !Empty(SE5->E5_RECONC) 
    dbSelectArea("SE5")
    dbSetOrder(2) // E5_FILIAL, E5_TIPODOC, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_DATA, E5_CLIFOR, E5_LOJA, E5_SEQ, R_E_C_N_O_, D_E_L_E_T_

    For nX := 1 to Len(aTipos)
        cChave := SE5->E5_FILIAL + aTipos[nX] + SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO) + dtos(SE5->E5_DATA) + SE5->(E5_CLIFOR + E5_LOJA)

        dbSeek(cChave)

        IF Found()
            RecLock("SE5", .F.)
            SE5->E5_RECONC := "x"
            MsUnlock()
        Endif

        dbGoto(nRecno)
    Next

    RestArea(aAreaSE5)
    RestArea(aArea)    
Endif

Return
