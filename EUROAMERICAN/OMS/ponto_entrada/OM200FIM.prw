#include "parmtype.ch"
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"
#include "Colors.ch"
#include "RwMake.ch"
#Include "Fwmvcdef.ch"

#define ENTER chr(13) + chr(10)
/*/{Protheus.doc} OM200FIM
Ponto de Entrada para gravar os volumes e especies para fecilitar a impressão no relatorio QEFAT005 
@type function Ponto de Entrada.
@version  1.00
@author Fabio Carneiro dos Santos  
@since 28/01/2022
@return Logical, permite ou nao a mudança de linha
/*/
User Function OM200FIM()

Local _aArea         := GetArea()
Local _aAreaDAK      := DAK->(GetArea())
Local _aAreaDAI      := DAI->(GetArea())
Local _cCarga        := DAK->DAK_COD
Local _cSeqCar       := DAK->DAK_SEQCAR
Local _lRet          := .T.
Local cQuery         := ""
Local cQueryA        := ""
Local cQueryB        := ""
Local cQueryC        := ""
Local cQueryP        := ""
Local _aVolumes      := {}
Local _nVol          := 0
Local _cUnQbVol      := ""
Local _nPesbru       := 0 // Peso de cada item da DAI
Local _nPesbruto     := 0 // Peso de cada item da DAK 
Local _cESPECIX      := ""
Local _nVOLUMEX      := 0
Local _cMsgVol       := ""
Local _nQtdVenda_    := 0
Local _nVal_         := 0
Local _nRetMod_      := 0
Local _nQtdVol_      := 0 
Local _nDifVol_      := 0
Local _cUnExpedicao_ := ""
Local _nQtdMinima_   := 0 
Local _nCalc1        := 0
Local _nCalc2        := 0 
Local _nCalc3 		 := 0
Local _nCalc4 		 := 0
Local _nCalc5 		 := 0
Local _nCalc6 		 := 0
Local _nCalc7 		 := 0
Local _nCalc8 		 := 0


If Select("TRBK") > 0
    TRBK->(DbCloseArea())
EndIf

cQuery := "SELECT DAI_PEDIDO, DAI_COD, DAI_SEQCAR, DAI_SEQUEN "+CRLF
cQuery += "FROM "+RetSqlName("DAI")+" AS DAI WITH (NOLOCK) "+CRLF
cQuery += "INNER JOIN "+RetSqlName("DAK")+" AS DAK  WITH (NOLOCK) ON DAK_FILIAL = DAI_FILIAL "+CRLF
cQuery += " AND DAK_COD = DAI_COD  "+CRLF
cQuery += " AND DAK.D_E_L_E_T_ = ' '  "+CRLF
cQuery += "WHERE DAI_FILIAL = '"+xFilial("DAI")+"' "+CRLF
cQuery += " AND DAI_COD = '"+_cCarga+"'     "+CRLF
cQuery += " AND DAI.D_E_L_E_T_ = ' '  "+CRLF
cQuery += "ORDER BY DAI_PEDIDO  "+CRLF

TcQuery cQuery ALIAS "TRBK" NEW

TRBK->(DbGoTop())

