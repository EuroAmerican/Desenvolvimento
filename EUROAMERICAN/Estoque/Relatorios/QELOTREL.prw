#Include "protheus.ch"
#Include "parmtype.ch"
#Include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"

#define ENTER chr(13) + chr(10)

/*/{Protheus.doc} QELOTREL
//Rotina para extrair layout para rodar o inventario
@author Fabio Carneiro dos Santos 
@since 28/05/2022
@version 1.0
/*/
User Function QELOTREL()

	Local aSays     := {}
	Local aButtons  := {}
	Local nOpca     := 0
	Local _cArmaz   := GetMv("QE_ARMAZ")
	Local _cTipProd := GetMv("QE_TIPPROD")
	Local cTitoDlg  := "Listagem de LAYOUT dos Lotes Vencidos e a Vencer para inventario"
	Private _cPerg  := "QELOTR01"

	// Prepara e executa a pergunta do relatorio

	aAdd(aSays, "Este relatório lista o saldo LAYOUT a ser utilizado para o inventario!")
	aAdd(aSays, "Este relatório não lista saldo zerado.")
	aAdd(aSays, "O parâmetro QE_ARMAZ - (Armazén)  está com o conteúdo "+_cArmaz+" !!!")
	aAdd(aSays, "O parâmetro QE_TIPPROD - (Tipo Produto) está com o conteúdo "+_cTipProd+" !!!")
	aAdd(aSays, "Caso queira fazer o inventario, deve ser alterado os parâmetros QE_ARMAZ e QE_TIPPROD.")
	aAdd(aSays, "Para alterar-los, favor abrir chamado no TI !!!")
	
	
	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	If nOpca == 1
	
		oAjustaSx1()

		If !Pergunte(_cPerg,.T.)
			Return
		Else 
			Processa({|| QELOT01ok("Gerando relatório...")})
		Endif
		
	EndIf
	Return

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QELOT01ok | Autor: | QUALY         | Data: | 28/05/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QELOT01ok                                    |
+------------+-----------------------------------------------------------+
*/

