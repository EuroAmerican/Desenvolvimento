#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MT380INC บ Autor ณ Fabio    	         บ Data ณ 23/12/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Ponto de entrada para valida็ใo de ajuste de empenho Mod 1 บฑฑ
ฑฑบ          ณ                                 							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Grupo Sabarแ                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function MT380INC()

Local aArea    := GetArea()
Local lValido  := .T.

If AllTrim( Upper( GetEnvServer() ) ) <> "FABIO"
	Return lValido
EndIf

lValido := BeAutori()

RestArea(aArea)

Return lValido

Static Function BeAutori()

Local lRet   := .T.
Local nLin   := 0
Local cTipos := GetMV( "MV_BE_AJTP",, "'PA','MP','PI','ME','EM','RV','BN','SP','PP','KT'")

// Verifica se Permite Validar Baixa de SA - Tipos de Produtos...
dbSelectArea("SB1")
dbSetOrder(1)
If SB1->( dbSeek( xFilial("SB1") + M->D4_COD ) )
	If !(AllTrim( SB1->B1_TIPO ) $ cTipos)
		Aviso("MT380INC / Tipo de Produto!","Tipo Produto: " + SB1->B1_TIPO + " Nใo Permitido Efetuar Ajuste de Empenho Mod. 1!",{"Cancela"})
		lRet := .F.
	EndIf
EndIf

Return lRet