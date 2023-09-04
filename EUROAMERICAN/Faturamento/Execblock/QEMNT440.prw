#include "parmtype.ch"
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"
#include "Colors.ch"
#include "RwMake.ch"

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

/*/{Protheus.doc} QEMNT440
//Relacao de conferencia de comissão por vendedor 
@Autor Fabio Carneiro 
@since 13/02/2022
@version 1.0
@type user function 
@History Ajustado em 09/09/2022 tratamento referente a não considerar comissão se o item estiver zerado - Fabio carneiro dos Santos
@return  character, sem retorno especifico
/*/
User Function QEMNT440()

Local aSays        := {}
Local aButtons     := {}
Local cTitoDlg     := "Atualização % Comissão Tabelas SC5/SC6/SD2/SE1 especifico QUALY"
Local nOpca        := 0
Private _cPerg     := "QECMT44"
Private aPlanilha  := {}

aAdd(aSays, "Rotina para atualizar % comissão das tabelas SC5/SC6/SD2/SE1 - QUALY!!!")
aAdd(aSays, "Esta rotina apenas permite executar um pedido ou nota/titulo por vez!")
aAdd(aSays, "Esta rotina atualiza percentual e revisão com base no cadastro de produto!")
aAdd(aSays, "Portanto, caso deseje presevar as revisões que já existem não executar esta rotina!")
aAdd(aSays, "Sugerimos primeiramente rodar o pedido e depois a NOTA/TITULO!")

aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

FormBatch(cTitoDlg, aSays, aButtons)

