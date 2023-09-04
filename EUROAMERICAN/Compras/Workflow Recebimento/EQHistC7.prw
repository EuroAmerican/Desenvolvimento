#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'RwMake.Ch'
#Include 'TopConn.Ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa º EQHistC7 º Autor ³ Fabio F. Sousa     º Data ³  25/04/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Efetua consulta dos processos executados no pedido de      º±±
±±º          ³ compras...                                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ Euroamerican...                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function EQHistC7()

Local aArea         := GetArea()

Private oCheck      := LoadBitmap( GetResources(), 'LIQCHECK' )
Private cNumPC      := SC7->C7_NUM
Private aItens      := {}
Private	aItensPC    := {}
Private aTFolder    := {}
Private aAlcada     := {}
Private aNivel      := {}
Private dDataFim    := ""
Private cHoraAtual  := Time()
Private cHoraFim    := ""
Private	cQuery      := ""
Private cTempo      := ""
Private cBmpInc:=cBmpLib:=cBmpPor:=cBmpNF:=cBmpCon:=cBmpCam:= "stopproc.png"
Private cUsrInc:=cUsrLib:=cUsrPor:=cUsrNF:=cUsrCon:=cUsrCam:= ""
Private cHrInc:=cHrLib:=cHrPor:=cHrNF:=cHrCon:=cHrCam:= ""
Private dDtInc:=dDtLib:=dDtPor:=dDtNF:=dDtCon:=dDtCam:= ""
Private oFont14n   := TFont():New( "Courier New",,14,,.T.,,,,,.F. )
Private oFont14	   := TFont():New( "Courier New",,14,,.F.,,,,,.F. )
Private oFontRes3  := TFont():New('Arial'        ,,-18,.T.,,,,,,.F.,.F.)
Private oHoraAtu
Private oTimer
Private oTFolder
Private oBmpInc
Private oUsrInc
Private oDtInc
Private oHrInc
Private oBmpLib
Private oUsrLib
Private oDtLib
Private oHrLib
Private oBmpPor
Private oUsrPor
Private oDtPor
Private oHrPor
Private oBmpNF
Private oUsrNF
Private oDtNF
Private oHrNF
Private oBmpCon
Private oUsrCon
Private oDtCon
Private oHrCon
Private oBmpCam
Private oUsrCam
Private oDtCam
Private oHrCam
Private oRat

If Empty( SC7->C7_EUWFID )
	ApMsgAlert( 'Pedido de Compras sem controle de processo.', 'Atenção')
	Return
EndIf

BeCargaProc(.F.)

