#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} QEQIPR001
Comparação de Lotes - EuroAmerican
@type function Relatorio
@version  1.00
@author Paulo Rogério
@since 25/05/2023
@return character, sem retorno

/*/
User Function QEQIPR001()

Private _cPerg:="QEQIPR001"
Private _aRegs:={}

Private aFields   := {}
Private aFieldsN  := {}

Private nQtdReg   := 0
Private aLotes    := {}
Private cArqDst   := "" 
Private cLstLotes := ""

//Private cLstLotes := ""

Private _TMPX     := GetNextAlias() //Arquivo  temporario (Planilha 01))
Private _TMPY     := GetNextAlias() //Arquivo  temporario (Planilha 02))

Private oExcel    := FWMsExcelEX():New()
Private oObj      := FWSX1Util()  :New()

Private vpParDatDe := ""
Private vpParDatAte:= ""
Private vpParCodPro:= ""
Private vpParLotDe := ""
Private vpParLotAt := ""
Private vpParTpLot := ""


//-----------|Grupo|Ord|Pergta                 |Pergunta              |Pergunta              |Variavel|Tip|Ta|D|P|GSC|Va|Var01     |Def Port       |De|De|Cn|Va|Def Port2      |De|De|Cn|Va|Def Port3    |De|De|Cn|Va|Def Port4    |De|De|Cn|Va|Def Port5  |De|De|Cn|F3|P |GRP
//-----------|     |em |Portug                 |Espanhol              |Ingles                |        |   |ma|e|r|   |li|          |               |f |f |te|r |               |f |f |te|r |             |f |f |te|r |             |f |f |te|r |           |f |f |te|  |Y |SXG
//-----------|     |   |                       |                      |                      |        |   |nh|c|e|   |d |          |               |Es|En|01|2 |               |Es|En|02|3 |             |Es|En|03|4 |             |Es|En|05|5 |           |Es|En|05|  |M |
AAdd(_aRegs,{_cPerg,"01","Analise de         ?","Analise de         ?","Analise de         ?","mv_ch1","D",08,0,0,"G","","mv_par01",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
AAdd(_aRegs,{_cPerg,"02","Analise ate        ?","Analise ate        ?","Analise ate        ?","mv_ch2","D",08,0,0,"G","","mv_par02",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
AAdd(_aRegs,{_cPerg,"03","Produto            ?","Produto            ?","Produto            ?","mv_ch3","C",15,0,0,"G","","mv_par03",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","","SB1"   ,"",""})
AAdd(_aRegs,{_cPerg,"04","Lote de            ?","Lote de            ?","Lote de            ?","mv_ch4","C",10,0,0,"G","","mv_par04",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
AAdd(_aRegs,{_cPerg,"05","Lote ate           ?","Lote ate           ?","Lote ate           ?","mv_ch5","C",10,0,0,"G","","mv_par05",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
AAdd(_aRegs,{_cPerg,"06","Tipo de Lote MP    ?","Tipo de Lote MP    ?","Tipo de Lote MP    ?","mv_ch6","N",01,0,0,"C","","mv_par06","Interno"      ,"","","","","Fornecedor"   ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})

U_FSX1FUNC(_aRegs, _cPerg)
    Pergunte(_cPerg, .T.)

    vpParDatDe := MV_PAR01
    vpParDatAte:= MV_PAR02
    vpParCodPro:= MV_PAR03
    vpParLotDe := MV_PAR04
    vpParLotAt := MV_PAR05
    vpParTpLot := MV_PAR06

    Processa( {|| fGerPlan1()}, "Processando", "Gerando Registros...", .F.)
    Processa( {|| fGerPlan2()}, "Processando", "Gerando Registros...", .F.)
Return

/* ------------------------------------------
Gera arquivo temporário para exportação em EXCEL
@type function Processmento
@version  1.00
@author Paulo Rogério
 --------------------------------------------
*/
Static Function fGerPlan1()
//Local cNomCpoChar := ""
//Local cNomCpoNume := ""
//Local nX          := 0

Local cQuery  := ""

cQuery := ""

cQuery += "SELECT DISTINCT * FROM "+chr(13)+chr(10)
cQuery += "("+chr(13)+chr(10)
cQuery += "SELECT ZD_CODANAL, ZD_DATA, ZD_LOTE, ZD_PRODUT, ZD_OP, ZD_STATUS,"+chr(13)+chr(10)

