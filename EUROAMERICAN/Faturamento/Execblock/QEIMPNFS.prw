#include "Colors.ch"
#include "Protheus.ch"
#include "RwMake.ch"
#Include "TOPCONN.CH" 
#Include "FWMVCDEF.CH"

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

/*/{Protheus.doc} QEIMPNFS 
//Atualiza Percentual De Comissão com arquivo CSV
@type function Rotina customizada 
@Autor Fabio Carneiro 
@since 31/03/2022
@version 1.0
@History Ajustado em 09/09/2022 tratamento referente a não considerar comissão se o item estiver zerado - Fabio carneiro dos Santos
@return  character, sem retorno especifico
/*/
User Function QEIMPNFS() 
                         
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

Define MsDialog oDlg1 From 000,000  TO 015,060 Title OemToAnsi("Atualiza Percentual de Comissão Nf/Titulo - QUALY") 
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

	            SFSC6(Ajj)

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

Processa({|| QEPED01ok("Gerando relatório...")})
	
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

Static Function SFSC6(ALINHA)

Local _nVLTOTAL        := 0
Local _nVLCOMIS1       := 0
lOCAL _nVLCOMTAB       := 0
Local _nVALACRS        := 0
Local _nVLBRUTO        := 0
Local _nPercTab        := 0
Local _cReprePorc      := 0
Local _nComPerc        := 0
Local _nPerPed         := 0
Local _nCount 		   := 0 
Local _nComisCli       := 0

Local cQueryP          := ""
Local cQueryC          := ""
Local _cGEREN          := ""
Local _cVENDEDOR  	   := ""
Local _cNOMEVEND       := ""
Local _cDOC            := ""
Local _cPgCliente      := ""
Local _cRepreClt       := ""
Local _cPgRepre        := ""
Local _dDataPed        := ""
Local _cItem           := ""
Local _cProduto        := ""
Local _cNfiscal        := ""
Local _cSerie          := "" 
Local _cCliente	       := ""
Local _cLoja 	       := ""
Local _cPedido 	       := ""
Local _cTpCom          := ""

_cNfiscal    		   := StrTran(Alinha[1][01],";","")
_cSerie      		   := StrTran(Alinha[1][02],";","")
_cCliente	 		   := StrTran(Alinha[1][03],";","")
_cLoja 	     		   := StrTran(Alinha[1][04],";","")
_cPedido 	 		   := StrTran(Alinha[1][05],";","")

If Select("TRBP") > 0
	TRBP->(DbCloseArea())
EndIf

