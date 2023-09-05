#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'
#Include 'fileio.Ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EQEdiDcc º Autor ³      º Data ³   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³    º±±
±±º          ³                                     º±±
±±º          ³                                     º±±
±±º          ³                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

----------------------------------------------------------------------------
Ateração: Paulo Rogério
Data....: 06/06/2023
Projeto.: Politicas Comerciais QUALY
Objetivo: Ao Invés de grava Pedido de Venda a rotina passa a gravar
          o Orçemento de Vendas, a fim de submeter o pedido as regras
		  da policita comercial Qualy.
-----------------------------------------------------------------------------
/*/

User Function EQEdiDcc()

Private lPreparado 	:= SELECT("SX6") == 0  	                          // Verifica se ambiente ja esta preparado
Private lProcessa  	:= .F.
Private lShow       := .T.
Private lHide       := .T.

Private cQuery     	:= ""
Private cIPFTP     	:= '186.202.119.87'                               // IP de conexão com o FTP...
Private nPortFTP   	:= 21                                             // Porta de conexão com o FTP...
Private cUsrFTP    	:= 'Qualyvinil'                                   // Usuário para conexão com o FTP...
Private cPwdFTP    	:= 'QsWdxv2C'                                     // Senha de conexão com o FTP...

Private aErros	   	:= {}
Private aProcs		:= {}
Private aAlert		:= {}

// Prepara o ambiente para processamento...
If lPreparado
	RpcClearEnv()
	PREPARE ENVIRONMENT EMPRESA "10" FILIAL "0803"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se houver conexão com FTP Ok...                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If IsFTP( { cIPFTP, nPortFTP, cUsrFTP, cPwdFTP} )
	fMensagem(.T.,  "Iniciando a Conexão FTP do Integrador Dicicco!")

	// Executa a rotina de Importação do XML via FTP
	ImpFTP( '\EDI\Dicico\Entrada\', { cIPFTP, nPortFTP, cUsrFTP, cPwdFTP} )

	fMensagem(.T.,  "Finalizando a Conexão FTP do Integrador Dicicco!")
	
	// Disconecta o FTP
	FTPDisconnect()
Else
	fMensagem(lPreparado,  "Erro na Conexão FTP do Integrador Dicicco!", 2)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o      ³ ImpFTP   ³ Autor ³          ³ Data ³ 03/08/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao   ³ Importa arquivo de pasta FTP para Integração               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros  ³ cPasta == Pasta do RootPatch \...                          ³±±
±±³            ³ aConexao[1] Informe o IP do FTP                            ³±±
±±³            ³ aConexao[2] Informe a Porta                                ³±±
±±³            ³ aConexao[3] Informe o Usuário                              ³±±
±±³            ³ aConexao[4] Informe a Senha                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpFTP( cPasta, aConexao )

//Local lOk        := .F.
//Local lRetorno   := .T.
Local nArqs      := 0
Local aRetDir    := {}
//Local cEndFtp    := aConexao[1]
//Local nPorFtp    := aConexao[2]
//Local cUsuFtp    := aConexao[3]
//Local cSenFtp    := aConexao[4]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna arquivos conforme filtro do diretório IN no servidor FTP      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FTPDirChange( '/IN/' )
aRetDir := FTPDIRECTORY( "*.xml" )

If Len(aRetDir) > 0
	For nArqs := 1 To Len( aRetDir )

		// Seleciona a pasta de origem do arquivo XML no FTP
		FTPDirChange( '/IN/' )

		// Faz Download do Arquivo XML via FTP
		If !FtpDownload( cPasta + aRetDir[nArqs][1], aRetDir[nArqs][1])
			fMensagem(lPreparado,  "Erro no Download do Arquivo: "+Alltrim(aRetDir[nArqs][1])+", no FTP do Integrador Dicicco!", 2)			
		Else
			fMensagem(lHide,  "Sucesso no Download do Arquivo "+Alltrim(aRetDir[nArqs][1])+", no FTP do Integrador Dicicco!", 1)

			// Apaga o arquivo XML na pasta IN do Servidor FTP
			FtpErase( AllTrim(aRetDir[nArqs][1]) )

			fMensagem(lHide,  "Exclusão do Arquivo "+Alltrim(aRetDir[nArqs][1])+", na pasta IN do FTP do Integrador Dicicco!", 1)


			//=========================================================
			// Chama a rotina de Inclusão do pedido de Venda no SC5/SC6
			//=========================================================
			If U_EQPVDcc(cPasta + aRetDir[nArqs][1], "SCJ")
				fMensagem(lPreparado,  "Pedido de Venda Incluido pelo arquivo "+Alltrim(aRetDir[nArqs][1])+", do FTP do Integrador Dicicco!", 2)	
			
				// Transfere arquivo para pasta processados...    			                
				Copy File &(cPasta + aRetDir[nArqs][1]) TO &('\EDI\Dicico\Processado\' +  aRetDir[nArqs][1])
				fMensagem(lHide,  "Arquivo "+Alltrim(aRetDir[nArqs][1])+" foi movido para a pasta processados no FTP do Integrador Dicicco!", 2)	
			Else
				//ConOut( "**** ERRO NA INCLUSÃO DO PEDIDO DE VENDA DO ARQUIVO "+Alltrim(aRetDir[nArqs][1])+" EM "+DtoC(MsDate())+" "+Time()+" ****")
				fMensagem(lPreparado,  "Erro na Inclusao do Pedido de Venda pelo Arquivo "+Alltrim(aRetDir[nArqs][1])+".", 2)	

				// Transfere arquivo para pasta de erros    			               
				Copy File &(cPasta + aRetDir[nArqs][1]) TO &('\EDI\Dicico\Erros\' +  aRetDir[nArqs][1])
				fMensagem(lHide,  "Arquivo "+Alltrim(aRetDir[nArqs][1])+" foi movido para a pasta erros no FTP do Integrador Dicicco!", 2)	
			EndIf

			// Configura a pasta de importados no FTP
			FTPDirChange( '/Importados/' )
			If FTPUpload(cPasta + aRetDir[nArqs][1] , aRetDir[nArqs][1] )
				fMensagem(lHide,  "Arquivo "+Alltrim(aRetDir[nArqs][1])+"foi movido para a pasta importados no FTP do Integrador Dicicco!", 2)	
			Else
				fMensagem(lHide,  "Erro ao mover o Arquivo "+Alltrim(aRetDir[nArqs][1])+" para a pasta importados no FTP do Integrador Dicicco!", 2)	
			EndIf
			
			// Exclusão do arquivo da pasta de entrada do protheus.
			IF FErase(cPasta + aRetDir[nArqs][1]) == -1
				fMensagem(lHide,  "Erro na exclusao do Arquivo "+Alltrim(aRetDir[nArqs][1])+" do diretorio de entrada "+cPasta + aRetDir[nArqs][1], 2)	
			Else
				fMensagem(lHide,  "Arquivo "+Alltrim(aRetDir[nArqs][1])+" Ecluido do diretorio de entrada "+cPasta + aRetDir[nArqs][1], 2)	
			EndIf
		EndIf
	Next
Else
	//ConOut( "**** NENHUM ARQUIVO ENCONTRADO FTP INTEGRATOR DICICO EM "+DtoC(MsDate())+" "+Time()+" ****")
	fMensagem(lPreparado,  "Nenhum arquivo foi encontrado no FTP INTEGRATOR DICICO.", 2)	
EndIf

//ConOut( "**** FTP INTEGRATOR DICICO DESCONECTADO EM "+DtoC(MsDate())+" "+Time()+" ****")
//fMensagem(lHide,  "Finalizando o processo no FTP INTEGRATOR DICICO.", 2)	
//FTPDisconnect()

If Len(aErros) > 0 .Or. Len(aProcs) > 0 
	EnvRel()
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EQEdiDcc º Autor ³      º Data ³   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³    º±±
±±º          ³                                     º±±
±±º          ³                                     º±±
±±º          ³                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function IsFTP(aConn)
      
Local lRet := .F.

If FTPConnect(aConn[1],aConn[2],aConn[3],aConn[4],.T.)           
	ConOut( "**** FTP INTEGRATOR DICICO CONECTADO EM "+DtoC(MsDate())+" "+Time()+" ****")
	lRet := .T.
Else
	ConOut( "**** FALHA CONEXÃO FTP INTEGRATOR DICICO EM "+DtoC(MsDate())+" "+Time()+" ****")
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ EnvRel	³ Autor ³ Rodrigo Sousa         ³ Data ³ 16/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Função para envio de relatório via email 				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EnvRel()

Local oProc
Local oHtml
Local nX := 0

oProc 	:= TWFProcess():New("100100","Notificação Integração Dicico")
oProc:NewTask('Inicio',"\workflow\html\EQNotDcc.html")
oHtml	:= oProc:oHtml

oHtml:valbyname( "cEmpresa"	, "Qualyvinil" )
oHtml:valbyname( "cCodFil"	, "10 - Filial 0803" )
oHtml:valbyname( "dDtProc"	, DtoC(dDatabase))
oHtml:valbyname( "cHora"	, Time())

If Len(aProcs) > 0
	For nX := 1 to Len(aProcs)
		aAdd( (oHtml:valbyname( "it.cArquivo" 		)), aProcs[nX][01] 	) 
		aAdd( (oHtml:valbyname( "it.cCliente" 		)), aProcs[nX][02] 	) 
		aAdd( (oHtml:valbyname( "it.cPCCliente"		)), aProcs[nX][03] 	) 
		aAdd( (oHtml:valbyname( "it.cPedVen" 		)), aProcs[nX][04] 	) 

		EqVPrcTb(aProcs[nX][01], aProcs[nX][04])

	Next nX
Else
	aAdd( (oHtml:valbyname( "it.cArquivo" 		)), "Não há Pedidos Processados" 	) 
	aAdd( (oHtml:valbyname( "it.cCliente" 		)), "" 	) 
	aAdd( (oHtml:valbyname( "it.cPCCliente"		)), "" 	) 
	aAdd( (oHtml:valbyname( "it.cPedVen" 		)), "" 	) 
EndIf


If Len(aAlert) > 0
	For nX := 1 to Len(aAlert)
		aAdd( (oHtml:valbyname( "itA.cArqAlert" 	)), aAlert[nX][01] 	) 
		aAdd( (oHtml:valbyname( "itA.cMsgAlert" 	)), aAlert[nX][02] 	) 
		aAdd( (oHtml:valbyname( "itA.cPCAlert"		)), aAlert[nX][03] 	) 
		aAdd( (oHtml:valbyname( "itA.cPedVenAlert"	)), aAlert[nX][04] 	) 
	Next nX
Else
	aAdd( (oHtml:valbyname( "itA.cArqAlert" 	)), "Não há alertas" 	) 
	aAdd( (oHtml:valbyname( "itA.cMsgAlert" 	)), "" 	) 
	aAdd( (oHtml:valbyname( "itA.cPCAlert"		)), "" 	) 
	aAdd( (oHtml:valbyname( "itA.cPedVenAlert"	)), "" 	) 
EndIf


If Len(aErros) > 0
	For nX := 1 to Len(aErros)
		aAdd( (oHtml:valbyname( "it2.cArqErro" 		)), aErros[nX][01] 	) 
		aAdd( (oHtml:valbyname( "it2.cMsgErro" 		)), aErros[nX][02] 	) 
		aAdd( (oHtml:valbyname( "it2.cPCErro"		)), aErros[nX][03] 	) 
		aAdd( (oHtml:valbyname( "it2.cPCItem" 		)), aErros[nX][04] 	) 
	Next nX
Else
	aAdd( (oHtml:valbyname( "it2.cArqErro" 		)), "Não há erros" 	) 
	aAdd( (oHtml:valbyname( "it2.cMsgErro" 		)), "" 	) 
	aAdd( (oHtml:valbyname( "it2.cPCErro"		)), "" 	) 
	aAdd( (oHtml:valbyname( "it2.cPCItem" 		)), "" 	) 
EndIf

ConOut('Envio de E-Mail Automatico - Integração Dicico'  )

oProc:cTo 	:= Alltrim("ellen.ataide@qualyvinil.com.br;ti@euroamerican.com.br")

oProc:cSubject := "Protheus | Notificação Integração Dicico"
oProc:Start()
oProc:Finish()
wfsendmail()

ConOut( "**** ENVIO DE EMAIL INTEGRAÇÃO FTP INTEGRATOR DICICO EM "+DtoC(MsDate())+" "+Time()+" ****")

Return


Static Function EqVPrcTb(cArqProc, cPedVld)

Local cQuery 	:= ""
Local cAlias	:= GetNextAlias()

cQuery := "SELECT C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, "+CRLF
cQuery += "C6_PRCVEN, C6_PRUNIT, C6_NUMPCOM, C6_ITEMPC"+CRLF
cQuery += "FROM "+RetSqlName("SC6")+" SC6"+CRLF
cQuery += "WHERE C6_FILIAL = '"+xFilial("SC6")+"'"+CRLF
cQuery += "AND C6_NUM = '"+cPedVld+"' "+CRLF
cQuery += "AND C6_QTDLIB = 0"+CRLF
cQuery += "AND C6_PRCVEN <> C6_PRUNIT"+CRLF
cQuery += "AND SC6.D_E_L_E_T_ = ''"+CRLF

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
EndIf

TcQuery cQuery New Alias (cAlias)

While !(cAlias)->(Eof())

	cMsg := "O Valor do Produto "+Alltrim((cAlias)->C6_PRODUTO)+" está divergente com o valor da Tabela de Preço. Valor Pedido R$ "+Transform((cAlias)->C6_PRCVEN,PesqPict("SC6","C6_PRCVEN"))+;
			" Valor Tabela de Preço R$ "+Transform((cAlias)->C6_PRUNIT,PesqPict("SC6","C6_PRUNIT"))

	aAdd(aAlert,{cArqProc,cMsg,(cAlias)->C6_NUMPCOM,(cAlias)->C6_NUM})	

	(cAlias)->(dbSkip())
End

(cAlias)->(dbCloseArea())

Return



User Function EQEdiMn()

If Left(cFilAnt,2) == '08' //.And. Left(cFilAnt,2) == '03'
	Msgrun("Processando Importação Dicico. Aguarde...","Aguarde",{|| u_EQEdiDcc()})
Else
	MsgStop("Empresa não autorizada a utilizar essa rotina.", "Atenção")
EndIf
Return


Static Function fMensagem(lOculta, cMsg, nTipo)
	IF lOculta
		ConOut("Data / Hora:"+DtoC(MsDate())+" / "+Time() + " *** "+UPPER(cMsg)+ " ***")
	Else
		IF nTipo == 1
			MsgInfo(cMsg,"Importação de PV")
		Else
			MsgAlert(cMsg,"Importação de Orçamento")
		Endif
	Endif
Return
