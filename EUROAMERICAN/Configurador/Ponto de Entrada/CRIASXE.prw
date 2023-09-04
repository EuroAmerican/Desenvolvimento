#include "protheus.ch"
user function CRIASXE()
Local cNum := NIL
Local aArea := getarea()
Local aArea2 := {}
Local cAlias    := paramixb[1]
Local cCpoSx8   := paramixb[2]
Local cAliasSx8 := paramixb[3]
Local nOrdSX8   := paramixb[4]
Local cUsa := "SC2"  // colocar os alias que irão permitir a execução do P.E.

//MsgInfo("Entrou ponto CriaSXE! Parametro 1: " + cAlias + " 2: " + cCpoSx8 + " 3: " + cAliasSx8 + " EmpAnt: " + cEmpAnt)

If cAlias $ cUsa .and.  ! ( Empty(cAlias) .and. empty(cCpoSx8) .and. empty(cAliasSx8) ) .And. Left(cFilAnt,2) $ "08"
	//qout(cAlias + "-" + cCpoSx8 + "-" + cAliasSx8 + "-" + str(nOrdSX8))
	dbselectarea(cAlias)
	aArea2 := getarea()
	dbsetorder(1)
	dbseek(xfilial()+"166632")	//Intervalo entre 166631 e 166709 lançados manualmente comprometendo sequência correta
	dbskip(-1)
	cNum := &(cCpoSx8)
	cnum := soma1(cNum)
	//MsgStop("Entrou no ponto de entrada " + cnum)
	restarea(aArea2)
	restarea(aArea)

ElseIf cAlias $ "SC1" .and.  ! ( Empty(cAlias) .and. empty(cCpoSx8) .and. empty(cAliasSx8) ) .And. Alltrim(cFilAnt) $ "0200"
	//qout(cAlias + "-" + cCpoSx8 + "-" + cAliasSx8 + "-" + str(nOrdSX8))
	dbselectarea(cAlias)
	aArea2 := getarea()
	dbsetorder(1)
	dbseek(xfilial()+"230001")	//Intervalo entre 230001 e 230052 lançados manualmente comprometendo sequência correta
	dbskip(-1)
	cNum := &(cCpoSx8)
	cnum := soma1(cNum)
	restarea(aArea2)
	restarea(aArea)
ElseIf cAlias $ "SZF" .and.  ! ( Empty(cAlias) .and. empty(cCpoSx8) .and. empty(cAliasSx8) ) /*.And. cEmpAnt + cFilAnt $ "0200"*/
	//qout(cAlias + "-" + cCpoSx8 + "-" + cAliasSx8 + "-" + str(nOrdSX8))
	dbselectarea(cAlias)
	aArea2 := getarea()
	dbsetorder(1)
	dbseek(xfilial()+"FQK881")	//Intervalo entre 230001 e 230052 lançados manualmente comprometendo sequência correta
	dbskip(-1)
	cNum := &(cCpoSx8)
	cnum := soma1(cNum)
	restarea(aArea2)
	restarea(aArea)
EndIf

return cNum