#INCLUDE "protheus.ch"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} UPDCREV

Função de update de dicionários para compatibilização

@author UPDATE gerado automaticamente
@since  02/10/22
@obs    Gerado por EXPORDIC - V.7.5.2.2 EFS / Upd. V.5.3.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPDCREV( cEmpAmb, cFilAmb )
Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
Local   cDesc3    := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça"
Local   cDesc4    := "um BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para"
Local   cDesc5    := "que caso ocorram eventuais falhas, esse backup possa ser restaurado."
Local   cDesc6    := ""
Local   cDesc7    := ""
Local   cMsg      := ""
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	FormBatch(  cTitulo,  aSay,  aButton )
EndIf

If lOk

	If GetVersao(.F.) < "12" .OR. ( FindFunction( "MPDicInDB" ) .AND. !MPDicInDB() )
		cMsg := "Este update NÃO PODE ser executado neste Ambiente." + CRLF + CRLF + ;
				"Os arquivos de dicionários se encontram em formato ISAM" + " (" + GetDbExtension() + ") " + "Os arquivos de dicionários se encontram em formato ISAM" + " " + ;
				"para atualizar apenas ambientes com dicionários no Banco de Dados."

		If lAuto
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( cMsg )
			ConOut( DToC(Date()) + "|" + Time() + cMsg )
		Else
			MsgInfo( cMsg )
		EndIf

		Return NIL
	EndIf

	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else
		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( "Atualização realizada.", "UPDCREV" )
				Else
					MsgStop( "Atualização não realizada.", "UPDCREV" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "Atualização realizada." )
				Else
					Final( "Atualização não realizada." )
				EndIf
			EndIf

		Else
			Final( "Atualização não realizada." )

		EndIf

	Else
		Final( "Atualização não realizada." )

	EndIf

EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc

Função de processamento da gravação dos arquivos

