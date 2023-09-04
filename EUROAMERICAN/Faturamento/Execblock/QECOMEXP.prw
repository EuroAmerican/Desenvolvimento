#include "protheus.ch"
#include "parmtype.ch"
#include "ap5mail.ch"
#include "totvs.ch"
#include 'topconn.ch'
#include 'tbiconn.ch'

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

/*/{Protheus.doc} QECOMEXP
Rotina que grava dados de unidade expedição e gera conferencia dos pack de separação. 
@type User function 
@version  1.00
@author Fabio Carneiro e Mario Angelo
@since 21/04/2022
@return  character, NOTA FISCAL, SERIE,Fornece,LOJA,TIPO 
/*/

User Function QECOMEXP(_cDoc,_cSerie,_cFornece,_cLoja,_cTipoNf)

Local cQueryI        := "" 
Local cQueryF        := ""
Local cQueryB        := ""
Local _nPesoB   	 := 0
Local _nPesoL   	 := 0
Local _nQtdVenda     := 0
Local _nVal          := 0
Local _nRetMod       := 0
Local _nQtdVol       := 0 
Local _nDifVol       := 0
Local _nPesoBruto    := 0
Local _nPesoLiquido  := 0
Local _nQtdMinima    := 0
Local _cUnExpedicao  := ""
Local _nVol          := 0
Local _nPasVol       := 1
Local _lAtVol        := .T.
Local _nValFd        := 0
Local _nPos0         := 0
Local _nCheck        := 0 
Local _aCheck        := {} 
Local _cUnExp        := "" 
Local _cFormul       := ""
Local _cTipo         := ""
Local _cNome         := ""
Local _cEst          := ""
Local _cPedido       := ""
Local _dNfEmis       := ""
Private _aVolumes    := Array(14, 2)

For _nVol := 1 to Len(_aVolumes)
	_aVolumes[_nVol, 1] := ""
	_aVolumes[_nVol, 2] := 0
Next _nVol

If Select("TRBF") > 0
	TRBF->(DbCloseArea())
EndIf

cQueryF := "SELECT D1_FILIAL, D1_COD, D1_QUANT, D1_DOC, D1_SERIE, D1_FORMUL, D1_TIPO, D1_FORNECE, D1_LOJA, "+CRLF
cQueryF += "B1_XUNEXP, B1_XQTDEXP, D1_ITEM, D1_TIPO  "+CRLF  
cQueryF += "FROM "+RetSqlName("SD1")+" AS SD1 WITH (NOLOCK) "+CRLF
cQueryF += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) ON B1_COD = D1_COD "+CRLF
cQueryF += " AND SB1.D_E_L_E_T_ = ' ' "+CRLF
cQueryF += "WHERE D1_FILIAL = '"+xFilial("SD1")+"' "+CRLF
cQueryF += " AND D1_DOC     = '"+_cDoc+"' "+CRLF
cQueryF += " AND D1_SERIE   = '"+_cSerie+"' "+CRLF
cQueryF += " AND D1_FORNECE = '"+_cFornece+"' "+CRLF
cQueryF += " AND D1_LOJA    = '"+_cLoja+"' "+CRLF
cQueryF += " AND D1_TIPO    = '"+_cTipoNf+"' "+CRLF
cQueryF += " AND SD1.D_E_L_E_T_ = ' ' "+CRLF 
cQueryF += "GROUP BY D1_FILIAL, D1_COD, D1_QUANT, D1_DOC, D1_SERIE, D1_FORMUL, D1_TIPO, D1_FORNECE, D1_LOJA, "+CRLF
cQueryF += "B1_XUNEXP, B1_XQTDEXP, D1_ITEM, D1_TIPO "+CRLF  
cQueryF += "ORDER BY B1_XUNEXP,B1_XQTDEXP,D1_DOC, D1_COD  "+CRLF

TcQuery cQueryF ALIAS "TRBF" NEW

TRBF->(DbGoTop())

