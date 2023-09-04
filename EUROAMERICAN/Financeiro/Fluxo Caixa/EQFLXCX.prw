#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} EQFLXCX
Fluxo de Caixa onforme padrao Euro American
@type function Relatorio
@version  1.00
@author mario.antonaccio
@since 25/01/2022
@return character, sem retorno

Obs
Fuxo Real  - a partir linha 514
Fuxo Previsto  - a partir linha 189
Fuxo Comprativo  - a partir linha 1245
Fuxo Diario   - a partir linha 864
Fuxo excel   - a partir linha 1677
/*/
User Function EQFLXCX()
    Local aButtons := {}
    Local aSays    := {}
    Local cTitoDlg := "Fluxo de Caixa EuroAmerican por Natureza"
    Local nOpca    := 0

    Private cCampo
    Private cCampoT
    Private cCampoT1
    Private cCampoT2
    Private cPerg     := "EQFLXCX2"
    Private cNatureza :=""
    Private cFilConta := ""
    Private cFilFilial:= ""


    // Perguntas
    //01  - Data Inicial - D - 8
    //02  - Data Final - D - 8
    //03  - Natureza de ? - C - 10 - SED
    //04  - Natureza ate ? - C - 10 - SED
    //05  - Tipo FLuxo - N -1  (Previsto/Realizado/Comparativo/Diario)
    //06  - Analitico ou Sintetico?  - N - 1  (Analitico/Sintetico)  - NOTA : Nessa opção so serao mostrados os grupos  nao os itens
    //07 -  Empresas: - C - 10   - Informa quais empresas separadas por ; (ponto e virgula)
    //08 -  Imprime Consolidado - N - 1  (Sim/Nao) -  Informa se imprime a planilha consolidadora por empresa
    //09 -  Imprime DFC - N - 1  (Sim/Nao) -  Informa se imprime a NATUREZAS DFC NO FLUXO
    //10 - Considera So Conciliados (REA)?- N - 1  (Sim/Nao) -  Informa se imprime somente conciliadaos

    aAdd(aSays, "Está rotina tem o objetivo gerar o fluxo de caixa, aglutinado por natureza")
    aAdd(aSays, "para ter uuma visão dos gastos gerados.")
    aAdd(aSays, "Pode ser retirado por PREVISTO,REALIZADO,COMPARATIVO e DIARIO.")

    aAdd(aButtons,{5, .T., {|o| Pergunte(cPerg, .T.)}})
    aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
    aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

    FormBatch(cTitoDlg, aSays, aButtons)
    If nOpca == 1
        Pergunte(cPerg, .F.)
        Processa( {|| EQFLXCX01() }, "Extração de Dados", "Gerando Registros...", .F.)
    EndIf

Return

/*/{Protheus.doc} EQFLXCX01
Extração de Dados do fluxo por natureza
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 25/01/2022
@return character, dados extraidos
/*/
Static Function EQFLXCX01()
    Local nI
    Local lErro    := .F.

    Private _FSE     := GetNextAlias() //Arquivo filtrado do SE5,SE1,SE2 - conforme tipo fluxo
    Private _SE8     := GetNextAlias() //Arquivo  temporario  SAldos Bancarios
    Private _SLD     := GetNextAlias() //Arquivo  temporario Saldo
    Private _TFLX    := GetNextAlias() //Arquivo  temporario de Fluxo (Excel)
    Private _TMP     := GetNextAlias() //Arquivo  temporario (Auxiliar)
    Private aDatas   := {}
    Private aFields  := {}
    Private aFieldsN := {}
    Private aFilial  := {}
    Private aSomaCol := {}
    Private cArqReal
    Private cExprEmp := "% "+FormatIn(AllTrim(mv_par07),";")+" %" //Separa Filiais
    Private cGrupo   := ""
    Private cItem    := ""
    Private cNGrupo  := " "
    Private cNItem   := " "
    Private cNSubGr  := " "
    Private cSubGr   := ""
    Private lAnalitico
    Private lConsolida
    Private lDFC
    Private nDifMes
    Private nInicio  := 0
    Private nSomaCol := 0
    Private nTotReg  := 0
    Private oExcel   := FWMsExcelEX():New()
    Private oObj     := FWSX1Util()  :New()

    // Posição 1,Posicao 2,Posicao 3
    //06  - Analitico ou Sintetico?  - N - 1  (Analitico/Sintetico)  - NOTA : Nessa opção so serao mostrados os grupos  nao os itens
    //08 -  Imprime Consolidado - N - 1  (Sim/Nao) -  Informa se imprime a planilha consolidadora por empresa
    //09 -  Imprime DFC - N - 1  (Sim/Nao) -  Informa se imprime as Naturezas DFC
    lAnalitico:= If(mv_par06==1,.T.,.F.)
    lConsolida:= If(mv_par08==1,.T.,.F.)
    lDFC:=If(mv_par09==1,.T.,.F.)

    MakeDir("C:\TOTVS")

    nDifMes  := If(mv_par05==4,DateDiffDay(mv_par01,mv_par02),DateDiffMonth(mv_par01,mv_par02) )

    //Filiais Utilizadas
    aFilial:=StrTokArr( mv_par07,";" )
    For nI:=1 to Len(aFilial)
        aFilial[nI]:=AllTrim(aFilial[nI])
    Next

    If mv_par08 == 1 // se Gera Consolidado
        AADD(aFilial,Space(02))
    End

    //Criaçao do arquivo - Campos BAsicos
    aadd(aFields, {"FLAG"  , 'C', 03, 0})
    aadd(aFieldsN, "Flag")

    If lAnalitico
        aadd(aFields, {"FILIAL", 'C', 02, 0})
        aadd(aFields, {"NATGR" , 'C', 02, 0})
        aadd(aFields, {"NOMEGR", 'C', 30, 0})
        aadd(aFields, {"NATSG ", 'C', 02, 0})
        aadd(aFields, {"NOMESG", 'C', 30, 0})
        aadd(aFields, {"NATIT ", 'C', 03, 0})
        aadd(aFields, {"NOMEIT", 'C', 30, 0})
        nInicio:=9
        // Array como snomes dos campos
        aadd(aFieldsN, "Filial")
        aadd(aFieldsN, "Grupo Natureza")
        aadd(aFieldsN, "Nome Grupo")
        aadd(aFieldsN, "Sub-Grupo Nat.")
        aadd(aFieldsN, "Nome Sub-Grupo")
        aadd(aFieldsN, "Item Natureza")
        aadd(aFieldsN, "Nome Item")
    Else
        //cria campos tabela temporario
        aadd(aFields, {"FILIAL", 'C', 02, 0})
        aadd(aFields, {"NATGR" , 'C', 02, 0})
        aadd(aFields, {"NOMEGR", 'C', 30, 0})
        nInicio:=5
        // Array como snomes dos campos
        aadd(aFieldsN,"Filial")
        aadd(aFieldsN,"Grupo Natureza")
        aadd(aFieldsN,"Nome Grupo")
    End

    // Define Filtro por Conta corrente
    IF mv_par13 == 1 
        IF !Empty(mv_par11)  // Considera a Conta 01
            cFilConta:="% SE5.E5_CONTA ='"+mv_par11+"' %"
        Else
            lErro := .T.
        Endif
    Elseif mv_par13 == 2     // Considera ambas (Conta 01 e Conta 02)
        IF !Empty(mv_par11) .and. !Empty(mv_par12)
            cFilConta:="% SE5.E5_CONTA IN ('"+mv_par11+"','"+mv_par12+"') %"  
        Else
            lErro := .T.        
        Endif 
    Else                     // Considera Nenhuma
        cFilConta:="% SE5.E5_CONTA <>' ' %"    
    Endif

    IF lErro
        MsgAlert("Os parâmetros relativos ao filtro de conta corrente foram configurados incorretamente!!!", "ATENÇÃO")
        Return
    Endif

    // Define Filtro por Filial
    IF !Empty(mv_par07)
        cFilFilial :=  "% "+FormatIn(AllTrim(mv_par07),";")+" %"
    Else
        MsgAlert("Os parâmetros relativos ao filtro de Filial foram configurados incorretamente!!!", "ATENÇÃO")
        Return
    Endif

    //Query de fluxoS
    Do Case
        Case  mv_par05  == 1  // Previsto
            EQFLXPRV(If(mv_par06==1,.T.,.F.),If(mv_par08==1,.T.,.F.),If(mv_par09==1,.T.,.F.))

        Case mv_par05 ==  2 // Realizado
            EQFLXREA(If(mv_par06==1,.T.,.F.),If(mv_par08==1,.T.,.F.),If(mv_par09==1,.T.,.F.))

        Case mv_par05 ==  3 // Comparativo
            EQFLXCMP(If(mv_par06==1,.T.,.F.),If(mv_par08==1,.T.,.F.),If(mv_par09==1,.T.,.F.))

        Case mv_par05 ==  4 // Diario Previsto
            EQFLXDIA(If(mv_par06==1,.T.,.F.),If(mv_par08==1,.T.,.F.),If(mv_par09==1,.T.,.F.),"P")

        Case mv_par05 ==  5 // Diario Realziado
            EQFLXDIA(If(mv_par06==1,.T.,.F.),If(mv_par08==1,.T.,.F.),If(mv_par09==1,.T.,.F.),"R")
    ENDCASE

    // SubTotais
    EQFLXST(If(mv_par06==1,.T.,.F.),If(mv_par08==1,.T.,.F.),If(mv_par09==1,.T.,.F.))

    // Gera Excel
    EQFLXEXC(If(mv_par06==1,.T.,.F.),If(mv_par08==1,.T.,.F.),If(mv_par09==1,.T.,.F.))
Return


/*/{Protheus.doc} EQFLXREA
Gera o Fluxo Realizado, podensdo ser ANalitico ou sintetico (so grupos) Impime Colsolidado e DFC
@type function Processmento
@version  1.00
@author mario.antonaccio
@since 10/02/2022
@param lAnalitico, logical, Indica se Imprime Analitico (.T.) ou Sintetico (.F.)
@param lConsolida, logical, Indica se Imprime Dados Consolidados (.T.) ou so Dados por Empresa (.F.)
@param lDFC, logical, Indica se Imprime Naturezas DFC (.T.) ou nao (.F.)
@return Character, Tabelas com os dados
/*/
Static Function EQFLXREA(lAnalitico,lConsolida,lDFC)
    Local nI      := 0
    Local cConcilia:= ""


    cExprEmp := "% "+FormatIn(AllTrim(mv_par07),";")+" %"
    
    // Somente Concilciados
    If mv_par10 == 1
       //cConcilia:=" %"+" SE5.E5_RECONC ='x' "+" %"
       cConcilia:="% SE5.E5_RECONC ='x' %"

    Else
       cConcilia:="% SE5.E5_RECONC IN ('x',' ') %"
    End        


    For nI:=0 to nDifMes
        cAnoMes:=ANOMES(MonthSum(mv_par01,nI))  // Retona o Ano e o mes seguintes a data base
        AADD(aFields,{"_"+cAnoMes,'N',14,2})
        //Nome Campo
        aadd(aFieldsN,Substr(cAnoMes,5,2)+"/"+Substr(cAnoMes,1,4))
        AADD(aDatas,cAnoMes)
    Next

    AADD(aFields,{"Total_Nat",'N',14,2})
    //Nome Campo
    AADD(aFieldsN,"Total Natureza")

    // Criaçao arquivo prnincipal
    oTmpTable:=FWTemporaryTable():New((_TFLX))
    oTmpTable:SetFields(aFields)
    oTmpTable:AddIndex("01",{"FILIAL","NATGR"})

    If lAnalitico
        oTmpTable:AddIndex("02",{"FILIAL","NATGR","NATSG"})
        oTmpTable:AddIndex("03",{"FILIAL","NATGR","NATSG","NATIT"})
    End

    oTmpTable:AddIndex("04",{"FILIAL","FLAG"})
    oTmpTable:Create()

    cArqReal:="%"+oTmpTable:GetRealName()+"%"

    // Gera por empresa conforme Parametro 07
    BeginSql Alias _FSE
        %noparser%

        SELECT
            FILIAL,
            NATUREZA,
            MESANO,
            SUM(VALOR) AS VALOR,
            TIPO,
            TIPODOC,
            PREFIXO,
            RECPAG
        FROM
            (
                SELECT
                    SUBSTRING(SE5.E5_FILIAL, 1, 2) AS FILIAL,
                    SED.ED_CODIGO AS NATUREZA,
                    SUBSTRING(SE5.E5_DTDISPO, 1, 6) AS MESANO,
                    CASE 
                        WHEN SE5.E5_TIPODOC IN('ES', 'TE') THEN (SE5.E5_VALOR - SE5.E5_VLJUROS - SE5.E5_VLMULTA + SE5.E5_VLDESCO ) * -1
                        WHEN SE5.E5_TIPODOC NOT IN('ES', 'TE') THEN (SE5.E5_VALOR - SE5.E5_VLJUROS - SE5.E5_VLMULTA + SE5.E5_VLDESCO ) 
                    END AS VALOR,
                    SE5.E5_TIPO AS TIPO,
                    SE5.E5_TIPODOC AS TIPODOC,
                    SE5.E5_PREFIXO AS PREFIXO,
                    SE5.E5_RECPAG AS RECPAG
                FROM
                    %Table:SE5% SE5
                INNER JOIN %Table:SED% SED
                      ON SE5.E5_NATUREZ = SED.ED_CODIGO AND SED.%NotDel%

			    INNER JOIN %Table:SA6% SA6
                      ON SA6.A6_FILIAL  = SUBSTRING(SE5.E5_FILIAL, 1, 2) 
                      AND SA6.A6_COD     = SE5.E5_BANCO 
                      AND SA6.A6_NUMCON  = SE5.E5_CONTA
                      AND SA6.A6_AGENCIA = SE5.E5_AGENCIA 
                      AND SA6.A6_FLUXCAI = 'S' 
                      AND SA6.%NotDel% 

                WHERE
                    SE5.%NotDel%
                    AND SE5.E5_DTDISPO >= %Exp:DTOS(mv_par01)%
                    AND SE5.E5_DTDISPO <= %Exp:DTOS(mv_par02)%
                    AND SUBSTRING(SE5.E5_FILIAL, 1, 2) IN %Exp:cExprEmp%
                    //AND SE5.E5_MOEDA <> 'TB'
                    AND SE5.E5_SITUACA = ' '
                    AND SE5.E5_MOTBX IN ('DEB', 'NOR', '  ')
                    AND %Exp:cFilConta%
                    AND %Exp:cConcilia%

            ) NAT
        GROUP BY
            FILIAL,
            NATUREZA,
            MESANO,
            TIPO,
            TIPODOC,
            PREFIXO,
            RECPAG
        ORDER BY
            FILIAL,
            NATUREZA,
            MESANO
    EndSql


    aQuery:=GetLastQuery()

    nTotReg := Contar((_FSE),"!EOF()")
    (_FSE)->(DbGoTop())

    ProcRegua(nTotReg)

    While (_FSE)->(!EOF())
        // Formatação campo natureza: 9.99.999
        // 99 - Grupo
        // 99 - Sub-Grupo
        // 999 - Item

        //-------------------------------------------------------
        // Redefine o codigo da Natureza em função do:#INCLUD
        // E5_TIPO, E5_TPODOC, E5_PREFIXO, E5_RECPA, etc...
        //-------------------------------------------------------
        cNatureza:=REGRANAT((_FSE)->NATUREZA,(_FSE)->TIPO,(_FSE)->TIPODOC,(_FSE)->RECPAG,(_FSE)->PREFIXO)

        If !Empty(cNatureza)

            SED->(dbSetOrder(1))

            cGrupo  := Substr(cNatureza,1,2)
            //Pega Nome da Natureza: Grupo
            SED->(MsSeek(xFilial("SED")+cGrupo))
            cNGrupo:=AllTrim(SED->ED_DESCRIC)
            If lAnalitico
                cSubGr  := Substr(cNatureza,3,2)
                //Pega Nome da Natureza: SubGrupo
                SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr))
                cNSubGr:=Alltrim(SED->ED_DESCRIC)

                cItem   := Substr(cNatureza,5,3)
                //Pega Nome da Natureza: Item
                SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr+cItem))
                cNItem:=AlLTrim(SED->ED_DESCRIC)
            End
        Else
            cGrupo:="99"
            cNGrupo:="SEM NATUREZA"
            cSubGr:=""
            cItem:=""
            cNSubGr:=""
            cNItem:=""
        End

        cCampo  := "(_FSE)->MESANO"
        cCampoT := "(_TFLX)->_"+&cCampo


        //---------------------------------------------------
        // Posiciona a Filial + Grupo na tabela temporaria
        // para fazer a totalização do valor da natureza.
        //---------------------------------------------------
        (_TFLX)->(dbSetOrder(1))
        If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo))
            RecLock((_TFLX),.F.)

            IF ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R")
                &cCampoT += (_FSE)->VALOR * (-1)
            Else
                &cCampoT +=(_FSE)->VALOR   
            Endif
        Else
            RecLock((_TFLX),.T.)
            (_TFLX)->FILIAL := (_FSE)->FILIAL
            (_TFLX)->NATGR  :=cGrupo
            (_TFLX)->NOMEGR :=cNGrupo

            &cCampoT := iif( ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R"),   (_FSE)->VALOR * -1, (_FSE)->VALOR)
        End
        MsUnlock()

        If lAnalitico
            //pesquiso no temporario se existe o Filial+grupo+SubGrupo
            (_TFLX)->(dbSetOrder(2))
            If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo+cSubGr))
                RecLock((_TFLX),.F.)

                IF ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R")
                    &cCampoT += (_FSE)->VALOR * (-1)
                Else
                    &cCampoT +=(_FSE)->VALOR   
                Endif
             Else
                RecLock((_TFLX),.T.)
                (_TFLX)->FILIAL:= (_FSE)->FILIAL
                (_TFLX)->NATGR :=cGrupo
                (_TFLX)->NATSG :=cSubGr
                (_TFLX)->NOMESG :=cNSubGr

                &cCampoT := iif( ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R"),   (_FSE)->VALOR * -1, (_FSE)->VALOR)
            End
            MsUnLock()

            //pesquiso no temporario se existe o Filial+grupo+SubGrupo+Item
            (_TFLX)->(dbSetOrder(3))
            If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo+cSubGr+cItem))
                RecLock((_TFLX),.F.)
                IF ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R")
                    &cCampoT += (_FSE)->VALOR * (-1)
                Else
                    &cCampoT +=(_FSE)->VALOR   
                Endif

            Else
                RecLock((_TFLX),.T.)
                (_TFLX)->FILIAL := (_FSE)->FILIAL
                (_TFLX)->NATGR  := cGrupo
                (_TFLX)->NATSG  := cSubGr
                (_TFLX)->NATIT  := cItem
                (_TFLX)->NOMEIT := cNItem

                &cCampoT := iif( ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R"),   (_FSE)->VALOR * -1, (_FSE)->VALOR)
            End
            MsUnLock()

        End

        (_FSE)->(dbSkip())
    End

    (_FSE)->(dbCloseArea())

    // Consolidada
    If lConsolida  // Imprime Planilha Consolidada
        BeginSql Alias _FSE
            %noparser%

            SELECT
                NATUREZA,
                MESANO,
                SUM(VALOR) AS VALOR,
                TIPO,
                TIPODOC,
                PREFIXO,
                RECPAG
                
            FROM
                (
                    SELECT
                        SED.ED_CODIGO AS NATUREZA,
                        SUBSTRING(SE5.E5_DTDISPO, 1, 6) AS MESANO,
                        CASE 
                            WHEN SE5.E5_TIPODOC IN('ES', 'TE') THEN (SE5.E5_VALOR - SE5.E5_VLJUROS - SE5.E5_VLMULTA + SE5.E5_VLDESCO ) * -1
                            WHEN SE5.E5_TIPODOC NOT IN('ES', 'TE') THEN (SE5.E5_VALOR - SE5.E5_VLJUROS - SE5.E5_VLMULTA + SE5.E5_VLDESCO ) 
                        END AS VALOR,
                        SE5.E5_TIPO AS TIPO,
                        SE5.E5_TIPODOC AS TIPODOC,
                        SE5.E5_PREFIXO AS PREFIXO,
                        SE5.E5_RECPAG AS RECPAG
                    FROM
                        %Table:SE5% SE5
                    INNER JOIN %Table:SED% SED
                        ON SE5.E5_NATUREZ = SED.ED_CODIGO AND SED.%NotDel%

                    INNER JOIN %Table:SA6% SA6
                        ON SA6.A6_FILIAL  = SUBSTRING(SE5.E5_FILIAL, 1, 2) 
                        AND SA6.A6_COD     = SE5.E5_BANCO 
                        AND SA6.A6_NUMCON  = SE5.E5_CONTA
                        AND SA6.A6_AGENCIA = SE5.E5_AGENCIA 
                        AND SA6.A6_FLUXCAI = 'S' 
                        AND SA6.%NotDel% 

                    WHERE
                        SE5.%NotDel%
                        AND SE5.E5_DTDISPO >= %Exp:DTOS(mv_par01)%
                        AND SE5.E5_DTDISPO <= %Exp:DTOS(mv_par02)%
                        AND SUBSTRING(SE5.E5_FILIAL, 1, 2) IN %Exp:cExprEmp%
                        //AND SE5.E5_MOEDA <> 'TB'
                        AND SE5.E5_SITUACA = ' '
                        AND SE5.E5_MOTBX IN ('DEB', 'NOR', '  ')
                        AND %Exp:cFilConta%
                        AND %Exp:cConcilia%                        
                ) NAT
            GROUP BY
                NATUREZA,
                MESANO,
                TIPO,
                TIPODOC,
                PREFIXO,
                RECPAG
            ORDER BY
                NATUREZA,
                MESANO
        EndSql
        
        aQuery:=GetLastQuery()

        nTotReg := Contar((_FSE),"!EOF()")
        (_FSE)->(DbGoTop())

        ProcRegua(nTotReg)

        While (_FSE)->(!EOF())
            // Formatação campo natureza: 9.99.999
            // 99 - Grupo
            // 99 - Sub-Grupo
            // 999 - Item

            //-------------------------------------------------------
            // Redefine o codigo da Natureza em função do:#INCLUD
            // E5_TIPO, E5_TPODOC, E5_PREFIXO, E5_RECPA, etc...
            //-------------------------------------------------------

            cNatureza:=REGRANAT((_FSE)->NATUREZA,(_FSE)->TIPO,(_FSE)->TIPODOC,(_FSE)->RECPAG,(_FSE)->PREFIXO)

            If !Empty(cNatureza)

                SED->(dbSetOrder(1))

                cGrupo  := Substr(cNatureza,1,2)
                //Pega Nome da Natureza: Grupo
                SED->(MsSeek(xFilial("SED")+cGrupo))
                cNGrupo:=AllTrim(SED->ED_DESCRIC)

                If lAnalitico
                    cSubGr  := Substr(cNatureza,3,2)
                    //Pega Nome da Natureza: SubGrupo
                    SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr))
                    cNSubGr:=Alltrim(SED->ED_DESCRIC)

                    cItem   := Substr(cNatureza,5,3)
                    //Pega Nome da Natureza: Item
                    SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr+cItem))
                    cNItem:=AlLTrim(SED->ED_DESCRIC)
                End
            Else
                cGrupo:="99"
                cNGrupo:="SEM NATUREZA"
                cSubGr:=""
                cItem:=""
                cNSubGr:=""
                cNItem:=""
            End

            cCampo  := "(_FSE)->MESANO"
            cCampoT := "(_TFLX)->_"+&cCampo

            //pesquiso no temporario se existe o grupo
            (_TFLX)->(dbSetOrder(1))
            If (_TFLX)->(Dbseek(Space(02)+cGrupo))
                RecLock((_TFLX),.F.)
                IF ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R")
                    &cCampoT += (_FSE)->VALOR * (-1)
                Else
                    &cCampoT +=(_FSE)->VALOR   
                Endif

            Else
                RecLock((_TFLX),.T.)
                (_TFLX)->NATGR :=cGrupo
                (_TFLX)->NOMEGR :=cNGrupo

                &cCampoT := iif( ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R"),   (_FSE)->VALOR * -1, (_FSE)->VALOR)
            End
            MsUnlock()

            If lAnalitico
                //pesquiso no temporario se existe o grupo+SubGrupo
                (_TFLX)->(dbSetOrder(2))
                If (_TFLX)->(Dbseek(Space(02)+cGrupo+cSubGr))
                    RecLock((_TFLX),.F.)
                    IF ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R")
                        &cCampoT += (_FSE)->VALOR * (-1)
                    Else
                        &cCampoT +=(_FSE)->VALOR   
                    Endif

                Else
                    RecLock((_TFLX),.T.)
                    (_TFLX)->NATGR :=cGrupo
                    (_TFLX)->NATSG :=cSubGr
                    (_TFLX)->NOMESG :=cNSubGr

                    &cCampoT := iif( ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R"),   (_FSE)->VALOR * -1, (_FSE)->VALOR)
                End
                MsUnLock()

                //pesquiso no temporario se existe o grupo+SubGrupo+Item
                (_TFLX)->(dbSetOrder(3))
                If (_TFLX)->(Dbseek(Space(02)+cGrupo+cSubGr+cItem))
                    RecLock((_TFLX),.F.)
                    IF ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R")
                        &cCampoT += (_FSE)->VALOR * (-1)
                    Else
                        &cCampoT +=(_FSE)->VALOR   
                    Endif

                Else
                    RecLock((_TFLX),.T.)
                    (_TFLX)->NATGR  := cGrupo
                    (_TFLX)->NATSG  := cSubGr
                    (_TFLX)->NATIT  := cItem
                    (_TFLX)->NOMEIT := cNItem

                    &cCampoT := iif( ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R"),   (_FSE)->VALOR * -1, (_FSE)->VALOR)
                End
                MsUnLock()
            End

            (_FSE)->(dbSkip())
        End

        (_FSE)->(dbCloseArea())
    End
Return

/*/{Protheus.doc} EQFLXDIA
Gera o Fluxo Previsto DIARIO, podensdo ser ANalitico ou sintetico (so grupos) Impime Colsolidado e DFC
@type function Processmento
@version  1.00
@author mario.antonaccio
@since 10/02/2022
@param lAnalitico, logical, Indica se Imprime Analitico (.T.) ou Sintetico (.F.)
@param lConsolida, logical, Indica se Imprime Dados Consolidados (.T.) ou so Dados por Empresa (.F.)
@param lDFC, logical, Indica se Imprime Naturezas DFC (.T.) ou nao (.F.)
@return Character, Tabelas com os dados
/*/
Static Function  EQFLXDIA(lAnalitico,lConsolida,lDF,cTipo)
    Local nI

    cExprEmp := "% "+FormatIn(AllTrim(mv_par07),";")+" %"

    // Somente Concilciados
    If mv_par10 == 1
       //cConcilia:=" %"+" SE5.E5_RECONC ='x' "+" %"
       cConcilia:="% SE5.E5_RECONC ='x' %"

    Else
       cConcilia:="% SE5.E5_RECONC IN ('x',' ') %"
    End   

    //Mostra as datas ao inves dos meses
    nDifMes:=DateDiffDay(mv_par01,mv_par02)
    For nI:=0 to nDifMes
        cData:=DTOC(mv_par01+nI)
        AADD(aFields,{"_"+DTOS(CTOD(cData)),'N',14,2})
        //Nome Campo
        aadd(aFieldsN,cData)
        AADD(aDatas,cData)
    Next

    AADD(aFields,{"Total_Nat",'N',14,2})
    //Nome Campo
    AADD(aFieldsN,"Total Natureza")

    // Cria tabela temporaria
    oTmpTable:=FWTemporaryTable():New((_TFLX))
    oTmpTable:SetFields(aFields)

    // Definie / Cria os indices
    oTmpTable:AddIndex("01",{"FILIAL","NATGR"})
    If lAnalitico
        oTmpTable:AddIndex("02",{"FILIAL","NATGR","NATSG"})
        oTmpTable:AddIndex("03",{"FILIAL","NATGR","NATSG","NATIT"})
    End

    oTmpTable:AddIndex("04",{"FILIAL","FLAG"})
    oTmpTable:Create()
    cArqReal:="%"+oTmpTable:GetRealName()+"%"

    // Gera por empresa conforme Parametro 07
    If cTipo == "P"  // Previsto
        BeginSql Alias _FSE
            SELECT
                FILIAL,
                NATUREZA,
                MESANO,
                SUM(VALOR) AS VALOR
            FROM
                (
                    SELECT
                        SUBSTRING(SE1.E1_FILIAL, 1, 2) AS FILIAL,
                        SED.ED_CODIGO AS NATUREZA,
                        SE1.E1_EMISSAO AS MESANO,
                        SE1.E1_SALDO AS VALOR
                    FROM
                        %Table:SE1% SE1
                    INNER JOIN %Table:SED% SED
                    ON SE1.E1_NATUREZ = SED.ED_CODIGO
                        AND SED.%NotDel%
                        //AND SED.ED_XNEWNAT <> 'NC'
                    WHERE
                        SE1.%NotDel%
                        AND SE1.E1_SALDO > 0
                        AND SE1.E1_EMISSAO >= %Exp:DTOS(mv_par01)%
                        AND SE1.E1_EMISSAO <= %Exp:DTOS(mv_par02)%
                        AND SUBSTRING(SE1.E1_FILIAL, 1, 2) IN %Exp:cExprEmp%
                    UNION
                    SELECT
                        SUBSTRING(SE2.E2_FILIAL, 1, 2) AS FILIAL,
                        SED.ED_CODIGO AS NATUREZA,
                        SE2.E2_EMISSAO AS MESANO,
                        SE2.E2_SALDO AS VALOR
                    FROM
                        %Table:SE2% SE2
                    INNER JOIN %Table:SED% SED
                    ON SE2.E2_NATUREZ = SED.ED_CODIGO
                        AND SED.%NotDel%
                        //AND SED.ED_XNEWNAT <> 'NC'
                    WHERE
                        SE2.%NotDel%
                        AND SE2.E2_SALDO > 0
                        AND SE2.E2_EMISSAO >= %Exp:DTOS(mv_par01)%
                        AND SE2.E2_EMISSAO <= %Exp:DTOS(mv_par02)%
                        AND SUBSTRING(SE2.E2_FILIAL, 1, 2) IN %Exp:cExprEmp%
                ) NAT
            GROUP BY
                FILIAL,
                NATUREZA,
                MESANO
            ORDER BY
                FILIAL,
                NATUREZA,
                MESANO
        EndSql

    ElseIf cTipo == "R" // DIARIO REALIZADO
        //------------------------------------------------------
        // Tratamento para impresão do fluxo diário
        //------------------------------------------------------    

        BeginSql Alias _FSE
            %noparser%
            SELECT
                FILIAL,
                NATUREZA,
                MESANO,
                SUM(VALOR) AS VALOR,
                TIPO,
                TIPODOC,
                PREFIXO,
                RECPAG
            FROM
                (
                    SELECT
                        SUBSTRING(SE5.E5_FILIAL, 1, 2) AS FILIAL,
                        SED.ED_CODIGO AS NATUREZA,
                        SE5.E5_DTDISPO AS MESANO,
                        CASE 
                            WHEN SE5.E5_TIPODOC IN('ES', 'TE') THEN (SE5.E5_VALOR - SE5.E5_VLJUROS - SE5.E5_VLMULTA + SE5.E5_VLDESCO ) * -1
                            WHEN SE5.E5_TIPODOC NOT IN('ES', 'TE') THEN (SE5.E5_VALOR - SE5.E5_VLJUROS - SE5.E5_VLMULTA + SE5.E5_VLDESCO ) 
                        END AS VALOR,
                        SE5.E5_TIPO AS TIPO,
                        SE5.E5_TIPODOC AS TIPODOC,
                        SE5.E5_PREFIXO AS PREFIXO,
                        SE5.E5_RECPAG AS RECPAG
                    FROM
                        %Table:SE5% SE5
                    INNER JOIN %Table:SED% SED
                          ON SE5.E5_NATUREZ = SED.ED_CODIGO AND SED.%NotDel%

			        INNER JOIN %Table:SA6% SA6
                          ON SA6.A6_FILIAL  = SUBSTRING(SE5.E5_FILIAL, 1, 2) 
                         AND SA6.A6_COD     = SE5.E5_BANCO 
                         AND SA6.A6_NUMCON  = SE5.E5_CONTA
                         AND SA6.A6_AGENCIA = SE5.E5_AGENCIA 
                         AND SA6.A6_FLUXCAI = 'S' 
                         AND SA6.%NotDel% 

                    WHERE
                        SE5.%NotDel%
                        AND SE5.E5_DTDISPO >= %Exp:DTOS(mv_par01)%
                        AND SE5.E5_DTDISPO <= %Exp:DTOS(mv_par02)%
                        AND SUBSTRING(SE5.E5_FILIAL, 1, 2) IN %Exp:cExprEmp%
                        //AND SE5.E5_MOEDA <> 'TB'
                        AND SE5.E5_SITUACA = ' '
                        AND SE5.E5_MOTBX IN ('DEB', 'NOR', '  ')
                        AND %Exp:cFilConta%
                        AND %Exp:cConcilia%
                        //AND SE5.E5_TIPODOC IN ('TE','TR') ///// TIRAR ESSE FILTRO DAQUI - ** TESTE ***
                        //AND SE5.E5_TIPO IN ('RA','PA') ///// TIRAR ESSE FILTRO DAQUI - ** TESTE *** 
                ) NAT
            GROUP BY
                FILIAL,
                NATUREZA,
                MESANO,
                TIPO,
                TIPODOC,
                PREFIXO,
                RECPAG
            ORDER BY
                FILIAL,
                NATUREZA,
                MESANO
        EndSql

    Endif
    aQuery:=GetLastQuery()

    nTotReg := Contar((_FSE),"!EOF()")
    (_FSE)->(DbGoTop())

    ProcRegua(nTotReg)

    Do While (_FSE)->(!EOF())
        IncProc()

        // Formatação campo natureza: 9.99.999
        // 99 - Grupo
        // 99 - Sub-Grupo
        // 999 - Item

        //-------------------------------------------------------
        // Redefine o codigo da Natureza em função do:
        // E5_TIPO, E5_TPODOC, E5_PREFIXO, E5_RECPA, etc...
        //-------------------------------------------------------
        cNatureza:=REGRANAT((_FSE)->NATUREZA,(_FSE)->TIPO,(_FSE)->TIPODOC,(_FSE)->RECPAG,(_FSE)->PREFIXO)

        IF (_FSE)->MESANO = '20221013'
            xpto := 0
        Endif

        If !Empty(cNatureza)
            // Pega o Grupo da Natureza
            SED->(dbSetOrder(1))
            cGrupo  := Substr(cNatureza,1,2)

            //Pega Nome da Natureza: Grupo
            SED->(MsSeek(xFilial("SED")+cGrupo))
            cNGrupo:=AllTrim(SED->ED_DESCRIC)

            If lAnalitico
                // Pega o Sub-Grupo da Natureza
                cSubGr  := Substr(cNatureza,3,2)

                // Pega Nome da Natureza: SubGrupo
                SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr))
                cNSubGr:=Alltrim(SED->ED_DESCRIC)

                cItem   := Substr(cNatureza,5,3)

                // Pega Nome da Natureza: Item
                SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr+cItem))
                cNItem:=AlLTrim(SED->ED_DESCRIC)
            Endif
        Else
            cGrupo:="99"
            cNGrupo:="SEM NATUREZA"
            cSubGr:=""
            cItem:=""
            cNSubGr:=""
            cNItem:=""
        Endif

        cCampo  := "(_FSE)->MESANO"
        cCampoT := "(_TFLX)->_"+&cCampo

        //---------------------------------------------------
        // Posiciona a Filial + Grupo na tabela temporaria
        // para fazer a totalização do valor da natureza.
        //---------------------------------------------------
        (_TFLX)->(dbSetOrder(1))  // FILIAL + NATGR  

        If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo))
            RecLock((_TFLX),.F.)
            IF ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R")
                &cCampoT += (_FSE)->VALOR * (-1)
            Else
                &cCampoT +=(_FSE)->VALOR   
            Endif

        Else
            RecLock((_TFLX),.T.)
            (_TFLX)->FILIAL := (_FSE)->FILIAL
            (_TFLX)->NATGR  := cGrupo
            (_TFLX)->NOMEGR := cNGrupo

            &cCampoT := iif( ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R"),   (_FSE)->VALOR * -1, (_FSE)->VALOR)

        Endif
        MsUnlock()

        If lAnalitico
            //--------------------------------------------------------------
            // Posiciona a Filial + Grupo + SubGrupo na tabela temporaria
            // para fazer a totalização do valor da natureza.
            //--------------------------------------------------------------        
            (_TFLX)->(dbSetOrder(2))  // FILIAL + NATGR + NATSG
            If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo+cSubGr))
                RecLock((_TFLX),.F.)

                IF ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R")
                    &cCampoT += (_FSE)->VALOR * (-1)
                Else
                    &cCampoT +=(_FSE)->VALOR   
                Endif  
            Else
                RecLock((_TFLX),.T.)
                (_TFLX)->FILIAL:= (_FSE)->FILIAL
                (_TFLX)->NATGR :=cGrupo
                (_TFLX)->NATSG :=cSubGr
                (_TFLX)->NOMESG :=cNSubGr
            
                &cCampoT := iif( ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R"),   (_FSE)->VALOR * -1, (_FSE)->VALOR)
            End
            MsUnLock()

            //--------------------------------------------------------------------
            // Posiciona a Filial + Grupo + SubGrupo + Item na tabela temporaria
            // para fazer a totalização do valor da natureza.
            //--------------------------------------------------------------------             
            (_TFLX)->(dbSetOrder(3))// FILIAL + NATGR + NATSG + NATIT
            If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo+cSubGr+cItem))
                RecLock((_TFLX),.F.)

                IF ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R")
                    &cCampoT += (_FSE)->VALOR * (-1)
                Else
                    &cCampoT +=(_FSE)->VALOR   
                Endif   

            Else
                RecLock((_TFLX),.T.)
                (_TFLX)->FILIAL:= (_FSE)->FILIAL
                (_TFLX)->NATGR := cGrupo
                (_TFLX)->NATSG := cSubGr
                (_TFLX)->NATIT := cItem
                (_TFLX)->NOMEIT := cNItem

                &cCampoT := iif( ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R"),   (_FSE)->VALOR * -1, (_FSE)->VALOR)
            End
            MsUnLock()
        End

        (_FSE)->(dbSkip())

    Enddo

    // Fecha tabela Temporaria
    (_FSE)->(dbCloseArea())

    //------------------------------------------------------
    // Tratamento para impresão da Planilha consolidada
    //------------------------------------------------------
    If lConsolida  
        BeginSql Alias _FSE
            %noparser%
            SELECT
                NATUREZA,
                MESANO,
                SUM(VALOR) AS VALOR,
                TIPO,
                TIPODOC,
                PREFIXO,
                RECPAG
            FROM
                (
                    SELECT
                        SED.ED_CODIGO AS NATUREZA,
                        SE5.E5_DTDISPO AS MESANO,
                        CASE 
                            WHEN SE5.E5_TIPODOC IN('ES', 'TE') THEN (SE5.E5_VALOR - SE5.E5_VLJUROS - SE5.E5_VLMULTA + SE5.E5_VLDESCO ) * -1
                            WHEN SE5.E5_TIPODOC NOT IN('ES', 'TE') THEN (SE5.E5_VALOR - SE5.E5_VLJUROS - SE5.E5_VLMULTA + SE5.E5_VLDESCO ) 
                        END AS VALOR,                        
                        SE5.E5_TIPO AS TIPO,
                        SE5.E5_TIPODOC AS TIPODOC,
                        SE5.E5_PREFIXO AS PREFIXO,
                        SE5.E5_RECPAG AS RECPAG
                    FROM
                        %Table:SE5% SE5
                    INNER JOIN %Table:SED% SED
                          ON SE5.E5_NATUREZ = SED.ED_CODIGO AND SED.%NotDel%

			        INNER JOIN %Table:SA6% SA6
                          ON SA6.A6_FILIAL  = SUBSTRING(SE5.E5_FILIAL, 1, 2) 
                         AND SA6.A6_COD     = SE5.E5_BANCO 
                         AND SA6.A6_NUMCON  = SE5.E5_CONTA
                         AND SA6.A6_AGENCIA = SE5.E5_AGENCIA 
                         AND SA6.A6_FLUXCAI = 'S' 
                         AND SA6.%NotDel% 

                    WHERE
                        SE5.%NotDel%
                        AND SE5.E5_DTDISPO >= %Exp:DTOS(mv_par01)%
                        AND SE5.E5_DTDISPO <= %Exp:DTOS(mv_par02)%
                        AND SUBSTRING(SE5.E5_FILIAL, 1, 2) IN %Exp:cExprEmp%
                        //ND SE5.E5_MOEDA <> 'TB'
                        AND SE5.E5_SITUACA = ' '
                        AND SE5.E5_MOTBX IN ('DEB', 'NOR', '  ')
                        AND %Exp:cFilConta%
                        AND %Exp:cConcilia%
                        //AND SE5.E5_TIPODOC IN ('TE','TR') ///// TIRAR ESSE FILTRO DAQUI - ** TESTE ***   
                        //AND SE5.E5_TIPO IN ('RA','PA') ///// TIRAR ESSE FILTRO DAQUI - ** TESTE ***  

                ) NAT
            GROUP BY
                NATUREZA,
                MESANO,
                TIPO,
                TIPODOC,
                PREFIXO,
                RECPAG
            ORDER BY
                NATUREZA,
                MESANO
        EndSql


        aQuery:=GetLastQuery()

        nTotReg := Contar((_FSE),"!EOF()")
        (_FSE)->(DbGoTop())

        ProcRegua(nTotReg)

        While (_FSE)->(!EOF())
            IncProc()

            // Formatação campo natureza: 9.99.999
            // 9 - Grupo
            // 99 - Sub-Grupo
            // 999 - Item

            cNatureza:=REGRANAT((_FSE)->NATUREZA,(_FSE)->TIPO,(_FSE)->TIPODOC,(_FSE)->RECPAG,(_FSE)->PREFIXO)

            //aChkNAt := fGetItemNat(cNatureza)

            If !Empty(cNatureza)
                // Pega o Grupo da Natureza
                SED->(dbSetOrder(1))
                cGrupo  := Substr(cNatureza,1,2)

                //Pega Nome da Natureza: Grupo
                SED->(MsSeek(xFilial("SED")+cGrupo))
                cNGrupo:=AllTrim(SED->ED_DESCRIC)


                If lAnalitico
                    // Pega o Sub-Grupo da Natureza
                    //cSubGr  := Substr(cNatureza,3,2)

                    // Pega Nome da Natureza: SubGrupo
                    SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr))
                    cNSubGr:=Alltrim(SED->ED_DESCRIC)

                    cItem   := Substr(cNatureza,5,3)

                    // Pega Nome da Natureza: Item
                    SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr+cItem))
                    cNItem:=AlLTrim(SED->ED_DESCRIC)

                    /*
                    IF (_FSE)->TIPODOC  == 'TR' 
                        cSubGr  := cSubGr+(_FSE)->RECPAG 

                        IF (_FSE)->RECPAG == "P"
                            cNSubGr := "(-)" + cNSubGr
                        Else
                            cNSubGr := "(+)" + cNSubGr
                        Endif
                    Endif
                    */
                Endif
            Else
                cGrupo:="99"
                cNGrupo:="SEM NATUREZA"
                cSubGr:=""
                cItem:=""
                cNSubGr:=""
                cNItem:=""
            Endif

            cCampo  := "(_FSE)->MESANO"
            cCampoT := "(_TFLX)->_"+&cCampo

            //pesquiso no temporario se existe o grupo
            (_TFLX)->(dbSetOrder(1))
            If (_TFLX)->(Dbseek(Space(02)+cGrupo))
                RecLock((_TFLX),.F.)

                IF ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R")
                    &cCampoT += (_FSE)->VALOR * (-1)
                Else
                    &cCampoT +=(_FSE)->VALOR   
                Endif  
            Else
                RecLock((_TFLX),.T.)
                (_TFLX)->NATGR  := cGrupo
                (_TFLX)->NOMEGR := cNGrupo

                &cCampoT := iif( ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R"),   (_FSE)->VALOR * -1, (_FSE)->VALOR)
            End
            MsUnlock()

            If lAnalitico
                //pesquiso no temporario se existe o grupo+SubGrupo
                (_TFLX)->(dbSetOrder(2))
                If (_TFLX)->(Dbseek(Space(02)+cGrupo+cSubGr))
                    RecLock((_TFLX),.F.)
                        
                    IF ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R")
                        &cCampoT += (_FSE)->VALOR * (-1)
                    Else
                        &cCampoT +=(_FSE)->VALOR   
                    Endif   
                Else
                    RecLock((_TFLX),.T.)
                    (_TFLX)->NATGR  := cGrupo
                    (_TFLX)->NATSG  := cSubGr
                    (_TFLX)->NOMESG := cNSubGr
                    &cCampoT := iif( ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R"),   (_FSE)->VALOR * -1, (_FSE)->VALOR)
                End
                MsUnLock()

                //pesquiso no temporario se existe o grupo+SubGrupo+Item
                (_TFLX)->(dbSetOrder(3))
                If (_TFLX)->(Dbseek(Space(02)+cGrupo+cSubGr+cItem))
                    RecLock((_TFLX),.F.)

                    IF ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R")
                        &cCampoT += (_FSE)->VALOR * (-1)
                    Else
                        &cCampoT +=(_FSE)->VALOR   
                    Endif    
                Else
                    RecLock((_TFLX),.T.)
                    (_TFLX)->NATGR  := cGrupo
                    (_TFLX)->NATSG  := cSubGr
                    (_TFLX)->NATIT  := cItem
                    (_TFLX)->NOMEIT := cNItem

                    &cCampoT := iif( ((_FSE)->TIPODOC == "TR" .AND. (_FSE)->RECPAG == "P") .OR. ((_FSE)->TIPODOC == "TE" .AND. (_FSE)->RECPAG ==  "R"),   (_FSE)->VALOR * -1, (_FSE)->VALOR)
                End
                MsUnLock()
            End

            (_FSE)->(dbSkip())
        End

        (_FSE)->(dbCloseArea())
    Endif 

Return


/*/{Protheus.doc} EQFLXPRV
Gera o Fluxo Previsto, podensdo ser ANalitico ou sintetico (so grupos) Impime Colsolidado e DFC
@type function Processmento
@version  1.00
@author mario.antonaccio
@since 10/02/2022
@param lAnalitico, logical, Indica se Imprime Analitico (.T.) ou Sintetico (.F.)
@param lConsolida, logical, Indica se Imprime Dados Consolidados (.T.) ou so Dados por Empresa (.F.)
@param lDFC, logical, Indica se Imprime Naturezas DFC (.T.) ou nao (.F.)
@return Character, Tabelas com os dados
/*/
Static Function  EQFLXPRV(lAnalitico,lConsolida,lDFC)

    Local nI

    For nI:=0 to nDifMes
        cAnoMes:=ANOMES(MonthSum(mv_par01,nI))  // Retona o NAo e o mes seguintes a data base
        AADD(aFields,{"_"+cAnoMes,'N',14,2})
        //Nome Campo
        aadd(aFieldsN,Substr(cAnoMes,5,2)+"/"+Substr(cAnoMes,1,4))
        AADD(aDatas,cAnoMes)
    Next
    AADD(aFields,{"Total_Nat",'N',14,2})
    //Nome Campo
    AADD(aFieldsN,"Total ")

    oTmpTable:=FWTemporaryTable():New((_TFLX))
    oTmpTable:SetFields(aFields)
    oTmpTable:AddIndex("01",{"FILIAL","NATGR"})
    If lAnalitico
        oTmpTable:AddIndex("02",{"FILIAL","NATGR","NATSG"})
        oTmpTable:AddIndex("03",{"FILIAL","NATGR","NATSG","NATIT"})
    End
    oTmpTable:AddIndex("04",{"FILIAL","FLAG"})
    oTmpTable:Create()

    cArqReal:="%"+oTmpTable:GetRealName()+"%"

    // Gera por empresa conforme Parametro 07
    BeginSql Alias _FSE
        SELECT
            FILIAL,
            NATUREZA,
            MESANO,
            SUM(VALOR) AS VALOR
        FROM
            (
                SELECT
                    SUBSTRING(SE1.E1_FILIAL, 1, 2) AS FILIAL,
                    SED.ED_CODIGO AS NATUREZA,
                    SUBSTRING(SE1.E1_EMISSAO, 1, 6) AS MESANO,
                    SE1.E1_SALDO AS VALOR
                FROM
                    %Table:SE1% SE1
                INNER JOIN %Table:SED% SED
                ON SE1.E1_NATUREZ = SED.ED_CODIGO
                    AND SED.%NotDel%
                    //AND SED.ED_XNEWNAT <> 'NC'
                WHERE
                    SE1.%NotDel%
                    AND SE1.E1_SALDO > 0
                    AND SE1.E1_EMISSAO >= %Exp:DTOS(mv_par01)%
                    AND SE1.E1_EMISSAO <= %Exp:DTOS(mv_par02)%
                    AND SUBSTRING(SE1.E1_FILIAL, 1, 2) IN %Exp:cExprEmp%
                UNION
                SELECT
                    SUBSTRING(SE2.E2_FILIAL, 1, 2) AS FILIAL,
                    SED.ED_CODIGO AS NATUREZA,
                    SUBSTRING(SE2.E2_EMISSAO, 1, 6) AS MESANO,
                    SE2.E2_SALDO AS VALOR
                FROM
                    %Table:SE2% SE2
                INNER JOIN %Table:SED% SED
                ON SE2.E2_NATUREZ = SED.ED_CODIGO
                    AND SED.%NotDel%
                    //AND SED.ED_XNEWNAT <> 'NC'
                WHERE
                    SE2.%NotDel%
                    AND SE2.E2_SALDO > 0
                    AND SE2.E2_EMISSAO >= %Exp:DTOS(mv_par01)%
                    AND SE2.E2_EMISSAO <= %Exp:DTOS(mv_par02)%
                    AND SUBSTRING(SE2.E2_FILIAL, 1, 2) IN %Exp:cExprEmp%
            ) NAT
        GROUP BY
            FILIAL,
            NATUREZA,
            MESANO
    EndSql

    aQuery:=GetLastQuery()

    nTotReg := Contar((_FSE),"!EOF()")

    (_FSE)->(DbGoTop())

    ProcRegua(nTotReg)

    While (_FSE)->(!EOF())
        // Formatação campo natureza: 99.99.999
        // 99 - Grupo
        // 99 - Sub-Grupo
        // 999 - Item
        If !Empty((_FSE)->NATUREZA)

            SED->(dbSetOrder(1))

            cGrupo  := Substr((_FSE)->NATUREZA,1,2)
            //Pega Nome da Natureza: Grupo
            SED->(MsSeek(xFilial("SED")+cGrupo))
            cNGrupo:=AllTrim(SED->ED_DESCRIC)
            //cDFC:=SED->ED_XDFC
            
            If lAnalitico
                cSubGr  := Substr((_FSE)->NATUREZA,3,2)
                //Pega Nome da Natureza: SubGrupo
                SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr))
                cNSubGr:=Alltrim(SED->ED_DESCRIC)
                // cDFC:=SED->ED_XDFC

                cItem   := Substr((_FSE)->NATUREZA,5,3)
                //Pega Nome da Natureza: Item
                SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr+cItem))
                cNItem:=AlLTrim(SED->ED_DESCRIC)
                //cDFC:=SED->ED_XDFC
            End
        Else
            cGrupo:="99"
            cNGrupo:="SEM NATUREZA"
            cSubGr:=""
            cItem:=""
            cNSubGr:=""
            cNItem:=""
            lSemNat:=.T.
            cDFC:=""
        End
        cCampo  := "(_FSE)->MESANO"
        cCampoT := "(_TFLX)->_"+&cCampo

        //pesquiso no temporario se existe o Filial+grupo
        (_TFLX)->(dbSetOrder(1))
        If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo))
            RecLock((_TFLX),.F.)
            &cCampoT+=(_FSE)->VALOR
        Else
            RecLock((_TFLX),.T.)
            //(_TFLX)->DFC:= cDFC
            (_TFLX)->FILIAL:= (_FSE)->FILIAL
            (_TFLX)->NATGR :=cGrupo
            (_TFLX)->NOMEGR :=cNGrupo
            &cCampoT:=(_FSE)->VALOR
        End
        MsUnlock()

        If lAnalitico
            //pesquiso no temporario se existe o Filial+grupo+SubGrupo
            (_TFLX)->(dbSetOrder(2))
            If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo+cSubGr))
                RecLock((_TFLX),.F.)
                &cCampoT+=(_FSE)->VALOR
            Else
                RecLock((_TFLX),.T.)
                (_TFLX)->FILIAL:= (_FSE)->FILIAL
                // (_TFLX)->DFC:= cDFC
                (_TFLX)->NATGR :=cGrupo
                (_TFLX)->NATSG :=cSubGr
                (_TFLX)->NOMESG :=cNSubGr
                &cCampoT:=(_FSE)->VALOR
            End
            MsUnLock()

            //pesquiso no temporario se existe o Filial+grupo+SubGrupo+Item
            (_TFLX)->(dbSetOrder(3))
            If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo+cSubGr+cItem))
                RecLock((_TFLX),.F.)
                &cCampoT+=(_FSE)->VALOR
            Else
                RecLock((_TFLX),.T.)
                // (_TFLX)->DFC:= cDFC
                (_TFLX)->FILIAL:= (_FSE)->FILIAL
                (_TFLX)->NATGR := cGrupo
                (_TFLX)->NATSG := cSubGr
                (_TFLX)->NATIT := cItem
                (_TFLX)->NOMEIT := cNItem
                &cCampoT       := (_FSE)->VALOR
            End
            MsUnLock()

        End

        (_FSE)->(dbSkip())

    End
    (_FSE)->(dbCloseArea())

    // Consolidada
    If lConsolida  // Imprime Planilha Consolidada
        BeginSql Alias _FSE
            SELECT
                NATUREZA,
                MESANO,
                SUM(VALOR) AS VALOR
            FROM
                (
                    SELECT
                        SED.ED_CODIGO AS NATUREZA,
                        SUBSTRING(SE1.E1_EMISSAO, 1, 6) AS MESANO,
                        SE1.E1_SALDO AS VALOR
                    FROM
                        %Table:SE1% SE1
                    INNER JOIN %Table:SED% SED
                    ON SE1.E1_NATUREZ = SED.ED_CODIGO
                        AND SED.%NotDel%
                        //AND SED.ED_XNEWNAT <> 'NC'
                    WHERE
                        SE1.%NotDel%
                        AND SE1.E1_SALDO > 0
                        AND SE1.E1_EMISSAO >= %Exp:DTOS(mv_par01)%
                        AND SE1.E1_EMISSAO <= %Exp:DTOS(mv_par02)%
                        AND SUBSTRING(SE1.E1_FILIAL, 1, 2) IN %Exp:cExprEmp%
                    UNION
                    SELECT
                        SED.ED_CODIGO AS NATUREZA,
                        SUBSTRING(SE2.E2_EMISSAO, 1, 6) AS MESANO,
                        SE2.E2_SALDO AS VALOR
                    FROM
                        %Table:SE2% SE2
                    INNER JOIN %Table:SED% SED
                    ON SE2.E2_NATUREZ = SED.ED_CODIGO
                        AND SED.%NotDel%
                        //AND SED.ED_XNEWNAT <> 'NC'
                    WHERE
                        SE2.%NotDel%
                        AND SE2.E2_SALDO > 0
                        AND SE2.E2_EMISSAO >= %Exp:DTOS(mv_par01)%
                        AND SE2.E2_EMISSAO <= %Exp:DTOS(mv_par02)%
                        AND SUBSTRING(SE2.E2_FILIAL, 1, 2) IN %Exp:cExprEmp%
                ) NAT
            GROUP BY
                NATUREZA,
                MESANO
        EndSql

        aQuery:=GetLastQuery()

        nTotReg := Contar((_FSE),"!EOF()")
        (_FSE)->(DbGoTop())

        ProcRegua(nTotReg)

        While (_FSE)->(!EOF())

            // Formatação campo natureza: 99.99.999
            // 99 - Grupo
            // 99 - Sub-Grupo
            // 999 - Item
            If !Empty((_FSE)->NATUREZA)

                SED->(dbSetOrder(1))

                cGrupo  := Substr((_FSE)->NATUREZA,1,2)
                //Pega Nome da Natureza: Grupo
                SED->(MsSeek(xFilial("SED")+cGrupo))
                cNGrupo:=AllTrim(SED->ED_DESCRIC)

                If lAnalitico
                    cSubGr  := Substr((_FSE)->NATUREZA,3,2)
                    //Pega Nome da Natureza: SubGrupo
                    SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr))
                    cNSubGr:=Alltrim(SED->ED_DESCRIC)

                    cItem   := Substr((_FSE)->NATUREZA,5,3)
                    //Pega Nome da Natureza: Item
                    SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr+cItem))
                    cNItem:=AlLTrim(SED->ED_DESCRIC)
                End
            Else
                cGrupo:="99"
                cNGrupo:="SEM NATUREZA"
                cSubGr:=""
                cItem:=""
                cNSubGr:=""
                cNItem:=""
            End
            cFlag:=cGrupo+"1"
            cCampo  := "(_FSE)->MESANO"
            cCampoT := "(_TFLX)->_"+&cCampo

            //pesquiso no temporario se existe o grupo
            (_TFLX)->(dbSetOrder(1))
            If (_TFLX)->(Dbseek(Space(02)+cGrupo))
                RecLock((_TFLX),.F.)
                &cCampoT+=(_FSE)->VALOR
            Else
                RecLock((_TFLX),.T.)
                (_TFLX)->NATGR :=cGrupo
                (_TFLX)->NOMEGR :=cNGrupo
                &cCampoT:=(_FSE)->VALOR
            End
            MsUnlock()

            If lAnalitico
                //pesquiso no temporario se existe o grupo+SubGrupo
                (_TFLX)->(dbSetOrder(2))
                If (_TFLX)->(Dbseek(Space(02)+cGrupo+cSubGr))
                    RecLock((_TFLX),.F.)
                    &cCampoT+=(_FSE)->VALOR
                Else
                    RecLock((_TFLX),.T.)
                    (_TFLX)->NATGR :=cGrupo
                    (_TFLX)->NATSG :=cSubGr
                    (_TFLX)->NOMESG :=cNSubGr
                    &cCampoT:=(_FSE)->VALOR
                End
                MsUnLock()

                //pesquiso no temporario se existe o grupo+SubGrupo+Item
                (_TFLX)->(dbSetOrder(3))
                If (_TFLX)->(Dbseek(Space(02)+cGrupo+cSubGr+cItem))
                    RecLock((_TFLX),.F.)
                    &cCampoT+=(_FSE)->VALOR
                Else
                    RecLock((_TFLX),.T.)
                    (_TFLX)->NATGR := cGrupo
                    (_TFLX)->NATSG := cSubGr
                    (_TFLX)->NATIT := cItem
                    (_TFLX)->NOMEIT := cNItem
                    &cCampoT       := (_FSE)->VALOR
                End
                MsUnLock()
            End

            (_FSE)->(dbSkip())
        End
    End

    (_FSE)->(dbCloseArea())

