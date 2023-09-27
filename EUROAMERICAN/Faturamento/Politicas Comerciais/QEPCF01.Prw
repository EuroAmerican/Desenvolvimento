#include "rwmake.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#include "Ap5Mail.ch"
#Include "Tbiconn.ch"
#Include "parmtype.ch"
#Include "Colors.ch"

#define ENTER CHR(13) + CHR(10)

/*
| Função...: QEPCF01()
| Autor....: Paulo Rogerio
| Data.....: 03/07/2023
| Retorno..: Nenhum
| Parametr.: 1. Cliente, 2.Loja, 3.Orçamento, 4.Tipo [1=Individual, 2=Grupo]
| Descricão: Funções Genericas do Projeto de Politicas Comerciais.
| 
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| 1 - Função xCalcMargem - Calculo da Margem de Comtribuição Individual 
|     e em grupo do(s) Orçamento(s). Também calcula o desconto médio do 
|     grupo de orçamentos.
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/


User Function xCalcMargem(aRet, cCliente, cLoja, nDocumento, nTipo, lMsg)
Local _aAreaA1   := SA1->(GetArea())
Local _aAreaF4   := SA1->(GetArea())
Local _aAreaB1   := SA1->(GetArea())
Local _aAreaCJ   := SCJ->(GetArea())
Local _aAreaCK   := SCK->(GetArea())

Local nMargem  := 0
Local nNrItens := 0
Local nItem    := 0

Local nRecno   := 0
Local nTotalNF := 0
Local nTotDesc := 0
Local nTotMerc := 0
Local nDescGrp := 0
Local cLotePrc := ""
Local nTotFret := 0
Local nTotDesp := 0
Local nTotSegu := 0
Local nTotImp  := 0

Local nRecLiq  := 0
Local nCustMed := 0
Local aRelImp  := {}
Local aImpostos:= {}

Local nX       := 0

Local cHolding := ""
Local cObsCusto:= ""
Local lErrCusto:= .F.
Local cQuery   := ""

aRelImp    := MaFisRelImp("MT100",{"SF2","SD2"}) // MaFisRelImp("MT100",{"SF2","SD2"})

dbSelectArea("SA1")
dbsetOrder(1)
dbSeek(xFilial("SA1")+cCliente + cLoja, .F.)

//IF SA1->A1_GRPVEN <> ''
//	cHolding := SA1->A1_GRPVEN
//Endif

//Preenchendo o valor total
dbSelectArea("SCJ")
dbSetOrder(1)
dbSeek(xFilial("SCJ")+nDocumento)

cHolding := SCJ->CJ_XGRPCLI
cLotePrc := SCJ->CJ_XLTPROC

dbSelectArea("SCK")
dbSetOrder(1) // CK_FILIAL, CK_NUM, CK_ITEM, CK_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
dbSeek(xFilial("SCK")+nDocumento)

IF nTipo == 1 
	//----------------------------
	// Analise Individual
	//----------------------------
	nRecno   := SCK->(Recno())
	
	nTotFret := SCJ->CJ_FRETE
	nTotDesp := SCJ->CJ_DESPESA
	nTotSegu := SCJ->CJ_SEGURO

	IF lMsg
		ProcRegua(20)	
	Endif

	Do While !Eof() .And. SCK->(CK_FILIAL + CK_NUM) == xFilial("SCJ")+M->CJ_NUM
		nNrItens++

		nTotalNF += SCK->CK_VALOR
		nTotDesc += SCK->CK_VALDESC
		nTotMerc += SCK->(CK_VALOR + CK_VALDESC)

		// Calcula o Custo Médio
		dbSelectArea("SB2")
		dbSetOrder(1)
		dbSeek(xFilial("SB2")+SCK->(CK_PRODUTO + CK_LOCAL))

		cObsCusto := StrTran(SCK->CK_OBS, "** CUSTO NEGATIVO **"   , "")
		cObsCusto := StrTran(cObsCusto  , "** CUSTO INEXISTENTE **", "")
		lErrCusto := .F.

		// Calcula o Custo Medio do Item no documento
		IF Found()
			IF B2_CM1 < 0
				nCustMed += (999 * SCK->CK_QTDVEN) // Força estouro no custo para redução da MC
				cObsCusto := Alltrim(cObsCusto) + IIF(AT("** CUSTO NEGATIVO **", Alltrim(cObsCusto) )  == 0,  " ** CUSTO NEGATIVO **", "")
				lErrCusto := .T.
			Else
				nCustMed += (B2_CM1 * SCK->CK_QTDVEN)
			Endif
		Else
			nCustMed += (999 * SCK->CK_QTDVEN)    // Força estouro no custo para redução da MC
			cObsCusto := Alltrim(cObsCusto) + IIF(AT("** CUSTO INEXISTENTE **", Alltrim(cObsCusto) )  == 0,  " ** CUSTO INEXISTENTE **", "")
			lErrCusto := .T.
		Endif

		dbSelectArea("SCK")
		IF 	lErrCusto 
			IF !Alltrim(SCK->CK_OBS) == Alltrim(cObsCusto)
				SCK->CK_OBS := 	cObsCusto
			Endif

			MsgAlert("Produto "+Alltrim(SCK->(CK_PRODUTO))+" com custo negativo ou inexistente. Informe a área responsável!","Politica Comerciais")
		Endif

		DbSkip()
	EndDo

	// Calcula o Desconto Médio do Grupo de Orçamento
	nDescGrp := 0 //SCJ->CJ_DESC1 + SCJ->CJ_DESC1

	IF MaFisFound("NF")
		MaFisClear()
		MaFisEnd()
	Endif

	IF ! MaFisFound("NF")
		aFisIni := MaFisIni(SCJ->CJ_CLIENT,;		// 1-Codigo Cliente/Fornecedor
			SCJ->CJ_LOJAENT,;			// 2-Loja do Cliente/Fornecedor
			"C",;	                // 3-C:Cliente , F:Fornecedor
			"N",;			        // 4-Tipo da NF
			SA1->A1_TIPO,;			// 5-Tipo do Cliente/Fornecedor
			aRelImp,;				// 6-Relacao de Impostos que suportados no arquivo
			,;						// 7-Tipo de complemento
			,;						// 8-Permite Incluir Impostos no Rodape .T./.F.
			"SB1",;					// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
			"MATA461")				// 10-Nome da rotina que esta utilizando a funcao - MATA461
	Endif


	MAFISALT("NF_UFDEST"  ,SA1->A1_ESTE) //UF do Destinatario
	MAFISALT("NF_UFORIGEM","SP") 	 //UF de Origem
	MAFISALT("NF_DESCONTO",nTotDesc) //Valor Total do Deconto
	MAFISALT("NF_FRETE"   ,nTotFret) //Valor Total do Frete
	MAFISALT("NF_DESPESA" ,nTotDesp) //Valor Total das Despesas Acessorias
	MAFISALT("NF_SEGURO"  ,nTotSegu) //Valor Total do Seguro
	MAFISALT("NF_TOTAL"   ,nTotalNF) //Valor Total da NF
	MAFISALT("NF_VALMERC" ,nTotMerc) //Total de Mercadorias
	MAFISALT("NF_NATUREZA",SA1->A1_NATUREZ) //Codigo da natureza a ser gravado nos titulos do ?Financeiro.

	dbSelectArea("SCK")
	dbGoto(nRecno)
	
	nItem := 0
	Do While !Eof() .And. SCK->(CK_FILIAL + CK_NUM) == xFilial("SCJ")+SCJ->CJ_NUM
		//Pega os tratamentos de impostos
		dbSelectArea("SB1")
		dbSetOrder(1)
		DbSeek(xFilial("SB1")+SCK->CK_PRODUTO)

		//Pega os tratamentos de impostos
		dbSelectArea("SF4")
		dbSetOrder(1)
		DbSeek(xFilial("SF4")+SCK->CK_TES)

		IF lMsg
			IncProc()	
		Endif

		nItem++

/*		
		IF ! MaFisFound("IT", nItem)
			MaFisAdd(   SCK->CK_PRODUTO,;                     // 1-Codigo do Produto                 ( Obrigatorio )
						SCK->CK_TES,;                         // 2-Codigo do TES                     ( Opcional )
						SCK->CK_QTDVEN,;                      // 3-Quantidade                     ( Obrigatorio )
						SCK->CK_PRCVEN,;                      // 4-Preco Unitario                 ( Obrigatorio )
						SCK->CK_VALDESC,;                     // 5 desconto
						"",;                     			  // 6-Numero da NF Original             ( Devolucao/Benef )
						"",;                    			  // 7-Serie da NF Original             ( Devolucao/Benef )
						0,;                                   // 8-RecNo da NF Original no arq SD1/SD2
						nTotFret/nNrItens,;              	  // 9-Valor do Frete do Item         ( Opcional )
						nTotDesp/nNrItens,;            		  // 10-Valor da Despesa do item         ( Opcional )
						nTotSegu/nNrItens,;             	  // 11-Valor do Seguro do item         ( Opcional )
						0,;                                   // 12-Valor do Frete Autonomo         ( Opcional )
						SCK->CK_VALOR + SCK->CK_VALDESC,;     // 13-Valor da Mercadoria             ( Obrigatorio )
						0,;                                   // 14-Valor da Embalagem             ( Opcional )
						0,;                                   // 15-RecNo do SB1
						0)                                    // 16-RecNo do SF4
		Else
			MaFisAlt("IT_QUANT"   ,SCK->CK_QTDVEN   , nItem)
			MaFisAlt("IT_TES"     ,SCK->CK_TES      , nItem)
			MaFisAlt("IT_PRCUNI"  ,SCK->CK_PRCVEN   , nItem)
			MaFisAlt("IT_DESCONTO",SCK->CK_VALDESC  , nItem)
			MaFisAlt("IT_FRETE"   ,nTotFret/nNrItens, nItem)
			MaFisAlt("IT_DESPESA" ,nTotDesp/nNrItens, nItem)
			MaFisAlt("IT_SEGURO"  ,nTotSegu/nNrItens, nItem)
			MaFisAlt("IT_VALMERC",SCK->CK_VALOR + SCK->CK_VALDESC, nItem)
		Endif
*/

		IF ! MaFisFound("IT", nItem)
			MaFisAdd(   SCK->CK_PRODUTO,;                     // 1-Codigo do Produto                 ( Obrigatorio )
						SCK->CK_TES,;                         // 2-Codigo do TES                     ( Opcional )
						SCK->CK_QTDVEN,;                      // 3-Quantidade                     ( Obrigatorio )
						SCK->CK_PRCVEN,;                      // 4-Preco Unitario                 ( Obrigatorio )
						SCK->CK_VALDESC,;                     // 5 desconto
						"",;                     			  // 6-Numero da NF Original             ( Devolucao/Benef )
						"",;                    			  // 7-Serie da NF Original             ( Devolucao/Benef )
						0,;                                   // 8-RecNo da NF Original no arq SD1/SD2
						SCK->CK_XVALFRE,;              	  // 9-Valor do Frete do Item         ( Opcional )
						SCK->CK_XVALDSP,;            		  // 10-Valor da Despesa do item         ( Opcional )
						SCK->CK_XVALSEG,;             	  // 11-Valor do Seguro do item         ( Opcional )
						0,;                                   // 12-Valor do Frete Autonomo         ( Opcional )
						SCK->CK_VALOR + SCK->CK_VALDESC,;     // 13-Valor da Mercadoria             ( Obrigatorio )
						0,;                                   // 14-Valor da Embalagem             ( Opcional )
						0,;                                   // 15-RecNo do SB1
						0)                                    // 16-RecNo do SF4
		Else
			MaFisAlt("IT_QUANT"   ,SCK->CK_QTDVEN   , nItem)
			MaFisAlt("IT_TES"     ,SCK->CK_TES      , nItem)
			MaFisAlt("IT_PRCUNI"  ,SCK->CK_PRCVEN   , nItem)
			MaFisAlt("IT_DESCONTO",SCK->CK_VALDESC  , nItem)
			MaFisAlt("IT_FRETE"   ,SCK->CK_XVALFRE  , nItem)
			MaFisAlt("IT_DESPESA" ,SCK->CK_XVALDSP  , nItem)
			MaFisAlt("IT_SEGURO"  ,SCK->CK_XVALSEG  , nItem)
			MaFisAlt("IT_VALMERC",SCK->CK_VALOR + SCK->CK_VALDESC, nItem)
		Endif

		dbSelectArea("SCK")
		DbSkip()
	EndDo

	// Efetua o Calculo da Base da Margem 
	aImpostos := MaFisNfCab()

	// Deduz os Impostos
	For nX := 1 to Len(aImpostos)
		IF Left(Alltrim(aImpostos[nX][1]), 3) $ "ICM/PS2/CF2"
			IF aImpostos [nX][5] <> 0
				nTotImp += aImpostos [nX][5]
			Endif
		Endif
	Next
