#include 'protheus.ch'
#include 'parmtype.ch'
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"

#define ENTER chr(13) + chr(10)

/*/{Protheus.doc} QEEST003
//Relatorio referente lead time e calculo de corbertura de estoque 
@author Fabio Carneiro dos Santos 
@since 13/02/2021
@version 1.0
/*/
User Function QEEST003()

	Local aSays    := {}
	Local aButtons := {}
	Local nOpca    := 0
	Local cTitoDlg := "Listagem de Lead Time - Cobertura de Estoque "
	Private _cPerg := "QERB2B1"

	// Prepara e executa a pergunta do relatorio

	aAdd(aSays, "Este relatorio lista Lead time de ME/MP Nacional: 7 dias e Importadas: 45 dias ")
	aAdd(aSays, "Ira fazer o calculo baseado no periodo informado em dias")
	aAdd(aSays, "Se houver saldo em estoque e houver o consumo no perioro informado")
	aAdd(aSays, "Ira calcular a coberura baseado na regra abaixo:")
	aAdd(aSays, "01 - Calculo do Dia = (Consumo / Dias) ")
	aAdd(aSays, "02 - Calculo Corbertura = (Saldo Atual / Calculo do Dia) ")
	aAdd(aSays, "03 - Calculo Exedente = (Calculo Corbertura - Lead Time de 7 ou 45 dias) ")

	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	If nOpca == 1
	
		oAjustaSx1()

		If !Pergunte(_cPerg,.T.)
			Return
		Else 
			Processa({|| QEEST03ok("Gerando relatório...")})
		Endif
		
	EndIf

Return

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEEST03ok | Autor: | QUALY         | Data: | 13/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEEST03ok                                    |
+------------+-----------------------------------------------------------+
*/

