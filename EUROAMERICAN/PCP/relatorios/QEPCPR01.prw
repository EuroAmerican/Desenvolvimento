#Include "protheus.ch"
#Include "parmtype.ch"
#Include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"

#define ENTER chr(13) + chr(10)

/*/{Protheus.doc} QEPCPR01
//Rotina para extrair saldos negativos das ordem de produção
@author Fabio Carneiro dos Santos 
@since 08/09/2022
@version 1.0
/*/
User Function QEPCPR01()

	Local aSays     := {}
	Local aButtons  := {}
	Local nOpca     := 0
	Local cTitoDlg  := "Listagem dos Saldos Das Ordens de Produção"
	Private _cPerg  := "QEPCPRA"

	// Prepara e executa a pergunta do relatorio

	aAdd(aSays, "Este relatório lista o saldo negativos dos empenhos de OP´S!")
	aAdd(aSays, "Este relatório não lista saldo zerado disponivel.")
	aAdd(aSays, "Deve se atentar para os preenchimento dos parametros!.")
	
	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	If nOpca == 1
	
		oAjustaSx1()

		If !Pergunte(_cPerg,.T.)
			Return
		Else 
			Processa({|| QEPCP01ok("Gerando relatório...")})
		Endif
		
	EndIf
	Return

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEPCP01ok | Autor: | QUALY         | Data: | 08/09/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEPCP01ok                                    |
+------------+-----------------------------------------------------------+
*/