Else  
	//----------------------------
	// Analise por Holding
	//----------------------------

	/*
	cQuery := "SELECT DISTINCT * "+ENTER
	cQuery += " FROM ("+ENTER
	cQuery += "      SELECT CJ_FILIAL, CJ_NUM, CJ_CLIENT, CJ_LOJAENT,SCJ.R_E_C_N_O_ AS CJ_RECNO, A1_GRPVEN"+ENTER
	cQuery += "	       FROM "+RetSqlName("SCJ")+" AS SCJ WITH(NOLOCK)"+ENTER
	cQuery += "	      INNER JOIN "+RetSqlName("SA1")+" AS SA1 ON SA1.D_E_L_E_T_ = '' AND A1_FILIAL = CJ_FILIAL AND A1_COD = CJ_CLIENT AND A1_LOJA = CJ_LOJAENT AND A1_GRPVEN = '"+cHolding+"'"+ENTER
	cQuery += "       WHERE SCJ.D_E_L_E_T_ = ''"+ENTER
   	cQuery += "         AND CJ_FILIAL = '"+xFilial("SCJ")+"'"+ENTER
	cQuery += "         AND CJ_VALIDA >= '"+dtos(dDataBase)+"'"+ENTER
	cQuery += "         AND CJ_STATUS = 'A'"+ENTER
	cQuery += "         AND CJ_XMCIND <> 0"+ENTER 
	cQuery += "         AND CJ_XLTPROC = '"+cLotePrc+"'"+ENTER
	cQuery += "      ) AS QRY"+ENTER 
	*/

	//cQuery := "SELECT DISTINCT * "+ENTER
	//Query += " FROM ("+ENTER

	cQuery := ''
	cQuery += "      SELECT CJ_FILIAL, CJ_XGRPCLI,  CJ_NUM, CJ_FRETE, CJ_DESPESA, CJ_SEGURO, CJ_XCUSTO, CJ_XTOTIMP, "+ENTER
	cQuery += "		        SUM(CK_VALOR)   AS CK_VALOR,  "+ENTER
	cQuery += "		        SUM(CK_VALDESC) AS CK_VALDESC,  "+ENTER
	cQuery += "		        SUM(CK_VALOR + CK_VALDESC) AS CK_VALMERC "+ENTER
	cQuery += "	       FROM "+RetSqlName("SCJ")+" AS SCJ WITH(NOLOCK)"+ENTER
	cQuery += "	      INNER JOIN "+RetSqlName("SCK")+" AS SCK WITH(NOLOCK) ON SCK.D_E_L_E_T_ = '' AND CK_FILIAL = CJ_FILIAL AND CK_NUM = CJ_NUM"+ENTER
	cQuery += "       WHERE SCJ.D_E_L_E_T_ = ''"+ENTER
   	cQuery += "         AND CJ_FILIAL = '"+xFilial("SCJ")+"'"+ENTER
	cQuery += "         AND CJ_VALIDA >= '"+dtos(dDataBase)+"'"+ENTER
	cQuery += "         AND CJ_STATUS = 'A'"+ENTER
	cQuery += "         AND CJ_XMCIND <> 0"+ENTER 
	cQuery += "         AND CJ_XGRPCLI = '"+cHolding+"'"+ENTER 
	cQuery += "         AND CJ_XLTPROC = '"+cLotePrc+"'"+ENTER
	cQuery += "       GROUP BY CJ_FILIAL, CJ_XGRPCLI,  CJ_NUM, CJ_FRETE, CJ_DESPESA, CJ_SEGURO, CJ_XCUSTO, CJ_XTOTIMP"+ENTER 

	//cQuery += "      ) AS QRY"+ENTER 
	
    IF Select("TMPO")
        TMPO->(dbCloseArea())
    Endif

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMPO", .F., .T.)
    dbSelectArea("TMPO")
	dbGotop()

	IF lMsg
		ProcRegua(TMPO->(LastRec() * 10))	
	Endif

	Do While !Eof()
		nTotFret += TMPO->CJ_FRETE
		nTotDesp += TMPO->CJ_DESPESA
		nTotSegu += TMPO->CJ_SEGURO     
		nCustMed += TMPO->CJ_XCUSTO
		nTotImp  += TMPO->CJ_XTOTIMP

		nTotalNF += TMPO->CK_VALOR
		nTotDesc += TMPO->CK_VALDESC
		nTotMerc += TMPO->CK_VALMERC

		/*
		dbSelectArea("SCJ")
		dbSetOrder(1)
		dbSeek(xFilial("SCJ")+TMPO->CJ_NUM)

		nTotFret += SCJ->CJ_FRETE
		nTotDesp += SCJ->CJ_DESPESA
		nTotSegu += SCJ->CJ_SEGURO     
		nCustMed += SCJ->CJ_XCUSTO
		nTotImp  += SCJ->CJ_XTOTIMP

		nTotalNF += TMPO->CK_VALOR
		nTotDesc += TMPO->CK_VALDESC
		nTotMerc += TMPO->CK_VALMERC
		*/

		/*
		dbSelectArea("SCK")
		dbSetOrder(1) // CK_FILIAL, CK_NUM, CK_ITEM, CK_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
		dbSeek(xFilial("SCK")+TMPO->CJ_NUM)

		Do While !Eof() .And. SCK->(CK_FILIAL + CK_NUM) == xFilial("SCJ")+TMPO->CJ_NUM
			nNrItens++

			nTotalNF += SCK->CK_VALOR
			nTotDesc += SCK->CK_VALDESC
			nTotMerc += SCK->(CK_VALOR + CK_VALDESC)

			DbSkip()
		EndDo
		*/

		dbSelectArea("TMPO")
		dbSkip()
	Enddo

	// Calcula o Desconto Médio do Grupo de Orçamento
	nDescGrp := (1-(nTotalNF / nTotMerc))*100
