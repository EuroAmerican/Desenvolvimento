#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "protheus.ch"
#include "totvs.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#define  ENTER		chr(13) + chr(10)    
#DEFINE	 IMP_DISCO 	1
#DEFINE	 IMP_SPOOL 	2
#DEFINE	 IMP_EMAIL 	3
#DEFINE	 IMP_EXCEL 	4
#DEFINE	 IMP_HTML  	5
#DEFINE	 IMP_PDF   	6 

#DEFINE	 NMINLIN	030
#DEFINE  NMINCOL	020
#DEFINE	 NMAXLIN   	800
#DEFINE	 NMAXCOL   	570

/*/{Protheus.doc} ESTX003
Rotina para o gerenciamento do controle de pesagem
@description Rotina para o gerenciamento do controle de pesagem
@type function
@author Tiago O. Beraldi 
@since 04/05/10
@table SZZ, SZF, SZG  
/*/

User Function ESTX003() 
Local _cUsuario  := Alltrim(cUserName)

Private aCores    := {}  
Private cAlias    := "SZZ"
Private cCadastro := "Controle de Pesagens  
Private aButtons  := {} 
Private aRotina   := {}

Private lImpLaser	:= SuperGetMv("MV_EQ_ITLS",.F.,.T.) // .T. Indica se utiliza impressora a laser. .F. Indica impressora Matricial
Private _cPORTASUP	:= GETMV("MV_XPORTSP",, ",antonio.cabral,Administrador" )

//Adiciona botao de Pesagem 
aAdd(aButtons, {"PRODUTO", {|| GravaPeso()}, "Pesagem", "Pesagem"})

//Define cores do Mbrowse          
aAdd(aCores, {"'TICKET CANCELADO' $ ZZ_OBS" ,"BR_PRETO"})
aAdd(aCores, {"ZZ_PESO2 == 0" ,"BR_VERDE"    })
aAdd(aCores, {"ZZ_PESO2 != 0" ,"BR_VERMELHO" })
     
aAdd(aRotina, {"Pesquisar"   , "AxPesqui"   ,0,1})
aAdd(aRotina, { "Visualizar" , "AxVisual"   ,0,2})
aAdd(aRotina, { "Incluir"    , "U_ESTX003I" ,0,3})
aAdd(aRotina, { "Alterar"    , "U_ESTX003A" ,0,4}) 
If _cUsuario $ _cPORTASUP
	//aAdd(aRotina, { "Excluir"    , "AxDeleta"   ,0,5})		// Somente para o usuario Supervisor da portaria insiro a op��o de excluir registro de controle de pesagem
	aAdd(aRotina, { "Excluir"   , "U_ESTX003D"  ,0,5})		// Somente para o usuario Supervisor da portaria insiro a op��o de excluir registro de controle de pesagem
Endif
aAdd(aRotina, { "Im&primir"  , "U_ESTX003R" ,0,6})
aAdd(aRotina, { "Aprovar"    , "U_ESTX003V" ,0,7})
aAdd(aRotina, { "Legenda"    , "U_ESTX003L" ,0,8})
aAdd(aRotina, { "Classificar", "U_ESTX003X" ,0,9})
aAdd(aRotina, { "Estornar"   , "U_ESTX003E" ,0,10})
aAdd(aRotina, { "Cancelar"   , "U_ESTX003C" ,0,11})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta MBrowse                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
dbSetOrder(1)
dbGoBottom()                       
mBrowse(6, 1, 22, 75, cAlias,,,,,, aCores)
Return  


/*/{Protheus.doc} ESTX003I
Inclusao da pesagem
@type function
@author Tiago O. Beraldi
@since 04/05/10
/*/
User Function ESTX003I              

Local cQry := ""
Local lRet := .T.
                     
cQry := " SELECT " + ENTER	
cQry += " 		ZZ_CODIGO CODIGO, " + ENTER
cQry += " 		CONVERT(VARCHAR, CONVERT(DATETIME, ZZ_EMISSAO), 103) + ' ' + ZZ_HREMISS DATAHORA, " + ENTER

cQry += " 		CASE " + ENTER 
cQry += " 				WHEN DATEPART(DW, GETDATE()) = 2 AND DATEPART(DW, CONVERT(DATE,ZZ_EMISSAO)) = 6 " + ENTER	
cQry += " 				THEN (DATEDIFF(MI, ZZ_EMISSAO + ' ' + ZZ_HREMISS, GETDATE())/60.0) - 48.0 " + ENTER	
cQry += " 				WHEN DATEPART(DW, GETDATE()) = 2 AND DATEPART(DW, CONVERT(DATE,ZZ_EMISSAO)) = 7 " + ENTER	
cQry += " 		  		THEN (DATEDIFF(MI, ZZ_EMISSAO + ' ' + ZZ_HREMISS, GETDATE())/60.0) - 24.0  " + ENTER	
cQry += " 		ELSE (DATEDIFF(MI, ZZ_EMISSAO + ' ' + ZZ_HREMISS, GETDATE())/60.0)" + ENTER	
cQry += " 		END 'HORAS'" + ENTER	

cQry += " FROM " + ENTER                        

cQry += " " + RetSqlName("SZZ") + ENTER

cQry += " WHERE" + ENTER
cQry += " 		D_E_L_E_T_ = ''" + ENTER
cQry += " 		AND ZZ_PESO1 != 0" + ENTER
cQry += " 		AND ZZ_PESO2 = 0" + ENTER

cQry += " 		AND CASE 
cQry += " 			WHEN DATEPART(DW, GETDATE()) = 2 AND DATEPART(DW, CONVERT(DATE,ZZ_EMISSAO)) = 6 " + ENTER	
cQry += " 			THEN (DATEDIFF(MI, ZZ_EMISSAO + ' ' + ZZ_HREMISS, GETDATE())/60.0) - 48.0 " + ENTER	
cQry += " 			WHEN DATEPART(DW, GETDATE()) = 2 AND DATEPART(DW, CONVERT(DATE,ZZ_EMISSAO)) = 7 " + ENTER	
cQry += " 		 	THEN (DATEDIFF(MI, ZZ_EMISSAO + ' ' + ZZ_HREMISS, GETDATE())/60.0) - 24.0 " + ENTER	
cQry += " 		ELSE (DATEDIFF(MI, ZZ_EMISSAO + ' ' + ZZ_HREMISS, GETDATE())/60.0)" + ENTER	
cQry += " 		END > 24.0" + ENTER

cQry += " 		AND UPPER(ISNULL(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),ZZ_OBS)), '')) NOT LIKE '%TICKET CANCELADO%'" + ENTER
cQry += " ORDER BY " + ENTER
cQry += " 		ZZ_EMISSAO, ZZ_HREMISS " + ENTER
                          
If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf                  

TCQUERY cQry NEW ALIAS QRY

If !QRY->(EOF()) 

	cMsg := ""
	While !QRY->(EOF())
		cMsg += QRY->CODIGO + QRY->DATAHORA + ENTER
		QRY->(dbSkip())
	EndDo                                                             
	QRY->(dbCloseArea())	 
	
	If !Empty(cMsg)
		Aviso("Controle de Pesagem", "Os tickets abaixo estão abertos a mais de 24h e precisam ser fechados:" + ENTER + cMsg, {"Ok"}, 3)		
		lRet := .F. 
	EndIf
		
EndIf

If lRet            
	dbSelectArea("SZZ")
	nOpcA := AxInclui("SZZ", Recno(), 3,,,,,,, aButtons)   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Atualiza historico do ticket de pesagem referente a NF Entrada    	³
	//|** Abertura do Ticket                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcA == 1
		U_ESTX003H(SZZ->ZZ_CODIGO, 1)
	EndIf  

EndIf	 
Return 


/*/{Protheus.doc} ESTX003C
Cancelamento do Ticket de pesagem
@type function
@author Tiago O. Beraldi
@since 04/05/10
/*/
User Function ESTX003C

Local aWFIDs    := {}          // FS
Local nPosWF    := 0           // FS
Local nLin      := 0           // FS

If U_PORTAUSR()		// Se o usu�rio do Protheus for do setor portaria, permite efetuar o cancelamento do Ticket de pesagem
	If MsgYesNo("Confirma Cancelamento do Ticket " + SZZ->ZZ_CODIGO + " ?")
		dbSelectArea("SZZ")
		RecLock("SZZ", .F.)
			SZZ->ZZ_OBS := SZZ->ZZ_OBS + ENTER + "(TICKET CANCELADO POR " + Upper(AllTrim(cUserName)) + " EM " + DtoC(dDataBase) + " " + Time() + ")"
		SZZ->( MsUnLock() )

		cQuery := "SELECT D1_PEDIDO " + CRLF
		cQuery += "FROM " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SF1") + " AS SF1 WITH (NOLOCK) ON F1_FILIAL = D1_FILIAL " + CRLF
		cQuery += "  AND F1_DOC = D1_DOC " + CRLF
		cQuery += "  AND F1_SERIE = D1_SERIE " + CRLF
		cQuery += "  AND F1_FORNECE = D1_FORNECE " + CRLF
		cQuery += "  AND F1_LOJA = D1_LOJA " + CRLF
		cQuery += "  AND F1_TIPO = D1_TIPO " + CRLF
		cQuery += "  AND F1_TICPESA = '" + SZZ->ZZ_CODIGO + "' " + CRLF
		cQuery += "WHERE D1_FILIAL <> '**' " + CRLF
		cQuery += "AND D1_PEDIDO <> '' " + CRLF
		cQuery += "AND SD1.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "GROUP BY D1_PEDIDO " + CRLF

		TCQuery cQuery New Alias "ESTPES"
		dbSelectArea("ESTPES")
		dbGoTop()

		Do While !ESTPES->( Eof() )
			dbSelectArea("SC7")
			dbSetOrder(1)
			If SC7->( dbSeek( xFilial("SC7") + ESTPES->D1_PEDIDO ) )
				If !Empty( SC7->C7_EUWFID )
					If aScan( aWFIDs, {|nLin| AllTrim( nLin[1] ) == AllTrim( SC7->C7_EUWFID ) }) == 0
						aAdd( aWFIDs, { AllTrim( SC7->C7_EUWFID ), SC7->C7_NUM })
					EndIf
				EndIf
			EndIf

			ESTPES->( dbSkip() )
		EndDo

		ESTPES->( dbCloseArea() )

		// Atualiza os processos da NF...
		For nPosWF := 1 To Len( aWFIDs )
			dbSelectArea("SC7")
			dbSetOrder(1)
			If SC7->( dbSeek( xFilial("SC7") + aWFIDs[nPosWF][2] ) )
				U_EQGeraWFC( "Protheus - Recebimento: " + AllTrim( SZZ->ZZ_CODIGO ) + " Recusado. Pedido: " + AllTrim( SC7->C7_NUM ),;
							"300901",;
							"RECEBIMENTO RECUSADO",;
							"1",;
							"Controle de Pesagem Cancelado. Recebimento Recusado" )
			EndIf
		Next
	EndIf                         
EndIf                         

Return 


/*/{Protheus.doc} ESTX003A
Altera��o do Ticket de pesagem
@type function
@author Tiago O. Beraldi
@since 04/05/10
/*/
User Function ESTX003A   

If !Empty(SZZ->ZZ_DTPES2) .Or. 'TICKET CANCELADO' $ SZZ->ZZ_OBS
	If MsgYesNo("Pesagem j� finalizada!" + CRLF + "Deseja realmente alterar?","Altera��o Pesos/Carga")
		FimAlt()//Fabio Batista 19/10/2020
	EndIf 
	Return .T.
Endif  
             
dbSelectArea("SZZ")   
nOpca := AxAltera("SZZ", Recno(), 4,,,,,"U_TUDOK()",,, aButtons)            
//nOpca := AxAltera("SZZ", Recno(), 4,,,,,,,, aButtons)  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Atualiza historico do ticket de pesagem referente a NF Entrada    	³
//|** Finalizacao do Ticket                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == 1 .And. !Empty(SZZ->ZZ_DTPES2)
	U_ESTX003H(SZZ->ZZ_CODIGO, 5)
EndIf

Return
                

/*/{Protheus.doc} TudOK
VALIDACAO DO TICKET
@type function
@author Tiago O. Beraldi
@since 04/05/10
@return logical, Retorna verdadeiro para digita��o valida, Falso para digita��o invalida 
/*/
User Function TudOK() 

Local aArea		:= GetArea()
Local aAreaSZF	:= SZF->(GetArea()) 
Local lRet		:= .T.     
Local cDoc		:= ""
Local nPeso		:= 0
Local aWFIDs    := {}          // FS
Local nPosWF	:= 0
Local nLin      := 0           // FS
Local lEnvAtu   := .T.

//+-----------------------------------------------------------------------
//| CG=CARGA
//+-----------------------------------------------------------------------
If M->ZZ_TIPO $ "CG" .And. ( 	Left(M->ZZ_TPDOC1,1)=="E" .Or.;
								Left(M->ZZ_TPDOC2,1)=="E" .Or.;
								Left(M->ZZ_TPDOC3,1)=="E" .Or.;
								Left(M->ZZ_TPDOC4,1)=="E"	)

	lRet := .F.
	MsgStop("Ticket emitido para saida de material porem foram associados documentos para entrada ( EE, EQ ). Verifique!")

//+-----------------------------------------------------------------------
//| DG=DESCARGA
//+-----------------------------------------------------------------------
ElseIf M->ZZ_TIPO $ "DG" .And. (	Left(M->ZZ_TPDOC1,1)=="R" .Or.;
								 	Left(M->ZZ_TPDOC2,1)=="R" .Or.;
								 	Left(M->ZZ_TPDOC3,1)=="R" .Or.;
								 	Left(M->ZZ_TPDOC4,1)=="R" 	)

	lRet := .F.
	MsgStop("Ticket emitido para entrada de material porem foram associados documentos para saida ( RE, RQ, CARGA ). Verifique!")

EndIf       

// FS - Verifica se houve amarração da NF se segunda pesagem...
If M->ZZ_FLAGP2
	If M->ZZ_EMISSAO > STOD("20190830") // Data de corte da amarração
		cQuery := "SELECT * FROM " + RetSqlName("SZX") + " WITH (NOLOCK) WHERE ZX_FILIAL = '" + xFilial("SZX") + "' AND ZX_CODSZZ = '" + AllTrim( M->ZZ_CODIGO ) + "' AND D_E_L_E_T_ = ' '"
		TCQuery cQuery New Alias "TMPSZX"
		dbSelectArea("TMPSZX")
		dbGoTop()
		If TMPSZX->( Eof() )
			If !ApMsgYesNo( "Ticket não possui amarração com a Nota Fiscal, deseja liberar o caminhão para segunda pesagem mesmo assim?", "Cuidado" )
				lRet := .F.
			EndIf 
		EndIf
		TMPSZX->( dbCloseArea() )
	EndIf
