#Include 'Protheus.ch'

/*/{Protheus.doc} MBRWBTN
Ponto de entrada genérico; executado no botão de manutenção das rotinas.
@type function Ponto de Entrada
@version  1.00
@author Paulo Rogério
@since 27/07/2022
@return Logical, permite ou nao o prosseguimento do processo
/*/

User Function  MBRWBTN()
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

ElseIF Alltrim(FunName()) $ "MATA415" 
	//--------------------------------------------------------
	// [INICIO ] Projeto de Politicas Comerciais
	//--------------------------------------------------------
	IF !SCJ->CJ_STATUS $ 'AD'  .And. PARAMIXB[4] == "A415ALTERA" // .OR. (SCJ->CJ_STATUS == 'A' .And. SCJ->CJ_XLIBER $ "R"))
		MsgAlert("Este orçamento não pode ser Alterado, pois se encontra liberado ou efetivado!", "Politicas Comerciais")
		lRet := .F.
	Endif

	IF !SCJ->CJ_STATUS $ 'AD'  .And. PARAMIXB[4] == "A415EXCLUI" // .OR. (SCJ->CJ_STATUS == 'A' .And. SCJ->CJ_XLIBER $ "R"))
		MsgAlert("Este orçamento não pode ser Excluído, pois se encontra liberado ou efetivado!", "Politicas Comerciais")
		lRet := .F.
	Endif    

	IF !SCJ->CJ_STATUS $ 'AD'  .And. PARAMIXB[4] == "A415CANCEL" // .OR. (SCJ->CJ_STATUS == 'A' .And. SCJ->CJ_XLIBER $ "R"))
		MsgAlert("Este orçamento não pode ser Cancelado, pois se encontra liberado ou efetivado!", "Politicas Comerciais")
		lRet := .F.
	Endif      
	//--------------------------------------------------------
	// [TERMINO] Projeto de Politicas Comerciais
	//--------------------------------------------------------

ElseIF Alltrim(FunName()) $ "MATA416" 
	//--------------------------------------------------------
	// [INICIO ] Projeto de Politicas Comerciais
	//--------------------------------------------------------
    IF U_xFilPComl() 
        IF PARAMIXB[4] == "A415BAIXA" .OR. PARAMIXB[4] == "MA416AUTO"
            MsgAlert("Rotina Desativada! Utilize a opção 'Analisar' no menu outras ações.", "Politicas Comerciais")
            lRet := .F.
        Endif

        IF !SCJ->CJ_STATUS $ 'AD'  .And. PARAMIXB[4] $"A415EXCLUI/A416EXCLUI" // .OR. (SCJ->CJ_STATUS == 'A' .And. SCJ->CJ_XLIBER $ "R"))
            MsgAlert("Este orçamento não pode ser Excluído, pois se encontra liberado ou efetivado!", "Politicas Comerciais")
            lRet := .F.
        Endif     

        IF !SCJ->CJ_STATUS $ 'AD'  .And. PARAMIXB[4] $ "A415CANCEL/A416CANCEL" // .OR. (SCJ->CJ_STATUS == 'A' .And. SCJ->CJ_XLIBER $ "R"))
            MsgAlert("Este orçamento não pode ser Cancelado, pois se encontra liberado ou efetivado!", "Politicas Comerciais")
            lRet := .F.
        Endif             
    Endif
	//--------------------------------------------------------
	// [TERMINO] Projeto de Politicas Comerciais
	//--------------------------------------------------------

ElseIF Alltrim(FunName()) $ "MATA410" 
	//--------------------------------------------------------
	// [INICIO ] Projeto de Politicas Comerciais
	//--------------------------------------------------------
    IF U_xFilPComl() 
        aArea  := GetArea()

        dbSelectArea("SC6")
        dbSetOrder(1)
        dbSeek(xFilial("SC6")+SC5->C5_NUM)

        IF Found() .And. !Empty(C6_NUMORC) //.And. Funname() == "MATA410"
            IF  PARAMIXB[4] == "A410ALTERA" //PARAMIXB[1] == 4
                MsgAlert("Este pedido não pode ser Alterado, pois foi gerado pela rotina de Orçamento, MATA415!", "Politicas Comerciais")
                lRet := .F.
            Endif

            IF  PARAMIXB[4] == "A410DELETA" //PARAMIXB[1] == 1
                MsgAlert("Este pedido não pode ser Excluído, pois foi gerado pela rotina de Orçamento, MATA415!", "Politicas Comerciais")
                lRet := .F.
            Endif    

            IF  PARAMIXB[4] == "A410PCOPIA" //PARAMIXB[1] == 3
                MsgAlert("Este pedido não pode ser Copiado, pois foi gerado pela rotina de Orçamento!, MATA415", "Politicas Comerciais")
                lRet := .F.
            Endif  
        Endif

        RestArea(aArea) 
    Endif

	//--------------------------------------------------------
	// [TERMINO] Projeto de Politicas Comerciais
	//--------------------------------------------------------

Endif 


Return lRet
