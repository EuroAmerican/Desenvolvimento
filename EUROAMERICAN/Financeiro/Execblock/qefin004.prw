#include 'protheus.ch'
#include 'parmtype.ch'
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"

#define ENTER chr(13) + chr(10)

/*/{Protheus.doc} QEFAT004
//Chama a rotina FINA150 e zera o paramento para geração do arquivo
@author Fabio Carneiro dos Santos 
@since 29/04/2021
@version 1.0
/*/
User Function QEFIN004()

	Local aSays    := {}
	Local aButtons := {}
	Local nOpca    := 0
	Local cTitoDlg := "Remessa exclusiva Banco Rendimento "
   
    Public c_Ret := getmv("MV_XSEQREM")

	// Prepara e executa a pergunta do relatorio

	aAdd(aSays, "Esta Rotina Tem por Objetivo Gerar as Remessas para o Banco Rendimento ")
	aAdd(aSays, "Esta rotina chama a Rotina FINA150 especifica para o Banco Rendimento")
	aAdd(aSays, "Caso usem a rotina para outros bancos, Podera causar impactos no arquivo de Remessa")
	
	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)

	If nOpca == 1
    
        c_Ret := 0

        PutMv("MV_XSEQREM", c_Ret)

        FINA150()
		
	EndIf

Return
