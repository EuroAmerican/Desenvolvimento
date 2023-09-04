#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#include "colors.ch"

#define ENTER chr(13) + chr(10)
#define PAD_LEFT            0
#define PAD_RIGHT           1
#define PAD_CENTER          2

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCPR019   บ Autor ณTiago O Beraldi     บ Data ณ 27/05/13    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณORDEM DE PRODUCAO - EUROAMERICAN                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCP                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function PCPR019

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aArea   := GetArea()
Local lOk	  := .F.

Private cPerg   := "PCPR019"
Private cTitulo := "Ordem de Produ็ใo"
Private nPag    := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Dicionario de Perguntas                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
fCriaSX1(cPerg)
Pergunte(cPerg, .F.)

oPrint := PcoPrtIni(cTitulo, .F., 2,, @lOk, cPerg)

If lOk
	oProcess := MsNewProcess():New({|lEnd| PCPR019Imp(@lEnd, oPrint, oProcess)},"","",.F.)
	oProcess :Activate()
	PcoPrtEnd(oPrint)
EndIf

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCPR019IMPบ Autor ณTiago O Beraldi     บ Data ณ 27/05/13    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFUNCAO DE IMPRESSAO                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCP                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function PCPR019Imp(lEnd,oPrint,oProcess) //PCPR019Imp(@lEnd, oPrint, oProcess)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis                                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cQry

