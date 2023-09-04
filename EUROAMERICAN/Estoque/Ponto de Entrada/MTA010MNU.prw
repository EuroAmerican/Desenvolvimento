#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} mt010inc
//PE utilizado para gerar o EAN 13 
@author 
@since 07/02/2018
@version 1.0
@type function
/*/

User Function MTA010MNU()

aAdd(aRotina, { "Gerar Código de Barras" ,"U_EQCodBar"	, 0 , 5, 1, nil} )		
aAdd(aRotina, { "Import. Unidade Expedição" ,"U_QEIUNEXP"	, 0 , 6, 1, nil} )		

Return ()
