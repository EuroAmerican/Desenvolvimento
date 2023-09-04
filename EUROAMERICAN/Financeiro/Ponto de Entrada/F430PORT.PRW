
#Include "TOTVS.CH"

/*/{Protheus.doc} F430PORT
PE para considerar o bancp do bordero na baixa do retorno CNAB a Pagar
Obs : EM PRIMEIRO MOMENTO somente para o banco ITAU pela aprticularidade no cadasdtro das contas
@type function Ponto de Entrada
@version  1.00
@author mario.antonaccio
@since 23/08/2021
@return Logical, Considera ou nao a conta cadastrada no bordero
/*/
User Function F430PORT()

Local lRet:=.T.

lRet:= MsgYesNo("Baixar titulo na conta Informada no Bordero??","Atenção")

Return (lRet)
