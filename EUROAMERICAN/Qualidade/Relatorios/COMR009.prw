#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
#include "RWMAKE.CH" 

#define ENTER		CHR(13)+CHR(10)
        
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ COMR009  ºAutor  ³Alexandre Marson    º Data ³  29/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ EXCEL - DEMONSTRATIVO MENSAL DE DESEMPENHO DE FORNECIMENTO º±±
±±º          ³ *** IQF ***                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                     A L T E R A C O E S                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ºProgramador       ºAlteracoes                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          º                  º                                         º±±
±±º          º                  º                                         º±±
±±º          º                  º                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function COMR009()
Local aArea		  := GetArea()  

Private cQry      := ""    
Private cPerg     := "COMR009"
Private cNomeProg := "COMR009"
Private cTitulo   := "Demonstrativo Mensal de Desempenho de Fornecimento"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta dicionario de Perguntas                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
AjustaSX1(cPerg)                                                        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe janela de Parametros                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If Pergunte(cPerg, .T.)      

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa planilha excel                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	Processa( {||COMR009()}, cTitulo, "Processando planilha em excel...", .F. )

EndIf              

Restarea( aArea )
Return

   
/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³COMR009   ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processamento                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function COMR009                 
Local aArea			:= GetArea()
Local aAreaSA2		:= SA2->( GetArea() )

Local cAnoAtu       := AllTrim(MV_PAR03)
Local cAnoAnt       := AllTrim(Str(Val(MV_PAR03)-1))

Local cFornece      := ""                              

Local aData 		:= {}                         

Local cArq	        := "C:\Protheus\COMR009.VBS"
Local nHdl	        := 0  
Local cVBS          := ""   

Local nCol          := 0                            
Local nRow          := 0  
Local cRow          := ""

Local nX, nY        := 0                   
Local nMeses        := 0         

Local cSrvPath		:= "\TEMP\"
Local cCliPath		:= "C:\PROTHEUS\"
Local cArqXLS		:= "iqf_" + AllTrim(mv_par01) + AllTrim(mv_par02) + ".xlsx"     

Local nDtDemerito	:= 1 // 1=D1_DTDIGIT; 2=D1_EMISSAO
              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array utilizado para guardar valores da query                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//            Indicador                              			Jan Fev Mar Abr Mai Jun Jul Ago Set Out Nov Dez Ac1 Ac2
AADD(ADATA, {"TOTAL DE LOTES RECEBIDOS"             			,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	})
AADD(ADATA, {"TOTAL DE LOTES RECEBIDOS NO PRAZO"    			,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	})
AADD(ADATA, {"TOTAL DE DEMERITOS POR ENTREGA"       			,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	})
AADD(ADATA, {"TOTAL DE LOTES APROVADOS"      					,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	})
AADD(ADATA, {"TOTAL DE LOTES CONDICIONAIS"      				,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	})
AADD(ADATA, {"TOTAL DE LOTES REJEITADOS" 		    			,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	})
AADD(ADATA, {"TOTAL DE DEMERITOS POR QUALIDADE"     			,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	})
AADD(ADATA, {"IQE - INDICE DE QUALIDADE DE ENTREGA" 			,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	})
AADD(ADATA, {"IQP - INDICE DE QUALIDADE DO PRODUTO" 			,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	})
AADD(ADATA, {"IS  - INDICE DO SISTEMA DE GESTAO DA QUALIDADE" 	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	})
AADD(ADATA, {"IQF - INDICE DE QUALIDADE DE FORNECIMENTO" 		,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	,0	})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Script SQL                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQry := "SELECT" + ENTER
cQry += "	FORNECE," + ENTER
cQry += "	LOJA," + ENTER
cQry += "	ANO," + ENTER
cQry += "	MES," + ENTER
cQry += "	E_TOT," + ENTER
cQry += "	E_PRZ," + ENTER
cQry += "	ISNULL(E_DEME,0) 'E_DEME'," + ENTER
cQry += "	ISNULL(((E_TOT*100)-E_DEME)/CONVERT(FLOAT, NULLIF(E_TOT,0)),0) 'IQE'," + ENTER
cQry += "	Q_APROV," + ENTER
cQry += "	Q_REST," + ENTER
cQry += "	Q_REPR," + ENTER
cQry += "	ISNULL(Q_DEME,0) 'Q_DEME'," + ENTER
cQry += "	ISNULL(((E_TOT*100)-Q_DEME)/CONVERT(FLOAT, NULLIF(E_TOT,0)),0) 'IQP'," + ENTER
cQry += "	FATAVA 'IS'," + ENTER
cQry += "	( FATAVA + ( 2 * ISNULL(((E_TOT*100)-E_DEME)/CONVERT(FLOAT, NULLIF(E_TOT,0)),0) ) + ( 4 * ISNULL(((E_TOT*100)-Q_DEME)/CONVERT(FLOAT, NULLIF(E_TOT,0)),0) ) ) / 7 'IQF'" + ENTER
cQry += "FROM" + ENTER
cQry += "	(" + ENTER
cQry += "		SELECT	" + ENTER
cQry += "				D1_FORNECE 'FORNECE'," + ENTER
cQry += "				D1_LOJA 'LOJA'," + ENTER
cQry += "				YEAR(" + IIf(nDtDemerito == 1, " D1_DTDIGIT ", " D1_EMISSAO ") + ") 'ANO'," + ENTER
cQry += "				CASE WHEN YEAR(" + IIf(nDtDemerito == 1, " D1_DTDIGIT ", " D1_EMISSAO ") + ") = " + cAnoAtu + " THEN MONTH(" + IIf(nDtDemerito == 1, " D1_DTDIGIT ", " D1_EMISSAO ") + ") ELSE 0 END 'MES'," + ENTER
//cQry += "				AVG(D1_FATAVA) 'FATAVA'," + ENTER
cQry += "				MAX(D1_FATAVA) 'FATAVA'," + ENTER
cQry += "				COUNT(1) 'E_TOT'," + ENTER
cQry += "				SUM( ISNULL(CASE WHEN DATEDIFF(DD, C7_DATPRF, " + IIf(nDtDemerito == 1, " D1_DTDIGIT ", " D1_EMISSAO ") + " ) <= 1 THEN 1 ELSE 0 END, 0) ) 'E_PRZ'," + ENTER
cQry += "				SUM( ISNULL( CASE WHEN DATEDIFF(DD, C7_DATPRF, " + IIf(nDtDemerito == 1, " D1_DTDIGIT ", " D1_EMISSAO ") + " ) <= 0 THEN 0" + ENTER
cQry += "								  WHEN DATEDIFF(DD, C7_DATPRF, " + IIf(nDtDemerito == 1, " D1_DTDIGIT ", " D1_EMISSAO ") + " )  = 1 THEN 20" + ENTER
cQry += "								  WHEN DATEDIFF(DD, C7_DATPRF, " + IIf(nDtDemerito == 1, " D1_DTDIGIT ", " D1_EMISSAO ") + " )  = 2 THEN 50" + ENTER
cQry += "								  WHEN DATEDIFF(DD, C7_DATPRF, " + IIf(nDtDemerito == 1, " D1_DTDIGIT ", " D1_EMISSAO ") + " ) >= 3 THEN 100" + ENTER
cQry += "							 END, 0) ) 'E_DEME'," + ENTER
cQry += "				SUM( ISNULL( CASE WHEN D7_TIPO = '1' AND D7_MOTREST = '' THEN 1 ELSE 0 END, 0) ) 'Q_APROV'," + ENTER
cQry += "				SUM( ISNULL( CASE WHEN D7_TIPO = '1' AND D7_MOTREST <> ''  THEN 1 ELSE 0 END, 0) ) 'Q_REST'," + ENTER
cQry += "				SUM( ISNULL( CASE WHEN D7_TIPO = '2' THEN 1 ELSE 0 END, 0) ) 'Q_REPR'," + ENTER
cQry += "				SUM( ISNULL( CASE WHEN D7_TIPO = '2' THEN 100 ELSE 0 END + " + ENTER
cQry += "							 CASE WHEN D7_TIPO = '1' AND D7_LAUDO = 'N' THEN 30 ELSE 0 END + " + ENTER
cQry += "							 CASE WHEN D7_TIPO = '1' AND D7_MOTREST = '01' THEN 50 ELSE 0 END + " + ENTER
cQry += "							 CASE WHEN D7_TIPO = '1' AND D7_MOTREST = '02' THEN 70 ELSE 0 END, 0) ) 'Q_DEME'" + ENTER	
cQry += "		FROM" + ENTER
cQry += "			" + RetSqlName("SD1") + " SD1 " + ENTER
cQry += "		INNER JOIN" + ENTER
cQry += "			" + RetSqlName("SB1") + " SB1 " + ENTER
cQry += "				ON	SB1.D_E_L_E_T_ = ''" + ENTER
cQry += "				AND	B1_FILIAL = '" + xFilial("SB1") + "'" + ENTER
cQry += "				AND	B1_COD = D1_COD" + ENTER
cQry += "				AND B1_TIPO IN ('ME', 'MP')" + ENTER
cQry += "		INNER JOIN" + ENTER
cQry += "			" + RetSqlName("SC7") + " SC7" + ENTER
cQry += "				ON	SC7.D_E_L_E_T_ = ''" + ENTER
cQry += "				AND	C7_FILIAL = D1_FILIAL" + ENTER
cQry += "				AND	C7_NUM = D1_PEDIDO" + ENTER
cQry += "				AND	C7_ITEM = D1_ITEMPC" + ENTER
cQry += "		LEFT JOIN" + ENTER
cQry += "			" + RetSqlName("SD7") + " SD7" + ENTER
cQry += "				ON	SD7.D_E_L_E_T_ = ''" + ENTER
cQry += "				AND	SD7.D7_FILIAL = D1_FILIAL" + ENTER
cQry += "				AND	SD7.D7_NUMERO = D1_NUMCQ " + ENTER
cQry += "				AND	SD7.D7_TIPO IN ('1','2')" + ENTER
cQry += "		WHERE	" + ENTER
cQry += "			SD1.D_E_L_E_T_ = ''" + ENTER
cQry += "			AND D1_TIPO = 'N'" + ENTER
cQry += "			AND	D1_FORNECE = '" + mv_par01 + "'" + ENTER
cQry += "			AND	D1_LOJA = '" + mv_par02 + "'" + ENTER
cQry += "			AND YEAR(D1_EMISSAO) BETWEEN " + cAnoAnt + " AND " + cAnoAtu + ENTER
cQry += "		GROUP BY" + ENTER
cQry += "			D1_FORNECE," + ENTER
cQry += "			D1_LOJA, " + ENTER
cQry += "			CASE WHEN YEAR(" + IIf(nDtDemerito == 1, " D1_DTDIGIT ", " D1_EMISSAO ") + ") = " + cAnoAtu + " THEN MONTH(" + IIf(nDtDemerito == 1, " D1_DTDIGIT ", " D1_EMISSAO ") + ") ELSE 0 END," + ENTER
cQry += "			YEAR(" + IIf(nDtDemerito == 1, " D1_DTDIGIT ", " D1_EMISSAO ") + ")" + ENTER
cQry += "	) SUBQRY" + ENTER
cQry += "ORDER BY" + ENTER
cQry += "	FORNECE," + ENTER
cQry += "	LOJA," + ENTER
cQry += "	ANO," + ENTER
cQry += "	MES" + ENTER

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria workarea temporaria com resultado da Query                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf         

