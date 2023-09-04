#Include 'Totvs.Ch'
#Include 'TopConn.Ch'


/*/{Protheus.doc} MT681INC
Ponto de Entrada  apontamento de produção PCP Mod2.
@type function Ponto de entrada
@version 1.00
@author mario.antonaccio
@since 21/09/2021
@return character, sem retorno
/*/
User Function MT681INC()

	Local aArea  := GetArea()
	Local cQuery := ""
	Local lFazBx := .F.
	Local aVetor := {}
	Local aEmpen := {}
	Local lUToler:=.F.

	If !(AllTrim( cEmpAnt ) == "08" .Or. (AllTrim( cEmpAnt ) == "10" .And. AllTrim( cFilAnt ) == "0803")) // Tratar somente Qualy por enquanto, a Euro trata PA por quilo e fica díficil automatizar processo...
		Return Nil
	EndIf

	// Caso efetuado apontamento da PI, aplicar ajuste de empenhos referente ao lote para as OPs das PAs
	If SC2->C2_ITEM == "01"

		cQuery := "SELECT * " + CRLF
		cQuery += "FROM " + RetSqlName("SD4") + " AS SD4 WITH (NOLOCK) " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
		cQuery += "  AND B1_COD = D4_COD " + CRLF
		cQuery += "  AND B1_RASTRO <> 'N' " + CRLF
		cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) ON B8_FILIAL = D4_FILIAL " + CRLF
		cQuery += "  AND B8_PRODUTO = D4_COD " + CRLF
		cQuery += "  AND B8_LOCAL = D4_LOCAL " + CRLF
		cQuery += "  AND B8_LOTECTL = LEFT( D4_OP, 6) " + CRLF
		cQuery += "  AND SB8.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "WHERE D4_FILIAL = '" + xFilial("SD4") + "' " + CRLF
		cQuery += "AND D4_OP LIKE '" + SC2->C2_NUM + "%' " + CRLF
		cQuery += "AND SUBSTRING( D4_OP, 7, 2) <> '01' " + CRLF
		cQuery += "AND D4_LOTECTL = B8_LOTECTL " + CRLF
		cQuery += "AND SD4.D_E_L_E_T_ = ' ' " + CRLF

		TCQuery cQuery New Alias "TMPSD4"
		dbSelectArea("TMPSD4")
		dbGoTop()

		Do While !TMPSD4->( Eof() )
			dbSelectArea("SD4")
			dbSetOrder(2) // D4_FILIAL, D4_OP, D4_COD, D4_LOCAL
			If SD4->( dbSeek( xFilial("SD4") + TMPSD4->D4_OP + TMPSD4->D4_COD + TMPSD4->D4_LOCAL ) )
				RecLock("SD4", .F.)
				SD4->D4_QUANT   := TMPSD4->D4_QUANT
				SD4->D4_QTDEORI := TMPSD4->D4_QUANT
				SD4->D4_SLDEMP  := TMPSD4->D4_QUANT
				MsUnLock()
				lMsErroAuto := .F.

				aVetor:={   {"D4_COD"     ,SD4->D4_COD		,Nil},;
					{"D4_LOCAL"   ,SD4->D4_LOCAL	,Nil},;
					{"D4_OP"      ,SD4->D4_OP		,Nil},;
					{"D4_QTDEORI" ,TMPSD4->D4_QUANT ,Nil},;
					{"D4_QUANT"   ,TMPSD4->D4_QUANT ,Nil},;
					{"D4_TRT"     ,SD4->D4_TRT		,Nil}}

				aAdd( aEmpen, { TMPSD4->D4_QUANT, .F.} )

				MSExecAuto({|x,y,z| mata380(x,y,z)},aVetor,4,aEmpen)

				If lMsErroAuto
					//Alert("Erro")
					MostraErro()
				EndIf
			EndIf

			TMPSD4->( dbSkip() )
		EndDo

		TMPSD4->( dbCloseArea() )

		// Verificar se todas as OPs do lote foi finalizado e forçar requisição do resíduo da PI se houve
	Else
		cQuery := "SELECT C2_NUM " + CRLF
		cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
		cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
		cQuery += "AND C2_NUM = '" + SC2->C2_NUM + "' " + CRLF
		cQuery += "AND C2_QUANT > (C2_QUJE + C2_PERDA) " + CRLF
		cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF

		TCQuery cQuery New Alias "TMPSC2"
		dbSelectArea("TMPSC2")
		dbGoTop()

		If TMPSC2->( Eof() )
			lFazBx := .T.
		EndIf

		TMPSC2->( dbCloseArea() )

		If lFazBx
			fExcSlqPI()
		EndIf
	EndIf

	// Validar produto especial - PROJETO : Tratativa de produtos especiais para controlar producao x pedido de vendas
	//Posiciona Pedido
	SC6->(dbSetOrder(2))
	If SC6->(dbSeek(xFilial("SC6")+SD3->D3_COD+SC2->C2_XPEDIDO))

		If SC6->C6_XGRPESP $ GETMV("QE_GRPPRES") // grupo de produtos

			cEmail:=SuperGetMv("QE_MLEPSOP",.F.,"mario.antonaccio@euroamerican.com.br;eulalia.ramos@qualyvinil.com.br;alexandre.gomes@qualyvinil.com.br;ellen.ataide@qualyvinil.com.br")

			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+SC6->C6_PRODUTO))

			// Considera Saldo do produto para Tolerancia = Alex - 2021-09-27
			SB2->(dbSetOrder(1))
			SB2->(dbSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL))

			If (((SB2->B2_QATU / SC6->C6_QTDVEN))-1) * 100 > SuperGetMv("QE_ESPTLR",.F.,10) //Considera somete a quantidade atual ja que a OP ja atualizou estoque
				lUToler:=.T.
				RecLock("SC2",.F.)
				SC2->C2_XBLQESP:="2"
				SC2->C2_XDTESP :=dDataBase
				MsUnLock()
				ALERT("Tolerancia Ultrapassada em "+Str(((SB2->B2_QATU / SC6->C6_QTDVEN)-1) * 100 ,6,2)+"% Verificar !"+CRLF+;
					"Qtde Produzida: "+Str(SD3->D3_QUANT)+CRLF+;
					"Qtde Estoque: "+Str(SB2->B2_QATU-SD3->D3_QUANT)+CRLF+;
					"TOTAL em Estoque: "+Str(SB2->B2_QATU)+CRLF+;
					"Qtde Pedido: "+Str(SC6->C6_QTDVEN))
			End

			//Atualiza Quantidade Produzida no pedido
			RecLock("SC6",.F.)
			SC6->C6_XQTDPRO:=SD3->D3_QUANT
			SC6->C6_QTDLIB:=0
			MsUnlock()

			If ! lUtoler
				//Atualiza Dados da OP senao ultrapassar a tolerancia
				RecLock("SC2",.F.)
				SC2->C2_XBLQESP:="1"
				SC2->C2_XDTESP :=CTOD(" ")
				If SC2->(FieldPos("C2_MSBLQL")) > 0
					SC2->C2_MSBLQL :="2"
				End
				MsUnLock()
			End

			cMensagem:="<h2>Prezados</h2>"
			cMensagem+="<p>A ORDEM DE PRODUCAO (OP) <u> <strong>"+SC2->C2_NUM+"</strong> que possue produto(s) especial(ais):</u></p>"
			cMensagem+="<p>foi <strong> PRODUZIDA  </strong> <strong>em "+DTOC(dDataBase)+"</strong> </p>"
			cMensagem+="<p>"+" "+"</p>"
			cMensagem+='<table border="1" cellpadding="1" cellspacing="1" style="width:500px">'
			cMensagem+="<tbody>"
			cMensagem+="<tr>"
			cMensagem+="	<td>Pedido</td>"
			cMensagem+="	<td>Produto</td>"
			cMensagem+="	<td>Descricao</td>"
			cMensagem+="	<td>Unid Medida</td>"
			cMensagem+="	<td>Qtd Produzida</td>"
			cMensagem+="	<td>Data Prevista</td>"
			cMensagem+="	<td>Produzida em</td>"
			cMensagem+="</tr>"
			cMensagem+="<tr>"
			cMensagem+='	<td style="text-align:center">'+SC2->C2_XPEDIDO+"</td>"
			cMensagem+="    <td>"+SB1->B1_COD+"</td>"
			cMensagem+="	<td>"+RTRIM(SB1->B1_DESC)+"</td>"
			cMensagem+='	<td style="text-align: center;">'+SB1->B1_UM+"</td>"
			cMensagem+='	<td style="text-align: center;">'+Transform(SD3->D3_QUANT,"@E 999,999.9999")+"</td>"
			cMensagem+='	<td style="text-align:center">'+DTOC(SC2->C2_DATPRF)+"</td>"
			cMensagem+='	<td style="text-align:center">'+DTOC(dDataBase)+"</td>"
			cMensagem+="</tr>"
			cMensagem+="</tbody>"
			cMensagem+="</table>"
			cMensagem+="<p>"+" "+"</p>"
			If lUToler

				cMensagem+='<h2 style="text-align: center;"><u><strong>A T E N &Ccedil; &Atilde; O</strong></u></h2>'
				cMensagem+='<h3><strong>Tolerancia&nbsp;Ultrapassada&nbsp;</strong>em <span style="color:#FF0000"><strong>'+Str((SB2->B2_QATU/SC6->C6_QTDVEN)*100,6,2)+' %</strong></span>&nbsp;</h3>'
				cMensagem+='<p>Qtde Produzida:'+Str(SD3->D3_QUANT)+'</p>'
				cMensagem+='<p>Qtde Estoque: ' +Str(SB2->B2_QATU-SD3->D3_QUANT)+'</p>'
				cMensagem+='<p>TOTAL em Estoque:<strong><span style="color:#FF0000">'+Str(SB2->B2_QATU)+'</span></strong></p>'
				cMensagem+='<p>Qtde Pedido: <span style="color:#008000">'+Str(SC6->C6_QTDVEN)+'</span></p>'
				cMensagem+="<p>"+" "+"</p>"
		
			End
			cMensagem+="<p>Atenciosamente</p>"

			//Limpando os registros da SC9  - Se houver
			SC9->(dbSetOrder(3))
			SC9->(dbSeek(xFilial("SC9")+SC2->C2_XPEDIDO+SB1->B1_GRUPO+SB1->B1_COD))
			While SC9->(!EOF()) .and. 	SC9->C9_FILIAL 	==  	xFilial("SC9") .and. ;
					SC9->C9_PEDIDO 	==  	SC2->C2_XPEDIDO .and.;
					SC9->C9_GRUPO 	== 		SB1->B1_GRUPO .and. ;
					SC9->C9_PRODUTO ==  	SB1->B1_COD
				RecLock("SC9",.F.)
				SC9->(dbDelete())
				MsUnLock()
				SC9->(dbSkip())
			End

			U_CPEmail(cEmail," ","Ordem de Producao com Produto Especial - Apontamento OP",cMensagem,"",.F.)

		End
	End

	RestArea( aArea )