cQueryP := "SELECT 'FATURADO' AS TPREG," + CRLF 
cQueryP += "D2_TIPO AS TIPO, " + CRLF
cQueryP += "A3_GEREN AS GEREN, " + CRLF
cQueryP += "F2_VEND1 AS VENDEDOR, " + CRLF
cQueryP += "A3_NOME AS NOMEVEND, " + CRLF
cQueryP += "A1_COD AS CODCLI, " + CRLF
cQueryP += "A1_LOJA AS LOJA, " + CRLF
cQueryP += "A1_NOME AS NOMECLI, " + CRLF
cQueryP += "B1_COD AS PRODUTO, " + CRLF
cQueryP += "B1_DESC AS DESCRI, " + CRLF
cQueryP += "D2_ITEM AS ITEM, " + CRLF
cQueryP += "D2_DOC AS DOC, " + CRLF
cQueryP += "D2_SERIE AS SERIE," + CRLF
cQueryP += "D2_PEDIDO AS PEDIDO, " + CRLF
cQueryP += "D2_EMISSAO AS DTEMISSAO, " + CRLF
cQueryP += "A1_XPGCOM AS XA1PGCOM, " + CRLF
cQueryP += "A3_XCLT AS XCLT, " + CRLF
cQueryP += "A3_XPGCOM AS  XA3PGCOM, " + CRLF
cQueryP += "A3_COMIS AS A3COMIS, " + CRLF
cQueryP += "D2_COMIS1 AS C6COMIS, " + CRLF
cQueryP += "D2_XTABCOM AS XTABCOM, " + CRLF
cQueryP += "D2_VALBRUT AS VLBRUTO, " + CRLF
cQueryP += "D2_TOTAL AS VLTOTAL, " + CRLF
cQueryP += "D2_VALACRS AS  VALACRS, " + CRLF
cQueryP += "B1_COMIS AS B1COMIS, " + CRLF
cQueryP += "D2_XCOM1 AS D2XCOM1, " + CRLF
cQueryP += "'' AS NUMTIT, " + CRLF 
cQueryP += "'' AS PREFIXO, " + CRLF
cQueryP += "'' AS PARCELA, " + CRLF
cQueryP += "'' AS TIPOTIT, " + CRLF
cQueryP += "'' AS DTEMISSAOTIT, " + CRLF
cQueryP += "'' AS DTVENCREA, " + CRLF
cQueryP += "'' AS DTBAIXA,  " + CRLF
cQueryP += "'' AS VLBASCOM1, " + CRLF
cQueryP += "'' AS VLCOM1, " + CRLF
cQueryP += "'' AS VLTITULO, " + CRLF
cQueryP += "A1_XCOMIS1 AS XCOMIS1, " + CRLF
cQueryP += "B1_XREVCOM AS XREVCOM, " + CRLF
cQueryP += "B1_XTABCOM AS XB1TABCOM, " + CRLF
cQueryP += "C6_XTABCOM AS C6XTABCOM, " + CRLF
cQueryP += "C6_XREVCOM AS C6XREVCOM, " + CRLF
cQueryP += "C6_XDTRVC AS C6XDTRVC, " + CRLF
cQueryP += "C6_XTPCOM AS C6XTPCOM, " + CRLF
cQueryP += "C6_COMIS1 AS C6COMIS1, " + CRLF
cQueryP += "C6_XCOM1 AS C6XCOM1  "+ CRLF
cQueryP += "FROM "+RetSqlName("SD2")+" AS SD2 WITH (NOLOCK) " + CRLF  
cQueryP += "INNER JOIN "+RetSqlName("SF2")+" AS SF2 WITH (NOLOCK) ON F2_FILIAL = D2_FILIAL " + CRLF 
cQueryP += " AND F2_DOC = D2_DOC " + CRLF
cQueryP += " AND F2_SERIE = D2_SERIE " + CRLF
cQueryP += " AND F2_CLIENTE = D2_CLIENTE " + CRLF
cQueryP += " AND F2_LOJA = D2_LOJA " + CRLF
cQueryP += " AND F2_TIPO = D2_TIPO " + CRLF
cQueryP += " AND F2_EMISSAO = D2_EMISSAO " + CRLF
cQueryP += " AND SF2.D_E_L_E_T_ = ' ' " + CRLF
cQueryP += "INNER JOIN "+RetSqlName("SE1")+" AS SE1 WITH (NOLOCK) ON E1_FILIAL = F2_FILIAL " + CRLF
cQueryP += " AND E1_NUM = F2_DOC " + CRLF
cQueryP += " AND E1_PREFIXO = F2_SERIE " + CRLF
cQueryP += " AND E1_CLIENTE = F2_CLIENTE " + CRLF
cQueryP += " AND E1_LOJA = F2_LOJA " + CRLF
cQueryP += " AND E1_EMISSAO = F2_EMISSAO " + CRLF
cQueryP += " AND SE1.D_E_L_E_T_ = ' '  " + CRLF
cQueryP += "INNER JOIN "+RetSqlName("SF4")+" AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(D2_FILIAL, 2) " + CRLF
cQueryP += " AND F4_CODIGO = D2_TES " + CRLF
cQueryP += " AND F4_DUPLIC = 'S' " + CRLF
cQueryP += " AND SF4.D_E_L_E_T_ = ' ' " + CRLF
cQueryP += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) ON B1_FILIAL = '    ' " + CRLF
cQueryP += " AND B1_COD = D2_COD " + CRLF
cQueryP += " AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQueryP += "INNER JOIN "+RetSqlName("SA3")+" AS SA3 WITH (NOLOCK) ON A3_COD = F2_VEND1 " + CRLF
cQueryP += "	AND SA3.D_E_L_E_T_ = ' ' " + CRLF
cQueryP += "INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH (NOLOCK) ON A1_FILIAL = F2_FILIAL " + CRLF
cQueryP += " AND A1_COD = F2_CLIENTE " + CRLF
cQueryP += " AND A1_LOJA = F2_LOJA " + CRLF
cQueryP += "INNER JOIN "+RetSqlName("SC6")+" AS SC6 WITH (NOLOCK) ON D2_FILIAL = C6_FILIAL " + CRLF
cQueryP += " AND C6_PRODUTO = D2_COD  "+ CRLF
cQueryP += " AND C6_NUM  = D2_PEDIDO  "+ CRLF
cQueryP += " AND C6_CLI  = D2_CLIENTE "+ CRLF
cQueryP += " AND C6_LOJA = D2_LOJA    "+ CRLF
cQueryP += " AND SC6.D_E_L_E_T_ = ' ' "+ CRLF
cQueryP += "WHERE D2_FILIAL = '"+xFilial("SD2")+"' " + CRLF
cQueryP += " AND D2_TIPO = 'N' " + CRLF
cQueryP += " AND D2_DOC     = '"+Alltrim(_cNfiscal)+"' " + CRLF
cQueryP += " AND D2_SERIE   = '"+Alltrim(_cSerie)+"' " + CRLF
cQueryP += " AND D2_CLIENTE = '"+Alltrim(_cCliente)+"' " + CRLF
cQueryP += " AND D2_LOJA    = '"+Alltrim(_cLoja)+"' " + CRLF
cQueryP += " AND SD2.D_E_L_E_T_ = ' '  " + CRLF
cQueryP += "GROUP BY D2_TIPO,A3_GEREN,F2_VEND1,A3_NOME,A1_COD,A1_LOJA,A1_NOME,B1_COD,B1_DESC,D2_ITEM,D2_DOC,D2_SERIE,D2_PEDIDO,D2_EMISSAO,B1_XREVCOM,B1_XTABCOM, " + CRLF
cQueryP += "A1_XPGCOM,A3_XCLT,A3_XPGCOM,A3_COMIS,D2_COMIS1,D2_XTABCOM,D2_TOTAL,B1_COMIS,D2_XCOM1,D2_VALACRS,D2_VALBRUT,F4_DUPLIC,A1_XCOMIS1, " + CRLF
cQueryP += "C6_XTABCOM, C6_XREVCOM, C6_XDTRVC, C6_XTPCOM, C6_COMIS1, C6_XCOM1  " + CRLF

