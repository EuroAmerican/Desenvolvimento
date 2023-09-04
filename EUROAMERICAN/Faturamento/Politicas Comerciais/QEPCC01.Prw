
#include "rwmake.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"

/*
| Função...: QEPCC01()
| Autor....: Paulo Rogerio
| Data.....: 12/06/2023
| Retorno..: Nenhum
| Descricão: Manutenção de Lotes de Processamento
|
| Observac.: 
| Objetivo.: 
| Documentação: 
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/

User Function QEPCC01()

    Local cCadastro := "Lotes de Processamento"
    Local cAlias    := "ZZ5"


    If !cFilant $ "0803/0901"
        Alert("Rotina disponivel apenas para está empresa/filial")
        Return
    Endif

     AxCadastro(cAlias, cCadastro, "U_QEPCC01E()", "U_QEPCC01A()")
Return(.T.)

User Function QEPCC01E()
    MSGALERT( "Exclusão não Permitida!"+chr(13)+chr(10)+" Use o Status do Registro para torná-lo Inativo.", "Exclusão" )
Return(.F.)


User Function QEPCC01A()
    //MSGALERT( "Inclusão ou alteração não Permitida!"+chr(13)+chr(10)+" Use a opção de visualização.", "Manutenção" )
Return(.T.)
