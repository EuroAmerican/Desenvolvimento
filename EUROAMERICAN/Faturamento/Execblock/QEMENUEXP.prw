#Include "Protheus.ch"
#Include "RWMake.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} QEMENU01
menu de Indicadores de Expedição 
@Autor Fabio Carneiro 
@since 22/08/2022
@version 1.0
@type user function 
/*/                
User Function QEMENU01()

Local aArea 		:= GetArea()   
Private cGetStat	:= ""
Private nOpc		:= 0
Private oDlgParam, oDlgMenu
Private cTitConf  	:= " Conferência e Gráficos"
Private cTitMenu    := " Menu indicadores de expedição"

U_QEMENUEXP()

RestArea(aArea)

Return()
/*
+------------------+-----------+---------------+-------+--------------+
| User Function    | QEMENUEXP |  QUALY        | Data: | 23/08/22     |
+------------------+-----------+---------------+-------+--------------+
| Descrição:       | Manutenção - Menu                                |
+------------------+--------------------------------------------------+
*/
User Function QEMENUEXP()

DEFINE MSDIALOG oDlgMenu TITLE cTitMenu FROM 0,0 TO 400, 600 OF oMainWnd STYLE DS_MODALFRAME PIXEL

If cFilAnt == '0803'
	oTBitmap1 := TBitmap():New(01,01,260,184,,"\SIGAADV\expedicao0803_png.PNG",.T.,oDlgMenu,/*{||}*/,,.F.,.F.,,,.F.,,.T.,,.F.)
Elseif cFilAnt == '0200'
	oTBitmap1 := TBitmap():New(01,01,260,184,,"\SIGAADV\expedicao0200_png.PNG",.T.,oDlgMenu,/*{||}*/,,.F.,.F.,,,.F.,,.T.,,.F.)
Elseif cFilAnt == '0901'
	oTBitmap1 := TBitmap():New(01,01,260,184,,"\SIGAADV\expedicao0901_png.PNG",.T.,oDlgMenu,/*{||}*/,,.F.,.F.,,,.F.,,.T.,,.F.)
Else
	oTBitmap1 := TBitmap():New(01,01,260,184,,"\SIGAADV\expedicao0000_png.PNG",.T.,oDlgMenu,/*{||}*/,,.F.,.F.,,,.F.,,.T.,,.F.)	
Endif

oTBitmap1:lAutoSize := .T.

oGroup	:= tGroup():New(110,005,195,300,"Menu indicadores de expedição",oDlgMenu,,,.T.)   
                                   	
TButton():New(130,20,  " &Relatório", /*oPanel2*/, {||oDlgMenu:End(),nOpc:=1},75, 24, , , .F., .T., , , .T.) 
TButton():New(130,110, " &Gráfico"	, /*oPanel2*/, {||oDlgMenu:End(),nOpc:=2},75, 24, , , .F., .T., , , .T.) 
TButton():New(130,200, " &Fechar"	, /*oPanel2*/, {||oDlgMenu:End(),nOpc:=5},75, 24, , , .F., .T., , , .T.) 

Activate MsDialog oDlgMenu Centered //on init EnchoiceBar(oDlgParam,{|| oDlgParam:End()},{||oDlgParam:End()},,)

If nOpc == 1 	// Relatorio
	U_QEEXPR01()
	U_QEMENUEXP()	
Elseif nOpc == 2 // Grafico
	U_QECHARTA()
	U_QEMENUEXP()
Elseif nOpc == 5 // Fechar
	//msgAlert("Fecha tela")
Endif	

Return()

