// #########################################################################################
// Projeto:	Retornar valor baseado em regras para utilização nos Lançamentos Padrões
// Modulo : SIGACTB
// Fonte  : CTBE003
// ---------+------------------------+------------------------------------------------------
// Data     | Autor                  | Descricao
// ---------+------------------------+------------------------------------------------------
// 04/09/17 | Emerson Paiva          | Criação rotina
// ${date}  | TOTVS Developer Studio | Gerado pelo Assistente de Código
// ---------+-------------------+-----------------------------------------------------------

#include "rwmake.ch"

//------------------------------------------------------------------------------------------
user function CTBE003(cCodLP, cTpData)

Local xRet	:=	Iif (cTpData == "N", 0,Iif( cTpData == "S", "",""))

If cCodLP $ "501#530"	//501 Recebimento Antecipado e 530 Baixas a Pagar: Retornar conta Crédito por empresa x banco x conta
	
	If Left(cFilAnt,2) == "01"
		If ( SE2->E2_BCOPAG == "001" .Or. SE5->E5_BANCO == "001" ) .And. AllTrim(SE5->E5_CONTA) == "22000"
			xRet	:= "111107001"
		EndIf
	ElseIf Left(cFilAnt,2) == "02"
		If ( SE2->E2_BCOPAG == "001" .Or. SE5->E5_BANCO == "001" ) .And. AllTrim(SE5->E5_CONTA) == "5.303-1"
			xRet	:= "111102001"
		ElseIf ( SE2->E2_BCOPAG == "021" .Or. SE5->E5_BANCO == "021" ) .And. AllTrim(SE5->E5_CONTA) == "1888855"
			xRet	:= "111102007"
		ElseIf ( SE2->E2_BCOPAG == "033" .Or. SE5->E5_BANCO == "033" )
			If AllTrim(SE5->E5_CONTA) == "13001842-4"
		 		xRet	:= "111102004"
		 	ElseIf AllTrim(SE5->E5_CONTA) == "13002698"
		 		xRet	:= "111102010"
			EndIf
		ElseIf ( SE2->E2_BCOPAG == "237" .Or. SE5->E5_BANCO == "237" )
			If AllTrim(SE5->E5_CONTA) == "52.250-3"
		 		xRet	:= "111102005"
		 	ElseIf AllTrim(SE5->E5_CONTA) == "5255"
		 		xRet	:= "111102008"
			EndIf
		ElseIf ( SE2->E2_BCOPAG == "246" .Or. SE5->E5_BANCO == "246" ) .And. AllTrim(SE5->E5_CONTA) == "0066086940"
		 	xRet	:= "111102009"	
		ElseIf ( SE2->E2_BCOPAG == "341" .Or. SE5->E5_BANCO == "341" )
		 	If AllTrim(SE5->E5_CONTA) == "25.005-7"
		 		xRet	:= "111102002"
		 	ElseIf AllTrim(SE5->E5_CONTA) == "01.297-8"
		 		xRet	:= "111305001" 	
		 	ElseIf AllTrim(SE5->E5_CONTA) == "1299"
		 		xRet	:= "211201002" 
		 	ElseIf AllTrim(SE5->E5_CONTA) == "01.295-2"
		 		xRet	:= "211201003" 
		 	ElseIf AllTrim(SE5->E5_CONTA) == "74999-1"
		 		xRet	:= "111102011" 
			EndIf
		ElseIf ( SE2->E2_BCOPAG == "633" .Or. SE5->E5_BANCO == "633" ) .And. AllTrim(SE5->E5_CONTA) == "205230000"
		 	xRet	:= "111102006"
		ElseIf ( SE2->E2_BCOPAG == "637" .Or. SE5->E5_BANCO == "637" ) .And. AllTrim(SE5->E5_CONTA) == "14838"
			xRet	:= "111102003"
		EndIf
	ElseIf Left(cFilAnt,2) == "03"
		If ( SE2->E2_BCOPAG == "001"  .Or. SE5->E5_BANCO == "001" ) .And. AllTrim(SE5->E5_CONTA) == "2300-6"
			xRet	:= "111103003"
		ElseIf ( SE2->E2_BCOPAG == "033" .Or. SE5->E5_BANCO == "033" ) .And. AllTrim(SE5->E5_CONTA) == "13002572-9"
			xRet	:= "111103004"
		ElseIf ( SE2->E2_BCOPAG == "237" .Or. SE5->E5_BANCO == "237" ) .And. AllTrim(SE5->E5_CONTA) == "66499-5"
			xRet	:= "111103002"
		ElseIf ( SE2->E2_BCOPAG == "341" .Or. SE5->E5_BANCO == "341" ) .And. AllTrim(SE5->E5_CONTA) == "38.415-3"
			xRet	:= "111103001"
		ElseIf ( SE2->E2_BCOPAG == "637" .Or. SE5->E5_BANCO == "637" ) .And. AllTrim(SE5->E5_CONTA) == "14835"
			xRet	:= "111103005"
		EndIf
	ElseIf Left(cFilAnt,2) == "08"
		If	( SE2->E2_BCOPAG == "021" .Or. SE5->E5_BANCO == "021" ) .And. AllTrim(SE5->E5_CONTA) == "2781780"
			xRet	:=	"111108004"
		ElseIf ( SE2->E2_BCOPAG == "033" .Or. SE5->E5_BANCO == "033" ) .And. AllTrim(SE5->E5_CONTA) == "13002998"
			xRet	:= "111108003"
		ElseIf ( SE2->E2_BCOPAG == "237" .Or. SE5->E5_BANCO == "237" ) .And. AllTrim(SE5->E5_CONTA) == "66500-2"
			xRet	:= "111108001"
		ElseIf ( SE2->E2_BCOPAG == "341" .Or. SE5->E5_BANCO == "341" ) .And. AllTrim(SE5->E5_CONTA) == "66739-1"
			xRet	:= "111108002"
		EndIf
	Else
		xRet	:= "INFORMAR"
	EndIf

Else
	MsgStop("Lançamento padrão não configurado, favor verificar!")	
EndIf	
	
return (xRet)
//--< fim de arquivo >----------------------------------------------------------------------