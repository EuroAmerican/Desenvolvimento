//Bibliotecas
#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "FwBrowse.ch"
#Include "fwmbrowse.ch"
#include 'tbiconn.ch'
#include "topconn.ch"
#Include "PRCONST.ch"


/*/{Protheus.doc} PM050GRAF
description Rotina de Geração de Grafico
@type function
@version 1.0
@author Paulo Lenzi
@since 9/1/2023
@param cProduto, character, param_description
@return variant, return_description
/*/
User Function PM050GRAF(cProduto)
	Local oChart 		as Object 
	Local oDlg   		as Object 
	Local aBindParam    as array
	Local cQuery        as character
	Local cAlias        as character

	cQuery := "SELECT B3_COD, B3_Q01, B3_Q02, B3_Q03, B3_Q04, B3_Q05, B3_Q06, B3_Q07, B3_Q08, B3_Q09, B3_Q10, B3_Q11, B3_Q12 FROM "+ RETSQLNAME("SB3") + " WHERE D_E_L_E_T_ = ' ' AND B3_FILIAL = ? AND  B3_COD = ?"
    cQuery 		:= ChangeQuery(cQuery)
	aBindParam 	:= {xFilial("SB3"), cProduto}
	cAlias  	:= MPSysOpenQuery(cQuery,,,,aBindParam)
    if (cAlias)->(Eof())
        MsgAlert("Sem dados para o Grafico")
		Return
    ENDIF

DEFINE MSDIALOG oDlg PIXEL FROM 10,0 TO 600,600
		oChart := FWChartLine():New()
		oChart:init( oDlg, .t. ) 

        While (cAlias)->( !Eof() )
    		oChart:addSerie( cProduto, { {"Jan",(cAlias)->B3_Q01}, {"Fev",(cAlias)->B3_Q02}, {"Mar",(cAlias)->B3_Q03},;
										 {"Abr",(cAlias)->B3_Q04}, {"Mai",(cAlias)->B3_Q05}, {"Jun",(cAlias)->B3_Q06},;
										 {"Jul",(cAlias)->B3_Q07}, {"Ago",(cAlias)->B3_Q08}, {"Set",(cAlias)->B3_Q09},;
										 {"Out",(cAlias)->B3_Q10}, {"Nov",(cAlias)->B3_Q11}, {"Dez",(cAlias)->B3_Q12} })

			oChart:setLegend( CONTROL_ALIGN_LEFT ) 
			oChart:Build()
          (cAlias)->( dbSkip() )	
	    EndDo

ACTIVATE MSDIALOG oDlg
Return




/*	Local cQuery	:= ""

	DEFINE MSDIALOG oDlg PIXEL FROM 10,0 TO 600,600
	oChart := FWChartLine():New()
	oChart:init( oDlg, .t. ) 

 	cQuery := " SELECT B3_COD, B3_Q01, B3_Q02, B3_Q03, B3_Q04, B3_Q05, B3_Q06, B3_Q07, B3_Q08, B3_Q09, B3_Q10, B3_Q11, B3_Q12 "
	cQuery += "from "+ RETSQLNAME("SB3") + " SB3 "
	cQuery += "Where D_E_L_E_T_ = ' '"
	cQuery += "AND B3_FILIAL = '"+xFilial("SB3")+"'"
	cQuery += "AND B3_COD =  '"+cProduto+"'"

	If ( SELECT("TRBACD") ) > 0
		dbSelectArea("TRBACD")
		TRBACD->(dbCloseArea())
	EndIf

	TCQuery cQuery New Alias "TRBACD"

	TRBACD->(dbGoTop())

	If TRBACD->(!EOF())
		While TRBACD->(!EOF())

			oChart:addSerie( cProduto, { {"Jan",TRBACD->B3_Q01}, {"Fev",TRBACD->B3_Q02}, {"Mar",TRBACD->B3_Q03},;
										{"Abr",TRBACD->B3_Q04}, {"Mai",TRBACD->B3_Q05}, {"Jun",TRBACD->B3_Q06},;
										{"Jul",TRBACD->B3_Q07}, {"Ago",TRBACD->B3_Q08}, {"Set",TRBACD->B3_Q09},;
										{"Out",TRBACD->B3_Q10}, {"Nov",TRBACD->B3_Q11}, {"Dez",TRBACD->B3_Q12},;
										})

			oChart:setLegend( CONTROL_ALIGN_LEFT ) 
			TRBACD->(dbSkip())

   		End
		oChart:build()
	Endif
 

	ACTIVATE MSDIALOG oDlg

Return
*/
/*/{Protheus.doc} PM050Tela
description
@type function
@version 1.0
@author Paulo Lenzi
@since 9/1/2023
@return variant, return_description
/*/
User Function PM050Tela(cProduto)
 Local cArea := FWGetArea()
 Local oDlg as Object 
 Local oBrowse as Object 
  Local aBrowse as Array 
 Local cAlias  := GetNextAlias()
 Local aSize   := MsAdvSize()