MemoWrite("COMR009.SQL", cqry)

TCQUERY cQry NEW ALIAS QRY   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe resultado na Query                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If QRY->(BoF()) .And. QRY->(EoF())
	MsgInfo("Não existem dados para gerar planilha.")
	Return
EndIf  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Localiza fornecedor e guarda Razao Social                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
SA2->( dbSetOrder(1) )
SA2->( dbSeek( xFilial("SA2") + QRY->(FORNECE+LOJA) ) )

cFornece := "( " + QRY->FORNECE + "-" + LOJA + ") " + Posicione("SA2", 1, xFilial("SA2") + QRY->(FORNECE+LOJA), "A2_NOME")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Numero de meses ativos do ano atual                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
/*
Count To nMeses

If cValToChar(QRY->ANO) == cAnoAnt
	nMeses := (nMeses-1)
EndIf
*/             
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Transforma recordset da Query em Array                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
dbSelectArea("QRY")
QRY->(dbGoTop())
While QRY->(!EoF()) 
	             
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dados do ano anterior                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	If cValToChar(QRY->ANO) == cAnoAnt

		nColAcu            := 15

		aData[01, nColAcu] := QRY->E_TOT 
		aData[02, nColAcu] := QRY->E_PRZ 
		aData[03, nColAcu] := QRY->E_DEME        
		aData[04, nColAcu] := QRY->Q_APROV
		aData[05, nColAcu] := QRY->Q_REST
		aData[06, nColAcu] := QRY->Q_REPR        
		aData[07, nColAcu] := QRY->Q_DEME
		aData[08, nColAcu] := QRY->IQE
		aData[09, nColAcu] := QRY->IQP
		aData[10, nColAcu] := QRY->IS
		aData[11, nColAcu] := QRY->IQF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dados do ano atual                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	ElseIf cValToChar(QRY->ANO) == cAnoAtu
	                             
		nColMes            := (QRY->MES+1)
		nColAcu            := 14
	
		aData[01, nColMes] := QRY->E_TOT 
		aData[01, nColAcu] += QRY->E_TOT 
	
		aData[02, nColMes] := QRY->E_PRZ 
		aData[02, nColAcu] += QRY->E_PRZ 
		
		aData[03, nColMes] := aData[03, nColMes] + QRY->E_DEME 
		//aData[03, nColAcu] := aData[03, nColAcu] + ( QRY->E_DEME / nMeses )
		aData[03, nColAcu] := aData[03, nColAcu] + QRY->E_DEME
	
		aData[04, nColMes] := QRY->Q_APROV
		aData[04, nColAcu] += QRY->Q_APROV 
    
		aData[05, nColMes] := QRY->Q_REST
		aData[05, nColAcu] += QRY->Q_REST

		aData[06, nColMes] := QRY->Q_REPR
		aData[06, nColAcu] += QRY->Q_REPR
		
		aData[07, nColMes] := QRY->Q_DEME
		//aData[07, nColAcu] := aData[07, nColAcu] + ( QRY->Q_DEME / nMeses )
		aData[07, nColAcu] := aData[07, nColAcu] + QRY->Q_DEME

		aData[08, nColMes] := QRY->	IQE
		//aData[08, nColAcu] := aData[08, nColAcu] + ( QRY->IQE / nMeses )
		aData[08, nColAcu] := ((aData[01, nColAcu]*100)-aData[03, nColAcu])/aData[01, nColAcu]

		aData[09, nColMes] := QRY->IQP
		//aData[09, nColAcu] := aData[09, nColAcu] + ( QRY->IQP / nMeses ) 
		aData[09, nColAcu] := ((aData[01, nColAcu]*100)-aData[07, nColAcu])/aData[01, nColAcu]

		aData[10, nColMes] := QRY->IS
		//aData[10, nColAcu] := aData[10, nColAcu] + ( QRY->IS / nMeses ) 
		aData[10, nColAcu] := QRY->IS

		aData[11, nColMes] := QRY->IQF
		//aData[11, nColAcu] := aData[11, nColAcu] + ( QRY->IQF / nMeses ) 
		aData[11, nColAcu] := (aData[10, nColAcu]+(2*aData[08, nColAcu])+(4*aData[09, nColAcu]))/7
		
	EndIf
                                 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Guarda ultimo mes corrente                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ               
	nMeses := QRY->MES

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Avanca para o proximo registro                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	QRY->(dbSkip())           
	
EndDo        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha workarea temporaria com resultado da Query                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄ
If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria script VBS                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHdl := FCreate(cArq)
If nHdl == -1
	MsgAlert("Falha na criação do arquivo!" , "Atenção!")
	Return
Endif        

cVBS := ""
cVBS += 'Dim objExcel' + ENTER
cVBS += 'Dim objImage' + ENTER
cVBS += 'Dim rngImage' + ENTER
cVBS += 'Dim objChart' + ENTER
cVBS += 'Dim rngChart' + ENTER

cVBS += 'on error resume next' + ENTER

cVBS += 'Set objExcel = CreateObject("Excel.Application")' + ENTER
cVBS += 'objExcel.Visible = True' + ENTER
cVBS += 'objExcel.Workbooks.Add' + ENTER

cVBS += 'objExcel.DisplayAlerts = False' + ENTER
cVBS += 'objExcel.ActiveWindow.DisplayGridlines = False' + ENTER
cVBS += 'objExcel.ScreenUpdating = False' + ENTER
cVBS += 'objExcel.EnableEvents = False' + ENTER

cVBS += 'objExcel.Columns("A").ColumnWidth = 9' + ENTER
cVBS += 'objExcel.Columns("B").ColumnWidth = 9' + ENTER
cVBS += 'objExcel.Columns("C").ColumnWidth = 9' + ENTER
cVBS += 'objExcel.Columns("D").ColumnWidth = 9' + ENTER
cVBS += 'objExcel.Columns("E").ColumnWidth = 9' + ENTER
cVBS += 'objExcel.Columns("F").ColumnWidth = 9' + ENTER
cVBS += 'objExcel.Columns("G").ColumnWidth = 9' + ENTER
cVBS += 'objExcel.Columns("H").ColumnWidth = 9' + ENTER
cVBS += 'objExcel.Columns("I").ColumnWidth = 9' + ENTER
cVBS += 'objExcel.Columns("J").ColumnWidth = 9' + ENTER
cVBS += 'objExcel.Columns("K").ColumnWidth = 9' + ENTER
cVBS += 'objExcel.Columns("L").ColumnWidth = 9' + ENTER
cVBS += 'objExcel.Columns("M").ColumnWidth = 9' + ENTER
cVBS += 'objExcel.Columns("N").ColumnWidth = 9' + ENTER
cVBS += 'objExcel.Columns("O").ColumnWidth = 9' + ENTER
cVBS += 'objExcel.Columns("P").ColumnWidth = 9' + ENTER
cVBS += 'objExcel.Columns("Q").ColumnWidth = 9' + ENTER
cVBS += 'objExcel.Columns("R").ColumnWidth = 9' + ENTER
cVBS += 'objExcel.Columns("S").ColumnWidth = 9' + ENTER
cVBS += 'objExcel.Columns("T").ColumnWidth = 9' + ENTER
cVBS += 'objExcel.Columns("U").ColumnWidth = 9' + ENTER
cVBS += 'objExcel.Columns("V").ColumnWidth = 9' + ENTER

cVBS += 'objExcel.Range("A1:A2").RowHeight = 35' + ENTER
cVBS += 'objExcel.Range("A1:D2").Merge' + ENTER
cVBS += 'objExcel.Range("A1:D2").Interior.Color = RGB(255,255,255)' + ENTER
cVBS += 'objExcel.Range("A1:D2").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("A1:D2").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("A1:D2").Borders.Weight = 3' + ENTER
cVBS += 'Set rngImage = objExcel.Range("B1:C2")' + ENTER
cVBS += 'Set objImage = objExcel.ActiveSheet.Pictures.Insert("G:\Utils\Modelos\Logo Euroamerican.png")' + ENTER
cVBS += 'With objImage' + ENTER
cVBS += '	.Left   = rngImage.Left' + ENTER
cVBS += '	.Top    = rngImage.Top' + ENTER
cVBS += '	.Height = rngImage.Height' + ENTER
cVBS += '	.Width  = rngImage.Width' + ENTER
cVBS += 'End With' + ENTER

cVBS += 'objExcel.Range("A1:A2").RowHeight = 35' + ENTER
cVBS += 'objExcel.Range("E1:R2").Merge' + ENTER
cVBS += 'objExcel.Range("E1:R2").Interior.Color = RGB(255,255,255)' + ENTER
cVBS += 'objExcel.Range("E1:R2").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("E1:R2").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("E1:R2").Borders.Weight = 3' + ENTER
cVBS += 'objExcel.Range("E1:R2").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("E1:R2").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("E1:R2").Font.Name = "Calibri"' + ENTER
cVBS += 'objExcel.Range("E1:R2").Font.Size = 30' + ENTER
cVBS += 'objExcel.Range("E1:R2").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("E1:R2").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(1,"E") = "Demonstrativo Anual de Desempenho de Fornecimento"' + ENTER
cVBS += 'objExcel.Range("A1:A2").RowHeight = 35' + ENTER

cVBS += 'objExcel.Range("S1:V2").Merge' + ENTER
cVBS += 'objExcel.Range("S1:V2").Interior.Color = RGB(255,255,255)' + ENTER
cVBS += 'objExcel.Range("S1:V2").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("S1:V2").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("S1:V2").Borders.Weight = 3' + ENTER
cVBS += 'objExcel.Range("S1:V2").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("S1:V2").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("S1:V2").Font.Name = "Calibri"' + ENTER
cVBS += 'objExcel.Range("S1:V2").Font.Size = 30' + ENTER
cVBS += 'objExcel.Range("S1:V2").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("S1:V2").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(1,"S") = "' + cAnoAtu + '"' + ENTER

