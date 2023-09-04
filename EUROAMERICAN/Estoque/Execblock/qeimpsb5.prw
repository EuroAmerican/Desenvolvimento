#Include "Colors.ch"
#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TOPCONN.CH"

#define ENTER chr(13) + chr(10)

/*/{Protheus.doc} QEIMPSB5
//importação dos codigos GTIN/DIPI
@author Fábio Carneiro
@since 08/08/2022
@version 1.0
@type function
/*/

User Function QEIMPSB5() 
                         
Local oDlg1

Private nRecs	    := 0
Private nLidos	    := 0
Private lAbre       := .F.
Private aPlanilha   := {}

Private _aCodNcm := {}

Private mv_par01 := space(90) // diretório + arquivo a ser migrado

Private aCampos_ := {} // campos do cabecalho
Private lEnd := .F.

DEFINE FONT 	oBold NAME "Times New Roman"	SIZE 0,  20
DEFINE FONT 	oFnt  NAME "Arial"				SIZE 0, -14 BOLD	// "Times New Roman"

Define MsDialog oDlg1 From 000,000  TO 015,060 Title OemToAnsi("Importacao pra carga da tabela SB5") 
@ 003,005 TO 090,230

@ 001,002 Say OemToAnsi("Informe o Arquivo para importar .TXT")	Font oBold	Color CLR_HRED     

@ 035,015 Say OemToAnsi("Arquivo a ser Migrado:")				 			OF oDlg1 PIXEL	Color CLR_HBLUE     
@ 035,070 MsGet MV_PAR01 Picture "@s15"			OF oDlg1 PIXEL	Valid .t. F3 "DIR"
@ 090,140 Button OemToAnsi("_OK")	Size 40,15 Action (OkLeTxt(),oDlg1:End())
@ 090,190 Button OemToAnsi("_Sair   ")	Size 40,15 Action Close(oDlg1)
@ 090,002 Say OemToAnsi("DAVISO") Font oFnt	Color CLR_GRAY

Activate MSDialog oDlg1 Centered
Return

/*
Static Function OkLeTxt
*/

Static Function OkLeTxt

LOCAL CULT	:= "000000"
local cnball	:= "00"

Private _nHdl    := fOpen(mv_par01,68) 

Private cEOL    := "CHR(13)+CHR(10)"
Private _nNum	:= 40
Private _nULT	:= 0
Private _cAtual	:= "N"
Private _nnBall	:= 0

If Empty(cEOL)
     cEOL := CHR(13)+CHR(10)
Else
     cEOL := Trim(cEOL)
     cEOL := &cEOL
Endif

If _nHdl == -1
     MsgAlert("O arquivo de nome "+alltrim(mv_par01)+" nao pode ser aberto! Verifique os parametros.","Atencao!")
     Return
Endif

_nUlt := val(cult)

_nnball := val(cNBall )

Processa({|| RunCont() },"Processando...")

Return

Static Function RunCont

Local _cQuebral		:= chr(13)+chr(10)
Local _nTam			:= fseek(_nHdl,0,2)
Local _cTam			:= '/'+alltrim(str(_nTam))
Local _cHoraIni		:= time()
Local _lTemErro		:= .f.
Local _nBytesLidos	:= _RegLidos		:= 0
Local _cSaldoLinha	:= ""
Local _nTamBloco	:= 50000 // Largura a ser lida a cada acesso a disco
Local _nBytesTrat	:= 0
Local _cMen2		:= ""
Local _cSaldoLin	:= ""                        
local x := u := colini := tamcol := 0
Local ajj    := {}
local coluna := {}
LOCAL NRECX  := 0     
local _jjrec := ""

_cQuebral		:=chr(13)+chr(10)
_nTam			:=fseek(_nHdl,0,2)
_cTam			:='/'+alltrim(str(_nTam))
_cHoraIni		:=time()
_lTemErro		:=.f.
_nBytesLidos	:=_nRegLidos:=0
_cSaldoLinha	:=""
_nTamBloco		:=50000 // Largura a ser lida a cada acesso a disco
_nTamBloco		:=max(_nTamBloco,len(_cQuebral)+1)
_nTamBloco		:=min(_nTamBloco,64000)
fseek(_nHdl,0,0) // Posiciona o ponteiro no inicio do arquivo
_nBytesTrat		:=0
_cMen2			:=""
_cSaldoLin		:=""   

