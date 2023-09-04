#Include "parmtype.ch"
#Include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"
#Include "Colors.ch"
#Include "RwMake.ch"
#include 'Ap5Mail.ch'

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

/*/{Protheus.doc} PE_FINA460A
/@type function Ponto de Entrada para Gravar o vendedor e base de comissão - MVC
@version 1.00
@author Fabio Carbeiro dos Santos  
@since 18/03/2022
@return Logical, True ou False 
@History Foi acrescentado o campo E1_EMISSAO para gravar a mesma data do titulo Origem no Destino  - 04/05/2022 Fabio Carneiro 
/*/

User Function FINA460A()

Local aAreaSE1   := SE1->(GetArea())
Local aAreaSE5   := SE5->(GetArea())
Local aParam     := PARAMIXB
Local xRet       := .T.
Local oObj       := ''
Local cIdPonto   := ''
Local cIdModel   := ''
Local _cQuery    := "" 
Local _cQueryA   := ""
Local _cQueryB   := "" 
Local _cVendedor := "" 
Local _cPedido   := ""  
Local _dEmissao  := ""
Local _cTpCom    := ""
Local _nBase     := 0
Local _nPercCom  := 0
Local _nPercTab  := 0
Local _nCount    := 0
Local _aComis    := {}
Local _nCom      := 0

