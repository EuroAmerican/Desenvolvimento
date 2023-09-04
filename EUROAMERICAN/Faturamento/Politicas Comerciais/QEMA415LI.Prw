#include "rwmake.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#define ENTER CHR(13) + CHR(10)

/*
| Função...: QEMA415LI()
| Autor....: Paulo Rogerio
| Data.....: 06/07/2023
| Retorno..: Nenhum
| Descricão: Liberação do Orçamento de Venda.
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User Function QEMA415LI()
Local aArea		 := GetArea()
Local aAreaCK    := SCK->(GetArea())
Local aAreaCJ	 := SCJ->(GetArea())
Local aAreaB1	 := SB1->(GetArea())
Local aAreaA1	 := SA1->(GetArea())
Local aAreaF4	 := SF4->(GetArea())
Local aAreaA3	 := SA3->(GetArea())

Private _cPerg:="QEMA415LI"
Private _aRegs:={}

Private vpParEmiDe := ""
Private vpParEmiAte:= ""
Private vpParCliDe := ""
Private vpParCliAte:= ""
Private vpParHolDe := ""
Private vpParHolAte:= ""
Private vpParOrcDe := ""
Private vpParOrcAte:= ""
Private vpParTipLib:= ""

IF !U_xFilPComl() 
    MsgAlert("Rotina disponivel apenas para as empresas Qualy e Phoenix!")
    Return
Endif

//-----------|Grupo|Ord|Pergta                 |Pergunta              |Pergunta              |Variavel|Tip|Ta|D|P|GSC|Va|Var01     |Def Port       |De|De|Cn|Va|Def Port2      |De|De|Cn|Va|Def Port3    |De|De|Cn|Va|Def Port4    |De|De|Cn|Va|Def Port5  |De|De|Cn|F3|P |GRP
//-----------|     |em |Portug                 |Espanhol              |Ingles                |        |   |ma|e|r|   |li|          |               |f |f |te|r |               |f |f |te|r |             |f |f |te|r |             |f |f |te|r |           |f |f |te|  |Y |SXG
//-----------|     |   |                       |                      |                      |        |   |nh|c|e|   |d |          |               |Es|En|01|2 |               |Es|En|02|3 |             |Es|En|03|4 |             |Es|En|05|5 |           |Es|En|05|  |M |
AAdd(_aRegs,{_cPerg,"01","Tipo               ?","Tipo               ?","Tipo               ?","mv_ch1","N",01,0,0,"C","","mv_par01","Liberação"    ,"","","","","Simulação"    ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
AAdd(_aRegs,{_cPerg,"02","Emissão de         ?","Emissão de         ?","Emissão de         ?","mv_ch2","D",08,0,0,"G","","mv_par02",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
AAdd(_aRegs,{_cPerg,"03","Emissão ate        ?","Emissão ate        ?","Emissão ate        ?","mv_ch3","D",08,0,0,"G","","mv_par03",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
AAdd(_aRegs,{_cPerg,"04","Cliente de         ?","Cliente de         ?","Cliente de         ?","mv_ch4","C",06,0,0,"G","","mv_par04",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","","SA1FIN","",""})
AAdd(_aRegs,{_cPerg,"05","Cliente ate        ?","Cliente ate        ?","Cliente ate        ?","mv_ch5","C",06,0,0,"G","","mv_par05",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","","SA1FIN","",""})
AAdd(_aRegs,{_cPerg,"06","Holding de         ?","Holding de         ?","Holding de         ?","mv_ch6","C",06,0,0,"G","","mv_par06",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","","ACY"   ,"",""})
AAdd(_aRegs,{_cPerg,"07","Holding ate        ?","Holding ate        ?","Holding ate        ?","mv_ch7","C",06,0,0,"G","","mv_par07",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","","ACY"   ,"",""})
AAdd(_aRegs,{_cPerg,"08","Orçamento de       ?","Orçamento de       ?","Orçamento de       ?","mv_ch8","C",06,0,0,"G","","mv_par08",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
AAdd(_aRegs,{_cPerg,"09","Orçamento ate      ?","Orçamento ate      ?","Orçamento ate      ?","mv_ch9","C",06,0,0,"G","","mv_par09",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})

U_FSX1FUNC(_aRegs, _cPerg)

IF !Pergunte(_cPerg,.T.)
    Return
Endif

vpParTipLib:= mv_par01
vpParEmiDe := mv_par02
vpParemiAte:= mv_par03
vpParCliDe := mv_par04
vpParCliAte:= mv_par05
vpParHolDe := mv_par06
vpParHolAte:= mv_par07
vpParOrcDe := mv_par08
vpParOrcAte:= mv_par09

IF vpParTipLib == 1
    IF ! MSGYESNO( "Tem certeza que deseja submneter os orçamentos a liberação efetiva?", "LIBERAÇÃO EFETIVA" )
        Return
    Endif
Endif

Processa({|| fProcessar()}, "Aguarde","Processando a liberação dos orçamentos...")


RestArea(aAreaCK)
RestArea(aAreaCJ)
RestArea(aAreaB1)
RestArea(aAreaA1)
RestArea(aAreaF4)
RestArea(aAreaA3)
RestArea(aArea)
Return

/*
| Função...: fProcessar()
| Autor....: Paulo Rogerio
| Data.....: 07/07/2023
| Retorno..: Nenhum
| Descricão: Processamento e analise dos Orçamento de Vendas.
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
Static Function fProcessar()
Local cQuery   := ""
Local cChave   := ""
Local cMsg     := ""
Local cLotePrc := ""
Local aPedidos := {}
Local nMargem  := 999
Local nDescMix := 0
Local nDescCF  := 0
Local nDescLog := 0
Local nDescAD  := 0
Local nDescTot := 0
 
Local lDescMix := .F.
Local lDescCF  := .F.
Local lDescLog := .F.

Local aMargem  := {}
Local cHolding := ""
Local cNome    := ""
Local cAcaoLib := "L"
Local aBloq    := {}

Private nPercCF  := GETMV( "QE_PERCCF")  // ,,  2)
Private nPesoCMI := GETMV( "QE_CARGAMI") //,, 14000)
Private nPercMC  := GETMV( "QE_PERCMAR") //,, 30)
Private nPercMIX := GETMV( "QE_PERCMIX") //,, 2)
Private nVlrMIX  := GETMV( "QE_VLRMIX")  //,, 7.5)
Private nPercLog := GETMV( "QE_PERCLOG") //,, 2

Private aTotais  := {}
Private aItens   := {}

nPercMIX := U_DefPerMix()

//--------------------------------------------------------------------------
// [INICIO ] - Rotina para calcular totais de volume, peso e MIX dos pedidos
//--------------------------------------------------------------------------
cQuery := ""
cQuery += "       SELECT CJ_FILIAL, CJ_XGRPCLI, SUM(CK_QTDVEN * B1_CONV) AS CJ_LITROS, SUM(CK_QTDVEN * B1_PESBRU) AS CJ_PBRUTO, SUM(CK_VALOR) AS CJ_TOTAL"+ENTER

cQuery += "	        FROM "+RetSqlName("SCJ")+" AS SCJ WITH(NOLOCK)"+ENTER
cQuery += "	        INNER JOIN "+RetSqlName("SCK")+" AS SCK WITH(NOLOCK) ON SCK.D_E_L_E_T_ = '' AND CK_FILIAL = CJ_FILIAL AND CK_CLIENTE = CJ_CLIENT AND CK_LOJA = CJ_LOJA AND CK_NUM = CJ_NUM"+ENTER
cQuery += "	        INNER JOIN "+RetSqlName("SB1")+" AS SB1 ON B1_COD = CK_PRODUTO AND SB1.D_E_L_E_T_ = ''

cQuery += "         WHERE SCJ.D_E_L_E_T_ = ''"+ENTER
cQuery += "           AND CJ_FILIAL = '"+xFilial("SCJ")+"'"+ENTER 
cQuery += "           AND CJ_VALIDA >= '"+dtos(dDataBase)+"'"+ENTER
cQuery += "           AND CJ_EMISSAO BETWEEN '"+dtos(vpParEmiDe)+"' AND '"+dtos(vpParEmiAte)+"'"+ENTER
cQuery += "           AND CJ_CLIENT  BETWEEN '"+vpParCliDe+"' AND '"+vpParCliAte+"'"+ENTER
cQuery += "           AND CJ_NUM     BETWEEN '"+vpParOrcDe+"' AND '"+vpParOrcAte+"'"+ENTER
cQuery += "           AND CJ_STATUS = 'A'"+ENTER
cQuery += "         GROUP BY CJ_FILIAL, CJ_XGRPCLI"

IF Select("TMPX")
    TMPX->(dbCloseArea())
Endif

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMPX", .F., .T.)
dbSelectArea("TMPX")
dbGotop()

IF Eof()
    MsgInfo("Não há registros para processamento! Click OK para retornar.","Politicas Comerciais")
    TMPX->(dbCloseArea())
    Return
Endif

aPedidos := {}
aTotais  := {}

// Guarda os totais, pesos e litros por grupo de pedidos
Do While  !Eof()
    Aadd(aTotais, {TMPX->CJ_XGRPCLI,;                           // 1-Grupo / Cliente
                    TMPX->CJ_TOTAL,;                             // 2-Valor Total dos Pedidos do Grupo
                    TMPX->CJ_LITROS,;                            // 3-Total de Litros dos Pedidos do Grupo
                    TMPX->CJ_PBRUTO,;                            // 4-Peso Bruto total dos Pedidos do Grupo
                    Round(TMPX->CJ_TOTAL / TMPX->CJ_LITROS,2),;  // 5-Valor do MIX pelos totais do Grupo
                    0,;                                          // 6-Reservador
                    .T. ,;                                       // 7 - Pedidos Liberados (Padrão)
                    "** Lote de Orçamento Liberado ** "})        // 8 - Mensagem
    dbSkip()
Enddo

dbCloseArea()
//--------------------------------------------------------------------------
// [TERMINO ] - Rotina para calcular totais de volume, peso e MIX dos pedidos
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// [INICIO ] - Rotina para identificar os pedidos e analisar suas 
// caracteristicas individualmente.
//--------------------------------------------------------------------------
cQuery := "" 
cQuery += "       SELECT CJ_FILIAL, CJ_NUM, CJ_CLIENT, CJ_LOJAENT, CJ_XGRPCLI "+ENTER // IIF(A1_GRPVEN = '', A1_COD+A1_LOJA, A1_GRPVEN)
cQuery += "	        FROM "+RetSqlName("SCJ")+" AS SCJ WITH(NOLOCK)"+ENTER

cQuery += "         WHERE SCJ.D_E_L_E_T_ = ''"+ENTER
cQuery += "           AND CJ_FILIAL = '"+xFilial("SCJ")+"'"+ENTER
cQuery += "           AND CJ_VALIDA >= '"+dtos(dDataBase)+"'"+ENTER
cQuery += "           AND CJ_EMISSAO BETWEEN '"+dtos(vpParEmiDe)+"' AND '"+dtos(vpParEmiAte)+"'"+ENTER
cQuery += "           AND CJ_CLIENT  BETWEEN '"+vpParCliDe+"' AND '"+vpParCliAte+"'"+ENTER
cQuery += "           AND CJ_NUM     BETWEEN '"+vpParOrcDe+"' AND '"+vpParOrcAte+"'"+ENTER
cQuery += "           AND CJ_STATUS = 'A'"+ENTER

cQuery += " ORDER BY CJ_FILIAL, CJ_XGRPCLI, CJ_CLIENT, CJ_LOJAENT, CJ_NUM"

IF Select("ORCX")
    ORCX->(dbCloseArea())
Endif

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "ORCX", .F., .T.)
dbSelectArea("ORCX")
dbGotop()    

Do While !Eof()
    cHolding:= Alltrim(ORCX->CJ_XGRPCLI)
    cChave  := ORCX->(CJ_FILIAL + CJ_XGRPCLI)
    cMsg    := ""
    cLotePrc:= ""

    lDescMix := .F.
    lDescCF  := .F.
    lDescLog := .F.
    nMargem  := 999
    nDescMix := 0
    nDescCF  := 0
    nDescLog := 0
    nDescAD  := 0
    nDescTot := 0

    aPedidos := {}
    aMargem  := {}

    // Posiciona o Holding
    IF ! Right(ORCX->CJ_XGRPCLI, 2) == "XX" // Holding
        dbSelectArea("ACY")    
        dbSetOrder(1)     
        dbSeek(xFilial("ACY")+cHolding) 

        cNome := Alltrim(Padr((ACY->ACY_DESCRI), 40))
        cAcaoLib := ACY->ACY_XACAO
        lDescMix := ACY->ACY_ZDSCMI == "S"
        lDescCF  := ACY->ACY_ZDSCCF == "S"   
        lDescLog := ACY->ACY_ZDSCLG == "S"     
    Endif

    Do While ORCX->(CJ_FILIAL + CJ_XGRPCLI) == cChave .and. !Eof()
        // Posiciona o Cliente
        IF Right(ORCX->CJ_XGRPCLI, 2) == "XX" // Individual
            dbSelectArea("SA1")    
            dbSetOrder(1)    
            dbSeek(xFilial("SA1")+ORCX->CJ_CLIENT) 

            cNome := Alltrim(Padr((SA1->A1_NOME), 40))
            lDescMix := SA1->A1_ZDSCMIX == "S"
            lDescCF  := SA1->A1_ZDSCCF  == "S"   
            lDescLog := SA1->A1_ZDSCLOG == "S"            
        Endif


        dbSelectArea("SCJ")
        dbSetOrder(1)
        dbSeek(xFilial("SCJ")+ORCX->CJ_NUM)         

        //--------------------------------------------------------
        // Se for o primeiro pedido do grupo, atualiza a 
        // Margem de Contribuição e Descontos MIX / CF do Grupo. 
        //--------------------------------------------------------
        IF nMargem == 999
           /* Data.......: 29/08/2023
              Analista...: Paulo Rogério
              Solicitante: Eristeu
              Alteração..: A partir dessa data, os descontos  MIC, Carga Fechada e Logisitico passam a ser digitados pelo usuário, 
                           ao invés de aplicados automáticamente. Vise MIQE031 - Solicitacao_de_Mudança_de_Escopo – 01.doc 

              Processa({|| U_xGrvMixCF(SCJ->CJ_XGRPCLI, SCJ->CJ_XLTPROC)}, "Aguarde","Calculando descontos da Holding, por volume ...")
           */        

           Processa({|| U_xCalcMargem(@aMargem, SCJ->CJ_CLIENT, SCJ->CJ_LOJAENT, SCJ->CJ_NUM, 2, .T.)}, "Aguarde","Calculando Margem da Holding...")
        Endif

        // Posiciona os Totais do Grupo de Pedidos em Analise
        nPesq := Ascan(aTotais, {|X| Alltrim(X[1]) == Alltrim(cHolding)})

        // Atualiza a margem media, desconto medio e Totais do Grupo no pedido posicionado.
        RecLock('SCJ',.F.)
        SCJ->CJ_XMCGRP  := aMargem[3]
        SCJ->CJ_XDESGRP := aMargem[4]	
        SCJ->CJ_XLTGRP  := aTotais[nPesq][3]
        SCJ->CJ_XPBGRP  := aTotais[nPesq][4]
        MsUnlock()

        nDescTot := SCJ->(CJ_DESC1 + CJ_XDESADC)

        aBloq := U_xRegraDsc(cHolding, lDescMix, lDescCF, lDescLog)


        // Adicona dados do pedido no array.
        //              01              , 02          ,  03  , 04        , 05        , 06        , 07       , 08        , 09        , 10       , 11        , 12       , 13       , 14                                              , 15      , 16
        Aadd(aPedidos, {ORCX->CJ_XGRPCLI, ORCX->CJ_NUM, cNome, CJ_XDESSCO, CJ_XDESFIN, CJ_XDESLOG, CJ_XDESCF, CJ_XDESMIX, CJ_XDESADC, nDescTot , CJ_XDESGRP, CJ_XMCIND, CJ_XMCGRP, iif(!aBloq[1], "Doc.Bloqueado", "Doc.Liberado") , aBloq[2], SCJ->(Recno())})
        
        // Pega menor margem de Grupo, maior desconto MIX/CF entre os pedidos
        nMargem := MIN(nMargem , SCJ->CJ_XMCGRP)
        nDescMix:= MAX(nDescMix, SCJ->CJ_XDESMIX)
        nDescCF := MAX(nDescCF , SCJ->CJ_XDESCF)
        nDescLog:= MAX(nDescLog, SCJ->CJ_XDESLOG)
        nDescAD := MAX(nDescAD , SCJ->CJ_XDESADC)
        cLotePrc:= IIF(Empty(cLotePrc), SCJ->CJ_XLTPROC, cLotePrc)

        dbSelectArea("ORCX")
        dbSkip()
    Enddo

    // Posiciona os Totais do Grupo de Pedidos em Analise
    nPesq := Ascan(aTotais, {|X| Alltrim(X[1]) == Alltrim(cHolding)})

    //--------------------------------------------
    //[INICIO] - Aplicação da Regra de Descontos
    //--------------------------------------------
    cMsg := ""

    // Validação do Desconto Adicional
    IF nDescAD > 0
        aTotais[nPesq][7] := .F.
        cMsg += "Desconto Adicional!"+ENTER
    Endif 


    // Validação do Desconto Logisitico
    IF  (nDescLog > 0 .And. !lDescLog) //.OR. (nDescLog > 0 .And. Day(SCJ->CJ_EMISSAO) > GETMV("QE_DTDESLG")) 
        aTotais[nPesq][7] := .F.
        cMsg += "Desconto Logistico!"+ENTER
    Endif  

    // Validação do Desconto MIX
    IF (aTotais[nPesq][5] < nVlrMIX .And. nDescMix > 0) .OR. (nDescMix > nPercMIX) .OR. (nDescMix > 0 .And. !lDescMix)
        aTotais[nPesq][7] := .F.
        cMsg += "Desconto MIX!"+ENTER
    Endif  

    // Validação do Desconto Carga Fechada
    IF (aTotais[nPesq][4] < nPesoCMI .And. nDescCF > 0) .OR. (nDescCF > nPercCF) .OR. (nDescCF > 0 .And. !lDescCF)
        aTotais[nPesq][7] := .F.
        cMsg += "Desconto C.Fechada!"+ENTER
    Endif  

    // Validação da Margem
    IF nMargem < nPercMC
        aTotais[nPesq][7] := .F.
        cMsg += "MC do Grupo!"+ENTER
    Endif  

    aTotais[nPesq][8] := cMsg
    //--------------------------------------------
    //[TERMINO] - Aplicação da Regra de Descontos
    //--------------------------------------------

    IF Len(aPedidos) > 0
        // Efetua Agrupamento, Liberação/Bloqueio dos Pedidos
        FwMsgRun( ,{ || fLiberar(aPedidos, aTotais[nPesq][7], cMsg, cLotePrc) }, , 'Liberando Orçamentos! aguarde...' )
    Endif

    dbSelectArea("ORCX")
