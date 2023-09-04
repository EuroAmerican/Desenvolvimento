#include "Colors.ch"
#include "Protheus.ch"
#include "RwMake.ch"
#Include "TOPCONN.CH" 
#Include "FWMVCDEF.CH"

#define ENTER chr(13) + chr(10)

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEEXPVNC  | Autor: |Fabio Carneiro | Data: | 28/05/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Invenmtario de Lotes Vencidos                             |
+------------+-----------------------------------------------------------+
| Uso:       | QUALY - Fabio Carneiro dos Santos                         |
+------------+-----------------------------------------------------------+
*/
User Function QEEXPVNC() 
                         
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

Define MsDialog oDlg1 From 000,000  TO 015,060 Title OemToAnsi("Acerta Lotes Vencidos - GRUPO AUROAMERICAN") 
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

	            SFSD5(Ajj)

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

Processa({|| QESD501ok("Gerando relatório...")})
	
fclose(_nHdl)                          

Return                   
                                               
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | SFSD5     | Autor: |Fabio Carneiro | Data: | 10/11/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Grava linha por linha do arquivo após delimitador (;)     |
+------------+-----------------------------------------------------------+
| Uso:       | QUALY / EURO                                              |
+------------+-----------------------------------------------------------+
*/

Static Function SFSD5(ALINHA)

Local _cLocal    := ""
Local _cLote     := ""
Local cQuery     := ""
Local cQueryG    := ""
Local lAbre      := .F.
Local _cArmaz    := GetMv("QE_ARMAZ")
Local _cTipProd  := GetMv("QE_TIPPROD")
Local _nPrzLote  := GetMv("QE_PRZLOTE")
Local dDataVal   := ""
Local _dDataNew  := ""
Local _cFilial   := ""
Local _cProduto  := ""
Local _cDesc     := ""
Local _cTipo     := ""
Local _cUnid     := ""
Local _dDataVal  := ""
Local _cCtrlLot  := ""
Local _cCtrlEnd  := ""
Local _nSaldo    := 0
Local _nEmpenho  := 0
Local _nLista    := 0

Local _aDados    := {}
Local _aCabec    := {} 

Private lMsErroAuto := .F.
Private TRB1        := GetNextAlias()

// Leitura da Linha para Gravar o Codigo na base de dados

_cFilial   := StrTran(Alinha[1][01],";","")
_cProduto  := StrTran(Alinha[1][02],";","")
_cDesc     := StrTran(Alinha[1][03],";","")      
_cTipo     := StrTran(Alinha[1][04],";","")
_cLocal    := StrTran(Alinha[1][05],";","") 
_cUnid     := StrTran(Alinha[1][06],";","")
_cLote     := StrTran(Alinha[1][07],";","")
_cLocaliz  := StrTran(Alinha[1][08],";","")
_dDataVal  := StrTran(Alinha[1][09],";","")
_nSaldo    := Val(StrTran(StrTran(Alinha[1][10],";",""),",", "."))
_nEmpenho  := Val(StrTran(StrTran(Alinha[1][11],";",""),",", "."))
_cCtrlLot  := StrTran(Alinha[1][12],";","")
_cCtrlEnd  := StrTran(Alinha[1][13],";","")

nLidos++

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf

cQuery := "SELECT B8_FILIAL AS FILIAL, B8_PRODUTO AS PRODUTO, B1_DESC AS DESCRI, B1_TIPO AS TIPO, B8_LOCAL AS ARMAZEN, B1_UM AS UM, B1_TIPO AS TIPOPROD,  " +ENTER 
cQuery += " B8_LOTECTL AS LOTE, B8_DTVALID AS VALID,'' AS LOCALIZ ,B8_SALDO AS SALDO, B8_EMPENHO AS EMPENHO, B1_RASTRO AS RASTRO, B1_LOCALIZ AS CTRLEND " +ENTER  
cQuery += "FROM " + RetSqlName("SB8") + " AS SB8 " +ENTER  
cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 ON B1_FILIAL = ' '  " +ENTER  
cQuery += " AND B1_COD = B8_PRODUTO " +ENTER  
cQuery += " AND SB1.D_E_L_E_T_ = ' '  " +ENTER  
cQuery += "WHERE B8_FILIAL =  '"+xFilial("SB8")+"' " +ENTER  
cQuery += " AND SB8.B8_PRODUTO = '"+AllTrim(_cProduto)+"' "+ ENTER
cQuery += " AND SB8.B8_LOCAL = '"+AllTrim(_cArmaz)+"' "+ ENTER
cQuery += " AND B8_DTVALID <= '"+Dtos(dDatabase)+"'  " +ENTER  
cQuery += " AND B8_SALDO > 0   " +ENTER  
cQuery += " AND SB8.D_E_L_E_T_ = ' '  " +ENTER  
	
