#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

#define ENTER chr(13) + chr(10)
                            
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINM012   ºAutor  ³Tiago Beraldi       º Data ³  30/06/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Aviso de titulos vencidos por e-mail                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                     A L T E R A C O E S                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ºProgramador       ºAlteracoes                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
User Function FINM012

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Declaracoes das variaveis                                  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cQry      := ""     
Local cMensagem := ""
Local cAssunto  := ""
Local cDe       := ""
Local cPara     := ""  
Local cCCO		:= ""
Local cSrvMail  := "" //AllTrim(GetMV("MV_RELSERV"))
Local cUserAut  := "" //AllTrim(GetMV("MV_RELACNT")) 
Local cPassAut  := "" //AllTrim(GetMV("MV_RELPSW")) 
Local cAuthent	:= "" //AllTrim(GetMV("MV_RELAUTH"))
Local cNReduz	:= ""
Local cNome		:= ""
Local nTime		:= 0
Local cUsrOpc 	:= "" //Alltrim(SuperGetMV("ES_PARFIN1",.T.,""))
Local lSchdAut	:= .F.
Local cBody := ''
Local CIMAGE := ''
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se rotina esta sendo executada via Schedule				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("SX5") <= 0
	lSchdAut	:= .T.
	Prepare Environment Empresa "02" Filial "00" 
EndIf
                                                           

cUsrOpc := Alltrim(SuperGetMV("ES_PARFIN1",.T.,""))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Executa apena em dias uteis                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTime := Val(Replace(Left(Time(),5),":",""))
If lSchdAut .And. ( ( DataValida( dDatabase, .T.  ) <> dDatabase ) /*.Or. ( nTime < 1200 .Or. nTime > 1209 )*/ )
	ConOut("=======================================")
	ConOut("Agendamento FINM012 - Falha na execução")
	ConOut(DtoC(dDataBase)+" as "+Time()+" horas. ")
	ConOut("=======================================")
	Return
EndIf	

ConOut("========================================")
ConOut("Agendamento FINM012 - Execução realizada")
ConOut(DtoC(dDataBase)+" as "+Time()+" horas. ")
ConOut("========================================")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Vencidos a mais de dois dias                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// ============================================================
//  Grupo Empresa - Ajuste realizado em 31.08.20 (CG)
// ============================================================

