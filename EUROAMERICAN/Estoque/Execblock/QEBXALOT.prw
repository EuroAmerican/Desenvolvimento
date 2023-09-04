#include "Colors.ch"
#include "Protheus.ch"
#include "RwMake.ch"
#Include "TOPCONN.CH" 
#Include "FWMVCDEF.CH"

#define ENTER chr(13) + chr(10)

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEBXALOT  | Autor: |Fabio Carneiro | Data: | 27/05/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Invenmtario de Lotes Vencidos                             |
+------------+-----------------------------------------------------------+
| Uso:       | QUALY - Fabio Carneiro dos Santos                         |
+------------+-----------------------------------------------------------+
*/
User Function QEBXALOT() 
                         
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

Define MsDialog oDlg1 From 000,000  TO 015,060 Title OemToAnsi("Gera Inventario de Lotes Vencidos - QUALY") 
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

	            SFSD3(Ajj)

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

Processa({|| QESD301ok("Gerando relatório...")})
	
fclose(_nHdl)                          

Return                   
                                               
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | SFSD3     | Autor: |Fabio Carneiro | Data: | 29/05/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Grava linha por linha do arquivo após delimitador (;)     |
+------------+-----------------------------------------------------------+
| Uso:       | QUALY / EURO                                              |
+------------+-----------------------------------------------------------+
*/

Static Function SFSD3(ALINHA)

Local _aInvent  as array
Local _cArmaz    := GetMv("QE_ARMAZ")
Local _cTipProd  := GetMv("QE_TIPPROD")
Local _cMovLot   := GetMv("QE_MOVLOT")
Local _cFilial   := ""
Local _cProduto  := ""
Local _cDesc     := ""
Local _cTipo     := ""
Local _cUnid     := ""
Local _dDataVal  := ""
Local _cCtrlLot  := ""
Local _cCtrlEnd  := ""
Local _cCCusto   := ""
Local _nSaldo    := 0
Local _nEmpenho  := 0
Local _nInv      := 0
Local lPassaA    := .T.

Local _aCab1     := {}
Local _aItem     := {}
Local _aTotItem  := {}

Private lMsErroAuto := .F.
Private TRB1        := GetNextAlias()
Private TRB2        := GetNextAlias()
Private TRB3        := GetNextAlias()


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

_aInvent   := {}

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf
	
If Posicione("SB1",1, xFilial("SB1")+_cProduto,"B1_LOCALIZ") == "S" .And. Posicione("SB1",1, xFilial("SB1")+_cProduto,"B1_RASTRO") == "L" 
	cQuery  := "SELECT BF_FILIAL AS FILIAL, BF_PRODUTO AS CODIGO, B1_DESC AS DESCRI, B1_UM AS UM, B1_TIPO AS TIPO, BF_LOCAL AS ARMAZEN, BF_LOCALIZ AS LOCALIZ, " + ENTER
	cQuery  += " B8_LOTECTL AS LOTE, B8_DATA AS DATA, B8_DTVALID AS VALID, BF_QUANT AS QTDEST, BF_EMPENHO AS QTDEMP, B2_VATU1 AS VALOR, B2_CM1 AS VLCUSTO" + ENTER
Else 
	cQuery  := "SELECT B8_FILIAL AS FILIAL, B8_PRODUTO AS CODIGO, B1_DESC AS DESCRI, B1_UM AS UM, B1_TIPO AS TIPO, B8_LOCAL AS ARMAZEN, " + ENTER
	cQuery  += " B8_LOTECTL AS LOTE, B8_DATA AS DATA, B8_DTVALID AS VALID, B8_SALDO AS QTDEST, B8_EMPENHO AS QTDEMP, B2_VATU1 AS VALOR, B2_CM1 AS VLCUSTO" + ENTER
EndIf
cQuery  += " FROM " + RetSqlName("SB8") + " AS SB8 " + ENTER
cQuery  += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_COD = B8_PRODUTO " + ENTER
cQuery  += " AND SB1.D_E_L_E_T_ = ' '  " + ENTER
cQuery  += "INNER JOIN " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) ON B2_COD = B8_PRODUTO  " + ENTER
cQuery  += " AND B8_FILIAL = SB2.B2_FILIAL " + ENTER
cQuery  += " AND B8_LOCAL  = SB2.B2_LOCAL   " + ENTER
cQuery  += " AND SB2.D_E_L_E_T_ = ' '  " + ENTER
If Posicione("SB1",1, xFilial("SB1")+_cProduto,"B1_LOCALIZ") == "S"
	cQuery  += "INNER JOIN " + RetSqlName("SBF") + " AS SBF WITH (NOLOCK) ON B2_COD = BF_PRODUTO  " + ENTER
	cQuery  += " AND BF_LOTECTL = B8_LOTECTL     " + ENTER
	cQuery  += " AND BF_FILIAL  = B8_FILIAL  " + ENTER
	cQuery  += " AND BF_LOCAL   = B8_LOCAL   " + ENTER
	cQuery  += " AND SBF.D_E_L_E_T_ = ' '   " + ENTER
