#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} LJ7087
Com o CNPJ da empresa liberado para emissão de Nota Fiscal no Venda Assistida, este Ponto de Entrada permite que o usuário 
defina o tipo da venda (Cupom ou Nota), ou se será exibida a pergunta padrão: “Cupom ou Nota?”. 
Também é possível definir se será utilizado Cupom (NFC-e), ou Nota sem a apresentação da pergunta na tela. 
É executado no início da venda, após o preenchimento do cliente, ou na finalização da venda por meio 
da opção “Finalizar Venda” na tela de lista de orçamentos .
	
Seu retorno deve ser um numérico de 0 a 2, onde:
0 = É definido com a apresentação da pergunta (padrão)
1 = Emissão de CF ou NFC-e (sem a apresentação da pergunta)
2 = Emissão de Nota Fiscal (sem a apresentação da pergunta)

@type function Ponto de Entrada
@version  1.00
@author mario.antonaccio
@since 03/11/2021
@return Numeric, Conforme acima
/*/
User Function LJ7087()
Local nRet := 0 //0 = Verifica emissao (padrão) / 1 = Emissão de CF ou NFC-e / 2 = Emissao de nota

If Len(AlLtrim(SA1->A1_CGC)) == 14 .or. SA1->A1_TIPO == "L"  // Produto rural
    If MSGYESNO( "Deseja emitir Nota Fiscal para esse cliente?", "Imprime Nota" )
     nRet := 2 //2 = Emissao de nota
   End 
End   
Return nRet
