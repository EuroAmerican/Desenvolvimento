#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#include "totvs.ch"

#define ENTER chr(13) + chr(10)
/*/{Protheus.doc} MTA440C9
LIBERACAO DO PEDIDO DE VENDA
Chamado na gravacao e liberacao do pedido de Venda, apos a atualizacao do acumulados do SA1.
P.E. para todos os itens do pedido referente a campos customizados.
@author		Fabio carneiro
@since 		25/01/2022
/*/
User Function MTA440C9()

Local _aAreaSB1     := SB1->( GetArea() )
Local _aAreaSC9     := SC9->( GetArea() )
Local _aArea        := GetArea()
Local _nQtdVenda    := 0
Local _nVal         := 0
Local _nRetMod      := 0
Local _nQtdVol      := 0 
Local _nDifVol      := 0
Local _cUnExpedicao := Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,"B1_XUNEXP")
Local _nQtdMinima   := Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,"B1_XQTDEXP") 
Local _nPesoBruto   := Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,"B1_PESBRU") 
Local _nPesoLiquido := Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,"B1_PESO") 
Local _cTipoPedido  := Posicione("SC5",1,xFilial("SC5")+SC9->C9_PEDIDO,"C5_TIPO")
Local cQuery        := "" 
Local cQry1         := ""
Local _aLIsta       := {}

// Calculo referente ao multiplo de embalagens 

If  _cTipoPedido $ "N/D/B" .And. !Empty(_cUnExpedicao) .And. _nQtdMinima > 0

    _nRetMod            := MOD(SC9->C9_QTDLIB,_nQtdMinima)
    _nQtdVenda          := (SC9->C9_QTDLIB -_nRetMod)
    _nVal               := (_nQtdVenda / _nQtdMinima)
    _nQtdVol            := _nVal * _nQtdMinima 
    _nDifVol            := SC9->C9_QTDLIB-_nQtdVol

    RecLock("SC9",.F.)
        
    SC9->C9_XUN     := Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,"B1_UM")
    SC9->C9_XUNEXP  := _cUnExpedicao
    SC9->C9_XCLEXP  := _nVal
    SC9->C9_XMINEMB := _nQtdMinima
    SC9->C9_XQTDVOL := _nQtdVol
    SC9->C9_XDIFVOL := _nDifVol  
    SC9->C9_XPESBUT := (SC9->C9_QTDLIB * _nPesoBruto)
    SC9->C9_XPESLIQ := (SC9->C9_QTDLIB * _nPesoLiquido)
    SC9->C9_XPBRU   := _nPesoBruto
    SC9->C9_XPLIQ   := _nPesoLiquido
        
    SC9->( MsUnlock() )

EndIf 

If Select("TRB8") > 0
	TRB8->(DbCloseArea())
EndIf

cQuery := "SELECT C9_NFISCAL AS NFISCAL " + CRLF
cQuery += "FROM "+RetSqlName("SC9")+" AS SC9 WITH (NOLOCK) " + CRLF
cQuery += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' " + CRLF
cQuery += " AND C9_PEDIDO   = '"+SC9->C9_PEDIDO+"' " + CRLF
cQuery += " AND C9_CLIENTE  = '"+SC9->C9_CLIENTE+"' " + CRLF
cQuery += " AND C9_LOJA     = '"+SC9->C9_LOJA+"' " + CRLF
cQuery += " AND C9_NFISCAL <> ' ' " + CRLF
cQuery += " AND C9_BLEST IN (' ','10') " + CRLF 
cQuery += " AND C9_BLCRED IN (' ','10') " + CRLF 
cQuery += " AND SC9.D_E_L_E_T_ = ' ' " + CRLF 

TCQuery cQuery New Alias "TRB8"

TRB8->(DbGoTop())

While TRB8->(!Eof())

    Aadd(_aLIsta,{TRB8->NFISCAL})    

	TRB8->(DbSkip())
    
EndDo

If Len(_aLista) > 0

   cQry1 := ""
   cQry1 := "UPDATE "+RetSqlName("SC9")+" " + CRLF
   cQry1 += " SET C9_XNUMIND = '2' " + CRLF
   cQry1 += "FROM "+RetSqlName("SC9")+" AS SC9 WITH (NOLOCK) " + CRLF
   cQry1 += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' " + CRLF
   cQry1 += " AND C9_PEDIDO  = '"+SC9->C9_PEDIDO+ "' " + CRLF
   cQry1 += " AND C9_CLIENTE = '"+SC9->C9_CLIENTE+"' " + CRLF
   cQry1 += " AND C9_LOJA    = '"+SC9->C9_LOJA+"' " + CRLF
   cQry1 += " AND C9_XNUMIND = ' ' " + CRLF
   cQry1 += " AND C9_NFISCAL = ' ' " + CRLF
   cQry1 += " AND C9_BLEST IN (' ','10') " + CRLF 
   cQry1 += " AND C9_BLCRED IN (' ','10') " + CRLF 
   cQry1 += " AND SC9.D_E_L_E_T_ = ' ' " + CRLF

   TcSQLExec(cQry1)

Else

   cQry1 := ""
   cQry1 := "UPDATE "+RetSqlName("SC9")+" " + CRLF
   cQry1 += " SET C9_XNUMIND = '1' " + CRLF
   cQry1 += "FROM "+RetSqlName("SC9")+" AS SC9 WITH (NOLOCK) " + CRLF
   cQry1 += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' " + CRLF
   cQry1 += " AND C9_PEDIDO  = '"+SC9->C9_PEDIDO+ "' " + CRLF
   cQry1 += " AND C9_CLIENTE = '"+SC9->C9_CLIENTE+"' " + CRLF
   cQry1 += " AND C9_LOJA    = '"+SC9->C9_LOJA+"' " + CRLF
   cQry1 += " AND C9_XNUMIND = ' ' " + CRLF
   cQry1 += " AND C9_NFISCAL = ' ' " + CRLF
   cQry1 += " AND C9_BLEST IN (' ','10') " + CRLF 
   cQry1 += " AND C9_BLCRED IN (' ','10') " + CRLF 
   cQry1 += " AND SC9.D_E_L_E_T_ = ' ' " + CRLF

   TcSQLExec(cQry1)

EndIf

If Select("TRB8") > 0
	TRB8->(DbCloseArea())
EndIf

RestArea(_aAreaSC9) 
RestArea(_aAreaSB1) 
RestArea(_aArea)

Return( Nil )
