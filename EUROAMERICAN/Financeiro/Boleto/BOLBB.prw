#Include "Totvs.ch"

/*/{Protheus.doc} BOLBB
Programa respons�vel pela impress�o de boletos do Banco Ita�, grava��o do nosso numero na tabela SE1.
@type function Relatorio
@version 1.0
@author S/A - Alterado por mario.antonaccio
@since 02/10/15 - Alterado em 09/09/2021
@param nNum, numeric, Numero do titulo
@param serie, character, serie do titulo
@param cliente, character, codigo do cliente
@param loja, character, loja do cliente
@param nopc, numeric, numero da op��o
@return character, sem retorno
/*/
User Function BOLBB(nNum,serie,cliente,loja,nopc)

	Local cEdit1	 := Space(25)
	//Local aPergs     := {}
	Local lChk 		 := .F.
	Local lMark      := .F.
	Local oOk        := LoadBitmap( GetResources(), "LBOK" )
	Local oNo        := LoadBitmap( GetResources(), "LBNO" )
	//Local aXy        := {}
	Local oChk       := Nil
	//Local oCheckBox1
	Local oEdit1
	Local _cAlias := GetNextAlias()

	// Variaveis Private
	Private oDBlBRASIL
	Private lExec      := .F.
	Private cIndexName := ""
	Private cIndexKey  := ""
	Private cFilter    := ""
	Private Tamanho    := "M"
	Private titulo     := "Impress�o do Boleto do Brasil"
	Private cDesc1     := "Programa de impressao de boletos para o banco do Brasil."
	Private cDesc2     := ""
	Private cDesc3     := ""
	Private cString    := "SE1"
	Private wnrel      := "BOLBRASIL"
	Private lEnd       := .F.
	Private cPerg      := "CBR009"
	Private aReturn    := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	Private nLastKey   := 0
	Private aVetor     := {}
	Private lImpAut		:= ( Upper(AllTrim(FunName())) $ "MATA460A#SPEDNFE" )

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

