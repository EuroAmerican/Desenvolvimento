#Include "Protheus.ch"

// FS - Adiciona campos no cabeçalho do pedido de compras...

User Function MT120TEL()

Local oEUWFID
Local aArea    := GetArea()
Local oDlg     := ParamIxb[1]
Local aPosGet  := ParamIxb[2]
Local nOpcx    := ParamIxb[4]
Local nRecPC   := ParamIxb[5]
Local lEdit    := .F. // Não será editável...

Public cEUWFID := ""

//Define o conteúdo para os campos
SC7->( DbGoTo( nRecPC ) )

If nOpcx == 3
	cEUWFID := CriaVar("C7_EUWFID",.F.)
Else
	cEUWFID := SC7->C7_EUWFID
EndIf

//Criando na janela o campo Id. WF do Processo
@ 062, aPosGet[1,08] - 012 SAY Alltrim(RetTitle("C7_EUWFID")) OF oDlg PIXEL SIZE 050,006
@ 061, aPosGet[1,09] - 006 MSGET oEUWFID VAR cEUWFID SIZE 100, 006 OF oDlg COLORS 0, 16777215  PIXEL
oEUWFID:bHelp := {|| ShowHelpCpo( "C7_EUWFID", {GetHlpSoluc("C7_EUWFID")[1]}, 5  )}

//Se não houver edição, desabilita os gets
If !lEdit
	oEUWFID:lActive := .F.
EndIf

RestArea(aArea)

Return