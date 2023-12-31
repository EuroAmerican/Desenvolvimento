#Include "Protheus.ch"

/*/{Protheus.doc} MA040TOK
/@type function Ponto de Entrada Validar a Inclus�o do Cadastro de Vendedores 
@version 1.00
@author Paulo Rog�rio  
@since 28/03/2023
@return 
@History  
/*/

User Function MA040TOK()  //--A040TudoOK() //MA040VLD()
Local aArea    := GetArea()
Local cMsgErro := ""
Local lRet     := .T.



//MSGINFO("AVISO DE ALTERA��O FUTURA NESTA ROTINA:"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+"Ap�s a Conclus�o da Revis�o do Cadastro de vendedores, ser� ATIVADA a valida��o de Niveis de Hierarquia!!!", "MA040TOK")
//Return(.T.)


IF M->A3_XNIVEL == "S" .AND. (!empty(M->A3_SUPER) .OR. !empty(M->A3_GEREN))
    cMsgErro := "N�o deve ser Informado c�digo de Gerente ou Supervisor para o vendedor que possui hierarquia de Supervisor!!!"

ElseIF M->A3_XNIVEL == "G" .AND. !empty(M->A3_GEREN) 
    cMsgErro := "N�o deve ser Informado c�digo de Gerente para o vendedor que possui hierarquia de Gerente!!!"

ElseIF M->A3_XNIVEL == "G" .AND. empty(M->A3_SUPER) 
    cMsgErro := "O c�digo do Supervisor � obrigat�rio para o vendedor que possui hierarquia de Gerente!!!"

ElseIF M->A3_XNIVEL == "V" .AND. !empty(M->A3_SUPER) 
    cMsgErro := "N�o deve ser Informado c�digo de Supervisor para o vendedor que possui hierarquia de Vendedor!!!"

ElseIF M->A3_XNIVEL == "V" .AND. empty(M->A3_GEREN) 
    cMsgErro :=  "O c�digo do Gerente � obrigat�rio para o vendedor que possui hierarquia de Vendedor!!!"
Endif


IF !Empty(cMsgErro)
    MSGALERT(cMsgErro + chr(13)+chr(10)+chr(13)+chr(10)+"Em caso de d�vidas, contate o administrador do sistema.", "MA040TOK" )
    lRet := .F.
Endif


RestArea(aArea)    

Return(lRet)

