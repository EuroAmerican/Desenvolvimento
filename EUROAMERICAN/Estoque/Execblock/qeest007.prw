#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"  

#define ENTER chr(13) + chr(10)

//-----------------------------------------------------------
/*/{Protheus.doc} QEEST007
Roatina pra tratamento referente ao estoque 07
@author Fabio Carneiro dos Santos
@since 06/03/2021
@version 1.0
@type Function
@History Ajustado o fonte para considerar o produto generico 1000.000.30
@since 11/06/2021
@author Fabio Carneiro dos Santos

/*/
//-----------------------------------------------------------
User Function QEEST007()

	Local aSays    := {}
	Local aButtons := {}
	Local nOpca    := 0
	Local cTitoDlg := "Manutenção no Estoque 07 - Grupo Euroamerican "

	Private arotina    := {}   
	Private cMark      :="ok" //GetMark()
    Private _cPerg     := "QEEST07"
	Private _lReturn   := .F.

	#IFDEF TOP
		IF !fDigSenha()
			Return
		Endif
	#ELSE
		MsgStop("Essa rotina funciona somente no ambiente TOP.")
		Return
	#ENDIF

	// Prepara e executa a pergunta do relatorio

	aAdd(aSays, "Esta rotina ira baixar os saldos do armazen 07 e gerar com 75% do custo no armazen Q7")
    aAdd(aSays, "*** Necessario Executar o Recalculo do Custo Medio Antes de Executar Esta Rotina ***")
	aAdd(aSays, "Somente para produtos que controlam Lote e Endereço!")
	aAdd(aSays, "Caso o produto esteja Empenhado,Bloqueado,saldo a endereçar,")
	aAdd(aSays, "e/ou o lote esteja com vencimento menor que a data base.")
	aAdd(aSays, "Não será realizado a baixa, necessario acertar antes!")
	aAdd(aSays, "Caso o produto esteja com custo zerado não será baixado, necessario valorar antes!")

	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
		
    If nOpca == 1
	
		oAjustaSx1()

		If !Pergunte(_cPerg,.T.)
			Return
		Else 
			Processa({|| U_QEEST009("Gerando dados em Tela...")})
		Endif
		
	EndIf

Return

/*
+------------+------------+--------+---------------+-------+--------------+
| Programa:  | QEEST007st | Autor: | QUALY         | Data: | 03/03/21     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEEST007st                                   |
+------------+------------------------------------------------------------+
*/

