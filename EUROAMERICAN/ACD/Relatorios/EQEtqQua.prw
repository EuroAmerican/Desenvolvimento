#include "protheus.ch"
/*-----------------+---------------------------------------------------------+
!Nome              ! EQETQQUA                                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Etiqueta Modelo Zebra ETOQUETA P/ QUALY                 !
+------------------+---------------------------------------------------------+
!Autor             ! Fábio Carneiro dos Santos                               !
!Colaborador       ! Paulo Rogério                                           !
+------------------+---------------------------------------------------------!
!Data              ! 15/09/2021                                              |
|Modificação       | 26/12/2022                                              !
+------------------+---------------------------------------------------------|
|Observação        | Com  a auteração relaizada em 26/12/22, o programa de   |
|                  | Impressão de Etiquetas de Edereço da Euro perde a Função!
|                  | e pode ser removido do projeto.                         |
+------------------+---------------------------------------------------------|

*/

User Function EQEtqQua()

Local cPorta    := "LPT1"  
Local aArea     := GetArea()

Local cZplCode  := ""
Local cZplTarg  := ""

Private cPerg   := "EQEtqEnd01"


// Código Nativo Gerado em ZPL (ZEBRA ZT-230)
cZplCode := "CT~~CD,~CC^~CT~"
cZplCode += "^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ"
cZplCode += "~DG000.GRF,07680,024,"
cZplCode += ",::L0gYF8,:::::::L0HFgU07F8,::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::L0gYF8,:::::::,:::::::::::::~DG001.GRF,54400,068,"
cZplCode += ",::::::::::::::::::::::::::::::03FlPF0,:::::::03FC0lL0HF0,:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::03FlPF0,:::::::,::::::::::::~DG002.GRF,07680,024,"
cZplCode += ",:::::L03FgWFC,:::::::L03FC0gS03FC,::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::L03FgWFC,:::::::,::::::::::::::~DG003.GRF,13056,024,"
cZplCode += ",:::::::::::::::::::::::::::::L0gYF8,:::::::L0HFgU07F8,:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::L0gYF8,:::::::,:::::::::::::::::~DG004.GRF,13056,024,"
cZplCode += ",:::::::::::::::::::::::::::::L03FgWFE,:::::::L03FC0gS01FE,:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::L03FgWFE,:::::::,:::::::::::::::::~DG005.GRF,12288,024,"
cZplCode += "07FgWFC0,:::::::07F80gS03FC0,:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::07FgWFC0,:::::::,:::::::::::::::~DG006.GRF,07680,024,"
cZplCode += ",:::::::0FgXF80,:::::::0FF0gT07F80,:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::0FgXF80,:::::::,:::::::::::^XA"
cZplCode += "^MMT"
cZplCode += "^PW839"
cZplCode += "^LL1638"
cZplCode += "^LS0"
cZplCode += "^FT512,832^XG000.GRF,1,1^FS"
cZplCode += "^FT160,1600^XG001.GRF,1,1^FS"
cZplCode += "^FT320,832^XG002.GRF,1,1^FS"
cZplCode += "^FT512,544^XG003.GRF,1,1^FS"
cZplCode += "^FT320,544^XG004.GRF,1,1^FS"
cZplCode += "^FT160,544^XG005.GRF,1,1^FS"
cZplCode += "^FT160,832^XG006.GRF,1,1^FS"
cZplCode += "^FT629,1557^A0B,130,132^FH\^FD%%ENDERECO%%^FS"
cZplCode += "^FT219,1346^BQN,2,10"
cZplCode += "^FDLA,%%QRCODE%%^FS"
cZplCode += "^FT648,410^A0B,87,88^FH\^FD%%ANDAR%%^FS"
cZplCode += "^FT457,411^A0B,87,88^FH\^FD%%PREDIO%%^FS"
cZplCode += "^FT646,792^A0B,87,88^FH\^FDAndar^FS"
cZplCode += "^FT455,793^A0B,87,88^FH\^FDPr\82dio^FS"
cZplCode += "^FT277,410^A0B,90,91^FH\^FD%%RUA%%^FS"
cZplCode += "^FT275,792^A0B,90,91^FH\^FDRua^FS"
cZplCode += "^PQ1,0,1,Y^XZ"
cZplCode += "^XA^ID000.GRF^FS^XZ"
cZplCode += "^XA^ID001.GRF^FS^XZ"
cZplCode += "^XA^ID002.GRF^FS^XZ"
cZplCode += "^XA^ID003.GRF^FS^XZ"
cZplCode += "^XA^ID004.GRF^FS^XZ"
cZplCode += "^XA^ID005.GRF^FS^XZ"
cZplCode += "^XA^ID006.GRF^FS^XZ"




