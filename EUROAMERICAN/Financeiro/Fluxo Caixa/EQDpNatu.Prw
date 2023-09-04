#Include "Protheus.ch"
#Include "RwMake.ch" 
#Include "Topconn.ch"

#define ENTER chr(13) + chr(10)
#define CRLF  chr(13) + chr(10)

User Function xDpNatureza()

    // PREPARAÇÃO DE AMBIENTE EM CASO DE ESTADO DE JOB

   
    If !IsBlind()
        RPCSetEnv("10", "0803")

        // GERA EXCEÇÃO
        U_fExecDpNat() 
    Else
    
        IF Aviso( "ATENÇÃO", "Deseja continuar com o de/para de naturezas financeiras: As tabelas FIW e FIV serão afetadas.", { "Não", "Sim" }, 1 ) <> 2
            MsgInfo("Rotina Abortada!", "De/Para Naturezas")
            Return
        Endif

        FwMsgRun( ,{ || U_fExecDpNat() }, , 'Processando... Aguarde!' )   
    Endif

    // ENCERRAMENTO DE AMBIENTE EM CASO DE ESTADO DE JOB
    If !IsBlind()
        RPCClearEnv()
    EndIf
    
/*
    IF Aviso( "ATENÇÃO", "Deseja continuar com o de/para de naturezas financeiras: As tabelas FIW e FIV serão afetadas.", { "Não", "Sim" }, 1 ) <> 2
        MsgInfo("Rotina Abortada!", "De/Para Naturezas")
        Return
    Endif

    FwMsgRun( ,{ || U_fExecDpNat() }, , 'Processando... Aguarde!' )
    */
Return 

User Function fExecDpNat()
Local aArea := GetArea()
Local cQuery    := ""
 
Local aFiliais := {}

Local cCodAntigo := ""
Local cCodNovo   := ""
Local nCont      := 0
Local cCodFil    := ""
Local cChaveRegi := ""
Local cChaveArra := ""
Local nPosic     := 0
Local aDeparaFIW := {}
Local aDeparaFIV := {}

Aadd(aFiliais, "0103")
Aadd(aFiliais, "0106")
Aadd(aFiliais, "0107")
Aadd(aFiliais, "0108")
Aadd(aFiliais, "0110")
Aadd(aFiliais, "0111")
Aadd(aFiliais, "0112")
Aadd(aFiliais, "0200")
Aadd(aFiliais, "0205")
Aadd(aFiliais, "0206")
Aadd(aFiliais, "0300")
Aadd(aFiliais, "0301")
Aadd(aFiliais, "0303")
Aadd(aFiliais, "0304")
Aadd(aFiliais, "0601")
Aadd(aFiliais, "0602")
Aadd(aFiliais, "0801")
Aadd(aFiliais, "0803")


 
//=====================================================================
// [INICIO ] - Controle de Saldos Devolvidos pela nota fiscal de entrada
//=====================================================================
cQuery :=" SELECT ED_CODIGO, ED_DESCRIC, ED_XNEWNAT"+ CRLF
cQuery +="   FROM "+RetSqlName("SED")+" SED WITH(NOLOCK)"+ CRLF
cQuery +="  WHERE D_E_L_E_T_ = '' AND ED_CODIGO <> '' AND ED_XNEWNAT NOT IN( '' , 'NC')  AND ED_FILIAL = '"+xFilial("SED")+"' "+ CRLF //AND ED_CODIGO = 'COMISSOES'
cQuery +="  ORDER BY ED_CODIGO"+ CRLF

TCQuery cQuery New Alias "SEDX"
dbSelectArea("SEDX")
SEDX->(DbGoTop())

