#include 'protheus.ch'
#include 'rwmake.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

#Define 	CODPROD		1
#Define 	DESCPROD	2
#Define 	TIPOPROD	3
#Define 	UMPROD		4
#Define		QTDATU		5
#Define		VLRATU		6
#Define		QTDVEND		7

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ³ Autor ³ 		³ Data ³ 15.08.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ ³±±
±±³ 		 ³ ³±±
±±³ 		 ³ 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function JayRDem1()

Local oReport

Private cPerg	:= "JARDEM"

ValidPerg()

oReport := ReportDef()
oReport:PrintDialog()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ReportDef³ Autor ³         ³ Data ³ 15.08.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definicao do layout do Relatorio							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local oReport  
Local oSection1
Local cPictVal
Local nTamCli,nTamTit,nTamCtr,nTamDte,nTamVal,nTamPro

oReport := TReport():New("JayRDem1","Relatorio de Demanda Por Periodo","JARDEM",{|oReport| ReportPrint(oReport)},"Imprime Relação de demanda por periodo.")

oReport:SetPortrait(.T.)
oReport:SetTotalInLine(.F.) // Imprime o total em linhas
oReport:ShowParamPage(.T.)

Pergunte("JARDEM",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia Seção                							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oReport,"Relatorio de Demanda Por Periodo",{"SB1"},{"Por Periodo"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define células                							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRCell():New(oSection1,"B1_COD"		,		,"Produto"					,							,30			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"B1_DESC"	,		,"Descrição"				,							,45			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"B1_TIPO"	,		,"Tipo"						,							,10			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"B1_UM"		,		,"U.M."						,							,10			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"QTD_ATUAL"	,		,"Quantidade Atual"			, PesqPict("SB2","B2_QATU")	,20			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"VALOR_ATUAL",		,"Valor Atual"				, PesqPict("SB2","B2_VATU1"),20			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"QTD_VENDIDA",		,"Quantidade Vendida"		, PesqPict("SB2","B2_QATU")	,20			,.F.	,,,,,,,.F.)  

oSection1:SetColSpace(0)

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Rodrigo Sousa          ³ Data ³15.08.12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os  ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint(oReport)

Local oBreak
Local oSection1  	:= oReport:Section(1)

Local nOrdem 		:= oSection1:GetOrder()
Local nBolRec		:= 0
Local nBolNRec		:= 0
Local nTotsRec 		:= 0

Local cFilterUser	
Local cRepTit		:= oReport:Title()

Local aDados[7]

Private cAlias		:= GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define bloco de código na impressão das células		  	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:Cell("B1_COD"   	):SetBlock( { || aDados[CODPROD]   	})
oSection1:Cell("B1_DESC"   	):SetBlock( { || aDados[DESCPROD]  	})
oSection1:Cell("B1_TIPO"   	):SetBlock( { || aDados[TIPOPROD]  	})
oSection1:Cell("B1_UM"   	):SetBlock( { || aDados[UMPROD]  	})
oSection1:Cell("QTD_ATUAL" 	):SetBlock( { || aDados[QTDATU]  	})
oSection1:Cell("VALOR_ATUAL"):SetBlock( { || aDados[VLRATU]  	})
oSection1:Cell("QTD_VENDIDA"):SetBlock( { || aDados[QTDVEND] 	})

oReport:NoUserFilter()

oSection1:Init()

aFill(aDados,nil)

cTitulo := "Relação de Demanda Por Periodo"

cFilterUser := oSection1:GetSqlExp("SB1")

//---- Relatorio de Demanda                                    
cQuery := "SELECT CODIGO, DESCRI, TIPO, UM, SUM(QTD_ATUAL) QTD_ATUAL, SUM(VALOR_ATUAL) AS VALOR_ATUAL, SUM(QTD_VENDIDA)	AS QTD_VENDIDA  "+CRLF
cQuery += "FROM  "+CRLF
cQuery += "	(SELECT B1_COD AS CODIGO , B1_DESC AS DESCRI, B1_TIPO AS TIPO, B1_UM AS UM, B2_LOCAL, B2_QATU AS QTD_ATUAL,  "+CRLF
cQuery += "			B2_VATU1 AS VALOR_ATUAL, ISNULL(SUM(D2_QUANT-D2_QTDEDEV),0) as QTD_VENDIDA "+CRLF
cQuery += "		FROM "+RetSqlName("SB1")+" AS SB1  "+CRLF
cQuery += "		INNER JOIN "+RetSqlName("SB2")+" SB2  "+CRLF
cQuery += "			ON B1_COD = B2_COD  "+CRLF
cQuery += "			AND B2_FILIAL = '"+xFilial("SB2")+"'  "+CRLF
cQuery += "			AND SB2.D_E_L_E_T_ = ''  "+CRLF
cQuery += "		LEFT JOIN "+RetSqlName("SD2")+" AS SD2  "+CRLF
cQuery += "			ON D2_FILIAL = '"+xFilial("SD2")+"'  "+CRLF
cQuery += "			AND D2_COD = B1_COD "+CRLF
cQuery += "			AND D2_LOCAL = B2_LOCAL  "+CRLF
cQuery += "			AND D2_EMISSAO BETWEEN '"+DtoS(MV_PAR07)+"' AND '"+DtoS(MV_PAR08)+"' "+CRLF
cQuery += "			AND SD2.D_E_L_E_T_ = ''  "+CRLF
cQuery += "		WHERE SB1.D_E_L_E_T_ = '' "+CRLF
cQuery += "		AND B2_FILIAL = '"+xFilial("SB2")+"'  "+CRLF
cQuery += "		AND B1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+CRLF
cQuery += "		AND B1_GRUPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+CRLF
cQuery += "		AND B1_TIPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "+CRLF
cQuery += "		GROUP BY B1_COD, B1_DESC, B1_TIPO, B1_UM, B2_LOCAL, B2_QATU, B2_VATU1 "+CRLF
cQuery += "		HAVING (SUM(D2_QUANT) > 0 OR SUM(B2_QATU) > 0) "+CRLF
cQuery += "		) AS AGRUPADO "+CRLF
cQuery += "GROUP BY CODIGO, DESCRI, TIPO, UM "+CRLF
cQuery += "ORDER BY QTD_VENDIDA "+CRLF

/*
cQuery := "SELECT B1_COD, B1_DESC, B1_TIPO, B1_UM, SUM(B2_QATU) QTD_ATUAL, SUM(B2_VATU1) VALOR_ATUAL, "+CRLF
cQuery += "ISNULL(SUM(D2_QUANT-D2_QTDEDEV),0) AS QTD_VENDIDA "+CRLF
cQuery += "FROM "+RetSqlName("SB1")+" SB1 "+CRLF
cQuery += "INNER JOIN "+RetSqlName("SB2")+" SB2 "+CRLF
cQuery += "	ON B1_COD = B2_COD "+CRLF 
cQuery += "	AND B2_FILIAL = '"+xFilial("SB2")+"' "+CRLF 
cQuery += "	AND SB2.D_E_L_E_T_ = '' "+CRLF
cQuery += "LEFT JOIN "+RetSqlName("SD2")+" AS SD2 "+CRLF 
cQuery += "	ON D2_FILIAL = '"+xFilial("SD2")+"' "+CRLF 
cQuery += "	AND D2_COD = B1_COD "+CRLF
cQuery += "	AND D2_LOCAL = B2_LOCAL "+CRLF
cQuery += "	AND D2_EMISSAO BETWEEN '"+DtoS(MV_PAR07)+"' AND '"+DtoS(MV_PAR08)+"' "+CRLF
cQuery += "	AND SD2.D_E_L_E_T_ = '' "+CRLF
cQuery += "WHERE SB1.D_E_L_E_T_ = '' "+CRLF
cQuery += "AND B1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+CRLF
cQuery += "AND B1_GRUPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+CRLF
cQuery += "AND B1_TIPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "+CRLF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aplica filtro personalizado se existir								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !empty(cFilterUser)
  	cQuery += " AND ("+ cFilterUser +") "
EndIf
cQuery += "GROUP BY B1_COD, B1_DESC, B1_TIPO, B1_UM, B2_QATU, B2_VATU1 "+CRLF
cQuery += "HAVING (SUM(D2_QUANT) > 0 OR SUM(B2_QATU) > 0)  "+CRLF
cQuery += "ORDER BY QTD_VENDIDA "+CRLF
*/
ConOut(cQuery)                                          

If Select((cAlias)) <> 0
	(cAlias)->( dbCloseArea() )
EndIf

TCQuery cQuery New Alias (cAlias)

nTotsRec := (cAlias)->(RecCount())
oReport:SetMeter(nTotsRec)

While !(cAlias)->(Eof()) 

	oReport:IncMeter()
	
	If oReport:Cancel()
		Exit
	EndIf
	
	aDados[CODPROD]		:= (cAlias)->CODIGO
	aDados[DESCPROD]	:= Substr((cAlias)->DESCRI,1,40)
	aDados[TIPOPROD]	:= (cAlias)->TIPO
	aDados[UMPROD]		:= (cAlias)->UM
	aDados[QTDATU]		:= (cAlias)->QTD_ATUAL
	aDados[VLRATU]		:= (cAlias)->VALOR_ATUAL
	aDados[QTDVEND]		:= (cAlias)->QTD_VENDIDA

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Linha 	 		 								  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1:PrintLine()
	aFill(aDados,nil)
    
	(cAlias)->(dbSkip())

EndDo

oSection1:Finish()

If Select((cAlias)) <> 0
	(cAlias)->( dbCloseArea() )
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ValidPerg ³ Autor ³ Rodrigo Sousa  		³ Data ³ 15.08.12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Parametros da rotina.                					   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValidPerg()

Local aArea := GetArea()
Local aPerg := {}

cPerg := cPerg + Space(4)

Aadd(aPerg, {cPerg, "01", "Do Produto   	?", "MV_CH1" , 	"C", 06	, 0	, "G"	, "MV_PAR01", "SB1"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "02", "Até o Produto	?", "MV_CH2" , 	"C", 06	, 0	, "G"	, "MV_PAR02", "SB1"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "03", "Do Grupo	        ?", "MV_CH3" , 	"C", 04	, 0	, "G"	, "MV_PAR03", "SBM"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "04", "Até o Grupo	    ?", "MV_CH4" , 	"C", 04	, 0	, "G"	, "MV_PAR04", "SBM"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "05", "Do Tipo	        ?", "MV_CH5" , 	"C", 04	, 0	, "G"	, "MV_PAR05", "02"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "06", "Até o Tipo       ?", "MV_CH6" , 	"C", 04	, 0	, "G"	, "MV_PAR06", "02"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "07", "Do Periodo	    ?", "MV_CH7" , 	"D", 08	, 0	, "G"	, "MV_PAR07", ""	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "08", "Até o Periodo    ?", "MV_CH8" , 	"D", 08	, 0	, "G"	, "MV_PAR08", ""	,""		,""				,""				,"",""})

DbSelectArea("SX1")
DbSetOrder(1)

For i := 1 To Len(aPerg)
	IF  !DbSeek(aPerg[i,1]+aPerg[i,2])
		RecLock("SX1",.T.)
	Else
		RecLock("SX1",.F.)
	EndIF
	Replace X1_GRUPO   with aPerg[i,01]
	Replace X1_ORDEM   with aPerg[i,02]
	Replace X1_PERGUNT with aPerg[i,03]
	Replace X1_VARIAVL with aPerg[i,04]
	Replace X1_TIPO	   with aPerg[i,05]
	Replace X1_TAMANHO with aPerg[i,06]
	Replace X1_PRESEL  with aPerg[i,07]
	Replace X1_GSC	   with aPerg[i,08]
	Replace X1_VAR01   with aPerg[i,09]
	Replace X1_F3	   with aPerg[i,10]
	Replace X1_DEF01   with aPerg[i,11]
	Replace X1_DEF02   with aPerg[i,12]
	Replace X1_DEF03   with aPerg[i,13]
	Replace X1_DEF04   with aPerg[i,14]
	Replace X1_DEF05   with aPerg[i,15]
	MsUnlock()
Next i

RestArea(aArea)

Return(.T.)