cVBS += 'objExcel.Range("A3:A3").RowHeight = 5' + ENTER
cVBS += 'objExcel.Range("A4:A4").RowHeight = 35' + ENTER
cVBS += 'objExcel.Range("A4:V4").Merge' + ENTER
cVBS += 'objExcel.Range("A4:V4").Interior.Color = RGB(055,096,145)' + ENTER
cVBS += 'objExcel.Range("A4:V4").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("A4:V4").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("A4:V4").Font.Name = "Calibri"' + ENTER
cVBS += 'objExcel.Range("A4:V4").Font.Size = 20' + ENTER
cVBS += 'objExcel.Range("A4:V4").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("A4:V4").Font.Color = RGB(255, 255, 255)' + ENTER
cVBS += 'objExcel.Cells(4,"A") = "FORNECEDOR: ' + AllTrim(cFornece) + '"' + ENTER
cVBS += 'objExcel.Range("A5:A5").RowHeight = 5' + ENTER

cVBS += 'objExcel.Range("A6:H7").Merge' + ENTER                  
cVBS += 'objExcel.Range("A6:H7").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("A6:H7").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("A6:H7").Borders.Weight = 1' + ENTER
cVBS += 'objExcel.Range("A6:H7").Interior.Color = RGB(216,216,216)' + ENTER
cVBS += 'objExcel.Range("A6:H7").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("A6:H7").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("A6:H7").Font.Name = "Courier New"' + ENTER
cVBS += 'objExcel.Range("A6:H7").Font.Size = 11' + ENTER
cVBS += 'objExcel.Range("A6:H7").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("A6:H7").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(6,"A") = "AVALIAÇÃO"' + ENTER

cVBS += 'objExcel.Range("I6:I7").Merge' + ENTER    
cVBS += 'objExcel.Range("I6:I7").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("I6:I7").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("I6:I7").Borders.Weight = 1' + ENTER
cVBS += 'objExcel.Range("I6:I7").Interior.Color = RGB(216,216,216)' + ENTER
cVBS += 'objExcel.Range("I6:I7").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("I6:I7").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("I6:I7").Font.Name = "Courier New"' + ENTER
cVBS += 'objExcel.Range("I6:I7").Font.Size = 11' + ENTER
cVBS += 'objExcel.Range("I6:I7").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("I6:I7").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(6,"I") = "JAN"' + ENTER

cVBS += 'objExcel.Range("J6:J7").Merge' + ENTER       
cVBS += 'objExcel.Range("J6:J7").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("J6:J7").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("J6:J7").Borders.Weight = 1' + ENTER
cVBS += 'objExcel.Range("J6:J7").Interior.Color = RGB(216,216,216)' + ENTER
cVBS += 'objExcel.Range("J6:J7").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("J6:J7").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("J6:J7").Font.Name = "Courier New"' + ENTER
cVBS += 'objExcel.Range("J6:J7").Font.Size = 11' + ENTER
cVBS += 'objExcel.Range("J6:J7").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("J6:J7").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(6,"J") = "FEV"' + ENTER

cVBS += 'objExcel.Range("K6:K7").Merge' + ENTER       
cVBS += 'objExcel.Range("K6:K7").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("K6:K7").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("K6:K7").Borders.Weight = 1' + ENTER
cVBS += 'objExcel.Range("K6:K7").Interior.Color = RGB(216,216,216)' + ENTER
cVBS += 'objExcel.Range("K6:K7").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("K6:K7").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("K6:K7").Font.Name = "Courier New"' + ENTER
cVBS += 'objExcel.Range("K6:K7").Font.Size = 11' + ENTER
cVBS += 'objExcel.Range("K6:K7").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("K6:K7").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(6,"K") = "MAR"' + ENTER

cVBS += 'objExcel.Range("L6:L7").Merge' + ENTER   
cVBS += 'objExcel.Range("L6:L7").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("L6:L7").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("L6:L7").Borders.Weight = 1' + ENTER
cVBS += 'objExcel.Range("L6:L7").Interior.Color = RGB(216,216,216)' + ENTER
cVBS += 'objExcel.Range("L6:L7").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("L6:L7").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("L6:L7").Font.Name = "Courier New"' + ENTER
cVBS += 'objExcel.Range("L6:L7").Font.Size = 11' + ENTER
cVBS += 'objExcel.Range("L6:L7").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("L6:L7").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(6,"L") = "ABR"' + ENTER

cVBS += 'objExcel.Range("M6:M7").Merge' + ENTER     
cVBS += 'objExcel.Range("M6:M7").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("M6:M7").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("M6:M7").Borders.Weight = 1' + ENTER
cVBS += 'objExcel.Range("M6:M7").Interior.Color = RGB(216,216,216)' + ENTER
cVBS += 'objExcel.Range("M6:M7").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("M6:M7").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("M6:M7").Font.Name = "Courier New"' + ENTER
cVBS += 'objExcel.Range("M6:M7").Font.Size = 11' + ENTER
cVBS += 'objExcel.Range("M6:M7").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("M6:M7").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(6,"M") = "MAI"' + ENTER

cVBS += 'objExcel.Range("N6:N7").Merge' + ENTER
cVBS += 'objExcel.Range("N6:N7").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("N6:N7").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("N6:N7").Borders.Weight = 1' + ENTER
cVBS += 'objExcel.Range("N6:N7").Interior.Color = RGB(216,216,216)' + ENTER
cVBS += 'objExcel.Range("N6:N7").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("N6:N7").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("N6:N7").Font.Name = "Courier New"' + ENTER
cVBS += 'objExcel.Range("N6:N7").Font.Size = 11' + ENTER
cVBS += 'objExcel.Range("N6:N7").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("N6:N7").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(6,"N") = "JUN"' + ENTER

cVBS += 'objExcel.Range("O6:O7").Merge' + ENTER        
cVBS += 'objExcel.Range("O6:O7").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("O6:O7").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("O6:O7").Borders.Weight = 1' + ENTER
cVBS += 'objExcel.Range("O6:O7").Interior.Color = RGB(216,216,216)' + ENTER
cVBS += 'objExcel.Range("O6:O7").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("O6:O7").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("O6:O7").Font.Name = "Courier New"' + ENTER
cVBS += 'objExcel.Range("O6:O7").Font.Size = 11' + ENTER
cVBS += 'objExcel.Range("O6:O7").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("O6:O7").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(6,"O") = "JUL"' + ENTER

cVBS += 'objExcel.Range("P6:P7").Merge' + ENTER         
cVBS += 'objExcel.Range("P6:P7").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("P6:P7").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("P6:P7").Borders.Weight = 1' + ENTER
cVBS += 'objExcel.Range("P6:P7").Interior.Color = RGB(216,216,216)' + ENTER
cVBS += 'objExcel.Range("P6:P7").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("P6:P7").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("P6:P7").Font.Name = "Courier New"' + ENTER
cVBS += 'objExcel.Range("P6:P7").Font.Size = 11' + ENTER
cVBS += 'objExcel.Range("P6:P7").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("P6:P7").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(6,"P") = "AGO"' + ENTER

cVBS += 'objExcel.Range("Q6:Q7").Merge' + ENTER        
cVBS += 'objExcel.Range("Q6:Q7").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("Q6:Q7").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("Q6:Q7").Borders.Weight = 1' + ENTER
cVBS += 'objExcel.Range("Q6:Q7").Interior.Color = RGB(216,216,216)' + ENTER
cVBS += 'objExcel.Range("Q6:Q7").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("Q6:Q7").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("Q6:Q7").Font.Name = "Courier New"' + ENTER
cVBS += 'objExcel.Range("Q6:Q7").Font.Size = 11' + ENTER
cVBS += 'objExcel.Range("Q6:Q7").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("Q6:Q7").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(6,"Q") = "SET"' + ENTER

cVBS += 'objExcel.Range("R6:R7").Merge' + ENTER    
cVBS += 'objExcel.Range("R6:R7").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("R6:R7").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("R6:R7").Borders.Weight = 1' + ENTER
cVBS += 'objExcel.Range("R6:R7").Interior.Color = RGB(216,216,216)' + ENTER
cVBS += 'objExcel.Range("R6:R7").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("R6:R7").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("R6:R7").Font.Name = "Courier New"' + ENTER
cVBS += 'objExcel.Range("R6:R7").Font.Size = 11' + ENTER
cVBS += 'objExcel.Range("R6:R7").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("R6:R7").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(6,"R") = "OUT"' + ENTER
     
cVBS += 'objExcel.Range("S6:S7").Merge' + ENTER    
cVBS += 'objExcel.Range("S6:S7").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("S6:S7").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("S6:S7").Borders.Weight = 1' + ENTER
cVBS += 'objExcel.Range("S6:S7").Interior.Color = RGB(216,216,216)' + ENTER
cVBS += 'objExcel.Range("S6:S7").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("S6:S7").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("S6:S7").Font.Name = "Courier New"' + ENTER
cVBS += 'objExcel.Range("S6:S7").Font.Size = 11' + ENTER
cVBS += 'objExcel.Range("S6:S7").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("S6:S7").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(6,"S") = "NOV"' + ENTER

cVBS += 'objExcel.Range("T6:T7").Merge' + ENTER     
cVBS += 'objExcel.Range("T6:T7").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("T6:T7").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("T6:T7").Borders.Weight = 1' + ENTER
cVBS += 'objExcel.Range("T6:T7").Interior.Color = RGB(216,216,216)' + ENTER
cVBS += 'objExcel.Range("T6:T7").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("T6:T7").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("T6:T7").Font.Name = "Courier New"' + ENTER
cVBS += 'objExcel.Range("T6:T7").Font.Size = 11' + ENTER
cVBS += 'objExcel.Range("T6:T7").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("T6:T7").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(6,"T") = "DEZ"' + ENTER

cVBS += 'objExcel.Range("U6:V6").Merge' + ENTER    
cVBS += 'objExcel.Range("U6:V6").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("U6:V6").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("U6:V6").Borders.Weight = 1' + ENTER
cVBS += 'objExcel.Range("U6:V6").Interior.Color = RGB(216,216,216)' + ENTER
cVBS += 'objExcel.Range("U6:V6").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("U6:V6").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("U6:V6").Font.Name = "Courier New"' + ENTER
cVBS += 'objExcel.Range("U6:V6").Font.Size = 11' + ENTER
cVBS += 'objExcel.Range("U6:V6").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("U6:V6").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(6,"U") = "ACUMULADO"' + ENTER

