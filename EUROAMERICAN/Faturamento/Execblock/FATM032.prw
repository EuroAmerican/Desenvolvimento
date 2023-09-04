#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"

#define ENTER chr(13) + chr(10)     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FATM032  บ Autor ณTiago Beraldi       บ Data ณ  17/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณGERA PEDIDO DOS CDS PARA FABRICA DE ACORDO COM DEMANDA DE   บฑฑ
ฑฑบ          ณVENDA                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFAT                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑบ12/01/18  บEmerson Paiva     บAdequa็ใo P12                            บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function FATM032  

If !Left(cFilAnt,2) $ "08"
	
	MsgAlert("Essa rotina deve ser executada somente atrav้s da Fแbrica e pelo usuแrio PEDIDO.JAYS!")
	Return

ElseIf AllTrim(Upper(cUserName)) $ "PEDIDO.JAYS"

	If Msgbox("Voc๊ esta prestes a gerar o Pedido. Confirma ?", " A T E N C A O", "YESNO")
		Processa({|lEnd| GeraPed()}, "Gerando Pedidos เ Fแbrica...")
	Endif

EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGERAPED   บ Autor ณTiago Beraldi       บ Data ณ  30/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณPROCESSAMENTO                                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFAT                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function GeraPed()

Local lCont    := .T. 
Local nDias    := 1          
Local aDados   := Iif(AllTrim(Upper(cUserName)) $ "PEDIDO.JAYS", {"032579", 18000, "07", "000424"}, {"032400", 32000, "08", "000425"})
Local cTabela  := "P_PEDIDOCD" + aDados[3]      
Local nPeso    := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//| Script SQL - Selecao de Nota Fiscal de Venda						|
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While lCont .And. nDias < 20

	If TcCanOpen(cTabela)  
		TcDelFile(cTabela)
	EndIf
	
	// ============================================================
	//  Grupo Empresa - Ajuste realizado em 31.08.20 (CG)
	// ============================================================

	/*
	cQry := " DECLARE @DIAS FLOAT = " + cValtoChar(nDias) + " " + ENTER 
	cQry += " SELECT " + ENTER
	cQry += " 		* " + ENTER
	cQry += " INTO " + ENTER
	cQry += " 		" + cTabela + " " + ENTER
	cQry += " FROM " + ENTER
	cQry += " 		( " + ENTER		
	cQry += " 		SELECT " + ENTER	 
	cQry += " 				PRODUTO, " + ENTER 
	cQry += " 				DESCRICAO, " + ENTER 
	cQry += " 				UM, " + ENTER 
	cQry += " 				(SELECT B1_TIPO FROM SB1000 WHERE D_E_L_E_T_ = '' AND B1_COD = PRODUTO) TIPO, " + ENTER
	cQry += " 				SUM(ISNULL(QTDVEN, 0)) QTDVEN, " + ENTER 
	cQry += " 				MAX(QTDEST) QTDEST, " + ENTER 
	cQry += " 				SUM(QTDRES) QTDRES, " + ENTER 
	cQry += " 				SUM(QTDTRT) QTDTRT, " + ENTER 
	cQry += " 				ROUND(MAX(QTD_DEMANDA_MES), 2) QTD_DEMANDA_MES, " + ENTER 
	cQry += " 				ROUND((MAX(QTDEST) + SUM(ISNULL(QTDVEN, 0)) + SUM(QTDTRT) - SUM(QTDRES))/CASE WHEN MAX(QTD_DEMANDA_MES) = 0 THEN 1 ELSE MAX(QTD_DEMANDA_MES) END * 30, 2) DIAS, " + ENTER 
	cQry += " 				ROUND((MAX(QTD_DEMANDA_MES) / 30) * 10, 2) ESTOQUE_MAXIMO, " + ENTER 
	cQry += " 				(SELECT B1_PESBRU FROM SB1000 WHERE D_E_L_E_T_ = '' AND B1_COD = PRODUTO) PESO_UNIT, " + ENTER 
	cQry += " 				CEILING(CASE WHEN ROUND((MAX(QTD_DEMANDA_MES) / 30) * @DIAS, 2) + SUM(QTDRES) - MAX(QTDEST) - SUM(QTDTRT) - SUM(ISNULL(QTDVEN, 0)) > 0 THEN ROUND((MAX(QTD_DEMANDA_MES) / 30) * @DIAS, 2) + SUM(QTDRES) - MAX(QTDEST) - SUM(QTDTRT) - SUM(ISNULL(QTDVEN, 0)) ELSE 0 END) NECESSIDADE, " + ENTER 
	cQry += " 				ISNULL((SELECT B2_QATU - B2_QEMP - B2_RESERVA FROM SB2080 WHERE D_E_L_E_T_ = '' AND B2_COD = PRODUTO AND B2_LOCAL = '08'), 0) EST_FABRICA " + ENTER 
	cQry += " 		FROM " + ENTER 
	cQry += " 				( " + ENTER 
	cQry += " 				SELECT " + ENTER 
	cQry += " 						RTRIM(B1_COD) PRODUTO, " + ENTER 
	cQry += " 						B1_DESC DESCRICAO, " + ENTER 
	cQry += " 						B1_UM UM, " + ENTER 
	cQry += " 						(SELECT SUM(C6_QTDVEN) FROM SC6020 WHERE D_E_L_E_T_ = '' AND C6_FILIAL = '00' AND C6_NOTA = '' AND C6_CLI = '" + aDados[1] + "' AND C6_PRODUTO = B1_COD) QTDVEN, " + ENTER 
	cQry += " 						ISNULL((SELECT SUM(B2_QATU) FROM SB2010 WHERE D_E_L_E_T_ = '' AND B2_COD = B1_COD AND B2_FILIAL = '" + aDados[3] + "'), 0) QTDEST, " + ENTER 
	cQry += " 						(SELECT ISNULL(SUM(D3_QUANT), 0) FROM SD3010 WHERE D_E_L_E_T_ = '' AND D3_ESTORNO = '' AND D3_FILIAL = '" + aDados[3] + "'	AND NOT D3_TM IN ('001','499','999','800','528','516','416','515','415','450') AND D3_EMISSAO >= '20100801' AND D3_COD = B1_COD) QTDRES, " + ENTER 
	cQry += " 						0 QTDTRT, " + ENTER 
	cQry += " 						ISNULL((SELECT SUM(D2_QUANT)/3 FROM SD2010 WHERE D_E_L_E_T_ = '' AND D2_TIPO = 'N' AND D2_COD = B1_COD AND D2_EMISSAO > CONVERT(VARCHAR, GETDATE() - 90, 112) AND D2_FILIAL = '" + aDados[3] + "'), 0) QTD_DEMANDA_MES " + ENTER 
	cQry += " 				FROM " + ENTER 
	cQry += " 						SB1000 " + ENTER 
	cQry += " 				WHERE " + ENTER 
	cQry += " 						D_E_L_E_T_ = '' " + ENTER 
	cQry += " 						AND EXISTS (SELECT B3_COD FROM SB3010 WHERE D_E_L_E_T_ = ''AND B3_COD = B1_COD) " + ENTER 
	cQry += " 				UNION ALL " + ENTER 
	cQry += " 				SELECT " + ENTER	 
	cQry += " 						RTRIM(C6_PRODUTO) PRODUTO, " + ENTER 
	cQry += " 						B1_DESC DESCRICAO, " + ENTER 
	cQry += " 						C6_UM UM, " + ENTER 
	cQry += " 						0 QTDVEN, " + ENTER 
	cQry += " 						0 QTDEST, " + ENTER 
	cQry += " 						C6_QTDVEN QTDRES, " + ENTER 
	cQry += " 						0 QTDTRT, " + ENTER 
	cQry += " 						0 QTD_DEMANDA_MES " + ENTER 
	cQry += " 				FROM " + ENTER 
	cQry += " 						SC6010 SC6, SB1000 SB1" + ENTER 
	cQry += " 				WHERE " + ENTER 
	cQry += " 						SC6.D_E_L_E_T_ = '' " + ENTER 
	cQry += " 						AND SB1.D_E_L_E_T_ = '' " + ENTER 
	cQry += " 						AND B1_COD = C6_PRODUTO " + ENTER 
	cQry += " 						AND C6_FILIAL = '" + aDados[3] + "' " + ENTER 
	cQry += " 						AND C6_NOTA = '' " + ENTER 
	cQry += " 				UNION ALL " + ENTER 
	cQry += " 				SELECT " + ENTER 
	cQry += " 						RTRIM(PRODUTO_) PRODUTO, " + ENTER 
	cQry += " 						MAX(B1_DESC) DESCRICAO, " + ENTER 
	cQry += " 						MAX(B1_UM) UM, " + ENTER 
	cQry += " 						0 QTDVEN, " + ENTER 
	cQry += " 						0 QTDEST, " + ENTER 
	cQry += " 						0 QTDRES, " + ENTER 
	cQry += " 						SUM(QTDSAIDA) - SUM(QTDENTRADA) QTDTRT, " + ENTER 
	cQry += " 						0 QTD_DEMANDA_MES " + ENTER 
	cQry += " 				FROM " + ENTER 
	cQry += " 					( " + ENTER 
	cQry += " 					SELECT " + ENTER 
	cQry += " 							D2_SERIE + D2_DOC  DOCUMENTO, " + ENTER 
	cQry += " 							D2_COD PRODUTO_, " + ENTER 
	cQry += " 							D2_QUANT - ISNULL((SELECT SUM(D1_QUANT) FROM SD1080 WHERE D_E_L_E_T_ = '' AND D1_FILIAL = D2_FILIAL AND D1_COD = D2_COD AND D1_NFORI = D2_DOC AND D1_SERIORI = D2_SERIE AND D1_ITEMORI = D2_ITEM AND D1_FORNECE = '" + aDados[1] + "'), 0)  QTDSAIDA, " + ENTER 
	cQry += " 							0 QTDENTRADA " + ENTER 
	cQry += " 					FROM " + ENTER 
	cQry += " 							SD2080 " + ENTER 
	cQry += " 					WHERE " + ENTER 
	cQry += " 							D_E_L_E_T_ = '' " + ENTER          
	cQry += " 							AND D2_FILIAL BETWEEN '  ' AND 'ZZ' " + ENTER
	cQry += " 							AND D2_CLIENTE = '" + aDados[1] + "' " + ENTER 
	cQry += " 							AND D2_EMISSAO >= CONVERT(VARCHAR, GETDATE() - 90, 112) " + ENTER 
	cQry += " 					UNION ALL " + ENTER 
	cQry += " 					SELECT " + ENTER 
	cQry += " 							D1_SERIE + D1_DOC DOCUMENTO, " + ENTER 
	cQry += " 							D1_COD PRODUTO, " + ENTER 
	cQry += " 							0 QTDSAIDA, " + ENTER 
	cQry += " 							D1_QUANT - ISNULL((SELECT SUM(D2_QUANT) FROM SD2010 WHERE D_E_L_E_T_ = '' AND D1_FILIAL = D2_FILIAL AND D1_COD = D2_COD AND D2_NFORI = D1_DOC AND D2_SERIORI = D1_SERIE AND D2_ITEMORI = D1_ITEM AND D2_CLIENTE = '000641' ), 0) QTDENTRADA " + ENTER 
	cQry += " 					FROM " + ENTER 
	cQry += " 							SD1010 " + ENTER 
	cQry += " 					WHERE " + ENTER 
	cQry += " 							D_E_L_E_T_ = '' " + ENTER   
	cQry += " 							AND D1_FILIAL = '" + xFilial("SD1") + "' " + ENTER
	cQry += " 							AND D1_SERIE + D1_DOC IN  (SELECT F2_SERIE + F2_DOC FROM SF2080 WHERE D_E_L_E_T_ = '' AND F2_CLIENTE = '" + aDados[1] + "' AND F2_EMISSAO >= CONVERT(VARCHAR, GETDATE() - 90, 112)) " + ENTER 
	cQry += " 					) QRY, SB1000 SB1 " + ENTER 
	cQry += " 				WHERE " + ENTER 
	cQry += " 						SB1.D_E_L_E_T_ = '' " + ENTER 
	cQry += " 						AND B1_COD = PRODUTO_ " + ENTER 
	cQry += " 				GROUP BY " + ENTER 
	cQry += " 						PRODUTO_ " + ENTER 
	cQry += " 				HAVING " + ENTER 
	cQry += " 						SUM(QTDSAIDA) != SUM(QTDENTRADA) " + ENTER 
	cQry += " 				) QRY " + ENTER 
	cQry += " 		GROUP BY " + ENTER 
	cQry += " 				PRODUTO, " + ENTER 
	cQry += " 				DESCRICAO, " + ENTER 
	cQry += " 				UM " + ENTER
	cQry += " 		HAVING " + ENTER  
	cQry += " 				( SUM(QTDVEN) != 0 OR " + ENTER 
	cQry += " 				SUM(QTDEST) != 0 OR " + ENTER 
	cQry += " 				SUM(QTDRES) != 0 OR " + ENTER 
	cQry += " 				SUM(QTDTRT) != 0 OR " + ENTER 
	cQry += " 				SUM(QTD_DEMANDA_MES) != 0 ) " + ENTER 
	cQry += " 		) QRY " + ENTER
	cQry += " WHERE " + ENTER
	cQry += " 		NECESSIDADE != 0 " + ENTER	
	cQry += " 		AND TIPO = 'PA' " + ENTER	
	cQry += " ORDER BY " + ENTER
	cQry += " 		PRODUTO " + ENTER	 

    */

	cQry := " DECLARE @DIAS FLOAT = " + cValtoChar(nDias) + " " + ENTER 
	cQry += " SELECT " + ENTER
	cQry += " 		* " + ENTER
	cQry += " INTO " + ENTER
	cQry += " 		" + cTabela + " " + ENTER
	cQry += " FROM " + ENTER
	cQry += " 		( " + ENTER		
	cQry += " 		SELECT " + ENTER	 
	cQry += " 				PRODUTO, " + ENTER 
	cQry += " 				DESCRICAO, " + ENTER 
	cQry += " 				UM, " + ENTER 
	cQry += " 				(SELECT B1_TIPO FROM " + RetSqlName("SB1") + " WITH (NOLOCK) WHERE D_E_L_E_T_ = '' AND B1_COD = PRODUTO) TIPO, " + ENTER
	cQry += " 				SUM(ISNULL(QTDVEN, 0)) QTDVEN, " + ENTER 
	cQry += " 				MAX(QTDEST) QTDEST, " + ENTER 
	cQry += " 				SUM(QTDRES) QTDRES, " + ENTER 
	cQry += " 				SUM(QTDTRT) QTDTRT, " + ENTER 
	cQry += " 				ROUND(MAX(QTD_DEMANDA_MES), 2) QTD_DEMANDA_MES, " + ENTER 
	cQry += " 				ROUND((MAX(QTDEST) + SUM(ISNULL(QTDVEN, 0)) + SUM(QTDTRT) - SUM(QTDRES))/CASE WHEN MAX(QTD_DEMANDA_MES) = 0 THEN 1 ELSE MAX(QTD_DEMANDA_MES) END * 30, 2) DIAS, " + ENTER 
	cQry += " 				ROUND((MAX(QTD_DEMANDA_MES) / 30) * 10, 2) ESTOQUE_MAXIMO, " + ENTER 
	cQry += " 				(SELECT B1_PESBRU FROM " + RetSqlName("SB1") + " WITH (NOLOCK) WHERE D_E_L_E_T_ = '' AND B1_COD = PRODUTO) PESO_UNIT, " + ENTER 
	cQry += " 				CEILING(CASE WHEN ROUND((MAX(QTD_DEMANDA_MES) / 30) * @DIAS, 2) + SUM(QTDRES) - MAX(QTDEST) - SUM(QTDTRT) - SUM(ISNULL(QTDVEN, 0)) > 0 THEN ROUND((MAX(QTD_DEMANDA_MES) / 30) * @DIAS, 2) + SUM(QTDRES) - MAX(QTDEST) - SUM(QTDTRT) - SUM(ISNULL(QTDVEN, 0)) ELSE 0 END) NECESSIDADE, " + ENTER 
	cQry += " 				ISNULL((SELECT B2_QATU - B2_QEMP - B2_RESERVA FROM " + RetSqlName("SB2") + " WITH (NOLOCK) WHERE D_E_L_E_T_ = '' AND B2_COD = PRODUTO AND B2_LOCAL = '08'), 0) EST_FABRICA " + ENTER 
	cQry += " 		FROM " + ENTER 
	cQry += " 				( " + ENTER 
	cQry += " 				SELECT " + ENTER 
	cQry += " 						RTRIM(B1_COD) PRODUTO, " + ENTER 
	cQry += " 						B1_DESC DESCRICAO, " + ENTER 
	cQry += " 						B1_UM UM, " + ENTER 
	cQry += " 						(SELECT SUM(C6_QTDVEN) FROM " + RetSqlName("SC6") = " WITH (NOLOCK) WHERE D_E_L_E_T_ = '' AND C6_NOTA = '' AND C6_CLI = '" + aDados[1] + "' AND C6_PRODUTO = B1_COD) QTDVEN, " + ENTER 
	cQry += " 						ISNULL((SELECT SUM(B2_QATU) FROM " + RetSqlName("SB2") + " WITH (NOLOCK) WHERE D_E_L_E_T_ = '' AND B2_COD = B1_COD AND B2_FILIAL = '" + aDados[3] + "'), 0) QTDEST, " + ENTER 
	cQry += " 						(SELECT ISNULL(SUM(D3_QUANT), 0) FROM " + RetSqlName("SD3") + " WITH (NOLOCK) WHERE D_E_L_E_T_ = '' AND D3_ESTORNO = '' AND D3_FILIAL = '" + aDados[3] + "'	AND NOT D3_TM IN ('001','499','999','800','528','516','416','515','415','450') AND D3_EMISSAO >= '20100801' AND D3_COD = B1_COD) QTDRES, " + ENTER 
	cQry += " 						0 QTDTRT, " + ENTER 
	cQry += " 						ISNULL((SELECT SUM(D2_QUANT)/3 FROM " + RetSqlName("SD2") + " WITH (NOLOCK) WHERE D_E_L_E_T_ = '' AND D2_TIPO = 'N' AND D2_COD = B1_COD AND D2_EMISSAO > CONVERT(VARCHAR, GETDATE() - 90, 112) AND D2_FILIAL = '" + aDados[3] + "'), 0) QTD_DEMANDA_MES " + ENTER 
	cQry += " 				FROM " + RetSqlName("SB1") + " WHERE D_E_L_E_T_ = '' " + ENTER 
	cQry += " 						AND EXISTS (SELECT B3_COD FROM " + RetSqlName("SB3") + " WITH (NOLOCK) WHERE D_E_L_E_T_ = ''AND B3_COD = B1_COD) " + ENTER 
	cQry += " 				UNION ALL " + ENTER 
	cQry += " 				SELECT " + ENTER	 
	cQry += " 						RTRIM(C6_PRODUTO) PRODUTO, " + ENTER 
	cQry += " 						B1_DESC DESCRICAO, " + ENTER 
	cQry += " 						C6_UM UM, " + ENTER 
	cQry += " 						0 QTDVEN, " + ENTER 
	cQry += " 						0 QTDEST, " + ENTER 
	cQry += " 						C6_QTDVEN QTDRES, " + ENTER 
	cQry += " 						0 QTDTRT, " + ENTER 
	cQry += " 						0 QTD_DEMANDA_MES " + ENTER 
	cQry += " 				FROM " + RetSqlName("SC6") + " AS SC6, " + RetSqlName("SB1") + " AS SB1" + ENTER 
	cQry += " 				WHERE " + ENTER 
	cQry += " 						SC6.D_E_L_E_T_ = '' " + ENTER 
	cQry += " 						AND SB1.D_E_L_E_T_ = '' " + ENTER 
	cQry += " 						AND B1_COD = C6_PRODUTO " + ENTER 
	cQry += " 						AND C6_FILIAL = '" + aDados[3] + "' " + ENTER 
	cQry += " 						AND C6_NOTA = '' " + ENTER 
	cQry += " 				UNION ALL " + ENTER 
	cQry += " 				SELECT " + ENTER 
	cQry += " 						RTRIM(PRODUTO_) PRODUTO, " + ENTER 
	cQry += " 						MAX(B1_DESC) DESCRICAO, " + ENTER 
	cQry += " 						MAX(B1_UM) UM, " + ENTER 
	cQry += " 						0 QTDVEN, " + ENTER 
	cQry += " 						0 QTDEST, " + ENTER 
	cQry += " 						0 QTDRES, " + ENTER 
	cQry += " 						SUM(QTDSAIDA) - SUM(QTDENTRADA) QTDTRT, " + ENTER 
	cQry += " 						0 QTD_DEMANDA_MES " + ENTER 
	cQry += " 				FROM " + ENTER 
	cQry += " 					( " + ENTER 
	cQry += " 					SELECT " + ENTER 
	cQry += " 							D2_SERIE + D2_DOC  DOCUMENTO, " + ENTER 
	cQry += " 							D2_COD PRODUTO_, " + ENTER 
	cQry += " 							D2_QUANT - ISNULL((SELECT SUM(D1_QUANT) FROM " + RetSqlName("SD1") + " WITH (NOLOCK) WHERE D_E_L_E_T_ = '' AND D1_FILIAL = D2_FILIAL AND D1_COD = D2_COD AND D1_NFORI = D2_DOC AND D1_SERIORI = D2_SERIE AND D1_ITEMORI = D2_ITEM AND D1_FORNECE = '" + aDados[1] + "'), 0)  QTDSAIDA, " + ENTER 
	cQry += " 							0 QTDENTRADA " + ENTER 
	cQry += " 					FROM " + RetSqlName("SD2") +" + WHERE D_E_L_E_T_ = '' " + ENTER          
	cQry += " 							AND LEFT(D2_FILIAL,2) = '" + Left(xFilial("SD2"),2) + "'" + ENTER
	cQry += " 							AND D2_CLIENTE = '" + aDados[1] + "' " + ENTER 
	cQry += " 							AND D2_EMISSAO >= CONVERT(VARCHAR, GETDATE() - 90, 112) " + ENTER 
	cQry += " 					UNION ALL " + ENTER 
	cQry += " 					SELECT " + ENTER 
	cQry += " 							D1_SERIE + D1_DOC DOCUMENTO, " + ENTER 
	cQry += " 							D1_COD PRODUTO, " + ENTER 
	cQry += " 							0 QTDSAIDA, " + ENTER 
	cQry += " 							D1_QUANT - ISNULL((SELECT SUM(D2_QUANT) FROM " + RetSqlName("SD2") + " WHERE D_E_L_E_T_ = '' AND D1_FILIAL = D2_FILIAL AND D1_COD = D2_COD AND D2_NFORI = D1_DOC AND D2_SERIORI = D1_SERIE AND D2_ITEMORI = D1_ITEM AND D2_CLIENTE = '000641' ), 0) QTDENTRADA " + ENTER 
	cQry += " 					FROM " + RetSqlName("SD1") + " WHERE D_E_L_E_T_ = '' " + ENTER   
	cQry += " 							AND D1_FILIAL = '" + xFilial("SD1") + "' " + ENTER
	cQry += " 							AND D1_SERIE + D1_DOC IN  (SELECT F2_SERIE + F2_DOC FROM " + RetSqlName("SF2") + " WHERE D_E_L_E_T_ = '' AND F2_CLIENTE = '" + aDados[1] + "' AND F2_EMISSAO >= CONVERT(VARCHAR, GETDATE() - 90, 112)) " + ENTER 
	cQry += " 					) QRY, " + RetSqlName("SB1") + " SB1 WHERE SB1.D_E_L_E_T_ = '' " + ENTER 
	cQry += " 						AND B1_COD = PRODUTO_ " + ENTER 
	cQry += " 				GROUP BY " + ENTER 
	cQry += " 						PRODUTO_ " + ENTER 
	cQry += " 				HAVING " + ENTER 
	cQry += " 						SUM(QTDSAIDA) != SUM(QTDENTRADA) " + ENTER 
	cQry += " 				) QRY " + ENTER 
	cQry += " 		GROUP BY " + ENTER 
	cQry += " 				PRODUTO, " + ENTER 
	cQry += " 				DESCRICAO, " + ENTER 
	cQry += " 				UM " + ENTER
	cQry += " 		HAVING " + ENTER  
	cQry += " 				( SUM(QTDVEN) != 0 OR " + ENTER 
	cQry += " 				SUM(QTDEST) != 0 OR " + ENTER 
	cQry += " 				SUM(QTDRES) != 0 OR " + ENTER 
	cQry += " 				SUM(QTDTRT) != 0 OR " + ENTER 
	cQry += " 				SUM(QTD_DEMANDA_MES) != 0 ) " + ENTER 
	cQry += " 		) QRY " + ENTER
	cQry += " WHERE " + ENTER
	cQry += " 		NECESSIDADE != 0 " + ENTER	
	cQry += " 		AND TIPO = 'PA' " + ENTER	
	cQry += " ORDER BY " + ENTER
	cQry += " 		PRODUTO " + ENTER	 
	
	TcSQLExec(cQry)            
	
	cQry := "SELECT SUM(PESO_UNIT * NECESSIDADE) PESO FROM " + cTabela
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf
	TCQUERY cQry NEW ALIAS QRY	
			                    
	If QRY->PESO > aDados[2]
		lCont := .F. 
		nPeso := QRY->PESO	
	EndIf     
	
	nDias++
			
