#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#include "colors.ch"

#define ENTER chr(13) + chr(10)
#define PAD_LEFT            0
#define PAD_RIGHT           1
#define PAD_CENTER          2
#define PAD_CENTER          2

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCPR006   บ Autor ณTiago O Beraldi     บ Data ณ 07/02/11    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณORDEM DE PRODUCAO - QUALYVINIL                              บฑฑ
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
User Function PCPR006()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aArea   := GetArea()
Local lOk	  := .F.

Private cPerg   := "PCPR006"
Private cTitulo := "Ordem de Produ็ใo"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Dicionario de Perguntas                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
fCriaSX1(cPerg)
Pergunte(cPerg, .F.)

oPrint := PcoPrtIni(cTitulo, .F., 2,, @lOk, cPerg)

If lOk
	oProcess := MsNewProcess():New({|lEnd| PCPR006Imp(@lEnd, oPrint, oProcess)},"","",.F.)
	oProcess :Activate()
	PcoPrtEnd(oPrint)
EndIf

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCPR006IMPบ Autor ณTiago O Beraldi     บ Data ณ 07/02/11    บฑฑ
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
Static Function PCPR006Imp(lEnd,oPrint)

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
cQry := " SELECT	C2_NUM + '.' + C2_ITEM + '.' + C2_SEQUEN NUMERO, RTRIM(C2_PRODUTO) + ' - ' + B1_DESC PRODUTO, B1_UM UND, C2_EMISSAO EMISSAO, C2_QUANT QUANT, SUM((100 * Z0_TEMPAD) + (60 * CONVERT(INT, Z0_TEMPAD))) TEMPO, C2_RECURSO EQUIP, C2_REVISAO + '-' + ISNULL((SELECT CONVERT(VARCHAR, CONVERT(DATETIME, G5_DATAREV), 103) FROM "+RetSqlName("SG5")+" WHERE D_E_L_E_T_ = '' AND G5_PRODUTO = C2_PRODUTO AND G5_REVISAO = C2_REVISAO),'') REVISAO, B1_TIPO, C2_PRODUTO CODPROD  " + ENTER
cQry += " FROM		" + RetSqlName("SC2") + " SC2, " + RetSqlName("SB1") + " SB1, " + RetSqlName("SZ0") + " SZ0 " + ENTER
cQry += " WHERE	SC2.D_E_L_E_T_ = '' " + ENTER
cQry += " 		AND SB1.D_E_L_E_T_ = '' " + ENTER
cQry += " 		AND SZ0.D_E_L_E_T_ = '' " + ENTER
cQry += " 		AND Z0_PRODUTO = C2_PRODUTO " + ENTER
cQry += " 		AND C2_PRODUTO = B1_COD " + ENTER
cQry += " 		AND C2_DATRF = '' " + ENTER
cQry += " 		AND C2_EMISSAO BETWEEN '" + DtoS(mv_par01) + "' AND '" + DtoS(mv_par02) + "' " + ENTER
cQry += " 		AND C2_NUM BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' " + ENTER
cQry += " 		AND C2_ITEM BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' " + ENTER
cQry += " 		AND C2_PRODUTO BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' " + ENTER
cQry += " 		AND C2_GRUPO BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "' " + ENTER
cQry += " 		AND C2_FILIAL = '" + xFilial("SC2") + "' " + ENTER
cQry += " GROUP BY C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO, B1_DESC, B1_UM, C2_EMISSAO, C2_QUANT, C2_RECURSO, C2_REVISAO, B1_TIPO " + ENTER
cQry += " ORDER BY NUMERO "

MemoWrite("pcpr006a.sql", cQry)

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

