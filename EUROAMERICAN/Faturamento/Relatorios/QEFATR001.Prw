#include "rwmake.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"

/*
| Função...: QEFATR001()
| Autor....: Paulo Rogerio
| Data.....: 29/08/2022
| Retorno..: Nenhum
| Descricão: Relatório Notas Fiscais Embarcadas.
|
| Observac.: 
| Objetivo.: 
| Documentação: 
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/

User Function QEFATR001()
Local oReport

Private _cPerg:="QEFATR001"
Private _aRegs:={}

Private vpParEmiDe := ""
Private vpParemiAte:= ""
Private vpParCliDe := ""
Private vpParCliAte:= ""
Private vpParEstDe := ""
Private vpParEstAte:= ""
Private vpParNotDe := ""
Private vpParNotAte:= ""
Private vpParSerDe := ""
Private vpParSerAte:= ""
Private vpParStaEmb:= ""
Private vpParStaExp:= ""
Private vpParStaRet:= ""
Private vpParDiasEn:= 0
Private vpParExpHum:= ""
Private vpParExpDoi:= ""
Private vpParContEx:= ""
Private vpParTraDe := ""
Private vpParTraAte:= ""
Private vpParTipFre:= ""


//-----------|Grupo|Ord|Pergta                 |Pergunta              |Pergunta              |Variavel|Tip|Ta|D|P|GSC|Va|Var01     |Def Port       |De|De|Cn|Va|Def Port2      |De|De|Cn|Va|Def Port3    |De|De|Cn|Va|Def Port4    |De|De|Cn|Va|Def Port5  |De|De|Cn|F3|P |GRP
//-----------|     |em |Portug                 |Espanhol              |Ingles                |        |   |ma|e|r|   |li|          |               |f |f |te|r |               |f |f |te|r |             |f |f |te|r |             |f |f |te|r |           |f |f |te|  |Y |SXG
//-----------|     |   |                       |                      |                      |        |   |nh|c|e|   |d |          |               |Es|En|01|2 |               |Es|En|02|3 |             |Es|En|03|4 |             |Es|En|05|5 |           |Es|En|05|  |M |
AAdd(_aRegs,{_cPerg,"01","Emissão de         ?","Emissão de         ?","Emissão de         ?","mv_ch1","D",08,0,0,"G","","mv_par01",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
AAdd(_aRegs,{_cPerg,"02","Emissão ate        ?","Emissão ate        ?","Emissão ate        ?","mv_ch2","D",08,0,0,"G","","mv_par02",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
AAdd(_aRegs,{_cPerg,"03","Cliente de         ?","Cliente de         ?","Cliente de         ?","mv_ch3","C",06,0,0,"G","","mv_par03",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","","SA1FIN","",""})
AAdd(_aRegs,{_cPerg,"04","Cliente ate        ?","Cliente ate        ?","Cliente ate        ?","mv_ch4","C",06,0,0,"G","","mv_par04",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","","SA1FIN","",""})
AAdd(_aRegs,{_cPerg,"05","UF de              ?","UF de              ?","UF de              ?","mv_ch5","C",02,0,0,"G","","mv_par05",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
AAdd(_aRegs,{_cPerg,"06","UF ate             ?","UF ate             ?","UF ate             ?","mv_ch6","C",02,0,0,"G","","mv_par06",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
AAdd(_aRegs,{_cPerg,"07","Nota Fiscal de     ?","Nota Fiscal de     ?","Nota Fiscal de     ?","mv_ch7","C",09,0,0,"G","","mv_par07",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
AAdd(_aRegs,{_cPerg,"08","Nota Fiscal ate    ?","Nota Fiscal ate    ?","Nota Fiscal ate    ?","mv_ch8","C",09,0,0,"G","","mv_par08",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
AAdd(_aRegs,{_cPerg,"09","Serie de           ?","Serie de           ?","Serie de           ?","mv_ch9","C",03,0,0,"G","","mv_par09",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
AAdd(_aRegs,{_cPerg,"10","Serie ate          ?","Serie ate          ?","Serie ate          ?","mv_cha","C",03,0,0,"G","","mv_par10",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
aAdd(_aRegs,{_cPerg,"11","Tipo Operação      ?","Tipo Operação      ?","Tipo Operação      ?","mv_chb","N",01,0,0,"C","","mv_par11","Venda"        ,"","","","","Remessa"      ,"","","","","Ambas"      ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
aAdd(_aRegs,{_cPerg,"12","Quanto ao Embarque ?","Quanto ao Embarque ?","Quanto ao Embarque ?","mv_chc","N",01,0,0,"C","","mv_par12","Com Carga"    ,"","","","","Sem Carga"    ,"","","","","Todas"      ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
aAdd(_aRegs,{_cPerg,"13","Quanto a Expedição ?","Quanto a Expedição ?","Quanto a Expedição ?","mv_chd","N",01,0,0,"C","","mv_par13","Liberada"     ,"","","","","Pendente"     ,"","","","","Todas"      ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
aAdd(_aRegs,{_cPerg,"14","Quanto ao Retorno  ?","Quanto ao Retorno  ?","Quanto ao Retorno  ?","mv_che","N",01,0,0,"C","","mv_par14","Entregue"     ,"","","","","Devolvida"    ,"","","","","Pendente"   ,"","","","","Todas"      ,"","","","",""         ,"","","",""      ,"",""})
aAdd(_aRegs,{_cPerg,"15","Dias p/ Expedir >= a","Dias p/ Expedir >= a","Dias p/ Expedir >= a","mv_chf","N",03,0,0,"G","","mv_par15",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
AAdd(_aRegs,{_cPerg,"16","Expressao 1 Cliente?","Expressao 1 Cliente?","Expressao 1 Cliente?","mv_chg","C",50,0,0,"G","","mv_par16",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
AAdd(_aRegs,{_cPerg,"17","Expressao 2 Cliente?","Expressao 2 Cliente?","Expressao 2 Cliente?","mv_chh","C",50,0,0,"G","","mv_par17",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})
AAdd(_aRegs,{_cPerg,"18","Quanto as Express. ?","Quanto as Express. ?","Quanto as Express. ?","mv_chi","N",01,0,0,"C","","mv_par18","Comtém"       ,"","","","","Não Contém"   ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","",""      ,"",""})

AAdd(_aRegs,{_cPerg,"19","Transportadora de  ?","Transportadora de  ?","Transportadora de  ?","mv_chj","C",06,0,0,"G","","mv_par19",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","","SA4"   ,"",""})
AAdd(_aRegs,{_cPerg,"20","Transportadora ate ?","Transportadora ate ?","Transportadora ate ?","mv_chk","C",06,0,0,"G","","mv_par20",""             ,"","","","",""             ,"","","","",""           ,"","","","",""           ,"","","","",""         ,"","","","SA4"   ,"",""})
AAdd(_aRegs,{_cPerg,"21","Tipo de Frete      ?","Tipo de Frete      ?","Tipo de Frete      ?","mv_chl","N",01,0,0,"C","","mv_par21","CIF"          ,"","","","","FOB"          ,"","","","","Terceiros"  ,"","","","","Todos"      ,"","","","",""         ,"","","",""      ,"",""})

U_FSX1FUNC(_aRegs, _cPerg)

/*
If FindFunction("TRepInUse") .And. TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:=ReportDef()
	oReport:PrintDialog()
Else
	Return
EndIf
*/
	oReport:=ReportDef()
	oReport:PrintDialog()