While TRBF->(!Eof())

    If TRBF->D1_TIPO $ "N/D/B"

        _cUnExpedicao  := Posicione("SB1",1,xFilial("SB1")+TRBF->D1_COD,"B1_XUNEXP")
        _nQtdMinima    := Posicione("SB1",1,xFilial("SB1")+TRBF->D1_COD,"B1_XQTDEXP") 
        _nPesoBruto    := Posicione("SB1",1,xFilial("SB1")+TRBF->D1_COD,"B1_PESBRU") 
        _nPesoLiquido  := Posicione("SB1",1,xFilial("SB1")+TRBF->D1_COD,"B1_PESO") 
        _nRetMod       := MOD(TRBF->D1_QUANT,_nQtdMinima)
        _nQtdVenda     := (TRBF->D1_QUANT -_nRetMod)
        _nVal          := (_nQtdVenda / _nQtdMinima)
        _nQtdVol       := _nVal * _nQtdMinima 
        _nDifVol       := TRBF->D1_QUANT-_nQtdVol

        DbSelectArea("SD1")
        SD1->(DbSetOrder(1)) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM 
        If SD1->(dbSeek(xFilial("SD1") + TRBF->D1_DOC + TRBF->D1_SERIE + TRBF->D1_FORNECE + TRBF->D1_LOJA + TRBF->D1_COD + TRBF->D1_ITEM))

            RecLock("SD1",.F.)

            SD1->D1_XUNEXP  := _cUnExpedicao
            SD1->D1_XCLEXP  := _nVal
            SD1->D1_XMINEMB := _nQtdMinima
            SD1->D1_XQTDVOL := _nQtdVol
            SD1->D1_XDIFVOL := _nDifVol  
            SD1->D1_XPESBUT := (TRBF->D1_QUANT * _nPesoBruto)
            SD1->D1_XPESLIQ := (TRBF->D1_QUANT * _nPesoLiquido)
            SD1->D1_XPBRU   := _nPesoBruto
            SD1->D1_XPLIQ   := _nPesoLiquido
 
            SD1->(MsUnlock())

        EndIf

    EndIf

    TRBF->(dbSkip())

    _cUnExpedicao  := ""
    _nQtdMinima    := 0
    _nPesoBruto    := 0
    _nPesoLiquido  := 0
    _nRetMod       := 0
    _nQtdVenda     := 0
    _nVal          := 0
    _nQtdVol       := 0
    _nDifVol       := 0

EndDo

If Select("TRBI") > 0
	TRBI->(DbCloseArea())
EndIf

cQueryI := "SELECT D1_FILIAL, D1_COD, SUM(D1_QUANT) AS D1_QUANT,D1_DOC,D1_SERIE,D1_FORMUL,D1_TIPO,D1_FORNECE, D1_LOJA, "+CRLF
cQueryI += "B1_XUNEXP, B1_XQTDEXP,B1_UM, A2_NOME, A2_EST, D1_PEDIDO, D1_DTDIGIT, B1_PESO, B1_PESBRU "+CRLF
cQueryI += "FROM "+RetSqlName("SD1")+" AS SD1 WITH (NOLOCK) "+CRLF
cQueryI += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) ON B1_COD = D1_COD "+CRLF
cQueryI += " AND SB1.D_E_L_E_T_ = ' ' "+CRLF
cQueryI += "INNER JOIN "+RetSqlName("SA2")+" AS SA2 WITH (NOLOCK) ON A2_COD  = D1_FORNECE   "+CRLF
cQueryI += " AND A2_LOJA = D1_LOJA "+CRLF 
cQueryI += " AND SA2.D_E_L_E_T_ = ' ' "+CRLF
cQueryI += "WHERE D1_FILIAL = '"+xFilial("SD1")+"' "+CRLF
cQueryI += " AND D1_DOC     = '"+_cDoc+"' "+CRLF
cQueryI += " AND D1_SERIE   = '"+_cSerie+"' "+CRLF
cQueryI += " AND D1_FORNECE = '"+_cFornece+"' "+CRLF
cQueryI += " AND D1_LOJA    = '"+_cLoja+"' "+CRLF
cQueryI += " AND D1_TIPO    = '"+_cTipoNf+"' "+CRLF
cQueryI += " AND SD1.D_E_L_E_T_ = ' ' "+CRLF 
cQueryI += "GROUP BY D1_FILIAL, D1_COD,D1_DOC,D1_SERIE,D1_FORMUL,D1_TIPO,D1_FORNECE, D1_LOJA, "+CRLF
cQueryI += "B1_XUNEXP, B1_XQTDEXP,B1_UM, A2_NOME, A2_EST, D1_PEDIDO, D1_DTDIGIT, B1_PESO, B1_PESBRU "+CRLF  
cQueryI += "ORDER BY B1_XUNEXP,B1_XQTDEXP,D1_DOC, D1_COD  "+CRLF

