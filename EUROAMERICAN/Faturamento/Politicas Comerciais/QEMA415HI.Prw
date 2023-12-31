#include "TOTVS.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"

#define ENTER CHR(13) + CHR(10)

/*
| Fun��o...: QEMA415HI()
| Autor....: Paulo Rogerio
| Data.....: 10/07/2023
| Retorno..: Nenhum
| Descric�o: Historico de Libera��o do Or�amento de Venda.
|
| Observac.: 
| Objetivo.: 
| Documenta��o: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Altera��o
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User Function QEMA415HI()
Local aArea		 := GetArea()
Local cLotPrc    := SCJ->CJ_XLTPROC
Local cTexto     := ""
Local cNome      := ""

IF !U_xFilPComl() 
    MsgAlert("Rotina disponivel apenas para as empresas Qualy e Phoenix!", "Politicas Comerciais")
    Return
Endif

IF Empty(SCJ->CJ_XLTPROC)
    MsgAlert("Este or�amento n�o possui historico para consulta!", "Politicas Comerciais")
    Return
Endif

IF Funname() == "MATA410"
    dbSelectArea("SC6")
    dbSetOrder(1)
    dbSeek(xFilial("SC6")+SC5->C5_NUM)

    IF Empty(SC6->C6_NUMORC)  
        MsgAlert("Este pedido n�o foi gerado por um or�amento de venda!", "Politicas Comerciais")
        RestArea(aArea)
        Return
    Endif

    dbSelectArea("SCJ")
    dbSetOrder(1)
    dbSeek(xFilial("SCJ")+Left(SC6->C6_NUMORC, 6))

    cLotPrc    := SCJ->CJ_XLTPROC

    IF Empty(SCJ->CJ_XLTPROC)
        MsgAlert("Este pedido n�o pertence a nova politica comercial!", "Politicas Comerciais")   
        RestArea(aArea) 
        Return
    Endif
Endif

dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+SCJ->(CJ_CLIENTE+CJ_LOJA))

IF Empty(SA1->A1_GRPVEN)
    cNome := Left(Alltrim(A1_NOME), 40)

    cTexto += Upper("Descontos Dispon�veis para o Cliente: ")+cNome+ENTER
    cTexto += "Score.....: "+IIF(A1_ZDSCSCO == "S", "Sim", "N�o")+ENTER
    cTexto += "Logistico.: "+IIF(A1_ZDSCLOG == "S", "Sim", "N�o")+ENTER
    cTexto += "Financeiro: "+IIF(A1_ZDSCFIN == "S", "Sim", "N�o")+ENTER
    cTexto += "C.Fechada.: "+IIF(A1_ZDSCCF  == "S", "Sim", "N�o")+ENTER
    cTexto += "Mix.......: "+IIF(A1_ZDSCMIX == "S", "Sim", "N�o")+ENTER

Else
    dbSelectArea("ACY")
    dbSetOrder(1)
    dbSeek(xFilial("ACY")+ACY->(SA1->A1_GRPVEN))

    cNome := Left(Alltrim(ACY_DESCRI), 40)

    cTexto += Upper("Descontos Dispon�veis para a Holding: ")+cNome+ENTER
    cTexto += "Score.....: "+IIF(ACY_ZDSCSC == "S", "Sim", "N�o")+ENTER
    cTexto += "Logistico.: "+IIF(ACY_ZDSCLG == "S", "Sim", "N�o")+ENTER
    cTexto += "Financeiro: "+IIF(ACY_ZDSCFI == "S", "Sim", "N�o")+ENTER
    cTexto += "C.Fechada.: "+IIF(ACY_ZDSCCF == "S", "Sim", "N�o")+ENTER
    cTexto += "Mix.......: "+IIF(ACY_ZDSCMI == "S", "Sim", "N�o")+ENTER
Endif

cTexto += Replicate("-", 120)+ENTER

cQuery := "SELECT CJ_NUM, CJ_CLIENTE, CJ_LOJA, CJ_DESC1, CJ_XDESSCO, CJ_XDESLOG, CJ_XDESFIN, CJ_XDESCF, CJ_XDESMIX, CJ_XDESADC, CONVERT(VARCHAR(1000), CJ_XOBSADC, 0)  AS CJ_XOBSADC"
cQuery += "  FROM "+RetSqlName("SCJ")+" AS SCJ"
cQuery += " WHERE CJ_FILIAL = '"+xFilial("SCJ")+"'"
cQuery += "   AND CJ_XLTPROC = '"+cLotPrc+"'"

IF Select("TMPX")
    TMPX->(dbCloseArea())
Endif

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMPX", .F., .T.)
dbSelectArea("TMPX")
dbGotop()    

//cTexto := "Tipo de Libera��o: "+cTipo+ENTER
cTexto += Upper("Descontos Concedidos: ")+ENTER
Do While !Eof()
    cTexto +="Or�amento..: "+CJ_NUM+ENTER
    cTexto +="Desc. Score: "+Str(CJ_XDESSCO, 6, 2) + ENTER
    cTexto +="Desc. Logistico: "+Str(CJ_XDESLOG, 6, 2)+ IIF(CJ_XDESLOG > 0 .AND. Day(SCJ->CJ_EMISSAO) > GETMV("QE_DTDESLG"), " ** Fora do Prazo ** ","") + ENTER
    cTexto +="Desc. Financeiro: "+Str(CJ_XDESFIN, 6, 2) + ENTER
    cTexto +="Desc. Mix..: "+Str(CJ_XDESMIX, 6, 2) + ENTER
    cTexto +="Desc. C.Fechada: "+Str(CJ_XDESCF , 6, 2) + ENTER 
    cTexto +="Desc. Adicional.: "+Str(CJ_XDESADC, 6, 2) + IIF(CJ_XDESADC > 0, " ** Necessita de Aprova��o ** ","") +ENTER
    cTexto +="*** Descto Total do Or�amento: [ "+Alltrim(Str(CJ_DESC1+CJ_XDESADC, 6, 2)) +" ]"  +ENTER

    IF !empty(Alltrim(CJ_XOBSADC))
        cTexto +=ENTER+"Observa��o.:"+ENTER
        cTexto +=Alltrim(CJ_XOBSADC)+ENTER
    Endif

    cTexto +=Replicate("-", 120)+ENTER

    dbSkip()
Enddo

TMPX->(dbCloseArea())

dbSelectArea("ZZ5")
dbSetOrder(1)
dbSeek(xFilial("ZZ5")+cLotPrc)

IF Found()
    IF !empty(Alltrim(ZZ5_MTBLOT))
        cTexto +=ENTER+"Motivo Bloqueio --> "+ENTER
        cTexto +=" ** " + Alltrim(ZZ5_MTBLOT)+" **"+ENTER
    Endif    

    cTexto +=ENTER + Padc("HISTORICO DE PROCESSAMENTO", 120)+ENTER
    cTexto += ZZ5_OBS

    cTexto +=Replicate("-", 120)+ENTER
Endif

fShowHistorico(cTexto)

RestArea(aArea)
Return

/*
| Fun��o...: fShowHistorico()
| Autor....: Paulo Rogerio
| Data.....: 10/07/2023
| Retorno..: Nenhum
| Descric�o: Apresenta historico na tela.
|
| Observac.: 
| Objetivo.: 
| Documenta��o: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Altera��o
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
Static Function fShowHistorico(cTexto)
Local oDlg
Local oTexto

Local nLinInic := 1
Local nColInic := 5
Local nLargura := 500
Local nAltura  := 220

Local nPosDlg1 :=500
Local nPosDlg2 :=1020

Local nPosBot  := 230


DEFINE FONT oFont1 NAME "courier" SIZE 10, 15 BOLD

cTexto := Upper(cTexto)


DEFINE MSDIALOG oDlg FROM 0,0 TO nPosDlg1,nPosDlg2 PIXEL TITLE "Historico de Processamento:"
@ nLinInic,nColInic GET oTexto  VAR  cTexto MEMO OF oDlg PIXEL SIZE nLargura, nAltura  // 243, 085 

@ nPosBot,450 BUTTON "Fechar"   SIZE 30,13 PIXEL OF oDlg ACTION oDlg:End()

oDlg:=GetWndDefault()
oDlg:nStyle=128

ACTIVATE MSDIALOG oDlg  CENTERED VALID .T.

Return

