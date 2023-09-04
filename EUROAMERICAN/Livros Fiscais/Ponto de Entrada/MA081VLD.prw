#Include 'Protheus.Ch'
#Include 'TopConn.Ch'


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MA081VLD ºAutor  ³ Fabio F Sousa      º Data ³  10/25/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validar inclusão/alteração do cadastro de TES...           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
±± Modificado por: Evandro Peixoto  Data: 08/10/2019					   ±±	
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function MA081VLD()

Local lRetorno := .T.

lRetorno := BeVldUser()

//If lRetorno
//	lRetorno := BeVldTES()
//EndIf

//If lRetorno
//	BeNotTES()
//EndIf

Return lRetorno

User Function MA080VLD()

Local lRetorno := .T.

lRetorno := BeVldUser()

//If lRetorno
//	lRetorno := BeVldTES()
//EndIf

//If lRetorno
//	BeNotTES()
//EndIf

Return lRetorno

// Validar Acesso de Usuário....
Static Function BeVldUser()

Local lRetorno := .T.
Local cPermite := Alltrim(SuperGetMV("ES_TES001",.T.,"")) //AllTrim( GetMV("MV_BE_UTES",,"ADRIANA/CLAUDIA DANTAS/ADMINISTRADOR") )

IF !AllTrim( cUsername ) $ cPermite
	lRetorno := .F.
	ApMsgAlert("Usuário sem permissão para usar esta rotina.","Atenção")
Endif

Return lRetorno

// Validar Dados da TES....
Static Function BeVldTES()

Local lRetorno := .T.

Return lRetorno

