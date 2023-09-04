#include "protheus.ch"
#include "parmtype.ch"
#include "ap5mail.ch"
#include "totvs.ch"
#include 'topconn.ch'
#include 'tbiconn.ch'

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

/*/{Protheus.doc} QEMNTEXP
Rotina que grava dados de unidade expedição e gera conferencia dos pack de separação. 
@type function Ponto de entrada
@version  1.00
@author Fabio Carneiro e Mario Angelo
@since 23/04/2022
@return  character, sem retorno especifico
/*/

User Function QEMNTEXP()

Local aSays    := {}
Local aButtons := {}
Local cTitoDlg := "Atualização de unidade de expedição e peso - Filial "+Rtrim(SM0->M0_CODFIL)
Local nOpca    := 0
Private _cPerg := "QEEXPX"

aAdd(aSays, "Rotina para ATUALIZAR unidade de expedição de NF(s)/Pack separação!")
aAdd(aSays, "->Esta rotina é apenas para NF(s) antes do cálculo da unidade expedição.")
aAdd(aSays, "->Esta rotina apaga os registros de especie, volume e peso e grava novamente.")
aAdd(aSays, "Utilizar antes da transmissão das NF(s), caso tenha necessidade de acertos!")


aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

FormBatch(cTitoDlg, aSays, aButtons)

