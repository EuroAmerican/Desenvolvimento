#include "Colors.ch"
#include "Protheus.ch"
#include "RwMake.ch"
#Include "TOPCONN.CH" 
#Include "FWMVCDEF.CH"

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEIUNEXP  | Autor: |Fabio Carneiro | Data: | 10/02/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descri��o: | Atualiza PERCENTUAL DE COMISS�O                           |
+------------+-----------------------------------------------------------+
| Uso:       | QUALY                                                     |
+------------+-----------------------------------------------------------+
*/
User Function QEIMPCOM() 
                         
Local oDlg1

Private nRecs	    := 0
Private nLidos	    := 0
Private lAbre       := .F.
Private aPlanilha   := {}
Private _aCodSB1    := {}

Private mv_par01    := space(90) // diret�rio + arquivo a ser migrado

Private aCampos_    := {} // campos do cabecalho
Private lEnd        := .F.

DEFINE FONT 	oBold NAME "Times New Roman"	SIZE 0,  20
DEFINE FONT 	oFnt  NAME "Arial"				SIZE 0, -14 BOLD	// "Times New Roman"

Define MsDialog oDlg1 From 000,000  TO 015,060 Title OemToAnsi("Atualiza Percentual de Comiss�o - QUALY") 
@ 003,005 TO 090,230

@ 001,002 Say OemToAnsi("Informe o Arquivo para importar .TXT|CSV")	Font oBold	Color CLR_HRED     

@ 035,015 Say OemToAnsi("Arquivo a ser Migrado:")				 			OF oDlg1 PIXEL	Color CLR_HBLUE     
@ 035,070 MsGet MV_PAR01 Picture "@s15"			OF oDlg1 PIXEL	Valid .t. F3 "DIR"
@ 090,140 Button OemToAnsi("_OK")	Size 40,15 Action (OkLeTxt(),oDlg1:End())
@ 090,190 Button OemToAnsi("_Sair   ")	Size 40,15 Action Close(oDlg1)
@ 090,002 Say OemToAnsi("DAVISO") Font oFnt	Color CLR_GRAY

Activate MSDialog oDlg1 Centered
Return

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | OkLeTxt   | Autor: |Fabio Carneiro | Data: | 04/02/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descri��o: | Le o arquivo TXT                                          |
+------------+-----------------------------------------------------------+
| Uso:       | QUALY / EURO                                              |
+------------+-----------------------------------------------------------+
*/

Static Function OkLeTxt()

LOCAL CULT	:= "000000"
local cnball	:= "00"

Private _nHdl    := fOpen(mv_par01,68) 

Private cEOL    := "CHR(13)+CHR(10)"
Private _nNum	:= 40
Private _nULT	:= 0
Private _cAtual	:= "N"
Private _nnBall	:= 0

//Close(oDlg1)

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
Local _nBytesLidos	:=_nRegLidos:=0
Local _cSaldoLinha	:= ""
Local _nTamBloco	:= 50000 // Largura a ser lida a cada acesso a disco
Local _nBytesTrat	:= 0
Local _cMen2		:= ""
Local _cSaldoLin	:= ""                        
local x := u := colini := tamcol := 0
Local ajj    := {}
local coluna := {}
LOCAL NRECX  := 0     

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

	            SFSB1(Ajj)

	     EndIf
          _nRegLidos++
          _nBytesTrat+=len(_cRegistro)
       else
          _cSaldoLin:=_cLinha
          _cLinha:=""
       endif         
    enddo   
enddo           

Aviso("Aten��o !!!" ,"Registros Lidos ..: "+ Str(nLidos) +" Gravados ..: "+ Str(nRecs),{"OK"})

Processa({|| QESB101ok("Gerando relat�rio...")})
	
fclose(_nHdl)                          

Return                   
                                               
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | SFSB1     | Autor: |Fabio Carneiro | Data: | 10/11/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descri��o: | Grava linha por linha do arquivo ap�s delimitador (;)     |
+------------+-----------------------------------------------------------+
| Uso:       | QUALY / EURO                                              |
+------------+-----------------------------------------------------------+
*/

Static Function SFSB1(ALINHA)

Local _cQueryA     := "" 
Local _cQueryB     := "" 
Local _cQueryC     := "" 

Local _lPassa1    := .T.
Local _lPassa2    := .T.
Local _aLidos     := {}
Local _nLidos     := 0
Local _cStatus    := ""
Local _cRev       := ""
// Variaveis do Produto 