DEFINE MSDIALOG oDlg TITLE "Histórico do Pedido: " + Alltrim( SC7->C7_NUM ) FROM 000, 000  TO 506, 865 PIXEL

	aTFolder := {'Histórico do Processo','Dados do Pedido','Status da Aprovação'}
	oTFolder := TFolder():New( 0,0,aTFolder,,oDlg,,,,.T.,,C(340),C(230))
	
	TGroup():New(003,005,097,428,'Fases do Processo',oTFolder:aDialogs[1],,,.T.)
	
	// Fase 100100 - Pedido Incluido
	TSay():New(018,020,{|| ' Pedido'   }				,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_HRED,CLR_HRED)
	TSay():New(025,020,{|| 'Incluído'  }				,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_HRED,CLR_HRED)

	oBmpInc := TBitmap():New(035,022,033,033,,cBmpInc,.T.	,oTFolder:aDialogs[1], {||},,.F.,.F.,,,.F.,,.T.,,.F.)
	oUsrInc := TSay():New(061,012,{|| PadC(Capital(Alltrim(cUsrInc)),15)  }	,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	oDtInc 	:= TSay():New(068,012,{|| PadC(dDtInc,15) }				,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	oHrInc 	:= TSay():New(073,012,{|| PadC(cHrInc,15) }				,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)

	// Fase 200001 - Pedido Liberado
	TSay():New(018,082,{|| ' Pedido' }				,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_HRED,CLR_HRED)
	TSay():New(025,080,{|| 'Aprovado'} 				,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_HRED,CLR_HRED)

	oBmpLib := TBitmap():New(035,082,033,033,,cBmpLib,.T.,oTFolder:aDialogs[1], {||},,.F.,.F.,,,.F.,,.T.,,.F.)
	oUsrLib := TSay():New(061,072,{|| PadC(Capital(Alltrim(cUsrLib)),15)} 	,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	oDtLib 	:= TSay():New(068,072,{|| PadC(dDtLib,15) }				,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	oHrLib 	:= TSay():New(073,072,{|| PadC(cHrLib,15) }				,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)

	// Fase 300001 - Chegada Portaria
	TSay():New(018,142,{|| 'Chegada' }				,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_HRED,CLR_HRED)
	TSay():New(025,140,{|| 'Portaria'}				,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_HRED,CLR_HRED)

	oBmpPor := TBitmap():New(035,142,033,033,,cBmpPor,.T.,oTFolder:aDialogs[1], {||},,.F.,.F.,,,.F.,,.T.,,.F.)
	oUsrPor := TSay():New(061,132,{|| PadC(Capital(Alltrim(cUsrPor)),15)} 	,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	oDtPor 	:= TSay():New(068,132,{|| PadC(dDtPor,15) }				,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	oHrPor 	:= TSay():New(073,132,{|| PadC(cHrPor,15) }				,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)

	// Fase 400001 - Nota Fiscal
	TSay():New(018,202,{|| '  Entrada' }			,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_HRED,CLR_HRED)
	TSay():New(025,200,{|| 'Nota Fiscal'}			,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_HRED,CLR_HRED)

	oBmpNF  := TBitmap():New(035,202,033,033,,cBmpNF,.T.,oTFolder:aDialogs[1], {||},,.F.,.F.,,,.F.,,.T.,,.F.)
	oUsrNF  := TSay():New(061,192,{|| PadC(Capital(Alltrim(cUsrNF)),15)} 	,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	oDtNF  	:= TSay():New(068,192,{|| PadC(dDtNF,15) }				,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	oHrNF  	:= TSay():New(073,192,{|| PadC(cHrNF,15) }				,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)

	// Fase 400200 - Conferência Física
	TSay():New(018,260,{|| 'Conferência'   }						,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_HRED,CLR_HRED)
	TSay():New(025,260,{|| '   Física'  }								,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_HRED,CLR_HRED)

	oBmpCon := TBitmap():New(035,262,033,033,,cBmpCon,.T.,oTFolder:aDialogs[1], {||},,.F.,.F.,,,.F.,,.T.,,.F.)
	oUsrCon := TSay():New(061,252,{|| PadC(Capital(Alltrim(cUsrCon)),15) }	,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	oDtCon 	:= TSay():New(068,252,{|| PadC(dDtCon,15) }				,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	oHrCon 	:= TSay():New(073,252,{|| PadC(cHrCon,15) }				,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)

	// Fase 500001 - Liberação Caminhão
	TSay():New(018,320,{|| 'Liberação' }							,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_HRED,CLR_HRED)
	TSay():New(025,320,{|| ' Caminhão'}								,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_HRED,CLR_HRED)

	oBmpCam := TBitmap():New(035,322,033,033,,cBmpCam,.T.,oTFolder:aDialogs[1], {||},,.F.,.F.,,,.F.,,.T.,,.F.)
	oUsrCam := TSay():New(061,312,{|| PadC(Capital(Alltrim(cUsrCam)),15)} 	,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	oDtCam 	:= TSay():New(068,312,{|| PadC(dDtCam,15) }				,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)
	oHrCam 	:= TSay():New(073,312,{|| PadC(cHrCam,15) }				,oTFolder:aDialogs[1],,oFont14,,,,.T.,CLR_BLACK,CLR_BLACK)

//	oBmpStatus := TBitmap():New(035,382,033,033,,"peleteeuro.png",.T.,oTFolder:aDialogs[1], {||},,.F.,.F.,,,.F.,,.T.,,.F.)

	TGroup():New(100,005,215,428,'Detalhes do Processo',oTFolder:aDialogs[1],,,.T.)

	//oRat := TcBrowse():New(C(85),C(006),C(328),C(77),,,,oTFolder:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)
	oRat  := TcBrowse():New(C(085),C(006),C(328),C(082),,,,oTFolder:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)

	oRat:AddColumn( TcColumn():New("Status"        ,{ || aItens[oRat:nAt,01] }   ,"@!" ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oRat:AddColumn( TcColumn():New("Descrição"     ,{ || aItens[oRat:nAt,02] }   ,"@x" ,,,"LEFT"  , 100,.F.,.F.,,,,.F.,) )
	oRat:AddColumn( TcColumn():New("Data"          ,{ || aItens[oRat:nAt,03] }   ,"@!" ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oRat:AddColumn( TcColumn():New("Hora"          ,{ || aItens[oRat:nAt,04] }   ,"@!" ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oRat:AddColumn( TcColumn():New("Tempo"         ,{ || aItens[oRat:nAt,05] }   ,""   ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oRat:AddColumn( TcColumn():New("Autor"         ,{ || aItens[oRat:nAt,06] }   ,"@x" ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )

	oRat:SetArray( aItens )

	//Folder 2 - Dados do Pedido
	TGroup():New(003,005,058,428,'Cabeçalho Pedido de Compras',oTFolder:aDialogs[2],,,.T.)
    
	TSay():New(014,015,{|| 'Fornecedor: '}				,oTFolder:aDialogs[2],,oFont14n,,,,.T.,,)
	TSay():New(014,065,{|| SC7->C7_FORNECE + " / " + SC7->C7_LOJA + " - " + Alltrim(Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NOME")) }				,oTFolder:aDialogs[2],,oFont14,,,,.T.,,)

	TSay():New(024,015,{|| 'Cond. Pagto.:' }				,oTFolder:aDialogs[2],,oFont14n,,,,.T.,,)
	TSay():New(024,065,{|| SC7->C7_COND + " - " + Substr(Posicione("SE4",1,xFilial("SE4")+SC7->C7_COND,"E4_DESCRI"),1,35) }				,oTFolder:aDialogs[2],,oFont14,,,,.T.,,)
	TSay():New(024,220,{|| 'Tipo:' }				,oTFolder:aDialogs[2],,oFont14n,,,,.T.,,)
	TSay():New(024,260,{|| IIf( SC7->C7_TIPO == 1, "Pedido de Compras", "Autorização de Entrega") }				,oTFolder:aDialogs[2],,oFont14n,,,,.T.,CLR_HRED,CLR_WHITE)

	TSay():New(034,015,{|| 'Contato: '}				,oTFolder:aDialogs[2],,oFont14n,,,,.T.,,)
	TSay():New(034,065,{|| Alltrim(SC7->C7_CONTATO) }				,oTFolder:aDialogs[2],,oFont14,,,,.T.,,)
	TSay():New(034,220,{|| 'Emissão:' }				,oTFolder:aDialogs[2],,oFont14n,,,,.T.,,)
	TSay():New(034,260,{|| DTOC(SC7->C7_EMISSAO) }				,oTFolder:aDialogs[2],,oFont14,,,,.T.,,)

	TSay():New(044,015,{|| 'Moeda: '}				,oTFolder:aDialogs[2],,oFont14n,,,,.T.,,)
	TSay():New(044,065,{|| AllTrim( Str( SC7->C7_MOEDA ) ) + " - " + Alltrim( SuperGetMv( "MV_MOEDA" + AllTrim( Str( SC7->C7_MOEDA, 2) ) ) ) }				,oTFolder:aDialogs[2],,oFont14,,,,.T.,,)
	TSay():New(044,220,{|| 'Taxa Moeda:' }				,oTFolder:aDialogs[2],,oFont14n,,,,.T.,,)
	TSay():New(044,260,{|| Transform( SC7->C7_TXMOEDA, "@E 999,999,999.99999999") }				,oTFolder:aDialogs[2],,oFont14,,,,.T.,,)

	TGroup():New(061,005,215,428,'Itens Pedido de Compras',oTFolder:aDialogs[2],,,.T.)

	dbSelectArea("SC7")
	dbSetOrder(1)
	dbSeek( xFilial("SC7") + cNumPC )
	
	Do While !SC7->( Eof() ) .And. SC7->C7_FILIAL = xFilial("SC7") .And. SC7->C7_NUM == cNumPC
		aAdd( aItensPC, {	SC7->C7_ITEM,;
							SC7->C7_PRODUTO,;
							SC7->C7_DESCRI,;
							SC7->C7_UM,;
							SC7->C7_QUANT,;
							SC7->C7_DATPRF,;
							SC7->C7_DATPRF - SC7->C7_EMISSAO,;
							SC7->C7_DATPRF - MsDate()})

		SC7->( dbSkip() )
    EndDo
    
	dbSelectArea("SC7")
	dbSetOrder(1)
	dbSeek( xFilial("SC7") + cNumPC )

	oRat2 := TcBrowse():New(C(055),C(006),C(328),C(111),,,,oTFolder:aDialogs[2],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)

	oRat2:AddColumn( TcColumn():New("Item"         ,{ || aItensPC[oRat2:nAt,01] }   ,"@!" ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oRat2:AddColumn( TcColumn():New("Produto"      ,{ || aItensPC[oRat2:nAt,02] }   ,"@!" ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oRat2:AddColumn( TcColumn():New("Descrição"    ,{ || aItensPC[oRat2:nAt,03] }   ,"@!" ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oRat2:AddColumn( TcColumn():New("Unidade"      ,{ || aItensPC[oRat2:nAt,04] }   ,"@!" ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oRat2:AddColumn( TcColumn():New("Quantidade"   ,{ || aItensPC[oRat2:nAt,05] }   ,PesqPict("SC7","C7_QUANT")   ,,,"RIGHT"  ,,.F.,.F.,,,,.F.,) )
	oRat2:AddColumn( TcColumn():New("Prev.Entr"    ,{ || aItensPC[oRat2:nAt,06] }   ,""   ,,,"CENTER",,.F.,.F.,,,,.F.,) )
	oRat2:AddColumn( TcColumn():New("Qtd Dias"     ,{ || aItensPC[oRat2:nAt,07] }   ,"@R 999,999"    ,,,"RIGHT"  ,,.F.,.F.,,,,.F.,) )
	oRat2:AddColumn( TcColumn():New("Faltam?"      ,{ || aItensPC[oRat2:nAt,07] }   ,"@R 999,999"    ,,,"RIGHT"  ,,.F.,.F.,,,,.F.,) )

	oRat2:SetArray( aItensPC )
 
	//Folder 3 - Status da Aprovação
	//TGroup():New(003,005,058,428,'Status Atual',oTFolder:aDialogs[3],,,.T.)
	//TGroup():New(061,005,215,428,'Histórico',oTFolder:aDialogs[3],,,.T.)
	TGroup():New(003,005,097,428,'Status da Aprovação Atual',oTFolder:aDialogs[3],,,.T.)

	TGroup():New(100,005,215,428,'Alçada do Pedido de Compras',oTFolder:aDialogs[3],,,.T.)

	cQuery := "SELECT CR_EMISSAO, SAK.AK_NOME APROV, CR_NIVEL, CR_STATUS, CASE WHEN CR_STATUS = '01' THEN 'Nível Bloqueado' ELSE CASE WHEN CR_STATUS = '02' THEN 'Aguardando Liberação' ELSE CASE WHEN CR_STATUS = '03' THEN 'Liberado' ELSE 'Reprovado' END END END AS DESCSTS, CR_DATALIB, APR.AK_NOME LIBERADO, ISNULL(CONVERT(VARCHAR(500),CR_OBS), '') AS OBS " + CRLF
	cQuery += "FROM " + RetSqlName("SCR") + " AS SCR WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SAK") + " AS SAK WITH (NOLOCK) ON SAK.AK_FILIAL = '" + xFilial("SAK") + "' AND SAK.AK_COD = CR_APROV AND SAK.AK_USER = CR_USER AND SAK.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "LEFT JOIN " + RetSqlName("SAK") + " AS APR WITH (NOLOCK) ON APR.AK_FILIAL = '" + xFilial("SAK") + "' AND APR.AK_COD = CR_LIBAPRO AND APR.AK_USER = CR_USERLIB AND APR.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE CR_FILIAL = '" + xFilial("SCR") + "' " + CRLF
	cQuery += "AND CR_TIPO = 'PC' " + CRLF
	cQuery += "AND CR_NUM = '" + SC7->C7_NUM + "' " + CRLF
	cQuery += "AND SCR.D_E_L_E_T_ = ' '  " + CRLF
	cQuery += "ORDER BY CR_NIVEL, SAK.AK_NOME  " + CRLF

	TCQuery cQuery New Alias "TMPSCR"
	dbSelectArea("TMPSCR")
	dbGoTop()

	Do While !TMPSCR->( Eof() )
		aAdd( aAlcada, { STOD(TMPSCR->CR_EMISSAO),;
		                 TMPSCR->APROV,;
		                 TMPSCR->CR_NIVEL,;
		                 TMPSCR->CR_STATUS,;
		                 TMPSCR->DESCSTS,;
		                 STOD(TMPSCR->CR_DATALIB),;
		                 TMPSCR->LIBERADO,;
		                 TMPSCR->OBS })

		TMPSCR->( dbSkip() )
	EndDo

	TMPSCR->( dbCloseArea() )

	If Len( aAlcada ) == 0
		aAdd( aAlcada, { dDataBase,;
		                 "",;
		                 "",;
		                 "",;
		                 "",;
		                 dDataBase,;
		                 "",;
		                 "" })
	EndIf

	oRat3 := TcBrowse():New(C(085),C(006),C(328),C(082),,,,oTFolder:aDialogs[3],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)

	oRat3:AddColumn( TcColumn():New("Emissão"       ,{ || aAlcada[oRat3:nAt,01] }   ,""   ,,,"CENTER",,.F.,.F.,,,,.F.,) )
	oRat3:AddColumn( TcColumn():New("Aprovador"     ,{ || aAlcada[oRat3:nAt,02] }   ,"@x" ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oRat3:AddColumn( TcColumn():New("Nível"         ,{ || aAlcada[oRat3:nAt,03] }   ,"@!" ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oRat3:AddColumn( TcColumn():New("Status"        ,{ || aAlcada[oRat3:nAt,04] }   ,"@!" ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oRat3:AddColumn( TcColumn():New("Descrição"     ,{ || aAlcada[oRat3:nAt,05] }   ,""   ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oRat3:AddColumn( TcColumn():New("Dt. Liberação" ,{ || aAlcada[oRat3:nAt,06] }   ,""   ,,,"CENTER",,.F.,.F.,,,,.F.,) )
	oRat3:AddColumn( TcColumn():New("Aprovador Por" ,{ || aAlcada[oRat3:nAt,07] }   ,"@x" ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oRat3:AddColumn( TcColumn():New("Observação"    ,{ || aAlcada[oRat3:nAt,08] }   ,"@x" ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )

	oRat3:SetArray( aAlcada )

	TSay():New(014,015,{|| 'Status: '}				,oTFolder:aDialogs[3],,oFont14n,,,,.T.,,)
	If AllTrim(SC7->C7_CONAPRO) == "B"
		TSay():New(014,065,{|| "Bloqueado" }				,oTFolder:aDialogs[3],,oFont14 ,,,,.T.,CLR_HRED,CLR_WHITE)
	Else
		TSay():New(014,065,{|| "Liberado"  }				,oTFolder:aDialogs[3],,oFont14 ,,,,.T.,CLR_GREEN,CLR_WHITE)
	EndIf
	TSay():New(014,220,{|| 'Pedido:' }				,oTFolder:aDialogs[3],,oFont14n,,,,.T.,,)
	If Empty(SC7->C7_ENCER)
		TSay():New(014,260,{|| "Em Aberto / Pendente" }				,oTFolder:aDialogs[3],,oFont14,,,,.T.,CLR_HBLUE,CLR_WHITE)
	Else
		TSay():New(014,260,{|| "Encerrado"            }				,oTFolder:aDialogs[3],,oFont14,,,,.T.,CLR_RED,CLR_WHITE)
	EndIf

	If !Empty( SC7->C7_APROV )
		dbSelectArea("SAL")
		dbSetOrder(1)
		If SAL->( dbSeek( xFilial("SAL")+SC7->C7_APROV ) )
			TSay():New(024,015,{|| 'Grupo Aprov:' }				,oTFolder:aDialogs[3],,oFont14n,,,,.T.,,)
			TSay():New(024,065,{|| AllTrim(SC7->C7_APROV) + " - " + Alltrim( SAL->AL_DESC) }				,oTFolder:aDialogs[3],,oFont14,,,,.T.,,)
		Else
			TSay():New(024,015,{|| 'Grupo Aprov:' }				,oTFolder:aDialogs[3],,oFont14n,,,,.T.,,)
			TSay():New(024,065,{|| "" }				,oTFolder:aDialogs[3],,oFont14,,,,.T.,,)
		EndIf
	Else
		TSay():New(024,015,{|| 'Grupo Aprov:' }				,oTFolder:aDialogs[3],,oFont14n,,,,.T.,,)
		TSay():New(024,065,{|| "" }				,oTFolder:aDialogs[3],,oFont14,,,,.T.,,)
	EndIf
	TSay():New(024,220,{|| 'Comprador:' }				,oTFolder:aDialogs[3],,oFont14n,,,,.T.,,)
	TSay():New(024,260,{|| AllTrim(UsrRetName( SC7->C7_USER )) + " Grupo: " + AllTrim(SC7->C7_GRUPCOM) }				,oTFolder:aDialogs[3],,oFont14,,,,.T.,,)

	cQuery := "SELECT AK_NOME, AL_PERFIL, DHL_DESCRI, " + CRLF
	cQuery += "CASE WHEN AL_LIBAPR = 'A' THEN 'Aprovador' ELSE 'Visto' END AS TIPOAPROV, " + CRLF
	cQuery += "CASE WHEN AL_TPLIBER = 'U' THEN 'Usuário' ELSE CASE WHEN AL_TPLIBER = 'N' THEN 'Nível' ELSE 'Documento' END END AS TIPOLIB, " + CRLF
	cQuery += "DHL_LIMMIN, DHL_LIMMAX, DHL_LIMITE, DHL_MOEDA, " + CRLF
	cQuery += "CASE WHEN DHL_TIPO = 'D' THEN 'Diário' ELSE CASE WHEN DHL_TIPO = 'M' THEN 'Mensal' ELSE 'Semanal' END END AS TIPOPERF " + CRLF
	cQuery += "FROM " + RetSqlName("SAL") + " AS SAL WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("DHL") + " AS DHL WITH (NOLOCK) ON DHL_FILIAL = '" + xFilial("DHL") + "' " + CRLF
	cQuery += "  AND DHL_COD = AL_PERFIL " + CRLF
	cQuery += "  AND DHL.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SAK") + " AS SAK WITH (NOLOCK) ON AK_FILIAL = '" + xFilial("SAK") + "' " + CRLF
	cQuery += "  AND AK_COD = AL_APROV " + CRLF
	cQuery += "  AND AK_USER = AL_USER " + CRLF
	cQuery += "  AND SAK.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE AL_FILIAL = '" + xFilial("SAL") + "' " + CRLF
	cQuery += "AND AL_COD = '" + SC7->C7_APROV + "' " + CRLF
	cQuery += "AND SAL.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPNIV"
	dbSelectArea("TMPNIV")
	dbGoTop()

	Do While !TMPNIV->( Eof() )
		aAdd( aNivel,  { AllTrim( TMPNIV->AK_NOME ),;
		                 AllTrim( TMPNIV->AL_PERFIL ),;
		                 AllTrim( TMPNIV->DHL_DESCRI ),;
		                 AllTrim( TMPNIV->TIPOAPROV ),;
		                 AllTrim( TMPNIV->TIPOLIB ),;
		                 TMPNIV->DHL_LIMMIN,;
		                 TMPNIV->DHL_LIMMAX,;
		                 TMPNIV->DHL_LIMITE,;
		                 TMPNIV->DHL_MOEDA,;
		                 AllTrim( TMPNIV->TIPOPERF )})

		TMPNIV->( dbSkip() )
	EndDo

	TMPNIV->( dbCloseArea() )

	If Len( aNivel ) == 0
		aAdd( aNivel,  { "",;
		                 "",;
		                 "",;
		                 "",;
		                 "",;
		                 "",;
		                 "",;
		                 "",;
		                 "",;
		                 ""})
	EndIf

	TBitmap():New(031,015,30,30, 'LIQCHECK',,.T.,oTFolder:aDialogs[3],,,,,,,,,.T. )
	TSay():New(034,033,{||'Critérios Geração de Alçada'},oTFolder:aDialogs[3],,oFont14n,,,,.T.,CLR_RED,CLR_WHITE,600,20)

	oRat4 := TcBrowse():New(C(034),C(006),C(328),C(041),,,,oTFolder:aDialogs[3],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)

	oRat4:AddColumn( TcColumn():New("Aprovador"       ,{ || aNivel[oRat4:nAt,01] }   ,""               ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oRat4:AddColumn( TcColumn():New("Perfil"          ,{ || aNivel[oRat4:nAt,02] }   ,""               ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oRat4:AddColumn( TcColumn():New("Descrição"       ,{ || aNivel[oRat4:nAt,03] }   ,""               ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oRat4:AddColumn( TcColumn():New("Tp. Aprov"       ,{ || aNivel[oRat4:nAt,04] }   ,""               ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oRat4:AddColumn( TcColumn():New("Tp. Lib"         ,{ || aNivel[oRat4:nAt,05] }   ,""               ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oRat4:AddColumn( TcColumn():New("Limite Min."     ,{ || aNivel[oRat4:nAt,06] }   ,"@R 999,999,999.99",,,"CENTER",,.F.,.F.,,,,.F.,) )
	oRat4:AddColumn( TcColumn():New("Limite Máx."     ,{ || aNivel[oRat4:nAt,07] }   ,"@R 999,999,999.99",,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oRat4:AddColumn( TcColumn():New("Limite"          ,{ || aNivel[oRat4:nAt,08] }   ,"@R 999,999,999.99",,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
	oRat4:AddColumn( TcColumn():New("Moeda"           ,{ || aNivel[oRat4:nAt,09] }   ,"@E 9"           ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )

	oRat4:SetArray( aNivel )

	oTimer := TTimer():New(1000, {|| BeCargaProc(.T.)  }, oDlg )
	oTimer:Activate()

	@ 238, 400 Button "Sair"       Size 28, 10 Action ( lConfirma := .F., oDlg:End() )

ACTIVATE MSDIALOG oDlg CENTERED

RestArea( aArea )

Return

Static Function BeCargaProc(lRefresh)

cHoraAtual  := Time()
dDataFim	:= ""

cQuery := "SELECT * FROM " + RetSqlName("WF3") + " AS WF3 WITH (NOLOCK) " + CRLF
cQuery += "WHERE WF3_FILIAL = '" + SC7->C7_FILIAL + "' " + CRLF
cQuery += "AND WF3_PROC = '" + AllTrim( GetMv("MV_EQ_PRWF",, "190001") ) + "' " + CRLF
cQuery += "AND WF3_ID LIKE '" + Substr( SC7->C7_EUWFID, 1, 8) + "%' " + CRLF
cQuery += "AND WF3_USU <> '' " + CRLF
cQuery += "AND WF3.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "ORDER BY WF3.R_E_C_N_O_ " + CRLF

TCQuery cQuery New Alias "TMPWF3"

TCSetField(("TMPWF3"),"WF3_DATA","D")

dbSelectArea("TMPWF3")
TMPWF3->( dbGoTop() )

aItens 	:= {}   
cTempo	:= "0000 00:00:00"

Do While !TMPWF3->( Eof() )
	
	nLen := Len(aItens)
	If nLen > 0
		cTempo := DWElapTime(CtOD(aItens[nLen][03]),aItens[nLen][04],TMPWF3->WF3_DATA,TMPWF3->WF3_HORA) 
	EndIf	

	aAdd( aItens, { AllTrim( TMPWF3->WF3_STATUS ) ,;
					AllTrim( Capital(TMPWF3->WF3_DESC)),;
					AllTrim( DtoC(TMPWF3->WF3_DATA) ),;
					AllTrim( TMPWF3->WF3_HORA ),;
					Alltrim( cTempo ),;
					AllTrim( TMPWF3->WF3_USU )})

	Do Case 
		Case TMPWF3->WF3_STATUS == '100001' // Pedido Incluído
  			cBmpInc	:= "approve.png"
			cUsrInc	:= TMPWF3->WF3_USU
			cHrInc	:= TMPWF3->WF3_HORA
			dDtInc	:= DtoC(TMPWF3->WF3_DATA)

		Case TMPWF3->WF3_STATUS == '100200' // Aguardando Aprovação
  			cBmpLib	:= "waiting.png"
			cUsrLib	:= ""
			cHrLib	:= DWElapTime(TMPWF3->WF3_DATA,TMPWF3->WF3_HORA,Date(),Time()) 
			dDtLib	:= ""

		Case TMPWF3->WF3_STATUS == '200001' // Aprovação Pedido
  			cBmpLib	:= "approve.png"
			cUsrLib	:= TMPWF3->WF3_USU
			cHrLib	:= TMPWF3->WF3_HORA
			dDtLib	:= DtoC(TMPWF3->WF3_DATA)
	
		Case TMPWF3->WF3_STATUS == '200200' // Aguardando Chegada Mercadoria
  			cBmpPor	:= "waiting.png"
			cUsrPor	:= ""
			cHrPor	:= DWElapTime(TMPWF3->WF3_DATA,TMPWF3->WF3_HORA,Date(),Time())
			dDtPor	:= ""

		Case TMPWF3->WF3_STATUS == '200901' // Aprovação Estornada
  			cBmpEst	:= "stopproc.png"
			cUsrEst	:= ""
			cHrEst	:= ""
			dDtEst	:= ""

			cBmpPor	:= "stopproc.png"
			cHrPor	:= ""

		Case TMPWF3->WF3_STATUS == '300001' // Chegada Portaria
  			cBmpPor	:= "approve.png"
			cUsrPor	:= TMPWF3->WF3_USU
			cHrPor	:= TMPWF3->WF3_HORA
			dDtPor	:= DtoC(TMPWF3->WF3_DATA)

		Case TMPWF3->WF3_STATUS == '300200' // Pesagem Recebimento
  			cBmpNF  := "waiting.png"
			cUsrNF  := ""
			cHrNF   := DWElapTime(TMPWF3->WF3_DATA,TMPWF3->WF3_HORA,Date(),Time() )
			dDtNF   := ""

		Case TMPWF3->WF3_STATUS == '300901' // Recebimento Recusado
  			cBmpPor	:= "stopproc.png"
			cUsrPor	:= ""
			cHrPor	:= ""
			dDtPor	:= ""

			cBmpNF  := "stopproc.png"
			cHrNF   := ""

		Case TMPWF3->WF3_STATUS == '400001' // Entrada Nota Fiscal
  			cBmpNF  := "approve.png"
			cUsrNF  := TMPWF3->WF3_USU
			cHrNF   := TMPWF3->WF3_HORA
			dDtNF   := DtoC(TMPWF3->WF3_DATA)

  			cBmpCon	:= "waiting.png"
			cUsrCon	:= ""
			cHrCon	:= DWElapTime(TMPWF3->WF3_DATA,TMPWF3->WF3_HORA,Date(),Time())
			dDtCon	:= ""

		Case TMPWF3->WF3_STATUS == '400200' // Conferência Física
  			cBmpCon	:= "approve.png"
			cUsrCon	:= TMPWF3->WF3_USU
			cHrCon	:= TMPWF3->WF3_HORA
			dDtCon	:= DtoC(TMPWF3->WF3_DATA)

  			cBmpCam	:= "waiting.png"
			cUsrCam	:= ""
			cHrCam	:= DWElapTime(TMPWF3->WF3_DATA,TMPWF3->WF3_HORA,Date(),Time())
			dDtCam	:= ""

		Case TMPWF3->WF3_STATUS == '400901' // Exclusão Nota Fiscal
  			cBmpNF	:= "stopproc.png"
			cUsrNF	:= ""
			cHrNF	:= ""
			dDtNF	:= ""
            
			cBmpCon	:= "stopproc.png"
			cHrCon	:= ""

		Case TMPWF3->WF3_STATUS == '500001' // Liberação Caminhão
  			cBmpCam	:= "approve.png"
			cUsrCam	:= TMPWF3->WF3_USU
			cHrCam	:= TMPWF3->WF3_HORA
			dDtCam	:= DtoC(TMPWF3->WF3_DATA)

		Case TMPWF3->WF3_STATUS == '500901' // Liberação Caminhão Estornada
  			cBmpCam	:= "stopproc.png"
			cUsrCam	:= ""
			cHrCam	:= ""
			dDtCam	:= ""
	EndCase
	
	TMPWF3->( dbSkip() )
EndDo

If Len( aItens ) == 0
	aAdd( aItens, { "",;
					"",;
					"",;
					"",;
					"",;
					""})
EndIf

TMPWF3->( dbCloseArea() )

aSort(aItens,,, {|x,y| DtoS(CtoD(x[3]))+x[4] > DtoS(CtoD(y[3]))+y[4] })       

If lRefresh
	oTFolder:Refresh()
	oDlg:Refresh()
	oHrInc:Refresh()
	oHrLib:Refresh()
	oHrPor:Refresh()
	oHrNF:Refresh()
	oHrCon:Refresh()
	oHrCam:Refresh()

	oRat:SetArray( aItens )
	oRat:DrawSelect()
	oRat:Refresh()
EndIf

Return

	/*
	TBitmap():New(013,003,033,033, 'CONTAINR',,.T.,oTFolder:aDialogs[3],,,,,,,,,.T. )
	TBitmap():New(013,053,30,30, 'BMPTRG',,.T.,oTFolder:aDialogs[3],,,,,,,,,.T. )
	TBitmap():New(013,103,30,30, 'CARGA',,.T.,oTFolder:aDialogs[3],,,,,,,,,.T. )
	TBitmap():New(013,153,30,30, 'S4WB009N',,.T.,oTFolder:aDialogs[3],,,,,,,,,.T. )
	TBitmap():New(033,003,30,30, 'GLOBO',,.T.,oTFolder:aDialogs[3],,,,,,,,,.T. )
	TBitmap():New(033,053,30,30, 'BMPGROUP',,.T.,oTFolder:aDialogs[3],,,,,,,,,.T. )
	TBitmap():New(033,103,30,30, 'S4WB016N',,.T.,oTFolder:aDialogs[3],,,,,,,,,.T. )
	TBitmap():New(033,153,30,30, 'NOTE'    ,,.T.,oTFolder:aDialogs[3],,,,,,,,,.T. )
	TBitmap():New(083,003,30,30, 'LIQCHECK',,.T.,oTFolder:aDialogs[3],,,,,,,,,.T. )
	TBitmap():New(083,053,30,30, 'SDUPROP' ,,.T.,oTFolder:aDialogs[3],,,,,,,,,.T. )
	TBitmap():New(083,103,30,30, 'FOLDER6' ,,.T.,oTFolder:aDialogs[3],,,,,,,,,.T. )
	TBitmap():New(083,153,30,30, 'S4WB011N',,.T.,oTFolder:aDialogs[3],,,,,,,,,.T. )
	TBitmap():New(103,003,30,30, 'RELOAD'  ,,.T.,oTFolder:aDialogs[3],,,,,,,,,.T. )
	TBitmap():New(103,103,30,30, 'S4WB008N',,.T.,oTFolder:aDialogs[3],,,,,,,,,.T. )
	TBitmap():New(103,153,30,30, 'BMPUSER' ,,.T.,oTFolder:aDialogs[3],,,,,,,,,.T. )
	*/