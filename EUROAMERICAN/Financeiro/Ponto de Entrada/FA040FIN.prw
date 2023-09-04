#Include 'Protheus.ch'

/*-----------------+---------------------------------------------------------+
!Nome              ! FA040FIN                                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Ponto de entrada ira atualizar parcela para 1 caractere !
!                  ! para titulos do tipo NF.                                !
+------------------+---------------------------------------------------------+
!Motivo Uso        ! Após Alterar o parametro MV_1DUP para 001, apresentou   !
!                  ! problemas no envio dos titulos para o banco.            !
+------------------+---------------------------------------------------------+
*/

User Function FA040FIN()

Local aArea     := GetArea() 

If IsInCallStack("FINA460") 
    RestArea(aArea)
    Return 
EndIf

If SE1->E1_TIPO == "NF " 

    If Len(SE1->E1_PARCELA) == 3

        SE1->E1_PARCELA := Alltrim(SubStr(SE1->E1_PARCELA,3,1)) // 001
            
    EndIf

EndIf

RestArea(aArea)

Return 
