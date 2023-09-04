#Include 'Protheus.ch'
#Include 'TbiConn.ch'
#Include 'TopConn.ch'

User Function EQWSCMoe( aParam ) // Client WS de Moedas...

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se rotina esta sendo executada via Schedule				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("SX5") <= 0
	lSchdAut := .T.
	If ValType( aParam ) == "A"
	 	RpcSetEnv( aParam[2], aParam[3],,, "FIN",, {"SM2"})
	Else
		Prepare Environment Empresa "02" Filial "00" Tables "SM2" Modulo "FIN"
		Set Deleted On
		Set Century On
		Set Date Format "dd/mm/yyyy"
	EndIf
EndIf

//Variaveis Locais
Private oCotacaoMoedas := Nil
Private cRetCotMoeda   := ""
Private cAvisos        := ""
Private cErros         := ""
Private cReplace       := ""
Private oXMLCotMoeda   := Nil
Private dDataDolar     := STOD("")
Private nCotDolar      := 0
Private nCodDolar      := 10813 // Dolar de Compra
Private lAtzDolar      := .F.
Private dDataEuro      := STOD("")
Private nCotEuro       := 0
Private nCodEuro       := 21620 // Euro de Compra
Private lAtzEuro       := .F.
Private aMoedas        := {}
Private nMoeda         := 0

nCodDolar := 1     // Dolar de Venda
nCodEuro  := 21619 // Euro de Venda

oCotacaoMoedas   := WSFachadaWSSGSService():New()
//Setado o Codigo 10813 respectivo ao Dolar (Compra)
oCotacaoMoedas:nin0 := nCodDolar

//Verificamos se o metodo getUltimoValorXML do WsClient WSFachadaWSSGSService foi consumido com sucesso
If (oCotacaoMoedas:getUltimoValorXML())
	//Obtem o retorno de cotacao da Moeda no formato XML
	cRetCotMoeda := oCotacaoMoedas:cgetUltimoValorXMLReturn
	//Utiliza a funcao XmlParser para converter o retorno XML do WS para uma variavel do Tipo Objeto
	oXMLCotMoeda :=  XmlParser(cRetCotMoeda, cReplace, @cErros, @cAvisos)
	//Verifica se houve erro ao consumir o WS
	If AllTrim(cErros) == ""
		//Obtem a Data da Ultima Cotacao
		dDataDolar := StoD(StrZero(Val(oXMLCotMoeda:_RESPOSTA:_SERIE:_DATA:_ANO:TEXT), 4) + StrZero(Val(oXMLCotMoeda:_RESPOSTA:_SERIE:_DATA:_MES:TEXT), 2) + StrZero(Val(oXMLCotMoeda:_RESPOSTA:_SERIE:_DATA:_DIA:TEXT), 2))
		//Obtem o Valor da Ultima Cotacao
		nCotDolar  := Val(StrTran(oXMLCotMoeda:_RESPOSTA:_SERIE:_VALOR:TEXT, ",", "."))
		//Operacao realizada com sucesso
		lAtzDolar := .T.
	EndIf
EndIf

If lAtzDolar
	oCotacaoMoedas:nin0 := nCodEuro

	//Verificamos se o metodo getUltimoValorXML do WsClient WSFachadaWSSGSService foi consumido com sucesso
	If (oCotacaoMoedas:getUltimoValorXML())
		//Obtem o retorno de cotacao da Moeda no formato XML
		cRetCotMoeda := oCotacaoMoedas:cgetUltimoValorXMLReturn
		//Utiliza a funcao XmlParser para converter o retorno XML do WS para uma variavel do Tipo Objeto
		oXMLCotMoeda :=  XmlParser(cRetCotMoeda, cReplace, @cErros, @cAvisos)
		//Verifica se houve erro ao consumir o WS
		If AllTrim(cErros) == ""
			//Obtem a Data da Ultima Cotacao
			dDataEuro := StoD(StrZero(Val(oXMLCotMoeda:_RESPOSTA:_SERIE:_DATA:_ANO:TEXT), 4) + StrZero(Val(oXMLCotMoeda:_RESPOSTA:_SERIE:_DATA:_MES:TEXT), 2) + StrZero(Val(oXMLCotMoeda:_RESPOSTA:_SERIE:_DATA:_DIA:TEXT), 2))
			//Obtem o Valor da Ultima Cotacao
			nCotEuro  := Val(StrTran(oXMLCotMoeda:_RESPOSTA:_SERIE:_VALOR:TEXT, ",", "."))
			//Operacao realizada com sucesso
			lAtzEuro := .T.
		EndIf
	EndIf
EndIf

