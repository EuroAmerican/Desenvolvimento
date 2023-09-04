#include "parmtype.ch"
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"
#include "Colors.ch"
#include "RwMake.ch"

/*/{Protheus.doc} QECOMR01 rotina para comissão
//Relacao de conferencia de comissão por vendedor 
@type user function 
@Autor Fabio Carneiro 
@since 13/02/2022
@version 1.0
@History Ajustado em 09/09/2022 tratamento referente a não considerar comissão se o item estiver zerado - Fabio carneiro dos Santos
@return character, sem retorno especificadao
/*/

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

User Function QECOMR01()

Local aSays    := {}
Local aButtons := {}
Local cTitoDlg := "Conferencia de Comissão por Vendedor Analitico"
Local nOpca    := 0
Private _cPerg := "QECOMR0"

aAdd(aSays, "Rotina para gerar a conferência das comissões de acordo com o periodo informado!!!")
aAdd(aSays, "Este relatório é apenas para se certificar que os produtos gerarm os percentuais corretos,")
aAdd(aSays, "porém o cálculo é gerado pela baixa, que consta no relatório padrão de Pgto de Comissão")
aAdd(aSays, "Análitico lista por Produto(s) e Titulo(s) / Sintético lista Total da Nota(s) e Titulo(s) ")
aAdd(aSays, "A planilha será salva no diretorio C:\TOTVS\QECOMR01_data_horario.xml ")

aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

FormBatch(cTitoDlg, aSays, aButtons)