PROCREGUA(0)

do while _nBytesLidos<_nTam

	IncProc("Aguarde...")
	
    _cLinha:=""
    do while .t. // Le ate encontrar no minimo uma quebra de linha ou o final do arquivo
       _cLido:=space(_nTamBloco)
       _nBytesAgora:=FREAD(_nHdl,@_cLido,_nTamBloco)
       _cLinha+=_cLido
       _nBytesLidos+=_nBytesAgora
       if _nBytesLidos>=_nTam.or.at(_cQuebral,_cLinha)>0.or.len(_cLinha)>64000
          exit
       endif
    enddo

    _cRegistro:=""
    _cLinha:=_cSaldoLin+_cLinha
    _cSaldoLin:=""
    do while len(_cLinha)>0
       _nPosic:=at(_cQuebral,_cLinha)
       if _nPosic>0.or._nBytesLidos==_nTam
          _jjlin := left(_clinha,_nPosic-1) +";"
          _cRegistro:=left(_cLinha,_nPosic+len(_cQuebral)-1)
          _cLinha:=substr(_cLinha,_nPosic+len(_cQuebral))
	     tamcol := 0
	     colini := 0
	     coluna := {}              

	     aJJ	:= {}
	     

	     	     For x := 1 to Len(_jjLin) // tentando
	          If Substr(_jjlin,x,1) == ";"
	               aAdd(coluna,{colini+1,tamcol})
	               colini := x
	               tamcol := 0
	          ElSe
	               tamcol ++
	          EndIf
	     Next
	            

	     //tamcol := tamcol
	     aadd( aJJ , Array(len(coluna)) )
	     
	     for u = 1 to len(coluna)
	     	ajj[len(ajj)][u] := substr(_jjlin,coluna[u][1],coluna[u][2])
	     next        
	                 
	     nRecx ++       
	     
	     if nRecx == 1 // guarda o cabecalho para tentar entrar com o nome do campo
	     	acampos_ := ajj
	     end

	     
	     if nRecx > 1 // despreza 1 registro

	            SFSB5(Ajj)

	     EndIf
	       
          _nRegLidos++
          _nBytesTrat+=len(_cRegistro)
       else
          _cSaldoLin:=_cLinha
          _cLinha:=""
       endif         
    enddo   
enddo           

Aviso("Atenção !!!" ,"Registros Lidos ..: "+ Str(nLidos) +" Gravados ..: "+ Str(nRecs),{"OK"})

Processa({|| QESB501ok("Gerando relatório...")})
	
fclose(_nHdl)                          

Return                   
                                               
/*
Static Function SFNCM(ALINHA)
*/
Static Function SFSB5(ALINHA)

Local cQueryA   := "" 
Local cQueryB   := ""
Local cCodProd  := ""
Local nPesLiqui := 0 
Local nPesBruto := 0 
Local nValDipi  := 0 
Local lPassa    := .F.
Private aCab    := {}

Private lMsErroAuto := .F.

nLidos++

cCodProd    := StrTran(Alinha[1][01] ,";","")
nPesLiqui   := Val(StrTran(StrTran(Alinha[1][02],";",""),",", "."))
nPesBruto   := Val(StrTran(StrTran(Alinha[1][03],";",""),",", "."))
nValDipi    := Val(StrTran(StrTran(Alinha[1][04],";",""),",", "."))

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf

cQueryA := "SELECT * " + ENTER
cQueryA += " FROM " + RetSqlName("SB1") + "  AS SB1 " + ENTER
cQueryA += " WHERE SB1.B1_COD = '"+cCodProd+"' " + ENTER
cQueryA += " AND SB1.D_E_L_E_T_ = ' '  " + ENTER
cQueryA += " ORDER BY B1_COD  " + ENTER

TcQuery cQueryA ALIAS "TRB1" NEW

TRB1->(DbGoTop())
	
ProcRegua(TRB1->(LastRec()))
	
