#include "protheus.ch"
#include "parmtype.ch"
#include "ap5mail.ch"
#include "totvs.ch"
#include 'topconn.ch'
#include 'tbiconn.ch'

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

/*/{Protheus.doc} SF2460I
Foi feito tratativa para gravar os pesos  dos pedidos liberados parcialmente
@type function Ponto de entrada
@version  1.00
@author Emerson Paiva / modificado por Fabio Carneiro e Mario Angelo
@since 25/05/2021
@return  character, sem retorno especifico
@History  Alterado a arotina para tratamento da unidade de medida de expedição - 23/02/2022 - Fabio carneiro 
@History Ajustado fonte para tratar a revisao de comissão Qualy - 24/06/2022 - Fabio Carneiro
@History Ajustado em 04/07/2022 tratamento referente ao peso liquido e peso bruto - Fabio carneiro dos Santos 
@History Ajustado em 09/09/2022 tratamento referente a não considerar comissão se o item estiver zerado - Fabio carneiro dos Santos
/*/
User Function SF2460I()

Local aArea          := GetArea()
Local aAreaSB1       := SB1->(GetArea())
Local aAreaSA1       := SA1->(GetArea())
Local aAreaSA2       := SA2->(GetArea())
Local aAreaSF4       := SF4->(GetArea())
Local aAreaSD2       := SD2->(GetArea())
Local aAreaSF2       := SF2->(GetArea())
Local aAreaSC6       := SC6->(GetArea())
Local aAreaSC5       := SC5->(GetArea())
Local aAreaSC9       := SC9->(GetArea())
Local aAreaSE1       := SE1->(GetArea())
Local aAreaSE2       := SE2->(GetArea())
Local aAreaEE7       := EE7->(GetArea())
Local aAreaEE8       := EE8->(GetArea())
Local aAreaSB2       := SB2->(GetArea())
Local aAreaSB8       := SB8->(GetArea())
Local aAreaSBF       := SBF->(GetArea())
Local aAreaSD5       := SD5->(GetArea())
Local aAreaSDB       := SDB->(GetArea())
Local aAreaSFT       := SFT->(GetArea())
Local aAreaSF3       := SF3->(GetArea())
Local aAreaCD2       := CD2->(GetArea())
Local aAreas         := {aArea,aAreaSB1,aAreaSA1,aAreaSA2,aAreaSF4,aAreaSD2,aAreaSF2,aAreaSC6,aAreaSC5,aAreaSC9,aAreaSE1,aAreaSE2,;
						 aAreaEE7,aAreaEE8,aAreaSB2,aAreaSB8,aAreaSBF,aAreaSD5,aAreaSDB,aAreaSFT,aAreaSF3,aAreaCD2}
Local cQueryI        := "" 
Local cQueryF        := ""
Local cQueryB        := ""
Local cQuery         := ""
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
Local _nValFd        := 0
Local _nPos0         := 0
Local _nCheck        := 0 
Local _nPercCli      := 0
Local _aCheck        := {} 
Local _cUnExp        := "" 
Local _cFormul       := ""
Local _cTipo         := ""
Local _cNome         := ""
Local _cEst          := ""
Local _cPedido       := ""
Local _dNfEmis       := ""
Local _cSerie        := "" 
Local _cCliente      := ""
Local _cLoja         := ""

// projeto Comissões - 31/05/2022

Local cQueryP     := ""
Local cQueryC     := ""
Local _nVlComis1  := 0
Local _nVlTotal   := 0
Local _cPgCliente := ""
Local _cRepreClt  := ""
Local _nVLCOMTAB  := 0
Local _nVALACRS   := 0
Local _nVLBRUTO   := 0
Local _nCount 	  := 0 
Local _nPercTab   := 0
Local _cReprePorc := 0
Local _nComPerc   := 0
Local _nPerPed    := 0
Local _nComProd   := 0
Local _cGEREN     := ""
Local _cVENDEDOR  := ""
Local _cNOMEVEND  := ""
Local _cDOC       := ""
Local _cPgRepre   := ""
Local _dDataPed   := ""
Local _cItem      := ""
Local _cProduto   := ""
Local _cTpCom     := ""
Local cFilComis   := GetMv("QE_FILCOM") // PARAMETRO PARA TRATAMENTO DE QUAIS FILIAIS ENTRAM NA REGRA DE COMISSÃO QUALY

Private _aVolumes    := Array(14, 2)

For _nVol := 1 to Len(_aVolumes)
    _aVolumes[_nVol, 1] := ""
    _aVolumes[_nVol, 2] := 0
Next _nVol
/*
+--------------------------------------------------------------------------+
| Projeto Indicadores de Expedição QUALY - 28/08/2022 - Fabio Carneiro     |
+--------------------------------------------------------------------------+
*/
If Select("TRB8") > 0
	TRB8->(DbCloseArea())
EndIf

cQuery := "SELECT D2_COD AS PRODUTO, " + CRLF
cQuery += " D2_ITEM AS ITEM, " + CRLF
cQuery += " C9_XNUMIND AS INDICADOR, " + CRLF
cQuery += " D2_CLIENTE AS CLIENTE, " + CRLF
cQuery += " D2_LOJA AS LOJA, " + CRLF
cQuery += " D2_DOC AS NFISCAL, " + CRLF
cQuery += " D2_SERIE AS SERIENF, " + CRLF
cQuery += " C9_DATALIB AS DATALIB, " + CRLF
cQuery += " D2_PEDIDO AS PEDIDO, " + CRLF
cQuery += " D2_EMISSAO AS EMISSAO " + CRLF
cQuery += "FROM "+RetSqlName("SD2")+" AS SD2 " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SC9")+" AS SC9 ON D2_FILIAL = C9_FILIAL " + CRLF
cQuery += " AND C9_CLIENTE = D2_CLIENTE " + CRLF
cQuery += " AND C9_LOJA = D2_LOJA " + CRLF
cQuery += " AND C9_PRODUTO = D2_COD " + CRLF
cQuery += " AND C9_LOCAL = D2_LOCAL " + CRLF
cQuery += " AND C9_LOTECTL = D2_LOTECTL " + CRLF
cQuery += " AND C9_NFISCAL = D2_DOC " + CRLF
cQuery += " AND C9_SERIENF = D2_SERIE " + CRLF
cQuery += " AND C9_PEDIDO = D2_PEDIDO " + CRLF
cQuery += " AND SC9.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE D2_FILIAL = '"+xFilial("SD2")+"' " + CRLF
cQuery += " AND D2_DOC     =  '"+SF2->F2_DOC+"' " + CRLF
cQuery += " AND D2_SERIE   =  '"+SF2->F2_SERIE+"' " + CRLF
cQuery += " AND D2_CLIENTE = '"+SF2->F2_CLIENTE+"' " + CRLF
cQuery += " AND D2_LOJA    = '"+SF2->F2_LOJA+"' " + CRLF
cQuery += " AND D2_XNUMIND = ' ' " + CRLF
cQuery += " AND SD2.D_E_L_E_T_ = ' ' " + CRLF 
cQuery += "GROUP BY D2_COD ,D2_ITEM, C9_XNUMIND, D2_CLIENTE, D2_LOJA, D2_DOC, D2_SERIE, D2_PEDIDO, D2_EMISSAO, C9_DATALIB " + CRLF
cQuery += "ORDER BY D2_EMISSAO, D2_PEDIDO, D2_DOC " + CRLF

