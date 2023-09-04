#include 'protheus.ch'
#include 'parmtype.ch'
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "ap5mail.ch"
#Include "RwMake.Ch"

/*/{Protheus.doc} RELORCNAO
//Rotina visualiza pedido venda
@author Fabio Batista
@since 09/12/2020
@version 1.0
/*/

User Function RELORCNAO()

Local   oReport
Local oBreak
Private cPerg     := "RELORCNAO"
Private cAliasQry := GetNextAlias()

	ValidPerg()

If !Pergunte( cPerg, .T.)
	ApMsgAlert( 'Processamento cancelado!', 'Atenção')
	Return
EndIf

	oReport := ReportDef()
	oReport:PrintDialog()

Return nil


Static Function ReportDef()
Local oReport, oSection
	
	oReport := TReport():New("RELORCNAO","Relatório de orçamentos", cPerg , {|oReport| ReportPrint(oReport)} , "Relatório de orçamentos não aprovados" )
                             
	oSection := TRSection():New(oReport,"Dados", cAliasQRY)               

	TRCell():New(oSection, "CJ_FILIAL"  , cAliasQRY, "Filial"       ,     , 04 )
	TRCell():New(oSection, "CJ_NUM"     , cAliasQRY, "Orçamento"    ,     , 06 )
	TRCell():New(oSection, "CJ_EMISSAO" , cAliasQRY, "Emissão"      ,     , 08 )
	TRCell():New(oSection, "CJ_CLIENTE" , cAliasQRY, "Cod.Cliente"  ,     , 06 )
	TRCell():New(oSection, "CJ_LOJA"    , cAliasQRY, "Loja"         ,     , 02 )
	TRCell():New(oSection, "A1_NOME"    , cAliasQRY, "Nome"         ,     , 40 )
	TRCell():New(oSection, "CJ_VEND1"   , cAliasQRY, "Vendedor"     ,     , 06 )
	TRCell():New(oSection, "A3_NREDUZ"  , cAliasQRY, "Nome vendedor"         ,     , 30 )
    TRCell():New(oSection, "CK_VALOR"   , cAliasQRY, "Valor"        , "@E 999,999,999,999,999.99",16)

    oBreak := TRBreak():New(oSection,oSection:Cell("CJ_NUM"),"Orçamento")

    TRFunction():New(oSection:Cell("CK_VALOR"),NIL,"SUM"  ,,,,,.F.,.T.,.T.)
    

    oReport:SetLandScape()

Return(oReport)


Static Function ReportPrint(oReport)
Local   oSection  := oReport:Section(1)
Local   cQuery    


    cQuery    := "SELECT CJ_FILIAL,CJ_NUM,CJ_EMISSAO,CJ_CLIENTE,CJ_LOJA,CJ_VEND1 " + CRLF
    cQuery    += ",SUM(CK_VALOR) AS CK_VALOR " + CRLF
    cQuery    += ",A1_COD,A1_NOME,A3_NREDUZ " + CRLF
	cQuery    += " FROM "+RetSqlName("SCJ")+" SCJ" + CRLF 
    cQuery    += "INNER JOIN "+RetSqlName("SCK") + " SCK" + CRLF 
    cQuery    += "ON CJ_FILIAL = CK_FILIAL AND CJ_NUM = CK_NUM AND CJ_CLIENTE = CK_CLIENTE AND CJ_LOJA = CK_LOJA AND SCK.D_E_L_E_T_ = '' " + CRLF
    cQuery    += "INNER JOIN "+RetSqlName("SA1") + " SA1" + CRLF
    cQuery    += "ON CJ_FILIAL = A1_FILIAL AND CJ_CLIENTE = A1_COD AND CJ_LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = '' " + CRLF
    cQuery    += "INNER JOIN "+RetSqlName("SA3") + " SA3"  + CRLF 
    cQuery    += "ON CJ_VEND1 = A3_COD " + CRLF 
    cQuery    += "WHERE SCJ.D_E_L_E_T_ = '' AND CJ_XMARGEM = 'NAO' AND CJ_FILIAL =  '"+xFilial("SA1")+"'" + CRLF
    cQuery    += "AND CJ_NUM >= '"+mv_par03+ "' AND CJ_NUM <= '"+mv_par04+ "' " + CRLF
    cQuery    += "AND CJ_EMISSAO >=   '"+DTOS(mv_par01)+ "' AND CJ_EMISSAO <=  '"+DTOS(mv_par02)+ "' " + CRLF
    cQuery    += "GROUP BY CJ_FILIAL,CJ_NUM,CJ_EMISSAO,CJ_CLIENTE,CJ_LOJA,CJ_VEND1 " + CRLF
    cQuery    += ",A1_COD,A1_NOME,A3_NREDUZ " + CRLF  
    cQuery    += "ORDER BY CJ_NUM " + CRLF

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )
	TcSetField( cAliasQry, "CJ_EMISSAO"  , "D", 8, 0 )
	oSection:Print()


Return nil  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ValidPergºAutor  ³ Fabio F Sousa      º Data ³ 26/04/2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Parâmetros da rotina...                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Beraca Sabara                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ValidPerg()

Local aArea := GetArea()
Local aPerg := {}

cPerg := PADR( cPerg, Len(SX1->X1_GRUPO))

aAdd( aPerg, { cPerg, "01", "Dt.Emissão de ?" , "MV_CH1" , "D", 08, 0, "G", "MV_PAR01", "", "", "", "", "", ""})
aAdd( aPerg, { cPerg, "02", "Dt.Emissão até ?", "MV_CH2" , "D", 08, 0, "G", "MV_PAR02", "", "", "", "", "", ""})
aAdd( aPerg, { cPerg, "03", "Orçamento de ?"  , "MV_CH3" , "C", 06, 0, "G", "MV_PAR03", "", "", "", "", "", ""})
aAdd( aPerg, { cPerg, "04", "Orçamento de ?"  , "MV_CH4" , "C", 06, 0, "G", "MV_PAR04", "", "", "", "", "", ""})


dbSelectArea("SX1")
dbSetOrder(1)

For i := 1 To Len(aPerg)
	If  !dbSeek(aPerg[i,1]+aPerg[i,2])
		RecLock("SX1",.T.)
	Else
		RecLock("SX1",.F.)
	EndIf
	Replace X1_GRUPO   With aPerg[i,01]
	Replace X1_ORDEM   With aPerg[i,02]
	Replace X1_PERGUNT With aPerg[i,03]
	Replace X1_VARIAVL With aPerg[i,04]
	Replace X1_TIPO	   With aPerg[i,05]
	Replace X1_TAMANHO With aPerg[i,06]
	Replace X1_PRESEL  With aPerg[i,07]
	Replace X1_GSC	   With aPerg[i,08]
	Replace X1_VAR01   With aPerg[i,09]
	Replace X1_F3	   With aPerg[i,10]
	Replace X1_DEF01   With aPerg[i,11]
	Replace X1_DEF02   With aPerg[i,12]
	Replace X1_DEF03   With aPerg[i,13]
	Replace X1_DEF04   With aPerg[i,14]
	Replace X1_VALID   With aPerg[i,15]
	MsUnlock()
Next i

RestArea(aArea)

Return(.T.)
