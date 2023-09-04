#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch" 
#include "ap5mail.ch"
#include "font.ch"

#define ENTER 				CHR(13)+CHR(10)
#define PAD_LEFT			0
#define PAD_RIGHT			1
#define PAD_CENTER			2 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FATX005  ºAutor  ³Tiago O. Beraldi    º Data ³  29/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ CADASTRO DE NAO-CONFORMIDADES ( RNC )                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                     A L T E R A C O E S                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ºProgramador       ºAlteracoes                               º±±
±±º05/01/18   Emerson Paiva      Adequação P12                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FATX005()
Local aArea			:= GetArea()                                     
Private aCores		:= {;
							{"UI_STATUS == '1'"	,"BR_VERDE"		},;	//Aberto
					   		{"UI_STATUS == '2'"	,"BR_AMARELO"	},;	//Em Analise
					   		{"UI_STATUS == '3'"	,"BR_AZUL"		},;	//Transferido
					   		{"UI_STATUS == '4'"	,"BR_PINK"		},;	//Fechado por Motivo Tecnico com Acao Nao Eficaz
                       		{"UI_STATUS == '5'"	,"BR_VERMELHO"	},;	//Fechado por Motivo Tecnico com Acao Eficaz
                       		{"UI_STATUS == '6'"	,"BR_LARANJA"	},;	//Em Auditoria
                       		{"UI_STATUS == '7'"	,"BR_MARRON"	},;	//Fechado por Motivo Outros 
                       		{"UI_STATUS == '8'"	,"BR_PRETO"		},;	//Aprovado Devolucao
                       		{"UI_STATUS == '9'"	,"BR_BRANCO"	};	//Conferido pela Portaria                      		    		                      		
          				}          				          				          				          				

Private aRotina		:= MenuDef()    
Private cAlias		:= "SUI"
Private cCadastro	:= "Cadastro de Não-Conformidades"     
Private cCICPath	:= "\\srv-004\pub\utils\tools\CICMsg.exe srv-004 workflow 123456"    
Private aInvMaqu 	:= {"01-Inadequado","02-Descalibrado","03-Sem Manutenção","04-Sujo"}
Private aInvMeto	:= {"01-Não Existe","02-Ultrapassado","03-Incompleto","04-Rasurado"}
Private aInvMedi	:= {"01-Incompleta","02-Errada","03-Cálculo Errado"}
Private aInvMatP	:= {"01-Reprovada","02-Aprovada com Restrição","03-Nova","04-Aprovada por C.A."}
Private aInvMObr	:= {"01-Pressa","02-Imprudencia","03-Falta de Capacitacao","04-Falta de Treinamento"}
Private aInvMAmb	:= {"01-Calor/Poeira","02-Falta Iluminação","03-Lay-out Inadequado","04-Falta de Espaço"}
Private cTpMov      := Alltrim(SuperGetMV("ES_TPMOVDE",.T.,"02#31#32" ))

dbSelectArea(cAlias)
dbSetOrder(1)              

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra registros para exibicao na MBROWSE              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
If !U_IsGroup("Administradores#ISO-X00")
	Set Filter To &( "@ ( RTrim(UI_INCLUI) = '" + Upper(AllTrim(cUserName)) + "' OR RTrim(UI_USRACAO) = '" + Upper(AllTrim(cUserName)) + "' OR RTrim(UI_USRAUDI)='" + Upper(AllTrim(cUserName)) + "' )" )
EndIf
*/

mBrowse(06,01,22,75,cAlias,,,,,,aCores) 
                     
Set Filter To

RestArea(aArea)

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Alexandre Marson      ³ Data ³24/04/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()    

Local aMenuDef := {} 
                
aAdd( aMenuDef, {"Pesquisar"			,"AxPesqui"		, 0, 1})
aAdd( aMenuDef, {"Visualizar"			,"U_FATX005M"	, 0, 2})
aAdd( aMenuDef, {"Incluir"				,"U_FATX005M"	, 0, 3})
aAdd( aMenuDef, {"Alterar"				,"U_FATX005M"	, 0, 4})
aAdd( aMenuDef, {"Excluir"				,"U_FATX005M"	, 0, 5})
aAdd( aMenuDef, {"Avaliar"				,"U_FATX005M"	, 0, 6})
aAdd( aMenuDef, {"Transferir"			,"U_FATX005M"	, 0, 7})
aAdd( aMenuDef, {"Aprovar Devolucao"	,"U_FATX005M"	, 0, 8})
aAdd( aMenuDef, {"Conferencia Portaria"	,"U_FATX005M"	, 0, 9})
aAdd( aMenuDef, {"Legenda"				,"U_FATX005L"	, 0, 0})  
aAdd( aMenuDef, {"Conhecimento"			,"U_fDocumentos", 0, 0}) 
aAdd( aMenuDef, {"Tipo Motivos"			,"U_MFATQA01"   , 0, 0}) 
aAdd( aMenuDef, {"&Documentos"   		,"U_GENA006(Recno(), 'SUI')", 0, 2, 0, Nil})
aAdd( aMenuDef, {"Imprimir"				,"U_FATX005I"	, 0, 0})

Return (aMenuDef)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FINX005L ºAutor  ³Tiago O. Beraldi    º Data ³  29/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³GERA LEGENDA                                                º±±
±±º          ³                                                            º±±
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
User Function FATX005L()

Local aCor := {}

aAdd(aCor,{"BR_VERDE"		, "Aberto"						})
aAdd(aCor,{"BR_AMARELO"		, "Em Analise"					})
aAdd(aCor,{"BR_AZUL"		, "Transferido"					})
aAdd(aCor,{"BR_PINK"		, "Fechado Tecnico - Nao Eficaz"})                                    
aAdd(aCor,{"BR_VERMELHO"	, "Fechado Tecnico - Eficaz"	})
aAdd(aCor,{"BR_LARANJA"	    , "Em Auditoria"				})
aAdd(aCor,{"BR_MARRON"		, "Fechado Outros"				})
aAdd(aCor,{"BR_PRETO"		, "Devolução Autorizada"		})
aAdd(aCor,{"BR_BRANCO"		, "Devolução Conferida"			})

BrwLegenda(cCadastro, "Legenda", aCor)

Return(Nil)             

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FATX005M  ºAutor  ³Alexandre Marson    º Data ³  24/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                           				                  º±±
±±º          ³                                                            º±±
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
User Function FATX005M(cAlias,nReg,nOpc)  
Local aArea				:= GetArea()

Local aSize		 		:= MsAdvSize()

Local oDlg				:= Nil            

Local lOk	 			:= .F.      

Local nOpcx	  			:= IIf( nOpc > 5, 4, nOpc )
Local nOpcGD			:= If( (nOpc == 3 .Or. nOpc == 4), GD_INSERT+GD_UPDATE+GD_DELETE, 0 )
      
Local aButtons 			:= {}

Local bOk	   			:= {|| If( fTudOk(cAlias,nReg,nOpc), ( lOk:=.T., oDlg:End() ), lOk:=.F. ) }
Local bCancel			:= {|| oDlg:End() }
                                 
Local aHeader			:= {}
Local aCols				:= {} 
Local nX                := 0              
       
Local cAliasGD1			:= "SUJ"	
Local cCposGD1  		:= "UJ_ITEM#UJ_PRODUTO#UJ_VDESCRI#UJ_QTDE#UJ_PRECO#UJ_TOTAL#UJ_LOTE#UJ_VLDLOTE"
Local bGD1LinOk			:= {||AllwaysTrue()}
Local bGD1TudOk			:= {||AllwaysTrue()}       

Local cUsrAltRNC		:= Alltrim(SuperGetMV("ES_URNCALT",.T.,"")) // Usuarios com acesso a Alteração RNC
Local cUsrExcRNC		:= Alltrim(SuperGetMV("ES_URNCEXC",.T.,"")) // Usuarios com acesso a Exclusão RNC
Local cUsrCnfRNC		:= Alltrim(SuperGetMV("ES_URNCCNF",.T.,"")) // Usuarios com acesso a Conferencia RNC
Local cUsrApvRNC		:= Alltrim(SuperGetMV("ES_URNCAPV",.T.,"")) // Usuarios com acesso a Aprovação RNC
Local cUsrAvlRNC		:= Alltrim(SuperGetMV("ES_URNCAVL",.T.,"")) // Usuarios com acesso a Avaliação RNC
Local cUsrAdmRNC        := Alltrim(SuperGetMV("ES_URNCADM",.T.,"CAROLINE.MONEA#LUANA.ARANEGA#ADMINISTRADOR#FABIANA.PRADO" )) // Usuarios com acesso de administradores da RNC 


Private oFolder			:= Nil      
Private aTitles			:= {}                                                 

Private oMsGet1			:= Nil
Private aVMsGet1		:= {"NOUSER","UI_ATEND","UI_EMISSAO","UI_INCLUI","UI_TIPO","UI_CODCLI","UI_LOJA","UI_NOMECLI","UI_CONTATO","UI_TELCTO","UI_SNOTA","UI_CARGA","UI_DTCARGA","UI_VISTECN","UI_NCONFOR","UI_NCONFCP","UI_DEVOLUC","UI_MOTDEVO","UI_OCDESC","UI_CAUTEC","UI_CAUDSC","UI_VEND","UI_DSCVEN","UI_TRANSP","UI_DSCTRAN","UI_DOCDEV"}
Private aAMsGet1		:= {"UI_ATEND","UI_EMISSAO","UI_INCLUI","UI_TIPO","UI_CODCLI","UI_LOJA","UI_NOMECLI","UI_CONTATO","UI_TELCTO","UI_SNOTA","UI_CARGA","UI_DTCARGA","UI_VISTECN","UI_NCONFOR","UI_NCONFCP","UI_DEVOLUC","UI_MOTDEVO","UI_OCDESC","UI_CAUTEC","UI_CAUDSC","UI_VEND","UI_DSCVEN","UI_TRANSP","UI_DSCTRAN","UI_DOCDEV"}
Private oGetD1			:= Nil                 
Private aTela1			:= {}

                                               
Private oMsGet2			:= Nil

Private aVMsGet2		:= {"NOUSER","UI_TERMINO","UI_ANALISE","UI_PROCEDE","UI_DEVOLUC","UI_PROBLEM","UI_INVMAQU","UI_INVMETO","UI_INVMEDI","UI_INVMATP","UI_INVMOBR","UI_INVMAMB","UI_CAUSA","UI_ACAO","UI_GRPINVE","UI_PLANO","UI_XUSER"}
Private aAMsGet2		:= {"UI_TERMINO","UI_ANALISE","UI_PROCEDE","UI_DEVOLUC","UI_PROBLEM","UI_INVMAQU","UI_INVMETO","UI_INVMEDI","UI_INVMATP","UI_INVMOBR","UI_INVMAMB","UI_CAUSA","UI_ACAO","UI_GRPINVE","UI_PLANO","UI_XUSER"}
Private aTela2			:= {}                                      
                                               
Private oMsGet3			:= Nil
Private aVMsGet3		:= {"NOUSER","UI_IMPLANT","UI_DETIMPL","UI_EFICAZ","UI_DETEFIC","UI_XUSER","UI_DTFIM"}
Private aAMsGet3		:= {"UI_IMPLANT","UI_DETIMPL","UI_EFICAZ","UI_DETEFIC","UI_XUSER","UI_DTFIM"}
Private aTela3			:= {}

Private cLastMVar		:= ""     

Private nHeader			:= 0  
Private aRegistro		:= {}

Private	aTELA[0][0]
Private aGETS[0]
                         
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula objetos do primeiro folder                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aObjects := {}
AAdd( aObjects, { 100, 40, .T., .T., .T. } )
aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 } 
aPosObj := MsObjSize( aInfo, aObjects )               
              
              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variavel de memoria                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory(cAlias, ( nOpc == 3 ))                                                                             

//+----------------------------------------------------------------------------
//| VISUALIZACAO - Exibe TODOS OS FOLDERS acrescentando os campos de 
//|            	   AVALIADOR, RESPONSAVEL E AUDITOR
//+----------------------------------------------------------------------------                   
If nOpc == 2		
	aAdd(aTitles, "1 - Identificação")
	aAdd(aTitles, "2 - Análise e Plano de Ação")
	aAdd(aTitles, "3 - Eficácia")                
	
	aAdd(aVMsGet1, "UI_DTHRAVA")
	aAdd(aVMsGet1, "UI_USRAVAL")
	aAdd(aVMsGet1, "UI_USRACAO")
	aAdd(aVMsGet1, "UI_USRAUDI")

	aAdd(aAMsGet1, "UI_DTHRAVA")
	aAdd(aAMsGet1, "UI_USRAVAL")
	aAdd(aAMsGet1, "UI_USRACAO")
	aAdd(aAMsGet1, "UI_USRAUDI")
		
EndIf  
      	                       	                        
//+----------------------------------------------------------------------------
//| INCLUSAO - Exibe apenas o FOLDER[1] sem acrescentar os campos de 
//|            AVALIADOR, RESPONSAVEL E AUDITOR
//+----------------------------------------------------------------------------
If nOpc == 3           
	aAdd(aTitles, "1 - Identificação")       
EndIf      	                