Return

/*/{Protheus.doc} EQFLXCMP
Gera o Fluxo Previsto Comparativo, podensdo ser ANalitico ou sintetico (so grupos) Impime Colsolidado e DFC
@type function Processmento
@version  1.00
@author mario.antonaccio
@since 10/02/2022
@param lAnalitico, logical, Indica se Imprime Analitico (.T.) ou Sintetico (.F.)
@param lConsolida, logical, Indica se Imprime Dados Consolidados (.T.) ou so Dados por Empresa (.F.)
@param lDFC, logical, Indica se Imprime Naturezas DFC (.T.) ou nao (.F.)
@return Character, Tabelas com os dados
/*/
Static Function  EQFLXCMP(lAnalitico,lConsolida,lDFC)

    Local nI

    cExprEmp := "% "+FormatIn(AllTrim(mv_par07),";")+" %"

    // Somente Concilciados
    If mv_par10 == 1
       //cConcilia:=" %"+" SE5.E5_RECONC ='x' "+" %"
       cConcilia:="% SE5.E5_RECONC ='x' %"

    Else
       cConcilia:="% SE5.E5_RECONC IN ('x',' ') %"
    End     

    //Mostra as datas ao inves dos meses
    For nI:=0 to nDifMes
        cAnoMes:=ANOMES(MonthSum(mv_par01,nI))  // Retona o NAo e o mes seguintes a data base
        AADD(aFields,{"_"+cAnoMes+"P",'N',14,2})
        AADD(aFields,{"_"+cAnoMes+"R",'N',14,2})

        //Nome do Campo
        aadd(aFieldsN,Substr(cAnoMes,5,2)+"/"+Substr(cAnoMes,1,4)+"_PRV")
        aadd(aFieldsN,Substr(cAnoMes,5,2)+"/"+Substr(cAnoMes,1,4)+"_REA")
        AADD(aDatas,cAnoMes)
    Next

    AADD(aFields,{"Total_Nat",'N',14,2})
    //Nome Campo
    AADD(aFieldsN,"Total")

    oTmpTable:=FWTemporaryTable():New((_TFLX))
    oTmpTable:SetFields(aFields)
    oTmpTable:AddIndex("01",{"FILIAL","NATGR"})
    If lAnalitico
        oTmpTable:AddIndex("02",{"FILIAL","NATGR","NATSG"})
        oTmpTable:AddIndex("03",{"FILIAL","NATGR","NATSG","NATIT"})
    End
    oTmpTable:AddIndex("04",{"FILIAL","FLAG"})
    oTmpTable:Create()

    cArqReal:="%"+oTmpTable:GetRealName()+"%"

    // Gera por empresa conforme Parametro 07
    BeginSql Alias _FSE
        SELECT
            FILIAL,
            NATUREZA,
            MESANO,
            SUM(VALORPRV) AS VALORPRV,
            SUM(VALORREA) AS VALORREA,
            TIPO,
            TIPODOC,
            PREFIXO,
            RECPAG
        FROM
            (
                SELECT
                    SUBSTRING(SE1.E1_FILIAL, 1, 2) AS FILIAL,
                    SED.ED_CODIGO AS NATUREZA,
                    SUBSTRING(SE1.E1_EMISSAO, 1, 6) AS MESANO,
                    SE1.E1_SALDO AS VALORPRV,
                    0 AS VALORREA,
                    SE1.E1_TIPO AS TIPO,
                    '  ' AS TIPODOC,
                    SE1.E1_PREFIXO  AS PREFIXO,
                    'R' AS RECPAG
                FROM
                    %Table:SE1% SE1
                INNER JOIN %Table:SED% SED
                ON SE1.E1_NATUREZ = SED.ED_CODIGO
                    AND SED.%NotDel%
                    //AND SED.ED_XNEWNAT <> 'NC'
                WHERE
                    SE1.%NotDel%
                    AND SE1.E1_SALDO > 0
                    AND SE1.E1_EMISSAO >= %Exp:DTOS(mv_par01)%
                    AND SE1.E1_EMISSAO <= %Exp:DTOS(mv_par02)%
                    AND SUBSTRING(SE1.E1_FILIAL, 1, 2) IN %Exp:cExprEmp%
                UNION
                SELECT
                    SUBSTRING(SE2.E2_FILIAL, 1, 2) AS FILIAL,
                    SED.ED_CODIGO AS NATUREZA,
                    SUBSTRING(SE2.E2_EMISSAO, 1, 6) AS MESANO,
                    SE2.E2_SALDO AS VALORPRV,
                    0 AS VALORREA,
                    SE2.E2_TIPO AS TIPO,
                    '  ' AS TIPODOC,
                    SE2.E2_PREFIXO AS PREFIXO,
                    'P' AS RECPAG
                FROM
                    %Table:SE2% SE2
                INNER JOIN %Table:SED% SED
                ON SE2.E2_NATUREZ = SED.ED_CODIGO
                    AND SED.%NotDel%
                    //AND SED.ED_XNEWNAT <> 'NC'
                WHERE
                    SE2.%NotDel%
                    AND SE2.E2_SALDO > 0
                    AND SE2.E2_EMISSAO >= %Exp:DTOS(mv_par01)%
                    AND SE2.E2_EMISSAO <= %Exp:DTOS(mv_par02)%
                    AND SUBSTRING(SE2.E2_FILIAL, 1, 2) IN %Exp:cExprEmp%
                UNION
                SELECT
                    SUBSTRING(SE5.E5_FILIAL, 1, 2) AS FILIAL,
                    SED.ED_CODIGO AS NATUREZA,
                    SUBSTRING(SE5.E5_DTDISPO, 1, 6) AS MESANO,
                    0 AS VALOPRV,
                    SE5.E5_VALOR - SE5.E5_VLJUROS - SE5.E5_VLMULTA + SE5.E5_VLDESCO AS VALORREA,
                    SE5.E5_TIPO AS TIPO,
                    SE5.E5_TIPODOC AS TIPODOC,
                    SE5.E5_PREFIXO AS PREFIXO,
                    SE5.E5_RECPAG AS RECPAG
                FROM
                    %Table:SE5% SE5
                INNER JOIN %Table:SED% SED
                ON SE5.E5_NATUREZ = SED.ED_CODIGO
                    AND SED.%NotDel%
                    //AND SED.ED_XNEWNAT <> 'NC'
                WHERE
                    SE5.%NotDel%
                    AND SE5.E5_DTDISPO >= %Exp:DTOS(mv_par01)%
                    AND SE5.E5_DTDISPO <= %Exp:DTOS(mv_par02)%
                    AND SUBSTRING(SE5.E5_FILIAL, 1, 2) IN %Exp:cExprEmp%
                    //AND SE5.E5_MOEDA <> 'TB'
                    AND SE5.E5_SITUACA = ' '
                    AND SE5.E5_MOTBX IN ('DEB', 'NOR', '  ')
            ) NAT
        GROUP BY
            FILIAL,
            NATUREZA,
            MESANO,
            TIPO,
            TIPODOC,
            PREFIXO,
            RECPAG
    EndSql

    aQuery:=GetLastQuery()

    nTotReg := Contar((_FSE),"!EOF()")
    (_FSE)->(DbGoTop())

    ProcRegua(nTotReg)

    While (_FSE)->(!EOF())

        // Formatação campo natureza: 9.99.999
        // 99 - Grupo
        // 99 - Sub-Grupo
        // 999 - Item
        cNatureza:=REGRANAT((_FSE)->NATUREZA,(_FSE)->TIPO,(_FSE)->TIPODOC,(_FSE)->RECPAG,(_FSE)->PREFIXO)

        If !Empty(cNatureza)


            SED->(dbSetOrder(1))

            cGrupo  := Substr(cNatureza,1,2)
            //Pega Nome da Natureza: Grupo
            SED->(MsSeek(xFilial("SED")+cGrupo))
            cNGrupo:=AllTrim(SED->ED_DESCRIC)
            If lAnalitico
                cSubGr  := Substr(cNatureza,3,2)
                //Pega Nome da Natureza: SubGrupo
                SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr))
                cNSubGr:=Alltrim(SED->ED_DESCRIC)

                cItem   := Substr(cNatureza,5,3)
                //Pega Nome da Natureza: Item
                SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr+cItem))
                cNItem:=AlLTrim(SED->ED_DESCRIC)
            End
        Else
            cGrupo:="99"
            cNGrupo:="SEM NATUREZA"
            cSubGr:=""
            cItem:=""
            cNSubGr:=""
            cNItem:=""
        End

        cCampo  := "(_FSE)->MESANO"
        cCampoT1 := "(_TFLX)->_"+&cCampo+"P"
        cCampoT2 := "(_TFLX)->_"+&cCampo+"R"

        //pesquiso no temporario se existe o Filial+grupo
        (_TFLX)->(dbSetOrder(1))
        If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo))
            RecLock((_TFLX),.F.)
            &cCampoT1+=(_FSE)->VALORPRV
            &cCampoT2+=(_FSE)->VALORREA
        Else
            RecLock((_TFLX),.T.)
            (_TFLX)->FILIAL:= (_FSE)->FILIAL
            (_TFLX)->NATGR :=cGrupo
            (_TFLX)->NOMEGR :=cNGrupo
            &cCampoT1:=(_FSE)->VALORPRV
            &cCampoT2:=(_FSE)->VALORREA
        End
        MsUnlock()

        If lAnalitico
            //pesquiso no temporario se existe o Filial+grupo+SubGrupo
            (_TFLX)->(dbSetOrder(2))
            If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo+cSubGr))
                RecLock((_TFLX),.F.)
                &cCampoT1+=(_FSE)->VALORPRV
                &cCampoT2+=(_FSE)->VALORREA
            Else
                RecLock((_TFLX),.T.)
                (_TFLX)->FILIAL:= (_FSE)->FILIAL
                (_TFLX)->NATGR :=cGrupo
                (_TFLX)->NATSG :=cSubGr
                (_TFLX)->NOMESG :=cNSubGr
                &cCampoT1=(_FSE)->VALORPRV
                &cCampoT2:=(_FSE)->VALORREA
            End
            MsUnLock()

            //pesquiso no temporario se existe o Filial+grupo+SubGrupo+Item
            (_TFLX)->(dbSetOrder(3))
            If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo+cSubGr+cItem))
                RecLock((_TFLX),.F.)
                &cCampoT1+=(_FSE)->VALORPRV
                &cCampoT2+=(_FSE)->VALORREA
            Else
                RecLock((_TFLX),.T.)
                (_TFLX)->FILIAL:= (_FSE)->FILIAL
                (_TFLX)->NATGR := cGrupo
                (_TFLX)->NATSG := cSubGr
                (_TFLX)->NATIT := cItem
                (_TFLX)->NOMEIT := cNItem
                &cCampoT1       := (_FSE)->VALORPRV
                &cCampoT2      := (_FSE)->VALORREA
            End
            MsUnLock()
        End

        (_FSE)->(dbSkip())

    End

    (_FSE)->(dbCloseArea())

    // Consolidada
    If lConsolida

        BeginSql Alias _FSE
            SELECT
                NATUREZA,
                MESANO,
                SUM(VALORPRV) AS VALORPRV,
                SUM(VALORREA) AS VALORREA,
                TIPO,
                TIPODOC,
                PREFIXO,
                RECPAG
            FROM
                (
                    SELECT
                        SED.ED_CODIGO as NATUREZA,
                        SUBSTRING(SE1.E1_EMISSAO, 1, 6) AS MESANO,
                        SE1.E1_SALDO AS VALORPRV,
                        0 as VALORREA,
                        SE1.E1_TIPO AS TIPO,
                        ' ' As TIPODOC,
                        SE1.E1_PREFIXO AS PREFIXO,
                        'R' AS RECPAG
                    FROM
                        %Table:SE1% SE1
                    INNER JOIN %Table:SED% SED
                    ON SE1.E1_NATUREZ = SED.ED_CODIGO
                        AND SED.%NotDel%
                        //AND SED.ED_XNEWNAT <> 'NC'
                    WHERE
                        SE1.%NotDel%
                        AND SE1.E1_SALDO > 0
                        AND SE1.E1_EMISSAO >= %Exp:DTOS(mv_par01)%
                        AND SE1.E1_EMISSAO <= %Exp:DTOS(mv_par02)%
                        AND SUBSTRING(SE1.E1_FILIAL, 1, 2) IN %Exp:cExprEmp%
                    UNION
                    SELECT
                        SED.ED_CODIGO AS NATUREZA,
                        SUBSTRING(SE2.E2_EMISSAO, 1, 6) AS MESANO,
                        SE2.E2_SALDO AS VALORPRV,
                        0 AS VALORREA,
                        SE2.E2_TIPO AS TIPO,
                        ' ' AS TIPODOC,
                        SE2.E2_PREFIXO PREFIXO,
                        'P' AS RECPAG
                    FROM
                        %Table:SE2% SE2
                    INNER JOIN %Table:SED% SED
                    ON SE2.E2_NATUREZ = SED.ED_CODIGO
                        AND SED.%NotDel%
                        //AND SED.ED_XNEWNAT <> 'NC'
                    WHERE
                        SE2.%NotDel%
                        AND SE2.E2_SALDO > 0
                        AND SE2.E2_EMISSAO >= %Exp:DTOS(mv_par01)%
                        AND SE2.E2_EMISSAO <= %Exp:DTOS(mv_par02)%
                        AND SUBSTRING(SE2.E2_FILIAL, 1, 2) IN %Exp:cExprEmp%
                    UNION
                    SELECT
                        SED.ED_CODIGO AS NATUREZA,
                        SUBSTRING(SE5.E5_DTDISPO, 1, 6) AS MESANO,
                        0 as VALOPRV,
                        SE5.E5_VALOR AS VALORREA,
                        SE5.E5_TIPO AS TIPO,
                        SE5.E5_TIPODOC AS TIPODOC,
                        SE5.E5_PREFIXO AS PREFIXO,
                        SE5.E5_RECPAG AS RECPAG
                    FROM
                        %Table:SE5% SE5
                    INNER JOIN %Table:SED% SED
                    ON SE5.E5_NATUREZ = SED.ED_CODIGO
                        AND SED.%NotDel%
                        //AND SED.ED_XNEWNAT <> 'NC'
                    WHERE
                        SE5.%NotDel%
                        AND SE5.E5_DTDISPO >= %Exp:DTOS(mv_par01)%
                        AND SE5.E5_DTDISPO <= %Exp:DTOS(mv_par02)%
                        AND SUBSTRING(SE5.E5_FILIAL, 1, 2) IN %Exp:cExprEmp%
                        //AND SE5.E5_MOEDA <> 'TB'
                        AND SE5.E5_SITUACA = ' '
                        AND SE5.E5_MOTBX IN ('DEB', 'NOR', '  ')
                ) NAT
            GROUP BY
                NATUREZA,
                MESANO,
                TIPO,
                TIPODOC,
                PREFIXO,
                RECPAG
        EndSql

        aQuery:=GetLastQuery()

        nTotReg := Contar((_FSE),"!EOF()")
        (_FSE)->(DbGoTop())

        ProcRegua(nTotReg)

        While (_FSE)->(!EOF())

            // Formatação campo natureza: 9.99.999
            // 9 - Grupo
            // 99 - Sub-Grupo
            // 999 - Item
            cNatureza:=REGRANAT((_FSE)->NATUREZA,(_FSE)->TIPO,(_FSE)->TIPODOC,(_FSE)->RECPAG,(_FSE)->PREFIXO)

            If !Empty(cNatureza)

                SED->(dbSetOrder(1))

                cGrupo  := Substr(cNatureza,1,2)
                //Pega Nome da Natureza: Grupo
                SED->(MsSeek(xFilial("SED")+cGrupo))
                cNGrupo:=AllTrim(SED->ED_DESCRIC)

                If lAnalitico
                    cSubGr  := Substr(cNatureza,3,2)
                    //Pega Nome da Natureza: SubGrupo
                    SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr))
                    cNSubGr:=Alltrim(SED->ED_DESCRIC)

                    cItem   := Substr(cNatureza,5,3)
                    //Pega Nome da Natureza: Item
                    SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr+cItem))
                    cNItem:=AlLTrim(SED->ED_DESCRIC)
                End
            Else
                cGrupo:="99"
                cNGrupo:="SEM NATUREZA"
                cSubGr:=""
                cItem:=""
                cNSubGr:=""
                cNItem:=""
            End

            cCampo1  := "(_FSE)->MESANOP"
            cCampo2  := "(_FSE)->MESANOR"
            cCampoT1 := "(_TFLX)->_"+&cCampo+"P"
            cCampoT2 := "(_TFLX)->_"+&cCampo+"R"

            //pesquiso no temporario se existe o grupo
            (_TFLX)->(dbSetOrder(1))
            If (_TFLX)->(Dbseek(Space(02)+cGrupo))
                RecLock((_TFLX),.F.)
                &cCampoT1 += (_FSE)->VALORPRV
                &cCampoT2 += (_FSE)->VALORREA
            Else
                RecLock((_TFLX),.T.)
                (_TFLX)->NATGR  := cGrupo
                (_TFLX)->NOMEGR := cNGrupo
                &cCampoT1       := (_FSE)->VALORPRV
                &cCampoT2       := (_FSE)->VALORREA
            End
            MsUnlock()

            If lAnalitico
                //pesquiso no temporario se existe o grupo+SubGrupo
                (_TFLX)->(dbSetOrder(2))
                If (_TFLX)->(Dbseek(Space(02)+cGrupo+cSubGr))
                    RecLock((_TFLX),.F.)
                    &cCampoT1+=(_FSE)->VALORPRV
                    &cCampoT2+=(_FSE)->VALORREA
                Else
                    RecLock((_TFLX),.T.)
                    (_TFLX)->NATGR  := cGrupo
                    (_TFLX)->NATSG  := cSubGr
                    (_TFLX)->NOMESG := cNSubGr
                    &cCampoT1        := (_FSE)->VALORPRV
                    &cCampoT2        := (_FSE)->VALORREA
                End
                MsUnLock()

                //pesquiso no temporario se existe o grupo+SubGrupo+Item
                (_TFLX)->(dbSetOrder(3))
                If (_TFLX)->(Dbseek(Space(02)+cGrupo+cSubGr+cItem))
                    RecLock((_TFLX),.F.)
                    &cCampoT1+=(_FSE)->VALORPRV
                    &cCampoT2+=(_FSE)->VALORREA
                Else
                    RecLock((_TFLX),.T.)
                    (_TFLX)->NATGR  := cGrupo
                    (_TFLX)->NATSG  := cSubGr
                    (_TFLX)->NATIT  := cItem
                    (_TFLX)->NOMEIT := cNItem
                    &cCampoT1        := (_FSE)->VALORPRV
                    &cCampoT2        := (_FSE)->VALORREA
                End
                MsUnLock()
            End
            (_FSE)->(dbSkip())

        End
    End
    (_FSE)->(dbCloseArea())

