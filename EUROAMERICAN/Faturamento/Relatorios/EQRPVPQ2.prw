#include "protheus.ch"
#include "topconn.ch"

#define XFILIAL		01
#define XCLI		02
#define XLOJA		03
#define XNREDUZ		04
#define XPRODUTO	05
#define XLOCAL		06
#define XQTDVEN		07
#define XPRCVEN		08
#define XVALOR		09
#define XQTDLIB		10
#define XQTDLIB2	11
#define XQTDENT		12
#define XQTDENT2	13
#define XQTDEMP		14
#define XQTDEMP2	15
#define XQATU		16
#define XRESERVA	17
#define XQACLASS	18	
#define XUNSVEN		19
#define XQATU2		20
#define XRESERV2	21
#define XQACLAS2	22
#define XDESC		23
#define XUM			24
#define XSEGUM		25


User Function EQRPVPQ2()

Local aPerg 	:= {}

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Perguntas do ParamBox								Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aAdd( aPerg , 	{ 1 ,"Cons. Pedidos de:" 	, CtoD(Space(8)), "" , "" , "" , "" , 50 , .T. } ) 
aadd( aPerg	,	{ 2 ,"Cons. Blq. CrИdito:" 	,"1"			,{"1=Sim","2=NЦo"},50,"",.T.})	

If ParamBox( @aPerg , "" , Nil , Nil , Nil , .T. )

	MsgRun("Processando Planilha.... Aguarde.","Aguarde",{|| RunCont()})
	
Else

	Alert("Relatorio Cancelado!")

EndIf

Return 


Static Function RunCont()

Local aCols		:= {}
Local aItens	:= {}
Local aProd		:= {}
Local aTotProd	:= {}

Local cQuery    := ""
Local cAlias	:= GetNextAlias()
Local cArquivo	:= GetTempPath()+"rel_"+DtoS(MsDate())+Replace(Time(),":","")+".xml"

Local nTotCli	:= 0

Local oExcel := FwMsExcelEx():New()

cQuery := "SELECT * FROM ("+CRLF
cQuery += "	SELECT C6_FILIAL, C6_CLI, C6_LOJA, A1_NREDUZ, C6_PRODUTO, B1_DESC, B1_UM, B1_SEGUM, C6_LOCAL, SUM(C6_QTDVEN) C6_QTDVEN, SUM(C6_UNSVEN) C6_UNSVEN, "+CRLF
cQuery += "	SUM(C6_PRCVEN) C6_PRCVEN, SUM(C6_VALOR) C6_VALOR, SUM(C6_QTDLIB) C6_QTDLIB, SUM(C6_QTDLIB2) C6_QTDLIB2,"+CRLF
cQuery += "	SUM(C6_QTDENT) C6_QTDENT, SUM(C6_QTDENT2) C6_QTDENT2, SUM(C6_QTDEMP) AS C6_QTDEMP, SUM(C6_QTDEMP2) AS C6_QTDEMP2, B2_QATU, B2_RESERVA, B2_QACLASS,ISNULL(C9_BLCRED,'') AS C9_BLCRED,"+CRLF
cQuery += "	CASE WHEN B1_TIPCONV = 'D' THEN B2_QATU / B1_CONV ELSE B2_QATU * B1_CONV END AS B2_QATU2,"+CRLF
cQuery += "	CASE WHEN B1_TIPCONV = 'D' THEN B2_RESERVA / B1_CONV ELSE B2_RESERVA * B1_CONV END AS B2_RESERV2,"+CRLF
cQuery += "	CASE WHEN B1_TIPCONV = 'D' THEN B2_QACLASS / B1_CONV ELSE B2_QACLASS * B1_CONV END AS B2_QACLAS2"+CRLF
cQuery += "	FROM "+RetSqlName("SC6")+" SC6"+CRLF
cQuery += "	INNER JOIN "+RetSqlName("SA1")+" AS SA1 "+CRLF
cQuery += "		ON A1_FILIAL = C6_FILIAL "+CRLF
cQuery += "		AND A1_COD = C6_CLI "+CRLF
cQuery += "		AND A1_LOJA = C6_LOJA "+CRLF
cQuery += "		AND SA1.D_E_L_E_T_ =''"+CRLF
cQuery += "	INNER JOIN "+RetSqlName("SB2")+" AS SB2 "+CRLF
cQuery += "		ON B2_FILIAL = C6_FILIAL"+CRLF
cQuery += "		AND B2_COD = C6_PRODUTO"+CRLF
cQuery += "		AND B2_LOCAL = C6_LOCAL"+CRLF
cQuery += "		AND SB2.D_E_L_E_T_ = ''"+CRLF
cQuery += "	INNER JOIN "+RetSqlName("SB1")+" AS SB1 "+CRLF
cQuery += "		ON B1_FILIAL = ''"+CRLF
cQuery += "		AND B1_COD = C6_PRODUTO"+CRLF
cQuery += "		AND B1_TIPO = 'PA'"+CRLF
cQuery += "		AND SB1.D_E_L_E_T_ = ''"+CRLF
cQuery += "	INNER JOIN "+RetSqlName("SC5")+" AS SC5 "+CRLF
cQuery += "		ON C5_FILIAL = C6_FILIAL"+CRLF
cQuery += "		AND C5_NUM = C6_NUM"+CRLF
cQuery += "		AND SC5.D_E_L_E_T_ = ''"+CRLF
cQuery += "	LEFT JOIN "+RetSqlName("SC9")+" AS SC9"+CRLF
cQuery += "		ON C9_FILIAL = C6_FILIAL"+CRLF
cQuery += "		AND C9_PEDIDO = C6_NUM"+CRLF
cQuery += "		AND C9_ITEM = C6_ITEM"+CRLF
cQuery += "		AND C9_BLCRED <> '10'"+CRLF
cQuery += "		AND SC9.D_E_L_E_T_ = ''"+CRLF
cQuery += "	WHERE C6_FILIAL = '"+xFilial("SC6")+"'"+CRLF
cQuery += "	AND C5_EMISSAO >= '"+DtoS(mv_par01)+"'"+CRLF  
cQuery += "	AND (C6_QTDVEN-C6_QTDENT) > 0"+CRLF  
cQuery += "	AND C6_BLQ NOT IN ('R','S')"+CRLF  
cQuery += "	AND C6_QTDVEN <> C6_QTDENT"+CRLF  
If mv_par02 == "2"
	cQuery += "	AND (C9_BLCRED IS NULL OR C9_BLCRED = '')"+CRLF  
