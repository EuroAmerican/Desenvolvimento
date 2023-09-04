#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#include 'parmtype.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MT250TOK บ Autor ณ Fabio    	         บ Data ณ 23/12/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Ponto de entrada para valida็ใo de apontamento produ็ใo    บฑฑ
ฑฑบ          ณ                                 							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Grupo Sabarแ                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function MT250TOK()

Local aArea    := GetArea()
Local lValido  := .T.
Local lRet     := .T.
Local lDif     := SuperGetMV("ES_A250DIF", .T., .F.)

If AllTrim( Upper( GetEnvServer() ) ) <> "FABIO"
	Return lRet
EndIf

// Valida็ใo anterior a modifica็ใo Fabio...
If ParamIxb  //Validacao padrao ok
	If M->D3_PARCTOT == "P" .and. M->D3_PERDA == 0  //verifica perda
		lRet := MsgYesNo("Aten็ใo, nใo foi informado um valor de perda, deseja continuar ???", "Perda")
	EndIf

	If lRet .and. lDif  //Mostra divergencia no empenho
		U_mpcp002(M->D3_OP)
		lRet := MsgYesNo("Producao", "Confirma o apontamento da ordem de producao ???")
	EndIf
	
	If !lRet
		RestArea(aArea)
		Return lRet
	EndIf
EndIf

If lValido
	lValido := BeAutori()
EndIf

RestArea(aArea)

Return lValido

Static Function BeAutori()

Local lRet   := .T.
Local nLin   := 0

dbSelectArea("SB1")
dbSetOrder(1)
If SB1->( dbSeek( xFilial("SB1") + M->D3_COD ) )
	If !(AllTrim( SB1->B1_TIPO ) $ "PA/PI/KT/PP/BN")
		Aviso("MT250TOK / Tipo de Produto!","Tipo Produto: " + SB1->B1_TIPO + " Nใo Permitido Efetuar Apontamento de Produ็ใo, somente PA, PI, KT, PP e BN sใo vแlidos para apontamentos!",{"Cancela"})
		lRet := .F.
	EndIf
EndIf

If lRet
	If Left(cFilAnt,2) == "08"
		Aviso("MT250TOK / Empresa!","Nใo permitido apontamento de OP de Estoque na Qualycril, utilizar apontamento PCP com roteiros de opera็๕es!",{"Cancela"})
		lRet := .F.
	EndIf
EndIf

Return lRet