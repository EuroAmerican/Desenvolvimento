#include 'protheus.ch'
#include 'parmtype.ch'
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "ap5mail.ch"
#Include "Totvs.ch"
#Include "FwBrowse.ch"
#Include "FwMvcDef.ch"
#Include 'FwCalendarWidget.ch'

/*/{Protheus.doc} FWSTATUS
//Rotina para controle de venda
@author Fabio Batista
@since 18/08/2020
@version 1.0
/*/

User Function FWSTATUS()

Private __oDlg

Private cPedD    := SPACE(06)
Private cPedAt   := SPACE(06)
Private dDatD    := CTOD("")
Private dDatAt   := CTOD("")


Private cNotaD   := SPACE(09)//CTOD("")
Private cNotaAt  := SPACE(09)//CTOD("")

Private cCargD   := SPACE(06)
Private cCargAt  := SPACE(06)

Private dDtCarAt := CTOD("")
Private dDtCarD  := CTOD("")
Private nDias    := SPACE(03)


	DEFINE MSDIALOG __oDlg FROM 0,0 TO 350,290 PIXEL TITLE "Tela Faturamento"
	@ 017,12 Say "Pedido de Venda de ?"         of __oDlg Pixel
	@ 016,74 MsGet cPedD Picture "@!" F3 "SC5"  of __oDlg Pixel

	@ 033,12 Say "Pedido de Venda até ?"         of __oDlg Pixel
	@ 032,74 MsGet cPedAt Picture "@!" F3 "SC5"  of __oDlg Pixel

	@ 049,12 Say "Data Emissão PV de ?"  of __oDlg Pixel
	@ 048,74 MsGet dDatD Picture "@!"    of __oDlg Pixel

	@ 065,12 Say "Data Emissão PV até ?" of __oDlg Pixel
	@ 064,74 MsGet dDatAt Picture "@!"   of __oDlg Pixel

//	@ 081,12 Say "Nota de ?"  					  of __oDlg Pixel
//	@ 080,74 MsGet cNotaD Picture "@!"  F3 "SF2"  of __oDlg Pixel

//	@ 097,12 Say "Nota até ?"                    of __oDlg Pixel
//	@ 096,74 MsGet cNotaAt Picture "@!" F3 "SF2" of __oDlg Pixel
	//@ 096,74 MsGet cOrdemAt Picture "@!" F3 "CB7" VALID !Empty(cOrdemD) of __oDlg Pixel

//	@ 113,12 Say "Carga de ?"                   of __oDlg Pixel
//	@ 112,74 MsGet cCargD Picture "@!" F3 "SZF" of __oDlg Pixel

//	@ 129,12 Say "Carga até ?"                   of __oDlg Pixel
//	@ 128,74 MsGet cCargAt Picture "@!" F3 "SZF" of __oDlg Pixel

//	@ 145,12 Say "Data da Carga de ?"            of __oDlg Pixel
//	@ 144,74 MsGet dDtCarD Picture "@!" of __oDlg Pixel
	
//	@ 161,12 Say "Data da Carga até ?"   of __oDlg Pixel
//	@ 160,74 MsGet dDtCarAt Picture "@!" of __oDlg Pixel

	//@ 177,12 Say "Dias atraso"   of __oDlg Pixel
	//@ 176,74 MsGet nDias Picture "@!" of __oDlg Pixel

	@ 093,034 BUTTON "Processar" SIZE 28,13 PIXEL OF __oDlg ACTION telapar(__oDlg)
	@ 093,081 BUTTON "Sair"      SIZE 28,13 PIXEL OF __oDlg ACTION __oDlg:End()
			
	ACTIVATE MSDIALOG __oDlg CENTERED

Return


Static function telapar()
//alert("teste")
	RptStatus({|| tela01()}, "Aguarde...", "Executando rotina...")
Return


Static Function tela01()

Local aFixes := {} //Array Fixos                                                       
Local oDlg, oLbx //Dialog, Label
Local oButton2, oButton3, oButton4, oButton5, oButton6, oButton7, oButton8, oButton9, oButton10, oButton11, oButton12 //Botoes
Local aBotoesTmp := {} 
Local aAreaSM0 := SM0->(GetArea())

Local cQuery := ''
Local TMP    := GetNextAlias()
Local nX     := 0
//Local cPerg  := 'FWSTA'

Private aTarefas := {}  //Array tarefas  
Private aCores    := {}
Private cCadastro := "Monitor de Serviços Faturamento"  //"Monitor de Serviços E-Commerce"

Private aRotina := {{"Pesquisar","PesqBrw",0,1},; //"Pesquisar"
{"Alterar"          ,"Lj906Alt",0,2},; //"Alterar"
{"Executar"         ,"Lj906Exc",0,2},; //"Executar"
{"Legenda"          ,"Lj906Log",0,3},; //"Legenda"
{"Relatório"        ,"LOJR902",0,3},; //"Relatório"
{"Ped. C/ Prob."    ,"LOJR903",0,3}} //"Ped. C/ Prob."

	If Empty(cPedAt) .or. Empty(dDatD) .or. Empty(dDatAt) 
		Alert('Existe campo em branco favor preencher')
		Return
	EndIf 

__oDlg:End()
      //PedAtraso()

DEFINE MSDIALOG oDlg FROM  0,0 TO 600,1200 TITLE cCadastro   PIXEL //tela de fora (monitor de serviço Faturamento)
               