TcQuery cQuery ALIAS "TRB1" NEW
	
TRB1->(DbGoTop())

While TRB1->(!Eof())

	If TRB1->TIPOPROD $ _cTipProd

		dDataVal   := Substr(TRB1->VALID,7,2)+"/"+Substr(TRB1->VALID,5,2)+"/"+Substr(TRB1->VALID,1,4)
		_dDataNew  := Substr(Dtos(dDatabase+_nPrzLote),7,2)+"/"+Substr(Dtos(dDatabase+_nPrzLote),5,2)+"/"+Substr(Dtos(dDatabase+_nPrzLote),1,4)
				
		_cFilial   := TRB1->FILIAL 
		_cProduto  := TRB1->PRODUTO 
		_cDesc     := TRB1->DESCRI      
		_cTipo     := TRB1->TIPO 
		_cLocal    := TRB1->ARMAZEN 
		_cUnid     := TRB1->UM                       
		_cLote     := TRB1->LOTE
		_cLocaliz  := TRB1->LOCALIZ
		_dDataVal  := dDataVal
		_nSaldo    := TRB1->SALDO 
		_nEmpenho  := TRB1->EMPENHO
		_cCtrlLot  := If(TRB1->RASTRO == "S","Sim","Não")
		_cCtrlEnd  := If(TRB1->CTRLEND == "L","Sim","Não")

		If Select("TRB3") > 0
			TRB3->(DbCloseArea())
		EndIf

		cQueryG  := "SELECT D5_FILIAL, D5_PRODUTO, D5_LOCAL, D5_LOTECTL, D5_NUMLOTE, D5_NUMSEQ, B8_SALDO, B8_EMPENHO, " + ENTER
		cQueryG  += " B8_LOTECTL, B8_NUMLOTE, B8_DTVALID " + ENTER
		cQueryG  += "FROM " + RetSqlName("SD5") + " AS SD5  " + ENTER
		cQueryG  += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_COD = D5_PRODUTO " + ENTER 
		cQueryG  += " AND SB1.D_E_L_E_T_ = ' ' " + ENTER 
		cQueryG  += "INNER JOIN " + RetSqlName("SB8") + " AS SB8 ON B8_FILIAL = D5_FILIAL " + ENTER 
		cQueryG  += " AND B8_PRODUTO = D5_PRODUTO " + ENTER 
		cQueryG  += " AND B8_LOTECTL = D5_LOTECTL " + ENTER 
		cQueryG  += " AND SB8.D_E_L_E_T_ = ' '  " + ENTER 
		cQueryG  += "WHERE D5_FILIAL = '"+xFilial("SD5")+"' " + ENTER 
		cQueryG  += " AND D5_PRODUTO  = '"+_cProduto+"'  " + ENTER
		cQueryG  += " AND D5_LOTECTL  = '"+_clote+"'  " + ENTER
		cQueryG  += " AND D5_LOCAL = '"+_cLocal+"' " + ENTER
		cQueryG  += " AND B8_SALDO > 0 " + ENTER
		cQueryG  += " AND SD5.D_E_L_E_T_ = ' ' " + ENTER
		cQueryG  += "ORDER BY SD5.R_E_C_N_O_ DESC  " + ENTER

		TcQuery cQueryG ALIAS "TRB3" NEW
				
		TRB3->(DbGoTop())

		While TRB3->(!Eof())

			DbSelectArea("SB8")
			DbSelectArea("SD5")
			SD5->(DbSetOrder(2)) // D5_FILIAL+D5_PRODUTO+D5_LOCAL+D5_LOTECTL+D5_NUMLOTE+D5_NUMSEQ
			If SD5->(dbSeek(xFilial("SD5")+TRB3->D5_PRODUTO+TRB3->D5_LOCAL+TRB3->D5_LOTECTL+TRB3->D5_NUMLOTE+TRB3->D5_NUMSEQ))  

				Begin Transaction               
					
					_aCabec := {}  

					aadd(_aCabec,{"D5_PRODUTO",TRB3->D5_PRODUTO,NIL})       
					aadd(_aCabec,{"D5_LOCAL"  ,TRB3->D5_LOCAL  ,NIL})     
					aadd(_aCabec,{"D5_LOTECTL",TRB3->D5_LOTECTL,NIL})      
					aadd(_aCabec,{"D5_NUMLOTE",TRB3->D5_NUMLOTE,NIL})
					aadd(_aCabec,{"D5_NUMSEQ" ,TRB3->D5_NUMSEQ ,NIL})
					aadd(_aCabec,{"B8_DTVALID",dDatabase+_nPrzLote,NIL})                                

					MSExecAuto({|x,y| mata390(x,y)},_aCabec,4)               

					If lMsErroAuto         
						DisarmTransaction()
					Else 
						nRecs++	
						lAbre := .T.
					EndIf       

				End Transaction
			
			EndIf
			
			TRB3->(DbSkip())

		EndDo

		If lAbre
		
			Aadd(_aDados,{_cFilial,;
						_cProduto,;
						_cDesc,;
						_cTipo,;
						_cLocal,;
						_cUnid,;
						_cLote,;
						_dDataVal,;
						_dDataNew})
		EndIf
	
	EndIf

	TRB1->(DbSkip())

