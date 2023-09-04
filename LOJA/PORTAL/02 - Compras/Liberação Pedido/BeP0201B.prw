#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

//Efetiva Aprovaçao / Bloqueio do Pedido de Compra
User Function BeP0201B()

Local cQuery	:= ""
Local cAlias	:= GetNextAlias()
Local cMsgHdr	:= ""
Local cMsgBody	:= ""
Local cRetfun	:= ""
Local cOpc		:= ""
Local nRegSM0	:= SM0->(Recno())

Local lRet		:= .F.
Local lLiberou	:= .F.
Local lSession 	:= Execblock("BePVSess",.F.,.F.) // Valida Sessão

Local nOpc		:= 0

Private cHtml 	:= ""    

WEB EXTENDED INIT cHtml                               

cHtml += Execblock("BePHeader",.F.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida Opção										      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If HttpPost->optlib <> Nil
	If HttpPost->optlib == "1"
		cOpc 	:= "Aprovado"
		nOpc	:= 4
	ElseIf HttpPost->optlib == "2"
		cOpc 	:= "Reprovado"
		nOpc	:= 6
	EndIf	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 													      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SCR")
SCR->(DbSetOrder(1))	
//If !SCR->(DbSeek(HttpPost->filped+"PC"+HttpPost->numpc)) // Tratar para linha de baixo, com nível e campo CR_NUM tamanho de 50 no padrão
//If !SCR->(DbSeek(xFilial("SC7")+"PC"+Padr(HttpPost->numpc,TamSX3("CR_NUM")[1])+HttpPost->nivapr))
If !SCR->(DbSeek(HttpPost->filped+"PC"+Padr(HttpPost->numpc,TamSX3("CR_NUM")[1])+HttpPost->nivapr))
	cMsgHdr		:= "BEP0201B - Alçada Não Encontrada"
	cMsgBody	:= "A alçada de aprovação não foi encontrada!"
	cRetFun		:= "u_BeP0201.apw"
	
	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 

ElseIf SCR->CR_STATUS <> "02"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³       	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMsgHdr		:= "BEP0201B - "+Iif(nOpc == 4,"Aprovação","Reprovação")+" Cancelada
	cMsgBody	:= "Aprovação ou reprovação realizada por outro usuário!"
	cRetFun		:= "u_BeP0201.apw"

ElseIf lSession .Or. HttpPost->numpc == Nil .Or. nOpc > 0
	dbSelectArea("SM0")
	dbSeek(cEmpAnt+HttpPost->filped,.T.)
	cFilAnt := SM0->M0_CODFIL
 
	dbSelectArea("SC7")
	dbSetOrder(1)
	//dbSeek(xFilial("SC7")+Alltrim(HttpPost->numpc))
	dbSeek(cFilAnt+Alltrim(HttpPost->numpc))
	cGrupo := SC7->C7_APROV

	dbSelectArea("SAK")
	dbSetOrder(1)
	dbSeek(xFilial("SAK")+Alltrim(HttpSession->ccodusr))
	
	dbSelectArea("SAL")       
	dbSetOrder(3)
	MsSeek(xFilial("SAL")+SC7->C7_APROV+SAK->AK_COD)    

	cHtml += Execblock("BePMenus",.F.,.F.)

	Begin	Transaction
    
  		While SCR->(!Eof())	.And. SCR->CR_FILIAL ==	xFilial("SCR") .And. SCR->CR_TIPO == "PC" .And. Alltrim(SCR->CR_NUM) == HttpPost->numpc
      
      		If AllTrim(SCR->CR_USER) == HttpSession->ccodusr .and. Empty(SCR->CR_USERLIB)

        		lRet := .t.

        		If lRet  

					/*
					±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
					±±³Sintaxe   ³ MaAlcDoc(ExpA1,ExpD1,ExpN1,ExpC1,ExpL1)               	  ³±±
					±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
					±±³Parametros³ ExpA1 = Array com informacoes do documento                 ³±±
					±±³          ³       [1] Numero do documento                              ³±±
					±±³          ³       [2] Tipo de Documento                                ³±±
					±±³          ³       [3] Valor do Documento                               ³±±
					±±³          ³       [4] Codigo do Aprovador                              ³±±
					±±³          ³       [5] Codigo do Usuario                                ³±±
					±±³          ³       [6] Grupo do Aprovador                               ³±±
					±±³          ³       [7] Aprovador Superior                               ³±±
					±±³          ³       [8] Moeda do Documento                               ³±±
					±±³          ³       [9] Taxa da Moeda                                    ³±±
					±±³          ³      [10] Data de Emissao do Documento                     ³±±
					±±³          ³      [11] Grupo de Compras                                 ³±±
					±±³          ³      [12] Aprovador Original                               ³±±
					±±³          ³ ExpD1 = Data de referencia para o saldo                    ³±±
					±±³          ³ ExpN1 = Operacao a ser executada                           ³±±
					±±³          ³       1 = Inclusao do documento                            ³±±
					±±³          ³       2 = Transferencia para Superior                      ³±±
					±±³          ³       3 = Exclusao do documento                            ³±±
					±±³          ³       4 = Aprovacao do documento                           ³±±
					±±³          ³       5 = Estorno da Aprovacao                             ³±±
					±±³          ³       6 = Bloqueio Manual da Aprovacao                     ³±±
					±±³          ³ ExpC1 = Chave(Alternativa) do SF1 para exclusao SCR        ³±±
					±±³          ³ ExpL1 = Eliminacao de Residuos                             ³±±
					*/
					lRet := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_APROV	,,SC7->C7_APROV,,,,,SCR->CR_OBS},dDatabase,nOpc )
					
      				// CR_STATUS== "01" Bloqueado p/ sistema (aguardando outros niveis)
      				// CR_STATUS== "02" Aguardando Liberacao do usuario
      				// CR_STATUS== "03" Pedido Liberado pelo usuario
      				// CR_STATUS== "04" Pedido Bloqueado pelo usuario
     	 			// CR_STATUS== "05" Pedido Liberado por outro usuario
          			If !Empty(SCR->CR_DATALIB) .And. SCR->CR_STATUS $ "03|04" 
          				If HttpPost->obslib <> Nil
            				RecLock("SCR",.F.)
            				SCR->CR_OBS := Transform(DecodeUTF8(HttpPost->obslib),"@x")
            				SCR->(MsUnLock())
            			EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  						//³       	  ³
  						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cMsgHdr		:= "BEP0201B - Pedido "+cOpc
						cMsgBody	:= "O pedido de compra "+SCR->CR_NUM+" foi "+cOpc+" com sucesso!"
						cRetFun		:= "u_BeP0201.apw"
	
						cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
            				
						If lRet 

							MEnviaMail("034",{SC7->C7_NUM,SCR->CR_TIPO},/*SC7->C7_USER*/"000000") 				
							
							If SuperGetMv("MV_EASY")=="S" .AND. SC7->(FieldPos("C7_PO_EIC"))<>0 .And. !Empty(SC7->C7_PO_EIC)
								If SW2->(MsSeek(xFilial("SW2")+SC7->C7_PO_EIC)) .AND. SW2->(FieldPos("W2_CONAPRO"))<>0 .AND. !Empty(SW2->W2_CONAPRO)
									Reclock("SW2",.F.)
									SW2->W2_CONAPRO := "L"
									MsUnlock()
								EndIf
							EndIf
						
							dbSelectArea("SC7")
							While !SC7->(Eof()) .And. SC7->C7_FILIAL+Substr(SC7->C7_NUM,1,len(SC7->C7_NUM)) == xFilial("SC7")+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM))
								Reclock("SC7",.F.)
								SC7->C7_CONAPRO := "L"
								MsUnlock()
							
								SC7->(dbSkip())
							EndDo
                        EndIf

						cQuery := "SELECT C7_FILIAL, C7_NUM " + CRLF
						cQuery += "FROM " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) " + CRLF
						cQuery += "WHERE C7_FILIAL = '" + xFilial("SC7") + "' " + CRLF
						cQuery += "AND C7_NUM = '" + AllTrim( SCR->CR_NUM ) + "' " + CRLF
						cQuery += "AND C7_PRODUTO LIKE 'RE%' " + CRLF
						cQuery += "AND C7_QUJE = 0 " + CRLF
						cQuery += "AND C7_CONAPRO = 'L' " + CRLF
						cQuery += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("SC7") + " WITH (NOLOCK) WHERE C7_FILIAL = SC7.C7_FILIAL AND C7_NUM = SC7.C7_NUM AND C7_CONAPRO = 'B' AND D_E_L_E_T_ = ' ') " + CRLF
						cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("SCR") + " WITH (NOLOCK) WHERE CR_FILIAL = C7_FILIAL AND CR_NUM = C7_NUM AND CR_TIPO = 'PC' AND CR_STATUS IN ('03','05') AND D_E_L_E_T_ = ' ') " + CRLF
						cQuery += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("SCR") + " WITH (NOLOCK) WHERE CR_FILIAL = C7_FILIAL AND CR_NUM = C7_NUM AND CR_TIPO = 'PC' AND CR_STATUS NOT IN ('03','05') AND D_E_L_E_T_ = ' ') " + CRLF
						cQuery += "AND D_E_L_E_T_ = ' ' " + CRLF
						cQuery += "GROUP BY C7_FILIAL, C7_NUM " + CRLF

						TCQuery cQuery New Alias "TMPSC7"
						dbSelectArea("TMPSC7")
						dbGoTop()

						If !TMPSC7->( Eof() )
							_aCabSF1   := {}
							_aItensSD1 := {}
							_aLinha    := {}
							cFornece   := ""
						
							cQry := " SELECT	ROW_NUMBER() OVER (ORDER BY C7_ITEM) AS ITEM, * "
							cQry += " FROM " + RetSqlName("SC7")
							cQry += " WHERE	D_E_L_E_T_ = '' AND C7_PRODUTO LIKE 'RE%' "
							cQry += " 		AND C7_NUM = '" + TMPSC7->C7_NUM + "' "
							cQry += " 		AND C7_FILIAL = '" + TMPSC7->C7_FILIAL + "' "
							cQry += " ORDER BY C7_ITEM "
						
							If Select("TSC7") > 0
								TSC7->(dbCloseArea())
							EndIf
						
							TCQUERY cQry NEW ALIAS TSC7
						
							dbSelectArea("TSC7")
							dbGoTop()
						
							If	!EOF("TSC7")
								lMsErroAuto     :=	.F.
								cFornece		:=	TSC7->C7_FORNECE
						
								Aadd(_aCabSF1,{"F1_FILIAL"		,TSC7->C7_FILIAL	,Nil})
								Aadd(_aCabSF1,{"F1_TIPO"		,"N"				,Nil})
								Aadd(_aCabSF1,{"F1_FORMUL"		,"N"				,Nil})
								Aadd(_aCabSF1,{"F1_DOC"			,StrZero(Val(TMPSC7->C7_NUM),9)	,Nil})
								Aadd(_aCabSF1,{"F1_SERIE"		,"REC"				,Nil})
								Aadd(_aCabSF1,{"F1_EMISSAO"		,dDataBase			,Nil})
								Aadd(_aCabSF1,{"F1_FORNECE"     ,TSC7->C7_FORNECE	,Nil})
								Aadd(_aCabSF1,{"F1_LOJA"		,TSC7->C7_LOJA		,Nil})
								Aadd(_aCabSF1,{"F1_ESPECIE"		,"RECIB"			,Nil})
								Aadd(_aCabSF1,{"F1_COND"		,TSC7->C7_COND		,Nil})
								Aadd(_aCabSF1,{"F1_DTDIGIT"		,dDataBase			,Nil})
								Aadd(_aCabSF1,{"F1_EST"			," "				,Nil})
								If	AllTrim(TSC7->C7_PRODUTO) $ "RE.0017"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"1403.1"		,Nil})
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0018"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"1606"			,Nil})
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0019"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"1304"			,Nil})
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0021"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"1519"			,Nil})
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0022"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"1402"			,Nil})
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0030"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"1403.2"		,Nil})
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0031"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"1901"			,Nil})
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0033"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"1931"			,Nil})
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0034"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"1932"			,Nil})
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0035"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"1514"			,Nil})
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0036"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"1802"			,Nil})
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0037"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"1803"			,Nil})
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0038"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"1804"			,Nil})
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0039"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"1801"			,Nil})
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0040"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"1806"			,Nil})
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0041"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"1899"			,Nil})
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0042"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"1447"			,Nil})
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0044"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"1719"			,Nil})
								Else
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"1917"			,Nil})
								EndIf
						
								While !EOF("TSC7")
									_aLinha		:=	{}
									Aadd(_aLinha,{"D1_FILIAL"	,TSC7->C7_FILIAL	,Nil})
									Aadd(_aLinha,{"D1_ITEM"		,StrZero(TSC7->ITEM,4),Nil})  //Alterado 28/09/2016 TSC7->C7_ITEM
									Aadd(_aLinha,{"D1_FORNECE"	,TSC7->C7_FORNECE	,Nil})
									Aadd(_aLinha,{"D1_LOJA"		,TSC7->C7_LOJA		,Nil})
									Aadd(_aLinha,{"D1_DOC"		,StrZero(Val(TMPSC7->C7_NUM),9)	,Nil})
									Aadd(_aLinha,{"D1_PEDIDO"	,TSC7->C7_NUM		,Nil})
									Aadd(_aLinha,{"D1_COD"		,TSC7->C7_PRODUTO	,Nil})
									Aadd(_aLinha,{"D1_UM"		,TSC7->C7_UM		,Nil})
									Aadd(_aLinha,{"D1_QUANT"	,TSC7->C7_QUANT		,Nil})
									Aadd(_aLinha,{"D1_VUNIT"	,TSC7->C7_PRECO		,Nil})
									Aadd(_aLinha,{"D1_TOTAL"	,TSC7->C7_TOTAL		,Nil})
									Aadd(_aLinha,{"D1_TES"		,IIf(Empty(AllTrim(TSC7->C7_TES)),"000",TSC7->C7_TES),Nil})
									Aadd(_aLinha,{"D1_CF"		,"1949"				,Nil})
									Aadd(_aLinha,{"D1_CC"		,TSC7->C7_CC		,Nil})
									Aadd(_aLinha,{"D1_ITEMPC"	,TSC7->C7_ITEM		,Nil})
									Aadd(_aLinha,{"D1_EMISSAO"	,dDataBase				})
									Aadd(_aLinha,{"D1_DTDIGIT"	,dDataBase			,Nil})
									Aadd(_aLinha,{"D1_LOCAL"	,TSC7->C7_LOCAL		,Nil})
									Aadd(_aLinha,{"D1_SERIE"	,"REC"				,Nil})
									Aadd(_aLinha,{"D1_TIPO"		,"N"				,Nil})
									Aadd(_aLinha,{"D1_FORMUL"	,"N"					})
									Aadd(_aLinha,{"D1_RATEIO"	,"2"				,Nil})
									Aadd(_aLinha,{"D1_TP"		,"RE"				,Nil})
									Aadd(_aLinha,{"AUTDELETA"	,"N"				,Nil})
									Aadd(_aItensSD1,_aLinha)
						
									TSC7->(dbSkip())
								EndDo
						
								MSExecAuto({|x,y,z| MATA103(x,y,z)},_aCabSF1,_aItensSD1,3)
						
								If lMsErroAuto
									//MostraErro()
								EndIf
							EndIf
						EndIf

						TMPSC7->( dbCloseArea() )
         	 		Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  						//³      	  ³
  						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cMsgHdr		:= "BEP0201B - Erro Inesperado "
						cMsgBody	:= "O pedido de compra "+SCR->CR_NUM+" não pôde ser "+cOpc+". Entre em contato com o Administrador do Sistema!"
						cRetFun		:= "u_BeP0201.apw"
	
						cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
         	 		Endif  
        		Endif
      		
      			Exit

      		EndIf
      		
      		SCR->(DbSkip())
		EndDo  

	End Transaction
	
Else
	cMsgHdr		:= "BEP0201B - Sessão não Iniciada"
	cMsgBody	:= "A sessão não foi iniciada, realize o Login!"
	cRetFun		:= "u_BePLogin"
	
	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
EndIf

cHtml += Execblock("BePFooter",.F.,.F.)

WEB EXTENDED END

SM0->(dbGoTo(nRegSM0))
cFilAnt := SM0->M0_CODFIL

Return (EncodeUTF8(cHtml))