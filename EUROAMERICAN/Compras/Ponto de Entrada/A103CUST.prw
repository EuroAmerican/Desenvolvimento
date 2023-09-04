#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TRYEXCEPTION.CH"

#define ENTER chr(13) + chr(10)

/*/{Protheus.doc} A103CUST - Este Ponto de entrada é executado durante a inclusão do Documento de Entrada, após a inclusão do item na tabela SD1. 
// O registro no SD1 já se encontra travado (Lock). 
// Será executado uma vez para cada item do Documento de Entrada que está sendo incluída.
@author Fabio Carneiro dos Santos 
@since 18/09/2021
@version 1.0
@Param  QE_TESENT - Parametro que contem as TES, que sera considerado para o calculo 
do custo para remessa de conta e ordem  
/*/

User Function A103CUST() 

Local aArea     := GetArea()
Local _aRet     := PARAMIXB[1]
Local _cTes     := GETMV("QE_TESENT",,"") 
Local _nTxPis   := GETMV("MV_TXPIS",,1.65) 
Local _nTxCof   := GETMV("MV_TXCOF",,7.60) 
Local _nbasCalc := 0
Local _nCalcPis := 0
Local _nCalcCof := 0
Local _nCusto   := 0

If SD1->D1_TES $ _cTes

    _nbasCalc := SD1->D1_TOTAL-SD1->D1_VALICM // Base de calculo valor total - icms  
    _nCalcPis := (_nbasCalc * _nTxPis/100)    // calculo do valor do Pis 
    _nCalcCof := (_nbasCalc * _nTxCof/100)    // Calculo do valor do cofins 
    _nCusto   := (_nbasCalc - _nCalcPis - _nCalcCof) // Valor do custo considerando icms - pis - cofins 
    _aRet     := _nCusto

EndIf 

RestArea( aArea )

Return _aRet
