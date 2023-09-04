#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

/* 
{Protheus.doc} AprovPC
Disparo e-mail após a classificação
@Author     Fabio Batista
@Since      22/06/2020
@Version    P12.25
@Project    EURO
@Param		 
@Param		 
@Param		 
*/

User Function COMPSTATUS()

    Local aArea             := GetArea()
    Local cDescrFase        := 'Documento de Entrada Faturado'
    Local cHtml             := ''
    Local cAssunto          := 'Documento de Entrada Faturado'
    Local cAttach           := ''
    Local cBody             := ''
    Local cNomeComp         := ''
    Private aTots          := {}

    cHtml := '<html>' + CRLF
    cHtml += '	<head>' + CRLF
    cHtml += '		<meta http-equiv="content-type" content="text/html;charset=utf-8">' + CRLF
    cHtml += '		<style>' + CRLF
    cHtml += '			table 	{' + CRLF
    cHtml += '					border-collapse: collapse;' + CRLF
    cHtml += '					border: 1px solid black;' + CRLF
    cHtml += '					}' + CRLF
    cHtml += '		</style>' + CRLF
    cHtml += '	</head>' + CRLF
    cHtml += '	<body>' + CRLF
    cHtml += '		<table style="text-align: left; width: 100%; height: 10%; border:none;" border="0" cellpadding="0" cellspacing="0">' + CRLF
    cHtml += '				<tr>'	 + CRLF			
    cHtml += '				</tr>' + CRLF
    cHtml += '		</table>' + CRLF
    cHtml += '		<table border="1" width="100%" align="center">' + CRLF
    cHtml += '			<tr>' + CRLF
    cHtml += '				<td colspan="6" width="100%"style=mso-number-format:"\@" align="center" VALIGN="MIDDLE" bgcolor="#336699">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><B><Font Size=4 color=white>'+cDescrFase+'</Font></B></font>' + CRLF
    cHtml += '				</td>' + CRLF
    cHtml += '			</tr>' + CRLF
    cHtml += '			<tr>' + CRLF
    cHtml += '				<td  width="10%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE" bgcolor="#F3F3F3">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><B><Font Size=2 color=black>Filial</Font></B></font>'   + CRLF  
    cHtml += '				</td>' + CRLF
    cHtml += '				<td colspan="2" width="40%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><Font Size=2 color=black>'+SM0->M0_CODIGO+'/'+SM0->M0_CODFIL+' - '+SM0->M0_FILIAL+'</Font></font>' + CRLF
    cHtml += '				</td>' + CRLF
    cHtml += '				<td  width="10%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE" bgcolor="#F3F3F3">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><B><Font Size=2 color=black>Emissao</Font></B></font>'     + CRLF
    cHtml += '				</td>' + CRLF
    cHtml += '				<td colspan="2" width="40%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><Font Size=2 color=black>'+DTOC(SC7->C7_EMISSAO)+'</Font></font>'  + CRLF   
    cHtml += '				</td>' + CRLF
    cHtml += '			</tr>' + CRLF
    cHtml += '			<tr>' + CRLF
    cHtml += '				<td  width="10%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE" bgcolor="#F3F3F3">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><B><Font Size=2 color=black>Numero Pedido</Font></B></font>'   + CRLF  
    cHtml += '				</td>' + CRLF
    cHtml += '				<td colspan="2" width="40%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><Font Size=2 color=black>'+SC7->C7_NUM+'</Font></font>'  + CRLF   
    cHtml += '				</td>' + CRLF
    cHtml += '				<td  width="10%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE" bgcolor="#F3F3F3">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><B><Font Size=2 color=black>Comprador</Font></B></font>' + CRLF
    cHtml += '				</td>' + CRLF
    cNomeComp := UsrFullName(SC7->C7_USER)
    cHtml += '				<td colspan="2" width="40%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><Font Size=2 color=black>'+cNomeComp+'</Font></font>'    + CRLF 
    cHtml += '				</td>' + CRLF
    cHtml += '			</tr>' + CRLF
    cHtml += '			<tr> '   + CRLF
    cHtml += '				<td  width="10%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE" bgcolor="#F3F3F3">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><B><Font Size=2 color=black>Fornecedor/Loja</Font></B></font>' + CRLF
    cHtml += '				</td>' + CRLF
    cHtml += '				<td colspan="2" width="40%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><Font Size=2 color=black>'+SC7->C7_FORNECE+'/'+SC7->C7_LOJA+'</Font></font>' + CRLF
    cHtml += '				</td>' + CRLF
    cHtml += '				<td  width="10%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE" bgcolor="#F3F3F3">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><B><Font Size=2 color=black>Nome Forn.</Font></B></font> '    + CRLF
    cHtml += '				</td>    ' + CRLF
    cHtml += '				<td colspan="2" width="40%"style=mso-number-format:"\@" align="left" VALIGN="MIDDLE">      ' + CRLF
    cNomeFor := Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,'A2_NREDUZ')
    cHtml += '					<font face="Courier New" size="2" color=WHITE><Font Size=2 color=black>'+cNomeFor+'</Font></font> '    + CRLF
    cHtml += '				</td>' + CRLF
    cHtml += '			</tr>' + CRLF
    cHtml += '		</table><br>' + CRLF
    cHtml += '		<table style="border:none;" border="0" width="100%" align="center" >' + CRLF
    cHtml += '			<tr>    ' + CRLF
    cHtml += '				<td colspan="6" width="100%"style=mso-number-format:"\@"  align="center" VALIGN="MIDDLE" bgcolor="#336699">' + CRLF
    cHtml += '					<font face="Courier New" size="2" color=WHITE><B><Font Size=4 color=white>Processo</Font></B></font>    ' + CRLF
    cHtml += '				</td>' + CRLF
    cHtml += '			</tr>' + CRLF
    cHtml += '			<tr>    <br>' + CRLF

    SomaValor(aTots)
    cHtml += '             <td  width="10%" align="center" VALIGN="MIDDLE"> ' + CRLF
	cHtml += '             				<font face="Courier New" size="2" color="#000000"><b>Valor</b></font><br> ' + CRLF
	cHtml += '             				<font face="Courier New" size="2" color="#000000"><b>Pedido Compra</b></font><br> ' + CRLF
	cHtml += '             				<font face="Courier New" size="5" color="#000000"><b>1950</b></font> ' + CRLF
	cHtml += '             			</td> ' + CRLF
	cHtml += '             			<td  width="10%" align="center" VALIGN="MIDDLE"> ' + CRLF
	cHtml += '             				<font face="Courier New" size="2" color="#000000"><b>Valor</b></font><br> ' + CRLF
	cHtml += '             				<font face="Courier New" size="2" color="#000000"><b>Documento de Entrada</b></font><br> ' + CRLF    
    cHtml += '             				<font face="Courier New" size="5" color="#000000"><b>1830</b></font> ' + CRLF    
	cHtml += '             			</td> ' + CRLF
	cHtml += '             			<td  width="10%" align="center" VALIGN="MIDDLE"> ' + CRLF
	cHtml += '             				<font face="Courier New" size="2" color="#000000"><b>Percentual</b></font><br> ' + CRLF
	cHtml += '             				<font face="Courier New" size="2" color="#000000"><b>Pedido x Doc.Ent</b></font> <br>' + CRLF
    cHtml += '             				<font face="Courier New" size="5" color="#000000"><b>97%</b></font> ' + CRLF
	cHtml += '             			</td> ' + CRLF
	cHtml += '             		</tr> ' + CRLF
	cHtml += '             	</table><br> ' + CRLF
	cHtml += '             </body> ' + CRLF
    cHtml += '             </html> ' + CRLF

    cBody := cHtml