If nOpca == 1
	
	oAjustaSx1()

	If !Pergunte(_cPerg,.T.)
		Return
	Else 
		MontaDir("C:\TOTVS\")
		Processa({|| QECOMR01ok("Gerando planilha, aguarde...")})
	Endif
		
EndIf

Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QECOMR01ok| Autor: | QUALY         | Data: | 13/02/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QECOMR01ok                                   |
+------------+-----------------------------------------------------------+
*/

Static Function QECOMR01ok()

Local cArqDst          := "C:\TOTVS\QECOMR01_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
Local oExcel           := FWMsExcelEX():New()
Local cPlan            := "Empresa_" + Rtrim(SM0->M0_CODIGO) + "_Filial_" + Rtrim(SM0->M0_CODFIL)
Local cTit             := "Conferencia de Comissão por Vendedor pela data de baixa dos Titulos De: " +Dtoc(MV_PAR01) + " Ate: " + Dtoc(MV_PAR02)
Local lAbre            := .F.
Local _lTemNota        := .F.
Local _nVLBRUTO        := 0
Local _nVLICM          := 0
Local _nVLRET          := 0
Local _nVLIPI          := 0
Local _nVLDESC         := 0
Local _nVLFRETE        := 0
Local _nVLOUTROS       := 0
Local _nVLTOTAL        := 0
Local _nVALACRS        := 0
Local _nVLTITULO       := 0
Local _nTotVlTit       := 0
Local _nCalcBase       := 0
Local _nBase           := 0
Local _nBaseCalc       := 0
Local _nPercTab        := 0
Local _nTabPerc        := 0
Local _cReprePorc      := 0
Local _nCMTOTAL        := 0
Local _nConta          := 0
Local _nComPerc        := 0
Local _nPercCom        := 0
Local _nComNeg         := 0
Local _nVlCusto        := 0
Local _nVlValor        := 0
Local _nPCalcTab       := 0
Local _nPCalcCom   	   := 0	
Local _nBaseTit        := 0
Local _nTotSDPG        := 0
Local _nBasePg         := 0
Local _nJuros          := 0
Local _nVLCOMA1        := 0
Local _nPartcip        := 0
Local _nPercCli        := 0
Local _nComProd        := 0
Local _nCalcVl01       := 0
Local _nCalcVl02       := 0
Local _nCalcVl03       := 0
Local _nCalcVl04       := 0
Local _nCalcVl05       := 0
Local _nCalcTot01      := 0

Local cQuery           := ""
Local cQueryC          := "" 

Local _cGEREN          := ""
Local _cVENDEDOR  	   := ""
Local _cNOMEVEND       := ""
Local _cTPREG          := ""
Local _cTIPO 		   := ""
Local _cDOC            := ""
Local _cCODCLI         := ""
Local _cLOJA           := ""
Local _cNOMECLI        := ""
Local _cSERIE          := ""
Local _cPedido         := ""
Local _cPgCliente      := ""
Local _cRepreClt       := ""
Local _cPgRepre        := ""
Local _cSeq            := ""
Local _dDTEMISSAO      := ""     
Local _cCONDPGTO       := ""
Local _cDESCRIPGTO     := ""
Local _cPARCELA        := ""
Local _dDTVIG1         := ""
Local _dDTVIG2         := ""
Local _cTpCom          := ""

/*
+------------------------------------------+
| DADOS NO CABEÇALHO DA PLANILHA           |
+------------------------------------------+
*/

oExcel:AddworkSheet(cPlan)
oExcel:AddTable(cPlan, cTit)
oExcel:AddColumn(cPlan, cTit, "Origem"             , 1, 1, .F.)  //01
oExcel:AddColumn(cPlan, cTit, "Cod. Gerente"       , 1, 1, .F.)  //02
oExcel:AddColumn(cPlan, cTit, "Cod. Vendedor"      , 1, 1, .F.)  //03
oExcel:AddColumn(cPlan, cTit, "Nome Vend."         , 1, 1, .F.)  //04
oExcel:AddColumn(cPlan, cTit, "Codigo Cliente"     , 1, 1, .F.)  //05
oExcel:AddColumn(cPlan, cTit, "Loja Cliente"       , 1, 1, .F.)  //06
oExcel:AddColumn(cPlan, cTit, "Nome Cliente"       , 1, 1, .F.)  //07
oExcel:AddColumn(cPlan, cTit, "Codigo Produto"     , 1, 1, .F.)  //08
oExcel:AddColumn(cPlan, cTit, "Descrição Produto"  , 1, 1, .F.)  //09
oExcel:AddColumn(cPlan, cTit, "Tipo Nf"            , 1, 1, .F.)  //10
oExcel:AddColumn(cPlan, cTit, "Numero Nf"          , 1, 1, .F.)  //11
oExcel:AddColumn(cPlan, cTit, "Serie Nf"           , 1, 1, .F.)  //12
oExcel:AddColumn(cPlan, cTit, "Data Emissão Nf"    , 1, 1, .F.)  //13
oExcel:AddColumn(cPlan, cTit, "Cod. Cond. Pgto"    , 1, 1, .F.)  //14
oExcel:AddColumn(cPlan, cTit, "Desc. Cond.Pgto"    , 1, 1, .F.)  //15
oExcel:AddColumn(cPlan, cTit, "Vl. Bruto Nf"       , 3, 2, .F.)  //16
oExcel:AddColumn(cPlan, cTit, "Vl. ICMS Nf"        , 3, 2, .F.)  //17
oExcel:AddColumn(cPlan, cTit, "Vl. ICMS ST Nf"     , 3, 2, .F.)  //18
oExcel:AddColumn(cPlan, cTit, "Vl. IPI Nf"         , 3, 2, .F.)  //19
oExcel:AddColumn(cPlan, cTit, "Valor Desconto Nf"  , 3, 2, .F.)  //20
oExcel:AddColumn(cPlan, cTit, "Valor Frete Nf"     , 3, 2, .F.)  //21
oExcel:AddColumn(cPlan, cTit, "Vl. Outros Impostos", 3, 2, .F.)  //22
oExcel:AddColumn(cPlan, cTit, "Vl. Custo Nf"       , 3, 2, .F.)  //23
oExcel:AddColumn(cPlan, cTit, "Vl. Acrescimo Nf"   , 3, 2, .F.)  //24
oExcel:AddColumn(cPlan, cTit, "Vl. Liquido Nf"     , 3, 2, .F.)  //25
oExcel:AddColumn(cPlan, cTit, "Base Margem Contrib.", 3, 2, .F.) //26
oExcel:AddColumn(cPlan, cTit, "% Margem Contrib."  , 3, 2, .F.)  //27
oExcel:AddColumn(cPlan, cTit, "% Comissao Nf"      , 3, 2, .F.)  //28
oExcel:AddColumn(cPlan, cTit, "Valor Comissao "    , 3, 2, .F.)  //29
oExcel:AddColumn(cPlan, cTit, "Tabela Comissao"    , 1, 1, .F.)  //30
oExcel:AddColumn(cPlan, cTit, "Revisao Comissao"   , 1, 1, .F.)  //31
oExcel:AddColumn(cPlan, cTit, "Dt. Rev. N.fiscal"  , 1, 1, .F.)  //32
oExcel:AddColumn(cPlan, cTit, "% Comissao Calc."   , 3, 2, .F.)  //33
oExcel:AddColumn(cPlan, cTit, "Vl Comissao Calc."  , 3, 2, .F.)  //34
oExcel:AddColumn(cPlan, cTit, "Vl.Dif.Pago X Calc.", 3, 2, .F.)  //35
oExcel:AddColumn(cPlan, cTit, "Vigencia Inicial"   , 1, 1, .F.)  //36
oExcel:AddColumn(cPlan, cTit, "Vigencia Final"     , 1, 1, .F.)  //37
oExcel:AddColumn(cPlan, cTit, "Tabela Bloqueada?"  , 1, 1, .F.)  //38
oExcel:AddColumn(cPlan, cTit, "Numero Tituto"      , 1, 1, .F.)  //39
oExcel:AddColumn(cPlan, cTit, "Prefixo Titulo"     , 1, 1, .F.)  //40
oExcel:AddColumn(cPlan, cTit, "Parcela Titulo"     , 1, 1, .F.)  //41
oExcel:AddColumn(cPlan, cTit, "Tipo Titulo"        , 1, 1, .F.)  //42
oExcel:AddColumn(cPlan, cTit, "Dt. Emissao Tit."   , 1, 1, .F.)  //43
oExcel:AddColumn(cPlan, cTit, "Dt. Vencimento Tit.", 1, 1, .F.)  //44
oExcel:AddColumn(cPlan, cTit, "Dt. Baixa Tit."     , 1, 1, .F.)  //45
oExcel:AddColumn(cPlan, cTit, "Vl. do Pgto Tit."   , 3, 2, .F.)  //46
oExcel:AddColumn(cPlan, cTit, "Base Com. Tit."     , 3, 2, .F.)  //47
oExcel:AddColumn(cPlan, cTit, "Base Com. P/ Pgto"  , 3, 2, .F.)  //48
oExcel:AddColumn(cPlan, cTit, "% Comissão Titulo"  , 3, 2, .F.)  //49
oExcel:AddColumn(cPlan, cTit, "Vl. Comissão Tit."  , 3, 2, .F.)  //50
oExcel:AddColumn(cPlan, cTit, "Base Com. P/ Pgto"  , 3, 2, .F.)  //51
oExcel:AddColumn(cPlan, cTit, "% Comissão Calc."   , 3, 2, .F.)  //52
oExcel:AddColumn(cPlan, cTit, "Vl. Comissão Calc." , 3, 2, .F.)  //53
oExcel:AddColumn(cPlan, cTit, "Difer. Tit. X Calc.", 3, 2, .F.)  //54
oExcel:AddColumn(cPlan, cTit, "Vl. Bruto Titulo "  , 3, 2, .F.)  //55
oExcel:AddColumn(cPlan, cTit, "Vl. Juros"          , 3, 2, .F.)  //56
oExcel:AddColumn(cPlan, cTit, "Tipo BX Financ."    , 1, 1, .F.)  //57
oExcel:AddColumn(cPlan, cTit, "Data Bx Financeiro" , 1, 1, .F.)  //58
oExcel:AddColumn(cPlan, cTit, "Check NF X Titulo"  , 1, 1, .F.)  //59
oExcel:AddColumn(cPlan, cTit, "Check NF X Tabela"  , 1, 1, .F.)  //60
oExcel:AddColumn(cPlan, cTit, "Check Tit. X Tabela", 1, 1, .F.)  //61
oExcel:AddColumn(cPlan, cTit, "Tipo Comissão"      , 1, 1, .F.)  //62

/*
+-------------------------------------------+
| QUERY REFERENTE OS MOVIMENTOS DE COMISSÃO |
+-------------------------------------------+
*/
If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf

cQuery := "SELECT 'FATURADO' AS TPREG, " + CRLF
cQuery += "D2_TIPO AS TIPO, " + CRLF
cQuery += "A3_GEREN AS GEREN, " + CRLF 
cQuery += "F2_VEND1 AS VENDEDOR, " + CRLF
cQuery += "A3_NOME AS NOMEVEND, " + CRLF
cQuery += "A1_COD AS CODCLI, " + CRLF
cQuery += "A1_LOJA AS LOJA , " + CRLF
cQuery += "A1_NOME AS NOMECLI, " + CRLF
cQuery += "B1_COD AS PRODUTO, " + CRLF
cQuery += "B1_DESC AS DESCPROD, " + CRLF
cQuery += "D2_ITEM AS ITEM, " + CRLF
cQuery += "D2_DOC AS DOC, " + CRLF
cQuery += "D2_SERIE AS SERIE, " + CRLF
cQuery += "D2_EMISSAO AS DTEMISSAO, " + CRLF
cQuery += "F2_COND AS CONDPGTO, " + CRLF
cQuery += "(D2_VALBRUT) AS VLBRUTO, " + CRLF
cQuery += "(D2_TOTAL) AS VLTOTAL, " + CRLF
cQuery += "(D2_VALICM) AS VLICM, " + CRLF
cQuery += "(D2_ICMSRET) AS VLICMRET, " + CRLF
cQuery += "(D2_VALIPI) AS VLIPI, " + CRLF
cQuery += "(D2_DESCON) AS VLDESC ," + CRLF
cQuery += "(D2_VALFRE) AS VLFRETE, " + CRLF
cQuery += "(D2_SEGURO+D2_VALIMP5+D2_VALIMP6) AS VLOUTROS, " + CRLF 
cQuery += "(D2_CUSTO1) AS CUSTO, " + CRLF
cQuery += "D2_COMIS1 AS VLCOMIS1, " + CRLF
cQuery += "D2_XCOM1 AS VLCOMTAB, " + CRLF
cQuery += "D2_XTABCOM AS TABVIG, " + CRLF
cQuery += "'' AS NUMTIT, " + CRLF
cQuery += "'' AS PREFIXO, " + CRLF
cQuery += "'' AS PARCELA, " + CRLF
cQuery += "'' AS TIPOTIT, " + CRLF
cQuery += "'' AS DTEMISSAOTIT, " + CRLF
cQuery += "'' AS DTVENCREA, " + CRLF
cQuery += "'' AS DTBAIXA, " + CRLF
cQuery += "0 AS VLBASCOM1, " + CRLF
cQuery += "0 AS VLCOM1, " + CRLF
cQuery += "0 AS VLTITULO, " + CRLF
cQuery += "0 AS VALLIQTIT, " + CRLF
cQuery += "'' AS NFORIGEM, " + CRLF
cQuery += "'' AS SERIEORI, " + CRLF
cQuery += "(D2_VALBRUT - D2_VALIPI - D2_VALICM - D2_VALIMP5 - D2_VALIMP6 - D2_DESPESA - D2_VALFRE - D2_DESCON - D2_SEGURO - D2_ICMSRET) AS VALOR, " + CRLF
cQuery += "(D2_TOTAL * D2_XCOM1)/100 AS CALCCOMTAB, " + CRLF
cQuery += "(D2_TOTAL * D2_COMIS1)/100 AS CALCCOMDOC, " + CRLF
cQuery += "0 AS VLPAGO, " + CRLF
cQuery += "0 AS VLJUROS, " + CRLF
cQuery += "'' AS DTVLPAGO, " + CRLF
cQuery += "'' AS TIPODOC, " + CRLF
cQuery += "'' AS HISTORICO, " + CRLF
cQuery += "D2_PEDIDO AS PEDIDO, " + CRLF
cQuery += "0 AS SALDOTIT, " + CRLF
cQuery += "D2_VALACRS AS  VALACRS, " + CRLF
cQuery += "'' AS MOTBX, " + CRLF
cQuery += "A1_XPGCOM AS XA1PGCOM, " + CRLF 
cQuery += "A3_XCLT AS XCLT, " + CRLF 
cQuery += "A3_XPGCOM AS  XA3PGCOM, " + CRLF
cQuery += "A3_COMIS AS A3COMIS, " + CRLF
cQuery += "'' AS E5SEQ, " + CRLF
cQuery += "0 AS VLMULTA, " + CRLF
cQuery += "0 AS VLCORRE, " + CRLF
cQuery += "0 AS VLDESCO, " + CRLF
cQuery += "0 AS JUROS, " + CRLF
cQuery += "A1_XCOMIS1 AS XCOMIS1, " + CRLF
cQuery += "'' AS DEVCOM, " + CRLF 
cQuery += "B1_XREVCOM AS XREVCOM, " + CRLF
cQuery += "B1_XTABCOM AS XB1TABCOM, " + CRLF
cQuery += "D2_XREVCOM AS D2XREVCOM, " + CRLF
cQuery += "D2_XDTRVC AS D2XDTRVC, " + CRLF
cQuery += "D2_XTPCOM AS D2XTPCOM, " + CRLF
cQuery += "C6_COMIS1 AS C6COMIS1, " + CRLF
cQuery += "C6_XCOM1 AS C6XCOM1,  "+ CRLF
cQuery += "B1_COMIS AS B1COMIS  "+ CRLF
cQuery += "FROM "+RetSqlName("SD2")+" AS SD2 WITH (NOLOCK)  " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SF2")+" AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL " + CRLF
cQuery += " AND F2_DOC = D2_DOC " + CRLF
cQuery += " AND F2_SERIE = D2_SERIE " + CRLF
cQuery += " AND F2_CLIENTE = D2_CLIENTE " + CRLF
cQuery += " AND F2_LOJA = D2_LOJA " + CRLF
cQuery += " AND F2_TIPO = D2_TIPO " + CRLF
cQuery += " AND F2_EMISSAO = D2_EMISSAO " + CRLF
cQuery += " AND SF2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SE1")+" AS SE1 WITH (NOLOCK) ON E1_FILIAL = F2_FILIAL " + CRLF 
cQuery += " AND E1_NUM = F2_DOC " + CRLF
cQuery += " AND E1_PREFIXO = F2_SERIE " + CRLF
cQuery += " AND E1_CLIENTE = F2_CLIENTE " + CRLF
cQuery += " AND E1_LOJA = F2_LOJA " + CRLF
cQuery += " AND E1_EMISSAO = F2_EMISSAO " + CRLF
cQuery += " AND SE1.D_E_L_E_T_ = ' '  " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SE5")+" AS SE5 ON E5_FILIAL = E1_FILIAL  " + CRLF 
cQuery += " AND E5_NUMERO = E1_NUM " + CRLF
cQuery += " AND E5_PREFIXO = E1_PREFIXO " + CRLF
cQuery += " AND E5_PARCELA = E1_PARCELA " + CRLF
cQuery += " AND E5_CLIFOR = E1_CLIENTE " + CRLF
cQuery += " AND E5_LOJA = E1_LOJA " + CRLF
cQuery += " AND SE5.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SE3")+" AS SE3 ON E1_FILIAL = E3_FILIAL
cQuery += " AND E3_NUM = E1_NUM " + CRLF
cQuery += " AND E3_PREFIXO = E1_PREFIXO " + CRLF
cQuery += " AND E3_PARCELA = E1_PARCELA " + CRLF
cQuery += " AND E3_TIPO = E1_TIPO  " + CRLF
cQuery += " AND SE3.D_E_L_E_T_ = ' '  " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SF4")+" AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(D2_FILIAL, 2) " + CRLF
cQuery += " AND F4_CODIGO = D2_TES " + CRLF
cQuery += " AND F4_DUPLIC = 'S' " + CRLF
cQuery += " AND SF4.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) ON B1_FILIAL = '    ' " + CRLF
cQuery += " AND B1_COD = D2_COD " + CRLF
cQuery += " AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SA3")+" AS SA3 WITH (NOLOCK) ON A3_COD = F2_VEND1 " + CRLF
cQuery += "	AND SA3.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH (NOLOCK) ON A1_FILIAL = F2_FILIAL " + CRLF
cQuery += " AND A1_COD = F2_CLIENTE " + CRLF
cQuery += " AND A1_LOJA = F2_LOJA " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SC6")+" AS SC6 WITH (NOLOCK) ON D2_FILIAL = C6_FILIAL " + CRLF
cQuery += " AND C6_PRODUTO = D2_COD  "+ CRLF
cQuery += " AND C6_NUM  = D2_PEDIDO  "+ CRLF
cQuery += " AND C6_CLI  = D2_CLIENTE "+ CRLF
cQuery += " AND C6_LOJA = D2_LOJA    "+ CRLF
cQuery += " AND SC6.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += "WHERE D2_FILIAL = '"+xFilial("SD2")+"' " + CRLF
cQuery += " AND D2_TIPO = 'N' " + CRLF
cQuery += " AND D2_EMISSAO BETWEEN '"+dtoS(mv_par15)+"' AND '"+dtoS(mv_par16)+"' " + CRLF
cQuery += " AND E5_DATA    BETWEEN '"+dtoS(mv_par01)+"' AND '"+dtoS(mv_par02)+"' " + CRLF 
cQuery += " AND F2_VEND1 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' " + CRLF
cQuery += " AND D2_DOC   BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' " + CRLF
cQuery += " AND D2_SERIE BETWEEN '"+mv_par07+"' AND '"+mv_par08+"' " + CRLF
cQuery += " AND D2_CLIENTE BETWEEN '"+mv_par09+"' AND '"+mv_par10+"' " + CRLF
cQuery += " AND D2_LOJA BETWEEN '"+mv_par11+"' AND '"+mv_par12+"' " + CRLF
cQuery += " AND D2_COD     BETWEEN '"+mv_par13+"' AND '"+mv_par14+"' " + CRLF
cQuery += " AND A1_XPGCOM = '2' "+ CRLF
cQuery += " AND A3_XPGCOM = '2' "+ CRLF
cQuery += " AND SD2.D_E_L_E_T_ = ' '  " + CRLF
cQuery += "GROUP BY D2_TIPO, A3_GEREN, F2_VEND1, A3_NOME, A1_COD, A1_LOJA, A1_NOME, D2_DOC,D2_SERIE,D2_EMISSAO,F2_COND,D2_CUSTO1,  " + CRLF 
cQuery += "D2_COMIS1,D2_XCOM1,B1_COD,B1_DESC,D2_ITEM,D2_XTABCOM,D2_VALBRUT,D2_TOTAL,D2_VALICM,D2_ICMSRET,D2_VALIPI,D2_DESCON,D2_XTABCOM, " + CRLF
cQuery += "D2_VALFRE,D2_SEGURO,D2_VALIMP5,D2_VALIMP6,D2_CUSTO1,D2_DESPESA,D2_VALACRS,D2_PEDIDO,A1_XPGCOM,A3_XCLT,A3_XPGCOM,A3_COMIS,A1_XCOMIS1, " + CRLF
cQuery += "B1_XREVCOM, B1_XTABCOM, D2_XREVCOM, D2_XDTRVC, D2_XTPCOM, C6_COMIS1, C6_XCOM1, B1_COMIS  "+ CRLF

