#include "Totvs.ch"
#include "Colors.ch"
#include "Protheus.ch"
#include "RwMake.ch"
#Include "Fwmvcdef.ch"
#include 'parmtype.ch'
#Include "Topconn.ch" 
#Include "Tbiconn.ch"

#define ENTER chr(13) + chr(10)

//---------------------------------------------------------
/*/{Protheus.doc} QEFAT003
Roatina para executar calculo tabela de preço 
-----------------------------------------------------------
Ultimo Fechamento do Custo médio + a margem definida por produto + Imposto: 
Fórmula: (Ultimo Fechamento Custo médio / (1-margem)) / fator imposto:
Fator imposto
Tabela 18% -      0,7275
Tabela 12% -      0,7875
Tabela 07% -      0,8375
-----------------------------------------------------------
@author Fabio Carneiro dos Santos
@since 15/03/2021
@update 03/04/2021
@version 1.0
@type Function
/*/
//-----------------------------------------------------------
User Function QEFAT003()

	Local aSays    := {}
	Local aButtons := {}
	Local nOpca    := 0
	Local cTitoDlg := "Carga Tabela Preço Euro e Importação de tabela "
	
	Private aRotina    := {}   
	Private cMark      :="ok" //GetMark()
    Private _cPerg     := "QEFAT03"
		
	// Prepara e executa a pergunta do relatorio

	aAdd(aSays, "Provisao da Tabela de Preço Para devida Conferencia antes de Atualizar!")
	aAdd(aSays, "Fórmula: (Ultimo Fechamento Custo médio / (1-margem % )) / fator imposto: ")
	aAdd(aSays, "Tabela 18% -      0,7275 ")
	aAdd(aSays, "Tabela 12% -      0,7875 ")
	aAdd(aSays, "Tabela 07% -      0,8375 ")
	
	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)
	
	If nOpca == 1
	
		oAjustaSx1()

		If !Pergunte(_cPerg,.T.)
			Return
		Else 
			Processa({|| U_QEFAT099("Gerando Dados Tabela de Preço...")})
		Endif
		
	EndIf
Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEFAT099  | Autor: | EURO          | Data: | 20/03/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QEFAT099                                     |
+------------+-----------------------------------------------------------+
*/

