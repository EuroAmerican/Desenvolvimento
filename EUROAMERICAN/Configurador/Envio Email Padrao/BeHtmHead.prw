#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BeHtmHeadบAutor  ณ Rodrigo Sousa 	 บ Data ณ  29/07/14  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cabe็alho do HTML                                          บฑฑ
ฑฑบ          ณ Parโmetros:                                                บฑฑ
ฑฑบ          ณ cTitulo 	-> Tํtulo do Html informado ao lado da imagem     บฑฑ
ฑฑบ          ณ 															  บฑฑ
ฑฑบ          ณ lImagem	-> Informa se irแ inserir Logotipo                บฑฑ
ฑฑบ          ณ 															  บฑฑ
ฑฑบ          ณ aHeadID	-> Array do Cabe็alho de Identifica็ใo do Email   บฑฑ
ฑฑบ          ณ 			 	1 - Texo que irแ na coluna desejada;		  บฑฑ
ฑฑบ          ณ 				2 - Define cor de fundo para a coluna 		  บฑฑ
ฑฑบ          ณ 					"1" Branco, "2" Cinza e "3" Azul Escuro;  บฑฑ
ฑฑบ          ณ 				3 - Atributo Width para o tamanho da coluna naบฑฑ 
ฑฑบ          ณ 					tabela;									  บฑฑ
ฑฑบ          ณ 				4 - Atributo ColSpan para espa็amentos em 	  บฑฑ
ฑฑบ          ณ 					mais de uma coluna na tabela;			  บฑฑ
ฑฑบ          ณ 				5 - Atributo Align para o alinhamento do 	  บฑฑ
ฑฑบ          ณ 					texto na coluna da tabela;				  บฑฑ
ฑฑบ          ณ 				6 - Atributo Class para propriedade da coluna บฑฑ 
ฑฑบ          ณ 					"N" number, "D" date e 					  บฑฑ
ฑฑบ          ณ 					"C" currency-format						  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ aCabCols	-> Array de Cabe็alho das Colunas do Email		  บฑฑ
ฑฑบ          ณ 				1 - Texto que irแ no cabe็alho da coluna da   บฑฑ
ฑฑบ          ณ					tabela;                                   บฑฑ
ฑฑบ          ณ             	2 - Atributo Width para o tamanho da coluna naบฑฑ
ฑฑบ          ณ     				a tabela;								  บฑฑ
ฑฑบ          ณ             	3 - Atributo Align para o alinhamento do 	  บฑฑ
ฑฑบ          ณ              	texto na coluna da tabela.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ       	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function BeHtmHead(cTitulo,lImagem,aHeadID,aCabCols)

Local cClass    := ""
Local cRet      := ""
Local cWidth     := ""
Local cCorFundo := ""
Local cEspandi  := ""
Local nLin      := 0
Local nCol      := 0

Default aHeadID := {}

cRet := '<html>' + CRLF

aCabCols := U_BeAjTamCol( aCabCols )

// Apresenta imagem e tํtulo no inicio do HTML...
If lImagem
	cRet += '<table style="text-align: left; width: 100%; height: 10%;" border="0" cellpadding="0" cellspacing="0">'
	cRet += '  <tbody>'
	cRet += '    <tr>'

	If !Empty( cTitulo )
		cRet += '      <td style="text-align: center; width: 701px;"><big><big><span style="font-weight: bold;">' + cTitulo + '</span></big></big></td>'
	EndIf

	If Left(cFilAnt,2) == "02"
		cRet += '      <td style="text-align: center; width: 239px;" bgcolor="#010305"><img style="width: 259px; height: 87px;" alt="" src="http://euroamerican.com.br/images/logo_euroamerican_antigo.png" width=200></td>'
	Else
		cRet += '      <td style="text-align: center; width: 239px;" bgcolor="#010305"><img style="width: 259px; height: 87px;" alt="" src="http://qualyvinil.com.br/assets/images/nav/logo_qv1.png" width=200></td>'
	EndIf
	cRet += '    </tr>'
	cRet += '  </tbody>'
	cRet += '</table>'
	cRet += '<HR>'
EndIf

If Len(aHeadID) > 0
	cRet += '<table border="1" width="100%" align="center">'

	For nLin := 1 To Len(aHeadID)
		cRet += '<tr>'
			For nCol := 1 To Len(aHeadID[nLin])
				If aHeadID[nLin][nCol][2] == "1"
					cCorFundo := ""
				ElseIf aHeadID[nLin][nCol][2] == "2"
					cCorFundo := " bgcolor='#F3F3F3'"
				Else
					cCorFundo := " bgcolor='#336699'"
				EndIf

				//Expandir colunas horizontalmente na linha...
				If aHeadID[nLin][nCol][4] > 0
					cEspandi := ' colspan="' + AllTrim(Str(aHeadID[nLin][nCol][4])) + '"'
				Else
					cEspandi := ' '
				EndIf

				//Largura de colunas linha...
				If aHeadID[nLin][nCol][3] > 0
					cWidth := ' width="' + AllTrim(Str(aHeadID[nLin][nCol][3])) + '%"'
				Else
					cWidth := ' '
				EndIf

				If Len( aHeadID[nLin][nCol] ) > 5
					If AllTrim( aHeadID[nLin][nCol][6] ) == "N"
						cClass := ' class="num"'
					ElseIf AllTrim( aHeadID[nLin][nCol][6] ) == "D"
						cClass := ' class="date"'
					ElseIf AllTrim( aHeadID[nLin][nCol][6] ) == "C"
						cClass := ' class="currency-format"'
					Else
						cClass := 'style=mso-number-format:"\@"'
					EndIf
				Else
					cClass := 'style=mso-number-format:"\@"'
				EndIf

				cRet += "    <td" + cEspandi + cWidth + cClass + " align='" + IIf( aHeadID[nLin][nCol][5] == "C", "center", IIf( aHeadID[nLin][nCol][5] == "L", "left", "right")) + "' VALIGN='MIDDLE'" + cCorFundo + ">"
				cRet += "      <font face='Courier New' size='2' color=WHITE>" + aHeadID[nLin][nCol][1] + "</font>"
				cRet += "    </td>"
			Next
		cRet += '</tr>'
	Next

	cRet += '</table>'
	cRet += '<Hr>'
EndIf

If Len( aCabCols ) > 0
	//Cabe็alho da tabela
	cRet += '<table border="1" width="100%" align="center">'

	cRet += '<tr>'
	For nLin := 1 To Len( aCabCols )
		//Largura de colunas linha...
		If aCabCols[nLin][2] > 0
			cWidth := ' width="' + AllTrim(Str(aCabCols[nLin][2])) + '%"'
		Else
			cWidth := ' '
		EndIf

		cRet += "    <td " + cWidth + " align='" + IIf( aCabCols[nLin][3] == "C", "center", IIf( aCabCols[nLin][3] == "L", "left", "right")) + "' VALIGN='MIDDLE' bgcolor='#336699'>"
		cRet += "      <font face='Courier New' size='2' color=WHITE><b>" + aCabCols[nLin][1] + "</b></font>"
		cRet += "    </td>"
	Next
	cRet += '</tr>' + CRLF
Else
	//Cabe็alho da tabela
	cRet += '<table border="0" width="100%" align="center">'
EndIf

Return cRet