//+----------------------------------------------------------------------------
//| ALTERACAO - Analisar as regras abaixo
//+----------------------------------------------------------------------------
If nOpc == 4
                                                          
	If (	Upper(AllTrim(cUserName)) == Upper(AllTrim(M->UI_INCLUI)) .And. ( M->UI_STATUS $ "4#5#7" ) )
		//+----------------------------------------------------------------------------
		//| ALTERACAO - Registro que foi encerrado pode ser adicionado alguma informacao
		//|             complementar
		//+----------------------------------------------------------------------------	
		aAdd(aTitles, "1 - Identificação")      
		
		If RTrim(Upper(M->UI_MOTDEVO)) $ cTpMov
			aAdd(aTitles, "2 - Análise e Plano de Ação")
			aAdd(aTitles, "3 - Eficácia")               
		EndIf 		
	
		aAMsGet1 := {"UI_NCONFCP"}
		aAMsGet2 := {}			
		aAMsGet3 := {}	  
		 
		If Empty(M->UI_VISTECN)
			AAdd(aAMsGet1, "UI_VISTECN")
		EndIf			
		

	ElseIf Upper(AllTrim(cUserName)) == Upper(AllTrim(M->UI_INCLUI)) .And. M->UI_STATUS $ "1"
		//+----------------------------------------------------------------------------
		//| ALTERACAO - Registro que ainda nao foi avaliado por um membro do grupo ISO 
		//|             exibira apenas os campos marcados como FOLDER 1 com excessao 
		//|             dos campos relacionados ao AVALIADOR, RESPONSAVEL E AUDITOR 
		//+----------------------------------------------------------------------------
		aAdd(aTitles, "1 - Identificação")       

	ElseIf Upper(AllTrim(cUserName)) == Upper(AllTrim(M->UI_USRACAO)) .Or.;
	       Upper(AllTrim(cUserName)) == Upper(AllTrim(M->UI_USRAUDI)) .Or. Upper(AllTrim(cUserName))$ cUsrAltRNC //"THIAGO.SILVA#ALESSANDRA.MONEA#EMERSON.CARMO#JOSE.RODRIGUES#SAMUEL.SANTANA#FELIPE.OLIVEIRA#CASSIO.GOMI#JOSE.MEDEIROS"	//U_IsGroup("LAB-X00") //Adicionado Grupo em 07/01/16
		
		If Upper(AllTrim(cUserName)) == Upper(AllTrim(M->UI_USRACAO)) .Or. Upper(AllTrim(cUserName))$ cUsrAltRNC //"THIAGO.SILVA#ALESSANDRA.MONEA#EMERSON.CARMO#JOSE.RODRIGUES#SAMUEL.SANTANA#FELIPE.OLIVEIRA#CASSIO.GOMI#JOSE.MEDEIROS" //U_IsGroup("LAB-X00") //Adicionado Grupo em 03/11/17
			//+----------------------------------------------------------------------------
			//| ALTERACAO - Registro que ja tenha associado um responsavel (UI_USRACAO)
			//|             exibira TODOS os campos mas apenas os campos marcados como 
			//|             FOLDER 2 poderão ser alterados ou campo COMPLEMENTO do FOLDER 1 
			//+----------------------------------------------------------------------------		
			aAdd(aTitles, "1 - Identificação")
			aAdd(aTitles, "2 - Análise e Plano de Ação")
			                                  
			aAMsGet1 := {"UI_NCONFCP"}
			aAMsGet3 := {}	         
		EndIf
                         
		If Upper(AllTrim(cUserName)) == Upper(AllTrim(M->UI_USRAUDI))
			//+----------------------------------------------------------------------------
			//| ALTERACAO - Registro que ja tenha associado um auditor (UI_USRAUDI)
			//|             exibira TODOS os campos mas apenas os campos marcados como 
			//|             FOLDER 3 poderão ser alterados ou campo COMPLEMENTO do FOLDER 1 
			//+----------------------------------------------------------------------------		
			aAdd(aTitles, "1 - Identificação")
			aAdd(aTitles, "2 - Análise e Plano de Ação")
			aAdd(aTitles, "3 - Eficácia")               

			aAMsGet1 := {"UI_NCONFCP"}
			aAMsGet2 := {} 
		EndIf              
		                  
	Else
		If Upper(RTrim(cUserName)) $ cUsrAdmRNC //"CAROLINE.MONEA#LUANA.ARANEGA#ADMINISTRADOR" // 28/11/2016 Ajuste realizado para revisão dos registros para normas exigidas pela auditoria. LUANA.ARANEGA#
			//(cAlias)->UI_STATUS 	:= "6"  
			//(cAlias)->UI_LOG		:= "Manutenção realizada por " + Upper(AllTrim(cUsuario)) + " em " + DtoC(dDataBase) + " " + Time() + ENTER
			//+----------------------------------------------------------------------------
			//| ALTERACAO - Registro que ja tenha associado um auditor (UI_USRAUDI)
			//|             exibira TODOS os campos mas apenas os campos marcados como 
			//|             FOLDER 3 poderão ser alterados ou campo COMPLEMENTO do FOLDER 1 
			//+----------------------------------------------------------------------------		
			aAdd(aTitles, "1 - Identificação")
			aAdd(aTitles, "2 - Análise e Plano de Ação")
			aAdd(aTitles, "3 - Eficácia")               

			aAMsGet1 := {"UI_NCONFOR","UI_NCONFCP","UI_CODCLI","UI_LOJA","UI_TIPO","UI_MOTDEVO","UI_SNOTA","UI_VEND","UI_DSCVEN","UI_DOCDEV"}
			aAMsGet2 := {"UI_TERMINO","UI_ANALISE","UI_PROCEDE","UI_DEVOLUC","UI_PROBLEM","UI_INVMAQU","UI_INVMETO","UI_INVMEDI","UI_INVMATP","UI_INVMOBR","UI_INVMAMB","UI_CAUSA","UI_ACAO","UI_GRPINVE","UI_PLANO","UI_OCDESC","UI_CAUTEC","UI_CAUDSC","UI_XUSER","UI_DOCDEV"}	
		Else		//Alterado 23/01/17 
			//+----------------------------------------------------------------------------
			//| ALTERACAO - Negado quando usuario ativo diferente do gravado no registro
			//+----------------------------------------------------------------------------   		
			MsgStop( "Este registro não pode ser alterado!", "FATX005" )    
			Return
		EndIf
	EndIf                        

EndIf      	                
      	
//+----------------------------------------------------------------------------
//| EXCLUSAO
//+----------------------------------------------------------------------------
If nOpc == 5

	If !Upper(AllTrim(cUserName))$ cUsrExcRNC //"ADMINISTRADOR#THIAGO.SILVA#ALESSANDRA.MONEA#LUANA.ARANEGA#EMERSON.CARMO#JOSE.RODRIGUES#SAMUEL.SANTANA#FELIPE.OLIVEIRA#CASSIO.GOMI#JOSE.MEDEIROS"	//!U_IsGroup("Administradores#ISO-X00")
		// Paulo lenzi
		If .Not. M->UI_STATUS $ "1#7" .Or. Upper(AllTrim(cUserName)) != Upper(AllTrim(M->UI_INCLUI))
			MsgStop("Registro não pode excluido!", "FATX005")
			Return   
		EndIf	

	EndIf
	
	aAdd(aTitles, "1 - Identificação")
	aAdd(aTitles, "2 - Análise e Plano de Ação")
	aAdd(aTitles, "3 - Eficácia")                          
		                         
	aAdd(aVMsGet1, "UI_DTHRAVA")
	aAdd(aVMsGet1, "UI_USRAVAL")
	aAdd(aVMsGet1, "UI_USRACAO")
	aAdd(aVMsGet1, "UI_USRAUDI")		
		      	
EndIf      	
      	
//+----------------------------------------------------------------------------
//| AVALIAR
//+----------------------------------------------------------------------------
If nOpc == 6          

	If !Upper(AllTrim(cUserName))$ cUsrAvlRNC// "ADMINISTRADOR#THIAGO.SILVA#ALESSANDRA.MONEA#LUANA.ARANEGA#EMERSON.CARMO#JOSE.RODRIGUES#SAMUEL.SANTANA#FELIPE.OLIVEIRA#CASSIO.GOMI#JOSE.MEDEIROS" //!U_IsGroup("Administradores#ISO-X00")
		MsgInfo("Opção não permitida para seu usuário.", "FATX005")
		Return 
	EndIf
	
	aAdd(aTitles, "1 - Identificação")	

	aAdd(aVMsGet1, "UI_DTHRAVA")
	aAdd(aVMsGet1, "UI_USRAVAL")
	aAdd(aVMsGet1, "UI_USRACAO")
	aAdd(aVMsGet1, "UI_USRAUDI")
	
	aAMsGet1 := {}
	aAdd(aAMsGet1, "UI_USRACAO")
	aAdd(aAMsGet1, "UI_USRAUDI")	
	
	M->UI_USRAVAL	:= Upper(AllTrim(cUserName))
	M->UI_DTHRAVA	:= DtoC(dDataBase)  + " " + Substr(Time(),1,5)		                     
	
EndIf	
      	
//+----------------------------------------------------------------------------
//| TRANSFERIR
//+----------------------------------------------------------------------------
If nOpc == 7
                 
	If !Upper(AllTrim(cUserName))$"ADMINISTRADOR#THIAGO.SILVA#ALESSANDRA.MONEA#LUANA.ARANEGA#EMERSON.CARMO#JOSE.RODRIGUES#SAMUEL.SANTANA#FELIPE.OLIVEIRA#CASSIO.GOMI#JOSE.MEDEIROS"	//!U_IsGroup("Administradores#ISO-X00")
		MsgInfo("Opção não permitida para seu usuário.", "FATX005")
		Return   
	EndIf
	
	If Empty(M->UI_USRAVAL)
		MsgInfo("Registro não pode ser transferido porque ainda não foi avaliado por um membro do grupo ISO.", "FATX005")
		Return   
	EndIf        
	
	aAdd(aTitles, "1 - Identificação")	

	aAdd(aVMsGet1, "UI_DTHRAVA")
	aAdd(aVMsGet1, "UI_USRAVAL")
	aAdd(aVMsGet1, "UI_USRACAO")
	aAdd(aVMsGet1, "UI_USRAUDI")
	
	aAMsGet1 := {}
	aAdd(aAMsGet1, "UI_USRACAO")
	aAdd(aAMsGet1, "UI_USRAUDI")  
	                   
	M->UI_USRACAO	:= ""    
	M->UI_USRAUDI	:= ""	
		
EndIf      	
       
//+----------------------------------------------------------------------------
//| APROVAR DEVOLUCAO - CONTROLADORIA
//+----------------------------------------------------------------------------
If nOpc == 8

	If !Upper(AllTrim(cUserName))$ cUsrApvRNC //"ADMINISTRADOR#ALESSANDRA.MONEA#CAROLINE.MONEA#THIAGO.MONEA#LUANA.ARANEGA" //!U_IsGroup("Administradores#DIR-X00")
		MsgInfo("Opção não permitida para seu usuário.", "FATX005")
		Return 
	EndIf
	
	aAdd(aTitles, "1 - Identificação")
	aAdd(aTitles, "2 - Análise e Plano de Ação")
	aAdd(aTitles, "3 - Eficácia")                          
		                         
	aAdd(aVMsGet1, "UI_DTHRAVA")
	aAdd(aVMsGet1, "UI_USRAVAL")
	aAdd(aVMsGet1, "UI_USRACAO")
	aAdd(aVMsGet1, "UI_USRAUDI")  
	
	aAMsGet1 := {"UI_NCONFCP"}
	aAMsGet2 := {}				
	aAMsGet3 := {}				

EndIf      	 

//+----------------------------------------------------------------------------
//| CONFERENCIA DO MATERIAL DEVOLVIDO - PORTARIA
//+----------------------------------------------------------------------------
If nOpc == 9

	If	!Upper(AllTrim(cUserName))$ cUsrCnfRNC //"ADMINISTRADOR#IVAN.MEDEIROS#JOSE.VELOSO#CARLOS.ALVES#EDSON.MIRANDA#ANTONIO.MARCOS#IVANALDO.COSTA#LUANA.ARANEGA" //!U_IsGroup("Administradores#POR-X00")
		MsgInfo("Opção não permitida para seu usuário.", "FATX005")
		Return 
	EndIf
	
	aAdd(aTitles, "1 - Identificação")
	aAdd(aTitles, "2 - Análise e Plano de Ação")
	aAdd(aTitles, "3 - Eficácia")                          
		                         
	aAdd(aVMsGet1, "UI_DTHRAVA")
	aAdd(aVMsGet1, "UI_USRAVAL")
	aAdd(aVMsGet1, "UI_USRACAO")
	aAdd(aVMsGet1, "UI_USRAUDI")  
	
	aAMsGet1 := {"UI_NCONFCP"}
	aAMsGet2 := {}				
	aAMsGet3 := {}				

EndIf  
      	      		      	                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta AHeader ( oGetD1 )                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
DbSetOrder(1)
DbGoTop()
DbSeek(cAliasGD1)     

While ( !Eof() .And. SX3->X3_ARQUIVO == cAliasGD1 )

	If ( X3Uso(SX3->X3_USADO) ;
			.And. cNivel >= SX3->X3_NIVEL ;
			.And. RTrim(SX3->X3_CAMPO) $ cCposGD1	 )
		            
		aAdd(aHeader, {;
							X3Titulo()				,;
	                        SX3->X3_CAMPO			,;
	                 		SX3->X3_PICTURE			,;
	                		SX3->X3_TAMANHO			,;
	                		SX3->X3_DECIMAL			,;
	                 		SX3->X3_VALID			,;
	                		SX3->X3_USADO			,;
	                		SX3->X3_TIPO			,;
	                		SX3->X3_F3				,;
	                		SX3->X3_CONTEXT			,;
	                		SX3->X3_CBOX			,;
	                		SX3->X3_RELACAO			;
                	 })
	EndIf

	DbSkip()

Enddo    
                               
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aCols                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
nHeader := Len(aHeader)

If INCLUI

	aAdd(aCols,Array(nHeader+1))
		
	For nX := 1 to nHeader  

		aCols[1,nX] := CriaVar(aHeader[nX,2])
		
		If ( AllTrim(aHeader[nX][2]) == "UJ_ITEM" )
			aCols[1][nX] := "01"
		EndIf			

	Next nX
	
	aCols[1,(nHeader+1)] := .F.	 

Else

	dbSelectArea(cAliasGD1)
	dbSetOrder(1)
	dbSeek(xFilial(cAliasGD1)+M->UI_CODIGO+"SUI")
        
	While (cAliasGD1)->(!EoF()) .And. (cAliasGD1)->(UJ_FILIAL+UJ_CODIGO+UJ_ENTIDA) == xFilial(cAlias)+M->UI_CODIGO+"SUI"
		
		aAdd(aCols,Array(nHeader+1))
		
		For nX := 1 to nHeader    
			If aHeader[nX][10] != "V"
				aCols[Len(aCols),nX] := FieldGet(FieldPos(aHeader[nX,2]))
			Else
				aCols[1,nX] := CriaVar(aHeader[nX,2])  
			EndIf
		Next nX
		
		aCols[Len(aCols),(nHeader+1)] := .F.
		
		aAdd(aRegistro,RecNo())
			
		dbSkip()

	Enddo