While !QRYA->(EOF())

	nLin    := 25
	nLinV   := 25

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Contador de Impressao                                               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SC2")
	dbSetOrder(1)
	dbSeek(xFilial("SC2") + StrTran(QRYA->NUMERO, ".", ""))
	Reclock("SC2",.F.)
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
	SC2->( MsUnLock() )

	If QRYA->B1_TIPO == "PI" //Subs(QRYA->NUMERO, 8, 6) == "01.001" 	Alterado 01/06/2016

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Layout Frente                                                       ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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
		cQry += " 			AND C2_FILIAL = '" + xFilial("SC2") + "' " + ENTER
		cQry += " 			AND D4_FILIAL = C2_FILIAL " + ENTER
		cQry += " ORDER BY SEQUENCIA "

		MemoWrite("pcpr006b.sql", cQry)

		If Select("QRYB") > 0
			QRYB->(dbCloseArea())
		EndIf

		TCQUERY cQry NEW ALIAS QRYB

		cQry := " SELECT	Z0_SEQINI SEQUENCIA, " + ENTER
		cQry += " ISNULL(UPPER(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),SUBSTRING (Z0_DESCRIC,1,75)))), '') INSTRUCAO_1, " + ENTER
		cQry += " ISNULL(UPPER(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),SUBSTRING (Z0_DESCRIC,76,74)))), '') INSTRU_2, " + ENTER
		cQry += " ISNULL(UPPER(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),SUBSTRING (Z0_DESCRIC,150,100)))), '') INSTR_3 " + ENTER
		cQry += " FROM		" + RetSqlName("SZ0") + ENTER
		cQry += " WHERE	D_E_L_E_T_ = '' " + ENTER
		cQry += "		AND Z0_PRODUTO = '" + QRYB->PRODUTO + "' "
		cQry += " 			AND Z0_FILIAL = '" + xFilial("SZ0") + "' " + ENTER

		MemoWrite("pcpr006c.sql", cQry)

		If Select("QRYC") > 0
    		QRYC->(dbCloseArea())
		EndIf

		TCQUERY cQry NEW ALIAS QRYC

		nLin := 0425

		QRYB->(dbGoTop())
		QRYC->(dbGoTop())

		While !QRYB->(EOF())
			If QRYB->SEQUENCIA >= QRYC->SEQUENCIA .And. !QRYC->(EOF())
				oPrint:Say(nLin, 0020,ALLTRIM(QRYC->INSTRUCAO_1) , oFont1,,,,PAD_LEFT)
				oPrint:Say(nLin + 32,0020,ALLTRIM(QRYC->INSTRU_2) , oFont1,,,,PAD_LEFT)
				oPrint:Say(nLin + 64,0020,ALLTRIM(QRYC->INSTR_3) , oFont1,,,,PAD_LEFT)
				oPrint:Box(nLin + 102, 0010, nLin + 104, 1680)
				nLin +=90
				QRYC->(dbSkip())
			EndIf

			oPrint:Say(nLin + 12, 0020, PadR(QRYB->SEQUENCIA + "-" + QRYB->COMPONENTE, 19) + "|" + IIF(SUBS(QRYB->PRODUTO,1,8)$"8300.001#8300.039",PadR("",15),PadR(QRYB->DESCOMP, 15)) + "|" + Transform(QRYB->QTDCOMP, "@E 999,999.999") + "|" + QRYB->UM  + "|" + PadR("", 10) + "|" + PadR("", 8) + "|", oFont0,,,,PAD_LEFT)
			oPrint:Box(nLin + 46, 0010, nLin + 48, 1680)
			nLin += 50
			QRYB->(dbSkip())
		EndDo

		nLin := 795

		QRYB->(dbGoTop())

		cQry := " SELECT	UPPER(QPJ_DESENS) ENSAIO, QPJ_LINF LIMINF, QPJ_LSUP LIMSUP, QPJ_TEXTO TEXTO, QP1_TIPO TIPO " + ENTER
		cQry += " FROM	" + RetSqlName("QPJ") + " QPJ, " + RetSqlName("QP1") + " QP1" + ENTER
		cQry += " WHERE	QPJ.D_E_L_E_T_ = '' " + ENTER
		cQry += " 		AND QP1.D_E_L_E_T_ = '' " + ENTER
		cQry += " 		AND QPJ_ENSAIO = QP1_ENSAIO " + ENTER
		cQry += " 		AND QPJ_PROD = '" + QRYB->PRODUTO + "' " + ENTER
		cQry += " 			AND QPJ_FILIAL = '" + xFilial("QPJ") + "' " + ENTER
		cQry += " 			AND QP1_FILIAL = " + xFilial("QP1") + " " + ENTER
		cQry += " ORDER BY QPJ_PROD, QPJ_ITEM "

		MemoWrite("pcpr006d.sql", cQry)

		If Select("QRYD") > 0
		    QRYD->(dbCloseArea())
		EndIf

		TCQUERY cQry NEW ALIAS QRYD

		QRYD->(dbGoTop())

		While !QRYD->(EOF())

			If QRYD->TIPO != "C"
				oPrint:Say(nLin, 1700, PadR(QRYD->ENSAIO, 30) + "|" + PadR(Subs(QRYD->TEXTO, 1, 15), 15) + "|" + PadR("",12) + "|", oFont0,,,,PAD_LEFT)
				oPrint:Say(nLin + 50, 1700, PadR("", 30) + "|" + PadR(Subs(QRYD->TEXTO, 16, 15), 15) + "|" + PadR("",12) + "|", oFont0,,,,PAD_LEFT)
			Else
				oPrint:Say(nLin, 1700, PadR(QRYD->ENSAIO, 30) + "|" + "DE:  " + PadL(Transform(QRYD->LIMINF, "999,999.999"), 10) + "|" + PadR("",12) + "|", oFont0,,,,PAD_LEFT)
				oPrint:Say(nLin + 50, 1700, PadR("", 30) + "|" + "ATษ: " + PadL(Transform(QRYD->LIMSUP, "999,999.999"), 10) + "|" + PadR("",12) + "|", oFont0,,,,PAD_LEFT)
			EndIf

			oPrint:Box(nLin + 96, 1690, nLin + 98, 3350)
			nLin += 100
			QRYD->(dbSkip())

		EndDo

		oPrint:EndPage()

		QRYB->(dbCloseArea())
		QRYC->(dbCloseArea())
		QRYD->(dbCloseArea())

		QRYA->(dbSkip())

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Layout Verso                                                        ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Else
		cLote := Subs(QRYA->NUMERO, 1, 6)
		nCont := 1

		oPrint:StartPage()

		While !QRYA->(EOF()) .And. cLote == Subs(QRYA->NUMERO, 1, 6)

 			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Contador de Impressao                                               ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			dbSelectArea("SC2")
			dbSetOrder(1)
			dbSeek(xFilial("SC2") + StrTran(QRYA->NUMERO, ".", ""))
			/*Reclock("SC2",.F.)

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

			SC2->( MsUnLock() )*/

			oPrint:Box(0010, 0010, 2360, 1680)
			oPrint:Box(0010, 1680, 2360, 3360)

			nCont++

			LVerso(nCont)

			QRYA->(dbSkip())

		EndDo

		oPrint:EndPage()

	EndIf

