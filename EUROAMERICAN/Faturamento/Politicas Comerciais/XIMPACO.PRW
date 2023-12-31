#include "rwmake.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#define ENTER CHR(13) + CHR(10)


/*
| Fun玢o...: xCargaRHP()
| Autor....: Paulo Rogerio 
| Data.....: 21/10/2013
| Parametro: 
| Retorno..: 
| Descric鉶: Importa玢o do Saldo Inicial do RHP (Csv)
| Objetivo.: 
| Documenta玢o: 
|
| Data       Programador    Altera玢o
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


// - Vari醰el utilizada para evitar que os gatilho (SX7) sejam executados 
// pelo msExecAuto. IMPORTANTE: A express鉶: TYPE("lImportNF")=="U" deve
// ser adicionada no campo X7_CONDIC de cada gatilho.
lImportNF:= .T.           

If MakeDir(cPathArq) # 0
	If !MontaDir(cPathArq)
		Alert("N鉶 foi Possivel criar a Pasta CNAB, dentro do Roothpath.")
		Return
	EndIf
EndIf

aFilies := Directory(cPathArq+"\*.Csv")

IF Len(aFilies) == 0
	//Alert("N鉶 existem aquivos disponiveis para importa玢o na pasta \Prenota.")

	IF Aviso("Aten玢o","Deseja procurar o arquivo em outra pastas?",{"Sim","N鉶"},1,"A pasta \CNAB n鉶 possui arquivos Csv.") == 2
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

DEFINE MSDIALOG oDlg1 TITLE "Arquivos para Importa玢o" From 009,000 To 029,060

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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北硆dmake	 � xImporCsv � Autor � : Paulo Rogerio                        潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Rotina de importa玢o de arquivo texto, padr鉶 csv MSDOS,   潮�
北�          � utilizando o ponto e virgula (;) como separador.           潮�
北�          �                                                 			  潮�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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
	// L� os registros do arquivo texto.
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
			// Cria e alimenta variaveis de prefixo "IT", que s鉶 referentes ao D1.
			cNomeVar    := "IT_"+Alltrim(aCampos[nCont][1])
				
			IF Alltrim(aCampos[nCont][2]) == "C"
				&(cNomeVar) := PADR(aCampos[nCont][3], TamSX3(Alltrim(aCampos[nCont][1]))[1])

				&(aCampos[nCont][1]) := PADR(aCampos[nCont][3], TamSX3(Alltrim(aCampos[nCont][1]))[1])
			Else
				&(cNomeVar) := aCampos[nCont][3]

				&(aCampos[nCont][1]) := aCampos[nCont][3]
			Endif

			IF Alltrim(aCampos[nCont][1]) == "ACO_CODCLI"
				IF RTRIM(IT_ACO_CODCLI) $ '011929' 
					XPTO := 0
				ENDIF
			ENDIF
		Next nCont
		MsUnlock()
		
		// Ajusta os tamanhos das vari醰eis chaves.
		/*
        IT_D5_DOC    := Padr(IT_D5_DOC    , 09)
        IT_SERIE     := Padr(IT_SERIE     , 03) 
        IT_FORNECE   := Padr(IT_FORNECE   , 06) 
        IT_LOJA      := Padr(IT_LOJA   , 02) 
        IT_D5_PRODUTO:= Padr(IT_D5_PRODUTO, 15)
        IT_LOTECTL   := Padr(IT_LOTECTL, 10)
        IT_LOTEFOR   := Padr(IT_LOTEFOR, 12)
		*/
		
		// Posiciona os cadastros.
		//cMsg := xPosicCad()
		//IF ! Empty(cMsg)                           
		//	//aadd(aErro, {IT_NFISCAL, IT_SERIE, IT_FORNECE, IT_D5_PRODUTO, IT_LOTECTL} )  
		//Else      
		//	lUpdate := .T.
			
			//dbSelectArea("PAO")
			//dbSetOrder(1) // PAO_FILIAL+PAO_PRODUT+PAO_LOTCTL+PAO_LOTFOR+PAO_FORNEC+PAO_LOJA+PAO_STATUS
			//dbSeek(xFilial("PAO")+IT_D5_PRODUTO+IT_LOTECTL+IT_LOTEFOR+IT_FORNECE+IT_LOJA)   

			//IF Found()    
			    //cChave := xFilial("PAO")+IT_NFISCAL+IT_SERIE+IT_FORNECE+IT_LOJA+IT_D5_PRODUTO+IT_LOTECTL

				//IF lPergunta
				//	IF Aviso("ATEN敲O", "A chave: "+cChave+" j� existe. Deseja Atualiz�-la?", {"Sim", "N鉶"}, 2, "Custo de Fabrica玢o ja Cadastrado") == 2
				//	   lUpdate := .F.                                       
				//	Endif
					
				//   IF MsgYesNo("Deseja usar a mesma resposta para as pr髕imas ocorr阯cias?")
				//  		lPergunta := .F.
				//   Endif
				//Else
				//aadd(aDados, {IT_NFISCAL, IT_SERIE, IT_FORNECE, IT_LOJA, IT_D5_PRODUTO, IT_LOTECTL, IT_LOTEFOR, IT_DATAENTR, IT_D5_QUANT, IT_ORIGEM, .F.})
				//Endif 
			//Else  
			//	aadd(aDados, {IT_NFISCAL, IT_SERIE, IT_FORNECE, IT_LOJA, IT_D5_PRODUTO, IT_LOTECTL, IT_LOTEFOR, IT_DATAENTR, IT_D5_QUANT, IT_ORIGEM, .T.})
			//	aadd(aDados, {IT_NFISCAL, IT_SERIE, IT_FORNECE, IT_LOJA, IT_D5_PRODUTO, IT_LOTECTL, IT_LOTEFOR, IT_DATAENTR, IT_D5_QUANT, IT_ORIGEM, .T.})
			//Endif
		//Endif
		
		// Muda de registros.
		ft_fskip()
	Enddo   

    // FEcha o Arquivo texto processado.
	ft_fuse()                           
	        
	cTexto := ""
	IF Len(aErro) > 0 
		cTexto := "OS PRODUTOS ABAIXO N肙 EST肙 CADASTRADOS. O ARQUIVO N肙 SER� IMPORTADO!"+chr(13)+chr(13)

		For nCont := 1 to Len(aErro)
			cTexto += Alltrim(aErro[nCont][2]) + "" + Alltrim(aErro[nCont][3])+chr(13)
		Next  
		
		Alert(cTexto)
	Else
		// Efetua a Grava玢o dos Registros.
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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北硆dmake	 � xCsvGetRecno � Autor � : Paulo Rogerio                     潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Rotina respons醰el pela leitura e interpleta玢o dos        潮�
北�          � registros do arquivo Cvs.                                  潮�
北�          �                                                 			  潮�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function xCsvGetRecno(cBuffer, aCampos)
Local nCont := 0
Local nPosInic  := 0
Local nPosFinal := 0
Local cCampo := ""