RestArea( aArea )
Return

/*
{Protheus.doc} AprovPC
Pega o percentual de aprovação do PC
@Author     Fabio Batista
@Since      22/06/2020
@Version    P12.25
@Project    EURO
@Param		 
@Param		 
@Param		 
*/
Static Function SomaValor(aTots)

    Local cCod    := ''
    Local cQuery  := ""
    Local TRB     := GetNextAlias()


    cQuery := " SELECT SUM(C7_TOTAL) C7_TOTAL, SUM(D1_TOTAL) D1_TOTAL, SUM(D1_TOTAL)/SUM(C7_TOTAL) *100 AS PORC  " + CRLF
    cQuery += " FROM "+RetSqlName("SC7")+" SC7" + CRLF
    cQuery += " INNER JOIN "+RetSqlName("SD1")+" SD1 ON C7_FILIAL = D1_FILIAL AND C7_NUM = D1_PEDIDO AND C7_ITEM = D1_ITEMPC   " + CRLF
    cQuery += " WHERE SC7.D_E_L_E_T_='' AND C7_NUM  = '"+SD1->D1_PEDIDO+"' " + CRLF
    cQuery += " AND SD1.D_E_L_E_T_=''  " + CRLF

   MsAguarde({|| dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery), TRB,.F.,.T.)}, "Selecionando Registros ...")


    If (TRB)->(EOF())
        ConOut("Não há resultado na query principal do Analistas (SC7)")
        Return
    EndIf

    While (TRB)->(!EOF())
       aAdd(aTots,(TRB)->C7_TOTAL,(TRB)->D1_TOTAL,(TRB)->PORC)
       (TRB)->(DBSKIP())    
    EndDo

Return