EndIf                                 	      	      	
      	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria objetos visuais                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL     
	oDlg:lCentered			:= .T. 
	oDlg:bInit 				:= {|| EnchoiceBar(oDlg,bOk,bCancel,,aButtons)}
	                    
	oFolder					:= TFolder():New(aPosObj[1,1],aPosObj[1,2],aTitles,,oDlg,,,,.T.,,aPosObj[1,3],aPosObj[1,4])
	oFolder:Align			:= CONTROL_ALIGN_ALLCLIENT
	
	If ( Len(aTitles) >= 1 )
		oMsmGet1		   		:= MsmGet():New(cAlias,nReg,nOpcx,,,,aVMsGet1,{3, 3, aPosObj[1,4]/2,aPosObj[1,3] - 5 },aAMsGet1,,,,,oFolder:aDialogs[1],,.T.,,"aTela1",.T.,.T.) 
		oMsmGet1:oBox:Align		:= CONTROL_ALIGN_TOP
		
		oGetD1 			  		:= MsNewGetDados():New(001,001,150,150,nOpcGD,bGD1LinOk,bGD1TudOk,"+UJ_ITEM",,0,999999,Nil,Nil,,oFolder:aDialogs[1],aHeader,aCols)      
		oGetD1:oBrowse:Align	:= CONTROL_ALIGN_ALLCLIENT
	EndIf
	
	If ( Len(aTitles) >= 2 )
		oMsmGet2		   		:= MsmGet():New(cAlias,nReg,nOpcx,,,,aVMsGet2,{3, 3, aPosObj[1,4]/2,aPosObj[1,3] - 5 },aAMsGet2,,,,,oFolder:aDialogs[2],,.T.,,"aTela2",.T.,.T.) 
		oMsmGet2:oBox:Align		:= CONTROL_ALIGN_ALLCLIENT                                                                                                                           
	EndIf
	
	If ( Len(aTitles) >= 3 )
		oMsmGet3		   		:= MsmGet():New(cAlias,nReg,nOpcx,,,,aVMsGet3,{3, 3, aPosObj[1,4]/2,aPosObj[1,3] - 5 },aAMsGet3,,,,,oFolder:aDialogs[3],,.T.,,"aTela3",.T.,.T.) 
		oMsmGet3:oBox:Align		:= CONTROL_ALIGN_ALLCLIENT
	EndIf
	
	oFolder:SetOption(1)
	
oDlg:ACTIVATE()     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava informacoes no banco de dados                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lOk    
	fConfirma(cAlias,nReg,nOpc)
	If	__lSX8
		ConfirmSX8()
	EndIf
	EvalTrigger()		
Else  
	If ( __lSX8)
		RollBackSX8()
	EndIf
EndIf                                     	

Restarea(aArea)

Return(Nil)

User Function FATX005x(cAlias,nReg,nOpc)  
Local aArea				:= GetArea()

Restarea(aArea)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fConfirma ºAutor  ³Alexandre Marson    º Data ³  25/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                              			                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Static Function fConfirma(cAlias,nReg,nOpc)

Local aArea		:= GetArea()    
Local nX		:= 0  
Local nZ        := 0      
Local bCampo	:= {|nField| FieldName(nField) }  
Local aHeader  	:= oGetD1:aHeader
Local aCols   	:= oGetD1:aCols 
Local cMsg		:= ""
//Local aSx3Box 	:= RetSx3Box( Posicione("SX3", 2, "UI_MOTDEVO", "X3CBox()" ),,, 1 )
Local cSx3Box	:= ""
//Local nSX3Box	:= 0
                                
BEGIN SEQUENCE                         
                         
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ INCLUSAO                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	If nOpc == 3
	
		dbSelectArea(cAlias)
		dbSetOrder(5)
		dbGoTop()
		
		cCodigo := TKNUMERO("SUI","UI_CODIGO")	
		While (cAlias)->(MsSeek(xFilial("SUI")+cCodigo))
			If ( __lSx8 )
				ConfirmSX8()
			EndIf
			cCodigo := TKNUMERO("SUI","UI_CODIGO")
		EndDo
		ConfirmSx8() 
		                          
		//+----------------------------------------------------------------------------
		//| Grava registro de cabecalho
		//+----------------------------------------------------------------------------
		RecLock(cAlias, .T.)
	
			For nX := 1 To FCount()
				FieldPut(nX,M->&(EVAL(bCampo,nX)))
			Next nX
	
			(cAlias)->UI_FILIAL		:= xFilial(cAlias)                                         
			(cAlias)->UI_USRAVAL	:= Upper(Alltrim(M->UI_USRAVAL))
			(cAlias)->UI_USRACAO	:= Upper(Alltrim(M->UI_USRACAO))
			(cAlias)->UI_USRAUDI	:= Upper(Alltrim(M->UI_USRAUDI))	
			
			(cAlias)->UI_STATUS		:= IIf( !(cAlias)->UI_MOTDEVO $ cTpMov, "7", "1" ) //(cAlias)->UI_STATUS		:= IIf( (cAlias)->UI_MOTDEVO != "T", "7", "1" )
			(cAlias)->UI_DEVOLUC	:= IIf( !(cAlias)->UI_MOTDEVO $ cTpMov, "2", "3" )
			(cAlias)->UI_PROCEDE	:= IIf( (cAlias)->UI_PROCEDE != "T", "1", "2" )        
	
			(cAlias)->UI_CODIGO		:= cCodigo
			(cAlias)->UI_ATEND		:= cCodigo
			
			(cAlias)->UI_LOG		:= "INCLUIDO por " + Upper(AllTrim(cUsuario)) + " em " + DtoC(dDataBase) + " " + Time() + ENTER
			
		(cAlias)->( MsUnlock() )   
		
		//+----------------------------------------------------------------------------
		//| Grava registro de itens
		//+----------------------------------------------------------------------------  
		dbSelectArea("SUJ")
		dbSetOrder(1)
		
		For nX := 1 To Len(aCols)               
		
			If !( aCols[nX][nHeader+1] ) //Registro Deletado
				
				//+----------------------------------------------
				//| Grava registro de carga
				//+----------------------------------------------  
				RecLock("SUJ",.T.)
					For nZ := 1 To nHeader
						If ( aHeader[nZ][10] != "V" )
							FieldPut(FieldPos(aHeader[nZ][2]),aCols[nX][nZ])
						EndIf
					Next nZ         
					SUJ->UJ_FILIAL	:= xFilial("SUJ")
					SUJ->UJ_ENTIDA	:= "SUI"
					SUJ->UJ_VALOR	:= "SUI->UI_CODIGO"
					SUJ->UJ_CODIGO	:= cCodigo
				SUJ->( MsUnlock() )
	
	  		EndIf	
		
		Next nX   	
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ALTERACAO                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	ElseIf nOpc == 4
	                       
		//+----------------------------------------------------------------------------
		//| Grava registro de cabecalho
		//+----------------------------------------------------------------------------  
		dbSelectArea(cAlias)
		
		RecLock(cAlias, .F.)                    
		
			For nX := 1 To FCount()
				FieldPut(nX,M->&(EVAL(bCampo,nX)))
			Next nX           
		     
	           
			If M->UI_MOTDEVO $ cTpMov
			
					If !Empty(M->UI_ANALISE) .And. !Empty(M->UI_CAUSA) .And. !Empty(M->UI_ACAO) .And. !Empty(M->UI_PLANO) ;
							.And. Empty(M->UI_DETIMPL) .And. Empty(M->UI_DETEFIC)
				
						(cAlias)->UI_STATUS		:= "6"
						(cAlias)->UI_LOG		:= "ENVIADO PARA AUDITORIA por " + Upper(AllTrim(cUsuario)) + " em " + DtoC(dDataBase) + " " + Time() + ENTER
						
					ElseIf !Empty(M->UI_DETIMPL) .And. M->UI_IMPLANT == "1" .And. M->UI_EFICAZ == "2" 
			
						(cAlias)->UI_STATUS 	:= "4"
						(cAlias)->UI_LOG		:= "FECHADO ( TECNICO ) - ACAO NAO EFICAZ por " + Upper(AllTrim(cUsuario)) + " em " + DtoC(dDataBase) + " " + Time() + ENTER
			
					ElseIf !Empty(M->UI_DETIMPL) .And. !Empty(M->UI_DETEFIC) .And. M->UI_IMPLANT == "1" .And. M->UI_EFICAZ == "1" 
					
						If Upper(RTrim(cUserName)) == "JOSE.MEDEIROS" // 24/11/2016 Ajuste realizado para revisão dos registros para normas exigidas pela auditoria.
							(cAlias)->UI_STATUS 	:= "6"  
							(cAlias)->UI_LOG		:= "Manutenção realizada por " + Upper(AllTrim(cUsuario)) + " em " + DtoC(dDataBase) + " " + Time() + ENTER  
						Else			
							(cAlias)->UI_STATUS 	:= "5"    
							(cAlias)->UI_LOG		:= "FECHADO ( TECNICO ) - ACAO EFICAZ por " + Upper(AllTrim(cUsuario)) + " em " + DtoC(dDataBase) + " " + Time() + ENTER
						EndIf
					EndIf
				
			Else
		
				(cAlias)->UI_STATUS		:= IIf( !(cAlias)->UI_MOTDEVO $ cTpMov, "7", "1" )
				(cAlias)->UI_DEVOLUC	:= IIf( !(cAlias)->UI_MOTDEVO $ cTpMov, "2", "3" )
				(cAlias)->UI_PROCEDE	:= IIf( (cAlias)->UI_PROCEDE != "T", "1", "2" )    													
				(cAlias)->UI_LOG		:= "FECHADO ( COMERCIAL ) por " + Upper(AllTrim(cUsuario)) + " em " + DtoC(dDataBase) + " " + Time() + ENTER

			EndIf
			
		(cAlias)->( MsUnlock() )
				
		//+----------------------------------------------------------------------------
		//| Grava registro de itens
		//+----------------------------------------------------------------------------  
		dbSelectArea("SUJ")
		dbSetOrder(1)
	
		For nX := 1 To Len(aCols)
	                          
			If nX <= Len(aRegistro)
			
				dbGoto(aRegistro[nX])   
				
				RecLock("SUJ",.F.)   
				If ( aCols[nX][nHeader+1] )
					dbDelete()
				EndIf	
						
		    Else
		                                   
			  	If !( aCols[nX][nHeader+1] )
			    	RecLock("SUJ",.T.)   
			   	EndIf   
			        
		    EndIf
		        		
			If !( aCols[nX][nHeader+1] )
			
				For nZ := 1 To nHeader
					If (aHeader[nZ][10] != "V")
						FieldPut(FieldPos(aHeader[nZ][2]), aCols[nX][nZ])
					EndIf
				Next nZ    
				
				SUJ->UJ_FILIAL	:= xFilial("SUJ")
				SUJ->UJ_ENTIDA	:= "SUI"
				SUJ->UJ_VALOR	:= "SUI->UI_CODIGO"
				SUJ->UJ_CODIGO	:= M->UI_CODIGO
	
			EndIf
		                                                               
			SZG->( MsUnlock() )
	
		Next nX		
	                
	                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ EXCLUSAO                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	ElseIf nOpc == 5    
	                                                
		dbSelectArea(cAlias)
		
		RecLock(cAlias, .F.)     
			(cAlias)->UI_LOG		:= "EXCLUIDO por " + Upper(AllTrim(cUsuario)) + " em " + DtoC(dDataBase) + " " + Time() + ENTER
			dbDelete()
		(cAlias)->( MsUnlock() )   
		
		//Itens - SZG
		dbSelectArea("SUJ")
		dbSetOrder(1)
		dbGoTop()
	
		For nX := 1 To Len(aRegistro)
	                          
			dbGoto(aRegistro[nX])   
			RecLock("SUJ",.F.)   
				dbDelete()
			SUJ->( MsUnlock() )    
		
		Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ AVALIACAO															³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	ElseIf nOpc == 6
	
		dbSelectArea(cAlias)
		
		RecLock(cAlias, .F.)
			(cAlias)->UI_STATUS		:= "2"	
			(cAlias)->UI_USRAVAL	:= Upper(Alltrim(M->UI_USRAVAL))
			(cAlias)->UI_USRACAO	:= Upper(Alltrim(M->UI_USRACAO))
			(cAlias)->UI_USRAUDI	:= Upper(Alltrim(M->UI_USRAUDI))	
			(cAlias)->UI_LOG		:= "AVALIADO por " + Upper(AllTrim(cUsuario)) + " em " + DtoC(dDataBase) + " " + Time() + ENTER
		(cAlias)->( MsUnlock() )
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TRANSFERENCIA														³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	ElseIf nOpc == 7
	
		dbSelectArea(cAlias)   
		
		//+----------------------------------------------------------------------------
		//| Atualiza informacoes do registro atual
		//+----------------------------------------------------------------------------	
		RecLock(cAlias, .F.)
			(cAlias)->UI_STATUS		:= "3"	
			(cAlias)->UI_LOG		:= "TRANSFERIDO por " + Upper(AllTrim(cUsuario)) + " em " + DtoC(dDataBase) + " " + Time() + ENTER
		(cAlias)->( MsUnlock() )
		                                                                                             
		//+----------------------------------------------------------------------------
		//| Cria um novo registro de Nao Conformidade
		//+----------------------------------------------------------------------------	
		cCodigo := TKNUMERO("SUI","UI_CODIGO")	
		While (cAlias)->(MsSeek(xFilial("SUI")+cCodigo))
			If ( __lSx8 )
				ConfirmSX8()
			EndIf
			cCodigo := TKNUMERO("SUI","UI_CODIGO")
		EndDo          
		ConfirmSx8()

		RecLock(cAlias, .T.)
			For nX := 1 To FCount()
				FieldPut(nX,M->&(EVAL(bCampo,nX)))
			Next nX
	
			(cAlias)->UI_STATUS		:= "2"	
			(cAlias)->UI_CODIGO		:= cCodigo
			(cAlias)->UI_ATEND		:= cCodigo			
			(cAlias)->UI_NCORIGE	:= M->UI_CODIGO
			(cAlias)->UI_USRAVAL	:= Upper(Alltrim(M->UI_USRAVAL))
			(cAlias)->UI_USRACAO	:= Upper(Alltrim(M->UI_USRACAO))
			(cAlias)->UI_USRAUDI	:= Upper(Alltrim(M->UI_USRAUDI)) 
			(cAlias)->UI_LOG		:= "INCLUIDO por " + Upper(AllTrim(cUsuario)) + " em " + DtoC(dDataBase) + " " + Time() + ENTER
			
		(cAlias)->( MsUnlock() )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ APROVACAO DE DEVOLUCAO - CONTROLADORIA								³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	ElseIf nOpc == 8
	
		dbSelectArea(cAlias)   
		
		If (cAlias)->UI_PROCEDE != "1"
			If !MsgYesNo("Atenção! Este registro foi avaliado com não procedente." + ENTER +;
			             "Confirma a autorização para devolucao?")
			    Break         
			EndIf		
		EndIf
		
		If (cAlias)->UI_MOTDEVO $ cTpMov .And. (cAlias)->UI_EFICAZ != "2"
			
			If !MsgYesNo("Atenção! Este registro foi resolvido através de uma ação não eficaz." + ENTER +;
			             "Confirma a autorização para devolucao?")
			    Break         
			EndIf		
		
		EndIf

		RecLock(cAlias, .F.)
			(cAlias)->UI_STATUS		:= IIf((cAlias)->UI_TIPO == "I", "9", "8")
			(cAlias)->UI_AUTORIZ	:= RTrim(Upper(cUsername)) + " - " + DtoC(dDataBase) + " " + Time()
			(cAlias)->UI_LOG		:= "DEVOLUCAO AUTORIZADA por " + Upper(AllTrim(cUsuario)) + " em " + DtoC(dDataBase) + " " + Time() + ENTER
			(cAlias)->UI_DEVOLUC	:= IIf((cAlias)->UI_DEVOLUC != "3", (cAlias)->UI_DEVOLUC, IIf((cAlias)->UI_MOTDEVO $ cTpMov, "1", "2"))
		(cAlias)->( MsUnlock() )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ CONFERENCIA - PORTARIA                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	ElseIf nOpc == 9
	
		dbSelectArea(cAlias)   
		RecLock(cAlias, .F.)
			(cAlias)->UI_STATUS		:= "9"	
			(cAlias)->UI_CONFERE	:= RTrim(Upper(cUsername)) + " - " + DtoC(dDataBase) + " " + Time()
			(cAlias)->UI_LOG		:= "CONFERENCIA por " + Upper(AllTrim(cUsuario)) + " em " + DtoC(dDataBase) + " " + Time() + ENTER			
		(cAlias)->( MsUnlock() )
	
	EndIf                     
	                           
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Workflow via mensageiro CIC                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	
	/*
	nSX3Box := Ascan( aSx3Box, { |e| e[2] = (cAlias)->UI_MOTDEVO } )
	If nSX3Box > 0
		cSx3Box := Upper(AllTrim( aSx3Box[nSX3Box][3] )	)// Descricao da situacao.
	Endif		
	*/
	cSx3Box := Posicione("ZZK",1,xFilial("ZZK")+(cAlias)->UI_MOTDEVO,"ZZK_DESC")

	If nOpc == 3
		
		//+----------------------------------------------------------------------------
		//| Avisa usuarios do grupo ISO
		//+----------------------------------------------------------------------------	
		cMsg := '"'
		cMsg += '(Workflow) NAO CONFOMIDADE - ** NOVO REGISTRO ** ' + ENTER + ENTER
		cMsg += 'Codigo.....: ' + (cAlias)->UI_CODIGO + ENTER
		cMsg += 'Usuario....: ' + Upper(AllTrim(cUserName)) + ENTER 
		cMsg += 'Cliente....: ' + '(' + (cAlias)->UI_CODCLI + '-' + (cAlias)->UI_LOJA + ') ' + (cAlias)->UI_NOMECLI + ENTER
		cMsg += 'NFiscal....: ' + (cAlias)->UI_SNOTA + ENTER
		cMsg += 'Motivo.....: ' + cSx3Box + ENTER
		cMsg += 'Descricao..: ' + RTrim((cAlias)->UI_NCONFOR) + ENTER
		cMsg += '"'
		//WinExec(cCICPath + Space(1) + '"' + U_getUserGp("ISO-X00") + ", ALEXANDRE.MARSON" + '"' + Space(1) + cMsg, 0)	
	
	ElseIf nOpc == 4 .And. (cAlias)->UI_STATUS == "6"
	
		//+----------------------------------------------------------------------------
		//| Avisa usuario nomeado como auditor que a NC ja foi analisada
		//+----------------------------------------------------------------------------	
		cMsg := '"'
		cMsg += '(Workflow) NAO CONFOMIDADE - ** ANALISE CONCLUIDA ** ' + ENTER + ENTER
		cMsg += 'Codigo.....: ' + (cAlias)->UI_CODIGO + ENTER
		cMsg += 'Usuario....: ' + Upper(AllTrim(cUserName)) + ENTER 
		cMsg += 'Cliente....: ' + '(' + (cAlias)->UI_CODCLI + '-' + (cAlias)->UI_LOJA + ') ' + (cAlias)->UI_NOMECLI + ENTER
		cMsg += 'NFiscal....: ' + (cAlias)->UI_SNOTA + ENTER
		cMsg += 'Motivo.....: ' + cSx3Box + ENTER
		cMsg += 'Descricao..: ' + RTrim((cAlias)->UI_NCONFOR) + ENTER
		cMsg += '"'	
		//WinExec(cCICPath + Space(1) + '"' + Upper(AllTrim((cAlias)->UI_USRAUDI)) + '"' + Space(1) + cMsg, 0)	
	
	ElseIf nOpc == 6 .Or. nOpc == 7
	
		//+----------------------------------------------------------------------------
		//| Avisa usuario nomeado como responsavel
		//+----------------------------------------------------------------------------	
		cMsg := '"'
		cMsg += '(Workflow) NAO CONFOMIDADE - ** REALIZAR ANALISE ** ' + ENTER + ENTER
		cMsg += 'Codigo.....: ' + (cAlias)->UI_CODIGO + ENTER
		cMsg += 'Usuario....: ' + Upper(AllTrim(cUserName)) + ENTER 
		cMsg += 'Cliente....: ' + '(' + (cAlias)->UI_CODCLI + '-' + (cAlias)->UI_LOJA + ') ' + (cAlias)->UI_NOMECLI + ENTER
		cMsg += 'NFiscal....: ' + (cAlias)->UI_SNOTA + ENTER
		cMsg += 'Motivo.....: ' + cSx3Box + ENTER
		cMsg += 'Descricao..: ' + RTrim((cAlias)->UI_NCONFOR) + ENTER
		cMsg += '"'
		//WinExec(cCICPath + Space(1) + '"' + Upper(AllTrim((cAlias)->UI_USRACAO)) + ", ALEXANDRE.MARSON"  + '"' + Space(1) + cMsg, 0)	
		//WinExec(cCICPath + Space(1) + '"' + Upper(AllTrim((cAlias)->UI_USRACAO))  + '"' + Space(1) + cMsg, 0)
		
		//+----------------------------------------------------------------------------
		//| Avisa usuario nomeado como auditor
		//+----------------------------------------------------------------------------	
		cMsg := '"'
		cMsg += '(Workflow) NAO CONFOMIDADE - ** REALIZAR AUDITORIA ** ' + ENTER + ENTER
		cMsg += 'Codigo.....: ' + (cAlias)->UI_CODIGO + ENTER
		cMsg += 'Usuario....: ' + Upper(AllTrim(cUserName)) + ENTER 
		cMsg += 'Cliente....: ' + '(' + (cAlias)->UI_CODCLI + '-' + (cAlias)->UI_LOJA + ') ' + (cAlias)->UI_NOMECLI + ENTER
		cMsg += 'NFiscal....: ' + (cAlias)->UI_SNOTA + ENTER
		cMsg += 'Motivo.....: ' + cSx3Box + ENTER
		cMsg += 'Descricao..: ' + RTrim((cAlias)->UI_NCONFOR) + ENTER
		cMsg += '"'
		//WinExec(cCICPath + Space(1) + '"' + Upper(AllTrim((cAlias)->UI_USRAUDI)) + '"' + Space(1) + cMsg, 0)	
				
	ElseIf nOpc == 8
	         
	 	//+----------------------------------------------------------------------------
		//| Avisa comercial e expedicao sobre aprovacao de devolucao
		//+----------------------------------------------------------------------------	
		cMsg := '"'
		cMsg += '(Workflow) NAO CONFOMIDADE - ** DEVOLUCAO APROVADA ** ' + ENTER + ENTER
		cMsg += 'Codigo.....: ' + (cAlias)->UI_CODIGO + ENTER
		cMsg += 'Usuario....: ' + Upper(AllTrim(cUserName)) + ENTER 
		cMsg += 'Cliente....: ' + '(' + (cAlias)->UI_CODCLI + '-' + (cAlias)->UI_LOJA + ') ' + (cAlias)->UI_NOMECLI + ENTER
		cMsg += 'NFiscal....: ' + (cAlias)->UI_SNOTA + ENTER
		cMsg += 'Motivo.....: ' + cSx3Box + ENTER
		cMsg += 'Descricao..: ' + RTrim((cAlias)->UI_NCONFOR) + ENTER
		cMsg += '"'
		//WinExec(cCICPath + Space(1) + '"' + U_getUserGp("EXP-X00") + "," + (cAlias)->UI_INCLUI + ", ALEXANDRE.MARSON"  + '"' + Space(1) + cMsg, 0) 	
	
	
	ElseIf nOpc == 9
	         
	 	//+----------------------------------------------------------------------------
		//| Avisa expedicao e comercial que material foi recebido e conferido pela portaria
		//+----------------------------------------------------------------------------	
		cMsg := '"'
		cMsg += '(Workflow) NAO CONFOMIDADE - ** DEVOLUCAO CONFERIDA ** ' + ENTER + ENTER
		cMsg += 'Codigo.....: ' + (cAlias)->UI_CODIGO + ENTER
		cMsg += 'Usuario....: ' + Upper(AllTrim(cUserName)) + ENTER 
		cMsg += 'Cliente....: ' + '(' + (cAlias)->UI_CODCLI + '-' + (cAlias)->UI_LOJA + ') ' + (cAlias)->UI_NOMECLI + ENTER
		cMsg += 'NFiscal....: ' + (cAlias)->UI_SNOTA + ENTER
		cMsg += 'Motivo.....: ' + cSx3Box + ENTER
		cMsg += 'Descricao..: ' + RTrim((cAlias)->UI_NCONFOR) + ENTER
		cMsg += '"'
		//WinExec(cCICPath + Space(1) + '"' + U_getUserGp("EXP-X00") + "," + (cAlias)->UI_INCLUI + ", ALEXANDRE.MARSON"  + '"' + Space(1) + cMsg, 0) 
	                                  
	EndIf           	
	
	If ( nOpc == 3 .Or. nOpc == 4 ) ;
	.And. (cAlias)->UI_STATUS $ "4#5#7" ;
	.And. (cAlias)->UI_DEVOLUC $ "1#2"
		//+----------------------------------------------------------------------------
		//| Avisa administrador que a analise foi encerrada e necessita aprovacao
		//+----------------------------------------------------------------------------	
		cMsg := '"'
		cMsg += '(Workflow) APROVAR DEVOLUCAO ' + ENTER + ENTER
		cMsg += 'Codigo.....: ' + (cAlias)->UI_CODIGO + ENTER
		cMsg += 'Empr/Filial: ' + AllTrim(cFilAnt) + ENTER
		cMsg += 'Usuario....: ' + Upper(AllTrim(cUserName)) + ENTER 
		cMsg += 'Cliente....: ' + '(' + (cAlias)->UI_CODCLI + '-' + (cAlias)->UI_LOJA + ') ' + (cAlias)->UI_NOMECLI + ENTER
		cMsg += 'NFiscal....: ' + (cAlias)->UI_SNOTA + ENTER
		cMsg += 'Motivo.....: ' + cSx3Box + ENTER
		cMsg += 'Descricao..: ' + RTrim((cAlias)->UI_NCONFOR) + ENTER
		cMsg += '"'
		//WinExec(cCICPath + Space(1) + '"ADMINISTRATOR"' + Space(1) + cMsg, 0)			

	EndIf	        


