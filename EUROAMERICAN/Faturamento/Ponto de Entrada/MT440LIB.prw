#Include "protheus.ch"
#Include "parmtype.ch"
#Include "ap5mail.ch"
#Include "totvs.ch"
#Include 'topconn.ch'
#Include 'tbiconn.ch'

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

/*/{Protheus.doc} MT440LIB
Ponto de entrada para alterar a quantidade de acordo com os multiplos de embalagem.
@Project    Unidade de Expedição
@type       User Function
@author     Fábio Carneiro dos Santos 
@since      26/04/2022
@version    1.0
@return     nQtdLib, quantidade calculada de acordo com multiplos de ambalagens.
/*/
User Function MT440LIB()

Local _aArea        := GetArea()
Local _nQtdAnt      := 0
Local _cC5XOPER     := SuperGetMv("QE_XOPER",.F.,"01/06/56")
Local _cXOPER       := Posicione("SC5",1,xFilial("SC5")+SC6->C6_NUM,"C5_XOPER")
Local cQueryI       := "" 
Local _nQtdVenda    := 0
Local _nRetMod      := 0
Local _cUnExpedicao := ""
Local _nQtdMinima   := 0
Local _nPesoBruto   := 0
Local _nPesoLiquido := 0
Local _cTipoPedido  := 0

ParamIXB := ParamIXB

_nQtdAnt := ParamIXB

If _cC5XOPER $ _cXOPER

    If Select("TRBI") > 0
        TRBI->(DbCloseArea())
    EndIf

    cQueryI := "SELECT C6_FILIAL, C6_PRODUTO, SUM(C6_QTDVEN) AS C6_QTDVEN,C6_NUM,C5_TIPO,C6_CLI, C6_LOJA, "+CRLF
    cQueryI += "B1_XUNEXP, B1_XQTDEXP,B1_UM, A1_NOME, A1_EST, C5_EMISSAO, B1_PESO, B1_PESBRU "+CRLF
    cQueryI += "FROM "+RetSqlName("SC6")+" AS SC6 WITH (NOLOCK) "+CRLF
    cQueryI += "INNER JOIN "+RetSqlName("SC5")+" AS SC5 WITH (NOLOCK) ON C5_FILIAL = C6_FILIAL "+CRLF
    cQueryI += " AND C5_NUM = C6_NUM      "+CRLF
    cQueryI += " AND C5_CLIENTE = C6_CLI  "+CRLF
    cQueryI += " AND C5_LOJACLI = C6_LOJA "+CRLF
    cQueryI += " AND SC5.D_E_L_E_T_ = ' ' "+CRLF
    cQueryI += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) ON B1_COD = C6_PRODUTO "+CRLF
    cQueryI += " AND SB1.D_E_L_E_T_ = ' ' "+CRLF
    cQueryI += "INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH (NOLOCK) ON A1_FILIAL = C6_FILIAL "+CRLF
    cQueryI += " AND A1_COD  = C6_CLI "+CRLF
    cQueryI += " AND A1_LOJA = C6_LOJA "+CRLF 
    cQueryI += " AND SA1.D_E_L_E_T_ = ' ' "+CRLF
    cQueryI += "WHERE C6_FILIAL = '"+xFilial("SC6")+"' "+CRLF
    cQueryI += " AND C6_NUM     = '"+SC6->C6_NUM+"' "+CRLF
    cQueryI += " AND C6_CLI     = '"+SC6->C6_CLI+"' "+CRLF
    cQueryI += " AND C6_LOJA    = '"+SC6->C6_LOJA+"' "+CRLF
    cQueryI += " AND C6_PRODUTO = '"+SC6->C6_PRODUTO+"' "+CRLF
    cQueryI += " AND C6_LOCAL   = '"+SC6->C6_LOCAL+"' "+CRLF
    cQueryI += " AND SC6.D_E_L_E_T_ = ' ' "+CRLF 
    cQueryI += "GROUP BY C6_FILIAL, C6_PRODUTO, C6_NUM,C5_TIPO,C6_CLI, C6_LOJA, "+CRLF
    cQueryI += "B1_XUNEXP, B1_XQTDEXP,B1_UM, A1_NOME, A1_EST, C5_EMISSAO, B1_PESO, B1_PESBRU "+CRLF  
    cQueryI += "ORDER BY B1_XUNEXP,B1_XQTDEXP,C6_NUM, C6_PRODUTO  "+CRLF

    TcQuery cQueryI ALIAS "TRBI" NEW

    TRBI->(DbGoTop())

    While TRBI->(!Eof())

        _cUnExpedicao := Posicione("SB1",1,xFilial("SB1")+TRBI->C6_PRODUTO,"B1_XUNEXP")
        _nQtdMinima   := Posicione("SB1",1,xFilial("SB1")+TRBI->C6_PRODUTO,"B1_XQTDEXP") 
        _nPesoBruto   := Posicione("SB1",1,xFilial("SB1")+TRBI->C6_PRODUTO,"B1_PESBRU") 
        _nPesoLiquido := Posicione("SB1",1,xFilial("SB1")+TRBI->C6_PRODUTO,"B1_PESO") 
        _cTipoPedido  := Posicione("SC5",1,xFilial("SC5")+TRBI->C6_NUM,"C5_TIPO")

        If  _cTipoPedido $ "N/D/B" 

            _nRetMod     := MOD(TRBI->C6_QTDVEN,_nQtdMinima)
            _nQtdVenda   := (TRBI->C6_QTDVEN -_nRetMod)

            If _nQtdAnt == _nQtdVenda 
                _nQtdVenda := _nQtdAnt 
            Else 
                _nQtdVenda := _nQtdVenda
            EndIf

        EndIf 

        TRBI->(dbSkip())

    EndDo 

EndIf

If Select("TRBI") > 0
    TRBI->(DbCloseArea())
EndIf

RestArea(_aArea)

Return _nQtdVenda   