Local _cPAACOD    := ""
Local _cPAAREV    := ""
Local _cPAADSCLIN := ""
Local _nPAACOMIS1 := 0
Local _cDtaVig1   := CTOD("  /  /  ")     
Local _cDtaVig2   := CTOD("  /  /  ")   

// Leitura da Linha para Gravar o Codigo na base de dados

_cPAACOD    := StrTran(Alinha[1][01],";","")
_cPAAREV    := StrTran(Alinha[1][02],";","")
_cPAATAB    := StrTran(Alinha[1][03],";","")
_cPAADSCLIN := StrTran(Alinha[1][04],";","")
_cDtaVig1	:= CTOD(StrTran(Alinha[1][05],";",""))
_cDtaVig2 	:= CTOD(StrTran(Alinha[1][06],";",""))
_nPAACOMIS1 := Val(StrTran(StrTran(Alinha[1][07],";",""),",", "."))

If Select("WK_SB1") > 0
	WK_SB1->(DbCloseArea())
EndIf

_cQueryA := "SELECT B1_FILIAL, B1_COD, B1_DESC ,B1_UM, B1_SEGUM, B1_PESO, B1_PESBRU, B1_XREVCOM, B1_XTABCOM FROM "+RetSqlName("SB1")+" SB1 "
_cQueryA += " WHERE B1_FILIAL = '"+xFilial("SB1")+"' "
_cQueryA += " AND B1_COD = '"+AllTrim(_cPAACOD)+"' "
_cQueryA += " AND SB1.D_E_L_E_T_ = ' '  "

TcQuery _cQueryA ALIAS "WK_SB1" NEW

nLidos++

