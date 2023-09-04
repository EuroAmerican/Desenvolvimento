#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

User Function EQReProgC7()

Local aArea       := GetArea()
Local aAreaSA2    := SA2->( GetArea() )
Local aAreaSB1    := SB1->( GetArea() )
Local aAreaSC7    := SC7->( GetArea() )
Local nLinha      := 0

Private oFontMsg  := TFont():New( "Courier New",,14,,.T.,,,,,.F. )
Private oOk       := LoadBitmap( GetResources(), "LBOK")
Private oNo       := LoadBitmap( GetResources(), "LBNO")
Private lConfirma := .F.
Private aPedido   := {}
Private cQuery    := ""

dbSelectArea("SA2")
dbSetOrder(1)
SA2->( dbSeek( xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA ) )

If SC7->C7_ENCER == "E"
	ApMsgAlert( "Pedido de Compras Encerrado!", "Atenção - Reprogramação Não Permitida")
	Return
EndIf

If SC7->C7_QUANT == SC7->C7_QUJE
	ApMsgAlert( "Item do pedido de compras já atendido / entregue!", "Atenção - Reprogramação Não Permitida")
	Return
EndIf

If SC7->C7_CONAPRO <> "L"
	ApMsgAlert( "Pedido de Compras não aprovado, selecione a opção Alterar!", "Atenção - Reprogramação Não Permitida")
	Return
EndIf

cQuery := "SELECT C7_NUM, C7_ITEM, C7_PRODUTO, C7_DESCRI, C7_UM, C7_SEGUM, C7_QUANT, C7_QTSEGUM, C7_PRECO, C7_TOTAL, C7_DATPRF, C7_OBS " + CRLF
cQuery += "FROM " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) " + CRLF
cQuery += "WHERE C7_FILIAL = '" + xFilial("SC7") + "' " + CRLF
cQuery += "AND C7_NUM = '" + SC7->C7_NUM + "' " + CRLF
cQuery += "AND C7_QUANT > C7_QUJE " + CRLF
cQuery += "AND C7_ENCER <> 'E' " + CRLF
cQuery += "AND C7_CONAPRO = 'L' " + CRLF
cQuery += "AND SC7.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "ORDER BY C7_NUM, C7_ITEM " + CRLF

TCQuery cQuery New Alias "TMPSC7"
dbSelectArea("TMPSC7")
dbGoTop()

Do While !TMPSC7->( Eof() )
	aAdd( aPedido, { TMPSC7->C7_ITEM,;
	                 TMPSC7->C7_PRODUTO,;
	                 TMPSC7->C7_DESCRI,;
	                 STOD(TMPSC7->C7_DATPRF),;
	                 TMPSC7->C7_UM,;
	                 TMPSC7->C7_SEGUM,;
	                 TMPSC7->C7_QUANT,;
	                 TMPSC7->C7_QTSEGUM,;
	                 TMPSC7->C7_PRECO,;
	                 TMPSC7->C7_TOTAL,;
	                 TMPSC7->C7_NUM,;
	                 TMPSC7->C7_OBS })

	TMPSC7->( dbSkip() )
EndDo

TMPSC7->( dbCloseArea() )

