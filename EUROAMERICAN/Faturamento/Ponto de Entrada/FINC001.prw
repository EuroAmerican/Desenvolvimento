#include 'Protheus.ch'
#include "topconn.ch"

#define ENTER CHR(13) + CHR(10)  
/*/{Protheus.doc} FINC001
//Utilizado em conjunto com FC010BOL para da tela de títulos abertos ou recebidos.
@author emerson paiva
@since 27/03/2018
@version 1.0
/*/

User Function FINC001(aCampos, nOpc, cAux)
//Baseado rotina VLDCAMPO

Local aArea  := GetArea()
Local xRet  
lOCAL cQry   := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Objetivo: Verifica titulos em atraso e pedidos em aberto para o cliente                  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
If nOpc == 8

	cCliente	:= &(aCampos[1])    
	cCond		:= AllTrim(Posicione("SE4", 1, xFilial("SE4") + &(aCampos[2]), "E4_COND")) 
	lAVista		:= .F.
	
	//Pagamento a Vista 
	If (cCond == "0" .Or. cCond == "1")
		lAVista := .T.
	EndIf  
	
	// Verifica titulos em aberto para o cliente
	cQry := " SELECT	E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER
	cQry += " 	   		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCIMENTO, " + ENTER
	cQry += " 	   		DATEDIFF(dd, E1_VENCREA, '" + DtoS(dDataBase) + "') DIAS, " + ENTER	
	cQry += " 			E1_SALDO VALOR, " + ENTER
	cQry += " 			--E1_BLQATR BLQ, " + ENTER
	cQry += " 			E1_NATUREZ NATUREZA, " + ENTER	
	cQry += " 			E1_CLIENTE+E1_LOJA CLIENTE, " + ENTER	
	cQry += " 			E1_HIST AS HISTORICO " + ENTER
	cQry += " FROM	" + RetSqlName("SE1") + ENTER
	cQry += " WHERE		D_E_L_E_T_ = '' " + ENTER 
	cQry += " 			AND E1_FILIAL = '" + xFilial("SE1") + "' " + ENTER
	cQry += " 			AND E1_SALDO != 0 " + ENTER
	cQry += " 			AND E1_TIPO != 'NCC' " + ENTER
	cQry += " 			AND E1_VENCREA < CONVERT(VARCHAR, GETDATE(), 112) " + ENTER
	cQry += " 			AND E1_CLIENTE = '" + cCliente + "' " + ENTER
	cQry += " ORDER BY E1_VENCREA "		
	                                                                       	
	MemoWrite("FINC008.sql", cQry) 
	
	TCQUERY cQry NEW ALIAS FINC008
	
	dbSelectArea("FINC008")
	dbGoTop() 
	
	If !FINC008->(EOF())

		cTxt := "=============================================" + ENTER
		cTxt += "CLIENTE APRESENTA PENDÊNCIAS FINANCEIRAS.    " + ENTER		              
		cTxt += "FAVOR ENTRAR EM CONTATO COM DEPTO. FINANCEIRO" + ENTER
		cTxt += "PELO TELEFONE (11)4619-8400.                 " + ENTER		              
		cTxt += "=============================================" + ENTER
		cTxt += "N. TITULO      VENCIMENTO     VALOR          " + ENTER
		cTxt += "=============================================" + ENTER
		
		While !FINC008->(EOF())
			cTxt += PadR(FINC008->NUMERO, 15) + PadR(FINC008->VENCIMENTO, 15) + PadL(Transform(FINC008->VALOR, "@E 999,999.99"), 12) + ENTER   
                                                                                       
   			// Regra sera ignorada para titulos com natureza 005-Funcionarios ou 008-Representantes 
   			// ou emitidos para 000996-01 VIACORES ( SOLICITACAO 016678 )
   			// ou Empresa Euroamerican 000667-01 MAS negociação cliente Gerson conforme e-mail 22/09/17 - Emerson Paiva
			If AllTrim(FINC008->NATUREZA) $ "005#008" .Or. AllTrim(FINC008->CLIENTE) == "00099601" .Or. ( cEmpAnt $ "02" .And. FINC008->CLIENTE $ "00066701" )
				FINC008->(dbSkip())
				Loop
			EndIf
				
			If FINC008->DIAS > 5 .And. /*FINC008->BLQ != "N" .And.*/ !lAVista .And. ( !IsInCallStack("U_FATX008E") .Or. !IsInCallStack("U_FATM025") )
				cCliente := ""			
			EndIf

			FINC008->(dbSkip())
		EndDo    
	
		cTxt += "=============================================" + ENTER
				
		oFontLoc := TFont():New("Mono AS", 06, 15)
		DEFINE MSDIALOG oDlg TITLE "Posição do Cliente" FROM 015,020 TO 032,61 
		@ 0.5,0.7  GET oGet VAR cTxt OF oDlg MEMO SIZE 150,118 READONLY COLOR CLR_BLACK,CLR_HGRAY
		oGet:oFont     := oFontLoc
		oGet:bRClicked := {||AllwaysTrue()}
		ACTIVATE MSDIALOG oDlg Centered
		oFontLoc:End()
	EndIf  
	FINC008->(dbCloseArea())          
	
	// Verifica pedidos em aberto para o cliente    
	If RTrim(FunName())=="MATA410"
		
		cQry := " SELECT " + ENTER	
		cQry += " 		C6_NUM PEDIDO, " + ENTER
		cQry += "		C6_PRODUTO PRODUTO, " + ENTER
		cQry += "		C6_QTDVEN QTDVEN " + ENTER
		cQry += " FROM	" + ENTER
		cQry += "		" + RetSqlName("SC6") + ENTER
		cQry += " WHERE " + ENTER
		cQry += "		D_E_L_E_T_ = '' " + ENTER
		cQry += "		AND C6_FILIAL = '" + xFilial("SC6") + "' " + ENTER
		cQry += "		AND C6_CLI = '" + cCliente + "' " + ENTER
		cQry += "		AND C6_NOTA = '' " + ENTER
		cQry += "		AND C6_BLQ = '' " + ENTER		
		 
		TCQUERY cQry NEW ALIAS FINC008
		
		dbSelectArea("FINC008")
		dbGoTop() 
		
		If !FINC008->(EOF())
	
			cTxt := "PEDIDOS DE VENDA - EM ABERTO                 " + ENTER
			cTxt += "=============================================" + ENTER
			cTxt += "NUMERO  PRODUTO         QUANTIDADE           " + ENTER
			cTxt += "=============================================" + ENTER
			
			While !FINC008->(EOF())
				cTxt += PadR(FINC008->PEDIDO, 8) + PadR(FINC008->PRODUTO, 17) + PadL(Transform(FINC008->QTDVEN, "@E 999,999.99"), 12) + ENTER
				FINC008->(dbSkip())
			EndDo    
		
			cTxt += "=============================================" + ENTER
			              
			oFontLoc := TFont():New("Mono AS", 06, 15)
			DEFINE MSDIALOG oDlg TITLE "Posição do Cliente" FROM 015,020 TO 032,61 
			@ 0.5,0.7  GET oGet VAR cTxt OF oDlg MEMO SIZE 150,118 READONLY COLOR CLR_BLACK,CLR_HGRAY
			oGet:oFont     := oFontLoc
			oGet:bRClicked := {||AllwaysTrue()}
			ACTIVATE MSDIALOG oDlg Centered
			oFontLoc:End()
		EndIf
	
		FINC008->(dbCloseArea())

	EndIf      
	
	If RTrim(FunName()) == "MATA415" .And. cCliente != "000001" .And. Upper(AllTrim(GetEnvServer())) == "PDV" 
		
		SA1->(dbSetOrder(1))	
		SA1->(dbSeek(xFilial("SA1") + cCliente))
		
		If .Not. SA1->A1_VEND $ U_FATX008V()  
			cCliente := ""
		EndIf
		
	EndIf                                                      
	         
	xRet := cCliente
	
