#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} mfat001
//Rotina para manutencao do historico no PV.
@author mjlozzardo
@since 31/10/2018
@version 1.0
/*/
User Function mfat001()
	Local oButton1
	Local oButton2
	Local oTela
	Local oScroll
	Local nOpcX := 2
	Local cEof  := Chr(13) + Chr(10)

	Local cMemo := Alltrim(SC5->C5_XOBSERV)
	Local oMemo
	Local cMemo1:= Space(254)
	Local oMemo1

	Define MsDialog oTela Title "Historico do Pedido" From 0,0 To 500,755 Pixel

	@ 5,5 Get oMemo1 Var cMemo1 Memo Size 360,100 Pixel
	@ 120,5 Get oMemo Var cMemo Memo Size 360,100 When .F. Pixel

	Define SBUTTON oButton1 From 235, 010 Type 01 Action (oTela:End(), nOpcX := 1) Of oTela Enable
	Define SBUTTON oButton2 From 235, 100 Type 02 Action (oTela:End(), nOpcX := 2) Of oTela Enable
	Activate MsDialog oTela Centered

	If nOpcX == 1
		SC5->(RecLock("SC5", .F.))
		SC5->C5_XOBSERV := UsrRetName(__cUserID) + " " + Dtoc(dDataBase) + " " + Time() + cEof + cMemo1 + cEof + cMemo + cEof
		SC5->(MsUnLock())
	EndIf

	Return