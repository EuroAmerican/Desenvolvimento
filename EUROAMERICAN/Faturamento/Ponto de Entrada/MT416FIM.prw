#Include "Totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#include "tryexception.ch"

#define ENTER chr(13) + chr(10)

/*/{Protheus.doc} MT416FIM
PE após efetivação orçamento para gravar grupo no Pedido
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 22/10/2021
@history Tratamento para gravar revisão de comissão - 17/07/2022 - Fábio Carneiro dos Santos   
@History Ajustado em 09/09/2022 tratamento referente a não considerar comissão se o item estiver zerado - Fabio carneiro dos Santos
@return Character, sem retorno

/*/
User Function MT416FIM()

Local aArea		 := GetArea()
Local aAreaCK    := SCK->(GetArea())
Local aAreaCJ	 := SCJ->(GetArea())
Local aAreaC5    := SC5->(GetArea())
Local aAreaC6	 := SC6->(GetArea())
Local aAreaB1	 := SB1->(GetArea())
Local aAreaA1	 := SA1->(GetArea())
Local aAreaF4	 := SF4->(GetArea())
Local aAreaA3	 := SA3->(GetArea())
Local _cGerFin   := "" 
Local _cCodProd  := ""
Local cPgCliente := "" 
Local cRepreClt  := ""
Local cPgvend1   := ""
Local cVend1     := ""
Local _cNumPv    := ""
Local _nVlComis1 := 0
Local _nVlTotal  := 0
Local _nPercCli  := 0
Local _cComRev   := ""
Local _cTabCom   := ""
Local _cTipoCom  := ""
Local _cQuery    := "" 
Local _nCliente  := 0
Local _nProduto  := 0
Local _nVendedor := 0
Local _nLidos    := 0 
Local _aLidos    := {} 
Local cFilComis  := GetMv("QE_FILCOM")
/*---------------------------------------------------------------------------------------------+
| INICIO    : Projeto produtos especiais - Mario antonacio - 22/10/2021                        |
+----------------------------------------------------------------------------------------------+
| ALTERAÇÃO : Projeto Comissão especifico QUALY - 17/07/2022 - Fabio Carneiro                  |
+----------------------------------------------------------------------------------------------+
| 1 - Quando for incluir ou alterar um orçamento pega a ultima revisão que estver no cadastro  |
|     de produto contento % de comissão, ultima revisão e tabela;                              |
| 2 - Se a filial estiver preenchida no parametro QE_FILCOM, entra na regra para fazer as      | 
|     devidas validações.                                                                      |
| 3 - Se o produto na PAA estiver com a comissão zerada não entra na regra para calcular a     | 
|     comissão em 09/09/2022 - Fabio carneiro.                                                 |
+----------------------------------------------------------------------------------------------*/
SCK->(dbSetOrder(1))
If SCK->(dbSeek(xFilial("SCK")+SCJ->CJ_NUM))
   
    While SCK->(!EOF()) .and. SCK->CK_NUM == SCJ->CJ_NUM
        
        If !Empty(SCK->CK_NUMPV)
            SC6->(dbSetOrder(2))
            If SC6->(dbSeek(xFilial("SC6")+SCK->CK_PRODUTO+SCK->CK_NUMPV))

                SB1->(dbSetOrder(1))
                SB1->(dbSeek(xFilial("SB1")+SCK->CK_PRODUTO))

                SBM->(dbSetOrder(1))
                SBM->(dbSeek(xFilial("SBM")+SB1->B1_GRUPO))

                RecLock("SC6",.F.)
                SC6->C6_XGRPESP:=SB1->B1_GRUPO
                SC6->C6_XGRPDSC:=SBM->BM_DESC
                SC6->(MsUnLock())
                /*---------------------------------------------------------+
                | INICIO PROJETO REVISÃO DE COMISSÃO - 17/07/2022          |
                +---------------------------------------------------------*/
                cPgCliente  := Posicione("SA1",1,xFilial("SA1")+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA,"A1_XPGCOM")  // 1 = Não / 2 = Não
                cRepreClt   := Posicione("SA3",1,xFilial("SA3")+SCJ->CJ_VEND1,"A3_XCLT")                   // 1 = Não / 2 = Não
                cPgvend1    := Posicione("SA3",1,xFilial("SA3")+SCJ->CJ_VEND1,"A3_XPGCOM")                 // 1 = Não / 2 = Não
                cVend1      := Posicione("SA3",1,xFilial("SA3")+SCJ->CJ_VEND1,"A3_COD")                    // Codigo do vendedor 
                _nPercCli   := Posicione("SA1",1,xFilial("SA1")+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA,"A1_XCOMIS1") // Percentual de Comissão no Cliente
                _cNumPv     := SCK->CK_NUMPV 
                /*-----------------------------------------------------------+
                | Se a filial estiver no parametro QE_FIMCOM, entra na regra |    
                +-----------------------------------------------------------*/
                If cfilAnt $ cFilComis 

                    _cGerFin    := Posicione("SF4",1,xFilial("SF4")+SCK->CK_TES,"F4_DUPLIC")     // verifica se a Tes gera financeiro
                    _cCodProd   := SCK->CK_PRODUTO                                                // Codigo do Produto 
                    _cComRev    := Posicione("SB1",1,xFilial("SB1")+SCK->CK_PRODUTO,"B1_XREVCOM") // Ultima revsão cadastrada na tabela PAA
                    _cTabCom    := Posicione("SB1",1,xFilial("SB1")+SCK->CK_PRODUTO,"B1_XTABCOM") // Ultimo codigo de tabela cadastrada na tabela PAA

                    If Select("WK_PAA") > 0
                        WK_PAA->(DbCloseArea())
                    EndIf

                    _cQuery := "SELECT * FROM "+RetSqlName("PAA")+" AS PAA "
                    _cQuery += "WHERE PAA_FILIAL = '"+xFilial("PAA")+"' ""
                    _cQuery += " AND PAA_COD = '"+AllTrim(SCK->CK_PRODUTO)+"'  " 
                    _cQuery += " AND PAA_REV = '"+AllTrim(_cComRev)+"'  " 
                    _cQuery += " AND PAA_CODTAB = '"+AllTrim(_cTabCom)+"'  " 
                    _cQuery += " AND PAA_MSBLQL = '2' " 
                    _cQuery += " AND PAA.D_E_L_E_T_ = ' ' " 
                    _cQuery += " ORDER BY  PAA_DTVIG1, PAA_DTVIG2 " 

                    TcQuery _cQuery ALIAS "WK_PAA" NEW

                    WK_PAA->(DbGoTop())

                    While WK_PAA->(!Eof())
                        
                        Aadd(_aLidos,{WK_PAA->PAA_COD,;  // 01
                                    WK_PAA->PAA_DTVIG1,; // 02
                                    WK_PAA->PAA_DTVIG2,; // 03
                                    WK_PAA->PAA_CODTAB,; // 04 
                                    WK_PAA->PAA_COMIS1,; // 05
                                    WK_PAA->PAA_REV})    // 06

                        WK_PAA->(DbSkip())

                    EndDo

                    If  Len(_aLidos)  > 0

                        For _nLidos:= 1 To Len(_aLidos) 
                            /*---------------------------------------------------------+
                            | Se gera financeiro prossegue as validações das comissões |    
                            +---------------------------------------------------------*/
                            If _cGerFin == "S" .And. _aLidos[_nlidos][01] == _cCodProd .And. _aLidos[_nlidos][06] == _cComRev 
                                    
                                If cPgCliente == "2" .And. _nPercCli > 0

                                    If _aLidos[_nlidos][05] > 0
                                        _nCliente++    
                                        Reclock("SC6",.F.)
                                        SC6->C6_XTABCOM := SCK->CK_XTABCOM
                                        SC6->C6_XCOM1   := SCK->CK_XCOM1
                                        SC6->C6_COMIS1  := _nPercCli
                                        SC6->C6_COMIS2  := 0
                                        SC6->C6_COMIS3  := 0
                                        SC6->C6_COMIS4  := 0
                                        SC6->C6_COMIS5  := 0
                                        SC6->C6_XREVCOM := SCK->CK_XREVCOM 
                                        SC6->C6_XDTRVC  := SCK->CK_XDTRVC
                                        SC6->C6_XTPCOM  := "01" // CLILENTE 
                                        SC6->(Msunlock())
                                        _nVlComis1  += Round( (SCK->CK_VALOR * _nPercCli) / 100,2)
                                        _nVlTotal   += SCK->CK_VALOR
                                        _cTipoCom   := "01" // CLILENTE
                                    
                                    Else 

                                        Reclock("SC6",.F.)
                                        SC6->C6_XTABCOM := SCK->CK_XTABCOM
                                        SC6->C6_XCOM1   := 0
                                        SC6->C6_COMIS1  := 0
                                        SC6->C6_COMIS2  := 0
                                        SC6->C6_COMIS3  := 0
                                        SC6->C6_COMIS4  := 0
                                        SC6->C6_COMIS5  := 0
                                        SC6->C6_XREVCOM := SCK->CK_XREVCOM 
                                        SC6->C6_XDTRVC  := SCK->CK_XDTRVC
                                        SC6->C6_XTPCOM  := "01" // Cliente 
                                        SC6->(Msunlock())
                                        _nVlComis1  += 0
                                        _nVlTotal   += 0
                                        _cTipoCom   := "01" // Cliente Zerado
                                    
                                    EndIf

                                /*---------------------------------------------------------+
                                |  Não / Sim / sim  -  Paga comissão pelo Produto          | 
                                +---------------------------------------------------------*/
                                ElseIf cRepreClt == "1" .And. cPgCliente == "2" .And. cPgvend1 == "2" .And.  _nPercCli <= 0

                                    If _aLidos[_nlidos][05] > 0
                                        _nProduto++
                                        Reclock("SC6",.F.)
                                        SC6->C6_XTABCOM := SCK->CK_XTABCOM
                                        SC6->C6_XCOM1   := SCK->CK_XCOM1
                                        SC6->C6_COMIS1  := SCK->CK_COMIS1
                                        SC6->C6_COMIS2  := 0
                                        SC6->C6_COMIS3  := 0
                                        SC6->C6_COMIS4  := 0
                                        SC6->C6_COMIS5  := 0
                                        SC6->C6_XREVCOM := SCK->CK_XREVCOM 
                                        SC6->C6_XDTRVC  := SCK->CK_XDTRVC
                                        SC6->C6_XTPCOM  := "02" // PRODUTO 
                                        SC6->(Msunlock())
                                        _nVlComis1  += Round( (SCK->CK_VALOR * SCK->CK_COMIS1) / 100,2)
                                        _nVlTotal   += SCK->CK_VALOR
                                        _cTipoCom   := "02" // PRODUTO

                                    Else 

                                        Reclock("SC6",.F.)
                                        SC6->C6_XTABCOM := SCK->CK_XTABCOM
                                        SC6->C6_XCOM1   := 0
                                        SC6->C6_COMIS1  := 0
                                        SC6->C6_COMIS2  := 0
                                        SC6->C6_COMIS3  := 0
                                        SC6->C6_COMIS4  := 0
                                        SC6->C6_COMIS5  := 0
                                        SC6->C6_XREVCOM := SCK->CK_XREVCOM 
                                        SC6->C6_XDTRVC  := SCK->CK_XDTRVC
                                        SC6->C6_XTPCOM  := "02" // PRODUTO 
                                        SC6->(Msunlock())
                                        _nVlComis1  += 0
                                        _nVlTotal   += 0
                                        _cTipoCom   := "02" // PRODUTO

                                    EndIf
                                /*--------------------------------------------------------------+
                                | Sim / Sim / sim -  paga comissão pelo percentual do vendedor  |           
                                +--------------------------------------------------------------*/
                                ElseIf cRepreClt == "2" .And. cPgCliente == "2" .And. cPgvend1 == "2" .And.  _nPercCli <= 0
                                                        
                                    If _aLidos[_nlidos][05] > 0
                                        _nVendedor++
                                        Reclock("SC6",.F.)
                                        SC6->C6_XTABCOM := SCK->CK_XTABCOM
                                        SC6->C6_XCOM1   := SCK->CK_XCOM1
                                        SC6->C6_COMIS1  := Posicione("SA3",1, xFilial("SA3+")+cVend1,"A3_COMIS")
                                        SC6->C6_COMIS2  := 0
                                        SC6->C6_COMIS3  := 0
                                        SC6->C6_COMIS4  := 0
                                        SC6->C6_COMIS5  := 0
                                        SC6->C6_XREVCOM := SCK->CK_XREVCOM 
                                        SC6->C6_XDTRVC  := SCK->CK_XDTRVC
                                        SC6->C6_XTPCOM  := "03" // VENDEDOR 
                                        SC6->(Msunlock())
                                        _nVlComis1  := Posicione("SA3",1, xFilial("SA3+")+cVend1,"A3_COMIS")
                                        _cTipoCom   := "03" // VENDEDOR
                                    
                                    Else 

                                        Reclock("SC6",.F.)
                                        SC6->C6_XTABCOM := SCK->CK_XTABCOM
                                        SC6->C6_XCOM1   := 0
                                        SC6->C6_COMIS1  := 0
                                        SC6->C6_COMIS2  := 0
                                        SC6->C6_COMIS3  := 0
                                        SC6->C6_COMIS4  := 0
                                        SC6->C6_COMIS5  := 0
                                        SC6->C6_XREVCOM := SCK->CK_XREVCOM 
                                        SC6->C6_XDTRVC  := SCK->CK_XDTRVC
                                        SC6->C6_XTPCOM  := "03" // VENDEDOR 
                                        SC6->(Msunlock())
                                        _nVlComis1  += 0
                                        _cTipoCom   := "03" // VENDEDOR
                                    
                                    EndIf

                                /*--------------------------------------------------------------+
                                | Não paga comissão                                             |
                                +--------------------------------------------------------------*/
                                Else
                                    Reclock("SC6",.F.)
                                    SC6->C6_XTABCOM := SCK->CK_XTABCOM
                                    SC6->C6_XCOM1   := SCK->CK_XCOM1
                                    SC6->C6_COMIS1  := 0
                                    SC6->C6_COMIS2  := 0
                                    SC6->C6_COMIS3  := 0
                                    SC6->C6_COMIS4  := 0
                                    SC6->C6_COMIS5  := 0
                                    SC6->C6_XREVCOM := SCK->CK_XREVCOM 
                                    SC6->C6_XDTRVC  := SCK->CK_XDTRVC
                                    SC6->C6_XTPCOM  := "04" // COMISSÃO ZERADA 
                                    SC6->(Msunlock())
                                    _nVlComis1  += 0
                                    _nVlTotal   += 0
                                    _cTipoCom   := "04" // COMISSÃO ZERADA
                            
                                EndIf
                        
                            EndIf
                    
                        Next _nLidos

                    EndIf    
                
                EndIf                    
                    
            EndIf
                
        EndIf

       SCK->(dbSkip())

    EndDo   
    /*---------------------------------------------------------------------------------+
    | Será gravado no cabeçalho do orçamento os tipos e os percentuais de comissão     |
    +---------------------------------------------------------------------------------*/
    DbSelectArea("SC5")
    SC5->(DbSetorder(1))
    If SC5->(MsSeek(xFilial("SC5")+_cNumPv))
        /*----------------------------------------------------------------------------------+
        | Sim e percentual preenchido no cadastro do cliente - Paga comissão pelo Cliente   | 
        +----------------------------------------------------------------------------------*/
        If cPgCliente == "2" .And. _nPercCli > 0
            If _nCliente > 0
                RecLock('SC5',.F.)
                SC5->C5_COMIS1  := _nPercCli
                SC5->C5_COMIS2  := 0
                SC5->C5_COMIS3  := 0 
                SC5->C5_COMIS4  := 0 
                SC5->C5_COMIS5  := 0 
                SC5->C5_XTPCOM  := _cTipoCom 
                SC5->( MsUnlock() )
            Else 
                RecLock('SC5',.F.)
                SC5->C5_COMIS1  := 0
                SC5->C5_COMIS2  := 0
                SC5->C5_COMIS3  := 0 
                SC5->C5_COMIS4  := 0 
                SC5->C5_COMIS5  := 0 
                SC5->C5_XTPCOM  := _cTipoCom 
                SC5->( MsUnlock() )
            EndIf    
        /*---------------------------------------------------------+
        |  Não / Sim / sim  -  Paga comissão pelo Produto          | 
        +---------------------------------------------------------*/
        ElseIf cRepreClt == "1" .And. cPgCliente == "2" .And. cPgvend1 == "2" .And. _nPercCli <= 0
            If _nProduto > 0
                RecLock('SC5',.F.)
                SC5->C5_COMIS1  := Round(((_nVlComis1 / _nVlTotal) * 100),2)
                SC5->C5_COMIS2  := 0
                SC5->C5_COMIS3  := 0 
                SC5->C5_COMIS4  := 0 
                SC5->C5_COMIS5  := 0 
                SC5->C5_XTPCOM  := _cTipoCom 
                SC5->( MsUnlock() )
            Else 
                RecLock('SC5',.F.)
                SC5->C5_COMIS1  := 0
                SC5->C5_COMIS2  := 0
                SC5->C5_COMIS3  := 0 
                SC5->C5_COMIS4  := 0 
                SC5->C5_COMIS5  := 0 
                SC5->C5_XTPCOM  := _cTipoCom 
                SC5->( MsUnlock() )
            EndIf    
        /*--------------------------------------------------------------+
        | Sim / Sim / sim -  paga comissão pelo percentual do vendedor  |           
        +--------------------------------------------------------------*/
        ElseIf cRepreClt == "2" .And. cPgCliente == "2" .And. cPgvend1 == "2" .And. _nPercCli <= 0
            If _nVendedor > 0
                RecLock('SC5',.F.)
                SC5->C5_COMIS1  := _nVlComis1
                SC5->C5_COMIS2  := 0
                SC5->C5_COMIS3  := 0 
                SC5->C5_COMIS4  := 0 
                SC5->C5_COMIS5  := 0 
                SC5->C5_XTPCOM  := _cTipoCom 
                SC5->( MsUnlock() )
            Else 
                RecLock('SC5',.F.)
                SC5->C5_COMIS1  := 0
                SC5->C5_COMIS2  := 0
                SC5->C5_COMIS3  := 0 
                SC5->C5_COMIS4  := 0 
                SC5->C5_COMIS5  := 0 
                SC5->C5_XTPCOM  := _cTipoCom 
                SC5->( MsUnlock() )
            EndIf    
        /*--------------------------------------------------------------+
        | Não paga comissão                                             |
        +--------------------------------------------------------------*/
        Else 
            RecLock('SC5',.F.)
            SC5->C5_COMIS1  := 0
			SC5->C5_COMIS2  := 0
			SC5->C5_COMIS3  := 0 
			SC5->C5_COMIS4  := 0 
			SC5->C5_COMIS5  := 0 
            SC5->C5_XTPCOM  := _cTipoCom 
            SC5->( MsUnlock() )
        EndIf 

    EndIf

EndIf 

_nCliente  := 0
_nProduto  := 0
_nVendedor := 0

RestArea(aAreaCK)
RestArea(aAreaCJ)
RestArea(aAreaC5)
RestArea(aAreaC6)
RestArea(aAreaB1)
RestArea(aAreaA1)
RestArea(aAreaF4)
RestArea(aAreaA3)
RestArea(aArea)

Return NIL