cQuery += "		(SELECT TOP 1 ZD_RNUM"+chr(13)+chr(10)
cQuery += "		   FROM "+RetSqlName("SZD")+" AS TMP"+chr(13)+chr(10)
cQuery += "		 WHERE TMP.D_E_L_E_T_ = ''"+chr(13)+chr(10)
cQuery += "		   AND TMP.ZD_FILIAL = SZD.ZD_FILIAL"+chr(13)+chr(10)
cQuery += "		   AND TMP.ZD_PRODUT = SZD.ZD_PRODUT"+chr(13)+chr(10)
cQuery += "		   AND TMP.ZD_STATUS = SZD.ZD_STATUS"+chr(13)+chr(10)
cQuery += "		   AND TMP.ZD_LOTE  =  SZD.ZD_LOTE"+chr(13)+chr(10)
cQuery += "		   AND UPPER(LEFT(TRIM(ZD_DENSAI), 4)) = 'TEOR'"+chr(13)+chr(10)
cQuery += "		   ORDER BY ZD_CODANAL DESC "+chr(13)+chr(10)
cQuery += "		 ) AS ZD_TEOR,"+chr(13)+chr(10)+chr(13)+chr(10)
		
cQuery += "		(SELECT TOP 1 ZD_RNUM"+chr(13)+chr(10)
cQuery += "		   FROM "+RetSqlName("SZD")+" AS TMP"+chr(13)+chr(10)
cQuery += "		 WHERE TMP.D_E_L_E_T_ = ''"+chr(13)+chr(10)
cQuery += "		   AND TMP.ZD_FILIAL = SZD.ZD_FILIAL"+chr(13)+chr(10)
cQuery += "		   AND TMP.ZD_PRODUT = SZD.ZD_PRODUT"+chr(13)+chr(10)
cQuery += "		   AND TMP.ZD_STATUS = SZD.ZD_STATUS"+chr(13)+chr(10)
cQuery += "		   AND TMP.ZD_LOTE  =  SZD.ZD_LOTE"+chr(13)+chr(10)
cQuery += "		   AND UPPER(LEFT(TRIM(ZD_DENSAI), 4)) = 'VISC'"+chr(13)+chr(10)
cQuery += "		   ORDER BY ZD_CODANAL DESC "+chr(13)+chr(10)
cQuery += "		 ) AS ZD_VISC,"+chr(13)+chr(10)+chr(13)+chr(10)

cQuery += "		(SELECT TOP 1 ZD_RNUM"+chr(13)+chr(10)
cQuery += "		   FROM "+RetSqlName("SZD")+" AS TMP"+chr(13)+chr(10)
cQuery += "		 WHERE TMP.D_E_L_E_T_ = ''"+chr(13)+chr(10)
cQuery += "		   AND TMP.ZD_FILIAL = SZD.ZD_FILIAL"+chr(13)+chr(10)
cQuery += "		   AND TMP.ZD_PRODUT = SZD.ZD_PRODUT"+chr(13)+chr(10)
cQuery += "		   AND TMP.ZD_STATUS = SZD.ZD_STATUS"+chr(13)+chr(10)
cQuery += "		   AND TMP.ZD_LOTE  =  SZD.ZD_LOTE"+chr(13)+chr(10)
cQuery += "		   AND UPPER(LEFT(TRIM(ZD_DENSAI), 2)) = 'PH'"+chr(13)+chr(10)
cQuery += "		   ORDER BY ZD_CODANAL DESC "+chr(13)+chr(10)
cQuery += "		 ) AS ZD_PH"+chr(13)+chr(10)+chr(13)+chr(10)
				
cQuery += "  FROM "+RetSqlName("SZD")+" AS SZD"+chr(13)+chr(10)
cQuery += " WHERE SZD.D_E_L_E_T_ = '' "+chr(13)+chr(10)
cQuery += "   AND ZD_FILIAL = '"+xFilial("SZD")+"'"+chr(13)+chr(10)
cQuery += "   AND ZD_DATA BETWEEN  '"+dtos(vpParDatDe)+"' AND '" + dtos(vpParDatAte)+"'" +chr(13)+chr(10)
cQuery += "   AND ZD_PRODUT = '"+vpParCodPro+"'"+chr(13)+chr(10)
//cQuery += "   AND ZD_STATUS = 'A'"+chr(13)+chr(10)
cQuery += "   AND ZD_LOTE BETWEEN '"+vpParLotDe+"' AND '"+vpParLotAt+"'"+chr(13)+chr(10)
cQuery += "   AND UPPER(LEFT(ZD_DENSAI, 3)) IN('TEO', 'VIS', 'PH ')"+chr(13)+chr(10)


