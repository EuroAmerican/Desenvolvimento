#include "protheus.ch"
#include "topconn.ch"
/*/{Protheus.doc} M460MARK
//O ponto de entrada M460MARK é utilizado para validar os pedidos marcados e está localizado no inicio da função a460Nota (endereça rotinas para a
//geração dos arquivos SD2/SF2).Será informado no terceiro parâmetro a série selecionada na geração da nota e o número da nota fiscal poderá ser verificado
//pela variável private cNumero.
@author Emerson Paiva
@since 30/01/2018
@version 1.0
@type function
/*/

#define ENTER		CHR(13) + CHR(10)
User Function M460MARK
	Local aArea   := GetArea()
	Local aAreaSC5:= SC5->(GetArea())
	Local aAreaSX5:= SX5->(GetArea())
	Local cQry    := ""
	Local lRet    := .T.
	Local cMarca  := ParamIxb[1]
	Local lInvert := ParamIxb[2]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faturamento Parcial                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	// Verifica a quantidade de itens (#)
	cQry := " SELECT C9_PEDIDO PEDIDO, " + ENTER
	cQry += "        SUM(C9_QTDLIB) REGSC9, " + ENTER
	cQry += "        (SELECT SUM(C6_QTDVEN) FROM " + RetSqlName("SC6") + " WHERE D_E_L_E_T_ = '' AND C6_FILIAL = '" + xFilial("SC6") + "' AND C6_FILIAL = C9_FILIAL AND C6_NUM = C9_PEDIDO AND C6_NOTA = '' ) REGSC6 " + ENTER
	cQry += " FROM " + RetSqlName("SC9") + ENTER
	cQry += " WHERE D_E_L_E_T_  = '' " + ENTER
	cQry += " 	AND C9_FILIAL = '" + xFilial("SC9") + "' " + ENTER
	cQry += " 	AND C9_OK = '" + cMarca + "' " + ENTER
	cQry += " 	AND C9_NFISCAL = ''	" + ENTER
	cQry += " GROUP BY C9_PEDIDO, " + ENTER
	cQry += "          C9_FILIAL " + ENTER

	MemoWrite("m460mark_1.sql", cQry)

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQry NEW ALIAS QRY

	While !QRY->(EOF())

		If QRY->REGSC9 != QRY->REGSC6

	        If !MsgYesNo("Pedido " + QRY->PEDIDO + " com faturamento parcial, prosseguir com faturamento?", "Faturamento Parcial")
    			Return .F.
    		EndIf

		EndIf

		QRY->(dbSkip())

	EndDo

	QRY->(dbCloseArea())


	// Verifica selecao de pedidos vinculados
	If lRet

		cQry := " SELECT " + ENTER
		cQry += " 		PEDIDO, " + ENTER
		cQry += " 		PEDVINC " + ENTER
		cQry += " FROM " + ENTER
		cQry += " 		( " + ENTER
		cQry += " 		SELECT " + ENTER
		cQry += " 				SC9A.C9_PEDIDO PEDIDO, " + ENTER
		cQry += " 				ISNULL(ISNULL(( " + ENTER
		cQry += " 							SELECT	ISNULL(MAX(C5_NUM), '') " + ENTER
		cQry += " 							FROM	" + RetSqlName("SC5") + ENTER
		cQry += " 							WHERE	D_E_L_E_T_ = '' " + ENTER
		cQry += " 							AND		C5_FILIAL = SC9A.C9_FILIAL " + ENTER
		cQry += " 							AND		C5_PEDVINC = SC9A.C9_PEDIDO	" + ENTER
		cQry += " 						), " + ENTER
		cQry += " 						( " + ENTER
		cQry += " 							SELECT	ISNULL(MAX(C5_PEDVINC), '') " + ENTER
		cQry += " 							FROM	" + RetSqlName("SC5") + ENTER
		cQry += " 							WHERE	D_E_L_E_T_ = '' " + ENTER
		cQry += " 							AND		C5_FILIAL = SC9A.C9_FILIAL " + ENTER
		cQry += " 							AND		C5_NUM = SC9A.C9_PEDIDO " + ENTER
		cQry += " 						)), '') PEDVINC " + ENTER
		cQry += " 		FROM " + ENTER
		cQry += " 				" + RetSqlName("SC9") + " SC9A " + ENTER
		cQry += " 		WHERE " + ENTER
		cQry += " 				SC9A.D_E_L_E_T_ = '' " + ENTER
		cQry += " 				AND SC9A.C9_FILIAL = '" + xFilial("SC9") + "' " + ENTER
		cQry += " 				AND SC9A.C9_NFISCAL = '' " + ENTER
		cQry += " 				AND SC9A.C9_OK = '" + cMarca + "' " + ENTER
		cQry += " 		) QRY " + ENTER
		cQry += " WHERE " + ENTER
		cQry += " 		PEDVINC != '' " + ENTER
		cQry += " 		AND (	SELECT	COUNT(1) " + ENTER
		cQry += " 				FROM 	" + RetSqlName("SC9") + " SC9B  " + ENTER
		cQry += " 				WHERE	SC9B.D_E_L_E_T_ = ''  " + ENTER
		cQry += " 				AND		SC9B.C9_FILIAL = '" + xFilial("SC9") + "' " + ENTER
		cQry += " 				AND 	SC9B.C9_NFISCAL = '' " + ENTER
		cQry += " 				AND		SC9B.C9_OK = '" + cMarca + "' " + ENTER
		cQry += " 				AND 	SC9B.C9_PEDIDO = PEDVINC ) = 0 " + ENTER

		MemoWrite("m460mark_3.sql", cQry)

		If Select("QRY") > 0
			QRY->(dbCloseArea())
		Endif

		TCQUERY cQry NEW ALIAS QRY

		While !QRY->(EOF())

			MsgStop("Pedidos " + QRY->PEDIDO + " e " + QRY->PEDVINC + " não podem ser faturados separadamente! ")
	   		lRet := .F.

			QRY->(dbSkip())
		EndDo

		QRY->(dbCloseArea())

	EndIf

	// Valida data de entrega e TES que nao movimenta estoque
	If lRet

		cQry := " SELECT DISTINCT C9_PEDIDO PEDIDO, " + ENTER //01/12/16 Emerson - Adicionado Distinct para não varrer todo arquivo
		//cQry += " 		 CONVERT(VARCHAR, CONVERT(DATETIME, C9_DATENT), 112) ENTREGA " + ENTER
		cQry += " 		 C9_DATENT ENTREGA " + ENTER
		cQry += " FROM	" + RetSqlName("SC9") + " " + ENTER
		cQry += " WHERE	D_E_L_E_T_ = '' AND C9_FILIAL = '" + xFilial("SC9") + "' " + ENTER
		cQry += "       AND C9_FILIAL = '" + xFilial("SC9") + "' AND C9_OK = '" + cMarca + "' " + ENTER
		cQry += "       AND C9_NFISCAL = '' " + ENTER

		MemoWrite("m460mark_4.sql", cQry)

		If Select("QRY") > 0
			QRY->(dbCloseArea())
		Endif

		TCQUERY cQry NEW ALIAS QRY

		While !QRY->(EOF())

			dbSelectArea("SC5")
			dbSetOrder(1)
			dbSeek(xFilial("SC5") + QRY->PEDIDO)

			// Verificacao de data de entrega
			//If AT( "004", AllTrim(SC5->C5_APROV) ) == 0

