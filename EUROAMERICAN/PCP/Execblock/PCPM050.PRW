#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "FwBrowse.ch"
#Include "fwmbrowse.ch"
#include 'tbiconn.ch'

#DEFINE cTitulo   "Lan�amentos de Programa��o PCP"

/*/{Protheus.doc} PCPM050
description Programa de manuten��o dos Lan�amentos de Programa��o
@type function User
@version 1.0
@author Paulo Lenzi
@since 01/09/2023
@return variant, return_description
/*/
user function PCPM050()
    local bSair   as block
    Local bGrava  as block
    Local BvldPro as Block
    Local bGraf   as Block
    Local bTela   as Block

    local nHeight as numeric
    local nWidth as numeric

    local oArea as object
    local oBtn1 as object
    local oBtn2 as object
    local oBtn3 as object
    local oBtn4 as object
    local oBtn5 as object
    local oBtn6 as object
    local oBtn7 as object
    local oCenterPanel as object
    local oDlg as object
    local oLayout as object
    local oPanel as object
    local oOption as object
    local oSide as object
     
    Private oBrowse := FwBrowse():New()

    Private nPosPro:= 01, nPosLoc:= 02, nPosSLD:= 03, nPosQEP:= 04, nPosDPN:= 05, nPosCmm:= 06, nPosCmD:= 07  
    Private nPosEAD:= 08, nPosEDD:= 09, nPosESD:= 10, nPosESQ:= 11, nPosSMQ:= 12, nPosSMD:= 13, nPosDUR:= 14                  
    Private nPosEnt:= 15, nPosDel := 16
    
    Private aDespes:=  {{space( tamSx3( "ZJ_PRODUTO" )[1]),;  // Codigo do produto
                      space( tamSx3( "ZJ_LOCAL" )[1]),;       // Local
                      0.0000,;                                // Saldo Atual
                      0.0000,;                                // Empenhos
                      0.0000,;                                // Disponivel
                      0.0000,;                                // Consumo Mes
                      0.0000,;                                // Consumo Dia
                      0.0000,;                                // Estoque Atual em dias
                      0.0000,;                                // Estoque Disponivel em dias
                      0.0000,;                                // Estoque de Seguran�a em Dias (Digitado)
                      0.0000,;                                // Estoque de Seguran�a em Quantidade
                      0.0000,;                                // Simulacao em Quantidade
                      0.0000,;                                // Simula��o em Dias
                      0.0000,;                                // Duracao em Dias
                      space( tamSx3( "ZJ_ENTREGA" )[1]),;    // Entregas
                      .F. }}    
 
    // Bot�es do painel lateral da tela
    bSair := {|| Iif(MsgYesNo('Deseja realmente sair do gerenciamento?','Gerenciamento'),(oDlg:End()),NIL)}
    bGrava := {|| Iif(MsgYesNo('Grava Lan�amentos?','Programa��o'),(PM050GRAVA(),oDlg:End()),NIL)}

   
    BvldPro := {|| PM050CPO(adespes[oBrowse:nAt][nPosPro]) }
    bGraf   := {|| U_PM050GRAF(adespes[oBrowse:nAt][nPosPro]) }
    bTela   := {|| U_PM050Tela(adespes[oBrowse:nAt][nPosPro]) }

    oMainWnd:ReadClientCoors()
    nHeight := oMainWnd:nHeight-50
    nWidth  := oMainWnd:nWidth-15

    // Call do parametro de pergunta
    If Pergunte("PCPM050",.T.)
		Set Key VK_F12 To
		SetKey( VK_F12, { || pergunte("PCPM050",.T.) } )
	EndIf

    // Tela Principal 
    DEFINE MSDIALOG oDlg FROM 0,0 TO nHeight,nWidth TITLE "" PIXEL STYLE nOR(WS_VISIBLE,WS_POPUP)

    oPanel := TPanel():New(0,0,,oDlg,,,,,,15,0,.F.,.F.)
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT

    oArea := FWArea():New(000,000,nHeight/2,nWidth,oPanel,0)
    oArea:CreateBorder(2)

    oArea:AddSideBar ( 12, 1, "oSide" )
    oSide := oArea:GetSideBar("oSide")

    oArea:AddWindow ( 100, 100, "cId1" ,"A��es", 3 , 2,oSide, CONTROL_ALIGN_TOP )
    oArea:AddPanel(100,100,"oOption")
    oOption := oArea:GetPanel("oOption")

    oBtn1 := TButton():New( 1,202,'Gravar Lan�amentos' ,oOption, bGrava,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn1:Align := CONTROL_ALIGN_TOP

    oBtn2 := TButton():New( 1,202,'Consulta SC/PC/NFe' ,oOption, bTela,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn2:Align := CONTROL_ALIGN_TOP

    oBtn3 := TButton():New( 1,202,'Grafico Consumo Medio' ,oOption, bGraf,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn3:Align := CONTROL_ALIGN_TOP

    oBtn4 := TButton():New( 1,202,'Gera Solicita��o Compra' ,oOption, bSair,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn4:Align := CONTROL_ALIGN_TOP

    oBtn5 := TButton():New( 1,202,'Gera Ordens Produ��o <aguarde>' ,oOption, bSair,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn5:Align := CONTROL_ALIGN_TOP

    oBtn6 := TButton():New( 1,202,'Recursos' ,oOption, bSair,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn6:Align := CONTROL_ALIGN_TOP

    oBtn7 := TButton():New( 1,202,'Sair'    ,oOption, bSair,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn7:Align := CONTROL_ALIGN_BOTTOM

    oArea:AddLayout ( "Default" )
    oLayout := oArea:GetLayout ( "Default" )

    oArea:AddWindow ( 100, 100, "cId2","Lan�amento", 3 , 3,oLayout, CONTROL_ALIGN_TOP )
    oArea:AddPanel(100,100,"oCenterPanel")
    oCenterPanel := oArea:GetPanel("oCenterPanel")

     if oBrowse != nil
        oBrowse:DeActivate()
    endif
    
    // Fun��o de telas 
    
    oBrowse:SetOwner(oCenterPanel)
    oBrowse:setDataArray()
    oBrowse:setArray( aDespes )
    oBrowse:disableConfig()
    oBrowse:disableReport()
    oBrowse:setInsert( .T. ) 
    oBrowse:Setdelete(.T.,{ || PM050DEL() } ) 
    oBrowse:SetBlkBackColor({|| IIf(aDespes[oBrowse:nAt,nPosDel]=.T. , CLR_LIGHTGRAY , Nil )})
   
   // Colunas da tela

   oBrowse:addColumn({"Produto", {||aDespes[oBrowse:nAt,nPosPro]}, GetSx3Cache("ZJ_PRODUTO","X3_TIPO"), pesqPict("SZJ","ZJ_PRODUTO") , 1, tamSx3("ZJ_PRODUTO")[1] ,, .T. ,BvldPro, .F.,, "XZJ_PRODUTO",, .F., .T.,, "XZJ_PRODUTO"})

   oBrowse:addColumn({"Local", {||aDespes[oBrowse:nAt,nPosSLD]}, GetSx3Cache("ZJ_LOCAL","X3_TIPO"), pesqPict("SZJ","ZJ_LOCAL")   , 1, tamSx3("ZJ_LOCAL")[1],, .T. , , .F.,, "XZJ_LOCAL",, .F., .T.,, "XZJ_LOCAL"})

   oBrowse:addColumn({"Saldo", {||aDespes[oBrowse:nAt,nPosSLD]}, GetSx3Cache("ZJ_SALDO","X3_TIPO"), pesqPict("SZJ","ZJ_SALDO")   , 1, tamSx3("ZJ_SALDO")[1] ,tamSx3("ZJ_SALDO")[2], .T. , , .F.,, "XZJ_SALDO",, .F., .T.,, "XZJ_SALDO"})

   oBrowse:addColumn({"Empenho", {||aDespes[oBrowse:nAt,nPosQEP]}, GetSx3Cache("ZJ_QEMP","X3_TIPO"), pesqPict("SZJ","ZJ_QEMP")   , 1, tamSx3("ZJ_QEMP")[1] ,tamSx3("ZJ_QEMP")[2], .T. , , .F.,, "XZJ_QEMP",, .F., .T.,, "XZJ_QEMP"})

   oBrowse:addColumn({"Disponivel", {||aDespes[oBrowse:nAt,nPosDPN]}, GetSx3Cache("ZJ_DISPON","X3_TIPO"), pesqPict("SZJ","ZJ_DISPON")   , 1, tamSx3("ZJ_DISPON")[1] ,tamSx3("ZJ_DISPON")[2], .T. , , .F.,, "XZJ_DISPON",, .F., .T.,, "XZJ_DISPON"})

   oBrowse:addColumn({FWX3Titulo("ZJ_CONSUM"), {||aDespes[oBrowse:nAt,nPosCmm]}, GetSx3Cache("ZJ_CONSUM","X3_TIPO"), pesqPict("SZJ","ZJ_CONSUM")   , 1, tamSx3("ZJ_CONSUM")[1] ,tamSx3("ZJ_CONSUM")[2], .T. , , .F.,, "XZJ_CONSUM",, .F., .T.,, "XZJ_CONSUM"})

   oBrowse:addColumn({FWX3Titulo("ZJ_CONSUD"), {||aDespes[oBrowse:nAt,nPosCmD]}, GetSx3Cache("ZJ_CONSUD","X3_TIPO"), pesqPict("SZJ","ZJ_CONSUD")   , 1, tamSx3("ZJ_CONSUD")[1] ,tamSx3("ZJ_CONSUD")[2], .T. , , .F.,, "XZJ_CONSUD",, .F., .T.,, "XZJ_CONSUD"})

   oBrowse:addColumn({FWX3Titulo("ZJ_STOKATU"), {||aDespes[oBrowse:nAt,nPosEAD]}, GetSx3Cache("ZJ_STOKATU","X3_TIPO"), pesqPict("SZJ","ZJ_STOKATU")   , 1, tamSx3("ZJ_STOKATU")[1] ,tamSx3("ZJ_STOKATU")[2], .T. , , .F.,, "XZJ_STOKATU",, .F., .T.,, "XZJ_STOKATU"})

   oBrowse:addColumn({FWX3Titulo("ZJ_STOKDAY"), {||aDespes[oBrowse:nAt,nPosEDD]}, GetSx3Cache("ZJ_STOKDAY","X3_TIPO"), pesqPict("SZJ","ZJ_STOKDAY")   , 1, tamSx3("ZJ_STOKDAY")[1] ,tamSx3("ZJ_STOKDAY")[2], .T. , , .F.,, "XZJ_STOKDAY",, .F., .T.,, "XZJ_STOKDAY"})

   oBrowse:addColumn({FWX3Titulo("ZJ_SEGDIA"), {||aDespes[oBrowse:nAt,nPosESD]}, GetSx3Cache("ZJ_SEGDIA","X3_TIPO"), pesqPict("SZJ","ZJ_SEGDIA")   , 1, tamSx3("ZJ_SEGDIA")[1] ,tamSx3("ZJ_SEGDIA")[2], .T. , , .F.,, "XZJ_SEGDIA",, .F., .T.,, "XZJ_SEGDIA"})

   oBrowse:addColumn({FWX3Titulo("ZJ_SEGQTD"), {||aDespes[oBrowse:nAt,nPosESQ]}, GetSx3Cache("ZJ_SEGQTD","X3_TIPO"), pesqPict("SZJ","ZJ_SEGQTD")   , 1, tamSx3("ZJ_SEGQTD")[1] ,tamSx3("ZJ_SEGQTD")[2], .T. , , .F.,, "XZJ_SEGQTD",, .F., .T.,, "XZJ_SEGQTD"})

   oBrowse:addColumn({FWX3Titulo("ZJ_SIMUQTD"), {||aDespes[oBrowse:nAt,nPosSMQ]}, GetSx3Cache("ZJ_SIMUQTD","X3_TIPO"), pesqPict("SZJ","ZJ_SIMUQTD")   , 1, tamSx3("ZJ_SIMUQTD")[1] ,tamSx3("ZJ_SIMUQTD")[2], .T. , , .F.,, "XZJ_SIMUQTD",, .F., .T.,, "XZJ_SIMUQTD"})

   oBrowse:addColumn({FWX3Titulo("ZJ_SIMUDIA"), {||aDespes[oBrowse:nAt,nPosSMD]}, GetSx3Cache("ZJ_SIMUDIA","X3_TIPO"), pesqPict("SZJ","ZJ_SIMUDIA")   , 1, tamSx3("ZJ_SIMUDIA")[1] ,tamSx3("ZJ_SIMUDIA")[2], .T. , , .F.,, "XZJ_SIMUDIA",, .F., .T.,, "XZJ_SIMUDIA"})

   oBrowse:addColumn({FWX3Titulo("ZJ_DURA"), {||aDespes[oBrowse:nAt,nPosDUR]}, GetSx3Cache("ZJ_DURA","X3_TIPO"), pesqPict("SZJ","ZJ_DURA")   , 1, tamSx3("ZJ_DURA")[1] ,tamSx3("ZJ_DURA")[2], .T. , , .F.,, "XZJ_DURA",, .F., .T.,, "XZJ_DURA"})

   oBrowse:addColumn({FWX3Titulo("ZJ_ENTREGA"), {||aDespes[oBrowse:nAt,nPosEnt]}, GetSx3Cache("ZJ_ENTREGA","X3_TIPO"), pesqPict("SZJ","ZJ_ENTREGA")   , 1, tamSx3("ZJ_ENTREGA")[1] ,tamSx3("ZJ_ENTREGA")[2], .T. , , .F.,, "XZJ_ENTREGA",, .F., .T.,, "XZJ_ENTREGA"})

   oBrowse:aColumns[nPosPro]:XF3 := 'SB1'
   oBrowse:acolumns[nPosPro]:ledit     := .T.
   oBrowse:acolumns[nPosPro]:cReadVar:= 'aDespes[oBrowse:nAt,nPosPro]'

   oBrowse:aColumns[nPosLoc]:XF3 := 'SB2'
   oBrowse:acolumns[nPosLoc]:ledit     := .T.
   oBrowse:acolumns[nPosLoc]:cReadVar:= 'aDespes[oBrowse:nAt,nPosLoc]'

   oBrowse:acolumns[nPosSLD]:ledit     := .F.
   oBrowse:acolumns[nPosQEP]:ledit     := .F.
   oBrowse:acolumns[nPosDPN]:ledit     := .F.
   oBrowse:acolumns[nPosCmm]:ledit     := .F.
   oBrowse:acolumns[nPosCmD]:ledit     := .F.
   oBrowse:acolumns[nPosEAD]:ledit     := .F.
   oBrowse:acolumns[nPosEDD]:ledit     := .F.

   oBrowse:acolumns[nPosESD]:ledit     := .T.
   oBrowse:acolumns[nPosESD]:cReadVar:= 'aDespes[oBrowse:nAt,nPosESD]'

   oBrowse:acolumns[nPosESQ]:ledit     := .F.

   oBrowse:acolumns[nPosSMQ]:ledit     := .T.
   oBrowse:acolumns[nPosSMQ]:cReadVar:= 'aDespes[oBrowse:nAt,nPosSMQ]'

   oBrowse:acolumns[nPosSMD]:ledit     := .F.
   oBrowse:acolumns[nPosDUR]:ledit     := .F.
   oBrowse:acolumns[nPosEnt]:ledit     := .T.
 
  oBrowse:setAfterAddLine( { || posIncLine()} )
  oBrowse:setEditCell( .T.,{ || PM050VLD() } )

  SetKey(VK_F4, {|| PM050CONS() } )

  oBrowse:Activate()

  ACTIVATE MSDIALOG oDlg CENTERED
return

/*/{Protheus.doc} posIncLine
description Controle de inclus�o dos arrays
@type function Static
@version 1.0
@author Paulo Lenzi
@since 8/29/2023
@return variant, return_description
/*/
Static function posIncLine()
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_PRODUTO"):nOrder ] := space( tamSx3( "ZJ_PRODUTO" )[1]        )
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_LOCAL"):nOrder ]   := space( tamSx3( "ZJ_LOCAL" )[1]        )
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_SALDO"):nOrder ]   := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_QEMP"):nOrder ]    := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_DISPON"):nOrder ]  := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_CONSUM"):nOrder ]  := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_CONSUD"):nOrder ]  := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_STOKATU"):nOrder ] := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_STOKDAY"):nOrder ] := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_SEGDIA"):nOrder ]  := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_SEGQTD"):nOrder ]  := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_SIMUQTD"):nOrder ] := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_SIMUDIA"):nOrder ] := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_DURA"):nOrder ]    := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_ENTREGA"):nOrder ] := space( tamSx3( "ZJ_ENTREGA" )[1])
    aDespes[oBrowse:nAt  , nPosDel]                                   := .F.
