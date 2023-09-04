#include "protheus.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BeRnkNFE ³ Autor ³ Rodrigo Sousa 		³ Data ³ 24.04.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ranking de Lançamentos de Nota fiscal de Entrada   		   ³±±
±±³			 ³ por usuario												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function EQRnkNFE()

Local oReport

Private cPerg	:= "EQRKNF"
Private cItemInc := ""
Private cUserInc := ""

ValidPerg()

If !Pergunte(cPerg, .T.)
	ApMsgInfo('Relatório Cancelado', 'Atenção')
	Return
EndIf

LjMsgRun( "Gerando o arquivo, aguarde...", "Ranking de Lançamentos NFE", {|| fImpExcel() } )

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fImpExcel  ³ Autor ³ Rodrigo              ³ Data ³ 02.10.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exporta para Excel	        		  	     				³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fImpExcel

Local lImpCab	:= .F.
Local lPrimeira	:= .T.

Local cUsrAnt	:= ""

Local nTotInc 	:= 0
Local nTotExc 	:= 0		

Local nWorkSheet := 0
Local cWorkSheet := ""
Local cTable	 := ""

Local oExcel 	:= FwMsExcel():New()

Local aRnkTot	:= {} 
Private aItens	:= {}

CarregaDados()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ordena Por Usuario										  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aItens := aSort(aItens,,, {|x,y| x[9]+DtoS(x[7]) < y[9]+DtoS(y[7]) })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Relatorio Sintético									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par03 == 1

	For nX := 1 to Len(aItens)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica aglutinação do Item								³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cUsrAnt == aItens[nX][09]
			Loop			
		EndIf			 

		If mv_par03 == 1
			aEval( aItens, {|x| iif(x[9] == aItens[nX][09] .And. Empty(Alltrim(x[10]))	, nTotInc 	+= 1, 0 ) })
			aEval( aItens, {|x| iif(x[9] == aItens[nX][09] .And. !Empty(Alltrim(x[10]))	, nTotExc 	+= 1, 0 ) })
		
			aAdd( aRnkTot , { aItens[nX][09], nTotInc, nTotExc })

			nTotInc := 0
			nTotExc := 0		

		EndIf

		cUsrAnt := aItens[nX][09]

	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ordena Por Usuario										  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aItens := aSort(aRnkTot,,, {|x,y| x[2] > y[2] })

	For nY := 1 to Len(aRnkTot)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Cabeçalho											³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lPrimeira

			cWorkSheet 	:= "Plan1"
			cTable		:= "Ranking de Lançamentos de NF de Entrada"
			
			oExcel:AddworkSheet(cWorkSheet)
			oExcel:AddTable(cWorkSheet,cTable)

			oExcel:AddColumn(cWorkSheet,cTable,"Usuario",1,1)
			oExcel:AddColumn(cWorkSheet,cTable,"NFs Incluidas",1,1)
			oExcel:AddColumn(cWorkSheet,cTable,"NFs Excluidas",1,1)

			lPrimeira := .F.

		EndIf	

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Ranking												³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oExcel:AddRow(cWorkSheet,cTable,{	aRnkTot[nY][01],;
											aRnkTot[nY][02],;
											aRnkTot[nY][03]})								
													
    Next nY

	oExcel:AddRow(cWorkSheet,cTable,{"","",""})								
	oExcel:AddRow(cWorkSheet,cTable,{"Emitido em: "+DtoC(ddatabase)+" "+time(),"",""})								
	oExcel:AddRow(cWorkSheet,cTable,{"Parametros","",""})								
	oExcel:AddRow(cWorkSheet,cTable,{"Filial: "+cFilAnt,"",""})								
	oExcel:AddRow(cWorkSheet,cTable,{"Da Digitação: "+DtoC(mv_par01),"",""})								
	oExcel:AddRow(cWorkSheet,cTable,{"Até Digitação: "+DtoC(mv_par02),"",""})								

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Relatorio Analitico									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nWorkSheet	+= 1
	cWorkSheet 	:= "Parametros"
	cTable		:= "Ranking de lançamentos de NFE por Usuario - Analitico"

	oExcel:AddworkSheet(cWorkSheet)
	oExcel:AddTable(cWorkSheet,cTable)

	oExcel:AddColumn(cWorkSheet,cTable,"Parametros",1,1)

	oExcel:AddRow(cWorkSheet,cTable,{""})								
	oExcel:AddRow(cWorkSheet,cTable,{"Emitido em: "+DtoC(ddatabase)+" "+time()})								
	oExcel:AddRow(cWorkSheet,cTable,{"Filial: "+cFilAnt})								
	oExcel:AddRow(cWorkSheet,cTable,{"Da Digitação: "+DtoC(mv_par01)})								
	oExcel:AddRow(cWorkSheet,cTable,{"Até Digitação: "+DtoC(mv_par02)})								

	For nX := 1 to Len(aItens)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica aglutinação do Item								³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cUsrAnt <> aItens[nX][09]
			nWorkSheet	+= 1
			cWorkSheet 	:= aItens[nX][09]
			cTable		:= "Ranking de lançamentos de NFE por Usuario: "+Capital(aItens[nX][09])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria Planilha												³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oExcel:AddworkSheet(cWorkSheet)
			oExcel:AddTable(cWorkSheet,cTable)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime Cabeçalho dos Itens 								³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oExcel:AddColumn(cWorkSheet,cTable,"Usuario",1,1)
			oExcel:AddColumn(cWorkSheet,cTable,"Documento",1,1)
			oExcel:AddColumn(cWorkSheet,cTable,"Série",1,1)
			oExcel:AddColumn(cWorkSheet,cTable,"Fornecedor",1,1)
			oExcel:AddColumn(cWorkSheet,cTable,"Loja",1,1)
			oExcel:AddColumn(cWorkSheet,cTable,"Emissão",1,1,.F.)
			oExcel:AddColumn(cWorkSheet,cTable,"Digitação",1,1,.F.)
			oExcel:AddColumn(cWorkSheet,cTable,"Especie",1,1,.F.)
			oExcel:AddColumn(cWorkSheet,cTable,"Deletado?",1,1,.F.)

		EndIf			 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Ranking												³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oExcel:AddRow(cWorkSheet,cTable,{	aItens[nX][09],;
											aItens[nX][02],;
											aItens[nX][03],;
											aItens[nX][04],;
											aItens[nX][05],;
											aItens[nX][06],;
											aItens[nX][07],;
											aItens[nX][08],;
											Iif(!Empty(aItens[nX][10]),"Sim","Não")})

		cUsrAnt := aItens[nX][09]

	Next nX
