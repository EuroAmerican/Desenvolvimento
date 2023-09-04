#include "parmtype.ch"
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"
#include "Colors.ch"
#include "RwMake.ch"

/*/{Protheus.doc} rfat006
//Relacao do faturamento por vendedor
@author mjlozzardo
@since 30/08/2018
@version 1.0
@Autor   : Fabio Carneiro 
@History : Foi alterado todo conceito do relatorio colocando a query semelhante ao portal. 
@History : Foi necessario mudar todo o conceito da logica porque a margem de contribuição não estava 
@History : batendo com os valores do portal, portanto foi decidido refazer o relatorio. 
@Date History : 23/07/2021 
/*/

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

User Function rfat006()

Local aSays    := {}
Local aButtons := {}
Local aHelpPor := {}
Local cTitoDlg := "Faturamento por vendedor"
Local cPerg    := "RFAT006"
Local nOpca    := 0

//Pergunta 01
aHelpPor := {}
aAdd(aHelpPor, "Informe a data inicial")
aAdd(aHelpPor, "a ser considerada.")
U_FATUSX1(cPerg,"01","Data Inicio","Data Inicio","Data Inicio","MV_CH1","D",8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

//Pergunta 02
aHelpPor := {}
aAdd(aHelpPor, "Informe a data final")
aAdd(aHelpPor, "a ser considerada.")
U_FATUSX1(cPerg,"02","Data Final","Data Final","Data Final","MV_CH2","D",8,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

//Pergunta 03
aHelpPor := {}
aAdd(aHelpPor, "Informe Codigo Vendedor inicial")
aAdd(aHelpPor, "a ser considerado.")
U_FATUSX1(cPerg,"03","Vendedor Inicial","Vendedor Inicial","Vendedor Inicial","MV_CH3","C",6,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

//Pergunta 04
aHelpPor := {}
aAdd(aHelpPor, "Informe Codigo Vendedor final")
aAdd(aHelpPor, "a ser considerado.")
U_FATUSX1(cPerg,"04","Vendedor Final","Vendedor Final","Vendedor Final","MV_CH4","C",6,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

//Pergunta 05
aHelpPor := {}
aAdd(aHelpPor, "Informe a Codigo do Gerente inicial")
aAdd(aHelpPor, "a ser considerado.")
U_FATUSX1(cPerg,"05","Gerente Inicial","Gerente Inicial","Gerente Inicial","MV_CH5","C",6,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

//Pergunta 06
aHelpPor := {}
aAdd(aHelpPor, "Informe a Codigo do Gerente final")
aAdd(aHelpPor, "a ser considerado.")
U_FATUSX1(cPerg,"06","Gerente Final","Gerente Final","Gerente Final","MV_CH6","C",6,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

//Pergunta 07
aHelpPor := {}
aAdd(aHelpPor, "Lista custo e Margem no Relatorio ")
U_FATUSX1(cPerg,"06","Lista Custo e Margem","Lista Custo e Margem","Lista Custo e Margem","MV_CH7","C",1,0,0,"C","","MV_PAR07","Sim","Sim","Sim","Não","Não","Não","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

aAdd(aSays, "Rotina para gerar a relação das vendas, devolucoes e pedidos em carteira")
aAdd(aSays, "de acordo com o periodo informado.")
aAdd(aSays, "A planilha será salva no diretorio C:\TOTVS\RFAT006.XML ")

aAdd(aButtons,{5, .T., {|o| Pergunte(cPerg, .T.)}})
aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

FormBatch(cTitoDlg, aSays, aButtons)

If !Pergunte(cPerg,.T.)
	Return
ElseIf nOpca == 1
	MontaDir("C:\TOTVS\")
	Processa({|| U_rfat06ok("Gerando planilha, aguarde...")})
EndIf

Return

User Function rfat06ok()
Local aDados := {}
Local n1     := 0
Local nPos   := 0
Local cQuery := ""

Local cArqDst := "C:\TOTVS\RFAT006_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
Local oExcel  := FWMsExcelEX():New()
Local cPlan   := "Empresa_" + Rtrim(SM0->M0_CODIGO) + "_Filial_" + Rtrim(SM0->M0_CODFIL)
Local cTit    := "Relação das vendas por Vendedor De: " + Dtoc(MV_PAR01) + " Ate: " + Dtoc(MV_PAR02)
Local cQuebra := ""
Local nTotal1 := 0
Local nTotal2 := 0
Local nTotal3 := 0
Local nTotal4 := 0
Local nTotal5 := 0
Local nTotal6 := 0
Local nTotal7 := 0
Local nTotal8 := 0
Local nTotal9 := 0
Local nTotal10:= 0
Local nTotal90:= 0 // Valor
Local nTotal91:= 0 // Custo
Local nTotal92:= 0 // base Comissão

Local nTotal1G := 0
Local nTotal2G := 0
Local nTotal3G := 0
Local nTotal4G := 0
Local nTotal5G := 0
Local nTotal6G := 0
Local nTotal7G := 0
Local nTotal8G := 0
Local nTotal9G := 0
Local nTotal10G:= 0
Local nTotal90G:= 0 // Valor
Local nTotal91G:= 0 // Custo
Local nTotal92G:= 0 // Comissão

Local cRegiao  := ""

//dados da planilha
oExcel:AddworkSheet(cPlan)
oExcel:AddTable(cPlan, cTit)
oExcel:AddColumn(cPlan, cTit, "Cod. Gerente" , 1, 1, .F.)  //01
oExcel:AddColumn(cPlan, cTit, "Cod. Vendedor", 1, 1, .F.)  //02
oExcel:AddColumn(cPlan, cTit, "Nome Vend."    , 1, 1, .F.)  //03
oExcel:AddColumn(cPlan, cTit, "Meta", 3, 2, .F.)  //04
oExcel:AddColumn(cPlan, cTit, "Vlr.Fat. Bruto - Devol.", 3, 2, .F.)  //05
If MV_PAR07 = 1
	oExcel:AddColumn(cPlan, cTit, "Mrg. Contr.", 3, 2, .F.)  // 06
EndIf
oExcel:AddColumn(cPlan, cTit, "Vlr.Devol."  , 3, 2, .F.)  //07
oExcel:AddColumn(cPlan, cTit, "% Atend."  	, 3, 2, .F.)  //08 
oExcel:AddColumn(cPlan, cTit, "Aguard.Lib." , 3, 2, .F.)  //09
oExcel:AddColumn(cPlan, cTit, "Aguard.Crd." , 3, 2, .F.)  //10
oExcel:AddColumn(cPlan, cTit, "Aguard.Fat." , 3, 2, .F.)  //11
oExcel:AddColumn(cPlan, cTit, "Fat.no Dia "+DTOC(DDATABASE) , 3, 2, .F.)  //12
oExcel:AddColumn(cPlan, cTit, "PVs.no Dia "+DTOC(DDATABASE)  , 3, 2, .F.)  //13
If MV_PAR07 = 1
	oExcel:AddColumn(cPlan, cTit, "Vlr.de custo."  , 3, 2, .F.)  //14
	oExcel:AddColumn(cPlan, cTit, "Vlr.de fat.Liq."  , 3, 2, .F.)  //15
EndIf
oExcel:AddColumn(cPlan, cTit, "Volume"  , 3, 2, .F.)  //16
oExcel:AddColumn(cPlan, cTit, "Preço Medio"  , 3, 2, .F.)  //17
oExcel:AddColumn(cPlan, cTit, "Base de Comissão"  , 3, 2, .F.)  //18


// Query referente ao Portal na rotina BeP0504.prw

cQuery := "SELECT GERENTE, VENDEDOR, NOME, SUM(TOTAL) AS TOTAL, SUM(DEVOLUCAO) AS DEVOLUCAO, SUM(CARTEIRA) AS CARTEIRA, SUM(CREDITO) AS CREDITO, SUM(ESTOQUE) AS ESTOQUE, SUM(AFATURAR) AS AFATURAR, SUM(BRUTO) AS BRUTO, SUM(META) AS META, SUM(BASECOM) AS BASECOM, SUM(VENDDIA) AS VENDDIA, SUM(CUSTO) AS CUSTO, SUM(VALOR) AS VALOR, SUM(VDDIA) AS VDDIA, SUM(VOLUME) AS VOLUME, AVG(PRECOMEDIO) AS PRECOMEDIO " + CRLF
cQuery += "FROM  ( " + CRLF
cQuery += "SELECT ISNULL(A3_GEREN, '') AS GERENTE, ISNULL(A3_COD, '') AS VENDEDOR, ISNULL(A3_NOME, '') AS NOME, SUM(D2_VALBRUT - D2_VALIPI - D2_VALICM - D2_VALIMP5 - D2_VALIMP6 - D2_DESPESA - D2_VALFRE - D2_DESCON - D2_SEGURO - D2_ICMSRET) AS TOTAL, 0 AS DEVOLUCAO, 0 AS CARTEIRA, 0 AS CREDITO, 0 AS ESTOQUE, 0 AS AFATURAR, SUM(D2_VALBRUT) AS BRUTO, 0 AS META, ISNULL(SUM(D2_VALBRUT - D2_VALIPI - D2_ICMSRET), 0) AS BASECOM, 0 AS VENDDIA, SUM(D2_CUSTO1) CUSTO, ISNULL(SUM(D2_VALBRUT - D2_VALIPI - D2_VALICM - D2_VALIMP5 - D2_VALIMP6 - D2_DESPESA - D2_VALFRE - D2_DESCON - D2_SEGURO - D2_ICMSRET), 0) AS VALOR, 0 AS VDDIA, SUM(CASE WHEN D2_SEGUM = 'KG' AND B1_CONV <> 0 THEN D2_QTSEGUM ELSE D2_QUANT END) AS VOLUME, AVG(CASE WHEN B1_SEGUM = 'KG' AND B1_CONV <> 0 THEN CASE WHEN B1_TIPCONV = 'M' THEN D2_PRCVEN / B1_CONV ELSE D2_PRCVEN * B1_CONV END ELSE D2_PRCVEN END) AS PRECOMEDIO " + CRLF
cQuery += "FROM " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SF2") + " AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL " + CRLF
cQuery += "  AND F2_DOC = D2_DOC " + CRLF
cQuery += "  AND F2_SERIE = D2_SERIE " + CRLF
cQuery += "  AND F2_CLIENTE = D2_CLIENTE " + CRLF
cQuery += "  AND F2_LOJA = D2_LOJA " + CRLF
cQuery += "  AND F2_TIPO = D2_TIPO " + CRLF
cQuery += "  AND F2_EMISSAO = D2_EMISSAO " + CRLF
cQuery += "  AND SF2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = '"+SubStr(XFilial("SF4"),1,2)+"' " + CRLF
cQuery += "  AND F4_CODIGO = D2_TES " + CRLF
cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
cQuery += "  AND NOT SUBSTRING(F4_CF,2,3) IN ('124') " + CRLF
cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + XFILIAL("SB1") + "' " + CRLF
cQuery += "  AND B1_COD = D2_COD " + CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "LEFT JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_FILIAL = '" + XFILIAL("SA3") + "' " + CRLF
cQuery += "  AND A3_COD = F2_VEND1 " + CRLF
cQuery += "  AND SA3.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE D2_FILIAL = '"+xFilial("SD2")+"' " + CRLF
cQuery += "AND D2_TIPO = 'N' " + CRLF
cQuery += "AND D2_EMISSAO BETWEEN '" +DTOS(MV_PAR01)+ "' AND '" +DTOS(MV_PAR02)+ "' " + CRLF
cQuery += "AND A3_COD BETWEEN '" +AllTrim(MV_PAR03)+ "' AND '" +AllTrim(MV_PAR04)+ "' " + CRLF
cQuery += "AND A3_GEREN BETWEEN '" +AllTrim(MV_PAR05)+ "' AND '" +AllTrim(MV_PAR06)+ "' " + CRLF
cQuery += "AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = D2_FILIAL AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
cQuery += "AND SD2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "GROUP BY A3_GEREN, A3_COD, A3_NOME " + CRLF

cQuery += "UNION ALL " + CRLF+ CRLF

cQuery += "SELECT ISNULL(A3_GEREN, '') AS GERENTE, ISNULL(A3_COD, '') AS VENDEDOR, ISNULL(A3_NOME, '') AS NOME, 0 AS TOTAL, 0 AS DEVOLUCAO, 0 AS CARTEIRA, 0 AS CREDITO, 0 AS ESTOQUE, 0 AS AFATURAR, 0 AS BRUTO, 0 AS META,  0 AS BASECOM, 0 AS VENDDIA, 0 AS CUSTO,  0 AS VALOR, SUM(D2_TOTAL) AS VDDIA, 0 AS VOLUME, 0 AS PRECOMEDIO " + CRLF
cQuery += "FROM " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SF2") + " AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL " + CRLF
cQuery += "  AND F2_DOC = D2_DOC " + CRLF
cQuery += "  AND F2_SERIE = D2_SERIE " + CRLF
cQuery += "  AND F2_CLIENTE = D2_CLIENTE " + CRLF
cQuery += "  AND F2_LOJA = D2_LOJA " + CRLF
cQuery += "  AND F2_TIPO = D2_TIPO " + CRLF
cQuery += "  AND F2_EMISSAO = D2_EMISSAO " + CRLF
cQuery += "  AND SF2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = '"+SubStr(XFilial("SF4"),1,2)+"' " + CRLF
cQuery += "  AND F4_CODIGO = D2_TES " + CRLF
cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
cQuery += "  AND NOT SUBSTRING(F4_CF,2,3) IN ('124') " + CRLF
cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + XFILIAL("SB1") + "' " + CRLF
cQuery += "  AND B1_COD = D2_COD " + CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "LEFT JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_FILIAL = '" + XFILIAL("SA3") + "' " + CRLF
cQuery += "  AND A3_COD = F2_VEND1 " + CRLF
cQuery += "  AND SA3.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE D2_FILIAL = '"+xFilial("SD2")+"' " + CRLF
cQuery += "AND D2_TIPO = 'N' " + CRLF
cQuery += "AND D2_EMISSAO = '" +DTOS(DDATABASE)+ "' " + CRLF
cQuery += "AND A3_COD BETWEEN '" +AllTrim(MV_PAR03)+ "' AND '" +AllTrim(MV_PAR04)+ "' " + CRLF
cQuery += "AND A3_GEREN BETWEEN '" +AllTrim(MV_PAR05)+ "' AND '" +AllTrim(MV_PAR06)+ "' " + CRLF
cQuery += "AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = D2_FILIAL AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
cQuery += "AND SD2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "GROUP BY A3_GEREN, A3_COD, A3_NOME " + CRLF

cQuery += "UNION ALL " + CRLF+ CRLF

cQuery += "SELECT ISNULL(A3_GEREN, '') AS GERENTE, ISNULL(A3_COD, '') AS VENDEDOR, ISNULL(A3_NOME, '') AS NOME, 0 AS TOTAL, SUM((D1_TOTAL-D1_VALDESC-D1_VALIPI+D1_DESPESA+D1_VALFRE+D1_SEGURO-D1_ICMSRET-D1_VALICM-D1_VALIMP5-D1_VALIMP6)) * (-1) AS DEVOLUCAO, 0 AS CARTEIRA, 0 AS CREDITO, 0 AS ESTOQUE, 0 AS AFATURAR, 0 AS BRUTO, 0 AS META, 0 AS BASECOM, 0 AS VENDDIA, 0 AS CUSTO, 0 AS VALOR, 0 AS VOLUME, 0 AS VDDIA , 0 AS PRECOMEDIO " + CRLF
cQuery += "FROM " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) ON D2_FILIAL = D1_FILIAL " + CRLF
cQuery += "  AND D2_DOC = D1_NFORI " + CRLF
cQuery += "  AND D2_SERIE = D1_SERIORI " + CRLF
cQuery += "  AND D2_CLIENTE = D1_FORNECE " + CRLF
cQuery += "  AND D2_LOJA = D1_LOJA " + CRLF
cQuery += "  AND D2_ITEM = D1_ITEMORI " + CRLF
cQuery += "  AND D2_TIPO = 'N' " + CRLF
cQuery += "  AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = D2_FILIAL AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
cQuery += "  AND SD2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SF2") + " AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL " + CRLF
cQuery += "  AND F2_DOC = D2_DOC " + CRLF
cQuery += "  AND F2_SERIE = D2_SERIE " + CRLF
cQuery += "  AND F2_CLIENTE = D2_CLIENTE " + CRLF
cQuery += "  AND F2_LOJA = D2_LOJA " + CRLF
cQuery += "  AND F2_TIPO = D2_TIPO " + CRLF
cQuery += "  AND F2_EMISSAO = D2_EMISSAO " + CRLF
cQuery += "  AND SF2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = '"+SubStr(XFilial("SF4"),1,2)+"' " + CRLF
cQuery += "  AND F4_CODIGO = D2_TES " + CRLF
cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
cQuery += "  AND NOT SUBSTRING(F4_CF,2,3) IN ('124') " + CRLF
cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "LEFT JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_FILIAL = '"  + XFILIAL("SA3") + "' " + CRLF
cQuery += "  AND A3_COD = F2_VEND1 " + CRLF
cQuery += "  AND SA3.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE LEFT(D1_FILIAL, 2) = '"+SubStr(XFilial("SD1"),1,2)+"' " + CRLF
cQuery += "AND D1_TIPO = 'D' " + CRLF
cQuery += "AND D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR01)+ "' AND '" + DTOS(MV_PAR02)+ "' " + CRLF
cQuery += "AND A3_COD BETWEEN '" +AllTrim(MV_PAR03)+ "' AND '" +AllTrim(MV_PAR04)+ "' " + CRLF
cQuery += "AND A3_GEREN BETWEEN '" +AllTrim(MV_PAR05)+ "' AND '" +AllTrim(MV_PAR06)+ "' " + CRLF
cQuery += "AND SD1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "GROUP BY A3_GEREN, A3_COD, A3_NOME " + CRLF

cQuery += "UNION ALL " + CRLF+ CRLF

cQuery += "SELECT ISNULL(A3_GEREN, '') AS GERENTE, ISNULL(A3_COD, '') AS VENDEDOR, ISNULL(A3_NOME, '') AS NOME, 0 AS TOTAL, 0 AS DEVOLUCAO, ISNULL(SUM(((C6_QTDVEN - C6_QTDENT ) * C6_PRCVEN)), 0) AS CARTEIRA, 0 AS CREDITO, 0 AS ESTOQUE, 0 AS AFATURAR, 0 AS BRUTO, 0 AS META, 0 AS BASECOM, 0 AS VENDDIA, 0 AS CUSTO, 0 AS VALOR, 0 AS VOLUME, 0 AS VDDIA, 0 AS PRECOMEDIO " + CRLF
cQuery += "FROM " + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SC5") + " AS SC5 WITH (NOLOCK) ON C5_FILIAL = C6_FILIAL " + CRLF
cQuery += "  AND C5_NUM = C6_NUM " + CRLF
cQuery += "  AND C5_TIPO = 'N' " + CRLF
cQuery += "  AND C5_LIBEROK = '' " + CRLF
cQuery += "  AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = C5_FILIAL AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
cQuery += "  AND SC5.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = '"+SubStr(XFilial("SF4"),1,2)+"' " + CRLF
cQuery += "  AND F4_CODIGO = C6_TES " + CRLF
cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
cQuery += "  AND NOT SUBSTRING(F4_CF,2,3) IN ('124') " + CRLF
cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + XFILIAL("SB1") + "' " + CRLF
cQuery += "  AND B1_COD = C6_PRODUTO " + CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) ON B2_FILIAL = C6_FILIAL " + CRLF
cQuery += "  AND B2_COD = C6_PRODUTO " + CRLF
cQuery += "  AND B2_LOCAL = C6_LOCAL " + CRLF
cQuery += "  AND SB2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "LEFT JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_FILIAL = '" + XFILIAL("SA3") + "' " + CRLF
cQuery += "  AND A3_COD = C5_VEND1 " + CRLF
cQuery += "  AND SA3.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE LEFT(C6_FILIAL, 2) = '"+SubStr(XFilial("SC6"),1,2)+"' " + CRLF
cQuery += "AND C6_BLQ = '' " + CRLF
cQuery += "AND C6_QTDVEN > C6_QTDENT " + CRLF
cQuery += "AND A3_COD BETWEEN '" +AllTrim(MV_PAR03)+ "' AND '" +AllTrim(MV_PAR04)+ "' " + CRLF
cQuery += "AND A3_GEREN BETWEEN '" +AllTrim(MV_PAR05)+ "' AND '" +AllTrim(MV_PAR06)+ "' " + CRLF
cQuery += "AND SC6.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "GROUP BY A3_GEREN, A3_COD, A3_NOME " + CRLF

cQuery += "UNION ALL " + CRLF+ CRLF

cQuery += "SELECT ISNULL(A3_GEREN, '') AS GERENTE, ISNULL(A3_COD, '') AS VENDEDOR, ISNULL(A3_NOME, '') AS NOME, 0 AS TOTAL, 0 AS DEVOLUCAO, 0 AS CARTEIRA, SUM((C9_QTDLIB * C9_PRCVEN)) AS CREDITO, 0 AS ESTOQUE, 0 AS AFATURAR, 0 AS BRUTO, 0 AS META, 0 AS BASECOM, 0 AS VENDDIA, 0 AS CUSTO, 0 AS VALOR, 0 AS VOLUME, 0 AS VDDIA,  0 AS PRECOMEDIO " + CRLF
cQuery += "FROM " + RetSqlName("SC9") + " AS SC9 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) ON C6_FILIAL = C9_FILIAL " + CRLF
cQuery += "  AND C6_NUM = C9_PEDIDO " + CRLF
cQuery += "  AND C6_ITEM = C9_ITEM " + CRLF
cQuery += "  AND C6_BLQ = '' " + CRLF
cQuery += "  AND C6_QTDVEN > C6_QTDENT " + CRLF
cQuery += "  AND SC6.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SC5") + " AS SC5 WITH (NOLOCK) ON C5_FILIAL = C6_FILIAL " + CRLF
cQuery += "  AND C5_NUM = C6_NUM " + CRLF
cQuery += "  AND C5_TIPO = 'N' " + CRLF
cQuery += "  AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = C5_FILIAL AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
cQuery += "  AND SC5.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = '"+SubStr(XFilial("SF4"),1,2)+"' " + CRLF
cQuery += "  AND F4_CODIGO = C6_TES " + CRLF
cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
cQuery += "  AND NOT SUBSTRING(F4_CF,2,3) IN ('124') " + CRLF
cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + XFILIAL("SB1") + "' " + CRLF
cQuery += "  AND B1_COD = C6_PRODUTO " + CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) ON B2_FILIAL = C6_FILIAL " + CRLF
cQuery += "  AND B2_COD = C6_PRODUTO " + CRLF
cQuery += "  AND B2_LOCAL = C6_LOCAL " + CRLF
cQuery += "  AND SB2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "LEFT JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_FILIAL = '" + XFILIAL("SA3") + "' " + CRLF
cQuery += "  AND A3_COD = C5_VEND1 " + CRLF
cQuery += "  AND SA3.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE LEFT(C6_FILIAL, 2) = '"+SubStr(XFilial("SC6"),1,2)+"' " + CRLF
cQuery += "AND C9_NFISCAL = '' " + CRLF
cQuery += "AND C9_BLCRED <> '' " + CRLF
cQuery += "AND A3_COD BETWEEN '" +AllTrim(MV_PAR03)+ "' AND '" +AllTrim(MV_PAR04)+ "' " + CRLF
cQuery += "AND A3_GEREN BETWEEN '" +AllTrim(MV_PAR05)+ "' AND '" +AllTrim(MV_PAR06)+ "' " + CRLF
cQuery += "AND SC9.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "GROUP BY A3_GEREN, A3_COD, A3_NOME " + CRLF

cQuery += "UNION ALL " + CRLF+ CRLF

cQuery += "SELECT ISNULL(A3_GEREN, '') AS GERENTE, ISNULL(A3_COD, '') AS VENDEDOR, ISNULL(A3_NOME, '') AS NOME, 0 AS TOTAL, 0 AS DEVOLUCAO, 0 AS CARTEIRA, 0 AS CREDITO, SUM((C9_QTDLIB * C9_PRCVEN)) AS ESTOQUE, 0 AS AFATURAR, 0 AS BRUTO, 0 AS META, 0 AS BASECOM, 0 AS VENDDIA, 0 AS CUSTO, 0 AS VALOR, 0 AS VOLUME, 0 AS VDDIA, 0 AS PRECOMEDIO " + CRLF
cQuery += "FROM " + RetSqlName("SC9") + " AS SC9 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) ON C6_FILIAL = C9_FILIAL " + CRLF
cQuery += "  AND C6_NUM = C9_PEDIDO " + CRLF
cQuery += "  AND C6_ITEM = C9_ITEM " + CRLF
cQuery += "  AND C6_BLQ = '' " + CRLF
cQuery += "  AND C6_QTDVEN > C6_QTDENT " + CRLF
cQuery += "  AND SC6.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SC5") + " AS SC5 WITH (NOLOCK) ON C5_FILIAL = C6_FILIAL " + CRLF
cQuery += "  AND C5_NUM = C6_NUM " + CRLF
cQuery += "  AND C5_TIPO = 'N' " + CRLF
cQuery += "  AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = C5_FILIAL AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
cQuery += "  AND SC5.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = '"+SubStr(XFilial("SF4"),1,2)+"' " + CRLF
cQuery += "  AND F4_CODIGO = C6_TES " + CRLF
cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
cQuery += "  AND NOT SUBSTRING(F4_CF,2,3) IN ('124') " + CRLF
cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + XFILIAL("SB1") + "' " + CRLF
cQuery += "  AND B1_COD = C6_PRODUTO " + CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) ON B2_FILIAL = C6_FILIAL " + CRLF
cQuery += "  AND B2_COD = C6_PRODUTO " + CRLF
cQuery += "  AND B2_LOCAL = C6_LOCAL " + CRLF
cQuery += "  AND SB2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "LEFT JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_FILIAL = '" + XFILIAL("SA3") + "' " + CRLF
cQuery += "  AND A3_COD = C5_VEND1 " + CRLF
cQuery += "  AND SA3.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE C6_FILIAL = '"+xFilial("SC6")+"' " + CRLF
cQuery += "AND A3_COD BETWEEN '" +AllTrim(MV_PAR03)+ "' AND '" +AllTrim(MV_PAR04)+ "' " + CRLF
cQuery += "AND A3_GEREN BETWEEN '" +AllTrim(MV_PAR05)+ "' AND '" +AllTrim(MV_PAR06)+ "' " + CRLF
cQuery += "AND C9_NFISCAL = '' " + CRLF
cQuery += "AND C9_BLCRED = '' " + CRLF
cQuery += "AND C9_BLEST <> '' " + CRLF
cQuery += "AND SC9.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "GROUP BY A3_GEREN, A3_COD, A3_NOME " + CRLF

cQuery += "UNION ALL " + CRLF+ CRLF

cQuery += "SELECT ISNULL(A3_GEREN, '') AS GERENTE, ISNULL(A3_COD, '') AS VENDEDOR, ISNULL(A3_NOME, '') AS NOME, 0 AS TOTAL, 0 AS DEVOLUCAO, 0 AS CARTEIRA, 0 AS CREDITO, 0 AS ESTOQUE, SUM((C9_QTDLIB * C9_PRCVEN)) AS AFATURAR, 0 AS BRUTO, 0 AS META, 0 AS BASECOM, 0 AS VENDDIA, 0 AS CUSTO, 0 AS VALOR, 0 AS VOLUME, 0 AS VDDIA, 0 AS PRECOMEDIO " + CRLF
cQuery += "FROM " + RetSqlName("SC9") + " AS SC9 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) ON C6_FILIAL = C9_FILIAL " + CRLF
cQuery += "  AND C6_NUM = C9_PEDIDO " + CRLF
cQuery += "  AND C6_ITEM = C9_ITEM " + CRLF
cQuery += "  AND C6_BLQ = '' " + CRLF
cQuery += "  AND C6_QTDVEN > C6_QTDENT " + CRLF
cQuery += "  AND SC6.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SC5") + " AS SC5 WITH (NOLOCK) ON C5_FILIAL = C6_FILIAL " + CRLF
cQuery += "  AND C5_NUM = C6_NUM " + CRLF
cQuery += "  AND C5_TIPO = 'N' " + CRLF
cQuery += "  AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = C5_FILIAL AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
cQuery += "  AND SC5.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = '"+SubStr(XFilial("SF4"),1,2)+"' " + CRLF
cQuery += "  AND F4_CODIGO = C6_TES " + CRLF
cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
cQuery += "  AND NOT SUBSTRING(F4_CF,2,3) IN ('124','929') " + CRLF
cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + XFILIAL("SB1") + "' " + CRLF
cQuery += "  AND B1_COD = C6_PRODUTO " + CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) ON B2_FILIAL = C6_FILIAL " + CRLF
cQuery += "  AND B2_COD = C6_PRODUTO " + CRLF
cQuery += "  AND B2_LOCAL = C6_LOCAL " + CRLF
cQuery += "  AND SB2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "LEFT JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_FILIAL = '" + XFILIAL("SA3") + "' " + CRLF
cQuery += "  AND A3_COD = C5_VEND1 " + CRLF
cQuery += "  AND SA3.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE LEFT(C6_FILIAL, 2) = '"+SubStr(XFilial("SC6"),1,2)+"' " + CRLF
//cQuery += "AND A3_COD BETWEEN '" +AllTrim(MV_PAR03)+ "' AND '" +AllTrim(MV_PAR04)+ "' " + CRLF
//cQuery += "AND A3_GEREN BETWEEN '" +AllTrim(MV_PAR05)+ "' AND '" +AllTrim(MV_PAR06)+ "' " + CRLF
cQuery += "AND C9_NFISCAL = '' " + CRLF
cQuery += "AND C9_BLCRED = '' " + CRLF
cQuery += "AND C9_BLEST = '' " + CRLF
cQuery += "AND SC9.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "GROUP BY A3_GEREN, A3_COD, A3_NOME " + CRLF

