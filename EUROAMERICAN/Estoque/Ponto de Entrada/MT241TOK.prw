#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

/*/{Protheus.doc} MT241TOK
POnto de entrada para bloquear o uso, somente quem estiver no parametro poderá utilizar a rotina.
@author Fabio Carneiro dos Santos
@since 27/06/2021
@version 1.0
@type User Function
@HIstory O local 07 e Q7, é usado pela rotina QEEST007, que tem o objetivo de gerar o estoque 07 p/ Q7.
/*/

User Function MT241TOK()

Local aArea         := GetArea()
Local aAreaSF5      := SF5->( GetArea() )
Local aAreaCTT      := CTT->( GetArea() )
Local lRet          := .T.
Local nPosLoc	    := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D3_LOCAL" })
Local cPermite      := Alltrim(SuperGetMV("QE_MT240IC",.T.,"")) 

For nLin := 1 To Len( aCols )
	If !aCols[nLin,Len(aHeader)+1]	// Indica se linha esta deletada
		If AllTrim( aCols[nLin][nPosLoc] ) $ "07/Q7"
			lRet := .T.
		Else
			If !AllTrim( cUsername ) $ cPermite
				Aviso("MT241TOK / Permissão de Uso!","Usuário sem permissão para usar Esta rotina, Favor entrar em contato com TI !",{"Ok"})
				lRet := .F.
			Else 
				lRet := .T.
			Endif
		EndIf
	EndIf
Next

CTT->( RestArea( aAreaCTT ) )
SF5->( RestArea( aAreaSF5 ) )
RestArea( aArea )

Return lRet
