#Include 'Protheus.Ch'
#Include 'Totvs.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

// Rotina deve gerar saldos nos endereços para os produtos que serão convertidos da Euroamerican
// para controlar endereço igual a SIM, deve ser executada uma única vez e somente irá atualizar 
// caso os itens não estejam controlando endereço. Deve ter cuidado paSra os itens que controlam
// lote e os itens que não controlam e irão ter endereços.

User Function EQSBF0200()

Local cQuery    := ""
Local cNumSeq   := ProxNum()
Local cCounter  := StrZero( 0, TamSx3('DB_ITEM')[1] )
Local cDoc      := "ACE000001"
Local cSerieDoc := "CAR"
Local cEndereco := "ZZ999901"
Local cEspec    := CriaVar("F1_ESPECIE")
Local lBloq     := .F.

// Somente na Euroamerican. Sair se estiver errado...
If AllTrim( cFilAnt ) <> "0200"
	ApMsgAlert( "Empresa e filial indevida para este processamento!", "Atenção" )
	Return
EndIf

// Alterar o parâmetro para controlar endereço na Euroamerican
dbSelectArea("SX6")
dbSetOrder(1)
If SX6->( dbSeek( "02  MV_LOCALIZ" ) )
	RecLock( "SX6", .F.)
		SX6->X6_CONTEUD := "S"
		SX6->X6_CONTSPA := "S"
		SX6->X6_CONTENG := "S"
	MsUnLock()
EndIf

cQuery := "SELECT B2_FILIAL, B2_COD, B2_LOCAL, '' AS B2_LOTE, B2_QATU, B2_QEMP, B1_MSBLQL, B2_QTSEGUM " + CRLF
cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
cQuery += "  AND B1_COD = B2_COD " + CRLF
cQuery += "  AND B1_TIPO = 'PA' " + CRLF
cQuery += "  AND B1_RASTRO = 'N' " + CRLF
cQuery += "  AND B1_LOCALIZ <> 'S' " + CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE B2_FILIAL = '0200' " + CRLF
cQuery += "AND B2_QATU <> 0 " + CRLF
cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "UNION ALL " + CRLF
cQuery += "SELECT B8_FILIAL AS B2_FILIAL, B8_PRODUTO AS B2_COD, B8_LOCAL AS B2_LOCAL, B8_LOTECTL AS B2_LOTE, B8_SALDO AS B2_QATU, B8_EMPENHO AS B2_QEMP, B1_MSBLQL, B8_SALDO2 AS B2_QTSEGUM " + CRLF
cQuery += "FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
cQuery += "  AND B1_COD = B8_PRODUTO " + CRLF
cQuery += "  AND B1_TIPO = 'PA' " + CRLF
cQuery += "  AND B1_RASTRO <> 'N' " + CRLF
cQuery += "  AND B1_LOCALIZ <> 'S' " + CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE B8_FILIAL = '0200' " + CRLF
cQuery += "AND B8_SALDO <> 0 " + CRLF
cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF

TCQuery cQuery New Alias "TMPSB2"
dbSelectArea("TMPSB2")
dbGoTop()

Do While !TMPSB2->( Eof() )
	dbSelectArea("SB1")
	SB1->( dbSetOrder(1) )
	SB1->( dbSeek( xFilial("SB1") + TMPSB2->B2_COD ) )

	// Se o produto estiver bloqueado, deve desbloquear temporariamente para atualizar o saldo
	lBloq := AllTrim( SB1->B1_MSBLQL ) == "1"

	// Tornar o produto posicionado para controlar endereço...
	RecLock( "SB1", .F.)
		SB1->B1_MSBLQL  := "2"
		SB1->B1_LOCALIZ := "S"
	MsUnLock()

	cCounter := Soma1(cCounter)

	// Criar endereço para o local se não existir
	dbSelectArea("SBE")
	dbSetOrder(1) //BE_FILIAL, BE_LOCAL, BE_LOCALIZ, BE_ESTFIS
	If !SBE->( dbSeek( xFilial( "SBE" ) + TMPSB2->B2_LOCAL + Padr( cEndereco, 15) ) )
	     RecLock("SBE", .T.)
	     	SBE->BE_FILIAL  := xFilial("SBE")
	     	SBE->BE_LOCAL   := TMPSB2->B2_LOCAL
	     	SBE->BE_LOCALIZ := cEndereco
	     	SBE->BE_DESCRIC := "SALDO INICIAL EUROAMERICAN"
	     	SBE->BE_PRIOR   := "ZZZ"
	     	SBE->BE_STATUS  := "1"
	     	SBE->BE_DATGER  := STOD("20180101")
	     	SBE->BE_ESTFIS  := Space(6)
	     MsUnLock()
	EndIf

	// Cria registro de movimentacao por Localizacao (SDB)
	CriaSDB(TMPSB2->B2_COD,;	// Produto
			TMPSB2->B2_LOCAL,;	// Armazem
			TMPSB2->B2_QATU,;	// Quantidade
			cEndereco,;			// Localizacao
			"",;				// Numero de Serie
			cDoc,;				// Doc
			cSerieDoc,;			// Serie
			"",;				// Cliente / Fornecedor
			"",;				// Loja
			"",;				// Tipo NF
			"ACE",;				// Origem do Movimento
			dDataBase,;			// Data
			TMPSB2->B2_LOTE,;	// Lote
			"",; 				// Sub-Lote
			cNumSeq,;			// Numero Sequencial
			"499",;				// Tipo do Movimento
			"M",;				// Tipo do Movimento (Distribuicao/Movimento)
			cCounter,;			// Item
			.F.,;				// Flag que indica se e' mov. estorno
			TMPSB2->B2_QEMP,;	// Quantidade empenhado
			TMPSB2->B2_QTSEGUM)	// Quantidade segunda UM

	// Soma saldo em estoque por localizacao fisica (SBF)
	GravaSBF("SDB")

	// Tornar bloqueado novamente se estivesse bloqueado...
	If lBloq
		RecLock( "SB1", .F.)
			SB1->B1_MSBLQL  := "1"
		MsUnLock()
	EndIf

	TMPSB2->( dbSkip() )
EndDo

TMPSB2->( dbCloseArea() )

// Instrução para converter todos os produtos tipo PA da Euroamerican em controle de endereços iguais a Sim, para os que não tinham saldos...
cQuery := "UPDATE " + RetSqlName("SB1") + " SET B1_LOCALIZ = 'S' " + CRLF
cQuery += "FROM " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) " + CRLF
cQuery += "WHERE B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
cQuery += "AND B1_TIPO = 'PA' " + CRLF
cQuery += "AND B1_LOCALIZ <> 'S' " + CRLF
cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("SB2") + " WITH (NOLOCK) WHERE B2_FILIAL = '0200' AND B2_COD = B1_COD AND D_E_L_E_T_ = ' ') " + CRLF
cQuery += "AND SB1.D_E_L_E_T_ = ' ' " + CRLF

TCSqlExec( cQuery )

Return