END SEQUENCE	            
	                                  
RestArea( aArea )
Return   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fTudOk    ºAutor  ³Alexandre Marson    º Data ³  25/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                              			                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Static Function fTudOk(cAlias,nReg,nOpc)
Local aArea		:= GetArea()    
Local lOk		:= .T.                
Local nX		:= 0           
Local aHeader  	:= oGetD1:aHeader
Local aCols   	:= oGetD1:aCols 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida campo obrigatorio conforme nOpc                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
dbSelectArea("SX3")
dbSetOrder(2)   
For nX := 1 To (cAlias)->(FCount())

	DbSeek( (cAlias)->(FieldName(nX)) )
	                              
	//+----------------------------------------------------------------------------
	//| INCLUSAO
	//+----------------------------------------------------------------------------		
	If nOpc == 3 ;
			.And. Ascan(aAMsGet1, {|cField| SX3->X3_CAMPO $ cField}) > 0 ;
			.And. X3Obrigat(SX3->X3_CAMPO) ;
			.And. Empty(M->&(SX3->X3_CAMPO))
	                                                            
		MsgStop("Um ou alguns campos obrigatórios não foram preechidos." + ENTER + ENTER +;
		                       "Pasta: 1. Identificacao" + ENTER +;
		                       "Campo: " + X3Titulo() + ENTER +;
		                       "Descrição: " + X3Descric())

		lOk := .F.
		Exit                   
		
	//+----------------------------------------------------------------------------
	//| ALTERACAO / AVALIACAO / TRANSFERENCIA
	//+----------------------------------------------------------------------------		
	ElseIf ( nOpc == 4 .Or. nOpc == 6 .Or. nOpc == 7 );
			.And. (;
					( Len(oFolder:aDialogs) >= 1 .And. Ascan(aAMsGet1, {|cField| SX3->X3_CAMPO $ cField}) > 0 ) .Or.;
					( Len(oFolder:aDialogs) >= 2 .And. Ascan(aAMsGet2, {|cField| SX3->X3_CAMPO $ cField}) > 0 ) .Or.;
					( Len(oFolder:aDialogs) >= 3 .And. Ascan(aAMsGet3, {|cField| SX3->X3_CAMPO $ cField}) > 0 ) ;
			      );
			.And. X3Obrigat(SX3->X3_CAMPO) ;
			.And. Empty(M->&(SX3->X3_CAMPO))

		MsgStop("Um ou alguns campos obrigatórios não foram preechidos." + ENTER + ENTER +;
		                       "Pasta: " + If( SX3->X3_FOLDER == "1", "1. Identificacao", IIf( SX3->X3_FOLDER == "2", "2. Analise/Plano de Acao", "3. Eficacia" )) + ENTER +;
		                       "Campo: " + X3Titulo() + ENTER +;
		                       "Descrição: " + X3Descric())
		
		lOk := .F.
		Exit                                             
	
	EndIf
		
Next nX         
         
//+----------------------------------------------------------------------------
//| Valida a informação de cliente quando registro de NC é TIPO EXTERNO
//+----------------------------------------------------------------------------		
If lOk .And. ( nOpc == 3 .Or. nOpc == 4 ) ;
		.And. ( ( Empty(M->UI_CODCLI) .Or. Empty(M->UI_LOJA) ) .And. !( M->UI_TIPO == "I" .And. M->UI_MOTDEVO == "6" ) ) //.And. ( Empty(M->UI_CODCLI) .Or. Empty(M->UI_LOJA) ) - Alterado 03/02/2016

	MsgStop("Para incluir uma Nao Conformidade é obrigatório informar o codigo e loja do cliente." + ENTER + ENTER +;
	                       "Pasta: 1. Identificacao" + ENTER +;
	                       "Campo: a) Cliente " + ENTER +;
	                       "       b) Loja " + ENTER + ENTER +;
	                       "Descrição: a) Codigo do Cliente que originou a Nao Conformidade." + ENTER +;
	                       "           b) Loja do Cliente que originou a Nao Conformidade. ")
	
	lOk := .F.