Endif

/*
// Efetua o Calculo da Base da Margem 
aImpostos := MaFisNfCab()

// Deduz os Impostos
For nX := 1 to Len(aImpostos)
	IF Left(Alltrim(aImpostos[nX][1]), 3) $ "ICM/PS2/CF2"
		IF aImpostos [nX][5] <> 0
			nTotImp += aImpostos [nX][5]
		Endif
	Endif
Next
*/

nRecLiq   := nTotMerc - nTotDesp - nTotFret  - nTotSegu - nTotDesc - nTotImp //nBaseMC := nTotMerc - SCJ->CJ_DESPESA - SCJ->CJ_FRETE - nTotDesc - SCJ->CJ_SEGURO
nMargem   := ((nRecLiq - nCustMed) / nRecLiq) * 100

Aadd(aRet, nCustMed) // Custo Médio do Orçamento
Aadd(aRet, nTotImp)  // Total de Impostos 
Aadd(aRet, nMargem)  // Margem de Contribuição
Aadd(aRet, nDescGrp) // Desconto Médiio do Grupo

RestArea(_aAreaA1)
RestArea(_aAreaF4)
RestArea(_aAreaB1)
RestArea(_aAreaCK)
RestArea(_aAreaCJ)
Return()



/*
| Função...: xCalcMCItem()
| Autor....: Paulo Rogerio
| Data.....: 18/09/2023
| Retorno..: Nenhum
| Parametr.: 1. Cliente, 2.Loja, 3.Orçamento, 4.Item
| Descricão: Funções Genericas do Projeto de Politicas Comerciais.
| 
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| 1 - Função xCalcMCItem - Calcular e gravar a Margem de Contribuição, custo e
|     impostos do orçamento.
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/


User Function xCalcMCItem(cCliente, cLoja, nDocumento, nItem)
Local _aAreaA1   := SA1->(GetArea())
Local _aAreaF4   := SA1->(GetArea())
Local _aAreaB1   := SA1->(GetArea())
Local _aAreaCJ   := SCJ->(GetArea())
Local _aAreaCK   := SCK->(GetArea())

Local nMargem  := 0

Local nRecno   := 0
Local nTotalNF := 0
Local nTotDesc := 0
Local nTotMerc := 0

Local nTotFret := 0
Local nTotDesp := 0
Local nTotSegu := 0
Local nTotImp  := 0

Local nVlrNota := 0
Local nVlrDesc := 0
Local nVlrMerc := 0

Local nVlrFret  := 0
Local nVlrDesp  := 0
Local nVlrSegu  := 0

Local nRecLiq  := 0
Local nCustMed := 0
Local aRelImp  := {}
Local aImpostos:= {}

Local nX       := 0
Local nIdItem  := 0
Local nNrItens := 0

Local cAlias   := "TMP"
Local cObsCusto:= ""
Local cCondicao:= ""
Local cDelete  := ""

IF Valtype(M->CJ_FRETE) <> "U"
	nTotFret :=  M->CJ_FRETE   
	nTotDesp :=  M->CJ_DESPESA 
	nTotSegu :=  M->CJ_SEGURO   
Else
	nTotFret :=  SCJ->CJ_FRETE   
	nTotDesp :=  SCJ->CJ_DESPESA 
	nTotSegu :=  SCJ->CJ_SEGURO  
Endif

aRelImp    := MaFisRelImp("MT100",{"SF2","SD2"}) // MaFisRelImp("MT100",{"SF2","SD2"})

dbSelectArea("SA1")
dbsetOrder(1)
dbSeek(xFilial("SA1")+cCliente + cLoja, .F.)

If nItem > 0
	nIdItem   := nItem 
	cAlias    := "TMP1"
    cCondicao := "TMP1->(Recno()) == nRecno .AND. !Eof()"
	cDelete   := ".not. CK_FLAG"

	nRecno    := TMP1->(Recno())

	dbSelectArea("TMP1")
	dbGotop()
Else
	nIdItem   := 1
	cAlias    := "SCK"
    cCondicao := "!Eof() .And. SCK->CK_FILIAL + SCK->CK_NUM == SCJ->CJ_FILIAL + SCJ->CJ_NUM"
	cDelete   := ".not. Deleted()"

	dbSelectArea("SCK")
	dbSetOrder(1) // CK_FILIAL, CK_NUM, CK_ITEM, CK_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
	dbSeek(xFilial("SCK")+SCJ->CJ_NUM) // dbSeek(xFilial("SCK")+nDocumento)

	nRecno    := SCK->(Recno())
EndIf

nNrItens  := 0

nTotalNF := 0
nTotDesc := 0
nTotMerc := 0

// Conta registros ativos no orçamento e
// soma totais.
Do While &(cCondicao) //!Eof()
	IF &(cDelete)
		nNrItens++

		nTotalNF  += (cAlias)->CK_VALOR
		nTotDesc  += (cAlias)->CK_VALDESC 
		nTotMerc  += nTotalNF + nTotDesc
	Endif 

	dbSkip()
Enddo

dbGoto(nRecno)

Do While &(cCondicao) //!Eof() .And. (cAlias)->(CK_FILIAL + CK_NUM) == xFilial("SCJ")+nDocumento
	IF ! &(cDelete)
		// Deduz os Impostos
		Reclock(cAlias, .F.)
		(cAlias)->CK_XVALIPI := 0
		(cAlias)->CK_XVALIST := 0

		(cAlias)->CK_XVALFRE := 0
		(cAlias)->CK_XVALDSP := 0
		(cAlias)->CK_XVALSEG := 0	

		(cAlias)->CK_XCUSTM  := 0
		(cAlias)->CK_XMC     := 0
		(cAlias)->CK_XTOTIMP := 0
		MsUnlock()

		dbSkip()
		Loop
	Endif 

    //(Valor do produto / Valor total dos produtos) x Valor do frete = Valor do rateio
	nVlrFret := ((cAlias)->CK_VALOR / nTotalNF) * nTotFret  
	nVlrDesp := ((cAlias)->CK_VALOR / nTotalNF) * nTotDesp 
	nVlrSegu := ((cAlias)->CK_VALOR / nTotalNF) * nTotSegu   

	nVlrNota := (cAlias)->CK_VALOR
	nVlrDesc := (cAlias)->CK_VALDESC
	nVlrMerc := (cAlias)->(CK_VALOR + CK_VALDESC)

	// Calcula o Custo Médio
	dbSelectArea("SB2")
	dbSetOrder(1)
	dbSeek(xFilial("SB2")+(cAlias)->(CK_PRODUTO + CK_LOCAL))

	cObsCusto := StrTran((cAlias)->CK_OBS, "** CUSTO NEGATIVO **"  , "")
	cObsCusto := StrTran((cAlias)->CK_OBS, "** CUSTO INEXISTENTE **", "")

	// Calcula o Custo Medio do Item no documento
	IF Found()
		nCustMed  := (B2_CM1 * (cAlias)->CK_QTDVEN)

		IF nCustMed < 0
			cObsCusto := Alltrim(cObsCusto) + IIF(AT("** CUSTO NEGATIVO **", Alltrim(cObsCusto) )  == 0,  " ** CUSTO NEGATIVO **", "")
		Endif
	Else
		nCustMed  := -999
		cObsCusto := Alltrim(cObsCusto) + IIF(AT("** CUSTO INEXISTENTE **", Alltrim(cObsCusto) )  == 0,  " ** CUSTO INEXISTENTE **", "")
	Endif

	dbSelectArea("SCK")
	IF !Alltrim((cAlias)->CK_OBS) == Alltrim(cObsCusto)
		MsgAlert("Produto "+Alltrim((cAlias)->(CK_PRODUTO))+" com custo negativo ou inexistente. Informe a área responsável!","Politica Comerciais")
	Endif

	IF MaFisFound("NF")
		MaFisClear()
		MaFisEnd()
	Endif

	IF ! MaFisFound("NF")
		aFisIni := MaFisIni(cCliente,;		// 1-Codigo Cliente/Fornecedor
			cLoja,;					// 2-Loja do Cliente/Fornecedor
			"C",;	                // 3-C:Cliente , F:Fornecedor
			"N",;			        // 4-Tipo da NF
			SA1->A1_TIPO,;			// 5-Tipo do Cliente/Fornecedor
			aRelImp,;				// 6-Relacao de Impostos que suportados no arquivo
			,;						// 7-Tipo de complemento
			,;						// 8-Permite Incluir Impostos no Rodape .T./.F.
			"SB1",;					// 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
			"MATA461")				// 10-Nome da rotina que esta utilizando a funcao - MATA461
	Endif

	MAFISALT("NF_UFDEST"  ,SA1->A1_ESTE) //UF do Destinatario
	MAFISALT("NF_UFORIGEM","SP") 	 //UF de Origem
	MAFISALT("NF_DESCONTO",nTotDesc) //Valor Total do Deconto
	MAFISALT("NF_FRETE"   ,nTotFret) //Valor Total do Frete
	MAFISALT("NF_DESPESA" ,nTotDesp) //Valor Total das Despesas Acessorias
	MAFISALT("NF_SEGURO"  ,nTotSegu) //Valor Total do Seguro
	MAFISALT("NF_TOTAL"   ,nTotalNF) //Valor Total da NF
	MAFISALT("NF_VALMERC" ,nTotMerc) //Total de Mercadorias
	MAFISALT("NF_NATUREZA",SA1->A1_NATUREZ) //Codigo da natureza a ser gravado nos titulos do ?Financeiro.


	//Pega os tratamentos de impostos
	dbSelectArea("SB1")
	dbSetOrder(1)
	DbSeek(xFilial("SB1")+(cAlias)->CK_PRODUTO)

	//Pega os tratamentos de impostos
	dbSelectArea("SF4")
	dbSetOrder(1)
	DbSeek(xFilial("SF4")+(cAlias)->CK_TES)

	IF ! MaFisFound("IT", nIdItem)
		MaFisAdd(   (cAlias)->CK_PRODUTO,;                // 1-Codigo do Produto                 ( Obrigatorio )
					(cAlias)->CK_TES,;                    // 2-Codigo do TES                     ( Opcional )
					(cAlias)->CK_QTDVEN,;                 // 3-Quantidade                     ( Obrigatorio )
					(cAlias)->CK_PRCVEN,;                 // 4-Preco Unitario                 ( Obrigatorio )
					(cAlias)->CK_VALDESC,;                // 5 desconto
					"",;                     			  // 6-Numero da NF Original             ( Devolucao/Benef )
					"",;                    			  // 7-Serie da NF Original             ( Devolucao/Benef )
					0,;                                   // 8-RecNo da NF Original no arq SD1/SD2
					nVlrFret,;              	          // 9-Valor do Frete do Item         ( Opcional )
					nVlrDesp,;            		          // 10-Valor da Despesa do item         ( Opcional )
					nVlrSegu,;             	              // 11-Valor do Seguro do item         ( Opcional )
					0,;                                   // 12-Valor do Frete Autonomo         ( Opcional )
					nVlrMerc,;                            // 13-Valor da Mercadoria             ( Obrigatorio )
					0,;                                   // 14-Valor da Embalagem             ( Opcional )
					0,;                                   // 15-RecNo do SB1
					0)                                    // 16-RecNo do SF4
	Else
		MaFisAlt("IT_QUANT"   ,(cAlias)->CK_QTDVEN   , nIdItem)
		MaFisAlt("IT_TES"     ,(cAlias)->CK_TES      , nIdItem)
		MaFisAlt("IT_PRCUNI"  ,(cAlias)->CK_PRCVEN   , nIdItem)
		MaFisAlt("IT_DESCONTO",(cAlias)->CK_VALDESC  , nIdItem)
		MaFisAlt("IT_FRETE"   ,nVlrFret, nIdItem)
		MaFisAlt("IT_DESPESA" ,nVlrDesp, nIdItem)
		MaFisAlt("IT_SEGURO"  ,nVlrSegu, nIdItem)
		MaFisAlt("IT_VALMERC" ,nVlrMerc, nIdItem)
	Endif

	// Efetua o Calculo da Base da Margem 
	aImpostos := MaFisNfCab()

	// Deduz os Impostos
	Reclock(cAlias, .F.)
	For nX := 1 to Len(aImpostos)
		IF Left(Alltrim(aImpostos[nX][1]), 3) $ "ICM/PS2/CF2"
			IF aImpostos [nX][5] <> 0
				nTotImp += aImpostos [nX][5]
			Endif

		ElseIF Left(Alltrim(aImpostos[nX][1]), 3) $ "IPI"
			(cAlias)->CK_XVALIPI := aImpostos [nX][5]

		ElseIF Left(Alltrim(aImpostos[nX][1]), 3) $ "ICR"
			(cAlias)->CK_XVALIST := aImpostos [nX][5]
		Endif
	Next

	IF nCustMed >= 0
		nRecLiq   := nVlrMerc - nVlrDesp - nVlrFret  - nVlrSegu - nVlrDesc - nTotImp 
		nMargem   := ((nRecLiq - nCustMed) / nRecLiq) * 100
	Else
		nMargem   := -999.99
	Endif


	(cAlias)->CK_XVALFRE := nTotFret 
	(cAlias)->CK_XVALDSP := nTotDesp 
	(cAlias)->CK_XVALSEG := nTotSegu 	

	(cAlias)->CK_XCUSTM  := nCustMed
	(cAlias)->CK_XMC     := nMargem
	(cAlias)->CK_XTOTIMP := nTotImp
	(cAlias)->CK_OBS     := cObsCusto
	MsUnlock()

	nIdItem++

	dbSelectArea(cAlias)
	DbSkip()
EndDo


dbGoto(nRecno)

If Type("oGetDad") <> "U" .And. nItem > 0
	oGetDad:oBrowse:Refresh()
EndIf


RestArea(_aAreaA1)
RestArea(_aAreaF4)
RestArea(_aAreaB1)
RestArea(_aAreaCJ)
RestArea(_aAreaCK)
Return()


/*
| Função...: xGrvMixCF()
| Autor....: Paulo Rogerio
| Data.....: 07/07/2023
| Retorno..: Nenhum
| Descricão: Calcular e Grava os Descontos MIX e Carga Fechada no Orçamento.
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User Function xGrvMixCF(cGrupoCli, cLotePrc) // (cCliente, cLoja)
Local _aAreaA1   := SA1->(GetArea())
Local _aAreaACY  := ACY->(GetArea())
Local _aAreaCJ   := SCJ->(GetArea())
Local _aAreaCK   := SCK->(GetArea())

Local cQuery   := ""
Local nExec    := 0
Local cChave   := ""
Local aPedidos := {}
Local cOrder   := ""
Local cJoinSA1 := ""
Local nDescMix := 0
Local nDescCF  := 0
 
Local lDescMix := .F.
Local lDescCF  := .F.
Local cHolding := ""
Local cWhile   := ""

Local nPercCF  := GETMV( "QE_PERCCF") // ,,  2)
Local nPesoCMI := GETMV( "QE_CARGAMI")//,, 14000)
Local nPercMIX := GETMV( "QE_PERCMIX")//,, 2)
Local nVlrMIX  := GETMV( "QE_VLRMIX") // ,, 7.5)
Local aTotais  := {}

//------------------------------------------------------------------
// Executa o Processo de Liberação duas vezes, sendo: uma apenas
// para pedidos individuais e outra para holdings.
//------------------------------------------------------------------
//For nExec := 1 to 1
    cQuery   := ""

    //-------------------------------------------------------------------
    // Query para calcular o volume de litros e peso bruto total dos 
    // orçamentos da holding.
    //-------------------------------------------------------------------

    cQuery += "       SELECT CJ_FILIAL, CJ_XGRPCLI, SUM(CK_QTDVEN * B1_CONV) AS CJ_LITROS, SUM(CK_QTDVEN * B1_PESBRU) AS CJ_PBRUTO, SUM(CK_VALOR) AS CJ_TOTAL"+ENTER

    cQuery += "	        FROM "+RetSqlName("SCJ")+" AS SCJ WITH(NOLOCK)"+ENTER
    cQuery += "	        INNER JOIN "+RetSqlName("SCK")+" AS SCK WITH(NOLOCK) ON SCK.D_E_L_E_T_ = '' AND CK_FILIAL = CJ_FILIAL AND CK_CLIENTE = CJ_CLIENT AND CK_LOJA = CJ_LOJA AND CK_NUM = CJ_NUM"+ENTER
    cQuery += "	        INNER JOIN "+RetSqlName("SB1")+" AS SB1 ON B1_COD = CK_PRODUTO AND SB1.D_E_L_E_T_ = ''
    
    cQuery += "         WHERE SCJ.D_E_L_E_T_ = ''"+ENTER
    cQuery += "           AND CJ_FILIAL = '"+xFilial("SCJ")+"'"+ENTER 
    cQuery += "           AND CJ_VALIDA >= '"+dtos(dDataBase)+"'"+ENTER
    cQuery += "           AND CJ_XGRPCLI =  '"+cGrupoCli+"'"+ENTER

	IF !empty(cLotePrc)
		cQuery += "           AND CJ_XLTPROC = '"+cLotePrc+"' "+ENTER
	Endif

    cQuery += "           AND CJ_STATUS = 'A'"+ENTER
    cQuery += "         GROUP BY CJ_FILIAL, CJ_XGRPCLI"
    
    cQuery += cOrder + ENTER

    IF Select("TMPO")
        TMPO->(dbCloseArea())
    Endif

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMPO", .F., .T.)
    dbSelectArea("TMPO")
    dbGotop()

    aPedidos := {}
    aTotais  := {}

    // Guarda os totais, pesos e litros por grupo de pedidos
    Do While  !Eof()
        Aadd(aTotais, {TMPO->CJ_XGRPCLI,;                           // 1-Grupo / Cliente
                       TMPO->CJ_TOTAL,;                             // 2-Valor Total dos Pedidos do Grupo
                       TMPO->CJ_LITROS,;                            // 3-Total de Litros dos Pedidos do Grupo
                       TMPO->CJ_PBRUTO,;                            // 4-Peso Bruto total dos Pedidos do Grupo
                       Round(TMPO->CJ_TOTAL / TMPO->CJ_LITROS,2)})  // 5-Valor do MIX pelos totais do Grupo
        dbSkip()
    Enddo
    
    dbCloseArea()

    //-------------------------------------------------------------------
    // Query para identificar os pedidos e analisar suas caracteristicas 
    // individualmente.
    //-------------------------------------------------------------------
    cQuery := "" 
    cQuery += "       SELECT CJ_FILIAL, CJ_NUM, CJ_CLIENT, CJ_LOJAENT, CJ_XGRPCLI"+ENTER
    cQuery += "	        FROM "+RetSqlName("SCJ")+" AS SCJ WITH(NOLOCK)"+ENTER

    cQuery += "         WHERE SCJ.D_E_L_E_T_ = ''"+ENTER
    cQuery += "           AND CJ_FILIAL = '"+xFilial("SCJ")+"'"+ENTER 
    cQuery += "           AND CJ_VALIDA >= '"+dtos(dDataBase)+"'"+ENTER
    cQuery += "           AND CJ_XGRPCLI  = '"+cGrupoCli+"'"+ENTER
    cQuery += "           AND CJ_STATUS  = 'A'"+ENTER
    cQuery += " ORDER BY CJ_FILIAL, CJ_XGRPCLI, CJ_CLIENT, CJ_LOJAENT, CJ_NUM"

    IF Select("ORCA")
        ORCA->(dbCloseArea())
    Endif

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "ORCA", .F., .T.)
    dbSelectArea("ORCA")
    dbGotop()    

    Do While !Eof()
		cHolding:= Alltrim(ORCA->CJ_XGRPCLI)
		cChave  := ORCA->CJ_FILIAL + ORCA->CJ_XGRPCLI
		cWhile  := "ORCA->CJ_FILIAL + ORCA->CJ_XGRPCLI == cChave"

        lDescMix := .F.
        lDescCF  := .F.
        nDescMix := 0
        nDescCF  := 0
        aPedidos := {}
    
        Do While &cWhile .and. !Eof() 
            IF Right(ORCA->CJ_XGRPCLI, 2) == "XX" // Individual
                dbSelectArea("SA1")    
                dbSetOrder(1)    
                dbSeek(xFilial("SA1")+ORCA->(CJ_CLIENT))

                lDescMix := SA1->A1_ZDSCMIX == "S"
                lDescCF  := SA1->A1_ZDSCCF  == "S"
            Else          // Holding
                dbSelectArea("ACY")    
                dbSetOrder(1)     
                dbSeek(xFilial("ACY")+cHolding) 

                lDescMix := ACY->ACY_ZDSCMI == "S"
                lDescCF  := ACY->ACY_ZDSCCF == "S"
            Endif

            dbSelectArea("SCJ")
            dbSetOrder(1)
            dbSeek(xFilial("SCJ")+ORCA->CJ_NUM)         

            // Posiciona os Totais do Grupo de Pedidos em Analise
            nPesq := Ascan(aTotais, {|X| Alltrim(X[1]) == Alltrim(cHolding)})

            //-------------------------------------------------------
            // Grava os Descontos MIX e Carga Fechada nos Orçamentos.
            //-------------------------------------------------------
            RecLock('SCJ',.F.)
            SCJ->CJ_XDESMIX  := IIF(lDescMix .And. aTotais[nPesq][5] >= nVlrMIX , nPercMIX, 0)
            SCJ->CJ_XDESCF   := IIF(lDescCF  .And. aTotais[nPesq][4] >= nPesoCMI, nPercCF , 0)

			// Atualiza o campo de Total de Desconto
			SCJ->CJ_DESC1   := SCJ->CJ_XDESSCO + SCJ->CJ_XDESFIN + SCJ->CJ_XDESLOG +  SCJ->CJ_XDESMIX + SCJ->CJ_XDESCF 
            MsUnlock()

			//-----------------------------------------------------------------
			// [INICIO ] - Atualiza o total de desconto nos itens do Orçamento
			//-----------------------------------------------------------------
			U_xCalcDesc("SCK", .F.)

			/*
			dbSelectArea("SCK")
			dbSetOrder(1)
			dbSeek(xFilial("SCK")+SCJ->CJ_NUM)			

			Do While !Eof() .And. SCK->CK_FILIAL + SCK->CK_NUM == SCJ->CJ_FILIAL + SCJ->CJ_NUM
				If SCK->CK_PRUNIT > 0 
					nPrcLst  := SCK->CK_PRUNIT 
					nDesAdc  := IIF(Empty(SCK->CK_XDESADC), 0, SCK->CK_XDESADC)

					nPerDesc := Round(nDesc1/100 , 3)
					nPerAdic := Round(nDesAdc/100, 3)
					nPerTota := nPerDesc + nPerAdic

					nTotDesc := A410Arred((nPrcLst  *  SCK->CK_QTDVEN) * nPerTota,"D2_TOTAL",nMoeda)
					nPrcVen  := A410Arred(nPrcLst * (1-nPerTota),"D2_TOTAL",nMoeda)
					
					Reclock("SCK", .F.)
					
					SCK->CK_PRCVEN := nPrcVen
					SCK->CK_VALOR  := A410Arred(nPrcVen  *  (cAlias)->CK_QTDVEN, "CK_VALOR")
					SCK->CK_DESCONT:= A410Arred(nDesc1,  "CK_DESCONT")
					SCK->CK_VALDESC:= A410Arred(nTotDesc,  "CK_VALDESC")

					MsUnlock()

					nOrcTotVnd += A410Arred(nPrcLst  * SCK->CK_QTDVEN,"CK_VALOR")
					nOrcResult += SCK->CK_VALOR
					nOrcTotDes := nOrcTotVnd - nOrcResult 
				EndIf

				dbSelectArea("SCK")
				dbSkip()
			EndDo
			*/

			//-----------------------------------------------------------------
			// [TERMINO] - Atualiza o total de desconto nos itens do Orçamento
			//-----------------------------------------------------------------

            dbSelectArea("ORCA")
            dbSkip()
        Enddo
    Enddo 

    dbCloseArea()
