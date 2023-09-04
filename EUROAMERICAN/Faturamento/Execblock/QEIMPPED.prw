#include "Colors.ch"
#include "Protheus.ch"
#include "RwMake.ch"
#Include "TOPCONN.CH" 
#Include "FWMVCDEF.CH"
/*/{Protheus.doc} QEIMPPED 
//Atualiza Percentual De Comissão com arquivo do para pedido de vendas em formato CSV
@type function Rotina customizada 
@Autor Fabio Carneiro 
@since 31/03/2022
@version 1.0
@History Ajustado em 09/09/2022 tratamento referente a não considerar comissão se o item estiver zerado - Fabio carneiro dos Santos
@return  character, sem retorno especifico
/*/
User Function QEIMPPED() 
                         
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

Define MsDialog oDlg1 From 000,000  TO 015,060 Title OemToAnsi("Atualiza Percentual de Comissão Pedido - QUALY") 
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

Processa({|| QEPED01ok(), "Gerando relatório..."})
	
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

Local lAbre            := .F.

Local _nVLTOTAL        := 0
Local _nVLCOMIS1       := 0
lOCAL _nVLCOMTAB       := 0
Local _nPercTab        := 0
Local _cReprePorc      := 0
Local _nComPerc        := 0
Local _nPerPed         := 0
Local _nComisCli       := 0

Local cQueryP          := ""
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
Local _cTpCom          := "04"

_cNfiscal    		   := StrTran(Alinha[1][01],";","")
_cSerie      		   := StrTran(Alinha[1][02],";","")
_cCliente	 		   := StrTran(Alinha[1][03],";","")
_cLoja 	     		   := StrTran(Alinha[1][04],";","")
_cPedido 	 		   := StrTran(Alinha[1][05],";","")

If Select("TRBP") > 0
	TRBP->(DbCloseArea())
EndIf

