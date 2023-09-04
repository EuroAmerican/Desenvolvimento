#include "Colors.ch"
#include "Protheus.ch"
#include "RwMake.ch"
#Include "TOPCONN.CH" 
#Include "FWMVCDEF.CH"

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEUPDSGC  | Autor: |Fabio Carneiro | Data: | 16/11/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Atualiza Segmento do cliente                              |
+------------+-----------------------------------------------------------+
| Uso:       | QUALY                                                     |
+------------+-----------------------------------------------------------+
*/
User Function QEUPDSGC() 
                         
Local oDlg1

Private nRecs	    := 0
Private nLidos	    := 0
Private lAbre       := .F.
Private aPlanilha   := {}
Private _aCodSB1    := {}

Private mv_par01    := space(90) // diretório + arquivo a ser migrado

Private aCampos_    := {} // campos do cabecalho
Private lEnd        := .F.

DEFINE FONT 	oBold NAME "Times New Roman"	SIZE 0,  20
DEFINE FONT 	oFnt  NAME "Arial"				SIZE 0, -14 BOLD	// "Times New Roman"

Define MsDialog oDlg1 From 000,000  TO 015,060 Title OemToAnsi("Atualiza codigo segmento cliente !") 
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
| Descrição: | Le o arquivo TXT                                          |
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

	            SFSA1(Ajj)

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

Processa({|| QESA101ok("Gerando relatório...")})
	
fclose(_nHdl)                          

Return                   
                                               
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | SFSB1     | Autor: |Fabio Carneiro | Data: | 10/11/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Grava linha por linha do arquivo após delimitador (;)     |
+------------+-----------------------------------------------------------+
| Uso:       | QUALY / EURO                                              |
+------------+-----------------------------------------------------------+
*/

Static Function SFSA1(ALINHA)

Local _lPassa1    := .T.
Local _lPassa2    := .T.

Local _cStatus    := " "
// Variaveis do Produto 

Local _cFILIAL     := ""
Local _cCNPJ       := ""
Local _cCODIGO     := ""
Local _cLOJA 	   := ""
Local _cNOME       := ""
Local _cCODSEG	   := ""
Local _cDESCRI	   := ""

If len(Alinha) > 0

	_cFILIAL    := StrTran(Alinha[1][01],";","")
	_cCNPJ      := StrTran(Alinha[1][02],";","")
	_cCODIGO    := StrTran(Alinha[1][03],";","")	
	_cLOJA    	:= StrTran(Alinha[1][04],";","")
	_cNOME   	:= StrTran(Alinha[1][05],";","")
	_cCODSEG	:= StrTran(Alinha[1][06],";","")
	_cDESCRI	:= StrTran(Alinha[1][07],";","")

	nLidos++

	If AllTrim(Posicione("SA1",1,_cFILIAL+_cCODIGO+_cLOJA,"A1_COD")) == AllTrim(_cCODIGO) .And.;
	AllTrim(Posicione("SA1",1,_cFILIAL+_cCODIGO+_cLOJA,"A1_LOJA")) == AllTrim(_cLOJA)	
		_lPassa1   := .T.
	Else 
		_lPassa1   := .F.
		_cStatus := "Cliente não Cadastrado"
	EndIf 

	If _lPassa1 // AOV_FILIAL+AOV_CODSEG
		If AllTrim(Posicione("AOV",1, xFilial("AOV")+_cCODSEG,"AOV_CODSEG")) == AllTrim(_cCODSEG)
			_lPassa2   := .T.
		Else 
			_lPassa2   := .F.
			_cStatus := "Codigo de Segmento Não Encontrado"
		EndIf 
	EndIf

	If _lPassa1 .And. _lPassa2  
		
		DBSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->(DbGoTop())
		If SA1->(DbSeek(_cFILIAL+_cCODIGO+_cLOJA))  
			
			RecLock("SA1",.F.)

			SA1->A1_CODSEG   := _cCODSEG      

			SA1->(MsUnlock())

			_cStatus := "Registro Atualizado"

		EndIf

		aAdd(aPlanilha,{_cStatus,;
				AllTrim(_cFILIAL),;    
				AllTrim(_cCNPJ),;      
				AllTrim(_cCODIGO),;    
				AllTrim(_cLOJA),;    	
				AllTrim(_cNOME),;   	
				AllTrim(_cCODSEG),;	
				AllTrim(_cDESCRI)})	
		nRecs++	
				
	Else 

		aAdd(aPlanilha,{_cStatus,;
				AllTrim(_cFILIAL),;    
				AllTrim(_cCNPJ),;      
				AllTrim(_cCODIGO),;    
				AllTrim(_cLOJA),;    	
				AllTrim(_cNOME),;   	
				AllTrim(_cCODSEG),;	
				AllTrim(_cDESCRI)})	
		
	EndIf 

EndIf

Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QESB101oK | Autor: | QUALY         | Data: | 29/07/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QESB101ok                                    |
+------------+-----------------------------------------------------------+
*/
Static Function QESA101ok()

	Local cArqDst     := "C:\TOTVS\QESA1SEG_EMP_" + SM0->M0_CODIGO + "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel      := FWMsExcelEX():New()
		
	Local nPlan       := 0
	
	Local cNomPla     := "Empresa_1" + Rtrim(SM0->M0_NOME)
	Local cTitPla     := "Relatorio conferencia de carga de dados "
	Local cNomWrk     := "Empresa_1" + Rtrim(SM0->M0_NOME)
		
	MakeDir("C:\TOTVS")

	oExcel:AddworkSheet(cNomWrk)
	oExcel:AddTable(cNomPla,  cTitPla)
	oExcel:AddColumn(cNomPla, cTitPla, "Status do registro" , 1, 1, .F.)     //01
	oExcel:AddColumn(cNomPla, cTitPla, "Filial"             , 1, 1, .F.)     //02
	oExcel:AddColumn(cNomPla, cTitPla, "Cnpj"               , 1, 1, .F.)     //03
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo Cliente"     , 1, 1, .F.)     //04
	oExcel:AddColumn(cNomPla, cTitPla, "Loja"               , 1, 1, .F.)     //05
	oExcel:AddColumn(cNomPla, cTitPla, "Nome Cliente"       , 1, 1, .F.)     //06
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo Segmento"    , 1, 1, .F.)     //07
	oExcel:AddColumn(cNomPla, cTitPla, "Desc. Segmento"     , 1, 1, .F.)     //08
	
	// preenche as informações na planilha de acordo com o Array aPlanilha 
	For nPlan:=1 To Len(aPlanilha)
		
		lAbre := .T.

		oExcel:AddRow(cNomPla,cTitPla,{aPlanilha[nPlan][01],;
									   aPlanilha[nPlan][02],;
									   aPlanilha[nPlan][03],;
									   aPlanilha[nPlan][04],;
									   aPlanilha[nPlan][05],;
									   aPlanilha[nPlan][06],;
									   aPlanilha[nPlan][07],;
									   aPlanilha[nPlan][08]}) 
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






