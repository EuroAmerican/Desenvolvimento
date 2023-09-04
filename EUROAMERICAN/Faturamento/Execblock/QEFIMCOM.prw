#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH" 

#DEFINE ENTER chr(13) + chr(10) 

/*/{Protheus.doc} QEFIMCOM  
// QE_XBLQFIM = Fechamento de Pagamento de Comissão especifico QUALY
@type function
@author fabio Caraneiro dos Santos
@since 17/05/2022
@version P12
@database MSSQL
/*/ 

User Function QEFIMCOM()

Private _lDataFin  := .F.

Private dDataFin:=dDataFinAnt:=GETMV("QE_XBLQFIM")

Private _dDataFin:=dDataFinAnt:=GETMV("QE_XBLQFIM")

Private oDlgFecha
SET CENTURY ON
@ 227,199 To 404,629 Dialog oDlgFecha Title OemToAnsi("Fechamento Comissão/Especifco QUALYl")
@ 9,5 Say OemToAnsi("Esta Rotina tem por objetivo permitir o fechamento das comissões pagas pela QUALY,") Size 214,18
@ 23,4 Say OemToAnsi("nao permitindo alteracoes com data inferior informado nos parametros.") Size 214,14
@ 37,20 Say OemToAnsi("Data Limite  Fech. Comissão(QE_XBLQFIM)") Size 98,8
@ 37,120 Get dDataFin Size 76,10
@ 70,126  BMPBUTTON TYPE 1 ACTION GRVFEC()         OBJECT oButtOK
@ 70,168 BMPBUTTON TYPE 2 ACTION FECHADLG()       OBJECT oButtCc
ACTIVATE DIALOG oDlgFecha CENTERED

Return Nil

Static Function GRVFEC()            

dbSelectArea("SX6")
dbSetOrder(1)

If dDataFin > _dDataFin .And. dDataFin <= dDatabase     
    _lDataFin := .T.
Else 
    If dDataFin == _dDataFin
        _lDataFin := .F.
    EndIf 
    Aviso("Atenção !!!" ,"As datas de alteração não podem ser menor que a data que esta atualmente no parametro e não pode ser maior que a database do sistema" ,{"OK"})
    _lDataFin := .F.
EndIf 

If dDataFin == _dDataFin
    _lDataFin := .F.
EndIf

If _lDataFin

    /*
    If Select("TRB2") > 0
        TRB2->(DbCloseArea())
    EndIf

    cQueryA := "SELECT * " + CRLF
    cQueryA += "FROM "+RetSqlName("SE3")+" AS SE3 " + CRLF
    cQueryA += " WHERE SE3.E3_FILIAL   = '"+xFilial("SE3")+"' " + CRLF
    cQueryA += 	" AND SE3.E3_EMISSAO BETWEEN '"+Dtos(dDataFinAnt) +"' AND '"+Dtos(dDataFin) +"' " + CRLF
    cQueryA += 	" AND SE3.E3_DATA     = '"+Dtos(Ctod(""))+"' " + CRLF
    cQueryA +=  " AND SE3.E3_BAIEMI='B'  " + CRLF
    cQueryA += 	" AND SE3.D_E_L_E_T_ = ' ' " + CRLF
                    
    TCQUERY cQueryA NEW ALIAS TRB2

    TRB2->(dbGoTop())

    While TRB2->(!Eof())
            
        DbSelectArea("SE3")
        DbSetOrder(3)    //E3_FILIAL+E3_VEND+E3_CODCLI+E3_LOJA+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_TIPO+E3_SEQ
        If SE3->(dbSeek(xFilial("SE3")+TRB2->E3_VEND+TRB2->E3_CODCLI+TRB2->E3_LOJA+TRB2->E3_PREFIXO+TRB2->E3_NUM+TRB2->E3_PARCELA+TRB2->E3_TIPO+TRB2->E3_SEQ)) 
            
            DbSelectArea("SE3")
            Reclock("SE3",.T.)
                SE3->E3_DATA   := dDataFin
            SE3->( Msunlock() )
            
        EndIf
        TRB2->(dbSkip())

    Enddo
    */
    //Apos gravar todas as datas na tabela SE3

    PutMV ("QE_XBLQFIM",  DTOC(dDataFin)) 

EndIf 


SET CENTURY OFF

If _lDataFin  
    Aviso("Atenção !!!" ,"Alteração Efetuada com Sucesso" ,{"OK"})
EndIf

Close(oDlgFecha)

Return Nil                      

Static Function FECHADLG()                   
SET CENTURY OFF
Close(oDlgFecha)

Return Nil

