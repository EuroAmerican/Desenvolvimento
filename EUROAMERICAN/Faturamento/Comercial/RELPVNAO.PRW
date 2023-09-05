#include 'protheus.ch'
#include 'parmtype.ch'
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "ap5mail.ch"
#Include "RwMake.Ch"

/*/{Protheus.doc} RELPVNAO
//Rotina visualiza pedido venda
@author Fabio Batista
@since 09/12/2020
@version 1.0
/*/

User Function RELPVNAO()

Local   oReport
Local oBreak
Private cPerg     := "RELPVNAO"
Private cAliasQry := GetNextAlias()

	ValidPerg()

If !Pergunte( cPerg, .T.)
	ApMsgAlert( 'Processamento cancelado!', 'Atenção')
	Return
EndIf

	oReport := ReportDef()
	oReport:PrintDialog()

Return nil

/*/{Protheus.doc} ReportDef
//Rotina visualiza pedido venda
@author Fabio Batista
@since 09/12/2020
@version 1.0
/*/
Static Function ReportDef()
Local oReport, oSection
	
	oReport := TReport():New("RELPVNAO","Relatório de Pedido de Venda", cPerg , {|oReport| ReportPrint(oReport)} , "Relatório de Pedido de Venda não aprovados" )
                             
	oSection := TRSection():New(oReport,"Dados", cAliasQRY)               

	TRCell():New(oSection, "C5_FILIAL"  , cAliasQRY, "Filial"       ,     , 04 )
	TRCell():New(oSection, "C5_NUM"     , cAliasQRY, "Ped.Venda"    ,     , 06 )
	TRCell():New(oSection, "C5_EMISSAO" , cAliasQRY, "Emissão"      ,     , 08 )
	TRCell():New(oSection, "C5_CLIENTE" , cAliasQRY, "Cod.Cliente"  ,     , 06 )
	TRCell():New(oSection, "C5_LOJACLI"    , cAliasQRY, "Loja"         ,     , 02 )
	TRCell():New(oSection, "A1_NOME"    , cAliasQRY, "Nome"         ,     , 40 )
	TRCell():New(oSection, "C5_VEND1"   , cAliasQRY, "Vendedor"     ,     , 06 )
	TRCell():New(oSection, "A3_NREDUZ"  , cAliasQRY, "Nome vendedor"         ,     , 30 )
    TRCell():New(oSection, "C6_VALOR"   , cAliasQRY, "Valor"        , "@E 999,999,999,999,999.99",16)

    oBreak := TRBreak():New(oSection,oSection:Cell("C5_NUM"),"Orçamento")

    TRFunction():New(oSection:Cell("C6_VALOR"),NIL,"SUM"  ,,,,,.F.,.T.,.T.)
    

    oReport:SetLandScape()

Return(oReport)

/*/{Protheus.doc} ReportPrint
//Rotina visualiza pedido venda
@author Fabio Batista
@since 10/12/2020
@version 1.0
/*/
Static Function ReportPrint(oReport)
Local   oSection  := oReport:Section(1)
Local   cQuery    


    cQuery    := "SELECT C5_FILIAL, C5_LOJACLI, C5_NUM, C5_CLIENTE, C5_VEND1, C5_EMISSAO,  " + CRLF
    cQuery    += "SUM(C6_VALOR) AS C6_VALOR,  " + CRLF
    cQuery    += "A1_COD,A1_NOME, " + CRLF
	cQuery    += "A3_COD,A3_NOME " + CRLF
	cQuery    += " FROM "+RetSqlName("SC5")+" SC5" + CRLF 
    cQuery    += "INNER JOIN "+RetSqlName("SC6") + " SC6" + CRLF 
    cQuery    += "ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM AND C5_CLIENTE = C6_CLI AND C5_LOJACLI = C6_LOJA AND SC6.D_E_L_E_T_ = '' " + CRLF
    cQuery    += "INNER JOIN "+RetSqlName("SA1") + " SA1" + CRLF
    cQuery    += "ON C5_FILIAL = A1_FILIAL AND C5_CLIENTE = A1_COD AND C5_LOJACLI = A1_LOJA AND SA1.D_E_L_E_T_= '' " + CRLF
    cQuery    += "INNER JOIN "+RetSqlName("SA3") + " SA3"  + CRLF 
    cQuery    += "ON C5_VEND1 = A3_COD AND SA3.D_E_L_E_T_ = '' " + CRLF 
    cQuery    += "WHERE SC5.D_E_L_E_T_ = '' AND C5_FILIAL = '"+xFilial("SA1")+"'" + CRLF 
	//cQuery    += "AND C5_XMARGEM = 'NAO' " + CRLF
	cQuery    += "AND C5_NUM>= '"+mv_par03+ "' AND C5_NUM <= '"+mv_par04+ "' " + CRLF
	cQuery    += "AND C5_EMISSAO >=   '"+DTOS(mv_par01)+ "' AND C5_EMISSAO <=  '"+DTOS(mv_par02)+ "' " + CRLF
	cQuery    += "GROUP BY C5_FILIAL, C5_LOJACLI ,C5_NUM, C5_CLIENTE, C5_VEND1, C5_EMISSAO,  " + CRLF
    cQuery    += "A1_COD,A1_NOME, " + CRLF  
    cQuery    += "A3_COD,A3_NOME " + CRLF  
	cQuery    += "ORDER BY C5_NUM " + CRLF

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )
	TcSetField( cAliasQry, "C5_EMISSAO"  , "D", 8, 0 )
	oSection:Print()


Return nil  


/*/{Protheus.doc} ValidPerg
//Rotina visualiza pedido venda
@author Fabio Batista
@since 10/12/2020
@version 1.0
/*/
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