cVBS += 'objExcel.Range("U7").Merge' + ENTER      
cVBS += 'objExcel.Range("U7").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("U7").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("U7").Borders.Weight = 1' + ENTER
cVBS += 'objExcel.Range("U7").Interior.Color = RGB(216,216,216)' + ENTER
cVBS += 'objExcel.Range("U7").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("U7").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("U7").Font.Name = "Courier New"' + ENTER
cVBS += 'objExcel.Range("U7").Font.Size = 11' + ENTER
cVBS += 'objExcel.Range("U7").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("U7").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(7,"U") = "' + cAnoAtu +'"' + ENTER

cVBS += 'objExcel.Range("V7").Merge' + ENTER      
cVBS += 'objExcel.Range("V7").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("V7").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("V7").Borders.Weight = 1' + ENTER
cVBS += 'objExcel.Range("V7").Interior.Color = RGB(216,216,216)' + ENTER
cVBS += 'objExcel.Range("V7").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("V7").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("V7").Font.Name = "Courier New"' + ENTER
cVBS += 'objExcel.Range("V7").Font.Size = 11' + ENTER
cVBS += 'objExcel.Range("V7").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("V7").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(7,"V") = "' + cAnoAnt +'"' + ENTER

If FWrite(nHdl, cVBS, Len(cVBS)) <> Len(cVBS)
	If !MsgAlert("Ocorreu um erro na gravação do arquivo.","Atenção!")
		Return
	EndIf
EndIf       

nRow := 8

