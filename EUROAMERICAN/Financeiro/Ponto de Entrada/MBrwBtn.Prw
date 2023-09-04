#Include 'Protheus.ch'

/*/{Protheus.doc} MBRWBTN
Ponto de entrada genérico; executado no botão de manutenção das rotinas.
@type function Ponto de Entrada
@version  1.00
@author Paulo Rogério
@since 27/07/2022
@return Logical, permite ou nao o prosseguimento do processo
/*/

User Function MBRWBTN()
Local lRet    := .T.
Local cAcesso :=""
Local cMsg    :=""
Local cFiltro := ""
Local aArea   := {}


IF FunName()=="FINA010" .AND. PARAMIXB[3] <> 2
    //-------------------------------------------------------------------------
    // Controle de Acesso para manutenção da rotina de Naturezas Financeiras.
    //-------------------------------------------------------------------------
    cAcesso := Upper(GETMV("QS_CADNAT",,""))

    IF ! Alltrim(Upper(cUserName)) $  Upper(cAcesso)
        cMsg := "Você não tem permissão para utilizar essa rotina!" + chr(13)+Chr(10) + chr(13)+Chr(10) 
        cMsg += "Contate o responsável na área financeira!"

        MsgAlert(cMsg)
        lRet := .F.
    EndIf

ElseIF Alltrim(FunName()) $ "MATA200/PCPA200" .AND. PARAMIXB[3] <> 3
    //-------------------------------------------------------------------------
    // Controle de Acesso para manutenção da Estrutura de Produtos.
    //-------------------------------------------------------------------------
    cAcesso := Upper(GETMV("QS_RESTPCP",,""))
    cFiltro := Upper(GETMV("QS_FILTPCP",,""))


    IF Alltrim(Upper(cUserName)) $  Upper(cAcesso)
        aArea   := GetArea()

        IF !Empty(cFiltro)
            dbSelectArea("SB1")
            dbSetOrder(1)
            dbSeek(xFilial("SB1")+SG1->G1_COD)

            IF Found()
                IF ! &(cFiltro)
                    lRet := .F.
                Endif
            Endif
        Endif

        RestArea(aArea)

        IF !lRet
            cMsg := "Você não possui privilégios para efetuar essa ação no produto selecionado!" + chr(13)+Chr(10) + chr(13)+Chr(10) 
            cMsg += "Escolha outro Produto!"

            MsgAlert(cMsg)
        Endif
    EndIf
Endif 

Return lRet
