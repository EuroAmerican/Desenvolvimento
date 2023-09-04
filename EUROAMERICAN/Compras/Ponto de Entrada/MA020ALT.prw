#Include 'Protheus.ch'
#include "rwmake.ch"

User Function MA020ALT()

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



