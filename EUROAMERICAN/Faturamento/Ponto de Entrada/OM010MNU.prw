#include "Totvs.ch"
#include "Colors.ch"
#include "Protheus.ch"
#include "RwMake.ch"
#Include "Fwmvcdef.ch"
#include 'parmtype.ch'
#Include "Topconn.ch" 
#Include "Tbiconn.ch"

#define ENTER chr(13) + chr(10)

/*/{Protheus.doc} OM010MNU- ponto de entrada para dar carga na planilha 
@Description: Ponto de Entrada para gravar as margens e os precos na tabela DA1,
@author Fabio Carneiro dos Santos 
@since 20/03/2020
@version 1.0
/*/
User Function OM010MNU()

aadd(aRotina,{'Geração Planilha P/ Manut. e Importação' ,'U_QeFat089()' , 0 , 3,0,NIL})
aadd(aRotina,{'Importa Tabela Preço Csv/Txt','U_QeGerA08()' , 0 , 3,0,NIL}) 
aadd(aRotina,{'Manutenção Euro Tabela Preço','U_QeFat003()' , 0 , 3,0,NIL})


Return Nil
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QeGerA08  | Autor: |Fabio Carneiro | Data: | 20/03/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Importa tabela de preço tabela DA1                        |
+------------+-----------------------------------------------------------+
| Uso:       | GRUPO EUROAMERICAN                                        |
+------------+-----------------------------------------------------------+
*/

User Function QeGerA08() 

Local oDlg1

Private nRecs	    := 0
Private nLidos	    := 0
Private lAbre       := .F.
Private aPlanilha   := {}

Private mv_par01    := space(90) // diretório + arquivo a ser migrado

Private aCampos_    := {} // campos do cabecalho
Private lEnd        := .F.

Private lMsErroAuto := .F.

DEFINE FONT 	oBold NAME "Times New Roman"	SIZE 0,  20
DEFINE FONT 	oFnt  NAME "Arial"				SIZE 0, -14 BOLD	// "Times New Roman"

Define MsDialog oDlg1 From 000,000  TO 015,060 Title OemToAnsi("Importa Tabela de Preço Com os Percentuais e Codigos - EURO") 
@ 003,005 TO 090,230

@ 001,002 Say OemToAnsi("Informe o Arquivo para importar .TXT|CSV")	Font oBold	Color CLR_HRED     

@ 035,015 Say OemToAnsi("Arquivo a ser Migrado:") OF oDlg1 PIXEL	Color CLR_HBLUE     
@ 035,070 MsGet MV_PAR01 Picture "@s15"			OF oDlg1 PIXEL	Valid .t. F3 "DIR"
@ 090,140 Button OemToAnsi("_OK")	Size 40,15 Action (OkLeTxt(),oDlg1:End())
@ 090,190 Button OemToAnsi("_Sair   ")	Size 40,15 Action Close(oDlg1)
@ 090,002 Say OemToAnsi("DAVISO") Font oFnt	Color CLR_GRAY

Activate MSDialog oDlg1 Centered
Return nil

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | OkLeTxt   | Autor: |Fabio Carneiro | Data: | 11/02/21     |
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

	            SFDA1(Ajj)

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

Processa({|| QEDA101ok("Gerando relatório...")})
	
fclose(_nHdl)                          

Return                   
                                            
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | SFDA1     | Autor: |Fabio Carneiro | Data: | 11/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Grava linha por linha do arquivo após delimitador (;)     |
+------------+-----------------------------------------------------------+
| Uso:       | QUALY / EURO                                              |
+------------+-----------------------------------------------------------+
*/
Static Function SFDA1(ALINHA)

Local _cQuery       := "" 
Local  cQuery       := "" 
Local _lPassa1      := .T.

// Variaveis da tabela 

Local _cDA1_CODTAB  := ""
Local _cDA0_DESC    := ""
Local _cDA0_VIGINI  := ""
Local _cDA0_VIGFIM  := ""
Local _cDA1_CODPRO  := ""
Local _cDA1_DESCPRO := ""
Local _cDA1_GRUPO   := ""
Local _nDA1_ZPMARG  := 0
Local _nDA1_PRCVEN  := 0

Private lAbre       := .F.


// Leitura da Linha para Gravar o Codigo na base de dados