Static Function QEPCP01ok()

	Local cArqDst    := "C:\TOTVS\QEPCPR01_EMP_" + SM0->M0_CODIGO + "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel     := FWMsExcelEX():New()
	Local cQuery     := ""
	Local cNomPla    := "Empresa_1" + Rtrim(SM0->M0_NOME)
	Local cTitPla    := "Saldos de empenhos por OP´S - Saldos em Estoque "
	Local cNomWrk    := "Empresa_1" + Rtrim(SM0->M0_NOME)
	Local lAbre      := .F.
	Local _nLista    := 0 
	Local _aDados    := {}
	Local _dDataEmi  := ""
	Local _dDataEnt  := ""

	Private TRB1      := GetNextAlias()
	
	MakeDir("C:\TOTVS")

	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf

	If MV_PAR10 = 1

		cQuery := "SELECT '01' AS ENVASE, " +ENTER 
		cQuery += " D4_FILIAL AS FILIAL, " +ENTER 
		cQuery += " D4_COD AS PRODUTO, " +ENTER 
		cQuery += " B1_DESC AS DESCRICAO, " +ENTER 
		cQuery += " B1_TIPO AS TIPO, " +ENTER 
		cQuery += " B1_UM AS UM, " +ENTER
		cQuery += " D4_OP AS OP, " +ENTER 
		cQuery += " D4_LOCAL AS ARMAZEN, " +ENTER 
		cQuery += " C2_PRODUTO AS CODIGOPAI, " +ENTER 
		cQuery += " C2_EMISSAO AS DTEMISSAO, " +ENTER 
		cQuery += " C2_DATPRF AS DTENTREGA, " +ENTER 
		cQuery += " D4_QUANT AS QUANT, " +ENTER  
		cQuery += " B2_QATU AS SALDOATU, " +ENTER 
		cQuery += " B2_QEMP AS EMP, " +ENTER 
		cQuery += " B2_QATU-B2_QEMP AS SALDO " +ENTER 
		cQuery += " FROM "+RetSqlName("SD4")+" AS SD4 " +ENTER 
		cQuery += " INNER JOIN "+RetSqlName("SB2")+" AS SB2 ON B2_FILIAL = D4_FILIAL " +ENTER 
		cQuery += " AND B2_COD = D4_COD " +ENTER 
		cQuery += " AND B2_LOCAL = D4_LOCAL " +ENTER 
		cQuery += " AND SB2.D_E_L_E_T_ = ' ' " +ENTER 
		cQuery += " INNER JOIN "+RetSqlName("SC2")+" AS SC2 ON C2_FILIAL = D4_FILIAL " +ENTER 
		cQuery += " AND C2_NUM+C2_ITEM = SUBSTRING(D4_OP,1,8) " +ENTER 
		cQuery += " AND SC2.D_E_L_E_T_ = ' '  " +ENTER 
		cQuery += " INNER JOIN "+RetSqlName("SB1")+" AS SB1 ON B1_COD = B2_COD  " +ENTER 
		cQuery += " AND SB1.D_E_L_E_T_ = ' ' " +ENTER 
		cQuery += " WHERE D4_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " +ENTER  
		cQuery += " AND D4_PRODUTO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+ ENTER
		cQuery += " AND D4_LOCAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "+ ENTER
		cQuery += " AND SUBSTRING(D4_OP,1,6) BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "+ ENTER
		cQuery += " AND B1_TIPO IN "+FORMATIN(RTrim(MV_PAR09),"/")+" "+ENTER
		cQuery += " AND D4_QUANT > 0  " +ENTER 
		If MV_PAR11 = 1
			cQuery += " AND (B2_QATU-B2_QEMP) < 0 " +ENTER 
		ElseIf MV_PAR11 = 2
			cQuery += " AND (B2_QATU-B2_QEMP) > 0 " +ENTER 
		EndIf
		cQuery += " AND SUBSTRING(D4_OP,7,2) = '01' " +ENTER
		cQuery += " AND B1_TIPO IN "+FORMATIN(GETMV("QE_TIP_MP"),"/")+" " + CRLF
		cQuery += " AND SD4.D_E_L_E_T_ = ' ' " +ENTER 
		cQuery += "GROUP BY D4_FILIAL, D4_COD, C2_PRODUTO,B1_DESC, B1_TIPO, B1_UM, D4_OP, D4_LOCAL, C2_EMISSAO, C2_DATPRF, " +ENTER
		cQuery += " B2_QATU, B2_QEMP, D4_QUANT " +ENTER
		cQuery += " ORDER BY D4_OP, D4_COD " +ENTER
	
	ElseIf MV_PAR10 = 2

		cQuery += " SELECT '02' AS ENVASE, " +ENTER
		cQuery += " D4_FILIAL AS FILIAL, " +ENTER
		cQuery += " D4_COD AS PRODUTO, " +ENTER 
		cQuery += " B1_DESC AS DESCRICAO, " +ENTER
		cQuery += " B1_TIPO AS TIPO, " +ENTER
		cQuery += " B1_UM AS UM, " +ENTER
		cQuery += " D4_OP AS OP, " +ENTER
		cQuery += " D4_LOCAL AS ARMAZEN, " +ENTER 
		cQuery += " C2_PRODUTO AS CODIGOPAI, " +ENTER
		cQuery += " C2_EMISSAO AS DTEMISSAO, " +ENTER
		cQuery += " C2_DATPRF AS DTENTREGA, " +ENTER
		cQuery += " D4_QUANT AS QUANT, " +ENTER  
		cQuery += " B2_QATU AS SALDOATU, " +ENTER 
		cQuery += " B2_QEMP AS EMP, " +ENTER 
		cQuery += " B2_QATU-B2_QEMP AS SALDO " +ENTER 
		cQuery += " FROM "+RetSqlName("SD4")+" AS SD4 " +ENTER 
		cQuery += " INNER JOIN "+RetSqlName("SB2")+" AS SB2 ON B2_FILIAL = D4_FILIAL " +ENTER 
		cQuery += " AND B2_COD = D4_COD " +ENTER 
		cQuery += " AND B2_LOCAL = D4_LOCAL " +ENTER 
		cQuery += " AND SB2.D_E_L_E_T_ = ' ' " +ENTER 
		cQuery += " INNER JOIN "+RetSqlName("SC2")+" AS SC2 ON C2_FILIAL = D4_FILIAL " +ENTER 
		cQuery += " AND C2_NUM+C2_ITEM = SUBSTRING(D4_OP,1,8) " +ENTER 
		cQuery += " AND SC2.D_E_L_E_T_ = ' '  " +ENTER 
		cQuery += " INNER JOIN "+RetSqlName("SB1")+" AS SB1 ON B1_COD = B2_COD  " +ENTER 
		cQuery += " AND SB1.D_E_L_E_T_ = ' ' " +ENTER 
		cQuery += " WHERE D4_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " +ENTER  
		cQuery += " AND D4_PRODUTO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+ ENTER
		cQuery += " AND D4_LOCAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "+ ENTER
		cQuery += " AND SUBSTRING(D4_OP,1,6) BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "+ ENTER
		cQuery += " AND B1_TIPO IN "+FORMATIN(RTrim(MV_PAR09),"/")+" "+ENTER
		cQuery += " AND D4_QUANT > 0  " +ENTER 
		If MV_PAR11 = 1
			cQuery += " AND (B2_QATU-B2_QEMP) < 0 " +ENTER 
		ElseIf MV_PAR11 = 2
			cQuery += " AND (B2_QATU-B2_QEMP) > 0 " +ENTER 
		EndIf
		cQuery += " AND SUBSTRING(D4_OP,7,2) <> '01' " +ENTER
		cQuery += " AND B1_TIPO IN "+FORMATIN(GETMV("QE_TIP_PA"),"/")+" " + CRLF
		cQuery += " AND SD4.D_E_L_E_T_ = ' ' " +ENTER 
		cQuery += "GROUP BY D4_FILIAL, D4_COD, C2_PRODUTO,B1_DESC, B1_TIPO, B1_UM, D4_OP, D4_LOCAL, C2_EMISSAO, C2_DATPRF, " +ENTER
		cQuery += " B2_QATU, B2_QEMP, D4_QUANT " +ENTER
		cQuery += " ORDER BY D4_OP, D4_COD " +ENTER

	ElseIf MV_PAR10 = 3

		cQuery := "SELECT '01' AS ENVASE, " +ENTER 
		cQuery += " D4_FILIAL AS FILIAL, " +ENTER 
		cQuery += " D4_COD AS PRODUTO, " +ENTER 
		cQuery += " B1_DESC AS DESCRICAO, " +ENTER 
		cQuery += " B1_TIPO AS TIPO, " +ENTER 
		cQuery += " B1_UM AS UM, " +ENTER
		cQuery += " D4_OP AS OP, " +ENTER 
		cQuery += " D4_LOCAL AS ARMAZEN, " +ENTER 
		cQuery += " C2_PRODUTO AS CODIGOPAI, " +ENTER 
		cQuery += " C2_EMISSAO AS DTEMISSAO, " +ENTER 
		cQuery += " C2_DATPRF AS DTENTREGA, " +ENTER 
		cQuery += " D4_QUANT AS QUANT, " +ENTER  
		cQuery += " B2_QATU AS SALDOATU, " +ENTER 
		cQuery += " B2_QEMP AS EMP, " +ENTER 
		cQuery += " B2_QATU-B2_QEMP AS SALDO " +ENTER 
		cQuery += " FROM "+RetSqlName("SD4")+" AS SD4 " +ENTER 
		cQuery += " INNER JOIN "+RetSqlName("SB2")+" AS SB2 ON B2_FILIAL = D4_FILIAL " +ENTER 
		cQuery += " AND B2_COD = D4_COD " +ENTER 
		cQuery += " AND B2_LOCAL = D4_LOCAL " +ENTER 
		cQuery += " AND SB2.D_E_L_E_T_ = ' ' " +ENTER 
		cQuery += " INNER JOIN "+RetSqlName("SC2")+" AS SC2 ON C2_FILIAL = D4_FILIAL " +ENTER 
		cQuery += " AND C2_NUM+C2_ITEM = SUBSTRING(D4_OP,1,8) " +ENTER 
		cQuery += " AND SC2.D_E_L_E_T_ = ' '  " +ENTER 
		cQuery += " INNER JOIN "+RetSqlName("SB1")+" AS SB1 ON B1_COD = B2_COD  " +ENTER 
		cQuery += " AND SB1.D_E_L_E_T_ = ' ' " +ENTER 
		cQuery += " WHERE D4_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " +ENTER  
		cQuery += " AND D4_PRODUTO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+ ENTER
		cQuery += " AND D4_LOCAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "+ ENTER
		cQuery += " AND SUBSTRING(D4_OP,1,6) BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "+ ENTER
		cQuery += " AND B1_TIPO IN "+FORMATIN(RTrim(MV_PAR09),"/")+" "+ENTER
		cQuery += " AND D4_QUANT > 0  " +ENTER 
		If MV_PAR11 = 1
			cQuery += " AND (B2_QATU-B2_QEMP) < 0 " +ENTER 
		ElseIf MV_PAR11 = 2
			cQuery += " AND (B2_QATU-B2_QEMP) > 0 " +ENTER 
		EndIf
		cQuery += " AND SUBSTRING(D4_OP,7,2) = '01' " +ENTER
		cQuery += " AND B1_TIPO IN "+FORMATIN(GETMV("QE_TIP_MP"),"/")+" " + CRLF
		cQuery += " AND SD4.D_E_L_E_T_ = ' ' " +ENTER 
		cQuery += "GROUP BY D4_FILIAL, D4_COD, C2_PRODUTO,B1_DESC, B1_TIPO, B1_UM, D4_OP, D4_LOCAL, C2_EMISSAO, C2_DATPRF, " +ENTER
		cQuery += " B2_QATU, B2_QEMP, D4_QUANT " +ENTER
		
		cQuery += " UNION " +ENTER

		cQuery += " SELECT '02' AS ENVASE, " +ENTER
		cQuery += " D4_FILIAL AS FILIAL, " +ENTER
		cQuery += " D4_COD AS PRODUTO, " +ENTER 
		cQuery += " B1_DESC AS DESCRICAO, " +ENTER
		cQuery += " B1_TIPO AS TIPO, " +ENTER
		cQuery += " B1_UM AS UM, " +ENTER
		cQuery += " D4_OP AS OP, " +ENTER
		cQuery += " D4_LOCAL AS ARMAZEN, " +ENTER 
		cQuery += " C2_PRODUTO AS CODIGOPAI, " +ENTER
		cQuery += " C2_EMISSAO AS DTEMISSAO, " +ENTER
		cQuery += " C2_DATPRF AS DTENTREGA, " +ENTER
		cQuery += " D4_QUANT AS QUANT, " +ENTER  
		cQuery += " B2_QATU AS SALDOATU, " +ENTER 
		cQuery += " B2_QEMP AS EMP, " +ENTER 
		cQuery += " B2_QATU-B2_QEMP AS SALDO " +ENTER 
		cQuery += " FROM "+RetSqlName("SD4")+" AS SD4 " +ENTER 
		cQuery += " INNER JOIN "+RetSqlName("SB2")+" AS SB2 ON B2_FILIAL = D4_FILIAL " +ENTER 
		cQuery += " AND B2_COD = D4_COD " +ENTER 
		cQuery += " AND B2_LOCAL = D4_LOCAL " +ENTER 
		cQuery += " AND SB2.D_E_L_E_T_ = ' ' " +ENTER 
		cQuery += " INNER JOIN "+RetSqlName("SC2")+" AS SC2 ON C2_FILIAL = D4_FILIAL " +ENTER 
		cQuery += " AND C2_NUM+C2_ITEM = SUBSTRING(D4_OP,1,8) " +ENTER 
		cQuery += " AND SC2.D_E_L_E_T_ = ' '  " +ENTER 
		cQuery += " INNER JOIN "+RetSqlName("SB1")+" AS SB1 ON B1_COD = B2_COD  " +ENTER 
		cQuery += " AND SB1.D_E_L_E_T_ = ' ' " +ENTER 
		cQuery += " WHERE D4_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " +ENTER  
		cQuery += " AND D4_PRODUTO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+ ENTER
		cQuery += " AND D4_LOCAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "+ ENTER
		cQuery += " AND SUBSTRING(D4_OP,1,6) BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "+ ENTER
		cQuery += " AND B1_TIPO IN "+FORMATIN(RTrim(MV_PAR09),"/")+" "+ENTER
		cQuery += " AND D4_QUANT > 0  " +ENTER 
		If MV_PAR11 = 1
			cQuery += " AND (B2_QATU-B2_QEMP) < 0 " +ENTER 
		ElseIf MV_PAR11 = 2
			cQuery += " AND (B2_QATU-B2_QEMP) > 0 " +ENTER 
		EndIf
		cQuery += " AND SUBSTRING(D4_OP,7,2) <> '01' " +ENTER
		cQuery += " AND B1_TIPO IN "+FORMATIN(GETMV("QE_TIP_PA"),"/")+" " + CRLF
		cQuery += " AND SD4.D_E_L_E_T_ = ' ' " +ENTER 
		cQuery += "GROUP BY D4_FILIAL, D4_COD, C2_PRODUTO,B1_DESC, B1_TIPO, B1_UM, D4_OP, D4_LOCAL, C2_EMISSAO, C2_DATPRF, " +ENTER
		cQuery += " B2_QATU, B2_QEMP, D4_QUANT " +ENTER
		cQuery += " ORDER BY OP, PRODUTO " +ENTER

	EndIf

	TcQuery cQuery ALIAS "TRB1" NEW

	// trata lotes na tabela SB8
	
	oExcel:AddworkSheet(cNomWrk)
	oExcel:AddTable(cNomPla, cTitPla)
	oExcel:AddColumn(cNomPla, cTitPla, "Filial "      , 1, 1, .F.) //01
	oExcel:AddColumn(cNomPla, cTitPla, "Tipo da OP"   , 1, 1, .F.) //02
	oExcel:AddColumn(cNomPla, cTitPla, "Cod. Produto" , 1, 1, .F.) //03
	oExcel:AddColumn(cNomPla, cTitPla, "Descricao"    , 1, 1, .F.) //04
	oExcel:AddColumn(cNomPla, cTitPla, "Tipo Produto" , 1, 1, .F.) //05
	oExcel:AddColumn(cNomPla, cTitPla, "Unid.Med."    , 1, 1, .F.) //06
	oExcel:AddColumn(cNomPla, cTitPla, "Produto Pai"  , 1, 1, .F.) //07 
	oExcel:AddColumn(cNomPla, cTitPla, "Descricao Pai", 1, 1, .F.) //08
	oExcel:AddColumn(cNomPla, cTitPla, "Num. Lote"    , 1, 1, .F.) //09
	oExcel:AddColumn(cNomPla, cTitPla, "Armazem"      , 1, 1, .F.) //10
	oExcel:AddColumn(cNomPla, cTitPla, "Dt.Emissao OP", 1, 1, .F.) //11
	oExcel:AddColumn(cNomPla, cTitPla, "Dt.Entrega OP", 1, 1, .F.) //12
	oExcel:AddColumn(cNomPla, cTitPla, "Qtde Empenho Lote"    , 3, 2, .F.) //13
	oExcel:AddColumn(cNomPla, cTitPla, "Qtde Tot. Sld. Atual" , 3, 2, .F.) //14
	oExcel:AddColumn(cNomPla, cTitPla, "Qtde Tot. Empenho"    , 3, 2, .F.) //15
	oExcel:AddColumn(cNomPla, cTitPla, "Qtde Sld. Disponivel" , 3, 2, .F.) //16

	TRB1->(DbGoTop())

	ProcRegua(TRB1->(LastRec()))
	
	While TRB1->(!Eof())
		
		lAbre := .T.
		
		_dDataEmi  := Substr(TRB1->DTEMISSAO,7,2)+"/"+Substr(TRB1->DTEMISSAO,5,2)+"/"+Substr(TRB1->DTEMISSAO,1,4)
		_dDataEnt  := Substr(TRB1->DTENTREGA,7,2)+"/"+Substr(TRB1->DTENTREGA,5,2)+"/"+Substr(TRB1->DTENTREGA,1,4)

		Aadd(_aDados,{TRB1->FILIAL,;     //01
						IF(TRB1->ENVASE=="01","Sem Envase","Com Envase"),; //02
						TRB1->PRODUTO,;  //03
						TRB1->DESCRICAO,;//04
						TRB1->TIPO,;     //05
						TRB1->UM,;       //06
						TRB1->CODIGOPAI,;//07
						Posicione("SB1",1,xFilial("SB1")+TRB1->CODIGOPAI,"B1_DESC"),; //08
						SubStr(TRB1->OP,1,6),;//09
						TRB1->ARMAZEN,;  //10
						_dDataEmi,;      //11
						_dDataEnt,;      //12
						TRB1->QUANT,;    //13
						TRB1->SALDOATU,; //14
						TRB1->EMP,;      //15
						TRB1->SALDO})    //16

		TRB1->(DbSkip())


		IncProc("Gerando arquivo...")
	
	EndDo

	If Len(_aDados) > 0 

		For _nLista:=1 To Len(_aDados)

			oExcel:AddRow(cNomPla, cTitPla, {_aDados[_nLista][01],;
											 _aDados[_nLista][02],;
			      							 _aDados[_nLista][03],;
			      							 _aDados[_nLista][04],;
			      							 _aDados[_nLista][05],;
			      							 _aDados[_nLista][06],;
			      							 _aDados[_nLista][07],;
			      							 _aDados[_nLista][08],;
			      							 _aDados[_nLista][09],;
			      							 _aDados[_nLista][10],;
			      							 _aDados[_nLista][11],;
			      							 _aDados[_nLista][12],;
			      							 _aDados[_nLista][13],;
			      							 _aDados[_nLista][14],;
			      							 _aDados[_nLista][15],;
			      							 _aDados[_nLista][16]}) 


		Next _nLista
	
	EndIf	
	
	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf
	
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