cBuffer := ";" + cBuffer + ";"

For nCont := 1 to Len(aCampos)
	// Identifica as posi珲es iniciais e finais do compo no buffer.
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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北硆dmake	 � xPosicCad � Autor � : Paulo Rogerio                        潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Rotina respons醰el pelo posicionamento e valida玢o dos     潮�
北�          � principais cadastros envolvidos no processo.               潮�
北�          �                                                 			  潮�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function	xPosicCad()
Local cMsg := ""

dbSelectArea("ACO")
dbSetOrder(2)  // ACO_FILIAL, ACO_CODTAB, ACO_CONDPG, ACO_FORMPG, ACO_CODCLI, ACO_LOJA, ACO_CFAIXA, R_E_C_N_O_, D_E_L_E_T_
dbSeek(xFilial("ACO")+IT_ACO_CODTAB+ACO_CONDPG+ACO_FORMPG+ACO_CODCLI+ACO_LOJA+ACO_CFAIXA)
IF ! Found()
	cMsg += "Registro: "+IT_ACO_CODTAB+ACO_CONDPG+ACO_FORMPG+ACO_CODCLI+ACO_LOJA+ACO_CFAIXA+" n鉶 encontrado."+chr(13)
Endif
dbSetOrder(1)

IF ! Empty(cMsg)
	Return(cMsg)
Endif
Return(cMsg)


/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北硆dmake	 � xGravaNF � Autor � : Paulo Rogerio                         潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Rotina grava玢o da pr�-nota fiscal.                        潮�
北�          �                                                 			  潮�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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
*  OBJETIVO: Cria uma interface que permite ao usu醨io escolher um arquivo para      *
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

// Abre janela de sele玢o.
cFOpen := cGetFile(cTipos,OemToAnsi("Abrir Arquivo..."),0,cPath,.T.)

Return (cFoPen)
