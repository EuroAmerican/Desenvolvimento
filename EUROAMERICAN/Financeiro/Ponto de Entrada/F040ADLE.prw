#include "protheus.ch"

User Function F040ADLE

Local aRet := {}

If IsInCallStack("FINA460") 
    Return aRet 
EndIf

If FunName() $ "FINA040,FINA740,MATA450"
     aAdd(aRet,{"BR_LARANJA","Pagamento Cartório"})
EndIf

Return aRet

User Function F040URET

Local aRet := {}

If IsInCallStack("FINA460") 
    Return aRet 
EndIf

If FunName() $ "FINA040,FINA740,MATA450"
     aAdd(aRet,{" E1_PAGCART == 'S' .AND. E1_SALDO <> 0 ","BR_LARANJA"})
EndIf

Return aRet