EndIf
            
//+----------------------------------------------------------------------------
//| Valida o motivo da devolucao
//+----------------------------------------------------------------------------		
If lOk .And. ( nOpc == 3 .Or. nOpc == 4 ) ;
		.And. Empty(M->UI_MOTDEVO)

		MsgStop("Informe o motivo que originou esta RNC!", "FATX005")		
		lOk := .F.		                       
EndIf		

//+----------------------------------------------------------------------------
//| Valida a informação de lote
//+----------------------------------------------------------------------------		
/*
If lOk .And. ( nOpc == 3 .Or. nOpc == 4 ) ;
		.And. !Empty(M->UI_LOTE) 

	If Len(AllTrim(M->UI_LOTE)) < 6
		                       
		MsgStop("O número referente ao lote deve conter no mínimo 6 posições." + ENTER + ENTER +;
		                       "Pasta: 1. Identificacao" + ENTER +;
		                       "Campo: Lote" + ENTER +;
		                       "Descrição: Lote referente ao produto reclamado.")
		
		lOk := .F.

	ElseIf Len(AllTrim(M->UI_LOTE)) > 6 .And. At(";", AllTrim(M->UI_LOTE)) == 0

		MsgStop("Utilize ; para identificar os lotes." + ENTER + ENTER +;
		                       "Pasta: 1. Identificacao" + ENTER +;
		                       "Campo: Lote" + ENTER +;
		                       "Descrição: Lote referente ao produto reclamado.")
		
		lOk := .F.

    EndIf

EndIf    
*/                                      

If lOk .And. nOpc == 4 ;

	//+----------------------------------------------------------------------------
	//| Valida se usuario executor não é o mesmo que o auditor
	//+----------------------------------------------------------------------------		
	If lOk ;
			.And. ( !Empty(M->UI_USRACAO) .And. !Empty(M->UI_USRAUDI) ) ;
			.And. ( Upper(AllTrim(M->UI_USRACAO)) == Upper(AllTrim(M->UI_USRAUDI)) )
		   
		MsgStop("O usuario responsavel nao pode ser o mesmo que o usuario auditor." + ENTER + ENTER +;
	                       "Pasta: 1. Identificacao" + ENTER +;
	                       "Campo: a) Responsavel " + ENTER +;
	                       "       b) Auditor " + ENTER + ENTER +;
	                       "Descrição: a) Usuario responsavel pela solucao da Nao Conformidade." + ENTER +;
	                       "           b) Usuario responsavel por auditar o plano de acao referente a NC. ")

		lOk := .F.

	EndIf


	//+----------------------------------------------------------------------------
	//| Valida condicao informada para finalizar o registro de NC
	//+----------------------------------------------------------------------------		
	If lOk ;
			.And. ( !Empty(M->UI_USRACAO) .And. !Empty(M->UI_USRAUDI) ) ;
			.And. ( M->UI_IMPLANT == "2" .And. M->UI_EFICAZ == "1" )
		
		MsgStop("O registro não pode ser finalizado como eficaz se o plano de acao nao foi implementado." + ENTER + ENTER +;
		                       "Pasta: 3. Eficacia" + ENTER +;
		                       "Campo: IMPLANTADA / EFICAZ " + ENTER +;
		                       "Descrição: Acao Implantada? / Acao Eficaz ? ")
		lOk := .F.

	EndIf	        
	
	//+----------------------------------------------------------------------------
	//| Valida se o lote de devolucao foi informado quando existe devolucao
	//+----------------------------------------------------------------------------		
	/*
	If lOk ;
			.And. ( !Empty(M->UI_USRACAO) .And. !Empty(M->UI_USRAUDI) ) ;	
			.And. ( M->UI_DEVOLUC $ "12" .And. Empty(M->UI_LOTEDEV) )
				
		MsgStop("A analise gerou devolução mais nenhum lote foi informado." + ENTER + ENTER +;
		                       "Pasta: 2. Analise/Plano de Acao" + ENTER +;
		                       "Campo: Lote Devoluc " + ENTER +;
		                       "Descrição: Lote(s) em que a devolução é procedente.")

		lOk := .F.

	EndIf		
	*/
	
EndIf        

//+----------------------------------------------------------------------------
//| Valida MsNewGetDados
//+----------------------------------------------------------------------------		
If lOk .And. ( nOpc == 3 .Or. nOpc == 4 )

	For nX := 1 To Len(aCols)
	
		If !(aCols[nX][nHeader+1]) 

			If Empty(GDFieldGet("UJ_PRODUTO", nX, .F.,aHeader, aCols)) .Or. Empty(GDFieldGet("UJ_LOTE", nX, .F.,aHeader, aCols))
				MsgStop("Um ou mais campos obrigatários não foram preenchidos na grade de produtos!", "FATX005")		
				lOk := .F.	
				Exit
			EndIf

		EndIf
		
	Next nX

EndIf

RestArea( aArea )

Return lOk


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FATX005G  ºAutor  ³Alexandre Marson    º Data ³  25/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                              			                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
User Function FATX005G( nOpc )
Local aArea		:= GetArea()     
Local xRet		:= ""       
Local aHeader  	:= oGetD1:aHeader
Local aCols   	:= {}
            
Do Case         

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Objetivo: Validar se o lote informado pertence ao produto                                |
	//| Local   : Gatilho                                                                        | 
	//| Campo   : UJ_LOTE                                                                        | 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	Case nOpc == 1    		
	    
	    xRet		:= GDFieldGet("UJ_LOTE")
	                             
	 	cProduto	:= GDFieldGet("UJ_PRODUTO")
	 	cLote		:= GDFieldGet("UJ_LOTE")
	 	
		If !Empty(cProduto) .And. !Empty(cLote)                                                                          
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta script SQL e atribui resultado a workarea QRY    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQry := "SELECT	COUNT(1) REGS " + ENTER
			cQry += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + ENTER
	        cQry += "WHERE SC2.D_E_L_E_T_ = '' " + ENTER
	        cQry += "  AND SC2.C2_FILIAL = '" + xFilial("SC2") + "' " + ENTER
	        cQry += "  AND SC2.C2_PRODUTO = '" + cProduto + "' " + ENTER		
	        cQry += "  AND SC2.C2_NUM = '" + cLote + "' " + ENTER     
	        cQry += "  AND SC2.C2_DATRF != '' " + ENTER	        
		
			If Select("FATX005G") > 0
				FATX005G->(dbCloseArea())
			EndIf
			
			TCQUERY cQry NEW ALIAS FATX005G
			
			dbSelectArea("FATX005G")         			
			
			If FATX005G->REGS = 0
				xRet = ""                   
				MsgStop("Lote incorreto!", "FATX005")
			Else
				U_QIPE001(cLote,";")
			EndIf  
			
			FATX005G->(dbCloseArea())
		
		EndIf	
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Objetivo: Devolver validade do lote reclamado                                            |
	//| Local   : Gatilho                                                                        | 
	//| Campo   : UJ_LOTE                                                                        | 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	Case nOpc == 2    		
	    
	    xRet		:= CtoD("")                          
	 	cProduto	:= GDFieldGet("UJ_PRODUTO")
	 	cLote		:= GDFieldGet("UJ_LOTE")
	 	
		If !Empty(cProduto) .And. !Empty(cLote)
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta script SQL e atribui resultado a workarea QRY    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQry := "SELECT	SC2.C2_NUM [LOTE], " + ENTER
			cQry += " CONVERT(VARCHAR, DATEADD(DD, B1_PRVALID, (SELECT TOP 1 ZD_DTFABR FROM " + RetSqlName("SZD") + " AS SZD WITH (NOLOCK) WHERE SZD.D_E_L_E_T_ = '' AND ZD_FILIAL = '' AND ZD_LOTE = C2_NUM)), 112) [VALIDADE] " + ENTER
			cQry += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + ENTER
	        cQry += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON SB1.D_E_L_E_T_ = '' " + ENTER
	        cQry += "AND SB1.B1_FILIAL = '' " + ENTER
	        cQry += "AND SB1.B1_COD = SC2.C2_PRODUTO " + ENTER
	        cQry += "WHERE SC2.D_E_L_E_T_ = '' " + ENTER
	        cQry += "AND SC2.C2_FILIAL = '" + xFilial("SC2") + "' " + ENTER
	        cQry += "AND SC2.C2_PRODUTO = '" + cProduto + "' " + ENTER		
	        cQry += "AND SC2.C2_NUM = '" + cLote + "' " + ENTER             
	        cQry += "AND SC2.C2_DATRF != '' " + ENTER	        
		
			If Select("FATX005G") > 0
				FATX005G->(dbCloseArea())
			EndIf
			
			TCQUERY cQry NEW ALIAS FATX005G
			
			dbSelectArea("FATX005G")         			
			
			If FATX005G->( !EoF() )
				xRet = StoD(FATX005G->VALIDADE)
			EndIf  
			
			FATX005G->(dbCloseArea())
		
		EndIf		 
				
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Objetivo: Validar se Serie+NFiscal pertence ao cliente informado                         |
	//| Local   : Gatilho                                                                        | 
	//| Campo   : UI_SNOTA                                                                       | 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	Case nOpc == 3  

		xRet := &(ReadVar())   
                  
		If !Empty(xRet)
		
			dbSelectArea("SF2")
			dbSetOrder(1)
			dbSeek(xFilial("SF2") + Subs(xRet,4,12) + Subs(xRet,1,3) + M->UI_CODCLI + M->UI_LOJA)
			
			If !Found()
				MsgStop("Nota fiscal não encontrada!", "FATX005")
				xRet := ""
			Else  
			
				If M->UI_TIPO == "I"
				               
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Monta script SQL e atribui resultado a workarea QRY    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					/*cQry := "SELECT		ZZE_PROD, " + ENTER
					cQry += "			B1_DESC, " + ENTER
					cQry += "	 		ZZE_QTDE, " + ENTER   
					cQry += "	 		D2_PRCVEN, " + ENTER   
					cQry += "	 		(ZZE_QTDE*D2_PRCVEN) TOTAL, " + ENTER   
					cQry += "	  		ZZE_LOTE, " + ENTER
					cQry += "	   		ZZE_VALID " + ENTER
					cQry += "FROM 		ZZE000 ZZE " + ENTER
					cQry += "LEFT JOIN	SB1000 SB1 " + ENTER
					cQry += "ON			SB1.D_E_L_E_T_ = '' " + ENTER
					cQry += "AND		B1_FILIAL = '' " + ENTER
					cQry += "AND		B1_COD = ZZE_PROD " + ENTER  
					cQry += "LEFT JOIN	" + RetSqlName("SD2") + " SD2 " + ENTER
					cQry += "ON			SD2.D_E_L_E_T_ = '' " + ENTER
					cQry += "AND		D2_FILIAL = '" + xFilial("SD2") + "' " + ENTER
					cQry += "AND		D2_DOC = '" + SF2->F2_DOC + "' " + ENTER
					cQry += "AND		D2_SERIE = '" + SF2->F2_SERIE + "' " + ENTER
					cQry += "AND		D2_CLIENTE = '" + SF2->F2_CLIENTE + "' " + ENTER
					cQry += "AND		D2_LOJA = '" + SF2->F2_LOJA + "' " + ENTER				
					cQry += "AND		D2_COD = ZZE_PROD " + ENTER								
					cQry += "WHERE 		ZZE.D_E_L_E_T_ = '' " + ENTER
					cQry += "AND  		ZZE_FILIAL = '" + xFilial("ZZE") + "' " + ENTER
					cQry += "AND   		ZZE_IDXCPO = 'D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA' " + ENTER
					cQry += "AND   		ZZE_IDXVAL = '" + SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) + "' " + ENTER
					cQry += "ORDER BY	ZZE_PROD, " + ENTER
					cQry += "			ZZE_LOTE " + ENTER	*/
					
					cQry :=	"SELECT	SD2.D2_COD AS PRODUTO_COD, " + ENTER
					cQry +=	"SB1.B1_DESC AS PRODUTO, " + ENTER
					cQry +=	"SD2.D2_QUANT AS QTDE, "
					cQry +=	"SD2.D2_PRCVEN AS PRCVEN, "
					cQry +=	"SD2.D2_TOTAL AS TOTAL, "
					cQry +=	"SD2.D2_LOTECTL AS LOTE, "
					cQry +=	"SD2.D2_DTVALID AS VALID "
					cQry +=	"FROM	" + RetSqlName("SD2") + " SD2 INNER JOIN "
					cQry +=	"		" +	RetSqlName("SB1") + " SB1 ON "
					cQry +=	"		SD2.D2_COD = SB1.B1_COD "
					cQry +=	"WHERE	SD2.D_E_L_E_T_ = '' "
				    cQry +=	"		AND SB1.D_E_L_E_T_ = '' "
				    cQry += "		AND	D2_FILIAL = '" + xFilial("SD2") + "' " + ENTER
					cQry += "		AND D2_DOC = '" + SF2->F2_DOC + "' " + ENTER
					cQry += "		AND D2_SERIE = '" + SF2->F2_SERIE + "' " + ENTER
					cQry += "		AND D2_CLIENTE = '" + SF2->F2_CLIENTE + "' " + ENTER
					cQry += "		AND D2_LOJA = '" + SF2->F2_LOJA + "' " + ENTER
				    cQry +=	"ORDER BY SD2.D2_COD, SD2.D2_LOTECTL "		
		
					If Select("FATX005G") > 0
						FATX005G->(dbCloseArea())
					EndIf
					
					TCQUERY cQry NEW ALIAS FATX005G
					
					dbSelectArea("FATX005G")

					FATX005G->(dbGoTop())
					                      
					If FATX005G->(!EoF())  
					
						aAdd(aCols, Array(Len(aHeader)+1))
						aCols[Len(aCols),(nHeader+1)] := .F.					
					
						Do While FATX005G->(!EoF())
						                                                                             
							aCols[Len(aCols),GdFieldPos("UJ_ITEM",aHeader)]		:= StrZero(Len(aCols),2,0)
							aCols[Len(aCols),GdFieldPos("UJ_PRODUTO",aHeader)]	:= FATX005G->PRODUTO_COD	//ZZE_PROD
							aCols[Len(aCols),GdFieldPos("UJ_VDESCRI",aHeader)]	:= FATX005G->PRODUTO		//B1_DESC
							aCols[Len(aCols),GdFieldPos("UJ_QTDE",aHeader)]		:= FATX005G->QTDE			//ZZE_QTDE
							aCols[Len(aCols),GdFieldPos("UJ_PRECO",aHeader)]	:= FATX005G->PRCVEN			//D2_PRCVEN
							aCols[Len(aCols),GdFieldPos("UJ_TOTAL",aHeader)]	:= FATX005G->TOTAL
							aCols[Len(aCols),GdFieldPos("UJ_LOTE",aHeader)]		:= FATX005G->LOTE			//ZZE_LOTE
							aCols[Len(aCols),GdFieldPos("UJ_VLDLOTE",aHeader)]	:= StoD(FATX005G->VALID)	//StoD(FATX005G->ZZE_VALID)
						     
							FATX005G->(dbSkip())    
							
							If FATX005G->(!EoF())
								aAdd(aCols, Array(Len(aHeader)+1))
								aCols[Len(aCols),(nHeader+1)] := .F.
							EndIf
							
						EndDo			
						
					EndIf
											
					oGetD1:SetArray(aCols)   
					oGetD1:ForceRefresh()
				
				EndIf
				
				
			EndIf			
			
		EndIf	     

		               
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Objetivo: Validar se produto pertence a nota fiscal                                      |
	//| Local   : Gatilho                                                                        | 
	//| Campo   : UJ_PRODUTO                                                                     | 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	Case nOpc == 4    		
	                
        xRet	:= GDFieldGet("UJ_PRODUTO")
        
		If M->UI_TIPO == "E"
	        		
			If !Empty(xRet)
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta script SQL e atribui resultado a workarea QRY    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQry := "SELECT		COUNT(1) REGS " + ENTER
		        cQry += "FROM		" + RetSqlName("SD2") + " SD2 " + ENTER
		        cQry += "WHERE		SD2.D_E_L_E_T_ = '' " + ENTER
		        cQry += "AND		D2_FILIAL = '" + xFilial("SD2") + "' " + ENTER
		        cQry += "AND		D2_COD = '" + xRet + "' " + ENTER		
		        cQry += "AND		D2_DOC = '" + Subs(M->UI_SNOTA,4,12) + "' " + ENTER
		        cQry += "AND		D2_SERIE = '" + Subs(M->UI_SNOTA,1,3) + "' " + ENTER      
		        cQry += "AND		D2_CLIENTE = '" + M->UI_CODCLI + "' " + ENTER      
		        cQry += "AND		D2_LOJA = '" + M->UI_LOJA + "' " + ENTER      
		
				If Select("FATX005G") > 0
					FATX005G->(dbCloseArea())
				EndIf
				
				TCQUERY cQry NEW ALIAS FATX005G
				
				dbSelectArea("FATX005G")         			
				     	
				If FATX005G->REGS == 0
					MsgStop("Produto não relacionado nesta nota fiscal!", "FATX005")
					xRet := ""
				EndIf
				
				FATX005G->(dbCloseArea())        
				
			EndIf			
		
		EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Objetivo: Buscar preco de venda utilizado na nf original                                 |
	//| Local   : Gatilho                                                                        | 
	//| Campo   : UJ_PRODUTO                                                                     | 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	Case nOpc == 5    		
	                
        xRet		:= 0       
        cProduto	:= GDFieldGet("UJ_PRODUTO")
              
        If M->UI_TIPO == "E"
        
	        If !Empty(cProduto)
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta script SQL e atribui resultado a workarea QRY    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQry := "SELECT		D2_PRCVEN " + ENTER
		        cQry += "FROM		" + RetSqlName("SD2") + " SD2 " + ENTER
		        cQry += "WHERE		SD2.D_E_L_E_T_ = '' " + ENTER
		        cQry += "AND		D2_FILIAL = '" + xFilial("SD2") + "' " + ENTER
		        cQry += "AND		D2_COD = '" + cProduto + "' " + ENTER		
		        cQry += "AND		D2_DOC = '" + Subs(M->UI_SNOTA,4,12) + "' " + ENTER
		        cQry += "AND		D2_SERIE = '" + Subs(M->UI_SNOTA,1,3) + "' " + ENTER      
		        cQry += "AND		D2_CLIENTE = '" + M->UI_CODCLI + "' " + ENTER      
		        cQry += "AND		D2_LOJA = '" + M->UI_LOJA + "' " + ENTER      
		
				If Select("FATX005G") > 0
					FATX005G->(dbCloseArea())
				EndIf
				
				TCQUERY cQry NEW ALIAS FATX005G
				
				dbSelectArea("FATX005G")         			
				     	
				If FATX005G->(!EoF())
					xRet := FATX005G->D2_PRCVEN
				EndIf
				
				FATX005G->(dbCloseArea())
						
			EndIf	
			
		EndIf
		
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Objetivo: Validar quantidade informada x quantidade nf original                          |
	//| Local   : Gatilho                                                                        | 
	//| Campo   : UJ_QTDE                                                                        | 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	Case nOpc == 6    		
	                
        xRet		:= GDFieldGet("UJ_QTDE")
	 	cProduto	:= GDFieldGet("UJ_PRODUTO")
                 
		If M->UI_TIPO == "E"

	        If !Empty(cProduto)
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta script SQL e atribui resultado a workarea QRY    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQry := "SELECT		D2_QUANT " + ENTER
		        cQry += "FROM		" + RetSqlName("SD2") + " SD2 " + ENTER
		        cQry += "WHERE		SD2.D_E_L_E_T_ = '' " + ENTER
		        cQry += "AND		D2_FILIAL = '" + xFilial("SD2") + "' " + ENTER
		        cQry += "AND		D2_COD = '" + cProduto + "' " + ENTER		
		        cQry += "AND		D2_DOC = '" + Subs(M->UI_SNOTA,4,12) + "' " + ENTER
		        cQry += "AND		D2_SERIE = '" + Subs(M->UI_SNOTA,1,3) + "' " + ENTER      
		        cQry += "AND		D2_CLIENTE = '" + M->UI_CODCLI + "' " + ENTER      
		        cQry += "AND		D2_LOJA = '" + M->UI_LOJA + "' " + ENTER      
		
				If Select("FATX005G") > 0
					FATX005G->(dbCloseArea())
				EndIf
				
				TCQUERY cQry NEW ALIAS FATX005G
				
				dbSelectArea("FATX005G")         			
				     	
				If FATX005G->(!EoF())
					If FATX005G->D2_QUANT < xRet
						MsgStop("Quantidade informada é maior do que a registrada na nota fiscal!", "FATX005")
						xRet := 0					
					EndIf
				EndIf
				
				FATX005G->(dbCloseArea())
						
			EndIf	  
		
		EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Objetivo: Totalizar valor devolvido                                                      |
	//| Local   : Gatilho                                                                        | 
	//| Campo   : UJ_QTDE                                                                        | 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	Case nOpc == 7   		
	                
        xRet		:= 0
  	 	nQtde		:= GDFieldGet("UJ_QTDE")
 	 	nPreco		:= GDFieldGet("UJ_PRECO")

        If !Empty(nQtde)
        	xRet := (nQtde * nPreco)
		EndIf									

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Objetivo: Buscar descricao do produto                                                    |
	//| Local   : Gatilho                                                                        | 
	//| Campo   : UJ_PRODUTO                                                                     | 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	Case nOpc == 8   		
	                
        xRet		:= ""
 	 	cProduto	:= GDFieldGet("UJ_PRODUTO")

        If !Empty(cProduto)
        	xRet := Posicione("SB1", 1, xFilial("SB1")+cProduto, "B1_DESC")
		EndIf
			  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Objetivo: Validar nome do usuario                                                        |
	//| Local   : Gatilho                                                                        | 
	//| Campo   : UI_USRACAO e UI_USRAUDI                                                        | 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	Case nOpc == 9   					                                                            

		xRet		:= RTrim(&(ReadVar()))

		PswOrder(2)
		If !PswSeek(xRet, .T.)
			MsgStop("Usuário inválido!")
			xRet := ""
		EndIf
								
