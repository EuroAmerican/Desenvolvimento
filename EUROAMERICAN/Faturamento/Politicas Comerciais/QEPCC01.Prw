
#include "rwmake.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"

/*
| Fun��o...: QEPCC01()
| Autor....: Paulo Rogerio
| Data.....: 12/06/2023
| Retorno..: Nenhum
| Descric�o: Manuten��o de Lotes de Processamento
|
| Observac.: 
| Objetivo.: 
| Documenta��o: 
|
| Data       Programador    Altera��o
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/

User Function QEPCC01()

    Local cCadastro := "Lotes de Processamento"
    Local cAlias    := "ZZ5"


    If !cFilant $ "0803/0901"
        Alert("Rotina disponivel apenas para est� empresa/filial")
        Return
    Endif

     AxCadastro(cAlias, cCadastro, "U_QEPCC01E()", "U_QEPCC01A()")
Return(.T.)

User Function QEPCC01E()
    MSGALERT( "Exclus�o n�o Permitida!"+chr(13)+chr(10)+" Use o Status do Registro para torn�-lo Inativo.", "Exclus�o" )
Return(.F.)


User Function QEPCC01A()
    //MSGALERT( "Inclus�o ou altera��o n�o Permitida!"+chr(13)+chr(10)+" Use a op��o de visualiza��o.", "Manuten��o" )
Return(.T.)
