#include 'protheus.ch'
#include 'parmtype.ch'

#define ENTER chr(13) + chr(10)
#define PAD_LEFT            0
#define PAD_RIGHT           1
#define PAD_CENTER          2

/*/{Protheus.doc} rfat001
//Relatorio para imprimir a ordem de separacao.
@author mjlozzardo
@since 24/04/2018
@version 1.0
/*/
User Function rfat001()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea   := GetArea()
	Local lOk	  := .F.

	Private cPerg   := "RFAT001"
	Private cTitulo := "Ordem de Separação e Embarque"

	MsgAlert("Função Descontinuada")
	Return

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dicionario de Perguntas                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//fCriaSX1(cPerg)
	Pergunte(cPerg, .F.)

	oPrint := PcoPrtIni(cTitulo, .F., 2,, @lOk, cPerg)

	If lOk
		oProcess := MsNewProcess():New({|lEnd| FATR006Imp(@lEnd, oPrint, oProcess)},"","",.F.)
		oProcess :Activate()
		PcoPrtEnd(oPrint)
	EndIf

	RestArea(aArea)

	Return

Static Function FATR006Imp(lEnd,oPrint)
	Local nI      := 0
	Local nPosPrn := 0
	Local cEndFat := ""
	Local cEndEnt := ""
	Local cNome   := ""
	Local k       := 1 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private nLin     := 4000
	Private cPag     := "001"
	Private aDados   := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fontes utilizadas                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private oFont0  := TFont():New( "Courier New",,10,,.F.,,,,,.F.)
	Private oFont1	:= TFont():New( "Courier New",,08,,.T.,,,,,.F.)
	Private oFont2  := TFont():New( "Courier New",,08,,.F.,,,,,.F.)
	Private oFont3  := TFont():New( "Courier New",,07,,.T.,,,,,.F.)
	Private oFont4  := TFont():New( "Courier New",,08,,.F.,,,,,.F.)
	Private oFont5	:= TFont():New( "Courier New",,14,,.T.,,,,,.F.)
	Private oFont6  := TFont():New( "Courier New",,10,,.F.,,,,,.F.)
	Private oFont6n := TFont():New( "Courier New",,10,,.T.,,,,,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campos                                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aDados,{"Produto"	, 0400, "CB8->CB8_PROD"  , "C",})
	aAdd(aDados,{"Descrição", 1210, "SB1->B1_DESC"   , "C",})
	aAdd(aDados,{"Qtde"		, 1450, "CB8->CB8_QTDORI", "N", "@E 9,999,999"})
	aAdd(aDados,{"UM"       , 1520, "SB1->B1_UM"     , "C",})
	aAdd(aDados,{"Almox"    , 1730, "CB8->CB8_LOCAL" , "C",})
	aAdd(aDados,{"Localiz" 	, 1980, "CB8->CB8_LCALIZ", "C",})
	aAdd(aDados,{"Lote"		, 2230, "CB8->CB8_LOTECT", "C",})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Incio da Impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:SetPaperSize(9)   //Papel A4
	oPrint:SetPortrait()     //Retrato

	SA1->(DbSetOrder(1))
	SA2->(DbSetOrder(1))
	SA4->(DbSetOrder(1))
	SB1->(DbSetOrder(1))
	SC5->(DbSetOrder(1))
	SF2->(DbSetOrder(1))
	CB8->(DbSetOrder(7))

	DbSelectArea("CB7")
	DbSetOrder(1)
	DbSeek(xFilial("CB7") + MV_PAR01, .T.)
	oProcess:SetRegua1(CB7->(RecCount()) - CB7->(RecNo()))

	While CB7->(!Eof()) .and. CB7->(CB7_FILIAL + CB7_ORDSEP) <= (xFilial("CB7") + MV_PAR02)
		If CB7->CB7_DTEMIS >= MV_PAR03 .and. CB7->CB7_DTEMIS <= MV_PAR04
			If (CB7->CB7_NOTA >= MV_PAR05 .and. CB7->CB7_NOTA <= MV_PAR06) .and. (CB7->CB7_PEDIDO >= MV_PAR07 .and. CB7->CB7_PEDIDO <= MV_PAR08)

				If !Empty(CB7->CB7_NOTA)
					//nota fiscal
					SF2->(DbSeek(xFilial("SF2") + CB7->(CB7_NOTA + CB7_SERIE + CB7_CLIENT + CB7_LOJA), .F.))
					If SF2->F2_TIPO $ "B|D"
						SA2->(DbSeek(xFilial("SA2") + SF2->(F2_CLIENTE + F2_LOJA), .F.))
						cNome   := Rtrim(SA2->A2_NOME)
						cEndFat := AllTrim(SA2->A2_END) + " - " + AllTrim(SA2->A2_BAIRRO) + " - " + AllTrim(SA2->A2_MUN) + " - " + AllTrim(SA2->A2_EST) + " - " + TransForm(SA2->A2_CEP, "@R 99999-999")
						cEndEnt := AllTrim(SA2->A2_END) + " - " + AllTrim(SA2->A2_BAIRRO) + " - " + AllTrim(SA2->A2_MUN) + " - " + AllTrim(SA2->A2_EST) + " - " + TransForm(SA2->A2_CEP, "@R 99999-999")
					Else
						SA1->(DbSeek(xFilial("SA1") + SF2->(F2_CLIENTE + F2_LOJA), .F.))
						cNome   := Rtrim(SA1->A1_NOME)
						cEndFat := AllTrim(SA1->A1_END) + " - " + AllTrim(SA1->A1_BAIRRO) + " - " + AllTrim(SA1->A1_MUN) + " - " + AllTrim(SA1->A1_EST) + " - " + TransForm(SA1->A1_CEP, "@R 99999-999")
						cEndEnt := AllTrim(SA1->A1_ENDENT) + " - " + AllTrim(SA1->A1_BAIRROE) + " - " + AllTrim(SA1->A1_MUNE) + " - " + AllTrim(SA1->A1_ESTE) + " - " + TransForm(SA1->A1_CEPE, "@R 99999-999")
					EndIf
					//transportadora
					SA4->(DbSeek(xFilial("SA4") + SF2->F2_TRANSP, .F.))

				Else
					//pedido de venda
					SC5->(DbSeek(xFilial("SC5") + CB7->CB7_PEDIDO, .F.))
					If SC5->C5_TIPO $ "B|D"
						SA2->(DbSeek(xFilial("SA2") + SC5->(C5_CLIENTE + C5_LOJACLI), .F.))
						cNome   := Rtrim(SA2->A2_NOME)
						cEndFat := AllTrim(SA2->A2_END) + " - " + AllTrim(SA2->A2_BAIRRO) + " - " + AllTrim(SA2->A2_MUN) + " - " + AllTrim(SA2->A2_EST) + " - " + TransForm(SA2->A2_CEP, "@R 99999-999")
						cEndEnt := AllTrim(SA2->A2_END) + " - " + AllTrim(SA2->A2_BAIRRO) + " - " + AllTrim(SA2->A2_MUN) + " - " + AllTrim(SA2->A2_EST) + " - " + TransForm(SA2->A2_CEP, "@R 99999-999")
					Else
						SA1->(DbSeek(xFilial("SA1") + SC5->(C5_CLIENTE + C5_LOJACLI), .F.))
						cNome   := Rtrim(SA1->A1_NOME)
						cEndFat := AllTrim(SA1->A1_END) + " - " + AllTrim(SA1->A1_BAIRRO) + " - " + AllTrim(SA1->A1_MUN) + " - " + AllTrim(SA1->A1_EST) + " - " + TransForm(SA1->A1_CEP, "@R 99999-999")
						cEndEnt := AllTrim(SA1->A1_ENDENT) + " - " + AllTrim(SA1->A1_BAIRROE) + " - " + AllTrim(SA1->A1_MUNE) + " - " + AllTrim(SA1->A1_ESTE) + " - " + TransForm(SA1->A1_CEPE, "@R 99999-999")
					EndIf
					//transportadora
					SA4->(DbSeek(xFilial("SA4") + SC5->C5_TRANSP, .F.))
				EndIf

				//item da ordem
				CB8->(DbSeek(xFilial("CB8") + CB7->CB7_ORDSEP, .F.))

				//pedido de venda
				SC5->(DbSeek(xFilial("SC5") + CB8->CB8_PEDIDO, .F.))
				
				//item da ordem - Reposicionar
				CB8->(DbSeek(xFilial("CB8") + CB7->CB7_ORDSEP, .F.))
				
				While CB8->(!Eof()) .and. CB8->CB8_ORDSEP == CB7->CB7_ORDSEP
					//Salto de Pagina
					If nLin > 2700
						oPrint:EndPage()
						fCabec(cNome, cEndFat, cEndEnt)
						oPrint:StartPage()
						//box-cabecalho
						For nI := 1 to Len(aDados)
							oPrint:Box(nLin, 0000, nLin + 50, aDados[nI, 2] + 10)
							oPrint:Say(nLin, aDados[nI, 2], aDados[nI, 1], oFont6n,,,,PAD_RIGHT)
						Next nI
						nLin += 70
					EndIf

					//produto
					SB1->(DbSeek(xFilial("SB1") + CB8->CB8_PROD, .F.))

					//BOX
					For nI := 1 to Len(aDados)
						oPrint:Box(nLin, 0000, nLin + 95, aDados[nI, 2] + 10)
					Next nI
					nLin += 30

					For nI := 1 To Len(aDados)
						If aDados[nI, 4] == "N"
							oPrint:Say(nLin, aDados[nI, 2], Transform(&(aDados[nI, 3]), aDados[nI, 5]), oFont6,,,, PAD_RIGHT)
						Else
							oPrint:Say(nLin, aDados[nI, 2], Rtrim(&(aDados[nI, 3])), oFont6,,,, PAD_RIGHT)
						EndIf
					Next nI
					nLin += 65
					
					CB8->(DbSkip())
				EndDo

			EndIf
		EndIf
		oProcess:IncRegua1("Efetuando impressao...")
		CB7->(DbSkip())
		nLin := 4000
	EndDo
	Return