/*// Notificar responsáveis pela TES....
Static Function BeNotTES()

Local lAltCpos   := .F.
Local cMensagem  := ""
Local lOk        := .T.
Local aAreaSX3   := SX3->( GetArea() )
Local aAreaSF4   := SF4->( GetArea() )
Local aArea      := GetArea()
Local lHistTab   := GetNewPar("MV_HISTTAB", .F.)
Local cFilialAIF := xFilial("AIF")
Local cFilialSF4 := xFilial("SF4")
Local aCpoAltSF4 := {}
Local cTipo      := ""
Local cConteudo  := ""
Local cResp      := ""
Local cNot       := GetMV("MV_BE_NTES",,"adriana@xisinformatica.com.br;claudia.dantas@beraca.com;fabio@xisinformatica.com.br")

dbSelectArea("SF4")
dbSetOrder(1)

If !SF4->( dbSeek( xFilial("SF4") + M->F4_CODIGO ) )
	lInclui := .T.
Else
	lInclui := .F.
EndIf

cMensagem += '</HEAD>'
cMensagem += '<BODY>'
cMensagem += '<BR><B>Notificação de ' + IIf(lInclui, 'Inclusão','Alteração') + ' no cadastro de TES</B>'
cMensagem += '<BR>'
cMensagem += '<BR>Usuário       : ' + cUserName
cMensagem += '<BR>Data          : ' + DTOC(dDataBase)
cMensagem += '<BR>Hora          : ' + Time()
cMensagem += '<BR>Código        : ' + M->F4_CODIGO
cMensagem += '<BR>Texto         : ' + M->F4_TEXTO
cMensagem += '<BR>Finalidade    : ' + M->F4_FINALID

If !lInclui
	cResp     := fVerMov( M->F4_CODIGO )
	cMensagem += '<BR>Já movimentou : ' + cResp
//	If AllTrim( Upper( Left( cResp, 3) ) ) == "SIM"
//		lRetorno  := .F.
//	EndIf
EndIf

cMensagem += '<TR>'
cMensagem += '<HR>'

If !lInclui
	cMensagem += 'Alterações:'
	cMensagem += '<HR>'

	cMensagem += "<Table Border=1>"
	cMensagem += "<TR>"
	cMensagem += "<TH><Font Face=Arial Size=-2>Campo</Font></TH>"
	cMensagem += "<TH><Font Face=Arial Size=-2>Conteúdo Anterior</Font></TH>"
	cMensagem += "<TH><Font Face=Arial Size=-2>Conteúdo Alterado</Font></TH>"
	cMensagem += "</TR>"

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek( "SF4" )

	dbSelectArea("SF4")
	dbSetOrder(1)

	If SF4->( dbSeek( xFilial("SF4") + M->F4_CODIGO ) )
		lAltCpos := .F.
		Do While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == "SF4"
			If &("M->" + AllTrim( SX3->X3_CAMPO )) != &("SF4->" + AllTrim( SX3->X3_CAMPO ))
				//If AllTrim( SX3->X3_CAMPO ) <> "F4_MSBLQL" .And. AllTrim( SX3->X3_CAMPO ) <> "F4_TESDV" .And. AllTrim( SX3->X3_CAMPO ) <> "F4_TEXTO" // FS - 08/04/2015 (Permitir também alteração da TES de devolução, pois não incide em calculos de impostos, apenas sugestão na operação)
				//	lAltCpos := .T.
				//EndIf

				cMensagem += "<TR>"
				cMensagem += "<TD><Font Face=Arial Size=-3 Color=Green>" + SX3->X3_CAMPO + "</Font></TD>"
				If AllTrim( SX3->X3_TIPO ) == "N"
					cMensagem += "<TD><Font Face=Arial Size=-3 Color=Green>" + Str( &("SF4->" + AllTrim( SX3->X3_CAMPO )) ) + "</Font></TD>"
					cMensagem += "<TD><Font Face=Arial Size=-3 Color=Green>" + Str( &("M->" + AllTrim( SX3->X3_CAMPO )) ) + "</Font></TD>"
				Else
					cMensagem += "<TD><Font Face=Arial Size=-3 Color=Green>" + &("SF4->" + AllTrim( SX3->X3_CAMPO )) + "</Font></TD>"
					cMensagem += "<TD><Font Face=Arial Size=-3 Color=Green>" + &("M->" + AllTrim( SX3->X3_CAMPO )) + "</Font></TD>"
				EndIf
				cMensagem += "</TR>"
			EndIf

			SX3->( dbSkip() )
		EndDo
	EndIf

	cMensagem += "</Table>"
	cMensagem += "<Hr>"
	cMensagem += '</TR>'
	cMensagem += '</TBODY>'
	cMensagem += '<TFOOT></TFOOT>'
	cMensagem += '</TABLE>'
	cMensagem += '</BODY>'

	If !lAltCpos
		//If !lRetorno
		//	lRetorno := .T. // Permite alteração caso o campo alterado seja apenas o de bloqueio...
		//EndIf
	Else
		//If !lRetorno
		//	Alert('Alteração da TES não é permitida, pois já houveram movimentações!!!')
		//	cMensagem += '<BR><Font Face=Arial Size=-4><B>ALTERAÇÃO NÃO PERMITIDA, JÁ HOUVE MOVIMENTAÇÃO</font></B>'
		//EndIf
	EndIf

	//If lRetorno
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega alterações efetuadas...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCpoAltSF4 := {}
	
		dbSelectArea("SX3")
		dbSetOrder(1)
	
		If SX3->( dbSeek( "SF4" ) )
			Do While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == "SF4"
				If &("M->" + AllTrim( SX3->X3_CAMPO )) != &("SF4->" + AllTrim( SX3->X3_CAMPO ))
					aAdd( aCpoAltSF4, { AllTrim( SX3->X3_CAMPO ), &("SF4->" + AllTrim( SX3->X3_CAMPO )) })
				EndIf
	
				SX3->( dbSkip() )
			EndDo
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravar o historico das alteracoes realizadas pelo usuario   ³
		//³ na tabela AIF usando o vetor aCpoAltSF4 que foi carregado   ³
		//³ na variavel de memoria.                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lHistTab .And. Len(aCpoAltSF4) > 0
			nX       := 0
			dDataAlt := Date()
			cHoraAlt := Time()
			For nX := 1 To Len(aCpoAltSF4)
				cTipo := TamSX3(aCpoAltSF4[nX][1])[3]
	
				If cTipo == "C" .And. ValType(aCpoAltSF4[nX][2]) == cTipo
					cConteudo := AllTrim( aCpoAltSF4[nX][2] )
				ElseIf cTipo == "N" .And. ValType(aCpoAltSF4[nX][2]) == cTipo
					cConteudo := AllTrim( Str( aCpoAltSF4[nX][2] ) )
				ElseIf cTipo == "D" .And. ValType(aCpoAltSF4[nX][2]) == cTipo
					cConteudo := DTOC( aCpoAltSF4[nX][2] )
				ElseIf cTipo == "L" .And. ValType(aCpoAltSF4[nX][2]) == cTipo
					cConteudo := IIf( aCpoAltSF4[nX][2], ".T.", ".F.")
				EndIf
	
				RecLock( "AIF", .T.)
					AIF->AIF_FILIAL   := cFilialAIF
					AIF->AIF_FILTAB   := cFilialSF4
					AIF->AIF_TABELA   := "SF4"
					AIF->AIF_CODIGO   := M->F4_CODIGO
					AIF->AIF_CAMPO    := aCpoAltSF4[nX][1]
					AIF->AIF_CONTEU   := cConteudo
					AIF->AIF_DATA     := dDataAlt
					AIF->AIF_HORA     := cHoraAlt
				MsUnLock()
			Next nX
			aCpoAltSF4 := {}
		EndIf
	//EndIf
EndIf

cMensagem += '<TR>'
cMensagem += '<BR>' + SM0->M0_NOMECOM

cAssunto := 'Notificação de ' + IIf(lInclui, 'Inclusão','Alteração') + ' no cadastro de TES: ' + M->F4_CODIGO

U_BeSendMail( { cNot, cAssunto, cMensagem} )

SX3->( RestArea( aAreaSX3 ) )
SF4->( RestArea( aAreaSF4 ) )
RestArea( aArea )

Return

Static Function fVerMov( cTES )

Local cMovim := "Não"
Local cQuery := ""
Local nSoma  := 0

aEmp := {}
SM0->(dbGotop())
While SM0->(!Eof())
	_xemp := aScan( aEmp, {|x| x[1] == SM0->M0_CODIGO})
	If _xemp == 0 
		AADD(aEmp, {SM0->M0_CODIGO} )
	Endif
	SM0->(dbSkip())
Enddo

cQuery := "SELECT SUM(CONTA) AS CONTA, TAB FROM (" + CRLF
For _i := 1 to len(aEmp)
	If _i <> 1
		cQuery += "UNION all " + CRLF
	Endif
	cQuery += "SELECT COUNT(*) AS CONTA, 'SD1' AS TAB FROM " + RetSqlName("SD1") + " " + CRLF
	cQuery += "WHERE D1_TES = '" + cTES + "' " + CRLF
	cQuery += "AND D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION all " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTA, 'SD2' AS TAB FROM " + RetSqlName("SD2") + " " + CRLF
	cQuery += "WHERE D2_TES = '" + cTES + "' " + CRLF
	cQuery += "AND D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION all " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTA, 'SC6' AS TAB FROM " + RetSqlName("SC6") + " " + CRLF
	cQuery += "WHERE C6_TES = '" + cTES + "' " + CRLF
	cQuery += "AND D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION all " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTA, 'SC7' AS TAB FROM " + RetSqlName("SC7") + " " + CRLF
	cQuery += "WHERE C7_TES = '" + cTES + "' " + CRLF
	cQuery += "AND D_E_L_E_T_ = ' ' " + CRLF
Next
cQuery += ") AS AGRUPADO " + CRLF
cQuery += "GROUP BY TAB " + CRLF

TCQuery cQuery New Alias "TMPTES"
dbSelectArea("TMPTES")
dbGoTop()

If !TMPTES->(Eof())
	Do While !TMPTES->( Eof() )
		nSoma += TMPTES->CONTA

		TMPTES->( dbSkip() )
	EndDo

	If nSoma > 0
		cMovim := "Sim <BR> "
		
		cMovim += "<Table Border=1>"
		cMovim += "<TR>"
		cMovim += "<TH><Font Face=Arial Size=-3>Tabela</Font></TH>"
		cMovim += "<TH><Font Face=Arial Size=-3>Quantidade</Font></TH>"
		cMovim += "</TR>"
		
		TMPTES->( dbGoTop() )
		
		Do While !TMPTES->( Eof() )
			cMovim += "<TR>"
			cMovim += "<TD><Font Face=Arial Size=-3 Color=Blue>" + TMPTES->TAB + "</Font></TD>"
			cMovim += "<TD><Font Face=Arial Size=-3 Color=Blue>" + Transform( TMPTES->CONTA, "@E 999,999,999") + "</Font></TD>"
			cMovim += "</TR>"
	
			TMPTES->( dbSkip() )
		EndDo
		cMovim += "</Table>"
	EndIf
EndIf

TMPTES->( dbCloseArea() )

Return cMovim*/