User Function QEFAT099()

	Local aCampos   as array
	Local aDados    as array

	Local _astru       :={}
	Local _afields     :={}
	Local _carq             
	Local aCores       := {} 
	Local cQuery       := ""

	Local nCalc18      := 0 
	Local nCalc12      := 0
	Local nCalc07      := 0
	Local _cDtULMES    := ""

	Private TRB1       := GetNextAlias()
	
	aCampos   := {} 
	
	aAdd( aRotina ,{"Marcar"            ,"u_QeMarc01()" ,0,3})
	aAdd( aRotina ,{"Desmarcar"         ,"u_QeDesM02()" ,0,2}) 
	aAdd( aRotina ,{"Inverter"          ,"u_QeMakA03()" ,0,4})
	aAdd( aRotina ,{"Atualiza Tabela"   ,"u_QeGerA05()" ,0,5})
	
	cCadastro := "Manutenção Lista Preço - Grupo Euroamerican "
	
	MakeDir("C:\TOTVS")
	
	Aadd(_astru,{"OK"          ,"C",02})
	Aadd(_astru,{"FILIAL"      ,"C",04})
	Aadd(_astru,{"CODIGO"      ,"C",15})
	Aadd(_astru,{"DESCRICAO"   ,"C",30})
	Aadd(_astru,{"TIPO"        ,"C",02})
	Aadd(_astru,{"CODTAB"      ,"C",03})
	Aadd(_astru,{"DESCTAB"     ,"C",30})
	Aadd(_astru,{"PERCTAB"     ,"N",16,2})
	Aadd(_astru,{"VLTABATU"    ,"N",16,2})
	Aadd(_astru,{"VLMEDIO"     ,"N",16,2})
	Aadd(_astru,{"VLNET"       ,"N",16,2})
	Aadd(_astru,{"VLTAB18"     ,"N",16,2})
	Aadd(_astru,{"VLTAB12"     ,"N",16,2})
	Aadd(_astru,{"VLTAB07"     ,"N",16,2})
	Aadd(_astru,{"DTULMES"     ,"C",10})

	_carq:="T_"+Criatrab(,.F.)
	MsCreate(_carq,_astru,"DBFCDX")
	Sleep(1000)
	// atribui a tabela temporária ao alias TRB
	dbUseArea(.T.,"DBFCDX",_cARq,"TRB",.T.,.F.)
	
	IndRegua("TRB", _cArq, "FILIAL+CODIGO+TIPO+CODTAB",,, "Indexando ....")
		
	aCores := {}

	aAdd(aCores,{"TRB->OK == 'ok'","BR_VERDE"	})
	aAdd(aCores,{"TRB->OK <> 'ok'","BR_VERMELHO"})
	aAdd(aCores,{"TRB->OK == 'ev'","BR_LARANJA"	})
	
	Aadd(_afields,{ "OK"         ,"", "Mark"             ,"@X"})
	Aadd(_afields,{ "FILIAL"     ,"", "Filial"           ,"@X"})
	Aadd(_afields,{ "CODIGO"     ,"", "Codigo Produto"   ,"@X"})
	Aadd(_afields,{ "DESCRICAO"  ,"", "Desc. Produto"    ,"@X"})
	Aadd(_afields,{ "TIPO"       ,"", "Tipo"             ,"@X"})
	Aadd(_afields,{ "CODTAB"     ,"", "Cod. Tab. Preço"  ,"@X"})
	Aadd(_afields,{ "DESCTAB"    ,"", "Desc. Tab. Preço" ,"@X"})
	Aadd(_afields,{ "PERCTAB"    ,"", "% Margen "        ,"@E 999,999,999.99"})
	Aadd(_afields,{ "VLTABATU"   ,"", "Vl. Tab. Atual"   ,"@E 999,999,999.99"})
	Aadd(_afields,{ "VLMEDIO"    ,"", "Vl. Ult. Fech. C.Medio"  ,"@E 999,999,999.99"})
    Aadd(_afields,{ "VLNET"      ,"", "Vl. Custo NET"    ,"@E 999,999,999.99"})
	Aadd(_afields,{ "VLTAB18"    ,"", "Previsao Vl. Tab. 18%" ,"@E 999,999,999.99"})
	Aadd(_afields,{ "VLTAB12"    ,"", "Previsao Vl. Tab. 12%" ,"@E 999,999,999.99"})
	Aadd(_afields,{ "VLTAB07"    ,"", "Previsao Vl. Tab. 7%"  ,"@E 999,999,999.99"})
	Aadd(_afields,{ "DTULMES"    ,"", "Data Ult. Fechamento" ,"@X"})

	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf
	
	cQuery  := "SELECT '" + Rtrim(SM0->M0_NOME) + "' AS EMP,  " + ENTER
	cQuery  += " B9_FILIAL, DA0_CODTAB , DA0_DESCRI, DA0_DATDE, DA0_DATATE, DA1_CODPRO, B1_DESC, B1_TIPO, DA1_GRUPO, DA1_ZPMARG, " + ENTER
	cQuery  += " DA1_PRCVEN , B9_CM1, B9_LOCAL, B1_CUSTNET, B9_DATA " + ENTER
	cQuery  += " FROM " + RetSqlName("DA0") + " AS DA0 " + ENTER
	cQuery  += " INNER JOIN " + RetSqlName("DA1") + " AS DA1 WITH (NOLOCK) ON DA0_CODTAB = DA1_CODTAB " + ENTER
	cQuery  += " INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '    '  " + ENTER
	cQuery  += "  AND B1_COD = DA1_CODPRO " + ENTER
	cQuery  += " INNER JOIN " + RetSqlName("SB9") + " AS SB9 WITH (NOLOCK) ON B9_COD = DA1_CODPRO " + ENTER
	cQuery  += "  AND B9_COD    = B1_COD " + ENTER
	cQuery  += "  AND B9_FILIAL = '"+xFilial("SB9")+"' " + ENTER
	cQuery  += "WHERE SUBSTRING(DA1_CODTAB,1,1) = 'E' " + ENTER
	cQuery  += " AND B1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  " + ENTER
	cQuery  += " AND DA0_CODTAB BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'  " + ENTER
	cQuery  += " AND B9_DATA = (SELECT MAX(B9_DATA) AS DATA FROM SB9100 WHERE B9_FILIAL = '"+xFilial("SB9")+"' AND D_E_L_E_T_ = ' ')  " + ENTER
	cQuery  += " AND B1_MSBLQL = '2'  " + ENTER
	cQuery  += " AND B9_LOCAL = '08'  " + ENTER
	cQuery  += " AND DA0.D_E_L_E_T_ = ' '   " + ENTER
	cQuery  += " AND DA1.D_E_L_E_T_ = ' '   " + ENTER
	cQuery  += " AND SB1.D_E_L_E_T_ = ' '   " + ENTER
	cQuery  += " AND SB9.D_E_L_E_T_ = ' '   " + ENTER
	cQuery  += " GROUP BY B9_FILIAL, DA0_CODTAB , DA0_DESCRI, DA0_DATDE, DA0_DATATE, DA1_CODPRO, B1_DESC,B1_TIPO ,DA1_GRUPO, " + ENTER
	cQuery  += " DA1_ZPMARG, DA1_PRCVEN , B9_CM1, B9_LOCAL,B1_CUSTNET, B9_DATA  " + ENTER
	
	cQuery  += "UNION ALL " + ENTER

	cQuery  += "SELECT '" + Rtrim(SM0->M0_NOME) + "' AS EMP,  " + ENTER
	cQuery  += " '"+xFilial("SB9")+"' AS B92_FILIAL, DA0_CODTAB , DA0_DESCRI, DA0_DATDE, DA0_DATATE, DA1_CODPRO, B1_DESC, B1_TIPO, DA1_GRUPO, DA1_ZPMARG, " + ENTER
	cQuery  += " DA1_PRCVEN , '0' AS B9_CM1, '08' AS B9_LOCAL, B1_CUSTNET, '0000000' AS B9_DATA " + ENTER
	cQuery  += " FROM " + RetSqlName("DA0") + " AS DA0 " + ENTER
	cQuery  += " INNER JOIN " + RetSqlName("DA1") + " AS DA1 WITH (NOLOCK) ON DA0_CODTAB = DA1_CODTAB " + ENTER
	cQuery  += " INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '    '  " + ENTER
	cQuery  += "  AND B1_COD = DA1_CODPRO " + ENTER
	cQuery  += "WHERE DA1_CODPRO NOT IN (SELECT B9_COD FROM "+RetSqlName("SB9")+" AS SB9 WHERE B9_LOCAL = '08' AND B9_DATA = (SELECT MAX(B9_DATA) AS DATA FROM SB9100 WHERE B9_FILIAL = '"+xFilial("SB9")+"' AND D_E_L_E_T_ = ' ') AND SB9.D_E_L_E_T_ = ' ' ) " + ENTER
	cQuery  += " AND B1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  " + ENTER
	cQuery  += " AND DA0_CODTAB BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'  " + ENTER
	cQuery  += " AND B1_MSBLQL = '2'  " + ENTER
	cQuery  += " AND DA0.D_E_L_E_T_ = ' '   " + ENTER
	cQuery  += " AND DA1.D_E_L_E_T_ = ' '   " + ENTER
	cQuery  += " AND SB1.D_E_L_E_T_ = ' '   " + ENTER
	cQuery  += " GROUP BY DA0_CODTAB , DA0_DESCRI, DA0_DATDE, DA0_DATATE, DA1_CODPRO, B1_DESC, B1_TIPO, DA1_GRUPO, " + ENTER
	cQuery  += " DA1_ZPMARG, DA1_PRCVEN , B1_CUSTNET  " + ENTER

	TcQuery cQuery ALIAS "TRB1" NEW
	
	TRB1->(DbGoTop())

	ProcRegua(TRB1->(LastRec()))

	While TRB1->(!Eof())

		DbSelectArea("TRB")        
		
		_cDtULMES := Substr(TRB1->B9_DATA,7,2)+"/"+Substr(TRB1->B9_DATA,5,2)+"/"+Substr(TRB1->B9_DATA,1,4)
		
		If TRB1->B9_CM1 > 0

			nCalc18   := (TRB1->B9_CM1/(1-TRB1->DA1_ZPMARG/100)) / 0.7275 
			nCalc12   := (TRB1->B9_CM1/(1-TRB1->DA1_ZPMARG/100)) / 0.7875
			nCalc07   := (TRB1->B9_CM1/(1-TRB1->DA1_ZPMARG/100)) / 0.8375

		Else 

			nCalc18   := (TRB1->B1_CUSTNET/(1-TRB1->DA1_ZPMARG/100)) / 0.7275 
			nCalc12   := (TRB1->B1_CUSTNET/(1-TRB1->DA1_ZPMARG/100)) / 0.7875
			nCalc07   := (TRB1->B1_CUSTNET/(1-TRB1->DA1_ZPMARG/100)) / 0.8375
		
		EndIf 
		
		RecLock("TRB",.T.)   
			
			TRB->OK        := " "
			TRB->FILIAL    := TRB1->B9_FILIAL
			TRB->CODIGO    := TRB1->DA1_CODPRO
			TRB->DESCRICAO := TRB1->B1_DESC
			TRB->TIPO      := TRB1->B1_TIPO
			TRB->CODTAB    := TRB1->DA0_CODTAB
			TRB->DESCTAB   := TRB1->DA0_DESCRI
			TRB->PERCTAB   := TRB1->DA1_ZPMARG
			TRB->VLTABATU  := TRB1->DA1_PRCVEN
			TRB->VLMEDIO   := TRB1->B9_CM1
			TRB->VLNET     := TRB1->B1_CUSTNET
			TRB->VLTAB18   := nCalc18
			TRB->VLTAB12   := nCalc12
			TRB->VLTAB07   := nCalc07
			TRB->DTULMES   := _cDtULMES

		TRB->(Msunlock()) 	
		DbSelectArea("TRB") 

		TRB1->(DbSkip())

		IncProc("Gerando arquivo...")

	EndDo
	
	DbSelectArea("TRB")
	DbGotop()
	
	MarkBrow( "TRB", "OK",,_afields,, cMark,"u_QeMakA04()",,,,"u_QeMark03()",{|| u_QeMakA04()},,,aCores,,,,.F.) 
	
	If Select("TRB") > 0
		TRB->(DbCloseArea())
	EndIf
	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf
	
	MsErase(_carq+GetDBExtension(),,"DBFCDX") 