EndDo		
	    
cQry := "SELECT * FROM " + cTabela	
If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf
TCQUERY cQry NEW ALIAS QRY		

dbSelectArea("QRY")
dbGoTop()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//| Geracao dos arrays para o Orcamento                          |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cSeqSCK  := "01" 
lGeraSCJ := .T.   
cPVSCJ   := ""   

While !QRY->(EOF())
    
	// Grava SCJ
	If lGeraSCJ
		
		cNumSCJ := GetSxeNum("SCJ", "CJ_NUM")     
		ConfirmSX8()   
		cPVSCJ  += cNumSCJ + "#"
		
		RecLock("SCJ", .T.)
			SCJ->CJ_FILIAL  := xFilial("SCJ")
			SCJ->CJ_NUM     := cNumSCJ
			//SCJ->CJ_TIPOCLI := "N"
			SCJ->CJ_CLIENTE := aDados[1]
			SCJ->CJ_LOJA    := "01"
			SCJ->CJ_CONDPAG := "30R"
			SCJ->CJ_EMISSAO := dDataBase
			SCJ->CJ_TABELA  := "QV1"
			SCJ->CJ_STATUS  := "F"
			SCJ->CJ_COD     := aDados[4]
			SCJ->CJ_MOEDA   := 1
			SCJ->CJ_TXMOEDA := 1
			SCJ->CJ_VALIDA  := dDataBase + 10
			SCJ->CJ_TPFRETE := "C"
			SCJ->CJ_ICMS    := "I"
			SCJ->CJ_CLIENT  := aDados[1]
			SCJ->CJ_LOJAENT := "01"
			SCJ->CJ_ATEND   := cUserName
			SCJ->CJ_TIPLIB  := "1"
			SCJ->CJ_TPCARGA := "2"
			SCJ->CJ_ENTREG  := dDataBase + 3
			SCJ->CJ_TRANSP  := "000001"
			SCJ->CJ_PBRUTO  := nPeso
		SCJ->(MsUnLock())
		lGeraSCJ := .F.		
		
	EndIf
    
    SB1->(dbSetOrder(1))                  
    SB1->(dbSeek(xFilial("SB1") + QRY->PRODUTO))                  
         
	// Grava SCK
	RecLock("SCK", .T.)               
		SCK->CK_FILIAL   := xFilial("SCK")
		SCK->CK_ITEM     := cSeqSCK
		SCK->CK_PRODUTO  := QRY->PRODUTO
		SCK->CK_DESCRI   := QRY->DESCRICAO
		SCK->CK_UM       := SB1->B1_UM
		SCK->CK_QTDVEN   := QRY->NECESSIDADE
		SCK->CK_PRCVEN   := ( SB1->B1_CUSTD / 2 )
		SCK->CK_VALOR    := QRY->NECESSIDADE * ( SB1->B1_CUSTD / 2 )
		SCK->CK_TES      := "511"
		SCK->CK_LOCAL    := "08"
		SCK->CK_CLIENTE  := aDados[1]
		SCK->CK_LOJA     := "01"
		SCK->CK_NUM      := cNumSCJ
		SCK->CK_PRUNIT   := ( SB1->B1_CUSTD / 2 )
		SCK->CK_ENTREG   := dDataBase + 3
	SCK->(MsUnLock())
		       
	cSeqSCK := Soma1(cSeqSCK, 2)	
		
	QRY->(dbSkip())  
	
EndDo

QRY->(dbCloseArea())

//Apagar tabela temporแria
If TcCanOpen(cTabela)  
	TcDelFile(cTabela)
EndIf

cMsg := "Opera็ใo efetuada com sucesso! Or็amento " + cPVSCJ + ENTER
	
MsgInfo(cMsg, "Gera็ใo Automแtica de Pedido เ Fแbrica")

Return