cQueryP := "SELECT 'PEDIDO' AS TPREG, " + CRLF
cQueryP += "'P' AS TIPO, " + CRLF
cQueryP += "A3_GEREN AS GEREN, " + CRLF
cQueryP += "C5_VEND1 AS VENDEDOR, " + CRLF
cQueryP += "A3_NOME AS NOMEVEND, " + CRLF
cQueryP += "A1_COD AS CODCLI, " + CRLF
cQueryP += "A1_LOJA AS LOJA, " + CRLF
cQueryP += "A1_NOME AS NOMECLI, " + CRLF
cQueryP += "B1_COD AS PRODUTO, " + CRLF
cQueryP += "B1_DESC AS DESCRI, " + CRLF
cQueryP += "C6_ITEM AS ITEM, " + CRLF
cQueryP += "C5_NUM AS DOC, " + CRLF
cQueryP += "C5_EMISSAO AS DTEMISSAO, " + CRLF 
cQueryP += "A1_XPGCOM AS XA1PGCOM, " + CRLF
cQueryP += "A3_XCLT AS XCLT, " + CRLF
cQueryP += "A3_XPGCOM AS  XA3PGCOM, " + CRLF
cQueryP += "A3_COMIS AS A3COMIS, " + CRLF
cQueryP += "C6_COMIS1 AS C6COMIS, " + CRLF
cQueryP += "C6_XCOM1 AS C6XCOM1, " + CRLF
cQueryP += "C6_XTABCOM AS XTABCOM, " + CRLF
cQueryP += "B1_COMIS AS B1COMIS, " + CRLF
cQueryP += "C6_VALOR AS VLTOTAL, " + CRLF
cQueryP += "A1_XCOMIS1 AS XCOMIS1, " + CRLF
cQueryP += "B1_XREVCOM AS XREVCOM, " + CRLF
cQueryP += "B1_XTABCOM AS XB1TABCOM, " + CRLF
cQueryP += "C6_XTABCOM AS C6XTABCOM, " + CRLF
cQueryP += "C6_XREVCOM AS C6XREVCOM, " + CRLF
cQueryP += "C6_XDTRVC AS C6XDTRVC, " + CRLF
cQueryP += "C6_XTPCOM AS C6XTPCOM, " + CRLF
cQueryP += "C6_COMIS1 AS C6COMIS1, " + CRLF
cQueryP += "C6_XCOM1 AS C6XCOM1  "+ CRLF
cQueryP += "FROM "+RetSqlName("SC5")+" AS SC5 WITH (NOLOCK) " + CRLF 
cQueryP += "INNER JOIN "+RetSqlName("SC6")+" AS SC6 WITH (NOLOCK) ON C5_FILIAL = C6_FILIAL " + CRLF 
cQueryP += " AND C5_NUM = C6_NUM " + CRLF
cQueryP += " AND C5_CLIENTE = C6_CLI " + CRLF
cQueryP += " AND C5_LOJACLI = C6_LOJA " + CRLF
cQueryP += " AND SC6.D_E_L_E_T_ = ' '  " + CRLF
CQueryP += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 WITH (NOLOCK) ON B1_COD = C6_PRODUTO " + CRLF
cQueryP += " AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQueryP += "INNER JOIN "+RetSqlName("SF4")+" AS SF4 WITH (NOLOCK) ON LEFT(F4_FILIAL, 2) = LEFT(C6_FILIAL, 2) " + CRLF
cQueryP += " AND F4_CODIGO = C6_TES " + CRLF
cQueryP += " AND F4_DUPLIC = 'S' " + CRLF
CQueryP += " AND SF4.D_E_L_E_T_ = ' ' " + CRLF
cQueryP += "INNER JOIN "+RetSqlName("SA3")+" AS SA3 WITH (NOLOCK) ON A3_COD = C5_VEND1 " + CRLF
cQueryP += " AND SA3.D_E_L_E_T_ = ' ' " + CRLF
cQueryP += "INNER JOIN "+RetSqlName("SA1")+" AS SA1 WITH (NOLOCK) ON A1_FILIAL = C5_FILIAL " + CRLF
cQueryP += " AND A1_COD = C5_CLIENTE " + CRLF
cQueryP += " AND A1_LOJA = C5_LOJACLI " + CRLF
cQueryP += "WHERE C5_FILIAL = '"+xFilial("SC5")+"'  " + CRLF
cQueryP += " AND C5_NUM     = '"+Alltrim(_cPedido)+"' " + CRLF
cQueryP += " AND C5_CLIENTE = '"+Alltrim(_cCliente)+"' " + CRLF
cQueryP += " AND C5_LOJACLI = '"+Alltrim(_cLoja)+"' " + CRLF
cQueryP += " AND SC6.D_E_L_E_T_ = ' '  " + CRLF
cQueryP += "GROUP BY A3_GEREN,C5_VEND1,A3_NOME,A1_COD,A1_LOJA,A1_NOME,B1_COD,B1_DESC,C6_ITEM,C5_NUM,C5_EMISSAO,A1_XPGCOM, " + CRLF
cQueryP += "A3_XCLT,A3_XPGCOM,A3_COMIS,C6_COMIS1,C6_XTABCOM,B1_COMIS,C6_VALOR,C6_XCOM1,B1_COMIS,A1_XCOMIS1,B1_XREVCOM,B1_XTABCOM, " + CRLF
cQueryP += "C6_XTABCOM, C6_XREVCOM, C6_XDTRVC, C6_XTPCOM, C6_COMIS1, C6_XCOM1  "+ CRLF
cQueryP += "ORDER BY C5_NUM, C5_EMISSAO, C6_ITEM " + CRLF

TCQuery cQueryP New Alias "TRBP"

TRBP->(DbGoTop())