oMainWnd:ReadClientCoors()
nHeight := oMainWnd:nHeight-50
nWidth  := oMainWnd:nWidth-15

aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 } 
 
 BeginSQL Alias cAlias
		SELECT   	C1_NUM,
					C1_ITEM,
					C1_EMISSAO,
					C1_DATPRF,
					C1_SOLICIT,
					C1_QUANT,
					isnull(C7_NUM,'') C7_NUM,
					isnull(C7_ITEM,'') C7_ITEM,
					isnull(C7_FORNECE,'') C7_FORNECE,
					isnull(C7_EMISSAO,' ') C7_EMISSAO,
					isnull(C7_DATPRF,'') C7_DATPRF,
					Isnull(C7_QUANT,0) C7_QUANT,
					isnull(C7_LOCAL,'') C7_LOCAL,
					isnull(D1_DOC,'') D1_DOC,
					isnull(D1_SERIE,'') D1_SERIE,
					isnull(D1_ITEM,'') D1_ITEM,
					isnull(D1_EMISSAO,'') D1_EMISSAO,
					isnull(D1_DTDIGIT,'') D1_DTDIGIT,
					isnull(D1_QUANT,0) D1_QUANT,
					isnull((C1_QUANT-  D1_QUANT ),0) DIV_QTD,
					isnull(DATEDIFF ( DAY , C1_DATPRF , D1_DTDIGIT ),0)  NDIAS
		FROM %Table:SC1% SC1

		Left Join %Table:SC7% SC7 ON C7_FILIAL = C1_FILIAL AND C7_PRODUTO = C1_PRODUTO AND C7_LOCAL = C1_LOCAL AND C7_NUM = C1_PEDIDO  AND C1_ITEMPED = C7_ITEM AND SC7.D_E_L_E_T_ = ' '
		Left join  %Table:SD1% SD1 on D1_FILIAL = C1_FILIAL AND D1_COD = C1_PRODUTO AND D1_LOCAL = C1_LOCAL AND D1_FORNECE = C7_FORNECE AND D1_LOJA = C7_LOJA AND D1_PEDIDO = C7_NUM  AND SD1.D_E_L_E_T_ = ' '

		WHERE SC1.%NotDel%
		and C1_FILIAL =  %xFilial:SC1%
		AND C1_PRODUTO =  %Exp:cProduto%
	    ORDER BY C1_NUM
 EndSQL
 TCSetField(cAlias, "C1_EMISSAO", "D")
 TCSetField(cAlias, "C1_DATPRF", "D")
 TCSetField(cAlias, "C7_EMISSAO", "D")
 TCSetField(cAlias, "C7_DATPRF", "D")
 TCSetField(cAlias, "D1_EMISSAO", "D")
 TCSetField(cAlias, "D1_DTDIGIT", "D")
 aBrowse :={}

 If (cAlias)->(!EOF())
          While (cAlias)->(!EOF())
		        aAdd(aBrowse , {(cAlias)->C1_NUM,;
							(cAlias)->C1_EMISSAO,;
							(cAlias)->C1_DATPRF,;
							(cAlias)->C1_SOLICIT,;
							(cAlias)->C1_QUANT,;
							(cAlias)->C7_NUM,;
							(cAlias)->C7_EMISSAO,;
							(cAlias)->C7_DATPRF,;
							(cAlias)->C7_QUANT,;
							(cAlias)->C7_LOCAL,;
							(cAlias)->D1_DOC,;
							(cAlias)->D1_SERIE,;
							(cAlias)->D1_EMISSAO,;
							(cAlias)->D1_DTDIGIT,;
							(cAlias)->D1_QUANT,;
							(cAlias)->DIV_QTD,;
							(cAlias)->NDIAS})
                (cAlias)->(dbSkip() )
          End
 Endif
 (cAlias)->(DbCloseArea())

 oDlg := MSDialog():New(aSize[7],0, nHeight,nWidth,"Consultas SC / PC / NFE",,,.F.,,,,,,.T.,,,.T. )

 oDlg:bInit := {||EnchoiceBar(oDlg,{||oDlg:End()},{|| oDlg:End()},,)}
 oBrowse := TCBrowse():New( aSize[7]+35,5, nHeight,nWidth,,{'Solicitacao', 'Emissao', 'Data Prevista' , 'Solicitante', 'Quantidade','Pedido Compras','Emissao','Data Prevista','Quantidade','Local','Nota','Serie','Emissao','Entrada','Quantidade','Diveg.Qtd','Dias Atraso'},;
	{030,050,050,150,050,030,050,050,050,020,20,20,50,050,20,50,50,020},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.T.,,, )

 
 oBrowse:SetArray(aBrowse)

 oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;   							// Solicitacao
                      Dtoc(aBrowse[oBrowse:nAt,02]),;							// Emissao
                      Dtoc(aBrowse[oBrowse:nAt,03]),;							// Data Prevista
					  aBrowse[oBrowse:nAt,04],;									// Solicitante
					  Transform(aBrowse[oBrowse:nAt,05],"@E 999999,99999"),;	// Quantidade
					  aBrowse[oBrowse:nAt,06],;									// Pedido de compras
					  Dtoc(aBrowse[oBrowse:nAt,07]),;							// Emissao
					  Dtoc(aBrowse[oBrowse:nAt,08]),;							// data prevista
					  Transform(aBrowse[oBrowse:nAt,09],"@E 999999,99999"),;	// Quantidade
					  aBrowse[oBrowse:nAt,10],; 								// Local
					  aBrowse[oBrowse:nAt,11],; 								// Nota
					  aBrowse[oBrowse:nAt,12],; 								// Serie
					  Dtoc(aBrowse[oBrowse:nAt,13]),; 							// Emissao
					  Dtoc(aBrowse[oBrowse:nAt,14]),; 							// Entrada
					  Transform(aBrowse[oBrowse:nAt,15],"@E 999999,99999"),; 	// Quantidade
					  Transform(aBrowse[oBrowse:nAt,16],"@E 99999"),; 			// Diverg Qtde
					  Transform(aBrowse[oBrowse:nAt,17],"@E 999")} } 			// Dias

 oDlg:Activate(,,,.T.)

 FwRestArea(cArea)

RETURN



Static Function AcessaPV(cPedido)
	Local aArea := GetArea() //Irei gravar a area atual
	Private Inclui    := .F. //defino que a inclusão é falsa
	Private Altera    := .T. //defino que a alteração é verdadeira
	Private nOpca     := 1   //obrigatoriamente passo a variavel nOpca com o conteudo 1
	Private cCadastro := "Pedido de Vendas" //obrigatoriamente preciso definir com private a variável cCadastro
	Private aRotina := {} //obrigatoriamente preciso definir a variavel aRotina como private
 
	DbSelectArea("SC5") //Abro a tabela SC5
	SC5->(dbSetOrder(1)) //Ordeno no índice 1
	SC5->(dbSeek(xFilial("SC5")+cPedido)) //Localizo o meu pedido
	If SC5->(!EOF()) //Se o pedido existe irei continuar
		SC5->(DbGoTo(Recno())) //Me posiciono no pedido
		MatA410(Nil, Nil, Nil, Nil, "A410Visual") //executo a função padrão MatA410
	Endif
	SC5->(DbCloseArea()) //quando eu sair da tela de visualizar pedido, fecho o meu alias
	RestArea(aArea) //restauro a area anterior.
Return
