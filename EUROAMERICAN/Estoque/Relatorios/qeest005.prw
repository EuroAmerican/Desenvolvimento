#include 'protheus.ch'
#include 'parmtype.ch'
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"

#define ENTER chr(13) + chr(10)

/*/{Protheus.doc} QEEST005
@TYPE Rotina para extrair relatorio para comparação com o portal 
@author Fabio Carneiro dos Santos 
@since 21/02/2021
@version 1.0
/*/
User Function QEEST005()

	Local aSays    := {}
	Local aButtons := {}
	Local nOpca    := 0
	Local cTitoDlg := "Listagem de valores do portal de forma analitica"
	Private _cPerg := "QESD201"

	// Prepara e executa a pergunta do relatorio

	aAdd(aSays, "Este relatorio lista os valores para conferencia do portal!")
	aAdd(aSays, "Se for por database ira carregar os valores identico ao portal.")
	aAdd(aSays, "Se For por range de data, considerar DD/MM/AAAA dentro do mes corrente.")
	aAdd(aSays, "Somente lista Notas que a TES esta configurada para gerar financeiro.")
	aAdd(aSays, "Támbem é considerado as Notas de Devolução para esta listagem.")
	aAdd(aSays, "Não consideremos os pedidos em carteira, somente Nota s fiscais.")
		
	
	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	If nOpca == 1
	
		oAjustaSx1()

		If !Pergunte(_cPerg,.T.)
			Return
		Else 
			Processa({|| QEVDA01ok("Gerando relatório...")})
		Endif
		
	EndIf
	Return

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEVDA01ok | Autor: | QUALY         | Data: | 04/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEEST01ok                                    |
+------------+-----------------------------------------------------------+
*/