@ 030, 050 GROUP oGroup1 TO 295, 590 PROMPT "Status Faturamento" OF oDlg COLOR 0, 16777215 PIXEL 

 cQuery := " SELECT DISTINCT C5_FILIAL,C5_NUM,C5_CLIENTE,C5_LOJACLI,C5_VEND1,C5_EMISSAO " + CRLF
 cQuery += " ,C6_ENTREG " + CRLF
 cQuery += " ,DATEDIFF(DAY,CONVERT(DATETIME,C6_ENTREG), CONVERT(DATETIME,ISNULL(ZF_EMISSAO,CONVERT(VARCHAR(8),GETDATE())))) AS DIAS " + CRLF
 cQuery += " ,A1_COD,A1_NOME, ISNULL(D2_SERIE, '') AS D2_SERIE, ISNULL(D2_DOC, '') AS D2_DOC " + CRLF
 cQuery += " ,ISNULL(ZF_NUM, '-') AS ZF_NUM " + CRLF
 cQuery += " ,ISNULL(F2_HORA, '-') AS F2_HORA " + CRLF
 cQuery += " ,ISNULL(F2_EMISSAO, '-') AS F2_EMISSAO" + CRLF
 cQuery += " ,ISNULL (ZG_RETORNO,'-') AS ZG_RETORNO " + CRLF
 cQuery += " ,ISNULL (A3_NREDUZ, '-') AS A3_NREDUZ" + CRLF
 cQuery += " ,ISNULL (ZF_EMISSAO,'-') AS ZF_EMISSAO " + CRLF
 cQuery += " ,ISNULL( OSNOTA.CB7_ORDSEP, ISNULL(OSPED.CB7_ORDSEP, '-')) AS ORDEMSEP " + CRLF
 cQuery += " ,ISNULL (ZG_DTENTR,'-') AS ZG_DTENTR " + CRLF
 cQuery += " FROM       "+RetSqlName("SC5") + " SC5 " + CRLF
 cQuery += " INNER JOIN "+RetSqlName("SA1") + " SA1 ON A1_FILIAL = C5_FILIAL AND C5_CLIENTE = A1_COD AND C5_LOJACLI = A1_LOJA AND SA1.D_E_L_E_T_ = ' '" + CRLF
 cQuery += " INNER JOIN "+RetSqlName("SC6") + " SC6 ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND SC6.D_E_L_E_T_='' " + CRLF
 cQuery += " LEFT JOIN  "+RetSqlName("SD2") + " SD2  ON D2_FILIAL = C5_FILIAL AND D2_PEDIDO = C5_NUM AND D2_ITEMPV = C6_ITEM AND SD2.D_E_L_E_T_ = ' '  " + CRLF
 
 //cQuery += " LEFT JOIN  "+RetSqlName("SF2") + " SF2  ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA AND F2_TIPO = D2_TIPO AND F2_DOC BETWEEN '"+cNotaD+"' AND '"+cNotaAt+"' AND SF2.D_E_L_E_T_ = ' ' WITH (NOLOCK) " + CRLF
 cQuery += " LEFT JOIN  "+RetSqlName("SF2") + " SF2  ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA AND F2_TIPO = D2_TIPO AND SF2.D_E_L_E_T_ = ' ' " + CRLF

 //cQuery += " LEFT JOIN  "+RetSqlName("SZG") + " SZG  ON ZG_FILIAL = '"+xFilial("SZF")+"' AND ZG_EMPFIL = '"+CFILANT +"' AND ZG_NOTA = D2_DOC AND ZG_SERIE = D2_SERIE AND ZG_CLIENTE = D2_CLIENTE AND ZG_LOJA = D2_LOJA AND ZG_RETORNO IN( '1','' ) AND ZG_DTENTR <> '' AND SZG.D_E_L_E_T_ = ''  " + CRLF
 cQuery += " LEFT JOIN  "+RetSqlName("SZG") + " SZG  ON ZG_FILIAL = '"+xFilial("SZF")+"' AND ZG_EMPFIL = '"+CFILANT +"' AND ZG_NOTA = D2_DOC AND ZG_SERIE = D2_SERIE AND ZG_CLIENTE = D2_CLIENTE AND ZG_LOJA = D2_LOJA AND ZG_DTENTR <> '' AND SZG.D_E_L_E_T_ = ''" + CRLF
 
 //cQuery += " LEFT JOIN  "+RetSqlName("SZF") + " SZF  ON ZF_FILIAL = ZG_FILIAL AND ZF_NUM = ZG_NUM  AND ZF_NUM  BETWEEN '"+cCargD+"' AND '"+cCargAt+"' AND ZF_EMISSAO BETWEEN '"+DTOS(dDtCarD)+"' AND '"+DTOS(dDtCarAt)+"' AND SZG.D_E_L_E_T_ = '' WITH (NOLOCK) " + CRLF
 cQuery += " LEFT JOIN  "+RetSqlName("SZF") + " SZF  ON ZF_FILIAL = ZG_FILIAL AND ZF_NUM = ZG_NUM AND SZG.D_E_L_E_T_ = '' " + CRLF
 
 cQuery += " LEFT JOIN  "+RetSqlName("SA3") + " SA3  ON A3_FILIAL = '' AND A3_COD = C5_VEND1 AND SA3.D_E_L_E_T_ = '' " + CRLF
 cQuery += " LEFT JOIN  "+RetSqlName("CB7") + " OSNOTA ON OSNOTA.CB7_FILIAL = C5_FILIAL AND OSNOTA.CB7_NOTA = F2_DOC AND OSNOTA.CB7_CLIENT = F2_CLIENTE AND OSNOTA.CB7_LOJA = F2_LOJA AND OSNOTA.CB7_ORIGEM = '2'AND OSNOTA.D_E_L_E_T_ = ' ' " + CRLF
 cQuery += " LEFT JOIN  "+RetSqlName("CB7") + " OSPED  ON OSPED.CB7_FILIAL = C5_FILIAL AND OSPED.CB7_PEDIDO = C5_NUM AND OSPED.CB7_ORIGEM = '1' AND OSPED.D_E_L_E_T_ = ' ' " + CRLF
 cQuery += " WHERE C5_FILIAL = '"+cFilAnt+"' AND SC5.D_E_L_E_T_ = ''  " + CRLF
 cQuery += " AND C5_NUM  BETWEEN '"+cPedD+"' AND '"+cPedAt+"' " + CRLF 
 cQuery += " AND C5_EMISSAO BETWEEN '"+DTOS(dDatD)+"' AND '"+DTOS(dDatAt)+"' " + CRLF
 cQuery += " GROUP BY C5_FILIAL,C5_NUM,C5_CLIENTE,C5_LOJACLI,C5_VEND1,C5_EMISSAO " + CRLF
 cQuery += " ,A1_COD,A1_NOME, D2_SERIE, D2_DOC, ZF_NUM" + CRLF
 cQuery += " ,F2_HORA, F2_EMISSAO" + CRLF
 cQuery += " ,ZG_RETORNO" + CRLF
 cQuery += " ,A3_NREDUZ " + CRLF
 cQuery += " ,ZF_EMISSAO " + CRLF
 cQuery += " ,OSNOTA.CB7_ORDSEP " + CRLF
 cQuery += " ,OSPED.CB7_ORDSEP " + CRLF
 cQuery += " ,C6_ENTREG " + CRLF
 cQuery += " ,C6_DATFAT " + CRLF
 cQuery += " ,C6_NOTA " + CRLF
 cQuery += " ,ZG_DTENTR " + CRLF
  cQuery += " ORDER BY C5_FILIAL,C5_NUM,D2_SERIE,D2_DOC,ZF_NUM,C5_CLIENTE,C5_LOJACLI " + CRLF

