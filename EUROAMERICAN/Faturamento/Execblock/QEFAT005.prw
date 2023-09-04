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
	Private _cPerg := "QEFTRA5"

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
	Local cQueryW        := ""
	Local cQuery2        := ""

	Local _nVolSep       := 0

	Private _cPedido     := ""
	Private _cOrdSep     := ""
	Private _cItem       := 0
	Private _aPedido     := {}
	Private _aOrdemSep   := {}
	Private aVolumes     := {}
	Private aVolumesW    := {}

	Private	_lVeiculo    := .F.
	Private	_lTransporte := .F.
	Private	_lMotorista  := .F.
	
	Private k            := 1
	Private nVal         := 0
	Private nTotal       := 0
	Private nValFd		 := 0	
	Private _nTotal      := 0

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
		
	SM0->(DbSetOrder(1))
	
	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf

	cQuery := "SELECT DAI_FILIAL, DAI_COD, DAI_CLIENT, DAI_LOJA, DAI_PESO, DAI_DATA, DAI_HORA,DAI_XVALPD,  " + ENTER
	cQuery += "DAK_FILIAL, DAK_COD, DAK_SEQCAR, DAK_CAMINH, DAK_DATA, DAK_TRANSP, DAK_MOTORI, DAI_PEDIDO,  " + ENTER 
	cQuery += "DAI_XESP1, DAI_XVOL1, " + ENTER
	cQuery += "DAI_XESP2, DAI_XVOL2, " + ENTER
	cQuery += "DAI_XESP3, DAI_XVOL3, " + ENTER
	cQuery += "DAI_XESP4, DAI_XVOL4, " + ENTER
	cQuery += "DAI_XESP5, DAI_XVOL5, " + ENTER
	cQuery += "DAI_XESP6, DAI_XVOL6, " + ENTER
	cQuery += "DAI_XESP7, DAI_XVOL7, " + ENTER
	cQuery += "DAI_XESP8, DAI_XVOL8, " + ENTER
	cQuery += "DAI_XESP9, DAI_XVOL9, " + ENTER
	cQuery += "DAI_XESP10, DAI_XVOL10, " + ENTER
	cQuery += "DAI_XESP11, DAI_XVOL11, " + ENTER
	cQuery += "DAI_XESP12, DAI_XVOL12, " + ENTER
	cQuery += "DAI_XESP13, DAI_XVOL13, " + ENTER
	cQuery += "DAI_XESP14, DAI_XVOL14, " + ENTER
	cQuery += "DAI_XESP15, DAI_XVOL15, " + ENTER
	cQuery += "DAI_XVDF1, DAI_XDIF1, " + ENTER
	cQuery += "DAI_XVDF2, DAI_XDIF2, " + ENTER
	cQuery += "DAI_XVDF3, DAI_XDIF3, " + ENTER
	cQuery += "DAI_XVDF4, DAI_XDIF4, " + ENTER
	cQuery += "DAI_XVDF5, DAI_XDIF5, " + ENTER
	cQuery += "DAI_XVDF6, DAI_XDIF6, " + ENTER
	cQuery += "DAI_XVDF7, DAI_XDIF7, " + ENTER
	cQuery += "DAI_XVDF8, DAI_XDIF8, " + ENTER
	cQuery += "DAI_XVDF9, DAI_XDIF9, " + ENTER
	cQuery += "DAI_XVDF10, DAI_XDIF10 " + ENTER
	cQuery += " FROM  " + RetSqlName("DAI") + " AS DAI " + ENTER
	cQuery += "INNER JOIN " + RetSqlName("DAK") + " AS DAK ON DAI_FILIAL = DAK_FILIAL " + ENTER
	cQuery += " AND DAK_COD = DAI_COD  " + ENTER
	cQuery += " AND DAI.D_E_L_E_T_ = ' '   " + ENTER
	cQuery += "WHERE DAI_FILIAL = '"+xFilial("DAI")+"' " + ENTER
	cQuery += " AND DAI_PEDIDO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  " + ENTER
	cQuery += " AND DAI_DATA   BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"' " + ENTER
	cQuery += " AND DAI_COD = '"+MV_PAR05+"' " + ENTER
	cQuery += " AND DAK_MOTORI <> ' '  " + ENTER
 	cQuery += " AND DAK_CAMINH <> ' '  " + ENTER
 	cQuery += " AND DAK_TRANSP <> ' '  " + ENTER
	cQuery += " AND DAI.D_E_L_E_T_ = ' ' " + ENTER
	cQuery += " ORDER BY DAI_PEDIDO   " + ENTER

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

	cQueryC := "SELECT DAK_FILIAL, DAK_COD, DAK_SEQCAR, DAK_CAMINH, DAK_DATA, DAK_TRANSP, DAK_MOTORI " + ENTER 
	cQueryC += " FROM  " + RetSqlName("DAK") + " AS DAK " + ENTER
	cQueryC += "WHERE DAK_FILIAL = '"+xFilial("DAK")+"' " + ENTER
	cQueryC += " AND DAK_COD = '"+MV_PAR05+"' " + ENTER
	cQueryC += " AND DAK_MOTORI <> ' '  " + ENTER
 	cQueryC += " AND DAK_CAMINH <> ' '  " + ENTER
 	cQueryC += " AND DAK_TRANSP <> ' '  " + ENTER
	cQueryC += " AND DAK.D_E_L_E_T_ = ' ' " + ENTER
	
	TcQuery cQueryC ALIAS "TRBC" NEW

	TRBC->(DbGoTop())
	
	While TRBC->(!Eof())

		_cCodCarga   := TRBC->DAK_COD
		_cSeqCar     := TRBC->DAK_SEQCAR
		_cVeiculo 	 := TRBC->DAK_CAMINH
		_dDataCarga	 := TRBC->DAK_DATA
		_cTransporte := TRBC->DAK_TRANSP
		_cMotorista  := TRBC->DAK_MOTORI

		If Empty(_cVeiculo)
			_lVeiculo := .T.
			Exit
		ElseIf Empty(_cTransporte)
			_lTransporte := .T.
			Exit
		ElseIf Empty(_cMotorista)
			_lMotorista := .T.
			Exit
		EndIf 

		TRBC->(DbSkip())

	EndDo
	
	If _lVeiculo

		Aviso("Atenção !!!" ,"Obrigatorio informar o Veiculo na Carga "+_cCodCarga ,{"OK"})

		If Select("TRB1") > 0
			TRB1->(DbCloseArea())
		EndIf

		SM0->(DbGoTo(nRegSM0))

		Return

	EndIf

	If _lMotorista

		Aviso("Atenção !!!" ,"Obrigatorio informar o Motorista na Carga "+_cCodCarga ,{"OK"})

		If Select("TRB1") > 0
			TRB1->(DbCloseArea())
		EndIf

		SM0->(DbGoTo(nRegSM0))

		Return

	EndIf

	If _lTransporte

		Aviso("Atenção !!!" ,"Obrigatorio informar a Transportadora na Carga "+_cCodCarga ,{"OK"})

		If Select("TRB1") > 0
			TRB1->(DbCloseArea())
		EndIf

		SM0->(DbGoTo(nRegSM0))

		Return

	EndIf

	// Tratamento para impressão total dos Volumes no cabeçalho 

	If Select("TRBW") > 0
		TRBW->(DbCloseArea())
	EndIf

	cQueryW := "SELECT SUM(DAI_XVALPD) AS VLPEDIDO, SUM(DAI_PESO) AS PESOBRUTO, " + ENTER
	cQueryW += "SUM(DAI_XVOL1)  AS DAI_XVOL1,  DAI_XESP1,  "+ ENTER 
	cQueryW += "SUM(DAI_XVDF1)  AS DAI_XVDF1,  DAI_XDIF1,  "+ ENTER
	cQueryW += "SUM(DAI_XVOL2)  AS DAI_XVOL2,  DAI_XESP2,  "+ ENTER
	cQueryW += "SUM(DAI_XVDF2)  AS DAI_XVDF2,  DAI_XDIF2,  "+ ENTER
	cQueryW += "SUM(DAI_XVOL3)  AS DAI_XVOL3,  DAI_XESP3,  "+ ENTER 
	cQueryW += "SUM(DAI_XVDF3)  AS DAI_XVDF3,  DAI_XDIF3,  "+ ENTER
	cQueryW += "SUM(DAI_XVOL4)  AS DAI_XVOL4,  DAI_XESP4,  "+ ENTER
	cQueryW += "SUM(DAI_XVDF4)  AS DAI_XVDF4,  DAI_XDIF4,  "+ ENTER
	cQueryW += "SUM(DAI_XVOL5)  AS DAI_XVOL5,  DAI_XESP5,  "+ ENTER
	cQueryW += "SUM(DAI_XVDF5)  AS DAI_XVDF5,  DAI_XDIF5,  "+ ENTER
	cQueryW += "SUM(DAI_XVOL6)  AS DAI_XVOL6,  DAI_XESP6,  "+ ENTER
	cQueryW += "SUM(DAI_XVDF6)  AS DAI_XVDF6,  DAI_XDIF6,  "+ ENTER
	cQueryW += "SUM(DAI_XVOL7)  AS DAI_XVOL7,  DAI_XESP7,  "+ ENTER
	cQueryW += "SUM(DAI_XVDF7)  AS DAI_XVDF7,  DAI_XDIF7,  "+ ENTER
	cQueryW += "SUM(DAI_XVOL8)  AS DAI_XVOL8,  DAI_XESP8,  "+ ENTER
	cQueryW += "SUM(DAI_XVDF8)  AS DAI_XVDF8,  DAI_XDIF8,  "+ ENTER
	cQueryW += "SUM(DAI_XVOL9)  AS DAI_XVOL9,  DAI_XESP9,  "+ ENTER
	cQueryW += "SUM(DAI_XVDF9)  AS DAI_XVDF9,  DAI_XDIF9,  "+ ENTER
	cQueryW += "SUM(DAI_XVOL10) AS DAI_XVOL10, DAI_XESP10, "+ ENTER
	cQueryW += "SUM(DAI_XVDF10) AS DAI_XVDF10, DAI_XDIF10, "+ ENTER
	cQueryW += "SUM(DAI_XVOL11) AS DAI_XVOL11, DAI_XESP11, "+ ENTER
	cQueryW += "SUM(DAI_XVOL12) AS DAI_XVOL12, DAI_XESP12, "+ ENTER
	cQueryW += "SUM(DAI_XVOL13) AS DAI_XVOL13, DAI_XESP13, "+ ENTER
	cQueryW += "SUM(DAI_XVOL14) AS DAI_XVOL14, DAI_XESP14, "+ ENTER
	cQueryW += "SUM(DAI_XVOL15) AS DAI_XVOL15, DAI_XESP15 "+ ENTER
	cQueryW += " FROM  " + RetSqlName("DAI") + " AS DAI " + ENTER
	cQueryW += "INNER JOIN " + RetSqlName("DAK") + " AS DAK ON DAK_FILIAL = DAI_FILIAL " + ENTER
	cQueryW += " AND DAK_COD = DAI_COD  " + ENTER
	cQueryW += " AND DAK.D_E_L_E_T_ = ' '   " + ENTER
	cQueryW += "WHERE DAI.DAI_FILIAL = '"+xFilial("DAI")+"' " + ENTER
	cQueryW += " AND  DAI.DAI_PEDIDO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  " + ENTER
	cQueryW += " AND DAK.DAK_DATA BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"' " + ENTER
	cQueryW += " AND DAK.DAK_MOTORI <> ' '  " + ENTER
	cQueryW += " AND DAK.DAK_CAMINH <> ' '  " + ENTER
	cQueryW += " AND DAK.DAK_TRANSP <> ' '  " + ENTER
 	cQueryW += " AND DAK.DAK_COD = '"+MV_PAR05+"' " + ENTER
	cQueryW += " AND DAI.D_E_L_E_T_ = ' '  " + ENTER
	cQueryW += "GROUP BY DAI_XESP1,DAI_XESP2, DAI_XESP3, DAI_XESP4, DAI_XESP5, DAI_XESP6, DAI_XESP7, DAI_XESP8, DAI_XESP9, DAI_XESP10,  " + ENTER
	cQueryW += " DAI_XESP11,DAI_XESP12, DAI_XESP13, DAI_XESP14, DAI_XESP15,DAI_XDIF1, DAI_XDIF2, DAI_XDIF3, DAI_XDIF4, DAI_XDIF5, DAI_XDIF6, " + ENTER
	cQueryW += " DAI_XDIF7, DAI_XDIF8, DAI_XDIF9, DAI_XDIF10 " + ENTER

	TcQuery cQueryW ALIAS "TRBW" NEW

	TRBW->(DbGoTop())

	While TRBW->(!Eof())

		// Valor total de pedido de vendas e total do peso na carga 
		
		_nVlTotalped  := TRBW->VLPEDIDO
		_nPesBruTotal := TRBW->PESOBRUTO

		// Tratamento dos volumes e especies que serão apresentado no cabeçalho

		cVolumesW := Alltrim(Iif(TRBW->DAI_XVOL1 > 0,Transform(TRBW->DAI_XVOL1,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XESP1),AllTrim(TRBW->DAI_XESP1)+"/", " " ))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVDF1 > 0,Transform(TRBW->DAI_XVDF1,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XDIF1),AllTrim(TRBW->DAI_XDIF1)+"/", " " ))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVOL2 > 0,Transform(TRBW->DAI_XVOL2,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XESP2),AllTrim(TRBW->DAI_XESP2)+"/"," "))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVDF2 > 0,Transform(TRBW->DAI_XVDF2,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XDIF2),AllTrim(TRBW->DAI_XDIF2)+"/"," "))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVOL3 > 0,Transform(TRBW->DAI_XVOL3,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XESP3),AllTrim(TRBW->DAI_XESP3)+"/"," "))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVDF3 > 0,Transform(TRBW->DAI_XVDF3,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XDIF3),AllTrim(TRBW->DAI_XDIF3)+"/", " "))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVOL4 > 0,Transform(TRBW->DAI_XVOL4,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XESP4),AllTrim(TRBW->DAI_XESP4)+"/", " "))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVDF4 > 0,Transform(TRBW->DAI_XVDF4,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XDIF4),AllTrim(TRBW->DAI_XDIF4)+"/", " "))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVOL5 > 0,Transform(TRBW->DAI_XVOL5,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XESP5),AllTrim(TRBW->DAI_XESP5)+"/", " "))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVDF5 > 0,Transform(TRBW->DAI_XVDF5,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XDIF5),AllTrim(TRBW->DAI_XDIF5)+"/", " "))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVOL6 > 0,Transform(TRBW->DAI_XVOL6,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XESP6),AllTrim(TRBW->DAI_XESP6)+"/", " "))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVDF6 > 0,Transform(TRBW->DAI_XVDF6,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XDIF6),AllTrim(TRBW->DAI_XDIF6)+"/", " "))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVOL7 > 0,Transform(TRBW->DAI_XVOL7,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XESP7),AllTrim(TRBW->DAI_XESP7)+"/", " "))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVDF7 > 0,Transform(TRBW->DAI_XVDF7,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XDIF7),AllTrim(TRBW->DAI_XDIF7)+"/", " "))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVOL8 > 0,Transform(TRBW->DAI_XVOL8,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XESP8),AllTrim(TRBW->DAI_XESP8)+"/", " "))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVDF8 > 0,Transform(TRBW->DAI_XVDF8,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XDIF8),AllTrim(TRBW->DAI_XDIF8)+"/", " "))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVOL9 > 0,Transform(TRBW->DAI_XVOL9,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XESP9),AllTrim(TRBW->DAI_XESP9)+"/", " "))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVDF9 > 0,Transform(TRBW->DAI_XVDF9,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XDIF9),AllTrim(TRBW->DAI_XDIF9)+"/", " "))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVOL10 > 0,Transform(TRBW->DAI_XVOL10,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XESP10),AllTrim(TRBW->DAI_XESP10)+"/", " "))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVDF10 > 0,Transform(TRBW->DAI_XVDF10,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XDIF10),AllTrim(TRBW->DAI_XDIF10)+"/", " "))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVOL11 > 0,Transform(TRBW->DAI_XVOL11,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XESP11),AllTrim(TRBW->DAI_XESP11)+"/", " "))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVOL12 > 0,Transform(TRBW->DAI_XVOL12,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XESP12),AllTrim(TRBW->DAI_XESP12)+"/", " "))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVOL13 > 0,Transform(TRBW->DAI_XVOL13,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XESP13),AllTrim(TRBW->DAI_XESP13)+"/", " "))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVOL14 > 0,Transform(TRBW->DAI_XVOL14,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XESP14),AllTrim(TRBW->DAI_XESP14)+"/", " "))
		cVolumesW += Alltrim(Iif(TRBW->DAI_XVOL15 > 0,Transform(TRBW->DAI_XVOL15,"@E 99,999")+"-", " "))
		cVolumesW += Alltrim(Iif(!Empty(TRBW->DAI_XESP15),AllTrim(TRBW->DAI_XESP15), " "))

		TRBW->(DbSkip())
		
	EndDo

	//impressão cabeçalho 
	
	qefat05c()
	
	nLin := 120

	// Impressão dos itens que constam na tabela DAI
		
	While TRB1->(!Eof())
				
		If nLin > 800  //Quebra de pagina
			oPrinter:Line(800,10,800,585)
			oPrinter:EndPage()
			oPrinter:StartPage()
			qefat05c()
			nLin := 140
		EndIf
		
		_aOrdemSep := {}

		If Select("TRB2") > 0
			TRB2->(DbCloseArea())
		EndIf

		cQuery2 := "SELECT CB7_PEDIDO, CB7_ORDSEP " + ENTER
		cQuery2 += " FROM  " + RetSqlName("CB7") + " AS CB7 " + ENTER
		cQuery2 += "WHERE CB7_FILIAL = '"+xFilial("CB7")+"' " + ENTER
		cQuery2 += " AND CB7_PEDIDO  = '"+TRB1->DAI_PEDIDO+"'     "+CRLF
		cQuery2 += " AND CB7.D_E_L_E_T_ = ' ' " + ENTER

		TcQuery cQuery2 ALIAS "TRB2" NEW

		TRB2->(DbGoTop())
			
		While TRB2->(!Eof())

			aAdd(_aOrdemSep,{TRB2->CB7_ORDSEP,TRB2->CB7_PEDIDO})  

			TRB2->(DbSkip())

		EndDo
	
		For _nVolSep := 1 To Len(_aOrdemSep)

			If _nVolSep >= 2
				_cOrdSep  += "/"+AllTrim(_aOrdemSep[_nVolSep][1])
			Else 
				_cOrdSep  := AllTrim(_aOrdemSep[_nVolSep][1])
			EndIf 

		Next _nVolSep
		
		_cItem++
		_cPedido  := TRB1->DAI_PEDIDO
		_cNomeCli :=  AllTrim(Posicione("SA1",1,xFilial("SA1")+TRB1->DAI_CLIENT+TRB1->DAI_LOJA,"A1_NOME"))
		_nPBRUTO  := TRB1->DAI_PESO
		nTotal    := TRB1->DAI_XVALPD

		cVolumes := AllTrim(Iif(TRB1->DAI_XVOL1 > 0,Transform(TRB1->DAI_XVOL1,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XESP1),AllTrim(TRB1->DAI_XESP1)+"/", " " ))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVDF1 > 0,Transform(TRB1->DAI_XVDF1,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XDIF1),AllTrim(TRB1->DAI_XDIF1)+"/", " " ))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVOL2 > 0,Transform(TRB1->DAI_XVOL2,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XESP2),AllTrim(TRB1->DAI_XESP2)+"/"," "))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVDF2 > 0,Transform(TRB1->DAI_XVDF2,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XDIF2),AllTrim(TRB1->DAI_XDIF2)+"/"," "))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVOL3 > 0,Transform(TRB1->DAI_XVOL3,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XESP3),AllTrim(TRB1->DAI_XESP3)+"/"," "))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVDF3 > 0,Transform(TRB1->DAI_XVDF3,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XDIF3),AllTrim(TRB1->DAI_XDIF3)+"/", " "))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVOL4 > 0,Transform(TRB1->DAI_XVOL4,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XESP4),AllTrim(TRB1->DAI_XESP4)+"/", " "))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVDF4 > 0,Transform(TRB1->DAI_XVDF4,"@E 99,999")+"-", " ")) 
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XDIF4),AllTrim(TRB1->DAI_XDIF4)+"/", " "))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVOL5 > 0,Transform(TRB1->DAI_XVOL5,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XESP5),AllTrim(TRB1->DAI_XESP5)+"/", " "))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVDF5 > 0,Transform(TRB1->DAI_XVDF5,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XDIF5),AllTrim(TRB1->DAI_XDIF5)+"/", " "))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVOL6 > 0,Transform(TRB1->DAI_XVOL6,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XESP6),AllTrim(TRB1->DAI_XESP6)+"/", " "))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVDF6 > 0,Transform(TRB1->DAI_XVDF6,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XDIF6),AllTrim(TRB1->DAI_XDIF6)+"/", " "))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVOL7 > 0,Transform(TRB1->DAI_XVOL7,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XESP7),AllTrim(TRB1->DAI_XESP7)+"/", " "))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVDF7 > 0,Transform(TRB1->DAI_XVDF7,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XDIF7),AllTrim(TRB1->DAI_XDIF7)+"/", " "))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVOL8 > 0,Transform(TRB1->DAI_XVOL8,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XESP8),AllTrim(TRB1->DAI_XESP8)+"/", " "))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVDF8 > 0,Transform(TRB1->DAI_XVDF8,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XDIF8),AllTrim(TRB1->DAI_XDIF8)+"/", " "))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVOL9 > 0,Transform(TRB1->DAI_XVOL9,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XESP9),AllTrim(TRB1->DAI_XESP9)+"/", " "))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVDF9 > 0,Transform(TRB1->DAI_XVDF9,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XDIF9),AllTrim(TRB1->DAI_XDIF9)+"/", " "))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVOL10 > 0,Transform(TRB1->DAI_XVOL10,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XESP10),AllTrim(TRB1->DAI_XESP10)+"/", " "))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVDF10 > 0,Transform(TRB1->DAI_XVDF10,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XDIF10),AllTrim(TRB1->DAI_XDIF10)+"/", " "))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVOL11 > 0,Transform(TRB1->DAI_XVOL11,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XESP11),AllTrim(TRB1->DAI_XESP11)+"/", " "))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVOL12 > 0,Transform(TRB1->DAI_XVOL12,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XESP12),AllTrim(TRB1->DAI_XESP12)+"/", " "))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVOL13 > 0,Transform(TRB1->DAI_XVOL13,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XESP13),AllTrim(TRB1->DAI_XESP13)+"/", " "))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVOL14 > 0,Transform(TRB1->DAI_XVOL14,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XESP14),AllTrim(TRB1->DAI_XESP14)+"/", " "))
		cVolumes += AllTrim(Iif(TRB1->DAI_XVOL15 > 0,Transform(TRB1->DAI_XVOL15,"@E 99,999")+"-", " "))
		cVolumes += AllTrim(Iif(!Empty(TRB1->DAI_XESP15),AllTrim(TRB1->DAI_XESP15), " "))
		
		cString := TransForm(_cItem, "@E 99")  + " - " + SubStr(Alltrim(_cFilNome), 1, 10) + " - "
		cString += _cPedido+ " - " + _cOrdSep + "   - " + SubStr(_cNomeCli, 1, 20) + " - "
		cString += TransForm(_nPBRUTO, "@E 99,999.9999") + " - "
		cString += TransForm(nTotal, "@E 9,999,999.99") + " - "
		cString += Alltrim(cVolumes) 

		oPrinter:Say(nLin, 10, cString, oFont10)
			
		nLin += 15
		
		cVolumes   := " "
		_aOrdemSep := {}
		_cOrdSep   := " "

		TRB1->(DbSkip())

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

	If Select("TRB2") > 0
		TRB2->(DbCloseArea())
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
	
	If !Select("DAK")>0
		DbSelectArea("DAK") 
	EndIf
	DAK->(DbSetOrder(1))
	DAK->(DbGotop())
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
Aadd(_aPerg,{"Dt. Carga Emisao De.?"        ,"mv_ch3","D",08,"G","mv_par03","","","","","",""    ,"","",0})
Aadd(_aPerg,{"Dt. Carga Emisao Até?"        ,"mv_ch4","D",08,"G","mv_par04","","","","","",""    ,"","",0})
Aadd(_aPerg,{"Numero da Carga ....?"        ,"mv_ch5","C",06,"G","mv_par05","","","","","","DAK" ,"","",0})

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