return

/*/{Protheus.doc} PM050VLD
description Calculo das Celulas
@type function Static
@version 1.0
@author Paulo Lenzi
@since 9/1/2023
@return variant, return_description
/*/
static function PM050VLD()
   Local nPos:= oBrowse:ColPos()

   IF nPos = nPosLoc  // Posiciona na coluna Local ( Armazem ) dispara os calculos 
      adespes[oBrowse:nAt][nPosSLD] := Posicione("SB2",1,xFilial("SB2")+adespes[oBrowse:nAt][nPosPro]+adespes[oBrowse:nAt][nPosLoc],'B2_QATU' )
      adespes[oBrowse:nAt][nPosQEP] := Posicione("SB2",1,xFilial("SB2")+adespes[oBrowse:nAt][nPosPro]+adespes[oBrowse:nAt][nPosLoc],'B2_QEMP' )
      adespes[oBrowse:nAt][nPosDPN] := Posicione("SB2",1,xFilial("SB2")+adespes[oBrowse:nAt][nPosPro]+adespes[oBrowse:nAt][nPosLoc],'B2_QATU' ) - Posicione("SB2",1,xFilial("SB2")+adespes[oBrowse:nAt][nPosPro]+adespes[oBrowse:nAt][nPosLoc],'B2_QEMP' )
      adespes[oBrowse:nAt][nPosCmm] := PM050CALC()
      adespes[oBrowse:nAt][nPosCmD] := adespes[oBrowse:nAt][nPosCmm] /30
      adespes[oBrowse:nAt][nPosEAD] := adespes[oBrowse:nAt][nPosSLD] / adespes[oBrowse:nAt][nPosCmD]
      adespes[oBrowse:nAt][nPosEDD] := adespes[oBrowse:nAt][nPosDPN] / adespes[oBrowse:nAt][nPosCmD]
   endif   

   IF nPos = nPosESD // Apos digitar o estoque de seguran��o Dia, faz o calculo para estoque de seguran�a Quantidade
      adespes[oBrowse:nAt][nPosESQ] := adespes[oBrowse:nAt][nPosCmD] * adespes[oBrowse:nAt][nPosESD]
   endif 

   IF nPos = nPosSMQ
       adespes[oBrowse:nAt][nPosSMD] := adespes[oBrowse:nAt][nPosSMQ] / adespes[oBrowse:nAt][nPosCmD]
       adespes[oBrowse:nAt][nPosDUR] := ( ((Date() + adespes[oBrowse:nAt][nPosEDD] ) - adespes[oBrowse:nAt][nPosESD]) +  adespes[oBrowse:nAt][nPosSMD] )
   Endif

