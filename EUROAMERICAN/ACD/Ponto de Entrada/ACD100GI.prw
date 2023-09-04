
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#include "tryexception.ch"
#include "totvs.ch"

#define ENTER chr(13) + chr(10)
/*/{Protheus.doc} ACD100GI ponto de entrada para gravar unidade de expedição
//ponto de entrada para gravar unidade de expedição
@Autor Fabio Carneiro 
@since 13/02/2022
@version 1.0
@type user function 
/*/
User Function ACD100GI() 

Local _aAreaSB1     := SB1->( GetArea() )
Local _aArea        := GetArea()
Local _nQtdVenda    := 0
Local _nVal         := 0
Local _nRetMod      := 0
Local _nQtdVol      := 0 
Local _nDifVol      := 0
Local _cUnExpedicao := Posicione("SB1",1,xFilial("SB1")+CB8->CB8_PROD,"B1_XUNEXP")
Local _nQtdMinima   := Posicione("SB1",1,xFilial("SB1")+CB8->CB8_PROD,"B1_XQTDEXP") 
Local _nPesoBruto   := Posicione("SB1",1,xFilial("SB1")+CB8->CB8_PROD,"B1_PESBRU") 
Local _nPesoLiquido := Posicione("SB1",1,xFilial("SB1")+CB8->CB8_PROD,"B1_PESO") 

// Calculo referente a geração e quebras pro endereços 

_nRetMod            := MOD(CB8->CB8_QTDORI,_nQtdMinima)
_nQtdVenda          := (CB8->CB8_QTDORI -_nRetMod)
_nVal               := (_nQtdVenda / _nQtdMinima)
_nQtdVol            := _nVal * _nQtdMinima 
_nDifVol            := CB8->CB8_QTDORI-_nQtdVol

// Grava informações em campos customizados 

CB8->CB8_XUN    := Posicione("SB1",1,xFilial("SB1")+CB8->CB8_PROD,"B1_UM")      // Primeira Unidade de medida - B1_UM
CB8->CB8_XUNEXP := _cUnExpedicao   // Unidade de medida Expedição - B1_XUNEXP 
CB8->CB8_XCLEXP := _nVal           // Especie da unidade de expedição exemplo FD(FARDO) / CX(CAIXA)
CB8->CB8_XMNEMB := _nQtdMinima     // Quantidade minima de embalagem 
CB8->CB8_XQTVOL := _nQtdVol        // Calculo do volume 
CB8->CB8_XDFVOL := _nDifVol        // Diferença de volume para tratamento dos Multiplos 
CB8->CB8_XPESBU := (CB8->CB8_QTDORI * _nPesoBruto)  // Peso Bruto que foi calculado na liberação do pedido
CB8->CB8_XPESLQ := (CB8->CB8_QTDORI * _nPesoLiquido)  // Peso liquido que foi calculado na liberação do pedido
CB8->CB8_XPBRU  := _nPesoBruto    // Peso Bruto do cadstro de produto
CB8->CB8_XPLIQ  := _nPesoLiquido  // Peso liquido do cadastro de produto

RestArea(_aAreaSB1) 
RestArea(_aArea)

Return