EndIf
cQuery += "	AND SC6.D_E_L_E_T_ = ''"+CRLF  
cQuery += "	GROUP BY C6_FILIAL, C6_CLI, C6_LOJA, A1_NREDUZ, C6_PRODUTO, B1_DESC, B1_UM, B1_SEGUM, B1_TIPCONV, B1_CONV, C6_LOCAL, B2_QATU, B2_RESERVA, B2_QACLASS,ISNULL(C9_BLCRED,'')"+CRLF  
cQuery += "	) AS GRP"+CRLF  
cQuery += "WHERE B2_QATU - (B2_RESERVA+B2_QACLASS) < "+CRLF  
cQuery += "	(SELECT SUM(C6_QTDVEN-C6_QTDENT) FROM "+RetSqlName("SC6")+" SC6 "+CRLF  
cQuery += "		LEFT JOIN "+RetSqlName("SC9")+" AS SC9"+CRLF
cQuery += "			ON C9_FILIAL = C6_FILIAL"+CRLF
cQuery += "			AND C9_PEDIDO = C6_NUM"+CRLF
cQuery += "			AND C9_ITEM = C6_ITEM"+CRLF
cQuery += "			AND C9_BLCRED <> '10'"+CRLF
cQuery += "			AND SC9.D_E_L_E_T_ = ''"+CRLF
cQuery += "		WHERE C6_FILIAL = '"+xFilial("SC6")+"'"+CRLF
cQuery += "		AND (C6_QTDVEN-C6_QTDENT) > 0"+CRLF  
cQuery += "		AND C6_BLQ NOT IN ('R','S')"+CRLF  
cQuery += "		AND C6_PRODUTO = GRP.C6_PRODUTO"+CRLF  
cQuery += "		AND C6_QTDVEN <> C6_QTDENT"+CRLF  
If mv_par02 == "2"
	cQuery += "	AND (C9_BLCRED IS NULL OR C9_BLCRED = '')"+CRLF  
EndIf
cQuery += "		AND SC6.D_E_L_E_T_ = '')"+CRLF  

Conout(cQuery)
TCQuery cQuery New Alias (cAlias)