EndIf

//+-----------------------------------------------------------------------
//| COMPATIBILIDADE ENTRE ROMANEIO E CONTROLE DE CARGA
//+-----------------------------------------------------------------------
If !Empty(M->ZZ_CARGA) 
	cDoc   := M->ZZ_CARGA
	nPeso  := M->ZZ_PESOCG
Else
	cDoc   := AllTrim(M->ZZ_TPDOC1 + M->ZZ_DOC1) + "-" + Alltrim(M->ZZ_TPDOC2 + M->ZZ_DOC2) + "-" + Alltrim(M->ZZ_TPDOC3 + M->ZZ_DOC3) + "-" + Alltrim(M->ZZ_TPDOC4 + M->ZZ_DOC4)
	nPeso  := ( M->ZZ_PESDOC1 + M->ZZ_PESDOC2 + M->ZZ_PESDOC3 + M->ZZ_PESDOC4 )
EndIf	                                                                          

//+-----------------------------------------------------------------------
//| Valida tipo do ticket x carga
//+-----------------------------------------------------------------------
If M->ZZ_FLAGP1 .And. M->ZZ_FLAGP2 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ CARGA                                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If M->ZZ_TIPO == "CG" 
		
		If Empty(M->ZZ_CARGA)
			lRet := .F.
			MsgStop("Carga não associada ao ticket de pesagem. Verifique!")

		Else
			
			SZF->(dbSetOrder(1))
			SZF->(dbSeek(xFilial("SZF")+M->ZZ_CARGA))                          
			
			If SZF->( !Found() )
				lRet := .F.
				MsgStop("Carga associada ao ticket não encontrada. Verifique!")
			
			ElseIf SZF->ZF_STATUS != "3"
				lRet := .F.
				MsgStop("Carga associada ao ticket não esta na etapa de liberação para trânsito. Verifique!")
			
			ElseIf AllTrim( SZF->ZF_VEICULO ) != StrTran( StrTran( StrTran( M->ZZ_PLACA, "-", "" ), ".", "" ), " ", "" )
				lRet := .F.
				MsgStop("Carga não pertence ao veiculo informado no ticket de pesagem. Verifique!")
				
			EndIf
			
		EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ DESCARGA                                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf M->ZZ_TIPO == "DG" .And. !Empty(M->ZZ_CARGA)

		lRet := .F.
		MsgStop("Carga associada ao ticket tipo DESCARGA. Verifique!")

	EndIf
	
EndIf

// Fabio...
If lRet
	If AllTrim( M->ZZ_TIPO ) == "DG"
		If !Empty( M->ZZ_APROV ) .Or. (M->ZZ_FLAGP1 .And. M->ZZ_FLAGP2)
			If ( M->ZZ_PESDOC1 + M->ZZ_PESDOC2 + M->ZZ_PESDOC3 + M->ZZ_PESDOC4 ) <= 0
				If ApMsgYesNo( "Peso do(s) documento(s) está zerado, deseja corrigir o peso?", "Atenção")
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf


// Verifica diferenca percentual > 2%
If lRet 

	If Empty(M->ZZ_APROV) .And. M->ZZ_FLAGP1 .And. M->ZZ_FLAGP2    

		lRet  := !(Abs(100 * ((Abs(M->ZZ_PESO1 - M->ZZ_PESO2) - (nPeso))/(nPeso))) > 2) //alterou de > 3 para > 2
		lTara := (Abs(Abs(M->ZZ_PESO1 - M->ZZ_PESO2) - (nPeso)) > 11)
		
		MsgStop("Divergência de Peso maior que 2%. Verifique se não há romaneios e/ou notas faltantes neste ticket!") //alterou de maior que 3% para maior que 2 %
					
	   	cTexto  := Replicate("=", 80) + chr(13) + chr(10) 
	   	cTexto  += "PLACA...............: " + M->ZZ_PLACA + chr(13) + chr(10)
		cTexto  += "DOCUMENTO/CARGA.....: " + cDoc + chr(13) + chr(10)
		cTexto  += "PRIMEIRA PESAGEM....: " + Transform(M->ZZ_PESO1, "@E 999,999,999") + " KG " + chr(13) + chr(10)
		cTexto  += "SEGUNDA PESAGEM.....: " + Transform(M->ZZ_PESO2, "@E 999,999,999") + " KG " + chr(13) + chr(10)
		cTexto  += "LIQUIDO.............: " + Transform(Abs(M->ZZ_PESO1 - M->ZZ_PESO2), "@E 999,999,999")  + " KG " + chr(13) + chr(10)
		cTexto  += "PESO DA NOTA........: " + Transform(nPeso, "@E 999,999,999") + " KG " + chr(13) + chr(10)
		cTexto  += "DIFERENCA...........: " + Transform(Abs(M->ZZ_PESO1 - M->ZZ_PESO2) - (nPeso), "@E 999,999,999") + "  " +  Transform(100 * ((Abs(M->ZZ_PESO1 - M->ZZ_PESO2) - (nPeso))/(nPeso)), "@E 999.99") + " %" + chr(13) + chr(10)
		cTexto  += Replicate("=", 80) + chr(13) + chr(10)  
	
		oFontLoc := TFont():New("Mono AS", 06, 15)
		DEFINE MSDIALOG oDlg TITLE "Controle de Pesagem" FROM 015,020 TO 032,69
		@ 0.5,0.7  GET oGet VAR cTexto OF oDlg MEMO SIZE 184,118 READONLY COLOR CLR_BLACK,CLR_HGRAY
		oGet:oFont     := oFontLoc
		oGet:bRClicked := {||AllwaysTrue()}
		ACTIVATE MSDIALOG oDlg Centered
		oFontLoc:End()
		
		If !lTara  
			lRet := .T.
		EndIf
	
	EndIf
	
EndIf      

// FS
If lRet
	If AllTrim( M->ZZ_TIPO ) == "DG"
		If !Empty( M->ZZ_APROV ) .Or. (M->ZZ_FLAGP1 .And. M->ZZ_FLAGP2)
			cQuery := "SELECT COUNT(*) AS CONTA " + CRLF
			cQuery += "FROM " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) " + CRLF
			cQuery += "INNER JOIN " + RetSqlName("SF1") + " AS SF1 WITH (NOLOCK) ON F1_FILIAL = D1_FILIAL " + CRLF
			cQuery += "  AND F1_DOC = D1_DOC " + CRLF
			cQuery += "  AND F1_SERIE = D1_SERIE " + CRLF
			cQuery += "  AND F1_FORNECE = D1_FORNECE " + CRLF
			cQuery += "  AND F1_LOJA = D1_LOJA " + CRLF
			cQuery += "  AND F1_TIPO = D1_TIPO " + CRLF
			cQuery += "  AND F1_TICPESA = '" + M->ZZ_CODIGO + "' " + CRLF
			cQuery += "  AND SF1.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += "WHERE D1_FILIAL = '" + xFilial("SD1") + "' " + CRLF
			cQuery += "AND D1_DTTRANS = '' AND D1_QUANT > D1_QTDCOF " + CRLF
			cQuery += "AND SD1.D_E_L_E_T_ = ' ' " + CRLF
		
			TCQuery cQuery New Alias "VLDCONF"
			dbSelectArea("VLDCONF")
			dbGoTop()
			
			If !VLDCONF->( Eof() )
				If VLDCONF->CONTA > 0
					MsgStop( "Há itens pendentes de conferência, liberação segunda pesagem não autorizada. Verifique!")
					lRet := .F.
				EndIf
			EndIf
			
			VLDCONF->( dbCloseArea() )
		EndIf
	EndIf
EndIf

// FS
If lRet
	If AllTrim( M->ZZ_TIPO ) == "DG"
		If !Empty( M->ZZ_APROV ) .Or. (M->ZZ_FLAGP1 .And. M->ZZ_FLAGP2)
			cQuery := "SELECT SD1.D1_FILIAL " + CRLF
			cQuery += "FROM " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) " + CRLF
			cQuery += "INNER JOIN " + RetSqlName("SF1") + " AS SF1 WITH (NOLOCK) ON SF1.F1_FILIAL = SD1.D1_FILIAL " + CRLF
			cQuery += "  AND SF1.F1_DOC = SD1.D1_DOC " + CRLF
			cQuery += "  AND SF1.F1_SERIE = SD1.D1_SERIE " + CRLF
			cQuery += "  AND SF1.F1_FORNECE = SD1.D1_FORNECE " + CRLF
			cQuery += "  AND SF1.F1_LOJA = SD1.D1_LOJA " + CRLF
			cQuery += "  AND SF1.F1_TIPO = SD1.D1_TIPO " + CRLF
			cQuery += "  AND SF1.F1_TICPESA = '" + M->ZZ_CODIGO + "' " + CRLF
			cQuery += "  AND SF1.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += "WHERE SF1.F1_FILIAL <> '**' " + CRLF
			cQuery += "  AND SD1.D_E_L_E_T_ = ' ' " + CRLF

			TCQuery cQuery New Alias "POSSUI"
			dbSelectArea("POSSUI")
			dbGoTop()

			lTem := .F.

			If !POSSUI->( Eof() )
				If !Empty( POSSUI->D1_FILIAL )
					lTem := .T.
				EndIf
			EndIf

			POSSUI->( dbCloseArea() )


           /*

			  Grupo Empresas - Regra original comentada em 28.08.2020 (CG)

			If !lTem
			
				cQuery := "SELECT '02' AS EMPRESA, D1_FILIAL, D1_PEDIDO " + CRLF
				cQuery += "FROM SD1020 AS SD1 WITH (NOLOCK) " + CRLF
				cQuery += "INNER JOIN SF1020 AS SF1 WITH (NOLOCK) ON F1_FILIAL = D1_FILIAL " + CRLF
				cQuery += "  AND F1_DOC = D1_DOC " + CRLF
				cQuery += "  AND F1_SERIE = D1_SERIE " + CRLF
				cQuery += "  AND F1_FORNECE = D1_FORNECE " + CRLF
				cQuery += "  AND F1_LOJA = D1_LOJA " + CRLF
				cQuery += "  AND F1_TIPO = D1_TIPO " + CRLF
				cQuery += "  AND F1_TICPESA = '" + M->ZZ_CODIGO + "' " + CRLF
				cQuery += "  AND SF1.D_E_L_E_T_ = ' ' " + CRLF
				cQuery += "WHERE D1_FILIAL <> '**' " + CRLF
				cQuery += "AND SD1.D_E_L_E_T_ = ' ' " + CRLF
				cQuery += "UNION ALL " + CRLF
				cQuery += "SELECT '08' AS EMPRESA, D1_FILIAL, D1_PEDIDO " + CRLF
				cQuery += "FROM SD1080 AS SD1 WITH (NOLOCK) " + CRLF
				cQuery += "INNER JOIN SF1080 AS SF1 WITH (NOLOCK) ON F1_FILIAL = D1_FILIAL " + CRLF
				cQuery += "  AND F1_DOC = D1_DOC " + CRLF
				cQuery += "  AND F1_SERIE = D1_SERIE " + CRLF
				cQuery += "  AND F1_FORNECE = D1_FORNECE " + CRLF
				cQuery += "  AND F1_LOJA = D1_LOJA " + CRLF
				cQuery += "  AND F1_TIPO = D1_TIPO " + CRLF
				cQuery += "  AND F1_TICPESA = '" + M->ZZ_CODIGO + "' " + CRLF
				cQuery += "  AND SF1.D_E_L_E_T_ = ' ' " + CRLF
				cQuery += "WHERE D1_FILIAL <> '**' " + CRLF
				cQuery += "AND SD1.D_E_L_E_T_ = ' ' " + CRLF
				cQuery += "UNION ALL " + CRLF
				cQuery += "SELECT '06' AS EMPRESA, D1_FILIAL, D1_PEDIDO " + CRLF
				cQuery += "FROM SD1060 AS SD1 WITH (NOLOCK) " + CRLF
				cQuery += "INNER JOIN SF1060 AS SF1 WITH (NOLOCK) ON F1_FILIAL = D1_FILIAL " + CRLF
				cQuery += "  AND F1_DOC = D1_DOC " + CRLF
				cQuery += "  AND F1_SERIE = D1_SERIE " + CRLF
				cQuery += "  AND F1_FORNECE = D1_FORNECE " + CRLF
				cQuery += "  AND F1_LOJA = D1_LOJA " + CRLF
				cQuery += "  AND F1_TIPO = D1_TIPO " + CRLF
				cQuery += "  AND F1_TICPESA = '" + M->ZZ_CODIGO + "' " + CRLF
				cQuery += "  AND SF1.D_E_L_E_T_ = ' ' " + CRLF
				cQuery += "WHERE D1_FILIAL <> '**' " + CRLF
				cQuery += "AND SD1.D_E_L_E_T_ = ' ' " + CRLF
			Else
				cQuery := "SELECT '" + AllTrim( cEmpAnt ) + "' AS EMPRESA, D1_FILIAL, D1_PEDIDO " + CRLF
				cQuery += "FROM " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) " + CRLF
				cQuery += "INNER JOIN " + RetSqlName("SF1") + " AS SF1 WITH (NOLOCK) ON F1_FILIAL = D1_FILIAL " + CRLF
				cQuery += "  AND F1_DOC = D1_DOC " + CRLF
				cQuery += "  AND F1_SERIE = D1_SERIE " + CRLF
				cQuery += "  AND F1_FORNECE = D1_FORNECE " + CRLF
				cQuery += "  AND F1_LOJA = D1_LOJA " + CRLF
				cQuery += "  AND F1_TIPO = D1_TIPO " + CRLF
				cQuery += "  AND F1_TICPESA = '" + M->ZZ_CODIGO + "' " + CRLF
				cQuery += "  AND SF1.D_E_L_E_T_ = ' ' " + CRLF
				cQuery += "WHERE D1_FILIAL <> '**' " + CRLF
				cQuery += "AND SD1.D_E_L_E_T_ = ' ' " + CRLF
			EndIf

            */

			cQuery := "SELECT " + Left(cFilAnt,2) + " AS EMPRESA, SD1.D1_FILIAL, SD1.D1_PEDIDO " + CRLF
			cQuery += "      FROM " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) " + CRLF
			cQuery += "INNER JOIN " + RetSqlName("SF1") + " AS SF1 WITH (NOLOCK) ON SF1.F1_FILIAL = SD1.D1_FILIAL " + CRLF
			cQuery += "  AND SF1.F1_DOC     = SD1.D1_DOC " + CRLF
			cQuery += "  AND SF1.F1_SERIE   = SD1.D1_SERIE " + CRLF
			cQuery += "  AND SF1.F1_FORNECE = SD1.D1_FORNECE " + CRLF
			cQuery += "  AND SF1.F1_LOJA    = SD1.D1_LOJA " + CRLF
			cQuery += "  AND SF1.F1_TIPO    = SD1.D1_TIPO " + CRLF
			cQuery += "  AND SF1.F1_TICPESA = '" + M->ZZ_CODIGO + "' " + CRLF
			cQuery += "  AND SF1.D_E_L_E_T_ = ' ' "  + CRLF
			cQuery += "WHERE SD1.D1_FILIAL <> '**' " + CRLF
			cQuery += "  AND SD1.D_E_L_E_T_ = ' ' "  + CRLF

			TCQuery cQuery New Alias "TMPPES"
			dbSelectArea("TMPPES")
			dbGoTop()
			
			Do While !TMPPES->( Eof() )
				If Left(cFilAnt,2) <> AllTrim( TMPPES->EMPRESA )
					If !Empty( TMPPES->EMPRESA ) .And. !Empty( TMPPES->D1_FILIAL )
						Aviso("Saída Caminhão","Este Ticket pertence Nota Fiscal da empresa: " + TMPPES->EMPRESA + ENTER + "Caso gere erro na confirmação da pesagem por favor efetuar novo Login na empresa: " + TMPPES->EMPRESA,{"OK"},3)
						lRet := .F.
						/*
						lEnvAtu := .F.
						cEmpAtu := cEmpAnt
						cFilAtu := cFilAnt
						dbSelectArea("SM0")
						dbSetOrder(1)
						If SM0->( dbSeek( TMPPES->EMPRESA + TMPPES->D1_FILIAL ) )
							RpcClearEnv()  //Limpa o Ambiente
							RpcSetType(3)
							RpcSetEnv( TMPPES->EMPRESA, TMPPES->D1_FILIAL )
						EndIf
						*/
					EndIf
				ElseIf AllTrim( cFilAnt ) <> AllTrim( TMPPES->D1_FILIAL )
					lEnvAtu := .F.
					//Prepare Environment EMPRESA AllTrim( TMPPES->EMPRESA ) FILIAL AllTrim( TMPPES->D1_FILIAL )
					cFilAnt := AllTrim( TMPPES->D1_FILIAL )
				EndIf

				dbSelectArea("SC7")
				dbSetOrder(1)
				If SC7->( dbSeek( TMPPES->D1_FILIAL + TMPPES->D1_PEDIDO ) )
					If aScan( aWFIDs, {|nLin| AllTrim( nLin[1] ) == AllTrim( SC7->C7_EUWFID ) }) == 0
						aAdd( aWFIDs, { AllTrim( SC7->C7_EUWFID ), SC7->C7_NUM })
					EndIf
				EndIf

				TMPPES->( dbSkip() )
			EndDo
			
			TMPPES->( dbCloseArea() )

			// Atualiza os processos da NF...
			For nPosWF := 1 To Len( aWFIDs )
				dbSelectArea("SC7")
				dbSetOrder(1)
				If SC7->( dbSeek( xFilial("SC7") + aWFIDs[nPosWF][2] ) )
					U_EQGeraWFC( "Protheus - Desembarque Concluído: " + AllTrim( SF1->F1_DOC ) + "|" + AllTrim( SF1->F1_SERIE ) + " Realizada. Pedido: " + AllTrim( SC7->C7_NUM ),;
					 			 "500001",;
								 "LIBERACAO SAIDA CAMINHAO",;
						         "1",;
								 "Desembarque Recebimento Concluído - Liberação Caminhão" )
				EndIf
			Next

			If !lEnvAtu
				/*
				//Reset Environment
				dbSelectArea("SM0")
				dbSetOrder(1)
				If SM0->( dbSeek( cEmpAtu + cFilAtu ) )
					RpcClearEnv()  //Limpa o Ambiente
					RpcSetType(3)
					RpcSetEnv( cEmpAtu, cFilAtu )
				EndIf
				*/
			EndIf
		EndIf
	EndIf
