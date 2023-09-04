#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwprintsetup.ch'
#include 'rptdef.ch'
#include 'totvs.ch'
#Include "Topconn.ch" 
#Include "Tbiconn.ch"

#define ENTER chr(13) + chr(10)
#define CRLF  chr(13) + chr(10)

/*/{Protheus.doc} QEFAT005 - Relatorio referente ao separação por pedido de vendas e orden de separação
@author FABIO CARNEIRO DOS sANTOS 
@since 30/04/2021
@version 1.0
@type function
@History Foi realizado o ajuste o calculo de peso total na separação por pedido em 24/10/2021 - Fabio Carneiro dos Santos 
@History Foi ajustado para não listar quando a carga conter nota fiscal em 19/01/2022 - Fabio Carneiro dos Santos 
@History Foi ajustado o titulo como CARGA DE SEPARAÇÃO 20/01/2022 - Fabio Carneiro dos Santos 
/*/
User Function QEFAT005()

	Local aSays    := {}
	Local aButtons := {}
	Local nOpca    := 0
	Local cTitoDlg := "Listagem de serparação pedido de vendas"
	Private _cPerg := "QEFTR05"

	// Prepara e executa a pergunta do relatorio

	aAdd(aSays, "Este relatorio lista volume do pedido de vendas")
	aAdd(aSays, "Ira listar conforme layout existente para nota fiscal")
	aAdd(aSays, "Caso o usuário deseje alterar o pedido de vendas, será necessario excluir da carga")
	aAdd(aSays, "Ira listar o volume e peso bruto por pedido de vendas")

	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)

	If nOpca == 1
	
		oAjustaSx1()

		If !Pergunte(_cPerg,.T.)
			Return
		Else 
			Processa({|| u_QEFATA05("Gerando relatório...")})
		Endif
		
	EndIf
Return

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEFAT005  | Autor: | QUALY         | Data: | 13/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEFAT005                                     |
+------------+-----------------------------------------------------------+
*/