For nX := 1 To Len(aData)
               
	cRow := cValToChar(nRow)
	
    cVBS := ""
    cVBS += 'objExcel.Range("A' + cRow + ':H' + cRow + '").Merge' + ENTER  
	cVBS += 'objExcel.Range("A' + cRow + ':H' + cRow + '").HorizontalAlignment = -4131' + ENTER
	cVBS += 'objExcel.Range("A' + cRow + ':H' + cRow + '").VerticalAlignment = -4108' + ENTER
	cVBS += 'objExcel.Range("A' + cRow + ':H' + cRow + '").Font.Name = "Courier New"' + ENTER 			
	cVBS += 'objExcel.Range("A' + cRow + ':H' + cRow + '").Font.Bold = "False"' + ENTER 			
	cVBS += 'objExcel.Range("A' + cRow + ':H' + cRow + '").Font.Size = 11' + ENTER 			
	cVBS += 'objExcel.Range("A' + cRow + ':H' + cRow + '").Font.Color = RGB(0, 0, 0)' + ENTER	
	cVBS += 'objExcel.Range("A' + cRow + ':H' + cRow + '").Borders.LineStyle = 1' + ENTER  
	cVBS += 'objExcel.Range("A' + cRow + ':H' + cRow + '").Borders.Color = RGB(0, 0, 0)' + ENTER  
	cVBS += 'objExcel.Range("A' + cRow + ':H' + cRow + '").Borders.Weight = 1' + ENTER    	
	cVBS += 'objExcel.Range("A' + cRow + ':A' + cRow + '").NumberFormat = "@"' + ENTER
	cVBS += 'objExcel.Cells('+ cRow + ',"A") = "'+ aData[nX,01] + '"' + ENTER
	If FWrite(nHdl, cVBS, Len(cVBS)) <> Len(cVBS)
		If !MsgAlert("Ocorreu um erro na gravação do arquivo.","Atenção!")
			Return
		EndIf
	EndIf 

    cVBS := ""
    cVBS += 'objExcel.Range("I' + cRow + ':I' + cRow + '").Merge' + ENTER  
	cVBS += 'objExcel.Range("I' + cRow + ':I' + cRow + '").HorizontalAlignment = -4152' + ENTER
	cVBS += 'objExcel.Range("I' + cRow + ':I' + cRow + '").VerticalAlignment = -4108' + ENTER
	cVBS += 'objExcel.Range("I' + cRow + ':I' + cRow + '").Font.Name = "Courier New"' + ENTER 			
	cVBS += 'objExcel.Range("I' + cRow + ':I' + cRow + '").Font.Bold = "False"' + ENTER 			
	cVBS += 'objExcel.Range("I' + cRow + ':I' + cRow + '").Font.Size = 11' + ENTER 			
	cVBS += 'objExcel.Range("I' + cRow + ':I' + cRow + '").Font.Color = RGB(0, 0, 0)' + ENTER	
	cVBS += 'objExcel.Range("I' + cRow + ':I' + cRow + '").Borders.LineStyle = 1' + ENTER  
	cVBS += 'objExcel.Range("I' + cRow + ':I' + cRow + '").Borders.Color = RGB(0, 0, 0)' + ENTER  
	cVBS += 'objExcel.Range("I' + cRow + ':I' + cRow + '").Borders.Weight = 1' + ENTER    	
	cVBS += 'objExcel.Range("I' + cRow + ':I' + cRow + '").NumberFormat = "#,##0.00"' + ENTER
	cVBS += 'objExcel.Cells('+ cRow + ',"I") = "' + cValToChar(aData[nX,02]) + '"' + ENTER
	If FWrite(nHdl, cVBS, Len(cVBS)) <> Len(cVBS)
		If !MsgAlert("Ocorreu um erro na gravação do arquivo.","Atenção!")
			Return
		EndIf
	EndIf 

    cVBS := ""
    cVBS += 'objExcel.Range("J' + cRow + ':J' + cRow + '").Merge' + ENTER  
	cVBS += 'objExcel.Range("J' + cRow + ':J' + cRow + '").HorizontalAlignment = -4152' + ENTER
	cVBS += 'objExcel.Range("J' + cRow + ':J' + cRow + '").VerticalAlignment = -4108' + ENTER
	cVBS += 'objExcel.Range("J' + cRow + ':J' + cRow + '").Font.Name = "Courier New"' + ENTER 			
	cVBS += 'objExcel.Range("J' + cRow + ':J' + cRow + '").Font.Bold = "False"' + ENTER 			
	cVBS += 'objExcel.Range("J' + cRow + ':J' + cRow + '").Font.Size = 11' + ENTER 			
	cVBS += 'objExcel.Range("J' + cRow + ':J' + cRow + '").Font.Color = RGB(0, 0, 0)' + ENTER	
	cVBS += 'objExcel.Range("J' + cRow + ':J' + cRow + '").Borders.LineStyle = 1' + ENTER  
	cVBS += 'objExcel.Range("J' + cRow + ':J' + cRow + '").Borders.Color = RGB(0, 0, 0)' + ENTER  
	cVBS += 'objExcel.Range("J' + cRow + ':J' + cRow + '").Borders.Weight = 1' + ENTER    	
	cVBS += 'objExcel.Range("J' + cRow + ':J' + cRow + '").NumberFormat = "#,##0.00"' + ENTER
	cVBS += 'objExcel.Cells('+ cRow + ',"J") = "' + cValToChar(aData[nX,03]) + '"' + ENTER
	If FWrite(nHdl, cVBS, Len(cVBS)) <> Len(cVBS)
		If !MsgAlert("Ocorreu um erro na gravação do arquivo.","Atenção!")
			Return
		EndIf
	EndIf         	

    cVBS := ""
    cVBS += 'objExcel.Range("K' + cRow + ':K' + cRow + '").Merge' + ENTER  
	cVBS += 'objExcel.Range("K' + cRow + ':K' + cRow + '").HorizontalAlignment = -4152' + ENTER
	cVBS += 'objExcel.Range("K' + cRow + ':K' + cRow + '").VerticalAlignment = -4108' + ENTER
	cVBS += 'objExcel.Range("K' + cRow + ':K' + cRow + '").Font.Name = "Courier New"' + ENTER 			
	cVBS += 'objExcel.Range("K' + cRow + ':K' + cRow + '").Font.Bold = "False"' + ENTER 			
	cVBS += 'objExcel.Range("K' + cRow + ':K' + cRow + '").Font.Size = 11' + ENTER 			
	cVBS += 'objExcel.Range("K' + cRow + ':K' + cRow + '").Font.Color = RGB(0, 0, 0)' + ENTER	
	cVBS += 'objExcel.Range("K' + cRow + ':K' + cRow + '").Borders.LineStyle = 1' + ENTER  
	cVBS += 'objExcel.Range("K' + cRow + ':K' + cRow + '").Borders.Color = RGB(0, 0, 0)' + ENTER  
	cVBS += 'objExcel.Range("K' + cRow + ':K' + cRow + '").Borders.Weight = 1' + ENTER    	
	cVBS += 'objExcel.Range("K' + cRow + ':K' + cRow + '").NumberFormat = "#,##0.00"' + ENTER
	cVBS += 'objExcel.Cells('+ cRow + ',"K") = "' + cValToChar(aData[nX,04]) + '"' + ENTER
	If FWrite(nHdl, cVBS, Len(cVBS)) <> Len(cVBS)
		If !MsgAlert("Ocorreu um erro na gravação do arquivo.","Atenção!")
			Return
		EndIf
	EndIf 	
	
    cVBS := ""
    cVBS += 'objExcel.Range("L' + cRow + ':L' + cRow + '").Merge' + ENTER  
	cVBS += 'objExcel.Range("L' + cRow + ':L' + cRow + '").HorizontalAlignment = -4152' + ENTER
	cVBS += 'objExcel.Range("L' + cRow + ':L' + cRow + '").VerticalAlignment = -4108' + ENTER
	cVBS += 'objExcel.Range("L' + cRow + ':L' + cRow + '").Font.Name = "Courier New"' + ENTER 			
	cVBS += 'objExcel.Range("L' + cRow + ':L' + cRow + '").Font.Bold = "False"' + ENTER 			
	cVBS += 'objExcel.Range("L' + cRow + ':L' + cRow + '").Font.Size = 11' + ENTER 			
	cVBS += 'objExcel.Range("L' + cRow + ':L' + cRow + '").Font.Color = RGB(0, 0, 0)' + ENTER	
	cVBS += 'objExcel.Range("L' + cRow + ':L' + cRow + '").Borders.LineStyle = 1' + ENTER  
	cVBS += 'objExcel.Range("L' + cRow + ':L' + cRow + '").Borders.Color = RGB(0, 0, 0)' + ENTER  
	cVBS += 'objExcel.Range("L' + cRow + ':L' + cRow + '").Borders.Weight = 1' + ENTER    	
	cVBS += 'objExcel.Range("L' + cRow + ':L' + cRow + '").NumberFormat = "#,##0.00"' + ENTER
	cVBS += 'objExcel.Cells('+ cRow + ',"L") = "' + cValToChar(aData[nX,05]) + '"' + ENTER
	If FWrite(nHdl, cVBS, Len(cVBS)) <> Len(cVBS)
		If !MsgAlert("Ocorreu um erro na gravação do arquivo.","Atenção!")
			Return
		EndIf
	EndIf 		
	              
    cVBS := ""
    cVBS += 'objExcel.Range("M' + cRow + ':M' + cRow + '").Merge' + ENTER  
	cVBS += 'objExcel.Range("M' + cRow + ':M' + cRow + '").HorizontalAlignment = -4152' + ENTER
	cVBS += 'objExcel.Range("M' + cRow + ':M' + cRow + '").VerticalAlignment = -4108' + ENTER
	cVBS += 'objExcel.Range("M' + cRow + ':M' + cRow + '").Font.Name = "Courier New"' + ENTER 			
	cVBS += 'objExcel.Range("M' + cRow + ':M' + cRow + '").Font.Bold = "False"' + ENTER 			
	cVBS += 'objExcel.Range("M' + cRow + ':M' + cRow + '").Font.Size = 11' + ENTER 			
	cVBS += 'objExcel.Range("M' + cRow + ':M' + cRow + '").Font.Color = RGB(0, 0, 0)' + ENTER	
	cVBS += 'objExcel.Range("M' + cRow + ':M' + cRow + '").Borders.LineStyle = 1' + ENTER  
	cVBS += 'objExcel.Range("M' + cRow + ':M' + cRow + '").Borders.Color = RGB(0, 0, 0)' + ENTER  
	cVBS += 'objExcel.Range("M' + cRow + ':M' + cRow + '").Borders.Weight = 1' + ENTER    	
	cVBS += 'objExcel.Range("M' + cRow + ':M' + cRow + '").NumberFormat = "#,##0.00"' + ENTER
	cVBS += 'objExcel.Cells('+ cRow + ',"M") = "' + cValToChar(aData[nX,06]) + '"' + ENTER
	If FWrite(nHdl, cVBS, Len(cVBS)) <> Len(cVBS)
		If !MsgAlert("Ocorreu um erro na gravação do arquivo.","Atenção!")
			Return
		EndIf
	EndIf 		
	              
    cVBS := ""
    cVBS += 'objExcel.Range("N' + cRow + ':N' + cRow + '").Merge' + ENTER  
	cVBS += 'objExcel.Range("N' + cRow + ':N' + cRow + '").HorizontalAlignment = -4152' + ENTER
	cVBS += 'objExcel.Range("N' + cRow + ':N' + cRow + '").VerticalAlignment = -4108' + ENTER
	cVBS += 'objExcel.Range("N' + cRow + ':N' + cRow + '").Font.Name = "Courier New"' + ENTER 			
	cVBS += 'objExcel.Range("N' + cRow + ':N' + cRow + '").Font.Bold = "False"' + ENTER 			
	cVBS += 'objExcel.Range("N' + cRow + ':N' + cRow + '").Font.Size = 11' + ENTER 			
	cVBS += 'objExcel.Range("N' + cRow + ':N' + cRow + '").Font.Color = RGB(0, 0, 0)' + ENTER	
	cVBS += 'objExcel.Range("N' + cRow + ':N' + cRow + '").Borders.LineStyle = 1' + ENTER  
	cVBS += 'objExcel.Range("N' + cRow + ':N' + cRow + '").Borders.Color = RGB(0, 0, 0)' + ENTER  
	cVBS += 'objExcel.Range("N' + cRow + ':N' + cRow + '").Borders.Weight = 1' + ENTER    	
	cVBS += 'objExcel.Range("N' + cRow + ':N' + cRow + '").NumberFormat = "#,##0.00"' + ENTER
	cVBS += 'objExcel.Cells('+ cRow + ',"N") = "' + cValToChar(aData[nX,07]) + '"' + ENTER
	If FWrite(nHdl, cVBS, Len(cVBS)) <> Len(cVBS)
		If !MsgAlert("Ocorreu um erro na gravação do arquivo.","Atenção!")
			Return
		EndIf
	EndIf 		
	
    cVBS := ""
    cVBS += 'objExcel.Range("O' + cRow + ':O' + cRow + '").Merge' + ENTER  
	cVBS += 'objExcel.Range("O' + cRow + ':O' + cRow + '").HorizontalAlignment = -4152' + ENTER
	cVBS += 'objExcel.Range("O' + cRow + ':O' + cRow + '").VerticalAlignment = -4108' + ENTER
	cVBS += 'objExcel.Range("O' + cRow + ':O' + cRow + '").Font.Name = "Courier New"' + ENTER 			
	cVBS += 'objExcel.Range("O' + cRow + ':O' + cRow + '").Font.Bold = "False"' + ENTER 			
	cVBS += 'objExcel.Range("O' + cRow + ':O' + cRow + '").Font.Size = 11' + ENTER 			
	cVBS += 'objExcel.Range("O' + cRow + ':O' + cRow + '").Font.Color = RGB(0, 0, 0)' + ENTER	
	cVBS += 'objExcel.Range("O' + cRow + ':O' + cRow + '").Borders.LineStyle = 1' + ENTER  
	cVBS += 'objExcel.Range("O' + cRow + ':O' + cRow + '").Borders.Color = RGB(0, 0, 0)' + ENTER  
	cVBS += 'objExcel.Range("O' + cRow + ':O' + cRow + '").Borders.Weight = 1' + ENTER    	
	cVBS += 'objExcel.Range("O' + cRow + ':O' + cRow + '").NumberFormat = "#,##0.00"' + ENTER
	cVBS += 'objExcel.Cells('+ cRow + ',"O") = "' + cValToChar(aData[nX,08]) + '"' + ENTER
	If FWrite(nHdl, cVBS, Len(cVBS)) <> Len(cVBS)
		If !MsgAlert("Ocorreu um erro na gravação do arquivo.","Atenção!")
			Return
		EndIf
	EndIf 	
	
    cVBS := ""
    cVBS += 'objExcel.Range("P' + cRow + ':P' + cRow + '").Merge' + ENTER  
	cVBS += 'objExcel.Range("P' + cRow + ':P' + cRow + '").HorizontalAlignment = -4152' + ENTER
	cVBS += 'objExcel.Range("P' + cRow + ':P' + cRow + '").VerticalAlignment = -4108' + ENTER
	cVBS += 'objExcel.Range("P' + cRow + ':P' + cRow + '").Font.Name = "Courier New"' + ENTER 			
	cVBS += 'objExcel.Range("P' + cRow + ':P' + cRow + '").Font.Bold = "False"' + ENTER 			
	cVBS += 'objExcel.Range("P' + cRow + ':P' + cRow + '").Font.Size = 11' + ENTER 			
	cVBS += 'objExcel.Range("P' + cRow + ':P' + cRow + '").Font.Color = RGB(0, 0, 0)' + ENTER	
	cVBS += 'objExcel.Range("P' + cRow + ':P' + cRow + '").Borders.LineStyle = 1' + ENTER  
	cVBS += 'objExcel.Range("P' + cRow + ':P' + cRow + '").Borders.Color = RGB(0, 0, 0)' + ENTER  
	cVBS += 'objExcel.Range("P' + cRow + ':P' + cRow + '").Borders.Weight = 1' + ENTER    	
	cVBS += 'objExcel.Range("P' + cRow + ':P' + cRow + '").NumberFormat = "#,##0.00"' + ENTER
	cVBS += 'objExcel.Cells('+ cRow + ',"P") = "' + cValToChar(aData[nX,09]) + '"' + ENTER
	If FWrite(nHdl, cVBS, Len(cVBS)) <> Len(cVBS)
		If !MsgAlert("Ocorreu um erro na gravação do arquivo.","Atenção!")
			Return
		EndIf
	EndIf 	
	
    cVBS := ""
    cVBS += 'objExcel.Range("Q' + cRow + ':Q' + cRow + '").Merge' + ENTER  
	cVBS += 'objExcel.Range("Q' + cRow + ':Q' + cRow + '").HorizontalAlignment = -4152' + ENTER
	cVBS += 'objExcel.Range("Q' + cRow + ':Q' + cRow + '").VerticalAlignment = -4108' + ENTER
	cVBS += 'objExcel.Range("Q' + cRow + ':Q' + cRow + '").Font.Name = "Courier New"' + ENTER 			
	cVBS += 'objExcel.Range("Q' + cRow + ':Q' + cRow + '").Font.Bold = "False"' + ENTER 			
	cVBS += 'objExcel.Range("Q' + cRow + ':Q' + cRow + '").Font.Size = 11' + ENTER 			
	cVBS += 'objExcel.Range("Q' + cRow + ':Q' + cRow + '").Font.Color = RGB(0, 0, 0)' + ENTER	
	cVBS += 'objExcel.Range("Q' + cRow + ':Q' + cRow + '").Borders.LineStyle = 1' + ENTER  
	cVBS += 'objExcel.Range("Q' + cRow + ':Q' + cRow + '").Borders.Color = RGB(0, 0, 0)' + ENTER  
	cVBS += 'objExcel.Range("Q' + cRow + ':Q' + cRow + '").Borders.Weight = 1' + ENTER    	
	cVBS += 'objExcel.Range("Q' + cRow + ':Q' + cRow + '").NumberFormat = "#,##0.00"' + ENTER
	cVBS += 'objExcel.Cells('+ cRow + ',"Q") = "' + cValToChar(aData[nX,10]) + '"' + ENTER
	If FWrite(nHdl, cVBS, Len(cVBS)) <> Len(cVBS)
		If !MsgAlert("Ocorreu um erro na gravação do arquivo.","Atenção!")
			Return
		EndIf
	EndIf	
		
    cVBS := ""
    cVBS += 'objExcel.Range("R' + cRow + ':R' + cRow + '").Merge' + ENTER  
	cVBS += 'objExcel.Range("R' + cRow + ':R' + cRow + '").HorizontalAlignment = -4152' + ENTER
	cVBS += 'objExcel.Range("R' + cRow + ':R' + cRow + '").VerticalAlignment = -4108' + ENTER
	cVBS += 'objExcel.Range("R' + cRow + ':R' + cRow + '").Font.Name = "Courier New"' + ENTER 			
	cVBS += 'objExcel.Range("R' + cRow + ':R' + cRow + '").Font.Bold = "False"' + ENTER 			
	cVBS += 'objExcel.Range("R' + cRow + ':R' + cRow + '").Font.Size = 11' + ENTER 			
	cVBS += 'objExcel.Range("R' + cRow + ':R' + cRow + '").Font.Color = RGB(0, 0, 0)' + ENTER	
	cVBS += 'objExcel.Range("R' + cRow + ':R' + cRow + '").Borders.LineStyle = 1' + ENTER  
	cVBS += 'objExcel.Range("R' + cRow + ':R' + cRow + '").Borders.Color = RGB(0, 0, 0)' + ENTER  
	cVBS += 'objExcel.Range("R' + cRow + ':R' + cRow + '").Borders.Weight = 1' + ENTER    	
	cVBS += 'objExcel.Range("R' + cRow + ':R' + cRow + '").NumberFormat = "#,##0.00"' + ENTER
	cVBS += 'objExcel.Cells('+ cRow + ',"R") = "' + cValToChar(aData[nX,11]) + '"' + ENTER
	If FWrite(nHdl, cVBS, Len(cVBS)) <> Len(cVBS)
		If !MsgAlert("Ocorreu um erro na gravação do arquivo.","Atenção!")
			Return
		EndIf
	EndIf		
		                             
    cVBS := ""
    cVBS += 'objExcel.Range("S' + cRow + ':S' + cRow + '").Merge' + ENTER  
	cVBS += 'objExcel.Range("S' + cRow + ':S' + cRow + '").HorizontalAlignment = -4152' + ENTER
	cVBS += 'objExcel.Range("S' + cRow + ':S' + cRow + '").VerticalAlignment = -4108' + ENTER
	cVBS += 'objExcel.Range("S' + cRow + ':S' + cRow + '").Font.Name = "Courier New"' + ENTER 			
	cVBS += 'objExcel.Range("S' + cRow + ':S' + cRow + '").Font.Bold = "False"' + ENTER 			
	cVBS += 'objExcel.Range("S' + cRow + ':S' + cRow + '").Font.Size = 11' + ENTER 			
	cVBS += 'objExcel.Range("S' + cRow + ':S' + cRow + '").Font.Color = RGB(0, 0, 0)' + ENTER	
	cVBS += 'objExcel.Range("S' + cRow + ':S' + cRow + '").Borders.LineStyle = 1' + ENTER  
	cVBS += 'objExcel.Range("S' + cRow + ':S' + cRow + '").Borders.Color = RGB(0, 0, 0)' + ENTER  
	cVBS += 'objExcel.Range("S' + cRow + ':S' + cRow + '").Borders.Weight = 1' + ENTER    	
	cVBS += 'objExcel.Range("S' + cRow + ':S' + cRow + '").NumberFormat = "#,##0.00"' + ENTER
	cVBS += 'objExcel.Cells('+ cRow + ',"S") = "' + cValToChar(aData[nX,12]) + '"' + ENTER
	If FWrite(nHdl, cVBS, Len(cVBS)) <> Len(cVBS)
		If !MsgAlert("Ocorreu um erro na gravação do arquivo.","Atenção!")
			Return
		EndIf
	EndIf	
		
    cVBS := ""
    cVBS += 'objExcel.Range("T' + cRow + ':T' + cRow + '").Merge' + ENTER  
	cVBS += 'objExcel.Range("T' + cRow + ':T' + cRow + '").HorizontalAlignment = -4152' + ENTER
	cVBS += 'objExcel.Range("T' + cRow + ':T' + cRow + '").VerticalAlignment = -4108' + ENTER
	cVBS += 'objExcel.Range("T' + cRow + ':T' + cRow + '").Font.Name = "Courier New"' + ENTER 			
	cVBS += 'objExcel.Range("T' + cRow + ':T' + cRow + '").Font.Bold = "False"' + ENTER 			
	cVBS += 'objExcel.Range("T' + cRow + ':T' + cRow + '").Font.Size = 11' + ENTER 			
	cVBS += 'objExcel.Range("T' + cRow + ':T' + cRow + '").Font.Color = RGB(0, 0, 0)' + ENTER	
	cVBS += 'objExcel.Range("T' + cRow + ':T' + cRow + '").Borders.LineStyle = 1' + ENTER  
	cVBS += 'objExcel.Range("T' + cRow + ':T' + cRow + '").Borders.Color = RGB(0, 0, 0)' + ENTER  
	cVBS += 'objExcel.Range("T' + cRow + ':T' + cRow + '").Borders.Weight = 1' + ENTER    	
	cVBS += 'objExcel.Range("T' + cRow + ':T' + cRow + '").NumberFormat = "#,##0.00"' + ENTER
	cVBS += 'objExcel.Cells('+ cRow + ',"T") = "' + cValToChar(aData[nX,13]) + '"' + ENTER
	If FWrite(nHdl, cVBS, Len(cVBS)) <> Len(cVBS)
		If !MsgAlert("Ocorreu um erro na gravação do arquivo.","Atenção!")
			Return
		EndIf
	EndIf		
	
    cVBS := ""
    cVBS += 'objExcel.Range("U' + cRow + ':U' + cRow + '").Merge' + ENTER  
	cVBS += 'objExcel.Range("U' + cRow + ':U' + cRow + '").HorizontalAlignment = -4152' + ENTER
	cVBS += 'objExcel.Range("U' + cRow + ':U' + cRow + '").VerticalAlignment = -4108' + ENTER
	cVBS += 'objExcel.Range("U' + cRow + ':U' + cRow + '").Font.Name = "Courier New"' + ENTER 			
	cVBS += 'objExcel.Range("U' + cRow + ':U' + cRow + '").Font.Bold = "False"' + ENTER 			
	cVBS += 'objExcel.Range("U' + cRow + ':U' + cRow + '").Font.Size = 11' + ENTER 			
	cVBS += 'objExcel.Range("U' + cRow + ':U' + cRow + '").Font.Color = RGB(0, 0, 0)' + ENTER	
	cVBS += 'objExcel.Range("U' + cRow + ':U' + cRow + '").Borders.LineStyle = 1' + ENTER  
	cVBS += 'objExcel.Range("U' + cRow + ':U' + cRow + '").Borders.Color = RGB(0, 0, 0)' + ENTER  
	cVBS += 'objExcel.Range("U' + cRow + ':U' + cRow + '").Borders.Weight = 1' + ENTER    	
	cVBS += 'objExcel.Range("U' + cRow + ':U' + cRow + '").NumberFormat = "#,##0.00"' + ENTER
	cVBS += 'objExcel.Cells('+ cRow + ',"U") = "' + cValToChar(aData[nX,14]) + '"' + ENTER
	If FWrite(nHdl, cVBS, Len(cVBS)) <> Len(cVBS)
		If !MsgAlert("Ocorreu um erro na gravação do arquivo.","Atenção!")
			Return
		EndIf
	EndIf	 
	
    cVBS := ""
    cVBS += 'objExcel.Range("V' + cRow + ':V' + cRow + '").Merge' + ENTER  
	cVBS += 'objExcel.Range("V' + cRow + ':V' + cRow + '").HorizontalAlignment = -4152' + ENTER
	cVBS += 'objExcel.Range("V' + cRow + ':V' + cRow + '").VerticalAlignment = -4108' + ENTER
	cVBS += 'objExcel.Range("V' + cRow + ':V' + cRow + '").Font.Name = "Courier New"' + ENTER 			
	cVBS += 'objExcel.Range("V' + cRow + ':V' + cRow + '").Font.Bold = "False"' + ENTER 			
	cVBS += 'objExcel.Range("V' + cRow + ':V' + cRow + '").Font.Size = 11' + ENTER 			
	cVBS += 'objExcel.Range("V' + cRow + ':V' + cRow + '").Font.Color = RGB(0, 0, 0)' + ENTER	
	cVBS += 'objExcel.Range("V' + cRow + ':V' + cRow + '").Borders.LineStyle = 1' + ENTER  
	cVBS += 'objExcel.Range("V' + cRow + ':V' + cRow + '").Borders.Color = RGB(0, 0, 0)' + ENTER  
	cVBS += 'objExcel.Range("V' + cRow + ':V' + cRow + '").Borders.Weight = 1' + ENTER    	
	cVBS += 'objExcel.Range("V' + cRow + ':V' + cRow + '").NumberFormat = "#,##0.00"' + ENTER
	cVBS += 'objExcel.Cells('+ cRow + ',"V") = "' + cValToChar(aData[nX,15]) + '"' + ENTER
	If FWrite(nHdl, cVBS, Len(cVBS)) <> Len(cVBS)
		If !MsgAlert("Ocorreu um erro na gravação do arquivo.","Atenção!")
			Return
		EndIf
	EndIf	 	       

	// Aumenta altura da linha
	cVBS += 'objExcel.Range("V' + cRow + ':V' + cRow + '").RowHeight = 20' + ENTER
	If FWrite(nHdl, cVBS, Len(cVBS)) <> Len(cVBS)
		If !MsgAlert("Ocorreu um erro na gravação do arquivo.","Atenção!")
			Return
		EndIf
	EndIf 	       

	// Pinta cores das linhas referente aos Indices
	If nX >= 8             
		cVBS += 'objExcel.Range("A' + cRow + ':V' + cRow + '").Interior.Color = RGB(221,221,221)' + ENTER 		
		If FWrite(nHdl, cVBS, Len(cVBS)) <> Len(cVBS)
			If !MsgAlert("Ocorreu um erro na gravação do arquivo.","Atenção!")
				Return
			EndIf
		EndIf 	       
	EndIf		       
	                             
	// Atualiza contador de linhas
	nRow ++

