


#include "rwmake.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#define ENTER CHR(13) + CHR(10)

/*
| Fun��o...: MA415MNU()
| Autor....: Paulo Rogerio
| Data.....: 07/06/2023
| Retorno..: Nenhum
| Descric�o: Inclus�o de Op��es no menu da rotina MATA415.
|
| Observac.: 
| Objetivo.: 
| Documenta��o: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Altera��o
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User Function MA415MNU

IF U_xFilPComl()
	aAdd(aRotina,{'Importar XML'      , 'U_FATM025("SCJ")'   , 0 , 3, 0, Nil}) // aAdd(aRotina,{'Importar XML', 'U_FATM025("SCJ")'   , 0 , 3, 0, Nil})
	aadd(aRotina,{'Liberar Or�am'     , 'U_QEMA415LI' , 0 , 3, 0, Nil})
	aAdd(aRotina,{'Estornar Liber'    , 'U_QEMA415ES' , 0 , 4, 0, Nil})
	aadd(aRotina,{'Historico Lib'     , 'U_QEMA415HI' , 0 , 9, 0, Nil})
	//aadd(aRotina,{'Desagrupar'        , 'U_QEMA415DE' , 0 , 9, 0, Nil})
Endif

Return

