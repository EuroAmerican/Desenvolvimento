#Include "parmtype.ch"
#Include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Tbiconn.ch"
#Include "Colors.ch"
#Include "RwMake.ch"
#include 'Ap5Mail.ch'

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)

/*/{Protheus.doc} QEAP0803
//Rotina via Sheduler para gravar as notas de despesas  
@author QualyCryl 
@since 02/01/2013
@version 1.0
@Update fabio carbeiro dos santos 
@history ajustado para gravar todos os itens do pedido de compra
@Since 08/03/2022
/*/

User Function QEAP0803(aParam)

Local aArea		    := {}
Local _aPegArray    := {}
Local _nPeg         := 0
Local _nPassa       := 0

Local aNfExist      := {}
Local aUsers        := {}
Local aEmLiber      := {} // Pedido em Liberação
Local cMailTI       := ""

Local cPara   := ""
Local cCopia  := ""
Local cFiltro := ""
Local nX      := 0
Local cNaturez:= ""
Local cRetExec := ""
Local cFileLog := ""

Private cQuery		:= "" 
Private _aCabSF1	:= {}
Private _aItensSD1	:= {}
Private _aLinha		:= {}
Private _lPassa     := .F.
Private _cNumPC     := ""	   	    
Private _cFornece   := ""
Private _cLoja      := ""
Private _cProduto   := ""
Private _cFilial    := ""
Private _cCond      := ""
Private _cDest      := ""
Private _cAprova    := ""
Private _cStatus    := ""
Private _cProces    := ""
Private _nQtdItem   := 0
Private PulaLinha   := chr(13)+chr(10)
Private _cTexto     := '<html>' + PulaLinha
Private _nValor     := 0
Private _cFonte     := 'font-size:10; fonte-family:Arial;'
Private lMsErroAuto := .F.
Private TSC7        := GetNextAlias()


IF ValType(aParam) <> "U"
	WFPrepEnv(aParam[1],aParam[2])

	Conout("*** JOB Geração de Documento de Entrada para Despesass")
	Conout("*** Empresa:"+aParam[1])
	Conout("*** Filial:"+aParam[2])
	Conout("*** Executada em "+dtoc(dDataBase)+" as "+Time())
Else
	Conout("*** JOB Geração de Documento de Entrada para Despesass")
	Conout("*** Empresa:"+cEmpAnt)
	Conout("*** Filial:"+cFilAnt)
	Conout("*** Executada em "+dtoc(dDataBase)+" as "+Time())
Endif

aArea	 := GetArea()
cMailTI  := GetMV("QS_MAILADM")

If Select("TSC7") > 0
	TSC7->(dbCloseArea())
EndIf

cQuery := "SELECT *, (SELECT COUNT(*) FROM " + RetSqlName("SC7")+" AS TMP WITH (NOLOCK) WHERE TMP.D_E_L_E_T_ = '' AND TMP.C7_NUM = SC7.C7_NUM AND TMP.C7_FILIAL = SC7.C7_FILIAL AND SUBSTRING(C7_PRODUTO,1,2) = 'RE')  AS QTDITEM, SC7.R_E_C_N_O_ RECNOSC7   " + CRLF 
cQuery += " FROM " + RetSqlName("SC7")+" AS SC7 WITH (NOLOCK) " + CRLF
cQuery += " WHERE C7_FILIAL = '"+xFilial("SC7")+"'  " + CRLF
cQuery += " AND SUBSTRING(C7_PRODUTO,1,2) = 'RE' " + CRLF 
cQuery += " AND C7_CONAPRO = 'L' " + CRLF
cQuery += " AND C7_QUJE <= 0 " + CRLF
cQuery += " AND C7_APROV <> ' '  " + CRLF
cQuery += " AND C7_XSTATUS <> 'C'  " + CRLF
cQuery += " AND C7_CC <> ' ' " + CRLF
cQuery += " AND C7_EMISSAO >= '"+DtoS(GetMV("QE_DTADESP"))+"' " + CRLF
cQuery += " AND SC7.D_E_L_E_T_ = ' '  " + CRLF
cQuery += " ORDER BY C7_NUM,C7_ITEM   " + CRLF

