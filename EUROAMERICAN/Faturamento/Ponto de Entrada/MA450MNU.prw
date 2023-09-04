#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"   
#include "protheus.ch"

#define ENTER CHR(13) + CHR(10)  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA450MNU  ºAutor  ³Tiago O. Beraldi    º Data ³  14/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ INCLUI FUNCOES NO AROTINA NA LIBERACAO DE CREDITO/ESTOQUE  º±±
±±º          ³                                                     		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                     A L T E R A C O E S                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ºProgramador       ºAlteracoes                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          º                  º                                         º±±
±±º          º                  º                                         º±±
±±º          º                  º                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
User Function MA450MNU  

//aAdd(aRotina, {"&Documentos", "U_GENA006(U_fMA450DOC(),'SA1')", 0, 2}) 
If AllTrim(Upper(cUserName)) $ "ADMINISTRADOR#ADRIANA.SILVA#JULIANA.ANTUNES"
	aAdd(aRotina, {"&Cliente", "U_fMA450SA1()", 0, 2}) 
	aAdd(aRotina, {"&Conhecimento", "MsDocument('SA1',SA1->(RecNo()), 4)", 0, 4,0,NIL})
EndIf

aAdd(aRotina, {"&Observacao", "U_fMA450OBS()", 0, 2}) 

Return 

//------------------------------------------------------------------------

/*User Function fMA450DOC()

Local aArea    := GetArea()  
Local aAreaSA1 := SA1->(GetArea())  
Local nRecNo   := 0

dbSelectArea("SA1")                        
dbSetOrder(1)		
dbSeek(xFilial("SA1") + SC9->C9_CLIENTE + SC9->C9_LOJA)    

nRecNo := SA1->(Recno())

RestArea( aArea )
RestArea( aAreaSA1 )

Return nRecNo*/

//------------------------------------------------------------------------

User Function fMA450SA1()

Local aArea		:= GetArea() 
Local aAreaSA1  := SA1->(GetArea())  
Local cEntidade	:= "SA1

aRotAuto  := Nil
cEntidade := "SA1"

dbSelectArea("SA1")                        
dbSetOrder(1)		
dbSeek(xFilial("SA1") + SC9->C9_CLIENTE + SC9->C9_LOJA)   

A030Altera(cEntidade,SA1->(Recno()),4)

RestArea( aArea )  
RestArea( aAreaSA1 )

Return

//------------------------------------------------------------------------

User Function fMA450OBS()

Local aArea      := GetArea()            
Local aAreaSC5   := SC5->(GetArea())   
Local aAreaSE4   := SE4->(GetArea())   

Local lBtnOK     := .F.   

Local cQry		 := ""   

Local aButtons	 := {}     
Local bOk	 	 := {|| IIf( !Empty(cGetObs), ( lBtnOK:=.T., oDlg:End() ), ( MsgStop("Campo observação é obrigatório."), lBtnOK:=.F. )) }
Local bCancel	 := {|| lBtnOK:=.F., oDlg:End() }   

Local cGetObs	 := Space(100)
Local oGetObs

Local oDlg

//+----------------------------------------------------------------------------
//| Posiciona arquivos
//+----------------------------------------------------------------------------
dbSelectArea("SC5")                        
dbSetOrder(1)		
dbSeek(xFilial("SC5") + SC9->C9_PEDIDO) 

dbSelectArea("SE4")                        
dbSetOrder(1)		
dbSeek(xFilial("SE4") + SC5->C5_CONDPAG) 
              
//+----------------------------------------------------------------------------
//| Monta janela de dialogo
//+----------------------------------------------------------------------------
DEFINE MSDIALOG oDlg TITLE "Observação Financeira" FROM  407 , 282  TO  576 , 716  PIXEL

	@  015 , 004  TO  050 , 216  LABEL "" PIXEL OF oDlg
	@  052 , 004  TO  085 , 216  LABEL "[ Observação ]" PIXEL OF oDlg

	@  022 , 010  Say "Pedido:" Size  020 , 008  COLOR CLR_BLACK PIXEL OF oDlg
	@  022 , 035  Say SC9->C9_PEDIDO Size  030 , 008  COLOR CLR_BLACK PIXEL OF oDlg
	@  022 , 075  Say "Condição de Pagto:" Size  050 , 008  COLOR CLR_BLACK PIXEL OF oDlg
	@  022 , 130  Say SE4->E4_CODIGO + "-" + SE4->E4_DESCRI Size  030 , 008  COLOR CLR_BLACK PIXEL OF oDlg
	@  035 , 010  Say "Cliente:" Size  018 , 008  COLOR CLR_BLACK PIXEL OF oDlg
	@  035 , 035  Say SC9->C9_CLIENTE + "-" + SC9->C9_LOJA + Space(3) + SA1->A1_NOME Size  175 , 008  COLOR CLR_BLACK PIXEL OF oDlg
	@  067 , 010  MsGet oGetObs Var cGetObs Size  200 , 009  COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED 

//+----------------------------------------------------------------------------
//| Atualiza arquivo
//+----------------------------------------------------------------------------
If lBtnOK

	/*cQry := "UPDATE " + RetSqlName("SC9") + ENTER
	cQry += "SET	C9_OBSFIN = '" + RTrim(cGetObs) + "' " + ENTER
	cQry += "WHERE	D_E_L_E_T_ = '' " + ENTER
	cQry += "	AND C9_FILIAL = '" + SC9->C9_FILIAL + "' " + ENTER      
	cQry += "	AND C9_PEDIDO = '" + SC9->C9_PEDIDO + "' " + ENTER
	
	If (TcSQLExec(cQry) < 0)
		MsgStop("TCSQLError() " + TCSQLError())
	EndIf*/
	
	dbSelectArea("SC9")
	
	RECLOCK("SC9",.F.)
		SC9->C9_OBSFIN := RTrim(cGetObs)
	MSUNLOCK()

EndIf

RestArea( aAreaSC5 )
RestArea( aAreaSE4 )
RestArea( aArea )

Return

//------------------------------------------------------------------------