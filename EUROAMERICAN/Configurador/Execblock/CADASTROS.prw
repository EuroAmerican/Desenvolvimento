// #########################################################################################
// Projeto: Cadastros Genéricos
// Modulo :
// Fonte  : ${sourceFileName}
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor Emerson Paiva      | Descricao Criação fonte
// ---------+-------------------+-----------------------------------------------------------
// ${date}  | TOTVS Developer Studio | Gerado pelo Assistente de Código
// ---------+-------------------+-----------------------------------------------------------

#include "rwmake.ch"

user function CADZZH()
	//-- variáveis ---------------------------------------------------------------------------
	
	//Indica a permissão ou não para a operação (pode-se utilizar 'ExecBlock')
	local cVldAlt := ".T." // Operacao: ALTERACAO
	local cVldExc := ".T." // Operacao: EXCLUSAO
	
	//trabalho/apoio
	local cAlias
	local cTitulo	:= "Cadastro de Holdings"
	
	//-- configuração de 'pergunte' e tecla de atalho ----------------------------------------
	//pergunte(${parameters}, .f.)
	//"setKey(123,{|| pergunte("${description}", .t.)}) // Acionamento dos parametros - tecla F12"
	
	//-- procedimentos -----------------------------------------------------------------------
	cAlias := "ZZH"	//"${alias}"
	chkFile(cAlias)
	dbSelectArea(cAlias)
	//indices
	dbSetOrder(1)
	axCadastro(cAlias, cTitulo, cVldExc, cVldAlt)
	
	//setKey(123, nil) // Desativa a tecla F12 para acionamento dos parametros
	
return

user function CADZZA()
	//-- variáveis ---------------------------------------------------------------------------
	
	//Indica a permissão ou não para a operação (pode-se utilizar 'ExecBlock')
	local cVldAlt := ".T." // Operacao: ALTERACAO
	local cVldExc := ".T." // Operacao: EXCLUSAO
	
	//trabalho/apoio
	local cAlias
	local cTitulo	:= "Cadastro de Solicitantes x CC"
	
	//-- configuração de 'pergunte' e tecla de atalho ----------------------------------------
	//pergunte(${parameters}, .f.)
	//"setKey(123,{|| pergunte("${description}", .t.)}) // Acionamento dos parametros - tecla F12"
	
	//-- procedimentos -----------------------------------------------------------------------
	cAlias := "ZZA"	//"${alias}"
	chkFile(cAlias)
	dbSelectArea(cAlias)
	//indices
	dbSetOrder(1)
	axCadastro(cAlias, cTitulo, cVldExc, cVldAlt)
	
	//setKey(123, nil) // Desativa a tecla F12 para acionamento dos parametros
	
return