cQuery += "UNION " + CRLF

cQuery += "SELECT 'TITULO' AS TPREG, " + CRLF
cQuery += "'T' AS TIPO, " + CRLF
cQuery += "A3_GEREN AS GEREN, " + CRLF
cQuery += "F2_VEND1 AS VENDEDOR, " + CRLF
cQuery += "A3_NOME AS NOMEVEND, " + CRLF
cQuery += "A1_COD AS CODCLI, " + CRLF
cQuery += "A1_LOJA AS LOJA, " + CRLF
cQuery += "A1_NOME AS NOMECLI, " + CRLF 
cQuery += "'' AS PRODUTO, " + CRLF
cQuery += "'' AS DESCPROD, " + CRLF
cQuery += "'' AS ITEM, " + CRLF
cQuery += "F2_DOC AS DOC, " + CRLF
cQuery += "F2_SERIE AS SERIE, " + CRLF
cQuery += "F2_EMISSAO AS DTEMISSAO, " + CRLF
cQuery += "'' AS CONDPGTO, " + CRLF
cQuery += "0 AS VLBRUTO, " + CRLF
cQuery += "0 AS VLTOTAL, " + CRLF
cQuery += "0 AS VLICM, " + CRLF
cQuery += "0 AS VLICMRET, 0 AS VLIPI, " + CRLF 
cQuery += "0 AS VLDESC, 0 AS VLFRETE, " + CRLF
cQuery += "0 AS VLOUTROS, " + CRLF
cQuery += "0 AS CUSTO, " + CRLF
cQuery += "0 AS VLCOMIS1, " + CRLF
cQuery += "0 AS VLCOMTAB, " + CRLF
cQuery += "'' AS TABVIG, " + CRLF
cQuery += "E1_NUM AS NUMTIT, " + CRLF
cQuery += "E1_PREFIXO AS PREFIXO, " + CRLF
cQuery += "E1_PARCELA AS PARCELA, " + CRLF
cQuery += "E1_TIPO AS TIPOTIT, " + CRLF
cQuery += "E1_EMISSAO AS DTEMISSAOTIT, " + CRLF
cQuery += "E1_VENCREA AS DTVENCREA, " + CRLF
cQuery += "E1_BAIXA AS DTBAIXA,  " + CRLF
cQuery += "E1_BASCOM1 AS VLBASCOM1, " + CRLF
cQuery += "E1_COMIS1 AS VLCOM1, " + CRLF 
cQuery += "E1_VALOR AS VLTITULO , " + CRLF
cQuery += "E1_VALLIQ AS VALLIQTIT, " + CRLF
cQuery += "'' AS NFORIGEM, " + CRLF 
cQuery += "'' AS SERIEORI, " + CRLF
cQuery += "0 AS VALOR, " + CRLF
cQuery += "0 AS CALCCOMTAB, " + CRLF
cQuery += "0 AS CALCCOMDOC, " + CRLF
cQuery += "E5_VALOR AS VLPAGO, " + CRLF
cQuery += "E1_JUROS AS VLJUROS, " + CRLF
cQuery += "E5_DATA AS DTVLPAGO, " + CRLF
cQuery += "E5_TIPODOC AS TIPODOC, " + CRLF
cQuery += "'' AS HISTORICO, " + CRLF
cQuery += "'' AS PEDIDO, " + CRLF
cQuery += "E1_SALDO AS SALDOTIT, " + CRLF
cQuery += "0 AS  VALACRS, " + CRLF
cQuery += "E5_MOTBX AS MOTBX, " + CRLF
cQuery += "A1_XPGCOM AS XA1PGCOM, " + CRLF 
cQuery += "A3_XCLT AS XCLT, " + CRLF 
cQuery += "A3_XPGCOM AS  XA3PGCOM, " + CRLF
cQuery += "A3_COMIS AS A3COMIS, " + CRLF
cQuery += "E5_SEQ AS E5SEQ, " + CRLF
cQuery += "E5_VLMULTA AS VLMULTA, " + CRLF
cQuery += "E5_VLCORRE AS VLCORRE, " + CRLF
cQuery += "E5_VLDESCO AS VLDESCO, " + CRLF
cQuery += "E5_VLJUROS AS JUROS, " + CRLF 
cQuery += "A1_XCOMIS1 AS XCOMIS1, " + CRLF
cQuery += "E5_XDEVCOM AS DEVCOM, " + CRLF 
cQuery += "'' AS XREVCOM, " + CRLF
cQuery += "'' AS XB1TABCOM, " + CRLF
cQuery += "'' AS D2XREVCOM, " + CRLF
cQuery += "'' AS D2XDTRVC, " + CRLF
cQuery += "'' AS D2XTPCOM, " + CRLF
cQuery += "'' AS C6COMIS1, " + CRLF
cQuery += "'' AS C6XCOM1,  "+ CRLF
cQuery += "0 AS B1COMIS  "+ CRLF
cQuery += "FROM "+RetSqlName("SE1")+" AS SE1 WITH (NOLOCK) " + CRLF 
cQuery += "INNER JOIN "+RetSqlName("SE5")+" AS SE5 ON E5_FILIAL = E1_FILIAL  " + CRLF 
cQuery += " AND E5_NUMERO = E1_NUM " + CRLF
cQuery += " AND E5_PREFIXO = E1_PREFIXO " + CRLF
cQuery += " AND E5_PARCELA = E1_PARCELA " + CRLF
cQuery += " AND E5_CLIFOR = E1_CLIENTE " + CRLF
cQuery += " AND E5_LOJA = E1_LOJA " + CRLF
cQuery += " AND SE5.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SF2")+" AS SF2 WITH (NOLOCK) ON E1_FILIAL = F2_FILIAL " + CRLF 
cQuery += " AND E1_NUM = F2_DOC " + CRLF
cQuery += " AND E1_PREFIXO = F2_SERIE " + CRLF
cQuery += " AND E1_CLIENTE = F2_CLIENTE " + CRLF
cQuery += " AND E1_LOJA = F2_LOJA " + CRLF
cQuery += " AND E1_EMISSAO = F2_EMISSAO " + CRLF
cQuery += " AND SE1.D_E_L_E_T_ = ' '  " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SE3")+" AS SE3 ON E1_FILIAL = E3_FILIAL
cQuery += " AND E3_NUM = E1_NUM " + CRLF
cQuery += " AND E3_PREFIXO = E1_PREFIXO " + CRLF
cQuery += " AND E3_PARCELA = E1_PARCELA " + CRLF
cQuery += " AND E3_TIPO = E1_TIPO  " + CRLF
cQuery += " AND SE3.D_E_L_E_T_ = ' '  " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SA3")+" AS SA3 WITH (NOLOCK) ON A3_COD = F2_VEND1 " + CRLF 
cQuery += " AND SA3.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH (NOLOCK) ON A1_FILIAL = F2_FILIAL " + CRLF
cQuery += " AND A1_COD = F2_CLIENTE " + CRLF
cQuery += " AND A1_LOJA = F2_LOJA " + CRLF
cQuery += "WHERE E1_FILIAL = '"+xFilial("SE1")+"'  " + CRLF
cQuery += " AND F2_TIPO = 'N' " + CRLF
cQuery += " AND NOT E5_MOTBX IN ('LIQ','CAN') " + CRLF
cQuery += " AND E5_TIPODOC IN ('VL','BA','CP','V2','DC') " + CRLF
cQuery += " AND E5_SITUACA = ' ' " + CRLF
cQuery += " AND E5_VALOR > 0 "+ CRLF
cQuery += " AND A1_XPGCOM = '2' "+ CRLF
cQuery += " AND A3_XPGCOM = '2' "+ CRLF
cQuery += " AND NOT E5_NATUREZ = 'DESCONT' " + CRLF
cQuery += " AND E1_EMISSAO BETWEEN '"+dtoS(mv_par15)+"' AND '"+dtoS(mv_par16)+"' " + CRLF
cQuery += " AND E5_DATA    BETWEEN '"+dtoS(mv_par01)+"' AND '"+dtoS(mv_par02)+"' " + CRLF 
cQuery += " AND F2_VEND1 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' " + CRLF
cQuery += " AND E1_NUM   BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' " + CRLF
cQuery += " AND E1_PREFIXO  BETWEEN '"+mv_par07+"' AND '"+mv_par08+"' " + CRLF
cQuery += " AND E1_CLIENTE BETWEEN '"+mv_par09+"' AND '"+mv_par10+"' " + CRLF
cQuery += " AND E1_LOJA BETWEEN '"+mv_par11+"' AND '"+mv_par12+"' " + CRLF
cQuery += " AND SE1.D_E_L_E_T_ = ' '  " + CRLF
cQuery += "GROUP BY A3_GEREN, F2_VEND1, A3_NOME, A1_COD, A1_LOJA, A1_NOME, E1_NUM, E1_PREFIXO, E1_PARCELA,E1_TIPO, E1_EMISSAO, " + CRLF
cQuery += "E1_VENCREA, E1_BAIXA, E1_COMIS1,F2_DOC, F2_SERIE , F2_EMISSAO,E1_COMIS1,E1_BASCOM1,E1_VALOR,E1_VALLIQ,E1_JUROS,E5_VALOR, " + CRLF
cQuery += "E5_DATA,E5_TIPODOC,E5_HISTOR,E5_MOTBX,E1_SALDO,A1_XPGCOM,A3_XCLT,A3_XPGCOM,A3_COMIS,E5_SEQ,E5_VLMULTA,E5_VLCORRE,E5_VLDESCO,E5_VLJUROS,A1_XCOMIS1,E5_XDEVCOM " + CRLF 

