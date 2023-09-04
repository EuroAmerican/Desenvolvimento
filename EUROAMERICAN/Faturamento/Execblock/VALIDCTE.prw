//Valida CTe
//Static Function ValidCTe() 
#define ENTER chr(13) + chr(10)

User Function ValidCTe() 

Local xNFeChave 	:= ""
Local xCNPJEmit 	:= ""
Local xCNPJReme 	:= ""
Local xCNPJDest 	:= ""
Local xNFiscal  	:= ""
Local xSerie    	:= ""
Local xEmissao 	 	:= StoD("")
Local xTotalNF  	:= 0
Local xFreteNF  	:= 0    
Local xTotalPIS 	:= 0
Local xTotalCOF  	:= 0    
Local xTotalST		:= 0	  
Local xTotalICM		:= 0	  

Local nBsPIS		:= 0
Local nVrPIS		:= 0
Local nBsCOF		:= 0
Local nVrCOF		:= 0      
Local nBsIPI		:= 0						
Local nVrIPI		:= 0  
Local nBsST			:= 0
Local nVrST			:= 0
Local nBsICM		:= 0
Local nVrICM		:= 0    

Local cMsg	  		:= ""    

Local lRet      	:= .T.    

// Popula variaveis com valores do arquivo XML
xNFeChave := StrTran(Upper(oXML:_INFCTE:_ID:TEXT),"CTE","")
xTomador  := IIf(;
					XmlChildEx(oXML:_INFCTE:_IDE,"_TOMA03"	) != Nil	,; 
					AllTrim( oXML:_INFCTE:_IDE:_TOMA03:_TOMA:TEXT )		,; 
					IIF(XmlChildEx(oXML:_INFCTE:_IDE,"_TOMA3"	) != Nil, AllTrim( oXML:_INFCTE:_IDE:_TOMA3:_TOMA:TEXT ) , ;					//Adicionado 23/10/2017: Conforme leiaute CTe 3.0 substitu?o tag TOMA03 por TOMA3
					IIF(AllTrim(oXML:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT) != Nil,AllTrim(oXML:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT),"")		;			//Alterado 10/10/2017: AllTrim(oXML:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT)		;
				) )
xCNPJEmit := IIf( Type("oXML:_INFCTE:_EMIT:_CNPJ") != "U", AllTrim(oXML:_INFCTE:_EMIT:_CNPJ:TEXT), AllTrim(oXML:_INFCTE:_EMIT:_CPF:TEXT) )
xCNPJReme := IIf( Type("oXML:_INFCTE:_REM:_CNPJ") != "U", AllTrim(oXML:_INFCTE:_REM:_CNPJ:TEXT), AllTrim(oXML:_INFCTE:_REM:_CPF:TEXT) )
xCNPJDest := IIf( Type("oXML:_INFCTE:_DEST:_CNPJ") != "U", AllTrim(oXML:_INFCTE:_DEST:_CNPJ:TEXT), AllTrim(oXML:_INFCTE:_DEST:_CPF:TEXT) )
xNFiscal  := AllTrim(oXML:_INFCTE:_IDE:_NCT:TEXT)
xSerie    := AllTrim(oXML:_INFCTE:_IDE:_SERIE:TEXT)
xEmissao  := StoD(StrTran(AllTrim(Left(oXML:_INFCTE:_IDE:_DHEMI:TEXT,10)),"-",""))
xTotalNF  := Val(oXML:_INFCTE:_VPREST:_VTPREST:TEXT)
xTotalICM := IIf( XmlChildEx(oXML:_INFCTE:_IMP:_ICMS,"_ICMS00") != Nil, Val(oXML:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT), 0 )
xTotalPIS := 0
xTotalCOF := 0
xTotalIPI := 0
xTotalST  := 0
 	
// Verifica se nota fiscal ?v?ida na SEFAZ
If lRet .And. !U_NFeGetChv(xNFeChave)

	MsgStop("Nao foi poss?el validar a nota fiscal junto a SEFAZ." + ENTER +;
			"Entre em contato com a equipe de informatica para continuar com o processo.", "Atenção")

	lRet := .F.

EndIf			    

// Verifica se nota fiscal ?para a filial ativa
If lRet        
	// 0-Remetente; 1-Expedidor; 2-Recebedor; 3-Destinat?io
	If ( xTomador == "3" .And. AllTrim(SM0->M0_CGC) != xCNPJDest ) .Or. ( xTomador == "0" .And. AllTrim(SM0->M0_CGC) != xCNPJReme )
		MsgStop( "Este arquivo n? pertence a esta Filial!", "Atenção" )
	    lRet := .F.			
	 EndIf
EndIf

// Verifica se a nota fiscal digitada ?a mesma do arquivo XML
If lRet .And. ( Val(cNFiscal) != Val(xNFiscal) ) 
	MsgStop( "Este arquivo n? pertence a nota fiscal informada!", "Atenção" )
    lRet := .F.      
EndIf
             
// Verifica se a serie digitada ?a mesma do arquivo XML
If lRet
	         
	lIsNumber := .T.
	For i := Len(cSerie) To 1 Step -1
		If !SubStr(cSerie,i,1) $ "0123456789" 
			lIsNumber := .F.
			Exit
		EndIf
	Next 			
	
	If ( lIsNumber .And. (Val(cSerie) != Val(xSerie)) ) .Or. ( !lIsNumber .And. (AllTrim(cSerie) != AllTrim(xSerie)) )
		MsgStop( "Este arquivo n? pertence a serie informada!", "Atenção" )
	    lRet := .F.                                
	EndIf

