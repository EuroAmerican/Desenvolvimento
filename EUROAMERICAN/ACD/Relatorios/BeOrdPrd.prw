#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'Totvs.Ch'

User Function BeOrdPrd()

Private cQuery     := ""
Private cPerg      := Padr( "BEORDPR001", 10)
Private aOP        := {}
Private lRet       := .T.

ValidPerg()

If !Pergunte( cPerg, .T.)
	ApMsgAlert( 'Processamento cancelado!', 'Atenção')
	Return
EndIf

cQuery := "SELECT D3_FILIAL, " + CRLF
cQuery += "       D3_OP, " + CRLF
cQuery += "	      ISNULL(CASE WHEN H6_PT = 'P' THEN 'Parcial' ELSE 'Total' END, CASE WHEN D3_PARCTOT = 'P' THEN 'Parcial' ELSE 'Total' END) AS D3_PARCTOT, " + CRLF
cQuery += "	      ISNULL(CASE WHEN H6_TIPO = 'I' THEN 'Improdutivo' ELSE 'Produtivo' END, '') AS H6_TIPO, " + CRLF
cQuery += "	      CASE WHEN LEFT( D3_CF, 2) = 'PR' THEN 'Produção' ELSE " + CRLF
cQuery += "	      CASE WHEN LEFT( D3_CF, 2) = 'RE' AND D3_UM = 'HR' AND B1_TIPO = 'MO' AND LEFT( B1_COD, 2) = 'MO' THEN 'Mão de Obra' ELSE " + CRLF
cQuery += "	      CASE WHEN LEFT( D3_CF, 2) = 'RE' AND D3_UM = 'HR' AND B1_TIPO IN ('GG','MO') AND LEFT( B1_COD, 2) = 'GE' THEN 'Energia Elétrica' ELSE " + CRLF
cQuery += "	      CASE WHEN LEFT( D3_CF, 2) = 'RE' AND D3_UM = 'HR' AND B1_TIPO IN ('GG','MO') AND LEFT( B1_COD, 2) = 'GA' THEN 'Gás' ELSE " + CRLF
cQuery += "	      CASE WHEN LEFT( D3_CF, 2) = 'RE' AND D3_UM = 'HR' AND B1_TIPO IN ('GG','MO') AND LEFT( B1_COD, 2) = 'GG' THEN 'Gastos Gerais de Fabricação' ELSE " + CRLF
cQuery += "	      CASE WHEN LEFT( D3_CF, 2) = 'RE' AND D3_UM <> 'HR' THEN 'Requisição Direta' ELSE '' END END END END END END AS TIPO, " + CRLF
cQuery += "	      D3_CF, " + CRLF
cQuery += "	      D3_TM, " + CRLF
cQuery += "	      CONVERT(VARCHAR(10),CONVERT(DATETIME,C2_EMISSAO), 103) AS D3_EMISSAO, " + CRLF
cQuery += "	      CONVERT(VARCHAR(10),CONVERT(DATETIME,C2_DATPRI), 103) AS C2_DATPRI, " + CRLF
cQuery += "	      CONVERT(VARCHAR(10),CONVERT(DATETIME,C2_DATPRF), 103) AS C2_DATPRF, " + CRLF
cQuery += "       ISNULL(CONVERT(VARCHAR(10),CONVERT(DATETIME,H6_DATAINI), 103), '') AS H6_DATAINI, " + CRLF
cQuery += "       ISNULL(H6_HORAINI, '') AS H6_HORAINI, " + CRLF
cQuery += "       ISNULL(CONVERT(VARCHAR(10),CONVERT(DATETIME,H6_DATAFIN), 103), '') AS H6_DATAFIN, " + CRLF
cQuery += "       ISNULL(H6_HORAFIN, '') AS H6_HORAFIN, " + CRLF
cQuery += "       ISNULL(H6_TEMPO, '') AS H6_TEMPO, " + CRLF
cQuery += "       D3_COD, " + CRLF
cQuery += "       B1_DESC, " + CRLF
cQuery += "       B1_TIPO, " + CRLF
cQuery += "	      D3_LOCAL, " + CRLF
cQuery += "       B1_UM, " + CRLF
cQuery += "       B1_SEGUM, " + CRLF
cQuery += "       B1_CONV, " + CRLF
cQuery += "       CASE WHEN B1_TIPCONV = 'D' THEN 'Divisor' ELSE 'Multiplicador' END AS B1_TIPCONV, " + CRLF
cQuery += "       C2_QUANT, " + CRLF
cQuery += "       ISNULL(H6_QTDPROD, 0) AS H6_QTDPROD, " + CRLF
cQuery += "       ISNULL(H6_QTDPERD, 0) AS H6_QTDPERD, " + CRLF
cQuery += "       D3_QUANT AS D3_QUANT, " + CRLF
cQuery += "	      D3_CUSTO1, " + CRLF
cQuery += "	      D3_LOTECTL, " + CRLF
cQuery += "	      ISNULL((SELECT TOP 1 CONVERT(VARCHAR(10),CONVERT(DATETIME, B8_DFABRIC), 103) FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) WHERE B8_FILIAL = D3_FILIAL AND B8_PRODUTO = D3_COD AND B8_LOCAL = D3_LOCAL AND B8_LOTECTL = D3_LOTECTL AND B8_DFABRIC <> '' AND D_E_L_E_T_ = ' '), CASE WHEN D3_EMISSAO = '' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DATETIME, D3_EMISSAO), 103) END) AS D3_DTFABRI, " + CRLF
cQuery += "	      CONVERT(VARCHAR(10),CONVERT(DATETIME, D3_DTVALID), 103) AS D3_DTVALID, " + CRLF
cQuery += "	      D3_OBSERVA, " + CRLF
cQuery += "	      ISNULL(X5_DESCRI, '') AS X5_DESCRI, " + CRLF
cQuery += "       ISNULL(H6_OPERAC, '') AS H6_OPERAC, " + CRLF
cQuery += "       ISNULL(G2_DESCRI, '') AS G2_DESCRI, " + CRLF
cQuery += "       ISNULL(H6_RECURSO, '') AS H6_RECURSO, " + CRLF
cQuery += "       ISNULL(H1_DESCRI, '') AS H1_DESCRI, " + CRLF
cQuery += "       ISNULL(G2_LOTEPAD, '') AS G2_LOTEPAD, " + CRLF
cQuery += "       ISNULL(G2_TEMPAD, '') AS G2_TEMPAD, " + CRLF
cQuery += "	      ISNULL(G2_MAOOBRA, 0) AS G2_MAOOBRA " + CRLF
cQuery += "FROM " + RetSqlName("SD3") + " AS SD3 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '  ' " + CRLF
cQuery += "  AND B1_COD = D3_COD " + CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) ON C2_FILIAL = D3_FILIAL " + CRLF
cQuery += "  AND C2_NUM + C2_ITEM + C2_SEQUEN = D3_OP " + CRLF
cQuery += "  AND SC2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "LEFT JOIN " + RetSqlName("SH6") + " AS SH6 WITH (NOLOCK) ON H6_FILIAL = D3_FILIAL " + CRLF
cQuery += "  AND H6_OP = D3_OP " + CRLF
cQuery += "  AND H6_PRODUTO = D3_COD " + CRLF
cQuery += "  AND H6_LOCAL = D3_LOCAL " + CRLF
cQuery += "  AND H6_IDENT = D3_IDENT " + CRLF
cQuery += "  AND SH6.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "LEFT JOIN " + RetSqlName("SG2") + " AS SG2 WITH (NOLOCK) ON G2_FILIAL = '" + xFilial("SG2") + "' " + CRLF
cQuery += "  AND G2_PRODUTO = H6_PRODUTO " + CRLF
cQuery += "  AND G2_OPERAC = H6_OPERAC " + CRLF
cQuery += "  AND G2_CODIGO = B1_OPERPAD " + CRLF
cQuery += "  AND SG2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "LEFT JOIN " + RetSqlName("SH1") + " AS SH1 WITH (NOLOCK) ON H1_FILIAL = '" + xFilial("SH1") + "' " + CRLF
cQuery += "  AND H1_CODIGO = H6_RECURSO " + CRLF
cQuery += "  AND SH1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "LEFT JOIN " + RetSqlName("SX5") + " AS SX5 WITH (NOLOCK) ON X5_FILIAL = '' " + CRLF
cQuery += "  AND X5_TABELA = '44' " + CRLF
cQuery += "  AND X5_CHAVE = H6_MOTIVO " + CRLF
cQuery += "  AND SX5.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE D3_FILIAL BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' " + CRLF
cQuery += "AND D3_OP BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' " + CRLF
cQuery += "AND D3_EMISSAO BETWEEN '" + DTOS(mv_par05) + "' AND '" + DTOS(mv_par06) + "' " + CRLF
If mv_par07 <> 1
	cQuery += "AND D3_CUSTO1 <> 0 " + CRLF
