#include "protheus.ch"
#include "topconn.ch"        
#include "tbiconn.ch"   
#include "rwmake.ch"    
#include "colors.ch"

#define ENTER chr(13) + chr(10)
#define PAD_LEFT            0
#define PAD_RIGHT           1
#define PAD_CENTER          2

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATR006   บ                            บ Data ณ 06/02/09    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณRELATORIO DE SEPARACAO E EMBARQUE                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFAT                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function FATR006()  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aArea   := GetArea()  
Local lOk	  := .F.      

Private cPerg   := "FATR006"    
Private cTitulo := "Ordem de Separa็ใo e Embarque"  

MsgAlert("Fun็ใo Descontinuada")
Return

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Dicionario de Perguntas                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
fCriaSX1(cPerg)    
Pergunte(cPerg, .F.)

oPrint := PcoPrtIni(cTitulo, .F., 2,, @lOk, cPerg) 

If lOk
	oProcess := MsNewProcess():New({|lEnd| FATR006Imp(@lEnd, oPrint, oProcess)},"","",.F.)
	oProcess :Activate()
	PcoPrtEnd(oPrint)
EndIf
                   
RestArea(aArea)                              

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATR006IMPบ Autor ณTiago O Beraldi     บ Data ณ 06/02/09    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFUNCAO DE IMPRESSAO                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFAT                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FATR006Imp(lEnd,oPrint)
       
Local cQry                                            
Local i
Local cQuebra  := ""    
Local cCliente := ""       
Local nPosPrn  := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis                                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private nLin     := 4000
Private cPag     := "001"      
Private aDados   := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fontes utilizadas                                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private oFont0  := TFont():New( "Courier New"             ,,10     ,,.F.,,,,,.F.) 
Private oFont1	:= TFont():New( "Courier New"             ,,08     ,,.T.,,,,,.F.)
Private oFont2  := TFont():New( "Courier New"             ,,08     ,,.F.,,,,,.F.) 
Private oFont3  := TFont():New( "Courier New"             ,,07     ,,.T.,,,,,.F.)       
Private oFont4  := TFont():New( "Courier New"             ,,08     ,,.F.,,,,,.F.) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Campos                                                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aDados,{"Produto"		, 0250, "QRY->PROD"   	, "C",}) 
aAdd(aDados,{"Descri็ใo"	, 1060, "QRY->DESCRI" 	, "C",}) 
aAdd(aDados,{"Qtde"			, 1220, "QRY->QUANT" 	, "N", "@E 9,999,999"}) 
aAdd(aDados,{"UM"         	, 1290, "QRY->UNID"   	, "C",})   
aAdd(aDados,{"Endereco"    	, 1500, "QRY->LOCALIZ"	, "C",}) 
aAdd(aDados,{"Lote 1" 		, 1750, "QRY->NUMLOTE1"	, "C",}) 
aAdd(aDados,{"Lote 2"		, 2000, "QRY->NUMLOTE2"	, "C",}) 
aAdd(aDados,{"Lote 3"		, 2250, "QRY->NUMLOTE3"	, "C",}) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Query                                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
cQry := "SELECT		D2_DOC DOC, " + ENTER
cQry += "			D2_SERIE SERIE, " + ENTER
cQry += "			D2_COD PROD, " + ENTER
cQry += "			CASE WHEN C6_MOV400 != '' THEN '(MOV400) ' + RTRIM(B1_DESC) ELSE RTRIM(B1_DESC) END DESCRI, " + ENTER
cQry += "			SUM(D2_QUANT) QUANT, " + ENTER
cQry += "			D2_UM UNID, " + ENTER
cQry += "			D2_EMISSAO EMISSAO,  " + ENTER
cQry += "			D2_PEDIDO PEDIDO, " + ENTER
cQry += "			B2_LOCALIZ LOCALIZ, " + ENTER
cQry += "			'' NUMLOTE1, " + ENTER
cQry += "			'' NUMLOTE2, " + ENTER
cQry += "			'' NUMLOTE3  " + ENTER
cQry += "FROM 		" + RetSqlName("SD2") + " SD2 " + ENTER
cQry += "LEFT JOIN	" + RetSqlName("SC6") + " SC6 " + ENTER
cQry += "ON			SC6.D_E_L_E_T_ = '' " + ENTER
cQry += "AND		C6_FILIAL = D2_FILIAL " + ENTER
cQry += "AND		C6_NUM = D2_PEDIDO " + ENTER
cQry += "AND		C6_ITEM = D2_ITEMPV " + ENTER
cQry += "LEFT JOIN	" + RetSqlName("SB1") + " SB1 " + ENTER
cQry += "ON 		SB1.D_E_L_E_T_ = '' " + ENTER
cQry += "AND		B1_FILIAL = '" + xFilial("SB1") + "' " + ENTER
cQry += "AND		B1_COD = D2_COD " + ENTER
cQry += "LEFT JOIN	" + RetSqlName("SB2") + " SB2 " + ENTER
cQry += "ON 		SB2.D_E_L_E_T_ = ''  " + ENTER
cQry += "AND		B2_FILIAL = '" + xFilial("SB2") + "' " + ENTER
cQry += "AND		B2_COD = D2_COD " + ENTER
cQry += "AND		B2_LOCAL = D2_LOCAL " + ENTER
cQry += "WHERE		SD2.D_E_L_E_T_ = '' " + ENTER
cQry += "AND		D2_FILIAL = '" + xFilial("SD2") + "' " + ENTER   
cQry += "AND		D2_EMISSAO BETWEEN '" + DtoS(mv_par01) + "' AND '" + DtoS(mv_par02) + "' " + ENTER
cQry += "AND		D2_DOC BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' " + ENTER
cQry += "AND		D2_SERIE BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' " + ENTER
cQry += "AND		D2_TP = 'PA' " + ENTER    
cQry += "AND		(SELECT F4_ESTOQUE FROM " + RetSqlName("SF4") + " WHERE D_E_L_E_T_ = '' AND F4_CODIGO >= '500' AND F4_CODIGO = D2_TES) = 'S'" + ENTER
//cQry += " ORDER BY D2_CLIENTE, D2_DOC, D2_COD " + ENTER
cQry += "GROUP BY	D2_FILIAL, " + ENTER
cQry += "			D2_DOC, " + ENTER
cQry += "			D2_SERIE,  " + ENTER
cQry += "			D2_COD,  " + ENTER
cQry += "			D2_UM,  " + ENTER
cQry += "			D2_EMISSAO,   " + ENTER
cQry += "			D2_LOCAL, " + ENTER
cQry += "			D2_PEDIDO, " + ENTER
cQry += "			B1_DESC, " + ENTER
cQry += "			C6_MOV400, " + ENTER
cQry += "			B2_LOCALIZ " + ENTER
cQry += "ORDER BY	D2_DOC, " + ENTER
cQry += "			D2_COD " + ENTER

