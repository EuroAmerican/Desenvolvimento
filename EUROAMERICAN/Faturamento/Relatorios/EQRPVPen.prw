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
#define XQACLASS2	22
#define XDESC		23
#define XUM			24
#define XSEGUM		25


User Function EQRPVPen()

Local aPerg 	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Perguntas do ParamBox								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aPerg , 	{ 1 ,"Cons. Pedidos de:" , CtoD(Space(8)) , "" , "" , "" , "" , 50 , .T. } ) 

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

Local cQuery    := ""
Local cAlias	:= GetNextAlias()
Local cArquivo	:= GetTempPath()+"_"+DtoS(MsDate())+Replace(Time(),":","")+".xml"

Local nTotCli	:= 0

Local oExcel := FwMsExcelEx():New()

/*
cQuery := "SELECT C6_FILIAL, C6_CLI, C6_LOJA, A1_NREDUZ, C6_PRODUTO, B1_DESC, B1_UM, B1_SEGUM, C6_LOCAL, SUM(C6_QTDVEN) C6_QTDVEN, SUM(C6_UNSVEN) C6_UNSVEN, "+CRLF
cQuery += "SUM(C6_PRCVEN) C6_PRCVEN, SUM(C6_VALOR) C6_VALOR, SUM(C6_QTDLIB) C6_QTDLIB, SUM(C6_QTDLIB2) C6_QTDLIB2,"+CRLF  
cQuery += "SUM(C6_QTDENT) C6_QTDENT, SUM(C6_QTDENT2) C6_QTDENT2, SUM(C6_QTDEMP) AS C6_QTDEMP, SUM(C6_QTDEMP2) AS C6_QTDEMP2, 
cQuery += "B2_QATU, B2_RESERVA, B2_QACLASS, CASE WHEN B1_TIPCONV = 'D' THEN B2_QATU / B1_CONV ELSE B2_QATU * B1_CONV END AS B2_QATU2,"+CRLF  
cQuery += "CASE WHEN B1_TIPCONV = 'D' THEN B2_RESERVA / B1_CONV ELSE B2_RESERVA * B1_CONV END AS B2_RESERV2,"+CRLF
cQuery += "CASE WHEN B1_TIPCONV = 'D' THEN B2_QACLASS / B1_CONV ELSE B2_QACLASS * B1_CONV END AS B2_QACLASS2"+CRLF  
cQuery += "FROM "+RetSqlName("SC6")+" SC6"+CRLF  
cQuery += "INNER JOIN "+RetSqlName("SA1")+" AS SA1 "+CRLF  
cQuery += "	ON A1_FILIAL = C6_FILIAL "+CRLF  
cQuery += "	AND A1_COD = C6_CLI "+CRLF  
cQuery += "	AND A1_LOJA = C6_LOJA "+CRLF  
cQuery += "	AND SA1.D_E_L_E_T_ =''"+CRLF  
cQuery += "INNER JOIN "+RetSqlName("SB2")+" AS SB2 "+CRLF  
cQuery += "	ON B2_FILIAL = C6_FILIAL"+CRLF  
cQuery += "	AND B2_COD = C6_PRODUTO"+CRLF  
cQuery += "	AND B2_LOCAL = C6_LOCAL"+CRLF  
cQuery += "	AND SB2.D_E_L_E_T_ = ''"+CRLF  
cQuery += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 "+CRLF  
cQuery += "	ON B1_FILIAL = ''"+CRLF  
cQuery += "	AND B1_COD = C6_PRODUTO"+CRLF  
cQuery += "	AND SB1.D_E_L_E_T_ = ''"+CRLF  
cQuery += "INNER JOIN "+RetSqlName("SC5")+" AS SC5 "+CRLF  
cQuery += "	ON C5_FILIAL = C6_FILIAL"+CRLF  
cQuery += "	AND C5_NUM = C6_NUM"+CRLF  
cQuery += "	AND SC5.D_E_L_E_T_ = ''"+CRLF  
cQuery += "WHERE C6_FILIAL = '"+xFilial("SC6")+"'"+CRLF  
cQuery += "AND C5_EMISSAO >= '"+DtoS(mv_par01)+"'"+CRLF  
cQuery += "AND (C6_QTDVEN-(C6_QTDEMP+C6_QTDENT)) > 0"+CRLF  
cQuery += "AND C6_BLQ NOT IN ('R','S')"+CRLF  
cQuery += "AND C6_QTDVEN <> C6_QTDENT"+CRLF  
cQuery += "AND SC6.D_E_L_E_T_ = ''"+CRLF  
cQuery += "GROUP BY C6_FILIAL, C6_CLI, C6_LOJA, A1_NREDUZ, C6_PRODUTO, B1_DESC, B1_UM, B1_SEGUM, B1_TIPCONV, B1_CONV, C6_LOCAL, B2_QATU, B2_RESERVA, B2_QACLASS"+CRLF  
*/
cQuery := "SELECT * FROM ("+CRLF
cQuery += "	SELECT C6_FILIAL, C6_CLI, C6_LOJA, A1_NREDUZ, C6_PRODUTO, B1_DESC, B1_UM, B1_SEGUM, C6_LOCAL, C5_EMISSAO, SUM(C6_QTDVEN) C6_QTDVEN, SUM(C6_UNSVEN) C6_UNSVEN, "+CRLF
cQuery += "	SUM(C6_PRCVEN) C6_PRCVEN, SUM(C6_VALOR) C6_VALOR, SUM(C6_QTDLIB) C6_QTDLIB, SUM(C6_QTDLIB2) C6_QTDLIB2,"+CRLF
cQuery += "	SUM(C6_QTDENT) C6_QTDENT, SUM(C6_QTDENT2) C6_QTDENT2, SUM(C6_QTDEMP) AS C6_QTDEMP, SUM(C6_QTDEMP2) AS C6_QTDEMP2, B2_QATU, B2_RESERVA, B2_QACLASS, "+CRLF
cQuery += "	CASE WHEN B1_TIPCONV = 'D' THEN B2_QATU / B1_CONV ELSE B2_QATU * B1_CONV END AS B2_QATU2,"+CRLF
cQuery += "	CASE WHEN B1_TIPCONV = 'D' THEN B2_RESERVA / B1_CONV ELSE B2_RESERVA * B1_CONV END AS B2_RESERV2,"+CRLF
cQuery += "	CASE WHEN B1_TIPCONV = 'D' THEN B2_QACLASS / B1_CONV ELSE B2_QACLASS * B1_CONV END AS B2_QACLASS2"+CRLF
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
cQuery += "		AND SB1.D_E_L_E_T_ = ''"+CRLF
cQuery += "	INNER JOIN "+RetSqlName("SC5")+" AS SC5 "+CRLF
cQuery += "		ON C5_FILIAL = C6_FILIAL"+CRLF
cQuery += "		AND C5_NUM = C6_NUM"+CRLF
cQuery += "		AND SC5.D_E_L_E_T_ = ''"+CRLF
cQuery += "	WHERE C6_FILIAL = '"+xFilial("SC6")+"'"+CRLF
cQuery += "	AND C5_EMISSAO >= '"+DtoS(mv_par01)+"'"+CRLF  
cQuery += "	AND (C6_QTDVEN-(C6_QTDEMP+C6_QTDENT)) > 0"+CRLF  
cQuery += "	AND C6_BLQ NOT IN ('R','S')"+CRLF  
cQuery += "	AND C6_QTDVEN <> C6_QTDENT"+CRLF  
cQuery += "	AND C6_UNSVEN > 0"+CRLF  
cQuery += "	AND SC6.D_E_L_E_T_ = ''"+CRLF  
cQuery += "	GROUP BY C6_FILIAL, C6_CLI, C6_LOJA, A1_NREDUZ, C6_PRODUTO, B1_DESC, B1_UM, B1_SEGUM, B1_TIPCONV, B1_CONV, C6_LOCAL, C5_EMISSAO, B2_QATU, B2_RESERVA, B2_QACLASS"+CRLF  
cQuery += "	) AS GRP"+CRLF  
cQuery += "WHERE B2_QATU2 - (B2_RESERV2+B2_QACLASS2) < "+CRLF  
cQuery += "	(SELECT SUM(C6_UNSVEN) FROM "+RetSqlName("SC6")+" SC6 "+CRLF  
cQuery += "	WHERE C6_FILIAL = '"+xFilial("SC6")+"'"+CRLF
cQuery += "	AND GRP.C5_EMISSAO >= '"+DtoS(mv_par01)+"'"+CRLF  
cQuery += "	AND (C6_QTDVEN-(C6_QTDEMP+C6_QTDENT)) > 0"+CRLF  
cQuery += "	AND C6_BLQ NOT IN ('R','S')"+CRLF  
cQuery += "	AND C6_PRODUTO = GRP.C6_PRODUTO"+CRLF  
cQuery += "	AND C6_QTDVEN <> C6_QTDENT"+CRLF  
cQuery += "	AND C6_UNSVEN > 0"+CRLF  
cQuery += "	AND SC6.D_E_L_E_T_ = '')"+CRLF  

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
	        		(cAlias)->B2_QACLASS2,;	
	        		(cAlias)->B1_DESC,;	
	        		(cAlias)->B1_UM,;	
	        		(cAlias)->B1_SEGUM})	


	(cAlias)->(dbSkip())

