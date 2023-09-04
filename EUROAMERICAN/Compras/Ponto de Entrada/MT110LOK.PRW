/*/{Protheus.doc} MT110LOK
//LOCALIZAÇÃO : MT110LOK - responsável pela validação de cada linha da GetDados da Solicitação de Compras
//EM QUE PONTO : O ponto se encontra no final da função e deve ser utilizado para validações especificas do usuario onde será controlada
//pelo retorno do ponto de entrada o qual se for .F. o processo será interrompido e se .T. será validado.
//http://tdn.totvs.com/pages/releaseview.action?pageId=6085445
@author Emerson Paiva
@since 07/08/2018
@version 1.0
/*/

User Function  MT110LOK()

Local nPosRat	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C1_RATEIO"}) 
Local nPosCC	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C1_CC"})
Local lValido	:= .T.

If	aCols[n, nPosRat] <> "1"
	lValido := !Empty(aCols[n, nPosCC])
	
	If !lValido
		MsgStop("É obrigatório informar o Centro de Custo para cada item da Solicitação!")
	EndIf
EndIf

Return(lValido) 