EndDo

If Len(_aDados) > 0 

	For _nLista:=1 To Len(_aDados)

		Aadd(aPlanilha,{_aDados[_nLista][01],;
						_aDados[_nLista][02],;
		      			_aDados[_nLista][03],;
		      			_aDados[_nLista][04],;
		      			_aDados[_nLista][05],;
		      			_aDados[_nLista][06],;
		      			_aDados[_nLista][07],;
	      			    _aDados[_nLista][08],;
						_aDados[_nLista][09]}) 

	Next _nLista
	
EndIf	

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf
If Select("TRB3") > 0
	TRB3->(DbCloseArea())
EndIf
If Select("SD5") > 0
	SD5->(DbCloseArea())
EndIf
If Select("SB8") > 0
	SB8->(DbCloseArea())
EndIf

Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QESD501oK | Autor: | QUALY         | Data: | 28/05/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QESD501ok                                    |
+------------+-----------------------------------------------------------+
*/
Static Function QESD501ok()

	Local cArqDst     := "C:\TOTVS\QEVNCLOT_EMP_" + SM0->M0_CODIGO + "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel      := FWMsExcelEX():New()
		
	Local nPlan       := 0
	
	Local cNomPla     := "Empresa_1" + Rtrim(SM0->M0_NOME)
	Local cTitPla     := "Relatorio conferencia de produtos baixados por meio da carga de dados "
	Local cNomWrk     := "Empresa_1" + Rtrim(SM0->M0_NOME)
		
	MakeDir("C:\TOTVS")

	oExcel:AddworkSheet(cNomWrk)
	oExcel:AddTable(cNomPla,  cTitPla)
	oExcel:AddColumn(cNomPla, cTitPla, "Filial"             , 1, 1, .F.)     //01
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo Produto"     , 1, 1, .F.)     //02
	oExcel:AddColumn(cNomPla, cTitPla, "Descrição Produto"  , 1, 1, .F.)     //03
	oExcel:AddColumn(cNomPla, cTitPla, "Tipo Produto"       , 1, 1, .F.)     //04
	oExcel:AddColumn(cNomPla, cTitPla, "Unidade medida"     , 1, 1, .F.)     //05
	oExcel:AddColumn(cNomPla, cTitPla, "Armazém"            , 1, 1, .F.)     //06
	oExcel:AddColumn(cNomPla, cTitPla, "Lote"               , 1, 1, .F.)     //07
	oExcel:AddColumn(cNomPla, cTitPla, "Validade Atual"     , 1, 1, .F.)     //08
	oExcel:AddColumn(cNomPla, cTitPla, "Nova Validade"      , 1, 1, .F.)     //09

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
									   aPlanilha[nPlan][08],;
									   aPlanilha[nPlan][09]}) 
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