(cAlias)->(dbGoTop())
While !(cAlias)->(Eof())

	aAdd(aItens, {	(cAlias)->C6_FILIAL,;
					(cAlias)->C6_CLI,;
	        		(cAlias)->C6_LOJA,;					
	        		(cAlias)->A1_NREDUZ,;					
	        		(cAlias)->C6_PRODUTO,;					
	        		(cAlias)->C6_LOCAL,;					
	        		(cAlias)->C6_QTDVEN,;
	        		(cAlias)->C6_PRCVEN,;
	        		(cAlias)->C6_VALOR,;
	        		(cAlias)->C6_QTDLIB,;
	        		(cAlias)->C6_QTDLIB2,;
	        		(cAlias)->C6_QTDENT,;
	        		(cAlias)->C6_QTDENT2,;
	        		(cAlias)->C6_QTDEMP,;
	        		(cAlias)->C6_QTDEMP2,;
	        		(cAlias)->B2_QATU,;
	        		(cAlias)->B2_RESERVA,;
	        		(cAlias)->B2_QACLASS,;
	        		(cAlias)->C6_UNSVEN,;
	        		(cAlias)->B2_QATU2,;
	        		(cAlias)->B2_RESERV2,;
	        		(cAlias)->B2_QACLAS2,;	
	        		(cAlias)->B1_DESC,;	
	        		(cAlias)->B1_UM,;	
	        		(cAlias)->B1_SEGUM})	

	(cAlias)->(dbSkip())

End

(cAlias)->(dbCloseArea())

For nY := 1 to Len(aItens)
	
	// Adiciona apenas uma linha por porduto
	If aScan( aTotProd,{|x| x[1] == aItens[nY][XPRODUTO]} ) == 0

		// Calcula total de Quantidade do Produto em Pedido
		nTotProd := 0
		aEval( aItens, {|y| Iif(y[XPRODUTO]==aItens[nY][XPRODUTO], nTotProd += (y[XQTDVEN]-(y[XQTDENT])),0) } )
		
		nQtdFaltante := (aItens[nY][XQATU] - (aItens[nY][XRESERVA]+aItens[nY][XQACLASS])) - nTotProd

		If nQtdFaltante < 0

			aAdd(aTotProd,{	aItens[nY][XPRODUTO],;
		 					aItens[nY][XQATU] - (aItens[nY][XRESERVA]+aItens[nY][XQACLASS]),;
		 					nTotProd,;
		 					nQtdFaltante,;
		 					aItens[nY][XQATU] - (aItens[nY][XRESERVA]+aItens[nY][XQACLASS]),; // Controle de Saldo
		 					aItens[nY][XQACLASS],;
		 					aItens[nY][XQATU2] - (aItens[nY][XRESERV2]+aItens[nY][XQACLAS2])  }) // Controle de Saldo 2a. Unidade de Medida
		 EndIf

	EndIf
	

	If aScan(aCols,{|x| x[1]+x[2]+x[3]== aItens[nY][XFILIAL]+aItens[nY][XCLI]+aItens[nY][XLOJA] })==0
                  
		nTotCli	:= 0
  		aProds	:= {}

		aEval( aItens, {|y| Iif(y[XFILIAL]+y[XCLI]+y[XLOJA]==aItens[nY][XFILIAL]+aItens[nY][XCLI]+aItens[nY][XLOJA],nTotCli += y[XVALOR],0) } )

		aEval( aItens, {|y| if(y[XFILIAL]+y[XCLI]+y[XLOJA]==aItens[nY][XFILIAL]+aItens[nY][XCLI]+aItens[nY][XLOJA],;
							aAdd(aProds,{	y[XPRODUTO],;
										 	y[XVALOR],;
										 	y[XQATU]-(y[XRESERVA]+y[XQACLASS]),;
										 	y[XQTDVEN]-(y[XQTDENT]),;
										 	y[XQATU2]-(y[XRESERV2]+y[XQACLAS2]),;
										 	y[XUNSVEN]-y[XQTDENT2] }),;
							"")})

		aAdd(aCols,{aItens[nY][XFILIAL], aItens[nY][XCLI], aItens[nY][XLOJA], aItens[nY][XNREDUZ], nTotCli, aProds})

	EndIf

Next nY