Next nX
                          
//--------------------------------------------------------------------------

cVBS := ""
cVBS += 'Set rngChart = objExcel.Range("A20:K37")' + ENTER
cVBS += 'Set objChart = objExcel.ActiveSheet.ChartObjects.Add( rngChart.Left, rngChart.Top, rngChart.Width, rngChart.Height )' + ENTER
cVBS += 'With objChart.Chart' + ENTER
cVBS += '	.ChartType = 4' + ENTER
cVBS += '	.HasTitle = True' + ENTER
cVBS += '	.ChartTitle.Characters.Text = "IQF - Indice de Qualidade de Fornecimento"' + ENTER	
cVBS += '	Do Until .SeriesCollection.Count = 0' + ENTER
cVBS += '		.SeriesCollection(1).Delete' + ENTER
cVBS += '	Loop' + ENTER
cVBS += '	With .SeriesCollection.NewSeries' + ENTER
cVBS += '		.Name = "IQF"' + ENTER
cVBS += '		.Values = objExcel.Range("I18:' + Chr(72+nMeses) + '18")' + ENTER
cVBS += '		.XValues = objExcel.Range("I6:T6")' + ENTER
cVBS += '		.MarkerStyle = -4142' + ENTER
cVBS += '	End With' + ENTER	
cVBS += '	With .SeriesCollection.NewSeries' + ENTER
cVBS += '		.Name = "Limite Inferior"' + ENTER
cVBS += '		.Values = Array(70,70,70,70,70,70,70,70,70,70,70,70)' + ENTER
cVBS += '		.XValues = objExcel.Range("I6:T6")' + ENTER
cVBS += '		.MarkerStyle = -4142' + ENTER
cVBS += '	End With' + ENTER	
cVBS += 'End With' + ENTER
If FWrite(nHdl, cVBS, Len(cVBS)) <> Len(cVBS)
	If !MsgAlert("Ocorreu um erro na gravação do arquivo.","Atenção!")
		Return
	EndIf