Return()

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QeMarcar  | Autor: | QUALY         | Data: | 13/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QeMarcar                                     |
+------------+-----------------------------------------------------------+
*/

User Function QeMarc01()                              

Local oMark := GetMarkBrow()

DbSelectArea("TRB")
DbGotop()
	While !Eof()        
 		If RecLock( "TRB", .F. )                
 			TRB->OK := cMark                
 			MsUnLock()        
 		EndIf        
 	dbSkip()
 	Enddo
 	MarkBRefresh()      
 	// força o posicionamento do browse no primeiro registro
 	oMark:oBrowse:Gotop()
Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QeDesMar  | Autor: | QUALY         | Data: | 13/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QeDesMar                                     |
+------------+-----------------------------------------------------------+
*/
User Function QeDesM02()

Local oMark := GetMarkBrow()

DbSelectArea("TRB")
DbGotop()
	
	While !Eof()        
 		
 		If RecLock( "TRB", .F. )                
 			TRB->OK := SPACE(2)                
 		MsUnLock()        
 		
 		EndIf        
 		
 		dbSkip()
 	
 	Enddo
 
MarkBRefresh()

// força o posicionamento do browse no primeiro registro
 
oMark:oBrowse:Gotop()
 
Return 
 
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QeMark    | Autor: | QUALY         | Data: | 13/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QeMark                                       |
+------------+-----------------------------------------------------------+
*/
User Function QeMark03()
	
	If IsMark( "OK", cMark )        
		RecLock( "TRB", .F. )                
			Replace OK With Space(2)        
		MsUnLock()
	Else        
		RecLock("TRB", .F. )                
			Replace OK With cMark        
		MsUnLock()
	EndIf
