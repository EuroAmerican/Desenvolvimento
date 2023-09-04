#include "totvs.ch"
#Include "Protheus.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TbiConn.Ch'

#DEFINE cEof  CHAR(13)+CHAR(10)

User Function FM020PLAN()
    Local oReport
    Private cArqTrab
    Private cPerg 		:= PADR("FM020PLAN",10)
    Private cTitulo 	:= OemToAnsi("Relacao de titulos Perda")
  
    Pergunte(cPerg,.T.)	 
    oReport 			:= ReportDef()
    oReport:PrintDialog()
RETURN

Static Function ReportDef() 
    Local oReport   := Nil
    Local oSection1 := Nil 
    Local oSection2 := Nil
    Local aOrdem 	:={}
    Local cDesc 	:= cTitulo
    Local oBreak

    oReport:= TReport():New("FM020PLAN",cTitulo,cPerg, {|oReport| ReportPrint(oReport)},cDesc)

    oReport:SetLandscape() //Define a orientacao de pagina do relatorio como paisagem.
    oReport:SetTotalInLine(.F.)


    oSection1 := TRSection():New(oReport,"Relacao dos titulos de perda",{"cQry01"},aOrdem)

    TRCell():New(oSection1,'ZB_STATUS'	,'cQry01','Status'     ,PesqPict('SZB',"ZB_CLIENTE")	,TamSX3("ZB_CLIENTE") [1]+1,,)  
    TRCell():New(oSection1,'ZB_CLIENTE'	,'cQry01','Cliente'    ,PesqPict('SZB',"ZB_CLIENTE")	,TamSX3("ZB_CLIENTE") [1]+1,,)  
    TRCell():New(oSection1,'ZB_LOJA'	,'cQry01','Loja'       ,PesqPict('SZB',"ZB_LOJA")	 	,TamSX3("ZB_LOJA") [1]+1,,) 
    TRCell():New(oSection1,'ZB_NOME'	,'cQry01','Nome'       ,PesqPict('SZB',"ZB_NOME")		,TamSX3("ZB_NOME") [1]+1,,)   
    TRCell():New(oSection1,'ZB_PREFIXO'	,'cQry01','Prefixo'    ,PesqPict('SZB',"ZB_PREFIXO")	,TamSX3("ZB_PREFIXO") [1]+1,,) 
    TRCell():New(oSection1,'ZB_NUM'		,'cQry01','Numero'     ,PesqPict('SZB',"ZB_NUM")		,TamSX3("ZB_NUM") [1]+1,,) 
    TRCell():New(oSection1,'ZB_PARCELA'	,'cQry01','Parcela'    ,PesqPict('SZB',"ZB_PARCELA")	,TamSX3("ZB_PARCELA") [1]+1,,) 
    TRCell():New(oSection1,'ZB_VENCTO'	,'cQry01','Vencimento' ,PesqPict('SZB',"ZB_VENCTO")		,TamSX3("ZB_VENCTO") [1]+1,,) 
    TRCell():New(oSection1,'ZB_VALOR'	,'cQry01','Valor'      ,PesqPict('SZB',"ZB_VALOR")		,TamSX3("ZB_VALOR") [1]+1,,) 

    oBreak := TRBreak():New(oSection1,{|| ZB_CLIENTE },"Total Titulos de perda do cliente ", .F.)	
    TRFunction():New(oSection1:Cell("ZB_VALOR")				,NIL,"SUM"		,oBreak, , , , .F., .T.)
    oSection1:SetHeaderSection(.T.)
		
    oSection2 := TRSection():New(oReport,"Titulos Gerados",{"cQry02"},)

    TRCell():New(oSection2,'E1_PREFIXO'	,'cQry02','Prefixo'     ,PesqPict('SE1',"E1_PREFIXO")		,TamSX3("E1_PREFIXO") [1]+1,,)  
    TRCell():New(oSection2,'E1_NUM'		,'cQry02','Numero'     	,PesqPict('SE1',"E1_NUM")			,TamSX3("E1_NUM") [1]+1,,)  
    TRCell():New(oSection2,'E1_PARCELA'	,'cQry02','Parcela'     ,PesqPict('SE1',"E1_PARCELA")		,TamSX3("E1_PARCELA") [1]+1,,)  
    TRCell():New(oSection2,'E1_TIPO'	,'cQry02','Tipo'     	,PesqPict('SE1',"E1_TIPO")			,TamSX3("E1_TIPO") [1]+1,,)  
    TRCell():New(oSection2,'E1_NATUREZ'	,'cQry02','Natureza' 	,PesqPict('SE1',"E1_NATUREZ")		,TamSX3("E1_NATUREZ") [1]+1,,)  
    TRCell():New(oSection2,'E1_EMISSAO'	,'cQry02','Emissao'  	,PesqPict('SE1',"E1_EMISSAO")		,TamSX3("E1_EMISSAO") [1]+1,,)  
    TRCell():New(oSection2,'E1_VENCTO'	,'cQry02','Vencimento'  ,PesqPict('SE1',"E1_VENCTO")		,TamSX3("E1_VENCTO") [1]+1,,)  
    TRCell():New(oSection2,'E1_VENCREA'	,'cQry02','Venc.Real'   ,PesqPict('SE1',"E1_VENCREA")		,TamSX3("E1_VENCREA") [1]+1,,)  
    TRCell():New(oSection2,'E1_BAIXA'	,'cQry02','Baixa'     	,PesqPict('SE1',"E1_BAIXA")			,TamSX3("E1_BAIXA") [1]+1,,)  
    TRCell():New(oSection2,'E1_VALOR'	,'cQry02','Valor'     	,PesqPict('SE1',"E1_VALOR")			,TamSX3("E1_VALOR") [1]+1,,)  
    oBreak := TRBreak():New(oSection2,{|| E1_NUM },"Total Titulos Negociados ", .F.)	
    TRFunction():New(oSection2:Cell("E1_VALOR")				,NIL,"SUM"		,oBreak, , , , .F., .T.)
    oSection1:SetHeaderSection(.T.)
    oReport:SetTotalInLine(.F.) 
        //Aqui, farei uma quebra  por seção
    oSection1:SetPageBreak(.T.)
    oSection1:SetTotalText(" ")				

