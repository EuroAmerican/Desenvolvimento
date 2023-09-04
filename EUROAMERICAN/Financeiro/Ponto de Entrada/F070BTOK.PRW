#include "rwmake.ch"   
#include "topconn.ch"
#include "tbiconn.ch"
#include "protheus.ch"

User Function F070BTOK()
    Local cArea := FwGetArea()
    Local lRet  := .T.
    //--[ Baixa de Perda]
    Local cPref := Alltrim(SE1->E1_PREFIXO)

    if cPref <> 'PRD'
      if CMOTBX = 'PERDA'
        if ExistBlock("F070MSZB")
            aParam2:= {SE1->E1_FILIAL,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_VENCREA,SE1->E1_VALOR,SE1->E1_VEND1}
            ExecBlock("F070MSZB",.f.,.f.,aParam2)
        endif 
      ENDIF
    ELSE
      if CMOTBX <> 'PERDA'
        if ExistBlock("F070ATUA")
            aParam2:= {SE1->E1_FILIAL,SE1->E1_CLIENTE,SE1->E1_LOJA}
            ExecBlock("F070ATUA",.f.,.f.,aParam2)
        endif 
      ENDIF               
    Endif
    //--[ Baixa da Perda]

    FWRestArea(cArea)
Return(lRet)

User Function F070MSZB()
    Local cArea     := FwGetArea()
    Local cwFilial  := PARAMIXB[1]
    Local cCliente  := PARAMIXB[2]
    Local cLoja     := PARAMIXB[3]
    Local cPref     := PARAMIXB[4]
    Local cNum      := PARAMIXB[5]
    Local cParc     := PARAMIXB[6]
    Local dVenc     := PARAMIXB[7]
    Local nValor    := PARAMIXB[8]
    Local cVend     := PARAMIXB[9]                                                                                            
    dbSelectArea("SE1")
    SE1->( dbSetOrder(1))
    if SE1->( !dbSeek(cwFilial+cCliente+cLoja+cPref+cNum+cParc,.T.))
        IF Reclock("SZB",.T.)
            SZB->ZB_FILIAL        :=      cwFilial
            SZB->ZB_CLIENTE       :=      cCliente
            SZB->ZB_LOJA          :=      cLoja
            SZB->ZB_NOME          :=      Posicione("SA1",1,cwFilial+cCliente+cLoja,"A1_NOME")
            SZB->ZB_PREFIXO       :=      cPref
            SZB->ZB_NUM           :=      cNum
            SZB->ZB_PARCELA       :=      cParc
            SZB->ZB_VENCTO        :=      dVenc
            SZB->ZB_VALOR         :=      nValor
            SZB->ZB_VEND          :=      cVend
            SZB->ZB_STATUS        :=      "1"
            SZB->ZB_KEYUSR        :=      UsrFullName(__cUserId)
            SZB->ZB_DTGRV         :=      dDataBase
            SZB->ZB_HORA          :=      Time()
            SZB->ZB_SITUACA       :=      "Titulo Perda"
            MsUnlock()
        Endif
    Endif
     dbSelectArea("SA1")
    SA1->( dbSetOrder(1))
    IF SA1->( dbSeek(cwFilial+cCliente+cLoja,.T. ))
        IF Reclock("SA1",.F.)
                SA1->A1_PERDA := "N"
           MsUnlock()
        ENDIF
    ENDIF    
    FWRestArea(cArea)
Return

User Function F070ATUA()
    Local cArea     := FwGetArea()
    Local cwFilial  := PARAMIXB[1]
    Local cCliente  := PARAMIXB[2]
    Local cLoja     := PARAMIXB[3]

    dbSelectArea("SZB")
    SZB->( dbSetOrder(1))
    SZB->( dbseek(cwFilial+cCliente+cLoja,.t.))
    While !SZB->( EOF() ) .and. SZB->(ZB_FILIAL+ZB_CLIENTE+ZB_LOJA) = cwFilial+cCliente+cLoja
            if Reclock("SZB",.F.)
                SZB->ZB_STATUS  := "3"
                SZB->ZB_KEYUSR  := UsrFullName(__cUserId)
                SZB->ZB_DTGRV   := dDataBase
                SZB->ZB_HORA    := Time()
                SZB->ZB_SITUACA := "Liquidado"                
            Endif
        SZB->( dbSkip() )
    End  
     dbSelectArea("SA1")
    SA1->( dbSetOrder(1))
    IF SA1->( dbSeek(cwFilial+cCliente+cLoja,.T. ))
        IF Reclock("SA1",.F.)
                SA1->A1_PERDA := "L"
           MsUnlock()
        ENDIF
    ENDIF
    FWRestArea(cArea)    
Return
