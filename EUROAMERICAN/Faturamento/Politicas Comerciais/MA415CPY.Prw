
#include "TOTVS.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#define ENTER CHR(13) + CHR(10)

/*
| Função...: MT415CPY()
| Autor....: Paulo Rogerio
| Data.....: 07/06/2023
| Retorno..: Nenhum
| Descricão: Exclusão de campos na copia do Orçamento na rotina MATA416.
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User Function MT415CPY
Local aCampos := {}

aadd(aCampos, "CJ_XPEDCLI")
aadd(aCampos, "CJ_XLIBER")
aadd(aCampos, "CJ_XDESADC")
aadd(aCampos, "CJ_XJUSADC")
aadd(aCampos, "CJ_XOBSADC")
aadd(aCampos, "CJ_XDESCF")
aadd(aCampos, "CJ_XDESMIX")

aadd(aCampos, "CJ_XDESSCO")
aadd(aCampos, "CJ_XDESLOG")
aadd(aCampos, "CJ_XDESFIN")

aadd(aCampos, "CJ_XMCIND")
aadd(aCampos, "CJ_XMCGRP")
aadd(aCampos, "CJ_XDESGRP")

aadd(aCampos, "CJ_DESC1")
aadd(aCampos, "CJ_OBS")

aadd(aCampos, "CJ_XTOTIMP")
aadd(aCampos, "CJ_XCUSTO")
aadd(aCampos, "CJ_XLTPROC")

Return(aCampos)
