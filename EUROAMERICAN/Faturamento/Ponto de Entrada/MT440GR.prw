#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#include "tryexception.ch"

#define ENTER chr(13) + chr(10)

/*/
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅН»пїЅпїЅ
пїЅпїЅпїЅPrograma  пїЅMT440GR   пїЅAutor  пїЅEmerson Paiva       пїЅ Data пїЅ  15/12/17   пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅН№пїЅпїЅ
пїЅпїЅпїЅDescricao пїЅPE APOS A CONFIRMACAO DA LIBERACAO DO PEDIDO                пїЅпїЅпїЅ
пїЅпїЅпїЅ          пїЅ                                                            пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅН№пїЅпїЅ
пїЅпїЅпїЅUso       пїЅ GENERICO                                                   пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅН№пїЅпїЅ
пїЅпїЅпїЅ                     A L T E R A C O E S                               пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅН№пїЅпїЅ
пїЅпїЅпїЅData      пїЅProgramador       пїЅAlteracoes                               пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅНјпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
/*/
User Function MT440GR()
 
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaSB2 := SB2->(GetArea())
Local aAreaSC6 := SC6->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSA1 := SA1->(GetArea())
Local cNum     := ""
//Local nDif     := 0
//Local lForaMix := (Posicione("SA1", 1, xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI) /*, "A1_MIX") == "N") */
Local nValorPV := 0
Local nDescAdi := 0
Local lBlqPolC := .T.
Local lExport := .F.
Local I

Local oError	:= Nil