User function QEEST009()

	Local aCampos   as array
	Local aDados    as array

	Local _astru:={}
	Local _afields:={}
	Local _carq             
	Local oMark
	Local oDlg
	Local aSay    := {}
	Local aButton := {}
	Local nOpcao  := 0
	Local aCores  := {} 
	Local cQuery   := ""

	Local cQueryA   := ""
	Local cQueryB   := ""
	Local cQueryC   := ""
	Local cQueryD   := ""
	Local cQueryF   := ""
	Local lPassaA   := .T.
	Local lPassaB   := .T.
	Local lPassaC   := .T.
	Local lPassaD   := .T.
	Local lPassaF   := .T.
	
	Local cArqDst   := "C:\TOTVS\QEEST007_EMP_" + SM0->M0_CODIGO + "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel    := FWMsExcelEX():New()
	Local cNomPla   := "Empresa_1" + Rtrim(SM0->M0_NOME)
	Local cTitPla   := "Listagem de produtos com lote no armazem 07 "
	Local cNomWrk   := "Empresa_1" + Rtrim(SM0->M0_NOME)
	Local lAbre     := .F.
	Local aPlanilha := {} 
	Local nPlan     := 0 
	
	Private TRB1    := GetNextAlias()
	Private TRB2    := GetNextAlias()
	Private TRB3    := GetNextAlias()
		
	aCampos   := {} 

	aAdd( aRotina ,{"Marcar"         ,"u_QeMarcar()" ,0,3})
	aAdd( aRotina ,{"Desmarcar"      ,"u_QeDesMar()" ,0,2}) 
	aAdd( aRotina ,{"Inverter"       ,"u_QeMakAll()",0,4})
	aAdd( aRotina ,{"Gerar Acerto"   ,"u_QeGerAll()",0,5})
    		
	cCadastro := "Manutenção no Estoque 07 - Grupo Euroamerican "
	
	MakeDir("C:\TOTVS")

	If MV_PAR04 = 1

		Aadd(_astru,{"OK"          ,"C",02})
		Aadd(_astru,{"FILIAL"      ,"C",04})
		Aadd(_astru,{"CODIGO"      ,"C",15})
		Aadd(_astru,{"DESCRICAO"   ,"C",30})
		Aadd(_astru,{"TIPO"        ,"C",02})
		Aadd(_astru,{"UM"          ,"C",02})
		Aadd(_astru,{"LOCAL"       ,"C",02})
		Aadd(_astru,{"LOTE"        ,"C",10})
		Aadd(_astru,{"DTLOTE"      ,"C",10})
		Aadd(_astru,{"LOCALIZ"     ,"C",15})
		Aadd(_astru,{"GENERICO"    ,"C",15})
		Aadd(_astru,{"QTDEST"      ,"N",16,4})
		Aadd(_astru,{"QTDEMP"      ,"N",16,4})
		Aadd(_astru,{"VLCUSTO"     ,"N",16,4})

		_carq:="T_"+Criatrab(,.F.)
		MsCreate(_carq,_astru,"DBFCDX")
		Sleep(1000)
		// atribui a tabela temporária ao alias TRB
		dbUseArea(.T.,"DBFCDX",_cARq,"TRB",.T.,.F.)
		
		IndRegua("TRB", _cArq, "FILIAL+CODIGO+LOCAL+LOTE+LOCALIZ",,, "Indexando ....")
		
		aCores := {}

		aAdd(aCores,{"TRB->OK == 'ok'","BR_VERDE"	})
		aAdd(aCores,{"TRB->OK <> 'ok'","BR_VERMELHO"})
		aAdd(aCores,{"TRB->OK == 'ev'","BR_LARANJA"	})

		Aadd(_afields,{ "OK"        ,"", "Mark"             ,"@X"})
		Aadd(_afields,{ "FILIAL"    ,"", "Filial"           ,"@X"})
		Aadd(_afields,{ "CODIGO"    ,"", "Codigo Produto"   ,"@X"})
		Aadd(_afields,{ "DESCRICAO" ,"", "Desc. Produto"    ,"@X"})
		Aadd(_afields,{ "TIPO"      ,"", "Tipo"             ,"@X"})
		Aadd(_afields,{ "UM"        ,"", "Un. Medida"       ,"@X"})
		Aadd(_afields,{ "LOCAL"     ,"", "Armazen"          ,"@X"})
		Aadd(_afields,{ "LOTE"      ,"", "Lote"             ,"@X"})
		Aadd(_afields,{ "DTLOTE"    ,"", "Dta Lote"         ,"@X"})
		Aadd(_afields,{ "LOCALIZ"   ,"", "Endereço"         ,"@X"})
		Aadd(_afields,{ "GENERICO"  ,"", "Codigo Generico"  ,"@X"})
		Aadd(_afields,{ "QTDEST"    ,"", "Quant. Estoque"   ,"@E 999,999,999.9999"})
		Aadd(_afields,{ "QTDEMP"    ,"", "Quant. Empenho"   ,"@E 999,999,999.9999"})
		Aadd(_afields,{ "VLCUSTO"   ,"", "Valor Custo"      ,"@E 999,999,999.9999"})

	EndIf 
	
	If MV_PAR04 = 2

		oExcel:AddworkSheet(cNomWrk)
		oExcel:AddTable(cNomPla, cTitPla)
		oExcel:AddColumn(cNomPla, cTitPla, "Empresa"    , 1, 1, .F.)  //01
		oExcel:AddColumn(cNomPla, cTitPla, "Filial "    , 1, 1, .F.)  //02
		oExcel:AddColumn(cNomPla, cTitPla, "Codigo"     , 1, 1, .F.)  //03
		oExcel:AddColumn(cNomPla, cTitPla, "Descricao"  , 1, 1, .F.)  //04
		oExcel:AddColumn(cNomPla, cTitPla, "Tipo"       , 1, 1, .F.)  //05
		oExcel:AddColumn(cNomPla, cTitPla, "UM"         , 1, 1, .F.)  //06
		oExcel:AddColumn(cNomPla, cTitPla, "Armazen"    , 1, 1, .F.)  //07
		oExcel:AddColumn(cNomPla, cTitPla, "Lote"       , 1, 1, .F.)  //08
		oExcel:AddColumn(cNomPla, cTitPla, "Validade do Lote" , 1, 1, .F.)  //09
		oExcel:AddColumn(cNomPla, cTitPla, "Endereço"         , 1, 1, .F.)  //10
		oExcel:AddColumn(cNomPla, cTitPla, "Codigo Generico"  , 1, 1, .F.)  //11
		oExcel:AddColumn(cNomPla, cTitPla, "Saldo Empenhado"  , 3, 2, .F.)  //12
		oExcel:AddColumn(cNomPla, cTitPla, "Saldo em Estoque" , 3, 2, .F.)  //13
		oExcel:AddColumn(cNomPla, cTitPla, "Vl. Custo Medio"  , 3, 2, .F.)  //14
	
	EndIf 

	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf
	
	cQuery  := "SELECT '" + Rtrim(SM0->M0_NOME) + "' AS EMP, BF_FILIAL, BF_PRODUTO, B1_DESC, B1_TIPO, B1_UM, BF_LOCAL, BF_LOCALIZ, " + ENTER
	cQuery  += " B8_LOTECTL, B8_DATA, B8_DTVALID, BF_QUANT, BF_EMPENHO ,B2_VATU1, B1_XCODGEN, B2_CM1 " + ENTER
	cQuery  += " FROM " + RetSqlName("SB8") + " AS SB8 " + ENTER
	cQuery  += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_COD = B8_PRODUTO " + ENTER
	cQuery  += " AND SB8.D_E_L_E_T_ = ' '  " + ENTER
	cQuery  += " AND SB1.D_E_L_E_T_ = ' '  " + ENTER
	cQuery  += "INNER JOIN " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) ON B2_COD = B8_PRODUTO  " + ENTER
	cQuery  += " AND SB2.D_E_L_E_T_ = ' '  " + ENTER
	cQuery  += " AND SB8.B8_FILIAL = SB2.B2_FILIAL " + ENTER
	cQuery  += " AND SB8.B8_LOCAL  = SB2.B2_LOCAL   " + ENTER
	cQuery  += "INNER JOIN " + RetSqlName("SBF") + " AS SBF WITH (NOLOCK) ON B2_COD = BF_PRODUTO  " + ENTER
	cQuery  += " AND SBF.D_E_L_E_T_ = ' '   " + ENTER
	cQuery  += " AND SBF.BF_FILIAL  = SB2.B2_FILIAL  " + ENTER
	cQuery  += " AND SBF.BF_LOCAL   = SB2.B2_LOCAL   " + ENTER
	cQuery  += " AND SBF.BF_LOTECTL = B8_LOTECTL     " + ENTER
	cQuery  += "WHERE SB8.B8_PRODUTO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+ ENTER
	If MV_PAR04 = 2
		cQuery  += "  AND SB8.B8_DTVALID >= '19800101' " + ENTER
	ElseIf MV_PAR04 = 1
		cQuery  += "  AND SB8.B8_DTVALID >= '"+DtoS(dDataBase)+"' " + ENTER
	EndIf 
	cQuery  += "  AND SB1.B1_MSBLQL = '2' " + ENTER
	cQuery  += "  AND SB1.B1_TIPO = 'PA'  " + ENTER
	cQuery  += "  AND SB8.D_E_L_E_T_ = ' ' " + ENTER
	cQuery  += "  AND SB1.D_E_L_E_T_ = ' ' " + ENTER
	cQuery  += "  AND SBF.D_E_L_E_T_ = ' ' " + ENTER
	cQuery  += "  AND SBF.BF_QUANT > 0 " + ENTER
	cQuery  += "  AND SB8.B8_SALDO > 0 " + ENTER
	cQuery  += "  AND SB2.B2_QATU > 0  " + ENTER
	cQuery  += "  AND SB8.B8_LOCAL = '07' " + ENTER
	cQuery  += "  AND SB2.B2_LOCAL = '07' " + ENTER
	cQuery  += "  AND SBF.BF_LOCAL = '07' " + ENTER
	cQuery  += "  AND SB2.B2_FILIAL = '"+xFilial("SB2")+"' " + ENTER
	cQuery  += "  AND SBF.BF_FILIAL = '"+xFilial("SBF")+"' " + ENTER
	cQuery  += "  AND SB8.B8_FILIAL = '"+xFilial("SB8")+"' " + ENTER
	cQuery  += "GROUP BY BF_FILIAL, BF_PRODUTO, B1_DESC, B1_TIPO, BF_LOCAL, B1_UM, BF_LOCALIZ, " + ENTER
	cQuery  += "B8_LOTECTL, B8_DATA, B8_DTVALID, BF_QUANT,BF_EMPENHO , B2_VATU1, B1_XCODGEN, B2_CM1 " + ENTER
	
	TcQuery cQuery ALIAS "TRB1" NEW
	
	TRB1->(DbGoTop())

	ProcRegua(TRB1->(LastRec()))

	While TRB1->(!Eof())

		lPassaA := .T.
		lPassaB := .T.
		lPassaC := .T.
		lPassaD := .T.
		lPassaE := .T.
		lPassaF := .T.
		
		If Select("TRB2") > 0
			TRB2->(DbCloseArea())
		EndIf

		cQueryA  := "SELECT D4_FILIAL, D4_PRODUTO, B1_DESC, B1_TIPO,D4_LOCAL, B1_UM, D4_LOTECTL, D4_QTDEORI, D4_QUANT, D4_OP, D4_DATA  " + ENTER
		cQueryA  += " FROM " + RetSqlName("SD4") + " AS SD4   " + ENTER
		cQueryA  += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_COD = D4_PRODUTO 
   		cQueryA  += "AND SD4.D_E_L_E_T_ = ' ' 
   		cQueryA  += "AND SB1.D_E_L_E_T_ = ' ' 
		cQueryA  += " WHERE D4_COD = '"+TRB1->BF_PRODUTO+"' " + ENTER
		cQueryA  += " AND D4_QUANT > 0  " + ENTER
		cQueryA  += " AND D4_LOCAL   = '"+TRB1->BF_LOCAL+"'  " + ENTER
		cQueryA  += " AND D4_FILIAL = '"+xFilial("SD4")+"' " + ENTER
		cQueryA  += " AND SD4.D_E_L_E_T_ = ' '  " + ENTER
		
		TcQuery cQueryA ALIAS "TRB2" NEW
	
		TRB2->(DbGoTop())
	
		If Select("TRB3") > 0
			TRB3->(DbCloseArea())
		EndIf

		cQueryB  := "SELECT DA_FILIAL, DA_PRODUTO,B1_DESC, B1_TIPO, DA_LOCAL, B1_UM, DA_LOTECTL, DA_QTDORI, DA_SALDO   " + ENTER
		cQueryB  += " FROM " + RetSqlName("SDA") + " AS SDA  " + ENTER
		cQueryB  += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_COD = DA_PRODUTO 
   		cQueryB  += "AND SDA.D_E_L_E_T_ = ' ' 
   		cQueryB  += "AND SB1.D_E_L_E_T_ = ' ' 
		cQueryB  += " WHERE DA_PRODUTO  = '"+TRB1->BF_PRODUTO+"'  " + ENTER
		cQueryB  += " AND DA_SALDO > 0 " + ENTER
		cQueryB  += " AND DA_LOCAL = '"+TRB1->BF_LOCAL+"'  " + ENTER
		cQueryB  += " AND DA_FILIAL = '"+xFilial("SDA")+"' " + ENTER
		cQueryB  += " AND SDA.D_E_L_E_T_ = ' '  " + ENTER

		TcQuery cQueryB ALIAS "TRB3" NEW
	
		TRB3->(DbGoTop())

		If TRB2->D4_QUANT > 0
			lPassaA := .F.
		EndIf 

		If TRB3->DA_SALDO > 0
			lPassaB := .F.
		EndIf 

		If MV_PAR05 = 2 //.And. lPassaA .And. lPassaB
			
			cQueryC  := "UPDATE " + RetSqlName("SB2") + " SET B2_QEMP= 0, B2_QEMP2 = 0  " + ENTER
			cQueryC  += " FROM " + RetSqlName("SB2") + " AS SB2 " + ENTER
			cQueryC  += "WHERE B2_COD  = '"+TRB1->BF_PRODUTO+"'   " + ENTER
			cQueryC  += " AND B2_QATU > 0  " + ENTER
			cQueryC  += " AND B2_LOCAL  = '"+TRB1->BF_LOCAL+"'  " + ENTER
			cQueryC  += " AND B2_FILIAL = '"+xFilial("SB2")+"' " + ENTER
			cQueryC  += " AND SB2.D_E_L_E_T_ = ' '  " + ENTER

			TCSqlExec( cQueryC )
			
			cQueryD  := "UPDATE " + RetSqlName("SB8") + " SET B8_EMPENHO = 0, B8_EMPENH2 = 0   " + ENTER
			cQueryD  += " FROM " + RetSqlName("SB8") + " AS SB8 " + ENTER
			cQueryD  += "WHERE B8_PRODUTO = '"+TRB1->BF_PRODUTO+"'   " + ENTER
			cQueryD  += " AND B8_SALDO > 0  " + ENTER
			cQueryD  += " AND B8_LOCAL  = '"+TRB1->BF_LOCAL+"'  " + ENTER
			cQueryD  += " AND B8_FILIAL = '"+xFilial("SB8")+"' " + ENTER
			cQueryD  += " AND SB8.D_E_L_E_T_ = ' '  " + ENTER

			TCSqlExec( cQueryD )

			cQueryF  := "UPDATE " + RetSqlName("SBF") + " SET BF_EMPENHO = 0, BF_EMPEN2 = 0   " + ENTER
			cQueryF  += " FROM " + RetSqlName("SBF") + " AS SBF " + ENTER
			cQueryF  += "WHERE BF_PRODUTO = '"+TRB1->BF_PRODUTO+"'   " + ENTER
			cQueryF  += " AND BF_QUANT > 0  " + ENTER
			cQueryF  += " AND BF_LOCAL  = '"+TRB1->BF_LOCAL+"'  " + ENTER
			cQueryF  += " AND BF_FILIAL = '"+xFilial("SB8")+"' " + ENTER
			cQueryF  += " AND SBF.D_E_L_E_T_ = ' '  " + ENTER

			TCSqlExec( cQueryF )

		EndIf 
		
		dDataVld := Substr(TRB1->B8_DTVALID,7,2)+"/"+Substr(TRB1->B8_DTVALID,5,2)+"/"+Substr(TRB1->B8_DTVALID,1,4)

		// Array para montagem da tela 

		If MV_PAR04 = 1 

			DbSelectArea("TRB")        
			
			RecLock("TRB",.T.)   
			
				TRB->OK        := " "
				TRB->FILIAL    := TRB1->BF_FILIAL
				TRB->CODIGO    := TRB1->BF_PRODUTO
				TRB->DESCRICAO := TRB1->B1_DESC
				TRB->TIPO      := TRB1->B1_TIPO
				TRB->UM	   	   := TRB1->B1_UM
				TRB->LOCAL	   := TRB1->BF_LOCAL
				TRB->LOTE	   := TRB1->B8_LOTECTL
				TRB->DTLOTE	   := dDataVld
				TRB->LOCALIZ   := TRB1->BF_LOCALIZ
				TRB->GENERICO  := TRB1->B1_XCODGEN
				TRB->QTDEST    := TRB1->BF_QUANT
				TRB->QTDEMP	   := TRB1->BF_EMPENHO
				TRB->VLCUSTO   := (TRB1->BF_QUANT*TRB1->B2_CM1)

			TRB->(Msunlock()) 	

		EndIf 

		If MV_PAR04 = 2

				lAbre := .T.
			
				aAdd(aPlanilha,{TRB1->EMP,;
						TRB1->BF_FILIAL,;
						TRB1->BF_PRODUTO,;
						TRB1->B1_DESC,;
						TRB1->B1_TIPO,;
						TRB1->B1_UM,;
						TRB1->BF_LOCAL,;
						TRB1->B8_LOTECTL,;
						dDataVld,;
						TRB1->BF_LOCALIZ,;
						TRB1->B1_XCODGEN,;
						TRB1->BF_QUANT,;
						TRB1->BF_EMPENHO,;
						TRB1->BF_QUANT*TRB1->B2_CM1})   
							
		EndIf 

		TRB1->(DbSkip())

		IncProc("Gerando arquivo...")

	EndDo

	If MV_PAR04 = 2

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
											aPlanilha[nPlan][14]}) 

		Next nPlan
	
	EndIf 
	
	DbGotop()

	If MV_PAR04 = 1

		MarkBrow( "TRB", "OK",,_afields,, cMark,"u_QeMakAll()",,,,"u_QeMark()",{|| u_QeMakAll()},,,aCores,,,,.F.) 

	EndIf 

	If Select("TRB") > 0
		TRB->(DbCloseArea())
	EndIf
	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf
	If Select("TRB2") > 0
		TRB2->(DbCloseArea())
	EndIf
	If Select("TRB3") > 0
		TRB3->(DbCloseArea())
	EndIf

	If MV_PAR04 = 2

		If lAbre
			oExcel:Activate()
			oExcel:GetXMLFile(cArqDst)
			OPENXML(cArqDst)
			oExcel:DeActivate()
		Else
			MsgInfo("Não existe dados para serem impressos.", "SEM DADOS")
		EndIf 
	
	EndIf

	If mv_par04 == 1
		// apaga a tabela temporário 
		MsErase(_carq+GetDBExtension(),,"DBFCDX") 
	EndIf 

