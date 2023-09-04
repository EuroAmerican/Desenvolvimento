#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

User Function FATGAT01(cCliente,cLoja)
    Local cArea := FWGetArea()
    Local lRet  := .T.
    Local cBoby := ' '
  
    dbSelectArea("SA1")
    SA1->( dbSetOrder(1))
    IF SA1->( dbSeek(xFilial("SA1")+cCliente+cLoja,.T.))

        IF SA1->A1_PERDA = 'P'
            cBoby :='<center><h1><font color="#ff0000">Atenção!</font></h1></center><br> '
            cBoby +='Esse cliente está com pendencias de titulos que não foram pagos a mais de <b>180 dias</b>.<br>'
            cBoby +='Por favor, entre em contato com o  <b>setor financeiro</b>.<br>'
            cBoby +='Obrigado.<br>'
            cBoby +='<i>Departamento Financeiro </i>'
            lRet := .F.
            FWAlertWarning(cBoby, "NEGADO O PEDIDO")
        ENDIF
    Endif    

    FWRestArea(cArea)    
Return(lRet)

User Function FATVLD01()
    Local cArea    := FwGetArea()
    Local cFilSA1  := PARAMIXB[1]
    Local cCliente := PARAMIXB[2]
    Local cLoja    := PARAMIXB[3]
    Local lRet  := .T.
    Local cBoby := ' '
    dbSelectArea("SA1")
    SA1->( dbSetOrder(1))
    IF SA1->( dbSeek(cFilSA1+cCliente+cLoja,.T.))
     IF SA1->A1_PERDA = 'P'
        cBoby :='<center><h1><font color="#ff0000">Atenção!</font></h1></center><br> '
        cBoby +='Esse cliente está com pendencias de titulos que não foram pagos a mais de <b>180 dias</b>.<br>'
        cBoby +='Por favor, entre em contato com o  <b>setor financeiro</b>.<br>'
        cBoby +='Obrigado.<br>'
        cBoby +='<i>Departamento Financeiro </i>'
        lRet := .F.
        FWAlertWarning(cBoby, "Nao será gravado esse pedido")
     ENDIF
    ENDIF 
    FwRestArea(cArea)
Return(lRet)