cQuery += ") QRY"+chr(13)+chr(10)
cQuery += " ORDER BY ZD_DATA, ZD_LOTE, ZD_STATUS DESC"+chr(13)+chr(10)

IF Select("TEMP") >0
    dbSelectArea("TEMP")
    dbcloseArea()
Endif

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TEMP", .F., .T.)

TCSetField("TEMP", "ZD_DATA", "D", 08, 0 )

dbSelectArea("TEMP")
Count to nQtdReg
dbGotop()

IF nQtdReg == 0
    MsgAlert("Não há certificado de analise para os parametros informados!")
    dbCloseArea()
    Return
Endif

// Define array para criação da estrutura do arquivo temporário - Planilha 01
AADD(aFields,{"X_PRODUTO" ,'C',15,0})
AADD(aFields,{"X_DESCRIC" ,'C',50,0})
AADD(aFields,{"X_LOTE"    ,'C',10,0})
AADD(aFields,{"X_DATA"    ,'D',08,0})
AADD(aFields,{"X_TEOR"    ,'N',12,4})
AADD(aFields,{"X_VISC"    ,'N',12,4})
AADD(aFields,{"X_PH"      ,'N',12,4})
AADD(aFields,{"X_STATUS"  ,'C',15,0})

// Nomes dos Campos
AADD(aFieldsN,"PRODUTO")
AADD(aFieldsN,"DESCRICAO")
AADD(aFieldsN,"LOTE"   )
AADD(aFieldsN,"ANALISE")
AADD(aFieldsN,"TEOR")
AADD(aFieldsN,"VISCOSIDADE")
AADD(aFieldsN,"PH")
AADD(aFieldsN,"STATUS")


// Criaçao arquivo temporário
oTmpTable:=FWTemporaryTable():New((_TMPX))
oTmpTable:SetFields(aFields)
oTmpTable:AddIndex("01",{"X_PRODUTO","X_LOTE"})
oTmpTable:Create()

dbSelectArea("TEMP")
ProcRegua(nQtdReg)

Do While TEMP->(!EOF())
    dbSelectArea(_TMPX)
    RecLock(_TMPX,.T.)
        X_PRODUTO := TEMP->ZD_PRODUT // ZD_CODANAL, ZD_DATA, ZD_LOTE, ZD_PRODUT, ZD_ENSAIO, ZD_RNUM, ZD_OP 
        X_DESCRIC := Left(Posicione("SB1", 1, xFilial("SB1")+TEMP->ZD_PRODUT, "B1_DESC" ), 50)
        X_LOTE    := TEMP->ZD_LOTE
        X_DATA    := TEMP->ZD_DATA
        X_TEOR    := TEMP->ZD_TEOR
        X_VISC    := TEMP->ZD_VISC
        X_PH      := TEMP->ZD_PH
        X_STATUS  := iif(TEMP->ZD_STATUS == 'A', 'APROVADO', iif(TEMP->ZD_STATUS == 'R', 'REPROVADO', 'C/RESTRICAO'))
    MsUnlock()

    IF Ascan(aLotes, rTrim(TEMP->ZD_LOTE)) == 0
        Aadd(aLotes, rTrim(TEMP->ZD_LOTE))
    Endif

    cLstLotes+=",'"+rTrim(TEMP->ZD_LOTE)+"'"

    dbSelectArea("TEMP")
    dbSkip()
Enddo

// Lesta de  lotes para realizar o filtro da planilha 02.
IF Len(cLstLotes) > 0
    cLstLotes := Subs(cLstLotes, 2)
Endif

// Gera o Arquivo XML
fGeraExcel(1, _TMPX)
//oTmpTable:Delete()
Return

//oTmpTable:Delete()
//oTmpTable:GetRealName() 

/* ------------------------------------------
Gera arquivo temporário para exportação em EXCEL
@type function Processmento
@version  1.00
@author Paulo Rogério
 --------------------------------------------
*/
Static Function fGerPlan2()
Local cNomCpoLot := ""
Local cCpoLote   := ""
Local cCpoTota   := ""
Local nX         := 0
Local aTotal     := {}
Local nPesq      := 0

Local cQuery  := ""

