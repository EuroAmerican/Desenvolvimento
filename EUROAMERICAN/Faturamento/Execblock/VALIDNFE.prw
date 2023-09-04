#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"

#define ENTER chr(13) + chr(10)

//Static Function ValidNFe()
User Function ValidNFe()

Local xNFeChave 	:= StrTran(Upper(oXML:_INFNFE:_ID:TEXT),"NFE","")
Local xCNPJEmit 	:= IIf( Type("oXML:_INFNFE:_EMIT:_CNPJ") != "U", RTrim(oXML:_INFNFE:_EMIT:_CNPJ:TEXT), RTrim(oXML:_INFNFE:_EMIT:_CPF:TEXT) )
Local xCNPJDest 	:= IIf( Type("oXML:_INFNFE:_DEST:_CNPJ") != "U", RTrim(oXML:_INFNFE:_DEST:_CNPJ:TEXT), RTrim(oXML:_INFNFE:_DEST:_CPF:TEXT) )
Local xNFiscal  	:= RTrim( oXML:_INFNFE:_IDE:_NNF:TEXT )
Local xSerie    	:= RTrim( oXML:_INFNFE:_IDE:_SERIE:TEXT )
Local xEmissao 	 	:= IIf( RTrim(oXML:_INFNFE:_VERSAO:TEXT) $ "3.10#4.00", StoD(StrTran(RTrim(Left(oXML:_INFNFE:_IDE:_DHEMI:TEXT,10)),"-","")), StoD(StrTran(RTrim(oXML:_INFNFE:_IDE:_DEMI:TEXT),"-","")))

Local xTotalNF  	:= Val(oXML:_INFNFE:_TOTAL:_ICMSTot:_VNF:TEXT)
Local xFreteNF  	:= Val(oXML:_INFNFE:_TOTAL:_ICMSTot:_VFRETE:TEXT)
Local xTotalPIS 	:= Val(oXML:_INFNFE:_TOTAL:_ICMSTot:_VPIS:TEXT)
Local xTotalCOF  	:= Val(oXML:_INFNFE:_TOTAL:_ICMSTot:_VCOFINS:TEXT)
Local xTotalIPI		:= Val(oXML:_INFNFE:_TOTAL:_ICMSTot:_VIPI:TEXT)
Local xTotalST		:= Val(oXML:_INFNFE:_TOTAL:_ICMSTot:_VST:TEXT)
Local xTotalICM		:= Val(oXML:_INFNFE:_TOTAL:_ICMSTot:_vICMS:TEXT)

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

Local cQry			:= ""

Local nPosTotal		:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})
Local nPosDesc		:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_VALDESC"})
Local nPosFrete		:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_VALFRE"})
Local nPosDespe		:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_DESPESA"})

Local nTotalNF  	:= 0
Local nDescNF  		:= 0
Local nFreteNF	  	:= 0
Local nDespNF 	 	:= 0

// Verifica se nota fiscal ?v?ida na SEFAZ
If lRet .And. !U_NFeGetChv(xNFeChave)

	MsgStop("Nao foi poss?el validar a nota fiscal junto a SEFAZ." + ENTER +;
			"Entre em contato com a equipe de informatica para continuar com o processo.", "Atenção")

	lRet := .F.

EndIf

// Verifica se nota fiscal ?para a filial ativa
If lRet .And. ( AllTrim(SM0->M0_CGC) != xCNPJDest )
	MsgStop( "Este arquivo n? pertence a esta Filial!", "Atenção" )
    lRet := .F.
EndIf

// Verifica se a nota fiscal digitada ?a mesma do arquivo XML
If lRet .And. ( Val(cNFiscal) != Val(xNFiscal) )
	MsgStop( "Este arquivo n? pertence a nota fiscal informada!", "Atenção" )
    lRet := .F.
EndIf

// Verifica se a serie digitada ?a mesma do arquivo XML
If lRet .And. ( RTrim(cSerie) != RTrim(xSerie) )
	MsgStop( "Este arquivo n? pertence a serie informada!", "Atenção" )
    lRet := .F.
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

// Processa aCols para validacoes diversas
If lRet

	For nX:=1 to len(aCols)

		If !( aCols[nX][Len(aHeader)+1] )

			// Acumula valores por item para posterior conferencia entre total da nf digitada x total nf xml
			nTotalNF += aCols[nX][nPosTotal]
			nDescNF  += aCols[nX][nPosDesc]
			nFreteNF += aCols[nX][nPosFrete]
			nDespNF  += aCols[nX][nPosDespe]

		EndIf

	Next nX

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
		If XmlNodeExist(oXML:_INFNFE:_TOTAL:_ICMSTOT, "_vIPIDevol")  //tratamento para devol. sem destaque do ipi
			If nVrIPI != Val(oXML:_INFNFE:_TOTAL:_ICMSTot:_VIPIDEVOL:TEXT)
				cMsg += "O valor do imposto IPI ( R$ " +  cValToChar( nVrIPI ) + " ) n? ?o mesmo do arquivo XML ( R$ " +  cValToChar( xTotalIPI ) + " )." + ENTER + ENTER
				lRet := .F.
			Else
				lRet := .T.
			EndIf
		Else
			cMsg += "O valor do imposto IPI ( R$ " +  cValToChar( nVrIPI ) + " ) n? ?o mesmo do arquivo XML ( R$ " +  cValToChar( xTotalIPI ) + " )." + ENTER + ENTER
	   		lRet := .F.
   		EndIf
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


If lRet

	// Verifica se o total informado ?o mesmo do arquivo XML
	 If ( xTotalNF != ( nTotalNF + nVrIPI + nVrST + nFreteNF + nDespNF - nDescNF  ) ) .And.  !AllTrim(cTipo) $ "I#P" //N? validar valor para Complemento de IPI e ICM
		MsgStop( "O valor total ( R$ " + cValToChar(nTotalNF + nVrIPI + nVrST + nFreteNF + nDespNF - nDescNF) + " )  nao ?o mesmo do arquivo XML ( R$ " + cValToChar( xTotalNF ) + " ).", "Atenção" )
    	lRet := .F.
	EndIf

EndIf

If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

Return( lRet )