Begin Sequence

	SC5->(dbSelectArea("SC5"))

	//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅДї
	//| PolпїЅtica comercial Multicores - A partir de Maio/2017 - Emerson Paiv|
	//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ

    //  Grupo Empresa - Ajuste realizado (CG)

    //  If cEmpAnt $ "01#03#08" .And. !SC5->C5_CLIENTE $ "001604#006477#006486#006487#006514#006514#006527#006647#006479#005154#005155#005156#006043#009335" //Jays, Latina e Euroamerican

	If Left(cFilAnt,2) $ "01#03#08" .And. !SC5->C5_CLIENTE $  SuperGetMv("EQ_NCLPOLV",.F.,"001604#006477#006486#006487#006514#006514#006527#006647#006479#005154#005155#005156#006043#009335") //Jays, Latina e Euroamerican

		/*
		//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅДї
		//|Verifica regra de condicao de pagamento                              пїЅ
		//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
		aVencto  := Condicao(10000, SC5->C5_CONDPAG, 0, dDataBase)
		nDias    := 0

		For i := 1 to Len(aVencto)
			nDias += (aVencto[i,1] - dDataBase)
		Next i

		nPrzMd := nDias / (i - 1)
		*/

		If !SC5->C5_TIPO $ "D#B#C#I#P"  //Ignorar Beneficiamento, Complemento de PreпїЅo/ICMS e IPI

			cQry := " SELECT CAST((( 1 - (SUM(VALOR) / SUM(TOTPRCTBL)))*100) AS NUMERIC(14,2)) AS DESCONTO, " + ENTER
			cQry += "		CAST(( SUM(FATORM) / SUM(VALOR) ) AS NUMERIC(14,2)) AS FATORMD,
			cQry += "		ZHOLDIN, " + ENTER
			cQry += "		ZCLASSI, " + ENTER
			cQry += "		ZDESCTZ, " + ENTER
			cQry += "		CONDPGTO, " + ENTER
			cQry += "		TRANSPORT, " + ENTER
			cQry += "		ESTADO, " + ENTER
			cQry += "		ZDSCLOG, " + ENTER
			cQry += "		ZDSCPRL, " + ENTER
			cQry += "		TABELA " + ENTER
			cQry += " FROM " + ENTER
			cQry += " ( " + ENTER
			cQry += "	SELECT	C6_VALOR VALOR, " + ENTER
			cQry += "			(	SELECT TOP 1 DA1.DA1_PRCVEN FROM " + RetSqlName("DA1") + " AS DA1 WITH (NOLOCK) " + ENTER
			cQry += " 				WHERE DA1.D_E_L_E_T_ = '' AND SC5.C5_TABELA = DA1.DA1_CODTAB AND SC5.C5_MOEDA = DA1.DA1_MOEDA AND SC6.C6_PRODUTO = DA1.DA1_CODPRO  ORDER BY DA1.R_E_C_N_O_ DESC) * C6_QTDVEN AS TOTPRCTBL, " + ENTER
			cQry += " 			ROUND(((C6_PRCVEN/(C5_PORCENT/100))/((CASE WHEN B1_CUSTD = 0 THEN (C6_PRCVEN/(C5_PORCENT/100)) ELSE (CASE WHEN A1_EST = 'EX' THEN (CASE WHEN B1_CUSTNET > 0 THEN B1_CUSTNET ELSE (C6_PRCVEN/(C5_PORCENT/100)) END) ELSE B1_CUSTD END) END)*1.03)),2) * C6_VALOR AS FATORM, " + ENTER   //Geronimo 28/08/23 Ajuste na query para evitar o erro de zero divide quando em PV de exportaзгo o campo B1_CUSTD estava maior que zero e  B1_CUSTONET IGUAL A ZERO
			// //cQry += " 		ROUND(((C6_PRCVEN/(C5_PORCENT/100))/((CASE WHEN B1_CUSTD = 0 THEN (C6_PRCVEN/(C5_PORCENT/100)) ELSE (CASE WHEN A1_EST = 'EX' THEN B1_CUSTNET ELSE B1_CUSTD END) END)*1.03)),2) * C6_VALOR AS FATORM, " + ENTER   //Geronimo 28/08/23 linha anterior da query para historico e comparaзгo 
			cQry += "			SA1.A1_ZHOLDIN ZHOLDIN, " + ENTER
			cQry += "			SA1.A1_ZCLASSI ZCLASSI, " + ENTER
			cQry += "			SA1.A1_ZDESCTZ ZDESCTZ, " + ENTER
			cQry += "			SC5.C5_CONDPAG AS CONDPGTO, " + ENTER
			cQry += "			SC5.C5_TRANSP AS TRANSPORT, " + ENTER
			cQry += "			SA1.A1_EST AS ESTADO,  " + ENTER
			cQry += "			A1_ZDSCLOG AS ZDSCLOG, " + ENTER
			cQry += "			A1_ZDSCPRL AS ZDSCPRL, " + ENTER
			cQry += "			SC5.C5_TABELA AS TABELA " + ENTER
			cQry += " 	FROM  " + ENTER
			cQry += " 		" + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) INNER JOIN " + ENTER
			cQry += " 		" + RetSqlName("SC5") + " AS SC5 WITH (NOLOCK) ON SC5.C5_NUM = SC6.C6_NUM AND SC5.C5_FILIAL = SC6.C6_FILIAL " + ENTER
			cQry += " 		INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON SC6.C6_PRODUTO = SB1.B1_COD " + ENTER
			cQry += " 		INNER JOIN " + RetSqlName("SA1") + " AS SA1 WITH (NOLOCK) ON SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA AND SC5.C5_FILIAL = SA1.A1_FILIAL " + ENTER
			cQry += "	 WHERE  " + ENTER
			cQry += " 		SC6.D_E_L_E_T_ = ''   " + ENTER
			cQry += " 		AND SC5.D_E_L_E_T_ = ''   " + ENTER
			cQry += " 		AND SB1.D_E_L_E_T_ = ''   " + ENTER
			cQry += " 		AND C6_FILIAL = '" + xFilial("SC6") + "'  " + ENTER
			cQry += "		AND C6_NUM = '" + SC5->C5_NUM + "' " + ENTER
			cQry += " ) PEDIDOS " + ENTER
			cQry += " GROUP BY ZHOLDIN, ZCLASSI, ZDESCTZ, CONDPGTO, TRANSPORT, ESTADO, ZDSCLOG, ZDSCPRL, TABELA " + ENTER

			If Select("QRY") > 0
				QRY->(dbCloseArea())
			EndIf

			TCQUERY cQry NEW ALIAS QRY

			If !QRY->(EOF())

				//Descontos conforme classificaпїЅпїЅo dos Clientes
				nDescAdi := 0

				If QRY->CONDPGTO $ "14A#21A#14D#01A"
					nDescAdi += 2	//Desconto adicional 2% para pagamento 21DDL
				ElseIf QRY->CONDPGTO $ "28Q#28Y"
					nDescAdi += 1	//Desconto adicional 1% para pagamento 42DDL
				EndIf

				/*If QRY->TRANSPORT $ "000002"
					If QRY->ESTADO $ "SP"	//Desconto Adicional 4% para retira estado de SP
						nDescAdi += 4
					Else					//Desconto Adicional 6% para retira fora de SP
						nDescAdi += 6
					EndIf
				EndIf*/ //Retirado 03/08/2018

				If QRY->ZDSCLOG == "S"		//Desconto LogпїЅstico - Pedidos com emissпїЅo entre dia 1 e 15 do mпїЅs
					nDescAdi += 2
				ElseIf QRY->ZDSCPRL == "S"	//Desconto PreпїЅo/Litro
					nDescAdi += 2
				EndIf

				Do Case
					Case QRY->TABELA $ "QC1" //Regra Construtoras desconto mпїЅximo 32%
						If QRY->DESCONTO <= SuperGetMv("EQ_DESCMXG",.T.,32.01)
							lBlqPolC := .F.
							nDescAdi := 0
						EndIf
					Case QRY->ZCLASSI == "A"	//Tabela PrпїЅpria
						If QRY->DESCONTO <= (SuperGetMv("EQ_DESCMXA",.T.,42.01) + nDescAdi)	//Considerando adicional 0.01 relativo a arredondamentos
							lBlqPolC := .F.
						EndIf
					Case QRY->ZCLASSI == "B"
						If QRY->DESCONTO <= (SuperGetMv("EQ_DESCMXB",.T.,40.01) + nDescAdi)
							lBlqPolC := .F.
						EndIf
					Case QRY->ZCLASSI == "C"
						If QRY->DESCONTO <= (SuperGetMv("EQ_DESCMXC",.T.,38.01) + nDescAdi)
							lBlqPolC := .F.
						EndIf
					Case QRY->ZCLASSI == "D"
						If QRY->DESCONTO <= (SuperGetMv("EQ_DESCMXD",.T.,36.01) + nDescAdi)
							lBlqPolC := .F.
						EndIf
					Case QRY->ZCLASSI == "E"
						If QRY->DESCONTO <= (SuperGetMv("EQ_DESCMXE",.T.,34.01) + nDescAdi)
							lBlqPolC := .F.
						EndIf
					Case QRY->ZCLASSI == "F"
						If QRY->DESCONTO <= (SuperGetMv("EQ_DESCMXF",.T.,32.01) + nDescAdi)
							lBlqPolC := .F.
						EndIf
					/*Case QRY->ZCLASSI == "Z"
						If QRY->DESCONTO <= (QRY->ZDESCTZ + nDescAdi + 0.01 )
							lBlqPolC := .F.
						EndIf	*/
					Otherwise
						If QRY->DESCONTO <= (0.01 + nDescAdi)
							lBlqPolC := .F.
						EndIf
				EndCase

			EndIf

			If lBlqPolC
				Aviso("Pedido com preзo de venda abaixo do mнnimo permitido.", "Pedido com desconto maior que o permitido pela polнtica comercial para a classificaзгo do Cliente. Desconto de " + cValToChar(QRY->DESCONTO) + "% e classificaзгo " + QRY->ZCLASSI + ". Desconto adicional retira а vista: " + cValToChar(nDescAdi) + "%. Solicitar aprovaзгo da Diretoria." , {"Ok"}, 3)
				If AllTrim(cUserName) $  SuperGetMv("EQ_MPRCMIN",.F.,"Alessandra.Monea#Thiago.Monea#Caroline.Monea#Kely.Souza#Administrador#eulalia.ramos#Talita.Rodrigues#Alexsandro.Blasques#eristeu.junior")
				//If (AllTrim(cUserName) $ GETMV('MV_XDESPPV')) //fabio batista 15/01/2021
					If !MsgYesNo("Deseja prosseguir com a liberaпїЅпїЅo do desconto maior que a polпїЅtica comercial para a classificaпїЅпїЅo do Cliente? Desconto de " + cValToChar(QRY->DESCONTO) + "% e classificaзгo "  + IIF(QRY->TABELA $ "QC1","CONSTRUTORA", QRY->ZCLASSI ) + ". Desconto adicional retira а vista: " + cValToChar(nDescAdi) + " %.", "A T E N З Г O", "YESNO")
						lRet := .F.
						Break
					EndIf
				Else
					lRet := .F.
					Break
				EndIf
			EndIf

		EndIf

	EndIf

	//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅДї
	//| LiberaпїЅпїЅo de todas bonificaпїЅпїЅes    - Autor: Emerson Paiva 24/04/17  |
	//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
	If !SC5->C5_TIPO $ "C#I#P" //Ignorar Complemento de PreпїЅo/ICMS e IPI

		cQry := " SELECT " + ENTER
		cQry += " 		SUM(C6_VALOR) BONIF " + ENTER
		cQry += " FROM " + RetSqlName("SC6") + ENTER
		cQry += "WHERE " + ENTER
		cQry += "		D_E_L_E_T_ = '' " + ENTER
		cQry += "       AND C6_FILIAL = '" + xFilial("SC6") + "' "
		//cQry += "		AND ( C6_U_OPER = '502' OR C6_TES = '510' ) " + ENTER
		cQry += "		AND C6_TES = '510' " + ENTER
		cQry += "		AND C6_NUM = '" + SC5->C5_NUM + "' " + ENTER

		If Select("QRY") > 0
			QRY->(dbCloseArea())
		EndIf

		TCQUERY cQry NEW ALIAS QRY

		//LiberaпїЅпїЅo todas as bonificaпїЅпїЅes - Emerson Paiva 24/04/17
		If QRY->BONIF > 0
			If 	!(AllTrim(cUserName) $ SuperGetMv("EQ_AUTBONI",.F.,"Alessandra.Monea#Thiago.Monea#Caroline.Monea#Administrador#eulalia.ramos#Talita.Rodrigues#Adriana.Lima#eristeu.junior"))
				Aviso("Pedido de Vendas", "Bonificaзгo: aprovaзгo deve ser realizada pela Diretoria!" + ENTER, {"Ok"}, 3)
				lRet := .F.
				Break
			ElseIf !MsgYesNo("Bonificaзгo, deseja prosseguir com a liberaзгo?", "A T E N З Г O", "YESNO")
				lRet := .F.
				Break
			EndIf
		EndIf

		If Select("QRY") > 0
			QRY->(dbCloseArea())
		EndIf

	EndIf


	//  Grupo Empresa - Ajuste realizado (CG)

	//  If cEmpAnt + cFilAnt $ "0107#0108" .And. SC5->C5_PBRUTO > 10000 .And. AllTrim(cUserName) != "Administrador"

	If cFilAnt $ "0107#0108" .And. SC5->C5_PBRUTO > 10000 .And. AllTrim(cUserName) != "Administrador"
		lRet := .F.
		MsgStop("Esse pedido deve ser emitido diretamente pela fбbrica. Entre em contato com a Adm. Vendas Qualyvinil.")
		Break
	EndIf

	If Len(AllTrim(SC5->C5_NOTA)) == 0 .And. SC5->C5_LIBEROK == "S"
		lRet := .F.
		Break
	EndIf

	// Valida liberacao de Pre-Pedido
	/*If SC5->C5_PREPED == "S"
		lRet := .F.
		MsgStop("Esse pedido пїЅ um PrпїЅ-Pedido. Altere o tipo para prosseguir com a liberaпїЅпїЅo.")
		Break
	EndIf*/

	SC6->(dbSetOrder(1))
	SC6->(dbSeek(xFilial("SC6") + SC5->C5_NUM))

	cNum    := SC6->C6_NUM
	nSumQtd := 0
	nSumFat := 0
	nSumMgm := 0
	nSumVlr := 0
	cProdIn := "'" + SC6->C6_PRODUTO + "'"

	While !SC6->(EOF()) .And. SC6->C6_NUM == cNum .And. SC6->C6_FILIAL == xFilial("SC6") .And. Empty(SC6->C6_NOTA)

		// Calcula Total do PV
		nValorPV += SC6->C6_VALOR / ( SC5->C5_PORCENT / 100 )

		// Saldos em Estoque
		/*
		SB2->(dbSetOrder(1))
		SB2->(dbSeek(xFilial("SB2") + SC6->C6_PRODUTO + SC6->C6_LOCAL))

		nSaldo := SB2->B2_QATU - SB2->B2_QEMP + SB2->B2_RESERVA
		nDif   := nSaldo - SC6->C6_QTDVEN

		If nDif <= 0
			aOp  := {"Ok"}
			cTit := "Saldo em Estoque Insuficiente"
			cMsg := "Produto + Almoxarifado : " + Alltrim(SC6->C6_PRODUTO) + " - " + SC6->C6_LOCAL + Space(3)
			cMsg := cMsg + "Saldo Atual : " + Transform(nSaldo, "@E 999,999.99") + Space(30)
			cMsg := cMsg + "Solicitado : " + Transform(SC6->C6_QTDVEN, "@E 999,999.99")
			Aviso(cTit,cMsg,aOp)
		Endif
		*/
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + SC6->C6_PRODUTO))

		If SA1->A1_TIPO == 'X' .and. (SB1->B1_SEGUM == "CT" .or. SB1->B1_UM == "CT") .And. Subs(SC6->C6_PRODUTO, 5, 2) == "07" .And. Posicione("SF4", 1, xFilial("SF4") + SC6->C6_TES, "F4_ESTOQUE") == "S"//ALATERADO POR FABIO BATISTA 23/06/2020
			lExport := .t.
		EndIf 
		// Pedido de Containner
	//	SB1->(dbSetOrder(1))
	//	SB1->(dbSeek(xFilial("SB1") + SC6->C6_PRODUTO))

		If (SB1->B1_SEGUM == "CT" .Or. SB1->B1_UM == "CT") .And. Subs(SC6->C6_PRODUTO, 5, 2) == "07" .And. Posicione("SF4", 1, xFilial("SF4") + SC6->C6_TES, "F4_ESTOQUE") == "S"
		  	If Empty(SC5->C5_PEDVINC) .and. !lExport
				MsgStop("Insira o pedido de container viculado a este Pedido!")
		  		lRet := .F.
		  		Break
			Else

				// Verifica se pedido vinculado eh de containner
				cQry := " SELECT	C6_NUM NUM, " + ENTER
				cQry += " 			SUM(C6_QTDVEN) QTD " + ENTER
				cQry += " FROM		" + RetSqlName("SC6") + " SC6 " + ENTER
				cQry += " INNER JOIN " + RetSqlName("SB1") + " SB1 " + ENTER
				cQry += " ON		SB1.D_E_L_E_T_ = '' " + ENTER
				cQry += " AND		B1_FILIAL = '' " + ENTER
				cQry += " AND		B1_COD = C6_PRODUTO " + ENTER
				cQry += " AND		( B1_UM = 'CT' OR B1_SEGUM = 'CT' OR  SUBSTRING(B1_COD, 5, 2) = '07' )  " + ENTER
				cQry += " WHERE 	SC6.D_E_L_E_T_ = '' " + ENTER


                // Grupo Empresa - Ajuste realizado (CG)
				
				// cQry += " AND C6_FILIAL IN (" + IIf( cEmpAnt+cFilAnt $ "0200#0205", "'00','05'", "'" + xFilial("SC6") + "'" ) + ") " + ENTER

                cQry += " AND		C6_FILIAL IN ('0200','0205')" + ENTER
				cQry += " AND 		C6_NUM = '" + SC5->C5_PEDVINC + "' " + ENTER
				cQry += " AND 		C6_PRODUTO IN ('ME.0044', 'XC700011') " + ENTER
				cQry += " GROUP BY C6_NUM " + ENTER

				If Select("QRY") > 0
					QRY->(dbCloseArea())
				EndIf

				TCQUERY cQry NEW ALIAS QRY

				dbSelectArea("QRY")

				If QRY->(EOF())  .and. !lExport
					MsgStop("Pedido vinculado nao eh de container!")
					lRet := .F.
					Break
				EndIf

				/*
	            // Verifica quantidade de container
				cQry := " SELECT	C6_NUM NUM, " + ENTER
				cQry += " 			SUM(C6_QTDEMB) QTD  " + ENTER
				cQry += " FROM		" + RetSqlName("SC6") + " SC6 " + ENTER
				cQry += " INNER JOIN " + RetSqlName("SB1") + " SB1 " + ENTER
				cQry += " ON		SB1.D_E_L_E_T_ = '' " + ENTER
				cQry += " AND		B1_FILIAL = '' " + ENTER
				cQry += " AND		B1_COD = C6_PRODUTO " + ENTER
				cQry += " AND		( B1_UM = 'CT' OR B1_SEGUM = 'CT' OR  SUBSTRING(B1_COD, 5, 2) = '07' )  " + ENTER
				cQry += " WHERE		SC6.D_E_L_E_T_ = '' " + ENTER
				cQry += " AND		C6_FILIAL IN (" + IIf( cEmpAnt+cFilAnt $ "0200#0205", "'00','05'", "'" + xFilial("SC6") + "'" ) + ") " + ENTER
				cQry += " AND 		C6_NUM = '" + SC5->C5_NUM + "' " + ENTER
				cQry += " GROUP BY C6_NUM" + ENTER

				If Select("QRY2") > 0
					QRY2->(dbCloseArea())
				EndIf

				TCQUERY cQry NEW ALIAS QRY2

				If QRY->QTD <> QRY2->QTD
					MsgStop("Pedido vinculado nпїЅo contem quantidade de container necessпїЅria ao pedido!")
				   	lRet := .F.
				   	Break
				EndIf
				*/
				QRY->(dbCloseArea())
				//QRY2->(dbCloseArea())

				// Verifica se pedido nao foi vinculado a outro pedido
				cQry := " SELECT	C5_PEDVINC " + ENTER
				cQry += " FROM		" + RetSqlName("SC5") + ENTER
				cQry += " WHERE		D_E_L_E_T_ = '' " + ENTER


				// Grupo Empresa - Ajuste realizado (CG)

				// cQry += " AND C5_FILIAL IN (" + IIf( cEmpAnt+cFilAnt $ "0200#0205", "'00','05'", "'" + xFilial("SC5") + "'" ) + ") " + ENTER

				cQry += " AND		C5_FILIAL IN ('0200','0205') " + ENTER
				cQry += " AND		C5_PEDVINC = '" + SC5->C5_PEDVINC + "' " + ENTER

				If Select("QRY") > 0
					QRY->(dbCloseArea())
				EndIf

				TCQUERY cQry NEW ALIAS QRY

				dbSelectArea("QRY")
				dbSkip()

				If !QRY->(EOF()) .and. !lExport
					MsgStop("Pedido vinculado jб associado a outro pedido!")
					lRet := .F.
					Break
				EndIf

				QRY->(dbCloseArea())

			EndIf

		EndIf

		SC6->(dbSkip())

		If !SC6->(EOF()) .And. SC6->C6_NUM == cNum .And. SC6->C6_FILIAL == xFilial("SC6")
			cProdIn += ",'" + AllTrim(SC6->C6_PRODUTO) + "'"
		EndIf

	Enddo

	// Produto em Inventario
	/*If !(cEmpAnt $ "06#04")

		cQry := " SELECT	ZO_PRODUTO PRODUTO " + ENTER
		cQry += " FROM	" + RetSqlName("SZO") + " " + ENTER
		cQry += " WHERE		D_E_L_E_T_ = '' " + ENTER
		cQry += "           AND ZO_FILIAL = '" + xFilial("SZO") + "' " + ENTER
		cQry += " 			AND ZO_STATUS != '2' " + ENTER
		cQry += " 			AND ZO_PRODUTO IN (" + cProdIn + ") "

		MemoWrite("mt440gr.sql", cQry)

		If Select("QRY") > 0
			QRY->(dbCloseArea())
		EndIf

		TCQUERY cQry NEW ALIAS QRY

		cProdIn := ""

		While !QRY->(EOF())
			cProdIn += QRY->PRODUTO + ENTER
			QRY->(dbSkip())
		EndDo
		QRY->(dbCloseArea())

		If !Empty(cProdIn)
			Aviso("Pedidos de Vendas", "Os produtos abaixo estпїЅo sendo inventariados:" + ENTER + cProdIn, {"Ok"}, 3)
			lRet := .F.
			Break
		EndIf

	EndIf*/

	//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅДї
	//| Verifica regra de bonificacao                                       |
	//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
	/*If !Empty(SC5->C5_PEDVINC) .And. cEmpAnt + cFilAnt $ "0107#0108#0200#0203#0303#0304#0801"

		cQry := " SELECT " + ENTER
		cQry += " 		SUM(C6_VALOR)/(SELECT SUM(C6_VALOR) FROM " + RetSqlName("SC6") + " WHERE D_E_L_E_T_ = ''  AND C6_FILIAL = '" + xFilial("SC6") + "' AND C6_NUM = '" + SC5->C5_PEDVINC + "') BONIF " + ENTER
		cQry += " FROM " + ENTER
		cQry += "		" + RetSqlName("SC6") + ENTER
		cQry += "WHERE " + ENTER
		cQry += "		D_E_L_E_T_ = '' " + ENTER
		cQry += "       AND C6_FILIAL = '" + xFilial("SC6") + "' "
		cQry += "		AND ( C6_U_OPER = '502' OR C6_TES = '510' ) " + ENTER
		cQry += "		AND C6_NUM = '" + SC5->C5_NUM + "' " + ENTER

		If Select("QRY") > 0
			QRY->(dbCloseArea())
		EndIf

		TCQUERY cQry NEW ALIAS QRY

		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))

		//LiberaпїЅпїЅo todas as bonificaпїЅпїЅes - Emerson Paiva 24/04/17
		If QRY->BONIF > 0
			If 	!(AllTrim(cUserName) $ "Alessandra.Monea#Thiago.Monea#Caroline.Monea#Administrador")
				Aviso("Pedido de Vendas", "BonificaпїЅпїЅo: aprovaпїЅпїЅo deve ser realizada pela Diretoria!" + ENTER, {"Ok"}, 3)
				lRet := .F.
				Break
			ElseIf !MsgYesNo("BonificaпїЅпїЅo, deseja prosseguir com a liberaпїЅпїЅo?", "A T E N пїЅ пїЅ O", "YESNO")
				lRet := .F.
				Break
			EndIf
		EndIf


		//Limite de bonificacao
		/*If QRY->BONIF > 0 .And. (QRY->BONIF > (SA1->A1_PBONIF / 100) .Or. SA1->A1_DTBONIF < dDataBase)
			Aviso("Pedido de Vendas", "Percentual de bonificaпїЅпїЅo acima do permitido ou data de validade vencida!" + ENTER, {"Ok"}, 3)
			lRet := .F.
			Break
		EndIf	        */ //Alterado 24/04/17
	/*
		If Select("QRY") > 0
			QRY->(dbCloseArea())
		EndIf

	EndIf     */ //Controle todas as bonificaпїЅпїЅes acima 05/12/17

	//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅДї
	//| Aprovacao financeira automatica para PV's feito para distribuidora  |
	//|                                                                     |
	//|	032579-01 : JAYS TINTAS                                             |
	//| 032400-01 : QUALYCOR COMERCIAL                                      |
	//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
	/*
	If AllTrim(cFilAnt) $ "0200#0205" .AND. SC5->(C5_CLIENTE+C5_LOJACLI) $ "03257901#03240001"
		lRet := U_FATM021("010")
	EndIF
	*/

	//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅДї
	//| Valida Valor da Parcela (Minimo R$ 300,00 para mais de 1)           пїЅ
	//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
	aParcelas := Condicao(nValorPV, SC5->C5_CONDPAG, 0, dDataBase)
	nVlrParc  := nValorPV / Len(aParcelas)
	If nVlrParc < SuperGetMv("EQ_PARCMIN",.F.,300) .And. Len(aParcelas) > 1 //.And. !cEmpAnt+cFilAnt $ "0801" Alterado 19/04/18
		MsgStop("O valor mпnнmo de parcela й R$ 300,00. Altere a Condiзгo de Pagamento!")
		lRet := .F.
		Break
	EndIf

	//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅДї
	//|Verifica regra de condicao de pagamento                              пїЅ
	//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
	aVencto  := Condicao(10000, SC5->C5_CONDPAG, 0, dDataBase)
	nDias    := 0

	For i := 1 to Len(aVencto)
		nDias += (aVencto[i,1] - dDataBase)
	Next i

	nPrzMd := nDias / (i - 1)

	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))

	//Regra de Prazo Medio

	//  Grupo Empresa - Ajuste realizado (CG)

	// If cEmpAnt + cFilAnt $ "0107#0108#0203#0303#0304#0801#0803#0901"

	If cFilAnt $ "0107#0108#0203#0303#0304#0801#0803#0901"

		If nValorPV < 1000
			nPrzRef := 25
		ElseIf nValorPV >= 1000 .And. nValorPV < 3000
			nPrzRef := 38
		ElseIf nValorPV >= 3000 .And. nValorPV < 5000
			nPrzRef := 42
		ElseIf nValorPV >= 5000 .And. nValorPV < 10000
			nPrzRef := 48
		ElseIf nValorPV >= 10000 .And. nValorPV < 20000
			nPrzRef := 50
		ElseIf nValorPV >= 20000 .And. nValorPV < 60000
			nPrzRef := 60
		Else
			nPrzRef := SA1->A1_PRZMD
		EndIf

	Else

		nPrzRef := SA1->A1_PRZMD

	EndIf

	If nPrzMd > nPrzRef .And. !(AllTrim(cUserName) $ "Alessandra.Monea#Thiago.Monea#Caroline.Monea#Kely.Souza#Eunice.Godoy#Luciana.Mota#Douglas.Moura#Administrador#eulalia.ramos#Talita.Rodrigues#Adriana.Lima#eristeu.junior")

		Aviso("Pedidos de Vendas", "Condiзгo de pagamento fora da regra (Prazo mйdio > " + AllTrim(Str(nPrzRef)) + " dias)" , {"Ok"}, 3)
		If !MsgYesNo("Deseja prosseguir com a liberaзгo do prazo?", "A T E N З Г O", "YESNO")
			lRet := .F.
			Break
		EndIf

	EndIf

	// Verifica Prazo MпїЅdio
	/*aParcelas := Condicao(10000, SC5->C5_CONDPAG, , dDataBase)
	nDias   := 0
	For i := 1 to Len(aParcelas)
		nDias += (aParcelas[i,1] - dDataBase)
	Next i
	nPrzMd  := nDias / (i - 1)
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
	cQry := " SELECT ISNULL(CEILING(SUM(PRZMD * SUBTOT) / SUM(SUBTOT)), 40) + 8 PRZMD FROM P_POLITICA_COMERCIAL WHERE QUANTID > 0 AND EMPRESA + FILIAL = '" + cEmpAnt + cFilAnt + "' AND SUBSTRING(CLIENTE, 1, 6) = '" + Iif(Empty(SA1->A1_CLICTR), SA1->A1_COD, SA1->A1_CLICTR) + "' "
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf
	TCQUERY cQry NEW ALIAS QRY

	If !QRY->(EOF()) .And. nPrzMd > QRY->PRZMD
	MsgAlert("Prazo de Pagamento Superior a MпїЅdia do Cliente! Ajuste para um prazo inferior a " + cValtoChar(Round(QRY->PRZMD, 2)))
		If !(AllTrim(cUserName) $ "Administrador#Alessandra.Monea#Thiago.Monea#Robson.Moraes#Caroline.Monea#Luciana.Mota#Eunice.Godoy")
			lRet := .F.
			Break
		EndIf
	EndIf*/


	//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅДї
	//| Mix de Vendas                                                       |
	//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
	/*If lRet

		lRet := U_FATM003(.F.)      */

	    // Clientes que nao obedecem a regra do mix
		/*If lForaMix
			lRet := lForaMix
		EndIf*/
		/*
		If !lRet
			Break
		EndIf

	EndIf*/


	//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅДї
	//| Verifica regra desconto acima de 5% do preпїЅo de lista e/ou fator    |
	//| acima de 1,50 para Euroamerican - Emerson Paiva                     |
	//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ


	// Grupo Empresa - Ajuste realizado (CG)

	// If cEmpAnt + cFilAnt $ "0200" .And. !SC5->C5_CLIENTE $ "031542#003444#035559#035728#036068#032154#000304#035323#000300#000301#000302#000891#001076#001129#002624#030605#032729#035512" //Exceto Klabin, Henkel e Qualycril (transferпїЅncia)

	If cFilAnt $ "0200" .And. !SC5->C5_CLIENTE $  SuperGetMv("EQ_CLDESC5",.F.,"031542#003444#035559#035728#036068#032154#000304#035323#000300#000301#000302#000891#001076#001129#002624#030605#032729#035512") //Exceto Klabin, Henkel e Qualycril (transferпїЅncia)

		cQry := " SELECT " + ENTER
 		cQry += " 		C6_ITEM, C6_PRODUTO, C6_PRCVEN " + ENTER
		cQry += " FROM  " + ENTER
		cQry += " 		" + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) INNER JOIN " + ENTER
		cQry += " 		" + RetSqlName("SC5") + " AS SC5 WITH (NOLOCK) ON SC5.C5_NUM = SC6.C6_NUM AND SC5.C5_FILIAL = SC6.C6_FILIAL " + ENTER
		cQry += " 		INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON SC6.C6_PRODUTO = SB1.B1_COD " + ENTER
		cQry += " WHERE  " + ENTER
		cQry += " 		SC6.D_E_L_E_T_ = ''   " + ENTER
		cQry += " 		AND SC5.D_E_L_E_T_ = ''   " + ENTER
		cQry += " 		AND SB1.D_E_L_E_T_ = ''   " + ENTER
		cQry += " 		AND C6_FILIAL = '" + xFilial("SC6") + "'  " + ENTER
		cQry += "		AND C6_NUM = '" + SC5->C5_NUM + "' " + ENTER
		cQry += " 		AND SB1.B1_GRUPO BETWEEN '1000' AND '1999' " + ENTER
		cQry += " 				AND (	( C6_PRCVEN < 0.95*ISNULL((	SELECT DA1.DA1_PRCVEN FROM " + RetSqlName("DA1") + " AS DA1 WITH (NOLOCK) " + ENTER //PreпїЅo de venda pode estar atпїЅ 5% abaixo do preпїЅo de tabela
		cQry += " 													WHERE DA1.D_E_L_E_T_ = '' AND SC5.C5_TABELA = DA1.DA1_CODTAB AND SC5.C5_MOEDA = DA1.DA1_MOEDA AND SC6.C6_PRODUTO = DA1.DA1_CODPRO ),0)  ) " + ENTER
		cQry += "				 	 OR ( ( SELECT DA1.DA1_PRCVEN FROM " + RetSqlName("DA1") + " AS DA1 WITH (NOLOCK) WHERE DA1.D_E_L_E_T_ = '' AND SC5.C5_TABELA = DA1.DA1_CODTAB AND SC5.C5_MOEDA = DA1.DA1_MOEDA AND SC6.C6_PRODUTO = DA1.DA1_CODPRO ) IS NULL " + ENTER
		cQry += "							AND C6_U_FATOR < 1.5 )	)	 " + ENTER //Caso produto nпїЅo faпїЅa parte da lista de preпїЅo pode ser realizado faturamento se fator maior ou igual a 1.5

		If Select("QRY") > 0
			QRY->(dbCloseArea())
		EndIf

		TRYEXCEPTION	//TRY EXCEPTION

			TCQUERY cQry NEW ALIAS QRY


		//Desconto superior a 5% do preпїЅo de lista
		If !QRY->(EOF())

			Aviso("Pedido com preзo de venda abaixo do mнnimo permitido.", "Pedido contendo item com desconto maior que 5% do preзo de lista. Necessбrio aprovaзгo da Diretoria." , {"Ok"}, 3)
			If AllTrim(cUserName) $ SuperGetMv("EQ_DESCPV5",.F.,"Alessandra.Monea#Thiago.Monea#Caroline.Monea#Luciana.Mota#Douglas.Moura#Tatiane.Paz#Administrador#Adriana.Lima")
				If !MsgYesNo("Deseja prosseguir com a liberaзгo do desconto maior que 5% do preзo de lista?", "A T E N З Г O", "YESNO")
					lRet := .F.
					Break
				EndIf
			Else
				lRet := .F.
				Break
			EndIf

		EndIf

		CATCHEXCEPTION USING oError

			MsgInfo("Pedido com produto cadastrado mais de uma vez na tabela de precos, favor solicitar a correcao! COMISSAO SERA DESCONTADA EM 50% ATE CORRECAO!!!")
			lRet := .F.

		ENDEXCEPTION //END TRY

	EndIf

	//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅДї
	//| Verifica regra desconto acima de 8% do preпїЅo de lista               |
	//| para Qualyvinil   - Emerson Paiva                                   |
	//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ


	// Grupo Empresa - Ajuste realizado (CG)

    // If cEmpAnt $ "01" //.And. !SC5->C5_CLIENTE $ "031542#003444"    Alterado 27/01/17 de cEmpAnt $ "03" / Retirado 28/04/17 empresa 08 (Multicores)

	If	Left(cFilAnt,2) == "01" 

		cQry := " SELECT " + ENTER
 		cQry += " 		C6_ITEM, C6_PRODUTO, C6_PRCVEN " + ENTER
		cQry += " FROM  " + ENTER
		cQry += " 		" + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) INNER JOIN " + ENTER
		cQry += " 		" + RetSqlName("SC5") + " AS SC5 WITH (NOLOCK) ON SC5.C5_NUM = SC6.C6_NUM AND SC5.C5_FILIAL = SC6.C6_FILIAL " + ENTER
		cQry += " 		INNER JOIN " + RetSqlName("SB1") + " SB1 ON SC6.C6_PRODUTO = SB1.B1_COD " + ENTER
		cQry += " WHERE  " + ENTER
		cQry += " 		SC6.D_E_L_E_T_ = ''   " + ENTER
		cQry += " 		AND SC5.D_E_L_E_T_ = ''   " + ENTER
		cQry += " 		AND SB1.D_E_L_E_T_ = ''   " + ENTER
		cQry += " 		AND C6_FILIAL = '" + xFilial("SC6") + "'  " + ENTER
		cQry += "		AND C6_NUM = '" + SC5->C5_NUM + "' " + ENTER
		//cQry += " 		AND SB1.B1_GRUPO BETWEEN '1000' AND '1999' " + ENTER
		cQry += " 				AND 	( C6_PRCVEN < 0.92*ISNULL((	SELECT DA1.DA1_PRCVEN FROM " + RetSqlName("DA1") + " AS DA1 WITH (NOLOCK)" + ENTER //PreпїЅo de venda pode estar atпїЅ 8% abaixo do preпїЅo de tabela
		cQry += " 													WHERE DA1.D_E_L_E_T_ = '' AND SC5.C5_TABELA = DA1.DA1_CODTAB AND SC5.C5_MOEDA = DA1.DA1_MOEDA AND SC6.C6_PRODUTO = DA1.DA1_CODPRO ),0)  ) " + ENTER

		If Select("QRY") > 0
			QRY->(dbCloseArea())
		EndIf

		TCQUERY cQry NEW ALIAS QRY

		//Desconto superior a 8% do preпїЅo de lista
		If !QRY->(EOF())

			Aviso("Pedido com preзo de venda abaixo do mнnimo permitido.", "Pedido contendo item com desconto maior que 8% do preпїЅo de lista. Necessпsбrio aprovзгo da Diretoria." , {"Ok"}, 3)
			If AllTrim(cUserName) $ SuperGetMv("EQ_DESCPV8",.F.,"Alessandra.Monea#Thiago.Monea#Kely.Souza#Caroline.Monea#Administrador#eulalia.ramos#Talita.Rodrigues#eristeu.junior")
				If !MsgYesNo("Deseja prosseguir com a liberaзгo do desconto maior que 8% do preзo de lista?", "A T E N З В O", "YESNO")
					lRet := .F.
					Break
				EndIf
			Else
				lRet := .F.
				Break
			EndIf

		EndIf

	EndIf


End Sequence

RestArea(aAreaSA1)
RestArea(aAreaSB2)
RestArea(aAreaSC6)
RestArea(aAreaSB1)
RestArea(aArea)

//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅДї
//пїЅ Administrador pode liberar mesmo com avisos emitidos                пїЅ
//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
If !lRet .And.  AllTrim(cUserName) $ SuperGetMv("QE_LIBPED",.F.,"Administrador#Thiago.Monea#Alessandra.Monea#Eunice.Godoy" )
	lRet := MsgYesNo("Confirma a liberacao do pedido mesmo com os avisos emitidos?", "MT440GR")
EndIf

Return lRet