If aParam <> NIL
    oObj := aParam[1]
    cIdPonto := aParam[2]
    cIdModel := aParam[3]

   If cIdPonto == 'MODELCOMMITNTTS' // Bloco substitui o ponto de entrada F460GRV.

		If Select("TRB3") > 0
			TRB3->(DbCloseArea())
		EndIf

		_cQueryA := "SELECT COUNT(E1_NUM) AS QUANT " + CRLF
		_cQueryA += "FROM "+RetSqlName("SE1")+" AS SE1 " + CRLF
		_cQueryA += " WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' " + CRLF
		_cQueryA += " AND SE1.E1_NUM     = '"+SE1->E1_NUM+"'  " + CRLF
		_cQueryA += " AND SE1.E1_PREFIXO = '"+SE1->E1_PREFIXO+"'  " + CRLF
		_cQueryA += " AND SE1.E1_CLIENTE = '"+SE1->E1_CLIENTE+"'  " + CRLF
		_cQueryA += " AND SE1.E1_LOJA    = '"+SE1->E1_LOJA+"'  " + CRLF
		_cQueryA += " AND SE1.E1_TIPO    = 'NF '   " + CRLF
		_cQueryA += " AND SE1.E1_BAIXA   = ' '   " + CRLF
		_cQueryA += " AND SE1.D_E_L_E_T_ = ' ' " + CRLF
						
		TCQUERY _cQueryA NEW ALIAS TRB3

		TRB3->(dbGoTop())

		While TRB3->(!Eof())
					
            _nCount := TRB3->QUANT

			TRB3->(dbSkip())

		Enddo

		If Select("TRB2") > 0
			TRB2->(DbCloseArea())
		EndIf

		_cQueryB := "SELECT TOP 1 E1_PEDIDO AS PEDIDO, E1_EMISSAO AS EMISSAO " + CRLF
		_cQueryB += "FROM "+RetSqlName("SE1")+" AS SE1 " + CRLF
		_cQueryB += " WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' " + CRLF
		_cQueryB += " AND SE1.E1_NUM     = '"+SE1->E1_NUM+"'  " + CRLF
		_cQueryB += " AND SE1.E1_PREFIXO = '"+SE1->E1_PREFIXO+"'  " + CRLF
		_cQueryB += " AND SE1.E1_CLIENTE = '"+SE1->E1_CLIENTE+"'  " + CRLF
		_cQueryB += " AND SE1.E1_LOJA    = '"+SE1->E1_LOJA+"'  " + CRLF
		_cQueryB += " AND SE1.E1_TIPO    = 'NF '   " + CRLF
		_cQueryB += " AND SE1.E1_PEDIDO  <> ' '   " + CRLF
		_cQueryB += " AND SE1.D_E_L_E_T_ = ' ' " + CRLF
						
		TCQUERY _cQueryB NEW ALIAS TRB2

		TRB2->(dbGoTop())

		While TRB2->(!Eof())
					
            _cPedido   := TRB2->PEDIDO
			_dEmissao  := TRB2->EMISSAO

			TRB2->(dbSkip())

		Enddo

	    If Select("TRB1") > 0
			TRB1->(DbCloseArea())
		EndIf

		_cQuery := "SELECT * " + CRLF
		_cQuery += "FROM "+RetSqlName("SE1")+" AS SE1 " + CRLF
		_cQuery += " WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' " + CRLF
		_cQuery += " AND SE1.E1_NUM     = '"+SE1->E1_NUM+"'  " + CRLF
		_cQuery += " AND SE1.E1_PREFIXO = '"+SE1->E1_PREFIXO+"'  " + CRLF
		_cQuery += " AND SE1.E1_CLIENTE = '"+SE1->E1_CLIENTE+"'  " + CRLF
		_cQuery += " AND SE1.E1_LOJA    = '"+SE1->E1_LOJA+"'  " + CRLF
		_cQuery += " AND SE1.E1_TIPO    = 'NF '   " + CRLF
		_cQuery += " AND SE1.D_E_L_E_T_ = ' ' " + CRLF
						
		TCQUERY _cQuery NEW ALIAS TRB1

		TRB1->(dbGoTop())

		While TRB1->(!Eof())

			If !Empty(TRB1->E1_BAIXA)
            
                _cVendedor := TRB1->E1_VEND1
                _nBase     := TRB1->E1_BASCOM1
			    _nPercCom  := TRB1->E1_COMIS1
			    _nPercTab  := TRB1->E1_XCOM1
			    _cTpCom    := TRB1->E1_XTPCOM

            EndIf

            If Empty(TRB1->E1_BAIXA)

                aAdd(_aComis,{TRB1->E1_NUM,;       //01
                              TRB1->E1_PARCELA,;   //02
                              TRB1->E1_PREFIXO,;   //03 
                              TRB1->E1_TIPO,;      //04 
                              _cVendedor,;         //05
                              TRB1->E1_CLIENTE,;   //06
                              TRB1->E1_LOJA,;      //07
                              TRB1->E1_VALOR,;     //08
                              Round((_nBase/_nCount),2),;//09 
                              _nPercCom,;    //10
                              _nPercTab,;    //11
							  _cPedido,;     //12
							  _dEmissao,;    //13
							  _cTpCom})      //14
            EndIf 
			
            TRB1->(dbSkip())

		Enddo
        
        For _nCom:= 1 to len(_aComis)

			DbSelectArea("SE1")
			DbSetOrder(1)  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
            If SE1->(dbSeek(xFilial("SE1")+_aComis[_nCom][03]+_aComis[_nCom][01]+_aComis[_nCom][02]+_aComis[_nCom][04])) 						
				
                Reclock("SE1",.F.)
					
				If Empty(SE1->E1_VEND1)
					SE1->E1_VEND1     := _aComis[_nCom][05]
				EndIf
				SE1->E1_BASCOM1    := _aComis[_nCom][09]
				SE1->E1_COMIS1     := _aComis[_nCom][10]  
				SE1->E1_XCOM1      := _aComis[_nCom][11] 
				SE1->E1_PEDIDO     := _aComis[_nCom][12] 
				SE1->E1_EMISSAO    := StoD(_aComis[_nCom][13]) 
				SE1->E1_XTPCOM     := _aComis[_nCom][14] 

        		SE1->( Msunlock() )
    
            EndIf
        
        Next _nCom

   EndIf

EndIf

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf
If Select("TRB2") > 0
	TRB2->(DbCloseArea())
EndIf
If Select("TRB3") > 0
	TRB3->(DbCloseArea())
EndIf

RestArea(aAreaSE1)
RestArea(aAreaSE5)

Return xRet
