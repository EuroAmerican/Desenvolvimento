#Include "Totvs.ch"

/*/{Protheus.doc} BOLSANTA
Programa responsável pela impressão de boletos do Banco Itaú, gravação do nosso numero na tabela SE1.
@type function Relatorio
@version 1.0
@author S/A - Alterado por mario.antonaccio
@since 02/10/15 - Alterado em 20/09/2021
/*/

User Function BOLSANTA()

	Local _cAlias      := GetNextAlias()
	Local cEdit1       := Space(25)
	Local lChk         := .F.
	//Local lMark        := .F.
	Local oChk         := Nil
	Local oEdit1
	Local oNo          := LoadBitmap( GetResources(), "LBNO" )
	Local oOk          := LoadBitmap( GetResources(), "LBOK" )
	// Variaveis Private
	Private aReturn    :={"Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private aVetor     := {}
	Private cDesc1     := "Programa de impressao de boletos para o banco Santander."
	Private cDesc2     := ""
	Private cDesc3     := ""
	Private cFilter    := ""
	Private cIndexKey  := ""
	Private cIndexName := ""
	Private cPerg      := "CBR009"
	Private cString    := "SE1"
	Private lEnd       := .F.
	Private lExec      := .F.
	Private nLastKey   := 0
	Private oDBlSant
	Private Tamanho    := "M"
	Private titulo     := "Impressão do Boleto Santader"
	Private wnrel      := "BOLSant"

	nOpc:=If(nopc==NIL,0,nOpc)
	

	/*
Perguntas

De Prefixo		,"C",03,0,"MV_PAR01"
Ate Prefixo		,"C",03,0,"MV_PAR02"
De Numero		,"C",09,0,"MV_PAR03"
Ate Numero		,"C",09,0,"MV_PAR04"
De Parcela		,"C",03,0,"MV_PAR05"
Ate Parcela		,"C",03,0,"MV_PAR06"
De Portador		,"C",03,0,"MV_PAR07"
Ate Portador	,"C",03,0,"MV_PAR08"
De Cliente		,"C",06,0,"MV_PAR09"
Ate Cliente		,"C",06,0,"MV_PAR10"
De Loja			,"C",02,0,"MV_PAR11"
Ate Loja		,"C",02,0,"MV_PAR12"
De Emissao		,"D",08,0,"MV_PAR13"
Ate Emissao		,"D",08,0,"MV_PAR14"
De Vencimento	,"D",08,0,"MV_PAR15"
Ate Vencimento	,"D",08,0,"MV_PAR16"
Do Bordero		,"C",06,0,"MV_PAR17"
Ate Bordero		,"C",06,0,"MV_PAR18"

Somente Visualizaçao
Codigo			,"C",03,0,"MV_PAR19"
Agencia			,"C",04,0,"MV_PAR20"
Nro. Conta		,"C",10,0,"MV_PAR21"
DV Conta		,"C",01,0,"MV_PAR22"
	*/

	Pergunte (cPerg,.F.)
	//Atualizando ultimos registros para a conta SANTANDER
	SetMVValue(cPerg,"MV_PAR19", GETMV('MV_XBANSA',.T.,'033'))
	SetMVValue(cPerg,"MV_PAR20", GETMV('MV_XAGESA',.T.,'2056 '))
	SetMVValue(cPerg,"MV_PAR21", GETMV('MV_XCTASA',.T.,'13002998  '))
	SetMVValue(cPerg,"MV_PAR22", " ")

	Wnrel := SetPrint(cString,Wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,,)

	If nLastKey == 27
		Set Filter to
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Set Filter to
		Return
	Endif

	//Query de filtragem
	BeginSql alias _cAlias
		column E1_EMISSAO as Date
		column E1_VENCTO as Date
		SELECT
			SE1.E1_PREFIXO,
			SE1.E1_NUM,
			SE1.E1_PARCELA,
			SE1.E1_CLIENTE,
			SE1.E1_LOJA,
			SE1.E1_TIPO,
			SE1.E1_SALDO,
			SE1.E1_VENCREA,
			SE1.R_E_C_N_O_ AS REGSE1
		FROM
			%table:SE1% SE1
		INNER JOIN %Table:SA1% SA1
		ON SE1.E1_CLIENTE = SA1.A1_COD
			AND SE1.E1_LOJA = SA1.A1_LOJA
			AND SE1.E1_FILIAL = SA1.A1_FILIAL
			AND SA1.A1_BCO1 <> ' '
			AND SA1.%NotDel%
		WHERE
			SE1.E1_FILIAL = %Exp:xfilial("SE1")%
			AND SE1.E1_PREFIXO >= %Exp:MV_PAR01%
			AND SE1.E1_PREFIXO <= %Exp:MV_PAR02%
			AND SE1.E1_NUM >= %Exp:mv_par03%
			AND SE1.E1_NUM <= %Exp:mv_par04%
			AND SE1.E1_PARCELA >= %Exp:MV_PAR05%
			AND SE1.E1_PARCELA <= %Exp:MV_PAR06%
			AND SE1.E1_PORTADO >= %Exp:MV_PAR07%
			AND SE1.E1_PORTADO <= %Exp:MV_PAR08%
			AND SE1.E1_CLIENTE >= %Exp:MV_PAR09%
			AND SE1.E1_CLIENTE <= %Exp:MV_PAR10%
			AND SE1.E1_LOJA >= %Exp:MV_PAR11%
			AND SE1.E1_LOJA <= %Exp:MV_PAR12%
			AND SE1.E1_EMISSAO >= %Exp:DTOS(mv_par13)%
			AND SE1.E1_EMISSAO <= %Exp:DTOS(mv_par14)%
			AND SE1.E1_VENCREA >= %Exp:DTOS(mv_par15)%
			AND SE1.E1_VENCREA <= %Exp:DTOS(mv_par16)%
			AND SE1.E1_NUMBOR >= %Exp:MV_PAR17%
			AND SE1.E1_NUMBOR <= %Exp:MV_PAR18%
			AND SE1.E1_SALDO > 0
			AND SE1.E1_EMISSAO <> SE1.E1_VENCTO //  RETIRADO OS TITULOS A VISTA -MAA 20210827
			AND SE1.E1_NUMBCO = ' '
			AND SE1.E1_CLIENTE NOT IN ('000002', '008507')
			AND SE1.%notDel%
		ORDER BY
			SE1.E1_PREFIXO,
			SE1.E1_NUM,
			SE1.E1_PARCELA,
			SE1.E1_CLIENTE,
			SE1.E1_LOJA
	EndSql

	aQuery:=GetLastQuery()

	(_cAlias)->(DbGoTop())

	While(!(_cAlias)->(EoF()))

		aAdd( aVetor, { lChk,;
			ALLTRIM(Posicione("SA1",1,xFilial("SA1")+(_cALias)->(E1_CLIENTE+E1_LOJA),"A1_NOME")),;
			(_cALias)->E1_PREFIXO,;
			(_cALias)->E1_NUM,;
			(_cALias)->E1_PARCELA,;
			(_cALias)->E1_TIPO,;
			(_cALias)->E1_SALDO,;
			(_cALias)->E1_VENCREA,;
			(_cALias)->REGSE1} )

		(_cALias)->( dbSkip() )
	EndDo

	(_cALias)->(dbCloseArea())

	//³ Verifica se existem titulos para impressao.                  ³
	If Len( aVetor ) == 0
		ApMsgInfo("Não existe títulos para impressão de boletos.","Atenção")
		Return
	Endif

	//³ Chamada da Janela de selecao dos titulos para impressao      ³
	Define MsDialog oDBlSant Title "Emissão de Boletos [Banco Santander]" From C(225),C(407) To C(657),C(1061) Pixel

	@ C(049),C(005) TO C(190),C(325) LABEL " Títulos Selecionados " Pixel Of oDBlSant
	@ C(059),C(010) ListBox oLbx Var cVar Fields HEADER " ",;
		"Razão Social",;
		"Prefixo",;
		"Numero",;
		"Parc",;
		"Tipo",;
		"Valor",;
		"Vencimento",;
		"No.Registro" Size C(312),C(123) Of oDBlSant Pixel ;
		On dblClick( Inverter(oLbx:nAt),oLbx:Refresh(.F.) )

	oLbx:SetArray( aVetor )
	oLbx:bLine := {|| {Iif(aVetor[oLbx:nAt,1],oOk,oNo),;
		aVetor[oLbx:nAt,2],;
		aVetor[oLbx:nAt,3],;
		aVetor[oLbx:nAt,4],;
		aVetor[oLbx:nAt,5],;
		aVetor[oLbx:nAt,6],;
		aVetor[oLbx:nAt,7],;
		aVetor[oLbx:nAt,8],;
		aVetor[oLbx:nAt,9]}}

	@ C(200),C(037) MsGet oEdit1 Var cEdit1 Size C(085),C(009) COLOR CLR_BLACK Pixel Of oDBlSant
	@ C(200),C(227) Button "&Confirma"      Size C(037),C(012) Pixel Of oDBlSant Action(MontaRel(),oDBlSant:End())
	@ C(200),C(274) Button "&Sair"          Size C(037),C(012) Pixel Of oDBlSant Action(oDBlSant:End())
	@ C(201),C(008) Say "Pesquisar"         Size C(025),C(008) COLOR CLR_BLACK Pixel OF oDBlSant
	@ C(201),C(148) CheckBox oChk Var lChk Prompt "Marca/Desmarca" Size C(057),C(008) Pixel Of oDBlSant;
		On CLICK(Iif(lChk,Marca(lChk),Marca(lChk)))

	Activate MsDialog oDBlSant Centered

Return Nil

/*/{Protheus.doc} MontaRel
Montagem e Impressao de boleto Grafico do Banco Itau.
@type function Relatorio
@version  1.00
@author S/A - alterado por mario.antonaccio
@since 02/02/09 - alterado em 20/09/2021
@return Character, Nulo
/*/
Static Function MontaRel()

	LOCAL oPrint
	LOCAL nX := 0
	Local cNroDoc    :=  " "
	Local __cCodB    := GETMV('MV_XBANSA',.T.,'033') //CODIGO BANCO
	Local __cAgen    := GETMV('MV_XAGESA',.T.,'2056 ') //AGENCIA
	Local __cContaS  := GETMV('MV_XCTASA',.T.,'13002998  ') // CONTA

	LOCAL aDadosEmp    := {	SM0->M0_NOMECOM                                  								  ,; //[1]Nome da Empresa
		SM0->M0_ENDCOB                                     						  ,; //[2]Endereço
		AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
		"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
		"PABX/FAX: "+SM0->M0_TEL                                                  ,; //[5]Telefones
		"CNPJ: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+          	   ; //[6]
		Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                       ; //[6]
		Subs(SM0->M0_CGC,13,2)                                                    ,; //[6]CGC
		"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ; //[7]
		Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                         } //[7]I.E

	LOCAL aDadosTit
	LOCAL aDadosBanco
	LOCAL aDatSacado
	LOCAL aBolText     := {"Protestar apos 05 dias do vencimento"," Juros ao dia"}
	LOCAL nI           := 1
	LOCAL aCB_RN_NN    := {}
	LOCAL nVlrAbat     := 0
	Local iT

	oPrint:= TMSPrinter():New( "Boleto Santander" )
	oPrint:SetPortrait() // ou SetLandscape()
	oPrint:StartPage()   // Inicia uma nova página

	For it:= 1 To Len( aVetor )

		If !aVetor[it][1]
			Loop
		EndIf

		SE1->(dbGoTo(aVetor[it][9]))

		//Posiciona o SA6 (Bancos)
		SA6->(DbSetOrder(1))
		SA6->(DbSeek(xFilial("SA6")+__cCodB   +__cAgen +__cContaS ,.T.))

		//Posiciona na Arq de Parametros CNAB
		SEE->(DbSetOrder(1))
		SEE->(DbSeek(xFilial("SEE")+__cCodB   + __cAgen + __cContaS ,.T.))

		If Empty(SE1->E1_NUMBCO)

			Reclock("SEE",.F.)
			SEE->EE_FAXATU :=  soma1(alltrim(SEE->EE_FAXATU),5)
			MsUnlock()

			cNroDoc := FNossoN(alltrim(SEE->EE_FAXATU))

			DbSelectArea("SE1")
			Reclock("SE1",.F.)
			SE1->E1_NUMBCO := cNroDoc
			MsUnlock()

		else
			cNroDoc := alltrim(SE1->E1_NUMBCO)
		Endif

		//Posiciona o SA1 (Cliente)
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.))

		DbSelectArea("SE1")
		aDadosBanco  := {SA6->A6_COD                       							    ,;	// [1]Numero do Banco
			SA6->A6_NREDUZ                                       	,;  // [2]Nome do Banco
			SUBSTR(SA6->A6_AGENCIA, 1, 4)                        			,;	// [3]Agência
			SUBSTR(SA6->A6_DVAGE, 1, 1)									,;  // [4]Dígito da Agência
			ALLTRIM(SEE->EE_CONTA)										,; 	// [5]Conta Corrente
			Alltrim(SA6->A6_DVCTA)  										,;	// [6]Dígito da conta corrente
			"101"                                              			,;	// [7]Codigo da Carteira
			Alltrim(SEE->EE_CODEMP)										}	// [8]Codigo da empresa no banco

		If Empty(SA1->A1_ENDCOB)
			aDatSacado   := {AllTrim(SA1->A1_NOME)           ,;      	// [1]Razão Social
				AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           ,;      	// [2]Código
				AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO),;      	// [3]Endereço
				AllTrim(SA1->A1_MUN )                            ,;			// [4]Cidade
				SA1->A1_EST                                      ,;    		// [5]Estado
				SA1->A1_CEP                                      ,;      	// [6]CEP
				SA1->A1_CGC										 ,;			// [7]CGC
				SA1->A1_PESSOA								      }  		// [8]PESSOA
		Else

			aDatSacado   := {AllTrim(SA1->A1_NOME)            	 ,;   	// [1]Razão Social
				AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA               ,;   	// [2]Código
				AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC) ,;   	// [3]Endereço
				AllTrim(SA1->A1_MUNC)	                             ,;   	// [4]Cidade
				SA1->A1_ESTC	                                     ,;   	// [5]Estado
				SA1->A1_CEP                                          ,;   	// [6]CEP
				SA1->A1_CGC											 ,;		// [7]CGC
				SA1->A1_PESSOA										  }		// [8]PESSOA
		Endif

		nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
		//	Monta codigo de barras
		aCB_RN_NN    :=Ret_cBarra(SE1->E1_PREFIXO	,SE1->E1_NUM	,SE1->E1_PARCELA	,SE1->E1_TIPO	,;
			Subs(aDadosBanco[1],1,3)	,aDadosBanco[3]	,aDadosBanco[5] ,aDadosBanco[6]	,;
			cNroDoc		,(E1_VALOR-nVlrAbat)	, aDadosBanco[7]	,"9", aDadosBanco[8]	)

		aDadosTit	:= {AllTrim(E1_NUM)+iif(E1_PARCELA = ' ','0',AllTrim(E1_PARCELA))		     ,;  // [1] Número do título
			SE1->E1_EMISSAO                          ,;  // [2] Data da emissão do título
			dDataBase                    			 ,;  // [3] Data da emissão do boleto
			SE1->E1_VENCTO                           ,;  // [4] Data do vencimento
			(SE1->E1_SALDO - nVlrAbat)               ,;  // [5] Valor do título
			aCB_RN_NN[3]                        	 ,;  // [6] Nosso número (Ver fórmula para calculo)
			SE1->E1_PREFIXO                          ,;  // [7] Prefixo da NF
			"DM"	                                 ,;  // [8] Tipo do Titulo
			SE1->E1_MULTA                          	 ,;  // [9] MULTA
			SE1->E1_JUROS                          	  }  // [10] JUROS

		Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN,cNroDoc)
		nX := nX + 1
	 
		IncProc()
		nI := nI + 1

	Next

	oPrint:EndPage()     // Finaliza a página
	oPrint:Preview()     // Visualiza antes de imprimir

