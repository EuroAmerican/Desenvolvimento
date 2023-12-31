#include 'protheus.ch'
#include 'parmtype.ch'
#include "totvs.ch"
#include 'topconn.ch'
#include 'tbiconn.ch'

#Define ENTER chr(13) + chr(10)
#Define CRLF chr(13) + chr(10)
/*/{Protheus.doc} rest002
//Rotina para impress�o, chamado via mta650mnu
@author mjlozzardo
@since 15/03/2018
@version 1.0
@type function
/*/
user function REST002()
	Local cAlias    := Alias()
	Local cPerg     := "REST002"
	Local cTipoBar  := ""
	Local aDados    := {}
	Local cCodPrd   := ""
	Local _dDtValid := CTOD("  /  /  ")
	Local _dDtEtiq  := CTOD("  /  /  ")
	Local cQry      := "" 
	Local lPermite  := GETMV("MV_XDTETQ",,.F.)
	Local _aLista   := {}
	Local _nLista   := 0
	Local cQuery    := ""
	
	AjustSX1()
	
	SB1->(DbSetOrder(1))  //filial + cod
	SB8->(DbSetOrder(5))  //filial + produto + lote
	CB5->(DbSetOrder(1))  //filial + cod

	// Rachadinha do FS
	lFazQualy := .F.
	lFazEuro  := .F.
	If cFilAnt == "0901"  //AllTrim( SM0->M0_CODIGO ) == "09"
		If ApMsgYesNo( "Utilizar padr�o Qualyvinil?", "Aten��o")
			lFazQualy := .T.
		Else
			lFazEuro  := .T.
		EndIf
	EndIf

	If Left(cFilAnt, 2) == "08" .Or. lFazQualy
		If Pergunte(cPerg, .T.)
			Pergunte(cPerg, .F.)

			//Verifica se ja foi impresso
			If CB5->(DbSeek(xFilial("CB5") + MV_PAR01, .F.))
				If !Usacb0("01")
					cTipoBar := 'MB04'
				EndIf

                // Valida Impressao da Etiqueta
	       if ExistBlock("RESTVLD")
         		cRet := ' '
				cRet:=ExecBlock("RESTVLD",.f.,.f.,Padr(SubStr(SC2->C2_NUM, 1, 6),10))
				IF !Empty(cRet)
                        MsgAlert(cRet)  
				Endif
           endif

				//Imprime etiqueta
				Set Century Off // IMPRESSAO COM O DOIS D�GITOS DO ANO.
				SB1->(DbSeek(xFilial("SB1") + SC2->C2_PRODUTO, .F.))
					CB5SetImp("000001")
				dbSelectArea("SB8")
				dbSetOrder(3)
				If dbSeek(xFilial("SB8")+SC2->C2_PRODUTO+SC2->C2_LOCAL+Padr(SubStr(SC2->C2_NUM, 1, 6),10))
				
					If MV_PAR06 == 1

						If lPermite
							dDtVld := MV_PAR08
							dDtFab := MV_PAR07
						Else 
							dDtVld := SB8->B8_DTVALID
							dDtFab := SB8->B8_DFABRIC
						EndIf 
						
					EndIf

					If MV_PAR06 == 2   
					
						dDtVld := SB8->B8_DTVALID
						dDtFab := SB8->B8_DFABRIC
					
					EndIf 

				Else

					If MV_PAR06 == 1

						If lPermite
							dDtVld := MV_PAR08
							dDtFab := MV_PAR07
						Else 
							dDtVld := SC2->C2_XDTVALI
							dDtFab := SC2->C2_EMISSAO
						EndIf

					EndIf

					If MV_PAR06 == 2

						dDtVld := SC2->C2_XDTVALI
						dDtFab := SC2->C2_EMISSAO
					
					EndIf

				EndIf

				aDados := {}
				aAdd(aDados, IIF(!EMPTY(SB1->B1_U_DESC2),Rtrim(Substr(SB1->B1_U_DESC2,1,25)),Rtrim(Substr(SB1->B1_DESC,1,25))))	//01 descricao
				aAdd(aDados, SB1->B1_COD)	//02 codigo
				aAdd(aDados, SB1->B1_CODBAR)	//03 ean13
				aAdd(aDados, Padr(SubStr(SC2->C2_NUM, 1, 6),10))	//04  op/lote
				aAdd(aDados, dDtFab)  //05 dt fab
				aAdd(aDados, dDtVld)  //06 dt val

				If MV_PAR02 == 1
					aAdd(aDados, MV_PAR03)  //07 quantidade
				Else
					aAdd(aDados, SC2->C2_QUANT + MV_PAR03)  //07 quantidade
				EndIf

				If !Empty(SB1->B1_U_UMETQ)
					aAdd(aDados, RTRIM(SB1->B1_U_CONTD)+Lower(RTRIM(SB1->B1_U_UMETQ)))	//08 peso
				Else
					aAdd(aDados,"")	//08 peso
				EndIf
              
                // Grava CV8


				If !Empty(SB1->B1_CODBAR)
						U_IACD001("001", aDados,Padr(SubStr(SC2->C2_NUM, 1, 6),10))  //IMPRIMIR QUALY media
					Set Century On  //Termino da impressao
					MscbClosePrinter()
				Else
					MsgStop("C�digo de barras n�o preenchido para o produto, solicitar cadastro!")
				EndIf

			EndIf
		EndIf
	ElseIf Left(cFilAnt, 2) == "02" .Or. lFazEuro

		If Pergunte(cPerg, .T.)
			Pergunte(cPerg, .F.)

			If CB5->(DbSeek(xFilial("CB5") + MV_PAR01, .F.))
				If !Usacb0("01")
					cTipoBar := 'MB04'
				EndIf

                 // Valida a Etiquera
            // Valida Impressao da Etiqueta
				if ExistBlock("RESTVLD")
					//aParam2:= {cFilSZB,cCliente,cLoja}
					cRet := ' '
					cRet:=ExecBlock("RESTVLD",.f.,.f.,Padr(SubStr(SC2->C2_NUM, 1, 6),10))
					IF !Empty(cRet)
                        MsgAlert(cRet)  
					Endif
				endif

				//Imprime etiqueta
				Set Century Off // IMPRESSAO COM O DOIS D�GITOS DO ANO.
				SB1->(DbSeek(xFilial("SB1") + SC2->C2_PRODUTO, .F.))
				CB5SetImp(MV_PAR01)

				If Substr(SB1->B1_COD,1,2) $ "PI"
					cCodPrd := Rtrim(SB1->B1_COD)
				ElseIf Len(Alltrim(SB1->B1_COD)) > 12
					cCodPrd := SubStr(SB1->B1_COD, 1, 4) + Right(Alltrim(SB1->B1_COD), 2)
				Else
					cCodPrd := SubStr(SB1->B1_COD, 1, 3)
				EndIf
				nQtdCB0 := Int(Iif(SB1->B1_TIPCONV == "D", SC2->C2_QUANT / SB1->B1_CONV, SC2->C2_QUANT * SB1->B1_CONV))

				aDados := {}
				aAdd(aDados, cCodPrd)  //01
				aAdd(aDados, Alltrim(SubStr(SB1->B1_DESC,1,18)) + " (" + Rtrim(SB1->B1_COD) + ")")  //02

				If MV_PAR05 > 0
					aAdd(aDados, MV_PAR05)  //03
				Else
					aAdd(aDados, SC2->C2_QUANT / nQtdCB0)  //03
				EndIf

				aAdd(aDados, SC2->C2_NUM)  //04
				aAdd(aDados, Posicione("SAH", 1, xFilial("SAH") + SB1->B1_SEGUM, "AH_UMRES"))  //05
				/*
				+------------------------------------------------------------------+
				| F�bio Carneiro - 14/09/2022  - Projeto impress�o de Etiqueta     |
				| Motivo: Ser� gravado uma tabela para controle de data fabrica��o |
				+------------------------------------------------------------------+
				*/
				If Select("TRB1") > 0
					TRB1->(DbCloseArea())
				EndIf

				cQuery := "SELECT * FROM "+RetSqlName("PAY")+" AS PAY WITH (NOLOCK) "+CRLF
				cQuery += "WHERE PAY_FILIAL = '"+xFilial("PAY")+"' "+CRLF
				cQuery += " AND PAY_OP = '"+SC2->C2_NUM+"01"+"001"+"' "+CRLF
				cQuery += " AND PAY_LOTE = '"+SC2->C2_NUM+"' "+CRLF
				cQuery += " AND SUBSTRING(PAY_PROD,1,3) = '"+SUBSTR(SC2->C2_PRODUTO,1,3)+"' "+CRLF
				cQuery += " AND PAY.D_E_L_E_T_ = ' ' "+CRLF 
				cQuery += "ORDER BY PAY_LOTE  "+CRLF

				TCQuery cQuery New Alias "TRB1"

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

							RecLock("PAY",.F.)
							PAY->PAY_FILIAL := _aLista[_nLista][01]
							PAY->PAY_CTRL   := If(Empty(_aLista[_nLista][02]),"000001",StrZero(Val(_aLista[_nLista][02])+1,6))
							PAY->PAY_SEQ    := "001" 
							PAY->PAY_PROD   := AllTrim(_aLista[_nLista][04]) 
							PAY->PAY_OP     := AllTrim(_aLista[_nLista][05]) 
							PAY->PAY_LOTE   := Alltrim(_aLista[_nLista][06]) 
							PAY->PAY_DTFAB  := StoD(_aLista[_nLista][07]) 
							PAY->PAY_DTVAL  := StoD(_aLista[_nLista][08]) 
							PAY->PAY_HRREG  := _aLista[_nLista][09] 
							PAY->PAY_STATUS := "1"
							PAY->(MsUnlock())
							
						EndIf

						_dDtValid := StoD(_aLista[_nLista][08])
						_dDtEtiq  := StoD(_aLista[_nLista][07])

					Next _nLista

					cQry := " UPDATE " + RetSqlName("SC2") + " "
					cQry += " SET C2_DTETIQ = '" + DtoS(_dDtEtiq) + "', C2_XDTVALI = '" + DtoS(_dDtValid) + "',  "
					cQry += " C2_DTFABR = '" + DtoS(_dDtEtiq) + "', C2_DTVALID = '" + DtoS(_dDtValid) + "'  "
					cQry += " FROM " + RetSqlName("SC2") + " AS SC2 "
					cQry += " WHERE C2_FILIAL = '"+xFilial("SC2")+"' "
					cQry += " AND C2_NUM    = '" + SC2->C2_NUM + "' "
					cQry += " AND SC2.D_E_L_E_T_ = ' ' "

					TcSQLExec(cQry)

				Else 
						
					DbSelectArea("PAY")
					RecLock("PAY",.T.)
					PAY->PAY_FILIAL := xFilial("PAY")
					PAY->PAY_CTRL   := "000001" 
					PAY->PAY_SEQ    := "001" 
					PAY->PAY_PROD   := AllTrim(SC2->C2_PRODUTO)  
					PAY->PAY_OP     := AllTrim(SC2->C2_NUM+"01"+"001")     
					PAY->PAY_LOTE   := AllTrim(SC2->C2_NUM)
					PAY->PAY_DTFAB  := dDataBase 
					PAY->PAY_DTVAL  := dDataBase+SB1->B1_PRVALID 
					PAY->PAY_HRREG  := time() 
					PAY->PAY_STATUS := "1"
					PAY->(MsUnlock())

					_dDtValid := dDataBase+SB1->B1_PRVALID 
					_dDtEtiq  := dDataBase

					cQry := " UPDATE " + RetSqlName("SC2") + " "
					cQry += " SET C2_DTETIQ = '" + DtoS(_dDtEtiq) + "', C2_XDTVALI = '" + DtoS(_dDtValid) + "',  "
					cQry += " C2_DTFABR = '" + DtoS(_dDtEtiq) + "', C2_DTVALID = '" + DtoS(_dDtValid) + "'  "
					cQry += " FROM " + RetSqlName("SC2") + " AS SC2 "
					cQry += " WHERE C2_FILIAL = '"+xFilial("SC2")+"' "
					cQry += " AND C2_NUM    = '" + SC2->C2_NUM + "' "
					cQry += " AND SC2.D_E_L_E_T_ = ' ' "

					TcSQLExec(cQry)

				EndIf

				aAdd(aDados, _dDtEtiq) //06
				aAdd(aDados, _dDtValid) //07

				aAdd(aDados, "")  //08

				If MV_PAR05 > 0
					aAdd(aDados, 1)
				Else
					If MV_PAR02 == 1  //somente adicionais
						aAdd(aDados, MV_PAR03)  //09 quantidade
					Else
						aAdd(aDados, nQtdCB0 + MV_PAR03)  //09 quantidade
					EndIf
				EndIf

				aAdd(aDados, Alltrim(SB1->B1_COD))  //10 codigo produto

				U_IACD001("003", aDados,Padr(SubStr(SC2->C2_NUM, 1, 6),10))  //IMPRIMIR A ETIQUETA

				Set Century On  //Termino da impressao
				MscbClosePrinter()
			EndIf
		EndIf
	EndIf
	DbSelectArea(cAlias)

	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf
	If Select("TRB2") > 0
		TRB2->(DbCloseArea())
	EndIf

