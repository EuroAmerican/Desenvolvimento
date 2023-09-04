#include 'protheus.ch'
#include 'parmtype.ch'
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"

#define ENTER chr(13) + chr(10)

/*/{Protheus.doc}QEACESE1
//compatibilizador para acertar as parcelas referente a tabela SE1
@author Fabio Carneiro dos Santos 
@since 24/04/2021
@version 1.0
/*/

User Function QEACESE1()

    Local aSays    := {}
	Local aButtons := {}
	Local nOpca    := 0
	Local cTitoDlg := "ALTERA  PARCELA DE 3 CARACTERE P/ 1 CARACTERE"
    Private _cPerg := "QEACET1"

	aAdd(aSays, "Esta rotina tem por objetivo alterar as parcelas para 1 caractere - Titulo Tipo NF")
    aAdd(aSays, "Será trocado todos os titulos de parcela numerica para 1 caractere a partir de 22/04/2021! ")
    aAdd(aSays, "Serão Titulos em aberto que não foram baixados e enviados para o banco")
	aAdd(aSays, "***Esta atualização é por Filial, Necessario rodar logado na Filial***")

	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	
    If nOpca == 1
	
		oAjustaSx1()

		If !Pergunte(_cPerg,.T.)
			Return
		Else 
			Processa({|| QEACESE1ok("Gravando alteração das parcelas dos titulos a partir de 22/04/2021 ...")})
		Endif
		
	EndIf

Return

/*
+------------+------------+--------+---------------+-------+--------------+
| Programa:  | QEACESE1ok | Autor: | QUALY         | Data: | 03/03/21     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEACESE1ok                                    |
+------------+------------------------------------------------------------+
*/

Static Function QEACESE1ok()

Local cQueryA       := ""
Local cQueryC       := ""

Local lPassa        := .F.

Private TRB1        := GetNextAlias()

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf

cQueryA := "SELECT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA, E1_TIPO  " + ENTER
cQueryA += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
cQueryA += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
cQueryA += " AND E1_PREFIXO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'   " + ENTER
cQueryA += " AND E1_NUM     BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'   " + ENTER
cQueryA += " AND E1_PARCELA BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'   " + ENTER
cQueryA += " AND E1_CLIENTE BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'   " + ENTER
cQueryA += " AND E1_LOJA    BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'   " + ENTER
cQueryA += " AND E1_EMISSAO BETWEEN '"+DtoS(MV_PAR11)+"' AND '"+DtoS(MV_PAR12)+"'   " + ENTER
cQueryA += " AND E1_TIPO = 'NF ' " + ENTER  
cQueryA += " AND LEN(E1_PARCELA) = 3 " + ENTER  
cQueryA += " AND E1_SALDO > 0 " + ENTER  
cQueryA += " AND E1_STATUS  = 'A' " + ENTER  
cQueryA += " AND E1_SITUACA = '0' " + ENTER  
cQueryA += " AND E1_EMISSAO >= '20210422' " + ENTER  
cQueryA += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
cQueryA += " ORDER BY E1_NUM, E1_PARCELA  " + ENTER

TcQuery cQueryA ALIAS "TRB1" NEW

TRB1->(DbGoTop())
	
ProcRegua(TRB1->(LastRec()))
	
