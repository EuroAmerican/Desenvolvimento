#include "parmtype.ch"
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"
#include "Colors.ch"
#include "RwMake.ch"

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

/*/{Protheus.doc} QEFIN440 rotina para comissão
//Relacao de conferencia de comissão por vendedor 
@type function Rotina customizada 
@Autor Fabio Carneiro 
@since 13/02/2022
@version 1.0
@History Foi incluido o conceito para tratamento de comissão por cliente em 26/05/2022 - Fabio Carneiro 
@History Ajustado em 09/09/2022 tratamento referente a não considerar comissão se o item estiver zerado - Fabio carneiro dos Santos
@return  character, sem retorno especifico
/*/

User Function QEFIN440()

Local aSays   		:= {}
Local aButtons		:= {}
Local cTitoDlg		:= "Atualização de Comissão pela baixa especifico QUALY"
Local nOpca   		:= 0
Private _cPerg		:= "QEFI44"
Private cMotBaixa	:= SuperGetMV("MV_XMOTBX", .T.,  "('LIQ', 'CAN', 'PRD', 'DAC', 'BSC', 'CEC', 'CMP' )"  )  //  U_MotBaixa()

aAdd(aSays, "Rotina para ATUALIZAR COMISSÕES QUALY de acordo com o periodo informado!!!")
aAdd(aSays, "O cálculo é gerado pela baixa, para listar no relatório MATR540.")
aAdd(aSays, "Caso seja utilizado esta Rotina, serão deletados os registros e gerados novamente.")
aAdd(aSays, "Serão gerados as comissões de acordo com as baixas e estornos que ocorreram no recebimento")
aAdd(aSays, "Esta Rotina vcerifica e acerta a base de comissão de acordo com a nota fiscal de origem.")

aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

FormBatch(cTitoDlg, aSays, aButtons)