//Next

RestArea(_aAreaA1)
RestArea(_aAreaACY)
RestArea(_aAreaCK)
RestArea(_aAreaCJ)
Return 

/*/{Protheus.doc} QEMAIL08 
//Função de Envio de e-mail QUALY 
@author Fabio Carneiro dos Santos 
@since 09/03/2022
@version 1.0
/*/

/*
| Função...: xEnvMail()
| Autor....: Paulo Rogerio
| Data.....: 07/07/2023
| Retorno..: Nenhum
| Descricão: Envio de email
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User Function xEnvMail(cRecebe,cCopia,cAssunto,cMensagem,cFile,lDisplay)
// PRS ************************** FPrepEnv("10","0803")

Private cServer   := GetMV("MV_RELSERV")
Private cAccount  := GetMV("MV_RELACNT")
Private cEnvia    := GetMV("MV_RELACNT")
Private cPassword := GetMV("MV_RELPSW")

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lConectou

If lConectou
	MAILAUTH(cAccount,cPassword)     //Esta função faz a autenticação no servidor
   If lDisplay
	   //Alert("Conectado com servidor - " + cServer)
   Endif
Else
	cError := ""
	GET MAIL ERROR cError
	If lDisplay
	   Alert(cError+" no Servidor SMTP")
	Endif
Endif

//Procurar e-mail do usuário
Email  	 := "workflow@qualyvinil.com.br"
If !Empty(Email)
	cRem   := "EUROAMERICAN"/*AllTrim(cNomeUsr)*/+" <"+cEnvia+">"
	If !Email$cRecebe
		//cCopia := Email 
		cCopia := Email
	EndIf