Return

/*
| Função......: ReportDef()
| Autor.......: Paulo Rogerio
| Data........: 29/08/2022
| Retorno.....: Nenhum
| Descricão...: Rotina de definição da estrutura do Relatório
|               
| Parametros..: 
|               
| Observação..: 
| Objetivo....: 
| Documentação: 
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/                                                    

Static Function ReportDef()
//Local oReport
//Local oSecHeader
Local oSection

// Criação do Objeto report.
oReport := TReport():New(_cPerg   ,"Notas Fiscais Embarcadas",_cPerg  , {|oReport| ReportPrint(oReport)},"Relatório de Notas Fiscais Embarcadas")
Pergunte(oReport:uParam,.F.)

oReport:SetPortrait() //SetLandscape()
oReport:nFontBody := 7.50 //9.5
oReport:lBold := .F.

oReport:SkipLine(1)
oReport:ThinLine()

// Cria secão com a estrutura do relatório.
oSection := TRSection():New(oReport,OemToAnsi("Notas Fiscais Embarcadas"),{"TMPX"})
oSection:SetTotalInLine(.F.)


Return oReport

/*
| Função......: ReportPrint()
| Autor.......: Paulo Rogerio
| Data........: 11/06/2013
| Retorno.....: Nenhum
| Descricão...: Impressão do Relatório
|               
| Parametros..: 
|               
| Observação..: 
| Objetivo....: 
| Documentação: 
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/    
Static Function ReportPrint(oReport)
Local oSection   := oReport:Section(1)
Local lRet       := .T.
Local lBreakLine := .F.
Local lAutoSize  := .F.
Local cChaveAnt  := ""

IF oReport:nDevice == 4  // Excel
	// Definição das células de impressão
	//             Objeto, Campo                , Alias, Titulo           , Pict                     ,Siz,lPix, bCod, cAlign  , lLineBreak,cHeaderAlign, N.Uso,nColSpace,lAutoSize , nClrBack,nClrFore, lBold
	//           01      , 02                   , 03   , 04               , 05                       , 06, 07 , 08   , 09     , 10        , 11         , 12   ,13       , 14       , 15      , 16     , 17
	TRCell():New(oSection,"F2_NFISCAL"          ,"TMPX", "N.Fiscal"       , "@!")
	TRCell():New(oSection,"TIPOFRETE"           ,"TMPX", "Fret"             , "@!")
	TRCell():New(oSection,"F2_EMISSAO"          ,"TMPX", "Emissão"        , "@!")
	TRCell():New(oSection,"A1_NREDUZ"           ,"TMPX", "Cliente"        , "@!")
	TRCell():New(oSection,"A1_MUNE"             ,"TMPX", "Cidade"         , "@!")
	TRCell():New(oSection,"A1_ESTE"             ,"TMPX", "UF"             , "@!")
	TRCell():New(oSection,"F2_PBRUTO"           ,"TMPX", "Peso"           , "@E 9,999,999.99"        , 14, ,,"RIGHT" , ,"RIGHT" )
	TRCell():New(oSection,"F2_VALFAT"           ,"TMPX", "Valor R$"       , "@E 9,999,999.99"        , 12, ,,"RIGHT" , ,"RIGHT" )
	TRCell():New(oSection,"F2_TIPOPER"          ,"TMPX", "Operac"         , "@!")
	TRCell():New(oSection,"TRANSPORTADOR"       ,"TMPX", "Transp"         , "@!")
	TRCell():New(oSection,"F2_CARGA"            ,"TMPX", "Carga"          , "@!")
	TRCell():New(oSection,"ZF_EMISSAO"          ,"TMPX", "Montagem"       , "@!")
	TRCell():New(oSection,"ZZ_CODIGO"           ,"TMPX", "Pesagem"        , "@!")
	TRCell():New(oSection,"ZZ_DATALIB"          ,"TMPX", "Liberação"      , "@!")
	TRCell():New(oSection,"ZG_DTENTR"           ,"TMPX", "Entrega"        , "@!")
	TRCell():New(oSection,"ZZ_QTDDIAS"          ,"TMPX", "Dias"           , "@E 999"                 , 05, ,,"RIGHT" , ,"RIGHT")
else
	// Definição das células de impressão
	//             Objeto, Campo                , Alias, Titulo           , Pict                     ,Siz,lPix, bCod, cAlign  , lLineBreak,cHeaderAlign, N.Uso,nColSpace,lAutoSize , nClrBack,nClrFore, lBold
	//           01      , 02                   , 03   , 04               , 05                       , 06, 07 , 08   , 09     , 10        , 11         , 12   ,13       , 14       , 15      , 16     , 17
	TRCell():New(oSection,"F2_NFISCAL"          ,"TMPX", "N.Fiscal"       , "@!"                     , 13, .F.,/*bc*/,"LEFT"  , lBreakLine,"LEFT"      ,      ,         , lAutoSize,         ,        , .F.)
	TRCell():New(oSection,"TIPOFRETE"           ,"TMPX", "Fret"           , "@!"                     , 04, .F.,/*bc*/,"LEFT"  , lBreakLine,"LEFT"      ,      ,         , lAutoSize,         ,        , .F.)
	TRCell():New(oSection,"F2_EMISSAO"          ,"TMPX", "Emissão"        , "@!"                     , 10, .F.,/*bc*/,"LEFT"  , lBreakLine,"LEFT"      ,      ,         , lAutoSize,         ,        , .F.)
	TRCell():New(oSection,"A1_NREDUZ"           ,"TMPX", "Cliente"        , "@!"                     , 20, .F.,/*bc*/,"LEFT"  , lBreakLine,"LEFT"      ,      ,         , lAutoSize,         ,        , .F.)
	TRCell():New(oSection,"A1_MUNE"             ,"TMPX", "Cidade"         , "@!"                     , 25, .F.,/*bc*/,"LEFT"  , lBreakLine,"LEFT"      ,      ,         , lAutoSize,         ,        , .F.)
	TRCell():New(oSection,"A1_ESTE"             ,"TMPX", "UF"             , "@!"                     , 03, .F.,/*bc*/,"LEFT"  , lBreakLine,"LEFT"      ,      ,         , lAutoSize,         ,        , .F.)
	TRCell():New(oSection,"F2_PBRUTO"           ,"TMPX", "Peso"           , "@E 9,999,999.99"        , 14, .F.,/*bc*/,"RIGHT" , lBreakLine,"RIGHT"     ,      ,         , lAutoSize,         ,        , .F.)
	TRCell():New(oSection,"F2_VALFAT"           ,"TMPX", "Valor R$"       , "@E 9,999,999.99"        , 12, .F.,/*bc*/,"RIGHT" , lBreakLine,"RIGHT"     ,      ,         , lAutoSize,         ,        , .F.)
	TRCell():New(oSection,"F2_TIPOPER"          ,"TMPX", "Operac"         , "@!"                     , 07, .F.,/*bc*/,"RIGHT" , lBreakLine,"RIGHT"     ,      ,         , lAutoSize,         ,        , .F.)
	TRCell():New(oSection,"TRANSPORTADOR"       ,"TMPX", "Transp"         , "@!"                     , 20, .F.,/*bc*/,"LEFT"  , lBreakLine,"LEFT"      ,      ,         , lAutoSize,         ,        , .F.)
	TRCell():New(oSection,"F2_CARGA"            ,"TMPX", "Carga"          , "@!"                     , 06, .F.,/*bc*/,"LEFT"  , lBreakLine,"LEFT"      ,      ,         , lAutoSize,         ,        , .F.)
	TRCell():New(oSection,"ZF_EMISSAO"          ,"TMPX", "Montagem"       , "@!"                     , 10, .F.,/*bc*/,"LEFT"  , lBreakLine,"LEFT"      ,      ,         , lAutoSize,         ,        , .F.)
	TRCell():New(oSection,"ZZ_CODIGO"           ,"TMPX", "Pesagem"        , "@!"                     , 07, .F.,/*bc*/,"LEFT"  , lBreakLine,"LEFT"      ,      ,         , lAutoSize,         ,        , .F.)
	TRCell():New(oSection,"ZZ_DATALIB"          ,"TMPX", "Liberação"      , "@!"                     , 10, .F.,/*bc*/,"LEFT"  , lBreakLine,"LEFT"      ,      ,         , lAutoSize,         ,        , .F.)
	TRCell():New(oSection,"ZG_DTENTR"           ,"TMPX", "Entrega"        , "@!"                     , 10, .F.,/*bc*/,"LEFT"  , lBreakLine,"LEFT"      ,      ,         , lAutoSize,         ,        , .F.)
	TRCell():New(oSection,"ZZ_QTDDIAS"          ,"TMPX", "Dias"           , "@E 999"                 , 05, .F.,/*bc*/,"RIGHT" , lBreakLine,"RIGHT"     ,      ,         , lAutoSize,         ,        , .F.)
	
	//----------------------------------------------------------------
	// Definicao do titulo do relatorio                            
	//----------------------------------------------------------------
	
	oReport:SetTitle(IIF(vpParStaEmb == "CC", "Notas Fiscais Embarcadas", IIF(vpParStaEmb == "SC", "Notas Fiscais NÃO Embarcadas", "Notas Fiscais Embarcadas/Não Embarcadas")))

	// Define a quebra para sub-total
	//oBreak1  := TRBreak():New(oSection,oSection:Cell("PA0_NUMERO"), "SubTotal Produtos" ) 

	// SubTotal para a Quebra
	//TRFunction():New(oSection:Cell("PA0_NUMERO")	,NIL,"COUNT", oBreak1, ,"@E 999,999.99" ,   ,.F., .F.)

	// SubTotal Geral
	TRFunction():New(oSection:Cell("F2_PBRUTO")     ,NIL,"SUM"     ,        , ,"@E 999,999,999.99" ,   ,.T.,.F.)
	TRFunction():New(oSection:Cell("F2_VALFAT")     ,NIL,"SUM"     ,        , ,"@E 999,999,999.99" ,   ,.T.,.F.)
	TRFunction():New(oSection:Cell("ZZ_QTDDIAS")    ,NIL,"AVERAGE" ,        , ,"@E 999.99"         ,   ,.T.,.F.)