If nOpca == 1
	
	oAjustaSx1()

	If !Pergunte(_cPerg,.T.)
		Return
	Else 
		MontaDir("C:\TOTVS\")
		Processa({|| QEFIN440ok()}, "Gerando carga de dados, aguarde...")		// Processa({|| QEFIN440ok("Gerando carga de dados, aguarde...")}) 
	Endif
		
EndIf

Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEFIN440ok| Autor: | QUALY         | Data: | 13/02/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção -QEFIN440ok                                   |
+------------+-----------------------------------------------------------+
*/

Static Function QEFIN440ok()

Local cArqDst          := "C:\TOTVS\QEFIN440_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
Local oExcel           := FWMsExcelEX():New()
Local cPlan            := "Empresa_" + Rtrim(SM0->M0_CODIGO) + "_Filial_" + Rtrim(SM0->M0_CODFIL)
Local cTit             := "Conferência de Carga de Comissão das Baixas dos Titulos De: " +Dtoc(MV_PAR01) + " Ate: " + Dtoc(MV_PAR02)

Local lAbre            := .F.
Local _lPassa          := .T. 
Local _lTemNota        := .F.

Local _nCom            := 0
Local _nVLBRUTO        := 0
Local _nVLICM          := 0
Local _nVLRET          := 0
Local _nVLIPI          := 0
Local _nVLDESC         := 0
Local _nVLFRETE        := 0
Local _nVLOUTROS       := 0
Local _nVLTOTAL        := 0
Local _nVLCOMIS1       := 0
lOCAL _nVLCOMTAB       := 0
Local _nVALACRS        := 0
Local _nTotVlTit       := 0
Local _nCalcBase       := 0
Local _nBase           := 0
Local _nVlPgCom  	   := 0
Local _nPgVlTab        := 0
Local _nBaseCalc       := 0
Local _nPercTab        := 0
Local _nTabPerc        := 0
Local _cReprePorc      := 0
Local _nCMTOTAL        := 0
Local _nConta          := 0
Local _nComPerc        := 0
Local _nPercCom        := 0
Local _nComNeg         := 0
Local _nCount          := 0
Local _nBaseTit        := 0
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
Local cQueryA          := ""
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
Local _cTPCOM          := ""

Local _aComis          := {}
Local _dDataFin        := GETMV("QE_XBLQFIM")
Local _dDtaAviso       := ""

/*
+------------------------------------------+
| VERIFICA DATA FECHAMENTO                 |
+------------------------------------------+
*/
If MV_PAR01 < _dDataFin .Or. MV_PAR02 <_dDataFin  
	_lCalcula  := .F.
	_dDtaAviso := Substr(DtoS(_dDataFin),7,2)+"/"+Substr(DtoS(_dDataFin),5,2)+"/"+Substr(DtoS(_dDataFin),1,4)	
    Aviso("Atenção !!!" ,"O periodo Informado para o cálculo de comissão encontra-se encerrado, Favor informar uma data superior a "+_dDtaAviso+" que já está fechado!" ,{"OK"})
	Return	
Else 
	_lCalcula := .T.
EndIf			
/*
+------------------------------------------+
| DADOS NO CABEÇALHO DA PLANILHA           |
+------------------------------------------+
*/

oExcel:AddworkSheet(cPlan)
oExcel:AddTable(cPlan, cTit)
oExcel:AddColumn(cPlan, cTit, "Status"             , 1, 1, .F.)  //01
oExcel:AddColumn(cPlan, cTit, "Vendedor"           , 1, 1, .F.)  //02
oExcel:AddColumn(cPlan, cTit, "Nome Vendedor"      , 1, 1, .F.)  //03
oExcel:AddColumn(cPlan, cTit, "Codigo Cliente"     , 1, 1, .F.)  //04
oExcel:AddColumn(cPlan, cTit, "Loja"               , 1, 1, .F.)  //05
oExcel:AddColumn(cPlan, cTit, "Nome Cliente"       , 1, 1, .F.)  //06
oExcel:AddColumn(cPlan, cTit, "Pedido Venda"       , 1, 1, .F.)  //07
oExcel:AddColumn(cPlan, cTit, "Dt. Pedido Venda"   , 1, 1, .F.)  //08
oExcel:AddColumn(cPlan, cTit, "Numero Tituto"      , 1, 1, .F.)  //09
oExcel:AddColumn(cPlan, cTit, "Prefixo Titulo"     , 1, 1, .F.)  //10
oExcel:AddColumn(cPlan, cTit, "Parcela Titulo"     , 1, 1, .F.)  //11
oExcel:AddColumn(cPlan, cTit, "Base Com. Tit."     , 3, 2, .F.)  //12
oExcel:AddColumn(cPlan, cTit, "% Comissão Titulo"  , 3, 2, .F.)  //13
oExcel:AddColumn(cPlan, cTit, "Valor Comissão"     , 3, 2, .F.)  //14
oExcel:AddColumn(cPlan, cTit, "Tipo BX Financ."    , 1, 1, .F.)  //15
oExcel:AddColumn(cPlan, cTit, "Data Bx Financeiro" , 1, 1, .F.)  //16
oExcel:AddColumn(cPlan, cTit, "Histrico Pgto"      , 1, 1, .F.)  //17
oExcel:AddColumn(cPlan, cTit, "% Comissão Calc."   , 3, 2, .F.)  //18
oExcel:AddColumn(cPlan, cTit, "Vl.Comissão Calc."  , 3, 2, .F.)  //19
oExcel:AddColumn(cPlan, cTit, "Numero do Item"     , 1, 1, .F.)  //20
oExcel:AddColumn(cPlan, cTit, "Tipo Comissão"      , 1, 1, .F.)  //21

/*
+-------------------------------------------+
| QUERY PARA DELETAR AS COMISSÕES           |
+-------------------------------------------+
*/

If _lCalcula 

	If Select("TRB2") > 0
		TRB2->(DbCloseArea())
	EndIf

	cQueryA := "SELECT * " + CRLF
	cQueryA += "FROM "+RetSqlName("SE3")+" AS SE3 " + CRLF
	cQueryA += " WHERE SE3.E3_FILIAL   = '"+xFilial("SE3")+"' " + CRLF
	cQueryA += " AND SE3.E3_EMISSAO BETWEEN '"+ Dtos(mv_par01) +"' AND '"+ Dtos(mv_par02) +"' " + CRLF
	cQueryA += " AND SE3.E3_VEND BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' " + CRLF	
	cQueryA += " AND SE3.E3_NUM BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' " + CRLF
	cQueryA += " AND SE3.E3_PREFIXO BETWEEN '"+mv_par07+"' AND '"+mv_par08+"' " + CRLF
	cQueryA += " AND SE3.E3_DATA = '"+Dtos(Ctod(""))+"' " + CRLF
	cQueryA += " AND SE3.E3_ORIGEM NOT IN(' ','L') " + CRLF
	cQueryA += " AND SE3.E3_BAIEMI='B'  " + CRLF
	cQueryA += " AND SE3.D_E_L_E_T_ = ' ' " + CRLF
				
	TCQUERY cQueryA NEW ALIAS TRB2

	TRB2->(dbGoTop())

	While TRB2->(!Eof())
				
		DbSelectArea("SE3")
		DbSetOrder(3)    //E3_FILIAL+E3_VEND+E3_CODCLI+E3_LOJA+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_TIPO+E3_SEQ
		If SE3->(dbSeek(xFilial("SE3")+TRB2->E3_VEND+TRB2->E3_CODCLI+TRB2->E3_LOJA+TRB2->E3_PREFIXO+TRB2->E3_NUM+TRB2->E3_PARCELA+TRB2->E3_TIPO+TRB2->E3_SEQ)) 

			RecLock("SE3")
			dbDelete()
			SE3->(MsUnlock())
				
		EndIf
		TRB2->(dbSkip())

	Enddo

	/*
	+-------------------------------------------+
	| QUERY REFERENTE OS MOVIMENTOS DE COMISSÃO |
	+-------------------------------------------+
	*/
	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf

	cQuery := "SELECT 'FATURADO' AS TPREG, " + CRLF
	cQuery += "       D2_TIPO    AS TIPO, " + CRLF
	cQuery += "       A3_GEREN   AS GEREN, " + CRLF 
	cQuery += "       F2_VEND1   AS VENDEDOR, " + CRLF
	cQuery += "       A3_NOME    AS NOMEVEND, " + CRLF
	cQuery += "       A1_COD     AS CODCLI, " + CRLF
	cQuery += "       A1_LOJA    AS LOJA , " + CRLF
	cQuery += "       A1_NOME    AS NOMECLI, " + CRLF
	cQuery += "       B1_COD     AS PRODUTO, " + CRLF
	cQuery += "       B1_DESC    AS DESCRI, " + CRLF
	cQuery += "       D2_ITEM    AS ITEM, " + CRLF
	cQuery += "       D2_DOC     AS DOC, " + CRLF
	cQuery += "       D2_SERIE   AS SERIE, " + CRLF
	cQuery += "       D2_EMISSAO AS DTEMISSAO, " + CRLF
	cQuery += "       F2_COND    AS CONDPGTO, " + CRLF
	cQuery += "       (D2_VALBRUT) AS VLBRUTO, " + CRLF
	cQuery += "       (D2_TOTAL)   AS VLTOTAL, " + CRLF
	cQuery += "       (D2_VALICM)  AS VLICM, " + CRLF
	cQuery += "       (D2_ICMSRET) AS VLICMRET, " + CRLF
	cQuery += "       (D2_VALIPI)  AS VLIPI, " + CRLF
	cQuery += "       (D2_DESCON)  AS VLDESC ," + CRLF
	cQuery += "       (D2_VALFRE)  AS VLFRETE, " + CRLF
	cQuery += "       (D2_SEGURO+D2_VALIMP5+D2_VALIMP6) AS VLOUTROS, " + CRLF 
	cQuery += "       D2_COMIS1    AS VLCOMIS1, " + CRLF
	cQuery += "       D2_XCOM1     AS VLCOMTAB, " + CRLF
	cQuery += "       '' AS NUMTIT, " + CRLF
	cQuery += "       '' AS PREFIXO, " + CRLF
	cQuery += "       '' AS PARCELA, " + CRLF
	cQuery += "       '' AS TIPOTIT, " + CRLF
	cQuery += "       '' AS DTEMISSAOTIT, " + CRLF
	cQuery += "       '' AS DTVENCREA, " + CRLF
	cQuery += "       '' AS DTBAIXA, " + CRLF
	cQuery += "       0  AS VLBASCOM1, " + CRLF
	cQuery += "       0  AS VLCOM1, " + CRLF
	cQuery += "       0  AS VLTITULO, " + CRLF
	cQuery += "       0  AS VALLIQTIT, " + CRLF
	cQuery += "       '' AS NFORIGEM, " + CRLF
	cQuery += "       '' AS SERIEORI, " + CRLF
	cQuery += "       (D2_TOTAL * D2_XCOM1)/100 AS CALCCOMTAB, " + CRLF
	cQuery += "       (D2_TOTAL * D2_COMIS1)/100 AS CALCCOMDOC, " + CRLF
	cQuery += "       0  AS VLPAGO, " + CRLF
	cQuery += "       0  AS VLJUROS, " + CRLF
	cQuery += "       '' AS DTVLPAGO, " + CRLF
	cQuery += "       '' AS TIPODOC, " + CRLF
	cQuery += "       '' AS HISTORICO, " + CRLF
	cQuery += "       D2_PEDIDO AS PEDIDO, " + CRLF
	cQuery += "       0  AS SALDOTIT, " + CRLF
	cQuery += "       D2_VALACRS AS  VALACRS, " + CRLF
	cQuery += "       '' AS MOTBX, " + CRLF
	cQuery += "       A1_XPGCOM AS XA1PGCOM, " + CRLF 
	cQuery += "       A3_XCLT AS XCLT, " + CRLF 
	cQuery += "       A3_XPGCOM AS  XA3PGCOM, " + CRLF
	cQuery += "       A3_COMIS AS A3COMIS, " + CRLF
	cQuery += "       '' AS E5SEQ, " + CRLF
	cQuery += "       0  AS VLMULTA, " + CRLF
	cQuery += "       0  AS VLCORRE, " + CRLF
	cQuery += "       0  AS VLDESCO, " + CRLF
	cQuery += "       0  AS JUROS, " + CRLF 
	cQuery += "       A1_XCOMIS1 AS XCOMIS1, " + CRLF
	cQuery += "       '' AS DEVCOM, " + CRLF
	cQuery += "       D2_XTPCOM AS XTPCOM " + CRLF
	cQuery += "  FROM "+RetSqlName("SD2")+" AS SD2 WITH (NOLOCK)  " + CRLF
	cQuery += " INNER JOIN "+RetSqlName("SF2")+" AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL " + CRLF
	cQuery += "   AND F2_DOC     = D2_DOC " + CRLF
	cQuery += "   AND F2_SERIE   = D2_SERIE " + CRLF
	cQuery += "   AND F2_CLIENTE = D2_CLIENTE " + CRLF
	cQuery += "   AND F2_LOJA    = D2_LOJA " + CRLF
	cQuery += "   AND F2_TIPO    = D2_TIPO " + CRLF
	cQuery += "   AND F2_EMISSAO = D2_EMISSAO " + CRLF
	cQuery += "   AND SF2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " INNER JOIN "+RetSqlName("SE1")+" AS SE1 WITH (NOLOCK) ON E1_FILIAL = F2_FILIAL " + CRLF 
	cQuery += "   AND E1_NUM     = F2_DOC " + CRLF
	cQuery += "   AND E1_PREFIXO = F2_SERIE " + CRLF
	cQuery += "   AND E1_CLIENTE = F2_CLIENTE " + CRLF
	cQuery += "   AND E1_LOJA    = F2_LOJA " + CRLF
	cQuery += "   AND E1_EMISSAO = F2_EMISSAO " + CRLF
	cQuery += "   AND SE1.D_E_L_E_T_ = ' '  " + CRLF
	cQuery += " INNER JOIN "+RetSqlName("SE5")+" AS SE5 ON E5_FILIAL = E1_FILIAL  " + CRLF 
	cQuery += "   AND E5_NUMERO  = E1_NUM " + CRLF
	cQuery += "   AND E5_PREFIXO = E1_PREFIXO " + CRLF
	cQuery += "   AND E5_PARCELA = E1_PARCELA " + CRLF
	cQuery += "   AND E5_CLIFOR  = E1_CLIENTE " + CRLF
	cQuery += "   AND E5_LOJA    = E1_LOJA " + CRLF
	cQuery += "   AND SE5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " INNER JOIN "+RetSqlName("SF4")+" AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(D2_FILIAL, 2) " + CRLF
	cQuery += "   AND F4_CODIGO = D2_TES " + CRLF
	cQuery += "   AND F4_DUPLIC = 'S' " + CRLF
	cQuery += "   AND SF4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) ON B1_FILIAL = '    ' " + CRLF
	cQuery += "   AND B1_COD = D2_COD " + CRLF
	cQuery += "   AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " INNER JOIN "+RetSqlName("SA3")+" AS SA3 WITH (NOLOCK) ON A3_COD = F2_VEND1 " + CRLF
	cQuery += "	  AND SA3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH (NOLOCK) ON A1_FILIAL = F2_FILIAL " + CRLF
	cQuery += "   AND A1_COD = F2_CLIENTE " + CRLF
	cQuery += "   AND A1_LOJA = F2_LOJA " + CRLF
	cQuery += " WHERE D2_FILIAL = '"+xFilial("SD2")+"' " + CRLF
	cQuery += "   AND D2_TIPO = 'N' " + CRLF
	cQuery += "   AND E1_TIPO = 'NF ' " + CRLF
	cQuery += "   AND D2_EMISSAO BETWEEN '"+dtoS(mv_par13)+"' AND '"+dtoS(mv_par14)+"' " + CRLF
	cQuery += "   AND E5_DATA    BETWEEN '"+dtoS(mv_par01)+"' AND '"+dtoS(mv_par02)+"' " + CRLF 
	cQuery += "   AND F2_VEND1   BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' " + CRLF
	cQuery += "   AND D2_DOC     BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' " + CRLF
	cQuery += "   AND D2_SERIE   BETWEEN '"+mv_par07+"' AND '"+mv_par08+"' " + CRLF
	cQuery += "   AND D2_CLIENTE BETWEEN '"+mv_par09+"' AND '"+mv_par10+"' " + CRLF
	cQuery += "   AND D2_LOJA    BETWEEN '"+mv_par11+"' AND '"+mv_par12+"' " + CRLF
	cQuery += "   AND A1_XPGCOM = '2' "+ CRLF
	cQuery += "   AND A3_XPGCOM = '2' "+ CRLF
	cQuery += "   AND SD2.D_E_L_E_T_ = ' '  " + CRLF
	cQuery += "GROUP BY D2_TIPO, A3_GEREN, F2_VEND1, A3_NOME, A1_COD, A1_LOJA, A1_NOME, D2_DOC,D2_SERIE,D2_EMISSAO,F2_COND,D2_PEDIDO, " + CRLF 
	cQuery += "      D2_COMIS1,D2_XCOM1,B1_COD,B1_DESC,D2_ITEM,D2_XTABCOM,D2_VALBRUT,D2_TOTAL,D2_VALICM,D2_ICMSRET,D2_VALIPI,D2_DESCON, " + CRLF
	cQuery += "      D2_VALFRE,D2_SEGURO,D2_VALIMP5,D2_VALIMP6,D2_CUSTO1,D2_DESPESA,D2_VALACRS,A1_XPGCOM,A3_XCLT,A3_XPGCOM,A3_COMIS,A1_XCOMIS1,D2_XTPCOM " + CRLF

	cQuery += "UNION " + CRLF

	cQuery += "SELECT 'TITULO' AS TPREG, " + CRLF
	cQuery += "       'T'      AS TIPO, " + CRLF
	cQuery += "       A3_GEREN AS GEREN, " + CRLF
	cQuery += "       F2_VEND1 AS VENDEDOR, " + CRLF
	cQuery += "       A3_NOME  AS NOMEVEND, " + CRLF
	cQuery += "       A1_COD   AS CODCLI, " + CRLF
	cQuery += "       A1_LOJA  AS LOJA, " + CRLF
	cQuery += "       A1_NOME  AS NOMECLI, " + CRLF 
	cQuery += "       '' AS PRODUTO, " + CRLF
	cQuery += "       '' AS DESCRI, " + CRLF
	cQuery += "       '' AS ITEM, " + CRLF
	cQuery += "       F2_DOC     AS DOC, " + CRLF
	cQuery += "       F2_SERIE   AS SERIE, " + CRLF
	cQuery += "       F2_EMISSAO AS DTEMISSAO, " + CRLF
	cQuery += "       '' AS CONDPGTO, " + CRLF
	cQuery += "       0  AS VLBRUTO, " + CRLF
	cQuery += "       0  AS VLTOTAL, " + CRLF
	cQuery += "       0  AS VLICM, " + CRLF
	cQuery += "       0  AS VLICMRET, 0 AS VLIPI, " + CRLF 
	cQuery += "       0  AS VLDESC, 0 AS VLFRETE, " + CRLF
	cQuery += "       0  AS VLOUTROS, " + CRLF
	cQuery += "       0  AS VLCOMIS1, " + CRLF
	cQuery += "       0  AS VLCOMTAB, " + CRLF
	cQuery += "       E1_NUM     AS NUMTIT, " + CRLF
	cQuery += "       E1_PREFIXO AS PREFIXO, " + CRLF
	cQuery += "       E1_PARCELA AS PARCELA, " + CRLF
	cQuery += "       E1_TIPO    AS TIPOTIT, " + CRLF
	cQuery += "       E1_EMISSAO AS DTEMISSAOTIT, " + CRLF
	cQuery += "       E1_VENCREA AS DTVENCREA, " + CRLF
	cQuery += "       E1_BAIXA   AS DTBAIXA,  " + CRLF
	cQuery += "       E1_BASCOM1 AS VLBASCOM1, " + CRLF
	cQuery += "       E1_COMIS1  AS VLCOM1, " + CRLF 
	cQuery += "       E1_VALOR   AS VLTITULO , " + CRLF
	cQuery += "       E1_VALLIQ  AS VALLIQTIT, " + CRLF
	cQuery += "       '' AS NFORIGEM, " + CRLF 
	cQuery += "       '' AS SERIEORI, " + CRLF
	cQuery += "       0  AS CALCCOMTAB, " + CRLF
	cQuery += "       0  AS CALCCOMDOC, " + CRLF
	cQuery += "       E5_VALOR   AS VLPAGO, " + CRLF
	cQuery += "       E1_JUROS   AS VLJUROS, " + CRLF
	cQuery += "       E5_DATA    AS DTVLPAGO, " + CRLF
	cQuery += "       E5_TIPODOC AS TIPODOC, " + CRLF
	cQuery += "       ''         AS HISTORICO, " + CRLF
	cQuery += "       E1_PEDIDO  AS PEDIDO, " + CRLF
	cQuery += "       E1_SALDO   AS SALDOTIT, " + CRLF
	cQuery += "       0          AS  VALACRS, " + CRLF
	cQuery += "       E5_MOTBX   AS MOTBX, " + CRLF
	cQuery += "       A1_XPGCOM  AS XA1PGCOM, " + CRLF 
	cQuery += "       A3_XCLT    AS XCLT, " + CRLF 
	cQuery += "       A3_XPGCOM  AS  XA3PGCOM, " + CRLF
	cQuery += "       A3_COMIS   AS A3COMIS, " + CRLF
	cQuery += "       E5_SEQ     AS E5SEQ, " + CRLF
	cQuery += "       E5_VLMULTA AS VLMULTA, " + CRLF
	cQuery += "       E5_VLCORRE AS VLCORRE, " + CRLF
	cQuery += "       E5_VLDESCO AS VLDESCO, " + CRLF
	cQuery += "       E5_VLJUROS AS JUROS, " + CRLF 
	cQuery += "       A1_XCOMIS1 AS XCOMIS1, " + CRLF
	cQuery += "       E5_XDEVCOM AS DEVCOM, " + CRLF 
	cQuery += "       '' AS XTPCOM " + CRLF
	cQuery += "  FROM "+RetSqlName("SE1")+" AS SE1 WITH (NOLOCK) " + CRLF 
	cQuery += " INNER JOIN "+RetSqlName("SE5")+" AS SE5 ON E5_FILIAL = E1_FILIAL  " + CRLF 
	cQuery += "   AND E5_NUMERO = E1_NUM " + CRLF
	cQuery += "   AND E5_PREFIXO = E1_PREFIXO " + CRLF
	cQuery += "   AND E5_PARCELA = E1_PARCELA " + CRLF
	cQuery += "   AND E5_CLIFOR = E1_CLIENTE " + CRLF
	cQuery += "   AND E5_LOJA = E1_LOJA " + CRLF
	cQuery += "   AND SE5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " INNER JOIN "+RetSqlName("SF2")+" AS SF2 WITH (NOLOCK) ON E1_FILIAL = F2_FILIAL " + CRLF 
	cQuery += "   AND E1_NUM = F2_DOC " + CRLF
	cQuery += "   AND E1_PREFIXO = F2_SERIE " + CRLF
	cQuery += "   AND E1_CLIENTE = F2_CLIENTE " + CRLF
	cQuery += "   AND E1_LOJA = F2_LOJA " + CRLF
	cQuery += "   AND E1_EMISSAO = F2_EMISSAO " + CRLF
	cQuery += "   AND SE1.D_E_L_E_T_ = ' '  " + CRLF
	cQuery += " INNER JOIN "+RetSqlName("SA3")+" AS SA3 WITH (NOLOCK) ON A3_COD = F2_VEND1 " + CRLF 
	cQuery += "   AND SA3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH (NOLOCK) ON A1_FILIAL = F2_FILIAL " + CRLF
	cQuery += "   AND A1_COD = F2_CLIENTE " + CRLF
	cQuery += "   AND A1_LOJA = F2_LOJA " + CRLF
	cQuery += " WHERE E1_FILIAL = '"+xFilial("SE1")+"'  " + CRLF
	cQuery += "   AND F2_TIPO = 'N' " + CRLF
	cQuery += "   AND E1_TIPO = 'NF ' " + CRLF
	cQuery += "   AND NOT E5_MOTBX IN " + cMotBaixa + CRLF						//('LIQ','CAN','PRD', 'DAC', 'BSC', 'CEC', 'CMP' ) " + CRLF
	cQuery += "   AND E5_TIPODOC IN ('VL','BA','CP','V2','DC') " + CRLF
	cQuery += "   AND E5_VALOR > 0 "+ CRLF
	cQuery += "   AND E5_SITUACA = ' ' " + CRLF
	cQuery += "   AND A1_XPGCOM = '2' "+ CRLF
	cQuery += "   AND A3_XPGCOM = '2' "+ CRLF
	cQuery += "   AND NOT E5_NATUREZ = 'DESCONT' " + CRLF
	cQuery += "   AND E1_EMISSAO BETWEEN '"+dtoS(mv_par13)+"' AND '"+dtoS(mv_par14)+"' " + CRLF
	cQuery += "   AND E5_DATA    BETWEEN '"+dtoS(mv_par01)+"' AND '"+dtoS(mv_par02)+"' " + CRLF 
	cQuery += "   AND F2_VEND1 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' " + CRLF
	cQuery += "   AND E1_NUM   BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' " + CRLF
	cQuery += "   AND E1_PREFIXO  BETWEEN '"+mv_par07+"' AND '"+mv_par08+"' " + CRLF
	cQuery += "   AND E1_CLIENTE BETWEEN '"+mv_par09+"' AND '"+mv_par10+"' " + CRLF
	cQuery += "   AND E1_LOJA BETWEEN '"+mv_par11+"' AND '"+mv_par12+"' " + CRLF
	cQuery += "   AND SE1.D_E_L_E_T_ = ' '  " + CRLF
	cQuery += " GROUP BY A3_GEREN, F2_VEND1, A3_NOME, A1_COD, A1_LOJA, A1_NOME, E1_NUM, E1_PREFIXO, E1_PARCELA,E1_TIPO, E1_EMISSAO,E1_PEDIDO, " + CRLF
	cQuery += "          E1_VENCREA, E1_BAIXA, E1_COMIS1,F2_DOC, F2_SERIE , F2_EMISSAO,E1_COMIS1,E1_BASCOM1,E1_VALOR,E1_VALLIQ,E1_JUROS,E5_VALOR, " + CRLF
	cQuery += "          E5_DATA,E5_TIPODOC,E5_HISTOR,E5_MOTBX,E1_SALDO,A1_XPGCOM,A3_XCLT,A3_XPGCOM,A3_COMIS,E5_SEQ,E5_VLMULTA,E5_VLCORRE,E5_VLDESCO,E5_VLJUROS,A1_XCOMIS1,E5_XDEVCOM " + CRLF 

	cQuery += "UNION " + CRLF

	cQuery += "SELECT 'TITULO'   AS TPREG, " + CRLF
	cQuery += "       'T'        AS TIPO, " + CRLF
	cQuery += "       A3_GEREN   AS GEREN, " + CRLF
	cQuery += "       F2_VEND1   AS VENDEDOR, " + CRLF
	cQuery += "       A3_NOME    AS NOMEVEND, " + CRLF
	cQuery += "       A1_COD     AS CODCLI, " + CRLF
	cQuery += "       A1_LOJA    AS LOJA, " + CRLF
	cQuery += "       A1_NOME    AS NOMECLI, " + CRLF 
	cQuery += "       ''         AS PRODUTO, " + CRLF
	cQuery += "       ''         AS DESCRI, " + CRLF
	cQuery += "       ''         AS ITEM, " + CRLF
	cQuery += "       F2_DOC     AS DOC, " + CRLF
	cQuery += "       F2_SERIE   AS SERIE, " + CRLF
	cQuery += "       F2_EMISSAO AS DTEMISSAO, " + CRLF
	cQuery += "       '' AS CONDPGTO, " + CRLF
	cQuery += "       0  AS VLBRUTO, " + CRLF
	cQuery += "       0  AS VLTOTAL, " + CRLF
	cQuery += "       0  AS VLICM, " + CRLF
	cQuery += "       0  AS VLICMRET, 0 AS VLIPI, " + CRLF 
	cQuery += "       0  AS VLDESC, 0 AS VLFRETE, " + CRLF
	cQuery += "       0  AS VLOUTROS, " + CRLF
	cQuery += "       0  AS VLCOMIS1, " + CRLF
	cQuery += "       0  AS VLCOMTAB, " + CRLF
	cQuery += "       E1_NUM     AS NUMTIT, " + CRLF
	cQuery += "       E1_PREFIXO AS PREFIXO, " + CRLF
	cQuery += "       E1_PARCELA AS PARCELA, " + CRLF
	cQuery += "       E1_TIPO    AS TIPOTIT, " + CRLF
	cQuery += "       E1_EMISSAO AS DTEMISSAOTIT, " + CRLF
	cQuery += "       E1_VENCREA AS DTVENCREA, " + CRLF
	cQuery += "       E1_BAIXA   AS DTBAIXA,  " + CRLF
	cQuery += "       (E1_BASCOM1 * (-1)) AS VLBASCOM1, " + CRLF
	cQuery += "       (E1_COMIS1  * (-1)) AS VLCOM1, " + CRLF 
	cQuery += "       (E1_VALOR   * (-1)) AS VLTITULO , " + CRLF
	cQuery += "       (E1_VALLIQ  * (-1)) AS VALLIQTIT, " + CRLF
	cQuery += "       ''         AS NFORIGEM, " + CRLF 
	cQuery += "       ''         AS SERIEORI, " + CRLF
	cQuery += "       0          AS CALCCOMTAB, " + CRLF
	cQuery += "       0          AS CALCCOMDOC, " + CRLF
	cQuery += "       (E5_VALOR * (-1)) AS VLPAGO, " + CRLF
	cQuery += "       (E1_JUROS * (-1)) AS VLJUROS, " + CRLF
	cQuery += "       E5_DATA    AS DTVLPAGO, " + CRLF
	cQuery += "       E5_TIPODOC AS TIPODOC, " + CRLF
	cQuery += "       ''         AS HISTORICO, " + CRLF
	cQuery += "       E1_PEDIDO  AS PEDIDO, " + CRLF
	cQuery += "       (E1_SALDO * (-1)) AS SALDOTIT, " + CRLF
	cQuery += "       0          AS  VALACRS, " + CRLF
	cQuery += "       E5_MOTBX   AS MOTBX, " + CRLF
	cQuery += "       A1_XPGCOM  AS XA1PGCOM, " + CRLF 
	cQuery += "       A3_XCLT    AS XCLT, " + CRLF 
	cQuery += "       A3_XPGCOM  AS  XA3PGCOM, " + CRLF
	cQuery += "       A3_COMIS   AS A3COMIS, " + CRLF
	cQuery += "       E5_SEQ     AS E5SEQ, " + CRLF
	cQuery += "       (E5_VLMULTA * (-1)) AS VLMULTA, " + CRLF
	cQuery += "       (E5_VLCORRE * (-1)) AS VLCORRE, " + CRLF
	cQuery += "       (E5_VLDESCO * (-1)) AS VLDESCO, " + CRLF
	cQuery += "       (E5_VLJUROS * (-1)) AS JUROS, " + CRLF 
	cQuery += "       (A1_XCOMIS1 * (-1)) AS XCOMIS1, " + CRLF
	cQuery += "       E5_XDEVCOM AS DEVCOM, " + CRLF 
	cQuery += "       '' AS XTPCOM " + CRLF
	cQuery += "  FROM "+RetSqlName("SE1")+" AS SE1 WITH (NOLOCK) " + CRLF 
	cQuery += " INNER JOIN "+RetSqlName("SE5")+" AS SE5 ON E5_FILIAL = E1_FILIAL  " + CRLF 
	cQuery += "   AND E5_NUMERO  = E1_NUM " + CRLF
	cQuery += "   AND E5_PREFIXO = E1_PREFIXO " + CRLF
	cQuery += "   AND E5_PARCELA = E1_PARCELA " + CRLF
	cQuery += "   AND E5_CLIFOR  = E1_CLIENTE " + CRLF
	cQuery += "   AND E5_LOJA    = E1_LOJA " + CRLF
	cQuery += "   AND SE5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN "+RetSqlName("SF2")+" AS SF2 WITH (NOLOCK) ON E1_FILIAL = F2_FILIAL " + CRLF 
	cQuery += "   AND E1_NUM     = F2_DOC " + CRLF
	cQuery += "   AND E1_PREFIXO = F2_SERIE " + CRLF
	cQuery += "   AND E1_CLIENTE = F2_CLIENTE " + CRLF
	cQuery += "   AND E1_LOJA    = F2_LOJA " + CRLF
	cQuery += "   AND E1_EMISSAO = F2_EMISSAO " + CRLF
	cQuery += "   AND SE1.D_E_L_E_T_ = ' '  " + CRLF
	cQuery += " INNER JOIN "+RetSqlName("SA3")+" AS SA3 WITH (NOLOCK) ON A3_COD = F2_VEND1 " + CRLF 
	cQuery += "   AND SA3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH (NOLOCK) ON A1_FILIAL = F2_FILIAL " + CRLF
	cQuery += "   AND A1_COD    = F2_CLIENTE " + CRLF
	cQuery += "   AND A1_LOJA   = F2_LOJA " + CRLF
	cQuery += " WHERE E1_FILIAL = '"+xFilial("SE1")+"'  " + CRLF
	cQuery += "   AND F2_TIPO   = 'N' " + CRLF
	cQuery += "   AND E1_TIPO   = 'NF ' " + CRLF
	cQuery += "   AND NOT E5_MOTBX IN " + cMotBaixa + CRLF						//('LIQ','CAN', 'PRD', 'DAC', 'BSC', 'CEC', 'CMP' ) " + CRLF
	cQuery += "   AND E5_SITUACA = ' ' " + CRLF
	cQuery += "   AND E5_TIPODOC IN ('ES','E2')" + CRLF
	cQuery += "   AND E5_VALOR > 0 "+ CRLF
	cQuery += "   AND NOT E5_NATUREZ = 'DESCONT' " + CRLF
	cQuery += "   AND A1_XPGCOM      = '2' "+ CRLF
	cQuery += "   AND A3_XPGCOM      = '2' "+ CRLF
	cQuery += "   AND E1_EMISSAO  BETWEEN '"+dtoS(mv_par13)+"' AND '"+dtoS(mv_par14)+"' " + CRLF
	cQuery += "   AND E5_DATA     BETWEEN '"+dtoS(mv_par01)+"' AND '"+dtoS(mv_par02)+"' " + CRLF 
	cQuery += "   AND F2_VEND1    BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' " + CRLF
	cQuery += "   AND E1_NUM      BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' " + CRLF
	cQuery += "   AND E1_PREFIXO  BETWEEN '"+mv_par07+"' AND '"+mv_par08+"' " + CRLF
	cQuery += "   AND E1_CLIENTE  BETWEEN '"+mv_par09+"' AND '"+mv_par10+"' " + CRLF
	cQuery += "   AND E1_LOJA     BETWEEN '"+mv_par11+"' AND '"+mv_par12+"' " + CRLF
	cQuery += "   AND SE1.D_E_L_E_T_ = ' '  " + CRLF
	cQuery += "GROUP BY A3_GEREN, F2_VEND1, A3_NOME, A1_COD, A1_LOJA, A1_NOME, E1_NUM, E1_PREFIXO, E1_PARCELA,E1_TIPO, E1_EMISSAO,E1_PEDIDO, " + CRLF
	cQuery += "      E1_VENCREA, E1_BAIXA, E1_COMIS1,F2_DOC, F2_SERIE , F2_EMISSAO,E1_COMIS1,E1_BASCOM1,E1_VALOR,E1_VALLIQ,E1_JUROS,E5_VALOR, " + CRLF
	cQuery += "      E5_DATA,E5_TIPODOC,E5_HISTOR,E5_MOTBX,E1_SALDO,A1_XPGCOM,A3_XCLT,A3_XPGCOM,A3_COMIS,E5_SEQ,E5_VLMULTA,E5_VLCORRE,E5_VLDESCO,E5_VLJUROS,A1_XCOMIS1,E5_XDEVCOM " + CRLF 

	cQuery += "ORDER BY VENDEDOR,DOC,TPREG,PARCELA,DTVLPAGO " + CRLF

	TCQuery cQuery New Alias "TRB1"

	TRB1->(DbGoTop())

	While TRB1->(!Eof())

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

				_cDOC  		:= TRB1->DOC                    
				_cGEREN		:= TRB1->GEREN
				_cVENDEDOR  := TRB1->VENDEDOR
				_cTPREG	    := AllTrim(TRB1->TPREG)
				_cPARCELA  	:= TRB1->PARCELA
				_cNOMEVEND 	:= TRB1->NOMEVEND     
				_cCODCLI   	:= TRB1->CODCLI    
				_cLOJA      := TRB1->LOJA       	 
				_cNOMECLI   := TRB1->NOMECLI   
				_cTIPO      := _cTIPO          	     
				_cSERIE     := TRB1->SERIE
				_cPedido    := TRB1->PEDIDO
				_nComProd   := TRB1->VLCOMIS1
				_nVLBRUTO   += TRB1->VLBRUTO 
				_nVLICM	    += TRB1->VLICM   
				_nVLRET     += TRB1->VLICMRET
				_nVLIPI     += TRB1->VLIPI
				_nVLDESC    += TRB1->VLDESC 
				_nVLFRETE   += TRB1->VLFRETE
				_nVLOUTROS  += TRB1->VLOUTROS
				_nCalcTot01 += TRB1->VLTOTAL
				
				If _nComProd > 0
					_nVLTOTAL   += TRB1->VLTOTAL
					_nVLCOMIS1  := TRB1->VLCOMIS1
					_nVLCOMTAB  := If(TRB1->XCLT=="2".And.TRB1->XA3PGCOM=="2",TRB1->A3COMIS,TRB1->VLCOMTAB)
					_nVALACRS   += TRB1->VALACRS
					_nCalcVl01  := TRB1->VLTOTAL  
					_nCalcVl02  := TRB1->XCOMIS1
					_nCalcVl03  := TRB1->VLCOMTAB
					_nCalcVl04  := TRB1->VLCOMIS1
					_nCalcVl05  := TRB1->A3COMIS
				Else 
					_nVLTOTAL   += 0
					_nVLCOMIS1  += 0
					_nVLCOMTAB  += 0
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
						_nPercTab    += Round((_nCalcVl01 * _nCalcVl03)/100,2)
						_cTPCOM      := "01"
					Else 
						_nComPerc    += 0
						_nPercTab    += 0
						_cTPCOM      := "01"
					EndIf
				ElseIf TRB1->XCLT == "1" .And. TRB1->XA1PGCOM == "2" .And. TRB1->XA3PGCOM == "2" .And. TRB1->XCOMIS1 <= 0 
					If _nComProd > 0
						_nComPerc    += Round((_nCalcVl01 * _nCalcVl04)/100,2)
						_nPercTab    += Round((_nCalcVl01 * _nCalcVl03)/100,2)
						_cTPCOM      := "02"
					Else 
						_nComPerc    += 0
						_nPercTab    += 0
						_cTPCOM      := "02"
					EndIf
				ElseIf TRB1->XCLT == "2" .And. TRB1->XA3PGCOM == "2" .And. TRB1->XCOMIS1 <= 0
					If _nComProd > 0
						_nComPerc    += Round((_nCalcVl01 * _nCalcVl05)/100,2)
						_nPercTab    += Round((_nCalcVl01 * _nCalcVl05)/100,2)
						_cTPCOM      := "03"
					Else 
						_nComPerc    += 0
						_nPercTab    += 0
						_cTPCOM      := "03"
					EndIf
				Else 
					_nComPerc    += 0
					_nPercTab    += 0
					_cTPCOM      := "04"
				EndIf

				_lTemNota   := .T.
				
			EndIf	
			
			If AllTrim(TRB1->TPREG) == "TITULO"

				_cSeq        := TRB1->E5SEQ
				_nConta++  

				// Conta os titulos na base SE1
				If Select("TRB3") > 0
					TRB3->(DbCloseArea())
				EndIf

				cQueryC := "SELECT COUNT(E1_NUM) AS QUANT " + CRLF
				cQueryC += "  FROM "+RetSqlName("SE1")+" AS SE1 " + CRLF
				cQueryC += " WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' " + CRLF
				cQueryC += "   AND SE1.E1_NUM     = '"+TRB1->NUMTIT+"'  " + CRLF
				cQueryC += "   AND SE1.E1_PREFIXO = '"+TRB1->PREFIXO+"'  " + CRLF
				cQueryC += "   AND SE1.E1_CLIENTE = '"+TRB1->CODCLI+"'  " + CRLF
				cQueryC += "   AND SE1.E1_LOJA    = '"+TRB1->LOJA+"'  " + CRLF
				cQueryC += "   AND SE1.E1_TIPO    = 'NF '   " + CRLF
				cQueryC += "   AND SE1.D_E_L_E_T_ = ' ' " + CRLF

				cQueryC += "UNION " + CRLF			

				cQueryC += "SELECT COUNT(E5_NUMERO)*(-1) AS QUANT " + CRLF
				cQueryC += "  FROM "+RetSqlName("SE5")+" AS SE5 " + CRLF
				cQueryC += " WHERE SE5.E5_FILIAL = '"+xFilial("SE5")+"' " + CRLF
				cQueryC += "   AND SE5.E5_NUMERO  = '"+TRB1->NUMTIT+"'  " + CRLF
				cQueryC += "   AND SE5.E5_PREFIXO = '"+TRB1->PREFIXO+"'  " + CRLF
				cQueryC += "   AND SE5.E5_CLIFOR  = '"+TRB1->CODCLI+"'  " + CRLF
				cQueryC += "   AND SE5.E5_LOJA    = '"+TRB1->LOJA+"'  " + CRLF
				cQueryC += "   AND SE5.E5_MOTBX IN " + cMotBaixa + CRLF						//('LIQ','CAN', 'PRD', 'DAC', 'BSC', 'CEC', 'CMP' ) " + CRLF
				cQueryC += "   AND SE5.E5_TIPO    = 'NF '   " + CRLF
				cQueryC += "   AND SE5.D_E_L_E_T_ = ' ' " + CRLF

				TCQUERY cQueryC NEW ALIAS TRB3

				TRB3->(dbGoTop())

				While TRB3->(!Eof())
							
					_nCount += TRB3->QUANT

					TRB3->(dbSkip())

				Enddo

				If TRB1->TIPODOC $ ("VL/BA/CP/V2/DC")
					
					// Calculo base sobre o valor do titulo 	
					If TRB1->XCOMIS1 > 0 .And. TRB1->XA1PGCOM == "2" .And. TRB1->XA3PGCOM == "2" .And. TRB1->XCLT <> "2"
						_nTabPerc   := TRB1->XCOMIS1 // Percentual tabela de comissão
						_nPercCom   := TRB1->XCOMIS1 // Percentual do Cliente  
						_cTPCOM     := "01" 
					
					ElseIf TRB1->XA1PGCOM == "2" .And. TRB1->XA3PGCOM == "2" .And. TRB1->XCLT == "2" .And. TRB1->XCOMIS1 <= 0 
						_nTabPerc   := TRB1->A3COMIS // Percentual tabela de comissão
						_nPercCom   := TRB1->A3COMIS // Percentual do Vendedor
						_cTPCOM     := "02" 
					Else 
						_nTabPerc   := ABS(Round((_nPercTab/_nVLTOTAL)*100,2)) // Percentual tabela de comissão
						_nPercCom   := ABS(Round((_nComPerc/_nVLTOTAL)*100,2)) 
					
						If TRB1->VLCOM1 == _nPercCom 
							_nPercCom  := ABS(Round((_nComPerc/_nVLTOTAL)*100,2)) 
						ElseIf TRB1->XCOMIS1 > 0
							_nPercCom  := TRB1->XCOMIS1
						Else 
							_nPercCom  := ABS(Round(TRB1->VLCOM1,2)) 
						EndIf
						If TRB1->VLCOM1 == ABS(NoRound((_nPercTab/_nVLTOTAL)*100,2)) 
							_nTabPerc   := ABS(NoRound((_nPercTab/_nVLTOTAL)*100,2)) // Percentual tabela de comissão
						Else 
							_nTabPerc   := ABS(Round((_nPercTab/_nVLTOTAL)*100,2)) // Percentual tabela de comissão
						EndIf

					EndIf					
	
					_nCMTOTAL   := ABS((_nVLTOTAL - _nVALACRS))
					_nBaseTit   := If (_nCount > 0,Round((_nCMTOTAL / _nCount),2),Round((_nCMTOTAL),2))
					_nBaseCalc  := ABS((_nCMTOTAL / _nVLBRUTO))

					// Foi dicido em reunião que somente será alterado a base de comissão na tabela 
					// SE1 até da data de 29/02/2022
					
					If TRB1->VLBASCOM1 <> _nBaseTit .Or. TRB1->VLCOM1 <= 0 
						
						DbSelectArea("SE1")
						DbSetOrder(1)  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
						If SE1->(dbSeek(xFilial("SE1")+TRB1->PREFIXO+TRB1->NUMTIT+TRB1->PARCELA+TRB1->TIPOTIT)) 
							Reclock("SE1",.F.)
							If Empty(SE1->E1_VEND1)
								SE1->E1_VEND1     := _cVENDEDOR 
							EndIf
							SE1->E1_BASCOM1    := _nBaseTit
							SE1->E1_COMIS1     := _nPercCom  
							SE1->E1_XCOM1      := Round(_nTabPerc,2) 
							SE1->E1_XDEVCOM    := TRB1->DEVCOM 
							SE1->E1_XTPCOM     := _cTPCOM 
							SE1->E1_XBASCOM    := _nBaseTit

							SE1->( Msunlock() )
						EndIf

					ElseIf TRB1->VLBASCOM1 <= 0 
						
						DbSelectArea("SE1")
						DbSetOrder(1)  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
						If SE1->(dbSeek(xFilial("SE1")+TRB1->PREFIXO+TRB1->NUMTIT+TRB1->PARCELA+TRB1->TIPOTIT)) 
							Reclock("SE1",.F.)
							If Empty(SE1->E1_VEND1)
								SE1->E1_VEND1     := _cVENDEDOR 
							EndIf
							SE1->E1_BASCOM1    := _nBaseTit
							SE1->E1_XBASCOM    := _nBaseTit

							SE1->( Msunlock() )
						EndIf

					ElseIf TRB1->XCOMIS1 > 0 .And. TRB1->XA1PGCOM == "2" .And. TRB1->XA3PGCOM == "2"

						DbSelectArea("SE1")
						DbSetOrder(1)  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
						If SE1->(dbSeek(xFilial("SE1")+TRB1->PREFIXO+TRB1->NUMTIT+TRB1->PARCELA+TRB1->TIPOTIT)) 
							Reclock("SE1",.F.)
							If Empty(SE1->E1_VEND1)
								SE1->E1_VEND1     := _cVENDEDOR 
							EndIf
							SE1->E1_COMIS1     := _nPercCom  
							SE1->E1_XCOM1      := Round(_nTabPerc,2) 
							SE1->E1_XDEVCOM    := TRB1->DEVCOM 
							SE1->E1_XTPCOM     := _cTPCOM 
							SE1->E1_XBASCOM    := _nBaseTit

							SE1->( Msunlock() )
						EndIf

					ElseIf TRB1->XA1PGCOM == "2" .And. TRB1->XA3PGCOM == "2" .And. TRB1->XCLT == "2" .And. TRB1->XCOMIS1 <= 0

						DbSelectArea("SE1")
						DbSetOrder(1)  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
						If SE1->(dbSeek(xFilial("SE1")+TRB1->PREFIXO+TRB1->NUMTIT+TRB1->PARCELA+TRB1->TIPOTIT)) 
							Reclock("SE1",.F.)
							If Empty(SE1->E1_VEND1)
								SE1->E1_VEND1     := _cVENDEDOR 
							EndIf
							SE1->E1_COMIS1     := _nPercCom  
							SE1->E1_XCOM1      := Round(_nTabPerc,2) 
							SE1->E1_XDEVCOM    := TRB1->DEVCOM 
							SE1->E1_XTPCOM     := _cTPCOM 
							SE1->E1_XBASCOM    := _nBaseTit

							SE1->( Msunlock() )
						EndIf

					EndIf
					
				EndIf

				If TRB1->TIPODOC $ ("VL/BA/CP/V2/DC")

					// Calculo da base Sobre o Valor Pago
					
					If TRB1->VLPAGO < TRB1->VLTITULO

						If TRB1->XCOMIS1 > 0 .And. TRB1->XA1PGCOM == "2" .And. TRB1->XA3PGCOM == "2" .And. TRB1->XCLT <> "2"
							_nTabPerc   := TRB1->XCOMIS1 // Percentual tabela de comissão
							_nPercCom   := TRB1->XCOMIS1 // Percentual do Cliente  
						
						ElseIf TRB1->XA1PGCOM == "2" .And. TRB1->XA3PGCOM == "2" .And. TRB1->XCLT == "2" .And. TRB1->XCOMIS1 <= 0
							_nTabPerc   := TRB1->A3COMIS  // Percentual tabela de comissão
							_nPercCom   := TRB1->A3COMIS // Percentual do Vendedor
						Else 
							If TRB1->VLCOM1 == _nPercCom 
								_nPercCom  := ABS(Round((_nComPerc/_nVLTOTAL)*100,2)) 
							Else 
								_nPercCom  := ABS(Round(TRB1->VLCOM1,2)) 
							EndIf
							If TRB1->VLCOM1 == ABS(NoRound((_nPercTab/_nVLTOTAL)*100,2)) 
								_nTabPerc   := ABS(NoRound((_nPercTab/_nVLTOTAL)*100,2)) // Percentual tabela de comissão
							Else 
								_nTabPerc   := ABS(Round((_nPercTab/_nVLTOTAL)*100,2)) // Percentual tabela de comissão
							EndIf
						Endif

						_nCMTOTAL  := ABS((_nVLTOTAL - _nVALACRS))
						_nCalcBase := ABS((_nCMTOTAL / _nVLBRUTO))
						_nPartcip  := ((TRB1->VLPAGO-TRB1->JUROS) / TRB1->VLTITULO)  // Apoio no calculo pelo Eristeu 23/03/2022
						_nBase     := Round((_nPartcip * _nBaseTit),2)  // Apoio no calculo pelo Eristeu 23/03/2022
						_nVlPgCom  := ABS(Round((_nBase * _nPercCom ) / 100,2))
						_nPgVlTab  := ABS(Round((_nBase * _nTabPerc ) / 100,2))

					Else 

						If TRB1->XCOMIS1 > 0 .And. TRB1->XA1PGCOM == "2" .And. TRB1->XA3PGCOM == "2" .And. TRB1->XCLT <> "2"
							_nTabPerc   := TRB1->XCOMIS1 // Percentual tabela de comissão
							_nPercCom   := TRB1->XCOMIS1 // Percentual do Cliente  
						
						ElseIf TRB1->XA1PGCOM == "2" .And. TRB1->XA3PGCOM == "2" .And. TRB1->XCLT == "2" .And. TRB1->XCOMIS1 <= 0
							_nTabPerc   := TRB1->A3COMIS  // Percentual tabela de comissão
							_nPercCom   := TRB1->A3COMIS // Percentual do Vendedor
						Else 

							_nTabPerc  := ABS(Round((_nPercTab/_nVLTOTAL)*100,2))
							_nPercCom  := ABS(Round((_nComPerc/_nVLTOTAL)*100,2)) 

							If TRB1->VLCOM1 == _nPercCom 
								_nPercCom  := ABS(Round((_nComPerc/_nVLTOTAL)*100,2)) 
							Else 
								_nPercCom  := ABS(Round(TRB1->VLCOM1,2)) 
							EndIf

							If TRB1->VLCOM1 == ABS(NoRound((_nPercTab/_nVLTOTAL)*100,2)) 
								_nTabPerc   := ABS(NoRound((_nPercTab/_nVLTOTAL)*100,2)) // Percentual tabela de comissão
							Else 
								_nTabPerc   := ABS(Round((_nPercTab/_nVLTOTAL)*100,2)) // Percentual tabela de comissão
							EndIf
						EndIf

						_nBase     := _nBaseTit
						_nVlPgCom  := ABS(Round((_nBase * _nPercCom ) / 100,2))
						_nPgVlTab  := ABS(Round((_nBase *  _nTabPerc) / 100,2))
					EndIf

				ElseIf TRB1->TIPODOC $ ("ES/E2") 
					
					If TRB1->XCOMIS1 > 0 .And. TRB1->XA1PGCOM == "2" .And. TRB1->XA3PGCOM == "2" .And. TRB1->XCLT <> "2"
						_nTabPerc   := TRB1->XCOMIS1 // Percentual tabela de comissão
						_nPercCom   := TRB1->XCOMIS1 // Percentual do Cliente  
						
					ElseIf TRB1->XA1PGCOM == "2" .And. TRB1->XA3PGCOM == "2" .And. TRB1->XCLT == "2" .And. TRB1->XCOMIS1 <= 0
						_nTabPerc   := TRB1->A3COMIS // Percentual tabela de comissão
						_nPercCom   := TRB1->A3COMIS // Percentual do Vendedor
					Else 
						If TRB1->VLCOM1 == _nPercCom 
							_nPercCom  := ABS(Round((_nComPerc/_nVLTOTAL)*100,2)) 
						Else 
							_nPercCom  := ABS(Round(TRB1->VLCOM1,2)) 
						EndIf

						If TRB1->VLCOM1 == ABS(NoRound((_nPercTab/_nVLTOTAL)*100,2)) 
							_nTabPerc   := ABS(NoRound((_nPercTab/_nVLTOTAL)*100,2)) // Percentual tabela de comissão
						Else 
							_nTabPerc   := ABS(Round((_nPercTab/_nVLTOTAL)*100,2)) // Percentual tabela de comissão
						EndIf
					
					EndIf

					_nCMTOTAL   := ABS((_nVLTOTAL - _nVALACRS))
					_nBaseTit   := If (_nCount > 0,Round((_nCMTOTAL / _nCount),2),Round((_nCMTOTAL),2))

					If ABS(TRB1->VLPAGO) < ABS(TRB1->VLTITULO)
						If TRB1->XCOMIS1 > 0 .And. TRB1->XA1PGCOM == "2" .And. TRB1->XA3PGCOM == "2" .And. TRB1->XCLT <> "2"
							_nTabPerc   := TRB1->XCOMIS1 // Percentual tabela de comissão
							_nPercCom   := TRB1->XCOMIS1 // Percentual do Cliente  
							
						ElseIf TRB1->XA1PGCOM == "2" .And. TRB1->XA3PGCOM == "2" .And. TRB1->XCLT == "2" .And. TRB1->XCOMIS1 <= 0
							_nTabPerc   := TRB1->A3COMIS // Percentual tabela de comissão
							_nPercCom   := TRB1->A3COMIS // Percentual do Vendedor

						Else 
							If TRB1->VLCOM1 == _nPercCom 
								_nPercCom  := ABS(Round((_nComPerc/_nVLTOTAL)*100,2)) 
							Else 
								_nPercCom  := ABS(Round(TRB1->VLCOM1,2)) 
							EndIf

							If TRB1->VLCOM1 == ABS(NoRound((_nPercTab/_nVLTOTAL)*100,2)) 
								_nTabPerc   := ABS(NoRound((_nPercTab/_nVLTOTAL)*100,2)) // Percentual tabela de comissão
							Else 
								_nTabPerc   := ABS(Round((_nPercTab/_nVLTOTAL)*100,2)) // Percentual tabela de comissão
							EndIf
						EndIf
						
						_nCMTOTAL  := (_nVLTOTAL - _nVALACRS)
						_nCalcBase := (_nCMTOTAL / _nVLBRUTO)
						_nPartcip  := ((TRB1->VLPAGO-TRB1->JUROS) / TRB1->VLTITULO)
						_nBase     := Round((_nPartcip * _nBaseTit),2)
						_nVlPgCom  := Round((_nBase * _nPercCom ) / 100,2)
						_nPgVlTab  := Round((_nBase * _nTabPerc ) / 100,2)
					Else 

						If TRB1->XCOMIS1 > 0 .And. TRB1->XA1PGCOM == "2" .And. TRB1->XA3PGCOM == "2" .And. TRB1->XCLT <> "2"
							_nTabPerc   := TRB1->XCOMIS1 // Percentual tabela de comissão
							_nPercCom   := TRB1->XCOMIS1 // Percentual do Cliente  
							
						ElseIf TRB1->XA1PGCOM == "2" .And. TRB1->XA3PGCOM == "2" .And. TRB1->XCLT == "2" .And. TRB1->XCOMIS1 <= 0
							_nTabPerc   := TRB1->A3COMIS // Percentual tabela de comissão
							_nPercCom   := TRB1->A3COMIS // Percentual do Vendedor
						Else 
						
							If TRB1->VLCOM1 == _nPercCom 
								_nPercCom  := ABS(Round((_nComPerc/_nVLTOTAL)*100,2)) 
							Else 
								_nPercCom  := ABS(Round(TRB1->VLCOM1,2)) 
							EndIf
							If TRB1->VLCOM1 == ABS(NoRound((_nPercTab/_nVLTOTAL)*100,2)) 
								_nTabPerc   := ABS(NoRound((_nPercTab/_nVLTOTAL)*100,2)) // Percentual tabela de comissão
							Else 
								_nTabPerc   := ABS(Round((_nPercTab/_nVLTOTAL)*100,2)) // Percentual tabela de comissão
							EndIf
						
						EndIf

						_nBase     := _nBaseTit
						_nVlPgCom  := Round((_nBase * _nPercCom ) / 100,2)
						_nPgVlTab  := Round((_nBase * _nTabPerc ) / 100,2)
					EndIf
				Endif 
					
				aAdd(_aComis,{_cVENDEDOR,;   //01
							_cDOC,;          //02
							TRB1->DTVLPAGO,; //03 
							_cSERIE,;        //04 
							_cCODCLI,;       //05
							_cLOJA,;         //06
							If(TRB1->TIPODOC $ "ES/E2",(_nBase * (-1)),_nBase),;       //07
							If(TRB1->TIPODOC $ "ES/E2",(_nPercCom * (-1)),_nPercCom),; //08
							If(TRB1->TIPODOC $ "ES/E2",(_nVlPgCom * (-1)),_nVlPgCom),; //09
							TRB1->PREFIXO,;  //10 
							TRB1->PARCELA,;  //11
							TRB1->TIPOTIT,;  //12
							_cPedido,;       //13
							TRB1->DTVENCREA,;//14 
							TRB1->TIPODOC,;  //15
							_cNOMECLI,;      //16
							_cSeq,;          //17
							_nConta,;        //18 
							TRB1->NOMEVEND,; //19
							TRB1->HISTORICO,;//20 
							If(TRB1->TIPODOC $ "ES/E2",(_nTabPerc* (-1)),_nTabPerc),; //21
							If(TRB1->TIPODOC $ "ES/E2",(_nBase * (-1)),_nBase),;      //22
							If(TRB1->TIPODOC $ "ES/E2",(_nPgVlTab * (-1)),_nPgVlTab),;//23 
							_cPgCliente,;    //24
							_cRepreClt,;     //25
							_cPgRepre,;      //26
							_cReprePorc,;    //27 
							TRB1->DEVCOM,;   //28
							If(Empty(_cTPCOM),"04",_cTPCOM)}) //29

				_nTabPerc   := 0
				_nPercCom   := 0
				_nCMTOTAL   := 0
				_nCalcBase  := 0
				_nBase      := 0
				_nVlPgCom   := 0
				_nPgVlTab   := 0
				_nBaseCalc  := 0
				_nCount     := 0
			EndIf
		
		EndIf

		TRB1->(DbSkip())

		IncProc("Gerando arquivo...")	

		If TRB1->(EOF()) .Or. TRB1->DOC <> _cDOC 

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

			_nVLBRUTO   := 0 
			_nVLICM	    := 0
			_nVLRET     := 0
			_nVLIPI     := 0
			_nVLDESC    := 0
			_nVLFRETE   := 0
			_nVLOUTROS  := 0
			_nVLTOTAL   := 0
			_nVLCOMIS1  := 0
			_nVLCOMTAB  := 0
			_nVALACRS   := 0
			
			_nTotVlTit  := 0
			_nCalcBase  := 0
			_nBase      := 0
			_nVlPgCom   := 0
			_nBaseCalc  := 0
			_nPercTab   := 0
			_nTabPerc   := 0
			_nPgVlTab   := 0
			_cReprePorc := 0
			_nCMTOTAL   := 0
			_nConta     := 0 
			_nPercCom   := 0 
			_nComPerc   := 0
			_nComNeg    := 0
			_nCount     := 0 
			_nBaseTit   := 0
			_nPartcip   := 0
			_nCalcVl01  := 0
			_nCalcVl02  := 0
			_nCalcVl03  := 0
			_nCalcVl04  := 0
			_nCalcVl05  := 0
	
		EndIf 

	EndDo

	For _nCom:= 1 to len(_aComis)
		
		If _aComis[_nCom][24] == "2"
			
			If _lPassa 
				
				DbSelectArea("SE1")
				DbSetOrder(1)  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
				If SE1->(dbSeek(xFilial("SE1")+_aComis[_nCom][10]+_aComis[_nCom][02]+_aComis[_nCom][11]+_aComis[_nCom][12])) 

					DbSelectArea("SE3")
					Reclock("SE3",.T.)
								
					SE3->E3_FILIAL    := xFilial("SE1") 
					SE3->E3_VEND      := _aComis[_nCom][01]
					SE3->E3_NUM       := _aComis[_nCom][02]
					SE3->E3_EMISSAO   := StoD(_aComis[_nCom][03])
					SE3->E3_SERIE     := _aComis[_nCom][04] 
					SE3->E3_CODCLI    := _aComis[_nCom][05]
					SE3->E3_LOJA      := _aComis[_nCom][06]
					SE3->E3_BASE      := If(_aComis[_nCom][28] == "S",ABS(_aComis[_nCom][07]) * (-1),_aComis[_nCom][07])  
					SE3->E3_PORC      := If(_aComis[_nCom][28] == "S",ABS(_aComis[_nCom][08]) * (-1),_aComis[_nCom][08]) 
					SE3->E3_COMIS     := If(_aComis[_nCom][28] == "S",ABS(_aComis[_nCom][09]) * (-1),_aComis[_nCom][09])
					SE3->E3_PREFIXO   := _aComis[_nCom][10]
					SE3->E3_PARCELA   := _aComis[_nCom][11]
					SE3->E3_TIPO      := _aComis[_nCom][12]
					SE3->E3_BAIEMI    := 'B'
					SE3->E3_PEDIDO    := _aComis[_nCom][13]
					SE3->E3_SEQ       := AllTrim(_aComis[_nCom][17])
					SE3->E3_ORIGEM    := If(_aComis[_nCom][12]=="VL","R","B")
					SE3->E3_VENCTO    := StoD(_aComis[_nCom][14])
					SE3->E3_MOEDA     := "01"
					SE3->E3_SDOC      := _aComis[_nCom][04]
					SE3->E3_XCOM1     := If(_aComis[_nCom][28] == "S",ABS(_aComis[_nCom][21]) * (-1),_aComis[_nCom][21])  
					SE3->E3_XPGCOM    := If(_aComis[_nCom][15] $ "ES/E2" .Or. _aComis[_nCom][28] == "S",(Round((_aComis[_nCom][07] * _aComis[_nCom][21]) / 100,2)*(-1)),Round((_aComis[_nCom][07] * _aComis[_nCom][21]) / 100,2))  
					SE3->E3_XTPCOM    := _aComis[_nCom][29] 

					SE3->( Msunlock() )

					lAbre := .T.
					
					If _aComis[_nCom][29] == "01"
						_cTpCom := "Comissão Por Cliente"
					ElseIf _aComis[_nCom][29] == "02"
						_cTpCom := "Comissão Por Produto"
					ElseIf _aComis[_nCom][29] == "03"
						_cTpCom := "Comissão Por Vendedor"
					ElseIf _aComis[_nCom][29] == "04"
						_cTpCom := "Comissão Zerada"
					Endif

					oExcel:AddRow(cPlan, cTit,{AllTrim("Atualizado"),; //01
											_aComis[_nCom][01],;    //02
											_aComis[_nCom][19],;    //03										
											_aComis[_nCom][05],;	//04										
											_aComis[_nCom][06],;    //05
											AllTrim(Posicione("SA1",1,xFilial("SA1")+_aComis[_nCom][05]+_aComis[_nCom][06],"A1_NOME")),; //06
											_aComis[_nCom][13],;    //07
											Posicione("SC5",1,xFilial("SC5")+_aComis[_nCom][13],"C5_EMISSAO"),; //08
											_aComis[_nCom][02],;    //09	 
											_aComis[_nCom][10],;    //10     
											_aComis[_nCom][11],; 	//11	 
											If(_aComis[_nCom][28] == "S",ABS(_aComis[_nCom][07]) * (-1),_aComis[_nCom][07]),; //12	 
											If(_aComis[_nCom][28] == "S",ABS(_aComis[_nCom][08]) * (-1),_aComis[_nCom][08]),; //13	 
											If(_aComis[_nCom][28] == "S",ABS(_aComis[_nCom][09]) * (-1),_aComis[_nCom][09]),; //14     
											_aComis[_nCom][15],;    //15
											Substr(_aComis[_nCom][03],7,2)+"/"+Substr(_aComis[_nCom][03],5,2)+"/"+Substr(_aComis[_nCom][03],1,4),; //16
											_aComis[_nCom][20],;    //17
											If(_aComis[_nCom][28] == "S",ABS(_aComis[_nCom][21]) * (-1) ,_aComis[_nCom][21]),;    //18
											If(_aComis[_nCom][15] $ "ES/E2" .Or. _aComis[_nCom][28] == "S",(Round((_aComis[_nCom][07] * _aComis[_nCom][21]) / 100,2)*(-1)),Round((_aComis[_nCom][07] * _aComis[_nCom][21]) / 100,2)),; //19
											StrZero(_aComis[_nCom][18],3),; // 20
											_cTpCom})             //21	     
				EndIf
			EndIf
		EndIf
	Next _nCom
EndIf

If lAbre

	oExcel:Activate()
	oExcel:GetXMLFile(cArqDst)
	OPENXML(cArqDst)
	oExcel:DeActivate()

Else

	MsgInfo("Não existe dados para serem impressos.", "SEM DADOS")

EndIf

If Select("SE1") > 0
	SE1->(DbCloseArea())
EndIf
If Select("SE3") > 0
	SE3->(DbCloseArea())
EndIf
If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf
If Select("TRB2") > 0
	TRB2->(DbCloseArea())
EndIf
If Select("TRB2") > 0
	TRB3->(DbCloseArea())
EndIf
If Select("TRB4") > 0
	TRB4->(DbCloseArea())
EndIf
If Select("TRB5") > 0
	TRB5->(DbCloseArea())
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

Aadd(_aPerg,{"Data Emissao De ....?","mv_chd","D",08,"G","mv_par13","","","","","","","","",0})
Aadd(_aPerg,{"Data Emissao Até ...?","mv_che","D",08,"G","mv_par14","","","","","","","","",0})


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

//Bibliotecas
#Include "Protheus.ch"
 
/*/{Protheus.doc} MotBaixa
Retorna os motivos de baixas do financeiro formatado 
@type function
@author Geronimo Benedito Alves
@since 30/06/2023
@version 1.0
/*/

User Function MotBaixa()
    Local aArea     := GetArea()
    Local aMotBx    := {}
    Local aBaixaAtu := {}
    Local cRet		:= ""
    Local _nI		:= 0
	
    aMotBx := ReadMotBx()			//Obtendo os motivos de baixa

	If Len(aMotBx) > 0
		For _nI := 1 to Len(aMotBx) 
			aBaixaAtu := StrTokArr(aMotBx[_nI], '³')		// Quebrando array, o primeiro elemento do array do Motivo de Baixas
			// Criar um for .... Next aqui	    
			//  Abaixo as posições do motivo de baixas
			//  [1] -> Sigla
			//  [2] -> Descrição
			//  [3] -> Movimentação Bancária
			//  [4] -> Comissão
			//  [5] -> Carteira
			//  [6] -> Cheque 
			If Alltrim(aBaixaAtu[4]) = "S"
				cRet += Alltrim(aBaixaAtu[1]) + "/"
			Endif
		Next
	Endif

	If Empty(cRet)
		cRet := "('LIQ','CAN','PRD', 'DAC', 'BSC', 'CEC', 'CMP' )"		// Se estiver vazio, joga um conteúdo padrão pré determinado em 30/06/2023
	Else 
		cRet := subs( cRet,1 , len(cRet)-1 )							// Retiro a ultimo "/" da variavel, pois ela esta "sobrando"
		cRet := FormatIn( cRet , "/")									// Formato a variavel para o formato in do SQL 
	Endif
    RestArea(aArea)
Return cRet