Static Function QELOT01ok()

	Local cArqDst    := "C:\TOTVS\QERLOT01_EMP_" + SM0->M0_CODIGO + "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel     := FWMsExcelEX():New()
	Local cQuery     := ""
	Local cNomPla    := "Empresa_1" + Rtrim(SM0->M0_NOME)
	Local cTitPla    := "Saldos de lotes para Layout"
	Local cNomWrk    := "Empresa_1" + Rtrim(SM0->M0_NOME)
	Local lAbre      := .F.
	Local _cArmaz    := GetMv("QE_ARMAZ")
	Local _cTipProd  := GetMv("QE_TIPPROD")
	Local dDataVal   := ""
	Local _cFilial   := ""
	Local _cProduto  := ""
	Local _cDesc     := ""
	Local _cTipo     := ""
	Local _cLocal    := ""
	Local _cUnid     := ""
	Local _cLote     := ""
	Local _dDataVal  := ""
	Local _cRegistro := ""
	Local _dDtaPassa := ""
	Local _cCtrlLot  := ""
	Local _cCtrlEnd  := ""
	Local _nSaldo    := 0
	Local _nEmpenho  := 0
	Local _nLista    := 0

	Local _aDados    := {}

	Private TRB1      := GetNextAlias()
	
	MakeDir("C:\TOTVS")

	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf
	
	cQuery := "SELECT '001' AS REG, B8_FILIAL AS FILIAL, B8_PRODUTO AS PRODUTO, B1_DESC AS DESCRI, B1_TIPO AS TIPO, B8_LOCAL AS ARMAZEN, B1_UM AS UM, " +ENTER 
	cQuery += " B8_LOTECTL AS LOTE, B8_DTVALID AS VALID,'' AS LOCALIZ ,B8_SALDO AS SALDO, B8_EMPENHO AS EMPENHO, B1_RASTRO AS RASTRO, B1_LOCALIZ AS CTRLEND " +ENTER  
	cQuery += "FROM " + RetSqlName("SB8") + " AS SB8 " +ENTER  
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 ON B1_FILIAL = ' '  " +ENTER  
	cQuery += " AND B1_COD = B8_PRODUTO " +ENTER  
	cQuery += " AND SB1.D_E_L_E_T_ = ' '  " +ENTER  
	cQuery += "WHERE B8_FILIAL =  '"+xFilial("SB8")+"' " +ENTER  
	cQuery += " AND SB8.B8_PRODUTO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+ ENTER
	cQuery += " AND SB8.B8_LOCAL = '"+AllTrim(_cArmaz)+"' "+ ENTER
	cQuery += " AND B8_SALDO > 0  " +ENTER  
	cQuery += " AND SB8.D_E_L_E_T_ = ' '  " +ENTER  
	
	cQuery += "UNION " +ENTER  

    cQuery += "SELECT '002' AS REG, BF_FILIAL AS FILIAL, BF_PRODUTO AS PRODUTO, B1_DESC AS DESCRI, B1_TIPO AS TIPO, BF_LOCAL AS ARMAZEN, B1_UM AS UM, " +ENTER  
	cQuery += " BF_LOTECTL AS LOTE, '' AS VALID,BF_LOCALIZ AS LOCALIZ ,BF_QUANT AS SALDO, BF_EMPENHO AS EMPENHO, B1_RASTRO AS RASTRO, B1_LOCALIZ AS CTRLEND " +ENTER  
	cQuery += "FROM  " + RetSqlName("SBF") + " AS SBF " +ENTER  
	cQuery += "INNER JOIN  " + RetSqlName("SB1") + " AS SB1 ON B1_FILIAL = ' ' " +ENTER  
	cQuery += " AND B1_COD = BF_PRODUTO " +ENTER  
	cQuery += "WHERE BF_FILIAL =  '"+xFilial("SBF")+"' " +ENTER  
	cQuery += " AND BF_PRODUTO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+ ENTER
	cQuery += " AND BF_LOCAL = '"+AllTrim(_cArmaz)+"' "+ ENTER
	cQuery += " AND BF_QUANT > 0  " +ENTER  
	cQuery += " AND SBF.D_E_L_E_T_ = ' ' " +ENTER  
	cQuery += "ORDER BY PRODUTO, LOTE " +ENTER  

	TcQuery cQuery ALIAS "TRB1" NEW

	// trata lotes na tabela SB8
	
	oExcel:AddworkSheet(cNomWrk)
	oExcel:AddTable(cNomPla, cTitPla)
	oExcel:AddColumn(cNomPla, cTitPla, "Filial "  , 1, 1, .F.)        //01
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo"   , 1, 1, .F.)        //02
	oExcel:AddColumn(cNomPla, cTitPla, "Descricao", 1, 1, .F.)        //03
	oExcel:AddColumn(cNomPla, cTitPla, "Tipo"     , 1, 1, .F.)        //04
	oExcel:AddColumn(cNomPla, cTitPla, "Armazem"  , 1, 1, .F.)        //05
	oExcel:AddColumn(cNomPla, cTitPla, "Unid.Med.", 1, 1, .F.)        //06
	oExcel:AddColumn(cNomPla, cTitPla, "Num. Lote", 1, 1, .F.)        //07
	oExcel:AddColumn(cNomPla, cTitPla, "Endereço" , 1, 1, .F.)        //08
	oExcel:AddColumn(cNomPla, cTitPla, "Dt.Vld"   , 1, 1, .F.)        //09
	oExcel:AddColumn(cNomPla, cTitPla, "Saldo"    , 3, 2, .F.)        //10
	oExcel:AddColumn(cNomPla, cTitPla, "Empenho"  , 3, 2, .F.)        //11
	oExcel:AddColumn(cNomPla, cTitPla, "Ctrl Lote", 1, 1, .F.)        //12
	oExcel:AddColumn(cNomPla, cTitPla, "Ctrl End.", 1, 1, .F.)        //13
	

	TRB1->(DbGoTop())
	ProcRegua(TRB1->(LastRec()))
	
	While TRB1->(!Eof())

		If TRB1->TIPO $ _cTipProd

			lAbre := .T.
			
			_cProduto  := TRB1->PRODUTO
			_cLote     := TRB1->LOTE
			_cLocaliz  := TRB1->LOCALIZ
			_cRegistro := AllTrim(TRB1->REG)

			If AllTrim(_cRegistro) == "001" // Lote 
				dDataVal   := Substr(TRB1->VALID,7,2)+"/"+Substr(TRB1->VALID,5,2)+"/"+Substr(TRB1->VALID,1,4)
				_dDtaPassa := TRB1->VALID 
			EndIf
			
			If TRB1->CTRLEND == "S" .And. TRB1->RASTRO == "L" 			
			
				If AllTrim(_cRegistro) == "002" // Endereço 
					
					_cFilial   := TRB1->FILIAL 
					_cProduto  := TRB1->PRODUTO 
					_cDesc     := TRB1->DESCRI      
					_cTipo     := TRB1->TIPO 
					_cLocal    := TRB1->ARMAZEN 
					_cUnid     := TRB1->UM                       
					_cLote     := TRB1->LOTE
					_cLocaliz  := TRB1->LOCALIZ
					_dDataVal  := dDataVal
					_nSaldo    := TRB1->SALDO 
					_nEmpenho  := TRB1->EMPENHO
					_cCtrlLot  := If(TRB1->RASTRO == "S","Sim","Não")
					_cCtrlEnd  := If(TRB1->CTRLEND == "L","Sim","Não")
					
				EndIf

				If _cRegistro == "002" //Endereço 

					Aadd(_aDados,{AllTrim(_cFilial),;
								AllTrim(_cProduto),;
								AllTrim(_cDesc),;
								AllTrim(_cTipo),;
								AllTrim(_cLocal),;
								AllTrim(_cUnid),;
								AllTrim(_cLote),;
								AllTrim(_cLocaliz),;
								If(!Empty(_dDtaPassa),AllTrim(_dDataVal),"Sem Validade"),;
								_nSaldo,;
								_nEmpenho,;
								_cCtrlLot,;
								_cCtrlEnd})
						
				EndIf
			
			Else

				If TRB1->RASTRO == "L" 

					If AllTrim(_cRegistro) == "001" // Lote 
						
						_cFilial   := TRB1->FILIAL 
						_cProduto  := TRB1->PRODUTO 
						_cDesc     := TRB1->DESCRI      
						_cTipo     := TRB1->TIPO 
						_cLocal    := TRB1->ARMAZEN 
						_cUnid     := TRB1->UM                       
						_cLote     := TRB1->LOTE
						_cLocaliz  := ""
						_dDataVal  := dDataVal
						_nSaldo    := TRB1->SALDO 
						_nEmpenho  := TRB1->EMPENHO
						_cCtrlLot  := If(TRB1->CTRLEND == "S","Sim","Não")
						_cCtrlEnd  := If(TRB1->RASTRO == "L","Sim","Não")
						
					EndIf

					If _cRegistro == "001" //Endereço 

						Aadd(_aDados,{AllTrim(_cFilial),;
									AllTrim(_cProduto),;
									AllTrim(_cDesc),;
									AllTrim(_cTipo),;
									AllTrim(_cLocal),;
									AllTrim(_cUnid),;
									AllTrim(_cLote),;
									AllTrim(_cLocaliz),;
									If(!Empty(_dDtaPassa),AllTrim(_dDataVal),"Sem Validade"),;
									_nSaldo,;
									_nEmpenho,;
									_cCtrlLot,;
									_cCtrlEnd})
							
					EndIf
				EndIf 

			EndIf	
		
		EndIf
		
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
			      							 AllTrim(TransForm(_aDados[_nLista][10],"@E 9,999,999.99")),;
			      							 AllTrim(TransForm(_aDados[_nLista][11],"@E 9,999,999.99")),;
											 _aDados[_nLista][12],;
											 _aDados[_nLista][13]}) 


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

Aadd(_aPerg,{"Produtos De  ....?"         ,"mv_ch1","C",20,"G","mv_par01","","","","","","SB1","","",0})
Aadd(_aPerg,{"Produtos Até ....?"         ,"mv_ch2","C",20,"G","mv_par02","","","","","","SB1","","",0})

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