Return()

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
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QeMarcar  | Autor: | QUALY         | Data: | 13/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QeMarcar                                     |
+------------+-----------------------------------------------------------+
*/

User Function QeMarcar()                              

Local oMark := GetMarkBrow()

DbSelectArea("TRB")
DbGotop()
	While !Eof()        
 		If RecLock( "TRB", .F. )                
 			TRB->OK := cMark                
 			MsUnLock()        
 		EndIf        
 	dbSkip()
 	Enddo
 	MarkBRefresh()      
 	// força o posicionamento do browse no primeiro registro
 	oMark:oBrowse:Gotop()
Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QeDesMar  | Autor: | QUALY         | Data: | 13/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QeDesMar                                     |
+------------+-----------------------------------------------------------+
*/
User Function QeDesMar()

Local oMark := GetMarkBrow()

DbSelectArea("TRB")
DbGotop()
	
	While !Eof()        
 		
 		If RecLock( "TRB", .F. )                
 			TRB->OK := SPACE(2)                
 		MsUnLock()        
 		
 		EndIf        
 		
 		dbSkip()
 	
 	Enddo
 
MarkBRefresh()

// força o posicionamento do browse no primeiro registro
 
oMark:oBrowse:Gotop()
 
Return 
 
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QeMark    | Autor: | QUALY         | Data: | 13/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QeMark                                       |
+------------+-----------------------------------------------------------+
*/
User Function QeMark()
	
	If IsMark( "OK", cMark )        
		RecLock( "TRB", .F. )                
			Replace OK With Space(2)        
		MsUnLock()
	Else        
		RecLock("TRB", .F. )                
			Replace OK With cMark        
		MsUnLock()
	EndIf
