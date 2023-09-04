#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

//Efetiva Aprovaçao / Bloqueio do Pedido de Compra
User Function BeP0202B()

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
//If !SCR->(DbSeek(xFilial("SC3")+"CP"+Padr(HttpPost->numpc,TamSX3("CR_NUM")[1])+HttpPost->nivapr))
If !SCR->(DbSeek(AllTrim(HttpPost->filped)+"CP"+Padr(HttpPost->numpc,TamSX3("CR_NUM")[1])+HttpPost->nivapr))
	cMsgHdr		:= "BEP0202B - Alçada Não Encontrada"
	cMsgBody	:= "A alçada de aprovação não foi encontrada!"
	cRetFun		:= "u_BeP0202.apw"
	
	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun})

ElseIf SCR->CR_STATUS <> "02"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³       	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMsgHdr		:= "BEP0202B - "+Iif(nOpc == 4,"Aprovação","Reprovação")+" Cancelada
	cMsgBody	:= "Aprovação ou reprovação realizada por outro usuário!"
	cRetFun		:= "u_BeP0202.apw"

ElseIf lSession .Or. HttpPost->numpc == Nil .Or. nOpc > 0
	dbSelectArea("SM0")
	dbSeek(cEmpAnt+HttpPost->filped,.T.)
	cFilAnt := SM0->M0_CODFIL
 
	dbSelectArea("SC3")
	dbSetOrder(1)
	//dbSeek(xFilial("SC3")+Alltrim(HttpPost->numpc))
	dbSeek(cFilAnt+Alltrim(HttpPost->numpc))
	cGrupo := SC3->C3_APROV

	dbSelectArea("SAK")
	dbSetOrder(1)
	dbSeek(xFilial("SAK")+Alltrim(HttpSession->ccodusr))
	
	dbSelectArea("SAL")       
	dbSetOrder(3)
	MsSeek(xFilial("SAL")+SC3->C3_APROV+SAK->AK_COD)    

	cHtml += Execblock("BePMenus",.F.,.F.)

	Begin	Transaction
    
  		While SCR->(!Eof())	.And. SCR->CR_FILIAL ==	xFilial("SCR") .And. SCR->CR_TIPO == "CP" .And. Alltrim(SCR->CR_NUM) == HttpPost->numpc
      
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
					lRet := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_APROV	,,SC3->C3_APROV,,,,,SCR->CR_OBS},dDatabase,nOpc )
					
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
						cMsgHdr		:= "BEP0202B - Contrato Parceria "+cOpc
						cMsgBody	:= "O contrato de parceria "+SCR->CR_NUM+" foi "+cOpc+" com sucesso!"
						cRetFun		:= "u_BeP0202.apw"
	
						cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
            				
						If lRet 

							MEnviaMail("034",{SC7->C7_NUM,SCR->CR_TIPO},/*SC7->C7_USER*/"000000") 				
							
							dbSelectArea("SC3")
							While !SC3->(Eof()) .And. SC3->C3_FILIAL+Substr(SC3->C3_NUM,1,len(SC3->C3_NUM)) == xFilial("SC3")+Substr(SCR->CR_NUM,1,len(SC3->C3_NUM))
								Reclock("SC3",.F.)
									SC3->C3_CONAPRO := "L"
								MsUnlock()
							
								SC3->(dbSkip())
							EndDo
                        EndIf
         	 		Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  						//³      	  ³
  						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cMsgHdr		:= "BEP0202B - Erro Inesperado "
						cMsgBody	:= "O contrato de parceria "+SCR->CR_NUM+" não pôde ser "+cOpc+". Entre em contato com o Administrador do Sistema!"
						cRetFun		:= "u_BeP0202.apw"
	
						cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
         	 		Endif  
        		Endif
      		
      			Exit

      		EndIf
      		
      		SCR->(DbSkip())
		EndDo  

	End Transaction
	
Else
	cMsgHdr		:= "BEP0202B - Sessão não Iniciada"
	cMsgBody	:= "A sessão não foi iniciada, realize o Login!"
	cRetFun		:= "u_BePLogin"
	
	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
EndIf

cHtml += Execblock("BePFooter",.F.,.F.)

WEB EXTENDED END

SM0->(dbGoTo(nRegSM0))
cFilAnt := SM0->M0_CODFIL

Return (EncodeUTF8(cHtml))