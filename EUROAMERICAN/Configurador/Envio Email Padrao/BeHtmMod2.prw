#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BeHtmMod2ºAutor  ³ Fabio F Sousa       º Data ³  04/07/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cabeçalho do HTML                                          º±±
±±º          ³ Parâmetros:                                                º±±
±±º          ³     _cTitulo                                               º±±
±±º          ³     _aColuna                                               º±±
±±º          ³     _lImagem                                               º±±
±±º          ³     _aTitulos                                              º±±
±±º          ³     _cImg2                                                 º±±
±±º          ³     _nWidth                                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Grupo Sabara                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
Cabeçalho do HTML - Específico para tratamentos de e-commerce da BASF
Parâmetros da Função:
_cTitulo  -> Título do Html informado ao lado da imagem
_aColuna  -> Cabeçalho da tabela HTML
			{ 1 - Texto que irá no cabeçalho da coluna da tabela;
			  2 - Atributo Width para o tamanho da coluna na tabela;
			  3 - Atributo Align para o alinhamento do texto na coluna da tabela}
_lImagem  -> Conteúdo verdadeiro para exibir a imagem do logotipo da TN
_aTitulos -> Gera tabela com linhas e colunas antes do cabeçalho da tabela de detalhes
			{ 1 - Texo que irá na coluna desejada;
			  2 - Define cor de fundo para a coluna até 5 opções de cores;
			  3 - Atributo Width para o tamanho da coluna na tabela;
			  4 - Atributo ColSpan para espaçamentos em mais de uma coluna na tabela;
			  5 - Atributo Align para o alinhamento do texto na coluna da tabela;
_cImg2    -> Instrução para buscar logotipo publicado na internet centralizado a direta do logotipo TN
_nWidth   -> tamanho da tabela na frame do HTML
*/
User Function BeHtmMod2( _cTitulo, _aColuna, lImagem, _aTitulos, _cImg2, _nWidth )

Local cRet      := ""
Local cWith     := ""
Local cCorFundo := ""
Local cEspandi  := ""
Local nLin      := 0
Local nCol      := 0

Default _aTitulos := {}

cRet := '<html>' + CRLF

_aColuna := U_BeAjTamCol( _aColuna )

// Apresenta imagem e título no inicio do HTML...
If lImagem
	cRet += '<table border="0" width="' + AllTrim(Str(_nWidth)) + '%" align="center">'
	cRet += '  <tbody>'
	cRet += '    <tr>'
	If !Empty( _cTitulo )
		cRet += '      <td style="text-align: center; width: 701px;"><big><big><span style="font-weight: bold;">' + _cTitulo + '</span></big></big></td>'
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

If Len(_aTitulos) > 0
	cRet += '<table border="0" width="' + AllTrim(Str(_nWidth)) + '%" align="center">'

	For nLin := 1 To Len(_aTitulos)
		cRet += '<tr>'
			For nCol := 1 To Len(_aTitulos[nLin])
				If _aTitulos[nLin][nCol][2] == "1"
					cCorFundo := ""
				ElseIf _aTitulos[nLin][nCol][2] == "2"
					cCorFundo := " bgcolor='#F3F3F3'"
				ElseIf _aTitulos[nLin][nCol][2] == "3"
					cCorFundo := " bgcolor='#F6FBF6'"
				ElseIf _aTitulos[nLin][nCol][2] == "4"
					cCorFundo := " bgcolor='#FFFFCC'"
				Else
					cCorFundo := " bgcolor='#336699'"
				EndIf

				//Expandir colunas horizontalmente na linha...
				If _aTitulos[nLin][nCol][4] > 0
					cEspandi := ' colspan="' + AllTrim(Str(_aTitulos[nLin][nCol][4])) + '"'
				Else
					cEspandi := ' '
				EndIf

				//Largura de colunas linha...
				If _aTitulos[nLin][nCol][3] > 0
					cWith := ' width="' + AllTrim(Str(_aTitulos[nLin][nCol][3])) + '%"'
				Else
					cWith := ' '
				EndIf

				cRet += "    <td" + cEspandi + cWith + " align='" + IIf( _aTitulos[nLin][nCol][5] == "C", "center", IIf( _aTitulos[nLin][nCol][5] == "L", "left", "right")) + "' VALIGN='MIDDLE'" + cCorFundo + ">"
				cRet += "      <font face='Courier New' size='2'>" + _aTitulos[nLin][nCol][1] + "</font>"
				cRet += "    </td>"
			Next
		cRet += '</tr>'
	Next

	cRet += '</table>'
EndIf

If Len( _aColuna ) > 0
	//Cabeçalho da tabela
	cRet += '<table border="0" width="' + AllTrim(Str(_nWidth)) + '%" align="center">'

	cRet += '<tr>'
	For nLin := 1 To Len( _aColuna )
		//Largura de colunas linha...
		If _aColuna[nLin][2] > 0
			cWith := ' width="' + AllTrim(Str(_aColuna[nLin][2])) + '%"'
		Else
			cWith := ' '
		EndIf

		cRet += "    <td " + cWith + " align='" + IIf( _aColuna[nLin][3] == "C", "center", IIf( _aColuna[nLin][3] == "L", "left", "right")) + "' valign='middle' bgcolor='#336699'>"
		cRet += "      <font face='Courier New' size='2' color=WHITE><b>" + _aColuna[nLin][1] + "</b></font>"
		cRet += "    </td>"
	Next
	cRet += '</tr>' + CRLF
Else
	//Cabeçalho da tabela
	cRet += '<table border="0" width="100%" align="center">'
EndIf

Return cRet