MemoWrite("fatr006.sql", cQry)    

If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS QRY

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Incio da Impressao                                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPrint:SetPaperSize(9)   //Papel A4
oPrint:SetPortrait()     //Retrato

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Itens                                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("QRY")             
dbGoTop()                            

oProcess:SetRegua1(QRY->(RecCount()))   

//Posiciona Pedido
SC5->(dbSetOrder(8))
SC5->(dbSeek(xFilial("SC5") + QRY->DOC + QRY->SERIE))

cCliente := SC5->C5_CLIENTE + SC5->C5_LOJACLI 
lNewPage := .F.

While !EOF("QRY")
    
	oProcess:IncRegua1("Processando dados...")
	
	//Salto de Pagina    
	If nLin > 2700 
		oPrint:EndPage()		
		fCabec() 
		lNewPage := .T. 
		oPrint:StartPage()  
	EndIf
                     
	If QRY->(DOC+SERIE) != cQuebra .Or. lNewPage 
		
		lNewPage := .F.  
		lImpRI   := .F.                                  

		SC5->(dbSetOrder(8))
		SC5->(dbSeek(xFilial("SC5") + QRY->DOC + QRY->SERIE))

		If SC5->C5_PREPEMB == "1"
			MsgAlert("Relat๓rio de Separa็ใo e Embarque jแ emitido para NF " + SC5->C5_NOTA)    
			lImpRI := .T.
		EndIf      
		
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))

		SA4->(dbSetOrder(1))
		SA4->(dbSeek(xFilial("SA4") + SC5->C5_TRANSP))                     
		
		If cCliente != (SC5->C5_CLIENTE + SC5->C5_LOJACLI)
			oPrint:EndPage()		
			fCabec()    
			oPrint:StartPage()  			
			cCliente := SC5->C5_CLIENTE + SC5->C5_LOJACLI
		EndIf
			
		nLin += 50
		oPrint:Say( nLin, 0100, "Nota Fiscal....: " + QRY->SERIE + QRY->DOC + "(" + DtoC(StoD(QRY->EMISSAO)) + ")     Pedido: " + QRY->PEDIDO + "(" + DtoC(SC5->C5_EMISSAO) + ")     Entrega: " + DtoC(SC5->C5_ENTREG), oFont0,,,,PAD_RIGHT)    
		nLin += 50
		oPrint:Say( nLin, 0100, "Cliente........: " + SA1->A1_NOME, oFont0,,,,PAD_RIGHT)    
		nLin += 50
		oPrint:Say( nLin, 0100, "Endere็o.......: " + AllTrim(SA1->A1_END) + " - " + AllTrim(SA1->A1_BAIRRO) + " - " + AllTrim(SA1->A1_MUN) + " - " + AllTrim(SA1->A1_EST) + " - " + AllTrim(SA1->A1_CEP), oFont0,,,,PAD_RIGHT)    
		nLin += 50
		oPrint:Say( nLin, 0100, "End. Entrega...: " + AllTrim(SC5->C5_ENDREC) + " - " + AllTrim(SC5->C5_BAIREC) + " - " + AllTrim(SC5->C5_MUNREC) + " - " + AllTrim(SC5->C5_ESTREC) + " - " + AllTrim(SC5->C5_CEPREC), oFont0,,,,PAD_RIGHT)    
		nLin += 50
		oPrint:Say( nLin, 0100, "Transportador..: " + IIf( SC5->C5_RETIRA=="S"," ( RETIRA ) ", "") + SC5->C5_TRANSP + "-" + SA4->A4_NREDUZ, oFont0,,,,PAD_RIGHT)    
		nLin += 50
		oPrint:Say( nLin, 0100, "End. Transp....: " + AllTrim(SA4->A4_END)+ " - " + AllTrim(SA4->A4_MUN) + "-" + SA4->A4_EST + "-" + SA4->A4_CEP, oFont0,,,,PAD_RIGHT)    
		nLin += 50
		//oPrint:Say( nLin, 0100, "Observa็๕es....: " + AllTrim(SC5->C5_OBS) + Iif(SA1->A1_LAUDO == "S", " - ACOMPANHA LAUDO", ""), oFont0,,,,PAD_RIGHT)    ]
		nCol := 100                                                     
		oPrint:Say( nLin, 0100, "Observa็๕es....: " + MemoLine(SC5->C5_OBS, nCol, 1) , oFont0,,,,PAD_RIGHT)
		For i := 2 To MlCount(SC5->C5_OBS, nCol)
			nLin += 35
			oPrint:Say( nLin, 0048, Space(15) + AllTrim(MemoLine(SC5->C5_OBS, nCol, i)), oFont0,,,,)  
		Next   

		If .Not. Empty(SA1->A1_U_ENTRG)
			nLin += 70
			oPrint:Say( nLin, 0048, Space(15) + "*** " + AllTrim(SA1->A1_U_ENTRG) + " ***", oFont0,,,,) 
		EndIf
	         
	    If AllTrim(SA1->A1_LAUDO) == "S"
			nLin += 70
			oPrint:Say( nLin, 0048, Space(15) + "*** ACOMPANHA LAUDO ***", oFont0,,,,) 
		EndIf

		nLin += 40                
		cVolumes := Iif(SC5->C5_VOLUME1 > 0,Transform(SC5->C5_VOLUME1,"@E 9,999") + " " + AllTrim(SC5->C5_ESPECI1),"");
					+ Iif(SC5->C5_VOLUME2 > 0,Transform(SC5->C5_VOLUME2,"@E 9,999") + " " + AllTrim(SC5->C5_ESPECI2),"");
					+ Iif(SC5->C5_VOLUME3 > 0,Transform(SC5->C5_VOLUME3,"@E 9,999") + " " + AllTrim(SC5->C5_ESPECI3),"");
					+ Iif(SC5->C5_VOLUME4 > 0,Transform(SC5->C5_VOLUME4,"@E 9,999") + " " + AllTrim(SC5->C5_ESPECI4),"");
					+ Iif(SC5->C5_VOLUME5 > 0,Transform(SC5->C5_VOLUME5,"@E 9,999") + " " + AllTrim(SC5->C5_ESPECI5),"");
					+ Iif(SC5->C5_VOLUME6 > 0,Transform(SC5->C5_VOLUME6,"@E 9,999") + " " + AllTrim(SC5->C5_ESPECI6),"");
					+ Iif(SC5->C5_VOLUME7 > 0,Transform(SC5->C5_VOLUME7,"@E 9,999") + " " + AllTrim(SC5->C5_ESPECI7),"")          
					
		//Posiciona SF2
		SF2->(dbSetOrder(1))
		SF2->(dbSeek(xFilial("SF2") + QRY->DOC + QRY->SERIE))	  
					
		oPrint:Say( nLin, 0100, "Volumes........: " + cVolumes, oFont0,,,,PAD_RIGHT)    
		nLin += 50                
		oPrint:Say( nLin, 0100, "Peso Bruto.....: " + Transform(SC5->C5_PBRUTO, "@E 999,999,999.99") + " KG         Valor..........: R$ " + AllTrim(Transform(SF2->F2_VALMERC, "@E 999,999,999.99")) + Iif(lImpRI, Space(5) + " *** R E I M P R E S S ร O *** ", ""), oFont0,,,,PAD_RIGHT)    
		nLin += 50

		For i := 1 to Len(aDados) 
			oPrint:Box( nLin, 0000, nLin + 40, aDados[i,2] + 10)
			oPrint:Say( nLin, aDados[i,2], aDados[i,1], oFont1,,,,PAD_RIGHT)                                                                
		Next i    
		
		nLin += 60                

		cQuebra := QRY->(DOC+SERIE)
	
	EndIf                                                       
	
	For i := 1 to Len(aDados) 
		oPrint:Box( nLin, 0000, nLin + 85, aDados[i,2] + 10)
	Next i   
	
	nLin += 20                
	
	For i := 1 to Len(aDados)   
		If !Empty(aDados[i][3])
			If aDados[i][4] == "N"
				oPrint:Say( nLin, aDados[i][2], Transform(&(aDados[i][3]), aDados[i][5]), oFont4,,,, PAD_RIGHT)                                     
			Else
				oPrint:Say( nLin, aDados[i][2], AllTrim(&(aDados[i][3])), oFont4,,,, PAD_RIGHT)                                     
			EndIf      
		EndIf
	Next i     
	     
	// Seleciona lotes que devem ser separados para o produto
	cQry := "SELECT		CASE WHEN RTRIM(C2_DATRF) = '' THEN ZZE_LOTE + ' #400' ELSE ZZE_LOTE END [LOTE], " + ENTER 
	cQry += "			ZZE_QTDE [QTDE]  " + ENTER
	cQry += "FROM		"+RetSqlName("ZZE")+" ZZE" + ENTER	
	cQry += "LEFT JOIN	"+RetSqlName("SC2")+" SC2" + ENTER
	cQry += "ON			SC2.D_E_L_E_T_ = '' " + ENTER
	cQry += "AND		C2_FILIAL = '' " + ENTER
	cQry += "AND		C2_NUM = ZZE_LOTE " + ENTER
	cQry += "AND		C2_PRODUTO = ZZE_PROD " + ENTER
	cQry += "AND		C2_LOCAL = ZZE_LOCAL " + ENTER
	cQry += "WHERE		ZZE.D_E_L_E_T_ = '' " + ENTER
	cQry += "AND		ZZE_FILIAL = '" + xFilial("ZZE") + "' " + ENTER
	cQry += "AND		ZZE_IDXCPO = 'D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA' " + ENTER
	cQry += "AND		ZZE_IDXVAL = '" + QRY->DOC + QRY->SERIE + SA1->A1_COD + SA1->A1_LOJA + "' " + ENTER
	cQry += "AND		ZZE_IDXARQ = 'SD2' " + ENTER
	cQry += "AND		ZZE_EMPFIL = '" + cFilAnt + "' " + ENTER
	cQry += "AND		ZZE_PROD = '" + QRY->PROD + "' 
	cQry += "AND		ZZE_ESTORN = '' " + ENTER                             

    
    // Grupo Empresa - Ajuste realizado (CG)
	
	// cQry += "AND		ZZE_EMPFIL = '" + cEmpAnt + cFilAnt + "' " + ENTER


	If Select("QRYZZE") > 0
		QRYZZE->(dbCloseArea())
	EndIf
	
	TCQUERY cQry NEW ALIAS QRYZZE
	              
	nPosPrn := 1750  
	
	While .Not. QRYZZE->( EoF() )             
	                                             
		cTxtPrn := RTrim( QRYZZE->LOTE )
		oPrint:Say( ( nLin-10 ), nPosPrn, cTxtPrn, oFont4,,,, PAD_RIGHT)
		
		cTxtPrn := cValToChar( QRYZZE->QTDE ) + "-" + QRY->UNID
		oPrint:Say( ( nLin+25 ), nPosPrn, cTxtPrn, oFont4,,,, PAD_RIGHT)
		                             
	 	nPosPrn += 250
	     
		QRYZZE->( dbSkip() )

	EndDo
	  
	If Select("QRYZZE") > 0
		QRYZZE->(dbCloseArea())
	EndIf
		
	// Espacamento entre linhas 
	nLin += 65

	dbSelectArea("QRY")  		
	dbSkip()   
	
	//Atualiza Status de Embarque no Pedido
	If QRY->(DOC+SERIE) != cQuebra     

		dbSelectArea("SC5")
		SC5->(dbSetOrder(8))
		SC5->(dbSeek(xFilial("SC5") + cQuebra))     
	       
		If SC5->(Found())
			RecLock("SC5", .F.)
				SC5->C5_PREPEMB := "1" 
			SC5->( MsUnLock() )
		EndIf
			                    
		dbSelectArea("SF2")
		SF2->(dbSetOrder(1))
		SF2->(dbSeek(xFilial("SF2") + RTrim(QRY->DOC) + RTrim(QRY->SERIE)))	  		
             
		If SF2->(Found())
			RecLock("SF2", .F.)
				SF2->F2_U_DTSEP := Date()
				SF2->F2_U_HRSEP := Left(Time(),5)
			SF2->( MsUnLock() )		
		EndIf
			
		dbSelectArea("QRY")
		  		
	EndIf    