EndIf 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Objetivo: Verifica titulos pagos na empresa 0203 - Qualyvinil Comercial                  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
If nOpc == 17

	cCliente	:= &(aCampos[1]) 
	cCliLoja	:= &(aCampos[3])   //Inclusão realizada em 22/04/16
                                                     
	// Verifica titulos em aberto para o cliente
	/*
	If cEmpAnt + cFilAnt $  "100304"
		cQry := " SELECT " + ENTER		
		cQry += " 		'01'+E1_FILIAL EMPRESA, " + ENTER		
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_BAIXA), 103) BAIXA, " + ENTER  
		cQry += " 		DATEDIFF(DD, E1_VENCREA, E1_BAIXA) ATRASO, " + ENTER
		cQry += " 		E1_BAIXA BAIXAORD, " + ENTER
		cQry += " 		E1_JUROS JUROS, " + ENTER
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_HIST HIST, " + ENTER
		cQry += " 		(SELECT MAX(E5_MOTBX) FROM SE5020 WHERE D_E_L_E_T_ = '' AND E5_FILIAL = E1_FILIAL AND E5_NUMERO = E1_NUM AND E5_PREFIXO = E1_PREFIXO AND E5_PARCELA = E1_PARCELA AND E5_CLIENTE = E1_CLIENTE AND E5_LOJA = E1_LOJA) MTBX, " + ENTER
		cQry += " 		E1_VALOR VALOR " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		SE1010 " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		cQry += "  		AND E1_FILIAL IN ('06','08') " + ENTER 
		cQry += "  		AND E1_SALDO = 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = ( SELECT TOP 1 SA1_A.A1_COD FROM SA1010 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('06','08') AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM SA1030 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '04' AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += "		AND E1_LOJA = ( SELECT TOP 1  SA1_A.A1_LOJA FROM SA1010 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('06','08') AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM SA1030 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '04' AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += " UNION ALL " + ENTER
		cQry += " SELECT " + ENTER		
		cQry += " 		'02'+E1_FILIAL EMPRESA, " + ENTER		
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_BAIXA), 103) BAIXA, " + ENTER  
		cQry += " 		DATEDIFF(DD, E1_VENCREA, E1_BAIXA) ATRASO, " + ENTER
		cQry += " 		E1_BAIXA BAIXAORD, " + ENTER
		cQry += " 		E1_JUROS JUROS, " + ENTER
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_HIST HIST, " + ENTER
		cQry += " 		(SELECT MAX(E5_MOTBX) FROM SE5020 WHERE D_E_L_E_T_ = '' AND E5_FILIAL = E1_FILIAL AND E5_NUMERO = E1_NUM AND E5_PREFIXO = E1_PREFIXO AND E5_PARCELA = E1_PARCELA AND E5_CLIENTE = E1_CLIENTE AND E5_LOJA = E1_LOJA) MTBX, " + ENTER
		cQry += " 		E1_VALOR VALOR " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		SE1020 " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		cQry += "  		AND E1_FILIAL = '03' " + ENTER 
		cQry += "  		AND E1_SALDO = 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = ( SELECT TOP 1 SA1_A.A1_COD FROM SA1020 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('03') AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM SA1030 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '04' AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += "		AND E1_LOJA = ( SELECT TOP 1 SA1_A.A1_LOJA FROM SA1020 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('03') AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM SA1030 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '04' AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += " UNION ALL " + ENTER
		cQry += " SELECT " + ENTER		
		cQry += " 		'0303' EMPRESA, " + ENTER
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER    
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_BAIXA), 103) BAIXA, " + ENTER  
		cQry += " 		DATEDIFF(DD, E1_VENCREA, E1_BAIXA) ATRASO, " + ENTER
		cQry += " 		E1_BAIXA BAIXAORD, " + ENTER   
		cQry += " 		E1_JUROS JUROS, " + ENTER	
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_HIST HIST, " + ENTER
		cQry += " 		(SELECT MAX(E5_MOTBX) FROM SE5030 WHERE D_E_L_E_T_ = '' AND E5_FILIAL = E1_FILIAL AND E5_NUMERO = E1_NUM AND E5_PREFIXO = E1_PREFIXO AND E5_PARCELA = E1_PARCELA AND E5_CLIENTE = E1_CLIENTE AND E5_LOJA = E1_LOJA) MTBX, " + ENTER
		cQry += " 		E1_VALOR VALOR " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		SE1030 " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		cQry += "  		AND E1_FILIAL = '03' " + ENTER 
		cQry += "  		AND E1_SALDO = 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = ( SELECT TOP 1 SA1_A.A1_COD FROM SA1030 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('03') AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM SA1030 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '04' AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += "		AND E1_LOJA = ( SELECT TOP 1 SA1_A.A1_LOJA FROM SA1030 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('03') AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM SA1030 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '04' AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += " ORDER BY " + ENTER 
		cQry += " 		BAIXAORD DESC"   
	ElseIf cEmpAnt + cFilAnt $  "0200"
		cQry := " SELECT " + ENTER	
		cQry += " 		'0205' EMPRESA, " + ENTER	
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_BAIXA), 103) BAIXA, " + ENTER  
		cQry += " 		DATEDIFF(DD, E1_VENCREA, E1_BAIXA) ATRASO, " + ENTER
		cQry += " 		E1_BAIXA BAIXAORD, " + ENTER
		cQry += " 		E1_JUROS JUROS, " + ENTER
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_HIST HIST, " + ENTER
		cQry += " 		(SELECT MAX(E5_MOTBX) FROM SE5020 WHERE D_E_L_E_T_ = '' AND E5_FILIAL = E1_FILIAL AND E5_NUMERO = E1_NUM AND E5_PREFIXO = E1_PREFIXO AND E5_PARCELA = E1_PARCELA AND E5_CLIENTE = E1_CLIENTE AND E5_LOJA = E1_LOJA) MTBX, " + ENTER
		cQry += " 		E1_VALOR VALOR " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		SE1020 " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		cQry += "  		AND E1_FILIAL = '05' " + ENTER 
		cQry += "  		AND E1_SALDO = 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = ( SELECT TOP 1 SA1_A.A1_COD FROM SA1020 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('05') AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM SA1020 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '00' AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += "		AND E1_LOJA = ( SELECT TOP 1 SA1_A.A1_LOJA FROM SA1020 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('05') AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM SA1020 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '00' AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += " ORDER BY " + ENTER 
		cQry += " 		BAIXAORD DESC"   	
	ElseIf cEmpAnt $  "08"
		cQry := " SELECT " + ENTER		
		cQry += " 		'01'+E1_FILIAL EMPRESA, " + ENTER		
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_BAIXA), 103) BAIXA, " + ENTER  
		cQry += " 		DATEDIFF(DD, E1_VENCREA, E1_BAIXA) ATRASO, " + ENTER
		cQry += " 		E1_BAIXA BAIXAORD, " + ENTER
		cQry += " 		E1_JUROS JUROS, " + ENTER
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_HIST HIST, " + ENTER
		cQry += " 		(SELECT MAX(E5_MOTBX) FROM SE5020 WHERE D_E_L_E_T_ = '' AND E5_FILIAL = E1_FILIAL AND E5_NUMERO = E1_NUM AND E5_PREFIXO = E1_PREFIXO AND E5_PARCELA = E1_PARCELA AND E5_CLIENTE = E1_CLIENTE AND E5_LOJA = E1_LOJA) MTBX, " + ENTER
		cQry += " 		E1_VALOR VALOR " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		SE1010 " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		cQry += "  		AND E1_FILIAL IN ('06','08') " + ENTER 
		cQry += "  		AND E1_SALDO = 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = ( SELECT TOP 1 SA1_A.A1_COD FROM SA1010 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('06,08') AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM SA1080 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '" + cFilAnt + "'  AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += "		AND E1_LOJA = ( SELECT TOP 1 SA1_A.A1_LOJA FROM SA1010 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('06,08') AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM SA1080 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '" + cFilAnt + "' AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += " UNION ALL " + ENTER
		cQry += " SELECT " + ENTER	
		cQry += " 		'02'+E1_FILIAL EMPRESA, " + ENTER	
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_BAIXA), 103) BAIXA, " + ENTER  
		cQry += " 		DATEDIFF(DD, E1_VENCREA, E1_BAIXA) ATRASO, " + ENTER
		cQry += " 		E1_BAIXA BAIXAORD, " + ENTER
		cQry += " 		E1_JUROS JUROS, " + ENTER
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_HIST HIST, " + ENTER
		cQry += " 		(SELECT MAX(E5_MOTBX) FROM SE5020 WHERE D_E_L_E_T_ = '' AND E5_FILIAL = E1_FILIAL AND E5_NUMERO = E1_NUM AND E5_PREFIXO = E1_PREFIXO AND E5_PARCELA = E1_PARCELA AND E5_CLIENTE = E1_CLIENTE AND E5_LOJA = E1_LOJA) MTBX, " + ENTER
		cQry += " 		E1_VALOR VALOR " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		SE1020 " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		cQry += "  		AND E1_FILIAL = '03' " + ENTER 
		cQry += "  		AND E1_SALDO = 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = ( SELECT TOP 1 SA1_A.A1_COD FROM SA1020 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('03') AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM SA1080 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '" + cFilAnt + "' AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += "		AND E1_LOJA = ( SELECT TOP 1 SA1_A.A1_LOJA FROM SA1020 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('03') AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM SA1080 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '" + cFilAnt + "' AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += " UNION ALL " + ENTER
		cQry += " SELECT " + ENTER		
		cQry += " 		'03'+E1_FILIAL EMPRESA, " + ENTER
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER    
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_BAIXA), 103) BAIXA, " + ENTER  
		cQry += " 		DATEDIFF(DD, E1_VENCREA, E1_BAIXA) ATRASO, " + ENTER
		cQry += " 		E1_BAIXA BAIXAORD, " + ENTER   
		cQry += " 		E1_JUROS JUROS, " + ENTER	
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_HIST HIST, " + ENTER
		cQry += " 		(SELECT MAX(E5_MOTBX) FROM SE5030 WHERE D_E_L_E_T_ = '' AND E5_FILIAL = E1_FILIAL AND E5_NUMERO = E1_NUM AND E5_PREFIXO = E1_PREFIXO AND E5_PARCELA = E1_PARCELA AND E5_CLIENTE = E1_CLIENTE AND E5_LOJA = E1_LOJA) MTBX, " + ENTER
		cQry += " 		E1_VALOR VALOR " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		SE1030 " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		cQry += "  		AND E1_FILIAL IN ('03','04') " + ENTER 
		cQry += "  		AND E1_SALDO = 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = ( SELECT TOP 1 SA1_A.A1_COD FROM SA1030 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('03','04') AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM SA1080 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '" + cFilAnt + "' AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += "		AND E1_LOJA = ( SELECT TOP 1 SA1_A.A1_LOJA FROM SA1030 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('03','04') AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM SA1080 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '" + cFilAnt + "' AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		
		If cEmpAnt + cFilAnt $  "0803"
			cQry += " UNION ALL " + ENTER
			cQry += " SELECT " + ENTER		
			cQry += " 		'08'+E1_FILIAL EMPRESA, " + ENTER
			cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER    
			cQry += " 		E1_TIPO TIPO, " + ENTER
			cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
			cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
			cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_BAIXA), 103) BAIXA, " + ENTER  
			cQry += " 		DATEDIFF(DD, E1_VENCREA, E1_BAIXA) ATRASO, " + ENTER
			cQry += " 		E1_BAIXA BAIXAORD, " + ENTER   
			cQry += " 		E1_JUROS JUROS, " + ENTER	
			cQry += " 		E1_PORTADO BCO, " + ENTER
			cQry += " 		E1_HIST HIST, " + ENTER
			cQry += " 		(SELECT MAX(E5_MOTBX) FROM SE5030 WHERE D_E_L_E_T_ = '' AND E5_FILIAL = E1_FILIAL AND E5_NUMERO = E1_NUM AND E5_PREFIXO = E1_PREFIXO AND E5_PARCELA = E1_PARCELA AND E5_CLIENTE = E1_CLIENTE AND E5_LOJA = E1_LOJA) MTBX, " + ENTER
			cQry += " 		E1_VALOR VALOR " + ENTER
			cQry += " FROM " + ENTER	
			cQry += " 		SE1080 " + ENTER
			cQry += " WHERE " + ENTER		
			cQry += " 		D_E_L_E_T_ = '' " + ENTER 
			cQry += "  		AND E1_FILIAL IN ('01') " + ENTER 
			cQry += "  		AND E1_SALDO = 0 " + ENTER 
			cQry += "  		AND E1_CLIENTE = ( SELECT TOP 1 SA1_A.A1_COD FROM SA1080 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('01') AND SA1_A.A1_CGC = "
			cQry += "  			( SELECT A1_CGC FROM SA1080 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '" + cFilAnt + "' AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
			cQry += "		AND E1_LOJA = ( SELECT TOP 1 SA1_A.A1_LOJA FROM SA1080 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('01') AND SA1_A.A1_CGC = "
			cQry += "  			( SELECT A1_CGC FROM SA1080 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '" + cFilAnt + "' AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
			
		EndIf
		
		cQry += " ORDER BY " + ENTER 
		cQry += " 		BAIXAORD DESC" 

	ElseIf cEmpAnt $  "09"
		cQry := " SELECT " + ENTER		
		cQry += " 		'01'+E1_FILIAL EMPRESA, " + ENTER		
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_BAIXA), 103) BAIXA, " + ENTER  
		cQry += " 		DATEDIFF(DD, E1_VENCREA, E1_BAIXA) ATRASO, " + ENTER
		cQry += " 		E1_BAIXA BAIXAORD, " + ENTER
		cQry += " 		E1_JUROS JUROS, " + ENTER
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_HIST HIST, " + ENTER
		cQry += " 		(SELECT MAX(E5_MOTBX) FROM SE5020 WHERE D_E_L_E_T_ = '' AND E5_FILIAL = E1_FILIAL AND E5_NUMERO = E1_NUM AND E5_PREFIXO = E1_PREFIXO AND E5_PARCELA = E1_PARCELA AND E5_CLIENTE = E1_CLIENTE AND E5_LOJA = E1_LOJA) MTBX, " + ENTER
		cQry += " 		E1_VALOR VALOR " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		SE1010 " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		cQry += "  		AND E1_FILIAL IN ('06','08') " + ENTER 
		cQry += "  		AND E1_SALDO = 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = ( SELECT TOP 1 SA1_A.A1_COD FROM SA1010 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('06,08') AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM SA1080 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '" + cFilAnt + "'  AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += "		AND E1_LOJA = ( SELECT TOP 1 SA1_A.A1_LOJA FROM SA1010 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('06,08') AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM SA1080 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '" + cFilAnt + "' AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += " UNION ALL " + ENTER
		cQry += " SELECT " + ENTER	
		cQry += " 		'02'+E1_FILIAL EMPRESA, " + ENTER	
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_BAIXA), 103) BAIXA, " + ENTER  
		cQry += " 		DATEDIFF(DD, E1_VENCREA, E1_BAIXA) ATRASO, " + ENTER
		cQry += " 		E1_BAIXA BAIXAORD, " + ENTER
		cQry += " 		E1_JUROS JUROS, " + ENTER
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_HIST HIST, " + ENTER
		cQry += " 		(SELECT MAX(E5_MOTBX) FROM SE5020 WHERE D_E_L_E_T_ = '' AND E5_FILIAL = E1_FILIAL AND E5_NUMERO = E1_NUM AND E5_PREFIXO = E1_PREFIXO AND E5_PARCELA = E1_PARCELA AND E5_CLIENTE = E1_CLIENTE AND E5_LOJA = E1_LOJA) MTBX, " + ENTER
		cQry += " 		E1_VALOR VALOR " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		SE1020 " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		cQry += "  		AND E1_FILIAL = '03' " + ENTER 
		cQry += "  		AND E1_SALDO = 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = ( SELECT TOP 1 SA1_A.A1_COD FROM SA1020 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('03') AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM SA1080 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '" + cFilAnt + "' AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += "		AND E1_LOJA = ( SELECT TOP 1 SA1_A.A1_LOJA FROM SA1020 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('03') AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM SA1080 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '" + cFilAnt + "' AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += " UNION ALL " + ENTER
		cQry += " SELECT " + ENTER		
		cQry += " 		'03'+E1_FILIAL EMPRESA, " + ENTER
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER    
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_BAIXA), 103) BAIXA, " + ENTER  
		cQry += " 		DATEDIFF(DD, E1_VENCREA, E1_BAIXA) ATRASO, " + ENTER
		cQry += " 		E1_BAIXA BAIXAORD, " + ENTER   
		cQry += " 		E1_JUROS JUROS, " + ENTER	
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_HIST HIST, " + ENTER
		cQry += " 		(SELECT MAX(E5_MOTBX) FROM SE5030 WHERE D_E_L_E_T_ = '' AND E5_FILIAL = E1_FILIAL AND E5_NUMERO = E1_NUM AND E5_PREFIXO = E1_PREFIXO AND E5_PARCELA = E1_PARCELA AND E5_CLIENTE = E1_CLIENTE AND E5_LOJA = E1_LOJA) MTBX, " + ENTER
		cQry += " 		E1_VALOR VALOR " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		SE1030 " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		cQry += "  		AND E1_FILIAL IN ('03','04') " + ENTER 
		cQry += "  		AND E1_SALDO = 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = ( SELECT TOP 1 SA1_A.A1_COD FROM SA1030 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('03','04') AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM SA1080 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '" + cFilAnt + "' AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += "		AND E1_LOJA = ( SELECT TOP 1 SA1_A.A1_LOJA FROM SA1030 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('03','04') AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM SA1080 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '" + cFilAnt + "' AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += " UNION ALL " + ENTER
		cQry += " SELECT " + ENTER		
		cQry += " 		'08'+E1_FILIAL EMPRESA, " + ENTER
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER    
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_BAIXA), 103) BAIXA, " + ENTER  
		cQry += " 		DATEDIFF(DD, E1_VENCREA, E1_BAIXA) ATRASO, " + ENTER
		cQry += " 		E1_BAIXA BAIXAORD, " + ENTER   
		cQry += " 		E1_JUROS JUROS, " + ENTER	
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_HIST HIST, " + ENTER
		cQry += " 		(SELECT MAX(E5_MOTBX) FROM SE5030 WHERE D_E_L_E_T_ = '' AND E5_FILIAL = E1_FILIAL AND E5_NUMERO = E1_NUM AND E5_PREFIXO = E1_PREFIXO AND E5_PARCELA = E1_PARCELA AND E5_CLIENTE = E1_CLIENTE AND E5_LOJA = E1_LOJA) MTBX, " + ENTER
		cQry += " 		E1_VALOR VALOR " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		SE1080 " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		cQry += "  		AND E1_FILIAL IN ('01','03') " + ENTER 
		cQry += "  		AND E1_SALDO = 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = ( SELECT TOP 1 SA1_A.A1_COD FROM SA1080 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('01','03') AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM SA1090 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '" + cFilAnt + "' AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += "		AND E1_LOJA = ( SELECT TOP 1 SA1_A.A1_LOJA FROM SA1080 SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL IN ('01','03') AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM SA1090 SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '" + cFilAnt + "' AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += " ORDER BY " + ENTER 
		cQry += " 		BAIXAORD DESC" 
	EndIf		
	*/
		cQry := " SELECT " + ENTER	
		cQry += " 		E1_FILIAL EMPRESA, " + ENTER	
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_BAIXA), 103) BAIXA, " + ENTER  
		cQry += " 		DATEDIFF(DD, E1_VENCREA, E1_BAIXA) ATRASO, " + ENTER
		cQry += " 		E1_BAIXA BAIXAORD, " + ENTER
		cQry += " 		E1_JUROS JUROS, " + ENTER
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_HIST HIST, " + ENTER
		cQry += " 		(SELECT MAX(E5_MOTBX) FROM " + RetSqlName("SE5") + " WHERE D_E_L_E_T_ = '' AND E5_FILIAL = E1_FILIAL AND E5_NUMERO = E1_NUM AND E5_PREFIXO = E1_PREFIXO AND E5_PARCELA = E1_PARCELA AND E5_CLIENTE = E1_CLIENTE AND E5_LOJA = E1_LOJA) MTBX, " + ENTER
		cQry += " 		E1_VALOR VALOR " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		" + RetSqlName("SE1") + " " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		//cQry += "  		AND E1_FILIAL = '05' " + ENTER 
		cQry += "  		AND E1_SALDO = 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = ( SELECT TOP 1 SA1_A.A1_COD FROM " + RetSqlName("SA1") + " SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL = E1_FILIAL AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM " + RetSqlName("SA1") + " SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = E1_FILIAL AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += "		AND E1_LOJA = ( SELECT TOP 1 SA1_A.A1_LOJA FROM " + RetSqlName("SA1") + " SA1_A WHERE SA1_A.D_E_L_E_T_ = '' AND SA1_A.A1_FILIAL = E1_FILIAL AND SA1_A.A1_CGC = "
		cQry += "  			( SELECT A1_CGC FROM " + RetSqlName("SA1") + " SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = E1_FILIAL AND SA1.A1_COD = '" + cCliente + "' AND SA1.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += " ORDER BY " + ENTER 
		cQry += " 		BAIXAORD DESC"   	
		                                                                       	
	MemoWrite("FINC017.sql", cQry) 
	
	TCQUERY cQry NEW ALIAS FINC017
	
	dbSelectArea("FINC017")
	dbGoTop() 
	
	If !FINC017->(EOF())
                  
		cTxtIt := ""       
		aTotal := {0, 0, 0}
		While !FINC017->(EOF())
			cTxtIt += PadR(FINC017->EMPRESA, 5) + ;
						 PadR(FINC017->NUMERO, 15) + ;
						 PadR(FINC017->TIPO, 5) + ;
						 PadR(FINC017->EMISSAO, 15) + ;
						 PadR(FINC017->VENCTO, 15) + ;
						 PadR(FINC017->BAIXA, 15) + ;
						 PadL(Transform(FINC017->VALOR, "@E 999,999.99"), 12) + ;
						 PadC(Transform(FINC017->ATRASO, "9999"), 8) + ;
 						 PadR(FINC017->BCO, 5) + ;
 						 PadR(FINC017->HIST, 25) + ;
  						 PadR(FINC017->MTBX, 5) + ENTER

			aTotal[1] += 1 
			aTotal[2] += Iif(FINC017->TIPO == "NCC", 0, FINC017->VALOR)
			aTotal[3] += Iif(FINC017->TIPO == "NCC", -FINC017->VALOR, FINC017->VALOR) + FINC017->JUROS
			FINC017->(dbSkip())
		EndDo    

		cTxt := "===========================================================================================================================" + ENTER
		cTxt += "# TÍTULOS.......: " + Transform(aTotal[1], "9999") /*+ " - Cliente: " + cCliente + cCliLoja*/  + ENTER		              
		cTxt += "VLR PRINCIPAL...: " + Transform(aTotal[2], "@E 999,999,999.99") + ENTER
		cTxt += "VLR PAGO........: " + Transform(aTotal[3], "@E 999,999,999.99") + ENTER
		cTxt += "===========================================================================================================================" + ENTER
		cTxt += "EMPR N. TITULO      TIPO EMISSAO        VENCIMENTO     BAIXA          VALOR       ATRASO  BCO                HISTORICO MTBX" + ENTER
		cTxt += "===========================================================================================================================" + ENTER
		cTxt += cTxtIt
		cTxt += "===========================================================================================================================" + ENTER
				
		oFontLoc := TFont():New("Mono AS", 06, 15)
		DEFINE MSDIALOG oDlg TITLE "Títulos Baixados" FROM 015,020 TO 044,120 
		@ 0.5,0.7  GET oGet VAR cTxt OF oDlg MEMO SIZE 385,208 READONLY COLOR CLR_BLACK,CLR_HGRAY
		oGet:oFont     := oFontLoc
		oGet:bRClicked := {||AllwaysTrue()}
		ACTIVATE MSDIALOG oDlg Centered
		oFontLoc:End()
	EndIf  
	
	FINC017->(dbCloseArea())
	         
	xRet := cCliente
	
EndIf

If nOpc == 23

	cCliente	:= &(aCampos[1]) 
	cCliLoja	:= &(aCampos[3])   //Inclusão realizada em 22/04/16
                                                     
	// Verifica titulos em aberto para o cliente
	/*
	If cEmpAnt + cFilAnt $  "0304"
		cQry := " SELECT " + ENTER
		cQry += " 		'01' + E1_FILIAL EMPRESA, " + ENTER		
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		DATEDIFF(DD, E1_VENCREA, GETDATE()) ATRASO, " + ENTER
		cQry += " 		E1_JUROS JUROS, " + ENTER
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_SALDO SALDO, " + ENTER
		cQry += " 		E1_VALOR VALOR, " + ENTER
		cQry += " 		E1_HIST HISTORICO " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		SE1010 " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		cQry += "  		AND E1_FILIAL IN ('06','08') " + ENTER 
		cQry += "  		AND E1_SALDO > 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = '" + cCliente + "'" + ENTER
		cQry += " UNION ALL " + ENTER
		cQry += " SELECT " + ENTER
		cQry += " 		'0203' EMPRESA, " + ENTER		
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		DATEDIFF(DD, E1_VENCREA, GETDATE()) ATRASO, " + ENTER
		cQry += " 		E1_JUROS JUROS, " + ENTER
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_SALDO SALDO, " + ENTER
		cQry += " 		E1_VALOR VALOR, " + ENTER
		cQry += " 		E1_HIST HISTORICO " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		SE1020 " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		cQry += "  		AND E1_FILIAL = '03' " + ENTER 
		cQry += "  		AND E1_SALDO > 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = '" + cCliente + "'" + ENTER
		cQry += " UNION ALL " + ENTER
		cQry += " SELECT " + ENTER		
		cQry += " 		'0303' EMPRESA, " + ENTER
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER    
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		DATEDIFF(DD, E1_VENCREA, GETDATE()) ATRASO, " + ENTER
		cQry += " 		E1_JUROS JUROS, " + ENTER	
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_SALDO SALDO, " + ENTER
		cQry += " 		E1_VALOR VALOR, " + ENTER
		cQry += " 		E1_HIST HISTORICO " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		SE1030 " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		cQry += "  		AND E1_FILIAL = '03' " + ENTER 
		cQry += "  		AND E1_SALDO > 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = '" + cCliente + "'" + ENTER
		//cQry += " ORDER BY " + ENTER 
		//cQry += " 		BAIXAORD DESC"   
	ElseIf cEmpAnt + cFilAnt $  "0200"
		cQry := " SELECT " + ENTER	
		cQry += " 		'0205' EMPRESA, " + ENTER	
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		DATEDIFF(DD, E1_VENCREA, GETDATE()) ATRASO, " + ENTER
		cQry += " 		E1_JUROS JUROS, " + ENTER
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_SALDO SALDO, " + ENTER
		cQry += " 		E1_VALOR VALOR, " + ENTER
		cQry += " 		E1_HIST HISTORICO " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		SE1020 " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		cQry += "  		AND E1_FILIAL = '05' " + ENTER 
		cQry += "  		AND E1_SALDO > 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = '" + cCliente + "'" + ENTER
		//cQry += " ORDER BY " + ENTER 
		//cQry += " 		BAIXAORD DESC"   	
	ElseIf cEmpAnt $  "08"
		cQry := " SELECT " + ENTER	
		cQry += " 		'0203' EMPRESA, " + ENTER	
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		DATEDIFF(DD, E1_VENCREA, GETDATE()) ATRASO, " + ENTER
		cQry += " 		E1_JUROS JUROS, " + ENTER
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_SALDO SALDO, " + ENTER
		cQry += " 		E1_VALOR VALOR, " + ENTER
		cQry += " 		E1_HIST HISTORICO " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		SE1020 " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		cQry += "  		AND E1_FILIAL = '03' " + ENTER 
		cQry += "  		AND E1_SALDO > 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = ( SELECT SA1.A1_COD FROM SA1020 SA1 WHERE D_E_L_E_T_ = ''  AND SA1.A1_FILIAL = '03' AND SA1.A1_CGC = ( SELECT SA1_2.A1_CGC FROM SA1080 SA1_2 WHERE SA1_2.D_E_L_E_T_ = '' AND SA1_2.A1_FILIAL = '" + cFilAnt + "' AND SA1_2.A1_COD = '" + cCliente + "' AND SA1_2.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += " UNION ALL " + ENTER
		cQry += " SELECT " + ENTER		
		cQry += " 		'0303' EMPRESA, " + ENTER
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER    
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		DATEDIFF(DD, E1_VENCREA, GETDATE()) ATRASO, " + ENTER
		cQry += " 		E1_JUROS JUROS, " + ENTER	
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_SALDO SALDO, " + ENTER
		cQry += " 		E1_VALOR VALOR, " + ENTER
		cQry += " 		E1_HIST HISTORICO " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		SE1030 " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		cQry += "  		AND E1_FILIAL = '03' " + ENTER 
		cQry += "  		AND E1_SALDO > 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = ( SELECT SA1.A1_COD FROM SA1030 SA1 WHERE D_E_L_E_T_ = ''  AND SA1.A1_FILIAL = '03' AND SA1.A1_CGC = ( SELECT SA1_2.A1_CGC FROM SA1080 SA1_2 WHERE SA1_2.D_E_L_E_T_ = '' AND SA1_2.A1_FILIAL = '" + cFilAnt + "' AND SA1_2.A1_COD = '" + cCliente + "' AND SA1_2.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += " UNION ALL " + ENTER
		cQry += " SELECT " + ENTER	
		cQry += " 		'0304' EMPRESA, " + ENTER	
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER    
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		DATEDIFF(DD, E1_VENCREA, GETDATE()) ATRASO, " + ENTER
		cQry += " 		E1_JUROS JUROS, " + ENTER	
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_SALDO SALDO, " + ENTER
		cQry += " 		E1_VALOR VALOR, " + ENTER
		cQry += " 		E1_HIST HISTORICO " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		SE1030 " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		cQry += "  		AND E1_FILIAL = '04' " + ENTER 
		cQry += "  		AND E1_SALDO > 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = ( SELECT SA1.A1_COD FROM SA1030 SA1 WHERE D_E_L_E_T_ = ''  AND SA1.A1_FILIAL = '04' AND SA1.A1_CGC = ( SELECT SA1_2.A1_CGC FROM SA1080 SA1_2 WHERE SA1_2.D_E_L_E_T_ = '' AND SA1_2.A1_FILIAL = '" + cFilAnt + "' AND SA1_2.A1_COD = '" + cCliente + "' AND SA1_2.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		
		If cEmpAnt + cFilAnt $  "0803"
			cQry += " UNION ALL " + ENTER
			cQry += " SELECT " + ENTER	
			cQry += " 		'0801' EMPRESA, " + ENTER	
			cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER    
			cQry += " 		E1_TIPO TIPO, " + ENTER
			cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
			cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
			cQry += " 		DATEDIFF(DD, E1_VENCREA, GETDATE()) ATRASO, " + ENTER
			cQry += " 		E1_JUROS JUROS, " + ENTER	
			cQry += " 		E1_PORTADO BCO, " + ENTER
			cQry += " 		E1_SALDO SALDO, " + ENTER
			cQry += " 		E1_VALOR VALOR, " + ENTER
			cQry += " 		E1_HIST HISTORICO " + ENTER
			cQry += " FROM " + ENTER	
			cQry += " 		SE1080 " + ENTER
			cQry += " WHERE " + ENTER		
			cQry += " 		D_E_L_E_T_ = '' " + ENTER 
			cQry += "  		AND E1_FILIAL = '01' " + ENTER 
			cQry += "  		AND E1_SALDO > 0 " + ENTER 
			cQry += "  		AND E1_CLIENTE = ( SELECT SA1.A1_COD FROM SA1080 SA1 WHERE D_E_L_E_T_ = ''  AND SA1.A1_FILIAL = '01' AND SA1.A1_CGC = ( SELECT SA1_2.A1_CGC FROM SA1080 SA1_2 WHERE SA1_2.D_E_L_E_T_ = '' AND SA1_2.A1_FILIAL = '" + cFilAnt + "' AND SA1_2.A1_COD = '" + cCliente + "' AND SA1_2.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		EndIf
		
		//cQry += " ORDER BY " + ENTER 
		//cQry += " 		BAIXAORD DESC" 

	ElseIf cEmpAnt $  "09"
		cQry := " SELECT " + ENTER	
		cQry += " 		'0203' EMPRESA, " + ENTER	
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		DATEDIFF(DD, E1_VENCREA, GETDATE()) ATRASO, " + ENTER
		cQry += " 		E1_JUROS JUROS, " + ENTER
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_SALDO SALDO, " + ENTER
		cQry += " 		E1_VALOR VALOR, " + ENTER
		cQry += " 		E1_HIST HISTORICO " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		SE1020 " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		cQry += "  		AND E1_FILIAL = '03' " + ENTER 
		cQry += "  		AND E1_SALDO > 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = ( SELECT SA1.A1_COD FROM SA1020 SA1 WHERE D_E_L_E_T_ = ''  AND SA1.A1_FILIAL = '03' AND SA1.A1_CGC = ( SELECT SA1_2.A1_CGC FROM SA1080 SA1_2 WHERE SA1_2.D_E_L_E_T_ = '' AND SA1_2.A1_FILIAL = '" + cFilAnt + "' AND SA1_2.A1_COD = '" + cCliente + "' AND SA1_2.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += " UNION ALL " + ENTER
		cQry += " SELECT " + ENTER		
		cQry += " 		'0303' EMPRESA, " + ENTER
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER    
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		DATEDIFF(DD, E1_VENCREA, GETDATE()) ATRASO, " + ENTER
		cQry += " 		E1_JUROS JUROS, " + ENTER	
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_SALDO SALDO, " + ENTER
		cQry += " 		E1_VALOR VALOR, " + ENTER
		cQry += " 		E1_HIST HISTORICO " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		SE1030 " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		cQry += "  		AND E1_FILIAL = '03' " + ENTER 
		cQry += "  		AND E1_SALDO > 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = ( SELECT SA1.A1_COD FROM SA1030 SA1 WHERE D_E_L_E_T_ = ''  AND SA1.A1_FILIAL = '03' AND SA1.A1_CGC = ( SELECT SA1_2.A1_CGC FROM SA1080 SA1_2 WHERE SA1_2.D_E_L_E_T_ = '' AND SA1_2.A1_FILIAL = '" + cFilAnt + "' AND SA1_2.A1_COD = '" + cCliente + "' AND SA1_2.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		cQry += " UNION ALL " + ENTER
		cQry += " SELECT " + ENTER	
		cQry += " 		'0304' EMPRESA, " + ENTER	
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER    
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		DATEDIFF(DD, E1_VENCREA, GETDATE()) ATRASO, " + ENTER
		cQry += " 		E1_JUROS JUROS, " + ENTER	
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_SALDO SALDO, " + ENTER
		cQry += " 		E1_VALOR VALOR, " + ENTER
		cQry += " 		E1_HIST HISTORICO " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		SE1030 " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		cQry += "  		AND E1_FILIAL = '04' " + ENTER 
		cQry += "  		AND E1_SALDO > 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = ( SELECT SA1.A1_COD FROM SA1030 SA1 WHERE D_E_L_E_T_ = ''  AND SA1.A1_FILIAL = '04' AND SA1.A1_CGC = ( SELECT SA1_2.A1_CGC FROM SA1080 SA1_2 WHERE SA1_2.D_E_L_E_T_ = '' AND SA1_2.A1_FILIAL = '" + cFilAnt + "' AND SA1_2.A1_COD = '" + cCliente + "' AND SA1_2.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		
		//If cEmpAnt + cFilAnt $  "0803"
			cQry += " UNION ALL " + ENTER
			cQry += " SELECT " + ENTER	
			cQry += " 		'08'+E1_FILIAL EMPRESA, " + ENTER	
			cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER    
			cQry += " 		E1_TIPO TIPO, " + ENTER
			cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
			cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
			cQry += " 		DATEDIFF(DD, E1_VENCREA, GETDATE()) ATRASO, " + ENTER
			cQry += " 		E1_JUROS JUROS, " + ENTER	
			cQry += " 		E1_PORTADO BCO, " + ENTER
			cQry += " 		E1_SALDO SALDO, " + ENTER
			cQry += " 		E1_VALOR VALOR, " + ENTER
			cQry += " 		E1_HIST HISTORICO " + ENTER
			cQry += " FROM " + ENTER	
			cQry += " 		SE1080 " + ENTER
			cQry += " WHERE " + ENTER		
			cQry += " 		D_E_L_E_T_ = '' " + ENTER 
			cQry += "  		AND E1_FILIAL IN ('01','03') " + ENTER 
			cQry += "  		AND E1_SALDO > 0 " + ENTER 
			cQry += "  		AND E1_CLIENTE = ( SELECT SA1.A1_COD FROM SA1080 SA1 WHERE D_E_L_E_T_ = ''  AND SA1.A1_FILIAL = E1_FILIAL AND SA1.A1_CGC = ( SELECT SA1_2.A1_CGC FROM SA1090 SA1_2 WHERE SA1_2.D_E_L_E_T_ = '' AND SA1_2.A1_FILIAL = '" + cFilAnt + "' AND SA1_2.A1_COD = '" + cCliente + "' AND SA1_2.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		//EndIf
	Endif			
	*/
		cQry := " SELECT " + ENTER	
		cQry += " 		E1_FILIAL EMPRESA, " + ENTER	
		cQry += " 		E1_PREFIXO + E1_NUM + E1_PARCELA NUMERO, " + ENTER
		cQry += " 		E1_TIPO TIPO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, E1_VENCREA), 103) VENCTO, " + ENTER
		cQry += " 		DATEDIFF(DD, E1_VENCREA, GETDATE()) ATRASO, " + ENTER
		cQry += " 		E1_JUROS JUROS, " + ENTER
		cQry += " 		E1_PORTADO BCO, " + ENTER
		cQry += " 		E1_SALDO SALDO, " + ENTER
		cQry += " 		E1_VALOR VALOR, " + ENTER
		cQry += " 		E1_HIST HISTORICO " + ENTER
		cQry += " FROM " + ENTER	
		cQry += " 		" + RetSqlName("SE1") + " " + ENTER
		cQry += " WHERE " + ENTER		
		cQry += " 		D_E_L_E_T_ = '' " + ENTER 
		//cQry += "  		AND E1_FILIAL = '03' " + ENTER 
		cQry += "  		AND E1_SALDO > 0 " + ENTER 
		cQry += "  		AND E1_CLIENTE = ( SELECT SA1.A1_COD FROM " + RetSqlName("SA1") + " SA1 WHERE D_E_L_E_T_ = ''  AND SA1.A1_FILIAL = E1_FILIAL AND SA1.A1_CGC = ( SELECT SA1_2.A1_CGC FROM " + RetSqlName("SA1") + " SA1_2 WHERE SA1_2.D_E_L_E_T_ = '' AND SA1_2.A1_FILIAL = E1_FILIAL AND SA1_2.A1_COD = '" + cCliente + "' AND SA1_2.A1_LOJA = '" + cCliLoja + "' ) ) " + ENTER
		                                                                       	
	MemoWrite("FINC023.sql", cQry) 
	
	TCQUERY cQry NEW ALIAS FINC023
	
	dbSelectArea("FINC023")
	dbGoTop() 
	
	If !FINC023->(EOF())
                  
		cTxtIt := ""       
		aTotal := {0, 0, 0}
		While !FINC023->(EOF())
			cTxtIt += PadR(FINC023->EMPRESA, 5) + ;
						 PadR(FINC023->NUMERO, 15) + ;
						 PadR(FINC023->TIPO, 5) + ;
						 PadR(FINC023->EMISSAO, 15) + ;
						 PadR(FINC023->VENCTO, 15) + ;
						 PadL(Transform(FINC023->SALDO, "@E 999,999.99"), 12) + ;
						 PadC(Transform(FINC023->ATRASO, "9999"), 8) + ;
						 PadL(FINC023->HISTORICO, 25) + ;
 						 PadR(FINC023->BCO, 35) + ENTER 

			aTotal[1] += 1 
			aTotal[2] += Iif(FINC023->TIPO == "NCC", 0, FINC023->VALOR)
			aTotal[3] += Iif(FINC023->TIPO == "NCC", 0, FINC023->SALDO)
			FINC023->(dbSkip())
		EndDo    

		cTxt := "===========================================================================================================================" + ENTER
		cTxt += "# TÍTULOS.......: " + Transform(aTotal[1], "9999") /*+ " - Cliente: " + cCliente + cCliLoja*/  + ENTER		              
		cTxt += "VLR PRINCIPAL...: " + Transform(aTotal[2], "@E 999,999,999.99") + ENTER
		cTxt += "SALDO A RECEBER.: " + Transform(aTotal[3], "@E 999,999,999.99") + ENTER
		cTxt += "===========================================================================================================================" + ENTER
		cTxt += "EMPR N. TITULO      TIPO EMISSAO        VENCIMENTO     SALDO       ATRASO  HISTORICO                                    BCO" + ENTER
		cTxt += "===========================================================================================================================" + ENTER
		cTxt += cTxtIt
		cTxt += "===========================================================================================================================" + ENTER
				
		oFontLoc := TFont():New("Mono AS", 06, 15)
		DEFINE MSDIALOG oDlg TITLE "Títulos Em Aberto" FROM 015,020 TO 044,120 
		@ 0.5,0.7  GET oGet VAR cTxt OF oDlg MEMO SIZE 385,208 READONLY COLOR CLR_BLACK,CLR_HGRAY
		oGet:oFont     := oFontLoc
		oGet:bRClicked := {||AllwaysTrue()}
		ACTIVATE MSDIALOG oDlg Centered
		oFontLoc:End()
	EndIf  
	
	FINC023->(dbCloseArea())
	         
	xRet := cCliente
	
EndIf          



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Restaura area anterior ao processamento                                                  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
RestArea(aArea)         

Return xRet