Return 

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QeMakAll  | Autor: | QUALY         | Data: | 13/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QeMakAll                                     |
+------------+-----------------------------------------------------------+
*/
 
User Function QeMakAll()   

Local oMark := GetMarkBrow()

dbSelectArea("TRB")
dbGotop()
	While !Eof()        
		
		u_QeMark()        
		
		dbSkip()
	End

MarkBRefresh()// força o posicionamento do browse no primeiro registro

oMark:oBrowse:Gotop()

Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QeGerAll  | Autor: | QUALY         | Data: | 13/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QeGerAll                                     |
+------------+-----------------------------------------------------------+
*/
 
User Function QeGerAll()()

	MsAguarde({|lEnd| cGerAll(@lEnd)},"Gerando Requisição Interna Aguarde...","Gerando Requisição Interna",.T.)
	
	DbSelectArea("TRB")

Return

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | cGerAll   | Autor: | QUALY         | Data: | 13/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - cGerAll                                     |
+------------+-----------------------------------------------------------+
*/
Static Function cGerAll(lEnd) 

Local aAreaSB1 	:= SB1->(GetArea()) 
Local aAreaSD3 	:= SD3->(GetArea()) 
Local aAreaSD4 	:= SD4->(GetArea()) 
Local aAreaSB8 	:= SB8->(GetArea()) 
Local aAreaSB2 	:= SB2->(GetArea()) 
Local aAreaSBF 	:= SBF->(GetArea()) 

