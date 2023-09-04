#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

/*/{Protheus.doc} chamlogs
//TODO validacão do campo familia e subfamilia
@author Fabio Batista/Fabio Souza 
@since 02/10/2020
@version 1.0
@return ${return}, ${return_description} .T. 
@param 
@type function
/*/

User Function A010TOK()

Local lRet    := .T.// Validações do usuário para exclusão do produto
//Local lInc    := Inclui
//Local lAlt    := Altera
Local cCampo  := ""

If AllTrim( M->B1_TIPO ) == "PA"

	If Empty( M->B1_XFAMILI )
		cCampo += ", FAMILIA"
	EndIf


	If Empty( M->B1_XSUBFAM )
		cCampo += ", SUB-FAMILIA"
	EndIf

	If lRet .And. Empty( M->B1_XCOR )
		cCampo += ", COR"
	EndIf

	If lRet .And. Empty( M->B1_XLINHA )
		cCampo += ", LINHA"
	EndIf

	cCampo := Alltrim(Subs(cCampo, 2))

	/*
	If Empty( M->B1_XFAMILI )
		ApMsgAlert( "Informar código da família do Produto. Obrigatório para tipo de produto PA!", "A010TOK - Atenção" )
		lRet := .F.
	EndIf

	If lRet .And. Empty( M->B1_XSUBFAM )
		ApMsgAlert( "Informar código da sub-família do Produto. Obrigatório para tipo de produto PA!", "A010TOK - Atenção" )
		lRet := .F.
	EndIf
	*/

	IF !Empty(cCampo)
		IF At(",", cCampo) > 0
		   ApMsgInfo("Os campos "+cCampo+" do produto nao foram preenchidos!", "A010TOK - ATENCAO")
		else
		   ApMsgInfo("O campo "+cCampo+" do produto nao foi preenchido!", "A010TOK - ATENCAO")
		Endif
	Endif
EndIf

Return lRet
