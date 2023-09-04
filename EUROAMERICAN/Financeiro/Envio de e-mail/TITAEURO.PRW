#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "RptDef.ch"
#Include "FWPrintSetup.ch"
#Include "TopConn.ch"
#Include 'TbiConn.Ch'
#Include 'Totvs.Ch'
#Include 'Ap5Mail.Ch'

User Function TITAEURO()

Local nTime		  := 0
Local cUsrOpc 	  := "" 
Local lSchdAut	  := .F.
Local cQry        := ''
Local cSrvMail    := AllTrim("smtp.gmail.com:587")
Local cUserAut    := AllTrim("cobranca@qualyvinil.com.br") 
Local cPassAut    := AllTrim("Nsqeiflef#19")
Local cAuthent    := ".T."
Local cEmail      := ''
Local cBody       := ''
Local cAssunto    := ''
Local cImage      :=  'src="http://euroamerican.com.br/wp-content/uploads/2019/09/logo.png"'
Local cNotaFiscal := ''
Local cDe         := "cobranca@euroamerican.com.br"
Local cCliente    := ' '
Local cAttach     := ''
Local cCopia      := 'contasareceber@euroamerican.com.br'
Local cNReduz     := "EUROAMERICAN"           
Local cNome	      := "EUROAMERICAN DO BRASIL IMPORTAÇÃO, INDÚSTRIA E COMÉRCIO LTDA"

    //³ Verifico se rotina esta sendo executada via Schedule				  
    If Select("SX5") <= 0
        lSchdAut	:= .T.
    EndIf

    If lSchdAut
        Prepare Environment Empresa "02" Filial "00"                            
    EndIf

    If !cfilant == "0200"
        Alert("Essa rotina só deverá ser rodado na empresa Euro(0200)")
        Return
    EndIf

//grupo para usar no parametro cc do e-mail
cUsrOpc := Alltrim(SuperGetMV("ES_PARFIN1",.T.,""))

ConOut(DtoC(dDataBase)+" as "+Time()+" horas. ")


cQry += " SELECT   '02' + E1_FILIAL EMPFIL, " + CRLF
cQry += " 		    E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + CRLF
cQry += " 		    CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCTO), 103) VENCIMENTO, " + CRLF
cQry += " 		    E1_SALDO VALOR, " + CRLF
cQry += " 		    E1_PREFIXO + E1_NUM REFER, " + CRLF
cQry += " 		    RTRIM(A1_COBMAIL) + '; ' + ( SELECT RTRIM(A3_EMAIL) FROM "+RetSqlName("SA3")+" SA3 WHERE SA3.D_E_L_E_T_ = '' AND SA3.A3_COD = SA1.A1_VEND ) EMAIL, " + CRLF 
cQry += " 		    E1_FILIAL FILIAL, " + CRLF
cQry += " 		    E1_CLIENTE + '-' + E1_LOJA + ' - ' + A1_NOME CLIENTE " + CRLF
cQry += " FROM	"	+RetSqlName("SE1") + " SE1, "	+RetSqlName("SA1") + " SA1 " + CRLF
cQry += " WHERE		SE1.D_E_L_E_T_ = '' " + CRLF
cQry += " 			AND SA1.D_E_L_E_T_ = '' " + CRLF						
cQry += " 			AND A1_FILIAL = E1_FILIAL " + CRLF
cQry += " 			AND A1_COD = E1_CLIENTE " + CRLF
cQry += " 			AND A1_LOJA = E1_LOJA " + CRLF
cQry += " 			AND E1_SALDO != 0 " + CRLF   
cQry += " 			AND A1_COBMAIL != ''" + CRLF    
cQry += " 			AND E1_TIPO NOT IN ('NCC','RA') " + CRLF
cQry += " 			AND NOT E1_SITUACA IN ('4', '5', '6', 'P', 'A', 'C') " + CRLF
cQry += " 			AND E1_PORTADO != '' " + CRLF
cQry += " 			AND A1_GRPVEN != '000002'" + CRLF
cQry += " 			AND (	( DATEDIFF(DD, E1_VENCREA, CONVERT(VARCHAR, GETDATE(), 112)) BETWEEN 1 AND 5 AND E1_PORTADO NOT IN ('021') ) OR " + CRLF
cQry += " 				 	(DATEDIFF(DD, E1_VENCREA, CONVERT(VARCHAR, GETDATE(), 112)) BETWEEN 2 AND 5 AND E1_PORTADO IN ('021') ) ) " + CRLF
cQry += " 			AND E1_FILIAL = '" + XFILIAL("SE1")  + "' " + CRLF
cQry += "Order by NUMERO " + CRLF

If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf
 
//MemoWrite("TITATSPHON.sql", cQry)

TCQUERY cQry NEW ALIAS QRY


