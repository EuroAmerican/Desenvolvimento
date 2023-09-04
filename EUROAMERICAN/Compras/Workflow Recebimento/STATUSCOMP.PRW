#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

/*
{Protheus.doc} STATUSCOMP()
Disparo e-mail na aprovação do PC
@Author     Fabio Batista
@Since      12/06/2020
@Version    P12.7
@Project    EURO
@Param		 cAssunto
@Param		 cBody
@Param		 cEmail
*/
Static nAlt := 0

User Function STATUSCOMP(nOper)

Local aArea             := GetArea()
Local cEmail 			:=  SuperGetMv("MV_XMAILPC",,"fabio.santos@euroamerican.com.br") // Processo recebimento...
Local cDescrFase        := ''
Local cHtml             := ''
Local cAssunto          := 'Pedido de Compra'
Local cAttach           := ''
Local nOper             := nOper
Local cBody             := ''
Local cMailAP           := '' 
Local lRet              := .F.
Local aAPROV            := {}
Local nI                := 0
Local lEnvia            := .F.



    If !SC7->(FieldPos("C7_XFLAG")) > 0
         Alert("A T E N Ç Ã O " + CRLF + CRLF + "Abra um chamado com essa mensagem" + CRLF + "Campo de (Flag PC) não existe na tabela (SC7)" + CRLF +;
         "Favor criar o seguinte campo" + CRLF + CRLF + "CAMPO : C7_XFLAG" + CRLF + "TIPO : C" + CRLF +;
         "TAMANHO : 1" + CRLF + "FORMATO : @!" + CRLF +;
         "CONTEXTO : REAL" + CRLF + "PROPRIEDADE : ALTERAR" + CRLF + "TITULO : Flag PC" + CRLF + CRLF +;
         "Vai ser abortada a rotina, até que seja criado o campo.")
          //RestArea(aArea)	 
         Return
    Endif

     nAlt++
    If nOper == 1  .and. Empty(C7_XFLAG) .And. nAlt == 1 
        cDescrFase := 'Pedido de Compra Incluido'
    ElseIf nOper == 1 .And. nAlt > 1
        Return
    EndIF 

    If nOper == 3 .and. Empty(C7_XFLAG)  
        Return
    EndIf
    
    If nOper == 3 .and. !Empty(C7_XFLAG)  
        cDescrFase := 'Pedido de Compra Alterado'
        lRet := .T.
    Else 
        If nOper == 5
            cDescrFase := 'Pedido de Compra Estorno'    
        ElseIf nOper == 4
            cDescrFase := 'Pedido de Compra Aprovado'
        ElseIf nOper == 7
            cDescrFase := 'Pedido de Compra Rejeitado'
        ElseIf nOper == 6
                cDescrFase := 'Pedido de Compra Bloqueado'                       
        EndIf
    EndIf

    cHtml := '<html>' + CRLF
    cHtml += '	<head>' + CRLF
    cHtml += '		<meta http-equiv="content-type" content="text/html;charset=utf-8">' + CRLF
    cHtml += '		<style>' + CRLF
    cHtml += '			table 	{' + CRLF
    cHtml += '					border-collapse: collapse;' + CRLF
    cHtml += '					border: 1px solid black;' + CRLF
    cHtml += '					}' + CRLF
    cHtml += '		</style>' + CRLF
    cHtml += '	</head>' + CRLF
    cHtml += '	<body>' + CRLF
    cHtml += '		<table style="text-align: left; width: 100%; height: 10%; border:none;" border="0" cellpadding="0" cellspacing="0">' + CRLF
    cHtml += '				<tr>'	 + CRLF			
    cHtml += '				</tr>' + CRLF
    cHtml += '		</table>' + CRLF
    cHtml += '		<table border="1" width="100%" align="center">' + CRLF
    cHtml += '			<tr>' + CRLF
    cHtml += '				<td colspan="6" width="100%"style=mso-number-format:"\@" align="center" VALIGN="MIDDLE" bgcolor="#336699">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><B><Font Size=4 color=white>'+cDescrFase+'</Font></B></font>' + CRLF
    cHtml += '				</td>' + CRLF
    cHtml += '			</tr>' + CRLF
    cHtml += '			<tr>' + CRLF
    cHtml += '				<td  width="10%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE" bgcolor="#F3F3F3">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><B><Font Size=2 color=black>Filial</Font></B></font>'   + CRLF  
    cHtml += '				</td>' + CRLF
    cHtml += '				<td colspan="2" width="40%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><Font Size=2 color=black>'+SM0->M0_CODIGO+'/'+SM0->M0_CODFIL+' - '+SM0->M0_FILIAL+'</Font></font>' + CRLF
    cHtml += '				</td>' + CRLF
    cHtml += '				<td  width="10%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE" bgcolor="#F3F3F3">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><B><Font Size=2 color=black>Emissao</Font></B></font>'     + CRLF
    cHtml += '				</td>' + CRLF
    cHtml += '				<td colspan="2" width="40%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><Font Size=2 color=black>'+DTOC(SC7->C7_EMISSAO)+'</Font></font>'  + CRLF   
    cHtml += '				</td>' + CRLF
    cHtml += '			</tr>' + CRLF
    cHtml += '			<tr>' + CRLF
    cHtml += '				<td  width="10%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE" bgcolor="#F3F3F3">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><B><Font Size=2 color=black>Numero</Font></B></font>'   + CRLF  
    cHtml += '				</td>' + CRLF
    cHtml += '				<td colspan="2" width="40%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><Font Size=2 color=black>'+SC7->C7_NUM+'</Font></font>'  + CRLF   
    cHtml += '				</td>' + CRLF
    cHtml += '				<td  width="10%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE" bgcolor="#F3F3F3">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><B><Font Size=2 color=black>Comprador</Font></B></font>' + CRLF
    cHtml += '				</td>' + CRLF
    cHtml += '				<td colspan="2" width="40%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><Font Size=2 color=black>'+UsrRetName(SC7->C7_USER)+'</Font></font>'    + CRLF 
    cHtml += '				</td>' + CRLF
    cHtml += '			</tr>' + CRLF
    cHtml += '			<tr> '   + CRLF
    cHtml += '				<td  width="10%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE" bgcolor="#F3F3F3">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><B><Font Size=2 color=black>Fornecedor/Loja</Font></B></font>' + CRLF
    cHtml += '				</td>' + CRLF
    cHtml += '				<td colspan="2" width="40%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><Font Size=2 color=black>'+SC7->C7_FORNECE+'/'+SC7->C7_LOJA+'</Font></font>' + CRLF
    cHtml += '				</td>' + CRLF
    cHtml += '				<td  width="10%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE" bgcolor="#F3F3F3">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><B><Font Size=2 color=black>Nome Forn.</Font></B></font> '    + CRLF
    cHtml += '				</td>    ' + CRLF
    cHtml += '				<td colspan="2" width="40%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE">      ' + CRLF
    cNomeFor := Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,'A2_NREDUZ')
    cHtml += '					<font face="Courier New" size="2" color=WHITE><Font Size=2 color=black>'+cNomeFor+'</Font></font> '    + CRLF
    cHtml += '				</td>' + CRLF
    cHtml += '			</tr>' + CRLF
    cHtml += '		</table><br>' + CRLF
    cHtml += '		<table style="border:none;" border="0" width="100%" align="center" >' + CRLF
    cHtml += '			<tr>    ' + CRLF
    cHtml += '				<td colspan="6" width="100%"style=mso-number-format:"\@"  align="center" VALIGN="MIDDLE" bgcolor="#336699">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><B><Font Size=4 color=white>Processo</Font></B></font>    ' + CRLF
    cHtml += '				</td>' + CRLF
    cHtml += '			</tr>' + CRLF
    cHtml += '			<tr>    <br>' + CRLF
    cHtml += ' </tr></table>

        If nOper == 4//aprovado
            cHtml += '	<div align=center> ' + CRLF
            cHtml += '					<font face="Courier New" size="2" color="#000000"><b>Pedido</b></font><br>    ' + CRLF
            cHtml += '					<font face="Courier New" size="2" color="#000000"><b>Aprovado</b></font><br>     ' + CRLF
        
        EndIf
        
        If nOper == 5//estornar 
            cHtml += '				<div align=center>   ' + CRLF
            cHtml += '					<font face="Courier New" size="2" color="#000000"><b>Pedido</b></font><br>    ' + CRLF
            cHtml += '					<font face="Courier New" size="2" color="#000000"><b>Aguardando</b></font><br>    ' + CRLF
            cHtml += '				' + CRLF
        EndIf
        
         If nOper == 1// inclusão PC
            cHtml += '				<div align=center>   ' + CRLF
            cHtml += '					<font face="Courier New" size="2" color="#000000"><b>Pedido</b></font><br>    ' + CRLF
            cHtml += '					<font face="Courier New" size="2" color="#000000"><b>Aguardando</b></font><br>    ' + CRLF
            cHtml += '				' + CRLF
        EndIf

        If lRet//pedido alterado após aprovador interagir
            cHtml += '				<div align=center>   ' + CRLF
            cHtml += '					<font face="Courier New" size="2" color="#000000"><b>Pedido</b></font><br>    ' + CRLF
            cHtml += '					<font face="Courier New" size="2" color="#000000"><b>Aguardando</b></font><br>    ' + CRLF
            cHtml += '				' + CRLF
        EndIf

        If nOper == 6//bloqueado
            cHtml += '				<div align=center> ' + CRLF
            cHtml += '					<font face="Courier New" size="2" color="#000000"><b>Pedido</b></font><br>' + CRLF
            cHtml += '					<font face="Courier New" size="2" color="#000000"><b>Bloqueado</b></font><br>' + CRLF
        EndIf

        If nOper == 7//rejeitada
            cHtml += '				<div align=center> ' + CRLF
            cHtml += '					<font face="Courier New" size="2" color="#000000"><b>Pedido</b></font><br>' + CRLF
            cHtml += '					<font face="Courier New" size="2" color="#000000"><b>Rejeitado</b></font><br>' + CRLF
        EndIf

        If nOper == 4//aprovado
            cHtml += '					<img style="width: 40px; height: 40px;" alt="" src="http://helpdesk.gruposabara.com/libs/images/rdg/approve.png">' + CRLF 
            cHtml += '<br>'
            cHtml += CUSERNAME
        EndIf    
    
        If nOper == 1//Inclusão PC
            cHtml += '					<img style="width: 40px; height: 40px;" alt="" src="http://helpdesk.gruposabara.com/libs/images/rdg/waiting.png">' + CRLF
            cHtml += CUSERNAME
            cHtml += '<br>'
        EndIf

        If nOper == 5//estornar
            cHtml += '					<img style="width: 40px; height: 40px;" alt="" src="http://helpdesk.gruposabara.com/libs/images/rdg/waiting.png">' + CRLF
            cHtml += CUSERNAME
            cHtml += '<br>'
        EndIf

        If lRet //pedido alterado após aprovador interagir
            cHtml += '					<img style="width: 40px; height: 40px;" alt="" src="http://helpdesk.gruposabara.com/libs/images/rdg/waiting.png">' + CRLF
            cHtml += CUSERNAME
            cHtml += '<br>'
        EndIf
    
        If nOper == 6 .or. nOper == 7//rejeitado
            cHtml += '					<img style="width: 40px; height: 40px;" alt="" src="http://helpdesk.gruposabara.com/libs/images/rdg/stop.png">' + CRLF
            cHtml += CUSERNAME
            cHtml += '<br>'
        EndIf
        cHtml += '<br>'    
        
    
        If !SC7->(FieldPos("C7_XHIST")) > 0
            Alert("A T E N Ç Ã O " + CRLF + CRLF + "Abra um chamado com essa mensagem" + CRLF + "Campo de (Hist. PC) não existe na tabela (SC7)" + CRLF +;
            "Favor criar o seguinte campo" + CRLF + CRLF + "CAMPO : C7_XHIST" + CRLF + "TIPO : C" + CRLF +;
            "TAMANHO : 40" + CRLF + "FORMATO : @!" + CRLF +;
            "CONTEXTO : REAL" + CRLF + "PROPRIEDADE : ALTERAR" + CRLF + "TITULO : Hist. PC" + CRLF + CRLF +;
            "Vai ser abortada a rotina, até que seja criado o campo.")
            	 
            Return
        Endif

        If lRet
            cHtml += '		<table style="border:none;" border="0" width="100%" align="center" >' + CRLF
            cHtml += '			<tr>    ' + CRLF
            cHtml += '				<td colspan="6" width="100%"style=mso-number-format:"\@"  align="center" VALIGN="MIDDLE" bgcolor="#336699">' + CRLF
            cHtml += '					<font face="Courier New" size="2" color=WHITE><B><Font Size=4 color=white>Historico Alteração</Font></B></font>    ' + CRLF
            cHtml += '				</td>' + CRLF
            cHtml += '			</tr>' + CRLF
            cHtml += '		</table>' + CRLF
            If Empty(C7_XHIST)
               RecLock("SC7", .F.)
               SC7->C7_XHIST := 'Comprador não informou o motivo da alteração!'
           EndIf
            cHtml += SC7->C7_XHIST + CRLF
            cHtml += '		<br>' + CRLF
        EndIf
        
        cHtml += '	</body>' + CRLF
        cHtml += '</html>' + CRLF
        cBody := cHtml
    
        //controle de envio de e-mail para aprovadores
        If Empty(SC7->C7_XFLAG) .and. nOper <> 1 
            RecLock("SC7", .F.)
            SC7->C7_XFLAG := 'x'
        EndIf    

    
        //Valida se manda e-mail para aprovador
        If nOper == 3 .and. !Empty(SC7->C7_XFLAG) .or. nOper == 1
                AprovPC(aAprov)
                For nI := 1 To Len(aAprov)
                    If aAprov[nI] <> '001028'
                        cMailAP := UsrRetMail(aAprov[nI]) 
                        cEmail := cMailAP    
                        //cEmail := 'fabio.batista@euroamerican.com.br' 
                        u_FSENVMAIL(cAssunto, cBody, cEmail,cAttach,,,,,,,,,)
                        lEnvia := .T.
                    EndIf     
                Next      
        EndIf   

        If !lEnvia
            cEmail := UsrRetMail(SC7->C7_USER)
            //cEmail := 'FABIO.BATISTA@EUROAMERICAN.COM.BR' 
            u_FSENVMAIL(cAssunto, cBody, cEmail,cAttach,,,,,,,,,)
        EndIf 

        RestArea( aArea )
