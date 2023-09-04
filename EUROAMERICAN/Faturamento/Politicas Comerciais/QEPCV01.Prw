#include "rwmake.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#define ENTER CHR(13) + CHR(10)

/*
| Função...: QEPCV01()
| Autor....: Paulo Rogerio
| Data.....: 23/06/2023
| Retorno..: Nenhum
| Descricão: Rotina para Validação dos Descontos MIX, Carga Fechada e Logistico
|            na rotina MATA415.
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User Function QEPCV01(cTipo)
Local nDescto := &(Readvar())
Local nVlrMax := IIF(cTipo == "M", U_DefPerMix(), IIF(cTipo == "C", GETMV("QE_PERCCF"), GETMV("QE_PERCLOG")))
Local lRet := .T.

IF nDescto > nVlrMax
    MsgAlert("Percentual máximo permitido é " + lTrim(Transform(nVlrMax, "@E 999.99")) ,"Politicas Comerciais")
    lRet := .F.
Endif

Return(lRet)


/*
| Função...: DefPerMix()
| Autor....: Paulo Rogerio
| Data.....: 23/06/2023
| Retorno..: Nenhum
| Descricão: Função para Calculo e Definição do Desconto Mix
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User Function  DefPerMix()
Local aArea     := GetArea()
Local aAreaSA1  := SA1->(GetArea())
Local aAreaACY  := ACY->(GetArea())

Local nPerMix  := GETMV("QE_PERCMIX")
Local lCalDesc := .F.
Local nPriorid := 0
Local cQuery   := ""
Local dEmissao := IIF(Valtype(M->CJ_EMISSAO) <> "N", SCJ->CJ_EMISSAO, M->CJ_EMISSAO) 
Local cCliente := IIF(Valtype(M->CJ_CLIENT)  <> "N", SCJ->CJ_CLIENT , M->CJ_CLIENT) 
Local cLoja    := IIF(Valtype(M->CJ_LOJAENT) <> "N", SCJ->CJ_LOJAENT, M->CJ_LOJAENT) 


dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+cCliente+cLoja)

IF Empty(SA1->A1_GRPVEN)
    lCalDesc := SA1->A1_ZDSCMIX == "S"

Else
    dbSelectArea("ACY")
    dbSetOrder(1)
    lCalDesc := ACY_ZDSCMI == "S"

Endif

IF lCalDesc
    For nPriorid := 1 to 3
        cQuery   := "SELECT ACO_XMIX "+ENTER
        cQuery   += " FROM "+RetSqlName("ACO")+" AS ACO "+ENTER
        cQuery   += "WHERE D_E_L_E_T_ = '' "+ENTER
        cQuery   += "  AND ACO_FILIAL = '"+xFilial("ACO")+"'"+ENTER
        cQuery   += "  AND ACO_XMIX <> 0 "+ENTER
        cQuery   += "  AND ((ACO_DATDE = '' AND ACO_DATATE = '') OR (ACO_DATATE = '') OR (ACO_DATDE <= '"+dtos(dEmissao)+"' AND ACO_DATATE >= '"+dtos(dEmissao)+"'))"+ENTER
        cQuery   += "  AND ACO_MSBLQL <> '1'"+ENTER

        IF nPriorid     == 1 // Prioriza regra especifica para o cliente
            cQuery += "  AND ACO_CODCLI = '"+SA1->A1_COD+"'"+ENTER
            cQuery += "  AND ACO_LOJA   = '"+SA1->A1_LOJA+"'"+ENTER

        ElseIf nPriorid == 2 // Prioriza regra especifica para a holding
            cQuery += "  AND ACO_GRPVEN = '"+ACY->ACY_GRPVEN+"'"+ENTER 
        ElseIf nPriorid == 3 // Prioriza regra especifica generica (todos os cliente e holdings)
            cQuery += "  AND ACO_GRPVEN = ' '  AND ACO_CODCLI  = ' ' "+ENTER
        Endif


        //----------------------------------------------------
        // Busca o desconto pelo cadastro de Exceções
        //----------------------------------------------------
        IF Select("TMPX")
            TMPX->(dbCloseArea())
        Endif

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMPX", .F., .T.)
        dbSelectArea("TMPX")

        Do While !EOF()
            IF ACO_XMIX > 0
                nPerMix := ACO_XMIX
                Exit
            ENDIF

            dbSkip()
        Enddo
    Next
Else
    nPerMix := 0
Endif

RestArea(aArea)
RestArea(aAreaSA1)
RestArea(aAreaACY)
Return(nPerMix)


/*
| Função...: DefPerScor()
| Autor....: Paulo Rogerio
| Data.....: 14/06/2023
| Retorno..: Nenhum
| Descricão: Função para Calculo e Definição do Desconto Score
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User Function  DefPerScor(cPeriodo)
Local nScore   := 0
Local nPerScor := 0
Local lCalDesc := .F.
Local cQuery   := ""
Local nPriorid := 0
Local lExcecao := .F.

dbSelectArea("SA1")
dbSetOrder(1)

IF Empty(SA1->A1_GRPVEN)
    lCalDesc := SA1->A1_ZDSCSCO == "S"
    nScore   := SA1->A1_ZSCORE
Else
    dbSelectArea("ACY")
    dbSetOrder(1)
    dbSeek(xFilial("ACY")+SA1->A1_GRPVEN)
    lCalDesc := ACY_ZDSCSC == "S"
    nScore   := ACY_ZSCORE
Endif

IF lCalDesc
    For nPriorid := 1 to 3
        cQuery   := "SELECT ACO_XSCORE "+ENTER
        cQuery   += " FROM "+RetSqlName("ACO")+" AS ACO "+ENTER
        cQuery   += "WHERE D_E_L_E_T_ = '' "+ENTER
        cQuery   += "  AND ACO_FILIAL = '"+xFilial("ACO")+"'"+ENTER
        cQuery   += "  AND ACO_XSCORE <> 0 "+ENTER
        cQuery   += "  AND ((ACO_DATDE = '' AND ACO_DATATE = '') OR (ACO_DATATE = '') OR (ACO_DATDE <= '"+dtos(dEmissao)+"' AND ACO_DATATE >= '"+dtos(dEmissao)+"'))"+ENTER
        cQuery   += "  AND ACO_MSBLQL <> '1'"+ENTER

        IF nPriorid     == 1 // Prioriza regra especifica para o cliente
            cQuery += "  AND ACO_CODCLI = '"+SA1->A1_COD+"'"+ENTER
            cQuery += "  AND ACO_LOJA   = '"+SA1->A1_LOJA+"'"+ENTER

        ElseIf nPriorid == 2 // Prioriza regra especifica para a holding
            cQuery += "  AND ACO_GRPVEN = '"+ACY->ACY_GRPVEN+"'"+ENTER 
        ElseIf nPriorid == 3 // Prioriza regra especifica generica (todos os cliente e holdings)
            cQuery += "  AND ACO_GRPVEN = ' '  AND ACO_CODCLI  = ' ' "+ENTER
        Endif

        //----------------------------------------------------
        // Busca o desconto pelo cadastro de Exceções
        //----------------------------------------------------
        IF Select("TMPX")
            TMPX->(dbCloseArea())
        Endif

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMPX", .F., .T.)
        dbSelectArea("TMPX")
        dbGotop()

        IF Eof()
            TMPX->(dbCloseArea())
            Loop
        Endif

        Do While !EOF()
            IF ACO_XSCORE > 0
                //nScore := ACO_XSCORE
                nPerScor := ACO_XSCORE
                lExcecao := .T.
                Exit
            ENDIF

            dbSkip()
        Enddo

        // Encerra a verificação após encontrar uma regra válida.
        Exit
    Next

    //----------------------------------------------------
    // Busca o desconto relacionado a pontuação do Score
    //----------------------------------------------------
    IF !lExcecao 
        dbSelectArea("ZZ4")
        dbSetOrder(1)

        dbSeek(xFilial("ZZ4")+cPeriodo)
        Do While !Eof() .And. ZZ4->(ZZ4_FILIAL + ZZ4_PERIOD) == xFilial("ZZ4")+cPeriodo
            IF ZZ4->ZZ4_STATUS <> "A"
                dbSkip()
                loop 
            Endif

            IF nScore >= ZZ4->ZZ4_RANGE1 .And. nScore <= ZZ4->ZZ4_RANGE2
                nPerScor := ZZ4->ZZ4_DESCON
                Exit
            Endif

            dbSkip()
        Enddo
    Endif
    
Else
    //nScore := 0
    nPerScor := 0 
Endif

Return(nPerScor)


/*
| Função...: DefPerFina()
| Autor....: Paulo Rogerio
| Data.....: 14/06/2023
| Retorno..: Nenhum
| Descricão: Função para Calculo e Definição do Desconto Financeiro
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User Function  DefPerFina(cPeriodo)
Local nPerFina := 0
Local lCalDesc := .F.
Local cQuery   := ""
Local nPriorid := 0
Local cCliente := ""
Local cLoja := ""


dbSelectArea("SE4")
dbSetOrder(1)
IF lEnchoi
    dbSeek(xFilial("SE4")+M->CJ_CONDPAG)
    cCliente := M->CJ_CLIENT
    cLoja    := M->CJ_LOJAENT     
Else
    dbSeek(xFilial("SE4")+SCJ->CJ_CONDPAG)
    cCliente := SCJ->CJ_CLIENT
    cLoja    := SCJ->CJ_LOJAENT     
Endif

IF !Found()
    nPerFina := 0
    Return(nPerFina)
Else
    nPerFina  := SE4->E4_XDESFIN
Endif

dbSelectArea("SA1")
dbSetOrder(1)

IF Empty(SA1->A1_GRPVEN)
    lCalDesc := SA1->A1_ZDSCFIN == "S"

Else
    dbSelectArea("ACY")
    dbSetOrder(1)
    dbSeek(xFilial("ACY")+SA1->A1_GRPVEN)
    lCalDesc := ACY_ZDSCFI == "S"
Endif

IF lCalDesc
    For nPriorid := 1 to 3
        cQuery   := "SELECT ACO_XDSCFI "+ENTER
        cQuery   += " FROM "+RetSqlName("ACO")+" AS ACO "+ENTER
        cQuery   += "WHERE D_E_L_E_T_ = '' "+ENTER
        cQuery   += "  AND ACO_FILIAL = '"+xFilial("ACO")+"'"+ENTER
        cQuery   += "  AND ACO_CONDPG  = '"+cCondPag+"'"+ENTER
        cQuery   += "  AND ((ACO_DATDE = '' AND ACO_DATATE = '') OR (ACO_DATATE = '') OR (ACO_DATDE <= '"+dtos(dEmissao)+"' AND ACO_DATATE >= '"+dtos(dEmissao)+"'))"+ENTER
        cQuery   += "  AND ACO_MSBLQL <> '1'"+ENTER

        IF nPriorid     == 1 // Prioriza regra especifica para o cliente
            cQuery += "  AND ACO_CODCLI = '"+cCliente+"'"+ENTER
            cQuery += "  AND ACO_LOJA   = '"+cLoja+"'"+ENTER

        ElseIf nPriorid == 2 // Prioriza regra especifica para a holding
            cQuery += "  AND ACO_GRPVEN = '"+ACY->ACY_GRPVEN+"'"+ENTER 
        ElseIf nPriorid == 3 // Prioriza regra especifica generica (todos os cliente e holdings)
            cQuery += "  AND ACO_GRPVEN = ' '  AND ACO_CODCLI  = ' ' "+ENTER
        Endif


        //----------------------------------------------------
        // Busca o desconto pelo cadastro de Exceções
        //----------------------------------------------------
        IF Select("TMPX")
            TMPX->(dbCloseArea())
        Endif

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMPX", .F., .T.)
        dbSelectArea("TMPX")
        dbGoTop()

        IF Eof()
            dbCloseArea()
            Loop
        Endif

        Do While !EOF()
            IF ACO_XDSCFI > 0
                nPerFina := ACO_XDSCFI
                Exit
            Endif

            dbSkip()
        Enddo

        // Encerra a verificação após encontrar uma regra válida.
        Exit
    Next
Else
    nPerFina := 0
Endif

Return(nPerFina)


/*
| Função...: DefPerLogi()
| Autor....: Paulo Rogerio
| Data.....: 14/06/2023
| Retorno..: Nenhum
| Descricão: Função para Calculo e Definição do Desconto Logistico
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User  Function  DefPerLogi(cPeriodo)
Local lCalDesc   := .F.
Local nDiaOrca   := iif(lEnchoi, Day(M->CJ_EMISSAO), Day(SCJ->CJ_EMISSAO))
Local nPerLogi   := 0
Local nDiaLimite := SuperGetMV("QE_DTDESLG",.T.,14)


dbSelectArea("SA1")
dbSetOrder(1)

IF Empty(SA1->A1_GRPVEN)
    lCalDesc := SA1->A1_ZDSCLOG == "S"
Else
    dbSelectArea("ACY")
    dbSetOrder(1)
    dbSeek(xFilial("ACY")+SA1->A1_GRPVEN)

    lCalDesc := ACY_ZDSCFI == "S"
Endif

IF lCalDesc
    //----------------------------------------------------
    // Busca o desconto pelo cadastro de Exceções
    //----------------------------------------------------

    IF nDiaOrca <= nDiaLimite
        nPerLogi   := SuperGetMV("QE_PERCLOG",.T.,2)    
    Endif
Else
    nPerLogi := 0
Endif

Return(nPerLogi)


/*
| Função...: AtivaDsc()
| Autor....: Paulo Rogerio
| Data.....: 30/08/2023
| Retorno..: Nenhum
| Descricão: Função para Ativação / Desativação de campos de Descontos
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User  Function  AtivaDsc(cCliente, cLoja, cTipo)
Local lRet   := .F.
Local aArea  := GetArea()

dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+cCliente+cLoja)

IF Empty(SA1->A1_GRPVEN)
    IF cTipo == "M"     // MIX
        lRet := SA1->A1_ZDSCMIX == "S"
    ElseIf cTipo == "C" // Carga Fechada
        lRet := SA1->A1_ZDSCCF == "S"
    ElseIf cTipo == "L" // Logisitico 
        lRet := SA1->A1_ZDSCLOG == "S"
    Endif
Else
    dbSelectArea("ACY")
    dbSetOrder(1)
    dbSeek(xFilial("ACY")+SA1->A1_GRPVEN)

    IF cTipo == "M"     // MIX
        lRet := ACY->ACY_ZDSCMI == "S"
    ElseIf cTipo == "C" // Carga Fechada
        lRet := ACY->ACY_ZDSCCF == "S"
    ElseIf cTipo == "L" // Logisitico 
        lRet := ACY->ACY_ZDSCLG == "S"
    Endif
Endif

RestArea(aArea)

Return(lRet)