While TRB1->(!Eof())

	lAbre     := .T.
	dbSelectArea("SB5")
    dbSetOrder(1)
	SB5->(DbGoTop())
    
	If DbSeek(xFilial("SB5")+TRB1->B1_COD)

		lPassa := .T.

		SB5->(Reclock("SB5",.F.))
        
		SB5->B5_CONVDIP := nPesLiqui
		SB5->B5_UMDIPI  := "KG"
		
		SB5->(MsUnlock())

		aAdd(aPlanilha,{AllTrim("Atualizado"),;
					    AllTrim(cCodProd),;
						        nPesLiqui,;
								nPesBruto,;
								     "KG",; 
								nPesLiqui})
	
	
	ElseIf !DbSeek(xFilial("SB5")+TRB1->B1_COD) 

    	If TRB1->B1_MSBLQL = '2' 

			aCab:= {{"B5_COD"     ,TRB1->B1_COD  ,Nil},;               
					{"B5_CEME"    ,TRB1->B1_DESC ,Nil},;
					{"B5_CONVDIP" ,TRB1->B1_PESO ,Nil},;
					{"B5_UMDIPI"  ,"KG"          ,Nil},;
					{"B5_UMIND"   ,'1'           ,Nil}}    
		
			MSExecAuto({|x,y| Mata180(x,y)},aCab,3) //Inclusão 
			
			If lMsErroAuto    
				cErro:=MostraErro()
			Else 
	
				lPassa := .T.

				aAdd(aPlanilha,{AllTrim("Incluido e Atualizado"),;
									AllTrim(cCodProd),;
											nPesLiqui,;
											nPesBruto,;
												"KG",; 
											nPesLiqui})

			Endif

		Else 

			nRecs--

			aAdd(aPlanilha,{AllTrim("Registro Não Atualizado - Bloqueado "),;
		 								AllTrim(cCodProd),;
												nPesLiqui,;
												nPesBruto,;
													"KG",; 
												nPesLiqui})

		EndIf 

	EndIf

	If lPassa 

		cQueryB := "UPDATE " + RetSqlName("SB1") + " SET B1_CODGTIN = '000000000000000'  " + ENTER
		cQueryB += " FROM " + RetSqlName("SB1") + " AS SB1 " + ENTER
		cQueryB += " WHERE SB1.B1_COD = '"+TRB1->B1_COD+"'  " + ENTER
		cQueryB += " AND SB1.D_E_L_E_T_ = ' '  " + ENTER

		TCSqlExec( cQueryB )

		nRecs++

	EndIf
	
	TRB1->(DbSkip())

    IncProc("Gerando arquivo...")

EndDo

SB5->(DbCloseArea())
SB1->(DbCloseArea())
TRB1->(DbCloseArea())

Return Nil
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEPED01oK | Autor: | QUALY         | Data: | 29/07/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEPED01ok                                    |
+------------+-----------------------------------------------------------+
*/
Static Function QESB501ok()

	Local cArqDst    := "C:\TOTVS\QEIMPSB5_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel     := FWMsExcelEX():New()
	Local nPlan      := 0
	Local cPlan      := "Empresa_" + Rtrim(SM0->M0_CODIGO) + "_Filial_" + Rtrim(SM0->M0_CODFIL)
	Local cTit       := "Relatorio conferencia de carga de dados "

	MakeDir("C:\TOTVS")

	oExcel:AddworkSheet(cPlan)
	oExcel:AddTable(cPlan, cTit)
	oExcel:AddColumn(cPlan, cTit, "Status"            , 1, 1, .F.)  //01
	oExcel:AddColumn(cPlan, cTit, "Produto"           , 1, 1, .F.)  //02
	oExcel:AddColumn(cPlan, cTit, "Peso Liquido"      , 3, 2, .F.)  //03
	oExcel:AddColumn(cPlan, cTit, "Peso Bruto"        , 3, 2, .F.)  //04
	oExcel:AddColumn(cPlan, cTit, "UM Dipi"           , 1, 1, .F.)  //05
	oExcel:AddColumn(cPlan, cTit, "Cobv. Dipi"        , 3, 2, .F.)  //06

	// preenche as informações na planilha de acordo com o Array aPlanilha 
	For nPlan:=1 To Len(aPlanilha)
		
		lAbre := .T.

		oExcel:AddRow(cPlan,cTit,{aPlanilha[nPlan][01],;
									aPlanilha[nPlan][02],;
									aPlanilha[nPlan][03],;
									aPlanilha[nPlan][04],;
									aPlanilha[nPlan][05],;
									aPlanilha[nPlan][06]}) 
    Next nPlan

If lAbre
	oExcel:Activate()
	oExcel:GetXMLFile(cArqDst)
	OPENXML(cArqDst)
	oExcel:DeActivate()
Else
		MsgInfo("Não existe dados para serem impressos.", "SEM DADOS")
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