Endif 

oSection:SetHeaderPage()
oSection:SetNoFilter("TMPX")


//--------------------------------------------------------
// Atualiza variaveis com os parametros da rotina
//--------------------------------------------------------
Pergunte(oReport:uParam,.F.)

vpParEmiDe := mv_par01
vpParemiAte:= mv_par02
vpParCliDe := mv_par03
vpParCliAte:= mv_par04

vpParEstDe := mv_par05
vpParEstAte:= mv_par06

vpParNotDe := mv_par07
vpParNotAte:= mv_par08
vpParSerDe := mv_par09
vpParSerAte:= mv_par10

vpParOpera := IIF(mv_par11 == 1, "VD", IIF(mv_par11 == 2, "RE", "VR"))
vpParStaEmb:= IIF(mv_par12 == 1, "CC", IIF(mv_par12 == 2, "SC", "TD"))
vpParStaExp:= IIF(mv_par13 == 1, "LB", IIF(mv_par13 == 2, "PD", "TD"))
vpParStaRet:= IIF(mv_par14 == 1, "EN", IIF(mv_par14 == 2, "DV",  IIF(mv_par14 == 3, "PD","TD")))
vpParDiasEn:= mv_par15
vpParExpHum:= Alltrim(mv_par16)
vpParExpDoi:= Alltrim(mv_par17)
vpParContEx:= IIF(mv_par18 == 1, "S", "N")

