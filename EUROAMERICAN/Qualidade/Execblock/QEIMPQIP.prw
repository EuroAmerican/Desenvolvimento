#include "Colors.ch"
#include "Protheus.ch"
#include "RwMake.ch"
#Include "TOPCONN.CH" 
#Include "FWMVCDEF.CH"

#Define ENTER chr(13) + chr(10)
#Define CTRL chr(13) + chr(10)

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEIMPQIP  | Autor: |Fabio Carneiro | Data: | 28/06/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Atualiza data fabricação e validade qualidade             |
+------------+-----------------------------------------------------------+
| Uso:       | EURO                                                      |
+------------+-----------------------------------------------------------+
*/
User Function QEIMPQIP() 
                         
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

Define MsDialog oDlg1 From 000,000  TO 015,060 Title OemToAnsi("Atualiza data fabriação/validade dos laudos e etiqueta - EURO") 
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
| Programa:  | OkLeTxt   | Autor: |Fabio Carneiro | Data: | 28/06/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Le o arquivo TXT                                          |
+------------+-----------------------------------------------------------+
| Uso:       | EURO                                                      |
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
local x             := u := colini := tamcol := 0
Local ajj           := {}
local coluna        := {}
LOCAL NRECX         := 0     

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

	            SFSZD(Ajj)

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

Processa({|| QEQIP01ok("Gerando relatório...")})
	
fclose(_nHdl)                          

Return                   
                                               
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  |  SFSZD    | Autor: |Fabio Carneiro | Data: | 28/06/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Grava linha por linha do arquivo após delimitador (;)     |
+------------+-----------------------------------------------------------+
| Uso:       | EURO                                                      |
+------------+-----------------------------------------------------------+
*/

Static Function SFSZD(ALINHA)

Local lAbre            := .F.
Local cQuery           := ""
Local cQry             := ""
Local _lPassa          := .F.
Local _cOrdProd        := ""
Local _cFilial    	   := ""	
Local _cProduto 	   := ""	
Local _cArmazen 	   := ""	
Local _cEndereco	   := ""	
Local _cLote  	 	   := ""	
Local _cChecaLaudo     := ""
Local _dDtFabric 	   := Ctod("  /  /    ")
Local _dDtValid 	   := Ctod("  /  /    ")
Local cQueryA          := ""
Local _aLista          := {}
Local _nLista          := 0

_cFilial    		   := StrTran(Alinha[1][01],";","")
_cProduto 	 		   := StrTran(Alinha[1][02],";","")
_cArmazen 	 		   := StrTran(Alinha[1][03],";","")
_cEndereco	 		   := StrTran(Alinha[1][04],";","")
_cLote  	 		   := StrTran(Alinha[1][05],";","")
_dDtFabric 	 		   := StrTran(Alinha[1][06],";","")
_dDtValid 	 		   := StrTran(Alinha[1][07],";","")

nLidos++

