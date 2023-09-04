#include "PROTHEUS.CH"

STATIC _oFINA4901
STATIC __lLimMot := ExistFunc("LimMotRead")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINA490  ³ Autor ³ Andreia dos Santos    ³ Data ³19.11.98  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tabela de Motivos da baixa                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FINA490(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Sem Argumentos                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financeiro     ³ Fun‡„o Relacionada ³ Entrada Dados (Todos)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User FuncTion FINM010()

Local lPanelFin		:= IsPanelFin()
Local oDlg
Local cVar			:= ""
Local nOpc			:= 0
Local aCampos		:= {}
Local cArqTmp		:= ""
Local cFile			:= "SIGAADV.MOT"
Local aButtonTxt	:= {}

If ExistBlock("FILEMOT")
	cFile := ExecBlock("FILEMOT",.F.,.F.,{cFile})
Endif

aCampos:={	{"SIGLA"	, "C", 03, 0 },;
			{"DESCR"	, "C", 10, 0 },;
			{"CARTEIRA"	, "C", 01, 0 },;
			{"MOVBANC"	, "C", 01, 0 },;
			{"COMIS"	, "C", 01, 0 },;
			{"CHEQUE"	, "C", 01, 0 },;
			{"ESPECIE"	, "C", 01, 0 }	}

//------------------
//Criação da tabela temporaria 
//------------------
If _oFINA4901 <> Nil
	_oFINA4901:Delete()
	_oFINA4901 := Nil
Endif

_oFINA4901 := FWTemporaryTable():New( "cArqTmp" )  
_oFINA4901:SetFields( aCampos ) 	
_oFINA4901:Create()	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ "Importa" o arquivo TXT com a tabela dos Motivos de Baixa ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "cArqTmp" )

If !FILE(cFile)
	nHdlMot := MSFCreate(cFile,0)
	If nHdlMot == -1
		HELP( " ", 1, "MOT_ERROR" )
		Final( "Erro F_" + Str( ferror(), 2 ) + " em SIGAADV.MOT" )
	EndIf
	

    fWrite(nHdlMot,STR0021+chr(13)+chr(10))
    fWrite(nHdlMot,STR0022+chr(13)+chr(10))
    fWrite(nHdlMot,STR0023+chr(13)+chr(10))
    fWrite(nHdlMot,STR0024+chr(13)+chr(10))
    fWrite(nHdlMot,STR0025+chr(13)+chr(10))

	fClose(nHdlMot)
EndIf

APPEND FROM &cFile SDF
dbGoTop()

While .T.
	aSize := MSADVSIZE()
	nOpc := 0
	cAlias := "cArqTmp"
	dbSelectArea(cAlias)

	DEFINE MSDIALOG oDlg FROM  aSize[7],0 To aSize[6],aSize[5] TITLE STR0001 PIXEL  // "Tabela de Motivos de Baixas"
	nEspLarg := 6
  	nEspLin  := 7
	oDlg:lMaximized := .T.
	oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	oPanel2 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,15,15)
	oPanel2:Align := CONTROL_ALIGN_BOTTOM


	@ nEspLin,nEspLarg LISTBOX oLbx  Var cVar FIELDS SIGLA,DESCR,CARTEIRA,MOVBANC,COMIS,CHEQUE,ESPECIE HEADER STR0002,STR0003,STR0004,STR0005,STR0006,STR0011,STR0020; // "SIGLA"###"DESCRICAO"###"CARTEIRA"###"MOV.BANCARIA"###"COMISSAO"###"CHEQUE"###"ESPECIE"
		COLSIZES 100,80,100	SIZE 205, 65 OF oPanel PIXEL ON DBLCLICK Edita( oLbx )
	
	oLBX:Align := CONTROL_ALIGN_ALLCLIENT

	DEFINE SBUTTON FROM 003, 220 TYPE 13 ENABLE OF oPanel2 Action ( nOpc := 4, oDlg:End()			) //Salvar
	DEFINE SBUTTON FROM 003, 255 TYPE 02 ENABLE OF oPanel2 Action ( nOpc := 0, oDlg:End()			) //cancelar
	DEFINE SBUTTON FROM 003, 290 TYPE 11 ENABLE OF oPanel2 Action ( nOpc := 1, Edita( oLbx )		) //edita
	DEFINE SBUTTON FROM 003, 325 TYPE 04 ENABLE OF oPanel2 Action ( nOpc := 2, Edita( oLbx, nOpc )	) //inclui
	DEFINE SBUTTON FROM 003, 360 TYPE 03 ENABLE OF oPanel2 Action ( nOpc := 3, Edita( oLbx, nOpc )	) //exclui


	ACTIVATE MSDIALOG oDlg Centered

	If nOpc == 0 .OR. nOpc == 4
		exit
	Endif
	dbgotop()
EndDo

