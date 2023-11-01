#include "rwmake.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#define ENTER CHR(13) + CHR(10)


/*
| Função...: xCargaRHP()
| Autor....: Paulo Rogerio 
| Data.....: 21/10/2013
| Parametro: 
| Retorno..: 
| Descricão: Importação do Saldo Inicial do RHP (Csv)
| Objetivo.: 
| Documentação: 
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------                 
*/

User Function xCargaACO()
Local aArea := GetArea()
Local aCampos := {}
//Local cMsg    := "Aguarde ..."
//Local cMsgErr := ""
Local nCntFile := 0
Local cPathArq := "\Cnab"
Local aFilies := Directory(cPathArq+"\*.Csv")
Local oDlg1 
Local nOpcao := 0
Local cFileCsv := ""

Private aCabec   := {}
Private lInverte := .F.
Private cMarca   := GetMark(.F.)  // Trazer os itens na tela DESMARCADOS.
Private aCpoBro  := {}
Private cNomeTRB := ""
Private lImportNF


// - Variável utilizada para evitar que os gatilho (SX7) sejam executados 
// pelo msExecAuto. IMPORTANTE: A expressão: TYPE("lImportNF")=="U" deve
// ser adicionada no campo X7_CONDIC de cada gatilho.
lImportNF:= .T.           

If MakeDir(cPathArq) # 0
	If !MontaDir(cPathArq)
		Alert("Não foi Possivel criar a Pasta CNAB, dentro do Roothpath.")
		Return
	EndIf
EndIf

aFilies := Directory(cPathArq+"\*.Csv")

