#include "protheus.ch"
/*-----------------+---------------------------------------------------------+
!Nome              ! EQETQQUA                                                !
+------------------+---------------------------------------------------------+
!Descri��o         ! Etiqueta Modelo Zebra ETOQUETA P/ QUALY                 !
+------------------+---------------------------------------------------------+
!Autor             ! F�bio Carneiro dos Santos                               !
+------------------+---------------------------------------------------------!
!Data              ! 15/09/2021                                              !
+------------------+--------------------------------------------------------*/

User Function EQEtqQua()

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

		MSCBPRINTER("LPT1",cPorta,,40,.F.)
			MSCBCHKSTATUS(.F.)
			MSCBBEGIN(1,4)
				MSCBWrite("^FO220,070^BXN ,10,200,40^FD"+BeAscHex(ALLTRIM(SBE->BE_LOCAL) + ALLTRIM(SBE->BE_LOCALIZ))+"^FS")	// C�digo de Barras 2d - Data Matrix
				MSCBSAY(006,015,ALLTRIM(Transform(SBE->BE_LOCALIZ, "@R ####.999.99")),"R","0","160,180")
				MSCBSAY(083,088,BeAscHex("Rua.......: " + SubStr( SBE->BE_LOCALIZ, 01, 04)),"R","0","110,120")
				MSCBSAY(063,088,BeAscHex("Pr�dio....: " + SubStr( SBE->BE_LOCALIZ, 05, 03)),"R","0","110,120")
				MSCBSAY(043,088,BeAscHex("Andar.....: " + SubStr( SBE->BE_LOCALIZ, 08, 02)),"R","0","110,120")
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
aAdd(_aPerg, {cPerg, "02", "At� o Local        ?", "MV_CH2" , 	"C", 02	, 0	, "G"	, "MV_PAR02", "NNR"	,"","","","",""})
aAdd(_aPerg, {cPerg, "03", "Do Endere�o        ?", "MV_CH3" , 	"C", 15	, 0	, "G"	, "MV_PAR03", "SBE"	,"","","","",""})
aAdd(_aPerg, {cPerg, "04", "At� o Endere�o     ?", "MV_CH4" , 	"C", 15	, 0	, "G"	, "MV_PAR04", "SBE"	,"","","","",""})

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

//���������������������������������������������������������������������Ŀ
//� Define caracteres a serem tratados.									�
//�����������������������������������������������������������������������
aAcento := {{"�","_85"},{"�","_a0"},{"�","_83"},{"�","_c6"},;
			{"�","_b7"},{"�","_b5"},{"�","_b6"},{"�","_c7"},;
			{"�","_8a"},{"�","_82"},{"�","_88"},;
			{"�","_d4"},{"�","_90"},{"�","_d2"},;
			{"�","_8d"},{"�","_a1"},{"�","_8c"},;
			{"�","_de"},{"�","_d6"},{"�","_d7"},;
			{"�","_95"},{"�","_a2"},{"�","_93"},{"�","_e4"},;
			{"�","_e3"},{"�","_e0"},{"�","_e2"},{"�","_e5"},;
			{"�","_97"},{"�","_a3"},{"�","_96"},;
			{"�","_eb"},{"�","_e9"},{"�","_ea"},;
			{"�","_87"},{"�","_80"},;
			{"�","_a7"},{'"',"_22"},{"@","_40"},{"/","_2f"},;
			{"�","_27"},{"�","_2d"},{"�","_ae"},{"%","_25"},{"�","_2d"}}


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