Static Function QEEST03ok()

	Local cArqDst     := "C:\TOTVS\QEEST003_EMP_" + SM0->M0_CODIGO + "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel      := FWMsExcelEX():New()
	Local cQueryA     := ""
	Local cQueryB     := ""
	Local cQueryC     := ""
	Local cQueryD     := ""
	Local cQueryE     := ""
	Local cQueryF     := ""
	
	Local nDias       := 0
	Local nConsumo    := 0
	Local nCalDia     := 0
	Local nNacional   := 0
	Local nImport     := 0
	Local nPedCmp     := 0
	Local nCustUnit   := 0
	Local nTotCusto   := 0
	Local nCalcDia    := 0
	Local nCalcDay    := 0
	Local nCalcCorb   := 0
	Local aPlanilha   := {}
	Local nPlan       := 0
	Local nSevenDay   := 0
		
	Local dDataDe     := Substr(Dtos(MV_PAR09),7,2)+"/"+Substr(Dtos(MV_PAR09),5,2)+"/"+Substr(Dtos(MV_PAR09),1,4)
	Local dDataAte    := Substr(Dtos(MV_PAR10),7,2)+"/"+Substr(Dtos(MV_PAR10),5,2)+"/"+Substr(Dtos(MV_PAR10),1,4)
	Local cDiaTit     := cValToChar(DateDiffDay(MV_PAR09, MV_PAR10))
	Local cNomPla     := "Empresa_1" + Rtrim(SM0->M0_NOME)
	Local cTitPla     := "Lead Time Dos Saldos dos Produtos No Periodo de "+dDataDe+" Até "+dDataAte+" Referente a "+cDiaTit+" Dia(s) "
	Local cNomWrk     := "Empresa_1" + Rtrim(SM0->M0_NOME)
	Local lAbre       := .F.

	Private TRB1      := GetNextAlias()
	Private TRB2      := GetNextAlias()
	Private TRB3      := GetNextAlias()
	Private TRB4      := GetNextAlias()
	Private TRB5      := GetNextAlias()
	Private TRB6      := GetNextAlias()
	Private TRB7      := GetNextAlias()

	MakeDir("C:\TOTVS")

	/*
		QUERY - Listagem de saldo em estoque e custo medio  
	*/
	
	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf
	
	If MV_PAR12 == 1 

		cQueryA := "SELECT '" + Rtrim(SM0->M0_NOME) + "' AS EMP, B2_FILIAL, B2_COD,B1_DESC, B1_UM,B1_TIPO,B1_UCOM,ISNULL(SUM(B2_QATU),0) AS B2_QATU  " +ENTER  
		cQueryA += " FROM " + RetSqlName("SB2") + " SB2 " + ENTER
		cQueryA += " INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_COD = B2_COD " + ENTER
		cQueryA += " WHERE B2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " +ENTER
		cQueryA += " AND B1_TIPO BETWEEN 'ME' AND 'MP' " +ENTER
		cQueryA += " AND B2_COD BETWEEN      '"+MV_PAR05+"' AND '"+MV_PAR06+"' " +ENTER
		cQueryA += " AND B2_LOCAL BETWEEN    '"+MV_PAR07+"' AND '"+MV_PAR08+"' " +ENTER
		cQueryA += " AND B2_FILIAL IN ('0107','0200','0803','0901') " +ENTER
		cQueryA += " AND NOT SB2.B2_COD IN ('MP.0001','MP.0002') " +ENTER
		cQueryA += " AND B1_TIPO <> 'MO' " +ENTER
		cQueryA += " AND SB2.D_E_L_E_T_ = ' ' " +ENTER
		cQueryA += " AND SB1.D_E_L_E_T_ = ' ' " +ENTER
		cQueryA += " GROUP BY B2_FILIAL,B2_COD, B1_DESC, B1_UM,B1_TIPO,B1_UCOM " +ENTER
	
	ElseIf MV_PAR12 == 2

		cQueryA := "SELECT '" + Rtrim(SM0->M0_NOME) + "' AS EMP, B2_FILIAL, B2_COD, B1_DESC, B1_TIPO, B2_LOCAL ,B1_UM, B1_UCOM ,B2_QATU, B2_VATU1   " +ENTER  
		cQueryA += " FROM " + RetSqlName("SB2") + " SB2 " + ENTER
		cQueryA += " INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_COD = B2_COD " + ENTER
		cQueryA += " WHERE B2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " +ENTER
		cQueryA += " AND B1_TIPO BETWEEN 'ME' AND 'MP' " +ENTER
		cQueryA += " AND B2_COD BETWEEN      '"+MV_PAR05+"' AND '"+MV_PAR06+"' " +ENTER
		cQueryA += " AND B2_LOCAL BETWEEN    '"+MV_PAR07+"' AND '"+MV_PAR08+"' " +ENTER
		cQueryA += " AND B2_FILIAL IN ('0107','0200','0803','0901') " +ENTER
		cQueryA += " AND NOT SB2.B2_COD IN ('MP.0001','MP.0002') " +ENTER
		cQueryA += " AND B1_TIPO <> 'MO' " +ENTER
		cQueryA += " AND SB2.D_E_L_E_T_ = ' ' " +ENTER
		cQueryA += " AND SB1.D_E_L_E_T_ = ' ' " +ENTER
	
	EndIf

	TcQuery cQueryA ALIAS "TRB1" NEW

	oExcel:AddworkSheet(cNomWrk)
	oExcel:AddTable(cNomPla, cTitPla)
	oExcel:AddColumn(cNomPla, cTitPla, "Empresa"  , 1, 1, .F.)  //01
	oExcel:AddColumn(cNomPla, cTitPla, "Filial "  , 1, 1, .F.)  //02
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo"   , 1, 1, .F.)  //03
	oExcel:AddColumn(cNomPla, cTitPla, "Descricao", 1, 1, .F.)  //04
	oExcel:AddColumn(cNomPla, cTitPla, "Tipo"     , 1, 1, .F.)  //05
	If MV_PAR12 == 2
		oExcel:AddColumn(cNomPla, cTitPla, "Armazem"  , 1, 1, .F.)  //06
	Else 
		oExcel:AddColumn(cNomPla, cTitPla, "Sem Armazem"  , 1, 1, .F.)  //06
	Endif
	oExcel:AddColumn(cNomPla, cTitPla, "UM"       , 1, 1, .F.)  //07
	oExcel:AddColumn(cNomPla, cTitPla, "Dt. Ult. Compra"   , 1, 1, .F.)  //08
	oExcel:AddColumn(cNomPla, cTitPla, "Saldo em Estoque"  , 3, 2, .F.)  //09
	oExcel:AddColumn(cNomPla, cTitPla, "Vl. Custo Unit."   , 3, 2, .F.)  //10
	oExcel:AddColumn(cNomPla, cTitPla, "Total do Custo"    , 3, 2, .F.)  //11
	oExcel:AddColumn(cNomPla, cTitPla, "Periodo de "+cDiaTit+" Dias"   , 3, 2, .F.)  //12
	oExcel:AddColumn(cNomPla, cTitPla, "Quant. Consumo em "+cDiaTit+" Dias" , 3, 2, .F.)  //13
	oExcel:AddColumn(cNomPla, cTitPla, "Quant. Compra Nac.", 3, 2, .F.)  //14
	oExcel:AddColumn(cNomPla, cTitPla, "Quant. Compra Imp.", 3, 2, .F.)  //15
	oExcel:AddColumn(cNomPla, cTitPla, "Quant. Ped. Compra Aprovado", 3, 2, .F.)  //16
	oExcel:AddColumn(cNomPla, cTitPla, "Quant. Cons. p/ Dia", 3, 2, .F.)  //17
	oExcel:AddColumn(cNomPla, cTitPla, "Dias Cobertura Estoque", 1, 1, .F.)  //18
	oExcel:AddColumn(cNomPla, cTitPla, "Dias Exedente da Cobertura Estoque", 1, 1, .F.)  //19
	oExcel:AddColumn(cNomPla, cTitPla, "Calculo Ref. 7 ou 45  Dias", 3, 2, .F.)  //20
		

	TRB1->(DbGoTop())
	
	ProcRegua(TRB1->(LastRec()))
	
	While TRB1->(!Eof())

		nConsumo    := 0 
		nPedCmp     := 0
		nTotCusto   := 0
		nNacional   := 0
		nImport     := 0
		nCalcDia    := 0
		nCalcCorb   := 0
		nSevenDay   := 0
		nForFiveDay := 0

		
		If Select("TRB2") > 0
			TRB2->(DbCloseArea())
		EndIf

		/*
			QUERY - Listagem de consumo nas requisições e movimentações internas  
		*/
		cQueryB := "SELECT ISNULL(SUM(D3_QUANT),0) AS D3_QUANT   " +ENTER  
		cQueryB += " FROM " + RetSqlName("SD3") + " SD3 " + ENTER
		cQueryB += " INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_COD = D3_COD " + ENTER
		cQueryB += " WHERE D3_FILIAL = '"+TRB1->B2_FILIAL+"' " +ENTER
		cQueryB += " AND B1_TIPO     = '"+TRB1->B1_TIPO+"'   " +ENTER
		cQueryB += " AND D3_COD      = '"+TRB1->B2_COD+"'    " +ENTER
		If MV_PAR12 == 2
			cQueryB += " AND D3_LOCAL    = '"+TRB1->B2_LOCAL+"'  " +ENTER
		EndIf
		cQueryB += " AND D3_EMISSAO BETWEEN  '"+DtoS(MV_PAR09)+"' AND '"+Dtos(MV_PAR10)+"' " +ENTER
		cQueryB += " AND D3_CF <> 'RE4' " +ENTER
		cQueryB += " AND SUBSTRING(D3_CF,1,2) = 'RE' " +ENTER
		cQueryB += " AND B1_TIPO <> 'MO' " +ENTER
		cQueryB += " AND D3_FILIAL IN ('0107','0200','0803','0901') " +ENTER
		cQueryB += " AND SD3.D_E_L_E_T_ = ' ' " +ENTER
		cQueryB += " AND SB1.D_E_L_E_T_ = ' ' " +ENTER

		TcQuery cQueryB ALIAS "TRB2" NEW
		
		/*
			QUERY - Listagem das saidas pelas notas ficais que movimentam estoque   
		*/

		If Select("TRB3") > 0
			TRB3->(DbCloseArea())
		EndIf

		cQueryC := "SELECT ISNULL(SUM(D2_QUANT),0) AS D2_QUANT  " +ENTER  
		cQueryC += " FROM " + RetSqlName("SD2") + " SD2 " + ENTER
		cQueryC += " INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_COD = D2_COD    " + ENTER
		cQueryC += " INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON D2_TES = F4_CODIGO " + ENTER
		cQueryC += " WHERE D2_FILIAL = '"+TRB1->B2_FILIAL+"' " +ENTER
		cQueryC += " AND B1_TIPO     = '"+TRB1->B1_TIPO+"'   " +ENTER
		cQueryC += " AND D2_COD      = '"+TRB1->B2_COD+"'    " +ENTER
		If MV_PAR12 == 2 
			cQueryC += " AND D2_LOCAL    = '"+TRB1->B2_LOCAL+"'  " +ENTER
		EndIf
		cQueryC += " AND D2_EMISSAO BETWEEN  '"+DtoS(MV_PAR09)+"' AND '"+Dtos(MV_PAR10)+"' " +ENTER
		cQueryC += " AND F4_ESTOQUE = 'S' " +ENTER
		cQueryC += " AND F4_PODER3 = 'N'  " +ENTER
		cQueryC += " AND D2_FILIAL IN ('0107','0200','0803','0901') " +ENTER
		cQueryC += " AND B1_TIPO <> 'MO' " +ENTER
		cQueryC += " AND SD2.D_E_L_E_T_ = ' ' " +ENTER
		cQueryC += " AND SB1.D_E_L_E_T_ = ' ' " +ENTER
		cQueryC += " AND SF4.D_E_L_E_T_ = ' ' " +ENTER

		TcQuery cQueryC ALIAS "TRB3" NEW

		/*
			QUERY - Listagem das saidas pelas notas ficais de entrada que movimentam estoque nacional
		*/

		If Select("TRB4") > 0
			TRB4->(DbCloseArea())
		EndIf

		cQueryD := "SELECT ISNULL(SUM(D1_QUANT),0) AS D1_QUANTA  " +ENTER  
		cQueryD += " FROM " + RetSqlName("SD1") + " SD1 " + ENTER
		cQueryD += " INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_COD = D1_COD    " + ENTER
		cQueryD += " INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON D1_TES = F4_CODIGO " + ENTER
		cQueryD += " AND F4_FILIAL = SUBSTRING(D1_FILIAL,1,2) " +ENTER
		cQueryD += " WHERE D1_FILIAL = '"+TRB1->B2_FILIAL+"' " +ENTER
		cQueryD += " AND F4_FILIAL = '"+SUBSTR(TRB1->B2_FILIAL,1,2)+"' " +ENTER
		cQueryD += " AND B1_TIPO     = '"+TRB1->B1_TIPO+"'   " +ENTER
		cQueryD += " AND D1_COD      = '"+TRB1->B2_COD+"'    " +ENTER
		cQueryD += " AND D1_DTDIGIT BETWEEN  '"+DtoS(MV_PAR09)+"' AND '"+Dtos(MV_PAR10)+"' " +ENTER
		cQueryD += " AND F4_ESTOQUE = 'S' " +ENTER
		cQueryD += " AND F4_PODER3 = 'N'  " +ENTER
		cQueryD += " AND SUBSTRING(D1_CF,1,1) <> '3' " +ENTER
		cQueryD += " AND B1_TIPO <> 'MO' " +ENTER
		cQueryD += " AND SD1.D_E_L_E_T_ = ' ' " +ENTER
		cQueryD += " AND SB1.D_E_L_E_T_ = ' ' " +ENTER
		cQueryD += " AND SF4.D_E_L_E_T_ = ' ' " +ENTER

		TcQuery cQueryD ALIAS "TRB4" NEW

		/*
			QUERY - Listagem das notas de entrada que se referemn a inportação 
		*/

		If Select("TRB5") > 0
			TRB5->(DbCloseArea())
		EndIf

		cQueryE := "SELECT ISNULL(SUM(D1_QUANT),0) AS D1_QUANTB  " +ENTER  
		cQueryE += " FROM " + RetSqlName("SD1") + " SD1 " + ENTER
		cQueryE += " INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_COD = D1_COD    " + ENTER
		cQueryE += " INNER JOIN " + RetSqlName("SF4") + " AS SF4 WITH (NOLOCK) ON D1_TES = F4_CODIGO " + ENTER
		cQueryE += " WHERE D1_FILIAL = '"+TRB1->B2_FILIAL+"' " +ENTER
		cQueryE += " AND B1_TIPO     = '"+TRB1->B1_TIPO+"'   " +ENTER
		cQueryE += " AND D1_COD      = '"+TRB1->B2_COD+"'    " +ENTER
		If MV_PAR12 == 2 
			cQueryE += " AND D1_LOCAL    = '"+TRB1->B2_LOCAL+"'  " +ENTER
		EndIf
		cQueryE += " AND D1_DTDIGIT BETWEEN  '"+DtoS(MV_PAR09)+"' AND '"+Dtos(MV_PAR10)+"' " +ENTER
		cQueryE += " AND F4_ESTOQUE = 'S' " +ENTER
		cQueryE += " AND F4_PODER3 = 'N'  " +ENTER
		cQueryE += " AND SUBSTRING(D1_CF,1,1) = '3' " +ENTER
		cQueryE += " AND D1_FILIAL IN ('0107','0200','0803','0901') " +ENTER
		cQueryE += " AND B1_TIPO <> 'MO' " +ENTER
		cQueryE += " AND SD1.D_E_L_E_T_ = ' ' " +ENTER
		cQueryE += " AND SB1.D_E_L_E_T_ = ' ' " +ENTER
		cQueryE += " AND SF4.D_E_L_E_T_ = ' ' " +ENTER


		TcQuery cQueryE ALIAS "TRB5" NEW

		/*
			QUERY - Listagem das notas de entrada que se referemn a inportação 
		*/

		If Select("TRB6") > 0
			TRB6->(DbCloseArea())
		EndIf

		cQueryF := "SELECT ISNULL(SUM(C7_QUANT),0) AS C7_QUANT  " +ENTER  
		cQueryF += " FROM " + RetSqlName("SC7") + " SC7 " + ENTER
		cQueryF += " INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_COD = C7_PRODUTO " + ENTER
		cQueryF += " WHERE C7_FILIAL = '"+TRB1->B2_FILIAL+"' " +ENTER
		cQueryF += " AND B1_TIPO     = '"+TRB1->B1_TIPO+"'   " +ENTER
		cQueryF += " AND C7_PRODUTO  = '"+TRB1->B2_COD+"'  " +ENTER
		If MV_PAR12 == 2 
			cQueryF += " AND C7_LOCAL    = '"+TRB1->B2_LOCAL+"'  " +ENTER
		EndIf
		cQueryF += " AND C7_EMISSAO BETWEEN  '"+DtoS(MV_PAR09)+"' AND '"+Dtos(MV_PAR10)+"' " +ENTER
		cQueryF += " AND C7_CONAPRO <> 'B' " +ENTER
		cQueryF += " AND C7_QUJE = 0   " +ENTER
		cQueryF += " AND C7_QTDACLA = 0 " +ENTER
		cQueryF += " AND C7_TIPO = '1' " +ENTER
		cQueryF += " AND C7_RESIDUO = ' ' " +ENTER
		cQueryF += " AND C7_FILIAL IN ('0107','0200','0803','0901') " +ENTER
		cQueryF += " AND B1_TIPO <> 'MO' " +ENTER
		cQueryF += " AND SC7.D_E_L_E_T_ = ' ' " +ENTER
		cQueryF += " AND SB1.D_E_L_E_T_ = ' ' " +ENTER
		
		TcQuery cQueryF ALIAS "TRB6" NEW

		/*
			QUERY - Pegar o custo do armazen 02 
		*/

		If Select("TRB7") > 0
			TRB7->(DbCloseArea())
		EndIf

		cQueryG := "SELECT '" + Rtrim(SM0->M0_NOME) + "' AS EMP, B2_FILIAL, B2_COD,B1_DESC, B1_UM,B1_TIPO,B1_UCOM,B2_CM1 " +ENTER  
		cQueryG += " FROM " + RetSqlName("SB2") + " SB2 " + ENTER
		cQueryG += " INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_COD = B2_COD " + ENTER
		cQueryG += " WHERE B2_FILIAL = '"+TRB1->B2_FILIAL+"' " +ENTER
		cQueryG += " AND B1_TIPO BETWEEN 'ME' AND 'MP' " +ENTER
		cQueryG += " AND B2_COD = '"+TRB1->B2_COD+"' " +ENTER
		cQueryG += " AND B2_LOCAL IN ('02','H2') " +ENTER
		cQueryG += " AND B2_FILIAL IN ('0107','0200','0803','0901') " +ENTER
		cQueryG += " AND NOT SB2.B2_COD IN ('MP.0001','MP.0002') " +ENTER
		cQueryG += " AND B1_TIPO <> 'MO' " +ENTER
		cQueryG += " AND SB2.D_E_L_E_T_ = ' ' " +ENTER
		cQueryG += " AND SB1.D_E_L_E_T_ = ' ' " +ENTER
		
		TcQuery cQueryG ALIAS "TRB7" NEW

		lAbre := .T.
		
		// Tratamento dos calculos de cobertura por dia 

		dDataCom    := Substr(TRB1->B1_UCOM,7,2)+"/"+Substr(TRB1->B1_UCOM,5,2)+"/"+Substr(TRB1->B1_UCOM,1,4)
		nDias       := DateDiffDay(MV_PAR09, MV_PAR10)
		nConsumo    := (TRB2->D3_QUANT+TRB3->D2_QUANT) 
		nPedCmp     := TRB6->C7_QUANT

		If MV_PAR12 == 1 
			nCustUnit   := TRB7->B2_CM1
			nTotCusto   := (TRB1->B2_QATU/nCustUnit)
		ElseIf MV_PAR12 == 2
			nCustUnit   := (TRB1->B2_VATU1/TRB1->B2_QATU)
			nTotCusto   := TRB1->B2_VATU1
		Endif 

		nNacional   := TRB4->D1_QUANTA
		nImport     := TRB5->D1_QUANTB
		nCalcDia    := (nConsumo / nDias)
		nCalcCorb   := (TRB1->B2_QATU / nCalcDia)
		
		If TRB4->D1_QUANTA > 0
			If TRB1->B2_QATU > 0 .And. nConsumo > 0
				nCalcDay    := (nCalcCorb - 7)
				nSevenDay   := (nCalcDia * 7)

			Endif 
		ElseIf TRB5->D1_QUANTB > 0
			If TRB1->B2_QATU > 0 .And. nConsumo > 0
				nCalcDay    := (nCalcCorb - 45)
				nSevenDay   := (nCalcDia * 45)
			Endif 
		Else 
			nCalcDay    := (nCalcCorb - 7)
			nSevenDay   := (nCalcDia * 7)
		EndIf 
		
		If MV_PAR12 == 1 

			aAdd(aPlanilha, {TRB1->EMP,; 
							 TRB1->B2_FILIAL,; 
							 TRB1->B2_COD,; 
							 TRB1->B1_DESC,;      
							 TRB1->B1_TIPO,;
							 " ",; 
							 TRB1->B1_UM,;                       
							 dDataCom,; 
							 TRB1->B2_QATU,;
							 nCustUnit,;
							 nTotCusto,;
							 nDias,;
							 nConsumo,;
							 nNacional,;
							 nImport,;
							 nPedCmp,;
							 nCalcDia,;
							 IIF(nCalcDia > 0 ,Round(nCalcCorb,0),0),;
							 IIF(nCalcDia > 0 .And. TRB1->B2_QATU > 0 ,Round(nCalcDay ,0),0),;
							 IIF(nCalcDia > 0 ,nSevenDay,0)})
		ElseIf MV_PAR12 == 2 

			aAdd(aPlanilha, {TRB1->EMP, TRB1->B2_FILIAL, TRB1->B2_COD, TRB1->B1_DESC,;      
											TRB1->B1_TIPO, TRB1->B2_LOCAL ,TRB1->B1_UM,;                       
											dDataCom, TRB1->B2_QATU,nCustUnit,nTotCusto,nDias,nConsumo,;
											nNacional,nImport,nPedCmp,nCalcDia,;
											IIF(nCalcDia > 0 ,Round(nCalcCorb,0),0),;
											IIF(nCalcDia > 0 .And. TRB1->B2_QATU > 0 ,Round(nCalcDay ,0),0),;
											IIF(nCalcDia > 0 ,nSevenDay,0)})
		
		EndIf


		TRB1->(DbSkip())
		
		IncProc("Gerando arquivo...")

		nConsumo    := 0 
		nPedCmp     := 0
		nTotCusto   := 0
		nNacional   := 0
		nImport     := 0
		nCalcDia    := 0
		nCalcCorb   := 0
		nSevenDay   := 0

	EndDo

	// Ordena o calculo dos dias exedente em ordem decrecente  
	If MV_PAR11 = 1

		ASORT(aPlanilha, , , { | x,y | x[18] > y[18] } )

	ElseIf MV_PAR11 = 2

		ASORT(aPlanilha, , , { | x,y | x[19] > y[19] } )

	ElseIf MV_PAR11 = 3

		ASORT(aPlanilha, , , { | x,y | x[20] > y[20] } )

	EndIf 

	// preenche as informações na planilha de acordo com o Array aPlanilha 

	For nPlan:=1 To Len(aPlanilha)
		
			oExcel:AddRow(cNomPla,cTitPla,{aPlanilha[nPlan][01],;
										aPlanilha[nPlan][02],;
										aPlanilha[nPlan][03],;
										aPlanilha[nPlan][04],;
										aPlanilha[nPlan][05],;
										aPlanilha[nPlan][06],;
										aPlanilha[nPlan][07],;
										aPlanilha[nPlan][08],;
										aPlanilha[nPlan][09],;
										aPlanilha[nPlan][10],;
										aPlanilha[nPlan][11],;
										aPlanilha[nPlan][12],;
										aPlanilha[nPlan][13],;
										aPlanilha[nPlan][14],;
										aPlanilha[nPlan][15],;
										aPlanilha[nPlan][16],;
										aPlanilha[nPlan][17],;
										aPlanilha[nPlan][18],;
										aPlanilha[nPlan][19],;
										aPlanilha[nPlan][20]}) 

	Next nPlan
	
	TRB1->(DbCloseArea())
	TRB2->(DbCloseArea())
	TRB3->(DbCloseArea())
	TRB4->(DbCloseArea())
	TRB5->(DbCloseArea())
	TRB6->(DbCloseArea())
	TRB7->(DbCloseArea())

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

