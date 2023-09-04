#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH" 

#DEFINE ENTER chr(13) + chr(10) 

/*/{Protheus.doc} QECTB003  
// Disponibilizacao de alteracao dos Parametros Pelo Usuario Contabil
// MV_DATAFIN = Financeiro
// MV_DATAFIS = FIscal/Compras
// MV_DBLQMOV = FIscal/Compras
@type function
@author fabio Caraneiro dos Santos
@since 17/01/2022
@version P12
@database MSSQL
/*/ 

User Function QECTB003()

Private _lDataFin  := .F.
Private _lDataFis  := .F.
Private _lDataEst  := .F.

Private dDataFin:=dDataFinAnt:=GETMV("MV_DATAFIN")
Private dDataFis:=dDataFisAnt:=GETMV("MV_DATAFIS")
Private dDataEst:=dDataEstAnt:=GETMV("MV_DBLQMOV")

Private _dDataFin:=dDataFinAnt:=GETMV("MV_DATAFIN")
Private _dDataFis:=dDataFisAnt:=GETMV("MV_DATAFIS")
Private _dDataEst:=dDataEstAnt:=GETMV("MV_DBLQMOV")

Private oDlgFecha
SET CENTURY ON
@ 227,199 To 404,629 Dialog oDlgFecha Title OemToAnsi("Fechamento Estoque/Financeiro e Fiscal")
@ 9,5 Say OemToAnsi("Esta Rotina tem por objetivo permitir o fechamento dos modulos Financeiro/Compras/Faturamento/Estoque e Fiscal,") Size 214,18
@ 23,4 Say OemToAnsi("nao permitindo alteracoes com data inferior informado nos parametros.") Size 214,14
@ 37,20 Say OemToAnsi("Data Limite  Financeiro(MV_DATAFIN)") Size 98,8
@ 48,20 Say OemToAnsi("Data Limite Fiscal(MV_DATAFIS)") Size 98,8
@ 59,20 Say OemToAnsi("Data Limite Estoque(MV_DBQLMOV)") Size 98,8
@ 37,120 Get dDataFin Size 76,10
@ 48,120 Get dDataFis Size 76,10
@ 59,120 Get dDataEst Size 76,10
@ 70,126  BMPBUTTON TYPE 1 ACTION GRVFEC()         OBJECT oButtOK
@ 70,168 BMPBUTTON TYPE 2 ACTION FECHADLG()       OBJECT oButtCc
ACTIVATE DIALOG oDlgFecha CENTERED

Return Nil

Static Function GRVFEC()            

dbSelectArea("SX6")
dbSetOrder(1)

If dDataFin > _dDataFin .And. dDataFin <= dDatabase     
    _lDataFin := .T.
ElseIf dDataFis > _dDataFis .And. dDataFis <= dDatabase
    _lDataFis := .T.
ElseIf dDataEst > _dDataEst .And. dDataEst <= dDatabase
    _lDataEst := .T.
Else 
    If dDataFin == _dDataFin
        _lDataFin := .F.
    ElseIf dDataFis == _dDataFis
        _lDataFis := .F.
    ElseIf dDataEst == _dDataEst
        _lDataEst := .F.
    EndIf 
    Aviso("Atenção !!!" ,"As datas de alteração não podem ser menor que a data que esta atualmente no parametro e não pode ser maior que a database do sistema" ,{"OK"})
    _lDataFin := .F.
    _lDataFis := .F.
    _lDataEst := .F.
EndIf 

If dDataFin == _dDataFin
    _lDataFin := .F.
EndIf

If dDataFis == _dDataFis
    _lDataFis := .F.
EndIf

If dDataEst == _dDataEst
    _lDataEst := .F.
EndIf 

If _lDataFin 
    PutMV ("MV_DATAFIN",  DTOC(dDataFin)) 
EndIf 

If _lDataFis
    PutMV ("MV_DATAFIS",  DTOC(dDataFis))
EndIf 

If _lDataEst 
    PutMV ("MV_DBLQMOV",  DTOC(dDataEst))
EndIf

SET CENTURY OFF

If _lDataFin .Or. _lDataFis .Or. _lDataEst 
    Aviso("Atenção !!!" ,"Alteração Efetuada com Sucesso" ,{"OK"})
EndIf

Close(oDlgFecha)

Return Nil                      

Static Function FECHADLG()                   
SET CENTURY OFF
Close(oDlgFecha)

Return Nil

