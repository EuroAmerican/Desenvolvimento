#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "protheus.ch"       

#define ENTER CHR(13) + CHR(10)    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณQESTR005  บ Autor ณTiago Oliveira Beraldi บ Data ณ24/01/2005บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Etiqueta produto Qualyvinil - Zebra                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Qualyvinil                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function QESTR005()

Local cPorta  := "LPT1"
Local _cObs   := ""    //Observacao
Local _cDesc2 := ""    //Descricao do produto
Local _cCod   := ""    //Cod do produto
Local _cVal   := ""    //Validade
Local _cLote  := ""    //Lote
Local _cCodBar:= ""    //String do Cod de barras
Local _nQtd   := 0     //Qtd de etiquetas
Local cCampo  := Iif(Left(cFilAnt,2) == "05", "SB1->B1_DESC2", "SB1->B1_U_DESC2") 
Local lSai    := .T.

Private cPerg := "QEST05"

//Verifica porta de impressao
If !IsPrinter(cPorta)
	Return
Endif

//Verifica dicionario de perguntas
CriaSX1(cPerg)     

If !Pergunte(cPerg,.t.)
	Return
Endif    

//--Inicio do processamento

dbSelectArea("SC2")
dbSetOrder(1)
If !dbSeek(xFilial("SC2")+mv_par04)    
	ApMsgStop("Lote invแlido!")
    Return
EndIf

/*
//Verifica se ja foi impresso
If SC2->C2_IMPFLAG == 0 .Or. ( MsgYesNo("As Etiquetas referente a essa O.P. foram impressas " + cValToChar( SC2->C2_IMPFLAG ) + " vezes, deseja imprimir mais???",'A T E N C A O','YESNO') )
	
	//Reclock("SC2",.F.)
	//SC2->C2_IMPFLAG := SC2->C2_IMPFLAG + mv_par02
	//SC2->( MsUnLock() )
	
	cQry := " UPDATE " + RetSqlName("SC2") + ENTER
	cQry += " SET 		C2_IMPFLAG = " + cValToChar( SC2->C2_IMPFLAG + mv_par02 ) + ENTER
	cQry += " WHERE 	D_E_L_E_T_ = '' " + ENTER
	cQry += " AND		C2_FILIAL = '" + xFilial("SC2") + "' " + ENTER
	cQry += " AND		C2_NUM = '" + SC2->C2_NUM + "' " + ENTER
	cQry += " AND		C2_ITEM = '" + SC2->C2_ITEM + "' " + ENTER
	cQry += " AND		C2_SEQUEN = '" + SC2->C2_SEQUEN + "' " + ENTER
	
	If (TcSQLExec(cQry) < 0)
		Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf
	
Endif
*/

dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1")+Alltrim(SC2->C2_PRODUTO))

If !Empty(SB1->B1_U_CONTD)
	_cObs := "Cont:" + Space(1) + RTrim(SB1->B1_U_CONTD) + Space(1) + SB1->B1_U_UMETQ
EndIf

//Adequa cod de barras
_cCodBar := Subs(SB1->B1_CODBAR, 1, 12)

//Grava Lotes
If Len(Alltrim(mv_par04)) >= 11
	_cLote := Subs(mv_par04,1,6)
Else
	_cLote := Alltrim(mv_par04)
EndIf

_nQtd   := mv_par02                                  //Quantidade de Etiquetas
_dData  := dDataBase + SB1->B1_PRVALID               //Vencimento
_cDesc2 := &cCampo                                   //Descricao
_cCod   := "Cod.: " + Alltrim(SB1->B1_COD)           //Codigo
_cVal   := "Validade: " + Subs(DtoC(_dData),4,2) + "-20" + Subs(DtoC(_dData),7,2) //Validade
_cLote  := "Lote: " + _cLote                         //Lote

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณProcessa impressao                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
MSCBPRINTER("S600",cPorta,,,.f.)

MSCBCHKSTATUS(.f.)

MSCBBEGIN(_nQtd,4)
MSCBSAY(05,03,_cDesc2, "N", "0", "040,032")
MSCBSAY(05,08,_cCod, "N", "0", "028,030")
MSCBSAY(05,11.5,_cVal, "N", "0", "028,030")
MSCBSAY(05,15,_cLote, "N", "0", "028,030")
MSCBSAY(05,18.5,_cObs, "N", "0", "028,030")
MSCBSAYBAR(38,13,_cCodBar,"N","MB04",9,.F.,.T.,.T.,,2,1)
MSCBEND()

MSCBCLOSEPRINTER()

Return

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria dicionario de perguntasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Static Function CriaSX1(cPerg)

Local aRegs     := {}

aAdd(aRegs,{cPerg,'01' ,'Produto            ?',''				 ,''			 ,'mv_ch1','C'  ,15     ,0      ,0     ,'G','                                ','mv_par01','         '  ,''		 ,''	 ,'                ',''   ,'        	    ',''   	 ,''   	  ,''	 ,''   ,'               ' ,''   	 ,''   	  ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'SB1',''})
aAdd(aRegs,{cPerg,'02' ,'Quantidade de Etiq.?',''				 ,''			 ,'mv_ch2','N'  ,10     ,0      ,0     ,'G','                                ','mv_par02','         '  ,''		 ,''	 ,'                ',''   ,'        	    ',''   	 ,''   	  ,''	 ,''   ,'               ' ,''   	 ,''   	  ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'',''})
aAdd(aRegs,{cPerg,'03' ,'Validade           ?',''				 ,''			 ,'mv_ch3','C'  ,07     ,0      ,0     ,'G','                                ','mv_par03','         '  ,''		 ,''	 ,'                ',''   ,'        	    ',''   	 ,''   	  ,''	 ,''   ,'               ' ,''   	 ,''   	  ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'',''})
aAdd(aRegs,{cPerg,'04' ,'Lote               ?',''				 ,''			 ,'mv_ch4','C'  ,13     ,0      ,0     ,'G','                                ','mv_par04','         '  ,''		 ,''	 ,'                ',''   ,'        	    ',''   	 ,''   	  ,''	 ,''   ,'               ' ,''   	 ,''   	  ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'SC2',''})
aAdd(aRegs,{cPerg,'05' ,'Observacao         ?',''				 ,''			 ,'mv_ch5','C'  ,30     ,0      ,0     ,'G','                                ','mv_par05','         '  ,''		 ,''	 ,'                ',''   ,'        	    ',''   	 ,''   	  ,''	 ,''   ,'               ' ,''   	 ,''   	  ,''	 ,''	,'       ',''  		 ,''  	  ,''	 ,''	,''			,''  	   ,''		 ,''	,'',''})
//aAdd(aRegs,{cPerg,'06' ,'Origem dos Dados   ?',''                ,''             ,"mv_ch6","N"  ,1      ,0      ,0     ,'C','                                ','mv_par06','Cadastro '  ,''		 ,''     ,'                ',''   ,'Manual          ',''	 ,''	  ,''    ,''   ,'               ' ,''	     ,''	  ,''	 ,''	,'       ',''		 ,''	  ,''    ,''	,''			,''		   ,''	     ,''	,'',''})
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Carrega as Perguntas no SX1                                  ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
ValidPerg(aRegs,cPerg)

Return 