cLstLotes := IIF(Empty(cLstLotes), "'NAOEXISTE'",cLstLotes)

cQuery := ""

cQuery += "SELECT SD5.D5_PRODUTO AS X_PRODUTO, "+chr(13)+chr(10)
cQuery += "       SD5.D5_QUANT   AS X_QTDPROD, "+chr(13)+chr(10)
cQuery += "	      SD5.D5_LOTECTL AS X_LOTPROD, "+chr(13)+chr(10)
cQuery += "	      SD5.D5_NUMSEQ  AS X_NUMSEQ,  "+chr(13)+chr(10)
cQuery += "	      SD5.D5_OP      AS X_OP,      "+chr(13)+chr(10)
cQuery += "	      TMP.D5_PRODUTO AS X_COMPONE, "+chr(13)+chr(10)
cQuery += "       SB1.B1_DESC    AS X_DESCRIC,"+chr(13)+chr(10)
cQuery += "	      SD3.D3_QUANT   AS X_QTDCOMP, "+chr(13)+chr(10)

IF vpParTpLot == 1
    cQuery += "	      TMP.D5_LOTECTL AS X_LTCOMPO, "+chr(13)+chr(10)
Else
    cQuery += "	      CASE WHEN RTRIM(SB8.B8_LOTEFOR) = '' THEN '000000' ELSE SB8.B8_LOTEFOR END AS X_LTCOMPO,"+chr(13)+chr(10)
Endif

cQuery += "	      SD3.D3_QUANT/SD5.D5_QUANT AS X_QTDUNIT,"+chr(13)+chr(10)
cQuery += "	      SD3.D3_TM      AS X_TM,      "+chr(13)+chr(10)
cQuery += "	      SD3.D3_CF      AS X_CF       "+chr(13)+chr(10)
cQuery += "FROM "+RetSqlName("SD5")+" AS SD5"+chr(13)+chr(10)
cQuery += "     INNER JOIN "+RetSqlName("SD5")+" AS TMP ON TMP.D5_FILIAL = SD5.D5_FILIAL AND TMP.D5_OP      = SD5.D5_OP AND TMP.D5_ESTORNO = '' AND TMP.D_E_L_E_T_ = '' -- D3_TM = '999' AND D3_CF = 'RE1' AND "+chr(13)+chr(10)
cQuery += "     INNER JOIN "+RetSqlName("SD3")+" AS SD3 ON SD3.D3_FILIAL = TMP.D5_FILIAL AND SD3.D3_COD     = TMP.D5_PRODUTO AND SD3.D3_LOCAL = TMP.D5_LOCAL AND SD3.D3_NUMSEQ   = TMP.D5_NUMSEQ  AND SD3.D3_ESTORNO = '' AND SD3.D3_TM <> '001' AND SD3.D_E_L_E_T_= ''"+chr(13)+chr(10)
cQuery += "     INNER JOIN "+RetSqlName("SB8")+" AS SB8 ON SB8.B8_FILIAL = TMP.D5_FILIAL AND SB8.B8_PRODUTO = TMP.D5_PRODUTO AND SB8.B8_LOCAL = TMP.D5_LOCAL AND SB8.B8_LOTECTL  = TMP.D5_LOTECTL AND SB8.D_E_L_E_T_ = ''"+chr(13)+chr(10)
cQuery += "     INNER JOIN "+RetSqlName("SB1")+" AS SB1 ON B1_COD = TMP.D5_PRODUTO AND SB1.D_E_L_E_T_ = ''"+chr(13)+chr(10)
cQuery += " WHERE SD5.D_E_L_E_T_ = ''"+chr(13)+chr(10)
cQuery += "   AND SD5.D5_FILIAL = '"+xFilial("SD5")+"'"+chr(13)+chr(10) 
cQuery += "   AND SD5.D5_PRODUTO = '"+vpParCodPro+"'"+chr(13)+chr(10) 
cQuery += "   AND SD5.D5_OP <> '' "+chr(13)+chr(10) 
cQuery += "   AND SD5.D5_ESTORNO <> 'S' "+chr(13)+chr(10) 
cQuery += "   AND SD5.D5_DATA BETWEEN  '"+dtos(vpParDatDe)+"' AND '" + dtos(vpParDatAte)+"'" +chr(13)+chr(10) 
cQuery += "   AND SD5.D5_ORIGLAN = '001' "+chr(13)+chr(10) 
//cQuery += "   AND SD5.D5_LOTEPRD BETWEEN '"+vpParLotDe+"' AND '"+vpParLotAt+"'"+chr(13)+chr(10)
cQuery += "   AND SD5.D5_LOTEPRD IN("+cLstLotes+")"+chr(13)+chr(10)
cQuery += " ORDER BY SD5.D5_PRODUTO, TMP.D5_PRODUTO"+chr(13)+chr(10) 