EndDo

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

oPrint:Say(0015, 0020, "QUALYCRIL                   ORDEM DE PRODUวรO               N." + QRYA->NUMERO, oFont1,,,,PAD_LEFT)

oPrint:Box(0060, 0010, 0325, 1680)

oPrint:Say(0065, 0020, "PRODUTO     .: " + RTrim(QRYA->PRODUTO), oFont0,,,,PAD_LEFT)
oPrint:Say(0115, 0020, "EMISSรO     .: " + DtoC(StoD(QRYA->EMISSAO)) + " TEMPO PRV: " + StrZero(Int(QRYA->TEMPO / 60), 2) + ":" + StrZero(QRYA->TEMPO % 60, 2) + " EQUIP: " + QRYA->EQUIP, oFont0,,,,PAD_LEFT)
oPrint:Say(0165, 0020, "REVISAO     .: #EST " + RTrim(QRYA->REVISAO) + " #PRC ", oFont0,,,,PAD_LEFT)
//oPrint:Say(0165, 0020, "REVISAO     .: #EST " + RTrim(QRYA->REVISAO) + " #PRC " + RTrim(QRYA->REV2), oFont0,,,,PAD_LEFT)
oPrint:Say(0215, 0020, "QTD PREVISTA.: " + Transform(QRYA->QUANT, "@E 999,999.99") + " " + QRYA->UND, oFont0,,,,PAD_LEFT)
oPrint:Say(0265, 0020, "QTD REALIZADA:________________              RENDIMENTO:________________%", oFont0,,,,PAD_LEFT)

MSBAR("CODE128",1.2,11.0,StrTran(RTrim(QRYA->NUMERO),".",""),oPrint,.F.,,.T.,0.0295,1.0,,,,.F.)

