#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} mta650mnu
//PE usado para inserir informacoes no browse da Ordem de Producao
@author mjlozzardo
@since 19/01/2018
@version 1.0
@type function
/*/
User Function mta650mnu()

	//aAdd(aRotina, {"Gerar Etiquera CB0"   , "U_MEST001", 0, 2, Nil})
	//aAdd(aRotina, {"Manut. etiqueta"  	  , "U_MEST004", 0, 2, Nil})
	aAdd(aRotina, {"Impressão de Etiqueta", "U_REST002" , 0, 2, Nil})
	aAdd(aRotina, {"Revalidação de Etiqueta", "U_QEETQREV" , 0, 2, Nil})
	aAdd(aRotina, {"Etiqueta p/Pallet"    , "U_REST004" , 0, 2, Nil})
	aAdd(aRotina, {"Etiq.Caixa Coletiva"  , "U_REST005" , 0, 2, Nil})
	aAdd(aRotina, {"Etiq. Kits"           , "U_QETIQ002", 0, 2, Nil})
	aAdd(aRotina, {"Etiqueta HENKEL"      , "U_EQEtHenk", 0, 2, Nil}) // FS - Imprime direto etiqueta Henkel conforme layout padrão do cliente
	aAdd(aRotina, {"Mod Ant. Ordem Prd"   , "U_EQNewOP2( SC2->C2_NUM )", 0, 2, Nil})
	aAdd(aRotina, {"Mod Novo Ordem Prd"   , "U_EQNewOP3( SC2->C2_NUM )", 0, 2, Nil})

Return
