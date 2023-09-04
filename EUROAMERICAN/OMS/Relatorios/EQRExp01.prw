#include 'protheus.ch'
#include 'rwmake.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

#Define 	XCARGA		1
#Define 	XNF			2
#Define 	XSERIE		3
#Define 	XITEM		4
#Define		XCLIENTE	5
#Define		XMUN		6
#Define		XEST		7
#Define		XCTRANSP	8
#Define		XNTRANSP	9
#Define		XPESO		10
#Define     XVALOR		11
#Define		XPERC		12
#Define		XVALPESO	13
#Define		XEMISSAONF	14
#Define		XEMISSAOCG	15
#Define		XTIMECOL	16
#Define		XDTENTR		17
#Define		XEMISENTR	18
#Define		XMUNCLI		19
#Define		XESTCLI		20

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
User Function EQRExp01()

Local oReport

Private cPerg	:= "EQRE01"

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

oReport := TReport():New("EQRExp","Relatório de Desempenho Logistico","EQRE01",{|oReport| ReportPrint(oReport)},"Imprime Relação de Desempenho logistico.") 

oReport:SetLandScape(.T.)
oReport:SetTotalInLine(.F.) // Imprime o total em linhas
oReport:ShowParamPage(.T.)

Pergunte("EQRE01",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia Seção                							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oReport,"Relatorio de Desempenho Logistico",{"SZF"},{"Por Periodo"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define células                							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRCell():New(oSection1,"ZG_NOTA"	,		,"Nota Fiscal"				,							,30			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"ZG_SERIE"	,		,"Série"					,							,05			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"A1_NOME"	,		,"Cliente"					,							,50			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"A1_MUN"		,		,"Mun. Cliente"				,							,30			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"A1_EST"		,		,"Est. Cliente"				,							,10			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"ZG_MUN"		,		,"Mun. Entrega"				,							,30			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"ZG_EST"		,		,"Est. Entrega"				,							,10			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"ZF_TRANSP"	,		,"Cod. Transp."				,							,10			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"A4_NOME"	,		,"Nome Transp."				,							,50			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"ZF_NUM"		,		,"Carga"					,							,10			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"ZG_ITEM"	,		,"Item"						,							,05			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"ZG_PESO"	,		,"Peso"						, PesqPict("SZG","ZG_PESO")	,25			,.F.	,,,,,,,.F.)
TRCell():New(oSection1,"ZG_VALOR"	,		,"Valor dos produtos"   	, PesqPict("SZG","ZG_VALOR"),25			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"PERC"		,		,"% Prop."					, "@E 999,999.99"			,25			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"VLRPESO"	,		,"Valor Frete Peso"			, "@E 999,999,999.9999"		,30			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"F2_EMISSAO"	,		,"Emissão NF"				,							,15			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"ZF_EMISSAO"	,		,"Emissão Carga"			,							,15			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"TIMECOLETA"	,		,"Time Coleta"				, "@E 9999"					,15			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"ZG_DTENTR"	,		,"Data Entrega"				,							,15			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"EMISENTR"	,		,"Emis. Até Entrega"		, "@E 9999"					,15			,.F.	,,,,,,,.F.)  

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

Local cFilterUser	
Local cRepTit		:= oReport:Title()

Local aDados[20]

Private cAlias		:= GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define bloco de código na impressão das células		  	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:Cell("ZG_NOTA"   	):SetBlock( { || aDados[XNF]   		})
oSection1:Cell("ZG_SERIE"  	):SetBlock( { || aDados[XSERIE]   	})
oSection1:Cell("A1_NOME"   	):SetBlock( { || aDados[XCLIENTE]   })
oSection1:Cell("A1_MUN"   	):SetBlock( { || aDados[XMUNCLI]   	})
oSection1:Cell("A1_EST" 	):SetBlock( { || aDados[XESTCLI]   	})
oSection1:Cell("ZG_MUN"   	):SetBlock( { || aDados[XMUN]   	})
oSection1:Cell("ZG_EST"   	):SetBlock( { || aDados[XEST]   	})
oSection1:Cell("ZF_TRANSP" 	):SetBlock( { || aDados[XCTRANSP]   })
oSection1:Cell("A4_NOME"   	):SetBlock( { || aDados[XNTRANSP]   })
oSection1:Cell("ZF_NUM"   	):SetBlock( { || aDados[XCARGA]   	})
oSection1:Cell("ZG_ITEM"   	):SetBlock( { || aDados[XITEM]   	})
oSection1:Cell("ZG_PESO"   	):SetBlock( { || aDados[XPESO]   	})
oSection1:Cell("ZG_VALOR"  	):SetBlock( { || aDados[XVALOR]   	})
oSection1:Cell("PERC"   	):SetBlock( { || aDados[XPERC]   	})
oSection1:Cell("VLRPESO"   	):SetBlock( { || aDados[XVALPESO]   })
oSection1:Cell("F2_EMISSAO"	):SetBlock( { || aDados[XEMISSAONF] })
oSection1:Cell("ZF_EMISSAO"	):SetBlock( { || aDados[XEMISSAOCG] })
oSection1:Cell("TIMECOLETA"	):SetBlock( { || aDados[XTIMECOL]   })
oSection1:Cell("ZG_DTENTR" 	):SetBlock( { || aDados[XDTENTR]   	})
oSection1:Cell("EMISENTR"  	):SetBlock( { || aDados[XEMISENTR]  })

oReport:NoUserFilter()

oSection1:Init()

aFill(aDados,nil)

cTitulo := "Relação Desempenho Logistico"

cFilterUser := oSection1:GetSqlExp("SZF")

/*
cQuery := "SELECT ZG_EMPFIL, ZF_NUM, ZG_NOTA, ZG_SERIE, ZG_ITEM,ZG_CLIENTE, ZG_LOJA, "+CRLF
cQuery += "ISNULL(SA1020.A1_NOME,ISNULL(SA1080.A1_NOME, SA1090.A1_NOME )) AS A1_NOME,"+CRLF
cQuery += "ISNULL(SA1020.A1_MUN,ISNULL(SA1080.A1_MUN,SA1090.A1_MUN)) AS A1_MUN,"+CRLF
cQuery += "ISNULL(SA1020.A1_EST,ISNULL(SA1080.A1_EST,SA1090.A1_EST)) AS A1_EST,"+CRLF
cQuery += "ZG_MUN, ZG_EST, ZF_TRANSP, A4_NOME, "+CRLF
cQuery += "ZG_PESO, ZG_VALOR, ZF_PESO, ZF_VALOR,"+CRLF
cQuery += "(CASE WHEN ZG_PESO = 0 OR ZF_PESO = 0 THEN 0 ELSE ROUND(ZG_PESO/ZF_PESO,3) END) AS PERC, "+CRLF
cQuery += "(CASE WHEN (ZG_PESO = 0 OR ZF_PESO = 0) AND ZF_FRETEP <= 0  THEN 0 ELSE ROUND(ZF_FRETEP * Round(ZG_PESO/ZF_PESO,3),4) END) AS VLRPESO,"+CRLF
cQuery += "ISNULL(SF2020.F2_EMISSAO,ISNULL(SF2080.F2_EMISSAO,SF2090.F2_EMISSAO)) AS F2_EMISSAO,"+CRLF
cQuery += "ZF_EMISSAO, ZG_DTENTR, ZF_STATUS"+CRLF
cQuery += "FROM SZF000 SZF"+CRLF
cQuery += "INNER JOIN SA4000 AS SA4 ON A4_COD = ZF_TRANSP AND SA4.D_E_L_E_T_ = ''"+CRLF
cQuery += "INNER JOIN SZG000 AS SZG ON ZG_NUM = ZF_NUM AND SZG.D_E_L_E_T_ = ''"+CRLF
cQuery += "LEFT JOIN SF2020 ON SUBSTRING(ZG_EMPFIL,1,2) = '02' AND SF2020.F2_FILIAL = SUBSTRING(ZG_EMPFIL,3,2) AND SF2020.F2_DOC = ZG_NOTA AND SF2020.F2_SERIE = ZG_SERIE AND SF2020.D_E_L_E_T_ = ''"+CRLF
cQuery += "LEFT JOIN SF2080 ON SUBSTRING(ZG_EMPFIL,1,2) = '08' AND SF2080.F2_FILIAL = SUBSTRING(ZG_EMPFIL,3,2) AND SF2080.F2_DOC = ZG_NOTA AND SF2080.F2_SERIE = ZG_SERIE AND SF2080.D_E_L_E_T_ = ''"+CRLF
cQuery += "LEFT JOIN SF2090 ON SUBSTRING(ZG_EMPFIL,1,2) = '09' AND SF2090.F2_FILIAL = SUBSTRING(ZG_EMPFIL,3,2) AND SF2090.F2_DOC = ZG_NOTA AND SF2090.F2_SERIE = ZG_SERIE AND SF2090.D_E_L_E_T_ = ''"+CRLF
cQuery += "LEFT JOIN SA1020 ON SUBSTRING(ZG_EMPFIL,1,2) = '02' AND SA1020.A1_FILIAL = SUBSTRING(ZG_EMPFIL,3,2) AND SA1020.A1_COD = ZG_CLIENTE AND SA1020.A1_LOJA = ZG_LOJA AND SA1020.D_E_L_E_T_ = ''"+CRLF
cQuery += "LEFT JOIN SA1080 ON SUBSTRING(ZG_EMPFIL,1,2) = '08' AND SA1080.A1_FILIAL = SUBSTRING(ZG_EMPFIL,3,2) AND SA1080.A1_COD = ZG_CLIENTE AND SA1080.A1_LOJA = ZG_LOJA AND SA1080.D_E_L_E_T_ = ''"+CRLF
cQuery += "LEFT JOIN SA1090 ON SUBSTRING(ZG_EMPFIL,1,2) = '09' AND SA1090.A1_FILIAL = SUBSTRING(ZG_EMPFIL,3,2) AND SA1090.A1_COD = ZG_CLIENTE AND SA1090.A1_LOJA = ZG_LOJA AND SA1090.D_E_L_E_T_ = ''"+CRLF
cQuery += "WHERE SZF.D_E_L_E_T_=''"+CRLF
cQuery += "AND ZF_STATUS <> '7' "+CRLF
cQuery += "AND ZF_FILIAL = ''"+CRLF
cQuery += "AND ZF_EMISSAO BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "+CRLF
cQuery += "AND A4_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+CRLF
cQuery += "ORDER BY ZF_NUM"+CRLF
*/
cQuery := "SELECT ZG_EMPFIL, ZF_NUM, ZG_NOTA, ZG_SERIE, ZG_ITEM,ZG_CLIENTE, ZG_LOJA, "+CRLF
cQuery += "A1_NOME,"+CRLF
cQuery += "A1_MUN,"+CRLF
cQuery += "A1_EST,"+CRLF
cQuery += "ZG_MUN, ZG_EST, ZF_TRANSP, A4_NOME, "+CRLF
cQuery += "ZG_PESO, ZG_VALOR, ZF_PESO, ZF_VALOR,"+CRLF
cQuery += "(CASE WHEN ZG_PESO = 0 OR ZF_PESO = 0 THEN 0 ELSE ROUND(ZG_PESO/ZF_PESO,3) END) AS PERC, "+CRLF
cQuery += "(CASE WHEN (ZG_PESO = 0 OR ZF_PESO = 0) AND ZF_FRETEP <= 0  THEN 0 ELSE ROUND(ZF_FRETEP * Round(ZG_PESO/ZF_PESO,3),4) END) AS VLRPESO,"+CRLF
cQuery += "F2_EMISSAO,"+CRLF
cQuery += "ZF_EMISSAO, ZG_DTENTR, ZF_STATUS"+CRLF
cQuery += "FROM " + RetSqlName("SZF") + " SZF"+CRLF
cQuery += "INNER JOIN " + RetSqlName("SA4") + " AS SA4 ON A4_COD = ZF_TRANSP AND SA4.D_E_L_E_T_ = ''"+CRLF
cQuery += "INNER JOIN " + RetSqlName("SZG") + " AS SZG ON ZG_NUM = ZF_NUM AND SZG.D_E_L_E_T_ = ''"+CRLF
cQuery += "LEFT JOIN " + RetSqlName("SF2") + " ON F2_FILIAL = ZG_EMPFIL AND F2_DOC = ZG_NOTA AND F2_SERIE = ZG_SERIE AND SF2100.D_E_L_E_T_ = ''"+CRLF
cQuery += "LEFT JOIN " + RetSqlName("SA1") + " ON A1_FILIAL = ZG_EMPFIL AND A1_COD = ZG_CLIENTE AND A1_LOJA = ZG_LOJA AND SA1100.D_E_L_E_T_ = ''"+CRLF
cQuery += "WHERE SZF.D_E_L_E_T_=''"+CRLF
cQuery += "AND ZF_STATUS <> '7' "+CRLF
cQuery += "AND ZF_FILIAL = ''"+CRLF
cQuery += "AND ZF_EMISSAO BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "+CRLF
cQuery += "AND A4_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+CRLF
cQuery += "ORDER BY ZF_NUM"+CRLF

ConOut(cQuery)                                          

If Select((cAlias)) <> 0
	(cAlias)->( dbCloseArea() )
EndIf

TCQuery cQuery New Alias (cAlias)                         

TCSetField((cAlias), "F2_EMISSAO", "D")
TCSetField((cAlias), "ZF_EMISSAO", "D")
TCSetField((cAlias), "ZG_DTENTR", "D")

nTotsRec := (cAlias)->(RecCount())
oReport:SetMeter(nTotsRec)

While !(cAlias)->(Eof()) 

	oReport:IncMeter()
	
	If oReport:Cancel()
		Exit
	EndIf
	
	aDados[XCARGA]		:= (cAlias)->ZF_NUM
	aDados[XNF]			:= (cAlias)->ZG_NOTA
	aDados[XSERIE]		:= (cAlias)->ZG_SERIE
	aDados[XITEM]		:= (cAlias)->ZG_ITEM
	aDados[XCLIENTE]	:= (cAlias)->A1_NOME
	aDados[XMUNCLI]		:= (cAlias)->A1_MUN
	aDados[XESTCLI]		:= (cAlias)->A1_EST
	aDados[XMUN]		:= (cAlias)->ZG_MUN
	aDados[XEST]		:= (cAlias)->ZG_EST
	aDados[XCTRANSP]	:= (cAlias)->ZF_TRANSP
	aDados[XNTRANSP]	:= (cAlias)->A4_NOME
	aDados[XPESO]		:= (cAlias)->ZG_PESO
	aDados[XVALOR]		:= (cAlias)->ZG_VALOR
	aDados[XPERC]		:= (cAlias)->PERC
	aDados[XVALPESO]	:= (cAlias)->VLRPESO
	aDados[XEMISSAONF]	:= DtoC((cAlias)->F2_EMISSAO)
	aDados[XEMISSAOCG]	:= DtoC((cAlias)->ZF_EMISSAO)
	aDados[XTIMECOL]	:= CalcDiaUt((cAlias)->F2_EMISSAO,(cAlias)->ZF_EMISSAO)
	aDados[XDTENTR]		:= DtoC((cAlias)->ZG_DTENTR)
	aDados[XEMISENTR]	:= CalcDiaUt((cAlias)->F2_EMISSAO, (cAlias)->ZG_DTENTR)

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

Aadd(aPerg, {cPerg, "01", "Da Dt. Carga     ?", "MV_CH1" , 	"D", 08	, 0	, "G"	, "MV_PAR01", ""	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "02", "Até a Dt. Carga  ?", "MV_CH2" , 	"D", 08	, 0	, "G"	, "MV_PAR02", ""	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "03", "Da Transp.		?", "MV_CH3" , 	"C", 06	, 0	, "G"	, "MV_PAR03", "SA4"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "04", "Até a Transp.	?", "MV_CH4" , 	"C", 06	, 0	, "G"	, "MV_PAR04", "SA4"	,""		,""				,""				,"",""})

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

//Retorna dias Uteis
Static Function CalcDiaUt(dDtIni,dDtFim)

Local nRet := 0

While dDtIni < dDtFim .And. !Empty(dDtIni) .And. !Empty(dDtFim)

	If DataValida(dDtIni,.T.) == dDtIni
		nRet += 1	
	EndIf        
	
	dDtIni := dDtIni + 1

EndDo

Return nRet