EndIf
		
// Verifica se o fornecedor ( CNPJ ) informado ?o mesmo do arquivo XML
If lRet     

	(macroAlias)->(dbSelectArea(macroAlias))
	(macroAlias)->(dbSetOrder(3))
	(macroAlias)->(dbSeek(xFilial(macroAlias)+xCNPJEmit))

	If (macroAlias)->( !Found() ) .Or. ( &macroCLIFOR != cA100For ) .Or. ( &macroLOJA != cLoja )
		MsgStop( "Este arquivo n? pertence ao fornecedor ou cliente informado!", "Atenção" )
	    lRet := .F.                                               
	EndIf						                                  

EndIf

// Verifica se a data de emissao ?a mesma do arquivo XML
If lRet .And. ( dDEmissao != xEmissao )
	MsgStop( "A data de emissao n? ?a mesma do arquivo!", "Atenção" )
    lRet := .F.    				
EndIf		           

// Verifica se os impostos PIS/COFINS/IPI e o mesmo do arquivo XML
If lRet    

	aImpFis := aClone( oFisRod:aArray )
	
	nBsPIS   := 0
	nVrPIS   := 0
	
	nBsCOF   := 0
	nVrCOF   := 0
	         
	nBsIPI   := 0						
	nVrIPI   := 0  
	
	nBsST	 := 0
	nVrST	 := 0
	
	nBsICM	 := 0
	nVrICM	 := 0

	For nX := 1 To Len( aImpFis )
	                    
		If AT( "PS2", aImpFis[nX, 1] ) > 0
			nBsPIS += aImpFis[nX, 3]
			nVrPIS += IIf( mv_par09 == 1, aImpFis[nX, 5], aImpFis[nX, 4] )
		EndIf
	
		If AT( "CF2", aImpFis[nX, 1] ) > 0
			nBsCOF += aImpFis[nX, 3]
			nVrCOF += IIf( mv_par09 == 1, aImpFis[nX, 5], aImpFis[nX, 4] )
		EndIf
	
		If AT( "IPI", aImpFis[nX, 1] ) > 0
			nBsIPI += aImpFis[nX, 3]
			nVrIPI += IIf( mv_par09 == 1, aImpFis[nX, 5], aImpFis[nX, 4] )
		EndIf
	
		If AT( "ICR", aImpFis[nX, 1] ) > 0
			nBsST += aImpFis[nX, 3]
			nVrST += IIf( mv_par09 == 1, aImpFis[nX, 5], aImpFis[nX, 4] )
		EndIf

		If AT( "ICM", aImpFis[nX, 1] ) > 0
			nBsICM += aImpFis[nX, 3]
			nVrICM += IIf( mv_par09 == 1, aImpFis[nX, 5], aImpFis[nX, 4] )
		EndIf
	
	Next nX	
     
	If nVrIPI != xTotalIPI
		cMsg += "O valor do imposto IPI ( R$ " +  cValToChar( nVrIPI ) + " ) n? ?o mesmo do arquivo XML ( R$ " +  cValToChar( xTotalIPI ) + " )." + ENTER + ENTER
   		lRet := .F.    	                                                           
	EndIf   
	
	If nVrST != xTotalST
		cMsg += "O valor do imposto ICMS ST ( R$ " +  cValToChar( nVrST ) + " ) n? ?o mesmo do arquivo XML ( R$ " +  cValToChar( xTotalST ) + " )." + ENTER + ENTER
   		lRet := .F.    	                                                           
	EndIf   
	   		
	If nVrICM != xTotalICM
   		cMsg += "O valor do imposto ICMS ( R$ " +  cValToChar( nVrICM ) + " ) n? ?o mesmo do arquivo XML ( R$ " +  cValToChar( xTotalICM ) + " )." + ENTER + ENTER
   		lRet := .F.    	                                                           
	EndIf   
	
	If !lRet
   		Aviso("Conferencia de Imposto", "H?imposto com valor diferente do arquivo XML. Verifique abaixo: " + ENTER + cMsg, {"Ok"}, 3)	
	EndIf
	
EndIf	

// Verifica se o total da nota  e o mesmo do arquivo XML
If lRet    
    
	nPosTotal := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})
	nPosDesc  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VALDESC"})
	nPosDesp  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_DESPESA"})

	nTotalNF  := 0
	nDescNF   := 0
	nDespNF   := 0	                 
	
	For nX:=1 to len(aCols) 
		If !( aCols[nX][Len(aHeader)+1] )
			nTotalNF += aCols[nX][nPosTotal]
			nDescNF  += aCols[nX][nPosDesc]
			nDespNF  += aCols[nX][nPosDesp]
		EndIf
	Next nX						             
              
	// Verifica se o total informado ?o mesmo do arquivo XML          
	If ( xTotalNF != ( nTotalNF + nVrIPI + nVrST + nDespNF - nDescNF ) ) .And.  !AllTrim(cTipo) $ "I#P" //N? validar valor para Complemento de IPI e ICM
		MsgStop( "O valor total ( R$ " + cValToChar(nTotalNF + nVrIPI + nVrST + nDespNF - nDescNF) + " )  nao ?o mesmo do arquivo XML ( R$ " + cValToChar( xTotalNF ) + " ).", "Atenção" )
    	lRet := .F.    		
	EndIf
			
EndIf 				
								
Return( lRet )