EndIf
Restarea( aAreaSZF )
Restarea( aArea )
Return lRet


/*/{Protheus.doc} ESTX003D
Exclus�o do Ticket de pesagem
@type function
@author Geronimo Benedito ALves
@since 18/07/2023
/*/
User Function ESTX003D
Local cNum_Carga :=  SZZ->ZZ_CARGA  
             
dbSelectArea("SZZ")   
nOpca := AxDeleta("SZZ",Recno(),5)						//AxDeleta( <cAlias>, <nReg>, <nOpc>, <cTransact>, <aCpos>, <aButtons>, <aParam>, <aAuto>, <lMaximized>)
If MsgYesNo("Deseja que esta carga ("+ cNum_Carga + ") retorne para o Status 3 (azul) = Ve�culo carregado , para poder ser reutilizado em futuro controle de pesagem ?","Reutilizar numero de carga")
	dbSelectArea("SZF")   
	SZF->(dbSetOrder(1))
	If SZF->(dbSeek(xFilial("SZF")+cNum_Carga))                          
		RecLock("SZF", .F.)
			SZF->ZF_STATUS	:= "3"		// RETORNO A CARGA PARA O STATUS "3"
		SZF->( MsUnlock() )
	Endif

	dbSelectArea("SZG")
	SZG->(dbSetOrder(1))
	If SZG->(dbSeek(xFilial("SZG")+cNum_Carga))                          
		While !EoF() .And. xFilial("SZG") +SZG->ZG_NUM == xFilial("SZF") + cNum_Carga
			RecLock("SZG", .F.)
				SZG->ZG_DTENTR  := cTOD("")		// NOS ITENS DA CARGA, "LIMPO" O CAMPO DATA DE ENTREGA 
				SZG->ZG_RETORNO := " "			// "LIMPO" TAMBEM O CAMPO NF RETORNADA POIS O campo ZG_RETORNO DEVE ESTAR com "2-NAO" quando informado data de entrega da NF E EM BRANCO QUANDO A DATA ESTIVER VAZIA
			SZG->( MsUnlock() )
			DbSkip()
		Enddo
	Endif

	dbSelectArea("SZZ")   
EndIf 


//nOpca := AxAltera("SZZ", Recno(), 4,,,,,,,, aButtons)  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Atualiza historico do ticket de pesagem referente a NF Entrada    	³
//|** Finalizacao do Ticket                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == 1 .And. !Empty(SZZ->ZZ_DTPES2)
	U_ESTX003H(SZZ->ZZ_CODIGO, 5)
EndIf

Return


/*/{Protheus.doc} ESTX003L
LEGENDA
@type function
@author Tiago O. Beraldi
@since 04/05/10
/*/
User Function ESTX003L()
Local aLegenda := {}
aAdd( aLegenda, {"BR_VERDE"    ,"Em Aberto"  })
aAdd( aLegenda, {"BR_VERMELHO" ,"Finalizado" })    
aAdd( aLegenda, {"BR_PRETO"    ,"Cancelado" })    
BrwLegenda(cCadastro, "Legenda", aLegenda)
Return 


/*/{Protheus.doc} GravaPeso
description
@type function
@author Tiago O. Beraldi
@since 04/05/10
/*/
Static Function GravaPeso()
                      
Local nPeso1 := 0
Local nPeso2 := 0

dbSelectArea("SZZ")
                                 
If !M->ZZ_FLAGP1
	CursorWait()     
	nPeso1 := LePeso()
	If MsgYesNo("Confirma a 1ª pesagem (" + Transform(nPeso1, "@E 999,999,999.99") + ") ?", "Controle de Pesagem")
		M->ZZ_PESO1  := nPeso1
		M->ZZ_DTPES1 := dDataBase
		M->ZZ_HRPES1 := Time()  
		M->ZZ_USRP1  := cUserName
		M->ZZ_FLAGP1 := .T.
		MsgInfo("Primeira Pesagem Capturada! Confira a pesagem.")		
	EndIf
	CursorArrow()    
ElseIf !M->ZZ_FLAGP2
	CursorWait()     
	nPeso2 := LePeso()
	If MsgYesNo("Confirma a 2ª pesagem (" + Transform(nPeso2, "@E 999,999,999.99") + ") ?", "Controle de Pesagem")
		M->ZZ_PESO2  := nPeso2
		M->ZZ_DTPES2 := dDataBase
		M->ZZ_HRPES2 := Time()  
		M->ZZ_USRP2  := cUserName
		M->ZZ_FLAGP2 := .T.
		MsgInfo("Segunda Pesagem Capturada! Confira a pesagem.")		
	EndIf
	CursorArrow()    
Else
	MsgStop("Primeira e segunda pesagens já foram capturadas!")
EndIf  

Return


/*/{Protheus.doc} LePeso
EFETUA LEITURA DO PESO 
@type function
@author Tiago O. Beraldi
@since 04/05/10
@return Numeric, Peso lido
/*/
Static Function LePeso()
              
Local lSai    := .T.  
Local cText   := ""     
Local nVezes  := 0

Private nHdll := 0       

While lSai .And. nVezes <= 50

	nVezes++ 

	//MSOpenPort(nHdll, "COM1:9600,e,8,2") 
	//MSOpenPort(nHdll, "COM1:9600,N,8,1") Alterado 17/08/2018 Novo equipamento balança
	//Configuração balança: Protocolo E24 - Ano 5 (Inteiro)	- Módulo BJNET
	MSOpenPort(nHdll, "COM3:9600,E,8,1") 
	lCom := MsRead(nHdll,cText) 

	If !lCom
	
		MsgStop("Não foi possível ler informações! Faça a leitura do peso novamente.")   
		Return nPeso
	
	Else
 
    	cText  := ""
    	aText  := Array(3)    
	
		Sleep(800)
		MsRead(nHdll, @cText) 
		MSClosePort(nHdll)

		aText[1] := Subs(cText, 05, 26)
		aText[2] := Subs(cText, 35, 26)
		aText[3] := Subs(cText, 65, 26)    

		If aText[1] == aText[2] .And. aText[1] == aText[3] .And. !Empty(aText[1]) .And. !(" " $ aText[1]) 
			lSai := .F. 
		EndIf          

	EndIf
		
EndDo   

Return (Val(Subs(aText[1], 1, 7)))           


/*/{Protheus.doc} ESTX003R
Impress�o do ticket de pesagem
@type function
@author Tiago O. Beraldi
@since 05/05/10
/*/
User Function ESTX003R()  

Local aArea    := GetArea()           
Local aAreaSZF := SZF->(GetArea())
Local aAreaSZG := SZG->(GetArea())      
Local cLog     := ""   
Local cQry     := ""

Local aRom     := {}
            
dbSelectArea("SZZ")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Gera TXT                                                             ³
//|Criar arquivo estx003i.bat na pasta de instalação do Smartclient     ³
//|Local com o conteúdo:                                                ³
//|copy C:\Protheus\ESTX003I.txt LPT1                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

If 'TICKET CANCELADO' $ SZZ->ZZ_OBS
	MsgStop("Ticket Cancelado !")
	Return 
Endif

If Empty(SZZ->ZZ_DTPES2) .Or. SZZ->ZZ_PESO2 == 0
	MsgStop("Sem segunda pesagem ou peso zero !")
	Return 
EndIf

If ! U_PORTAUSR()		// Se o usu�rio do Protheus N�O FOR do setor portaria, N�O permito efetuar a impress�o do Ticket de pesagem
	Return 
EndIf


If SZZ->ZZ_PESDOC1 == 0 ;
   .And. SZZ->ZZ_PESDOC2 == 0 ;
   .And. SZZ->ZZ_PESDOC3 == 0 ;
   .And. SZZ->ZZ_PESDOC4 == 0 ;
   .And. SZZ->ZZ_PESOCG == 0

	MsgStop("Informe o peso bruto da nota fiscal !")
	Return  
	
EndIf
       
// FS - Retirado, não entendi o proposito, entretanto, problemas na impressão exigem intervenção no SDU... Por isso, comentado por enquanto.
//If SZZ->ZZ_QTDIMP > 0 
//	MsgStop("Ticket já foi impresso!")
//	Return 
//EndIf

If SZZ->ZZ_TIPO == "CG"

	If EMPTY(SZZ->ZZ_CARGA) .And. SZZ->ZZ_TIPO == "CG"
		MsgStop("Ticket sem uma carga associada!")
		Return 
	EndIf
            	
	cQry := "SELECT ZZ_CODIGO TICKET" + ENTER
	cQry += "FROM " + RetSqlName("SZZ") + ENTER
	cQry += "WHERE D_E_L_E_T_ = '' " + ENTER
	cQry += "AND ZZ_FILIAL = '" + xFilial("SZZ") + "' " + ENTER
	cQry += "AND ZZ_CARGA = '" + SZZ->ZZ_CARGA + "' " + ENTER
	
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf                  
	
	TCQUERY cQry NEW ALIAS QRY       
	
	If QRY->( !EoF() ) .And. QRY->TICKET != SZZ->ZZ_CODIGO
		MsgStop("Carga já associada ao ticket " + QRY->TICKET + ".")
		Return 		     
	EndIf

EndIf	

If !lImpLaser
	fGeraTxt()
EndIf	

