#include "protheus.ch"
#include "topconn.ch"        
#include "tbiconn.ch"   
#include "rwmake.ch"    

#define ENTER chr(13) + chr(10)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FATM005  º Autor ³Tiago O Beraldi     º Data ³ 14/10/08    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³AJUSTA CUSTO STANDARD DE MPS E EMBALAGENS                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFAT                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                     A L T E R A C O E S                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ºProgramador       ºAlteracoes                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FATM005()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dicionario de Perguntas                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("FATM05",.T.)    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 96, 009 TO 310, 592 DIALOG oDlg TITLE "Atualiza Custo Standard de Matéria-Prima e Embalagem."
@ 18, 006 TO 066, 287
@ 29, 015 SAY "Este programa tem o objetivo de atualizar o campo Custo Standard conforme parametros definidos pelo " SIZE 268, 8
@ 38, 015 SAY "usuario, Custo Standard == Valor 1 + ( Valor 2 x Dolar Informado)                                   " SIZE 268, 8
@ 80, 196 BMPBUTTON TYPE 1 ACTION RunProc()
@ 80, 224 BMPBUTTON TYPE 2 ACTION Close(oDlg)
@ 80, 252 BMPBUTTON TYPE 5 ACTION Pergunte("FATM05", .T.) 
ACTIVATE DIALOG oDlg CENTERED

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FATM005  º Autor ³Tiago O Beraldi     º Data ³ 14/10/08    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ PROCESSAMENTO                                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFAT                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                     A L T E R A C O E S                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ºProgramador       ºAlteracoes                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunProc()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha dialog e inicia processamento                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Close(oDlg)
                                               
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 1 = Atualiza Custo Standard 2 = Atualiza Custo Teste                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par04 == 1
	cMsg := "Deseja continuar a atualização? (CUSTO STANDARD)"
Else
	cMsg := "Deseja continuar a atualização? (CUSTO TESTES)"
EndIf

If ApMsgYesNo(cMsg, "Atualização de Custos")    
	Processa({|| CalcCust()}, "Atualizando Custo Standard...")
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FATM005  º Autor ³Tiago O Beraldi     º Data ³ 14/10/08    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ EFETUA O CALCULO DO CUSTO                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFAT                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                     A L T E R A C O E S                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ºProgramador       ºAlteracoes                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CalcCust()
                           
Local nCstNew   := 0
Local nCstOld   := 0
Local cCampo    := ""
Local _nCalcIcm := 0
Local _nCalcPis := 0
Local _nCalcCof := 0
Local _nCalcFim := 0
Local _nCalcBas := 0
Local _nPisCof  := 0
Local _lNewNet  := GETMV("QE_NEWNET",,.T.) 

dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1") + AllTrim(mv_par01))

ProcRegua(RecCount()-Recno())