Return

/*/{Protheus.doc} EQFLXEXC
Gera Planilha EXCEL do fluxos contemplando analitico Consolidado e DFC
@type function Processmento
@version  1.00
@author mario.antonaccio
@since 10/02/2022
@param lAnalitico, logical, Indica se Imprime Analitico (.T.) ou Sintetico (.F.)
@param lConsolida, logical, Indica se Imprime Dados Consolidados (.T.) ou so Dados por Empresa (.F.)
@param lDFC, logical, Indica se Imprime Naturezas DFC (.T.) ou nao (.F.)
@return Character, Tabelas com os dados
/*/
Static Function  EQFLXEXC(lAnalitico,lConsolida,lDFC)

    Local aLinhaAux := {}
    Local aPergunte := {}
    Local cArqDst   := "C:\TOTVS\EQFLX"
    Local cCampos   := " "
    Local cNomeFil  := " "
    Local cTitPla   := "Fluxo - "
    Local lAbre     := .F.
    Local nCampos   := 0
    Local nI        := 0
    Local nJ        := 0
    Local nTotReg   := 0

    //Deixa a planilha  sen o azul no corpo
    oExcel:SetLineFrColor("#000000")
    oExcel:SetLineBgColor("#FFFFFF")
    oExcel:Set2LineFrColor("#000000")
    oExcel:Set2LineBgColor("#FFFFFF")

    //Indica quais campos entrarao na montaem do EXCEL
    cCampos:="%"
    For nI:=2 to Len(aFields)
        cCampos+=aFields[nI,1]+If(nI==Len(afIelds),"",",")
        nCampos++
    Next
    cCampos+="%"

    If Mv_par05 == 1
        cTitPla+="Previsto"
        cArqDst+="PRV_"+ Dtos(dDataBase) + Str(Seconds(),5,0) + ".XML"
    ElseIf Mv_par05 == 2
        cTitPla+="Realizado"
        cArqDst+="REA_"+ Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
    ElseIf Mv_par05 == 3
        cTitPla+="Comparativo"
        cArqDst+="CMP_"+ Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
    ElseIf Mv_par05 == 4
        cTitPla+="Diario Previsto"
        cArqDst+="DIA_PRV_"+ Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
    ElseIf Mv_par05 == 5
        cTitPla+="Diario Realizado"
        cArqDst+="DIA_REA_"+ Dtos(dDataBase) + Str(Seconds(),5,0) + ".XML"
    End

    cTitPla+= If(mv_par06 == 1," - Analitico"," - Sintetico")

    For nJ:=1 To Len(aFilial)

        cNomeFil=If(Empty(aFilial[nJ]),"Consolidado",AllTrim(FWFilialName(cEmpAnt,aFilial[nJ],1)))

        oExcel:AddworkSheet(cNomeFil)
        oExcel:AddTable(cNomeFil, cTitPla)

        If SELECT(_TMP) > 0
            (_TMP)->(dbCloseArea())
        End

        cOrder:="%"
        If mv_par06==1 // Analitico
            cOrder+="FILIAL,FLAG ,NATGR,NATSG,NATIT "
        Else
            cOrder+="FILIAL,FLAG ,NATGR"
        End
        cOrder+="%"

        BeginSql Alias _TMP
            SELECT
                %Exp:cCampos%
            FROM
                %Exp:cArqReal%
            WHERE
                FILIAL = %Exp:aFilial[nJ]%
            ORDER BY
                %Exp:cOrder%
        EndSql

        //Monta Excel Dinamico conforme os campos selecionados
        For nI := 1 To nCampos
            If aFields[nI+1,2] == "C"
                oExcel:AddColumn(cNomeFil, cTitPla, aFieldsN[nI+1], 1, 1, .F.)
            ElseIf aFields[nI+1,2] == "N"
                oExcel:AddColumn(cNomeFil, cTitPla, aFieldsN[nI+1], 3, 2, .F.,,"@ER 999.999.999")
            End
        Next

        nTotReg := Contar((_TMP),"!EOF()")
        (_TMP)->(DbGoTop())

        ProcRegua(nTotReg)

        While (_TMP)->(!EOF())

            IncProc()

            lAbre:=.T.

            //Carrega array auxiiar para carregar planilha
            aLinhaAux:={}
            For nI := 1 To (_TMP)->(FCOUNT()) //nCampos
                //If VALTYPE((_TFLX)->(FIELDGET(nI)))=="N"
                //     AADD(aLinhaAux, ABS((_TMP)->(FieldGet(nI))))
                // Else
                AADD(aLinhaAux, (_TMP)->(FieldGet(nI)))
                // End
            Next

            //Nudança de Cor na linha???????
            /*
            If "Saldo" $ (_TMP)->NOMEGR  .or. "Endividamento" $ (_TMP)->NOMEGR
                oExcel:SetCelFrColor("#FFFFFF")
                oExcel:SetCelBgColor("#708090")
            Else
                oExcel:SetCelBgColor("#FFFFFF")
                oExcel:SetCelFrColor("#000000")
            End
            */

            oExcel:AddRow(cNomeFil, cTitPla,aLinhaAux)

            (_TMP)->(dbSkip())

        End

    Next nJ
    //Fim Fluxo
    (_TMP)->(dbCloseArea())

    lDFC:=.F.
    If lDFC
    End

    // ABA de Parametros
    oObj:AddGroup(cPerg)
    oObj:SearchGroup()
    aPergunte := oObj:GetGroup(cPerg)

    oExcel:AddworkSheet("Parametros")
    oExcel:AddTable ("Parametros","Definicoes")

    oExcel:AddColumn("Parametros","Definicoes","Ordem",1,1)
    oExcel:AddColumn("Parametros","Definicoes","Pergunta",1,1)
    oExcel:AddColumn("Parametros","Definicoes","Resposta",1,1)

    For nI:=1 to Len(aPergunte[2])
        If aPergunte[2][nI]:CX1_TIPO == "D"
            cVar:=DTOC(&(aPergunte[2][nI]:CX1_VAR01))
        ElseIf aPergunte[2][nI]:CX1_TIPO == "N"
            If aPergunte[2][nI]:CX1_GSC=="G"
                cVar:=Transform(&(aPergunte[2][nI]:CX1_VAR01),"@ER 999,999,99.99")
            ElseIf aPergunte[2][nI]:CX1_GSC=="C"
                cVar:=&("aPergunte[2][nI]:CX1_DEF"+StrZero(&(aPergunte[2][nI]:CX1_VAR01),2,0))
            End
        Else
            cVar:=&(aPergunte[2][nI]:CX1_VAR01)
        End
        oExcel:AddRow("Parametros","Definicoes",{aPergunte[2][nI]:CX1_ORDEM,RTRIM(aPergunte[2][nI]:CX1_PERGUNT),cVar})
    Next

    If lAbre
        oExcel:Activate()
        oExcel:GetXMLFile(cArqDst)
        OPENXML(cArqDst)
        oExcel:DeActivate()
    Else
        MsgInfo("Nao existem dados para serem impressos.", "SEM DADOS")
    EndIf