While !QRY->(EOF())      

    cRefer 		:= AllTrim(QRY->REFER)	 
	cNotaFiscal := AllTrim(QRY->REFER)	   
            
    cAssunto  := "EUROAMERICAN - TÍTULO EM ABERTO - " + QRY->CLIENTE
	
	If !Empty(QRY->EMAIL)
		cEmail := AllTrim(QRY->EMAIL) //+";adriana.silva@euroamerican.com.br"+";lucas.chacon@euroamerican.com.br"
      Else
		cEmail := cCopia //"adriana.silva@euroamerican.com.br"+";lucas.chacon@euroamerican.com.br"
	EndIf  
	
   // cCopia		:= Upper(AllTrim(cUsrOpc))

    cHtml := '<html> ' + CRLF
    cHtml += '	<head> ' + CRLF
    cHtml += '		<meta http-equiv="content-type" content="text/html;charset=utf-8"> ' + CRLF
    cHtml += '		<style> ' + CRLF
    cHtml += '			table 	{ ' + CRLF
    cHtml += '					border-collapse: collapse; ' + CRLF
    cHtml += '					border: 1px solid black; ' + CRLF
    cHtml += '					} ' + CRLF
    cHtml += '		</style> ' + CRLF
    cHtml += '	</head> ' + CRLF
    cHtml += '	<body> ' + CRLF
    cHtml += '		<table border="0" width="100%" align="center"> ' + CRLF
    cHtml += '			<tr rowspan="2"> ' + CRLF
    cHtml += '				<td width="100%" style=mso-number-format:"\@" align="center" VALIGN="MIDDLE" bgcolor="#ffffff"> ' + CRLF      
    cHtml += '					<img style="width:180px;height:60px;" align="left" alt="" '+cImage+'>  ' + CRLF
    cHtml += '					<br> ' + CRLF
    cHtml += '					<font face="Courier New" size="4" VALIGN="MIDDLE" color=black><strong><B>TITULO EM ABERTO</B></strong></font> ' + CRLF   
    cHtml += '				</td> ' + CRLF
    cHtml += '			</tr> ' + CRLF
    cHtml += '			<tr> ' + CRLF
    cHtml += '				<td> ' + CRLF
    cHtml += '					<font> ' + CRLF
    cHtml += '						<br> ' + CRLF
    cHtml += '						Nossos registros indicam que sua fatura referente a Nota Fiscal '+cNotaFiscal+' esta atrasada.  ' + CRLF
    cHtml += '						<br><br> ' + CRLF						
    cHtml += '						Para maiores informacoes e segunda via do boleto entre em contato atraves do endereco '+cDe+'.  ' + CRLF
    cHtml += '						<br><br> ' + CRLF
    cHtml += '						Caso ja tenha efetuado o pagamento desconsidere este e-mail. ' + CRLF
    cHtml += '						<br><br> ' + CRLF
    cHtml += '						<b>Sacado: '+AllTrim(QRY->CLIENTE)+' </b><br> ' + CRLF
    cHtml += '						<br><br> ' + CRLF
    cHtml += '					</font> ' + CRLF
    cHtml += '				</td> ' + CRLF
    cHtml += '			</tr>     ' + CRLF
    cHtml += '		</table><Br> ' + CRLF
    cHtml += '		<table border="0" width="100%" align="center" > ' + CRLF
    cHtml += '			<tr>     ' + CRLF
    cHtml += '				<td colspan="3" width="100%"style=mso-number-format:"\@" align="center" VALIGN="MIDDLE" bgcolor="#336699"> ' + CRLF      
    cHtml += '					<font face="Courier New" size="4" color="ffffff" ><B>INFORMACOES DA COBRANCA</b></Font> ' + CRLF
    cHtml += '				</td> ' + CRLF
    cHtml += '			</tr> ' + CRLF
    cHtml += '			<tr>     ' + CRLF
    cHtml += '				<td width="30%" align="center" VALIGN="MIDDLE" bgcolor="#336699"> ' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><b>N. do Titulo</b></font> ' + CRLF    
    cHtml += '				</td> ' + CRLF    
    cHtml += '				<td  width="30%" align="center" VALIGN="MIDDLE" bgcolor="#336699"> ' + CRLF      
    cHtml += '					<font face="Courier New" size="2" color=WHITE><b>Vencimento</b></font> ' + CRLF    
    cHtml += '				</td> ' + CRLF    
    cHtml += '				<td  width="40%" align="center" VALIGN="MIDDLE" bgcolor="#336699"> ' + CRLF      
    cHtml += '					<font face="Courier New" size="2" color=WHITE><b>Valor</b></font> ' + CRLF    
    cHtml += '				</td>     ' + CRLF
    cHtml += '			</tr> ' + CRLF

    While !QRY->(EOF()) .And. cRefer == AllTrim(QRY->REFER)
        cHtml += '			<tr>     ' + CRLF
        cHtml += '				<td  width="30%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE"> ' + CRLF      
        cHtml += '					<font face="Courier New" size="2">'+QRY->NUMERO+'</font> ' + CRLF    
        cHtml += '				</td>    
        cHtml += '				<td  width="30%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE"> ' + CRLF      
        cHtml += '					<font face="Courier New" size="2">'+QRY->VENCIMENTO+'</font> ' + CRLF
        cHtml += '				</td>     ' + CRLF
        cHtml += '				<td  width="40%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE"> ' + CRLF      
        cHtml += '					<font face="Courier New" size="2">'+Transform(QRY->VALOR, "@E 999,999,999.99")+'</font> ' + CRLF    
        cHtml += '				</td>    
        cHtml += '			</tr>

        QRY->(dbSkip())    
            
    EndDo    

    cHtml += '		</table>
    cHtml += '		<Hr>
    cHtml += '		<font face="Arial" size="1"><I>Powered by TI Euroamerican</I></font>  <font face="Arial" size="1" color="#FFFFFF">%cCodUsr% %cIDWF% %cFuncao%</font><br> ' + CRLF
    cHtml += '		<font face="Arial" size="3"><B>Euroamerican do Brasil Imp Ind e Com LTDA</B></font><br/> ' + CRLF
    cHtml += '	</body> ' + CRLF
    cHtml += '</html> ' + CRLF

    cBody := cHtml
    //cEmail := 'fabio.batista@euroamerican.com.br'
    //cEmail := 'lucas.chacon@euroamerican.com.br'
    //cCopia := ''//'fabio-j-b@hotmail.com.com'
    ConOut("***********************************************")
	ConOut(" Envindo e-mail para " + cEmail)        
	ConOut("***********************************************")
    u_FSENVMAIL(cAssunto, cBody, cEmail,cAttach,,,,,,,,cCopia,)
EndDo

//RESET ENVIRONMENT

Return