Return 

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QeMakAll  | Autor: | QUALY         | Data: | 13/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QeMakAll                                     |
+------------+-----------------------------------------------------------+
*/
 
User Function QeMakA04()   

Local oMark := GetMarkBrow()

dbSelectArea("TRB")
dbGotop()
	While !Eof()        
		
		u_QeMark03()        
		
		dbSkip()
	End

MarkBRefresh()// força o posicionamento do browse no primeiro registro

oMark:oBrowse:Gotop()

Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QeGerAll  | Autor: | QUALY         | Data: | 13/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QeGerAll                                     |
+------------+-----------------------------------------------------------+
*/
 
User Function QeGerA05()

	MsAguarde({|lEnd| cGerAll(@lEnd)},"Gerando Atualização dos Preços...","Gerando Atualização tabela de Preço",.T.)
	
	DbSelectArea("TRB")

Return

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | cGerAll   | Autor: | QUALY         | Data: | 13/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - cGerAll                                     |
+------------+-----------------------------------------------------------+
*/
Static Function cGerAll(lEnd) 

Local aAreaSB1 	:= SB1->(GetArea()) 
Local aAreaDA0 	:= DA0->(GetArea()) 
Local aAreaDA1 	:= DA1->(GetArea()) 

Local cQuery    := ""
Local _lPassa1  := .F.