If MsgYesNo("Confirma impressão ?","Controle de Pesagem")
	
	dbSelectArea("SZZ")

	RecLock("SZZ", .F.)
		SZZ->ZZ_QTDIMP := SZZ->ZZ_QTDIMP + 1
	SZZ->( MsUnLock() )

	If SZZ->ZZ_TIPO == "CG"  // Carga	

		aAdd(aRom, {SZZ->ZZ_TPDOC1, SZZ->ZZ_DOC1})
		aAdd(aRom, {SZZ->ZZ_TPDOC2, SZZ->ZZ_DOC2})
		aAdd(aRom, {SZZ->ZZ_TPDOC3, SZZ->ZZ_DOC3})	
		aAdd(aRom, {SZZ->ZZ_TPDOC4, SZZ->ZZ_DOC4})
		

	    /*
	    
	    Grupo Empresas - Regra original comentada em 28.08.2020 (CG)
	    
	    Obs. Tabela SZ4 ( Não existe na SX2 de todas as empresas )  

		For i := 1 to Len(aRom)

			cExec := ""

			If aRom[i, 1] == "RE"   
				cExec := " UPDATE SZ4020 " + ENTER
				cExec += " SET 		Z4_STATUS = '2' " + ENTER
				cExec += " WHERE 	Z4_ROMANEI = '" + aRom[i, 2] + "' " + ENTER
			ElseIf aRom[i, 1] == "RQ"
				cExec := " UPDATE SZ4030 " + ENTER
				cExec += " SET 		Z4_STATUS = '2' " + ENTER
				cExec += " WHERE 	Z4_ROMANEI = '" + aRom[i, 2] + "' " + ENTER
			ElseIf aRom[i, 1] == "RJ"
				cExec := " UPDATE SZ4010 " + ENTER
				cExec += " SET 		Z4_STATUS = '2' " + ENTER
				cExec += " WHERE 	Z4_ROMANEI = '" + aRom[i, 2] + "' " + ENTER
				cExec += "          AND Z4_FILIAL = '07' " + ENTER
			EndIf
			
			If !Empty(cExec) .And. (TcSQLExec(cExec) < 0)
				Return MsgStop("TCSQLError() " + TCSQLError())
			EndIf	
			
		Next i  

       */
		
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza status da carga para TRANSITO ou FINALIZADO   ³
	//³ e associa o numero da carga ao pedido de venda         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	If !Empty(SZZ->ZZ_CARGA)
	
		//+----------------------------------------------
		//| SZF
		//+----------------------------------------------
		dbSelectArea("SZF")
		dbSetOrder(1)			
		dbSeek( xFilial("SZF") + SZZ->ZZ_CARGA )

		If SZF->( Found() ) 
		
			If SZF->ZF_TIPO $ "1#4" /* 1-CARGA # 4-RETIRA */
		              			
				//+----------------------------------------------
				//| SZG
				//+----------------------------------------------
				dbSelectArea("SZG")
				dbSetOrder(1)                
				dbSeek(xFilial("SZG")+SZF->ZF_NUM)
				
				While !EoF() .And. SZG->(ZG_FILIAL+ZG_NUM) == SZF->(ZF_FILIAL+ZF_NUM)
				            
					cIDEmp := AllTrim(Subs(SZG->ZG_EMPFIL,1,2))
					cIDFil := AllTrim(Subs(SZG->ZG_EMPFIL,3,2))

					//+----------------------------------------------
					//| Pedido de Venda ( SC5 )
					//+----------------------------------------------
					/*cExec := "UPDATE " + IIf( cIDEmp == "01", "SC5010", IIf( cIDEmp == "02", "SC5020", "SC5030" ) ) + ENTER
					cExec += "SET		C5_ROMANEI = '" + SZG->ZG_NUM + "' " + ENTER
					cExec += "WHERE		D_E_L_E_T_ = '' " + ENTER
					cExec += "AND 		C5_FILIAL = '" + cIDFil + "' " + ENTER
					cExec += "AND 		C5_NOTA = '" + SZG->ZG_NOTA + "' " + ENTER
					cExec += "AND 		C5_SERIE = '" + SZG->ZG_SERIE + "' " + ENTER				
                                           
					If (TcSQLExec(cExec) < 0)
						Return MsgStop("TCSQLError() " + TCSQLError())
					EndIf		*/

					//+----------------------------------------------
					//| Items da Carga ( 4 - RETIRA )
					//+----------------------------------------------]
					If SZF->ZF_TIPO == "4"   
					
						dbSelectArea("SZG")
						RecLock("SZG", .F.)
							SZG->ZG_DTENTR  := dDatabase
							SZG->ZG_RETORNO := "2"
						SZG->( MsUnlock() )
						
					EndIf
						
					//+----------------------------------------------
					//| Avanca para o proximo registro
					//+----------------------------------------------]
					dbSkip()     
				
				EndDo
                
			EndIf				                 
			
			//+----------------------------------------------
			//| SZF
			//+----------------------------------------------
			cLog	:= U_FATX011H(9, SZZ->ZZ_CODIGO)   
			cStatus	:= IIf( SZF->ZF_TIPO == "1", "4", "6" )
			     
			dbSelectArea("SZF")
			RecLock("SZF", .F.)
				SZF->ZF_STATUS	:= cStatus
				SZF->ZF_LOG		:= cLog
			SZF->( MsUnlock() )

		EndIf

	EndIf

	If !lImpLaser
		Processa({|lEnd| fExecImp()},"Executa impressão...")
	Else		
		Processa({|lEnd| EqImpPes()},"Executa impressão...")
	EndIf	

	
EndIf          

Restarea( aAreaSZF )
RestArea( aAreaSZG )
RestArea( aArea )

Return   


/*/{Protheus.doc} fGeraTxt
IMPRESSAO DA PESAGEM em arquivo txt
@type function
@author Tiago O. Beraldi
@since 05/05/10
/*/
Static Function fGeraTxt()

Local cPath      := "C:\Protheus12\"
Local aDirectory := Directory(cPath + "ESTX003I.*")   // Identifica todos os arquivos do DIR  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o arquivo texto                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cArqTxt := "C:\Protheus12\ESTX003I.txt"
Private cArqBat := "C:\Protheus12\ESTX003I.bat"
Private nHdlTxt := fCreate(cArqTxt)
Private nHdlBat := fCreate(cArqBat)  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga arquivos do diretorio                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEval(aDirectory, {|x| FErase(cPath + x[1])}) 

If nHdlTxt == -1
	MsgAlert("O arquivo de nome " + cArqTxt + " nao pode ser executado! Verifique os parametros.","Atencao!")
	Return
Endif

If nHdlBat == -1
	MsgAlert("O arquivo de nome " + cArqBat + " nao pode ser executado! Verifique os parametros.","Atencao!")
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a regua de processamento                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Processa({|| fImpPes() },"Processando...")  
Return    


/*/{Protheus.doc} fExecImp
GERA IMPRESSAO 
@type function
@author Tiago O. Beraldi 
@since 05/05/10
/*/
Static Function fExecImp()
WaitRun("C:\Protheus12\ESTX003I.bat", 0)     // Copia para LPT1  
Return


/*/{Protheus.doc} fImpPes
IMPRESSAO DA PESAGEM 
@type function
@author Tiago O. Beraldi
@since 05/05/10
/*/
Static Function fImpPes()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nPeso := IIf(!Empty(SZZ->ZZ_CARGA), SZZ->ZZ_PESOCG, (SZZ->ZZ_PESDOC1 + SZZ->ZZ_PESDOC2 + SZZ->ZZ_PESDOC3 + SZZ->ZZ_PESDOC4))


Private cTexto
Private cBatch
                            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³- Configuracao dos caracteres:                                       |
//³Ativa negrito          chr(27)+chr(69)                               |
//³Desativa negrito       chr(27)+chr(70)                               |
//³Ativa expandido        chr(27)+chr(87)+chr(1)                        |
//³Desativa expandido     chr(27)+chr(87)+chr(0)                        |
//³Ativa carta            chr(27)+chr(120)+chr(1)                       |
//³Desativa carta         chr(27)+chr(120)+chr(0)                       |
//³Ativa italic           chr(27)+chr(52)                               |
//³Desativa italic        chr(27)+chr(53)                               |
//³Ativa comprimido       chr(27)+chr(15)                               |
//³Desativa comprimido    chr(27)+chr(18)                               |
//³Desativa todos         chr(27)+chr(64)                               |
//³                                                                     |
//³- Configuracao de entrelinhas:                                       |
//³chr(27)+'2'            6 linhas por polegada                         |
//³chr(27)+'0'            8 linhas por polegada                         |
//³chr(27)+'P'+chr(18)    10 caracteres por polegada                    |
//³chr(27)+'M'+chr(18)    12 caracteres por polegada                    |
//³chr(27)+'P'+chr(15)    17 caracteres por polegada                    |
//³chr(27)+'M'+chr(15)    20 caracteres por polegada                    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cabecalho                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTexto  := chr(27) + chr(64)
cTexto  += Replicate("=", 80) + chr(13) + chr(10) + chr(13) + chr(10)
cTexto  += chr(27) + chr(87) + chr(1)
cTexto  += "EUROAMERICAN DO BRASIL IMP IND E COM LTD" + chr(13) + chr(10) + chr(13) + chr(10)
cTexto  += chr(27) + chr(87) + chr(0)
cTexto  += "AV ANTONIO BARDELLA, 789 - JD SAO LUIZ - JANDIRA - SP - CEP 06618-000" + chr(13) + chr(10) + chr(13) + chr(10)
cTexto  += Replicate("=", 80) + chr(13) + chr(10) + chr(13) + chr(10)
cTexto  += chr(27) + chr(87) + chr(1)
cTexto  += "TICKET: " + SZZ->ZZ_CODIGO + " EMISSAO: " + DtoC(dDataBase) + " " + Subs(Time(), 1, 5) + chr(13) + chr(10) + chr(13) + chr(10)
cTexto  += chr(27) + chr(87) + chr(0)
cTexto  += Replicate("=", 80) + chr(13) + chr(10) + chr(13) + chr(10)
cTexto  += "PLACA...............: " + chr(27) + chr(87) + chr(1) + SZZ->ZZ_PLACA + chr(27) + chr(87) + chr(0) + chr(13) + chr(10)
cTexto  += "DOCUMENTO...........: " + chr(27) + chr(87) + chr(0) + (AllTrim(SZZ->ZZ_TPDOC1 + SZZ->ZZ_DOC1) + "-" + Alltrim(SZZ->ZZ_TPDOC2 + SZZ->ZZ_DOC2) + "-" + Alltrim(SZZ->ZZ_TPDOC3 + SZZ->ZZ_DOC3) + "-" + Alltrim(SZZ->ZZ_TPDOC4 + SZZ->ZZ_DOC4)) + chr(27) + chr(87) + chr(0) + chr(13) + chr(10)
cTexto  += "PRIMEIRA PESAGEM....: " + chr(27) + chr(87) + chr(1) + Transform(SZZ->ZZ_PESO1, "@E 999,999,999") + " KG " + chr(27) + chr(87) + chr(0) + "DATA: " + DtoC(SZZ->ZZ_DTPES1) + " " + SZZ->ZZ_HRPES1 + chr(13) + chr(10)
cTexto  += "SEGUNDA PESAGEM.....: " + chr(27) + chr(87) + chr(1) + Transform(SZZ->ZZ_PESO2, "@E 999,999,999") + " KG " + chr(27) + chr(87) + chr(0) + "DATA: " + DtoC(SZZ->ZZ_DTPES2) + " " + SZZ->ZZ_HRPES2 + chr(13) + chr(10)
cTexto  += "LIQUIDO.............: " + chr(27) + chr(87) + chr(1) + Transform(Abs(SZZ->ZZ_PESO1 - SZZ->ZZ_PESO2), "@E 999,999,999")  + " KG " + chr(27) + chr(87) + chr(0) + chr(13) + chr(10)
cTexto  += "PESO DA NOTA........: " + chr(27) + chr(87) + chr(1) + Transform(nPeso, "@E 999,999,999") + " KG " + chr(27) + chr(87) + chr(0) + chr(13) + chr(10)
cTexto  += "DIFERENCA...........: " + chr(27) + chr(87) + chr(1) + Transform(Abs(SZZ->ZZ_PESO1 - SZZ->ZZ_PESO2) - nPeso, "@E 999,999,999") + "  " +  Transform(100 * ((Abs(SZZ->ZZ_PESO1 - SZZ->ZZ_PESO2) - nPeso)/nPeso), "@E 999.99") + " %" + chr(27) + chr(87) + chr(0) + chr(13) + chr(10) + chr(13) + chr(10)
cTexto  += Replicate("=", 80) + chr(13) + chr(10)
cTexto  += chr(27) + chr(64)      
cTexto  += Replicate(chr(13) + chr(10), 20) 
            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera Batch                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ            
cBatch  := "copy C:\Protheus12\ESTX003I.txt LPT1"
	
If fWrite(nHdlTxt,cTexto,Len(cTexto)) != Len(cTexto)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
	Endif
Endif

If fWrite(nHdlBat,cBatch,Len(cBatch)) != Len(cBatch)
	If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
	Endif
Endif

fClose(nHdlTxt)
fClose(nHdlBat)

Return   

    
/*/{Protheus.doc} ESTX003P
DIFERENCA DE PESO - ATUALIZA CAMPO VIRTUAL 
@type function
@author Tiago O. Beraldi
@since 05/05/10
@return numeric, Numero com a diferen�a
/*/
User Function ESTX003P
                 
dbSelectArea("SZZ")
nDif := (Abs(SZZ->ZZ_PESO1 - SZZ->ZZ_PESO2) - (SZZ->ZZ_PESDOC1 + SZZ->ZZ_PESDOC2 + SZZ->ZZ_PESDOC3 + SZZ->ZZ_PESDOC4))            

Return  nDif           


/*/{Protheus.doc} ESTX003K
VERIFICA SE A PESAGEM EM ABERTO PARA A PLACA DIGITADA
@description em 02/01/18 foi retirado bloqueio (em caso de retornar .F.) temporariamente para permitir lançamentos regulização pós migração P12
@type function
@author Tiago O. Beraldi
@since 05/05/10
@return logical, .T. n�o tem pesagem em aberto.   .F. tem pesagem em aberto
/*/                                                                                                                                                         
User Function ESTX003K()

Local lRet := .T.

cQry := " SELECT	ZZ_CODIGO CODIGO" + chr(13) + chr(10)
cQry += " FROM	" + RetSqlName("SZZ") + chr(13) + chr(10)
cQry += " WHERE	D_E_L_E_T_ = '' " + chr(13) + chr(10)
cQry += " 		AND ZZ_PESO2 = 0 " + chr(13) + chr(10)
cQry += " 		AND ZZ_PLACA = '" + M->ZZ_PLACA + "' " + chr(13) + chr(10)
cQry += "       AND NOT (ISNULL(UPPER(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),ZZ_OBS))),'')) LIKE '%TICKET CANCELADO%' " + chr(13) + chr(10)
cQry += " 		AND ZZ_EMISSAO >= '20170614' " 		//20100614
cQry := ChangeQuery(cQry)

If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf      

TCQUERY cQry NEW ALIAS QRY
   
dbSelectArea("QRY")

If !QRY->(EOF()) 
	//lRet := .F. 	02/01/18 Retirado bloqueio temporariamente para permitir lançamentos regulização pós migração P12
	MsgStop("Existe pesagem em aberto para a placa! Numero: " + QRY->CODIGO)
EndIf
QRY->(dbCloseArea())
Return lRet  

                                                                                                                                    