Static Function QEVDA01ok()

	Local cArqDst      := "C:\TOTVS\QEVDA001_EMP_" + SM0->M0_CODIGO + "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel       := FWMsExcelEX():New()
	Local cQuery       := ""

	Local cTipoNota    := ""
	Local nCalcContrib := 0
	Local cNomPla      := "Empresa_1" + Rtrim(SM0->M0_NOME)

	Local dDataA       := ""
	Local dDataB       := ""
	
	Local cTitPla      := " "
	
	Local cNomWrk      := "Empresa_1" + Rtrim(SM0->M0_NOME)

	Local lAbre        := .F.
	
	Private TRB1       := GetNextAlias()
	
	If MV_PAR15 == 1
		dDataA        := Substr(DTOS(dDataBase),5,2)+"/"+Substr(DTOS(dDataBase),1,4)
		cTitPla      := "Valores do portal para conferencia referente ao Mes/Ano de "+dDataA+"  "
	ElseIf MV_PAR15 == 2
		dDataB        := Substr(Dtos(MV_PAR13),5,2)+"/"+Substr(Dtos(MV_PAR14),1,4)
		cTitPla      := "Valores do portal para conferencia referente ao Mes/Ano de "+dDataB+"  "
	EndIf 

	MakeDir("C:\TOTVS")

	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf
	
	cQuery := "SELECT '" + Rtrim(SM0->M0_NOME) + "' EMP, D2_FILIAL,'Faturado' AS FATURADO ,D2_COD,B1_DESC,B1_TIPO ,D2_TES, F4_TEXTO,D2_LOCAL,D2_EMISSAO, D2_DOC,D2_SERIE,D2_ITEM,D2_TIPO, " +ENTER  
	cQuery += " D2_CLIENTE, D2_LOJA,A1_NOME,D2_CF,F2_VEND1,A3_NOME,D2_VALBRUT, D2_VALIPI, D2_VALICM, D2_VALIMP5, D2_VALIMP6,D2_DESPESA, D2_VALFRE, D2_DESCON, D2_SEGURO,  " + ENTER
	cQuery += " D2_ICMSRET, D2_CUSTO1, D2_QUANT,B1_CUSTD, " + ENTER
	cQuery += " ISNULL(SUM(D2_VALBRUT - D2_VALIPI - D2_VALICM - D2_VALIMP5 - D2_VALIMP6 - D2_DESPESA - D2_VALFRE - D2_DESCON - D2_SEGURO - D2_ICMSRET), 0) AS VALORLIQ, " + ENTER
	cQuery += " ISNULL(SUM(D2_CUSTO1), 0) AS CUSTOMEDIO, " + ENTER
	cQuery += " ISNULL(SUM(D2_QUANT * B1_CUSTD),0) AS CUSTOSTANDARD, " + ENTER
	cQuery += " ISNULL(SUM(D2_VALBRUT), 0) AS VALBRUTO," + ENTER
	cQuery += " ISNULL(SUM(D2_VALBRUT - D2_VALIPI - D2_ICMSRET), 0) AS BASECOM " + ENTER
	cQuery += " FROM " + RetSqlName("SD2") + " SD2 WITH (NOLOCK) " + ENTER
	cQuery += "INNER JOIN " + RetSqlName("SF2") + " AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL " + ENTER
	cQuery += " AND F2_DOC = D2_DOC " + ENTER
  	cQuery += " AND F2_SERIE = D2_SERIE " + ENTER
  	cQuery += " AND F2_CLIENTE = D2_CLIENTE " + ENTER
  	cQuery += " AND F2_LOJA = D2_LOJA " + ENTER
  	cQuery += " AND F2_TIPO = D2_TIPO " + ENTER
  	cQuery += " AND F2_EMISSAO = D2_EMISSAO " + ENTER
  	cQuery += " AND SF2.D_E_L_E_T_ = ' ' " + ENTER
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(D2_FILIAL, 2) " + ENTER
  	cQuery += " AND F4_CODIGO = D2_TES " + ENTER
  	cQuery += " AND F4_DUPLIC = 'S' " + ENTER
	cQuery += " AND NOT SUBSTRING(F4_CF,2,3) = '124' " + ENTER  
  	cQuery += " AND SF4.D_E_L_E_T_ = ' ' " + ENTER
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_COD = D2_COD " + ENTER
  	cQuery += " AND SB1.D_E_L_E_T_ = ' ' " + ENTER
	cQuery += "INNER JOIN " + RetSqlName("SA1") + " AS SA1 WITH (NOLOCK) ON A1_FILIAL = D2_FILIAL " + ENTER
  	cQuery += " AND A1_COD = D2_CLIENTE " + ENTER
  	cQuery += " AND A1_LOJA = D2_LOJA " + ENTER
  	cQuery += " AND SA1.D_E_L_E_T_ = ' ' " + ENTER
	cQuery += "INNER JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_COD = F2_VEND1 " + ENTER
    cQuery += "AND SA3.D_E_L_E_T_ = ' ' " + ENTER
	cQuery += " WHERE D2_FILIAL <> '****' " + ENTER
	cQuery += " AND D2_COD   BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " +ENTER
	cQuery += " AND B1_TIPO  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " +ENTER
	cQuery += " AND D2_DOC   BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' " +ENTER
	cQuery += " AND D2_SERIE BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " +ENTER
	cQuery += " AND A1_COD   BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' " +ENTER
	cQuery += " AND A1_LOJA  BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' " +ENTER
	If MV_PAR16 = 1
		cQuery += "	AND A1_EQ_PRRL = '1' " +ENTER
	ElseIf MV_PAR16 = 2 
		cQuery += "	AND A1_EQ_PRRL <> '1' " +ENTER
	ElseIf MV_PAR16 = 3
		cQuery += "	AND A1_EQ_PRRL IN ('1','2',' ') " +ENTER
	EndIf 

	If MV_PAR15 == 2
		cQuery += " AND D2_EMISSAO  BETWEEN '"+Dtos(MV_PAR13)+"' AND '"+Dtos(MV_PAR14)+"' " +ENTER
	ElseIf MV_PAR15 == 1
		cQuery += " AND LEFT( D2_EMISSAO, 6) = '" + Left( DTOS( dDataBase ), 6) + "' " + ENTER
	EndIf 
	cQuery += " AND D2_TIPO = 'N' " + ENTER
	//cQuery += " AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = D2_FILIAL AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') " + ENTER
	cQuery += " AND SD2.D_E_L_E_T_ = ' ' " + ENTER
	cQuery += " GROUP BY D2_FILIAL, D2_COD,B1_DESC,B1_TIPO ,D2_TES,F4_TEXTO, D2_LOCAL,D2_EMISSAO, D2_DOC,D2_SERIE, D2_ITEM, D2_TIPO,D2_CLIENTE, " + ENTER
	cQuery += " D2_LOJA,A1_NOME,D2_CF,F2_VEND1,A3_NOME,D2_VALBRUT, D2_VALIPI, D2_VALICM, D2_VALIMP5, D2_VALIMP6, " + ENTER
	cQuery += " D2_DESPESA, D2_VALFRE, D2_DESCON, D2_SEGURO,D2_ICMSRET, D2_CUSTO1, D2_QUANT,B1_CUSTD, D2_VALBRUT " + ENTER
	
	cQuery += " UNION ALL " + ENTER
	
	cQuery += "SELECT '" + Rtrim(SM0->M0_NOME) + "' EMP,D1_FILIAL,'Devolução' AS DEVOLUCAO, D1_COD,B1_DESC,B1_TIPO ,D1_TES,F4_TEXTO, D1_LOCAL,D1_DTDIGIT, D1_DOC,D1_SERIE, D1_ITEM, D1_TIPO, " + ENTER //14
	cQuery += " D1_FORNECE, D1_LOJA,A1_NOME,D1_CF,F2_VEND1,A3_NOME,D1_TOTAL,D1_VALIPI,D1_VALICM, D1_VALIMP5,D1_VALIMP6,D1_DESPESA,D1_VALFRE, D1_DESC,D1_SEGURO,D1_ICMSRET, " + ENTER //16
	cQuery += " D1_CUSTO,D1_QUANT,B1_CUSTD, " + ENTER // 03
	cQuery += " ISNULL(SUM((D1_TOTAL-D1_VALDESC-D1_VALIPI+D1_DESPESA+D1_VALFRE+D1_SEGURO-D1_ICMSRET-D1_VALICM-D1_VALIMP5-D1_VALIMP6)) * (-1), 0) AS VALORLIQ,  " + ENTER
	cQuery += " ISNULL(SUM(D1_CUSTO) * (-1), 0) AS CUSTOMEDIO,  " + ENTER
	cQuery += " ISNULL(SUM(D1_QUANT * B1_CUSTD) * (-1),0) AS CUSTOSTANDARD, 0 AS VALBRUTO, " + ENTER
	cQuery += " ISNULL(SUM((D1_TOTAL-D1_VALDESC-D1_VALIPI+D1_DESPESA+D1_VALFRE+D1_SEGURO-D1_ICMSRET-D1_VALICM-D1_VALIMP5-D1_VALIMP6)) * (-1), 0) AS BASECOM  " + ENTER
	cQuery += " FROM " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) " + ENTER
	cQuery += "INNER JOIN " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) ON D2_FILIAL = D1_FILIAL " + ENTER
	cQuery += " AND D2_DOC = D1_NFORI " + ENTER
	cQuery += " AND D2_SERIE = D1_SERIORI " + ENTER
	cQuery += " AND D2_CLIENTE = D1_FORNECE " + ENTER
	cQuery += " AND D2_LOJA = D1_LOJA  " + ENTER
	cQuery += " AND D2_ITEM = D1_ITEMORI " + ENTER
	cQuery += " AND D2_TIPO = 'N'  " + ENTER
	cQuery += " AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WITH (NOLOCK) WHERE A1_FILIAL = D2_FILIAL AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ')  " + ENTER
	cQuery += " AND SD2.D_E_L_E_T_ = ' ' " + ENTER
	cQuery += "INNER JOIN " + RetSqlName("SF2") + " AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL " + ENTER
	cQuery += "AND F2_DOC = D2_DOC  " + ENTER
  	cQuery += "AND F2_SERIE = D2_SERIE " + ENTER
  	cQuery += "AND F2_CLIENTE = D2_CLIENTE " + ENTER
  	cQuery += "AND F2_LOJA = D2_LOJA " + ENTER
  	cQuery += "AND F2_TIPO = D2_TIPO " + ENTER
  	cQuery += "AND F2_EMISSAO = D2_EMISSAO " + ENTER
  	cQuery += "AND SF2.D_E_L_E_T_ = ' ' " + ENTER
	cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(D2_FILIAL, 2) " + ENTER
  	cQuery += "AND F4_CODIGO = D2_TES " + ENTER
  	cQuery += "AND F4_DUPLIC = 'S' " + ENTER
	cQuery += "AND NOT SUBSTRING(F4_CF,2,3) = '124' " + ENTER  
  	cQuery += "AND SF4.D_E_L_E_T_ = ' ' " + ENTER
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '    ' " + ENTER
  	cQuery += "AND B1_COD = D2_COD " + ENTER
  	cQuery += "AND SB1.D_E_L_E_T_ = ' ' " + ENTER
	cQuery += "INNER JOIN " + RetSqlName("SA1") + " AS SA1 WITH (NOLOCK) ON A1_FILIAL = D2_FILIAL " + ENTER
  	cQuery += " AND A1_COD = D2_CLIENTE " + ENTER
  	cQuery += " AND A1_LOJA = D2_LOJA " + ENTER
  	cQuery += " AND SA1.D_E_L_E_T_ = ' ' " + ENTER
	cQuery += "INNER JOIN " + RetSqlName("SA3") + " AS SA3 WITH (NOLOCK) ON A3_COD = F2_VEND1 " + ENTER
    cQuery += "AND SA3.D_E_L_E_T_ = ' ' " + ENTER
	cQuery += "WHERE D1_FILIAL <> '****' " + ENTER
	cQuery += " AND D1_COD   BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " +ENTER
	cQuery += " AND B1_TIPO  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " +ENTER
	cQuery += " AND D1_DOC   BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' " +ENTER
	cQuery += " AND D1_SERIE BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' " +ENTER
	cQuery += " AND A1_COD   BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' " +ENTER
	cQuery += " AND A1_LOJA  BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' " +ENTER
	If MV_PAR15 == 2
		cQuery += " AND D1_DTDIGIT  BETWEEN '"+Dtos(MV_PAR13)+"' AND '"+Dtos(MV_PAR14)+"' " +ENTER
	ElseIf MV_PAR15 == 1
		cQuery += " AND LEFT( D1_DTDIGIT, 6) = '" + Left( DTOS( dDataBase ), 6) + "' " + ENTER
	EndIf 
	cQuery += "AND D1_TIPO = 'D' " + ENTER
	cQuery += "AND SD1.D_E_L_E_T_ = ' ' " + ENTER
	cQuery += "GROUP BY  D1_FILIAL,D1_COD,B1_DESC,B1_TIPO ,D1_TES,F4_TEXTO, D1_LOCAL,D1_DTDIGIT, D1_DOC,D1_SERIE, D1_ITEM, D1_TIPO, " + ENTER
	cQuery += "D1_FORNECE, D1_LOJA,A1_NOME ,D1_CF,F2_VEND1,A3_NOME, " + ENTER
	cQuery += "D1_TOTAL,D1_VALIPI,D1_VALICM, D1_VALIMP5,D1_VALIMP6,D1_DESPESA,D1_VALFRE, D1_DESC,D1_SEGURO,D1_ICMSRET,D1_CUSTO,D1_QUANT,B1_CUSTD " + ENTER
	cQuery += "ORDER BY D2_EMISSAO, D2_DOC, D2_SERIE, D2_ITEM, D2_COD " + ENTER
	
	TcQuery cQuery ALIAS "TRB1" NEW

	
	oExcel:AddworkSheet(cNomWrk)
	oExcel:AddTable(cNomPla, cTitPla)
	oExcel:AddColumn(cNomPla, cTitPla, "Empresa"  , 1, 1, .F.)  //01
	oExcel:AddColumn(cNomPla, cTitPla, "Filial "  , 1, 1, .F.)  //02
	oExcel:AddColumn(cNomPla, cTitPla, "Tipo Nota"   , 1, 1, .F.)  //03
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo Produto", 1, 2, .F.)  //04
	oExcel:AddColumn(cNomPla, cTitPla, "Descrição Produto", 1, 2, .F.)  //05
	oExcel:AddColumn(cNomPla, cTitPla, "Tipo Produto"     , 1, 1, .F.)  //06
	oExcel:AddColumn(cNomPla, cTitPla, "TES"     , 1, 1, .F.)  //07
	oExcel:AddColumn(cNomPla, cTitPla, "Descrição TES"     , 1, 1, .F.)  //08
	oExcel:AddColumn(cNomPla, cTitPla, "Armazem"  , 1, 1, .F.)  //09
	oExcel:AddColumn(cNomPla, cTitPla, "Data Nota Fiscal"  , 1, 1, .F.)  //10
	oExcel:AddColumn(cNomPla, cTitPla, "Nº Nota Fiscal "  , 1, 1, .F.)  //11
	oExcel:AddColumn(cNomPla, cTitPla, "Serie Nota Fiscal"  , 1, 1, .F.)  //12
	oExcel:AddColumn(cNomPla, cTitPla, "Item Nota Fiscal"  , 1, 1, .F.)  //13
	oExcel:AddColumn(cNomPla, cTitPla, "Tipo Nota Fiscal"  , 1, 1, .F.)  //14
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo Cliente"  , 1, 1, .F.)  //15
	oExcel:AddColumn(cNomPla, cTitPla, "Loja"  , 1, 1, .F.)  //16
	oExcel:AddColumn(cNomPla, cTitPla, "Nome Cliente"  , 1, 1, .F.)  //17
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo Fiscal Opereção"  , 1, 1, .F.)  //18
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo Vendedor"  , 1, 1, .F.)  //19
	oExcel:AddColumn(cNomPla, cTitPla, "Nome Vendedor"  , 1, 1, .F.)  //20
	oExcel:AddColumn(cNomPla, cTitPla, "Valor Item"  , 3, 2, .F.)  //21
	oExcel:AddColumn(cNomPla, cTitPla, "Valor IPI"  , 3, 2, .F.)  //22
	oExcel:AddColumn(cNomPla, cTitPla, "Valor ICMS"  , 3, 2, .F.)  //23
	oExcel:AddColumn(cNomPla, cTitPla, "Valor PIS"  , 3, 2, .F.)  //24
	oExcel:AddColumn(cNomPla, cTitPla, "Valor COFINS"  , 3, 2, .F.)  //25
	oExcel:AddColumn(cNomPla, cTitPla, "Valor DESPESA"  , 3, 2, .F.)  //26
	oExcel:AddColumn(cNomPla, cTitPla, "Valor FRETE"  , 3, 2, .F.)  //27
	oExcel:AddColumn(cNomPla, cTitPla, "Valor Desconto"  , 3, 2, .F.)  //28
	oExcel:AddColumn(cNomPla, cTitPla, "Valor Seguro"  , 3, 2, .F.)  //29
	oExcel:AddColumn(cNomPla, cTitPla, "Valor ICMS Solidario"  , 3, 2, .F.)  //30
	oExcel:AddColumn(cNomPla, cTitPla, "Valor Custo Medio"  , 3, 2, .F.)  //31
	oExcel:AddColumn(cNomPla, cTitPla, "Quantidade"  , 3, 2, .F.)  //32
	oExcel:AddColumn(cNomPla, cTitPla, "Custo Standart"  , 3, 2, .F.)  //33
	oExcel:AddColumn(cNomPla, cTitPla, "*Valor Liquido"  , 3, 2, .F.)  //34
	oExcel:AddColumn(cNomPla, cTitPla, "*Valor Custo Medio"  , 3, 2, .F.)  //35
	oExcel:AddColumn(cNomPla, cTitPla, "*Custo Standart"  , 3, 2, .F.)  //36
	oExcel:AddColumn(cNomPla, cTitPla, "*Valor Bruto"  , 3, 2, .F.)  //37
	oExcel:AddColumn(cNomPla, cTitPla, "*Valor Base Comissão"  , 3, 2, .F.)  //38
	oExcel:AddColumn(cNomPla, cTitPla, "*Valor Margem"  , 3, 2, .F.)  //39
	
	
	TRB1->(DbGoTop())
	ProcRegua(TRB1->(LastRec()))
	
	While TRB1->(!Eof())
		lAbre := .T.
		
		dDataEmis := Substr(TRB1->D2_EMISSAO,7,2)+"/"+Substr(TRB1->D2_EMISSAO,5,2)+"/"+Substr(TRB1->D2_EMISSAO,1,4)
		
		If TRB1->D2_TIPO == 'N'

			cTipoNota := 'Normal'
		
		ElseIf TRB1->D2_TIPO == 'D'

			cTipoNota := 'Devolução'

		EndIf 

		nCalcContrib := (TRB1->VALORLIQ - TRB1->CUSTOMEDIO)
				
		oExcel:AddRow(cNomPla, cTitPla, {TRB1->EMP,;
										TRB1->D2_FILIAL,;
										TRB1->FATURADO,;
										TRB1->D2_COD,;
										TRB1->B1_DESC,;
										TRB1->B1_TIPO,;
										TRB1->D2_TES,;
										TRB1->F4_TEXTO,;
										TRB1->D2_LOCAL,;
										dDataEmis,;
										TRB1->D2_DOC,;
										TRB1->D2_SERIE,;
										TRB1->D2_ITEM,;
										cTipoNota,;
										TRB1->D2_CLIENTE,;
										TRB1->D2_LOJA,;
										TRB1->A1_NOME,;
										TRB1->D2_CF,;
										TRB1->F2_VEND1,;
										TRB1->A3_NOME,;
										TRB1->D2_VALBRUT,;
										TRB1->D2_VALIPI,;
										TRB1->D2_VALICM,;
										TRB1->D2_VALIMP5,;
										TRB1->D2_VALIMP6,;
										TRB1->D2_DESPESA,;
										TRB1->D2_VALFRE,;
										TRB1->D2_DESCON,;
										TRB1->D2_SEGURO,;
										TRB1->D2_ICMSRET,;
										TRB1->D2_CUSTO1,;
										TRB1->D2_QUANT,;
										TRB1->B1_CUSTD,;
										TRB1->VALORLIQ,;
										TRB1->CUSTOMEDIO,;
										TRB1->CUSTOSTANDARD,;
										TRB1->VALBRUTO,;
										TRB1->BASECOM,;
										nCalcContrib}) 
		TRB1->(DbSkip())
		
		nCalcContrib := 0
		
		IncProc("Gerando arquivo...")
	
	EndDo

	TRB1->(DbCloseArea())
	
	If lAbre
		oExcel:Activate()
		oExcel:GetXMLFile(cArqDst)
		OPENXML(cArqDst)
		oExcel:DeActivate()
	Else
		MsgInfo("Não existe dados para serem impressos.", "SEM DADOS")
	EndIf
