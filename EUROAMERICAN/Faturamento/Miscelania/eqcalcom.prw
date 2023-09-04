#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"

#define ENTER chr(13) + chr(10)
#define CTRL chr(13) + chr(10)

/*/{Protheus.doc} EQCALCOM
Rotina de Calculo de comissao conforme MIQE44 Especifica√ß√£o de Personaliza√ß√£o
Projeto: Rotina para C√°lculo de Comiss√£o conforme Margem de Produto
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 06/12/2021
@return Character, sem retorno definido
@History Foi incluido a condiÁıes de pagamento e a descriÁ„o em 05/10/2022 - Fabio carneiro dos Santos 
/*/
User Function EQCALCOM()

    Private cCadastro := "Controle de Comissoes"
    Private cPerg     := "EQCALCOM"
    Private cPergR    := "EQCALCOMR"
    Private cTitulo   := "Controle de Comissoes"
    Private oBrowse
    Private aNotaVd2:={}

    //Inst√¢nciando FWMBrowse - Somente com dicion√°rio de dados
    oBrowse := FWMBrowse():New()

    If cFilant<>"0200"
        Alert("Rotina disponivel apenas para Euro")
        Return
    End

    //Se arquivo vazio - primeiro calculo -  executa direto a rotna de calculo
    Z02->(dbGoTop())
    If Z02->(BOF())  .or. Z02->(EOF())
        U_EQCALCM1()
    End

    //Setando a tabela de cadastro de comissoes
    oBrowse:SetAlias("Z02")

    //Setando a descri√ß√£o da rotina
    oBrowse:SetDescription(cTitulo)

    //Legendas
    oBrowse:AddLegend( 'Z02->Z02_OCORR == "3"', "BLACK" , "Desconto maior 5%" )
    oBrowse:AddLegend( 'Z02->Z02_OCORR == "1"', "YELLOW", "Sem Custo" )
    oBrowse:AddLegend( 'Z02->Z02_OCORR == "2"', "RED"   ,    "Sem Comissao" )
    oBrowse:AddLegend( 'Z02->Z02_OCORR == "0"', "GREEN" ,   "Sem Ocorrencia" )

    //Ativa a Browse
    oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Descri√ß√£o dos Botoes de tela
@type function Tela
@version  1.00
@author mario.antonaccio
@since 06/12/2021
@return array, op√ß√µes de fun√ß√µes
*/
Static Function MenuDef()

    Local aMenu := {}

    ADD OPTION aMenu TITLE 'Pesquisar' 	ACTION 'AxPesqui'		OPERATION 1 ACCESS 0
    ADD OPTION aMenu TITLE 'Visualizar' ACTION 'AxVisual'	    OPERATION 2 ACCESS 0
    ADD OPTION aMenu TITLE 'Calculo' 	ACTION 'U_EQCALCM1()'	OPERATION 3 ACCESS 0
    ADD OPTION aMenu TITLE 'Relatorio' 	ACTION 'U_EQCALCM5()'	OPERATION 4 ACCESS 0
    ADD OPTION aMenu TITLE 'Legenda'     ACTION 'U_EQCALCLG()'  OPERATION 6 ACCESS 0 //OPERATION X

Return( aMenu )

/*/{Protheus.doc} EQCALCM1
Paramtrizacao do Calculo de Comsisao
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 06/12/2021
@return Character, sem retorno definido
/*/
User Function EQCALCM1()

    Local aButtons  := {}
    Local aSays     := {}
    Local cTitoDlg  := "Rotina para C·lculo de Comiss„o"
    Local nOpca     := 0
    Private aQuery := {}

    //Pergunta 01
    aAdd(aSays, "Esta rotina tem o objetivo de gerar o c·lculo de comiss„o ")
    aAdd(aSays, "conforme definiÁıes dadas")

    aAdd(aButtons,{5, .T., {|o| Pergunte(cPerg, .T.)}})
    aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
    aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

    FormBatch(cTitoDlg, aSays, aButtons)
    If nOpca == 1
        Pergunte(cPerg, .F.)
        Processa( {|| EQCALCOM2() }, "Aguarde...", "Efetuando Calculo ...",.F.)
    EndIf

Return