/*/{Protheus.doc} ESTX003G
VALIDACOES E ATUALIZACAO DE CAMPOS DA PESAGEM 
@type function
@author Tiago O. Beraldi
@since 05/05/10
@param nOpc,   numeric, Se nOpc for 1 == Documentos 
@param aParam, array,   parametro desconhecido (esta fun��o n�o esta em uso atualmente)
@return numerico, retorna 0  ou o numero que vier no aparam[3]
/*/
User Function ESTX003G(nOpc, aParam)
          
Local xRet   := 0
Local aArea  := GetArea()

If nOpc == 1 // Documentos     

	xRet := aParam[3]

	/*

	Grupo Empresas - Regra original comentada em 28.08.2020 (CG)
	    
	Obs. Tabela SZ4 ( Não existe na SX2 de todas as empresas )  

	If aParam[2] == "RE"    
	                           
		cQry := " SELECT ISNULL(SUM(F2_PBRUTO), 0) QUANT " + chr(13) + chr(10)
		cQry += " FROM SF2020 " + chr(13) + chr(10)
		cQry += " WHERE  D_E_L_E_T_ <> '*' " + chr(13) + chr(10)
		cQry += "        AND (F2_DOC + F2_SERIE) IN (SELECT  (Z4_NOTA + Z4_SERIE) " + chr(13) + chr(10)
		cQry += " 	                    FROM    SZ4020 " + chr(13) + chr(10)
		cQry += "                       WHERE	D_E_L_E_T_ <> '*' " + chr(13) + chr(10)
		cQry += "        				        AND Z4_ROMANEI = '" + aParam[1] + "' " + chr(13) + chr(10) 
		//cQry += "        				        AND ( RTRIM(Z4_PLACA1) = '' OR Z4_PLACA1 = '" + aParam[4] + "')" + chr(13) + chr(10) 
		cQry += "        				        AND Z4_CODIGO <> 'ME.0044'" + chr(13) + chr(10) 
     	cQry += " 						GROUP BY Z4_NOTA, Z4_SERIE) "
		
	ElseIf aParam[2] == "RQ"

		cQry := " SELECT ISNULL(SUM(F2_PBRUTO), 0) QUANT " + chr(13) + chr(10)
		cQry += " FROM SF2030 "  + chr(13) + chr(10)
		cQry += " WHERE  D_E_L_E_T_ <> '*' " + chr(13) + chr(10)
		cQry += "        AND (F2_DOC + F2_SERIE) IN (SELECT  Z4_NOTA + Z4_SERIE " + chr(13) + chr(10)
		cQry += " 	                    FROM    SZ4030 " + chr(13) + chr(10)
		cQry += "                       WHERE	D_E_L_E_T_ <> '*' " + chr(13) + chr(10)
		cQry += "        				        AND Z4_ROMANEI = '" + aParam[1] + "' " + chr(13) + chr(10)
		//cQry += "        				        AND ( RTRIM(Z4_PLACA1) = '' OR Z4_PLACA1 = '" + aParam[4] + "')" + chr(13) + chr(10) 
		cQry += "        				        AND Z4_CODIGO <> 'ME.0044'" + chr(13) + chr(10) 
     	cQry += " 						GROUP BY Z4_NOTA, Z4_SERIE) " 
     	
    ElseIf aParam[2] == "RJ"

		cQry := " SELECT ISNULL(SUM(F2_PBRUTO), 0) QUANT " + chr(13) + chr(10)
		cQry += " FROM SF2010 "  + chr(13) + chr(10)
		cQry += " WHERE  D_E_L_E_T_ <> '*' " + chr(13) + chr(10)
		cQry += "        AND (F2_DOC + F2_SERIE) IN (SELECT  Z4_NOTA + Z4_SERIE " + chr(13) + chr(10)
		cQry += " 	                    FROM    SZ4010 " + chr(13) + chr(10)
		cQry += "                       WHERE	D_E_L_E_T_ <> '*' " + chr(13) + chr(10)
		cQry += "        				        AND Z4_ROMANEI = '" + aParam[1] + "' " + chr(13) + chr(10)
		//cQry += "        				        AND ( RTRIM(Z4_PLACA1) = '' OR Z4_PLACA1 = '" + aParam[4] + "')" + chr(13) + chr(10) 
		cQry += "        				        AND Z4_CODIGO <> 'ME.0044'" + chr(13) + chr(10) 
     	cQry += " 						GROUP BY Z4_NOTA, Z4_SERIE) "
	
	EndIf   

	If !Empty(cQry)	

		MemoWrite("estx003g.sql", cQry)   
		
		cQry := ChangeQuery(cQry)
	
		If Select("QRY1") > 0
			QRY1->(dbCloseArea())
		EndIf      

		TCQUERY cQry NEW ALIAS QRY1
	
		dbSelectArea("QRY1")
	
		If QRY1->QUANT == 0 
			MsgStop("Romaneio inválido! Verifique e digite o número do Romaneio completo (DEVE CONTER 6 DIGITOS).")   
		Else
			xRet := QRY1->QUANT
		EndIf
			
		QRY1->(dbCloseArea())   
		
	EndIf

   */	

EndIf      
RestArea(aArea)
Return xRet


/*/{Protheus.doc} ESTX003V
APROVACAO DE PESAGEM DIVERGENTE 
@type function
@author Tiago O. Beraldi 
@since 27/08/12
/*/ 
User Function ESTX003V     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cEmiss     := ""
Local cCodigo    := ""
Local cPeso	     := ""   
Local cAprMot    := CriaVar("ZZ_APRMOT")
Local cUsrOpc 	 := Alltrim(SuperGetMV("ES_PAREST1",.T.,""))

Private oDlg    := Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Valida usuario                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If 	!Upper(AllTrim(cUserName)) $ Upper(AllTrim(cUsrOpc))// "ADMINISTRADOR#WENDEL.DIAS#CARLOS.ARAUJO#PRISCILA.ARTHUZO#CAROLINE.MONEA#THIAGO.MONEA#LIGIA.MARTINS"
//If Upper(RTrim(cUserName)) $ Upper(RTrim(cUsrOpc))		
	MsgStop("Usuário sem acesso a aprovação de ticket!")
	Return
EndIf

If AllTrim( SZZ->ZZ_TIPO ) == "DG"

    /*

    Grupo Empresas - Regra original comentada em 28.08.2020 (CG)
	
	cQuery := "SELECT SUM(CONTA) AS TICKETS " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTA " + CRLF
	cQuery += "FROM " + RetSqlName("SF1") + " AS SF1 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE F1_FILIAL <> '**' " + CRLF
	cQuery += "AND F1_TICPESA = '" + SZZ->ZZ_CODIGO + "' " + CRLF
	cQuery += "AND SF1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTA " + CRLF
	If cEmpAnt == "02"
		cQuery += "FROM SF1080 AS SF1 WITH (NOLOCK) " + CRLF
	Else
		cQuery += "FROM SF1020 AS SF1 WITH (NOLOCK) " + CRLF
	EndIf
	cQuery += "WHERE F1_FILIAL <> '**' " + CRLF
	cQuery += "AND F1_TICPESA = '" + SZZ->ZZ_CODIGO + "' " + CRLF
	cQuery += "AND SF1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF

    */
	
	cQuery := "SELECT SUM(CONTA) AS TICKETS " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTA " + CRLF
	cQuery += "FROM " + RetSqlName("SF1") + " AS SF1 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE F1_FILIAL <> '**' " + CRLF
	cQuery += "AND F1_TICPESA = '" + SZZ->ZZ_CODIGO + "' " + CRLF
	cQuery += "AND SF1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTA " + CRLF
	cQuery += "FROM " + RetSqlName("SF1") + " AS SF1 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE F1_FILIAL <> '**' " + CRLF
	cQuery += "AND F1_TICPESA = '" + SZZ->ZZ_CODIGO + "' " + CRLF
	cQuery += "AND SF1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF

	TCQuery cQuery New Alias "VLDVINC"
	dbSelectArea("VLDVINC")
	dbGoTop()
	
	If !VLDVINC->( Eof() )
		If VLDVINC->TICKETS == 0
			ApMsgAlert("Ticket não vinculada a nenhuma nota fiscal, aprovação não permitida!","Atenção")
			Return .F.
		EndIf
	Else
		ApMsgAlert("Ticket não vinculada a nenhuma nota fiscal, aprovação não permitida!","Atenção")
		Return .F.
	EndIf
	
	VLDVINC->( dbCloseArea() )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Definicao da janela e seus conteudos                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SZZ") 
                            
cEmiss	:= DtoC(SZZ->ZZ_EMISSAO)
cCodigo	:= SZZ->ZZ_CODIGO

cPeso  := Replicate("=", 70)
cPeso  += chr(13) + chr(10) 
cPeso  += "PLACA...............: " + SZZ->ZZ_PLACA
cPeso  += chr(13) + chr(10) 
cPeso  += "DOCUMENTO...........: " + (AllTrim(SZZ->ZZ_TPDOC1 + SZZ->ZZ_DOC1) + "-" + Alltrim(SZZ->ZZ_TPDOC2 + SZZ->ZZ_DOC2) + "-" + Alltrim(SZZ->ZZ_TPDOC3 + SZZ->ZZ_DOC3) + "-" + Alltrim(SZZ->ZZ_TPDOC4 + SZZ->ZZ_DOC4))
cPeso  += chr(13) + chr(10) 
cPeso  += "PRIMEIRA PESAGEM....: " + Transform(SZZ->ZZ_PESO1, "@E 999,999,999") + " KG "
cPeso  += chr(13) + chr(10) 
cPeso  += "PESO DA NOTA........: " + Transform(SZZ->ZZ_PESDOC1 + SZZ->ZZ_PESDOC2 + SZZ->ZZ_PESDOC3 + SZZ->ZZ_PESDOC4, "@E 999,999,999") + " KG "
cPeso  += chr(13) + chr(10) 
cPeso  += Replicate("=", 70)

DEFINE FONT oFont NAME "Courier New" SIZE 7,15

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 065,000 TO 504, 393 OF oDlg PIXEL

	@ 002, 004 TO  197, 197 LABEL "" PIXEL OF oDlg
                                        
	@ 007,010 Say "Código" Size 050,008 COLOR CLR_BLACK PIXEL OF oDlg
	@ 017,008 MsGet oCodigo Var cCodigo Size 060,009 COLOR CLR_BLACK Picture "@!" When .F. PIXEL OF oDlg

	@ 007,102 Say "Emissão" Size 050,008 COLOR CLR_BLACK PIXEL OF oDlg
	@ 017,100 MsGet oEmiss Var cEmiss Size 060,009 COLOR CLR_BLACK Picture "@R 99/99/99" When .F. PIXEL OF oDlg

	@ 035, 010 Say "Pesagem:" Size  037, 008 COLOR CLR_BLACK PIXEL OF oDlg
	@ 045, 008 GET oPeso Var cPeso MEMO Size  184, 065 When .F. PIXEL OF oDlg
	oPeso:oFont:=oFont

	@ 117, 010 Say "Motivo:" Size  018, 008 COLOR CLR_BLACK PIXEL OF oDlg
	@ 127, 008 GET oAprMot Var cAprMot MEMO Size 184, 065 PIXEL OF oDlg
	oAprMot:oFont:=oFont

	@ 204,055 Button "&Aprovar"  Size 037, 012 PIXEL OF oDlg ACTION ( IIf(ExecLib3(cAprMot), oDlg:End(), Nil) )
	@ 204,107 Button "&Cancelar" Size 037, 012 PIXEL OF oDlg ACTION ( oDlg:End() )
ACTIVATE MSDIALOG oDlg CENTERED 
Return


/*/{Protheus.doc} ExecLib3
aprova��o do ticket divergente
@type function
@author Tiago O. Beraldi 
@since 27/08/12 
@param cAprMot, character, Recebe as INFORMACOES DE APROVACAO DO TICKET 
@return logical, Se .T. aprova��o do ticket divergente aprovado. Se for .F. aprova��o n�o efetuada.
/*/
Static Function ExecLib3(cAprMot)     

Local lRet    := .F.              
Local aWFIDs  := {}          // FS
Local nLin    := 0           // FS
Local lEnvAtu := .T.
lOCAL nPosWF	:= 0

If !Empty( SZZ->ZZ_APROV )
	ApMsgInfo( "Controle de Pesagem já Aprovada Anteriormente", "Atenção")
	Return lRet
EndIf