If lAtzDolar == lAtzEuro .And. dDataDolar == dDataEuro .And. (nCotDolar <> 0.00 .And. nCotEuro <> 0.00)
	If dDataDolar == MsDate()
		dDataDolar := dDataDolar + 1
		dDataEuro  := dDataEuro  + 1

		aAdd( aMoedas, {dDataDolar, nCotDolar, nCotEuro})

		If DOW( dDataDolar ) == 7
			aAdd( aMoedas, {dDataDolar + 1, nCotDolar, nCotEuro}) // Domingo
			aAdd( aMoedas, {dDataDolar + 2, nCotDolar, nCotEuro}) // Segunda
		EndIf

		For nMoeda := 1 To Len( aMoedas )
			// Atualiza SM2...
			Begin Transaction
				dbSelectArea("SM2")
				dbSetOrder(1)
				If dbSeek(aMoedas[nMoeda][1])
					RecLock("SM2",.F.)
				Else
					RecLock("SM2",.T.)
				EndIf
	
				SM2->M2_DATA 	:= aMoedas[nMoeda][1]
				SM2->M2_MOEDA2  := aMoedas[nMoeda][2]
				SM2->M2_MOEDA3	:= 0
				SM2->M2_MOEDA4	:= aMoedas[nMoeda][3]
				SM2->M2_INFORM	:= "S"
				SM2->(MsUnlock())
			End Transaction

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza Moeda Easy													   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			/*
			Begin Transaction
				// Dolar
				dbSelectArea("SYE")
				dbSetOrder(1)
				If dbSeek(xFilial("SYE")+DtoS(aMoedas[nMoeda][1])+"US$")
					RecLock("SYE",.F.)
				Else
					RecLock("SYE",.T.)
				EndIf
				SYE->YE_DATA 	:= aMoedas[nMoeda][1]
				SYE->YE_MOEDA  	:= "US$"
				SYE->YE_VLCON_C	:= aMoedas[nMoeda][2]
				SYE->YE_TX_COMP := aMoedas[nMoeda][2]
				SYE->YE_MOE_FIN	:= "2"
				SYE->(MsUnlock())
			End Transaction

			Begin Transaction
				// Dolar
				dbSelectArea("SYE")
				dbSetOrder(1)
				If dbSeek(xFilial("SYE")+DtoS(aMoedas[nMoeda][1])+"EUR")
					RecLock("SYE",.F.)
				Else
					RecLock("SYE",.T.)
				EndIf
				SYE->YE_DATA 	:= aMoedas[nMoeda][1]
				SYE->YE_MOEDA  	:= "EUR"
				SYE->YE_VLCON_C	:= aMoedas[nMoeda][3]
				SYE->YE_TX_COMP := aMoedas[nMoeda][3]
				SYE->YE_MOE_FIN	:= "4"
				SYE->(MsUnlock())
			End Transaction
			*/
		Next
	ElseIf dDataDolar == DataValida( MsDate(), .F. ) // Feriado...
		dDataDolar := dDataDolar + 1
		dDataEuro  := dDataEuro  + 1

		aAdd( aMoedas, {dDataDolar, nCotDolar, nCotEuro})

		If DOW( dDataDolar ) == 7
			aAdd( aMoedas, {dDataDolar + 1, nCotDolar, nCotEuro}) // Domingo
			aAdd( aMoedas, {dDataDolar + 2, nCotDolar, nCotEuro}) // Segunda
		ElseIf DOW( dDataDolar ) == 6 // Se Sexta
			aAdd( aMoedas, {dDataDolar + 1, nCotDolar, nCotEuro}) // Sábado
			aAdd( aMoedas, {dDataDolar + 2, nCotDolar, nCotEuro}) // Domingo
			aAdd( aMoedas, {dDataDolar + 3, nCotDolar, nCotEuro}) // Segunda
		EndIf

		For nMoeda := 1 To Len( aMoedas )
			// Atualiza SM2...
			Begin Transaction
				dbSelectArea("SM2")
				dbSetOrder(1)
				If dbSeek(aMoedas[nMoeda][1])
					RecLock("SM2",.F.)
				Else
					RecLock("SM2",.T.)
				EndIf
				SM2->M2_DATA 	:= aMoedas[nMoeda][1]
				SM2->M2_MOEDA2  := aMoedas[nMoeda][2]
				SM2->M2_MOEDA3	:= 0
				SM2->M2_MOEDA4	:= aMoedas[nMoeda][3]
				SM2->M2_INFORM	:= "S"
				SM2->(MsUnlock())
			End Transaction

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza Moeda Easy													   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			/*
			Begin Transaction
				// Dolar
				dbSelectArea("SYE")
				dbSetOrder(1)
				If dbSeek(xFilial("SYE")+DtoS(aMoedas[nMoeda][1])+"US$")
					RecLock("SYE",.F.)
				Else
					RecLock("SYE",.T.)
				EndIf
				SYE->YE_DATA 	:= aMoedas[nMoeda][1]
				SYE->YE_MOEDA  	:= "US$"
				SYE->YE_VLCON_C	:= aMoedas[nMoeda][2]
				SYE->YE_TX_COMP := aMoedas[nMoeda][2]
				SYE->YE_MOE_FIN	:= "2"
				SYE->(MsUnlock())
			End Transaction

			Begin Transaction
				// Dolar
				dbSelectArea("SYE")
				dbSetOrder(1)
				If dbSeek(xFilial("SYE")+DtoS(aM]oedas[nMoeda][1])+"EUR")
					RecLock("SYE",.F.)
				Else
					RecLock("SYE",.T.)
				EndIf
				SYE->YE_DATA 	:= aMoedas[nMoeda][1]
				SYE->YE_MOEDA  	:= "EUR"
				SYE->YE_VLCON_C	:= aMoedas[nMoeda][3]
				SYE->YE_TX_COMP := aMoedas[nMoeda][3]
				SYE->YE_MOE_FIN	:= "4"
				SYE->(MsUnlock())
			End Transaction
			*/
		Next
	EndIf
EndIf

Return