End

(cAlias)->(dbCloseArea())

For nY := 1 to Len(aItens)
	
	If aScan(aCols,{|x| x[1]+x[2]+x[3]== aItens[nY][01]+aItens[nY][02]+aItens[nY][03] })==0
                  
		nTotCli	:= 0
  		aProds	:= {}

		//aProds[1] Produto 
		//aProds[2] Valor 
		//aProds[3] Saldo Atual 
		//aProds[4] Quantidade em Pedido 
		//aProds[5] Saldo Atual 2o. UM 
		//aProds[6] Quantidade em Pedido 2o. UM

		aEval( aItens, {|y| Iif(y[1]+y[2]+y[3]==aItens[nY][01]+aItens[nY][02]+aItens[nY][03], aAdd(aProds,{y[5], y[9],y[16]-(y[17]+y[18]),y[7]-(y[12]+y[14]), y[20]-(y[21]+y[22]), y[19]-(y[13]+y[15])}) ,0),;
        					Iif(y[1]+y[2]+y[3]==aItens[nY][01]+aItens[nY][02]+aItens[nY][03], nTotCli += y[9],0) } )

		aAdd(aCols,{aItens[nY][01], aItens[nY][02], aItens[nY][03], aItens[nY][04], nTotCli, aProds})

	EndIf

