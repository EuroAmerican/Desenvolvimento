#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"   
#include "protheus.ch"

#define ENTER CHR(13) + CHR(10)  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FINE002  ºAutor  ³Alexandre Marson    º Data ³  04/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Devolve o nosso numero para o titulo financeiro conforme   º±±
±±º          ³ o banco selecionado                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                     A L T E R A C O E S                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ºProgramador       ºAlteracoes                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º23/01/18  ºEmerson Paiva     ºAjuste rotina p/ P12 e atualiz E1_NUMBCO º±±
±±º          º                  º                                         º±±
±±º          º                  º                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                        
User Function FINE002
//Local lRet		:= .T.
Local aArea		:= GetArea()        
Local cNumBco	:= ""
Local cMvPar    := "MV_NBOLETO"

BEGIN SEQUENCE 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Rotina liberada apenas para as empresas 0107 e 0108                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	// Grupo Empresa - Ajuste realizado (CG)

	// If cEmpAnt+cFilAnt $ "0106;0107;0108" .And. Empty(SE1->E1_NUMBCO)	//Atualizado 23/01/18

	If cFilAnt $ "0106;0107;0108" .And. Empty(SE1->E1_NUMBCO)	//Atualizado 23/01/18
                                         
        //Verifica a existencia do parametro no SX6
        SX6->( dbSetOrder(1) )
        SX6->( dbSeek(xFilial("SE1")+cMvPar) )
        
        //Caso nao encontre, cria o mesmo
        If SX6->( !Found() )
			RecLock("SX6", .T.)
				SX6->X6_FIL         := xFilial("SE1")
				SX6->X6_VAR         := cMvPar
				SX6->X6_TIPO        := "C" 
				SX6->X6_DESCRIC     := "Ultimo número de boleto gerado"
				SX6->X6_CONTEUD     := "0000000"
				SX6->X6_PROPRI      := "U"
			SX6->( MsUnLock() )          
		EndIf		

		//Gera um novo numero sequencial 
		cNumBco := Left(SX6->X6_CONTEUD,7)
		cNumBco := Soma1(cNumBco)
		
		//Atualiza valor do parametro           
		RecLock("SX6", .F.)      
			SX6->X6_CONTEUD := cNumBco
		SX6->( MsUnlock() )

		//Devolve o nosso numero conforme regra da entidade financeira
		Do Case

			Case ALLTRIM(cFilAnt) == "0107" 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| JAYS - Utiliza conta no banco do brasil com convenio de 7 posicoes. ³ 
				//|        Numeracao iniciada na faixa 500 + 7 numeros sequenciais,     ³
				//|        totalizando as 10 posicoes exigidas pelo manual.             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cNumBco := "500" + cNumBco 

			Case ALLTRIM(cFilAnt) == "0108" 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| QCOR - Utiliza conta no bradesco.                                   ³
				//|        Numeracao iniciada na faixa 5000 + 7 numeros sequenciais,    ³
				//|        totalizando as 11 posicoes exigidas pelo manual              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cNumBco := "5000" + cNumBco 
			
			Otherwise       
				cNumBco := cNumBco
		
		EndCase
		
		/*//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Atualiza campo E1_NUMBCO                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQry := " UPDATE	" + RetSqlName("SE1") + ENTER
		cQry += " SET		E1_NUMBCO	= '" + cNumBco + "' " + ENTER
		cQry += " WHERE		D_E_L_E_T_	= '' " + ENTER
		cQry += " AND 		E1_FILIAL	= '" + xFilial("SE1") + "' " + ENTER
		cQry += " AND 		E1_PREFIXO	= '" + SE1->E1_PREFIXO + "' " + ENTER
		cQry += " AND 		E1_NUM 		= '" + SE1->E1_NUM + "' " + ENTER
		cQry += " AND 		E1_PARCELA	= '" + SE1->E1_PARCELA + "' " + ENTER
		cQry += " AND 		E1_CLIENTE	= '" + SE1->E1_CLIENTE + "' " + ENTER
		cQry += " AND 		E1_LOJA 	= '" + SE1->E1_LOJA + "' " + ENTER
		
		If (TcSQLExec(cQry) < 0)
			MsgStop("TCSQLError() " + TCSQLError())
			lRet := .F.  
		EndIf     */     
		
		//Atualizado 23/01/18
		dbSelectArea("SE1")
		RecLock("SE1",.F.)
			SE1->E1_NUMBCO := cNumBco
		SE1->( MsUnlock() )
	
	EndIf
	
END SEQUENCE	

RestArea( aArea ) 

Return( )	//Return( lRet )


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//DAC - NOSSO NUMERO
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function FINE02NN()
Local aArea		:= GetArea()     
Local aAreaSE1	:= SE1->( GetArea() )
Local aAreaSEE	:= SEE->( GetArea() )

Local cBanco	:= RTrim( IIf( ValType("SEE->EE_CODIGO")  != "U", SEE->EE_CODIGO,  "" ) )
Local cCarteira	:= RTrim( IIf( ValType("SEE->EE_CARTEIR") != "U", SEE->EE_CARTEIR, "" ) )
Local cConvenio	:= RTrim( IIf( ValType("SEE->EE_CODEMP")  != "U", SEE->EE_CODEMP,  "" ) )
Local cNumBco	:= RTrim( IIf( ValType("SE1->E1_NUMBCO")  != "U", SE1->E1_NUMBCO,  "" ) )
Local nCont		:= 0
Local nPeso		:= 0   
Local nResto	:= 0
Local i			:= 0          
Local cDV_NNUM	:= ""    

If Empty( cBanco ) ;
	.Or. Empty( cCarteira ) ;
	.Or. Empty( cNumBco )
	
	MsgStop( "Não foi possível identificar o banco, carteira ou nosso numero", "FINE002DV")

	Return( "" )

EndIf               


Do Case        
                        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| 001 - Banco do Brasil ( Peso 2 -> 9 )                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cBanco == "001"
	
		If Len(cConvenio) >= 7   
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Não há DV - Dígito Verificador - para o Nosso-Número, quando o      ³
			//| número convênio de cobrança for acima de 1.000.000 (um milhão).     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cDV_NNUM := ""
		
		Else

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Implementar calculo do nosso numero para outros convenios BB        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| 237 - Bradesco ( Peso: 2 -> 7 )                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cBanco == "237"

		 nCont   	:= 0
		 nPeso   	:= 2      
		 cNNumero	:= StrZero(Val(cCarteira),2) + StrZero(Val(cNumBco),11)
		                   
		For i := 13 To 1 Step -1
			
			 nCont :=  nCont + (Val(SubStr(cNNumero,i,1))) * nPeso
			 nPeso :=  nPeso + 1
			
			If nPeso == 8
				nPeso := 2
			EndIf
			
		Next
		
		nResto := (nCont % 11)
		
		If nResto == 1
			cDV_NNUM := "P"

		ElseIf nResto == 0
			cDV_NNUM := "0"

		Else
			nResto		:= (11-nResto)
			cDV_NNUM	:= cValToChar(nResto)
		
		EndIf

EndCase
                      
Restarea( aAreaSE1 )     
Restarea( aAreaSEE )     
Restarea( aArea )     

Return( cDV_NNUM )