vpParTraDe := mv_par19
vpParTraAte:= mv_par20
vpParTipFre:= IIF(mv_par21 == 1, "C", IIF(mv_par21 == 2, "F", IIF(mv_par21 == 3, "T", "")))


// Redefine o Titulo do Relatoiro
oReport:SetTitle(IIF(vpParStaEmb == "CC", "Notas Fiscais Embarcadas", IIF(vpParStaEmb == "SC", "Notas Fiscais NÃO Embarcadas", "Notas Fiscais Embarcadas/Não Embarcadas")))
oReport:SetTitle(IIF(vpParStaExp == "LB", oReport:Title()+" - Liberadas ", IIF(vpParStaExp == "PD", oReport:Title()+" - Pendentes" , oReport:Title()+" - Todas")))
oReport:SetTitle(IIF(vpParStaRet == "DV", oReport:Title()+" - Devolvidas", IIF(vpParStaRet == "EN", oReport:Title()+" - Entregues" , oReport:Title()+" - Todas")))
oReport:SetTitle(IIF(vpParOpera  == "VD", oReport:Title()+" - Vendas"    , IIF(vpParOpera  == "RE", oReport:Title()+" - Remessas"  , oReport:Title()+" - Venda/Remessa")))

Processa({|| lRet := fGeraTmp()})

IF !lRet
	Return
Endif

dbSelectArea("TMPX")
dbGotop()

// Definição da Regua de impressão.
oReport:SetMeter(RecCount())

oSection:Init()

oReport:SkipLine()

cChaveAnt := ""
While !Eof()
	If oReport:Cancel()
		Exit
	EndIf

	oReport:IncMeter()
	oSection:PrintLine()

	dbSkip()
End

oSection:Finish()