Return nil

/*/{Protheus.doc} Impress...
Impressao de boleto Grafico do Banco Itau.
@type function Relatorio
@version  1.00
@author S/A - Alterado por mario.antonaccio
@since 02/02/09 - alterado em 09/09/2021
@param oPrint, object, Objeto de impressao
@param aBitmap, array, Array cpm os Bitmaps
@param aDadosEmp, array, Array com os dados da empresa
@param aDadosTit, array, Array com os dados dos titulos
@param aDadosBanco, array, Array com dados deo banco
@param aDatSacado, array, Array com  dados do sacadon
@param aBolText, array, Array com dados de mensagens
@param CB_RN_NN, Array, Array com Codigo de Barras, Linha Digitavel e Nosso Nuemro
@return Character,  sem retorno
/*/

Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN,cNroDoc)

	LOCAL oFont8
	LOCAL oFont11c
	LOCAL oFont10
	LOCAL oFont14
	LOCAL oFont16n
	LOCAL oFont15
	LOCAL oFont14n
	LOCAL oFont24
	LOCAL nI := 0

	Private aLogo := {} //logo santander
	aLogo := array(1)//logo santander
	aLogo[1] := "\SYSTEM\qualyvinil.png"//logo santander

	oFont8   := TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont11  := TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont20  := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont21  := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont15  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont15n := TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont14n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrint:StartPage()   // Inicia uma nova página

	/******************/
	/* PRIMEIRA PARTE */
	/******************/

	nRow1 := 0

	oPrint:Line (nRow1+0150,500,nRow1+0070, 500)
	oPrint:Line (nRow1+0150,710,nRow1+0070, 710)

	oPrint:SayBitmap(nRow1+0000,100,"logoSant.png",390,230)    // Logo do Banco
	oPrint:Say  (nRow1+0075,513,"033-7",oFont21 )  		// [1]Numero do Banco

	oPrint:Say  (nRow1+0084,1900,"Comprovante de Entrega",oFont10)
	oPrint:Line (nRow1+0150,100,nRow1+0150,2300)

	oPrint:Say  (nRow1+0150,100 ,"Cedente",oFont8)
	oPrint:Say  (nRow1+0175,100 ,Alltrim(aDadosEmp[1]),oFont8)				//Nome + CNPJ
	oPrint:Say  (nRow1+0203,100 ,'Av. Antônio Bardela, 598 - Jandira - CNPJ:07.122.447/0001-82',oFont8)				//Nome + CNPJ

	oPrint:Say  (nRow1+0150,1060,"Agência/Código Cedente",oFont8)
	oPrint:Say  (nRow1+0200,1060,aDadosBanco[3]+"/"+aDadosBanco[8],oFont10)

	oPrint:Say  (nRow1+0150,1510,"Nro.Documento",oFont8)
	oPrint:Say  (nRow1+0200,1510,Alltrim(aDadosTit[7])+Alltrim(SubStr(aDadosTit[1],2,9)),oFont10) //Prefixo +Numero+Parcela

	oPrint:Say  (nRow1+0250,100 ,"Sacado",oFont8)
	oPrint:Say  (nRow1+0300,100 ,aDatSacado[1],oFont10)				//Nome

	oPrint:Say  (nRow1+0250,1060,"Vencimento",oFont8)
	oPrint:Say  (nRow1+0300,1060,StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4),oFont10)

	oPrint:Say  (nRow1+0250,1510,"Valor do Documento",oFont8)
	oPrint:Say  (nRow1+0300,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

	oPrint:Say  (nRow1+0400,0100,"Recebi(emos) o bloqueto/título",oFont10)
	oPrint:Say  (nRow1+0450,0100,"com as características acima.",oFont10)
	oPrint:Say  (nRow1+0350,1060,"Data",oFont8)
	oPrint:Say  (nRow1+0350,1410,"Assinatura",oFont8)
	oPrint:Say  (nRow1+0450,1060,"Data",oFont8)
	oPrint:Say  (nRow1+0450,1410,"Entregador",oFont8)

	oPrint:Line (nRow1+0250, 100,nRow1+0250,1900 )
	oPrint:Line (nRow1+0350, 100,nRow1+0350,1900 )
	oPrint:Line (nRow1+0450,1050,nRow1+0450,1900 ) //---
	oPrint:Line (nRow1+0550, 100,nRow1+0550,2300 )

	oPrint:Line (nRow1+0550,1050,nRow1+0150,1050 )
	oPrint:Line (nRow1+0550,1400,nRow1+0350,1400 )
	oPrint:Line (nRow1+0350,1500,nRow1+0150,1500 ) //--
	oPrint:Line (nRow1+0550,1900,nRow1+0150,1900 )

	oPrint:SayBitmap(0180,1930,aLogo[1],0370,0350)//logo qualyvinil
	
	/*****************/
	/* SEGUNDA PARTE */
	/*****************/

	nRow2 := 0

	//Pontilhado separador
	For nI := 100 to 2300 step 50
		oPrint:Line(nRow2+0580, nI,nRow2+0580, nI+30)
	Next nI

	oPrint:Line (nRow2+0710,100,nRow2+0710,2300)
	oPrint:Line (nRow2+0710,500,nRow2+0630, 500)
	oPrint:Line (nRow2+0710,710,nRow2+0630, 710)

	oPrint:SayBitmap(nRow1+0560,100,"logoSant.png",390,230) // Logo do Banco
	oPrint:Say  (nRow2+0635,513,"033-7",oFont21 )	// [1]Numero do Banco
	oPrint:Say  (nRow2+0644,755,aCB_RN_NN[2],oFont15n)			// Linha Digitavel do Codigo de Barras

	oPrint:Line (nRow2+0810,100,nRow2+0810,2300 )
	oPrint:Line (nRow2+0910,100,nRow2+0910,2300 )
	oPrint:Line (nRow2+0980,100,nRow2+0980,2300 )
	oPrint:Line (nRow2+1050,100,nRow2+1050,2300 )
	oPrint:Line (nRow2+0980,750,nRow2+1050,750)
	oPrint:Line (nRow2+0910,1000,nRow2+1050,1000)
	oPrint:Line (nRow2+0910,1300,nRow2+0980,1300)
	oPrint:Line (nRow2+0910,1480,nRow2+1050,1480)

	oPrint:Say  (nRow2+0710,100 ,"Local de Pagamento",oFont8)
	oPrint:Say  (nRow2+0725,400 ,"Qualquer banco até a data do vencimento",oFont10)
	
	oPrint:Say  (nRow2+0710,1810,"Vencimento"                                     ,oFont8)
	cString	:= StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
	nCol := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow2+0750,nCol,cString,oFont11c)

	oPrint:Say  (nRow2+0810,100 ,"Cedente"                                        ,oFont8)
	oPrint:Say  (nRow2+0850,100 ,Alltrim(aDadosEmp[1])+" - Av. Antônio Bardela,598 - CNPJ:07.122.447/0001-82" 	,oFont8) //Nome + CNPJ

	oPrint:Say  (nRow2+0810,1810,"Agência/Código Cedente",oFont8)
	cString := Alltrim(aDadosBanco[3]+"-0"+"/"+aDadosBanco[8])
	nCol := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow2+0850,nCol,cString,oFont11c)

	oPrint:Say  (nRow2+0910,100 ,"Data do Documento"                              ,oFont8)
	oPrint:Say  (nRow2+0940,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4),oFont10)

	oPrint:Say  (nRow2+0910,505 ,"Nro.Documento"                                  ,oFont8)
	oPrint:Say  (nRow2+0940,605 ,Alltrim(aDadosTit[7])+Alltrim(SubStr(aDadosTit[1],2,9))						  ,oFont10) //Prefixo +Numero+Parcela

	oPrint:Say  (nRow2+0910,1005,"Espécie Doc."                                   ,oFont8)
	oPrint:Say  (nRow2+0940,1050,aDadosTit[8]									  ,oFont10) //Tipo do Titulo

	oPrint:Say  (nRow2+0910,1305,"Aceite"                                         ,oFont8)
	oPrint:Say  (nRow2+0940,1400,"N"                                              ,oFont10)

	oPrint:Say  (nRow2+0910,1485,"Data do Processamento"                          ,oFont8)
	oPrint:Say  (nRow2+0940,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4),oFont10) // Data impressao

	oPrint:Say  (nRow2+0910,1810,"Nosso Número"                                   ,oFont8)
	cString := Alltrim(Substr(cNroDoc,1,12)+"-"+Substr(cNroDoc,13,1))
	nCol := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow2+0940,nCol,cString,oFont11c)

	oPrint:Say  (nRow2+0980,105 ,"Carteira"                                     ,oFont8)
	oPrint:Say  (nRow2+1010,155 ,aDadosBanco[7]+" - Cobrança simples"                 ,oFont10)

	oPrint:Say  (nRow2+0980,755 ,"Espécie"                                      ,oFont8)
	oPrint:Say  (nRow2+1010,805 ,"REAL"                                         ,oFont10)

	oPrint:Say  (nRow2+0980,1005,"Quantidade"                                   ,oFont8)
	oPrint:Say  (nRow2+0980,1485,"Valor"                                        ,oFont8)

	oPrint:Say  (nRow2+0980,1810,"Valor do Documento"                          	,oFont8)
	cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
	nCol := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow2+1010,nCol,cString ,oFont11c)

	oPrint:Say  (nRow2+1050,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do cedente)",oFont8)

	oPrint:Say  (nRow2+1080,100 ,aBolText[1]  ,oFont10)
	oPrint:Say  (nRow2+1120,100 ,"APÓS O VENCIMENTO COBRAR MORA DE R$......."+alltrim(transform(((aDadosTit[5]*6)/100),"@E 999,999.99"))       ,oFont10)
	
	oPrint:Say  (nRow2+1050,1810,"(-)Desconto/Abatimento"                         ,oFont8)
	oPrint:Say  (nRow2+1120,1810,"(-)Outras Deduções"                             ,oFont8)
	oPrint:Say  (nRow2+1190,1810,"(+)Mora/Multa"                                  ,oFont8)
	oPrint:Say  (nRow2+1260,1810,"(+)Outros Acréscimos"                           ,oFont8)
	oPrint:Say  (nRow2+1330,1810,"(=)Valor Cobrado"                               ,oFont8)

	oPrint:Say  (nRow2+1400,100 ,"Sacado"                                         ,oFont8)
	oPrint:Say  (nRow2+1430,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)
	oPrint:Say  (nRow2+1483,400 ,aDatSacado[3]                                    ,oFont10)
	oPrint:Say  (nRow2+1536,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado

	if aDatSacado[8] = "J"
		oPrint:Say  (nRow2+1589,400 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
	Else
		oPrint:Say  (nRow2+1589,400 ,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
	EndIf

	oPrint:Say  (nRow2+1589,1850,Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4)  ,oFont10)

	oPrint:Say  (nRow2+1605,100 ,"Sacador/Avalista",oFont8)
	oPrint:Say  (nRow2+1645,1500,"Autenticação Mecânica",oFont8)

	oPrint:Line (nRow2+0710,1800,nRow2+1400,1800 )
	oPrint:Line (nRow2+1120,1800,nRow2+1120,2300 )
	oPrint:Line (nRow2+1190,1800,nRow2+1190,2300 )
	oPrint:Line (nRow2+1260,1800,nRow2+1260,2300 )
	oPrint:Line (nRow2+1330,1800,nRow2+1330,2300 )
	oPrint:Line (nRow2+1400,100 ,nRow2+1400,2300 )
	oPrint:Line (nRow2+1640,100 ,nRow2+1640,2300 )

	/******************/
	/* TERCEIRA PARTE */
	/******************/

	nRow3 := 0

	For nI := 100 to 2300 step 50
		oPrint:Line(nRow3+1880, nI, nRow3+1880, nI+30)
	Next nI

	oPrint:Line (nRow3+2000,100,nRow3+2000,2300)
	oPrint:Line (nRow3+2000,500,nRow3+1920, 500)
	oPrint:Line (nRow3+2000,710,nRow3+1920, 710)

	oPrint:SayBitmap(nRow1+1850,100,"logoSant.png",390,230) // Logo do Banco

	oPrint:Say  (nRow3+1925,513,"033-7",oFont21 )	// 	[1]Numero do Banco
	oPrint:Say  (nRow3+1934,755,aCB_RN_NN[2],oFont15n)			//	Linha Digitavel do Codigo de Barras

	oPrint:Line (nRow3+2100,100,nRow3+2100,2300 )
	oPrint:Line (nRow3+2200,100,nRow3+2200,2300 )
	oPrint:Line (nRow3+2270,100,nRow3+2270,2300 )
	oPrint:Line (nRow3+2340,100,nRow3+2340,2300 )

	oPrint:Line (nRow3+2270,750 ,nRow3+2340,750 )
	oPrint:Line (nRow3+2200,1000,nRow3+2340,1000)
	oPrint:Line (nRow3+2200,1300,nRow3+2270,1300)
	oPrint:Line (nRow3+2200,1480,nRow3+2340,1480)

	oPrint:Say  (nRow3+2000,100 ,"Local de Pagamento",oFont8)
	oPrint:Say  (nRow3+2015,400 ,"Qualquer banco até a data do vencimento",oFont10)

	oPrint:Say  (nRow3+2000,1810,"Vencimento",oFont8)
	cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
	nCol	 	 := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow3+2040,nCol,cString,oFont11c)

	oPrint:Say  (nRow3+2100,100 ,"Cedente",oFont8)
	oPrint:Say  (nRow3+2140,100 ,Alltrim(aDadosEmp[1])+" - Av. Antônio Bardela,598 - CNPJ:07.122.447/0001-82",oFont8) //Nome + CNPJ

	oPrint:Say  (nRow3+2100,1810,"Agência/Código Cedente",oFont8)
	cString := Alltrim(aDadosBanco[3]+"-0"+"/"+aDadosBanco[8])
	nCol 	 := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow3+2140,nCol,cString ,oFont11c)

	oPrint:Say  (nRow3+2200,100 ,"Data do Documento"                                ,oFont8)
	oPrint:Say (nRow3+2230,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFont10)

	oPrint:Say  (nRow3+2200,505 ,"Nro.Documento"                                    ,oFont8)
	oPrint:Say  (nRow3+2230,605 ,Alltrim(aDadosTit[7])+Alltrim(SubStr(aDadosTit[1],2,9))    ,oFont10) //Prefixo +Numero+Parcela

	oPrint:Say  (nRow3+2200,1005,"Espécie Doc."                                     ,oFont8)
	oPrint:Say  (nRow3+2230,1050,aDadosTit[8]										,oFont10) //Tipo do Titulo

	oPrint:Say  (nRow3+2200,1305,"Aceite"                                           ,oFont8)
	oPrint:Say  (nRow3+2230,1400,"N"                                                ,oFont10)

	oPrint:Say  (nRow3+2200,1485,"Data do Processamento"                            ,oFont8)
	oPrint:Say  (nRow3+2230,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4)                               ,oFont10) // Data impressao

	oPrint:Say  (nRow3+2200,1810,"Nosso Número"                                     ,oFont8)
	cString := Alltrim(Substr(cNroDoc,1,12)+"-"+Substr(cNroDoc,13,1))
	nCol := 1809+(374-(len(cString)*22))
	oPrint:Say  (nRow3+2230,nCol,cString,oFont11c)

	oPrint:Say  (nRow3+2270,105 ,"Carteira"                                         ,oFont8)
	oPrint:Say  (nRow3+2300,155 ,aDadosBanco[7]+" Cobrança Simples"                  	,oFont10)

	oPrint:Say  (nRow3+2270,755 ,"Espécie"                                          ,oFont8)
	oPrint:Say  (nRow3+2300,805 ,"REAL"                                               ,oFont10)

	oPrint:Say  (nRow3+2270,1005,"Quantidade"                                       ,oFont8)
	oPrint:Say  (nRow3+2270,1485,"Valor"                                            ,oFont8)

	oPrint:Say  (nRow3+2270,1810,"Valor do Documento"                    	      	,oFont8)
	cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
	nCol 	 := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow3+2300,nCol,cString,oFont11c)

	oPrint:Say  (nRow3+2340,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do cedente)",oFont8)

	oPrint:Say  (nRow3+2390,100 ,aBolText[1] ,oFont10)
	
	oPrint:Say  (nRow2+2480,100 ,"APÓS O VENCIMENTO COBRAR MORA DE R$......."+alltrim(transform(((aDadosTit[5]*6)/100),"@E 999,999.99"))       ,oFont10)
	
	oPrint:Say  (nRow3+2340,1810,"(-)Desconto/Abatimento"                         ,oFont8)
	oPrint:Say  (nRow3+2410,1810,"(-)Outras Deduções"                             ,oFont8)
	oPrint:Say  (nRow3+2480,1810,"(+)Mora/Multa"                                  ,oFont8)
	oPrint:Say  (nRow3+2550,1810,"(+)Outros Acréscimos"                           ,oFont8)
	oPrint:Say  (nRow3+2620,1810,"(=)Valor Cobrado"                               ,oFont8)

	oPrint:Say  (nRow3+2690,100 ,"Sacado"                                         ,oFont8)
	oPrint:Say  (nRow3+2700,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)

	if aDatSacado[8] = "J"
		oPrint:Say  (nRow3+2700,1750,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
	Else
		oPrint:Say  (nRow3+2700,1750,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10)	 	// CPF
	EndIf

	oPrint:Say  (nRow3+2753,400 ,aDatSacado[3]                                    ,oFont10)
	oPrint:Say  (nRow3+2806,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado
	oPrint:Say  (nRow3+2806,1750,Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4)  ,oFont10)

	oPrint:Say  (nRow3+2815,100 ,"Sacador/Avalista"                               ,oFont8)
	oPrint:Say  (nRow3+2855,1500,"Autenticação Mecânica - Ficha de Compensação"                        ,oFont8)

	oPrint:Line (nRow3+2000,1800,nRow3+2690,1800 )
	oPrint:Line (nRow3+2410,1800,nRow3+2410,2300 )
	oPrint:Line (nRow3+2480,1800,nRow3+2480,2300 )
	oPrint:Line (nRow3+2550,1800,nRow3+2550,2300 )
	oPrint:Line (nRow3+2620,1800,nRow3+2620,2300 )
	oPrint:Line (nRow3+2690,100 ,nRow3+2690,2300 )

	oPrint:Line (nRow3+2850,100,nRow3+2850,2300  )

	MSBAR("INT25",24.8,1,aCB_RN_NN[1],oPrint,.F.,Nil,Nil,0.025,,Nil,Nil,"A",.F.)

	oPrint:EndPage() // Finaliza a página

Return Nil

/*/{Protheus.doc} FNossoN
Gera o Nosso Numero
@type function Relatorio
@version  1.00
@author S/A - Alterado por mario.antonaccio
@since 21/01/21  - alterado em 20/09/2021
@param cNoss, character, nosso numero
@return Character, nosso numero com digito
/*/
static function FNossoN(cNoss)

	local nCont 	:= 0
	local nPeso 	:= 1
	local cRet		:= ''
	local nResto	:= 0
	local cDig		:= ''
	Local i as number

	For i := 12 To 1 Step -1
		nPeso := nPeso + 1
		nCont := nCont + (Val(SUBSTR(cNoss,i,1))) * nPeso
		If nPeso == 8
			nPeso := 1
		Endif
	Next

	nResto := ( nCont % 11 )

	If nResto == 10
		cDig := '1'
	Elseif nResto == 1 .or. nResto == 0
		cDig := '0'
	else
		cDig := Str(11 - nResto,1)
	EndIf

	//cRet	:= substr(cNoss,3,11) + cDig
	cRet := cNoss + cDig

return cRet

/*/{Protheus.doc} Ret_cBarra
Gera a codificacao da Linha digitavel gerando o codigo de barras.
@type function Processamento
@version  1.0
@author sem autor -  alterado por mario.antonaccio
@since sem data - alterado em 09/09/2021
@param cBanco, character, Codigo do Banco
@param cAgencia, character, Codigo da Agencia
@param cConta, character, Numero da Conta Bancaria
@param cDacCC, character, Digito de Contrle da Conta Corrente
@param cNroDoc, character, Numero Documento
@param nValor, numeric, Valor Documento
@param dVencto, date, Data de Vencimento
@return Array, Array Contendo Codigo de Barra, Linha Digitavel e nosso numero
/*/

Static Function Ret_cBarra(	cPrefixo	,cNumero	,cParcela	,cTipo	,;
		cBanco		,cAgencia	,cConta		,cDacCC	,;
		cNroDoc		,nValor		,cCart		,cMoeda, cCodEmpBco	)

	Local cNosso		:= ""
	Local NNUM			:= ""
	Local cCampoL		:= ""
	Local cFatorValor	:= ""
	Local cLivre		:= ""
	Local cDigBarra		:= ""
	Local cBarra		:= ""
	Local cParte1		:= ""
	Local cDig1			:= ""
	Local cParte2		:= ""
	Local cDig2			:= ""
	Local cParte3		:= ""
	Local cDig3			:= ""
	Local cParte4		:= ""
	Local cParte5		:= ""
	Local cDigital		:= ""
	Local cNro  		:= ""
	Local aRet			:= {}

	cAgencia:=STRZERO(Val(cAgencia),4)

	cNosso := ""
	cNro   := Val(cNroDoc)

	//Nosso Numero com o DV
	NNUM := Alltrim(cNroDoc)

	cCampoL := "9"+cCodEmpBco+NNUm+"0"+cCart

	//campo livre do codigo de barra                   // verificar a conta
	If nValor > 0
		cFatorValor  := u_fator2()+strzero(nValor*100,10)
	Else
		cFatorValor  := u_fator2()+strzero(SE1->E1_VALOR*100,10)
	Endif

	cLivre := cBanco+cMoeda+cFatorValor+cCampoL

	// campo do codigo de barra
	cDigBarra := U_CALC_5S( cLivre )

	cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,40)

	// composicao da linha digitavel
	cParte1  := cBanco+cMoeda+"9"
	cParte1  := cParte1 + Left(cCodEmpBco, 4) //SUBSTR(cCampoL,1,5)
	cDig1    := U_DIGITSan( cParte1 )
	cParte2  := SUBSTR(cCampoL,6,10)
	cDig2    := U_DIGITSan( cParte2 )
	cParte3  := SUBSTR(cCampoL,16,10)
	cDig3    := U_DIGITSan( cParte3 )
	cParte4  := cDigBarra
	cParte5  := cFatorValor

	cDigital := cParte1+"."+cDig1+" "+;
		cParte2+"."+cDig2+" "+;
		cParte3+"."+cDig3+" "+;
		cParte4+" "+;
		cParte5

	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)
	Aadd(aRet,cNosso)

