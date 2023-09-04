#Include 'Rwmake.Ch'
#Include 'Protheus.Ch'
#Include 'Totvs.Ch'
#Include 'ApVT100.Ch'

User Function EQACDCOP()

Local cEtiq := Space(64)
Local aTela := VTSave()
Local nL    := VTRow()
Local nC    := VTCol()
Local aArea    := GetArea()
Local ckey03
Local bkey03

ckey03 := VTDescKey(03)
bkey03 := VTSetKey(03)

VtClearBuffer()
While .t.
	aHist := {}
	VTClear()
	If VtModelo()== "RF"
		@ 0,0  VTSay "Consulta"
		@ 1,0  VTSay "Etiqueta"
		@ 2,0  VTGet cEtiq pict '@!' VALID fConsOP(cEtiq)
	Else
		@ 0,0 VTSay "Consulta" //"Consulta"
		@ 1,0 VTGet cEtiq pict '@!' VALID fConsOP(cEtiq)
	EndIf
	VTRead
	If VTLastKey() == 27
		Exit
	EndIf
Enddo
VTRestore(,,,,aTela)
@ nL,nC VtSay ""

VTSetKey(03,bkey03,ckey03)

Return

Static Function fConsOP(cEtiqueta)

Local aSize     := {}
Local aCab      := {}
Local aEtiqueta := {}
Local aTela
Local cQuery   := ""
Local cWhere   := ""
Local cAlias   := ""

cQuery := "SELECT CASE WHEN C2_QUJE = C2_QUANT THEN 'OP ENCERRADA' ELSE "
cQuery += "       CASE WHEN NOT H6_OP IS NULL THEN 'OPERACAO CONCLUIDA' ELSE "
cQuery += "       CASE WHEN NOT INI.CBH_DTINI IS NULL THEN 'OPERACAO INICIADA' ELSE "
cQuery += "       CASE WHEN INI.CBH_DTINI IS NULL THEN 'NAO INICIADA' ELSE 'PENDENTE' END END END END AS STSOP, "
cQuery += "       G2_OPERAC, G2_DESCRI, "
cQuery += "	      ISNULL(INI.CBH_RECUR, ISNULL(H6_RECURSO, '')) AS RECURSO, "
cQuery += "	      ISNULL(INI.CBH_DTINI, ISNULL(H6_DATAINI, '')) AS DATAINI, "
cQuery += "	      ISNULL(INI.CBH_HRINI, ISNULL(H6_HORAINI, '  :  ')) AS HORAINI, "
cQuery += "	      ISNULL(FIM.CBH_DTFIM, ISNULL(H6_DATAFIN, '')) AS DATAFIM, "
cQuery += "	      ISNULL(FIM.CBH_HRFIM, ISNULL(H6_HORAFIN, '  :  ')) AS HORAFIM, "
cQuery += "	      C2_PRODUTO, C2_QUANT "
cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 "
cQuery += "INNER JOIN " + RetSqlName("SG2") + " AS SG2 ON G2_FILIAL = '" + xFilial("SG2") + "' "
cQuery += "  AND G2_CODIGO = C2_ROTEIRO "
cQuery += "  AND G2_PRODUTO = C2_PRODUTO "
cQuery += "  AND SG2.D_E_L_E_T_ = ' ' "
cQuery += "LEFT JOIN " + RetSqlName("CBH") + " AS INI ON INI.CBH_FILIAL = C2_FILIAL "
cQuery += "  AND INI.CBH_OP = C2_NUM + C2_ITEM + C2_SEQUEN "
cQuery += "  AND INI.CBH_OPERAC = G2_OPERAC "
cQuery += "  AND INI.CBH_TRANSA = '01' "
cQuery += "  AND INI.D_E_L_E_T_ = ' ' "
cQuery += "LEFT JOIN " + RetSqlName("CBH") + " AS FIM ON FIM.CBH_FILIAL = C2_FILIAL "
cQuery += "  AND FIM.CBH_OP = C2_NUM + C2_ITEM + C2_SEQUEN "
cQuery += "  AND FIM.CBH_OPERAC = G2_OPERAC "
cQuery += "  AND FIM.CBH_TRANSA = '04' "
cQuery += "  AND FIM.D_E_L_E_T_ = ' ' "
cQuery += "LEFT JOIN " + RetSqlName("SH6") + " AS SH6 ON H6_FILIAL = C2_FILIAL "
cQuery += "  AND H6_OP = C2_NUM + C2_ITEM + C2_SEQUEN "
cQuery += "  AND H6_OPERAC = G2_OPERAC "
cQuery += "  AND SH6.D_E_L_E_T_ = ' ' "
cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' "
cQuery += "AND C2_NUM + C2_ITEM + C2_SEQUEN = '" + AllTrim(cEtiqueta) + "' "
cQuery += "AND SC2.D_E_L_E_T_ = ' ' "

cQuery    := ChangeQuery(cQuery)
cAlias := GetNextAlias()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

aHist := {}

While !(cAlias)->(Eof())
	Aadd(aHist,{;
		(cAlias)->STSOP,;
		(cAlias)->G2_OPERAC,;
		(cAlias)->G2_DESCRI,;
		(cAlias)->RECURSO,;
		(cAlias)->DATAINI,;
		(cAlias)->HORAINI,;
		(cAlias)->DATAFIM,;
		(cAlias)->HORAFIM,;
		(cAlias)->C2_PRODUTO,;
		PadL(Alltrim(Transform((cAlias)->C2_QUANT,PesqPict("SC2","C2_QUANT"))),Tamsx3("C2_QUANT")[1]) })
	(cAlias)->(DbSkip())
EndDo
(cAlias)->(DbCloseArea())

If !Empty(aHist)
	aTela := VTSave()
	VTClear()
	aCab  := {"Status","Operacao","Descricao","Recurso","Dt Ini","Hr Ini","Dt Fin","Hr Fin","Produto","Quantidade"}
	aSize := {20      ,10        ,30         ,8        ,10      ,6       ,10      ,6       ,15       ,Tamsx3("C2_QUANT")[1]}

	If VTModelo()=="RF"
		@0,0 VTSay 'OP: ' + cEtiqueta
		VTaBrowse(1,0,VTMaxRow(),VtmaxCol(),aCab,aHist,aSize)
	Else
		VTaBrowse(0,0,VTMaxRow(),VtmaxCol(),aCab,aHist,aSize)
	EndIf
	vtRestore(,,,,aTela)
	VtClearBuffer()
Else
	VTBeep()
	VTAlert("OP nao encontrada","Aviso",.t.,4000) //'Endereco Vazio'###'Aviso'
EndIf
VTKeyBoard(chr(20))
Return .F.