EndDo

oPrint :EndPage()		

QRY->(dbCloseArea())

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFCABEC    บ Autor ณTiago O Beraldi     บ Data ณ 23/07/08    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณCABECALHO                                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFAT                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fCabec()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis                                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cLogo    
Local i

// Grupo Empresa - Ajuste realizado (CG)


//If cEmpAnt == "02"      //Euroamerican
//	cLogo    := "EURO.BMP"
//ElseIf cEmpAnt + cFilAnt $ "0203#0304"  //Qualyvinil
//	cLogo    := "QUALY.BMP"
//EndIf


If Left(cFilAnt,2) == "02"    //Euroamerican
	cLogo    := "EURO.BMP"
ElseIf cFilAnt $ "0203#0304"  //Qualyvinil
	cLogo    := "QUALY.BMP"
EndIf
     
nLin := 20

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Logomarca                                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oPrint:Say( nLin, 0050, SM0->M0_NOMECOM, oFont0,,,, PAD_LEFT)
oPrint:SayBitmap( nLin, 3250, cLogo, 0180, 0110)
nLin += 50
oPrint:Box( nLin, 0010, nLin + 2, 3250)
nLin += 20                                                                                                     
oPrint:Say( nLin, 0050, "Data: " + DtoC(dDataBase), oFont2,,,, PAD_LEFT)
nLin += 20                                                               
oPrint:Say( nLin, 0050, "Hora: " + Time(), oFont2,,,, PAD_LEFT)                                     
oPrint:Say( nLin, 1150, cTitulo + " - Emissใo de " + DtoC(mv_par01) + " at้ " + DtoC(mv_par02), oFont1,,,, PAD_CENTER)
nLin += 40
oPrint:Say( nLin, 2350, "Pแgina: " + cPag, oFont2,,,, PAD_RIGHT) 
nLin += 40
oPrint:Box( nLin, 0010, nLin + 2, 2500)    
nLin += 20   

