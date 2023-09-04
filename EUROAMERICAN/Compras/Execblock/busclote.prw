#INCLUDE "rwmake.ch"
#INCLUDE "Protheus.ch"

/*/{Protheus.doc} BuscLote - Rotina criada para consultar lotes fornecedor 
@Description: Foi criado para consultar o lote dos fornecedor, por que alguns produtos, não 
possuem controle de lote, porém necessitam saber qual a nota, serie, data.
@Document: MIQE044 - Especificacao_de_Personalizacao_consulta_lote_fornecedor
@author Fabio Carneiro dos Santos 
@since 06/01/2020
@version 1.0
/*/

User Function BuscLote()

Public _aCmpBrw  := {"D1_FILIAL","D1_COD","D9_LOCAL","D1_EMISSAO","D1_DTDIGIT","D1_LOTEFOR","D1_QUANT","D1_UM","D1_FORNECE","D1_LOJA","D1_DOC","D1_SERIE"}
							//Campos a serem mostrados no browse e no cadastro

_acampos:={{"Codigo Produto","D1_COD"},;
          {"Data Entrada","D1_DTDIGIT"},{"Lote Fornecedor","D1_LOTEFOR"},{"Numero Nota","D1_DOC"},;
		  {"Serie","D1_SERIE"},{"Data Emissão","D1_EMISSAO"},{"Numero Item","D1_ITEM"},;
		  {"Quantidade","D1_QUANT"},{"Local ","D1_LOCAL"}}
          
DbSelectArea("SD1")
DbSetOrder(1)
Private cCadastro  := "Consulta Lote Fornecedor Por Item"

Private aRotina := { { "Pesquisar" ,"AxPesqui", 0 , 1},;
					{ "Visualizar","AxVisual", 0 , 2}}


mBrowse(6,1,22,75,"SD1",_acampos)

DbSelectArea("SD1")

Return 	
