#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} SD1100I - Este Ponto de entrada é executado durante a inclusão do Documento de Entrada, após a inclusão do item na tabela SD1. 
// O registro no SD1 já se encontra travado (Lock). 
// Será executado uma vez para cada item do Documento de Entrada que está sendo incluída.
@author Fabio Carneiro dos Santos 
@since 18/09/2021
@version 1.0
@Param  QE_TESENT - Parametro que contem as TES, que sera considerado para o calculo 
do custo para remessa de conta e ordem  
/*/
User Function MTA190D1()

Local _aSD1     := SD1->(GetArea())
Local _aSF1     := SF1->(GetArea())
Local _aSA2     := SA2->(GetArea())
Local _aSA1     := SA1->(GetArea())
Local _aCus     := ParamIXB[1]
Local _aItm     := {}
Local _aRet     := {}
Local _cDoc     := SF1->F1_DOC
Local _cSer     := SF1->F1_SERIE
Local _cFor     := SF1->F1_FORNECE
Local _cLoja    := SF1->F1_LOJA
Local _cTes     := SUPERGETMV("QE_TESENT",,"") 
Local _nTxPis   := SUPERGETMV("MV_TXPIS",,1.65) 
Local _nTxCof   := SUPERGETMV("MV_TXCOF",,7.60) 
Local _nbasCalc := 0
Local _nCalcPis := 0
Local _nCalcCof := 0
Local _nCusto   := 0

_aRet := aClone(_aCus)

SD1->(dbSetOrder(1))
SD1->(dbGoTop())
If dbSeek(xFilial("SD1") + _cDoc + _cSer + _cFor + _cLoja)
_aRet    := {}

    While !SD1->(Eof()) .and. (SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA == xFilial("SD1") + _cDoc + _cSer + _cFor + _cLoja) 

        If SD1->D1_TES $ _cTes

            If Posicione("SA2",1,xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA,"A2_DEDBSPC") == "5" // 1=Legado;2=ICMS e IPI;3=ICMS;4=IPI;5=Nenhum;6=Soma IPI
			
				_nbasCalc := SD1->D1_TOTAL // Base de calculo valor total - icms  
				_nCalcPis := (_nbasCalc * _nTxPis/100)    // calculo do valor do Pis 
				_nCalcCof := (_nbasCalc * _nTxCof/100)    // Calculo do valor do cofins 
				_nCusto   := (_nbasCalc - _nCalcPis - _nCalcCof - SD1->D1_VALICM) // Valor do custo considerando icms - pis - cofins 
				_aItm     := {0, 0, 0, 0, 0}
				_aItm[1]  := _nCusto
				_aItm[2]  := 0
				_aItm[3]  := 0
				_aItm[4]  := 0
				_aItm[5]  := 0
				aAdd(_aRet, aClone(_aItm))
			
			Elseif Posicione("SA2",1,xFilial("SA2")+SD1->D1_FORNECE + SD1->D1_LOJA,"A2_DEDBSPC") == "1" // 1=Legado;2=ICMS e IPI;3=ICMS;4=IPI;5=Nenhum;6=Soma IPI 	

				_nbasCalc := SD1->D1_TOTAL-SD1->D1_VALICM // Base de calculo valor total - icms  
				_nCalcPis := (_nbasCalc * _nTxPis/100)    // calculo do valor do Pis 
				_nCalcCof := (_nbasCalc * _nTxCof/100)    // Calculo do valor do cofins 
				_nCusto   := (_nbasCalc - _nCalcPis - _nCalcCof) // Valor do custo considerando icms - pis - cofins 
				_aItm     := {0, 0, 0, 0, 0}
				_aItm[1]  := _nCusto
				_aItm[2]  := 0
				_aItm[3]  := 0
				_aItm[4]  := 0
				_aItm[5]  := 0
				aAdd(_aRet, aClone(_aItm))

			EndIf

        EndIf 

		SD1->(dbSkip())

	Enddo

Endif

SD1->(RestArea(_aSD1))
SF1->(RestArea(_aSF1))
SA2->(RestArea(_aSA2))
SA1->(RestArea(_aSA1))

Return _aRet
