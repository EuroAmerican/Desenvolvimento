#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwprintsetup.ch'
#include 'rptdef.ch'
#include 'totvs.ch'

#define ENTER chr(13) + chr(10)

/*/{Protheus.doc} rfat005
//Relatorio pra pre-separacao de estoque.
@author epaiva
@since 20/07/2018
@version 1.0
@type function
/*/
User Function rfat005()
	Local aSays    := {}
	Local aButtons := {}
	Local aHelpPor := {}
	Local nOpca    := 0
	Local cTitoDlg := "Romaneio de Expedição - ESPELHO"

	Local cQry
	Local cFilePDF
	Local nRegSM0 := SM0->(RecNo())

	Local aArea		:= GetArea()
	Local aAreaSZF	:= SZF->( GetArea() )

	Private oFont14 := TFont():New("Arial",,-14,.F.)
	Private oFont14n:= TFont():New("Arial",,-14,.T.)
	Private oFont10 := TFont():New("Courier New",,-10,.F.)
	Private oFont10n:= TFont():New("Courier New",,-10,.T.)

	Private oPrint
	Private nLin := 0

	SM0->(DbSetOrder(1))

	cQry := "SELECT SZF.ZF_NUM AS Numero, " + ENTER
	cQry += "		SZF.ZF_VEICULO Veiculo, " + ENTER
	//cQry += "       SZF.ZF_EMISSAO EMISSAO," + ENTER
	cQry += "		DA3.DA3_TRANSP Transp, " + ENTER
	cQry += "		SA4.A4_NOME AS Nome, " + ENTER
	cQry += "		SZG.ZG_ITEM Item, " + ENTER
	cQry += "		SZF.ZF_FRETEP FPrevis, " + ENTER
	cQry += "		SZF.ZF_VOLUME AS VTotal, " + ENTER
	cQry += "		SZF.ZF_PESO AS PTotal, " + ENTER
	cQry += "		SZF.ZF_VALOR AS VlrTotal, " + ENTER
	cQry += "		SZG.ZG_ITEM AS Item, " + ENTER
	cQry += "		SZG.ZG_EMPFIL AS EmpFil, " + ENTER
	cQry += "		SZG.ZG_NOTA AS NF, " + ENTER
	cQry += "		SZG.ZG_SERIE AS Serie, " + ENTER

	cQry += "				( SELECT A1_NOME FROM " + RetSqlName("SA1") + " SA1 WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = ZG_EMPFIL AND SA1.A1_COD = SZG.ZG_CLIENTE AND SA1.A1_LOJA = SZG.ZG_LOJA ) AS Cliente, " + ENTER
	cQry += "		SZG.ZG_PESO AS PBruto, " + ENTER
	cQry += "		SZG.ZG_VALOR AS Valor, " + ENTER
	cQry += "		SZG.ZG_VOLUME AS Volume " + ENTER
	cQry += " FROM	" + RetSqlName("SZF") + " SZF INNER JOIN " + ENTER
	cQry += "		" + RetSqlName("SZG") + " SZG ON " + ENTER
	cQry += "		SZF.ZF_NUM = SZG.ZG_NUM INNER JOIN " + ENTER
	cQry += "		" + RetSqlName("DA3") + " DA3 ON " + ENTER
	cQry += "		SZF.ZF_VEICULO = DA3.DA3_PLACA INNER JOIN " + ENTER
	cQry += "		" + RetSqlName("SA4") + " SA4 ON " + ENTER
	cQry += "		SA4.A4_COD = DA3.DA3_TRANSP " + ENTER
	cQry += " WHERE	SZF.D_E_L_E_T_ = '' AND SZG.D_E_L_E_T_ = '' AND DA3.D_E_L_E_T_ = '' " + ENTER
	cQry += "		AND SZG.ZG_NUM = '" + SZF->ZF_NUM + "' " + ENTER
    cQry := ChangeQuery(cQry)
    DbUseArea(.T., "TOPCONN", TcGenQry(,,cQry), "TRB1", .F., .F.)


	MontaDir("C:\TEMP\")
	cFilePDF := "ROMANEIO_" + Alltrim(SZF->ZF_NUM) + ".PDF"
	fErase("C:\TEMP\" + cFilePDF)
	oPrinter := FWMSPrinter():New(cFilePdf, IMP_PDF, .F., "C:\TEMP\", .T.,,,,,,,.F.,)
	oPrinter:SetPortrait()
	oPrinter:SetPaperSize(9)
	oPrinter:SetDevice(IMP_PDF)
	oPrinter:cPathPDF :="C:\TEMP\"

	//impressão cabec
	U_rfat05c()
	nLin := 120

	While TRB1->(!Eof())
		If nLin > 800  //Quebra de pagina
			//Imprime rodape
			oPrinter:Line(800,10,800,585)
			oPrinter:EndPage()
			oPrinter:StartPage()
			rfat05c()
			nLin := 140
		EndIf
		SM0->(DbSeek(Alltrim(TRB1->EMPFIL), .F.))

		cString := SubStr(TRB1->ITEM, 1, 2) + " - " + SubStr(Alltrim(SM0->M0_NOME), 1, 10) + " - "
		cString += TRB1->NF + " - " + TRB1->SERIE + "   - " + SubStr(TRB1->CLIENTE, 1, 20) + " - "
		cString += TransForm(TRB1->PBRUTO, "@E 9,999,999.99") + " - "
		cString += TransForm(TRB1->VALOR, "@E 9,999,999.99") + " - "
		cString += TRB1->VOLUME

		oPrinter:Say(nLin, 10, cString, oFont10)

		/*oPrinter:Say(nLin, 10, SubStr(TRB1->ITEM, 1, 2) + " - " + SubStr(Alltrim(SM0->M0_NOME), 1, 10) + " - ", oFont10)
		oPrinter:Say(nLin, 85, TRB1->NF + " - " + TRB1->SERIE + "   - " + SubStr(TRB1->CLIENTE, 1, 20) + " - ", oFont10)
		oPrinter:Say(nLin, 290, TransForm(TRB1->PBRUTO, "@E 9,999,999.99") + " - ", oFont10)
		oPrinter:Say(nLin, 350, TransForm(TRB1->VALOR, "@E 9,999,999.99") + " - ", oFont10)
		oPrinter:Say(nLin, 420, TRB1->VOLUME, oFont10)*/
		nLin += 15

		TRB1->(DbSkip())
	EndDo
	oPrinter:Line(nLin,10,nLin,585)
	nLin += 20
	oPrinter:Say(nLin, 12, "Conferente..: ______________________________________________________", oFont14n)
	nLin += 20
	oPrinter:Say(nLin, 12, "Motorista....: ______________________________________________________", oFont14n)
	nLin += 20
	oPrinter:Say(nLin, 12, "Patrimonial.: ______________________________________________________", oFont14n)

	oPrinter:EndPage()
	oPrinter:Preview()
	FreeObj(oPrinter)
	oPrinter := Nil

	nRet := ShellExecute("Open", "C:\TEMP\ROMANEIO_" + Alltrim(SZF->ZF_NUM) + ".PDF", "", "C:\TEMP\", 3)
	If nRet <= 32
		Aviso("Atenção", "Não foi possível abrir o arquivo, instalar um leitor de arquivo PDF", {"Ok"}, 2)
	EndIf

	TRB1->(DbCloseArea())
	SM0->(DbGoTo(nRegSM0))
	//SZF->(DBCLOSEAREA())

	Return

User Function rfat05c()
	oPrinter:StartPage()
	oPrinter:Box(10, 10, 830, 585)  //moldura
	nLin := 25
	oPrinter:Say(nLin, 20, "Romaneio: " + TRB1->NUMERO, oFont14n)
	oPrinter:Say(nLin, 150,"Veiculo: " + TRB1->VEICULO, oFont14n)
	
	//---------- FABIO BATISTA 24/01/2021 -----------------
	If !SELECT("SZF")>0
		DBSELECTAREA("SZF") 
	EndIf
	SZF->(DBSETORDER(1))
	SZF->(DBGOTOP())
	If SZF->(DbSeek(xFilial("SZF")+TRB1->NUMERO))
		oPrinter:Say(nLin, 330,"Emissão: " + DTOC(SZF->ZF_EMISSAO), oFont14n)
	Else 
		oPrinter:Say(nLin, 330,"Emissão: __/__/____" , oFont14n)
	EndIf 
	//------------ Fabio Batista ---------------------------

	nLin += 20

	oPrinter:Say(nLin, 20, "Nome Transp: " + TRB1->NOME, oFont14n)
	nLin += 20

	//oPrinter:Say(nLin, 20, "Frete Previsto: " + TransForm(TRB1->FPREVIS, "@E 9,999,999.99"), oFont14n)
	//nLin += 20

	oPrinter:Say(nLin, 20, "Volume Total: " + TRB1->VTOTAL, oFont14n)
	nLin += 20

	oPrinter:Say(nLin, 20, "Pes.Bruto: " + TransForm(TRB1->PTOTAL, "@E 999,999.99"), oFont14n)
	oPrinter:Say(nLin, 150,"Valor Total: " + TransForm(TRB1->VLRTOTAL, "@E 999,999.99"), oFont14n)
	nLin += 10
	oPrinter:Line(nLin,10,nLin,585)
	nLin += 10

	oPrinter:Say(nLin, 10, "IT - Empresa    - NFiscal   - Serie - Razao Social         - Peso Bruto   - Vlr.Total  - Volume/Especie", oFont10n)

	Return