aSort(aCols,,,{|x,y| x[5] > y[5]})	
aSort(aTotProd,,,{ |x,y| x[4] < y[4] })

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime CabeГalho											Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cWorkSheet 	:= "Plan1"
cTable		:= "Analise Pedidos de Venda Pendentes "

oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(cWorkSheet,cTable)

oExcel:AddColumn(cWorkSheet,cTable,"Cliente"+Space(10),1,1)
oExcel:AddColumn(cWorkSheet,cTable,"Nome"+Space(25),1,1)
oExcel:AddColumn(cWorkSheet,cTable,"Total R$"+Space(5),1,2)
oExcel:AddColumn(cWorkSheet,cTable,"% Atendido"+Space(10),1,2)

For nZ := 1 to Len(aTotProd)
	If aTotProd[nZ][4] < 0
		oExcel:AddColumn(cWorkSheet,cTable,aTotProd[nZ][1],1,2)
	EndIf	
Next nZ

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime Linha Saldo Produto									Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aLinha 	:= {}	
aAdd(aLinha,"")
aAdd(aLinha,"")
aAdd(aLinha,"")
aAdd(aLinha,"Saldo")
For nX := 1 to Len(aTotProd)
	If aTotProd[nX][4] < 0
		aAdd(aLinha,aTotProd[nX][2])
	EndIf	
Next nX
oExcel:SetLineBold(.T.)
oExcel:AddRow(cWorkSheet,cTable,aLinha,{21,22,23,24},{1})

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime Total em PedidoЁ
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aLinha 	:= {}	
aAdd(aLinha,"")
aAdd(aLinha,"")
aAdd(aLinha,"")
aAdd(aLinha,"Total em Pedido")
For nX := 1 to Len(aTotProd)
	If aTotProd[nX][4] < 0
		aAdd(aLinha,aTotProd[nX][3])
	EndIf	
Next nX
oExcel:SetLineBold(.T.)
oExcel:AddRow(cWorkSheet,cTable,aLinha,{21,22,23,24},{1})

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime Qtd. a EndereГar									Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aLinha 	:= {}	
aAdd(aLinha,"")
aAdd(aLinha,"")
aAdd(aLinha,"")
aAdd(aLinha,"Qtd. A EndereГar")
For nX := 1 to Len(aTotProd)
	If aTotProd[nX][4] < 0
		aAdd(aLinha,aTotProd[nX][6])
	EndIf	
Next nX
oExcel:SetLineBold(.T.)
oExcel:AddRow(cWorkSheet,cTable,aLinha,{21,22,23,24},{1})

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime Linha Faltante							Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aLinha 	:= {}	
aAdd(aLinha,"")
aAdd(aLinha,"")
aAdd(aLinha,"")
aAdd(aLinha,"Qtd. Faltante")
For nX := 1 to Len(aTotProd)
	If aTotProd[nX][4] < 0
		aAdd(aLinha,aTotProd[nX][4])
	EndIf	
Next nX
oExcel:Set2LineBold(.T.)
oExcel:AddRow(cWorkSheet,cTable,aLinha,{21,22,23,24},{1})

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime Produtos											Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nY := 1 to Len (aCols)
	
	aProdutos   := aCols[nY][6]
	aLinha 		:= {}	

	aAdd(aLinha,aCols[nY][2]+aCols[nY][3])
	aAdd(aLinha,aCols[nY][4])
	aAdd(aLinha,aCols[nY][5])
	aAdd(aLinha,Transform(EQPAtVt(aProdutos,aTotProd),"@r 999.99%"))

	For nX := 1 to Len(aTotProd)

		If aTotProd[nX][4] < 0

			nPosProd := aScan(aProdutos,{|x| x[1]== aTotProd[nX][1] })
			
			If nPosProd > 0
				
				nSldProdPed		:= aTotProd[nX][5]
				nQtdProdPed 	:= aProdutos[nPosProd][4]

				nSld2ProdPed	:= aTotProd[nX][7]
				nQtd2ProdPed 	:= aProdutos[nPosProd][6]

				nQtdFaltante    := Iif(nSldProdPed <= 0, (nQtdProdPed * -1), (nSldProdPed - nQtdProdPed))
				
				aTotProd[nX][5] := nSldProdPed - nQtdProdPed	// Controle de Saldo 1a. Unidade de Medida
				aTotProd[nX][7] := nSld2ProdPed - nQtd2ProdPed 	// Controle de Saldo 2a. Unidade de Medida
				
				aAdd(aLinha,Iif( nQtdFaltante > 0, 0, nQtdFaltante ))

			Else
				aAdd(aLinha,0)
			EndIf	

		EndIf	

	Next nX

	oExcel:AddRow(cWorkSheet,cTable,aLinha)

