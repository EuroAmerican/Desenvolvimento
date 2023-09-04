#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'Colors.Ch'
#Include 'JPeg.Ch'
#Include 'HButton.Ch'
#Include 'DBTree.Ch'
#Include 'Font.Ch'
#Include 'TbiConn.Ch'
#Include 'Ap5Mail.Ch'

// Consulta Específica Produto (MATC050 - Produto)

User Function EQConPrd()

Local aArea := GetArea()

Private oFontMsg     := TFont():New('Courier new',,-14,.T.)
Private oFontPar     := TFont():New('Arial'      ,,-13,.T.,,,,,,.F.,.T.)
Private oFontPar1    := TFont():New('Arial'      ,,-11,.T.,,,,,,.F.,.F.)
Private oFontRes1    := TFont():New('Courier new',,-11,.F.)
Private oFontRes2    := TFont():New('Courier new',,-16,.T.)
Private oFontRes3    := TFont():New('Arial'      ,,-18,.T.,,,,,,.F.,.F.)

	DEFINE MSDIALOG oDlgCFG TITLE "EQConPrd - Consulta de Produtos" FROM 000, 000  TO 506, 785 PIXEL
	
		aTFolder := {'Dados Cadastrais','Saldos em Estoques','Saldos Por Lotes','Saldos Por Endereços','Entradas NF','Saídas NF','Movimentações e Produção' }
		oTFolder := TFolder():New( 0,0,aTFolder,,oDlgCFG,,,,.T.,,C(309),C(174))
	
		oGroup:= TGroup():New(C(003),C(005),C(092),C(303), 'Dados Cadastrais do Produto: ' + AllTrim( SB1->B1_COD ) + ' | ' + AllTrim( SB1->B1_DESC ), oTFolder:aDialogs[1],,,.T.)

		oSayPar := TSay():New(C(014),C(010),{||'Produto: ' + SB1->B1_COD + ' Descrição: ' + AllTrim( SB1->B1_DESC )},oTFolder:aDialogs[1],,oFontMsg ,,,,.T.,CLR_RED,CLR_WHITE,400,20)
		oSayPar := TSay():New(C(026),C(010),{||'Tipo: ' + AllTrim( SB1->B1_TIPO ) + ' - ' + AllTrim( Posicione("SX5", 1, "  " + "02" + SB1->B1_TIPO, "X5_DESCRI") ) + ' Peso Líquido: ' + AllTrim( Transform( SB1->B1_PESO, "@R 999,999.99") ) + ' Peso Bruto: ' + AllTrim( Transform( SB1->B1_PESBRU, "@R 999,999.99") )},oTFolder:aDialogs[1],,oFontRes1,,,,.T.,CLR_BLACK,CLR_WHITE,400,20)
		oSayPar := TSay():New(C(036),C(010),{||'Unidade Medida: ' + AllTrim( SB1->B1_UM ) + ' - ' + AllTrim( Posicione("SAH", 1, xFilial("SAH") + SB1->B1_UM, "AH_DESCPO") ) + ' Segunda UM: ' + AllTrim( SB1->B1_SEGUM ) + ' - ' + AllTrim( Posicione("SAH", 1, xFilial("SAH") + SB1->B1_SEGUM, "AH_DESCPO") ) + ' Conversão: ' + IIf( SB1->B1_TIPCONV == "D", "Divisor", "Multiplicador" ) + ' Fator: ' + AllTrim( Transform( SB1->B1_CONV, "@R 999,999.99") )},oTFolder:aDialogs[1],,oFontRes1,,,,.T.,CLR_BLACK,CLR_WHITE,400,20)
		oSayPar := TSay():New(C(046),C(010),{||'Rastro: ' + IIf( SB1->B1_RASTRO == "L", "Controla Lote", IIf( SB1->B1_RASTRO == "S", "Controla Sub-Lote", "Não Controla")) + ' Endereçamento? ' + IIf( SB1->B1_LOCALIZ == "S", "Sim", "Não") + ' Calcula MRP? ' + IIf( SB1->B1_MRP == "S", "Sim", "Não")},oTFolder:aDialogs[1],,oFontRes1,,,,.T.,CLR_BLACK,CLR_WHITE,400,20)

		oGroup:= TGroup():New(C(095),C(005),C(159),C(303), 'Estoque', oTFolder:aDialogs[1],,,.T.)

		cQuery := "SELECT SUM(B2_QATU) FROM " + RetSqlName("SB2") + " AS SB2 "
		cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' "
		cQuery += "AND B2_COD = '" + SB1->B1_COD + "' "
		cQuery += "AND SB2.D_E_L_E_T_ = ' ' "

		oGroup:= TGroup():New(C(003),C(005),C(159),C(303), 'Saldos em Estoques: ' + AllTrim( SB1->B1_COD ) + ' | ' + AllTrim( SB1->B1_DESC ), oTFolder:aDialogs[2],,,.T.)
		oGroup:= TGroup():New(C(003),C(005),C(159),C(303), 'Saldos Por Lotes: ' + AllTrim( SB1->B1_COD ) + ' | ' + AllTrim( SB1->B1_DESC ), oTFolder:aDialogs[3],,,.T.)
		oGroup:= TGroup():New(C(003),C(005),C(159),C(303), 'Saldos Por Endereços: ' + AllTrim( SB1->B1_COD ) + ' | ' + AllTrim( SB1->B1_DESC ), oTFolder:aDialogs[4],,,.T.)
		oGroup:= TGroup():New(C(003),C(005),C(159),C(303), 'Entradas NF: ' + AllTrim( SB1->B1_COD ) + ' | ' + AllTrim( SB1->B1_DESC ), oTFolder:aDialogs[5],,,.T.)
		oGroup:= TGroup():New(C(003),C(005),C(159),C(303), 'Saídas NF: ' + AllTrim( SB1->B1_COD ) + ' | ' + AllTrim( SB1->B1_DESC ), oTFolder:aDialogs[6],,,.T.)
		oGroup:= TGroup():New(C(003),C(005),C(159),C(303), 'Movimentações e Produção: ' + AllTrim( SB1->B1_COD ) + ' | ' + AllTrim( SB1->B1_DESC ), oTFolder:aDialogs[7],,,.T.)

		@ C(176),C(191) Button "Legenda"   Size C(037),C(010) Action (U_XCFGLeg()) PIXEL OF oDlgCFG
		@ C(176),C(231) Button "Cancelar"  Size C(037),C(010) Action (lConfirmado := .F., oDlgCFG:End()) PIXEL OF oDlgCFG
		@ C(176),C(271) Button "Confirmar" Size C(037),C(010) Action (lConfirmado := .T., oDlgCFG:End()) PIXEL OF oDlgCFG
	
	ACTIVATE MSDIALOG oDlgCFG CENTERED

RestArea( aArea )

Return