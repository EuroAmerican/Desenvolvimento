#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} mt010inc
//PE utilizado para gerar o EAN 13 na inclusao do produto
@author mjlozzardo
@since 07/02/2018
@version 1.0
@type function
@History: 23/02/2022 - Alterado para envio de e-mail projeto comiss�o. 
          12/01/2023 - Altera��o para alertar a digita��o de Lote e Endere�o
                       quando o tipo do produto for PA. Solicitado pelo Sr. 
					   Alex Blasques (Produ��o) em 12/01/23. 
					   [Analista Paulo Rog�rio].

/*/
User Function mt010inc()

Local cAlias      := Alias()
Local aAreaB1     := SB1->(GetArea())
Local cTipo       := SuperGetMV("ES_MTA010A", .T., "PA|PV")
Local cSeq        := ""
Local cEan        := ""
Local nRegB1      := SB1->(RecNo())
// Variaveis Projeto comiss�es 
Local cNomeUsr    := UsrRetName(RetCodUsr())
Local _cDest      := ""
Private PulaLinha := chr(13)+chr(10)
Private _cTexto   := '<html>' + PulaLinha
Private _nValor   := 0
Private _cFonte   := 'font-size:10; fonte-family:Arial;'

//Sequ�ncia contratada Qualyvinil 789825824 + 3 d�gitos + 1 d�gito verificador

If SB1->B1_TIPO $ cTipo .and. Empty(SB1->B1_CODBAR) .and. !Empty(SB1->B1_GRUPO)
	SZ2->(DbSetOrder(2))
	SZ2->(DbSeek(xFilial("SZ2") + SB1->B1_GRUPO, .T.))
	If SB1->B1_GRUPO >= SZ2->Z2_GRPDE .and. SB1->B1_GRUPO <= SZ2->Z2_GRPATE
		cSeq := Soma1(SZ2->Z2_SEQ)
		SB1->(DbSetOrder(5))
		While .T.
			cEan := (SZ2->Z2_MATRIZ + cSeq) + Rtrim(EanDigito(SZ2->Z2_MATRIZ + cSeq))
			If SB1->(DbSeek(xFilial("SB1") + cEan, .F.))
				cSeq := Soma1(cSeq)
				Loop
			Else
				SZ2->(RecLock("SZ2", .F.))
				SZ2->Z2_SEQ := cSeq
				SZ2->(MsUnLock())

				SB1->(DbGoTo(nRegB1))
				SB1->(RecLock("SB1", .F.))
				SB1->B1_CODBAR := cEan
				SB1->(MsUnLock())
				Exit
			EndIf
		EndDo
	Else
		MsgAlert("Aten��o", "N�o foi localizada a configura��o EAN, favor informar o TI.")
	EndIf

EndIf

/*
+-------------------------------------------------------------------------------+
| Obriga��o dos Campos de Lote e Endere�o para PA - 01/12/2023 - Paulo Rog�rio  |
+-------------------------------------------------------------------------------+
*/
IF SB1->B1_TIPO == "PA" .and. (SB1->B1_RASTRO <> "L" .OR. SB1->B1_LOCALIZ <> "S")
	IF MsgYesNo("Produtos Acabados precisam ter Controles de Lote e Endere�o!!! Deseja ativar esses controles agora?", "ATEN��O - MT010INC") 
		SB1->B1_RASTRO :=  "L" 
		SB1->B1_LOCALIZ:=  "S"

		MsgInfo("Controles ativados com sucesso!","MT010INC")
	Endif
Endif


/*
+------------------------------------------------------------------+
| Projeto Comiss�o especifico QUALY - 23/02/2022 - Fabio Carneiro  |
+------------------------------------------------------------------+
*/
If SB1->B1_TIPO == "PA"

	If SB1->B1_COMIS == 0
		SB1->(DbGoTo(nRegB1))
		SB1->(RecLock("SB1", .F.))
		SB1->B1_COMIS := 0
		SB1->(MsUnLock())
	EndIf

	_cTexto += '<b><font size="3" face="Arial">O Produto abaixo foi inclu�do pelo Usu�rio: '+AllTrim(cNomeUsr)+'</font></b><br><br>'
	_cTexto += '<b><font size="2" face="Arial">C�digo: '+SB1->B1_COD+'</b><br>'
	_cTexto += '<b><font size="2" face="Arial">Descri��o: '+SB1->B1_DESC+'</b><br>'
	_cTexto += '<b><font size="2" face="Arial">Aliq. IPI: '+Transform(SB1->B1_IPI,"@E 999,999,999.99")+'</b><br>'
	_cTexto += '<b><font size="2" face="Arial">Aliq. ICMS: '+Transform(SB1->B1_PICM,"@E 999,999,999.99")+'</b><br>'
	_cTexto += '<b><font size="2" face="Arial">Posi��o IPI: '+SB1->B1_POSIPI+'</b><br>'  
	_cTexto += '<b><font size="2" face="Arial">Origem: '+SB1->B1_ORIGEM+'</b><br>'
	_cTexto += '<b><font size="2" face="Arial">% Comiss�o: '+Transform(SB1->B1_COMIS,"@E 999,999,999.99")+'</b><br><br>'
	_cTexto += '<b><font size="2" face="Arial">Unidade Expedi��o: '+SB1->B1_XUNEXP+'</b><br>'
	_cTexto += '<b><font size="2" face="Arial">Quant. Embalagem: '+Alltrim(Transform(SB1->B1_XQTDEXP,PesqPict("SB1","B1_XQTDEXP")))+'</b><br><br>'
	_cTexto += '<b><font size="2" face="Arial" Color="Red">Observa��o: Este produto deve ser incluido na tabela de vig�ncia de comiss�o e revisado a unidade de expedi��o, para gravar o campo de comiss�o no cadastro de produto.</font></b><br>'
	_cTexto += '<br><br><b><font size="3" face="Arial" color="Blue">'+AllTrim(SM0->M0_NOME)+' - '+AllTrim(SM0->M0_FILIAL)+'</font></b><br>'
	_cTexto += '</html>'

	// Ajuste para Tratar a Unidade de Expedi��o em 10/04/2022 - Fabio Carneiro 	
	If cFilAnt == "0803" 
		_cDest := GetMV("QE_RECPROD")
	Else 
		_cDest := GetMV("QE_RECEXP")
	EndIf

	If !Empty(_cDest).And.Len(_cTexto)>30
		U_CPEmail(_cDest,"","Novo Produto Cadastrado - BASE DE PRODU��O: "+SB1->B1_COD,_cTexto,"",.T.)
	EndIf
		
EndIf

DbSelectArea(cAlias)
RestArea(aAreaB1)
Return