Return NIL

/*/{Protheus.doc} fExcSlqPI
verifica lote PI
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 28/09/2021
@return character, sem retorno
/*/
Static Function fExcSlqPI()

	/*
Local nOpc   := 6 //-Opção de execução da rotina, informado nos parâmetros quais as opções possíveis
Local aCabec := {}
Local aItens := {}
Local aLinha := {}

cQuery := "SELECT * " + CRLF
cQuery += "FROM " + RetSqlName("SB8") + " AS SB8 " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
cQuery += "  AND B1_COD = B8_PRODUTO " + CRLF
cQuery += "  AND B1_TIPO = 'PI' " + CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE B8_FILIAL = '" + xFilial("SB8") + "' " + CRLF
cQuery += "AND B8_LOTECTL = '" + SC2->C2_NUM + "' " + CRLF
cQuery += "AND B8_SALDO <> 0 " + CRLF
cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF

TCQuery cQuery New Alias "SB8PI"
dbSelectArea("SB8PI")
SB8PI->( dbGoTop() )

Do While !SB8PI->( Eof() )
	aCabec := {}
	aAdd( aCabec, {'BC_OP'		, SC2->C2_NUM + "01" + "001"	, Nil })
	aAdd( aCabec, {'BC_OPERAC'	, "40"							, Nil })
	aItens := {	{"BC_QUANT"		,SB8PI->B8_SALDO		,NIL},;
				{"BC_PRODUTO"	,SB8PI->B8_PRODUTO		,NIL},;
				{"BC_LOCORIG"	,SB8PI->B8_LOCAL		,NIL},;
				{"BC_TIPO"		,"R"					,NIL},;
				{'BC_DATA'		,dDatabase				,NIL},;
				{"BC_MOTIVO"	,"RB"					,NIL}}
	aAdd( aLinha ,aItens )
	lMSErroAuto := .F.
	MsExecAuto({|x,y,z|MATA685(x,y,z) },aCabec,aLinha,nOpc)

	If lMSErroAuto
		MostraErro()
	Endif

	SB8PI->( dbSkip() )
EndDo

SB8PI->( dbCloseArea() )
	*/
	cQuery := "SELECT * " + CRLF
	cQuery += "FROM " + RetSqlName("SB8") + " AS SB8 " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = B8_PRODUTO " + CRLF
	cQuery += "  AND B1_TIPO = 'PI' " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B8_FILIAL = '" + xFilial("SB8") + "' " + CRLF
	cQuery += "AND B8_LOTECTL = '" + SC2->C2_NUM + "' " + CRLF
	cQuery += "AND B8_SALDO <> 0 " + CRLF
	cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "SB8PI"
	dbSelectArea("SB8PI")
	SB8PI->( dbGoTop() )

	Do While !SB8PI->( Eof() )
		_aCab1      := {}
		_aItem      := {}
		_aTotItem   := {}
		lMsErroAuto := .F.

		_aCab1 := { {"D3_TM"		, "551"					, NIL},;
			{"D3_EMISSAO"	, ddatabase				, NIL}}

		_aItem := { {"D3_COD" 		, SB8PI->B8_PRODUTO		,NIL},;
			{"D3_UM" 		, SB8PI->B1_UM			,NIL},;
			{"D3_QUANT"		, SB8PI->B8_SALDO		,NIL},;
			{"D3_LOCAL"		, SB8PI->B8_LOCAL		,NIL},;
			{"D3_LOTECTL"	, SB8PI->B8_LOTECTL		,NIL}}

		aAdd( _aTotItem, _aitem)

		MSExecAuto({|f,g,h| MATA241(f,g,h)}, _aCab1, _aTotItem, 3)

		If lMsErroAuto
			DisarmTransaction()
		EndIf

		SB8PI->( dbSkip() )
	EndDo

	SB8PI->( dbCloseArea() )

Return
