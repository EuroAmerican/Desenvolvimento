#INCLUDE "xMATR540.CH"
#INCLUDE "PROTHEUS.CH"

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR540  � Autor � Marco Bianchi            � Data � 23/05/06 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Comissoes.                                       ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   � MATR540(void)                                                 ���
����������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                      ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
User Function MTR54x()

Private MV_PAR04 := RetCodUsr()
Private MV_PAR05 := RetCodUsr()
Private MV_PAR15 := 3
Private cCodUsr  := ''


	DBSELECTAREA("SA3")
	SA3->(DBSETORDER(7))
	SA3->(DBGOTOP())

	If SA3->(dbSeek(xFILIAL("SA3")+MV_PAR04))
		cCodUsr := SA3->A3_COD
	Else
		MSGINFO("A T E N � � O" + CRLF + CRLF + "Entrar em contato com o departamento comercial para informar no (seu cadastro de vendedor) o codigo do usu�rio." + CRLF + CRLF + "Codigo do usu�rio: (" + MV_PAR05 + ")")
		Return
	EndIf

	If !Empty(cCodUsr)
		MV_PAR04 := cCodUsr
		MV_PAR05 := cCodUsr
	EndIf
SA3->(DBCLOSEAREA())

//pegando o codigo do vendedor e escrevendo no grupo de perguntas
DBSELECTAREA("SX1")
SX1->(DBGOTOP())
SX1->(DBSETORDER(1))

If SX1->(dbSeek(PadR("XMTR540",10)+"04"))
	Reclock("SX1",.F.)
	SX1->X1_CNT01 := MV_PAR04
EndIf

If SX1->(dbSeek(PadR("XMTR540",10)+"05"))
	Reclock("SX1",.F.)
	SX1->X1_CNT01 := MV_PAR05
EndIf

If SX1->(dbSeek(PadR("XMTR540",10)+"15"))
	Reclock("SX1",.F.)
	SX1->X1_CNT01 := '3' 
EndIf

SX1->(DBCLOSEAREA())


YMATR540()

static Function yMatr540()

Local oReport	  := Nil
//-- Interface de impressao
oReport := ReportDef() 
oReport:PrintDialog()  

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Marco Bianchi         � Data �23/05/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local oReport
Local oComissaoA
Local oComissaoS
Local oDetalhe
Local oTotal,oGeral
Local cVend  		:= ""
Local dVencto   	:= CTOD( "" ) 
Local dBaixa    	:= CTOD( "" ) 
Local nVlrTitulo	:= 0
Local nBasePrt  	:= 0
Local nComPrt   	:= 0
Local cTipo     	:= ""
Local cLiquid 		:= ""
Local aValLiq   	:= {}
Local nI2       	:= 0
Local aLiqProp  	:= {}
Local nValIR    	:= 0
Local nTotSemIR 	:= 0
Local nAc1			:= 0
Local nAc2			:= 0
Local nAc3      	:= 0
Local nDecPorc		:= TamSX3("E3_PORC")[2]
Local nTamData  	:= Len(DTOC(MsDate()))
Local lRndIrrf		:= GetMV("MV_RNDIRF")
Local cAlias		:= GetNextAlias()

MV_PAR14 := 1


//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport := TReport():New("xMATR540",STR0025,"XMTR540", {|oReport| ReportPrint(oReport,cAlias,oComissaoA,oComissaoS,oDetalhe,oTotal,oGeral)},STR0026)
oReport:SetLandscape() 
oReport:SetTotalInLine(.F.)

Pergunte("XMTR540",.F.)
//mv_par04 := '000002'
//mv_par05 := '000002'
//Pergunte("XMTR540",.T.)
//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�                                                                        �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
oComissaoA := TRSection():New(oReport,STR0050,{"SE3","SA3"},{STR0046,STR0047},/*Campos do SX3*/,/*Campos do SIX*/)
oComissaoA:SetTotalInLine(.F.)

//������������������������������������������������������������������������Ŀ
//� Analitico                                                              �
//��������������������������������������������������������������������������
TRCell():New(oComissaoA,"E3_VEND" ,"SE3",/*Titulo*/,/*Picture*/                ,/*Tamanho*/         ,/*lPixel*/  ,{|| cVend })
TRCell():New(oComissaoA,"A3_NOME" ,"SA3",/*Titulo*/,/*Picture*/                ,/*Tamanho*/         ,/*lPixel*/  ,{|| SA3->A3_NOME })

