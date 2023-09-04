#Include "rwmake.ch"
#Include "protheus.ch"
#Include "TopConn.Ch"
#Include "parmtype.ch"
#Include "Tbiconn.ch"
#Include "Colors.ch"
#Include "RwMake.ch"

/*/{Protheus.doc} SF1100I
@type function Ponto de entrada
@version  1.00
@author Rodrigo Sousa
@since 11/09/2013
@since 01/02/2022
@History Fabio Carneiro dos Santos - Projeto Unidade de Expedição - 23/02/2022
@History Fabio Carneiro dos Santos - Projeto DEVOLUÇÃO COMISSÃO   - 06/05/2022
@History Fabio Carneiro dos Santos - Ajuste para Gravar Peso liquido e Bruto - 25/06/2022
@return  character, sem retorno especifico
/*/

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

User Function SF1100I()

Local aArea          := GetArea()
Local aAreaSB1       := SB1->(GetArea())
Local aAreaSA1       := SA1->(GetArea())
Local aAreaSA2       := SA2->(GetArea())
Local aAreaSF4       := SF4->(GetArea())
Local aAreaSYD       := SYD->(GetArea())
Local aAreaSY3       := SY3->(GetArea())
Local aAreaSD1       := SD1->(GetArea())
Local aAreaSD2       := SD2->(GetArea())
Local aAreaSF1       := SF1->(GetArea())
Local aAreaSF2       := SF2->(GetArea())
Local aAreaSD3       := SD3->(GetArea())
Local aAreaSC6       := SC6->(GetArea())
Local aAreaSC7       := SC7->(GetArea())
Local aAreaSC5       := SC5->(GetArea())
Local aAreaSC9       := SC9->(GetArea())
Local aAreaSE1       := SE1->(GetArea())
Local aAreaSE2       := SE2->(GetArea())
Local aAreaEE7       := EE7->(GetArea())
Local aAreaEE8       := EE8->(GetArea())
Local aAreaSB2       := SB2->(GetArea())
Local aAreaSB8       := SB8->(GetArea())
Local aAreaSBF       := SBF->(GetArea())
Local aAreaSD5       := SD5->(GetArea())
Local aAreaSDB       := SDB->(GetArea())
Local aAreaSFT       := SFT->(GetArea())
Local aAreaSF3       := SF3->(GetArea())
Local aAreaCD2       := CD2->(GetArea())
Local aAreaCD5       := CD5->(GetArea())
Local aAreas         := {aArea,aAreaSB1,aAreaSA1,aAreaSA2,aAreaSF4,aAreaSD2,aAreaSF2,aAreaSD1,aAreaSF1,aAreaSC6,aAreaSC7,aAreaSC5,aAreaSC9,aAreaSE1,aAreaSE2,;
						 aAreaEE7,aAreaEE8,aAreaSB2,aAreaSB8,aAreaSBF,aAreaSD5,aAreaSDB,aAreaSFT,aAreaSF3,aAreaCD2,aAreaSYD,aAreaSY3,aAreaSD3,aAreaCD5}
Local cQuery    := ""
Local cQueryA   := ""
Local cQueryF   := ""
Local cQuery4   := ""
Local _cFilial  := ""
Local _cPrefixo := ""
Local _cNum     := ""
Local _cParcela := ""
Local _cTipo    := ""
Local aGrava    := {}
Local nGrava    := 0
Local cFilComis := GetMv("QE_FILCOM")

// Unidade de Expedição Melhoria para Formulario proprio - 25/06/2022

Local cQueryI        := "" 
Local cQueryB        := ""
Local _nPesoB   	 := 0
Local _nPesoL   	 := 0
Local _nQtdVenda     := 0
Local _nVal          := 0
Local _nRetMod       := 0
Local _nQtdVol       := 0 
Local _nDifVol       := 0
Local _nPesoBruto    := 0
Local _nPesoLiquido  := 0
Local _nQtdMinima    := 0
Local _cUnExpedicao  := ""
Local _nVol          := 0
Local _nPasVol       := 1
Local _lAtVol        := .T.
Local _nValFd        := 0
Local _nPos0         := 0
Local _nCheck        := 0 
Local _aCheck        := {} 
Local _cUnExp        := "" 
Local _cFormul       := ""
Local _cPedido       := ""
Local _dNfEmis       := ""
Private _aVolumes    := Array(14, 2)

For _nVol := 1 to Len(_aVolumes)
	_aVolumes[_nVol, 1] := ""
	_aVolumes[_nVol, 2] := 0
Next _nVol