EndCase

If Select("FATX005G") > 0
	FATX005G->(dbCloseArea())
EndIf

RestArea( aArea )

Return( xRet )



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FATX005Z  ºAutor  ³Alexandre Marson    º Data ³  25/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                              			                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
User Function FATX005Z()
   
Local cTitulo		:= ""

Local cField               
Local cMemVar		
Local cReadVar		:= AllTrim(ReadVar())
                            
Local cOpcoes		:= ""
Local aOpcoes		:= {}
                                            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define array conforme parametro da funcao              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	
//////////////////////

	Case cReadVar == "M->UI_INVMAQU"
		                            
		cTitulo	:= "MAQUINARIO"
		aOpcoes	:= aClone(aInvMaqu)
		cField	:= "UI_INVMAQU"          
		cOpcoes	:= "01020304"
		
//////////////////////

	Case cReadVar == "M->UI_INVMETO"

		cTitulo := "METODO"
		aOpcoes	:= aClone(aInvMeto)
		cField	:= "UI_INVMETO"
		cOpcoes	:= "01020304"

//////////////////////

	Case cReadVar == "M->UI_INVMEDI"
                          
		cTitulo := "MEDICAO"
		aOpcoes	:= aClone(aInvMedi)
		cField	:= "UI_INVMEDI"
		cOpcoes	:= "010203"

//////////////////////

	Case cReadVar == "M->UI_INVMATP"
                          
		cTitulo := "MATERIA PRIMA"
		aOpcoes	:= aClone(aInvMatP)
		cField	:= "UI_INVMATP"
		cOpcoes	:= "01020304"

//////////////////////

	Case cReadVar == "M->UI_INVMOBR"
                          
		cTitulo := "MAO DE OBRA"
		aOpcoes	:= aClone(aInvMObr)
		cField	:= "UI_INVMOBR"
		cOpcoes	:= "01020304"

//////////////////////

	Case cReadVar == "M->UI_INVMAMB"
                          
		cTitulo	:= "MEIO AMBIENTE"
		aOpcoes	:= aClone(aInvMAmb)
		cField	:= "UI_INVMAMB"
		cOpcoes	:= "01020304"

//////////////////////

	Otherwise
	
EndCase                                                            
                 
If Len(aOpcoes)>0 .And. cLastMVar <> cReadVar
           
	cLastMVar	:= cReadVar
	cMemVar		:= GetMemVar( cField )
	
	If f_Opcoes( @cMemVar, cTitulo, aOpcoes, cOpcoes, Nil, Nil, .F., 2, GetSx3Cache( cField , "X3_TAMANHO" ) )
		SetMemVar( cField, cMemVar )
	EndIf

Endif       

Return
       
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FATX005SXBºAutor  ³Alexandre Marson    º Data ³  25/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                              			                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FATX005W  ºAutor  ³Alexandre Marson    º Data ³  25/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                              			                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
User Function FATX005W()
Local cSrvMail  := AllTrim(GetMV("MV_RELSERV"))
Local cUserAut  := AllTrim(GetMV("MV_RELACNT")) 
Local cPassAut  := AllTrim(GetMV("MV_RELPSW")) 
Local cAuthent	:= AllTrim(GetMV("MV_RELAUTH"))
Local cDe       := "workflow@euroamerican.com.br"
Local cPara		:= ""
Local cMsg		:= "Email enviado automaticamente." + ENTER
Local cQry      := ""   
Local aUsrEmp	:= AllUsers()         
Local nX		:= 0                
Local cArqTxt	:= ""
Local nHdl		:= -1
Local cLin		:= ""     
Local nRec		:= 0
                  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dispara e-mail para o grupo ISO                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ          
cQry := "SELECT	UI_ATEND [NUMERO],																				" + ENTER
cQry +=	"		UI_EMISSAO [EMISSAO],																			" + ENTER
cQry +=	"		UI_TERMINO [TERMINO],																			" + ENTER
cQry +=	"		CASE 																							" + ENTER
cQry +=	"			WHEN UI_STATUS = '1' THEN 'ABERTO'															" + ENTER
cQry +=	"			WHEN UI_STATUS = '2' THEN 'EM ANALISE'														" + ENTER
cQry +=	"			WHEN UI_STATUS = '4' THEN 'NAO EFICAZ'														" + ENTER
cQry +=	"		END [STATUS],																					" + ENTER
cQry +=	"		CASE 																							" + ENTER
cQry +=	"			WHEN UI_TIPO = 'E' THEN 'EXTERNA'															" + ENTER
cQry +=	"			WHEN UI_TIPO = 'I' THEN 'INTERNA'															" + ENTER
cQry +=	"		END [TIPO],																						" + ENTER
cQry +=	"		UI_USRACAO [RESPONSAVEL],																		" + ENTER
cQry +=	"		UI_USRAUDI [AUDITOR],																			" + ENTER
//
cQry +=	"		CASE WHEN LEN(ISNULL(CONVERT(VARCHAR(150),CONVERT(VARBINARY(150),UI_NCONFOR)),''))>100			" + ENTER
cQry +=	"			THEN UPPER(ISNULL(CONVERT(VARCHAR(100),CONVERT(VARBINARY(100),UI_NCONFOR)),''))+'...'		" + ENTER
cQry +=	"			ELSE UPPER(ISNULL(CONVERT(VARCHAR(100),CONVERT(VARBINARY(100),UI_NCONFOR)),''))				" + ENTER
cQry +=	"		END [DESCRICAO]																					" + ENTER
//
cQry +=	"FROM																									" + ENTER
cQry +=	"		" + RetSqlName("SUI") + " SUI 																	" + ENTER
cQry +=	"INNER JOIN																								" + ENTER
cQry +=	"		" + RetSqlName("SB1") + " SB1 																	" + ENTER
cQry +=	"			ON SB1.D_E_L_E_T_ = ' '																		" + ENTER
cQry +=	"			AND UI_CODPROD = B1_COD																		" + ENTER
cQry +=	"WHERE	SUI.D_E_L_E_T_ = ' '																			" + ENTER 
cQry += "		AND UI_STATUS IN ('1','2','4')																	" + ENTER    
cQry += "ORDER BY																								" + ENTER    
cQry += "		UI_EMISSAO, UI_ATEND																			" + ENTER    

If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS QRY

dbSelectArea("QRY")	   

Count to nRec