/*/{Protheus.doc} EQCALCOM2
Efetua o calculo da Comissao Vendedor 1
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 06/12/2021
@return Character, sem retorno definido
/*/
Static Function EQCALCOM2()
    Local nCusMed  := 0
    Local nPercCom := 0
    Local nPercPG  := 0
    Local nPontosAT
    Local nPontosDE
    Local nTotReg
    Local nCalcMg:=0
    Local nRegGer:=0
    Private _FCOM  := GetNextAlias()  //Arquivo filtrado do SE5
    Private _FSD2  := GetNextAliass()  // Arquivo temporario do SD2 -
    Private cVar

    // Antes do Calculo, √© necessario apagar todas as informa√ß√µes de calculos previamente registradas
    //para os parametros mencionados evitando Duplicidade
    TCSqlExec("DELETE "+;
              " FROM "+RetSQlName("Z02")+;
              " WHERE "+;
              " Z02_DTPAGO >='"+DTOS(mv_par01)+"' AND Z02_DTPAGO <='"+DTOS(mv_par02)+"'"+;
              " AND Z02_VEND >='" +mv_par03+"' AND Z02_VEND <='"+mv_par04+"'"+;
              " AND Z02_NOTA >='" +mv_par05+"' AND Z02_NOTA <='"+mv_par06+"'")    
    //Fim Limpeza de Registros

    BeginSql Alias _FCOM
        COLUMN E5_DATA as Date
        COLUMN F2_EMISSAO as Date
        SELECT
            SE5.E5_FILIAL,
            SE5.E5_DATA,
            SE5.E5_PREFIXO,
            SE5.E5_NUMERO,
            SE5.E5_PARCELA,
            SE5.E5_CLIFOR,
            SE5.E5_LOJA,
            SE5.E5_VALOR,
            SE5.E5_TIPODOC,
            SE5.E5_VLDESCO,
            SF2.F2_VEND1,
            SF2.F2_VEND2,
            SF2.F2_EMISSAO,
            SF2.F2_VALBRUT,
            SA3.A3_TIPO as TIPO1
        FROM
            %Table:SE5% SE5
        INNER JOIN %Table:SF2% SF2
        ON SE5.E5_FILIAL = SF2.F2_FILIAL
            AND SE5.E5_NUMERO = SF2.F2_DOC
            AND SE5.E5_PREFIXO = SF2.F2_SERIE
            AND SE5.E5_CLIFOR = SF2.F2_CLIENTE
            AND SE5.E5_LOJA = SF2.F2_LOJA
            AND SF2.%NotDel%
        INNER JOIN %Table:SA3% SA3
        ON SA3.%NotDel%
            AND SF2.F2_VEND1 = SA3.A3_COD
            AND SA3.A3_XNCALC = 'S'
        WHERE
            SE5.E5_FILIAL = %Exp:cFilAnt%
            AND SE5.E5_DATA >= %Exp:DTOS(mv_par01)%
            AND SE5.E5_DATA <= %Exp:DTOS(mv_par02)%
            AND SE5.E5_NUMERO >= %Exp:mv_par05%
            AND SE5.E5_NUMERO <= %Exp:mv_par06%
            AND SE5.%NotDel%
            AND SE5.E5_RECPAG = 'R'
            AND SE5.E5_TIPO = 'NF'
            AND SE5.E5_TIPODOC IN ('VL')
            AND SE5.E5_CLIFOR <> '036068'
            AND SF2.F2_VEND1 >= %Exp:mv_par03%
            AND SF2.F2_VEND1 <= %Exp:mv_par04%
        ORDER BY
            SE5.E5_PREFIXO,
            SE5.E5_NUMERO,
            SE5.E5_PARCELA,
            SE5.E5_CLIFOR,
            SE5.E5_LOJA
    EndSql

    aQuery:=GetLastQuery()

    nTotReg := Contar((_FCOM),"!EOF()")
    (_FCOM)->(DbGoTop())

    ProcRegua(nTotReg)

    While (_FCOM)->(!EOF())

        IncProc()

        //Se Tiver valor 0 (???) pula
        If (_FCOM)->E5_VALOR == 0
            (_FCOM)->(dbSkip())
            Loop
        End

        //Calculo Percentual do Valor pago sobre o valot total da NF
        nPercPG:=Round((_FCOM)->E5_VALOR / (_FCOM)->F2_VALBRUT,3)

        If Select((_FSD2)) > 0
            (_FSD2)->(dbCloseArea())
        End

        BeginSql Alias _FSD2
            COLUMN D2_EMISSAO as Date
            SELECT
                SD2.D2_FILIAL,
                SD2.D2_CLIENTE,
                SD2.D2_EMISSAO,
                SD2.D2_LOJA,
                SD2.D2_COD,
                SD2.D2_DOC,
                SD2.D2_SERIE,
                SUM(SD2.D2_QUANT) AS D2_QUANT,
                SUM(SD2.D2_VALBRUT) AS D2_VALBRUT,
                SUM(SD2.D2_VALICM) AS D2_VALICM,
                SUM(SD2.D2_ICMSRET) AS D2_ICMSRET,
                SUM(SD2.D2_VALIPI) AS D2_VALIPI,
                SUM(SD2.D2_VALIMP6) AS D2_VALIMP6,
                SUM(SD2.D2_VALIMP5) AS D2_VALIMP5,
                SUM(SD2.D2_VALFRE) AS D2_VALFRE,
                MAX(SB9.B9_CM1) AS B9_CM1
            FROM
                %Table:SD2% SD2
            INNER JOIN %Table:SB9% SB9
            ON SD2.D2_FILIAL = SB9.B9_FILIAL
                AND SD2.D2_COD = SB9.B9_COD
                AND SD2.D2_LOCAL = SB9.B9_LOCAL
                AND SB9.B9_DATA = %Exp:LastDate((_FCOM)->F2_EMISSAO)%
                AND SB9.%NotDel%
            WHERE
                SD2.%NotDel%
                AND SD2.D2_FILIAL = %Exp:(_FCOM)->E5_FILIAL%
                AND SD2.D2_DOC = %Exp:(_FCOM)->E5_NUMERO%
                AND SD2.D2_SERIE = %Exp:(_FCOM)->E5_PREFIXO%
                AND SD2.D2_CLIENTE = %Exp:(_FCOM)->E5_CLIFOR%
                AND SD2.D2_LOJA = %Exp:(_FCOM)->E5_LOJA%
                AND SD2.D2_TIPO = 'N'
            GROUP BY
                SD2.D2_FILIAL,
                SD2.D2_CLIENTE,
                SD2.D2_EMISSAO,
                SD2.D2_LOJA,
                SD2.D2_COD,
                SD2.D2_DOC,
                SD2.D2_SERIE
        EndSql
        aQuery:=GetLastQuery()

        //Itens
        While (_FSD2)->(!EOF())

            // Verifica o Custo Medio do produto conforme o mes de emissao da NF -(Query)
            nCusmed:=((_FSD2)->D2_QUANT * (_FSD2)->B9_CM1 ) * nPercPG

            // Calcula Venda Liquida
            nVdaLiq:=((_FSD2)->D2_VALBRUT - (_FSD2)->D2_VALICM - (_FSD2)->D2_ICMSRET -  (_FSD2)->D2_VALIMP6 - (_FSD2)->D2_VALIMP5)*nPercPG

            //Calcula Margem em Valor
            nCalcMg:=nVdaLiq -  nCusMed

            //ApuraÁaı do valor de margem
            nMargem:=  (nCalcMg/nVdaLiq) * 100

            // Verifica o Valor de % conforme Margem
            Z01->(dbSetOrder(1))
            Z01->(dbGotop())
            While Z01->(!EOF())
                If nMargem >= Z01->Z01_FXINI .and. nMargem <= Z01->Z01_FXFIM
                    nPercCom:=Z01->Z01_PERCOM
                    nPontosDE:=Z01->Z01_PONTDE
                    nPontosAT:=Z01->Z01_PONTAT
                    Exit
                End
                Z01->(dbSkip())
            End

            //Se Tem Mais de Um Vendedor, Calcula % diferenciado
            If (_FCOM)->TIPO1 == "I"
                nPercCom :=0.5
            End

            nValCom1:=((_FSD2)->D2_VALBRUT * nPercPG ) * (nPercCom/100)
            lVend2:=.F.
            If !Empty((_FCOM)->F2_VEND2)
                SA3->(dbSetOrder(1))
                SA3->(dbSeek(xFilial("SA3")+(_FCOM)->F2_VEND2))

                If SA3->A3_XNCALC <> 'S'
                    nValCom2:=0
                    nPercCom2:=0
                    lVend2:=.F.
                Else
                    lVend2:=.T.
                    cTipo2:=SA3->A3_TIPO
                        If nPercCom > 1
                            nPercCom:=nPercCom  - 0.5
                            nPercCom2:=0.5 
                        Else  // Se for menor ou igual a 1 entao divide
                            nPercCom:=nPercCom / 2
                            nPercCom2:=nPercCom
                        End
                End                     
            End

            If lVend2
                nValCom2:=((_FSD2)->D2_VALBRUT * nPercPG ) * (nPercCom2/100)
                //Grava Vend 2
                RecLock("Z02",.T.)
                Z02->Z02_FILIAL := (_FCOM)->E5_FILIAL
                Z02->Z02_VEND   := (_FCOM)->F2_VEND2
                Z02->Z02_TPVEND := cTipo2
                Z02->Z02_CLIENT := (_FSD2)->D2_CLIENTE
                Z02->Z02_LOJA   := (_FSD2)->D2_LOJA
                Z02->Z02_PRODUT := (_FSD2)->D2_COD
                Z02->Z02_QUANT  := (_FSD2)->D2_QUANT
                Z02->Z02_TOTITM := (_FSD2)->D2_VALBRUT * nPercPG
                Z02->Z02_ICMS   := (_FSD2)->D2_VALICM  * nPercPG  // Ja proporcionaliza o ICMS conforme %
                Z02->Z02_ST     := (_FSD2)->D2_ICMSRET * nPercPG  // Ja proporcionaliza o ST conforme %
                Z02->Z02_VALIPI := (_FSD2)->D2_VALIPI  * nPercPG  // Ja proporcionaliza o IPI conforme % - Nao incluso em Calculo
                Z02->Z02_PIS    := (_FSD2)->D2_VALIMP6 * nPercPG  // Ja proporcionaliza PIS
                Z02->Z02_COFINS := (_FSD2)->D2_VALIMP5 * nPercPG  // Ja proporcionaliza COFINS
                Z02->Z02_FRETE  := (_FSD2)->D2_VALFRE  * nPercPG  // Proporcionaliza Frete com %  -Implantando GFE alterar
                Z02->Z02_VLRPAG := (_FCOM)->E5_VALOR
                Z02->Z02_DTPAGO := (_FCOM)->E5_DATA
                Z02->Z02_DTEMIS := (_FSD2)->D2_EMISSAO
                Z02->Z02_NOTA   := (_FSD2)->D2_DOC
                Z02->Z02_SERIE  := (_FSD2)->D2_SERIE
                Z02->Z02_PARCEL := (_FCOM)->E5_PARCELA
                Z02->Z02_TIPONF := If((_FCOM)->E5_TIPODOC $ "CP","Z","V")
                Z02->Z02_DTCALC := dDataBase
                Z02->Z02_CUSTO  := nCusMed
                Z02->Z02_BASCOM := (_FCOM)->E5_VALOR              //nVdaLiq  //Venda Liquida para efeito de calculo
                Z02->Z02_MARGEM := nMargem
                Z02->Z02_PERCOM := nPercCom2
                Z02->Z02_VALCOM := nValCom2
                Z02->Z02_PONTDE := nPontosDE
                Z02->Z02_PONTAT := nPontosAT
                Z02->Z02_VLDESC := (_FCOM)->E5_VLDESCO
                Z02->Z02_VDSEQ  := "2'
                Z02->Z02_PERPAG := nPercPG
                If nCusmed == 0
                    Z02->Z02_OCORR  :="1"
                ElseIf nValCom2 == 0
                    Z02->Z02_OCORR  :="2"
                ElseIf (((_FCOM)->E5_VLDESCO / (_FCOM)->E5_VALOR) * 100)  > 5
                    Z02->Z02_OCORR  :="3"
                Else
                    Z02->Z02_OCORR  :="0"
                End
                MsUnLock()
                nRegGer++
            End

            //Grava Vend 1
            RecLock("Z02",.T.)
            Z02->Z02_FILIAL := (_FCOM)->E5_FILIAL
            Z02->Z02_VEND   := (_FCOM)->F2_VEND1
            Z02->Z02_TPVEND := (_FCOM)->TIPO1
            Z02->Z02_CLIENT := (_FSD2)->D2_CLIENTE
            Z02->Z02_LOJA   := (_FSD2)->D2_LOJA
            Z02->Z02_PRODUT := (_FSD2)->D2_COD
            Z02->Z02_QUANT  := (_FSD2)->D2_QUANT
            Z02->Z02_TOTITM := (_FSD2)->D2_VALBRUT * nPercPG
            Z02->Z02_ICMS   := (_FSD2)->D2_VALICM  * nPercPG  // Ja proporcionaliza o ICMS conforme %
            Z02->Z02_ST     := (_FSD2)->D2_ICMSRET * nPercPG  // Ja proporcionaliza o ST conforme %
            Z02->Z02_VALIPI := (_FSD2)->D2_VALIPI  * nPercPG  // Ja proporcionaliza o IPI conforme % - Nao incluso em Calculo
            Z02->Z02_PIS    := (_FSD2)->D2_VALIMP6 * nPercPG  // Ja proporcionaliza PIS
            Z02->Z02_COFINS := (_FSD2)->D2_VALIMP5 * nPercPG  // Ja proporcionaliza COFINS
            Z02->Z02_FRETE  := (_FSD2)->D2_VALFRE  * nPercPG  // Proporcionaliza Frete com %  -Implantando GFE alterar
            Z02->Z02_VLRPAG := (_FCOM)->E5_VALOR
            Z02->Z02_DTPAGO := (_FCOM)->E5_DATA
            Z02->Z02_DTEMIS := (_FSD2)->D2_EMISSAO
            Z02->Z02_NOTA   := (_FSD2)->D2_DOC
            Z02->Z02_SERIE  := (_FSD2)->D2_SERIE
            Z02->Z02_PARCEL := (_FCOM)->E5_PARCELA
            Z02->Z02_TIPONF := If((_FCOM)->E5_TIPODOC $ "CP","Z","V")
            Z02->Z02_DTCALC := dDataBase
            Z02->Z02_CUSTO  := nCusMed
            Z02->Z02_BASCOM := (_FCOM)->E5_VALOR              //nVdaLiq  //Venda Liquida para efeito de calculo
            Z02->Z02_MARGEM := nMargem
            Z02->Z02_PERCOM := nPercCom
            Z02->Z02_VALCOM := nValCom1
            Z02->Z02_PONTDE := nPontosDE
            Z02->Z02_PONTAT := nPontosAT
            Z02->Z02_VLDESC := (_FCOM)->E5_VLDESCO
            Z02->Z02_VDSEQ  := "1'
            Z02->Z02_PERPAG := nPercPG
            If nCusmed == 0
                Z02->Z02_OCORR  :="1"
            ElseIf nValCom1 == 0
                Z02->Z02_OCORR  :="2"
            ElseIf (((_FCOM)->E5_VLDESCO / (_FCOM)->E5_VALOR) * 100)  > 5
                Z02->Z02_OCORR  :="3"
            Else
                Z02->Z02_OCORR  :="0"
            End
            MsUnLock()
            nRegGer++

            (_FSD2)->(dbSkip())
        End
        // Fim Itens

        (_FCOM)->(dbSkip())
    End
    // Fim Se5
    (_FCOM)->(dbCloseArea())

    MSgInfo("Calculo efetuado. Regisros Gerados: "+Str(nRegGer,5,0),"Fim Processo (Vend2)")