Aadd(_aPerg,{"Filial De  ......?","mv_ch1","C",04,"G","mv_par01","","","","","","SM0","","",0})
Aadd(_aPerg,{"Filial Até ......?","mv_ch2","C",04,"G","mv_par02","","","","","","SM0","","",0})
Aadd(_aPerg,{"Produtos De .....?","mv_ch3","C",15,"G","mv_par03","","","","","","SB1","","",0})
Aadd(_aPerg,{"Produtos Até ....?","mv_ch4","C",15,"G","mv_par04","","","","","","SB1","","",0})
Aadd(_aPerg,{"Armazen De  .....?","mv_ch5","C",02,"G","mv_par05","","","","","","NNR","","",0})
Aadd(_aPerg,{"Armazen Até .....?","mv_ch6","C",02,"G","mv_par06","","","","","","NNR","","",0})
Aadd(_aPerg,{"Lote OP De  .....?","mv_ch7","C",10,"G","mv_par07","","","","","","SC2","","",0})
Aadd(_aPerg,{"Lote OP Até .....?","mv_ch8","C",10,"G","mv_par08","","","","","","SC2","","",0})
Aadd(_aPerg,{"Tip.Prod.ME/MP/PI?","mv_ch9","C",20,"G","mv_par09","","","","","","","","",0})
Aadd(_aPerg,{"Lista Tipos OP´S.?","mv_cha","C",01,"C","mv_par10","Sem Envase","Com Envase","Todos","","","","","",0})
Aadd(_aPerg,{"Lista Saldos ....?","mv_chb","C",01,"C","mv_par11","Negativos","Positivos","Todos","","","","","",0})


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

