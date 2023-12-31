#include "rwmake.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#define ENTER CHR(13) + CHR(10)

/*
| Fun��o...: MA415COR()
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
User Function MA415COR()
Local aCores := {}

aCores	:= {{'SCJ->CJ_STATUS=="A" .AND. Empty(SCJ->CJ_XLIBER)', 'ENABLE'},;		 	//Padr�o: Orcamento em Aberto
       	    {'SCJ->CJ_STATUS=="B" .AND. Empty(SCJ->CJ_XLIBER)', 'DISABLE'},;		//Padr�o: Orcamento Baixado
       	    {'SCJ->CJ_STATUS=="C"', 'BR_PRETO'},;									//Padr�o: Orcamento Cancelado
       	    {'SCJ->CJ_STATUS=="D"', 'BR_AMARELO'},;									//Padr�o: Orcamento nao Orcado
       	    {'SCJ->CJ_STATUS=="A" .AND. SCJ->CJ_XLIBER = "R"', 'BR_AZUL_CLARO'},;	//Custom: Orcamento Aberto/Rejeitado
       	    {'SCJ->CJ_STATUS=="B" .AND. SCJ->CJ_XLIBER <> " "', 'BR_VIOLETA'},;	    //Custom: Orcamento Baixado/Efetivado 
       	    {'SCJ->CJ_STATUS=="F"', 'BR_MARROM'}}									//Padr�o: Or�amento .....
Return(aCores)