Return

/*/{Protheus.doc} EQCALCM5
Chamada do relatorio
@type function Tela
@version  1.00
@author mario.antonaccio
@since 06/12/2021
@return Character, sem retorno definido
/*/
User Function EQCALCM5()

    Local aButtons  := {}
    Local aSays     := {}
    Local cTitoDlg  := OEMToAnsi("Rotina para GeraÁ„o do Relatorio de Comiss„o")
    Local nOpca     := 0

    //Pergunta 01
    aAdd(aSays, "Esta rotina tem o objetivo de, gerar a o relatorio do calculo de comissao ")
    aAdd(aSays, "conforme definicoes dadas")

    aAdd(aButtons,{5, .T., {|o| Pergunte(cPerg, .T.)}})
    aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
    aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

    FormBatch(cTitoDlg, aSays, aButtons)
    If nOpca == 1
        Pergunte(cPerg, .F.)
        Processa( {|| EQCALCM6() }, "Aguarde...", "Gerando Relatorio...",.F.)
    EndIf

Return

/*/{Protheus.doc} EQCALCM6
Gera o Relatorio em EXCEL
@type function Relatorio
@version  1.00
@author mario.antonaccio
@since 06/12/2021
@return Character, sem retorno definido
/*/
Static Function EQCALCM6()

    Local aPergunte := {}
    Local aSomaTt   :={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    Local aSomaVd   :={0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    Local cArqDst   := "C:\TOTVS\EQCALCM5_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
    Local cNomPla   := "EQCALCOM"
    Local cNomWrk   := "EQCALCOM"
    Local cTitPla   := "Demonstrativo Comissao"
    Local cVend
    Local lAbre     := .F.
    Local nI        := 0
    Local nTotReg   := 0
    Local _nI       := 0
    Local aVencto   := {}
    Local nPrzMd    := 0
    Local nDias     := 0
    Local _CalcPrz  := 0
    Local _cQuery   := ""
    Local oExcel    := FWMsExcelEX():New()
    Local oObj      := FWSX1Util()  :New()
    Local _cCodPgto := ""
    Local _cDescPto := ""
    Private _FZ02   := GetNextAlias() //Arquivo filtrado de comissao

    oObj:AddGroup(cPerg)
    oObj:SearchGroup()
    aPergunte := oObj:GetGroup(cPerg)

    MakeDir("C:\TOTVS")

    BeginSql Alias _FZ02
        COLUMN Z02_DTPAGO as Date
        COLUMN Z02_DTEMIS as Date
        COLUMN Z02_DTCALC as Date
        SELECT
            Z02.Z02_FILIAL,
            Z02.Z02_VEND,
            Z02.Z02_TPVEND,
            Z02.Z02_CLIENT,
            Z02.Z02_LOJA,
            Z02.Z02_PRODUT,
            Z02.Z02_QUANT,
            Z02.Z02_TOTITM,
            Z02.Z02_ICMS,
            Z02.Z02_ST,
            Z02.Z02_VALIPI,
            Z02.Z02_PIS,
            Z02.Z02_COFINS,
            Z02.Z02_FRETE,
            Z02.Z02_CUSTO,
            Z02.Z02_MARGEM,
            Z02.Z02_BASCOM,
            Z02.Z02_PERCOM,
            Z02.Z02_VALCOM,
            Z02.Z02_VLRPAG,
            Z02.Z02_DTPAGO,
            Z02.Z02_DTEMIS,
            Z02.Z02_NOTA,
            Z02.Z02_SERIE,
            Z02.Z02_TIPONF,
            Z02.Z02_DTCALC,
            Z02.Z02_PONTDE,
            Z02.Z02_PONTAT,
            Z02.Z02_OCORR,
            Z02.Z02_VLDESC,
            Z02.Z02_PARCEL,
            Z02.Z02_PERPAG,
            Z02.Z02_VDSEQ
        FROM
            %Table:Z02% Z02
        WHERE
            Z02.%NotDel%
            AND Z02.Z02_DTPAGO >= %Exp:DTOS(mv_par01)%
            AND Z02.Z02_DTPAGO <= %Exp:DTOS(mv_par02)%
            AND Z02.Z02_VEND >= %Exp:mv_par03%
            AND Z02.Z02_VEND <= %Exp:mv_par04%
            AND Z02.Z02_NOTA >= %Exp:mv_par05%
            AND Z02.Z02_NOTA <= %Exp:mv_par06%
            AND Z02.Z02_OCORR = '0'
        ORDER BY
            Z02.Z02_VEND,
            Z02.Z02_NOTA,
            Z02.Z02_SERIE,
            Z02.Z02_CLIENT,
            Z02.Z02_LOJA,
            Z02.Z02_PRODUT
    EndSql

    aQuery:=GetLastQuery()
    nTotReg := Contar((_FZ02),"!EOF()")
    (_FZ02)->(DbGoTop())

    oExcel:AddworkSheet(cNomWrk)
    oExcel:AddTable(cNomPla, cTitPla)

    // Dados Nota -  12 Colunas
    oExcel:AddColumn(cNomPla, cTitPla, "Filial "        , 1, 1, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "Cliente "       , 1, 1, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "Loja"           , 1, 1, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "Nome"           , 1, 1, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "Produto"        , 1, 1, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "DescriÁ„o"      , 1, 1, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "Qtd.Vendida"    , 3, 2, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "Volume Total"   , 3, 2, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "Valor Item"     , 3, 2, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "Valor ICMS"     , 3, 2, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "Valor ST"       , 3, 2, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "Valor PIS"      , 3, 2, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "Valor COFINS"   , 3, 2, .F.)

    // Custo - 1 coluna
    oExcel:AddColumn(cNomPla, cTitPla, "Valor Custo"     , 3, 2, .F.)

    // Dados Titulo - 3 colunas
    oExcel:AddColumn(cNomPla, cTitPla, "Valor Pago"      , 3, 2, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "Desconto"        , 3, 2, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "Parcela"         , 1, 1, .F.)

    // Comissao - 4 colunas
    oExcel:AddColumn(cNomPla, cTitPla, "Margem"          , 3, 2, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "Base Comiss„o"   , 3, 2, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "% Comissao"      , 3, 2, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "Valor Comiss„o"  , 3, 2, .F.)

    // Complementares -  6 colunas
    oExcel:AddColumn(cNomPla, cTitPla, "Data Pagto"      , 1, 4, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "Nota Fiscal"     , 1, 1, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "SÈrie"           , 1, 1, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "Dt Emiss„o NF"   , 1, 4, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "Cond. Pgto"      , 1, 1, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "Prazo Pgto Nf"   , 1, 1, .F.)
    oExcel:AddColumn(cNomPla, cTitPla, "Prazo Medio Pgto", 1, 1, .F.)


    ProcRegua(nTotReg)

    While (_FZ02)->(!EOF())

        lAbre:=.T.

        //Dados Vendedor
        SA3->(dbSetOrder(1))
        SA3->(dbSeek(xFilial("SA3")+(_FZ02)->Z02_VEND))

        cVend:=(_FZ02)->Z02_VEND

        // Linha  CabeÁalho - dados Filial Vendedor, nome tipo  vendedor
        oExcel:AddRow(cNomPla, cTitPla,{"Vend:"	    		,;
            cVend   			,;
            " " 				,;
            AllTrim(SA3->A3_NOME)    ,;
            "(Vendedor:  "+ (_FZ02)->Z02_VDSEQ  +")"     			,;
            If(SA3->A3_TIPO=="I","Interno","Externo"),;
            0            		,;
            0  	                ,;
            0                   ,;
            0  	                ,;
            0  	                ,;
            0                   ,;
            0                   ,;
            0                   ,;
            0                   ,;
            0                   ,;
            " "             	,;
            0                	,;
            0                 	,;
            0                	,;
            0                	,;
            " "              	,;
            "Data Calculo"     	,;
            " "               	,;
            DTOC((_FZ02)->Z02_DTCALC),;
            " "               	,;
            " "               	,;
            " "               	})

        //Linha em Branco
        oExcel:AddRow(cNomPla, cTitPla,{"  "	    		,;
            " "        			,;
            " " 				,;
            " "                 ,;
            " "        			,;
            " "                 ,;
            0            		,;
            0  	                ,;
            0                   ,;
            0  	                ,;
            0                   ,;
            0                   ,;
            0                   ,;
            0                   ,;
            0                   ,;
            0                   ,;
            " "             	,;
            0                	,;
            0                 	,;
            0                	,;
            0                	,;
            " "              	,;
            " "             	,;
            " "               	,;
            " "               	,;
            " "               	,;
            " "               	,;
            " "               	})

        While (_FZ02)->(!EOF()) .and. (_FZ02)->Z02_VEND == cVend

            IncProc()

            _cCodPgto  := ""
            _cDescPto  := ""
            _nI        := 0 
            nDias      := 0 
            nPrzMd     := 0
            _CalcPrz   := 0

            // Dados Cliente
            SA1->(dbSetOrder(1))
            SA1->(dbSeek(xFilial("SA1")+(_FZ02)->Z02_CLIENT+(_FZ02)->Z02_LOJA))

            // Dados produto
            SB1->(dbSetOrder(1))
            SB1->(dbSeek(xFilial("SB1")+(_FZ02)->Z02_PRODUT))

            nVolTot:=(_FZ02)->Z02_QUANT * (_FZ02)->Z02_PERPAG

            /*---------------------------------------------------------------------------------------------+
            | ALTERA«√O : AlteraÁ„o solicitada pela Alessandra Monea - 05/10/2022 - Fabio Carneiro         |
            |           : Foi incluido o codigo da condiÁ„o de pgto, descriÁ„o e media da cond pgto        |
            +---------------------------------------------------------------------------------------------*/
            If Select("TRB1") > 0
                TRB1->(DbCloseArea())
            EndIf

            _cQuery := "SELECT F2_COND, E4_CODIGO, E4_COND " + CRLF
            _cQuery += "FROM "+RetSqlName("SF2")+" AS SF2 " + CRLF
            _cQuery += "INNER JOIN "+RetSqlName("SE4")+" AS SE4 ON F2_COND = E4_CODIGO " + CRLF
            _cQuery += "AND SE4.D_E_L_E_T_ = ' '  " + CRLF
            _cQuery += "WHERE F2_FILIAL = '"+xFilial("SF2")+"' " + CRLF
            _cQuery += "AND F2_DOC      = '"+(_FZ02)->Z02_NOTA+"'  " + CRLF
            _cQuery += "AND F2_SERIE    = '"+(_FZ02)->Z02_SERIE+"'  " + CRLF
            _cQuery += "AND F2_CLIENTE  = '"+(_FZ02)->Z02_CLIENT+"'  " + CRLF
            _cQuery += "AND F2_LOJA     = '"+(_FZ02)->Z02_LOJA+"'  " + CRLF
            _cQuery += "AND SF2.D_E_L_E_T_ = ' ' " + CRLF
            _cQuery += "GROUP BY F2_COND, E4_CODIGO, E4_COND " + CRLF

                            
            TCQUERY _cQuery NEW ALIAS TRB1

            TRB1->(dbGoTop())

            While TRB1->(!Eof())

                _cCodPgto  := TRB1->F2_COND
                _cDescPto  := TRB1->E4_COND

                TRB1->(dbSkip())

            Enddo

            aVencto  := Condicao(10000, _cCodPgto, 0, dDataBase)
            nDias    := 0
            
            For _nI := 1 to Len(aVencto)
                nDias += (aVencto[_nI,1] - dDataBase)
            Next _nI
            
            nPrzMd := nDias / (_nI - 1)

            _CalcPrz := Iif(nPrzMd > 999,999, int(nPrzMd))
            /*----------------------------------+
            | FIM - 05/10/2022 - Fabio Carneiro |
            +----------------------------------*/

            oExcel:AddRow(cNomPla, cTitPla,{(_FZ02)->Z02_FILIAL     ,;
                (_FZ02)->Z02_CLIENT     ,;
                (_FZ02)->Z02_LOJA       ,;
                AllTrim(SA1->A1_NOME)   ,;
                (_FZ02)->Z02_PRODUT     ,;
                AllTrim(SB1->B1_DESC)   ,;
                nVolTot                 ,;
                (_FZ02)->Z02_QUANT      ,;
                (_FZ02)->Z02_TOTITM     ,;
                (_FZ02)->Z02_ICMS       ,;
                (_FZ02)->Z02_ST         ,;
                (_FZ02)->Z02_PIS        ,;
                (_FZ02)->Z02_COFINS     ,;
                (_FZ02)->Z02_CUSTO      ,;
                (_FZ02)->Z02_VLRPAG     ,;
                (_FZ02)->Z02_VLDESC     ,;
                (_FZ02)->Z02_PARCEL     ,;
                (_FZ02)->Z02_MARGEM     ,;
                (_FZ02)->Z02_BASCOM     ,;
                (_FZ02)->Z02_PERCOM     ,;
                (_FZ02)->Z02_VALCOM     ,;
                (_FZ02)->Z02_DTPAGO     ,;
                (_FZ02)->Z02_NOTA       ,;
                (_FZ02)->Z02_SERIE      ,;
                (_FZ02)->Z02_DTEMIS     ,;
                _cCodPgto               ,;
                _cDescPto               ,;
                _CalcPrz                 })

            aSomaVd[01]+=nVolTot
            aSomaVd[02]+=(_FZ02)->Z02_TOTITM
            aSomaVd[03]+=(_FZ02)->Z02_ICMS
            aSomaVd[04]+=(_FZ02)->Z02_ST
            aSomaVd[05]+=(_FZ02)->Z02_PIS
            aSomaVd[06]+=(_FZ02)->Z02_COFINS
            aSomaVd[07]+=(_FZ02)->Z02_CUSTO
            aSomaVd[08]+=(_FZ02)->Z02_VLRPAG
            aSomaVd[09]+=(_FZ02)->Z02_VLDESC
            aSomaVd[10]+=(_FZ02)->Z02_BASCOM
            aSomaVd[11]+=(_FZ02)->Z02_VALCOM
            aSomaVd[12]+=(_FZ02)->Z02_QUANT

            (_FZ02)->(dbSkip())

        End

        //Total Vendedor
        oExcel:AddRow(cNomPla, cTitPla,{" " 	    		,;
            " "        			,;
            " " 				,;
            "Total Vendedor "   ,;
            " "        			,;
            " "                 ,;
            aSomaVD[01]    		,;
            aSomaVD[12]    		,;
            aSomaVD[02]         ,;
            aSomaVD[03]         ,;
            aSomaVD[04]         ,;
            aSomaVD[05]         ,;
            aSomaVD[06]         ,;
            aSomaVD[07]         ,;
            aSomaVD[08]         ,;
            aSomaVD[09]         ,;
            " "             	,;
            0                	,;
            aSomaVD[10]        	,;
            0                	,;
            aSomaVD[11]        	,;
            " "              	,;
            " "             	,;
            " "               	,;
            " "               	,;
            " "               	,;
            " "               	,;
            " "               	})

        //Linha em Branco
        oExcel:AddRow(cNomPla, cTitPla,{" " 	    		,;
            " "        			,;
            " " 				,;
            " "                 ,;
            " "        			,;
            " "                 ,;
            0            		,;
            0  	                ,;
            0  	                ,;
            0                   ,;
            0  	                ,;
            0                   ,;
            0                   ,;
            0                   ,;
            0                   ,;
            0                   ,;
            " "             	,;
            0                	,;
            0                 	,;
            0                	,;
            0                	,;
            " "              	,;
            " "             	,;
            " "               	,;
            " "               	,;
            " "               	,;
            " "               	,;
            " "               	})

        For nI:=1 To Len(aSomaVD)
            aSomaTT[nI]+=aSomaVD[nI]
        Next
        aSomaVd:={0,0,0,0,0,0,0,0,0,0,0,0}
    End

    //Linha em Branco
    oExcel:AddRow(cNomPla, cTitPla,{" "	        		,;
        " "        			,;
        " " 				,;
        " "                 ,;
        " "        			,;
        " "                 ,;
        0            		,;
        0  	                ,;
        0                   ,;
        0  	                ,;
        0  	                ,;
        0                   ,;
        0                   ,;
        0                   ,;
        0                   ,;
        0                   ,;
        " "             	,;
        0                	,;
        0                 	,;
        0                	,;
        0                	,;
        " "              	,;
        " "             	,;
        " "               	,;
        " "               	,;
        " "               	,;
        " "               	,;
        " "               	})

    //Total Geral
    oExcel:AddRow(cNomPla, cTitPla,{" " 	    		,;
        " "        			,;
        " " 				,;
        "Total Geral "      ,;
        " "        			,;
        " "                 ,;
        aSomaTT[01]    		,;
        aSomaTT[12]    		,;
        aSomaTT[02]         ,;
        aSomaTT[03]         ,;
        aSomaTT[04]         ,;
        aSomaTT[05]         ,;
        aSomaTT[06]         ,;
        aSomaTT[07]         ,;
        aSomaTT[08]         ,;
        aSomaTT[09]         ,;
        " "             	,;
        0                	,;
        aSomaTT[10]        	,;
        0                	,;
        aSomaTT[11]        	,;
        " "              	,;
        " "             	,;
        " "               	,;
        " "               	,;
        " "               	,;
        " "               	,;
        " "               	})

    (_FZ02)->(dbCloseArea())

    If lAbre
        oExcel:Activate()
        oExcel:GetXMLFile(cArqDst)
        OPENXML(cArqDst)
        oExcel:DeActivate()
    Else
        MsgInfo("Nao existem dados para serem impressos.", "SEM DADOS")
    EndIf

    If Select("TRB1") > 0
	    TRB1->(DbCloseArea())
	EndIf

Return

/*/{Protheus.doc} OPENXML
Abertura do arquivo XML Gerado
@type function Files
@version  1.00
@author mario.antonaccio
@since 16/12/2021
@param cArq, character, Nome do Arquivo XML
@return character, sem retorno
/*/
Static Function OPENXML(cArq)

    //Local cDirDocs := MsDocPath()
    // Local cPath	   := AllTrim(GetTempPath())

    If !ApOleClient("MsExcel")
        Aviso("Atencao", "O Microsoft Excel nao esta instalado.", {"Ok"}, 2)
    Else
        oExcelApp := MsExcel():New()
        oExcelApp:WorkBooks:Open(cArq)
        oExcelApp:SetVisible(.T.)
        oExcelApp:Destroy()
    EndIf
Return

/*/{Protheus.doc} EQCALCLG
Legenda da tela
@type function Tela (Browse)
@version  1.00
@author mario.antonaccio
@since 15/12/2021
@return character, sem retuorno
/*/
User Function EQCALCLG()
    Local aLegenda:={}

    aadd(aLegenda, {"BR_AMARELO" , "Sem Custo"})
    aadd(aLegenda, {"BR_PRETO"   , "Desconto maior 5%"})
    aadd(aLegenda, {"BR_VERDE"   , "Sem Ocorrencias"})
    aadd(aLegenda, {"BR_VERMELHO", "Sem Comissao"})
    //aadd(aLegenda, {"BR_AZUL"   , "Comissao PAGA"})

    BrwLegenda("Controle de Comissao", "SituaÁ„o", aLegenda)

Return

