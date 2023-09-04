#include "RWMAKE.CH"    

#define ENTER			   chr(13) + chr(10)   
#define PAD_LEFT		   0
#define PAD_RIGHT          1
#define PAD_CENTER         2      

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FATR077  º Autor ³Alexandre Marson    º Data ³ 16/07/13    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ BOLETO BANCARIO ( GENERICO )                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFAT                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                     A L T E R A C O E S                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ºProgramador       ºAlteracoes                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criar campo:                                                    ³
//³SEE    EE_CARTEIR   C  3   "Carteira de cobranca"               ³
//³SEE    EE_VARCART   C  3   "Variacao da Carteira"               ³
//³SEE    EE_AGECART   C  7   "Agencia da Carteira "               ³
//³SA6    A6_BCOCORR   C  3   "Banco correspondente"               ³
//³SA6    A6_AGECORR   C  5   "Agencia do banco correspondente"    ³
//³SA6    A6_CTACORR   C  10  "Conta do banco correspondente "     ³
//³SA6    A6_DESCORR   C  15  "Descricao do banco correspondente " ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/


User Function FATR077()     
Local aArea			:= GetArea() 
Local aAreaSE1		:= SE1->( GetArea() )
Local aDesc			:= "Este programa imprime os boletos de" + ENTER +;
				   		"cobranca bancaria de acordo com" + ENTER +;
				   		"os parametros informados"
Private cPerg		:= PadR("FATR077", 10)
Private lImpAut		:= ( Upper(AllTrim(FunName())) $ "MATA460A#SPEDNFE" )
                     
ValidPerg()
Pergunte (cPerg,.F.)


// Grupo Empresa - Ajuste realizado (CG)

If lImpAut .And. ALLTRIM(cFilAnt) $ "0107;0108"

	MV_PAR01 := SF2->F2_SERIE
	MV_PAR02 := SF2->F2_SERIE
	MV_PAR03 := SF2->F2_DOC
	MV_PAR04 := SF2->F2_DOC
	MV_PAR05 := ""
	MV_PAR06 := "Z"			   
	MV_PAR07 := ""
	MV_PAR08 := "ZZZZZZ"			 
	
	Do Case
		
		Case ALLTRIM(cFilAnt) == "0107"
		   
			MV_PAR09 := "001"			   
			MV_PAR10 := "3355"
			MV_PAR11 := "22000"			   

	    Case ALLTRIM(cFilAnt) == "0108"
			
			MV_PAR09 := "237"			   
			MV_PAR10 := "03390"
			MV_PAR11 := "54000-5"			 		
	
	EndCase
	
	FATR077Print()
Else
	If Pergunte(cPerg, .T.)
		
		If ( ALLTRIM(cFilAnt) == "0107" .And. MV_PAR09 != "001" ) .Or.;
		   ( ALLTRIM(cFilAnt) == "0108" .And. MV_PAR09 != "237" )
			
			MsgStop("Banco selecionado não é válido para empresa ativa.")
		Else        	
			FATR077Print()         		
		EndIf  
	EndIf    
EndIf

Restarea( aAreaSE1 )
Restarea( aArea )

Return( Nil )
                           

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function ValidPerg
Local aArea		:= GetArea()
Local aRegs		:= {}
Local i,j		:= 0