EndIf
cQuery  += "WHERE SB8.B8_FILIAL = '"+xFilial("SB8")+"' " + ENTER
cQuery  += "  AND B1_MSBLQL = '2' " + ENTER
cQuery  += "  AND B8_SALDO > 0 " + ENTER
cQuery  += "  AND B8_PRODUTO = '"+AllTrim(_cProduto)+"' "+ ENTER
cQuery  += "  AND B8_LOCAL   = '"+AllTrim(_cArmaz)+"' "+ ENTER
cQuery  += "  AND B8_LOTECTL = '"+AllTrim(_cLote)+"' "+ ENTER
If Posicione("SB1",1, xFilial("SB1")+_cProduto,"B1_LOCALIZ") == "S"
	cQuery  += "  AND BF_LOCALIZ = '"+AllTrim(_cLocaliz)+"' "+ ENTER
	cQuery  += "  AND SB8.D_E_L_E_T_ = ' ' " + ENTER
	cQuery  += "GROUP BY BF_FILIAL, BF_PRODUTO, B1_DESC, B1_UM, B1_TIPO, BF_LOCAL, BF_LOCALIZ, " + ENTER
	cQuery  += "B8_LOTECTL, B8_DATA, B8_DTVALID, BF_QUANT, BF_EMPENHO, B2_VATU1, B2_CM1 " + ENTER
Else
	cQuery  += "  AND SB8.D_E_L_E_T_ = ' ' " + ENTER
	cQuery  += "GROUP BY B8_FILIAL, B8_PRODUTO, B1_DESC, B1_UM, B1_TIPO, B8_LOCAL, " + ENTER
	cQuery  += "B8_LOTECTL, B8_DATA, B8_DTVALID, B8_SALDO, B8_EMPENHO, B2_VATU1, B2_CM1 " + ENTER
EndIf

TcQuery cQuery ALIAS "TRB1" NEW
	
TRB1->(DbGoTop())

While TRB1->(!Eof())

	If TRB1->TIPO $ _cTipProd 
		
		lPassaA := .T.
		
		If TRB1->QTDEMP > 0 
			lPassaA := .F.
			_cStatusA := "Resgistro Com Empenho"
		EndIf 

		If lPassaA

			_dDataVld := Substr(TRB1->VALID,07,2)+"/"+Substr(TRB1->VALID,5,2)+"/"+Substr(TRB1->VALID,1,4)

			If Posicione("SB1",1, xFilial("SB1")+_cProduto,"B1_LOCALIZ") == "S"

				aAdd(_aInvent,{TRB1->FILIAL,;    // 01
							TRB1->CODIGO,;       // 02 
							AllTrim(TRB1->DESCRI),;// 03
							TRB1->TIPO,;         // 04 
							TRB1->UM,;	   	     // 05   
							TRB1->ARMAZEN,;	     // 06 
							TRB1->LOTE,;	     // 07 
							_dDataVld,;	         // 08    
							TRB1->LOCALIZ,;      // 09
							TRB1->QTDEST,;       // 10 
							TRB1->QTDEMP,;	     // 11  
							TRB1->VLCUSTO})      // 12 
			Else 

				aAdd(_aInvent,{TRB1->FILIAL,;    // 01
							TRB1->CODIGO,;       // 02 
							AllTrim(TRB1->DESCRI),;// 03
							TRB1->TIPO,;         // 04 
							TRB1->UM,;	   	     // 05   
							TRB1->ARMAZEN,;	     // 06 
							TRB1->LOTE,;	     // 07 
							_dDataVld,;	         // 08    
							"",;                 // 09
							TRB1->QTDEST,;       // 10 
							TRB1->QTDEMP,;	     // 11  
							TRB1->VLCUSTO})      // 12 

			EndIf

		EndIf

	EndIf

	TRB1->(DbSkip())

EndDo

DbSelectArea("SD3")
DbSetOrder(1) 