Private TRB2    := GetNextAlias()

DbSelectArea("TRB")
TRB->(dbGoTop())

While TRB->(!Eof())   
	
	If IsMark( "OK", cMark )

		If Select("TRB2") > 0
			TRB2->(DbCloseArea())
		EndIf
		
		cQuery  := "SELECT B9_FILIAL, DA0_CODTAB , DA0_DESCRI, DA0_DATDE, DA0_DATATE, DA1_CODPRO, B1_DESC, B1_TIPO, DA1_GRUPO, DA1_ZPMARG, " + ENTER
		cQuery  += " DA1_PRCVEN , B9_CM1, B9_LOCAL, B1_CUSTNET, B9_DATA, DA1_ITEM " + ENTER
		cQuery  += " FROM " + RetSqlName("DA0") + " AS DA0 " + ENTER
		cQuery  += " INNER JOIN " + RetSqlName("DA1") + " AS DA1 WITH (NOLOCK) ON DA0_CODTAB = DA1_CODTAB " + ENTER
		cQuery  += " INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '    '  " + ENTER
		cQuery  += "  AND B1_COD = DA1_CODPRO " + ENTER
		cQuery  += " INNER JOIN " + RetSqlName("SB9") + " AS SB9 WITH (NOLOCK) ON B9_COD = DA1_CODPRO " + ENTER
		cQuery  += "  AND B9_COD    = B1_COD " + ENTER
		cQuery  += "  AND B9_FILIAL = '"+xFilial("SB9")+"' " + ENTER
		cQuery  += "WHERE SUBSTRING(DA1_CODTAB,1,1) = 'E' " + ENTER
		cQuery  += " AND B1_COD     = '"+TRB->CODIGO+"'   " + ENTER
		cQuery  += " AND DA0_CODTAB = '"+TRB->CODTAB+"'  " + ENTER
		cQuery  += " AND B9_DATA = (SELECT MAX(B9_DATA) AS DATA FROM SB9100 WHERE B9_FILIAL = '"+xFilial("SB9")+"' AND D_E_L_E_T_ = ' ')  " + ENTER
		cQuery  += " AND B1_MSBLQL = '2'  " + ENTER
		cQuery  += " AND B9_LOCAL = '08'  " + ENTER
		cQuery  += " AND DA0.D_E_L_E_T_ = ' '   " + ENTER
		cQuery  += " AND DA1.D_E_L_E_T_ = ' '   " + ENTER
		cQuery  += " AND SB1.D_E_L_E_T_ = ' '   " + ENTER
		cQuery  += " AND SB9.D_E_L_E_T_ = ' '   " + ENTER
		cQuery  += " GROUP BY B9_FILIAL, DA0_CODTAB , DA0_DESCRI, DA0_DATDE, DA0_DATATE, DA1_CODPRO, B1_DESC,B1_TIPO ,DA1_GRUPO, " + ENTER
		cQuery  += " DA1_ZPMARG, DA1_PRCVEN , B9_CM1, B9_LOCAL,B1_CUSTNET, B9_DATA, DA1_ITEM  " + ENTER
		
		cQuery  += "UNION ALL " + ENTER

		cQuery  += "SELECT '"+xFilial("SB9")+"' AS B92_FILIAL, DA0_CODTAB , DA0_DESCRI, DA0_DATDE, DA0_DATATE, DA1_CODPRO, B1_DESC, B1_TIPO, DA1_GRUPO, DA1_ZPMARG, " + ENTER
		cQuery  += " DA1_PRCVEN , '0' AS B9_CM1, '08' AS B9_LOCAL, B1_CUSTNET, '0000000' AS B9_DATA, DA1_ITEM " + ENTER
		cQuery  += " FROM " + RetSqlName("DA0") + " AS DA0 " + ENTER
		cQuery  += " INNER JOIN " + RetSqlName("DA1") + " AS DA1 WITH (NOLOCK) ON DA0_CODTAB = DA1_CODTAB " + ENTER
		cQuery  += " INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '    '  " + ENTER
		cQuery  += "  AND B1_COD = DA1_CODPRO " + ENTER
		cQuery  += "WHERE DA1_CODPRO NOT IN (SELECT B9_COD FROM "+RetSqlName("SB9")+" AS SB9 WHERE B9_LOCAL = '08' AND B9_DATA = (SELECT MAX(B9_DATA) AS DATA FROM SB9100 WHERE B9_FILIAL = '"+xFilial("SB9")+"' AND D_E_L_E_T_ = ' ') AND SB9.D_E_L_E_T_ = ' ' ) " + ENTER
		cQuery  += " AND B1_COD     = '"+TRB->CODIGO+"'   " + ENTER
		cQuery  += " AND DA0_CODTAB = '"+TRB->CODTAB+"'  " + ENTER
		cQuery  += " AND B1_MSBLQL = '2'  " + ENTER
		cQuery  += " AND DA0.D_E_L_E_T_ = ' '   " + ENTER
		cQuery  += " AND DA1.D_E_L_E_T_ = ' '   " + ENTER
		cQuery  += " AND SB1.D_E_L_E_T_ = ' '   " + ENTER
		cQuery  += " GROUP BY DA0_CODTAB , DA0_DESCRI, DA0_DATDE, DA0_DATATE, DA1_CODPRO, B1_DESC, B1_TIPO, DA1_GRUPO, " + ENTER
		cQuery  += " DA1_ZPMARG, DA1_PRCVEN , B1_CUSTNET, DA1_ITEM " + ENTER

		TcQuery cQuery ALIAS "TRB2" NEW
		
		TRB2->(DbGoTop())
	
		If AllTrim(Posicione("SB1",1, xFilial("SB1")+TRB2->DA1_CODPRO,"B1_COD")) == AllTrim(TRB->CODIGO)
        	_lPassa1 := .T.
    	Else 
    		_lPassa1   := .F.
    	EndIf 
    	
		DbSelectArea("DA1")
		DbSetOrder(2)

		If DbSeek(xFilial("DA1")+TRB2->DA1_CODPRO+TRB2->DA0_CODTAB+TRB2->DA1_ITEM) 
		
			If _lPassa1  .And. TRB2->DA0_CODTAB = 'EU2'  // Tabela para o calculo de 18%
	
				RecLock("DA1",.F.)

					DA1_ZPMARG  := TRB->PERCTAB
					DA1_PRCVEN  := TRB->VLTAB18 

	    		DA1->(MsUnlock())
			
			EndIf 
			
			If _lPassa1  .And. TRB2->DA0_CODTAB = 'EU3' // Tabela para o calculo de 12%
	
				RecLock("DA1",.F.)

					DA1_ZPMARG  := TRB->PERCTAB
					DA1_PRCVEN  := TRB->VLTAB12 

	    		DA1->(MsUnlock())
			
			EndIf 
		
			If _lPassa1  .And. TRB2->DA0_CODTAB = 'EU4' // // Tabela para o calculo de 7%
	
				RecLock("DA1",.F.)

					DA1_ZPMARG  := TRB->PERCTAB
					DA1_PRCVEN  := TRB->VLTAB07 

	    		DA1->(MsUnlock())
					
			EndIf 
			
			If _lPassa1 .And. !(TRB2->DA0_CODTAB) $ 'EU2/EU3/EU4' 
	
				RecLock("DA1",.F.)

					DA1_ZPMARG  := TRB->PERCTAB
					DA1_PRCVEN  := TRB->VLTAB18 

	    		DA1->(MsUnlock())
					
			EndIf 

		EndIf

	Endif

	ProcessMessage()

	DbSelectArea("TRB")
	
	TRB->(dbSkip()) 