/*
cQry := " SELECT	'01' + E1_FILIAL EMPFIL, " + ENTER
cQry += " 		    E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER
cQry += " 		    CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCTO), 103) VENCIMENTO, " + ENTER
cQry += " 		    E1_SALDO VALOR, " + ENTER
cQry += " 		    E1_PREFIXO + E1_NUM REFER, " + ENTER
cQry += " 		    RTRIM(A1_COBMAIL) + '; ' + ( SELECT RTRIM(A3_EMAIL) FROM SA3000 SA3 WHERE SA3.D_E_L_E_T_ = '' AND SA3.A3_COD = SA1.A1_VEND ) EMAIL, " + ENTER 
cQry += " 		    E1_FILIAL FILIAL, " + ENTER
cQry += " 		    E1_CLIENTE + '-' + E1_LOJA + ' - ' + A1_NOME CLIENTE " + ENTER
cQry += " FROM		SE1010 SE1, SA1010 SA1 " + ENTER
cQry += " WHERE		SE1.D_E_L_E_T_ = '' " + ENTER
cQry += " 			AND SA1.D_E_L_E_T_ = '' " + ENTER						
cQry += " 			AND A1_FILIAL = E1_FILIAL " + ENTER
cQry += " 			AND A1_COD = E1_CLIENTE " + ENTER
cQry += " 			AND A1_LOJA = E1_LOJA " + ENTER
cQry += " 			AND E1_SALDO != 0 " + ENTER   
cQry += " 			AND A1_COBMAIL != ''" + ENTER    
cQry += " 			AND E1_TIPO NOT IN ('NCC','RA') " + ENTER
cQry += " 			AND NOT E1_SITUACA IN ('4', '5', '6', 'P', 'A', 'C') " + ENTER
cQry += " 			AND E1_PORTADO != '' " + ENTER
cQry += " 			AND A1_GRPVEN != '000002'" + CRLF
cQry += " 			AND DATEDIFF(DD, E1_VENCREA, CONVERT(VARCHAR, GETDATE(), 112)) BETWEEN 1 AND 5  " + ENTER  //Alterado 24/11/2016 Between 2 AND 20

//
cQry += " UNION ALL " + ENTER
//   
cQry += " SELECT   '02' + E1_FILIAL EMPFIL, " + ENTER
cQry += " 		    E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER
cQry += " 		    CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCTO), 103) VENCIMENTO, " + ENTER
cQry += " 		    E1_SALDO VALOR, " + ENTER
cQry += " 		    E1_PREFIXO + E1_NUM REFER, " + ENTER
cQry += " 		    RTRIM(A1_COBMAIL) + '; ' + ( SELECT RTRIM(A3_EMAIL) FROM SA3000 SA3 WHERE SA3.D_E_L_E_T_ = '' AND SA3.A3_COD = SA1.A1_VEND ) EMAIL, " + ENTER 
cQry += " 		    E1_FILIAL FILIAL, " + ENTER
cQry += " 		    E1_CLIENTE + '-' + E1_LOJA + ' - ' + A1_NOME CLIENTE " + ENTER
cQry += " FROM		SE1020 SE1, SA1020 SA1 " + ENTER
cQry += " WHERE		SE1.D_E_L_E_T_ = '' " + ENTER
cQry += " 			AND SA1.D_E_L_E_T_ = '' " + ENTER						
cQry += " 			AND A1_FILIAL = E1_FILIAL " + ENTER
cQry += " 			AND A1_COD = E1_CLIENTE " + ENTER
cQry += " 			AND A1_LOJA = E1_LOJA " + ENTER
cQry += " 			AND E1_SALDO != 0 " + ENTER   
cQry += " 			AND A1_COBMAIL != ''" + ENTER    
cQry += " 			AND E1_TIPO NOT IN ('NCC','RA') " + ENTER
cQry += " 			AND NOT E1_SITUACA IN ('4', '5', '6', 'P', 'A', 'C') " + ENTER
cQry += " 			AND E1_PORTADO != '' " + ENTER
cQry += " 			AND A1_GRPVEN != '000002'" + CRLF
cQry += " 			AND (	( DATEDIFF(DD, E1_VENCREA, CONVERT(VARCHAR, GETDATE(), 112)) BETWEEN 1 AND 5 AND E1_PORTADO NOT IN ('021') ) OR " + ENTER
cQry += " 				 	(DATEDIFF(DD, E1_VENCREA, CONVERT(VARCHAR, GETDATE(), 112)) BETWEEN 2 AND 5 AND E1_PORTADO IN ('021') ) ) " + ENTER

//
cQry += " UNION ALL " + ENTER
//   
cQry += " SELECT	'03' + E1_FILIAL EMPFIL, " + ENTER
cQry += " 		    E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER
cQry += " 		    CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCTO), 103) VENCIMENTO, " + ENTER
cQry += " 		    E1_SALDO VALOR, " + ENTER
cQry += " 		    E1_PREFIXO + E1_NUM REFER, " + ENTER
cQry += " 		    RTRIM(A1_COBMAIL) + '; ' + ( SELECT RTRIM(A3_EMAIL) FROM SA3000 SA3 WHERE SA3.D_E_L_E_T_ = '' AND SA3.A3_COD = SA1.A1_VEND ) EMAIL, " + ENTER 
cQry += " 		    E1_FILIAL FILIAL, " + ENTER
cQry += " 		    E1_CLIENTE + '-' + E1_LOJA + ' - ' + A1_NOME CLIENTE " + ENTER
cQry += " FROM		SE1030 SE1, SA1030 SA1 " + ENTER
cQry += " WHERE		SE1.D_E_L_E_T_ = '' " + ENTER
cQry += " 			AND SA1.D_E_L_E_T_ = '' " + ENTER						
cQry += " 			AND A1_FILIAL = E1_FILIAL " + ENTER
cQry += " 			AND A1_COD = E1_CLIENTE " + ENTER
cQry += " 			AND A1_LOJA = E1_LOJA " + ENTER
cQry += " 			AND E1_SALDO != 0 " + ENTER   
cQry += " 			AND A1_COBMAIL != ''" + ENTER    
cQry += " 			AND E1_TIPO NOT IN ('NCC','RA') " + ENTER
cQry += " 			AND NOT E1_SITUACA IN ('4', '5', '6', 'P', 'A', 'C') " + ENTER
cQry += " 			AND E1_PORTADO != '' " + ENTER
cQry += " 			AND A1_GRPVEN != '000002'" + CRLF
cQry += " 			AND DATEDIFF(DD, E1_VENCREA, CONVERT(VARCHAR, GETDATE(), 112)) BETWEEN 2 AND 5  " + ENTER

//
cQry += " UNION ALL " + ENTER
//   
cQry += " SELECT	'08' + E1_FILIAL EMPFIL, " + ENTER
cQry += " 		    E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER
cQry += " 		    CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCTO), 103) VENCIMENTO, " + ENTER
cQry += " 		    E1_SALDO VALOR, " + ENTER
cQry += " 		    E1_PREFIXO + E1_NUM REFER, " + ENTER
cQry += " 		    RTRIM(A1_COBMAIL) + '; ' + ( SELECT RTRIM(A3_EMAIL) FROM SA3000 SA3 WHERE SA3.D_E_L_E_T_ = '' AND SA3.A3_COD = SA1.A1_VEND ) EMAIL, " + ENTER 
cQry += " 		    E1_FILIAL FILIAL, " + ENTER
cQry += " 		    E1_CLIENTE + '-' + E1_LOJA + ' - ' + A1_NOME CLIENTE " + ENTER
cQry += " FROM		SE1080 SE1, SA1080 SA1 " + ENTER
cQry += " WHERE		SE1.D_E_L_E_T_ = '' " + ENTER
cQry += " 			AND SA1.D_E_L_E_T_ = '' " + ENTER						
cQry += " 			AND A1_FILIAL = E1_FILIAL " + ENTER
cQry += " 			AND A1_COD = E1_CLIENTE " + ENTER
cQry += " 			AND A1_LOJA = E1_LOJA " + ENTER
cQry += " 			AND E1_SALDO != 0 " + ENTER   
cQry += " 			AND A1_COBMAIL != ''" + ENTER    
cQry += " 			AND E1_TIPO NOT IN ('NCC','RA') " + ENTER
cQry += " 			AND NOT E1_SITUACA IN ('4', '5', '6', 'P', 'A', 'C') " + ENTER
cQry += " 			AND E1_PORTADO != '' " + ENTER
cQry += " 			AND A1_GRPVEN != '000002'" + CRLF
cQry += " 			AND (	( DATEDIFF(DD, E1_VENCREA, CONVERT(VARCHAR, GETDATE(), 112)) BETWEEN 1 AND 5 AND E1_PORTADO NOT IN ('021') ) OR " + ENTER
cQry += " 				 	(DATEDIFF(DD, E1_VENCREA, CONVERT(VARCHAR, GETDATE(), 112)) BETWEEN 2 AND 5 AND E1_PORTADO IN ('021') ) ) " + ENTER
*/