If nOpc == 0 .OR. nOpc == 4
	dbSelectArea( "cArqTmp" )
	FERASE(cFile)
	Copy to &cFile SDF

	//Deleta tabela temporária criada no banco de dados
	If _oFINA4901 <> Nil
		_oFINA4901:Delete()
		_oFINA4901 := Nil
	Endif


	If lPanelFin  //Chamado pelo Painel Financeiro
		dbSelectArea(FinWindow:cAliasFile)
		FinVisual(FinWindow:cAliasFile,FinWindow,(FinWindow:cAliasFile)->(Recno()),.T.)
	Endif
	

EndIf

Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ EDITA    ³ Autor ³ Vinicius Barreira     ³ Data ³ 14/02/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Edita os campos do arquivo temporario                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EDITA()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Edita( oLbx , nModo , aValores )

Local oDlg
Local cSigla	:= IIf( nModo <> 2, Field->SIGLA	, space(03) )
Local cDescrMot	:= IIf( nModo <> 2, Field->DESCR	, space(10) )
Local cCarteira	:= IIf( nModo <> 2, Field->CARTEIRA	, space(01) )
Local cMovBan	:= IIf( nModo <> 2, Field->MOVBANC	, space(01) )
Local cComis	:= IIf( nModo <> 2, Field->COMIS	, space(01) )
Local cGCheque	:= IIf( nModo <> 2, Field->CHEQUE	, space(01) )
Local cEspecie	:= IIf( nModo <> 2, Field->ESPECIE	, space(01) ) 
Local nOpc		:= 0
Local lValido	:= .T.
Local nRecNo	:= RecNo()

Default aValores := {}

nModo := if( nModo == NIL, 0, nModo)
aSize := MSADVSIZE()

//Validação para que a tela seja aberta com valores pré-estabelecidos
If !Empty( aValores )
	cSigla		:= aValores[ 1 ]
	cDescrMot	:= aValores[ 2 ]
	cCarteira	:= aValores[ 3 ]
	cMovBan		:= aValores[ 4 ]
	cComis		:= aValores[ 5 ]
	cGCheque		:= aValores[ 6 ]
	cEspecie		:= aValores[ 7 ]
EndIf

Do While .T.
	cAlias := "cArqTmp"
	DEFINE MSDIALOG oDlg FROM  86,1 TO 380,400 TITLE STR0008 PIXEL  // "Edicao dos Motivos de Baixa"

	nEspLarg := 0
	nEspLin  := 0
	oDlg:lMaximized := .F.
	oPanela := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20)
	oPanela:Align := CONTROL_ALIGN_ALLCLIENT

	@ 007+nEspLin, 004+nEspLarg TO 192+nEspLin, 154+nEspLarg LABEL STR0009 OF oPanela  PIXEL  // "Motivos"
	@ 016+nEspLin, 008+nEspLarg SAY STR0002   SIZE 053, 007 OF oPanela PIXEL  // "Sigla"
	@ 029+nEspLin, 008+nEspLarg SAY STR0003   SIZE 053, 007 OF oPanela PIXEL  // "Descricao"
	@ 043+nEspLin, 008+nEspLarg SAY STR0004   SIZE 053, 007 OF oPanela PIXEL  // "Carteira"
	@ 056+nEspLin, 008+nEspLarg SAY STR0005   SIZE 053, 007 OF oPanela PIXEL  // "Mov.Banc"
	@ 069+nEspLin, 008+nEspLarg SAY STR0006   SIZE 053, 007 OF oPanela PIXEL  // "Comissao"
	@ 082+nEspLin, 008+nEspLarg SAY STR0011   SIZE 053, 007 OF oPanela PIXEL  // "Cheque"
	@ 095+nEspLin, 008+nEspLarg SAY STR0020   SIZE 053, 007 OF oPanela PIXEL  // "Especie"

	@ 014+nEspLin, 068+nEspLarg MSGET cSigla    SIZE 024, 010 OF oPanela PIXEL Picture "@!" When nModo <> 3
	@ 027+nEspLin, 068+nEspLarg MSGET cDescrMot SIZE 051, 010 OF oPanela PIXEL Picture "@!" When nModo <> 3
	@ 040+nEspLin, 068+nEspLarg MSGET cCarteira SIZE 015, 010 OF oPanela PIXEL Picture "@!" When nModo <> 3
	@ 053+nEspLin, 068+nEspLarg MSGET cMovBan   SIZE 015, 010 OF oPanela PIXEL Picture "@!" When nModo <> 3
	@ 066+nEspLin, 068+nEspLarg MSGET cComis    SIZE 015, 010 OF oPanela PIXEL Picture "@!" When nModo <> 3
	@ 079+nEspLin, 068+nEspLarg MSGET cGCheque  SIZE 015, 010 OF oPanela PIXEL Picture "@!" When nModo <> 3
	@ 092+nEspLin, 068+nEspLarg MSGET cEspecie  SIZE 015, 010 OF oPanela PIXEL Picture "@!" When nModo <> 3


	DEFINE SBUTTON FROM 15,160 TYPE 1 ENABLE OF oDlg Action (nOpc:=1,oDlg:End())
	DEFINE SBUTTON FROM 29,160 TYPE 2 ENABLE OF oDlg Action (nOpc:=0,oDlg:End())
	ACTIVATE MSDIALOG oDlg Centered

	If nOpc == 1 .And. (empty( cSigla) .or. empty( cDescrMot) .or. !(cCarteira $"PRA" .or. cMovBan $"SN" .or. cComis $"SN" .or. cGCheque $"SN").or. cSigla$"PCC/CMF")
	   If cSigla$"PCC/CMF"
	   		MsgAlert(STR0017)
	   Endif
	   Loop
	Endif

	//Modulo Controle de Lojas - não permite alteração do registro do motivo de baixa
	If nOpc == 1 .And. (AllTrim(cSigla) == "LOJ") .And. !(cCarteira + cMovBan + cComis + cGCheque == "ANSS")
		MsgAlert(STR0018) //"Não é possível alterar esse tipo de Motivo de Baixa"
		nOpc := 0
		Loop
	EndIf
	
	Exit
