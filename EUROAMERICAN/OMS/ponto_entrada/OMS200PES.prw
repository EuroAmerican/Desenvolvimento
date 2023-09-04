#include "parmtype.ch"
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"
#include "Colors.ch"
#include "RwMake.ch"
#Include "Fwmvcdef.ch"

#define ENTER chr(13) + chr(10)
#define CRLF  chr(13) + chr(10)

/*/{Protheus.doc} OM200PES
@Type    Ponto de Entrada para Tratamento do peso na montagem da carga   
@author  Fabio Carneiro dos Santos 
@since   09/06/2021
@version 1.0
@return Logical, permite ou nao a mudança de linha
/*/
User Function OM200PES()

Local _aAreaSB1  := SB1->(GetArea())
Local _aAreaDAK  := DAK->(GetArea())
Local _aAreaDAI  := DAI->(GetArea())
Local _cProd     := PARAMIXB[1]
Local _nPeso     := 0
Local _cQuery    := ""

If Select("TRBR") > 0
	TRBR->(DbCloseArea())
EndIf

_cQuery := "SELECT B1_PESBRU AS PESOBRUTO "+CRLF 
_cQuery += " FROM "+RetSqlName("SB1")+" AS SB1 "+CRLF
_cQuery += "WHERE B1_FILIAL = '"+xFilial("SB1")+"'   "+CRLF
_cQuery += " AND B1_COD = '"+AllTrim(_cProd)+"' "+CRLF
_cQuery += " AND SB1.D_E_L_E_T_ = ' '  "+CRLF

TcQuery _cQuery ALIAS "TRBR" NEW

TRBR->(DbGoTop())
			
While TRBR->(!Eof())

	_nPeso   := TRBR->PESOBRUTO 
	
	TRBR->(DbSkip())

EndDo

TRBR->(DbCloseArea())
RestArea(_aAreaSB1)
RestArea(_aAreaDAK)
RestArea(_aAreaDAI)

Return _nPeso