cQry := " SELECT	E1_FILIAL EMPFIL, " + ENTER
cQry += " 		    E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER
cQry += " 		    CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCTO), 103) VENCIMENTO, " + ENTER
cQry += " 		    E1_SALDO VALOR, " + ENTER
cQry += " 		    E1_PREFIXO + E1_NUM REFER, " + ENTER
cQry += " 		    RTRIM(A1_COBMAIL) + '; ' + ( SELECT RTRIM(A3_EMAIL) FROM " + RetSqlName("SA3") + " SA3 WHERE SA3.D_E_L_E_T_ = '' AND SA3.A3_COD = SA1.A1_VEND ) EMAIL, " + ENTER 
cQry += " 		    E1_FILIAL FILIAL, " + ENTER
cQry += " 		    E1_CLIENTE + '-' + E1_LOJA + ' - ' + A1_NOME CLIENTE " + ENTER
cQry += " FROM " + RetSqlName("SE1") + " SE1, " + RetSqlName("SA1") + " SA1 " + ENTER
cQry += " WHERE		SE1.D_E_L_E_T_ = '' " + ENTER
cQry += " 			AND SA1.D_E_L_E_T_ = '' " + ENTER						
cQry += " 			AND A1_FILIAL = E1_FILIAL " + ENTER
cQry += " 			AND A1_COD = E1_CLIENTE " + ENTER
cQry += " 			AND A1_LOJA = E1_LOJA " + ENTER
cQry += " 			AND E1_SALDO != 0 " + ENTER   
cQry += " 			AND A1_COBMAIL != ''" + ENTER    
cQry += " 			AND E1_TIPO NOT IN ('NCC','RA') " + ENTER
cQry += " 			AND NOT E1_SITUACA IN ('4', '5', '6', 'P', 'A', 'C') " + ENTER
cQry += " 			AND E1_PORTADO != '' " + ENTER
cQry += " 			AND A1_GRPVEN != '000002'" + CRLF
cQry += " 			AND DATEDIFF(DD, E1_VENCREA, CONVERT(VARCHAR, GETDATE(), 112)) BETWEEN 1 AND 5  " + ENTER  //Alterado 24/11/2016 Between 2 AND 20


If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

MemoWrite("finm012_2.sql", cQry)