Next nY

aSort(aCols,,,{|x,y| x[5] > y[5]})	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Cabeçalho											³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cWorkSheet 	:= "Plan1"
cTable		:= "Analise Pedidos de Venda Pendentes "

oExcel:AddworkSheet(cWorkSheet)
oExcel:AddTable(cWorkSheet,cTable)

oExcel:AddColumn(cWorkSheet,cTable,"Produto"+Space(10),1,1)
oExcel:AddColumn(cWorkSheet,cTable,"Descrição"+Space(25),1,1)
oExcel:AddColumn(cWorkSheet,cTable,"UM"+Space(5),1,1)
oExcel:AddColumn(cWorkSheet,cTable,"Saldo Atual",1,1)
oExcel:AddColumn(cWorkSheet,cTable,"Total Pedidos",1,1)
oExcel:AddColumn(cWorkSheet,cTable,"Qtd. Faltante",1,1)

For nZ := 1 to Len(aCols)
	oExcel:AddColumn(cWorkSheet,cTable,aCols[nZ][2]+aCols[nZ][3]+" - "+aCols[nZ][4],1,2)
Next nZ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Linha Total em Reais								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aLinha := {}	
aAdd(aLinha,"")
aAdd(aLinha,"")
aAdd(aLinha,"")
aAdd(aLinha,"")
aAdd(aLinha,"")
aAdd(aLinha,"Total em R$ -->>")
For nX := 1 to Len(aCols)
	aAdd(aLinha,aCols[nX][5])
