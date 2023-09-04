#INCLUDE 'TOTVS.ch'

/*/{Protheus.doc} LJ7007
Permite ao usuario personalizar formas de pagamento
@type function Ponto de Entrada
@version  1.0
@author mario.antonaccio
@since 09/10/2021
@return Array, Condi��o pagamento 
/*/
User Function LJ7007()

Local aRet := {}


aAdd( aRet, 'P I X ') //-- Descri��o do Botao
aAdd( aRet, "LJ7CondPg(2, '002'), M->LQ_CONDPG := '002', cDescCondPg := Posicione('SE4',1,xFilial('SE4')+M->LQ_CONDPG,'SE4->E4_DESCRI')") //-- Função que será executada para adicionar automaticamente a condição '005', atualizar o combo e a descrição da condição de pagamento.

/*
aAdd( aRet, '1+2 30DD')
aAdd( aRet, "LJ7CondPg(2, '010'), M->LQ_CONDPG := '010', cDescCondPg := Posicione('SE4',1,xFilial('SE4')+M->LQ_CONDPG,'SE4->E4_DESCRI')")

aAdd( aRet, '0,30,60,90 FI')
aAdd( aRet, "LJ7CondPg(2, '013'), M->LQ_CONDPG := '013', cDescCondPg := Posicione('SE4',1,xFilial('SE4')+M->LQ_CONDPG,'SE4->E4_DESCRI')")
*/

Return aRet
