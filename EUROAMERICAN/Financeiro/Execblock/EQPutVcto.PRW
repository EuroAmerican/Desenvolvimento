#include 'protheus.ch'
#Include 'RwMake.Ch'
#Include 'ApWizard.Ch'
#include 'topconn.ch'
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �BePutVcto � Autor � Rodrigo Sousa         � Data �21.10.2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualiza��o do parametro MV_BEDVCTO    		  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function EQPutVcto()

Local nMvEQDVcto 	:= SuperGetMv("MV_EQDVCTO",,0)
Local aPerg			:= {}
Local aParam    	:= {nMvEQDVcto}
Local cRetorno		:= ""
Local cTexto		:= ""

cTexto 	:= "Essa rotina tem como objetivo alterar a data minima para vencimento "
cTexto	+= "de titulos a pagar de acordo com as informa��es informadas nos par�metros."

//������������������������������������������������������������������������Ŀ
//� Carrega perguntas													   �
//��������������������������������������������������������������������������
aadd(aPerg,{1,"Vencto Minimo (Dias)"	,aParam[01]			,"@E 99999","Positivo()","",".T.",30,.T.})				//"Nota fiscal inicial"

//������������������������������������������������������������������������Ŀ
//� Montagem da Interface                                                  �
//��������������������������������������������������������������������������
DEFINE WIZARD oWizard ;
	TITLE "Assistente para altera��o de data minima para vencimento de titulos a pagar";
	HEADER "Aten��o";
	MESSAGE "Siga atentamente os pasos a seguir";
	TEXT cTexto ;
	NEXT {|| .T.} ;
	FINISH {||.T.}

CREATE PANEL oWizard  ;
	HEADER "Aten��o" ;
	MESSAGE "Preencha os par�metros atentamente."	;
	BACK {|| .T.} ;
	NEXT {|| Processa({|lEnd| cRetorno := EQProcPut(aParam[1],nMvEQDVcto)}),,.T.} ;
	PANEL 
	ParamBox(aPerg,"Vencto Minimo (Dias) - CP",@aParam,,,,,,oWizard:oMPanel[2],,.F.,.F.)

CREATE PANEL oWizard  ;
	HEADER "Aten��o";
	MESSAGE "Fim do Processamento";
	BACK {|| .T.} ;
	FINISH {|| .T.} ;
	PANEL 
	@ 010,010 GET cRetorno MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[3] 

ACTIVATE WIZARD oWizard CENTERED

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BeProcPut �Autor  �Rodrigo Sousa       � Data �  26/04/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Processa Atualiza��o										  ���
���     	 � Parametros:										  		  ���
���     	 � nPar1 := Conteudo Atualizado								  ���
���     	 � nPar2 := Conteudo Anterior								  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EQProcPut(nDiasAtu,nDiasAnt)

Local dDtVcto	

Local nDiasAux	:= nDiasAtu
Local cRetorno	:= ""  

If nDiasAtu <> nDiasAnt

	PutMv("MV_EQDVCTO",nDiasAtu)

	//������������������������������������������������������������������������Ŀ
	//� Busca Data de Vencimento Permitidas a partir da data base do sistema   �
	//��������������������������������������������������������������������������
	dDtVcto := dDataBase + nDiasAtu
	
	//������������������������������������������������������������������������Ŀ
	//� Mensagem final														   �
	//��������������������������������������������������������������������������
	cRetorno	:= "Aten��o!"+CRLF+CRLF
	cRetorno	+= "Altera��o concluida com sucesso!"+CRLF+CRLF
	cRetorno	+= "Empresa: "+Alltrim(SM0->M0_NOME)+" - Filial: "+Alltrim(SM0->M0_CODFIL)+" - "+SM0->M0_FILIAL+CRLF
	cRetorno	+= "Data Base: "+DtoC(dDataBase)+CRLF
	cRetorno	+= "Dias p/ Vencto.: "+Alltrim(Str(nDiasAtu))+CRLF
	cRetorno	+= "Vencto. Permitido para a Data Base: "+DtoC(dDtVcto)+CRLF+CRLF

Else
	cRetorno	:= "Aten��o!"+CRLF+CRLF
	cRetorno	+= "N�o Houveram altera��es no Conte�do do Par�metro!"+CRLF+CRLF
EndIf

Return cRetorno