If nRec > 0        
                
	cArqTxt := "\temp\FATX005_ISO.txt"
	nHdl    := fCreate(cArqTxt)  
	
	If nHdl == -1
		ConOut("FATX005W - O arquivo " + cArqTxt + " nao pode ser criado.")
		Return
	Endif   

	cLin    := "=====================================================================================================================================================" + ENTER
	cLin    += "NUMERO  EMISSAO   TERMINO   STATUS      TIPO     RESPONSAVEL                AUDITOR                    DESCRICAO                                     " + ENTER
	cLin    += "=====================================================================================================================================================" + ENTER	

	If fWrite(nHdl, cLin, Len(cLin)) != Len(cLin)
		ConOut("FATX005W - Ocorreu um erro na gravacao do arquivo.")
	Endif			

	dbGoTop()      

	While !QRY->(EoF())
		
		cLin := PadR(QRY->NUMERO,6)			+ Space(2) +;
				DtoC(StoD(QRY->EMISSAO))	+ Space(2) +;
				DtoC(StoD(QRY->TERMINO))	+ Space(2) +;
				PadR(QRY->STATUS,10) 		+ Space(2) +;
				PadR(QRY->TIPO,7) 			+ Space(2) +;
			    PadR(QRY->RESPONSAVEL,25)	+ Space(2) +;
			    PadR(QRY->AUDITOR,25) 		+ Space(2) +;
			    QRY->DESCRICAO				+ ENTER
	
		QRY->(dbSkip())
			                    
		If fWrite(nHdl, cLin, Len(cLin)) != Len(cLin)
			ConOut("FATX005W - Ocorreu um erro na gravacao do arquivo.")
		Endif			
			
	EndDo     		    
	
	cLin  := "=====================================================================================================================================" + ENTER
	cLin  += DtoC(dDataBase) + " " + Subs(Time(), 1, 5) + " - FATX005W - WORKFLOW DE NAO CONFORMIDADE 											   " + ENTER	
	cLin  += "=====================================================================================================================================" + ENTER
	
	If fWrite(nHdl, cLin, Len(cLin)) != Len(cLin)
		ConOut("FATX005W - Ocorreu um erro na gravacao do arquivo.")
	Endif
	                        
	fClose(nHdl)           
	
	QRY->(dbCloseArea())   
	
	cPara := "ti@euroamerican.com.br;" + "luana.aranega@euroamerican.com.br"// U_getUserGp("ISO-X00")      
	
	CONNECT SMTP SERVER cSrvMail ACCOUNT cUserAut PASSWORD cPassAut TIMEOUT 60 RESULT lOk
	
	If (lOk)        
		
		If cAuthent == ".T."
			MAILAUTH(cUserAut, cPassAut)
		EndIf
	
		SEND MAIL FROM cDe TO cPara ;
		SUBJECT "FATX005W - RELACAO DE NAO CONFORMIDADE";
		BODY cMsg;      
		ATTACHMENT cArqTxt;
		RESULT lOK     
		
		DISCONNECT SMTP SERVER
		
	Endif                   
	
	fErase(cArqTxt)

EndIf
         
If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf
                            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dispara e-mail para reponsavel ou auditor              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
For nX := 1 to Len(aUsrEmp)                            

	cQry := "SELECT	UI_ATEND [NUMERO],																				" + ENTER
	cQry +=	"		UI_EMISSAO [EMISSAO],																			" + ENTER
	cQry +=	"		UI_TERMINO [TERMINO],																			" + ENTER
	cQry +=	"		CASE 																							" + ENTER
	cQry +=	"			WHEN UI_STATUS = '1' THEN 'ABERTO'															" + ENTER
	cQry +=	"			WHEN UI_STATUS = '2' THEN 'EM ANALISE'														" + ENTER
	cQry +=	"			WHEN UI_STATUS = '4' THEN 'NAO EFICAZ'														" + ENTER
	cQry +=	"		END [STATUS],																					" + ENTER
	cQry +=	"		CASE 																							" + ENTER
	cQry +=	"			WHEN UI_TIPO = 'E' THEN 'EXTERNA'															" + ENTER
	cQry +=	"			WHEN UI_TIPO = 'I' THEN 'INTERNA'															" + ENTER
	cQry +=	"		END [TIPO],																						" + ENTER
	cQry +=	"		UPPER(UI_USRACAO) [RESPONSAVEL],																" + ENTER
	cQry +=	"		Upper(UI_USRAUDI) [AUDITOR],																	" + ENTER
	//
	cQry +=	"		CASE WHEN LEN(ISNULL(CONVERT(VARCHAR(150),CONVERT(VARBINARY(150),UI_NCONFOR)),''))>100			" + ENTER
	cQry +=	"			THEN UPPER(ISNULL(CONVERT(VARCHAR(100),CONVERT(VARBINARY(100),UI_NCONFOR)),''))+'...'		" + ENTER
	cQry +=	"			ELSE UPPER(ISNULL(CONVERT(VARCHAR(100),CONVERT(VARBINARY(100),UI_NCONFOR)),''))				" + ENTER
	cQry +=	"		END [DESCRICAO]																					" + ENTER
	//
	cQry +=	"FROM																									" + ENTER
	cQry +=	"		" + RetSqlName("SUI") + " SUI 																	" + ENTER
	cQry +=	"INNER JOIN																								" + ENTER
	cQry +=	"		" + RetSqlName("SB1") + " SB1 																	" + ENTER
	cQry +=	"			ON SB1.D_E_L_E_T_ = ' '																		" + ENTER
	cQry +=	"			AND UI_CODPROD = B1_COD																		" + ENTER
	cQry +=	"WHERE	SUI.D_E_L_E_T_ = ' '																			" + ENTER 
	cQry += "		AND UI_STATUS IN ('2','4')																		" + ENTER
	cQry += "		AND ( UI_USRACAO = '" + Upper(AllTrim(aUsrEmp[nX,1,2])) + "' OR UI_USRAUDI = '" + Upper(AllTrim(aUsrEmp[nX,1,2])) + "' )		" + ENTER           
	cQry += "ORDER BY																								" + ENTER    
	cQry += "		UI_EMISSAO, UI_ATEND																			" + ENTER         
	
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf
	
	TCQUERY cQry NEW ALIAS QRY
	
	dbSelectArea("QRY")	
	
	Count to nRec
	
	If nRec > 0
		
		cArqTxt := "\temp\FATX005_" + aUsrEmp[nX,1,1] + ".txt"
		nHdl    := fCreate(cArqTxt)  
		
		If nHdl == -1
			ConOut("FATX005W - O arquivo " + cArqTxt + " nao pode ser criado.")
			Return
		Endif   
					
		cLin    := "=====================================================================================================================================================" + ENTER
		cLin    += "NUMERO  EMISSAO   TERMINO   STATUS      TIPO     RESPONSAVEL                AUDITOR                    DESCRICAO                                     " + ENTER
		cLin    += "=====================================================================================================================================================" + ENTER
	                  
		If fWrite(nHdl, cLin, Len(cLin)) != Len(cLin)
			ConOut("FATX005W - Ocorreu um erro na gravacao do arquivo.")
		Endif			
	
		dbGoTop()      

		While !QRY->(EoF())

			cLin := PadR(QRY->NUMERO,6)			+ Space(2) +;
					DtoC(StoD(QRY->EMISSAO))	+ Space(2) +;
					DtoC(StoD(QRY->TERMINO))	+ Space(2) +;
					PadR(QRY->STATUS,10) 		+ Space(2) +;
					PadR(QRY->TIPO,7) 			+ Space(2) +;
				    PadR(QRY->RESPONSAVEL,25)	+ Space(2) +;
				    PadR(QRY->AUDITOR,25) 		+ Space(2) +;
				    QRY->DESCRICAO				+ ENTER
		
			QRY->(dbSkip())

			If fWrite(nHdl, cLin, Len(cLin)) != Len(cLin)
				ConOut("FATX005W - Ocorreu um erro na gravacao do arquivo.")
			Endif				
				
		EndDo     		    
		
		cLin  := "=====================================================================================================================================" + ENTER
		cLin  += DtoC(dDataBase) + " " + Subs(Time(), 1, 5) + " - FATX005W - WORKFLOW DE NAO CONFORMIDADE 											   " + ENTER	
		cLin  += "=====================================================================================================================================" + ENTER
		
		If fWrite(nHdl, cLin, Len(cLin)) != Len(cLin)
			ConOut("FATX005W - Ocorreu um erro na gravacao do arquivo.")
		Endif
		                        
		fClose(nHdl)           
		
		QRY->(dbCloseArea())   
		
		cPara := AllTrim(aUsrEmp[nX,1,14])
		
		CONNECT SMTP SERVER cSrvMail ACCOUNT cUserAut PASSWORD cPassAut TIMEOUT 60 RESULT lOk
		
		If (lOk)        
			
			If cAuthent == ".T."
				MAILAUTH(cUserAut, cPassAut)
			EndIf
			
			SEND MAIL FROM cDe TO cPara ;
			SUBJECT "FATX005W - RELACAO DE NAO CONFORMIDADE";
			BODY cMsg;      
			ATTACHMENT cArqTxt;
			RESULT lOK     
			
			DISCONNECT SMTP SERVER
			
		Endif
	
	EndIf
	
	fErase(cArqTxt)
	
Next nX            

If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

Return 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FATX005I  ºAutor  ³Alexandre Marson    º Data ³  25/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                              			                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
User Function FATX005I(cAlias,nReg,nOpc)

Local aArea			:= GetArea()

Local lOk	    	:= .F.

Local nx

Local cArray		:= ""


Private nLin		:= 0
Private nCol		:= 0

Private oFont06  	:= TFont():New( "Arial"             ,,06     ,,.F.,,,,,.F.) 

Private oFont07  	:= TFont():New( "Arial"             ,,07     ,,.F.,,,,,.F.) 
Private oFont07B  	:= TFont():New( "Arial"             ,,07     ,,.T.,,,,,.F.) 

Private oFont10		:= TFont():New( "Arial"             ,,10     ,,.F.,,,,,.F.)
Private oFont10B	:= TFont():New( "Arial"             ,,10     ,,.T.,,,,,.F.)

Private oBrush		:= TBrush():New(,RGB(218, 218, 218))
Private oPen		:= TPen():New(0,100,CLR_BLACK)

Private oPrint		:= Nil

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                                 
oPrint := PcoPrtIni(cCadastro, .F., 2,, @lOk)                                        
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                                 
If lOk

	oPrint:SetPaperSize(9)	//Papel A4
	oPrint:SetPortrait()	//Retrato

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	fCabecalho()
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	     
	oPrint:Say( nLin, 0070, "Emissor:", oFont07B,,,,)
	oPrint:Say( nLin, 0200, Upper(AllTrim(SUI->UI_INCLUI)), oFont07,,,,)

	oPrint:Say( nLin, 0844, "Início:", oFont07B,,,,)
	oPrint:Say( nLin, 1010, DtoC(SUI->UI_EMISSAO), oFont07,,,,)    
	
	oPrint:Say( nLin, 1600, "Término:", oFont07B,,,,)
	oPrint:Say( nLin, 1785, DtoC(SUI->UI_TERMINO), oFont07,,,,)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	nLin+=40
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	oPrint:Say( nLin, 0070, "Cliente:", oFont07B,,,,)
	oPrint:Say( nLin, 0200, SUI->UI_CODCLI+"-"+SUI->UI_LOJA, oFont07,,,,)    
	oPrint:Say( nLin, 0360, "( " + AllTrim(UI_NOMECLI)+" )", oFont06,,,,)
	
	oPrint:Say( nLin, 0844, "Origem:", oFont07B,,,,)
	oPrint:Say( nLin, 1010, IIf(SUI->UI_TIPO=="I","INTERNA","EXTERNA"), oFont07,,,,)
	
	oPrint:Say( nLin, 1600, "Nota Fiscal:", oFont07B,,,,)
	oPrint:Say( nLin, 1785, SUI->UI_SNOTA, oFont07,,,,)    
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////   
	nLin+=40
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	oPrint:Say( nLin, 0070, "Produto:", oFont07B,,,,)
	oPrint:Say( nLin, 0200, AllTrim(SUI->UI_CODPROD), oFont07,,,,)
	oPrint:Say( nLin, 0360, "( " + AllTrim(Posicione("SB1",1,xFilial("SB1")+SUI->UI_CODPROD,"B1_DESC"))+" )", oFont06,,,,)

	oPrint:Say( nLin, 0844, "Quantidade:", oFont07B,,,,)
	oPrint:Say( nLin, 1010, Transform(SUI->UI_QTDE, PesqPict("SUI","UI_QTDE")), oFont07,,,,)    
	
	oPrint:Say( nLin, 1600, "Lote:", oFont07B,,,,)
	oPrint:Say( nLin, 1785, SUI->UI_LOTE, oFont07,,,,)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	nLin+=80
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	oPrint:Say( nLin, 0070, "Avalidor:", oFont07B,,,,)
	oPrint:Say( nLin, 0200, Upper(AllTrim(SUI->UI_USRAVAL)), oFont07,,,,)

	oPrint:Say( nLin, 0844, "Reponsável:", oFont07B,,,,)
	oPrint:Say( nLin, 1010, Upper(AllTrim(SUI->UI_USRACAO)), oFont07,,,,)    
	
	oPrint:Say( nLin, 1600, "Auditor:", oFont07B,,,,)
	oPrint:Say( nLin, 1785, Upper(AllTrim(SUI->UI_USRAUDI)), oFont07,,,,)                       
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	nLin+=80
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	oPrint:FillRect({nLin, 0070, (nLin+0040), 2330}, oBrush)
	oPrint:Say( (nLin+0005), 0070, "[ ITEM ]", oFont07B,,,,)	
	oPrint:Say( (nLin+0005), 0150, "[ PRODUTO ]", oFont07B,,,,)
	oPrint:Say( (nLin+0005), 0450, "[ DESCRICAO ]", oFont07B,,,,)	

	oPrint:Say( (nLin+0005), 1200, "[ QUANT. ]", oFont07B,,,,)	
	oPrint:Say( (nLin+0005), 1500, "[ PRECO ]", oFont07B,,,,)	
	oPrint:Say( (nLin+0005), 1800, "[ TOTAL ]", oFont07B,,,,)	
	oPrint:Say( (nLin+0005), 2000, "[ LOTE ]", oFont07B,,,,)	
	oPrint:Say( (nLin+0005), 2200, "[ VALIDADE ]", oFont07B,,,,)	

	nLin+=60
	nCol:=190

    DbSelectArea("SUJ")
	("SUJ")->( DbSetOrder(1) )
	IF ("SUJ")->( DBSEEK( xFilial("SUJ")+SUI->UI_ATEND+"SUI",.T.) )