_cDA1_CODTAB  := StrTran(Alinha[1][01],";","")
_cDA0_DESC    := StrTran(Alinha[1][02],";","")
_cDA0_VIGINI  := StrTran(Alinha[1][03],";","")
_cDA0_VIGFIM  := StrTran(Alinha[1][04],";","")
_cDA1_CODPRO  := StrTran(Alinha[1][05],";","")
_cDA1_DESCPRO := StrTran(Alinha[1][06],";","")
_cDA1_GRUPO   := StrTran(Alinha[1][07],";","")
_nDA1_ZPMARG  := Val(StrTran(StrTran(Alinha[1][08],";",""),",", "."))
_nDA1_PRCVEN  := Val(StrTran(StrTran(Alinha[1][09],";",""),",", "."))

If Select("WK_DA1") > 0
	WK_DA1->(DbCloseArea())
EndIf
	
cQuery  := " SELECT DA0_CODTAB , DA0_DESCRI, DA0_DATDE, DA0_DATATE, DA1_CODPRO, B1_DESC, B1_TIPO, DA1_GRUPO, DA1_ZPMARG, " + ENTER
cQuery  += " DA1_PRCVEN, B1_CUSTNET, DA1_ITEM " + ENTER
cQuery  += " FROM " + RetSqlName("DA0") + " AS DA0 " + ENTER
cQuery  += " INNER JOIN " + RetSqlName("DA1") + " AS DA1 WITH (NOLOCK) ON DA0_CODTAB = DA1_CODTAB " + ENTER
cQuery  += " INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '    '  " + ENTER
cQuery  += "  AND B1_COD = DA1_CODPRO " + ENTER
cQuery  += "WHERE SUBSTRING(DA1_CODTAB,1,1) = 'E' " + ENTER
cQuery  += " AND B1_COD = '"+_cDA1_CODPRO+"' " + ENTER
cQuery  += " AND DA0_CODTAB = '"+_cDA1_CODTAB+"'  " + ENTER
cQuery  += " AND B1_MSBLQL = '2'  " + ENTER
cQuery  += " AND DA0.D_E_L_E_T_ = ' '   " + ENTER
cQuery  += " AND DA1.D_E_L_E_T_ = ' '   " + ENTER
cQuery  += " AND SB1.D_E_L_E_T_ = ' '   " + ENTER
cQuery  += " GROUP BY DA0_CODTAB , DA0_DESCRI, DA0_DATDE, DA0_DATATE, DA1_CODPRO, B1_DESC, B1_TIPO, DA1_GRUPO, DA1_ZPMARG, " + ENTER
cQuery  += " DA1_PRCVEN, B1_CUSTNET, DA1_ITEM  " + ENTER

TcQuery cQuery ALIAS "WK_DA1" NEW

WK_DA1->(DbGoTop())
	
ProcRegua(WK_DA1->(LastRec()))