//conout("Query FB: "+cquery)

//IncRegua()

oBrowse1 := FWBrowse():New( oGroup1 )        
oBrowse1:SetDataQuery(.T.)
oBrowse1:SetQuery(cQuery)
oBrowse1:SetQueryIndex({"C5_FILIAL+C5_NUM+D2_SERIE+D2_DOC+ZF_NUM+C5_CLIENTE+C5_LOJACLI"})
oBrowse1:SetAlias("TMP1")              
oBrowse1:SetUniqueKey({"C5_FILIAL","C5_NUM","D2_SERIE","D2_DOC","ZF_NUM","C5_CLIENTE","C5_LOJACLI"})
oBrowse1:DisableConfig()
oBrowse1:DisableReport()
//quando inclui o filtro não está trazendo o pedido que não foi gerado doc saida
//oBrowse1:SetFilterDefault( " AllTrim( TMP1->ZG_RETORNO ) == '' .or. AllTrim( TMP1->ZG_RETORNO ) == '2' " )//filtro para trazer os dados 
oBrowse1:ExecuteFilter( .T. )

		//Colunas
ADD COLUMN oColumn DATA { || TMP1->C5_FILIAL+"/"+TMP1->C5_NUM }	TITLE "Emp./Pedido"    SIZE  008 OF oBrowse1
ADD COLUMN oColumn DATA { || TMP1->A1_NOME   				  }	TITLE "Cliente"		     SIZE  020 OF oBrowse1
ADD COLUMN oColumn DATA { || TMP1->A3_NREDUZ     			  }	TITLE "Vendedor"	     SIZE  006 OF oBrowse1
ADD COLUMN oColumn DATA { || STOD(TMP1->C5_EMISSAO)			  }	TITLE "Dt.Emissão PV"	     SIZE  010 OF oBrowse1
ADD COLUMN oColumn DATA { || ORDEMSEP  				          }	TITLE "Ordem Sep."	     SIZE  010 OF oBrowse1
ADD COLUMN oColumn DATA { || TMP1->D2_DOC+"-"+cValtochar(STOD(TMP1->F2_EMISSAO))}	TITLE "NF-Dt.Emissão" SIZE  010 OF oBrowse1
ADD COLUMN oColumn DATA { || TMP1->ZF_NUM+"-"+cValtochar(STOD(TMP1->ZF_EMISSAO))}	TITLE "Carga-Data"	 SIZE  010 OF oBrowse1
ADD COLUMN oColumn DATA { || DTOC(STOD(TMP1->C6_ENTREG)) + " [" + AllTrim( Str( TMP1->DIAS ) ) + "]"}	TITLE "Dt.Entrega/Dias Prev."	     SIZE  010 OF oBrowse1
//ADD COLUMN oColumn DATA { || IIf(TMP1->ZG_RETORNO == "1","Sim",IIf(TMP1->ZG_RETORNO == "2","Não",""))}	TITLE "Retorno"	         SIZE  006 OF oBrowse1
	
	//Ativa o Browse
ACTIVATE FWBROWSE oBrowse1

@ 036, 006 BUTTON oButton2 PROMPT "  Pedido Venda " SIZE 037, 012 OF oDlg ACTION MATASC5() PIXEL //" Executar   "
@ 052, 006 BUTTON oButton3 PROMPT "  Nota Fiscal  " SIZE 037, 012 OF oDlg ACTION MATASF2() PIXEL //" XML Envio"
@ 068, 006 BUTTON oButton3 PROMPT "  Env. e-mail  " SIZE 037, 012 OF oDlg ACTION ENVMAIL() PIXEL //" XML Retorno"