Return(.T.)

/*/{Protheus.doc} PM050CONS
description Tela de Consumo Medio 
@type function
@version 1.0
@author Paulo Lenzi
@since 9/1/2023
@return variant, return_description
/*/
Static Function PM050CONS()
   Local cArea := FWGetArea()
   Local Cod_Produto := adespes[oBrowse:nAt][nPosPro]
   MACOMVIEWSM(Cod_Produto)
   FWRestArea(cArea)
RETURN

/*/{Protheus.doc} PM050CALC
description Rotina de calculo do consumo medio
@type function 
@version 1.0
@author Paulo Lenzi
@since 9/1/2023
@return variant, return_description
/*/
Static Function PM050CALC()
   Local cArea       := FWGetArea()
   Local Cod_Produto := adespes[oBrowse:nAt][nPosPro]
   Local nMonth      := Month(dDataBase)
   Local nMeses      := MV_PAR01
   Local vlrCons     := 0
   Local vlMedia     := 0
   Local AB

   dbSelectArea("SB3")
   SB3->( dbSetOrder(1))   
   if SB3->( dbSeek( xFilial("SB3")+Cod_Produto,.T.) )
         FOR AB:=1 TO nMeses
             nMonth := Month(dDataBase)-AB
             vlrCons +=  &("SB3->B3_Q"+StrZero(nMonth,2))
         NEXT
   ENDIF
   vlMedia := vlrCons/nMeses
   FWRestArea(cArea)