EndIf
cQuery += "AND D3_ESTORNO = '' " + CRLF
cQuery += "AND SD3.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "ORDER BY D3_FILIAL, D3_OP, D3_CF, SD3.R_E_C_N_O_ " + CRLF

TCQuery cQuery New Alias "TMPEST"
dbSelectArea("TMPEST")
TMPEST->( dbGoTop() )

If TMPEST->( Eof() )
	ApMsgAlert( 'Não há dados para geração do relatório, verifique os parâmetros!', 'Atenção')
	Return
EndIf

Processa( {|| fGeraPla()}, "Gerando Relação de Ordens de Produções")

TMPEST->( dbCloseArea() )

Return

Static Function fGeraPla()

Local aCabec	:= {}
Local aColunas	:= {}
Local cMensagem	:= ""
Local cAssunto	:= ""
Local cMensagem := ""
Local cArquivo  := "c:\temp\Relacao_OP_" + DTOS( dDataBase ) + "_" + Replace( Time(), ":", "") + ".xls"
Local cAnexo1   := ""
Local nLin      := 0
Local nElemento := 0
Local nTotal    := 0

MakeDir( "C:\TEMP\" )

If File( cArquivo )
	fErase( cArquivo )
EndIf

ProcRegua( TMPEST->( RecCount() ) )

cAssunto := 'Relação de Ordens de Produções'

_nFile := MsFCreate( cArquivo )
	
cMensagem := ""
aCabec    := {}
aColunas  := {}
aAdd( aColunas, {'Filial'			   					, 05	, 'C'})
aAdd( aColunas, {'Ordem de Produção'					, 10	, 'C'})
aAdd( aColunas, {'Total / Parcial'						, 10	, 'C'})
aAdd( aColunas, {'Apontamento'							, 10	, 'C'})
aAdd( aColunas, {'Tipo'									, 10	, 'C'})
aAdd( aColunas, {'CF'									, 10	, 'C'})
aAdd( aColunas, {'TM'									, 10	, 'C'})
aAdd( aColunas, {'Emissão'								, 10	, 'C'})
aAdd( aColunas, {'Prev. Início'							, 10	, 'C'})
aAdd( aColunas, {'Prev. Final'							, 10	, 'C'})
aAdd( aColunas, {'Data Início'							, 10	, 'C'})
aAdd( aColunas, {'Hora Início'							, 10	, 'C'})
aAdd( aColunas, {'Data Final'							, 10	, 'C'})
aAdd( aColunas, {'Hora Final'							, 10	, 'C'})
aAdd( aColunas, {'Tempo'								, 10	, 'C'})
aAdd( aColunas, {'Produto'								, 10	, 'C'})
aAdd( aColunas, {'Descrição'							, 10	, 'C'})
aAdd( aColunas, {'Tipo Produto'							, 10	, 'C'})
aAdd( aColunas, {'Local'								, 10	, 'C'})
aAdd( aColunas, {'UM'									, 10	, 'C'})
aAdd( aColunas, {'Seg. UM'								, 10	, 'C'})
aAdd( aColunas, {'Fator'								, 10	, 'C'})
aAdd( aColunas, {'Tipo Conversão'						, 10	, 'C'})
aAdd( aColunas, {'Qtde. OP'								, 10	, 'C'})
aAdd( aColunas, {'Qtde. Apontada'						, 10	, 'C'})
aAdd( aColunas, {'Qtde. Perda'							, 10	, 'C'})
aAdd( aColunas, {'Qtde. Real'							, 10	, 'C'})
aAdd( aColunas, {'Custo Total'							, 10	, 'C'})
aAdd( aColunas, {'Lote'									, 10	, 'C'})
aAdd( aColunas, {'Data Fabricação'						, 10	, 'C'})
aAdd( aColunas, {'Data Vencimento'						, 10	, 'C'})
aAdd( aColunas, {'Observação'							, 10	, 'C'})
aAdd( aColunas, {'Motivo'								, 10	, 'C'})
aAdd( aColunas, {'Operação'								, 10	, 'C'})
aAdd( aColunas, {'Desc. Operação'						, 10	, 'C'})
aAdd( aColunas, {'Recurso'								, 10	, 'C'})
aAdd( aColunas, {'Nome Recurso'							, 10	, 'C'})
aAdd( aColunas, {'Lote Padrão'							, 10	, 'C'})
aAdd( aColunas, {'Tempo Padrão'							, 10	, 'C'})
aAdd( aColunas, {'Qtde. Mão de Obra'					, 10	, 'C'})

cMensagem += U_BeHtmHead( '',.T.,aCabec, aColunas )

FlushFile(_nFile, @cMensagem, 0)

Do While !TMPEST->( Eof() )
	IncProc( 'Filial: ' + TMPEST->D3_FILIAL + ' OP: ' + AllTrim( TMPEST->D3_OP ) + ' Produto: ' + AllTrim( TMPEST->D3_COD ) + ' Local: ' + TMPEST->D3_LOCAL )

	aColunas := {}
	aAdd( aColunas, {AllTrim( TMPEST->D3_FILIAL )				   									, 05	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->D3_OP )					  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->D3_PARCTOT )				  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->H6_TIPO )					  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->TIPO )					  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->D3_CF )					  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->D3_TM )					  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->D3_EMISSAO )				  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->C2_DATPRI )				  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->C2_DATPRF )				  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->H6_DATAINI )				  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->H6_HORAINI )				  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->H6_DATAFIN )				  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->H6_HORAFIN )				  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->H6_TEMPO )				  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->D3_COD )					  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->B1_DESC )					  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->B1_TIPO )					  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->D3_LOCAL )				  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->B1_UM )					  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->B1_SEGUM )				  		  							, 10	, 'L'})
	aAdd( aColunas, {Transform( TMPEST->B1_CONV, "@E 999,999,999.99" )								, 12	, 'R'})
	aAdd( aColunas, {AllTrim( TMPEST->B1_TIPCONV )				  		  							, 10	, 'L'})
	aAdd( aColunas, {Transform( TMPEST->C2_QUANT, "@E 999,999,999.99" )								, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->H6_QTDPROD, "@E 999,999,999.99" )							, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->H6_QTDPERD, "@E 999,999,999.99" )							, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->D3_QUANT, "@E 999,999,999.99" )								, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->D3_CUSTO1, "@E 999,999,999.99" )							, 12	, 'R'})
	aAdd( aColunas, {AllTrim( TMPEST->D3_LOTECTL )				  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->D3_DTFABRI )				  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->D3_DTVALID )				  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->D3_OBSERVA )				  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->X5_DESCRI )				  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->H6_OPERAC )				  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->G2_DESCRI )				  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->H6_RECURSO )				  		  							, 10	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->H1_DESCRI )				  		  							, 10	, 'L'})
	aAdd( aColunas, {Transform( TMPEST->G2_LOTEPAD, "@E 999,999,999.99" )							, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->G2_TEMPAD, "@E 999,999,999.99" )							, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->G2_MAOOBRA, "@E 999,999,999" )								, 12	, 'R'})

	If AllTrim( TMPEST->TIPO ) == "Produção"
		cMensagem += U_BeHtmDet( aColunas, ((nLin % 2) == 0) , .T. )
	Else
		cMensagem += U_BeHtmDet( aColunas, ((nLin % 2) == 0) , .F. )
	EndIf

	FlushFile(_nFile, @cMensagem, 0)

	nLin++

	TMPEST->( dbSkip() )
