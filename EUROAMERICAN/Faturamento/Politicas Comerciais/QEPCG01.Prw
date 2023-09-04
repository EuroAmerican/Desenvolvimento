#include "rwmake.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#define ENTER CHR(13) + CHR(10)

/*
| Função...: QEPCG01()
| Autor....: Paulo Rogerio
| Data.....: 14/06/2023
| Retorno..: Nenhum
| Descricão: Funçoes para Gatilho para Calculo e Aplicação de Descontos na rotina MATA415.
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User Function QEPCG01()
Local aArea     := GetArea()
Local aAreaSA1  := SA1->(GetArea())
Local aAreaACY  := ACY->(GetArea())
Local cPeriodo  := 0

Private lEnchoi := IIF(ValType(M->CJ_CLIENTE) == "C", .T., .F.)
Private dEmissao:= ctod('')
Private cCondPag:= ""

IF !U_xFilPComl()
    Return(.T.)
Endif

cPeriodo := IIF(lEnchoi, Year(M->CJ_EMISSAO), Year(SCJ->CJ_EMISSAO))

IF cPeriodo < 100
    cPeriodo := Alltrim(str(2000 + cPeriodo)) 
Else
    cPeriodo := Alltrim(str(cPeriodo)) 
Endif

dbSelectArea("SA1")
dbSetOrder(1)
IF lEnchoi
    dbSeek(xFilial("SA1")+M->CJ_CLIENTE + M->CJ_LOJA)

    dEmissao := M->CJ_EMISSAO
    cCondPag := M->CJ_CONDPAG
Else
    dbSeek(xFilial("SA1")+SCJ->CJ_CLIENTE + SCJ->CJ_LOJA)

    dEmissao := SCJ->CJ_EMISSAO    
    cCondPag := SCJ->CJ_CONDPAG
Endif

IF Found()
    if lEnchoi
        M->CJ_XDESSCO  := U_DefPerScor(cPeriodo) // 
        M->CJ_XDESFIN  := U_DefPerFina(cPeriodo) // 
        //M->CJ_XDESLOG  := U_DefPerLogi(cPeriodo) // Carga Automática Retira em 01.09.2023 p/ solicitação do Eristeu.

        // Atualiza o campo de Total de Desconto
        M->CJ_DESC1   := M->CJ_XDESSCO + M->CJ_XDESFIN + M->CJ_XDESLOG +  M->CJ_XDESMIX + M->CJ_XDESCF

        // Aplica os descontos de cabecalho e de item
        U_xCalcDesc()    
    Else
        SCJ->CJ_XDESSCO  := U_DefPerScor(cPeriodo)
        SCJ->CJ_XDESFIN  := U_DefPerFina(cPeriodo)
        //SCJ->CJ_XDESLOG  := U_DefPerLogi(cPeriodo) // Carga Automática Retira em 01.09.2023 p/ solicitação do Eristeu.

        // Atualiza o campo de Total de Desconto
        SCJ->CJ_DESC1   := SCJ->CJ_XDESSCO + SCJ->CJ_XDESFIN + SCJ->CJ_XDESLOG +  SCJ->CJ_XDESMIX + SCJ->CJ_XDESCF 

        // Aplica os descontos de cabecalho e de item
        U_xCalcDesc("SCK")    
    Endif
Endif

RestArea(aArea)
RestArea(aAreaSA1)
RestArea(aAreaACY)
Return(.T.)


/*
| Função...: xCalcDesc()
| Autor....: Paulo Rogerio
| Data.....: 19/06/2023
| Retorno..: Nenhum
| Descricão: Gatilho para Atualizar o Desconto nos Itens
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User Function  xCalcDesc(cAlias, lUpdDlg)
Local aArea		:= GetArea()
Local aAreaTmp1 := IIF(cAlias == "SCK", SCK->(GetArea()), TMP1->(GetArea()))
Local oDlg

Local nX        := 0
Local lRet 		:= .T.
Local nPrcLst   := 0
Local nPrcVen   := 0

Local nPerDesc  := 0
Local nPerAdic  := 0
Local nPerTota  := 0

Local nOrcTotVnd := 0
Local nOrcTotDes := 0
Local nOrcResult := 0

Local nMoeda    := IIF(Valtype(M->CJ_MOEDA) <> "N", SCJ->CJ_MOEDA, M->CJ_MOEDA)
Local nDesc1    := IIF(Valtype(M->CJ_DESC1) <> "N", SCJ->CJ_DESC1, M->CJ_DESC1)
Local nDesAdc   := 0
 
DEFAULT lTodos	:= .T.
DEFAULT lRecal  := .T.
DEFAULT lRecItens  := .F.
DEFAULT cAlias  := "TMP1"
DEFAULT lUpdDlg := .T.

IF ! U_xFilPComl()
    Return(.T.)
Endif 

dbSelectArea(cAlias)
If ( lTodos )
    IF Alias() == "TMP1"
	    dbGotop()
        cCondicao := "( !Eof() )"
    Else
        dbSetOrder(1)
        dbSeek(xFilial("SCK")+SCJ->CJ_NUM)

        cCondicao := "!Eof() .And. SCK->CK_FILIAL + SCK->CK_NUM == SCJ->CJ_FILIAL + SCJ->CJ_NUM"
        cAlias  := "SCK"
        lLock   := .T.
    Endif
EndIf

Do While &(cCondicao) //( !Eof() )
	If ( (cAlias)->CK_PRUNIT > 0 )
		nPrcLst  := (cAlias)->CK_PRUNIT //fPrcDesc((cAlias)->CK_PRUNIT)
        nDesAdc  := IIF(Empty((cAlias)->CK_XDESADC), 0, (cAlias)->CK_XDESADC)

        nPerDesc := Round(nDesc1/100 , 3)
        nPerAdic := Round(nDesAdc/100, 3)
        nPerTota := nPerDesc + nPerAdic

        nTotDesc := A410Arred((nPrcLst  *  (cAlias)->CK_QTDVEN) * nPerTota,"D2_TOTAL",nMoeda)
        nPrcVen  := A410Arred(nPrcLst * (1-nPerTota),"D2_TOTAL",nMoeda)
        
        IF cAlias == "SCK"
            Reclock("SCK", .F.)
        Endif

        (cAlias)->CK_PRCVEN := nPrcVen
        (cAlias)->CK_VALOR  := A410Arred(nPrcVen  *  (cAlias)->CK_QTDVEN, "CK_VALOR")
        (cAlias)->CK_DESCONT:= A410Arred(nDesc1,  "CK_DESCONT")
        (cAlias)->CK_VALDESC:= A410Arred(nTotDesc,  "CK_VALDESC")

        IF cAlias == "SCK"
            MsUnlock()
        Endif

        nOrcTotVnd += A410Arred(nPrcLst  * (cAlias)->CK_QTDVEN,"CK_VALOR")
        nOrcResult += (cAlias)->CK_VALOR
        nOrcTotDes := nOrcTotVnd - nOrcResult 
	EndIf

	If ( lTodos )
		dbSelectArea(cAlias)
		dbSkip()
	Else
		Exit
	EndIf
EndDo

IF lUpdDlg
    oDlg := GetWndDefault()

    aControl := oDlg:aControls

    If lRecal
        For nX := 1 To Len(aControl)
            If ValType(aControl[nX]) <> "U" .AND. ValType(aControl[nX]:Cargo)=="C"
                Do Case
                    Case ( aControl[nX]:Cargo $ "Total" )
                        aControl[nX]:SetText(nOrcResult)
                        oDlg:aControls[nX]:ReFresh()

                    Case ( aControl[nX]:Cargo $ "Desconto" )
                        aControl[nX]:SetText(nOrcTotDes)
                        oDlg:aControls[nX]:ReFresh()

                    Case ( aControl[nX]:Cargo $ "Valor" )
                        aControl[nX]:SetText(nOrcTotVnd)
                        oDlg:aControls[nX]:ReFresh()
                EndCase
            EndIf
        Next
    Endif
Endif

RestArea(aAreaTmp1)
RestArea(aArea)
Return(lRet)
 
/*
| Função...: fPrcDesc()
| Autor....: Paulo Rogerio
| Data.....: 19/06/2023
| Retorno..: Nenhum
| Descricão: Função para Calcular  o Preço Lista com Desconto
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
Static Function fPrcDesc(nPrcLista)
Local lDialog := IIF(Valtype(M->CJ_DESC1) <> "U", .T., .F.)

IF lDialog
    nPrcLista := FtDescCab(nPrcLista,{M->CJ_DESC1,M->CJ_DESC2,M->CJ_DESC3,M->CJ_DESC4}) // // FtDescCab(nPrcLista,{M->CJ_DESC1,M->CJ_DESC2,M->CJ_DESC3,M->CJ_DESC4})
Else
    nPrcLista := FtDescCab(nPrcLista,{SCJ->CJ_DESC1,SCJ->CJ_DESC2,SCJ->CJ_DESC3,SCJ->CJ_DESC4}) 
Endif
 
Return(nPrcLista)



/*
| Função...: fUpdTotDesc()
| Autor....: Paulo Rogerio
| Data.....: 19/06/2023
| Retorno..: Nenhum
| Descricão: Função para atualizar total do Desconto
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
Static Function fUpdTotDesc(oDlg)

Local aArea   	:= GetArea()
Local aAreaTmp1	:= TMP1->(GetArea())
Local nTotVal 	:= 0
Local nTotDesc	:= 0
Local nPerDesc  := M->CJ_DESC4
Local nX  := 0
Local aControl
Local cBonusTS	:= SuperGetMv("MV_BONUSTS", .F., "")


//l415Auto := If(Type("l415Auto")<>"U",l415Auto,.F.)
//l416Auto := If(Type("l416Auto")<>"U",l416Auto,.F.)

//If !(l415Auto) .and. !(l416Auto)
	aControl := oDlg:aControls
//EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Soma o os valores e os descontos, mostrando-os na tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TMP1")
dbGotop()
While ( !Eof() )
	If ( !TMP1->CK_FLAG ) .Or. ( TMP1->CK_FLAG .And. TMP1->CK_TES $ AllTrim(cBonusTS))
		nTotVal  += TMP1->CK_VALOR
		If (TMP1->CK_PRUNIT > TMP1->CK_PRCVEN)
			nTotDesc += A410Arred((TMP1->CK_PRUNIT * TMP1->CK_QTDVEN),"CK_VALOR") - A410Arred((TMP1->CK_PRCVEN * TMP1->CK_QTDVEN),"CK_VALOR")
		Else
			nTotDesc += TMP1->CK_VALDESC
		EndIf
	EndIf

	dbSelectArea("TMP1")
	dbSkip()
EndDo

nTotDesc += M->CJ_DESCONT
nTotVal  -= M->CJ_DESCONT

nTotDesc += A410Arred(nTotVal*M->CJ_PDESCAB/100,"C6_VALOR")
nTotVal  -= A410Arred(nTotVal*M->CJ_PDESCAB/100,"C6_VALOR")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula o Desconto por Total                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTotVal > 0 .And. FtRegraDesc(4,nTotVal+nTotDesc,@M->CJ_DESC4) <> nPerDesc
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Soma o os valores e os descontos, mostrando-os na tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotVal := 0
	nTotDesc:= 0

	dbSelectArea("TMP1")
	dbGotop()
	While ( !Eof() )
		If ( !TMP1->CK_FLAG )
			nTotVal  += TMP1->CK_VALOR

			If (TMP1->CK_PRUNIT > TMP1->CK_PRCVEN)
				nTotDesc += A410Arred((TMP1->CK_PRUNIT * TMP1->CK_QTDVEN),"CK_VALOR") - A410Arred((TMP1->CK_PRCVEN * TMP1->CK_QTDVEN),"CK_VALOR")
			Else
				nTotDesc += TMP1->CK_VALDESC
			EndIf
		EndIf

		dbSelectArea("TMP1")
		dbSkip()
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Soma as variaveis da Enchoice                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotVal += M->CJ_FRETE
nTotVal += M->CJ_SEGURO
nTotVal += M->CJ_DESPESA
nTotVal += M->CJ_FRETAUT

If cPaisLoc $ "CHI|PAR" .And. M->CJ_MOEDA == 1
	nTotVal   := A410Arred(nTotVal ,"CK_VALOR",M->CJ_MOEDA)
	nTotDesc  := A410Arred(nTotDesc,"CK_VALOR",M->CJ_MOEDA)	
EndIf

//If !( l415Auto .or. l416Auto)
	For nX := 1 To Len(aControl)
		If ValType(aControl[nX]) <> "U" .AND. ValType(aControl[nX]:Cargo)=="C"
			Do Case
			Case ( aControl[nX]:Cargo $ "Total" )
				aControl[nX]:SetText(IIf(cPaisLoc $ "CHI|PAR" .And. M->CJ_MOEDA > 1,Transform(nTotVal,PesqPict("SCK","CK_VALOR",,M->CJ_MOEDA)),nTotVal))
			Case ( aControl[nX]:Cargo $ "Desconto" )
				aControl[nX]:SetText(IIf(cPaisLoc $ "CHI|PAR" .And. M->CJ_MOEDA > 1,Transform(nTotDesc,PesqPict("SCK","CK_VALOR",,M->CJ_MOEDA)),nTotDesc))
			Case ( aControl[nX]:Cargo $ "Valor" )
				aControl[nX]:SetText(IIf(cPaisLoc $ "CHI|PAR" .And. M->CJ_MOEDA > 1,Transform(nTotVal+nTotDesc,PesqPict("SCK","CK_VALOR",,M->CJ_MOEDA)),nTotVal+nTotDesc))
			EndCase
		EndIf
	Next nX
//EndIf

RestArea(aAreaTmp1)
RestArea(aArea)
Return(Nil)


/*
| Função...: xFilPComl()
| Autor....: Paulo Rogerio
| Data.....: 19/06/2023
| Retorno..: Nenhum
| Descricão: Validação da Filial para aplicação da Politica Conercial
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User Function  xFilPComl()
lRet := Left(cFilAnt, 2) $ "08/09" 
Return(lRet)


/*
| Função...: xUpdDsAdc()
| Autor....: Paulo Rogerio
| Data.....: 19/06/2023
| Retorno..: Nenhum
| Descricão: Função para atualizar total do Desconto
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User Function xUpdDsAdc()
Local aArea   	:= GetArea()
Local aAreaTmp1	:= TMP1->(GetArea())
Local nDescAdic := IIF(Valtype(M->CJ_NUM) == "U", SCJ->CJ_XDESADC, M->CJ_XDESADC)
Local lDialog   := IIF(Valtype(M->CJ_XDESADC) <> "U", .T., .F.)
Local nOpcao    := 0

IF !U_xFilPComl()
    Return(.T.)
Endif

IF !lDialog 
    Return(.T.)
Endif

IF ! "CJ_XDESADC" $ UPPER(READVAR())
    Return(.T.)
Endif

IF lDialog
    nOpcao := Aviso("Atencao", "Deseja replicar o percentual do Desconto Adicional para todos os itens do orçamento?", {"Sim", "Não"}, 2)
Endif

DbSelectArea("TMP1")
dbGoTop()
	
Do While TMP1->(!EOF()) .And. nOpcao == 1
    IF TMP1->CK_XORGDES <> "D" //.OR. nDescAdic < TMP1->CK_XDESADC
        Reclock("TMP1", .F.)
        TMP1->CK_XDESADC := nDescAdic
        MsUnlock()
    Endif

    dbSkip()
Enddo

 // Aplica os descontos de cabecalho e de item
U_xCalcDesc("TMP1")

RestArea(aAreaTmp1)

If Type("oGetDad") <> "U"
	oGetDad:oBrowse:Refresh()
Endif

RestArea(aAreaTmp1)
RestArea(aArea)
Return(.T.)

/*
| Função...: xGetGrpCli()
| Autor....: Paulo Rogerio
| Data.....: 14/08/2023
| Retorno..: Nenhum
| Descricão: Função para Retornar o Código da Holding
|
| Observac.: 
| Objetivo.: 
| Documentação: Projeto de Politicas Comerciais - QUALY
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/
User Function xGetGrpCli(cCliente, cLoja)
Local aArea := SA1->(GetArea())
Local cRet := ""

dbSelectArea("SA1")    
dbSetOrder(1)    
dbSeek(xFilial("SA1")+cCliente+cLoja)

IF !Empty(A1_GRPVEN)
    cRet := A1_GRPVEN
Else
    cRet := A1_COD+"XX"
Endif

RestArea(aArea)
Return(cRet)