@author UPDATE gerado automaticamente
@since  02/10/22
@obs    Gerado por EXPORDIC - V.7.5.2.2 EFS / Upd. V.5.3.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// Só adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( "Atualização da empresa " + aRecnoSM0[nI][2] + " não efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( " Dados Ambiente" )
			AutoGrLog( " --------------------" )
			AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
			AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
			AutoGrLog( " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time() )
			AutoGrLog( " Environment........: " + GetEnvServer()  )
			AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
			AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
			AutoGrLog( " Versão.............: " + GetVersao(.T.) )
			AutoGrLog( " Usuário TOTVS .....: " + __cUserId + " " +  cUserName )
			AutoGrLog( " Computer Name......: " + GetComputerName() )

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( " Dados Thread" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Usuário da Rede....: " + aInfo[nPos][1] )
				AutoGrLog( " Estação............: " + aInfo[nPos][2] )
				AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
				AutoGrLog( " Environment........: " + aInfo[nPos][6] )
				AutoGrLog( " Conexão............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )

			If !lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )
			EndIf

			oProcess:SetRegua1( 8 )

			//------------------------------------
			// Atualiza o dicionário SX2
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de arquivos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX2()

			//------------------------------------
			// Atualiza o dicionário SX3
			//------------------------------------
			FSAtuSX3()

			//------------------------------------
			// Atualiza o dicionário SIX
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de índices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSIX()

			oProcess:IncRegua1( "Dicionário de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/índices" )

			// Alteração física dos arquivos
			__SetX31Mode( .F. )

			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf

			For nX := 1 To Len( aArqUpd )

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf

				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nX] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( "Ocorreu um erro desconhecido durante a atualização da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicionário e da tabela.", "ATENÇÃO" )
					AutoGrLog( "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] )
				EndIf

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf

			Next nX

			//------------------------------------
			// Atualiza o dicionário SX6
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de parâmetros" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX6()

			//------------------------------------
			// Atualiza o dicionário SX7
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de gatilhos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX7()

			//------------------------------------
			// Atualiza o dicionário SXB
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de consultas padrão" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSXB()

			//------------------------------------
			// Atualiza os helps
			//------------------------------------
			oProcess:IncRegua1( "Helps de Campo" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuHlp()

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
			AutoGrLog( Replicate( "-", 128 ) )

			RpcClearEnv()

		Next nI

		If !lAuto

			cTexto := LeLog()

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualização concluida." From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX2

Função de processamento da gravação do SX2 - Arquivos

@author UPDATE gerado automaticamente
@since  02/10/22
@obs    Gerado por EXPORDIC - V.7.5.2.2 EFS / Upd. V.5.3.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX2()
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ""
Local cCpoUpd   := "X2_ROTINA /X2_UNICO  /X2_DISPLAY/X2_SYSOBJ /X2_USROBJ /X2_POSLGT /"
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SX2" + CRLF )

aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"   , "X2_NOMESPA", "X2_NOMEENG", "X2_MODO"   , ;
             "X2_TTS"    , "X2_ROTINA" , "X2_PYME"   , "X2_UNICO"  , "X2_DISPLAY", "X2_SYSOBJ" , "X2_USROBJ" , ;
             "X2_POSLGT" , "X2_CLOB"   , "X2_AUTREC" , "X2_MODOEMP", "X2_MODOUN" , "X2_MODULO" }


dbSelectArea( "SX2" )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )

//
// Tabela PAA
//
aAdd( aSX2, { ;
	'PAA'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'PAA'+cEmpr																, ; //X2_ARQUIVO
	'Regras de Comissão Qualy'												, ; //X2_NOME
	'Regras de Comissão Qualy'												, ; //X2_NOMESPA
	'Regras de Comissão Qualy'												, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'2'																		, ; //X2_POSLGT
	'2'																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela PAW
//
aAdd( aSX2, { ;
	'PAW'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'PAW'+cEmpr																, ; //X2_ARQUIVO
	'Controle de alteração Comissão'										, ; //X2_NOME
	'Controle de alteração Comissão'										, ; //X2_NOMESPA
	'Controle de alteração Comissão'										, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'1'																		, ; //X2_POSLGT
	'1'																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela PAY
//
aAdd( aSX2, { ;
	'PAY'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'PAY'+cEmpr																, ; //X2_ARQUIVO
	'Tabela Auxiliar Laudo'													, ; //X2_NOME
	'Tabela Auxiliar Laudo'													, ; //X2_NOMESPA
	'Tabela Auxiliar Laudo'													, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'2'																		, ; //X2_POSLGT
	'2'																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela SZD
//
aAdd( aSX2, { ;
	'SZD'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'SZD'+cEmpr																, ; //X2_ARQUIVO
	'ANALISE DE PRODUCAO'													, ; //X2_NOME
	'ANALISE DE PRODUCAO'													, ; //X2_NOMESPA
	'ANALISE DE PRODUCAO'													, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	'ZD_FILIAL+ZD_PRODUT+ZD_LOTE+ZD_LI+ZD_LE+ZD_ITEM+ZD_ENSAIO'				, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela ZZH
//
aAdd( aSX2, { ;
	'ZZH'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZH'+cEmpr																, ; //X2_ARQUIVO
	'HOLDINGS CLIENTES'														, ; //X2_NOME
	'HOLDINGS CLIENTES'														, ; //X2_NOMESPA
	'HOLDINGS CLIENTES'														, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela ZZJ
//
aAdd( aSX2, { ;
	'ZZJ'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZJ'+cEmpr																, ; //X2_ARQUIVO
	'motivos tecnicos'														, ; //X2_NOME
	'motivos tecnicos'														, ; //X2_NOMESPA
	'motivos tecnicos'														, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'1'																		, ; //X2_POSLGT
	'1'																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela ZZK
//
aAdd( aSX2, { ;
	'ZZK'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZK'+cEmpr																, ; //X2_ARQUIVO
	'Tipos de Ocorrencias'													, ; //X2_NOME
	'Tipos de Ocorrencias'													, ; //X2_NOMESPA
	'Tipos de Ocorrencias'													, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'1'																		, ; //X2_POSLGT
	'1'																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( "SX2" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	oProcess:IncRegua2( "Atualizando Arquivos (SX2) ..." )

	If !SX2->( dbSeek( aSX2[nI][1] ) )

		If !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + "/"
			AutoGrLog( "Foi incluída a tabela " + aSX2[nI][1] )
		EndIf

		RecLock( "SX2", .T. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If AllTrim( aEstrut[nJ] ) == "X2_ARQUIVO"
					FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  "0" )
				Else
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf
			EndIf
		Next nJ
		MsUnLock()

	Else

		If  !( StrTran( Upper( AllTrim( SX2->X2_UNICO ) ), " ", "" ) == StrTran( Upper( AllTrim( aSX2[nI][12]  ) ), " ", "" ) )
			RecLock( "SX2", .F. )
			SX2->X2_UNICO := aSX2[nI][12]
			MsUnlock()

			If MSFILE( RetSqlName( aSX2[nI][1] ),RetSqlName( aSX2[nI][1] ) + "_UNQ"  )
				TcInternal( 60, RetSqlName( aSX2[nI][1] ) + "|" + RetSqlName( aSX2[nI][1] ) + "_UNQ" )
			EndIf

			AutoGrLog( "Foi alterada a chave única da tabela " + aSX2[nI][1] )
		EndIf

		RecLock( "SX2", .F. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If PadR( aEstrut[nJ], 10 ) $ cCpoUpd
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf

			EndIf
		Next nJ
		MsUnLock()

	EndIf

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3

Função de processamento da gravação do SX3 - Campos

@author UPDATE gerado automaticamente
@since  02/10/22
@obs    Gerado por EXPORDIC - V.7.5.2.2 EFS / Upd. V.5.3.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cMsg      := ""
Local cSeqAtu   := ""
Local cX3Campo  := ""
Local cX3Dado   := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nPosVld   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX3" + CRLF )

aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, { "X3_TITULO" , 0 }, ;
             { "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, { "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, ;
             { "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, { "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, ;
             { "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, ;
             { "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, { "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, ;
             { "X3_CONDSQL", 0 }, { "X3_CHKSQL" , 0 }, { "X3_IDXSRV" , 0 }, { "X3_ORTOGRA", 0 }, { "X3_TELA"   , 0 }, { "X3_POSLGT" , 0 }, { "X3_IDXFLD" , 0 }, ;
             { "X3_AGRUP"  , 0 }, { "X3_MODAL"  , 0 }, { "X3_PYME"   , 0 } }

aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )


//
// Campos Tabela CB8
//
aAdd( aSX3, { ;
	'CB8'																	, ; //X3_ARQUIVO
	'27'																	, ; //X3_ORDEM
	'CB8_XUN'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Unid.Medida'															, ; //X3_TITULO
	'Unid.Medida'															, ; //X3_TITSPA
	'Unid.Medida'															, ; //X3_TITENG
	'Unidade de Medida'														, ; //X3_DESCRIC
	'Unidade de Medida'														, ; //X3_DESCSPA
	'Unidade de Medida'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SAH'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'CB8'																	, ; //X3_ARQUIVO
	'28'																	, ; //X3_ORDEM
	'CB8_XUNEXP'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Unid.Med.Exp'															, ; //X3_TITULO
	'Unid.Med.Exp'															, ; //X3_TITSPA
	'Unid.Med.Exp'															, ; //X3_TITENG
	'Unidade Medida Expedição'												, ; //X3_DESCRIC
	'Unidade Medida Expedição'												, ; //X3_DESCSPA
	'Unidade Medida Expedição'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'CB8'																	, ; //X3_ARQUIVO
	'29'																	, ; //X3_ORDEM
	'CB8_XCLEXP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Calc.Qte.Emb'															, ; //X3_TITULO
	'Calc.Qte.Emb'															, ; //X3_TITSPA
	'Calc.Qte.Emb'															, ; //X3_TITENG
	'Calculo Quant. Embalagem'												, ; //X3_DESCRIC
	'Calculo Quant. Embalagem'												, ; //X3_DESCSPA
	'Calculo Quant. Embalagem'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'CB8'																	, ; //X3_ARQUIVO
	'30'																	, ; //X3_ORDEM
	'CB8_XQTVOL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Calc.Qte.Vol'															, ; //X3_TITULO
	'Calc.Qte.Vol'															, ; //X3_TITSPA
	'Calc.Qte.Vol'															, ; //X3_TITENG
	'Calculo Qtde Volume'													, ; //X3_DESCRIC
	'Calculo Qtde Volume'													, ; //X3_DESCSPA
	'Calculo Qtde Volume'													, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'CB8'																	, ; //X3_ARQUIVO
	'31'																	, ; //X3_ORDEM
	'CB8_XDFVOL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Calc.Dif.Vol'															, ; //X3_TITULO
	'Calc.Dif.Vol'															, ; //X3_TITSPA
	'Calc.Dif.Vol'															, ; //X3_TITENG
	'Calculo Diferença Volume'												, ; //X3_DESCRIC
	'Calculo Diferença Volume'												, ; //X3_DESCSPA
	'Calculo Diferença Volume'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'CB8'																	, ; //X3_ARQUIVO
	'32'																	, ; //X3_ORDEM
	'CB8_XMNEMB'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Qte.Min.Emb.'															, ; //X3_TITULO
	'Qte.Min.Emb.'															, ; //X3_TITSPA
	'Qte.Min.Emb.'															, ; //X3_TITENG
	'Quanti. Minima Embalagem'												, ; //X3_DESCRIC
	'Quanti. Minima Embalagem'												, ; //X3_DESCSPA
	'Quanti. Minima Embalagem'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'CB8'																	, ; //X3_ARQUIVO
	'33'																	, ; //X3_ORDEM
	'CB8_XPESBU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Calc.Pes.Bru'															, ; //X3_TITULO
	'Calc.Pes.Bru'															, ; //X3_TITSPA
	'Calc.Pes.Bru'															, ; //X3_TITENG
	'Calculo Peso Bruto'													, ; //X3_DESCRIC
	'Calculo Peso Bruto'													, ; //X3_DESCSPA
	'Calculo Peso Bruto'													, ; //X3_DESCENG
	'@E 99,999,999,999.9999'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'CB8'																	, ; //X3_ARQUIVO
	'34'																	, ; //X3_ORDEM
	'CB8_XPESLQ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Calc.Pes.Liq'															, ; //X3_TITULO
	'Calc.Pes.Liq'															, ; //X3_TITSPA
	'Calc.Pes.Liq'															, ; //X3_TITENG
	'Calculo Peso Liquido'													, ; //X3_DESCRIC
	'Calculo Peso Liquido'													, ; //X3_DESCSPA
	'Calculo Peso Liquido'													, ; //X3_DESCENG
	'@E 99,999,999,999.9999'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'CB8'																	, ; //X3_ARQUIVO
	'35'																	, ; //X3_ORDEM
	'CB8_XPLIQ'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Peso.Liq.Cad'															, ; //X3_TITULO
	'Peso.Liq.Cad'															, ; //X3_TITSPA
	'Peso.Liq.Cad'															, ; //X3_TITENG
	'Peso Liquido do Cadastro'												, ; //X3_DESCRIC
	'Peso Liquido do Cadastro'												, ; //X3_DESCSPA
	'Peso Liquido do Cadastro'												, ; //X3_DESCENG
	'@E 99,999,999,999.9999'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'CB8'																	, ; //X3_ARQUIVO
	'36'																	, ; //X3_ORDEM
	'CB8_XPBRU'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Peso.Bru.Cad'															, ; //X3_TITULO
	'Peso.Bru.Cad'															, ; //X3_TITSPA
	'Peso.Bru.Cad'															, ; //X3_TITENG
	'Peso Bruto do Cadastro'												, ; //X3_DESCRIC
	'Peso Bruto do Cadastro'												, ; //X3_DESCSPA
	'Peso Bruto do Cadastro'												, ; //X3_DESCENG
	'@E 99,999,999,999.9999'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela DAI
//
aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'33'																	, ; //X3_ORDEM
	'DAI_XESP1'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'34'																	, ; //X3_ORDEM
	'DAI_XVOL1'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'35'																	, ; //X3_ORDEM
	'DAI_XESP2'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'36'																	, ; //X3_ORDEM
	'DAI_XESP3'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'37'																	, ; //X3_ORDEM
	'DAI_XESP4'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'38'																	, ; //X3_ORDEM
	'DAI_XESP5'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'39'																	, ; //X3_ORDEM
	'DAI_XESP6'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'40'																	, ; //X3_ORDEM
	'DAI_XESP7'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'41'																	, ; //X3_ORDEM
	'DAI_XESP8'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'42'																	, ; //X3_ORDEM
	'DAI_XESP9'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'43'																	, ; //X3_ORDEM
	'DAI_XESP10'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'44'																	, ; //X3_ORDEM
	'DAI_XESP11'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'45'																	, ; //X3_ORDEM
	'DAI_XESP12'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'46'																	, ; //X3_ORDEM
	'DAI_XESP13'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'47'																	, ; //X3_ORDEM
	'DAI_XESP14'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'48'																	, ; //X3_ORDEM
	'DAI_XESP15'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'49'																	, ; //X3_ORDEM
	'DAI_XVOL2'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'50'																	, ; //X3_ORDEM
	'DAI_XVOL3'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'51'																	, ; //X3_ORDEM
	'DAI_XVOL4'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'52'																	, ; //X3_ORDEM
	'DAI_XVOL5'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'53'																	, ; //X3_ORDEM
	'DAI_XVOL6'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'54'																	, ; //X3_ORDEM
	'DAI_XVOL7'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'55'																	, ; //X3_ORDEM
	'DAI_XVOL8'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'56'																	, ; //X3_ORDEM
	'DAI_XVOL9'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'57'																	, ; //X3_ORDEM
	'DAI_XVOL10'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'58'																	, ; //X3_ORDEM
	'DAI_XVOL11'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'59'																	, ; //X3_ORDEM
	'DAI_XVOL12'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'60'																	, ; //X3_ORDEM
	'DAI_XVOL13'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'61'																	, ; //X3_ORDEM
	'DAI_XVOL14'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'62'																	, ; //X3_ORDEM
	'DAI_XVOL15'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'63'																	, ; //X3_ORDEM
	'DAI_XDIF1'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'64'																	, ; //X3_ORDEM
	'DAI_XDIF2'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'65'																	, ; //X3_ORDEM
	'DAI_XDIF3'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'66'																	, ; //X3_ORDEM
	'DAI_XDIF4'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'67'																	, ; //X3_ORDEM
	'DAI_XDIF5'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'68'																	, ; //X3_ORDEM
	'DAI_XDIF6'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'69'																	, ; //X3_ORDEM
	'DAI_XDIF7'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'70'																	, ; //X3_ORDEM
	'DAI_XDIF8'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'71'																	, ; //X3_ORDEM
	'DAI_XDIF9'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'72'																	, ; //X3_ORDEM
	'DAI_XDIF10'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Esp.Ped.Vda'															, ; //X3_TITULO
	'Esp.Ped.Vda'															, ; //X3_TITSPA
	'Esp.Ped.Vda'															, ; //X3_TITENG
	'Especie Pedido de Venda'												, ; //X3_DESCRIC
	'Especie Pedido de Venda'												, ; //X3_DESCSPA
	'Especie Pedido de Venda'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'73'																	, ; //X3_ORDEM
	'DAI_XVDF1'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'74'																	, ; //X3_ORDEM
	'DAI_XVDF2'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'75'																	, ; //X3_ORDEM
	'DAI_XVDF3'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'76'																	, ; //X3_ORDEM
	'DAI_XVDF4'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'77'																	, ; //X3_ORDEM
	'DAI_XVDF5'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'78'																	, ; //X3_ORDEM
	'DAI_XVDF6'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'79'																	, ; //X3_ORDEM
	'DAI_XVDF7'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'80'																	, ; //X3_ORDEM
	'DAI_XVDF8'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'81'																	, ; //X3_ORDEM
	'DAI_XVDF9'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'82'																	, ; //X3_ORDEM
	'DAI_XVDF10'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vol.Ped.Vda'															, ; //X3_TITULO
	'Vol.Ped.Vda'															, ; //X3_TITSPA
	'Vol.Ped.Vda'															, ; //X3_TITENG
	'Volume Pedido de Vendas'												, ; //X3_DESCRIC
	'Volume Pedido de Vendas'												, ; //X3_DESCSPA
	'Volume Pedido de Vendas'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DAI'																	, ; //X3_ARQUIVO
	'83'																	, ; //X3_ORDEM
	'DAI_XVALPD'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vl.Ped.Venda'															, ; //X3_TITULO
	'Vl.Ped.Venda'															, ; //X3_TITSPA
	'Vl.Ped.Venda'															, ; //X3_TITENG
	'Valor Total Pedido Vendas'												, ; //X3_DESCRIC
	'Valor Total Pedido Vendas'												, ; //X3_DESCSPA
	'Valor Total Pedido Vendas'												, ; //X3_DESCENG
	'@E 9,999,999,999,999.99'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela EE7
//
aAdd( aSX3, { ;
	'EE7'																	, ; //X3_ARQUIVO
	'A6'																	, ; //X3_ORDEM
	'EE7_INDPRE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Pres.Inform.'															, ; //X3_TITULO
	'Pres.Inform.'															, ; //X3_TITSPA
	'Pres.Inform.'															, ; //X3_TITENG
	'Presença Informada'													, ; //X3_DESCRIC
	'Presença Informada'													, ; //X3_DESCSPA
	'Presença Informada'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'Pertence(" 0/1/2/3/5/9")'												, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'0=Não Aplica;1=Presencial;2=Não Presencial,Net;3=Não Presencial,TeleAtendi.;5=Presencial,ForadoEstab.;9=Não Presencial,outros', ; //X3_CBOX
	'0=Não Aplica;1=Presencial;2=Não Presencial,Net;3=Não Presencial,TeleAtendi.;5=Presencial,ForadoEstab.;9=Não Presencial,outros', ; //X3_CBOXSPA
	'0=Não Aplica;1=Presencial;2=Não Presencial,Net;3=Não Presencial,TeleAtendi.;5=Presencial,ForadoEstab.;9=Não Presencial,outros', ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'EE7'																	, ; //X3_ARQUIVO
	'A7'																	, ; //X3_ORDEM
	'EE7_TPFRET'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo frete'															, ; //X3_TITULO
	'Tipo frete'															, ; //X3_TITSPA
	'Tipo frete'															, ; //X3_TITENG
	'Tipo frete'															, ; //X3_DESCRIC
	'Tipo frete'															, ; //X3_DESCSPA
	'Tipo frete'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'C=CIF;F=FOB;T=Por conta terceiros;R=Por conta remetente;D=Por conta destinatário;S=Sem frete', ; //X3_CBOX
	'C=CIF;F=FOB;T=Por conta terceiros;R=Por conta remetente;D=Por conta destinatário;S=Sem frete', ; //X3_CBOXSPA
	'C=CIF;F=FOB;T=Por conta terceiros;R=Por conta remetente;D=Por conta destinatário;S=Sem frete', ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'EE7'																	, ; //X3_ARQUIVO
	'A8'																	, ; //X3_ORDEM
	'EE7_FECENT'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dta Entrada'															, ; //X3_TITULO
	'Dta Entrada'															, ; //X3_TITSPA
	'Dta Entrada'															, ; //X3_TITENG
	'Dta Entrada'															, ; //X3_DESCRIC
	'Dta Entrada'															, ; //X3_DESCSPA
	'Dta Entrada'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'DDATABASE+5'															, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'EE7'																	, ; //X3_ARQUIVO
	'A9'																	, ; //X3_ORDEM
	'EE7_TIPLIB'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo LIber.'															, ; //X3_TITULO
	'Tipo LIber.'															, ; //X3_TITSPA
	'Tipo LIber.'															, ; //X3_TITENG
	'Tipo LIberação'														, ; //X3_DESCRIC
	'Tipo LIberação'														, ; //X3_DESCSPA
	'Tipo LIberação'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"1"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Libera Por Item;2=Libera por Pedido'									, ; //X3_CBOX
	'1=Libera Por Item;2=Libera por Pedido'									, ; //X3_CBOXSPA
	'1=Libera Por Item;2=Libera por Pedido'									, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'EE7'																	, ; //X3_ARQUIVO
	'B0'																	, ; //X3_ORDEM
	'EE7_XOPER'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo Operac.'															, ; //X3_TITULO
	'Tipo Operac.'															, ; //X3_TITSPA
	'Tipo Operac.'															, ; //X3_TITENG
	'Tipo da operação'														, ; //X3_DESCRIC
	'Tipo da operação'														, ; //X3_DESCSPA
	'Tipo da operação'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"01"'																	, ; //X3_RELACAO
	'DJ'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'ExistCpo("SX5","DJ"+M->EE7_XOPER)'										, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'EE7'																	, ; //X3_ARQUIVO
	'B1'																	, ; //X3_ORDEM
	'EE7_XOBSER'															, ; //X3_CAMPO
	'M'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Observação'															, ; //X3_TITULO
	'Observação'															, ; //X3_TITSPA
	'Observação'															, ; //X3_TITENG
	'Observação s/pedido'													, ; //X3_DESCRIC
	'Observação s/pedido'													, ; //X3_DESCSPA
	'Observação s/pedido'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'EE7'																	, ; //X3_ARQUIVO
	'B2'																	, ; //X3_ORDEM
	'EE7_XMARGE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'PC'																	, ; //X3_TITULO
	'PC'																	, ; //X3_TITSPA
	'PC'																	, ; //X3_TITENG
	'PC'																	, ; //X3_DESCRIC
	'PC'																	, ; //X3_DESCSPA
	'PC'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'EE7'																	, ; //X3_ARQUIVO
	'B3'																	, ; //X3_ORDEM
	'EE7_XVALMA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	7																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'VMC'																	, ; //X3_TITULO
	'VMC'																	, ; //X3_TITSPA
	'VMC'																	, ; //X3_TITENG
	'VMC'																	, ; //X3_DESCRIC
	'VMC'																	, ; //X3_DESCSPA
	'VMC'																	, ; //X3_DESCENG
	'9999999'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela EE8
//
aAdd( aSX3, { ;
	'EE8'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'EE8_XPESLI'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Pesp Liq.'																, ; //X3_TITULO
	'Pesp Liq.'																, ; //X3_TITSPA
	'Pesp Liq.'																, ; //X3_TITENG
	'Peso Liquido do Produto'												, ; //X3_DESCRIC
	'Peso Liquido do Produto'												, ; //X3_DESCSPA
	'Peso Liquido do Produto'												, ; //X3_DESCENG
	'@E 99,999,999,999.9999'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'EE8'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'EE8_XPESBU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Peso Bruto'															, ; //X3_TITULO
	'Peso Bruto'															, ; //X3_TITSPA
	'Peso Bruto'															, ; //X3_TITENG
	'Peso Bruto  do Produto'												, ; //X3_DESCRIC
	'Peso Bruto  do Produto'												, ; //X3_DESCSPA
	'Peso Bruto  do Produto'												, ; //X3_DESCENG
	'@E 99,999,999,999.9999'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'EE8'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'EE8_XCLEXP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Calc.Qtd.Exp'															, ; //X3_TITULO
	'Calc.Qtd.Exp'															, ; //X3_TITSPA
	'Calc.Qtd.Exp'															, ; //X3_TITENG
	'Calculo Qtde de Expedição'												, ; //X3_DESCRIC
	'Calculo Qtde de Expedição'												, ; //X3_DESCSPA
	'Calculo Qtde de Expedição'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'EE8'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'EE8_XQTDEN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Qtd.já Fatur'															, ; //X3_TITULO
	'Qtd.já Fatur'															, ; //X3_TITSPA
	'Qtd.já Fatur'															, ; //X3_TITENG
	'Quantidade já faturada'												, ; //X3_DESCRIC
	'Quantidade já faturada'												, ; //X3_DESCSPA
	'Quantidade já faturada'												, ; //X3_DESCENG
	'@E 99,999,999,999.9999'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'IF(INCLUI, 0, EE8->EE8_SLDINI)'										, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'EE8'																	, ; //X3_ARQUIVO
	'14'																	, ; //X3_ORDEM
	'EE8_XGRPES'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Grp Produto'															, ; //X3_TITULO
	'Grp Produto'															, ; //X3_TITSPA
	'Grp Produto'															, ; //X3_TITENG
	'Grupo de Produto'														, ; //X3_DESCRIC
	'Grupo de Produto'														, ; //X3_DESCSPA
	'Grupo de Produto'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SBM'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'EE8'																	, ; //X3_ARQUIVO
	'15'																	, ; //X3_ORDEM
	'EE8_XGRPDS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Descr Grupo'															, ; //X3_TITULO
	'Descr Grupo'															, ; //X3_TITSPA
	'Descr Grupo'															, ; //X3_TITENG
	'Descrição Grupo'														, ; //X3_DESCRIC
	'Descrição Grupo'														, ; //X3_DESCSPA
	'Descrição Grupo'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'EE8'																	, ; //X3_ARQUIVO
	'16'																	, ; //X3_ORDEM
	'EE8_XQTDPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Qtd Produzid'															, ; //X3_TITULO
	'Qtd Produzid'															, ; //X3_TITSPA
	'Qtd Produzid'															, ; //X3_TITENG
	'Quantidade Produzida'													, ; //X3_DESCRIC
	'Quantidade Produzida'													, ; //X3_DESCSPA
	'Quantidade Produzida'													, ; //X3_DESCENG
	'@E 999,999,999.9999'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'EE8'																	, ; //X3_ARQUIVO
	'17'																	, ; //X3_ORDEM
	'EE8_XPLIQ'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Peso.Liq.Cad'															, ; //X3_TITULO
	'Peso.Liq.Cad'															, ; //X3_TITSPA
	'Peso.Liq.Cad'															, ; //X3_TITENG
	'Peso Liquido do Cadastro'												, ; //X3_DESCRIC
	'Peso Liquido do Cadastro'												, ; //X3_DESCSPA
	'Peso Liquido do Cadastro'												, ; //X3_DESCENG
	'@E 99,999,999,999.9999'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'EE8'																	, ; //X3_ARQUIVO
	'18'																	, ; //X3_ORDEM
	'EE8_XPBRU'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Peso.Bru.Cad'															, ; //X3_TITULO
	'Peso.Bru.Cad'															, ; //X3_TITSPA
	'Peso.Bru.Cad'															, ; //X3_TITENG
	'Peso Bruto do Cadastro'												, ; //X3_DESCRIC
	'Peso Bruto do Cadastro'												, ; //X3_DESCSPA
	'Peso Bruto do Cadastro'												, ; //X3_DESCENG
	'@E 99,999,999,999.9999'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela PAA
//
aAdd( aSX3, { ;
	'PAA'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'PAA_REV'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Revisao'															, ; //X3_TITULO
	'Cod. Revisao'															, ; //X3_TITSPA
	'Cod. Revisao'															, ; //X3_TITENG
	'Codigo Revisão Comissão'												, ; //X3_DESCRIC
	'Codigo Revisão Comissão'												, ; //X3_DESCSPA
	'Codigo Revisão Comissão'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	'A01'																	, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAA'																	, ; //X3_ARQUIVO
	'26'																	, ; //X3_ORDEM
	'PAA_JUSTIF'															, ; //X3_CAMPO
	'M'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Just. Alter.'															, ; //X3_TITULO
	'Just. Alter.'															, ; //X3_TITSPA
	'Just. Alter.'															, ; //X3_TITENG
	'Justificativa Alteração'												, ; //X3_DESCRIC
	'Justificativa Alteração'												, ; //X3_DESCSPA
	'Justificativa Alteração'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'IF(INCLUI,.F.,.T.)'													, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'2'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela PAW
//
aAdd( aSX3, { ;
	'PAW'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'PAW_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'XXXXXX X'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAW'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'PAW_PEDIDO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Pedido Vda'															, ; //X3_TITULO
	'Pedido Vda'															, ; //X3_TITSPA
	'Pedido Vda'															, ; //X3_TITENG
	'Pedido de Vendas'														, ; //X3_DESCRIC
	'Pedido de Vendas'														, ; //X3_DESCSPA
	'Pedido de Vendas'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAW'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'PAW_CODCLI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Cliente'															, ; //X3_TITULO
	'Cod. Cliente'															, ; //X3_TITSPA
	'Cod. Cliente'															, ; //X3_TITENG
	'Codigo do Cliente'														, ; //X3_DESCRIC
	'Codigo do Cliente'														, ; //X3_DESCSPA
	'Codigo do Cliente'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAW'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'PAW_LOJA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Loja Cliente'															, ; //X3_TITULO
	'Loja Cliente'															, ; //X3_TITSPA
	'Loja Cliente'															, ; //X3_TITENG
	'Loja Cliente'															, ; //X3_DESCRIC
	'Loja Cliente'															, ; //X3_DESCSPA
	'Loja Cliente'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAW'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'PAW_COD'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Produto'															, ; //X3_TITULO
	'Cod. Produto'															, ; //X3_TITSPA
	'Cod. Produto'															, ; //X3_TITENG
	'Codigo do Produto'														, ; //X3_DESCRIC
	'Codigo do Produto'														, ; //X3_DESCSPA
	'Codigo do Produto'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAW'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'PAW_ITEM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Item Pedido'															, ; //X3_TITULO
	'Item Pedido'															, ; //X3_TITSPA
	'Item Pedido'															, ; //X3_TITENG
	'Item do Pedido de vendas'												, ; //X3_DESCRIC
	'Item do Pedido de vendas'												, ; //X3_DESCSPA
	'Item do Pedido de vendas'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAW'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'PAW_QTD'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Qtd Ped. Vda'															, ; //X3_TITULO
	'Qtd Ped. Vda'															, ; //X3_TITSPA
	'Qtd Ped. Vda'															, ; //X3_TITENG
	'Quantidade Pedido Venda'												, ; //X3_DESCRIC
	'Quantidade Pedido Venda'												, ; //X3_DESCSPA
	'Quantidade Pedido Venda'												, ; //X3_DESCENG
	'@E 99,999,999,999.9999'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAW'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'PAW_PRECO'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Preco Pedido'															, ; //X3_TITULO
	'Preco Pedido'															, ; //X3_TITSPA
	'Preco Pedido'															, ; //X3_TITENG
	'Preco Unitario Produto'												, ; //X3_DESCRIC
	'Preco Unitario Produto'												, ; //X3_DESCSPA
	'Preco Unitario Produto'												, ; //X3_DESCENG
	'@E 99,999,999,999.9999'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAW'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'PAW_CODTAB'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tab. Ped.Vda'															, ; //X3_TITULO
	'Tab. Ped.Vda'															, ; //X3_TITSPA
	'Tab. Ped.Vda'															, ; //X3_TITENG
	'Cod. Tabela Pedido Vendas'												, ; //X3_DESCRIC
	'Cod. Tabela Pedido Vendas'												, ; //X3_DESCSPA
	'Cod. Tabela Pedido Vendas'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAW'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'PAW_REV'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Rev.Ped.Vda'															, ; //X3_TITULO
	'Rev.Ped.Vda'															, ; //X3_TITSPA
	'Rev.Ped.Vda'															, ; //X3_TITENG
	'Revisao Pedido de Vendas'												, ; //X3_DESCRIC
	'Revisao Pedido de Vendas'												, ; //X3_DESCSPA
	'Revisao Pedido de Vendas'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAW'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'PAW_DATA'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dta.Rev.Ped.'															, ; //X3_TITULO
	'Dta.Rev.Ped.'															, ; //X3_TITSPA
	'Dta.Rev.Ped.'															, ; //X3_TITENG
	'Dta Revisao Pedido Vendas'												, ; //X3_DESCRIC
	'Dta Revisao Pedido Vendas'												, ; //X3_DESCSPA
	'Dta Revisao Pedido Vendas'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAW'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'PAW_COMIS1'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'% Comis.Ped.'															, ; //X3_TITULO
	'% Comis.Ped.'															, ; //X3_TITSPA
	'% Comis.Ped.'															, ; //X3_TITENG
	'% Comissão Pedido Vendas'												, ; //X3_DESCRIC
	'% Comissão Pedido Vendas'												, ; //X3_DESCSPA
	'% Comissão Pedido Vendas'												, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAW'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'PAW_DTAREG'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dta Ocorren.'															, ; //X3_TITULO
	'Dta Ocorren.'															, ; //X3_TITSPA
	'Dta Ocorren.'															, ; //X3_TITENG
	'Data da Ocorrencia'													, ; //X3_DESCRIC
	'Data da Ocorrencia'													, ; //X3_DESCSPA
	'Data da Ocorrencia'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAW'																	, ; //X3_ARQUIVO
	'14'																	, ; //X3_ORDEM
	'PAW_STATUS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Sts Registro'															, ; //X3_TITULO
	'Sts Registro'															, ; //X3_TITSPA
	'Sts Registro'															, ; //X3_TITENG
	'Status do Registro'													, ; //X3_DESCRIC
	'Status do Registro'													, ; //X3_DESCSPA
	'Status do Registro'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Alterado;2=Revisado'													, ; //X3_CBOX
	'1=Alterado;2=Revisado'													, ; //X3_CBOXSPA
	'1=Alterado;2=Revisado'													, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAW'																	, ; //X3_ARQUIVO
	'15'																	, ; //X3_ORDEM
	'PAW_USRNOM'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome Usuario'															, ; //X3_TITULO
	'Nome Usuario'															, ; //X3_TITSPA
	'Nome Usuario'															, ; //X3_TITENG
	'Nome Usuario da Alteração'												, ; //X3_DESCRIC
	'Nome Usuario da Alteração'												, ; //X3_DESCSPA
	'Nome Usuario da Alteração'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAW'																	, ; //X3_ARQUIVO
	'16'																	, ; //X3_ORDEM
	'PAW_USERGA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	17																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Log de Alter'															, ; //X3_TITULO
	'Log de Alter'															, ; //X3_TITSPA
	'Log de Alter'															, ; //X3_TITENG
	'Log de Alteracao'														, ; //X3_DESCRIC
	'Log de Alteracao'														, ; //X3_DESCSPA
	'Log de Alteracao'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	9																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'L'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAW'																	, ; //X3_ARQUIVO
	'17'																	, ; //X3_ORDEM
	'PAW_USERGI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	17																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Log de Inclu'															, ; //X3_TITULO
	'Log de Inclu'															, ; //X3_TITSPA
	'Log de Inclu'															, ; //X3_TITENG
	'Log de Inclusao'														, ; //X3_DESCRIC
	'Log de Inclusao'														, ; //X3_DESCSPA
	'Log de Inclusao'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	9																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'L'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela PAY
//
aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'PAY_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'XXXXXX X'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'PAY_CTRL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Contrl. Imp.'															, ; //X3_TITULO
	'Contrl. Imp.'															, ; //X3_TITSPA
	'Contrl. Imp.'															, ; //X3_TITENG
	'Controle de Impressão'													, ; //X3_DESCRIC
	'Controle de Impressão'													, ; //X3_DESCSPA
	'Controle de Impressão'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'PAY_SEQ'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Seq.Ctrl.Op'															, ; //X3_TITULO
	'Seq.Ctrl.Op'															, ; //X3_TITSPA
	'Seq.Ctrl.Op'															, ; //X3_TITENG
	'Sequencia Controle OP'													, ; //X3_DESCRIC
	'Sequencia Controle OP'													, ; //X3_DESCSPA
	'Sequencia Controle OP'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'PAY_PROD'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Produto'															, ; //X3_TITULO
	'Cod. Produto'															, ; //X3_TITSPA
	'Cod. Produto'															, ; //X3_TITENG
	'Codigo Produto'														, ; //X3_DESCRIC
	'Codigo Produto'														, ; //X3_DESCSPA
	'Codigo Produto'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'PAY_OP'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Num.Ord.Prod'															, ; //X3_TITULO
	'Num.Ord.Prod'															, ; //X3_TITSPA
	'Num.Ord.Prod'															, ; //X3_TITENG
	'Numero Ordem Produção'													, ; //X3_DESCRIC
	'Numero Ordem Produção'													, ; //X3_DESCSPA
	'Numero Ordem Produção'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'PAY_LOTE'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Num. Lote'																, ; //X3_TITULO
	'Num. Lote'																, ; //X3_TITSPA
	'Num. Lote'																, ; //X3_TITENG
	'Numero de Lote'														, ; //X3_DESCRIC
	'Numero de Lote'														, ; //X3_DESCSPA
	'Numero de Lote'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'PAY_DTFAB'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Fabric.'															, ; //X3_TITULO
	'Data Fabric.'															, ; //X3_TITSPA
	'Data Fabric.'															, ; //X3_TITENG
	'Data Fabricação'														, ; //X3_DESCRIC
	'Data Fabricação'														, ; //X3_DESCSPA
	'Data Fabricação'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'PAY_DTVAL'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dta Validad.'															, ; //X3_TITULO
	'Dta Validad.'															, ; //X3_TITSPA
	'Dta Validad.'															, ; //X3_TITENG
	'Data de Validade'														, ; //X3_DESCRIC
	'Data de Validade'														, ; //X3_DESCSPA
	'Data de Validade'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'PAY_HRREG'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hr. Registro'															, ; //X3_TITULO
	'Hr. Registro'															, ; //X3_TITSPA
	'Hr. Registro'															, ; //X3_TITENG
	'Hora do Registro'														, ; //X3_DESCRIC
	'Hora do Registro'														, ; //X3_DESCSPA
	'Hora do Registro'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'PAY_DTLAUD'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dta Laudo'																, ; //X3_TITULO
	'Dta Laudo'																, ; //X3_TITSPA
	'Dta Laudo'																, ; //X3_TITENG
	'Data do Laudo'															, ; //X3_DESCRIC
	'Data do Laudo'															, ; //X3_DESCSPA
	'Data do Laudo'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'PAY_CODANL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Analise'															, ; //X3_TITULO
	'Cod. Analise'															, ; //X3_TITSPA
	'Cod. Analise'															, ; //X3_TITENG
	'Codigo da Analise'														, ; //X3_DESCRIC
	'Codigo da Analise'														, ; //X3_DESCSPA
	'Codigo da Analise'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'PAY_USERGA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	17																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Log de Alter'															, ; //X3_TITULO
	'Log de Alter'															, ; //X3_TITSPA
	'Log de Alter'															, ; //X3_TITENG
	'Log de Alteracao'														, ; //X3_DESCRIC
	'Log de Alteracao'														, ; //X3_DESCSPA
	'Log de Alteracao'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	9																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'L'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'PAY_USERGI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	17																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Log de Inclu'															, ; //X3_TITULO
	'Log de Inclu'															, ; //X3_TITSPA
	'Log de Inclu'															, ; //X3_TITENG
	'Log de Inclusao'														, ; //X3_DESCRIC
	'Log de Inclusao'														, ; //X3_DESCSPA
	'Log de Inclusao'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	9																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'L'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'14'																	, ; //X3_ORDEM
	'PAY_STATUS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status Laudo'															, ; //X3_TITULO
	'Status Laudo'															, ; //X3_TITSPA
	'Status Laudo'															, ; //X3_TITENG
	'Status do Laudo'														, ; //X3_DESCRIC
	'Status do Laudo'														, ; //X3_DESCSPA
	'Status do Laudo'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Emissão Etiqueta;2=Elaboração Laudo'									, ; //X3_CBOX
	'1=Emissão Etiqueta;2=Elaboração Laudo'									, ; //X3_CBOXSPA
	'1=Emissão Etiqueta;2=Elaboração Laudo'									, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SA1
//
aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'E3'																	, ; //X3_ORDEM
	'A1_XCOMIS1'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'% Comis Cli.'															, ; //X3_TITULO
	'% Comis Cli.'															, ; //X3_TITSPA
	'% Comis Cli.'															, ; //X3_TITENG
	'% Comisão Cliente'														, ; //X3_DESCRIC
	'% Comisão Cliente'														, ; //X3_DESCSPA
	'% Comisão Cliente'														, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'4'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SA3
//
aAdd( aSX3, { ;
	'SA3'																	, ; //X3_ARQUIVO
	'95'																	, ; //X3_ORDEM
	'A3_TPCOMIS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tp Comissão'															, ; //X3_TITULO
	'Tp Comissão'															, ; //X3_TITSPA
	'Tp Comissão'															, ; //X3_TITENG
	'Tipo da Comissão'														, ; //X3_DESCRIC
	'Tipo da Comissão'														, ; //X3_DESCSPA
	'Tipo da Comissão'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"N"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'N=Normal;T=Teto;F=Fixo'												, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA3'																	, ; //X3_ARQUIVO
	'96'																	, ; //X3_ORDEM
	'A3_COMINF'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Comiss Piso'															, ; //X3_TITULO
	'Comiss Piso'															, ; //X3_TITSPA
	'Comiss Piso'															, ; //X3_TITENG
	'Comissão Piso'															, ; //X3_DESCRIC
	'Comissão Piso'															, ; //X3_DESCSPA
	'Comissão Piso'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA3'																	, ; //X3_ARQUIVO
	'97'																	, ; //X3_ORDEM
	'A3_XLOGIN'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	200																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Logins'																, ; //X3_TITULO
	'Logins'																, ; //X3_TITSPA
	'Logins'																, ; //X3_TITENG
	'Logins Autorizados'													, ; //X3_DESCRIC
	'Logins Autorizados'													, ; //X3_DESCSPA
	'Logins Autorizados'													, ; //X3_DESCENG
	'01'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	9																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA3'																	, ; //X3_ARQUIVO
	'98'																	, ; //X3_ORDEM
	'A3_XPRZENT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Prz.Entrega'															, ; //X3_TITULO
	'Prz.Entrega'															, ; //X3_TITSPA
	'Prz.Entrega'															, ; //X3_TITENG
	'Prz.Entrega p/regiao'													, ; //X3_DESCRIC
	'Prz.Entrega p/regiao'													, ; //X3_DESCSPA
	'Prz.Entrega p/regiao'													, ; //X3_DESCENG
	'99'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x     x'														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA3'																	, ; //X3_ARQUIVO
	'9A'																	, ; //X3_ORDEM
	'A3_XNCALC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Pontuação?'															, ; //X3_TITULO
	'Pontuação?'															, ; //X3_TITSPA
	'Pontuação?'															, ; //X3_TITENG
	'Pontuação Sim/Nao'														, ; //X3_DESCRIC
	'Pontuação Sim/Nao'														, ; //X3_DESCSPA
	'Pontuação Sim/Nao'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'S=Sim;N-Nao'															, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA3'																	, ; //X3_ARQUIVO
	'9B'																	, ; //X3_ORDEM
	'A3_XCLT'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Pg.% Com.Cad'															, ; //X3_TITULO
	'Pg.% Com.Cad'															, ; //X3_TITSPA
	'Pg.% Com.Cad'															, ; //X3_TITENG
	'Paga % Comissao Pelo Cad.'												, ; //X3_DESCRIC
	'Paga % Comissao Pelo Cad.'												, ; //X3_DESCSPA
	'Paga % Comissao Pelo Cad.'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Não;2=Sim'															, ; //X3_CBOX
	'1=Não;2=Sim'															, ; //X3_CBOXSPA
	'1=Não;2=Sim'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA3'																	, ; //X3_ARQUIVO
	'9C'																	, ; //X3_ORDEM
	'A3_XPGCOM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Pg. Comissão'															, ; //X3_TITULO
	'Pg. Comissão'															, ; //X3_TITSPA
	'Pg. Comissão'															, ; //X3_TITENG
	'Pg. Comissão p/  Vendedor'												, ; //X3_DESCRIC
	'Pg. Comissão p/  Vendedor'												, ; //X3_DESCSPA
	'Pg. Comissão p/  Vendedor'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Não;2=Sim'															, ; //X3_CBOX
	'1=Não;2=Sim'															, ; //X3_CBOXSPA
	'1=Não;2=Sim'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SB1
//
aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'66'																	, ; //X3_ORDEM
	'B1_XTABCOM'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Tab.Com.'															, ; //X3_TITULO
	'Cod.Tab.Com.'															, ; //X3_TITSPA
	'Cod.Tab.Com.'															, ; //X3_TITENG
	'Codigo Tabela de Comissão'												, ; //X3_DESCRIC
	'Codigo Tabela de Comissão'												, ; //X3_DESCSPA
	'Codigo Tabela de Comissão'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'67'																	, ; //X3_ORDEM
	'B1_XREVCOM'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ult.Rev.Com.'															, ; //X3_TITULO
	'Ult.Rev.Com.'															, ; //X3_TITSPA
	'Ult.Rev.Com.'															, ; //X3_TITENG
	'Ultima Revisão Comissão'												, ; //X3_DESCRIC
	'Ultima Revisão Comissão'												, ; //X3_DESCSPA
	'Ultima Revisão Comissão'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SC2
//
aAdd( aSX3, { ;
	'SC2'																	, ; //X3_ARQUIVO
	'AR'																	, ; //X3_ORDEM
	'C2_DTFABR'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dta.Fab.Euro'															, ; //X3_TITULO
	'Dta.Fab.Euro'															, ; //X3_TITSPA
	'Dta.Fab.Euro'															, ; //X3_TITENG
	'Dta. Fabricação Euro'													, ; //X3_DESCRIC
	'Dta. Fabricação Euro'													, ; //X3_DESCSPA
	'Dta. Fabricação Euro'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC2'																	, ; //X3_ARQUIVO
	'AS'																	, ; //X3_ORDEM
	'C2_DTVALID'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dta.Val.Euro'															, ; //X3_TITULO
	'Dta.Val.Euro'															, ; //X3_TITSPA
	'Dta.Val.Euro'															, ; //X3_TITENG
	'Data Validade Euro'													, ; //X3_DESCRIC
	'Data Validade Euro'													, ; //X3_DESCSPA
	'Data Validade Euro'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC2'																	, ; //X3_ARQUIVO
	'AT'																	, ; //X3_ORDEM
	'C2_XCTRL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ctrl. Laudo'															, ; //X3_TITULO
	'Ctrl. Laudo'															, ; //X3_TITSPA
	'Ctrl. Laudo'															, ; //X3_TITENG
	'Controle de Laudo Euro'												, ; //X3_DESCRIC
	'Controle de Laudo Euro'												, ; //X3_DESCSPA
	'Controle de Laudo Euro'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SC5
//
aAdd( aSX3, { ;
	'SC5'																	, ; //X3_ARQUIVO
	'BA'																	, ; //X3_ORDEM
	'C5_XTPCOM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tp. Comissão'															, ; //X3_TITULO
	'Tp. Comissão'															, ; //X3_TITSPA
	'Tp. Comissão'															, ; //X3_TITENG
	'Tipo de Comissão Qualy'												, ; //X3_DESCRIC
	'Tipo de Comissão Qualy'												, ; //X3_DESCSPA
	'Tipo de Comissão Qualy'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'01=Clliente;02=Produto;03=Vendedor;04=Zerada;05=Camapanha;06=Outros'		, ; //X3_CBOX
	'01=Clliente;02=Produto;03=Vendedor;04=Zerada;05=Camapanha;06=Outros'		, ; //X3_CBOXSPA
	'01=Clliente;02=Produto;03=Vendedor;04=Zerada;05=Camapanha;06=Outros'		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SC6
//
aAdd( aSX3, { ;
	'SC6'																	, ; //X3_ARQUIVO
	'C0'																	, ; //X3_ORDEM
	'C6_XDTRVC'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dta.Rev.Com.'															, ; //X3_TITULO
	'Dta.Rev.Com.'															, ; //X3_TITSPA
	'Dta.Rev.Com.'															, ; //X3_TITENG
	'Data Revisão da Comissão'												, ; //X3_DESCRIC
	'Data Revisão da Comissão'												, ; //X3_DESCSPA
	'Data Revisão da Comissão'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'IF(INCLUI,DDATABASE,CTOD(""))'											, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC6'																	, ; //X3_ARQUIVO
	'C1'																	, ; //X3_ORDEM
	'C6_XREVCOM'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Rev.Com.'															, ; //X3_TITULO
	'Cod.Rev.Com.'															, ; //X3_TITSPA
	'Cod.Rev.Com.'															, ; //X3_TITENG
	'Codigo Revisão Comissão'												, ; //X3_DESCRIC
	'Codigo Revisão Comissão'												, ; //X3_DESCSPA
	'Codigo Revisão Comissão'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC6'																	, ; //X3_ARQUIVO
	'C2'																	, ; //X3_ORDEM
	'C6_XTPCOM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tp. Comissão'															, ; //X3_TITULO
	'Tp. Comissão'															, ; //X3_TITSPA
	'Tp. Comissão'															, ; //X3_TITENG
	'Tipo de Comissão Qualy'												, ; //X3_DESCRIC
	'Tipo de Comissão Qualy'												, ; //X3_DESCSPA
	'Tipo de Comissão Qualy'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'01=Clliente;02=Produto;03=Vendedor;04=Zerada;05=Camapanha;06=Outros'		, ; //X3_CBOX
	'01=Clliente;02=Produto;03=Vendedor;04=Zerada;05=Camapanha;06=Outros'		, ; //X3_CBOXSPA
	'01=Clliente;02=Produto;03=Vendedor;04=Zerada;05=Camapanha;06=Outros'		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SC9
//
aAdd( aSX3, { ;
	'SC9'																	, ; //X3_ARQUIVO
	'90'																	, ; //X3_ORDEM
	'C9_XNUMIND'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Indicador'																, ; //X3_TITULO
	'Indicador'																, ; //X3_TITSPA
	'Indicador'																, ; //X3_TITENG
	'Indicador'																, ; //X3_DESCRIC
	'Indicador'																, ; //X3_DESCSPA
	'Indicador'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Primeira;2=Segunda'													, ; //X3_CBOX
	'1=Primeira;2=Segunda'													, ; //X3_CBOXSPA
	'1=Primeira;2=Segunda'													, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SCJ
//
aAdd( aSX3, { ;
	'SCJ'																	, ; //X3_ARQUIVO
	'61'																	, ; //X3_ORDEM
	'CJ_XTPCOM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tp. Comissão'															, ; //X3_TITULO
	'Tp. Comissão'															, ; //X3_TITSPA
	'Tp. Comissão'															, ; //X3_TITENG
	'Tipo de Comissão Qualy'												, ; //X3_DESCRIC
	'Tipo de Comissão Qualy'												, ; //X3_DESCSPA
	'Tipo de Comissão Qualy'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'01=Clliente;02=Produto;03=Vendedor;04=Zerada;05=Camapanha;06=Outros'		, ; //X3_CBOX
	'01=Clliente;02=Produto;03=Vendedor;04=Zerada;05=Camapanha;06=Outros'		, ; //X3_CBOXSPA
	'01=Clliente;02=Produto;03=Vendedor;04=Zerada;05=Camapanha;06=Outros'		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SCK
//
aAdd( aSX3, { ;
	'SCK'																	, ; //X3_ARQUIVO
	'51'																	, ; //X3_ORDEM
	'CK_XDTRVC'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dta.Rev.Com.'															, ; //X3_TITULO
	'Dta.Rev.Com.'															, ; //X3_TITSPA
	'Dta.Rev.Com.'															, ; //X3_TITENG
	'Dta Revcisão de Comissão'												, ; //X3_DESCRIC
	'Dta Revcisão de Comissão'												, ; //X3_DESCSPA
	'Dta Revcisão de Comissão'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'DDATABASE'																, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SCK'																	, ; //X3_ARQUIVO
	'52'																	, ; //X3_ORDEM
	'CK_XREVCOM'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Rev.Com.'															, ; //X3_TITULO
	'Cod.Rev.Com.'															, ; //X3_TITSPA
	'Cod.Rev.Com.'															, ; //X3_TITENG
	'Codigo Revisão Comissão'												, ; //X3_DESCRIC
	'Codigo Revisão Comissão'												, ; //X3_DESCSPA
	'Codigo Revisão Comissão'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SCK'																	, ; //X3_ARQUIVO
	'53'																	, ; //X3_ORDEM
	'CK_XTPCOM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tp. Comissão'															, ; //X3_TITULO
	'Tp. Comissão'															, ; //X3_TITSPA
	'Tp. Comissão'															, ; //X3_TITENG
	'Tipo de Comissão Qualy'												, ; //X3_DESCRIC
	'Tipo de Comissão Qualy'												, ; //X3_DESCSPA
	'Tipo de Comissão Qualy'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'01=Clliente;02=Produto;03=Vendedor;04=Zerada;05=Camapanha;06=Outros'		, ; //X3_CBOX
	'01=Clliente;02=Produto;03=Vendedor;04=Zerada;05=Camapanha;06=Outros'		, ; //X3_CBOXSPA
	'01=Clliente;02=Produto;03=Vendedor;04=Zerada;05=Camapanha;06=Outros'		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SCT
//
aAdd( aSX3, { ;
	'SCT'																	, ; //X3_ARQUIVO
	'19'																	, ; //X3_ORDEM
	'CT_XLTVOL'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Volume/Litro'															, ; //X3_TITULO
	'Volume/Litro'															, ; //X3_TITSPA
	'Volume/Litro'															, ; //X3_TITENG
	'Meta de Volume e LItro'												, ; //X3_DESCRIC
	'Meta de Volume e LItro'												, ; //X3_DESCSPA
	'Meta de Volume e LItro'												, ; //X3_DESCENG
	'@E 99,999,999,999.9999'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SD1
//
aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'D1_DESCR'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	50																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Desc.Produto'															, ; //X3_TITULO
	'Desc.Produto'															, ; //X3_TITSPA
	'Desc.Produto'															, ; //X3_TITENG
	'Descrição do Produto'													, ; //X3_DESCRIC
	'Descrição do Produto'													, ; //X3_DESCSPA
	'Descrição do Produto'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'IF(!INCLUI,POSICIONE("SB1",1,XFILIAL("SB1")+SD1->D1_COD,"B1_DESC")," ")'	, ; //X3_RELACAO
	''																		, ; //X3_F3
	4																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Texto()'																, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'22'																	, ; //X3_ORDEM
	'D1_OBSERV'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	150																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Observação'															, ; //X3_TITULO
	'Observação'															, ; //X3_TITSPA
	'Observação'															, ; //X3_TITENG
	'Observação'															, ; //X3_DESCRIC
	'Observação'															, ; //X3_DESCSPA
	'Observação'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'FA'																	, ; //X3_ORDEM
	'D1_QTDCOF'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	18																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Qtde Conferi'															, ; //X3_TITULO
	'Qtde Conferi'															, ; //X3_TITSPA
	'Qtde Conferi'															, ; //X3_TITENG
	'Quantidade Conferida'													, ; //X3_DESCRIC
	'Quantidade Conferida'													, ; //X3_DESCSPA
	'Quantidade Conferida'													, ; //X3_DESCENG
	'@E 999,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'FB'																	, ; //X3_ORDEM
	'D1_USRCONF'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Usuario Conf'															, ; //X3_TITULO
	'Usuario Conf'															, ; //X3_TITSPA
	'Usuario Conf'															, ; //X3_TITENG
	'Usuario Conferencia'													, ; //X3_DESCRIC
	'Usuario Conferencia'													, ; //X3_DESCSPA
	'Usuario Conferencia'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'FC'																	, ; //X3_ORDEM
	'D1_DTTRANS'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Transf.'															, ; //X3_TITULO
	'Data Transf.'															, ; //X3_TITSPA
	'Data Transf.'															, ; //X3_TITENG
	'Data Transferencia'													, ; //X3_DESCRIC
	'Data Transferencia'													, ; //X3_DESCSPA
	'Data Transferencia'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'FD'																	, ; //X3_ORDEM
	'D1_U_IDRNC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Codigo RNC'															, ; //X3_TITULO
	'Codigo RNC'															, ; //X3_TITSPA
	'Codigo RNC'															, ; //X3_TITENG
	'Codigo RNC'															, ; //X3_DESCRIC
	'Codigo RNC'															, ; //X3_DESCSPA
	'Codigo RNC'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'FE'																	, ; //X3_ORDEM
	'D1_U_ITRNC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Item RNC'																, ; //X3_TITULO
	'Item RNC'																, ; //X3_TITSPA
	'Item RNC'																, ; //X3_TITENG
	'Item RNC'																, ; //X3_DESCRIC
	'Item RNC'																, ; //X3_DESCSPA
	'Item RNC'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'G1'																	, ; //X3_ORDEM
	'D1_XUNEXP'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Un.Med.Exped'															, ; //X3_TITULO
	'Un.Med.Exped'															, ; //X3_TITSPA
	'Un.Med.Exped'															, ; //X3_TITENG
	'Unidade Medida Expedição'												, ; //X3_DESCRIC
	'Unidade Medida Expedição'												, ; //X3_DESCSPA
	'Unidade Medida Expedição'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SAH'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'G1'																	, ; //X3_ORDEM
	'D1_XCLEXP'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Quant.Ml.Exp'															, ; //X3_TITULO
	'Quant.Ml.Exp'															, ; //X3_TITSPA
	'Quant.Ml.Exp'															, ; //X3_TITENG
	'Qtde Multiplos Embalagem'												, ; //X3_DESCRIC
	'Qtde Multiplos Embalagem'												, ; //X3_DESCSPA
	'Qtde Multiplos Embalagem'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'G1'																	, ; //X3_ORDEM
	'D1_XQTDVOL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Calv.Qtd.Vol'															, ; //X3_TITULO
	'Calv.Qtd.Vol'															, ; //X3_TITSPA
	'Calv.Qtd.Vol'															, ; //X3_TITENG
	'Calculo Qtde Volume'													, ; //X3_DESCRIC
	'Calculo Qtde Volume'													, ; //X3_DESCSPA
	'Calculo Qtde Volume'													, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'G1'																	, ; //X3_ORDEM
	'D1_XDIFVOL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Calc.Dif.Vol'															, ; //X3_TITULO
	'Calc.Dif.Vol'															, ; //X3_TITSPA
	'Calc.Dif.Vol'															, ; //X3_TITENG
	'Calculo Diferença Volume'												, ; //X3_DESCRIC
	'Calculo Diferença Volume'												, ; //X3_DESCSPA
	'Calculo Diferença Volume'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'G1'																	, ; //X3_ORDEM
	'D1_XMINEMB'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Qtde.Min.Emb'															, ; //X3_TITULO
	'Qtde.Min.Emb'															, ; //X3_TITSPA
	'Qtde.Min.Emb'															, ; //X3_TITENG
	'Quantidade Min. Embalagem'												, ; //X3_DESCRIC
	'Quantidade Min. Embalagem'												, ; //X3_DESCSPA
	'Quantidade Min. Embalagem'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'G1'																	, ; //X3_ORDEM
	'D1_XPESBUT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Calc.Pes.Bru'															, ; //X3_TITULO
	'Calc.Pes.Bru'															, ; //X3_TITSPA
	'Calc.Pes.Bru'															, ; //X3_TITENG
	'Calculo do Peso Bruto'													, ; //X3_DESCRIC
	'Calculo do Peso Bruto'													, ; //X3_DESCSPA
	'Calculo do Peso Bruto'													, ; //X3_DESCENG
	'@E 99,999,999,999.9999'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'G1'																	, ; //X3_ORDEM
	'D1_XPESLIQ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Calc.Pes.Liq'															, ; //X3_TITULO
	'Calc.Pes.Liq'															, ; //X3_TITSPA
	'Calc.Pes.Liq'															, ; //X3_TITENG
	'Calculo do Peso Liquido'												, ; //X3_DESCRIC
	'Calculo do Peso Liquido'												, ; //X3_DESCSPA
	'Calculo do Peso Liquido'												, ; //X3_DESCENG
	'@E 99,999,999,999.9999'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'G1'																	, ; //X3_ORDEM
	'D1_XPLIQ'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Peso.Liq.Cad'															, ; //X3_TITULO
	'Peso.Liq.Cad'															, ; //X3_TITSPA
	'Peso.Liq.Cad'															, ; //X3_TITENG
	'Peso Liquido do Cadastro'												, ; //X3_DESCRIC
	'Peso Liquido do Cadastro'												, ; //X3_DESCSPA
	'Peso Liquido do Cadastro'												, ; //X3_DESCENG
	'@E 99,999,999,999.9999'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'G2'																	, ; //X3_ORDEM
	'D1_XPBRU'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Peso.Bru.Cad'															, ; //X3_TITULO
	'Peso.Bru.Cad'															, ; //X3_TITSPA
	'Peso.Bru.Cad'															, ; //X3_TITENG
	'Peso Bruto do Cadastro'												, ; //X3_DESCRIC
	'Peso Bruto do Cadastro'												, ; //X3_DESCSPA
	'Peso Bruto do Cadastro'												, ; //X3_DESCENG
	'@E 99,999,999,999.9999'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'G4'																	, ; //X3_ORDEM
	'D1_XOPER'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Oper.'															, ; //X3_TITULO
	'Cod. Oper.'															, ; //X3_TITSPA
	'Cod. Oper.'															, ; //X3_TITENG
	'Cod. Oper.'															, ; //X3_DESCRIC
	'Cod. Oper.'															, ; //X3_DESCSPA
	'Cod. Oper.'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'G5'																	, ; //X3_ORDEM
	'D1_FATAVA'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Fator Aval.'															, ; //X3_TITULO
	'Fator Aval.'															, ; //X3_TITSPA
	'Fator Aval.'															, ; //X3_TITENG
	'Fator de Avaliacao'													, ; //X3_DESCRIC
	'Fator de Avaliacao'													, ; //X3_DESCSPA
	'Fator de Avaliacao'													, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'G6'																	, ; //X3_ORDEM
	'D1_EUWFID'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Id WF'																	, ; //X3_TITULO
	'Id WF'																	, ; //X3_TITSPA
	'Id WF'																	, ; //X3_TITENG
	'Id WF'																	, ; //X3_DESCRIC
	'Id WF'																	, ; //X3_DESCSPA
	'Id WF'																	, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'.F.'																	, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SD2
//
aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'FA'																	, ; //X3_ORDEM
	'D2_XDTRVC'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dta.Rev.Com.'															, ; //X3_TITULO
	'Dta.Rev.Com.'															, ; //X3_TITSPA
	'Dta.Rev.Com.'															, ; //X3_TITENG
	'Data Revisao Comissão'													, ; //X3_DESCRIC
	'Data Revisao Comissão'													, ; //X3_DESCSPA
	'Data Revisao Comissão'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'FB'																	, ; //X3_ORDEM
	'D2_XREVCOM'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Rev.Com.'															, ; //X3_TITULO
	'Cod.Rev.Com.'															, ; //X3_TITSPA
	'Cod.Rev.Com.'															, ; //X3_TITENG
	'Codigo Revisão Comissão'												, ; //X3_DESCRIC
	'Codigo Revisão Comissão'												, ; //X3_DESCSPA
	'Codigo Revisão Comissão'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'FG'																	, ; //X3_ORDEM
	'D2_XTPCOM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tp. Comissão'															, ; //X3_TITULO
	'Tp. Comissão'															, ; //X3_TITSPA
	'Tp. Comissão'															, ; //X3_TITENG
	'Tipo de Comissão Qualy'												, ; //X3_DESCRIC
	'Tipo de Comissão Qualy'												, ; //X3_DESCSPA
	'Tipo de Comissão Qualy'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'01=Clliente;02=Produto;03=Vendedor;04=Zerada;05=Camapanha;06=Outros'		, ; //X3_CBOX
	'01=Clliente;02=Produto;03=Vendedor;04=Zerada;05=Camapanha;06=Outros'		, ; //X3_CBOXSPA
	'01=Clliente;02=Produto;03=Vendedor;04=Zerada;05=Camapanha;06=Outros'		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'FH'																	, ; //X3_ORDEM
	'D2_XNUMIND'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Indicador'																, ; //X3_TITULO
	'Indicador'																, ; //X3_TITSPA
	'Indicador'																, ; //X3_TITENG
	'Indicador'																, ; //X3_DESCRIC
	'Indicador'																, ; //X3_DESCSPA
	'Indicador'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Primeira;2=Segunda'													, ; //X3_CBOX
	'1=Primeira;2=Segunda'													, ; //X3_CBOXSPA
	'1=Primeira;2=Segunda'													, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SE1
//
aAdd( aSX3, { ;
	'SE1'																	, ; //X3_ARQUIVO
	'E8'																	, ; //X3_ORDEM
	'E1_XDEVCOM'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dsc.Com.S/N?'															, ; //X3_TITULO
	'Dsc.Com.S/N?'															, ; //X3_TITSPA
	'Dsc.Com.S/N?'															, ; //X3_TITENG
	'Desconto da Comissão S/N?'												, ; //X3_DESCRIC
	'Desconto da Comissão S/N?'												, ; //X3_DESCSPA
	'Desconto da Comissão S/N?'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"N"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'S=Sim;Não'																, ; //X3_CBOX
	'S=Sim;Não'																, ; //X3_CBOXSPA
	'S=Sim;Não'																, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SE1'																	, ; //X3_ARQUIVO
	'E9'																	, ; //X3_ORDEM
	'E1_XTIPO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo Ocorr.'															, ; //X3_TITULO
	'Tipo Ocorr.'															, ; //X3_TITSPA
	'Tipo Ocorr.'															, ; //X3_TITENG
	'Tipo Ocorrencia RNC!'													, ; //X3_DESCRIC
	'Tipo Ocorrencia RNC!'													, ; //X3_DESCSPA
	'Tipo Ocorrencia RNC!'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"I"'																	, ; //X3_RELACAO
	'ZZK'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'S'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SE1'																	, ; //X3_ARQUIVO
	'EA'																	, ; //X3_ORDEM
	'E1_XTPCOM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tp. Comissão'															, ; //X3_TITULO
	'Tp. Comissão'															, ; //X3_TITSPA
	'Tp. Comissão'															, ; //X3_TITENG
	'Tipo de Comissão Qualy'												, ; //X3_DESCRIC
	'Tipo de Comissão Qualy'												, ; //X3_DESCSPA
	'Tipo de Comissão Qualy'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'01=Clliente;02=Produto;03=Vendedor;04=Zerada;05=Camapanha;06=Outros'		, ; //X3_CBOX
	'01=Clliente;02=Produto;03=Vendedor;04=Zerada;05=Camapanha;06=Outros'		, ; //X3_CBOXSPA
	'01=Clliente;02=Produto;03=Vendedor;04=Zerada;05=Camapanha;06=Outros'		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SE1'																	, ; //X3_ARQUIVO
	'EB'																	, ; //X3_ORDEM
	'E1_XDESC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Desc. Ocorr.'															, ; //X3_TITULO
	'Desc. Ocorr.'															, ; //X3_TITSPA
	'Desc. Ocorr.'															, ; //X3_TITENG
	'Descrição da Ocorrencia'												, ; //X3_DESCRIC
	'Descrição da Ocorrencia'												, ; //X3_DESCSPA
	'Descrição da Ocorrencia'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"INTERNO"'																, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SE1'																	, ; //X3_ARQUIVO
	'EC'																	, ; //X3_ORDEM
	'E1_XCODRNC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Rnc.Dev.'															, ; //X3_TITULO
	'Cod.Rnc.Dev.'															, ; //X3_TITSPA
	'Cod.Rnc.Dev.'															, ; //X3_TITENG
	'Codigo Rnc Devolução'													, ; //X3_DESCRIC
	'Codigo Rnc Devolução'													, ; //X3_DESCSPA
	'Codigo Rnc Devolução'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SE1'																	, ; //X3_ARQUIVO
	'ED'																	, ; //X3_ORDEM
	'E1_XBASCOM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Comiss.'															, ; //X3_TITULO
	'Base Comiss.'															, ; //X3_TITSPA
	'Base Comiss.'															, ; //X3_TITENG
	'Base de Comissão'														, ; //X3_DESCRIC
	'Base de Comissão'														, ; //X3_DESCSPA
	'Base de Comissão'														, ; //X3_DESCENG
	'@E 9,999,999,999,999.99'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SE3
//
aAdd( aSX3, { ;
	'SE3'																	, ; //X3_ARQUIVO
	'35'																	, ; //X3_ORDEM
	'E3_XTPCOM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tp Comissao'															, ; //X3_TITULO
	'Tp Comissao'															, ; //X3_TITSPA
	'Tp Comissao'															, ; //X3_TITENG
	'Tipo de Comissão'														, ; //X3_DESCRIC
	'Tipo de Comissão'														, ; //X3_DESCSPA
	'Tipo de Comissão'														, ; //X3_DESCENG
	'@1'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'01=Cliente;02=Produto;03=Vendedor;04=Zerada'							, ; //X3_CBOX
	'01=Cliente;02=Produto;03=Vendedor;04=Zerada'							, ; //X3_CBOXSPA
	'01=Cliente;02=Produto;03=Vendedor;04=Zerada'							, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SE3'																	, ; //X3_ARQUIVO
	'36'																	, ; //X3_ORDEM
	'E3_XCODRNC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Rnc.Dev.'															, ; //X3_TITULO
	'Cod.Rnc.Dev.'															, ; //X3_TITSPA
	'Cod.Rnc.Dev.'															, ; //X3_TITENG
	'Codigo Rnc de Devolução'												, ; //X3_DESCRIC
	'Codigo Rnc de Devolução'												, ; //X3_DESCSPA
	'Codigo Rnc de Devolução'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SE5
//
aAdd( aSX3, { ;
	'SE5'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'E5_XDEVCOM'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dsc.Com S/N?'															, ; //X3_TITULO
	'Dsc.Com S/N?'															, ; //X3_TITSPA
	'Dsc.Com S/N?'															, ; //X3_TITENG
	'Desconta Comissão S/N ?'												, ; //X3_DESCRIC
	'Desconta Comissão S/N ?'												, ; //X3_DESCSPA
	'Desconta Comissão S/N ?'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"N"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'S=Sim;N=Não'															, ; //X3_CBOX
	'S=Sim;N=Não'															, ; //X3_CBOXSPA
	'S=Sim;N=Não'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SE5'																	, ; //X3_ARQUIVO
	'9H'																	, ; //X3_ORDEM
	'E5_XCODRNC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Rnc.Dev.'															, ; //X3_TITULO
	'Cod.Rnc.Dev.'															, ; //X3_TITSPA
	'Cod.Rnc.Dev.'															, ; //X3_TITENG
	'Codigo Rnc de Devolução'												, ; //X3_DESCRIC
	'Codigo Rnc de Devolução'												, ; //X3_DESCSPA
	'Codigo Rnc de Devolução'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SED
//
aAdd( aSX3, { ;
	'SED'																	, ; //X3_ARQUIVO
	'9K'																	, ; //X3_ORDEM
	'ED_XNEWNAT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nova Naturez'															, ; //X3_TITULO
	'Nova Naturez'															, ; //X3_TITSPA
	'Nova Naturez'															, ; //X3_TITENG
	'Nova Naureza'															, ; //X3_DESCRIC
	'Nova Naureza'															, ; //X3_DESCSPA
	'Nova Naureza'															, ; //X3_DESCENG
	'@R 99.99.999'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SF1
//
aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'F1_XNOME'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	50																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome'																	, ; //X3_TITULO
	'Nome'																	, ; //X3_TITSPA
	'Nome'																	, ; //X3_TITENG
	'Nome do Fornec/Cliente'												, ; //X3_DESCRIC
	'Nome do Fornec/Cliente'												, ; //X3_DESCSPA
	'Nome do Fornec/Cliente'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	'IF(SF1->F1_TIPO$"B|D",FORMULA("996"),FORMULA("995"))'					, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'BR'																	, ; //X3_ORDEM
	'F1_COMPFT'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Conhec Frete'															, ; //X3_TITULO
	'Conhec Frete'															, ; //X3_TITSPA
	'Conhec Frete'															, ; //X3_TITENG
	'Conhecimento de Frete'													, ; //X3_DESCRIC
	'Conhecimento de Frete'													, ; //X3_DESCSPA
	'Conhecimento de Frete'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'BS'																	, ; //X3_ORDEM
	'F1_TICPESA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ticket Pesag'															, ; //X3_TITULO
	'Ticket Pesag'															, ; //X3_TITSPA
	'Ticket Pesag'															, ; //X3_TITENG
	'Ticket de Pesagem'														, ; //X3_DESCRIC
	'Ticket de Pesagem'														, ; //X3_DESCSPA
	'Ticket de Pesagem'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'BT'																	, ; //X3_ORDEM
	'F1_FORNTRP'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Forn. Transp'															, ; //X3_TITULO
	'Forn. Transp'															, ; //X3_TITSPA
	'Forn. Transp'															, ; //X3_TITENG
	'Fornecedor de Transporte'												, ; //X3_DESCRIC
	'Fornecedor de Transporte'												, ; //X3_DESCSPA
	'Fornecedor de Transporte'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'BU'																	, ; //X3_ORDEM
	'F1_VALFRT'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Conhec'															, ; //X3_TITULO
	'Valor Conhec'															, ; //X3_TITSPA
	'Valor Conhec'															, ; //X3_TITENG
	'Valor da NF de Conhecimen'												, ; //X3_DESCRIC
	'Valor da NF de Conhecimen'												, ; //X3_DESCSPA
	'Valor da NF de Conhecimen'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'C3'																	, ; //X3_ORDEM
	'F1_XUSERI'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Inc.Por'																, ; //X3_TITULO
	'Inc.Por'																, ; //X3_TITSPA
	'Inc.Por'																, ; //X3_TITENG
	'Incluido Por'															, ; //X3_DESCRIC
	'Incluido Por'															, ; //X3_DESCSPA
	'Incluido Por'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x         x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x     x'														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	'FWLeUserLg("F1_USERLGI")+"-"+FWLeUserLg("F1_USERLGI",2)'				, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'C4'																	, ; //X3_ORDEM
	'F1_EUWFID'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Id WF'																	, ; //X3_TITULO
	'Id WF'																	, ; //X3_TITSPA
	'Id WF'																	, ; //X3_TITENG
	'Id WF'																	, ; //X3_DESCRIC
	'Id WF'																	, ; //X3_DESCSPA
	'Id WF'																	, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'.F.'																	, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SUI
//
aAdd( aSX3, { ;
	'SUI'																	, ; //X3_ARQUIVO
	'22'																	, ; //X3_ORDEM
	'UI_DOCDEV'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Doc.Dev.Cli.'															, ; //X3_TITULO
	'Doc.Dev.Cli.'															, ; //X3_TITSPA
	'Doc.Dev.Cli.'															, ; //X3_TITENG
	'Doc. Devolução Cliente'												, ; //X3_DESCRIC
	'Doc. Devolução Cliente'												, ; //X3_DESCSPA
	'Doc. Devolução Cliente'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SUI'																	, ; //X3_ARQUIVO
	'54'																	, ; //X3_ORDEM
	'UI_CARGA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Carga Exped.'															, ; //X3_TITULO
	'Carga Exped.'															, ; //X3_TITSPA
	'Carga Exped.'															, ; //X3_TITENG
	'Codigo carga da expedição'												, ; //X3_DESCRIC
	'Codigo carga da expedição'												, ; //X3_DESCSPA
	'Codigo carga da expedição'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SZF'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SUI'																	, ; //X3_ARQUIVO
	'55'																	, ; //X3_ORDEM
	'UI_DTCARGA'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Carga'															, ; //X3_TITULO
	'Data Carga'															, ; //X3_TITSPA
	'Data Carga'															, ; //X3_TITENG
	'Data Carga Expedição'													, ; //X3_DESCRIC
	'Data Carga Expedição'													, ; //X3_DESCSPA
	'Data Carga Expedição'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SUI'																	, ; //X3_ARQUIVO
	'56'																	, ; //X3_ORDEM
	'UI_OCDESC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Desc.Ocorre.'															, ; //X3_TITULO
	'Desc.Ocorre.'															, ; //X3_TITSPA
	'Desc.Ocorre.'															, ; //X3_TITENG
	'Desc. Ocorrencia'														, ; //X3_DESCRIC
	'Desc. Ocorrencia'														, ; //X3_DESCSPA
	'Desc. Ocorrencia'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SUI'																	, ; //X3_ARQUIVO
	'57'																	, ; //X3_ORDEM
	'UI_CAUTEC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Causa Tec.'															, ; //X3_TITULO
	'Causa Tec.'															, ; //X3_TITSPA
	'Causa Tec.'															, ; //X3_TITENG
	'Causa Tecnica'															, ; //X3_DESCRIC
	'Causa Tecnica'															, ; //X3_DESCSPA
	'Causa Tecnica'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'ZZJ'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'IF(M->UI_MOTDEVO=="T",.T.,.F.)'										, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'S'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SUI'																	, ; //X3_ARQUIVO
	'58'																	, ; //X3_ORDEM
	'UI_CAUDSC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Desc.Tecnica'															, ; //X3_TITULO
	'Desc.Tecnica'															, ; //X3_TITSPA
	'Desc.Tecnica'															, ; //X3_TITENG
	'Desc. Tecnica'															, ; //X3_DESCRIC
	'Desc. Tecnica'															, ; //X3_DESCSPA
	'Desc. Tecnica'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SUI'																	, ; //X3_ARQUIVO
	'59'																	, ; //X3_ORDEM
	'UI_VEND'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Vendedor'															, ; //X3_TITULO
	'Cod.Vendedor'															, ; //X3_TITSPA
	'Cod.Vendedor'															, ; //X3_TITENG
	'Codigo do vendedor'													, ; //X3_DESCRIC
	'Codigo do vendedor'													, ; //X3_DESCSPA
	'Codigo do vendedor'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SA3'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'S'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SUI'																	, ; //X3_ARQUIVO
	'60'																	, ; //X3_ORDEM
	'UI_DSCVEN'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	40																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome Vend.'															, ; //X3_TITULO
	'Nome Vend.'															, ; //X3_TITSPA
	'Nome Vend.'															, ; //X3_TITENG
	'Nome do vendedor'														, ; //X3_DESCRIC
	'Nome do vendedor'														, ; //X3_DESCSPA
	'Nome do vendedor'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SUI'																	, ; //X3_ARQUIVO
	'61'																	, ; //X3_ORDEM
	'UI_TRANSP'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Transp.'															, ; //X3_TITULO
	'Cod. Transp.'															, ; //X3_TITSPA
	'Cod. Transp.'															, ; //X3_TITENG
	'Codigo da Transportadora'												, ; //X3_DESCRIC
	'Codigo da Transportadora'												, ; //X3_DESCSPA
	'Codigo da Transportadora'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SUI'																	, ; //X3_ARQUIVO
	'62'																	, ; //X3_ORDEM
	'UI_DSCTRAN'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	40																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome Transp.'															, ; //X3_TITULO
	'Nome Transp.'															, ; //X3_TITSPA
	'Nome Transp.'															, ; //X3_TITENG
	'Nome Transportadora'													, ; //X3_DESCRIC
	'Nome Transportadora'													, ; //X3_DESCSPA
	'Nome Transportadora'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SUI'																	, ; //X3_ARQUIVO
	'63'																	, ; //X3_ORDEM
	'UI_XUSER'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome Colab.'															, ; //X3_TITULO
	'Nome Colab.'															, ; //X3_TITSPA
	'Nome Colab.'															, ; //X3_TITENG
	'Nome Colaborador'														, ; //X3_DESCRIC
	'Nome Colaborador'														, ; //X3_DESCSPA
	'Nome Colaborador'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SUI'																	, ; //X3_ARQUIVO
	'64'																	, ; //X3_ORDEM
	'UI_DTFIM'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Temino'															, ; //X3_TITULO
	'Data Temino'															, ; //X3_TITSPA
	'Data Temino'															, ; //X3_TITENG
	'Data do Temino'														, ; //X3_DESCRIC
	'Data do Temino'														, ; //X3_DESCSPA
	'Data do Temino'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SZD
//
aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZD_FILIAL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal del Sistema'													, ; //X3_DESCSPA
	'System Branch'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	5																		, ; //X3_NIVEL
	''																		, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZD_ITEM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Item'																	, ; //X3_TITULO
	'Item'																	, ; //X3_TITSPA
	'Item'																	, ; //X3_TITENG
	'Item'																	, ; //X3_DESCRIC
	'Item'																	, ; //X3_DESCSPA
	'Item'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	5																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZD_CODANAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cód Analista'															, ; //X3_TITULO
	'Cód Analista'															, ; //X3_TITSPA
	'Cód Analista'															, ; //X3_TITENG
	'Código do Analista'													, ; //X3_DESCRIC
	'Código do Analista'													, ; //X3_DESCSPA
	'Código do Analista'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'ExistCpo("SX5","ZD"+M->ZD_CODANAL)'									, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'ZD'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZD_ANALIS'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Analista'																, ; //X3_TITULO
	'Analista'																, ; //X3_TITSPA
	'Analista'																, ; //X3_TITENG
	'Analista'																, ; //X3_DESCRIC
	'Analista'																, ; //X3_DESCSPA
	'Analista'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZD_OP'																	, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nº Ord.Prod.'															, ; //X3_TITULO
	'Nº Ord.Prod.'															, ; //X3_TITSPA
	'Nº Ord.Prod.'															, ; //X3_TITENG
	'Numero Ordem de Produção'												, ; //X3_DESCRIC
	'Numero Ordem de Produção'												, ; //X3_DESCSPA
	'Numero Ordem de Produção'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SC2'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'S'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'ZD_DTATU'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Atualiz'															, ; //X3_TITULO
	'Fch Actualiz'															, ; //X3_TITSPA
	'Updating Dt.'															, ; //X3_TITENG
	'Data de Atualizacao'													, ; //X3_DESCRIC
	'Fecha de Actualizacion'												, ; //X3_DESCSPA
	'Updating Date'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x     x'														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'ZD_LOTE'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Lote OP'																, ; //X3_TITULO
	'Lote OP'																, ; //X3_TITSPA
	'Lote OP'																, ; //X3_TITENG
	'Lote OP'																, ; //X3_DESCRIC
	'Lote OP'																, ; //X3_DESCSPA
	'Lote OP'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	"Vazio() .Or. ExistChav('SC2',M->ZD_LOTE)"								, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'ZD_DATA'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Analise'															, ; //X3_TITULO
	'Data Analise'															, ; //X3_TITSPA
	'Data Analise'															, ; //X3_TITENG
	'Data da análise'														, ; //X3_DESCRIC
	'Data da análise'														, ; //X3_DESCSPA
	'Data da análise'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'ZD_PRODUT'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Produto'																, ; //X3_TITULO
	'Producto'																, ; //X3_TITSPA
	'Product'																, ; //X3_TITENG
	'Codigo do Produto'														, ; //X3_DESCRIC
	'Codigo del Producto'													, ; //X3_DESCSPA
	'Product Code'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'ExistCpo("SB1")'														, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SB1'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x     x'														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'ZD_DESCRI'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	40																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Descritivo'															, ; //X3_TITULO
	'Descriptivo'															, ; //X3_TITSPA
	'Description'															, ; //X3_TITENG
	'Descritivo do Produto'													, ; //X3_DESCRIC
	'Descripcion del Producto'												, ; //X3_DESCSPA
	'Product Description'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x     x'														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'ZD_ENSAIO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ensaio'																, ; //X3_TITULO
	'Ensaio'																, ; //X3_TITSPA
	'Ensaio'																, ; //X3_TITENG
	'Ensaio'																, ; //X3_DESCRIC
	'Ensaio'																, ; //X3_DESCSPA
	'Ensaio'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'QP1'																	, ; //X3_F3
	5																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'ZD_DENSAI'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	25																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Desc. Ensaio'															, ; //X3_TITULO
	'Desc. Ensaio'															, ; //X3_TITSPA
	'Desc. Ensaio'															, ; //X3_TITENG
	'Descrição do ensaio'													, ; //X3_DESCRIC
	'Descrição do ensaio'													, ; //X3_DESCSPA
	'Descrição do ensaio'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	5																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'ZD_LINF'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	3																		, ; //X3_DECIMAL
	'Lim.Inferior'															, ; //X3_TITULO
	'Lim.Inferior'															, ; //X3_TITSPA
	'Lim.Inferior'															, ; //X3_TITENG
	'Limite inferior'														, ; //X3_DESCRIC
	'Limite inferior'														, ; //X3_DESCSPA
	'Limite inferior'														, ; //X3_DESCENG
	'@E 999,999,999.999'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	5																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'14'																	, ; //X3_ORDEM
	'ZD_LSUP'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	3																		, ; //X3_DECIMAL
	'Lim.Superior'															, ; //X3_TITULO
	'Lim.Superior'															, ; //X3_TITSPA
	'Lim.Superior'															, ; //X3_TITENG
	'Limite superior'														, ; //X3_DESCRIC
	'Limite superior'														, ; //X3_DESCSPA
	'Limite superior'														, ; //X3_DESCENG
	'@E 999,999,999.999'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	5																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'15'																	, ; //X3_ORDEM
	'ZD_RNUM'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	3																		, ; //X3_DECIMAL
	'Result.Numer'															, ; //X3_TITULO
	'Result.Numer'															, ; //X3_TITSPA
	'Result.Numer'															, ; //X3_TITENG
	'Resultado numérico'													, ; //X3_DESCRIC
	'Resultado numérico'													, ; //X3_DESCSPA
	'Resultado numérico'													, ; //X3_DESCENG
	'@E 999,999,999.999'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	5																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'16'																	, ; //X3_ORDEM
	'ZD_RNUMR'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	3																		, ; //X3_DECIMAL
	'Inutilizado'															, ; //X3_TITULO
	'Res Num REAL'															, ; //X3_TITSPA
	'Res Num REAL'															, ; //X3_TITENG
	'Inutilizado'															, ; //X3_DESCRIC
	'Resultado Numerico Real'												, ; //X3_DESCSPA
	'Resultado Numerico Real'												, ; //X3_DESCENG
	'@E 99,999,999,999.999'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	9																		, ; //X3_NIVEL
	'xxxxxx x     x'														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'17'																	, ; //X3_ORDEM
	'ZD_RTEXTP'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	25																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'R.Texto Pad.'															, ; //X3_TITULO
	'R.Texto Pad.'															, ; //X3_TITSPA
	'R.Texto Pad.'															, ; //X3_TITENG
	'Resultado Texto Padrão'												, ; //X3_DESCRIC
	'Resultado Texto Padrão'												, ; //X3_DESCSPA
	'Resultado Texto Padrão'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	5																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'18'																	, ; //X3_ORDEM
	'ZD_RTEXTO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Result.Texto'															, ; //X3_TITULO
	'Result.Texto'															, ; //X3_TITSPA
	'Result.Texto'															, ; //X3_TITENG
	'Resultado Texto'														, ; //X3_DESCRIC
	'Resultado Texto'														, ; //X3_DESCSPA
	'Resultado Texto'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	5																		, ; //X3_NIVEL
	'xxxxxx x     x'														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'C=Conforme;N=Não Conforme'												, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'19'																	, ; //X3_ORDEM
	'ZD_TEXTOR'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Res Txt REAL'															, ; //X3_TITULO
	'Res Txt REAL'															, ; //X3_TITSPA
	'Res Txt REAL'															, ; //X3_TITENG
	'Resultado Texto Real'													, ; //X3_DESCRIC
	'Resultado Texto Real'													, ; //X3_DESCSPA
	'Resultado Texto Real'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	5																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'C=Conforme;N=Não Conforme'												, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'20'																	, ; //X3_ORDEM
	'ZD_LIMITE'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Limite Med'															, ; //X3_TITULO
	'Limite Med'															, ; //X3_TITSPA
	'Limite Med'															, ; //X3_TITENG
	'Limite da medida'														, ; //X3_DESCRIC
	'Limite da medida'														, ; //X3_DESCSPA
	'Limite da medida'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	5																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Intervalo;2=Superior;3=Inferior'										, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'21'																	, ; //X3_ORDEM
	'ZD_STATUS'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status'																, ; //X3_TITULO
	'Status'																, ; //X3_TITSPA
	'Status'																, ; //X3_TITENG
	'Status'																, ; //X3_DESCRIC
	'Status'																, ; //X3_DESCSPA
	'Status'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	5																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'A=Aprovado;R=Reprovado;C=Aprov. Restrição'								, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'22'																	, ; //X3_ORDEM
	'ZD_LI'																	, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Lote Interno'															, ; //X3_TITULO
	'Lote Interno'															, ; //X3_TITSPA
	'Lote Interno'															, ; //X3_TITENG
	'Lote Interno'															, ; //X3_DESCRIC
	'Lote Interno'															, ; //X3_DESCSPA
	'Lote Interno'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SB8SZD'																, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'23'																	, ; //X3_ORDEM
	'ZD_LE'																	, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Lote Externo'															, ; //X3_TITULO
	'Lote Externo'															, ; //X3_TITSPA
	'Lote Externo'															, ; //X3_TITENG
	'Lote Externo'															, ; //X3_DESCRIC
	'Lote Externo'															, ; //X3_DESCSPA
	'Lote Externo'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'24'																	, ; //X3_ORDEM
	'ZD_LTREFER'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	100																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Lote Referen'															, ; //X3_TITULO
	'Lote Referen'															, ; //X3_TITSPA
	'Lote Referen'															, ; //X3_TITENG
	'Lote Referencia'														, ; //X3_DESCRIC
	'Lote Referencia'														, ; //X3_DESCSPA
	'Lote Referencia'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'25'																	, ; //X3_ORDEM
	'ZD_FORN'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Fornecedor'															, ; //X3_TITULO
	'Fornecedor'															, ; //X3_TITSPA
	'Fornecedor'															, ; //X3_TITENG
	'Fornecedor'															, ; //X3_DESCRIC
	'Fornecedor'															, ; //X3_DESCSPA
	'Fornecedor'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SA2'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'26'																	, ; //X3_ORDEM
	'ZD_LJFORN'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Loja'																	, ; //X3_TITULO
	'Loja'																	, ; //X3_TITSPA
	'Loja'																	, ; //X3_TITENG
	'Loja'																	, ; //X3_DESCRIC
	'Loja'																	, ; //X3_DESCSPA
	'Loja'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'27'																	, ; //X3_ORDEM
	'ZD_DTFABR'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt Fabricaçã'															, ; //X3_TITULO
	'Dt Fabricaçã'															, ; //X3_TITSPA
	'Dt Fabricaçã'															, ; //X3_TITENG
	'Data de Fabricação'													, ; //X3_DESCRIC
	'Data de Fabricação'													, ; //X3_DESCSPA
	'Data de Fabricação'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'28'																	, ; //X3_ORDEM
	'ZD_DTVALID'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt Validade'															, ; //X3_TITULO
	'Dt Validade'															, ; //X3_TITSPA
	'Dt Validade'															, ; //X3_TITENG
	'Data de Validade'														, ; //X3_DESCRIC
	'Data de Validade'														, ; //X3_DESCSPA
	'Data de Validade'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'29'																	, ; //X3_ORDEM
	'ZD_USERLGI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	17																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Log de Inclu'															, ; //X3_TITULO
	'Log de Inclu'															, ; //X3_TITSPA
	'Log de Inclu'															, ; //X3_TITENG
	'Log de Inclusao'														, ; //X3_DESCRIC
	'Log de Inclusao'														, ; //X3_DESCSPA
	'Log de Inclusao'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	9																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'L'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'30'																	, ; //X3_ORDEM
	'ZD_USERLGA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	17																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Log de Alter'															, ; //X3_TITULO
	'Log de Alter'															, ; //X3_TITSPA
	'Log de Alter'															, ; //X3_TITENG
	'Log de Alteracao'														, ; //X3_DESCRIC
	'Log de Alteracao'														, ; //X3_DESCSPA
	'Log de Alteracao'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	9																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'L'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'31'																	, ; //X3_ORDEM
	'ZD_IMPRES'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Imprimir ?'															, ; //X3_TITULO
	'Imprimir ?'															, ; //X3_TITSPA
	'Imprimir ?'															, ; //X3_TITENG
	'Impressão'																, ; //X3_DESCRIC
	'Impressão'																, ; //X3_DESCSPA
	'Impressão'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	5																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'S=Sim;N=Não'															, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZD'																	, ; //X3_ARQUIVO
	'32'																	, ; //X3_ORDEM
	'ZD_METODO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Metodo'																, ; //X3_TITULO
	'Metodo'																, ; //X3_TITSPA
	'Metodo'																, ; //X3_TITENG
	'Metodo'																, ; //X3_DESCRIC
	'Metodo'																, ; //X3_DESCSPA
	'Metodo'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	5																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela ZZH
//
aAdd( aSX3, { ;
	'ZZH'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZH_COMIS1'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'% Comissão'															, ; //X3_TITULO
	'% Comissão'															, ; //X3_TITSPA
	'% Comissão'															, ; //X3_TITENG
	'% Comissão da Holding'													, ; //X3_DESCRIC
	'% Comissão da Holding'													, ; //X3_DESCSPA
	'% Comissão da Holding'													, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela ZZJ
//
aAdd( aSX3, { ;
	'ZZJ'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZJ_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'XXXXXX X'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZJ'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZJ_COD'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Tec.'																, ; //X3_TITULO
	'Cod. Tec.'																, ; //X3_TITSPA
	'Cod. Tec.'																, ; //X3_TITENG
	'Codigo Tecnico'														, ; //X3_DESCRIC
	'Codigo Tecnico'														, ; //X3_DESCSPA
	'Codigo Tecnico'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZJ'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZJ_DESC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Desc.Tecnica'															, ; //X3_TITULO
	'Desc.Tecnica'															, ; //X3_TITSPA
	'Desc.Tecnica'															, ; //X3_TITENG
	'Descrição Tecnica'														, ; //X3_DESCRIC
	'Descrição Tecnica'														, ; //X3_DESCSPA
	'Descrição Tecnica'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela ZZK
//
aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZZK_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'XXXXXX X'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZZK_TIPO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo Ocorr.'															, ; //X3_TITULO
	'Tipo Ocorr.'															, ; //X3_TITSPA
	'Tipo Ocorr.'															, ; //X3_TITENG
	'Tipo Ocorrencia'														, ; //X3_DESCRIC
	'Tipo Ocorrencia'														, ; //X3_DESCSPA
	'Tipo Ocorrencia'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZZK_DESC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Desc. Ocorr.'															, ; //X3_TITULO
	'Desc. Ocorr.'															, ; //X3_TITSPA
	'Desc. Ocorr.'															, ; //X3_TITENG
	'Descrição da Ocorrencia'												, ; //X3_DESCRIC
	'Descrição da Ocorrencia'												, ; //X3_DESCSPA
	'Descrição da Ocorrencia'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'ZZK'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZZK_DEVCOM'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dsc.Com.S/N?'															, ; //X3_TITULO
	'Dsc.Com.S/N?'															, ; //X3_TITSPA
	'Dsc.Com.S/N?'															, ; //X3_TITENG
	'Desconta Comissão S/N?'												, ; //X3_DESCRIC
	'Desconta Comissão S/N?'												, ; //X3_DESCSPA
	'Desconta Comissão S/N?'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME


//
// Atualizando dicionário
//
nPosArq := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_GRPSXG"  } )
nPosVld := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_VALID"   } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			If aSX3[nI][nPosTam] <> SXG->XG_SIZE
				aSX3[nI][nPosTam] := SXG->XG_SIZE
				AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo] + " NÃO atualizado e foi mantido em [" + ;
				AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
				" por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			dbSkip( -1 )

			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == nPosOrd  // Ordem
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), cSeqAtu ) )

			ElseIf aEstrut[nJ][2] > 0
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ] ) )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		AutoGrLog( "Criado campo " + aSX3[nI][nPosCpo] )

	EndIf

	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3) ..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSIX

Função de processamento da gravação do SIX - Indices

@author UPDATE gerado automaticamente
@since  02/10/22
@obs    Gerado por EXPORDIC - V.7.5.2.2 EFS / Upd. V.5.3.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSIX()
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SIX" + CRLF )

aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , ;
             "DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }

//
// Tabela PAA
//
aAdd( aSIX, { ;
	'PAA'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'PAA_FILIAL+PAA_COD+PAA_CODTAB+PAA_REV'									, ; //CHAVE
	'Cod.Produto+Cont.Interno+Cod. Revisao'									, ; //DESCRICAO
	'Cod.Produto+Cont.Interno+Cod. Revisao'									, ; //DESCSPA
	'Cod.Produto+Cont.Interno+Cod. Revisao'									, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela PAW
//
aAdd( aSIX, { ;
	'PAW'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'PAW_FILIAL+PAW_PEDIDO+PAW_COD+PAW_ITEM+PAW_CODTAB+PAW_REV+PAW_STATUS'		, ; //CHAVE
	'Pedido Vda+Cod. Produto+Item Pedido+Tab. Ped.Vda+Rev.Ped.Vda+Sts Regis'	, ; //DESCRICAO
	'Pedido Vda+Cod. Produto+Item Pedido+Tab. Ped.Vda+Rev.Ped.Vda+Sts Regis'	, ; //DESCSPA
	'Pedido Vda+Cod. Produto+Item Pedido+Tab. Ped.Vda+Rev.Ped.Vda+Sts Regis'	, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela PAY
//
aAdd( aSIX, { ;
	'PAY'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'PAY_FILIAL+PAY_OP+PAY_PROD+PAY_CTRL'									, ; //CHAVE
	'Num.Ord.Prod+Cod. Produto+Contrl. Imp.'								, ; //DESCRICAO
	'Num.Ord.Prod+Cod. Produto+Contrl. Imp.'								, ; //DESCSPA
	'Num.Ord.Prod+Cod. Produto+Contrl. Imp.'								, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAY'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'PAY_FILIAL+PAY_LOTE+PAY_PROD'											, ; //CHAVE
	'Num. Lote+Cod. Produto'												, ; //DESCRICAO
	'Num. Lote+Cod. Produto'												, ; //DESCSPA
	'Num. Lote+Cod. Produto'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela SUI
//
aAdd( aSIX, { ;
	'SUI'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'UI_FILIAL+DTOS(UI_EMISSAO)'											, ; //CHAVE
	'Emissão'																, ; //DESCRICAO
	'Emissão'																, ; //DESCSPA
	'Emissão'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SUI'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'UI_FILIAL+UI_CODCLI'													, ; //CHAVE
	'Cód Cliente'															, ; //DESCRICAO
	'Cód Cliente'															, ; //DESCSPA
	'Cód Cliente'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SUI'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'UI_FILIAL+UI_NOMECLI'													, ; //CHAVE
	'Nome Cliente'															, ; //DESCRICAO
	'Nome Cliente'															, ; //DESCSPA
	'Nome Cliente'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SUI'																	, ; //INDICE
	'5'																		, ; //ORDEM
	'UI_FILIAL+UI_ATEND'													, ; //CHAVE
	'Atendimento'															, ; //DESCRICAO
	'Atendimento'															, ; //DESCSPA
	'Atendimento'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela SZD
//
aAdd( aSIX, { ;
	'SZD'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZD_FILIAL+ZD_PRODUT+ZD_LOTE+ZD_LI+ZD_LE+ZD_ITEM+ZD_ENSAIO'				, ; //CHAVE
	'Produto+Lote+Lote Interno+Lote Externo+Item+Ensaio'					, ; //DESCRICAO
	'Producto+Lote+Lote Interno+Lote Externo+Ensaio'						, ; //DESCSPA
	'Product+Lote+Lote Interno+Lote Externo+Ensaio'							, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SZD'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'ZD_FILIAL+ZD_LOTE+ZD_LI+ZD_LE+ZD_ITEM'									, ; //CHAVE
	'Lote OP+Lote Interno+Lote Externo+Item'								, ; //DESCRICAO
	'Lote OP+Lote Interno+Lote Externo+'									, ; //DESCSPA
	'Lote OP+Lote Interno+Item+Lote Externo+'								, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SZD'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'ZD_FILIAL+ZD_LI+ZD_LOTE+ZD_PRODUT+ZD_ITEM'								, ; //CHAVE
	'Lote Interno+Lote OP+Produto+Item'										, ; //DESCRICAO
	'Lote Interno+Lote OP+Producto+'										, ; //DESCSPA
	'Lote Interno+Lote OP+Producto+'										, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SZD'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'ZD_FILIAL+ZD_LE+ZD_LOTE+ZD_PRODUT+ZD_ITEM'								, ; //CHAVE
	'Lote Externo+Lote OP+Produto+Item'										, ; //DESCRICAO
	'Lote Externo+Lote OP+Producto+Item'									, ; //DESCSPA
	'Lote Externo+Lote OP+Producto+Item'									, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SZD'																	, ; //INDICE
	'5'																		, ; //ORDEM
	'ZD_FILIAL+ZD_LOTE+ZD_LI+ZD_LE+ZD_ENSAIO+ZD_ITEM'						, ; //CHAVE
	'Lote OP+Lote Interno+Lote Externo+Ensaio+Item'							, ; //DESCRICAO
	'Lote OP+Lote Interno+Lote Externo+Ensaio+Item'							, ; //DESCSPA
	'Lote OP+Lote Interno+Lote Externo+Ensaio+Item'							, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela ZZH
//
aAdd( aSIX, { ;
	'ZZH'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZH_COD+ZZH_NOME'														, ; //CHAVE
	'Codigo+Holding'														, ; //DESCRICAO
	'Codigo+Holding'														, ; //DESCSPA
	'Codigo+Holding'														, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela ZZJ
//
aAdd( aSIX, { ;
	'ZZJ'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZJ_FILIAL+ZZJ_COD+ZZJ_DESC'											, ; //CHAVE
	'Cod. Tec.+Desc.Tecnica'												, ; //DESCRICAO
	'Cod. Tec.+Desc.Tecnica'												, ; //DESCSPA
	'Cod. Tec.+Desc.Tecnica'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela ZZK
//
aAdd( aSIX, { ;
	'ZZK'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZK_FILIAL+ZZK_TIPO+ZZK_DESC'											, ; //CHAVE
	'Tipo Ocorr.+Desc. Ocorr.'												, ; //DESCRICAO
	'Tipo Ocorr.+Desc. Ocorr.'												, ; //DESCSPA
	'Tipo Ocorr.+Desc. Ocorr.'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( "SIX" )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

	lAlt    := .F.
	lDelInd := .F.

	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		AutoGrLog( "Índice criado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
	Else
		lAlt := .T.
		aAdd( aArqUpd, aSIX[nI][1] )
		If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "" ) == ;
		    StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
			AutoGrLog( "Chave do índice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
			lDelInd := .T. // Se for alteração precisa apagar o indice do banco
		EndIf
	EndIf

	RecLock( "SIX", !lAlt )
	For nJ := 1 To Len( aSIX[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
		EndIf
	Next nJ
	MsUnLock()

	dbCommit()

	If lDelInd
		TcInternal( 60, RetSqlName( aSIX[nI][1] ) + "|" + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] )
	EndIf

	oProcess:IncRegua2( "Atualizando índices ..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX6

Função de processamento da gravação do SX6 - Parâmetros

@author UPDATE gerado automaticamente
@since  02/10/22
@obs    Gerado por EXPORDIC - V.7.5.2.2 EFS / Upd. V.5.3.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX6()
Local aEstrut   := {}
Local aSX6      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lContinua := .T.
Local lReclock  := .T.
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nTamFil   := Len( SX6->X6_FIL )
Local nTamVar   := Len( SX6->X6_VAR )

AutoGrLog( "Ínicio da Atualização" + " SX6" + CRLF )

aEstrut := { "X6_FIL"    , "X6_VAR"    , "X6_TIPO"   , "X6_DESCRIC", "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1"  , ;
             "X6_DSCSPA1", "X6_DSCENG1", "X6_DESC2"  , "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", ;
             "X6_CONTENG", "X6_PROPRI" , "X6_VALID"  , "X6_INIT"   , "X6_DEFPOR" , "X6_DEFSPA" , "X6_DEFENG" , ;
             "X6_PYME"   }

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XDTETQ'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'parametro criado para permitir alterar data de fab'					, ; //X6_DESCRIC
	'parametro criado para permitir alterar data de fab'					, ; //X6_DSCSPA
	'parametro criado para permitir alterar data de fab'					, ; //X6_DSCENG
	'ricação e data de validade usado no fnte'								, ; //X6_DESC1
	'ricação e data de validade usado no fnte'								, ; //X6_DSCSPA1
	'ricação e data de validade usado no fnte'								, ; //X6_DSCENG1
	'rest002'																, ; //X6_DESC2
	'rest002'																, ; //X6_DSCSPA2
	'rest002'																, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XDV'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Digito verificador da conta na impressão do boleto'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'4'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XDVSOFI'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Digito da conta sofisa usado no boleto'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'3'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_ARMAZ'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Parametro para ser utilizado na rotina QEEXP001,'						, ; //X6_DESCRIC
	'Parametro para ser utilizado na rotina QEEXP001,'						, ; //X6_DSCSPA
	'Parametro para ser utilizado na rotina QEEXP001,'						, ; //X6_DSCENG
	'para tratamnento de quais armazens poserão ser'						, ; //X6_DESC1
	'para tratamnento de quais armazens poserão ser'						, ; //X6_DSCSPA1
	'para tratamnento de quais armazens poserão ser'						, ; //X6_DSCENG1
	'movimentado para inventario'											, ; //X6_DESC2
	'movimentado para inventario'											, ; //X6_DSCSPA2
	'movimentado para inventario'											, ; //X6_DSCENG2
	'06'																	, ; //X6_CONTEUD
	'06'																	, ; //X6_CONTSPA
	'06'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_DIFENV'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'contas de e-mail que serão dispoarados se houver a'					, ; //X6_DESCRIC
	'contas de e-mail que serão dispoarados se houver a'					, ; //X6_DSCSPA
	'contas de e-mail que serão dispoarados se houver a'					, ; //X6_DSCENG
	'alteração no pedido de vendas conforme'								, ; //X6_DESC1
	'alteração no pedido de vendas conforme'								, ; //X6_DSCSPA1
	'alteração no pedido de vendas conforme'								, ; //X6_DSCENG1
	'projeto revisão de comissão'											, ; //X6_DESC2
	'projeto revisão de comissão'											, ; //X6_DSCSPA2
	'projeto revisão de comissão'											, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_DTADESP'															, ; //X6_VAR
	'D'																		, ; //X6_TIPO
	'Utilizado nop fonte QEAPDESP.PRW como data'							, ; //X6_DESCRIC
	'Utilizado nop fonte QEAPDESP.PRW como data'							, ; //X6_DSCSPA
	'Utilizado nop fonte QEAPDESP.PRW como data'							, ; //X6_DSCENG
	'limite para pegar os pedidos em aberto que'							, ; //X6_DESC1
	'limite para pegar os pedidos em aberto que'							, ; //X6_DSCSPA1
	'limite para pegar os pedidos em aberto que'							, ; //X6_DSCENG1
	'estejam liberados e não contem quant. ja entregue'						, ; //X6_DESC2
	'estejam liberados e não contem quant. ja entregue'						, ; //X6_DSCSPA2
	'estejam liberados e não contem quant. ja entregue'						, ; //X6_DSCENG2
	'01/03/2022'															, ; //X6_CONTEUD
	'01/03/2022'															, ; //X6_CONTSPA
	'01/03/2022'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_ESPTLR'																, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Tolerancia para carregar pedido de venda sem bloqu'					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'eio'																	, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'0'																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_FIL440'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Parametro que permite gerar o relacaulo comissão'						, ; //X6_DESCRIC
	'Parametro que permite gerar o relacaulo comissão'						, ; //X6_DSCSPA
	'Parametro que permite gerar o relacaulo comissão'						, ; //X6_DSCENG
	'para QUALY - 0803'														, ; //X6_DESC1
	'para QUALY - 0803'														, ; //X6_DSCSPA1
	'para QUALY - 0803'														, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'0803'																	, ; //X6_CONTEUD
	'0803'																	, ; //X6_CONTSPA
	'0803'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_FILCOM'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Parametro que libera qual filial será tratado o'						, ; //X6_DESCRIC
	'Parametro que libera qual filial será tratado o'						, ; //X6_DSCSPA
	'Parametro que libera qual filial será tratado o'						, ; //X6_DSCENG
	'processo de comissão do projeto QUALY'									, ; //X6_DESC1
	'processo de comissão do projeto QUALY'									, ; //X6_DSCSPA1
	'processo de comissão do projeto QUALY'									, ; //X6_DSCENG1
	'que foi desenvolvido em  23/03/2022'									, ; //X6_DESC2
	'que foi desenvolvido em  23/03/2022'									, ; //X6_DSCSPA2
	'que foi desenvolvido em  23/03/2022'									, ; //X6_DSCENG2
	'0803/0901'																, ; //X6_CONTEUD
	'0803/0901'																, ; //X6_CONTSPA
	'0803/0901'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_GRPPRES'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica os grupos de produtos especiaiis'								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'processo de produtos especiais (OP)'									, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'4000/4001'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_GRUPO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Parametro para tratamento dos volumes a serem'							, ; //X6_DESCRIC
	'Parametro para tratamento dos volumes a serem'							, ; //X6_DSCSPA
	'Parametro para tratamento dos volumes a serem'							, ; //X6_DSCENG
	'considerados no ponto de entrada MTA410T, SF2460I,'					, ; //X6_DESC1
	'considerados no ponto de entrada MTA410T, SF2460I,'					, ; //X6_DSCSPA1
	'considerados no ponto de entrada MTA410T, SF2460I,'					, ; //X6_DSCENG1
	' E ORDEM DE SEPARAÇÃO'													, ; //X6_DESC2
	' E ORDEM DE SEPARAÇÃO'													, ; //X6_DSCSPA2
	' E ORDEM DE SEPARAÇÃO'													, ; //X6_DSCENG2
	'1213'																	, ; //X6_CONTEUD
	'1213'																	, ; //X6_CONTSPA
	'1213'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME



aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_MOVLOT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo de MOvimento interno utilizado na rotina'							, ; //X6_DESCRIC
	'Tipo de MOvimento interno utilizado na rotina'							, ; //X6_DSCSPA
	'Tipo de MOvimento interno utilizado na rotina'							, ; //X6_DSCENG
	'QEBXALOT.prw para baixar inventario'									, ; //X6_DESC1
	'QEBXALOT.prw para baixar inventario'									, ; //X6_DSCSPA1
	'QEBXALOT.prw para baixar inventario'									, ; //X6_DSCENG1
	'do armazen no parametro QE_ARMAZ.'										, ; //X6_DESC2
	'do armazen no parametro QE_ARMAZ.'										, ; //X6_DSCSPA2
	'do armazen no parametro QE_ARMAZ.'										, ; //X6_DSCENG2
	'595'																	, ; //X6_CONTEUD
	'595'																	, ; //X6_CONTSPA
	'595'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_MT240IC'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Parametro utilizado no ponto de entrada MT240TOK'						, ; //X6_DESCRIC
	'e MT241TOK, preenchido com o usuário'									, ; //X6_DSCSPA
	'Parametro utilizado no ponto de entrada MT240TOK'						, ; //X6_DSCENG
	'e MT241TOK, preenchido com o usuário'									, ; //X6_DESC1
	'Parametro utilizado no ponto de entrada MT240TOK'						, ; //X6_DSCSPA1
	'e MT241TOK, preenchido com o usuário'									, ; //X6_DSCENG1
	'valido para rotinas MATA240/MATA241'									, ; //X6_DESC2
	'e MT241TOK, preenchido com o usuário'									, ; //X6_DSCSPA2
	'valido para rotinas MATA240/MATA241'									, ; //X6_DSCENG2
	'Administrador#marilton.silva#Washington.Santos#Luiz.Lima#sandro.melo#Alexsandro.Blasques', ; //X6_CONTEUD
	'Administrador#roberta.prestes#marilton.silva'							, ; //X6_CONTSPA
	'Administrador#roberta.prestes#marilton.silva'							, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_MTA455P'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usado para liberação do uso da opção na rotina'						, ; //X6_DESCRIC
	'Usado para liberação do uso da opção na rotina'						, ; //X6_DSCSPA
	'Usado para liberação do uso da opção na rotina'						, ; //X6_DSCENG
	'MATA455 no ponto de MTA455P, para somente'								, ; //X6_DESC1
	'MATA455 no ponto de MTA455P, para somente'								, ; //X6_DSCSPA1
	'MATA455 no ponto de MTA455P, para somente'								, ; //X6_DSCENG1
	'LIberar o uso conforme usuário no parametro.'							, ; //X6_DESC2
	'LIberar o uso conforme usuário no parametro.'							, ; //X6_DSCSPA2
	'LIberar o uso conforme usuário no parametro.'							, ; //X6_DSCENG2
	'maria.pereira#Administrador'											, ; //X6_CONTEUD
	'maria.pereira#Administrador'											, ; //X6_CONTSPA
	'maria.pereira#Administrador'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_NOMCLI'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Parametro  que contem os codigos dos clientes que'						, ; //X6_DESCRIC
	'Parametro  que contem os codigos dos clientes que'						, ; //X6_DSCSPA
	'Parametro  que contem os codigos dos clientes que'						, ; //X6_DSCENG
	'serão separados por nota fiscal'										, ; //X6_DESC1
	'serão separados por nota fiscal'										, ; //X6_DSCSPA1
	'serão separados por nota fiscal'										, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_PASSWOR'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Senha para uso da rotina ANALISE para ajuste'							, ; //X6_DESCRIC
	'Senha para uso da rotina ANALISE para ajuste'							, ; //X6_DSCSPA
	'Senha para uso da rotina ANALISE para ajuste'							, ; //X6_DSCENG
	'dos estoques.'															, ; //X6_DESC1
	'dos estoques.'															, ; //X6_DSCSPA1
	'dos estoques.'															, ; //X6_DSCENG1
	'Uso restrito do TI'													, ; //X6_DESC2
	'Uso restrito do TI'													, ; //X6_DSCSPA2
	'Uso restrito do TI'													, ; //X6_DSCENG2
	'Euro@0102'																, ; //X6_CONTEUD
	'Euro@0102'																, ; //X6_CONTSPA
	'Euro@0102'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_PRZLOTE'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Tempo que será considerado o prazo do lote na'							, ; //X6_DESCRIC
	'Tempo que será considerado o prazo do lote na'							, ; //X6_DSCSPA
	'Tempo que será considerado o prazo do lote na'							, ; //X6_DSCENG
	'rotina  QEEXPLOT.prw'													, ; //X6_DESC1
	'rotina  QEEXPLOT.prw'													, ; //X6_DSCSPA1
	'rotina  QEEXPLOT.prw'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'10'																	, ; //X6_CONTEUD
	'10'																	, ; //X6_CONTSPA
	'10'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_RECEXP'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Lista de e-mail dos usuários que receberão'							, ; //X6_DESCRIC
	'Lista de e-mail dos usuários que receberão'							, ; //X6_DSCSPA
	'Lista de e-mail dos usuários que receberão'							, ; //X6_DSCENG
	'de inclusão de cadstro de produto novo na'								, ; //X6_DESC1
	'de inclusão de cadstro de produto novo na'								, ; //X6_DSCSPA1
	'de inclusão de cadstro de produto novo na'								, ; //X6_DSCENG1
	'QUALY, ponto de entrada MT010INC.'										, ; //X6_DESC2
	'QUALY, ponto de entrada MT010INC.'										, ; //X6_DSCSPA2
	'QUALY, ponto de entrada MT010INC.'										, ; //X6_DSCENG2
	'jessica.freitas@euroamerican.com.br;maria.pereira@euroamerican.com.br;marilton.silva@euroamerican.com.br;caique.silva@euroamerican.com.br;samuel.oliveira@euroamerican.com.br', ; //X6_CONTEUD
	'jessica.freitas@euroamerican.com.br;eristeu.junior@qualyvinil.com.br;maria.pereira@euroamerican.com.br;marilton.silva@euroamerican.com.br;eulalia.ramos@qualyvinil.com.br', ; //X6_CONTSPA
	'jessica.freitas@euroamerican.com.br;maria.pereira@euroamerican.com.br;marilton.silva@euroamerican.com.br', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_RECPROD'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Lista de e-mail dos usuários que receberão'							, ; //X6_DESCRIC
	'Lista de e-mail dos usuários que receberão'							, ; //X6_DSCSPA
	'Lista de e-mail dos usuários que receberão'							, ; //X6_DSCENG
	'de inclusão de cadstro de produto novo na'								, ; //X6_DESC1
	'de inclusão de cadstro de produto novo na'								, ; //X6_DSCSPA1
	'de inclusão de cadstro de produto novo na'								, ; //X6_DSCENG1
	'QUALY, ponto de entrada MT010INC.'										, ; //X6_DESC2
	'QUALY, ponto de entrada MT010INC.'										, ; //X6_DSCSPA2
	'QUALY, ponto de entrada MT010INC.'										, ; //X6_DSCENG2
	'jessica.freitas@euroamerican.com.br;eristeu.junior@qualyvinil.com.br;maria.pereira@euroamerican.com.br;marilton.silva@euroamerican.com.br;eulalia.ramos@qualyvinil.com.br;caique.silva@euroamerican.com.br;samuel.oliveira@euroamerican.com.br', ; //X6_CONTEUD
	'eulalia.ramos@qualyvinil.com.br;eristeu.junior@qualyvinil.com.br;jessica.freitas@euroamerican.com.br', ; //X6_CONTSPA
	'eulalia.ramos@qualyvinil.com.br;eristeu.junior@qualyvinil.com.br;jessica.freitas@euroamerican.com.br', ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_SENHA'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Senha para o uso da rotina QEEST007, REF.'								, ; //X6_DESCRIC
	'Senha para o uso da rotina QEEST007, REF.'								, ; //X6_DSCSPA
	'Senha para o uso da rotina QEEST007, REF.'								, ; //X6_DSCENG
	'a transferencia do estoque 07 p / Q7'									, ; //X6_DESC1
	'a transferencia do estoque 07 p / Q7'									, ; //X6_DSCSPA1
	'a transferencia do estoque 07 p / Q7'									, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'072021'																, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_TESENT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Parametro utilizado no ponto de entrada A103CUST'						, ; //X6_DESCRIC
	'Parametro utilizado no ponto de entrada A103CUST'						, ; //X6_DSCSPA
	'Parametro utilizado no ponto de entrada A103CUST'						, ; //X6_DSCENG
	'para tratamento de NF  remessa por conta e ordem.'						, ; //X6_DESC1
	'para tratamento de NF  remessa por conta e ordem.'						, ; //X6_DSCSPA1
	'para tratamento de NF  remessa por conta e ordem.'						, ; //X6_DSCENG1
	'para carregar o custo sem pis/dofins.'									, ; //X6_DESC2
	'para carregar o custo sem pis/dofins.'									, ; //X6_DSCSPA2
	'para carregar o custo sem pis/dofins.'									, ; //X6_DSCENG2
	'152'																	, ; //X6_CONTEUD
	'152'																	, ; //X6_CONTSPA
	'152'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_TIPPROD'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo de Produto que podera ser inventariado'							, ; //X6_DESCRIC
	'Tipo de Produto que podera ser inventariado'							, ; //X6_DSCSPA
	'Tipo de Produto que podera ser inventariado'							, ; //X6_DSCENG
	'na rotina QEEXP001.prw'												, ; //X6_DESC1
	'na rotina QEEXP001.prw'												, ; //X6_DSCSPA1
	'na rotina QEEXP001.prw'												, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'PA'																	, ; //X6_CONTEUD
	'PA'																	, ; //X6_CONTSPA
	'PA'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_TROCAUN'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Parametro para ser utilizado na impressão da'							, ; //X6_DESCRIC
	'Parametro para ser utilizado na impressão da'							, ; //X6_DSCSPA
	'Parametro para ser utilizado na impressão da'							, ; //X6_DSCENG
	'ordem de separação na rotina QEORDSEP.PRW'								, ; //X6_DESC1
	'ordem de separação na rotina QEORDSEP.PRW'								, ; //X6_DSCSPA1
	'ordem de separação na rotina QEORDSEP.PRW'								, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'0660.001.35/BD;'														, ; //X6_CONTEUD
	'0660.001.35/BD;'														, ; //X6_CONTSPA
	'0660.001.35/BD;'														, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_XBLQFIM'															, ; //X6_VAR
	'D'																		, ; //X6_TIPO
	'Utilizado para não permitir excluir dentro da tabe'					, ; //X6_DESCRIC
	'Utilizado para não permitir excluir dentro da tabe'					, ; //X6_DSCSPA
	'Utilizado para não permitir excluir dentro da tabe'					, ; //X6_DSCENG
	'la SE3 as comissões até a data no parametro'							, ; //X6_DESC1
	'la SE3 as comissões até a data no parametro'							, ; //X6_DSCSPA1
	'la SE3 as comissões até a data no parametro'							, ; //X6_DSCENG1
	'utilizada na rotina QEFIN440.'											, ; //X6_DESC2
	'utilizada na rotina QEFIN440.'											, ; //X6_DSCSPA2
	'utilizada na rotina QEFIN440.'											, ; //X6_DSCENG2
	'31/03/2022'															, ; //X6_CONTEUD
	'31/03/2022'															, ; //X6_CONTSPA
	'31/03/2022'															, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_XCLIMSG'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Clientes que receberão mensagens de alerta,'							, ; //X6_DESCRIC
	'Clientes que receberão mensagens de alerta,'							, ; //X6_DSCSPA
	'Clientes que receberão mensagens de alerta,'							, ; //X6_DSCENG
	'Projeto Comissões - QUALY'												, ; //X6_DESC1
	'Projeto Comissões - QUALY'												, ; //X6_DSCSPA1
	'Projeto Comissões - QUALY'												, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_XLIBCOM'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuarios que podem fazer a liberação das comissão'						, ; //X6_DESCRIC
	'Usuarios que podem fazer a liberação das comissão'						, ; //X6_DSCSPA
	'Usuarios que podem fazer a liberação das comissão'						, ; //X6_DSCENG
	'que contem valor a maior da ultima revisão para a'						, ; //X6_DESC1
	'que contem valor a maior da ultima revisão para a'						, ; //X6_DSCSPA1
	'que contem valor a maior da ultima revisão para a'						, ; //X6_DSCENG1
	'proxima revisão no MT410LIOK'											, ; //X6_DESC2
	'proxima revisão no MT410LIOK'											, ; //X6_DSCSPA2
	'proxima revisão no MT410LIOK'											, ; //X6_DSCENG2
	'Alessandra.Monea#Thiago.Monea#Caroline.Monea#eulalia.ramos#eristeu.junior'	, ; //X6_CONTEUD
	'Alessandra.Monea#Thiago.Monea#Caroline.Monea#eulalia.ramos#eristeu.junior'	, ; //X6_CONTSPA
	'Alessandra.Monea#Thiago.Monea#Caroline.Monea#eulalia.ramos#eristeu.junior'	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_XLIBMAI'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Parametro para habilitar e desabilitar envio de'						, ; //X6_DESCRIC
	'Parametro para habilitar e desabilitar envio de'						, ; //X6_DSCSPA
	'Parametro para habilitar e desabilitar envio de'						, ; //X6_DSCENG
	'de produtos sem a unidade expedição cadastrada'						, ; //X6_DESC1
	'de produtos sem a unidade expedição cadastrada'						, ; //X6_DSCSPA1
	'de produtos sem a unidade expedição cadastrada'						, ; //X6_DSCENG1
	'no ponto de entrada MT410LIOK.'										, ; //X6_DESC2
	'no ponto de entrada MT410LIOK.'										, ; //X6_DSCSPA2
	'no ponto de entrada MT410LIOK.'										, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_XLIBPES'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Parametro que libera a atualização de peso na'							, ; //X6_DESCRIC
	'Parametro que libera a atualização de peso na'							, ; //X6_DSCSPA
	'Parametro que libera a atualização de peso na'							, ; //X6_DSCENG
	'rotina  QEIUNEXP.'														, ; //X6_DESC1
	'rotina  QEIUNEXP.'														, ; //X6_DSCSPA1
	'rotina  QEIUNEXP.'														, ; //X6_DSCENG1
	'Se acionada deve conter no layout para carga'							, ; //X6_DESC2
	'Se acionada deve conter no layout para carga'							, ; //X6_DSCSPA2
	'Se acionada deve conter no layout para carga'							, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_XMSG'																, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Parametro utilizado na rotina QEFAT001, para o'						, ; //X6_DESCRIC
	'Parametro utilizado na rotina QEFAT001, para o'						, ; //X6_DSCSPA
	'Parametro utilizado na rotina QEFAT001, para o'						, ; //X6_DSCENG
	'numero de controle de mensagens na'									, ; //X6_DESC1
	'numero de controle de mensagens na'									, ; //X6_DSCSPA1
	'numero de controle de mensagens na'									, ; //X6_DSCENG1
	'rotina de alerta'														, ; //X6_DESC2
	'rotina de alerta'														, ; //X6_DSCSPA2
	'rotina de alerta'														, ; //X6_DSCENG2
	'0'																		, ; //X6_CONTEUD
	'0'																		, ; //X6_CONTSPA
	'0'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'QE_XOPER'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'parametro para controlar as operações do C5_XOPER'						, ; //X6_DESCRIC
	'parametro para controlar as operações do C5_XOPER'						, ; //X6_DSCSPA
	'parametro para controlar as operações do C5_XOPER'						, ; //X6_DSCENG
	'para fazer a validação da embalagem minima e a'						, ; //X6_DESC1
	'para fazer a validação da embalagem minima e a'						, ; //X6_DSCSPA1
	'para fazer a validação da embalagem minima e a'						, ; //X6_DSCENG1
	'unidade de expedição do pedido de vendas'								, ; //X6_DESC2
	'unidade de expedição do pedido de vendas'								, ; //X6_DSCSPA2
	'unidade de expedição do pedido de vendas'								, ; //X6_DSCENG2
	'01/06/56'																, ; //X6_CONTEUD
	'01/06/56'																, ; //X6_CONTSPA
	'01/06/56'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0107'																	, ; //X6_FIL
	'QE_ARMAZ'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Parametro para ser utilizado na rotina QEEXP001,'						, ; //X6_DESCRIC
	'Parametro para ser utilizado na rotina QEEXP001,'						, ; //X6_DSCSPA
	'Parametro para ser utilizado na rotina QEEXP001,'						, ; //X6_DSCENG
	'para tratamnento de quais armazens poserão ser'						, ; //X6_DESC1
	'para tratamnento de quais armazens poserão ser'						, ; //X6_DSCSPA1
	'para tratamnento de quais armazens poserão ser'						, ; //X6_DSCENG1
	'movimentado para inventario'											, ; //X6_DESC2
	'movimentado para inventario'											, ; //X6_DSCSPA2
	'movimentado para inventario'											, ; //X6_DSCENG2
	'06'																	, ; //X6_CONTEUD
	'06'																	, ; //X6_CONTSPA
	'06'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0107'																	, ; //X6_FIL
	'QE_MOVLOT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Movimento interno utilizado na rotina QEBXALOT.prw'					, ; //X6_DESCRIC
	'Movimento interno utilizado na rotina QEBXALOT.prw'					, ; //X6_DSCSPA
	'Movimento interno utilizado na rotina QEBXALOT.prw'					, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'595'																	, ; //X6_CONTEUD
	'595'																	, ; //X6_CONTSPA
	'595'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0107'																	, ; //X6_FIL
	'QE_PRZLOTE'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Tempo que será considerado o prazo do lote na'							, ; //X6_DESCRIC
	'Tempo que será considerado o prazo do lote na'							, ; //X6_DSCSPA
	'Tempo que será considerado o prazo do lote na'							, ; //X6_DSCENG
	'rotina  QEEXPLOT.prw'													, ; //X6_DESC1
	'rotina  QEEXPLOT.prw'													, ; //X6_DSCSPA1
	'rotina  QEEXPLOT.prw'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'10'																	, ; //X6_CONTEUD
	'10'																	, ; //X6_CONTSPA
	'10'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'0107'																	, ; //X6_FIL
	'QE_TIPPROD'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo de Produto que podera ser inventariado'							, ; //X6_DESCRIC
	'Tipo de Produto que podera ser inventariado'							, ; //X6_DSCSPA
	'Tipo de Produto que podera ser inventariado'							, ; //X6_DSCENG
	'na rotina QEEXP001.prw'												, ; //X6_DESC1
	'na rotina QEEXP001.prw'												, ; //X6_DSCSPA1
	'na rotina QEEXP001.prw'												, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'PA'																	, ; //X6_CONTEUD
	'PA'																	, ; //X6_CONTSPA
	'PA'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX6 ) )

dbSelectArea( "SX6" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX6 )
	lContinua := .F.
	lReclock  := .F.

	If !SX6->( dbSeek( PadR( aSX6[nI][1], nTamFil ) + PadR( aSX6[nI][2], nTamVar ) ) )
		lContinua := .T.
		lReclock  := .T.
		AutoGrLog( "Foi incluído o parâmetro " + aSX6[nI][1] + aSX6[nI][2] + " Conteúdo [" + AllTrim( aSX6[nI][13] ) + "]" )
	EndIf

	If lContinua
		If !( aSX6[nI][1] $ cAlias )
			cAlias += aSX6[nI][1] + "/"
		EndIf

		RecLock( "SX6", lReclock )
		For nJ := 1 To Len( aSX6[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX6[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
	EndIf

	oProcess:IncRegua2( "Atualizando Arquivos (SX6) ..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX6" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX7

Função de processamento da gravação do SX7 - Gatilhos

@author UPDATE gerado automaticamente
@since  02/10/22
@obs    Gerado por EXPORDIC - V.7.5.2.2 EFS / Upd. V.5.3.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX7()
Local aEstrut   := {}
Local aAreaSX3  := SX3->( GetArea() )
Local aSX7      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX7->X7_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX7" + CRLF )

aEstrut := { "X7_CAMPO", "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN", "X7_TIPO", "X7_SEEK", ;
             "X7_ALIAS", "X7_ORDEM"  , "X7_CHAVE", "X7_PROPRI", "X7_CONDIC" }

//
// Campo UI_CARGA
//
aAdd( aSX7, { ;
	'UI_CARGA'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'SZF->ZF_EMISSAO'														, ; //X7_REGRA
	'UI_DTCARGA'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SZF'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'XFILIAL("SZF")+M->UI_CARGA'											, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo UI_CAUTEC
//
aAdd( aSX7, { ;
	'UI_CAUTEC'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'ZZJ->ZZJ_DESC'															, ; //X7_REGRA
	'UI_CAUDSC'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'ZZJ'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'XFILIAL("ZZJ")+M->UI_CAUTEC'											, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'INCLUI'																} ) //X7_CONDIC

//
// Campo ZD_CODANAL
//
aAdd( aSX7, { ;
	'ZD_CODANAL'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'Tabela("ZD",M->ZD_CODANAL)'											, ; //X7_REGRA
	'ZD_ANALIS'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo ZD_ENSAIO
//
aAdd( aSX7, { ;
	'ZD_ENSAIO'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'QP1->QP1_DESCPO'														, ; //X7_REGRA
	'ZD_DENSAI'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'QP1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'XFILIAL("QP1")+M->ZD_ENSAIO'											, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo ZD_LOTE
//
aAdd( aSX7, { ;
	'ZD_LOTE'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'U_QIPX02getEspec(M->ZD_LOTE)'											, ; //X7_REGRA
	'ZD_PRODUT'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'ZD_LOTE'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'SB1->B1_DESC'															, ; //X7_REGRA
	'ZD_DESCRI'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'XFILIAL("SB1")+U_QIPX02getEspec(M->ZD_LOTE)'							, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'ZD_LOTE'																, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'U_QIPX02Valid(M->ZD_LOTE,2)'											, ; //X7_REGRA
	'ZD_LOTE'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo ZD_OP
//
aAdd( aSX7, { ;
	'ZD_OP'																	, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'PAY->PAY_LOTE'															, ; //X7_REGRA
	'ZD_LOTE'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'PAY'																	, ; //X7_ALIAS
	2																		, ; //X7_ORDEM
	'xFilial("PAY")+SUBSTR(M->ZD_OP,1,6)+M->ZD_PRODUT'						, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'INCLUI'																} ) //X7_CONDIC

aAdd( aSX7, { ;
	'ZD_OP'																	, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'PAY->PAY_DTFAB'														, ; //X7_REGRA
	'ZD_DTFABR'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'PAY'																	, ; //X7_ALIAS
	2																		, ; //X7_ORDEM
	'xFilial("PAY")+SUBSTR(M->ZD_OP,1,6)+M->ZD_PRODUT'						, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'INCLUI'																} ) //X7_CONDIC

aAdd( aSX7, { ;
	'ZD_OP'																	, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'PAY->PAY_DTVAL'														, ; //X7_REGRA
	'ZD_DTVALID'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'PAY'																	, ; //X7_ALIAS
	2																		, ; //X7_ORDEM
	'xFilial("PAY")+SUBSTR(M->ZD_OP,1,6)+M->ZD_PRODUT'						, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'INCLUI'																} ) //X7_CONDIC

//
// Campo ZD_PRODUT
//
aAdd( aSX7, { ;
	'ZD_PRODUT'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'SB1->B1_DESC'															, ; //X7_REGRA
	'ZD_DESCRI'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'XFILIAL("SB1")+M->ZD_PRODUT'											, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo ZD_RNUM
//
aAdd( aSX7, { ;
	'ZD_RNUM'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'IIF(M->ZD_RNUM<ACOLS[N,4].OR.M->ZD_RNUM>ACOLS[N,5],"R","A")'			, ; //X7_REGRA
	'ZD_STATUS'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'ACOLS[N,11] == "1"'													} ) //X7_CONDIC

aAdd( aSX7, { ;
	'ZD_RNUM'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'0'																		, ; //X7_REGRA
	'ZD_RNUM'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'EMPTY(ACOLS[N,4]).AND.EMPTY(ACOLS[N,5])'								} ) //X7_CONDIC

aAdd( aSX7, { ;
	'ZD_RNUM'																, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'IIF(M->ZD_RNUM>ACOLS[N,5],"R","A")'									, ; //X7_REGRA
	'ZD_STATUS'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'ACOLS[N,11] == "2"'													} ) //X7_CONDIC

aAdd( aSX7, { ;
	'ZD_RNUM'																, ; //X7_CAMPO
	'004'																	, ; //X7_SEQUENC
	'IIF(M->ZD_RNUM<ACOLS[N,4],"R","A")'									, ; //X7_REGRA
	'ZD_STATUS'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'ACOLS[N,11] == "3"'													} ) //X7_CONDIC

aAdd( aSX7, { ;
	'ZD_RNUM'																, ; //X7_CAMPO
	'005'																	, ; //X7_SEQUENC
	'M->ZD_RNUM'															, ; //X7_REGRA
	'ZD_RNUMR'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo ZD_RNUMR
//
aAdd( aSX7, { ;
	'ZD_RNUMR'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'IIF(MSGYESNO("Continua alteração RES REAL?",""),M->ZD_RNUMR,M->ZD_RNUM)'	, ; //X7_REGRA
	'ZD_RNUMR'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'ZD_RNUMR'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'IIF(MSGYESNO("Continua alteração RES REAL?",""),M->ZD_RNUMR,M->ZD_RNUM)'	, ; //X7_REGRA
	'ZD_RNUMR'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo ZD_RTEXTO
//
aAdd( aSX7, { ;
	'ZD_RTEXTO'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'IIF(M->ZD_RTEXTO=="C","A","R")'										, ; //X7_REGRA
	'ZD_STATUS'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	'!EMPTY(ACOLS[N,8])'													} ) //X7_CONDIC

aAdd( aSX7, { ;
	'ZD_RTEXTO'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'M->ZD_RTEXTO'															, ; //X7_REGRA
	'ZD_TEXTOR'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX7 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )

dbSelectArea( "SX7" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX7 )

	If !SX7->( dbSeek( PadR( aSX7[nI][1], nTamSeek ) + aSX7[nI][2] ) )

		AutoGrLog( "Foi incluído o gatilho " + aSX7[nI][1] + "/" + aSX7[nI][2] )

		RecLock( "SX7", .T. )
		For nJ := 1 To Len( aSX7[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX7[nI][nJ] )
			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		If SX3->( dbSeek( SX7->X7_CAMPO ) )
			RecLock( "SX3", .F. )
			SX3->X3_TRIGGER := "S"
			MsUnLock()
		EndIf

	EndIf
	oProcess:IncRegua2( "Atualizando Arquivos (SX7) ..." )

Next nI

RestArea( aAreaSX3 )

AutoGrLog( CRLF + "Final da Atualização" + " SX7" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXB

Função de processamento da gravação do SXB - Consultas Padrao

@author UPDATE gerado automaticamente
@since  02/10/22
@obs    Gerado por EXPORDIC - V.7.5.2.2 EFS / Upd. V.5.3.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXB()
Local aEstrut   := {}
Local aSXB      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0

AutoGrLog( "Ínicio da Atualização" + " SXB" + CRLF )

aEstrut := { "XB_ALIAS"  , "XB_TIPO"   , "XB_SEQ"    , "XB_COLUNA" , "XB_DESCRI" , "XB_DESCSPA", "XB_DESCENG", ;
             "XB_WCONTEM", "XB_CONTEM" }


//
// Consulta SC2
//
aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Ordem de Produção'														, ; //XB_DESCRI
	'Orden de producción'													, ; //XB_DESCSPA
	'Production Order'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC2'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'N·mero'																, ; //XB_DESCRI
	'Número'																, ; //XB_DESCSPA
	'Number'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Produto'																, ; //XB_DESCRI
	'Producto'																, ; //XB_DESCSPA
	'Product'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Item'																	, ; //XB_DESCRI
	'Ítem'																	, ; //XB_DESCSPA
	'Item'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_ITEM'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'N·mero'																, ; //XB_DESCRI
	'Número'																, ; //XB_DESCSPA
	'Number'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_NUM'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Sequência'																, ; //XB_DESCRI
	'Secuencia'																, ; //XB_DESCSPA
	'Sequence'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_SEQUEN'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Produto'																, ; //XB_DESCRI
	'Producto'																, ; //XB_DESCSPA
	'Product'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_PRODUTO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Saldo'																	, ; //XB_DESCRI
	'Saldo'																	, ; //XB_DESCSPA
	'Balance4'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Transform(aSC2Sld(),PesqPict("SC2", "C2_QUANT"))'						} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Inic.Prev'																, ; //XB_DESCRI
	'Inic.Prev'																, ; //XB_DESCSPA
	'Est Start'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_DATPRI'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Entr.Prev'																, ; //XB_DESCRI
	'Entr.Prev'																, ; //XB_DESCSPA
	'Est Entr'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_DATPRF'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Entr.Real'																, ; //XB_DESCRI
	'Entr.Real'																, ; //XB_DESCSPA
	'Actual Entr'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_DATRF'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'09'																	, ; //XB_COLUNA
	'It. Grade'																, ; //XB_DESCRI
	'Ítem grilla'															, ; //XB_DESCSPA
	'Grid It'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_ITEMGRD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'10'																	, ; //XB_COLUNA
	'N·mero'																, ; //XB_DESCRI
	'Número'																, ; //XB_DESCSPA
	'Number'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_NUM'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'11'																	, ; //XB_COLUNA
	'Item'																	, ; //XB_DESCRI
	'Ítem'																	, ; //XB_DESCSPA
	'Item'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_ITEM'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'12'																	, ; //XB_COLUNA
	'Sequência'																, ; //XB_DESCRI
	'Secuencia'																, ; //XB_DESCSPA
	'Sequence'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_SEQUEN'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'13'																	, ; //XB_COLUNA
	'Produto'																, ; //XB_DESCRI
	'Producto'																, ; //XB_DESCSPA
	'Product'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_PRODUTO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'14'																	, ; //XB_COLUNA
	'Saldo'																	, ; //XB_DESCRI
	'Saldo'																	, ; //XB_DESCSPA
	'Balance'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Transform(aSC2Sld(),PesqPict("SC2", "C2_QUANT"))'						} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'15'																	, ; //XB_COLUNA
	'Inic.Prev'																, ; //XB_DESCRI
	'Inic.Prev'																, ; //XB_DESCSPA
	'Est Start'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_DATPRI'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'16'																	, ; //XB_COLUNA
	'Entr.Prev'																, ; //XB_DESCRI
	'Entr.Prev'																, ; //XB_DESCSPA
	'Est Entr'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_DATPRF'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'17'																	, ; //XB_COLUNA
	'Entr.Real'																, ; //XB_DESCRI
	'Entr.Real'																, ; //XB_DESCSPA
	'Actual Entr'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_DATRF'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'18'																	, ; //XB_COLUNA
	'It. Grade'																, ; //XB_DESCRI
	'Ít. Grilla'															, ; //XB_DESCSPA
	'Grid It'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_ITEMGRD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD'				} ) //XB_CONTEM

//
// Consulta ZZH
//
aAdd( aSXB, { ;
	'ZZH'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Holdings'																, ; //XB_DESCRI
	'Holdings'																, ; //XB_DESCSPA
	'Holdings'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZH'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZH'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo+holding'														, ; //XB_DESCRI
	'Codigo+holding'														, ; //XB_DESCSPA
	'Codigo+holding'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZH'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZH'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZH_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZH'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Holding'																, ; //XB_DESCRI
	'Holding'																, ; //XB_DESCSPA
	'Holding'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZH_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZH'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZH->ZZH_COD'															} ) //XB_CONTEM

//
// Consulta ZZJ
//
aAdd( aSXB, { ;
	'ZZJ'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Controle tecnica'														, ; //XB_DESCRI
	'Controle tecnica'														, ; //XB_DESCSPA
	'Controle tecnica'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZJ'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZJ'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Tec.+desc.tecni'													, ; //XB_DESCRI
	'Cod. Tec.+desc.tecni'													, ; //XB_DESCSPA
	'Cod. Tec.+desc.tecni'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZJ'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZJ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Tec.'																, ; //XB_DESCRI
	'Cod. Tec.'																, ; //XB_DESCSPA
	'Cod. Tec.'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZJ_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZJ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc.Tecnica'															, ; //XB_DESCRI
	'Desc.Tecnica'															, ; //XB_DESCSPA
	'Desc.Tecnica'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZJ_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZJ'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZJ->ZZJ_COD'															} ) //XB_CONTEM

//
// Consulta ZZK
//
aAdd( aSXB, { ;
	'ZZK'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Ocorrencia NC'															, ; //XB_DESCRI
	'Ocorrencia NC'															, ; //XB_DESCSPA
	'Ocorrencia NC'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZK'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZK'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Tipo Ocorr.+desc. Oc'													, ; //XB_DESCRI
	'Tipo Ocorr.+desc. Oc'													, ; //XB_DESCSPA
	'Tipo Ocorr.+desc. Oc'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZK'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZK'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Tipo Ocorr.'															, ; //XB_DESCRI
	'Tipo Ocorr.'															, ; //XB_DESCSPA
	'Tipo Ocorr.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZK_TIPO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZK'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc. Ocorr.'															, ; //XB_DESCRI
	'Desc. Ocorr.'															, ; //XB_DESCSPA
	'Desc. Ocorr.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZK_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ZZK'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZZK->ZZK_TIPO'															} ) //XB_CONTEM

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSXB ) )

dbSelectArea( "SXB" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXB )

	If !Empty( aSXB[nI][1] )

		If !SXB->( dbSeek( PadR( aSXB[nI][1], Len( SXB->XB_ALIAS ) ) + aSXB[nI][2] + aSXB[nI][3] + aSXB[nI][4] ) )

			If !( aSXB[nI][1] $ cAlias )
				cAlias += aSXB[nI][1] + "/"
				AutoGrLog( "Foi incluída a consulta padrão " + aSXB[nI][1] )
			EndIf

			RecLock( "SXB", .T. )

			For nJ := 1 To Len( aSXB[nI] )
				If FieldPos( aEstrut[nJ] ) > 0
					FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
				EndIf
			Next nJ

			dbCommit()
			MsUnLock()

		Else

			//
			// Verifica todos os campos
			//
			For nJ := 1 To Len( aSXB[nI] )

				//
				// Se o campo estiver diferente da estrutura
				//
				If !StrTran( AllToChar( SXB->( FieldGet( FieldPos( aEstrut[nJ] ) ) ) ), " ", "" ) == ;
					StrTran( AllToChar( aSXB[nI][nJ] ), " ", "" )

					cMsg := "A consulta padrão " + aSXB[nI][1] + " está com o " + SXB->( FieldName( FieldPos( aEstrut[nJ] ) ) ) + ;
					" com o conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( SXB->( FieldGet( FieldPos( aEstrut[nJ] ) ) ) ) ) + "]" + CRLF + ;
					", e este é diferente do conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( aSXB[nI][nJ] ) ) + "]" + CRLF +;
					"Deseja substituir ? "

					If      lTodosSim
						nOpcA := 1
					ElseIf  lTodosNao
						nOpcA := 2
					Else
						nOpcA := Aviso( "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS", cMsg, { "Sim", "Não", "Sim p/Todos", "Não p/Todos" }, 3, "Diferença de conteúdo - SXB" )
						lTodosSim := ( nOpcA == 3 )
						lTodosNao := ( nOpcA == 4 )

						If lTodosSim
							nOpcA := 1
							lTodosSim := MsgNoYes( "Foi selecionada a opção de REALIZAR TODAS alterações no SXB e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a ação [Sim p/Todos] ?" )
						EndIf

						If lTodosNao
							nOpcA := 2
							lTodosNao := MsgNoYes( "Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SXB que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta ação [Não p/Todos]?" )
						EndIf

					EndIf

					If nOpcA == 1
						RecLock( "SXB", .F. )
						FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
						dbCommit()
						MsUnLock()

						If !( aSXB[nI][1] $ cAlias )
							cAlias += aSXB[nI][1] + "/"
							AutoGrLog( "Foi alterada a consulta padrão " + aSXB[nI][1] )
						EndIf

					EndIf

				EndIf

			Next

		EndIf

	EndIf

	oProcess:IncRegua2( "Atualizando Consultas Padrões (SXB) ..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SXB" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuHlp

Função de processamento da gravação dos Helps de Campos

@author UPDATE gerado automaticamente
@since  02/10/22
@obs    Gerado por EXPORDIC - V.7.5.2.2 EFS / Upd. V.5.3.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuHlp()
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}

AutoGrLog( "Ínicio da Atualização" + " " + "Helps de Campos" + CRLF )


oProcess:IncRegua2( "Atualizando Helps de Campos ..." )

//
// Helps Tabela CB8
//
aHlpPor := {}
aAdd( aHlpPor, 'Unidade de Medida' )

aHlpEng := {}
aAdd( aHlpEng, 'Unidade de Medida' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Unidade de Medida' )

PutSX1Help( "PCB8_XUN   ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "CB8_XUN" )

aHlpPor := {}
aAdd( aHlpPor, 'Unidade Medida Expedição' )

aHlpEng := {}
aAdd( aHlpEng, 'Unidade Medida Expedição' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Unidade Medida Expedição' )

PutSX1Help( "PCB8_XUNEXP", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "CB8_XUNEXP" )

aHlpPor := {}
aAdd( aHlpPor, 'Calculo Quant. Embalagem' )

aHlpEng := {}
aAdd( aHlpEng, 'Calculo Quant. Embalagem' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Calculo Quant. Embalagem' )

PutSX1Help( "PCB8_XCLEXP", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "CB8_XCLEXP" )

aHlpPor := {}
aAdd( aHlpPor, 'Calculo Qtde Volume' )

aHlpEng := {}
aAdd( aHlpEng, 'Calculo Qtde Volume' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Calculo Qtde Volume' )

PutSX1Help( "PCB8_XQTVOL", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "CB8_XQTVOL" )

aHlpPor := {}
aAdd( aHlpPor, 'Calculo Diferença Volume' )

aHlpEng := {}
aAdd( aHlpEng, 'Calculo Diferença Volume' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Calculo Diferença Volume' )

PutSX1Help( "PCB8_XDFVOL", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "CB8_XDFVOL" )

aHlpPor := {}
aAdd( aHlpPor, 'Quanti. Minima Embalagem' )

aHlpEng := {}
aAdd( aHlpEng, 'Quanti. Minima Embalagem' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Quanti. Minima Embalagem' )

PutSX1Help( "PCB8_XMNEMB", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "CB8_XMNEMB" )

aHlpPor := {}
aAdd( aHlpPor, 'Calculo Peso Bruto' )

aHlpEng := {}
aAdd( aHlpEng, 'Calculo Peso Bruto' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Calculo Peso Bruto' )

PutSX1Help( "PCB8_XPESBU", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "CB8_XPESBU" )

aHlpPor := {}
aAdd( aHlpPor, 'Calculo Peso Liquido' )

aHlpEng := {}
aAdd( aHlpEng, 'Calculo Peso Liquido' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Calculo Peso Liquido' )

PutSX1Help( "PCB8_XPESLQ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "CB8_XPESLQ" )

aHlpPor := {}
aAdd( aHlpPor, 'Peso Liquido do Cadastro' )

aHlpEng := {}
aAdd( aHlpEng, 'Peso Liquido do Cadastro' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Peso Liquido do Cadastro' )

PutSX1Help( "PCB8_XPLIQ ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "CB8_XPLIQ" )

aHlpPor := {}
aAdd( aHlpPor, 'Peso Bruto do Cadastro de Produtos' )

aHlpEng := {}
aAdd( aHlpEng, 'Peso Bruto do Cadastro de Produtos' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Peso Bruto do Cadastro de Produtos' )

PutSX1Help( "PCB8_XPBRU ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "CB8_XPBRU" )

//
// Helps Tabela DAI
//
aHlpPor := {}
aAdd( aHlpPor, 'Especie Pedido de Venda' )

aHlpEng := {}
aAdd( aHlpEng, 'Especie Pedido de Venda' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Especie Pedido de Venda' )

PutSX1Help( "PDAI_XESP1 ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XESP1" )

aHlpPor := {}
aAdd( aHlpPor, 'Volume Pedido de Vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Volume Pedido de Vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Volume Pedido de Vendas' )

PutSX1Help( "PDAI_XVOL1 ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XVOL1" )

aHlpPor := {}
aAdd( aHlpPor, 'Especie Pedido de Venda' )
aAdd( aHlpPor, 'Especie Pedido de Venda 1' )

aHlpEng := {}
aAdd( aHlpEng, 'Especie Pedido de Venda' )
aAdd( aHlpEng, 'Especie Pedido de Venda 1' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Especie Pedido de Venda' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 1' )

PutSX1Help( "PDAI_XESP2 ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XESP2" )

aHlpPor := {}
aAdd( aHlpPor, 'Especie Pedido de Venda' )
aAdd( aHlpPor, 'Especie Pedido de Venda 1' )
aAdd( aHlpPor, 'Especie Pedido de Venda 2' )

aHlpEng := {}
aAdd( aHlpEng, 'Especie Pedido de Venda' )
aAdd( aHlpEng, 'Especie Pedido de Venda 1' )
aAdd( aHlpEng, 'Especie Pedido de Venda 2' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Especie Pedido de Venda' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 1' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 2' )

PutSX1Help( "PDAI_XESP3 ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XESP3" )

aHlpPor := {}
aAdd( aHlpPor, 'Especie Pedido de Venda' )
aAdd( aHlpPor, 'Especie Pedido de Venda 1' )
aAdd( aHlpPor, 'Especie Pedido de Venda 2' )

aHlpEng := {}
aAdd( aHlpEng, 'Especie Pedido de Venda' )
aAdd( aHlpEng, 'Especie Pedido de Venda 1' )
aAdd( aHlpEng, 'Especie Pedido de Venda 2' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Especie Pedido de Venda' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 1' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 2' )

PutSX1Help( "PDAI_XESP4 ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XESP4" )

aHlpPor := {}
aAdd( aHlpPor, 'Especie Pedido de Venda' )
aAdd( aHlpPor, 'Especie Pedido de Venda 1' )
aAdd( aHlpPor, 'Especie Pedido de Venda 2' )

aHlpEng := {}
aAdd( aHlpEng, 'Especie Pedido de Venda' )
aAdd( aHlpEng, 'Especie Pedido de Venda 1' )
aAdd( aHlpEng, 'Especie Pedido de Venda 2' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Especie Pedido de Venda' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 1' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 2' )

PutSX1Help( "PDAI_XESP5 ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XESP5" )

aHlpPor := {}
aAdd( aHlpPor, 'Especie Pedido de Venda' )
aAdd( aHlpPor, 'Especie Pedido de Venda 1' )
aAdd( aHlpPor, 'Especie Pedido de Venda 2' )

aHlpEng := {}
aAdd( aHlpEng, 'Especie Pedido de Venda' )
aAdd( aHlpEng, 'Especie Pedido de Venda 1' )
aAdd( aHlpEng, 'Especie Pedido de Venda 2' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Especie Pedido de Venda' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 1' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 2' )

PutSX1Help( "PDAI_XESP6 ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XESP6" )

aHlpPor := {}
aAdd( aHlpPor, 'Especie Pedido de Venda' )
aAdd( aHlpPor, 'Especie Pedido de Venda 1' )
aAdd( aHlpPor, 'Especie Pedido de Venda 2' )

aHlpEng := {}
aAdd( aHlpEng, 'Especie Pedido de Venda' )
aAdd( aHlpEng, 'Especie Pedido de Venda 1' )
aAdd( aHlpEng, 'Especie Pedido de Venda 2' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Especie Pedido de Venda' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 1' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 2' )

PutSX1Help( "PDAI_XESP7 ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XESP7" )

aHlpPor := {}
aAdd( aHlpPor, 'Especie Pedido de Venda' )
aAdd( aHlpPor, 'Especie Pedido de Venda 1' )
aAdd( aHlpPor, 'Especie Pedido de Venda 2' )

aHlpEng := {}
aAdd( aHlpEng, 'Especie Pedido de Venda' )
aAdd( aHlpEng, 'Especie Pedido de Venda 1' )
aAdd( aHlpEng, 'Especie Pedido de Venda 2' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Especie Pedido de Venda' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 1' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 2' )

PutSX1Help( "PDAI_XESP8 ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XESP8" )

aHlpPor := {}
aAdd( aHlpPor, 'Especie Pedido de Venda' )
aAdd( aHlpPor, 'Especie Pedido de Venda 1' )
aAdd( aHlpPor, 'Especie Pedido de Venda 2' )

aHlpEng := {}
aAdd( aHlpEng, 'Especie Pedido de Venda' )
aAdd( aHlpEng, 'Especie Pedido de Venda 1' )
aAdd( aHlpEng, 'Especie Pedido de Venda 2' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Especie Pedido de Venda' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 1' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 2' )

PutSX1Help( "PDAI_XESP9 ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XESP9" )

aHlpPor := {}
aAdd( aHlpPor, 'Especie Pedido de Venda' )
aAdd( aHlpPor, 'Especie Pedido de Venda 1' )
aAdd( aHlpPor, 'Especie Pedido de Venda 2' )

aHlpEng := {}
aAdd( aHlpEng, 'Especie Pedido de Venda' )
aAdd( aHlpEng, 'Especie Pedido de Venda 1' )
aAdd( aHlpEng, 'Especie Pedido de Venda 2' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Especie Pedido de Venda' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 1' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 2' )

PutSX1Help( "PDAI_XESP10", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XESP10" )

aHlpPor := {}
aAdd( aHlpPor, 'Especie Pedido de Venda' )
aAdd( aHlpPor, 'Especie Pedido de Venda 1' )
aAdd( aHlpPor, 'Especie Pedido de Venda 2' )

aHlpEng := {}
aAdd( aHlpEng, 'Especie Pedido de Venda' )
aAdd( aHlpEng, 'Especie Pedido de Venda 1' )
aAdd( aHlpEng, 'Especie Pedido de Venda 2' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Especie Pedido de Venda' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 1' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 2' )

PutSX1Help( "PDAI_XESP11", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XESP11" )

aHlpPor := {}
aAdd( aHlpPor, 'Especie Pedido de Venda' )
aAdd( aHlpPor, 'Especie Pedido de Venda 1' )
aAdd( aHlpPor, 'Especie Pedido de Venda 2' )

aHlpEng := {}
aAdd( aHlpEng, 'Especie Pedido de Venda' )
aAdd( aHlpEng, 'Especie Pedido de Venda 1' )
aAdd( aHlpEng, 'Especie Pedido de Venda 2' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Especie Pedido de Venda' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 1' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 2' )

PutSX1Help( "PDAI_XESP12", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XESP12" )

aHlpPor := {}
aAdd( aHlpPor, 'Especie Pedido de Venda' )
aAdd( aHlpPor, 'Especie Pedido de Venda 1' )
aAdd( aHlpPor, 'Especie Pedido de Venda 2' )

aHlpEng := {}
aAdd( aHlpEng, 'Especie Pedido de Venda' )
aAdd( aHlpEng, 'Especie Pedido de Venda 1' )
aAdd( aHlpEng, 'Especie Pedido de Venda 2' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Especie Pedido de Venda' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 1' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 2' )

PutSX1Help( "PDAI_XESP13", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XESP13" )

aHlpPor := {}
aAdd( aHlpPor, 'Especie Pedido de Venda' )
aAdd( aHlpPor, 'Especie Pedido de Venda 1' )
aAdd( aHlpPor, 'Especie Pedido de Venda 2' )

aHlpEng := {}
aAdd( aHlpEng, 'Especie Pedido de Venda' )
aAdd( aHlpEng, 'Especie Pedido de Venda 1' )
aAdd( aHlpEng, 'Especie Pedido de Venda 2' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Especie Pedido de Venda' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 1' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 2' )

PutSX1Help( "PDAI_XESP14", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XESP14" )

aHlpPor := {}
aAdd( aHlpPor, 'Especie Pedido de Venda' )
aAdd( aHlpPor, 'Especie Pedido de Venda 1' )
aAdd( aHlpPor, 'Especie Pedido de Venda 2' )

aHlpEng := {}
aAdd( aHlpEng, 'Especie Pedido de Venda' )
aAdd( aHlpEng, 'Especie Pedido de Venda 1' )
aAdd( aHlpEng, 'Especie Pedido de Venda 2' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Especie Pedido de Venda' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 1' )
aAdd( aHlpSpa, 'Especie Pedido de Venda 2' )

PutSX1Help( "PDAI_XESP15", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XESP15" )

aHlpPor := {}
aAdd( aHlpPor, 'Volume Pedido de Vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Volume Pedido de Vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Volume Pedido de Vendas' )

PutSX1Help( "PDAI_XVOL2 ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XVOL2" )

aHlpPor := {}
aAdd( aHlpPor, 'Volume Pedido de Vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Volume Pedido de Vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Volume Pedido de Vendas' )

PutSX1Help( "PDAI_XVOL3 ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XVOL3" )

aHlpPor := {}
aAdd( aHlpPor, 'Volume Pedido de Vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Volume Pedido de Vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Volume Pedido de Vendas' )

PutSX1Help( "PDAI_XVOL4 ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XVOL4" )

aHlpPor := {}
aAdd( aHlpPor, 'Volume Pedido de Vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Volume Pedido de Vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Volume Pedido de Vendas' )

PutSX1Help( "PDAI_XVOL5 ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XVOL5" )

aHlpPor := {}
aAdd( aHlpPor, 'Volume Pedido de Vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Volume Pedido de Vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Volume Pedido de Vendas' )

PutSX1Help( "PDAI_XVOL6 ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XVOL6" )

aHlpPor := {}
aAdd( aHlpPor, 'Volume Pedido de Vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Volume Pedido de Vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Volume Pedido de Vendas' )

PutSX1Help( "PDAI_XVOL7 ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XVOL7" )

aHlpPor := {}
aAdd( aHlpPor, 'Volume Pedido de Vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Volume Pedido de Vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Volume Pedido de Vendas' )

PutSX1Help( "PDAI_XVOL8 ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XVOL8" )

aHlpPor := {}
aAdd( aHlpPor, 'Volume Pedido de Vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Volume Pedido de Vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Volume Pedido de Vendas' )

PutSX1Help( "PDAI_XVOL9 ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XVOL9" )

aHlpPor := {}
aAdd( aHlpPor, 'Volume Pedido de Vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Volume Pedido de Vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Volume Pedido de Vendas' )

PutSX1Help( "PDAI_XVOL10", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XVOL10" )

aHlpPor := {}
aAdd( aHlpPor, 'Volume Pedido de Vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Volume Pedido de Vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Volume Pedido de Vendas' )

PutSX1Help( "PDAI_XVOL11", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XVOL11" )

aHlpPor := {}
aAdd( aHlpPor, 'Volume Pedido de Vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Volume Pedido de Vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Volume Pedido de Vendas' )

PutSX1Help( "PDAI_XVOL12", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XVOL12" )

aHlpPor := {}
aAdd( aHlpPor, 'Volume Pedido de Vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Volume Pedido de Vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Volume Pedido de Vendas' )

PutSX1Help( "PDAI_XVOL13", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XVOL13" )

aHlpPor := {}
aAdd( aHlpPor, 'Volume Pedido de Vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Volume Pedido de Vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Volume Pedido de Vendas' )

PutSX1Help( "PDAI_XVOL14", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XVOL14" )

aHlpPor := {}
aAdd( aHlpPor, 'Volume Pedido de Vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Volume Pedido de Vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Volume Pedido de Vendas' )

PutSX1Help( "PDAI_XVOL15", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XVOL15" )

aHlpPor := {}
aAdd( aHlpPor, 'Valor Total Pedido Vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Valor Total Pedido Vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Valor Total Pedido Vendas' )

PutSX1Help( "PDAI_XVALPD", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "DAI_XVALPD" )

//
// Helps Tabela EE7
//
aHlpPor := {}
aAdd( aHlpPor, 'Presença Informada para tratamento da' )
aAdd( aHlpPor, 'rejeição 434, na nota fiscal eletronica.' )

aHlpEng := {}
aAdd( aHlpEng, 'Presença Informada para tratamento da' )
aAdd( aHlpEng, 'rejeição 434, na nota fiscal eletronica.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Presença Informada para tratamento da' )
aAdd( aHlpSpa, 'rejeição 434, na nota fiscal eletronica.' )

PutSX1Help( "PEE7_INDPRE", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "EE7_INDPRE" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo frete' )

aHlpEng := {}
aAdd( aHlpEng, 'Tipo frete' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Tipo frete' )

PutSX1Help( "PEE7_TPFRET", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "EE7_TPFRET" )

aHlpPor := {}
aAdd( aHlpPor, 'Dta Entrada' )

aHlpEng := {}
aAdd( aHlpEng, 'Dta Entrada' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Dta Entrada' )

PutSX1Help( "PEE7_FECENT", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "EE7_FECENT" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo LIberação' )

aHlpEng := {}
aAdd( aHlpEng, 'Tipo LIberação' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Tipo LIberação' )

PutSX1Help( "PEE7_TIPLIB", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "EE7_TIPLIB" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe o tipo da operação fiscal a ser' )
aAdd( aHlpPor, 'gerada por esse pedido de venda.' )

aHlpEng := {}
aAdd( aHlpEng, 'Informe o tipo da operação fiscal a ser' )
aAdd( aHlpEng, 'gerada por esse pedido de venda.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Informe o tipo da operação fiscal a ser' )
aAdd( aHlpSpa, 'gerada por esse pedido de venda.' )

PutSX1Help( "PEE7_XOPER ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "EE7_XOPER" )

aHlpPor := {}
aAdd( aHlpPor, 'Campo utilizado para guardar qualquer' )
aAdd( aHlpPor, 'tipo de informação relevante ao pedido.' )

aHlpEng := {}
aAdd( aHlpEng, 'Campo utilizado para guardar qualquer' )
aAdd( aHlpEng, 'tipo de informação relevante ao pedido.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Campo utilizado para guardar qualquer' )
aAdd( aHlpSpa, 'tipo de informação relevante ao pedido.' )

PutSX1Help( "PEE7_XOBSER", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "EE7_XOBSER" )

aHlpPor := {}
aAdd( aHlpPor, 'Margem' )

aHlpEng := {}
aAdd( aHlpEng, 'Margem' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Margem' )

PutSX1Help( "PEE7_XMARGE", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "EE7_XMARGE" )

//
// Helps Tabela EE8
//
aHlpPor := {}
aAdd( aHlpPor, 'Peso Liquido do Produto' )

aHlpEng := {}
aAdd( aHlpEng, 'Peso Liquido do Produto' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Peso Liquido do Produto' )

PutSX1Help( "PEE8_XPESLI", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "EE8_XPESLI" )

aHlpPor := {}
aAdd( aHlpPor, 'Peso Bruto  do Produto' )

aHlpEng := {}
aAdd( aHlpEng, 'Peso Bruto  do Produto' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Peso Bruto  do Produto' )

PutSX1Help( "PEE8_XPESBU", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "EE8_XPESBU" )

aHlpPor := {}
aAdd( aHlpPor, 'Peso Liquido do Cadastro' )

aHlpEng := {}
aAdd( aHlpEng, 'Peso Liquido do Cadastro' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Peso Liquido do Cadastro' )

PutSX1Help( "PEE8_XPLIQ ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "EE8_XPLIQ" )

aHlpPor := {}
aAdd( aHlpPor, 'Peso Bruto do Cadastro de produtos' )

aHlpEng := {}
aAdd( aHlpEng, 'Peso Bruto do Cadastro de produtos' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Peso Bruto do Cadastro de produtos' )

PutSX1Help( "PEE8_XPBRU ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "EE8_XPBRU" )

//
// Helps Tabela PAA
//
aHlpPor := {}
aAdd( aHlpPor, 'Codigo Revisão Comissão' )

aHlpEng := {}
aAdd( aHlpEng, 'Codigo Revisão Comissão' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Codigo Revisão Comissão' )

PutSX1Help( "PPAA_REV   ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAA_REV" )

aHlpPor := {}
aAdd( aHlpPor, 'Justificativa Alteração de comissão' )

aHlpEng := {}
aAdd( aHlpEng, 'Justificativa Alteração de comissão' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Justificativa Alteração de comissão' )

PutSX1Help( "PPAA_JUSTIF", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAA_JUSTIF" )

//
// Helps Tabela PAW
//
aHlpPor := {}
aAdd( aHlpPor, 'Pedido de Vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Pedido de Vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Pedido de Vendas' )

PutSX1Help( "PPAW_PEDIDO", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAW_PEDIDO" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo do Cliente' )

aHlpEng := {}
aAdd( aHlpEng, 'Codigo do Cliente' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Codigo do Cliente' )

PutSX1Help( "PPAW_CODCLI", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAW_CODCLI" )

aHlpPor := {}
aAdd( aHlpPor, 'Loja Cliente' )

aHlpEng := {}
aAdd( aHlpEng, 'Loja Cliente' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Loja Cliente' )

PutSX1Help( "PPAW_LOJA  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAW_LOJA" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo do Produto' )

aHlpEng := {}
aAdd( aHlpEng, 'Codigo do Produto' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Codigo do Produto' )

PutSX1Help( "PPAW_COD   ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAW_COD" )

aHlpPor := {}
aAdd( aHlpPor, 'Item do Pedido de vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Item do Pedido de vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Item do Pedido de vendas' )

PutSX1Help( "PPAW_ITEM  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAW_ITEM" )

aHlpPor := {}
aAdd( aHlpPor, 'Quantidade Pedido Venda' )

aHlpEng := {}
aAdd( aHlpEng, 'Quantidade Pedido Venda' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Quantidade Pedido Venda' )

PutSX1Help( "PPAW_QTD   ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAW_QTD" )

aHlpPor := {}
aAdd( aHlpPor, 'Preco Unitario Produto' )

aHlpEng := {}
aAdd( aHlpEng, 'Preco Unitario Produto' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Preco Unitario Produto' )

PutSX1Help( "PPAW_PRECO ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAW_PRECO" )

aHlpPor := {}
aAdd( aHlpPor, 'Cod. Tabela Pedido Vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Cod. Tabela Pedido Vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Cod. Tabela Pedido Vendas' )

PutSX1Help( "PPAW_CODTAB", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAW_CODTAB" )

aHlpPor := {}
aAdd( aHlpPor, 'Revisao Pedido de Vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Revisao Pedido de Vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Revisao Pedido de Vendas' )

PutSX1Help( "PPAW_REV   ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAW_REV" )

aHlpPor := {}
aAdd( aHlpPor, 'Dta Revisao Pedido Vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Dta Revisao Pedido Vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Dta Revisao Pedido Vendas' )

PutSX1Help( "PPAW_DATA  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAW_DATA" )

aHlpPor := {}
aAdd( aHlpPor, '% Comissão Pedido Vendas' )

aHlpEng := {}
aAdd( aHlpEng, '% Comissão Pedido Vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, '% Comissão Pedido Vendas' )

PutSX1Help( "PPAW_COMIS1", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAW_COMIS1" )

aHlpPor := {}
aAdd( aHlpPor, 'Data da Ocorrencia' )

aHlpEng := {}
aAdd( aHlpEng, 'Data da Ocorrencia' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Data da Ocorrencia' )

PutSX1Help( "PPAW_DTAREG", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAW_DTAREG" )

aHlpPor := {}
aAdd( aHlpPor, 'Status do Registro' )

aHlpEng := {}
aAdd( aHlpEng, 'Status do Registro' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Status do Registro' )

PutSX1Help( "PPAW_STATUS", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAW_STATUS" )

aHlpPor := {}
aAdd( aHlpPor, 'Nome Usuario da Alteração' )

aHlpEng := {}
aAdd( aHlpEng, 'Nome Usuario da Alteração' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Nome Usuario da Alteração' )

PutSX1Help( "PPAW_USRNOM", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAW_USRNOM" )

//
// Helps Tabela PAY
//
aHlpPor := {}
aAdd( aHlpPor, 'Controle de Impressão' )

aHlpEng := {}
aAdd( aHlpEng, 'Controle de Impressão' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Controle de Impressão' )

PutSX1Help( "PPAY_CTRL  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_CTRL" )

aHlpPor := {}
aAdd( aHlpPor, 'Sequencia Controle OP' )

aHlpEng := {}
aAdd( aHlpEng, 'Sequencia Controle OP' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Sequencia Controle OP' )

PutSX1Help( "PPAY_SEQ   ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_SEQ" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo Produto' )

aHlpEng := {}
aAdd( aHlpEng, 'Codigo Produto' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Codigo Produto' )

PutSX1Help( "PPAY_PROD  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_PROD" )

aHlpPor := {}
aAdd( aHlpPor, 'Numero Ordem Produção' )

aHlpEng := {}
aAdd( aHlpEng, 'Numero Ordem Produção' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Numero Ordem Produção' )

PutSX1Help( "PPAY_OP    ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_OP" )

aHlpPor := {}
aAdd( aHlpPor, 'Numero de Lote' )

aHlpEng := {}
aAdd( aHlpEng, 'Numero de Lote' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Numero de Lote' )

PutSX1Help( "PPAY_LOTE  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_LOTE" )

aHlpPor := {}
aAdd( aHlpPor, 'Data Fabricação' )

aHlpEng := {}
aAdd( aHlpEng, 'Data Fabricação' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Data Fabricação' )

PutSX1Help( "PPAY_DTFAB ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_DTFAB" )

aHlpPor := {}
aAdd( aHlpPor, 'Data de Validade' )

aHlpEng := {}
aAdd( aHlpEng, 'Data de Validade' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Data de Validade' )

PutSX1Help( "PPAY_DTVAL ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_DTVAL" )

aHlpPor := {}
aAdd( aHlpPor, 'Hora do Registro' )

aHlpEng := {}
aAdd( aHlpEng, 'Hora do Registro' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Hora do Registro' )

PutSX1Help( "PPAY_HRREG ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_HRREG" )

aHlpPor := {}
aAdd( aHlpPor, 'Data do Laudo' )

aHlpEng := {}
aAdd( aHlpEng, 'Data do Laudo' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Data do Laudo' )

PutSX1Help( "PPAY_DTLAUD", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_DTLAUD" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo da Analise' )

aHlpEng := {}
aAdd( aHlpEng, 'Codigo da Analise' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Codigo da Analise' )

PutSX1Help( "PPAY_CODANL", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_CODANL" )

aHlpPor := {}
aAdd( aHlpPor, 'Status do Laudo' )

aHlpEng := {}
aAdd( aHlpEng, 'Status do Laudo' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Status do Laudo' )

PutSX1Help( "PPAY_STATUS", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_STATUS" )

//
// Helps Tabela SA1
//
aHlpPor := {}
aAdd( aHlpPor, '% Comisão Cliente  para tratamento do' )
aAdd( aHlpPor, 'projeto comissões' )

aHlpEng := {}
aAdd( aHlpEng, '% Comisão Cliente  para tratamento do' )
aAdd( aHlpEng, 'projeto comissões' )

aHlpSpa := {}
aAdd( aHlpSpa, '% Comisão Cliente  para tratamento do' )
aAdd( aHlpSpa, 'projeto comissões' )

PutSX1Help( "PA1_XCOMIS1", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XCOMIS1" )

//
// Helps Tabela SA3
//
aHlpPor := {}
aAdd( aHlpPor, 'Tipo do tratamento no cáculo da' )
aAdd( aHlpPor, 'comissão.' )
aAdd( aHlpPor, 'N=Calculo Normal da comissão;' )
aAdd( aHlpPor, 'T=Teto, comissão não ultrapassa valor' )
aAdd( aHlpPor, 'especificado no cadastro;' )
aAdd( aHlpPor, 'F=Fixo, comissão é fixa.' )

aHlpEng := {}
aAdd( aHlpEng, 'Tipo do tratamento no cáculo da' )
aAdd( aHlpEng, 'comissão.' )
aAdd( aHlpEng, 'N=Calculo Normal da comissão;' )
aAdd( aHlpEng, 'T=Teto, comissão não ultrapassa valor' )
aAdd( aHlpEng, 'especificado no cadastro;' )
aAdd( aHlpEng, 'F=Fixo, comissão é fixa.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Tipo do tratamento no cáculo da' )
aAdd( aHlpSpa, 'comissão.' )
aAdd( aHlpSpa, 'N=Calculo Normal da comissão;' )
aAdd( aHlpSpa, 'T=Teto, comissão não ultrapassa valor' )
aAdd( aHlpSpa, 'especificado no cadastro;' )
aAdd( aHlpSpa, 'F=Fixo, comissão é fixa.' )

PutSX1Help( "PA3_TPCOMIS", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A3_TPCOMIS" )

aHlpPor := {}
aAdd( aHlpPor, 'Mínimo percentual de comissão que o' )
aAdd( aHlpPor, 'vendedor receberá por venda efetuada.' )

aHlpEng := {}
aAdd( aHlpEng, 'Mínimo percentual de comissão que o' )
aAdd( aHlpEng, 'vendedor receberá por venda efetuada.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Mínimo percentual de comissão que o' )
aAdd( aHlpSpa, 'vendedor receberá por venda efetuada.' )

PutSX1Help( "PA3_COMINF ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A3_COMINF" )

aHlpPor := {}
aAdd( aHlpPor, 'Logins autorizados a visualizar os' )
aAdd( aHlpPor, 'dadosde faturamento do' )
aAdd( aHlpPor, 'representantes/vendedor.' )

aHlpEng := {}
aAdd( aHlpEng, 'Logins autorizados a visualizar os' )
aAdd( aHlpEng, 'dadosde faturamento do' )
aAdd( aHlpEng, 'representantes/vendedor.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Logins autorizados a visualizar os' )
aAdd( aHlpSpa, 'dadosde faturamento do' )
aAdd( aHlpSpa, 'representantes/vendedor.' )

PutSX1Help( "PA3_XLOGIN ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A3_XLOGIN" )

aHlpPor := {}
aAdd( aHlpPor, 'Indica se utiliza criterios de' )
aAdd( aHlpPor, 'pontuaçãopara calculo da comissao' )
aAdd( aHlpPor, 'Campo nao original do sistema' )

aHlpEng := {}
aAdd( aHlpEng, 'Indica se utiliza criterios de' )
aAdd( aHlpEng, 'pontuaçãopara calculo da comissao' )
aAdd( aHlpEng, 'Campo nao original do sistema' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Indica se utiliza criterios de' )
aAdd( aHlpSpa, 'pontuaçãopara calculo da comissao' )
aAdd( aHlpSpa, 'Campo nao original do sistema' )

PutSX1Help( "PA3_XNCALC ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A3_XNCALC" )

aHlpPor := {}
aAdd( aHlpPor, 'Este campo será utilizado para pagar o' )
aAdd( aHlpPor, 'percentual de comissão pelo cadastro do' )
aAdd( aHlpPor, 'vendedor, oou seja, deve ser preenchido' )
aAdd( aHlpPor, 'o campo A3_COMIS' )

aHlpEng := {}
aAdd( aHlpEng, 'Este campo será utilizado para pagar o' )
aAdd( aHlpEng, 'percentual de comissão pelo cadastro do' )
aAdd( aHlpEng, 'vendedor, oou seja, deve ser preenchido' )
aAdd( aHlpEng, 'o campo A3_COMIS' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Este campo será utilizado para pagar o' )
aAdd( aHlpSpa, 'percentual de comissão pelo cadastro do' )
aAdd( aHlpSpa, 'vendedor, oou seja, deve ser preenchido' )
aAdd( aHlpSpa, 'o campo A3_COMIS' )

PutSX1Help( "PA3_XCLT   ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A3_XCLT" )

aHlpPor := {}
aAdd( aHlpPor, 'Paga comissão para o vendedor ou' )
aAdd( aHlpPor, 'representante, ou seja, se este campo' )
aAdd( aHlpPor, 'estiver preenchido como NÃO, na' )
aAdd( aHlpPor, 'digitação do pedido não será pago' )
aAdd( aHlpPor, 'comissão.' )
aAdd( aHlpPor, 'Especifico Qualy!' )

aHlpEng := {}
aAdd( aHlpEng, 'Paga comissão para o vendedor ou' )
aAdd( aHlpEng, 'representante, ou seja, se este campo' )
aAdd( aHlpEng, 'estiver preenchido como NÃO, na' )
aAdd( aHlpEng, 'digitação do pedido não será pago' )
aAdd( aHlpEng, 'comissão.' )
aAdd( aHlpEng, 'Especifico Qualy!' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Paga comissão para o vendedor ou' )
aAdd( aHlpSpa, 'representante, ou seja, se este campo' )
aAdd( aHlpSpa, 'estiver preenchido como NÃO, na' )
aAdd( aHlpSpa, 'digitação do pedido não será pago' )
aAdd( aHlpSpa, 'comissão.' )
aAdd( aHlpSpa, 'Especifico Qualy!' )

PutSX1Help( "PA3_XPGCOM ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "A3_XPGCOM" )

//
// Helps Tabela SB1
//
aHlpPor := {}
aAdd( aHlpPor, 'Codigo Tabela de Comissão vigente' )

aHlpEng := {}
aAdd( aHlpEng, 'Codigo Tabela de Comissão vigente' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Codigo Tabela de Comissão vigente' )

PutSX1Help( "PB1_XTABCOM", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_XTABCOM" )

aHlpPor := {}
aAdd( aHlpPor, 'Ultima Revisão Comissão' )

aHlpEng := {}
aAdd( aHlpEng, 'Ultima Revisão Comissão' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Ultima Revisão Comissão' )

PutSX1Help( "PB1_XREVCOM", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_XREVCOM" )

//
// Helps Tabela SC2
//
aHlpPor := {}
aAdd( aHlpPor, 'Dta. Fabricação Euro' )

aHlpEng := {}
aAdd( aHlpEng, 'Dta. Fabricação Euro' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Dta. Fabricação Euro' )

PutSX1Help( "PC2_DTFABR ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "C2_DTFABR" )

aHlpPor := {}
aAdd( aHlpPor, 'Data Validade Euro' )

aHlpEng := {}
aAdd( aHlpEng, 'Data Validade Euro' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Data Validade Euro' )

PutSX1Help( "PC2_DTVALID", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "C2_DTVALID" )

aHlpPor := {}
aAdd( aHlpPor, 'Controle de Laudo Euro para impressão' )
aAdd( aHlpPor, 'deetqueta' )

aHlpEng := {}
aAdd( aHlpEng, 'Controle de Laudo Euro para impressão' )
aAdd( aHlpEng, 'deetqueta' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Controle de Laudo Euro para impressão' )
aAdd( aHlpSpa, 'deetqueta' )

PutSX1Help( "PC2_XCTRL  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "C2_XCTRL" )

//
// Helps Tabela SC5
//
aHlpPor := {}
aAdd( aHlpPor, 'Tipo de Comissão Qualy' )
aAdd( aHlpPor, '01=Clliente;02=Produto;03=Vendedor;04=Ze' )
aAdd( aHlpPor, 'rada;05=Camapanha;06=Outros' )

aHlpEng := {}
aAdd( aHlpEng, 'Tipo de Comissão Qualy' )
aAdd( aHlpEng, '01=Clliente;02=Produto;03=Vendedor;04=Ze' )
aAdd( aHlpEng, 'rada;05=Camapanha;06=Outros' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Tipo de Comissão Qualy' )
aAdd( aHlpSpa, '01=Clliente;02=Produto;03=Vendedor;04=Ze' )
aAdd( aHlpSpa, 'rada;05=Camapanha;06=Outros' )

PutSX1Help( "PC5_XTPCOM ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "C5_XTPCOM" )

//
// Helps Tabela SC6
//
aHlpPor := {}
aAdd( aHlpPor, 'Data Revisão da Comissão na inclusão do' )
aAdd( aHlpPor, 'pedido de vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Data Revisão da Comissão na inclusão do' )
aAdd( aHlpEng, 'pedido de vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Data Revisão da Comissão na inclusão do' )
aAdd( aHlpSpa, 'pedido de vendas' )

PutSX1Help( "PC6_XDTRVC ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "C6_XDTRVC" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo Revisão Comissão na inclusão do' )
aAdd( aHlpPor, 'pedido de vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Codigo Revisão Comissão na inclusão do' )
aAdd( aHlpEng, 'pedido de vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Codigo Revisão Comissão na inclusão do' )
aAdd( aHlpSpa, 'pedido de vendas' )

PutSX1Help( "PC6_XREVCOM", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "C6_XREVCOM" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo de Comissão Qualy' )
aAdd( aHlpPor, '01=Clliente;02=Produto;03=Vendedor;04=Ze' )
aAdd( aHlpPor, 'rada;05=Camapanha;06=Outros' )

aHlpEng := {}
aAdd( aHlpEng, 'Tipo de Comissão Qualy' )
aAdd( aHlpEng, '01=Clliente;02=Produto;03=Vendedor;04=Ze' )
aAdd( aHlpEng, 'rada;05=Camapanha;06=Outros' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Tipo de Comissão Qualy' )
aAdd( aHlpSpa, '01=Clliente;02=Produto;03=Vendedor;04=Ze' )
aAdd( aHlpSpa, 'rada;05=Camapanha;06=Outros' )

PutSX1Help( "PC6_XTPCOM ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "C6_XTPCOM" )

//
// Helps Tabela SC9
//
aHlpPor := {}
aAdd( aHlpPor, 'Indicador' )

aHlpEng := {}
aAdd( aHlpEng, 'Indicador' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Indicador' )

PutSX1Help( "PC9_XNUMIND", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "C9_XNUMIND" )

//
// Helps Tabela SCJ
//
aHlpPor := {}
aAdd( aHlpPor, 'Tipo de Comissão Qualy:' )
aAdd( aHlpPor, '01=Clliente;02=Produto;03=Vendedor;04=Ze' )
aAdd( aHlpPor, 'rada;05=Camapanha;06=Outros' )

aHlpEng := {}
aAdd( aHlpEng, 'Tipo de Comissão Qualy:' )
aAdd( aHlpEng, '01=Clliente;02=Produto;03=Vendedor;04=Ze' )
aAdd( aHlpEng, 'rada;05=Camapanha;06=Outros' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Tipo de Comissão Qualy:' )
aAdd( aHlpSpa, '01=Clliente;02=Produto;03=Vendedor;04=Ze' )
aAdd( aHlpSpa, 'rada;05=Camapanha;06=Outros' )

PutSX1Help( "PCJ_XTPCOM ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "CJ_XTPCOM" )

//
// Helps Tabela SCK
//
aHlpPor := {}
aAdd( aHlpPor, 'Dta Revcisão de Comissão na inclusão do' )
aAdd( aHlpPor, 'orçamento.' )

aHlpEng := {}
aAdd( aHlpEng, 'Dta Revcisão de Comissão na inclusão do' )
aAdd( aHlpEng, 'orçamento.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Dta Revcisão de Comissão na inclusão do' )
aAdd( aHlpSpa, 'orçamento.' )

PutSX1Help( "PCK_XDTRVC ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "CK_XDTRVC" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo Revisão Comissão que será' )
aAdd( aHlpPor, 'carregado do produto' )

aHlpEng := {}
aAdd( aHlpEng, 'Codigo Revisão Comissão que será' )
aAdd( aHlpEng, 'carregado do produto' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Codigo Revisão Comissão que será' )
aAdd( aHlpSpa, 'carregado do produto' )

PutSX1Help( "PCK_XREVCOM", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "CK_XREVCOM" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo de Comissão Qualy' )
aAdd( aHlpPor, '01=Clliente;02=Produto;03=Vendedor;04=Ze' )
aAdd( aHlpPor, 'rada;05=Camapanha;06=Outros' )

aHlpEng := {}
aAdd( aHlpEng, 'Tipo de Comissão Qualy' )
aAdd( aHlpEng, '01=Clliente;02=Produto;03=Vendedor;04=Ze' )
aAdd( aHlpEng, 'rada;05=Camapanha;06=Outros' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Tipo de Comissão Qualy' )
aAdd( aHlpSpa, '01=Clliente;02=Produto;03=Vendedor;04=Ze' )
aAdd( aHlpSpa, 'rada;05=Camapanha;06=Outros' )

PutSX1Help( "PCK_XTPCOM ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "CK_XTPCOM" )

//
// Helps Tabela SCT
//
aHlpPor := {}
aAdd( aHlpPor, 'Meta de Volume e LItro' )

aHlpEng := {}
aAdd( aHlpEng, 'Meta de Volume e LItro' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Meta de Volume e LItro' )

PutSX1Help( "PCT_XLTVOL ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "CT_XLTVOL" )

//
// Helps Tabela SD1
//
aHlpPor := {}
aAdd( aHlpPor, 'Quantidade Conferida' )

aHlpEng := {}
aAdd( aHlpEng, 'Quantidade Conferida' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Quantidade Conferida' )

PutSX1Help( "PD1_QTDCOF ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_QTDCOF" )

aHlpPor := {}
aAdd( aHlpPor, 'Usuario Conferiu quantidade da N.F.' )

aHlpEng := {}
aAdd( aHlpEng, 'Usuario Conferiu quantidade da N.F.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Usuario Conferiu quantidade da N.F.' )

PutSX1Help( "PD1_USRCONF", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_USRCONF" )

aHlpPor := {}
aAdd( aHlpPor, 'Data da Transferencia para Almoxarifado.' )

aHlpEng := {}
aAdd( aHlpEng, 'Data da Transferencia para Almoxarifado.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Data da Transferencia para Almoxarifado.' )

PutSX1Help( "PD1_DTTRANS", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_DTTRANS" )

aHlpPor := {}
aAdd( aHlpPor, 'Item RNC' )

aHlpEng := {}
aAdd( aHlpEng, 'Item RNC' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Item RNC' )

PutSX1Help( "PD1_U_ITRNC", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_U_ITRNC" )

aHlpPor := {}
aAdd( aHlpPor, 'Unidade Medida Expedição' )

aHlpEng := {}
aAdd( aHlpEng, 'Unidade Medida Expedição' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Unidade Medida Expedição' )

PutSX1Help( "PD1_XUNEXP ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_XUNEXP" )

aHlpPor := {}
aAdd( aHlpPor, 'Qtde Multiplos Embalagem' )

aHlpEng := {}
aAdd( aHlpEng, 'Qtde Multiplos Embalagem' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Qtde Multiplos Embalagem' )

PutSX1Help( "PD1_XCLEXP ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_XCLEXP" )

aHlpPor := {}
aAdd( aHlpPor, 'Calculo Qtde Volume' )

aHlpEng := {}
aAdd( aHlpEng, 'Calculo Qtde Volume' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Calculo Qtde Volume' )

PutSX1Help( "PD1_XQTDVOL", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_XQTDVOL" )

aHlpPor := {}
aAdd( aHlpPor, 'Calculo Diferença Volume' )

aHlpEng := {}
aAdd( aHlpEng, 'Calculo Diferença Volume' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Calculo Diferença Volume' )

PutSX1Help( "PD1_XDIFVOL", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_XDIFVOL" )

aHlpPor := {}
aAdd( aHlpPor, 'Quantidade Min. Embalagem' )

aHlpEng := {}
aAdd( aHlpEng, 'Quantidade Min. Embalagem' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Quantidade Min. Embalagem' )

PutSX1Help( "PD1_XMINEMB", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_XMINEMB" )

aHlpPor := {}
aAdd( aHlpPor, 'Calculo do Peso Bruto' )

aHlpEng := {}
aAdd( aHlpEng, 'Calculo do Peso Bruto' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Calculo do Peso Bruto' )

PutSX1Help( "PD1_XPESBUT", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_XPESBUT" )

aHlpPor := {}
aAdd( aHlpPor, 'Calculo do Peso Liquido' )

aHlpEng := {}
aAdd( aHlpEng, 'Calculo do Peso Liquido' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Calculo do Peso Liquido' )

PutSX1Help( "PD1_XPESLIQ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_XPESLIQ" )

aHlpPor := {}
aAdd( aHlpPor, 'Peso Liquido do Cadastro de Produtos' )

aHlpEng := {}
aAdd( aHlpEng, 'Peso Liquido do Cadastro de Produtos' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Peso Liquido do Cadastro de Produtos' )

PutSX1Help( "PD1_XPLIQ  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_XPLIQ" )

aHlpPor := {}
aAdd( aHlpPor, 'Peso Bruto do Cadastro de Produtos' )

aHlpEng := {}
aAdd( aHlpEng, 'Peso Bruto do Cadastro de Produtos' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Peso Bruto do Cadastro de Produtos' )

PutSX1Help( "PD1_XPBRU  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_XPBRU" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo de Operação' )

aHlpEng := {}
aAdd( aHlpEng, 'Codigo de Operação' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Codigo de Operação' )

PutSX1Help( "PD1_XOPER  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_XOPER" )

aHlpPor := {}
aAdd( aHlpPor, 'Fator Aval.' )

aHlpEng := {}
aAdd( aHlpEng, 'Fator Aval.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Fator Aval.' )

PutSX1Help( "PD1_FATAVA ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_FATAVA" )

aHlpPor := {}
aAdd( aHlpPor, 'Id WF' )

aHlpEng := {}
aAdd( aHlpEng, 'Id WF' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Id WF' )

PutSX1Help( "PD1_EUWFID ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_EUWFID" )

//
// Helps Tabela SD2
//
aHlpPor := {}
aAdd( aHlpPor, 'Data Revisao Comissão no faturamento' )

aHlpEng := {}
aAdd( aHlpEng, 'Data Revisao Comissão no faturamento' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Data Revisao Comissão no faturamento' )

PutSX1Help( "PD2_XDTRVC ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D2_XDTRVC" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo Revisão Comissão  no faturamento' )

aHlpEng := {}
aAdd( aHlpEng, 'Codigo Revisão Comissão  no faturamento' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Codigo Revisão Comissão  no faturamento' )

PutSX1Help( "PD2_XREVCOM", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D2_XREVCOM" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo de Comissão Qualy' )
aAdd( aHlpPor, '01=Clliente;02=Produto;03=Vendedor;04=Ze' )
aAdd( aHlpPor, 'rada;05=Camapanha;06=Outros' )

aHlpEng := {}
aAdd( aHlpEng, 'Tipo de Comissão Qualy' )
aAdd( aHlpEng, '01=Clliente;02=Produto;03=Vendedor;04=Ze' )
aAdd( aHlpEng, 'rada;05=Camapanha;06=Outros' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Tipo de Comissão Qualy' )
aAdd( aHlpSpa, '01=Clliente;02=Produto;03=Vendedor;04=Ze' )
aAdd( aHlpSpa, 'rada;05=Camapanha;06=Outros' )

PutSX1Help( "PD2_XTPCOM ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D2_XTPCOM" )

aHlpPor := {}
aAdd( aHlpPor, 'Indicador' )

aHlpEng := {}
aAdd( aHlpEng, 'Indicador' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Indicador' )

PutSX1Help( "PD2_XNUMIND", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D2_XNUMIND" )

//
// Helps Tabela SE1
//
aHlpPor := {}
aAdd( aHlpPor, 'Neste caso será utilizado para Titulos' )
aAdd( aHlpPor, 'do Tipo NCC, para tratamentodas das' )
aAdd( aHlpPor, 'devoluções.' )

aHlpEng := {}
aAdd( aHlpEng, 'Neste caso será utilizado para Titulos' )
aAdd( aHlpEng, 'do Tipo NCC, para tratamentodas das' )
aAdd( aHlpEng, 'devoluções.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Neste caso será utilizado para Titulos' )
aAdd( aHlpSpa, 'do Tipo NCC, para tratamentodas das' )
aAdd( aHlpSpa, 'devoluções.' )

PutSX1Help( "PE1_XDEVCOM", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "E1_XDEVCOM" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo Ocorrencia RNC!' )

aHlpEng := {}
aAdd( aHlpEng, 'Tipo Ocorrencia RNC!' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Tipo Ocorrencia RNC!' )

PutSX1Help( "PE1_XTIPO  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "E1_XTIPO" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo de Comissão Qualy' )
aAdd( aHlpPor, '01=Clliente;02=Produto;03=Vendedor;04=Ze' )
aAdd( aHlpPor, 'rada;05=Camapanha;06=Outros' )

aHlpEng := {}
aAdd( aHlpEng, 'Tipo de Comissão Qualy' )
aAdd( aHlpEng, '01=Clliente;02=Produto;03=Vendedor;04=Ze' )
aAdd( aHlpEng, 'rada;05=Camapanha;06=Outros' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Tipo de Comissão Qualy' )
aAdd( aHlpSpa, '01=Clliente;02=Produto;03=Vendedor;04=Ze' )
aAdd( aHlpSpa, 'rada;05=Camapanha;06=Outros' )

PutSX1Help( "PE1_XTPCOM ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "E1_XTPCOM" )

aHlpPor := {}
aAdd( aHlpPor, 'Descrição da Ocorrencia  para leitura' )
aAdd( aHlpPor, 'dotitulo tipo NCC.' )

aHlpEng := {}
aAdd( aHlpEng, 'Descrição da Ocorrencia  para leitura' )
aAdd( aHlpEng, 'dotitulo tipo NCC.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Descrição da Ocorrencia  para leitura' )
aAdd( aHlpSpa, 'dotitulo tipo NCC.' )

PutSX1Help( "PE1_XDESC  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "E1_XDESC" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo Rnc Devolução' )

aHlpEng := {}
aAdd( aHlpEng, 'Codigo Rnc Devolução' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Codigo Rnc Devolução' )

PutSX1Help( "PE1_XCODRNC", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "E1_XCODRNC" )

aHlpPor := {}
aAdd( aHlpPor, 'Base de Comissão para apoio após a' )
aAdd( aHlpPor, 'baixa!' )

aHlpEng := {}
aAdd( aHlpEng, 'Base de Comissão para apoio após a' )
aAdd( aHlpEng, 'baixa!' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Base de Comissão para apoio após a' )
aAdd( aHlpSpa, 'baixa!' )

PutSX1Help( "PE1_XBASCOM", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "E1_XBASCOM" )

//
// Helps Tabela SE3
//
aHlpPor := {}
aAdd( aHlpPor, 'Tipo de Comissão' )

aHlpEng := {}
aAdd( aHlpEng, 'Tipo de Comissão' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Tipo de Comissão' )

PutSX1Help( "PE3_XTPCOM ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "E3_XTPCOM" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo Rnc de Devolução' )

aHlpEng := {}
aAdd( aHlpEng, 'Codigo Rnc de Devolução' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Codigo Rnc de Devolução' )

PutSX1Help( "PE3_XCODRNC", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "E3_XCODRNC" )

//
// Helps Tabela SE5
//
aHlpPor := {}
aAdd( aHlpPor, 'Desconta Comissão S/N ?' )

aHlpEng := {}
aAdd( aHlpEng, 'Desconta Comissão S/N ?' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Desconta Comissão S/N ?' )

PutSX1Help( "PE5_XDEVCOM", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "E5_XDEVCOM" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo Rnc de Devolução' )

aHlpEng := {}
aAdd( aHlpEng, 'Codigo Rnc de Devolução' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Codigo Rnc de Devolução' )

PutSX1Help( "PE5_XCODRNC", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "E5_XCODRNC" )

//
// Helps Tabela SED
//
aHlpPor := {}
aAdd( aHlpPor, 'Nova natureza' )

aHlpEng := {}
aAdd( aHlpEng, 'Nova natureza' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Nova natureza' )

PutSX1Help( "PED_XNEWNAT", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "ED_XNEWNAT" )

//
// Helps Tabela SF1
//
aHlpPor := {}
aAdd( aHlpPor, 'Conhecimento de Frete' )

aHlpEng := {}
aAdd( aHlpEng, 'Conhecimento de Frete' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Conhecimento de Frete' )

PutSX1Help( "PF1_COMPFT ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "F1_COMPFT" )

aHlpPor := {}
aAdd( aHlpPor, 'Ticket de Pesagem' )

aHlpEng := {}
aAdd( aHlpEng, 'Ticket de Pesagem' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Ticket de Pesagem' )

PutSX1Help( "PF1_TICPESA", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "F1_TICPESA" )

aHlpPor := {}
aAdd( aHlpPor, 'Fornecedor de Transporte' )

aHlpEng := {}
aAdd( aHlpEng, 'Fornecedor de Transporte' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Fornecedor de Transporte' )

PutSX1Help( "PF1_FORNTRP", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "F1_FORNTRP" )

aHlpPor := {}
aAdd( aHlpPor, 'Valor da NF de Conhecimen' )

aHlpEng := {}
aAdd( aHlpEng, 'Valor da NF de Conhecimen' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Valor da NF de Conhecimen' )

PutSX1Help( "PF1_VALFRT ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "F1_VALFRT" )

aHlpPor := {}
aAdd( aHlpPor, 'Id WF' )

aHlpEng := {}
aAdd( aHlpEng, 'Id WF' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Id WF' )

PutSX1Help( "PF1_EUWFID ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "F1_EUWFID" )

//
// Helps Tabela SUI
//
aHlpPor := {}
aAdd( aHlpPor, 'Doc. Devolução Cliente, meramente' )
aAdd( aHlpPor, 'informativo' )

aHlpEng := {}
aAdd( aHlpEng, 'Doc. Devolução Cliente, meramente' )
aAdd( aHlpEng, 'informativo' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Doc. Devolução Cliente, meramente' )
aAdd( aHlpSpa, 'informativo' )

PutSX1Help( "PUI_DOCDEV ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "UI_DOCDEV" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo carga da expedição' )

aHlpEng := {}
aAdd( aHlpEng, 'Codigo carga da expedição' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Codigo carga da expedição' )

PutSX1Help( "PUI_CARGA  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "UI_CARGA" )

aHlpPor := {}
aAdd( aHlpPor, 'Data Carga Expedição' )

aHlpEng := {}
aAdd( aHlpEng, 'Data Carga Expedição' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Data Carga Expedição' )

PutSX1Help( "PUI_DTCARGA", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "UI_DTCARGA" )

aHlpPor := {}
aAdd( aHlpPor, 'Desc. Ocorrencia' )

aHlpEng := {}
aAdd( aHlpEng, 'Desc. Ocorrencia' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Desc. Ocorrencia' )

PutSX1Help( "PUI_OCDESC ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "UI_OCDESC" )

aHlpPor := {}
aAdd( aHlpPor, 'Causa Tecnica' )

aHlpEng := {}
aAdd( aHlpEng, 'Causa Tecnica' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Causa Tecnica' )

PutSX1Help( "PUI_CAUTEC ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "UI_CAUTEC" )

aHlpPor := {}
aAdd( aHlpPor, 'Desc. Tecnica' )

aHlpEng := {}
aAdd( aHlpEng, 'Desc. Tecnica' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Desc. Tecnica' )

PutSX1Help( "PUI_CAUDSC ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "UI_CAUDSC" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo do vendedor' )

aHlpEng := {}
aAdd( aHlpEng, 'Codigo do vendedor' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Codigo do vendedor' )

PutSX1Help( "PUI_VEND   ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "UI_VEND" )

aHlpPor := {}
aAdd( aHlpPor, 'Nome do vendedor' )

aHlpEng := {}
aAdd( aHlpEng, 'Nome do vendedor' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Nome do vendedor' )

PutSX1Help( "PUI_DSCVEN ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "UI_DSCVEN" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo da Transportadora' )

aHlpEng := {}
aAdd( aHlpEng, 'Codigo da Transportadora' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Codigo da Transportadora' )

PutSX1Help( "PUI_TRANSP ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "UI_TRANSP" )

aHlpPor := {}
aAdd( aHlpPor, 'Nome Transportadora' )

aHlpEng := {}
aAdd( aHlpEng, 'Nome Transportadora' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Nome Transportadora' )

PutSX1Help( "PUI_DSCTRAN", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "UI_DSCTRAN" )

aHlpPor := {}
aAdd( aHlpPor, 'Nome Colaborador' )

aHlpEng := {}
aAdd( aHlpEng, 'Nome Colaborador' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Nome Colaborador' )

PutSX1Help( "PUI_XUSER  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "UI_XUSER" )

aHlpPor := {}
aAdd( aHlpPor, 'Data do Temino' )

aHlpEng := {}
aAdd( aHlpEng, 'Data do Temino' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Data do Temino' )

PutSX1Help( "PUI_DTFIM  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "UI_DTFIM" )

//
// Helps Tabela SZD
//
aHlpPor := {}
aAdd( aHlpPor, 'Numero Ordem de Produção' )

aHlpEng := {}
aAdd( aHlpEng, 'Numero Ordem de Produção' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Numero Ordem de Produção' )

PutSX1Help( "PZD_OP     ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "ZD_OP" )

aHlpPor := {}
aAdd( aHlpPor, 'Lote Referencia' )

aHlpEng := {}
aAdd( aHlpEng, 'Lote Referencia' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Lote Referencia' )

PutSX1Help( "PZD_LTREFER", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "ZD_LTREFER" )

//
// Helps Tabela ZZH
//
aHlpPor := {}
aAdd( aHlpPor, '% Comissão da Holding pago ao vendedor' )

aHlpEng := {}
aAdd( aHlpEng, '% Comissão da Holding pago ao vendedor' )

aHlpSpa := {}
aAdd( aHlpSpa, '% Comissão da Holding pago ao vendedor' )

PutSX1Help( "PZZH_COMIS1", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "ZZH_COMIS1" )

//
// Helps Tabela ZZJ
//
aHlpPor := {}
aAdd( aHlpPor, 'Codigo Tecnico' )

aHlpEng := {}
aAdd( aHlpEng, 'Codigo Tecnico' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Codigo Tecnico' )

PutSX1Help( "PZZJ_COD   ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "ZZJ_COD" )

aHlpPor := {}
aAdd( aHlpPor, 'Descrição Tecnica' )

aHlpEng := {}
aAdd( aHlpEng, 'Descrição Tecnica' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Descrição Tecnica' )

PutSX1Help( "PZZJ_DESC  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "ZZJ_DESC" )

//
// Helps Tabela ZZK
//
aHlpPor := {}
aAdd( aHlpPor, 'Tipo Ocorrencia que será utilizado na' )
aAdd( aHlpPor, 'rotina registro de não conformidade' )

aHlpEng := {}
aAdd( aHlpEng, 'Tipo Ocorrencia que será utilizado na' )
aAdd( aHlpEng, 'rotina registro de não conformidade' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Tipo Ocorrencia que será utilizado na' )
aAdd( aHlpSpa, 'rotina registro de não conformidade' )

PutSX1Help( "PZZK_TIPO  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "ZZK_TIPO" )

aHlpPor := {}
aAdd( aHlpPor, 'Descrição da Ocorrencia' )

aHlpEng := {}
aAdd( aHlpEng, 'Descrição da Ocorrencia' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Descrição da Ocorrencia' )

PutSX1Help( "PZZK_DESC  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "ZZK_DESC" )

aHlpPor := {}
aAdd( aHlpPor, 'Desconta Comissão S/N?' )

aHlpEng := {}
aAdd( aHlpEng, 'Desconta Comissão S/N?' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Desconta Comissão S/N?' )

PutSX1Help( "PZZK_DEVCOM", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "ZZK_DEVCOM" )

AutoGrLog( CRLF + "Final da Atualização" + " " + "Helps de Campos" + CRLF + Replicate( "-", 128 ) + CRLF )

Return {}


//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Função genérica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as seleções feitas.
             Se não for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()

//---------------------------------------------
// Parâmetro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta só com Empresas
// 3 - Monta só com Filiais de uma Empresa
//
// Parâmetro  aMarcadas
// Vetor com Empresas/Filiais pré marcadas
//
// Parâmetro  cEmpSel
// Empresa que será usada para montar seleção
//---------------------------------------------
Local   aRet      := {}
Local   aSalvAmb  := GetArea()
Local   aSalvSM0  := {}
Local   aVetor    := {}
Local   cMascEmp  := "??"
Local   cVar      := ""
Local   lChk      := .F.
Local   lOk       := .F.
Local   lTeveMarc := .F.
Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
Local   oOk       := LoadBitmap( GetResources(), "LBOK" )
Local   oDlg, oChkMar, oLbx, oMascEmp, oSay
Local   oButDMar, oButInv, oButMarc, oButOk, oButCanc

Local   aMarcadas := {}


If !MyOpenSm0(.F.)
	Return aRet
EndIf


dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 280, 395 Pixel

oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Máscara Empresa ( ?? )"  Of oDlg
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), IIf( Len( aRet ) > 0, oDlg:End(), MsgStop( "Ao menos um grupo deve ser selecionado", "UPDCREV" ) ) ) ;
Message "Confirma a seleção e efetua" + CRLF + "o processamento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela o processamento" + CRLF + "e abandona a aplicação" Of oDlg
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função auxiliar para inverter a seleção do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções

@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Função para marcar/desmarcar usando máscaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a máscara (???)
@param lMarDes  Marca a ser atribuída .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] := lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função auxiliar para verificar se estão todos marcados ou não

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0

Função de processamento abertura do SM0 modo exclusivo

@author UPDATE gerado automaticamente
@since  02/10/22
@obs    Gerado por EXPORDIC - V.7.5.2.2 EFS / Upd. V.5.3.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0( lShared )
Local lOpen := .F.
Local nLoop := 0

If FindFunction( "OpenSM0Excl" )
	For nLoop := 1 To 20
		If OpenSM0Excl(,.F.)
			lOpen := .T.
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop
Else
	For nLoop := 1 To 20
		dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

		If !Empty( Select( "SM0" ) )
			lOpen := .T.
			dbSetIndex( "SIGAMAT.IND" )
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop
EndIf

If !lOpen
	MsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return lOpen


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog

Função de leitura do LOG gerado com limitacao de string

@author UPDATE gerado automaticamente
@since  02/10/22
@obs    Gerado por EXPORDIC - V.7.5.2.2 EFS / Upd. V.5.3.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()

	cAux := FT_FREADLN()

	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()

Return cRet


/////////////////////////////////////////////////////////////////////////////