Enddo

If nOpc == 1 .and. nModo <> 3

	//Validação de registros duplicados - Início
	dbGoTop()
	While !Eof()
		If cSigla == Field->Sigla .And. IIF(nModo == 0, Recno() <> nRecno, .T.)
			lValido := .F.
			Exit
		EndIf
		dbSkip()
	EndDo
	dbGoTo( nRecNo )
	//Validação de registros duplicados - Fim

	If lValido
		If nModo == 2
			RecLock( "cArqTmp" , .T. )
		Else
			RecLock( "cArqTmp" )
		EndIf
		Field->Sigla	:= cSigla
		Field->Descr	:= cDescrMot
		Field->Carteira	:= cCarteira
		Field->MovBanC	:= cMovBan
		Field->Comis	:= cComis
		Field->Cheque	:= cGCheque
		Field->Especie	:= cEspecie
		
		If oLbx != Nil
			oLbx:Refresh()
		EndIf
	Else
		Help( " " , 1 , "JAGRAVADO" )
		aValores := {}
		aAdd( aValores , cSigla    )
		aAdd( aValores , cDescrMot )
		aAdd( aValores , cCarteira )
		aAdd( aValores , cMovBan   )
		aAdd( aValores , cComis    )
		aAdd( aValores , cGCheque  )
		aAdd( aValores , cEspecie  )
		//Abre a tela no mesmo modo e valores que estava de forma ao usuário cancelar ou alterar o registro para que se torne válido
		Edita( oLbx , nModo , aValores )
	EndIf
ElseIf nOpc == 1 .and. nModo == 3
	If PesqBxSE5( cSigla )
		RecLock( "cArqTmp" , .F. , .T. )
		dbDelete()
		If oLbx != Nil
			oLbx:Refresh()
		EndIf
	Else
		Help( " " , 1 , "NODELETA" ,,,,,,,,,, { STR0019 } )
	EndIf
Endif

If nOpc == 1 .and. __lLimMot
	//Limpa variável static __aMotRead do fonte matxfunb.prx para carregamento do array novamente
	LimMotRead()
End

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PesqBxSE5 ³ Autor ³ Daniel Mendes    ³ Data ³18.10.2016    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se existe movimentação na SE5 com o motivo de BX  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ PesqBxSE5( "DEB" )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cMotBx = Motivo de baixa                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA490     ³ Functoin Edita()                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PesqBxSE5( cMotBx )
Local lRet := .T.
Local cSQL := ""
Local aArea := GetArea()

//SE5 - Movimentação bancária
cSQL := GetNextAlias()

BeginSQL Alias cSQL
	SELECT COUNT( E5_MOTBX ) QTD
	FROM %Table:SE5% E5
	WHERE E5.E5_MOTBX = %Exp:cMotBx%
	   AND E5.%NotDel% 
EndSQL

lRet := (cSQL)->QTD == 0
(cSQL)->( dbCloseArea() )

//FK1 - Baixas a receber
If lRet
	cSQL := GetNextAlias()
	
	BeginSQL Alias cSQL
		SELECT COUNT( FK1_MOTBX ) QTD
		  FROM %Table:FK1% FK1
		 WHERE FK1.FK1_MOTBX = %Exp:cMotBx%
		   AND FK1.%NotDel% 
	EndSQL
	
	lRet := (cSQL)->QTD == 0
	(cSQL)->( dbCloseArea() )
EndIf

//FK2 - Baixas a pagar
If lRet
	cSQL := GetNextAlias()

	BeginSQL Alias cSQL
		SELECT COUNT( FK2_MOTBX ) QTD
		  FROM %Table:FK2% FK2
		 WHERE FK2.FK2_MOTBX = %Exp:cMotBx%
		   AND FK2.%NotDel% 
	EndSQL

	lRet := (cSQL)->QTD == 0
	(cSQL)->( dbCloseArea() )
EndIf

RestArea(aArea)

Return lRet
