#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'Rwmake.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

User Function FINAM010()
    Processa({|| FM010SZB()}, "Gerando Controle de Perda")
    Processa({|| FM010CLI()}, "Atualizando cadastro de Cliente")
RETURN


Static Function FM010SZB()
    Local cArea := fwgetarea()
    Local cAlias:= GetNextAlias()
    Local cQuery:= ' '

    cQuery := "Select		E5_FILORIG, "
	cQuery += "			    E5_CLIFOR, "
	cQuery += "			    E5_LOJA, "
	cQuery += "			    E5_PREFIXO, "
	cQuery += "			    E5_NUMERO, "
	cQuery += "			    E5_PARCELA, "
	cQuery += "			    E5_VENCTO, "
	cQuery += "			    SUM(E5_VALOR)		VALOR, "
	cQuery += "			    SUM(E5_VLDESCO)   DESCONTO "
    cQuery += "From " + RetSqlName("SE5") +"  SE5  "
    cQuery += "Where D_E_L_E_T_ = ' '  "
    cQuery += "And RTRIM(E5_MOTBX) = 'PRD' "
    cQuery += "AND DATEDIFF(DAY,E5_VENCTO,GETDATE()) >= 180 "
    cQuery += "GROUP BY E5_FILORIG, "
    cQuery += "				E5_CLIFOR, "
    cQuery += "				E5_LOJA, "
    cQuery += "				E5_PREFIXO, "
    cQuery += "				E5_NUMERO, "
    cQuery += "				E5_PARCELA, "
    cQuery += "				E5_VENCTO "
    cQuery += "ORDER BY E5_FILORIG, "
    cQuery += "				E5_CLIFOR, "
    cQuery += "				E5_LOJA, "
    cQuery += "				E5_PREFIXO, "
    cQuery += "				E5_NUMERO, "
    cQuery += "				E5_PARCELA, "
    cQuery += "				E5_VENCTO "

    FwQueryCache():TurnOnCache("120", "60")
    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
    FwQueryCache():TurnOffCache()
    ProcRegua( (cAlias)->( RecCount() ) )

    while !(cAlias)->(Eof())
           IncProc("Processando... ") 
           dbSelectArea("SZB")
           ("SZB")->( dbSetOrder(1) )
           IF !dbSeek((cAlias)->E5_FILORIG+(cAlias)->E5_CLIFOR+(cAlias)->E5_LOJA+(cAlias)->E5_PREFIXO+(cAlias)->E5_NUMERO+(cAlias)->E5_PARCELA+(cAlias)->E5_VENCTO,.T.) 
                      IF RecLock("SZB",.T.)
                          SZB->ZB_FILIAL        :=      (cAlias)->E5_FILORIG
                          SZB->ZB_CLIENTE       :=      (cAlias)->E5_CLIFOR
                          SZB->ZB_LOJA          :=      (cAlias)->E5_LOJA
                          SZB->ZB_NOME          :=      Posicione("SA1",1,(cAlias)->E5_FILORIG+(cAlias)->E5_CLIFOR+(cAlias)->E5_LOJA,"A1_NOME")
                          SZB->ZB_PREFIXO       :=      (cAlias)->E5_PREFIXO
                          SZB->ZB_NUM           :=      (cAlias)->E5_NUMERO
                          SZB->ZB_PARCELA       :=      (cAlias)->E5_PARCELA
                          SZB->ZB_VENCTO        :=      stod((cAlias)->E5_VENCTO)
                          SZB->ZB_VALOR         :=      (cAlias)->VALOR
                          SZB->ZB_VEND          :=      Posicione("SA1",1,(cAlias)->E5_FILORIG+(cAlias)->E5_CLIFOR+(cAlias)->E5_LOJA,"A1_VEND")
                          SZB->ZB_STATUS        :=      IIF(Empty(SZB->ZB_STATUS),"1",SZB->ZB_STATUS)
                          SZB->ZB_KEYUSR        :=      UsrFullName(__cUserId)
                          SZB->ZB_DTGRV         :=      dDataBase
                          SZB->ZB_HORA          :=      Time()
                          SZB->ZB_SITUACA       :=      "Titulo Perda"
                         MsUnlock()
                      ENDIF
           ENDIF

          (cAlias)->(DBSkip())
    enddo
 
    (cAlias)->(DBCloseArea())

    FwRestArea(cArea)
RETURN


Static Function FM010CLI()
    Local cArea := fwgetarea()
    Local cAlias:= GetNextAlias()
    Local cQuery:= ' '

    cQuery := "select	ZB_FILIAL, "
    cQuery += "			ZB_CLIENTE, "
	cQuery += "			ZB_LOJA, "
	cQuery += "			COUNT(*) QTDE "
    cQuery += "from  " + RetSqlName("SZB") +"  SZB  "
    cQuery += "where D_E_L_E_T_ = ' ' "
    cQuery += "GROUP BY ZB_FILIAL, "
    cQuery += "			    ZB_CLIENTE, "
    cQuery += "				ZB_LOJA "
    cQuery += "ORDER BY ZB_FILIAL, "
    cQuery += "			    ZB_CLIENTE, "
    cQuery += "				ZB_LOJA "

    FwQueryCache():TurnOnCache("120", "60")
    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
    FwQueryCache():TurnOffCache()
    ProcRegua( (cAlias)->( RecCount() ) )

    while !(cAlias)->(Eof())
           IncProc("Processando... ") 
           dbSelectArea("SA1")
           ("SA1")->( dbSetOrder(1) )
           IF dbSeek((cAlias)->ZB_FILIAL+(cAlias)->ZB_CLIENTE+(cAlias)->ZB_LOJA,.T.) 
                IF SA1->A1_MSBLQL = '2'
                      IF RecLock("SA1",.F.)
                         SA1->A1_PERDA         := "P"
                         MsUnlock()
                      ENDIF
                ENDIF      
           ENDIF

          (cAlias)->(DBSkip())
    enddo
    (cAlias)->(DBCloseArea())
    FwRestArea(cArea)
Return

