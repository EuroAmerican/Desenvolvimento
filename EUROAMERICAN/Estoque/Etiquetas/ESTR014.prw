#include "protheus.ch"
#include "topconn.ch"        
#include "tbiconn.ch"   
#include "rwmake.ch"   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณESTR014   บ Autor ณTiago O. Beraldi    บ Data ณ  13/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณIMPRESSAO DE ROTULO DE PRODUTOS - EUROAMERICAN              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAEST                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑบ10/01/18  บEmerson Paiva     บAjustes P12 e controle Lotes Padrใo      บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function ESTR014(nOpc)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de variaveis                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cPorta    := "LPT1:"
Local cPerg     := "ESTR014"
Local aDados    := Array(11)

Default nOpc := 1

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica dicionario de perguntas                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
dbSelectArea("SX1")
dbSetOrder(1)
dbSeek(PadR(cPerg, 10) + "02")

RecLock("SX1", .F.)
	SX1->X1_CNT01 := Str(0)
SX1->( MsUnLock() )

Pergunte(cPerg, .T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica porta de impressao                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !IsPrinter(cPorta)
	Return
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento                                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
SC2->(dbSetOrder(1))
SC2->(dbSeek(xFilial("SC2") + mv_par01))

SB1->(dbSetOrder(1))
If Empty(mv_par04)
	SB1->(dbSeek(xFilial("SB1") + SC2->C2_PRODUTO))
Else
	SB1->(dbSeek(xFilial("SB1") + AllTrim(mv_par04)))
Endif

SAH->(dbSetOrder(1))
SAH->(dbSeek(xFilial("SAH") + SB1->B1_SEGUM))
                     
/*
//Grava primeira emissao               
If SC2->C2_IMPFLAG == 0
	Reclock("SC2", .F.)
		SC2->C2_IMPFLAG := mv_par03
	SC2->( MsUnLock() )
Else
	If !(MsgYesNo("As Etiquetas referente a essa O.P. foram impressas " + Str(SC2->C2_IMPFLAG) +;
	              " vezes, deseja imprimir mais ?", "A T E N C A O", "YESNO"))
		Return
	Else
		Reclock("SC2",.F.)
			SC2->C2_IMPFLAG += mv_par03
		SC2->( MsUnLock() )
	Endif
Endif                    
*/

SZD->(dbSetOrder(2))         
If SZD->(dbSeek(xFilial("SZD") + SC2->C2_NUM))
	dDataEt := SZD->ZD_DTFABR
	dDataFb := SZD->ZD_DTVALID
Else
	SB8->(dbSetOrder(5))	//Alterado 10/01/18
	If SB8->(dbSeek(xFilial("SB8") + SC2->C2_PRODUTO + SC2->C2_NUM))
		dDataEt := SB8->B8_DFABRIC
		dDataFb := SB8->B8_DTVALID
	Else                                      
		dDataEt := dDataBase
		dDataFb := dDataBase + SB1->B1_PRVALID
	EndIf 
EndIf

If Empty(SC2->C2_DTETIQ) 
	U_ExecSql(SC2->C2_NUM)
EndIf    

If mv_par02 == 0 
	nPesoL := SB1->B1_PESO 
Else
	nPesoL := mv_par02
EndIf
                       
aDados[01] := Subs(SB1->B1_DESC, 1, 40)                              // Descricao do Produto
aDados[02] := AllTrim(SB1->B1_COD)                                   // Codigo do Produto
aDados[03] := SC2->C2_NUM                                            // Lote
aDados[04] := AllTrim(Str(nPesoL)) + Space(1) + "KG"                // Peso
aDados[05] := DtoC(dDataEt)                                          // Data de Fabricacao
aDados[06] := DtoC(dDataFb)                                          // Data de Vencimento
aDados[07] := AllTrim(SAH->AH_UMRES)                                 // Descricao da Embalagem
aDados[08] := aDados[05]                                             // Data de Envase
aDados[09] := SB1->B1_U_DESC2                                        // Descricao Complementar
aDados[10] := AllTrim(SC2->(C2_NUM + C2_ITEM + C2_SEQUEN))          // Cod de Barras                  
aDados[11] := Subs(SC2->C2_PRODUTO, 1, 3) + Iif(Subs(SC2->C2_PRODUTO, 14, 1) $ "A#B#C#D#E#K#V#R#S#Y#I", "." + Subs(SC2->C2_PRODUTO, 14, 2), "")    
                        
//Tratamento PI
If Subs(aDados[11], 1, 1) == "P"
	aDados[11] := Subs(SC2->C2_PRODUTO, 1, 5)
EndIf	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Impressao                                                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
MSCBPRINTER("S600", cPorta,,, .F.)
MSCBCHKSTATUS(.F.)  
MSCBBEGIN(mv_par03, 3)   

If Len(aDados[11]) == 3
    // Amostras
	If nOpc == 2
		MSCBSAY(0043, 0060, "AMOSTRA", "N", "0", "070,050", .T.) 
		MSCBSAY(0035, 0006, aDados[11], "R", "0", "270,165", .T.)
	Else
		MSCBSAY(0042, 0006, aDados[11], "R", "0", "270,280", .T.)
	EndIf		
Else	
	If nOpc == 2
		MSCBSAY(0030, 0050, "AMOSTRA", "N", "0", "070,050", .T.) 
	EndIf
	MSCBSAY(0035, 0006, aDados[11], "R", "0", "270,165", .T.)
EndIf     

If ( RTrim(aDados[11]) $ "329#337#937" )
	MSCBSAY(0040, 0004, "** AGITAR ANTES DE USAR **", "R", "0", "045,040", .T.)
EndIf

MSCBSAY(0063, 0070, aDados[01] , "R", "0", "085,070", .T.)
MSCBSAY(0065, 0140, "(" + aDados[02] + ")", "R", "0", "060,055", .T.)

MSCBSAY(0050, 0070, aDados[04], "R", "0", "055,045", .T.)
MSCBSAY(0050, 0115, aDados[03], "R", "0", "055,045", .T.)
MSCBSAY(0050, 0160, aDados[07], "R", "0", "055,045", .T.)                                

MSCBSAY(0036, 0070, aDados[05], "R", "0", "055,045", .T.)
MSCBSAY(0036, 0115, aDados[06], "R", "0", "055,045", .T.)

If nOpc == 2
	MSCBSAY(0036, 0160, "AMOSTRA", "R", "0", "055,045", .T.) 
Else
	MSCBSAYBAR(0036, 0155, aDados[10], "R", "MB01", 08, .F., .T., .T.,, 3, 2)     
EndIf	

//MSCBSAY(0096, 0054, aDados[09], "R", "0", "085,070", .T.)      

MSCBEND()
MSCBCLOSEPRINTER()

Return         

User Function ExecSql(cNumOP)

cQry := " UPDATE " + RetSqlName("SC2") + " "
cQry += " SET C2_DTETIQ = '" + DtoS(dDataBase) + "' "
cQry += " WHERE C2_NUM = '" + cNumOP + "' "
TcSQLExec(cQry)

Return