While TRB1->(!Eof())

	lPassa := .F.
	
	cQueryC := ""

	dbSelectArea("SE1")
    dbSetOrder(2)
	SE1->(DbGoTop())
    
	If DbSeek(xFilial("SE1")+TRB1->E1_CLIENTE+TRB1->E1_LOJA+TRB1->E1_PREFIXO+TRB1->E1_NUM+TRB1->E1_PARCELA+TRB1->E1_TIPO ) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	
		lPassa := .T.
	
	EndIf

	If lPassa
	
		If TRB1->E1_PARCELA	== '001' 

			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = SUBSTRING(E1_PARCELA,3,1) " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
					
			TCSqlExec( cQueryC )
				
		ElseIf TRB1->E1_PARCELA	== '002' 

			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = SUBSTRING(E1_PARCELA,3,1) " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
					
			TCSqlExec( cQueryC )
	
		ElseIf TRB1->E1_PARCELA	== '002' 

			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = SUBSTRING(E1_PARCELA,3,1) " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
					
			TCSqlExec( cQueryC )
		
		ElseIf TRB1->E1_PARCELA	== '003' 

			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = SUBSTRING(E1_PARCELA,3,1) " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
					
			TCSqlExec( cQueryC )
		
		ElseIf TRB1->E1_PARCELA	== '004' 

			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = SUBSTRING(E1_PARCELA,3,1) " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
					
			TCSqlExec( cQueryC )
	
		ElseIf TRB1->E1_PARCELA	== '005' 

			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = SUBSTRING(E1_PARCELA,3,1) " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
					
			TCSqlExec( cQueryC )
	
		ElseIf TRB1->E1_PARCELA	== '006' 

			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = SUBSTRING(E1_PARCELA,3,1) " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
					
			TCSqlExec( cQueryC )
	
		ElseIf TRB1->E1_PARCELA	== '007' 

			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = SUBSTRING(E1_PARCELA,3,1) " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
					
			TCSqlExec( cQueryC )
		
		ElseIf TRB1->E1_PARCELA	== '008' 

			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = SUBSTRING(E1_PARCELA,3,1) " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER

			TCSqlExec( cQueryC )			
		
		ElseIf TRB1->E1_PARCELA	== '009' 

			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = SUBSTRING(E1_PARCELA,3,1) " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER

			TCSqlExec( cQueryC )
	
		ElseIf TRB1->E1_PARCELA	== '010'
			
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'A' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
			
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '011'
			
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'B' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
				
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '012'
			
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'C' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
				
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '013'
			
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'D' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
			
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '014'
		
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'E' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
				
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '015'
			
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'F' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
			
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '016'
			
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'G' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
			
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '017'
			
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'H' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
				
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '018'
			
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'I' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
			
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '019'
		
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'J' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
			
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '020'
			
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'K' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
			
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '021'
			
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'L' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
			
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '022'
		
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'M' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
			
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '023'
		
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'N' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
			
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '024'
			
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'O' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
			
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '025'
			
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'P' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
				
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '026'
			
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'Q' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
				
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '027'
			
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'R' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
				
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '028'
			
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'S' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
			
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '029'
			
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'T' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
			
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '030'
		
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'U' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
			
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '031'
			
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'V' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
			
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '032'
		
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'W' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
			
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '033'
			
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'X' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
				
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '034'			
		
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'Z' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER
			
			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	==  '035'			
			
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = 'Y' " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER

			TCSqlExec( cQueryC )

		ElseIf TRB1->E1_PARCELA	$ '00A/00B/00C/00D/00E/00F/00G/00H/00I/00J/00K/00L/00M/00N/00O/00P/00Q/00R/00S/00T/00U/00V/00X/00Z/00W/00Y'			
			
			cQueryC := "UPDATE " + RetSqlName("SE1") + " SET E1_PARCELA = SUBSTRING(E1_PARCELA,3,1) " + ENTER
			cQueryC += " FROM " + RetSqlName("SE1") + "  AS SE1 " + ENTER
			cQueryC += " WHERE E1_FILIAL = '"+XfILIAL("SE1")+"' " + ENTER
			cQueryC += " AND E1_PREFIXO = '"+TRB1->E1_PREFIXO+"' " + ENTER
			cQueryC += " AND E1_NUM     = '"+TRB1->E1_NUM+"'     " + ENTER
			cQueryC += " AND E1_PARCELA = '"+TRB1->E1_PARCELA+"' " + ENTER
			cQueryC += " AND E1_CLIENTE = '"+TRB1->E1_CLIENTE+"' " + ENTER
			cQueryC += " AND E1_LOJA    = '"+TRB1->E1_LOJA+"'    " + ENTER
			cQueryC += " AND LEN(E1_PARCELA) = 3 " + ENTER  
			cQueryC += " AND E1_SALDO > 0 " + ENTER  
			cQueryC += " AND E1_EMISSAO >= '20210422' " + ENTER  
			cQueryC += " AND SE1.D_E_L_E_T_ = ' '  " + ENTER

			TCSqlExec( cQueryC )

		EndIf

	EndIf

    TRB1->(DbSkip())

    IncProc("Gerando arquivo...")