EndDo

MarkBRefresh() 

DA0->(dbCloseArea())
DA1->(dbCloseArea())
If Select("TRB2") > 0
	TRB2->(DbCloseArea())
EndIf
RestArea(aAreaSB1)
RestArea(aAreaDA0)
RestArea(aAreaDA1)

Return
/*
+------------+------------+--------+---------------+-------+--------------+
| Programa:  | oAjustaSx1 | Autor: | QUALY         | Data: | 13/02/21     |
+------------+------------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - Perguntas                                     |
+------------+------------------------------------------------------------+
*/
Static Function oAjustaSx1()

Local _aPerg  := {}  // aRRAY 
Local _ni

Aadd(_aPerg,{"Produtos De  ......?"        ,"mv_ch1","C",15,"G","mv_par01","","","","","","SB1","","",0})
Aadd(_aPerg,{"Produtos Até ......?"        ,"mv_ch2","C",15,"G","mv_par02","","","","","","SB1","","",0})
Aadd(_aPerg,{"Tabela Preço De....?"        ,"mv_ch3","C",03,"G","mv_par03","","","","","","DA1EUR","","",0})
Aadd(_aPerg,{"Tabela Preço Até...?"        ,"mv_ch4","C",03,"G","mv_par04","","","","","","DA1EUR","","",0})

