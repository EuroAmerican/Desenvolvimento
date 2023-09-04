#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "XMLXFUN.CH"

#define ENTER chr(13) + chr(10)

/*/{Protheus.doc} SD1100I - Este Ponto de entrada é executado durante a inclusão do Documento de Entrada, após a inclusão do item na tabela SD1. 
// O registro no SD1 já se encontra travado (Lock). 
// Será executado uma vez para cada item do Documento de Entrada que está sendo incluída.
@author Fabio Carneiro dos Santos 
@since 18/09/2021
@version 1.0
@Param  QE_TESENT - Parametro que contem as TES, que sera considerado para o calculo 
do custo para remessa de conta e ordem  
@Return NULO
@History Incluido a tratativa de unidade de expedição 
/*/

User Function SD1100I() 

Local aArea          := GetArea()
Local aAreaSD1 		 := SD1->(GetArea())
Local aAreaSF1 		 := SF1->(GetArea())
Local _cTes          := GETMV("QE_TESENT",,"") 
Local _nTxPis        := GETMV("MV_TXPIS",,1.65) 
Local _nTxCof        := GETMV("MV_TXCOF",,7.60) 
Local _nbasCalc      := 0
Local _nCalcPis      := 0
Local _nCalcCof      := 0
Local _nCusto        := 0
Local _nQtdVenda     := 0
Local _nVal          := 0
Local _nRetMod       := 0
Local _nQtdVol       := 0 
Local _nDifVol       := 0
Local _cUnExpedicao  := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_XUNEXP")
Local _nQtdMinima    := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_XQTDEXP") 
Local _nPesoBruto    := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_PESBRU") 
Local _nPesoLiquido  := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_PESO") 

// Tratamento para calculo de custo 

If SD1->D1_TES $ _cTes

    If Posicione("SA2",1,xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA,"A2_DEDBSPC") == "5" // 1=Legado;2=ICMS e IPI;3=ICMS;4=IPI;5=Nenhum;6=Soma IPI
			
		_nbasCalc := SD1->D1_TOTAL                // Base de calculo valor total - icms  
		_nCalcPis := (_nbasCalc * _nTxPis/100)    // calculo do valor do Pis 
		_nCalcCof := (_nbasCalc * _nTxCof/100)    // Calculo do valor do cofins 
		_nCusto   := (_nbasCalc - _nCalcPis - _nCalcCof - SD1->D1_VALICM) // Valor do custo considerando icms - pis - cofins 
			
	Elseif Posicione("SA2",1,xFilial("SA2")+SD1->D1_FORNECE + SD1->D1_LOJA,"A2_DEDBSPC") == "1" // 1=Legado;2=ICMS e IPI;3=ICMS;4=IPI;5=Nenhum;6=Soma IPI 	

		_nbasCalc := SD1->D1_TOTAL-SD1->D1_VALICM // Base de calculo valor total - icms  
		_nCalcPis := (_nbasCalc * _nTxPis/100)    // calculo do valor do Pis 
		_nCalcCof := (_nbasCalc * _nTxCof/100)    // Calculo do valor do cofins 
		_nCusto   := (_nbasCalc - _nCalcPis - _nCalcCof ) // Valor do custo considerando icms - pis - cofins 
	
	EndIf

	RecLock("SD1", .F.)
	SD1->D1_CUSTO := _nCusto
	SD1->(MsUnLock())

EndIf 

If SD1->D1_TIPO $ "N/D/B" 

	// Calculo referente ao multiplo de embalagens 

	_nRetMod            := MOD(SD1->D1_QUANT,_nQtdMinima)
	_nQtdVenda          := (SD1->D1_QUANT -_nRetMod)
	_nVal               := (_nQtdVenda / _nQtdMinima)
	_nQtdVol            := _nVal * _nQtdMinima 
	_nDifVol            := SD1->D1_QUANT-_nQtdVol

	DbSelectArea("SD1")
	SD1->(DbSetOrder(3))
	If SD1->(dbSeek(xFilial("SD1") + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_COD + SD1->D1_ITEM))

		RecLock("SD1",.F.)

		SD1->D1_XUNEXP  := _cUnExpedicao
		SD1->D1_XCLEXP  := _nVal
		SD1->D1_XMINEMB := _nQtdMinima
		SD1->D1_XQTDVOL := _nQtdVol
		SD1->D1_XDIFVOL := _nDifVol  
		SD1->D1_XPESBUT := (SD1->D2_QUANT * _nPesoBruto)
		SD1->D1_XPESLIQ := (SD1->D2_QUANT * _nPesoLiquido)
		SD1->D1_XPBRU   := _nPesoBruto
		SD1->D1_XPLIQ   := _nPesoLiquido

		SD1->(MsUnlock())

	EndIf

EndIf

RestArea(aAreaSF1)
RestArea(aAreaSD1)
RestArea(aArea)

Return nil