DEFINE MSDIALOG oDlgAdiant TITLE "Reprogramação de Entregas do Pedido: " + SC7->C7_NUM FROM 000, 000  TO 296, 785 PIXEL

	aTFolder := {'Ajustar datas de entregas do pedido de compras'}
	oTFolder := TFolder():New( 0,0,aTFolder,,oDlgAdiant,,,,.T.,,C(309),C(094))

	oGroup:= TGroup():New(C(003),C(005),C(077),C(303), 'Duplo-clique para alterar a data de entrega', oTFolder:aDialogs[1],,,.T.)

	oLbx := TcBrowse():New(C(010),C(010),C(289),C(066),,,,oTFolder:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)

	//oLbx:AddColumn( TCColumn():New(" "                  ,{ || If(aPedido[oLbx:nAt,01],oOk,oNo) },                       ,,,        ,,.T.,.F.,,,,.F.,) )
	oLbx:AddColumn( TcColumn():New("Item"               ,{ || aPedido[oLbx:nAt,01] }   ,""                              ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oLbx:AddColumn( TcColumn():New("Produto"            ,{ || aPedido[oLbx:nAt,02] }   ,""                              ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oLbx:AddColumn( TcColumn():New("Descrição"          ,{ || aPedido[oLbx:nAt,03] }   ,""                              ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oLbx:AddColumn( TcColumn():New("Data Entrega"       ,{ || aPedido[oLbx:nAt,04] }   ,""                              ,,,"CENTER",,.F.,.F.,,,,.F.,) )
	oLbx:AddColumn( TcColumn():New("UM"                 ,{ || aPedido[oLbx:nAt,05] }   ,""                              ,,,"CENTER",,.F.,.F.,,,,.F.,) )
	oLbx:AddColumn( TcColumn():New("Seg. UM"            ,{ || aPedido[oLbx:nAt,06] }   ,""                              ,,,"CENTER",,.F.,.F.,,,,.F.,) )
	oLbx:AddColumn( TcColumn():New("Quantidade"         ,{ || aPedido[oLbx:nAt,07] }   ,PesqPict("SC7","C7_QUANT")      ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )
	oLbx:AddColumn( TcColumn():New("Preço"              ,{ || aPedido[oLbx:nAt,09] }   ,PesqPict("SC7","C7_PRECO")      ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )
	oLbx:AddColumn( TcColumn():New("Total"              ,{ || aPedido[oLbx:nAt,10] }   ,PesqPict("SC7","C7_TOTAL")      ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )
	oLbx:AddColumn( TcColumn():New("Qtd. Seg. UM"       ,{ || aPedido[oLbx:nAt,08] }   ,PesqPict("SC7","C7_QTSEGUM")    ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )
	oLbx:AddColumn( TcColumn():New("Observação"         ,{ || aPedido[oLbx:nAt,12] }   ,""                              ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )

	oLbx:SetArray( aPedido )
	oLbx:bLDblClick := {|| EditaTRB(oLbx:ColPos(),@aPedido), oLbx:DrawSelect() }

	oLbx:GoTop()

	lConfirma := .F.
	lValido   := .T.

	//@ C(132), C(065) Button "Atualizar" Size 28, 10 Action ( lConfirma := .T., lValido := .T., oDlgAdiant:End() )
	oTButton1 := TButton():New( 122, 345, "Atualizar", oDlgAdiant, {|| (lConfirma := .T., lValido := .T., oDlgAdiant:End()) }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	oTMsgBar   := TMsgBar():New(oDlgAdiant, AllTrim(SM0->M0_NOME) + "/" + AllTrim(SM0->M0_FILIAL), .F.,.F.,.F.,.F., ,,oFontMsg,.F.)
	oTMsgItem1 := TMsgItem():New( oTMsgBar,SA2->A2_NOME, 500,, ,,.T., {||} )

ACTIVATE MSDIALOG oDlgAdiant CENTERED

If lConfirma .And. lValido
	If ApMsgYesNo("Deseja realmente atualizar a(s) data(s) de entrega(s)?", "Atenção")
		For nLinha := 1 To Len( aPedido )
			dbSelectArea("SC7")
			dbSetOrder(1)
			If SC7->( dbSeek( xFilial("SC7") + aPedido[nLinha][11] + aPedido[nLinha][01] ) )
				If SC7->C7_DATPRF <> aPedido[nLinha][04]
					RecLock("SC7", .F.)
						SC7->C7_DATPRF := aPedido[nLinha][04]
					MsUnLock()
				EndIf
			EndIf
		Next
	EndIf
EndIf

SB1->( RestArea( aAreaSB1 ) )
SA2->( RestArea( aAreaSA2 ) )
SC7->( RestArea( aAreaSC7 ) )
RestArea( aArea )

Return

Static Function EditaTRB( N, aDados)

Local pCol := 4 // Somente a coluna de data de entrega...

lEditCell(@aDados,oLbx,"",pCol)

Return