RETURN(vlMedia)

/*/{Protheus.doc} PM050GRAVA
description Rotina de grava��o dos lan�amentos de programa��o
@type function
@version 1.0
@author Paulo Lenzi
@since 9/1/2023
@return variant, return_description
/*/
Static Function PM050GRAVA()
   Local cArea       := FWGetArea()
   Local AB as numeric
 
   IF len(aDespes) > 0
       FOR AB:=1 to len(aDespes)
       IF !adespes[AB][nPosDel] .AND. !Empty(adespes[AB][nPosFor])  // Valida se o array n�o foi deletado
            dbSelectArea("SZJ")
            SZJ->( dbSetOrder(1) )
            IF SZJ->( !dbSeek(xFilial("SZJ")+Alltrim(adespes[AB][nPosFor])+Alltrim(adespes[AB][nPosLoj])+Alltrim(adespes[AB][nPosPro])+Alltrim(adespes[AB][nPosLoc]+Dtos(dDatabase) ),.T. ) )
                     IF RecLock("SZJ",.T.)
                           SZJ->ZJ_FILIAL       :=    xFilial("SZJ")
                           SZJ->ZJ_PRODUTO      :=    adespes[AB][nPosPro]
                           SZJ->ZJ_LOCAL        :=    adespes[AB][nPosloc]
                           SZJ->ZJ_SALDO        :=    adespes[AB][nPosSLD]
                           SZJ->ZJ_QEMP         :=    adespes[AB][nPosQEP]
                           SZJ->ZJ_DISPON       :=    adespes[AB][nPosDPN]
                           SZJ->ZJ_CONSUM       :=    adespes[AB][nPosCmm]
                           SZJ->ZJ_CONSUD       :=    adespes[AB][nPosCmD]
                           SZJ->ZJ_STOKATU      :=    adespes[AB][nPosEAD]
                           SZJ->ZJ_STOKDAY      :=    adespes[AB][nPosEDD]
                           SZJ->ZJ_SEGDIA       :=    adespes[AB][nPosESD]
                           SZJ->ZJ_SEGQTD       :=    adespes[AB][nPosESQ]
                           SZJ->ZJ_SIMUQTD      :=    adespes[AB][nPosSMQ]
                           SZJ->ZJ_SIMUDIA      :=    adespes[AB][nPosSMD]
                           SZJ->ZJ_DURA         :=    adespes[AB][nPosDUR]
                           SZJ->ZJ_ENTREGA      :=    adespes[AB][nPosEnt]
                           SZJ->ZJ_DATA         :=    dDataBase

                        MsUnlock()
                     ENDIF 
            else
                     IF RecLock("SZJ",.F.)
                           SZJ->ZJ_SALDO        :=    adespes[AB][nPosSLD]
                           SZJ->ZJ_QEMP         :=    adespes[AB][nPosQEP]
                           SZJ->ZJ_DISPON       :=    adespes[AB][nPosDPN]
                           SZJ->ZJ_CONSUM       :=    adespes[AB][nPosCmm]
                           SZJ->ZJ_CONSUD       :=    adespes[AB][nPosCmD]
                           SZJ->ZJ_STOKATU      :=    adespes[AB][nPosEAD]
                           SZJ->ZJ_STOKDAY      :=    adespes[AB][nPosEDD]
                           SZJ->ZJ_SEGDIA       :=    adespes[AB][nPosESD]
                           SZJ->ZJ_SEGQTD       :=    adespes[AB][nPosESQ]
                           SZJ->ZJ_SIMUQTD      :=    adespes[AB][nPosSMQ]
                           SZJ->ZJ_SIMUDIA      :=    adespes[AB][nPosSMD]
                           SZJ->ZJ_DURA         :=    adespes[AB][nPosDUR]
                           SZJ->ZJ_ENTREGA      :=    adespes[AB][nPosEnt]
                        MsUnlock()
                     ENDIF 
                 
           Endif
       Endif 
       NEXT
    ENDIF

    FWRestArea(cArea)
