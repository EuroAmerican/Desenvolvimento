#include "protheus.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EQ³ Autor ³ Rodrigo Sousa 		³ Data ³ 10.11.14 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³   														  ³±±
±±³ 		 ³ 															  ³±±
±±³ 		 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico                                    			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function EQRIQEPP()

Local oReport

Private cPerg	:= "EQRIQE"

ValidPerg()

oReport := ReportDef()
oReport:PrintDialog()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ReportDef³ Autor ³ Rodrigo Sousa         ³ Data ³  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definicao do layout do Relatorio							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico 	 	 		  	                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local oReport  
Local oSection1
Local cPictVal
Local nTamFil,nTamCod,nTamDesc,nTamQtde

oReport := TReport():New("EQRIQE","Relação IQE Por Produto",cPerg,{|oReport| ReportPrint(oReport)},"Imprime relação de IQE de acordo com os parâmetros.")

oReport:SetLandScap(.T.)
oReport:SetTotalInLine(.F.) 

Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia Seção                							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oReport,"Indice de Qualidade de Entrega",{"SA2","SD1"},{""})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define células                							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRCell():New(oSection1,"A2_COD"		,	,"Código"			,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"A2_LOJA"	,	,"Loja"		,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"A2_NREDUZ"	,	,"Cliente"	,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"D1_DOC"		,	,"Nota Fiscal"			,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"D1_SERIE"	,	,"Série"			,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"C7_NUM"		,	,"Pedido de Compra"			,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"D1_COD"		,	,"Produto"			,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"C7_DATPRF"	,	,"Data Entrega Prevista"			,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"D1_DTDIGIT"	,	,"Data de Entrega Real"		,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"DIAS_ATRASO",	,"Dias de Atraso"			,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"PONTUACAO_DEMERITO"	,	,"Pontuação Demerito"			,	,	,.F.	,,,,,,,.F.)  

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
Local nSeek			:= 0

Local cFilterUser	
Local cRepTit		:= oReport:Title()
Local cDescrMot		:= ""
Local cNomFil		:= ""

Local aDados[11]

Private cAlias		:= GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define bloco de código na impressão das células		  	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:Cell("A2_COD" 	):SetBlock( { || aDados[01]})
oSection1:Cell("A2_LOJA" 	):SetBlock( { || aDados[02]})
oSection1:Cell("A2_NREDUZ" 	):SetBlock( { || aDados[03]})
oSection1:Cell("D1_DOC"  	):SetBlock( { || aDados[04]})
oSection1:Cell("D1_SERIE" 	):SetBlock( { || aDados[05]})
oSection1:Cell("C7_NUM" 	):SetBlock( { || aDados[06]})
oSection1:Cell("D1_COD" 	):SetBlock( { || aDados[07]})
oSection1:Cell("C7_DATPRF" 	):SetBlock( { || aDados[08]})
oSection1:Cell("D1_DTDIGIT"	):SetBlock( { || aDados[09]})
oSection1:Cell("DIAS_ATRASO"):SetBlock( { || aDados[10]})
oSection1:Cell("PONTUACAO_DEMERITO" ):SetBlock( { || aDados[11]})

oReport:NoUserFilter()

oSection1:Init()

aFill(aDados,nil)

cTitulo := "Relação Indice de Qualidade de Entrega"

