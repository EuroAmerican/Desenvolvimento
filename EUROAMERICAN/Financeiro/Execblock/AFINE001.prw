#Include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AFINE001 ºAutor  ³Tiago O. Beraldi    º Data ³  04/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Seleciona dados para geração de arquivo remessa            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AFINE001()   
Local aArea		:= GetArea()
Local aAreaSE1	:= SE1->( GetArea() )
Local aAreaSEE	:= SEE->( GetArea() )
Local aAreaSA1	:= SA1->( GetArea() )  

Local cMod11	:= ""

Local c_Return	:= ""

Local n_ValOpc	:= ParamIxb


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Seleciona clientes Euroamerican(Matriz e Revenda) a partir da Matriz |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA1->(Dbsetorder(1))
SA1->(Dbgotop())
SA1->(dbSeek(SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA))                   
      
Do Case
	//Pessoa Fisica ou Juridica
	Case n_ValOpc == 1
		If Right(SA1->A1_CGC,2)== '  '
			c_Return := '01'
		Else
			c_Return := '02'
		Endif                  
	
	//CNPJ
	Case n_ValOpc == 2
		c_Return := SA1->A1_CGC
	
	//Nome do Cliente
	Case n_ValOpc == 3
		c_Return := SA1->A1_NOME
	
	//Endereco de cobranca
	Case n_ValOpc == 4
		c_Return := NOACENTO(ANSITOOEM(SA1->A1_ENDCOB))
	
	//CEP de cobranca
	Case n_ValOpc == 5
		c_Return := SA1->A1_CEPC //Alterado A1_CEPCOB

	// ============================================================
	//  Grupo Empresa - Ajuste realizado em 31.08.20 (CG)
	// ============================================================

    // Alterado SM0->M0_CODIGO por SM0->M0_CODFIL

	//Ident. Cedente
	Case n_ValOpc == 6
		If Substr(SM0->M0_CODFIL,1,2) == '02' //Euroamerican
			c_Return := '00090339000522503'
		ElseIf Substr(SM0->M0_CODFIL,1,2) == '03' .Or. ALLTRIM(SM0->M0_CODFIL) == '0108"
			c_Return := '0009' + SEE->EE_AGENCIA + 	StrZero(Val(StrTran(StrTran(SEE->EE_CONTA, ".",""),"-", "")), 8)
		ElseIf Substr(SM0->M0_CODFIL,1,2) == '08'		//Multicores: Carteira 009 - Pos 22 a 24/ Ag sem digito Pos 25 a 29 / Conta Pos 30 a 36 / Digito Pos 37
			c_Return := '00090339000665002'
		Endif
	
	//Mensagem Bloqueto
	Case n_ValOpc == 7
		If Substr(SM0->M0_CODFIL,1,2) == '02' 			 //Euroamerican
			c_Return := 'Juros Mora 6% ao mes/Apos 5 dias vencto sujeito a protesto'
		Elseif Substr(SM0->M0_CODFIL,1,2) == '03'       //Qualyvinil
			c_Return := 'Juros Mora 5% ao mes/Apos 5 dias vencto sujeito a protesto'
		Endif      
	
	//Bairro de cobranca
	Case n_ValOpc == 8
		c_Return := SA1->A1_BAIRROC //Alterado SA1->A1_BAI_COB
	
	//Municipio de cobranca
	Case n_ValOpc == 9
		c_Return := SA1->A1_MUNC 
		
	//Estado de cobranca
	Case n_ValOpc == 10
		c_Return := SA1->A1_ESTC         
		
	//Ident. Cedente Caucao
	Case n_ValOpc == 11
		If Substr(SM0->M0_CODFIL,1,2) == '02' 		 //Euroamerican
			c_Return := '00020339000522520'
		ElseIf Substr(SM0->M0_CODFIL,1,2) == '03'    //Qualyvinil
			c_Return := '0002' + SEE->EE_AGENCIA + 	StrZero(Val(StrTran(StrTran(SEE->EE_CONTA, ".",""),"-", "")), 8)
		EndIf
		 
    //Mensagem no Boleto
	Case n_ValOpc == 12
		If Empty(SA1->A1_AVALIST)     

			If Substr(SM0->M0_CODFIL,1,2) == "02" .And. RTrim(SEE->EE_CODIGO) == "033"
				c_Return := LEFT( SM0->M0_NOMECOM, 30 )			

			ElseIf ALLTRIM(SM0->M0_CODFIL) == "0304" .And. RTrim(SEE->EE_CODIGO) $ "237#633#341#021"
				c_Return := LEFT( SM0->M0_NOMECOM, 60 )			

			Else				
				c_Return := "NF" + SE1->E1_NUM + SE1->E1_PARCELA 

			EndIf

		Else
			c_Return := Subs(Posicione("SA1", 1, xFilial("SA1") + SA1->A1_AVALIST, "A1_NOME"), 1, 17) + "-NF" + SE1->E1_NUM + SE1->E1_PARCELA 
		EndIf	
				
		SA1->(dbSeek(SE1->E1_FILIAL + SE1->E1_CLIENTE + SE1->E1_LOJA))                   

	//Instrucao de Protesto		
	Case n_ValOpc == 13
		If SE1->E1_PREFIXO $ "REQ#ZZZ"
			c_Return := Space(2)

		ElseIf SA1->A1_GRPVEN == "000003"
			If SEE->EE_CODIGO $ "237#033"
				c_Return := "06"
			ElseIf SEE->EE_CODIGO == "341"
				c_Return := "34"
			ElseIf SEE->EE_CODIGO == "633"
				c_Return := "09"
			ElseIf SEE->EE_CODIGO $ "655#637"
				c_Return := "09"
			ElseIf SEE->EE_CODIGO $ "021"
				c_Return := "P6"
			Else
				c_Return := Space(2)
			EndIf			

		ElseIf SA1->A1_GRPVEN == "000004"      
			If SEE->EE_CODIGO $ "655#637"
				c_Return := "10"     
			ElseIf SEE->EE_CODIGO $ "021"
				c_Return := "P7"
			Else				
				c_Return := Space(2)
			EndIf				

		Else                


		// Grupo Empresa - Ajuste realizado (CG)
	
		// If AllTrim(cEmpAnt + cFilAnt) $ "0203#0304"

			If AllTrim(cFilAnt) $ "0203#0304"
				If SEE->EE_CODIGO $ "655#637"
					c_Return := "10"     
				ElseIf SEE->EE_CODIGO $ "021"
					c_Return := "P7"
				Else				
					c_Return := Space(2)
				EndIf				

			Else
				If SEE->EE_CODIGO $ "237#033"
					c_Return := "06"
				ElseIf SEE->EE_CODIGO == "341"
					c_Return := "34"
				ElseIf SEE->EE_CODIGO == "633"
					c_Return := "09"   
				ElseIf SEE->EE_CODIGO $ "655#637"
					c_Return := "09"   
				ElseIf SEE->EE_CODIGO $ "021"
					c_Return := "P6"
				Else
					c_Return := Space(2)
				EndIf			
			EndIf
		EndIf
			
	//Dias de Protesto		
	Case n_ValOpc == 14
		c_Return := "05"

	//Conta		
	Case n_ValOpc == 15
		c_Return := StrTran(SEE->EE_CONTA, ".", "")
		c_Return := StrTran(c_Return, "-", "")

	//Numero Convenio BB		
	Case n_ValOpc == 16  

		// Grupo Empresa - Ajuste realizado (CG)

		If cFilAnt == "0203" .Or. Left(cFilAnt,2) == "03"
			c_Return := "1568839"

		ElseIf Left(cFilAnt,2) == "02"   
			c_Return := "1700235"

		ElseIf cFilAnt == "0107"

			//If Len(RTrim(SE1->E1_NUMBCO)) == 10 .And. RTrim(SA1->A1_IMPBOLE) == "S"  	// 19/01/17
				c_Return := "2671909"	// -> Convenio onde cliente gera nosso numero	( Carteira 17 )
			/*Else                      
				c_Return := "1323321"	// -> Convenio onde banco gera nosso numero		( Carteira 11 )
			EndIf*/ // 19/01/17 Alterado opção para gerar somente carteira 17
		
		ElseIf cFilAnt == "0200"
			c_Return := "1702234"
		Else 
			c_Return := ""			
		EndIf  
		
	//Seu Numero
	Case n_ValOpc == 17  
		c_Return := Subs(SE1->E1_PREFIXO, 1, 2) + Subs(SE1->E1_NUM, 3, 7) + SE1->E1_PARCELA    
		
	//Mensagem Bloqueto
	Case n_ValOpc == 18
		c_Return := 'JUROS 5% AO MES / '

	//Sacador Avalista
	Case n_ValOpc == 19
		If cFilAnt == "0304"
			c_Return := ''
		Else
			c_Return := '94'
		EndIf 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Sequencial CNAB                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	Case n_ValOpc == 20

		dbSelectArea("SEE")
		RecLock("SEE", .F.)
			SEE->EE_ULTDSK := Soma1(SEE->EE_ULTDSK)		
		SEE->( MsUnLock() )
		
		c_Return := StrZero(Val(SEE->EE_ULTDSK),7) 
  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Nosso Numero                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	Case n_ValOpc == 21  
        
		If cFilAnt == "0107"
			//BANCO DO BRASIL
			//If Len(RTrim(SE1->E1_NUMBCO)) == 10 .And. RTrim(SA1->A1_IMPBOLE) == "S"	//19/01/17 Alterado opção para gerar somente carteira 17
			If	Empty(SE1->E1_NUMBCO)
				
				U_FINE002()
					
			EndIf			
			
			c_Return	:= RTrim(SEE->EE_CODEMP) + RTrim(SE1->E1_NUMBCO)
			
			/*Else
				c_Return 	:= Replicate("0", 17)
			EndIf*/ // 19/01/17 Alterado opção para gerar somente carteira 17

		ElseIf cFilAnt == "0108"     
			//BANCO BRADESCO
			If Len(RTrim(SE1->E1_NUMBCO)) == 11 .And. RTrim(SA1->A1_IMPBOLE) == "S"
				c_Return	:= RTrim(SE1->E1_NUMBCO) + U_FINE02NN() 
			Else
				c_Return 	:= Replicate("0", 12)
			EndIf
	
		EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Impressao do boleto  ( Especifico - BANCO BRADESCO )                 ³
	//|Opcoes: 1-Banco Imprime || 2-Cliente Imprime                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	Case n_ValOpc == 22                
	
		If cFilAnt == "0108" .And. Len(RTrim(SE1->E1_NUMBCO)) == 11 .And. RTrim(SA1->A1_IMPBOLE) == "S"
			c_Return := "2"
		Else
			c_Return := "1"
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Codigo Inscricao ( Especifico - BANCO RENDIMENTO )                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	Case n_ValOpc == 23
	
		If cFilAnt == "0304"  
			c_Return := "04"
		Else                
			c_Return := "02"
		EndIf          
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Carteira de Cobranca ( Especifico - BANCO BRASIL )                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	Case n_ValOpc == 24

		//If cEmpAnt + cFilAnt == "0107" .And. Len(RTrim(SE1->E1_NUMBCO)) == 10 .And. RTrim(SA1->A1_IMPBOLE) == "S"      //19/01/17 Alterado opção para gerar somente carteira 17
			c_Return	:= "17"
		/*Else
			c_Return 	:= "11"
		EndIf */ //19/01/17 Alterado opção para gerar somente carteira 17
             
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Nome Sacador/Avalista                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	Case n_ValOpc == 25 
		If Empty(SA1->A1_AVALIST)    
			c_Return 	:= Left(RTrim(SM0->M0_NOMECOM), 40)
		Else                                       
			c_Return 	:= Left(RTrim(SA1->A1_NOME), 40)
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Endereco Sacador/Avalista                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  	
	Case n_ValOpc == 26

		If Empty(SA1->A1_AVALIST)    
			c_Return 	:= NOACENTO(ANSITOOEM(Left(RTrim(SM0->M0_ENDCOB), 40)))
		Else                                       
			c_Return 	:= NOACENTO(ANSITOOEM(Left(RTrim(SA1->A1_ENDCOB), 40)))
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Bairro Sacador/Avalista                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  	
	Case n_ValOpc == 27

		If Empty(SA1->A1_AVALIST)    
	   		c_Return 	:= Left(RTrim(SM0->M0_BAIRCOB), 12)
		Else                                       
			c_Return 	:= Left(RTrim(SA1->A1_BAI_COB), 12)
		EndIf
                           
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|CEP Sacador/Avalista                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                   
	Case n_ValOpc == 28

		If Empty(SA1->A1_AVALIST)    
	   		c_Return 	:= Left(RTrim(SM0->M0_CEPCOB), 08)
		Else                                       
			c_Return 	:= Left(RTrim(A1_CEPC), 08)  //Alterado SA1->A1_CEPCOB
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Municipio Sacador/Avalista                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                   
	Case n_ValOpc == 29

		If Empty(SA1->A1_AVALIST)    
			c_Return 	:= Left(RTrim(SM0->M0_CIDCOB), 15)
		Else                                       
			c_Return 	:= Left(RTrim(SA1->A1_MUNC), 15)	//SA1->A1_MUN_COB
		EndIf
                     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Estado Sacador/Avalista                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                   
	Case n_ValOpc == 30

		If Empty(SA1->A1_AVALIST)    
	   		c_Return 	:= Left(RTrim(SM0->M0_ESTCOB), 02)
		Else                                       
			c_Return 	:= Left(RTrim(SA1->A1_ESTC), 02)		//SA1->A1_EST_COB
		EndIf                                                                 
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Tipo de inscricao do Sacador/Avalista                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	Case n_ValOpc == 31

		If Empty(SA1->A1_AVALIST)    
	   		c_Return 	:= "02" //CNPJ
		Else                                       
			c_Return 	:= IIf(RTrim(SA1->A1_TIPO) == "", "00", IIf(RTrim(SA1->A1_TIPO) == "F", "01", "02") )
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Inscricao do Sacador/Avalista                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	Case n_ValOpc == 32

		If Empty(SA1->A1_AVALIST)    
			c_Return 	:= Left(RTrim(SM0->M0_CGC), 14)
		Else                                       
			c_Return 	:= Left(RTrim(SA1->A1_CGC),14)
		EndIf   
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Email do Sacado                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	Case n_ValOpc == 33
		c_Return := SA1->A1_EMAIL

EndCase     

Restarea( aArea		)
Restarea( aAreaSE1	)
Restarea( aAreaSEE	)
Restarea( aAreaSA1	)       

Return(c_Return)