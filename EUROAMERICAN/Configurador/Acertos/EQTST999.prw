#Include "protheus.ch"
#Include "rwmake.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"

/*/
Programa para contornar erro de não inclusão automática...
/*/

User Function EQTST999() //u_EQTST999()

Local _aCabSF1   := {}
Local _aItensSD1 := {}
Local _aLinha    := {}
Local cFornece   := ""

cQuery := "SELECT C7_FILIAL, C7_NUM " + CRLF
cQuery += "FROM " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) " + CRLF
cQuery += "WHERE C7_FILIAL = '" + xFilial("SC7") + "' " + CRLF
cQuery += "AND C7_PRODUTO LIKE 'RE%' " + CRLF
cQuery += "AND C7_EMISSAO >= '20190501' " + CRLF
cQuery += "AND C7_QUJE = 0 " + CRLF
cQuery += "AND C7_CONAPRO = 'L' " + CRLF
cQuery += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("SC7") + " WITH (NOLOCK) WHERE C7_FILIAL = SC7.C7_FILIAL AND C7_NUM = SC7.C7_NUM AND C7_CONAPRO = 'B' AND D_E_L_E_T_ = ' ') " + CRLF
cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("SCR") + " WITH (NOLOCK) WHERE CR_FILIAL = C7_FILIAL AND CR_NUM = C7_NUM AND CR_TIPO = 'PC' AND CR_STATUS IN ('03','05') AND D_E_L_E_T_ = ' ') " + CRLF
cQuery += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("SCR") + " WITH (NOLOCK) WHERE CR_FILIAL = C7_FILIAL AND CR_NUM = C7_NUM AND CR_TIPO = 'PC' AND CR_STATUS NOT IN ('03','05') AND D_E_L_E_T_ = ' ') " + CRLF
cQuery += "AND D_E_L_E_T_ = ' ' " + CRLF
cQuery += "GROUP BY C7_FILIAL, C7_NUM " + CRLF

TCQuery cQuery New Alias "TMPSC7"
dbSelectArea("TMPSC7")
dbGoTop()