While TRBK->(!Eof())

    _aVolumes := {}
    
    DAI->(DbSetOrder(1))
    If DAI->(DbSeek(xFilial("DAI")+TRBK->DAI_COD+TRBK->DAI_SEQCAR+TRBK->DAI_SEQUEN+TRBK->DAI_PEDIDO))

        If Select("TRB1") > 0
            TRB1->(DbCloseArea())
        EndIf
        
        cQueryA := "SELECT CB8_XUNEXP AS UNEXP, SUM(CB8_XCLEXP) AS CLEXP, SUM(CB8_XDFVOL) AS DIFVOL, "+CRLF
        cQueryA += " MAX(CB8_XMNEMB) AS EMBMAX, MIN(CB8_XMNEMB) AS EMBMIN , SUM(CB8_QTDORI) AS VENDA   "+CRLF 		
        cQueryA += "FROM "+RetSqlName("CB8")+" AS CB8 WITH (NOLOCK) "+CRLF
        cQueryA += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) ON B1_COD = CB8_PROD "+CRLF
        cQueryA += " AND SB1.D_E_L_E_T_ = ' '  "+CRLF
        cQueryA += "WHERE CB8_FILIAL = '"+xFilial("CB8")+"' "+CRLF
        cQueryA += " AND CB8_PEDIDO = '"+TRBK->DAI_PEDIDO+"'     "+CRLF
        cQueryA += " AND CB8.D_E_L_E_T_ = ' '  "+CRLF
        cQueryA += " GROUP BY CB8_XUNEXP " +CRLF
        cQueryA += "ORDER BY CB8_XUNEXP  "+CRLF

        TcQuery cQueryA ALIAS "TRB1" NEW

        TRB1->(DbGoTop())

        While TRB1->(!Eof())

		    _nCalc1 := (TRB1->CLEXP * TRB1->EMBMAX)
			_nCalc2 := (_nCalc1 - TRB1->VENDA )
			_nCalc3 := (_nCalc2 * 2)
			_nCalc4 := (TRB1->VENDA - _nCalc3) 
			_nCalc5 := (_nCalc4/TRB1->EMBMAX)
			_nCalc6 := (_nCalc3/TRB1->EMBMIN) 
			_nCalc7 := (_nCalc5 + _nCalc6)
			_nCalc8 := (_nCalc3 + _nCalc4)
			
			aAdd(_aVolumes,{TRB1->UNEXP,;
							TRB1->CLEXP,;
							TRB1->DIFVOL,;
							TRB1->EMBMIN,;
							TRB1->CLEXP+(TRB1->DIFVOL/TRB1->EMBMIN),;
							TRB1->VENDA,;
							TRB1->CLEXP+(TRB1->DIFVOL/TRB1->EMBMAX),;
							TRB1->EMBMAX,;
							_nCalc1,;
							_nCalc2,;
							_nCalc3,;
							_nCalc4,;
							_nCalc5,;
							_nCalc6,;
							_nCalc7,;
							_nCalc8})      

			_nCalc1 := 0
			_nCalc2 := 0
			_nCalc3 := 0
			_nCalc4 := 0
			_nCalc5 := 0
			_nCalc6 := 0
			_nCalc7 := 0
			_nCalc8 := 0

            TRB1->(DbSkip())
            
        EndDo

        For _nVol:=1 To Len(_aVolumes)
        
            If _aVolumes[_nVol][2] == _aVolumes[_nVol][5]
           
               If _nVol == 1 
   
                   RecLock("DAI",.F.)
                   DAI->DAI_XESP1  := _aVolumes[_nVol][1]
                   DAI->DAI_XVOL1  := _aVolumes[_nVol][2]
                   DAI->(MsUnlock())
               
               ElseIf _nVol == 2
   
                   RecLock("DAI",.F.)
                   DAI->DAI_XESP2  := _aVolumes[_nVol][1]
                   DAI->DAI_XVOL2  := _aVolumes[_nVol][2]
                   DAI->(MsUnlock())
   
               ElseIf _nVol == 3
   
                   RecLock("DAI",.F.)
                   DAI->DAI_XESP3  := _aVolumes[_nVol][1]
                   DAI->DAI_XVOL3  := _aVolumes[_nVol][2]
                   DAI->(MsUnlock())
   
               ElseIf _nVol == 4
   
                   RecLock("DAI",.F.)
                   DAI->DAI_XESP4  := _aVolumes[_nVol][1]
                   DAI->DAI_XVOL4  := _aVolumes[_nVol][2]
                   DAI->(MsUnlock())
   
               ElseIf _nVol == 5
   
                   RecLock("DAI",.F.)
                   DAI->DAI_XESP5  := _aVolumes[_nVol][1]
                   DAI->DAI_XVOL5  := _aVolumes[_nVol][2]
                   DAI->(MsUnlock())
   
               ElseIf _nVol == 6
   
                   RecLock("DAI",.F.)
                   DAI->DAI_XESP6  := _aVolumes[_nVol][1]
                   DAI->DAI_XVOL6  := _aVolumes[_nVol][2]
                   DAI->(MsUnlock())
   
               ElseIf _nVol == 7
   
                   RecLock("DAI",.F.)
                   DAI->DAI_XESP7  := _aVolumes[_nVol][1]
                   DAI->DAI_XVOL7  := _aVolumes[_nVol][2]
                   DAI->(MsUnlock())
   
               ElseIf _nVol == 8
   
                   RecLock("DAI",.F.)
                   DAI->DAI_XESP8  := _aVolumes[_nVol][1]
                   DAI->DAI_XVOL8  := _aVolumes[_nVol][2]
                   DAI->(MsUnlock())
   
               ElseIf _nVol == 9
   
                   RecLock("DAI",.F.)
                   DAI->DAI_XESP9  := _aVolumes[_nVol][1]
                   DAI->DAI_XVOL9  := _aVolumes[_nVol][2]
                   DAI->(MsUnlock())
   
               ElseIf _nVol == 10
   
                   RecLock("DAI",.F.)
                   DAI->DAI_XESP10  := _aVolumes[_nVol][1]
                   DAI->DAI_XVOL10  := _aVolumes[_nVol][2]
                   DAI->(MsUnlock())
   
               ElseIf _nVol == 11
   
                   RecLock("DAI",.F.)
                   DAI->DAI_XESP11  := _aVolumes[_nVol][1]
                   DAI->DAI_XVOL11  := _aVolumes[_nVol][2]
                   DAI->(MsUnlock())
   
               ElseIf _nVol == 12
   
                   RecLock("DAI",.F.)
                   DAI->DAI_XESP12  := _aVolumes[_nVol][1]
                   DAI->DAI_XVOL12  := _aVolumes[_nVol][2]
                   DAI->(MsUnlock())
   
               ElseIf _nVol == 13
   
                   RecLock("DAI",.F.)
                   DAI->DAI_XESP13  := _aVolumes[_nVol][1]
                   DAI->DAI_XVOL13  := _aVolumes[_nVol][2]
                   DAI->(MsUnlock())
               
               ElseIf _nVol == 14
   
                   RecLock("DAI",.F.)
                   DAI->DAI_XESP14  := _aVolumes[_nVol][1]
                   DAI->DAI_XVOL14  := _aVolumes[_nVol][2]
                   DAI->(MsUnlock())
   
               ElseIf _nVol == 15
   
                   RecLock("DAI",.F.)
                   DAI->DAI_XESP15  := _aVolumes[_nVol][1]
                   DAI->DAI_XVOL15  := _aVolumes[_nVol][2]
                   DAI->(MsUnlock())
   
               ElseIf _nVol >= 16
               
                   _cESPECIX += _aVolumes[_nVol][1]
                   _nVOLUMEX += _aVolumes[_nVol][2]
                   _cMsgVol := "Esta carga ultrapassou 15 volumes, Será necessario verificar"
   
               EndIf
   
            Else 
   
               If Select("TRB2") > 0
                   TRB2->(DbCloseArea())
               EndIf
   
               cQueryB := "SELECT CB8_XUN, CB8_XUNEXP, CB8_XMNEMB, CB8_QTDORI "+CRLF
               cQueryB += "FROM "+RetSqlName("CB8")+" AS CB8 WITH (NOLOCK) "+CRLF
               cQueryB += "WHERE CB8_FILIAL = '"+xFilial("CB8")+"' "+CRLF
               cQueryB += " AND CB8_XUNEXP = '"+_aVolumes[_nVol][1]+"'  "+CRLF
               cQueryB += " AND CB8_PEDIDO = '"+TRBK->DAI_PEDIDO+"'  "+CRLF
               cQueryB += " AND CB8.D_E_L_E_T_ = ' '  "+CRLF
               cQueryB += " GROUP BY CB8_XUN, CB8_XUNEXP, CB8_XMNEMB, CB8_QTDORI "+CRLF
   
               TcQuery cQueryB ALIAS "TRB2" NEW
   
               TRB2->(DbGoTop())
   
               While TRB2->(!Eof())
   
                    If TRB2->CB8_XUNEXP == _aVolumes[_nVol][1]

                        If _aVolumes[_nVol][4] == TRB2->CB8_XMNEMB
                            _cUnQbVol    := TRB2->CB8_XUN
                            _nQtdMinima_ := TRB2->CB8_XMNEMB
                        Elseif _aVolumes[_nVol][8] == TRB2->CB8_XMNEMB
                            _nQtdMinima_ := TRB2->CB8_XMNEMB
                        Else 
                            _nQtdMinima_ := TRB2->CB8_XMNEMB
                        EndIf 	
                    
                    Endif 

                   TRB2->(DbSkip())
       
               EndDo
                   
               If (_aVolumes[_nVol][3] - _aVolumes[_nVol][4]) == 0 							
                   
                   If _nVol == 1 
   
                       RecLock("DAI",.F.)
                       DAI->DAI_XESP1  := _aVolumes[_nVol][1]
                       DAI->DAI_XVOL1  := _aVolumes[_nVol][5]
                       DAI->(MsUnlock())
                   
                   ElseIf _nVol == 2
   
                       RecLock("DAI",.F.)
                       DAI->DAI_XESP2  := _aVolumes[_nVol][1]
                       DAI->DAI_XVOL2  := _aVolumes[_nVol][5]
   
                       DAI->(MsUnlock())
                   ElseIf _nVol == 3
   
                       RecLock("DAI",.F.)
                       DAI->DAI_XESP3  := _aVolumes[_nVol][1]
                       DAI->DAI_XVOL3  := _aVolumes[_nVol][5]
                       DAI->(MsUnlock())
   
                   ElseIf _nVol == 4
   
                       RecLock("DAI",.F.)
                       DAI->DAI_XESP4  := _aVolumes[_nVol][1]
                       DAI->DAI_XVOL4  := _aVolumes[_nVol][5]
                       DAI->(MsUnlock())
   
                   ElseIf _nVol == 5
   
                       RecLock("DAI",.F.)
                       DAI->DAI_XESP5  := _aVolumes[_nVol][1]
                       DAI->DAI_XVOL5  := _aVolumes[_nVol][5]
                       DAI->(MsUnlock())
   
                   ElseIf _nVol == 6
   
                       RecLock("DAI",.F.)
                       DAI->DAI_XESP6  := _aVolumes[_nVol][1]
                       DAI->DAI_XVOL6  := _aVolumes[_nVol][5]
                       DAI->(MsUnlock())
   
                   ElseIf _nVol == 7
   
                       RecLock("DAI",.F.)
                       DAI->DAI_XESP7  := _aVolumes[_nVol][1]
                       DAI->DAI_XVOL7  := _aVolumes[_nVol][5]
                       DAI->(MsUnlock())
   
                   ElseIf _nVol == 8
   
                       RecLock("DAI",.F.)
                       DAI->DAI_XESP8  := _aVolumes[_nVol][1]
                       DAI->DAI_XVOL8  := _aVolumes[_nVol][5]
                       DAI->(MsUnlock())
   
                   ElseIf _nVol == 9
   
                       RecLock("DAI",.F.)
                       DAI->DAI_XESP9  := _aVolumes[_nVol][1]
                       DAI->DAI_XVOL9  := _aVolumes[_nVol][5]
                       DAI->(MsUnlock())
   
                   ElseIf _nVol == 10
   
                       RecLock("DAI",.F.)
                       DAI->DAI_XESP10  := _aVolumes[_nVol][1]
                       DAI->DAI_XVOL10  := _aVolumes[_nVol][5]
                       DAI->(MsUnlock())
   
                   ElseIf _nVol == 11
   
                       RecLock("DAI",.F.)
                       DAI->DAI_XESP11  := _aVolumes[_nVol][1]
                       DAI->DAI_XVOL11  := _aVolumes[_nVol][5]
                       DAI->(MsUnlock())
                  
                   ElseIf _nVol == 12
                  
                       RecLock("DAI",.F.)
                       DAI->DAI_XESP12  := _aVolumes[_nVol][1]
                       DAI->DAI_XVOL12  := _aVolumes[_nVol][5]
                       DAI->(MsUnlock())
                  
                   ElseIf _nVol == 13
                  
                       RecLock("DAI",.F.)
                       DAI->DAI_XESP13  := _aVolumes[_nVol][1]
                       DAI->DAI_XVOL13  := _aVolumes[_nVol][5]
                       DAI->(MsUnlock())
                   
                   ElseIf _nVol == 14
                  
                       RecLock("DAI",.F.)
                       DAI->DAI_XESP14  := _aVolumes[_nVol][1]
                       DAI->DAI_XVOL14  := _aVolumes[_nVol][5]
                       DAI->(MsUnlock())
                  
                   ElseIf _nVol == 15
                  
                       RecLock("DAI",.F.)
                       DAI->DAI_XESP15  := _aVolumes[_nVol][1]
                       DAI->DAI_XVOL15  := _aVolumes[_nVol][5]
                       DAI->(MsUnlock())
                
                   EndIf
                
                Else 

                   If _aVolumes[_nVol][4] - _aVolumes[_nVol][3] > 0
                       
                       If _nVol == 1 
                    
                           RecLock("DAI",.F.)
                           DAI->DAI_XDIF1  := _cUnQbVol
                           DAI->DAI_XVDF1  := _aVolumes[_nVol][3]
                           DAI->(MsUnlock())
                       
                       ElseIf _nVol == 2
                    
                           RecLock("DAI",.F.)
                           DAI->DAI_XDIF2  := _cUnQbVol
                           DAI->DAI_XVDF2  := _aVolumes[_nVol][3]
                           DAI->(MsUnlock())
                    
                       ElseIf _nVol == 3
                    
                           RecLock("DAI",.F.)
                           DAI->DAI_XDIF3  := _cUnQbVol
                           DAI->DAI_XVDF3  := _aVolumes[_nVol][3]
                           DAI->(MsUnlock())
                    
                       ElseIf _nVol == 4
                    
                           RecLock("DAI",.F.)
                           DAI->DAI_XDIF4  := _cUnQbVol
                           DAI->DAI_XVDF4  := _aVolumes[_nVol][3]
                           DAI->(MsUnlock())
                    
                       ElseIf _nVol == 5
                    
                           RecLock("DAI",.F.)
                           DAI->DAI_XDIF5  := _cUnQbVol
                           DAI->DAI_XVDF5  := _aVolumes[_nVol][3]
                           DAI->(MsUnlock())
                    
                       ElseIf _nVol == 6
                    
                           RecLock("DAI",.F.)
                           DAI->DAI_XDIF6  := _cUnQbVol
                           DAI->DAI_XVDF6  := _aVolumes[_nVol][3]
                           DAI->(MsUnlock())
                    
                       ElseIf _nVol == 7
                    
                           RecLock("DAI",.F.)
                           DAI->DAI_XDIF7  := _cUnQbVol
                           DAI->DAI_XVDF7  := _aVolumes[_nVol][3]
                           DAI->(MsUnlock())
                    
                       ElseIf _nVol == 8
                    
                           RecLock("DAI",.F.)
                           DAI->DAI_XDIF8  := _cUnQbVol
                           DAI->DAI_XVDF8  := _aVolumes[_nVol][3]
                           DAI->(MsUnlock())
                    
                       ElseIf _nVol == 9
                    
                           RecLock("DAI",.F.)
                           DAI->DAI_XDIF9  := _cUnQbVol
                           DAI->DAI_XVDF9  := _aVolumes[_nVol][3]
                           DAI->(MsUnlock())
                    
                       ElseIf _nVol == 10
                    
                           RecLock("DAI",.F.)
                           DAI->DAI_XDIF10  := _cUnQbVol
                           DAI->DAI_XVDF10  := _aVolumes[_nVol][3]
                           DAI->(MsUnlock())
                    
                       ElseIf _nVol >= 11
               
                           _cESPECIX += _cUnQbVol
                           _nVOLUMEX += _aVolumes[_nVol][3]
                           _cMsgVol := "Esta carga ultrapassou 10 volumes, Será necessario verificar"
                    
                       EndIf
                                           
                    ElseIf _aVolumes[_nVol][4] - _aVolumes[_nVol][3] < 0 	
                           
                           If _nVol == 1 
                           
                               _nQtdMinima_      := _aVolumes[_nVol][4]
                               _cUnExpedicao_    := _aVolumes[_nVol][1]
                               _nQtdVenda_       := _aVolumes[_nVol][6]
                               _nRetMod_         := MOD(_aVolumes[_nVol][6],_nQtdMinima_)
                               _nQtdVenda_       := (_aVolumes[_nVol][6] - _nRetMod_)
                               _nVal_            := (_nQtdVenda_ / _nQtdMinima_)
                               _nQtdVol_         := _nVal_ * _nQtdMinima_ 
                               _nDifVol_         := _aVolumes[_nVol][6]-_nQtdVol_
                           
                               RecLock("DAI",.F.)
                               DAI->DAI_XESP1  := _cUnExpedicao_
                               DAI->DAI_XVOL1  := _nVal_
                               DAI->DAI_XDIF1  := _cUnQbVol
                               DAI->DAI_XVDF1  := _nDifVol_
                               DAI->(MsUnlock())

                           ElseIf _nVol == 2
                                                   
                               _nQtdMinima_      := _aVolumes[_nVol][4]
                               _cUnExpedicao_    := _aVolumes[_nVol][1]
                               _nQtdVenda_       := _aVolumes[_nVol][6]
                               _nRetMod_         := MOD(_aVolumes[_nVol][6],_nQtdMinima_)
                               _nQtdVenda_       := (_aVolumes[_nVol][6] - _nRetMod_)
                               _nVal_            := (_nQtdVenda_ / _nQtdMinima_)
                               _nQtdVol_         := _nVal_ * _nQtdMinima_ 
                               _nDifVol_         := _aVolumes[_nVol][6]-_nQtdVol_
                               
                                RecLock("DAI",.F.)
                                DAI->DAI_XESP2  := _cUnExpedicao_
                                DAI->DAI_XVOL2  := _nVal_
                                DAI->DAI_XDIF2  := _cUnQbVol
                                DAI->DAI_XVDF2  := _nDifVol_
                                DAI->(MsUnlock())
                           
                           ElseIf _nVol == 3
                           
                               _nQtdMinima_      := _aVolumes[_nVol][4]
                               _cUnExpedicao_    := _aVolumes[_nVol][1]
                               _nQtdVenda_       := _aVolumes[_nVol][6]
                               _nRetMod_         := MOD(_aVolumes[_nVol][6],_nQtdMinima_)
                               _nQtdVenda_       := (_aVolumes[_nVol][6] - _nRetMod_)
                               _nVal_            := (_nQtdVenda_ / _nQtdMinima_)
                               _nQtdVol_         := _nVal_ * _nQtdMinima_ 
                               _nDifVol_         := _aVolumes[_nVol][6]-_nQtdVol_
                           
                                RecLock("DAI",.F.)
                                DAI->DAI_XESP3  := _cUnExpedicao_
                                DAI->DAI_XVOL3  := _nVal_
                                DAI->DAI_XDIF3  := _cUnQbVol
                                DAI->DAI_XVDF3  := _nDifVol_
                                DAI->(MsUnlock())
                           
                           ElseIf _nVol == 4
                           
                               _nQtdMinima_      := _aVolumes[_nVol][4]
                               _cUnExpedicao_    := _aVolumes[_nVol][1]
                               _nQtdVenda_       := _aVolumes[_nVol][6]
                               _nRetMod_         := MOD(_aVolumes[_nVol][6],_nQtdMinima_)
                               _nQtdVenda_       := (_aVolumes[_nVol][6] - _nRetMod_)
                               _nVal_            := (_nQtdVenda_ / _nQtdMinima_)
                               _nQtdVol_         := _nVal_ * _nQtdMinima_ 
                               _nDifVol_         := _aVolumes[_nVol][6]-_nQtdVol_
                           
                                RecLock("DAI",.F.)
                                DAI->DAI_XESP4  := _cUnExpedicao_
                                DAI->DAI_XVOL4  := _nVal_
                                DAI->DAI_XDIF4  := _cUnQbVol
                                DAI->DAI_XVDF4  := _nDifVol_
                                DAI->(MsUnlock())
                           
                           ElseIf _nVol == 5
                           
                               _nQtdMinima_      := _aVolumes[_nVol][4]
                               _cUnExpedicao_    := _aVolumes[_nVol][1]
                               _nQtdVenda_       := _aVolumes[_nVol][6]
                               _nRetMod_         := MOD(_aVolumes[_nVol][6],_nQtdMinima_)
                               _nQtdVenda_       := (_aVolumes[_nVol][6] - _nRetMod_)
                               _nVal_            := (_nQtdVenda_ / _nQtdMinima_)
                               _nQtdVol_         := _nVal_ * _nQtdMinima_ 
                               _nDifVol_         := _aVolumes[_nVol][6]-_nQtdVol_
                           
                                RecLock("DAI",.F.)
                                DAI->DAI_XESP5  := _cUnExpedicao_
                                DAI->DAI_XVOL5  := _nVal_
                                DAI->DAI_XDIF5  := _cUnQbVol
                                DAI->DAI_XVDF5  := _nDifVol_
                                DAI->(MsUnlock())
                           
                           ElseIf _nVol == 6
                               
                               _nQtdMinima_      := _aVolumes[_nVol][4]
                               _cUnExpedicao_    := _aVolumes[_nVol][1]
                               _nQtdVenda_       := _aVolumes[_nVol][6]
                               _nRetMod_         := MOD(_aVolumes[_nVol][6],_nQtdMinima_)
                               _nQtdVenda_       := (_aVolumes[_nVol][6] - _nRetMod_)
                               _nVal_            := (_nQtdVenda_ / _nQtdMinima_)
                               _nQtdVol_         := _nVal_ * _nQtdMinima_ 
                               _nDifVol_         := _aVolumes[_nVol][6]-_nQtdVol_
                               
                                RecLock("DAI",.F.)
                                DAI->DAI_XESP6  := _cUnExpedicao_
                                DAI->DAI_XVOL6  := _nVal_
                                DAI->DAI_XDIF6  := _cUnQbVol
                                DAI->DAI_XVDF6  := _nDifVol_
                                DAI->(MsUnlock())

                           ElseIf _nVol == 7
                               
                               _nQtdMinima_      := _aVolumes[_nVol][4]
                               _cUnExpedicao_    := _aVolumes[_nVol][1]
                               _nQtdVenda_       := _aVolumes[_nVol][6]
                               _nRetMod_         := MOD(_aVolumes[_nVol][6],_nQtdMinima_)
                               _nQtdVenda_       := (_aVolumes[_nVol][6] - _nRetMod_)
                               _nVal_            := (_nQtdVenda_ / _nQtdMinima_)
                               _nQtdVol_         := _nVal_ * _nQtdMinima_ 
                               _nDifVol_         := _aVolumes[_nVol][6]-_nQtdVol_
                               
                                RecLock("DAI",.F.)
                                DAI->DAI_XESP7  := _cUnExpedicao_
                                DAI->DAI_XVOL7  := _nVal_
                                DAI->DAI_XDIF7  := _cUnQbVol
                                DAI->DAI_XVDF7  := _nDifVol_
                                DAI->(MsUnlock())

                           ElseIf _nVol == 8
                               
                               _nQtdMinima_      := _aVolumes[_nVol][4]
                               _cUnExpedicao_    := _aVolumes[_nVol][1]
                               _nQtdVenda_       := _aVolumes[_nVol][6]
                               _nRetMod_         := MOD(_aVolumes[_nVol][6],_nQtdMinima_)
                               _nQtdVenda_       := (_aVolumes[_nVol][6] - _nRetMod_)
                               _nVal_            := (_nQtdVenda_ / _nQtdMinima_)
                               _nQtdVol_         := _nVal_ * _nQtdMinima_ 
                               _nDifVol_         := _aVolumes[_nVol][6]-_nQtdVol_
                               
                                RecLock("DAI",.F.)
                                DAI->DAI_XESP8  := _cUnExpedicao_
                                DAI->DAI_XVOL8  := _nVal_
                                DAI->DAI_XDIF8  := _cUnQbVol
                                DAI->DAI_XVDF8  := _nDifVol_
                                DAI->(MsUnlock())

                           ElseIf _nVol == 8
                               
                               _nQtdMinima_      := _aVolumes[_nVol][4]
                               _cUnExpedicao_    := _aVolumes[_nVol][1]
                               _nQtdVenda_       := _aVolumes[_nVol][6]
                               _nRetMod_         := MOD(_aVolumes[_nVol][6],_nQtdMinima_)
                               _nQtdVenda_       := (_aVolumes[_nVol][6] - _nRetMod_)
                               _nVal_            := (_nQtdVenda_ / _nQtdMinima_)
                               _nQtdVol_         := _nVal_ * _nQtdMinima_ 
                               _nDifVol_         := _aVolumes[_nVol][6]-_nQtdVol_
                               
                                RecLock("DAI",.F.)
                                DAI->DAI_XESP8  := _cUnExpedicao_
                                DAI->DAI_XVOL8  := _nVal_
                                DAI->DAI_XDIF8  := _cUnQbVol
                                DAI->DAI_XVDF8  := _nDifVol_
                                DAI->(MsUnlock())


                           ElseIf _nVol == 9
                               
                               _nQtdMinima_      := _aVolumes[_nVol][4]
                               _cUnExpedicao_    := _aVolumes[_nVol][1]
                               _nQtdVenda_       := _aVolumes[_nVol][6]
                               _nRetMod_         := MOD(_aVolumes[_nVol][6],_nQtdMinima_)
                               _nQtdVenda_       := (_aVolumes[_nVol][6] - _nRetMod_)
                               _nVal_            := (_nQtdVenda_ / _nQtdMinima_)
                               _nQtdVol_         := _nVal_ * _nQtdMinima_ 
                               _nDifVol_         := _aVolumes[_nVol][6]-_nQtdVol_
                               
                                RecLock("DAI",.F.)
                                DAI->DAI_XESP9  := _cUnExpedicao_
                                DAI->DAI_XVOL9  := _nVal_
                                DAI->DAI_XDIF9  := _cUnQbVol
                                DAI->DAI_XVDF9  := _nDifVol_
                                DAI->(MsUnlock())


                           ElseIf _nVol == 10
                               
                               _nQtdMinima_      := _aVolumes[_nVol][4]
                               _cUnExpedicao_    := _aVolumes[_nVol][1]
                               _nQtdVenda_       := _aVolumes[_nVol][6]
                               _nRetMod_         := MOD(_aVolumes[_nVol][6],_nQtdMinima_)
                               _nQtdVenda_       := (_aVolumes[_nVol][6] - _nRetMod_)
                               _nVal_            := (_nQtdVenda_ / _nQtdMinima_)
                               _nQtdVol_         := _nVal_ * _nQtdMinima_ 
                               _nDifVol_         := _aVolumes[_nVol][6]-_nQtdVol_
                               
                                RecLock("DAI",.F.)
                                DAI->DAI_XESP10  := _cUnExpedicao_
                                DAI->DAI_XVOL10  := _nVal_
                                DAI->DAI_XDIF10  := _cUnQbVol
                                DAI->DAI_XVDF10  := _nDifVol_
                                DAI->(MsUnlock())


                            EndIf 
                
                        EndIf
                       
                    EndIf 
                   
                EndIf 

        Next _nVol
    
        // GRAVA O PESO DE CADA PEDIDO NA CARGA TABELA DAI
    
        If Select("TRBP") > 0
            TRBP->(DbCloseArea())
        EndIf
    
        cQueryP := "SELECT SUM(CB8_QTDORI * B1_PESBRU) AS PESOBRU   " +CRLF
        cQueryP += " FROM "+RetSqlName("CB8")+" AS CB8 WITH (NOLOCK) " +CRLF
        cQueryp += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) ON CB8_PROD = B1_COD "+CRLF
        cQueryP += " AND SB1.D_E_L_E_T_ = ' ' "+CRLF		
        cQueryP += "WHERE CB8_FILIAL = '"+xFilial("CB8")+"' "+CRLF
        cQueryP += " AND CB8_PEDIDO  = '"+TRBK->DAI_PEDIDO+"' "+CRLF
        cQueryP += " AND CB8.D_E_L_E_T_ = ' '  "
    
        TcQuery cQueryP ALIAS "TRBP" NEW
    
        TRBP->(DbGoTop())
    
        While TRBP->(!Eof())
        
            _nPesbru   := TRBP->PESOBRU 
    
            TRBP->(DbSkip())
    
        EndDo
    
        // GRAVA O VALOR TOTAL DO PEDIDO NA CARGA TABELA DAI 
    
        If Select("TRBF") > 0
            TRBF->(DbCloseArea())
        EndIf
        cQueryB := "SELECT SUM(ROUND(C9_PRCVEN * CB8_QTDORI,2)) AS VLCARGA  " +CRLF
        cQueryB += " FROM  " + RetSqlName("SC9") + " AS SC9 WITH (NOLOCK) " + ENTER
        cQueryB += "INNER JOIN " + RetSqlName("CB8") + " AS CB8 WITH (NOLOCK) ON CB8_FILIAL = C9_FILIAL  " + ENTER
        cQueryB += " AND C9_PEDIDO  = CB8_PEDIDO  " + ENTER
        cQueryB += " AND C9_PRODUTO = CB8_PROD  " + ENTER
        cQueryB += " AND C9_LOCAL   = CB8_LOCAL  " + ENTER
        cQueryB += " AND C9_LOTECTL = CB8_LOTECT  " + ENTER
        cQueryB += " AND SC9.D_E_L_E_T_ = ' '  " + ENTER   
        cQueryB += "INNER JOIN " + RetSqlName("CB7") + " AS CB7 WITH (NOLOCK) ON CB8_FILIAL = CB7_FILIAL  " + ENTER
        cQueryB += " AND CB7_ORDSEP = CB8_ORDSEP " + ENTER 
        cQueryB += " AND CB7.D_E_L_E_T_ = ' '  " + ENTER
        cQueryB += "WHERE CB8_FILIAL = '"+xFilial("CB8")+"' " + ENTER
        cQueryB += " AND CB8_PEDIDO  = '"+TRBK->DAI_PEDIDO+"' "+CRLF
        cQueryB += " AND CB8.D_E_L_E_T_ = ' '  " + ENTER

        TcQuery cQueryB ALIAS "TRBF" NEW

        TRBF->(DbGoTop())
                    
        While TRBF->(!Eof())

            _nVlCarga    := TRBF->VLCARGA
                        
            TRBF->(DbSkip())
        EndDo

        RecLock("DAI",.F.)
        DAI->DAI_PESO   := _nPesbru
        DAI->DAI_XVALPD := _nVlCarga
        DAI->(MsUnlock())

    Endif

    TRBK->(DbSkip())
    
