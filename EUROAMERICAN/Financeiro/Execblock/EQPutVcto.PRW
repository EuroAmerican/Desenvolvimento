#include 'protheus.ch'
#Include 'RwMake.Ch'
#Include 'ApWizard.Ch'
#include 'topconn.ch'
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³BePutVcto ³ Autor ³ Rodrigo Sousa         ³ Data ³21.10.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualização do parametro MV_BEDVCTO    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function EQPutVcto()

Local nMvEQDVcto 	:= SuperGetMv("MV_EQDVCTO",,0)
Local aPerg			:= {}
Local aParam    	:= {nMvEQDVcto}
Local cRetorno		:= ""
Local cTexto		:= ""

cTexto 	:= "Essa rotina tem como objetivo alterar a data minima para vencimento "
cTexto	+= "de titulos a pagar de acordo com as informações informadas nos parâmetros."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega perguntas													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aPerg,{1,"Vencto Minimo (Dias)"	,aParam[01]			,"@E 99999","Positivo()","",".T.",30,.T.})				//"Nota fiscal inicial"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da Interface                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE WIZARD oWizard ;
	TITLE "Assistente para alteração de data minima para vencimento de titulos a pagar";
	HEADER "Atenção";
	MESSAGE "Siga atentamente os pasos a seguir";
	TEXT cTexto ;
	NEXT {|| .T.} ;
	FINISH {||.T.}

CREATE PANEL oWizard  ;
	HEADER "Atenção" ;
	MESSAGE "Preencha os parâmetros atentamente."	;
	BACK {|| .T.} ;
	NEXT {|| Processa({|lEnd| cRetorno := EQProcPut(aParam[1],nMvEQDVcto)}),,.T.} ;
	PANEL 
	ParamBox(aPerg,"Vencto Minimo (Dias) - CP",@aParam,,,,,,oWizard:oMPanel[2],,.F.,.F.)

CREATE PANEL oWizard  ;
	HEADER "Atenção";
	MESSAGE "Fim do Processamento";
	BACK {|| .T.} ;
	FINISH {|| .T.} ;
	PANEL 
	@ 010,010 GET cRetorno MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[3] 

ACTIVATE WIZARD oWizard CENTERED

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BeProcPut ºAutor  ³Rodrigo Sousa       º Data ³  26/04/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processa Atualização										  º±±
±±º     	 ³ Parametros:										  		  º±±
±±º     	 ³ nPar1 := Conteudo Atualizado								  º±±
±±º     	 ³ nPar2 := Conteudo Anterior								  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EQProcPut(nDiasAtu,nDiasAnt)

Local dDtVcto	

Local nDiasAux	:= nDiasAtu
Local cRetorno	:= ""  

If nDiasAtu <> nDiasAnt

	PutMv("MV_EQDVCTO",nDiasAtu)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca Data de Vencimento Permitidas a partir da data base do sistema   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dDtVcto := dDataBase + nDiasAtu
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mensagem final														   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRetorno	:= "Atenção!"+CRLF+CRLF
	cRetorno	+= "Alteração concluida com sucesso!"+CRLF+CRLF
	cRetorno	+= "Empresa: "+Alltrim(SM0->M0_NOME)+" - Filial: "+Alltrim(SM0->M0_CODFIL)+" - "+SM0->M0_FILIAL+CRLF
	cRetorno	+= "Data Base: "+DtoC(dDataBase)+CRLF
	cRetorno	+= "Dias p/ Vencto.: "+Alltrim(Str(nDiasAtu))+CRLF
	cRetorno	+= "Vencto. Permitido para a Data Base: "+DtoC(dDtVcto)+CRLF+CRLF

Else
	cRetorno	:= "Atenção!"+CRLF+CRLF
	cRetorno	+= "Não Houveram alterações no Conteúdo do Parâmetro!"+CRLF+CRLF
EndIf

Return cRetorno