If nOpca == 1
	
	oAjustaSx1()

	If !Pergunte(_cPerg,.T.)
		Return
	Else 
    	MontaDir("C:\TOTVS\")
        Processa({|| QEMNTEXPok("Gerando dados, aguarde...")})
	Endif
		
EndIf

Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEMNTEXPok| Autor: | QUALY         | Data: | 13/02/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEMNTEXPok                                   |
+------------+-----------------------------------------------------------+
*/
Static Function QEMNTEXPok()

Local cArqDst        := "C:\TOTVS\QEMNTEXP_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
Local oExcel         := FWMsExcelEX():New()
Local cPlan          := "Empresa_" + Rtrim(SM0->M0_CODIGO) + "_Filial_" + Rtrim(SM0->M0_CODFIL)
Local cTit           := "Conferência de Pack de Separação do Projeto Unidade de Expedição   "
Local _lAbre          := .F.

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
Local _lAtVol        := EQVldAlt(1) //.T.
Local _nValFd        := 0
Local _nPos0         := 0
Local _nCheck        := 0 
Local _aCheck        := {} 
Local _cUnExp        := "" 
Local _cDoc          := ""
Local _cSerie        := ""
Local _cCliente      := ""
Local _cLoja         := ""
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

oExcel:AddworkSheet(cPlan)
oExcel:AddTable(cPlan, cTit)
oExcel:AddColumn(cPlan, cTit, "Filial"             , 1, 1, .F.)  //01
oExcel:AddColumn(cPlan, cTit, "Nota Fiscal"        , 1, 1, .F.)  //02
oExcel:AddColumn(cPlan, cTit, "Serie"              , 1, 1, .F.)  //03
oExcel:AddColumn(cPlan, cTit, "Data Emissao"       , 1, 1, .F.)  //04
oExcel:AddColumn(cPlan, cTit, "Codigo Cliente"     , 1, 1, .F.)  //05
oExcel:AddColumn(cPlan, cTit, "Loja Cliente"       , 1, 1, .F.)  //06
oExcel:AddColumn(cPlan, cTit, "Nome Cliente"       , 1, 1, .F.)  //07
oExcel:AddColumn(cPlan, cTit, "Estado"             , 1, 1, .F.)  //08
oExcel:AddColumn(cPlan, cTit, "Pedido Vendas"      , 1, 1, .F.)  //09
oExcel:AddColumn(cPlan, cTit, "Produto"            , 1, 1, .F.)  //10
oExcel:AddColumn(cPlan, cTit, "Desc. Produto"      , 1, 1, .F.)  //11
oExcel:AddColumn(cPlan, cTit, "Unid. Med."         , 1, 1, .F.)  //12
oExcel:AddColumn(cPlan, cTit, "Unid. Exp."         , 1, 1, .F.)  //13
oExcel:AddColumn(cPlan, cTit, "Quant. Emb."        , 3, 2, .F.)  //14
oExcel:AddColumn(cPlan, cTit, "Quant. Venda"       , 3, 2, .F.)  //15
oExcel:AddColumn(cPlan, cTit, "Peso Liquido"       , 3, 2, .F.)  //16
oExcel:AddColumn(cPlan, cTit, "Peso Bruto"         , 3, 2, .F.)  //17
oExcel:AddColumn(cPlan, cTit, "Especie 1"          , 1, 1, .F.)  //18
oExcel:AddColumn(cPlan, cTit, "Volume  1"          , 3, 2, .F.)  //19
oExcel:AddColumn(cPlan, cTit, "Especie 2"          , 1, 1, .F.)  //20
oExcel:AddColumn(cPlan, cTit, "Volume  2"          , 3, 2, .F.)  //21
oExcel:AddColumn(cPlan, cTit, "Especie 3"          , 1, 1, .F.)  //22
oExcel:AddColumn(cPlan, cTit, "Volume  3"          , 3, 2, .F.)  //23
oExcel:AddColumn(cPlan, cTit, "Especie 4"          , 1, 1, .F.)  //24
oExcel:AddColumn(cPlan, cTit, "Volume  4"          , 3, 2, .F.)  //25
oExcel:AddColumn(cPlan, cTit, "Especie 5"          , 1, 1, .F.)  //26
oExcel:AddColumn(cPlan, cTit, "Volume  5"          , 3, 2, .F.)  //27
oExcel:AddColumn(cPlan, cTit, "Especie 6"          , 1, 1, .F.)  //28
oExcel:AddColumn(cPlan, cTit, "Volume  6"          , 3, 2, .F.)  //29
oExcel:AddColumn(cPlan, cTit, "Especie 7"          , 1, 1, .F.)  //30
oExcel:AddColumn(cPlan, cTit, "Volume  7"          , 3, 2, .F.)  //31

// será gravado as unidades de expedição, diferenças e os calculos de embalagens de cada produto 

If Select("TRBF") > 0
	TRBF->(DbCloseArea())
EndIf

cQueryF := "SELECT D2_FILIAL, D2_COD, D2_QUANT, D2_DOC, D2_SERIE, D2_FORMUL, D2_TIPO, D2_CLIENTE, D2_LOJA, "+CRLF
cQueryF += "B1_XUNEXP, B1_XQTDEXP, D2_ITEM, D2_TIPO, B1_UM, B1_DESC  "+CRLF  
cQueryF += "FROM "+RetSqlName("SD2")+" AS SD2 WITH (NOLOCK) "+CRLF
cQueryF += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) ON B1_COD = D2_COD "+CRLF
cQueryF += " AND SB1.D_E_L_E_T_ = ' ' "+CRLF
cQueryF += "WHERE D2_FILIAL = '"+xFilial("SD2")+"' "+CRLF
cQueryF += " AND D2_DOC BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+CRLF
cQueryF += " AND D2_SERIE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+CRLF
cQueryF += " AND D2_EMISSAO BETWEEN '"+Dtos(MV_PAR05)+"' AND '"+Dtos(MV_PAR06)+"' "+CRLF
cQueryF += " AND D2_TIPO IN ('N','D','B') "+CRLF
cQueryF += " AND SD2.D_E_L_E_T_ = ' ' "+CRLF 
cQueryF += "GROUP BY D2_FILIAL, D2_COD, D2_QUANT, D2_DOC, D2_SERIE, D2_FORMUL, D2_TIPO, D2_CLIENTE, D2_LOJA, "+CRLF
cQueryF += "B1_XUNEXP, B1_XQTDEXP, D2_ITEM, D2_TIPO, B1_UM, B1_DESC "+CRLF  
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

    _cDoc          := ""
    _cSerie        := ""
    _cCliente      := ""
    _cLoja         := ""
    _cFormul       := ""
    _cTipo         := ""

EndDo

// Query para o calculo do volume, especie e peso de acordo com a unidade de expedição 

If Select("TRBI") > 0
	TRBI->(DbCloseArea())
EndIf