Return aRet

/*/{Protheus.doc} DIGITSan
Para calculo da linha digitavel do Banco do Santander
@type function Processamento
@version  1.00
@author S/A - alterado por mario.antonaccio
@since 21/01/0=21 - alterado em 20/09/2021
@param cVariavel, character, numero apra calculo do digito
@return character, digito calculado
/*/
User Function DIGITSan(cVariavel)

	Local Auxi := 0, sumdig := 0
	cbase  := cVariavel
	lbase  := LEN(cBase)
	umdois := 2
	sumdig := 0
	Auxi   := 0
	iDig   := lbase

	While iDig >= 1
		auxi   := Val(SubStr(cBase, idig, 1)) * umdois
		sumdig := SumDig+If (auxi < 10, auxi, (auxi-9))
		umdois := 3 - umdois
		iDig:=iDig-1
	EndDo

	auxi := Mod(sumdig,10) //pega o resto da divisao por 10

	If auxi != 0
		auxi := 10 - auxi      //e faz a subtração da base conforme manual
	EndIf

Return(str(auxi,1,0))

/*/{Protheus.doc} Fator2
Calculo do FATOR  de vencimento para linha digitavel.
@type function Processamento
@version  1.00
@author S/A - alterado por mario.antonaccio
@since 20/01/2021 - alterado em 20/09/2021
@return character, valor do fator para vencimento
/*/
User function Fator2()
	If Len(ALLTRIM(SUBSTR(DTOC(SE1->E1_VENCTO),7,4))) = 4
		cData := SUBSTR(DTOC(SE1->E1_VENCTO),7,4)+SUBSTR(DTOC(SE1->E1_VENCTO),4,2)+SUBSTR(DTOC(SE1->E1_VENCTO),1,2)
	Else
		cData := "20"+SUBSTR(DTOC(SE1->E1_VENCTO),7,2)+SUBSTR(DTOC(SE1->E1_VENCTO),4,2)+SUBSTR(DTOC(SE1->E1_VENCTO),1,2)
	EndIf
	cFator := STRZERO((STOD(cData)-STOD("19971007")),4)