Return

/*
{Protheus.doc} AprovPC
Pega o codigo do usuario no
grupo de aprovadores
@Author     Fabio Batista
@Since      16/06/2020
@Version    P12.25
@Project    EURO
@Param		 
@Param		 
@Param		 
*/
Static Function AprovPC(aAprov)

    Local cCod    := ''
    Local cQuery  := ""
    Local TRB     := GetNextAlias()
    Local aAprov  := {}

    cQuery := " SELECT AL_USER " + CRLF
    cQuery += " FROM "+RetSqlName("SAL")+" SAL" + CRLF
    cQuery += " WHERE D_E_L_E_T_ = '' " + CRLF
    cQuery += " AND AL_COD = '"+SC7->C7_APROV+"' " + CRLF

   MsAguarde({|| dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery), TRB,.F.,.T.)}, "Selecionando Registros ...")


        If (TRB)->(EOF())
            ConOut("Não há resultado na query principal do Analistas (SAL)")
            Return
        EndIf

    While (TRB)->(!EOF())
       aAdd(aAprov,(TRB)->AL_USER)
       (TRB)->(DBSKIP())    
    EndDo
Return

/*
{Protheus.doc} AprovPC
pega o limite do aprovador
@Author     Fabio Batista
@Since      16/06/2020
@Version    P12.25
@Project    EURO
            grupo de aprovadores
@Param		 
@Param		 
@Param		 
*/
/*
STATIC FUNCTION PEGLIMITE()

Local cCod    := ''
Local cQuery  := ""
Local TRB     := GetNextAlias()
Local aVal  := {}

SELECT AK_COD,AK_LIMITE,* FROM SAK000
WHERE D_E_L_E_T_=''
AND AK_COD ='000052' 

Return */