User Function QEFATA05()

	Local aSays          := {}
	Local aButtons       := {}
	Local aHelpPor       := {}
	Local nOpca          := 0
	Local nPassa         := 0 
	Local _cMensagem     := ""
	Local _lLibera       := .F.
	Local cTitoDlg       := "Romaneio de Expedição p/ pedido de vendas- ESPELHO"

	Local cQuery         := "" 	// Tratamento para os Itens do relatorio 
	Local cQueryC        := ""
	Local cQueryP        := ""
	Local cQueryW        := ""
	Local _nY            := 0
	Local _nW            := 0
	Local i              := 0
	Local iW             := 0

	Private _cPedido     := ""
	Private _cOrdSep     := ""
	Private _cItem       := 0
	Private _aPedido     := {}
	
	Private _cPedidoW    := ""
	Private _cOrdSepW    := ""
	Private _cItemW      := 0

	Private aVolumes     := Array(80, 2)
	Private aPesos       := Array(2)

	Private aVolumesW    := Array(80, 2)
	Private aPesosW      := Array(2)

	Private i            := 0
	Private k            := 1
	Private nVal         := 0
	Private nTotal       := 0
	Private nValFd		 := 0	
	Private _nTotal      := 0

	Private lAtVol       := EQVldAlt(1) //.T.
	Private lAtPes       := EQVldAlt(2) //.T.

	Private iW           := 0
	Private kW           := 1
	Private nValW        := 0
	Private nTotalW      := 0
	Private _nTotalW     := 0
	Private nValFdW 	 := 0
	Private nValW        := 0

	Private lAtVolW      := EQVldAlt(1) //.T.
	Private lAtPesW      := EQVldAlt(2) //.T.
		
	Private _cESPECI1    := ""
	Private _nVOLUME1    := 0
	Private _cESPECI2    := ""
	Private _nVOLUME2    := 0
	Private _cESPECI3    := ""
	Private _nVOLUME3    := 0
	Private _cESPECI4    := ""
	Private _nVOLUME4    := 0
	Private	_cESPECI5    := ""
	Private	_nVOLUME5    := 0
	Private	_cESPECI6    := ""
	Private	_nVOLUME6    := 0
	Private	_cESPECI7    := ""
	Private _nVOLUME7    := 0
	Private	_cESPECI8    := ""
	Private	_nVOLUME8    := 0
	Private	_cESPECI9    := ""
	Private	_nVOLUME9    := 0
	Private	_cESPECI10   := ""
	Private	_nVOLUME10   := 0
	Private	_cESPECI11   := ""
	Private	_nVOLUME11   := 0
	Private	_cESPECI12   := ""
	Private	_nVOLUME12   := 0
	Private	_cESPECI13   := ""
	Private	_nVOLUME13   := 0
	Private	_cESPECI14   := ""
	Private	_nVOLUME14   := 0
	Private	_cESPECI15   := ""
	Private	_nVOLUME15   := 0
	Private	_cESPECI16   := ""
	Private	_nVOLUME16   := 0
	Private	_cESPECI17   := ""
	Private	_nVOLUME17   := 0
	Private	_cESPECI18   := ""
	Private	_nVOLUME18   := 0
	Private	_cESPECI19   := ""
	Private	_nVOLUME19   := 0
	Private	_cESPECI20   := ""
	Private	_nVOLUME20   := 0
	Private	_cESPECI20   := ""
	Private	_nVOLUME20   := 0
	Private	_cESPECI21   := ""
	Private	_nVOLUME21   := 0
	Private	_cESPECI22   := ""
	Private	_nVOLUME22   := 0
	Private	_cESPECI23   := ""
	Private	_nVOLUME23   := 0
	Private	_cESPECI24   := ""
	Private	_nVOLUME24   := 0
	Private	_cESPECI25   := ""
	Private	_nVOLUME25   := 0
	Private	_cESPECI26   := ""
	Private	_nVOLUME26   := 0
	Private	_cESPECI27   := ""
	Private	_nVOLUME27   := 0
	Private	_cESPECI28   := ""
	Private	_nVOLUME28   := 0
	Private	_cESPECI29   := ""
	Private	_nVOLUME29   := 0
	Private	_cESPECI30   := ""
	Private	_nVOLUME30   := 0
	Private	_cESPECI31   := ""
	Private	_nVOLUME31   := 0
	Private	_cESPECI32   := ""
	Private	_nVOLUME32   := 0
	Private	_cESPECI33   := ""
	Private	_nVOLUME33   := 0
	Private	_cESPECI34   := ""
	Private	_nVOLUME34   := 0
	Private	_cESPECI35   := ""
	Private	_nVOLUME35   := 0
	Private	_cESPECI36   := ""
	Private	_nVOLUME36   := 0
	Private	_cESPECI37   := ""
	Private	_nVOLUME37   := 0
	Private	_cESPECI38   := ""
	Private	_nVOLUME38   := 0
	Private	_cESPECI39   := ""
	Private	_nVOLUME39   := 0
	Private	_cESPECI40   := ""
	Private	_nVOLUME40   := 0
	Private	_cESPECI41   := ""
	Private	_nVOLUME41   := 0
	Private	_cESPECI42   := ""
	Private	_nVOLUME42   := 0
	Private	_cESPECI43   := ""
	Private	_nVOLUME43   := 0
	Private	_cESPECI44   := ""
	Private	_nVOLUME44   := 0
	Private	_cESPECI45   := ""
	Private	_nVOLUME45   := 0
	Private	_cESPECI46   := ""
	Private	_nVOLUME46   := 0
	Private	_cESPECI47   := ""
	Private	_nVOLUME47   := 0
	Private	_cESPECI48   := ""
	Private	_nVOLUME48   := 0
	Private	_cESPECI49   := ""
	Private	_nVOLUME49   := 0
	Private	_cESPECI50   := ""
	Private	_nVOLUME50   := 0

	Private	_cESPECI51   := ""
	Private	_nVOLUME51   := 0
	Private	_cESPECI52   := ""
	Private	_nVOLUME52   := 0
	Private	_cESPECI53   := ""
	Private	_nVOLUME53   := 0

	Private _cESPECI1W   := ""
	Private _nVOLUME1W   := 0
	Private _cESPECI2W   := ""
	Private _nVOLUME2W   := 0
	Private _cESPECI3W   := ""
	Private _nVOLUME3W   := 0
	Private _cESPECI4W   := ""
	Private _nVOLUME4W   := 0
	Private	_cESPECI6W   := ""
	Private _nVOLUME6W   := 0
	Private _cESPECI7W   := ""
	Private	_nVOLUME7W   := 0
	Private	_cESPECI8W   := ""
	Private	_nVOLUME8W   := 0
	Private	_cESPECI9W   := ""
	Private	_nVOLUME9W   := 0
	Private	_cESPECI10W  := ""
	Private	_nVOLUME10W  := 0
	Private	_cESPECI11W  := ""
	Private	_nVOLUME11W  := 0
	Private	_cESPECI12W  := ""
	Private	_nVOLUME12W  := 0
	Private	_cESPECI13W  := ""
	Private	_nVOLUME13W  := 0
	Private	_cESPECI14W  := ""
	Private	_nVOLUME14W  := 0
	Private	_cESPECI15W  := ""
	Private	_nVOLUME15W  := 0
	Private	_cESPECI16W  := ""
	Private	_nVOLUME16W  := 0
	Private	_cESPECI17W  := ""
	Private	_nVOLUME17W  := 0
	Private	_cESPECI18W  := ""
	Private	_nVOLUME18W  := 0
	Private	_cESPECI19W  := ""
	Private	_nVOLUME19W  := 0
	Private	_cESPECI20W  := ""
	Private	_nVOLUME20W  := 0
	Private	_cESPECI20W  := ""
	Private	_nVOLUME20W  := 0
	Private	_cESPECI21W  := ""
	Private	_nVOLUME21W  := 0
	Private	_cESPECI22W  := ""
	Private	_nVOLUME22W  := 0
	Private	_cESPECI23W  := ""
	Private	_nVOLUME23W  := 0
	Private	_cESPECI24W  := ""
	Private	_nVOLUME24W  := 0
	Private	_cESPECI25W  := ""
	Private	_nVOLUME25W  := 0
	Private	_cESPECI26W  := ""
	Private	_nVOLUME26W  := 0
	Private	_cESPECI27W  := ""
	Private	_nVOLUME27W  := 0
	Private	_cESPECI28W  := ""
	Private	_nVOLUME28W  := 0
	Private	_cESPECI29W  := ""
	Private	_nVOLUME29W  := 0
	Private	_cESPECI30W  := ""
	Private	_nVOLUME30W  := 0
	Private	_cESPECI31W  := ""
	Private	_nVOLUME31W  := 0
	Private	_cESPECI32W  := ""
	Private	_nVOLUME32W  := 0
	Private	_cESPECI33W  := ""
	Private	_nVOLUME33W  := 0
	Private	_cESPECI34W  := ""
	Private	_nVOLUME34W  := 0
	Private	_cESPECI35W  := ""
	Private	_nVOLUME35W  := 0
	Private	_cESPECI36W  := ""
	Private	_nVOLUME36W  := 0
	Private	_cESPECI37W  := ""
	Private	_nVOLUME37W  := 0
	Private	_cESPECI38W  := ""
	Private	_nVOLUME38W  := 0
	Private	_cESPECI39W  := ""
	Private	_nVOLUME39W  := 0
	Private	_cESPECI40W  := ""
	Private	_nVOLUME40W  := 0

	Private	_cESPECI41W  := ""
	Private	_nVOLUME41W  := 0
	Private	_cESPECI42W  := ""
	Private	_nVOLUME42W  := 0
	Private	_cESPECI43W  := ""
	Private	_nVOLUME43W  := 0
	Private	_cESPECI44W  := ""
	Private	_nVOLUME44W  := 0
	Private	_cESPECI45W  := ""
	Private	_nVOLUME45W  := 0
	Private	_cESPECI46W  := ""
	Private	_nVOLUME46W  := 0
	Private	_cESPECI47W  := ""
	Private	_nVOLUME47W  := 0
	Private	_cESPECI48W  := ""
	Private	_nVOLUME48W  := 0
	Private	_cESPECI49W  := ""
	Private	_nVOLUME49W  := 0
	Private	_cESPECI50W  := ""
	Private	_nVOLUME50W  := 0

	Private	_cESPECI51W  := ""
	Private	_nVOLUME51W  := 0
	Private	_cESPECI52W  := ""
	Private	_nVOLUME52W  := 0
	Private	_cESPECI53W  := ""
	Private	_nVOLUME53W  := 0


	Private cFilePDF
	Private nRegSM0      := SM0->(RecNo())

	Private aArea		 := GetArea()

	Private TRB1         := GetNextAlias()
	Private TRB2         := GetNextAlias()

	Private _cFilial     := ""
	Private _cCod        := ""
	Private _cSeqCar     := ""
	Private cVolumes     := "" 
	Private _cCodCarga   := ""
	Private	_cNomeCli    := ""

	Private	_cVeiculo 	 := ""
	Private _dDataCarga	 
	Private	_cTransporte := ""
	Private	_cMotorista  := ""
	Private	_cPedidoVen  := ""
	
	Private _nPESOL      := 0
	private _nPBRUTO     := 0
	Private _nPesoTotal  := 0

	Private _cFilialW    := ""
	Private _cCodW       := ""
	Private _cSeqCarW    := ""
	Private cVolumesW    := "" 

	Private _nPESOLW     := 0
	private _nPBRUTOW    := 0
	Private _nPesoTotalW := 0
	Private _nVlTotalped := 0
	
	Private _nPesBruTotal := 0 
	Private	_nPesLiqTotal := 0 

	Private oFont14      := TFont():New("Arial",,-14,.F.)
	Private oFont14n     := TFont():New("Arial",,-14,.T.)
	Private oFont10      := TFont():New("Courier New",,-10,.F.)
	Private oFont10n     := TFont():New("Courier New",,-10,.T.)

	Private oPrint
	Private nLin         := 0

	Private _cFilNome    := ""

	Private cString      := ""
	
	For i := 1 to Len(aVolumes)
		aVolumes[i, 1] := ""
		aVolumes[i, 2] := 0
	Next i

	For iW := 1 to Len(aVolumesW)
		aVolumesW[iW, 1] := ""
		aVolumesW[iW, 2] := 0
	Next iW

	aPesos[1] := 0
	aPesos[2] := 0

	aPesosW[1] := 0
	aPesosW[2] := 0
	
	SM0->(DbSetOrder(1))
	
	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf

	cQuery := "SELECT DAK_FILIAL, DAK_COD, C5_NUM, CB8_ORDSEP,A1_COD, A1_NOME, B1_COD, B1_UM, B1_SEGUM,  " + ENTER
	cQuery += "A4_COD, A4_NOME, DA3_COD, DA3_PLACA, DA3_MOTORI,B1_PESO, B1_GRUPO, DA3_DESC, DAK_DATA, " + ENTER
	cQuery += "CB8_FILIAL, CB8_PROD, CB8_ITEM, CB8_PEDIDO, CB8_LOCAL, CB8_LOTECT, CB8_QTDORI, "+ ENTER
	cQuery += "B1_PESO, B1_PESBRU, B1_TIPO, B1_CONV, CB7_DTEMIS, CB7_PEDIDO, "+ ENTER
	cQuery += "CB7_PEDIDO, CB7_STATUS,CB7_TRANSP, B1_TIPCONV   "+ ENTER
	cQuery += " FROM  " + RetSqlName("DAK") + " AS DAK " + ENTER
	cQuery += "INNER JOIN " + RetSqlName("DAI") + " AS DAI ON DAI_FILIAL = DAK_FILIAL " + ENTER
	cQuery += " AND DAK_COD = DAI_COD  " + ENTER
	cQuery += " AND DAI.D_E_L_E_T_ = ' '   " + ENTER
	cQuery += "INNER JOIN " + RetSqlName("SA4") + " AS SA4 ON A4_COD = DAK_TRANSP  " + ENTER
	cQuery += " AND SA4.D_E_L_E_T_ = ' ' " + ENTER
	cQuery += "INNER JOIN " + RetSqlName("DA3") + " AS DA3 ON DA3_COD = DAK_CAMINH  " + ENTER
	cQuery += " AND DA3.D_E_L_E_T_ = ' '   " + ENTER
	cQuery += "INNER JOIN " + RetSqlName("DA4") + " AS DA4 ON DA4_COD = DAK_MOTORI  " + ENTER
	cQuery += " AND DA4.D_E_L_E_T_ = ' '  " + ENTER
	cQuery += "INNER JOIN " + RetSqlName("CB8") + " AS CB8 ON CB8_FILIAL = DAI_FILIAL  " + ENTER
	cQuery += " AND CB8_PEDIDO = DAI_PEDIDO  " + ENTER
	cQuery += " AND CB8.D_E_L_E_T_ = ' '  " + ENTER
	cQuery += "INNER JOIN " + RetSqlName("CB7") + " AS CB7 ON CB7_FILIAL = CB8_FILIAL  " + ENTER
	cQuery += " AND CB7_ORDSEP = CB8_ORDSEP  " + ENTER
	cQuery += " AND CB7_NOTA  = ' '  " + ENTER
	cQuery += " AND CB7_SERIE = ' '  " + ENTER
	cQuery += " AND CB7.D_E_L_E_T_ = ' '  " + ENTER
	cQuery += "INNER JOIN " + RetSqlName("SC9") + " AS SC9 ON C9_FILIAL = CB8_FILIAL  " + ENTER
	cQuery += " AND C9_PEDIDO  = CB8_PEDIDO   " + ENTER
	cQuery += " AND C9_PRODUTO = CB8_PROD " + ENTER
	cQuery += " AND C9_LOCAL   = CB8_LOCAL " + ENTER
	cQuery += " AND C9_LOTECTL = CB8_LOTECT " + ENTER
	cQuery += " AND SC9.D_E_L_E_T_ = ' '  " + ENTER
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 ON B1_COD = CB8_PROD  " + ENTER
	cQuery += " AND SB1.D_E_L_E_T_ = ' '   " + ENTER
	cQuery += "INNER JOIN " + RetSqlName("SC5") + " AS SC5 ON C5_FILIAL = CB8_FILIAL  " + ENTER
	cQuery += " AND C5_NUM = CB8_PEDIDO  " + ENTER
	cQuery += " AND SC5.D_E_L_E_T_ = ' ' " + ENTER
	cQuery += "INNER JOIN " + RetSqlName("SA1") + " AS SA1 ON A1_FILIAL = C5_FILIAL   " + ENTER
	cQuery += " AND A1_COD  = C5_CLIENTE  " + ENTER
	cQuery += " AND A1_LOJA = C5_LOJACLI  " + ENTER
	cQuery += "WHERE CB8_FILIAL = '"+xFilial("CB8")+"' " + ENTER
	cQuery += " AND CB8_PEDIDO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  " + ENTER
	cQuery += " AND CB8_ORDSEP BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'  " + ENTER
	cQuery += " AND CB7_DTEMIS BETWEEN '"+DtoS(MV_PAR05)+"' AND '"+DtoS(MV_PAR06)+"' " + ENTER
	cQuery += " AND DAK_COD = '"+MV_PAR07+"' " + ENTER
	cQuery += " AND CB8.D_E_L_E_T_ = ' ' " + ENTER
	cQuery += " GROUP BY DAK_FILIAL, DAK_COD, C5_NUM, CB8_ORDSEP,A1_COD, A1_NOME, B1_COD, B1_UM, B1_SEGUM, " + ENTER 
	cQuery += " A4_COD, A4_NOME, DA3_COD, DA3_PLACA, DA3_MOTORI,B1_PESO, B1_GRUPO, DA3_DESC, DAK_DATA, " + ENTER
	cQuery += " CB8_FILIAL, CB8_PROD, CB8_ITEM, CB8_PEDIDO, CB8_LOCAL, CB8_LOTECT, CB8_QTDORI, " + ENTER
	cQuery += " B1_PESO, B1_PESBRU, B1_TIPO, B1_CONV, CB7_DTEMIS, CB7_PEDIDO, " + ENTER
	cQuery += " CB7_PEDIDO, CB7_STATUS,CB7_TRANSP, B1_TIPCONV " + ENTER
	cQuery += " ORDER BY  CB8_ORDSEP, CB8_ITEM   " + ENTER

	TcQuery cQuery ALIAS "TRB1" NEW

	TRB1->(DbGoTop())

	If Alltrim(cFilAnt) == "0803"
			
		_cFilNome := "Qualy"
			
	ElseIf Alltrim(cFilAnt) == "0200"
			
		_cFilNome := "Euro"
			
	ElseIf Alltrim(cFilAnt) == "0107"
			
		_cFilNome := "Jay"

	ElseIf Alltrim(cFilAnt) == "0901"

		_cFilNome := "Phoenix"

	EndIf

	MontaDir("C:\TEMP\")
	cFilePDF := "QEFAT005_EMP_" + Alltrim(_cFilNome) + "_" + Dtos(dDataBase) + ".PDF"
	fErase("C:\TEMP\" + cFilePDF)
	oPrinter := FWMSPrinter():New(cFilePdf, IMP_PDF, .F., "C:\TEMP\", .T.,,,,,,,.F.,)
	oPrinter:SetPortrait()
	oPrinter:SetPaperSize(9)
	oPrinter:SetDevice(IMP_PDF)
	oPrinter:cPathPDF :="C:\TEMP\"

	// Tratamento para os dadaos da carga doa dados no cabeçalho 
	
	If Select("TRBC") > 0
		TRBC->(DbCloseArea())
	EndIf

	cQueryC := "SELECT * " + ENTER
	cQueryC += "FROM DAK100 AS DAK " + ENTER
	cQueryC += "INNER JOIN DAI100 AS DAI ON DAI_FILIAL = DAK_FILIAL " + ENTER
	cQueryC += "AND DAK_COD = DAI_COD     " + ENTER
	cQueryC += "AND DAI.D_E_L_E_T_ = ' '  " + ENTER
	cQueryC += "WHERE DAK_FILIAL = '"+xFilial("DAK")+"' " + ENTER
	cQueryC += "AND DAK_DATA BETWEEN '"+DtoS(MV_PAR05)+"' AND '"+DtoS(MV_PAR06)+"' " + ENTER
	cQueryC += "AND DAK_COD = '"+MV_PAR07+"' " + ENTER
	cQueryC += "AND DAK.D_E_L_E_T_ = ' '  " + ENTER

	TcQuery cQueryC ALIAS "TRBC" NEW

	TRBC->(DbGoTop())
	
	While TRBC->(!Eof())

		_cFilial     := TRBC->DAK_FILIAL
		_cCodCarga   := TRBC->DAK_COD
		_cSeqCar     := TRBC->DAK_SEQCAR
		_cVeiculo 	 := TRBC->DAK_CAMINH
		_dDataCarga	 := TRBC->DAK_DATA
		_cTransporte := TRBC->DAK_TRANSP
		_cMotorista  := TRBC->DAK_MOTORI
		_cPedidoVen  := TRBC->DAI_PEDIDO

		TRBC->(DbSkip())

	EndDo

	If Empty(_cVeiculo)

		Aviso("Atenção !!!" ,"Obrigatorio informar o Veiculo na Carga "+_cCodCarga ,{"OK"})

		If Select("TRB1") > 0
			TRB1->(DbCloseArea())
		EndIf
		If Select("TRBC") > 0
			TRBC->(DbCloseArea())
		EndIf

		SM0->(DbGoTo(nRegSM0))

		Return

	EndIf

	If Empty(_cMotorista)

		Aviso("Atenção !!!" ,"Obrigatorio informar o Motorista na Carga "+_cCodCarga ,{"OK"})

		If Select("TRB1") > 0
			TRB1->(DbCloseArea())
		EndIf
		If Select("TRBC") > 0
			TRBC->(DbCloseArea())
		EndIf

		SM0->(DbGoTo(nRegSM0))

		Return

	EndIf

	If Empty(_cTransporte)

		Aviso("Atenção !!!" ,"Obrigatorio informar a Transportadora na Carga "+_cCodCarga ,{"OK"})

		If Select("TRB1") > 0
			TRB1->(DbCloseArea())
		EndIf
		If Select("TRBC") > 0
			TRBC->(DbCloseArea())
		EndIf

		SM0->(DbGoTo(nRegSM0))

		Return

	EndIf

	// Tratamento para impressão total dos Volumes no cabeçalho 

	If Select("TRBW") > 0
		TRBW->(DbCloseArea())
	EndIf
	cQueryW := "SELECT DAK_FILIAL, DAK_COD, C5_NUM, CB8_ORDSEP,A1_COD, A1_NOME, B1_COD, B1_UM, B1_SEGUM,  " + ENTER
	cQueryW += "C5_EMISSAO, A4_COD, A4_NOME, DA3_COD, DA3_PLACA, DA3_MOTORI,B1_PESO, B1_GRUPO, DA3_DESC, DAK_DATA, " + ENTER
	cQueryW += "CB8_FILIAL, CB8_PROD, CB8_ITEM, CB8_PEDIDO, CB8_LOCAL, CB8_LOTECT, CB8_QTDORI, C9_PRCVEN, "+ ENTER
	cQueryW += "B1_PESO, B1_PESBRU, C9_BLEST, C9_ITEM, C9_QTDLIB, B1_TIPO, B1_CONV, CB7_DTEMIS, CB7_PEDIDO, "+ ENTER
	cQueryW += "CB7_PEDIDO, CB7_STATUS,CB7_TRANSP, B1_TIPCONV   "+ ENTER
	cQueryW += " FROM  " + RetSqlName("DAK") + " AS DAK " + ENTER
	cQueryW += "INNER JOIN " + RetSqlName("DAI") + " AS DAI ON DAI_FILIAL = DAK_FILIAL " + ENTER
	cQueryW += " AND DAK_COD = DAI_COD  " + ENTER
	cQueryW += " AND DAI.D_E_L_E_T_ = ' '   " + ENTER
	cQueryW += "INNER JOIN " + RetSqlName("SA4") + " AS SA4 ON A4_COD = DAK_TRANSP  " + ENTER
	cQueryW += " AND SA4.D_E_L_E_T_ = ' ' " + ENTER
	cQueryW += "INNER JOIN " + RetSqlName("DA3") + " AS DA3 ON DA3_COD = DAK_CAMINH  " + ENTER
	cQueryW += " AND DA3.D_E_L_E_T_ = ' '   " + ENTER
	cQueryW += "INNER JOIN " + RetSqlName("DA4") + " AS DA4 ON DA4_COD = DAK_MOTORI  " + ENTER
	cQueryW += " AND DA4.D_E_L_E_T_ = ' '  " + ENTER
	cQueryW += "INNER JOIN " + RetSqlName("CB8") + " AS CB8 ON CB8_FILIAL = DAI_FILIAL  " + ENTER
	cQueryW += " AND CB8_PEDIDO = DAI_PEDIDO  " + ENTER
	cQueryW += " AND CB8.D_E_L_E_T_ = ' '  " + ENTER
	cQueryW += "INNER JOIN " + RetSqlName("CB7") + " AS CB7 ON CB7_FILIAL = CB8_FILIAL  " + ENTER
	cQueryW += " AND CB7_ORDSEP = CB8_ORDSEP  " + ENTER
	cQueryW += " AND CB7_NOTA  = ' '  " + ENTER
	cQueryW += " AND CB7_SERIE = ' '  " + ENTER
	cQueryW += " AND CB7.D_E_L_E_T_ = ' '  " + ENTER
	cQueryW += "INNER JOIN " + RetSqlName("SC9") + " AS SC9 ON C9_FILIAL = CB8_FILIAL  " + ENTER
	cQueryW += " AND C9_PEDIDO  = CB8_PEDIDO   " + ENTER
	cQueryW += " AND C9_PRODUTO = CB8_PROD " + ENTER
	cQueryW += " AND C9_LOCAL   = CB8_LOCAL " + ENTER
	cQueryW += " AND C9_LOTECTL = CB8_LOTECT " + ENTER
	cQueryW += " AND SC9.D_E_L_E_T_ = ' '  " + ENTER
	cQueryW += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 ON B1_COD = CB8_PROD  " + ENTER
	cQueryW += " AND SB1.D_E_L_E_T_ = ' '   " + ENTER
	cQueryW += "INNER JOIN " + RetSqlName("SC5") + " AS SC5 ON C5_FILIAL = CB8_FILIAL  " + ENTER
	cQueryW += " AND C5_NUM = CB8_PEDIDO  " + ENTER
	cQueryW += " AND SC5.D_E_L_E_T_ = ' ' " + ENTER
	cQueryW += "INNER JOIN " + RetSqlName("SA1") + " AS SA1 ON A1_FILIAL = C5_FILIAL   " + ENTER
	cQueryW += " AND A1_COD  = C5_CLIENTE  " + ENTER
	cQueryW += " AND A1_LOJA = C5_LOJACLI  " + ENTER
	cQueryW += "WHERE CB8_FILIAL = '"+xFilial("CB8")+"' " + ENTER
	cQueryW += " AND CB8_PEDIDO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  " + ENTER
	cQueryW += " AND CB8_ORDSEP BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'  " + ENTER
	cQueryW += " AND CB7_DTEMIS BETWEEN '"+DtoS(MV_PAR05)+"' AND '"+DtoS(MV_PAR06)+"' " + ENTER
	cQueryW += " AND DAK_COD = '"+MV_PAR07+"' " + ENTER
	cQueryW += " AND CB8.D_E_L_E_T_ = ' ' " + ENTER
	cQueryW += "GROUP BY DAK_FILIAL, DAK_COD, C5_NUM, CB8_ORDSEP,A1_COD, A1_NOME, B1_COD, B1_UM, B1_SEGUM,  " + ENTER
	cQueryW += "C5_EMISSAO, A4_COD, A4_NOME, DA3_COD, DA3_PLACA, DA3_MOTORI,B1_PESO, B1_GRUPO, DA3_DESC, DAK_DATA, " + ENTER
	cQueryW += "CB8_FILIAL, CB8_PROD, CB8_ITEM, CB8_PEDIDO, CB8_LOCAL, CB8_LOTECT, CB8_QTDORI, C9_PRCVEN, "+ ENTER
	cQueryW += "B1_PESO, B1_PESBRU, C9_BLEST, C9_ITEM, C9_QTDLIB, B1_TIPO, B1_CONV, CB7_DTEMIS, CB7_PEDIDO, "+ ENTER
	cQueryW += "CB7_PEDIDO, CB7_STATUS,CB7_TRANSP, B1_TIPCONV   "+ ENTER
	cQueryW += " ORDER BY  CB8_ORDSEP, CB8_ITEM   " + ENTER

	TcQuery cQueryW ALIAS "TRBW" NEW

	//TRBW->(DbGoTop())

	While TRBW->(!Eof())

		_cPedidoW  := TRBW->C5_NUM
		_cOrdSepW  := TRBW->CB8_ORDSEP
		_cCodCarga := TRBW->DAK_COD
		
		nValFdW    := 0
		nValW      := 0
		
		cCampoW    := ""

		cCampoW := Iif((Subs(TRBW->B1_GRUPO, 1, 1) != "3" .And. TRBW->B1_GRUPO != "1300") .And. TRBW->B1_TIPO == "PA", "TRBW->B1_SEGUM", "TRBW->B1_UM")

		nPos0W  := Ascan(aVolumesW, {|x| &cCampoW $ x[1]})

		If AllTrim( TRBW->B1_UM ) == "KG" .And. AllTrim( TRBW->B1_SEGUM ) <> "KG" .And. TRBW->B1_TIPO == "PA" .And. !Empty( TRBW->B1_SEGUM ) .And. TRBW->B1_CONV <> 0
			nValW   := Iif(TRBW->B1_TIPCONV == "D", TRBW->CB8_QTDORI / TRBW->B1_CONV, TRBW->CB8_QTDORI * TRBW->B1_CONV)
		Else
			nValW := Iif((Subs(TRBW->B1_GRUPO, 1, 1) != "3" .And. TRBW->B1_GRUPO != "1300") .And. TRBW->B1_TIPO == "PA",Iif(TRBW->B1_TIPCONV == "D",TRBW->CB8_QTDORI / TRBW->B1_CONV, TRBW->CB8_QTDORI * TRBW->B1_CONV), TRBW->CB8_QTDORI)
		EndIf

		If Subs(TRBW->B1_GRUPO, 1, 1) $ "3/4" .And. TRBW->B1_UM $ "GL#PT"
			If Subs(AllTrim(TRBW->B1_COD), -2) == "06" .Or. SubStr(AllTrim(TRBW->B1_COD),1,8) $ ("7770.909/7770.910") // tratamento caixa somente para o alcool - 14/04/2021 
				nPos1W := Ascan(aVolumesW, {|x| "CX" $ x[1]})
			Else
				nPos1W := Ascan(aVolumesW, {|x| "FD" $ x[1]})
			EndIf

			If &cCampoW == "GL"
				nValFdW := ((nValW - (nValW % 4)))/4
				nValW   := nValW % 4
			ElseIf &cCampoW == "PT"
				If Subs(AllTrim(TRBW->B1_COD), -2) $ "02|06"
					nValFdW := ((nValW - (nValW % 12)))/12
					nValW   := nValW % 12
				Else  
					nValFdW := ((nValW - (nValW % 6)))/6
					nValW   := nValW % 6
				EndIf
			EndIf
					
			If nValFdW > 0
				If nPos1W == 0
					aVolumesW[kW, 1]     := If(Subs(AllTrim(TRBW->B1_COD), -2) == "06", "CX", "FD")
					aVolumesW[kW, 2]     := nValFdW
					kW++
				Else
					aVolumesW[nPos1W, 2] += nValFdW
				EndIf

			EndIf
					
			If nValW > 0

				If nPos0W == 0
					aVolumesW[kW, 1]     := &(cCampoW)
					aVolumesW[kW, 2]     := nValW
					kW++
				Else
					aVolumesW[nPos0W, 2] += nValW
				EndIf
					
			EndIf

		Else 
				
			If nValW > 0
				If nPos0W == 0
					aVolumesW[kW, 1]     := &(cCampoW)
					aVolumesW[kW, 2]     := nValW
					kW++
				Else
					aVolumesW[nPos0W, 2] += nValW
				EndIf
			EndIf
				
		EndIf

		_nVlTotalped  += (TRBW->CB8_QTDORI * TRBW->C9_PRCVEN)
		_nPesBruTotal += (TRBW->CB8_QTDORI * TRBW->B1_PESBRU)

			If lAtVol
				
				_cESPECI1W  := aVolumesW[1][1]
				_nVOLUME1W  := aVolumesW[1][2]
				_cESPECI2w  := aVolumesW[2][1]
				_nVOLUME2W  := aVolumesW[2][2]
				_cESPECI3W  := aVolumesW[3][1]
				_nVOLUME3W  := aVolumesW[3][2]
				_cESPECI4W  := aVolumesW[4][1]
				_nVOLUME4W  := aVolumesW[4][2]
				_cESPECI5W  := aVolumesW[5][1]
				_nVOLUME5W  := aVolumesW[5][2]
				_cESPECI6W  := aVolumesW[6][1]
				_nVOLUME6W  := aVolumesW[6][2]
				_cESPECI7W  := aVolumesW[7][1]
				_nVOLUME7W  := aVolumesW[7][2]
				_cESPECI8W  := aVolumesW[8][1]
				_nVOLUME8W  := aVolumesW[8][2]
				_cESPECI9W  := aVolumesW[9][1]
				_nVOLUME9W  := aVolumesW[9][2]
				_cESPECI10W := aVolumesW[10][1]
				_nVOLUME10W := aVolumesW[10][2]
				_cESPECI11W := aVolumesW[11][1]
				_nVOLUME11W := aVolumesW[11][2]
				_cESPECI12W := aVolumesW[12][1]
				_nVOLUME12W := aVolumesW[12][2]
				_cESPECI13W := aVolumesW[13][1]
				_nVOLUME13W := aVolumesW[13][2]
				_cESPECI14W := aVolumesW[14][1]
				_nVOLUME14W := aVolumesW[14][2]
				_cESPECI15W := aVolumesW[15][1]
				_nVOLUME15W := aVolumesW[15][2]
				_cESPECI16W := aVolumesW[16][1]
				_nVOLUME16W := aVolumesW[16][2]
				_cESPECI17W := aVolumesW[17][1]
				_nVOLUME17W := aVolumesW[17][2]
				_cESPECI18W := aVolumesW[18][1]
				_nVOLUME18W := aVolumesW[18][2]
				_cESPECI19W := aVolumesW[19][1]
				_nVOLUME19W := aVolumesW[19][2]
				_cESPECI20W := aVolumesW[20][1]
				_nVOLUME20W := aVolumesW[20][2]
				_cESPECI21W := aVolumesW[21][1]
				_nVOLUME21W := aVolumesW[21][2]
				_cESPECI22W := aVolumesW[22][1]
				_nVOLUME22W := aVolumesW[22][2]
				_cESPECI23W := aVolumesW[23][1]
				_nVOLUME23W := aVolumesW[23][2]
				_cESPECI24W := aVolumesW[24][1]
				_nVOLUME24W := aVolumesW[24][2]
				_cESPECI25W := aVolumesW[25][1]
				_nVOLUME25W := aVolumesW[25][2]
				_cESPECI26W := aVolumesW[26][1]
				_nVOLUME26W := aVolumesW[26][2]
				_cESPECI27W := aVolumesW[27][1]
				_nVOLUME27W := aVolumesW[27][2]
				_cESPECI28W := aVolumesW[28][1]
				_nVOLUME28W := aVolumesW[28][2]
				_cESPECI29W := aVolumesW[29][1]
				_nVOLUME29W := aVolumesW[29][2]
				_cESPECI30W := aVolumesW[30][1]
				_nVOLUME30W := aVolumesW[30][2]
				_cESPECI31W := aVolumesW[31][1]
				_nVOLUME31W := aVolumesW[31][2]
				_cESPECI32W := aVolumesW[32][1]
				_nVOLUME32W := aVolumesW[32][2]
				_cESPECI33W := aVolumesW[33][1]
				_nVOLUME33W := aVolumesW[33][2]
				_cESPECI34W := aVolumesW[34][1]
				_nVOLUME34W := aVolumesW[34][2]
				_cESPECI35W := aVolumesW[35][1]
				_nVOLUME35W := aVolumesW[35][2]
				_cESPECI36W := aVolumesW[36][1]
				_nVOLUME36W := aVolumesW[36][2]
				_cESPECI37W := aVolumesW[37][1]
				_nVOLUME37W := aVolumesW[37][2]
				_cESPECI38W := aVolumesW[38][1]
				_nVOLUME38W := aVolumesW[38][2]
				_cESPECI39W := aVolumesW[39][1]
				_nVOLUME39W := aVolumesW[39][2]
				_cESPECI40W := aVolumesW[40][1]
				_nVOLUME40W := aVolumesW[40][2]

				_cESPECI41W := aVolumesW[41][1]
				_nVOLUME41W := aVolumesW[41][2]
				_cESPECI42W := aVolumesW[42][1]
				_nVOLUME42W := aVolumesW[42][2]
				_cESPECI43W := aVolumesW[43][1]
				_nVOLUME43W := aVolumesW[43][2]
				_cESPECI44W := aVolumesW[44][1]
				_nVOLUME44W := aVolumesW[44][2]
				_cESPECI45W := aVolumesW[45][1]
				_nVOLUME45W := aVolumesW[45][2]
				_cESPECI46W := aVolumesW[46][1]
				_nVOLUME46W := aVolumesW[46][2]
				_cESPECI47W := aVolumesW[47][1]
				_nVOLUME47W := aVolumesW[47][2]
				_cESPECI48W := aVolumesW[48][1]
				_nVOLUME48W := aVolumesW[48][2]
				_cESPECI49W := aVolumesW[49][1]
				_nVOLUME49W := aVolumesW[49][2]
				_cESPECI50W := aVolumesW[50][1]
				_nVOLUME50W := aVolumesW[50][2]
				_cESPECI51W := aVolumesW[51][1]
				_nVOLUME51W := aVolumesW[51][2]
				_cESPECI52W := aVolumesW[52][1]
				_nVOLUME52W := aVolumesW[52][2]
				_cESPECI53W := aVolumesW[53][1]
				_nVOLUME53W := aVolumesW[53][2]

			EndIf

		cVolumesW := Iif(_nVOLUME1W > 0,Transform(_nVOLUME1W,"@E 9,999") + " " + AllTrim(_cESPECI1W+" |"),"");
					+ Iif(_nVOLUME2W  > 0,Transform(_nVOLUME2W ,"@E 9,999") + " " + AllTrim(_cESPECI2W+" |") ,"");
					+ Iif(_nVOLUME3W  > 0,Transform(_nVOLUME3W ,"@E 9,999") + " " + AllTrim(_cESPECI3W+" |") ,"");
					+ Iif(_nVOLUME4W  > 0,Transform(_nVOLUME4W ,"@E 9,999") + " " + AllTrim(_cESPECI4W+" |") ,"");		
					+ Iif(_nVOLUME5W  > 0,Transform(_nVOLUME5W ,"@E 9,999") + " " + AllTrim(_cESPECI5W+" |") ,"");		
					+ Iif(_nVOLUME6W  > 0,Transform(_nVOLUME6W ,"@E 9,999") + " " + AllTrim(_cESPECI6W+" |") ,"");		
					+ Iif(_nVOLUME7W  > 0,Transform(_nVOLUME7W ,"@E 9,999") + " " + AllTrim(_cESPECI7W+" |") ,"");		
					+ Iif(_nVOLUME8W  > 0,Transform(_nVOLUME8W ,"@E 9,999") + " " + AllTrim(_cESPECI8W+" |") ,"");		
					+ Iif(_nVOLUME9W  > 0,Transform(_nVOLUME9W ,"@E 9,999") + " " + AllTrim(_cESPECI9W+" |") ,"");
					+ Iif(_nVOLUME10W > 0,Transform(_nVOLUME10W,"@E 9,999") + " " + AllTrim(_cESPECI10W+" |"),"");
					+ Iif(_nVOLUME11W > 0,Transform(_nVOLUME11W,"@E 9,999") + " " + AllTrim(_cESPECI11W+" |"),"");
					+ Iif(_nVOLUME12W > 0,Transform(_nVOLUME12W,"@E 9,999") + " " + AllTrim(_cESPECI12W+" |"),"");
					+ Iif(_nVOLUME13W > 0,Transform(_nVOLUME13W,"@E 9,999") + " " + AllTrim(_cESPECI13W+" |"),"");
					+ Iif(_nVOLUME14W > 0,Transform(_nVOLUME14W,"@E 9,999") + " " + AllTrim(_cESPECI14W+" |"),"");
					+ Iif(_nVOLUME15W > 0,Transform(_nVOLUME15W,"@E 9,999") + " " + AllTrim(_cESPECI15W+" |"),"");
					+ Iif(_nVOLUME16W > 0,Transform(_nVOLUME16W,"@E 9,999") + " " + AllTrim(_cESPECI16W+" |"),"");
					+ Iif(_nVOLUME17W > 0,Transform(_nVOLUME17W,"@E 9,999") + " " + AllTrim(_cESPECI17W+" |"),"");
					+ Iif(_nVOLUME18W > 0,Transform(_nVOLUME18W,"@E 9,999") + " " + AllTrim(_cESPECI18W+" |"),"");
					+ Iif(_nVOLUME19W > 0,Transform(_nVOLUME19W,"@E 9,999") + " " + AllTrim(_cESPECI19W+" |"),"");
					+ Iif(_nVOLUME20W > 0,Transform(_nVOLUME20W,"@E 9,999") + " " + AllTrim(_cESPECI20W+" |"),"");
					+ Iif(_nVOLUME21W > 0,Transform(_nVOLUME21W,"@E 9,999") + " " + AllTrim(_cESPECI21W+" |"),"");
					+ Iif(_nVOLUME22W > 0,Transform(_nVOLUME22W,"@E 9,999") + " " + AllTrim(_cESPECI22W+" |"),"");
					+ Iif(_nVOLUME23W > 0,Transform(_nVOLUME23W,"@E 9,999") + " " + AllTrim(_cESPECI23W+" |"),"");
					+ Iif(_nVOLUME24W > 0,Transform(_nVOLUME24W,"@E 9,999") + " " + AllTrim(_cESPECI24W+" |"),"");
					+ Iif(_nVOLUME25W > 0,Transform(_nVOLUME25W,"@E 9,999") + " " + AllTrim(_cESPECI25W+" |"),"");
					+ Iif(_nVOLUME26W > 0,Transform(_nVOLUME26W,"@E 9,999") + " " + AllTrim(_cESPECI26W+" |"),"");
					+ Iif(_nVOLUME27W > 0,Transform(_nVOLUME27W,"@E 9,999") + " " + AllTrim(_cESPECI27W+" |"),"");
					+ Iif(_nVOLUME28W > 0,Transform(_nVOLUME28W,"@E 9,999") + " " + AllTrim(_cESPECI28W+" |"),"");
					+ Iif(_nVOLUME29W > 0,Transform(_nVOLUME29W,"@E 9,999") + " " + AllTrim(_cESPECI29W+" |"),"");
					+ Iif(_nVOLUME30W > 0,Transform(_nVOLUME30W,"@E 9,999") + " " + AllTrim(_cESPECI30W+" |"),"");
					+ Iif(_nVOLUME31W > 0,Transform(_nVOLUME31W,"@E 9,999") + " " + AllTrim(_cESPECI31W+" |"),"");
					+ Iif(_nVOLUME32W > 0,Transform(_nVOLUME32W,"@E 9,999") + " " + AllTrim(_cESPECI32W+" |"),"");
					+ Iif(_nVOLUME33W > 0,Transform(_nVOLUME33W,"@E 9,999") + " " + AllTrim(_cESPECI33W+" |"),"");
					+ Iif(_nVOLUME34W > 0,Transform(_nVOLUME34W,"@E 9,999") + " " + AllTrim(_cESPECI34W+" |"),"");
					+ Iif(_nVOLUME35W > 0,Transform(_nVOLUME35W,"@E 9,999") + " " + AllTrim(_cESPECI35W+" |"),"");
					+ Iif(_nVOLUME36W > 0,Transform(_nVOLUME36W,"@E 9,999") + " " + AllTrim(_cESPECI36W+" |"),"");
					+ Iif(_nVOLUME37W > 0,Transform(_nVOLUME37W,"@E 9,999") + " " + AllTrim(_cESPECI37W+" |"),"");
					+ Iif(_nVOLUME38W > 0,Transform(_nVOLUME38W,"@E 9,999") + " " + AllTrim(_cESPECI38W+" |"),"");
					+ Iif(_nVOLUME39W > 0,Transform(_nVOLUME39W,"@E 9,999") + " " + AllTrim(_cESPECI39W+" |"),"");
					+ Iif(_nVOLUME40W > 0,Transform(_nVOLUME40W,"@E 9,999") + " " + AllTrim(_cESPECI40W+" |"),"");
					+ Iif(_nVOLUME41W > 0,Transform(_nVOLUME41W,"@E 9,999") + " " + AllTrim(_cESPECI41W+" |"),"");
					+ Iif(_nVOLUME42W > 0,Transform(_nVOLUME42W,"@E 9,999") + " " + AllTrim(_cESPECI42W+" |"),"");
					+ Iif(_nVOLUME43W > 0,Transform(_nVOLUME43W,"@E 9,999") + " " + AllTrim(_cESPECI43W+" |"),"");
					+ Iif(_nVOLUME44W > 0,Transform(_nVOLUME44W,"@E 9,999") + " " + AllTrim(_cESPECI44W+" |"),"");
					+ Iif(_nVOLUME45W > 0,Transform(_nVOLUME45W,"@E 9,999") + " " + AllTrim(_cESPECI45W+" |"),"");
					+ Iif(_nVOLUME46W > 0,Transform(_nVOLUME46W,"@E 9,999") + " " + AllTrim(_cESPECI46W+" |"),"");
					+ Iif(_nVOLUME47W > 0,Transform(_nVOLUME47W,"@E 9,999") + " " + AllTrim(_cESPECI47W+" |"),"");
					+ Iif(_nVOLUME48W > 0,Transform(_nVOLUME48W,"@E 9,999") + " " + AllTrim(_cESPECI48W+" |"),"");
					+ Iif(_nVOLUME49W > 0,Transform(_nVOLUME49W,"@E 9,999") + " " + AllTrim(_cESPECI49W+" |"),"");
					+ Iif(_nVOLUME50W > 0,Transform(_nVOLUME50W,"@E 9,999") + " " + AllTrim(_cESPECI50W+" |"),"");
					+ Iif(_nVOLUME51W > 0,Transform(_nVOLUME51W,"@E 9,999") + " " + AllTrim(_cESPECI51W+" |"),"");
					+ Iif(_nVOLUME52W > 0,Transform(_nVOLUME52W,"@E 9,999") + " " + AllTrim(_cESPECI52W+" |"),"");
					+ Iif(_nVOLUME53W > 0,Transform(_nVOLUME53W,"@E 9,999") + " " + AllTrim(_cESPECI53W+" |"),"")

		TRBW->(DbSkip())
		
	EndDo

	//impressão cabeçalho 
	
	qefat05c()
	
	nLin := 120

	While TRB1->(!Eof())
				
		_cPedido  := TRB1->C5_NUM
		_cOrdSep  := TRB1->CB8_ORDSEP
		_cNomeCli := TRB1->A1_NOME
		cCampo    := ""

		If nLin > 800  //Quebra de pagina
			oPrinter:Line(800,10,800,585)
			oPrinter:EndPage()
			oPrinter:StartPage()
			qefat05c()
			nLin := 140
		EndIf
		
		cCampo := Iif((Subs(TRB1->B1_GRUPO, 1, 1) != "3" .And. TRB1->B1_GRUPO != "1300") .And. TRB1->B1_TIPO == "PA", "TRB1->B1_SEGUM", "TRB1->B1_UM")

		nPos0  := Ascan(aVolumes, {|x| &cCampo $ x[1]})

		If AllTrim( TRB1->B1_UM ) == "KG" .And. AllTrim( TRB1->B1_SEGUM ) <> "KG" .And. TRB1->B1_TIPO == "PA" .And. !Empty( TRB1->B1_SEGUM ) .And. TRB1->B1_CONV <> 0
			nVal   := Iif(TRB1->B1_TIPCONV == "D", TRB1->CB8_QTDORI / TRB1->B1_CONV, TRB1->CB8_QTDORI * TRB1->B1_CONV)
		Else
			nVal := Iif((Subs(TRB1->B1_GRUPO, 1, 1) != "3" .And. TRB1->B1_GRUPO != "1300") .And. TRB1->B1_TIPO == "PA",Iif(TRB1->B1_TIPCONV == "D",TRB1->CB8_QTDORI / TRB1->B1_CONV, TRB1->CB8_QTDORI * TRB1->B1_CONV), TRB1->CB8_QTDORI)
		EndIf

		If Subs(TRB1->B1_GRUPO, 1, 1) $ "3/4" .And. TRB1->B1_UM $ "GL#PT"
			If Subs(AllTrim(TRB1->B1_COD), -2) == "06" .Or. SubStr(AllTrim(TRB1->B1_COD),1,8) $ ("7770.909/7770.910") // tratamento caixa somente para o alcool - 14/04/2021 
				nPos1 := Ascan(aVolumes, {|x| "CX" $ x[1]})
			Else
				nPos1 := Ascan(aVolumes, {|x| "FD" $ x[1]})
			EndIf

			If &cCampo == "GL"
				nValFd := ((nVal - (nVal % 4)))/4
				nVal   := nVal % 4
			ElseIf &cCampo == "PT"
				If Subs(AllTrim(TRB1->B1_COD), -2) $ "02|06"
					nValFd := ((nVal - (nVal % 12)))/12
					nVal   := nVal % 12
				Else  
					nValFd := ((nVal - (nVal % 6)))/6
					nVal   := nVal % 6
				EndIf
			EndIf
					
			If nValFd > 0
				If nPos1 == 0
					aVolumes[k, 1]     := If(Subs(AllTrim(TRB1->B1_COD), -2) == "06", "CX", "FD")
					aVolumes[k, 2]     := nValFd
					k++
				Else
					aVolumes[nPos1, 2] += nValFd
				EndIf

			EndIf
					
			If nVal > 0

				If nPos0 == 0
					aVolumes[k, 1]     := &(cCampo)
					aVolumes[k, 2]     := nVal
					k++
				Else
					aVolumes[nPos0, 2] += nVal
				EndIf
					
			EndIf

		Else 
				
			If nVal > 0
				If nPos0 == 0
					aVolumes[k, 1]     := &(cCampo)
					aVolumes[k, 2]     := nVal
					k++
				Else
					aVolumes[nPos0, 2] += nVal
				EndIf
			
			EndIf
				
		EndIf

		TRB1->(DbSkip())

		If TRB1->(EOF()) .Or. TRB1->CB8_ORDSEP <> _cOrdSep

			_cItem++

			If Select("TRBP") > 0
				TRBP->(DbCloseArea())
			EndIf

			cQueryP := "SELECT SUM(CB8_QTDORI * B1_PESBRU) AS PESOBRU, SUM(CB8_QTDORI * B1_PESO) AS PESOLIQ, SUM(ROUND(C9_PRCVEN * CB8_QTDORI,2)) AS TOTAL  " +CRLF
			cQueryP += " FROM  " + RetSqlName("DAK") + " AS DAK " + ENTER
			cQueryP += "INNER JOIN " + RetSqlName("DAI") + " AS DAI ON DAI_FILIAL = DAK_FILIAL " + ENTER
			cQueryP += " AND DAK_COD = DAI_COD  " + ENTER
			cQueryP += " AND DAI.D_E_L_E_T_ = ' '   " + ENTER
			cQueryP += "INNER JOIN " + RetSqlName("SA4") + " AS SA4 ON A4_COD = DAK_TRANSP  " + ENTER
			cQueryP += " AND SA4.D_E_L_E_T_ = ' ' " + ENTER
			cQueryP += "INNER JOIN " + RetSqlName("DA3") + " AS DA3 ON DA3_COD = DAK_CAMINH  " + ENTER
			cQueryP += " AND DA3.D_E_L_E_T_ = ' '   " + ENTER
			cQueryP += "INNER JOIN " + RetSqlName("DA4") + " AS DA4 ON DA4_COD = DAK_MOTORI  " + ENTER
			cQueryP += " AND DA4.D_E_L_E_T_ = ' '  " + ENTER
			cQueryP += "INNER JOIN " + RetSqlName("CB8") + " AS CB8 ON CB8_FILIAL = DAI_FILIAL  " + ENTER
			cQueryP += " AND CB8_PEDIDO = DAI_PEDIDO  " + ENTER
			cQueryP += " AND CB8.D_E_L_E_T_ = ' '  " + ENTER
			cQueryP += "INNER JOIN " + RetSqlName("CB7") + " AS CB7 ON CB7_FILIAL = CB8_FILIAL  " + ENTER
			cQueryP += " AND CB7_ORDSEP = CB8_ORDSEP  " + ENTER
			cQueryP += " AND CB7_NOTA  = ' '  " + ENTER
			cQueryP += " AND CB7_SERIE = ' '  " + ENTER
			cQueryP += " AND CB7.D_E_L_E_T_ = ' '  " + ENTER
			cQueryP += "INNER JOIN " + RetSqlName("SC9") + " AS SC9 ON C9_FILIAL = CB8_FILIAL  " + ENTER
			cQueryP += " AND C9_PEDIDO  = CB8_PEDIDO   " + ENTER
			cQueryP += " AND C9_PRODUTO = CB8_PROD " + ENTER
			cQueryP += " AND C9_LOCAL   = CB8_LOCAL " + ENTER
			cQueryP += " AND C9_LOTECTL = CB8_LOTECT " + ENTER
			cQueryP += " AND SC9.D_E_L_E_T_ = ' '  " + ENTER
			cQueryP += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 ON B1_COD = CB8_PROD  " + ENTER
			cQueryP += " AND SB1.D_E_L_E_T_ = ' '   " + ENTER
			cQueryP += "INNER JOIN " + RetSqlName("SC5") + " AS SC5 ON C5_FILIAL = CB8_FILIAL  " + ENTER
			cQueryP += " AND C5_NUM = CB8_PEDIDO  " + ENTER
			cQueryP += " AND SC5.D_E_L_E_T_ = ' ' " + ENTER
			cQueryP += "INNER JOIN " + RetSqlName("SA1") + " AS SA1 ON A1_FILIAL = C5_FILIAL   " + ENTER
			cQueryP += " AND A1_COD  = C5_CLIENTE  " + ENTER
			cQueryP += " AND A1_LOJA = C5_LOJACLI  " + ENTER
			cQueryP += "WHERE CB8_FILIAL = '"+xFilial("CB8")+"' " + ENTER
			cQueryP += " AND CB8_PEDIDO  = '"+_cPedido+"'     "+CRLF
			cQueryP += " AND CB8_ORDSEP  = '"+_cOrdSep+"' "+CRLF
			cQueryP += " AND CB8.D_E_L_E_T_ = ' ' " + ENTER

			TcQuery cQueryP ALIAS "TRBP" NEW

			TRBP->(DbGoTop())
			
			While TRBP->(!Eof())

				_nPESOL   := TRBP->PESOLIQ
				_nPBRUTO  := TRBP->PESOBRU
				nTotal    := TRBP->TOTAL
				
				TRBP->(DbSkip())

			EndDo

			If lAtVol

				_cESPECI1  := aVolumes[1][1]
				_nVOLUME1  := aVolumes[1][2]
				_cESPECI2  := aVolumes[2][1]
				_nVOLUME2  := aVolumes[2][2]
				_cESPECI3  := aVolumes[3][1]
				_nVOLUME3  := aVolumes[3][2]
				_cESPECI4  := aVolumes[4][1]
				_nVOLUME4  := aVolumes[4][2]
				_cESPECI5  := aVolumes[5][1]
				_nVOLUME5  := aVolumes[5][2]
				_cESPECI6  := aVolumes[6][1]
				_nVOLUME6  := aVolumes[6][2]
				_cESPECI7  := aVolumes[7][1]
				_nVOLUME7  := aVolumes[7][2]
				_cESPECI8  := aVolumes[8][1]
				_nVOLUME8  := aVolumes[8][2]
				_cESPECI9  := aVolumes[9][1]
				_nVOLUME9  := aVolumes[9][2]
				_cESPECI10 := aVolumes[10][1]
				_nVOLUME10 := aVolumes[10][2]
				_cESPECI11 := aVolumes[11][1]
				_nVOLUME11 := aVolumes[11][2]
				_cESPECI12 := aVolumes[12][1]
				_nVOLUME12 := aVolumes[12][2]
				_cESPECI13 := aVolumes[13][1]
				_nVOLUME13 := aVolumes[13][2]
				_cESPECI14 := aVolumes[14][1]
				_nVOLUME14 := aVolumes[14][2]
				_cESPECI15 := aVolumes[15][1]
				_nVOLUME15 := aVolumes[15][2]
				_cESPECI16 := aVolumes[16][1]
				_nVOLUME16 := aVolumes[16][2]
				_cESPECI17 := aVolumes[17][1]
				_nVOLUME17 := aVolumes[17][2]
				_cESPECI18 := aVolumes[18][1]
				_nVOLUME18 := aVolumes[18][2]
				_cESPECI19 := aVolumes[19][1]
				_nVOLUME19 := aVolumes[19][2]
				_cESPECI20 := aVolumes[20][1]
				_nVOLUME20 := aVolumes[20][2]
				_cESPECI21 := aVolumes[21][1]
				_nVOLUME21 := aVolumes[21][2]
				_cESPECI22 := aVolumes[22][1]
				_nVOLUME22 := aVolumes[22][2]
				_cESPECI23 := aVolumes[23][1]
				_nVOLUME23 := aVolumes[23][2]
				_cESPECI24 := aVolumes[24][1]
				_nVOLUME24 := aVolumes[24][2]
				_cESPECI25 := aVolumes[25][1]
				_nVOLUME25 := aVolumes[25][2]
				_cESPECI26 := aVolumes[26][1]
				_nVOLUME26 := aVolumes[26][2]
				_cESPECI27 := aVolumes[27][1]
				_nVOLUME27 := aVolumes[27][2]
				_cESPECI28 := aVolumes[28][1]
				_nVOLUME28 := aVolumes[28][2]
				_cESPECI29 := aVolumes[29][1]
				_nVOLUME29 := aVolumes[29][2]
				_cESPECI30 := aVolumes[30][1]
				_nVOLUME30 := aVolumes[30][2]
				_cESPECI31 := aVolumes[31][1]
				_nVOLUME31 := aVolumes[31][2]
				_cESPECI32 := aVolumes[32][1]
				_nVOLUME32 := aVolumes[32][2]
				_cESPECI33 := aVolumes[33][1]
				_nVOLUME33 := aVolumes[33][2]
				_cESPECI34 := aVolumes[34][1]
				_nVOLUME34 := aVolumes[34][2]
				_cESPECI35 := aVolumes[35][1]
				_nVOLUME35 := aVolumes[35][2]
				_cESPECI36 := aVolumes[36][1]
				_nVOLUME36 := aVolumes[36][2]
				_cESPECI37 := aVolumes[37][1]
				_nVOLUME37 := aVolumes[37][2]
				_cESPECI38 := aVolumes[38][1]
				_nVOLUME38 := aVolumes[38][2]
				_cESPECI39 := aVolumes[39][1]
				_nVOLUME39 := aVolumes[39][2]
				_cESPECI40 := aVolumes[40][1]
				_nVOLUME40 := aVolumes[40][2]

				_cESPECI41 := aVolumes[41][1]
				_nVOLUME41 := aVolumes[41][2]
				_cESPECI42 := aVolumes[42][1]
				_nVOLUME42 := aVolumes[42][2]
				_cESPECI43 := aVolumes[43][1]
				_nVOLUME43 := aVolumes[43][2]
				_cESPECI44 := aVolumes[44][1]
				_nVOLUME44 := aVolumes[44][2]
				_cESPECI45 := aVolumes[45][1]
				_nVOLUME45 := aVolumes[45][2]
				_cESPECI46 := aVolumes[46][1]
				_nVOLUME46 := aVolumes[46][2]
				_cESPECI47 := aVolumes[47][1]
				_nVOLUME47 := aVolumes[47][2]
				_cESPECI48 := aVolumes[48][1]
				_nVOLUME48 := aVolumes[48][2]
				_cESPECI49 := aVolumes[49][1]
				_nVOLUME49 := aVolumes[49][2]
				_cESPECI50 := aVolumes[50][1]
				_nVOLUME50 := aVolumes[50][2]
				_cESPECI51 := aVolumes[51][1]
				_nVOLUME51 := aVolumes[51][2]
				_cESPECI52 := aVolumes[52][1]
				_nVOLUME52 := aVolumes[52][2]
				_cESPECI53 := aVolumes[53][1]
				_nVOLUME53 := aVolumes[53][2]


			EndIf

			cVolumes := Iif(_nVOLUME1 > 0,Transform(_nVOLUME1,"@E 9,999") +""+ AllTrim(_cESPECI1+"|"),"");
					+ Iif(_nVOLUME2 > 0,Transform(_nVOLUME2,"@E 9,999") + ""+ AllTrim(_cESPECI2+"|"),"");
					+ Iif(_nVOLUME3 > 0,Transform(_nVOLUME3,"@E 9,999") + ""+ AllTrim(_cESPECI3+"|"),"");
					+ Iif(_nVOLUME4 > 0,Transform(_nVOLUME4,"@E 9,999") + ""+ AllTrim(_cESPECI4+"|"),"");		
					+ Iif(_nVOLUME5 > 0,Transform(_nVOLUME5,"@E 9,999") + ""+ AllTrim(_cESPECI5+"|"),"");	
					+ Iif(_nVOLUME6 > 0,Transform(_nVOLUME6,"@E 9,999") + ""+ AllTrim(_cESPECI6+"|"),"");		
					+ Iif(_nVOLUME7 > 0,Transform(_nVOLUME7,"@E 9,999") + ""+ AllTrim(_cESPECI7+"|"),"");		
					+ Iif(_nVOLUME8 > 0,Transform(_nVOLUME8,"@E 9,999") + ""+ AllTrim(_cESPECI8+"|"),"");		
					+ Iif(_nVOLUME9 > 0,Transform(_nVOLUME9,"@E 9,999") + " " + AllTrim(_cESPECI9+" |"),"");
					+ Iif(_nVOLUME10 > 0,Transform(_nVOLUME10,"@E 9,999") + " " + AllTrim(_cESPECI10+" |"),"");
					+ Iif(_nVOLUME11 > 0,Transform(_nVOLUME11,"@E 9,999") + " " + AllTrim(_cESPECI11+" |"),"");
					+ Iif(_nVOLUME12 > 0,Transform(_nVOLUME12,"@E 9,999") + " " + AllTrim(_cESPECI12+" |"),"");
					+ Iif(_nVOLUME13 > 0,Transform(_nVOLUME13,"@E 9,999") + " " + AllTrim(_cESPECI13+" |"),"");
					+ Iif(_nVOLUME14 > 0,Transform(_nVOLUME14,"@E 9,999") + " " + AllTrim(_cESPECI14+" |"),"");
					+ Iif(_nVOLUME15 > 0,Transform(_nVOLUME15,"@E 9,999") + " " + AllTrim(_cESPECI15+" |"),"");
					+ Iif(_nVOLUME16 > 0,Transform(_nVOLUME16,"@E 9,999") + " " + AllTrim(_cESPECI16+" |"),"");
					+ Iif(_nVOLUME17 > 0,Transform(_nVOLUME17,"@E 9,999") + " " + AllTrim(_cESPECI17+" |"),"");
					+ Iif(_nVOLUME18 > 0,Transform(_nVOLUME18,"@E 9,999") + " " + AllTrim(_cESPECI18+" |"),"");
					+ Iif(_nVOLUME19 > 0,Transform(_nVOLUME19,"@E 9,999") + " " + AllTrim(_cESPECI19+" |"),"");
					+ Iif(_nVOLUME20 > 0,Transform(_nVOLUME20,"@E 9,999") + " " + AllTrim(_cESPECI20+" |"),"");
					+ Iif(_nVOLUME21 > 0,Transform(_nVOLUME21,"@E 9,999") + " " + AllTrim(_cESPECI21+" |"),"");
					+ Iif(_nVOLUME22 > 0,Transform(_nVOLUME22,"@E 9,999") + " " + AllTrim(_cESPECI22+" |"),"");
					+ Iif(_nVOLUME23 > 0,Transform(_nVOLUME23,"@E 9,999") + " " + AllTrim(_cESPECI23+" |"),"");
					+ Iif(_nVOLUME24 > 0,Transform(_nVOLUME24,"@E 9,999") + " " + AllTrim(_cESPECI24+" |"),"");
					+ Iif(_nVOLUME25 > 0,Transform(_nVOLUME25,"@E 9,999") + " " + AllTrim(_cESPECI25+" |"),"");
					+ Iif(_nVOLUME26 > 0,Transform(_nVOLUME26,"@E 9,999") + " " + AllTrim(_cESPECI26+" |"),"");
					+ Iif(_nVOLUME27 > 0,Transform(_nVOLUME27,"@E 9,999") + " " + AllTrim(_cESPECI27+" |"),"");
					+ Iif(_nVOLUME28 > 0,Transform(_nVOLUME28,"@E 9,999") + " " + AllTrim(_cESPECI28+" |"),"");
					+ Iif(_nVOLUME29 > 0,Transform(_nVOLUME29,"@E 9,999") + " " + AllTrim(_cESPECI29+" |"),"");
					+ Iif(_nVOLUME30 > 0,Transform(_nVOLUME30,"@E 9,999") + " " + AllTrim(_cESPECI30+" |"),"");
					+ Iif(_nVOLUME31 > 0,Transform(_nVOLUME31,"@E 9,999") + " " + AllTrim(_cESPECI31+" |"),"");
					+ Iif(_nVOLUME32 > 0,Transform(_nVOLUME32,"@E 9,999") + " " + AllTrim(_cESPECI32+" |"),"");
					+ Iif(_nVOLUME33 > 0,Transform(_nVOLUME33,"@E 9,999") + " " + AllTrim(_cESPECI33+" |"),"");
					+ Iif(_nVOLUME34 > 0,Transform(_nVOLUME34,"@E 9,999") + " " + AllTrim(_cESPECI34+" |"),"");
					+ Iif(_nVOLUME35 > 0,Transform(_nVOLUME35,"@E 9,999") + " " + AllTrim(_cESPECI35+" |"),"");
					+ Iif(_nVOLUME36 > 0,Transform(_nVOLUME36,"@E 9,999") + " " + AllTrim(_cESPECI36+" |"),"");
					+ Iif(_nVOLUME37 > 0,Transform(_nVOLUME37,"@E 9,999") + " " + AllTrim(_cESPECI37+" |"),"");
					+ Iif(_nVOLUME38 > 0,Transform(_nVOLUME38,"@E 9,999") + " " + AllTrim(_cESPECI38+" |"),"");
					+ Iif(_nVOLUME39 > 0,Transform(_nVOLUME39,"@E 9,999") + " " + AllTrim(_cESPECI39+" |"),"");
					+ Iif(_nVOLUME40 > 0,Transform(_nVOLUME40,"@E 9,999") + " " + AllTrim(_cESPECI40+" |"),"");
					+ Iif(_nVOLUME41 > 0,Transform(_nVOLUME41,"@E 9,999") + " " + AllTrim(_cESPECI41+" |"),"");
					+ Iif(_nVOLUME42 > 0,Transform(_nVOLUME42,"@E 9,999") + " " + AllTrim(_cESPECI42+" |"),"");
					+ Iif(_nVOLUME43 > 0,Transform(_nVOLUME43,"@E 9,999") + " " + AllTrim(_cESPECI43+" |"),"");
					+ Iif(_nVOLUME44 > 0,Transform(_nVOLUME44,"@E 9,999") + " " + AllTrim(_cESPECI44+" |"),"");
					+ Iif(_nVOLUME45 > 0,Transform(_nVOLUME45,"@E 9,999") + " " + AllTrim(_cESPECI45+" |"),"");
					+ Iif(_nVOLUME46 > 0,Transform(_nVOLUME46,"@E 9,999") + " " + AllTrim(_cESPECI46+" |"),"");
					+ Iif(_nVOLUME47 > 0,Transform(_nVOLUME47,"@E 9,999") + " " + AllTrim(_cESPECI47+" |"),"");
					+ Iif(_nVOLUME48 > 0,Transform(_nVOLUME48,"@E 9,999") + " " + AllTrim(_cESPECI48+" |"),"");
					+ Iif(_nVOLUME49 > 0,Transform(_nVOLUME49,"@E 9,999") + " " + AllTrim(_cESPECI49+" |"),"");
					+ Iif(_nVOLUME50 > 0,Transform(_nVOLUME50,"@E 9,999") + " " + AllTrim(_cESPECI50+" |"),"");
					+ Iif(_nVOLUME51 > 0,Transform(_nVOLUME51,"@E 9,999") + " " + AllTrim(_cESPECI51+" |"),"");
					+ Iif(_nVOLUME52 > 0,Transform(_nVOLUME52,"@E 9,999") + " " + AllTrim(_cESPECI52+" |"),"");
					+ Iif(_nVOLUME53 > 0,Transform(_nVOLUME53,"@E 9,999") + " " + AllTrim(_cESPECI53+" |"),"")

			cString := TransForm(_cItem, "@E 99")  + " - " + SubStr(Alltrim(_cFilNome), 1, 10) + " - "
			cString += _cPedido+ " - " + _cOrdSep + "   - " + SubStr(_cNomeCli, 1, 20) + " - "
			cString += TransForm(_nPBRUTO, "@E 999,999.9999") + " - "
			cString += TransForm(nTotal, "@E 9,999,999.99") + " - "
			cString += Alltrim(cVolumes) 

			oPrinter:Say(nLin, 10, cString, oFont10)
			
			nLin += 15

			aVolumes[1][1]  := ""
			aVolumes[1][2]  := 0
			aVolumes[2][1]  := ""
			aVolumes[2][2]  := 0
			aVolumes[3][1]  := ""
			aVolumes[3][2]  := 0
			aVolumes[4][1]  := ""
			aVolumes[4][2]  := 0
			aVolumes[5][1]  := ""
			aVolumes[5][2]  := 0
			aVolumes[6][1]  := ""
			aVolumes[6][2]  := 0
			aVolumes[7][1]  := ""
			aVolumes[7][2]  := 0
			aVolumes[8][1]  := ""
			aVolumes[8][2]  := 0
			aVolumes[9][1]  := ""
			aVolumes[9][2]  := 0
			aVolumes[10][1] := ""
			aVolumes[10][2] := 0
			aVolumes[11][1] := ""
			aVolumes[11][2] := 0
			aVolumes[12][1] := ""
			aVolumes[12][2] := 0
			aVolumes[13][1] := ""
			aVolumes[13][2] := 0
			aVolumes[14][1] := ""
			aVolumes[14][2] := 0
			aVolumes[15][1] := ""
			aVolumes[15][2] := 0
			aVolumes[16][1] := ""
			aVolumes[16][2] := 0
			aVolumes[17][1] := ""
			aVolumes[17][2] := 0
			aVolumes[18][1] := ""
			aVolumes[18][2] := 0
			aVolumes[19][1] := ""
			aVolumes[19][2] := 0
			aVolumes[20][1] := ""
			aVolumes[20][2] := 0
			aVolumes[21][1] := ""
			aVolumes[21][2] := 0
			aVolumes[22][1] := ""
			aVolumes[22][2] := 0
			aVolumes[23][1] := ""
			aVolumes[23][2] := 0
			aVolumes[24][1] := ""
			aVolumes[24][2] := 0
			aVolumes[25][1] := ""
			aVolumes[25][2] := 0
			aVolumes[26][1] := ""
			aVolumes[26][2] := 0
			aVolumes[27][1] := ""
			aVolumes[27][2] := 0
			aVolumes[28][1] := ""
			aVolumes[28][2] := 0
			aVolumes[29][1] := ""
			aVolumes[29][2] := 0
			aVolumes[30][1] := ""
			aVolumes[30][2] := 0
			aVolumes[31][1] := ""
			aVolumes[31][2] := 0
			aVolumes[32][1] := ""
			aVolumes[32][2] := 0
			aVolumes[33][1] := ""
			aVolumes[33][2] := 0
			aVolumes[34][1] := ""
			aVolumes[34][2] := 0
			aVolumes[35][1] := ""
			aVolumes[35][2] := 0
			aVolumes[36][1] := ""
			aVolumes[36][2] := 0
			aVolumes[37][1] := ""
			aVolumes[37][2] := 0
			aVolumes[38][1] := ""
			aVolumes[38][2] := 0
			aVolumes[39][1] := ""
			aVolumes[39][2] := 0
			aVolumes[40][1] := ""
			aVolumes[40][2] := 0

			_cESPECI1  := ""
			_nVOLUME1  := 0
			_cESPECI2  := ""
			_nVOLUME2  := 0
			_cESPECI3  := ""
			_nVOLUME3  := 0
			_cESPECI4  := ""
			_nVOLUME4  := 0
			_cESPECI5  := ""
			_nVOLUME5  := 0
			_cESPECI6  := ""
			_nVOLUME6  := 0
			_cESPECI7  := ""
			_nVOLUME7  := 0
			_cESPECI8  := ""
			_nVOLUME8  := 0
			_cESPECI9  := ""
			_nVOLUME9  := 0
			_cESPECI10 := ""
			_nVOLUME10 := 0
			_cESPECI11 := ""
			_nVOLUME11 := 0
			_cESPECI12 := ""
			_nVOLUME12 := 0
			_cESPECI13 := ""
			_nVOLUME13 := 0
			_cESPECI14 := ""
			_nVOLUME14 := 0
			_cESPECI15 := ""
			_nVOLUME15 := 0
			_cESPECI16 := ""
			_nVOLUME16 := 0
			_cESPECI17 := ""
			_nVOLUME17 := 0
			_cESPECI18 := ""
			_nVOLUME18 := 0
			_cESPECI19 := ""
			_nVOLUME19 := 0
			_cESPECI20 := ""
			_nVOLUME20 := 0
			_cESPECI21 := ""
			_nVOLUME21 := 0
			_cESPECI22 := ""
			_nVOLUME22 := 0
			_cESPECI23 := ""
			_nVOLUME23 := 0
			_cESPECI24 := ""
			_nVOLUME24 := 0
			_cESPECI25 := ""
			_nVOLUME25 := 0
			_cESPECI26 := ""
			_nVOLUME26 := 0
			_cESPECI27 := ""
			_nVOLUME27 := 0
			_cESPECI28 := ""
			_nVOLUME28 := 0
			_cESPECI30 := ""
			_nVOLUME30 := 0
			_cESPECI31 := ""
			_nVOLUME31 := 0
			_cESPECI32 := ""
			_nVOLUME32 := 0
			_cESPECI33 := ""
			_nVOLUME33 := 0
			_cESPECI34 := ""
			_nVOLUME34 := 0
			_cESPECI35 := ""
			_nVOLUME35 := 0
			_cESPECI36 := ""
			_nVOLUME36 := 0
			_cESPECI37 := ""
			_nVOLUME37 := 0
			_cESPECI38 := ""
			_nVOLUME38 := 0
			_cESPECI40 := ""
			_nVOLUME40 := 0

			cVolumes  := ""
		
		EndIf 

	EndDo

	oPrinter:Line(nLin,10,nLin,585)
	nLin += 20
	oPrinter:Say(nLin, 12, "Conferente..: ______________________________________________________", oFont14n)
	nLin += 20
	oPrinter:Say(nLin, 12, "Motorista....: ______________________________________________________", oFont14n)
	nLin += 20
	oPrinter:Say(nLin, 12, "Patrimonial.: ______________________________________________________", oFont14n)

	oPrinter:EndPage()
	oPrinter:Preview()
	FreeObj(oPrinter)
	oPrinter := Nil

	nRet := ShellExecute("Open", "C:\TEMP\QEFAT005_EMP_" + Alltrim(_cFilNome) + "_" + Dtos(dDataBase) +".PDF", "", "C:\TEMP\", 3)
	If nRet <= 32
		Aviso("Atenção", "Não foi possível abrir o arquivo, instalar um leitor de arquivo PDF", {"Ok"}, 2)
	EndIf

	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf
	If Select("TRBC") > 0
		TRBC->(DbCloseArea())
	EndIf
	If Select("TRBP") > 0
		TRBP->(DbCloseArea())
	EndIf
	If Select("TRBW") > 0
		TRBW->(DbCloseArea())
	EndIf
	SM0->(DbGoTo(nRegSM0))

Return
/*
+------------+------------+--------+---------------+-------+--------------+
| Programa:  | qefat05c   | Autor: | QUALY         | Data: | 02/05/21     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - qefat05c                                      |
+------------+------------------------------------------------------------+
*/
Static Function qefat05c()
	
	If !SELECT("DAK")>0
		DBSELECTAREA("DAK") 
	EndIf
	DAK->(DBSETORDER(1))
	DAK->(DBGOTOP())
	If DAK->(DbSeek(xFilial("DAK")+_cCodCarga+_cSeqCar))
	
		oPrinter:StartPage()
		oPrinter:Box(10, 10, 830, 585)  //moldura
		nLin := 25
		oPrinter:Say(nLin, 20 ,"CARGA DE SEPARAÇÃO: " + _cCodCarga , oFont14n)
		oPrinter:Say(nLin, 200,"Veiculo:  " + AllTrim(Posicione("DA3",1,xFilial("DA3")+_cVeiculo,"DA3_PLACA")) , oFont14n)
		oPrinter:Say(nLin, 400,"Emissão:  " + Substr(_dDataCarga,7,2)+"/"+Substr(_dDataCarga,5,2)+"/"+Substr(_dDataCarga,1,4), oFont14n)
	Else 
		oPrinter:Say(nLin, 330,"Emissão: __/__/____" , oFont14n)
	EndIf 

	nLin += 20
	
	oPrinter:Say(nLin, 20, "Nome Transp: " + AllTrim(Posicione("SA4",1,xFilial("SA4")+_cTransporte,"A4_NOME")); 
		+ "  Nome Motorista: "+AllTrim(Posicione("DA4",1,xFilial("DA4")+_cMotorista,"DA4_NOME")), oFont14n)
	nLin += 20

	oPrinter:Say(nLin, 20, "Volume Total: " + cVolumesW, oFont14n)
	nLin += 20

	oPrinter:Say(nLin, 20, "Pes.Bruto: " + TransForm(_nPesBruTotal, "@E 999,999.99"), oFont14n)
	oPrinter:Say(nLin, 150,"Valor Total: " + TransForm(_nVlTotalped, "@E 999,999.99"), oFont14n)
	nLin += 10
	oPrinter:Line(nLin,10,nLin,585)
	nLin += 10

	oPrinter:Say(nLin, 10, "IT - Empresa    - Pedido   - Ord.Sep  - Razao Social         - Peso Bruto   - Vlr.Total  - Volume/Especie", oFont10n)

Return
/*
+------------+------------+--------+---------------+-------+--------------+
| Programa:  | EQVldAlt   | Autor: | QUALY         | Data: | 02/05/21     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - EQVldAlt                                      |
+------------+------------------------------------------------------------+
*/

Static Function EQVldAlt(nTipo)

Local lRet 		:= .T.

Return lRet

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

Aadd(_aPerg,{"Pedido Vendas De  ..?"        ,"mv_ch1","C",06,"G","mv_par01","","","","","","SC5" ,"","",0})
Aadd(_aPerg,{"Pedido Vendas Até ..?"        ,"mv_ch2","C",06,"G","mv_par02","","","","","","SC5" ,"","",0})
Aadd(_aPerg,{"Ordem Separação De..?"        ,"mv_ch3","C",06,"G","mv_par03","","","","","","CB7" ,"","",0})
Aadd(_aPerg,{"Ordem Separação Até.?"        ,"mv_ch4","C",06,"G","mv_par04","","","","","","CB7" ,"","",0})
Aadd(_aPerg,{"Data Emisao OS De ..?"        ,"mv_ch5","D",08,"G","mv_par05","","","","","",""    ,"","",0})
Aadd(_aPerg,{"Data Emisao OS Até..?"        ,"mv_ch6","D",08,"G","mv_par06","","","","","",""    ,"","",0})
Aadd(_aPerg,{"Numero da Carga ....?"        ,"mv_ch7","C",06,"G","mv_par07","","","","","","DAK" ,"","",0})

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



