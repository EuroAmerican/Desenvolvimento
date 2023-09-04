#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TRYEXCEPTION.CH"

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

/*/{Protheus.doc} F330SE5
//Valida a inclusão de NF
//Esse Ponto de Entrada é chamado 2 vezes dentro da rotina A103Tudok(). 
//Para o controle do número de vezes em que ele é chamado foi criada a variável lógica lMT100TOK,que quando for definida como (.F.) o ponto de entrada será chamado somente uma vez.
//https://tdn.engpro.totvs.com.br/pages/releaseview.action?pageId=6085400
@type function Ponto de entrada
@author Fabio Carneiro dos Santos - Projeto DEVOLUÇÃO COMISSÃO   - 06/05/2022
@version  1.00
@return  retorno, verdadeiro ou falso
/*/
User Function MT100TOK

	Local aArea     	:= GetArea()
	Local aAreaSA2  	:= SA2->(GetArea())
	Local aAreaSA1  	:= SA1->(GetArea())
	Local lRet      	:= .T.
	Local lEstoque      := .F. // FS - Validar se TES atualiza estoque e verificar se houve amarraÃ§Ã£o com pesagem...
	Local lAmarra       := .F. // FS
	Local nLin          := 0   // FS
	Local cTES          := ""  // FS
	Local nX            := 0
	Local lDevSemRNC	:= .F.
	Local cFormul       := ""
	Local cQuery        := ""
	Local cProduto      := ""
	Local cTipo         := GetMv("QE_XTPPRD" , ,"PA/PI")
	
	Local cXespec       := GetMv( "MV_XESPEC" , ,"SPED#CTE#NFE#NFCF#CTR#NFS#NFSE#NFST#NFCEE#NFF#RPS#RECIB#INV#NFSC#NTST")

	Private oXML		:= Nil
	Private macroALIAS	:= IIf( AllTrim(cTipo) $ "N#C#I#P", "SA2", "SA1" )
	Private macroEST	:= IIf( AllTrim(cTipo) $ "N#C#I#P", "SA2->A2_EST", "SA1->A1_EST" )
	Private macroCLIFOR	:= IIf( AllTrim(cTipo) $ "N#C#I#P", "SA2->A2_COD", "SA1->A1_COD" )
	Private macroLOJA	:= IIf( AllTrim(cTipo) $ "N#C#I#P", "SA2->A2_LOJA", "SA1->A1_LOJA" )

	// Este P.E. excutado na utilizacao da funcao RETORNAR e algumas das 
	// regras retornavam falsa e a tela de documento de entrada nao era   
	// exibida ao usuario.                                                
	// Com a regra abaixo, as validacoes sao desconsideradas no momento da
	// da execucao do RETORNAR mas ser? acionadas ao clicar no botao      

If IsInCallStack("A103Devol") .And. l103Auto
	Return .T.
EndIf

If IsInCallStack("SPEDNFE") 
	Return .T.
EndIf

If IsInCallStack("MATA920") 
	Return .T.
EndIf

