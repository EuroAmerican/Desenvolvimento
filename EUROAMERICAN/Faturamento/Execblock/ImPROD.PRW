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
//TODO Importação dados produto
@author Fabio Batista
@since 04/08/2020
@version 1.0
@return ${return}, ${return_description} .T. 
@param 
@type function
/*/
User Function ImProd()

//'0001069' = eristeu 
//If RetCodUsr() == '000000' .or. RetCodUsr() == '0001069' //GETMV("0001069#000000")

    If MsgNoYes("Essa rotina vai importar os campos Familia e Sub Familia do aquivo selecionado!" + CRLF + "Deseja realmente fazer a importação?" ,"ImProd")
        Processa({|| FTIMP003()}, "Aguarde...", "Atualizando dados...")	
    Else
        Return
    EndIf 
//Else
//	Alert("Esse processo não poderá ser executado!" +  CRLF + "Favor entrar em contato com administrador", 'ImProd')
//	Return
//EndIf

Return

Static function FTIMP003()

    Local cLinha        := "" 
	Local aDados        := {}
	
	local  cMascara  	:= '*.csv'
	Local nMascpad      := 0
	local  cDirini   	:= "\"
	Local  lSalvar   	:= .T. //.T. = Salva || .F. = Abre
	Local  nOpcoes   	:= GETF_LOCALHARD
	Local  lArvore   	:= .T. //.T. = apresenta o árvore do servidor || .F. = não apresenta
	
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

Local nY         := 0
Local cProdX     := ''
Local cProdY     := ''
Local aProdX     := {}
Local cDuplic    := ''
Local cMsg       := ''
Local cFamilia   := ''
Local lRet       := .F. 

	ADel(aDados,1)// tratamento para excluir primeira linha do array
	ASize( aDados,LEN(aDados)-1)// tratamento para excluir a linha em branco do array
	aSort(aDados, , , {|x, y| x[1] < y[1]}) 

    dbselectarea("ZZZ")
	ZZZ->(DBSetOrder(1))
	
    dbselectarea("ZZX")
	ZZX->(DBSetOrder(1))

	For nY := 1 TO LEN(aDados)
		ZZZ->(DBGoTop())
		If !ZZZ->(dbSeek(xFilial("ZZZ")+Padr(aDados[nY][3],TamSX3("ZZZ_COD")[1])))//verifica se existe codigo no cadastro
			 If Valtype(aDados[nY][3]) <> "C"
				cFamilia := val(aDados[nY][3])
			 Else 
			 	cFamilia := aDados[nY][3]
			 EndIf
			lRet := .T.
			Alert("O processo foi interrompido" + CRLF + "O codigo: " + cFamilia +;
			      " não existe no cadastro de Sub Família" + CRLF + "Favor incluir!" ,"ATENÇÃO" )
			Exit 
		EndIf
		
		ZZX->(DBGoTop())
		If !ZZX->(dbSeek(xFilial("ZZX")+Padr(aDados[nY][5],TamSX3("ZZX_CODIGO")[1])))//verifica se existe codigo no cadastro
			 If Valtype(aDados[nY][5]) <> "C"
				cSubFam := val(aDados[nY][5])
			 Else 
			 	cSubFam := aDados[nY][5]
			 EndIf
			lRet := .T.
			Alert("O processo foi interrompido" + CRLF + "O codigo: " + cSubFam +;
			      " não existe no cadastro de Sub Família" + CRLF + "Favor incluir!" ,"ATENÇÃO" )
			Exit 
		EndIf

		SB1->(DBGoTop())
		If SB1->(dbSeek(xFilial("SB1")+Padr(aDados[nY][1],TamSX3("B1_COD")[1])))
			If SB1->B1_MSBLQL == '1'
				cProdX += "-------------------------------------------" + CRLF +;
					      "Produto bloqueado" + CRLF + CRLF +;
                           cValToChar(SB1->B1_COD) + CRLF 
            ElseIf !Empty(SB1->B1_XFAMILI)
                 cProdX += "-------------------------------------------" + CRLF +;
					      "Produto com campo Família ou Sub Família Preenchido" + CRLF + CRLF +;
                          "Codigo Produto: " + cValToChar(SB1->B1_COD) + CRLF +;
                          "Familia: " + cValtochar(SB1->B1_XFAMILI) + CRLF
            ElseIf !Empty(SB1->B1_XSUBFAM)
                cProdX += "-------------------------------------------" + CRLF +;
					      "Produto com campo Família ou Sub Família Preenchido" + CRLF + CRLF +;
                           "Codigo do Produto: " + cValToChar(SB1->B1_COD) + CRLF +;
                           "Sub Familia: " + cValtochar(SB1->B1_XSUBFAM) + CRLF
            Else
                    If Valtype(aDados[nY][3]) <> "C"
						RecLock("SB1", .F.)
                        SB1->B1_XFAMILI := cValtochar(aDados[nY][3])
                        SB1->B1_XDESCFA := cValtochar(aDados[nY][4])   
						MsUnLock()
                    Else 
						RecLock("SB1", .F.)
                        SB1->B1_XFAMILI := aDados[nY][3]
                        SB1->B1_XDESCFA := aDados[nY][4]   
						MsUnLock()
					EndIf
                    
                    If Valtype(aDados[nY][3]) <> "C"
                       RecLock("SB1", .F.)
					   SB1->B1_XSUBFAM := cValtochar(aDados[nY][5])
                       SB1->B1_XDESCSU := cValtochar(aDados[nY][6])
					   MsUnLock()	
					Else
						RecLock("SB1", .F.)
                        SB1->B1_XSUBFAM := aDados[nY][5]
                        SB1->B1_XDESCSU := aDados[nY][6]
						MsUnLock()
                    EndIf     	      
			EndIf
		Else
			cProdY += "-------------------------------------------" + CRLF +;
					  "Produto não existe " + CRLF + CRLF + "Código Produto: " + cValtochar(aDados[nY][1]) + CRLF
		EndIf 
	Next nY
	
	SB1->(DBCloseArea())
	ZZZ->(DBCloseArea())
	ZZX->(DBCloseArea())

   If !lRet
		If !Empty(cProdX) .or. !Empty(cProdY) .or. !Empty(cDuplic) .or. !Empty(cMsg)  
			FSIMP005(cProdX,cProdY,cDuplic,cMsg)
		Else
			MSGINFO("Incluido com sucesso.")    
		EndIf    
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
		cMsgErro := cProdX + cProdY + cDuplic + cValtochar(cMsg) + CRLF
		MakeDir(cLeARQ)
		nHandle := FCreate(cLeARQ+cArquivo)
		cBuffer += cMsgErro + CRLF
		FWrite(nHandle, cBuffer,nBloco )
		FClose(nHandle)
		Alert("A T E N Ç Ã O" + CRLF + CRLF + "O processo gerou log!" + CRLF + "(" + cLeARQ + ")","LOG ARQUIVO")
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
