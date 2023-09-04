// #########################################################################################
// Projeto:	Retornar valor líquido para utilização nos Lançamentos Padrões
// Modulo : SIGACTB
// Fonte  : CTBVLRLQ
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 15/06/16 | Emerson Paiva     | Criação rotina
// ${date} | TOTVS Developer Studio | Gerado pelo Assistente de Código
// ---------+-------------------+-----------------------------------------------------------

#include "rwmake.ch"

//------------------------------------------------------------------------------------------
user function CTBVLRLQ(cTab)

	Local cTabela := cTab	//Tabela origem do LP SD1, SD2, etc
	Local nVlrLiq := 0
	
	If cTab == "SD1"
		nVlrLiq := SD1->D1_TOTAL
	ElseIf cTab == "SD2"
		nVlrLiq := SD2->D2_TOTAL
	EndIf
		
	IF SF4->F4_PISCOF$"1/3"
		If cTab == "SD1" .And. Left(cFilAnt,2) $ "02/08" //Só empresas Lucro Real tem direito a crédito (Euro e Multicores)
			nVlrLiq	-= SD1->D1_TOTAL*SD1->D1_ALQPIS/100
		ElseIf cTab == "SD2"
			nVlrLiq	-= SD2->D2_TOTAL*SD2->D2_ALQPIS/100
		EndIf		
	EndIf
	
	IF SF4->F4_PISCOF$"2/3"
		If cTab == "SD1" .And. Left(cFilAnt,2) $ "02/08" //Só empresas Lucro Real tem direito a crédito (Euro e Multicores)
			nVlrLiq	-= SD1->D1_TOTAL*SD1->D1_ALQCOF/100
		ElseIf cTab == "SD2"
			nVlrLiq	-= SD2->D2_TOTAL*SD2->D2_ALQCOF/100
		EndIf		
	EndIf
	
	IF ALLTRIM(SF4->F4_ICM)$"S"
		If cTab == "SD1"
			nVlrLiq	-= SD1->D1_VALICM
		ElseIf cTab == "SD2"
			nVlrLiq	-= SD2->D2_VALICM
		EndIf
	EndIf
	
	/*IF ALLTRIM(SF4->F4_IPI)="S"
		If cTab == "SD1"
			nVlrLiq	-= SD1->D1_VALIPI
		ElseIf cTab == "SD2"
			nVlrLiq	-= SD2->D2_VALIPI
		EndIf
	EndIf*/
	
return (nVlrLiq)
//--< fim de arquivo >----------------------------------------------------------------------