Aadd(_aPerg,{"Filial De  ......?"        ,"mv_ch1","C",04,"G","mv_par01","","","","","",""   ,"","",0})
Aadd(_aPerg,{"Filial Até ......?"        ,"mv_ch2","C",04,"G","mv_par02","","","","","",""   ,"","",0})
Aadd(_aPerg,{"Tipo Porduto De..?"        ,"mv_ch3","C",02,"G","mv_par03","","","","","","02" ,"","",0})
Aadd(_aPerg,{"Tipo Porduto Até.?"        ,"mv_ch4","C",02,"G","mv_par04","","","","","","02" ,"","",0})
Aadd(_aPerg,{"Produtos De  ....?"        ,"mv_ch5","C",15,"G","mv_par05","","","","","","SB1","","",0})
Aadd(_aPerg,{"Produtos Até ....?"        ,"mv_ch6","C",15,"G","mv_par06","","","","","","SB1","","",0})
Aadd(_aPerg,{"Armazem  De  ....?"        ,"mv_ch7","C",02,"G","mv_par07","","","","","","NNR","","",0})
Aadd(_aPerg,{"Armazem  Até ....?"        ,"mv_ch8","C",02,"G","mv_par08","","","","","","NNR","","",0})
Aadd(_aPerg,{"Periodo  De  ....?"        ,"mv_ch9","D",08,"G","mv_par09","","","","","",""   ,"","",0})
Aadd(_aPerg,{"Periodo Até .....?"        ,"mv_chA","D",08,"G","mv_par10","","","","","",""   ,"","",0})
Aadd(_aPerg,{"Ordena Por ......?"        ,"mv_chB","C",01,"C","mv_par11","Dias Cobertura","Dias Exedente","Dias por 7 ou 45","","",""   ,"","",0})
Aadd(_aPerg,{"Lista Armazem....?"        ,"mv_chC","C",01,"C","mv_par12","Não","Sim","","","",""   ,"","",0})

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
