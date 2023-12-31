#include "rwmake.ch"
#include "topconn.ch"        
#include "tbiconn.ch"   
#include "protheus.ch"  
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GENC001   � Autor �Tiago O. Beraldi    � Data �  23/07/07   ���
�������������������������������������������������������������������������͹��
���Descricao �FILTRO PARA CONSULTA SXB->SB1                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function GENC001()                                                 

//���������������������������������������������������������������������Ŀ
//|Declaracao de variaveis                                              �
//�����������������������������������������������������������������������  
Local cFiltro := ""

//���������������������������������������������������������������������Ŀ
//|Filtra SXB - Consulta SB1                                            | 
//�����������������������������������������������������������������������
// Pedidos de Vendas / Saidas
If Upper(Alltrim(FunName())) $ "MATA410#MATA415" 
	If AllTrim(cFilAnt) $ "0200#0201#0205"
		cFiltro := "@B1_MSBLQL <> '1' AND SUBSTRING(B1_GRUPO,1,1) = '1'" 
	ElseIf AllTrim(cFilAnt) $ "0203#0107#0108" 
		cFiltro := "@B1_MSBLQL <> '1' AND SUBSTRING(B1_GRUPO,1,1) = '3' AND B1_TIPO = 'PA'" 
	EndIf
EndIf     
                             
// Aviso de Recebimento
If Upper(Alltrim(FunName())) == "MATA145" 
	cFiltro := "@B1_MSBLQL <> '1' AND B1_TIPO NOT IN ('PA','PI')
EndIf

Return cFiltro