If nOpca == 1
	
	oAjustaSx1()

	If !Pergunte(_cPerg,.T.)
		Return
	Else 
		MontaDir("C:\TOTVS\")
		Processa({|| QEMNT440ok("Gerando carga de dados, aguarde...")})
	Endif
		
EndIf

Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEMNT440ok| Autor: | QUALY         | Data: | 13/02/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção -QEFIN440ok                                   |
+------------+-----------------------------------------------------------+
*/

Static Function QEMNT440ok()

Local cArqDst          := "C:\TOTVS\QEMNT440_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
Local oExcel           := FWMsExcelEX():New()
Local cPlan            := "Empresa_" + Rtrim(SM0->M0_CODIGO) + "_Filial_" + Rtrim(SM0->M0_CODFIL)
Local cTit             := "Conferência de Carga de % Comissão"

Local lAbre            := .F.

Local _nVLTOTAL        := 0
Local _nVLCOMIS1       := 0
LOCAL _nVLCOMTAB       := 0
Local _nVALACRS        := 0
Local _nVLBRUTO        := 0
Local _nCount 		   := 0 
Local _nPercTab        := 0
Local _nReprePorc      := 0
Local _nComPerc        := 0
Local _nPerPed         := 0
Local nPlan            := 0
Local _nPercCli        := 0
 
Local cQueryP          := ""
Local cQueryC          := ""
Local _cGEREN          := ""
Local _cVENDEDOR  	   := ""
Local _cNOMEVEND       := ""
Local _cDOC            := ""
Local _cPgCliente      := ""
Local _cRepreClt       := ""
Local _cPgRepre        := ""
Local _dDataPed        := ""
Local _cItem           := ""
Local _cProduto        := ""
Local _cTpCom          := ""

/*
+------------------------------------------+
| DADOS DO PEDIDO DE VENDAS/TITULOS        |
+------------------------------------------+
*/

If MV_PAR03 == 1

	oExcel:AddworkSheet(cPlan)
	oExcel:AddTable(cPlan, cTit)
	oExcel:AddColumn(cPlan, cTit, "Status"             , 1, 1, .F.)  //01
	oExcel:AddColumn(cPlan, cTit, "Vendedor"           , 1, 1, .F.)  //02
	oExcel:AddColumn(cPlan, cTit, "Nome Vendedor"      , 1, 1, .F.)  //03
	oExcel:AddColumn(cPlan, cTit, "Pedido Vendas"      , 1, 1, .F.)  //04
	oExcel:AddColumn(cPlan, cTit, "Data Pedido"        , 1, 1, .F.)  //05
	oExcel:AddColumn(cPlan, cTit, "Item"               , 1, 1, .F.)  //06
	oExcel:AddColumn(cPlan, cTit, "Produto"            , 1, 1, .F.)  //07
	oExcel:AddColumn(cPlan, cTit, "Codigo Tabela"      , 1, 1, .F.)  //08
	oExcel:AddColumn(cPlan, cTit, "Codigo Revisão"     , 1, 1, .F.)  //09
	oExcel:AddColumn(cPlan, cTit, "Valor Item"         , 3, 2, .F.)  //10
	oExcel:AddColumn(cPlan, cTit, "% Comissão"         , 3, 2, .F.)  //11
	oExcel:AddColumn(cPlan, cTit, "% Comissão Tabela"  , 3, 2, .F.)  //12

	If Select("TRBP") > 0
		TRBP->(DbCloseArea())
	EndIf

	cQueryP := "SELECT 'PEDIDO' AS TPREG, " + CRLF
	cQueryP += "'P' AS TIPO, " + CRLF
	cQueryP += "A3_GEREN AS GEREN, " + CRLF
	cQueryP += "C5_VEND1 AS VENDEDOR, " + CRLF
	cQueryP += "A3_NOME AS NOMEVEND, " + CRLF
	cQueryP += "A1_COD AS CODCLI, " + CRLF
	cQueryP += "A1_LOJA AS LOJA, " + CRLF
	cQueryP += "A1_NOME AS NOMECLI, " + CRLF
	cQueryP += "B1_COD AS PRODUTO, " + CRLF
	cQueryP += "B1_DESC AS DESCRI, " + CRLF
	cQueryP += "C6_ITEM AS ITEM, " + CRLF
	cQueryP += "C5_NUM AS DOC, " + CRLF
	cQueryP += "C5_EMISSAO AS DTEMISSAO, " + CRLF 
	cQueryP += "A1_XPGCOM AS XA1PGCOM, " + CRLF
	cQueryP += "A3_XCLT AS XCLT, " + CRLF
	cQueryP += "A3_XPGCOM AS  XA3PGCOM, " + CRLF
	cQueryP += "A3_COMIS AS A3COMIS, " + CRLF
	cQueryP += "C6_COMIS1 AS C6COMIS, " + CRLF
	cQueryP += "C6_XCOM1 AS C6XCOM1, " + CRLF
	cQueryP += "C6_XTABCOM AS XTABCOM, " + CRLF
	cQueryP += "B1_COMIS AS B1COMIS, " + CRLF
	cQueryP += "C6_VALOR AS VLTOTAL, " + CRLF
	cQueryP += "F4_DUPLIC AS F4DUPLIC, " + CRLF
	cQueryP += "A1_XCOMIS1 AS XCOMIS1, " + CRLF
	cQueryP += "B1_XREVCOM AS XREVCOM, " + CRLF
	cQueryP += "B1_XTABCOM AS XB1TABCOM, " + CRLF
	cQueryP += "C6_XTABCOM AS C6XTABCOM, " + CRLF
	cQueryP += "C6_XREVCOM AS C6XREVCOM, " + CRLF
	cQueryP += "C6_XDTRVC AS C6XDTRVC, " + CRLF
	cQueryP += "C6_XTPCOM AS C6XTPCOM, " + CRLF
	cQueryP += "C6_COMIS1 AS C6COMIS1, " + CRLF
	cQueryP += "C6_XCOM1 AS C6XCOM1  "+ CRLF
	cQueryP += "FROM "+RetSqlName("SC5")+" AS SC5 WITH (NOLOCK) " + CRLF 
	cQueryP += "INNER JOIN "+RetSqlName("SC6")+" AS SC6 WITH (NOLOCK) ON C5_FILIAL = C6_FILIAL " + CRLF 
	cQueryP += " AND C5_NUM = C6_NUM " + CRLF
	cQueryP += " AND C5_CLIENTE = C6_CLI " + CRLF
	cQueryP += " AND C5_LOJACLI = C6_LOJA " + CRLF
	cQueryP += " AND SC6.D_E_L_E_T_ = ' '  " + CRLF
	CQueryP += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) ON B1_COD = C6_PRODUTO " + CRLF
	cQueryP += " AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQueryP += "INNER JOIN "+RetSqlName("SF4")+" AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(C6_FILIAL, 2) " + CRLF
	cQueryP += " AND F4_CODIGO = C6_TES " + CRLF
	cQueryP += " AND SF4.D_E_L_E_T_ = ' ' " + CRLF
	cQueryP += "INNER JOIN "+RetSqlName("SA3")+" AS SA3 WITH (NOLOCK) ON A3_COD = C5_VEND1 " + CRLF
	cQueryP += " AND SA3.D_E_L_E_T_ = ' ' " + CRLF
	cQueryP += "INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH (NOLOCK) ON A1_FILIAL = C5_FILIAL " + CRLF
	cQueryP += " AND A1_COD = C5_CLIENTE " + CRLF
	cQueryP += " AND A1_LOJA = C5_LOJACLI " + CRLF
	cQueryP += "WHERE C5_FILIAL = '"+xFilial("SC5")+"'  " + CRLF
	cQueryP += " AND C5_NUM = '"+MV_PAR01+"'  " + CRLF
	cQueryP += " AND SC6.D_E_L_E_T_ = ' '  " + CRLF
	cQueryP += "GROUP BY A3_GEREN,C5_VEND1,A3_NOME,A1_COD,A1_LOJA,A1_NOME,B1_COD,B1_DESC,C6_ITEM,C5_NUM,C5_EMISSAO,A1_XPGCOM,F4_DUPLIC, " + CRLF
	cQueryP += "A3_XCLT,A3_XPGCOM,A3_COMIS,C6_COMIS1,C6_XTABCOM,B1_COMIS,C6_VALOR,C6_XCOM1,B1_COMIS,A1_XCOMIS1,B1_XREVCOM,B1_XTABCOM, " + CRLF
	cQueryP += "C6_XTABCOM, C6_XREVCOM, C6_XDTRVC, C6_XTPCOM, C6_COMIS1, C6_XCOM1  "+ CRLF
	cQueryP += "ORDER BY C5_NUM, C5_EMISSAO, C6_ITEM " + CRLF

	TCQuery cQueryP New Alias "TRBP"

	TRBP->(DbGoTop())

	While TRBP->(!Eof())

			// Tratamento do Tipo que vem do SQL NO ALIAS 
		_cPgCliente  := ""
		_cRepreClt   := ""
		_cPgRepre    := ""
		_nReprePorc  := 0

		_cPgCliente  := TRBP->XA1PGCOM  // 1 = Não / 2 = Sim
		_cRepreClt   := TRBP->XCLT      // 1 = Não / 2 = Sim
		_cPgRepre    := TRBP->XA3PGCOM  // 1 = Não / 2 = Sim
		If TRBP->B1COMIS > 0
			_nReprePorc  := TRBP->A3COMIS   // % do vendedor 
			_nPercCli    := TRBP->XCOMIS1   // % por cliente 
		Else 
			_nReprePorc  := 0   // % do vendedor 
			_nPercCli    := 0   // % por cliente 
		EndIf
		_cGEREN		 := TRBP->GEREN
		_cVENDEDOR   := TRBP->VENDEDOR
		_cNOMEVEND 	 := TRBP->NOMEVEND 
		_cDOC  		 := TRBP->DOC                    
		_dDataPed    := StoD(TRBP->DTEMISSAO)
		_cItem       := TRBP->ITEM
		_cProduto    := TRBP->PRODUTO 

		If _cPgCliente == "2" .And. _cPgRepre == "2" .And. TRBP->F4DUPLIC == "S"

			If  AllTrim(TRBP->TPREG) == "PEDIDO"

				If TRBP->B1COMIS > 0
					_nVLCOMIS1  := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_COMIS1")
					_nVLCOMTAB  := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_COMIS1")         
					_nVLTOTAL   += TRBP->VLTOTAL
				Else 
					_nVLCOMIS1  := 0
					_nVLCOMTAB  := 0
					_nVLTOTAL   += 0
				EndIf

				If TRBP->XA1PGCOM == "2" .And. TRBP->XCOMIS1 > 0

					If TRBP->B1COMIS > 0
						_nPercTab   += Round((TRBP->VLTOTAL * _nVLCOMTAB)/100,2) 
						_nComPerc   += Round((TRBP->VLTOTAL * TRBP->XCOMIS1)/100,2)
						_cTpCom     := "01" // cliente
					Else 
						_nPercTab   += 0
						_nComPerc   += 0
						_cTpCom     := "01" // cliente
					EndIf

				ElseIf TRBP->XCLT == "2" .And. TRBP->XA3PGCOM == "2" .And. TRBP->XCOMIS1 <= 0

					If TRBP->B1COMIS > 0
						_nPercTab   += Round((TRBP->VLTOTAL * _nVLCOMTAB)/100,2) 
						_nComPerc   += Round((TRBP->VLTOTAL * TRBP->A3COMIS)/100,2)
						_cTpCom     := "03" // Vendedor
					Else 	
						_nPercTab   += 0
						_nComPerc   += 0
						_cTpCom     := "03" // Vendedor
					EndIf

				ElseIf TRBP->XCLT == "1" .And. TRBP->XA1PGCOM == "2" .And. TRBP->XCOMIS1 <= 0

					If TRBP->B1COMIS > 0
						_nPercTab   += Round((TRBP->VLTOTAL * _nVLCOMTAB)/100,2) 
						_nComPerc   += Round((TRBP->VLTOTAL * Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_COMIS1"))/100,2)
						_cTpCom     := "02" // produto
					Else 
						_nPercTab   += 0
						_nComPerc   += 0
						_cTpCom     := "02" // produto
					EndIf

				EndIf

				If TRBP->B1COMIS > 0

					If TRBP->XCOMIS1 > 0
						_nPerPed    := If(TRBP->XA1PGCOM=="2".And.TRBP->XCOMIS1 > 0,TRBP->XCOMIS1,Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_COMIS1"))
					Else 
						_nPerPed    := If(TRBP->XCLT=="2".And.TRBP->XA3PGCOM=="2",TRBP->A3COMIS,Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_COMIS1"))
					EndIf

				Else 
					_nPerPed    := 0
	
				EndIf
	
				DbSelectArea("SC6")
				DbSetOrder(1)  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
				If SC6->(dbSeek(xFilial("SC6")+TRBP->DOC+TRBP->ITEM+TRBP->PRODUTO)) 
							
					Reclock("SC6",.F.)
							
						SC6->C6_COMIS1    := _nPerPed
						SC6->C6_XCOM1     := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_COMIS1")         
						SC6->C6_XTABCOM   := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_CODTAB")       
						SC6->C6_XREVCOM   := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_REV")       
						SC6->C6_XDTRVC    := DDATABASE  
						SC6->C6_XTPCOM    := If(Empty(_cTpCom),"04",_cTpCom)
						SC6->C6_COMIS2    := 0
						SC6->C6_COMIS3    := 0
						SC6->C6_COMIS4    := 0
						SC6->C6_COMIS5    := 0

					SC6->( Msunlock() )

					aAdd(aPlanilha,{AllTrim("Atualizado"),;              //01
												_cVENDEDOR,;             //02
												_cNOMEVEND,;             //03        
												_cDOC,;                  //04	 
												StoD(TRBP->DTEMISSAO),;  //05     
												TRBP->ITEM,;        	 //06	 
												TRBP->PRODUTO,;      	 //07	 
												Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_CODTAB"),;//11
												Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_REV"),;   //12	     
												TRBP->VLTOTAL,;          //10	 
												_nPerPed,;               //11     
												_nVLCOMTAB})             //12	     


				EndIf

			EndIf	

		ElseIf _cPgCliente == "1" .And. _cPgRepre == "1"  

			DbSelectArea("SC6")
			DbSetOrder(1)  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
			If SC6->(dbSeek(xFilial("SC6")+TRBP->DOC+TRBP->ITEM+TRBP->PRODUTO)) 
							
				Reclock("SC6",.F.)
					
					SC6->C6_XCOM1     := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_COMIS1")         
					SC6->C6_XTABCOM   := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_CODTAB")       
					SC6->C6_XREVCOM   := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_REV")       
					SC6->C6_XDTRVC    := DDATABASE  
					SC6->C6_XTPCOM    := If(Empty(_cTpCom),"04",_cTpCom)
					SC6->C6_COMIS1    := 0
					SC6->C6_COMIS2    := 0
					SC6->C6_COMIS3    := 0
					SC6->C6_COMIS4    := 0
					SC6->C6_COMIS5    := 0

				SC6->( Msunlock() )
					

				lAbre := .T.

				aAdd(aPlanilha,{AllTrim("Comissão Zero"),;               //01
												_cVENDEDOR,;             //02
												_cNOMEVEND,;             //03        
												_cDOC,;                  //04	 
												StoD(TRBP->DTEMISSAO),;  //05     
												TRBP->ITEM,;        	 //06	 
												TRBP->PRODUTO,;      	 //07
												Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_CODTAB"),;//11
												Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_REV"),;   //12	     
												TRBP->VLTOTAL,;          //09	 
												0,;                      //10     
												0})	   				     //12	     
		
			EndIf	
		
		Else  

			DbSelectArea("SC6")
			DbSetOrder(1)  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
			If SC6->(dbSeek(xFilial("SC6")+TRBP->DOC+TRBP->ITEM+TRBP->PRODUTO)) 
							
				Reclock("SC6",.F.)
					
					SC6->C6_XCOM1     := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_COMIS1")         
					SC6->C6_XTABCOM   := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_CODTAB")       
					SC6->C6_XREVCOM   := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_REV")       
					SC6->C6_XDTRVC    := DDATABASE  
					SC6->C6_XTPCOM    := If(Empty(_cTpCom),"04",_cTpCom)
					SC6->C6_COMIS1    := 0
					SC6->C6_COMIS2    := 0
					SC6->C6_COMIS3    := 0
					SC6->C6_COMIS4    := 0
					SC6->C6_COMIS5    := 0

				SC6->( Msunlock() )
					

				lAbre := .T.

				aAdd(aPlanilha,{AllTrim("Comissão Zero"),;               //01
												_cVENDEDOR,;             //02
												_cNOMEVEND,;             //03        
												_cDOC,;                  //04	 
												StoD(TRBP->DTEMISSAO),;  //05     
												TRBP->ITEM,;        	 //06	 
												TRBP->PRODUTO,;      	 //07	 
												Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_CODTAB"),;//11
												Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_REV"),;   //12	     
												TRBP->VLTOTAL,;          //10	 
												0,;                      //11     
												0})  					 //12	     
			
			
			EndIf


		EndIf
			
		TRBP->(DbSkip())

		IncProc("Gerando arquivo...")	

		If TRBP->(EOF()) .Or. TRBP->DOC <> _cDOC 
		
			_nPCalcCom   := Round((_nComPerc/_nVLTOTAL)*100,2) 
			_nPCalcTab   := Round((_nPercTab/_nVLTOTAL)*100,2) 	
		
			If _cPgCliente == "2" .And. _nPercCli > 0	
			
				DbSelectArea("SC5")
				DbSetOrder(1)  
				If SC5->(dbSeek(xFilial("SC5")+ _cDOC)) 
								
					Reclock("SC5",.F.)
							
						SC5->C5_COMIS1    := _nPercCli
						SC5->C5_COMIS2    := 0
						SC5->C5_COMIS3    := 0
						SC5->C5_COMIS4    := 0
						SC5->C5_COMIS5    := 0

					SC5->( Msunlock() )
					
				EndIf 

				aAdd(aPlanilha,{AllTrim("SubTotal-->"),;    //01
										TRBP->VENDEDOR,;    //02
										TRBP->NOMEVEND,;    //03        
										TRBP->DOC,;         //04	 
										_dDataPed,;         //05     
										"",;        	    //06	 
										"",;      	        //07	 
										"",;				//08
										"",;                //09
										_nVLTOTAL,;         //10	 
										_nPCalcCom,;        //11     
										_nPCalcTab})        //12	     


				aAdd(aPlanilha,{"",;    //01
								"",;    //02
								"",;    //03        
								"",;    //04	 
								"",;    //05     
								"",;    //06	 
								"",;    //07	 
								"",;    //08	 
								"",;    //09	 
								"",;    //10	 
								"",;    //11     
								""})    //12	     


			ElseIf _cPgCliente == "2" .And. _cPgRepre == "2" .And. _nPercCli <= 0 
			
				DbSelectArea("SC5")
				DbSetOrder(1)  
				If SC5->(dbSeek(xFilial("SC5")+ _cDOC)) 
								
					Reclock("SC5",.F.)
							
						SC5->C5_COMIS1    := _nPCalcCom
						SC5->C5_COMIS2    := 0
						SC5->C5_COMIS3    := 0
						SC5->C5_COMIS4    := 0
						SC5->C5_COMIS5    := 0

					SC5->( Msunlock() )
					
				EndIf 

				aAdd(aPlanilha,{AllTrim("SubTotal-->"),;    //01
										TRBP->VENDEDOR,;    //02
										TRBP->NOMEVEND,;    //03        
										TRBP->DOC,;         //04	 
										_dDataPed,;         //05     
										"",;        	    //06	 
										"",;      	        //07	 
										"",;        	    //06	 
										"",;      	        //07	 
										_nVLTOTAL,;         //08	 
										_nPCalcCom,;        //09     
										_nPCalcTab})        //12	     

				aAdd(aPlanilha,{"",;    //01
								"",;    //02
								"",;    //03        
								"",;    //04	 
								"",;    //05     
								"",;    //06	 
								"",;    //07	 
								"",;    //08	 
								"",;    //09	 
								"",;    //10	 
								"",;    //11     
								""})    //12	     


			ElseIf _cPgCliente == "1" .And. _cPgRepre == "1"

				DbSelectArea("SC5")
				DbSetOrder(1)  
				If SC5->(dbSeek(xFilial("SC5")+ _cDOC)) 
								
					Reclock("SC5",.F.)
								
						SC5->C5_COMIS1    := 0
						SC5->C5_COMIS2    := 0
						SC5->C5_COMIS3    := 0
						SC5->C5_COMIS4    := 0
						SC5->C5_COMIS5    := 0

					SC5->( Msunlock() )
					
				EndIf 

				aAdd(aPlanilha,{AllTrim("SubTotal-->"),;    //01
										TRBP->VENDEDOR,;    //02
										TRBP->NOMEVEND,;    //03        
										TRBP->DOC,;         //04	 
										_dDataPed,;         //05     
										"",;        	    //06	 
										"",;      	        //07	 
										"",;        	    //08	 
										"",;      	        //09	 
										_nVLTOTAL,;         //10	 
										0,;                 //11     
										0})                 //12	     
				
				aAdd(aPlanilha,{"",;    //01
								"",;    //02
								"",;    //03        
								"",;    //04	 
								"",;    //05     
								"",;    //06	 
								"",;    //07	 
								"",;    //08	 
								"",;    //10	 
								"",;    //11     
								""})    //12	     

			Else

				DbSelectArea("SC5")
				DbSetOrder(1)  
				If SC5->(dbSeek(xFilial("SC5")+ _cDOC)) 
								
					Reclock("SC5",.F.)
								
						SC5->C5_COMIS1    := 0
						SC5->C5_COMIS2    := 0
						SC5->C5_COMIS3    := 0
						SC5->C5_COMIS4    := 0
						SC5->C5_COMIS5    := 0

					SC5->( Msunlock() )
					
				EndIf 

				aAdd(aPlanilha,{AllTrim("SubTotal-->"),;    //01
										TRBP->VENDEDOR,;    //02
										TRBP->NOMEVEND,;    //03        
										TRBP->DOC,;         //04	 
										_dDataPed,;         //05     
										"",;        	    //06	 
										"",;      	        //07	 
										"",;        	    //08	 
										"",;      	        //09	 
										_nVLTOTAL,;         //10	 
										0,;                 //11     
										0})                 //12	     
				
				aAdd(aPlanilha,{"",;    //01
								"",;    //02
								"",;    //03        
								"",;    //04	 
								"",;    //05     
								"",;    //06	 
								"",;    //07	 
								"",;    //08	 
								"",;    //09	 
								"",;    //10	 
								"",;    //11     
								""})    //12	     

			EndIf
				
			_nVLCOMIS1  := 0
			_nVLCOMTAB  := 0
			_nVLTOTAL   := 0
			_nPCalcCom  := 0
			_nPCalcTab  := 0 
			_cGEREN		:= ""
			_cVENDEDOR  := ""
			_cNOMEVEND 	:= ""
			_cDOC  		:= ""
			_dDataPed   := "" 
			_cItem      := ""
			_cProduto   := ""
			
		EndIf 

	EndDo

	For nPlan:=1 To Len(aPlanilha)
		
		lAbre := .T.

		oExcel:AddRow(cPlan,cTit,{aPlanilha[nPlan][01],;
								  aPlanilha[nPlan][02],;
								  aPlanilha[nPlan][03],;
								  aPlanilha[nPlan][04],;
								  aPlanilha[nPlan][05],;
								  aPlanilha[nPlan][06],;
								  aPlanilha[nPlan][07],;
								  aPlanilha[nPlan][08],;
								  aPlanilha[nPlan][09],;
								  aPlanilha[nPlan][10],;
								  aPlanilha[nPlan][11],;
								  aPlanilha[nPlan][12]}) 
	Next nPlan

ElseIf MV_PAR03 == 2 

	oExcel:AddworkSheet(cPlan)
	oExcel:AddTable(cPlan, cTit)
	oExcel:AddColumn(cPlan, cTit, "Status"             , 1, 1, .F.)  //01
	oExcel:AddColumn(cPlan, cTit, "Vendedor"           , 1, 1, .F.)  //02
	oExcel:AddColumn(cPlan, cTit, "Nome Vendedor"      , 1, 1, .F.)  //03
	oExcel:AddColumn(cPlan, cTit, "Nf/Titulo"          , 1, 1, .F.)  //04
	oExcel:AddColumn(cPlan, cTit, "Serie/Prefixo"      , 1, 1, .F.)  //05
	oExcel:AddColumn(cPlan, cTit, "Parcela"            , 1, 1, .F.)  //06
	oExcel:AddColumn(cPlan, cTit, "Data Pedido"        , 1, 1, .F.)  //07
	oExcel:AddColumn(cPlan, cTit, "Item"               , 1, 1, .F.)  //08
	oExcel:AddColumn(cPlan, cTit, "Produto"            , 1, 1, .F.)  //09
	oExcel:AddColumn(cPlan, cTit, "Codigo Tabela"      , 1, 1, .F.)  //10
	oExcel:AddColumn(cPlan, cTit, "Revisão Tabela"     , 1, 1, .F.)  //11
	oExcel:AddColumn(cPlan, cTit, "Valor Item"         , 3, 2, .F.)  //12
	oExcel:AddColumn(cPlan, cTit, "% Comissão"         , 3, 2, .F.)  //13
	oExcel:AddColumn(cPlan, cTit, "% Comissão Tabela"  , 3, 2, .F.)  //14


	If Select("TRBP") > 0
		TRBP->(DbCloseArea())
	EndIf

	cQueryP := "SELECT 'FATURADO' AS TPREG," + CRLF 
	cQueryP += "D2_TIPO AS TIPO, " + CRLF
	cQueryP += "A3_GEREN AS GEREN, " + CRLF
	cQueryP += "F2_VEND1 AS VENDEDOR, " + CRLF
	cQueryP += "A3_NOME AS NOMEVEND, " + CRLF
	cQueryP += "A1_COD AS CODCLI, " + CRLF
	cQueryP += "A1_LOJA AS LOJA, " + CRLF
	cQueryP += "A1_NOME AS NOMECLI, " + CRLF
	cQueryP += "B1_COD AS PRODUTO, " + CRLF
	cQueryP += "B1_DESC AS DESCRI, " + CRLF
	cQueryP += "D2_ITEM AS ITEM, " + CRLF
	cQueryP += "D2_DOC AS DOC, " + CRLF
	cQueryP += "D2_SERIE AS SERIE," + CRLF
	cQueryP += "D2_PEDIDO AS PEDIDO, " + CRLF
	cQueryP += "D2_EMISSAO AS DTEMISSAO, " + CRLF
	cQueryP += "A1_XPGCOM AS XA1PGCOM, " + CRLF
	cQueryP += "A3_XCLT AS XCLT, " + CRLF
	cQueryP += "A3_XPGCOM AS  XA3PGCOM, " + CRLF
	cQueryP += "A3_COMIS AS A3COMIS, " + CRLF
	cQueryP += "D2_COMIS1 AS C6COMIS, " + CRLF
	cQueryP += "D2_XTABCOM AS XTABCOM, " + CRLF
	cQueryP += "D2_VALBRUT AS VLBRUTO, " + CRLF
	cQueryP += "D2_TOTAL AS VLTOTAL, " + CRLF
	cQueryP += "D2_VALACRS AS  VALACRS, " + CRLF
	cQueryP += "B1_COMIS AS B1COMIS, " + CRLF
	cQueryP += "D2_XCOM1 AS D2XCOM1, " + CRLF
	cQueryP += "'' AS NUMTIT, " + CRLF 
	cQueryP += "'' AS PREFIXO, " + CRLF
	cQueryP += "'' AS PARCELA, " + CRLF
	cQueryP += "'' AS TIPOTIT, " + CRLF
	cQueryP += "'' AS DTEMISSAOTIT, " + CRLF
	cQueryP += "'' AS DTVENCREA, " + CRLF
	cQueryP += "'' AS DTBAIXA,  " + CRLF
	cQueryP += "'' AS VLBASCOM1, " + CRLF
	cQueryP += "'' AS VLCOM1, " + CRLF
	cQueryP += "'' AS VLTITULO, " + CRLF
	cQueryP += "F4_DUPLIC AS F4DUPLIC, " + CRLF
	cQueryP += "A1_XCOMIS1 AS XCOMIS1, " + CRLF
	cQueryP += "C6_XTABCOM AS C6XTABCOM, " + CRLF
	cQueryP += "C6_XREVCOM AS C6XREVCOM, " + CRLF
	cQueryP += "C6_XDTRVC AS C6XDTRVC, " + CRLF
	cQueryP += "C6_XTPCOM AS C6XTPCOM, " + CRLF
	cQueryP += "C6_COMIS1 AS C6COMIS1, " + CRLF
	cQueryP += "C6_XCOM1 AS C6XCOM1  "+ CRLF
	cQueryP += "FROM "+RetSqlName("SD2")+" AS SD2 WITH (NOLOCK) " + CRLF  
	cQueryP += "INNER JOIN "+RetSqlName("SF2")+" AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL " + CRLF 
	cQueryP += " AND F2_DOC = D2_DOC " + CRLF
	cQueryP += " AND F2_SERIE = D2_SERIE " + CRLF
	cQueryP += " AND F2_CLIENTE = D2_CLIENTE " + CRLF
	cQueryP += " AND F2_LOJA = D2_LOJA " + CRLF
	cQueryP += " AND F2_TIPO = D2_TIPO " + CRLF
	cQueryP += " AND F2_EMISSAO = D2_EMISSAO " + CRLF
	cQueryP += " AND SF2.D_E_L_E_T_ = ' ' " + CRLF
	cQueryP += "INNER JOIN "+RetSqlName("SC6")+" AS SC6 WITH (NOLOCK) ON D2_FILIAL = C6_FILIAL " + CRLF
	cQueryP += " AND C6_PRODUTO = D2_COD  "+ CRLF
	cQueryP += " AND C6_NUM  = D2_PEDIDO  "+ CRLF
	cQueryP += " AND C6_CLI  = D2_CLIENTE "+ CRLF
	cQueryP += " AND C6_LOJA = D2_LOJA    "+ CRLF
	cQueryP += " AND SC6.D_E_L_E_T_ = ' ' "+ CRLF
	cQueryP += "INNER JOIN "+RetSqlName("SE1")+" AS SE1 WITH (NOLOCK) ON E1_FILIAL = F2_FILIAL " + CRLF
	cQueryP += " AND E1_NUM = F2_DOC " + CRLF
	cQueryP += " AND E1_PREFIXO = F2_SERIE " + CRLF
	cQueryP += " AND E1_CLIENTE = F2_CLIENTE " + CRLF
	cQueryP += " AND E1_LOJA = F2_LOJA " + CRLF
	cQueryP += " AND E1_EMISSAO = F2_EMISSAO " + CRLF
	cQueryP += " AND SE1.D_E_L_E_T_ = ' '  " + CRLF
	cQueryP += "INNER JOIN "+RetSqlName("SF4")+" AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(D2_FILIAL, 2) " + CRLF
	cQueryP += " AND F4_CODIGO = D2_TES " + CRLF
	cQueryP += " AND SF4.D_E_L_E_T_ = ' ' " + CRLF
	cQueryP += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) ON B1_FILIAL = '    ' " + CRLF
	cQueryP += " AND B1_COD = D2_COD " + CRLF
	cQueryP += " AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQueryP += "INNER JOIN "+RetSqlName("SA3")+" AS SA3 WITH (NOLOCK) ON A3_COD = F2_VEND1 " + CRLF
	cQueryP += "	AND SA3.D_E_L_E_T_ = ' ' " + CRLF
	cQueryP += "INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH (NOLOCK) ON A1_FILIAL = F2_FILIAL " + CRLF
	cQueryP += " AND A1_COD = F2_CLIENTE " + CRLF
	cQueryP += " AND A1_LOJA = F2_LOJA " + CRLF
	cQueryP += "WHERE D2_FILIAL = '"+xFilial("SD2")+"' " + CRLF
	cQueryP += " AND D2_TIPO  = 'N' " + CRLF
	cQueryP += " AND D2_DOC = '"+MV_PAR02+"' " + CRLF
	cQueryP += " AND SD2.D_E_L_E_T_ = ' '  " + CRLF
	cQueryP += "GROUP BY D2_TIPO,A3_GEREN,F2_VEND1,A3_NOME,A1_COD,A1_LOJA,A1_NOME,B1_COD,B1_DESC,D2_ITEM,D2_DOC,D2_SERIE,D2_PEDIDO,D2_EMISSAO, " + CRLF
	cQueryP += "A1_XPGCOM,A3_XCLT,A3_XPGCOM,A3_COMIS,D2_COMIS1,D2_XTABCOM,D2_TOTAL,B1_COMIS,D2_XCOM1,D2_VALACRS,D2_VALBRUT,F4_DUPLIC,A1_XCOMIS1, " + CRLF
	cQueryP += "C6_XTABCOM, C6_XREVCOM, C6_XDTRVC, C6_XTPCOM, C6_COMIS1, C6_XCOM1  " + CRLF

	cQueryP += "UNION " + CRLF

	cQueryP += "SELECT 'TITULO' AS TPREG, " + CRLF 
	cQueryP += "'T' AS TIPO, " + CRLF
	cQueryP += "A3_GEREN AS GEREN, " + CRLF
	cQueryP += "F2_VEND1 AS VENDEDOR, " + CRLF
	cQueryP += "A3_NOME AS NOMEVEND, " + CRLF
	cQueryP += "A1_COD AS CODCLI, " + CRLF
	cQueryP += "A1_LOJA AS LOJA, " + CRLF
	cQueryP += "A1_NOME AS NOMECLI, " + CRLF
	cQueryP += "'' AS PRODUTO, " + CRLF
	cQueryP += "'' AS DESCRI, " + CRLF
	cQueryP += "'' AS ITEM, " + CRLF
	cQueryP += "E1_NUM AS DOC, " + CRLF
	cQueryP += "E1_PREFIXO AS SERIE,  " + CRLF
	cQueryP += "'' AS PEDIDO, " + CRLF
	cQueryP += "E1_EMISSAO AS DTEMISSAO, " + CRLF 
	cQueryP += "A1_XPGCOM AS XA1PGCOM, " + CRLF
	cQueryP += "A3_XCLT AS XCLT, " + CRLF
	cQueryP += "A3_XPGCOM AS  XA3PGCOM, " + CRLF
	cQueryP += "A3_COMIS AS A3COMIS, " + CRLF
	cQueryP += "0 AS C6COMIS, " + CRLF
	cQueryP += "0 AS XTABCOM, " + CRLF
	cQueryP += "0 AS VLBRUTO, " + CRLF
	cQueryP += "0 AS VLTOTAL, " + CRLF
	cQueryP += "0 AS VALACRS, " + CRLF
	cQueryP += "0 AS B1COMIS, " + CRLF
	cQueryP += "0 AS D2XCOM1, " + CRLF
	cQueryP += "E1_NUM AS NUMTIT, " + CRLF 
	cQueryP += "E1_PREFIXO AS PREFIXO, " + CRLF
	cQueryP += "E1_PARCELA AS PARCELA, " + CRLF
	cQueryP += "E1_TIPO AS TIPOTIT, " + CRLF
	cQueryP += "E1_EMISSAO AS DTEMISSAOTIT, " + CRLF
	cQueryP += "E1_VENCREA AS DTVENCREA, " + CRLF
	cQueryP += "E1_BAIXA AS DTBAIXA,  " + CRLF
	cQueryP += "E1_BASCOM1 AS VLBASCOM1, " + CRLF
	cQueryP += "E1_COMIS1  AS VLCOM1, " + CRLF
	cQueryP += "E1_VALOR   AS VLTITULO, " + CRLF
	cQueryP += "'' AS F4DUPLIC, " + CRLF
	cQueryP += "A1_XCOMIS1 AS XCOMIS1, " + CRLF
	cQueryP += "'' AS C6XTABCOM, " + CRLF
	cQueryP += "'' AS C6XREVCOM, " + CRLF
	cQueryP += "'' AS C6XDTRVC, " + CRLF
	cQueryP += "'' AS C6XTPCOM, " + CRLF
	cQueryP += "0 AS C6COMIS1, " + CRLF
	cQueryP += "0 AS C6XCOM1  "+ENTER
	cQueryP += "FROM "+RetSqlName("SE1")+" AS SE1 WITH (NOLOCK) " + CRLF 
	cQueryP += "INNER JOIN "+RetSqlName("SF2")+" AS SF2 WITH (NOLOCK) ON E1_FILIAL = F2_FILIAL " + CRLF
	cQueryP += " AND E1_NUM = F2_DOC " + CRLF
	cQueryP += " AND E1_PREFIXO = F2_SERIE " + CRLF
	cQueryP += " AND E1_CLIENTE = F2_CLIENTE " + CRLF
	cQueryP += " AND E1_LOJA = F2_LOJA " + CRLF
	cQueryP += " AND E1_EMISSAO = F2_EMISSAO " + CRLF
	cQueryP += " AND SE1.D_E_L_E_T_ = ' '  " + CRLF
	cQueryP += "INNER JOIN "+RetSqlName("SA3")+" AS SA3 WITH (NOLOCK) ON A3_COD = F2_VEND1 " + CRLF
	cQueryP += " AND SA3.D_E_L_E_T_ = ' ' " + CRLF
	cQueryP += "INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH (NOLOCK) ON A1_FILIAL = F2_FILIAL " + CRLF
	cQueryP += " AND A1_COD = F2_CLIENTE " + CRLF
	cQueryP += " AND A1_LOJA = F2_LOJA " + CRLF
	cQueryP += "WHERE E1_FILIAL = '"+xFilial("SE1")+"'  " + CRLF
	cQueryP += " AND F2_TIPO  = 'N' " + CRLF
	cQueryP += " AND E1_TIPO  = 'NF ' " + CRLF
	cQueryP += " AND E1_NUM = '"+MV_PAR02+"' " + CRLF
	cQueryP += " AND SE1.D_E_L_E_T_ = ' '  " + CRLF
	cQueryP += "GROUP BY A3_GEREN,F2_VEND1,A3_NOME,A1_COD,A1_LOJA,A1_NOME,E1_EMISSAO,A1_XPGCOM,A3_XCLT,A3_XPGCOM,A3_COMIS,E1_NUM,E1_PREFIXO, " + CRLF
	cQueryP += "E1_PARCELA,E1_TIPO,E1_EMISSAO,E1_VENCREA,E1_BAIXA,E1_BASCOM1,E1_COMIS1,E1_VALOR,A1_XCOMIS1 " + CRLF
	cQueryP += "ORDER BY VENDEDOR,DOC,TPREG,PARCELA,DTEMISSAO,ITEM " + CRLF

	TCQuery cQueryP New Alias "TRBP"

	TRBP->(DbGoTop())

	While TRBP->(!Eof())

		_cPgCliente  := ""
		_cRepreClt   := ""
		_cPgRepre    := ""
		_nReprePorc  := 0
		_nPercCli    := 0

		_cPgCliente  := TRBP->XA1PGCOM  // 1 = Não / 2 = Sim
		_cRepreClt   := TRBP->XCLT      // 1 = Não / 2 = Sim
		_cPgRepre    := TRBP->XA3PGCOM  // 1 = Não / 2 = Sim
		If TRBP->B1COMIS > 0
			_nReprePorc  := TRBP->A3COMIS   // % do vendedor 
			_nPercCli    := TRBP->XCOMIS1   // % por cliente 
		Else 
			_nReprePorc  += 0   // % do vendedor 
			_nPercCli    += 0   // % por cliente 
		EndIf	
		_cGEREN		 := TRBP->GEREN
		_cVENDEDOR   := TRBP->VENDEDOR
		_cNOMEVEND 	 := TRBP->NOMEVEND 
		_cDOC  		 := TRBP->DOC                    
		_dDataPed    := StoD(TRBP->DTEMISSAO)
		_cItem       := TRBP->ITEM
		_cProduto    := TRBP->PRODUTO 

		If _cPgCliente == "2" .And. _cPgRepre == "2" .And. TRBP->F4DUPLIC == "S"

			If  AllTrim(TRBP->TPREG) == "FATURADO"

				_nVLBRUTO   += TRBP->VLBRUTO 

				If TRBP->B1COMIS > 0
					_nVLCOMIS1  := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_COMIS1")
					_nVLCOMTAB  := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_COMIS1")         
					_nVLTOTAL   += TRBP->VLTOTAL
					_nVALACRS   += TRBP->VALACRS
				Else 
					_nVLCOMIS1  := 0
					_nVLCOMTAB  := 0
					_nVLTOTAL   += 0
					_nVALACRS   += 0
				EndIf

				If TRBP->XA1PGCOM == "2" .And. TRBP->XCOMIS1 > 0
				
					If TRBP->B1COMIS > 0
						_nPercTab   += Round((TRBP->VLTOTAL * _nVLCOMTAB)/100,2) 
						_nComPerc   += Round((TRBP->VLTOTAL * TRBP->XCOMIS1)/100,2)
					Else 
						_nPercTab   += 0
						_nComPerc   += 0
					EndIf

				ElseIf TRBP->XCLT == "2" .And. TRBP->XA3PGCOM == "2" .And. TRBP->XCOMIS1 <= 0
				
					If TRBP->B1COMIS > 0
						_nPercTab   += Round((TRBP->VLTOTAL * _nVLCOMTAB)/100,2) 
						_nComPerc   += Round((TRBP->VLTOTAL * TRBP->A3COMIS)/100,2)
					Else 
						_nPercTab   += 0
						_nComPerc   += 0
					Endif 

				ElseIf TRBP->XA1PGCOM == "2" .And. TRBP->XCOMIS1 <= 0
				
					If TRBP->B1COMIS > 0
						_nPercTab   += Round((TRBP->VLTOTAL * _nVLCOMTAB)/100,2) 
						_nComPerc   += Round((TRBP->VLTOTAL * Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_COMIS1"))/100,2)
					Else 
						_nPercTab   += 0
						_nComPerc   += 0
					EndIf
				
				EndIf
				
				If TRBP->B1COMIS > 0

					If TRBP->XCOMIS1 > 0
						_nPerPed    := If(TRBP->XA1PGCOM=="2".And.TRBP->XCOMIS1 > 0,TRBP->XCOMIS1,Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_COMIS1"))
					Else 
						_nPerPed    := If(TRBP->XCLT=="2".And.TRBP->XA3PGCOM=="2",TRBP->A3COMIS,Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_COMIS1"))
					EndIf

				Else 
					_nPerPed    := 0

				EndIf

				DbSelectArea("SD2")
				DbSetOrder(3)  //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				If SD2->(dbSeek(xFilial("SD2")+TRBP->DOC+TRBP->SERIE+TRBP->CODCLI+TRBP->LOJA+TRBP->PRODUTO+TRBP->ITEM)) 
							
					Reclock("SD2",.F.)
							
						SD2->D2_XCOM1     := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_COMIS1")         
						SD2->D2_XTABCOM   := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_CODTAB")       
						SD2->D2_XREVCOM   := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_REV")       
						SD2->D2_XDTRVC    := StoD(TRBP->C6XDTRVC)
						SD2->D2_COMIS1    := _nPerPed
						SD2->D2_COMIS2    := 0
						SD2->D2_COMIS3    := 0
						SD2->D2_COMIS4    := 0
						SD2->D2_COMIS5    := 0

					SD2->( Msunlock() )

					aAdd(aPlanilha,{AllTrim("Atualizado"),;              //01
												_cVENDEDOR,;             //02
												_cNOMEVEND,;             //03        
												_cDOC,;                  //04
												TRBP->PREFIXO,;          //05
												TRBP->PARCELA,;          //06
												StoD(TRBP->DTEMISSAO),;  //07     
												TRBP->ITEM,;        	 //08	 
												TRBP->PRODUTO,;      	 //09
												Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_CODTAB"),; //10
												Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_REV"),;	   //11
												TRBP->VLTOTAL,;          //12	 
												_nPerPed,;               //13     
												_nVLCOMTAB})             //14	     

				EndIf

			EndIf	

		ElseIf _cPgCliente == "1" .And. _cPgRepre == "1"  

			If  AllTrim(TRBP->TPREG) == "FATURADO"

				DbSelectArea("SD2")
				DbSetOrder(3)  //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				If SD2->(dbSeek(xFilial("SD2")+TRBP->DOC+TRBP->SERIE+TRBP->CODCLI+TRBP->LOJA+TRBP->PRODUTO+TRBP->ITEM)) 
								
					Reclock("SD2",.F.)
								
						SD2->D2_COMIS1    := 0
						SD2->D2_XCOM1     := 0
						SD2->D2_COMIS2    := 0
						SD2->D2_COMIS3    := 0
						SD2->D2_COMIS4    := 0
						SD2->D2_COMIS5    := 0

						SD2->( Msunlock() )

						aAdd(aPlanilha,{AllTrim("Comissão Zerada"),;         //01
													_cVENDEDOR,;             //02
													_cNOMEVEND,;             //03        
													_cDOC,;                  //04	
													TRBP->PREFIXO,;          //05
													TRBP->PARCELA,;          //06
													StoD(TRBP->DTEMISSAO),;  //07     
													TRBP->ITEM,;        	 //08	 
													TRBP->PRODUTO,;      	 //09
													Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_CODTAB"),; //10
													Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_REV"),;	   //11
													0,;                      //12	 
													0,;                      //13     
													0})                      //14	     

				EndIf
			
			EndIf
		Else  

			If  AllTrim(TRBP->TPREG) == "FATURADO"

				DbSelectArea("SD2")
				DbSetOrder(3)  //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				If SD2->(dbSeek(xFilial("SD2")+TRBP->DOC+TRBP->SERIE+TRBP->CODCLI+TRBP->LOJA+TRBP->PRODUTO+TRBP->ITEM)) 
								
					Reclock("SD2",.F.)
								
						SD2->D2_COMIS1    := 0
						SD2->D2_XCOM1     := 0
						SD2->D2_COMIS2    := 0
						SD2->D2_COMIS3    := 0
						SD2->D2_COMIS4    := 0
						SD2->D2_COMIS5    := 0

						SD2->( Msunlock() )

						aAdd(aPlanilha,{AllTrim("Comissão Zerada"),;         //01
													_cVENDEDOR,;             //02
													_cNOMEVEND,;             //03        
													_cDOC,;                  //04	 
													TRBP->PREFIXO,;          //05
													TRBP->PARCELA,;          //06
													StoD(TRBP->DTEMISSAO),;  //07     
													TRBP->ITEM,;        	 //08	 
													TRBP->PRODUTO,;      	 //09
													Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_CODTAB"),; //10
													Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_REV"),;	   //11
													0,;                      //12	 
													0,;                      //13     
													0})                      //14	     

				EndIf
			
			EndIf

		EndIf

		If  AllTrim(TRBP->TPREG) == "TITULO"

			_nCount := 0

			If Select("TRB3") > 0
				TRB3->(DbCloseArea())
			EndIf

			cQueryC := "SELECT COUNT(E1_NUM) AS QUANT " + CRLF
			cQueryC += "FROM "+RetSqlName("SE1")+" AS SE1 " + CRLF
			cQueryC += " WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' " + CRLF
			cQueryC += " AND SE1.E1_NUM     = '"+TRBP->NUMTIT+"'  " + CRLF
			cQueryC += " AND SE1.E1_PREFIXO = '"+TRBP->PREFIXO+"'  " + CRLF
			cQueryC += " AND SE1.E1_CLIENTE = '"+TRBP->CODCLI+"'  " + CRLF
			cQueryC += " AND SE1.E1_LOJA    = '"+TRBP->LOJA+"'  " + CRLF
			cQueryC += " AND SE1.E1_TIPO    = 'NF '   " + CRLF
			cQueryC += " AND SE1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryC += "UNION " + CRLF			
			cQueryC += "SELECT COUNT(E5_NUMERO)*(-1) AS QUANT " + CRLF
			cQueryC += "FROM "+RetSqlName("SE5")+" AS SE5 " + CRLF
			cQueryC += " WHERE SE5.E5_FILIAL = '"+xFilial("SE5")+"' " + CRLF
			cQueryC += " AND SE5.E5_NUMERO  = '"+TRBP->NUMTIT+"'  " + CRLF
			cQueryC += " AND SE5.E5_PREFIXO = '"+TRBP->PREFIXO+"'  " + CRLF
			cQueryC += " AND SE5.E5_CLIFOR  = '"+TRBP->CODCLI+"'  " + CRLF
			cQueryC += " AND SE5.E5_LOJA    = '"+TRBP->LOJA+"'  " + CRLF
			cQueryC += " AND SE5.E5_MOTBX IN ('LIQ','CAN') " + CRLF
			cQueryC += " AND SE5.E5_TIPO    = 'NF '   " + CRLF
			cQueryC += " AND SE5.D_E_L_E_T_ = ' ' " + CRLF

			TCQUERY cQueryC NEW ALIAS TRB3

			TRB3->(dbGoTop())

			While TRB3->(!Eof())
							
				_nCount += TRB3->QUANT

				TRB3->(dbSkip())

			Enddo

			_cDOC  		 := TRBP->DOC  
			_cSerie		 := TRBP->SERIE  
			_cPercela	 := TRBP->PARCELA  

			_nCMTOTAL   := ABS((_nVLTOTAL - _nVALACRS))
			_nBaseTit   := If(_nCount > 0,Round((_nCMTOTAL / _nCount),2),Round((_nCMTOTAL),2))
			_nPCalcCom  := Round((_nComPerc/_nVLTOTAL)*100,2) 
			_nPCalcTab  := Round((_nPercTab/_nVLTOTAL)*100,2) 	

			If _cPgCliente == "2" .And. _cPgRepre == "2"

				DbSelectArea("SE1")
				DbSetOrder(1)  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
				If SE1->(dbSeek(xFilial("SE1")+TRBP->PREFIXO+TRBP->NUMTIT+TRBP->PARCELA+TRBP->TIPOTIT)) 

					Reclock("SE1",.F.)
							
					If Empty(SE1->E1_VEND1)
						SE1->E1_VEND1     := _cVENDEDOR 
					EndIf
					SE1->E1_BASCOM1    := _nBaseTit
					SE1->E1_COMIS1     := _nPCalcCom  
					SE1->E1_XCOM1      := _nPCalcTab 
					SE1->E1_XBASCOM    := _nBaseTit

					SE1->( Msunlock() )

					aAdd(aPlanilha,{AllTrim("Titulo"),;     //01
											TRBP->VENDEDOR,;    //02
											TRBP->NOMEVEND,;    //03        
											TRBP->DOC,;         //04
											TRBP->PREFIXO,;     //05
											TRBP->PARCELA,;     //06
											_dDataPed,;         //07     
											"",;        	    //08	 
											"",;      	        //09
											"",;      	        //10
											"",;      	        //11
											_nBaseTit,;         //12	 
											_nPCalcCom,;        //13     
											_nPCalcTab})        //14

				EndIf

			ElseIf _cPgCliente == "1" .And. _cPgRepre == "1"

				DbSelectArea("SE1")
				DbSetOrder(1)  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
				If SE1->(dbSeek(xFilial("SE1")+TRBP->PREFIXO+TRBP->NUMTIT+TRBP->PARCELA+TRBP->TIPOTIT)) 

					Reclock("SE1",.F.)
								
					If Empty(SE1->E1_VEND1)
						SE1->E1_VEND1     := _cVENDEDOR 
					EndIf
					SE1->E1_BASCOM1    := 0
					SE1->E1_COMIS1     := 0
					SE1->E1_XCOM1      := 0
					SE1->E1_XBASCOM    := 0


					SE1->( Msunlock() )
					
					aAdd(aPlanilha,{AllTrim("Titulo"),;    //01
											TRBP->VENDEDOR,;    //02
											TRBP->NOMEVEND,;    //03        
											TRBP->DOC,;         //04	 
											TRBP->PREFIXO,;     //05
											TRBP->PARCELA,;     //06
											_dDataPed,;         //07     
											"",;        	    //08	 
											"",;      	        //09
											"",;        	    //10	 
											"",;      	        //11
											0,;                 //12	 
											0,;                 //13     
											0})                 //14

				EndIf

			Else 

				DbSelectArea("SE1")
				DbSetOrder(1)  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
				If SE1->(dbSeek(xFilial("SE1")+TRBP->PREFIXO+TRBP->NUMTIT+TRBP->PARCELA+TRBP->TIPOTIT)) 

					Reclock("SE1",.F.)
								
					If Empty(SE1->E1_VEND1)
						SE1->E1_VEND1     := _cVENDEDOR 
					EndIf
					SE1->E1_BASCOM1    := 0
					SE1->E1_COMIS1     := 0
					SE1->E1_XCOM1      := 0
					SE1->E1_XBASCOM    := 0

					SE1->( Msunlock() )

					aAdd(aPlanilha,{AllTrim("Titulo"),;         //01
										TRBP->VENDEDOR,;        //02
										TRBP->NOMEVEND,;        //03        
										TRBP->DOC,;             //04	 
										TRBP->PREFIXO,;         //05
										TRBP->PARCELA,;         //06
										_dDataPed,;             //07     
											"",;        	    //08	 
											"",;      	        //09
											"",;        	    //10	 
											"",;      	        //11
											0,;                 //12	 
											0,;                 //13     
											0})                 //14

				
				EndIf

			
			EndIf

		EndIf

		TRBP->(DbSkip())

		IncProc("Gerando arquivo...")	

		If TRBP->(EOF()) .Or. TRBP->DOC <> _cDOC 
				
			_nVLCOMIS1  := 0
			_nVLCOMTAB  := 0
			_nVLTOTAL   := 0
			_nVALACRS   := 0
			_nVLBRUTO   := 0
			_nPCalcCom  := 0
			_nPCalcTab  := 0 
			_cGEREN		:= ""
			_cVENDEDOR  := ""
			_cNOMEVEND 	:= ""
			_cDOC  		:= ""
			_dDataPed   := "" 
			_cItem      := ""
			_cProduto   := ""
			
		EndIf 

	EndDo

	For nPlan:=1 To Len(aPlanilha)
		
		lAbre := .T.

		oExcel:AddRow(cPlan,cTit,{aPlanilha[nPlan][01],;
								  aPlanilha[nPlan][02],;
								  aPlanilha[nPlan][03],;
								  aPlanilha[nPlan][04],;
								  aPlanilha[nPlan][05],;
								  aPlanilha[nPlan][06],;
								  aPlanilha[nPlan][07],;
								  aPlanilha[nPlan][08],;
								  aPlanilha[nPlan][09],;
								  aPlanilha[nPlan][10],;
								  aPlanilha[nPlan][11],;
								  aPlanilha[nPlan][12],;
								  aPlanilha[nPlan][13],;
								  aPlanilha[nPlan][14]}) 
    Next nPlan

EndIf

If lAbre

	oExcel:Activate()
	oExcel:GetXMLFile(cArqDst)
	OPENXML(cArqDst)
	oExcel:DeActivate()

Else

	MsgInfo("Não existe dados para serem impressos.", "SEM DADOS")

EndIf

If Select("TRBP") > 0
	TRBP->(DbCloseArea())
EndIf
If Select("TRB3") > 0
	TRB3->(DbCloseArea())
EndIf
If Select("SE1") > 0
	SE1->(DbCloseArea())
EndIf
If Select("SD2") > 0
	SD2->(DbCloseArea())
EndIf
If Select("SC6") > 0
	SC6->(DbCloseArea())
EndIf
If Select("SC5") > 0
	SC5->(DbCloseArea())
EndIf

Return

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | OPENXML   | Autor: | QUALY         | Data: | 13/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - OPENXML                                      |
+------------+-----------------------------------------------------------+
*/

Static Function OPENXML(cArq)
	Local cDirDocs := MsDocPath()
	Local cPath	   := AllTrim(GetTempPath())

	If !ApOleClient("MsExcel")
		Aviso("Atencao", "O Microsoft Excel nao esta instalado.", {"Ok"}, 2)
	Else
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(cArq)
		oExcelApp:SetVisible(.T.)
		oExcelApp:Destroy()
	EndIf
Return

/*
+------------+------------+--------+---------------+-------+--------------+
| Programa:  | oAjustaSx1 | Autor: | QUALY         | Data: | 13/02/21     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - Perguntas                                     |
+------------+------------------------------------------------------------+
*/
Static Function oAjustaSx1()

Local _aPerg  := {}  // aRRAY 
Local _ni

Aadd(_aPerg,{"Num. Pedido Venda .....?","mv_ch1","C",06,"G","mv_par01","","","","","","SC5","","",0})
Aadd(_aPerg,{"Num. Nf/Titulo ........?","mv_ch2","C",09,"G","mv_par02","","","","","","SE1","","",0})
Aadd(_aPerg,{"Reprocessa Nf.Tit/Ped.:?","mv_ch3","C",01,"C","mv_par03","Pedido","Nf/Titulo","","","","","","",0})

dbSelectArea("SX1")
For _ni := 1 To Len(_aPerg)
	If !dbSeek(_cPerg+ SPACE( LEN(SX1->X1_GRUPO) - LEN(_cPerg))+StrZero(_ni,2))
		RecLock("SX1",.T.)
		SX1->X1_GRUPO    := _cPerg
		SX1->X1_ORDEM    := StrZero(_ni,2)
		SX1->X1_PERGUNT  := _aPerg[_ni][1]
		SX1->X1_VARIAVL  := _aPerg[_ni][2]
		SX1->X1_TIPO     := _aPerg[_ni][3]
		SX1->X1_TAMANHO  := _aPerg[_ni][4]
		SX1->X1_GSC      := _aPerg[_ni][5]
		SX1->X1_VAR01    := _aPerg[_ni][6]
		SX1->X1_DEF01    := _aPerg[_ni][7]
		SX1->X1_DEF02    := _aPerg[_ni][8]
		SX1->X1_DEF03    := _aPerg[_ni][9]
		SX1->X1_DEF04    := _aPerg[_ni][10]
		SX1->X1_DEF05    := _aPerg[_ni][11]
		SX1->X1_F3       := _aPerg[_ni][12]
		SX1->X1_CNT01    := _aPerg[_ni][13]
		SX1->X1_VALID    := _aPerg[_ni][14]
		SX1->X1_DECIMAL  := _aPerg[_ni][15]
		MsUnLock()
	EndIf
Next _ni

Return
// fim