cQuery += "UNION " + CRLF

cQuery += "SELECT 'TITULO' AS TPREG, " + CRLF
cQuery += "'T' AS TIPO, " + CRLF
cQuery += "A3_GEREN AS GEREN, " + CRLF
cQuery += "F2_VEND1 AS VENDEDOR, " + CRLF
cQuery += "A3_NOME AS NOMEVEND, " + CRLF
cQuery += "A1_COD AS CODCLI, " + CRLF
cQuery += "A1_LOJA AS LOJA, " + CRLF
cQuery += "A1_NOME AS NOMECLI, " + CRLF 
cQuery += "'' AS PRODUTO, " + CRLF
cQuery += "'' AS DESCPROD, " + CRLF
cQuery += "'' AS ITEM, " + CRLF
cQuery += "F2_DOC AS DOC, " + CRLF
cQuery += "F2_SERIE AS SERIE, " + CRLF
cQuery += "F2_EMISSAO AS DTEMISSAO, " + CRLF
cQuery += "'' AS CONDPGTO, " + CRLF
cQuery += "0 AS VLBRUTO, " + CRLF
cQuery += "0 AS VLTOTAL, " + CRLF
cQuery += "0 AS VLICM, " + CRLF
cQuery += "0 AS VLICMRET, 0 AS VLIPI, " + CRLF 
cQuery += "0 AS VLDESC, 0 AS VLFRETE, " + CRLF
cQuery += "0 AS VLOUTROS, " + CRLF
cQuery += "0 AS CUSTO, " + CRLF
cQuery += "0 AS VLCOMIS1, " + CRLF
cQuery += "0 AS VLCOMTAB, " + CRLF
cQuery += "'' AS TABVIG, " + CRLF
cQuery += "E1_NUM AS NUMTIT, " + CRLF
cQuery += "E1_PREFIXO AS PREFIXO, " + CRLF
cQuery += "E1_PARCELA AS PARCELA, " + CRLF
cQuery += "E1_TIPO AS TIPOTIT, " + CRLF
cQuery += "E1_EMISSAO AS DTEMISSAOTIT, " + CRLF
cQuery += "E1_VENCREA AS DTVENCREA, " + CRLF
cQuery += "E1_BAIXA AS DTBAIXA,  " + CRLF
cQuery += "(E1_BASCOM1 * (-1)) AS VLBASCOM1, " + CRLF
cQuery += "(E1_COMIS1  * (-1)) AS VLCOM1, " + CRLF 
cQuery += "(E1_VALOR   * (-1)) AS VLTITULO , " + CRLF
cQuery += "(E1_VALLIQ  * (-1)) AS VALLIQTIT, " + CRLF
cQuery += "'' AS NFORIGEM, " + CRLF 
cQuery += "'' AS SERIEORI, " + CRLF
cQuery += "0 AS VALOR, " + CRLF
cQuery += "0 AS CALCCOMTAB, " + CRLF
cQuery += "0 AS CALCCOMDOC, " + CRLF
cQuery += "(E5_VALOR * (-1)) AS VLPAGO, " + CRLF
cQuery += "(E1_JUROS * (-1)) AS VLJUROS, " + CRLF
cQuery += "E5_DATA AS DTVLPAGO, " + CRLF
cQuery += "E5_TIPODOC AS TIPODOC, " + CRLF
cQuery += "'' AS HISTORICO, " + CRLF
cQuery += "'' AS PEDIDO, " + CRLF
cQuery += "(E1_SALDO * (-1)) AS SALDOTIT, " + CRLF
cQuery += "0 AS  VALACRS, " + CRLF
cQuery += "E5_MOTBX AS MOTBX, " + CRLF
cQuery += "A1_XPGCOM AS XA1PGCOM, " + CRLF 
cQuery += "A3_XCLT AS XCLT, " + CRLF 
cQuery += "A3_XPGCOM AS  XA3PGCOM, " + CRLF
cQuery += "A3_COMIS AS A3COMIS, " + CRLF
cQuery += "E5_SEQ AS E5SEQ, " + CRLF
cQuery += "(E5_VLMULTA * (-1)) AS VLMULTA, " + CRLF
cQuery += "(E5_VLCORRE * (-1)) AS VLCORRE, " + CRLF
cQuery += "(E5_VLDESCO * (-1)) AS VLDESCO, " + CRLF
cQuery += "(E5_VLJUROS * (-1)) AS JUROS, " + CRLF 
cQuery += "(A1_XCOMIS1 * (-1)) AS XCOMIS1, " + CRLF
cQuery += "E5_XDEVCOM AS DEVCOM, " + CRLF 
cQuery += "'' AS XREVCOM, " + CRLF
cQuery += "'' AS XB1TABCOM, " + CRLF
cQuery += "'' AS D2XREVCOM, " + CRLF
cQuery += "'' AS D2XDTRVC, " + CRLF
cQuery += "'' AS D2XTPCOM, " + CRLF
cQuery += "'' AS C6COMIS1, " + CRLF
cQuery += "'' AS C6XCOM1,  "+ CRLF
cQuery += "0 AS B1COMIS  "+ CRLF
cQuery += "FROM "+RetSqlName("SE1")+" AS SE1 WITH (NOLOCK) " + CRLF 
cQuery += "INNER JOIN "+RetSqlName("SE5")+" AS SE5 ON E5_FILIAL = E1_FILIAL  " + CRLF 
cQuery += " AND E5_NUMERO = E1_NUM " + CRLF
cQuery += " AND E5_PREFIXO = E1_PREFIXO " + CRLF
cQuery += " AND E5_PARCELA = E1_PARCELA " + CRLF
cQuery += " AND E5_CLIFOR = E1_CLIENTE " + CRLF
cQuery += " AND E5_LOJA = E1_LOJA " + CRLF
cQuery += " AND SE5.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SF2")+" AS SF2 WITH (NOLOCK) ON E1_FILIAL = F2_FILIAL " + CRLF 
cQuery += " AND E1_NUM = F2_DOC " + CRLF
cQuery += " AND E1_PREFIXO = F2_SERIE " + CRLF
cQuery += " AND E1_CLIENTE = F2_CLIENTE " + CRLF
cQuery += " AND E1_LOJA = F2_LOJA " + CRLF
cQuery += " AND E1_EMISSAO = F2_EMISSAO " + CRLF
cQuery += " AND SE1.D_E_L_E_T_ = ' '  " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SE3")+" AS SE3 ON E1_FILIAL = E3_FILIAL
cQuery += " AND E3_NUM = E1_NUM " + CRLF
cQuery += " AND E3_PREFIXO = E1_PREFIXO " + CRLF
cQuery += " AND E3_PARCELA = E1_PARCELA " + CRLF
cQuery += " AND E3_TIPO = E1_TIPO  " + CRLF
cQuery += " AND SE3.D_E_L_E_T_ = ' '  " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SA3")+" AS SA3 WITH (NOLOCK) ON A3_COD = F2_VEND1 " + CRLF 
cQuery += " AND SA3.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH (NOLOCK) ON A1_FILIAL = F2_FILIAL " + CRLF
cQuery += " AND A1_COD = F2_CLIENTE " + CRLF
cQuery += " AND A1_LOJA = F2_LOJA " + CRLF
cQuery += "WHERE E1_FILIAL = '"+xFilial("SE1")+"'  " + CRLF
cQuery += " AND F2_TIPO = 'N' " + CRLF
cQuery += " AND NOT E5_MOTBX IN ('LIQ','CAN') " + CRLF
cQuery += " AND E5_SITUACA = ' ' " + CRLF
cQuery += " AND E5_TIPODOC IN ('ES','E2')" + CRLF
cQuery += " AND E5_VALOR > 0 "+ CRLF
cQuery += " AND A1_XPGCOM = '2' "+ CRLF
cQuery += " AND A3_XPGCOM = '2' "+ CRLF
cQuery += " AND NOT E5_NATUREZ = 'DESCONT' " + CRLF
cQuery += " AND E1_EMISSAO BETWEEN '"+dtoS(mv_par15)+"' AND '"+dtoS(mv_par16)+"' " + CRLF
cQuery += " AND E5_DATA    BETWEEN '"+dtoS(mv_par01)+"' AND '"+dtoS(mv_par02)+"' " + CRLF 
cQuery += " AND F2_VEND1 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' " + CRLF
cQuery += " AND E1_NUM   BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' " + CRLF
cQuery += " AND E1_PREFIXO  BETWEEN '"+mv_par07+"' AND '"+mv_par08+"' " + CRLF
cQuery += " AND E1_CLIENTE BETWEEN '"+mv_par09+"' AND '"+mv_par10+"' " + CRLF
cQuery += " AND E1_LOJA BETWEEN '"+mv_par11+"' AND '"+mv_par12+"' " + CRLF
cQuery += " AND SE1.D_E_L_E_T_ = ' '  " + CRLF
cQuery += "GROUP BY A3_GEREN, F2_VEND1, A3_NOME, A1_COD, A1_LOJA, A1_NOME, E1_NUM, E1_PREFIXO, E1_PARCELA,E1_TIPO, E1_EMISSAO, " + CRLF
cQuery += "E1_VENCREA, E1_BAIXA, E1_COMIS1,F2_DOC, F2_SERIE , F2_EMISSAO,E1_COMIS1,E1_BASCOM1,E1_VALOR,E1_VALLIQ,E1_JUROS,E5_VALOR, " + CRLF
cQuery += "E5_DATA,E5_TIPODOC,E5_HISTOR,E5_MOTBX,E1_SALDO,A1_XPGCOM,A3_XCLT,A3_XPGCOM,A3_COMIS,E5_SEQ,E5_VLMULTA,E5_VLCORRE,E5_VLDESCO,E5_VLJUROS,A1_XCOMIS1,E5_XDEVCOM " + CRLF 

