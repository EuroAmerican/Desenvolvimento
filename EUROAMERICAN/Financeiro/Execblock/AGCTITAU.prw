User Function AgCtItau()

Local cLinha := ''
Local cAg    := ''
Local cConta := ''
Local cDAc   := ''

IF SA2->A2_BANCO == '341'
 
	cAg  := Padl(Alltrim(SA2->A2_AGENCIA),4,'0')
	cConta  := Padl(Alltrim(SA2->A2_NUMCON),6,'0')
	cDac  := Alltrim(SA2->A2_DVCTA)
 
	//Se a DAC tiver mais de um caracter, não imprime o espaço na posição 42 (FUnção LEN() retorno a quantidade de caracteres)
 
	If Len(cDac) > 1
				//Zero + agencia + branco + zeros + conta  + DAC
		cLinha := '0' + cAg + Space(01) + '000000' + cConta +  cDac
  
	Else
				//Zero + agencia + branco + zeros + conta + branco + DAC
		cLinha := '0' + cAg + Space(01) + '000000' + cConta + Space(01) + cDac
  
	Endif 

Else  

	cAg  := Padl(Alltrim(SA2->A2_AGENCIA),5,'0')
	cConta  := Padl(Alltrim(SA2->A2_NUMCON),12,'0')
	cDac  := Alltrim(SA2->A2_DVCTA)

	If Len(cDac) > 1
				//agencia + branco + conta  + DAC
		cLinha := cAg + Space(01) + cConta +  cDac
  
	Else
				//agencia + branco + conta + branco + DAC
		cLinha := cAg + Space(01) + cConta + Space(01) + cDac
  
	Endif 
	
EndIf

Return cLinha