/*        //FABIO BATISTA 11/08/2020 COMENTADO PARA NÃO CHAMAR A VALIDAÇÃO DA DATA
		       	If cEmpAnt  $ "02"

					//If U_DiasUteis(dDataBase, StoD(QRY->ENTREGA)) > 2
					If DateWorkDay( DATE(), CTOD(QRY->ENTREGA) ) > 2
						MsgStop("Pedido com data de entrega fora da regra. (" + QRY->PEDIDO + " - " + DtoC(StoD(QRY->ENTREGA)) + "). Faturamento cancelado!")
			   			lRet := .F.
			   		EndIf

			   	ElseIf cEmpAnt + cFilAnt $ "0304#0801#0803"

					If DateWorkDay( DATE(), CTOD(QRY->ENTREGA) ) > 6
						MsgStop("Pedido com data de entrega fora da regra. (" + QRY->PEDIDO + " - " + DtoC(StoD(QRY->ENTREGA)) + "). Faturamento cancelado!")
			   			lRet := .F.
			   		EndIf

			   	EndIf

			//EndIf

			If dDataBase > StoD(QRY->ENTREGA)
				MsgStop("Pedido com data de entrega fora da regra. (" + QRY->PEDIDO + " - " + DtoC(StoD(QRY->ENTREGA)) + "). Faturamento cancelado!")
				lRet := .F.
            EndIf
*/
			// Verificacao de movimentacao de estoque
			cQry := " SELECT 	C6_NUM " + ENTER
			cQry += " FROM 		" + RetSqlName("SC6") + ENTER
			cQry += " WHERE 	D_E_L_E_T_ = '' " + ENTER
			cQry += " 			AND C6_NUM = '" + QRY->PEDIDO + "' " + ENTER
			cQry += " 			AND C6_FILIAL = '" + xFilial("SC6") + "'" + ENTER
			//cQry += " 			AND C6_U_OPER != '531'" + ENTER //OPERACAO DE CONTA E ORDEM DEVE SER DESCONSIDERADA
			cQry += " 			AND C6_PRODUTO != 'ME.0044' " + ENTER //CONTAINER DEVE SER DESCONSIDERADO
			cQry += "			AND NOT SUBSTRING(C6_PRODUTO, 1, NULLIF(CHARINDEX('.', C6_PRODUTO) - 1, -1)) IN ('0100') " + ENTER
			cQry += "			AND (SELECT B1_TIPO FROM " + RetSqlName("SB1") + " WHERE D_E_L_E_T_ = '' AND B1_COD = C6_PRODUTO) IN ('PA','PI','MP','ME') " + ENTER
			cQry += " 			AND (SELECT F4_ESTOQUE FROM " + RetSqlName("SF4") + " WHERE F4_FILIAL = '" + XFILIAL("SF4") + "' AND D_E_L_E_T_ = '' AND F4_CODIGO = C6_TES) = 'N' " + ENTER
			cQry += " 			AND C6_NOTA = '' " + ENTER
			//cQry += "			AND (SELECT ISNULL(UPPER(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),C5_APROV))), '') FROM " + RetSqlName("SC5") + " WHERE D_E_L_E_T_ = '' AND C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM) NOT LIKE '%ESTOQUE%' " + ENTER

			MemoWrite("m460mark_9.sql", cQry)

			If Select("QRY1") > 0
				QRY1->(dbCloseArea())
			EndIf

			TCQUERY cQry NEW ALIAS QRY1

			/*If	!QRY1->(EOF())
				MsgStop("Há itens no pedido que não movimentam estoque. (" + QRY->PEDIDO + " - " + QRY->ENTREGA + "). Faturamento cancelado!")
	   			lRet := .F.
				QRY1->(dbCloseArea())
				Exit
			EndIf*/

			If	!QRY1->(EOF())
				If !MsgYesNo("Há itens no pedido que não movimentam estoque. Pedido " + QRY->PEDIDO + ". Prosseguir com faturamento?", "Não movimenta estoque!")
	    			QRY1->(dbCloseArea())
	    			Return .F.
	    		EndIf
	    	EndIf

			QRY->(dbSkip())

		EndDo

		If Select("QRY") > 0
			QRY->(dbCloseArea())
		EndIf

		If Select("QRY1") > 0
			QRY1->(dbCloseArea())
		EndIf

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida TES que nao gera financeiro                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet

		cQry := " SELECT DISTINCT C9_PEDIDO PEDIDO, " + ENTER
		cQry += " 		 CONVERT(VARCHAR, CONVERT(DATETIME, C9_DATENT), 103) ENTREGA " + ENTER
		cQry += " FROM	" + RetSqlName("SC9") + " " + ENTER
		cQry += " WHERE	D_E_L_E_T_ = '' AND C9_FILIAL = '" + xFilial("SC9") + "' " + ENTER
		cQry += "       AND C9_FILIAL = '" + xFilial("SC9") + "' AND C9_OK = '" + cMarca + "' " + ENTER

		MemoWrite("m460mark_10.sql", cQry)

		If Select("QRY") > 0
			QRY->(dbCloseArea())
		Endif

		TCQUERY cQry NEW ALIAS QRY

		While !QRY->(EOF())

			cQry := " SELECT 	C6_NUM " + ENTER
			cQry += " FROM 		" + RetSqlName("SC6") + ENTER
			cQry += " WHERE 	D_E_L_E_T_ = '' " + ENTER
			cQry += " 			AND C6_NUM = '" + QRY->PEDIDO + "' " + ENTER
			cQry += " 			AND C6_FILIAL = '" + xFilial("SC6") + "' " + ENTER
			cQry += " 			AND C6_PRODUTO != 'ME.0044' " + ENTER
			cQry += " 			AND C6_QTDVEN > 5 " + ENTER
			cQry += "			AND NOT SUBSTRING(C6_PRODUTO, 1, NULLIF(CHARINDEX('.', C6_PRODUTO) - 1, -1)) IN ('0100') " + ENTER
			cQry += "			AND (SELECT B1_TIPO FROM " + RetSqlName("SB1") + " WHERE D_E_L_E_T_ = '' AND B1_COD = C6_PRODUTO) IN ('PA','PI','MP','ME') " + ENTER
			cQry += " 			AND (SELECT F4_DUPLIC FROM " + RetSqlName("SF4") + " WHERE F4_FILIAL = '" + XFILIAL("SF4") + "' AND D_E_L_E_T_ = '' AND F4_CODIGO = C6_TES) = 'N' " + ENTER
			//cQry += "			AND (SELECT ISNULL(UPPER(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),C5_APROV))), '') FROM " + RetSqlName("SC5") + " WHERE D_E_L_E_T_ = '' AND C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM) NOT LIKE '%FINANCEIRO%' " + ENTER
			//cQry += "			AND (SELECT ISNULL(UPPER(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),C5_APROV))), '') FROM " + RetSqlName("SC5") + " WHERE D_E_L_E_T_ = '' AND C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM) NOT LIKE '%BONIFICA%' " + ENTER

			MemoWrite("m460mark_11.sql", cQry)

			If Select("QRY1") > 0
				QRY1->(dbCloseArea())
			EndIf

			TCQUERY cQry NEW ALIAS QRY1

			/*If	!QRY1->(EOF())
				MsgStop("Há itens no pedido que não geram financeiro (" + QRY->PEDIDO + " - " + QRY->ENTREGA + "). Faturamento cancelado!")
	   			lRet := .F.
				QRY1->(dbCloseArea())
				Exit
			EndIf*/

			If	!QRY1->(EOF())
				If !MsgYesNo("Há itens no pedido que não geram financeiro. Pedido " + QRY->PEDIDO + ". Prosseguir com faturamento?", "Não gera financeiro!")
	    			QRY1->(dbCloseArea())
	    			Return .F.
	    		EndIf
	    	EndIf

			QRY->(dbSkip())

		EndDo

		If Select("QRY") > 0
			QRY->(dbCloseArea())
		EndIf

		If Select("QRY1") > 0
			QRY1->(dbCloseArea())
		EndIf

	EndIf
	RestArea(aAreaSC5)
	RestArea(aAreaSX5)
	RestArea(aArea)

    // 	If Alltrim(cEmpAnt) == "08"  //valida vlr.pedido/parcela - Grupo Empresa - Ajuste realizado (CG)

	If Left(cFilAnt,2) == "08"  //valida vlr.pedido/parcela
		SE4->(DbSetOrder(1))

		nVlrPar := SuperGetMV("ES_MFAT02C", .T., 300.00)   //valor minimo da parcela
		nVlrMin := SuperGetMV("ES_MFAT02D", .T., 1000.00)  //valor minimo do pedido
		cOper   := SuperGetMV("ES_MFAT02E", .T., "02|03|04")  //operacao que nao deve validar valor/parcela
		aCondPg := {}
		nI      := 0

		cQuery := "SELECT C9_PEDIDO, C5_XOPER, C5_CONDPAG, SUM(C9_QTDLIB * C9_PRCVEN) C9_TOTAL"
		cQuery += " FROM " + RetSqlName("SC9") + " SC9, " + RetSqlName("SC5") + " SC5"
		cQuery += " WHERE C9_FILIAL = '" + xFilial("SC9") + "'"
		cQuery += "   AND C9_BLEST = '  '"
		cQuery += "   AND C9_BLCRED = '  '"
		cQuery += "   AND C9_NFISCAL = '         '"
		cQuery += "   AND C9_OK = '" + cMarca + "'"
		cQuery += "   AND SC9.D_E_L_E_T_ = ''"
		cQuery += "   AND C5_FILIAL = '" + xFilial("SC5") + "'"
		cQuery += "   AND C5_NUM = C9_PEDIDO"
		cQuery += "   AND SC5.D_E_L_E_T_ = ''"
		cQuery += " GROUP BY C9_PEDIDO, C5_XOPER, C5_CONDPAG"
		cQuery += " ORDER BY C9_PEDIDO"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB1", .F., .F.)
		TRB1->(DbGoTop())
		While TRB1->(!Eof())
			If !TRB1->C5_XOPER $ cOper
				If TRB1->C9_TOTAL < nVlrMin
					aCondPg := Condicao(TRB1->C9_TOTAL, TRB1->C5_CONDPAG, 0, dDataBase)
					For nI := 1 To Len(aCondPg)
						If aCondPg[nI, 2] < nVlrPar
							lRet := .F.
							MsgStop("O valor da parcela do pedido " + TRB1->C9_PEDIDO + " esta abaixo do valor minimo. O PV nao sera faturado", "VLR.PARCELA")
						EndIf
					Next nI
				EndIf
			EndIf
			TRB1->(DbSkip())
		EndDo
		TRB1->(DbCloseArea())
		If !lRet
			MsgStop("O processo será cancelado, pedidos fora do padrao. Desmarque os pedidos para efetuar o faturamento.", "CANCELADO")
			Return(.F.)
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiministrador pode liberar mesmo com avisos emitidos               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lRet .And. UPPER(cUserName) $ ("Administrador")
		lRet := MsgYesNo("Administrador, deseja continuar com o processo de faturamento?", "M460MARK - ADMINISTRADOR")
	EndIf

	Return lRet