cQuery += "UNION ALL " + CRLF+ CRLF

cQuery += "SELECT ISNULL(A3_GEREN, '') AS GERENTE, ISNULL(A3_COD, '') AS VENDEDOR, ISNULL(A3_NOME, '') AS NOME, 0 AS TOTAL, 0 AS DEVOLUCAO, 0 AS CARTEIRA, 0 AS CREDITO, 0 AS ESTOQUE, 0 AS AFATURAR, 0 AS BRUTO, SUM(CT_VALOR) AS META, 0 AS BASECOM, 0 AS VENDDIA, 0 AS CUSTO, 0 AS VALOR, 0 AS VOLUME, 0 AS VDDIA, 0 AS PRECOMEDIO " + CRLF
cQuery += "FROM " + RetSqlName("SCT") + " AS SCT WITH (NOLOCK) " + CRLF
cQuery += "LEFT JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_FILIAL = '" + XFILIAL("SA3") + "' " + CRLF
cQuery += "  AND A3_COD = CT_VEND " + CRLF
cQuery += "  AND SA3.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE LEFT(CT_FILIAL, 2) = '"+SubStr(XFilial("SCT"),1,2)+"' " + CRLF
cQuery += "AND CT_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' " + CRLF
cQuery += "AND A3_COD BETWEEN '" +AllTrim(MV_PAR03)+ "' AND '" +AllTrim(MV_PAR04)+ "' " + CRLF
cQuery += "AND A3_GEREN BETWEEN '" +AllTrim(MV_PAR05)+ "' AND '" +AllTrim(MV_PAR06)+ "' " + CRLF
cQuery += "AND CT_MSBLQL <> '1' " + CRLF
cQuery += "AND SCT.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "GROUP BY A3_GEREN, A3_COD, A3_NOME " + CRLF

