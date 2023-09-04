#include "protheus.ch"
#include "topconn.ch"

User Function EQEtqSep() // Etiqueta de ordem de separação...

Local cPorta 	:= "LPT1"
Local nFaz      := 0

Private cPerg   := "BEETQORDEM"

ValidPerg()

If Pergunte(cPerg, .T.)
	cQuery := "SELECT CB8_FILIAL, D4_OP, D4_COD, D4_LOCAL, D4_QUANT, CB8_QTDORI, CB8_ORDSEP, D4_LOTECTL, CB8_LOTECT, CB8_NUMLOT, CB8_LOCAL, CB8_PROD, CB8_ITEM, CB8_SEQUEN, CB8_LCALIZ " + CRLF
	cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD4") + " AS SD4 WITH (NOLOCK) ON D4_FILIAL = C2_FILIAL " + CRLF
	cQuery += "  AND D4_OP = C2_NUM + C2_ITEM + C2_SEQUEN " + CRLF
	cQuery += "  AND SD4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("CB8") + " AS CB8 WITH (NOLOCK) ON CB8_FILIAL = D4_FILIAL " + CRLF
	cQuery += "  AND CB8_OP = D4_OP " + CRLF
	cQuery += "  AND CB8_PROD = D4_COD " + CRLF
	cQuery += "  AND CB8_LOCAL = D4_LOCAL " + CRLF
	cQuery += "  AND CB8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
	cQuery += "AND C2_NUM BETWEEN '" + AllTrim( mv_par01 ) + "' AND '" + AllTrim( mv_par02 ) + "' " + CRLF // 010307
	cQuery += "AND C2_ITEM = '01' AND C2_SEQUEN = '001' " + CRLF // 010307
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY CB8_FILIAL, CB8_ORDSEP, D4_LOCAL, CB8_LCALIZ, CB8_ITEM, CB8_LOCAL, CB8_PROD, D4_COD, CB8_LOTECT, CB8_NUMLOT, D4_OP, D4_LOTECTL, D4_QUANT, CB8_QTDORI, CB8_SEQUEN " + CRLF
	//cQuery += "ORDER BY CB8_ORDSEP, CB8_ITEM, D4_COD, CB8_LOTECT, D4_OP, D4_LOTECTL, D4_QUANT, CB8_QTDORI " + CRLF
	//cQuery += "ORDER BY CB8_ORDSEP, CB8_LOCAL, CB8_ITEM, CB8_PROD " + CRLF
	cQuery += "ORDER BY CB8_FILIAL, CB8_ORDSEP, CB8_LOCAL, CB8_LCALIZ, CB8_PROD, CB8_LOTECT, CB8_NUMLOT, CB8_ITEM, CB8_SEQUEN " + CRLF  
Else
	Return
EndIf

TCQuery cQuery New Alias "TMLBAR"
dbSelectArea("TMLBAR")
dbGoTop()

nConta := 0
         
//MSCBPRINTER("LPT1",cPorta,,40,.f.)
//MSCBCHKSTATUS(.F.)

Do While !TMLBAR->( Eof() )
	MSCBPRINTER("LPT1",cPorta,,40,.f.)
		MSCBCHKSTATUS(.F.)
		MSCBBEGIN(1,6)
			MSCBWrite("^FO400,070^BXN ,05,200,20^FD"+BeAscHex(TMLBAR->D4_COD + TMLBAR->D4_LOTECTL)+"^FS") 				// Código de Barras 2d - Data Matrix
			MSCBSAY(014,004,"ORDEM DE PRODUCAO  :. " + Alltrim( TMLBAR->D4_OP ),"N","0","020,020")
			MSCBSAY(014,008,"ORDEM DE SEPARACAO :. " + Alltrim( TMLBAR->CB8_ORDSEP ),"N","0","020,020")
			MSCBSAY(014,012,"PRODUTO: " + Alltrim( TMLBAR->D4_COD ),"N","0","020,020")
			MSCBSAY(014,016,"LOCAL: " + Alltrim( TMLBAR->D4_LOCAL ),"N","0","020,020")
			MSCBSAY(014,020,"LOTE :. " + Alltrim( TMLBAR->D4_LOTECTL ),"N","0","020,020")
			MSCBSAY(014,024,"QUANTIDADE: " + TRANSFORM( TMLBAR->CB8_QTDORI, "@E 999,999,999.9999"),"N","0","020,020")
		MSCBEND()
	MSCBCLOSEPRINTER()

	Sleep(1000)

	//nConta++

	TMLBAR->( dbSkip() )
