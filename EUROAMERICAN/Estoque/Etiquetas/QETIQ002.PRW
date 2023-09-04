#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH" 

/*
{Protheus.doc} QETIQ002
Processa a função QETIQ002
@Author     FABIO BATISTA
@Since      29/05/2020
@Version    P12.25
@Project    Qualy
@Param		ETIQUETA KIT - ZEBRA
@Param		 
@Param		 
*/
User Function QETIQ002()        

Processa( {||QESTQ000() }, "Aguarde...", "Imprimindo etiquetas...",.F.)

Return 

/*
{Protheus.doc} QESTR009()
Emissão de ETIQUETA TEXTO LIVRE - ZEBRA
@Author     FABIO BATISTA
@Since      27/05/2020
@Version    P12.25
@Project    Qualy
@Param		 ETIQUETA GENERICA - ZEBRA
@Param		 cBody
@Param		 mv_par01/mv_par02
*/
Static function QESTQ000()

Local cPorta   := "LPT1"
Local cModelo  := "ZEBRA"
Local nX       := 0
Local _cLote   := ''
Local _cFab    := ''
Local _dVal    := ''
Local _cCodBar := ''
Local nX       := 0 
Local cAlias  := Alias()
Local aarea := GetArea()
Local _dFab := ctod("  /  /  ")
Local _cFab := ""
Local _cVal := ""
Local _dVal := ctod("  /  /  ")
Private cPerg := "QETIQ002" 

//alert(varinfo("aarea",aarea)) // pega as informações posicionada

	cPergunt()
	If ! Pergunte(cPerg, .T.)
		Return nil
	endif                       

	_cLote := SC2->C2_NUM 
    If !SELECT("SB1")>0
        DBSELECTAREA("SB1")
    EndIf
    SB1->(DBSETORDER(1))
    SB1->(DBGOTOP())

    If SB1->(dbSeek(xFilial("SB1")+SC2->C2_PRODUTO))  
       _cCodBar := SB1->B1_CODBAR
	   _dVal  := dDataBase + SB1->B1_PRVALID
    EndIf
    If Empty(_cCodBar)
        Alert("A impressão de etiqueta será abortada !" + CRLF + "Não foi encontrado o codigo de barra do produto( " + SC2->C2_PRODUTO + " )")
        Return    
    EndIf
/*
    If !SELECT("SD3")>0
        DBSELECTAREA("SD3")
    EndIf

    SD3->(DBSETORDER(1))
    SD3->(DBGOTOP())
*/
    //If SD3->(dbSeek(xFilial("SD3")+Alltrim(SC2->C2_NUM)+Alltrim(SC2->C2_ITEM)+Alltrim(SC2->C2_SEQUEN)))
       //_cLote := SD3->D3_LOTECTL
       //_dFab  := SD3->D3_EMISSAO
       //_dVal  := SD3->D3_DTVALID
    //Else
	
	
	
        //Alert("A impressão de etiqueta será abortada !" + CRLF + "Não foi encontrado (APONTAMENTO PARA ESTA OP: " + SC2->C2_NUM + ")")
      //  Return
    //EndIf

	If Empty(_dVal)
		Alert("A T E N Ç Ã O" + CRLF + CRLF + "Não será gerado a etiqueta!" + CRLF +;
		      "Favor preencher o campo: (" + "B1_PRVALID" + ") no cadastro de produtos" + CRLF + CRLF + ;
			  "Produto: (" + SC2->C2_PRODUTO + ")")  

	Else
		_cFab := Subs(DtoC(dDatabase),4,2) + "-20" + Subs(DtoC(dDatabase),7,2)
		_cVal := Subs(DtoC(_dVal),4,2) + "-20" + Subs(DtoC(_dVal),7,2)
		MSCBPRINTER(cModelo, cPorta,,10,.F.,,,,,,.F.,)
	
		ProcRegua(MV_PAR01)
		For nX:= 1 To MV_PAR01
			IncProc("Processando...")
			MSCBCHKSTATUS(.F.)
			MSCBBEGIN(1,6)             
			MSCBSAY(07,04 , Alltrim(_cLote)          , "N","0","40,40")   // LOTE
			MSCBSAY(28,2.5,"FAB. " + Alltrim(_cFab)  , "N","0","30,28")   // FABRICAÇÃO
			MSCBSAY(28,6.5,"VAL. " +_cVal   , "N","0","30,28")  // VALIDADE
			MSCBSAYBAR(07,10,_cCodBar,"N","MB04",04,.F.,.T.,.F.,,3)       // CODIGO BARRA    
			MSCBEND()       
		Next    
		MSCBCLOSEPRINTER()
		restarea(aarea)
	EndIf
Return


/*
{Protheus.doc} QESTR009()
Grupo de perguntas 
@Author     FABIO BATISTA
@Since      27/05/2020
@Version    P12.25
@Project    Qualy
@Param		 ETIQUETA GENERICA - ZEBRA
@Param		 cBody
@Param		 mv_par01/mv_par02
*/
Static function cPergunt()
	
	u_fsPutSx1(cPerg ,"01", "Quantidade de Etiq.?" ,'' ,'' ,"MV_C01"	,"N" , 10                      ,0 , ,"G"	,""	,""	,"","","mv_par01","","","","","","","","","","","","","","","","")
	
return

