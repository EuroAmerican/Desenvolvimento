#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} EQCMMES
Demonstrativo comparativo de custo medios dos ultimos 12 meses, baseado no ultimo fechamento
@type function Relatorio
@version  1.00
@author mario.antonaccio
@since 21/03/2022
@return character, sem retorno
/*/
User Function EQCMMES()

    Local aButtons := {}
    Local aSays    := {}
    Local cTitoDlg := "Comparativo de Custo Medio"
    Local nOpca    := 0
    Private _TCM   := GetNextAlias() //Arquivo  temporario
    Private _TMP   := GetNextAlias() //Arquivo  temporario
    Private aDatas := {}
    Private cCampo   
    Private nTotReg1:=0
    Private cPerg  := "EQCMMES"
    Private oExcel := FWMsExcelEX():New()
    Private oObj   := FWSX1Util()  :New()

    // Perguntas
    //01  - Data Fechamento? -  - 8
    //02  - Do Produto Inicial - C - 15 - SB1
    //03  - Ate Produto Final ? - C - 15 - SB1
    //04  - Do Armazem - C - 2  NN1
    //05  - Ate Armazem ? - C - 2 - NN1
    //06  - Listar Tipo de Produto (separado por ;) - C -15  ('PA', 'PI', 'MP', 'ME')
    //07 -  Empresas: - C - 10   - Informa quais empresas separadas por ; (ponto e virgula)

    aAdd(aSays, "Está rotina tem o objetivo demonstrar comparativo de custo medio")
    aAdd(aSays, "nos ultimos 12 meses a partir do ultimo fechamento.")
    aAdd(aSays, "Pode ser extraído por range de produtos, por tipo, por empresa e por local.")

    aAdd(aButtons,{5, .T., {|o| Pergunte(cPerg, .T.)}})
    aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
    aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

    FormBatch(cTitoDlg, aSays, aButtons)
    If nOpca == 1
        Pergunte(cPerg, .F.)
        Processa( {|| EQCMMES01() }, "Extracao de Dados", "Gerando Registros...", .F.)
        Processa( {|| EQCMEXC()() }, "Planilha Excel", "Gerando Excel...", .F.)
    EndIf

Return

/*/{Protheus.doc} EQCMMES01
Extração de Dados do Custo Medio
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 21/03/2022
@return character, dados extraidos
/*/
Static Function EQCMMES01()

    Local nI
    Local cCampo
    Local nTotReg
    Private dData    := CTOD(" ")
    Private cData    := " "
    Private aFields  := {}
    Private cArqReal    
    Private cExprEmp := "% "+FormatIn(AllTrim(mv_par07),";")+" %" //Separa Filiais
    Private cExprTipo:= "% "+FormatIn(AllTrim(mv_par06),";")+" %" //Separa tipos
  
    dData:=LastDate(YearSub(MonthSum(Mv_par01,1),1))
    AADD(aDatas,dData)
    For nI:=2 to 12
        dData:=LastDate(MonthSum(dData,1))
        AADD(aDatas,dData)
    Next

    MakeDir("C:\TOTVS")

    //Criaçao do arquivo - Campos BAsicos
    aadd(aFields, {"FILIAL"   , 'C', 04, 0})
    aadd(aFields, {"PRODUTO"  , 'C', 15, 0})
    aadd(aFields, {"DESCRICAO", 'C', 30, 0})
    aadd(aFields, {"TIPO "    , 'C', 02, 0})
    aadd(aFields, {"UM"       , 'C', 02, 0})
    aadd(aFields, {"ARMAZEM"  , 'C', 02, 0})

    For nI:=1 to Len(aDatas)
        cData:=DTOS(aDatas[nI])  // Retona o Ano e o mes das datas seguintes ao parametro
        AADD(aFields,{"_"+cData,'N',14,2})
    Next

    oTmpTable:=FWTemporaryTable():New((_TCM))
    oTmpTable:SetFields(aFields)
    oTmpTable:AddIndex("01",{"FILIAL","PRODUTO","ARMAZEM"})
    oTmpTable:Create()

    cArqReal:="%"+oTmpTable:GetRealName()+"%"

    // Gera por empresa conforme
    BeginSql Alias _TMP
        SELECT
            SB9.B9_FILIAL,
            SB9.B9_COD,
            SB1.B1_DESC,
            SB1.B1_TIPO,
            SB1.B1_UM,
            SB9.B9_LOCAL,
            SB9.B9_DATA,
            SB9.B9_CM1
        FROM
            %Table:SB9% SB9
        INNER JOIN %Table:SB1% SB1
        ON SB9.B9_COD = SB1.B1_COD
            AND SB1.%NotDel%
            AND SB1.B1_TIPO IN  %Exp:cExprTipo% 
        WHERE
            SB9.B9_DATA >= %Exp:aDatas[1]%
            AND SB9.B9_DATA <= %Exp:aDatas[(Len(aDatas))]%
            AND SB9.%NotDel%
            AND SB9.B9_FILIAL IN %Exp:cExprEmp%
            AND SB9.B9_COD >= %Exp:mv_par02%
            AND SB9.B9_COD <= %Exp:mv_par03%
            AND SB9.B9_LOCAL >= %Exp:mv_par04%
            AND SB9.B9_LOCAL <= %Exp:mv_par05%
        ORDER BY
            SB9.B9_FILIAL,
            SB9.B9_COD,
            SB9.B9_LOCAL
    EndSql

    aQuery:=GetLastQuery()

    nTotReg := Contar((_TMP),"!EOF()")

    (_TMP)->(DbGoTop())

    ProcRegua(nTotReg)

    While (_TMP)->(!EOF())

        IncProc()

        cCampo := "(_TCM)->_"+(_TMP)->B9_DATA
        (_TCM)->(dbSetOrder(1))
        If (_TCM)->(Dbseek((_TMP)->B9_FILIAL+(_TMP)->B9_COD+(_TMP)->B9_LOCAL))
            RecLock((_TCM),.F.)
            &cCampo:=(_TMP)->B9_CM1
        Else
             RecLock((_TCM),.T.)
             (_TCM)->FILIAL    := (_TMP)->B9_FILIAL
             (_TCM)->PRODUTO   := (_TMP)->B9_COD
             (_TCM)->DESCRICAO := (_TMP)->B1_DESC
             (_TCM)->TIPO      := (_TMP)->B1_TIPO
             (_TCM)->UM        := (_TMP)->B1_UM
             (_TCM)->ARMAZEM   := (_TMP)->B9_LOCAL
             &cCampo           := (_TMP)->B9_CM1
             nTotReg1++
        End
        MsUnlock()

        (_TMP)->(dbSkip())

    End

    (_TMP)->(dbCloseArea())

Return

/*/{Protheus.doc} EQCMEXC
Gera Planilha EXCEL dos Custos Medios
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 22/03/2022
@return Character, Tabelas com os dados
/*/
Static Function EQCMEXC()

    Local aLinhaAux := {}
    Local aPergunte := {}
    Local cArqDst   := "C:\TOTVS\EQCM_"+DTOS(MV_PAR01)+Substr(TIME(),7,2)+".XML"
    Local cNomeFil  := "Custo Medio Mensal "
    Local cTitPla   := "Custo Medio Periodo de  "+DTOC(aDatas[1]) +" a "+DTOC(aDatas[Len(aDatas)])
    Local lAbre     := .F.
    Local nI        := 0

    //Deixa a planilha  sen o azul no corpo
    /*
    oExcel:SetLineFrColor("#000000")
    oExcel:SetLineBgColor("#FFFFFF")
    oExcel:Set2LineFrColor("#000000")
    oExcel:Set2LineBgColor("#FFFFFF")
    */
    oExcel:AddworkSheet(cNomeFil)
    oExcel:AddTable(cNomeFil, cTitPla)

    oExcel:AddColumn(cNomeFil, cTitPla, "Filial",1,1,.F.)
    oExcel:AddColumn(cNomeFil, cTitPla, "Produto",1,1,.F.)
    oExcel:AddColumn(cNomeFil, cTitPla, "Descricao",1,1,.F.)
    oExcel:AddColumn(cNomeFil, cTitPla, "Tipo",1,1,.F.)
    oExcel:AddColumn(cNomeFil, cTitPla, "UM",1,1,.F.)
    oExcel:AddColumn(cNomeFil, cTitPla, "Armazem",1,1,.F.)
    For nI:=1 to Len(aDatas)
        oExcel:AddColumn(cNomeFil, cTitPla, Substr(DTOC(aDatas[nI]),4,8), 3, 2, .F.,"@ER 999,999.99")
    Next

    (_TCM)->(DbGoTop())

    ProcRegua(nTotReg1)

    While (_TCM)->(!EOF())

        IncProc()

        lAbre:=.T.

        //Carrega array auxiiar para carregar planilha
        aLinhaAux:={}
        For nI := 1 To (_TCM)->(FCOUNT()) //nCampos
            AADD(aLinhaAux, (_TCM)->(FieldGet(nI)))
        Next
        oExcel:AddRow(cNomeFil, cTitPla,aLinhaAux)

        (_TCM)->(dbSkip())

    End

    (_TCM)->(dbCloseArea())

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