cQueryP += "UNION " + CRLF

cQueryP += "SELECT 'TITULO' AS TPREG, " + CRLF 
cQueryP += "'T' AS TIPO, " + CRLF
cQueryP += "A3_GEREN AS GEREN, " + CRLF
cQueryP += "F2_VEND1 AS VENDEDOR, " + CRLF
cQueryP += "A3_NOME AS NOMEVEND, " + CRLF
cQueryP += "A1_COD AS CODCLI, " + CRLF
cQueryP += "A1_LOJA AS LOJA, " + CRLF
cQueryP += "A1_NOME AS NOMECLI, " + CRLF
cQueryP += "'' AS PRODUTO, " + CRLF
cQueryP += "'' AS DESCRI, " + CRLF
cQueryP += "'' AS ITEM, " + CRLF
cQueryP += "E1_NUM AS DOC, " + CRLF
cQueryP += "E1_PREFIXO AS SERIE,  " + CRLF
cQueryP += "'' AS PEDIDO, " + CRLF
cQueryP += "E1_EMISSAO AS DTEMISSAO, " + CRLF 
cQueryP += "A1_XPGCOM AS XA1PGCOM, " + CRLF
cQueryP += "A3_XCLT AS XCLT, " + CRLF
cQueryP += "A3_XPGCOM AS  XA3PGCOM, " + CRLF
cQueryP += "A3_COMIS AS A3COMIS, " + CRLF
cQueryP += "0 AS C6COMIS, " + CRLF
cQueryP += "0 AS XTABCOM, " + CRLF
cQueryP += "0 AS VLBRUTO, " + CRLF
cQueryP += "0 AS VLTOTAL, " + CRLF
cQueryP += "0 AS VALACRS, " + CRLF
cQueryP += "0 AS B1COMIS, " + CRLF
cQueryP += "0 AS D2XCOM1, " + CRLF
cQueryP += "E1_NUM AS NUMTIT, " + CRLF 
cQueryP += "E1_PREFIXO AS PREFIXO, " + CRLF
cQueryP += "E1_PARCELA AS PARCELA, " + CRLF
cQueryP += "E1_TIPO AS TIPOTIT, " + CRLF
cQueryP += "E1_EMISSAO AS DTEMISSAOTIT, " + CRLF
cQueryP += "E1_VENCREA AS DTVENCREA, " + CRLF
cQueryP += "E1_BAIXA AS DTBAIXA,  " + CRLF
cQueryP += "E1_BASCOM1 AS VLBASCOM1, " + CRLF
cQueryP += "E1_COMIS1  AS VLCOM1, " + CRLF
cQueryP += "E1_VALOR   AS VLTITULO, " + CRLF
cQueryP += "A1_XCOMIS1 AS XCOMIS1, " + CRLF
cQueryP += "'' AS XREVCOM, " + CRLF
cQueryP += "'' AS XB1TABCOM, " + CRLF
cQueryP += "'' AS C6XTABCOM, " + CRLF
cQueryP += "'' AS C6XREVCOM, " + CRLF
cQueryP += "'' AS C6XDTRVC, " + CRLF
cQueryP += "'' AS C6XTPCOM, " + CRLF
cQueryP += "0 AS C6COMIS1, " + CRLF
cQueryP += "0 AS C6XCOM1  "+CRLF
cQueryP += "FROM "+RetSqlName("SE1")+" AS SE1 WITH (NOLOCK) " + CRLF 
cQueryP += "INNER JOIN "+RetSqlName("SF2")+" AS SF2 WITH (NOLOCK) ON E1_FILIAL = F2_FILIAL " + CRLF
cQueryP += " AND E1_NUM = F2_DOC " + CRLF
cQueryP += " AND E1_PREFIXO = F2_SERIE " + CRLF
cQueryP += " AND E1_CLIENTE = F2_CLIENTE " + CRLF
cQueryP += " AND E1_LOJA = F2_LOJA " + CRLF
cQueryP += " AND E1_EMISSAO = F2_EMISSAO " + CRLF
cQueryP += " AND SE1.D_E_L_E_T_ = ' '  " + CRLF
cQueryP += "INNER JOIN "+RetSqlName("SA3")+" AS SA3 WITH (NOLOCK) ON A3_COD = F2_VEND1 " + CRLF
cQueryP += " AND SA3.D_E_L_E_T_ = ' ' " + CRLF
cQueryP += "INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH (NOLOCK) ON A1_FILIAL = F2_FILIAL " + CRLF
cQueryP += " AND A1_COD = F2_CLIENTE " + CRLF
cQueryP += " AND A1_LOJA = F2_LOJA " + CRLF
cQueryP += "WHERE E1_FILIAL = '"+xFilial("SE1")+"'  " + CRLF
cQueryP += " AND F2_TIPO = 'N' " + CRLF
cQueryP += " AND E1_TIPO = 'NF ' " + CRLF
cQueryP += " AND E1_NUM     = '"+Alltrim(_cNfiscal)+"' " + CRLF
cQueryP += " AND E1_PREFIXO = '"+Alltrim(_cSerie)+"' " + CRLF
cQueryP += " AND E1_CLIENTE = '"+Alltrim(_cCliente)+"' " + CRLF
cQueryP += " AND E1_LOJA    = '"+Alltrim(_cLoja)+"' " + CRLF
cQueryP += " AND SE1.D_E_L_E_T_ = ' '  " + CRLF
cQueryP += "GROUP BY A3_GEREN,F2_VEND1,A3_NOME,A1_COD,A1_LOJA,A1_NOME,E1_EMISSAO,A1_XPGCOM,A3_XCLT,A3_XPGCOM,A3_COMIS,E1_NUM,E1_PREFIXO, " + CRLF
cQueryP += "E1_PARCELA,E1_TIPO,E1_EMISSAO,E1_VENCREA,E1_BAIXA,E1_BASCOM1,E1_COMIS1,E1_VALOR,A1_XCOMIS1 " + CRLF
cQueryP += "ORDER BY VENDEDOR,DOC,TPREG,PARCELA,DTEMISSAO,ITEM " + CRLF

