#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"
/*/{Protheus.doc} FINAM020
description Controle de titulos com baixa de perda
@type function
@version 1.0
@author Paulo Lenzi
@since 8/10/2023
@return variant, return_description
/*/
User Function FINAM020()
   Local aArea   := GetArea()
    Local cFunBkp := FunName()
    Local oBrowse
    SetFunName("FINAM020")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("SA1")
    oBrowse:SetDescription("Controle de titulos de perda")
    oBrowse:SetFilterDefault("SA1->A1_PERDA != ' '")
    oBrowse:AddLegend( "SA1->A1_PERDA == 'L'", "GREEN",  "Liquidados os titulos com perda" )
    oBrowse:AddLegend( "SA1->A1_PERDA == 'P'", "RED",    "Tem Titulos com perda" )
    oBrowse:Activate()
    SetFunName(cFunBkp)
    RestArea(aArea)
RETURN

/*/{Protheus.doc} MenuDef
description Menu de opções do programa
@type function
@version 1.0
@author Paulo Lenzi
@since 8/10/2023
@return variant, return_description
/*/
Static Function MenuDef()
    Local aRotina :={}
   	ADD OPTION aRotina TITLE 'Pesquisar'  				ACTION "AxPesqui"        	OPERATION 1  ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE "Visualizar" 				ACTION "VIEWDEF.FINAM020" 	OPERATION 2  ACCESS 0 //"Visualizar"
    ADD OPTION aRotina TITLE "Negociar"			        ACTION "U_FM020NEG()" 		OPERATION 9  ACCESS 0 //"Negociar  
    ADD OPTION aRotina TITLE "Imprimir"			        ACTION "U_FM020PLAN()" 		OPERATION 9  ACCESS 0 //"Relatorio  
Return aRotina

/*/{Protheus.doc} ModelDef
description Model Definições
@type function
@version 1.0
@author Paulo Lenzi
@since 8/10/2023
@return variant, return_description
/*/
Static Function ModelDef()
    local oModel as object
    local oStrctSA1 as object
    local oStrctSZB as object
    local oStrctSE1 as object
    Local cPref := "PRD"
   
    oStrctSA1 := FwFormStruct( 1, "SA1" , /*bFiltro*/ )
    oStrctSZB := FwFormStruct( 1, "SZB" , /*bFiltro*/ )
    oStrctSE1 := FwFormStruct( 1, "SE1" , /*bFiltro*/ )

    oStrctSZB:SetProperty('ZB_PJUROS'   , MODEL_FIELD_WHEN     ,  {||.T.})
    oStrctSZB:SetProperty('ZB_DESCON'  , MODEL_FIELD_WHEN     ,  {||.T.})   
    oStrctSZB:SetProperty('ZB_COMIS'    , MODEL_FIELD_WHEN     ,  {||.T.})  

    oModel    := MPFormModel():New( "MdlMvcSA1", /*bPre*/ , /*bPos*/, /*bCommit*/, /*bCancel*/ )
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:AddFields( "M01SA1", /*Owner*/ , oStrctSA1 , /*bPre*/ , /*bPos*/ , /*bLoad*/ )

    oModel:AddGrid( "M02SZB", "M01SA1" , oStrctSZB , /*bLinePre*/ , /*bLinePost*/ , /*bPre*/ , /*bLinePost*/ , /*bLoad*/ ) 
    oModel:AddGrid( "M02SE1", "M01SA1" , oStrctSE1 , /*bLinePre*/ , /*bLinePost*/ , /*bPre*/ , /*bLinePost*/ , /*bLoad*/ ) 

    oModel:SetRelation(  "M02SZB", {{ "ZB_FILIAL" , xFilial("SZB") } , { "ZB_CLIENTE" , "A1_COD" },{"ZB_LOJA","A1_LOJA"} }, SZB->( IndexKey(1) ) )

    oModel:SetRelation(  "M02SE1", {{ "E1_FILIAL" , xFilial("SE1") } , { "E1_CLIENTE" , "A1_COD" },{"E1_LOJA","A1_LOJA"},{"E1_PREFIXO",'"'+cPref+'"'}}, SE1->( IndexKey(1) ) )


    oModel:GetModel( "M02SZB" ):SetUniqueLine( { "ZB_CLIENTE" } )
    oModel:GetModel( 'M02SZB' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'M02SZB' ):SetNoUpdateLine( .F. )
	oModel:GetModel( 'M02SZB' ):SetNoDeleteLine( .T. )
    oModel:GetModel( 'M02SZB' ):CanUpdateLine(.T.)

    oModel:GetModel( "M02SE1" ):SetUniqueLine( { "E1_CLIENTE" } )
    oModel:GetModel( 'M02SE1' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'M02SE1' ):SetNoUpdateLine( .F. )
	oModel:GetModel( 'M02SE1' ):SetNoDeleteLine( .T. )
    oModel:GetModel( 'M02SE1' ):CanUpdateLine(.T.)

    oModel:SetDescription("Movimentacoes")
    oModel:GetModel('M02SZB'):SetDescription('Titulos de Perda')
    oModel:GetModel('M02SE1'):SetDescription('Titulos Negociaveis')