IF Select("TEMP") > 0
    dbSelectArea("TEMP")
    dbcloseArea()
Endif

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TEMP", .F., .T.)


dbSelectArea("TEMP")
Count to nQtdReg
dbGotop()

IF nQtdReg == 0
    MsgAlert("Não há itens a rastrear para os parametros informados!")
    dbCloseArea()
    Return
Endif

aFields  := {}
aFieldsn := {}

// [INICIO] Define array para criação da estrutura do arquivo temporário - Planilha 01
Aadd(aFields,{"X_COMPONE" ,'C',15,0})
Aadd(aFields,{"X_DESCRIC" ,'C',50,0})
Aadd(aFields,{"X_LTCOMPO" ,'C',12,0})

Aadd(aFieldsN,"Componente")
Aadd(aFieldsN,"Descricao")
Aadd(aFieldsN,"Lote MP")

For nX:=1 to Len(aLotes)
    cNomCpoLot:="LT_"+Alltrim(aLotes[nX])

    Aadd(aFields,{cNomCpoLot,'N',12,4})
    Aadd(aFieldsN,Alltrim(aLotes[nX]))
Next

//cNomCpoLot:="LT_TOTAL"
//Aadd(aFields,{"LT_TOTAL",'N',12,4})
Aadd(aFields,{"LT_TOTAL",'N',12,4})
Aadd(aFieldsN,"Total")

// [TERMINO] Define array para criação da estrutura do arquivo temporário - Planilha 01


// Criaçao arquivo temporário
oTmpTable:=FWTemporaryTable():New((_TMPY))
oTmpTable:SetFields(aFields)
oTmpTable:AddIndex("01",{"X_COMPONE","X_LTCOMPO"})
oTmpTable:Create()

dbSelectArea("TEMP")
ProcRegua(nQtdReg)

// Controla a troca de componente para geração de subtotal
cCompAnterior := TEMP->X_COMPONE 
cDescAnterior := Left(TEMP->X_DESCRIC, 50)

Do While TEMP->(!EOF())
    nQtdCompon := 0
    cCpoLote   := ""
    cCpoTota   := ""

    // [INICIO] Adiciona / Atualiza Componente / Lote
    dbSelectArea(_TMPY)
    dbSeek(TEMP->X_COMPONE+TEMP->X_LTCOMPO, .F. )

    IF !Found()
        RecLock(_TMPY,.T.)
        X_COMPONE := TEMP->X_COMPONE 
        X_DESCRIC := Left(TEMP->X_DESCRIC, 50)
        X_LTCOMPO := TEMP->X_LTCOMPO
    Else
        RecLock(_TMPY,.F.)
    Endif

    cCpoLote := "LT_"+TEMP->X_LOTPROD    
    cCpoTota := "LT_TOTAL"   

    &cCpoLote := TEMP->X_QTDUNIT
    &cCpoTota += TEMP->X_QTDUNIT
    MsUnlock()
    // [TERMINO] Adiciona / Atualiza Componente / Lote

    // Totalizador por Componente / Lote
    nPesq := ascan(aTotal, {|X| Trim(X[1]) ==  Trim(TEMP->X_COMPONE) .And. Trim(X[2]) == Trim(TEMP->X_LOTPROD)})
    IF nPesq == 0
        aadd(aTotal, {TEMP->X_COMPONE, TEMP->X_LOTPROD, TEMP->X_QTDUNIT})
    Else
        aTotal[nPesq][3] += TEMP->X_QTDUNIT
    Endif

    dbSelectArea("TEMP")
    dbSkip()

    // [INICIO] Adiciona Totalizar por Componente
    IF cCompAnterior <> TEMP->X_COMPONE  .OR. Eof()
        dbSelectArea(_TMPY)
        RecLock(_TMPY,.T.)

        X_COMPONE := cCompAnterior 
        X_DESCRIC := cDescAnterior
        X_LTCOMPO := "TOTAL"   

        For nX := 1 to Len(aTotal)
            cCpoLote := "LT_"+aTotal[nX][2]   
            cCpoTota := "LT_TOTAL"   

            &cCpoLote := aTotal[nX][3]
            &cCpoTota += aTotal[nX][3]
        Next
        MsUnlock() 

        cCompAnterior := TEMP->X_COMPONE 
        cDescAnterior := Left(TEMP->X_DESCRIC, 50)
        aTotal := {}

        dbSelectArea("TEMP")              
    Endif
    // [TERMINO] Adiciona Totalizar por Componente
