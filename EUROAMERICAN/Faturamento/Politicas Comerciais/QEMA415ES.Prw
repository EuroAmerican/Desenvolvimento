#include "TOTVS.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#define ENTER CHR(13) + CHR(10)


/*
| Função...: QEMA415ES()
| Autor....: Paulo Rogerio
| Data.....: 12/07/2023
| Retorno..: Nenhum
| Descricão: Estorno da Liberação do Orçamento de Venda.
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User Function QEMA415ES()
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

IF SCJ->CJ_STATUS <> "A"
    IF Aviso("Politicas Comerciais - ESTORNO LIB", "O Estorno da Liberação retornará o status de todo o lote de orçamentos para 'Aberto' e incluirá os pedidos de vendas relacionados a eles. Deseja Continuar? ", {"Sim","Não"}, 2) <> 1
        Return
    Endif
Else 
    MsgAlert("Este orçamento não está liberado!", "Politicas Comerciais")
    Return
Endif


Processa({|| fEstornar()}, "Aguarde","Processando o Estorno da Liberação...")


RestArea(aAreaCK)
RestArea(aAreaCJ)
RestArea(aAreaB1)
RestArea(aAreaA1)
RestArea(aAreaF4)
RestArea(aAreaA3)
RestArea(aArea)

Return


/*
| Função...: fEstornar()
| Autor....: Paulo Rogerio
| Data.....: 12/07/2023
| Retorno..: Nenhum
| Descricão: Rotina de Estorno da Liberação.
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
Static Function fEstornar()
Local cNumPed   := ""
Local cNumOrc   := ""
Local cLotPrc   := ""
Local cQuery    := ""
Local cPedidos  := ""
Local cOrcamtos := ""
Local nQtItemLib:= 0
Local cObserv   := ""

Local aCabec := {}
Local aItens := {}
Local aLinha := {}


Public lMsErroAuto    := .F.
Public lAutoErrNoFile := .F.

cLotPrc := SCJ->CJ_XLTPROC

cQuery += "SELECT DISTINCT * FROM ("+ENTER
cQuery += " SELECT CJ_FILIAL, CJ_NUM, CK_NUMPV,"+ENTER
cQuery += "	       ISNULL((SELECT COUNT(*) FROM "+RetSqlName("SC9")+" AS SC9 WITH(NOLOCK) WHERE C9_FILIAL = CK_FILIAL AND C9_PEDIDO = CK_NUMPV AND C9_CLIENTE = CK_CLIENTE AND C9_LOJA = CK_LOJA AND SC9.D_E_L_E_T_ = ''),0) AS C9_QTDPV"+ENTER
cQuery += "   FROM "+RetSqlName("SCJ")+" AS SCJ WITH(NOLOCK)"+ENTER
cQuery += "  INNER JOIN "+RetSqlName("SCK")+" AS SCK WITH(NOLOCK) ON CK_FILIAL = CJ_FILIAL AND CK_NUM = CJ_NUM AND CK_CLIENTE = CJ_CLIENTE AND CK_LOJA = CJ_LOJA AND SCK.D_E_L_E_T_ = ''"+ENTER

cQuery += "  WHERE SCJ.D_E_L_E_T_ = ''"+ENTER
cQuery += "    AND CJ_FILIAL = '"+xFilial("SCJ")+"'"+ENTER
cQuery += "    AND CJ_XLTPROC = '"+cLotPrc+"'"+ENTER
cQuery += " ) AS QRY "

//cQuery += "	       SELECT COUNT(*) FROM "+RetSqlName("SC9")+" AS SC9 WITH(NOLOCK)"+ENTER
//cQuery += " ORDER BY CJ_FILIAL, A1_GRPVEN, CJ_CLIENT, CJ_LOJAENT, CJ_NUM"

IF Select("TMPX")
    TMPX->(dbCloseArea())
Endif

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMPX", .F., .T.)
dbSelectArea("TMPX")
dbGotop()    

Do While !Eof()
    nQtItemLib += TMPX->C9_QTDPV 
	cPedidos   += ","+alltrim(TMPX->CK_NUMPV)
    cOrcamtos  += ","+TMPX->CJ_NUM
    dbSkip()
Enddo

cPedidos := Subs(cPedidos , 2)
cOrcamtos:= Subs(cOrcamtos, 2)

IF nQtItemLib > 0
    TMPX->(dbCloseArea())

    MsgAlert("O ESTORNO não será possivel! Existem Pedidos de Vendas Liberados ou Faturados nesse lote de orçamentos. Verifique os Pedidos: "+cPedidos+".","Politicas Comerciais" )
    Return
Endif

Begin transaction 
    dbSelectArea("TMPX")
    dbGotop()

    Do While !Eof() .And. nQtItemLib == 0
        cNumPed := TMPX->CK_NUMPV
		cNumOrc := TMPX->CJ_NUM

        IF !Empty(cNumPed)
            aCabec  := {}
            aItens  := {}
            aLinha  := {}

            dbSelectArea("SC5")
            dbSetOrder(1)
            dbSeek(xFilial("SC5")+cNumPed)

            aadd(aCabec, {"C5_NUM",     C5_NUM    , Nil})
            aadd(aCabec, {"C5_TIPO",    C5_TIPO   , Nil})
            aadd(aCabec, {"C5_CLIENTE", C5_CLIENTE, Nil})
            aadd(aCabec, {"C5_LOJACLI", C5_LOJACLI, Nil})
            aadd(aCabec, {"C5_LOJAENT", C5_LOJAENT, Nil})
            aadd(aCabec, {"C5_CONDPAG", C5_CONDPAG, Nil})

            dbSelectArea("SC6")
            dbSetOrder(1)
            dbSeek(xFilial("SC6")+cNumPed)

            Do While SC6->(C6_FILIAL+C6_NUM+C6_CLI+C6_LOJA) == SC5->(C5_FILIAL+C5_NUM+C5_CLIENTE+C5_LOJACLI)
                aLinha  := {}

                aadd(aLinha,{"C6_ITEM"   , C6_ITEM   , Nil})
                aadd(aLinha,{"C6_PRODUTO", C6_PRODUTO, Nil})
                aadd(aLinha,{"C6_QTDVEN" , C6_QTDVEN , Nil})
                aadd(aLinha,{"C6_PRCVEN" , C6_PRCVEN , Nil})
                aadd(aLinha,{"C6_PRUNIT" , C6_PRUNIT , Nil})
                aadd(aLinha,{"C6_VALOR"  , C6_VALOR  , Nil})
                aadd(aLinha,{"C6_TES"    , C6_TES    , Nil})

                aadd(aItens, aLinha)

                dbSkip()
            Enddo

            MSExecAuto({|a, b, c| MATA410(a, b, c)}, aCabec, aItens, 5)

            If lMsErroAuto
                //MsgAlert("Ocorreu um erro na exclusão do Pedido de Venda: "+cNumPed+". O processo será abortado!")
                DisarmTransaction()
                MostraErro()

                Exit
            EndIf
        Endif

		dbSelectArea("SCJ")
		dbSetOrder(1)
		dbseek(xFilial("SCJ")+cNumOrc)

		Reclock("SCJ", .F.)
		CJ_STATUS := "A"
		CJ_XLIBER := " "
		CJ_XBLOQ  := "N"
        CJ_XMOTBLQ:= ""

		MsUnlock()

		dbSelectArea("SCK")
		dbSetOrder(1)
		dbseek(xFilial("SCK")+cNumOrc)
		Do While !Empty(cNumPed) .And. SCK->(CK_FILIAL+CK_NUM+CK_CLIENTE+CK_LOJA) == SCJ->(CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA)
			Reclock("SCK", .F.)
			SCK->CK_NUMPV:= ""
			MsUnlock()

			dbSkip()
		Enddo

        dbSelectArea("TMPX")
        dbSkip()
    Enddo
End Transaction

TMPX->(dbCloseArea())

IF lMsErroAuto
	MsgAlert("Ocorreu um erro na exclusão do Pedido de Venda: "+cNumPed+". O processo foi abortado!")
else
    //==============================================
    // Grava Log de Processamento do Estorno
    //==============================================

    cObserv  := "Procesamento do Estorno em:" + dtoc(dDataBase) + " as " + Time() + ENTER
    cObserv  += "Usuário:" + cUserName + ENTER

    //cObserv  += "Grupo:" + aPedidos[1][1] + ENTER

    cObserv  += "[Observações:]" + ENTER
    cObserv  += "Realizado o estorno dos Orçamentos: "+cOrcamtos + ENTER
    cObserv  += Replicate("-", 60)
    
    // Cria Log de Processamento de Lotes
    dbSelectArea("ZZ5")
    dbSetOrder(1)
    dbSeek(xFilial("ZZ5")+cLotPrc)
    IF Found()
        Reclock("ZZ5", .F.)
        ZZ5_OBS    := cObserv + ENTER + ZZ5_OBS 
        MsUnlock()        
    Endif    
Endif

Return