Return

/*/{Protheus.doc} OPENXML
Abertura do arquivo XML Gerado
@type function Files
@version  1.00
@author mario.antonaccio
@since 16/12/2021
@param cArq, character, Nome do Arquivo XML
@return character, sem retorno
/*/
Static Function OPENXML(cArq)

    If !ApOleClient("MsExcel")
        Aviso("Atencao", "O Microsoft Excel nao esta instalado.", {"Ok"}, 2)
    Else
        oExcelApp := MsExcel():New()
        oExcelApp:WorkBooks:Open(cArq)
        oExcelApp:SetVisible(.T.)
        oExcelApp:Destroy()
    EndIf

Return

/*/{Protheus.doc} EQFLXST - REALIZADO TOTALIZADO
Rotina de geração de subtottais para a planilha
@type function processameno
@version  1.00
@author mario.antonaccio
@since 21/02/2022
@return vCHaracter, sem retorno especifico
/*/
Static Function EQFLXST(lAnalitico,lConsolida,lDFC)

    Local aNSubTot := {}
    Local aSemNat  := {}
    Local nTotDespBanc      := 0 // Soma Receitas despesas Bancarias
    Local nTotEndvBanc      := 0 // Soma Endividamento Bancario
    Local nI
    Local nJ
    Local nTotPagament      := 0 // Soma Pagamentos
    Local nTotRecebime      := 0 // Soma Recebimentos
    Local nSldFinalBai      := 0 // Saldo FInal Caixa
    Local nSldInicial       := 0 // SAldos Iniciais
    Local nSldCaixa         := 0 // Saldo de Caixa
    Local nSomaLin := 0
    Local nX
    Local cExpr
    Local dDiaIni
    Local dDiaFim
    Local nSaldo:=0

    cExprEmp := "% "+FormatIn(AllTrim(mv_par07),";")+" %"

    //Nome Subtotais
    AADD(aNSubTot,{"111","Saldos Recebimentos"})
    AADD(aNSubTot,{"211","Saldos Pagamentos"})
    AADD(aNSubTot,{"311","Saldo de Caixa"})
    AADD(aNSubTot,{"X11","Saldo Final de Caixa"})

    //   AADD(aNSubTot,{"611","Endividamento Bancario"})
    //    AADD(aNSubTot,{"711","Receitas/Despesas Banco"})

    // Atualiza flag de indexação
    (_TFLX)->(dbGoTop())
    While (_TFLX)->(!EOF())

        For nI:=nInicio To Len(aFields)
            nSomaLin+=(_TFLX)->(FieldGet(nI))
        Next

        RecLock((_TFLX),.F.)
        If AllTrim((_TFLX)->NATGR) $ "01"            //Recebimentos
            (_TFLX)->FLAG:="11"
        ElseIf AllTrim((_TFLX)->NATGR) $  "02/03/04" //Pagamentos
            (_TFLX)->FLAG:="21"
        ElseIf AllTrim((_TFLX)->NATGR) $  "05" // Emprestimos Bancarios
            (_TFLX)->FLAG:="51"
        ElseIf AllTrim((_TFLX)->NATGR) $  "06" // Pagamneto emprestimos
            (_TFLX)->FLAG:="52"
        ElseIf AllTrim((_TFLX)->NATGR) $  "07" //Despesas Financeiras
            (_TFLX)->FLAG:="71"
        ElseIf AllTrim((_TFLX)->NATGR) $  "08" //Receitas Financeiras NOVO
            (_TFLX)->FLAG:="72"
        ElseIf AllTrim((_TFLX)->NATGR) $  "09" //Capitalizacao Investimentos NOVO
            (_TFLX)->FLAG:="73"
        ElseIf AllTrim((_TFLX)->NATGR) $  "10" //Resgate Capitalizaçao NOVO
            (_TFLX)->FLAG:="74"
        ElseIf AllTrim((_TFLX)->NATGR) $  "11" //Transferencias NOVO
            (_TFLX)->FLAG:="75"
        //ElseIf AllTrim((_TFLX)->NATGR) $  "15" //Outros NOVO
        //    (_TFLX)->FLAG:="76"            
        Else  //Outros
            (_TFLX)->FLAG:="ZZ"
        End

        (_TFLX)->(FieldPut(Len(aFields),nSomaLin))
        MsUnlock()
        nSomaLin:=0
        (_TFLX)->(dbSkip())
    End

    //--------------------------------------------------------------------
    //Como é mensal , entao pega o saldo do ultimo dia do mes anterior
    // -------------------------------------------------------------------
    // A rotina abaixo tem como objetivo pegar o saldo final do dia 
    // anterior a primeira da do filtro definido pelo usuário.
    //
    // --> ROTINA PREWCISA DE REVISAO
    //
    //--------------------------------------------------------------------
    dDiaFim:=mv_par01 -1
    dDiaIni:=FirstDate(dDiaFim)

    //dDiaFim:=mv_par01
    //dDiaIni:=mv_par02
    //dUltSld:=mv_par01 - 1

    //cFilConta:="% SE5.E5_CONTA ='"+mv_par11+"' %"

    cFilConta := StrTran(cFilConta, "SE5.E5_CONTA", "SA6.A6_NUMCON")


    //--===========================================================================
    //-- SOMAR OS SALDOS BANCARIOS DE TODAS AS CONTAS NUM DETERMINADO PERIODO
    //--===========================================================================
    BeginSql Alias _SE8

        SELECT A6_FILIAL AS FILIAL, 
               SUM(SALDO)  AS  VALOR 

          FROM ( 
                SELECT A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON, A6_NOME,

                        ISNULL((SELECT TOP 1 E8_SALATUA
                                FROM %Table:SE8%  SE8
                                WHERE E8_DTSALAT BETWEEN  %Exp:DTOS(dDiaIni)% AND  %Exp:DTOS(dDiaFim)% 
                                  AND SUBSTRING (E8_FILIAL, 1, 2) = SUBSTRING (A6_FILIAL, 1, 2) 
                                  AND E8_BANCO   = A6_COD
                                  AND E8_AGENCIA = A6_AGENCIA
                                  AND E8_CONTA   = A6_NUMCON
                                  AND SE8.%NotDel% 
                                ORDER BY E8_BANCO ASC, E8_AGENCIA ASC, E8_CONTA ASC, E8_DTSALAT DESC), 0) AS SALDO

                  FROM %Table:SA6% SA6
                 WHERE SA6.%NotDel% 
                   AND SUBSTRING(SA6.A6_FILIAL, 1, 2) IN %Exp:cExprEmp%   
                   AND %Exp:cFilConta%             
                   AND A6_FLUXCAI = 'S'
                ) QRY

          GROUP BY A6_FILIAL
          ORDER BY A6_FILIAL
    ENDSQL
    aQuery:=GetLastQuery()