oPrint:Box( 2800, 0010, 2802, 3250)
oPrint:Say( 2900, 0050, "SEPARADOR:_________________________________________ CONFERENTE:_________________________________________ BOX:__________________________", oFont1,,,,PAD_RIGHT)   					     
oPrint:Box( 2950, 0010, 2952, 3250)
                                                                 
cPag := Soma1(cPag, 3)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFCRIASX1  บ Autor ณTiago O. Beraldi    บ Data ณ  06/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณGERA DICIONARIO DE PERGUNTAS                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fCriaSX1()

Local cKey := ""
Local aHelpEng := {}
Local aHelpPor := {}
Local aHelpSpa := {}

PutSX1(cPerg,"01","De Emissใo        ?","","","mv_ch1","D",08,0,0,"G","",""   ,"","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"02","At้ Emissใo       ?","","","mv_ch2","D",08,0,0,"G","",""   ,"","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"03","De Nota Fiscal     ","","","mv_ch3","C",09,0,0,"G","","SF2","","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"04","Ate Nota Fiscal    ","","","mv_ch4","C",09,0,0,"G","","SF2","","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"05","De Serie           ","","","mv_ch5","C",03,0,0,"G","",""   ,"","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"06","Ate Serie          ","","","mv_ch6","C",03,0,0,"G","",""   ,"","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","")

cKey     := "P." + cPerg + "01."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe a Emissใo Inicial.")
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
aAdd(aHelpPor,"Informa a Emissใo Final.")
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
aAdd(aHelpPor,"Informe a Nota Fiscal Inicial.")
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
aAdd(aHelpPor,"Informe a Nota Fiscal Final.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P." + cPerg + "05."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe a Serie Inicial.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P." + cPerg + "06."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe a Serie Final.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

Return 