Local cQueryB9      := ""
Local _cDataVld     := ""

Local _aCab1        := {}
Local _aItem        := {}
Local _aTotItem     := {}
Local _aGen         := {} 

Local _lGen         := .F.
Local _lPassa       := .F.

Local _nGen         := 0 

Private lMsErroAuto := .F.
Private TRBGEN      := GetNextAlias()

DbSelectArea("TRB")
TRB->(dbGoTop())

While TRB->(!Eof())  
	
	_cDataVld := Substr(TRB->DTLOTE,1,2)+"/"+Substr(TRB->DTLOTE,4,2)+"/"+Substr(TRB->DTLOTE,9,2)

	If IsMark( "OK", cMark )
		
		If Select("TRB9") > 0
			TRB9->(DbCloseArea())
		EndIf

		cQueryB9  := "SELECT B9_COD, B9_LOCAL   " + ENTER
		cQueryB9  += " FROM " + RetSqlName("SB9") + " AS SB9  " + ENTER
		cQueryB9  += " WHERE B9_FILIAL = '"+xFilial("SB9")+"'   " + ENTER
		cQueryB9  += " AND B9_COD = '"+Alltrim(TRB->GENERICO)+"' " + ENTER
		cQueryB9  += " AND B9_LOCAL = 'Q7'  " + ENTER
		cQueryB9  += " AND SB9.D_E_L_E_T_ = ' '  " + ENTER

		TcQuery cQueryB9 ALIAS "TRB9" NEW
	
		TRB9->(DbGoTop())
		
		If Empty(TRB9->B9_COD) 
			aviso("Atenção!","Este produto  "+Alltrim(TRB->GENERICO)+"  necessita ser criado estoque inicial para permitir a movimentação",{"OK"})
			TRB9->(DbCloseArea())
			EXIT
		EndIf 
		
		If Empty(Posicione("SB1",1,xFilial("SB1")+"1000.000."+Substr(TRB->CODIGO,10,2)+"","B1_COD")) 
			aviso("Atenção!","Este produto  "+"1000.000."+Substr(TRB->CODIGO,10,2)+""+" não esta cadastrado como generico, necessita realizar o cadstro para permitir a movimentação",{"OK"})
			EXIT
		EndIf

		If Empty(TRB->GENERICO) 
			aviso("Atenção!","Este produto  "+Alltrim(TRB->CODIGO)+"  não possui codigo generico amarrado com o codigo "+"1000.000."+Substr(TRB->CODIGO,10,2)+""+", necessita ser regularizado para permitir a movimentação",{"OK"})
			EXIT
		EndIf 

		If AllTrim(Posicione("SB1",1,xFilial("SB1")+"1000.000."+Substr(TRB->CODIGO,10,2)+"","B1_COD")) == AllTrim(TRB->GENERICO)
			_lPassa := .T. 
		Else 
			aviso("Atenção!","No produto  "+Alltrim(TRB->CODIGO)+", deve ser realizado a amarração com o codigo "+Alltrim(Posicione("SB1",1,xFilial("SB1")+"1000.000."+Substr(TRB->CODIGO,10,2)+"","B1_COD"))+", atualmente está com o codigo "+AllTrim(TRB->GENERICO)+", necessario acertar! ",{"OK"})
			EXIT
		EndIf	 

		If Substr(TRB->GENERICO,10,2) == Substr(TRB->CODIGO,10,2) .And. _lPassa 

			aAdd(_aGen,{TRB->FILIAL,;    // 01
						TRB->CODIGO,;    // 02 
						TRB->DESCRICAO,; // 03
						TRB->TIPO,;      // 04 
						TRB->UM,;	     // 05   
						TRB->LOCAL,;	 // 06 
						TRB->LOTE,;	     // 07 
						_cDataVld,;	     // 08    
						TRB->LOCALIZ,;   // 09
						Alltrim(Alltrim(TRB->GENERICO)),;  // 10
						TRB->QTDEST,;    // 11 
						TRB->QTDEMP,;	 // 12  
						TRB->VLCUSTO})   // 13 
		
			_lGen         := .T.
		
		EndIf		
	
	EndIf

	ProcessMessage()

	DbSelectArea("TRB")
	
	TRB->(dbSkip()) 