TcQuery cQueryI ALIAS "TRBI" NEW

TRBI->(DbGoTop())

_cUnExpedicao  := ""
_nQtdMinima    := 0
_nPesoBruto    := 0
_nPesoLiquido  := 0
_nRetMod       := 0
_nQtdVenda     := 0
_nVal          := 0
_nQtdVol       := 0
_nDifVol       := 0
_nVol          := 0
_nPasVol       := 1

While TRBI->(!Eof())
   
    If TRBI->D1_TIPO $ "N/D/B"

        _aCheck   := {}
        _cCampo   := ""
        _cFilial  := TRBI->D1_FILIAL
        _cDoc     := TRBI->D1_DOC
        _cSerie   := TRBI->D1_SERIE
        _cFornece := TRBI->D1_FORNECE
        _cLoja    := TRBI->D1_LOJA
        _cFormul  := TRBI->D1_FORMUL
        _cTipo    := TRBI->D1_TIPO
        _cNome    := TRBI->A2_NOME
        _cEst     := TRBI->A2_EST
        _cPedido  := TRBI->D1_PEDIDO
        _dNfEmis  := Substr(TRBI->D1_DTDIGIT,7,2)+"/"+Substr(TRBI->D1_DTDIGIT,5,2)+"/"+Substr(TRBI->D1_DTDIGIT,1,4)

        _cCampo := "TRBI->B1_UM"

        _nPos0  := Ascan(_aVolumes, {|x| &_cCampo $ x[1]})
        
        If TRBI->B1_XUNEXP == 'KG'
            _nVal := (TRBI->D1_QUANT * TRBI->B1_XQTDEXP)
        Else
            _nVal := TRBI->D1_QUANT
        EndIf
        
        If !Empty(TRBI->B1_XUNEXP) 

            _nPos1 := Ascan(_aVolumes, {|x| TRBI->B1_XUNEXP $ x[1]})
                
            If Select("TRB1") > 0
                TRB1->(DbCloseArea())
            EndIf

            cQueryB := "SELECT B1_XQTDEXP,B1_XUNEXP,B1_UM  "+CRLF
            cQueryB += "FROM "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) "+CRLF
            cQueryB += "WHERE SB1.B1_COD = '"+TRBI->D1_COD+"' "+CRLF 
            cQueryB += " AND SB1.D_E_L_E_T_ = ' '  "+CRLF
            cQueryB += "GROUP BY B1_XQTDEXP,B1_XUNEXP,B1_UM  "+CRLF
            cQueryB += "ORDER BY B1_XQTDEXP  "+CRLF

            TcQuery cQueryB ALIAS "TRB1" NEW

            TRB1->(DbGoTop())

            While TRB1->(!Eof())

                Aadd(_aCheck,{TRB1->B1_XQTDEXP,TRB1->B1_XUNEXP,TRB1->B1_UM})  
                        
                TRB1->(dbSkip())

            EndDo

            For _nCheck := 1 to Len(_aCheck)
                    
                If TRBI->B1_XQTDEXP == _aCheck[_nCheck][1]  .And. _aCheck[_nCheck][3] == TRBI->B1_UM
                        
                _nValFd  := ((_nVal - (_nVal % _aCheck[_nCheck][1])))/_aCheck[_nCheck][1]
                _nVal    := _nVal % _aCheck[_nCheck][1]
                _cUnExp  := _aCheck[_nCheck][2]
                        
                EndIf
                    
            Next _nCheck

            If _nValFd > 0
                If _nPos1 == 0
                    _aVolumes[_nPasVol, 1]     := _cUnExp
                    _aVolumes[_nPasVol, 2]     := _nValFd
                    _nPasVol++
                Else
                    _aVolumes[_nPos1, 2] += _nValFd
                EndIf
                If _nVal > 0
                    If _nPos0 == 0
                        _aVolumes[_nPasVol, 1]     := &(_cCampo)
                        _aVolumes[_nPasVol, 2]     := _nVal
                        _nPasVol++
                    Else
                        _aVolumes[_nPos0, 2] += _nVal
                    EndIf
                EndIf
            
            Else 

                If _nVal > 0
                    If _nPos0 == 0
                        _aVolumes[_nPasVol, 1] := &(_cCampo)
                        _aVolumes[_nPasVol, 2] := _nVal
                        _nPasVol++
                    Else
                        _aVolumes[_nPos0, 2] += _nVal
                    EndIf
                EndIf

            EndIf

        EndIf

        _nPesoL+=TRBI->D1_QUANT * TRBI->B1_PESO
        _nPesoB+=TRBI->D1_QUANT * TRBI->B1_PESBRU
        
    EndIf

    TRBI->(dbSkip())

    If TRBI->(EOF()) .Or. TRBI->D1_DOC <> _cDoc 

        If _lAtVol

            SF1->(dbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
            If SF1->(dbSeek(xFilial("SF1") + _cDoc +  _cSerie + _cFornece + _cLoja + _cTipo))
               
                Reclock("SF1",.F.)
                SF1->F1_ESPECI1 := AllTrim(_aVolumes[1][1])
                SF1->F1_VOLUME1 := _aVolumes[1][2]
                SF1->F1_ESPECI2 := AllTrim(_aVolumes[2][1])
                SF1->F1_VOLUME2 := _aVolumes[2][2]
                SF1->F1_ESPECI3 := AllTrim(_aVolumes[3][1])
                SF1->F1_VOLUME3 := _aVolumes[3][2]
                SF1->F1_ESPECI4 := AllTrim(_aVolumes[4][1])
                SF1->F1_VOLUME4 := _aVolumes[4][2]
                SF1->F1_ESPECI5 := AllTrim(_aVolumes[5][1])
                SF1->F1_VOLUME5 := _aVolumes[5][2]
                SF1->F1_ESPECI6 := AllTrim(_aVolumes[6][1])
                SF1->F1_VOLUME6 := _aVolumes[6][2]
                SF1->F1_ESPECI7 := AllTrim(_aVolumes[7][1])
                SF1->F1_VOLUME7 := _aVolumes[7][2]
                SF1->F1_PBRUTO  := _nPesoB
                SF1->F1_PLIQUI  := _nPesoL

                SF1->( Msunlock() )

                _aCheck   := {}
                _nPasVol  := 1
                _nVol     := 0
                _nVal     := 0
                _nValFd   := 0
                _nPos0    := 0
                _nPos1    := 0
                _nPesoB   := 0
                _nPesoL   := 0 

                _cFilial  := ""
                _cDoc     := ""
                _cSerie   := ""
                _cFornece := ""
                _cLoja    := ""
                _cFormul  := ""
                _cTipo    := ""
                _cNome    := ""
                _cEst     := ""
                _cPedido  := ""
                _dNfEmis  := ""
                For _nVol := 1 to Len(_aVolumes)
                    _aVolumes[_nVol, 1] := ""
                    _aVolumes[_nVol, 2] := 0
                Next _nVol
            
            EndIf

        EndIf

    EndIf

EndDo

If Select("TRB1") > 0
    TRB1->(DbCloseArea())
EndIf
If Select("TRBI") > 0
    TRBI->(DbCloseArea())
EndIf
If Select("TRBF") > 0
	TRBF->(DbCloseArea())
EndIf
If Select("SF1") > 0
    SF1->(DbCloseArea())
EndIf
If Select("SD1") > 0
    SD1->(DbCloseArea())
EndIf

Return