Static Function fCabec(cNome, cEndFat, cEndEnt)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cLogo
	Local i

	// ============================================================
	//  Grupo Empresa - Ajuste realizado em 31.08.20 (CG)
	// ============================================================
	
	// cEmpAnt (Substituido por cFilAnt)
	
	If Left(cFilAnt,2) == "02"      //Euroamerican
		cLogo    := "EURO.BMP"
	ElseIf AllTrim(cFilAnt) $ "0203#0304#0801"  //Qualyvinil
		cLogo    := "QUALY.BMP"
	EndIf

	nLin := 20

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Logomarca                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:Say( nLin, 0050, SM0->M0_NOMECOM, oFont0,,,, PAD_LEFT)
	oPrint:SayBitmap( nLin, 3250, cLogo, 0180, 0110)
	nLin += 50
	oPrint:Box( nLin, 0010, nLin + 2, 3250)
	nLin += 20
	oPrint:Say( nLin, 0050, "Data: " + DtoC(dDataBase), oFont2,,,, PAD_LEFT)
	nLin += 20
	oPrint:Say( nLin, 0050, "Hora: " + Time(), oFont2,,,, PAD_LEFT)
	oPrint:Say( nLin, 1150, cTitulo /*+ " - Emissão de " + DtoC(mv_par03) + " até " + DtoC(mv_par04)*/, oFont1,,,, PAD_CENTER)
	oPrint:Say( nLin, 2350, "Ord.Sep: " + CB7->CB7_ORDSEP, oFont5,,,,PAD_RIGHT)
	nLin += 40
	//oPrint:Say( nLin, 2350, "Página: " + cPag, oFont2,,,, PAD_RIGHT)
	nLin += 40
	oPrint:Box( nLin, 0010, nLin + 2, 2500)
	nLin += 20

	cPag := Soma1(cPag, 3)

	nLin += 50
	oPrint:Say( nLin, 0100, "Nota Fiscal....: " + SF2->F2_SERIE + SF2->F2_DOC + "(" + Dtoc(SF2->F2_EMISSAO) + ") Pedido: " + SC5->C5_NUM + " (" + Dtoc(SC5->C5_EMISSAO) + ")"/* Entrega: " + Dtoc(SC5->C5_ENTREG)*/, oFont0,,,,PAD_RIGHT)
	nLin += 50
	oPrint:Say( nLin, 0100, "Cliente........: " + SC5->C5_CLIENTE + "/" + SC5->C5_LOJACLI + "-" + cNome, oFont0,,,,PAD_RIGHT)
	nLin += 50
	oPrint:Say( nLin, 0100, "Endereço.......: " + cEndFat, oFont0,,,,PAD_RIGHT)
	nLin += 50
	oPrint:Say( nLin, 0100, "End. Entrega...: " + cEndEnt, oFont0,,,,PAD_RIGHT)
	nLin += 50
	oPrint:Say( nLin, 0100, "Transportador..: " + /*Iif(SC5->C5_RETIRA == "S","(RETIRA) ", " ") + */SC5->C5_TRANSP + " - " + SA4->A4_NREDUZ, oFont0,,,,PAD_RIGHT)
	nLin += 50
	oPrint:Say( nLin, 0100, "End. Transp....: " + AllTrim(SA4->A4_END)+ " - " + AllTrim(SA4->A4_MUN) + "-" + SA4->A4_EST + "-" + TransForm(SA4->A4_CEP, "@R 99999-999"), oFont0,,,,PAD_RIGHT)
	nLin += 50
	nCol := 100
	oPrint:Say( nLin, 0100, "Observações....: " + MemoLine(SC5->C5_OBS, nCol, 1) , oFont0,,,,PAD_RIGHT)
	For i := 2 To MlCount(SC5->C5_OBS, nCol)
		nLin += 35
		oPrint:Say( nLin, 0048, Space(15) + AllTrim(MemoLine(SC5->C5_OBS, nCol, i)), oFont0,,,,)
	Next

	If !Empty(SA1->A1_U_ENTRG)
		nLin += 70
		oPrint:Say( nLin, 0048, Space(15) + "*** " + AllTrim(SA1->A1_U_ENTRG) + " ***", oFont0,,,,)
	EndIf

	If AllTrim(SA1->A1_LAUDO) == "S"
		nLin += 70
		oPrint:Say( nLin, 0048, Space(15) + "*** ACOMPANHA LAUDO ***", oFont0,,,,)
	EndIf

	nLin += 40
	
	If !Empty(CB7->CB7_NOTA)
	
		cVolumes := Iif(SF2->F2_VOLUME1 > 0,Transform(SF2->F2_VOLUME1,"@E 9,999") + " " + AllTrim(SF2->F2_ESPECI1),"");
				+ Iif(SF2->F2_VOLUME2 > 0,Transform(SF2->F2_VOLUME2,"@E 9,999") + " " + AllTrim(SF2->F2_ESPECI2),"");
				+ Iif(SF2->F2_VOLUME3 > 0,Transform(SF2->F2_VOLUME3,"@E 9,999") + " " + AllTrim(SF2->F2_ESPECI3),"");
				+ Iif(SF2->F2_VOLUME4 > 0,Transform(SF2->F2_VOLUME4,"@E 9,999") + " " + AllTrim(SF2->F2_ESPECI4),"");
				+ Iif(SF2->F2_VOLUME5 > 0,Transform(SF2->F2_VOLUME5,"@E 9,999") + " " + AllTrim(SF2->F2_ESPECI5),"");
				+ Iif(SF2->F2_VOLUME6 > 0,Transform(SF2->F2_VOLUME6,"@E 9,999") + " " + AllTrim(SF2->F2_ESPECI6),"");
				+ Iif(SF2->F2_VOLUME7 > 0,Transform(SF2->F2_VOLUME7,"@E 9,999") + " " + AllTrim(SF2->F2_ESPECI7),"")
	
	Else
		cVolumes := Iif(SC5->C5_VOLUME1 > 0,Transform(SC5->C5_VOLUME1,"@E 9,999") + " " + AllTrim(SC5->C5_ESPECI1),"");
				+ Iif(SC5->C5_VOLUME2 > 0,Transform(SC5->C5_VOLUME2,"@E 9,999") + " " + AllTrim(SC5->C5_ESPECI2),"");
				+ Iif(SC5->C5_VOLUME3 > 0,Transform(SC5->C5_VOLUME3,"@E 9,999") + " " + AllTrim(SC5->C5_ESPECI3),"");
				+ Iif(SC5->C5_VOLUME4 > 0,Transform(SC5->C5_VOLUME4,"@E 9,999") + " " + AllTrim(SC5->C5_ESPECI4),"")		
	EndIf
	

	oPrint:Say( nLin, 0100, "Volumes........: " + cVolumes, oFont0,,,,PAD_RIGHT)
	nLin += 50
	If !Empty(CB7->CB7_NOTA)
		oPrint:Say( nLin, 0100, "Peso Bruto.....: " + Transform(SF2->F2_PBRUTO, "@E 999,999,999.99") + " KG         Valor..........: R$ " + AllTrim(Transform(SF2->F2_VALMERC, "@E 999,999,999.99")), oFont0,,,,PAD_RIGHT)
	Else
		oPrint:Say( nLin, 0100, "Peso Bruto.....: " + Transform(SC5->C5_PBRUTO, "@E 999,999,999.99") + " KG         Valor..........: R$ " + AllTrim(Transform(SF2->F2_VALMERC, "@E 999,999,999.99")), oFont0,,,,PAD_RIGHT)
	EndIf
	nLin += 50

	oPrint:Box( 2800, 0010, 2802, 3250)
	oPrint:Say( 2900, 0050, "SEPARADOR:_________________________________________ CONFERENTE:_________________________________________ BOX:__________________________", oFont1,,,,PAD_RIGHT)
	oPrint:Box( 2950, 0010, 2952, 3250)

	Return

