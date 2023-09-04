#include "protheus.ch"   
#include "topconn.ch"

User Function BeRPrPRe() // Relatorio Apontamento de Produ玢o Previsto x Realizado

Local oReport

Private cPerg	:= Padr("BERPRE0001", 10)

ValidPerg()

oReport := ReportDef()
oReport:PrintDialog()

Return

Static Function ReportDef()

Local oReport  
Local oSection1
Local cPictVal

oReport := TReport():New("BeRPrPRe","Rela玢o Horas Previsto x Realizado","BERPRE0001",{|oReport| ReportPrint(oReport)},"Imprime Rela玢o das Horas de apontamentos Previsto x Realizado.")

oReport:SetLandScape(.T.)
oReport:SetTotalInLine(.F.) // Imprime o total em linhas

Pergunte("BERPRE0001",.F.)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Inicia Se玢o                							  ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
oSection1 := TRSection():New(oReport,"Rela玢o Horas Previsto x Realizado",{""},{"Por Ord. Prod."})
oSection1:SetHeaderPage()

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Define c?ulas                							  ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
TRCell():New(oSection1,"H6_FILIAL"	,,"Filial"			,,10	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"H6_PRODUTO"	,,"Produto"			,,20	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"B1_DESC"	,,"Descri玢o"		,,40	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"B1_TIPO"	,,"Tipo"			,,10	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"C2_CC"		,,"C.Custo"			,,15	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"C2_LOCAL"	,,"Local"			,,10	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"H6_DTAPONT"	,,"Dt. Apont."		,,15	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"H6_OP"		,,"Ord. Producao"	,,20	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"H6_OPERAC"	,,"Cod. Oper."		,,10	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"G2_DESCRI"	,,"Operacao"		,,40	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"H6_TEMPO"	,,"Tempo Real"		,,20	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"TEMPAD"	    ,,"Tempo Padrao"	,,20	,.F.	,,,,,,,.F.)  

oSection1:SetColSpace(0)

Return oReport

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北?rograma  ?eportPrint?Autor ?odrigo Sousa          ?Data ?5.08.12  潮?
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北?escri噮o ? funcao estatica ReportDef devera ser criada para todos os  潮?
北?         ?elatorios que poderao ser agendados pelo usuario.           潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?etorno   ?enhum                                                       潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?arametros?xpO1: Objeto Report do Relat?io                            潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?  DATA   ?Programador   ?anutencao efetuada                          潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北?         ?              ?                                            潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Static Function ReportPrint(oReport)

Local oBreak
Local oSection1  	:= oReport:Section(1)

Local nOrdem 		:= oSection1:GetOrder()
Local cTipo			:= ""

Local cFilterUser	
Local cRepTit		:= oReport:Title()

Local aDados[12]

Private cAlias		:= GetNextAlias()

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
//?Define bloco de c?igo na impress? das c?ulas		  	  ?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
oSection1:Cell("H6_FILIAL" 	):SetBlock( { || aDados[01]   	})
oSection1:Cell("H6_PRODUTO"	):SetBlock( { || aDados[02]   	})
oSection1:Cell("B1_DESC"  	):SetBlock( { || aDados[03]   	})
oSection1:Cell("B1_TIPO"  	):SetBlock( { || aDados[04]   	})
oSection1:Cell("C2_CC" 		):SetBlock( { || aDados[05]   	})
oSection1:Cell("C2_LOCAL"   ):SetBlock( { || aDados[06]   	})
oSection1:Cell("H6_DTAPONT" ):SetBlock( { || aDados[07]   	})
oSection1:Cell("H6_OP"   	):SetBlock( { || aDados[08]   	})
oSection1:Cell("H6_OPERAC"  ):SetBlock( { || aDados[09]   	})
oSection1:Cell("G2_DESCRI"  ):SetBlock( { || aDados[10]   	})
oSection1:Cell("H6_TEMPO"   ):SetBlock( { || aDados[11]   	})
oSection1:Cell("TEMPAD"   	):SetBlock( { || aDados[12]   	})

oReport:NoUserFilter()

oSection1:Init()

aFill(aDados,nil)

cTitulo := ""

