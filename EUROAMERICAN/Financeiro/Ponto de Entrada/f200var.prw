#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} f200var
//Atualiza situacao do titulo, caso seja protesto.
//01 - cNumTit -> Número do título
//02 - Baixa -> Data da Baixa
//03 - cTipo -> Tipo do título
//04 - cNsNum -> Nosso Número
//05 - nDespes -> Valor da despesa
//06 - nDescont -> Valor do desconto
//07 - nAbatim -> Valor do abatimento
//08 - nValRec -> Valor recebidos
//09 - nJuros -> Juros
//10 - nMulta -> Multa
//11 - nOutrDesp -> Outras despesas
//12 - nValCc -> Valor do crédito
//13 - dDataCred -> Data do crédito
//14 - cOcorr -> Ocorrencia
//15 - cMotBai -> Motivo da baixa
//16 - xBuffer -> Linha inteira
//17 - dDtVc -> Data do vencimento
@author mjloz
@since 02/05/2018
@version 1.0
/*/
User Function f200var()
	Local aArea    := GetArea()
	Local aAreaSE1 := SE1->(GetArea())
	Local aTitulo  := PARAMIXB
	Local aAreaSA6 := SA6->(GetArea())
	Local _nReten := GETMV("MV_XD1",,1)//SA6->A6_RETENCA


	//Transferencia automatica para Cartorio
	If AllTrim(aTitulo[1, 14]) $ "23#21"
		SE1->(dbSetOrder(1))
		If SE1->(dbSeek(xFilial("SE1") + AllTrim(aTitulo[1, 1])))
			If SE1->E1_SALDO != 0
				If (SE1->E1_PORTADO == "033" .and. AllTrim(aTitulo[1, 14]) == "21") .or. (SE1->E1_PORTADO != "033" .and. AllTrim(aTitulo[1, 14]) $ "23|98")
					SE1->(RecLock("SE1", .F.))
					SE1->E1_SITUACA := "F"
					SE1->(MsUnLock())
	    		EndIf
			EndIf
		EndIf
	EndIf

cTipo := "01"

//tratamento para o banco sofisa 
If MV_PAR06 == '707' 
	dBaixa  := ddatabase + _nReten // Tratamento para data
	nValRec := nValRec + ndespes //tratamento para não gera linha despesas(SE5)
	ndespes := 0
EndIf

If MV_PAR06 == '637' 
	dBaixa  := ddatabase + _nReten // Tratamento para data
	nValRec := nValRec + ndespes //tratamento para não gera linha despesas(SE5)
	ndespes := 0
EndIf
	
//tratamento para itau não gera linha despesas(SE5)
If mv_par06 == '341'
	nValRec := nValRec + ndespes
	ndespes := 0
EndIf 

RestArea(aAreaSE1)
RestArea(aArea)

Return