Return oModel

/*/{Protheus.doc} ViewDef
description View definições do MVC
@type function
@version 1.0
@author Paulo Lenzi
@since 8/10/2023
@return variant, return_description
/*/
Static Function ViewDef()
    local oModel as object
    local oView as object
    local oStrctSA1 as object
    local oStrctSZB as object
    local oStrctSE1 as object

    oModel    := FwLoadModel( "FINAM020" )
    oView     := FwFormView():New() 
    oStrctSA1 := FwFormStruct( 2 , "SA1" , /*bFiltro*/ )
    oStrctSZB := FwFormStruct( 2 , "SZB" , /*bFiltro*/ )
    oStrctSE1 := FwFormStruct( 2 , "SE1" , /*bFiltro*/ )

    oStrctSZB:RemoveField( 'ZB_FILIAL' )
    oStrctSZB:RemoveField( 'ZB_CLIENTE' )
    oStrctSZB:RemoveField( 'ZB_LOJA' )
    oStrctSZB:RemoveField( 'ZB_NOME' )

    oView:SetModel( oModel )
    oView:AddField( "V01SA1" , oStrctSA1 , "M01SA1" )
    oView:AddGrid( "V02SZB" , oStrctSZB , "M02SZB" )
    oView:AddGrid( "V02SE1" , oStrctSE1 , "M02SE1" )

    oView:CreateHorizontalBox( "VwSA1" , 50 )
    oView:CreateHorizontalBox( "VwSZB" , 25 )
    oView:CreateHorizontalBox( "VwSE1" , 25 )

    oView:SetOwnerView( "V01SA1" , "VwSA1" )
    oView:SetOwnerView( "V02SZB" , "VwSZB" )
    oView:SetOwnerView( "V02SE1" , "VwSE1" )

Return oView

/*/{Protheus.doc} FM020NEG
description Função que carrega os programas que pertence a negociação dos titulos de perda
@type function
@version 1.0
@author Paulo Lenzi
@since 8/10/2023
@return variant, return_description
/*/
User Function FM020NEG()
     Local cArea := FWGetarea()
     Local cFilSZB  := SA1->A1_FILIAL
     Local cCliente := SA1->A1_COD
     Local cLoja    := SA1->A1_LOJA
    if ExistBlock("FM020MARK")
        aParam2:= {cFilSZB,cCliente,cLoja}
        ExecBlock("FM020MARK",.f.,.f.,aParam2)
    endif
     FWRestArea(cArea)
RETURN

/*/{Protheus.doc} FM020MARK
description Função que vai marcar ou desmacar os titulos baixado de perda para negociar
@type function
@version 1.0
@author Paulo Lenzi
@since 8/10/2023
@return variant, return_description
/*/
User Function FM020MARK()
    Local cArea := FwGetArea()
    Local cFilSZB := PARAMIXB[1]
    Local cCliente:= PARAMIXB[2]
    Local cLoja:= PARAMIXB[3]
    Private oMrkBrow

    oMrkBrow := FWMarkBrowse():New()
    oMrkBrow:SetAlias('SZB')
    oMrkBrow:SetSemaphore(.T.)
    oMrkBrow:SetDescription('Seleção dos titulos Negociaveis')
    oMrkBrow:AddFilter("Cliente", "ZB_FILIAL = '"+cFilSZB+"' .AND. ZB_CLIENTE = '"+cCliente+"' .AND. ZB_LOJA = '"+cLoja+"' .AND. ZB_STATUS = '1' ",,.T.,,,,"1" )
    oMrkBrow:SetFieldMark( 'ZB_OK' )
    oMrkBrow:SetAllMark( { || oMrkBrow:AllMark() } )
    oMrkBrow:AddLegend( "ZB_STATUS=='1'", "RED", "Pendente de Negociacao" )
    oMrkBrow:AddLegend( "ZB_STATUS=='2'", "GREEN" , "Negociado" )
    oMrkBrow:AddButton("Gerar Titulos"   ,{||U_FM020SE1(cFilSZB,cCliente,cLoja), oMrkBrow:Refresh(), oMrkBrow:Refresh()},,2,,.F.)
    oMrkBrow:Activate()

    FwRestArea(cArea)