ValidPerg()

Pergunte(cPerg, .T.)

dbSelectArea("SBE")
dbSetOrder(1)

If SBE->( dbSeek( xFilial( "SBE" ) + mv_par01 + Padr( mv_par03, 15) ) )
	MSCBPRINTER("S600",cPorta,,40,.f., , , , ,,.f., )

	Do While !SBE->( Eof() ) .And. AllTrim( SBE->BE_LOCAL + SBE->BE_LOCALIZ ) >= AllTrim( mv_par01 + mv_par03 ) .And. AllTrim( SBE->BE_LOCAL + SBE->BE_LOCALIZ ) <= AllTrim( mv_par02 + mv_par04 )
		if len(ALLTRIM(SBE->BE_LOCALIZ)) == 8
			//EURO
			cZplTarg := Strtran(cZplCode, "%%RUA%%"      , SubStr( SBE->BE_LOCALIZ, 01, 04))
			cZplTarg := Strtran(cZplTarg, "%%PREDIO%%"   , SubStr( SBE->BE_LOCALIZ, 05, 02))
			cZplTarg := Strtran(cZplTarg, "%%ANDAR%%"    , SubStr( SBE->BE_LOCALIZ, 07, 02))

		Else
			//QUALY
			cZplTarg := Strtran(cZplCode, "%%RUA%%"      , SubStr( SBE->BE_LOCALIZ, 01, 04))
			cZplTarg := Strtran(cZplTarg, "%%PREDIO%%"   , SubStr( SBE->BE_LOCALIZ, 05, 03))
			cZplTarg := Strtran(cZplTarg, "%%ANDAR%%"    , SubStr( SBE->BE_LOCALIZ, 08, 02))
		endif

		cZplTarg := Strtran(cZplTarg, "%%ENDERECO%%" , ALLTRIM(SBE->BE_LOCALIZ))
		cZplTarg := Strtran(cZplTarg, "%%QRCODE%%"   , ALLTRIM(SBE->BE_LOCAL)+ALLTRIM(SBE->BE_LOCALIZ))		// ALLTRIM(SBE->BE_LOCAL)+chr(13)+chr(10)+ALLTRIM(SBE->BE_LOCALIZ))		


			MSCBCHKSTATUS(.F.)
			MSCBBEGIN(1,4)

			MSCBWrite(cZplTarg)	// Código de Barras 2d - Data Matrix

		/*
				MSCBWrite("^FO300,070^BXN ,10,200,40^FD"+BeAscHex(ALLTRIM(SBE->BE_LOCAL) + ALLTRIM(SBE->BE_LOCALIZ))+"^FS")	// Código de Barras 2d - Data Matrix
				MSCBSAY(014,015,ALLTRIM(Transform(SBE->BE_LOCALIZ, "@R ####.999.99")),"R","0","160,180")
				MSCBSAY(075,074,BeAscHex("Rua.......: " + SubStr( SBE->BE_LOCALIZ, 01, 04)),"R","0","110,120")
				MSCBSAY(055,074,BeAscHex("Prédio....: " + SubStr( SBE->BE_LOCALIZ, 05, 03)),"R","0","110,120")
				MSCBSAY(035,074,BeAscHex("Andar.....: " + SubStr( SBE->BE_LOCALIZ, 08, 02)),"R","0","110,120")
		*/

		/*
		N - Normal
		R - Cima para baixo
		I - Invertido
		B - Baixo para cima
		*/

			MSCBEND()
		//MSCBCLOSEPRINTER()

		SBE->( dbSkip() )
	EndDo

	MSCBCLOSEPRINTER()

EndIf

RestArea( aArea )

Return

Static Function ValidPerg()

Local _aArea := GetArea()
Local _aPerg := {}
Local i      := 0
Local nX     := 0

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