Next nY

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Abre Planilha				 								Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

oExcel:Activate()
oExcel:GetXMLFile(cArquivo)

oExcelApp := MsExcel():New()
oExcelApp:WorkBooks:Open(cArquivo)
oExcelApp:SetVisible(.T.)        
oExcelApp:Destroy()                        //Encerra o processo do gerenciador de tarefas

Return

Static Function EQGetPAt(cCliente, cLoja)

Local nRet		:= 0
Local nFalta	:= 0
Local nTot		:= 0 

Local cQuery    := ""
Local cAliasCli	:= GetNextAlias()

cQuery := "	SELECT C6_PRODUTO, SUM(C6_QTDVEN) C6_QTDVEN, SUM(C6_UNSVEN) C6_UNSVEN, "+CRLF
cQuery += "	SUM(C6_PRCVEN) C6_PRCVEN, SUM(C6_VALOR) C6_VALOR, SUM(C6_QTDLIB) C6_QTDLIB, SUM(C6_QTDLIB2) C6_QTDLIB2,"+CRLF
cQuery += "	SUM(C6_QTDENT) C6_QTDENT, SUM(C6_QTDENT2) C6_QTDENT2, SUM(C6_QTDEMP) AS C6_QTDEMP, SUM(C6_QTDEMP2) AS C6_QTDEMP2, B2_QATU, B2_RESERVA, B2_QACLASS, "+CRLF
cQuery += "	CASE WHEN B1_TIPCONV = 'D' THEN B2_QATU / B1_CONV ELSE B2_QATU * B1_CONV END AS B2_QATU2,"+CRLF
cQuery += "	CASE WHEN B1_TIPCONV = 'D' THEN B2_RESERVA / B1_CONV ELSE B2_RESERVA * B1_CONV END AS B2_RESERV2,"+CRLF
cQuery += "	CASE WHEN B1_TIPCONV = 'D' THEN B2_QACLASS / B1_CONV ELSE B2_QACLASS * B1_CONV END AS B2_QACLAS2"+CRLF
cQuery += "	FROM "+RetSqlName("SC6")+" SC6"+CRLF
cQuery += "	INNER JOIN "+RetSqlName("SB2")+" AS SB2 "+CRLF
cQuery += "		ON B2_FILIAL = C6_FILIAL"+CRLF
cQuery += "		AND B2_COD = C6_PRODUTO"+CRLF
cQuery += "		AND B2_LOCAL = C6_LOCAL"+CRLF
cQuery += "		AND SB2.D_E_L_E_T_ = ''"+CRLF
cQuery += "	INNER JOIN "+RetSqlName("SB1")+" AS SB1 "+CRLF
cQuery += "		ON B1_FILIAL = ''"+CRLF
cQuery += "		AND B1_COD = C6_PRODUTO"+CRLF
cQuery += "		AND B1_TIPO = 'PA'"+CRLF
cQuery += "		AND SB1.D_E_L_E_T_ = ''"+CRLF
cQuery += "	INNER JOIN "+RetSqlName("SC5")+" AS SC5 "+CRLF
cQuery += "		ON C5_FILIAL = C6_FILIAL"+CRLF
cQuery += "		AND C5_NUM = C6_NUM"+CRLF
cQuery += "		AND SC5.D_E_L_E_T_ = ''"+CRLF
cQuery += "	INNER JOIN "+RetSqlName("SF4")+" AS SF4 "+CRLF
cQuery += "		ON F4_FILIAL = '" + xFilial("SF4") + "'"+CRLF
cQuery += "		AND F4_CODIGO = C6_TES"+CRLF
cQuery += "		AND F4_ESTOQUE = 'S'"+CRLF
cQuery += "		AND SF4.D_E_L_E_T_ = ''"+CRLF
cQuery += "	LEFT JOIN "+RetSqlName("SC9")+" AS SC9"+CRLF
cQuery += "		ON C9_FILIAL = C6_FILIAL"+CRLF
cQuery += "		AND C9_PEDIDO = C6_NUM"+CRLF
cQuery += "		AND C9_ITEM = C6_ITEM"+CRLF
cQuery += "		AND C9_BLCRED <> '10'"+CRLF
cQuery += "		AND SC9.D_E_L_E_T_ = ''"+CRLF
cQuery += "	WHERE C6_FILIAL = '"+xFilial("SC6")+"'"+CRLF
cQuery += "	AND C5_EMISSAO >= '"+DtoS(mv_par01)+"'"+CRLF  
cQuery += "	AND (C6_QTDVEN-(C6_QTDENT)) > 0"+CRLF  
cQuery += "	AND C6_BLQ NOT IN ('R','S')"+CRLF  
cQuery += "	AND C6_QTDVEN <> C6_QTDENT"+CRLF  
cQuery += " AND C6_CLI = '"+cCliente+"' "
cQuery += " AND C6_LOJA = '"+cLoja+"' "       
If mv_par02 == "2"
	cQuery += "	AND (C9_BLCRED IS NULL OR C9_BLCRED = '')"+CRLF  