Somente Visualiza�ao
Codigo			,"C",03,0,"MV_PAR19"
Agencia			,"C",04,0,"MV_PAR20"
DV Agencia		,"C",01,0,"MV_PAR21"
Nro. Conta		,"C",10,0,"MV_PAR22"
DV Conta		,"C",01,0,"MV_PAR23"
	*/

	Pergunte (cPerg,.F.)
	//Atualizando ultimos registros para a conta SANTANDER
	SetMVValue(cPerg,"MV_PAR19", "001")
	SetMVValue(cPerg,"MV_PAR20", "3355")
	SetMVValue(cPerg,"MV_PAR21", "22000")
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

		aAdd( aVetor, { lMark,;
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

	//� Verifica se existem titulos para impressao.                  �
	If Len( aVetor ) == 0
		ApMsgInfo("N�o existe t�tulos para impress�o de boletos.","Aten��o")
		Return
	Endif

	//� Chamada da Janela de selecao dos titulos para impressao      �
	Define MsDialog oDBlBRASIL Title "Emiss�o de Boletos [Banco do Brasil]" From C(225),C(407) To C(657),C(1061) Pixel

	@ C(049),C(005) TO C(190),C(325) LABEL " T�tulos Selecionados " Pixel Of oDBlBRASIL
	@ C(059),C(010) ListBox oLbx Var cVar Fields HEADER " ",;
		"Raz�o Social",;
		"Prefixo",;
		"Numero",;
		"Parc",;
		"Tipo",;
		"Valor",;
		"Vencimento",;
		"No.Registro" Size C(312),C(123) Of oDBlBRASIL Pixel ;
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

	@ C(200),C(037) MsGet oEdit1 Var cEdit1 Size C(085),C(009) COLOR CLR_BLACK Pixel Of oDBlBRASIL
	@ C(200),C(227) Button "&Confirma"      Size C(037),C(012) Pixel Of oDBlBRASIL Action(MontaRel(aVetor),oDBlBRASIL:End())
	@ C(200),C(274) Button "&Sair"          Size C(037),C(012) Pixel Of oDBlBRASIL Action(oDBlBRASIL:End())
	@ C(201),C(008) Say "Pesquisar"         Size C(025),C(008) COLOR CLR_BLACK Pixel OF oDBlBRASIL
	@ C(201),C(148) CheckBox oChk Var lChk Prompt "Marca/Desmarca" Size C(057),C(008) Pixel Of oDBlBRASIL;
		On CLICK(Iif(lChk,Marca(lChk),Marca(lChk)))

	Activate MsDialog oDBlBRASIL Centered

Return Nil


/*/{Protheus.doc} MontaRel
Montagem e Impressao de boleto Grafico do Banco Itau.
@type function Relatorio
@version  1.00
@author S/A - alterado por mario.antonaccio
@since 02/02/09 - alterado em 20/09/2021
@return Character, Nulo
/*/
Static Function MontaRel(aVetor)
	Local 	oPrint:=TMSPrinter():New( "BOLBRASIL - BOLETO BANCARIO" )
	Local nI as numeric

	oPrint:SetPortrait()
	oPrint:EndPage()

	For nI:=1 To Len(aVetor)

		If  ! aVetor[nI,1]
			Loop
		End

		SE1->(dbGoTo(aVetor[nI,9]))

		lRegistrado := .F.

		If !EMPTY(SE1->E1_IDCNAB)
			MsgAlert("Titulo " + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + " ja transferido para banco, boleto não pode ser gerado até o cancelamento do bordero bancario do titulo." + CRLF + "Favor entrar em contato com o financeiro", "FATR077")
		EndIf
		// não foi gerado IDCNAB mais já foi registrado
		If !EMPTY(SE1->E1_NUMBCO) .And. EMPTY(SE1->E1_IDCNAB)
			If !ApMsgYesNo("Titulo " + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + " ja possui registro bancario. Caso o boleto já enviado para o cliente, nao pode ser gerado. Deseja gerar assim mesmo?", "FATR077")
				lRegistrado := .T.
			Else
				MsgInfo("Numero bancario sera alterado!!!","Atencao")
			EndIf
		EndIf

		If  EMPTY(SE1->E1_IDCNAB) .And. !lRegistrado

			//³ Posiciona arquivos                                                  ³
			//SA6 (Bancos)
			SA6->( DbSetOrder(1) )
			SA6->( DbSeek(xFilial("SA6")+MV_PAR19+MV_PAR20+MV_PAR21) )

			//SEE (Parametros Bancos)
			SEE->( DbSetOrder(1) )
			SEE->( DbSeek(xFilial("SEE")+MV_PAR19+MV_PAR20+MV_PAR21) )

			//SA1 (Cliente)
			SA1->( DbSetOrder(1) )
			SA1->( DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)	 )

			//³ Variaveis                                                           ³
			_Banco			:= RTrim(SA6->A6_COD)
			_NomeBanco		:= RTrim(SA6->A6_NOME)
			_Agencia		:= StrTran(StrTran( Substr(RTrim(SA6->A6_AGENCIA),1, IIf( At("-",RTrim(SA6->A6_AGENCIA)) > 0, At("-",RTrim(SA6->A6_AGENCIA)), Len(SA6->A6_AGENCIA))), "-", ""), ".", "")
			_DvAgencia		:= IIf( Empty(SA6->A6_DVAGE), Modulo11(SA6->A6_DVAGE), RTrim(SA6->A6_DVAGE) )
			_Conta			:= StrTran(StrTran(Substr(RTrim(SA6->A6_NUMCON),1, IIf( At("-",RTrim(SA6->A6_NUMCON)) > 0, At("-",RTrim(SA6->A6_NUMCON)), Len(SA6->A6_NUMCON))), "-", ""), ".", "")
			_DvConta		:= IIf( Empty(SA6->A6_DVCTA), Modulo11(SA6->A6_DVCTA), RTrim(SA6->A6_DVCTA) )
			_Carteira		:= IF(RTrim(SA6->A6_COD)$"001","17","  ")			//RTrim(SEE->EE_CARTEIR)
			_VarCarteira	:= IF(RTrim(SA6->A6_COD)$"001","019","  ")			//RTrim(IIf(!Empty(SEE->EE_VRCARTE), "-" + SEE->EE_VRCARTE, ""))
			_Convenio		:= If(Empty(EE->EE_CODEMP),"2671909", SEE->EE_CODEMP)
			_Convenio		:= StrTran(StrTran(RTrim(_cConvenio), "-", ""), ".", "")

			_LogoBanco	:= "banco_" + _banco + ".jpg"
			_DvBanco	:= Modulo11(_Banco)
			_nVlrAbat	:= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
			_nDiasJur	:= IIf(SE1->E1_VENCREA < dDatabase, DateDiffDay(SE1->E1_VENCREA, dDatabase ), 0)
			_nVlrJur	:= (( 0.06 / 30 )  * SE1->E1_VALOR )
			_nVlrTit	:= SE1->E1_VALOR + ( IIf( _nDiasJur > 0, ( _nDiasJur * _nVlrJur ), 0 ) )
			_Vencimento	:= IIf( (dDatabase > SE1->E1_VENCREA), dDatabase, SE1->E1_VENCREA )

			If Empty(SE1->E1_NUMBCO)
				//BANCO DO BRASIL
				//If Len(RTrim(SE1->E1_NUMBCO)) == 10 .And. RTrim(SA1->A1_IMPBOLE) == "S"	//19/01/17 Alterado opção para gerar somente carteira 17
				U_FINE002()

			EndIf

			_Sequencial	:= SE1->E1_NUMBCO

			//³ Retorna Codigo de Barras / Linha Digitavel / Nosso Numero           ³
			_aCBLDNN	:= fCBLDNN(_Banco,_Agencia,_DvAgencia,_Conta,_DvConta,_Carteira,_nVlrTit,_Vencimento,_Convenio,_Sequencial)
			If Len(_aCBLDNN) < 3
				Break
			EndIf

			//³ Impressao - Inicio                                                  ³
			oPrint:StartPage()

			//³ Recibo de Entrega                                                   ³
			oPrint:SayBitmap(0100,0200,_LogoBanco,400,120 )

			oPrint:Line(0150,0700,0205,0700)
			oPrint:Say(0148,0720,( _Banco + "-" + _DvBanco ),oFont1,100)
			oPrint:Line(0150,0900,0205,0900)

			oPrint:Say(0160,0980,_aCBLDNN[2],oFont2,100)

			oPrint:Box(0210,0200,0290,1500)
			oPrint:Say(0210,0230,"Pagador",oFont3,100)
			oPrint:Say(0240,0230,SA1->A1_NOME,oFont4,100)

			oPrint:box(0210,1500,0290,2200)
			oPrint:Say(0210,1530,"Vencimento",oFont3,100)
			oPrint:Say(0240,2190,DtoC(_Vencimento),oFont4,,,,PAD_RIGHT)

			oPrint:Box(0290,0200,0370,1500)
			oPrint:Say(0290,0230,"Beneficiário",oFont3,100)
			oPrint:Say(0320,0230,( RTrim(SM0->M0_NOMECOM)+ Space(5) + "CPF/CNPJ: " +  Transform(SM0->M0_CGC,"@R 99.999.999/9999-99") ),oFont4,100)

			oPrint:Box(0290,1500,0370,2200)
			oPrint:Say(0290,1530,"Agência / Código Beneficiário",oFont3,100)
			oPrint:Say(0320,2190,( RTrim(_Agencia) + "-" + _DvAgencia + " / " + RTrim(_Conta) + "-" + _DvConta ),oFont4,,,,PAD_RIGHT)

			oPrint:box(0370,0200,0450,0460)
			oPrint:Say(0370,0230,"Data do Documento",oFont3,100)
			oPrint:Say(0400,0230,DtoC(SE1->E1_EMISSAO),oFont4,100)

			oPrint:box(0370,0460,0450,0720)
			oPrint:Say(0370,0490,"Nro Documento",oFont3,100)
			oPrint:Say(0400,0490,( RTrim(SE1->E1_PREFIXO) + " " + SE1->E1_NUM + " " + SE1->E1_PARCELA ),oFont4,100)

			oPrint:box(0370,0720,0450,980)
			oPrint:Say(0370,0750,"Espécie Documento",oFont3,100)
			oPrint:Say(0400,0750,"DM",oFont4,100)

			oPrint:box(0370,0980,0450,1240)
			oPrint:Say(0370,1010,"Aceite",oFont3,100)
			oPrint:Say(0400,1010,"N",oFont4,100)

			oPrint:box(0370,1240,0450,1500)
			oPrint:Say(0370,1270,"Data Processamento",oFont3,100)
			oPrint:Say(0400,1270,DtoC(dDatabase),oFont4,100)

			oPrint:Box(0370,1500,0450,2200)
			oPrint:Say(0370,1530,"Nosso Número",oFont3,100)
			oPrint:Say(0400,2190,_aCBLDNN[3],oFont4,,,,PAD_RIGHT)

			oPrint:box(0450,0200,0530,0460)
			oPrint:Say(0450,0230,"Uso do Banco",oFont3,100)
			oPrint:Say(0480,0230,"",oFont4,100)

			oPrint:box(0450,0460,0530,0720)
			oPrint:Say(0450,0490,"Carteira",oFont3,100)
			oPrint:Say(0480,0490,_Carteira,oFont4,100)

			oPrint:box(0450,0720,0530,980)
			oPrint:Say(0450,0750,"Espécie",oFont3,100)
			oPrint:Say(0480,0750,"R$",oFont4,100)

			oPrint:box(0450,0980,0530,1240)
			oPrint:Say(0450,1010,"Quantidade",oFont3,100)
			oPrint:Say(0480,1010,"",oFont4,100)

			oPrint:box(0450,1240,0530,1500)
			oPrint:Say(0450,1270,"Valor",oFont3,100)
			oPrint:Say(0480,1270,"",oFont4,100)

			oPrint:Box(0450,1500,0530,2200)
			oPrint:Say(0450,1530,"(=) Valor do Documento",oFont3,100)
			oPrint:Say(0480,2190,Transform(_nVlrTit,"@E 999,999,999.99"),oFont4,,,,PAD_RIGHT)

			oPrint:say(600,0200,"NOME DO RECEBEDOR",oFont4,100)
			oPrint:say(600,0800,Replicate("_",45),oFont4,100)
			oPrint:say(680,0200,"ASSINATURA DO RECEBEDOR",oFont4,100)
			oPrint:say(680,0800,Replicate("_",45),oFont4,100)
			oPrint:say(760,0200,"DATA DO RECEBIMENTO",oFont4,100)
			oPrint:say(760,0800,Replicate("_",45),oFont4,100)

			oPrint:Say(760,2100,"Recido de Entrega",oFont2,,,,PAD_RIGHT)

			oPrint:say(0850,0000,Replicate(". ",2000),oFont3,100)

			//³ Recibo do Pagador                                                   ³
			oPrint:SayBitmap(0900,0200,_LogoBanco,400,120 )

			oPrint:Line(0950,0700,1005,0700)
			oPrint:Say(0948,0720,( _Banco + "-" + _DvBanco ),oFont1,100)
			oPrint:Line(0950,0900,1005,0900)

			oPrint:Say(0960,0980,_aCBLDNN[2],oFont2,100)

			oPrint:Box(1010,0200,1090,1500)
			oPrint:Say(1010,0230,"Local de Pagamento",oFont3,100)
			oPrint:Say(1040,0230,"Pagável em qualquer banco até o vencimento",oFont4,,,,PAD_LEFT)

			oPrint:Box(1010,1500,1090,2200)
			oPrint:Say(1010,1530,"Vencimento",oFont3,100)
			oPrint:Say(1040,2190,DtoC(_Vencimento),oFont4,,,,PAD_RIGHT)

			oPrint:Box(1090,0200,1170,1500)
			oPrint:Say(1090,0230,"Beneficiário",oFont3,100)
			oPrint:Say(1120,0230,( RTrim(SM0->M0_NOMECOM)+ Space(5) + "CPF/CNPJ: " +  Transform(SM0->M0_CGC,"@R 99.999.999/9999-99") ),oFont4,,,,PAD_LEFT)

			oPrint:Box(1090,1500,1170,2200)
			oPrint:Say(1090,1530,"Agência / Código Beneficiário",oFont3,100)
			oPrint:Say(1120,2190,( RTrim(_Agencia) + "-" + _DvAgencia + " / " + RTrim(_Conta) + "-" + _DvConta ),oFont4,,,,PAD_RIGHT)

			oPrint:box(1170,0200,1250,0460)
			oPrint:Say(1170,0230,"Data do Documento",oFont3,100)
			oPrint:Say(1200,0230,DtoC(SE1->E1_EMISSAO),oFont4,100)

			oPrint:box(1170,0460,1250,0720)
			oPrint:Say(1170,0490,"Nro Documento",oFont3,100)
			oPrint:Say(1200,0490,( RTrim(SE1->E1_PREFIXO) + " " + SE1->E1_NUM + " " + SE1->E1_PARCELA ),oFont4,100)

			oPrint:box(1170,0720,1250,980)
			oPrint:Say(1170,0750,"Espécie Documento",oFont3,100)
			oPrint:Say(1200,0750,"DM",oFont4,100)

			oPrint:box(1170,0980,1250,1240)
			oPrint:Say(1170,1010,"Aceite",oFont3,100)
			oPrint:Say(1200,1010,"N",oFont4,100)

			oPrint:box(1170,1240,1250,1500)
			oPrint:Say(1170,1270,"Data Processamento",oFont3,100)
			oPrint:Say(1200,1270,DtoC(dDatabase),oFont4,100)

			oPrint:Box(1170,1500,1250,2200)
			oPrint:Say(1170,1530,"Nosso Número",oFont3,100)
			oPrint:Say(1200,2190,_aCBLDNN[3],oFont4,,,,PAD_RIGHT)

			oPrint:box(1250,0200,1330,0460)
			oPrint:Say(1250,0230,"Uso do Banco",oFont3,100)
			oPrint:Say(1280,0230,"",oFont4,100)

			oPrint:box(1250,0460,1330,0720)
			oPrint:Say(1250,0490,"Carteira",oFont3,100)
			oPrint:Say(1280,0490,_Carteira,oFont4,100)

			oPrint:box(1250,0720,1330,980)
			oPrint:Say(1250,0750,"Espécie",oFont3,100)
			oPrint:Say(1280,0750,"R$",oFont4,100)

			oPrint:box(1250,0980,1330,1240)
			oPrint:Say(1250,1010,"Quantidade",oFont3,100)
			oPrint:Say(1280,1010,"",oFont4,100)

			oPrint:box(1250,1240,1330,1500)
			oPrint:Say(1250,1270,"Valor",oFont3,100)
			oPrint:Say(1280,1270,"",oFont4,100)

			oPrint:Box(1250,1500,1330,2200)
			oPrint:Say(1250,1530,"(=) Valor do Documento",oFont3,100)
			oPrint:Say(1280,2190,Transform(_nVlrTit,"@E 999,999,999.99"),oFont4,,,,PAD_RIGHT)

			oPrint:box(1330,0200,1730,1500)
			oPrint:Say(1330,0230,"Instruções ( Texto de exclusiva responsabilidade do cedente/beneficiário )",oFont3,100)
			oPrint:Say(1360,0230,("Cobrar juros de R$ " + AllTrim(Transform(_nVlrJur,"@E 999,999,999.99")) + " por dia de atraso de pagamento após " + DtoC(SE1->E1_VENCREA) ) ,oFont4,100)
			oPrint:Say(1400,0230,("Sujeito a inclusão no Serasa e/ou Protesto após o vencimento"),oFont4,100)

			oPrint:Box(1330,1500,1410,2200)
			oPrint:Say(1330,1530,"(-) Desconto/Abatimento",oFont3,100)
			oPrint:Say(1360,2190,"",oFont4,,,,PAD_RIGHT)

			oPrint:Box(1410,1500,1490,2200)
			oPrint:Say(1410,1530,"(-) Outras Deduções",oFont3,100)
			oPrint:Say(1440,2190,"",oFont4,,,,PAD_RIGHT)

			oPrint:Box(1490,1500,1570,2200)
			oPrint:Say(1490,1530,"(+) Mora/Multa",oFont3,100)
			oPrint:Say(1520,2190,"",oFont4,,,,PAD_RIGHT)

			oPrint:Box(1570,1500,1650,2200)
			oPrint:Say(1570,1530,"(+) Outros Acréscimos",oFont3,100)
			oPrint:Say(1600,2190,"",oFont4,,,,PAD_RIGHT)

			oPrint:Box(1650,1500,1730,2200)
			oPrint:Say(1650,1530,"(=) Valor Cobrado",oFont3,100)
			oPrint:Say(1680,2190,"",oFont4,,,,PAD_RIGHT)

			oPrint:box(1730,0200,1910,2200)
			oPrint:Say(1730,0230,"Pagador:",oFont3,100)
			oPrint:Say(1760,0230,( RTrim(SA1->A1_NOME) + Space(5) + "CPF/CNPJ: " +  IIf(RTrim(SA1->A1_PESSOA)=="J", Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"), Transform(SA1->A1_CGC,"@R 999.999.999-99")) ),oFont4,100)
			oPrint:Say(1795,0230,RTrim(SA1->A1_ENDCOB),oFont4,100)
			oPrint:Say(1830,0230,( RTrim(SA1->A1_MUNC) + " - " + RTrim(SA1->A1_ESTC) + " - " + RTrim(SA1->A1_CEPC)),oFont4,100)	//A1_CEPCOB
			oPrint:Say(1875,0230,"Sacador/Avalista:",oFont3,100)

			oPrint:Say(1850,2100,"Recibo do Pagador",oFont2,,,,PAD_RIGHT)

			oPrint:Say(1915,2200,"Autenticação Mecânica",oFont3,,,,PAD_RIGHT)

			oPrint:say(2000,0000,Replicate(". ",2000),oFont4,100)

			//³ Recibo do Sacado                                                    ³
			oPrint:SayBitmap(2050,0200,_LogoBanco,400,120 )

			oPrint:Line(2100,0700,2155,0700)
			oPrint:Say(2098,0720,( _Banco + "-" + _DvBanco ),oFont1,100)
			oPrint:Line(2100,0900,2155,0900)

			oPrint:Say(2110,0980,_aCBLDNN[2],oFont2,100)

			oPrint:Box(2160,0200,2240,1500)
			oPrint:Say(2160,0230,"Local de Pagamento",oFont3,100)
			oPrint:Say(2190,0230,"Pagavel em qualquer banco até o vencimento",oFont4,,,,PAD_LEFT)

			oPrint:box(2160,1500,2240,2200)
			oPrint:Say(2160,1530,"Vencimento",oFont3,100)
			oPrint:Say(2190,2190,DtoC(_Vencimento),oFont4,,,,PAD_RIGHT)

			oPrint:Box(2240,0200,2320,1500)
			oPrint:Say(2240,0230,"Beneficiário",oFont3,100)
			oPrint:Say(2270,0230,( RTrim(SM0->M0_NOMECOM)+ Space(5) + "CPF/CNPJ: " +  Transform(SM0->M0_CGC,"@R 99.999.999/9999-99") ),oFont4,,,,PAD_LEFT)

			oPrint:Box(2240,1500,2320,2200)
			oPrint:Say(2240,1530,"Agência / Código Beneficiário",oFont3,100)
			oPrint:Say(2270,2190,( RTrim(_Agencia) + "-" + _DvAgencia + " / " + RTrim(_Conta) + "-" + _DvConta ),oFont4,,,,PAD_RIGHT)

			oPrint:box(2320,0200,2400,0460)
			oPrint:Say(2320,0230,"Data do Documento",oFont3,100)
			oPrint:Say(2350,0230,DtoC(SE1->E1_EMISSAO),oFont4,100)

			oPrint:box(2320,0460,2400,0720)
			oPrint:Say(2320,0490,"Nro Documento",oFont3,100)
			oPrint:Say(2350,0490,( RTrim(SE1->E1_PREFIXO) + " " + SE1->E1_NUM + " " + SE1->E1_PARCELA ),oFont4,100)

			oPrint:box(2320,0720,2400,980)
			oPrint:Say(2320,0750,"Espécie Documento",oFont3,100)
			oPrint:Say(2350,0750,"DM",oFont4,100)

			oPrint:box(2320,0980,2400,1240)
			oPrint:Say(2320,1010,"Aceite",oFont3,100)
			oPrint:Say(2350,1010,"N",oFont4,100)

			oPrint:box(2320,1240,2400,1500)
			oPrint:Say(2320,1270,"Data Processamento",oFont3,100)
			oPrint:Say(2350,1270,DtoC(dDatabase),oFont4,100)

			oPrint:Box(2320,1500,2400,2200)
			oPrint:Say(2320,1530,"Nosso Número",oFont3,100)
			oPrint:Say(2350,2190,_aCBLDNN[3],oFont4,,,,PAD_RIGHT)

			oPrint:box(2400,0200,2480,0460)
			oPrint:Say(2400,0230,"Uso do Banco",oFont3,100)
			oPrint:Say(2430,0230,"",oFont4,100)

			oPrint:box(2400,0460,2480,0720)
			oPrint:Say(2400,0490,"Carteira",oFont3,100)
			oPrint:Say(2430,0490,_Carteira,oFont4,100)

			oPrint:box(2400,0720,2480,980)
			oPrint:Say(2400,0750,"Espécie",oFont3,100)
			oPrint:Say(2430,0750,"R$",oFont4,100)

			oPrint:box(2400,0980,2480,1240)
			oPrint:Say(2400,1010,"Quantidade",oFont3,100)
			oPrint:Say(2430,1010,"",oFont4,100)

			oPrint:box(2400,1240,2480,1500)
			oPrint:Say(2400,1270,"Valor",oFont3,100)
			oPrint:Say(2430,1270,"",oFont4,100)

			oPrint:Box(2400,1500,2480,2200)
			oPrint:Say(2400,1530,"(=) Valor do Documento",oFont3,100)
			oPrint:Say(2430,2190,Transform(_nVlrTit,"@E 999,999,999.99"),oFont4,,,,PAD_RIGHT)

			oPrint:box(2480,0200,2880,1500)
			oPrint:Say(2480,0230,"Instruções ( Texto de exclusiva responsabilidade do cedente/beneficiário )",oFont3,100)
			oPrint:Say(2510,0230,("Cobrar juros de R$ " + AllTrim(Transform(_nVlrJur,"@E 999,999,999.99")) + " por dia de atraso de pagamento após " + DtoC(SE1->E1_VENCREA) ) ,oFont4,100)
			oPrint:Say(2550,0230,("Sujeito a inclusão no Serasa e/ou Protesto após o vencimento"),oFont4,100)

			oPrint:Box(2480,1500,2560,2200)
			oPrint:Say(2480,1530,"(-) Desconto/Abatimento",oFont3,100)
			oPrint:Say(2510,2190,"",oFont4,,,,PAD_RIGHT)

			oPrint:Box(2560,1500,2640,2200)
			oPrint:Say(2560,1530,"(-) Outras Deduções",oFont3,100)
			oPrint:Say(2590,2190,"",oFont4,,,,PAD_RIGHT)

			oPrint:Box(2640,1500,2720,2200)
			oPrint:Say(2640,1530,"(+) Mora/Multa",oFont3,100)
			oPrint:Say(2670,2190,"",oFont4,,,,PAD_RIGHT)

			oPrint:Box(2720,1500,2800,2200)
			oPrint:Say(2720,1530,"(+) Outros Acréscimos",oFont3,100)
			oPrint:Say(2750,2190,"",oFont4,,,,PAD_RIGHT)

			oPrint:Box(2800,1500,2880,2200)
			oPrint:Say(2800,1530,"(=) Valor Cobrado",oFont3,100)
			oPrint:Say(2830,2190,"",oFont4,,,,PAD_RIGHT)

			oPrint:box(2880,0200,3050,2200)
			oPrint:Say(2880,0230,"Pagador:",oFont3,100)
			oPrint:Say(2910,0230,( RTrim(SA1->A1_NOME) + Space(5) + "CPF/CNPJ: " +  IIf(RTrim(SA1->A1_PESSOA)=="J", Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"), Transform(SA1->A1_CGC,"@R 999.999.999-99")) ),oFont4,100)
			oPrint:Say(2945,0230,RTrim(SA1->A1_ENDCOB),oFont4,100)
			oPrint:Say(2980,0230,( RTrim(SA1->A1_MUNC) + " - " + RTrim(SA1->A1_ESTC) + " - " + RTrim(SA1->A1_CEPC)),oFont4,100)	//A1_CEPCOB
			oPrint:Say(3015,0230,"Sacador/Avalista:",oFont3,100)

			oPrint:Say(2990,2100,"Ficha de Compensação",oFont2,,,,PAD_RIGHT)

			oPrint:Say(3055,2200,"Autenticação Mecânica",oFont3,,,,PAD_RIGHT)

			MSBAR("INT25",26.5,2.3,_aCBLDNN[1],oPrint,.F.,Nil,Nil,0.0212,1.3,Nil,Nil,"A",.F.)

			//³ Impressao - Termino                                                    ³
			oPrint:EndPage()

		EndIf
	Next

	If .Not. lImpAut
		oPrint:Preview()
	Else
		oPrint:Print()
	EndIf

	Restarea( aAreaSA6 )
	Restarea( aAreaSEE )
	Restarea( aAreaSE1 )
	Restarea( aArea )

Return( Nil )


/*/{Protheus.doc} fCBLDNN
Retorna os strings para inpressão do Boleto
CB = Codigo de barras, LD = Linha digitável, NN = Nosso Numero
@type function Processamento
@version  1.00
@author S/A - mario.antonaccio
@since  S/D - 24/09/2021
@param cBanco, character, Cdoigo Banco
@param cAgencia, character, Codigo Agencia
@param cDacAG, character, Digito Agencia
@param cConta, character, Numero da Conta
@param cDacCC, character, Digito da Conta Corrente
@param cCarteira, character, Codigo Carteira
@param nValor, numeric, Valor do Titulo
@param dVencimento, date, Data Venciemnto
@param cConvenio, character, Codigo Convenio emrpesa
@param cNroSeq, character, Numero sequencial
@return Array, Contendo 3 elemnteos, codigo de barra, Linha digitavel e nosso numero
/*/
Static Function fCBLDNN(cBanco,cAgencia,cDacAG,cConta,cDacCC,cCarteira,nValor,dVencimento,cConvenio,cNroSeq)

	Local aNNCBLD     := {}
	Local cCodBarra   := ""
	Local cCodBarSDig := ""
	Local cFatVenc    := StrZero(dVencimento - CtoD("07/10/1997"),4)
	Local cMoedaPad   := "9" //REAL
	Local cNNum       := ""
	Local cNNumSDig   := ""
	Local cNossoNum   := ""
	Local cValor      := ""
	Local lRet        := .T.

	If Len(RTrim(cConvenio)) == 7

		If Len(RTrim(cNroSeq)) != 10 .Or. Left(cNroSeq,3) != "500"
			MsgStop("Valor do campo E1_NUMBCO deve ter 10 posicoes iniciando com 500.")
			lRet:=.F.
		EndIf

		cNroSeq		:= StrZero(Val(cNroSeq)		,10)
		cBanco		:= StrZero(Val(cBanco)		,03)
		cAgencia	:= StrZero(Val(cAgencia)	,04)
		cConta		:= StrZero(Val(cConta)		,08)
		cCarteira	:= StrZero(Val(cCarteira)	,02)
		cValor		:= StrZero((nValor*100)		,10)
		cConvenio	:= StrZero(Val(cConvenio)	,07)
		cDV_NNum	:= "" // -> Para convenios acima de 1.000.000 nao é necessario calcular DV para o nosso numero

		cNNumSDig	:= cConvenio + cNroSeq
		cNNum		:= cNNumSDig + cDV_NNum
		cNossoNum	:= cNNumSDig

		cCodBarSDig	:= cBanco + cMoedaPad + cFatVenc + cValor + Replicate("0", 6) + cNNumSDig + cCarteira
		cCodBarra	:= cBanco + cMoedaPad + fCodBarDAC(cCodBarSDig) + cFatVenc + cValor + Replicate("0", 6) + cNNumSDig + cCarteira

	Else
		MsgStop("Convenioo de " + cValToChar(Len(cConvenio)) + " posicoes nao implementado no programa BOLBB")
		lRet:=.F.
	EndIf

	If lRet
		//Digito Verificador do Primeiro Campo
		cPrCpo := cBanco + cMoedaPad + SubStr(cCodBarra,20,5)
		cDvPrCpo := AllTrim(Str(fModulo10(cPrCpo)))

		//Digito Verificador do Segundo Campo
		cSgCpo := SubStr(cCodBarra,25,10)
		cDvSgCpo := AllTrim(Str(fModulo10(cSgCpo)))

		//Digito Verificador do Terceiro Campo
		cTrCpo := SubStr(cCodBarra,35,10)
		cDvTrCpo := AllTrim(Str(fModulo10(cTrCpo)))

		//Digito Verificador Geral
		cDvGeral := SubStr(cCodBarra,5,1)

		//Linha Digitavel
		cLindig := SubStr(cPrCpo,1,5) + "." + SubStr(cPrCpo,6,4) + cDvPrCpo + " "	//primeiro campo
		cLinDig += SubStr(cSgCpo,1,5) + "." + SubStr(cSgCpo,6,5) + cDvSgCpo + " "	//segundo campo
		cLinDig += SubStr(cTrCpo,1,5) + "." + SubStr(cTrCpo,6,5) + cDvTrCpo + " "	//terceiro campo
		cLinDig += cDvGeral + " "													//dig verificador geral
		cLinDig += SubStr(cCodBarra,6,4)+SubStr(cCodBarra,10,10)					//fator de vencimento e valor nominal do titulo
		aNNCBLD	:={cCodBarra,cLinDig,cNossoNum}
	End
Return(aNNCBLD)

/*/{Protheus.doc} fModulo10
Calculo Modulo 10
@type function Processamento
@version  1.00
@author S/A - mario.antonaccio
@since S/D - 24/09/2021
@param xNum, character, Numero a ser calaculado o digito
@return character, numero com digito
/*/
Static Function fModulo10( xNum )
	Local cNum    := IIf( Type("xNum") == "N", cValToChar( xNum ), xNum )
	Local nFor    := 0
	Local nTot    := 0
	Local cNumAux

	// Verifico o numero de digitos e impar
	// Caso seja, adiciono um caracter
	If Len(cNum)%2 #0
		cNum := "0"+cNum
	EndIf

	For nFor := 1 To Len(cNum)
		If nFor%2 == 0
			cNumAux := StrZero(2 * Val(SubStr(cNum,nFor,1)), 2)
		Else
			cNumAux := StrZero(Val(SubStr(cNum,nFor,1))    , 2)
		Endif
		nTot += ( Val(LEFT(cNumAux,1)) + Val(Right(cNumAux,1)) )
	Next

	nTot := nTot % 10
	nTot := If( nTot#0, 10-nTot, nTot )

Return nTot

/*/{Protheus.doc} fCodBarDAC
Calculo do digito de controle do codigo de barras
@type function Processamento
@version  1.00
@author S/A - mario.antonaccio
@since S/D - 24/09/2021
@param cCodBarSDig, character, Codigo de barra sem o digito
@return Character, digito de controle do codigo de barra
/*/
Static Function fCodBarDAC( cCodBarSDig )
	Local aArea		:= GetArea()
	Local nCont		:= 0
	Local nPeso		:= 0
	Local nResto	:= 0
	Local cDV_BARRA	:= ""
	Local i			:= 0

	//| Verifica se o tamanho da string eh composta de 43 caracteres        ³
	If Len(cCodBarSDig) != 43
		MsgStop( "O parametro nao compoe uma cadeia de 43 caracteres necessários para o calculo do digito verificador do codigo de barras!", "FINE002DVB")
		Return( "" )
	EndIf

	//| Calcula DAC do codigo de barras                                     ³
	nCont := 0
	nPeso := 2

	For i := 43 To 1 Step -1
		nCont := nCont + ( Val(Substr( cCodBarSDig,i,1 )) * nPeso )
		nPeso := nPeso + 1

		If  nPeso > 9
			nPeso := 2
		EndIf

	Next i

	nResto  := ( nCont % 11 )

	If nResto == 1 .Or. nResto == 0
		cDV_BARRA := "1"
	Else
		nResto		:= (11-nResto)
		cDV_BARRA	:= cValToChar(nResto)
	EndIf

	Restarea( aArea )

Return( cDV_BARRA )


/*/{Protheus.doc} Inverter
Inverte selecao conforme clique do usuario.
@type function  Processamento
@version  1.0
@author sem autor - alterado por mario.antonaccio
@since 02/02/2009 - alterado em  09/09/2021
@param nPos, numeric, Posi��o dentro do arrya de titulos
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
