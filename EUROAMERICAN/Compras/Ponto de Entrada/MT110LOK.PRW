/*/{Protheus.doc} MT110LOK
//LOCALIZA��O : MT110LOK - respons�vel pela valida��o de cada linha da GetDados da Solicita��o de Compras
//EM QUE PONTO : O ponto se encontra no final da fun��o e deve ser utilizado para valida��es especificas do usuario onde ser� controlada
//pelo retorno do ponto de entrada o qual se for .F. o processo ser� interrompido e se .T. ser� validado.
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
		MsgStop("� obrigat�rio informar o Centro de Custo para cada item da Solicita��o!")
	EndIf
EndIf

Return(lValido) 
