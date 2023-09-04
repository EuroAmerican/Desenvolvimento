#Include "Protheus.ch"

/*/{Protheus.doc} FA070ADTSE5
/@type function Ponto de Entrada Alteração da Natureza Financeira após a gravação no SE5 (Tipo = RA) 
@version 1.00
@author Paulo Rogério  
@since 28/07/2022
@return 
@History  
/*/


User Function FA070ADTSE5()
Local cNatNew  := SuperGetMV("QS_NATFLXR",,"0401017")
Local cLstFor  := SuperGetMV("QS_FORNFLX",,"13387026000186/07122447000344/01245930000500/27329492809") // SuperGetMV("QS_FORNFLX",,"01644203;01486501;01524601")
Local aAreaSA1 := GetArea("SA1")

IF Alltrim(SE5->E5_TIPO) == "RA" .And. Alltrim(SE5->E5_TIPODOC) == "VL" 
    //------------------------------------------------------------------------------------------
    // Se o cliente estiver relacionado no parametro, altera a natureza finacneira da baixa.
    //------------------------------------------------------------------------------------------
    dbSelectArea("SA1")
    dbSetOrder(1) // A1_FILIAL, A1_COD, A1_LOJA
    dbSeek(xFilial("SA1")+SE5->(E5_CLIFOR + E5_LOJA))

    dbSelectArea("SE5")
    IF AllTrim(SA1->A1_CGC) $ cLstFor
        RecLock("SE5", .F.)
        SE5->E5_NATUREZ := cNatNew
        MsUnlock()
    Endif

    RestArea(aAreaSA1)    
Endif

Return