DbSelectArea("TMPX")
dbCloseArea()
Return

/*
| Função......: fGeraTmp()
| Autor.......: Paulo Rogerio
| Data........: 28/08/2022
| Retorno.....: Nenhum
| Descricão...: Geração do arquivo temporário 
|
| Observação..: 
| Objetivo....: 
| Documentação: 
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/                                                    

Static Function fGeraTmp()  
Local cQuery   := ""

// Definição da Query.
cQuery := fDefQuery()
 
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMPX", .F., .T.)

TCSetField( "TMPX", "F2_EMISSAO", "D", 08, 0 )
TCSetField( "TMPX", "ZG_DTENTR" , "D", 08, 0 )
TCSetField( "TMPX", "ZZ_DATALIB", "D", 08, 0 )
TCSetField( "TMPX", "ZF_EMISSAO", "D", 08, 0 )

dbSelectArea("TMPX")
dbGoTop()

IF eof()
	MsgAlert("Não há dados para impressão")

	dbCloseArea()
	Return(.F.)
Endif

//fPrintRel()

dbSelectArea("TMPX")           

//dbCloseArea()
Return(.T.)                                     


/*
| Função......: fDefQuery()
| Autor.......: Paulo Rogerio
| Data........: 30/06/2013
| Retorno.....: Nenhum
| Descricão...: Definição da Query para montagem do relatório
|               
| Parametros..: 
|               
| Observação..: 
| Objetivo....: 
| Documentação: 
|
| Data       Programador    Alteração
| -------------------------------------------------------------------------
| -------------------------------------------------------------------------
*/    
Static Function fDefQuery()
Local cQuery     := ""
Local cColigadas := ""
//Local cCfpoVenda := "'5101', '5102', '5112 ', '5116', '5117','5118', '5122','5401', '5403','5405', '5501', '6101', '6102', '6112 ', '6116', '6117','6118', '6122','6401', '6403','6405', '6501', '6107', '6108', '6109', '6404', '7101'"
//Local cFilSf4    := Left(xFilial("SF2"), 2)
Local nX 		 := 0

Do Case 
	Case cFilant == "0803"
		cColigadas := GETMV("QE_CLI0803")
	Case cFilant == "0901"
		cColigadas := GETMV("QE_CLI0901")
	Case cFilant == "0200"
		cColigadas := GETMV("QE_CLI0200")
endCase

cQuery += "SELECT *, CASE "+Chr(13)+Chr(10)
cQuery += "          WHEN F2_ITENSVND > 0 AND F2_ITENSREM > 0 THEN 'MISTA'"+Chr(13)+Chr(10)
cQuery += "          WHEN F2_ITENSVND > 0 AND F2_ITENSREM = 0 THEN 'VENDA'"+Chr(13)+Chr(10)
cQuery += "          WHEN F2_ITENSVND = 0 AND F2_ITENSREM > 0 THEN 'REMES'"+Chr(13)+Chr(10)
cQuery += "          ELSE 'OUTRAS' END AS F2_TIPOPER"+Chr(13)+Chr(10)
cQuery += "  FROM ("+Chr(13)+Chr(10)