cQuery += "ORDER BY VENDEDOR,DOC,TPREG,PARCELA,DTVLPAGO " + CRLF

TCQuery cQuery New Alias "TRB1"

TRB1->(DbGoTop())

While TRB1->(!Eof())

	lAbre   := .T.
	
	// Tratamento do Tipo que vem do SQL NO ALIAS 
	_cPgCliente  := ""
	_cRepreClt   := ""
	_cPgRepre    := ""
	_cReprePorc  := 0
	_nCount      := 0
	_nComProd    := 0

	_cPgCliente  := TRB1->XA1PGCOM  // 1 = Não / 2 = Sim
	_cRepreClt   := TRB1->XCLT      // 1 = Não / 2 = Sim
	_cPgRepre    := TRB1->XA3PGCOM  // 1 = Não / 2 = Sim
	_cReprePorc  := TRB1->A3COMIS   // % do vendedor 
	_nPercCli    := TRB1->XCOMIS1   // % por cliente 

	If TRB1->TIPO == "N"
		_cTIPO 	:= "Normal"                 
	ElseIf TRB1->TIPO == "D"
		_cTIPO 	:= "Devolucao"                 
	ElseIf TRB1->TIPO == "T"
		_cTIPO 	:= "Titulo"                 
	Else 
		_cTIPO 	:= "Outros"
	EndIf

	If _cPgCliente == "2" .And. _cPgRepre == "2"

		If  AllTrim(TRB1->TPREG) == "FATURADO"

			_cDOC  		 := TRB1->DOC                    
			_cGEREN		 := TRB1->GEREN
			_cVENDEDOR   := TRB1->VENDEDOR
			_cTPREG	     := AllTrim(TRB1->TPREG)
			_cPARCELA  	 := TRB1->PARCELA
			_cNOMEVEND 	 := TRB1->NOMEVEND     
			_cCODCLI   	 := TRB1->CODCLI    
			_cLOJA       := TRB1->LOJA       	 
			_cNOMECLI    := TRB1->NOMECLI   
			_cTIPO       := _cTIPO          	     
			_cSERIE      := TRB1->SERIE
			_cPedido     := TRB1->PEDIDO
			_nComProd    := TRB1->VLCOMIS1
			_nVLBRUTO    += TRB1->VLBRUTO 
			_nVLICM	     += TRB1->VLICM   
			_nVLRET      += TRB1->VLICMRET
			_nVLIPI      += TRB1->VLIPI
			_nVLDESC     += TRB1->VLDESC 
			_nVLFRETE    += TRB1->VLFRETE
			_nVLOUTROS   += TRB1->VLOUTROS
			_nVlCUSTO    += TRB1->CUSTO
			_nVlValor    += TRB1->VALOR
			_nCalcTot01  += TRB1->VLTOTAL
			If _nComProd > 0
				_nVLTOTAL   += TRB1->VLTOTAL
				_nVALACRS   += TRB1->VALACRS
				_nCalcVl01  := TRB1->VLTOTAL  
				_nCalcVl02  := TRB1->XCOMIS1
				_nCalcVl03  := TRB1->VLCOMTAB
				_nCalcVl04  := TRB1->VLCOMIS1
				_nCalcVl05  := TRB1->A3COMIS
			Else 
				_nVLTOTAL   += 0
				_nVALACRS   += 0
				_nCalcVl01  += 0
				_nCalcVl02  += 0
				_nCalcVl03  += 0
				_nCalcVl04  += 0
				_nCalcVl05  += 0
			EndIf
			If TRB1->XA1PGCOM == "2" .And. TRB1->XA3PGCOM == "2" .And. TRB1->XCOMIS1 > 0 
				If _nComProd > 0
					_nComPerc    += Round((_nCalcVl01 * _nCalcVl02)/100,2)
					_nPercTab    += Round((_nCalcVl01 * _nCalcVl02)/100,2)
					_cTpCom      := "Comissão Por Cliente" // cliente
				Else 
					_nComPerc    += 0
					_nPercTab    += 0
					_cTpCom      := "Comissão Por Cliente" // cliente
				EndIf
			ElseIf TRB1->XA1PGCOM == "2" .And. TRB1->XCLT == "2" .And. TRB1->XA3PGCOM == "2" .And. TRB1->XCOMIS1 <= 0
				If _nComProd > 0
					_nComPerc    += Round((_nCalcVl01 * _nCalcVl05)/100,2)
					_nPercTab    += Round((_nCalcVl01 * _nCalcVl05)/100,2)
					_cTpCom      := "Comissão Por Vendedor" // vendedor
				Else 
					_nComPerc    += 0
					_nPercTab    += 0
					_cTpCom      := "Comissão Por Vendedor" // vendedor
				EndIf
			ElseIf TRB1->XCLT == "1" .And. TRB1->XA1PGCOM == "2" .And. TRB1->XA3PGCOM == "2" .And. TRB1->XCOMIS1 <= 0 
				If _nComProd > 0
					_nComPerc    += Round((_nCalcVl01 * _nCalcVl04)/100,2)
					_nPercTab    += Round((_nCalcVl01 * _nCalcVl03)/100,2)
					_cTpCom      := "Comissão Por Produto" // produto
				Else 
					_nComPerc    += 0
					_nPercTab    += 0
					_cTpCom      := "Comissão Por Produto" // produto
				EndIf
			Else 	
				_nComPerc    += 0
				_nPercTab    += 0
				_cTpCom      := "Comissão Zerada" // produto
			EndIf
			
			_lTemNota    := .T.
			_dDTVIG1     := DtoS(Posicione("PAA",1,xFilial("PAA")+TRB1->PRODUTO+TRB1->TABVIG+TRB1->D2XREVCOM,"PAA_DTVIG1")) 
			_dDTVIG2     := Dtos(Posicione("PAA",1,xFilial("PAA")+TRB1->PRODUTO+TRB1->TABVIG+TRB1->D2XREVCOM,"PAA_DTVIG2"))
			_dDTEMISSAO  := If(!Empty(TRB1->DTEMISSAO) .And. _cTIPO <> "Titulo",Substr(TRB1->DTEMISSAO,7,2)+"/"+Substr(TRB1->DTEMISSAO,5,2)+"/"+Substr(TRB1->DTEMISSAO,1,4),"")       
			_cCONDPGTO   := TRB1->CONDPGTO          
			_cDESCRIPGTO := Alltrim(Posicione("SE4",1,xFilial("SE4")+TRB1->CONDPGTO,"E4_DESCRI"))      
		
		EndIf
		
		If AllTrim(TRB1->TPREG) == "TITULO"

			_nConta++  

			If Select("TRB3") > 0
				TRB3->(DbCloseArea())
			EndIf

			cQueryC := "SELECT COUNT(E1_NUM) AS QUANT " + CRLF
			cQueryC += "FROM "+RetSqlName("SE1")+" AS SE1 " + CRLF
			cQueryC += " WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' " + CRLF
			cQueryC += " AND SE1.E1_NUM     = '"+TRB1->NUMTIT+"'  " + CRLF
			cQueryC += " AND SE1.E1_PREFIXO = '"+TRB1->PREFIXO+"'  " + CRLF
			cQueryC += " AND SE1.E1_CLIENTE = '"+TRB1->CODCLI+"'  " + CRLF
			cQueryC += " AND SE1.E1_LOJA    = '"+TRB1->LOJA+"'  " + CRLF
			cQueryC += " AND SE1.E1_TIPO    = 'NF '   " + CRLF
			cQueryC += " AND SE1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryC += "UNION " + CRLF			
			cQueryC += "SELECT COUNT(E5_NUMERO)*(-1) AS QUANT " + CRLF
			cQueryC += "FROM "+RetSqlName("SE5")+" AS SE5 " + CRLF
			cQueryC += " WHERE SE5.E5_FILIAL = '"+xFilial("SE5")+"' " + CRLF
			cQueryC += " AND SE5.E5_NUMERO  = '"+TRB1->NUMTIT+"'  " + CRLF
			cQueryC += " AND SE5.E5_PREFIXO = '"+TRB1->PREFIXO+"'  " + CRLF
			cQueryC += " AND SE5.E5_CLIFOR  = '"+TRB1->CODCLI+"'  " + CRLF
			cQueryC += " AND SE5.E5_LOJA    = '"+TRB1->LOJA+"'  " + CRLF
			cQueryC += " AND SE5.E5_MOTBX IN ('LIQ','CAN') " + CRLF
			cQueryC += " AND SE5.E5_TIPO    = 'NF '   " + CRLF
			cQueryC += " AND SE5.D_E_L_E_T_ = ' ' " + CRLF

			TCQUERY cQueryC NEW ALIAS TRB3

			TRB3->(dbGoTop())

			While TRB3->(!Eof())
							
				_nCount += TRB3->QUANT

				TRB3->(dbSkip())

			Enddo

			If TRB1->TIPODOC $ ("VL/BA/CP/V2/DC")

				If TRB1->DEVCOM <> "S" 
				
					_nVLCOMA1   := TRB1->VLCOM1    
					_nCMTOTAL   := ABS((_nVLTOTAL - _nVALACRS))
					_nBaseTit   := If (_nCount > 0,Round((_nCMTOTAL / _nCount),2),Round((_nCMTOTAL),2))
					_nTotSDPG	+= Round(TRB1->VLPAGO-TRB1->JUROS,2) 
					_nVLTITULO  := TRB1->VLTITULO 
					_nJuros     += TRB1->JUROS
				
					If TRB1->VLPAGO < TRB1->VLTITULO

						_nTabPerc  := ABS(Round((_nPercTab/_nVLTOTAL)*100,2))
						_nPercCom  := ABS(Round((_nComPerc/_nVLTOTAL)*100,2)) 
						_nCMTOTAL  := ABS((_nVLTOTAL - _nVALACRS))
						_nCalcBase := ABS((_nCMTOTAL / _nVLBRUTO))
						_nPartcip  := ((TRB1->VLPAGO-TRB1->JUROS) / TRB1->VLTITULO)  // Apoio no calculo pelo Eristeu 23/03/2022
						_nBase     += Round((_nPartcip * _nBaseTit),2)
						_nBasePg   := Round((_nPartcip * _nBaseTit),2)
						_nVlPgCom  := ABS(Round((_nBase * _nPercCom ) / 100,2))
						_nPgVlTab  := ABS(Round((_nBase * _nTabPerc ) / 100,2))

					Else 
						_nTabPerc  := ABS(Round((_nPercTab/_nVLTOTAL)*100,2))
						_nPercCom  := ABS(Round((_nComPerc/_nVLTOTAL)*100,2)) 
						_nBase     += _nBaseTit
						_nBasePg   := _nBaseTit
						_nVlPgCom  := ABS(Round((_nBase * _nPercCom ) / 100,2))
						_nPgVlTab  := ABS(Round((_nBase * _nTabPerc ) / 100,2))
					EndIf
				
				ElseIf TRB1->DEVCOM == "S" 

					_nVLCOMA1   := (ABS(TRB1->VLCOM1) * (-1))   
					_nCMTOTAL   := (_nVLTOTAL - _nVALACRS) 
					_nBaseTit   := If(_nCount > 0,Round((_nCMTOTAL / _nCount),2),Round((_nCMTOTAL),2))
					_nTotSDPG	+= (Round(ABS(TRB1->VLPAGO-TRB1->JUROS),2) * (-1))  
					_nVLTITULO  := (ABS(TRB1->VLTITULO) * (-1))  
					_nJuros     += (ABS(TRB1->JUROS)  * (-1)) 
				
					If ABS(TRB1->VLPAGO) < ABS(TRB1->VLTITULO)

						_nTabPerc  := (ABS(Round((_nPercTab/_nVLTOTAL)*100,2)) * (-1)) 
						_nPercCom  := (ABS(Round((_nComPerc/_nVLTOTAL)*100,2)) * (-1))  
						_nCMTOTAL  := (ABS((_nVLTOTAL - _nVALACRS))  * (-1)) 
						_nCalcBase := (ABS((_nCMTOTAL / _nVLBRUTO))  * (-1)) 
						_nPartcip  := ((TRB1->VLPAGO-TRB1->JUROS) / TRB1->VLTITULO)  // Apoio no calculo pelo Eristeu 23/03/2022
						_nBase     += (Round((_nPartcip * _nBaseTit),2)*(-1))
						_nBasePg   := (Round((_nPartcip * _nBaseTit),2)*(-1))
						_nVlPgCom  := (ABS(Round((_nBase * _nPercCom ) / 100,2))*(-1))
						_nPgVlTab  := (ABS(Round((_nBase * _nTabPerc ) / 100,2))*(-1))
					
					Else 
						_nTabPerc  := (ABS(Round((_nPercTab/_nVLTOTAL)*100,2)) * (-1)) 
						_nPercCom  := (ABS(Round((_nComPerc/_nVLTOTAL)*100,2)) * (-1))  
						_nBase     += (_nBaseTit * (-1)) 
						_nBasePg   := (_nBaseTit * (-1)) 
						_nVlPgCom  := (ABS(Round((_nBase * _nPercCom ) / 100,2))*(-1))
						_nPgVlTab  := (ABS(Round((_nBase * _nTabPerc ) / 100,2))*(-1))

					EndIf
				
				EndIf

			ElseIf TRB1->TIPODOC $ ("ES/E2") 
				
				_nVLCOMA1   := (ABS(TRB1->VLCOM1) * (-1))   
				_nCMTOTAL   := (_nVLTOTAL - _nVALACRS) 
				_nBaseTit   := If(_nCount > 0,Round((_nCMTOTAL / _nCount),2),Round((_nCMTOTAL),2))
				_nTotSDPG	+= (Round(ABS(TRB1->VLPAGO-TRB1->JUROS),2) * (-1))  
				_nVLTITULO  := (ABS(TRB1->VLTITULO) * (-1))  
				_nJuros     += (ABS(TRB1->JUROS)  * (-1)) 
			
				If ABS(TRB1->VLPAGO) < ABS(TRB1->VLTITULO)

					_nTabPerc  := (ABS(Round((_nPercTab/_nVLTOTAL)*100,2)) * (-1)) 
					_nPercCom  := (ABS(Round((_nComPerc/_nVLTOTAL)*100,2)) * (-1))  
					_nCMTOTAL  := (ABS((_nVLTOTAL - _nVALACRS))  * (-1)) 
					_nCalcBase := (ABS((_nCMTOTAL / _nVLBRUTO))  * (-1)) 
					_nPartcip  := ((TRB1->VLPAGO-TRB1->JUROS) / TRB1->VLTITULO)  // Apoio no calculo pelo Eristeu 23/03/2022
					_nBase     += (Round((_nPartcip * _nBaseTit),2)*(-1))
					_nBasePg   := (Round((_nPartcip * _nBaseTit),2)*(-1))
					_nVlPgCom  := (ABS(Round((_nBase * _nPercCom ) / 100,2))*(-1))
					_nPgVlTab  := (ABS(Round((_nBase * _nTabPerc ) / 100,2))*(-1))
				
				Else 
					_nTabPerc  := (ABS(Round((_nPercTab/_nVLTOTAL)*100,2)) * (-1)) 
					_nPercCom  := (ABS(Round((_nComPerc/_nVLTOTAL)*100,2)) * (-1))  
					_nBase     += (_nBaseTit * (-1)) 
					_nBasePg   := (_nBaseTit * (-1)) 
					_nVlPgCom  := (ABS(Round((_nBase * _nPercCom ) / 100,2))*(-1))
					_nPgVlTab  := (ABS(Round((_nBase * _nTabPerc ) / 100,2))*(-1))

				EndIf
				
			Endif 

		EndIf
		
		oExcel:AddRow(cPlan, cTit,{AllTrim(TRB1->TPREG),;       //01
											TRB1->GEREN,;       //02        
											TRB1->VENDEDOR,;    //03	 
											TRB1->NOMEVEND,;    //04     
											TRB1->CODCLI,; 	    //05	 
											TRB1->LOJA,;   	    //06	 
											TRB1->NOMECLI,;     //07	 
											TRB1->PRODUTO,;     //08     
											TRB1->DESCPROD,;    //09	     
											If(_cTIPO == "Titulo","",_cTIPO),;     //10
											If(_cTIPO == "Titulo","",TRB1->DOC),;  //11     
											If(_cTIPO == "Titulo","",TRB1->SERIE),;//12     
											If(_cTIPO == "Titulo","",_dDTEMISSAO),;//13     
											TRB1->CONDPGTO,;     //14     
											If(_cTIPO == "Titulo","",_cDESCRIPGTO),;//15     
											TRB1->VLBRUTO,;      //16     
											TRB1->VLICM,;        //17     
											TRB1->VLICMRET,;     //18     
											TRB1->VLIPI,;        //19     
											TRB1->VLDESC,;       //20     
											TRB1->VLFRETE,;      //21     
											TRB1->VLOUTROS,;     //22     
											TRB1->CUSTO,;        //23
											TRB1->VALACRS,;      //24 
											TRB1->VLTOTAL,;      //25     
											TRB1->VALOR,;        //26   
											If(_cTIPO <> "Titulo",Transform(ABS(((TRB1->CUSTO / TRB1->VALOR)*100)-100),"@R 999.99%"),0),; //27   
											If(_cTIPO <> "Titulo",Transform(TRB1->VLCOMIS1,"@R 999.99%"),0),;        //28 
											If(_cTIPO <> "Titulo",Round((TRB1->VLTOTAL * TRB1->VLCOMIS1)/100,2),0),; //29
											If(!Empty(TRB1->D2XDTRVC) .And. _cTIPO <> "Titulo",TRB1->TABVIG,""),;     //30     
											If(!Empty(TRB1->D2XDTRVC) .And. _cTIPO <> "Titulo",TRB1->D2XREVCOM,""),;  //31     
											If(!Empty(TRB1->D2XDTRVC) .And. _cTIPO <> "Titulo",Substr(TRB1->D2XDTRVC,7,2)+"/"+Substr(TRB1->D2XDTRVC,5,2)+"/"+Substr(TRB1->D2XDTRVC,1,4),""),;  //32         
											If(_cTIPO <> "Titulo",If(TRB1->XCLT == "2".And.TRB1->XA3PGCOM == "2",Transform(TRB1->A3COMIS,"@R 999.99%"),Transform(TRB1->VLCOMTAB,"@R 999.99%")),""),; //33
											If(_cTIPO <> "Titulo",If(TRB1->XCLT == "2".And.TRB1->XA3PGCOM == "2",Round((TRB1->VLTOTAL * TRB1->A3COMIS)/100,2) , Round((TRB1->VLTOTAL * TRB1->VLCOMTAB)/100,2)),""),;  //34
											If(_cTIPO <> "Titulo",If(TRB1->XCLT == "2".And.TRB1->XA3PGCOM == "2",Round(((TRB1->VLTOTAL * TRB1->VLCOMIS1)/100) - ((TRB1->VLTOTAL * TRB1->A3COMIS)/100),2),Round(((TRB1->VLTOTAL * TRB1->VLCOMIS1)/100) - ((TRB1->VLTOTAL * TRB1->VLCOMTAB)/100),2)),""),; //35 
											If(!Empty(_dDTVIG1) .And. _cTIPO <> "Titulo",Substr(_dDTVIG1,7,2)+"/"+Substr(_dDTVIG1,5,2)+"/"+Substr(_dDTVIG1,1,4),""),;  //36    
											If(!Empty(_dDTVIG2) .And. _cTIPO <> "Titulo",Substr(_dDTVIG2,7,2)+"/"+Substr(_dDTVIG2,5,2)+"/"+Substr(_dDTVIG2,1,4),""),;  //37     
											If(!Empty(TRB1->TABVIG),If(Posicione("PAA",1,xFilial("PAA")+TRB1->PRODUTO+TRB1->TABVIG+TRB1->D2XREVCOM,"PAA_MSBLQL")=='1',"Bloqueado","Desbloqueado"),""),; //38     
											TRB1->NUMTIT,;       //39     
											TRB1->PREFIXO,;      //40		 
											TRB1->PARCELA,;      //41     
											TRB1->TIPOTIT,;      //42    
											If(!Empty(TRB1->DTEMISSAOTIT),Substr(TRB1->DTEMISSAOTIT,7,2)+"/"+Substr(TRB1->DTEMISSAOTIT,5,2)+"/"+Substr(TRB1->DTEMISSAOTIT,1,4),""),; //43
											If(!Empty(TRB1->DTVENCREA),Substr(TRB1->DTVENCREA,7,2)+"/"+Substr(TRB1->DTVENCREA,5,2)+"/"+Substr(TRB1->DTVENCREA,1,4),""),;             //44
											If(!Empty(TRB1->DTBAIXA),Substr(TRB1->DTBAIXA,7,2)+"/"+Substr(TRB1->DTBAIXA,5,2)+"/"+Substr(TRB1->DTBAIXA,1,4),""),;                     //45   
											Round(TRB1->VLPAGO-TRB1->JUROS,2),; //46 
											TRB1->VLBASCOM1,;       //47  
											If(_cTIPO == "Titulo",_nBasePg,0),;  // 48
											If(_cTIPO == "Titulo",Transform(_nVLCOMA1,"@R 999.99%"),0),;   //49 
											If(_cTIPO == "Titulo",If(TRB1->TIPODOC $ "ES/E2",(Round((_nBasePg * _nVLCOMA1)/100,2)*(-1)),Round((_nBasePg * _nVLCOMA1)/100,2)),0),; //50
											If(_cTIPO == "Titulo",Round(_nBasePg,2),0),;  // 51
											If(_cTIPO == "Titulo",Transform(_nTabPerc,"@R 999.99%"),0),;    //52 
											If(_cTIPO == "Titulo",If(TRB1->TIPODOC $ "ES/E2",(Round((_nBasePg * _nTabPerc )/100,2)*(-1)),Round((_nBasePg * _nTabPerc )/100,2)),0),; //53
											If(_cTIPO == "Titulo",(Round((_nBasePg * _nVLCOMA1)/100,2) - Round((_nBasePg * _nTabPerc)/100,2)),0),; //54
											TRB1->VLTITULO,;          //55  
											TRB1->JUROS,;          //56
											AllTrim(TRB1->TIPODOC),;  //57
											If(AllTrim(TRB1->TPREG) == "TITULO",Substr(TRB1->DTVLPAGO,7,2)+"/"+Substr(TRB1->DTVLPAGO,5,2)+"/"+Substr(TRB1->DTVLPAGO,1,4),""),; //58
														"",;    //59 
														"",;    //60
														"",;    //61
											If(Empty(_cTpCom),"Comissão Zerada",_cTpCom)}) //62
	EndIf 
	
	TRB1->(DbSkip())

	IncProc("Gerando arquivo...")	

	If TRB1->(EOF()) .Or. TRB1->DOC <> _cDOC   
	
		_nPCalcCom   := Round((_nComPerc/_nVLTOTAL)*100,2) 
		_nPCalcTab   := Round((_nPercTab/_nVLTOTAL)*100,2) 	
	
		oExcel:AddRow(cPlan,cTit,{"Total",; //01
							_cGEREN,; //02  
							_cVENDEDOR,; //03  
							_cNOMEVEND,; //04 
							_cCODCLI,; //05 
								_cLOJA,; //06 
							_cNOMECLI,; //07 
									"",; //08 
									"",; //09 
									"",; //10 
								_cDOC,; //11 
							_cSERIE,; //12 
						_dDTEMISSAO,; //13 
							_cCONDPGTO,; //14 
						_cDESCRIPGTO,; //15 
					Round(_nVLBRUTO,2),; //16 
					Round(_nVLICM,2),; //17       
					Round(_nVLRET,2),; //18    
					Round(_nVLIPI,2),; //19      
					Round(_nVLDESC,2),; //20     
					Round(_nVLFRETE,2),; //21    
				Round(_nVLOUTROS,2),; //22   
					Round(_nVlCUSTO,2),; //23
					Round(_nVALACRS,2),; //24  
					Round(_nCalcTot01,2),; //25
					Round(_nVlValor,2),; //26
					Transform(ABS(((_nVlCUSTO/_nVlValor)*100)-100),"@R 999.99%"),; //27
						Transform(_nPCalcCom,"@R 999.99%"),; //28
					Round(_nComPerc,2),; //29   
									"",; //30 
									"",; //31
									"",; //32
				Transform(_nPCalcTab,"@R 999.99%"),; //33 
				Round(_nPercTab,2) ,; //34 
			Round((_nComPerc - _nPercTab),2),; //35
									"",; //36 
									"",; //37 
									"",; //38 
									"",; //39 
									"",; //40 
									"",; //41 
									"",; //42 
									"",; //43 
							"S U B",; //44 
			"T O T A L -> T I T U L O",; //45 
					Round(_nTotSDPG,2),; //46
									"",; //47
						Round(_nBase,2),; //48
	Transform(_nPCalcCom,"@R 999.99%"),; //49
	Round(( _nBase * _nPCalcCom)/100,2),; //50
					Round(_nBase,2),; //51
	Transform(_nPCalcTab,"@R 999.99%"),; //52
	Round(( _nBase * _nPCalcTab)/100,2),; //53
	Round(( _nBase * _nPCalcCom)/100,2) - Round(( _nBase * _nPCalcTab)/100,2),; //54
									"",; //55
									"",; //56
									"",; //57
									"",; //58		 
					If(_nPCalcCom==Round(_nVLCOMA1,2),"OK", "DIVERGENTE"),; //59
					If(_nPCalcCom==_nPCalcTab,"OK", "DIVERGENTE"),;         //60
					If(Round(_nVLCOMA1,2)==_nPCalcTab,"OK","DIVERGENTE"),;  //61
					""})  //62 

		oExcel:AddRow(cPlan, cTit,{		"",; //01  
										"",; //02  
										"",; //03 
										"",; //04 
										"",; //05 
										"",; //06 
										"",; //07 
										"",; //08 
										"",; //09 
										"",; //10									   
										"",; //11 
										"",; //12 
										"",; //13 
										"",; //14 
										"",; //15 
										"",; //16 
										"",; //17 
										"",; //18 
										"",; //19 
										"",; //20 
										"",; //21       
										"",; //22    
										"",; //23      
										"",; //24     
										"",; //25    
										"",; //26   
										"",; //27    
										"",; //28   
										"",; //29 
										"",; //30 
										"",; //31 
										"",; //32 
										"",; //33 
										"",; //34 
										"",; //35 
										"",; //36 
										"",; //37 
										"",; //38 
										"",; //39 
										"",; //40 
										"",; //41 
										"",; //42 
										"",; //43 
										"",; //44 
										"",; //45 
										"",; //46 
										"",; //47 
										"",; //48 
										"",; //49 
										"",; //50 
										"",; //51 
										"",; //52 
										"",; //53 
										"",; //54 
										"",; //55 
										"",; //56 
										"",; //57 
										"",; //58 
										"",; //59 
										"",; //60 
										"",; //61 
										""}) //62 
		_lTemNota   := .F.
		_cDOC  		:= ""                    
		_cGEREN		:= ""
		_cVENDEDOR  := ""
		_cTPREG	    := ""
		_cPARCELA  	:= ""
		_cNOMEVEND 	:= ""     
		_cCODCLI   	:= ""    
		_cLOJA      := ""       	 
		_cNOMECLI   := ""   
		_cTIPO      := ""          	     
		_cDOC       := ""               
		_cSERIE     := ""
		_cPedido    := ""
		_cPgCliente := ""
		_cRepreClt  := ""
		_cPgRepre   := ""
		_cSeq       := ""
		_cTpCom     := ""
		_nVLBRUTO   := 0 
		_nVLICM	    := 0
		_nVLRET     := 0
		_nVLIPI     := 0
		_nVLDESC    := 0
		_nVLFRETE   := 0
		_nVLOUTROS  := 0
		_nVLTOTAL   := 0
		_nVALACRS   := 0
		_nPartcip   := 0
		_nCalcTot01 := 0
		
		_nTotVlTit  := 0
		_nCalcBase  := 0
		_nBase      := 0
		_nBaseCalc  := 0
		_nPercTab   := 0
		_nTabPerc   := 0
		_cReprePorc := 0
		_nCMTOTAL   := 0
		_nConta     := 0 
		_nPercCom   := 0 
		_nComPerc   := 0
		_nComNeg    := 0
		_nVlCusto   := 0
		_nVlValor   := 0
		_nPCalcTab  := 0
		_nPCalcCom  := 0
		_nComBase   := 0
		_nTotSDPG	:= 0
		_nVLCOMA1   := 0
		_nVLTITULO  := 0
		_nBasePg    := 0 
		_nJuros     := 0
		_nCount     := 0
		_nCalcVl01  := 0
		_nCalcVl02  := 0
		_nCalcVl03  := 0
		_nCalcVl04  := 0
		_nCalcVl05  := 0

	EndIf

