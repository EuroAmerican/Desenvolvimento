#include "parmtype.ch"
#include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"
#include "Colors.ch"
#include "RwMake.ch"

/*/{Protheus.doc} QEZER001
Grava QUANTIDADE ZERO na tabela SB7 
@Autor Fabio Carneiro 
@since 26/11/2022
@version 1.0
@type user function 
/*/

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

User Function QEZER001()

Local aSays       := {}
Local aButtons    := {}
Local cTitoDlg    := "Grava quantidade zero na digitação do invetário de produtos com saldo !!! "
Local nOpca       := 0

Private lAbre     := .F.
Private aPlanilha := {}
Private _aCodSB1  := {}
Private _cPerg    := "QEZERT1"
Private _lPermite := GetMv("QE_ZERINV")

aAdd(aSays, "Rotina para zerar o saldo dos produtos em estoque pelo inventário!!!")
aAdd(aSays, "Serão listados somente produtos com saldo em estoque!")
aAdd(aSays, "Esta rotina ira tratar produtos que não Controlam lote/Endereço!")

aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

FormBatch(cTitoDlg, aSays, aButtons)

If nOpca == 1
	
	oAjustaSx1()

	If !Pergunte(_cPerg,.T.)
		Return
	Else 
		If _lPermite 
			MontaDir("C:\TOTVS\")
			Processa({|| QEZERMNTok()}, "Atualizando digitação do inventário...")
		Else 
			Aviso('EQZER001','Rotina não Autorizada a Executar, Abrir Chamado para o uso desta rotina!',{'OK'})
			Return
		EndIf	
	Endif
		
EndIf

Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QECUSMNTok| Autor: | QUALY         | Data: | 08/08/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEEXPMNTok                                   |
+------------+-----------------------------------------------------------+
*/
Static Function QEZERMNTok() 

Local cArqDst    := "C:\TOTVS\QESB7ZERO1_EMP_" + SM0->M0_CODIGO + "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
Local oExcel     := FWMsExcelEX():New()
Local nPlan      := 0
Local cNomPla    := "Empresa_1" + Rtrim(SM0->M0_NOME)
Local cTitPla    := "QEZER001 - Relatorio Conferência do Inventário com quantidade Zero na Data "+Substr(DtoS(MV_PAR07),7,2)+"/"+Substr(DtoS(MV_PAR07),5,2)+"/"+Substr(DtoS(MV_PAR07),1,4)+" "
Local cNomWrk    := "Empresa_1" + Rtrim(SM0->M0_NOME)
Local lAbre      := .F.
Local cQuery     := ""
Local cQuery1    := ""
Local _aPassa    := {}
Local _nY        := 0
Local _cLocaliz  := ""
Local _cLote     := ""
Local _cStatus   := ""

MakeDir("C:\TOTVS")

oExcel:AddworkSheet(cNomWrk)
oExcel:AddTable(cNomPla,  cTitPla)
oExcel:AddColumn(cNomPla, cTitPla, "Status do registro" , 1, 1, .F.)     //01
oExcel:AddColumn(cNomPla, cTitPla, "Filial"             , 1, 1, .F.)     //02
oExcel:AddColumn(cNomPla, cTitPla, "Numero Doc."        , 1, 1, .F.)     //03
oExcel:AddColumn(cNomPla, cTitPla, "Codgo Produto"      , 1, 1, .F.)     //04
oExcel:AddColumn(cNomPla, cTitPla, "Descrição produto"  , 1, 1, .F.)     //05
oExcel:AddColumn(cNomPla, cTitPla, "Tipo Produto"       , 1, 1, .F.)     //06
oExcel:AddColumn(cNomPla, cTitPla, "Unidade Medida"     , 1, 1, .F.)     //07
oExcel:AddColumn(cNomPla, cTitPla, "Armazen"            , 1, 1, .F.)     //08
oExcel:AddColumn(cNomPla, cTitPla, "Qtd Antes Invent."  , 3, 2, .F.)     //09
oExcel:AddColumn(cNomPla, cTitPla, "Numero Contagem"    , 1, 1, .F.)     //10
oExcel:AddColumn(cNomPla, cTitPla, "Data Inventario"    , 1, 1, .F.)     //11
oExcel:AddColumn(cNomPla, cTitPla, "Status Qtd invent." , 1, 1, .F.)     //12
oExcel:AddColumn(cNomPla, cTitPla, "Controla Lote?"     , 1, 1, .F.)     //13
oExcel:AddColumn(cNomPla, cTitPla, "Controla Endereço?" , 1, 1, .F.)     //14
oExcel:AddColumn(cNomPla, cTitPla, "Produto Bloqueado?" , 1, 1, .F.)     //15
oExcel:AddColumn(cNomPla, cTitPla, "Produto Empenhado?" , 1, 1, .F.)     //16
oExcel:AddColumn(cNomPla, cTitPla, "Status Inventário?" , 1, 1, .F.)     //17
/*
+--------------------------------+
| QUERY REFERENTE OS MOVIMENTOS  |
+--------------------------------+
*/
ProcRegua(RecCount()-Recno())

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf

cQuery := "SELECT B2_COD, B1_DESC,B1_TIPO, B1_UM, B2_LOCAL, B2_QATU, B2_QEMP, B2_RESERVA, B2_QACLASS, B2_QEMPSA, B2_QPEDVEN, B2_SALPEDI, B1_UM, " + CRLF
cQuery += "B1_RASTRO, B1_LOCALIZ, B1_MSBLQL " + CRLF
cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
cQuery += "  AND B1_COD = B2_COD " + CRLF
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " AS SBZ ON BZ_FILIAL = B2_FILIAL " + CRLF
cQuery += "  AND BZ_COD = B2_COD " + CRLF
cQuery += "  AND SBZ.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
cQuery += "AND B2_COD BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' " + CRLF
cQuery += "AND B1_TIPO BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' " + CRLF
cQuery += "AND B2_LOCAL BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' " + CRLF
cQuery += "AND B2_QATU <> 0 " + CRLF
cQuery += "AND B1_RASTRO = 'N' " + CRLF
cQuery += "AND NOT B1_TIPO IN ('MO') " + CRLF
cQuery += "AND ((BZ_LOCALIZ IS NULL AND B1_LOCALIZ = 'N') OR (BZ_LOCALIZ = 'N')) " + CRLF
cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "ORDER BY B2_LOCAL, B2_COD  " + CRLF

TCQuery cQuery New Alias "TRB1"

TRB1->(DbGoTop())

While TRB1->(!Eof())

	_cStatus   := ""
	_aPassa    := {}
	_nY        := 0

	Incproc("Atualizando registro de Inventário: " + TRB1->B2_COD )
	
	If TRB1->B1_RASTRO <> "L" .And. TRB1->B1_LOCALIZ <> "S" 
	
		DbSelectArea("SB1")
		DbSetOrder(1)
		If SB1->( dbSeek( xFilial("SB1") + TRB1->B2_COD ) )

			If Select("TRBK") > 0
				TRBK->(DbCloseArea())
			EndIf

			cQuery1 := "SELECT * FROM " + RetSqlName("SB7") + " AS SB7 " + CRLF
			cQuery1 += "WHERE B7_FILIAL = '" + xFilial("SB7") + "' " + CRLF 
			cQuery1 += "AND B7_DOC   = 'DOCZERV1' " + CRLF
			cQuery1 += "AND B7_COD   = '"+TRB1->B2_COD+"' " + CRLF
			cQuery1 += "AND B7_LOCAL = '"+TRB1->B2_LOCAL+"' " + CRLF
			cQuery1 += "AND B7_DATA = '"+Dtos(MV_PAR07)+"' " + CRLF
			cQuery1 += "AND SB7.D_E_L_E_T_ = ' '  " + CRLF

			TCQuery cQuery1 New Alias "TRBK"

			TRBK->(DbGoTop())

			While TRBK->(!Eof())

				Aadd(_aPassa,{TRBK->B7_DATA,;   //01
							  TRBK->B7_COD,;    //02
							  TRBK->B7_LOCAL,;  //03 
							  TRBK->B7_LOCALIZ,;//04
							  TRBK->B7_NUMSERI,;//05
							  TRBK->B7_LOTECTL,;//06
							  TRBK->B7_NUMLOTE,;//07
							  TRBK->B7_CONTAGE,;//08
							  TRBK->B7_DOC,;    //09
							  TRBK->B7_STATUS}) //10

				TRBK->(DbSkip())

			EndDo 

			If len(_aPassa) > 0

				lAbre := .T.

				For _nY := 1 To len(_aPassa) 
				
					DbSelectArea("SB7")
					DbSetOrder(1)
					If SB7->(dbSeek(xFilial("SB7")+_aPassa[_nY][01]+_aPassa[_nY][02]+_aPassa[_nY][03]+_aPassa[_nY][04]+_aPassa[_nY][05]+_aPassa[_nY][06]+_aPassa[_nY][07]+_aPassa[_nY][08]))

						lAbre := .T.

						_cStatus := "Registro Já Existe"
						
						aAdd(aPlanilha,{_cStatus,;        //01
								AllTrim(xFilial("SB7")),; //02 
								_aPassa[_nY][09],;        //03    
								AllTrim(TRB1->B2_COD),;   //04    
								AllTrim(TRB1->B1_DESC),;  //05
								AllTrim(TRB1->B1_TIPO),;  //06
								AllTrim(TRB1->B1_UM),;    //07
								AllTrim(TRB1->B2_LOCAL),; //08    	
								TRB1->B2_QATU,;           //09 	
								_aPassa[_nY][08],; //10
								Substr(DtoS(MV_PAR07),7,2)+"/"+Substr(DtoS(MV_PAR07),5,2)+"/"+Substr(DtoS(MV_PAR07),1,4),; //11
								"Quant. Zero",;  //12
								If(TRB1->B1_RASTRO=="L","Sim","Não"),;  //13
								If(TRB1->B1_LOCALIZ=="S","Sim","Não"),; //14
								If(TRB1->B1_MSBLQL=="1","Sim","Não"),;  //15 
								If(TRB1->B2_QEMP > 0 ,"Sim","Não"),;    //16
								If(_aPassa[_nY][10]=="1","Não Processado","Processado")}) //17

					Else 

						RecLock("SB7", .T.)

						SB7->B7_FILIAL  := xFilial("SB7")
						SB7->B7_DOC     := "DOCZERV1"
						SB7->B7_COD     := TRB1->B2_COD
						SB7->B7_TIPO    := TRB1->B1_TIPO
						SB7->B7_QUANT   := 0
						SB7->B7_QTSEGUM := 0
						SB7->B7_STATUS  := "1"
						SB7->B7_LOCAL   := TRB1->B2_LOCAL
						SB7->B7_LOTECTL := _cLote
						SB7->B7_LOCALIZ := _cLocaliz
						SB7->B7_CONTAGE := "001"  
						SB7->B7_ORIGEM  := "MATA270"
						SB7->B7_DATA    := MV_PAR07

						SB7->(MsUnLock())

						_cStatus := "Registro Novo Incluido"
							
						aAdd(aPlanilha,{_cStatus,;        //01
								AllTrim(xFilial("SB7")),; //02
								"DOCZERV1",;              //03     
								AllTrim(TRB1->B2_COD),;   //04    
								AllTrim(TRB1->B1_DESC),;  //05
								AllTrim(TRB1->B1_TIPO),;  //06
								AllTrim(TRB1->B1_UM),;    //07
								AllTrim(TRB1->B2_LOCAL),; //08    	
								TRB1->B2_QATU,;           //09 	
								"001",; //10
								Substr(DtoS(MV_PAR07),7,2)+"/"+Substr(DtoS(MV_PAR07),5,2)+"/"+Substr(DtoS(MV_PAR07),1,4),; //11
								"Quant. Zero",;  //12
								If(TRB1->B1_RASTRO=="L","Sim","Não"),;  //13
								If(TRB1->B1_LOCALIZ=="S","Sim","Não"),; //14
								If(TRB1->B1_MSBLQL=="1","Sim","Não"),;  //15 
								If(TRB1->B2_QEMP > 0 ,"Sim","Não"),;    //16
								"Não Processado"}) //17	
					EndIf
				
				Next _nY
			
			Else 

				lAbre := .T.

				RecLock("SB7", .T.)

				SB7->B7_FILIAL  := xFilial("SB7")
				SB7->B7_DOC     := "DOCZERV1"
				SB7->B7_COD     := TRB1->B2_COD
				SB7->B7_TIPO    := TRB1->B1_TIPO
				SB7->B7_QUANT   := 0
				SB7->B7_QTSEGUM := 0
				SB7->B7_STATUS  := "1"
				SB7->B7_LOCAL   := TRB1->B2_LOCAL
				SB7->B7_LOTECTL := _cLote
				SB7->B7_LOCALIZ := _cLocaliz
				SB7->B7_CONTAGE := "001"  
				SB7->B7_ORIGEM  := "MATA270"
				SB7->B7_DATA    := MV_PAR07

				SB7->(MsUnLock())

				_cStatus := "Registro Novo Incluido"
					
				aAdd(aPlanilha,{_cStatus,;        //01
						AllTrim(xFilial("SB7")),; //02
						"DOCZERV1",;              //03     
						AllTrim(TRB1->B2_COD),;   //04    
						AllTrim(TRB1->B1_DESC),;  //05
						AllTrim(TRB1->B1_TIPO),;  //06
						AllTrim(TRB1->B1_UM),;    //07
						AllTrim(TRB1->B2_LOCAL),; //08    	
						TRB1->B2_QATU,;           //09 	
						"001",; //10
						Substr(DtoS(MV_PAR07),7,2)+"/"+Substr(DtoS(MV_PAR07),5,2)+"/"+Substr(DtoS(MV_PAR07),1,4),; //11
						"Quant. Zero",;  //12
						If(TRB1->B1_RASTRO=="L","Sim","Não"),;  //13
						If(TRB1->B1_LOCALIZ=="S","Sim","Não"),; //14
						If(TRB1->B1_MSBLQL=="1","Sim","Não"),;  //15 
						If(TRB1->B2_QEMP > 0 ,"Sim","Não"),;    //16
						"Não Processado"}) //17	
			EndIf

		EndIf

	EndIf

	TRB1->(DbSkip())

EndDo 

For nPlan:=1 To Len(aPlanilha)
		
	lAbre := .T.

	oExcel:AddRow(cNomPla,cTitPla,{aPlanilha[nPlan][01],;
								   aPlanilha[nPlan][02],;
								   aPlanilha[nPlan][03],;
								   aPlanilha[nPlan][04],;
								   aPlanilha[nPlan][05],;
								   aPlanilha[nPlan][06],;
								   aPlanilha[nPlan][07],;
								   aPlanilha[nPlan][08],;
								   aPlanilha[nPlan][09],;
								   aPlanilha[nPlan][10],;
								   aPlanilha[nPlan][11],;
								   aPlanilha[nPlan][12],;
								   aPlanilha[nPlan][13],;
								   aPlanilha[nPlan][14],;
								   aPlanilha[nPlan][15],;
								   aPlanilha[nPlan][16],;
								   aPlanilha[nPlan][17]}) 
Next nPlan

If lAbre
	oExcel:Activate()
	oExcel:GetXMLFile(cArqDst)
	OPENXML(cArqDst)
	oExcel:DeActivate()
Else
		MsgInfo("Não existe dados para serem impressos.", "SEM DADOS")
EndIf

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf
If Select("TRBK") > 0
	TRBK->(DbCloseArea())
EndIf

Return 
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | OPENXML   | Autor: | QUALY         | Data: | 13/02/21     |
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
| Programa:  | oAjustaSx1 | Autor: | QUALY         | Data: | 13/02/21     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - Perguntas                                     |
+------------+------------------------------------------------------------+
*/
Static Function oAjustaSx1()

Local _aPerg  := {}  // aRRAY 
Local _ni

Aadd(_aPerg,{"Produto De ........?","mv_ch1","C",15,"G","mv_par01","","","","","","SB1","","",0})
Aadd(_aPerg,{"Produto Até........?","mv_ch2","C",15,"G","mv_par02","","","","","","SB1","","",0})
Aadd(_aPerg,{"Tipo Produto De ...?","mv_ch3","C",02,"G","mv_par03","","","","","","02","","",0})
Aadd(_aPerg,{"Tipo Produto Até...?","mv_ch4","C",02,"G","mv_par04","","","","","","02","","",0})
Aadd(_aPerg,{"Armazen De ........?","mv_ch5","C",02,"G","mv_par05","","","","","","NNR","","",0})
Aadd(_aPerg,{"Armazen Até........?","mv_ch6","C",02,"G","mv_par06","","","","","","NNR","","",0})
Aadd(_aPerg,{"Data Inventário....?","mv_ch7","D",08,"G","mv_par07","","","","","","","","",0})

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