EndDo

SE1->(DbCloseArea())
TRB1->(DbCloseArea())

Return Nil

/*
+------------+------------+--------+---------------+-------+--------------+
| Programa:  | oAjustaSx1 | Autor: | QUALY         | Data: | 13/02/21     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - Perguntas                                     |
+------------+------------------------------------------------------------+
*/
Static Function oAjustaSx1()

Local _aPerg  := {}  // aRRAY 
Local _ni

Aadd(_aPerg,{"Prefixo De  .....?"        ,"mv_ch1","C",03,"G","mv_par01","","","","","","SE1","","",0})
Aadd(_aPerg,{"Produtos Até ....?"        ,"mv_ch2","C",03,"G","mv_par02","","","","","","SE1","","",0})

Aadd(_aPerg,{"Titulo De  ......?"        ,"mv_ch3","C",09,"G","mv_par03","","","","","","SE1","","",0})
Aadd(_aPerg,{"Titulo Até ......?"        ,"mv_ch4","C",09,"G","mv_par04","","","","","","SE1","","",0})

Aadd(_aPerg,{"Parcela De  .....?"        ,"mv_ch5","C",03,"G","mv_par05","","","","","","SE1","","",0})
Aadd(_aPerg,{"Parcela Até .....?"        ,"mv_ch6","C",03,"G","mv_par06","","","","","","SE1","","",0})

Aadd(_aPerg,{"Cliente De  .....?"        ,"mv_ch7","C",06,"G","mv_par07","","","","","","SA1","","",0})
Aadd(_aPerg,{"Cliente Até .....?"        ,"mv_ch8","C",06,"G","mv_par08","","","","","","SA1","","",0})

Aadd(_aPerg,{"Loja De  ........?"        ,"mv_ch9","C",02,"G","mv_par09","","","","","","SA1","","",0})
Aadd(_aPerg,{"Loja Até ........?"        ,"mv_cha","C",02,"G","mv_par10","","","","","","SA1","","",0})

Aadd(_aPerg,{"Data Emissão De..?"        ,"mv_ch9","D",08,"G","mv_par09","","","","","","","","",0})
Aadd(_aPerg,{"Data Emissão Até.?"        ,"mv_cha","D",08,"G","mv_par10","","","","","","","","",0})


dbSelectArea("SX1")
For _ni := 1 To Len(_aPerg)
	If !dbSeek(_cPerg+ SPACE( LEN(SX1->X1_GRUPO) - LEN(_cPerg))+StrZero(_ni,2))
		RecLock("SX1",.T.)
		SX1->X1_GRUPO    := _cPerg
		SX1->X1_ORDEM    := StrZero(_ni,2)
		SX1->X1_PERGUNT  := _aPerg[_ni][1]
		SX1->X1_VARIAVL  := _aPerg[_ni][2]
		SX1->X1_TIPO     := _aPerg[_ni][3]
		SX1->X1_TAMANHO  := _aPerg[_ni][4]
		SX1->X1_GSC      := _aPerg[_ni][5]
		SX1->X1_VAR01    := _aPerg[_ni][6]
		SX1->X1_DEF01    := _aPerg[_ni][7]
		SX1->X1_DEF02    := _aPerg[_ni][8]
		SX1->X1_DEF03    := _aPerg[_ni][9]
		SX1->X1_DEF04    := _aPerg[_ni][10]
		SX1->X1_DEF05    := _aPerg[_ni][11]
		SX1->X1_F3       := _aPerg[_ni][12]
		SX1->X1_CNT01    := _aPerg[_ni][13]
		SX1->X1_VALID    := _aPerg[_ni][14]
		SX1->X1_DECIMAL  := _aPerg[_ni][15]
		MsUnLock()
	EndIf
Next _ni

Return


