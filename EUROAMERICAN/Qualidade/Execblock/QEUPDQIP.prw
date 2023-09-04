#include "parmtype.ch"
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"
#include "Colors.ch"
#include "RwMake.ch"

/*/{Protheus.doc} QEUPDQIP rotina para gravar de datas de facrição e vencimento tabela PAY
//ajuste de datas de facrição e vencimento de acordo com o laudo
@Autor Fabio Carneiro 
@since 06/10/2022
@version 1.0
@type user function 
/*/

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

User Function QEUPDQIP()

Local aSays        := {}
Local aButtons     := {}
Local cTitoDlg     := "Ajusta os laudos na tabela auxiliar em relação a data de fabricação e validade - EURO "
Local nOpca        := 0
Private _cPerg     := "QEXPDIP"
Private aPlanilha  := {}

aAdd(aSays, "Rotina para gravar a data de Fabricação e Validade na tabela PAY - Tabela Auxiliar ")

aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

FormBatch(cTitoDlg, aSays, aButtons)

If nOpca == 1
	
	oAjustaSx1()

	If !Pergunte(_cPerg,.T.)
		Return
	Else 
		MontaDir("C:\TOTVS\")
		Processa({|| QEUPDQIPok("Gerando carga de dados, aguarde...")})
	Endif
		
EndIf

Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEUPDQIPok| Autor: | EURO          | Data: | 27/06/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEMNTQIPok                                   |
+------------+-----------------------------------------------------------+
*/

Static Function QEUPDQIPok()

Local cArqDst          := "C:\TOTVS\QEUPDQIP_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
Local oExcel           := FWMsExcelEX():New()
Local cPlan            := "Empresa_" + Rtrim(SM0->M0_CODIGO) + "_Filial_" + Rtrim(SM0->M0_CODFIL)
Local cTit             := "Conferência ajuste de laudo"

Local lAbre            := .F.
Local nPlan            := 0 
Local cQuery           := ""

Local _lPassa          := .F.
Local _cOrdProd        := ""
Local cQueryA          := ""
Local _aLista          := {}
Local _nLista          := 0
Local _nCalc           := 0

oExcel:AddworkSheet(cPlan)
oExcel:AddTable(cPlan, cTit)
oExcel:AddColumn(cPlan, cTit, "Status"             , 1, 1, .F.)  //01
oExcel:AddColumn(cPlan, cTit, "Produto"            , 1, 1, .F.)  //02
oExcel:AddColumn(cPlan, cTit, "Num. Lote"          , 1, 1, .F.)  //03
oExcel:AddColumn(cPlan, cTit, "Data Fabricação"    , 1, 1, .F.)  //04
oExcel:AddColumn(cPlan, cTit, "Data Validade"      , 1, 1, .F.)  //05

If Select("TRBP") > 0
	TRBP->(DbCloseArea())
EndIf

cQuery := "SELECT ZD_LOTE, ZD_PRODUT, ZD_OP, ZD_DTFABR, ZD_DTVALID, ZD_DATA, ZD_CODANAL  " + CRLF
cQuery += "FROM "+RetSqlName("SZD")+" AS SZD WITH (NOLOCK) " + CRLF 
cQuery += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 ON ZD_PRODUT = B1_COD " + CRLF
cQuery += " AND SB1.D_E_L_E_T_ = ' '  " + CRLF
cQuery += "WHERE ZD_FILIAL = '"+xFilial("SZD")+"' " + CRLF
cQuery += " AND ZD_DATA BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' " + CRLF
cQuery += " AND SUBSTRING(ZD_PRODUT,1,3) BETWEEN '"+AllTrim(Substr(MV_PAR03,1,3))+"' AND '"+AllTrim(Substr(MV_PAR04,1,3))+"' " + CRLF
cQuery += " AND ZD_LOTE BETWEEN '"+AllTrim(MV_PAR05)+"' AND '"+AllTrim(MV_PAR06)+"' " + CRLF
cQuery += " AND SZD.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "GROUP BY ZD_LOTE, ZD_PRODUT, ZD_OP, ZD_DTFABR, ZD_DTVALID, ZD_DATA, ZD_CODANAL " + CRLF

TCQuery cQuery New Alias "TRBP"

TRBP->(DbGoTop())

While TRBP->(!Eof())

	_lPassa := .F.
	_nCalc  := 0
	_aLista := {}
	
	If AllTrim(Posicione("SB1",1,xFilial("SB1")+TRBP->ZD_PRODUT,"B1_COD")) == Alltrim(TRBP->ZD_PRODUT)
		_lPassa := .T.
	EndIf

	If _lPassa
	
		lAbre         := .T.

		If !Empty(Alltrim(TRBP->ZD_LOTE)) 

			If Select("TRB1") > 0
				TRB1->(DbCloseArea())
			EndIf

			cQueryA := "SELECT * FROM "+RetSqlName("PAY")+" AS PAY WITH (NOLOCK) "+CRLF
			cQueryA += "WHERE PAY_FILIAL = '"+xFilial("PAY")+"' "+CRLF
			cQueryA += " AND PAY_OP = '"+If(Empty(AllTrim(TRBP->ZD_OP)),AllTrim(TRBP->ZD_LOTE)+"01"+"001",AllTrim(TRBP->ZD_OP))+"' "+CRLF
			cQueryA += " AND PAY.D_E_L_E_T_ = ' ' "+CRLF 
			cQueryA += "ORDER BY PAY_LOTE  "+CRLF

			TCQuery cQueryA New Alias "TRB1"

			TRB1->(DbGoTop())

			While TRB1->(!Eof())

				Aadd(_aLista,{PAY_FILIAL,; //01
							  PAY_CTRL,;   //02 
							  PAY_SEQ,;    //03
							  PAY_PROD,;   //04
							  PAY_OP,;     //05 
							  PAY_LOTE,;   //06
							  PAY_DTFAB,;  //07
							  PAY_DTVAL,;  //08
							  PAY_HRREG,;  //09
							  PAY_DTLAUD,; //10
							  PAY_CODANL,; //11
							  PAY_STATUS}) //12

				TRB1->(DbSkip())

			EndDo
			
		EndIf

		If Len(_aLista) > 0

			For _nLista := 1 To Len(_aLista)

				DbSelectArea("PAY")
				PAY->(DbSetOrder(2)) // PAY_FILIAL+PAY_OP+PAY_PROD+PAY_CTRL
				If PAY->(dbSeek(xFilial("PAY")+_aLista[_nLista][06]+_aLista[_nLista][04])) 

					If _aLista[_nLista][06] == TRBP->ZD_LOTE

						RecLock("PAY",.F.)
						PAY->PAY_STATUS := "3"
						PAY->PAY_PROD   := Alltrim(TRBP->ZD_PRODUT)
						PAY->PAY_LOTE   := Alltrim(TRBP->ZD_LOTE)	
						PAY->PAY_DTFAB  := StoD(TRBP->ZD_DTFABR) 
						PAY->PAY_DTVAL  := StoD(TRBP->ZD_DTVALID) 
						PAY->(MsUnlock())
				
						aAdd(aPlanilha,{AllTrim("Registro Atualizado"),;   //01
												Alltrim(TRBP->ZD_PRODUT),; //02
												Alltrim(TRBP->ZD_LOTE),;   //03
									Substr(TRBP->ZD_DTFABR,7,2)+"/"+Substr(TRBP->ZD_DTFABR,5,2)+"/"+Substr(TRBP->ZD_DTFABR,1,4),;  //04
									Substr(TRBP->ZD_DTVALID,7,2)+"/"+Substr(TRBP->ZD_DTVALID,5,2)+"/"+Substr(TRBP->ZD_DTVALID,1,4)}) //05	     
					EndIf

				Else 

					DbSelectArea("PAY")
					RecLock("PAY",.T.)
					PAY->PAY_FILIAL := xFilial("PAY")
					PAY->PAY_CTRL   := "000001" 
					PAY->PAY_SEQ    := "001" 
					PAY->PAY_PROD   := AllTrim(TRBP->ZD_PRODUT) 
					PAY->PAY_OP     := If(Empty(AllTrim(TRBP->ZD_OP)),AllTrim(TRBP->ZD_LOTE)+"01"+"001",AllTrim(TRBP->ZD_OP))
					PAY->PAY_LOTE   := AllTrim(TRBP->ZD_LOTE)
					PAY->PAY_DTFAB  := StoD(TRBP->ZD_DTFABR) 
					PAY->PAY_DTVAL  := StoD(TRBP->ZD_DTVALID) 
					PAY->PAY_HRREG  := time() 
					PAY->PAY_STATUS := "3"
					PAY->PAY_DTLAUD := StoD(TRBP->ZD_DATA)		
					PAY->PAY_CODANL := AllTrim(TRBP->ZD_CODANAL)
					PAY->(MsUnlock())

					aAdd(aPlanilha,{AllTrim("Registro Gravado"),;  //01
											   TRBP->ZD_PRODUT ,;  //02
												  TRBP->ZD_LOTE,;  //03
										Substr(TRBP->ZD_DTFABR,7,2)+"/"+Substr(TRBP->ZD_DTFABR,5,2)+"/"+Substr(TRBP->ZD_DTFABR,1,4),;  //04
										Substr(TRBP->ZD_DTVALID,7,2)+"/"+Substr(TRBP->ZD_DTVALID,5,2)+"/"+Substr(TRBP->ZD_DTVALID,1,4)}) //05	     

				EndIf
			
			Next _nLista

		Else 
						
			DbSelectArea("PAY")
			RecLock("PAY",.T.)
			PAY->PAY_FILIAL := xFilial("PAY")
			PAY->PAY_CTRL   := "000001" 
			PAY->PAY_SEQ    := "001" 
			PAY->PAY_PROD   := AllTrim(TRBP->ZD_PRODUT) 
			PAY->PAY_OP     := If(Empty(AllTrim(TRBP->ZD_OP)),AllTrim(TRBP->ZD_LOTE)+"01"+"001",AllTrim(TRBP->ZD_OP))
			PAY->PAY_LOTE   := AllTrim(TRBP->ZD_LOTE)
			PAY->PAY_DTFAB  := StoD(TRBP->ZD_DTFABR) 
			PAY->PAY_DTVAL  := StoD(TRBP->ZD_DTVALID) 
			PAY->PAY_HRREG  := time() 
			PAY->PAY_STATUS := "3"
			PAY->PAY_DTLAUD := StoD(TRBP->ZD_DATA)		
			PAY->PAY_CODANL := AllTrim(TRBP->ZD_CODANAL)
			PAY->(MsUnlock())

			aAdd(aPlanilha,{AllTrim("Registro Gravado"),;  //01
									   TRBP->ZD_PRODUT ,;  //02
										  TRBP->ZD_LOTE,;  //03
								 Substr(TRBP->ZD_DTFABR,7,2)+"/"+Substr(TRBP->ZD_DTFABR,5,2)+"/"+Substr(TRBP->ZD_DTFABR,1,4),;  //04
								 Substr(TRBP->ZD_DTVALID,7,2)+"/"+Substr(TRBP->ZD_DTVALID,5,2)+"/"+Substr(TRBP->ZD_DTVALID,1,4)}) //05	     
		
				
		EndIf

		cQry := "UPDATE "+RetSqlName("SC2")+" SET C2_DTETIQ = ZD_DTFABR, C2_XDTVALI = ZD_DTVALID, C2_DTFABR = ZD_DTFABR, C2_DTVALID = ZD_DTVALID " + CRLF
		cQry += "FROM "+RetSqlName("SC2")+" AS SC2  " + CRLF
		cQry += "INNER JOIN "+RetSqlName("SZD")+" AS SZD ON SUBSTRING(C2_FILIAL,1,2) = ZD_FILIAL  " + CRLF
		cQry += " AND C2_NUM = ZD_LOTE " + CRLF
		cQry += " AND SUBSTRING(C2_PRODUTO,1,3) = SUBSTRING(ZD_PRODUT,1,3) " + CRLF
		cQry += " AND SZD.D_E_L_E_T_ = ' ' " + CRLF
		cQry += "WHERE C2_FILIAL = '"+xFilial("SC2")+"'  " + CRLF
		cQry += " AND C2_NUM = '"+AllTrim(TRBP->ZD_LOTE)+"' " + CRLF
		cQry += " AND SUBSTRING(C2_PRODUTO,1,3) = '"+AllTrim(SUBSTR(TRBP->ZD_PRODUT,1,3))+"' " + CRLF
		cQry += " AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	
		TcSQLExec(cQry)
	
	EndIf

TRBP->(DbSkip())

	IncProc("Gerando arquivo...")	

EndDo

If Len(aPlanilha) > 0

	For nPlan:=1 To Len(aPlanilha)
			
		lAbre := .T.

		oExcel:AddRow(cPlan,cTit,{aPlanilha[nPlan][01],;
								  aPlanilha[nPlan][02],;
								  aPlanilha[nPlan][03],;
								  aPlanilha[nPlan][04],;
								  aPlanilha[nPlan][05]}) 
	Next nPlan

EndIf

If lAbre

	oExcel:Activate()
	oExcel:GetXMLFile(cArqDst)
	OPENXML(cArqDst)
	oExcel:DeActivate()

Else

	MsgInfo("Não existe dados para serem impressos.", "SEM DADOS")

EndIf

If Select("TRBP") > 0
	TRBP->(DbCloseArea())
EndIf
If Select("TRBI") > 0
	TRBI->(DbCloseArea())
EndIf
If Select("SZD") > 0
	SZD->(DbCloseArea())
EndIf
If Select("PAY") > 0
	PAY->(DbCloseArea())
EndIf

Return

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | OPENXML   | Autor: | EURO          | Data: | 27/06/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - OPENXML                                      |
+------------+-----------------------------------------------------------+
*/

Static Function OPENXML(cArq)
	Local cDirDocs := MsDocPath()
	Local cPath	   := AllTrim(GetTempPath())

	If !ApOleClient("MsExcel")
		Aviso("Atencao", "O Microsoft Excel nao esta instalado.", {"Ok"}, 2)
	Else
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(cArq)
		oExcelApp:SetVisible(.T.)
		oExcelApp:Destroy()
	EndIf
Return

/*
+------------+------------+--------+---------------+-------+--------------+
| Programa:  | oAjustaSx1 | Autor: | QUALY         | Data: | 27/06/22     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - Perguntas                                     |
+------------+------------------------------------------------------------+
*/
Static Function oAjustaSx1()

Local _aPerg  := {}  // aRRAY 
Local _ni

Aadd(_aPerg,{"Data Emissao De....?","mv_ch1","D",08,"G","mv_par01","","","","","","","","",0})
Aadd(_aPerg,{"Data Emissao Até ..?","mv_ch2","D",08,"G","mv_par02","","","","","","","","",0})

Aadd(_aPerg,{"Cod. Produto De ...?","mv_ch3","C",15,"G","mv_par03","","","","","","SB1","","",0})
Aadd(_aPerg,{"Cod. Produto Até ..?","mv_ch4","C",15,"G","mv_par04","","","","","","SB1","","",0})

Aadd(_aPerg,{"Cod. Lote De ......?","mv_ch5","C",10,"G","mv_par05","","","","","","SZD","","",0})
Aadd(_aPerg,{"Cod. Lote Até .....?","mv_ch6","C",10,"G","mv_par06","","","","","","SZD","","",0})


dbSelectArea("SX1")
For _ni := 1 To Len(_aPerg)
	If !dbSeek(_cPerg+ SPACE( LEN(SX1->X1_GRUPO) - LEN(_cPerg))+StrZero(_ni,2))
		RecLock("SX1",.T.)
		SX1->X1_GRUPO    := _cPerg
		SX1->X1_ORDEM    := StrZero(_ni,2)
		SX1->X1_PERGUNT  := _aPerg[_ni][1]
		SX1->X1_VARIAVL  := _aPerg[_ni][2]
		SX1->X1_TIPO     := _aPerg[_ni][3]
		SX1->X1_TAMANHO  := _aPerg[_ni][4]
		SX1->X1_GSC      := _aPerg[_ni][5]
		SX1->X1_VAR01    := _aPerg[_ni][6]
		SX1->X1_DEF01    := _aPerg[_ni][7]
		SX1->X1_DEF02    := _aPerg[_ni][8]
		SX1->X1_DEF03    := _aPerg[_ni][9]
		SX1->X1_DEF04    := _aPerg[_ni][10]
		SX1->X1_DEF05    := _aPerg[_ni][11]
		SX1->X1_F3       := _aPerg[_ni][12]
		SX1->X1_CNT01    := _aPerg[_ni][13]
		SX1->X1_VALID    := _aPerg[_ni][14]
		SX1->X1_DECIMAL  := _aPerg[_ni][15]
		MsUnLock()
	EndIf
Next _ni

Return
// fim