Return

/*/{Protheus.doc} PM050DEL
description Fun��o para registros (aCols) deletados
@type function Static
@version 1.0
@author Paulo Lenzi
@since 9/1/2023
@return variant, return_description
/*/

Static Function PM050DEL()
     Local cArea       := FWGetArea()
     Local nLinha      := oBrowse:nAt
     Local lSit        := oBrowse:LDELETE
     if lSit 
         aDespes[nLinha][nPosDel] := .T.
     Endif    
     oBrowse:setArray(aDespes)	// For�o o Browse a ler os novos valores informados.
     oBrowse:GoTop()
     oBrowse:Refresh()	
     FWRestArea(cArea)
RETURN


/*/{Protheus.doc} PM050CPO
description Valida a existencia do Fornecedor, Produto e a Amarra��o
@type function
@version 1.0
@author Paulo Lenzi
@since 8/30/2023
@param nOpc, numeric, param_description
@return variant, return_description
/*/
Static Function PM050CPO(cProduto)
  Local cArea       := FWGetArea()
  Local lRet        := .T.
  dbSelectArea("SB1")
  SB1->( dbSetOrder(1) )
  IF SB1->( !dbSeek( xFilial("SB1")+cProduto,.T. ))   
                  lRet        := .F.
                  MsgAlert( " Esse Produto nao existe no cadastro")
  Endif
  FWRestArea(cArea)    
RETURN(lRet)
