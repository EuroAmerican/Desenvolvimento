
#include "rwmake.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#DEFINE ENTER Chr(13) + Chr(10)
/*
| Função...: QEPCM11()
| Autor....: Paulo Rogerio
| Data.....: 12/06/2023
| Retorno..: Nenhum
| Descricão: Calculo da Pontuação do Score.
|
| Observac.: 
| Objetivo.: 
| Documentação: 
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/

User Function QEPCM11()

	IF Aviso("Calculo do Score", "Deseja realmente recalcular o Score de todos os clientes e holdings?", {"Sim","Não"}) <> 1
        Return
    Endif

	Processa({|| fScoreCliente()}, "Calculando pontuação score para Clientes...")
	Processa({|| fScoreHolding()}, "Calculando pontuação score para Holdings...")

    MSGINFO( "Termino de processamento!!!"+ENTER+"Foram gerados arquivos de log (Score_*.log) na pasta system.", "Recalculo do Score" )
Return

Static Function fScoreCliente()
Local cQuery   := ""
Local nX       := 0
Local nScore   := 0
Local nQtdReg  := 0
Local aClientes:= {}

Local dDataIni := ctod("01/01/" + Alltrim(Str(Year(dDataBase) - 1, 4, 0)))
Local dDataFin := ctod("31/12/" + Alltrim(Str(Year(dDataBase) - 1, 4, 0)))
Local cFilLog  := "Score_"+dtos(dDataBase)+"_"+Strtran(time(), ":", "")+".Log" 
Local cTexto   := ""

Local cTime    := Time()

cQuery += "SELECT Filial, Cliente, Loja, SUM(QuantLitros) AS QuantLitros, SUM(Total) AS Total" + ENTER
cQuery += "FROM (" + ENTER

cQuery += "	SELECT  Filial," + ENTER
cQuery += "			Cliente, " + ENTER
cQuery += "			Loja, " + ENTER
cQuery += "			Produto, " + ENTER
cQuery += "			Quantidade," + ENTER
cQuery += "			Unidade," + ENTER
cQuery += "			Quantidade2," + ENTER
cQuery += "			Unidade2," + ENTER
cQuery += "			QuantLitros," + ENTER
cQuery += "			TipoProduto," + ENTER
cQuery += "			PrecoUnit," + ENTER
cQuery += "			ValorItem," + ENTER
cQuery += "			Total," + ENTER
cQuery += "			TipoDoc" + ENTER

cQuery += "	  FROM (" + ENTER

For nX := 1 to 2
    IF nX == 1
        cQuery += "  			--VENDA / COMPLEMENTO DE NF / BONIFICAÇÂO" + ENTER
    Else
        cQuery += "  			--INDUSTRIALIZAÇÃO" + ENTER
    Endif

    cQuery += "			SELECT  F2_FILIAL             AS Filial," + ENTER
    cQuery += "					F2_CLIENTE            AS Cliente, " + ENTER
    cQuery += "					F2_LOJA               AS Loja, " + ENTER
    cQuery += "					D2_COD                AS Produto, " + ENTER
    cQuery += "					ISNULL(D2_QUANT, 0)   AS Quantidade, " + ENTER
    cQuery += "					D2_UM                 AS Unidade," + ENTER
    cQuery += "					CASE WHEN D2_QTSEGUM > 0 THEN D2_QTSEGUM ELSE 0 END AS Quantidade2," + ENTER
    cQuery += "					D2_SEGUM              AS Unidade2," + ENTER

    cQuery += "					CASE WHEN D2_UM    = 'L'                                         THEN D2_QUANT " + ENTER
    cQuery += "						 WHEN D2_SEGUM = 'L'                                         THEN D2_QTSEGUM  " + ENTER
    cQuery += "						 -- NÃO HA LITROS NAS UNIDADES DA NF E TANTO A 1A. QUANTO A 2A. UNIDADE DO SB1 É DIFERENTE DE LITRO" + ENTER
    cQuery += "						 WHEN D2_UM <> 'L' AND D2_SEGUM <> 'L'  AND  B1_SEGUM  <> 'L' AND B1_UM   <>  'L'                                   THEN 0" + ENTER 

    cQuery += "						 -- NÃO HA LITROS NAS UNIDADES DA NF E TANTO A 1A. QUANTO A 2A. UNIDADE DO SB1 É LITRO" + ENTER
    cQuery += "						 WHEN D2_UM <> 'L' AND D2_SEGUM <> 'L'  AND  B1_SEGUM   = 'L' AND B1_UM   =  'L'                                     THEN D2_QUANT " + ENTER

    cQuery += "						 -- NÃO HA LITROS NAS UNIDADES DA NF E A 2A. DO SB1 É LITRO COM FATOR MULTIPLICADOR" + ENTER
    cQuery += "						 WHEN D2_UM <> 'L' AND D2_SEGUM <> 'L'  AND  B1_SEGUM   = 'L' AND B1_UM   <> 'L'AND B1_CONV > 0 AND B1_TIPCONV = 'M' THEN D2_QUANT * B1_CONV  " + ENTER

    cQuery += "						 -- NÃO HA LITROS NAS UNIDADES DA NF E A 2A. DO SB1 É LITRO COM FATOR DIVISOR" + ENTER
    cQuery += "						 WHEN D2_UM <> 'L' AND D2_SEGUM <> 'L'  AND  B1_SEGUM   = 'L' AND B1_UM   <> 'L'AND B1_CONV > 0 AND B1_TIPCONV = 'D' THEN D2_QUANT / B1_CONV  " + ENTER

    cQuery += "						 -- 1A. UNIDADE DA NF É LATA E A  2A. É DIFERENTE DE LATA. AS UNIDADES DO SB1 SÃO DIFERENTES DE  LITRO." + ENTER
    cQuery += "						 WHEN D2_UM = 'LT' AND D2_SEGUM NOT IN('LT', 'L')  AND  B1_SEGUM   <> 'L' AND B1_UM   <> 'L' THEN D2_QUANT * 18  " + ENTER

    cQuery += "						 -- 1A. UNIDADE É DIFERENTE DE LATA E A 2A. É LATA. AS UNIDADES DO SB1 SÃO DIFERENTES DE LITRO." + ENTER
    cQuery += "						 WHEN D2_UM NOT IN('LT', 'L')   AND D2_SEGUM = 'LT'  AND  B1_SEGUM   <> 'L' AND B1_UM   <> 'L' THEN D2_QTSEGUM * 18 " + ENTER
    cQuery += "						 ELSE 0 END       AS QuantLitros," + ENTER

    cQuery += "					B1_TIPO               AS TipoProduto," + ENTER
    cQuery += "					D2_PRCVEN             AS PrecoUnit," + ENTER
    cQuery += "					D2_TOTAL              AS ValorItem," + ENTER

    cQuery += "					-- NOVOS CAMPOS" + ENTER
    cQuery += "					ISNULL((SD2.D2_VALBRUT - SD2.D2_VALIPI - SD2.D2_ICMSRET), 0)    AS Total,  " + ENTER
    
    IF nX == 1
        cQuery += "					CASE WHEN F2_TIPO = 'N' AND F4_CF NOT IN('5910','6910') THEN 'VENDA'" + ENTER
        cQuery += "						 WHEN F2_TIPO IN('P','I','C') AND F4_DUPLIC = 'S'   THEN 'COMPLEMENTAR'" + ENTER
        cQuery += "						 WHEN F2_TIPO = 'N' AND F4_CF     IN('5910','6910') THEN 'BONIFICACAO'  " + ENTER
        cQuery += "						 ELSE 'INDEFINIDO'	END AS TipoDoc" + ENTER
    Else
        cQuery += "             'INDUSTRIALIZAÇÃO'	 AS TipoDoc" + ENTER
    Endif

    cQuery += "				FROM "+RetSqlName("SF2")+" AS SF2 WITH(NOLOCK)" + ENTER
    cQuery += "				INNER JOIN "+RetSqlName("SD2")+" AS SD2 WITH(NOLOCK) ON D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC     AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA  AND SD2.D_E_L_E_T_ = '' -- AND D2_QUANT > 0 AND D2_TOTAL > 0" + ENTER
    cQuery += "				INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH(NOLOCK) ON A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA  = F2_LOJA  AND A1_GRPVEN  = ''         AND A1_ZDSCSCO <> 'N'  AND SA1.D_E_L_E_T_ = ''" + ENTER
    
    IF nX == 1
        cQuery += "				INNER JOIN "+RetSqlName("SF4")+" AS SF4 WITH(NOLOCK) ON F4_FILIAL = LEFT(D2_FILIAL, 2) AND F4_CODIGO = D2_TES AND F4_DUPLIC = 'S' AND SUBSTRING(F4_CF, 2, 3) <> '124' AND SF4.D_E_L_E_T_ = '' -- RETIRA NOTA DE VENDA POR INDUSTRIALIZAÇÃO / BENEFICIAMENTO" + ENTER
    Else
		cQuery += "             INNER JOIN "+RetSqlName("SF4")+" AS SF4 WITH(NOLOCK) ON F4_FILIAL = LEFT(D2_FILIAL, 2) AND F4_CODIGO = D2_TES AND F4_DUPLIC = 'S' AND SUBSTRING(F4_CF, 2, 3) = '124' AND SF4.D_E_L_E_T_ = ''  -- INCLUI VENDA POR INDUSTRIALIZAÇÃO / BENEFICIAMENTO" + ENTER
    Endif

    cQuery += "				INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH(NOLOCK) ON B1_COD    =  D2_COD AND (B1_UM = 'L' OR B1_SEGUM = 'L') AND B1_TIPO IN('PA', 'PI') AND SB1.D_E_L_E_T_ = ''" + ENTER


	cQuery += "			WHERE SF2.D_E_L_E_T_ = '' " + ENTER
	cQuery += "			  AND F2_EMISSAO BETWEEN '"+dtos(dDataIni)+"' AND '"+dtos(dDataFin)+"'" + ENTER
	cQuery += "		      AND F2_TIPO  IN('N','B','P', 'I', 'C')" + ENTER
	cQuery += "			  AND F2_SERIE <> 'REQ'" + ENTER
	cQuery += "			  AND F2_FILIAL IN('0803','0901')" + ENTER + ENTER

	cQuery += "			UNION" + ENTER + ENTER
Next


cQuery += "			--DEVOLUÇÃO DE COMPRA" + ENTER
cQuery += "				SELECT F1_FILIAL             AS Filial," + ENTER
cQuery += "					   F1_FORNECE            AS Cliente, " + ENTER
cQuery += "					   F1_LOJA               AS Loja, " + ENTER
cQuery += "					   D1_COD                AS Produto, " + ENTER
cQuery += "					   (-1)*D1_QUANT         AS Quantidade, " + ENTER
cQuery += "					   D1_UM                 AS Unidade," + ENTER
cQuery += "					   (-1)*CASE WHEN D1_QTSEGUM > 0 THEN D1_QTSEGUM ELSE 0 END AS Quantidade2," + ENTER
cQuery += "					   D1_SEGUM                    AS Unidade2," + ENTER

cQuery += "					CASE WHEN D1_UM    = 'L'                                         THEN D1_QUANT " + ENTER
cQuery += "						 WHEN D1_SEGUM = 'L'                                         THEN D1_QTSEGUM  " + ENTER
cQuery += "						 -- NÃO HA LITROS NAS UNIDADES DA NF E TANTO A 1A. QUANTO A 2A. UNIDADE DO SB1 É DIFERENTE DE LITRO" + ENTER
cQuery += "						 WHEN D1_UM <> 'L' AND D1_SEGUM <> 'L'  AND  B1_SEGUM  <> 'L' AND B1_UM   <>  'L'                                    THEN 0" + ENTER

cQuery += "						 -- NÃO HA LITROS NAS UNIDADES DA NF E TANTO A 1A. QUANTO A 2A. UNIDADE DO SB1 É LITRO" + ENTER
cQuery += "						 WHEN D1_UM <> 'L' AND D1_SEGUM <> 'L'  AND  B1_SEGUM   = 'L' AND B1_UM   =  'L'                                     THEN D1_QUANT " + ENTER

cQuery += "						 -- NÃO HA LITROS NAS UNIDADES DA NF E A 2A. DO SB1 É LITRO COM FATOR MULTIPLICADOR" + ENTER
cQuery += "						 WHEN D1_UM <> 'L' AND D1_SEGUM <> 'L'  AND  B1_SEGUM   = 'L' AND B1_UM   <> 'L'AND B1_CONV > 0 AND B1_TIPCONV = 'M' THEN D1_QUANT * B1_CONV  " + ENTER

cQuery += "						 -- NÃO HA LITROS NAS UNIDADES DA NF E A 2A. DO SB1 É LITRO COM FATOR DIVISOR" + ENTER
cQuery += "						 WHEN D1_UM <> 'L' AND D1_SEGUM <> 'L'  AND  B1_SEGUM   = 'L' AND B1_UM   <> 'L'AND B1_CONV > 0 AND B1_TIPCONV = 'D' THEN D1_QUANT / B1_CONV  " + ENTER

cQuery += "						 -- 1A. UNIDADE DA NF É LATA E A  2A. É DIFERENTE DE LATA. AS UNIDADES DO SB1 SÃO DIFERENTES DE  LITRO." + ENTER
cQuery += "						 WHEN D1_UM = 'LT' AND D1_SEGUM NOT IN('LT', 'L')  AND  B1_SEGUM   <> 'L' AND B1_UM   <> 'L' THEN D1_QUANT * 18  " + ENTER

cQuery += "						 -- 1A. UNIDADE É DIFERENTE DE LATA E A 2A. É LATA. AS UNIDADES DO SB1 SÃO DIFERENTES DE LITRO." + ENTER
cQuery += "						 WHEN D1_UM NOT IN('LT', 'L')   AND D1_SEGUM = 'LT'  AND  B1_SEGUM   <> 'L' AND B1_UM   <> 'L' THEN D1_QTSEGUM * 18  " + ENTER
cQuery += "						 ELSE 0 END       AS QuantLitros," + ENTER

cQuery += "					   B1_TIPO                     AS TipoProduto," + ENTER
cQuery += "					   D1_VUNIT                    AS PrecoUnit," + ENTER
cQuery += "					   (-1)*(D1_QUANT * D1_VUNIT)  AS ValorItem," + ENTER

cQuery += "						-- NOVOS CAMPOS" + ENTER
cQuery += "					   (-1)*ISNULL((D1_TOTAL-D1_VALDESC-D1_VALIPI+D1_DESPESA+D1_VALFRE+D1_SEGURO-D1_ICMSRET-D1_VALICM-D1_VALIMP5-D1_VALIMP6),0) AS Total,  -- TOTAL MERCADORIA" + ENTER

cQuery += "					   CASE	WHEN F1_TIPO = 'D' THEN 'DEVOLUCAO'" + ENTER
cQuery += "							WHEN F1_TIPO = 'B' AND F1_FORMUL = 'S' THEN 'DEVOLUCAO' ELSE 'INDEFINIDO'	END AS TipoDoc" + ENTER


cQuery += "				  FROM "+RetSqlName("SF1")+" AS SF1 WITH(NOLOCK) "+ ENTER
cQuery += "				 INNER JOIN "+RetSqlName("SD1")+" AS SD1 WITH(NOLOCK) ON D1_FILIAL = F1_FILIAL AND D1_DOC = F1_DOC     AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA  AND SD1.D_E_L_E_T_ = '' --AND D1_QUANT > 0 AND D1_TOTAL > 0" + ENTER
cQuery += "				 INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH(NOLOCK) ON A1_FILIAL = F1_FILIAL AND A1_COD = F1_FORNECE AND A1_LOJA  = F1_LOJA  AND A1_GRPVEN  = ''   AND A1_ZDSCSCO <> 'N'  AND SA1.D_E_L_E_T_ = ''" + ENTER
cQuery += "				 INNER JOIN "+RetSqlName("SF4")+" AS SF4 WITH(NOLOCK) ON F4_FILIAL = LEFT(D1_FILIAL, 2) AND F4_CODIGO = D1_TES  AND SUBSTRING(F4_CF,2,3) IN('201','202','411','410') AND F4_DUPLIC = 'S' AND SF4.D_E_L_E_T_ = '' " + ENTER
cQuery += "				 INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH(NOLOCK) ON B1_COD    =  D1_COD  AND (B1_UM = 'L' OR B1_SEGUM = 'L') AND B1_TIPO IN('PA', 'PI') AND SB1.D_E_L_E_T_ = ''" + ENTER

cQuery += "				 WHERE SF1.D_E_L_E_T_ = '' " + ENTER
cQuery += "				   AND F1_DTDIGIT BETWEEN '"+dtos(dDataIni)+"' AND '"+dtos(dDataFin)+"'" + ENTER
cQuery += "				   AND F1_TIPO  IN('D','B')" + ENTER
cQuery += "				   AND F1_SERIE NOT IN('REQ')" + ENTER
cQuery += "				   AND F1_FILIAL IN('0803','0901')" + ENTER

cQuery += "		) QryAnalitica" + ENTER
cQuery += "	) QrySintetica" + ENTER
cQuery += "GROUP BY Filial, Cliente, Loja" + ENTER

IF Select("TMPX")
    TMPX->(dbCloseArea())
Endif

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMPX", .F., .T.)
dbSelectArea("TMPX")
Count to nQtdReg

nQtdReg := SA1->(Reccount())

dbGoTop()

// Grava o cabeçaçho do arquivo de log
cTexto := "DATA      HORARIO  USUARIO              CLIENTE/HOLDING                                          SCORE-D       SCORE-P"
//        99/99/9999 99:99:99 XXXXXXXXXXXXXXXXXXXX 999999/99-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99.999.999,99 99.999.999,99
xGravaLog(cTexto, cFilLog)
xGravaLog(Replicate("-", Len(cTexto)), cFilLog)

// Calcula e Grava a Pontuação Score
ProcRegua(nQtdReg)
Do while !Eof()
    dbSelectArea("SA1")
    dbSetOrder(1)
    dbSeek(TMPX->(Filial+Cliente+Loja))

    //IF "011929" $ TMPX->(Holding)
    //    xpto := 0
    //Endif

    IF Found()
        nScore := ((0.7 * TMPX->QuantLitros) + (0.30 * TMPX->Total)) / 2

        // Texto para gravação do Log
	    cTexto := Left(FWTimeStamp(2),10) + " "+ ;
        cTime + " " + ;
        Left(Alltrim(cUsername),20) + " "+ ;
        SA1->A1_COD +"/"+ SA1->A1_LOJA + "-" + LEFT(SA1->A1_NOME, 40) + " " + ;
        Padl(Transform(SA1->A1_ZSCORE, "@E 99,999,999.99"), 13) + " " + ;
        Padl(Transform(nScore        , "@E 99,999,999.99"), 13) 


        // Gravação do novo Score
        Reclock("SA1", .F.)
        SA1->A1_ZSCORE  := Round(nScore, 2)
        SA1->A1_ZDTSCOR := dDataBase
        SA1->A1_ZUSRSCO := Left(Alltrim(cUsername),20)
        MsUnlock()

        xGravaLog(cTexto, cFilLog)

        Aadd(aClientes, {TMPX->Filial, TMPX->Cliente, TMPX->Loja})
    Endif

    IncProc()

    dbSelectArea("TMPX")
    dbSkip()    
Enddo
dbCloseArea()

//------------------------------------------------
// Zeragem do Score para clientes que não tiveram
// movimentação de vendas no periodo
//------------------------------------------------
dbSelectArea("SA1")
dbSetOrder(1)
dbGoTop()

Do While !Eof()
    IF !A1_FILIAL $ "0803/0901"
        dbSkip()
        Loop
    Endif 

    IF Empty(SA1->A1_ZSCORE)
        dbSkip()
        Loop 
    Endif

    IncProc()

    IF ascan(aClientes, {|X| RTRIM(X[1]) == RTRIM(A1_FILIAL) .AND. X[2] == A1_COD .AND. X[3] == A1_LOJA}) >0
        dbSkip()
        Loop 
    Endif


    // Texto para gravação do Log
    cTexto := Left(FWTimeStamp(2),10) + " "+ ;
    cTime + " " + ;
    Left(Alltrim(cUsername),20) + " "+ ;
    SA1->A1_COD +"/"+ SA1->A1_LOJA + "-" + LEFT(SA1->A1_NOME, 40) + " " + ;
    Padl(Transform(SA1->A1_ZSCORE, "@E 99,999,999.99"), 13) + " " + ;
    Padl(Transform(0             , "@E 99,999,999.99"), 13) 


    // Zeragem do Score
    Reclock("SA1", .F.)
    SA1->A1_ZSCORE  := 0
    SA1->A1_ZDTSCOR := dDataBase
    SA1->A1_ZUSRSCO := Left(Alltrim(cUsername),20)
    MsUnlock()

    xGravaLog(cTexto, cFilLog)

    dbSkip()
Enddo

Return

Static Function fScoreHolding()
Local cQuery   := ""
Local nX       := 0
Local nScore   := 0
Local nQtdReg  := 0
Local aHoldings:= {}
Local dDataIni := ctod("01/01/" + Alltrim(Str(Year(dDataBase) - 1, 4, 0)))
Local dDataFin := ctod("31/12/" + Alltrim(Str(Year(dDataBase) - 1, 4, 0)))
Local cFilLog  := "Score_"+dtos(dDataBase)+"_"+Strtran(time(), ":", "")+".Log" 
Local cTexto   := ""
Local cTime    := Time()

cQuery += "SELECT Filial, Holding, SUM(QuantLitros) AS QuantLitros, SUM(Total) AS Total" + ENTER
cQuery += "FROM (" + ENTER

cQuery += "	SELECT  Filial," + ENTER
cQuery += "			Cliente, " + ENTER
cQuery += "			Loja, " + ENTER
cQuery += "			Produto, " + ENTER
cQuery += "			Quantidade," + ENTER
cQuery += "			Unidade," + ENTER
cQuery += "			Quantidade2," + ENTER
cQuery += "			Unidade2," + ENTER
cQuery += "			QuantLitros," + ENTER
cQuery += "			TipoProduto," + ENTER
cQuery += "			PrecoUnit," + ENTER
cQuery += "			ValorItem," + ENTER
cQuery += "			Total," + ENTER
cQuery += "			TipoDoc," + ENTER
cQuery += "			Holding" + ENTER

cQuery += "	  FROM (" + ENTER

For nX := 1 to 2
    IF nX == 1
        cQuery += "  			--VENDA / COMPLEMENTO DE NF / BONIFICAÇÂO" + ENTER
    Else
        cQuery += "  			--INDUSTRIALIZAÇÃO" + ENTER
    Endif

    cQuery += "			SELECT  F2_FILIAL             AS Filial," + ENTER
    cQuery += "					F2_CLIENTE            AS Cliente, " + ENTER
    cQuery += "					F2_LOJA               AS Loja, " + ENTER
    cQuery += "					A1_GRPVEN             AS Holding, " + ENTER
    cQuery += "					D2_COD                AS Produto, " + ENTER
    cQuery += "					ISNULL(D2_QUANT, 0)   AS Quantidade, " + ENTER
    cQuery += "					D2_UM                 AS Unidade," + ENTER
    cQuery += "					CASE WHEN D2_QTSEGUM > 0 THEN D2_QTSEGUM ELSE 0 END AS Quantidade2," + ENTER
    cQuery += "					D2_SEGUM              AS Unidade2," + ENTER

    cQuery += "					CASE WHEN D2_UM    = 'L'                                         THEN D2_QUANT " + ENTER
    cQuery += "						 WHEN D2_SEGUM = 'L'                                         THEN D2_QTSEGUM  " + ENTER
    cQuery += "						 -- NÃO HA LITROS NAS UNIDADES DA NF E TANTO A 1A. QUANTO A 2A. UNIDADE DO SB1 É DIFERENTE DE LITRO" + ENTER
    cQuery += "						 WHEN D2_UM <> 'L' AND D2_SEGUM <> 'L'  AND  B1_SEGUM  <> 'L' AND B1_UM   <>  'L'                                   THEN 0" + ENTER 

    cQuery += "						 -- NÃO HA LITROS NAS UNIDADES DA NF E TANTO A 1A. QUANTO A 2A. UNIDADE DO SB1 É LITRO" + ENTER
    cQuery += "						 WHEN D2_UM <> 'L' AND D2_SEGUM <> 'L'  AND  B1_SEGUM   = 'L' AND B1_UM   =  'L'                                     THEN D2_QUANT " + ENTER

    cQuery += "						 -- NÃO HA LITROS NAS UNIDADES DA NF E A 2A. DO SB1 É LITRO COM FATOR MULTIPLICADOR" + ENTER
    cQuery += "						 WHEN D2_UM <> 'L' AND D2_SEGUM <> 'L'  AND  B1_SEGUM   = 'L' AND B1_UM   <> 'L'AND B1_CONV > 0 AND B1_TIPCONV = 'M' THEN D2_QUANT * B1_CONV  " + ENTER

    cQuery += "						 -- NÃO HA LITROS NAS UNIDADES DA NF E A 2A. DO SB1 É LITRO COM FATOR DIVISOR" + ENTER
    cQuery += "						 WHEN D2_UM <> 'L' AND D2_SEGUM <> 'L'  AND  B1_SEGUM   = 'L' AND B1_UM   <> 'L'AND B1_CONV > 0 AND B1_TIPCONV = 'D' THEN D2_QUANT / B1_CONV  " + ENTER

    cQuery += "						 -- 1A. UNIDADE DA NF É LATA E A  2A. É DIFERENTE DE LATA. AS UNIDADES DO SB1 SÃO DIFERENTES DE  LITRO." + ENTER
    cQuery += "						 WHEN D2_UM = 'LT' AND D2_SEGUM NOT IN('LT', 'L')  AND  B1_SEGUM   <> 'L' AND B1_UM   <> 'L' THEN D2_QUANT * 18  " + ENTER

    cQuery += "						 -- 1A. UNIDADE É DIFERENTE DE LATA E A 2A. É LATA. AS UNIDADES DO SB1 SÃO DIFERENTES DE LITRO." + ENTER
    cQuery += "						 WHEN D2_UM NOT IN('LT', 'L')   AND D2_SEGUM = 'LT'  AND  B1_SEGUM   <> 'L' AND B1_UM   <> 'L' THEN D2_QTSEGUM * 18 " + ENTER
    cQuery += "						 ELSE 0 END       AS QuantLitros," + ENTER

    cQuery += "					B1_TIPO               AS TipoProduto," + ENTER
    cQuery += "					D2_PRCVEN             AS PrecoUnit," + ENTER
    cQuery += "					D2_TOTAL              AS ValorItem," + ENTER

    cQuery += "					ISNULL((SD2.D2_VALBRUT - SD2.D2_VALIPI - SD2.D2_ICMSRET), 0)                                                                                 AS Total,    -- TOTAL MERFADORIA" + ENTER
    
    IF nX == 1
        cQuery += "					CASE WHEN F2_TIPO = 'N' AND F4_CF NOT IN('5910','6910') THEN 'VENDA'" + ENTER
        cQuery += "						 WHEN F2_TIPO IN('P') AND F4_DUPLIC = 'S'   THEN 'COMPLEMENTAR'   -- 'C','I'," + ENTER
        cQuery += "						 WHEN F2_TIPO = 'N' AND F4_CF     IN('5910','6910') THEN 'BONIFICACAO'  " + ENTER
        cQuery += "						 ELSE 'INDEFINIDO'	END AS TipoDoc" + ENTER
    Else
        cQuery += "             'INDUSTRIALIZAÇÃO'	 AS TipoDoc" + ENTER
    Endif

    cQuery += "				FROM "+RetSqlName("SF2")+" AS SF2 WITH(NOLOCK)" + ENTER
    cQuery += "				INNER JOIN "+RetSqlName("SD2")+" AS SD2 WITH(NOLOCK) ON D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC     AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA  AND SD2.D_E_L_E_T_ = '' -- AND D2_QUANT > 0 AND D2_TOTAL > 0" + ENTER
    cQuery += "				INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH(NOLOCK) ON A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA  = F2_LOJA  AND SA1.D_E_L_E_T_ = ''" + ENTER  // AND A1_GRPVEN  <> ''         AND A1_ZDSCSCO <> 'N'
    cQuery += "				INNER JOIN "+RetSqlName("ACY")+" AS ACY WITH(NOLOCK) ON ACY_GRPVEN= A1_GRPVEN AND ACY.D_E_L_E_T_ = ''" + ENTER  // AND A1_GRPVEN  <> ''         AND A1_ZDSCSCO <> 'N'
    
    IF nX == 1
        cQuery += "				INNER JOIN "+RetSqlName("SF4")+" AS SF4 WITH(NOLOCK) ON F4_FILIAL = LEFT(D2_FILIAL, 2) AND F4_CODIGO = D2_TES AND F4_DUPLIC = 'S' AND SUBSTRING(F4_CF, 2, 3) <> '124' AND SF4.D_E_L_E_T_ = '' -- RETIRA NOTA DE VENDA POR INDUSTRIALIZAÇÃO / BENEFICIAMENTO" + ENTER
    Else
		cQuery += "             INNER JOIN "+RetSqlName("SF4")+" AS SF4 WITH(NOLOCK) ON F4_FILIAL = LEFT(D2_FILIAL, 2) AND F4_CODIGO = D2_TES AND F4_DUPLIC = 'S' AND SUBSTRING(F4_CF, 2, 3) = '124' AND SF4.D_E_L_E_T_ = ''  -- INCLUI VENDA POR INDUSTRIALIZAÇÃO / BENEFICIAMENTO" + ENTER
    Endif

    cQuery += "				INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH(NOLOCK) ON B1_COD    =  D2_COD AND (B1_UM = 'L' OR B1_SEGUM = 'L') AND B1_TIPO IN('PA', 'PI') AND SB1.D_E_L_E_T_ = ''" + ENTER


	cQuery += "			WHERE SF2.D_E_L_E_T_ = '' " + ENTER
	cQuery += "			  AND F2_EMISSAO BETWEEN '"+dtos(dDataIni)+"' AND '"+dtos(dDataFin)+"'" + ENTER
	cQuery += "		      AND F2_TIPO  IN('N','B','P', 'I')" + ENTER
	cQuery += "			  AND F2_SERIE <> 'REQ'" + ENTER
	cQuery += "			  AND F2_FILIAL IN('0803','0901')" + ENTER + ENTER

	cQuery += "			UNION" + ENTER + ENTER
Next


cQuery += "			--DEVOLUÇÃO DE COMPRA" + ENTER
cQuery += "				SELECT F1_FILIAL             AS Filial," + ENTER
cQuery += "					   F1_FORNECE            AS Cliente, " + ENTER
cQuery += "					   F1_LOJA               AS Loja, " + ENTER
cQuery += "					   A1_GRPVEN             AS Holding, " + ENTER
cQuery += "					   D1_COD                AS Produto, " + ENTER
cQuery += "					   (-1)*D1_QUANT         AS Quantidade, " + ENTER
cQuery += "					   D1_UM                 AS Unidade," + ENTER
cQuery += "					   (-1)*CASE WHEN D1_QTSEGUM > 0 THEN D1_QTSEGUM ELSE 0 END AS Quantidade2," + ENTER
cQuery += "					   D1_SEGUM                    AS Unidade2," + ENTER

cQuery += "					CASE WHEN D1_UM    = 'L'                                         THEN D1_QUANT " + ENTER
cQuery += "						 WHEN D1_SEGUM = 'L'                                         THEN D1_QTSEGUM  " + ENTER
cQuery += "						 -- NÃO HA LITROS NAS UNIDADES DA NF E TANTO A 1A. QUANTO A 2A. UNIDADE DO SB1 É DIFERENTE DE LITRO" + ENTER
cQuery += "						 WHEN D1_UM <> 'L' AND D1_SEGUM <> 'L'  AND  B1_SEGUM  <> 'L' AND B1_UM   <>  'L'                                    THEN 0" + ENTER

cQuery += "						 -- NÃO HA LITROS NAS UNIDADES DA NF E TANTO A 1A. QUANTO A 2A. UNIDADE DO SB1 É LITRO" + ENTER
cQuery += "						 WHEN D1_UM <> 'L' AND D1_SEGUM <> 'L'  AND  B1_SEGUM   = 'L' AND B1_UM   =  'L'                                     THEN D1_QUANT " + ENTER

cQuery += "						 -- NÃO HA LITROS NAS UNIDADES DA NF E A 2A. DO SB1 É LITRO COM FATOR MULTIPLICADOR" + ENTER
cQuery += "						 WHEN D1_UM <> 'L' AND D1_SEGUM <> 'L'  AND  B1_SEGUM   = 'L' AND B1_UM   <> 'L'AND B1_CONV > 0 AND B1_TIPCONV = 'M' THEN D1_QUANT * B1_CONV  " + ENTER

cQuery += "						 -- NÃO HA LITROS NAS UNIDADES DA NF E A 2A. DO SB1 É LITRO COM FATOR DIVISOR" + ENTER
cQuery += "						 WHEN D1_UM <> 'L' AND D1_SEGUM <> 'L'  AND  B1_SEGUM   = 'L' AND B1_UM   <> 'L'AND B1_CONV > 0 AND B1_TIPCONV = 'D' THEN D1_QUANT / B1_CONV  " + ENTER

cQuery += "						 -- 1A. UNIDADE DA NF É LATA E A  2A. É DIFERENTE DE LATA. AS UNIDADES DO SB1 SÃO DIFERENTES DE  LITRO." + ENTER
cQuery += "						 WHEN D1_UM = 'LT' AND D1_SEGUM NOT IN('LT', 'L')  AND  B1_SEGUM   <> 'L' AND B1_UM   <> 'L' THEN D1_QUANT * 18  " + ENTER

cQuery += "						 -- 1A. UNIDADE É DIFERENTE DE LATA E A 2A. É LATA. AS UNIDADES DO SB1 SÃO DIFERENTES DE LITRO." + ENTER
cQuery += "						 WHEN D1_UM NOT IN('LT', 'L')   AND D1_SEGUM = 'LT'  AND  B1_SEGUM   <> 'L' AND B1_UM   <> 'L' THEN D1_QTSEGUM * 18  " + ENTER
cQuery += "						 ELSE 0 END       AS QuantLitros," + ENTER

cQuery += "					   B1_TIPO                     AS TipoProduto," + ENTER
cQuery += "					   D1_VUNIT                    AS PrecoUnit," + ENTER
cQuery += "					   (-1)*(D1_QUANT * D1_VUNIT)  AS ValorItem," + ENTER

cQuery += "					   (-1) * ISNULL((D1_TOTAL-D1_VALDESC-D1_VALIPI+D1_DESPESA+D1_VALFRE+D1_SEGURO-D1_ICMSRET-D1_VALICM-D1_VALIMP5-D1_VALIMP6),0) AS Total,  -- TOTAL MERCADORIA" + ENTER

cQuery += "					   CASE	WHEN F1_TIPO = 'D' THEN 'DEVOLUCAO'" + ENTER
cQuery += "							WHEN F1_TIPO = 'B' AND F1_FORMUL = 'S' THEN 'DEVOLUCAO' ELSE 'INDEFINIDO'	END AS TipoDoc" + ENTER


cQuery += "				  FROM "+RetSqlName("SF1")+" AS SF1 WITH(NOLOCK) "+ ENTER
cQuery += "				 INNER JOIN "+RetSqlName("SD1")+" AS SD1 WITH(NOLOCK) ON D1_FILIAL = F1_FILIAL AND D1_DOC = F1_DOC     AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA  AND SD1.D_E_L_E_T_ = '' --AND D1_QUANT > 0 AND D1_TOTAL > 0" + ENTER
cQuery += "				 INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH(NOLOCK) ON A1_FILIAL = F1_FILIAL AND A1_COD = F1_FORNECE AND A1_LOJA  = F1_LOJA  AND SA1.D_E_L_E_T_ = ''" + ENTER
cQuery += "				 INNER JOIN "+RetSqlName("ACY")+" AS ACY WITH(NOLOCK) ON ACY_GRPVEN= A1_GRPVEN AND ACY.D_E_L_E_T_ = ''" + ENTER  

cQuery += "				 INNER JOIN "+RetSqlName("SF4")+" AS SF4 WITH(NOLOCK) ON F4_FILIAL = LEFT(D1_FILIAL, 2) AND F4_CODIGO = D1_TES  AND SUBSTRING(F4_CF,2,3) IN('201','202','411','410') AND F4_DUPLIC = 'S' AND SF4.D_E_L_E_T_ = '' " + ENTER
cQuery += "				 INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH(NOLOCK) ON B1_COD    =  D1_COD  AND (B1_UM = 'L' OR B1_SEGUM = 'L') AND B1_TIPO IN('PA', 'PI') AND SB1.D_E_L_E_T_ = ''" + ENTER

cQuery += "				 WHERE SF1.D_E_L_E_T_ = '' " + ENTER
cQuery += "				   AND F1_DTDIGIT BETWEEN '"+dtos(dDataIni)+"' AND '"+dtos(dDataFin)+"'" + ENTER
cQuery += "				   AND F1_TIPO  IN('D','B')" + ENTER
cQuery += "				   AND F1_SERIE NOT IN('REQ')" + ENTER
cQuery += "				   AND F1_FILIAL IN('0803','0901')" + ENTER

cQuery += "		) QryAnalitica" + ENTER
cQuery += "	) QrySintetica" + ENTER
cQuery += "GROUP BY Filial, Holding" + ENTER

IF Select("TMPX")
    TMPX->(dbCloseArea())
Endif

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMPX", .F., .T.)
dbSelectArea("TMPX")
Count to nQtdReg

nQtdReg *= 2

dbGoTop()

// Grava o cabeçaçho do arquivo de log
cTexto := "DATA      HORARIO  USUARIO              CLIENTE/HOLDING                                          SCORE-D       SCORE-P"
//        99/99/9999 99:99:99 XXXXXXXXXXXXXXXXXXXX 999999/99-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99.999.999,99 99.999.999,99
xGravaLog(cTexto, cFilLog)
xGravaLog(Replicate("-", Len(cTexto)), cFilLog)

// Calcula e Grava a Pontuação Score
ProcRegua(nQtdReg)
Do while !Eof()
    dbSelectArea("ACY")
    dbSetOrder(1)
    //dbSeek(Padr(TMPX->Filial, TamSX3("ACY_FILIAL")[1])+TMPX->(Holding))
    dbSeek(xFilial("ACY")+TMPX->(Holding))

    //IF "000019" $ TMPX->(Holding)
    //    xpto := 0
    //Endif

    IF Found()
        nScore := ((0.7 * TMPX->QuantLitros) + (0.30 * TMPX->Total)) / 2

        // Texto para gravação do Log
	    cTexto := Left(FWTimeStamp(2),10) + " "+ ;
        cTime + " " + ;
        Left(Alltrim(cUsername),20) + " "+ ;
        ACY->ACY_GRPVEN +"   -" + PADL(LEFT(ACY->ACY_DESCRI, 40), 40) + " " + ;
        Padl(Transform(ACY->ACY_ZSCORE, "@E 99,999,999.99"), 13) + " " + ;
        Padl(Transform(nScore         , "@E 99,999,999.99"), 13) 


        // Gravação do novo Score
        Reclock("ACY", .F.)
        ACY->ACY_ZSCORE  := Round(nScore, 2)
        ACY->ACY_ZDTSCO := dDataBase
        ACY->ACY_ZUSRSC := Left(Alltrim(cUsername),20)
        MsUnlock()

        Aadd(aHoldings, {TMPX->Filial, TMPX->Holding})

        xGravaLog(cTexto, cFilLog)
    Endif

    IncProc()

    dbSelectArea("TMPX")
    dbSkip()    
Enddo

dbCloseArea()

//------------------------------------------------
// Zeragem do Score para Holdings que não tiveram
// movimentação de vendas no periodo
//------------------------------------------------
dbSelectArea("ACY")
dbSetOrder(1)
dbGoTop()

Do While !Eof()
    IF ascan(aHoldings, {|X| X[2] == ACY_GRPVEN}) >0 // ascan(aHoldings, {|X| RTRIM(X[1]) == RTRIM(ACY_FILIAL) .AND. X[2] == ACY_GRPVEN})
        dbSkip()
        Loop 
    Endif

    IF Empty(ACY->ACY_ZSCORE)
        dbSkip()
        Loop 
    Endif

    // Texto para gravação do Log
    cTexto := Left(FWTimeStamp(2),10) + " "+ ;
    cTime + " " + ;
    Left(Alltrim(cUsername),20) + " "+ ;
    ACY->ACY_GRPVEN +"   -" + PADL(LEFT(ACY->ACY_DESCRI, 40), 40) + " " + ;
    Padl(Transform(ACY->ACY_ZSCORE, "@E 99,999,999.99"), 13) + " " + ;
    Padl(Transform(0              , "@E 99,999,999.99"), 13) 


    IncProc()

    // Zeragem do Score
    Reclock("ACY", .F.)
    ACY->ACY_ZSCORE := 0
    ACY->ACY_ZDTSCO := dDataBase
    ACY->ACY_ZUSRSC := Left(Alltrim(cUsername),20)
    MsUnlock()

    xGravaLog(cTexto, cFilLog)

    dbSkip()
Enddo


Return


/*
| Função...: xGravaLog()
| Autor....: Paulo Rogerio
| Data.....: 13/06/2023
| Retorno..: Nenhum
| Descricão: Gravação de Arquivo de Log.
|
| Observac.: 
| Objetivo.: 
| Documentação: 
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/

Static Function xGravaLog(_ctxt, _cArq)
local _cLogBody := ''

if _ctxt == NIL
	_ctxt := 'nulo'
endif

// Se o arquivo de log ainda nao existir, cria e grava cabecalho do log.
nHdl2:= FOPEN(_cArq,2)
IIF(nHdl2 > 0,,nHdl2:=MSFCREATE(_cArq,0))

Conout(_ctxt)
//nHdl2:= FOPEN(_cArq,2)

fseek(nHdl2,0,2)
_cLogBody += _cTxt + chr(13) + chr(10)

Fwrite(nHdl2,_cLogBody,len(_cLogBody))
FCLOSE(nHdl2)
Return
