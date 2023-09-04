#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

//Transferência Superior
User Function BeP0207B()

Local cQuery	:= ""
Local cAlias	:= GetNextAlias()
Local cMsgHdr	:= ""
Local cMsgBody	:= ""
Local cRetfun	:= ""
//Local nRegSM0	:= SM0->(Recno())
Local lRet		:= .F.
Local lSession 	:= Execblock("BePVSess",.F.,.F.) // Valida Sessão
Local cCodUser  := ""
Local cCodAprov := ""

Private cHtml 	:= ""    

WEB EXTENDED INIT cHtml                               

cHtml += Execblock("BePHeader",.F.,.F.)

If lSession
	dbSelectArea("SAK")
	dbSetOrder(2)
	dbSeek(xFilial("SAK")+Alltrim(HttpSession->ccodusr))

	cQuery := "SELECT CR_FILIAL, CR_TIPO, CR_NUM, CR_USER, R_E_C_N_O_ " + CRLF
	cQuery += "FROM " + RetSqlName("SCR") + " AS SCR WITH (NOLOCK) " + CRLF
	cQuery += "WHERE CR_FILIAL = '" + xFilial("SCR") + "' " + CRLF
	cQuery += "AND CR_APROV = '" + HttpPost->codapr + "' " + CRLF
	cQuery += "AND (CR_STATUS='02' OR CR_STATUS='04') " + CRLF
	cQuery += "AND SCR.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPSCR"
	dbSelectArea("TMPSCR")
	TMPSCR->( dbGoTop() )

	Do While !TMPSCR->( Eof() )
		dbSelectArea("SCR")
		dbSetOrder(2)
		dbSeek( xFilial("SCR") + TMPSCR->CR_TIPO + TMPSCR->CR_NUM + TMPSCR->CR_USER )

		Begin Transaction
			MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,,SAK->AK_COD,SAK->AK_USER,,,SCR->CR_MOEDA,SCR->CR_TXMOEDA,,"Tranferido por Ausencia"},,2)
		End Transaction	

		TMPSCR->( dbSkip() )
	EndDo

	TMPSCR->( dbCloseArea() )

	cMsgHdr		:= "BeP0207B - Ausencia Temporária"
	cMsgBody	:= "Transferências de documentos realizadas com sucesso!"
	cRetFun		:= "u_BeP0207.apw"
	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
Else
	cMsgHdr		:= "BeP0207B - Sessão não Iniciada"
	cMsgBody	:= "A sessão não foi iniciada, realize o Login!"
	cRetFun		:= "u_BePLogin.apw"
	
	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
EndIf

cHtml += Execblock("BePFooter",.F.,.F.)

WEB EXTENDED END

Return (EncodeUTF8(cHtml))
