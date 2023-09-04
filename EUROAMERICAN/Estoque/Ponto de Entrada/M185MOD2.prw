#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ M185MOD2 บ Autor ณ Fabio    	         บ Data ณ 19/08/2019  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Ponto de entrada para valida็ใo de baixa SA Mod 2          บฑฑ
ฑฑบ          ณ                                 							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Euroamerican                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function M185MOD2()

Local aArea    := GetArea()
Local lValido  := .T.

Private aItens := aClone( ParamIXB )

If AllTrim( Upper( GetEnvServer() ) ) <> "FABIO"
	Return lValido
EndIf

lValido := BeAutori()

RestArea(aArea)

Return lValido

Static Function BeAutori()

Local lRet   := .T.
Local nLin   := 0
Local cTipos := GetMV( "MV_BE_BSTP",, "'PA','MP','PI','ME','EM','RV','GG','MO','BN','SP','PP','SV'")

// Verifica se Permite Validar Baixa de SA - Tipos de Produtos...
For nLin := 1 To Len( aItens )
	If aItens[nLin][1]
		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->( dbSeek( xFilial("SB1") + aItens[nLin][4] ) )
			If !(AllTrim( SB1->B1_TIPO ) $ cTipos)
				Aviso("M185MOD2 / Tipo de Produto!","Tipo Produto: " + SB1->B1_TIPO + " Nใo Permitido Efetuar Baixa SA Mod. 2!",{"Cancela"})
				lRet := .F.
				Exit
			EndIf
		EndIf
	EndIf
Next

Return lRet