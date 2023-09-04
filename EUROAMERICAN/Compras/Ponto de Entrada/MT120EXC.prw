#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TopConn.ch"

// FS - Exclusão Pedido de Compras

User Function MT120EXC()

Local aArea		:= GetArea()
Local aUser 	:= {}

Private cNumPC  := SC7->C7_NUM

/*
If !Empty( SC7->C7_EUWFID )
	U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " excluído",;
 				 "100901",;
				 "PEDIDO DE COMPRAS EXCLUIDO",;
		         "1",;
				 "Pedido de Compras Excluído" )
EndIf
*/

RestArea( aArea )

Return