Private nLin    := 25
Private nLinV   := 25

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fontes utilizadas                                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private oFont0  := TFont():New( "Courier New",, 10,, .F.,,,,, .F.)
Private oFont1  := TFont():New( "Courier New",, 10,, .T.,,,,, .F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento                                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQry := " SELECT	C2_NUM + '.' + C2_ITEM + '.' + C2_SEQUEN NUMERO, RTRIM(C2_PRODUTO) + ' - ' + B1_DESC PRODUTO, B1_UM UND, C2_EMISSAO EMISSAO, C2_QUANT QUANT, ISNULL(SUM((100 * Z0_TEMPAD) + (60 * CONVERT(INT, Z0_TEMPAD))), 0) TEMPO, C2_RECURSO EQUIP, C2_REVISAO + '-' + ISNULL((SELECT CONVERT(VARCHAR, CONVERT(DATETIME, G5_DATAREV), 103) FROM "+RetSqlName("SG5")+" WHERE D_E_L_E_T_ = '' AND G5_PRODUTO = C2_PRODUTO AND G5_REVISAO = C2_REVISAO),'') REVISAO, C2_PRODUTO CODPROD " + ENTER
cQry += " FROM		" + RetSqlName("SB1") + " SB1, " + RetSqlName("SC2") + " SC2 " + ENTER
cQry += " LEFT JOIN " + RetSqlName("SZ0") + " SZ0 " + ENTER
cQry += " ON (SZ0.D_E_L_E_T_ = '' AND Z0_PRODUTO = C2_PRODUTO ) " + ENTER
cQry += " WHERE	SC2.D_E_L_E_T_ = '' " + ENTER
cQry += " 		AND SB1.D_E_L_E_T_ = '' " + ENTER
cQry += " 		AND C2_PRODUTO = B1_COD " + ENTER
//cQry += " 		AND C2_DATRF = '' " + ENTER
cQry += " 		AND C2_EMISSAO BETWEEN '" + DtoS(mv_par01) + "' AND '" + DtoS(mv_par02) + "' " + ENTER
cQry += " 		AND C2_NUM BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' " + ENTER
cQry += " 		AND C2_ITEM BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' " + ENTER
cQry += " 		AND C2_PRODUTO BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' " + ENTER
cQry += " 		AND C2_GRUPO BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "' " + ENTER
cQry += " 		AND C2_FILIAL = '" + xFilial("SC2") + "' " + ENTER
cQry += " GROUP BY C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO, B1_DESC, B1_UM, C2_EMISSAO, C2_QUANT, C2_RECURSO, C2_REVISAO " + ENTER
cQry += " ORDER BY NUMERO "

MemoWrite("pcpr019a.sql", cQry)

If Select("QRYA") > 0
     QRYA->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS QRYA

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Incio da Impressao                                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPrint:SetPaperSize(9)   //Papel A4
oPrint:SetLandScape()    //Paisagem

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Itens                                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
QRYA->(dbGoTop())

oProcess:SetRegua1(100)
oProcess:SetRegua2(QRYA->(RecCount()))

If !QRYA->(EOF())
	cQuebOP := StrTran(QRYA->NUMERO, ".", "")
EndIf

While !QRYA->(EOF())

	nLin    := 25
	nLinV   := 25

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Contador de Impressao                                               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SC2")
	dbSetOrder(1)
	dbSeek(xFilial("SC2") + StrTran(QRYA->NUMERO, ".", ""))
	//Reclock("SC2",.F.)
		/*
		If SC2->C2_QIMPOP == 0
			SC2->C2_QIMPOP := 1
		Else
			If !(MsgBox("A O.P. nบ " + SC2->C2_NUM + "." + SC2->C2_ITEM + "." + SC2->C2_SEQUEN + " foi impressa " + AllTrim(Str(SC2->C2_QIMPOP)) + " vezes, deseja imprimir novamente ?",'A T E N C A O', 'YESNO'))
				SC2->( MsUnLock() )
				QRYA->(dbSkip())
				Loop
	  		Else
				SC2->C2_QIMPOP += 1
			Endif
		Endif
		*/
	//SC2->( MsUnLock() )

	If Subs(QRYA->NUMERO, 8, 6) == "01.001"

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Layout Frente                                                       ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nPag++
		oPrint:StartPage()
		LFrente()

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Imprime Dados da Frente                                             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cQry := " SELECT	D4_TRT SEQUENCIA, " + ENTER
		cQry += " 			C2_PRODUTO PRODUTO, " + ENTER
		cQry += " 			D4_COD COMPONENTE, " + ENTER
		cQry += " 			SUBSTRING(B1_DESC, 1, 15) DESCOMP, " + ENTER
		cQry += " 			D4_QUANT QTDCOMP, " + ENTER
		cQry += " 			B1_UM UM " + ENTER
		cQry += " FROM	" + RetSqlName("SC2") + " SC2, " + RetSqlName("SD4") + " SD4, " + RetSqlName("SB1") + " SB1 " + ENTER
		cQry += " WHERE		SC2.D_E_L_E_T_ = '' " + ENTER
		cQry += " 			AND SD4.D_E_L_E_T_ = '' " + ENTER
		cQry += " 			AND SB1.D_E_L_E_T_ = '' " + ENTER
		cQry += " 			AND	C2_NUM + C2_ITEM + C2_SEQUEN = D4_OP " + ENTER
		cQry += " 			AND	C2_NUM + '.' + C2_ITEM + '.' + C2_SEQUEN = '" + QRYA->NUMERO + "' " + ENTER
		cQry += " 			AND B1_COD = D4_COD " + ENTER
		cQry += " 			AND B1_TIPO != 'MO' " + ENTER
		cQry += " 			AND D4_QUANT != 0 " + ENTER
		cQry += " 		    AND C2_FILIAL = D4_FILIAL " + ENTER
		cQry += " 		    AND C2_FILIAL = '" + xFilial("SC2") + "' " + ENTER
		cQry += " ORDER BY SEQUENCIA "

		MemoWrite("pcpr019b.sql", cQry)

		If Select("QRYB") > 0
			QRYB->(dbCloseArea())
		EndIf

		TCQUERY cQry NEW ALIAS QRYB

		nLin := 0425

		nItens := 0  //Contador para verifica็ใo se n๚mero de itens excedo 30 por pแgina - 18/05/16

		While !QRYB->(EOF())
			//oPrint:Say(nLin, 0020, PadR(QRYB->SEQUENCIA + "-" + QRYB->COMPONENTE, 19) + "|" + PadR(QRYB->DESCOMP, 15) + "|" + Transform(QRYB->QTDCOMP, "@E 9,999.999") + "|" + QRYB->UM  + "|" + PadR("", 10) + "|" + PadR("", 8) + "|", oFont0,,,,PAD_LEFT)
			oPrint:Say(nLin, 0020, PadR(QRYB->SEQUENCIA + "-" + QRYB->COMPONENTE, 19) + "|" /*+ PadR(" ", 15) + "|"*/ + Transform(QRYB->QTDCOMP, "@E 999,999.999") + "|" + QRYB->UM  + "|" + PadR("", 14) + "|" + PadR("", 12) + "|", oFont0,,,,PAD_LEFT)
			oPrint:Box(nLin + 46, 0010, nLin + 48, 1680)
			nLin += 50

			nItens++
			If ( nItens > 30)
				nLin := 795
				oPrint:EndPage()
				oPrint:StartPage()
				oPrint:EndPage()
				oPrint:StartPage()
				nPag += 2
				//oPrint:StartPage()
				oPrint:Box(0010, 0010, 0060, 1680)
				oPrint:Say(0015, 0020, "EUROAMERICAN                ORDEM DE PRODUวรO               N." + QRYA->NUMERO, oFont1,,,,PAD_LEFT)
				oPrint:Box(0060, 0010, 0325, 1680)
				oPrint:Say(0065, 0020, "CONTINUACAO COMPONENTES" , oFont0,,,,PAD_LEFT)

				oPrint:Box(0325, 0010, 0425, 1680)
				oPrint:Say(0335, 0020, "C O M P O N E N T E S                           |A L M O X A R I F A D O  ", oFont1,,,,PAD_LEFT)
				oPrint:Say(0385, 0020, "CODIGO             |DESCRICAO      |QUANTID  |UM|QTD REAL  |LOTE    |ALM  ", oFont1,,,,PAD_LEFT)

				oPrint:Box(0010, 0010, 2360, 1680)

				nLin := 0425
				nItens := 0
			EndIf

			QRYB->(dbSkip())
		EndDo

		oPrint:Say(nLin, 0020, "A D I ว ร O   E X T R A - F ำ R M U L A                                   ", oFont1,,,,PAD_LEFT)
		oPrint:Box(nLin + 46, 0010, nLin + 48, 1680)
		nLin += 55
		oPrint:Say(nLin, 0020, "CODIGO             |DESCRICAO      |QUANTID  |UM|LOTE     |VISTO          ", oFont1,,,,PAD_LEFT)
		For i := 1 to 7
			nLin += 70
			oPrint:Say(nLin, 0020, "___________________|_______________|_________|__|_________|_______________", oFont0,,,,PAD_LEFT)
		Next i

		nLin := 795

		oPrint:EndPage()

		QRYB->(dbCloseArea())
		QRYA->(dbSkip())

	Else

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Layout Verso                                                        ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nPag++
		oPrint:StartPage()

		cLote := Subs(QRYA->NUMERO, 1, 6)
		nCont := 1

		While !QRYA->(EOF()) .And. cLote == Subs(QRYA->NUMERO, 1, 6)

 			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Contador de Impressao                                               ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			dbSelectArea("SC2")
			dbSetOrder(1)
			dbSeek(xFilial("SC2") + StrTran(QRYA->NUMERO, ".", ""))
			//Reclock("SC2",.F.)
				/*
				If SC2->C2_QIMPOP == 0
					SC2->C2_QIMPOP := 1
				Else
					If !(MsgBox("A O.P. nบ " + SC2->C2_NUM + "." + SC2->C2_ITEM + "." + SC2->C2_SEQUEN + " foi impressa " + AllTrim(Str(SC2->C2_QIMPOP)) + " vezes, deseja imprimir novamente ?",'A T E N C A O', 'YESNO'))
						SC2->( MsUnLock() )
						QRYA->(dbSkip())
						Loop
			  		Else
						SC2->C2_QIMPOP += 1
					Endif
				Endif
				*/
			//SC2->( MsUnLock() )

			LVerso(nCont)

			nCont++

			QRYA->(dbSkip())

			/*
			If !QRYA->(EOF()) // fs - nใo tratava quebra de OP, por isso, nใo imprime qualidade corretamente...
				If AllTrim( cQuebOP ) <> AllTrim( StrTran(QRYA->NUMERO, ".", "") )
					cQuebOP := StrTran(QRYA->NUMERO, ".", "")

					//If ( nPag % 2 ) != 0
						//oPrint:StartPage()
						oPrint:EndPage()
					//EndIf

					dbSelectArea("SC2")
					dbSetOrder(1)
					SC2->( xFilial("SC2") + Left( cQuebOP, 6) )
					
					oPrint:StartPage()
					LQualid(SC2->C2_PRODUTO)
					oPrint:EndPage()
					
					If ( nPag % 2 ) != 0
						oPrint:StartPage()
						oPrint:EndPage()
					EndIf
				EndIf
			EndIf
			*/

		EndDo

		oPrint:EndPage()

	EndIf

EndDo

QRYA->(dbGoTop())

If ( nPag % 2 ) != 0
	oPrint:StartPage()
	oPrint:EndPage()
EndIf

dbSelectArea("SC2")
dbSetOrder(1)
dbSeek(xFilial("SC2") + StrTran(QRYA->NUMERO, ".", ""))

oPrint:StartPage()
LQualid(SC2->C2_PRODUTO)
oPrint:EndPage()

If ( nPag % 2 ) != 0
	oPrint:StartPage()
	oPrint:EndPage()
EndIf

QRYA->(dbCloseArea())

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLFRENTE   บ Autor ณTiago O Beraldi     บ Data ณ 07/02/11    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณDESENHA LAYOUT DA FRENTE DA OP                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCP                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function LFrente()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Molduras                                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPrint:Box(0010, 0010, 2360, 1680)
oPrint:Box(0010, 1680, 2360, 3360)

// Lado Esquerdo
oPrint:Box(0010, 0010, 0060, 1680)

oPrint:Say(0015, 0020, "EUROAMERICAN                ORDEM DE PRODUวรO               N." + QRYA->NUMERO, oFont1,,,,PAD_LEFT)

oPrint:Box(0060, 0010, 0325, 1680)

oPrint:Say(0065, 0020, "PRODUTO     .: " + AllTrim(QRYA->PRODUTO), oFont0,,,,PAD_LEFT)
oPrint:Say(0115, 0020, "EMISSรO     .: " + DtoC(StoD(QRYA->EMISSAO)) + " TEMPO PRV: " + StrZero(Int(QRYA->TEMPO / 60), 2) + ":" + StrZero(QRYA->TEMPO % 60, 2) + " EQUIP: " + QRYA->EQUIP, oFont0,,,,PAD_LEFT)
//oPrint:Say(0165, 0020, "REVISAO     .: #EST " + RTrim(QRYA->REVISAO) + " #PRC " + RTrim(QRYA->REV2), oFont0,,,,PAD_LEFT)
oPrint:Say(0165, 0020, "REVISAO     .: #EST " + RTrim(QRYA->REVISAO) + " #PRC " , oFont0,,,,PAD_LEFT)
oPrint:Say(0215, 0020, "QTD PREVISTA.: " + Transform(QRYA->QUANT, "@E 999,999.99") + " " + QRYA->UND, oFont0,,,,PAD_LEFT)
oPrint:Say(0265, 0020, "QTD REALIZADA:________________              RENDIMENTO:________________%", oFont0,,,,PAD_LEFT)

MSBAR("CODE128",1.2,11.0,StrTran(RTrim(QRYA->NUMERO),".",""),oPrint,.F.,,.T.,0.0295,1.0,,,,.F.)

oPrint:Box(0325, 0010, 0425, 1680)
oPrint:Say(0335, 0020, "C O M P O N E N T E S                           |A L M O X A R I F A D O  ", oFont1,,,,PAD_LEFT)
oPrint:Say(0385, 0020, "CODIGO             |QUANTID    |UM| QTD REAL     |LOTE        |ALM        ", oFont1,,,,PAD_LEFT)

// Lado Direito
oPrint:Box(0010, 1680, 0060, 3360)
oPrint:Say(0015, 1700, "EUROAMERICAN          HISTำRICO DE PRODUวรO                 N." + QRYA->NUMERO, oFont1,,,,PAD_LEFT)

oPrint:Say(0065, 1700, "PRODUTO: " + AllTrim(QRYA->PRODUTO) + " - REV.EST." + QRYA->REVISAO, oFont0,,,,PAD_LEFT)
oPrint:Say(0115, 1700, "EMISSรO: " + DtoC(StoD(QRYA->EMISSAO)) + " TEMPO PRV: " + StrZero(Int(QRYA->TEMPO / 60), 2) + ":" + StrZero(QRYA->TEMPO % 60, 2) + " EQUIP: " + QRYA->EQUIP + " - REV.PRC.", oFont0,,,,PAD_LEFT)
//oPrint:Say(0115, 1700, "EMISSรO: " + DtoC(StoD(QRYA->EMISSAO)) + " TEMPO PRV: " + StrZero(Int(QRYA->TEMPO / 60), 2) + ":" + StrZero(QRYA->TEMPO % 60, 2) + " EQUIP: " + QRYA->EQUIP + " - REV.PRC." + QRYA->REV2, oFont0,,,,PAD_LEFT)

//Imprime o roteiro de producao
lin := 145
npula := 0
SG2->(DbSetOrder(1))
If SG2->(DbSeek(xFilial("SG2") + QRYA->CODPROD, .F.))
	cChvSG2 := SG2->(G2_FILIAL + G2_PRODUTO + G2_CODIGO)
	While SG2->(!Eof()) .and. cChvSG2 == SG2->(G2_FILIAL + G2_PRODUTO + G2_CODIGO)
		oPrint:Say(lin, 1700, Rtrim(SG2->G2_DESCRI), oFont1,,,,PAD_LEFT)
		lin += 45
		oPrint:Say(lin, 1700, "DT/HR INI: ____/____/____  ____:____ DT/HR FIN: ____/____/____  ____:____", oFont0,,,,PAD_LEFT)
		lin += 40
		npula++
		SG2->(DbSkip())
	EndDo
Else  //se nao tem imprime o padrao atual

	oPrint:Say(0145, 1700, "PESAGEM", oFont1,,,,PAD_LEFT)
	oPrint:Say(0190, 1700, "DT/HR INI: ____/____/____  ____:____ DT/HR FIN: ____/____/____  ____:____", oFont0,,,,PAD_LEFT)
	oPrint:Say(0220, 1700, "PRODUวรO", oFont1,,,,PAD_LEFT)
	oPrint:Say(0265, 1700, "DT/HR INI: ____/____/____  ____:____ DT/HR FIN: ____/____/____  ____:____", oFont0,,,,PAD_LEFT)
EndIf

oPrint:Box(lin, 1680, lin+75, 3360)
oPrint:Say(lin+10, 1700, "H I S T ำ R I C O                      |HORA   |ROTAวรO |TEMPER  |RUBRICA ", oFont1,,,,PAD_LEFT)

Lin += 20
For i := 1 to (23 - npula)
	oPrint:Say(Lin, 1700, "_______________________________________|_______|________|________|________", oFont0,,,,PAD_LEFT)
	Lin += 70
Next i

oPrint:Box(2098, 1680, 2100, 3360)
oPrint:Say(2145, 1700, "OBSERVAวีES GERAIS:_______________________________________________________", oFont1,,,,PAD_LEFT)
oPrint:Say(2215, 1700, "__________________________________________________________________________", oFont1,,,,PAD_LEFT)

cQry := " SELECT	SUM(CASE WHEN B1_UM <> 'KG' THEN B1_PESO * B2_QATU ELSE B2_QATU END) QUANT " + ENTER
cQry += " FROM	" + RetSqlName("SB2") + " SB2, " + RetSqlName("SB1") + " SB1" + ENTER
cQry += " WHERE	SB1.D_E_L_E_T_ = '' " + ENTER
cQry += " 		AND SB2.D_E_L_E_T_ = '' " + ENTER
cQry += "  		AND B2_COD = B1_COD " + ENTER
cQry += " 		AND B2_LOCAL = '07' " + ENTER
cQry += " 		AND B2_FILIAL = '" + xFilial("SB2") + "' " + ENTER
cQry += "  		AND SUBSTRING(B2_COD, 1, 8) = '" + AllTrim(SC2->C2_PRODUTO) + "' "

If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS QRY

If QRY->QUANT <> 0
	oPrint:Say(2250, 1710, "VERIFICAR SALDO DE REPROCESSO (" + AllTrim(Transform(QRY->QUANT, "@E 999,999,999.99")) + " KG)", oFont1,,,,PAD_LEFT)
EndIf
QRY->(dbCloseArea())

cQry := " SELECT	SUM(CASE WHEN B1_UM <> 'KG' THEN B1_PESO * B2_QATU ELSE B2_QATU END) QUANT " + ENTER
cQry += " FROM	" + RetSqlName("SB2") + " SB2, " + RetSqlName("SB1") + " SB1" + ENTER
cQry += " WHERE		SB1.D_E_L_E_T_ = '' " + ENTER
cQry += " 			AND SB2.D_E_L_E_T_ = '' " + ENTER
cQry += "  			AND B2_COD = B1_COD " + ENTER
cQry += "  			AND B1_TIPO = 'PA' " + ENTER
cQry += "  			AND SUBSTRING(B2_COD, 1, 8) = '" + AllTrim(SC2->C2_PRODUTO) + "' " + ENTER
cQry += " 			AND NOT B2_QATU = 0 " + ENTER
cQry += " 			AND B2_LOCAL <> '07' " + ENTER
cQry += " 			AND (SELECT MAX(D2_EMISSAO) FROM " + RetSqlName("SD2") + " WHERE D_E_L_E_T_ = '' AND D2_COD = B2_COD) < GETDATE() - 365 " + ENTER

If Select("QRY") > 0
     QRY->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS QRY

If QRY->QUANT <> 0
	oPrint:Say(2330, 1710, "VERIFICAR PRODUTOS VENCIDOS EM ESTOQUE (" + AllTrim(Transform(QRY->QUANT, "@E 999,999,999.99")) + " KG)", oFont1,,,,PAD_LEFT)
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLVERSO    บ Autor ณTiago O Beraldi     บ Data ณ 07/02/11    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณDESENHA LAYOUT DO VERSO DA OP                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCP                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function LVerso(nQtOP)

Private oBrush  := TBrush():New(,RGB(245,245,245))
Private nColuna := 0

cQry := " SELECT	D4_TRT SEQUENCIA, " + ENTER
cQry += " 			C2_PRODUTO PRODUTO, " + ENTER
cQry += " 			D4_COD COMPONENTE, " + ENTER
cQry += " 			SUBSTRING(B1_DESC, 1, 15) DESCOMP, " + ENTER
cQry += " 			D4_QUANT QTDCOMP, " + ENTER
cQry += " 			B1_UM UM " + ENTER
cQry += " FROM	" + RetSqlName("SC2") + " SC2, " + RetSqlName("SD4") + " SD4, " + RetSqlName("SB1") + " SB1 " + ENTER
cQry += " WHERE		SC2.D_E_L_E_T_ = '' " + ENTER
cQry += " 			AND SD4.D_E_L_E_T_ = '' " + ENTER
cQry += " 			AND SB1.D_E_L_E_T_ = '' " + ENTER
cQry += " 			AND	C2_NUM + C2_ITEM + C2_SEQUEN = D4_OP " + ENTER
cQry += " 			AND	C2_NUM + '.' + C2_ITEM + '.' + C2_SEQUEN = '" + QRYA->NUMERO + "' " + ENTER
cQry += " 			AND B1_COD = D4_COD " + ENTER
cQry += " 			AND D4_QUANT != 0 " + ENTER
cQry += " 		    AND C2_FILIAL = D4_FILIAL " + ENTER
cQry += " 		    AND C2_FILIAL = '" + xFilial("SC2") + "' " + ENTER
cQry += " ORDER BY SEQUENCIA "

MemoWrite("pcpr019e.sql", cQry)

If Select("QRYE") > 0
     QRYE->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS QRYE

dbSelectArea("QRYE")
QRYE->(dbGoTop())
Count To nRecE
QRYE->(dbGoTop())

cQry := " SELECT	Z0_SEQINI SEQUENCIA, ISNULL(UPPER(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),Z0_DESCRIC))), '') INSTRUCAO " + ENTER
cQry += " FROM		" + RetSqlName("SZ0") + ENTER
cQry += " WHERE	D_E_L_E_T_ = '' " + ENTER
cQry += "		AND Z0_PRODUTO = '" + QRYE->PRODUTO + "' "
cQry += " 		    AND Z0_FILIAL = '" + xFilial("SZ0") + "' " + ENTER

MemoWrite("pcpr019f.sql", cQry)

If Select("QRYF") > 0
     QRYF->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS QRYF

dbSelectArea("QRYF")
QRYF->(dbGoTop())
Count To nRecF
QRYF->(dbGoTop())

// Controla impressao lado direito
If nQtOP > 3
	If nQtOP == 4
		nLinV := 10
	EndIf
	nColuna := 1680
EndIf

// Sombra
If (nQtOP % 2) == 0
	oPrint:FillRect({nLinV, 0010 + nColuna, nLinV + 550 + 50 * (nRecE + nRecF), 1680 + nColuna}, oBrush)
EndIf

nLinV += 5
oPrint:Box(nLinV, 0010 + nColuna, nLinV + 0050, 1680 + nColuna)
oPrint:Say(nLinV, 0020 + nColuna, "EUROAMERICAN                ORDEM DE PRODUวรO               N." + QRYA->NUMERO, oFont1,,,,PAD_LEFT)
nLinV += 55
oPrint:Say(nLinV, 0020 + nColuna, "PRODUTO......: " + AllTrim(QRYA->PRODUTO), oFont0,,,,PAD_LEFT)

Do Case
	Case nQtOP == 1
		MSBAR("CODE128", 1.2,( 11 * (IIf(nQtOP<=3, 1, 2 ))),StrTran(RTrim(QRYA->NUMERO),".",""),oPrint,.F.,,.T.,0.0295,1.0,,,,.F.)

	Case nQtOP == 2
		MSBAR("CODE128", 7.1,( 11 * (IIf(nQtOP<=3, 1, 2 ))),StrTran(RTrim(QRYA->NUMERO),".",""),oPrint,.F.,,.T.,0.0295,1.0,,,,.F.)

	Case nQtOP == 3
		MSBAR("CODE128", 12.9,( 11 * (IIf(nQtOP<=3, 1, 2 ))),StrTran(RTrim(QRYA->NUMERO),".",""),oPrint,.F.,,.T.,0.0295,1.0,,,,.F.)
EndCase

nLinV += 45
oPrint:Say(nLinV, 0020 + nColuna, "EMISSรO......: " + DtoC(StoD(QRYA->EMISSAO)) + SPACE(4) + "TEMPO PREVISTO.: " + StrZero(Int(QRYA->TEMPO / 60), 2) + ":" + StrZero(QRYA->TEMPO % 60, 2), oFont0,,,,PAD_LEFT)
nLinV += 45
oPrint:Say(nLinV, 0020 + nColuna, "EQUIPAMENTO..: " + RTrim(QRYA->EQUIP), oFont0,,,,PAD_LEFT)
nLinV += 45
oPrint:Say(nLinV, 0020 + nColuna, "REVISAO......: " + RTrim(QRYA->REVISAO), oFont0,,,,PAD_LEFT)
nLinV += 50
oPrint:Say(nLinV, 0020 + nColuna, "DT/HR INICIO.: ____/____/____  ____:____       DT/HR FIM: ____/____/____  ____:____", oFont0,,,,PAD_LEFT)
nLinV += 75
oPrint:Say(nLinV, 0020 + nColuna, "QTD PREVISTA.: " + Transform(QRYA->QUANT, "@E 999,999.99") + " " + QRYA->UND, oFont0,,,,PAD_LEFT)
oPrint:Say(nLinV, 0750 + nColuna, "QTD REAL:____________    REND:____________% ", oFont0,,,,PAD_LEFT)
nLinV += 60
oPrint:Box(nLinV, 0010 + nColuna, nLinV + 0100, 1680 + nColuna)
nLinV += 10
oPrint:Say(nLinV, 0020 + nColuna, "C O M P O N E N T E S                          |A L M O X A R I F A D O   ", oFont1,,,,PAD_LEFT)
nLinV += 50
oPrint:Say(nLinV, 0020 + nColuna, "CODIGO             |DESCRICAO      |QUANTID  |UM|QTD REAL  |LOTE    |ALM  ", oFont1,,,,PAD_LEFT)
nLinV += 50

While !QRYE->(EOF())
	If QRYE->SEQUENCIA >= QRYF->SEQUENCIA .And. !QRYF->(EOF())
		oPrint:Say(nLinV, 0020 + nColuna, QRYF->INSTRUCAO, oFont1,,,,PAD_LEFT)
		oPrint:Box(nLinV + 46, 0010 + nColuna, nLinV + 48, 1680 + nColuna)
		nLinV += 50
		QRYF->(dbSkip())
	EndIf

	oPrint:Say(nLinV, 0020 + nColuna, PadR(QRYE->SEQUENCIA + "-" + QRYE->COMPONENTE, 19) + "|" + PadR(QRYE->DESCOMP, 15) + "|" + Transform(QRYE->QTDCOMP, "@E 999,999.999") + "|" + QRYE->UM  + "|" + PadR("", 10) + "|" + PadR("", 8) + "|", oFont0,,,,PAD_LEFT)
	oPrint:Box(nLinV + 46, 0010 + nColuna, nLinV + 48, 1680 + nColuna)
	nLinV += 50

	QRYE->(dbSkip())

EndDo

//imprime roteiro de producao
SG2->(DbSetOrder(1))
If SG2->(DbSeek(xFilial("SG2") + QRYA->CODPROD, .F.))
	cChvSG2 := SG2->(G2_FILIAL + G2_PRODUTO + G2_CODIGO)
	oPrint:Say(nLinV, 0020, "ETAPAS DO PROCESSO PRODUTIVO", oFont1,,,,PAD_LEFT)
	nLinV += 50
	While SG2->(!Eof()) .and. cChvSG2 == SG2->(G2_FILIAL + G2_PRODUTO + G2_CODIGO)
		oPrint:Say(nLinV, 0020, Rtrim(SG2->G2_DESCRI), oFont1,,,,PAD_LEFT)
		nLinV += 45
		oPrint:Say(nLinV, 0020, "DT/HR INI: ____/____/____  ____:____ DT/HR FIN: ____/____/____  ____:____", oFont0,,,,PAD_LEFT)
		nLinV += 50
		SG2->(DbSkip())
	EndDo
EndIf

QRYE->(dbCloseArea())
QRYF->(dbCloseArea())

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLQUALID   บ Autor ณTiago O Beraldi     บ Data ณ 07/02/11    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณDESENHA LAYOUT DA FOLHA DE QUALIDADE                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCP                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function LQualid(cPrd)

Local nLin := 10

oPrint:Box(0010, 0010, 2360, 3360)
nLin := 10
oPrint:Box(nLin, 0010, nLin + 0050, 3360)
oPrint:Say(nLin, 0020, "EUROAMERICAN                                       C O N T R O L E   D E   Q U A L I D A D E                                       OP N." + QRYA->NUMERO, oFont1,,,,PAD_LEFT)
nLin += 55
oPrint:Say(nLin, 0020, "PRODUTO......: " + AllTrim(QRYA->PRODUTO) + " - REV." + QRYA->REVISAO, oFont0,,,,PAD_LEFT)
nLin += 80
oPrint:Say(nLin, 0020, "EMISSรO......: " + DtoC(StoD(QRYA->EMISSAO)) + "DT/HR INI: ____/____/____  ____:____ DT/HR FIN: ____/____/____  ____:____", oFont0,,,,PAD_LEFT)
nLin += 60
oPrint:Box(nLin, 0010, nLin + 2, 3360)
nLin += 15
oPrint:Say(nLin, 0020, PadR("DESCRIวรO", 30) + "|" + PadR("ESPECIFICAวรO", 30) + "|" + PadR("ANALISE 1", 20) + "|" + PadR("ANALISE 2", 20) + "|" + PadR("ANALISE 3", 20) + "|" + PadR("ANALISE FINAL", 20), oFont1,,,,PAD_LEFT)
nLin += 35
oPrint:Box(nLin, 0010, nLin + 2, 3360)
nLin += 15

//cPrdOri := AllTrim(StrTran(Subs(cPrd, 1, 4), ".", ""))       //cPrdOri := AllTrim(StrTran(Subs(cPrd, 1, 4), ".", ""))

//If Empty( cPrd )
//	cPrd := QRYA->PRODUTO
//EndIf

SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1") + cPrd))

dbSelectArea("QPJ")
//dbSetOrder(1)
//dbSeek(xFilial("QPJ") + Alltrim(cPrd))
//If Alltrim(QPJ->QPJ_PROD) == Alltrim(cPrd)
QPJ->(dbSetOrder(1))
If !QPJ->(dbSeek(xFilial("QPJ") + cPrd))
//If dbSeek(xFilial("QPJ") + Alltrim(cPrd))
	//cPrdOri := AllTrim(StrTran(Subs(cPrd, 1, 4), ".", ""))
	//If SubStr(Alltrim(cPrd),13,1) == "."
	//	cPrdOri := cPrdOri + SubStr(Alltrim(cPrd), -3)
	//EndIf
	cPrdOri := AllTrim(cPrd)
Else
	cPrdOri := AllTrim(cPrd)
EndIf

//dbSelectArea("QPJ")
//dbSetOrder(1)
//dbSeek(xFilial("QPJ") + Iif(Subs(cPrd,1,1) == "P", Alltrim(cPrd), cPrdOri))  //dbSeek(xFilial("QPJ") + Iif(Subs(cPrd,1,1) == "P", Alltrim(cPrd), cPrdOri))

nCntQPJ := 0
nPag++

//While !EOF() .And. Alltrim(QPJ->QPJ_PROD) == Iif(Subs(cPrd,1,1) == "P", AllTrim(cPrd),  cPrdOri)
Do While !QPJ->( EOF() ) .And. Alltrim(QPJ->QPJ_PROD) == AllTrim(cPrd)

	cLinImp1 := Upper(PadR(Subs(QPJ->QPJ_DESENS, 1, 30), 30)) + "|"

	If Empty(QPJ->QPJ_ENSAIO)
    	dbSelectArea("QPJ")
    	dbSkip()
 	EndIf

	dbSelectArea("QP1")
	dbSetOrder(1)
	dbSeek(xFilial("QP1")+QPJ->QPJ_ENSAIO)
	If QP1->QP1_TIPO == "C"
		cLinImp1 += PadR("DE  " + Transform(QPJ->QPJ_LINF,"@E 999,999,999.99"), 30)
	Else
		cLinImp1 += PadR(" " + Subs(QPJ->QPJ_TEXTO,1,24), 30)
	EndIf

	cLinImp1 += "|" + Space(20) + "|" + Space(20) + "|" + Space(20) + "|" + Space(20)

	cLinImp2 := Upper(PadR(Subs(QPJ->QPJ_DESENS, 30, 10), 30)) + "|"

	dbSelectArea("QP1")
	dbSetOrder(1)
	dbSeek(xFilial("QP1")+QPJ->QPJ_ENSAIO)
	If QP1->QP1_TIPO == "C"
		If QPJ->QPJ_LINF # QPJ->QPJ_LSUP
			cLinImp2 += PadR("ATE " + Transform(QPJ->QPJ_LSUP,"@E 999,999,999.99"), 30)
		EndIf
	Else
			cLinImp2 += PadR(" " + Subs(QPJ->QPJ_TEXTO, 26, 9), 30)
	EndIf

	cLinImp2 += "|" + Space(20) + "|" + Space(20) + "|" + Space(20) + "|" + Space(20)

	nLin += 15
	oPrint:Box(nLin, 0010, nLin + 2, 3360)
	nLin += 25

	oPrint:Say(nLin, 0020, cLinImp1, oFont0,,,,PAD_LEFT)

	nLin += 70
	oPrint:Say(nLin, 0020, cLinImp2, oFont0,,,,PAD_LEFT)

	nLin += 70
	oPrint:Box(nLin, 0010, nLin + 2, 3360)

	nCntQPJ++

	QPJ->(dbSkip())

EndDo

If nCntQPJ > 5
	oPrint:EndPage()
	oPrint:StartPage()
	nPag++
	oPrint:Box(0010, 0010, 2360, 3360)
	nLin := 10
	oPrint:Box(nLin, 0010, nLin + 0050, 3360)
	oPrint:Say(nLin, 0020, "EUROAMERICAN                                       C O N T R O L E   D E   Q U A L I D A D E                                       OP N." + QRYA->NUMERO, oFont1,,,,PAD_LEFT)
	nLin += 55
	oPrint:Say(nLin, 0020, "PRODUTO......: " + AllTrim(QRYA->PRODUTO) + " - REV." + QRYA->REVISAO, oFont0,,,,PAD_LEFT)
	nLin += 80
	oPrint:Say(nLin, 0020, "EMISSรO......: " + DtoC(StoD(QRYA->EMISSAO)) + "DT/HR INI: ____/____/____  ____:____ DT/HR FIN: ____/____/____  ____:____", oFont0,,,,PAD_LEFT)
	nLin += 60
	oPrint:Box(nLin, 0010, nLin + 2, 3360)
	nLin += 15
	nLinF := 230
Else
	nLinF := 1300
EndIf
/*
oPrint:Box(nLinF, 0010, nLinF + 2, 3360)
nLinF += 10
oPrint:Say(nLinF, 0020, "                                                         D E S C A R G A  /  E M B A L A G E M                                                                ", oFont1,,,,PAD_LEFT)
nLinF += 60
oPrint:Box(nLinF, 0010, nLinF + 2, 3360)
nLinF += 10
oPrint:Say(nLinF, 0020 , "TAMBOR(ES)......:_________X_________ CONTAINER(ES)...:_________X_________ GRANEL..........:_________X_________ SACO 1 KG.......: _________X_________", oFont0,,,,PAD_LEFT)
nLinF += 70
oPrint:Say(nLinF, 0020 , "TAMBOR INCOMP...:_________X_________ CONTAINER INCOMP:_________X_________ BALDE 5 L.......:_________X_________ SACO 30 KG......: _________X_________", oFont0,,,,PAD_LEFT)
nLinF += 70
oPrint:Say(nLinF, 0020 , "BOMBONA(S)......:_________X_________ BARRICA(S)......:_________X_________ BALDE 10 L......:_________X_________ LATA(S).........: _________X_________", oFont0,,,,PAD_LEFT)
nLinF += 70
oPrint:Say(nLinF, 0020 , "BOMBONA INCOMP..:_________X_________ BARRICA INCOMP..:_________X_________ BALDE 20 L......:_________X_________ GALรO(ีES)......: _________X_________", oFont0,,,,PAD_LEFT)
nLinF += 70

oPrint:Box(nLinF, 0010, nLinF + 2, 3360)
nLinF += 10
oPrint:Say(nLinF, 0020 , "                   |TURNO A        |TURNO B        |TURNO C        |OBSERVACีES", oFont0,,,,PAD_LEFT)
nLinF += 70
oPrint:Box(nLinF, 0010, nLinF + 2, 3360)
nLinF += 10
oPrint:Say(nLinF, 0020 , "OPERADOR           |               |               |               |           ", oFont0,,,,PAD_LEFT)
nLinF += 70
oPrint:Box(nLinF, 0010, nLinF + 2, 3360)
nLinF += 10
oPrint:Say(nLinF, 0020 , "AJUDANTE           |               |               |               |           ", oFont0,,,,PAD_LEFT)
nLinF += 70
oPrint:Box(nLinF, 0010, nLinF + 2, 3360)
nLinF += 10
oPrint:Say(nLinF, 0020 , "ASS.LIDER          |               |               |               |           ", oFont0,,,,PAD_LEFT)
nLinF += 70
oPrint:Box(nLinF, 0010, nLinF + 2, 3360)
*/
oPrint:Say(1800, 0020, "APROVADO                (   )                                             REPROCESSAR             (   )                                             ", oFont0,,,,PAD_LEFT)
oPrint:Say(1870, 0020, "REPROVADO               (   )                                             ACERTO COMERCIAL        (   )                                             ", oFont0,,,,PAD_LEFT)
oPrint:Say(1940, 0020, "APROVADO COM RESTRIวีES (   )                                                                                         								", oFont0,,,,PAD_LEFT)
oPrint:Say(2010, 0020, "ASS. ANALISTA...............:____________________________________________ ASS. RESPONSAVEL............:_____________________________________________", oFont0,,,,PAD_LEFT)
oPrint:Say(2080, 0020, "N. RETENวรO.................:_____________________________________________OBSERVAวีES.................:_____________________________________________", oFont0,,,,PAD_LEFT)
oPrint:Say(2150, 0001, "____________________________________________________________________________________________________________________________________________________", oFont0,,,,PAD_LEFT)
oPrint:Say(2220, 0001, "____________________________________________________________________________________________________________________________________________________", oFont0,,,,PAD_LEFT)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFCRIASX1  บ Autor ณTiago O. Beraldi    บ Data ณ  07/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณGERA DICIONARIO DE PERGUNTAS                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fCriaSX1( cPerg )

Local cKey := ""
Local aHelpEng := {}
Local aHelpPor := {}
Local aHelpSpa := {}

PutSX1(cPerg,"01","De Emissใo         ","","","mv_ch1","D",08,0,0,"G","",""   ,"","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"02","At้ Emissใo        ","","","mv_ch2","D",08,0,0,"G","",""   ,"","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"03","De O.P.            ","","","mv_ch3","C",06,0,0,"G","","SC2","","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"04","Ate O.P.           ","","","mv_ch4","C",06,0,0,"G","","SC2","","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"05","De Item O.P.       ","","","mv_ch5","C",02,0,0,"G","","SC2","","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"06","Ate Item O.P.      ","","","mv_ch6","C",02,0,0,"G","","SC2","","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"07","De Produto         ","","","mv_ch7","C",15,0,0,"G","","SB1","","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"08","Ate Produto        ","","","mv_ch8","C",15,0,0,"G","","SB1","","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"09","De Grupo           ","","","mv_ch9","C",04,0,0,"G","","SBM","","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"10","Ate Grupo          ","","","mv_cha","C",04,0,0,"G","","SBM","","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","")

cKey     := "P." + cPerg + "01."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe a Emissใo Inicial.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P." + cPerg + "02."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informa a Emissใo Final.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P." + cPerg + "03."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe a O.P. Inicial.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P." + cPerg + "04."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe a O.P. Final.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P." + cPerg + "05."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe o Produto Inicial.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P." + cPerg + "06."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe o Produto Final.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P." + cPerg + "07."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe o Grupo Inicial.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P." + cPerg + "08."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe o Grupo Final.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

Return