EndIf

oExcel:Activate()
oExcel:GetXMLFile(Alltrim(mv_par04)+".xml")                            

oExcelApp := MsExcel():New()
oExcelApp:WorkBooks:Open(Alltrim(mv_par04)+".xml" )
oExcelApp:SetVisible(.T.)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CarregaDados³ Autor ³ Rodrigo Sousa        ³ Data ³ 02/10/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Dados . 	               		  	     				³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CarregaDados()

Local cQuery		:= ""
Local cAlias 		:= GetNextAlias()
Local lRetorno		:= .T.
Local aUser		:= FWSFALLUSERS()
Local cUserInc	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona Itens											  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_EMISSAO, F1_DTDIGIT, F1_ESPECIE, F1_USERLGI, D_E_L_E_T_ as DELET "
cQuery += "FROM "+RetSqlName("SF1")+" SE1 " 
cQuery += "WHERE F1_FILIAL = '"+xFilial("SF1")+"' AND "
cQuery += "F1_DTDIGIT BETWEEN '" + DtoS(mv_par01)+ "' AND '" + DtoS(mv_par02) + "'  "
	                                          
If Select((cAlias)) <> 0
	(cAlias)->( dbCloseArea() )
EndIf

dbSelectArea("SF1")
dbCloseArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa Query											  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TCQuery cQuery New Alias (cAlias)
TCSetField( (cAlias),"F1_EMISSAO","D")
TCSetField( (cAlias),"F1_DTDIGIT","D")

dbSelectArea(cAlias)
dbGoTop()

If (cAlias)->( Eof() )
	lRetorno := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Itens											  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !(cAlias)->(Eof())

    aAdd( aItens,{	(cAlias)->F1_FILIAL,;
    				(cAlias)->F1_DOC,;
    				(cAlias)->F1_SERIE,;
    				(cAlias)->F1_FORNECE,;
    				(cAlias)->F1_LOJA,;
    				(cAlias)->F1_EMISSAO,;
    				(cAlias)->F1_DTDIGIT,;
    				(cAlias)->F1_ESPECIE,;
    				(cAlias)->F1_USERLGI,;
    				(cAlias)->DELET})
	

	(cAlias)->(dbSkip())

EndDo

(cAlias)->(dbCloseArea())

/*For nX := 1 to Len(aItens)
	cItemInc    	:= aItens[nX][09]
	cUserInc		:= FWLeUserlg("cItemInc",1) 												// FWLeUserlg - 1 ou branco Usuario 2 Data 
	aItens[nX][09]	:= cUserInc
Next nX
*/

For nX := 1 to Len(aItens)
	cUserInc		:= (SUBSTR(EMBARALHA(aItens[nX][09],1),3,6))
	If aScan(aUser,{|x|x[2]==cUserInc}) > 0 
		aItens[nX][09]	:= (aUser[aScan(aUser,{|x|x[2]==cUserInc})][3])
	EndIf	
Next nX

Return lRetorno
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

Aadd(aPerg, {cPerg, "01", "Da Digitação        	?", "MV_CH1" , 	"D", 08	, 0	, "G"	, "MV_PAR01", ""	,""				,""					,"","",""})
Aadd(aPerg, {cPerg, "02", "Até a Digitação     	?", "MV_CH2" , 	"D", 08	, 0	, "G"	, "MV_PAR02", ""	,""				,""					,"","",""})
Aadd(aPerg, {cPerg, "03", "Tipo					?", "MV_CH3" , 	"N", 01	, 0	, "C"	, "MV_PAR03", ""	,"Sintético"	,"Analítico"		,"","",""})
Aadd(aPerg, {cPerg, "04", "Diretório   			?", "MV_CH4" , 	"C", 30	, 0	, "G"	, "MV_PAR04", "DIR"	,""				,""					,"","",""})

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
