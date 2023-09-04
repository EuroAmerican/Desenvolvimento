#include "protheus.ch"

User Function EQEtqEnd()

Local cPorta    := "LPT1"  
Local aArea     := GetArea()
Local cEof      := Chr(13) + Chr(10)

Private cPerg   := "EQEtqEnd01"

ValidPerg()

Pergunte(cPerg, .T.)

dbSelectArea("SBE")
dbSetOrder(1)

If SBE->( dbSeek( xFilial( "SBE" ) + mv_par01 + Padr( mv_par03, 15) ) )
	Do While !SBE->( Eof() ) .And. AllTrim( SBE->BE_LOCAL + SBE->BE_LOCALIZ ) >= AllTrim( mv_par01 + mv_par03 ) .And. AllTrim( SBE->BE_LOCAL + SBE->BE_LOCALIZ ) <= AllTrim( mv_par02 + mv_par04 )
/*
		MSCBPRINTER("LPT1",cPorta,,40,.f.)
		MSCBCHKSTATUS(.F.)
	
		MSCBBEGIN(1,6)
		MSCBSAYBAR(04,19,ALLTRIM(SBE->BE_LOCAL) + ALLTRIM(SBE->BE_LOCALIZ),"N","MB07",24,.F.,.F.,.F.,,2)
		MSCBSAY(52,10,ALLTRIM(SBE->BE_LOCALIZ),"N","0","225,150")
		MSCBEND()
	
		MSCBCLOSEPRINTER()
*/
/*
MSCBPRINTER(cModelo,cPorta, , , .F., , , , ,,.f. , ) 
 MSCBCHKSTATUS(.F.)
cFonteT := "F"
 cTam2 := "020,008" //15

MSCBBEGIN(1,4,10) //Inicio da Imagem da Etiqueta
*/

		MSCBPRINTER("S600",cPorta,,40,.f., , , , ,,.f., )
			MSCBCHKSTATUS(.F.)
			MSCBBEGIN(1,4)
//				MSCBWrite("^FO400,070^BXN ,05,200,20^FD"+BeAscHex(TMLBAR->D4_COD + TMLBAR->D4_LOTECTL)+"^FS") 				// Código de Barras 2d - Data Matrix
				MSCBWrite("^FO300,070^BXN ,10,200,40^FD"+BeAscHex(ALLTRIM(SBE->BE_LOCAL) + ALLTRIM(SBE->BE_LOCALIZ))+"^FS") 				// Código de Barras 2d - Data Matrix
				MSCBSAY(014,015,ALLTRIM(Transform(SBE->BE_LOCALIZ, "@R ##.99.99.99")),"R","0","120,160")
				//MSCBSAY(064,005,ALLTRIM(SBE->BE_DESCRIC),"R","0","060,060")
				MSCBSAY(075,074,BeAscHex("Rua.......: " + SubStr( SBE->BE_LOCALIZ, 01, 02)),"R","0","040,040")
				MSCBSAY(065,074,BeAscHex("Prédio....: " + SubStr( SBE->BE_LOCALIZ, 03, 02)),"R","0","040,040")
				MSCBSAY(055,074,BeAscHex("Andar.....: " + SubStr( SBE->BE_LOCALIZ, 05, 02)),"R","0","040,040")
				MSCBSAY(045,074,BeAscHex("Vão.......: " + SubStr( SBE->BE_LOCALIZ, 07, 02)),"R","0","040,040")
			MSCBEND()
		MSCBCLOSEPRINTER()
/*
N - Normal
R - Cima para baixo
I - Invertido
B - Baixo para cima
*/
		SBE->( dbSkip() )
	EndDo
EndIf

RestArea( aArea )

Return

Static Function ValidPerg()

Local _aArea := GetArea()
Local _aPerg := {}

cPerg := cPerg

aAdd(_aPerg, {cPerg, "01", "Do Local           ?", "MV_CH1" , 	"C", 02	, 0	, "G"	, "MV_PAR01", "NNR"	,"","","","",""})
aAdd(_aPerg, {cPerg, "02", "Até o Local        ?", "MV_CH2" , 	"C", 02	, 0	, "G"	, "MV_PAR02", "NNR"	,"","","","",""})
aAdd(_aPerg, {cPerg, "03", "Do Endereço        ?", "MV_CH3" , 	"C", 15	, 0	, "G"	, "MV_PAR03", "SBE"	,"","","","",""})
aAdd(_aPerg, {cPerg, "04", "Até o Endereço     ?", "MV_CH4" , 	"C", 15	, 0	, "G"	, "MV_PAR04", "SBE"	,"","","","",""})

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