#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#include "rwmake.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "totvs.ch"
#include 'protheus.ch'
#include 'parmtype.ch'
#Include "ap5mail.ch"
#Include "RESTFUL.ch"
#INCLUDE "FILEIO.CH"

Static cArquivo :=  "Log_nao_incluso.txt"//"Log_nao_incluso.csv"
Static cTab := 'C:\TABELA_PRECO\'

/*/{Protheus.doc} chamlogs
//TODO Caixa de dialogo com usuario.
@author Fabio Batista
@since 03/06/2020
@version 1.0
@return ${return}, ${return_description} .T. 
@param 
@type function
/*/
User Function FTIMPCSV()

Private oDlg
Private dData   := CTOD("")
Private nResult := 0       
Private DDATAF  := CTOD("")

		// verifica existencia da pasta
		CriaPasta()
		
		DEFINE MSDIALOG oDlg FROM 0,0 TO 250,250 PIXEL TITLE "Inclusão de dados"
		@ 017,17 Say "Data de vigencia : "     of oDlg Pixel
		@ 016,72 MsGet dData Picture "@!" of oDlg Pixel
	
   		@ 090,028 BUTTON "Processar"   SIZE 28,13 PIXEL OF oDlg ACTION FTIMP002(oDlg)
		@ 090,073 BUTTON "Sair"   SIZE 28,13 PIXEL OF oDlg ACTION oDlg:End()
			

		ACTIVATE MSDIALOG oDlg CENTERED
Return

/*/{Protheus.doc} chamlogs
//TODO - Processamento de dados na função processa
@author Fabio Batista
@since 03/06/2020
@version 1.0
@return ${return}, ${return_description} .T. 
@param 
@type function
/*/
Static Function FTIMP002()

		If Empty(dData)
			Alert("A T E N Ç Ã O" + CRLF + CRLF + "O campo Data de vigencia está em branco deseja realmente continuar?", "DATA")
			oDlg:end()
			Return
		Else	
			Processa({|| FTIMP003()}, "Aguarde...", "Atualizando dados...")		
		EndIf

oDlg:end()
Return

/*/{Protheus.doc} FSIMPDA1
//TODO Descrição leitura do arquivo CSV.
@author Fabio Batista
@since 04/06/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static function FTIMP003()

    Local cLinha        := "" 
	Local aDados        := {}
	Local cGrava        := ""
	local  cMascara  	:= '*.csv'
	Local nMascpad      := 0
	local  cDirini   	:= "\"
	Local  lSalvar   	:= .T. //.T. = Salva || .F. = Abre
	Local  nOpcoes   	:= GETF_LOCALHARD
	Local  lArvore   	:= .T. //.T. = apresenta o árvore do servidor || .F. = não apresenta
	Local cProdY        := ''


	Private cLeARQ      := ''

	cLocalFile	        := cGetFile( cMascara, "Escolha o arquivo", nMascpad, cDirIni, lSalvar, nOpcoes, lArvore)
	ADIR(cLocalFile+ "*.csv",aDados)
	
	MV_PAR01 := cLocalFile//"C:\TABELA_ETHOSX\faethr11_20190630.csv"
	
	cLeARQ	 := SubStr(MV_PAR01,1,RAT("\",MV_PAR01))// CAMINHO DE ONDE PEGOU O ARQUIVO

	FT_FUSE(MV_PAR01)
	FT_FGOTOP()

	If cLocalFile == "" // caso colocar em cancelar na escolha do arquivo ele sai do programa
		Return
	EndIf

	ProcRegua(10000)
	While !FT_FEOF() 
	IncProc("Preparando arquivo...")

		cLinha := Upper(FT_FREADLN())

		aAdd(aDados,Separa(cLinha,";",.T.))

		FT_FSKIP()

	EndDo

	FT_FUSE()
	If !Len(aDados) > 1
		Alert("A T E N Ç Ã O" + CRLF + CRLF + "Não há dados a ser importado")
		Return
	EndIf

		FTIMP004(aDados)
	
Return

/*/{Protheus.doc} FSIMPDA1
//TODO Execauto.
@author Fabio Batista
@since 05/06/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function FTIMP004(aDados)

Local aCab       := {}
Local aItem      := {}
Local nOpc       := 3
Local cHoraDe    := "00:00"
Local cHoraAte   := "23:59"
Local cTpHorario := "1"
Local cTabAtiv   := "1"
Local aItens     :={}
Local nY         := 0
Local cProdX     := ''
Local cProdY     := ''
Local nMsg       := 0
Local nMsg1      := 0
Local nCont      := 0
Local aProdX     := {}
Local cDuplic    := ''
Local nErro      := 0
Local cMsg       := ''
Local _loop      := 0