//aAdd(aBotoesTmp, { , { || LOJR902()  }, 	"STR0019"}) // cria botão dentro outras ações


ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End },{||oDlg:End()},,@aBotoesTmp, /* nRecno*/, /* cAlias*/, .F., .F., .F. , .F., .F., ) CENTERED

RestArea(aAreaSM0)

//TMP1->(DBCloseArea(TMP1)) 
//DBCloseArea()
Return

/*/{Protheus.doc} ConsRet
//Rotina para atualizar tela
@author Fabio Batista
@since 18/08/2020
@version 1.0
/*/
STATIC FUNCTION ConsRet()

  oBrowse1:GoPgDown()
  oBrowse1:Refresh(.F.)
  If oBrowse1:At() == oBrowse1:LogicLen()
  	oBrowse1:GoTop()
  	oBrowse1:Refresh()
  EndIf
	//oBrowse1:Activate()
    oBrowse1:Refresh(.F.)
	//oTimeRef:Activate()
//oBrowse1:At() // retorna a linha posicionada

Return


/*/{Protheus.doc} MATASC5
//Rotina visualiza pedido venda
@author Fabio Batista
@since 18/08/2020
@version 1.0
/*/
Static Function MATASC5()

	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))

	If SC5->(DbSeek(TMP1->C5_FILIAL+TMP1->C5_NUM, .F.))
		SC6->(DbSeek(TMP1->C5_FILIAL+TMP1->C5_NUM, .F.))
		A410VISUAL("SC5", SC5->(RecNo()), 2)
	Else
		Alert("Não existe o Pedido de Venda")
	EndIf

Return

/*/{Protheus.doc} MATASC5
//Rotina visualiza Documento de saída
@author Fabio Batista
@since 18/08/2020
@version 1.0
/*/
Static Function MATASF2()
	
	DbSelectArea("SF2")
	SF2->(DbSetOrder(1))
	
	If SF2->(DbSeek(TMP1->C5_FILIAL+TMP1->D2_DOC+TMP1->D2_SERIE+TMP1->C5_CLIENTE+TMP1->C5_LOJACLI, .F.))
		Mc090Visual("SF2", SF2->(RecNo()), 2)
	Else
		Alert("Não existe a NFe!")
	EndIf

	//aRotina := {}
	//DbSelectArea(cAlias)
Return

/*/{Protheus.doc} ENVMAIL
//Rotina envio de e-mail com pedido selecionado
@author Fabio Batista
@since 20/08/2020
@version 1.0
/*/
Static Function ENVMAIL()

Local _cHtml   := ''
Local CASSUNTO := 'Situação do Pedido'
Local cAttach  := ''
//Local mv_par01 := ''
Private cPerg  := "FWSTATUS" 

	cPergunt()
	If ! Pergunte(cPerg, .T.)
		Return nil
	EndIf              

_cHtml := '<html>' + CRLF
_cHtml += '	<head>' + CRLF
_cHtml += '		<meta http-equiv="content-type" content="text/html;charset=utf-8">' + CRLF
_cHtml += '		<style>' + CRLF
_cHtml += '			table 	{' + CRLF
_cHtml += '					border-collapse: collapse;' + CRLF
_cHtml += '					border: 1px solid black;' + CRLF
_cHtml += '					}' + CRLF
_cHtml += '		</style>' + CRLF
_cHtml += '	</head>' + CRLF
_cHtml += '	<body>' + CRLF
_cHtml += '		<table border="0" width="100%" align="center">' + CRLF
_cHtml += '			<tr rowspan="2">' + CRLF
_cHtml += '				<td width="100%" style=mso-number-format:"\@" align="center" VALIGN="MIDDLE" bgcolor="#ffffff">      ' + CRLF
_cHtml += '					<br>' + CRLF
_cHtml += '					<font face="Courier New" size="5" VALIGN="MIDDLE" color=black><strong><B>Situação do Pedido</B></strong></font>   ' + CRLF
_cHtml += '				</td>' + CRLF
_cHtml += '			</tr>' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td>' + CRLF
_cHtml += '					<font>' + CRLF
_cHtml += '						<br>' + CRLF
_cHtml += '					</font>' + CRLF
_cHtml += '				</td>' + CRLF
_cHtml += '			</tr>    ' + CRLF
_cHtml += '		</table><Br>' + CRLF
_cHtml += '		<table border="0" width="100%" align="center" >' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td colspan="8" width="100%"style=mso-number-format:"\@" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color="ffffff" ><B></b></Font>' + CRLF
_cHtml += '				</td>' + CRLF
_cHtml += '			</tr>' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '			<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Emp./Pedido</b></font>' + CRLF    
_cHtml += '				</td>    ' + CRLF
_cHtml += '			<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Cliente</b></font>    ' + CRLF
_cHtml += '				</td>    	' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Vendedor</b></font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Dt.Emissão PV</b></font>  ' + CRLF  
_cHtml += '				</td> ' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Ordem Sep.</b></font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>NF-Dt.Emissão</b></font>  ' + CRLF  
_cHtml += '				</td> 	' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Carga-Data</b></font>    ' + CRLF
_cHtml += '				</td> ' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Dt.Entrega/Dias Prev.</b></font>    ' + CRLF
_cHtml += '				</td> ' + CRLF

//_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
//_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Dt.Entregue</b></font>    ' + CRLF
//_cHtml += '				</td> ' + CRLF