EndIf  

//--------------------------------------------------------------------------
     
cVBS := ""                                               
cVBS += 'objExcel.Range("M20:V20").RowHeight = 35' + ENTER
cVBS += 'objExcel.Range("M20:V20").Merge' + ENTER     
cVBS += 'objExcel.Range("M20:V20").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("M20:V20").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("M20:V20").Borders.Weight = 2' + ENTER
cVBS += 'objExcel.Range("M20:V20").Interior.Color = RGB(255,255,255)' + ENTER
cVBS += 'objExcel.Range("M20:V20").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("M20:V20").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("M20:V20").Font.Name = "Calibri"' + ENTER
cVBS += 'objExcel.Range("M20:V20").Font.Size = 12' + ENTER
cVBS += 'objExcel.Range("M20:V20").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("M20:V20").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(20,"M") = "IQE = ( Nº de Entregas x 100 - Demeritos por Entrega ) / Nº de Entregas"' + ENTER

cVBS += 'objExcel.Range("M21:O21").Merge' + ENTER     
//cVBS += 'objExcel.Range("M21:O21").Borders.LineStyle = 1' + ENTER
//cVBS += 'objExcel.Range("M21:O21").Borders.Color = RGB(0, 0, 0)' + ENTER
//cVBS += 'objExcel.Range("M21:O21").Borders.Weight = 2' + ENTER
cVBS += 'objExcel.Range("M21:O21").Interior.Color = RGB(255,255,255)' + ENTER
cVBS += 'objExcel.Range("M21:O21").HorizontalAlignment = -4131' + ENTER
cVBS += 'objExcel.Range("M21:O21").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("M21:O21").Font.Name = "Calibri"' + ENTER
cVBS += 'objExcel.Range("M21:O21").Font.Size = 10' + ENTER
cVBS += 'objExcel.Range("M21:O21").Font.Bold = "False"' + ENTER
cVBS += 'objExcel.Range("M21:O21").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(21,"M") = "Demeritos por Entrega:"' + ENTER

cVBS += 'objExcel.Range("N22:V22").Merge' + ENTER     
//cVBS += 'objExcel.Range("N22:V22").Borders.LineStyle = 1' + ENTER
//cVBS += 'objExcel.Range("N22:V22").Borders.Color = RGB(0, 0, 0)' + ENTER
//cVBS += 'objExcel.Range("N22:V22").Borders.Weight = 2' + ENTER
cVBS += 'objExcel.Range("N22:V22").Interior.Color = RGB(255,255,255)' + ENTER
cVBS += 'objExcel.Range("N22:V22").HorizontalAlignment = -4131' + ENTER
cVBS += 'objExcel.Range("N22:V22").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("N22:V22").Font.Name = "Calibri"' + ENTER
cVBS += 'objExcel.Range("N22:V22").Font.Size = 10' + ENTER
cVBS += 'objExcel.Range("N22:V22").Font.Bold = "False"' + ENTER
cVBS += 'objExcel.Range("N22:V22").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(22,"N") = "Atraso de 01 dia util = 20 pontos"' + ENTER

cVBS += 'objExcel.Range("N23:V23").Merge' + ENTER     
//cVBS += 'objExcel.Range("N23:V23").Borders.LineStyle = 1' + ENTER
//cVBS += 'objExcel.Range("N23:V23").Borders.Color = RGB(0, 0, 0)' + ENTER
//cVBS += 'objExcel.Range("N23:V23").Borders.Weight = 2' + ENTER
cVBS += 'objExcel.Range("N23:V23").Interior.Color = RGB(255,255,255)' + ENTER
cVBS += 'objExcel.Range("N23:V23").HorizontalAlignment = -4131' + ENTER
cVBS += 'objExcel.Range("N23:V23").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("N23:V23").Font.Name = "Calibri"' + ENTER
cVBS += 'objExcel.Range("N23:V23").Font.Size = 10' + ENTER
cVBS += 'objExcel.Range("N23:V23").Font.Bold = "False"' + ENTER
cVBS += 'objExcel.Range("N23:V23").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(23,"N") = "Atraso de 02 dias uteis = 50 pontos"' + ENTER

cVBS += 'objExcel.Range("N24:V24").Merge' + ENTER     
//cVBS += 'objExcel.Range("N24:V24").Borders.LineStyle = 1' + ENTER
//cVBS += 'objExcel.Range("N24:V24").Borders.Color = RGB(0, 0, 0)' + ENTER
//cVBS += 'objExcel.Range("N24:V24").Borders.Weight = 2' + ENTER
cVBS += 'objExcel.Range("N24:V24").Interior.Color = RGB(255,255,255)' + ENTER
cVBS += 'objExcel.Range("N24:V24").HorizontalAlignment = -4131' + ENTER
cVBS += 'objExcel.Range("N24:V24").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("N24:V24").Font.Name = "Calibri"' + ENTER
cVBS += 'objExcel.Range("N24:V24").Font.Size = 10' + ENTER
cVBS += 'objExcel.Range("N24:V24").Font.Bold = "False"' + ENTER
cVBS += 'objExcel.Range("N24:V24").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(24,"N") = "Atraso de 03 dias uteis = 100 pontos"' + ENTER

cVBS += 'objExcel.Range("N25:V25").Merge' + ENTER     
//cVBS += 'objExcel.Range("N25:V25").Borders.LineStyle = 1' + ENTER
//cVBS += 'objExcel.Range("N25:V25").Borders.Color = RGB(0, 0, 0)' + ENTER
//cVBS += 'objExcel.Range("N25:V25").Borders.Weight = 2' + ENTER
cVBS += 'objExcel.Range("N25:V25").Interior.Color = RGB(255,255,255)' + ENTER
cVBS += 'objExcel.Range("N25:V25").HorizontalAlignment = -4131' + ENTER
cVBS += 'objExcel.Range("N25:V25").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("N25:V25").Font.Name = "Calibri"' + ENTER
cVBS += 'objExcel.Range("N25:V25").Font.Size = 10' + ENTER
cVBS += 'objExcel.Range("N25:V25").Font.Bold = "False"' + ENTER
cVBS += 'objExcel.Range("N25:V25").Font.Color = RGB(0, 0, 0)' + ENTER
//cVBS += 'objExcel.Cells(25,"N") = "Atraso de 04 dias uteis = 100 pontos"' + ENTER                                            
            
cVBS += 'objExcel.Range("M27:V27").RowHeight = 35' + ENTER
cVBS += 'objExcel.Range("M27:V27").Merge' + ENTER     
cVBS += 'objExcel.Range("M27:V27").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("M27:V27").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("M27:V27").Borders.Weight = 2' + ENTER
cVBS += 'objExcel.Range("M27:V27").Interior.Color = RGB(255,255,255)' + ENTER
cVBS += 'objExcel.Range("M27:V27").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("M27:V27").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("M27:V27").Font.Name = "Calibri"' + ENTER
cVBS += 'objExcel.Range("M27:V27").Font.Size = 12' + ENTER
cVBS += 'objExcel.Range("M27:V27").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("M27:V27").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(27,"M") = "IQP = ( Nº de Entregas x 100 - Demeritos por Qualidade ) / Nº de Entregas"' + ENTER
                                                      
cVBS += 'objExcel.Range("M28:O28").Merge' + ENTER     
//cVBS += 'objExcel.Range("M28:O28").Borders.LineStyle = 1' + ENTER
//cVBS += 'objExcel.Range("M28:O28").Borders.Color = RGB(0, 0, 0)' + ENTER
//cVBS += 'objExcel.Range("M28:O28").Borders.Weight = 2' + ENTER
cVBS += 'objExcel.Range("M28:O28").Interior.Color = RGB(255,255,255)' + ENTER
cVBS += 'objExcel.Range("M28:O28").HorizontalAlignment = -4131' + ENTER
cVBS += 'objExcel.Range("M28:O28").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("M28:O28").Font.Name = "Calibri"' + ENTER
cVBS += 'objExcel.Range("M28:O28").Font.Size = 10' + ENTER
cVBS += 'objExcel.Range("M28:O28").Font.Bold = "False"' + ENTER
cVBS += 'objExcel.Range("M28:O28").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(28,"M") = "Demeritos por Qualidade:"' + ENTER
                                                         
cVBS += 'objExcel.Range("N29:V29").Merge' + ENTER     
//cVBS += 'objExcel.Range("N29:V29").Borders.LineStyle = 1' + ENTER
//cVBS += 'objExcel.Range("N29:V29").Borders.Color = RGB(0, 0, 0)' + ENTER
//cVBS += 'objExcel.Range("N29:V29").Borders.Weight = 2' + ENTER
cVBS += 'objExcel.Range("N29:V29").Interior.Color = RGB(255,255,255)' + ENTER
cVBS += 'objExcel.Range("N29:V29").HorizontalAlignment = -4131' + ENTER
cVBS += 'objExcel.Range("N29:V29").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("N29:V29").Font.Name = "Calibri"' + ENTER
cVBS += 'objExcel.Range("N29:V29").Font.Size = 10' + ENTER
cVBS += 'objExcel.Range("N29:V29").Font.Bold = "False"' + ENTER
cVBS += 'objExcel.Range("N29:V29").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(29,"N") = "Produto sem laudo de analise = 30 pontos"' + ENTER

cVBS += 'objExcel.Range("N30:V30").Merge' + ENTER     
//cVBS += 'objExcel.Range("N30:V30").Borders.LineStyle = 1' + ENTER
//cVBS += 'objExcel.Range("N30:V30").Borders.Color = RGB(0, 0, 0)' + ENTER
//cVBS += 'objExcel.Range("N30:V30").Borders.Weight = 2' + ENTER
cVBS += 'objExcel.Range("N30:V30").Interior.Color = RGB(255,255,255)' + ENTER
cVBS += 'objExcel.Range("N30:V30").HorizontalAlignment = -4131' + ENTER
cVBS += 'objExcel.Range("N30:V30").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("N30:V30").Font.Name = "Calibri"' + ENTER
cVBS += 'objExcel.Range("N30:V30").Font.Size = 10' + ENTER
cVBS += 'objExcel.Range("N30:V30").Font.Bold = "False"' + ENTER
cVBS += 'objExcel.Range("N30:V30").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(30,"N") = "Produto com desvio na qualidade mas passivel de consumo sem alteracao no processo = 50 pontos"' + ENTER