User Function fsPutSx1( cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
						cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
						cF3, cGrpSxg,cPyme,;
						cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
						cDef02,cDefSpa2,cDefEng2,;
						cDef03,cDefSpa3,cDefEng3,;
						cDef04,cDefSpa4,cDefEng4,;
						cDef05,cDefSpa5,cDefEng5,;
						aHelpPor,aHelpEng,aHelpSpa,cHelp)

	LOCAL aArea := GetArea()
	Local cKey
	Local lPort := .f.
	Local lSpa := .f.
	Local lIngl := .f.

	cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."

	cPyme    := Iif( cPyme           == Nil, " ", cPyme          )
	cF3      := Iif( cF3           == NIl, " ", cF3          )
	cGrpSxg := Iif( cGrpSxg     == Nil, " ", cGrpSxg     )
	cCnt01   := Iif( cCnt01          == Nil, "" , cCnt01      )
	cHelp      := Iif( cHelp          == Nil, "" , cHelp          )

	dbSelectArea( "SX1" )
	dbSetOrder( 1 )

// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes.
// RFC - 15/03/2007
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )

	If !( DbSeek( cGrupo + cOrdem ))

		cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa     := If(! "?" $ cPerSpa .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng     := If(! "?" $ cPerEng .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)

		Reclock( "SX1" , .T. )

		Replace X1_GRUPO   With cGrupo
		Replace X1_ORDEM   With cOrdem
		Replace X1_PERGUNT With cPergunt
		Replace X1_PERSPA With cPerSpa
		Replace X1_PERENG With cPerEng
		Replace X1_VARIAVL With cVar
		Replace X1_TIPO    With cTipo
		Replace X1_TAMANHO With nTamanho
		Replace X1_DECIMAL With nDecimal
		Replace X1_PRESEL With nPresel
		Replace X1_GSC     With cGSC
		Replace X1_VALID   With cValid

		Replace X1_VAR01   With cVar01

		Replace X1_F3      With cF3
		Replace X1_GRPSXG With cGrpSxg

		If Fieldpos("X1_PYME") > 0
			If cPyme != Nil
				Replace X1_PYME With cPyme
			Endif
		Endif

		Replace X1_CNT01   With cCnt01
		If cGSC == "C"               // Mult Escolha
			Replace X1_DEF01   With cDef01
			Replace X1_DEFSPA1 With cDefSpa1
			Replace X1_DEFENG1 With cDefEng1

			Replace X1_DEF02   With cDef02
			Replace X1_DEFSPA2 With cDefSpa2
			Replace X1_DEFENG2 With cDefEng2

			Replace X1_DEF03   With cDef03
			Replace X1_DEFSPA3 With cDefSpa3
			Replace X1_DEFENG3 With cDefEng3

			Replace X1_DEF04   With cDef04
			Replace X1_DEFSPA4 With cDefSpa4
			Replace X1_DEFENG4 With cDefEng4

			Replace X1_DEF05   With cDef05
			Replace X1_DEFSPA5 With cDefSpa5
			Replace X1_DEFENG5 With cDefEng5
		Endif

		Replace X1_HELP With cHelp

		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

		MsUnlock()
	Else

		cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa     := If(! "?" $ cPerSpa .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng     := If(! "?" $ cPerEng .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)
		If !(X1_GRUPO+X1_ORDEM+X1_PERGUNT+X1_VARIAVL+X1_TIPO == cGrupo+ cOrdem+cPergunt+SPACE(Len(X1_PERGUNT)-len(cPergunt))+cVar+cTipo)
			Reclock( "SX1" , .F. )
	
			Replace X1_GRUPO   With cGrupo
			Replace X1_ORDEM   With cOrdem
			Replace X1_PERGUNT With cPergunt
			Replace X1_PERSPA With cPerSpa
			Replace X1_PERENG With cPerEng
			Replace X1_VARIAVL With cVar
			Replace X1_TIPO    With cTipo
			Replace X1_TAMANHO With nTamanho
			Replace X1_DECIMAL With nDecimal
			Replace X1_PRESEL With nPresel
			Replace X1_GSC     With cGSC
			Replace X1_VALID   With cValid
	
			Replace X1_VAR01   With cVar01
	
			Replace X1_F3      With cF3
			Replace X1_GRPSXG With cGrpSxg
	
			If Fieldpos("X1_PYME") > 0
				If cPyme != Nil
					Replace X1_PYME With cPyme
				Endif
			Endif
	
			Replace X1_CNT01   With cCnt01
			If cGSC == "C"               // Mult Escolha
				Replace X1_DEF01   With cDef01
				Replace X1_DEFSPA1 With cDefSpa1
				Replace X1_DEFENG1 With cDefEng1
	
				Replace X1_DEF02   With cDef02
				Replace X1_DEFSPA2 With cDefSpa2
				Replace X1_DEFENG2 With cDefEng2
	
				Replace X1_DEF03   With cDef03
				Replace X1_DEFSPA3 With cDefSpa3
				Replace X1_DEFENG3 With cDefEng3
	
				Replace X1_DEF04   With cDef04
				Replace X1_DEFSPA4 With cDefSpa4
				Replace X1_DEFENG4 With cDefEng4
	
				Replace X1_DEF05   With cDef05
				Replace X1_DEFSPA5 With cDefSpa5
				Replace X1_DEFENG5 With cDefEng5
			Endif
	
			Replace X1_HELP With cHelp
	
			PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
	
			MsUnlock()
		endif
	Endif

	RestArea( aArea )

Return