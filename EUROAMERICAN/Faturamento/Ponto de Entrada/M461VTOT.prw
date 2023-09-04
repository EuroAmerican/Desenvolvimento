User Function M461VTot()
 
Local aArea     := GetArea()
Local nValTot   := PARAMIXB[1] // Valor total da nota
Local nRecnoE4  := PARAMIXB[2] // RECNO da condição de pagamento
Local lRet      := .T.
 
If nValTot < 300 .And. nRecnoE4 > 0
    dbSelectArea("SE4") 
    SE4->(dbGoTo(nRecnoE4))  
    
    aParcelas := Condicao(nValTot, SE4->E4_CODIGO, 0, dDataBase)
    nVlrParc  := nValTot / Len(aParcelas)
    
    If nVlrParc < 300 .And. Len(aParcelas) > 1 
        MsgStop("O valor mínimo de parcela é R$ 300,00. Altere a Condição de Pagamento!")       
        lRet := .F.     
    EndIf
EndIf   
 
RestArea(aArea)
 
Return lRet