/*
    BeginSql Alias _SE8
        SELECT
            FILIAL,
            SUM(VALOR) AS VALOR
        FROM
            (
                SELECT
                    SUBSTRING (SE8.E8_FILIAL, 1, 2) AS FILIAL,
                    (
                        SELECT
                            SE81.E8_SALATUA
                        FROM
                            %Table:SE8% SE81
                        WHERE
                            SE81.%NotDel%
                            AND SUBSTRING (SE81.E8_FILIAL, 1, 2) = SUBSTRING (SE8.E8_FILIAL, 1, 2)
                            AND SE81.E8_DTSALAT = MAX(SE8.E8_DTSALAT)
                            AND SE81.E8_BANCO = SE8.E8_BANCO
                            AND SE81.E8_AGENCIA = SE8.E8_AGENCIA
                            AND SE81.E8_CONTA = SE8.E8_CONTA
                    ) VALOR
                FROM
                    %Table:SE8% SE8

                    INNER JOIN %Table:SA6% SA6 
                            ON SE8.%NotDel%
                           AND SUBSTRING(A6_FILIAL, 1, 2) = SUBSTRING (SE8.E8_FILIAL, 1, 2)
                           AND A6_COD     = SE8.E8_BANCO
                           AND A6_AGENCIA = SE8.E8_AGENCIA 
                           AND A6_NUMCON  = SE8.E8_CONTA
                           AND A6_FLUXCAI = 'S'
                           
                WHERE
                    SE8.%NotDel%
                    AND SUBSTRING(SE8.E8_FILIAL, 1, 2) IN %Exp:cExprEmp%
                    AND SE8.E8_DTSALAT >= %Exp:DTOS(dDiaIni)%
                    AND SE8.E8_DTSALAT <= %Exp:DTOS(dDiaFim)%

                GROUP BY
                    SUBSTRING (SE8.E8_FILIAL, 1, 2),
                    SE8.E8_BANCO,
                    SE8.E8_AGENCIA,
                    SE8.E8_CONTA
            ) SALDO
        GROUP BY
            FILIAL
    ENDSQL
    aQuery:=GetLastQuery()
*/
    //Grava ARRAY DE SALDO
    aSaldo:={}
    nSaldo:=0

    While (_SE8)->(!EOF())
        AADD(aSaldo,{(_SE8)->FILIAL,(_SE8)->VALOR})
        nSaldo+=(_SE8)->VALOR
        (_SE8)->(dbSkip())
    End
    AADD(aSaldo,{" ",nSaldo})

    //Crio Linhas  de Saldo Incial
    For nI:=1 to Len(aFilial)
        nPos:=Ascan(aSaldo,{|x| AllTrim(x[1])==Alltrim(aFILIAL[nI])})

        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="000"
        (_TFLX)->NOMEGR:="Saldos Iniciais"

        If nPos > 0
            (_TFLX)->(FieldPut(nInicio,aSaldo[nPos,2]))
        End
        MsUnLock()
    Next
    //Fim Saldo Bancario

    //Adiciono Registro para Gravação de SubTotal no arquivo temporario.
    For nI:=1 To Len(aFilial)
        For nJ:=1 To Len(aNSubTot)
            RecLock((_TFLX),.T.)
            (_TFLX)->FILIAL := aFilial[nI]
            (_TFLX)->FLAG   := aNSubTot[nJ,1]
            (_TFLX)->NOMEGR := aNSubTot[nJ,2]
            MsUnLock()
        Next nJ
    Next nI


    // Calculo SubTot
    For nX:=1 to Len(aFilial)

        nTotDespBanc := 0 // Soma Receitas despesas Bancarias
        nTotEndvBanc := 0 // Soma Endividamento Bancario
        nTotPagament := 0 // Soma Pagamentos
        nTotRecebime := 0 // Soma Recebimentos
        nSldFinalBai := 0 // Saldo FInal Caixa
        nSldInicial  := 0 // Saldos Iniciais
        nSldCaixa    := 0 // Saldo de Caixa

        For nI:=nInicio To Len(aFields)-1
            cCampo:="%"+aFields[nI,1]+"%"
            cExpr:="%FILIAL = '"+aFilial[nX]+If(mv_par06==1,"' AND NATSG=' '","'")+"%"
            If SELECT((_TMP)) > 0
                (_TMP)->(dbCloseArea())
            End

            BeginSql Alias _TMP
                SELECT
                    FLAG,
                    SUM(%Exp:cCampo%)
                FROM
                    %Exp:cArqReal%
                WHERE
                    FLAG NOT IN ('99') // 99 IU ZZ ???
                    AND LEN(FLAG) = 2
                    AND %Exp:cExpr%
                GROUP BY
                    FLAG
            EndSql

            cQuery:=GetLastQuery()

            nTotRecebime:=0
            nTotPagament:=0
            nSldCaixa   :=0
            nTotEndvBanc:=0
            nTotDespBanc:=0

            // Pego Saldo Icicial
            If nSldFinalBai == 0  // Primeira Coluna
                nPos:=Ascan(aSaldo,{|x| AllTrim(x[1])==Alltrim(aFILIAL[nX])})

                If nPos > 0
                    nSldInicial:=aSaldo[nPos,2]
                Else
                    nSldInicial:=0
                End
            Else
                nSldInicial:=nSldFinalBai
            EndIF 

            // Atualiza variaveis de totalização
            While (_TMP)->(!EOF())
                If AllTrim((_TMP)->FLAG) == "11"
                    nTotRecebime+=(_TMP)->(FieldGet(2))

                ElseIf AllTrim((_TMP)->FLAG) == "21"
                    nTotPagament+=(_TMP)->(FieldGet(2))

                ElseIf AllTrim((_TMP)->FLAG) == "51"
                    nTotEndvBanc+=(_TMP)->(FieldGet(2))

                ElseIf AllTrim((_TMP)->FLAG) == "52"
                    nTotEndvBanc-=(_TMP)->(FieldGet(2))

                ElseIf AllTrim((_TMP)->FLAG) == "71"
                    nTotDespBanc-=(_TMP)->(FieldGet(2))

                ElseIf AllTrim((_TMP)->FLAG) == "72"
                    nTotDespBanc+=(_TMP)->(FieldGet(2))
                    
                ElseIf AllTrim((_TMP)->FLAG) == "73"
                    nTotDespBanc-=(_TMP)->(FieldGet(2))

                ElseIf AllTrim((_TMP)->FLAG) == "74"
                    nTotDespBanc+=(_TMP)->(FieldGet(2))

                ElseIf AllTrim((_TMP)->FLAG) == "75" // NOVO - Transferencias
                    nTotDespBanc+=(_TMP)->(FieldGet(2))

                //ElseIf AllTrim((_TMP)->FLAG) == "76" // NOVO - Outros
                //    nTotDespBanc+=(_TMP)->(FieldGet(2))                    
                Else
                    xpto := 0
                Endif

                nSldCaixa:=nSldInicial+nTotRecebime-nTotPagament
                nSldFinalBai:=nSldCaixa+nTotEndvBanc+nTotDespBanc
                (_TMP)->(dbSkip())
            End
            (_TMP)->(dbCloseArea())

            //Grava Subtotais
            (_TFLX)->(dbSetOrder(If(lAnalitico,4,2)))

            //SAldos Inciais
            (_TFLX)->(MsSeek(aFilial[nX]+"000"))
            RecLock((_TFLX),.F.)
            (_TFLX)->(FIELDPUT(nI,nSldInicial))
            MsUnLock()

            //Grava Registro de Saldos Recebimentos
            (_TFLX)->(MsSeek(aFilial[nX]+"111"))
            RecLock((_TFLX),.F.)
            (_TFLX)->(FIELDPUT(nI,nTotRecebime))
            MsUnLock()

            //Grava Registro de Saldos Pagamentos
            (_TFLX)->(MsSeek(aFilial[nX]+"211"))
            RecLock((_TFLX),.F.)
            (_TFLX)->(FIELDPUT(nI,nTotPagament))
            MsUnLock()

            //Grava Registro de Saldos Caixa Incial
            (_TFLX)->(MsSeek(aFilial[nX]+"311"))
            RecLock((_TFLX),.F.)
            (_TFLX)->(FIELDPUT(nI,nSldCaixa))
            MsUnLock()

            /*
            //Grava Registro de Endividamento Bancario
            (_TFLX)->(MsSeek(aFilial[nX]+"611"))
            RecLock((_TFLX),.F.)
            (_TFLX)->(FIELDPUT(nI,nTotEndvBanc))
            MsUnLock()

              //Grava Registro de Despeas/Receitas Bancarias
            (_TFLX)->(MsSeek(aFilial[nX]+"711"))
            RecLock((_TFLX),.F.)
            (_TFLX)->(FIELDPUT(nI,nTotDespBanc))
            MsUnLock()
            */

            //Grava Registro de Saldos Caixa Final
            (_TFLX)->(MsSeek(aFilial[nX]+"X11"))
            RecLock((_TFLX),.F.)
            (_TFLX)->(FIELDPUT(nI,nSldFinalBai))
            MsUnLock()

            nTotRecebime:=0
            nTotPagament:=0
            nSldCaixa:=0
            nTotEndvBanc:=0
            nTotDespBanc:=0
        Next nI
    Next nX

    // Tratamento para a Ultima coluna por ser um resumo geral

    For nX:=1 to Len(aFilial)
        nUltCol:=Len(aFields)
        cCampo:="%"+aFields[nUltCol,1]+"%"
        cExpr:="%FILIAL = '"+aFilial[nX]+If(mv_par06==1,"' AND NATSG=' '","'")+"%"
        If SELECT((_TMP)) > 0
            (_TMP)->(dbCloseArea())
        End

        BeginSql Alias _TMP
            SELECT
                FLAG,
                SUM(%Exp:cCampo%)
            FROM
                %Exp:cArqReal%
            WHERE
                FLAG NOT IN ('01')
                AND LEN(FLAG) = 2
                AND %Exp:cExpr%
            GROUP BY
                FLAG
        EndSql

        aQuery:=GetLastQuery()        

        nSldFinalBai:=0
        nTotRecebime:=0
        nTotPagament:=0
        nSldCaixa:=0
        nTotEndvBanc:=0
        nTotDespBanc:=0

        If nSldFinalBai == 0  // Primeira Coluna
            nPos:=Ascan(aSaldo,{|x| AllTrim(x[1])==Alltrim(aFILIAL[nX])})
            If nPos > 0
                nSldInicial:=aSaldo[nPos,2]
            Else
                nSldInicial:=0
            End
        Else
            nSldInicial:=nSldFinalBai
        End

        //Soma SubTotal
        While (_TMP)->(!EOF())
            If AllTrim((_TMP)->FLAG) == "11"
                nTotRecebime+=(_TMP)->(FieldGet(2))
            ElseIf AllTrim((_TMP)->FLAG) == "21"
                nTotPagament+=(_TMP)->(FieldGet(2))
            ElseIf AllTrim((_TMP)->FLAG) == "51"
                nTotEndvBanc+=(_TMP)->(FieldGet(2))
            ElseIf AllTrim((_TMP)->FLAG) == "52"
                nTotEndvBanc-=(_TMP)->(FieldGet(2))
            ElseIf AllTrim((_TMP)->FLAG) == "71"
                nTotDespBanc-=(_TMP)->(FieldGet(2))
            ElseIf AllTrim((_TMP)->FLAG) == "72"
                nTotDespBanc+=(_TMP)->(FieldGet(2))
            ElseIf AllTrim((_TMP)->FLAG) == "73"
                nTotDespBanc-=(_TMP)->(FieldGet(2))
            ElseIf AllTrim((_TMP)->FLAG) == "74"
                nTotDespBanc+=(_TMP)->(FieldGet(2))
            ElseIf AllTrim((_TMP)->FLAG) == "75" // NOVO - Transferencias
                nTotDespBanc+=(_TMP)->(FieldGet(2))   
            Else
                xpto := 0             
            Endif

            nSldCaixa:=nSldInicial+nTotRecebime-nTotPagament
            nSldFinalBai:=nSldCaixa+nTotEndvBanc+nTotDespBanc
            (_TMP)->(dbSkip())
        End

        (_TMP)->(dbCloseArea())

        //Grava Subtotais
        (_TFLX)->(dbSetOrder(If(lAnalitico,4,2)))

        //SAldos Inciais
        (_TFLX)->(MsSeek(aFilial[nX]+"000"))
        RecLock((_TFLX),.F.)
        (_TFLX)->(FIELDPUT(nUltCol,nSldInicial))
        MsUnLock()

        //Grava Registro de Saldos Recebimentos
        (_TFLX)->(MsSeek(aFilial[nX]+"111"))
        RecLock((_TFLX),.F.)
        (_TFLX)->(FIELDPUT(nUltCol,nTotRecebime))
        MsUnLock()

        //Grava Registro de Saldos Pagamentos
        (_TFLX)->(MsSeek(aFilial[nX]+"211"))
        RecLock((_TFLX),.F.)
        (_TFLX)->(FIELDPUT(nUltCol,nTotPagament))
        MsUnLock()

        //Grava Registro de Saldos Caixa Incial
        (_TFLX)->(MsSeek(aFilial[nX]+"311"))
        RecLock((_TFLX),.F.)
        (_TFLX)->(FIELDPUT(nUltCol,nSldCaixa))
        MsUnLock()

        /*
        //Grava Registro de Endividamento Bancario
        (_TFLX)->(MsSeek(aFilial[nX]+"611"))
        RecLock((_TFLX),.F.)
        (_TFLX)->(FIELDPUT(nUltCol,nTotEndvBanc))
        MsUnLock()

        //Grava Registro de Despesas/Receitas Bancarias
        (_TFLX)->(MsSeek(aFilial[nX]+"711"))
        RecLock((_TFLX),.F.)
        (_TFLX)->(FIELDPUT(nUltCol,nTotDespBanc))
        MsUnLock()
        */
        //Grava Registro de Saldos Caixa Final
        (_TFLX)->(MsSeek(aFilial[nX]+"X11"))
        RecLock((_TFLX),.F.)
        (_TFLX)->(FIELDPUT(nUltCol,nSldFinalBai))
        MsUnLock()
    Next nX

    // Acresenta Linhas em branco
    For nI:=1 To Len(aFilial)

        // Pula Linha Apos SAldo inciail
        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="001"
        MsUnLock()

        //Pula Linha depois do sem natureza se houver
        If ASCAN(aSemNat,aFilial[nI]) > 0
            RecLock((_TFLX),.T.)
            (_TFLX)->FILIAL:=aFilial[nI]
            (_TFLX)->FLAG:="002"
            MsUnLock()
        End

        //Linha de Soma de recebimento
        // Pula Linha antes
        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="110"
        MsUnLock()

        // Pula Linha Depois
        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="112"
        MsUnLock()

        // SAldo de Pagamentos
        // Pula Linha Antes
        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="210"
        MsUnLock()

        // Pula Linha antes do Saldo de Caixa
        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="310"
        MsUnLock()

        // Pula Linha antes do Saldo de Caixa
        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="312"
        MsUnLock()


        /*
       RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="610"
        MsUnLock()
        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="612"
        MsUnLock()

        // Pula Linha antes do Despesas Bancarias
        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="312"
        MsUnLock()  // Pula Linha antes do Despesas Bancarias
        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="710"
        MsUnLock()
        */

        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="X10"
        MsUnLock()

        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="X12"
        MsUnLock()

    Next
