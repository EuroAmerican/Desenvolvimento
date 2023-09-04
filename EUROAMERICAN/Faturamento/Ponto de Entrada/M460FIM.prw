#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} M460FIM
//Ponto de entrada apos a geração da nota fiscal
@author erics
@since 26/12/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function M460FIM
Local cPedido	:= SD2->D2_PEDIDO
Local aArea		:= GetArea()
Local aAreaSD2 	:= SD2->(GetArea())
Local aAreaSF2 	:= SF2->(GetArea())
Local nTotDivNF := 0
Local nValDiver := 0
Local cMsgAlert := ""

Local cDestMail := SuperGetMV("QS_MAILADM", .F., 'ti@euroamerican.com.br')
Local nDiferMax := SuperGetMV("QS_DIFMAX", , 1)

// Processar PA0 -- Eliminação de Residuo
U_ProcPA0(cPedido, 3) // inclusão 

Grava_CDL()     //Grava a tabela CDL-"Complemento de exportação" quando a da NF for de exportação . Geronimo 30/05/23 

RestArea(aAreaSF2)
RestArea(aAreaSD2)
RestArea(aArea)

/*
+-----------------------------------------------------------------------------------------+
| Tratamento para identificação de erro no valor total do item da NF. 
| Paulo Rogério - 22/06/2022
+-----------------------------------------------------------------------------------------+
| - Em 22/06/22 Atendemos um chamado referente aos PVs 234327 e 234135, cujos valores totais
| estavam divergentes dos valores gravados nos itens das notas fiscais(D2_TOTAL). Identifica-
| mos que em ambos os pedidos houve quebra de lote no SC9 (quebrou corretamente), porém, no
| SD2, em todos os itens do mesmo Produto (quebra em função dos lotes), ao invés de o sistema
| recalcular o valor total do item: D2_TOTAL = D2_PRCVEN * D2_QUANT, ele replicou o D2_TOTAL
| do primeiro item nos demais, gerando divergencia entre o valor da NF e do PV. Não identifi-
| camos irregularidas nas personalizações existentes na geração da nota fiscal e também não 
| conseguimos reproduzir o problema no Ambiente de testes. Analisando a base de dados oficial,
| verificamos que apenas na data em questão e nos pedidos em análise havia esse tipo de oco-
| rrência, caracteriando um problema pontual. Para garantir que em caso de recorrencia o pro-
| blema não passe despercebido, concordamos em validar todas as notas fiscais nesse PE e aler-
| tar o usuário e o Admin se alguma divergencia voltar a ocorrer.
+------------------------------------------------------------------------------------------+
*/
If SF2->F2_TIPO $ "N/D/B" 
	DbSelectArea("SD2")
	DbSetOrder(3) //D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM, R_E_C_N_O_, D_E_L_E_T_

    dbSeek(SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA)
	If Found()
        do While !Eof() .And. SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA) == SF2->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)
            nValDiver := Abs(Round(SD2->D2_QUANT * SD2->D2_PRCVEN, 2)) - Round(SD2->D2_TOTAL,2) 

            IF abs(nValDiver) > abs(nDiferMax)
                nTotDivNF += abs(nValDiver)
            EndIf

            dbSkip()
        Enddo
	EndIf

   IF nTotDivNF > 0
        cMsgAlert := "A Quantidade X Preço Unitário diverge do Valor Total em hum ou mais itens da Nota Fiscal "+SF2->F2_DOC +"/"+Alltrim(SF2->F2_SERIE)+". "
        cMsgAlert += "A NF FOI GERADA, PORÉM, SUA TRANSMISSÃO NÃO É RECOMENDADA NO MOMENTO. "+chr(13)+chr(10)+chr(13)+chr(10)
        cMsgAlert += "A NOTA FISCAL DEVE SER EXCLUIDA E EMITIDA NOVAMENTE!!! SE O PROBLEMA PERSISTIR, INFORME O ADMINISTRADOR DO SISTEMA!"+chr(13)+chr(10)

        MsgAlert(cMsgAlert+chr(13)+chr(10), "Divergência no Valor Total do Item da NF")
                                                                                                                                                                                                             
        //==============================================
        //ENVIAR EMAIL PARA O ADMINISTRADOR - PROTHEUS
        //==============================================
        U_CPEmail(cDestMail,"","Divergência no D2_TOTAL, no Item da Nota Fiscal",cMsgAlert,"",.T.)
    Endif

    RestArea(aAreaSD2)
    RestArea(aArea)