cQuery += "UNION ALL " + CRLF+ CRLF

cQuery += "SELECT ISNULL(A3_GEREN, '') AS GERENTE, ISNULL(A3_COD, '') AS VENDEDOR, ISNULL(A3_NOME, '') AS NOME, 0 AS TOTAL, 0 AS DEVOLUCAO, 0 AS CARTEIRA, 0 AS CREDITO, 0 AS ESTOQUE, 0 AS AFATURAR, 0 AS BRUTO, 0 AS META, 0 AS BASECOM, ISNULL(SUM(((C6_QTDVEN) * C6_PRCVEN)), 0) AS VENDDIA, 0 AS CUSTO, 0 AS VALOR, 0 AS VOLUME, 0 AS VDDIA, 0 AS PRECOMEDIO " + CRLF
cQuery += "FROM " + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SC5") + " AS SC5 WITH (NOLOCK) ON C5_FILIAL = C6_FILIAL " + CRLF
cQuery += "  AND C5_NUM = C6_NUM " + CRLF
cQuery += "  AND C5_TIPO = 'N' " + CRLF
cQuery += "  AND C5_EMISSAO = '"+DTOS(dDataBase)+"' " + CRLF
cQuery += "  AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = C5_FILIAL AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + CRLF
cQuery += "  AND SC5.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = '"+SubStr(XFilial("SF4"),1,2)+"' " + CRLF
cQuery += "  AND F4_CODIGO = C6_TES " + CRLF
cQuery += "  AND F4_DUPLIC = 'S' " + CRLF
cQuery += "  AND NOT SUBSTRING(F4_CF,2,3) IN ('124') " + CRLF
cQuery += "  AND SF4.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + XFILIAL("SB1") + "' " + CRLF
cQuery += "  AND B1_COD = C6_PRODUTO " + CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) ON B2_FILIAL = C6_FILIAL " + CRLF
cQuery += "  AND B2_COD = C6_PRODUTO " + CRLF
cQuery += "  AND B2_LOCAL = C6_LOCAL " + CRLF
cQuery += "  AND SB2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "LEFT JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_FILIAL = '" + XFILIAL("SA3") + "' " + CRLF
cQuery += "  AND A3_COD = C5_VEND1 " + CRLF
cQuery += "  AND SA3.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE LEFT(C6_FILIAL, 2) = '"+SubStr(XFilial("SC6"),1,2)+"' " + CRLF
cQuery += "AND A3_COD BETWEEN '" +AllTrim(MV_PAR03)+ "' AND '" +AllTrim(MV_PAR04)+ "' " + CRLF
cQuery += "AND A3_GEREN BETWEEN '" +AllTrim(MV_PAR05)+ "' AND '" +AllTrim(MV_PAR06)+ "' " + CRLF
cQuery += "AND C6_BLQ = '' " + CRLF
cQuery += "AND SC6.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "GROUP BY A3_GEREN, A3_COD, A3_NOME " + CRLF
cQuery += ") AS AGRUPADO " + CRLF
cQuery += "GROUP BY GERENTE, VENDEDOR, NOME " + CRLF
cQuery += "ORDER BY GERENTE, VENDEDOR, NOME " + CRLF

