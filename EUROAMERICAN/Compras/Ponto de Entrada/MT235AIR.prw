#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

// FS - PE Eliminação de Resíduos

User Function MT235AIR()

Local lRetorno := .T.
Local cTabela  := ParamIxb[1]
Local aArea    := GetArea()

If AllTrim( cTabela ) == "SC7"
	If !Empty( SC7->C7_EUWFID )
		U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( SC7->C7_NUM ) + " Resíduos Eliminados",;
		             "500290",;
			         "ELIMINACAO DE RESIDUOS",;
			         "1",;
			         "Pedido de Compras com Resíduos Eliminados" )
	EndIf
EndIf

RestArea( aArea )

Return lRetorno