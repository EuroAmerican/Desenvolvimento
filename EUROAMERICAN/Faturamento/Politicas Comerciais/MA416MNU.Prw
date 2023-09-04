


#include "rwmake.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#define ENTER CHR(13) + CHR(10)

/*
| Função...: MA416MNU()
| Autor....: Paulo Rogerio
| Data.....: 07/06/2023
| Retorno..: Nenhum
| Descricão: Inclusão de Opções no menu da rotina MATA416.
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User Function MA416MNU

IF U_xFilPComl()
	aAdd(aRotina,{'Analisar'    , 'U_QEMA416AN' , 0 , 4, 0, Nil})
	aAdd(aRotina,{'Estornar'    , 'U_QEMA415ES' , 0 , 4, 0, Nil})
	//aadd(aRotina,{'Rejeitar'    , 'U_QEMA416RE' , 0 , 4, 0, Nil})
ENDIF

Return