Private aLinhaEr   := {}
Private aLinhaErro := {}
Private _aPed      := {} 
Private lMsErroAuto := .F.
Private lAutoErrNoFile 	:= .T.

	ADel(aDados,1)// tratamento para excluir primeira linha do array
	ASize( aDados,LEN(aDados)-1)// tratamento para excluir a linha em branco do array
	aSort(aDados, , , {|x, y| x[1] < y[1]}) 

	// Exclui os itens deletados DA1/DA0
	cDeclaracao := "DELETE " + RetSqlName("DA1") + " WHERE D_E_L_E_T_ = '*'"
	TCSqlExec(cDeclaracao)
	cDeclaracao := "DELETE " + RetSqlName("DA0") + " WHERE D_E_L_E_T_ = '*'"
	TCSqlExec(cDeclaracao)


	DBSELECTAREA("DA0")
	DA0->(DBSETORDER(1))
	DA0->(DBGOTOP())
	If DA0->(dbSeek(xFilial("DA0")+Padr(aDados[1][1],TamSX3("DA0_CODTAB")[1])))
		Alert("Já existe o codigo da tabela informado!")
		Return
	EndIf

	If !Select("SB1")>0
		dbselectarea("SB1")
	EndIf
	
	SB1->(DBSetOrder(1))
	
	//tratamento para pegar produtos não existe e bloqueados
	For nY := 1 TO LEN(aDados)
		SB1->(DBGoTop())
		If SB1->(dbSeek(xFilial("SB1")+Padr(aDados[nY][3],TamSX3("B1_COD")[1])))
			If SB1->B1_MSBLQL == '1'
				cProdX += "-------------------------------------------" + CRLF +;
					      "Produto bloqueado" + CRLF + CRLF +;
					      cValToChar(SB1->B1_COD) + CRLF
			EndIf
		Else
			cProdY += "-------------------------------------------" + CRLF +;
					  "Produto não existe" + CRLF + CRLF + aDados[nY][3] + CRLF
		EndIf 
	Next nY

    // tratamento para pegar itens duplicados
	For nCont := 1 to len(aDados)
		If aScan(aProdX,{|x| alltrim(x[1]) == alltrim(aDados[nCont][3])}) == 0
			aAdd(aProdX,{alltrim(aDados[nCont][3])})
		Else 
			cDuplic += "-------------------------------------------" + CRLF +;
						 "Produto duplicado" + CRLF + CRLF +; 
			            alltrim(aDados[nCont][3]) + CRLF //Alert("ok")
		EndIf
	Next nCont 

	If Empty(cProdX) .or. Empty(cProdY) .or. Empty(cDuplic)
		FSIMP005(cProdX,cProdY,cDuplic)
	Endif 

    aAdd(aCab, {"DA0_CODTAB" , alltrim(aDados[1][1]) , NIL})
    aAdd(aCab, {"DA0_DESCRI" , alltrim(aDados[1][2]) , NIL})
    aAdd(aCab, {"DA0_DATDE"  , dData        , NIL})
    aAdd(aCab, {"DA0_HORADE" , cHoraDe      , NIL})
	aAdd(aCab, {"DA0_HORATE" , cHoraAte     , NIL})
    aAdd(aCab, {"DA0_TPHORA" , cTpHorario   , NIL})
    aAdd(aCab, {"DA0_ATIVO"  , cTabAtiv     , NIL})


    ProcRegua(Len(aDados))
	For _loop := 1 To Len(aDados)
	    IncProc("Processando...")
		If VALTYPE(aDados[_loop,4]) <> "N"
			nPrcven := Val(aDados[_loop,4])
		EndIf 
		aAdd(aItem,{{"DA1_ITEM"  , StrZero(_loop,4)          , NIL},;
					{"DA1_CODPRO" ,  ALLTRIM(aDados[_loop,3]), NIL},;
					{"DA1_PRCVEN" , nPrcven                  , NIL},;
					{"DA1_TIPPRE" , ALLTRIM(aDados[_loop,5]) , NIL}})
    Next _loop
	
		Omsa010(aCab,aItem,nOpc)

    If lMsErroAuto
        DisarmTransaction()
        
		//TRATAMENTO PARA MENSAGEM DO EXECAUTO NO TXT 
		aErrPCAuto	:= GETAUTOGRLOG()
		cMsg	:= ""
		For nErro := 1 To Len(aErrPCAuto)
			cMsg += "-------------------------------" + CRLF + aErrPCAuto[nErro] + CRLF
		Next
		FSIMP005(cProdX,cProdY,cDuplic,cMsg)
    Else
        MSGINFO("Incluido com sucesso.")
    EndIf
Return(.T.)


/*/{Protheus.doc} chamlogs
//TODO Geração de arquivos do log com CSV.
@author Fabio
@since 05/06/2020
@version 1.0
@return ${return}, ${return_description} .T. 
@param 
@type function
/*/
Static function FSIMP005(cProdX,cProdY,cDuplic,cMsg)//FSIMP005(cMsgErro)

	Local nHandle 
	Local nBloco   := 999999
	Local nI       := 0
	Local cBuffer  := '' 
	Local nRet     := MakeDir(cLeARQ)
	lOCAL cMsgErro := ''
	Local lRet     := .F.
   
  if nRet != 0
    conout( "Não foi possível criar o diretório. Erro: " + cValToChar(FError()))
  endif

	If !Empty(cProdX) .or. !Empty(cProdY)  .or. !Empty(cDuplic)  .or. !Empty(cMsg)
		cMsgErro := cProdX + cProdY + cDuplic + cValtochar(cMsg)
		MakeDir(cLeARQ)
		nHandle := FCreate(cLeARQ+cArquivo)
		cBuffer += cMsgErro + CRLF
		FWrite(nHandle, cBuffer,nBloco )
		FClose(nHandle)
		Alert("A T E N Ç Ã O" + CRLF + CRLF + "O processo será interrompido!" + CRLF +;
		      "Foi gerado um Log do(s) resgistro(s) com os devidos problemas!","LOG ARQUIVO")
	EndIf
Return .T.

Static function CriaPasta()

	Local nRet := 0

	If !ExistDir(cTab)
		nRet := MakeDir(cTab)
		//Alert("A T E N Ç Ã O" + CRLF + CRLF + "Deverá ser criado a pasta no diretorio conforme abaixo." + CRLF +"C:\TABELA_PRECO\","Cria Pasta")
	EndIf
   
	If nRet != 0
		Alert( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
	EndIf

Return