EndDo

If lAbre

	oExcel:Activate()
	oExcel:GetXMLFile(cArqDst)
	OPENXML(cArqDst)
	oExcel:DeActivate()

Else

	MsgInfo("Não existe dados para serem impressos.", "SEM DADOS")

EndIf

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf
If Select("TRB3") > 0
	TRB3->(DbCloseArea())
EndIf
If Select("TRB4") > 0
	TRB4->(DbCloseArea())
EndIf

Return

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | OPENXML   | Autor: | QUALY         | Data: | 13/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - OPENXML                                      |
+------------+-----------------------------------------------------------+
*/

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

/*
+------------+------------+--------+---------------+-------+--------------+
| Programa:  | oAjustaSx1 | Autor: | QUALY         | Data: | 13/02/21     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - Perguntas                                     |
+------------+------------------------------------------------------------+
*/
Static Function oAjustaSx1()

Local _aPerg  := {}  // aRRAY 
Local _ni

Aadd(_aPerg,{"Data Baixa De  ....?","mv_ch1","D",08,"G","mv_par01","","","","","","","","",0})
Aadd(_aPerg,{"Data Baixa Até ....?","mv_ch2","D",08,"G","mv_par02","","","","","","","","",0})

Aadd(_aPerg,{"Representante De  ..?","mv_ch3","C",06,"G","mv_par03","","","","","","SA3","","",0})
Aadd(_aPerg,{"Representante Até ..?","mv_ch4","C",06,"G","mv_par04","","","","","","SA3","","",0})