Return

/*/{Protheus.doc} REGRANAT
Regras de alteração de Natureza especifica pra fluxo de Caixa por natureza
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 31/03/2022
@param Natureza, character, natureza previamente carregada
@param Tipo, character, tipo do titulo
@param TipoDoc, character, Tipo do Docmento de Baixa
@param RecPag, character, Indicador de Pagar ou Receber
@param PREFIXO, character, Indicador do prefixo do Titulo
@return character, nova natureza definida
/*/

Static Function REGRANAT(NATUREZA,TIPO,TIPODOC,RECPAG,PREFIXO)

    Local cNat:=NATUREZA

    //Tratamento a Pagar
    If RECPAG == "P"
        If RTrim(TIPO) == "NF" .and.  Rtrim(TIPODOC) $ "JR,MT"
            cNat:=SuperGetMV("EQ_PNAT01",.F.,"0701002")
        End

        If RTrim(TIPO) == "FI"
            If Rtrim(TIPODOC) $ "JR,MT"
                cNat:= SuperGetMV("EQ_PNAT02",.F.,"0701012")
            ElseIf Rtrim(TIPODOC) $ "VL" .AND. PREFIXO = "JUR"
                cNat:= SuperGetMV("EQ_PNAT02",.F.,"0701012")                
            ElseIf Rtrim(TIPODOC) $ "VL"
                cNat:=SuperGetMV("EQ_PNAT03",.F.,"0601001")
            Endif
        End

        If RTrim(PREFIXO) == "FIN"  .and.  RTRIM(TIPODOC) $ "VL"
            cNat:=SuperGetMV("EQ_PNAT04",.F.,"0601001")
        End

        If RTrim(TIPO) $ "TX,ISS,FLO,IRF"  .and.  Rtrim(TIPODOC) $ "JR,MT"
            cNat:=SuperGetMV("EQ_PNAT05",.F.,"0701017")
        End

        If RTrim(TIPODOC) == "DC"
            cNat:=SuperGetMV("EQ_PNAT06",.F.,"0801004") // 0701013
        End

        If RTrim(PREFIXO) == "RAE" //RA ENTRE EMPRESAS
            cNat:=SuperGetMV("EQ_PNAT07",.F.,"0401017")
        End

        If RTrim(PREFIXO) == "PAE" //PA ENTRE EMPRESAS
            cNat:=SuperGetMV("EQ_PNAT08",.F.,"0101005")
        End

        IF TIPODOC  $ 'TR/TE'
            cNat:="1101001"
        Endif        
    End

    If RECPAG == "R"
        If RTrim(TIPO) == "NF" .and.  Rtrim(TIPODOC) $ "JR,MT"
            cNat:=SuperGetMV("EQ_RNAT01",.F.,"0801003")
        End

        If RTrim(TIPO) == "NF" .and.  Rtrim(TIPODOC) == "DC"
            cNat:=SuperGetMV("EQ_RNAT02",.F.,"0701013") // 0801004
        End
        
        If RTrim(PREFIXO) == "RAE"   //RA ENTRE EMPRESAS
            cNat:=SuperGetMV("EQ_RNAT03",.F.,"0101005")
        End
        If RTrim(PREFIXO) == "PAE" //PA ENTRE EMPRESAS
            cNat:=SuperGetMV("EQ_RNAT04",.F.,"0401017")
        End

        IF TIPODOC  $ 'TR/TE'
            cNat:="1102001"
        Endif
    End