TCQuery cQueryP New Alias "TRBP"

TRBP->(DbGoTop())

nRecs++
nLidos++

While TRBP->(!Eof())

	_cPgCliente  := ""
	_cRepreClt   := ""
	_cPgRepre    := ""
	_cReprePorc  := 0
	_nComisCli   := 0

	_cPgCliente  := TRBP->XA1PGCOM  // 1 = Não / 2 = Sim
	_cRepreClt   := TRBP->XCLT      // 1 = Não / 2 = Sim
	_cPgRepre    := TRBP->XA3PGCOM  // 1 = Não / 2 = Sim
	_cReprePorc  := TRBP->A3COMIS   // % do vendedor 
	_nComisCli   := TRBP->XCOMIS1   // % do Cliente 
	_cGEREN		 := TRBP->GEREN
	_cVENDEDOR   := TRBP->VENDEDOR
	_cNOMEVEND 	 := TRBP->NOMEVEND 
	_cDOC  		 := TRBP->DOC                    
	_dDataPed    := StoD(TRBP->DTEMISSAO)
	_cItem       := TRBP->ITEM
	_cProduto    := TRBP->PRODUTO

	If _cPgCliente == "2" .And. _cPgRepre == "2"

		If  AllTrim(TRBP->TPREG) == "FATURADO"

			_nVLBRUTO   += TRBP->VLBRUTO 

			If TRBP->C6XCOM1 > 0
				_nVLCOMIS1  := IF(_nComisCli > 0,_nComisCli,TRBP->C6COMIS1)
			Else 
				_nVLCOMIS1  := 0
			EndIf

			If TRBP->C6XCOM1 > 0
				_nVLCOMTAB  := TRBP->C6XCOM1
				_nVLTOTAL   += TRBP->VLTOTAL
				_nVALACRS   += TRBP->VALACRS
			Else 
				_nVLCOMTAB  += 0
				_nVLTOTAL   += 0
				_nVALACRS   += 0
			EndIf 
	
			If _cPgCliente == "2" .And. _nComisCli > 0
				If TRBP->C6XCOM1 > 0
					_nPercTab   += Round((TRBP->VLTOTAL * _nVLCOMTAB)/100,2) 
					_nComPerc   += Round((TRBP->VLTOTAL * _nComisCli)/100,2)
					_cTpCom     := "01" 
				Else 
					_nPercTab   += 0
					_nComPerc   += 0
					_cTpCom     := "01" 
				EndIf
			ElseIf TRBP->XCLT == "2" .And. TRBP->XA3PGCOM == "2" .And. _nComisCli <= 0
				If TRBP->C6XCOM1 > 0
					_nPercTab   += Round((TRBP->VLTOTAL * _nVLCOMTAB)/100,2) 
					_nComPerc   += Round((TRBP->VLTOTAL * TRBP->A3COMIS)/100,2)
					_cTpCom     := "03" 
				Else
					_nPercTab   += 0
					_nComPerc   += 0
					_cTpCom     := "03" 
				EndIf
			ElseIf _cPgCliente == "2" .And. _nComisCli <= 0
				If TRBP->C6XCOM1 > 0
					_nPercTab   += Round((TRBP->VLTOTAL * _nVLCOMTAB)/100,2) 
					_nComPerc   += Round((TRBP->VLTOTAL * TRBP->C6XCOM1)/100,2)
					_cTpCom     := "02" 
				Else 
					_nPercTab   += 0
					_nComPerc   += 0
					_cTpCom     := "02" 
				EndIf
			EndIf
			
			If TRBP->C6XCOM1 > 0
				If TRBP->XCOMIS1 > 0
					_nPerPed    := If(TRBP->XA1PGCOM=="2".And.TRBP->XCOMIS1 > 0,TRBP->XCOMIS1,TRBP->C6XCOM1)
				Else 
					_nPerPed    := If(TRBP->XCLT=="2".And.TRBP->XA3PGCOM=="2",TRBP->A3COMIS,TRBP->C6XCOM1)
				EndIf
			Else 
				_nPerPed    := 0
			EndIf
	
			DbSelectArea("SD2")
			DbSetOrder(3)  //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			If SD2->(dbSeek(xFilial("SD2")+TRBP->DOC+TRBP->SERIE+TRBP->CODCLI+TRBP->LOJA+TRBP->PRODUTO+TRBP->ITEM)) 
						
				Reclock("SD2",.F.)
						
					SD2->D2_XCOM1     := TRBP->C6XCOM1
					SD2->D2_XTABCOM   := TRBP->C6XTABCOM       
					SD2->D2_XREVCOM   := TRBP->C6XREVCOM       
					SD2->D2_XDTRVC    := StoD(TRBP->C6XDTRVC)
					SD2->D2_XTPCOM    := _cTpCom
					SD2->D2_COMIS1    := _nPerPed
					SD2->D2_COMIS2    := 0
					SD2->D2_COMIS3    := 0
					SD2->D2_COMIS4    := 0
					SD2->D2_COMIS5    := 0


				SD2->( Msunlock() )

				aAdd(aPlanilha,{AllTrim("Atualizado"),;              //01
											_cVENDEDOR,;             //02
											_cNOMEVEND,;             //03        
											_cDOC,;                  //04
											TRBP->PREFIXO,;          //05
											TRBP->PARCELA,;          //06
											StoD(TRBP->DTEMISSAO),;  //07     
											TRBP->ITEM,;        	 //08	 
											TRBP->PRODUTO,;      	 //09	 
											TRBP->VLTOTAL,;          //10	 
											_nPerPed,;               //11     
											_nVLCOMTAB})             //12	     

			EndIf

		EndIf	

	ElseIf _cPgCliente == "1" .And. _cPgRepre == "1"  

		If  AllTrim(TRBP->TPREG) == "FATURADO"

			DbSelectArea("SD2")
			DbSetOrder(3)  //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			If SD2->(dbSeek(xFilial("SD2")+TRBP->DOC+TRBP->SERIE+TRBP->CODCLI+TRBP->LOJA+TRBP->PRODUTO+TRBP->ITEM)) 
							
				Reclock("SD2",.F.)
							
					SD2->D2_XCOM1     := TRBP->C6XCOM1
					SD2->D2_XTABCOM   := TRBP->C6XTABCOM       
					SD2->D2_XREVCOM   := TRBP->C6XREVCOM       
					SD2->D2_XDTRVC    := StoD(TRBP->C6XDTRVC)
					SD2->D2_XTPCOM    := _cTpCom
					SD2->D2_COMIS1    := 0
					SD2->D2_XCOM1     := 0
					SD2->D2_COMIS2    := 0
					SD2->D2_COMIS3    := 0
					SD2->D2_COMIS4    := 0
					SD2->D2_COMIS5    := 0

					SD2->( Msunlock() )

					aAdd(aPlanilha,{AllTrim("Comissão Zerada"),;         //01
												_cVENDEDOR,;             //02
												_cNOMEVEND,;             //03        
												_cDOC,;                  //04	
												TRBP->PREFIXO,;          //05
												TRBP->PARCELA,;          //06
												StoD(TRBP->DTEMISSAO),;  //07     
												TRBP->ITEM,;        	 //08	 
												TRBP->PRODUTO,;      	 //09	 
												0,;                      //10	 
												0,;                      //11     
												0})                      //12	     

			EndIf
		
		EndIf
	Else  

		If  AllTrim(TRBP->TPREG) == "FATURADO"

			DbSelectArea("SD2")
			DbSetOrder(3)  //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			If SD2->(dbSeek(xFilial("SD2")+TRBP->DOC+TRBP->SERIE+TRBP->CODCLI+TRBP->LOJA+TRBP->PRODUTO+TRBP->ITEM)) 
							
				Reclock("SD2",.F.)
							
					SD2->D2_XCOM1     := TRBP->C6XCOM1
					SD2->D2_XTABCOM   := TRBP->C6XTABCOM       
					SD2->D2_XREVCOM   := TRBP->C6XREVCOM       
					SD2->D2_XDTRVC    := StoD(TRBP->C6XDTRVC)
					SD2->D2_XTPCOM    := "04"
					SD2->D2_COMIS1    := 0
					SD2->D2_XCOM1     := 0
					SD2->D2_COMIS2    := 0
					SD2->D2_COMIS3    := 0
					SD2->D2_COMIS4    := 0
					SD2->D2_COMIS5    := 0

					SD2->( Msunlock() )

					aAdd(aPlanilha,{AllTrim("Comissão Zerada"),;         //01
												_cVENDEDOR,;             //02
												_cNOMEVEND,;             //03        
												_cDOC,;                  //04	 
												TRBP->PREFIXO,;          //05
												TRBP->PARCELA,;          //06
												StoD(TRBP->DTEMISSAO),;  //07     
												TRBP->ITEM,;        	 //08	 
												TRBP->PRODUTO,;      	 //09	 
												0,;                      //10	 
												0,;                      //11     
												0})                      //12	     

			EndIf
		
		EndIf

	EndIf

	If  AllTrim(TRBP->TPREG) == "TITULO"

		_nCount := 0

		If Select("TRB3") > 0
			TRB3->(DbCloseArea())
		EndIf

		cQueryC := "SELECT COUNT(E1_NUM) AS QUANT " + CRLF
		cQueryC += "FROM "+RetSqlName("SE1")+" AS SE1 " + CRLF
		cQueryC += " WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' " + CRLF
		cQueryC += " AND SE1.E1_NUM     = '"+TRBP->NUMTIT+"'  " + CRLF
		cQueryC += " AND SE1.E1_PREFIXO = '"+TRBP->PREFIXO+"'  " + CRLF
		cQueryC += " AND SE1.E1_CLIENTE = '"+TRBP->CODCLI+"'  " + CRLF
		cQueryC += " AND SE1.E1_LOJA    = '"+TRBP->LOJA+"'  " + CRLF
		cQueryC += " AND SE1.E1_TIPO    = 'NF '   " + CRLF
		cQueryC += " AND SE1.D_E_L_E_T_ = ' ' " + CRLF
		cQueryC += "UNION " + CRLF			
		cQueryC += "SELECT COUNT(E5_NUMERO)*(-1) AS QUANT " + CRLF
		cQueryC += "FROM "+RetSqlName("SE5")+" AS SE5 " + CRLF
		cQueryC += " WHERE SE5.E5_FILIAL = '"+xFilial("SE5")+"' " + CRLF
		cQueryC += " AND SE5.E5_NUMERO  = '"+TRBP->NUMTIT+"'  " + CRLF
		cQueryC += " AND SE5.E5_PREFIXO = '"+TRBP->PREFIXO+"'  " + CRLF
		cQueryC += " AND SE5.E5_CLIFOR  = '"+TRBP->CODCLI+"'  " + CRLF
		cQueryC += " AND SE5.E5_LOJA    = '"+TRBP->LOJA+"'  " + CRLF
		cQueryC += " AND SE5.E5_MOTBX IN ('LIQ','CAN') " + CRLF
		cQueryC += " AND SE5.E5_TIPO    = 'NF '   " + CRLF
		cQueryC += " AND SE5.D_E_L_E_T_ = ' ' " + CRLF

		TCQUERY cQueryC NEW ALIAS TRB3

		TRB3->(dbGoTop())

		While TRB3->(!Eof())
						
			_nCount += TRB3->QUANT

			TRB3->(dbSkip())

		Enddo

		_cDOC  		 := TRBP->DOC  
		_cSerie		 := TRBP->SERIE  
		_cPercela	 := TRBP->PARCELA  

		_nCMTOTAL   := ABS((_nVLTOTAL - _nVALACRS))
		_nBaseTit   := If(_nCount > 0,Round((_nCMTOTAL / _nCount),2),Round((_nCMTOTAL),2))
		_nPCalcCom  := Round((_nComPerc/_nVLTOTAL)*100,2) 
		_nPCalcTab  := Round((_nPercTab/_nVLTOTAL)*100,2) 	

		If _cPgCliente == "2" .And. _cPgRepre == "2"

			DbSelectArea("SE1")
			DbSetOrder(1)  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
			If SE1->(dbSeek(xFilial("SE1")+TRBP->PREFIXO+TRBP->NUMTIT+TRBP->PARCELA+TRBP->TIPOTIT)) 
						
				Reclock("SE1",.F.)
						
					If Empty(SE1->E1_VEND1)
						SE1->E1_VEND1     := _cVENDEDOR 
					EndIf
					SE1->E1_BASCOM1    := _nBaseTit
					SE1->E1_COMIS1     := _nPCalcCom  
					SE1->E1_XCOM1      := _nPCalcTab 
					SE1->E1_XTPCOM     := _cTpCom 
					SE1->E1_XBASCOM    := _nBaseTit

					SE1->( Msunlock() )

					aAdd(aPlanilha,{AllTrim("Titulo"),;     //01
										TRBP->VENDEDOR,;    //02
										TRBP->NOMEVEND,;    //03        
										TRBP->DOC,;         //04
										TRBP->PREFIXO,;     //05
										TRBP->PARCELA,;     //06
										_dDataPed,;         //07     
										"",;        	    //08	 
										"",;      	        //09	 
										_nBaseTit,;         //10	 
										_nPCalcCom,;        //11     
										_nPCalcTab})        //12

			EndIf

		ElseIf _cPgCliente == "1" .And. _cPgRepre == "1"

			DbSelectArea("SE1")
			DbSetOrder(1)  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
			If SE1->(dbSeek(xFilial("SE1")+TRBP->PREFIXO+TRBP->NUMTIT+TRBP->PARCELA+TRBP->TIPOTIT)) 
						
				Reclock("SE1",.F.)
						
					If Empty(SE1->E1_VEND1)
						SE1->E1_VEND1     := _cVENDEDOR 
					EndIf
					SE1->E1_BASCOM1    := 0
					SE1->E1_COMIS1     := 0
					SE1->E1_XCOM1      := 0
					SE1->E1_XBASCOM    := 0
					SE1->E1_XTPCOM     := "04"

					SE1->( Msunlock() )
			
				aAdd(aPlanilha,{AllTrim("Titulo"),;    //01
										TRBP->VENDEDOR,;    //02
										TRBP->NOMEVEND,;    //03        
										TRBP->DOC,;         //04	 
										TRBP->PREFIXO,;     //05
										TRBP->PARCELA,;     //06
										_dDataPed,;         //07     
										"",;        	    //08	 
										"",;      	        //09	 
										0,;                 //10	 
										0,;                 //11     
										0})                 //12

			EndIf

		Else 

			DbSelectArea("SE1")
			DbSetOrder(1)  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO 
			If SE1->(dbSeek(xFilial("SE1")+TRBP->PREFIXO+TRBP->NUMTIT+TRBP->PARCELA+TRBP->TIPOTIT)) 
						
				Reclock("SE1",.F.)
						
					If Empty(SE1->E1_VEND1)
						SE1->E1_VEND1     := _cVENDEDOR 
					EndIf
					SE1->E1_BASCOM1    := 0
					SE1->E1_COMIS1     := 0
					SE1->E1_XCOM1      := 0
					SE1->E1_XBASCOM    := 0
					SE1->E1_XTPCOM     := "04" 

				SE1->( Msunlock() )
			
				aAdd(aPlanilha,{AllTrim("Titulo"),;         //01
									TRBP->VENDEDOR,;        //02
									TRBP->NOMEVEND,;        //03        
									TRBP->DOC,;             //04	 
									TRBP->PREFIXO,;         //05
									TRBP->PARCELA,;         //06
									_dDataPed,;             //07     
									"",;        	        //08	 
									"",;      	            //09	 
									0,;                     //10	 
									0,;                     //11     
									0})                     //12

			
			EndIf

		
		EndIf

	EndIf

	TRBP->(DbSkip())

	IncProc("Gerando arquivo...")	

	If TRBP->(EOF()) .Or. TRBP->DOC <> _cDOC 
			
		_nVLCOMIS1  := 0
		_nVLCOMTAB  := 0
		_nVLTOTAL   := 0
		_nVALACRS   := 0
		_nVLBRUTO   := 0
		_nPCalcCom  := 0
		_nPCalcTab  := 0 
		_cGEREN		:= ""
		_cVENDEDOR  := ""
		_cNOMEVEND 	:= ""
		_cDOC  		:= ""
		_dDataPed   := "" 
		_cItem      := ""
		_cProduto   := ""
		_cTpCom     := "" 
			
	EndIf 