_cHtml += '			</tr>' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">' +TMP1->C5_FILIAL+"/"+TMP1->C5_NUM+'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+TMP1->A1_NOME+'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+TMP1->A3_NREDUZ+'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+DTOC(STOD(TMP1->C5_EMISSAO))+'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+TMP1->ORDEMSEP+'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+TMP1->D2_DOC+"-"+cValtochar(STOD(TMP1->C5_EMISSAO))+'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+TMP1->ZF_NUM+"-"+cValtochar(STOD(TMP1->ZF_EMISSAO))+'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+DTOC(STOD(TMP1->C6_ENTREG)) + " [" + AllTrim( Str( TMP1->DIAS ) ) + "]"+'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
//_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
//_cHtml += '					<font face="Courier New" size="3">'+IIf(TMP1->ZG_RETORNO == "1","Sim",IIf(TMP1->ZG_RETORNO == "2","Não",""))+'</font>    ' + CRLF
//_cHtml += '				</td>    ' + CRLF
_cHtml += '			</tr>' + CRLF
_cHtml += '		</table>' + CRLF
_cHtml += '		<Hr>' + CRLF
_cHtml += '		<font face="Arial" size="1"><I>Powered by TI Euroamerican</I></font>  <font face="Arial" size="1" color="#FFFFFF">%cCodUsr% %cIDWF% %cFuncao%</font><br>' + CRLF
_cHtml += '		<font face="Arial" size="3"><B>Euroamerican do Brasil Imp Ind e Com LTDA</B></font><br/>' + CRLF
_cHtml += '	</body>' + CRLF
_cHtml += '</html>' + CRLF

cBody := _cHtml

If Empty(MV_PAR01)
	Alert("A T E N Ç Ã O" + CRLF + "O campo de e-mail está vazio favor incluir o e-mail.","ENVMAIL")	
Else
	cEmail := MV_PAR01
	u_FSENVMAIL(cAssunto, cBody, cEmail,cAttach,,,,,,,,,)
EndIf 

Return

/*/{Protheus.doc} cPergunt
//Rotina cria grupo de perguntas
@author Fabio Batista
@since 20/08/2020
@version 1.0
@Param		 mv_par01
/*/
Static function cPergunt()
	
	u_fsPutSx1(cPerg ,"01", "E-mail"              ,'' ,'' ,"MV_C01"	,"C" , 99                      ,0 , ,"G"	,""	,""	,"","","mv_par01","","","","","","","","","","","","","","","","")
	
return

/*/{Protheus.doc} fRetCor
//Rotina cria linhas com cores
@author Fabio Batista
@since 20/08/2020
@version 1.0
@Param		 mv_par01
/*/
Static Function fRetCor( nOper )

Local nCor

//1 - IIf(Mod(oBrowse1:nAt, 2) == 0 .And. (oBrowse1:nAt > 15 .And. Mod(Int( (oBrowse1:nAt / 15) ), 2) <> 0), CLR_YELLOW, CLR_WHITE)
//2 - IIf(Mod(oBrowse1:nAt, 2) == 0 .And. (oBrowse1:nAt > 15 .And. Mod(Int( (oBrowse1:nAt / 15) ), 2) <> 0), CLR_HGRAY, CLR_WHITE)
If nOper == 1
	If oBrowse1:nAt <= 15
		If Mod(oBrowse1:nAt, 2) == 0
			nCor := CLR_YELLOW
		Else
			nCor := CLR_WHITE
		EndIf
	Else
		If Mod(Int( (oBrowse1:nAt / 15) ), 2) <> 0
			If Mod(oBrowse1:nAt, 2) <> 0
				nCor := CLR_YELLOW
			Else
				nCor := CLR_WHITE
			EndIf
		Else
			If Mod(oBrowse1:nAt, 2) == 0
				nCor := CLR_YELLOW
			Else
				nCor := CLR_WHITE
			EndIf
		EndIf
	EndIf
Else
	If oBrowse1:nAt <= 15
		If Mod(oBrowse1:nAt, 2) == 0
			nCor := CLR_HGRAY
		Else
			nCor := CLR_WHITE
		EndIf
	Else
		If Mod(Int( (oBrowse1:nAt / 15) ), 2) <> 0
			If Mod(oBrowse1:nAt, 2) <> 0
				nCor := CLR_HGRAY
			Else
				nCor := CLR_WHITE
			EndIf
		Else
			If Mod(oBrowse1:nAt, 2) == 0
				nCor := CLR_HGRAY
			Else
				nCor := CLR_WHITE
			EndIf
		EndIf
	EndIf
EndIf

oBrowse1:LineRefresh( oBrowse1:nAt )

Return nCor

Static Function PedAtraso()