EndIf
cQuery += "	AND SC6.D_E_L_E_T_ = ''"+CRLF  
cQuery += "	GROUP BY C6_PRODUTO,B1_TIPCONV,B1_CONV, B2_QATU, B2_RESERVA, B2_QACLASS"+CRLF  

Conout(cQuery)
TCQuery cQuery New Alias (cAliasCli)

(cAliasCli)->(dbGoTop())
While !(cAliasCli)->(Eof())

	nSaldoProd 	:= (cAliasCli)->B2_QATU2	- ((cAliasCli)->B2_RESERV2+(cAliasCli)->B2_QACLAS2)	
	nTotPedProd	:= (cAliasCli)->C6_UNSVEN - ((cAliasCli)->C6_QTDENT2 ) 
			
	nTot 	+= nTotPedProd
	nFalta 	+= Iif( nTotPedProd > nSaldoProd,nTotPedProd-nSaldoProd,0)          

	(cAliasCli)->(dbSkip())

End

(cAliasCli)->(dbCloseArea())
           
nRet := Iif( nFalta > 0, (1-(nFalta/nTot))*100	,100)

Return nRet
/*
--------------------------------------------------------------------------
Array Produtos Por Cliente
aPrdCli[1] 	:= CСdigo Produto
aPrdCli[2] 	:= Valor
aPrdCli[3] 	:= Saldo 1a. Unidade de Medida
aPrdCli[4] 	:= Quantidade 1a. UM em Aberto Pedido de Venda Para o Cliente
aPrdCli[5] 	:= Saldo 2a. Unidade de Medida
aPrdCli[6] 	:= Quantidade 2a. UM em Aberto Pedido de Venda Para o Cliente
--------------------------------------------------------------------------
Array Produtos Totais
aPrd[1] 	:= CСdigo Produto
aPrd[2] 	:= Saldo Atual
aPrd[3] 	:= Quantidade Total Em Aberto em Pedido de Venda
aPrd[4] 	:= Quantidade Total Faltante de Saldo
aPrd[5] 	:= Controle de Saldos do Produto 1a. Unidade de Medida
aPrd[6] 	:= Quantidade a EndereГar 1a. Unidade de Medida
aPrd[7] 	:= Controle de Saldos do Produto 2a. Unidade de Medida
--------------------------------------------------------------------------
*/
Static Function EQPAtVt(aPrdCli,aPrd)

Local nW    	:= 0
Local nRet  	:= 0
Local nTotPV	:= 0
Local nFalta	:= 0
Local nPosAtu	:= 0

For nW:= 1 To Len(aPrdCli)

	nPosAtu := aScan(aPrd,{|x| x[1]== aPrdCli[nW][1] })
	
	If nPosAtu > 0

    	nTotPV	+= aPrdCli[nW][6]
    	
    	If aPrd[nPosAtu][7] <= 0
			nFalta := nFalta + aPrdCli[nW][6]
		ElseIf aPrd[nPosAtu][7]-aPrdCli[nW][6] < 0
			nFalta := nFalta + (aPrdCli[nW][6] - aPrd[nPosAtu][7])
		EndIf	
	EndIf
	
Next nW 

nRet := Iif( nFalta > 0, (1-(nFalta/nTotPV))*100,100)

Return nRet