Else
	cRem := "QUALYCRYL"/*AllTrim(cNomeUsr)*/+" <"+GetMV("MV_RELFROM")+">"
	cCopia := "fabio.santos@euroamerican.com.br"
EndIF


If !Empty(cRem)
	cEnvia := cRem
EndIf

If !Empty(cFile) 
   SEND MAIL FROM cEnvia;
	     TO cRecebe;
	     CC cCopia ;
	     SUBJECT cAssunto;
	     BODY cMensagem;
         ATTACHMENT cFile;
	     FORMAT TEXT;
	     RESULT lEnviado
Else	     
	SEND MAIL FROM cEnvia;
	     TO cRecebe;
	     CC cCopia ;
	     SUBJECT cAssunto;
	     BODY cMensagem;
	     FORMAT TEXT;
	     RESULT lEnviado
Endif	     

If lEnviado
   If lDisplay  
	//aviso("Envio E-mail!","Enviado e-mail para analise " + cRecebe,{"OK"})
   Endif

   Conout("*** Enviado e-mail para analise. ")
Else
	GET MAIL ERROR cMensagem 
	If lDisplay
	   Alert(cMensagem+":"+cAssunto)
	Endif                         
	Return .F.
Endif
   
DISCONNECT SMTP SERVER Result lDisConectou

If lDisConectou
   If lDisplay
//	   Alert("Desconectado do servidor - " + cServer)
   Endif
Endif

Return  .T.
