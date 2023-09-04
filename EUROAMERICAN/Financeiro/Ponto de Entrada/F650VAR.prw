//Ponto entrada relatório retorno CNAB para resolver casos de E1_TIPO = NF
#include "protheus.ch"

//cNumTit -> Número do título  
//dBaixa -> Data da Baixa  
//cTipo -> Tipo do título         
//cNsNum -> Nosso Número      
//nDespes -> Valor da despesa
//nDescont -> Valor do desconto         
//nAbatim -> Valor do abatimento        
//nValRec -> Valor recebidos                                                             
//nJuros -> Juros                   
//nMulta -> Multa                  
//nOutrDesp -> Outras despesas     
//nValCc -> Valor do crédito           
//dDataCred -> Data do crédito       
//cOcorr -> Ocorrencia                
//cMotBai -> Motivo da baixa   
//xBuffer -> Linha inteira     
//dDtVc -> Data do vencimento  

User Function F650VAR()

cTipo := "01"

Return