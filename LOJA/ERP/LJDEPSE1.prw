#Include 'Totvs.ch'

/*/{Protheus.doc} LJDEPSE1
 após a gravação do título a receber na tabela SE1,
 possibilitando que sejam realizadas gravações complementares no titulo inserido.
@type function ponto de Entrada
@version  1.00
@author mario.antonaccio
@since 02/11/2021
@return Character, Sem rtorno definido
/*/
User Function LJDEPSE1()

    Local aArea    := GetArea()
    Local aAreaSD2 := SD2->(GetArea())
    Local aAreaSF2 := SF2->(GetArea())
    Local cHora    := Substr(TIME(),1,5)
    Local nPesoB   := 0
    Local nPesoL   := 0
    Local aVolumes := {{},{},{}}
    Local nVolumes := 0

    /*
    Caso seja realizada uma venda com as seguintes formas de pagamento:
    Entrada a vista em dinheiro, 1 Parcela em CH e 3 Parcelas em CC.

    O Ponto de Entrada será acionado 5 vezes:
    na primeira chamada vem posicionado no registro referente ao SE1->E1_TIPO = R$,
    na segunda posicionado no SE1->E1_TIPO = CH,
    na terceira chamada no SE1->E1_TIPO = CC e SE1->E1_PARCELA = A,
    na sequência será chamado mais duas vezes, para as Parcelas B e C.

    */
    If SE1->E1_TIPO $ "PX/BOL/BO"

        SL1->(dbSetOrder(2))
        If SL1->(dbSeek(xFilial("SL1")+SE1->E1_PREFIXO+SE1->E1_NUM))

            SA1->(dbSetOrder(1))
            If SA1->(dbSeek(xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA))
                RecLock("SE1",.F.)
                SE1->E1_NOMCLI:=SA1->A1_NREDUZ
                SE1->E1_NUMRA:=SA1->A1_COD+SA1->A1_LOJA
                MsUnLock()
            END
            /// Grava No. PDV quando for NF para permitir Exclusao da NF
            RecLock("SL1",.F.)
            SL1->L1_PDV:=SLG->LG_PDV
            MsUnLock()
        END
    End

    //Grava Hora
    If SF2->(FieldPos("F2_HORA"))<>0 .And. Empty(SF2->F2_HORA)
        RecLock("SF2",.F.)
        SF2->F2_HORA := cHora
        MsUnlock()
    EndIf

    RestArea(aAreaSF2)
    RestArea(aAreaSD2)
    RestArea(aArea)

Return