cQuery	:= "SELECT D1_FILIAL, A2_COD, A2_LOJA, A2_NREDUZ, D1_DOC, D1_SERIE, D1_COD, C7_DATPRF, D1_DTDIGIT, C7_NUM, "+CRLF  
cQuery	+= "CASE WHEN DATEDIFF(DD, C7_DATPRF,  D1_DTDIGIT  ) > 0 THEN DATEDIFF(DD, C7_DATPRF,  D1_DTDIGIT  ) ELSE 0 END AS 'DIAS_ATRASO',"+CRLF
cQuery	+= "ISNULL( CASE	WHEN DATEDIFF(DD, C7_DATPRF,  D1_DTDIGIT  ) <= 0 THEN 0"+CRLF
cQuery	+= "				WHEN DATEDIFF(DD, C7_DATPRF,  D1_DTDIGIT  )  = 1 THEN 20"+CRLF
cQuery	+= "				WHEN DATEDIFF(DD, C7_DATPRF,  D1_DTDIGIT  )  = 2 THEN 50"+CRLF
cQuery	+= "				WHEN DATEDIFF(DD, C7_DATPRF,  D1_DTDIGIT  ) >= 3 THEN 100"+CRLF
cQuery	+= "				END, 0) 'PONTUACAO_DEMERITO'"+CRLF
cQuery	+= "FROM "+RetSqlName("SD1")+" SD1"+CRLF
cQuery	+= "INNER JOIN "+RetSqlName("SA2")+" SA2"+CRLF
cQuery	+= "	ON A2_FILIAL = '"+xFilial("SA2")+"'"+CRLF
cQuery	+= "	AND A2_COD = D1_FORNECE"+CRLF
cQuery	+= "	AND A2_LOJA = D1_LOJA"+CRLF
cQuery	+= "	AND SA2.D_E_L_E_T_ = ''"+CRLF
cQuery	+= "INNER JOIN "+RetSqlName("SC7")+" SC7"+CRLF
cQuery	+= "	ON C7_FILIAL = D1_FILIAL"+CRLF
cQuery	+= "	AND C7_NUM = D1_PEDIDO"+CRLF
cQuery	+= "	AND C7_ITEM = D1_ITEMPC"+CRLF
cQuery	+= "	AND SC7.D_E_L_E_T_ = ''"+CRLF
cQuery	+= "INNER JOIN "+RetSqlName("SB1")+" SB1"+CRLF
cQuery	+= "	ON	SB1.D_E_L_E_T_ = ''"+CRLF
cQuery	+= "	AND	B1_FILIAL = '"+xFilial("SB1")+"'"+CRLF
cQuery	+= "	AND	B1_COD = D1_COD"+CRLF
cQuery	+= "WHERE D1_FILIAL = '"+xFilial("SD1")+"'"+CRLF
cQuery	+= "AND D1_FORNECE BETWEEN '"+mv_par01+"' AND '"+mv_par03+"'"+CRLF
cQuery	+= "AND D1_LOJA BETWEEN '"+mv_par02+"' AND '"+mv_par04+"'"+CRLF
cQuery	+= "AND D1_DTDIGIT BETWEEN '"+DtoS(mv_par05)+"' AND '"+DtoS(mv_par06)+"'"+CRLF
cQuery	+= "AND B1_TIPO IN ('ME', 'MP')"+CRLF
cQuery	+= "AND SD1.D_E_L_E_T_ = ''"+CRLF

MemoWrite("eqriqepp.sql",cQuery)

TCQuery cQuery New Alias (cAlias)
TcSetField((cAlias),"C7_DATPRF","D")
TcSetField((cAlias),"D1_DTDIGIT","D")

nTotsRec := (cAlias)->(RecCount())
oReport:SetMeter(nTotsRec)

While !(cAlias)->(Eof()) 

	oReport:IncMeter()

	If oReport:Cancel()
		Exit
	EndIf

	aDados[1]	:= (cAlias)->A2_COD
	aDados[2]	:= (cAlias)->A2_LOJA
	aDados[3]	:= (cAlias)->A2_NREDUZ
	aDados[4]	:= (cAlias)->D1_DOC
	aDados[5]	:= (cAlias)->D1_SERIE
	aDados[6]	:= (cAlias)->C7_NUM
	aDados[7]	:= (cAlias)->D1_COD
	aDados[8]	:= DtoC((cAlias)->C7_DATPRF)
	aDados[9]	:= DtoC((cAlias)->D1_DTDIGIT)
	aDados[10]	:= (cAlias)->DIAS_ATRASO
	aDados[11]	:= (cAlias)->PONTUACAO_DEMERITO

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

Aadd(aPerg, {cPerg, "01", "Do Fornecedor?"		, "MV_CH1" , 	"C", 06	, 0	, "G"	, "MV_PAR01", "SA2"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "02", "Da Loja?"			, "MV_CH2" , 	"C", 02	, 0	, "G"	, "MV_PAR02", ""	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "03", "Até o Fornecedor?"	, "MV_CH3" , 	"C", 06	, 0	, "G"	, "MV_PAR03", "SA2"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "04", "Até a Loja?"			, "MV_CH4" , 	"C", 02	, 0	, "G"	, "MV_PAR04", ""	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "05", "Da Entrega?"			, "MV_CH5" , 	"D", 08	, 0	, "G"	, "MV_PAR05", ""	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "06", "Até a Entrega?"		, "MV_CH6" , 	"D", 08	, 0	, "G"	, "MV_PAR06", ""	,""		,""				,""				,"",""})

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