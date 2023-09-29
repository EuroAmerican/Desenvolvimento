#include "rwmake.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#define ENTER CHR(13) + CHR(10)

/*
| Função...: QEMA415NT()
| Autor....: Paulo Rogerio
| Data.....: 29/09/2023
| Retorno..: Nenhum
| Descricão: Estornar Notificação de Liberação dos Orçamentos.
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User Function QEMA415NT()
Local aArea		 := GetArea()
Local aAreaCK    := SCK->(GetArea())
Local aAreaCJ	 := SCJ->(GetArea())
Local aAreaB1	 := SB1->(GetArea())
Local aAreaA1	 := SA1->(GetArea())
Local aAreaF4	 := SF4->(GetArea())
Local aAreaA3	 := SA3->(GetArea())

Private _cPerg:="QEMA415NT"
Private _aRegs:={}

Private vpParEmiDe := ""
Private vpParEmiAte:= ""
Private vpParHolDe := ""
Private vpParHolAte:= ""

IF !U_xFilPComl() 
    MsgAlert("Rotina disponivel apenas para as empresas Qualy e Phoenix!")
    Return
Endif

IF !UPPER(cUserName)  $ SuperGetMV("ES_MT415BR", .T., .F.)
    MsgAlert("Usuário não Autorizado!", "Politica Comercial")
    Return
Endif

//-----------|Grupo|Ord|Pergta                 |Pergunta              |Pergunta              |Variavel|Tip|Ta|D|P|GSC|Va|Var01     |Def Port       |De|De|Cn|Va|Def Port2      |De|De|Cn|Va|Def Port3    |De|De|Cn|Va|Def Port4    |De|De|Cn|Va|Def Port5  |De|De|Cn|F3|P |GRP
//-----------|     |em |Portug                 |Espanhol              |Ingles                |        |   |ma|e|r|   |li|          |               |f |f |te|r |               |f |f |te|r |             |f |f |te|r |             |f |f |te|r |           |f |f |te|  |Y |SXG
//-----------|     |   |                       |                      |                      |        |   |nh|c|e|   |d |          |               |Es|En|01|2 |               |Es|En|02|3 |             |Es|En|03|4 |             |Es|En|05|5 |           |Es|En|05|  |M |
AAdd(_aRegs,{_cPerg,"01","Emissão de         ?","Emissão de         ?","Emissão de         ?","mv_ch1","D",08,0,0,"G","","mv_par01",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
AAdd(_aRegs,{_cPerg,"02","Emissão ate        ?","Emissão ate        ?","Emissão ate        ?","mv_ch2","D",08,0,0,"G","","mv_par02",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
AAdd(_aRegs,{_cPerg,"03","Holding de         ?","Holding de         ?","Holding de         ?","mv_ch3","C",06,0,0,"G","","mv_par03",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","","ACY"   ,"",""})
AAdd(_aRegs,{_cPerg,"04","Holding ate        ?","Holding ate        ?","Holding ate        ?","mv_ch4","C",06,0,0,"G","","mv_par04",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","","ACY"   ,"",""})

U_FSX1FUNC(_aRegs, _cPerg)

IF !Pergunte(_cPerg,.T.)
    Return
Endif

vpParEmiDe := mv_par01
vpParemiAte:= mv_par02
vpParHolDe := mv_par03
vpParHolAte:= mv_par04

IF ! MSGYESNO( "Tem certeza que deseja estornar a notificação dos orçamentos", "ESTORNAR NOTIFICAÇÃO" )
    Return
Endif

Processa({|| fProcessar()}, "Aguarde","Processando o Estorno das Notificações...")

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
| Data.....: 29/09/2023
| Retorno..: Nenhum
| Descricão: Processamento do Estorno.
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
Local cLotePrc := ""
Local cObserv  := ""
Local cNotific := ""

//--------------------------------------------------------------------------
// [INICIO ] - Rotina para identificar os pedidos e analisar suas 
// caracteristicas individualmente.
//--------------------------------------------------------------------------
cQuery := "" 
cQuery += "SELECT CJ_FILIAL, CJ_NUM, CJ_CLIENT, CJ_LOJAENT, CJ_XGRPCLI, CJ_XLTPROC "+ENTER
cQuery += "  FROM "+RetSqlName("SCJ")+" AS SCJ WITH(NOLOCK)"+ENTER

cQuery += "  WHERE SCJ.D_E_L_E_T_ = ''"+ENTER
cQuery += "    AND CJ_FILIAL = '"+xFilial("SCJ")+"'"+ENTER
cQuery += "    AND CJ_EMISSAO BETWEEN '"+dtos(vpParEmiDe)+"' AND '"+dtos(vpParEmiAte)+"'"+ENTER
cQuery += "    AND CJ_XGRPCLI BETWEEN '"+vpParHolDe+"' AND '"+vpParHolAte+"'"+ENTER
cQuery += "    AND CJ_STATUS = 'A'"+ENTER
cQuery += "    AND CJ_XLIBER = 'P'"+ENTER

cQuery += " ORDER BY CJ_FILIAL, CJ_XGRPCLI, CJ_CLIENT, CJ_LOJAENT, CJ_NUM"

IF Select("ORCX")
    ORCX->(dbCloseArea())
Endif

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "ORCX", .F., .T.)
dbSelectArea("ORCX")
dbGotop()    

Do While !Eof()
    // Define o número do novo lote de processamento.
    IF Empty(cLotePrc)
        cLotePrc := GetSxeNum("ZZ5", "ZZ5_NUMLOT")
        ConfirmSX8() //RollbackSX8()

        dbSelectArea("ACY")
        dbSetOrder(1)
        dbSeek(xFilial("ACY")+ORCX->CJ_XGRPCLI)

        // Define mensagem para gravação no arquivo de log.
        cObserv  := "Processamento em:" + dtoc(dDataBase) + " as " + Time() + ENTER
        cObserv  += "Usuário:" + cUserName + ENTER
        cObserv  += "Grupo:" + Alltrim(ACY->ACY_DESCRI) + ENTER

        cObserv  += "[Observações:]" + ENTER
        cObserv  += "Lote originado por orçamentos com notificação de Liberação."
    Endif

    cNotific := ""

    cNotific  := "Estorno da Notificação:" + dtoc(dDataBase) + " as " + Time() + ENTER
    cNotific  += "Usuário:" + cUserName + ENTER
    cNotific  += "Lote cancelado pela rotina de Estorno da Notificação de Liberação"

    dbSelectArea("ZZ5")
    dbSetOrder(1)
    dbSeek(xFilial("ZZ5")+ORCX->CJ_XLTPROC)

    IF Found() .And. ZZ5_STATUS <> "I"
        RecLock("ZZ5", .F.)
        ZZ5_OBS    := cObserv
        ZZ5_STATUS := "I"
        MsUnlock()
    Endif

    dbSelectArea("SCJ")
    dbSetOrder(1)
    dbSeek(xFilial("SCJ")+ORCX->CJ_NUM)         

    IF Found()
        RecLock("SCJ", .F.)
        SCJ->CJ_XLTPROC:= cLotePrc
        SCJ->CJ_STATUS := "A" // A=Aberto
        SCJ->CJ_XLIBER := "" 
        SCJ->CJ_XBLOQ  := ""          
        MsUnlock()        
    Endif

    dbSelectArea("ORCX")
    dbSkip()     
Enddo

dbCloseArea()

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
    ZZ5_MTBLOT := ""
    MsUnlock()
Endif

MsgInfo("Termino de Processamento!"+ENTER+" Execute a liberação do lote, a fim de aplicar as regras de validação da politica comercial.", "Politica Comercial")
Return