EndDo

/*
aColunas := {}
For nTotal := 1 To Len( aTotal )
	If nTotal <= 5
		aAdd( aColunas, {AllTrim( aTotal[nTotal] )				   									, 05	, 'L'})
	Else
		aAdd( aColunas, {Transform( aTotal[nTotal], "@E 999,999,999.99" )	  						, 12	, 'R'})
	EndIf
Next

cMensagem += U_BeHtmDet( aColunas, ((nLin % 2) == 0) , .T. )
*/

FlushFile(_nFile, @cMensagem, 0)

cMensagem += U_BeHtmRod(.T.)

FlushFile(_nFile, @cMensagem, 0)

FClose(_nFile)

ShellExecute( "open", AllTrim( cArquivo ), "", "C:\temp\", 1)

//cAnexo1 := cArquivo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia envio de e-mail...                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cMensagem := ""
//cMensagem += U_BeHtmRod(.T.)

//U_BeSendMail( { "fabio@xisinformatica.com.br", cAssunto, cMensagem, cAnexo1 } )

Return

Static Function FlushFile(_nFile, cMsg, nMaxSize)

Default nMaxSize := 50 * 1024 //50KB

FWrite(_nFile, cMsg)
cMsg := ""

Return Nil

Static Function ValidPerg()

Local _aArea := GetArea()
Local _aPerg := {}

aAdd(_aPerg, {cPerg, "01", "Da Filial             ?", "MV_CH1" , 	"C", 02	, 0	, "G"	, "MV_PAR01", "   "	,""         ,""         ,"","",""})
aAdd(_aPerg, {cPerg, "02", "Até Filial            ?", "MV_CH2" , 	"C", 02	, 0	, "G"	, "MV_PAR02", "   "	,""         ,""         ,"","",""})
aAdd(_aPerg, {cPerg, "03", "Da Ordem Produção     ?", "MV_CH3" , 	"C", 11	, 0	, "G"	, "MV_PAR03", "SC2"	,""         ,""         ,"","",""})
aAdd(_aPerg, {cPerg, "04", "Até Ordem Produção    ?", "MV_CH4" , 	"C", 11	, 0	, "G"	, "MV_PAR04", "SC2"	,""         ,""         ,"","",""})
aAdd(_aPerg, {cPerg, "05", "Da Data               ?", "MV_CH5" , 	"D", 08	, 0	, "G"	, "MV_PAR05", "   "	,""         ,""         ,"","",""})
aAdd(_aPerg, {cPerg, "06", "Até Data              ?", "MV_CH6" , 	"D", 08	, 0	, "G"	, "MV_PAR06", "   "	,""         ,""         ,"","",""})
aAdd(_aPerg, {cPerg, "07", "Considera Custo Zero  ?", "MV_CH7" , 	"N", 01	, 0	, "C"	, "MV_PAR07", "   "	,"Sim"      ,"Não"      ,"","",""})

DbSelectArea("SX1")
DbSetOrder(1)

For i := 1 To Len(_aPerg)
	IF  !DbSeek(_aPerg[i,1]+_aPerg[i,2])
		RecLock("SX1",.T.)
	Else
		RecLock("SX1",.F.)
	EndIF
	Replace X1_GRUPO   with _aPerg[i,01]
	Replace X1_ORDEM   with _aPerg[i,02]
	Replace X1_PERGUNT with _aPerg[i,03]
	Replace X1_VARIAVL with _aPerg[i,04]
	Replace X1_TIPO	   with _aPerg[i,05]
	Replace X1_TAMANHO with _aPerg[i,06]
	Replace X1_PRESEL  with _aPerg[i,07]
	Replace X1_GSC	   with _aPerg[i,08]
	Replace X1_VAR01   with _aPerg[i,09]
	Replace X1_F3	   with _aPerg[i,10]
	Replace X1_DEF01   with _aPerg[i,11]
	Replace X1_DEF02   with _aPerg[i,12]
	Replace X1_DEF03   with _aPerg[i,13]
	Replace X1_DEF04   with _aPerg[i,14]
	Replace X1_DEF05   with _aPerg[i,15]
	MsUnlock()
Next i

RestArea(_aArea)

Return(.T.)