//(sx1) Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Prefixo De			","","","mv_ch1" ,"C", 3,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Prefixo Ate			","","","mv_ch2" ,"C", 3,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Titulo De			","","","mv_ch3" ,"C", 9,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Titulo Ate			","","","mv_ch4" ,"C", 9,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Parcela De			","","","mv_ch5" ,"C", 1,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Parcela Ate			","","","mv_ch6" ,"C", 1,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Bordero De			","","","mv_ch7" ,"C", 6,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Bordero Ate			","","","mv_ch8" ,"C", 6,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09","Banco				","","","mv_ch9" ,"C", 3,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","SA6",""})
aAdd(aRegs,{cPerg,"10","Agencia				","","","mv_cha" ,"C", 5,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"11","Conta				","","","mv_chb" ,"C",10,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","",""})

dbSelectArea("SX1")
dbSetOrder(1)          

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		SX1->( MsUnlock() )
	Endif
Next

Restarea( aArea )

Return( Nil )

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function FATR077Print()

Local aArea			:= GetArea()
Local aAreaSE1		:= SE1->( GetArea() )
Local aAreaSA6		:= SA6->( GetArea() )
Local aAreaSEE		:= SEE->( GetArea() )
Local nOpc			:= 1      
Local oPrint		:= Nil 

Local aCB_LD_NN  	:= {}           
                  
Local cIndexName	:= Criatrab(Nil,.F.)
Local cIndexKey		:= "E1_PORTADO+E1_PREFIXO+E1_NUM+E1_PARCELA+DTOS(E1_EMISSAO)+E1_CLIENTE"

Local cFilter		:= "SE1->E1_PREFIXO >= '" + MV_PAR01 + "' .And. SE1->E1_PREFIXO <= '" + MV_PAR02 + "' .And. " +;
			  		   "SE1->E1_NUM     >= '" + MV_PAR03 + "' .And. SE1->E1_NUM     <= '" + MV_PAR04 + "' .And. " +;       
			 		   "SE1->E1_PARCELA >= '" + MV_PAR05 + "' .And. SE1->E1_PARCELA <= '" + MV_PAR06 + "' .And. " +;
			 		   "SE1->E1_NUMBOR  >= '" + MV_PAR07 + "' .And. SE1->E1_NUMBOR  <= '" + MV_PAR08 + "' .And. " +;       
			 		   "RTRIM(SE1->E1_TIPO) = 'NF' .And. " +;
			 		   "SE1->E1_FILIAL = '" + xFilial("SE1") + "' .And. " +;
			 		   "POSICIONE('SC5', 1, SE1->E1_FILIAL + SE1->E1_PEDIDO, 'C5_TIPOPAG') == '1' " +;
					   ".AND. Empty(SE1->E1_IDCNAB) " // Ajustado por Fabio Batista 06/10/2020
					   //".AND. SE1->E1_IDCNAB == '' "
			 		   
Local _Banco		:= ""  
Local _DvBanco		:= ""
Local _NomeBanco	:= ""
Local _Agencia		:= ""
Local _DvAgencia	:= ""
Local _Conta		:= ""
Local _DvConta		:= ""
Local _Carteira		:= ""
Local _VarCarteira	:= ""	   
Local _Convenio		:= ""
Local _nVlrAbat		:= 0
Local _nVlrTit		:= 0
Local _LogoBanco	:= ""		 		   

Local oFont1		:= TFont():New("Arial"      		,09,16,,.T.,,,,,.F.)	//Codigo do Banco
Local oFont2		:= TFont():New("Arial"      		,09,12,,.T.,,,,,.F.)	//Linha Digitavel
Local oFont3		:= TFont():New("Arial"				,09,06,,.F.,,,,,.F.)	//Titulo de Campo
Local oFont4 		:= TFont():New("Arial"      		,09,08,,.F.,,,,,.F.)	//Conteudo de Campo
Local oFont5 		:= TFont():New("Arial"      		,09,09,,.T.,,,,,.F.)	//Instrucoes de Pagamento
                            
BEGIN SEQUENCE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra arquivos de contas a receber ( SE1 )                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde, selecionando registros....")
	DbSelectArea("SE1")
	#IFNDEF TOP
		DbSetIndex(cIndexName + OrdBagExt())
	#ENDIF   
	dbGoTop()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existem registros que atendem ao criterio do filtro     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If SE1->( EoF() )
		MsgStop("Nenhum registro encontrado!", "FATR077")
		Break
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe tela para selecao de titulos                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If .Not. lImpAut
	
		@ 001,001 TO 400,700 DIALOG oDlg TITLE "Selecao de Titulos"
		@ 001,001 TO 170,350 BROWSE "SE1" MARK "E1_OK"
		@ 180,310 BMPBUTTON TYPE 01 ACTION (nOpc := 1,	Close(oDlg))
		@ 180,280 BMPBUTTON TYPE 02 ACTION (nOpc := 0,	Close(oDlg))
		
		ACTIVATE DIALOG oDlg CENTERED
		
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera boleto para titulos selecionados                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 1 .And. .Not. SE1->( EoF() )
	
		oPrint:=TMSPrinter():New( "FATR077 - BOLETO BANCARIO" )
		oPrint:SetPortrait()
		oPrint:EndPage()
	
		dbSelectArea("SE1")
		dbGoTop()


		While .Not. SE1->( EoF() )
			//rachadinha FB
			lRegistrado := .F.

			If !EMPTY(SE1->E1_IDCNAB)
				MsgAlert("Titulo " + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + " ja transferido para banco, boleto não pode ser gerado até o cancelamento do bordero bancario do titulo." + CRLF + "Favor entrar em contato com o financeiro", "FATR077")
			EndIf
			// não foi gerado IDCNAB mais já foi registrado
			If !EMPTY(SE1->E1_NUMBCO) .And. EMPTY(SE1->E1_IDCNAB)
				If !ApMsgYesNo("Titulo " + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + " ja possui registro bancario. Caso o boleto já enviado para o cliente, nao pode ser gerado. Deseja gerar assim mesmo?", "FATR077")
					lRegistrado := .T.
				Else
					MsgInfo("Numero bancario sera alterado!!!","Atencao")
				EndIf
			EndIf

			If Marked("E1_OK") .And. EMPTY(SE1->E1_IDCNAB) .And. !lRegistrado
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona arquivos                                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//SA6 (Bancos)
				SA6->( DbSetOrder(1) )
				SA6->( DbSeek(xFilial("SA6")+MV_PAR09+MV_PAR10+MV_PAR11) )
				        
				//SEE (Parametros Bancos)
				SEE->( DbSetOrder(1) )
				SEE->( DbSeek(xFilial("SEE")+MV_PAR09+MV_PAR10+MV_PAR11) )
						             
				//SA1 (Cliente)
				SA1->( DbSetOrder(1) )
				SA1->( DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)	 )   

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se cliente esta parametrizado para utiliza cao do boleto   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				/*If RTrim(SA1->A1_IMPBOLE) != "S"
					MsgAlert("O cliente " + RTrim(SA1->A1_NOME) + " não esta configurado para emissao do boleto de cobrança.", "FATR077")
					SE1->( dbSkip() )
					Loop
				EndIf*/				

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Variaveis                                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//If Empty(SA6->A6_BCOCORR)
					_Banco			:= RTrim(SA6->A6_COD)
					_NomeBanco		:= RTrim(SA6->A6_NOME)
					_Agencia		:= StrTran(StrTran( Substr(RTrim(SA6->A6_AGENCIA),1, IIf( At("-",RTrim(SA6->A6_AGENCIA)) > 0, At("-",RTrim(SA6->A6_AGENCIA)), Len(SA6->A6_AGENCIA))), "-", ""), ".", "")
					_DvAgencia		:= IIf( Empty(SA6->A6_DVAGE), Modulo11(SA6->A6_DVAGE), RTrim(SA6->A6_DVAGE) )
					_Conta			:= StrTran(StrTran(Substr(RTrim(SA6->A6_NUMCON),1, IIf( At("-",RTrim(SA6->A6_NUMCON)) > 0, At("-",RTrim(SA6->A6_NUMCON)), Len(SA6->A6_NUMCON))), "-", ""), ".", "")
					_DvConta		:= IIf( Empty(SA6->A6_DVCTA), Modulo11(SA6->A6_DVCTA), RTrim(SA6->A6_DVCTA) )
					_Carteira		:= IF(RTrim(SA6->A6_COD)$"001","17","  ")			//RTrim(SEE->EE_CARTEIR)
					_VarCarteira	:= IF(RTrim(SA6->A6_COD)$"001","019","  ")			//RTrim(IIf(!Empty(SEE->EE_VRCARTE), "-" + SEE->EE_VRCARTE, ""))
					_Convenio		:= StrTran(StrTran(RTrim(SEE->EE_CODEMP), "-", ""), ".", "")
				
				/*Else
					_Banco			:= RTrim(SA6->A6_BCOCORR)
					_NomeBanco		:= RTrim(SA6->A6_DESCORR)
					_Agencia		:= StrTran(StrTran( Substr(RTrim(SA6->A6_AGECORR),1, IIf( At("-",RTrim(SA6->A6_AGECORR)) > 0, At("-",RTrim(SA6->A6_AGECORR)), Len(SA6->A6_AGECORR))), "-", ""), ".", "") 
					_DvAgencia		:= IIf( Empty(SA6->A6_AGECORR), Modulo11(RTrim(SA6->A6_AGECORR)), RTrim(SA6->A6_AGECORR))
					_Conta			:= StrTran(StrTran(Substr(RTrim(SA6->A6_CTACORR),1, IIf( At("-",RTrim(SA6->A6_CTACORR)) > 0, At("-",RTrim(SA6->A6_CTACORR)), Len(SA6->A6_CTACORR))), "-", ""), ".", "")
					_DvConta		:= IIf( Empty(SA6->A6_CTACORR), Modulo11(RTrim(SA6->A6_CTACORR)), RTrim(SA6->A6_CTACORR))
					_Carteira		:= RTrim(SEE->EE_CARTEIR)
					_VarCarteira	:= RTrim(IIf(!Empty(SEE->EE_VRCARTE), "-" + SEE->EE_VRCARTE, ""))
					_Convenio		:= StrTran(StrTran(RTrim(SEE->EE_CODEMP), "-", ""), ".", "")
	
				EndIf  */  
				           
	            _LogoBanco	:= "banco_" + _banco + ".jpg"
				_DvBanco	:= Modulo11(_Banco)
			    _nVlrAbat	:= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
			    _nDiasJur	:= IIf(SE1->E1_VENCREA < dDatabase, DateDiffDay(SE1->E1_VENCREA, dDatabase ), 0)
			    _nVlrJur	:= (( 0.06 / 30 )  * SE1->E1_VALOR )
			    _nVlrTit	:= SE1->E1_VALOR + ( IIf( _nDiasJur > 0, ( _nDiasJur * _nVlrJur ), 0 ) )
			    _Vencimento	:= IIf( (dDatabase > SE1->E1_VENCREA), dDatabase, SE1->E1_VENCREA )
			    
			    If ALLTRIM(cFilAnt) == "0107" .And.Empty(SE1->E1_NUMBCO)
			    	//BANCO DO BRASIL
			    	//If Len(RTrim(SE1->E1_NUMBCO)) == 10 .And. RTrim(SA1->A1_IMPBOLE) == "S"	//19/01/17 Alterado opção para gerar somente carteira 17
					U_FINE002()
						
				EndIf
			    
			    _Sequencial	:= SE1->E1_NUMBCO

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Retorna Codigo de Barras / Linha Digitavel / Nosso Numero           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
			    _aCBLDNN	:= fCBLDNN(_Banco,_Agencia,_DvAgencia,_Conta,_DvConta,_Carteira,_nVlrTit,_Vencimento,_Convenio,_Sequencial)
			    If Len(_aCBLDNN) < 3
			    	Break
			    EndIf		    	
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Impressao - Inicio                                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				oPrint:StartPage()       
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Recibo de Entrega                                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:SayBitmap(0100,0200,_LogoBanco,400,120 )
				
				oPrint:Line(0150,0700,0205,0700)
				oPrint:Say(0148,0720,( _Banco + "-" + _DvBanco ),oFont1,100)				
				oPrint:Line(0150,0900,0205,0900)
				
				oPrint:Say(0160,0980,_aCBLDNN[2],oFont2,100)                                     
				
				oPrint:Box(0210,0200,0290,1500)   
				oPrint:Say(0210,0230,"Pagador",oFont3,100)   
				oPrint:Say(0240,0230,SA1->A1_NOME,oFont4,100)
	
				oPrint:box(0210,1500,0290,2200)
				oPrint:Say(0210,1530,"Vencimento",oFont3,100)			
				oPrint:Say(0240,2190,DtoC(_Vencimento),oFont4,,,,PAD_RIGHT)			
				                   
				oPrint:Box(0290,0200,0370,1500)   
				oPrint:Say(0290,0230,"Beneficiário",oFont3,100)   
				oPrint:Say(0320,0230,( RTrim(SM0->M0_NOMECOM)+ Space(5) + "CPF/CNPJ: " +  Transform(SM0->M0_CGC,"@R 99.999.999/9999-99") ),oFont4,100)			                          
	
				oPrint:Box(0290,1500,0370,2200)   
				oPrint:Say(0290,1530,"Agência / Código Beneficiário",oFont3,100)   
				oPrint:Say(0320,2190,( RTrim(_Agencia) + "-" + _DvAgencia + " / " + RTrim(_Conta) + "-" + _DvConta ),oFont4,,,,PAD_RIGHT)			                          
	
				oPrint:box(0370,0200,0450,0460)    
				oPrint:Say(0370,0230,"Data do Documento",oFont3,100)
				oPrint:Say(0400,0230,DtoC(SE1->E1_EMISSAO),oFont4,100)			                          
				
				oPrint:box(0370,0460,0450,0720)
				oPrint:Say(0370,0490,"Nro Documento",oFont3,100)
				oPrint:Say(0400,0490,( RTrim(SE1->E1_PREFIXO) + " " + SE1->E1_NUM + " " + SE1->E1_PARCELA ),oFont4,100)			                          
	
				oPrint:box(0370,0720,0450,980)
				oPrint:Say(0370,0750,"Espécie Documento",oFont3,100)
				oPrint:Say(0400,0750,"DM",oFont4,100)			                          
	
				oPrint:box(0370,0980,0450,1240)
				oPrint:Say(0370,1010,"Aceite",oFont3,100)
				oPrint:Say(0400,1010,"N",oFont4,100)			                          
	
				oPrint:box(0370,1240,0450,1500)
				oPrint:Say(0370,1270,"Data Processamento",oFont3,100)
				oPrint:Say(0400,1270,DtoC(dDatabase),oFont4,100)			                          
	
				oPrint:Box(0370,1500,0450,2200)
				oPrint:Say(0370,1530,"Nosso Número",oFont3,100)
				oPrint:Say(0400,2190,_aCBLDNN[3],oFont4,,,,PAD_RIGHT)			                          
	
				oPrint:box(0450,0200,0530,0460)    
				oPrint:Say(0450,0230,"Uso do Banco",oFont3,100)
				oPrint:Say(0480,0230,"",oFont4,100)			                          
				
				oPrint:box(0450,0460,0530,0720)
				oPrint:Say(0450,0490,"Carteira",oFont3,100)
				oPrint:Say(0480,0490,_Carteira,oFont4,100)			                          
	
				oPrint:box(0450,0720,0530,980)
				oPrint:Say(0450,0750,"Espécie",oFont3,100)
				oPrint:Say(0480,0750,"R$",oFont4,100)			                          
	
				oPrint:box(0450,0980,0530,1240)
				oPrint:Say(0450,1010,"Quantidade",oFont3,100)
				oPrint:Say(0480,1010,"",oFont4,100)			                          
	
				oPrint:box(0450,1240,0530,1500)
				oPrint:Say(0450,1270,"Valor",oFont3,100)
				oPrint:Say(0480,1270,"",oFont4,100)			                          
	
				oPrint:Box(0450,1500,0530,2200)
				oPrint:Say(0450,1530,"(=) Valor do Documento",oFont3,100)
				oPrint:Say(0480,2190,Transform(_nVlrTit,"@E 999,999,999.99"),oFont4,,,,PAD_RIGHT)			                                                                            
				
				oPrint:say(600,0200,"NOME DO RECEBEDOR",oFont4,100)
				oPrint:say(600,0800,Replicate("_",45),oFont4,100)
				oPrint:say(680,0200,"ASSINATURA DO RECEBEDOR",oFont4,100)
				oPrint:say(680,0800,Replicate("_",45),oFont4,100)
				oPrint:say(760,0200,"DATA DO RECEBIMENTO",oFont4,100)
				oPrint:say(760,0800,Replicate("_",45),oFont4,100)                                         
				
				oPrint:Say(760,2100,"Recido de Entrega",oFont2,,,,PAD_RIGHT) 
	
				oPrint:say(0850,0000,Replicate(". ",2000),oFont3,100)
	                                         
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Recibo do Pagador                                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
				oPrint:SayBitmap(0900,0200,_LogoBanco,400,120 )
				
				oPrint:Line(0950,0700,1005,0700)
				oPrint:Say(0948,0720,( _Banco + "-" + _DvBanco ),oFont1,100)				
				oPrint:Line(0950,0900,1005,0900)
				
				oPrint:Say(0960,0980,_aCBLDNN[2],oFont2,100)                                     
				
				oPrint:Box(1010,0200,1090,1500)   
				oPrint:Say(1010,0230,"Local de Pagamento",oFont3,100)   
				oPrint:Say(1040,0230,"Pagável em qualquer banco até o vencimento",oFont4,,,,PAD_LEFT)
	
				oPrint:Box(1010,1500,1090,2200)
				oPrint:Say(1010,1530,"Vencimento",oFont3,100)			
				oPrint:Say(1040,2190,DtoC(_Vencimento),oFont4,,,,PAD_RIGHT)	                                               
	                          
				oPrint:Box(1090,0200,1170,1500)   
				oPrint:Say(1090,0230,"Beneficiário",oFont3,100)   
				oPrint:Say(1120,0230,( RTrim(SM0->M0_NOMECOM)+ Space(5) + "CPF/CNPJ: " +  Transform(SM0->M0_CGC,"@R 99.999.999/9999-99") ),oFont4,,,,PAD_LEFT)			                          
	
				oPrint:Box(1090,1500,1170,2200)   
				oPrint:Say(1090,1530,"Agência / Código Beneficiário",oFont3,100)   
				oPrint:Say(1120,2190,( RTrim(_Agencia) + "-" + _DvAgencia + " / " + RTrim(_Conta) + "-" + _DvConta ),oFont4,,,,PAD_RIGHT)			                          
	                                    
				oPrint:box(1170,0200,1250,0460)    
				oPrint:Say(1170,0230,"Data do Documento",oFont3,100)
				oPrint:Say(1200,0230,DtoC(SE1->E1_EMISSAO),oFont4,100)			                          
				
				oPrint:box(1170,0460,1250,0720)
				oPrint:Say(1170,0490,"Nro Documento",oFont3,100)
				oPrint:Say(1200,0490,( RTrim(SE1->E1_PREFIXO) + " " + SE1->E1_NUM + " " + SE1->E1_PARCELA ),oFont4,100)			                          
	
				oPrint:box(1170,0720,1250,980)
				oPrint:Say(1170,0750,"Espécie Documento",oFont3,100)
				oPrint:Say(1200,0750,"DM",oFont4,100)			                          
	
				oPrint:box(1170,0980,1250,1240)
				oPrint:Say(1170,1010,"Aceite",oFont3,100)
				oPrint:Say(1200,1010,"N",oFont4,100)			                          
	
				oPrint:box(1170,1240,1250,1500)
				oPrint:Say(1170,1270,"Data Processamento",oFont3,100)
				oPrint:Say(1200,1270,DtoC(dDatabase),oFont4,100)			                          
	
				oPrint:Box(1170,1500,1250,2200)
				oPrint:Say(1170,1530,"Nosso Número",oFont3,100)
				oPrint:Say(1200,2190,_aCBLDNN[3],oFont4,,,,PAD_RIGHT)			           
	                                                      
				oPrint:box(1250,0200,1330,0460)    
				oPrint:Say(1250,0230,"Uso do Banco",oFont3,100)
				oPrint:Say(1280,0230,"",oFont4,100)			                          
				
				oPrint:box(1250,0460,1330,0720)
				oPrint:Say(1250,0490,"Carteira",oFont3,100)
				oPrint:Say(1280,0490,_Carteira,oFont4,100)			                          
	
				oPrint:box(1250,0720,1330,980)
				oPrint:Say(1250,0750,"Espécie",oFont3,100)
				oPrint:Say(1280,0750,"R$",oFont4,100)			                          
	
				oPrint:box(1250,0980,1330,1240)
				oPrint:Say(1250,1010,"Quantidade",oFont3,100)
				oPrint:Say(1280,1010,"",oFont4,100)			                          
	
				oPrint:box(1250,1240,1330,1500)
				oPrint:Say(1250,1270,"Valor",oFont3,100)
				oPrint:Say(1280,1270,"",oFont4,100)			                          
	
				oPrint:Box(1250,1500,1330,2200)
				oPrint:Say(1250,1530,"(=) Valor do Documento",oFont3,100)
				oPrint:Say(1280,2190,Transform(_nVlrTit,"@E 999,999,999.99"),oFont4,,,,PAD_RIGHT)	
	                           
				oPrint:box(1330,0200,1730,1500)    
				oPrint:Say(1330,0230,"Instruções ( Texto de exclusiva responsabilidade do cedente/beneficiário )",oFont3,100)
				oPrint:Say(1360,0230,("Cobrar juros de R$ " + AllTrim(Transform(_nVlrJur,"@E 999,999,999.99")) + " por dia de atraso de pagamento após " + DtoC(SE1->E1_VENCREA) ) ,oFont4,100)	
				oPrint:Say(1400,0230,("Sujeito a inclusão no Serasa e/ou Protesto após o vencimento"),oFont4,100)	
	
				oPrint:Box(1330,1500,1410,2200)
				oPrint:Say(1330,1530,"(-) Desconto/Abatimento",oFont3,100)
				oPrint:Say(1360,2190,"",oFont4,,,,PAD_RIGHT)	
	
				oPrint:Box(1410,1500,1490,2200)
				oPrint:Say(1410,1530,"(-) Outras Deduções",oFont3,100)
				oPrint:Say(1440,2190,"",oFont4,,,,PAD_RIGHT)	
	                                 
				oPrint:Box(1490,1500,1570,2200)
				oPrint:Say(1490,1530,"(+) Mora/Multa",oFont3,100)
				oPrint:Say(1520,2190,"",oFont4,,,,PAD_RIGHT)	
	
				oPrint:Box(1570,1500,1650,2200)
				oPrint:Say(1570,1530,"(+) Outros Acréscimos",oFont3,100)
				oPrint:Say(1600,2190,"",oFont4,,,,PAD_RIGHT)	
	
				oPrint:Box(1650,1500,1730,2200)
				oPrint:Say(1650,1530,"(=) Valor Cobrado",oFont3,100)
				oPrint:Say(1680,2190,"",oFont4,,,,PAD_RIGHT)	
	
				oPrint:box(1730,0200,1910,2200)                         
				oPrint:Say(1730,0230,"Pagador:",oFont3,100)
				oPrint:Say(1760,0230,( RTrim(SA1->A1_NOME) + Space(5) + "CPF/CNPJ: " +  IIf(RTrim(SA1->A1_PESSOA)=="J", Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"), Transform(SA1->A1_CGC,"@R 999.999.999-99")) ),oFont4,100)
				oPrint:Say(1795,0230,RTrim(SA1->A1_ENDCOB),oFont4,100)
				oPrint:Say(1830,0230,( RTrim(SA1->A1_MUNC) + " - " + RTrim(SA1->A1_ESTC) + " - " + RTrim(SA1->A1_CEPC)),oFont4,100)	//A1_CEPCOB
				oPrint:Say(1875,0230,"Sacador/Avalista:",oFont3,100)
	
				oPrint:Say(1850,2100,"Recibo do Pagador",oFont2,,,,PAD_RIGHT)    
	
				oPrint:Say(1915,2200,"Autenticação Mecânica",oFont3,,,,PAD_RIGHT)
				
				oPrint:say(2000,0000,Replicate(". ",2000),oFont4,100)
				                   
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Recibo do Sacado                                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
				oPrint:SayBitmap(2050,0200,_LogoBanco,400,120 )
				
				oPrint:Line(2100,0700,2155,0700)
				oPrint:Say(2098,0720,( _Banco + "-" + _DvBanco ),oFont1,100)				
				oPrint:Line(2100,0900,2155,0900)
				
				oPrint:Say(2110,0980,_aCBLDNN[2],oFont2,100)                                     
				             
				oPrint:Box(2160,0200,2240,1500)   
				oPrint:Say(2160,0230,"Local de Pagamento",oFont3,100)   
				oPrint:Say(2190,0230,"Pagavel em qualquer banco até o vencimento",oFont4,,,,PAD_LEFT)
	
				oPrint:box(2160,1500,2240,2200)
				oPrint:Say(2160,1530,"Vencimento",oFont3,100)			
				oPrint:Say(2190,2190,DtoC(_Vencimento),oFont4,,,,PAD_RIGHT)	              			                                         
				                 
				oPrint:Box(2240,0200,2320,1500)   
				oPrint:Say(2240,0230,"Beneficiário",oFont3,100)   
				oPrint:Say(2270,0230,( RTrim(SM0->M0_NOMECOM)+ Space(5) + "CPF/CNPJ: " +  Transform(SM0->M0_CGC,"@R 99.999.999/9999-99") ),oFont4,,,,PAD_LEFT)			                          
	
				oPrint:Box(2240,1500,2320,2200)   
				oPrint:Say(2240,1530,"Agência / Código Beneficiário",oFont3,100)   
				oPrint:Say(2270,2190,( RTrim(_Agencia) + "-" + _DvAgencia + " / " + RTrim(_Conta) + "-" + _DvConta ),oFont4,,,,PAD_RIGHT)			      			                  
			
				oPrint:box(2320,0200,2400,0460)    
				oPrint:Say(2320,0230,"Data do Documento",oFont3,100)
				oPrint:Say(2350,0230,DtoC(SE1->E1_EMISSAO),oFont4,100)			                          
				
				oPrint:box(2320,0460,2400,0720)
				oPrint:Say(2320,0490,"Nro Documento",oFont3,100)
				oPrint:Say(2350,0490,( RTrim(SE1->E1_PREFIXO) + " " + SE1->E1_NUM + " " + SE1->E1_PARCELA ),oFont4,100)			                          
	
				oPrint:box(2320,0720,2400,980)
				oPrint:Say(2320,0750,"Espécie Documento",oFont3,100)
				oPrint:Say(2350,0750,"DM",oFont4,100)			                          
	
				oPrint:box(2320,0980,2400,1240)
				oPrint:Say(2320,1010,"Aceite",oFont3,100)
				oPrint:Say(2350,1010,"N",oFont4,100)			                          
	
				oPrint:box(2320,1240,2400,1500)
				oPrint:Say(2320,1270,"Data Processamento",oFont3,100)
				oPrint:Say(2350,1270,DtoC(dDatabase),oFont4,100)			                          
	
				oPrint:Box(2320,1500,2400,2200)
				oPrint:Say(2320,1530,"Nosso Número",oFont3,100)
				oPrint:Say(2350,2190,_aCBLDNN[3],oFont4,,,,PAD_RIGHT)			           
				                                          
				oPrint:box(2400,0200,2480,0460)    
				oPrint:Say(2400,0230,"Uso do Banco",oFont3,100)
				oPrint:Say(2430,0230,"",oFont4,100)			                          
				
				oPrint:box(2400,0460,2480,0720)
				oPrint:Say(2400,0490,"Carteira",oFont3,100)
				oPrint:Say(2430,0490,_Carteira,oFont4,100)			                          
	
				oPrint:box(2400,0720,2480,980)
				oPrint:Say(2400,0750,"Espécie",oFont3,100)
				oPrint:Say(2430,0750,"R$",oFont4,100)			                          
	
				oPrint:box(2400,0980,2480,1240)
				oPrint:Say(2400,1010,"Quantidade",oFont3,100)
				oPrint:Say(2430,1010,"",oFont4,100)			                          
	
				oPrint:box(2400,1240,2480,1500)
				oPrint:Say(2400,1270,"Valor",oFont3,100)
				oPrint:Say(2430,1270,"",oFont4,100)			                          
	
				oPrint:Box(2400,1500,2480,2200)
				oPrint:Say(2400,1530,"(=) Valor do Documento",oFont3,100)
				oPrint:Say(2430,2190,Transform(_nVlrTit,"@E 999,999,999.99"),oFont4,,,,PAD_RIGHT)				
				
				oPrint:box(2480,0200,2880,1500)    
				oPrint:Say(2480,0230,"Instruções ( Texto de exclusiva responsabilidade do cedente/beneficiário )",oFont3,100)
				oPrint:Say(2510,0230,("Cobrar juros de R$ " + AllTrim(Transform(_nVlrJur,"@E 999,999,999.99")) + " por dia de atraso de pagamento após " + DtoC(SE1->E1_VENCREA) ) ,oFont4,100)	
				oPrint:Say(2550,0230,("Sujeito a inclusão no Serasa e/ou Protesto após o vencimento"),oFont4,100)	
	            
				oPrint:Box(2480,1500,2560,2200)
				oPrint:Say(2480,1530,"(-) Desconto/Abatimento",oFont3,100)
				oPrint:Say(2510,2190,"",oFont4,,,,PAD_RIGHT)	
	
				oPrint:Box(2560,1500,2640,2200)
				oPrint:Say(2560,1530,"(-) Outras Deduções",oFont3,100)
				oPrint:Say(2590,2190,"",oFont4,,,,PAD_RIGHT)	
	                                 
				oPrint:Box(2640,1500,2720,2200)
				oPrint:Say(2640,1530,"(+) Mora/Multa",oFont3,100)
				oPrint:Say(2670,2190,"",oFont4,,,,PAD_RIGHT)	
	
				oPrint:Box(2720,1500,2800,2200)
				oPrint:Say(2720,1530,"(+) Outros Acréscimos",oFont3,100)
				oPrint:Say(2750,2190,"",oFont4,,,,PAD_RIGHT)	
	
				oPrint:Box(2800,1500,2880,2200)
				oPrint:Say(2800,1530,"(=) Valor Cobrado",oFont3,100)
				oPrint:Say(2830,2190,"",oFont4,,,,PAD_RIGHT)				                                                    
				
				oPrint:box(2880,0200,3050,2200)                         
				oPrint:Say(2880,0230,"Pagador:",oFont3,100)
				oPrint:Say(2910,0230,( RTrim(SA1->A1_NOME) + Space(5) + "CPF/CNPJ: " +  IIf(RTrim(SA1->A1_PESSOA)=="J", Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"), Transform(SA1->A1_CGC,"@R 999.999.999-99")) ),oFont4,100)
				oPrint:Say(2945,0230,RTrim(SA1->A1_ENDCOB),oFont4,100)
				oPrint:Say(2980,0230,( RTrim(SA1->A1_MUNC) + " - " + RTrim(SA1->A1_ESTC) + " - " + RTrim(SA1->A1_CEPC)),oFont4,100)	//A1_CEPCOB
				oPrint:Say(3015,0230,"Sacador/Avalista:",oFont3,100)
	
				oPrint:Say(2990,2100,"Ficha de Compensação",oFont2,,,,PAD_RIGHT)    
	
				oPrint:Say(3055,2200,"Autenticação Mecânica",oFont3,,,,PAD_RIGHT)
			
				MSBAR("INT25",26.5,2.3,_aCBLDNN[1],oPrint,.F.,Nil,Nil,0.0212,1.3,Nil,Nil,"A",.F.)
				                  
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Impressao - Termino                                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:EndPage()
		
			EndIf
			           
			DbSelectArea("SE1")
			SE1->( dbSkip() )
			
		EndDo
	
		If .Not. lImpAut
			oPrint:Preview()   
		Else	
			oPrint:Print()
		EndIf
		
	EndIf
                      
END SEQUENCE        
        
DbSelectArea("SE1") 
RetIndex("SE1")
FErase(cIndexName+OrdBagExt())

SE1->( dbClearAllFilter() )

Restarea( aAreaSA6 )
Restarea( aAreaSEE )
Restarea( aAreaSE1 )
Restarea( aArea )

Return( Nil )


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// fCBLDNN
//------------------------------------------------------------------------------------------------------------------------------------
//Retorna os strings para inpressão do Boleto
//CB = Codigo de barras, LD = Linha digitável, NN = Nosso Numero
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fCBLDNN(cBanco,cAgencia,cDacAG,cConta,cDacCC,cCarteira,nValor,dVencimento,cConvenio,cNroSeq)
                             
Local cFatVenc		:= StrZero(dVencimento - CtoD("07/10/1997"),4)
Local cMoedaPad		:= "9" //REAL
Local cValor		:= ""

Local cNNumSDig		:= ""
Local cNNum	   		:= ""
Local cNossoNum		:= "" 

Local cCodBarSDig	:= ""
Local cCodBarra		:= ""

Do Case
	
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|BANCO BRASIL                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 	
	Case cBanco	== "001"

		If Len(RTrim(cConvenio)) == 7
		
			If Len(RTrim(cNroSeq)) != 10 .Or. Left(cNroSeq,3) != "500"
				MsgStop("Valor do campo E1_NUMBCO deve ter 10 posições iniciando com 500.")
				Return({})				
			EndIf				


			cNroSeq		:= StrZero(Val(cNroSeq)		,10)
			cBanco		:= StrZero(Val(cBanco)		,03)
			cAgencia	:= StrZero(Val(cAgencia)	,04) 
			cConta		:= StrZero(Val(cConta)		,08) 
			cCarteira	:= StrZero(Val(cCarteira)	,02)     
			cValor		:= StrZero((nValor*100)		,10)
			cConvenio	:= StrZero(Val(cConvenio)	,07)   
			cDV_NNum	:= "" // -> Para convenios acima de 1.000.000 nao é necessario calcular DV para o nosso numero
	
			cNNumSDig	:= cConvenio + cNroSeq
			cNNum		:= cNNumSDig + cDV_NNum	
			cNossoNum	:= cNNumSDig
	                 
			cCodBarSDig	:= cBanco + cMoedaPad + cFatVenc + cValor + Replicate("0", 6) + cNNumSDig + cCarteira
			cCodBarra	:= cBanco + cMoedaPad + fCodBarDAC(cCodBarSDig) + cFatVenc + cValor + Replicate("0", 6) + cNNumSDig + cCarteira
			
		Else
			MsgStop("Convênio de " + cValToChar(Len(cConvenio)) + " posições não implementado no programa FATR077.")
			Return({})
		EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|BANCO BRADESCO                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 	
	Case cBanco == "237"
                          
			If Len(RTrim(cNroSeq)) != 11 .Or. Left(cNroSeq,4) != "5000"
				MsgStop("Valor do campo E1_NUMBCO deve ter 11 posições iniciando com 5000.")
				Return({})				
			EndIf				

			cNroSeq		:= StrZero(Val(cNroSeq)		,11)
			cBanco		:= StrZero(Val(cBanco)		,03)
			cAgencia	:= StrZero(Val(cAgencia)	,04) 
			cConta		:= StrZero(Val(cConta)		,07) 
			cCarteira	:= StrZero(Val(cCarteira)	,02)     
			cValor		:= StrZero((nValor*100)		,10)
			cDV_NNum	:= U_FINE02NN()          
	
			cNNumSDig	:= cCarteira + cNroSeq
			cNNum		:= cNNumSDig + cDV_NNum
			cNossoNum	:= cCarteira + "/" + cNroSeq + "-" + cDV_NNum				   
	                 
			cCodBarSDig	:= cBanco + cMoedaPad + cFatVenc + cValor + cAgencia + cCarteira + cNroSeq + cConta + "0"
			cCodBarra	:= cBanco + cMoedaPad + fCodBarDAC(cCodBarSDig) + cFatVenc + cValor + cAgencia + cCarteira + cNroSeq + cConta + "0"
	
	Otherwise           
		MsgStop("Banco " + cBanco + " não implementado no programa FATR077.")
		Return({})

EndCase
                        

//Digito Verificador do Primeiro Campo                  
cPrCpo := cBanco + cMoedaPad + SubStr(cCodBarra,20,5)
cDvPrCpo := AllTrim(Str(fModulo10(cPrCpo)))

//Digito Verificador do Segundo Campo
cSgCpo := SubStr(cCodBarra,25,10)
cDvSgCpo := AllTrim(Str(fModulo10(cSgCpo)))

//Digito Verificador do Terceiro Campo
cTrCpo := SubStr(cCodBarra,35,10)
cDvTrCpo := AllTrim(Str(fModulo10(cTrCpo)))

//Digito Verificador Geral
cDvGeral := SubStr(cCodBarra,5,1)

//Linha Digitavel
cLindig := SubStr(cPrCpo,1,5) + "." + SubStr(cPrCpo,6,4) + cDvPrCpo + " "	//primeiro campo
cLinDig += SubStr(cSgCpo,1,5) + "." + SubStr(cSgCpo,6,5) + cDvSgCpo + " "	//segundo campo
cLinDig += SubStr(cTrCpo,1,5) + "." + SubStr(cTrCpo,6,5) + cDvTrCpo + " "	//terceiro campo
cLinDig += cDvGeral + " "													//dig verificador geral
cLinDig += SubStr(cCodBarra,6,4)+SubStr(cCodBarra,10,10)					//fator de vencimento e valor nominal do titulo

Return({cCodBarra,cLinDig,cNossoNum})   


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo 10
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fModulo10( xNum )
Local cNum    := IIf( Type("xNum") == "N", cValToChar( xNum ), xNum )
Local nFor    := 0
Local nTot    := 0
Local cNumAux

// Verifico o numero de digitos e impar
// Caso seja, adiciono um caracter
If Len(cNum)%2 #0
	cNum := "0"+cNum
EndIf

For nFor := 1 To Len(cNum)
	If nFor%2 == 0
		cNumAux := StrZero(2 * Val(SubStr(cNum,nFor,1)), 2)
	Else
		cNumAux := StrZero(Val(SubStr(cNum,nFor,1))    , 2)
	Endif
	nTot += ( Val(LEFT(cNumAux,1)) + Val(Right(cNumAux,1)) )
Next

nTot := nTot % 10
nTot := If( nTot#0, 10-nTot, nTot )

Return nTot


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DAC - CODIGO DE BARRAS
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fCodBarDAC( cCodBarSDig )
Local aArea		:= GetArea() 
Local nCont		:= 0
Local nPeso		:= 0
Local nResto	:= 0
Local cDV_BARRA	:= ""       
Local i			:= 0  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verifica se o tamanho da string eh composta de 43 caracteres        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(cCodBarSDig) != 43
	MsgStop( "O parametro nao compoe uma cadeia de 43 caracteres necessários para o calculo do digito verificador do codigo de barras!", "FINE002DVB")
	Return( "" )
EndIf                  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Calcula DAC do codigo de barras                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nCont := 0         
nPeso := 2

For i := 43 To 1 Step -1
	nCont := nCont + ( Val(Substr( cCodBarSDig,i,1 )) * nPeso )
	nPeso := nPeso + 1

	If  nPeso > 9
		nPeso := 2
	EndIf

Next i

nResto  := ( nCont % 11 )  

If nResto == 1 .Or. nResto == 0
	cDV_BARRA := "1"
Else
	nResto		:= (11-nResto)
	cDV_BARRA	:= cValToChar(nResto)
EndIf

Restarea( aArea ) 

Return( cDV_BARRA )