TCQUERY cQry NEW ALIAS QRY

While !QRY->(EOF()) 

	If Empty(QRY->EMAIL)
		QRY->(dbSkip())  
		Loop		
	EndIf                       
	                                       
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controla titulos enviados no corpo do email            ³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRefer 		:= AllTrim(QRY->REFER)	 
	cNotaFiscal := AllTrim(QRY->REFER)	      
	                    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define conta para envio                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Left(QRY->EMPFIL,2) == "02"
			ConOut("---- Inicio conexao smtp ----")    
	  		ConOut("EUROAMERICAN")
			ConOut("-----------------------------")      
			cDe := "cobranca@euroamerican.com.br"    
			cNReduz := "EUROAMERICAN"           
			cNome	:= "EUROAMERICAN DO BRASIL IMPORTAÇÃO, INDÚSTRIA E COMÉRCIO LTDA"

			cSrvMail  := AllTrim("smtp.gmail.com:587")
			cUserAut  := AllTrim("cobranca@euroamerican.com.br") 
			cPassAut  := AllTrim("Nsqeiflef#19") 			
			cAuthent  := ".T."
			ConOut("----- Fim conexao smtp -----")    
		//EndIf		
	 
	ElseIf Left(QRY->EMPFIL,2) == "03"	
			ConOut("---- Inicio conexao smtp ----")       
	  		ConOut("QUALYVINIL")
			ConOut("-----------------------------")      
		cDe := "cobranca@qualyvinil.com.br"
		cNReduz := "QUALYVINIL"                   
		cNome	:= "QUALYVINIL COMERCIAL LTDA"
		
		cSrvMail  := AllTrim("smtp.gmail.com:587")
		cUserAut  := AllTrim("cobranca@qualyvinil.com.br") 
		cPassAut  := AllTrim("Nsqeiflef#19")
		cAuthent  := ".T."
		ConOut("----- Fim conexao smtp -----")    
	ElseIf Left(QRY->EMPFIL,2) == "08"	
		ConOut("---- Inicio conexao smtp ----")    
	  	ConOut("QUALYCRIL")
		ConOut("-----------------------------")      
		cDe := "cobranca@qualyvinil.com.br"
		cNReduz := "QUALYCRIL"          
		cNome	:= "QUALYCRIL SOLUCOES PARA CONSTRUCAO CIVIL LTDA"
		
		cSrvMail  := AllTrim("smtp.gmail.com:587")
		cUserAut  := AllTrim("cobranca@qualyvinil.com.br") 
		cPassAut  := AllTrim("Nsqeiflef#19")
		cAuthent  := ".T."
		ConOut("----- Fim conexao smtp -----")    
	ElseIf Left(QRY->EMPFIL,2) == "01"// duas primeiras posições
	
		If Right(QRY->EMPFIL,2) == "06"	// duas ultimas posições
			ConOut("---- Inicio conexao smtp ----")        
	  		ConOut("DNT")
			ConOut("-----------------------------")   
			cDe := "cobranca@qualyvinil.com.br"
			cNReduz := "DNT"          
			cNome	:= "DNT Distribuidora Nacional de Tintas Ltda"
			
			cSrvMail  := AllTrim("smtp.gmail.com:587")
			cUserAut  := AllTrim("cobranca@qualyvinil.com.br") 
			cPassAut  := AllTrim("Nsqeiflef#19")
			cAuthent  := ".T."
			ConOut("----- Fim conexao smtp -----")    
		ElseIf Right(QRY->EMPFIL,2) == "07"	  
			ConOut("---- Inicio conexao smtp ----")        
	  		ConOut("JAYS TINTAS")
			ConOut("-----------------------------")   
			cDe := "cobranca@jaystintas.com.br"	//cobranca@jaystintas.com.br
			cNReduz := "JAYS TINTAS"          
			cNome	:= "JAYS TINTAS E TEXTURAS LTDA"
			
			cSrvMail  := AllTrim("smtp.gmail.com:587")	//smtp.jaystintas.com.br:587
			cUserAut  := AllTrim("cobranca@jaystintas.com.br") 
			cPassAut  := AllTrim("Nsqeiflef#19")
			cAuthent  := ".T."
			ConOut("----- Fim conexao smtp -----")    
		ElseIf Right(QRY->EMPFIL,2) == "08"	
			ConOut("---- Inicio conexao smtp ----")        
	  		ConOut("QUALYCOR")
			ConOut("-----------------------------")   
			cDe := "cobranca@qualyvinil.com.br"
			cNReduz := "QUALYCOR"      
			cNome	:= "QUALYCOR COMERCIAL LTDA"
			
			cSrvMail  := AllTrim("smtp.gmail.com:587")
			cUserAut  := AllTrim("cobranca@qualyvinil.com.br") 
			cPassAut  := AllTrim("Nsqeiflef#19")
			cAuthent  := ".T."
			ConOut("----- Fim conexao smtp -----")    
		ElseIf Right(QRY->EMPFIL,2) == "11"	
			ConOut("---- Inicio conexao smtp ----")        
	  		ConOut("MACRO CORES")
			ConOut("-----------------------------")
			cDe := "cobranca@qualyvinil.com.br"
			cNReduz := "MACRO CORES"            
			cNome	:= "MACRO CORES TINTAS E TEXTURAS LTDA"
			
			cSrvMail  := AllTrim("smtp.gmail.com:587")
			cUserAut  := AllTrim("cobranca@qualyvinil.com.br") 
			cPassAut  := AllTrim("Nsqeiflef#19")
			cAuthent  := ".T."
			ConOut("----- Fim conexao smtp -----")    
		EndIf
	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define parametros do envio                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ConOut("=========================")
	ConOut("Pegando e-mail a ser enviado para" + cPara)        
	ConOut("=========================")
	If !Empty(QRY->EMAIL)
		cPara := AllTrim(QRY->EMAIL)+";adriana.silva@euroamerican.com.br"+";fabio.batista@euroamerican.com.br"
  	Else
		cPara := "adriana.silva@euroamerican.com.br"+";fabio.batista@euroamerican.com.br"
	EndIf 
	  //cCCO		:= "ti@euroamerican.com.br;cobranca@qualyvinil.com.br;cobranca@euroamerican.com.br;" //+ cDe Alteardo 24/11/16 Para todo contas a Receber     
    cCCO := Upper(AllTrim(cUsrOpc))
