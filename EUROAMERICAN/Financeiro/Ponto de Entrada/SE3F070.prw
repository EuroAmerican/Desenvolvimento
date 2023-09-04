#include "Colors.ch"
#include "Protheus.ch"
#include "RwMake.ch"
#Include "TOPCONN.CH" 
#Include "FWMVCDEF.CH"
/*/{Protheus.doc} SE3F070
//Atualiza Percentual e base de Comissão 
@type function Rotina customizada 
@Autor Fabio Carneiro 
@since 19/09/2022
@version 1.0
@return  Logical, retorno verdadeiro
/*/
User Function SE3F070()

Local aAreaSE1 := SE1->(GetArea())
Local aAreaSE5 := SE5->(GetArea())
Local lret     := .T.

DbSelectArea("SE1")
DbSetOrder(1)  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
If SE1->(dbSeek(xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)) 
					
	Reclock("SE1",.F.)
	SE1->E1_BASCOM1    := SE1->E1_XBASCOM
	SE1->E1_COMIS1     := SE1->E1_XCOM1 
	SE1->( Msunlock() )
					
EndIf

RestArea(aAreaSE1)
RestArea(aAreaSE5)

Return lret