Next nX

oExcel:AddRow(cWorkSheet,cTable,aLinha)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Linha Percentual Atendido							³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aLinha := {}	
aAdd(aLinha,"")
aAdd(aLinha,"")
aAdd(aLinha,"")
aAdd(aLinha,"")
aAdd(aLinha,"")
aAdd(aLinha,"%Atendido -->>")
For nX := 1 to Len(aCols)

	//aProds[1] Produto 
	//aProds[2] Valor 
	//aProds[3] Saldo Atual 
	//aProds[4] Quantidade em Pedido 
	//aProds[5] Saldo Atual 2o. UM 
	//aProds[6] Quantidade em Pedido 2o. UM
	//aProds[7] Quantidade Faltante 2o. UM

	/*
	aProds 	:= aCols[nX][6]
   	nTot	:= 0
   	nFalta	:= 0

	For nZ := 1 to Len(aProds)
		nTot	+= aProds[nZ][6]
		nFalta 	+= Iif(aProds[nZ][5]-aProds[nZ][6] < 0,aProds[nZ][6]-aProds[nZ][5],0)
	Next nZ
	
	nPercAtend := (1-(nFalta/nTot))*100	//AllTrim(TransForm((1-(nFalta/nTot))*100,"@R 999.99%"))
	aAdd(aLinha,nPercAtend)
    */
    
	nPercAtend := EQGetPAt(aCols[nX][2],aCols[nX][3])
	aAdd(aLinha,nPercAtend)

Next nX

oExcel:AddRow(cWorkSheet,cTable,aLinha)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Produtos											³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aProd 		:= {}
nSldPrdAtu	:= 0

For nY := 1 to Len (aItens)
	
	// Adiona apenas uma linha por porduto
	If aScan( aProd,{|x| x[1] == aItens[nY][XPRODUTO]} ) > 0
		Loop
	Else
		aAdd(aProd,{aItens[nY][XPRODUTO]})
	EndIf
			
	// Calcula total de Quantidade do Produto em Pedido
	nTotProd := 0
	aEval( aItens, {|y| Iif(y[XPRODUTO]==aItens[nY][XPRODUTO], nTotProd += (y[XUNSVEN]-(y[XQTDEMP2]+y[XQTDENT2])),0) } )

	// Imprime apenas produtos sem Saldo para atender as necessidades
	nQtdFaltante := (aItens[nY][XQATU2] - (aItens[nY][XRESERV2]+aItens[nY][XQACLASS2])) - nTotProd
	If nQtdFaltante >= 0
		Loop	
	EndIf
	
	aLinha := {}	
	aAdd(aLinha,aItens[nY][XPRODUTO])
	aAdd(aLinha,aItens[nY][XDESC])
	aAdd(aLinha,aItens[nY][XSEGUM])
	aAdd(aLinha,aItens[nY][XQATU2] - (aItens[nY][XRESERV2]+aItens[nY][XQACLASS2]))
	aAdd(aLinha,nTotProd)
	aAdd(aLinha,nQtdFaltante) // Qtd. Faltante Total

	nSldPrdAtu	:= aItens[nY][XQATU2] - (aItens[nY][XRESERV2]+aItens[nY][XQACLASS2])
	For nX := 1 to Len(aCols)
            
		nTotProdCli := 0
		
		nPosCli := aScan( aItens,{|x| x[2]+x[3]+x[5] == aCols[nX][2]+aCols[nX][3]+aItens[nY][XPRODUTO] } ) 
		If nPosCli > 0
			nTotProdCli :=  aItens[nPosCli][XUNSVEN]-(aItens[nPosCli][XQTDEMP2]+aItens[nPosCli][XQTDENT2])
			nSldPrdAtu 	:= nSldPrdAtu - nTotProdCli
			aAdd(aLinha,nSldPrdAtu)
		Else			
			aAdd(aLinha,0)
		EndIf	

   	Next nX

	oExcel:AddRow(cWorkSheet,cTable,aLinha)