EndDo

// Tratamento para baixa com movimento interno 
dbSelectArea("SD3")
dbSetOrder(1) 

If Len(_aGen) > 0

	If _lGen

		For _nGen:=1 To Len(_aGen)	

			_aCab1      := {}
			_aItem      := {}
			_aTotItem   := {}
			lMsErroAuto := .F.
		
			_aCab1 := { {"D3_TM"		, "806"					, NIL},;
						{"D3_EMISSAO"	, ddatabase				, NIL}}
			
			
			_aItem := { {"D3_COD" 		, _aGen[_nGen][02]	,NIL},;
						{"D3_UM" 		, _aGen[_nGen][05]	,NIL},; 
						{"D3_QUANT"		, _aGen[_nGen][11]	,NIL},;
						{"D3_LOCAL"		, _aGen[_nGen][06]	,NIL},;
						{"D3_LOTECTL"	, _aGen[_nGen][07]	,NIL},;
						{"D3_LOCALIZ"   , _aGen[_nGen][09]  ,NIL},;
						{"D3_XCODGEN"   , _aGen[_nGen][10]  ,NIL}}
				
			aAdd( _aTotItem, _aitem)
					
			MSExecAuto({|f,g,h| MATA241(f,g,h)}, _aCab1, _aTotItem, 3)

			If lMsErroAuto
				DisarmTransaction()
			EndIf

			If _aGen[_nGen][13] > 0 .And. Alltrim(Posicione("SB1",1,xFilial("SB1")+_aGen[_nGen][10],"B1_COD")) == _aGen[_nGen][10]
			
				_aCab1      := {}
				_aItem      := {}
				_aTotItem   := {}
				lMsErroAuto := .F.
				
				_aCab1 := { {"D3_TM"		, "052"					, NIL},;
							{"D3_EMISSAO"	, ddatabase				, NIL}}
					
				_aItem := { {"D3_COD" 		, _aGen[_nGen][10]    	,NIL},;
							{"D3_QUANT"		, _aGen[_nGen][11]      ,NIL},;
							{"D3_CUSTO1"	, (_aGen[_nGen][13]*75/100) ,NIL},;
							{"D3_LOCAL"		, 'Q7'              	,NIL},;
							{"D3_XCUST25"	, (_aGen[_nGen][13]*25/100) ,NIL},;
							{"D3_XCODGEN"   , _aGen[_nGen][02]      ,NIL}}
						
						aAdd( _aTotItem, _aitem)
							
						MSExecAuto({|f,g,h| MATA241(f,g,h)}, _aCab1, _aTotItem, 3)

						If lMsErroAuto
							DisarmTransaction()
						EndIf

			EndIf 

		Next _nGen	

	EndIf 