/*
+------------------------------------------------------------------+
| Projeto UNIDADE DE EXPEDIÇÃO - 21/04/2022 - Fabio Carneiro       |
+------------------------------------------------------------------+
*/
If SF1->F1_FORMUL = 'S' 

	If SF1->F1_TIPO $ "N/D/B"

		If Select("TRBF") > 0
			TRBF->(DbCloseArea())
		EndIf

		cQueryF := "SELECT D1_FILIAL, D1_COD, D1_QUANT, D1_DOC, D1_SERIE, D1_FORMUL, D1_TIPO, D1_FORNECE, D1_LOJA, "+CRLF
		cQueryF += "B1_XUNEXP, B1_XQTDEXP, D1_ITEM, D1_TIPO  "+CRLF  
		cQueryF += "FROM "+RetSqlName("SD1")+" AS SD1 WITH (NOLOCK) "+CRLF
		cQueryF += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) ON B1_COD = D1_COD "+CRLF
		cQueryF += " AND SB1.D_E_L_E_T_ = ' ' "+CRLF
		cQueryF += "WHERE D1_FILIAL = '"+xFilial("SD1")+"' "+CRLF
		cQueryF += " AND D1_DOC     = '"+SF1->F1_DOC+"' "+CRLF
		cQueryF += " AND D1_SERIE   = '"+SF1->F1_SERIE+"' "+CRLF
		cQueryF += " AND D1_FORNECE = '"+SF1->F1_FORNECE+"' "+CRLF
		cQueryF += " AND D1_LOJA    = '"+SF1->F1_LOJA+"' "+CRLF
		cQueryF += " AND SD1.D_E_L_E_T_ = ' ' "+CRLF 
		cQueryF += "GROUP BY D1_FILIAL, D1_COD, D1_QUANT, D1_DOC, D1_SERIE, D1_FORMUL, D1_TIPO, D1_FORNECE, D1_LOJA, "+CRLF
		cQueryF += "B1_XUNEXP, B1_XQTDEXP, D1_ITEM, D1_TIPO "+CRLF  
		cQueryF += "ORDER BY B1_XUNEXP,B1_XQTDEXP,D1_DOC, D1_COD  "+CRLF

		TcQuery cQueryF ALIAS "TRBF" NEW

		TRBF->(DbGoTop())

		While TRBF->(!Eof())

			If TRBF->D1_TIPO $ "N/D/B"

				_cUnExpedicao  := Posicione("SB1",1,xFilial("SB1")+TRBF->D1_COD,"B1_XUNEXP")
				_nQtdMinima    := Posicione("SB1",1,xFilial("SB1")+TRBF->D1_COD,"B1_XQTDEXP") 
				_nPesoBruto    := Posicione("SB1",1,xFilial("SB1")+TRBF->D1_COD,"B1_PESBRU") 
				_nPesoLiquido  := Posicione("SB1",1,xFilial("SB1")+TRBF->D1_COD,"B1_PESO") 
				_nRetMod       := MOD(TRBF->D1_QUANT,_nQtdMinima)
				_nQtdVenda     := (TRBF->D1_QUANT -_nRetMod)
				_nVal          := (_nQtdVenda / _nQtdMinima)
				_nQtdVol       := _nVal * _nQtdMinima 
				_nDifVol       := TRBF->D1_QUANT-_nQtdVol

				DbSelectArea("SD1")
				SD1->(DbSetOrder(1)) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM 
				If SD1->(dbSeek(xFilial("SD1") + TRBF->D1_DOC + TRBF->D1_SERIE + TRBF->D1_FORNECE + TRBF->D1_LOJA + TRBF->D1_COD + TRBF->D1_ITEM))

					RecLock("SD1",.F.)

					SD1->D1_XUNEXP  := _cUnExpedicao
					SD1->D1_XCLEXP  := _nVal
					SD1->D1_XMINEMB := _nQtdMinima
					SD1->D1_XQTDVOL := _nQtdVol
					SD1->D1_XDIFVOL := _nDifVol  
					SD1->D1_XPESBUT := (TRBF->D1_QUANT * _nPesoBruto)
					SD1->D1_XPESLIQ := (TRBF->D1_QUANT * _nPesoLiquido)
					SD1->D1_XPBRU   := _nPesoBruto
					SD1->D1_XPLIQ   := _nPesoLiquido
		
					SD1->(MsUnlock())

				EndIf

			EndIf

			TRBF->(dbSkip())

			_cUnExpedicao  := ""
			_nQtdMinima    := 0
			_nPesoBruto    := 0
			_nPesoLiquido  := 0
			_nRetMod       := 0
			_nQtdVenda     := 0
			_nVal          := 0
			_nQtdVol       := 0
			_nDifVol       := 0

		EndDo

		If Select("TRBI") > 0
			TRBI->(DbCloseArea())
		EndIf

		cQueryI := "SELECT D1_FILIAL, D1_COD, SUM(D1_QUANT) AS D1_QUANT,D1_DOC,D1_SERIE,D1_FORMUL,D1_TIPO,D1_FORNECE, D1_LOJA, "+CRLF
		cQueryI += "B1_XUNEXP, B1_XQTDEXP, B1_UM,B1_SEGUM, D1_PEDIDO, D1_DTDIGIT, B1_PESO, B1_PESBRU "+CRLF
		cQueryI += "FROM "+RetSqlName("SD1")+" AS SD1 WITH (NOLOCK) "+CRLF
		cQueryI += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) ON B1_COD = D1_COD "+CRLF
		cQueryI += " AND SB1.D_E_L_E_T_ = ' ' "+CRLF
		cQueryI += "WHERE D1_FILIAL = '"+xFilial("SD1")+"' "+CRLF
		cQueryI += " AND D1_DOC     = '"+SF1->F1_DOC+"' "+CRLF
		cQueryI += " AND D1_SERIE   = '"+SF1->F1_SERIE+"' "+CRLF
		cQueryI += " AND D1_FORNECE = '"+SF1->F1_FORNECE+"' "+CRLF
		cQueryI += " AND D1_LOJA    = '"+SF1->F1_LOJA+"' "+CRLF
		cQueryI += " AND SD1.D_E_L_E_T_ = ' ' "+CRLF 
		cQueryI += "GROUP BY D1_FILIAL, D1_COD,D1_DOC,D1_SERIE,D1_FORMUL,D1_TIPO,D1_FORNECE, D1_LOJA, "+CRLF
		cQueryI += "B1_XUNEXP, B1_XQTDEXP,B1_UM, B1_SEGUM, D1_PEDIDO, D1_DTDIGIT, B1_PESO, B1_PESBRU "+CRLF  
		cQueryI += "ORDER BY B1_XUNEXP,B1_XQTDEXP,D1_DOC, D1_COD  "+CRLF

		TcQuery cQueryI ALIAS "TRBI" NEW

		TRBI->(DbGoTop())

		_cUnExpedicao  := ""
		_nQtdMinima    := 0
		_nPesoBruto    := 0
		_nPesoLiquido  := 0
		_nRetMod       := 0
		_nQtdVenda     := 0
		_nVal          := 0
		_nQtdVol       := 0
		_nDifVol       := 0
		_nVol          := 0
		_nPasVol       := 1

		While TRBI->(!Eof())
		
			If TRBI->D1_TIPO $ "N/D/B"

				_aCheck   := {}
				_cCampo   := ""
				_cFilial  := TRBI->D1_FILIAL
				_cDoc     := TRBI->D1_DOC
				_cSerie   := TRBI->D1_SERIE
				_cFornece := TRBI->D1_FORNECE
				_cLoja    := TRBI->D1_LOJA
				_cFormul  := TRBI->D1_FORMUL
				_cTipo    := TRBI->D1_TIPO
				_cPedido  := TRBI->D1_PEDIDO
				_dNfEmis  := Substr(TRBI->D1_DTDIGIT,7,2)+"/"+Substr(TRBI->D1_DTDIGIT,5,2)+"/"+Substr(TRBI->D1_DTDIGIT,1,4)

				_cCampo := "TRBI->B1_UM"

				_nPos0  := Ascan(_aVolumes, {|x| &_cCampo $ x[1]})
				
				If TRBI->B1_XUNEXP == 'KG'
					_nVal := (TRBI->D1_QUANT * TRBI->B1_XQTDEXP)
				Else
					_nVal := TRBI->D1_QUANT
				EndIf
				
				If !Empty(TRBI->B1_XUNEXP) 

					_nPos1 := Ascan(_aVolumes, {|x| TRBI->B1_XUNEXP $ x[1]})
						
					If Select("TRB1") > 0
						TRB1->(DbCloseArea())
					EndIf

					cQueryB := "SELECT B1_XQTDEXP,B1_XUNEXP,B1_UM  "+CRLF
					cQueryB += "FROM "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) "+CRLF
					cQueryB += "WHERE SB1.B1_COD = '"+TRBI->D1_COD+"' "+CRLF 
					cQueryB += " AND SB1.D_E_L_E_T_ = ' '  "+CRLF
					cQueryB += "GROUP BY B1_XQTDEXP,B1_XUNEXP,B1_UM  "+CRLF
					cQueryB += "ORDER BY B1_XQTDEXP  "+CRLF

					TcQuery cQueryB ALIAS "TRB1" NEW

					TRB1->(DbGoTop())

					While TRB1->(!Eof())

						Aadd(_aCheck,{TRB1->B1_XQTDEXP,TRB1->B1_XUNEXP,TRB1->B1_UM})  
								
						TRB1->(dbSkip())

					EndDo

					For _nCheck := 1 to Len(_aCheck)
							
						If TRBI->B1_XQTDEXP == _aCheck[_nCheck][1]  .And. _aCheck[_nCheck][3] == TRBI->B1_UM
								
							_nValFd  := ((_nVal - (_nVal % _aCheck[_nCheck][1])))/_aCheck[_nCheck][1]
							_nVal    := _nVal % _aCheck[_nCheck][1]
							_cUnExp  := _aCheck[_nCheck][2]
								
						EndIf
							
					Next _nCheck

					If _nValFd > 0
						If _nPos1 == 0
							_aVolumes[_nPasVol, 1]     := _cUnExp
							_aVolumes[_nPasVol, 2]     := _nValFd
							_nPasVol++
						Else
							_aVolumes[_nPos1, 2] += _nValFd
						EndIf
						If _nVal > 0
							If _nPos0 == 0
								_aVolumes[_nPasVol, 1]     := &(_cCampo)
								_aVolumes[_nPasVol, 2]     := _nVal
								_nPasVol++
							Else
								_aVolumes[_nPos0, 2] += _nVal
							EndIf
						EndIf
					
					Else 

						If _nVal > 0
							If _nPos0 == 0
								_aVolumes[_nPasVol, 1] := &(_cCampo)
								_aVolumes[_nPasVol, 2] := _nVal
								_nPasVol++
							Else
								_aVolumes[_nPos0, 2] += _nVal
							EndIf
						EndIf

					EndIf

				EndIf

				_nPesoL+=TRBI->D1_QUANT * TRBI->B1_PESO
				_nPesoB+=TRBI->D1_QUANT * TRBI->B1_PESBRU
				
			EndIf

			TRBI->(dbSkip())

			If TRBI->(EOF()) .Or. TRBI->D1_DOC <> _cDoc 

				If _lAtVol

					SF1->(dbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
					If SF1->(dbSeek(xFilial("SF1") + _cDoc +  _cSerie + _cFornece + _cLoja + _cTipo))
					
						Reclock("SF1",.F.)
						SF1->F1_ESPECI1 := AllTrim(_aVolumes[1][1])
						SF1->F1_VOLUME1 := _aVolumes[1][2]
						SF1->F1_ESPECI2 := AllTrim(_aVolumes[2][1])
						SF1->F1_VOLUME2 := _aVolumes[2][2]
						SF1->F1_ESPECI3 := AllTrim(_aVolumes[3][1])
						SF1->F1_VOLUME3 := _aVolumes[3][2]
						SF1->F1_ESPECI4 := AllTrim(_aVolumes[4][1])
						SF1->F1_VOLUME4 := _aVolumes[4][2]
						SF1->F1_ESPECI5 := AllTrim(_aVolumes[5][1])
						SF1->F1_VOLUME5 := _aVolumes[5][2]
						SF1->F1_ESPECI6 := AllTrim(_aVolumes[6][1])
						SF1->F1_VOLUME6 := _aVolumes[6][2]
						SF1->F1_ESPECI7 := AllTrim(_aVolumes[7][1])
						SF1->F1_VOLUME7 := _aVolumes[7][2]
						SF1->F1_PBRUTO  := _nPesoB
						SF1->F1_PLIQUI  := _nPesoL

						SF1->( Msunlock() )

						_aCheck   := {}
						_nPasVol  := 1
						_nVol     := 0
						_nVal     := 0
						_nValFd   := 0
						_nPos0    := 0
						_nPos1    := 0
						_nPesoB   := 0
						_nPesoL   := 0 

						_cFilial  := ""
						_cDoc     := ""
						_cSerie   := ""
						_cFornece := ""
						_cLoja    := ""
						_cFormul  := ""
						_cTipo    := ""
						_cPedido  := ""
						_dNfEmis  := ""
						For _nVol := 1 to Len(_aVolumes)
							_aVolumes[_nVol, 1] := ""
							_aVolumes[_nVol, 2] := 0
						Next _nVol
					
					EndIf

				EndIf

			EndIf

		EndDo

	EndIf

EndIf 
/*
+---------------------------------------------------------------------------+
| Acerto referente a Hora na NFE de entrada - 25/06/2022 - Fabio Carneiro   |
+---------------------------------------------------------------------------+
*/
If SF1->F1_FORMUL = 'S' 

	SF1->(dbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	If SF1->(dbSeek(xFilial("SF1") +SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO))

		Reclock("SF1",.F.)
		SF1->F1_HORA    := time()
		SF1->F1_HORNFE  := time()
		SF1->( Msunlock() )

	EndIf

EndIf
/*
+------------------------------------------------------------------+
| Projeto DEVOLUÇÃO COMISSÃO - 31/05/2022 - Fabio Carneiro         |
+------------------------------------------------------------------+
*/
If cfilAnt $ cFilComis

	If SF1->F1_TIPO == "D" 

		If Select("TRBF") > 0
			TRBF->(DbCloseArea())
		EndIf

		cQueryF := "SELECT TOP 1 D1_DOC, D1_SERIE, D1_NFORI, D1_SERIORI, D1_FORNECE, D1_LOJA, D1_TES,F4_DUPLIC "+CRLF
		cQueryF += "FROM "+RetSqlName("SD1")+" AS SD1 WITH (NOLOCK) "+CRLF
		cQueryF += "INNER JOIN "+RetSqlName("SF4")+" AS SF4 WITH (NOLOCK) ON F4_FILIAL = SUBSTRING(D1_FILIAL,1,2) " + CRLF
		cQueryF += " AND D1_TES  =  F4_CODIGO "+CRLF
		cQueryF += " AND SF4.D_E_L_E_T_ = ' ' "+CRLF 
		cQueryF += "WHERE D1_FILIAL = '"+xFilial("SD1")+"' "+CRLF
		cQueryF += " AND D1_DOC     = '"+SF1->F1_DOC+"' "+CRLF
		cQueryF += " AND D1_SERIE   = '"+SF1->F1_SERIE+"' "+CRLF
		cQueryF += " AND D1_FORNECE = '"+SF1->F1_FORNECE+"' "+CRLF
		cQueryF += " AND D1_LOJA    = '"+SF1->F1_LOJA+"' "+CRLF
		cQueryF += " AND F4_DUPLIC = 'S' "+CRLF 
		cQueryF += " AND SD1.D_E_L_E_T_ = ' ' "+CRLF 

		TcQuery cQueryF ALIAS "TRBF" NEW

		TRBF->(DbGoTop())

		While TRBF->(!Eof())

			aGrava := {}

			If SE1->E1_TIPO == 'NCC' 

				If Select("TRB1") > 0
					TRB1->(DbCloseArea())
				EndIf

				cQuery := "SELECT SUBSTRING(UI_SNOTA,1,3) AS SERIE, " + CRLF  
				cQuery += "SUBSTRING(UI_SNOTA,4,9) AS NOTA, " + CRLF
				cQuery += "UI_MOTDEVO AS MOTDEV, " + CRLF
				cQuery += "ZZK_DEVCOM AS DEVCOM, " + CRLF
				cQuery += "ZZK_TIPO   AS TIPODEV, " + CRLF
				cQuery += "ZZK_DESC   AS DESCDEV, " + CRLF
				cQuery += "UI_CODCLI AS CLIENTE, " + CRLF
				cQuery += "UI_LOJA AS LOJA,      " + CRLF
				cQuery += "UI_VEND AS VENDEDOR, " + CRLF
				cQuery += "UJ_PRODUTO AS PRODRNC, " + CRLF
				cQuery += "UJ_ITEM  AS ITEMRNC, " + CRLF
				cQuery += "UJ_CODIGO AS CODRNC " + CRLF
				cQuery += "FROM "+RetSqlName("SUI")+" AS SUI WITH (NOLOCK) " + CRLF
				cQuery += "INNER JOIN "+RetSqlName("SUJ")+" AS SUJ WITH (NOLOCK) ON UJ_FILIAL = UI_FILIAL  " + CRLF
				cQuery += "AND UJ_CODIGO = UI_CODIGO  " + CRLF
				cQuery += "AND UJ_ENTIDA = 'SUI' " + CRLF
				cQuery += "AND SUJ.D_E_L_E_T_ = ' '   " + CRLF
				cQuery += "INNER JOIN "+RetSqlName("ZZK")+" AS ZZK WITH (NOLOCK) ON ZZK_FILIAL = ' '  " + CRLF
				cQuery += "AND ZZK_TIPO = UI_MOTDEVO  " + CRLF
				cQuery += "AND ZZK.D_E_L_E_T_ = ' '   " + CRLF
				cQuery += "WHERE UI_FILIAL = '"+xFilial("SUI")+"' " + CRLF
				cQuery += "AND SUBSTRING(UI_SNOTA,1,3) = '"+TRBF->D1_SERIORI+"' " + CRLF
				cQuery += "AND SUBSTRING(UI_SNOTA,4,9) = '"+TRBF->D1_NFORI+"'  " + CRLF
				cQuery += "AND UI_CODCLI = '"+TRBF->D1_FORNECE+"' " + CRLF
				cQuery += "AND UI_LOJA   = '"+TRBF->D1_LOJA+"' " + CRLF
				cQuery += "AND SUI.D_E_L_E_T_ = ' ' " + CRLF

				TCQUERY cQuery NEW ALIAS TRB1

				TRB1->(dbGoTop())

				While TRB1->(!Eof())

					If Select("TRB2") > 0
						TRB2->(DbCloseArea())
					EndIf

					cQueryA := "SELECT E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO  " + CRLF
					cQueryA += "FROM "+RetSqlName("SE1")+" AS SE1  WITH (NOLOCK) " + CRLF
					cQueryA += " WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' " + CRLF
					cQueryA += " AND SE1.E1_NUM     = '"+TRBF->D1_DOC+"'  " + CRLF
					cQueryA += " AND SE1.E1_PREFIXO = '"+TRBF->D1_SERIE+"'  " + CRLF
					cQueryA += " AND SE1.E1_CLIENTE = '"+TRBF->D1_FORNECE+"'  " + CRLF
					cQueryA += " AND SE1.E1_LOJA    = '"+TRBF->D1_LOJA+"'  " + CRLF
					cQueryA += " AND SE1.E1_TIPO    = 'NCC'   " + CRLF
					cQueryA += " AND SE1.D_E_L_E_T_ = ' ' " + CRLF
				
					TCQUERY cQueryA NEW ALIAS TRB2

					TRB2->(dbGoTop())

					If TRB2->(!Eof()) .And. TRB2->(!Bof()) 
									
						_cFilial  := TRB2->E1_FILIAL
						_cPrefixo := TRB2->E1_PREFIXO
						_cNum     := TRB2->E1_NUM
						_cParcela := TRB2->E1_PARCELA
						_cTipo    := TRB2->E1_TIPO 
					
					EndIf												
						
					DbSelectArea("SE1")
					DbSetOrder(1)    //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
					If SE1->(dbSeek(_cFilial+_cPrefixo+_cNum+_cParcela+_cTipo)) 

						RecLock("SE1")

						SE1->E1_XDEVCOM := TRB1->DEVCOM   // GRAVA SE A COMISSÃO É DEVIDA OU NÃO
						SE1->E1_XTIPO   := TRB1->TIPODEV  // GRAVA TIPO DE DEVOLUÇÃO NO TITULO NCC
						SE1->E1_XDESC   := TRB1->DESCDEV  // GRAVA DECRIÇÃO DA DEVOLUÇÃO TITULO NCC
						SE1->E1_VEND1   := TRB1->VENDEDOR // GRAVA VENDEDOR NO TITULO NCC
						SE1->E1_XCODRNC := TRB1->CODRNC   // GRAVA RNC NA DEVOLUÇÃO
						
						SE1->(MsUnlock())
								
					EndIf

					Aadd(aGrava,{TRB1->PRODRNC,;
								 TRB1->CODRNC,;
								 TRB1->ITEMRNC})
					
					TRB1->(dbSkip())

				Enddo

			EndIf

			TRBF->(dbSkip())

		EndDo

		If Len(aGrava) > 0 
	
			If Select("TRB4") > 0
				TRB4->(DbCloseArea())
			EndIf

			cQuery4 := "SELECT D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM "+CRLF
			cQuery4 += "FROM "+RetSqlName("SD1")+" AS SD1 WITH (NOLOCK) "+CRLF
			cQuery4 += "WHERE D1_FILIAL = '"+xFilial("SD1")+"' "+CRLF
			cQuery4 += " AND D1_DOC     = '"+SF1->F1_DOC+"' "+CRLF
			cQuery4 += " AND D1_SERIE   = '"+SF1->F1_SERIE+"' "+CRLF
			cQuery4 += " AND D1_FORNECE = '"+SF1->F1_FORNECE+"' "+CRLF
			cQuery4 += " AND D1_LOJA    = '"+SF1->F1_LOJA+"' "+CRLF
			cQuery4 += " AND SD1.D_E_L_E_T_ = ' ' "+CRLF 

			TcQuery cQuery4 ALIAS "TRB4" NEW

			TRB4->(DbGoTop())

			While TRB4->(!Eof())

				DbSelectArea("SD1")
				DbSetOrder(1)    //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
				If SD1->(dbSeek(xFilial("SD1")+TRB4->D1_DOC+TRB4->D1_SERIE+TRB4->D1_FORNECE+TRB4->D1_LOJA+TRB4->D1_COD+TRB4->D1_ITEM)) 

					For nGrava := 1 to Len(aGrava)

						RecLock("SD1",.F.)

						If aGrava[nGrava][01] == TRB4->D1_COD
							SD1->D1_U_IDRNC := aGrava[nGrava][02]
							SD1->D1_U_ITRNC := aGrava[nGrava][03]
						EndIf	

						SD1->(MsUnlock())

					Next nGrava

				EndIf

				TRB4->(dbSkip())

			EndDo
		
		EndIf
	
	EndIf

EndIf
// FIM 

EQWfRespCC()

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf
If Select("TRB2") > 0
	TRB2->(DbCloseArea())
EndIf
If Select("TRB3") > 0
	TRB3->(DbCloseArea())
EndIf
If Select("TRB4") > 0
	TRB4->(DbCloseArea())
EndIf
If Select("TRBF") > 0
	TRBF->(DbCloseArea())
EndIf
If Select("TRBI") > 0
    TRBI->(DbCloseArea())
EndIf

AEval(aAreas, {|uArea| RestArea(uArea)})

Return
/*
BeWfRespCC 
Rodrigo Sousa         
Data 12/09/2013
WorkFlow Notificação de Inclusão Documento de Entrada	   
Por Responsáveis pelo Centro de Custo					   
Solicitante: Ronison - Depto. Controladoria				   
Finalidade: Notificar o responsável pelo Centro de Custo cadastrada na tabela SZU e utilizado nos itens do Documento de entrada. 					   ³±±
Motivo    : Obter maior controle das entradas de notas para seus centros de custos.
*/
Static Function EQWfRespCC()

Local aArea  	:= GetArea()
Local aAreaSD1  := SD1->(GetArea())
Local aAreaSDE  := SDE->(GetArea())
Local aAreaSB1  := SB1->(GetArea())

Local aItensSD1	:= {}
Local aItensSDE	:= {}

Local cCodUser	:= ""
Local cMailUser	:= ""
Local cNomUsr	:= ""
Local cMailNot	:= ""
Local cNaturez	:= ""
Local cDescNat	:= ""
Local nX        := 0

Local oProc
Local oHtml

//Carrega Itens da Nota Fiscal de Entrada
dbSelectArea("SD1")
dbSetOrder(1)
dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)

Do While !SD1->( Eof() ) .AND. SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+SD1->D1_COD)
	
	aAdd( aItensSD1, {	SD1->D1_ITEM,;
						SD1->D1_COD,; 
						SB1->B1_DESC,; 
						SD1->D1_TP,; 
						SD1->D1_TES,; 
						SD1->D1_CF,; 
						SD1->D1_RATEIO,;
						SD1->D1_CC,;
						SD1->D1_QUANT,;
						SD1->D1_UM,;
						SD1->D1_VUNIT,;
						SD1->D1_TOTAL})

	//Carrega Linhas de Rateio do Item se houver
	If SD1->D1_RATEIO == '1'
		dbSelectArea("SDE")
		dbSetOrder(1)
		dbSeek(xFilial("SDE")+SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM))
	
		Do While !SDE->( Eof() ) .AND. SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM) == SDE->(DE_DOC+DE_SERIE+DE_FORNECE+DE_LOJA+DE_ITEMNF)

			aAdd( aItensSDE, {	SDE->DE_ITEMNF,;
								SDE->DE_ITEM,; 
								SD1->D1_COD,; 
								SDE->DE_PERC,;
								SDE->DE_CUSTO1,;
								SDE->DE_CC,;
								Round(SD1->D1_TOTAL * (SDE->DE_PERC/100),2),;
								SDE->DE_CONTA })
								
			//Carrega Emails dos Responsáveis pelo Centro de Custo
			cMailNot := EQGetSZU(SDE->DE_CC,cMailNot)

			SDE->( dbSkip() )
		EndDo
	Else
		//Carrega Emails dos Responsáveis pelo Centro de Custo
		cMailNot := EQGetSZU(SD1->D1_CC,cMailNot)
	EndIf

	SD1->( dbSkip() )