Static Function fCriaSX1()
	Local cKey := ""
	Local aHelpEng := {}
	Local aHelpPor := {}
	Local aHelpSpa := {}

	PutSX1(cPerg,"01","Ord Sep Ini","","","mv_ch1","C",06,0,0,"G","","CB7","","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","")
	PutSX1(cPerg,"02","Ord Sep Fim","","","mv_ch2","C",06,0,0,"G","","CB7","","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","")
	PutSX1(cPerg,"03","Emissao Ini","","","mv_ch3","D",08,0,0,"G","",""   ,"","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","")
	PutSX1(cPerg,"04","Emissao Fim","","","mv_ch4","D",08,0,0,"G","",""   ,"","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","")
	PutSX1(cPerg,"05","NFiscal Ini","","","mv_ch5","C",09,0,0,"G","","SF2","","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","")
	PutSX1(cPerg,"06","NFiscal Fim","","","mv_ch6","C",09,0,0,"G","","SF2","","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","")

	cKey     := "P." + cPerg + "01."
	aHelpEng := {}
	aHelpPor := {}
	aHelpSpa := {}
	aAdd(aHelpEng,"")
	aAdd(aHelpEng,"")
	aAdd(aHelpPor,"Informe a Ordem de separacao Inicial.")
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
	aAdd(aHelpPor,"Informe a Ordem de separacao Final.")
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
	aAdd(aHelpPor,"Informe a Emissão Inicial.")
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
	aAdd(aHelpPor,"Informa a Emissão Final.")
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
	aAdd(aHelpPor,"Informe a Nota Fiscal Inicial.")
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
	aAdd(aHelpPor,"Informe a Nota Fiscal Final.")
	aAdd(aHelpPor,"")
	aAdd(aHelpSpa,"")
	aAdd(aHelpSpa,"")
	PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

	Return