For nX := 1 to 2
	cQuery += "  		SELECT F2_FILIAL, F2_DOC+'/'+F2_SERIE AS F2_NFISCAL, F2_EMISSAO, F2_CARGA  , F2_PBRUTO, F2_VALFAT, F2_TIPO,"+Chr(13)+Chr(10)
	cQuery += "			       (SELECT COUNT(*) FROM "+RetSqlName("SD2")+" SD2 WITH(NOLOCK), "+RetSqlName("SF4")+" SF4 WHERE D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA AND SD2.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' AND F4_FILIAL = '"+Left(xFilial("SF2"), 2)+"' AND F4_CODIGO = D2_TES AND F4_ESTOQUE = 'S' AND F4_DUPLIC = 'S') AS F2_ITENSVND,"+Chr(13)+Chr(10) // AND D2_CF     IN("+cCfpoVenda+") 
	cQuery += "			       (SELECT COUNT(*) FROM "+RetSqlName("SD2")+" SD2 WITH(NOLOCK), "+RetSqlName("SF4")+" SF4 WHERE D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA AND SD2.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' AND F4_FILIAL = '"+Left(xFilial("SF2"), 2)+"' AND F4_CODIGO = D2_TES AND F4_ESTOQUE = 'S' AND F4_DUPLIC = 'N') AS F2_ITENSREM,"+Chr(13)+Chr(10) // AND D2_CF NOT IN("+cCfpoVenda+")
	//cQuery += "			       (SELECT TOP 1 D2_CF+'-'+LEFT(F4_TEXTO, 20)  FROM "+RetSqlName("SD2")+" SD2 WITH(NOLOCK), "+RetSqlName("SF4")+" SF4 WHERE D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA AND SD2.D_E_L_E_T_ = '' AND SF4.D_E_L_E_T_ = '' AND F4_FILIAL = '"+Left(xFilial("SF2"), 2)+"' AND F4_CF = D2_CF) AS OPERFIS,"+Chr(13)+Chr(10) // AND D2_CF NOT IN("+cCfpoVenda+")

	IF nx == 1
		cQuery += "			       A1_COD   , LEFT(A1_NREDUZ, 20) AS A1_NREDUZ, LEFT(A1_MUNE, 25) AS A1_MUNE , A1_ESTE AS A1_ESTE , ZF_VEICULO, "+Chr(13)+Chr(10)
	Else
		cQuery += "			       A2_COD   , LEFT(A2_NREDUZ, 20) AS A1_NREDUZ, LEFT(A2_MUN , 25) AS A1_MUNE , A2_EST  AS A1_ESTE , ZF_VEICULO, "+Chr(13)+Chr(10)	
	Endif

	cQuery += "			       CASE WHEN RTRIM(A4_NREDUZ) <> '' THEN LEFT(RTRIM(A4_NREDUZ), 15)"+Chr(13)+Chr(10)	
	cQuery += "			            ELSE LEFT(RTRIM(A4_NOME), 15) END AS TRANSPORTADOR,"+Chr(13)+Chr(10)	

	cQuery += "				   Isnull(ZZ_CODIGO , '') AS ZZ_CODIGO , "+Chr(13)+Chr(10)
	cQuery += "				   Isnull(ZF_EMISSAO, '') AS ZF_EMISSAO, "+Chr(13)+Chr(10)
	cQuery += "			       Isnull(ZG_DTENTR , '') AS ZG_DTENTR , "+Chr(13)+Chr(10)
	cQuery += "			       Isnull(ZG_RETORNO, '') AS ZG_RETORNO, "+Chr(13)+Chr(10)
	cQuery += "			       Isnull(ZG_MOTRETO, '') AS ZG_MOTRETO, "+Chr(13)+Chr(10)
	cQuery += "				   -- SE NAO HOUVER REGISTRO DE PESAGEM PARA A CARGA, USADA A DATA DE MONTAGEM DA CARGA COMO LIBERACAO"+Chr(13)+Chr(10)
	cQuery += "				   CASE WHEN Isnull(ZZ_CODIGO , '') = '' AND Isnull(ZG_DTENTR , '') <> '' THEN Isnull(ZF_EMISSAO, '')  ELSE Isnull(ZZ_DTPES2 , '') END AS ZZ_DATALIB, "+Chr(13)+Chr(10)
	cQuery += "			       -- SE A NOTA JA SAIU PARA ENTREGA, UTILIZA DATA DA LIBERAÇÃO, SENÃO A DATA DO DIA."+Chr(13)+Chr(10)
	cQuery += "			       CASE WHEN Isnull(ZZ_DTPES2, '') <> '' "+Chr(13)+Chr(10)
	cQuery += "					    THEN Isnull(DATEDIFF(DAY, CONVERT(DATE, F2_EMISSAO, 103), CONVERT(DATE, ZZ_DTPES2 , 103)), 0)"+Chr(13)+Chr(10)
	cQuery += "					    ELSE Isnull(DATEDIFF(DAY, CONVERT(DATE, F2_EMISSAO, 103), CONVERT(DATE, getdate() , 103)), 0) END as ZZ_QTDDIAS,"+Chr(13)+Chr(10)

	IF nx == 1
		cQuery += "                Isnull((SELECT SUM(D2_VALDEV + D2_ICMSRET + D2_VALIPI) FROM "+RetSqlName("SD2")+" WHERE D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA AND D2_VALDEV > 0), 0) AS VALORDEV,"+Chr(13)+Chr(10)
	Else
		cQuery += "                0 AS VALORDEV,"+Chr(13)+Chr(10)
	Endif

	cQuery += "                --TIPO DE FRETE"+Chr(13)+Chr(10)
	cQuery += "                CASE WHEN F2_TPFRETE = 'C' THEN 'CIF' "+Chr(13)+Chr(10)
	cQuery += "                     WHEN F2_TPFRETE = 'F' THEN 'FOB' "+Chr(13)+Chr(10)
	cQuery += "                     ELSE 'TERC' END AS TIPOFRETE"+Chr(13)+Chr(10)


	cQuery += "		      FROM "+RetSqlName("SF2")+" SF2"+Chr(13)+Chr(10)

	IF nx == 1
		// FAZ TRATAMENTO PARA NOTAS FISCAIS DE VENDA / REMESSA
		cQuery += "		     INNER JOIN "+RetSqlName("SA1")+" SA1 WITH(NOLOCK) ON A1_FILIAL = F2_FILIAL AND A1_COD   = F2_CLIENTE AND A1_LOJA = F2_LOJA AND SA1.D_E_L_E_T_  = ''"

		IF vpParContEx == "S"
			IF !Empty(vpParExpHum) .And. !Empty(vpParExpDoi)
				cQuery += " AND (A1_NREDUZ LIKE '%"+vpParExpHum+"%' OR A1_NREDUZ LIKE '%"+vpParExpDoi+"%') "+Chr(13)+Chr(10)
			ElseIF !Empty(vpParExpHum) .And. Empty(vpParExpDoi)
				cQuery += " AND A1_NREDUZ LIKE '%"+vpParExpHum+"%' "+Chr(13)+Chr(10)
			ElseIF Empty(vpParExpHum) .And. !Empty(vpParExpDoi)
				cQuery += " AND A1_NREDUZ LIKE '%"+vpParExpDoi+"%' "+Chr(13)+Chr(10)	
			Endif		
		Else
			IF !Empty(vpParExpHum) .And. !Empty(vpParExpDoi)
				cQuery += " AND (A1_NREDUZ NOT LIKE '%"+vpParExpHum+"%' AND A1_NREDUZ NOT LIKE '%"+vpParExpDoi+"%') "+Chr(13)+Chr(10)
			ElseIF !Empty(vpParExpHum) .And. Empty(vpParExpDoi)
				cQuery += " AND A1_NREDUZ NOT LIKE '%"+vpParExpHum+"%' "+Chr(13)+Chr(10)
			ElseIF Empty(vpParExpHum) .And. !Empty(vpParExpDoi)
				cQuery += " AND A1_NREDUZ NOT LIKE '%"+vpParExpDoi+"%' "+Chr(13)+Chr(10)	
			Endif	
		Endif
			
	Else
		// FAZ TRATAMENTO PARA NOTAS FISCAIS DE DEVOLUÇÃO DE COMPRA / BENEFICIAMENTO
		cQuery += "		     INNER JOIN "+RetSqlName("SA2")+" SA2 WITH(NOLOCK) ON A2_FILIAL = F2_FILIAL AND A2_COD   = F2_CLIENTE AND A2_LOJA = F2_LOJA AND SA2.D_E_L_E_T_  = ''"

		IF vpParContEx == "S"
			IF !Empty(vpParExpHum) .And. !Empty(vpParExpDoi)
				cQuery += " AND (A2_NREDUZ LIKE '%"+vpParExpHum+"%' OR A2_NREDUZ LIKE '%"+vpParExpDoi+"%') "+Chr(13)+Chr(10)
			ElseIF !Empty(vpParExpHum) .And. Empty(vpParExpDoi)
				cQuery += " AND A2_NREDUZ LIKE '%"+vpParExpHum+"%' "+Chr(13)+Chr(10)
			ElseIF Empty(vpParExpHum) .And. !Empty(vpParExpDoi)
				cQuery += " AND A2_NREDUZ LIKE '%"+vpParExpDoi+"%' "+Chr(13)+Chr(10)	
			Endif		
		Else
			IF !Empty(vpParExpHum) .And. !Empty(vpParExpDoi)
				cQuery += " AND (A2_NREDUZ NOT LIKE '%"+vpParExpHum+"%' AND A2_NREDUZ NOT LIKE '%"+vpParExpDoi+"%') "+Chr(13)+Chr(10)
			ElseIF !Empty(vpParExpHum) .And. Empty(vpParExpDoi)
				cQuery += " AND A2_NREDUZ NOT LIKE '%"+vpParExpHum+"%' "+Chr(13)+Chr(10)
			ElseIF Empty(vpParExpHum) .And. !Empty(vpParExpDoi)
				cQuery += " AND A2_NREDUZ NOT LIKE '%"+vpParExpDoi+"%' "+Chr(13)+Chr(10)	
			Endif	
		Endif
	Endif 

	//cQuery += "		     INNER JOIN "+RetSqlName("SA1")+" SA1 WITH(NOLOCK) ON A1_FILIAL = F2_FILIAL AND A1_COD   = F2_CLIENTE AND A1_LOJA = F2_LOJA AND SA1.D_E_L_E_T_  = ''"+Chr(13)+Chr(10)
	cQuery += "		      LEFT JOIN "+RetSqlName("SZF")+" SZF WITH(NOLOCK) ON ZF_FILIAL = '"+xFilial("SZF")+"'  AND ZF_NUM   = F2_CARGA   AND  SZF.D_E_L_E_T_  = ''"+Chr(13)+Chr(10)
	cQuery += "		      LEFT JOIN "+RetSqlName("SZG")+" SZG WITH(NOLOCK) ON ZG_FILIAL = '"+xFilial("SZG")+"'  AND ZG_NUM   = F2_CARGA   AND  ZG_NOTA = F2_DOC AND ZG_SERIE = F2_SERIE AND ZG_CLIENTE = F2_CLIENTE AND ZG_SERIE = F2_SERIE AND SZG.D_E_L_E_T_  = ''"+Chr(13)+Chr(10)
	cQuery += "		      LEFT JOIN "+RetSqlName("SZZ")+" SZZ WITH(NOLOCK) ON ZZ_FILIAL = '"+xFilial("SZZ")+"'  AND ZZ_CARGA <> ''        AND  ZZ_CARGA = F2_CARGA AND  SZZ.D_E_L_E_T_  = ''"+Chr(13)+Chr(10)
	cQuery += "		      LEFT JOIN "+RetSqlName("SA4")+" SA4 WITH(NOLOCK) ON A4_FILIAL = '"+xFilial("SA4")+"'  AND A4_COD   = F2_TRANSP  AND  SA4.D_E_L_E_T_  = ''"+Chr(13)+Chr(10)

	cQuery += "		     WHERE SF2.D_E_L_E_T_ = '' "+Chr(13)+Chr(10)
	cQuery += "		       AND F2_FILIAL = '"+xFilial("SF2")+"'"+Chr(13)+Chr(10)
	cQuery += "		       AND F2_EMISSAO BETWEEN '"+dtos(vpParEmiDe)+"' AND '"+dtos(vpParEmiAte)+"'"+Chr(13)+Chr(10)
	cQuery += "		       AND F2_CLIENTE BETWEEN '"+vpParCliDe+"' AND '"+vpParCliAte+"'"+Chr(13)+Chr(10)
	cQuery += "		       AND F2_EST     BETWEEN '"+vpParEstDe+"' AND '"+vpParEstAte+"'"+Chr(13)+Chr(10)
	cQuery += "		       AND F2_DOC     BETWEEN '"+vpParNotDe+"' AND '"+vpParNotAte+"'"+Chr(13)+Chr(10)
	cQuery += "		       AND F2_SERIE   BETWEEN '"+vpParNotDe+"' AND '"+vpParSerAte+"'"+Chr(13)+Chr(10)
	cQuery += "		       AND F2_TRANSP  BETWEEN '"+vpParTraDe+"' AND '"+vpParTraAte+"'"+Chr(13)+Chr(10) 
	
	IF nx == 1
		cQuery += "            AND F2_TIPO = 'N'"+Chr(13)+Chr(10)
	Else
		cQuery += "            AND F2_TIPO IN('D', 'B')"+Chr(13)+Chr(10)
	Endif

	// Quanto ao Embarque
	IF vpParStaEmb == "CC"
		cQuery += "		       AND F2_CARGA <> ''      -- FILTRO: EMBARCADAS "+Chr(13)+Chr(10)
	ElseIF vpParStaEmb == "SC"
		cQuery += "		       AND F2_CARGA =  ''      -- FILTRO: NÃO EMBARCADAS"+Chr(13)+Chr(10)
	Endif

	// Quanto ao Frete
	IF !empty(vpParTipFre)
		cQuery += "	   AND F2_TPFRETE = '"+vpParTipFre+"'"+Chr(13)+Chr(10)
	Endif

	IF nx == 1
		cQuery += Chr(13)+Chr(10)+"UNION"+Chr(13)+Chr(10)
	Endif
