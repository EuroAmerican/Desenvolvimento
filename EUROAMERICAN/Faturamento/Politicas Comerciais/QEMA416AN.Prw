#include "rwmake.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#define ENTER CHR(13) + CHR(10)

/*
| Fun��o...: QEMA416AN()
| Autor....: Paulo Rogerio
| Data.....: 07/08/2023
| Retorno..: Nenhum
| Descric�o: Analise do Or�amento de Venda Bloqueado.
|
| Observac.: 
| Objetivo.: 
| Documenta��o: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Altera��o
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User Function QEMA416AN()
Local aArea		 := GetArea()
Local aAreaCK    := SCK->(GetArea())
Local aAreaCJ	 := SCJ->(GetArea())
Local aAreaB1	 := SB1->(GetArea())
Local aAreaA1	 := SA1->(GetArea())
Local aAreaF4	 := SF4->(GetArea())
Local aAreaA3	 := SA3->(GetArea())

IF !U_xFilPComl() 
    MsgAlert("Rotina disponivel apenas para as empresas Qualy e Phoenix!", "Politicas Comerciais")
    Return
Endif

IF SCJ->(CJ_STATUS <> "F")
    MsgAlert("Este or�amento n�o est� Bloqueado!","Politicas Comerciais")
    Return
Endif

Processa({|| fProcessar()}, "Aguarde","Processando os or�amentos...")

RestArea(aAreaCK)
RestArea(aAreaCJ)
RestArea(aAreaB1)
RestArea(aAreaA1)
RestArea(aAreaF4)
RestArea(aAreaA3)
RestArea(aArea)

Return


/*
| Fun��o...: fProcessar()
| Autor....: Paulo Rogerio
| Data.....: 07/08/2023
| Retorno..: Nenhum
| Descric�o: Processamento e analise dos Or�amento de Vendas.
|
| Observac.: 
| Objetivo.: 
| Documenta��o: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Altera��o
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
Static Function fProcessar()
Local cQuery   := ""
Local cChave   := ""
Local cMsg     := ""
Local cLotePrc := ""
Local aPedidos := {}
Local nDescTot := 0

Local cHolding := ""
Local cNome    := ""

//--------------------------------------------------------------------------
// [INICIO ] - Rotina para identificar os pedidos e analisar suas 
// caracteristicas individualmente.
//--------------------------------------------------------------------------
cQuery := "" 
cQuery += "       SELECT CJ_FILIAL, CJ_NUM, CJ_CLIENT, CJ_LOJAENT, CJ_XGRPCLI "+ENTER 
cQuery += "	        FROM "+RetSqlName("SCJ")+" AS SCJ WITH(NOLOCK)"+ENTER
cQuery += "         WHERE SCJ.D_E_L_E_T_ = ''"+ENTER
cQuery += "           AND CJ_FILIAL = '"+xFilial("SCJ")+"'"+ENTER
cQuery += "           AND CJ_XLTPROC = '"+SCJ->CJ_XLTPROC+"'"+ENTER
cQuery += " ORDER BY CJ_FILIAL, CJ_XGRPCLI, CJ_CLIENT, CJ_LOJAENT, CJ_NUM"

IF Select("ORCX")
    ORCX->(dbCloseArea())
Endif

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "ORCX", .F., .T.)
dbSelectArea("ORCX")
dbGotop()    


cLotePrc:= SCJ->CJ_XLTPROC
cHolding:= ORCX->CJ_XGRPCLI
cChave  := ORCX->(CJ_FILIAL + CJ_XGRPCLI)
cMsg    := ""

nDescTot := 0
aPedidos := {}



IF !Right(cHolding, 2) == "XX" // Holding
    dbSelectArea("ACY")    
    dbSetOrder(1)     
    dbSeek(xFilial("ACY")+cHolding) 

    cNome := Alltrim(Padr((ACY->ACY_DESCRI), 40))
Endif 

Do While !Eof() //ORCX->(CJ_FILIAL + CJ_XGRPCLI) == cChave .and. !Eof()
    dbSelectArea("SCJ")
    dbSetOrder(1)
    dbSeek(xFilial("SCJ")+ORCX->CJ_NUM)         

    nDescTot := SCJ->(CJ_DESC1 + CJ_XDESADC)

    IF Right(cHolding, 2) == "XX" // Individual
        dbSelectArea("SA1")    
        dbSetOrder(1)    
        dbSeek(xFilial("SA1")+ORCX->CJ_CLIENT) 

        cNome    := Alltrim(Padr((SA1->A1_NOME), 40))
    Endif        

    dbSelectArea("SCJ")

    //cMsg := IIF(Empty(cMsg), Rtrim(CJ_XMOTBLQ), cMsg)

    //              01              , 02          ,  03  , 04        , 05        , 06        , 07       , 08        , 09        , 10       , 11        , 12       , 13       , 14                                                 , 15 , 16
    Aadd(aPedidos, {ORCX->CJ_XGRPCLI, ORCX->CJ_NUM, cNome, CJ_XDESSCO, CJ_XDESFIN, CJ_XDESLOG, CJ_XDESCF, CJ_XDESMIX, CJ_XDESADC, nDescTot , CJ_XDESGRP, CJ_XMCIND, CJ_XMCGRP, iif(CJ_XBLOQ == "S","Doc.Bloqueado","Doc.Liberado"), CJ_XMOTBLQ, SCJ->(Recno())})

    dbSelectArea("ORCX")
    dbSkip()
Enddo

dbCloseArea()

// Verifica se o Lote de Processamento esta liberado.
dbSelectArea("ZZ5")
dbSetOrder(1)
dbSeek(xFilial("ZZ5")+cLotePrc)
IF !Found()
    lLiberado := .F.
Else
    lLiberado := IIF(Empty(ZZ5_MTBLOT), .T., .F.)
Endif

cMsg := Rtrim(ZZ5_MTBLOT)

//dbSelectArea("ORCX")

//--------------------------------------------------------------------------
// [TERMINO ] - Rotina para identificar os pedidos e analisar suas 
// caracteristicas individualmente.
//--------------------------------------------------------------------------

IF Len(aPedidos) > 0
    // Efetua Agrupamento, Libera��o/Bloqueio dos Pedidos
    FwMsgRun( ,{ || fAgrupar(aPedidos, lLiberado, cMsg, cLotePrc) }, , 'Agrupando Or�amentos! aguarde...' )
Endif

Return

/*
| Fun��o...: fAgrupar()
| Autor....: Paulo Rogerio
| Data.....: 07/07/2023
| Retorno..: Nenhum
| Descric�o: Agrupar e Analisar os Or�amentos.
|
| Observac.: 
| Objetivo.: 
| Documenta��o: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Altera��o
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
Static Function fAgrupar(aPedidos, lLiberado, cMensagem, cLotePrc)
Local nX       := 0
Local aItens   := {}
Local aUser    := {}
Local lAdmin   := .F. 
Local nUsrNivel:= 5
Local cObsPvs  := ""

// Declara��o de Variaveis da Rotina Padr�o de Oibera��o
Private aHeadC6  := {}
Private aHeadD4  := {}

// Pega o Nivel de campo do usu�rio
PswOrder(1) 
If PswSeek(__cUserId,.T.)
   aUser 	:= PswRet(1) 
   nUsrNivel:= aUser[1,25]
EndIf

lAdmin := nUsrNivel >= 7 .Or. "ADMIN" $ Upper(cUserName)

For nX := 1 to Len(aPedidos)
    dbSelectArea("SCJ")
    dbSetOrder(1)
    dbSeek(xFilial("SCJ")+aPedidos[nX][2])

    IF !Empty(SCJ->CJ_XOBSADC)
        cObsPvs += "Or�amento:"+SCJ->CJ_NUM+ENTER
        cObsPvs +=  SCJ->CJ_XOBSADC+ENTER+chr(13)+chr(10)   
    Endif
    
    aAdd(aItens,{lLiberado,; // 01 - Legenda   --- {iif(lLiberado, oOk, oNo)
            aPedidos[nX][03],; // 02 - Grupo ou Cliente
            aPedidos[nX][02],; // 03 - Or�amento  
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
            "DOC: "+Rtrim(aPedidos[nX][15]) + ". LOTE:" +IIF(!Empty(cMensagem), Strtran(Rtrim(cMensagem), ENTER, ", "), ""),; // 15 - Ocorr�ncias
            aPedidos[nX][16]}) // 16 - Recno SCJ
Next


fAnalisar(aItens, cObsPvs, lAdmin)


Return

/*
| Fun��o...: fAnalisar()
| Autor....: Paulo Rogerio
| Data.....: 07/08/2023
| Retorno..: Nenhum
| Descric�o: Mostra Resultado dos or�amentos para analise.
|
| Observac.: 
| Objetivo.: 
| Documenta��o: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Altera��o
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
Static Function fAnalisar(aItens, cHistObs, lAdmin)
Local oOk   := LoaDbitmap(GetResources(),"BR_VERDE")	 // Verde
Local oNo   := LoaDbitmap(GetResources(),"BR_VERMELHO")  // Vermelho	
Local oPanel
Local oLbx
Local oHistObs

Local nLinInic := 1
Local nColInic := 5
Local nLargura := 530
Local nAltura  := 220

Local nDlglFin1 :=0650 //0500
Local nDlglFin2 :=1090

Local nLinBot  := 230
Local nLinObs  := 230

Private oConside
Private cConside := ""
Private oDlgAnalise	


DEFINE MSDIALOG oDlgAnalise TITLE "ANALISE DOS OR�AMENTOS" FROM 0,0 TO nDlglFin1,nDlglFin2 PIXEL
oPanel := tPanel():New(nLinInic,nColInic,"",oDlgAnalise   ,,,,,CLR_WHITE,nLargura,nAltura)

@ nLinObs   ,10 SAY "Observa��es do Representante:"   PIXEL OF oDlgAnalise
@ nLinObs+10,10 GET oHistObs Var cHistObs MEMO WHEN .F.  PIXEL OF oDlgAnalise SIZE 220, 70

@ nLinObs   ,240 SAY "Suas Considera��es:"   PIXEL OF oDlgAnalise
@ nLinObs+10,240 GET oConside Var cConside MEMO WHEN .T.  PIXEL OF oDlgAnalise SIZE 220, 70


@ nLinBot,500 BUTTON "Visualizar"   SIZE 35,13 PIXEL OF oDlgAnalise ACTION fVisualizar(oLbx,  aItens)
nLinBot+= 15
@ nLinBot,500 BUTTON "Historico"    SIZE 35,13 PIXEL OF oDlgAnalise ACTION fHistorico(oLbx,  aItens)
nLinBot+= 15

if lAdmin
    @ nLinBot,500 BUTTON "Liberar"      SIZE 35,13 PIXEL OF oDlgAnalise ACTION FwMsgRun( ,{ || fGravar(2, oLbx ,  aItens) }, , 'Liberando Or�amentos! aguarde...' )
    nLinBot+= 15
    @ nLinBot,500 BUTTON "Rejeitar"     SIZE 35,13 PIXEL OF oDlgAnalise ACTION FwMsgRun( ,{ || fGravar(1, oLbx ,  aItens) }, , 'Rejeitando Or�amentos! aguarde...') 
    nLinBot+= 15
Endif

@ nLinBot,500 BUTTON "Fechar"       SIZE 35,13 PIXEL OF oDlgAnalise ACTION oDlgAnalise:End()


@ nLinInic+2,nColInic+2 LISTBOX oLbx FIELDS HEADER "Lote",;
             "Holding/Cliente",;
             "Or�am.",;  
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
                 aItens[oLbx:nAt,03],; // 03 - Or�amento  
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


//@ 210,310 CHECKBOX oChk VAR lChk PROMPT "Marca/Desmarca" SIZE 60,007 PIXEL OF oDlgAnalise;
//ON CLICK(Iif(lChk,Marca(lChk),Marca(lChk)))

oLbx:Refresh()

ACTIVATE MSDIALOG oDlgAnalise CENTERED

Return(.F.) 

/*
| Fun��o...: fVisualizar()
| Autor....: Paulo Rogerio
| Data.....: 07/08/2023
| Retorno..: Nenhum
| Descric�o: Visualizar o Or�amento de Venda.
|
| Observac.: 
| Objetivo.: 
| Documenta��o: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Altera��o
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
| Fun��o...: fHistorico()
| Autor....: Paulo Rogerio
| Data.....: 07/08/2023
| Retorno..: Nenhum
| Descric�o: Mostra o Hist�rico de Libera��o do Or�amento de Venda.
|
| Observac.: 
| Objetivo.: 
| Documenta��o: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Altera��o
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


/*
| Fun��o...: fGravar()
| Autor....: Paulo Rogerio
| Data.....: 07/08/2023
| Retorno..: Nenhum
| Descric�o: Gravar a Libera��o ou Rejei��o do Or�amento de Venda.
|
| Observac.: 
| Objetivo.: 
| Documenta��o: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Altera��o
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
Static Function fGravar(nOpcao, oLbx, aItens)
Local nRecno   := SCJ->(Recno())
Local aArea    := GetArea()
Local nX       := 0
Local cLotePrc := ""
Local cHolding := ""
Local cRepres  := ""
Local cEmail   := ""
Local cCopia   := SUPERGETMV( "QE_MGCOMLQ",, "eulalia.ramos@qualivinil.com.br;eristeu.junior@qualivinil.com.br")


Local cObserv:= Strtran(Strtran(Strtran(cConside,".",""), "*", ""), "-","")

IF Len(Alltrim(cObserv)) < 15
    MsgAlert("Considera��es invalidas! Informe corretamente suas considera��es sobre a rejei��o ou libera��o dos or�amentos.", "Politicas Comerciais")
    Return
Endif

IF nOpcao == 1 // Rejeitar
    IF Aviso("REJEITAR OR�AMENTOS", "Confirma a Rejei��o do lote de or�amentos? ", {"Sim","N�o"}, 1) <> 1
        Return()
    Endif
Else
    IF Aviso("LIBERAR OR�AMENTOS", "Confirma a Libera��o do lote de or�amentos? ", {"Sim","N�o"}, 1) <> 1
        Return()
    Endif
Endif


For nX := 1 to Len(aItens)
    dbSelectArea("SCJ")
    dbGoto(aItens[nX][16])

    IF Empty(cHolding)
        dbSelectArea("SA1")    
        dbSetOrder(1)    
        dbSeek(xFilial("SA1")+SCJ->(CJ_CLIENT+CJ_LOJA)) 

        IF Empty(SA1->A1_GRPVEN) // Individual
            cHolding := Alltrim(Padr((SA1->A1_NOME), 40))
        Else          // Holding
            dbSelectArea("ACY")    
            dbSetOrder(1)     
            dbSeek(xFilial("ACY")+SA1->A1_GRPVEN) 
            cHolding := Alltrim(Padr((ACY->ACY_DESCRI), 40))
        Endif    

        cLotePrc := SCJ->CJ_XLTPROC
        cRepres  := SCJ->CJ_VEND1
    Endif

    IF nOpcao == 1 // Rejeitar
        Reclock("SCJ", .F.)
        SCJ->CJ_STATUS := "A"
        SCJ->CJ_XLIBER := "R"
        SCJ->CJ_XBLOQ  := "N"
        SCJ->CJ_XMOTBLQ:= ""
        MsUnlock()
    Else          // Liberado - Aprovado
        Reclock("SCJ", .F.)
        SCJ->CJ_STATUS := "A"
        SCJ->CJ_XLIBER := "M" // Manual
        SCJ->CJ_XBLOQ  := "N" 
        SCJ->CJ_XMOTBLQ:= ""
        MsUnlock()

        //----------------------------------------------------
        // Altera parametros de libera��o da rotina padr�o
        //----------------------------------------------------
        dbSelectArea("SX1")
        aArea := GetArea()

        dbSetOrder(1) // X1_GRUPO, X1_ORDEM, R_E_C_N_O_, D_E_L_E_T_
        dbSeek(padr("MT416A", 10)+'01')

        Reclock("SX1", .F.)
        X1_CNT01 := alltrim(aItens[nX][3])
        MsUnLock()

        dbSkip()

        Reclock("SX1", .F.)
        X1_CNT01 := Alltrim(aItens[nX][3])
        MsUnLock()

        dbSkip()

        Reclock("SX1", .F.)
        X1_CNT01 := dtoc(dDatabase-30)
        MsUnLock()

        dbSkip()

        Reclock("SX1", .F.)
        X1_CNT01 := dtoc(dDatabase+30)
        MsUnLock()

        dbSkip()

        Reclock("SX1", .F.)
        X1_CNT01 := "N�o"
        MsUnLock()

        Pergunte("MT416A",.F.)
        RestArea(aArea)

        // Executa rotina de libera��o
        MA416Proc() 
    Endif
Next

// Define mensagem para grava��o no arquivo de log.
cObserv  := "Procesamento em:" + dtoc(dDataBase) + " as " + Time() + chr(13)+chr(10)
cObserv  += "Usu�rio:" + cUserName +  chr(13)+chr(10)
cObserv  += "Grupo:" + cHolding+ chr(13)+chr(10)
cObserv  += "Status:" + iif(nOpcao == 1, "** Or�amentos Rejeitados **","** Or�amentos Aprovados **") + chr(13)+chr(10)

cObserv  += "[Observa��es:]" + chr(13)+chr(10)
cObserv  += cConside + chr(13)+chr(10)
cObserv  += Replicate("-", 60) + chr(13)+chr(10)

// Atualiza o Log de Processamento de Lotes
dbSelectArea("ZZ5")
dbSetOrder(1)
dbSeek(xFilial("ZZ5")+cLotePrc)
IF Found()
    Reclock("ZZ5", .F.)
    ZZ5_OBS    := cObserv + chr(13)+chr(10) + ZZ5_OBS 
    MsUnlock()        
Endif


// Define mensagem para grava��o no email de notifica��o.
cObserv  := '<html>'+ chr(13)+chr(10)
cObserv  += '<b><font size="3" face="Arial">Notifica��o sobre an�lise de or�amentos</font></b><br><br>'+ chr(13)+chr(10)

cObserv  += '<b><font size="2" face="Arial">Procesamento em: ' + dtoc(dDataBase) + " as " + Time()+'</b><br>'+ chr(13)+chr(10)
cObserv  += '<b><font size="2" face="Arial">Lote de Or�amentos: ' + cLotePrc+'</b><br>'+ chr(13)+chr(10)
cObserv  += '<b><font size="2" face="Arial">Analista: ' + cUserName +'</b><br>' +  chr(13)+chr(10)
cObserv  += '<b><font size="2" face="Arial">Grupo: '    + cHolding  +'</b><br>' + chr(13)+chr(10)
cObserv  += '<b><font size="2" face="Arial">Status: '   + iif(nOpcao == 1, "** Or�amentos Rejeitados **","** Or�amentos Aprovados **") +'</b><br><br>' + chr(13)+chr(10)

cObserv  += '<b><font size="3" face="Arial">Observa��es:</font></b><br>' + chr(13)+chr(10)
cObserv  += Strtran(cConside, chr(13)+chr(10), '<br') + chr(13)+chr(10)
cObserv  += '</html>'+ chr(13)+chr(10)

cObserv := upper(cObserv)

dbSelectArea("SA3")
dbSetOrder(1)
dbSeek(xFilial("SA3")+cRepres)
cEmail   := alltrim(SA3->A3_EMAIL)

// Envia email informativo para o repreentante.
U_QEMAIL08("paulo.santos@euroamerican.com.br", cCopia, "AN�LISE DE OR�AMENTO **TESTE** - "+cHolding+" - Lote:"+cLotePrc, cObserv,,.T.)

msginfo("** Colocar email do representante e retirar TESTE do Titulo **", "ATENCAO!!!")

dbSelectArea("SCJ")
dbGoto(nRecno)

oDlgAnalise:End()

RestArea(aArea)
Return