If MsgYesNo("Deseja prosseguir com a aprovação do ticket divergente ?", "Controle de Pesagem") // .And. !Empty(cAprMot)
	
	dbSelectArea("SZZ")
	
	RecLock("SZZ", .F.)
		SZZ->ZZ_APROV  := AllTrim(cUserName) + "-" + DtoC(dDataBase) + "  " + Time()
		SZZ->ZZ_APRMOT := cAprMot
	SZZ->( MsUnLock() )
	
	lRet := .T.
	
	If AllTrim( SZZ->ZZ_TIPO ) == "DG"
		If !Empty( SZZ->ZZ_APROV )

            /*
            
            Grupo Empresas - Regra original comentada em 28.08.2020 (CG)

			cQuery := "SELECT '02' AS EMPRESA, D1_FILIAL, D1_PEDIDO " + CRLF
			cQuery += "FROM SD1020 AS SD1 WITH (NOLOCK) " + CRLF
			cQuery += "INNER JOIN SF1020 AS SF1 WITH (NOLOCK) ON F1_FILIAL = D1_FILIAL " + CRLF
			cQuery += "  AND F1_DOC = D1_DOC " + CRLF
			cQuery += "  AND F1_SERIE = D1_SERIE " + CRLF
			cQuery += "  AND F1_FORNECE = D1_FORNECE " + CRLF
			cQuery += "  AND F1_LOJA = D1_LOJA " + CRLF
			cQuery += "  AND F1_TIPO = D1_TIPO " + CRLF
			cQuery += "  AND F1_TICPESA = '" + SZZ->ZZ_CODIGO + "' " + CRLF
			cQuery += "  AND SF1.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += "WHERE D1_FILIAL <> '**' " + CRLF
			cQuery += "AND SD1.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += "UNION ALL " + CRLF
			cQuery += "SELECT '08' AS EMPRESA, D1_FILIAL, D1_PEDIDO " + CRLF
			cQuery += "FROM SD1080 AS SD1 WITH (NOLOCK) " + CRLF
			cQuery += "INNER JOIN SF1080 AS SF1 WITH (NOLOCK) ON F1_FILIAL = D1_FILIAL " + CRLF
			cQuery += "  AND F1_DOC = D1_DOC " + CRLF
			cQuery += "  AND F1_SERIE = D1_SERIE " + CRLF
			cQuery += "  AND F1_FORNECE = D1_FORNECE " + CRLF
			cQuery += "  AND F1_LOJA = D1_LOJA " + CRLF
			cQuery += "  AND F1_TIPO = D1_TIPO " + CRLF
			cQuery += "  AND F1_TICPESA = '" + SZZ->ZZ_CODIGO + "' " + CRLF
			cQuery += "  AND SF1.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += "WHERE D1_FILIAL <> '**' " + CRLF
			cQuery += "AND SD1.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += "UNION ALL " + CRLF
			cQuery += "SELECT '06' AS EMPRESA, D1_FILIAL, D1_PEDIDO " + CRLF
			cQuery += "FROM SD1060 AS SD1 WITH (NOLOCK) " + CRLF
			cQuery += "INNER JOIN SF1060 AS SF1 WITH (NOLOCK) ON F1_FILIAL = D1_FILIAL " + CRLF
			cQuery += "  AND F1_DOC = D1_DOC " + CRLF
			cQuery += "  AND F1_SERIE = D1_SERIE " + CRLF
			cQuery += "  AND F1_FORNECE = D1_FORNECE " + CRLF
			cQuery += "  AND F1_LOJA = D1_LOJA " + CRLF
			cQuery += "  AND F1_TIPO = D1_TIPO " + CRLF
			cQuery += "  AND F1_TICPESA = '" + SZZ->ZZ_CODIGO + "' " + CRLF
			cQuery += "  AND SF1.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += "WHERE D1_FILIAL <> '**' " + CRLF
			cQuery += "AND SD1.D_E_L_E_T_ = ' ' " + CRLF

          */

			cQuery := "SELECT SD1.D1_PEDIDO " + CRLF
			cQuery += ",CASE WHEN LEFT(SD1.D1_FILIAL,2) = '01' THEN 'Distribuidora'" + CRLF
			cQuery += "      WHEN LEFT(SD1.D1_FILIAL,2) = '02' THEN 'Euroamerican'" + CRLF
			cQuery += "      WHEN LEFT(SD1.D1_FILIAL,2) = '03' THEN 'Qualyvinil'" + CRLF
			cQuery += "      WHEN LEFT(SD1.D1_FILIAL,2) = '06' THEN 'Metropole'" + CRLF
			cQuery += "      WHEN LEFT(SD1.D1_FILIAL,2) = '08' THEN 'Qualycril'" + CRLF
			cQuery += "      WHEN LEFT(SD1.D1_FILIAL,2) = '09' THEN 'Phoenix Quimica' END AS EMPRESA" + CRLF
			cQuery += "FROM " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) " + CRLF
			cQuery += "INNER JOIN " + RetSqlName("SF1") + " AS SF1 WITH (NOLOCK) ON SF1.F1_FILIAL = SD1.D1_FILIAL " + CRLF
			cQuery += "  AND SF1.F1_DOC = SD1.D1_DOC " + CRLF
			cQuery += "  AND SF1.F1_SERIE = SD1.D1_SERIE " + CRLF
			cQuery += "  AND SF1.F1_FORNECE = SD1.D1_FORNECE " + CRLF
			cQuery += "  AND SF1.F1_LOJA = SD1.D1_LOJA " + CRLF
			cQuery += "  AND SF1.F1_TIPO = SD1.D1_TIPO " + CRLF
			cQuery += "  AND SF1.F1_TICPESA = '" + SZZ->ZZ_CODIGO + "' " + CRLF
			cQuery += "  AND SF1.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += "WHERE SD1.D_E_L_E_T_ = ' ' " + CRLF

			TCQuery cQuery New Alias "TMPPES"
			dbSelectArea("TMPPES")
			dbGoTop()
			
			Do While !TMPPES->( Eof() )
				If Left(cFilAnt,2) <> AllTrim( TMPPES->EMPRESA )
					If !Empty( TMPPES->EMPRESA ) .And. !Empty( TMPPES->D1_FILIAL )
						Aviso("Saída Caminhão","Este Ticket pertence Nota Fiscal da empresa: " + TMPPES->EMPRESA + ENTER + "Caso gere erro na confirmação da pesagem por favor efetuar novo Login na empresa: " + TMPPES->EMPRESA,{"OK"},3)
						lRet := .F.
						/*
						lEnvAtu := .F.
						cEmpAtu := cEmpAnt
						cFilAtu := cFilAnt
						dbSelectArea("SM0")
						dbSetOrder(1)
						If SM0->( dbSeek( TMPPES->EMPRESA + TMPPES->D1_FILIAL ) )
							RpcClearEnv()  //Limpa o Ambiente
							RpcSetType(3)
							RpcSetEnv( TMPPES->EMPRESA, TMPPES->D1_FILIAL )
						EndIf
						*/
					EndIf
				ElseIf AllTrim( cFilAnt ) <> AllTrim( TMPPES->D1_FILIAL )
					lEnvAtu := .F.
					//Prepare Environment EMPRESA AllTrim( TMPPES->EMPRESA ) FILIAL AllTrim( TMPPES->D1_FILIAL )
					cFilAnt := AllTrim( TMPPES->D1_FILIAL )
				EndIf

				dbSelectArea("SC7")
				dbSetOrder(1)
				If SC7->( dbSeek( xFilial("SC7") + TMPPES->D1_PEDIDO ) )
					If aScan( aWFIDs, {|nLin| AllTrim( nLin[1] ) == AllTrim( SC7->C7_EUWFID ) }) == 0
						aAdd( aWFIDs, { AllTrim( SC7->C7_EUWFID ), SC7->C7_NUM })
					EndIf
				EndIf
			
				TMPPES->( dbSkip() )
			EndDo
			
			TMPPES->( dbCloseArea() )

			// Atualiza os processos da NF...
			For nPosWF := 1 To Len( aWFIDs )
				dbSelectArea("SC7")
				dbSetOrder(1)
				If SC7->( dbSeek( xFilial("SC7") + aWFIDs[nPosWF][2] ) )
					U_EQGeraWFC( "Protheus - Desembarque Concluído: " + AllTrim( SF1->F1_DOC ) + "|" + AllTrim( SF1->F1_SERIE ) + " Realizada. Pedido: " + AllTrim( SC7->C7_NUM ),;
					 			 "500001",;
								 "LIBERACAO SAIDA CAMINHAO",;
						         "1",;
								 "Desembarque Recebimento Concluído - Liberação Caminhão" )
				EndIf
			Next

			If !lEnvAtu
				//Reset Environment
				/*
				dbSelectArea("SM0")
				dbSetOrder(1)
				If SM0->( dbSeek( cEmpAtu + cFilAtu ) )
					RpcClearEnv()  //Limpa o Ambiente
					RpcSetType(3)
					RpcSetEnv( cEmpAtu, cFilAtu )
				EndIf
				*/
			EndIf
		EndIf
	EndIf
Else
	MsgStop("Motivo da aprovação não pode ser vazio !")	
EndIf
Return lRet


/*/{Protheus.doc} ESTX003X
EXIBE JANELA PARA CLASSIFICAR TICKET DE PESAGEM 
@type function
@author Tiago O. Beraldi 
@since 27/08/12 
/*/
User Function ESTX003X

Local aPboxPerg := {}
Local aPBoxRet  := {}

          
If AllTrim( SZZ->ZZ_TIPO ) == "DG"

   /*
    Grupo Empresas - Regra original comentada em 28.08.2020 (CG)

	cQuery := "SELECT SUM(CONTA) AS TICKETS " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTA " + CRLF
	cQuery += "FROM " + RetSqlName("SF1") + " AS SF1 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE F1_FILIAL <> '**' " + CRLF
	cQuery += "AND F1_TICPESA = '" + SZZ->ZZ_CODIGO + "' " + CRLF
	cQuery += "AND SF1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTA " + CRLF

	If cEmpAnt == "02"
		cQuery += "FROM SF1080 AS SF1 WITH (NOLOCK) " + CRLF
	Else
		cQuery += "FROM SF1020 AS SF1 WITH (NOLOCK) " + CRLF
	EndIf

	cQuery += "WHERE F1_FILIAL <> '**' " + CRLF
	cQuery += "AND F1_TICPESA = '" + SZZ->ZZ_CODIGO + "' " + CRLF
	cQuery += "AND SF1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF

    */

	cQuery := "SELECT SUM(CONTA) AS TICKETS " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTA " + CRLF
	cQuery += "FROM " + RetSqlName("SF1") + " AS SF1 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE SF1.F1_FILIAL <> '**' " + CRLF
	cQuery += "AND SF1.F1_TICPESA = '" + SZZ->ZZ_CODIGO + "' " + CRLF
	cQuery += "AND SF1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTA " + CRLF
	cQuery += "FROM " + RetSqlName("SF1") +" AS SF1 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE SF1.F1_FILIAL <> '**' " + CRLF
	cQuery += "AND SF1.F1_TICPESA = '" + SZZ->ZZ_CODIGO + "' " + CRLF
	cQuery += "AND SF1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF
	
	TCQuery cQuery New Alias "VLDVINC"
	dbSelectArea("VLDVINC")
	dbGoTop()
	
	If !VLDVINC->( Eof() )
		If VLDVINC->TICKETS == 0
			ApMsgAlert("Ticket não vinculada a nenhuma nota fiscal, classificação não permitida!","Atenção")
			Return .F.
		EndIf
	Else
		ApMsgAlert("Ticket não vinculada a nenhuma nota fiscal, classificação não permitida!","Atenção")
		Return .F.
	EndIf
	
	VLDVINC->( dbCloseArea() )
EndIf

aAdd( aPboxPerg ,{2,"Motivo","1", {"1=Sem Pedido", "2=Sem Laudo", "3=Alteração Preço", "4=Alteração Quantidade", "5=Alteração Dt Entrega"}, 120,'.T.',.T.}) 

If ParamBox(aPboxPerg ,"Classificar", aPBoxRet,,,,,,,,.F.,.F.)  
                    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Atualiza historico do ticket de pesagem referente a NF Entrada    	³
	//|** Classificacao do Ticket                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	U_ESTX003H(SZZ->ZZ_CODIGO, 2, aPboxPerg[1][4][Val(aPBoxRet[1])] )

EndIf

Return


/*/{Protheus.doc} ESTX003H
GRAVA HISTORICO DE OCORRENCIAS COM O TICKET DE PESAGEM 
@type function
@author geronimo.alves
@since 7/12/2023
@param cTicket, character, param_description
@param nID, numeric, param_description
@param cExtra, character, param_description
/*/
User Function ESTX003H( cTicket, nID, cExtra )
Local aArea := GetArea()                           
Local aHist := {}
Local cHist := ""
Local nX    := 0

Default cExtra := ""                                                                                                                                                         

dbSelectArea("SZZ")
dbSetOrder(1)
If MsSeek(xFilial("SZZ")+cTicket)
                   
	If Empty(SZZ->ZZ_HISTCOM)
		aHist := Array(5)   
	Else
		aHist := StrTokArr(SZZ->ZZ_HISTCOM, "#")
	EndIf
	
	aHist[nID] := Padr( "[" + StrZero(nID,2) + "]" + Space(3) + Transform(dDatabase, "@E") + "-" + Time() + IIf(Empty(cExtra), "", Space(3) + Upper(RTrim(cExtra))), 50 )
	    
	For nX := 1 To Len( aHist )
		cHist += IIf( Empty(aHist[nX]), Space(50), aHist[nX] ) + "#"
	Next nX
	
	RecLock("SZZ", .F.)
		SZZ->ZZ_HISTCOM := cHist
	SZZ->( MsUnLock() )
	
EndIf

RestArea(aArea)

Return         


/*/{Protheus.doc} ESTX003SF1
GRAVA TICKET DE PESAGEM NO DOCUMENTO DE ENTRADA ( SF1 ) 
@type function
@author Tiago O. Beraldi 
@since 27/08/12 
/*/
User Function ESTX003SF1()
    
Local aPBoxPerg := {}
Local aPBoxRet  := {}   
Local bPBoxOK   := {||IIf(!Empty(aPBoxRet[1]), ExistCpo("SZZ", aPBoxRet[1], 1), .T.)}  
Local cCodTic   := "      "

// FS - Não permitir se NF bloqueada..
If AllTrim( SF1->F1_STATUS ) == "B"
	ApMsgAlert("Nota fiscal bloqueada, aguarde aprovação para geração do Ticket de Recebimento!", "Atenção")
	Return
ElseIf Empty( SF1->F1_STATUS )
	ApMsgAlert("Nota fiscal não Classificada, aguarde a classificação da Nota Fiscal para geração do Ticket de Recebimento!", "Atenção")
	Return
EndIf

If SF1->F1_ESPECIE == SuperGetMv("EQ_ESPSRV",.F.,"NFSE")  // Nao pedir tiquete de pesagem pra NFSE
	Return
End	

If !Empty( SF1->F1_TICPESA )
	If !ApMsgYesNo("Ticket de pesagem já relacionado para esta NF, deseja alterar?", "Atenção")
		Return
	Else
		cCodTic := SF1->F1_TICPESA
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Define campos utilizados na funcao ParamBox                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aPBoxPerg,{1,"Ticket de Pesagem",cCodTic,"@!","","SZZ","",120,.F.})       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Executa ParamBox                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ParamBox(aPBoxPerg,"Parametros",@aPBoxRet,bPBoxOK,,,,,,,.F.,.F.)
   
	If .NOT. Empty(aPBoxRet[1]) 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|Grava ticket de pesagem utilizado para entrada do documento          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SF1")
		RecLock("SF1", .F.)
			SF1->F1_TICPESA := aPBoxRet[1]
		SF1->( MsUnlock() )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|Atualiza historico do ticket de pesagem referente a NF Entrada    	³
		//|** Recebimento de Documento Fiscal                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		U_ESTX003H(aPBoxRet[1], 3)

	EndIf
	
EndIf
      
Return


/*/{Protheus.doc} LePesoBKP
EFETUA LEITURA DO PESO 
@type function
@author Tiago O. Beraldi 
@since 04/05//10
@return Numerico, peso lido
/*/
Static Function LePesoBKP()
              
Local lSai    := .T.  
Local cText   := ""     
Local nVezes  := 0

Private nHdll := 0       

