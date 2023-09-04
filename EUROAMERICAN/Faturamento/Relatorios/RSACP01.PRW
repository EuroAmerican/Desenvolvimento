#include "totvs.ch"
#Include "Protheus.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TbiConn.Ch'

#DEFINE cEof  CHAR(13)+CHAR(10)

User Function RSACP01()
    Local oReport
    Private cArqTrab
    Private cPerg 		:= PADR("RSACP01",10)
    Private cTitulo 	:= OemToAnsi("Relacao Mão de Obra")
    Pergunte(cPerg,.F.)	 
    oReport 			:= ReportDef()
    oReport:PrintDialog()
RETURN

Static Function ReportDef() 
    Local oReport   := Nil
    Local oSection1 := Nil 
    Local aOrdem 	:={}
    Local cDesc 	:= cTitulo
    Local oBreak

    PutSX1(cPerg,"01","Data Inicial    	?","         	?" ,"         	?" 	,"mv_ch1","D",08,00,00,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",{"Informe a data Inicial","",""},{""},{""})
    PutSX1(cPerg,"02","Data Final   	?","         	?" ,"          	?" 	,"mv_ch2","D",08,00,00,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",{"Informe a data Final","",""},{""},{""})
    PutSX1(cPerg,"03","Da Filial     	?","          	?" ,"         	?" 	,"mv_ch3","C",10,00,00,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",{"Informe a data Final","",""},{""},{""})
    PutSX1(cPerg,"04","Ate Filial    	?","          	?" ,"          	?" 	,"mv_ch4","C",10,00,00,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",{"Informe a data Final","",""},{""},{""})
    PutSX1(cPerg,"05","Do Produto   	?","          	?" ,"          	?" 	,"mv_ch5","C",15,00,00,"G","","","","","mv_par05","","","","","","","","","","","","","","","","",{"Informe a data Final","",""},{""},{""})
    PutSX1(cPerg,"06","Ate Produto   	?","          	?" ,"          	?" 	,"mv_ch6","C",15,00,00,"G","","","","","mv_par06","","","","","","","","","","","","","","","","",{"Informe a data Final","",""},{""},{""})

    oReport:= TReport():New("RSACP01",cTitulo,cPerg, {|oReport| ReportPrint(oReport)},cDesc)
    oReport:SetLandscape() //Define a orientacao de pagina do relatorio como paisagem.
    oReport:SetTotalInLine(.F.)


    oSection1 := TRSection():New(oReport,"Notas",{"cQry01"},aOrdem)
    TRCell():New(oSection1,'D1_FILIAL'   	,'cQry01','Filial'      ,PesqPict('SD1',"D1_FILIAL")	,TamSX3("D1_FILIAL")	    [1]+1,,)                           
    TRCell():New(oSection1,'D1_DTDIGIT'   	,'cQry01','Entrada'     ,PesqPict('SD1',"D1_DTDIGIT")	,TamSX3("D1_DTDIGIT")	    [1]+1,,)                           
    TRCell():New(oSection1,'D1_DOC'		    ,'cQry01','Nota'	    ,PesqPict('SD1',"D1_DOC")		,TamSX3("D1_DOC")		[1]+1,,)
    TRCell():New(oSection1,'D1_SERIE' 	    ,'cQry01','Serie'	    ,PesqPict('SD1',"D1_SERIE")	    ,TamSX3("D1_SERIE")	[1]+1,,)
    TRCell():New(oSection1,'D1_FORNECE'		,'cQry01','Fornecedor'	,PesqPict('SD1',"D1_FORNECE")	,TamSX3("D1_FORNECE")		[1]+1,,)
    TRCell():New(oSection1,'D1_LOJA' 		,'cQry01','Loja'	    ,PesqPict('SD1',"D1_LOJA")	    ,TamSX3("D1_LOJA")	[1]+1,,)
    TRCell():New(oSection1,'A2_NOME'		,'cQry01','Razao'		,PesqPict('SD1',"A2_NOME")		,TamSX3("A2_NOME")		[1]+1,,)
    TRCell():New(oSection1,'D1_COD'			,'cQry01','Produto'		,PesqPict('SD1',"D1_COD")		,TamSX3("D1_COD")		[1]+1,,)
    TRCell():New(oSection1,'D1_TOTAL'		,'cQry01','Total'	    ,PesqPict('SD1',"D1_TOTAL")		,TamSX3("D1_TOTAL")		[1]+1,,)

    oBreak := TRBreak():New(oSection1,{|| D1_COD },"Sub Total por Produto ", .F.)	
    TRFunction():New(oSection1:Cell("D1_TOTAL")				,NIL,"SUM"		,oBreak, , , , .F., .T.)
		

    oReport:SetTotalInLine(.F.)
       
        //Aqui, farei uma quebra  por seção
    oSection1:SetPageBreak(.T.)
    oSection1:SetTotalText(" ")				

Return(oReport)
                                   

Static Function ReportPrint(oReport)      
  	Local oSection1 := oReport:Section(1)
    Local cQuery    := ' '

    cQuery :="SELECT D1_FILIAL,D1_DTDIGIT,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,A2_NOME,D1_COD,D1_TOTAL "    +cEof
    cQuery +="FROM "+RetSqlName("SD1")+" SD1 "    +cEof
    cQuery +="INNER JOIN "+RetSqlName("SA2")+" SA2 ON A2_COD = D1_FORNECE AND A2_LOJA = D1_LOJA AND SA2.D_E_L_E_T_ = ' ' "    +cEof
    cQuery +="Where SD1.D_E_L_E_T_ = ' ' "    +cEof
    cQuery +="AND   D1_FILIAL  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "    +cEof 
    cQuery +="AND   D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "    +cEof
    cQuery +="AND   D1_COD     BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "    +cEof 
    cQuery +="ORDER BY D1_COD "    +cEof 

    Memowrit("C:\dados\RSACP01.Sql",cQuery)

    If  Select("cQry01") > 0
            DbSelectArea("cQry01")
            DbCloseArea()
    Endif

    TCQUERY cQuery NEW ALIAS "cQry01"

    oReport:SetMeter(("cQry01")->(LastRec()))
    oSection1:Init()

    dbSelectArea("cQry01")
    While !oReport:Cancel() .And. !("cQry01")->(Eof())   
        // Quebra de Nota Entrada
        oSection1:Cell("D1_FILIAL"):SetValue(("cQry01")->D1_FILIAL)
        oSection1:Cell("D1_DTDIGIT"):SetValue(STOD(("cQry01")->D1_DTDIGIT))
        oSection1:Cell("D1_DOC"):SetValue(("cQry01")->D1_DOC )
        oSection1:Cell("D1_SERIE"):SetValue(("cQry01")->D1_SERIE )
        oSection1:Cell("D1_FORNECE"):SetValue(("cQry01")->D1_FORNECE )
        oSection1:Cell("D1_LOJA"):SetValue(("cQry01")->D1_LOJA)
        oSection1:Cell("A2_NOME"):SetValue(("cQry01")->A2_NOME )
        oSection1:Cell("D1_COD"):SetValue(("cQry01")->D1_COD)
        oSection1:Cell("D1_TOTAL"):SetValue(("cQry01")->D1_TOTAL)
	    oSection1:PrintLine()
	    oReport:IncMeter()
        dbSelectArea("cQry01")
        dbSkip()
    EndDo
    
oSection1:Finish()
oReport:ThinLine() 

Return NIL 

