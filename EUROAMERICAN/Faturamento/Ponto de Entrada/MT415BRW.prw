#include "protheus.ch"
//#include "rwmake.ch"
#include "topconn.ch"
//#include "tbiconn.ch"
//#include "totvs.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MT415BRW � Autor �Emerson Paiva       � Data �  12/12/17   ���
�������������������������������������������������������������������������͹��
���Descricao � Filtrar Browse Or�amentos de Vendas                        ���
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
User Function MT415BRW() 

	Local cFiltro  := ""
		If	!UPPER(cUserName)  $ SuperGetMV("ES_MT415BR", .T., .F.) //"Administrator#Alessandra.Monea#Thiago.Monea#Robson.Moraes#Joelita.Silva#Luciana.Mota#Daiane.Gomes#Kely.Souza#Eunice.Godoy#Tatiane.Paz#Marcia.Oliveira" // ! Vendedores externos
			cFiltro := "CJ_COD $ '" + U_FATX008V() + "'"
		EndIf

Return cFiltro
