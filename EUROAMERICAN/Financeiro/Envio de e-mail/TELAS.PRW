#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "RptDef.ch"
#Include "FWPrintSetup.ch"
#Include "TopConn.ch"
#Include 'TbiConn.Ch'
#Include 'Totvs.Ch'
#Include 'Ap5Mail.Ch'

User Function TELACONT()

PRIVATE dDatav      := CTOD("")
PRIVATE lMsErroAuto := .F.
PRIVATE nNum        := 1
PRIVATE cProdd      :=SPACE(12)
PRIVATE cProda      :=SPACE(12)
PRIVATE nPor        :=0
PRIVATE cNome       :=SPACE(25)
Private _oDlg
Private oEdit
//PRIVATE DDATA       := GETMV("MV_ULMES")
public INCLUI       := .T.



//DEFINE MSDIALOG _oDlg TITLE "Painel Controle" FROM (178),(100) TO (700),(1000) PIXEl
DEFINE MSDIALOG _oDlg TITLE "Painel Controle envio e-mail titulos em atraso" FROM (178),(100) TO (600),(950) PIXEl

oFont := TFont():New('Courier new',,-18,.T.)

//@ (005),(015) Say "Envio de e-mail atraso 5 dias Qualy/Euro (FINM012)" COLOR CLR_BLACK FONT oFont OF _oDlg PIXEL
@ (005),(015) Say "Envio de e-mail atraso 5 dias Jays" COLOR CLR_BLACK FONT oFont OF _oDlg PIXEL
@ (005),(350) Button "Processar"    		 	Size (049),(012) PIXEL OF _oDlg ACTION TITJAYS()

//@ (030),(015) Say "Envio de e-mail atraso 5 dias Phoenix (TITATSPHON)" COLOR CLR_BLACK FONT oFont OF _oDlg PIXEL
@ (030),(015) Say "Envio de e-mail atraso 5 dias Euro" COLOR CLR_BLACK FONT oFont OF _oDlg PIXEL
@ (030),(350) Button "Processar"  	Size (049),(012) PIXEL OF _oDlg ACTION TITAEURO()

@ (060),(015) Say "Envio de e-mail atraso 5 dias QualyCril" COLOR CLR_BLACK FONT oFont OF _oDlg PIXEL
@ (060),(350) Button "Processar"           	Size (049),(012) PIXEL OF _oDlg ACTION TITCRIL()

@ (090),(015) Say "Envio de e-mail atraso 5 dias Qualyvinil" COLOR CLR_BLACK FONT oFont OF _oDlg PIXEL
@ (090),(350) Button "Processar"   	Size (049),(012) PIXEL OF _oDlg ACTION TITQUALY()

@ (120),(015) Say "Envio de e-mail atraso 5 dias Phoenix" COLOR CLR_BLACK FONT oFont OF _oDlg PIXEL
@ (120),(350) Button "Processar"  	Size (049),(012) PIXEL OF _oDlg ACTION TITATSPHON()

@ (150),(015) Say "Todos" COLOR CLR_BLACK FONT oFont OF _oDlg PIXEL
@ (150),(350) Button "Processar"      	Size (049),(012) PIXEL OF _oDlg ACTION u_todos()
/*
@ (180),(015) Say "Caixa de dialog fonte (STATUSCOMP)" COLOR CLR_BLACK FONT oFont OF _oDlg PIXEL
@ (180),(350) Button "Processar"   Size (049),(012) PIXEL OF _oDlg ACTION u_LstBxMr2()
*/
@ (180),(190) Button " SAIR "        Size (039),(012) PIXEL OF _oDlg ACTION _oDlg:end()


ACTIVATE MSDIALOG _oDlg CENTERED

RETURN


Static Function TITJAYS()

    //If FWCodEmp() == "01" 
        If MSGYESNO('Essa rotina vai enviar e-mail para os clientes que estão com atraso nos boletos Empresa(01)' , 'WORKFLOW' )
            If MSGYESNO('Deseja realmente rodar a rotina?' , 'WORKFLOW')
                Processa({|| u_TITJAYS()}, "Aguarde...", "Atualizando dados...")	
                Msginfo('Enviado com sucesso')	 
            Else
                Return
            EndIf    
        EndIf     
    //Else
      //  Alert("A T E N Ç Ã O" + CRLF + CRLF + "Esse envio de e-mail deverá ser rodado somente nas empresas abaixo:" + CRLF + "02 = Euroamerican" + CRLF + "03 = Qualyvinil" + CRLF + "08 = Qualycril" + CRLF + "Favor logar em alguma dessas empresas") 
    //EndIf     
Return

