#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"  

#define ENTER chr(13) + chr(10)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINR007   บAutor  ณAlexandre Marson    บ Data ณ 19/04/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณRELATORIO DE MAIORES DEVEDORES                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑฬอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ  
ฑฑบ          บ                  บ                                         บฑฑ
ฑฑบ          บ                  บ                                         บฑฑ
ฑฑบ          บ                  บ                                         บฑฑ
ฑฑบ          บ                  บ                                         บฑฑ
ฑฑบ          บ                  บ                                         บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function FINR007()
Local cPerg := "FINR007"

//+----------------------------------------------------------------------------
//| Dicionario de Perguntas
//+----------------------------------------------------------------------------
fCriaSX1(cPerg)    

//+----------------------------------------------------------------------------
//| Processamento
//+----------------------------------------------------------------------------
If Pergunte(cPerg, .T.)           
	Processa({|| fFINR007() }, "Processando...")
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfFINR007  บAutor  ณAlexandre Marson      บ Data ณ  19/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria dicionario de perguntas                                 บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fFINR007()          

Local cQry 		:= ""        
Local aYear		:= {}
Local nRec		:= 0     
Local cArq		:= ""
Local nHdl		:= 0      
Local cLinha	:= ""    

Local nCntCol	:= 0    
Local nCntRow	:= 0
Local cNumRow	:= 0   

//+----------------------------------------------------------------------------
//| Query - Retorna os anos com algum titulo em aberto
//+----------------------------------------------------------------------------
cQry :=	"SELECT	" 											+ ENTER
cQry +=	"		CONVERT(VARCHAR, YEAR(E1_VENCREA)) YEAR "	+ ENTER
cQry +=	"FROM " 											+ ENTER
cQry +=			RetSqlName("SE1") + " SE1 " 				+ ENTER
cQry +=	"WHERE " 											+ ENTER
cQry +=	"		SE1.D_E_L_E_T_ = '' " 						+ ENTER
cQry +=	"		AND E1_FILIAL = '" + xFilial("SE1") + "' " 	+ ENTER
cQry +=	"		AND E1_SALDO != 0 " 						+ ENTER
cQry +=	"		AND E1_TIPO != 'NCC' " 						+ ENTER
cQry +=	"		AND E1_SITUACA != 'P' " 					+ ENTER
cQry +=	"		AND E1_VENCREA BETWEEN " + IIF(MV_PAR01 == 1, " '"	+ "20060101"		+ "' AND '" + DtoS(dDataBase-30)	+ "' ",;
                                                               " '"	+ DtoS(MV_PAR02)	+ "' AND '" + DtoS(MV_PAR03) 		+ "' ") + ENTER
cQry +=	"GROUP BY " 										+ ENTER
cQry +=	"		YEAR(E1_VENCREA) " 							+ ENTER
cQry +=	"HAVING " 											+ ENTER
cQry +=	"		SUM(E1_SALDO) > 0 " 						+ ENTER //Alterado 21/02/2017 E1_VALOR
cQry +=	"ORDER BY " 										+ ENTER
cQry +=	"		YEAR(E1_VENCREA) " 							+ ENTER

If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS QRY 

dbEval( {|| aAdd(aYear, AllTrim(QRY->YEAR)) },,{|| QRY->(!EoF())} )

QRY->(dbCloseArea())
    
    
//+----------------------------------------------------------------------------
//| Query - Registros a serem exibidos no Excel
//+----------------------------------------------------------------------------
cQry :=	"SELECT	" + ENTER
cQry +=	"		CLIENTE, " + ENTER
cQry +=	"		VENDEDOR, " + ENTER
//cQry +=	"		SITUACAO, " + ENTER      //Alterado 21/02/2017
				aEval( aYear, {|x| cQry += "		SUM([" + x + "]) [" + x + "], " + ENTER })    