//	cCCO := 'fabio-j-b@hotmail.com'

	cAssunto	:= cNReduz + " - TÍTULO EM ABERTO - " + QRY->CLIENTE

	ConOut("--------------------------------------")
	ConOut(" Inicio para escrever no HTML ")        
	ConOut("--------------------------------------")
	oProc := TWFProcess():New("100100","Notificação Titulo em Aberto ")
	oProc:NewTask('Inicio',"\workflow\html\notpendfin.html")
	oHtml:= oProc:oHtml

	If Left(QRY->EMPFIL,2) == "02" .or. Left(QRY->EMPFIL,2) == "01"
		ConOut(" Logo da euro ")        
		cImage := 'src="http://euroamerican.com.br/wp-content/uploads/2019/09/logo.png"'
	elseIf Left(QRY->EMPFIL,2) == "03" .or. Left(QRY->EMPFIL,2) == "08"
		ConOut(" Logo da Qualy ")
		cImage :=  'src="http://qualyvinil.com.br/assets/images/nav/logo_qv1.png"'
	EndIf 		

	oHtml:valbyname( "cImage"  , cImage ) 
	oHtml:valbyname( "cNotaFiscal"  , cNotaFiscal )
	oHtml:valbyname( "cDe"  , cDe )
	oHtml:valbyname( "cCliente"  , QRY->CLIENTE )

   	While !QRY->(EOF()) .And. cRefer == AllTrim(QRY->REFER)      

		aAdd( (oHtml:valbyname( "it.cNumTit" 	)), QRY->NUMERO    	) 
		aAdd( (oHtml:valbyname( "it.dVencto" 	)), QRY->VENCIMENTO 		) 
		aAdd( (oHtml:valbyname( "it.nValor"		)), Transform(QRY->VALOR, "@E 999,999,999.99"))

		QRY->(dbSkip())    
		
	EndDo    
	ConOut("--------------------------------------")
	ConOut(" Fim da escrita no HTML ")        
	ConOut("--------------------------------------")


	ConOut("-----------------------------------------------------------------------------")
	ConOut(" Inicio do envio de e-mail ")
	ConOut(cPara)        
	ConOut("-----------------------------------------------------------------------------")

	//cPara := "fabio.batista@euroamerican.com.br"
	oProc:cTo := cPara
	
	oProc:cCC := ""

	oProc:cBCC := cCCO
	oProc:cSubject := cAssunto
	oProc:Start()
	oProc:Finish()
	wfsendmail()
	ConOut("--------------------------------------")
	ConOut("------- Fim do envio de e-mail -------")        
	ConOut("--------------------------------------")

EndDo
	ConOut("----------------------------------------")
	ConOut("------- Saiu do programa FINM012 -------")        
	ConOut("----------------------------------------")

	
Return