Static Function TITAEURO()

    //If FWCodEmp() == "02" //.or. FWCodEmp() == "03" .or. FWCodEmp() == "08" 
        If MSGYESNO('Essa rotina vai enviar e-mail para os clientes que estão com atraso nos boletos Empresa(2)' , 'WORKFLOW' )
            If MSGYESNO('Deseja realmente rodar a rotina?' , 'WORKFLOW')
                Processa({|| u_TITAEURO()}, "Aguarde...", "Atualizando dados...")	
                Msginfo('Enviado com sucesso')	 
            Else
                Return
            EndIf    
        EndIf     
    //Else
    //    Alert("A T E N Ç Ã O" + CRLF + CRLF + "Esse envio de e-mail deverá ser rodado somente nas empresas abaixo:" + CRLF + "02 = Euroamerican" + CRLF + "03 = Qualyvinil" + CRLF + "08 = Qualycril" + CRLF + "Favor logar em alguma dessas empresas") 
    //EndIf     
Return



Static Function TITCRIL()

    //If FWCodEmp() == "02" //.or. FWCodEmp() == "03" .or. FWCodEmp() == "08" 
        If MSGYESNO('Essa rotina vai enviar e-mail para os clientes que estão com atraso nos boletos Empresa(3)' , 'WORKFLOW' )
            If MSGYESNO('Deseja realmente rodar a rotina?' , 'WORKFLOW')
                Processa({|| u_TITCRIL()}, "Aguarde...", "Atualizando dados...")	
                Msginfo('Enviado com sucesso')	 
            Else
                Return
            EndIf    
        EndIf     
    //Else
    //    Alert("A T E N Ç Ã O" + CRLF + CRLF + "Esse envio de e-mail deverá ser rodado somente nas empresas abaixo:" + CRLF + "02 = Euroamerican" + CRLF + "03 = Qualyvinil" + CRLF + "08 = Qualycril" + CRLF + "Favor logar em alguma dessas empresas") 
    //EndIf     
Return

Static Function TITQUALY()

    //If FWCodEmp() == "08"
        If MSGYESNO('Essa rotina vai enviar e-mail para os clientes que estão com atraso nos boletos Empresa(8)' , 'WORKFLOW' )
            If MSGYESNO('Deseja realmente rodar a rotina?' , 'WORKFLOW')
                Processa({|| u_TITQUALY()}, "Aguarde...", "Atualizando dados...")	
                Msginfo('Enviado com sucesso')	 
            Else
                Return
            EndIf    
        EndIf     
    //Else
      //   Alert("A T E N Ç Ã O" + CRLF + CRLF + "Esse envio de e-mail deverá ser rodado somente nas empresas abaixo:" + CRLF + "09 = Phoenix" + CRLF + "Favor logar na empresa correta")
        //Return
    //EndIf     
Return


Static Function TITATSPHON()

    //If FWCodEmp() == "09"
        If MSGYESNO('Essa rotina vai enviar e-mail para os clientes que estão com atraso nos boletos Empresa(9)' , 'WORKFLOW' )
            If MSGYESNO('Deseja realmente rodar a rotina?' , 'WORKFLOW')
                Processa({|| u_TITATSPHON()}, "Aguarde...", "Atualizando dados...")	
                Msginfo('Enviado com sucesso')	 
            Else
                Return
            EndIf    
        EndIf     
    //Else
      //   Alert("A T E N Ç Ã O" + CRLF + CRLF + "Esse envio de e-mail deverá ser rodado somente nas empresas abaixo:" + CRLF + "09 = Phoenix" + CRLF + "Favor logar na empresa correta")
        //Return
    //EndIf     
Return

Static Function TODOS()

    //If FWCodEmp() == "09"
        If MSGYESNO('Essa rotina vai enviar e-mail para os clientes que estão com atraso nos boletos Empresa(9)' , 'WORKFLOW' )
            If MSGYESNO('Deseja realmente rodar a rotina?' , 'WORKFLOW')
                Processa({|| u_TODOS()}, "Aguarde...", "Atualizando dados...")	
                Msginfo('Enviado com sucesso')	 
            Else
                Return
            EndIf    
        EndIf     
    //Else
      //   Alert("A T E N Ç Ã O" + CRLF + CRLF + "Esse envio de e-mail deverá ser rodado somente nas empresas abaixo:" + CRLF + "09 = Phoenix" + CRLF + "Favor logar na empresa correta")
        //Return
    //EndIf     
Return


User Function TODOS()

    If FWCodEmp() == "09"
        u_TITJAYS()
        u_TITAEURO()
        u_TITCRIL()
        u_TITQUALY()
        MsgInfo("Enviado com sucesso","WORKFLOW")
    Else
        Alert("A T E N Ç Ã O" + CRLF + "Essa rotina não pode ser radada nessa empresa" + CRLF +"Favor logar na empresa Phoenix", "WORKFLOW")
        Return
    EndIf

Return