EndDo

// ***********************************************
// TRATAMENTO PARA GRAVAR DADOS NA TABELA DAK    *
// QUERY PARA CALCULAR O PESO TOTAL DA CARGA     *
//************************************************

If Select("TRB2") > 0
    TRB2->(DbCloseArea())
EndIf

cQueryC := "SELECT SUM(DAI_PESO) AS PESOBRUTO, SUM(DAI_XVALPD) AS VLTOTCARGA   " +CRLF
cQueryC += " FROM "+RetSqlName("DAI")+" AS DAI WITH (NOLOCK) " +CRLF
cQueryC += "WHERE DAI_FILIAL = '"+xFilial("DAI")+"' "+CRLF
cQueryC += " AND DAI_COD  = '"+_cCarga+"' "+CRLF
cQueryC += " AND DAI.D_E_L_E_T_ = ' '  "

TcQuery cQueryC ALIAS "TRB2" NEW

TRB2->(DbGoTop())

While TRB2->(!Eof())
        
    _nPesbruto   := TRB2->PESOBRUTO 
    _nVlTotCarga := TRB2->VLTOTCARGA 

    TRB2->(DbSkip())

EndDo

DAK->(DbSetOrder(1))
If DAK->(DbSeek(xFilial("DAK")+_cCarga+_cSeqCar))
    RecLock("DAK",.F.)
    DAK->DAK_PESO   := _nPesbruto
    DAK->DAK_VALOR  := _nVlTotCarga
    DAK->(MsUnlock())
EndIf

If Select("TRB1") > 0
    TRB1->(DbCloseArea())
EndIf
If Select("TRB2") > 0
	TRB2->(DbCloseArea())
EndIf
If Select("TRBK") > 0
    TRBK->(DbCloseArea())
EndIf
If Select("TRBP") > 0
	TRBP->(DbCloseArea())
EndIf

RestArea(_aArea)
RestArea(_aAreaDAK)
RestArea(_aAreaDAI)

Return _lRet