Local cQry      := ''
Local TMP2      := GetNextAlias()
Local cBody    := ''
Local cNumPd    := '' 
Local cCliente  := ''
Local lContinua := .T.
Local dData     := dDatabase
Local cAttach   := ''
Local lMail     := .F. 
Local cAssunto  := "Situação do Pedido"

	If !Empty(nDias) 
		If valtype(nDias) <> "N"
			MsgInfo("Vai ser enviado e-mail com todos itens com (" + cValtochar(nDias) + ") dias de atraso")
			nDias := Val(nDias)
		EndIf	
		//dData := database-nDias
		cQry := " SELECT DISTINCT C5_FILIAL,C5_NUM,C5_CLIENTE,C5_LOJACLI,C5_VEND1,C5_EMISSAO " + CRLF
		cQry += " ,C6_ENTREG " + CRLF
		cQry += " ,DATEDIFF(DAY,CONVERT(DATETIME,C6_ENTREG), CONVERT(DATETIME,ISNULL(ZF_EMISSAO,CONVERT(VARCHAR(8),GETDATE())))) AS DIAS " + CRLF
		cQry += " ,A1_COD,A1_NOME, ISNULL(D2_SERIE, '') AS D2_SERIE, ISNULL(D2_DOC, '') AS D2_DOC " + CRLF
		cQry += " ,ISNULL(ZF_NUM, '') AS ZF_NUM " + CRLF
		cQry += " ,ISNULL(F2_HORA, '') AS F2_HORA " + CRLF
		cQry += " ,ISNULL(F2_EMISSAO, '') AS F2_EMISSAO" + CRLF
		cQry += " ,ISNULL (ZG_RETORNO,'--') AS ZG_RETORNO " + CRLF
		cQry += " ,ISNULL (A3_NREDUZ, '') AS A3_NREDUZ" + CRLF
		cQry += " ,ISNULL (ZF_EMISSAO,'') AS ZF_EMISSAO " + CRLF
		cQry += " ,ISNULL( OSNOTA.CB7_ORDSEP, ISNULL(OSPED.CB7_ORDSEP, '')) AS ORDEMSEP " + CRLF

		cQry += "  FROM "+RetSqlName("SC5")+" SC5 " + CRLF
		cQry += " INNER JOIN "+RetSqlName("SA1")+" SA1  ON C5_CLIENTE = A1_COD AND C5_LOJACLI = A1_LOJA AND SA1.D_E_L_E_T_ = ' ' " + CRLF
		cQry += " INNER JOIN "+RetSqlName("SC6")+" AS SC6 ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND SC6.D_E_L_E_T_='' " + CRLF
		cQry += "  LEFT JOIN "+RetSqlName("SD2")+" AS SD2  ON D2_FILIAL = C5_FILIAL AND D2_PEDIDO = C5_NUM AND SD2.D_E_L_E_T_ = ' '  " + CRLF
		cQry += "  LEFT JOIN "+RetSqlName("SF2")+" AS SF2  ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA AND F2_TIPO = D2_TIPO AND SF2.D_E_L_E_T_ = ' '  " + CRLF
		cQry += "  LEFT JOIN "+RetSqlName("SZG")+" AS SZG  ON ZG_FILIAL = '  ' AND ZG_EMPFIL = '08' + D2_FILIAL AND ZG_NOTA = D2_DOC AND ZG_SERIE = D2_SERIE AND ZG_CLIENTE = D2_CLIENTE AND ZG_LOJA = D2_LOJA AND SZG.D_E_L_E_T_ = ''  " + CRLF
		cQry += "  LEFT JOIN "+RetSqlName("SZF")+" AS SZF  ON ZF_FILIAL = ZG_FILIAL AND ZF_NUM = ZG_NUM AND SZG.D_E_L_E_T_ = ''  " + CRLF
		cQry += "  LEFT JOIN "+RetSqlName("SA3")+" AS SA3  ON A3_FILIAL = '' AND A3_COD = C5_VEND1 AND SA3.D_E_L_E_T_ = '' " + CRLF
		cQry += "  LEFT JOIN "+RetSqlName("CB7")+" AS OSNOTA  ON OSNOTA.CB7_FILIAL = C5_FILIAL AND OSNOTA.CB7_NOTA = F2_DOC AND OSNOTA.CB7_CLIENT = F2_CLIENTE AND OSNOTA.CB7_LOJA = F2_LOJA AND OSNOTA.CB7_ORIGEM = '2'AND OSNOTA.D_E_L_E_T_ = ' ' " + CRLF
		cQry += "  LEFT JOIN "+RetSqlName("CB7")+" AS OSPED  ON OSPED.CB7_FILIAL = C5_FILIAL AND OSPED.CB7_PEDIDO = C5_NUM AND OSPED.CB7_ORIGEM = '1' AND OSPED.D_E_L_E_T_ = ' ' " + CRLF