TCQuery cQuery New Alias "TRB8"

TRB8->(DbGoTop())

While TRB8->(!Eof())

    DbSelectArea("SD2")
    SD2->(DbSetOrder(3))
    If SD2->(dbSeek(xFilial("SD2")+TRB8->NFISCAL+TRB8->SERIENF+TRB8->CLIENTE+TRB8->LOJA+TRB8->PRODUTO+TRB8->ITEM))

		If Empty(SD2->D2_XNUMIND)  
			SD2->(RecLock("SD2",.F.))
			SD2->D2_XNUMIND := TRB8->INDICADOR
			SD2->(MsUnlock())
		EndIf
	
	EndIf

	TRB8->(DbSkip())
		
EndDo
//Fim

// será gravado as unidades de expedição, diferenças e os calculos de embalagens de cada produto 
If SF2->F2_TIPO $ "N/D/B"

    If Select("TRBF") > 0
        TRBF->(DbCloseArea())
    EndIf

    cQueryF := "SELECT D2_FILIAL, D2_COD, D2_QUANT, D2_DOC, D2_SERIE, D2_FORMUL, D2_TIPO, D2_CLIENTE, D2_LOJA, "+CRLF
    cQueryF += "B1_XUNEXP, B1_XQTDEXP, D2_ITEM, D2_TIPO  "+CRLF  
    cQueryF += "FROM "+RetSqlName("SD2")+" AS SD2 WITH (NOLOCK) "+CRLF
    cQueryF += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) ON B1_COD = D2_COD "+CRLF
    cQueryF += " AND SB1.D_E_L_E_T_ = ' ' "+CRLF
    cQueryF += "WHERE D2_FILIAL = '"+xFilial("SD2")+"' "+CRLF
    cQueryF += " AND D2_DOC     = '"+SF2->F2_DOC+"' "+CRLF
    cQueryF += " AND D2_SERIE   = '"+SF2->F2_SERIE+"' "+CRLF
    cQueryF += " AND D2_CLIENTE = '"+SF2->F2_CLIENTE+"' "+CRLF
    cQueryF += " AND D2_LOJA    = '"+SF2->F2_LOJA+"' "+CRLF
    cQueryF += " AND SD2.D_E_L_E_T_ = ' ' "+CRLF 
    cQueryF += "GROUP BY D2_FILIAL, D2_COD, D2_QUANT, D2_DOC, D2_SERIE, D2_FORMUL, D2_TIPO, D2_CLIENTE, D2_LOJA, "+CRLF
    cQueryF += "B1_XUNEXP, B1_XQTDEXP, D2_ITEM, D2_TIPO "+CRLF  
    cQueryF += "ORDER BY B1_XUNEXP,B1_XQTDEXP,D2_DOC, D2_COD  "+CRLF

    TcQuery cQueryF ALIAS "TRBF" NEW

    TRBF->(DbGoTop())

    While TRBF->(!Eof())

        If TRBF->D2_TIPO $ "N/D/B"

            _cDoc          := TRBF->D2_DOC
            _cSerie        := TRBF->D2_SERIE
            _cCliente      := TRBF->D2_CLIENTE
            _cLoja         := TRBF->D2_LOJA
            _cFormul       := TRBF->D2_FORMUL
            _cTipo         := TRBF->D2_TIPO
            _cUnExpedicao  := Posicione("SB1",1,xFilial("SB1")+TRBF->D2_COD,"B1_XUNEXP")
            _nQtdMinima    := Posicione("SB1",1,xFilial("SB1")+TRBF->D2_COD,"B1_XQTDEXP") 
            _nPesoBruto    := Posicione("SB1",1,xFilial("SB1")+TRBF->D2_COD,"B1_PESBRU") 
            _nPesoLiquido  := Posicione("SB1",1,xFilial("SB1")+TRBF->D2_COD,"B1_PESO") 
            _nRetMod       := MOD(TRBF->D2_QUANT,_nQtdMinima)
            _nQtdVenda     := (TRBF->D2_QUANT -_nRetMod)
            _nVal          := (_nQtdVenda / _nQtdMinima)
            _nQtdVol       := _nVal * _nQtdMinima 
            _nDifVol       := TRBF->D2_QUANT-_nQtdVol

            DbSelectArea("SD2")
            SD2->(DbSetOrder(3))
            If SD2->(dbSeek(xFilial("SD2") + TRBF->D2_DOC + TRBF->D2_SERIE + TRBF->D2_CLIENTE + TRBF->D2_LOJA + TRBF->D2_COD + TRBF->D2_ITEM))

                RecLock("SD2",.F.)

                SD2->D2_XUNEXP  := _cUnExpedicao                    // Unidade de expedição do cadastro do produto
                SD2->D2_XCLEXP  := _nVal                            // Quantidade de embalagem 
                SD2->D2_XMINEMB := _nQtdMinima                      // Minimo de Embalagem do cadastro do produto
                SD2->D2_XQTDVOL := _nQtdVol                         // Quantidade do Volume 
                SD2->D2_XDIFVOL := _nDifVol                         // Diferença de Volume menor que a embalagem minima   
                SD2->D2_XPESBUT := (TRBF->D2_QUANT * _nPesoBruto)   // Total de peso bruto
                SD2->D2_XPESLIQ := (TRBF->D2_QUANT * _nPesoLiquido) // Total de peso liquido
                SD2->D2_XPBRU   := _nPesoBruto                      // Peso bruto do cadastro do produto para historico 
                SD2->D2_XPLIQ   := _nPesoLiquido                    // Peso Liquido do cadastro do produto para historico
    
                SD2->(MsUnlock())

            EndIf

        EndIf

        TRBF->(dbSkip())

        SF2->(dbSetOrder(1))	//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
        If SF2->(dbSeek(xFilial("SF2") + _cDoc +  _cSerie + _cCliente + _cLoja + _cFormul + _cTipo))
                    
            Reclock("SF2",.F.)
            SF2->F2_ESPECI1 := ""
            SF2->F2_VOLUME1 := 0
            SF2->F2_ESPECI2 := ""
            SF2->F2_VOLUME2 := 0
            SF2->F2_ESPECI3 := ""
            SF2->F2_VOLUME3 := 0
            SF2->F2_ESPECI4 := ""
            SF2->F2_VOLUME4 := 0
            SF2->F2_ESPECI5 := ""
            SF2->F2_VOLUME5 := 0
            SF2->F2_ESPECI6 := ""
            SF2->F2_VOLUME6 := 0
            SF2->F2_ESPECI7 := ""
            SF2->F2_VOLUME7 := 0
            SF2->F2_PBRUTO  := 0
            SF2->F2_PLIQUI  := 0
            SF2->( Msunlock() )
            
        Endif

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
        _cDoc          := ""
        _cSerie        := ""
        _cCliente      := ""
        _cLoja         := ""
        _cFormul       := ""
        _cTipo         := ""

    EndDo

    // Query para o calculo do volume, especie e peso de acordo com a unidade de expedição geral das empresas

    If Select("TRBI") > 0
        TRBI->(DbCloseArea())
    EndIf

    cQueryI := "SELECT D2_FILIAL, D2_COD, SUM(D2_QUANT) AS D2_QUANT,D2_DOC,D2_SERIE,D2_FORMUL,D2_TIPO,D2_CLIENTE, D2_LOJA, "+CRLF
    cQueryI += "B1_XUNEXP, B1_XQTDEXP,B1_UM, D2_PEDIDO, D2_EMISSAO, B1_PESO, B1_PESBRU "+CRLF
    cQueryI += "FROM "+RetSqlName("SD2")+" AS SD2 WITH (NOLOCK) "+CRLF
    cQueryI += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) ON B1_COD = D2_COD "+CRLF
    cQueryI += " AND SB1.D_E_L_E_T_ = ' ' "+CRLF
    cQueryI += "WHERE D2_FILIAL = '"+xFilial("SD2")+"' "+CRLF
    cQueryI += " AND D2_DOC     = '"+SF2->F2_DOC+"' "+CRLF
    cQueryI += " AND D2_SERIE   = '"+SF2->F2_SERIE+"' "+CRLF
    cQueryI += " AND D2_CLIENTE = '"+SF2->F2_CLIENTE+"' "+CRLF
    cQueryI += " AND D2_LOJA    = '"+SF2->F2_LOJA+"' "+CRLF
    cQueryI += " AND SD2.D_E_L_E_T_ = ' ' "+CRLF 
    cQueryI += "GROUP BY D2_FILIAL, D2_COD,D2_DOC,D2_SERIE,D2_FORMUL,D2_TIPO,D2_CLIENTE, D2_LOJA, "+CRLF
    cQueryI += "B1_XUNEXP, B1_XQTDEXP,B1_UM, D2_PEDIDO, D2_EMISSAO, B1_PESO, B1_PESBRU "+CRLF  
    cQueryI += "ORDER BY B1_XUNEXP,B1_XQTDEXP,D2_DOC, D2_COD  "+CRLF

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

    While TRBI->(!Eof())
    
        If TRBI->D2_TIPO $ "N/D/B"

            _aCheck   := {}
            _cCampo   := ""
            _cFilial  := TRBI->D2_FILIAL
            _cDoc     := TRBI->D2_DOC
            _cSerie   := TRBI->D2_SERIE
            _cCliente := TRBI->D2_CLIENTE
            _cLoja    := TRBI->D2_LOJA
            _cFormul  := TRBI->D2_FORMUL
            _cTipo    := TRBI->D2_TIPO
            _cPedido  := TRBI->D2_PEDIDO
            _dNfEmis  := Substr(TRBI->D2_EMISSAO,7,2)+"/"+Substr(TRBI->D2_EMISSAO,5,2)+"/"+Substr(TRBI->D2_EMISSAO,1,4)

            _cCampo := "TRBI->B1_UM"

            _nPos0  := Ascan(_aVolumes, {|x| &_cCampo $ x[1]})
            
            If TRBI->B1_XUNEXP == 'KG'
                _nVal := (TRBI->D2_QUANT * TRBI->B1_XQTDEXP)
            Else
                _nVal := TRBI->D2_QUANT
            EndIf
            
            If !Empty(TRBI->B1_XUNEXP) 

                _nPos1 := Ascan(_aVolumes, {|x| TRBI->B1_XUNEXP $ x[1]})
                    
                If Select("TRB1") > 0
                    TRB1->(DbCloseArea())
                EndIf

                cQueryB := "SELECT B1_XQTDEXP,B1_XUNEXP,B1_UM  "+CRLF
                cQueryB += "FROM "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) "+CRLF
                cQueryB += "WHERE SB1.B1_COD = '"+TRBI->D2_COD+"' "+CRLF 
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
                        
                    // Calculo que retorna o calculo de embalagens no de acordo com a unidade de expedição e unidade de medida
                    If TRBI->B1_XQTDEXP == _aCheck[_nCheck][1]  .And. _aCheck[_nCheck][3] == TRBI->B1_UM
                            
                        _nValFd  := ((_nVal - (_nVal % _aCheck[_nCheck][1])))/_aCheck[_nCheck][1]
                        _nVal    := _nVal % _aCheck[_nCheck][1]
                        _cUnExp  := _aCheck[_nCheck][2]
                            
                    EndIf
                        
                Next _nCheck

                If _nValFd > 0
                    If _nPos1 == 0
                        _aVolumes[_nPasVol, 1] := _cUnExp
                        _aVolumes[_nPasVol, 2] := _nValFd
                        _nPasVol++
                    Else
                        _aVolumes[_nPos1, 2] += _nValFd
                    EndIf
                    If _nVal > 0
                        If _nPos0 == 0
                            _aVolumes[_nPasVol, 1] := &(_cCampo)
                            _aVolumes[_nPasVol, 2] := _nVal
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
            
            // Calculo do Peso liquido e peso Bruto 
            _nPesoL+=TRBI->D2_QUANT * TRBI->B1_PESO
            _nPesoB+=TRBI->D2_QUANT * TRBI->B1_PESBRU
            
        EndIf

        TRBI->(dbSkip())
   
    EndDo