IF Len(aFilies) == 0
	//Alert("Não existem aquivos disponiveis para importação na pasta \Prenota.")

	IF Aviso("Atenção","Deseja procurar o arquivo em outra pastas?",{"Sim","Não"},1,"A pasta \CNAB não possui arquivos Csv.") == 2
		Return
	Else      
		cFileCsv :=	xGetFile("C:\")	
		
		IF Empty(cFileCsv)
			Return
		Endif     
		
		// Tira o nome do arquivo e usa apenas o path informado.
		cFileCsv := Strtran(cFileCsv, "\", "#")
		Do While .T.
			nPosic := AT("#", cFileCsv)
			IF nPosic == 0
				Exit
			Endif   
			
			nLastPos := nPosic
			cFileCsv := Left(cFileCsv,nPosic-1) +"\"+Subs(cFileCsv,nPosic+1)
		Enddo
		
		cPathArq := Subs(cFileCsv, 1, nLastPos)
		aFilies  := Directory(cPathArq+"*.Csv")
	Endif
Endif

If Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
Endif

aAdd(aCampos,{'OK'      ,'C',02,0})
aAdd(aCampos,{'ARQUIVO' ,'C',20,0})
aAdd(aCampos,{'PASTA'   ,'C',50,0})

cNomeTRB := CriaTrab(aCampos)
dbUseArea(.T.,,cNomeTRB,'TRB')

For nCntFile := 1 to Len(aFilies)
	RecLock("TRB",.T.)
	TRB->ARQUIVO := aFilies[nCntFile][1]
	TRB->PASTA   := cPathArq
	MsUnlock()
Next

dbSelectArea("TRB")
DbGotop()

aCpoBro  := {{"OK"      ,,"Ok"           ,"@!"},;
             {"ARQUIVO" ,,"Arquivo"      ,"@!"},;
             {"PASTA"   ,,"Pasta"        ,"@!"}}

DEFINE MSDIALOG oDlg1 TITLE "Arquivos para Importação" From 009,000 To 029,060

oMark := MsSelect():New("TRB","OK","",aCpoBro,@lInverte,@cMarca,{010,005,120,230})
oMark :bMark := {|| oMark:oBrowse:Refresh()}                     // Para Ativar Refresh

@ 130,175 BMPBUTTON TYPE 1 ACTION (nOpcao := 1 ,Close(ODlg1))
@ 130,205 BMPBUTTON TYPE 2 ACTION (nOpcao := 2, Close(ODlg1))

oDlg1:=GetWndDefault()
oDlg1:nStyle:=128

ACTIVATE MSDIALOG oDlg1 CENTERED

IF nOpcao == 1
	Processa({|| xImportCsv()})
Endif

dbSelectArea("TRB")
dbCloseArea()
Ferase(cNomeTRB+ GetDBExtension())
Ferase(cNomeTRB+OrdBagExt())

//dbSelectArea("PAO")
RestArea(aArea)
Return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³rdmake	 ³ xImporCsv ³ Autor ³ : Paulo Rogerio                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de importação de arquivo texto, padrão csv MSDOS,   ³±±
±±³          ³ utilizando o ponto e virgula (;) como separador.           ³±±
±±³          ³                                                 			  ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static function xImportCsv()
Local cArquivo:= "SldIniRhp.csv" //cGetFile()
Local cBuffer := ""
//Local cMsg    := ""
Local nCont   := 0
Local nTotReg := 0
Local aLayout := {}
Local aCampos := {}
Local aErro   := {}
Local aDados  := {}
Local lUpdate := .F.
Local lPergunta := .T.

// Define o layout do Arquivo 
aLayout := {{"ACO_FILIAL","C"," "," "},;
{"ACO_CODREG","C"," "," "},;
{"ACO_DESCRI","C"," "," "},;
{"ACO_CODCLI","C"," "," "},;
{"ACO_LOJA"  ,"C"," "," "},;
{"ACO_CODTAB","C"," "," "},;
{"ACO_CONDPG","C"," "," "},;
{"ACO_FORMPG","C"," "," "},;
{"ACO_FAIXA" ,"N"," "," "},;
{"ACO_MOEDA" ,"N"," "," "},;
{"ACO_PERDES","N"," "," "},;
{"ACO_CFAIXA","C"," "," "},;
{"ACO_TPHORA","C"," "," "},;
{"ACO_HORADE","C"," "," "},;
{"ACO_HORATE","C"," "," "},;
{"ACO_DATDE" ,"D"," "," "},;
{"ACO_DATATE","D"," "," "},;
{"ACO_GRPVEN","C"," "," "},;
{"ACO_DESCPR","L"," "," "},;
{"ACO_VLRDES","N"," "," "},;
{"ACO_MSBLQL","C"," "," "},;
{"ACO_XSCORE","N"," "," "},;
{"ACO_XMIX"  ,"N"," "," "},;
{"ACO_XDSCFI","N"," "," "}}


dbSelectArea("TRB")
dbGotop()
ProcRegua(35000)
Do While ! Eof()
	If ! Marked("OK")
		dbSkip()
		Loop
	Endif

	aErro  := {}
	aDados := {}
	

    cArquivo := Alltrim(TRB->PASTA)+"\"+Alltrim(TRB->ARQUIVO)
    
	// Abre o arquivo texto.
	ft_fuse(cArquivo)

	lUpdate := .F.
	lPergunta := .T.
	
	//************************************
	// Lê os registros do arquivo texto.
	//************************************
	While ! ft_feof()
		cBuffer := ft_freadln()
		
		aCampos := aClone(aLayout)
             
		nTotReg+=1
		
		INCPROC("Processando Registro: " + Strzero(nTotReg, 5))
		
		//Retira os campos do registro texto.
		aCampos := xCsvGetRecno(cBuffer, @aCampos)
		
		//==============================================
		// Cria e Alimenta Variaveis de Memoria.
		//==============================================
		Reclock("ACO", .T.)
		For nCont := 1 to Len(aCampos)
			// Cria e alimenta variaveis de prefixo "IT", que são referentes ao D1.
			cNomeVar    := "IT_"+Alltrim(aCampos[nCont][1])
				
			IF Alltrim(aCampos[nCont][2]) == "C"
				&(cNomeVar) := PADR(aCampos[nCont][3], TamSX3(Alltrim(aCampos[nCont][1]))[1])

				&(aCampos[nCont][1]) := PADR(aCampos[nCont][3], TamSX3(Alltrim(aCampos[nCont][1]))[1])
			Else
				&(cNomeVar) := aCampos[nCont][3]

				&(aCampos[nCont][1]) := aCampos[nCont][3]
			Endif

		Next nCont
		MsUnlock()
		
		// Muda de registros.
		ft_fskip()
	Enddo   

    // FEcha o Arquivo texto processado.
	ft_fuse()                           
	        
	cTexto := ""
	IF Len(aErro) > 0 
		cTexto := "OS PRODUTOS ABAIXO NÃO ESTÃO CADASTRADOS. O ARQUIVO NÃO SERÁ IMPORTADO!"+chr(13)+chr(13)

		For nCont := 1 to Len(aErro)
			cTexto += Alltrim(aErro[nCont][2]) + "" + Alltrim(aErro[nCont][3])+chr(13)
		Next  
		
		Alert(cTexto)
	Else
		// Efetua a Gravação dos Registros.
		//U_GrvSldRHP(aDados)

		MSGINFO( "Termino de Processamento", "Carga ACO" )
	Endif
	
	dbSelectArea("TRB")

	IF Empty(aErro) 
		//Renomeia o Arquivo processado.
	    fRename(cArquivo,Strtran(Upper(cArquivo),".CSV", ".#OK"))
	Endif
	 
	dbSkip()
Enddo

//Alert("Termino de Processamento!!!")

Return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³rdmake	 ³ xCsvGetRecno ³ Autor ³ : Paulo Rogerio                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina responsável pela leitura e interpletação dos        ³±±
±±³          ³ registros do arquivo Cvs.                                  ³±±
±±³          ³                                                 			  ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function xCsvGetRecno(cBuffer, aCampos)
Local nCont := 0
Local nPosInic  := 0
Local nPosFinal := 0
Local cCampo := ""

cBuffer := ";" + cBuffer + ";"

For nCont := 1 to Len(aCampos)
	// Identifica as posições iniciais e finais do compo no buffer.
	nPosInic  := AT(";",cBuffer)
	cBuffer   := Subs(cBuffer,nPosInic+1)
	nPosFinal := AT(";",cBuffer)
	
	// Pega o Campo e Comverte seu valor.
	cCampo := Alltrim(Subs(cBuffer,1, (nPosFinal-1)))
	
	Do Case
		Case aCampos[nCont][2] == "N"
			cCampo := Val(Strtran(cCampo,",","."))
			
		Case aCampos[nCont][2] == "D"
			cCampo := ctod(cCampo)
			
		Case aCampos[nCont][2] == "L"
			cCampo := iif(cCampo == "1", .T., .F.)
	Endcase
	
	aCampos[nCont][3] := cCampo
	
	// Tira o campo do Buffer.
	cBuffer := Subs(cBuffer, nPosFinal)
	
Next nCont
Return(aCampos)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³rdmake	 ³ xPosicCad ³ Autor ³ : Paulo Rogerio                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina responsável pelo posicionamento e validação dos     ³±±
±±³          ³ principais cadastros envolvidos no processo.               ³±±
±±³          ³                                                 			  ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function	xPosicCad()
Local cMsg := ""

dbSelectArea("ACO")
dbSetOrder(2)  // ACO_FILIAL, ACO_CODTAB, ACO_CONDPG, ACO_FORMPG, ACO_CODCLI, ACO_LOJA, ACO_CFAIXA, R_E_C_N_O_, D_E_L_E_T_
dbSeek(xFilial("ACO")+IT_ACO_CODTAB+ACO_CONDPG+ACO_FORMPG+ACO_CODCLI+ACO_LOJA+ACO_CFAIXA)
IF ! Found()
	cMsg += "Registro: "+IT_ACO_CODTAB+ACO_CONDPG+ACO_FORMPG+ACO_CODCLI+ACO_LOJA+ACO_CFAIXA+" não encontrado."+chr(13)
Endif
dbSetOrder(1)

IF ! Empty(cMsg)
	Return(cMsg)
Endif
Return(cMsg)


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³rdmake	 ³ xGravaNF ³ Autor ³ : Paulo Rogerio                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina gravação da pré-nota fiscal.                        ³±±
±±³          ³                                                 			  ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function	GrvSldRHP(aDados)
Local nCont := 0
Local dData := ""
Local cProd := ""
//Local nPrec := ""


For nCont := 1 to Len(aDados)
	IF Alltrim(UPPER(Funname())) == "XCARGARHP"
		INCPROC("Gravando...")
	Endif

	//IF !aDados[nCont][11]
	//	Loop
	//Endif   
	
	cDocu := aDados[nCont][01]
	cSeri := aDados[nCont][02]
	cForn := aDados[nCont][03]
	cLoja := aDados[nCont][04]
	cProd := aDados[nCont][05]
	cLotC := aDados[nCont][06]
	cLotF := aDados[nCont][07]
	dData := aDados[nCont][08]
	nSldo := aDados[nCont][09]
	cOrig := aDados[nCont][10]

	dbSelectArea("PAO")
	dbSetOrder(1) // PAO_FILIAL+PAO_DOC+PAO_SERIE+PAO_FORNEC+PAO_LOJA+PAO_PRODUT+PAO_LOTCTL+PAO_LOTFOR+PAO_STATUS
	dbSeek(xFilial("PAO")+cDocu+cSeri+cForn+cLoja+cProd+cLotC+cLotF+"A")   

	IF Found() 
		Reclock("PAO", .F.)
	    PAO_SLDINI += nSldo
	Else
		Reclock("PAO", .T.)
	    PAO_SLDINI := nSldo
	Endif                

	PAO_FILIAL := xFilial("PAO")
	PAO_PRODUT := cProd
	PAO_LOTCTL := cLotC
	PAO_LOTFOR := cLotF
	PAO_DOC    := cDocu
	PAO_SERIE  := cSeri
	PAO_FORNEC := cForn
	PAO_LOJA   := cLoja
	PAO_DATA   := dData
	PAO_ORIGEM := cOrig
	PAO_STATUS := "A"
	MsUnlock()
Next

Return(.T.)

/*
*=====================================================================================
* ROTINA ESCOLHA DE ARQUIVO VIA COMMOM DIALOG: xGetFile                              *
*=====================================================================================
* Chamada pela consulta XGTARQ do SXB.                                               *
*=====================================================================================
*  OBJETIVO: Cria uma interface que permite ao usuário escolher um arquivo para      *
*            processamento.                                                          *
*                                                                                    *
*=====================================================================================
*  Desenvolvido por:      * Data:                                                    *
*  Paulo Rogerio.         * 09/05/08                                                 *
*=====================================================================================
*/
Static Function xGetFile(cPath, cTipos)
Local cFOpen := ""

cTipos := IIF(cTipos == NIL, "Arquivos Csv (MS DOS)|*.Csv|Todos os Arquivos |*.*",cTipos)

// Abre janela de seleção.
cFOpen := cGetFile(cTipos,OemToAnsi("Abrir Arquivo..."),0,cPath,.T.)

Return (cFoPen)