oPrint:Box(0325, 0010, 0425, 1680)
oPrint:Say(0335, 0020, "C O M P O N E N T E S                           |A L M O X A R I F A D O  ", oFont1,,,,PAD_LEFT)
oPrint:Say(0385, 0020, "CODIGO             |" + IIF(SUBS(QRYA->PRODUTO,1,8)$"8300.001#8300.039",PadR("",9),"DESCRICAO")+ "      |QUANTID  |UM|QTD REAL  |LOTE    |ALM  ", oFont1,,,,PAD_LEFT)

// Lado Direito
oPrint:Box(0010, 1680, 0060, 3360)
oPrint:Say(0015, 1700, "QUALYCRIL             HISTำRICO DE PRODUวรO/ANมLISE         N." + QRYA->NUMERO, oFont1,,,,PAD_LEFT)

oPrint:Box(0060, 1680, 0160, 3360)
oPrint:Box(0160, 1680, 0410, 3360)
oPrint:Say(0070, 1700, "A D I ว ร O   E X T R A - F ำ R M U L A                                   ", oFont1,,,,PAD_LEFT)
oPrint:Say(0125, 1700, "CODIGO             |DESCRICAO      |QUANTID  |UM|LOTE     |VISTO          ", oFont1,,,,PAD_LEFT)
oPrint:Say(0180, 1700, "___________________|_______________|_________|__|_________|_______________", oFont0,,,,PAD_LEFT)
oPrint:Say(0235, 1700, "___________________|_______________|_________|__|_________|_______________", oFont0,,,,PAD_LEFT)
oPrint:Say(0290, 1700, "___________________|_______________|_________|__|_________|_______________", oFont0,,,,PAD_LEFT)
oPrint:Say(0345, 1700, "___________________|_______________|_________|__|_________|_______________", oFont0,,,,PAD_LEFT)

//Imprime o roteiro de producao
lin := 415
SG2->(DbSetOrder(1))
If SG2->(DbSeek(xFilial("SG2") + QRYA->CODPROD, .F.))
	cChvSG2 := SG2->(G2_FILIAL + G2_PRODUTO + G2_CODIGO)
	While SG2->(!Eof()) .and. cChvSG2 == SG2->(G2_FILIAL + G2_PRODUTO + G2_CODIGO)
		oPrint:Say(lin, 1700, Rtrim(SG2->G2_DESCRI), oFont1,,,,PAD_LEFT)
		lin += 45
		oPrint:Say(lin, 1700, "DT/HR INI: ____/____/____  ____:____ DT/HR FIN: ____/____/____  ____:____", oFont0,,,,PAD_LEFT)
		lin += 50
		SG2->(DbSkip())
	EndDo
Else  //se nao tem imprime o padrao atual
	oPrint:Say(lin, 1700, "PESAGEM", oFont1,,,,PAD_LEFT)
	lin += 45
	oPrint:Say(lin, 1700, "DT/HR INI: ____/____/____  ____:____ DT/HR FIN: ____/____/____  ____:____", oFont0,,,,PAD_LEFT)
	lin += 50
	oPrint:Say(lin, 1700, "PIGMENTAวรO", oFont1,,,,PAD_LEFT)
	lin += 45
	oPrint:Say(lin, 1700, "DT/HR INI: ____/____/____  ____:____ DT/HR FIN: ____/____/____  ____:____", oFont0,,,,PAD_LEFT)
	lin += 50
	oPrint:Say(lin, 1700, "ANมLISE", oFont1,,,,PAD_LEFT)
	lin += 45
	oPrint:Say(lin, 1700, "DT/HR INI: ____/____/____  ____:____ DT/HR FIN: ____/____/____  ____:____", oFont0,,,,PAD_LEFT)
	lin += 50
EndIf

oPrint:Box(lin, 1680, lin+5, 3360)
lin += 20
oPrint:Say(lin, 1700, "E N S A I O S - L A B O R A T ำ R I O                                    ", oFont1,,,,PAD_LEFT)
lin += 35
oPrint:Say(lin, 1700, "DESCRICAO                     |ESPECIFICAวรO  |ANALISE I   |ANALISE FINAL", oFont1,,,,PAD_LEFT)

