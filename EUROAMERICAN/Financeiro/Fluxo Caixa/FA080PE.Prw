
#Include "Protheus.ch"

/*/{Protheus.doc} FA080PE
/@type function Ponto de Entrada Alteração da Natureza Financeira após a gravação no SE5 (Tipo = PA) 
@version 1.00
@author Paulo Rogério  
@since 28/07/2022
@return 
@History  
/*/

User Function FA080PE()
Local cNatNew  := SuperGetMV("QS_NATFLXP",,"0101005") 
Local cLstFor  := SuperGetMV("QS_FORNFLX",,"13387026000186/07122447000344/01245930000500/27329492809") // SuperGetMV("QS_FORNFLX",,"01644203;01486501;01524601")
Local aAreaSA2 := GetArea("SA2")

IF Alltrim(SE5->E5_TIPO) == "PA" .And. Alltrim(SE5->E5_TIPODOC) == "VL" 
    //------------------------------------------------------------------------------------------
    // Se o fornecedor estiver relacionado no parametro, altera a natureza finacneira da baixa.
    //------------------------------------------------------------------------------------------

    dbSelectArea("SA2")
    dbSetOrder(1) // A2_FILIAL, A2_COD, A2_LOJA
    dbSeek(xFilial("SA2")+SE5->(E5_CLIFOR + E5_LOJA))

    dbSelectArea("SE5")
    IF AllTrim(SA2->A2_CGC) $ cLstFor
        RecLock("SE5", .F.)
        SE5->E5_NATUREZ := cNatNew
        MsUnlock()
    Endif

    RestArea(aAreaSA2)
Endif

Return