/*
        Analista Paulo Rogério:
		Data 28/09/2022 - 09:00:00

		TRECHO COMENTADO E SUBSTITUIDO BLOCO DE PROGRAMA ACIMA, A FIM DE RETIRAR REFERENCIA
		FIXA DAS TABELAS DE DAODS, SUBSTITUINDO ESSAS OCORRENCIAS PELO RetSqlName. VALE RESSALTAR QUE 
		NESSE TRECHO FOI IDENTIFICADA A REFERENCIA EM TABELAS DE DADOS DE EMPRESAS/FILIAIS DISTINTAS,
		COMO: 080 E 000, POREM, NO BLOCO SUBSTITUTO FOI MANTIDA A COERENCIA DE UTILIZAR TABELAS DA MESMA 
		EMPRESA/FILIAL.

		cQry += " FROM SC5080 SC5 " + CRLF
		cQry += " INNER JOIN SA1080 SA1  ON C5_CLIENTE = A1_COD AND C5_LOJACLI = A1_LOJA AND SA1.D_E_L_E_T_ = ' ' " + CRLF
		cQry += " INNER JOIN SC6080 AS SC6 ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND SC6.D_E_L_E_T_='' " + CRLF
		cQry += " LEFT JOIN SD2080 AS SD2  ON D2_FILIAL = C5_FILIAL AND D2_PEDIDO = C5_NUM AND SD2.D_E_L_E_T_ = ' '  " + CRLF
		cQry += " LEFT JOIN SF2080 AS SF2  ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA AND F2_TIPO = D2_TIPO AND SF2.D_E_L_E_T_ = ' '  " + CRLF
		cQry += " LEFT JOIN SZG000 AS SZG  ON ZG_FILIAL = '  ' AND ZG_EMPFIL = '08' + D2_FILIAL AND ZG_NOTA = D2_DOC AND ZG_SERIE = D2_SERIE AND ZG_CLIENTE = D2_CLIENTE AND ZG_LOJA = D2_LOJA AND SZG.D_E_L_E_T_ = ''  " + CRLF
		cQry += " LEFT JOIN SZF000 AS SZF  ON ZF_FILIAL = ZG_FILIAL AND ZF_NUM = ZG_NUM AND SZG.D_E_L_E_T_ = ''  " + CRLF
		cQry += " LEFT JOIN SA3000 AS SA3  ON A3_FILIAL = '' AND A3_COD = C5_VEND1 AND SA3.D_E_L_E_T_ = '' " + CRLF
		cQry += " LEFT JOIN CB7080 AS OSNOTA  ON OSNOTA.CB7_FILIAL = C5_FILIAL AND OSNOTA.CB7_NOTA = F2_DOC AND OSNOTA.CB7_CLIENT = F2_CLIENTE AND OSNOTA.CB7_LOJA = F2_LOJA AND OSNOTA.CB7_ORIGEM = '2'AND OSNOTA.D_E_L_E_T_ = ' ' " + CRLF
		cQry += " LEFT JOIN CB7080 AS OSPED  ON OSPED.CB7_FILIAL = C5_FILIAL AND OSPED.CB7_PEDIDO = C5_NUM AND OSPED.CB7_ORIGEM = '1' AND OSPED.D_E_L_E_T_ = ' ' " + CRLF
*/
		cQry += " WHERE C5_FILIAL <> '**' AND SC5.D_E_L_E_T_ = ''  " + CRLF
		cQry += " AND C5_NUM  BETWEEN '"+cPedD+"' AND '"+cPedAt+"' " + CRLF 
		cQry += " AND C5_EMISSAO BETWEEN '"+DTOS(dDatD)+"' AND '"+DTOS(dDatAt)+"' " + CRLF
		cQry += " AND F2_DOC BETWEEN '"+cNotaD+"' AND '"+cNotaAt+"' " + CRLF 
		cQry += " AND ZF_NUM  BETWEEN '"+cCargD+"' AND '"+cCargAt+"' " + CRLF 
		cQry += " AND ZF_EMISSAO BETWEEN '"+DTOS(dDtCarD)+"' AND '"+DTOS(dDtCarAt)+"' " + CRLF 
		cQry += " AND ZG_RETORNO IN( '1','' ) " + CRLF
		cQry += " GROUP BY C5_FILIAL,C5_NUM,C5_CLIENTE,C5_LOJACLI,C5_VEND1,C5_EMISSAO " + CRLF
		cQry += " ,A1_COD,A1_NOME, D2_SERIE, D2_DOC, ZF_NUM" + CRLF
		cQry += " ,F2_HORA, F2_EMISSAO" + CRLF
		cQry += " ,ZG_RETORNO" + CRLF
		cQry += " ,A3_NREDUZ " + CRLF
		cQry += " ,ZF_EMISSAO " + CRLF
		cQry += " ,OSNOTA.CB7_ORDSEP " + CRLF
		cQry += " ,OSPED.CB7_ORDSEP " + CRLF
		cQry += " ,C6_ENTREG " + CRLF
		cQry += " ORDER BY C5_FILIAL,C5_NUM,D2_SERIE,D2_DOC,ZF_NUM,C5_CLIENTE,C5_LOJACLI " + CRLF

			MsAguarde({|| dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQry), TMP2,.F.,.T.)}, "Selecionando Registros ...")

			If (TMP2)->(EOF())
				Alert("Não há resultado na query principal do Analistas")
				Return
			EndIf


			While (TMP2)->(!EOF())

			cNumPd   :=  (TMP2)->C5_NUM
			cCliente :=  (TMP2)->C5_CLIENTE
			
			//If !nDias <= (TMP2)->DIAS
			If !6 == (TMP2)->DIAS .and. !4 == (TMP2)->DIAS
				(TMP2)->(DBSKIP())
			Else	
				If lContinua 
					cBody := '<html>' + CRLF
					cBody += '	<head>' + CRLF
					cBody += '		<meta http-equiv="content-type" content="text/html;charset=utf-8">' + CRLF
					cBody += '		<style>' + CRLF
					cBody += '			table 	{' + CRLF
					cBody += '					border-collapse: collapse;' + CRLF
					cBody += '					border: 1px solid black;' + CRLF
					cBody += '					}' + CRLF
					cBody += '		</style>' + CRLF
					cBody += '	</head>' + CRLF
					cBody += '	<body>' + CRLF
					cBody += '		<table border="0" width="100%" align="center">' + CRLF
					cBody += '			<tr rowspan="2">' + CRLF
					cBody += '				<td width="100%" style=mso-number-format:"\@" align="center" VALIGN="MIDDLE" bgcolor="#ffffff">      ' + CRLF
					cBody += '					<br>' + CRLF
					If Valtype(nDias) <> "C"
						cDias := cValtochar(nDias)
					EndIf
					cBody += '					<font face="Courier New" size="5" VALIGN="MIDDLE" color=black><strong><B>Situação do Pedido com ('+cDias+') Dias</B></strong></font>   ' + CRLF
					cBody += '				</td>' + CRLF
					cBody += '			</tr>' + CRLF
					cBody += '			<tr>    ' + CRLF
					cBody += '				<td>' + CRLF
					cBody += '					<font>' + CRLF
					cBody += '						<br>' + CRLF
					cBody += '					</font>' + CRLF
					cBody += '				</td>' + CRLF
					cBody += '			</tr>    ' + CRLF
					cBody += '		</table><Br>' + CRLF
				lContinua := .F.
				EndIf
					cBody += '		<table border="0" width="100%" align="center" >' + CRLF
					cBody += '			<tr>    ' + CRLF
					cBody += '				<td colspan="9" width="100%"style=mso-number-format:"\@" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
					cBody += '					<font face="Courier New" size="3" color="ffffff" ><B></b></Font>' + CRLF
					cBody += '				</td>' + CRLF
					cBody += '			</tr>' + CRLF
					cBody += '			<tr>    ' + CRLF
					cBody += '			<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
					cBody += '					<font face="Courier New" size="3" color=WHITE><b>Emp./Pedido</b></font>' + CRLF    
					cBody += '				</td>    ' + CRLF
					cBody += '			<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
					cBody += '					<font face="Courier New" size="3" color=WHITE><b>Cliente</b></font>    ' + CRLF
					cBody += '				</td>    	' + CRLF
					cBody += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
					cBody += '					<font face="Courier New" size="3" color=WHITE><b>Vendedor</b></font>    ' + CRLF
					cBody += '				</td>    ' + CRLF
					cBody += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
					cBody += '					<font face="Courier New" size="3" color=WHITE><b>Dt.Emissão</b></font>  ' + CRLF  
					cBody += '				</td> ' + CRLF
					cBody += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
					cBody += '					<font face="Courier New" size="3" color=WHITE><b>Ord. Sep.</b></font>    ' + CRLF
					cBody += '				</td>    ' + CRLF
					cBody += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
					cBody += '					<font face="Courier New" size="3" color=WHITE><b>NF/Emis</b></font>  ' + CRLF  
					cBody += '				</td> 	' + CRLF
					cBody += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
					cBody += '					<font face="Courier New" size="3" color=WHITE><b>Carga/Data</b></font>    ' + CRLF
					cBody += '				</td> ' + CRLF
					cBody += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
					cBody += '					<font face="Courier New" size="3" color=WHITE><b>Prevista</b></font>    ' + CRLF
					cBody += '				</td> ' + CRLF
					cBody += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
					cBody += '					<font face="Courier New" size="3" color=WHITE><b>Entregue</b></font>    ' + CRLF
					cBody += '				</td> ' + CRLF
					cBody += '			</tr>' + CRLF
					While (TMP2)->(!EOF()) .and. (cNumPd == (TMP2)->(C5_NUM)) .and. (cCliente == (TMP2)->(C5_CLIENTE)) 
						cBody += '			<tr>    ' + CRLF
						cBody += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
						cBody += '					<font face="Courier New" size="3">' +alltrim((TMP2)->C5_FILIAL)+"/"+alltrim((TMP2)->C5_NUM)+'</font>    ' + CRLF
						cBody += '				</td>    ' + CRLF
						cBody += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
						cBody += '					<font face="Courier New" size="3">'+(TMP2)->A1_NOME+'</font>    ' + CRLF
						cBody += '				</td>    ' + CRLF
						cBody += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
						cBody += '					<font face="Courier New" size="3">'+(TMP2)->A3_NREDUZ+'</font>    ' + CRLF
						cBody += '				</td>    ' + CRLF
						cBody += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
						cBody += '					<font face="Courier New" size="3">'+DTOC(STOD((TMP2)->C5_EMISSAO))+'</font>    ' + CRLF
						cBody += '				</td>    ' + CRLF
						cBody += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
						cBody += '					<font face="Courier New" size="3">'+ORDEMSEP+'</font>    ' + CRLF
						cBody += '				</td>    ' + CRLF
						cBody += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
						cBody += '					<font face="Courier New" size="3">'+(TMP2)->D2_DOC+"-"+cValtochar(STOD((TMP2)->C5_EMISSAO))+'</font>    ' + CRLF
						cBody += '				</td>    ' + CRLF
						cBody += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
						cBody += '					<font face="Courier New" size="3">'+(TMP2)->ZF_NUM+"-"+cValtochar(STOD((TMP2)->ZF_EMISSAO))+'</font>    ' + CRLF
						cBody += '				</td>    ' + CRLF
						cBody += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
						cBody += '					<font face="Courier New" size="3">'+DTOC(STOD((TMP2)->C6_ENTREG)) + " [" + AllTrim( Str( (TMP2)->DIAS ) ) + "]"+'</font>    ' + CRLF
						cBody += '				</td>    ' + CRLF
						cBody += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
						cBody += '					<font face="Courier New" size="3">'+IIf((TMP2)->ZG_RETORNO == "1","Sim",IIf((TMP2)->ZG_RETORNO == "2","Não",""))+'</font>    ' + CRLF
						cBody += '				</td>    ' + CRLF
						cBody += '			</tr>' + CRLF		
					(TMP2)->(DBSKIP())
					EndDo    	
			EndIf		
			EndDo
			cBody += '		</table>' + CRLF
			cBody += '		<Hr>' + CRLF
			cBody += '		<font face="Arial" size="1"><I>Powered by TI Euroamerican</I></font>  <font face="Arial" size="1" color="#FFFFFF">%cCodUsr% %cIDWF% %cFuncao%</font><br>' + CRLF
			cBody += '		<font face="Arial" size="3"><B>Euroamerican do Brasil Imp Ind e Com LTDA</B></font><br/>' + CRLF
			cBody += '	</body>' + CRLF
			cBody += '</html>' + CRLF 
			lMail := .T.
	EndIf

	If lMail
		cEmail := GetMv( "FS_EMAIL" , .F. , 'FABIO.batista@EUROAMERICAN.COM.BR')
		u_FSENVMAIL(cAssunto, cBody, cEmail,cAttach,,,,,,,,,)
	EndIf

Return