// Titulos da Comissao
oDetalhe := TRSection():New(oComissaoA,STR0048,{"SE3","SA3","SA1"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oDetalhe:SetTotalInLine(.F.)
oDetalhe:SetHeaderBreak(.T.)
TRCell():New(oDetalhe,"E3_PREFIXO" 	,cAlias,/*Titulo*/,/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"E3_NUM"		,cAlias,/*Titulo*/,/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,{|| E3_NUM })
TRCell():New(oDetalhe,"E3_PARCELA" 	,cAlias,/*Titulo*/,/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"E3_CODCLI"	,cAlias,/*Titulo*/,/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"NOMCLI"      ,"   " ,Iif(MV_PAR14 == 1,RetTitle("A1_NREDUZ"),RetTitle("A1_NOME")),/*Picture*/               ,30			,/*lPixel*/,{|| Substr(Iif(MV_PAR14 == 1,SA1->A1_NREDUZ,SA1->A1_NOME),1,30) })
TRCell():New(oDetalhe,"E3_EMISSAO"	,cAlias,/*Titulo*/,/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"DVENCTO"		,"    ",STR0033   ,/*Picture*/               ,nTamData  ,/*lPixel*/,{|| dVencto })
TRCell():New(oDetalhe,"DBAIXA"		,"    ",STR0034   ,/*Picture*/               ,nTamData  ,/*lPixel*/,{|| dBaixa })
TRCell():New(oDetalhe,"E3_DATA"		,cAlias,/*Titulo*/,/*Picture*/               ,nTamData  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"E3_PEDIDO"	,cAlias,STR0039   ,/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"NVLRTITULO"	,"    ",STR0035,PesqPict('SE3','E3_BASE')	 ,TamSx3("E3_BASE"	)[1],/*lPixel*/,{|| 5,5 }) //nVlrTitulo })
TRCell():New(oDetalhe,"NBASEPRT"	,"    ",STR0036,PesqPict('SE3','E3_BASE')	 ,TamSx3("E3_BASE"	)[1],/*lPixel*/,{|| nBasePrt })
TRCell():New(oDetalhe,"E3_PORC"		,cAlias,STR0032,PesqPict('SE3','E3_PORC')	 ,TamSx3("E3_PORC"  )[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"NCOMPRT"		,"    ",STR0038,PesqPict('SE3','E3_COMIS')   ,TamSx3("E3_COMIS" )[1],/*lPixel*/,{|| nComPrt })
TRCell():New(oDetalhe,"E3_BAIEMI"	,cAlias,STR0040,/*Picture*/                  ,/*Tamanho*/  ,/*lPixel*/,{|| Substr(cTipo,1,1) })
TRCell():New(oDetalhe,"AJUSTE"		,"    ",STR0037,/*Picture*/                  ,/*Tamanho*/  ,/*lPixel*/,{|| ""})

// Titulos de Liquidacao
oLiquida := TRSection():New(oDetalhe,STR0051,{"SE1","SA1"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oLiquida:SetTotalInLine(.F.)
TRCell():New(oLiquida,"E1_NUMLIQ" 	,"   ",/*Titulo*/ ,/*Picture*/                ,/*Tamanho*/  		,/*lPixel*/,{|| cLiquid })
TRCell():New(oLiquida,"E1_PREFIXO"	,"SE1",/*Titulo*/ ,/*Picture*/                ,/*Tamanho*/  		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLiquida,"E1_NUM"	    ,"SE1",/*Titulo*/ ,/*Picture*/                ,/*Tamanho*/  		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLiquida,"E1_PARCELA" 	,"SE1",/*Titulo*/ ,/*Picture*/                ,/*Tamanho*/  		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLiquida,"E1_TIPO"   	,"SE1",/*Titulo*/ ,/*Picture*/                ,/*Tamanho*/  		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLiquida,"E1_CLIENTE"	,"SE1",/*Titulo*/ ,/*Picture*/                ,/*Tamanho*/  		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLiquida,"E1_LOJA"		,"SE1",/*Titulo*/ ,/*Picture*/                ,/*Tamanho*/  		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLiquida,"NOMCLI"   	,"   ",Iif(MV_PAR14 == 1,RetTitle("A1_NREDUZ"),RetTitle("A1_NOME")),/*Picture*/               ,30			,/*lPixel*/,{|| Substr(Iif(MV_PAR14 == 1,SA1->A1_NREDUZ,SA1->A1_NOME),1,30) })
TRCell():New(oLiquida,"E1_VALOR"		,"SE1",/*Titulo*/ ,Tm(SE1->E1_VALOR,15,2)    ,/*Tamanho*/  		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLiquida,"NVALLIQ1"		,"   ",STR0043    ,/*Picture*/                ,nTamData	     		,/*lPixel*/,{|| aValLiq[nI2,1] })
TRCell():New(oLiquida,"NVALLIQ2"		,"   ",STR0044    ,Tm(SE1->E1_VALOR,15,2)    ,/*Tamanho*/  		,/*lPixel*/,{|| aValLiq[nI2,2] })
TRCell():New(oLiquida,"NLIQPROP"		,"   ",STR0045    ,Tm(SE1->E1_VALOR,15,2)    ,/*Tamanho*/  		,/*lPixel*/,{|| aLiqProp[nI2] })

//-- Secao Totalizadora do Valor do IR e Total (-) IR
oTotal := TRSection():New(oReport,"",{},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
TRCell():New(oTotal,"TOTALIR"     ,"   ",STR0028,"@E 99,999,999.99",12         ,/*lPixel*/,{|| If(lRndIrrf,Round(nValIR,TamSX3("E2_IRRF")[2]),NoRound(nValIR,TamSX3("E2_IRRF")[2])) })
TRCell():New(oTotal,"TOTSEMIR"    ,"   ",STR0029,"@E 99,999,999.99",12         ,/*lPixel*/,{|| nTotSemIR })  

//-- TOTAL GERAL
oGeral := TRSection():New(oTotal,"",{},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
TRCell():New(oGeral, "TXTTOTAL"          , "" , STR0052  , , 08 ,/*lPixel*/,{ || "" } )    
TRCell():New(oGeral, "GERAL"	         , "" , STR0053  , PesqPict('SE3','E3_COMIS')    	, TamSX3("E3_COMIS")[1]   ,/*lPixel*/,/*CodeBlock*/)
TRCell():New(oGeral, "PERCENT"	         , "" , STR0054  , PesqPict("SE3","E3_PORC" )   	, TamSX3("E3_PORC" )[1]   ,/*lPixel*/,/*CodeBlock*/)
TRCell():New(oGeral, "COMIS"		     , "" , STR0055  , PesqPict('SE3','E3_COMIS')    	, TamSX3("E3_COMIS")[1]   ,/*lPixel*/,/*CodeBlock*/)

//������������������������������������������������������������������������Ŀ
//� Sintetico                                                              �
//��������������������������������������������������������������������������
oComissaoS := TRSection():New(oReport,STR0049,{"SE3","SA3"},{STR0046,STR0047},/*Campos do SX3*/,/*Campos do SIX*/)
oComissaoS:SetTotalInLine(.F.)

TRCell():New(oComissaoS,"E3_VEND" ,"SE3",/*Titulo*/,/*Picture*/                	,/*Tamanho*/          	,/*lPixel*/	,{|| cVend })
TRCell():New(oComissaoS,"A3_NOME" ,"SA3",/*Titulo*/,/*Picture*/					,/*Tamanho*/          	,/*lPixel*/	,{|| SA3->A3_NOME })
TRCell():New(oComissaoS,"TOTALTIT",""		,STR0027   ,PesqPict('SE3','E3_BASE') 	,TamSx3("E3_BASE")[1] 	,/*lPixel*/	,{|| nAc3 })
TRCell():New(oComissaoS,"E3_BASE" ,cAlias,STR0030   ,PesqPict('SE3','E3_BASE') 	,TamSx3("E3_BASE")[1] 	,/*lPixel*/	,{|| nAc1 })
TRCell():New(oComissaoS,"E3_PORC" ,cAlias,STR0032   ,PesqPict('SE3','E3_PORC') 	,TamSx3("E3_PORC")[1] 	,/*lPixel*/	,{||NoRound((nAc2*100) / nAc1),2})
TRCell():New(oComissaoS,"E3_COMIS",cAlias,STR0031   ,PesqPict('SE3','E3_COMIS')	,TamSx3("E3_COMIS")[1]	,/*lPixel*/	,{|| nAc2 })
TRCell():New(oComissaoS,"VALIR"   ,""   	,STR0028   ,PesqPict('SE3','E3_COMIS')	,TamSx3("E3_COMIS")[1]	,/*lPixel*/	,{|| If(lRndIrrf,Round(nValIR,TamSX3("E2_IRRF")[2]),NoRound(nValIR,TamSX3("E2_IRRF")[2])) })
TRCell():New(oComissaoS,"TOTSEMIR",""   	,STR0029   ,PesqPict('SE3','E3_COMIS')	,TamSx3("E3_COMIS")[1]	,/*lPixel*/	,{||nTotSemIR})

//������������������������������������������������������������������������Ŀ
//� Impressao do Cabecalho no topo da pagina                               �
//��������������������������������������������������������������������������
oReport:Section(1):SetHeaderPage()
oReport:Section(3):SetHeaderPage() 
oReport:Section(1):Setedit(.T.)
oReport:Section(1):Section(1):Setedit(.T.)
oReport:Section(1):Section(1):Section(1):Setedit(.T.)
oReport:Section(2):Setedit(.F.)

//������������������������������������������������������������������������Ŀ
//� Alinhamento a direita dos campos de valores                            �
//��������������������������������������������������������������������������
//Analitico
oDetalhe:Cell("NVLRTITULO"):SetHeaderAlign("RIGHT")
oDetalhe:Cell("NBASEPRT"):SetHeaderAlign("RIGHT")
oDetalhe:Cell("NCOMPRT"):SetHeaderAlign("RIGHT")
//Sintetico
oComissaoS:Cell("TOTALTIT"):SetHeaderAlign("RIGHT")
oComissaoS:Cell("E3_BASE" ):SetHeaderAlign("RIGHT")
oComissaoS:Cell("E3_COMIS"):SetHeaderAlign("RIGHT")
oComissaoS:Cell("VALIR"   ):SetHeaderAlign("RIGHT")
oComissaoS:Cell("TOTSEMIR"):SetHeaderAlign("RIGHT")

//IR
oTotal:Cell("TOTALIR"):SetHeaderAlign("RIGHT")
oTotal:Cell("TOTSEMIR"):SetHeaderAlign("RIGHT")       

//TOTAL GERAL
oGeral:Cell("TXTTOTAL"):SetHeaderAlign("RIGHT")
oGeral:Cell("GERAL"   ):SetHeaderAlign("RIGHT") 
oGeral:Cell("PERCENT" ):SetHeaderAlign("RIGHT")
oGeral:Cell("COMIS"   ):SetHeaderAlign("RIGHT")

Return(oReport)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Eduardo Riera          � Data �04.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport,cAlias,oComissaoA,oComissaoS,oDetalhe,oTotal,oGeral)

Local dEmissao := CTOD( "" ) 
Local nTotLiq  := 0
Local aLiquid  := {}
Local ny 
Local cWhere   := ""
Local cNomArq, cFilialSE1, cFilialSE3
Local nI       := 0
Local cOrder   := ""
Local nDecs
Local nTotPorc	:= 0
Local nTotPerVen	:= 0
Local nTotPerGer	:= 0
Local nTaxa	:= 0

Local cDocLiq   := ""
Local cTitulo   := ""                                     
Local cAjuste   := ""
Local nTotBase	:= 0
Local nTotComis	:= 0
Local nSection	:= 0
Local nOrdem	:= 0
Local nTGerBas  := 0
Local nTGerCom  := 0
Local cFilSE1	:= "" 
Local cFilSE3   := "" 
Local cFilSA1   := "" 
Local lVend	    := .F.
Local lFirst    := .F.
Local lRndIrrf	:= GetMV("MV_RNDIRF")

If oReport:Section(1):GetOrder() == 1		// Ordem: por Titulo
	nOrdem := 1
Else										// Ordem: por Cliente
	nOrdem := 2
EndIf	

If mv_par12 == 1	// Analitico
	oReport:Section(3):Disable()
	nSection := 1   
	
	oReport:Section(1):section(1):Cell("NOMCLI"):SetTitle( Iif(mv_par14 == 1,RetTitle("A1_NREDUZ"),RetTitle("A1_NOME")) )
	oReport:Section(1):section(1):section(1):Cell("NOMCLI"):SetTitle( Iif(mv_par14 == 1,RetTitle("A1_NREDUZ"),RetTitle("A1_NOME")) )
	
	oReport:Section(1):Cell("E3_VEND"):SetBlock({|| cVend })
	oReport:Section(1):Section(1):Cell("DVENCTO" ):SetBlock({|| dVencto })	
	oReport:Section(1):Section(1):Cell("DBAIXA" ):SetBlock({|| dBaixa })	
	oReport:Section(1):Section(1):Cell("NVLRTITULO" ):SetBlock({|| nVlrTitulo })	
	oReport:Section(1):Section(1):Cell("NBASEPRT" ):SetBlock({|| nBasePrt })	
	oReport:Section(1):Section(1):Cell("NCOMPRT" ):SetBlock({|| nComPrt })	
	oReport:Section(1):Section(1):Cell("E3_BAIEMI" ):SetBlock({|| Substr(cTipo,1,1) })	
	oReport:Section(1):Section(1):Cell("AJUSTE" ):SetBlock({|| IIf( (cAjuste == "S" .And. MV_PAR07 == 1),"AJUSTE","" ) })	
	oReport:Section(1):Section(1):Section(1):Cell("E1_NUMLIQ" ):SetBlock({|| cLiquid  })	
	oReport:Section(1):Section(1):Section(1):Cell("NVALLIQ1" ):SetBlock({|| aValLiq[nI2,1] })	
	oReport:Section(1):Section(1):Section(1):Cell("NVALLIQ2" ):SetBlock({|| aValLiq[nI2,2] })	
	oReport:Section(1):Section(1):Section(1):Cell("NLIQPROP" ):SetBlock({|| aLiqProp[nI2] })	
	oReport:Section(2):Cell("TOTALIR" ):SetBlock({|| If(lRndIrrf,Round(nValIR,TamSX3("E2_IRRF")[2]),NoRound(nValIR,TamSX3("E2_IRRF")[2])) })	
	oReport:Section(2):Cell("TOTSEMIR" ):SetBlock({|| nTotSemIR })	

    bVOrig := { || cDocLiq := SE1->E1_NUMLIQ, nVlrTitulo := Iif(cTitulo <> (cAlias)->E3_PREFIXO+(cAlias)->E3_NUM+(cAlias)->E3_PARCELA+(cAlias)->E3_TIPO+(cAlias)->E3_VEND+(cAlias)->E3_CODCLI+(cAlias)->E3_LOJA, nVlrTitulo, 0 ) }
    
	TRFunction():New(oDetalhe:Cell("NVLRTITULO"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,bVOrig,.T./*lEndSection*/,IIf(mv_par11 == 2,.T.,.F.)/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oDetalhe:Cell("NBASEPRT")  ,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,IIf(mv_par11 == 2,.T.,.F.)/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oDetalhe:Cell("NCOMPRT")   ,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,PesqPict('SE3','E3_COMIS'),/*uFormula*/,.T./*lEndSection*/,IIf(mv_par11 == 2,.T.,.F.)/*lEndReport*/,/*lEndPage*/)	
	TRFunction():New(oDetalhe:Cell("E3_PORC")   ,/* cID */,"ONPRINT",/*oBreak*/,/*cTitle*/,PesqPict('SE3','E3_PORC'),{|| nTotPorc },.T./*lEndSection*/,IIf(mv_par11 == 2,.T.,.F.)/*lEndReport*/,/*lEndPage*/)

	cVend		:= ""
	dVencto 	:= ctod("  /  /  ")
	dBaixa 		:= ctod("  /  /  ")
	nVlrTitulo 	:= 0
	nBasePrt 	:= 0
	nComPrt 	:= 0
	cTipo 		:= ""
	cLiquid  	:= ""
	nValIR		:= 0
	nTotSemIR 	:= 0
	
Else				// Sintetico

	TRFunction():New(oComissaoS:Cell("TOTALTIT"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oComissaoS:Cell("E3_BASE"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oComissaoS:Cell("E3_PORC"),/* cID */,"ONPRINT",/*oBreak*/,/*cTitle*/,PesqPict('SE3','E3_PORC'),{||nTotPorc},.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oComissaoS:Cell("E3_COMIS"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,PesqPict('SE3','E3_COMIS'),/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oComissaoS:Cell("VALIR"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oComissaoS:Cell("TOTSEMIR"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
              
	oReport:Section(1):Disable()
	oReport:Section(1):Section(1):Disable()
	oReport:Section(1):Section(1):Section(1):Disable()
	nSection := 3
	
	oReport:Section(3):Cell("E3_VEND" ):SetBlock({|| cVend })		
	oReport:Section(3):Cell("TOTALTIT" ):SetBlock({|| nAc3 })		
	oReport:Section(3):Cell("E3_BASE" ):SetBlock({|| nAc1 })		
	oReport:Section(3):Cell("E3_PORC" ):SetBlock({||NoRound((nAc2*100) / nAc1,TamSX3("E3_PORC")[2]) })		
	oReport:Section(3):Cell("E3_COMIS" ):SetBlock({||nAc2 })		
	oReport:Section(3):Cell("VALIR" ):SetBlock({|| If(lRndIrrf,Round(nValIR,TamSX3("E2_IRRF")[2]),NoRound(nValIR,TamSX3("E2_IRRF")[2])) })	
	oReport:Section(3):Cell("TOTSEMIR" ):SetBlock({|| nTotSemIR })	

	cVend		:= ""
	nAc1		:= 0
	nAc2		:= 0
	nAc3		:= 0
	nValIR		:= 0
	nTotSemIR	:= 0
	
EndIf
If len(oReport:Section(1):GetAdvplExp("SE1")) > 0
   cFilSE1 := oReport:Section(1):GetAdvplExp("SE1")
EndIf
If len(oReport:Section(3):GetAdvplExp("SE3")) > 0
   cFilSE3 := oReport:Section(3):GetAdvplExp("SE3")
EndIf
If len(oReport:Section(1):GetAdvplExp("SA1")) > 0
   cFilSA1 := oReport:Section(1):GetAdvplExp("SA1")
EndIf
//������������������������������������������������������������������������Ŀ
//�Filtragem do relat�rio                                                  �
//��������������������������������������������������������������������������


// Indexa de acordo com ordem escolhida oelo cliente
dbSelectArea("SE3")
If nOrdem == 1		// Ordem: por Titulo
	dbSetOrder(2)   
	cOrder := "E3_FILIAL,E3_VEND,E3_PREFIXO,E3_NUM,E3_PARCELA"
Else										// Ordem: por Cliente
	dbSetOrder(3)
	cOrder := "E3_FILIAL,E3_VEND,E3_CODCLI,E3_LOJA,E3_PREFIXO,E3_NUM,E3_PARCELA"
EndIf	

//������������������������������������������������������������������������Ŀ
//�Query do relat�rio da secao 1                                           �
//��������������������������������������������������������������������������
	//������������������������������������������������������������������������Ŀ
	//�Transforma parametros Range em expressao SQL                            �
	//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam)	

oReport:Section(nSection):BeginQuery()

If mv_par01 == 1
	cWhere += "AND E3_BAIEMI <> 'B'"  //Baseado pela emissao da NF
Elseif mv_par01 == 2
	cWhere += "AND E3_BAIEMI =  'B'"  //Baseado pela baixa do titulo
EndIf
If mv_par06 == 1 		//Comissoes a pagar
	cWhere += "AND E3_DATA = '" + Dtos(Ctod("")) + "'"
ElseIf mv_par06 == 2 //Comissoes pagas
	cWhere += "AND E3_DATA <> '" + Dtos(Ctod("")) + "'"
Endif

	If !Valtype(MV_PAR15) == "N"
 		MV_PAR15 := Val(MV_PAR15)
	EndIf

If ValType(mv_par15) == "N"
	If mv_par15 <> 1 // Todos
		If mv_par15 == 2 // Parceiros
			cWhere += "AND A3_TIPO = 'P'"
		ElseIf mv_par15 == 3 // Vendedores
			cWhere += "AND A3_TIPO <> 'P'"
		EndIf
	EndIf
EndIf
cWhere += " ORDER BY " + cOrder
cWhere := "%" + cWhere + "%"

BEGIN REPORT QUERY oDetalhe
	BeginSql Alias cAlias
	SELECT E3_FILIAL,E3_BASE, E3_COMIS, E3_VEND, E3_PORC, A3_NOME, E3_PREFIXO,E3_NUM, E3_PARCELA,E3_TIPO,E3_CODCLI,E3_LOJA,E3_AJUSTE,E3_BAIEMI,E3_EMISSAO,E3_DATA, E3_PEDIDO
		FROM %table:SE3% SE3
		LEFT JOIN %table:SA3% SA3
	        ON A3_COD = E3_VEND
		WHERE A3_FILIAL = %xFilial:SA3%
			AND E3_FILIAL = %xFilial:SE3%

			AND	E3_EMISSAO >= %Exp:Dtos(mv_par02)%
			AND E3_EMISSAO <= %Exp:Dtos(mv_par03)%
			AND SE3.E3_VEND BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR05%
			AND SA3.%NotDel%
			AND SE3.%notdel%
			%Exp:cWhere%
	EndSql
END REPORT QUERY oDetalhe 

//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�                                                                        �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�                                                                        �
//�ExpA1 : Array com os parametros do tipo Range                           �
//�                                                                        �
//��������������������������������������������������������������������������
oReport:Section(nSection):EndQuery()

//������������������������������������������������������������������������Ŀ
//�Metodo TrPosition()                                                     �
//�                                                                        �
//�Posiciona em um registro de uma outra tabela. O posicionamento ser�     �
//�realizado antes da impressao de cada linha do relat�rio.                �
//�                                                                        �
//�                                                                        �
//�ExpO1 : Objeto Report da Secao                                          �
//�ExpC2 : Alias da Tabela                                                 �
//�ExpX3 : Ordem ou NickName de pesquisa                                   �
//�ExpX4 : String ou Bloco de c�digo para pesquisa. A string ser� macroexe-�
//�        cutada.                                                         �
//�                                                                        �				
//��������������������������������������������������������������������������
TRPosition():New(oReport:Section(nSection),"SA3",1,{|| xFilial("SA3")+cVend })
//TRPosition():New(oReport:Section(nSection),"SE3",2,{|| xFilial("SE3")+cVend+(cAlias)->E3_PREFIXO+(cAlias)->E3_NUM+(cAlias)->E3_PARCELA+(cAlias)->E3_SEQ})
If mv_par12 == 1
   TRPosition():New(oReport:Section(1):Section(1),"SA1",1,{|| xFilial("SA1")+(cAlias)->E3_CODCLI+(cAlias)->E3_LOJA })
   TRPosition():New(oReport:Section(1):Section(1):Section(1),"SA1",1,{|| xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA })
EndIf   

//������������������������������������������������������������������������Ŀ
//�Inicio da impressao do fluxo do relat�rio                               �
//��������������������������������������������������������������������������
If mv_par12 == 2 .Or. mv_par12 == 1 
	nTotBase	:= 0
	nTotComis	:= 0
EndIf

dbSelectArea(cAlias)
dbGoTop()
nDecs     := GetMv("MV_CENT"+(IIF(mv_par08 > 1 , STR(mv_par08,1),"")))

oReport:SetMeter(SE3->(LastRec()))
dbSelectArea(cAlias)
While !oReport:Cancel() .And. !&(cAlias)->(Eof())
	
	cVend := &(cAlias)->(E3_VEND)
	nAc1 := 0
	nAc2 := 0
	nAc3 := 0
	nTotPerVen := 0
	
	oReport:Section(nSection):Init()
	If mv_par12 == 1 .And. Empty(cFilSE1) .And. Empty(cFilSE3) .And. Empty(cFilSA1)
		oReport:Section(nSection):PrintLine()
	EndIf	

	lVend:= .T. 
	lFirst := .T. 
	While !Eof() .And. xFilial("SE3") == (cAlias)->E3_FILIAL .And. (cAlias)->E3_VEND == cVend
		nBasePrt   := 0
		nComPrt    := 0
		nVlrTitulo := 0
		If mv_par12 == 1 
			nTotBase	:= 0
			nTotComis	:= 0
		EndIf

		dbSelectArea("SE3")
		dbSetOrder(2)
		dbSeek(xFilial("SE3")+cVend+&(cAlias)->(E3_PREFIXO)+&(cAlias)->(E3_NUM)+&(cAlias)->(E3_PARCELA))
						
		dbSelectArea("SE1")
		dbSetOrder(1)
		dbSeek(xFilial()+&(cAlias)->(E3_PREFIXO)+&(cAlias)->(E3_NUM)+&(cAlias)->(E3_PARCELA)+&(cAlias)->(E3_TIPO))

		// Se nao imprime detalhes da origem, desconsidera titulos faturados
		If mv_par13 <> 1 .And. !Empty(SE1->E1_FATURA) .And. SE1->E1_FATURA <> "NOTFAT"
			(cAlias)->( dbSkip() )
			Loop
		EndIf

	   // Verifica filtro do usuario
	   	If !Empty(cFilSE1) .And. !(&cFilSE1)
		   dbSelectArea(cAlias)	
	       dbSkip()
		   Loop
		ElseIf !Empty(cFilSE1) .And. (&cFilSE1) .And. lFirst
			oReport:Section(nSection):PrintLine()
			lFirst := .F.    
		EndIf 
		If!Empty(cFilSE3) .And. !(cAlias)->(&cFilSE3)
		   dbSelectArea(cAlias)	
	       dbSkip()
		   Loop
		ElseIf !Empty(cFilSE3) .And. (cAlias)->(&cFilSE3) .And. lVend 
			If mv_par12 == 1
				oReport:Section(nSection):PrintLine()       
				lVend:= .F.
			EndIf   
		EndIf
		If!Empty(cFilSA1) 
		   	SA1->(dbSetOrder(1))               
			If SA1->(dbSeek(xFilial()+&(cAlias)->(E3_CODCLI)+&(cAlias)->(E3_LOJA)))
				If !( SA1->&cFilSa1)	
		  			dbSelectArea(cAlias)	 
				   	dbSkip()  
					Loop
				ElseIf (SA1->&cFilSA1) .And. lVend
					oReport:Section(nSection):PrintLine()
					lVend := .F.	
				EndIf	
		   	EndIf 
		EndIf 		   	
		If nModulo == 12 
			nVlrTitulo:= Round(xMoeda((cAlias)->E3_BASE,SE1->E1_MOEDA,MV_PAR08,(cAlias)->E3_EMISSAO,nDecs+1),nDecs)
		Else
			nVlrTitulo:= Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,MV_PAR08,SE1->E1_EMISSAO,nDecs+1),nDecs)
		EndIf
			
		dEmissao  := SE1->E1_EMISSAO
		cLiquid   := ""
		cDocLiq   := SE1->E1_NUMLIQ
		
		If mv_par12 == 1
			dVencto   := SE1->E1_VENCTO
			aLiquid	  := {}
			aValLiq	  := {}
			aLiqProp  := {}
			nTotLiq	  := 0
			If mv_par13 == 1 .And. !Empty(SE1->E1_NUMLIQ) .And. FindFunction("FA440LIQSE1")
				cLiquid := SE1->E1_NUMLIQ
				cDocLiq := SE1->E1_NUMLIQ
				// Obtem os registros que deram origem ao titulo gerado pela liquidacao
				Fa440LiqSe1(SE1->E1_NUMLIQ,@aLiquid,@aValLiq)
				For ny := 1 to Len(aValLiq)
					nTotLiq += aValLiq[ny,2]
				Next
				For ny := 1 to Len(aValLiq)
					aAdd(aLiqProp,(nVlrTitulo/nTotLiq)*aValLiq[ny,2])
				Next
			Endif
			
			If (cAlias)->E3_BAIEMI == "B"
				dBaixa     := (cAlias)->E3_EMISSAO
			Else
				dBaixa     := SE1->E1_BAIXA
			Endif
		EndIf
		
		If Eof()

			dbSelectArea("SF1")
			dbSetOrder(1)

			dbSelectArea("SF2")
			dbSetorder(1)
			
			If AllTrim((cAlias)->E3_TIPO) == "NCC"
				SF1->(dbSeek(xFilial("SF1")+(cAlias)->E3_NUM+(cAlias)->E3_PREFIXO+(cAlias)->E3_CODCLI+(cAlias)->E3_LOJA,.t.))
			    nVlrTitulo := Round(xMoeda(SF1->F1_VALBRUT,SF1->F1_MOEDA,mv_par08,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA),nDecs)
			    dEmissao   := SF1->F1_DTDIGIT
			Else
		   		dbSeek(xFilial()+(cAlias)->E3_NUM+(cAlias)->E3_PREFIXO)
				nVlrTitulo := Round(xMoeda(F2_VALFAT,SF2->F2_MOEDA,mv_par08,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA),nDecs)
		 		dEmissao   := SF2->F2_EMISSAO
			EndIf
			
			If mv_par12 == 1
				dVencto    := CTOD( "" )
				dBaixa     := CTOD( "" )  	
			EndIf
			
			If Eof()
				nVlrTitulo := 0
				dbSelectArea("SE1")
				dbSetOrder(1)
				cFilialSE1 := xFilial()
				dbSeek(cFilialSE1+&(cAlias)->(E3_PREFIXO)+&(cAlias)->(E3_NUM))
				While ( !Eof() .And. (cAlias)->E3_PREFIXO == SE1->E1_PREFIXO .And.;
					(cAlias)->E3_NUM == SE1->E1_NUM .And.;
					(cAlias)->E3_FILIAL == cFilialSE1 )
					If ( SE1->E1_TIPO == (cAlias)->E3_TIPO  .And. ;
						SE1->E1_CLIENTE == (cAlias)->E3_CODCLI .And. ;
						SE1->E1_LOJA == (cAlias)->E3_LOJA )
						nVlrTitulo += Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,MV_PAR08,SE1->E1_EMISSAO,nDecs+1),nDecs)
						
						If mv_par12 == 1
							dVencto    := CTOD( "" )
							dBaixa     := CTOD( "" )
						EndIf

						If Empty(dEmissao)
							dEmissao := SE1->E1_EMISSAO
						EndIf
						
					EndIf
					dbSelectArea("SE1")
					dbSkip()
				EndDo
			EndIf
		Endif
		
		If Empty(dEmissao)
			dEmissao := NIL
		EndIf

		nTaxa := SE1->E1_VLCRUZ / SE1->E1_VALOR
				
		If MV_PAR08 == 1 .Or. SE1->E1_MOEDA == 1
			nBasePrt:=	Round(xMoeda((cAlias)->E3_BASE ,1,MV_PAR08,dEmissao,nDecs+1),nDecs)
			nComPrt :=	Round(xMoeda((cAlias)->E3_COMIS,1,MV_PAR08,dEmissao,TamSx3("E3_COMIS")[2]+1),TamSx3("E3_COMIS")[2])
		Else
			nBasePrt:=	Round(xMoeda((cAlias)->E3_BASE ,1,MV_PAR08,dEmissao,nDecs+1,SE1->E1_TXMOEDA,nTaxa),nDecs)
			nComPrt :=	Round(xMoeda((cAlias)->E3_COMIS,1,MV_PAR08,dEmissao,TamSx3("E3_COMIS")[2]+1,SE1->E1_TXMOEDA,nTaxa),TamSx3("E3_COMIS")[2])
		EndIf
		
		If mv_par09 == 2 .And. mv_par08 != 1  //N�o apresenta comiss�es zeradas em outras moedas
			If nVlrTitulo == 0 .And. nBasePrt == 0 .And. nComPrt == 0 
				(cAlias)->(DbSkip())
				Loop
			EndIf
		EndIf 
		
		If nBasePrt < 0 .And. nComPrt < 0
			nVlrTitulo := nVlrTitulo * -1
		Endif
		
		If mv_par12 == 1
			cAjuste := (cAlias)->E3_AJUSTE
			cTipo   := (cAlias)->E3_BAIEMI
			dbSelectArea(cAlias)
			oReport:Section(1):Section(1):Init()
 			oReport:Section(1):Section(1):PrintLine()
  			oReport:IncMeter()
			
			If mv_par13 == 1
				For nI := 1 To Len(aLiquid)
					nI2 := nI
					SE1->(MsGoto(aLiquid[nI]))
				    oReport:Section(1):SetHeaderBreak(.T.)
					oReport:Section(1):Section(1):Section(1):Init()
					oReport:Section(1):Section(1):Section(1):PrintLine()
				Next
				If Len(aLiquid) > 0
					oReport:Section(1):Section(1):Section(1):Finish()
				EndIf
			Endif			
			
		EndIf
		
		nAc1 += nBasePrt
		nAc2 += nComPrt
		nTotPerVen += (nBasePrt*(cAlias)->E3_PORC)/100
		nTotPerGer += nTotPerVen
		If cTitulo <> (cAlias)->E3_PREFIXO+(cAlias)->E3_NUM+(cAlias)->E3_PARCELA+(cAlias)->E3_TIPO+(cAlias)->E3_VEND+(cAlias)->E3_CODCLI+(cAlias)->E3_LOJA 
			nAc3   += nVlrTitulo
			cTitulo:= (cAlias)->E3_PREFIXO+(cAlias)->E3_NUM+(cAlias)->E3_PARCELA+(cAlias)->E3_TIPO+(cAlias)->E3_VEND+(cAlias)->E3_CODCLI+(cAlias)->E3_LOJA
			cDocLiq:= ""
		EndIf
		
		dbSelectArea(cAlias)
		dbSkip()
	EndDo
	
	If mv_par12 == 1
		nTotBase 	+= nAc1
		nTotComis 	+= nAc2
		nTotPorc	:= Round((nTotComis / nTotBase)*100,TamSx3("E3_COMIS")[2])
		nTotPerVen  := Round((nTotPerVen/nAc1)*100,TamSx3("E3_PORC")[2])
		oReport:Section(1):Section(1):SetTotalText("Total do Vendedor " + cVend)
		oReport:Section(1):Section(1):Finish()
	EndIf
	
	nValIR    := 0
	nTotSemIR := 0
	If mv_par10 > 0 .And. (nAc2 * mv_par10 / 100) > GetMV("MV_VLRETIR") //IR
		nValIR    := nAc2 * (MV_PAR10/100)
		nTotSemIR := nAc2 - (nAc2 * (MV_PAR10/100))
	Else
		nTotSemIR := nAc2
	EndIf
	
	If mv_par12 == 2
		nTotBase 	+= nAc1
		nTotComis 	+= nAc2
		nTotPorc	:= Round((nTotComis / nTotBase)*100,TamSx3("E3_COMIS")[2])
		nTotPerVen  := Round((nTotPerVen/nAc1)*100,TamSx3("E3_PORC")[2])
		oReport:Section(nSection):Init()				
		oReport:Section(nSection):PrintLine()
	EndIf	
	oReport:Section(nSection):Finish()
	
	If mv_par12 == 1 .And. mv_par10 > 0
		oReport:Section(2):Init()
		oReport:Section(2):PrintLine()
		oReport:Section(2):Finish()
	EndIf
	
	If mv_par11 == 1
	   oReport:Section(nSection):SetPageBreak(.T.)
	EndIf
	
	If mv_par12 == 2
		oReport:IncMeter()
	EndIf
	
	nTGerBas    += nAc1
    nTGerCom    += nAc2
	
EndDo

nTotPorc := ((nTGerCom*100)/nTGerBas) 
 
If mv_par11 == 1
	oGeral:SetPageBreak(.T.)
	oGeral:Cell("TXTTOTAL"):SetSize(21)
	oGeral:Cell("GERAL"   ):SetBlock  ( { || nTGerBas } ) 
	oGeral:Cell("PERCENT" ):SetBlock  ( { || nTotPorc } )
	oGeral:Cell("COMIS"   ):SetBlock  ( { || nTGerCom } ) 
	oGeral:Init()
	oGeral:PrintLine()
	oGeral:Finish()
	oGeral:SetPageBreak(.T.)
EndIf 

Return