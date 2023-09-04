#include "rwmake.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#define ENTER CHR(13) + CHR(10)

/*
| Função...: MA416COR()
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
User Function MA416COR()
Local aCores := {}


aCores	:= {{'SCJ->CJ_STATUS=="A" .AND. Empty(SCJ->CJ_XLIBER)', 'ENABLE'},;		 	//Padrão: Orcamento em Aberto
       	    {'SCJ->CJ_STATUS=="B" .AND. Empty(SCJ->CJ_XLIBER)', 'DISABLE'},;		//Padrão: Orcamento Baixado
       	    {'SCJ->CJ_STATUS=="C"', 'BR_PRETO'},;									//Padrão: Orcamento Cancelado
       	    {'SCJ->CJ_STATUS=="D"', 'BR_AMARELO'},;									//Padrão: Orcamento nao Orcado
       	    {'SCJ->CJ_STATUS=="A" .AND. SCJ->CJ_XLIBER = "R"' , 'BR_AZUL_CLARO'},;	//Custom: Orcamento Aberto/Rejeitado
       	    {'SCJ->CJ_STATUS=="B" .AND. SCJ->CJ_XLIBER <> " "', 'BR_VIOLETA'},;	    //Custom: Orcamento Baixado/Efetivado 
       	    {'SCJ->CJ_STATUS=="F"', 'BR_MARROM'}}									//Padrão: Orçamento .....
Return(aCores)