Aadd(_aPerg,{"Numero Nf/Tit. De ..?","mv_ch5","C",09,"G","mv_par05","","","","","","","","",0})
Aadd(_aPerg,{"Numero Nf/Tit. Até .?","mv_ch6","C",09,"G","mv_par06","","","","","","","","",0})

Aadd(_aPerg,{"Serie/Prefixo De  ..?","mv_ch7","C",03,"G","mv_par07","","","","","","","","",0})
Aadd(_aPerg,{"Serie/Prefixo Até ..?","mv_ch8","C",03,"G","mv_par08","","","","","","","","",0})

Aadd(_aPerg,{"Cliente De  ........?","mv_ch9","C",06,"G","mv_par09","","","","","","SA1","","",0})
Aadd(_aPerg,{"Cliente Até ........?","mv_cha","C",06,"G","mv_par10","","","","","","SA1","","",0})

Aadd(_aPerg,{"Loja De ............?","mv_chb","C",02,"G","mv_par11","","","","","","SA1","","",0})
Aadd(_aPerg,{"Loja Até ...........?","mv_chc","C",02,"G","mv_par12","","","","","","SA1","","",0})

Aadd(_aPerg,{"Cod. Produto De ....?","mv_chd","C",15,"G","mv_par13","","","","","","SB1","","",0})
Aadd(_aPerg,{"Cod. Produto Até ...?","mv_che","C",15,"G","mv_par14","","","","","","SB1","","",0})