oPrint:Box(1795, 1680, 2000, 3360)
oPrint:Say(1845, 1700, "ASS. ALMOX...:______________________  ASS. OPERADOR:______________________", oFont0,,,,PAD_LEFT)
oPrint:Say(1945, 1700, "ASS. ANALISTA:______________________  ASS. AJUDANTE:______________________", oFont0,,,,PAD_LEFT)
oPrint:Say(2045, 1700, "ASS. LIDER...:______________________  ASS. ENCARREG:______________________", oFont0,,,,PAD_LEFT)
oPrint:Box(2095, 1680, 2100, 3360)
oPrint:Say(2145, 1700, "APROVADO (   ) REPROVADO (   )   RETENวรO:________________________________", oFont1,,,,PAD_LEFT)
oPrint:Say(2215, 1700, "APROVADO COM RESTRIวีES  (   )   _________________________________________", oFont1,,,,PAD_LEFT)
oPrint:Say(2285, 1700, "OBS. GERAIS:______________________________________________________________", oFont0,,,,PAD_LEFT)

cQry := " SELECT	SUM(CASE WHEN B1_UM <> 'KG' THEN B1_PESO * B2_QATU ELSE B2_QATU END) QUANT " + ENTER
cQry += " FROM	" + RetSqlName("SB2") + " SB2, " + RetSqlName("SB1") + " SB1" + ENTER
cQry += " WHERE	SB1.D_E_L_E_T_ = '' " + ENTER
cQry += " 		AND SB2.D_E_L_E_T_ = '' " + ENTER
cQry += "  		AND B2_COD = B1_COD " + ENTER
cQry += " 		AND B2_LOCAL = '07' " + ENTER
cQry += "  		AND SUBSTRING(B2_COD, 1, 8) = '" + AllTrim(SC2->C2_PRODUTO) + "' "
cQry += " 			AND B2_FILIAL = '" + xFilial("SB2") + "' " + ENTER

If Select("QRY") > 0
     QRY->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS QRY

If QRY->QUANT <> 0
	oPrint:Say(2245, 1970, "VERIFICAR SALDO DE REPROCESSO (" + AllTrim(Transform(QRY->QUANT, "@E 999,999,999.99")) + " KG)", oFont1,,,,PAD_LEFT)
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
cQry += " 			AND (SELECT MAX(D2_EMISSAO) FROM " + RetSqlName("SD2") + " WHERE D2_FILIAL = B2_FILIAL AND D_E_L_E_T_ = '' AND D2_COD = B2_COD) < GETDATE() - 365 " + ENTER
cQry += " 			AND B2_FILIAL = '" + xFilial("SB2") + "' " + ENTER

If Select("QRY") > 0
     QRY->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS QRY

If QRY->QUANT <> 0
	oPrint:Say(2325, 1750, "VERIFICAR PRODUTOS VENCIDOS EM ESTOQUE (" + AllTrim(Transform(QRY->QUANT, "@E 999,999,999.99")) + " KG)", oFont1,,,,PAD_LEFT)
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
cQry += " 			AND C2_FILIAL = '" + xFilial("SC2") + "' " + ENTER
cQry += " 			AND D4_FILIAL = C2_FILIAL " + ENTER
cQry += " ORDER BY SEQUENCIA "

MemoWrite("pcpr006e.sql", cQry)

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

MemoWrite("pcpr006f.sql", cQry)

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
oPrint:Say(nLinV, 0020 + nColuna, "QUALYCRIL                   ORDEM DE PRODUวรO               N." + QRYA->NUMERO, oFont1,,,,PAD_LEFT)

Do Case
	Case nQtOP == 1
		MSBAR("CODE128", 1.2,( 11 * (IIf(nQtOP<=3, 1, 2 ))),StrTran(RTrim(QRYA->NUMERO),".",""),oPrint,.F.,,.T.,0.0295,1.0,,,,.F.)

	Case nQtOP == 2
		MSBAR("CODE128", 7.1,( 11 * (IIf(nQtOP<=3, 1, 2 ))),StrTran(RTrim(QRYA->NUMERO),".",""),oPrint,.F.,,.T.,0.0295,1.0,,,,.F.)

	Case nQtOP == 3
		MSBAR("CODE128", 12.9,( 11 * (IIf(nQtOP<=3, 1, 2 ))),StrTran(RTrim(QRYA->NUMERO),".",""),oPrint,.F.,,.T.,0.0295,1.0,,,,.F.)
EndCase