EndIf

If  Len(_aVolumes) > 0

    SF2->(dbSetOrder(1))	//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
    If SF2->(dbSeek(xFilial("SF2") + _cDoc +  _cSerie + _cCliente + _cLoja + _cFormul + _cTipo))
                
       Reclock("SF2",.F.)
       SF2->F2_ESPECI1 := AllTrim(_aVolumes[1][1])
       SF2->F2_VOLUME1 := _aVolumes[1][2]
       SF2->F2_ESPECI2 := AllTrim(_aVolumes[2][1])
       SF2->F2_VOLUME2 := _aVolumes[2][2]
       SF2->F2_ESPECI3 := AllTrim(_aVolumes[3][1])
       SF2->F2_VOLUME3 := _aVolumes[3][2]
       SF2->F2_ESPECI4 := AllTrim(_aVolumes[4][1])
       SF2->F2_VOLUME4 := _aVolumes[4][2]
       SF2->F2_ESPECI5 := AllTrim(_aVolumes[5][1])
       SF2->F2_VOLUME5 := _aVolumes[5][2]
       SF2->F2_ESPECI6 := AllTrim(_aVolumes[6][1])
       SF2->F2_VOLUME6 := _aVolumes[6][2]
       SF2->F2_ESPECI7 := AllTrim(_aVolumes[7][1])
       SF2->F2_VOLUME7 := _aVolumes[7][2]
       SF2->F2_PBRUTO  := _nPesoB
       SF2->F2_PLIQUI  := _nPesoL
       SF2->( Msunlock() )

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
        _cCliente := ""
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