RETURN


/*/{Protheus.doc} FM020SE1
description Função na qual irá gravar o titulo a receber do total dos titulos com baixa de perda
@type function
@version 1.0
@author Paulo Lenzi
@since 8/10/2023
@return variant, return_description
/*/
User Function FM020SE1(cFilSZB,cCliente,cLoja)
    Local cArea := FwGetArea()
    Local aPergs   := {}
    Local nPJuro   := 0
    Local nPDesc   := 0
    Local nComis   := "S"
    Local cCond := SPACE(3)

    Local aRet     :={}


    aAdd(aPergs, {1, "Perc. Juros ",  nPJuro,   PesqPict("SE1", "E1_JUROS") , "", "",    ".T."         , 80,  .F.})
    aAdd(aPergs, {1, "Perc. Desc"  ,  nPDesc,   PesqPict("SE1", "E1_JUROS") , "", "",    ".T."         , 80,  .F.})
    aAdd(aPergs, {1, "Condição"    ,  cCond,    PesqPict("SE4", "E4_CODIGO"), "","SE4",  ".T."         , 60,  .F.})
    aAdd(aPergs, {2, "Comissionado",  nComis, {"S=Sim (Automaticamente)", "N=Não"}  ,090, ".T.", .F.})
    If ParamBox(aPergs, "Informe os parâmetros",aRet)
        Processa({|| FM020GER(aRet[1],aRet[2],aRet[3],aRet[4],cFilSZB,cCliente,cLoja)},"Gerando o Titulo de Negociacao")
    EndIf
   FwRestArea(cArea)
RETURN