nLinV += 55
oPrint:Say(nLinV, 0020 + nColuna, "PRODUTO......: " + AllTrim(QRYA->PRODUTO), oFont0,,,,PAD_LEFT)
nLinV += 45
oPrint:Say(nLinV, 0020 + nColuna, "EMISSรO......: " + DtoC(StoD(QRYA->EMISSAO)) + SPACE(4) + "TEMPO PREVISTO.: " + StrZero(Int(QRYA->TEMPO / 60), 2) + ":" + StrZero(QRYA->TEMPO % 60, 2), oFont0,,,,PAD_LEFT)
nLinV += 45
oPrint:Say(nLinV, 0020 + nColuna, "EQUIPAMENTO..: " + RTrim(QRYA->EQUIP), oFont0,,,,PAD_LEFT)
nLinV += 45
oPrint:Say(nLinV, 0020 + nColuna, "REVISAO......: " + RTrim(QRYA->REVISAO), oFont0,,,,PAD_LEFT)
nLinV += 50
//oPrint:Say(nLinV, 0020 + nColuna, "DT/HR INICIO.: ___/___/___  ___:___    DT/HR FIM: ___/___/___  ___:___", oFont0,,,,PAD_LEFT)
//nLinV += 75
oPrint:Say(nLinV, 0020 + nColuna, "QTD PREVISTA.: " + Transform(QRYA->QUANT, "@E 999,999.99") + " " + QRYA->UND, oFont0,,,,PAD_LEFT)
oPrint:Say(nLinV, 0750 + nColuna, "QTD REAL:__________    REND:__________% ", oFont0,,,,PAD_LEFT)
nLinV += 60
oPrint:Box(nLinV, 0010 + nColuna, nLinV + 0100, 1680 + nColuna)
nLinV += 10
oPrint:Say(nLinV, 0020 + nColuna, "C O M P O N E N T E S                          |A L M O X A R I F A D O   ", oFont1,,,,PAD_LEFT)
nLinV += 50
oPrint:Say(nLinV, 0020 + nColuna, "CODIGO             |"+ IIF(SUBS(QRYE->PRODUTO,1,8)$"8300.001#8300.039",PadR("",9),"DESCRICAO")+"      |QUANTID  |UM|QTD REAL  |LOTE    |ALM  ", oFont1,,,,PAD_LEFT)
nLinV += 50

While !QRYE->(EOF())
	If QRYE->SEQUENCIA >= QRYF->SEQUENCIA .And. !QRYF->(EOF())
		oPrint:Say(nLinV, 0020 + nColuna, ALLTRIM(QRYF->INSTRUCAO), oFont1,,,,PAD_LEFT)
		oPrint:Box(nLinV + 46, 0010 + nColuna, nLinV + 48, 1680 + nColuna)
		nLinV += 50
		QRYF->(dbSkip())
	EndIf

	oPrint:Say(nLinV, 0020 + nColuna, PadR(QRYE->SEQUENCIA + "-" + QRYE->COMPONENTE, 19) + "|" + IIF(SUBS(QRYE->PRODUTO,1,8)$"8300.001#8300.039",PadR("",15),PadR(QRYE->DESCOMP, 15)) + "|" + Transform(QRYE->QTDCOMP, "@E 999,999.999") + "|" + QRYE->UM  + "|" + PadR("", 10) + "|" + PadR("", 8) + "|", oFont0,,,,PAD_LEFT)
	oPrint:Box(nLinV + 46, 0010 + nColuna, nLinV + 48, 1680 + nColuna)
	nLinV += 50

	QRYE->(dbSkip())

EndDo

//oPrint:Say(nLinV, 0020 + nColuna, "PESAGEM 1     |PESAGEM 2     |PESAGEM 3     |PESAGEM 4     |PESAGEM 5    ", oFont1,,,,PAD_LEFT)
oPrint:Say(nLinV, 0020 + nColuna, "ORIENTAวรO DE PESAGEM                                                    ", oFont1,,,,PAD_LEFT)  //Alterado 25/01/17 - Atender auditoria
nLinV += 50
//oPrint:Say(nLinV, 0020 + nColuna, "              |              |              |              |             ", oFont1,,,,PAD_LEFT)
oPrint:Say(nLinV, 0020 + nColuna, "MอNIMO:_________________                 MมXIMO:_________________        ", oFont1,,,,PAD_LEFT)  //Alterado 25/01/17 - Atender auditoria
nLinV += 70

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
Static Function fCriaSX1()

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