/*
+--------------------------------------------------------------------------+
| Projeto Comissão especifico QUALY CLIENTE - 31/05/2022 - Fabio Carneiro  |
+--------------------------------------------------------------------------+
*/
If cfilAnt $ cFilComis .And. SF2->F2_TIPO == "N"

	If Select("TRBP") > 0
		TRBP->(DbCloseArea())
	EndIf

	cQueryP := "SELECT 'FATURADO' AS TPREG," + CRLF 
	cQueryP += "D2_TIPO AS TIPO, " + CRLF
	cQueryP += "A3_GEREN AS GEREN, " + CRLF
	cQueryP += "F2_VEND1 AS VENDEDOR, " + CRLF
	cQueryP += "A3_NOME AS NOMEVEND, " + CRLF
	cQueryP += "A1_COD AS CODCLI, " + CRLF
	cQueryP += "A1_LOJA AS LOJA, " + CRLF
	cQueryP += "A1_NOME AS NOMECLI, " + CRLF
	cQueryP += "B1_COD AS PRODUTO, " + CRLF
	cQueryP += "B1_DESC AS DESCRI, " + CRLF
	cQueryP += "D2_ITEM AS ITEM, " + CRLF
	cQueryP += "D2_DOC AS DOC, " + CRLF
	cQueryP += "D2_SERIE AS SERIE," + CRLF
	cQueryP += "D2_PEDIDO AS PEDIDO, " + CRLF
	cQueryP += "D2_EMISSAO AS DTEMISSAO, " + CRLF
	cQueryP += "A1_XPGCOM AS XA1PGCOM, " + CRLF
	cQueryP += "A3_XCLT AS XCLT, " + CRLF
	cQueryP += "A3_XPGCOM AS  XA3PGCOM, " + CRLF
	cQueryP += "A3_COMIS AS A3COMIS, " + CRLF
	cQueryP += "D2_COMIS1 AS C6COMIS, " + CRLF
	cQueryP += "D2_XTABCOM AS XTABCOM, " + CRLF
	cQueryP += "D2_VALBRUT AS VLBRUTO, " + CRLF
	cQueryP += "D2_TOTAL AS VLTOTAL, " + CRLF
	cQueryP += "D2_VALACRS AS  VALACRS, " + CRLF
	cQueryP += "B1_COMIS AS B1COMIS, " + CRLF
	cQueryP += "D2_XCOM1 AS D2XCOM1, " + CRLF
	cQueryP += "'' AS NUMTIT, " + CRLF 
	cQueryP += "'' AS PREFIXO, " + CRLF
	cQueryP += "'' AS PARCELA, " + CRLF
	cQueryP += "'' AS TIPOTIT, " + CRLF
	cQueryP += "'' AS DTEMISSAOTIT, " + CRLF
	cQueryP += "'' AS DTVENCREA, " + CRLF
	cQueryP += "'' AS DTBAIXA,  " + CRLF
	cQueryP += "'' AS VLBASCOM1, " + CRLF
	cQueryP += "'' AS VLCOM1, " + CRLF
	cQueryP += "'' AS VLTITULO, " + CRLF
	cQueryP += "F4_DUPLIC AS F4DUPLIC, " + CRLF
	cQueryP += "A1_XCOMIS1 AS XCOMIS1, " + CRLF
	cQueryP += "B1_XREVCOM AS XREVCOM, " + CRLF
	cQueryP += "B1_XTABCOM AS XB1TABCOM, " + CRLF
	cQueryP += "C6_XTABCOM AS C6XTABCOM, "+ CRLF
	cQueryP += "C6_XREVCOM AS C6XREVCOM, "+ CRLF
	cQueryP += "C6_XDTRVC AS C6XDTRVC, "+ CRLF
	cQueryP += "C6_XTPCOM AS C6XTPCOM, "+ CRLF
	cQueryP += "C6_COMIS1 AS C6COMIS1, "+ CRLF 
	cQueryP += "C6_XCOM1 AS C6XCOM1  "+ CRLF
	cQueryP += "FROM "+RetSqlName("SD2")+" AS SD2 WITH (NOLOCK) " + CRLF  
	cQueryP += "INNER JOIN "+RetSqlName("SF2")+" AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL " + CRLF 
	cQueryP += " AND F2_DOC = D2_DOC " + CRLF
	cQueryP += " AND F2_SERIE = D2_SERIE " + CRLF
	cQueryP += " AND F2_CLIENTE = D2_CLIENTE " + CRLF
	cQueryP += " AND F2_LOJA = D2_LOJA " + CRLF
	cQueryP += " AND F2_TIPO = D2_TIPO " + CRLF
	cQueryP += " AND F2_EMISSAO = D2_EMISSAO " + CRLF
	cQueryP += " AND SF2.D_E_L_E_T_ = ' ' " + CRLF
	cQueryP += "INNER JOIN "+RetSqlName("SE1")+" AS SE1 WITH (NOLOCK) ON E1_FILIAL = F2_FILIAL " + CRLF
	cQueryP += " AND E1_NUM = F2_DOC " + CRLF
	cQueryP += " AND E1_PREFIXO = F2_SERIE " + CRLF
	cQueryP += " AND E1_CLIENTE = F2_CLIENTE " + CRLF
	cQueryP += " AND E1_LOJA = F2_LOJA " + CRLF
	cQueryP += " AND E1_EMISSAO = F2_EMISSAO " + CRLF
	cQueryP += " AND SE1.D_E_L_E_T_ = ' '  " + CRLF
	cQueryP += "INNER JOIN "+RetSqlName("SF4")+" AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(D2_FILIAL, 2) " + CRLF
	cQueryP += " AND F4_CODIGO = D2_TES " + CRLF
	cQueryP += " AND SF4.D_E_L_E_T_ = ' ' " + CRLF
	cQueryP += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) ON B1_FILIAL = '    ' " + CRLF
	cQueryP += " AND B1_COD = D2_COD " + CRLF
	cQueryP += " AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQueryP += "INNER JOIN "+RetSqlName("SA3")+" AS SA3 WITH (NOLOCK) ON A3_COD = F2_VEND1 " + CRLF
	cQueryP += "	AND SA3.D_E_L_E_T_ = ' ' " + CRLF
	cQueryP += "INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH (NOLOCK) ON A1_FILIAL = F2_FILIAL " + CRLF
	cQueryP += " AND A1_COD = F2_CLIENTE " + CRLF
	cQueryP += " AND A1_LOJA = F2_LOJA " + CRLF
	cQueryP += "INNER JOIN "+RetSqlName("SC6")+" AS SC6 WITH (NOLOCK) ON D2_FILIAL = C6_FILIAL " + CRLF
	cQueryP += " AND C6_PRODUTO = D2_COD  "+ CRLF
	cQueryP += " AND C6_NUM  = D2_PEDIDO  "+ CRLF
	cQueryP += " AND C6_CLI  = D2_CLIENTE "+ CRLF
	cQueryP += " AND C6_LOJA = D2_LOJA    "+ CRLF
	cQueryP += " AND SC6.D_E_L_E_T_ = ' ' "+ CRLF
	cQueryP += "WHERE D2_FILIAL = '"+xFilial("SD2")+"' " + CRLF
	cQueryP += " AND D2_DOC   = '"+SF2->F2_DOC+"' " + CRLF
	cQueryP += " AND D2_SERIE = '"+SF2->F2_SERIE+"' " + CRLF
	cQueryP += " AND D2_CLIENTE = '"+SF2->F2_CLIENTE+"' " + CRLF
	cQueryP += " AND D2_LOJA = '"+SF2->F2_LOJA+"' " + CRLF
	cQueryP += " AND F4_DUPLIC = 'S'  " + CRLF
	cQueryP += " AND SD2.D_E_L_E_T_ = ' '  " + CRLF
	cQueryP += "GROUP BY D2_TIPO,A3_GEREN,F2_VEND1,A3_NOME,A1_COD,A1_LOJA,A1_NOME,B1_COD,B1_DESC,D2_ITEM,D2_DOC,D2_SERIE,D2_PEDIDO,D2_EMISSAO,B1_XREVCOM,B1_XTABCOM, " + CRLF
	cQueryP += "A1_XPGCOM,A3_XCLT,A3_XPGCOM,A3_COMIS,D2_COMIS1,D2_XTABCOM,D2_TOTAL,B1_COMIS,D2_XCOM1,D2_VALACRS,D2_VALBRUT,F4_DUPLIC,A1_XCOMIS1, " + CRLF
	cQueryP += "C6_XTABCOM, C6_XREVCOM, C6_XDTRVC, C6_XTPCOM, C6_COMIS1, C6_XCOM1  " + CRLF

	cQueryP += "UNION " + CRLF

	cQueryP += "SELECT 'TITULO' AS TPREG, " + CRLF 
	cQueryP += "'T' AS TIPO, " + CRLF
	cQueryP += "A3_GEREN AS GEREN, " + CRLF
	cQueryP += "F2_VEND1 AS VENDEDOR, " + CRLF
	cQueryP += "A3_NOME AS NOMEVEND, " + CRLF
	cQueryP += "A1_COD AS CODCLI, " + CRLF
	cQueryP += "A1_LOJA AS LOJA, " + CRLF
	cQueryP += "A1_NOME AS NOMECLI, " + CRLF
	cQueryP += "'' AS PRODUTO, " + CRLF
	cQueryP += "'' AS DESCRI, " + CRLF
	cQueryP += "'' AS ITEM, " + CRLF
	cQueryP += "E1_NUM AS DOC, " + CRLF
	cQueryP += "E1_PREFIXO AS SERIE,  " + CRLF
	cQueryP += "'' AS PEDIDO, " + CRLF
	cQueryP += "E1_EMISSAO AS DTEMISSAO, " + CRLF 
	cQueryP += "A1_XPGCOM AS XA1PGCOM, " + CRLF
	cQueryP += "A3_XCLT AS XCLT, " + CRLF
	cQueryP += "A3_XPGCOM AS  XA3PGCOM, " + CRLF
	cQueryP += "A3_COMIS AS A3COMIS, " + CRLF
	cQueryP += "0 AS C6COMIS, " + CRLF
	cQueryP += "0 AS XTABCOM, " + CRLF
	cQueryP += "0 AS VLBRUTO, " + CRLF
	cQueryP += "0 AS VLTOTAL, " + CRLF
	cQueryP += "0 AS VALACRS, " + CRLF
	cQueryP += "0 AS B1COMIS, " + CRLF
	cQueryP += "0 AS D2XCOM1, " + CRLF
	cQueryP += "E1_NUM AS NUMTIT, " + CRLF 
	cQueryP += "E1_PREFIXO AS PREFIXO, " + CRLF
	cQueryP += "E1_PARCELA AS PARCELA, " + CRLF
	cQueryP += "E1_TIPO AS TIPOTIT, " + CRLF
	cQueryP += "E1_EMISSAO AS DTEMISSAOTIT, " + CRLF
	cQueryP += "E1_VENCREA AS DTVENCREA, " + CRLF
	cQueryP += "E1_BAIXA AS DTBAIXA,  " + CRLF
	cQueryP += "E1_BASCOM1 AS VLBASCOM1, " + CRLF
	cQueryP += "E1_COMIS1  AS VLCOM1, " + CRLF
	cQueryP += "E1_VALOR   AS VLTITULO, " + CRLF
	cQueryP += "'' AS F4DUPLIC, " + CRLF
	cQueryP += "A1_XCOMIS1 AS XCOMIS1, " + CRLF
	cQueryP += "'' AS XREVCOM, " + CRLF
	cQueryP += "'' AS XB1TABCOM, " + CRLF
	cQueryP += "'' AS C6XTABCOM, '' AS C6XREVCOM, '' AS C6XDTRVC, '' AS C6XTPCOM, 0 AS C6COMIS1, 0 AS C6XCOM1  "+ENTER
	cQueryP += "FROM "+RetSqlName("SE1")+" AS SE1 WITH (NOLOCK) " + CRLF 
	cQueryP += "INNER JOIN "+RetSqlName("SF2")+" AS SF2 WITH (NOLOCK) ON E1_FILIAL = F2_FILIAL " + CRLF
	cQueryP += " AND E1_NUM = F2_DOC " + CRLF
	cQueryP += " AND E1_PREFIXO = F2_SERIE " + CRLF
	cQueryP += " AND E1_CLIENTE = F2_CLIENTE " + CRLF
	cQueryP += " AND E1_LOJA = F2_LOJA " + CRLF
	cQueryP += " AND E1_EMISSAO = F2_EMISSAO " + CRLF
	cQueryP += " AND SE1.D_E_L_E_T_ = ' '  " + CRLF
	cQueryP += "INNER JOIN "+RetSqlName("SA3")+" AS SA3 WITH (NOLOCK) ON A3_COD = F2_VEND1 " + CRLF
	cQueryP += " AND SA3.D_E_L_E_T_ = ' ' " + CRLF
	cQueryP += "INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH (NOLOCK) ON A1_FILIAL = F2_FILIAL " + CRLF
	cQueryP += " AND A1_COD = F2_CLIENTE " + CRLF
	cQueryP += " AND A1_LOJA = F2_LOJA " + CRLF
	cQueryP += "WHERE E1_FILIAL = '"+xFilial("SE1")+"'  " + CRLF
	cQueryP += " AND E1_TIPO    = 'NF ' " + CRLF
	cQueryP += " AND E1_NUM     = '"+SF2->F2_DOC+"' " + CRLF
	cQueryP += " AND E1_PREFIXO = '"+SF2->F2_SERIE+"' " + CRLF
	cQueryP += " AND E1_CLIENTE  = '"+SF2->F2_CLIENTE+"' " + CRLF
	cQueryP += " AND E1_LOJA = '"+SF2->F2_LOJA+"' " + CRLF
	cQueryP += " AND SE1.D_E_L_E_T_ = ' '  " + CRLF
	cQueryP += "GROUP BY A3_GEREN,F2_VEND1,A3_NOME,A1_COD,A1_LOJA,A1_NOME,E1_EMISSAO,A1_XPGCOM,A3_XCLT,A3_XPGCOM,A3_COMIS,E1_NUM,E1_PREFIXO, " + CRLF
	cQueryP += "E1_PARCELA,E1_TIPO,E1_EMISSAO,E1_VENCREA,E1_BAIXA,E1_BASCOM1,E1_COMIS1,E1_VALOR,A1_XCOMIS1 " + CRLF
	cQueryP += "ORDER BY VENDEDOR,DOC,TPREG,PARCELA,DTEMISSAO,ITEM " + CRLF

	TCQuery cQueryP New Alias "TRBP"

	TRBP->(DbGoTop())

	While TRBP->(!Eof())

		_cPgCliente  := ""
		_cRepreClt   := ""
		_cPgRepre    := ""
		_cReprePorc  := 0
		_nComProd    := 0 

		_cPgCliente  := TRBP->XA1PGCOM  // 1 = Não / 2 = Sim
		_cRepreClt   := TRBP->XCLT      // 1 = Não / 2 = Sim
		_cPgRepre    := TRBP->XA3PGCOM  // 1 = Não / 2 = Sim
		_cReprePorc  := TRBP->A3COMIS   // % do vendedor 
		_nPercCli    := TRBP->XCOMIS1   // % por cliente 
		_cGEREN		 := TRBP->GEREN
		_cVENDEDOR   := TRBP->VENDEDOR
		_cNOMEVEND 	 := TRBP->NOMEVEND 
		_cDOC  		 := TRBP->DOC                    
		_dDataPed    := StoD(TRBP->DTEMISSAO)
		_cItem       := TRBP->ITEM
		_cProduto    := TRBP->PRODUTO 

		If _cPgCliente == "2" .And. _cPgRepre == "2" .And. TRBP->F4DUPLIC == "S"

			If  AllTrim(TRBP->TPREG) == "FATURADO"
		
				_nComProd   := TRBP->C6COMIS	
				_nVLBRUTO   += TRBP->VLBRUTO 

				If _nComProd > 0
					_nVLCOMIS1  := TRBP->C6COMIS1
					_nVLCOMTAB  := TRBP->C6XCOM1
					_nVLTOTAL   += TRBP->VLTOTAL
					_nVALACRS   += TRBP->VALACRS
				Else 
					_nVLCOMIS1  += 0
					_nVLCOMTAB  += 0
					_nVLTOTAL   += 0
					_nVALACRS   += 0
				EndIf 
				
				If TRBP->XA1PGCOM == "2" .And. TRBP->XCOMIS1 > 0
	
					If _nComProd > 0
						_nPercTab   += Round((TRBP->VLTOTAL * _nVLCOMTAB)/100,2)    // Percentual da Tabela 
						_nComPerc   += Round((TRBP->VLTOTAL * TRBP->XCOMIS1)/100,2) // Percentual do cadastro do cleinte 
						_cTpCom     := TRBP->C6XTPCOM 
					Else 
						_nPercTab   += 0
						_nComPerc   += 0
						_cTpCom     := TRBP->C6XTPCOM 
					EndIf 

				ElseIf TRBP->XCLT == "2" .And. TRBP->XA3PGCOM == "2" .And. TRBP->XCOMIS1 <= 0
					If _nComProd > 0
						_nPercTab   += Round((TRBP->VLTOTAL * _nVLCOMTAB)/100,2) 
						_nComPerc   += Round((TRBP->VLTOTAL * TRBP->A3COMIS)/100,2)
						_cTpCom     := TRBP->C6XTPCOM 
					Else 
						_nPercTab   += 0
						_nComPerc   += 0
						_cTpCom     := TRBP->C6XTPCOM 
					EndIf
				ElseIf TRBP->XA1PGCOM == "2" .And. TRBP->XCOMIS1 <= 0

					If _nComProd > 0
						_nPercTab   += Round((TRBP->VLTOTAL * _nVLCOMTAB)/100,2) 
						_nComPerc   += Round((TRBP->VLTOTAL * TRBP->C6COMIS1)/100,2)
						_cTpCom     := TRBP->C6XTPCOM 
					Else 
						_nPercTab   += 0
						_nComPerc   += 0
						_cTpCom     := TRBP->C6XTPCOM 
					EndIf 

				EndIf
					
				If _nComProd > 0

					If TRBP->XCOMIS1 > 0
						_nPerPed    := If(TRBP->XA1PGCOM=="2".And.TRBP->XCOMIS1 > 0,TRBP->XCOMIS1,TRBP->C6COMIS1)
					Else 
						_nPerPed    := If(TRBP->XCLT=="2".And.TRBP->XA3PGCOM=="2",TRBP->A3COMIS,TRBP->C6COMIS1)
					EndIf
				
				Else 				

					_nPerPed    := 0

				EndIf

			EndIf

		EndIf

		If  AllTrim(TRBP->TPREG) == "TITULO"

			_nCount := 0
			If Select("TRB3") > 0
    			TRB3->(DbCloseArea())
			EndIf

			cQueryC := "SELECT COUNT(E1_NUM) AS QUANT " + CRLF
			cQueryC += "FROM "+RetSqlName("SE1")+" AS SE1 " + CRLF
			cQueryC += " WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' " + CRLF
			cQueryC += " AND SE1.E1_NUM     = '"+TRBP->NUMTIT+"'  " + CRLF
			cQueryC += " AND SE1.E1_PREFIXO = '"+TRBP->PREFIXO+"'  " + CRLF
			cQueryC += " AND SE1.E1_CLIENTE = '"+TRBP->CODCLI+"'  " + CRLF
			cQueryC += " AND SE1.E1_LOJA    = '"+TRBP->LOJA+"'  " + CRLF
			cQueryC += " AND SE1.E1_TIPO    = 'NF '   " + CRLF
			cQueryC += " AND SE1.D_E_L_E_T_ = ' ' " + CRLF
			cQueryC += "UNION " + CRLF			
			cQueryC += "SELECT COUNT(E5_NUMERO)*(-1) AS QUANT " + CRLF
			cQueryC += "FROM "+RetSqlName("SE5")+" AS SE5 " + CRLF
			cQueryC += " WHERE SE5.E5_FILIAL = '"+xFilial("SE5")+"' " + CRLF
			cQueryC += " AND SE5.E5_NUMERO  = '"+TRBP->NUMTIT+"'  " + CRLF
			cQueryC += " AND SE5.E5_PREFIXO = '"+TRBP->PREFIXO+"'  " + CRLF
			cQueryC += " AND SE5.E5_CLIFOR  = '"+TRBP->CODCLI+"'  " + CRLF
			cQueryC += " AND SE5.E5_LOJA    = '"+TRBP->LOJA+"'  " + CRLF
			cQueryC += " AND SE5.E5_MOTBX IN ('LIQ','CAN') " + CRLF
			cQueryC += " AND SE5.E5_TIPO    = 'NF '   " + CRLF
			cQueryC += " AND SE5.D_E_L_E_T_ = ' ' " + CRLF

			TCQUERY cQueryC NEW ALIAS TRB3

			TRB3->(dbGoTop())

			While TRB3->(!Eof())
								
				_nCount += TRB3->QUANT

				TRB3->(dbSkip())

			Enddo

			_cDOC  		 := TRBP->DOC  
			_cSerie		 := TRBP->SERIE  
			_cPercela	 := TRBP->PARCELA  

			_nCMTOTAL   := ABS((_nVLTOTAL - _nVALACRS))
			_nBaseTit   := If(_nCount > 0,Round((_nCMTOTAL / _nCount),2),Round((_nCMTOTAL),2))
			_nPCalcCom  := Round((_nComPerc/_nVLTOTAL)*100,2) 
			_nPCalcTab  := Round((_nPercTab/_nVLTOTAL)*100,2) 	

			If _cPgCliente == "2" .And. _cPgRepre == "2"

				DbSelectArea("SE1")
				DbSetOrder(1)  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
				If SE1->(dbSeek(xFilial("SE1")+TRBP->PREFIXO+TRBP->NUMTIT+TRBP->PARCELA+TRBP->TIPOTIT)) 
								
					If TRBP->XA1PGCOM == "2" .And. TRBP->XCOMIS1 > 0
					
						Reclock("SE1",.F.)
						If Empty(SE1->E1_VEND1)
							SE1->E1_VEND1     := _cVENDEDOR 
						EndIf
						SE1->E1_BASCOM1    := _nBaseTit
						SE1->E1_COMIS1     := TRBP->XCOMIS1 
						SE1->E1_XCOM1      := TRBP->XCOMIS1 
						SE1->E1_XBASCOM    := _nBaseTit
						SE1->E1_XTPCOM     := If(Empty(_cTpCom),"04",_cTpCom)
						SE1->( Msunlock() )
					
					ElseIf TRBP->XA1PGCOM == "2" .And. TRBP->XCLT == "1" .And. TRBP->XCOMIS1 <= 0

						Reclock("SE1",.F.)
						If Empty(SE1->E1_VEND1)
							SE1->E1_VEND1     := _cVENDEDOR 
						EndIf
						SE1->E1_BASCOM1    := _nBaseTit
						SE1->E1_COMIS1     := _nPCalcCom  
						SE1->E1_XCOM1      := _nPCalcTab 
						SE1->E1_XBASCOM    := _nBaseTit
						SE1->E1_XTPCOM     := If(Empty(_cTpCom),"04",_cTpCom)
						SE1->( Msunlock() )

					ElseIf TRBP->XA1PGCOM == "2" .And. TRBP->XCLT == "2" .And. TRBP->XA3PGCOM == "2" .And. TRBP->XCOMIS1 <= 0

						Reclock("SE1",.F.)
						If Empty(SE1->E1_VEND1)
							SE1->E1_VEND1     := _cVENDEDOR 
						EndIf
						SE1->E1_BASCOM1    := _nBaseTit
						SE1->E1_COMIS1     := TRBP->A3COMIS 
						SE1->E1_XCOM1      := TRBP->A3COMIS 
						SE1->E1_XBASCOM    := _nBaseTit
						SE1->E1_XTPCOM     := If(Empty(_cTpCom),"04",_cTpCom)
						SE1->( Msunlock() )
					
					ElseIf TRB1->VLBASCOM1 <= 0 
						
						DbSelectArea("SE1")
						DbSetOrder(1)  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
						If SE1->(dbSeek(xFilial("SE1")+TRB1->PREFIXO+TRB1->NUMTIT+TRB1->PARCELA+TRB1->TIPOTIT)) 
							Reclock("SE1",.F.)
							If Empty(SE1->E1_VEND1)
								SE1->E1_VEND1     := _cVENDEDOR 
							EndIf
							SE1->E1_BASCOM1    := _nBaseTit
							SE1->E1_XBASCOM    := _nBaseTit

							SE1->( Msunlock() )
						EndIf

					
					EndIf	

				EndIf

			ElseIf _cPgCliente == "1" .And. _cPgRepre == "1"

				DbSelectArea("SE1")
				DbSetOrder(1)  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
				If SE1->(dbSeek(xFilial("SE1")+TRBP->PREFIXO+TRBP->NUMTIT+TRBP->PARCELA+TRBP->TIPOTIT)) 
								
					Reclock("SE1",.F.)
								
						If Empty(SE1->E1_VEND1)
							SE1->E1_VEND1     := _cVENDEDOR 
						EndIf
						SE1->E1_BASCOM1    := 0
						SE1->E1_COMIS1     := 0
						SE1->E1_XCOM1      := 0
						SE1->E1_XBASCOM    := 0
						SE1->E1_XTPCOM     := If(Empty(_cTpCom),"04",_cTpCom)

					SE1->( Msunlock() )
					
				EndIf

			Else 

				DbSelectArea("SE1")
				DbSetOrder(1)  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
				If SE1->(dbSeek(xFilial("SE1")+TRBP->PREFIXO+TRBP->NUMTIT+TRBP->PARCELA+TRBP->TIPOTIT)) 
								
					Reclock("SE1",.F.)
								
						If Empty(SE1->E1_VEND1)
							SE1->E1_VEND1     := _cVENDEDOR 
						EndIf
						SE1->E1_BASCOM1    := 0
						SE1->E1_COMIS1     := 0
						SE1->E1_XCOM1      := 0
						SE1->E1_XBASCOM    := 0
						SE1->E1_XTPCOM     := If(Empty(_cTpCom),"04",_cTpCom)

					SE1->( Msunlock() )
					
				EndIf
			
			EndIf

		EndIf

		TRBP->(DbSkip())

		If TRBP->(EOF()) .Or. TRBP->DOC <> _cDOC 
					
			_nVLCOMIS1  := 0
			_nVLCOMTAB  := 0
			_nVLTOTAL   := 0
			_nVALACRS   := 0
			_nVLBRUTO   := 0
			_nPCalcCom  := 0
			_nPCalcTab  := 0 
			_cGEREN		:= ""
			_cVENDEDOR  := ""
			_cNOMEVEND 	:= ""
			_cDOC  		:= ""
			_dDataPed   := "" 
			_cItem      := ""
			_cProduto   := ""
			_cTpCom     := ""
			
		EndIf 

	EndDo
	
EndIf

If Select("TRBP") > 0
	TRBP->(DbCloseArea())
EndIf
If Select("TRB3") > 0
    TRB3->(DbCloseArea())
EndIf
If Select("TRB1") > 0
    TRB1->(DbCloseArea())
EndIf
If Select("TRBI") > 0
    TRBI->(DbCloseArea())
EndIf
If Select("TRBF") > 0
	TRBF->(DbCloseArea())
EndIf

AEval(aAreas, {|uArea| RestArea(uArea)})

Return
