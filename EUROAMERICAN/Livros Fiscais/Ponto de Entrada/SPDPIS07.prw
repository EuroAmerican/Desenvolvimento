#include "rwmake.ch"
#include "Topconn.ch"
#include "protheus.ch"
#include "parmtype.ch"
#Include "Tbiconn.ch"
#include "Colors.ch"

/*/{Protheus.doc} SPDPIS07
Ponto de entrada para Gravar conta contabil na tabela SFT
@Autor Fabio Carneiro 
@since 28/11/2022
@version 1.0
@type user function 
/*/

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

User Function SPDPIS07()
 
Local   _aAreaFT    :=  SFT->(GetArea())
Local   _aAreaB1    :=  SB1->(GetArea())
Local   _cTpMov     :=  PARAMIXB[2] //FT_TIPOMOV
Local   _cSerie     :=  PARAMIXB[3] //FT_SERIE
Local   _cDoc       :=  PARAMIXB[4] //FT_NFISCAL
Local   _cClieFor   :=  PARAMIXB[5] //FT_CLIEFOR
Local   _cLoja      :=  PARAMIXB[6] //FT_LOJA
Local   _cItem      :=  PARAMIXB[7] //FT_ITEM
Local   _cProd      :=  PARAMIXB[8] //FT_PRODUTO       
Local   _cConta     :=  PARAMIXB[9] //FT_CONTA

If Empty(_cConta) 

    DbSelectArea("SFT")
    DbSetOrder(1) //FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO 
    If DbSeek(xFilial("SFT")+_cTpMov+_cSerie+_cDoc+_cClieFor+_cLoja+_cItem+_cProd)  
        _cConta := Posicione("SB1",1,xFilial("SB1")+_cProd,"B1_CONTA")
    EndIf

EndIf

RestArea(_aAreaFT)
RestArea(_aAreaB1)

Return _cConta