Return

Static Function AjustSX1()
	Local cAlias   := Alias()
	Local aHelpPor := {}

	//Pergunta 01
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o local de impress�o")
	aAdd(aHelpPor, "das etiquetas")
	U_FATUSX1("REST002","01","Local de Impress�o ?","Local de Impress�o ?","Local de Impress�o ?","MV_CH1","C",6,0,0,"G",'ExistCpo("CB5")',"MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","CB5","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 02
	aHelpPor := {}
	aAdd(aHelpPor, "Imprimir total ou somente adicional")
	U_FATUSX1("REST002","02","Imp s� adicional?","Imp s� adicional?","Imp s� adicional?","MV_CH2","N",1,0,0,"C",'',"MV_PAR02","Sim","Sim","Sim","","N�o","N�o","N�o","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 03
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o n�mero de etiquetas adicionais")
	U_FATUSX1("REST002","03","Qtd etiqueta adicional?","Qtd etiqueta adicional?","Qtd etiqueta adicional?","MV_CH3","N",3,0,0,"G",'',"MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 04
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o numero da etiqueta")
	aAdd(aHelpPor, "para ser impressa. Caso queira")
	aAdd(aHelpPor, "todas, deixar em branco")
	U_FATUSX1("REST002","04","Num.Etiqueta ?","Num.Etiqueta ?","Num.Etiqueta ?","MV_CH4","C",10,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","ZZ","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 05
	aHelpPor := {}
	aAdd(aHelpPor, "Informe a SOBRA de produ��o")
	aAdd(aHelpPor, "para ser impressa. Essa op��o")
	aAdd(aHelpPor, "serve apenas na empresa EURO.")
	U_FATUSX1("REST002","05","Qtd. Sobra","Qtd. Sobra","Qtd. Sobra","MV_CH5","N",12,3,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","ZZ","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 06
	aHelpPor := {}
	aAdd(aHelpPor, "Imprimir Data Fabica��o e Data de Validade Pelo Parametro de Tela ?")
	U_FATUSX1("REST002","06","Imp Dt Fab./Valid.?","Imp Dt Fab./Valid.?","Imp Dt Fab./Valid.?","MV_CH6","N",1,0,0,"C",'',"MV_PAR06","Sim","Sim","Sim","","N�o","N�o","N�o","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)
	
	//Pergunta 07
	aHelpPor := {}
	aAdd(aHelpPor, "Informe a Data de Fabrica��o")
	aAdd(aHelpPor, "das etiquetas")
	U_FATUSX1("REST002","07","Inf. Data Fabrica��o ?","Inf. Data Fabrica��o ?","Inf. Data Fabrica��o ?","MV_CH7","D",8,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 08
	aHelpPor := {}
	aAdd(aHelpPor, "Informe a Data de Validade")
	aAdd(aHelpPor, "das etiquetas")
	U_FATUSX1("REST002","08","Inf. Data Validade ?","Inf. Data Validade ?","Inf. Data Validade ?","MV_CH8","D",8,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	DbSelectArea(cAlias)
	Return
/*/{Protheus.doc} VldGrvCV8
description
@type function
@version 1.0
@author Paulo Lenzi
@since 8/25/2023
@return variant, return_description
/*/
User Function RESTVLD()
	Local cArea  := FwGetArea()
	Local lRet 	 := ' '
	Local cLote  := PARAMIXB
	Local cAlias := GetNextAlias()
	Local cProc  := "REST002"
	Local cData  := Dtos(dDataBase)

    BeginSql Alias cAlias	
        SELECT * 
		FROM %table:CV8% CV8
        WHERE CV8_FILIAL = %xFilial:CV8%
        AND CV8_PROC = %Exp:cProc%
        AND CV8_DATA = %Exp:cData%
        AND CV8.%NotDel%
    EndSql

     If (cAlias)->(!EOF())
          While (cAlias)->(!EOF())
		      IF cLote $ (cAlias)->CV8_MSG
                 lRet:= "Lote Ja Impresso : "+IIF(VALTYPE(cLote)="C",ALLTRIM(cLote),strzero(cLote,10))+" Data "+DTOC(StoD((cAlias)->CV8_DATA))+" Hora: "+(cAlias)->CV8_HORA+" Usuario: "+(cAlias)->CV8_USER+""+CRLF
			  Endif 
              (cAlias)->(dbSkip() )
          End
	 Endif
	  (cAlias)->(DbCloseArea())
	FwRestArea(cArea)

Return(lRet)