Do While !TMPSC7->( Eof() )
	_aCabSF1   := {}
	_aItensSD1 := {}
	_aLinha    := {}
	cFornece   := ""

	cQry := " SELECT	ROW_NUMBER() OVER (ORDER BY C7_ITEM) AS ITEM, * "
	cQry += " FROM " + RetSqlName("SC7")
	cQry += " WHERE	D_E_L_E_T_ = '' AND C7_PRODUTO LIKE 'RE%' "
	cQry += " 		AND C7_NUM = '" + TMPSC7->C7_NUM + "' "
	cQry += " 		AND C7_FILIAL = '" + TMPSC7->C7_FILIAL + "' "
	cQry += " ORDER BY C7_ITEM "
	
	If Select("TSC7") > 0
		TSC7->(dbCloseArea())
	EndIf
	
	TCQUERY cQry NEW ALIAS TSC7
	
	dbSelectArea("TSC7")
	dbGoTop()
	
	If	!TSC7->(EOF()) //("TSC7")
		lMsErroAuto     :=	.F.
		cFornece		:=	TSC7->C7_FORNECE
		
		Aadd(_aCabSF1,{"F1_FILIAL"		,TSC7->C7_FILIAL	,Nil})
		Aadd(_aCabSF1,{"F1_TIPO"		,"N"				,Nil})
		Aadd(_aCabSF1,{"F1_FORMUL"		,"N"				,Nil})
		Aadd(_aCabSF1,{"F1_DOC"			,StrZero(Val(TMPSC7->C7_NUM),9)	,Nil})
		Aadd(_aCabSF1,{"F1_SERIE"		,"REC"				,Nil})
		Aadd(_aCabSF1,{"F1_EMISSAO"		,dDataBase			,Nil})
		Aadd(_aCabSF1,{"F1_FORNECE"     ,TSC7->C7_FORNECE	,Nil})
		Aadd(_aCabSF1,{"F1_LOJA"		,TSC7->C7_LOJA		,Nil})
		Aadd(_aCabSF1,{"F1_ESPECIE"		,"RECIB"			,Nil})
		Aadd(_aCabSF1,{"F1_COND"		,TSC7->C7_COND		,Nil})
		Aadd(_aCabSF1,{"F1_DTDIGIT"		,dDataBase			,Nil})
		Aadd(_aCabSF1,{"F1_EST"			," "				,Nil})
		If	AllTrim(TSC7->C7_PRODUTO) $ "RE.0017"
			Aadd(_aCabSF1,{"E2_NATUREZ"		,"0403004"		,Nil})	// 1403.1
		ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0018"
			Aadd(_aCabSF1,{"E2_NATUREZ"		,"0402046"		,Nil})  // 1606
		ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0019"
			Aadd(_aCabSF1,{"E2_NATUREZ"		,"0404004"		,Nil})  // 1304
		ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0021"
			Aadd(_aCabSF1,{"E2_NATUREZ"		,"0202004"		,Nil})  // 1519
		ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0022"
			Aadd(_aCabSF1,{"E2_NATUREZ"		,"0402003"		,Nil})  // 1402
		ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0030"
			Aadd(_aCabSF1,{"E2_NATUREZ"		,"0403005"		,Nil})  // 1403.2
		ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0031"
			Aadd(_aCabSF1,{"E2_NATUREZ"		,"0402060"		,Nil})  // 1901
		ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0033"
			Aadd(_aCabSF1,{"E2_NATUREZ"		,"0402071"		,Nil})  // 1931
		ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0034"
			Aadd(_aCabSF1,{"E2_NATUREZ"		,"0402072"		,Nil})  // 1932
		ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0035"
			Aadd(_aCabSF1,{"E2_NATUREZ"		,"0202003"		,Nil})  // 1514 	
		ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0036"
			Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301008"		,Nil})  // 1802
		ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0037"
			Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301009"		,Nil})  // 1803
		ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0038"
			Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301010"		,Nil})  // 1804	
		ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0039"
			Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301007"		,Nil})  // 1801	
		ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0040"
			Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301011"		,Nil})  // 1806	
		ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0041"
			Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301016"		,Nil})  // 1899	
		ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0042"
			Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301001"		,Nil})  // 1447
		ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0044"
			Aadd(_aCabSF1,{"E2_NATUREZ"		,"0402050"		,Nil})  // 1719	
		ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.SGA.0049"
			Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301021"		,Nil})  						
		Else
			Aadd(_aCabSF1,{"E2_NATUREZ"		,"0402068"		,Nil})  // 1917
		EndIf
	
		While !TSC7->(EOF()) //EOF("TSC7")
			
			_aLinha		:=	{}
			Aadd(_aLinha,{"D1_FILIAL"	,TSC7->C7_FILIAL	,Nil})
			Aadd(_aLinha,{"D1_ITEM"		,StrZero(TSC7->ITEM,4),Nil})  //Alterado 28/09/2016 TSC7->C7_ITEM
			Aadd(_aLinha,{"D1_FORNECE"	,TSC7->C7_FORNECE	,Nil})
			Aadd(_aLinha,{"D1_LOJA"		,TSC7->C7_LOJA		,Nil})
			Aadd(_aLinha,{"D1_DOC"		,StrZero(Val(TMPSC7->C7_NUM),9)	,Nil})
			Aadd(_aLinha,{"D1_PEDIDO"	,TSC7->C7_NUM		,Nil})
			Aadd(_aLinha,{"D1_COD"		,TSC7->C7_PRODUTO	,Nil})
			Aadd(_aLinha,{"D1_UM"		,TSC7->C7_UM		,Nil})
			Aadd(_aLinha,{"D1_QUANT"	,TSC7->C7_QUANT		,Nil})
			Aadd(_aLinha,{"D1_VUNIT"	,TSC7->C7_PRECO		,Nil})
			Aadd(_aLinha,{"D1_TOTAL"	,TSC7->C7_TOTAL		,Nil})
			Aadd(_aLinha,{"D1_TES"		,IIf(Empty(AllTrim(TSC7->C7_TES)),"000",TSC7->C7_TES),Nil})
			Aadd(_aLinha,{"D1_CF"		,"1949"				,Nil})
			Aadd(_aLinha,{"D1_CC"		,TSC7->C7_CC		,Nil})
			Aadd(_aLinha,{"D1_ITEMPC"	,TSC7->C7_ITEM		,Nil})
			Aadd(_aLinha,{"D1_EMISSAO"	,dDataBase				})
			Aadd(_aLinha,{"D1_DTDIGIT"	,dDataBase			,Nil})
			Aadd(_aLinha,{"D1_LOCAL"	,TSC7->C7_LOCAL		,Nil})
			Aadd(_aLinha,{"D1_SERIE"	,"REC"				,Nil})
			Aadd(_aLinha,{"D1_TIPO"		,"N"				,Nil})
			Aadd(_aLinha,{"D1_FORMUL"	,"N"					})
			Aadd(_aLinha,{"D1_RATEIO"	,"2"				,Nil})
			Aadd(_aLinha,{"D1_TP"		,"RE"				,Nil})
			Aadd(_aLinha,{"AUTDELETA"	,"N"				,Nil})
			Aadd(_aItensSD1,_aLinha)
			
			TSC7->(dbSkip())
			
		EndDo
		
		MSExecAuto({|x,y,z| MATA103(x,y,z)},_aCabSF1,_aItensSD1,3)
		
		If lMsErroAuto
			MostraErro()
			
			If Select("TSE2") > 0
				TSE2->(dbCloseArea())
			EndIf
			
			cQry := " SELECT	E2_NUM "
			cQry += " FROM " + RetSqlName("SE2")  + " "
			cQry += " WHERE	D_E_L_E_T_ = '' AND E2_NUM = '" + StrZero(Val(TMPSC7->C7_NUM),9) + "' "
			cQry += " 		AND E2_FILIAL = '" + TMPSC7->C7_FILIAL + "' "
			cQry += " 		AND E2_FORNECE = '" + cFornece + "' "
			
			TCQUERY cQry NEW ALIAS TSE2
			
			dbSelectArea("TSE2")
			dbGoTop()
			
			If	!TSE2->(EOF()) //EOF("TSE2")
				//MsgInfo("Criação da despesa realizada!")
			Else
				//MsgInfo("Erro na criação da despesa, favor informar para a área de TI ou Financeira!")
			EndIf
			
		Else
			// Exibe mensagem ao usuario
			//MsgInfo("Criação da despesa realizada com sucesso! " + ENTER +;
			//"Título : " + StrZero(Val(SCR->CR_NUM),9) + ".")
		Endif
		
	EndIf
	
	TMPSC7->( dbSkip() )
EndDo

TMPSC7->( dbCloseArea() )

Return