While TRBP->(!Eof())

		// Tratamento do Tipo que vem do SQL NO ALIAS 
	_cPgCliente  := ""
	_cRepreClt   := ""
	_cPgRepre    := ""
	_cReprePorc  := 0

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

	nLidos++

	If _cPgCliente == "2" .And. _cPgRepre == "2"

		If  AllTrim(TRBP->TPREG) == "PEDIDO"

			If TRBP->B1COMIS > 0
				_nVLCOMIS1  := IF(_nComisCli > 0,_nComisCli,Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_COMIS1"))
				_nVLCOMTAB  := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_COMIS1")         
				_nVLTOTAL   += TRBP->VLTOTAL
			Else 
				_nVLCOMIS1  += 0
				_nVLCOMTAB  += 0
				_nVLTOTAL   += 0
			EndIf

			If _cPgCliente == "2" .And. _nComisCli > 0

				If TRBP->B1COMIS > 0
					_nPercTab   += Round((TRBP->VLTOTAL * _nVLCOMTAB)/100,2) 
					_nComPerc   += Round((TRBP->VLTOTAL * _nComisCli)/100,2)
					_cTpCom     := "01" // cliente
				Else 
					_nPercTab   += 0
					_nComPerc   += 0
					_cTpCom     := "01" // cliente
				EndIf

			ElseIf _cPgCliente == "2" .And. _cRepreClt == "2" .And. _cPgRepre == "2" .And. _nComisCli <= 0

				If TRBP->B1COMIS > 0
					_nPercTab   += Round((TRBP->VLTOTAL * _nVLCOMTAB)/100,2) 
					_nComPerc   += Round((TRBP->VLTOTAL * TRBP->A3COMIS)/100,2)
					_cTpCom     := "03" // Vendedor
				Else 
					_nPercTab   += 0
					_nComPerc   += 0
					_cTpCom     := "03" // Vendedor
				EndIf

			ElseIf _cPgCliente == "2" .And. _cRepreClt == "1" .And. _cPgRepre == "2" .And. _nComisCli <= 0

				If TRBP->B1COMIS > 0
					_nPercTab   += Round((TRBP->VLTOTAL * _nVLCOMTAB)/100,2) 
					_nComPerc   += Round((TRBP->VLTOTAL * Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_COMIS1"))/100,2)
					_cTpCom     := "02" // Produto 
				Else    
					_nPercTab   += 0
					_nComPerc   += 0
					_cTpCom     := "02" // Produto 
				EndIf

			Else 

				_cTpCom     := "04" // Zerada 

			EndIf

			If TRBP->B1COMIS > 0

				If TRBP->XCOMIS1 > 0
					_nPerPed    := If(TRBP->XA1PGCOM=="2".And.TRBP->XCOMIS1 > 0,TRBP->XCOMIS1,Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_COMIS1"))
				Else 
					_nPerPed    := If(TRBP->XCLT=="2".And.TRBP->XA3PGCOM=="2",TRBP->A3COMIS,Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_COMIS1"))
				EndIf

			Else 

				_nPerPed    := 0

			EndIf

			DbSelectArea("SC6")
			DbSetOrder(1)  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
			If SC6->(dbSeek(xFilial("SC6")+TRBP->DOC+TRBP->ITEM+TRBP->PRODUTO)) 
						
				Reclock("SC6",.F.)
						
					SC6->C6_COMIS1    := _nPerPed
					SC6->C6_XCOM1     := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_COMIS1")         
					SC6->C6_XTABCOM   := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_CODTAB")       
					SC6->C6_XREVCOM   := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_REV")       
					SC6->C6_XDTRVC    := DDATABASE 
					SC6->C6_XTPCOM    := _cTpCom
					SC6->C6_COMIS2    := 0
					SC6->C6_COMIS3    := 0
					SC6->C6_COMIS4    := 0
					SC6->C6_COMIS5    := 0

				SC6->( Msunlock() )

				aAdd(aPlanilha,{AllTrim("Atualizado"),;              //01
											_cVENDEDOR,;             //02
											_cNOMEVEND,;             //03        
											_cDOC,;                  //04	 
											StoD(TRBP->DTEMISSAO),;  //05     
											TRBP->ITEM,;        	 //06	 
											TRBP->PRODUTO,;      	 //07	 
											TRBP->VLTOTAL,;          //08	 
											_nPerPed,;             //09     
											_nVLCOMTAB})             //10	     

			EndIf

		EndIf	

	ElseIf _cPgCliente == "1" .And. _cPgRepre == "1"  

		DbSelectArea("SC6")
		DbSetOrder(1)  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		If SC6->(dbSeek(xFilial("SC6")+TRBP->DOC+TRBP->ITEM+TRBP->PRODUTO)) 
						
			Reclock("SC6",.F.)
				
				SC6->C6_XTABCOM   := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_CODTAB")       
				SC6->C6_XREVCOM   := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_REV")       
				SC6->C6_XDTRVC    := DDATABASE 
				SC6->C6_XTPCOM    := _cTpCom
				SC6->C6_COMIS1    := 0
				SC6->C6_COMIS2    := 0
				SC6->C6_COMIS3    := 0
				SC6->C6_COMIS4    := 0
				SC6->C6_COMIS5    := 0
				SC6->C6_XCOM1     := 0

			SC6->( Msunlock() )
				

			lAbre := .T.

			aAdd(aPlanilha,{AllTrim("Comissão Zero"),;               //01
											_cVENDEDOR,;             //02
											_cNOMEVEND,;             //03        
											_cDOC,;                  //04	 
											StoD(TRBP->DTEMISSAO),;  //05     
											TRBP->ITEM,;        	 //06	 
											TRBP->PRODUTO,;      	 //07	 
											TRBP->VLTOTAL,;          //08	 
											0,;                      //09     
											0})                      //10	     
	
		EndIf	
	
	Else  

		DbSelectArea("SC6")
		DbSetOrder(1)  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		If SC6->(dbSeek(xFilial("SC6")+TRBP->DOC+TRBP->ITEM+TRBP->PRODUTO)) 
						
			Reclock("SC6",.F.)
				
				SC6->C6_XTABCOM   := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_CODTAB")       
				SC6->C6_XREVCOM   := Posicione("PAA",1,xFilial("PAA")+TRBP->PRODUTO+TRBP->C6XTABCOM+TRBP->C6XREVCOM,"PAA_REV")       
				SC6->C6_XDTRVC    := DDATABASE 
				SC6->C6_XTPCOM    := _cTpCom
				SC6->C6_COMIS1    := 0
				SC6->C6_COMIS2    := 0
				SC6->C6_COMIS3    := 0
				SC6->C6_COMIS4    := 0
				SC6->C6_COMIS5    := 0
				SC6->C6_XCOM1     := 0

			SC6->( Msunlock() )
				

			lAbre := .T.

			aAdd(aPlanilha,{AllTrim("Comissão Zero"),;               //01
											_cVENDEDOR,;             //02
											_cNOMEVEND,;             //03        
											_cDOC,;                  //04	 
											StoD(TRBP->DTEMISSAO),;  //05     
											TRBP->ITEM,;        	 //06	 
											TRBP->PRODUTO,;      	 //07	 
											TRBP->VLTOTAL,;          //08	 
											0,;                      //09     
											0})                      //10	     
		
		
		EndIf
	EndIf
		
	TRBP->(DbSkip())

	IncProc("Gerando arquivo...")	

	If TRBP->(EOF()) .Or. TRBP->DOC <> _cDOC 
	
		_nPCalcCom   := Round((_nComPerc/_nVLTOTAL)*100,2) 
		_nPCalcTab   := Round((_nPercTab/_nVLTOTAL)*100,2) 	

		nLidos++
	
		If _cPgCliente == "2" .And. _cPgRepre == "2"	
		
			DbSelectArea("SC5")
			DbSetOrder(1)  
			If SC5->(dbSeek(xFilial("SC5")+ _cDOC)) 
							
				Reclock("SC5",.F.)
						
					SC5->C5_COMIS1    := _nPCalcCom
					SC5->C5_COMIS2    := 0
					SC5->C5_COMIS3    := 0
					SC5->C5_COMIS4    := 0
					SC5->C5_COMIS5    := 0
					SC5->C5_XTPCOM    := _cTpCom

				SC5->( Msunlock() )
				
			EndIf 

			nRecs++

			aAdd(aPlanilha,{AllTrim("SubTotal-->"),;    //01
									TRBP->VENDEDOR,;    //02
									TRBP->NOMEVEND,;    //03        
									TRBP->DOC,;         //04	 
									_dDataPed,;         //05     
									"",;        	    //06	 
									"",;      	        //07	 
									_nVLTOTAL,;         //08	 
									_nPCalcCom,;        //09     
									_nPCalcTab})        //10

			aAdd(aPlanilha,{"",;    //01
							"",;    //02
							"",;    //03        
							"",;    //04	 
							"",;    //05     
							"",;    //06	 
							"",;    //07	 
							"",;    //08	 
							"",;    //09     
							""})    //10	     


		ElseIf _cPgCliente == "1" .And. _cPgRepre == "1"

			DbSelectArea("SC5")
			DbSetOrder(1)  
			If SC5->(dbSeek(xFilial("SC5")+ _cDOC)) 
							
				Reclock("SC5",.F.)
							
					SC5->C5_COMIS1    := 0
					SC5->C5_COMIS2    := 0
					SC5->C5_COMIS3    := 0
					SC5->C5_COMIS4    := 0
					SC5->C5_COMIS5    := 0
					SC5->C5_XTPCOM    := _cTpCom

				SC5->( Msunlock() )
				
			EndIf 

			nRecs++

			aAdd(aPlanilha,{AllTrim("SubTotal-->"),;    //01
									TRBP->VENDEDOR,;    //02
									TRBP->NOMEVEND,;    //03        
									TRBP->DOC,;         //04	 
									_dDataPed,;         //05     
									"",;        	    //06	 
									"",;      	        //07	 
									_nVLTOTAL,;         //08	 
									0,;                 //09     
									0})                 //10	     
			
			aAdd(aPlanilha,{"",;    //01
							"",;    //02
							"",;    //03        
							"",;    //04	 
							"",;    //05     
							"",;    //06	 
							"",;    //07	 
							"",;    //08	 
							"",;    //09     
							""})    //10	     

		Else

			DbSelectArea("SC5")
			DbSetOrder(1)  
			If SC5->(dbSeek(xFilial("SC5")+ _cDOC)) 
							
				Reclock("SC5",.F.)
							
					SC5->C5_COMIS1    := 0
					SC5->C5_COMIS2    := 0
					SC5->C5_COMIS3    := 0
					SC5->C5_COMIS4    := 0
					SC5->C5_COMIS5    := 0
					SC5->C5_XTPCOM    := _cTpCom

				SC5->( Msunlock() )
				
			EndIf 

			nRecs++

			aAdd(aPlanilha,{AllTrim("SubTotal-->"),;    //01
									TRBP->VENDEDOR,;    //02
									TRBP->NOMEVEND,;    //03        
									TRBP->DOC,;         //04	 
									_dDataPed,;         //05     
									"",;        	    //06	 
									"",;      	        //07	 
									_nVLTOTAL,;         //08	 
									0,;                 //09     
									0})                 //10	     
			
			aAdd(aPlanilha,{"",;    //01
							"",;    //02
							"",;    //03        
							"",;    //04	 
							"",;    //05     
							"",;    //06	 
							"",;    //07	 
							"",;    //08	 
							"",;    //09     
							""})    //10	     

		EndIf
			
		_nVLCOMIS1  := 0
		_nVLCOMTAB  := 0
		_nVLTOTAL   := 0
		_nPCalcCom  := 0
		_nPCalcTab  := 0 
		_cGEREN		:= ""
		_cVENDEDOR  := ""
		_cNOMEVEND 	:= ""
		_cDOC  		:= ""
		_dDataPed   := "" 
		_cItem      := ""
		_cProduto   := ""
		
	EndIf 

EndDo

If Select("TRBP") > 0
	TRBP->(DbCloseArea())
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
	oExcel:AddColumn(cPlan, cTit, "Pedido Vendas"      , 1, 1, .F.)  //04
	oExcel:AddColumn(cPlan, cTit, "Data Pedido"        , 1, 1, .F.)  //05
	oExcel:AddColumn(cPlan, cTit, "Item"               , 1, 1, .F.)  //06
	oExcel:AddColumn(cPlan, cTit, "Produto"            , 1, 1, .F.)  //07
	oExcel:AddColumn(cPlan, cTit, "Valor Item"         , 3, 2, .F.)  //08
	oExcel:AddColumn(cPlan, cTit, "% Comissão"         , 3, 2, .F.)  //09
	oExcel:AddColumn(cPlan, cTit, "% Comissão Tabela"  , 3, 2, .F.)  //10

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
									aPlanilha[nPlan][10]}) 
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

	//Local cDirDocs := MsDocPath()
	//Local cPath	   := AllTrim(GetTempPath())

	If !ApOleClient("MsExcel")
		Aviso("Atencao", "O Microsoft Excel nao esta instalado.", {"Ok"}, 2)
	Else
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(cArq)
		oExcelApp:SetVisible(.T.)
		oExcelApp:Destroy()
	EndIf

Return