//----------------------------------------------
// Processa de/para na Tabela FIW
//----------------------------------------------
Begin Transaction
Do While !Eof()
    IF Empty(SEDX->ED_CODIGO) .or. Empty(SEDX->ED_XNEWNAT)
        dbSkip()
        loop
    Endif

    cCodAntigo := SEDX->ED_CODIGO
    cCodNovo   := SEDX->ED_XNEWNAT

    For nCont := 1 to Len(aFiliais)
        cCodFil := aFiliais[nCont]

        // Define as Chaves de Busca
        cChaveRegi := cCodFil + cCodAntigo + "01"

        dbSelectArea("FIW")
        DbSetOrder(1) //FIW_FILIAL, FIW_NATUR, FIW_MOEDA, FIW_TPSALD, FIW_CARTEI, FIW_DATA, R_E_C_N_O_, D_E_L_E_T_

        Do While dbSeek(cChaveRegi)
            //IF cCodFil == '0803' .AND. FIW_TPSALD = '2' .AND. FIW_CARTEI == 'P' .AND. DTOS(FIW_DATA) == '20180731'
            //    XPTO := 0
            //Endif

            IF Found() .And.  FIW_FILIAL + FIW_NATUR + FIW_MOEDA == cChaveRegi
                cChaveArra := cCodFil + cCodNovo + "01" + FIW_TPSALD + FIW_CARTEI + dtos(FIW_DATA)

                // Verifica se já houve de/para com o codigo atual
                nPosic := Ascan(aDeparaFIW, {|x| x[1] == cChaveArra})

                IF nPosic == 0
                    nRecno := Recno()
                    nValor := FIW_VALOR

                    // Verifica se já existe registro cadastrado com a chave unica.
                    dbSeek(cChaveArra)

                    IF !Found()
                        dbGoto(nRecno)

                        RecLock("FIW", .F.)
                        FIW_NATUR := cCodNovo
                        MsUnlock()
                    Else
                        RecLock("FIW", .F.)
                        FIW_VALOR += nValor //aDeparaFIW[nPosic][2]
                        MsUnlock()       
                    Endif

                    // Guarda a Chave que foi atualizada
                    Aadd(aDeparaFIW, {cChaveArra, FIW_VALOR, Recno()})
                Else
                    // Acumulo o Valor do Item
                    aDeparaFIW[nPosic][2] += FIW_VALOR

                    // Apago o Registro Atual
                    RecLock("FIW", .F.)
                    DBDelete() 
                    MsUnlock()

                    // Posiciona o Registro Mestre e altero o valor.
                    dbGoTo(aDeparaFIW[nPosic][3])
                    RecLock("FIW", .F.)
                    FIW_VALOR := aDeparaFIW[nPosic][2]
                    MsUnlock()
                Endif
            Endif 
        Enddo


        dbSelectArea("FIV")
        DbSetOrder(1) //FIV_FILIAL, FIV_NATUR, FIV_MOEDA, FIV_TPSALD, FIV_CARTEI, FIV_DATA, R_E_C_N_O_, D_E_L_E_T_

        // Define as Chaves de Busca
        cChaveRegi := cCodFil + cCodAntigo + "01"

        Do While dbSeek(cChaveRegi)

            IF Found() .And.  FIV_FILIAL + FIV_NATUR + FIV_MOEDA == cChaveRegi
                cChaveArra := cCodFil + cCodNovo + "01" + FIV_TPSALD + FIV_CARTEI + dtos(FIV_DATA)

                // Verifica se já houve de/para com o codigo atual
                nPosic := Ascan(aDeparaFIV, {|x| x[1] == cChaveArra})

                IF nPosic == 0
                    nRecno := Recno()
                    nValor := FIV_VALOR

                    // Verifica se já existe registro cadastrado com a chave unica.
                    dbSeek(cChaveArra)

                    IF !Found()
                        dbGoto(nRecno)

                        RecLock("FIV", .F.)
                        FIV_NATUR := cCodNovo
                        MsUnlock()
                    Else
                        RecLock("FIV", .F.)
                        FIV_VALOR += nValor //aDeparaFIW[nPosic][2]
                        MsUnlock()       
                    Endif

                    // Guarda a Chave que foi atualizada
                    Aadd(aDeparaFIV, {cChaveArra, FIV_VALOR, Recno()})
                Else
                    // Acumulo o Valor do Item
                    aDeparaFIV[nPosic][2] += FIV_VALOR

                    // Apago o Registro Atual
                    RecLock("FIV", .F.)
                    DBDelete() 
                    MsUnlock()

                    // Posiciona o Registro Mestre e altero o valor.
                    dbGoTo(aDeparaFIV[nPosic][3])
                    RecLock("FIV", .F.)
                    FIV_VALOR := aDeparaFIV[nPosic][2]
                    MsUnlock()
                Endif
            Endif 
        Enddo

        XPTO := 0
    NEXT nCont

    XPTO := 0
    XPTY := 0
    XPTW := 0

    dbSelectArea("SEDX")
    dbSkip()
Enddo 
End Transaction


SEDX->(DbCloseArea())

//RPCClearEnv()

// ENCERRAMENTO DE AMBIENTE EM CASO DE ESTADO DE JOB
If !IsBlind()
    RPCClearEnv()
Else
    MsgInfo("Termino de Processamento!","De/Para Naturezas")
EndIf

Restarea(aArea)
RETURN