Next


cQuery += "		   ) QRY"+Chr(13)+Chr(10)

// Dias para Expedir
cQuery += "  WHERE ZZ_QTDDIAS >= "+str(vpParDiasEn, 3,0)+Chr(13)+Chr(10)


// Remove empresas Coligadas
IF !empty(cColigadas)
	cQuery += "     AND A1_COD NOT IN "+FormatIn(cColigadas, "/")+Chr(13)+Chr(10)
Endif 


// Tipo de Operação    
IF vpParOpera = "VD"
	cQuery += "     AND (F2_ITENSVND > 0 OR (F2_ITENSVND > 0 AND F2_ITENSREM > 0))"+Chr(13)+Chr(10)
ElseIf vpParOpera = "RE"
	cQuery += "     AND F2_ITENSVND = 0 AND F2_ITENSREM > 0"+Chr(13)+Chr(10)
Else
	cQuery += "     AND (F2_ITENSVND > 0 OR F2_ITENSREM > 0)"+Chr(13)+Chr(10)
Endif


// Quanto a Expedição
IF vpParStaExp == "LB"
    cQuery += "	   AND ZZ_DATALIB <> '' "+Chr(13)+Chr(10)
Elseif vpParStaExp == "PD"
    cQuery += "	   AND ZZ_DATALIB =  '' "+Chr(13)+Chr(10)