static function FM020GER(nPJuro,nPDesc,cCond,nComis,cFilSZB,cCliente,cLoja)
    Local cArea := FwGetArea()
    Local cMarca := oMrkBrow:Mark()
    Local aVetSE1 :={}
    Local cProxNum := GETMV("ES_PROXNUM")
    Local cNaturez := posicione("SA1",1,cFilSZB+cCliente+cLoja,"A1_NATUREZ")
    Local cVendedor:= posicione("SA1",1,cFilSZB+cCliente+cLoja,"A1_VEND")
    Local nPComis  := posicione("SA3",1,cFilSZB+cVendedor,"A3_COMIS")
    Local nTotal    := 0
    Local nValCom   := 0
    Local aParcela  := {}
    Local AI
    Local cQuery    := ''
    Local aSeqPar   := {"A","B","C","D","E","F","G","H","I","J","L","M","N","O","P","Q","R","S","T","U","V","X","Y","Z"}

    Private lMsErroAuto := .F.
    Private lMsHelpAuto := .T.

    cProxNum := Soma1(cProxNum)

    dbSelectArea("SZB")
    SZB->( dbSetOrder(1))
    SZB->( dbseek(cFilSZB+cCliente+cLoja,.t.))
    While !SZB->( EOF() ) .and. SZB->(ZB_FILIAL+ZB_CLIENTE+ZB_LOJA) = cFilSZB+cCliente+cLoja
        If oMrkBrow:IsMark(cMarca)
            if Reclock("SZB",.F.)
                SZB->ZB_STATUS  := '2'
                SZB->ZB_PJUROS  := nPJuro
                SZB->ZB_DESCON  := nPDesc
                SZB->ZB_COMIS   := nComis
                SZB->ZB_KEYUSR  := UsrFullName(__cUserId)
                SZB->ZB_DTGRV   := dDataBase
                SZB->ZB_HORA    := Time()
                SZB->ZB_SITUACA := "Em negociacao"    
                SZB->ZB_TITNEG  := cProxNum            
                nTotal := nTotal + SZB->ZB_VALOR
            Endif
        EndIf
        SZB->( dbSkip() )
    End

    nPorcJuros := nPJuro
    nValJuros  := nTotal * nPJuro/100
    nValCom    := nTotal * nPComis/100


    aParcela:= Condicao(nTotal, cCond, , dDataBase )

    if len(aParcela)>0
       FOR AI:=1 TO LEN(aParcela)
            cHist := "Titulo de Negociacao"
                aVetSE1 := {}
                cnPar := aSeqPar[AI]
                aAdd(aVetSE1, {"E1_FILIAL",  cFilSZB,                                               Nil})
                aAdd(aVetSE1, {"E1_NUM",     cProxNum,                                              Nil})
                aAdd(aVetSE1, {"E1_PREFIXO", "PRD",                                                 Nil})
                aAdd(aVetSE1, {"E1_PARCELA", cnPar,                                                 Nil})
                aAdd(aVetSE1, {"E1_TIPO",    "NF",                                                  Nil})
                aAdd(aVetSE1, {"E1_NATUREZ", cNaturez,                                              Nil})
                aAdd(aVetSE1, {"E1_CLIENTE", cCliente,                                              Nil})
                aAdd(aVetSE1, {"E1_LOJA",    cLoja,                                                 Nil})
                aAdd(aVetSE1, {"E1_NOMCLI",  Posicione("SA1",1,cFilSZB+cCliente+cLoja,"A1_NOME"),   Nil})
                aAdd(aVetSE1, {"E1_VEND  ", cVendedor,                                              Nil})
                aAdd(aVetSE1, {"E1_EMISSAO", DDATABASE,                                             Nil})
                aAdd(aVetSE1, {"E1_VENCTO",  aParcela[AI][1],                                       Nil})
                aAdd(aVetSE1, {"E1_VENCREA",  aParcela[AI][1],                                      Nil})
                aAdd(aVetSE1, {"E1_VALOR",    aParcela[AI][2],  ,                                   Nil})
                aAdd(aVetSE1, {"E1_VALJUR",  aParcela[AI][2]*nPorcJuros/100,                        Nil})
                aAdd(aVetSE1, {"E1_VALCOM1",  aParcela[AI][2]*nPComis/100,                          Nil})
                aAdd(aVetSE1, {"E1_PORCJUR", nPorcJuros,                                            Nil})
                aAdd(aVetSE1, {"E1_HIST",    cHist,                                                 Nil})
                aAdd(aVetSE1, {"E1_MOEDA",   1,                                                     Nil})
                
                //Inicia o controle de transação
                Begin Transaction
                    //Chama a rotina automática
                    lMsErroAuto := .F.
                    MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 3)
                    
                    //Se houve erro, mostra o erro ao usuário e desarma a transação
                    If lMsErroAuto
                        MostraErro()
                        DisarmTransaction()
                    EndIf
                //Finaliza a transação
                End Transaction
                
                 If !lMsErroAuto
                    cQuery:= "UPDATE "+ RetSqlName("SE1")+ " SET E1_PARCELA = '"+cnPar+"' where D_E_L_E_T_ = ' ' AND E1_PREFIXO = 'PRD' AND E1_NUM = '"+cProxNum+"' AND E1_PARCELA = ' '"
                    BEGIN TRANSACTION
                    lRet:= TCSqlExec( cQuery )
                        if lRet <> 0
                            MsgAlert( "1 Caso Gravacao " + TcSQLError() )
                        Endif
                    END TRANSACTION
                 Endif
               
       NEXT
    Endif
  
    If !lMsErroAuto
        PUTMV( "ES_PROXNUM", cProxNum )
        dbSelectArea("SA1")
        SA1->( dbSetOrder(1))
        IF SA1->( dbSeek(cFilSZB+cCliente+cLoja,.T. ))
           IF Reclock("SA1",.F.)
                SA1->A1_PERDA := "L"
              MsUnlock()
           ENDIF
        ENDIF
    Endif
    


    FwRestArea(cArea)
RETURN
//==================================================================================================================================================================//
               // {"CBCOAUTO"     , Alltrim(cGetbco)   ,NIL},;
               // {"CAGEAUTO"     , Alltrim(cGetAge)   ,NIL},;
               // {"CCTAAUTO"     , Alltrim(cGetConta) ,NIL},;	
               // {"E1_NATUREZ" 	,_cNaturez			 ,Nil},;
