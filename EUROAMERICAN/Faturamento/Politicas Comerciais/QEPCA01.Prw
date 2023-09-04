
#include "rwmake.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"

/*
| Função...: QEPCA01()
| Autor....: Paulo Rogerio
| Data.....: 12/06/2023
| Retorno..: Nenhum
| Descricão: Cadastro de Pontuação do Score.
|
| Observac.: 
| Objetivo.: 
| Documentação: 
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/

User Function QEPCA01()
    //Private oBrowse := FwMBrowse():New()

    Local cCadastro := "Cadastro de Pontuação Score"
    Local cAlias    := "ZZ4"


    If !cFilant $ "0803/0901"
        Alert("Rotina disponivel apenas para está empresa/filial")
        Return
    Endif

     AxCadastro(cAlias, cCadastro, "U_QEPCA01E()", "U_QEPCA01A()")
Return(.T.)

User Function QEPCA01E()
    MSGALERT( "Exclusão não Permitida!"+chr(13)+chr(10)+" Use o Status do Registro para torná-lo Inativo.", "Exclusão" )
Return(.F.)


User Function QEPCA01A()
Local lRet := .T.

IF Altera
    IF M->ZZ4_PERIOD <> ZZ4->ZZ4_PERIOD .or. M->ZZ4_RANGE1 <> ZZ4->ZZ4_RANGE1 .or. M->ZZ4_RANGE2 <> ZZ4->ZZ4_RANGE2 .or. M->ZZ4_DESCON <> ZZ4->ZZ4_DESCON
        lRet := .F.

        MSGALERT( "Alteração não Permitida!"+chr(13)+chr(10)+" Use o Status do Registro para torná-lo Inativo.", "Alterção")
    Endif
Endif

Return(lRet)