Aadd(_aPerg,{"Data Emissao De ....?","mv_chg","D",08,"G","mv_par15","","","","","","","","",0})
Aadd(_aPerg,{"Data Emissao Até ...?","mv_chh","D",08,"G","mv_par16","","","","","","","","",0})


dbSelectArea("SX1")
For _ni := 1 To Len(_aPerg)
	If !dbSeek(_cPerg+ SPACE( LEN(SX1->X1_GRUPO) - LEN(_cPerg))+StrZero(_ni,2))
		RecLock("SX1",.T.)
		SX1->X1_GRUPO    := _cPerg
		SX1->X1_ORDEM    := StrZero(_ni,2)
		SX1->X1_PERGUNT  := _aPerg[_ni][1]
		SX1->X1_VARIAVL  := _aPerg[_ni][2]
		SX1->X1_TIPO     := _aPerg[_ni][3]
		SX1->X1_TAMANHO  := _aPerg[_ni][4]
		SX1->X1_GSC      := _aPerg[_ni][5]
		SX1->X1_VAR01    := _aPerg[_ni][6]
		SX1->X1_DEF01    := _aPerg[_ni][7]
		SX1->X1_DEF02    := _aPerg[_ni][8]
		SX1->X1_DEF03    := _aPerg[_ni][9]
		SX1->X1_DEF04    := _aPerg[_ni][10]
		SX1->X1_DEF05    := _aPerg[_ni][11]
		SX1->X1_F3       := _aPerg[_ni][12]
		SX1->X1_CNT01    := _aPerg[_ni][13]
		SX1->X1_VALID    := _aPerg[_ni][14]
		SX1->X1_DECIMAL  := _aPerg[_ni][15]
		MsUnLock()
	EndIf
Next _ni

Return
// fim