DbSelectArea("SB1")
SB1->(DbSetOrder(1))
SB1->(DbGoTop())
If SB1->(DbSeek(xFilial("SB1")+WK_SB1->B1_COD))  

	If AllTrim(Posicione("SB1",1, xFilial("SB1")+_cPAACOD,"B1_COD")) == AllTrim(_cPAACOD)
		_lPassa1   := .T.
	Else 
		_lPassa1   := .F.
		_cStatus := "Resgistro N�o Encontrado"
	EndIf 
		
	If _lPassa1  
	
		If Select("WK_PAA") > 0
			WK_PAA->(DbCloseArea())
		EndIf

		_cQueryB := "SELECT * FROM "+RetSqlName("PAA")+" AS PAA "
		_cQueryB += "WHERE PAA_FILIAL = '"+xFilial("PAA")+"' ""
		_cQueryB += " AND PAA_COD = '"+AllTrim(_cPAACOD)+"'  " 
		_cQueryB += " AND PAA_REV = '"+AllTrim(_cPAAREV)+"'  " 
		_cQueryB += " AND PAA.D_E_L_E_T_ = ' ' " 
		_cQueryB += " ORDER BY  PAA_DTVIG1, PAA_DTVIG2 " 

		TcQuery _cQueryB ALIAS "WK_PAA" NEW

		WK_PAA->(DbGoTop())

		While WK_PAA->(!Eof())
			
			Aadd(_aLidos,{WK_PAA->PAA_COD,WK_PAA->PAA_CODTAB,WK_PAA->PAA_REV})

			WK_PAA->(DbSkip())

		EndDo

		If Len(_aLidos) > 0

			For _nLidos:= 1 To Len(_aLidos) 
			
				DbSelectArea("PAA")
				PAA->(DbSetorder(1))
				PAA->(DbGotop())
				If PAA->(DbSeek(xFilial("PAA")+_aLidos[_nLidos][01]+_aLidos[_nLidos][02]+_aLidos[_nLidos][03]))    
					_cStatus := "Resgistro J� Existe"
				Endif 

			Next _nLidos 	

			aAdd(aPlanilha,{_cStatus,;
						AllTrim(_nPAAREV),;
						AllTrim(AllTrim(_cPAACOD) ),;
						AllTrim(Posicione("SB1",1,xFilial("SB1")+_cPAACOD,"B1_DESC")),;
						AllTrim(Posicione("SB1",1,xFilial("SB1")+_cPAACOD,"B1_TIPO")),;
						AllTrim(Posicione("SB1",1,xFilial("SB1")+_cPAACOD,"B1_GRUPO")),;
						AllTrim(Posicione("SBM",1,xFilial("SBM")+AllTrim(Posicione("SB1",1, xFilial("SB1")+_cPAACOD,"B1_GRUPO")),"BM_DESC")),;
						_cPAADSCLIN,; 
						_cDtaVig1,; 
						_cDtaVig2,;
						TransForm(_nPAACOMIS1,"@E 999.99" )})

		Else

			If Select("W1_PAB") > 0
				W1_PAB->(DbCloseArea())
			EndIf

			_cQueryC := "SELECT MAX(PAA_REV) AS REV FROM "+RetSqlName("PAA")+" AS PAA "
			_cQueryC += "WHERE PAA_FILIAL = '"+xFilial("PAA")+"' ""
			_cQueryC += " AND PAA_COD = '"+AllTrim(_cPAACOD)+"' "
			_cQueryC += " AND PAA.D_E_L_E_T_ = ' ' " 

			TcQuery _cQueryC ALIAS "W1_PAB" NEW

			W1_PAB->(DbGoTop())

			While W1_PAB->(!Eof())
			
				_cRev := W1_PAB->REV

				W1_PAB->(DbSkip())

			EndDo
			
			DbSelectArea("PAA")
			RecLock("PAA",.T.)
											
			PAA->PAA_FILIAL := XFilial("PAA") 
			PAA->PAA_CODTAB := If(Alltrim(_cPAATAB) == "000001","000001","000001")
			PAA->PAA_REV    := If(Empty(_cRev),"001",StrZero(Val(_cRev)+1,3))    
			PAA->PAA_COD    := Alltrim(_cPAACOD)     
			PAA->PAA_DESC   := AllTrim(Posicione("SB1",1, xFilial("SB1")+_cPAACOD,"B1_DESC"))   
			PAA->PAA_TIPO   := AllTrim(Posicione("SB1",1, xFilial("SB1")+_cPAACOD,"B1_TIPO"))  
			PAA->PAA_GRUPO  := AllTrim(Posicione("SB1",1, xFilial("SB1")+_cPAACOD,"B1_GRUPO")) 
			PAA->PAA_DSCGRP := AllTrim(Posicione("SBM",1, xFilial("SBM")+AllTrim(Posicione("SB1",1, xFilial("SB1")+_cPAACOD,"B1_GRUPO")),"BM_DESC"))
			PAA->PAA_FAMILI := AllTrim(Posicione("SB1",1, xFilial("SB1")+_cPAACOD,"B1_XFAMILI"))
			PAA->PAA_DSCFAM := AllTrim(Posicione("ZZZ",1, xFilial("ZZZ")+AllTrim(Posicione("SB1",1, xFilial("SB1")+_cPAACOD,"B1_XFAMILI")),"ZZZ_DESCFA"))
			PAA->PAA_SUBFAM := AllTrim(Posicione("SB1",1, xFilial("SB1")+_cPAACOD,"B1_XSUBFAM"))
			PAA->PAA_DSCSFM := AllTrim(Posicione("ZZX",1, xFilial("ZZX")+AllTrim(Posicione("SB1",1, xFilial("SB1")+_cPAACOD,"B1_XSUBFAM")),"ZZX_DESCSU"))
			PAA->PAA_LINHA  := SubStr(_cPAACOD,1,4)   
			PAA->PAA_DSCLIN := _cPAADSCLIN  
			PAA->PAA_MSBLQL := "2" 
			PAA->PAA_DTCARG :=  DDATABASE
			PAA->PAA_DTVIG1 := _cDtaVig1 
			PAA->PAA_DTVIG2 := _cDtaVig2  
			PAA->PAA_COMIS1 := _nPAACOMIS1 
			PAA->PAA_COMIS2 := 0 
			PAA->PAA_COMIS3 := 0 
			PAA->PAA_COMIS4 := 0
			PAA->PAA_COMIS5 := 0 
								
			PAA->(MsUnlock())

			SB1->(DbSetOrder(1))
			SB1->(DbGoTop())
			If SB1->(DbSeek(xFilial("SB1")+WK_SB1->B1_COD))  
				RecLock("SB1",.F.)
				SB1->B1_COMIS   := _nPAACOMIS1
				SB1->B1_XREVCOM := If(Empty(_cRev),"001",StrZero(Val(_cRev)+1,3))
				SB1->B1_XTABCOM := If(Alltrim(_cPAATAB) == "000001","000001","000001")
				SB1->(MsUnlock())
			EndIf

			_cStatus := "Resgistro Gravado"

			aAdd(aPlanilha,{_cStatus,;
							AllTrim(If(Empty(_cRev),"001",StrZero(Val(_cRev)+1,3))),;
							AllTrim(AllTrim(_cPAACOD) ),;
							AllTrim(Posicione("SB1",1,xFilial("SB1")+_cPAACOD,"B1_DESC")),;
							AllTrim(Posicione("SB1",1,xFilial("SB1")+_cPAACOD,"B1_TIPO")),;
							AllTrim(Posicione("SB1",1,xFilial("SB1")+_cPAACOD,"B1_GRUPO")),;
							AllTrim(Posicione("SBM",1,xFilial("SBM")+AllTrim(Posicione("SB1",1, xFilial("SB1")+_cPAACOD,"B1_GRUPO")),"BM_DESC")),;
							_cPAADSCLIN,; 
							_cDtaVig1,; 
							_cDtaVig2,;
							TransForm(_nPAACOMIS1,"@E 999.99" )})

							nRecs++	
		
		EndIf
	
	Else 

		aAdd(aPlanilha,{_cStatus,;
						AllTrim(_nPAAREV),;
						AllTrim(AllTrim(_cPAACOD) ),;
						AllTrim(Posicione("SB1",1,xFilial("SB1")+_cPAACOD,"B1_DESC")),;
						AllTrim(Posicione("SB1",1,xFilial("SB1")+_cPAACOD,"B1_TIPO")),;
						AllTrim(Posicione("SB1",1,xFilial("SB1")+_cPAACOD,"B1_GRUPO")),;
						AllTrim(Posicione("SBM",1,xFilial("SBM")+AllTrim(Posicione("SB1",1, xFilial("SB1")+_cPAACOD,"B1_GRUPO")),"BM_DESC")),;
						_cPAADSCLIN,; 
						_cDtaVig1,; 
						_cDtaVig2,;
						TransForm(_nPAACOMIS1,"@E 999.99" )})
	
	Endif 