cQueryI := "SELECT D2_FILIAL, D2_COD, SUM(D2_QUANT) AS D2_QUANT,D2_DOC,D2_SERIE,D2_FORMUL,D2_TIPO,D2_CLIENTE, D2_LOJA, "+CRLF
cQueryI += "B1_XUNEXP, B1_XQTDEXP,B1_UM, A1_NOME, A1_EST, D2_PEDIDO, D2_EMISSAO, B1_PESO, B1_PESBRU "+CRLF
cQueryI += "FROM "+RetSqlName("SD2")+" AS SD2 WITH (NOLOCK) "+CRLF
cQueryI += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) ON B1_COD = D2_COD "+CRLF
cQueryI += " AND SB1.D_E_L_E_T_ = ' ' "+CRLF
cQueryI += "INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH (NOLOCK) ON A1_FILIAL = D2_FILIAL "+CRLF
cQueryI += " AND A1_COD  = D2_CLIENTE "+CRLF
cQueryI += " AND A1_LOJA = D2_LOJA "+CRLF 
cQueryI += " AND SA1.D_E_L_E_T_ = ' ' "+CRLF
cQueryI += "WHERE D2_FILIAL = '"+xFilial("SD2")+"' "+CRLF
cQueryI += " AND D2_DOC BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+CRLF
cQueryI += " AND D2_SERIE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+CRLF
cQueryI += " AND D2_EMISSAO BETWEEN '"+Dtos(MV_PAR05)+"' AND '"+Dtos(MV_PAR06)+"' "+CRLF
cQueryI += " AND D2_TIPO IN ('N','D','B') "+CRLF
cQueryI += " AND SD2.D_E_L_E_T_ = ' ' "+CRLF 
cQueryI += "GROUP BY D2_FILIAL, D2_COD,D2_DOC,D2_SERIE,D2_FORMUL,D2_TIPO,D2_CLIENTE, D2_LOJA, "+CRLF
cQueryI += "B1_XUNEXP, B1_XQTDEXP,B1_UM, A1_NOME, A1_EST, D2_PEDIDO, D2_EMISSAO, B1_PESO, B1_PESBRU "+CRLF  
cQueryI += "ORDER BY D2_DOC,B1_XUNEXP,B1_XQTDEXP,D2_COD  "+CRLF

TcQuery cQueryI ALIAS "TRBI" NEW

TRBI->(DbGoTop())

_cUnExpedicao  := ""
_nQtdMinima    := 0
_nPesoBruto    := 0
_nPesoLiquido  := 0
_nRetMod       := 0
_nQtdVenda     := 0
_nVal          := 0
_nVol          := 0
_nQtdVol       := 0
_nDifVol       := 0