If !Empty(cQuery)
	
	nLidos++
	
	If AllTrim(Posicione("SB1",1, xFilial("SB1")+_cDA1_CODPRO,"B1_COD")) == AllTrim(WK_DA1->DA1_CODPRO)
        _lPassa1 := .T.
    Else 
    	_lPassa1   := .F.
    EndIf 
    
	DbSelectArea("DA1")
	DbSetOrder(2)
	If DbSeek(xFilial("DA1")+WK_DA1->DA1_CODPRO+WK_DA1->DA0_CODTAB+WK_DA1->DA1_ITEM) 
		
		If _lPassa1  
	
			RecLock("DA1",.F.)

				DA1_ZPMARG  := _nDA1_ZPMARG

	    	DA1->(MsUnlock())
		
			aAdd(aPlanilha,{"REGISTRO ALTERADO",;
									_cDA1_CODPRO,;
			  			   			AllTrim(Posicione("SB1",1, xFilial("SB1")+_cDA1_CODPRO,"B1_DESC")),;
									_cDA1_CODTAB,;
									_cDA0_DESC,;
									_nDA1_ZPMARG,;
									_nDA1_PRCVEN})

        	nRecs++	
			lAbre := .T.
		
		EndIf
	
	EndIf

	If AllTrim(Posicione("SB1",1, xFilial("SB1")+_cDA1_CODPRO,"B1_COD")) == AllTrim(_cDA1_CODPRO)
		
		If !DbSeek(xFilial("DA1")+WK_DA1->DA1_CODPRO+WK_DA1->DA0_CODTAB+WK_DA1->DA1_ITEM)  

			If Select("TRB8") > 0
				TRB8->(DbCloseArea())
			EndIf
			
			_cQuery  := "SELECT MAX(DA1_ITEM) AS ITEM FROM " + RetSqlName("DA1") + " AS DA1 " + ENTER
			_cQuery  += "WHERE DA1_CODTAB = '"+_cDA1_CODTAB+"' " + ENTER 
			_cQuery  += "AND DA1.D_E_L_E_T_ = ' ' " + ENTER

			TcQuery _cQuery ALIAS "TRB8" NEW

			TRB8->(DbGoTop())

			RecLock("DA1",.T.)

				DA1_FILIAL  := xFilial("DA1")
				DA1_ITEM    := StrZero(Val(TRB8->ITEM)+1,4)
				DA1_CODTAB  := _cDA1_CODTAB
				DA1_CODPRO  := _cDA1_CODPRO    
				DA1_GRUPO   := AllTrim(Posicione("SB1",1, xFilial("SB1")+_cDA1_CODPRO,"B1_GRUPO"))
				DA1_REFGRD  := ""                
				DA1_PRCVEN  := _nDA1_PRCVEN            
				DA1_VLRDES  := 0           
				DA1_PERDES  := 0             
				DA1_ATIVO   := '1'
				DA1_FRETE   := 0            
				DA1_ESTADO  := ""
				DA1_TPOPER  := "4"
				DA1_QTDLOT  := 999999.99           
				DA1_INDLOT  := "000000000999999.99"         
				DA1_MOEDA   := 1           
				DA1_DATVIG  := dDatabase
				DA1_ITEMGR  := ""
				DA1_ECDTEX  := ""
				DA1_ECSEQ   := ""    
				DA1_PRCMAX  := 0           
				DA1_MSEXP   := ""
				DA1_HREXPO  := ""
				DA1_COMISS  := 0         
				DA1_ZPMARG  := _nDA1_ZPMARG           
				DA1_TIPPRE  := ""

	    	DA1->(MsUnlock())
		
			aAdd(aPlanilha,{"NOVO REGISTRO",;
							_cDA1_CODPRO,;
			  			    AllTrim(Posicione("SB1",1, xFilial("SB1")+_cDA1_CODPRO,"B1_DESC")),;
							_cDA1_CODTAB,;
							_cDA0_DESC,;
							_nDA1_ZPMARG,;
							_nDA1_PRCVEN})

        	nRecs++	
			
			lAbre := .T.
		
		EndIf

	EndIf 
	
Endif

If Select("WK_DA1") > 0
	WK_DA1->(DbCloseArea())
EndIf
If Select("TRB8") > 0
	TRB8->(dbCloseArea())
EndIf
DA1->(dbCloseArea())

Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEDA101ok | Autor: | QUALY         | Data: | 13/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEDA101ok                                    |
+------------+-----------------------------------------------------------+
*/
Static Function QEDA101ok()

	Local cArqDst     := "C:\TOTVS\QETAB001_EMP_" + SM0->M0_CODIGO + "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel      := FWMsExcelEX():New()
		
	Local nPlan        := 0
	
	Local cNomPla      := "Empresa_1" + Rtrim(SM0->M0_NOME)
	Local cTitPla      := "Relatorio conferencia de carga de dados "
	Local cNomWrk      := "Empresa_1" + Rtrim(SM0->M0_NOME)
		
	MakeDir("C:\TOTVS")

	oExcel:AddworkSheet(cNomWrk)
	oExcel:AddTable(cNomPla, cTitPla)
	oExcel:AddColumn(cNomPla, cTitPla, "Status do Registro"    , 1, 1, .F.)     //01
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo Produto"        , 1, 1, .F.)     //01
	oExcel:AddColumn(cNomPla, cTitPla, "Descrição Produto"     , 1, 1, .F.)     //02
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo Tabela"         , 1, 1, .F.)     //03
	oExcel:AddColumn(cNomPla, cTitPla, "Descrição Tabela"      , 1, 1, .F.)     //04
	oExcel:AddColumn(cNomPla, cTitPla, "% Margem"              , 3, 2, .F.)     //05
	oExcel:AddColumn(cNomPla, cTitPla, "Preço Venda"           , 3, 2, .F.)     //06
		
	// preenche as informações na planilha de acordo com o Array aPlanilha 
	For nPlan:=1 To Len(aPlanilha)
		
		lAbre := .T.

		oExcel:AddRow(cNomPla,cTitPla,{aPlanilha[nPlan][01],;
									aPlanilha[nPlan][02],;
									aPlanilha[nPlan][03],;
									aPlanilha[nPlan][04],;
									aPlanilha[nPlan][05],;
									aPlanilha[nPlan][06],;
									aPlanilha[nPlan][07]}) 
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



