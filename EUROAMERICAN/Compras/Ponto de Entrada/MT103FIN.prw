#include "protheus.ch"
#include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT100TOK  ºAutor  ³Rodrigo Sousa       º Data ³  26/04/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida Folder Duplicatas da Nota Fiscal de Entrada		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User FuncTion MT103FIN()

Local lLocRet  	:= PARAMIXB[3]      // Flag de validações anteriores padrões do sistema.                                    

If lLocRet                                                           
	lLocRet := EQVldVcto()
EndIf	

Return(lLocRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BeVldVcto ºAutor  ³Rodrigo Sousa       º Data ³  26/04/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Não permite inclusão de duplicatas com vencimento abaixo	  º±±
±±º     	 ³ do indicado no parametro MV_BEDVCTO, onde é informado	  º±±
±±º     	 ³ o numero de dias uteis permitidos para vencimento minimo	  º±±
±±º     	 ³ de titulos a pagar.										  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EQVldVcto()

Local lRet		:= .T.
Local nX		:= 0

Local aLocHead 	:= PARAMIXB[1]      // aHeader do getdados apresentado no folter Financeiro.
Local aLocCols 	:= PARAMIXB[2]      // aCols do getdados apresentado no folter Financeiro.

Local nPosVcto	:= aScan(aLocHead,{|x| Upper(Alltrim(x[2]))=="E2_VENCTO"})  
Local nPosVlr	:= aScan(aLocHead,{|x| Upper(Alltrim(x[2]))=="E2_VALOR"})  
Local nDiasVcto := SuperGetMV("MV_EQDVCTO",.f.,0)

Local dVctoPer	:= dDataBase + nDiasVcto

If nDiasVcto > 0
	
	For nX := 1 to Len(aLocCols)

		If aLocCols[nX][nPosVcto] < dVctoPer .And. aLocCols[nX][nPosVlr] > 0 .And. !Empty(cCondicao)

			Aviso("MT103FIN / EQVldVcto","Existe(m) titulo(s) com vencimento não permitido"+CRLF+;
										 "Data de vencimento minimo permitido é em: "+DtoC(dVctoPer)+CRLF+CRLF+;
										 "Entre em contato com o Departamento Financeiro.",{"Ok"},2)
			lRet := .F.  
			Exit

		EndIf

	Next nX

EndIf

Return lRet