dbSelectArea("SX1")
For _ni := 1 To Len(_aPerg)
	If !dbSeek(_cPerg+ SPACE( LEN(SX1->X1_GRUPO) - LEN(_cPerg))+StrZero(_ni,2))
		RecLock("SX1",.T.)
		SX1->X1_GRUPO    := _cPerg
		SX1->X1_ORDEM    := StrZero(_ni,2)
		SX1->X1_PERGUNT  := _aPerg[_ni][1]
		SX1->X1_VARIAVL  := _aPerg[_ni][2]
		SX1->X1_TIPO     := _aPerg[_ni][3]
		SX1->X1_TAMANHO  := _aPerg[_ni][4]
		SX1->X1_GSC      := _aPerg[_ni][5]
		SX1->X1_VAR01    := _aPerg[_ni][6]
		SX1->X1_DEF01    := _aPerg[_ni][7]
		SX1->X1_DEF02    := _aPerg[_ni][8]
		SX1->X1_DEF03    := _aPerg[_ni][9]
		SX1->X1_DEF04    := _aPerg[_ni][10]
		SX1->X1_DEF05    := _aPerg[_ni][11]
		SX1->X1_F3       := _aPerg[_ni][12]
		SX1->X1_CNT01    := _aPerg[_ni][13]
		SX1->X1_VALID    := _aPerg[_ni][14]
		SX1->X1_DECIMAL  := _aPerg[_ni][15]
		MsUnLock()
	EndIf
Next _ni

Return






