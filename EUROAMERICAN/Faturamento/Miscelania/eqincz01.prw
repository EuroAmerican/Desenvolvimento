#INCLUDE "TOTVS.CH"
#Include "topconn.ch"
#Include "FwBrowse.ch"
#Include "FwMvcDef.ch"

/*/{Protheus.doc} EQINCZ01
Inclusao das margens e percentuais pra efeito de calculo de comissao
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 06/12/2021
@return character, sem retorno definido
/*/
User Function EQINCZ01()
    Private oBrowse := FwMBrowse():New()

    PRIVATE cCadastro  := "Pontuação de Comissao"

    If cFilant<>"0200"
        Alert("Rotina disponivel apenas para Euro")
        Return
    End

     AxCadastro("Z01", cCadastro, ".T.", ".T.")
Return(.T.)