EndIf
Return( Nil )


/*/{Protheus.doc} Grava_CDL
// Função para gravar a tabela CDL-"Complemento de exportação" quando a da NF for de exportação 
@author Geronimo Benedito Alves
@since 30/05/2023
@version 1.0
@return ${return}, ${return_description}
@type Static function
/*/

Static Function Grava_CDL()   
Local aArea		:= GetArea()
Local aAreaSD2 	:= SD2->(GetArea())
Local aAreaSF2 	:= SF2->(GetArea())

Local cCliEx := Posicione("SA1",1,xfilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_EST")

If cCliEx == 'EX'           // incluir registro na tabela CDL complemento de exportação quando o cliente tiver o campo A1_EST = 'EX' (exportação)
    dbSelectArea("SD2")     // posiciona no item da nf
    dbSetorder(3)
    If dbSeek(SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA)
        While !sd2->(Eof()) .and. sd2->d2_filial == sf2->f2_filial .and. sd2->d2_doc == sf2->f2_doc .and. sd2->d2_serie == sf2->f2_serie .and. sd2->d2_cliente == sf2->f2_cliente .and. sd2->d2_loja == sf2->f2_loja
            DbSelectArea("CDL")
            RecLock("CDL",.T.)
            CDL->CDL_FILIAL := SD2->D2_FILIAL
            CDL->CDL_DOC    := SD2->D2_DOC
            CDL->CDL_SERIE  := SD2->D2_SERIE
            CDL->CDL_ESPEC  := 'SPED'
            CDL->CDL_CLIENT := SD2->D2_CLIENTE
            CDL->CDL_LOJA   := SD2->D2_LOJA
            CDL->CDL_INDDOC := ''       //'0'
            CDL->CDL_NUMDE  := ''       //'1'
            CDL->CDL_DTDE   := SD2->D2_EMISSAO
            CDL->CDL_NATEXP := ''       //'0'
            CDL->CDL_DTREG  := SD2->D2_EMISSAO
            CDL->CDL_CHCEMB :=  ''       //'01'
            CDL->CDL_DTCHC  := SD2->D2_EMISSAO
            CDL->CDL_DTAVB  := SD2->D2_EMISSAO
            CDL->CDL_TPCHC  :=  ''       //'01'
            CDL->CDL_PAIS   := Posicione("SA1",1,xfilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA,"A1_CODPAIS")
            CDL->CDL_NRMEMO := SD2->D2_ITEM
            CDL->CDL_EMIEXP := SD2->D2_EMISSAO
            CDL->CDL_QTDEXP := 0
            CDL->CDL_UFEMB  := 'SP'
            CDL->CDL_LOCEMB := 'JANDIRA'
            CDL->CDL_ITEMNF := SD2->D2_ITEM
            CDL->CDL_PRODNF := SD2->D2_COD
            CDL->CDL_VLREXP := 0
            CDL->CDL_SDOC   := SD2->D2_SERIE
            CDL->(MsUnLock())
            
            SD2->(DbSkip())
        Enddo
    EndIf
Endif

RestArea(aAreaSF2)
RestArea(aAreaSD2)
RestArea(aArea)
Return 

/*/{Protheus.doc} Grava_CDL
// ROTINA DE TESTE PARA DEBUGAR A FUNÇÃO Grava_CDL() QUE GRAVA a tabela CDL-"Complemento de exportação" quando a da NF for de exportação 
@author Geronimo Benedito Alves
@since 15/06/2023
@version 1.0
@return ${return}, ${return_description}
@type Static function
/*/
User Function  TstGrCDL()
SF2->(dBgOTO(481203))
SD2->(dBgOTO(3194480))
SC5->(dBgOTO(469261))

Grava_CDL()   

Return 