Return(oReport)
                                   

Static Function ReportPrint(oReport)      
  	Local oSection1 := oReport:Section(1)
    Local oSection2 := oReport:Section(2)
    Local cQuery    := ' '
    Local cCliente,cLoja,cTitneg:= ' '
  
    cQuery :="Select		ZB_STATUS, "    +cEof
    cQuery +="				ZB_FILIAL, "    +cEof
    cQuery +="				ZB_CLIENTE, "    +cEof
    cQuery +="				ZB_LOJA, "    +cEof
    cQuery +="				ZB_NOME, "    +cEof
    cQuery +="				ZB_PREFIXO, "    +cEof
    cQuery +="				ZB_NUM, "    +cEof
    cQuery +="				ZB_PARCELA, "    +cEof
    cQuery +="				ZB_VENCTO, "    +cEof
    cQuery +="				ZB_VALOR, "    +cEof
    cQuery +="				ZB_TITNEG "    +cEof
    cQuery +="from "+RetSqlName("SZB")+" SZB "    +cEof
    cQuery +="Where D_E_L_E_T_ = ' ' "    +cEof
    cQuery +="AND ZB_FILIAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "    +cEof
    cQuery +="AND ZB_CLIENTE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "    +cEof
    cQuery +="AND ZB_VEND BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "    +cEof

   
    If  Select("cQry01") > 0
            DbSelectArea("cQry01")
            DbCloseArea()
    Endif

    TCQUERY cQuery NEW ALIAS "cQry01"
    TCSetField("cQry01", "ZB_VENCTO", "D")

    oReport:SetMeter(("cQry01")->(LastRec()))
    oSection1:Init()

    dbSelectArea("cQry01")
    While !oReport:Cancel() .And. !("cQry01")->(Eof())   
        oSection1:Cell("ZB_STATUS"):SetValue(IIF(("cQry01")->ZB_STATUS='1',"Titulo Perda",IIF(("cQry01")->ZB_STATUS='2',"Em Negociação","Liquidados") )   )
        oSection1:Cell("ZB_CLIENTE"):SetValue(("cQry01")->ZB_CLIENTE)
        oSection1:Cell("ZB_LOJA"):SetValue(("cQry01")->ZB_LOJA)
        oSection1:Cell("ZB_NOME"):SetValue(("cQry01")->ZB_NOME)
        oSection1:Cell("ZB_PARCELA"):SetValue(("cQry01")->ZB_PARCELA)
        oSection1:Cell("ZB_VENCTO"):SetValue(("cQry01")->ZB_VENCTO)
        oSection1:Cell("ZB_VALOR"):SetValue(("cQry01")->ZB_VALOR)
        cTitNeg := ("cQry01")->ZB_TITNEG
        cCliente:= ("cQry01")->ZB_CLIENTE
        cLoja := ("cQry01")->ZB_LOJA
	    oSection1:PrintLine()
	    oReport:IncMeter()
        dbSelectArea("cQry01")
        dbSkip()
    EndDo
    oSection1:Finish()

    cQuery    := ' '
    cQuery    :="SELECT E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_NATUREZ,E1_EMISSAO,E1_VENCTO,E1_VENCREA,E1_BAIXA,E1_VALOR "    +cEof
    cQuery    +="FROM "+RetSqlName("SE1")+" "    +cEof
    cQuery    +="Where D_E_L_E_T_ = ' ' "    +cEof
    cQuery    +="AND E1_PREFIXO = 'PRD' "    +cEof
    cQuery    +="AND E1_FILIAL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "    +cEof
    cQuery    +="and E1_NUM = '"+cTitNeg+"' "    +cEof
    cQuery    +="AND E1_CLIENTE = '"+cCliente+"'"    +cEof
    cQuery    +="AND E1_LOJA = '"+cLoja+"'"    +cEof

    If  Select("cQry02") > 0
            DbSelectArea("cQry02")
            DbCloseArea()
    Endif

    TCQUERY cQuery NEW ALIAS "cQry02"
    TCSetField("cQry02", "E1_EMISSAO", "D")
    TCSetField("cQry02", "E1_VENCTO", "D")
    TCSetField("cQry02", "E1_VENCREA", "D")
    TCSetField("cQry02", "E1_BAIXA", "D")

    oReport:SetMeter(("cQry02")->(LastRec()))
    oSection2:Init()

    dbSelectArea("cQry02")
    While !oReport:Cancel() .And. !("cQry02")->(Eof())    

        oSection2:Cell("E1_PREFIXO"):SetValue(("cQry02")->E1_PREFIXO)
        oSection2:Cell("E1_NUM"):SetValue(("cQry02")->E1_NUM)
        oSection2:Cell("E1_PARCELA"):SetValue(("cQry02")->E1_PARCELA)
        oSection2:Cell("E1_TIPO"):SetValue(("cQry02")->E1_TIPO)
        oSection2:Cell("E1_NATUREZ"):SetValue(("cQry02")->E1_NATUREZ)
        oSection2:Cell("E1_EMISSAO"):SetValue(("cQry02")->E1_EMISSAO)
        oSection2:Cell("E1_VENCTO"):SetValue(("cQry02")->E1_VENCTO)
        oSection2:Cell("E1_VENCREA"):SetValue(("cQry02")->E1_VENCREA)
        oSection2:Cell("E1_BAIXA"):SetValue(("cQry02")->E1_BAIXA)
        oSection2:Cell("E1_VALOR"):SetValue(("cQry02")->E1_VALOR)

	    oSection2:PrintLine()
	    oReport:IncMeter()
        dbSelectArea("cQry02")
        dbSkip()
    EndDo
    oSection2:Finish()
    oReport:ThinLine() 

Return NIL 