Return

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | OPENXML   | Autor: | QUALY         | Data: | 04/02/21     |
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
| Programa:  | oAjustaSx1 | Autor: | QUALY         | Data: | 04/02/21     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - Perguntas                                     |
+------------+------------------------------------------------------------+
*/
Static Function oAjustaSx1()

Local _aPerg  := {}  // aRRAY 
Local _ni

Aadd(_aPerg,{"Produtos De  ....?"   ,"mv_ch1","C",20,"G","mv_par01","","","","","","SB1","","",0})
Aadd(_aPerg,{"Produtos Até ....?"   ,"mv_ch2","C",20,"G","mv_par02","","","","","","SB1","","",0})

Aadd(_aPerg,{"Tipo Produto De..?"   ,"mv_ch3","C",02,"G","mv_par03","","","","","","02" ,"","",0})
Aadd(_aPerg,{"Tipo Produto Até.?"   ,"mv_ch4","C",02,"G","mv_par04","","","","","","02" ,"","",0})

Aadd(_aPerg,{"Nota Fiscal De...?"   ,"mv_ch5","C",09,"G","mv_par05","","","","","","SF2" ,"","",0})
Aadd(_aPerg,{"Nota Fiscal Até..?"   ,"mv_ch6","C",09,"G","mv_par06","","","","","","SF2" ,"","",0})