EndIf

// Tratamento com movimentação interna de entrada 

SD3->(dbCloseArea())
RestArea(aAreaSB1)
RestArea(aAreaSD3)
RestArea(aAreaSD4)
RestArea(aAreaSB8)
RestArea(aAreaSB2)
RestArea(aAreaSBF)

Return
/*
+------------+------------+--------+---------------+-------+--------------+
| Programa:  | fDigSenha  | Autor: | QUALY         | Data: | 13/02/21     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - Senhas                                        |
+------------+------------------------------------------------------------+
*/
Static Function fDigSenha()
Private cSenha   := Space(10)         
Private cSenhAce := GetMV("QE_SENHA")
@ 067,020 To 169,312 Dialog Senhadlg Title OemToAnsi("Liberação de Acesso")
@ 015,005 Say OemToAnsi("Informe a senha para o acesso ?") Size 80,8
@ 015,089 Get cSenha Size 50,10 Password
@ 037,106 BmpButton Type 1 Action fOK()
@ 037,055 BmpButton Type 2 Action Close(Senhadlg)
Activate Dialog Senhadlg CENTERED
Return(_lReturn)                     

/*
+------------+------------+--------+---------------+-------+--------------+
| Programa:  | fOK()      | Autor: | QUALY         | Data: | 13/02/21     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - Senhas                                        |
+------------+------------------------------------------------------------+
*/
Static Function fOK()

If ALLTRIM(cSenha)<> cSenhAce
   MsgStop("Senha não Confere !!!")
   cSenha  := Space(10)
   dlgRefresh(Senhadlg)
Else
   _lReturn  := .T.
   Close(Senhadlg)
Endif
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

Aadd(_aPerg,{"Produtos De  ....?"        ,"mv_ch1","C",15,"G","mv_par01","","","","","","SB1","","",0})
Aadd(_aPerg,{"Produtos Até ....?"        ,"mv_ch2","C",15,"G","mv_par02","","","","","","SB1","","",0})
Aadd(_aPerg,{"Marca Produtos ..?"        ,"mv_ch3","C",01,"C","mv_par03","Não","Sim","","","",""   ,"","",0})
Aadd(_aPerg,{"Lista Relatorio..?"        ,"mv_ch4","C",01,"C","mv_par04","Não","Sim","","","",""   ,"","",0})
Aadd(_aPerg,{"Ajusta Empenho ..?"        ,"mv_ch5","C",01,"C","mv_par05","Não","Sim","","","",""   ,"","",0})

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