Enddo

// Gera o Arquivo XML
fGeraExcel(2, _TMPY)
Return



/* ------------------------------------------
{Protheus.doc} fGeraExcel
Gera Planilha EXCEL 
@type function Processmento
@version  1.00
@author Paulo Rogério
@since 26/05/23
@return Character, Tabelas com os dados
 ------------------------------------------
*/
Static Function  fGeraExcel(nPasta, cAlias)
    //Local cNomeFil  := " "
    //Local nJ        := 0
    //Local nTotReg   := 0

    Local aLinhaAux := {}
    Local aPergunte := {}

    Local cCampos   := " "
    Local cTitPla   := "Comparacao de Lotes"
    Local lAbre     := .F.
    Local nCampos   := 0
    Local nI        := 0
    Local cPasta    := IIF(nPasta == 1, "Analise", "Rastro")

    //Deixa a planilha  sem o azul no corpo
    oExcel:SetLineFrColor("#000000")
    oExcel:SetLineBgColor("#FFFFFF")
    oExcel:Set2LineFrColor("#000000")
    oExcel:Set2LineBgColor("#FFFFFF")

    //Indica quais campos entrarao na montaem do EXCEL
    cCampos:="%"
    For nI:=1 to Len(aFields)
        cCampos+=aFields[nI,1]+If(nI==Len(aFields),"",",")
        nCampos++
    Next
    cCampos+="%"

    // Nome do arquivo XML a ser gerado
    IF Empty(cArqDst)
        cArqDst := "C:\TOTVS\"
        cArqDst += "QIP_"+ Dtos(dDataBase) + Str(Seconds(),5,0) + ".XML"
    Endif

    // Cria pasta e adiciona título
    oExcel:AddworkSheet(cPasta)
    oExcel:AddTable(cPasta, cTitPla)

    //Monta Excel Dinamico conforme os campos selecionados
    For nI := 1 To Len(aFields) //nCampos
        If aFields[nI,2] = "C"
            oExcel:AddColumn(cPasta, cTitPla, aFieldsN[nI], 1, 1, .F.)
        ElseIf aFields[nI,2] == "N"
            oExcel:AddColumn(cPasta, cTitPla, aFieldsN[nI], 3, 2, .F.) //,,"@E 999.999,9999")
        Else
            oExcel:AddColumn(cPasta, cTitPla, aFieldsN[nI], 1, 1, .F.)
        Endif
    Next

    dbSelectArea(cAlias)
    dbGotop()

    lAbre:=.T.

    // Adicona linhas na planilha.
    Do While (cAlias)->(!EOF())
        aLinhaAux:={}

        //Carrega array auxiiar para carregar planilha
        For nI := 1 To (cAlias)->(FCOUNT()) //nCampos
            AADD(aLinhaAux, (cAlias)->(FieldGet(nI)))
        Next

        oExcel:AddRow(cPasta, cTitPla, aLinhaAux)

        (cAlias)->(dbSkip())
    Enddo

    //Fim Fluxo
    //(_TMP)->(dbCloseArea())

    //lDFC:=.F.
    //If lDFC
    //End

    IF nPasta == 2
        // Cria Aba de Parametros da rotian
        oObj:AddGroup(_cPerg)
        oObj:SearchGroup()
        aPergunte := oObj:GetGroup(_cPerg)

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

        // Abre o relatório em Excel
        If lAbre
            oExcel:Activate()
            oExcel:GetXMLFile(cArqDst)
            OPENXML(cArqDst)
            oExcel:DeActivate()
        Else
            MsgInfo("Nao existem dados para serem impressos.", "SEM DADOS")
        EndIf
    Endif
Return

/* ------------------------------------------
{Protheus.doc} OPENXML
Abertura do arquivo XML Gerado
@type function Files
@version  1.00
@author mario.antonaccio
@since 16/12/2021
@param cArq, character, Nome do Arquivo XML
@return character, sem retorno
 ------------------------------------------*/
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
