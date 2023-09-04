#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#include "xmlxfun.ch"
#include "shell.ch"
#include "tryexception.ch"
#Include "FileIO.ch"

/*/{Protheus.doc} chamlogs
//TODO - Tela modelo 1 
@author Fabio Batista
@since 10/02/2021
@version 1.0
@return ${return}, ${return_description} .T. 
@param 
@type function
/*/
User Function PRODREV()
     
LOCAL cAlias      := 'PZ1'
Private cCadastro := 'Cadastro Produtos de Revenda'
Private aRotina   := { }

AADD(aRotina, { 'Pesquisar'  , 'AxPesqui' , 0, 1 })
AADD(aRotina, { 'Visualizar' , 'AxVisual' , 0, 2 })
AADD(aRotina, { 'Incluir'    , 'AxInclui' , 0, 3 })
AADD(aRotina, { 'Alterar'    , 'AxAltera' , 0, 4 })
AADD(aRotina, { 'Excluir'    , 'AxDeleta' , 0, 5 })

dbSelectArea(cAlias)
dbSetOrder(1)

mBrowse(6, 1, 22, 75, cAlias,,,,,,)

Return NIL