If AllTrim(Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_COD")) == Alltrim(_cProduto)
	_lPassa := .T.
EndIf

If Empty(CtoD(_dDtFabric)) .Or. Empty(CtoD(_dDtValid))
	_lPassa := .F.
EndIf

If _lPassa 

	If Select("TRBP") > 0
		TRBP->(DbCloseArea())
	EndIf

	cQuery := "SELECT *  " + CRLF
	cQuery += "FROM "+RetSqlName("SZD")+" AS SZD WITH (NOLOCK) " + CRLF 
	cQuery += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 ON ZD_PRODUT = B1_COD " + CRLF
	cQuery += " AND SB1.D_E_L_E_T_ = ' '  " + CRLF
	cQuery += "WHERE ZD_FILIAL = '"+xFilial("SZD")+"' " + CRLF
	cQuery += " AND SUBSTRING(ZD_PRODUT,1,3) = '"+AllTrim(Substr(_cProduto,1,3))+"' " + CRLF
	cQuery += " AND ZD_LOTE     = '"+AllTrim(_cLote)+"' " + CRLF
	cQuery += " AND SZD.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TRBP"

	TRBP->(DbGoTop())

	While TRBP->(!Eof())

		lAbre         := .T.
		_cChecaLaudo  := Posicione("SZD",1,xFilial("SZD")+TRBP->ZD_PRODUT+TRBP->ZD_LOTE+TRBP->ZD_LI+TRBP->ZD_LE+TRBP->ZD_ITEM+TRBP->ZD_ENSAIO,"ZD_LOTE")

		If !Empty(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"01"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_NUM"))
			_cOrdProd  := AllTrim(Posicione("SC2",1,xFilial("SC2")+Alltrim(TRBP->ZD_LOTE)+"01"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_NUM"))
			_cOrdProd  += AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"01"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_ITEM"))
			_cOrdProd  += AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"01"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_SEQUEN"))
		Else
			If !Empty(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"02"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_NUM"))
				_cOrdProd  := AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"02"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_NUM"))
				_cOrdProd  += AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"02"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_ITEM"))
				_cOrdProd  += AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"02"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_SEQUEN"))
			Else 
				If !Empty(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"03"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_NUM"))
					_cOrdProd  := AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"03"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_NUM"))
					_cOrdProd  += AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"03"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_ITEM"))
					_cOrdProd  += AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"03"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_SEQUEN"))
				Else 
					If !Empty(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"04"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_NUM"))
						_cOrdProd  := AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"04"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_NUM"))
						_cOrdProd  += AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"04"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_ITEM"))
						_cOrdProd  += AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"04"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_SEQUEN"))
					Else
						If !Empty(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"05"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_NUM"))
							_cOrdProd  := AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"05"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_NUM"))
							_cOrdProd  += AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"05"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_ITEM"))
							_cOrdProd  += AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"05"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_SEQUEN"))
						Else 
							If !Empty(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"06"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_NUM"))
								_cOrdProd  := AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"06"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_NUM"))
								_cOrdProd  += AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"06"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_ITEM"))
								_cOrdProd  += AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"06"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_SEQUEN"))
							Else
								If !Empty(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"07"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_NUM"))
									_cOrdProd  := AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"07"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_NUM"))
									_cOrdProd  += AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"07"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_ITEM"))
									_cOrdProd  += AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"07"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_SEQUEN"))
								Else 
									_cOrdProd  := AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"08"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_NUM"))
									_cOrdProd  += AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"08"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_ITEM"))
									_cOrdProd  += AllTrim(Posicione("SC2",1,xFilial("SC2")+AllTrim(TRBP->ZD_LOTE)+"08"+"001"+Space(TamSX3("C2_ITEMGRD")[1]),"C2_SEQUEN"))
								EndIf
							EndIf
						EndIf
					EndIf	
				EndIf
			EndIf
		EndIf
		
		If AllTrim(_cChecaLaudo) == AllTrim(_cLote) 
		
			DbSelectArea("SZD")   
			DbSetOrder(1) //ZD_FILIAL+ZD_PRODUT+ZD_LOTE+ZD_LI+ZD_LE+ZD_ITEM+ZD_ENSAIO
			If DbSeek(xFilial("SZD")+TRBP->ZD_PRODUT+TRBP->ZD_LOTE+TRBP->ZD_LI+TRBP->ZD_LE+TRBP->ZD_ITEM+TRBP->ZD_ENSAIO)
			
				RecLock("SZD",.F.)
			
				SZD->ZD_DTFABR    := CtoD(_dDtFabric)
				SZD->ZD_OP        := AllTrim(_cOrdProd) 
				SZD->ZD_DTVALID   := CtoD(_dDtValid)
			
				SZD->( MsUnLock() )
			
			EndIf

			If Select("TRB1") > 0
				TRB1->(DbCloseArea())
			EndIf

			cQueryA := "SELECT * FROM "+RetSqlName("PAY")+" AS PAY WITH (NOLOCK) "+CRLF
			cQueryA += "WHERE PAY_FILIAL = '"+xFilial("PAY")+"' "+CRLF
			cQueryA += " AND PAY_OP = '"+SubStr(_cOrdProd,1,6)+"01"+"001"+"' "+CRLF
			cQueryA += " AND PAY.D_E_L_E_T_ = ' ' "+CRLF 
			cQueryA += "ORDER BY PAY_LOTE  "+CRLF

			TCQuery cQueryA New Alias "TRB1"

			TRB1->(DbGoTop())

			While TRB1->(!Eof())

				Aadd(_aLista,{PAY_FILIAL,; //01
							  PAY_CTRL,;   //02 
							  PAY_SEQ,;    //03
							  PAY_PROD,;   //04
							  PAY_OP,;     //05 
							  PAY_LOTE,;   //06
							  PAY_DTFAB,;  //07
							  PAY_DTVAL,;  //08
							  PAY_HRREG,;  //09
							  PAY_DTLAUD,; //10
							  PAY_CODANL,; //11
							  PAY_STATUS}) //12

				TRB1->(DbSkip())

			EndDo

			If Len(_aLista) > 0

				For _nLista := 1 To Len(_aLista)

					DbSelectArea("PAY")
					PAY->(DbSetOrder(1)) // PAY_FILIAL+PAY_OP+PAY_PROD+PAY_CTRL
					If PAY->(dbSeek(xFilial("PAY")+_aLista[_nLista][05]+_aLista[_nLista][04]+_aLista[_nLista][02])) 

						If _aLista[_nLista][04] == TRBP->ZD_PRODUT .And. _aLista[_nLista][06] == TRBP->ZD_LOTE

							RecLock("PAY",.F.)
							PAY->PAY_FILIAL := _aLista[_nLista][01]
							PAY->PAY_CTRL   := _aLista[_nLista][02]
							PAY->PAY_SEQ    := _aLista[_nLista][03]
							PAY->PAY_PROD   := _aLista[_nLista][04] 
							PAY->PAY_OP     := _aLista[_nLista][05] 
							PAY->PAY_LOTE   := _aLista[_nLista][06] 
							PAY->PAY_DTFAB  := CtoD(_aLista[_nLista][07])
							PAY->PAY_DTVAL  := CtoD(_aLista[_nLista][08])
							PAY->PAY_HRREG  := _aLista[_nLista][09] 
							PAY->PAY_STATUS := "3"
							PAY->PAY_DTLAUD := CtoD(_aLista[_nLista][10])
							PAY->PAY_CODANL := _aLista[_nLista][11]
							PAY->(MsUnlock())
						
						EndIf

					EndIf
					
				Next _nLista

			Else 
					
				DbSelectArea("PAY")
				RecLock("PAY",.T.)
				PAY->PAY_FILIAL := xFilial("PAY")
				PAY->PAY_CTRL   := "000001" 
				PAY->PAY_SEQ    := "001" 
				PAY->PAY_PROD   := TRBP->ZD_PRODUT 
				PAY->PAY_OP     := TRBP->ZD_OP
				PAY->PAY_LOTE   := TRBP->ZD_LOTE
				PAY->PAY_DTFAB  := CtoD(_dDtFabric) 
				PAY->PAY_DTVAL  := CtoD(_dDtValid) 
				PAY->PAY_HRREG  := time() 
				PAY->PAY_STATUS := "3"
				PAY->PAY_DTLAUD := CtoD(TRBP->ZD_DATA)		
				PAY->PAY_CODANL := TRBP->ZD_CODANAL		

				PAY->(MsUnlock())
			
			EndIf
		
		EndIf

		TRBP->(DbSkip())

		IncProc("Gerando arquivo...")	

	EndDo

	cQuery := ""

	cQuery := "SELECT C2_FILIAL,C2_NUM, C2_PRODUTO, C2_DTETIQ,C2_XDTVALI, C2_DTFABR, C2_DTVALID,C2_NUM,C2_ITEM,C2_SEQUEN,C2_ITEMGRD " + CRLF
	cQuery += "FROM "+RetSqlName("SC2")+" AS SC2 WITH (NOLOCK) " + CRLF 
	cQuery += "INNER JOIN "+RetSqlName("SB1")+" AS SB1 ON C2_PRODUTO = B1_COD " + CRLF
	cQuery += " AND SB1.D_E_L_E_T_ = ' '  " + CRLF
	cQuery += "WHERE C2_FILIAL = '"+xFilial("SC2")+"' " + CRLF
	cQuery += " AND SUBSTRING(C2_PRODUTO,1,3) = '"+AllTrim(Substr(_cProduto,1,3))+"' " + CRLF
	cQuery += " AND C2_NUM     = '"+AllTrim(_cLote)+"' " + CRLF
	cQuery += " AND SC2.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TRBI"

	TRBI->(DbGoTop())

	While TRBI->(!Eof())

		nRecs++

		cQry := " UPDATE " + RetSqlName("SC2") + " "
		cQry += " SET C2_DTETIQ = '" + DtoS(CtoD(_dDtFabric)) + "', C2_XDTVALI = '" + DtoS(CtoD(_dDtValid)) + "',  "
		cQry += " C2_DTFABR = '" + DtoS(CtoD(_dDtFabric)) + "', C2_DTVALID = '" + DtoS(CtoD(_dDtValid)) + "'  "
		cQry += " FROM " + RetSqlName("SC2") + " AS SC2 "
		cQry += " WHERE C2_FILIAL = '"+xFilial("SC2")+"' "
		cQry += " AND C2_NUM     = '" + AllTrim(TRBI->C2_NUM) + "' "
		cQry += " AND C2_PRODUTO = '" + AllTrim(TRBI->C2_PRODUTO) + "' "
		cQry += " AND SC2.D_E_L_E_T_ = ' ' "

		TcSQLExec(cQry)

		aAdd(aPlanilha,{AllTrim("Atualizado"),;       //01
					    AllTrim(TRBI->C2_PRODUTO),;    //02
						AllTrim(TRBI->c2_NUM),;       //03	 
						_dDtFabric,;    //04
						_dDtValid})     //05	     


		TRBI->(DbSkip())

	EndDo

EndIf

If Select("TRBI") > 0
	TRBI->(DbCloseArea())
EndIf
If Select("TRBP") > 0
	TRBP->(DbCloseArea())
EndIf
If Select("SZD") > 0
	SZD->(DbCloseArea())
EndIf

Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEQIP01ok | Autor: | QUALY         | Data: | 28/06/22     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEQIP01ok                                    |
+------------+-----------------------------------------------------------+
*/
Static Function QEQIP01ok()

	Local cArqDst    := "C:\TOTVS\QEIMPQIP_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel     := FWMsExcelEX():New()
	Local nPlan      := 0
	Local cPlan      := "Empresa_" + Rtrim(SM0->M0_CODIGO) + "_Filial_" + Rtrim(SM0->M0_CODFIL)
	Local cTit       := "Relatorio conferencia de carga de dados "

	MakeDir("C:\TOTVS")

	oExcel:AddworkSheet(cPlan)
	oExcel:AddTable(cPlan, cTit)
	oExcel:AddColumn(cPlan, cTit, "Status"             , 1, 1, .F.)  //01
	oExcel:AddColumn(cPlan, cTit, "Produto"            , 1, 1, .F.)  //02
	oExcel:AddColumn(cPlan, cTit, "Num. Lote"          , 1, 1, .F.)  //03
	oExcel:AddColumn(cPlan, cTit, "Data Fabricação"    , 1, 1, .F.)  //04
	oExcel:AddColumn(cPlan, cTit, "Data Validade"      , 1, 1, .F.)  //05


	// preenche as informações na planilha de acordo com o Array aPlanilha 

	For nPlan:=1 To Len(aPlanilha)
		
		lAbre := .T.

		oExcel:AddRow(cPlan,cTit,{aPlanilha[nPlan][01],;
									aPlanilha[nPlan][02],;
									aPlanilha[nPlan][03],;
									aPlanilha[nPlan][04],;
									aPlanilha[nPlan][05]}) 
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