EndIf

If Select("WK_SB1") > 0
	WK_SB1->(DbCloseArea())
EndIf
If Select("WK_PAA") > 0
	WK_PAA->(DbCloseArea())
EndIf
If Select("W1_PAB") > 0
	W1_PAB->(DbCloseArea())
EndIf
If Select("SB1") > 0
	SB1->(DbCloseArea())
EndIf

Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QESB101oK | Autor: | QUALY         | Data: | 29/07/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descri��o: | Manuten��o - QESB101ok                                    |
+------------+-----------------------------------------------------------+
*/
Static Function QESB101ok()

	Local cArqDst     := "C:\TOTVS\QEPAACOM_EMP_" + SM0->M0_CODIGO + "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel      := FWMsExcelEX():New()
		
	Local nPlan       := 0
	
	Local cNomPla     := "Empresa_1" + Rtrim(SM0->M0_NOME)
	Local cTitPla     := "Relatorio conferencia de carga de dados "
	Local cNomWrk     := "Empresa_1" + Rtrim(SM0->M0_NOME)
		
	MakeDir("C:\TOTVS")

	oExcel:AddworkSheet(cNomWrk)
	oExcel:AddTable(cNomPla,  cTitPla)
	oExcel:AddColumn(cNomPla, cTitPla, "Status do registro"       , 1, 1, .F.)     //01
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo Revisao"           , 1, 1, .F.)     //02
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo Produto"           , 1, 1, .F.)     //03
	oExcel:AddColumn(cNomPla, cTitPla, "Descri��o Produto"        , 1, 1, .F.)     //04
	oExcel:AddColumn(cNomPla, cTitPla, "tipo"                     , 1, 1, .F.)     //05
	oExcel:AddColumn(cNomPla, cTitPla, "Grupo"                    , 1, 1, .F.)     //06
	oExcel:AddColumn(cNomPla, cTitPla, "Descri��o Grupo"          , 1, 1, .F.)     //07
	oExcel:AddColumn(cNomPla, cTitPla, "Descri��o Linha"          , 1, 1, .F.)     //08
	oExcel:AddColumn(cNomPla, cTitPla, "Data Vig. Inicial"        , 1, 1, .F.)     //09
	oExcel:AddColumn(cNomPla, cTitPla, "Data Vig. Final"          , 1, 1, .F.)     //10
	oExcel:AddColumn(cNomPla, cTitPla, "Comiss�o 1"               , 3, 2, .F.)     //11

	// preenche as informa��es na planilha de acordo com o Array aPlanilha 
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
									   aPlanilha[nPlan][11]}) 
    Next nPlan

If lAbre
	oExcel:Activate()
	oExcel:GetXMLFile(cArqDst)
	OPENXML(cArqDst)
	oExcel:DeActivate()
Else
		MsgInfo("N�o existe dados para serem impressos.", "SEM DADOS")
EndIf

Return

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | OPENXML   | Autor: | QUALY         | Data: | 13/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descri��o: | Manuten��o - OPENXML                                      |
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






