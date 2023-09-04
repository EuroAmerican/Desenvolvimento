#include "rwmake.ch"
#include "topconn.ch"        
#include "tbiconn.ch"   
#include "protheus.ch"  
#include "tryexception.ch"

#define ENTER chr(13) + chr(10)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINM013   ºAutor  ³Alexandre Marson    º Data ³27/02/2015   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Importa planilha com previsoes de pagamentos conforme      º±±
±±º          ³ modelo EXCEL                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                     A L T E R A C O E S                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ºProgramador       ºAlteracoes                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
User Function FINM013()  
Local aArea			:= GetArea()

Local aParBox		:= {}      
Local aParRet		:= {}  
Local aParReg		:= {}       
  
Local oError		:= Nil         

Private cCadastro	:= "FINM013 - IMPORTAR PREVISOES DE PAGAMENTOS"        
Private cTemp		:= GetTempPath() //pega caminho do temp do client
Private cSystem		:= Upper(GetSrvProfString("STARTPATH","")) //Pega o caminho do sistema

aAdd( aParBox, Array(10) )
aParBox[Len(aParBox)][01]	:= 6													//[01] : 6 - FILE
aParBox[Len(aParBox)][02]	:= "Planilha Excel"      	   							//[02] : Descricao
aParBox[Len(aParBox)][03]	:= Space(50)                  							//[03] : String contendo o inicializador do campo
aParBox[Len(aParBox)][04]	:= ""													//[04] : String contendo a Picture do campo
aParBox[Len(aParBox)][05]	:= ""													//[05] : String contendo a validacao
aParBox[Len(aParBox)][06]	:= ""													//[06] : String contendo a validacao When
aParBox[Len(aParBox)][07]	:= 50													//[07] : Tamanho do MsGet
aParBox[Len(aParBox)][08]	:= .T.													//[08] : Flag .T./.F. Parametro Obrigatorio ?
aParBox[Len(aParBox)][09]	:= "Excel 97/2003 .XLS | *.XLS | Excel .XLSX | *.XLSX |"		//[09] : Texto contendo os tipos de arquivo, exemplo: "Arquivos .CSV |*.CSV"
aParBox[Len(aParBox)][10]	:= ""													//[10] : Diretorio inicial do cGetFile

If ParamBox( aParBox, cCadastro , @aParRet , , , , , , , .F. , .F. , .F. )
	Processa( {|| XLS2CSV( Trim(aParRet[1]) )}, "Processando..." )
EndIf


Return (NIl)


*-------------------------*
Static Function XLS2CSV(cArqXLS)
*-------------------------*
Local oExcelApp       
Local cExtensao		:= Trim(SubStr(cArqXLS,Rat(".",cArqXLS),Len(cArqXLS)+1-Rat(".",cArqXLS)))
Local cArquivo		:= U_NewAlias()                       
Local cArqMacro		:= "XLS2DBF.XLA"

If !File(cArqXLS)
	MsgInfo("O arquivo "+cArqXLS+" não foi encontrado!" ,"Arquivo")      
	Return(.F.)
EndIf
     
//verifica se existe o arquivo na pasta temporaria e apaga
If File(cTemp+cArquivo+cExtensao)
	fErase(cTemp+cArquivo+cExtensao)
EndIf                 
   
//Copia o arquivo XLS para o Temporario para ser executado
If !AvCpyFile(cArqXLS,cTemp+cArquivo+cExtensao,.F.) 
	MsgInfo("Problemas na copia do arquivo "+cArqXLS+" para "+cTemp+cArquivo+cExtensao ,"AvCpyFile()")
	Return(.F.)
EndIf                                       
   
//apaga macro da pasta temporária se existir
If File(cTemp+cArqMacro)
	fErase(cTemp+cArqMacro)
EndIf

//Copia o arquivo XLA para o Temporario para ser executado
If !AvCpyFile(cSystem+cArqMacro,cTemp+cArqMacro,.F.) 
	MsgInfo("Problemas na copia do arquivo "+cSystem+cArqMacro+"para"+cTemp+cArqMacro ,"AvCpyFile()")
	Return(.F.)
EndIf
     
//Inicializa o objeto para executar a macro
oExcelApp := MsExcel():New()             

//define qual o caminho da macro a ser executada
oExcelApp:WorkBooks:Open(cTemp+cArqMacro)       