Endif

// Quanto ao Retorno
IF vpParStaRet == "EN"
    cQuery += "	   AND ZG_DTENTR  <> ''"+Chr(13)+Chr(10)
Elseif vpParStaRet == "DV"
    cQuery += "	   AND ZG_MOTRETO <> '' "+Chr(13)+Chr(10)
ElseIf vpParStaRet == "PD"
    cQuery += "	   AND ZZ_DATALIB <> '' AND ZG_DTENTR <> ''"+Chr(13)+Chr(10)
Endif



// Remove notas fiscais que foram integralmente devolvidas
cQuery += "    AND ROUND(VALORDEV, 0) < ROUND(F2_VALFAT, 0) "+Chr(13)+Chr(10)

cQuery += "   ORDER BY F2_EMISSAO, F2_NFISCAL"

Return (cQuery)


/* ===================================================================================
| Funcao: FSx1Func
| Data  : 29/08/22
| Autor : Paulo Rogerio 
| Descr.: Valida a existencia das pergustas no SX1 e as inclui caso as mesmas não existam.
=================================================================================== */
User Function FSx1Func(aRegs, cPerg)
//-- Inicializa Variaveis
Local nSX1Order := SX1->(IndexOrd())
Local nSX1Recno := SX1->(Recno())
Local lRet      := .F.
Local nX        := 0
Local nY        := 0

cPerg     := Padr(cPerg, Len(SX1->X1_GRUPO))
SX1->(dbSetOrder(1))

For nX := 1 to Len(aRegs)
    if !SX1->(dbSeek(cPerg + aRegs[nX,2]))
       lRet := .T.
       RecLock('SX1',.T.)
       For nY:=1 to fCount()
           If nY <= Len(aRegs[nX])
              SX1->(FieldPut(nY,aRegs[nX,nY]))
           Endif
       Next nY
       MsUnlock()
    Endif
Next nX

SX1->(dbSetOrder(nSX1Order))
SX1->(dbGoto(nSX1Recno))

Return lRet