TCQuery cQuery New Alias "TRB1"
dbSelectArea("TRB1")
SA3->(DbSetOrder(1))
TRB1->(DbGoTop())
While TRB1->(!Eof())

	aAdd(aDados,{TRB1->GERENTE,;        // 01
				 TRB1->VENDEDOR,;       // 02
				 TRB1->NOME,;           // 03
				 TRB1->BASECOM,;        // 04
				 ABS(TRB1->DEVOLUCAO),; // 05
			 	 TRB1->CARTEIRA,;       // 06
				 TRB1->CREDITO,;        // 07
				 TRB1->AFATURAR+TRB1->ESTOQUE,;// 08
				 TRB1->VENDDIA,;        // 09
				 0,;                    // 10
				 TRB1->AFATURAR,;       // 11	
				 TRB1->META,;           // 12
				 TRB1->CUSTO,;          // 13
				 TRB1->VALOR,;          // 14
				 TRB1->VOLUME,;         // 15
				 TRB1->PRECOMEDIO,;     // 16
				 TRB1->BASECOM,;        // 17
				 0,;                    // 18
				 TRB1->VDDIA})          // 19

	TRB1->(DbSkip())
EndDo

TRB1->(DbCloseArea())

If Len(aDados) > 0
	aSort(aDados,,, {|x,y| x[1] < y[1]})
	cQuebra := aDados[1, 1]
	nTotal1 := 0
	nTotal2 := 0
	nTotal3 := 0
	nTotal4 := 0
	nTotal5 := 0
	nTotal6 := 0
	nTotal7 := 0
	nTotal8 := 0
	nTotal9 := 0
	nTotal10 := 0
	nTotal90 := 0
	nTotal91 := 0
	nTotal92 := 0
	
	For n1 := 1 To Len(aDados)
		nTotal1G  += aDados[n1, 4] - aDados[n1, 5]
		nTotal2G  += aDados[n1, 5]
		nTotal3G  += aDados[n1, 6]
		nTotal4G  += aDados[n1, 7]
		nTotal5G  += aDados[n1, 8]
		nTotal6G  += aDados[n1,19]
		nTotal7G  += aDados[n1, 9]
		nTotal9G  += aDados[n1,12]
		nTotal10G += aDados[n1,13]
		nTotal90G += aDados[n1,14]
		nTotal91G += aDados[n1,13]
		nTotal92G += (aDados[n1,17] - aDados[n1, 5] )
		
		If cQuebra == aDados[n1, 1]
			
			If Left(cFilAnt,2) == "08"
				If	Empty(cQuebra)
			cRegiao :=  "TOTAL DA REGIAO - CD JAYS"  
				ElseIf cQuebra == "000001"
			cRegiao :=  "TOTAL REGIONAL SÃO PAULO 2"//"TOTAL DA REGIAO - INTERIOR 2"
				ElseIf cQuebra == "000035"
			cRegiao :=  "TOTAL DA REGIAO - INTERNO"
				ElseIf cQuebra == "000093"
			cRegiao :=  "TOTAL DA REGIAO - LITORAL"
				ElseIf Alltrim(cQuebra) $ "001995|002065"
			cRegiao := "TOTAL DA REGIAO - NOVOS NEGOCIOS"
				ElseIf Alltrim(cQuebra) $ "002003|002047"
			cRegiao :=  "TOTAL DA REGIAO - RIO CENTRO"
				ElseIf cQuebra == "002027"
			cRegiao :=  "TOTAL DA REGIAO - SUL"
				ElseIf cQuebra == "002048"
			cRegiao :=  "TOTAL DA REGIAO SÃO PAULO 1"
				ElseIf cQuebra == "002071"
			cRegiao :=  "TOTAL DICICO"
				Else
			cRegiao :=  "TOTAL DA REGIAO"
				EndIf
			Else
				cRegiao :=  "TOTAL GERENTE"
			EndIf	

			If MV_PAR07 == 1

				oExcel:AddRow(cPlan, cTit,{aDados[n1, 1],;  //gerente
				aDados[n1, 2],;  //vendedor
				aDados[n1, 3],;	 //nome
				aDados[n1, 12],; //Meta
				aDados[n1, 4] - aDados[n1, 5],;	//fat.geral
				Transform(IIf(aDados[n1, 4] <= 0, 0, 100 - ((aDados[n1, 13] / aDados[n1, 14]) * 100)),"@R 9999.99%"),;
				aDados[n1, 5],;	//devolucoes
				Iif(aDados[n1, 12] > 0, Transform(((aDados[n1, 4]-aDados[n1, 5]) / aDados[n1, 12])*100,"@R 9999%"),"") ,;
				aDados[n1, 6],;	//aguard.lib
				aDados[n1, 7],;	//aguard.crd
				aDados[n1, 8],;	//aguard.fat 
				aDados[n1, 19],; //fat.dia
				aDados[n1, 9],;	//pedido dia
				aDados[n1,13],; // custo 
				aDados[n1,14],; // Valor Liquido
				aDados[n1,15],; // Volume 
				aDados[n1,16],; // Preço medio
				(aDados[n1,17] - aDados[n1, 5])}) // Base de Comissão 
			
			EndIf

			If MV_PAR07 = 2

				oExcel:AddRow(cPlan, cTit,{aDados[n1, 1],;  //gerente
				aDados[n1, 2],;   //vendedor
				aDados[n1, 3],;	  //nome
				aDados[n1, 12],;  //Meta
				aDados[n1, 4] - aDados[n1, 5],;	//fat.geral
				aDados[n1, 5],;	//devolucoes
				Iif(aDados[n1, 12] > 0, Transform(((aDados[n1, 4]-aDados[n1, 5]) / aDados[n1, 12])*100,"@R 9999%"),"") ,;
				aDados[n1, 6],;	//aguard.lib
				aDados[n1, 7],;	//aguard.crd
				aDados[n1, 8],;	//aguard.fat
				aDados[n1, 19],; //fat.dia
				aDados[n1, 9],;	 //pedido dia
				aDados[n1,15],; // Volume 
				aDados[n1,16],; // Preço medio
				(aDados[n1,17] - aDados[n1, 5])}) // Base de Comissão 
			
			EndIf

			nTotal1 += aDados[n1, 4] - aDados[n1, 5] 
			nTotal2 += aDados[n1, 5]
			nTotal3 += aDados[n1, 6]
			nTotal4 += aDados[n1, 7]
			nTotal5 += aDados[n1, 8]
			nTotal6 += aDados[n1,19]
			nTotal7 += aDados[n1, 9]
			nTotal9 += aDados[n1,12]
			nTotal10+= aDados[n1,13]
			nTotal90+= aDados[n1,14]
			nTotal91+= aDados[n1,13]
			nTotal92+= (aDados[n1,17] - aDados[n1, 5])  

		Else

			If Left(cFilAnt,2) == "08"
				If	Empty(cQuebra)
			cRegiao :=  "TOTAL DA REGIAO - CD JAYS"  
				ElseIf cQuebra == "000001"
			cRegiao :=  "TOTAL REGIONAL SÃO PAULO 2"//"TOTAL DA REGIAO - INTERIOR 2"
				ElseIf cQuebra == "000035"
			cRegiao :=  "TOTAL DA REGIAO - INTERNO"
				ElseIf cQuebra == "000093"
			cRegiao :=  "TOTAL DA REGIAO - LITORAL"
				ElseIf Alltrim(cQuebra) $ "001995|002065"
			cRegiao := "TOTAL DA REGIAO - NOVOS NEGOCIOS"
				ElseIf Alltrim(cQuebra) $ "002003|002047"
			cRegiao :=  "TOTAL DA REGIAO - RIO CENTRO"
				ElseIf cQuebra == "002027"
			cRegiao :=  "TOTAL DA REGIAO - SUL"
				ElseIf cQuebra == "002048"
			cRegiao :=  "TOTAL DA REGIAO SÃO PAULO 1"
				ElseIf cQuebra == "002071"
			cRegiao :=  "TOTAL DICICO"
				Else
			cRegiao :=  "TOTAL DA REGIAO"
				EndIf
			Else
				cRegiao :=  "TOTAL GERENTE"
			EndIf	

			If MV_PAR07 == 1
				oExcel:AddRow(cPlan, cTit,{"",;  //gerente
				"",;  //vendedor
				cRegiao,; // Região
				nTotal9,;  //Meta
				nTotal1,;  //fat.geral
				Transform(IIf(nTotal1 <= 0, 0, 100 - ((nTotal91 / nTotal90) * 100)),"@R 9999.99%"),;//Fator (Transform(IIf(nTotal1 <= 0, 0, 100.00 - ((nTotal10 / nTotal1) * 100.00)),"@R 999.99%"))
				nTotal2,;  //devolucoes
				Iif(nTotal9 > 0,Transform(( (nTotal1-nTotal2) / nTotal9)*100,"@R 9999%"),""),;  //% Atend.
				nTotal3,;  //aguard.lib
				nTotal4,;  //aguard.crd
				nTotal5,;  //aguard.fat
				nTotal6,;  //fat.dia
				nTotal7,;  //pedido dia
				nTotal91,; //custo 
				nTotal90,; // 
				"",; //
				"",; //
				nTotal92})

			EndIf

			If MV_PAR07 == 2
				oExcel:AddRow(cPlan, cTit,{"",;  //gerente
				"",;  //vendedor
				cRegiao,; // Região
				nTotal9,;  //Meta
				nTotal1,;  //fat.geral
				nTotal2,;  //devolucoes
				Iif(nTotal9 > 0,Transform(( (nTotal1-nTotal2) / nTotal9)*100,"@R 9999%"),""),;  //% Atend.
				nTotal3,;  //aguard.lib
				nTotal4,;  //aguard.crd
				nTotal5,;  //aguard.fat
				nTotal6,;  //fat.dia
				nTotal7,;  //pedido dia
				"",; //
				"",; //
				nTotal92})  
			EndIf	

			iF MV_PAR07 == 1
				oExcel:AddRow(cPlan, cTit,{;
				"",;  //01
				"",;  //02
				"",;  //03
				"",;  //04
				"",;  //05
				"",;  //06
				"",;  //07
				"",;  //08
				"",;  //09
				"",;  //10
				"",;  //11
				"",;  //12	
				"",;  //13
				"",;  //14
				"",;  //15
				"",;  //16
				"",;  //17
				""})  //18 
			EndIf

			iF MV_PAR07 == 2
				oExcel:AddRow(cPlan, cTit,{;
				"",;  //01
				"",;  //02
				"",;  //03
				"",;  //04
				"",;  //05
				"",;  //07
				"",;  //08
				"",;  //09
				"",;  //10
				"",;  //11
				"",;  //12	
				"",;  //13
				"",;  //14
				"",;  //15
				""})  //16 
			EndIf

			cQuebra := aDados[n1, 1]
			nTotal1 := aDados[n1, 4] - aDados[n1, 5] //aDados[n1, 4]
			nTotal2 := aDados[n1, 5]
			nTotal3 := aDados[n1, 6]
			nTotal4 := aDados[n1, 7]
			nTotal5 := aDados[n1, 8]
			nTotal6 := aDados[n1,19]
			nTotal7 := aDados[n1, 9]
			nTotal9 := aDados[n1,12]
			nTotal10:= aDados[n1,13]
			nTotal90:= aDados[n1,14]
			nTotal91:= aDados[n1,13]
			nTotal92:= (aDados[n1,17] - aDados[n1, 5])

			If MV_PAR07 == 1
				oExcel:AddRow(cPlan, cTit,{aDados[n1, 1],;  //gerente
				aDados[n1, 2],;  //vendedor
				aDados[n1, 3],;	//nome
				aDados[n1, 12],;	//Meta
				aDados[n1, 4]-aDados[n1, 5],;//aDados[n1, 4],;	//fat.geral
				Transform(IIf(aDados[n1, 4] <= 0, 0, 100 - ((aDados[n1, 13] / aDados[n1, 14]) * 100)),"@R 9999.99%"),;//Fator (Transform(IIf(aDados[n1, 4] <= 0, 0, 100.00 - ((aDados[n1, 13] / (aDados[n1, 4] - aDados[n1, 5])) * 100.00)),"@R 999.99%"))
				aDados[n1, 5],;	//devolucoes
				Iif(aDados[n1, 12] > 0, Transform(((aDados[n1, 4] - aDados[n1, 5])/aDados[n1, 12])*100,"@R 9999%"),""),;	//% Atend.
				aDados[n1, 6],;	//aguard.lib
				aDados[n1, 7],;	//aguard.crd
				aDados[n1, 8],;	//aguard.fat
				aDados[n1,19],;	//fat.dia
				aDados[n1,9],;	//pedido dia
				aDados[n1,13],;
				aDados[n1,14],;
				aDados[n1,15],;
				aDados[n1,16],;
				(aDados[n1,17] - aDados[n1, 5])}) 

			EndIf

			If MV_PAR07 == 2
				oExcel:AddRow(cPlan, cTit,{aDados[n1, 1],;  //gerente
				aDados[n1, 2],;  //vendedor
				aDados[n1, 3],;	//nome
				aDados[n1, 12],;	//Meta
				aDados[n1, 4]-aDados[n1, 5],;//aDados[n1, 4],;	//fat.geral
				aDados[n1, 5],;	//devolucoes
				Iif(aDados[n1, 12] > 0, Transform(((aDados[n1, 4] - aDados[n1, 5])/aDados[n1, 12])*100,"@R 9999%"),""),;	//% Atend.
				aDados[n1, 6],;	//aguard.lib
				aDados[n1, 7],;	//aguard.crd
				aDados[n1, 8],;	//aguard.fat
				aDados[n1,19],;	//fat.dia
				aDados[n1,9],;	//pedido dia
				aDados[n1,15],;
				aDados[n1,16],;
				(aDados[n1,17] - aDados[n1, 5])}) 

			EndIf
		EndIf
	Next n1

	If Left(cFilAnt,2) == "08"
		If	Empty(cQuebra)
	cRegiao :=  "TOTAL DA REGIAO - CD JAYS"  
		ElseIf cQuebra == "000001"
	cRegiao :=  "TOTAL REGIONAL SÃO PAULO 2"//"TOTAL DA REGIAO - INTERIOR 2"
		ElseIf cQuebra == "000035"
	cRegiao :=  "TOTAL DA REGIAO - INTERNO"
		ElseIf cQuebra == "000093"
	cRegiao :=  "TOTAL DA REGIAO - LITORAL"
		ElseIf Alltrim(cQuebra) $ "001995|002065"
	cRegiao := "TOTAL DA REGIAO - NOVOS NEGOCIOS"
		ElseIf Alltrim(cQuebra) $ "002003|002047"
	cRegiao :=  "TOTAL DA REGIAO - RIO CENTRO"
		ElseIf cQuebra == "002027"
	cRegiao :=  "TOTAL DA REGIAO - SUL"
		ElseIf cQuebra == "002048"
	cRegiao :=  "TOTAL DA REGIAO SÃO PAULO 1"
		ElseIf cQuebra == "002071"
	cRegiao :=  "TOTAL DICICO"
		Else
	cRegiao :=  "TOTAL DA REGIAO"
		EndIf
	Else
		cRegiao :=  "TOTAL GERENTE"
	EndIf	

	If MV_PAR07 == 1

		oExcel:AddRow(cPlan, cTit,{"",;  //gerente
		"",;  //vendedor
		cRegiao,;  //nome
		nTotal9,;  //Meta
		nTotal1,;  //fat.geral
		Transform(IIf(nTotal1 <= 0, 0, 100 - ((nTotal91 / nTotal90) * 100)),"@R 9999.99%"),;//Fator (Transform(IIf(nTotal1 <= 0, 0, 100.00 - ((nTotal10 / nTotal1) * 100.00)),"@R 999.99%"))
		nTotal2,;  //devolucoes
		Iif(nTotal9 > 0,Transform(( (nTotal1 - nTotal2)/nTotal9)*100,"@R 9999%"),""),;  //% Atend.
		nTotal3,;  //aguard.lib
		nTotal4,;  //aguard.crd
		nTotal5,;  //aguard.fat
		nTotal6,;  //fat.dia
		nTotal7,;  //pedido dia
		nTotal91,;
		nTotal90,;
		"",;
		"",;
		nTotal92})  
		
		oExcel:AddRow(cPlan, cTit,{;
		"",;  //01
		"",;  //02
		"",;  //03
		"",;  //04
		"",;  //05
		"",;  //06
		"",;  //07
		"",;  //08
		"",;  //09
		"",;  //10
		"",;  //12
		"",;  //13	
		"",;  //14
		"",;  //15
		"",;  //16
		"",;  //17
		"",;  //18
		""}) 
		
		oExcel:AddRow(cPlan, cTit,{"",;  //gerente
		"",;  //vendedor
		"T O T A L  G E R A L",;  //nome
		nTotal9G,;  //Meta
		nTotal1G,;  //fat.geral
		Transform(IIf(nTotal1G <= 0, 0, 100 - ((nTotal91G / nTotal90G) * 100)),"@R 9999.99%"),;//Fator (Transform(IIf(nTotal1G <= 0, 0, 100.00 - ((nTotal10G / nTotal1G) * 100.00)),"@R 999.99%"))
		nTotal2G,;  //devolucoes
		Iif(nTotal9G > 0,Transform(( (nTotal1G - nTotal2G)/nTotal9G)*100,"@R 9999%"),""),;  //% Atend.
		nTotal3G,;  //aguard.lib
		nTotal4G,;  //aguard.crd
		nTotal5G,;  //aguard.fat
		nTotal6G,;  //fat.dia
		nTotal7G,;  //pedido dia
		nTotal91G,;
		nTotal90G,;
		"",;
		"",;
		nTotal92G})  
	EndIf

	If MV_PAR07 == 2

		oExcel:AddRow(cPlan, cTit,{"",;  //gerente
		"",;  //vendedor
		cRegiao,;  //nome
		nTotal9,;  //Meta
		nTotal1,;  //fat.geral
		nTotal2,;  //devolucoes
		Iif(nTotal9 > 0,Transform(( (nTotal1 - nTotal2)/nTotal9)*100,"@R 9999%"),""),;  //% Atend.
		nTotal3,;  //aguard.lib
		nTotal4,;  //aguard.crd
		nTotal5,;  //aguard.fat
		nTotal6,;  //fat.dia
		nTotal7,;  //pedido dia
		"",;
		"",;
		nTotal92})  
		
		oExcel:AddRow(cPlan, cTit,{;
		"",;  //01
		"",;  //02
		"",;  //03
		"",;  //04
		"",;  //05
		"",;  //07
		"",;  //08
		"",;  //09
		"",;  //10
		"",;  //11
		"",;  //12	
		"",;  //13
		"",;  //14
		"",;  //15
		""})  //16 
		
		oExcel:AddRow(cPlan, cTit,{"",;  //gerente
		"",;  //vendedor
		"T O T A L  G E R A L",;  //nome
		nTotal9G,;  //Meta
		nTotal1G,;  //fat.geral
		nTotal2G,;  //devolucoes
		Iif(nTotal9G > 0,Transform(( (nTotal1G - nTotal2G)/nTotal9G)*100,"@R 9999%"),""),;  //% Atend.
		nTotal3G,;  //aguard.lib
		nTotal4G,;  //aguard.crd
		nTotal5G,;  //aguard.fat
		nTotal6G,;  //fat.dia
		nTotal7G,;  //pedido dia
		"",;
		"",;
		nTotal92G})  
	EndIf	

	oExcel:Activate()
	oExcel:GetXMLFile(cArqDst)
	OPENXML(cArqDst)
	oExcel:DeActivate()
	
EndIf

Return

Static Function OPENXML(cArq)
Local cDirDocs := MsDocPath()
Local cPath	   := AllTrim(GetTempPath())

If !ApOleClient("MsExcel")
	Aviso("Atencao", "O Microsoft Excel nao esta instalado.", {"Ok"}, 2)
Else
	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open(cArq)
	oExcelApp:SetVisible(.T.)
	oExcelApp:Destroy()
EndIf

Return
