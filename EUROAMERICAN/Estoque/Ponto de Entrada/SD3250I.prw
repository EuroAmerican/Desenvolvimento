#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} SD3250I - Ponto de Entrada final da gravação da SC2, SB2, SD3
@Description: Ponto de Entrada para gravar o saldo de empenho na fabriacação 
Este ponto de entrada ira verificar o saldo que ira ficar do envase, e 
gerar uma requisição interna de perda para um determinado centro de custo.
Será tratado no final da operação e ira verificar o saldo que restou do empenho. 
@author Fabio Carneiro dos Santos 
@since 06/01/2020
@version 1.0
/*/

User Function SD3250I()

Local aAreaSB1 	:= SB1->(GetArea()) 
Local aAreaSD3 	:= SD3->(GetArea()) 
Local aAreaSH6 	:= SH6->(GetArea()) 
Local aAreaSB8 	:= SB8->(GetArea()) 
Local aAreaSC2 	:= SC2->(GetArea()) 

Local nOpc   	:= 6 //-Opção de execução da rotina, informado nos parâmetros quais as opções possíveis
Local aCabec 	:= {}
Local aItens 	:= {}
Local aLinha 	:= {}
Local aVetor 	:= {}
Local aEmpen 	:= {}
Local lFazBx 	:= .F.
Local cQuery 	:= ""
Local _aCab1 	:= {}
Local _aItem 	:= {}
Local _aTotItem := {}

If !(AllTrim( cEmpAnt ) == "08" .Or. (AllTrim( cEmpAnt ) == "10" .And. AllTrim( cFilAnt ) == "0803")) // Tratar somente Qualy por enquanto, a Euro trata PA por quilo e fica díficil automatizar processo...
	Return Nil
EndIf

If SC2->C2_ITEM == "01"
	cQuery := "UPDATE " + RetSqlName("SD4") + " SET D4_LOTECTL = B8_LOTECTL, D4_NUMLOTE = B8_NUMLOTE, D4_DTVALID = B8_DTVALID, D4_POTENCI = B8_POTENCI " + CRLF
	cQuery += "FROM " + RetSqlName("SD4") + " AS SD4 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = D4_COD " + CRLF
	cQuery += "  AND B1_RASTRO <> 'N' " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) ON B8_FILIAL = D4_FILIAL " + CRLF
	cQuery += "  AND B8_PRODUTO = D4_COD " + CRLF
	cQuery += "  AND B8_LOCAL = D4_LOCAL " + CRLF
	cQuery += "  AND B8_LOTECTL = LEFT( D4_OP, 6) " + CRLF
	cQuery += "  AND SB8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE D4_FILIAL = '" + xFilial("SD4") + "' " + CRLF
	cQuery += "AND D4_OP LIKE '" + SC2->C2_NUM + "%' " + CRLF
	cQuery += "AND SUBSTRING( D4_OP, 7, 2) <> '01' " + CRLF
	cQuery += "AND D4_LOTECTL <> B8_LOTECTL " + CRLF
	cQuery += "AND SD4.D_E_L_E_T_ = ' ' " + CRLF

	TCSqlExec( cQuery )

	cQuery := "SELECT * " + CRLF
	cQuery += "FROM " + RetSqlName("SD4") + " AS SD4 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = D4_COD " + CRLF
	cQuery += "  AND B1_RASTRO <> 'N' " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) ON B8_FILIAL = D4_FILIAL " + CRLF
	cQuery += "  AND B8_PRODUTO = D4_COD " + CRLF
	cQuery += "  AND B8_LOCAL = D4_LOCAL " + CRLF
	cQuery += "  AND B8_LOTECTL = LEFT( D4_OP, 6) " + CRLF
	cQuery += "  AND SB8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE D4_FILIAL = '" + xFilial("SD4") + "' " + CRLF
	cQuery += "AND D4_OP LIKE '" + SC2->C2_NUM + "%' " + CRLF
	cQuery += "AND SUBSTRING( D4_OP, 7, 2) <> '01' " + CRLF
	cQuery += "AND D4_LOTECTL = B8_LOTECTL " + CRLF
	cQuery += "AND SD4.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPSD4"
	dbSelectArea("TMPSD4")
	dbGoTop()

	Do While !TMPSD4->( Eof() )
		dbSelectArea("SD4")
		dbSetOrder(2) // D4_FILIAL, D4_OP, D4_COD, D4_LOCAL
		If SD4->( dbSeek( xFilial("SD4") + TMPSD4->D4_OP + TMPSD4->D4_COD + TMPSD4->D4_LOCAL ) )
			RecLock("SD4", .F.)
				SD4->D4_QUANT   := TMPSD4->D4_QUANT
				SD4->D4_QTDEORI := TMPSD4->D4_QUANT
				SD4->D4_SLDEMP  := TMPSD4->D4_QUANT
			MsUnLock()
			lMsErroAuto := .F.
			 
			aVetor:={   {"D4_COD"     ,SD4->D4_COD		,Nil},;
			            {"D4_LOCAL"   ,SD4->D4_LOCAL	,Nil},;
			            {"D4_OP"      ,SD4->D4_OP		,Nil},;
			            {"D4_QTDEORI" ,TMPSD4->D4_QUANT ,Nil},;
			            {"D4_QUANT"   ,TMPSD4->D4_QUANT ,Nil},;
			            {"D4_TRT"     ,SD4->D4_TRT		,Nil}}
			             
			aAdd( aEmpen, { TMPSD4->D4_QUANT, .F.} ) 
			 
			MSExecAuto({|x,y,z| mata380(x,y,z)},aVetor,4,aEmpen) 
			 
			If lMsErroAuto
			    //Alert("Erro")
			    MostraErro()
			EndIf
		EndIf

		TMPSD4->( dbSkip() )
	EndDo

	TMPSD4->( dbCloseArea() )

	// Garantir ajuste no saldo de empenho do lote produzido na PA...
	cQuery := "SELECT 'UPDATE " + RetSqlName("SB8") + " SET B8_EMPENHO = ' + CONVERT(VARCHAR(20),SUM(D4_QUANT)) + ', B8_EMPENH2 = ' + CONVERT(VARCHAR(20),SUM(D4_QTSEGUM)) + ' WHERE R_E_C_N_O_ = ' + CONVERT(VARCHAR(20),SB8.R_E_C_N_O_) AS INSTRUCAO " + CRLF
	cQuery += "FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD4") + " AS SD4 WITH (NOLOCK) ON D4_FILIAL = B8_FILIAL " + CRLF
	//cQuery += "  AND D4_PRODUTO = '" + SC2->C2_PRODUTO + "' " + CRLF
	cQuery += "  AND D4_COD = B8_PRODUTO " + CRLF
	cQuery += "  AND D4_LOCAL = B8_LOCAL " + CRLF
	cQuery += "  AND D4_LOTECTL = B8_LOTECTL " + CRLF
	cQuery += "  AND SD4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B8_FILIAL = '" + xFilial("SC2") + "' " + CRLF
	cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("SB1") + " WHERE B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = B8_PRODUTO AND B1_TIPO = 'PI' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND B8_LOCAL = '04' " + CRLF
	cQuery += "AND B8_LOTECTL = '" + SC2->C2_NUM + "' " + CRLF
	cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY B8_EMPENHO, B8_EMPENH2, SB8.R_E_C_N_O_  " + CRLF

	TCQuery cQuery New Alias "ACERTO"
	dbSelectArea("ACERTO")
	dbGoTop()

	If !ACERTO->( Eof() )
		TCSqlExec( ACERTO->INSTRUCAO )
	EndIf

	ACERTO->( dbCloseArea() )

// Verificar se todas as OPs do lote foi finalizado e forçar requisição do resíduo da PI se houve
EndIf

If Select("TMPSC2") > 0
	TMPSC2->(dbCloseArea())
EndIf

cQuery := "SELECT C2_NUM " + CRLF
cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
cQuery += "AND C2_NUM = '" + SC2->C2_NUM + "' " + CRLF
cQuery += "AND C2_QUANT > (C2_QUJE + C2_PERDA) " + CRLF
cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF

TCQuery cQuery New Alias "TMPSC2"
dbSelectArea("TMPSC2")
dbGoTop()

//If TMPSC2->( Eof() )
//	lFazBx := .T.
//EndIf

If lFazBx

	If Select("SB8PI") > 0
		SB8PI->(dbCloseArea())
	EndIf

	cQuery := "SELECT * " + CRLF
	cQuery += "FROM " + RetSqlName("SB8") + " AS SB8 " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = B8_PRODUTO " + CRLF
	cQuery += "  AND B1_TIPO = 'PI' " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B8_FILIAL = '" + xFilial("SB8") + "' " + CRLF
	cQuery += "AND B8_LOTECTL = '" + SC2->C2_NUM + "' " + CRLF
	cQuery += "AND B8_SALDO <> 0 " + CRLF
	cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "SB8PI"
	dbSelectArea("SB8PI")
	SB8PI->( dbGoTop() )

	Do While !SB8PI->( Eof() )

		/*
		_aCab1      := {}
		_aItem      := {}
		_aTotItem   := {}
		lMsErroAuto := .F.
		

		_aCab1 := { {"D3_TM"		, "551"					, NIL},;
					{"D3_EMISSAO"	, ddatabase				, NIL}}
		
		_aItem := { {"D3_COD" 		, SB8PI->B8_PRODUTO		,NIL},;
					{"D3_UM" 		, SB8PI->B1_UM			,NIL},; 
					{"D3_QUANT"		, SB8PI->B8_SALDO		,NIL},;
					{"D3_LOCAL"		, SB8PI->B8_LOCAL		,NIL},;
					{"D3_LOTECTL"	, SB8PI->B8_LOTECTL		,NIL}}
		
		aAdd( _aTotItem, _aitem)
		
		MSExecAuto({|f,g,h| MATA241(f,g,h)}, _aCab1, _aTotItem, 3)

		If lMsErroAuto
			DisarmTransaction()
		EndIf
		*/
		SB8PI->( dbSkip() )
	
	EndDo

	SB8PI->(dbCloseArea())

Endif 

TMPSC2->(dbCloseArea())

RestArea(aAreaSB1)
RestArea(aAreaSD3)
RestArea(aAreaSH6)
RestArea(aAreaSB8)
RestArea(aAreaSC2)

Return()