While lSai .And. nVezes <= 50

	nVezes++ 

	MSOpenPort(nHdll, "COM4:9600,N,8,2") 
	lCom := MsRead(nHdll,cText) 

	If !lCom
	
		MsgStop("Não foi possível ler informações! Faça a leitura do peso novamente.")   
		Return nPeso
	
	Else
 
    	cText  := ""
    	aText  := Array(3)
	
		Sleep(800)
		MsRead(nHdll, @cText) 
		MSClosePort(nHdll)

		nPos := At("C", cText) + 1
		aText[1] := Subs(cText, nPos     , 07)
		aText[2] := Subs(cText, nPos + 16, 07)
		aText[3] := Subs(cText, nPos + 32, 07)    
		
		If aText[1] == aText[2] .And. aText[1] == aText[3] .And. !Empty(aText[1]) .And. !(" " $ aText[1]) 
			lSai := .F. 
		EndIf          

	EndIf
		
EndDo   

Return ( Val(aText[1]) )

/*/{Protheus.doc} ESTX003E
Estorna cancelamento
@type function
@author Evandro Peixoto 
@since 21/05/19
/*/
User Function ESTX003E()

local cObs:= SZZ->ZZ_OBS

If U_PORTAUSR()		// Se o usu�rio do Protheus for do setor portaria, permite efetuar o estorno
	If MsgYesNo("Deseja estornar o ticket " + SZZ->ZZ_CODIGO + " ?")

		dbSelectArea("SZZ")
		RecLock("SZZ", .F.)

			SZZ->ZZ_OBS := MemoLine(cObs,, 1,,.F.)
			msginfo("O ticket" + SZZ->ZZ_CODIGO + " foi estornado com sucesso.")

		SZZ->( MsUnLock() )
	EndIf
Endif
	
 /*If MsgYesNo("Deseja estornar o cancelamento do ticket " + SZZ->ZZ_CODIGO + " ?")
	dbSelectArea("SZZ")
	RecLock("SZZ", .F.)
		SZZ->ZZ_OBS := REPLACE(SZZ->ZZ_OBS,'(TICKET CANCELADO POR','')
		msginfo("O ticket" + SZZ->ZZ_CODIGO + " foi estornado com sucesso.")
	SZZ->( MsUnLock() )
EndIf    */         
Return 

              
/*/{Protheus.doc} EqImpPes
Estorna cancelamento
@type function
@author Evandro Peixoto 
@since 21/05/19
/*/