Return(cFator)

/*/{Protheus.doc} CALC_5S
Calculo do digito do código de barras
@type function Processamento
@version  1.00
@author S/A - alterado por mario.antonaccio
@since 21/01/2021 -  alterado em 20/09/2021
@param cVariavel, character, variavel a qual sera calculado o digito
@return character, digito calculado
/*/
User Function CALC_5S(cVariavel)
	Local Auxi := 0, sumdig := 0

	cbase  := cVariavel
	lbase  := LEN(cBase)
	base   := 2
	sumdig := 0
	Auxi   := 0
	iDig   := lbase
	While iDig >= 1
		If base == 10
			base := 2
		EndIf
		auxi   := Val(SubStr(cBase, idig, 1)) * base
		sumdig := SumDig+auxi
		base   := base + 1
		iDig   := iDig-1
	EndDo
	sumdig := SumDig * 10

	auxi := mod(sumdig,11)

	If auxi == 0 .or. auxi == 1 .or. auxi == 10
		auxi := 1
	EndIf

Return(str(auxi,1,0))

/*/{Protheus.doc} Inverter
Inverte selecao conforme clique do usuario.
@type function  Processamento
@version  1.0
@author sem autor - alterado por mario.antonaccio
@since 02/02/2009 - alterado em  09/09/2021
@param nPos, numeric, Posição dentro do arrya de titulos
@return character, sem retorno
/*/
Static Function Inverter(nPos)
	aVetor[nPos][1] := !aVetor[nPos][1]
	oLbx:Refresh()
Return

/*/{Protheus.doc} Marca
Marca ou desmarca todos os registros.
@type function Processamento
@version  1.00
@author sem autor - alterado por mario.antonaccio
@since 02/02/2009 - alterado em 09/09/2021
@param lMarca, logical, Indica se o registro esta ou nao marcado
@return character, sem retorno
/*/
Static Function Marca(lMarca)
	Local i := 0

	For i := 1 To Len(aVetor)
		aVetor[i][1] := lMarca
	Next i

	oLbx:Refresh()

Return