Return cNat

/*
Static Function fGetItemNat(cNaturez)
Local aNaturez := {}
Local nPosic   := 0
Local aRet     := {}

Aadd(aNaturez, {"001", "APLICACAO "})
Aadd(aNaturez, {"002", "CAP       "})
Aadd(aNaturez, {"003", "CARTAO    "})
Aadd(aNaturez, {"004", "CHEQUE    "})
Aadd(aNaturez, {"005", "COFINS    "})
Aadd(aNaturez, {"006", "COMISSOES "})
Aadd(aNaturez, {"007", "CONVENIO  "})
Aadd(aNaturez, {"008", "CREDITO   "})
Aadd(aNaturez, {"009", "CSLL      "})
Aadd(aNaturez, {"010", "DESCONT   "})
Aadd(aNaturez, {"011", "DESP BANC "})
Aadd(aNaturez, {"012", "DEV./TROCA"})
Aadd(aNaturez, {"013", "DINHEIRO  "})
Aadd(aNaturez, {"014", "EMPRESTIMO"})
Aadd(aNaturez, {"015", "FINAN     "})
Aadd(aNaturez, {"016", "ICMS      "})
Aadd(aNaturez, {"017", "INSS      "})
Aadd(aNaturez, {"018", "IPI       "})
Aadd(aNaturez, {"018", "IRF       "})
Aadd(aNaturez, {"020", "ISS       "})
Aadd(aNaturez, {"021", "NATMOVP   "})
Aadd(aNaturez, {"022", "NATMOVR   "})
Aadd(aNaturez, {"023", "NAT_FK    "})
Aadd(aNaturez, {"024", "NOTA DE CR"})
Aadd(aNaturez, {"025", "OUTROS    "})
Aadd(aNaturez, {"026", "PAG DESCON"})
Aadd(aNaturez, {"027", "PAGDIGITAL"})
Aadd(aNaturez, {"028", "PIS       "})
Aadd(aNaturez, {"029", "PIX       "})
Aadd(aNaturez, {"030", "REC DESCON"})
Aadd(aNaturez, {"032", "RECEBIMENT"})
Aadd(aNaturez, {"033", "SANGRIA   "})
Aadd(aNaturez, {"034", "SEST      "})
Aadd(aNaturez, {"034", "TEF       "})
Aadd(aNaturez, {"036", "TROCO     "})
Aadd(aNaturez, {"037", "VALE      "})

nPosic := Ascan(aNaturez, {|x| alltrim(x[2]) == Alltrim(cNaturez)})

IF nPosic > 0
    Aadd(aRet, aNaturez[nPosic][1])  // Item
    Aadd(aRet, aNaturez[nPosic][2])  // Descrição
Endif

Return(aRet)
*/