EndDo

If !Empty(cMailNot)

	//Obtém dados da Natureza
	cNaturez := MAFISRET(,"NF_NATUREZA")
	
	dbSelectArea("SED")
	dbSetOrder(1)
	If dbSeek(xFilial("SED")+cNaturez)
		cDescNat := SED->ED_DESCRIC
	EndIf                          
	
	//Dados do Usuario
	cCodUser 	:= RetCodUsr() 				// Função que retorna o codigo do usuario corrente.
	cMailUser  	:= UsrRetMail(cCodUser)    	// Retorna eMail do Usuario
	cNomUsr  	:= UsrFullName(cCodUser)   	// Retorna eMail do Usuario

	// Instancia Objeto do WF	
	oProc := TWFProcess():New("100200","Notificacao de Inclusão de N.F de Entrada - Por Centro de Custo")
	oProc:NewTask('Inicio',"\workflow\html\EQNotNFE.html")
	oHtml:= oProc:oHtml

	//Carrega dados da Tabela Dados da Nota Fiscal
	oHtml:valbyname( "cEmpresa"  ,	SM0->M0_CODIGO )
	oHtml:valbyname( "cCodFil"  ,	SM0->M0_CODFIL+" "+SM0->M0_FILIAL )
	oHtml:valbyname( "cNomUsr"  , 	Alltrim(Capital(cNomUsr )))
	oHtml:valbyname( "cEmail" 	, 	ALLTRIM(Lower(cMailUser)))
	oHtml:valbyname( "cCodFor" 	, 	SF1->F1_FORNECE )
	oHtml:valbyname( "cLojaFor"	, 	SF1->F1_LOJA )
	oHtml:valbyname( "cNomeFor"	, 	SA2->A2_NREDUZ )
	oHtml:valbyname( "cNumNF"  	, 	ALLTRIM(SF1->F1_DOC) )
	oHtml:valbyname( "cSerie"  	, 	SF1->F1_SERIE )
	oHtml:valbyname( "cEmissao"	, 	DTOC(SF1->F1_EMISSAO) )
	oHtml:valbyname( "nVlrTot" 	, 	Transform( SF1->F1_VALBRUT , '@E 999,999,999.99') )
	oHtml:valbyname( "cEspecNF"	, 	SF1->F1_ESPECIE )
	oHtml:valbyname( "cChaveNFe",	SF1->F1_CHVNFE )
	oHtml:valbyname( "cNaturez",	cNaturez )
	oHtml:valbyname( "cDescNat",	cDescNat )

	//Carrega dados da Tabela Itens da Nota Fiscal
	aSort(aItensSD1,,, {|x, y| x[1] < y[1]})

	For nX := 1 to Len(aItensSD1)
				
		aAdd( (oHtml:valbyname( "itNf.Item" 		)), aItensSD1[nX][01]     	) 
		aAdd( (oHtml:valbyname( "itNf.Codigo" 		)), aItensSD1[nX][02] 		) 
		aAdd( (oHtml:valbyname( "itNf.Descr"		)), aItensSD1[nX][03]	    )
		aAdd( (oHtml:valbyname( "itNf.Tipo"			)), aItensSD1[nX][04]	    )
		aAdd( (oHtml:valbyname( "itNf.Tes"			)), aItensSD1[nX][05]	    )
		aAdd( (oHtml:valbyname( "itNf.Cfo"			)), aItensSD1[nX][06]	    )
		aAdd( (oHtml:valbyname( "itNf.Rateio"   	)), Iif(aItensSD1[nX][07] == '1', 'Sim', 'Não') 		) 
		aAdd( (oHtml:valbyname( "itNf.CCusto"   	)), aItensSD1[nX][08]		) 
		aAdd( (oHtml:valbyname( "itNf.Quant"   		)), Transform( aItensSD1[nX][09],'@E 999,999.99' )) 
		aAdd( (oHtml:valbyname( "itNf.UM"   		)), aItensSD1[nX][10]		) 
		aAdd( (oHtml:valbyname( "itNf.VlrUnit"   	)), Transform( aItensSD1[nX][11],'@E 999,999,999.99' 	)) 
		aAdd( (oHtml:valbyname( "itNf.VlrTotal"   	)), Transform( aItensSD1[nX][12],'@E 999,999,999.99' 	)) 

	Next nX
	
	// Carrega dados da Tabela Itens do Rateio
	If Len(aItensSDE) > 0 
	
		aSort(aItensSDE,,, {|x, y| x[1]+x[2] < y[1]+x[2]})
	
	    For nX := 1 to Len(aItensSDE)
			aAdd( (oHtml:valbyname( "itRat.Item" 		)), aItensSDE[nX][01]     	) 
			aAdd( (oHtml:valbyname( "itRat.Codigo" 		)), aItensSDE[nX][03] 		) 
			aAdd( (oHtml:valbyname( "itRat.PercRat"		)), Transform( aItensSDE[nX][04],'@E 999.99' ))
			aAdd( (oHtml:valbyname( "itRat.ValRat"   	)), Transform( aItensSDE[nX][07],'@E 999,999,999.99' 	)) 
			aAdd( (oHtml:valbyname( "itRat.CCusto"   	)), aItensSDE[nX][06]		) 
			aAdd( (oHtml:valbyname( "itRat.CtaCont"   	)), aItensSDE[nX][08]		) 
		Next nX	
	Else
		aAdd( (oHtml:valbyname( "itRat.Item" 		)), ''     	) 
		aAdd( (oHtml:valbyname( "itRat.Codigo" 		)), 'Não existe rateio.'		) 
		aAdd( (oHtml:valbyname( "itRat.PercRat"		)), Transform( 0	,'@E 999.99' ))
		aAdd( (oHtml:valbyname( "itRat.ValRat"   	)), Transform( 0	,'@E 999,999,999.99' 	)) 
		aAdd( (oHtml:valbyname( "itRat.CCusto"   	)), ''							) 
		aAdd( (oHtml:valbyname( "itRat.CtaCont"   	)), ''							) 
	EndIf

	//Ativa envio do Email de Notificação
	ConOut('Notificação de Inclusão de N.F de Entrada Por Centro de Custo: ' + alltrim(SF1->F1_DOC) + " Serie: " + SF1->F1_SERIE )

	oProc:cBCC := cMailNot

	oProc:cSubject := "Notificacao de Inclusao de N.F. de Entrada Por Centro de Custo"
	oProc:Start()
	oProc:Finish()
	wfsendmail()

EndIf	

RestArea( aArea )
RestArea ( aAreaSD1 )
RestArea ( aAreaSDE )
RestArea ( aAreaSB1 )

Return
/*
Rotina    : BeGetSZU	
Autor     : Rodrigo Sousa
Data      : 20/08/2012
Descriçao : Busca Emails dos responsáveis pelo Centro de Custo
cParam1   : Centro de Custo	
cParam2   : Emails Adicionados anteriormente
*/
Static Function EQGetSZU(cCCusto,cRet)

Default cRet	:= ""
Default cCCusto := ""

//Busca Emails conforme Centro de Custo

If !Empty(cCCusto)

    dbSelectArea("SZU")
    dbSetOrder(1)
    dbSeek(xFilial("SZU")+cCCusto)
    
	Do While !SZU->( Eof() ) .And. xFilial("SZU") == SZU->ZU_FILIAL .And. SZU->ZU_CCUSTO == cCCusto
        If !Alltrim(SZU->ZU_EMAIL) $ cRet .And. SZU->ZU_NOTIFIC == '1'
			cRet += Alltrim(SZU->ZU_EMAIL)+";"
        EndIf
		
		SZU->(dbSkip())
	EndDo	
EndIf

Return cRet
