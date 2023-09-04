#Include 'TOTVS.CH'

/*/{Protheus.doc} MA650TOK
Ponto de entrada para validação de inclusão de OP
@type function Ponto de Entrada
@version 1.00
@author Fabio - alterado por mario.antonaccio
@since 19/08/2019- alterado em 14/09/2021
@return Logical, Permite ou nao a inclusao da OP
/*/
User Function MA650TOK()

	Local aArea     := GetArea()
	Local lValido   := .T.

	If AllTrim( Upper( GetEnvServer() ) ) == "FABIO"
		lValido := BeAutori()
	End

		// Validar produto especial - PROJETO : Tratativa de produtos especiais para controlar producao x pedido de vendas
		If lValido
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+M->C2_PRODUTO))
			If SB1->B1_GRUPO  $ GETMV("QE_GRPPRES")	.and. SB1->B1_TIPO == "PA"
				If Empty(M->C2_XPEDIDO) 
					ALERT("Por se tratar de produto especial, necessario informar o PEDIDO DE VENDA correspondente ")
					lValido:=.F.
				Else
					SC5->(dBSetOrder(1))
					If ! SC5->(dbSeek(xFilial("SC5")+M->C2_XPEDIDO))		
						ALERT("Pedido nao Encontrado. Verificar! ")
						lValido:=.F.	
					End
				End
			End
		End	

	RestArea( aArea )

Return lValido

/*/{Protheus.doc} BeAutori
Validação de produtos
@type function |Ponto de entrada
@version  1.0
@author mario.antonaccio
@since 14/09/2021
@return Logical, continua ou nao o processo
/*/
Static Function BeAutori()

	Local lRet      := .T.

	dbSelectArea("SB1")
	dbSetOrder(1)
	If SB1->( dbSeek( xFilial("SB1") + M->C2_PRODUTO ) )
		If !(AllTrim( SB1->B1_TIPO ) $ "PA/PI/KT/PP")
			Aviso("MA650TOK / Tipo Produto!","Tipo Produto: " + SB1->B1_TIPO + " Não Permitido para inclusão de OP, somente válido para PA, PI, PP ou KT!",{"Cancela"})
			lRet := .F.
			Return lRet
		EndIf
	EndIf

	If AllTrim( SB1->B1_TIPO ) <> "PP"
		dbSelectArea("SG1")
		dbSetOrder(1)
		If !SG1->( dbSeek( xFilial("SG1") + M->C2_PRODUTO ) )
			Aviso("MA650TOK / Estrutura de Produto!","Não permitido inclusão de OP para produto sem estrutura!",{"Cancela"})
			lRet := .F.
			Return lRet
		EndIf
	EndIf

Return lRet