Enddo 
//--------------------------------------------------------------------------
// [TERMINO ] - Rotina para identificar os pedidos e analisar suas 
// caracteristicas individualmente.
//--------------------------------------------------------------------------


IF vpParTipLib == 2 // Simulação
    fReport(aItens)
Endif

dbCloseArea()
Return

/*
| Função...: xRegraDsc()
| Autor....: Paulo Rogerio
| Data.....: 13/07/2023
| Retorno..: Nenhum
| Descricão: Valida a regra de desconto por documento.
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User  Function xRegraDsc(cHolding, lDescMix, lDescCF, lDescLog)
Local lRet  := .T.
LocAL aRet  := {}
Local nPesq := Ascan(aTotais, {|X| Alltrim(X[1]) == Alltrim(cHolding)})
Local cMsg  := ""

//--------------------------------------------
//[INICIO] - Aplicação da Regra de Descontos
//--------------------------------------------

// Validação do Desconto Adicional
IF SCJ->CJ_XDESADC > 0
    lRet := .F.
    cMsg += "Desconto Adicional, "
Endif 

// Validação do Desconto Logistico
IF (SCJ->CJ_XDESLOG > 0 .And. !lDescLog) .OR. (SCJ->CJ_XDESLOG > nPercLog) .OR. (SCJ->CJ_XDESLOG > 0 .And. Day(SCJ->CJ_EMISSAO) > GETMV("QE_DTDESLG")) 
    lRet := .F.
    cMsg += "Desconto Logistico, "
Endif


// Validação do Desconto MIX
IF (aTotais[nPesq][5] < nVlrMIX .And. SCJ->CJ_XDESMIX > 0) .OR. (SCJ->CJ_XDESMIX > nPercMIX) .OR. (SCJ->CJ_XDESMIX > 0 .And. !lDescMix)
    lRet := .F.
    cMsg += "Desconto MIX, "
Endif  

// Validação do Desconto Carga Fechada
IF (aTotais[nPesq][4] < nPesoCMI .And. SCJ->CJ_XDESCF > 0) .OR. (SCJ->CJ_XDESCF > nPercCF) .OR. (SCJ->CJ_XDESCF > 0 .And. !lDescCF)
    lRet := .F.
    cMsg += "Desconto C.Fechada, "
Endif  

// Validação da Margem
IF SCJ->CJ_XMCIND < nPercMC
    lRet := .F.
    cMsg += " MC Individual, "
Endif  

Aadd(aRet, lRet)
Aadd(aRet, cMsg)

//--------------------------------------------
//[FIM] - Aplicação da Regra de Descontos
//--------------------------------------------
Return(aRet)

/*
| Função...: fLiberar()
| Autor....: Paulo Rogerio
| Data.....: 07/07/2023
| Retorno..: Nenhum
| Descricão: Agrupar e Liberar ou Bloquear os Orçamentos.
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
Static Function fLiberar(aPedidos, lLiberado, cMensagem, cLotePrc)
Local nX       := 0
Local cObserv  := ""
Local aArea    := {}

Local aUser    := {}
Local lAdmin   := .F. //UPPER(cUserName)  $ SuperGetMV("ES_MT415BR", .T., .F.)
Local nUsrNivel:= 5

// Declaração de Variaveis da Rotina Padrão de Oiberação
Private aHeadC6  := {}
Private aHeadD4  := {}

// Pega o Nivel de campo do usuário
PswOrder(1) 
If PswSeek(__cUserId,.T.)
   aUser 	:= PswRet(1) 
   nUsrNivel:= aUser[1,25]
EndIf

lAdmin := nUsrNivel >= 7 .Or. "ADMIN" $ Upper(cUserName)

// Define mensagem para gravação no arquivo de log.
IF vpParTipLib == 1
    cObserv  := "Procesamento em:" + dtoc(dDataBase) + " as " + Time() + ENTER
    cObserv  += "Usuário:" + cUserName + ENTER
    cObserv  += "Grupo:" + aPedidos[1][1] + ENTER

    cObserv  += "[Observações:]" + ENTER
    cObserv  += cMensagem
Else
    cObserv  := "Simulação em:" + dtoc(dDataBase) + " as " + Time() + ENTER
    cObserv  += "Usuário:" + cUserName + ENTER
    cObserv  += "Grupo:" + aPedidos[1][1] + ENTER
Endif

//IF !Empty(Rtrim(aPedidos[nX][15]) + Strtran(Rtrim(cMensagem), ENTER, ", "))
//    cObserv += "** Motivo Bloqeuio **  DOC: "+Rtrim(aPedidos[nX][15]) + ". LOTE:" + IIF(!Empty(cMensagem), Strtran(Rtrim(cMensagem), ENTER, ", "), "") + ENTER
//Endif    

cObserv  += Replicate("-", 60)

For nX := 1 to Len(aPedidos)
    dbSelectArea("SCJ")
    dbSetOrder(1)
    dbSeek(xFilial("SCJ")+aPedidos[nX][2])

    IF Empty(cLotePrc)
        cLotePrc := GetSxeNum("ZZ5", "ZZ5_NUMLOT")
        ConfirmSX8() //RollbackSX8()
    Endif

    // Atualiza Status do orçamento.
    Reclock("SCJ", .F.)
    SCJ->CJ_XLTPROC:= cLotePrc

    IF vpParTipLib == 1
        SCJ->CJ_STATUS := iif(!lLiberado, "F", "A") // F =Bloqueado, A=aberto
        SCJ->CJ_XLIBER := iif(!lLiberado, " ", "A") // ""=Bloqueado, A=Aberto"
        SCJ->CJ_XBLOQ  := iif(!lLiberado, "S", "N") 

        IF !lLiberado
            SCJ->CJ_XMOTBLQ := aPedidos[nX][15] //IIF(!Empty(cMensagem), Strtran(Rtrim(cMensagem), ENTER, " | "), "") // 15 - Ocorrências
        Else
            SCJ->CJ_XMOTBLQ := ""
        Endif
    Endif

    MsUnlock()


    IF lLiberado .And. vpParTipLib == 1 
        //----------------------------------------------------
        // Altera parametros de liberação da rotina padrão
        //----------------------------------------------------
        dbSelectArea("SX1")
        aArea := GetArea()

        dbSetOrder(1) // X1_GRUPO, X1_ORDEM, R_E_C_N_O_, D_E_L_E_T_
        dbSeek(padr("MT416A", 10)+'01')

        Reclock("SX1", .F.)
        X1_CNT01 := aPedidos[nX][2]
        MsUnLock()

        dbSkip()

        Reclock("SX1", .F.)
        X1_CNT01 := aPedidos[nX][2]
        MsUnLock()

        dbSkip()

        Reclock("SX1", .F.)
        X1_CNT01 := dtoc(vpParEmiDe)
        MsUnLock()

        dbSkip()

        Reclock("SX1", .F.)
        X1_CNT01 := dtoc(vpParEmiAte)
        MsUnLock()

        dbSkip()

        Reclock("SX1", .F.)
        X1_CNT01 := "Não"
        MsUnLock()

        Pergunte("MT416A",.F.)
        RestArea(aArea)

        // Executa rotina de liberação
        MA416Proc()
    Else
        IF vpParTipLib == 2 // Simulação
            aAdd(aItens,{lLiberado,; // 01 - Legenda   --- {iif(lLiberado, oOk, oNo)
                 aPedidos[nX][03],; // 02 - Grupo ou Cliente
                 aPedidos[nX][02],; // 03 - Orçamento  
                 aPedidos[nX][04],; // 04 - Desconto Score
                 aPedidos[nX][05],; // 05 - Desconto Financeiro
                 aPedidos[nX][06],; // 06 - Desconto Logistico
                 aPedidos[nX][07],; // 07 - Desconto Carga Fechada
                 aPedidos[nX][08],; // 08 - Desconto Mix
                 aPedidos[nX][09],; // 09 - Desconto Adicioonal
                 aPedidos[nX][10],; // 10 - Desconto Total Individual
                 aPedidos[nX][11],; // 11 - Desconto Total Grupo
                 IIF(lAdmin, aPedidos[nX][12], "***,**"),; // 12 - Margem Individual
                 IIF(lAdmin, aPedidos[nX][13], "***,**"),; // 13 - Margem Grupo
                 aPedidos[nX][14],; // 14 - Status Doc.
                 "DOC: "+Rtrim(aPedidos[nX][15]) + ". LOTE:" + IIF(!Empty(cMensagem), Strtran(Rtrim(cMensagem), ENTER, ", "), ""),; // 15 - Ocorrências
                 aPedidos[nX][16]}) // 16 - Recno SCJ

                 //IIF(lStatusGrup, IIF(lLiberado, "Liberado!","Bloqueado"), aPedidos[nX][14])}) // 14 - Observação
        Endif
    Endif
Next

// Cria Log de Processamento de Lotes
dbSelectArea("ZZ5")
dbSetOrder(1)
dbSeek(xFilial("ZZ5")+cLotePrc)
IF !Found()
    Reclock("ZZ5", .T.)
    ZZ5_FILIAL := xFilial("ZZ5")
    ZZ5_NUMLOT := cLotePrc
    ZZ5_DATA   := dDataBase
    ZZ5_HORA   := Time()
    ZZ5_USER   := cUserName
    ZZ5_OBS    := cObserv
    ZZ5_STATUS := "A"
    ZZ5_MTBLOT := Strtran(Rtrim(cMensagem), ENTER, " | ")
    MsUnlock()
Else
    Reclock("ZZ5", .F.)
    ZZ5_OBS    := cObserv + ENTER + ZZ5_OBS 
    ZZ5_MTBLOT := Strtran(Rtrim(cMensagem), ENTER, " | ")
    MsUnlock()        
Endif

/*
Paulo Rogério
08/08/2023
Observação: Chamada do fReport transferiada para a Function fProcessar

IF vpParTipLib == 2 // Simulação
    fReport(aItens)
Endif
*/