EndDo

//MSCBCLOSEPRINTER()

TMLBAR->( dbCloseArea() )
	
Return

Static Function ValidPerg()

Local _aArea := GetArea()
Local _aPerg := {}
Local i      := 0

cPerg := Padr( cPerg, 10)

aAdd(_aPerg, {cPerg, "01", "Da Ordem Produção  ?", "MV_CH1" , "C", 11	, 0	, "G", "MV_PAR01", "SC2",""           ,""               ,""               ,""     ,""})
aAdd(_aPerg, {cPerg, "02", "Até Ordem Produção ?", "MV_CH2" , "C", 11	, 0	, "G", "MV_PAR02", "SC2",""           ,""               ,""               ,""     ,""})

DbSelectArea("SX1")
DbSetOrder(1)

For i := 1 To Len(_aPerg)
	IF  !DbSeek(_aPerg[i,1]+_aPerg[i,2])
		RecLock("SX1",.T.)
	Else
		RecLock("SX1",.F.)
	EndIF
	Replace X1_GRUPO   with _aPerg[i,01]
	Replace X1_ORDEM   with _aPerg[i,02]
	Replace X1_PERGUNT with _aPerg[i,03]
	Replace X1_VARIAVL with _aPerg[i,04]
	Replace X1_TIPO	   with _aPerg[i,05]
	Replace X1_TAMANHO with _aPerg[i,06]
	Replace X1_PRESEL  with _aPerg[i,07]
	Replace X1_GSC	   with _aPerg[i,08]
	Replace X1_VAR01   with _aPerg[i,09]
	Replace X1_F3	   with _aPerg[i,10]
	Replace X1_DEF01   with _aPerg[i,11]
	Replace X1_DEF02   with _aPerg[i,12]
	Replace X1_DEF03   with _aPerg[i,13]
	Replace X1_DEF04   with _aPerg[i,14]
	Replace X1_DEF05   with _aPerg[i,15]
	MsUnlock()
Next i

RestArea(_aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ BeAscHex	³ Autor ³ Fabio F Sousa         ³ Data ³ 16/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Converte Asc para Hexadecimal.							  ³±±
±±³          ³ 					  			  							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function BeAscHex(cString)

Local cRet 		:= "^FH_^FD"
Local aAcento	:= {}
Local nPos		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define caracteres a serem tratados.									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAcento := {{"à","_85"},{"á","_a0"},{"â","_83"},{"ã","_c6"},;
			{"À","_b7"},{"Á","_b5"},{"Â","_b6"},{"Ã","_c7"},;
			{"è","_8a"},{"é","_82"},{"ê","_88"},;
			{"È","_d4"},{"É","_90"},{"Ê","_d2"},;
			{"ì","_8d"},{"í","_a1"},{"î","_8c"},;
			{"Ì","_de"},{"Í","_d6"},{"Î","_d7"},;
			{"ò","_95"},{"ó","_a2"},{"ô","_93"},{"õ","_e4"},;
			{"Ò","_e3"},{"Ó","_e0"},{"Ô","_e2"},{"Õ","_e5"},;
			{"ù","_97"},{"ú","_a3"},{"û","_96"},;
			{"Ù","_eb"},{"Ú","_e9"},{"Û","_ea"},;
			{"ç","_87"},{"Ç","_80"},;
			{"°","_a7"},{'"',"_22"},{"@","_40"},{"/","_2f"},;
			{"´","_27"},{"–","_2d"},{"“","_ae"},{"%","_25"},{"—","_2d"}}


For nX := 1 to Len(cString)

	cAux := Substr(cString,nX,1)
	nPos := aScan(aAcento,{|x| x[1] == cAux })

	If nPos > 0
		cRet += aAcento[nPos][2]
	Else
		cRet += cAux
	EndIf

Next nX

cRet := cRet+"^FS"

Return cRet