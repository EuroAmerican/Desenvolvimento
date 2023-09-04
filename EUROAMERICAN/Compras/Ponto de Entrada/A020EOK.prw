#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MA030TOK  ºAutor³ Evandro Peixoto          ºData 11/10/2019º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada na inclusão do Forncedor com o objetivo     º±±
±±º          ³ de gerar o item contabil                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function A020EOK()

//Local cEmail := ""
Local lRet   := .T.
local nResto := 0
Local nTam   := 0
Local nI     := 1

/*If M->A1_EST # "EX"
	If empty(M->A1_CGC)
		If m->a1_tipo # "L" .AND. m->a1_tipo # "X"
			Alert("O preenchimento de campo CGC/CNPJ deve ser obrigatorio para clientes diferentes de Exportacao e Produtor Rural")
			Return(.f.)
		Endif
	Endif
Endif*/

If M->A1_EST = "EX" 
	If ! EMPTY(M->A2_CGC)
			Alert("Fornecedor estrangeiro não deve ter CNPJ cadastrado.")
		Return(.f.)
	Endif
Endif

If m->a2_est # "EX"
	If m->a2_tipo == "X"
		Alert("Para clientes com tipo igual a Exportação o Estado deve ser igual a EX, verifique!")
		Return(.f.)
	Endif
Endif

If  M->A2_EST <> "EX" .AND. EMPTY(M->A2_CGC)  
			ALERT("Por favor, cadastrar o CNPJ do cliente.")
			Return(.f.)
EndIf

If M->A2_EST # "EX"
	If empty(M->A2_COD_MUN)
		Alert("Por favor, preencher o Código do município")
		Return(.f.)
	Endif
Endif

If M->A2_EST # "EX"
	If empty(M->A2_INSCR)
		Alert("Por favor, preencher Inscrição estadual")
		Return(.f.)
	Endif
Endif

	If empty(M->A2_PAIS)
		Alert("Por favor, preencher o código do pais")
		Return(.f.)
	Endif

RETURN(.T.)

/*
//Fabio 10/11/2017 - Validar E-Mail...
cEmail := AllTrim( M->A1_EMAIL )

If !Empty(cEmail)
	cEmail := Lower( cEmail )
	nTam   := Len( Alltrim( cEmail ) )

	If Len( Alltrim( cEmail ) ) <= 5
        Alert( "O e-mail deve ter no mínimo 5 caracteres." , "E-mail inválido ..." )
		Return( .F. )
	Else
		Do While nI <= nTam .And. lRet
			If Alltrim( Substr( Alltrim( cEmail ), nI, 1) ) $ "{}()<>[]|\/&*$%?!^~`,:=#"
				lRet := .F.
			Endif
			nI++
		Enddo
		If !lRet
	        Alert( "O e-mail contém caracteres não permitidos. ( Caracteres especiais)!!" , "E-mail inválido ..." )
			Return( .F. )
		Else
			If ( nResto := At( "@", cEmail )) > 1 .and. At( "@", Right( cEmail, Len( cEmail ) - nResto )) == 0 .and. !Len(Alltrim(cEmail)) == nResto
				If ( nResto := At( ".", Right( cEmail, Len( cEmail ) - nResto ))) > 0
					Do Case
						Case (nResto := At(".", cEmail )) == 1
					        Alert( "O e-mail não pode começar com ponto '.' !!" , "E-mail inválido ..." )
							Return( .F. )
						Case len(Alltrim(cEmail)) == nResto
					        Alert( "O e-mail não pode terminar com ponto '.' !!" , "E-mail inválido ..." )
							Return( .F. )
						Case Substr(cEmail,(nResto-1),1) == "@"
					        Alert( "O e-mail contém um ponto(.) em seguida do '@'!" , "E-mail inválido ..." )
							Return( .F. )
					EndCase
				Else
			        Alert( "O e-mail não contém pontos após o '@' !" , "E-mail inválido ..." )
					Return( .F. )
				Endif
			Else
				Do Case
					Case nResto == 0
				        Alert( "Não foi encontrado nenhum '@' no e-mail!" , "E-mail inválido ..." )
						Return( .F. )
					Case nResto == 1
				        Alert( "O e-mail não pode começar com '@'!." , "E-mail inválido ..." )
						Return( .F. )
					Case Len(Alltrim(cEmail)) == nResto
				        Alert( "O e-mail não pode terminar com '@'!." , "E-mail inválido ..." )
						Return( .F. )
				EndCase
		        /*
		        Alert( "Existe mais de um '@' no e-mail!" , "E-mail inválido ..." )
				Return( .F. )
				
			Endif
		Endif
	Endif
EndIf

RETURN()*/
/*
_cArea:=GetArea()

_cItem:="C"+M->A1_COD+M->A1_LOJA

DbSelectArea("CTD")
DbSetOrder(1)
dbseek(xFilial("CTD")+_cItem)
If !Found()
	Reclock("CTD",.T.)
	CTD->CTD_FILIAL :=XFILIAL("CTD")
	CTD->CTD_ITEM   :=_cItem
	CTD->CTD_CLASSE :="2"
	CTD->CTD_DESC01 :=M->A1_NOME
	CTD->CTD_BLOQ   :="2"
	CTD->CTD_DTEXIS :=CTOD("01/01/07")
	CTD->CTD_CLOBRG :="2"
	CTD->CTD_ACCLVL :="1"
	CTD->CTD_ITLP   :=_cItem
	CTD->CTD_ITSUP  :="C"
	MsUnlock()
	//Else
	//        MsgAlert("Já existe um item contábil com o codigo: "+_cItem+". O Item contábil referente a este cliente não poderá ser criado.","ATENCAO")
EndIf

RestArea(_cArea)

Return(.T.)*/