Next nY

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre Planilha				 								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
cQuery += "	CASE WHEN B1_TIPCONV = 'D' THEN B2_QACLASS / B1_CONV ELSE B2_QACLASS * B1_CONV END AS B2_QACLASS2"+CRLF
cQuery += "	FROM "+RetSqlName("SC6")+" SC6"+CRLF
cQuery += "	INNER JOIN "+RetSqlName("SB2")+" AS SB2 "+CRLF
cQuery += "		ON B2_FILIAL = C6_FILIAL"+CRLF
cQuery += "		AND B2_COD = C6_PRODUTO"+CRLF
cQuery += "		AND B2_LOCAL = C6_LOCAL"+CRLF
cQuery += "		AND SB2.D_E_L_E_T_ = ''"+CRLF
cQuery += "	INNER JOIN "+RetSqlName("SB1")+" AS SB1 "+CRLF
cQuery += "		ON B1_FILIAL = ''"+CRLF
cQuery += "		AND B1_COD = C6_PRODUTO"+CRLF
cQuery += "		AND SB1.D_E_L_E_T_ = ''"+CRLF
cQuery += "	INNER JOIN "+RetSqlName("SC5")+" AS SC5 "+CRLF
cQuery += "		ON C5_FILIAL = C6_FILIAL"+CRLF
cQuery += "		AND C5_NUM = C6_NUM"+CRLF
cQuery += "		AND SC5.D_E_L_E_T_ = ''"+CRLF
cQuery += "	WHERE C6_FILIAL = '"+xFilial("SC6")+"'"+CRLF
cQuery += "	AND C5_EMISSAO >= '"+DtoS(mv_par01)+"'"+CRLF  
cQuery += "	AND (C6_QTDVEN-(C6_QTDEMP+C6_QTDENT)) > 0"+CRLF  
cQuery += "	AND C6_BLQ NOT IN ('R','S')"+CRLF  
cQuery += "	AND C6_QTDVEN <> C6_QTDENT"+CRLF  
cQuery += " AND C6_CLI = '"+cCliente+"' "
cQuery += " AND C6_LOJA = '"+cLoja+"' "
cQuery += "	AND SC6.D_E_L_E_T_ = ''"+CRLF  
cQuery += "	GROUP BY C6_PRODUTO,B1_TIPCONV,B1_CONV, B2_QATU, B2_RESERVA, B2_QACLASS"+CRLF  

Conout(cQuery)
TCQuery cQuery New Alias (cAliasCli)

(cAliasCli)->(dbGoTop())
While !(cAliasCli)->(Eof())

	nSaldoProd 	:= (cAliasCli)->B2_QATU2	- ((cAliasCli)->B2_RESERV2+(cAliasCli)->B2_QACLASS2)	
	nTotPedProd	:= (cAliasCli)->C6_UNSVEN - ((cAliasCli)->C6_QTDENT2 + (cAliasCli)->C6_QTDEMP2 ) 
			
	nTot 	+= nTotPedProd
	nFalta 	+= Iif( nTotPedProd > nSaldoProd,nTotPedProd-nSaldoProd,0)          

	(cAliasCli)->(dbSkip())

End

(cAliasCli)->(dbCloseArea())
           
nRet := Iif( nFalta > 0, (1-(nFalta/nTot))*100	,100)

Return nRet