While TRBI->(!Eof())

    _aCheck   := {}
    _cCampo   := ""
    _cUnExpedicao  := Posicione("SB1",1,xFilial("SB1")+TRBI->D2_COD,"B1_XUNEXP")
    _nQtdMinima    := Posicione("SB1",1,xFilial("SB1")+TRBI->D2_COD,"B1_XQTDEXP") 
    _nPesoBruto    := Posicione("SB1",1,xFilial("SB1")+TRBI->D2_COD,"B1_PESBRU") 
    _nPesoLiquido  := Posicione("SB1",1,xFilial("SB1")+TRBI->D2_COD,"B1_PESO") 
    _cDescProd     := Posicione("SB1",1,xFilial("SB1")+TRBI->D2_COD,"B1_DESC") 

    _cFilial  := TRBI->D2_FILIAL
    _cDoc     := TRBI->D2_DOC
    _cSerie   := TRBI->D2_SERIE
    _cCliente := TRBI->D2_CLIENTE
    _cLoja    := TRBI->D2_LOJA
    _cFormul  := TRBI->D2_FORMUL
    _cTipo    := TRBI->D2_TIPO
    _cNome    := TRBI->A1_NOME
    _cEst     := TRBI->A1_EST
    _cPedido  := TRBI->D2_PEDIDO
    _dNfEmis  := Substr(TRBI->D2_EMISSAO,7,2)+"/"+Substr(TRBI->D2_EMISSAO,5,2)+"/"+Substr(TRBI->D2_EMISSAO,1,4)

    _lAbre    := .T.    
    
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

    oExcel:AddRow(cPlan,cTit,{_cFilial,; //01
                                 _cDoc,; //02
                               _cSerie,; //03        
                              _dNfEmis,; //04
                             _cCliente,; //05
                                _cLoja,; //06
                       AllTrim(_cNome),; //07
                                 _cEst,; //08
                              _cPedido,; //09
                 AllTrim(TRBI->D2_COD),; //10
                   AllTrim(_cDescProd),; //11
                  AllTrim(TRBI->B1_UM),; //12
                         _cUnExpedicao,; //13
                           _nQtdMinima,; //14
                        TRBI->D2_QUANT,; //15                   
      (TRBI->D2_QUANT * _nPesoLiquido),; //16
        (TRBI->D2_QUANT * _nPesoBruto),; //17 
                         _cUnExpedicao,; //18
          (TRBI->D2_QUANT/_nQtdMinima),; //19
                                    "",; //20
                                    "",; //21
                                    "",; //22
                                    "",; //23
                                    "",; //24
                                    "",; //25
                                    "",; //26
                                    "",; //27
                                    "",; //28
                                    "",; //29
                                    "",; //30
                                    ""}) //31
   
    TRBI->(dbSkip())

    If TRBI->(EOF()) .Or. TRBI->D2_DOC <> _cDoc 

        If _lAtVol

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

                oExcel:AddRow(cPlan,cTit,{  "",; //01
                                            "",; //02
                                            "",; //03        
                                            "",; //04
                                            "",; //05
                                            "",; //06
                                            "",; //07
                                            "",; //08
                                            "",; //09
                                            "",; //10
                                            "",; //11
                                            "",; //12
                                            "",; //13
                                            "",; //14
                                            "",; //15
                                            "",; //16 
                                            "",; //17
                                            "",; //18
                                            "",; //19 
                                            "",; //20
                                            "",; //21
                                            "",; //22
                                            "",; //23
                                            "",; //24
                                            "",; //25
                                            "",; //26
                                            "",; //27
                                            "",; //28
                                            "",; //29
                                            "",; //30
                                            ""}) //31

                oExcel:AddRow(cPlan,cTit,{_cFilial,; //01
                                             _cDoc,; //02
                                           _cSerie,; //03        
                                          _dNfEmis,; //04
                                         _cCliente,; //05
                                            _cLoja,; //06
                                   AllTrim(_cNome),; //07
                                             _cEst,; //08
                                          _cPedido,; //09
                                                "",; //10
                                                "",; //11
                                                "",; //12
                                                "",; //13
                                                "",; //14
                               "T  O  T  A  L  ->",; //15
                                           _nPesoL,; //16
                                           _nPesoB,; //17
                          AllTrim(_aVolumes[1][1]),; //18
                                   _aVolumes[1][2],; //19
                          AllTrim(_aVolumes[2][1]),; //20
                                   _aVolumes[2][2],; //21
                          AllTrim(_aVolumes[3][1]),; //22
                                   _aVolumes[3][2],; //23
                          AllTrim(_aVolumes[4][1]),; //24
                                   _aVolumes[4][2],; //25
                          AllTrim(_aVolumes[5][1]),; //26
                                   _aVolumes[5][2],; //27
                          AllTrim(_aVolumes[6][1]),; //28
                                   _aVolumes[6][2],; //29
                          AllTrim(_aVolumes[7][1]),; //30
                                  _aVolumes[7][2]})  //31

                oExcel:AddRow(cPlan,cTit,{  "",; //01
                                            "",; //02
                                            "",; //03        
                                            "",; //04
                                            "",; //05
                                            "",; //06
                                            "",; //07
                                            "",; //08
                                            "",; //09
                                            "",; //10
                                            "",; //11
                                            "",; //12
                                            "",; //13
                                            "",; //14
                                            "",; //15
                                            "",; //16 
                                            "",; //17
                                            "",; //18
                                            "",; //19 
                                            "",; //20
                                            "",; //21
                                            "",; //22
                                            "",; //23
                                            "",; //24
                                            "",; //25
                                            "",; //26
                                            "",; //27
                                            "",; //28
                                            "",; //29
                                            "",; //30
                                            ""}) //31

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

    EndIf

EndDo

If _lAbre
	oExcel:Activate()
	oExcel:GetXMLFile(cArqDst)
	OPENXML(cArqDst)
	oExcel:DeActivate()
Else
	MsgInfo("Não existe dados para serem impressos.", "SEM DADOS")
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
If Select("SF2") > 0
    SF2->(DbCloseArea())
EndIf
If Select("SD2") > 0
    SD2->(DbCloseArea())
EndIf

Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | OPENXML   | Autor: | QUALY         | Data: | 13/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - OPENXML                                      |
+------------+-----------------------------------------------------------+
*/