//
cQry +=	"		SUM("
				aEval( aYear, {|x| cQry += "[" + x + "]" + IIf(x # aYear[Len(aYear)], "+", "") })
cQry +=	") VALOR" + ENTER
//
cQry +=	"FROM	( " + ENTER
cQry +=	"			SELECT " + ENTER
cQry +=	"					A1_COD  + ' - ' + A1_NOME CLIENTE, " + ENTER
							aEval( aYear, {|x| cQry += "					CASE WHEN YEAR(E1_VENCREA) = " + x + " THEN E1_SALDO ELSE 0 END [" + x + "], " + ENTER })  //Alterado 21/02/2017 E1_VALOR
//cQry +=	"					(SELECT RTRIM(X5_CHAVE) + '-' + X5_DESCRI FROM " + RetSqlName("SX5") + " WHERE D_E_L_E_T_ = '' AND X5_TABELA = '07' AND X5_CHAVE = E1_SITUACA) SITUACAO " + ENTER

cQry +=	"					(SELECT A3_COD + '-' + A3_NOME FROM " + RetSqlName("SA3") + " WHERE D_E_L_E_T_ = '' AND A3_COD = A1_VEND) VENDEDOR " + ENTER
cQry +=	"			FROM   " + ENTER
cQry +=	"				   " + RetSqlName("SE1") + " SE1, " + RetSqlName("SA1") + " SA1 " + ENTER
cQry +=	"			WHERE  " + ENTER
cQry +=	"					SE1.D_E_L_E_T_ = '' " + ENTER
cQry +=	"					AND SA1.D_E_L_E_T_ = '' " + ENTER
cQry +=	"				   	AND A1_FILIAL = E1_FILIAL " + ENTER
cQry +=	"				   	AND A1_COD = E1_CLIENTE " + ENTER
cQry +=	"				   	AND A1_LOJA = E1_LOJA " + ENTER
cQry +=	"				   	AND E1_FILIAL = '" + xFilial("SE1") + "' " + ENTER
cQry +=	"				   	AND E1_SALDO != 0 " + ENTER    
cQry +=	"				   	AND E1_TIPO != 'NCC' " + ENTER    
cQry +=	"				   	AND E1_SITUACA != 'P' " + ENTER   
//Filtra somente jurํdico
If	MV_PAR04 == 1
	cQry +=	"		AND E1_SITUACA IN ('6') " 					+ ENTER
Else
	cQry +=	"		AND E1_SITUACA NOT IN ('6') " 					+ ENTER
EndIf
cQry +=	"				   	AND E1_VENCREA BETWEEN " + IIF(MV_PAR01 == 1, " '"	+ "20060101"		+ "' AND '" + DtoS(dDataBase-30)	+ "' ",;
                           				                                  " '"	+ DtoS(MV_PAR02)	+ "' AND '" + DtoS(MV_PAR03) 		+ "' ") + ENTER
cQry +=	"		) QRY" + ENTER
cQry +=	"GROUP BY " + ENTER
cQry +=	"		   CLIENTE, VENDEDOR " + ENTER //, SITUACAO
cQry +=	"ORDER BY " + ENTER
cQry +=	"	       VALOR DESC " + ENTER
                 
If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS QRY 

//+----------------------------------------------------------------------------
//| Encerra o programa caso nao exista resultado na query
//+----------------------------------------------------------------------------
Count to nRec

If nRec == 0
	MsgAlert("Sem dados para gera็ใo da planilha!" , "Aten็ใo!")
	Return
EndIf                                                               

//+----------------------------------------------------------------------------
//| VBS - Cria script para geracao da planilha Excel	
//+----------------------------------------------------------------------------

CPASTALD() //Valida็ใo se a pasta existe fabio batista 11/10/2021

cArq     := "C:\Protheus\FINR007.VBS"
nHdl 	 := FCreate(cArq)

If nHdl == -1
	MsgAlert("Falha na cria็ใo do arquivo (VBS)!" , "Aten็ใo!")
	Return
Endif                 

//+----------------------------------------------------------------------------
//| VBS - Objeto Excel
//+----------------------------------------------------------------------------
cLinha := 'Set objExcel = CreateObject("Excel.Application")' + ENTER
cLinha += 'objExcel.Visible = True' + ENTER 
cLinha += 'objExcel.Workbooks.Add' + ENTER  

//+----------------------------------------------------------------------------
//| VBS - Largura das colunas
//+----------------------------------------------------------------------------
cLinha += 'objExcel.Columns("A").ColumnWidth = 95' + ENTER
cLinha += 'objExcel.Columns("B").ColumnWidth = 60' + ENTER
cLinha += 'objExcel.Columns("C").ColumnWidth = 30' + ENTER

nCntCol	:= Asc("D")
aEval( aYear, {|x|	cLinha += 'objExcel.Columns("' + CHR(nCntCol) + '").ColumnWidth = 20' + ENTER,;
					nCntCol++})
                    
cLinha += 'objExcel.Columns("' + CHR(nCntCol) + '").ColumnWidth = 30' + ENTER                    
                                                    
//+----------------------------------------------------------------------------
//| VBS - Formato das colunas numericas
//+----------------------------------------------------------------------------
nCntCol	:= Asc("D")
aEval( aYear, {|x|	cLinha += 'objExcel.Range("' + CHR(nCntCol) + '5:' + CHR(nCntCol) + '999999").NumberFormat = "#,##0"' + ENTER,;
					nCntCol++})

cLinha += 'objExcel.Range("' + CHR(nCntCol) + '5:' + CHR(nCntCol) + '999999").NumberFormat = "#,##0"' + ENTER

//+----------------------------------------------------------------------------
//| VBS - Titulo 1
//+----------------------------------------------------------------------------
cLinha += 'objExcel.Cells(1,1).Font.Name = "Courier New"' + ENTER
cLinha += 'objExcel.Cells(1,1).Font.Bold = True' + ENTER
cLinha += 'objExcel.Cells(1,1).Font.Size = 16' + ENTER
cLinha += 'objExcel.Cells(1,1).Font.ColorIndex = 1' + ENTER
cLinha += 'objExcel.Cells(1,1).Value = "Maiores Devedores"' + ENTER

//+----------------------------------------------------------------------------
//| VBS - Titulo 2
//+----------------------------------------------------------------------------
cLinha += 'objExcel.Cells(2,1).Font.Name = "Courier New"' + ENTER
cLinha += 'objExcel.Cells(2,1).Font.Bold = True' + ENTER
cLinha += 'objExcel.Cells(2,1).Font.Size = 12' + ENTER
cLinha += 'objExcel.Cells(2,1).Font.ColorIndex = 1' + ENTER
cLinha += 'objExcel.Cells(2,1).Value = "(' + IIf(mv_par01==1, '01/01/2006 a ' + DtoC(dDataBase-30), DtoC(mv_par02) + ' a ' + DtoC(mv_par03)) + ')"' + ENTER     

//+----------------------------------------------------------------------------
//| VBS - Titulo Colunas
//+----------------------------------------------------------------------------
cLinha += 'objExcel.Cells(4,"A") = "CLIENTE"' + ENTER
cLinha += 'objExcel.Cells(4,"B") = "VENDEDOR"' + ENTER
//cLinha += 'objExcel.Cells(4,"C") = "SITUACAO"' + ENTER       
//
nCntCol	:= Asc("C")
aEval( aYear, {|x|	cLinha += 'objExcel.Cells(4,"' + CHR(nCntCol) + '") = "' + x + '"' + ENTER,;
					nCntCol++ })
//
cLinha += 'objExcel.Cells(4,"' + CHR(nCntCol) + '") = "VALOR"' + ENTER

//+----------------------------------------------------------------------------
//| VBS - Alinhamento Colunas | -4131 = LEFT | -4152 = RIGHT | -4108 = CENTER
//+----------------------------------------------------------------------------                                                                  
cLinha += 'objExcel.Columns("A").HorizontalAlignment = -4131 ' + ENTER	    
cLinha += 'objExcel.Columns("B").HorizontalAlignment = -4131 ' + ENTER
//cLinha += 'objExcel.Columns("C").HorizontalAlignment = -4131 ' + ENTER    
//
nCntCol	:= Asc("C")
aEval( aYear, {|x|	cLinha += 'objExcel.Columns("' +CHR(nCntCol) + '").HorizontalAlignment = -4152 ' + ENTER,;
					nCntCol++ })                                                                            

cLinha += 'objExcel.Columns("' +CHR(nCntCol) + '").HorizontalAlignment = -4152 ' + ENTER					

//+----------------------------------------------------------------------------
//| VBS - Congelando Painel
//+----------------------------------------------------------------------------                                                                  
cLinha += 'objExcel.Range("A4:' + CHR(nCntCol) + '4").Font.Name = "Courier New"' + ENTER      
cLinha += 'objExcel.Range("A4:' + CHR(nCntCol) + '4").Font.Bold = True' + ENTER      
cLinha += 'objExcel.Range("A4:' + CHR(nCntCol) + '4").Borders.LineStyle = 1' + ENTER  
cLinha += 'objExcel.Range("A4:' + CHR(nCntCol) + '4").Borders.Color = RGB(0, 0, 0)' + ENTER  
cLinha += 'objExcel.Range("A4:' + CHR(nCntCol) + '4").Borders.Weight = 1' + ENTER    
cLinha += 'objExcel.Range("A5:' + CHR(nCntCol) + '5").Select' + ENTER
cLinha += 'objExcel.ActiveWindow.FreezePanes = True' + ENTER

//+----------------------------------------------------------------------------
//| VBS - Efetiva gravacao no arquivo VBS
//+----------------------------------------------------------------------------
If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
	If !MsgAlert("Ocorreu um erro na grava็ใo do arquivo.","Aten็ใo!")
		Return
	EndIf
EndIf   	

//+----------------------------------------------------------------------------
//| VBS - Registros Query
//+----------------------------------------------------------------------------
nCntRow := 5
cNumRow	:= AllTrim(Str(nCntRow))

aColor  := {"RGB(221,217,195)", "RGB(255,255,255)"} 
nColor  := 1
                 
QRY->(dbSelectArea("QRY"))                                 
QRY->(dbGoTop())
While !QRY->(EOF())              
	
	If (nCntRow % 2) == 0
		 nColor := 1
	Else
		 nColor := 2
	EndIf
	
	
	
	cLinha	:= ""
                   
	nCntCol	:= Asc("D")
	aEval( aYear, {|x|	nCntCol++ })
	
	cLinha += 'objExcel.Range("A' + cNumRow + ':' + CHR(nCntCol) + cNumRow + '").Interior.Color = ' + aColor[nColor] + ' ' + ENTER  
	cLinha += 'objExcel.Range("A' + cNumRow + ':' + CHR(nCntCol) + cNumRow + '").Borders.LineStyle = 1' + ENTER    
	cLinha += 'objExcel.Range("A' + cNumRow + ':' + CHR(nCntCol) + cNumRow + '").Borders.Color = RGB(0, 0, 0)' + ENTER  
	cLinha += 'objExcel.Range("A' + cNumRow + ':' + CHR(nCntCol) + cNumRow + '").Borders.Weight = 1' + ENTER     
	cLinha += 'objExcel.Range("A' + cNumRow + ':' + CHR(nCntCol) + cNumRow + '").Font.Bold = False' + ENTER     
	cLinha += 'objExcel.DisplayAlerts = False' + ENTER	  
		    
	cLinha += 'objExcel.Cells(' + cNumRow + ', 1) = "' + AllTrim(QRY->CLIENTE) + '"' + ENTER
	cLinha += 'objExcel.Cells(' + cNumRow + ', 2) = "' + AllTrim(QRY->VENDEDOR) + '"' + ENTER
	//cLinha += 'objExcel.Cells(' + cNumRow + ', 3) = "' + AllTrim(QRY->SITUACAO) + '"' + ENTER

	nCntCol	:= 3
	cNumCol	:= AllTrim(Str(nCntCol))
	aEval( aYear, {|x|	cLinha += 'objExcel.Cells(' + cNumRow + ', ' + cNumCol + ') = "' + cValToChar(FieldGet(FieldPos(x))) + '"' + ENTER,;
						nCntCol++,;
						cNumCol := AllTrim(Str(nCntCol)) })
	

	cLinha += 'objExcel.Cells(' + cNumRow + ', ' + cNumCol + ').Interior.Color = RGB(203, 197, 161)' + ENTER  
	cLinha += 'objExcel.Cells(' + cNumRow + ', ' + cNumCol + ').Font.Bold = True' + ENTER
	cLinha += 'objExcel.Cells(' + cNumRow + ', ' + cNumCol + ') = "' + cValToChar(QRY->VALOR) + '"' +  ENTER
	
	nCntRow++         
	
	cNumRow	:= AllTrim(Str(nCntRow))
                  	
	QRY->(dbSkip())    
			
	//+----------------------------------------------------------------------------
	//| VBS - Efetiva gravacao no arquivo VBS
	//+----------------------------------------------------------------------------
	If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
		If !MsgAlert("Ocorreu um erro na grava็ใo do arquivo.","Aten็ใo!")
			Return
		EndIf
	EndIf   
	
	//+----------------------------------------------------------------------------
	//| VBS - Verifica se ้ final de arquivo e adiciona linha totalizadora
	//+----------------------------------------------------------------------------
	If QRY->(EoF())        
	                   
		cLinha	:= ""
	                   
		nCntCol	:= Asc("D")
		aEval( aYear, {|x|	nCntCol++ })
		
		cLinha += 'objExcel.Range("A' + cNumRow + ':' + CHR(nCntCol) + cNumRow + '").Interior.Color = RGB(203, 197, 161)' + ENTER  
		cLinha += 'objExcel.Range("A' + cNumRow + ':' + CHR(nCntCol) + cNumRow + '").Borders.LineStyle = 1' + ENTER    
		cLinha += 'objExcel.Range("A' + cNumRow + ':' + CHR(nCntCol) + cNumRow + '").Borders.Color = RGB(0, 0, 0)' + ENTER  
		cLinha += 'objExcel.Range("A' + cNumRow + ':' + CHR(nCntCol) + cNumRow + '").Borders.Weight = 1' + ENTER  
		cLinha += 'objExcel.Range("A' + cNumRow + ':' + CHR(nCntCol) + cNumRow + '").Font.Bold = True' + ENTER  
		cLinha += 'objExcel.DisplayAlerts = False' + ENTER	  	 
		
		nCntCol	:= 3
		cNumCol	:= AllTrim(Str(nCntCol))         
		nChrCol := Asc("C") 
		
		aEval( aYear, {|x|	cLinha += 'objExcel.Cells(' + cNumRow + ', ' + cNumCol + ') = "=SUM('+ CHR(nChrCol) + '1:' + CHR(nChrCol) + cValToChar(nCntRow-1) + ')"' + ENTER,;
							nCntCol++, nChrCol++,;
							cNumCol := AllTrim(Str(nCntCol)) })
		
	
		cLinha += 'objExcel.Cells(' + cNumRow + ', ' + cNumCol + ') = "=SUM(' + CHR(nChrCol) + '1:' + CHR(nChrCol) + cValToChar(nCntRow-1) + ')"' + ENTER
			
		
		If FWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
			If !MsgAlert("Ocorreu um erro na grava็ใo do arquivo.","Aten็ใo!")
				Return
			EndIf
		EndIf   
		

	EndIF
	
EndDo
                       
 
//+----------------------------------------------------------------------------
//| Abre Excel
//+----------------------------------------------------------------------------                                    
If nCntRow > 5
		
	//Fecha arquivo VBS
	fClose(nHdl)
	
	//Executa Script VBS
	ShellExecute( "OPEN", cArq, "", "", 1 )
	
	Sleep(3000)
   	
Else

	MsgAlert("Nenhum dado para exibir!")
   	
EndIf                

MS_FLUSH()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfCriaSX1  บAutor  ณAlexandre Marson      บ Data ณ  19/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria dicionario de perguntas                                 บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fCriaSX1(cPerg)

Local cKey := ""
Local aHelpEng := {}
Local aHelpPor := {}
Local aHelpSpa := {}

PutSX1(cPerg,"01","Considerar Vencimento  ?","","","mv_ch1","N",01,0,0,"C","","","","","mv_par01","Todos"	,"","","","Vencto De/Ate"	,"","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"02","Vencimento De          ?","","","mv_ch2","D",08,0,0,"G","","","","","mv_par02",""		,"","","",""				,"","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"03","Vencimento Ate         ?","","","mv_ch3","D",08,0,0,"G","","","","","mv_par03",""		,"","","",""				,"","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"04","Somente Jurํdico?","","","mv_ch4","N",01,0,0,"C","","","","","mv_par04","Sim"	,"","","","Nใo"	,"","","","","","","","","","","","","","","","","","")


cKey     := "P." + cPerg + "01."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")                                       
aAdd(aHelpPor,"Periodo de vencimento a ser considerado.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P." + cPerg + "02."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe vencimento inicial.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P." + cPerg + "03."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe vencimento final.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P." + cPerg + "04."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")                                       
aAdd(aHelpPor,"Considerar somente tํtulos no jurํdico.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

Return Nil

/*/{Protheus.doc} CPASTALD
//Rotina Verifica se existe 
a pasta laudos na protheus data
@author Fabio Batista
@since 11/02/2021
@version 1.0
/*/   
STATIC FUNCTION CPASTALD()

Local nRet := 0 

    If !ExistDir( "C:\Protheus" )
        nRet := MakeDir("C:\Protheus")
        If nRet <> 0
            alert( "Nใo foi possํvel criar o diret๓rio. Erro: " + cValToChar( FError() ) )
        Endif
    EndIf

Return( Nil )
