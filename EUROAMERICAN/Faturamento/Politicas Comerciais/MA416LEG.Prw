#include "rwmake.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#define ENTER CHR(13) + CHR(10)

/*
| Fun��o...: MA416LEG()
| Autor....: Paulo Rogerio
| Data.....: 13/06/2023
| Retorno..: Nenhum
| Descric�o: Altera as cores da legenda da rotina MATA416.
|
| Observac.: 
| Objetivo.: 
| Documenta��o: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Altera��o
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User Function MA416LEG()
Local aCores := {{ 'ENABLE'      , 'Orcamento em Aberto' },;  //'Orcamento em Aberto'
				{ 'DISABLE'      , 'Orcamento Baixado' },;    //'Orcamento Baixado'
				{ 'BR_PRETO'     , 'Orcamento Cancelado' },;  //'Orcamento Cancelado'
				{ 'BR_AMARELO'   , 'Orcamento nao Orcado' },; //'Orcamento nao Orcado'
				{ 'BR_MARROM'    , 'Orcamento bloqueado' },;  //'Orcamento bloqueado'
				{ 'BR_AZUL_CLARO', 'Orcamento Aberto/Rejeitado'},;
				{ 'BR_VIOLETA'   , 'Orcamento Efetivado'}} 
			
Return(aCores)