While !SB1->(EOF()) .And. RTrim(SB1->B1_COD) <= RTrim(mv_par02)
    
	If mv_par04 == 1
		Incproc( "Atualizando Custo Standard: " + SB1->B1_COD)
	Else
		Incproc( "Atualizando Custo Teste: " + SB1->B1_COD )
	Endif
	

	IF Alltrim(SB1->B1_COD) > AllTrim(mv_par02)
		Exit
	Endif


	If SB1->B1_TIPO $ "MP|ME|MO|BN"	        

		_nCalcIcm := 0
		_nCalcBas := 0
		_nCalcPis := 0
		_nCalcCof := 0
		_nPisCof  := 0
		_nCalcFim := 0

		nCstNew := SB1->B1_VAL1 + (mv_par03 * SB1->B1_VALOR2)
		nCstOld := SB1->B1_XCUSTD
		cCampo  := "SB1->B1_CUST" + Subs(DtoC(dDataBase), 4, 2)
	
		Reclock("SB1",.F.)
			If mv_par04 == 1  // Custo Standard
				SB1->B1_XCUSTD  := nCstNew
					If SB1->B1_ZCSTIMP == 0

					If _lNewNet 
						_nCalcIcm := (nCstNew * SB1->B1_XPICM/100)      // Calculo do valor do ICMS  
						_nCalcBas := (nCstNew - _nCalcIcm)              // Base de calculo - o icms 
						_nCalcPis := (_nCalcBas * SB1->B1_XPPIS/100)    // calculo do valor do Pis 
						_nCalcCof := (_nCalcBas * SB1->B1_XPCOFIN/100)  // Calculo do valor do cofins 
						_nPisCof  := (_nCalcPis + _nCalcCof)            // Soma os valores do PIS e COFINS
						_nCalcFim := (_nCalcBas - _nPisCof)             // Calcula com na dedução do valor do icms na base de pis e cofins	 

						SB1->B1_CUSTNET:= _nCalcFim
						&cCampo        := _nCalcFim
						SB1->B1_CNETQUA:= _nCalcFim
						SB1->B1_CNETPHO:= _nCalcFim
					Else 
						SB1->B1_CUSTNET:= nCstNew * (1 - ((SB1->B1_XPPIS + SB1->B1_XPCOFIN + SB1->B1_XPICM)/100))
						&cCampo        := nCstNew * (1 - ((SB1->B1_XPPIS + SB1->B1_XPCOFIN + SB1->B1_XPICM)/100)) //28/03/18 Alterado para gravar Custo Net
						SB1->B1_CNETQUA:= nCstNew * (1 - ((SB1->B1_XPPIS + SB1->B1_XPCOFIN + SB1->B1_XPICM)/100))
						SB1->B1_CNETPHO:= nCstNew * (1 - ((SB1->B1_XPPIS + SB1->B1_XPCOFIN + SB1->B1_XPICM)/100))
					EndIf

				Else
					SB1->B1_CUSTNET := nCstNew - SB1->B1_ZCSTIMP
					&cCampo         := nCstNew - SB1->B1_ZCSTIMP
					SB1->B1_CNETQUA := nCstNew - SB1->B1_ZCSTIMP
					SB1->B1_CNETPHO := nCstNew - SB1->B1_ZCSTIMP
				EndIf
				SB1->B1_XDATREF := dDataBase
				SB1->B1_XUREV   := dDataBase
			Else			 // Custo Teste
				If SB1->B1_ZCSTIMP == 0

					If _lNewNet 
						_nCalcIcm := (nCstNew * SB1->B1_XPICM/100)      // Calculo do valor do ICMS  
						_nCalcBas := (nCstNew - _nCalcIcm)              // Base de calculo - o icms 
						_nCalcPis := (_nCalcBas * SB1->B1_XPPIS/100)    // calculo do valor do Pis 
						_nCalcCof := (_nCalcBas * SB1->B1_XPCOFIN/100)  // Calculo do valor do cofins 
						_nPisCof  := (_nCalcPis + _nCalcCof)            // Soma os valores do PIS e COFINS
						_nCalcFim := (_nCalcBas - _nPisCof)             // Calcula com na dedução do valor do icms na base de pis e cofins	 

						SB1->B1_VALOR4  := _nCalcFim
						SB1->B1_VALOR4Q := _nCalcFim
						SB1->B1_VALOR4P := _nCalcFim
					Else 
						SB1->B1_VALOR4  := nCstNew * (1 - ((SB1->B1_XPPIS + SB1->B1_XPCOFIN + SB1->B1_XPICM)/100)) //28/03/18 Alterado para gravar Custo Net
						SB1->B1_VALOR4Q := nCstNew * (1 - ((SB1->B1_XPPIS + SB1->B1_XPCOFIN + SB1->B1_XPICM)/100)) //28/03/18 Alterado para gravar Custo Net
						SB1->B1_VALOR4P := nCstNew * (1 - ((SB1->B1_XPPIS + SB1->B1_XPCOFIN + SB1->B1_XPICM)/100)) //28/03/18 Alterado para gravar Custo Net
					EndIf
				Else					
					SB1->B1_VALOR4  := nCstNew - SB1->B1_ZCSTIMP
					SB1->B1_VALOR4Q := nCstNew - SB1->B1_ZCSTIMP
					SB1->B1_VALOR4P := nCstNew - SB1->B1_ZCSTIMP
				EndIf
			Endif
		SB1->( Msunlock() )
	
	EndIf
	
	dbSelectArea("SB1")
	dbSkip()
	
EndDo 

MsgInfo("Termino de Processamento!!!", "Custo Net - MP")

Return