cQuery := "SELECT H6_FILIAL, H6_PRODUTO, B1_DESC, B1_TIPO, C2_CC, C2_LOCAL, H6_DTAPONT, H6_OP, H6_OPERAC, G2_DESCRI, H6_TEMPO, "+CRLF
cQuery += "CONVERT(CHAR(5), DATEADD(MINUTE, 60*G2_TEMPAD, 0), 108) AS TEMPAD "+CRLF
cQuery += "FROM "+RetSqlName("SH6")+" AS SH6 "+CRLF
cQuery += "LEFT JOIN "+RetSqlName("SG2")+" AS SG2  ON G2_FILIAL = '" + xFilial("SG2") + "' AND G2_PRODUTO = H6_PRODUTO AND G2_OPERAC = H6_OPERAC AND SG2.D_E_L_E_T_ = '' "+CRLF
cQuery += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 ON B1_FILIAL = '' AND B1_COD = H6_PRODUTO AND SB1.D_E_L_E_T_ = '' "+CRLF
cQuery += "INNER JOIN "+RetSqlName("SC2")+" AS SC2 ON C2_FILIAL = H6_FILIAL AND H6_OP = C2_NUM + C2_ITEM + C2_SEQUEN AND SC2.D_E_L_E_T_ = '' "+CRLF
cQuery += "WHERE H6_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+CRLF
cQuery += "AND H6_PRODUTO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+CRLF
cQuery += "AND C2_LOCAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "+CRLF
cQuery += "AND H6_DTAPONT BETWEEN '"+DtoS(MV_PAR07)+"' AND '"+DtoS(MV_PAR08)+"' "+CRLF
cQuery += "AND SH6.D_E_L_E_T_ = '' "+CRLF
cQuery += "ORDER BY H6_FILIAL, H6_OP, H6_PRODUTO "

If Select((cAlias)) <> 0
	(cAlias)->( dbCloseArea() )
EndIf

TCQuery cQuery New Alias (cAlias)
TCSetField( (cAlias),"H6_DTAPONT","D")

While !(cAlias)->(Eof()) 

	oReport:IncMeter()
	
	If oReport:Cancel()
		Exit
	EndIf

	aDados[01]	:= (cAlias)->H6_FILIAL
	aDados[02]	:= (cAlias)->H6_PRODUTO
	aDados[03]	:= (cAlias)->B1_DESC
	aDados[04]	:= (cAlias)->B1_TIPO
	aDados[05]	:= (cAlias)->C2_CC
	aDados[06]	:= (cAlias)->C2_LOCAL
	aDados[07]	:= (cAlias)->H6_DTAPONT
	aDados[08]	:= (cAlias)->H6_OP
	aDados[09]	:= (cAlias)->H6_OPERAC
	aDados[10]	:= (cAlias)->G2_DESCRI
	aDados[11]	:= (cAlias)->H6_TEMPO
	aDados[12]	:= (cAlias)->TEMPAD
		
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
	//?Imprime Linha 	 		 								  ?
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪?
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
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪目北
北?un噮o    ?alidPerg ?Autor ?Rodrigo Sousa  		?Data ?15.08.12  潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪拇北
北?escri噮o ?Parametros da rotina.                					   潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Static Function ValidPerg()

Local aArea := GetArea()
Local aPerg := {}

cPerg := cPerg

Aadd(aPerg, {cPerg, "01", "Da Filial 	?" , "MV_CH1" , 	"C", 04	, 0	, "G"	, "MV_PAR01", ""	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "02", "At?a Filial	?" , "MV_CH2" , 	"C", 04	, 0	, "G"	, "MV_PAR02", ""	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "03", "Do Produto 	?" , "MV_CH3" , 	"C", 15	, 0	, "G"	, "MV_PAR03", "SB1"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "04", "At?o Produto?" , "MV_CH4" , 	"C", 15	, 0	, "G"	, "MV_PAR04", "SB1"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "05", "Do Local 	?" , "MV_CH5" , 	"C", 02	, 0	, "G"	, "MV_PAR05", "NNR"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "06", "At?o Local  ?" , "MV_CH6" , 	"C", 02	, 0	, "G"	, "MV_PAR06", "NNR"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "07", "Da Dt. Apont.?" , "MV_CH7" , 	"D", 08	, 0	, "G"	, "MV_PAR07", ""	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "08", "At?Dt. Apont.?", "MV_CH8" , 	"D", 08	, 0	, "G"	, "MV_PAR08", ""	,""		,""				,""				,"",""})

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