Static Function OPENXML(cArq)
	Local cDirDocs := MsDocPath()
	Local cPath	   := AllTrim(GetTempPath())

	If !ApOleClient("MsExcel")
		Aviso("Atencao", "O Microsoft Excel nao esta instalado.", {"Ok"}, 2)
	Else
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(cArq)
		oExcelApp:SetVisible(.T.)
		oExcelApp:Destroy()
	EndIf
Return

/*
+------------+------------+--------+---------------+-------+--------------+
| Programa:  | oAjustaSx1 | Autor: | QUALY         | Data: | 13/02/21     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - Perguntas                                     |
+------------+------------------------------------------------------------+
*/
Static Function oAjustaSx1()

Local _aPerg  := {}  // aRRAY 
Local _ni

Aadd(_aPerg,{"Numero Nf De ...?","mv_ch1","C",09,"G","mv_par01","","","","","","","","",0})
Aadd(_aPerg,{"Numero Nf Até ..?","mv_ch2","C",09,"G","mv_par02","","","","","","","","",0})

Aadd(_aPerg,{"Serie De  ......?","mv_ch3","C",03,"G","mv_par03","","","","","","","","",0})
Aadd(_aPerg,{"Serie Até ......?","mv_ch4","C",03,"G","mv_par04","","","","","","","","",0})

Aadd(_aPerg,{"Dt. Emissao De..?","mv_ch5","D",08,"G","mv_par05","","","","","","","","",0})
Aadd(_aPerg,{"Dt. Emissao Até.?","mv_ch6","D",08,"G","mv_par06","","","","","","","","",0})

dbSelectArea("SX1")
For _ni := 1 To Len(_aPerg)
	If !dbSeek(_cPerg+ SPACE( LEN(SX1->X1_GRUPO) - LEN(_cPerg))+StrZero(_ni,2))
		RecLock("SX1",.T.)
		SX1->X1_GRUPO    := _cPerg
		SX1->X1_ORDEM    := StrZero(_ni,2)
		SX1->X1_PERGUNT  := _aPerg[_ni][1]
		SX1->X1_VARIAVL  := _aPerg[_ni][2]
		SX1->X1_TIPO     := _aPerg[_ni][3]
		SX1->X1_TAMANHO  := _aPerg[_ni][4]
		SX1->X1_GSC      := _aPerg[_ni][5]
		SX1->X1_VAR01    := _aPerg[_ni][6]
		SX1->X1_DEF01    := _aPerg[_ni][7]
		SX1->X1_DEF02    := _aPerg[_ni][8]
		SX1->X1_DEF03    := _aPerg[_ni][9]
		SX1->X1_DEF04    := _aPerg[_ni][10]
		SX1->X1_DEF05    := _aPerg[_ni][11]
		SX1->X1_F3       := _aPerg[_ni][12]
		SX1->X1_CNT01    := _aPerg[_ni][13]
		SX1->X1_VALID    := _aPerg[_ni][14]
		SX1->X1_DECIMAL  := _aPerg[_ni][15]
		MsUnLock()
	EndIf
Next _ni

Return
// fim
/*/{Protheus.doc} EQVldAlt
Valida recalculo de Peso e Volume peloPonto de Entrada
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 14/10/2021
@param nTipo, numeric,1 = Volume / Especie  2 = Peso Liquido e Peso Bruto
@return Logical, Seguindo o processo
/*/
Static Function EQVldAlt(nTipo)

	Local lRet 		:= .T.

	Local cMVEQAVol	:= GetMv("MV_XEQAVOL",,"") // Indica Operações que não serão considerados para recalculo de volume
	Local cMVEQAPes	:= GetMv( "MV_XEQAPES",, "")  // Indica Operações que não serão considerados para recalculo de peso
	Local aAreaSC5 	:= SC5->(GetArea())

	SC5->(dbSetOrder(1))
	If SC5->(dbSeek(xFilial("SC5")+SC9->C9_PEDIDO))

		If nTipo == 1 .And. SC5->C5_XOPER $ cMVEQAVOL
			lRet := .F.
		ElseIf nTipo == 2 .And. SC5->C5_XOPER $ cMVEQAPES
			lRet := .F.
		Endif

	EndIf

	RestArea(aAreaSC5)

Return lRet