//executa a macro passando como parametro da macro o caminho e o nome do excel corrente
oExcelApp:Run(cArqMacro+'!XLS2DBF',cTemp,cArquivo)

//fecha a macro sem salvar
oExcelApp:WorkBooks:Close()

//sai do arquivo e destrói o objeto
oExcelApp:Quit()
oExcelApp:Destroy()

//Exclui o Arquivo excel da temp
fErase(cTemp+cArquivo+cExtensao)
                           
//Exclui a Macro excel da temp
fErase(cTemp+cArqMacro)     

//Processa CSV para SQL
Return CSV2SQL(cArquivo)

Return(.T.)


*-------------------------*
Static Function CSV2SQL(cArqCSV)
*-------------------------*
Local cLinha	:= ""
Local nLin		:= 1 
Local nLinTit	:= 1
Local nTotLin	:= 0
Local aDados	:= {}
Local cFile		:= cTemp + cArqCSV + ".csv"
Local nHandle	:= 0            
Local dVencto	:= Ctod("")
Local nValor	:= 0

//abre o arquivo csv gerado na temp
nHandle := Ft_Fuse(cFile)
If nHandle == -1
   Return(.F.)
EndIf

Ft_FGoTop()                                                         

nLinTot := FT_FLastRec()-1

ProcRegua(nLinTot)

//Pula as linhas de cabeçalho
While nLinTit > 0 .AND. !Ft_FEof()
   Ft_FSkip()
   nLinTit--
EndDo

//Processamento
Do While !Ft_FEof()

   //exibe a linha a ser lida
   IncProc("Processando registro "+AllTrim(Str(nLin))+" de "+AllTrim(Str(nLinTot)))
               
   //atualiza controlador
   nLin++

   //le a linha
   cLinha := Ft_FReadLn()

   //verifica se a linha está em branco, se estiver pula
   If Empty(AllTrim(StrTran(cLinha,';','')))
      Ft_FSkip()
      Loop
   EndIf

   //transforma as aspas duplas em aspas simples
   cLinha := StrTran(cLinha,'"',"'")
   cLinha := '{"'+cLinha+'"}' 

   //adiciona o cLinha no array trocando o delimitador ; por , para ser reconhecido como elementos de um array 
   cLinha := StrTran(cLinha,';','","')
   aAdd(aDados, &cLinha)
   
   //passa para a próxima linha
   FT_FSkip()
  
EndDo

//libera o arquivo CSV
FT_FUse()             

//Exclui o arquivo csv
If File(cFile)
   FErase(cFile)
EndIf     

//processa array
If Len(aDados) > 0

	For nX := 1 To Len(aDados)
	
		lMsErroAuto := .F.          		
		dVencto		:= CtoD(aDados[nX][6])         
		dEmissao	:= FirstDate(dVencto)
		nValor		:= Val(Replace(Replace(Replace(aDados[nX][7], "R$", ""),".",""),",","."))
	
		aArray      := {{"E2_PREFIXO"	, AllTrim(aDados[nX][5])					, NIL },;      
						{"E2_TIPO"		, "PR"			 							, NIL },;  
		                {"E2_NUM"		, DtoS(dDatabase)							, NIL },;
						{"E2_NATUREZ"	, aDados[nX][2]								, NIL },;
		                {"E2_FORNECE"	, aDados[nX][3]								, NIL },;
		                {"E2_LOJA"   	, aDados[nX][4]								, NIL },;
		                {"E2_EMISSAO"	, dEmissao 									, NIL },;
		                {"E2_VENCTO"	, dVencto 									, NIL },;
		                {"E2_VENCREA"	, dVencto 									, NIL },;
		                {"E2_VALOR"		, nValor									, NIL },;
		                {"E2_VLCRUZ"	, nValor									, NIL },;	  
		                {"E2_PARCELA"	, AllTrim(aDados[nX][8])					, NIL },;	  
		                {"E2_CC"		, AllTrim(aDados[nX][9])					, NIL },;		               
		                {"E2_HIST"		, AllTrim(aDados[nX][1])	+ " - " +;
		                				  AllTrim(cUserName) 		+ " - " +;
		                				  DtoC(dDataBase) 			+ " - " +;
		                				  Time()									, NIL }}
		                                                                                            
		MsExecAuto({|x,y,z|FINA050(x,y,z)},aArray,,3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

		If lMsErroAuto
		    MostraErro()
		EndIf		

	Next nX

EndIf

Return(.T.)