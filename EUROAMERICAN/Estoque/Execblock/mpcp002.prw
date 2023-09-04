#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} mpcp002
//rotina para verificar se os empenhos estao dentro da margem
//de seguranca.
@author mjlozzardo
@since 25/01/2018
@version 1.0
@type function
/*/
User Function mpcp002(cNumOP)
	Local nI     := 0
	Local nPos   := 0
	Local aEstru := {}
	Local aDados := {}
	Local aErros := {}
	Local cEof   := Chr(13) + Chr(10)
	Local nMrg   := SuperGetMV("ES_A250MRG", .T., 1.04)
	Local lRet   := .T.
	Local cAlias := Alias()
	Local aCpoTrb:= {}
	Local cQuery := ""
	Local cArqTrb:= ""
	Local cIndTrb:= ""
	Local cTexto := ""
	Local cFilLog:= ""

	Private nEstru := 0

	Default cNumOP := ""

	If !Empty(cNumOP)
		//Monta estrutura
		SC2->(DbSetOrder(1))
		SC2->(DbSeek(xFilial("SC2") + cNumOP, .F.))
		aEstru := Estrut(SC2->C2_PRODUTO, SC2->C2_QUANT,.T.)

		For nI := 1 To Len(aEstru)
			If aEstru[nI, 4] <> 0
				nPos := aScan(aDados, {|x| Rtrim(x[1]) == Rtrim(aEstru[nI, 3])})
				If nPos > 0
					aDados[nPos, 2] += aEstru[nI, 4]
				Else
					aAdd(aDados, {aEstru[nI, 3], aEstru[nI, 4], " "})
				EndIf
			EndIf
		Next nI

		//Busca empenhos
		cQuery := "SELECT D4_COD, SUM(D4_QTDEORI) D4_QTDEORI
		cQuery += " FROM " + RetSqlName("SD4") + " SD4"
		cQuery += " WHERE D4_FILIAL = '" + xFilial("SD4") + "'"
		cQuery += "   AND D4_OP = '" + cNumOP + "'"
		cQuery += "   AND SD4.D_E_L_E_T_ = ''"
		cQuery += " GROUP BY D4_COD"
		cQuery += " ORDER BY D4_COD"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB1", .F., .F.)

		//Arquivo fisico
		aAdd(aCpoTrb, {"D4_COD"    , "C", 15, 0})
		aAdd(aCpoTrb, {"D4_QTDEORI", "N", 17, 6})
		cArqTrb := CriaTrab(aCpoTRB, .T.)
		cIndTrb := StrTran(cArqTrb, ".DTC", ".CDX")
		DbUseArea(.T., "DBFCDX", cArqTRB, "TRB2", .T., .F.)
		DbSelectArea("TRB2")
		Index On D4_COD To &cIndTrb

		//Executa o APPEND no arquivo DBF com base nos dados gerados pela Query
		MsAppend("TRB2", "TRB1")

		//Confere empenho x estrutura
		TRB1->(DbGoTop())
		While TRB1->(!Eof())
			nPos := aScan(aDados, {|x| Rtrim(x[1]) == Rtrim(TRB1->D4_COD)})
			If nPos <> 0
				If TRB1->D4_QTDEORI > (aDados[nPos, 2] * nMrg)
					//Empenho maior que estrutura * margem
					aAdd(aErros, {TRB1->D4_COD, TRB1->D4_QTDEORI, "MA", (aDados[nPos, 2] * nMrg)})
				EndIf

				If TRB1->D4_QTDEORI < (aDados[nPos, 2] / nMrg)
					//Empenho menor que estrutura * margem
					aAdd(aErros, {TRB1->D4_COD, TRB1->D4_QTDEORI, "ME", (aDados[nPos, 2] / nMrg)})
				EndIf

			Else
				//Tem no empenho e nao tem na estrutura
			//	aAdd(aErros, {TRB1->D4_COD, TRB1->D4_QTDEORI, "NE", 0})
			EndIf
			TRB1->(DbSkip())
		EndDo

		//Verifica se algum item da estrutura foi retirado do empenho
		TRB2->(DbSetOrder(1))
		For nI := 1 To Len(aDados)
			TRB2->(DbGoTop())
			If !TRB2->(DbSeek(aDados[nI, 1], .F.))
				//aAdd(aErros, {aDados[nI, 1], 0, "SE", aDados[nI, 2]})
			EndIf
		Next nI
		TRB1->(DbCloseArea())
		TRB2->(DbCloseArea())

		//Existe divergencia
		If Len(aErros) > 0
			lRet := .F.

			cTexto := "Ordem de producao: " + cNumOP + cEof
			cTexto += "Produto: " + SC2->C2_PRODUTO + Posicione("SB1", 1, xFilial("SB1") + SC2->C2_PRODUTO, "B1_DESC") + cEof
			cTexto += "Qtd. OP       : " + TransForm(SC2->C2_QUANT, "@E 999,999,999.999999") + cEof
			cTexto += "Qtd. Produzida: " + TransForm(M->D3_QUANT, "@E 999,999,999.999999") + cEof
			//cTexto += "Qtd. Ganho    : " + TransForm(M->D3_QTGANHO + M->D3_QTMAIOR, "@E 999,999,999.999999") + cEof
			cTexto += "Qtd. Perda    : " + TransForm(M->D3_PERDA, "@E 999,999,999.999999") + cEof
			cTexto += "Relação das inconsistencias encontradas" + cEof
			For nI := 1 To Len(aErros)
				If aErros[nI, 3] == "MA"		//empenho maior que estrutura
					cTexto += aErros[nI, 1] + " - qtd empenhada maior que a estrutura, empenho = " + TransForm(aErros[nI, 2], "@E 999,999,999.999999")
					cTexto += " calculado = " +  TransForm(aErros[nI, 4], "@E 999,999,999.999999")
					cTexto += " " + TransForm(aErros[nI,2] / aErros[nI,4] * 100, "@E 99,999.9") + "%" + cEof
				ElseIf aErros[nI, 3] == "ME"	//empenho menor que estrutura
					cTexto += aErros[nI, 1] + " - qtd empenhada menor que a estrutura, empenho = " + TransForm(aErros[nI, 2], "@E 999,999,999.999999")
					cTexto += " calculado = " +  TransForm(aErros[nI, 4], "@E 999,999,999.999999")
					cTexto += " " + TransForm(aErros[nI,4] / aErros[nI,2] * 100, "@E 99,999.9") + "%" + cEof
				ElseIf aErros[nI, 3] == "NE"	//tem na SD4 e não existe na estrutura
					cTexto += aErros[nI, 1] + " - item empenhado não existe na estrutura, empenho = " + TransForm(aErros[nI, 2], "@E 999,999,999.999999")
					cTexto += "    100,0%" + cEof
				ElseIf aErros[nI, 3] == "SE"	//tem na estrutura e nao exisite na SD4
					cTexto += aErros[nI, 1] + " - o item não foi empenhado, calculado = " + TransForm(aErros[nI, 4], "@E 999,999,999.999999")
					cTexto += "    100,0%" + cEof
				EndIf
			Next nI
			cFilLog := "LOG_OP_" + Rtrim(cNumOP) + "_" + Dtos(MsDate()) + StrTran(Time(), ":", "") + ".TXT"
			MemoWrite("\LOGOP\" + cFilLog, cTexto)
			CpyS2T("\LOGOP\" + cFilLog, "C:\WINDOWS\TEMP\")
			ShellExecute("OPEN", "C:\WINDOWS\TEMP\" + cFilLog, "", "", 1 )
		EndIf

	EndIf
	DbCloseArea(cAlias)
	DbCloseArea("TRB2")
	Ferase(Alltrim(cArqTrb) + ".DBF")
	Ferase(Alltrim(cArqTrb) + ".DTC")
	Ferase(Alltrim(cArqTrb) + ".CDX")
	Ferase(Alltrim(cIndTrb))
	Return(lRet)