Static Function EqImpPes()
Local lRet 	:= .T.
Local cPathDest   := GetTempPath() //REL_PATH
Local cRelName	:= "ImpPes_"+DTOS(dDataBase)+"_"+Replace(Time(),":","")+"_"+AllTrim(SZZ->ZZ_CODIGO) // Adionado data e hora para não travar se reimpressao e estiver aberto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Instancia os objetos de fonte   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFont07n := TFont():New( "Arial",, 07,,.T.)
oFont07  := TFont():New( "Arial",, 07,,.F.)
oFont08n := TFont():New( "Arial",, 08,,.T.)
oFont08  := TFont():New( "Arial",, 08,,.F.)
oFont09  := TFont():New( "Arial",, 09,,.F.)
oFont09n := TFont():New( "Arial",, 09,,.T.)
oFont10n := TFont():New( "Arial",, 10,,.T.)
oFont10  := TFont():New( "Courier New",, 10,,.F.)
oFont11  := TFont():New( "Courier New",, 11,,.F.)
oFont11n := TFont():New( "Courier New",, 11,,.T.)
oFont12c  := TFont():New( "Courier New",, 12,,.F.)
oFont12cn := TFont():New( "Courier New",, 12,,.T.)
oFont12n := TFont():New( "Arial",, 12,,.T.)
oFont12  := TFont():New( "Arial",, 12,,.F.)
oFont14n := TFont():New( "Arial",, 14,,.T.)
oFont14  := TFont():New( "Arial",, 14,,.F.)
oFont14c  := TFont():New( "Courier New",, 12,,.F.)
oFont14cn := TFont():New( "Courier New",, 12,,.T.)
oFont16c  := TFont():New( "Courier New",, 12,,.F.)
oFont16cn := TFont():New( "Courier New",, 12,,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Instancia a Classe FwMsPrinter  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrn := FwMsPrinter():New(cRelName,IMP_PDF,.F.,cPathDest,.T.,.F.,@oPrn,,,.F.,.F.,.T.,)
oPrn:SetResolution(72)
oPrn:SetPortrait()
oPrn:SetPaperSize(DMPAPER_A4)

//oPrn:cPathPDF := cPathDest 			//Caso seja utilizada impressão em IMP_PDF      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Instancia a Classe FWPrintSetup ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSetup := FWPrintSetup():New(PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION+PD_DISABLEDESTINATION+PD_DISABLEPAPERSIZE+PD_DISABLEPREVIEW ,"PESAGEM")
oSetup:SetProperty(PD_MARGIN,{05,05,05,05})
oSetup:SetProperty(PD_DESTINATION,2) 
oSetup:SetProperty(PD_PRINTTYPE,IMP_PDF)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ativa Tela de Setup		  	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oSetup:Activate() == 2
	Alert("Erro ao ativar impressão")
	lRet	:= .F.
EndIf                              


RunPrint() 

Return


/*/{Protheus.doc} RunPrint
description
@type function
@author Rodrigo Sousa
@since 02/10/2011
/*/
Static Function RunPrint()

Local nPixLin	:= NMINLIN
Local nPixCol	:= NMINCOL                  
Local nPeso := IIf(!Empty(SZZ->ZZ_CARGA), SZZ->ZZ_PESOCG, (SZZ->ZZ_PESDOC1 + SZZ->ZZ_PESDOC2 + SZZ->ZZ_PESDOC3 + SZZ->ZZ_PESDOC4))
lOCAL nX		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa a pagina    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrn:StartPage()	

For nX := 1 To 2

	nPixLin += 30 
	oPrn:Box(nPixLin,nPixCol,nPixLin+280,NMAXCOL)
	oPrn:SayBitmap(nPixLin+=15,nPixCol+10,"logoeuro.bmp",70,35)	
	oPrn:Say(nPixLin+=15,nPixCol+90,"EUROAMERICAN DO BRASIL IMP. IND. E COM. LTDA.",oFont14cn)
	oPrn:Say(nPixLin+=10,nPixCol+90,"AV. ANTONIO BARDELA, 789 - JD. SÃO LUIZ - JANDIRA - SP - CEP 06618-000",oFont12c,,)
	nPixLin += 20
	oPrn:Line(nPixLin,nPixCol,nPixLin,NMAXCOL)
	nPixLin += 10
	oPrn:Say(nPixLin+4,nPixCol+20,"TICKET: " + SZZ->ZZ_CODIGO + " EMISSAO: " + DtoC(dDataBase) + " " + Subs(Time(), 1, 5),oFont14cn,,)
	nPixLin+=10
	oPrn:Line(nPixLin,nPixCol,nPixLin,NMAXCOL)
	nPixLin+=10
	oPrn:Say(nPixLin+=20,nPixCol+20,"PLACA...............: " +  SZZ->ZZ_PLACA ,oFont16cn,,)
	oPrn:Say(nPixLin+=20,nPixCol+20,"DOCUMENTO...........: " + (AllTrim(SZZ->ZZ_TPDOC1 + SZZ->ZZ_DOC1) + Iif(!Empty(SZZ->ZZ_TPDOC2),"-" + Alltrim(SZZ->ZZ_TPDOC2 + SZZ->ZZ_DOC2),"") + Iif(!Empty(SZZ->ZZ_TPDOC3),"-" + Alltrim(SZZ->ZZ_TPDOC3 + SZZ->ZZ_DOC3),"") + Iif(!Empty(SZZ->ZZ_TPDOC4),"-" + Alltrim(SZZ->ZZ_TPDOC4 + SZZ->ZZ_DOC4),"") ),oFont16cn,,)
	oPrn:Say(nPixLin+=20,nPixCol+20,"PRIMEIRA PESAGEM....: " + Transform(SZZ->ZZ_PESO1, "@E 999,999,999") + " KG " + "DATA: " + DtoC(SZZ->ZZ_DTPES1) + " " + SZZ->ZZ_HRPES1 ,oFont16cn,,)
	oPrn:Say(nPixLin+=20,nPixCol+20,"SEGUNDA PESAGEM.....: " + Transform(SZZ->ZZ_PESO2, "@E 999,999,999") + " KG " + "DATA: " + DtoC(SZZ->ZZ_DTPES2) + " " + SZZ->ZZ_HRPES2 ,oFont16cn,,)
	oPrn:Say(nPixLin+=20,nPixCol+20,"LIQUIDO.............: " + Transform(Abs(SZZ->ZZ_PESO1 - SZZ->ZZ_PESO2), "@E 999,999,999")  + " KG " ,oFont16cn,,)
	oPrn:Say(nPixLin+=20,nPixCol+20,"PESO DA NOTA........: " + Transform(nPeso, "@E 999,999,999") + " KG " ,oFont16cn,,)
	oPrn:Say(nPixLin+=20,nPixCol+20,"DIFERENCA...........: " + Transform(Abs(SZZ->ZZ_PESO1 - SZZ->ZZ_PESO2) - nPeso, "@E 999,999,999") + "  " +  Transform(100 * ((Abs(SZZ->ZZ_PESO1 - SZZ->ZZ_PESO2) - nPeso)/nPeso), "@E 999.99") + " %" ,oFont16cn,,)

	If nX == 1
		nPixLin := 415 
		oPrn:Say(nPixLin,nPixCol,Replicate(" - ", 33),oFont14c,,)
		nPixLin += 30
	EndIf
	
Next nX

If ValType(oPrn) == "O"
  	oPrn:Print()
Else
	MsgInfo('O Objeto de impressão não foi inicializado com exito')
EndIf

oPrn:EndPage()

Return

/*/{Protheus.doc} LIBPESO
//TODO Envia e-mail para o usuário no parametro
@author  Fabio Batista
@since 16/10/2020
@type function
*/

Static Function LIBPESO()

Local _cHtml   := ''
Local cEmail   := GETMV("MV_XMAILPS",.T.,'aurelito.ribeiro@euroamerican.com.br')
Local cBody    := ''
Local cAssunto := 'Alteração Peso' 
Local cAttach  := ''

_cHtml := '<html>' + CRLF
_cHtml += '	<head>' + CRLF
_cHtml += '		<meta http-equiv="content-type" content="text/html;charset=utf-8">' + CRLF
_cHtml += '		<style>' + CRLF
_cHtml += '			table 	{' + CRLF
_cHtml += '					border-collapse: collapse;' + CRLF
_cHtml += '					border: 1px solid black;' + CRLF
_cHtml += '					}' + CRLF
_cHtml += '		</style>' + CRLF
_cHtml += '	</head>' + CRLF
_cHtml += '	<body>' + CRLF
_cHtml += '		<table border="0" width="100%" align="center">' + CRLF
_cHtml += '			<tr rowspan="2">' + CRLF
_cHtml += '				<td width="100%" style=mso-number-format:"\@" align="center" VALIGN="MIDDLE" bgcolor="#ffffff">      ' + CRLF
_cHtml += '					<br>' + CRLF
_cHtml += '					<font face="Courier New" size="5" VALIGN="MIDDLE" color=black><strong><B>Alteração Peso</B></strong></font>   ' + CRLF
_cHtml += '				</td>' + CRLF
_cHtml += '			</tr>' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td>' + CRLF
_cHtml += '					<font>' + CRLF
_cHtml += '						<br>' + CRLF
_cHtml += '					</font>' + CRLF
_cHtml += '				</td>' + CRLF
_cHtml += '			</tr>    ' + CRLF
_cHtml += '		</table><Br>' + CRLF
_cHtml += '		<table border="0" width="100%" align="center" >' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td colspan="7" width="100%"style=mso-number-format:"\@" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color="ffffff" ><B></b></Font>' + CRLF
_cHtml += '				</td>' + CRLF
_cHtml += '			</tr>' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Nro.Carga</b></font>    ' + CRLF
_cHtml += '				</td>    	' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Campo de alteração</b></font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Peso anterior</b></font>  ' + CRLF  
_cHtml += '				</td> ' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Peso Atual</b></font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Usuário</b></font>  ' + CRLF  
_cHtml += '				</td> 	' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Hora Alteração</b></font>    ' + CRLF
_cHtml += '				</td> ' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Data Alteração</b></font>    ' + CRLF
_cHtml += '				</td> ' + CRLF
_cHtml += '			</tr>' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+ SZZ->ZZ_CODIGO +'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

If lPeso	
	_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
	_cHtml += '					<font face="Courier New" size="3">Pesagem 1</font>    ' + CRLF
	_cHtml += '				</td>    ' + CRLF
	_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
	_cHtml += '					<font face="Courier New" size="3">'+cValtochar(_nPeso)+'</font>    ' + CRLF
	_cHtml += '				</td>    ' + CRLF
	_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
	_cHtml += '					<font face="Courier New" size="3">'+cValtochar(_nPesoAt)+'</font>    ' + CRLF
	_cHtml += '				</td>    ' + CRLF
EndIf

If lDoc1     
	_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
	_cHtml += '					<font face="Courier New" size="3">Peso Doc 1</font>    ' + CRLF
	_cHtml += '				</td>    ' + CRLF
	_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
	_cHtml += '					<font face="Courier New" size="3">'+cValtochar(_nDoc1)+'</font>    ' + CRLF
	_cHtml += '				</td>    ' + CRLF
	_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
	_cHtml += '					<font face="Courier New" size="3">'+cValtochar(_nDoc2)+'</font>    ' + CRLF
	_cHtml += '				</td>    ' + CRLF
EndIf
  
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">' + Upper(AllTrim(cUserName)) + '</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">' + Time() + '</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+ DTOC(DDATABASE) +'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '			</tr>' + CRLF
_cHtml += '		</table>' + CRLF
_cHtml += '		<Hr>' + CRLF
_cHtml += '		<font face="Arial" size="1"><I>Powered by TI Euroamerican</I></font>  <font face="Arial" size="1" color="#FFFFFF">%cCodUsr% %cIDWF% %cFuncao%</font><br>' + CRLF
_cHtml += '		<font face="Arial" size="3"><B>Euroamerican do Brasil Imp Ind e Com LTDA</B></font><br/>' + CRLF
_cHtml += '	</body>' + CRLF
_cHtml += '</html>' + CRLF

cBody := _cHtml

	If Empty(cEmail )
		cEmail   := 'aurelito.ribeiro@euroamerican.com.br'
	EndIf
	
	u_FSENVMAIL(cAssunto, cBody, cEmail,cAttach,,,,,,,,,)
 
Return

/*/{Protheus.doc} XLIBPESO
//TODO Envia e-mail para o usuário no parametro
@author  Fabio Batista
@since 16/10/2020
@type function
/*/
Static Function XLIBPESO()
Local _cHtml   := ''
Local cEmail   := GETMV("MV_XMAILPS",.T.,'aurelito.ribeiro@euroamerican.com.br')
Local cBody    := ''
Local cAssunto := 'Alteração peso' 
Local cAttach  := ''

_cHtml := '<html>' + CRLF
_cHtml += '	<head>' + CRLF
_cHtml += '		<meta http-equiv="content-type" content="text/html;charset=utf-8">' + CRLF
_cHtml += '		<style>' + CRLF
_cHtml += '			table 	{' + CRLF
_cHtml += '					border-collapse: collapse;' + CRLF
_cHtml += '					border: 1px solid black;' + CRLF
_cHtml += '					}' + CRLF
_cHtml += '		</style>' + CRLF
_cHtml += '	</head>' + CRLF
_cHtml += '	<body>' + CRLF
_cHtml += '		<table border="0" width="100%" align="center">' + CRLF
_cHtml += '			<tr rowspan="2">' + CRLF
_cHtml += '				<td width="100%" style=mso-number-format:"\@" align="center" VALIGN="MIDDLE" bgcolor="#ffffff">      ' + CRLF
_cHtml += '					<br>' + CRLF
_cHtml += '					<font face="Courier New" size="5" VALIGN="MIDDLE" color=black><strong><B>Alteração Peso</B></strong></font>   ' + CRLF
_cHtml += '				</td>' + CRLF
_cHtml += '			</tr>' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td>' + CRLF
_cHtml += '					<font>' + CRLF
_cHtml += '						<br>' + CRLF
_cHtml += '					</font>' + CRLF
_cHtml += '				</td>' + CRLF
_cHtml += '			</tr>    ' + CRLF
_cHtml += '		</table><Br>' + CRLF
_cHtml += '		<table border="0" width="100%" align="center" >' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td colspan="9" width="100%"style=mso-number-format:"\@" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color="ffffff" ><B></b></Font>' + CRLF
_cHtml += '				</td>' + CRLF
_cHtml += '			</tr>' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Nro.Carga</b></font>    ' + CRLF
_cHtml += '				</td>    	' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Campo de alteração</b></font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF


_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Ant Pesagem 1</b></font>  ' + CRLF  
_cHtml += '				</td> ' + CRLF

_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Atu Pesagem 1</b></font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Ant Peso Doc 1</b></font>  ' + CRLF  
_cHtml += '				</td> 	' + CRLF

_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Atu Peso Doc 1</b></font>    ' + CRLF
_cHtml += '				</td> ' + CRLF

_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Usuário</b></font>    ' + CRLF
_cHtml += '				</td> ' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Hora Alteração</b></font>    ' + CRLF
_cHtml += '				</td> ' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Data Alteração</b></font>    ' + CRLF
_cHtml += '				</td> ' + CRLF

_cHtml += '			</tr>' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+ SZZ->ZZ_CODIGO +'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">ZZ_PESO2|ZZ_PESDOC1</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
//---------------------------------------------- Pesagem 1 -----------------------------------------------
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+cValtochar(_nPeso)+'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+cValtochar(_nPesoAt)+'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
//------------------------------------------------ Peso Doc 1 --------------------------------------------
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+cValtochar(_nDoc1)+'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+cValtochar(_nDoc2)+'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
//-------------------------------------------------------------------------------------------------------
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">' + Upper(AllTrim(cUserName)) + '</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">' + Time() + '</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+ DTOC(DDATABASE) +'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '			</tr>' + CRLF
_cHtml += '		</table>' + CRLF
_cHtml += '		<Hr>' + CRLF
_cHtml += '		<font face="Arial" size="1"><I>Powered by TI Euroamerican</I></font>  <font face="Arial" size="1" color="#FFFFFF">%cCodUsr% %cIDWF% %cFuncao%</font><br>' + CRLF
_cHtml += '		<font face="Arial" size="3"><B>Euroamerican do Brasil Imp Ind e Com LTDA</B></font><br/>' + CRLF
_cHtml += '	</body>' + CRLF
_cHtml += '</html>' + CRLF

cBody := _cHtml

	If Empty(cEmail )
		cEmail   := 'aurelito.ribeiro@euroamerican.com.br'
	EndIf

	u_FSENVMAIL(cAssunto, cBody, cEmail,cAttach,,,,,,,,,)
 
Return


/*/{Protheus.doc} FIMALT
//TODO VALIDA SE O PESO FOI ALTERADO
@author  Fabio Batista
@since 19/10/2020
@type function
*/
Static Function FimAlt()

Local aCpos       := {"ZZ_PESDOC1", "ZZ_PESDOC2", "ZZ_PESDOC3", "ZZ_PESDOC4", "ZZ_CARGA"}
Local _cUsuario  := Alltrim(cUserName)

Private lPeso       := .F.
Private lDoc1       := .F.

Private _nPeso   := 0
Private _nPesoAt := 0
Private _nDoc1   := 0
Private _nDoc2   := 0
Private _cCarga  := ''
Private _cCarga1 := ''
Private lCarga   := .F. 

	If _cUsuario $ _cPORTASUP	//O usu�rio Supervisor da portaria pode alterar alem dos campos ZZ_PESDOC1, ZZ_PESDOC2, ZZ_PESDOC3, ZZ_PESDOC4 e ZZ_CARGA tamb�m os campos ZZ_PESO2, ZZ_OBS, ZZ_MATER, ZZ_DTPES1, ZZ_DTPES2, ZZ_PLACA, ZZ_PLCCAV.
		aCpos       := {"ZZ_PESDOC1", "ZZ_PESDOC2", "ZZ_PESDOC3", "ZZ_PESDOC4", "ZZ_CARGA", "ZZ_PESO2", "ZZ_OBS", "ZZ_MATER", "ZZ_DTPES1" , "ZZ_DTPES2", "ZZ_PLACA" , "ZZ_PLCCAV" }
	Endif

    _cCarga := SZZ->ZZ_CARGA
	_nDoc1 := SZZ->ZZ_PESDOC1
	_nPeso := SZZ->ZZ_PESO2
	AxAltera("SZZ", Recno(), 4,,aCpos,,,,,, aButtons)
	_nPesoAt := SZZ->ZZ_PESO2
	_nDoc2   := SZZ->ZZ_PESDOC1
	_cCarga1 := SZZ->ZZ_CARGA 
	
	If !_nPesoAt == _nPeso .and. !_nDoc1 == _nDoc2
		XLIBPESO()
		Return
	EndIf 

	If !_nPesoAt == _nPeso
		lPeso := .T.
		LIBPESO()
		Return
	EndIf

	If !_nDoc1 == _nDoc2
		lDoc1  := .T.
		LIBPESO()
	EndIf 

// libera o campo do N� Carga
	If !_cCarga == _cCarga1
		XNUMCARG()
		lCarga := .T.
		Return
	EndIf 
Return


/*/{Protheus.doc} XNUMCARG
Envia e-mail para o usu�rio indicado no parametro MV_XMAILPS
@author  Fabio Batista
@since 16/10/2020
@type function
*/
Static Function XNUMCARG()

Local _cHtml   := ''
Local cEmail   := GETMV("MV_XMAILPS",.T.,'aurelito.ribeiro@euroamerican.com.br')
Local cBody    := ''
Local cAssunto := 'Altera��o N� Carga' 
Local cAttach  := ''

_cHtml := '<html>' + CRLF
_cHtml += '	<head>' + CRLF
_cHtml += '		<meta http-equiv="content-type" content="text/html;charset=utf-8">' + CRLF
_cHtml += '		<style>' + CRLF
_cHtml += '			table 	{' + CRLF
_cHtml += '					border-collapse: collapse;' + CRLF
_cHtml += '					border: 1px solid black;' + CRLF
_cHtml += '					}' + CRLF
_cHtml += '		</style>' + CRLF
_cHtml += '	</head>' + CRLF
_cHtml += '	<body>' + CRLF
_cHtml += '		<table border="0" width="100%" align="center">' + CRLF
_cHtml += '			<tr rowspan="2">' + CRLF
_cHtml += '				<td width="100%" style=mso-number-format:"\@" align="center" VALIGN="MIDDLE" bgcolor="#ffffff">      ' + CRLF
_cHtml += '					<br>' + CRLF
_cHtml += '					<font face="Courier New" size="5" VALIGN="MIDDLE" color=black><strong><B>Altera��o carga</B></strong></font>   ' + CRLF
_cHtml += '				</td>' + CRLF
_cHtml += '			</tr>' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td>' + CRLF
_cHtml += '					<font>' + CRLF
_cHtml += '						<br>' + CRLF
_cHtml += '					</font>' + CRLF
_cHtml += '				</td>' + CRLF
_cHtml += '			</tr>    ' + CRLF
_cHtml += '		</table><Br>' + CRLF
_cHtml += '		<table border="0" width="100%" align="center" >' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td colspan="7" width="100%"style=mso-number-format:"\@" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color="ffffff" ><B></b></Font>' + CRLF
_cHtml += '				</td>' + CRLF
_cHtml += '			</tr>' + CRLF
_cHtml += '			<tr>    ' + CRLF

// ----------------------- campos cabec ---------------------------------------
//----------------------------------------- 1 numero carga
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Nro.Pesagem</b></font>    ' + CRLF
_cHtml += '				</td>    	' + CRLF

//---------------------------------------- 2 campo alteracao
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Campo de altera��o</b></font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

//----------------------------------------- 3 ant carga
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Ant Carga</b></font>  ' + CRLF  
_cHtml += '				</td> ' + CRLF

//----------------------------------------- 4 atu carga
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Atu Carga</b></font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

//---------------------------------------- 5 usuario
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Usu�rio</b></font>    ' + CRLF
_cHtml += '				</td> ' + CRLF

//--------------------------------------- 6 h. alteracao
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Hora Altera��o</b></font>    ' + CRLF
_cHtml += '				</td> ' + CRLF

//--------------------------------------- 7 dt alteracao
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Data Altera��o</b></font>    ' + CRLF
_cHtml += '				</td> ' + CRLF
_cHtml += '			</tr>' + CRLF


//------------------------ campos itens 
//-------------------------------------- 1 numero carga
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+ SZZ->ZZ_CODIGO +'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

//-------------------------------------- 2 campo alterado
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">Carga</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

//-------------------------------------- 3 ant carga
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">' + _cCarga + '</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

//--------------------------------------- 4 atu carga
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">' + _cCarga1 + '</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

//-------------------------------------- 5 usuario
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+ Upper(AllTrim(cUserName)) +'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

//-------------------------------------- 6 h. alteracao
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+ Time() +'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

//------------------------------------- 7 dt alteracao
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+ DTOC(DDATABASE) +'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
//------------------------------------- fim 

_cHtml += '			</tr>' + CRLF
_cHtml += '		</table>' + CRLF
_cHtml += '		<Hr>' + CRLF
_cHtml += '		<font face="Arial" size="1"><I>Powered by TI Euroamerican</I></font>  <font face="Arial" size="1" color="#FFFFFF">%cCodUsr% %cIDWF% %cFuncao%</font><br>' + CRLF
_cHtml += '		<font face="Arial" size="3"><B>Euroamerican do Brasil Imp Ind e Com LTDA</B></font><br/>' + CRLF
_cHtml += '	</body>' + CRLF
_cHtml += '</html>' + CRLF

cBody := _cHtml

	If Empty(cEmail )
		//cEmail   := 'aurelito.ribeiro@euroamerican.com.br;portaria@euroamerican.com.br'
		cEmail   := 'fabio.batista@euroamerican.com.br'
	EndIf
    
	cEmail := 'fabio.batista@euroamerican.com.br;portaria@euroamerican.com.br'
	u_FSENVMAIL(cAssunto, cBody, cEmail,cAttach,,,,,,,,,)
 
Return


/*/{Protheus.doc} PORTAUSR
Verifica se o usu�rio atual � usuario da portaria. Somente os usuarios da portaria ter�o alguns acessos que s�o: Imprimir, estornar ou cancelar registro na tabela de controle de pesagem
@type function
@author geronimo.alves
@since 7/12/2023
@return logical, Se retornar verddeiro permite a opera��o (imprimir, imprimir, estornar ou cancelar registro na tabela de controle de pesagem). Se retornar .F. n�o permite 
/*/
User Function PORTAUSR()
Local _lRet      := .T.
Local _cUsuario  := Alltrim(cUserName)
Local _cPORTAUSR := GETMV("MV_XPORTUS",, ",vanessa.nemeth,valter.lima,willes.souza,Carlos.Alves,antonio.cabral,Administrador," )
If  !( _cUsuario $ _cPORTAUSR )
    Help( ,, "PORTAUSR",, OemToAnsi("O seu usu�rio Protheus n�o � do setor da portaria. Por isto n�o tem acesso para imprimir, estornar ou cancelar registro na tabela de controle de pesagem. Os usu�rios com este acesso s�o os cadastrados no par�metro MV_XPORTUS : ") + ENTER + subs(_cPORTAUSR,1,47) + ENTER +subs(_cPORTAUSR,48,47)  , 1, 0 )
    _lRet := .F.
EndIf
Return _lRet


/*/{Protheus.doc} PORTASUP
Verifica se o usu�rio atual � Supervisor da portaria. Somente o Supervisor da portaria ter� alguns acessos que s�o: Excluir registro na tabela de controle de pesagem. Alterar o campo ZZ_PESO2
@type function
@version  1.00
@author geronimo.alves
@since 7/12/2023
@return logical, Se retornar .T. permite a opera��o (Excluir registro na tabela de controle de pesagem E/OU Alterar o campo ZZ_PESO2). Se retornar .F. n�o permite
/*/
User Function PORTASUP()
Local _lRet      := .T.
Local _cUsuario  := Alltrim(cUserName)
Local _cPORTASUP := GETMV("MV_XPORTSP",, ",antonio.cabral,Administrador," )
If  !( _cUsuario $ _cPORTASUP )
    Help( ,, "PORTASUP",, OemToAnsi("O seu usu�rio Protheus n�o � Supervisor da portaria. N�o pode portanto alterar o campo Pesagem 2 (ZZ_PESO2) e/ou excluir registro na tabela de controle de pesagem. Os usu�rios com este acesso s�o os cadastrados no par�metro PORTARISUP : ") + ENTER + subs(_cPORTASUP,1,47) + ENTER +subs(_cPORTASUP,48,47)  , 1, 0 )
    _lRet := .F.
EndIf
Return _lRet