cVBS += 'objExcel.Range("N31:V31").Merge' + ENTER     
//cVBS += 'objExcel.Range("N31:V31").Borders.LineStyle = 1' + ENTER
//cVBS += 'objExcel.Range("N31:V31").Borders.Color = RGB(0, 0, 0)' + ENTER
//cVBS += 'objExcel.Range("N31:V31").Borders.Weight = 2' + ENTER
cVBS += 'objExcel.Range("N31:V31").Interior.Color = RGB(255,255,255)' + ENTER
cVBS += 'objExcel.Range("N31:V31").HorizontalAlignment = -4131' + ENTER
cVBS += 'objExcel.Range("N31:V31").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("N31:V31").Font.Name = "Calibri"' + ENTER
cVBS += 'objExcel.Range("N31:V31").Font.Size = 10' + ENTER
cVBS += 'objExcel.Range("N31:V31").Font.Bold = "False"' + ENTER
cVBS += 'objExcel.Range("N31:V31").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(31,"N") = "Produto com desvio na qualidade mas passivel de consumo com alteracao no processo = 70 pontos"' + ENTER                                               

cVBS += 'objExcel.Range("N32:V32").Merge' + ENTER     
//cVBS += 'objExcel.Range("N32:V32").Borders.LineStyle = 1' + ENTER
//cVBS += 'objExcel.Range("N32:V32").Borders.Color = RGB(0, 0, 0)' + ENTER
//cVBS += 'objExcel.Range("N32:V32").Borders.Weight = 2' + ENTER
cVBS += 'objExcel.Range("N32:V32").Interior.Color = RGB(255,255,255)' + ENTER
cVBS += 'objExcel.Range("N32:V32").HorizontalAlignment = -4131' + ENTER
cVBS += 'objExcel.Range("N32:V32").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("N32:V32").Font.Name = "Calibri"' + ENTER
cVBS += 'objExcel.Range("N32:V32").Font.Size = 10' + ENTER
cVBS += 'objExcel.Range("N32:V32").Font.Bold = "False"' + ENTER
cVBS += 'objExcel.Range("N32:V32").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(32,"N") = "Produto rejeitado = 100 pontos"' + ENTER                                                                        

cVBS += 'objExcel.Range("M34:V34").RowHeight = 35' + ENTER
cVBS += 'objExcel.Range("M34:V34").Merge' + ENTER     
cVBS += 'objExcel.Range("M34:V34").WrapText = True' + ENTER
cVBS += 'objExcel.Range("M34:V34").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("M34:V34").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("M34:V34").Borders.Weight = 2' + ENTER
cVBS += 'objExcel.Range("M34:V34").Interior.Color = RGB(255,255,255)' + ENTER
cVBS += 'objExcel.Range("M34:V34").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("M34:V34").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("M34:V34").Font.Name = "Calibri"' + ENTER
cVBS += 'objExcel.Range("M34:V34").Font.Size = 12' + ENTER
cVBS += 'objExcel.Range("M34:V34").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("M34:V34").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(34,"M") = "IS = Obtido pelo percentual de atendimento ao questionario de auto-avaliacao do SGQ ' +;
                                  'ou definido como 100% nos casos em que o fornecedor possuir certificação ISO 9001"' + ENTER

cVBS += 'objExcel.Range("M36:V36").RowHeight = 35' + ENTER
cVBS += 'objExcel.Range("M36:V36").Merge' + ENTER     
cVBS += 'objExcel.Range("M36:V36").Borders.LineStyle = 1' + ENTER
cVBS += 'objExcel.Range("M36:V36").Borders.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Range("M36:V36").Borders.Weight = 2' + ENTER
cVBS += 'objExcel.Range("M36:V36").Interior.Color = RGB(255,255,255)' + ENTER
cVBS += 'objExcel.Range("M36:V36").HorizontalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("M36:V36").VerticalAlignment = -4108' + ENTER
cVBS += 'objExcel.Range("M36:V36").Font.Name = "Calibri"' + ENTER
cVBS += 'objExcel.Range("M36:V36").Font.Size = 18' + ENTER
cVBS += 'objExcel.Range("M36:V36").Font.Bold = "True"' + ENTER
cVBS += 'objExcel.Range("M36:V36").Font.Color = RGB(0, 0, 0)' + ENTER
cVBS += 'objExcel.Cells(36,"M") = "IQF = [ IS + ( 2 x IQE ) + ( 4 x IQP ) ] / 7"' + ENTER

If FWrite(nHdl, cVBS, Len(cVBS)) <> Len(cVBS)
	If !MsgAlert("Ocorreu um erro na gravação do arquivo.","Atenção!")
		Return
	EndIf
EndIf  

//--------------------------------------------------------------------------

cVBS := ""                                                 
cVBS += 'objExcel.ActiveSheet.PageSetup.PrintArea = "$A$1:$V$40"' + ENTER 
cVBS += 'objExcel.ActiveSheet.PageSetup.Orientation = 2' + ENTER
cVBS += 'objExcel.ActiveSheet.PageSetup.PaperSize = 9' + ENTER
cVBS += 'objExcel.ActiveSheet.PageSetup.CenterHorizontally = True' + ENTER
cVBS += 'objExcel.ActiveSheet.PageSetup.Zoom = False' + ENTER
cVBS += 'objExcel.ActiveSheet.PageSetup.FitToPagesWide = 1' + ENTER
cVBS += 'objExcel.ActiveSheet.PageSetup.FitToPagesTall = 1' + ENTER    
If FWrite(nHdl, cVBS, Len(cVBS)) <> Len(cVBS)
	If !MsgAlert("Ocorreu um erro na gravação do arquivo.","Atenção!")
		Return
	EndIf
EndIf         

cVBS += 'objExcel.ScreenUpdating = True' + ENTER                                    
cVBS += 'objExcel.EnableEvents = True' + ENTER   
cVBS += 'objExcel.ActiveSheet.SaveAs "' + cCliPath + "\" + cArqXLS + '"' + ENTER
      
// Abre arquivo para visualizacao ( 1=SIM / 2=NAO )
If mv_par05 == 2 
	cVBS += 'objExcel.ActiveWorkbook.Close False' + ENTER
	cVBS += 'objExcel.Quit' + ENTER
	cVBS += 'Set objExcel = Nothing' + ENTER
EndIf

If FWrite(nHdl, cVBS, Len(cVBS)) <> Len(cVBS)
	If !MsgAlert("Ocorreu um erro na gravação do arquivo.","Atenção!")
		Return
	EndIf
EndIf         

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre Excel                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nRow := 10
If nRow > 3
	fClose(nHdl)      
	
	// Envia e-mail ao fornecedor ( 1=SIM / 2=NAO )
	If mv_par04 == 1        
	  
		CPYT2S(cCliPath+cArqXLS, cSrvPath)
		
		If File(cSrvPath+cArqXLS)
			EnvEmail(SA2->A2_EMAIL, cSrvPath+cArqXLS)     
		Else
			MsgStop("Não foi possivel copiar arquivo para o servidor", "Copiar")
		EndIf
	
	EndIf	
	
	ShellExecute( "OPEN", cArq, "", "", 1 )	
	Sleep(3000)   	
EndIf
      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga Script                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDirectory := Directory(cCliPath + "*.vbs")  
aEval(aDirectory, {|x| FErase(cCliPath + x[1])})   
                  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga XLS                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDirectory := Directory(cCliPath + "iqf*.xls*")  
aEval(aDirectory, {|x| FErase(cCliPath + x[1])})   

aDirectory := Directory(cSrvPath + "iqf*.xls*")  
aEval(aDirectory, {|x| FErase(cSrvPath + x[1])})   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura area anterior                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Restarea( aAreaSA2 )
Restarea( aArea )

Return


/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CriaSX1   ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera dicionario de perguntas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/     
Static Function AjustaSX1(cPerg)

Local cKey := ""
Local aHelpEng := {}
Local aHelpPor := {}
Local aHelpSpa := {}

PutSX1(cPerg,"01","Fornecedor         ?","","","mv_ch1","C",06,0,0,"G","","SA2","","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"02","Loja               ?","","","mv_ch2","C",02,0,0,"G","",""   ,"","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","")     
PutSX1(cPerg,"03","Ano Base           ?","","","mv_ch3","C",04,0,0,"G","",""   ,"","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","")     
PutSX1(cPerg,"04","Enviar por E-mail  ?","","","mv_ch4","N",01,0,0,"C","",""   ,"","","mv_par04","Sim","","","","Nao","","","","","","","","","","","","","","","","","","","","","","")     
PutSX1(cPerg,"05","Visualizar Arquivo ?","","","mv_ch5","N",01,0,0,"C","",""   ,"","","mv_par05","Sim","","","","Nao","","","","","","","","","","","","","","","","","","","","","","")     

cKey     := "P." + cPerg + "01."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe o codigo do fornecedor.")
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
aAdd(aHelpPor,"Informe o codigo da loja.")
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
aAdd(aHelpPor,"Informe o Ano Base.")
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
aAdd(aHelpPor,"Envia um e-mail de maneira automatica ao")
aAdd(aHelpPor,"com o arquivo da planilha em anexo.")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P." + cPerg + "05."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Abre o arquivo para visualizacao apos")
aAdd(aHelpPor,"processamento das informações.")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

Return 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ENVEMAIL ³ Autor ³ Tiago Oliveira Beraldi³ Data ³ 21/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia e-mail do Orcamento para o Cliente                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Euroamerican                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function EnvEmail( cEmail, cAnexo )

Local cSrvMail  := AllTrim(GetMV("MV_RELSERV"))
Local cUserAut  := AllTrim(GetMV("MV_RELACNT")) 
Local cPassAut  := AllTrim(GetMV("MV_RELPSW"))  
Local cAuthent	:= AllTrim(GetMV("MV_RELAUTH")) 

Local cDe		:= UsrRetMail(__cUserID)
Local cPara		:= Lower(AllTrim(cEmail))
Local cCc		:= ""
Local cCco		:= FATR072UsrRetMail(__cUserID)
Local cSubject	:= "Indice de Qualidade de Fornecimento - " + AllTrim(SM0->M0_NOMECOM)
Local cBody		:= "E-mail enviado automaticamente."  
Local cAttach	:= cAnexo

CONNECT SMTP SERVER cSrvMail ACCOUNT cUserAut PASSWORD cPassAut TIMEOUT 60 RESULT lOk

If (lOk)
	
	If cAuthent == ".T."
		MAILAUTH(cUserAut, cPassAut)
	EndIf
	
	SEND MAIL FROM cDe TO cPara ;
	BCC cCco ;
	CC cCc ;
	SUBJECT cSubject ;
	BODY cBody ;
	ATTACHMENT cAttach ;
	RESULT lOK     
	
	DISCONNECT SMTP SERVER
	
Endif

If (lOk)
	MsgInfo("A mensagem foi enviada com sucesso!", "IQF")
Else
	MsgStop("Ocorreu uma falha ao tentar enviar a mensagem!","IQF")
Endif

Return