TCQUERY cQuery NEW ALIAS TSC7
        
TSC7->(DbGoTop())
           
While !TSC7->(EOF())
	dbSelectArea("TSC7")

	// Ignora Pedido de Venda com Liberação Parcial.
	IF !Empty(cFiltro)
		IF &(cFiltro)
			TSC7->(dbSkip())
			Loop
		Endif
	Endif

	_cFilial  := TSC7->C7_FILIAL	
	_cNumPC   := TSC7->C7_NUM	   	    
	_cProduto := TSC7->C7_PRODUTO
	_cFornece := TSC7->C7_FORNECE	
	_cLoja    := TSC7->C7_LOJA		
	_cCond    := TSC7->C7_COND
	_cAprova  := TSC7->C7_CONAPRO
	_cStatus  := TSC7->C7_XSTATUS

	_cProces  := TSC7->C7_TX
	_nQtdItem := TSC7->QTDITEM
	_lPassa   := .F. 		
	
	If TSC7->C7_CONAPRO == 'L' .And. TSC7->C7_QUJE <= 0
		
		//------------------------------------------------------------------
		// Tratamento para não processar pedido de compra que já possua 
		// documento de entrada cadastrado.
		//------------------------------------------------------------------
		dbSelectArea("SF1")
		dbSetOrder(1) // F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO, R_E_C_N_O_, D_E_L_E_T_
		dbSeek(xFilial("SF1")+PadL(TSC7->C7_NUM,9,'0')+"REC"+TSC7->C7_FORNECE+TSC7->C7_LOJA)

		IF Found()
			// Define Filtro para ignorar os proximos itens do mesmo pedido.
			cFiltro := "C7_NUM == '"+_cNumPC+"' .and. C7_FORNECE == '"+_cFornece+"' .AND. C7_LOJA == '"+_cLoja+"'" 

			IF Empty(_cProces)
				Aadd(aNfExist, {TSC7->C7_NUM, TSC7->C7_CONAPRO, TSC7->C7_FORNECE, TSC7->C7_LOJA, SF1->F1_DOC}) 

				fCtrlEmail()
			Endif

			_aCabSF1   := {}
			_aPegArray := {}
			_aLinha    := {}
			_nPassa    := 0
			_nPeg      := 0
			_cTexto    := "" 			

			dbSelectArea("TSC7")
			TSC7->(dbSkip())
			Loop
		Endif

		_lPassa := .T.

		aAdd(_aPegArray,{TSC7->C7_CONAPRO,; //01
						TSC7->C7_PRODUTO,;  //02 
						TSC7->C7_FORNECE,;  //03
						TSC7->C7_LOJA,;     //04 
						TSC7->C7_NUM,;	   	//05   
						TSC7->C7_QUJE,;     //06 
						TSC7->C7_CONAPRO,;  //07
						TSC7->C7_FILIAL,;	//08
						TSC7->C7_COND,;     //09
						TSC7->C7_ITEM,;     //10
						TSC7->C7_UM,;       //11
						TSC7->C7_QUANT,;    //12
						TSC7->C7_PRECO,;    //13  
						TSC7->C7_TOTAL,;    //14
						TSC7->C7_TES,;      //15 
						TSC7->C7_CC,;       //16
						TSC7->C7_LOCAL,;    //17
						_lPassa})           //18
		
	Else 
		// Define Filtro para ignorar os proximos itens do mesmo pedido.
		cFiltro := "C7_NUM == '"+_cNumPC+"' .and. C7_FORNECE == '"+_cFornece+"' .AND. C7_LOJA == '"+_cLoja+"'" 

		Conout("*** Pedido de compra....: "+_cNumPC)
		Conout("*** Produto.............: "+_cProduto)
		Conout("*** Entregua Parcial....: "+IIF(TSC7->C7_QUJE > 0, "Sim", "Não"))
		Conout("*** Status da Liberação.: "+_cAprova)
		Conout("*** Status Processamento: "+_cStatus)
		Conout("----------------------------------------------------------------")

		_lPassa := .F.
	
	EndIf 

	TSC7->(dbSkip())

	// Controle de Mudança de Pedido de Compra
	If TSC7->(EOF()) .Or. TSC7->C7_NUM <> _cNumPC 

		//------------------------------------------------------------------
		// - Se o Pedido de Compra estiver liberado apenas parcialmente, 
		// deixa a geração da Nota de Entrada para o proximo processamento.
		//------------------------------------------------------------------
		IF Len(_aPegArray) < _nQtdItem
			// Define Filtro para ignorar os proximos itens do mesmo pedido.
			cFiltro := "C7_NUM == '"+_cNumPC+"' .and. C7_FORNECE == '"+_cFornece+"' .AND. C7_LOJA == '"+_cLoja+"'" 

			_aCabSF1   := {}
			_aPegArray := {}
			_aLinha    := {}
			_nPassa    := 0
			_nPeg      := 0
			_cTexto    := "" 			

			IF Empty(_cProces)
				// Alimenta array para envio de email
				Aadd(aEmLiber, {_cNumPC, _cFornece, _cLoja})

				fCtrlEmail()
			Endif

			dbSelectArea("TSC7")
			Loop
		Endif

		If _lPassa  
			lMsErroAuto     :=	.F.

			_aCabSF1 := {}
				
			Aadd(_aCabSF1,{"F1_FILIAL"		,_cFilial	,Nil})
			Aadd(_aCabSF1,{"F1_TIPO"		,"N"				,Nil})
			Aadd(_aCabSF1,{"F1_FORMUL"		,"N"				,Nil})
			Aadd(_aCabSF1,{"F1_DOC"			,StrZero(Val(_aPegArray[1][05]),9)	,Nil})
			Aadd(_aCabSF1,{"F1_SERIE"		,"REC"				,Nil})
			Aadd(_aCabSF1,{"F1_EMISSAO"		,dDataBase			,Nil})
			Aadd(_aCabSF1,{"F1_FORNECE"     ,_cFornece	        ,Nil})
			Aadd(_aCabSF1,{"F1_LOJA"		,_cLoja		        ,Nil})
			Aadd(_aCabSF1,{"F1_ESPECIE"		,"RECIB"			,Nil})
			Aadd(_aCabSF1,{"F1_COND"		,_cCond	        	,Nil})
			Aadd(_aCabSF1,{"F1_DTDIGIT"		,dDataBase			,Nil})
			Aadd(_aCabSF1,{"F1_EST"			," "				,Nil})

			If	AllTrim(_cProduto) $ "RE.0017"
				Aadd(_aCabSF1,{"E2_NATUREZ"		,"0403004"		,Nil})	// 1403.1
			ElseIf AllTrim(_cProduto) $ "RE.0018"
				Aadd(_aCabSF1,{"E2_NATUREZ"		,"0402046"		,Nil})  // 1606
			ElseIf AllTrim(_cProduto) $ "RE.0019"
				Aadd(_aCabSF1,{"E2_NATUREZ"		,"0404004"		,Nil})  // 1304
			ElseIf AllTrim(_cProduto) $ "RE.0021"
				Aadd(_aCabSF1,{"E2_NATUREZ"		,"0202004"		,Nil})  // 1519
			ElseIf AllTrim(_cProduto) $ "RE.0022"
				Aadd(_aCabSF1,{"E2_NATUREZ"		,"0402003"		,Nil})  // 1402
			ElseIf AllTrim(_cProduto) $ "RE.0030"
				Aadd(_aCabSF1,{"E2_NATUREZ"		,"0403005"		,Nil})  // 1403.2
			ElseIf AllTrim(_cProduto) $ "RE.0031"
				Aadd(_aCabSF1,{"E2_NATUREZ"		,"0402060"		,Nil})  // 1901
			ElseIf AllTrim(_cProduto) $ "RE.0033"
				Aadd(_aCabSF1,{"E2_NATUREZ"		,"0402071"		,Nil})  // 1931
			ElseIf AllTrim(_cProduto) $ "RE.0034"
				Aadd(_aCabSF1,{"E2_NATUREZ"		,"0402072"		,Nil})  // 1932
			ElseIf AllTrim(_cProduto) $ "RE.0035"
				Aadd(_aCabSF1,{"E2_NATUREZ"		,"0202003"		,Nil})  // 1514 	
			ElseIf AllTrim(_cProduto) $ "RE.0036"
				Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301008"		,Nil})  // 1802
			ElseIf AllTrim(_cProduto) $ "RE.0037"
				Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301009"		,Nil})  // 1803
			ElseIf AllTrim(_cProduto) $ "RE.0038"
				Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301010"		,Nil})  // 1804	
			ElseIf AllTrim(_cProduto) $ "RE.0039"
				Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301007"		,Nil})  // 1801	
			ElseIf AllTrim(_cProduto) $ "RE.0040"
				Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301011"		,Nil})  // 1806	
			ElseIf AllTrim(_cProduto) $ "RE.0041"
				Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301016"		,Nil})  // 1899	
			ElseIf AllTrim(_cProduto) $ "RE.0042"
				Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301001"		,Nil})  // 1447
			ElseIf AllTrim(_cProduto) $ "RE.0044"
				Aadd(_aCabSF1,{"E2_NATUREZ"		,"0402050"		,Nil})  // 1719				
			ElseIf AllTrim(_cProduto) $ "RE.SGA.0049"
				Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301021"		,Nil})  			
			Else
				Aadd(_aCabSF1,{"E2_NATUREZ"		,"0402068"		,Nil})  // 1917
			EndIf
			
			_aItensSD1  := {}
			For _nPeg:=1 To Len(_aPegArray)	
				If  _aPegArray[_nPeg][18]
					_aLinha		:= {}

					Aadd(_aLinha,{"D1_FILIAL"	,_aPegArray[_nPeg][08]	,Nil})
					Aadd(_aLinha,{"D1_ITEM"		,StrZero(Val(_aPegArray[_nPeg][10]),4),Nil})  
					Aadd(_aLinha,{"D1_FORNECE"	,_aPegArray[_nPeg][03]	,Nil})
					Aadd(_aLinha,{"D1_LOJA"		,_aPegArray[_nPeg][04]	,Nil})
					Aadd(_aLinha,{"D1_DOC"		,StrZero(Val(_aPegArray[_nPeg][05]),9)	,Nil})
					Aadd(_aLinha,{"D1_PEDIDO"	,_aPegArray[_nPeg][05]	,Nil})	
					Aadd(_aLinha,{"D1_COD"		,_aPegArray[_nPeg][02]	,Nil})
					Aadd(_aLinha,{"D1_UM"		,_aPegArray[_nPeg][11]	,Nil})
					Aadd(_aLinha,{"D1_QUANT"	,_aPegArray[_nPeg][12]	,Nil})
					Aadd(_aLinha,{"D1_VUNIT"	,_aPegArray[_nPeg][13]	,Nil})
					Aadd(_aLinha,{"D1_TOTAL"	,_aPegArray[_nPeg][14]	,Nil})
					Aadd(_aLinha,{"D1_TES"		,IIf(Empty(AllTrim(_aPegArray[_nPeg][15])),"000",_aPegArray[_nPeg][15]),Nil})		
					Aadd(_aLinha,{"D1_CF"		,"1949"				   ,Nil})
					Aadd(_aLinha,{"D1_CC"		,_aPegArray[_nPeg][16] ,Nil})	
					Aadd(_aLinha,{"D1_ITEMPC"	,_aPegArray[_nPeg][10] ,Nil})
					Aadd(_aLinha,{"D1_EMISSAO"	,dDataBase				})
					Aadd(_aLinha,{"D1_DTDIGIT"	,dDataBase			   ,Nil})
					Aadd(_aLinha,{"D1_LOCAL"	,_aPegArray[_nPeg][17] ,Nil})
					Aadd(_aLinha,{"D1_SERIE"	,"REC"				,Nil})
					Aadd(_aLinha,{"D1_TIPO"		,"N"				,Nil})
					Aadd(_aLinha,{"D1_FORMUL"	,"N"					})
					Aadd(_aLinha,{"D1_RATEIO"	,"2"				,Nil})
					Aadd(_aLinha,{"D1_TP"		,"RE"				,Nil})
					Aadd(_aLinha,{"AUTDELETA"	,"N"				,Nil})	

					Aadd(_aItensSD1,_aLinha)
				Else 
					_lPassa := .F.
					Exit
				EndIf		
			Next _nPeg
				
			If  _lPassa 
				Conout("*** Executado MSExecAuto para o Pedido de Compra: "+_cNumPC)
				Conout("*** Processado em "+dtoc(dDataBase)+" as "+Time())

				MSExecAuto({|x,y,z| MATA103(x,y,z)},_aCabSF1,_aItensSD1,3)
					
				If lMsErroAuto
					cFileLog := "PC"+_cNumPC+"_"+StrTran(Time(), ":", "")+".Log"
					cRetExec := MostraErro("\System\", cFileLog)
					cRetExec := Subs(cRetExec,1,1800)

					U_QEMAIL08("paulo.santos@euroamerican.com.br","","**ERRO** - Pedido de Compra NÚmero - : "+_cNumPC,"OCORREU ERRO NA ROTINA MsExecAuto:"+chr(13)+chr(10)+cRetExec,"\System\"+cFileLog,.T.)

					conout("*** Deu erro na rotina de MsExecauto: "+cRetExec)
				Else
					Conout("*** Pedido Gravado com Sucesso...")

					For _nPassa:=1 To Len(_aPegArray)

						DbSelectArea("SC7")
						DbSetOrder(2) // C7_FILIAL, C7_PRODUTO, C7_FORNECE, C7_LOJA, C7_NUM, R_E_C_N_O_, D_E_L_E_T_
						If SC7->(dbSeek(xFilial("SC7")+_aPegArray[_nPassa][02]+_aPegArray[_nPassa][03] +_aPegArray[_nPassa][04]+_aPegArray[_nPassa][05])) //C7_FILIAL+C7_PRODUTO+C7_FORNECE+C7_LOJA+C7_NUM
							Reclock("SC7",.F.)

							SC7->C7_XSTATUS  := 'S'

							SC7->( Msunlock() )
						Endif
					Next _nPassa

					//DBCommitAll()

					_cTexto += '<b><font size="3" face="Arial">O Título / Nf referente ao Pedido de compras abaixo foi incluído pela rotina SCHEDULER.</font></b><br><br>'
					_cTexto += '<b><font size="2" face="Arial">Numero Pedido de Compras: '+_cNumPC+'</b><br>'
					_cTexto += '<b><font size="2" face="Arial">Código do Fornecedor: '+_cFornece+'</b><br>'
					_cTexto += '<b><font size="2" face="Arial">Loja Do Fornecedor: '+_cLoja +'</b><br>'
					_cTexto += '<b><font size="2" face="Arial">Status da LIberação: '+If(_cAprova=='L','Liberado','Não LIberado')+'</b><br>'
					_cTexto += '<br><br><b><font size="3" face="Arial" color="Blue">'+AllTrim(SM0->M0_NOME)+' - '+AllTrim(SM0->M0_FILIAL)+'</font></b><br>'
					_cTexto += '</html>'

					_cDest := GetMV("QE_LSTDSP")
					
					If !Empty(_cDest).And.Len(_cTexto)>30
						Conout("*** Enviado email ")
						U_QEMAIL08(_cDest,"","Pedido de Compra NÚmero - : "+_cNumPC,_cTexto,"",.T.)
					EndIf
					
					_cTexto := ""
				Endif
			EndIf
			
		EndIf
	
		_aCabSF1   := {}
		_aPegArray := {}
		_aLinha    := {}
		_aItensSD1 := {}
		_nPassa    := 0
		_nPeg      := 0
		_cTexto    := "" 
	EndIf
EndDo

//-----------------------------------------------------------------
// - Envia Email com a relação de pedidos de compra para os quais
// o sistema não pode gerar Documento de Entrada
//-----------------------------------------------------------------
IF Len(aNfExist) > 0 
	_cTexto := '<b><font size="3" face="Arial">Já Existe Documento de Entrada para os Pedidos de Compra abaixo, portanto os mesmos não puderam ser processados pela rotina SCHEDULER.</font></b><br><br>'

	dbSelectArea("SA2")
	dbSetOrder(1)

	For nX := 1 to Len(aNfExist) 
		dbSeek(xFilial("SA2") + aNfExist[nX][3] + aNfExist[nX][4])

		aUsers := fGetUserMail(aNfExist[nX][1])

		_cTexto += '<b><font size="2" face="Arial">Numero Pedido de Compras: '+aNfExist[nX][1]+'</b><br>'
		_cTexto += '<b><font size="2" face="Arial">Código do Fornecedor: '+A2_COD+'</b><br>'
		_cTexto += '<b><font size="2" face="Arial">Loja Do Fornecedor: '+A2_LOJA +'</b><br>'
		_cTexto += '<b><font size="2" face="Arial">Status da LIberação: '+If(aNfExist[nX][2]=='L','Liberado','Não LIberado')+'</b><br>'
		_cTexto += '<b><font size="2" face="Arial">Aprovador(es): '+aUsers[1]+'</b><br>'
		_cTexto += '<b><font size="2" face="Arial">Documento de Entrada: '+aNfExist[nX][5] + "/ REC"+'</b><br><hr>'
	Next

	_cTexto += "<b><font size='3' face='Arial'>Procedimento de Normalização do Processo</font></b><br>"
    _cTexto += "- Exclua o Documento de Entrada - [Área Fiscal]; <br>"
	_cTexto += "- Realize o estorno da Aprovação do Pedido de Compra - [Aprovador]; <br>"
	_cTexto += "- Realize nova aprovação - [Aprovador]. <br>"

	_cTexto += '<br><br><b><font size="3" face="Arial" color="Blue">'+AllTrim(SM0->M0_NOME)+' - '+AllTrim(SM0->M0_FILIAL)+'</font></b><br>'
	_cTexto += '</html>'


	cPara  := "maria.pereira@euroamerican.com.br;"+aUsers[2] // "maria.pereira@euroamerican.com.br"
	cCopia := "ricardo.silva@euroamerican.com.br;herica.carvalho@euroamerican.com.br;"+cMailTI

	//cPara  :=cMailTI
	//cCopia := ""

	u_FSENVMAIL("Documento de Entrada JÁ EXISTE para Pedido(s) de Despesa(s)", _cTexto, cPara,"",,,,,,,,cCopia,)

	Conout("***Geração do Documento de entrada abortada por motivo: Já existe NF relacoonada ao pedido de compra...")
Endif
      

//-----------------------------------------------------------------
// - Envia Email informativo para a area de TI sobre pedidos de 
// compra que o sistema identificou como estando em processo de 
// liberação e abortou a geração do Documento de Entrada.
//-----------------------------------------------------------------
IF Len(aEmLiber) > 0 
	_cTexto := '<b><font size="3" face="Arial">Pedidos em Processo de Liberação para os quais não foi gerado Documento de Entrada via rotina SCHEDULER.</font></b><br><br>'

	dbSelectArea("SA2")
	dbSetOrder(1)

	For nX := 1 to Len(aEmLiber) 
		dbSeek(xFilial("SA2")+aEmLiber[nX][2]+aEmLiber[nX][3])

		_cTexto += '<b><font size="2" face="Arial">Numero Pedido de Compras: '+aEmLiber[nX][1]+'</b><br>'
		_cTexto += '<b><font size="2" face="Arial">Código do Fornecedor: '+A2_COD+'</b><br>'
		_cTexto += '<b><font size="2" face="Arial">Loja Do Fornecedor: '+A2_LOJA +'</b><br><hr>'
	Next

	_cTexto += "<b><font size='3' face='Arial'>IMPORTANTE:</font></b><br>"
    _cTexto += "Os pedidos listados acima serão processados novamente no próximo evento do JOB<br>"
	_cTexto += "e provalvemente serão concluidos. Caso isso não ocorra nos próximos minutos, verifique  <br>"
	_cTexto += "o status (C7_XSTATUS) dos mesmos no SC7 e providêncie solução, caso necessário. <br>"

	_cTexto += '<br><br><b><font size="3" face="Arial" color="Blue">'+AllTrim(SM0->M0_NOME)+' - '+AllTrim(SM0->M0_FILIAL)+'</font></b><br>'
	_cTexto += '</html>'

	u_FSENVMAIL("Pedidos de Compras ** EM LIBERAÇÃO **", _cTexto, cMailTI,"",,,,,,,,"",)

	Conout("***Geração do Documento de entrada abortada por motivo de liberação parcial do pedido de compra...")
Endif

TSC7->(dbCloseArea())

RestArea(aArea)

Return ()

/*/{Protheus.doc} QEMAIL08 
//Função de Envio de e-mail QUALY 
@author Fabio Carneiro dos Santos 
@since 09/03/2022
@version 1.0
/*/

User Function QEMAIL08(cRecebe,cCopia,cAssunto,cMensagem,cFile,lDisplay)

// PRS ************************** FPrepEnv("10","0803")

Private cServer   := GetMV("MV_RELSERV")
Private cAccount  := GetMV("MV_RELACNT")
Private cEnvia    := GetMV("MV_RELACNT")
Private cPassword := GetMV("MV_RELPSW")

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lConectou

If lConectou
	MAILAUTH(cAccount,cPassword)     //Esta função faz a autenticação no servidor
   If lDisplay
	   //Alert("Conectado com servidor - " + cServer)
   Endif
Else
	cError := ""
	GET MAIL ERROR cError
	If lDisplay
	   Alert(cError+" no Servidor SMTP")
	Endif
Endif

//Procurar e-mail do usuário
Email  	 := "workflow@qualyvinil.com.br"
If !Empty(Email)
	cRem   := "EUROAMERICAN"/*AllTrim(cNomeUsr)*/+" <"+cEnvia+">"
	If !Email$cRecebe
		//cCopia := Email 
		cCopia := Email
	EndIf
Else
	cRem := "QUALYCRYL"/*AllTrim(cNomeUsr)*/+" <"+GetMV("MV_RELFROM")+">"
	cCopia := "fabio.santos@euroamerican.com.br"
EndIF


If !Empty(cRem)
	cEnvia := cRem
EndIf

If !Empty(cFile) 
   SEND MAIL FROM cEnvia;
	     TO cRecebe;
	     CC cCopia ;
	     SUBJECT cAssunto;
	     BODY cMensagem;
         ATTACHMENT cFile;
	     FORMAT TEXT;
	     RESULT lEnviado
Else	     
	SEND MAIL FROM cEnvia;
	     TO cRecebe;
	     CC cCopia ;
	     SUBJECT cAssunto;
	     BODY cMensagem;
	     FORMAT TEXT;
	     RESULT lEnviado
Endif	     

If lEnviado
   If lDisplay  
	//aviso("Envio E-mail!","Enviado e-mail para analise " + cRecebe,{"OK"})
   Endif

   Conout("*** Enviado e-mail para analise. ")
Else
	GET MAIL ERROR cMensagem 
	If lDisplay
	   Alert(cMensagem+":"+cAssunto)
	Endif                         
	Return .F.
Endif
   
DISCONNECT SMTP SERVER Result lDisConectou

If lDisConectou
   If lDisplay
//	   Alert("Desconectado do servidor - " + cServer)
   Endif
Endif

Return  .T.



/*/{Protheus.doc} fGetUserMail 
//Função para identificar destinatario de email
@author Paulo Rogério
@since 05/08/2022
@version 1.0
/*/

Static Function fGetUserMail(cNumPC)
Local cQuery   := ""
Local aRet     := {}
Local aArea := GetArea()
Local cMail := ""
Local cNome := ""


cQuery := " SELECT DISTINCT CR_APROV, AK_NOME, AK_USER , USR_EMAIL "+ CRLF 
cQuery += "   FROM " + RetSqlName("SCR")+" AS SCR WITH (NOLOCK) " + CRLF
cQuery += "  INNER JOIN " + RetSqlName("SAK")+" AS SAK WITH (NOLOCK) ON AK_COD = CR_APROV " + CRLF
cQuery += "  INNER JOIN SYS_USR AS TMP ON USR_ID = AK_USER AND TMP.D_E_L_E_T_ = '' " + CRLF
cQuery += "  WHERE CR_NUM = '"+cNumPC+"'"
cQuery += "    AND CR_FILIAL = '"+xFilial("SCR")+"'" + CRLF
cQuery += "    AND SCR.D_E_L_E_T_ = ''  " + CRLF

TCQUERY cQuery NEW ALIAS "TMP"
dbSelectArea("TMP")

Do While !Eof()

	/*
	cNomeUsr := UsrRetName(RetCodUsr(TMP->AK_USER))
	PswOrder(2) // Ordem de nome
	PswSeek(cNomeUsr, .T.)

	aRetUser := PswRet(1)
	cRet     := IIF(alltrim(aRetUser[1,14]) <> "", alltrim(aRetUser[1,14]) + ";", "")
	*/

	cMail     += IIF(alltrim(TMP->USR_EMAIL) <> "", alltrim(TMP->USR_EMAIL) + ";", "")
	cNome     += Alltrim(TMP->AK_NOME) + ", "

	dbSkip()
Enddo 

Aadd(aRet, cNome)
Aadd(aRet, cMail)

dbCloseArea()
RestArea(aArea)

Return(aRet)


/*/{Protheus.doc} fCtrlEmail 
//Função para Controlar envio de email
@author Paulo Rogério
@since 05/08/2022
@version 1.0
/*/
Static Function fCtrlEmail()
Local cQuery := ""

	// ------------------------------------------------------------
	// Paulo Rogerio - 05/08/2022
	// -------------------------------------------------------------
	// Para evitar que o sistema envie e-mail toda vez que entrar
	// na rotina via JOB, faço o controle  de email através
	// desse campo padrão do sistema (medida paliativa). Antes de 
	// replicar a alteração para as demais empresas será criado um
	// novo campo especifico para esse controle.
	// -------------------------------------------------------------

	cQuery := ""
	cQuery += "UPDATE "+RetSqlName("SC7") + CRLF
	cQuery += "   SET C7_TX = '*' "+ CRLF
	cQuery += " WHERE C7_FILIAL = '"+xFilial("SC7")+"'  " + CRLF
	cQuery += " AND C7_NUM = '"+_cNumPC+"'" + CRLF 
	cQuery += " AND C7_FORNECE = '"+_cFornece+"'" + CRLF
	cQuery += " AND C7_LOJA = '"+_cLoja+"'" + CRLF
	cQuery += " AND D_E_L_E_T_ = ' '  " + CRLF			

	TCSqlExec( cQuery )
Return