// UJ_ITEM,UJ_PRODUTO,B1_DESC,UJ_QTDE,UJ_PRECO,UJ_TOTAL,UJ_LOTE,UJ_VLDLOTE
       While ("SUJ")->( !EOF()) .AND. SUJ->UJ_CODIGO = SUI->UI_ATEND 
				oPrint:Say( nLin, 0090, ("SUJ")->UJ_ITEM, oFont07,,,,) 
				oPrint:Say( nLin, 0160, ("SUJ")->UJ_PRODUTO, oFont07,,,,) 
				oPrint:Say( nLin, 0450, POSICIONE("SB1",1,xFilial("SB1")+("SUJ")->UJ_PRODUTO,"B1_DESC"), oFont07,,,,) 

				oPrint:Say( nLin, 1200, TRANSFORM(("SUJ")->UJ_QTDE,"@e 9999.999"), oFont07,,,,) 
				oPrint:Say( nLin, 1500, TRANSFORM(("SUJ")->UJ_PRECO,"@e  9,999,999.99"), oFont07,,,,) 
				oPrint:Say( nLin, 1800, TRANSFORM(("SUJ")->UJ_TOTAL,"@e  9,999,999.99"), oFont07,,,,) 
				oPrint:Say( nLin, 2000, ("SUJ")->UJ_LOTE, oFont07,,,,) 
				oPrint:Say( nLin, 2200, dtos(("SUJ")->UJ_VLDLOTE), oFont07,,,,) 
			
				If nLin > 3000 
					oPrint:EndPage()		
					fCabecalho()
					oPrint:StartPage()  
				EndIf			
                nLin+=60
          ("SUJ")->( DBSKIP() )
	   END 
	endif
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	nLin+=80
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 	oPrint:FillRect({nLin, 0070, (nLin+0040), 2330}, oBrush)
	oPrint:Say( (nLin+0005), 0080, "[ DESCRIÇÃO DA NÃO CONFORMIDADE ( O QUE, QUANDO, COMO, ONDE ) ]", oFont07B,,,,)

	nLin+=60
	nCol:=190

	For nX := 1 To MlCount(SUI->UI_NCONFOR, nCol)
		oPrint:Say( nLin, 0070, MemoLine(SUI->UI_NCONFOR, nCol, nX), oFont07,,,,) 

		nLin += 40 

		If nLin > 3000 
			oPrint:EndPage()		
			fCabecalho()
			oPrint:StartPage()  
		EndIf			
	Next 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	nLin+=40

	If nLin > 3000 
		oPrint:EndPage()		
		fCabecalho()
		oPrint:StartPage()  
	EndIf	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                  
 	oPrint:FillRect({nLin, 0070, (nLin+0040), 2330}, oBrush)
	oPrint:Say( (nLin+0005), 0080, "[ AÇÃO IMEDIATA E DISPOSIÇÃO DO ITEM NÃO CONFORME ]", oFont07B,,,,)

	nLin+=60
	nCol:=190

	For nX := 1 To MlCount(SUI->UI_ACAO, nCol)
		oPrint:Say( nLin, 0070, MemoLine(SUI->UI_ACAO, nCol, nX), oFont07,,,,) 

		nLin += 40

		If nLin > 3000 
			oPrint:EndPage()		
			fCabecalho()
			oPrint:StartPage()  
		EndIf	
	Next 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	nLin+=40   

	If nLin > 3000 
		oPrint:EndPage()		
		fCabecalho()
		oPrint:StartPage()  
	EndIf	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 	oPrint:FillRect({nLin, 0070, (nLin+0040), 2330}, oBrush)
	oPrint:Say( (nLin+0005), 0080, "[ ANÁLISE DA NÃO CONFORMIDADE ]", oFont07B,,,,)

	nLin+=60
                                           
	oPrint:Say( nLin, 0070, "Devolução:", oFont07B,,,,)
	oPrint:Say( nLin, 0200, If(SUI->UI_DEVOLUC=="1","SIM (TECNICA)", IIf(SUI->UI_DEVOLUC=="2", "SIM (COMERCIAL)", "NÃO") ), oFont07,,,,)

	oPrint:Say( nLin, 0844, "Procede:", oFont07B,,,,)
	oPrint:Say( nLin, 1010, IIf(SUI->UI_PROCEDE=="1","SIM","NAO"), oFont07,,,,)    
	
	oPrint:Say( nLin, 1600, "Problema:", oFont07B,,,,)
	oPrint:Say( nLin, 1785, IIf(SUI->UI_PROBLEM=="R","REAL","POTENCIAL"), oFont07,,,,)    
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                             
	nLin+=80

	If nLin > 3000 
		oPrint:EndPage()		
		fCabecalho()
		oPrint:StartPage()  
	EndIf
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                             	
 	oPrint:FillRect({nLin, 0070, (nLin+0040), 2330}, oBrush)
	oPrint:Say( (nLin+0005), 0080, "[ INVESTIGAÇÃO DAS POSSÍVEIS CAUSAS ]", oFont07B,,,,)

	nLin+=60

	cArray := ""
	For nX := 1 To Len(aInvMaqu)
		
		If AT(Substr(aInvMaqu[nX],1,2), SUI->UI_INVMAQU) > 0
			cArray := cArray + " / " + Upper(AllTrim(Substr(aInvMaqu[nX], 4, Len(aInvMaqu[nX]))))
		EndIf
	Next    
	cArray := Substr(cArray,3, Len(cArray))

	oPrint:Say( nLin, 0070, "Maquinário:", oFont07B,,,,)
	oPrint:Say( nLin, 0270, cArray, oFont07,,,,)

	nLin+=40

	cArray := ""
	For nX := 1 To Len(aInvMeto)
		
		If AT(Substr(aInvMeto[nX],1,2), SUI->UI_INVMETO) > 0
			cArray := cArray + " / " + Upper(AllTrim(Substr(aInvMeto[nX], 4, Len(aInvMeto[nX]))))
		EndIf
	Next    
	cArray := Substr(cArray,3, Len(cArray))

	oPrint:Say( nLin, 0070, "Método:", oFont07B,,,,)
	oPrint:Say( nLin, 0270, cArray, oFont07,,,,)

	nLin+=40

	cArray := ""
	For nX := 1 To Len(aInvMedi)
		
		If AT(Substr(aInvMedi[nX],1,2), SUI->UI_INVMEDI) > 0
			cArray := cArray + " / " + Upper(AllTrim(Substr(aInvMedi[nX], 4, Len(aInvMedi[nX]))))
		EndIf
	Next    
	cArray := Substr(cArray,3, Len(cArray))

	oPrint:Say( nLin, 0070, "Medição:", oFont07B,,,,)
	oPrint:Say( nLin, 0270, cArray, oFont07,,,,)
                      
	nLin+=40

	cArray := ""
	For nX := 1 To Len(aInvMatP)
		
		If AT(Substr(aInvMatP[nX],1,2), SUI->UI_INVMATP) > 0
			cArray := cArray + " / " + Upper(AllTrim(Substr(aInvMatP[nX], 4, Len(aInvMatP[nX]))))
		EndIf
	Next    
	cArray := Substr(cArray,3, Len(cArray))

	oPrint:Say( nLin, 0070, "Matéria Prima:", oFont07B,,,,)
	oPrint:Say( nLin, 0270, cArray, oFont07,,,,)
       
	nLin+=40

	cArray := ""
	For nX := 1 To Len(aInvMObr)
		
		If AT(Substr(aInvMObr[nX],1,2), SUI->UI_INVMOBR) > 0
			cArray := cArray + " / " + Upper(AllTrim(Substr(aInvMObr[nX], 4, Len(aInvMObr[nX]))))
		EndIf
	Next    
	cArray := Substr(cArray,3, Len(cArray))

	oPrint:Say( nLin, 0070, "Mão de Obra:", oFont07B,,,,)
	oPrint:Say( nLin, 0270, cArray, oFont07,,,,)

	nLin+=40

	cArray := ""
	For nX := 1 To Len(aInvMAmb)
		
		If AT(Substr(aInvMAmb[nX],1,2), SUI->UI_INVMAMB) > 0
			cArray := cArray + " / " + Upper(AllTrim(Substr(aInvMAmb[nX], 4, Len(aInvMAmb[nX]))))
		EndIf
	Next    
	cArray := Substr(cArray,3, Len(cArray))

	oPrint:Say( nLin, 0070, "Meio Ambiente:", oFont07B,,,,)
	oPrint:Say( nLin, 0270, cArray, oFont07,,,,)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                                 
	nLin+=40       
	
	If nLin > 3000 
		oPrint:EndPage()		
		fCabecalho()
		oPrint:StartPage()  
	EndIf	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                             
 	oPrint:FillRect({nLin, 0070, (nLin+0040), 2330}, oBrush)
	oPrint:Say( (nLin+0005), 0080, "[ OCORRÊNCIA OU EFEITO INDESEJADO ]", oFont07B,,,,)

	nLin+=60
	nCol:=190

	For nX := 1 To MlCount(SUI->UI_ANALISE, nCol)
		oPrint:Say( nLin, 0070, MemoLine(SUI->UI_ANALISE, nCol, nX), oFont07,,,,) 

		nLin += 40

		If nLin > 3000 
			oPrint:EndPage()		
			fCabecalho()
			oPrint:StartPage()  
		EndIf	
	Next 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                                 
	nLin+=40       
	
	If nLin > 3000 
		oPrint:EndPage()		
		fCabecalho()
		oPrint:StartPage()  
	EndIf	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                             
 	oPrint:FillRect({nLin, 0070, (nLin+0040), 2330}, oBrush)
	oPrint:Say( (nLin+0005), 0080, "[ DETALHAMENTO DA CAUSA RAIZ ]", oFont07B,,,,)

	nLin+=60
	nCol:=190

	For nX := 1 To MlCount(SUI->UI_CAUSA, nCol)
		oPrint:Say( nLin, 0070, MemoLine(SUI->UI_CAUSA, nCol, nX), oFont07,,,,) 

		nLin += 40

		If nLin > 3000 
			oPrint:EndPage()		
			fCabecalho()
			oPrint:StartPage()  
		EndIf	
	Next 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                                 
	nLin+=40       
	
	If nLin > 3000 
		oPrint:EndPage()		
		fCabecalho()
		oPrint:StartPage()  
	EndIf	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                             
 	oPrint:FillRect({nLin, 0070, (nLin+0040), 2330}, oBrush)
	oPrint:Say( (nLin+0005), 0080, "[ GRUPO PARTICIPANTE NA INVESTIGAÇÃO DAS POSS´VEIS CAUSAS ]", oFont07B,,,,)

	nLin+=60
	nCol:=190

	For nX := 1 To MlCount(SUI->UI_GRPINVE, nCol)
		oPrint:Say( nLin, 0070, MemoLine(SUI->UI_GRPINVE, nCol, nX), oFont07,,,,) 

		nLin += 40

		If nLin > 3000 
			oPrint:EndPage()		
			fCabecalho()
			oPrint:StartPage()  
		EndIf	
	Next 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                                 
	nLin+=40       
	
	If nLin > 3000 
		oPrint:EndPage()		
		fCabecalho()
		oPrint:StartPage()  
	EndIf	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                             
 	oPrint:FillRect({nLin, 0070, (nLin+0040), 2330}, oBrush)
	oPrint:Say( (nLin+0005), 0080, "[ PLANO DE AÇÃO ]", oFont07B,,,,)

	nLin+=60
	nCol:=190

	For nX := 1 To MlCount(SUI->UI_PLANO, nCol)
		oPrint:Say( nLin, 0070, MemoLine(SUI->UI_PLANO, nCol, nX), oFont07,,,,) 

		nLin += 40

		If nLin > 3000 
			oPrint:EndPage()		
			fCabecalho()
			oPrint:StartPage()  
		EndIf	
	Next 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                                 
	nLin+=40       
	
	If nLin > 3000 
		oPrint:EndPage()		
		fCabecalho()
		oPrint:StartPage()  
	EndIf	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                             
 	oPrint:FillRect({nLin, 0070, (nLin+0040), 2330}, oBrush)
	oPrint:Say( (nLin+0005), 0080, "[ ACOMPANHAMENTO DAS AÇÕES CORRETIVAS ]", oFont07B,,,,)

	nLin+=60         
	
	oPrint:Say( nLin, 0070, "Ação Corretiva/Preventiva foi Implantada:", oFont07B,,,,)
	oPrint:Say( nLin, 0600, IIf(SUI->UI_IMPLANT=="1","SIM","NÃO"), oFont07,,,,)	
	
	nLin+=50
	nCol:=190
	For nX := 1 To MlCount(SUI->UI_DETIMPL, nCol)
		oPrint:Say( nLin, 0070, MemoLine(SUI->UI_DETIMPL, nCol, nX), oFont07,,,,) 

		nLin += 40

		If nLin > 3000 
			oPrint:EndPage()		
			fCabecalho()
			oPrint:StartPage()  
		EndIf	
	Next 

	nLin+=40

	oPrint:Say( nLin, 0070, "Ação Corretiva/Preventiva foi Eficaz:", oFont07B,,,,)
	oPrint:Say( nLin, 0600, IIf(SUI->UI_EFICAZ=="1","SIM","NÃO"), oFont07,,,,)	
	
	nLin+=50
	nCol:=190
	For nX := 1 To MlCount(SUI->UI_DETEFIC, nCol)
		oPrint:Say( nLin, 0070, MemoLine(SUI->UI_DETEFIC, nCol, nX), oFont07,,,,) 

		nLin += 40

		If nLin > 3000
			oPrint:EndPage()		
			fCabecalho()
			oPrint:StartPage()  
		EndIf	
	Next 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                                 
	PcoPrtEnd(oPrint)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                                 
EndIf

RestArea( aArea )

Return        

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fCabecalhoºAutor  ³Alexandre Marson    º Data ³  25/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                              			                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Static Function fCabecalho()

Local cLogo	:= "EURO.BMP"

nLin:=42

oPrint:SayBitmap( nLin, 0080, cLogo, 0236, 0151)

nLin+=40
             
oPrint:Say( nLin, 0950, "RELATÓRIO DE NÃO CONFORMIDADE", oFont10B,,,,)

nLin+=40

oPrint:Say( nLin, 1200, "(RNC)", oFont10B,,,,)
oPrint:Say( nLin, 2050, "Nº " + SUI->UI_ATEND, oFont10B,,,,)

nLin+=0150

oPrint:Box( 0045, 0070, 200, 2330, oPen )

Return


/*/{Protheus.doc} fDocumentos
description
@type function
@version  
@author paulo.lenzi
@since 26/05/2023
@return variant, return_description
/*/
User Function fDocumentos()
	Local lRet := .t.
	Local aRecACB := {}
	Local cAlias := "SUI"
	Local nReg := SUI->(Recno())
	Local nOpc := 4
	Local xVar := Nil
	Local lExcelConnect := .F.
	lRet := MsDocument(cAlias, nReg, nOpc, xVar, /*nOper*/, @aRecACB, lExcelConnect)
	If lRet
	EndIf
Return lRet
