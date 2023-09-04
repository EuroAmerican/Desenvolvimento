#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA60FIL   ºAutor  ³                    º Data ³  30/01/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³FILTRO NA GERACAO DE BORDEROS A RECEBER                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                     A L T E R A C O E S                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ºProgramador       ºAlteracoes                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  
User Function FA60FIL()

Local cFiltro   := ".T."
Local aArea     := GetArea()           
Local cSit      := AllTrim(ParamIXB[4])   

//Monta Filtro     
//If cEmpAnt + cFilAnt == "0107" //Tratamento Jays  
	//cFiltro := "Posicione('SC5', 1, SE1->E1_FILIAL + SE1->E1_PEDIDO, 'C5_TIPOPAG') == '1' .And. SE1->E1_FILIAL = xFilial('SE1') "
//Else //Tratamento default

	cFiltro := "!(SE1->E1_PREFIXO $ 'CH ') .And. SE1->E1_FILIAL = xFilial('SE1') .And. !(SE1->E1_TIPO $ 'CH ')"
	//cFiltro += " .And. !(Posicione('SA1', 1, SE1->E1_FILIAL + SE1->E1_CLIENTE + SE1->E1_LOJA, 'A1_BOLZZZ') = 'N' .And. SE1->E1_PREFIXO $ 'REQ#ZZZ') "
	cFiltro += " .And. Posicione('SC5', 1, SE1->E1_FILIAL + SE1->E1_PEDIDO, 'C5_TIPOPAG') != '5' "
	//cFiltro += " .And. ( Empty(SE1->E1_BAIXA) .OR. (!Empty(SE1->E1_BAIXA) .And. SE1->E1_DESCONT > 0 ) ) " //Filtrar títulos com baixa parcial (compensação) //Retirado filtro 08/05/18
	If cFilAnt == "0107" //Tratamento Jays 
		cFiltro += " .And. ( Posicione('SC5', 1, SE1->E1_FILIAL + SE1->E1_PEDIDO, 'C5_TIPOPAG') == '1' .Or. ( SE1->E1_CLIENTE $ '000666' .And. ALLTRIM(SE1->E1_TIPO) $ 'NF' ) ) .And. SE1->E1_FILIAL = xFilial('SE1') "
	EndIf
//EndIf 

cFiltro += " .And. SE1->E1_NATUREZ != '0101003' .And. SE1->E1_NATUREZ != '0101004' .And.  SE1->E1_NATUREZ != '006' "
cFiltro += " .And. SE1->E1_NATUREZ != '007' .And.  SE1->E1_NATUREZ != '0101006' "
cFiltro += " .And. ((cPort060 == Posicione('SA1',1,xFilial('SA1')+SE1->E1_CLIENTE + SE1->E1_LOJA,'A1_BCO1')) .Or. "
cFiltro += " (cPort060 == Posicione('SA1',1,SE1->E1_FILIAL+SE1->E1_CLIENTE + SE1->E1_LOJA,'A1_BCO2')) .Or. "
cFiltro += " (cPort060 == Posicione('SA1',1,SE1->E1_FILIAL+SE1->E1_CLIENTE + SE1->E1_LOJA,'A1_BCO3')) .Or. "
cFiltro += " (cPort060 == Posicione('SA1',1,SE1->E1_FILIAL+SE1->E1_CLIENTE + SE1->E1_LOJA,'A1_BCO4')) .Or. "
cFiltro += " (cPort060 == Posicione('SA1',1,SE1->E1_FILIAL+SE1->E1_CLIENTE + SE1->E1_LOJA,'A1_BCO5')) .Or. "
cFiltro += " (cPort060 == Posicione('SA1',1,SE1->E1_FILIAL+SE1->E1_CLIENTE + SE1->E1_LOJA,'A1_BCO6')) .Or. "
cFiltro += " (cPort060 == Posicione('SA1',1,SE1->E1_FILIAL+SE1->E1_CLIENTE + SE1->E1_LOJA,'A1_BCO7')) .Or. "
cFiltro += " (cPort060 == Posicione('SA1',1,SE1->E1_FILIAL+SE1->E1_CLIENTE + SE1->E1_LOJA,'A1_BCO8')) .Or. "
cFiltro += " (cPort060 == Posicione('SA1',1,SE1->E1_FILIAL+SE1->E1_CLIENTE + SE1->E1_LOJA,'A1_BCO9'))) "       


// Grupo Empresa - Ajuste realizado (CG)

// If cEmpAnt == "03"
	
// 	cQry := " SELECT 	A1_COD CODIGO "
// 	cQry += " FROM		SA1030 "
// 	cQry += " WHERE		D_E_L_E_T_ = '' "
// 	cQry += "           AND A1_FILIAL = '" + xFilial("SA1") + "' "
// 	cQry += " 			AND A1_NREDUZ LIKE '%DICICO%' "                                 


//If Left(cFilAnt,2) == "03"
If cFilAnt == "####0803"
	
	cQry := " SELECT SA1.A1_COD AS CODIGO" + CRLF
	cQry += " FROM " + RetSqlName("SA1") + " AS SA1 WITH (NOLOCK)" + CRLF
	cQry += " WHERE	SA1.D_E_L_E_T_ = ''" + CRLF
	cQry += "   AND SA1.A1_FILIAL = '" + xFilial("SA1") + "'" + CRLF
	cQry += " 	AND SA1.A1_NREDUZ LIKE '%DICICO%'"  + CRLF

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TCQUERY cQry NEW ALIAS "QRY"
	
	cSimples := ""
	
	Do While !QRY->(EOF())
		cSimples += QRY->CODIGO + "#"
		QRY->(dbSkip())		
	EndDo  
	
	QRY->(dbCloseArea())

	If cSit != "1" 
		cFiltro += " .And. !(SE1->E1_CLIENTE $ '" + cSimples + "') "  
	//Else
		//cFiltro += " .And. (SE1->E1_CLIENTE $ '" + cSimples + "') "  
	EndIf    

EndIf

RestArea(aArea)
               	
Return(cFiltro)
