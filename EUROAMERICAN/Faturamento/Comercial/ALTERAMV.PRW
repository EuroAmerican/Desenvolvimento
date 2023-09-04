#include 'protheus.ch'
#include 'parmtype.ch'
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "ap5mail.ch"
#Include "RwMake.Ch"

/*/{Protheus.doc} ENVADES
//Rotina altera para parametro sx6
@author Fabio Batista
@since 17/10/2020
@version 1.0
/*/
User Function ALTERAMV()

Local __cUSRALT := GETMV("MV_XALTS6",,'000000#001069')

Private __oDlg
Private __nMarg  := SPACE(05)

	If RetCodUsr() $__cUSRALT 

		DEFINE MSDIALOG __oDlg FROM 0,0 TO 350,290 PIXEL TITLE "Alteração parâmetro da margem"
		@ 017,12 Say "Digite a margem ?"         of __oDlg Pixel
		@ 016,74 MsGet __nMarg Picture "@!" of __oDlg Pixel

		@ 093,034 BUTTON "Processar" SIZE 28,13 PIXEL OF __oDlg ACTION ALTMARG(__oDlg)
		@ 093,081 BUTTON "Sair"      SIZE 28,13 PIXEL OF __oDlg ACTION __oDlg:End()
				
		ACTIVATE MSDIALOG __oDlg CENTERED
	Else
		mSgInfo("Usuário sem permição para alterar o parametro")
	EndIf 

Return

/*/{Protheus.doc} ALTMARG
//Rotina altera sx6
@author Fabio Batista
@since 04/12/2020
@version 1.0
/*/
Static Function ALTMARG()

Local aAreaSX6	  := GetArea()

	DBSELECTAREA("SX6")
	SX6->(DBGOTOP())

	If SX6->(DBSeek('    ' + "MV_XMARGEM"))
		RecLock('SX6',.F.)
		SX6->X6_CONTEUD := __nMarg
		SX6->( MsUnlock() )
		__oDlg:End()
		MsgInfo('Valor da margem atualizado para: ' + __nMarg)
	EndIf 

	RestArea( aAreaSX6 )

Return
