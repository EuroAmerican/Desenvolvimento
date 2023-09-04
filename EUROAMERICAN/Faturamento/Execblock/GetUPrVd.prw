// #########################################################################################
// Projeto: Euroamerican
// Modulo : FAT
// Fonte  : U_GetUPrVd.prw
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor Emerson Paiva            | Descricao Consulta Ult Preco Venda para Orçam
// ---------+-------------------+-----------------------------------------------------------
// 14/12/15 | TOTVS Developer Studio /| Uso em gatilhos CK_PRODUTO (Itens Orçamento)
// ---------+-------------------+-----/------------------------------------------------------

#include "rwmake.ch"
#include "topconn.ch"
#include "TOTVS.CH" //MsDialog
#define ENTER chr(13) + chr(10)

//------------------------------------------------------------------------------------------
user function GetUPrVd(cCli, cCLj, cPro, cOpc)

Local aArea    := GetArea()
Local cCliente := cCli
//Local cCliLoja := cCLj
Local cProduto := cPro
Local cOpcao   := cOpc //D = Dt Ult Venda or V = Valor Ultima Venda para o Cliente
Local dUltVnda := ''
Local nUltPrec := 0

// Cria diálogo para teste
//Local oDlg := MSDialog():New(180,180,550,700,'Teste MSDialog',,,,,CLR_BLACK,CLR_WHITE,,,.T.)

	cQry := " SELECT	 D2_EMISSAO AS ULTVENDA, D2_PRCVEN AS ULTPRE " + ENTER
	cQry += " FROM	" + RetSqlName("SD2") + " SD2 " + ENTER
	cQry += " WHERE	SD2.D_E_L_E_T_ <> '*' AND " + ENTER
	cQry += " 		SD2.D2_CLIENTE = '" + cCliente + "' AND " + ENTER
	cQry += " 		SD2.D2_LOJA = '" + cCLj + "' AND " + ENTER

	//If cEmpAnt + cFilAnt $"0803" - Grupo Empresa (CG) 31.08.20

	//If AllTrim(cFilAnt) $ "0803"
	//	cQry += " 		SD2.D2_FILIAL IN  ('01','03')  AND " + ENTER
	//Else
		cQry += " 		SD2.D2_FILIAL =  '" + xFilial("SD2") + "'  AND " + ENTER
	//EndIf

	cQry += " 		SD2.D2_COD = '" + cProduto + "' AND " + ENTER
	cQry += " 		SD2.R_E_C_N_O_ =  " + ENTER
	cQry += " 			(	SELECT MAX(R_E_C_N_O_) FROM	" + RetSqlName("SD2") + " SD2_1 " + ENTER
	cQry += " 				WHERE	SD2_1.D_E_L_E_T_ <> '*' AND " + ENTER
	cQry += " 						SD2_1.D2_CLIENTE = '" + cCliente + "' AND " + ENTER
	cQry += " 						SD2_1.D2_LOJA = '" + cCLj + "' AND " + ENTER
	cQry += " 						SD2_1.D2_FILIAL = '" + xFilial("SD2") + "' AND " + ENTER
	cQry += " 						SD2_1.D2_COD = '" + cProduto + "' ) "
	
	If Select("QRYC") > 0
		QRYC->(dbCloseArea())
	EndIf                   
	
	TCQUERY cQry NEW ALIAS QRYC
	
	dUltVnda := StoD(QRYC->ULTVENDA)
	nUltPrec := QRYC->ULTPRE

	QRYC->(dbCloseArea())

	// Ativa diálogo centralizado
	//oDlg:Activate(,,,.T.,{||msgstop(dUltVnda),.T.},,{||msgstop(nUltPrec+chr(133))} ) 

	RestArea(aArea)

	If cOpcao == 'D'
		return dUltVnda
	EndIf

return(nUltPrec)
//--< fim de arquivo >----------------------------------------------------------------------