If FunName() <> "MATA920" 
	
	If lRet

		For nX := 1 To Len( aCols )

			If !(aCols[nX][Len(aHeader)+1])

				cProduto := aCols[ nX, GDFieldPos("D1_COD")]

				If RTrim(cTipo) == "D" .And. Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_TIPO") $ cTipo 

					If Select("TRB1") > 0
						TRB1->(DbCloseArea())
					EndIf

					cQuery := "SELECT UJ_CODIGO AS CODRNC " + CRLF
					cQuery += "FROM "+RetSqlName("SUI")+" AS SUI WITH (NOLOCK) " + CRLF
					cQuery += "INNER JOIN "+RetSqlName("SUJ")+" AS SUJ WITH (NOLOCK) ON UJ_FILIAL = UI_FILIAL  " + CRLF
					cQuery += "AND UJ_CODIGO = UI_CODIGO  " + CRLF
					cQuery += "AND UJ_ENTIDA = 'SUI' " + CRLF
					cQuery += "AND SUJ.D_E_L_E_T_ = ' '   " + CRLF
					cQuery += "INNER JOIN "+RetSqlName("ZZK")+" AS ZZK WITH (NOLOCK) ON ZZK_FILIAL = ' '  " + CRLF
					cQuery += "AND ZZK_TIPO = UI_MOTDEVO  " + CRLF
					cQuery += "AND ZZK.D_E_L_E_T_ = ' '   " + CRLF
					cQuery += "WHERE UI_FILIAL = '"+xFilial("SUI")+"' " + CRLF
					cQuery += "AND SUBSTRING(UI_SNOTA,1,3) = '"+aCols[nX,GDFieldPos("D1_SERIORI")]+"' " + CRLF
					cQuery += "AND SUBSTRING(UI_SNOTA,4,9) = '"+aCols[nX,GDFieldPos("D1_NFORI")]+"'  " + CRLF
					cQuery += "AND SUI.D_E_L_E_T_ = ' ' " + CRLF

					TCQUERY cQuery NEW ALIAS TRB1

					TRB1->(dbGoTop())

					While TRB1->(!Eof())
						
						If !Empty(TRB1->CODRNC)
							lDevSemRNC := .T.
						Else 
							lDevSemRNC := .F.
							Exit
						EndIf

						TRB1->(dbSkip())

					Enddo

					If !(lDevSemRNC)
						If !(aCols[nX][Len(aHeader)+1])
							cTES     := aCols[ nX, GDFieldPos("D1_TES")]
							dbSelectArea("SF4")
							dbSetOrder(1)
							If SF4->( dbSeek( xFilial("SF4") + cTES ) )
								If AllTrim( SF4->F4_DUPLIC ) == "S" 
									MsgStop("Item sem RNC Cadastrada, Favor contatar o SAC para regularizar!")
									lRet := .F.
									Exit
								EndIf

							EndIf
						
						EndIf

					EndIf

				EndIf

			EndIf

		Next nX

	EndIf

	If lRet .And.  AllTrim(cFormul) == "N" .And. Len(AllTrim(cNFiscal)) != 9
		MsgStop( "O campo de nota fiscal deve ser preenchido com 9 caracteres numericos." + ENTER +;
		"Se necessario, complete o campo com zeros a esquerda.", "Atenção" )
		lRet := .F.
	EndIf
	
	If lRet

		If AllTrim(cTipo) == "D" .And. AllTrim(cFormul) == "S"

			If AllTrim(cEspecie) $ "SPED#NFE"

				If ( AllTrim(cEspecie) == "SPED" .And. AllTrim(cSerie) == "REQ" ) .Or.;
				( AllTrim(cEspecie) == "NFE"  .And. AllTrim(cSerie) != "REQ" )

					lRet := .F.

					MsgStop("Especie invalida para o documento de devolução." + ENTER + ENTER +;
					"- Utilize a especie SPED quando a serie do documento for DIFERENTE de REQ;" + ENTER +;
					"- Utilize a especie NFE quando a serie do documento for IGUAL a REQ;" )

				EndIf

			Else

				lRet := .F.
				MsgStop("Especie invalida para o documento de devolução.")

			EndIf
		EndIf

	EndIf

	If lRet .And. .Not. AllTrim(cEspecie) $ cXespec//"SPED#CTE#NFE#NFCF#CTR#NFS#NFSE#NFST#NFCEE#NFF#RPS#RECIB#INV"
		MsgStop("A especie de documento nao e permitida. Verifique!")
		lRet := .F.
	EndIf

	If lRet .And. AllTrim(cEspecie) == "SPED" .And. AllTrim(cFormul) == "S" .And. dDEmissao != dDataBase
		MsgStop("Data invalida para operação!")
		lRet := .F.
	EndIf

	// FS - Se quantidade zero e atualiza estoque (somente custeio) n? permitir local 01...
	If lRet
		For nLin := 1 To Len( aCols )
			If !(aCols[nLin][Len(aHeader)+1])
				If aCols[ nLin, GDFieldPos("D1_QUANT")] == 0 .And. aCols[ nLin, GDFieldPos("D1_LOCAL")] $ AllTrim( GetMv("MV_CQ",,"01") )
					cTES := aCols[ nLin, GDFieldPos("D1_TES")]
					dbSelectArea("SF4")
					dbSetOrder(1)
					If SF4->( dbSeek( xFilial("SF4") + cTES ) )
						If AllTrim( SF4->F4_ESTOQUE ) == "S" .And. AllTrim( SF4->F4_TRANSIT ) <> "S"
							ApMsgAlert( "Não é permitido local de CQ 01 para quantidade igual a zero [0.00]!", "Atenção")
							lRet := .F.
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
		Next
	EndIf

	If lRet

		For nLin := 1 To Len( aCols )
			If !(aCols[nLin][Len(aHeader)+1])
				cTES := aCols[ nLin, GDFieldPos("D1_TES")]
				dbSelectArea("SF4")
				dbSetOrder(1)
				If SF4->( dbSeek( xFilial("SF4") + cTES ) )
					If AllTrim( SF4->F4_ESTOQUE ) == "S" .And. AllTrim( SF4->F4_TRANSIT ) <> "S"
						lEstoque := .T.
						Exit
					EndIf
				EndIf
			EndIf
		Next

		dbSelectArea("SA2")
		dbSetOrder(1)
		SA2->( dbSeek( xFilial("SA2") + cA100For + cLoja ) )

		If Left(SA2->A2_CGC, 8) $ GetMv("MV_EQ_CNPJ",,"01245930|03294570|04488985|07122447|10760710|10864589|17291293|")
			lEstoque := .F.
		ElseIf AllTrim( cTipo ) == "D"
			lEstoque := .F.
		ElseIf dDataBase <= STOD("20190830")
			lEstoque := .F.
		EndIf

		// Verifica se empresa deve possuir controle de pesagem / workflow...
		lEmp01    := SM0->M0_CODIGO $ GetMv("MV_EQ_SFEM",,"02|08|")
		cFilUsaWF := Alltrim(SuperGetMV("MV_EQ_FIWF",.F.,"00|01|03|",)) // Filiais habilitadas para utilizaÃ§Ã£o do controle de processo
		If lEmp01 .And. Alltrim( cFilAnt ) $ cFilUsaWF
			lEstoque := .F.
		EndIf

		If lEstoque
			If !(AllTrim(Left(cFilant, 2)) == "02" .And. AllTrim(Right(cfilant, 2)) == "00" .Or. AllTrim(Left(cFilant, 2)) == "08" .And. AllTrim(Right(cfilant, 2)) == "03")
				lEstoque := .F.
			EndIf
		EndIf

		// FS - Se atualiza estoque, verifica se houve amarraÃ§Ã£o com a pesagem...
		If lEstoque
			If Type("aSZZxSF1") == "A"
				If Len( aSZZxSF1 ) > 0
					lAmarra := .T.
				EndIf
			EndIf
			If !lAmarra
				ApMsgAlert( "Documento de entrada possui itens que atualizam estoques, contudo não houve amarração com a pesagem!" + CRLF + "Operação obrigatoria!", "Atenção")
				lRet := .F.
			EndIf
		EndIf

	EndIf

EndIf

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf
RestArea(aAreaSA1)
RestArea(aAreaSA2)
RestArea(aArea)

Return lRet
