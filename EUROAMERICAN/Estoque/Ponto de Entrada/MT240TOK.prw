#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

/*/{Protheus.doc} MT240TOK
POnto de entrada para bloquear o uso, somente quem estiver no parametro poderá utilizar a rotina.
@author Fabio Carneiro dos Santos
@since 27/06/2021
@version 1.0
@type User Function
@HIstory O local 07 e Q7, é usado pela rotina QEEST007, que tem o objetivo de gerar o estoque 07 p/ Q7.
/*/

User Function MT240TOK()

Local aArea         := GetArea()
Local aAreaSF5      := SF5->( GetArea() )
Local aAreaCTT      := CTT->( GetArea() )
Local lRet          := .T.
Local cPermite      := Alltrim(SuperGetMV("QE_MT240IC",.T.,"")) 
Local cLocal        := M->D3_LOCAL 

If cLocal $ "07/Q7"
	lRet := .T.
Else
	If !AllTrim( cUsername ) $ cPermite
		Aviso("MT240TOK / Permissão de Uso!","Usuário sem permissão para usar Esta rotina, Favor entrar em contato com TI !",{"Ok"})
		lRet := .F.
		Return lRet
	Else
		lRet := .T.
	Endif
Endif

CTT->( RestArea( aAreaCTT ) )
SF5->( RestArea( aAreaSF5 ) )
RestArea( aArea )

Return lRet