Return

/*
| Função...: fReport()
| Autor....: Paulo Rogerio
| Data.....: 13/07/2023
| Retorno..: Nenhum
| Descricão: Mostra Resultado da simulação de Luberação dos Orçamentos.
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
Static Function fReport(aItens)
Local oDlg	
Local oOk   := LoaDbitmap(GetResources(),"BR_VERDE")	 // Verde
Local oNo   := LoaDbitmap(GetResources(),"BR_VERMELHO")  // Vermelho	
Local oPanel
Local oLbx

Local nLinInic := 1
Local nColInic := 5
Local nLargura := 530
Local nAltura  := 220

Local nPosDlg1 :=500
Local nPosDlg2 :=1090

Local nPosBot  := 230

DEFINE MSDIALOG oDlg TITLE "SIMULAÇÃO DE LIBERAÇÃO DOS ORÇAMENTOS" FROM 0,0 TO nPosDlg1,nPosDlg2 PIXEL
oPanel := tPanel():New(nLinInic,nColInic,"",oDlg   ,,,,,CLR_WHITE,nLargura,nAltura)


@ nPosBot,500 BUTTON "Fechar"       SIZE 35,13 PIXEL OF oDlg ACTION oDlg:End()
@ nPosBot,400 BUTTON "Historico"    SIZE 35,13 PIXEL OF oDlg ACTION fHistorico(oLbx, aItens)
@ nPosBot,450 BUTTON "Visualizar"   SIZE 35,13 PIXEL OF oDlg ACTION fVisualizar(oLbx,  aItens) // A415Visual("SCJ", oLbx:nAt, 2) //

@ nLinInic+2,nColInic+2 LISTBOX oLbx FIELDS HEADER "Lote",;
             "Holding/Cliente",;
             "Orçam.",;  
             "Des.Sco",;
             "Des.Fin",;
             "Des.Log",;
             "Des.CF",;
             "Des.Mix",;
             "Des.Adc",;
             "Des.DOC",;
             "Des.GRP",;
             "MC.DOC",;
             "MC.GRP",;
             "Status Doc.",;
             "Ocorrencias no Lote de Processado",;
             "Recno" SIZE nLargura-3,nAltura-3 NOSCROLL OF oPanel PIXEL ON   dblClick(  fVisualizar(oLbx, aItens)) //   dblClick(aItens[oLbx:nAt,1] := !aItens[oLbx:nAt,1],oLbx:Refresh())

oLbx:SetArray(aItens)

oLbx:bLine:={|| {If(aItens[oLbx:nAt,1],oOk,oNo),;
                 aItens[oLbx:nAt,02],; // 02 - Grupo ou Cliente
                 aItens[oLbx:nAt,03],; // 03 - Orçamento  
                 aItens[oLbx:nAt,04],; // 04 - Desconto Score
                 aItens[oLbx:nAt,05],; // 05 - Desconto Financeiro
                 aItens[oLbx:nAt,06],; // 06 - Desconto Logistico
                 aItens[oLbx:nAt,07],; // 07 - Desconto Carga Fechada
                 aItens[oLbx:nAt,08],; // 08 - Desconto Mix
                 aItens[oLbx:nAt,09],; // 09 - Desconto Adicioonal
                 aItens[oLbx:nAt,10],; // 10 - Desconto Total Individual
                 aItens[oLbx:nAt,11],; // 11 - Desconto Total Grupo
                 aItens[oLbx:nAt,12],; // 12 - Margem Individual
                 aItens[oLbx:nAt,13],; // 13 - Margem Grupo
                 aItens[oLbx:nAt,14],; // 14 - Status
                 aItens[oLbx:nAt,15],; // 15 - Ocorrencias
                 aItens[oLbx:nAt,16]}} // 16 - Recno


//@ 210,310 CHECKBOX oChk VAR lChk PROMPT "Marca/Desmarca" SIZE 60,007 PIXEL OF oDlg;
//ON CLICK(Iif(lChk,Marca(lChk),Marca(lChk)))

oLbx:Refresh()

ACTIVATE MSDIALOG oDlg CENTERED

Return(.F.) 

/*
| Função...: fVisualizar()
| Autor....: Paulo Rogerio
| Data.....: 30/08/2023
| Retorno..: Nenhum
| Descricão: Visualizar o Orçamento de Venda.
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
Static Function fVisualizar(oLbx, aItens)
Local nRecno := SCJ->(Recno())
Local aArea := GetArea()

dbSelectArea("SCJ")
dbGoto(aItens[oLbx:nAt][16])

    A415Visual("SCJ", aItens[oLbx:nAt][16], 2)

dbSelectArea("SCJ")
dbGoto(nRecno)

RestArea(aArea)
Return 

/*
| Função...: fHistorico()
| Autor....: Paulo Rogerio
| Data.....: 30/08/2023
| Retorno..: Nenhum
| Descricão: Mostra o Histórico de Liberação do Orçamento de Venda.
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
Static Function fHistorico(oLbx, aItens)
Local nRecno := SCJ->(Recno())
Local aArea := GetArea()

dbSelectArea("SCJ")
dbGoto(aItens[oLbx:nAt][16])

U_QEMA415HI()

dbSelectArea("SCJ")
dbGoto(nRecno)

RestArea(aArea)
Return 
