#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CBRETEAN  ºAutor  ³                    º Data ³  22/08/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para possibilitar a leitura de varios     º±±
±±º          ³ codigos de barra para o mesmo produto.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/            
User Function CBRETEAN()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declara as Variaveis													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea    		:= GetArea()
Local aAreaSB1 		:= SB1->(GetArea())
Local aAreaSB8 		:= SB8->(GetArea())
Local aRet     		:= {}
Local cEtiqueta		:= ParamIXB[1]
Local cCodProd		:= Padr(Substr(Alltrim(cEtiqueta),1,15),15)
Local cProduto 		:= Space(Len(SB1->B1_COD))
Local cLote    		:= Padr(Substr(cEtiqueta,16,10),10) //Space(10)
Local dDtValid 		:= SToD(Substr(cEtiqueta,26,8))
Local nQtde    		:= 1 
Local lQtde    		:= .F. 
Local lFound   		:= .F.
Local cCodGrv  		:= ""
Local cCodTip		:= ""
 
If Empty(cCodProd)
   Return (aRet)
Endif  
                                 
//acdV120 - CONFERENCIA
//ACDV121 - CONFERENCIA NF
/*                     
If Alltrim(FunName()) $ "ACDV120|ACDV121|ACDV166|ACDV177"
	dDtValid	:= StoD(substr(cEtiqueta,26,8))
Else
	dDtValid	:= CtoD("  /  /  ")
Endif
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o Codigo de Controle do Usuário								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(alltrim(cEtiqueta)) == 13 // Código EAN-13  

	DBSelectArea("SB1")	// Cadastro de Produto
	DBSetOrder(5) 		// B1_FILIAL+B1_CODBAR
	If DBSeek(xFilial("SB1")+cEtiqueta)
		cProduto := SB1->B1_COD
		lFound 	 := .T.
	EndIf

EndIf

If !lFound

	DBSelectArea("SB1")	// Cadastro de Produto
	DBSetOrder(1) 		// B1_FILIAL+B1_COD
	If DBSeek(xFilial("SB1")+cCodProd)
		cProduto := SB1->B1_COD
		lFound 	 := .T.
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Localizou Codigo de Etiqueta nas Tabelas PCO/SB1			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFound
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alimenta Array de Retorno do Ponto de Entrada							³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(Alltrim(cEtiqueta)) > Len(SB1->B1_COD)
    			
		If Alltrim(FunName()) $ "ACDV166|ACDV177" 
			DbSelectArea("SB8")                  
			DbSetOrder(3)
			
			If DbSeek(xFilial("SB8")+cProduto + CB8->CB8_LOCAL +cLote) 
    		
				//If !Empty(dDtValid) .And. dDtValid <> SB8->B8_DTVALID
				//	VtAlert("Validade nao confere","VALIDADE",.T.,4000)  
				//	cProduto := " "
				//	cLote    := " "
	    	    //EndIf 
			Else
				VtAlert("Lote nao encontrado","LOTE",.T.,4000)  
				cProduto := " "
				cLote    := " "
			EndIf 
		EndIf
		
		AAdd(aRet,cProduto)        //01-Codigo do produto
		AAdd(aRet,nQtde)           //02-Quantidade
		AAdd(aRet,cLote)           //03-Lote
		AAdd(aRet,dDtValid)        //04-Data de validade
		AAdd(aRet,Space(20))       //05-Numero de serie

	Else                                               

		AAdd(aRet,cProduto)        //01-Codigo do produto
		AAdd(aRet,nQtde)           //02-Quantidade
		AAdd(aRet,cLote)           //03-Lote
		AAdd(aRet,dDtValid)//04-Data de validade
		AAdd(aRet,Space(20))       //05-Numero de serie

	EndIf	
	
EndIf

RestArea(aAreaSB8)
RestArea(aAreaSB1)
RestArea(aArea)

Return(aRet)