Aadd(_aPerg,{"Serie NF De......?"   ,"mv_ch7","C",03,"G","mv_par07","","","","","","" ,"","",0})
Aadd(_aPerg,{"Serie NF Até.....?"   ,"mv_ch8","C",03,"G","mv_par08","","","","","","" ,"","",0})

Aadd(_aPerg,{"Cod.Cliente De...?"   ,"mv_ch9","C",06,"G","mv_par09","","","","","","SA1" ,"","",0})
Aadd(_aPerg,{"Cod.Cliente Até..?"   ,"mv_chA","C",06,"G","mv_par10","","","","","","SA1" ,"","",0})

Aadd(_aPerg,{"Loja Cliente De..?"   ,"mv_chB","C",02,"G","mv_par11","","","","","","" ,"","",0})
Aadd(_aPerg,{"Loja Cliente Até.?"   ,"mv_chC","C",02,"G","mv_par12","","","","","","" ,"","",0})

Aadd(_aPerg,{"Data NF De......?"   ,"mv_chD","D",08,"G","mv_par13","","","","","","","","",0})
Aadd(_aPerg,{"Data NF Até ....?"   ,"mv_chE","D",08,"G","mv_par14","","","","","","","","",0})

Aadd(_aPerg,{"Lista Database..?"   ,"mv_chF","C",01,"C","mv_par15","Sim","Não","","","",""   ,"","",0})

Aadd(_aPerg,{"Cons. Coligadas.?"   ,"mv_chg","C",01,"C","mv_par16","Sim","Não","Todos","","",""   ,"","",0})

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