If Len(_aInvent) > 0

	If cFilAnt == "0803"
		_cCCusto := "1030302"
	ElseIf cFilAnt == "0200"
		_cCCusto := "1030202"
	ElseIf cFilAnt == "0901"
		_cCCusto := "1030202"
	EndIf
	
	For _nInv:=1 To Len(_aInvent)	

		_aCab1      := {}
		_aItem      := {}
		_aTotItem   := {}
		lMsErroAuto := .F.
	
			_aCab1 := { {"D3_TM"		, _cMovLot  			, NIL},;
						{"D3_CC"   	    , _cCCusto				, NIL},;
						{"D3_EMISSAO"	, ddatabase				, NIL}}
		
			_aItem := { {"D3_COD" 		, _aInvent[_nInv][02]	,NIL},;
						{"D3_UM" 		, _aInvent[_nInv][05]	,NIL},; 
						{"D3_QUANT"		, _aInvent[_nInv][10]	,NIL},;
						{"D3_LOCAL"		, _aInvent[_nInv][06]	,NIL},;
						{"D3_LOTECTL"	, _aInvent[_nInv][07]	,NIL},;
						{"D3_LOCALIZ"   , _aInvent[_nInv][09]   ,NIL}}
			
			aAdd( _aTotItem, _aItem)
				
			MSExecAuto({|f,g,h| MATA241(f,g,h)}, _aCab1, _aTotItem, 3)

			If lMsErroAuto
				DisarmTransaction()
				_cStatus := "Não passou pelo ExecAuto"
				aAdd(aPlanilha,{_cStatus,;
							   _aInvent[_nInv][02],;
							   AllTrim(_aInvent[_nInv][03]),;
							   _aInvent[_nInv][04],;
							   _aInvent[_nInv][05],;
							   _aInvent[_nInv][06],;
							   _aInvent[_nInv][07],;
							   _aInvent[_nInv][08],;
							   _aInvent[_nInv][09],;
							   AllTrim(TransForm(_aInvent[_nInv][10],"@E 9,999,999.99")),;
							   AllTrim(TransForm(_aInvent[_nInv][12],"@E 9,999,999.99"))})
			Else 

				nRecs++	
				_cStatus := "Resgistro Baixado"
				aAdd(aPlanilha,{_cStatus,;
							   _aInvent[_nInv][02],;
							   AllTrim(_aInvent[_nInv][03]),;
							   _aInvent[_nInv][04],;
							   _aInvent[_nInv][05],;
							   _aInvent[_nInv][06],;
							   _aInvent[_nInv][07],;
							   _aInvent[_nInv][08],;
							   _aInvent[_nInv][09],;
							   AllTrim(TransForm(_aInvent[_nInv][10],"@E 9,999,999.99")),;
							   AllTrim(TransForm(_aInvent[_nInv][12],"@E 9,999,999.99"))})
			EndIf

	Next _nInv				

Else

	_cStatus := "Resgistro Não Encontrado"
				aAdd(aPlanilha,{_cStatus,;
							   AllTrim(_cProduto),;
							   AllTrim(Posicione("SB1",1, xFilial("SB1")+_cProduto,"B1_DESC")),;
							   Posicione("SB1",1, xFilial("SB1")+_cProduto,"B1_TIPO"),;
							   Posicione("SB1",1, xFilial("SB1")+_cProduto,"B1_UM"),;
							   _cLocal,;
							   AllTrim(_cLote),;
							   _dDataVal,;
							   AllTrim(_cLocaliz),;
							   AllTrim(TransForm(_nSaldo,"@E 9,999,999.99")),;
							   AllTrim(TransForm(0,"@E 9,999,999.99"))})

EndIf 

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf
If Select("TRB2") > 0
	TRB2->(DbCloseArea())
EndIf
If Select("TRB3") > 0
	TRB3->(DbCloseArea())
EndIf
If Select("SD3") > 0
	SD3->(dbCloseArea())
EndIf

Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QESB101oK | Autor: | QUALY         | Data: | 29/07/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QESB101ok                                    |
+------------+-----------------------------------------------------------+
*/
Static Function QESD301ok()

	Local cArqDst     := "C:\TOTVS\QEINVEST_EMP_" + SM0->M0_CODIGO + "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel      := FWMsExcelEX():New()
		
	Local nPlan       := 0
	
	Local cNomPla     := "Empresa_1" + Rtrim(SM0->M0_NOME)
	Local cTitPla     := "Relatorio conferencia de produtos baixados por meio da carga de dados "
	Local cNomWrk     := "Empresa_1" + Rtrim(SM0->M0_NOME)
		
	MakeDir("C:\TOTVS")

	oExcel:AddworkSheet(cNomWrk)
	oExcel:AddTable(cNomPla,  cTitPla)
	oExcel:AddColumn(cNomPla, cTitPla, "Status do registro" , 1, 1, .F.)     //01
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo Produto"     , 1, 1, .F.)     //02
	oExcel:AddColumn(cNomPla, cTitPla, "Descrição Produto"  , 1, 1, .F.)     //03
	oExcel:AddColumn(cNomPla, cTitPla, "Tipo Produto"       , 1, 1, .F.)     //04
	oExcel:AddColumn(cNomPla, cTitPla, "Unidade medida"     , 1, 1, .F.)     //05
	oExcel:AddColumn(cNomPla, cTitPla, "Armazém"            , 1, 1, .F.)     //06
	oExcel:AddColumn(cNomPla, cTitPla, "Lote"               , 1, 1, .F.)     //07
	oExcel:AddColumn(cNomPla, cTitPla, "Validade"           , 1, 1, .F.)     //08
	oExcel:AddColumn(cNomPla, cTitPla, "Endereço"           , 1, 1, .F.)     //09
	oExcel:AddColumn(cNomPla, cTitPla, "Quantidade Baixada" , 3, 2, .F.)     //10
	oExcel:AddColumn(cNomPla, cTitPla, "Custo Atual"        , 3, 2, .F.)     //11
	
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