EndDo

If Select("TRBP") > 0
	TRBP->(DbCloseArea())
EndIf
If Select("TRB3") > 0
	TRB3->(DbCloseArea())
EndIf

Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEPED01oK | Autor: | QUALY         | Data: | 29/07/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEPED01ok                                    |
+------------+-----------------------------------------------------------+
*/
Static Function QEPED01ok()

	Local cArqDst    := "C:\TOTVS\QEIMPPED_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel     := FWMsExcelEX():New()
	Local nPlan      := 0
	Local cPlan      := "Empresa_" + Rtrim(SM0->M0_CODIGO) + "_Filial_" + Rtrim(SM0->M0_CODFIL)
	Local cTit       := "Relatorio conferencia de carga de dados "

	MakeDir("C:\TOTVS")

	oExcel:AddworkSheet(cPlan)
	oExcel:AddTable(cPlan, cTit)
	oExcel:AddColumn(cPlan, cTit, "Status"             , 1, 1, .F.)  //01
	oExcel:AddColumn(cPlan, cTit, "Vendedor"           , 1, 1, .F.)  //02
	oExcel:AddColumn(cPlan, cTit, "Nome Vendedor"      , 1, 1, .F.)  //03
	oExcel:AddColumn(cPlan, cTit, "Nf/Titulo"          , 1, 1, .F.)  //04
	oExcel:AddColumn(cPlan, cTit, "Serie/Prefixo"      , 1, 1, .F.)  //05
	oExcel:AddColumn(cPlan, cTit, "Parcela"            , 1, 1, .F.)  //06
	oExcel:AddColumn(cPlan, cTit, "Data Pedido"        , 1, 1, .F.)  //07
	oExcel:AddColumn(cPlan, cTit, "Item"               , 1, 1, .F.)  //08
	oExcel:AddColumn(cPlan, cTit, "Produto"            , 1, 1, .F.)  //09
	oExcel:AddColumn(cPlan, cTit, "Valor Item"         , 3, 2, .F.)  //10
	oExcel:AddColumn(cPlan, cTit, "% Comissão"         , 3, 2, .F.)  //11
	oExcel:AddColumn(cPlan, cTit, "% Comissão Tabela"  , 3, 2, .F.)  //12

	// preenche as informações na planilha de acordo com o Array aPlanilha 
	For nPlan:=1 To Len(aPlanilha)
		
		lAbre := .T.

		oExcel:AddRow(cPlan,cTit,{aPlanilha[nPlan][01],;
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
								  aPlanilha[nPlan][12]}) 
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






