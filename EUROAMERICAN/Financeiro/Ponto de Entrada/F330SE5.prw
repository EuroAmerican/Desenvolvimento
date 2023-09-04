#Include "rwmake.ch"
#Include "protheus.ch"
#Include "TopConn.Ch"
#Include "parmtype.ch"
#Include "Tbiconn.ch"
#Include "Colors.ch"
#Include "RwMake.ch"

/*/{Protheus.doc} F330SE5
Este ponto de entrada será chamado após a gravação do registros de movimentação bancaria(SE5 e FK's).
@type function Ponto de entrada
@author Fabio Carneiro dos Santos - Projeto DEVOLUÇÃO COMISSÃO   - 06/05/2022
@version  1.00
@return  sem retorno especifico
/*/

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

User Function F330SE5()

Local aAreaSE1  := SE1->(GetArea())
Local aAreaSE2  := SE2->(GetArea())
Local aAreaSE5  := SE5->(GetArea())
Local aAreaSE8  := SE8->(GetArea())
Local aAreaFK1  := FK1->(GetArea())
Local aAreaFK5  := FK5->(GetArea())
Local aAreas    := {aAreaSE1, aAreaSE2,aAreaSE5,aAreaSE8,aAreaFK1,aAreaFK5}
Local aRecno    := ParamIxb[1]
Local nCntFor   := 0
Local cQuery    := ""
Local cDevCom   := ""
Local cTipdev   := ""
Local cDscDev   := "" 
Local cRnc      := "" 
Local cTpcom    := ""
Local aGrava    := {}
Local nGrava    := 0
Local nPassa    := 0 
Local nCheca    := 0 
Local nBaseCom  := 0
Local nPercCom  := 0
Local cFilComis := GetMv("QE_FILCOM")
/*
+------------------------------------------------------------------+
| Projeto DEVOLUÇÃO COMISSÃO - 06/05/2022 - Fabio Carneiro         |
+------------------------------------------------------------------+
*/
If cfilAnt $ cFilComis

    If Len(aRecno) > 0

        For nCntFor := 1 to Len(aRecno)

            SE5->(dbGoto(aRecno[nCntFor]))

            If Select("TRB1") > 0
                TRB1->(DbCloseArea())
            EndIf

            cQuery := "SELECT E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_CLIFOR, E5_LOJA, E5_TIPO, E5_MOTBX, E5_TIPODOC,E5_SEQ " + CRLF
            cQuery += "FROM "+RetSqlName("SE5")+" AS SE5 WITH (NOLOCK) " + CRLF
            cQuery += " WHERE SE5.E5_FILIAL = '"+xFilial("SE5")+"' " + CRLF
            cQuery += " AND NOT E5_MOTBX IN ('LIQ','CAN') " + CRLF
            cQuery += " AND E5_TIPODOC IN ('VL','BA','CP','V2','DC','ES','E2') " + CRLF
            cQuery += " AND E5_VALOR > 0 "+ CRLF
            cQuery += " AND E5_SITUACA = ' ' " + CRLF
            cQuery += " AND SE5.R_E_C_N_O_ = '"+cValtoChar(aRecno[nCntFor])+"' " + CRLF
            cQuery += " AND SE5.D_E_L_E_T_ = ' ' " + CRLF
            
            TCQUERY cQuery NEW ALIAS TRB1

            TRB1->(dbGoTop())

            While TRB1->(!Eof())
                                
                If AllTrim(TRB1->E5_TIPO) == "NCC"
                    cDevCom  := AllTrim(Posicione("SE1",1,TRB1->E5_FILIAL+TRB1->E5_PREFIXO+TRB1->E5_NUMERO+TRB1->E5_PARCELA+TRB1->E5_TIPO,"E1_XDEVCOM"))
                    cTipdev  := AllTrim(Posicione("SE1",1,TRB1->E5_FILIAL+TRB1->E5_PREFIXO+TRB1->E5_NUMERO+TRB1->E5_PARCELA+TRB1->E5_TIPO,"E1_XTIPO"))
                    cDscDev  := AllTrim(Posicione("SE1",1,TRB1->E5_FILIAL+TRB1->E5_PREFIXO+TRB1->E5_NUMERO+TRB1->E5_PARCELA+TRB1->E5_TIPO,"E1_XDESC"))
                    cRnc     := AllTrim(Posicione("SE1",1,TRB1->E5_FILIAL+TRB1->E5_PREFIXO+TRB1->E5_NUMERO+TRB1->E5_PARCELA+TRB1->E5_TIPO,"E1_XCODRNC"))
                EndIf
                If AllTrim(TRB1->E5_TIPO) == "NF"
                    nBaseCom := Posicione("SE1",1,TRB1->E5_FILIAL+TRB1->E5_PREFIXO+TRB1->E5_NUMERO+TRB1->E5_PARCELA+TRB1->E5_TIPO,"E1_BASCOM1")
                    nPercCom := Posicione("SE1",1,TRB1->E5_FILIAL+TRB1->E5_PREFIXO+TRB1->E5_NUMERO+TRB1->E5_PARCELA+TRB1->E5_TIPO,"E1_COMIS1")
                    cTpcom   := AllTrim(Posicione("SE1",1,TRB1->E5_FILIAL+TRB1->E5_PREFIXO+TRB1->E5_NUMERO+TRB1->E5_PARCELA+TRB1->E5_TIPO,"E1_XTPCOM"))
                EndIf
           
                Aadd(aGrava,{TRB1->E5_FILIAL,; // 01
                            TRB1->E5_PREFIXO,; // 02
                            TRB1->E5_NUMERO,;  // 03
                            TRB1->E5_PARCELA,; // 04 
                            TRB1->E5_TIPO,;    // 05
                            TRB1->E5_CLIFOR,;  // 06
                            TRB1->E5_LOJA,;    // 07
                            TRB1->E5_SEQ,;     // 08
                            cDevCom,;          // 09 
                            cTipdev,;          // 10 
                            AllTrim(cDscDev),; // 11
                            nBaseCom,;         // 12
                            nPercCom,;         // 13 
                            cRnc,;             // 14
                            cTpcom})           // 15


                TRB1->(dbSkip())

            Enddo

        Next nCntFor

        If Len(aGrava) > 0
        
            For nGrava := 1 to Len(aGrava)

                For nPassa := 1 to Len(aGrava)
                    
                    If !Empty(aGrava[nGrava][09])     

                        DbSelectArea("SE5")
                        DbSetOrder(7)    // E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ 
                        If SE5->(dbSeek(aGrava[nPassa][01]+aGrava[nPassa][02]+aGrava[nPassa][03]+aGrava[nPassa][04]+aGrava[nPassa][05]+aGrava[nPassa][06]+aGrava[nPassa][07]+aGrava[nPassa][08])) 

                            RecLock("SE5",.F.)
                            SE5->E5_XDEVCOM := aGrava[nGrava][09] // Grava se é devido o desconto da Comissão 
                            SE5->E5_XCODRNC := aGrava[nGrava][14] // Grava O o codigo da RNC para pesquisa 
                            SE5->(MsUnlock())

                        EndIf

                    EndIf
                
                Next nPassa 

                For nCheca := 1 to Len(aGrava)

                    DbSelectArea("SE1")
                    DbSetOrder(1)    //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
                    If SE1->(dbSeek(aGrava[nCheca][01]+aGrava[nCheca][02]+aGrava[nCheca][03]+aGrava[nCheca][04]+aGrava[nCheca][05])) 

                        RecLock("SE1",.F.)
                                
                        If !Empty(aGrava[nGrava][09])
                            SE1->E1_XDEVCOM := aGrava[nGrava][09] // Grava se é devido o desconto da Comissão 
                            SE1->E1_XTIPO   := aGrava[nGrava][10] // Grava o tipo da RNC para conferencia quando houver a compensação 
                            SE1->E1_XDESC   := aGrava[nGrava][11] // Grava o descrição do tipo da RNC para conferencia quando houver a compensação  
                            SE1->E1_XCODRNC := aGrava[nGrava][14] // Grava o codigo da RNC  de devolução 
                            SE1->E1_XTPCOM  := aGrava[nGrava][15] // Tipo de comissão 
                        EndIf
                                    
                        SE1->(MsUnlock())

                    EndIf

                Next nCheca 

            Next nGrava
        
        EndIf

    EndIf

EndIf

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf

AEval(aAreas, {|aArea| RestArea(aArea)})

Return
