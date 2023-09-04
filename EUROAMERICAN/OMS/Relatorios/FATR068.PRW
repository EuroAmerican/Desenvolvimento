
#include "topconn.ch"        
#include "tbiconn.ch"   
#include "rwmake.ch"    
#include "colors.ch"

#define ENTER chr(13) + chr(10)   

#define PAD_LEFT            0
#define PAD_RIGHT           1
#define PAD_CENTER          2

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATR068   บ Autor ณAlexandre Marson    บ Data ณ 15/03/13    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ RELATORIO - ROMANEIO DE EXPEDICAO                          บฑฑ
ฑฑบ          ณ MODELO PSAY ( NAO GRAFICO )                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFAT                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function FATR068( IDCarga )
Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local titulo         := "Romaneio de Despacho ( EXPEDICAO )"
Local aOrd           := {}
Local Cabec1         := ""                            
Local Cabec2         := ""

Private nLin         := 80
Private lEnd         := .F.
Private CbTxt        := ""
Private limite       := 132
Private tamanho      := "M"
Private nomeprog     := "FATR068"
Private nTipo        := 18
Private aReturn      := {"Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := ""
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "FATR068"
Private cString      := "SZF"

Private cCarga       := IDCarga

         
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Envia controle para a funcao SETPRINT                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Chamada a SetDefault para carga das Informacoes do seleciona-ณ
//ณ das na SetPrint()                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RptStatus({|lEnd| FATR068IMP(@lEnd,wnRel,cString)},Titulo)

Return                              


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATR066SAYบ Autor ณAlexandre Marson    บ Data ณ 15/03/13    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFUNCAO DE IMPRESSAO                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFAT                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/              
Static Function FATR068Imp(lEnd,WnRel,cString)
Local aArea		:= GetArea()
Local aAreaSZF	:= SZF->( GetArea() )
Local aAreaDA3	:= DA3->( GetArea() )
Local cQry		:= ""       
Local nDet      := 1       
Local aTotal    := {}    
Local nApvFrete := 0
Local nApvCarga := 0

Private nRec    := 0
Private nPag	:= 0   
Private nTotPag := 0
Private aL		:= fLayout()
Private nX		:= 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Script SQL para impressao dos registros de detalhe                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
If Left(cFilAnt, 2) $ "02#03#08#09"

	cQry := "SELECT " + ENTER
	cQry += "	RTRIM(ZG_SERIE) + '-' + ZG_NOTA [NOTA], " + ENTER
	cQry += "	RTRIM(CONVERT(VARCHAR, CONVERT(DATE, F2_EMISSAO), 103)) [EMISSAO], " + ENTER
	cQry += "	(SELECT MAX(D2_PEDIDO) FROM " + RetSqlName("SD2") + " SD2 WHERE SD2.D_E_L_E_T_ = '' " + ENTER
	cQry += "		AND	D2_FILIAL = F2_FILIAL " + ENTER
	cQry += "		AND D2_DOC = F2_DOC " + ENTER
	cQry += "		AND	D2_SERIE = F2_SERIE) [PEDIDO], " + ENTER		//C5_NUM
	cQry += "	ZG_EMPFIL [EMPFIL], " + ENTER
	cQry += "	ZG_PESO [PESO], " + ENTER
	cQry += "	ZG_VALOR [VALOR], " + ENTER
	cQry += "	RTRIM(ZG_VOLUME) [VOLUME], " + ENTER
	cQry += "	ZG_KM0 [KM0], " + ENTER
	cQry += "	ZG_TM0 [TM0], " + ENTER
	cQry += "	ZG_KMX [KMX], " + ENTER
	cQry += "	ZG_TMX [TMX], " + ENTER      
	
	cQry += "	CASE WHEN NOT F2_TIPO IN ('D','B') " + ENTER
	cQry += "		THEN ( SELECT '( ' + A1_COD + '-' + A1_LOJA + ') ' + RTRIM(A1_NOME) FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )" + ENTER
	cQry += "		ELSE ( SELECT '( ' + A2_COD + '-' + A2_LOJA + ') ' + RTRIM(A2_NOME) FROM " + RetSqlName("SA2") + " WHERE D_E_L_E_T_ = '' AND A2_FILIAL = '' AND A2_COD = F2_CLIENTE AND A2_LOJA = F2_LOJA )" + ENTER
	cQry += "	END [CLIFOR], " + ENTER
	
	cQry += "	CASE WHEN NOT F2_TIPO IN ('D','B') " + ENTER
	cQry += "		THEN ( SELECT A1_U_ENTRG + '- HR REC:' + RTRIM(A1_HRECEB) FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )" + ENTER
	cQry += "		ELSE '' " + ENTER
	cQry += "	END [INSTRUCAO], " + ENTER
	
	cQry += "	'( ' + SA4.A4_COD + ') ' + SA4.A4_NOME [REDESP], " + ENTER
	cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_ENDENT FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) "	+ ENTER			//RTRIM(C5_ENDREC) " + ENTER
	cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
	cQry += "		 ELSE RTRIM(SA4.A4_END) " + ENTER
	cQry += "	END [END1], " + ENTER
	cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_BAIRROE FROM " + RetSqlName("SA1") +" WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) " + ENTER		//C5_BAIREC
	cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
	cQry += "		 ELSE RTRIM(SA4.A4_BAIRRO) " + ENTER
	cQry += "	END + ' - ' + " + ENTER
	cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_MUNE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) " + ENTER		//C5_MUNREC
	cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
	cQry += "		 ELSE RTRIM(SA4.A4_MUN) " + ENTER
	cQry += "	END + ' - ' + " + ENTER
	cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_ESTE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA ))  " + ENTER	//C5_ESTREC
	cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
	cQry += "		 ELSE RTRIM(SA4.A4_EST) " + ENTER
	cQry += "	END + ' - CEP ' + " + ENTER
	cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_CEPE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) " + ENTER		//C5_CEPREC
	cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
	cQry += "		 ELSE RTRIM(SA4.A4_CEP) " + ENTER
	cQry += "	END [END2] " + ENTER
	cQry += "FROM " + RetSqlName("SZG") + " SZG " + ENTER
	cQry += "INNER JOIN " + ENTER
	cQry += "	" + RetSqlName("SF2") + " SF2 " + ENTER
	cQry += "		ON	SF2.D_E_L_E_T_ = '' " + ENTER
	//cQry += "		AND	F2_FILIAL = RIGHT(ZG_EMPFIL,2) " + ENTER
	cQry += "		AND	F2_FILIAL = ZG_EMPFIL " + ENTER
	cQry += "		AND	F2_DOC = ZG_NOTA " + ENTER
	cQry += "		AND F2_SERIE = ZG_SERIE	 " + ENTER
	/*cQry += "INNER JOIN " + ENTER
	cQry += "	SC5020 SC5 " + ENTER
	cQry += "		ON	SC5.D_E_L_E_T_ = '' " + ENTER
	cQry += "		AND	C5_FILIAL = F2_FILIAL " + ENTER
	cQry += "		AND C5_NOTA = F2_DOC " + ENTER
	cQry += "		AND	C5_SERIE = F2_SERIE " + ENTER*/
	cQry += "INNER JOIN " + RetSqlName("SA4") + " SA4 " + ENTER
	cQry += "		ON	SA4.D_E_L_E_T_ = '' " + ENTER
	cQry += "		AND	SA4.A4_FILIAL = '' " + ENTER
	cQry += "		AND SA4.A4_COD = F2_TRANSP " + ENTER	//C5_TRANSP
	cQry += "WHERE " + ENTER
	cQry += "	SZG.D_E_L_E_T_ = '' " + ENTER
	cQry += "	AND ZG_NUM = '" + cCarga + "' " + ENTER
	cQry += "	AND	ZG_FILIAL = '' " + ENTER
	cQry += "	AND LEFT(ZG_EMPFIL,2) = '02' " + ENTER
	
	cQry += "---------------------------------- " + ENTER
	cQry += "UNION ALL " + ENTER
	cQry += "---------------------------------- " + ENTER
	
	cQry += "SELECT " + ENTER
	cQry += "	RTRIM(ZG_SERIE) + '-' + ZG_NOTA [NOTA], " + ENTER
	cQry += "	RTRIM(CONVERT(VARCHAR, CONVERT(DATE, F2_EMISSAO), 103)) [EMISSAO], " + ENTER
	cQry += "	(SELECT MAX(D2_PEDIDO) FROM " + RetSqlName("SD2") + " SD2 WHERE SD2.D_E_L_E_T_ = '' " + ENTER
	cQry += "		AND	D2_FILIAL = F2_FILIAL " + ENTER
	cQry += "		AND D2_DOC = F2_DOC " + ENTER
	cQry += "		AND	D2_SERIE = F2_SERIE) [PEDIDO], " + ENTER		//C5_NUM
	cQry += "	ZG_EMPFIL [EMPFIL], " + ENTER
	cQry += "	ZG_PESO [PESO], " + ENTER
	cQry += "	ZG_VALOR [VALOR], " + ENTER
	cQry += "	RTRIM(ZG_VOLUME) [VOLUME], " + ENTER
	cQry += "	ZG_KM0 [KM0], " + ENTER
	cQry += "	ZG_TM0 [TM0], " + ENTER
	cQry += "	ZG_KMX [KMX], " + ENTER
	cQry += "	ZG_TMX [TMX], " + ENTER
	
	cQry += "	CASE WHEN NOT F2_TIPO IN ('D','B') " + ENTER
	cQry += "		THEN ( SELECT '( ' + A1_COD + '-' + A1_LOJA + ') ' + RTRIM(A1_NOME) FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )" + ENTER
	cQry += "		ELSE ( SELECT '( ' + A2_COD + '-' + A2_LOJA + ') ' + RTRIM(A2_NOME) FROM " + RetSqlName("SA2") + " WHERE D_E_L_E_T_ = '' AND A2_FILIAL = '' AND A2_COD = F2_CLIENTE AND A2_LOJA = F2_LOJA )" + ENTER
	cQry += "	END [CLIFOR], " + ENTER
	
	cQry += "	CASE WHEN NOT F2_TIPO IN ('D','B') " + ENTER
	cQry += "		THEN ( SELECT A1_U_ENTRG + '- HR REC:' + RTRIM(A1_HRECEB) FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )" + ENTER
	cQry += "		ELSE '' " + ENTER
	cQry += "	END [INSTRUCAO], " + ENTER
	
	cQry += "	'( ' + SA4.A4_COD + ') ' + SA4.A4_NOME [REDESP], " + ENTER
	cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_ENDENT FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) "	+ ENTER			//RTRIM(C5_ENDREC) " + ENTER
	cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
	cQry += "		 ELSE RTRIM(SA4.A4_END) " + ENTER
	cQry += "	END [END1], " + ENTER
	cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_BAIRROE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) " + ENTER		//C5_BAIREC
	cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
	cQry += "		 ELSE RTRIM(SA4.A4_BAIRRO) " + ENTER
	cQry += "	END + ' - ' + " + ENTER
	cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_MUNE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) " + ENTER		//C5_MUNREC
	cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
	cQry += "		 ELSE RTRIM(SA4.A4_MUN) " + ENTER
	cQry += "	END + ' - ' + " + ENTER
	cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_ESTE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA ))  " + ENTER	//C5_ESTREC
	cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
	cQry += "		 ELSE RTRIM(SA4.A4_EST) " + ENTER
	cQry += "	END + ' - CEP ' + " + ENTER
	cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_CEPE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) " + ENTER		//C5_CEPREC
	cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
	cQry += "		 ELSE RTRIM(SA4.A4_CEP) " + ENTER
	cQry += "	END [END2] " + ENTER
	cQry += "FROM " + ENTER
	cQry += "	" + RetSqlName("SZG") + " SZG " + ENTER
	cQry += "INNER JOIN " + ENTER
	cQry += "	" + RetSqlName("SF2") + " SF2 " + ENTER
	cQry += "		ON	SF2.D_E_L_E_T_ = '' " + ENTER
//	cQry += "		AND	F2_FILIAL = RIGHT(ZG_EMPFIL,2) " + ENTER
	cQry += "		AND	F2_FILIAL = ZG_EMPFIL " + ENTER
	cQry += "		AND	F2_DOC = ZG_NOTA " + ENTER
	cQry += "		AND F2_SERIE = ZG_SERIE	 " + ENTER
	/*cQry += "INNER JOIN " + ENTER
	cQry += "	SC5030 SC5 " + ENTER
	cQry += "		ON	SC5.D_E_L_E_T_ = '' " + ENTER
	cQry += "		AND	C5_FILIAL = F2_FILIAL " + ENTER
	cQry += "		AND C5_NOTA = F2_DOC " + ENTER
	cQry += "		AND	C5_SERIE = F2_SERIE " + ENTER*/
	cQry += "INNER JOIN " + ENTER
	cQry += "	" + RetSqlName("SA4") + " SA4 " + ENTER
	cQry += "		ON	SA4.D_E_L_E_T_ = '' " + ENTER
	cQry += "		AND	SA4.A4_FILIAL = '' " + ENTER
	cQry += "		AND SA4.A4_COD = F2_TRANSP " + ENTER	//C5_TRANSP
	cQry += "WHERE " + ENTER
	cQry += "	SZG.D_E_L_E_T_ = '' " + ENTER
	cQry += "	AND ZG_NUM = '" + cCarga + "' " + ENTER
	cQry += "	AND	ZG_FILIAL = '' " + ENTER
	cQry += "	AND LEFT(ZG_EMPFIL,2) = '03' " + ENTER
	                                     
	cQry += "---------------------------------- " + ENTER
	cQry += "UNION ALL " + ENTER
	cQry += "---------------------------------- " + ENTER            

//ElseIf Left(cFilAnt,2) $ "08"

	cQry += "SELECT " + ENTER
	cQry += "	RTRIM(ZG_SERIE) + '-' + ZG_NOTA [NOTA], " + ENTER
	cQry += "	RTRIM(CONVERT(VARCHAR, CONVERT(DATE, F2_EMISSAO), 103)) [EMISSAO], " + ENTER
	cQry += "	(SELECT MAX(D2_PEDIDO) FROM " + RetSqlName("SD2") + " SD2 WHERE SD2.D_E_L_E_T_ = '' " + ENTER
	cQry += "		AND	D2_FILIAL = F2_FILIAL " + ENTER
	cQry += "		AND D2_DOC = F2_DOC " + ENTER
	cQry += "		AND	D2_SERIE = F2_SERIE) [PEDIDO], " + ENTER		//C5_NUM
	cQry += "	ZG_EMPFIL [EMPFIL], " + ENTER
	cQry += "	ZG_PESO [PESO], " + ENTER
	cQry += "	ZG_VALOR [VALOR], " + ENTER
	cQry += "	RTRIM(ZG_VOLUME) [VOLUME], " + ENTER
	cQry += "	ZG_KM0 [KM0], " + ENTER
	cQry += "	ZG_TM0 [TM0], " + ENTER
	cQry += "	ZG_KMX [KMX], " + ENTER
	cQry += "	ZG_TMX [TMX], " + ENTER      
	
	cQry += "	CASE WHEN NOT F2_TIPO IN ('D','B') " + ENTER
	cQry += "		THEN ( SELECT '( ' + A1_COD + '-' + A1_LOJA + ') ' + RTRIM(A1_NOME) FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )" + ENTER
	cQry += "		ELSE ( SELECT '( ' + A2_COD + '-' + A2_LOJA + ') ' + RTRIM(A2_NOME) FROM " + RetSqlName("SA2") + " WHERE D_E_L_E_T_ = '' AND A2_FILIAL = '' AND A2_COD = F2_CLIENTE AND A2_LOJA = F2_LOJA )" + ENTER
	cQry += "	END [CLIFOR], " + ENTER
	
	cQry += "	CASE WHEN NOT F2_TIPO IN ('D','B') " + ENTER
	cQry += "		THEN ( SELECT A1_U_ENTRG + '- HR REC:' + RTRIM(A1_HRECEB) FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )" + ENTER
	cQry += "		ELSE '' " + ENTER
	cQry += "	END [INSTRUCAO], " + ENTER
	
	cQry += "	'( ' + SA4.A4_COD + ') ' + SA4.A4_NOME [REDESP], " + ENTER
	cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_ENDENT FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) "	+ ENTER			//RTRIM(C5_ENDREC) " + ENTER
	cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
	cQry += "		 ELSE RTRIM(SA4.A4_END) " + ENTER
	cQry += "	END [END1], " + ENTER
	cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_BAIRROE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) " + ENTER		//C5_BAIREC
	cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
	cQry += "		 ELSE RTRIM(SA4.A4_BAIRRO) " + ENTER
	cQry += "	END + ' - ' + " + ENTER
	cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_MUNE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) " + ENTER		//C5_MUNREC
	cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
	cQry += "		 ELSE RTRIM(SA4.A4_MUN) " + ENTER
	cQry += "	END + ' - ' + " + ENTER
	cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_ESTE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA ))  " + ENTER	//C5_ESTREC
	cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
	cQry += "		 ELSE RTRIM(SA4.A4_EST) " + ENTER
	cQry += "	END + ' - CEP ' + " + ENTER
	cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_CEPE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) " + ENTER		//C5_CEPREC
	cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
	cQry += "		 ELSE RTRIM(SA4.A4_CEP) " + ENTER
	cQry += "	END [END2] " + ENTER
	cQry += "FROM " + ENTER
	cQry += "	" + RetSqlName("SZG") + " SZG " + ENTER
	cQry += "INNER JOIN " + ENTER
	cQry += "	" + RetSqlName("SF2") + " SF2 " + ENTER
	cQry += "		ON	SF2.D_E_L_E_T_ = '' " + ENTER
	//cQry += "		AND	F2_FILIAL = RIGHT(ZG_EMPFIL,2) " + ENTER
	cQry += "		AND	F2_FILIAL = ZG_EMPFIL " + ENTER
	cQry += "		AND	F2_DOC = ZG_NOTA " + ENTER
	cQry += "		AND F2_SERIE = ZG_SERIE	 " + ENTER
	/*cQry += "INNER JOIN " + ENTER
	cQry += "	SC5080 SC5 " + ENTER
	cQry += "		ON	SC5.D_E_L_E_T_ = '' " + ENTER
	cQry += "		AND	C5_FILIAL = F2_FILIAL " + ENTER
	cQry += "		AND C5_NOTA = F2_DOC " + ENTER
	cQry += "		AND	C5_SERIE = F2_SERIE " + ENTER*/
	cQry += "INNER JOIN " + ENTER
	cQry += "	" + RetSqlName("SA4") + " SA4 " + ENTER
	cQry += "		ON	SA4.D_E_L_E_T_ = '' " + ENTER
	cQry += "		AND	SA4.A4_FILIAL = '' " + ENTER
	cQry += "		AND SA4.A4_COD = F2_TRANSP " + ENTER	//C5_TRANSP
	cQry += "WHERE " + ENTER
	cQry += "	SZG.D_E_L_E_T_ = '' " + ENTER
	cQry += "	AND ZG_NUM = '" + cCarga + "' " + ENTER
	cQry += "	AND	ZG_FILIAL = '' " + ENTER
	cQry += "	AND LEFT(ZG_EMPFIL,2) = '08' " + ENTER
	
	cQry += "---------------------------------- " + ENTER
	cQry += "UNION ALL " + ENTER
	cQry += "---------------------------------- " + ENTER
	
	cQry += "SELECT " + ENTER
	cQry += "	RTRIM(ZG_SERIE) + '-' + ZG_NOTA [NOTA], " + ENTER
	cQry += "	RTRIM(CONVERT(VARCHAR, CONVERT(DATE, F2_EMISSAO), 103)) [EMISSAO], " + ENTER
	cQry += "	(SELECT MAX(D2_PEDIDO) FROM " + RetSqlName("SD2") + " SD2 WHERE SD2.D_E_L_E_T_ = '' " + ENTER
	cQry += "		AND	D2_FILIAL = F2_FILIAL " + ENTER
	cQry += "		AND D2_DOC = F2_DOC " + ENTER
	cQry += "		AND	D2_SERIE = F2_SERIE) [PEDIDO], " + ENTER		//C5_NUM
	cQry += "	ZG_EMPFIL [EMPFIL], " + ENTER
	cQry += "	ZG_PESO [PESO], " + ENTER
	cQry += "	ZG_VALOR [VALOR], " + ENTER
	cQry += "	RTRIM(ZG_VOLUME) [VOLUME], " + ENTER
	cQry += "	ZG_KM0 [KM0], " + ENTER
	cQry += "	ZG_TM0 [TM0], " + ENTER
	cQry += "	ZG_KMX [KMX], " + ENTER
	cQry += "	ZG_TMX [TMX], " + ENTER      
	
	cQry += "	CASE WHEN NOT F2_TIPO IN ('D','B') " + ENTER
	cQry += "		THEN ( SELECT '( ' + A1_COD + '-' + A1_LOJA + ') ' + RTRIM(A1_NOME) FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )" + ENTER
	cQry += "		ELSE ( SELECT '( ' + A2_COD + '-' + A2_LOJA + ') ' + RTRIM(A2_NOME) FROM " + RetSqlName("SA2") + " WHERE D_E_L_E_T_ = '' AND A2_FILIAL = '' AND A2_COD = F2_CLIENTE AND A2_LOJA = F2_LOJA )" + ENTER
	cQry += "	END [CLIFOR], " + ENTER
	
	cQry += "	CASE WHEN NOT F2_TIPO IN ('D','B') " + ENTER
	cQry += "		THEN ( SELECT A1_U_ENTRG + '- HR REC:' + RTRIM(A1_HRECEB) FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )" + ENTER
	cQry += "		ELSE '' " + ENTER
	cQry += "	END [INSTRUCAO], " + ENTER
	
	cQry += "	'( ' + SA4.A4_COD + ') ' + SA4.A4_NOME [REDESP], " + ENTER
	cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_ENDENT FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) "	+ ENTER			//RTRIM(C5_ENDREC) " + ENTER
	cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
	cQry += "		 ELSE RTRIM(SA4.A4_END) " + ENTER
	cQry += "	END [END1], " + ENTER
	cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_BAIRROE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) " + ENTER		//C5_BAIREC
	cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
	cQry += "		 ELSE RTRIM(SA4.A4_BAIRRO) " + ENTER
	cQry += "	END + ' - ' + " + ENTER
	cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_MUNE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) " + ENTER		//C5_MUNREC
	cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
	cQry += "		 ELSE RTRIM(SA4.A4_MUN) " + ENTER
	cQry += "	END + ' - ' + " + ENTER
	cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_ESTE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA ))  " + ENTER	//C5_ESTREC
	cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
	cQry += "		 ELSE RTRIM(SA4.A4_EST) " + ENTER
	cQry += "	END + ' - CEP ' + " + ENTER
	cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_CEPE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) " + ENTER		//C5_CEPREC
	cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
	cQry += "		 ELSE RTRIM(SA4.A4_CEP) " + ENTER
	cQry += "	END [END2] " + ENTER
	cQry += "FROM " + ENTER
	cQry += "	" + RetSqlName("SZG") + " SZG " + ENTER
	cQry += "INNER JOIN " + ENTER
	cQry += "	" + RetSqlName("SF2") + " SF2 " + ENTER
	cQry += "		ON	SF2.D_E_L_E_T_ = '' " + ENTER
	//cQry += "		AND	F2_FILIAL = RIGHT(ZG_EMPFIL,2) " + ENTER
	cQry += "		AND	F2_FILIAL = ZG_EMPFIL " + ENTER
	cQry += "		AND	F2_DOC = ZG_NOTA " + ENTER
	cQry += "		AND F2_SERIE = ZG_SERIE	 " + ENTER
	/*cQry += "INNER JOIN " + ENTER
	cQry += "	SC5080 SC5 " + ENTER
	cQry += "		ON	SC5.D_E_L_E_T_ = '' " + ENTER
	cQry += "		AND	C5_FILIAL = F2_FILIAL " + ENTER
	cQry += "		AND C5_NOTA = F2_DOC " + ENTER
	cQry += "		AND	C5_SERIE = F2_SERIE " + ENTER*/
	cQry += "INNER JOIN " + ENTER
	cQry += "	" + RetSqlName("SA4") + " SA4 " + ENTER
	cQry += "		ON	SA4.D_E_L_E_T_ = '' " + ENTER
	cQry += "		AND	SA4.A4_FILIAL = '' " + ENTER
	cQry += "		AND SA4.A4_COD = F2_TRANSP " + ENTER	//C5_TRANSP
	cQry += "WHERE " + ENTER
	cQry += "	SZG.D_E_L_E_T_ = '' " + ENTER
	cQry += "	AND ZG_NUM = '" + cCarga + "' " + ENTER
	cQry += "	AND	ZG_FILIAL = '' " + ENTER
	cQry += "	AND LEFT(ZG_EMPFIL,2) = '09' " + ENTER
	
	cQry += "---------------------------------- " + ENTER
	cQry += "UNION ALL " + ENTER
	cQry += "---------------------------------- " + ENTER

EndIf  

cQry += "SELECT " + ENTER
cQry += "	RTRIM(ZG_SERIE) + '-' + ZG_NOTA [NOTA], " + ENTER
cQry += "	RTRIM(CONVERT(VARCHAR, CONVERT(DATE, F2_EMISSAO), 103)) [EMISSAO], " + ENTER
	cQry += "	(SELECT MAX(D2_PEDIDO) FROM " + RetSqlName("SD2") + " SD2 WHERE SD2.D_E_L_E_T_ = '' " + ENTER
	cQry += "		AND	D2_FILIAL = F2_FILIAL " + ENTER
	cQry += "		AND D2_DOC = F2_DOC " + ENTER
	cQry += "		AND	D2_SERIE = F2_SERIE) [PEDIDO], " + ENTER		//C5_NUM
cQry += "	ZG_EMPFIL [EMPFIL], " + ENTER
cQry += "	ZG_PESO [PESO], " + ENTER
cQry += "	ZG_VALOR [VALOR], " + ENTER
cQry += "	RTRIM(ZG_VOLUME) [VOLUME], " + ENTER
cQry += "	ZG_KM0 [KM0], " + ENTER
cQry += "	ZG_TM0 [TM0], " + ENTER
cQry += "	ZG_KMX [KMX], " + ENTER
cQry += "	ZG_TMX [TMX], " + ENTER

cQry += "	CASE WHEN NOT F2_TIPO IN ('D','B') " + ENTER
cQry += "		THEN ( SELECT '( ' + A1_COD + '-' + A1_LOJA + ') ' + RTRIM(A1_NOME) FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )" + ENTER
cQry += "		ELSE ( SELECT '( ' + A2_COD + '-' + A2_LOJA + ') ' + RTRIM(A2_NOME) FROM " + RetSqlName("SA2") + " WHERE D_E_L_E_T_ = '' AND A2_FILIAL = '' AND A2_COD = F2_CLIENTE AND A2_LOJA = F2_LOJA )" + ENTER
cQry += "	END [CLIFOR], " + ENTER

cQry += "	CASE WHEN NOT F2_TIPO IN ('D','B') " + ENTER
cQry += "		THEN ( SELECT A1_U_ENTRG + '- HR REC:' + RTRIM(A1_HRECEB) FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )" + ENTER
cQry += "		ELSE '' " + ENTER
cQry += "	END [INSTRUCAO], " + ENTER

cQry += "	'( ' + SA4.A4_COD + ') ' + SA4.A4_NOME [REDESP], " + ENTER
cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_ENDENT FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) "	+ ENTER			//RTRIM(C5_ENDREC) " + ENTER
cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
cQry += "		 ELSE RTRIM(SA4.A4_END) " + ENTER
cQry += "	END [END1], " + ENTER
cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_BAIRROE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) " + ENTER		//C5_BAIREC
cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
cQry += "		 ELSE RTRIM(SA4.A4_BAIRRO) " + ENTER
cQry += "	END + ' - ' + " + ENTER
cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_MUNE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) " + ENTER		//C5_MUNREC
cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
cQry += "		 ELSE RTRIM(SA4.A4_MUN) " + ENTER
cQry += "	END + ' - ' + " + ENTER
cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_ESTE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA ))  " + ENTER	//C5_ESTREC
cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
cQry += "		 ELSE RTRIM(SA4.A4_EST) " + ENTER
cQry += "	END + ' - CEP ' + " + ENTER
cQry += "	CASE WHEN SA4.A4_COD = '000001' THEN RTRIM(( SELECT A1_CEPE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) " + ENTER		//C5_CEPREC
cQry += "		 WHEN SA4.A4_COD = '000002' THEN '** RETIRA **' " + ENTER
cQry += "		 ELSE RTRIM(SA4.A4_CEP) " + ENTER
cQry += "	END [END2] " + ENTER
cQry += "FROM " + ENTER
cQry += "	" + RetSqlName("SZG") + " SZG " + ENTER
cQry += "INNER JOIN " + ENTER
cQry += "	" + RetSqlName("SF2") + " SF2 " + ENTER
cQry += "		ON	SF2.D_E_L_E_T_ = '' " + ENTER
//cQry += "		AND	F2_FILIAL = RIGHT(ZG_EMPFIL,2) " + ENTER
cQry += "		AND	F2_FILIAL = ZG_EMPFIL " + ENTER
cQry += "		AND	F2_DOC = ZG_NOTA " + ENTER
cQry += "		AND F2_SERIE = ZG_SERIE	 " + ENTER
/*cQry += "INNER JOIN " + ENTER
cQry += "	SC5010 SC5 " + ENTER
cQry += "		ON	SC5.D_E_L_E_T_ = '' " + ENTER
cQry += "		AND	C5_FILIAL = F2_FILIAL " + ENTER
cQry += "		AND C5_NOTA = F2_DOC " + ENTER
cQry += "		AND	C5_SERIE = F2_SERIE " + ENTER*/
cQry += "INNER JOIN " + ENTER
cQry += "	" + RetSqlName("SA4") + " SA4 " + ENTER
cQry += "		ON	SA4.D_E_L_E_T_ = '' " + ENTER
cQry += "		AND	SA4.A4_FILIAL = '' " + ENTER
cQry += "		AND SA4.A4_COD = F2_TRANSP " + ENTER	//C5_TRANSP
cQry += "WHERE " + ENTER
cQry += "	SZG.D_E_L_E_T_ = '' " + ENTER
cQry += "	AND ZG_NUM = '" + cCarga + "' " + ENTER
cQry += "	AND	ZG_FILIAL = '" + IIf( AllTrim(cFilAnt) $ "0107#0108", xFilial("SZG"), "" ) + "' " + ENTER
cQry += "	AND LEFT(ZG_EMPFIL,2) = '01' " + ENTER                                            
cQry += "ORDER BY " + ENTER
cQry += "	KM0, " + ENTER
cQry += "	TM0 " + ENTER

MemoWrite("FATR068.SQL", cQry)  

If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS QRY

dbSelectArea("QRY")             

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Guarda total de registros retornado pela query                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Count To nRec
                                                                         
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Calcula total de paginas                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//nTotPag := Ceiling( nRec/6 )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ajusta tamanho da regua                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SetRegua(nRec * 2)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Posiciona no primeiro registro do arquivo                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

For nX := 1 to 2

	nDet := 1
	
	QRY->(dbGoTop())
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Processa relatorio                                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	While !Eof()               
	
		// Aborta o Processamento 
		If lEnd
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif   
		
		// Salto de Pagina    
		If nDet == 1
			fCabec()
			dbSelectArea("QRY")
		EndIf   
		
		// Imprime os Detalhes
		FmtLin({QRY->NOTA, AllTrim(QRY->EMISSAO), fIDEmpresa( QRY->EMPFIL )},aL[08],,,@nLin)   
		FmtLin({TransForm(QRY->PESO,"@E 999,999.99"), "R$ " + TransForm(QRY->VALOR, "@E 999,999.99")},aL[09],,,@nLin)   
		FmtLin({AllTrim(QRY->VOLUME)},aL[10],,,@nLin)   
	//	FmtLin({AllTrim(QRY->CLIFOR)},aL[11],,,@nLin)   
		FmtLin({AllTrim(QRY->REDESP)},aL[12],,,@nLin)   
		FmtLin({AllTrim(QRY->END1)},aL[13],,,@nLin)   
		FmtLin({AllTrim(QRY->END2)},aL[14],,,@nLin)   
		FmtLin({AllTrim(QRY->INSTRUCAO)},aL[15],,,@nLin)   
		FmtLin({"DISTANCIA: " +  cValToChar(QRY->KMX) + " KM " + Space(5) + "TEMPO: " + StrTran(Transform(QRY->TMX,"@D 999.99"),".",":") },aL[16],,,@nLin)   
	
	
		// Proximo Registro
		dbSkip()
		
		// Imprime separador de registro ou pagina
		If !EoF() 
		
			If nDet < 5 			// Retirado para imprimir um registro por pแgina 22/06/17
				// Separador de Registro
				FmtLin(,aL[17],,,@nLin)   
	
				// Atualiza contador de registro
				nDet++
			Else  
				// Separador de Pagina
				FmtLin(,aL[43],,,@nLin)   
				FmtLin(,aL[44],,,@nLin)   
				FmtLin(,aL[45],,,@nLin)   
			
				// Reinicializa contador de registro
				nDet := 1
			EndIf
	
		EndIf
	EndDo        
	
	// Aborta o Processamento 
	If lEnd
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Return
	Endif   
	
	// Separador de Pagina - Adicionado 23/06/17
		FmtLin(,aL[43],,,@nLin)   
		FmtLin(,aL[44],,,@nLin)   
		FmtLin(,aL[45],,,@nLin)  
	
	// Salto de Pagina    
	If nDet > 3
		fCabec()
		dbSelectArea("QRY")
	EndIf  //Retirado para imprimir um registro por pแgina 22/06/17      
	
	// Total    
	FmtLin(,aL[18],,,@nLin)   
	FmtLin(,aL[19],,,@nLin)   
	FmtLin(,aL[20],,,@nLin)    //Retirado para imprimir um registro por pแgina 22/06/17
	
	dbSelectArea("SZF")
	dbSetOrder(1)
	dbSeek( xFilial("SZF") + cCarga )                   
	
	dbSelectArea("DA3")
	dbSetOrder(3)
	dbSeek( xFilial("DA3") + SZF->ZF_VEICULO )   
	
	nApvFrete := Round((( (SZF->ZF_FRETEP + SZF->ZF_ACREFRT - SZF->ZF_DESCFRT) / SZF->ZF_VALOR ) * 100 ), 2)
	nApvCarga := Round((( SZF->ZF_PESO / DA3->DA3_CAPACM ) * 100 ), 2)                
	
	FmtLin({"R$ " + TransForm(SZF->ZF_VALOR, "@E 999,999.99"), AllTrim(SZF->ZF_VOLUME)},aL[21],,,@nLin)
	FmtLin({"R$ " + TransForm((SZF->ZF_FRETEP + SZF->ZF_ACREFRT - SZF->ZF_DESCFRT), "@E 999,999.99"), TransForm(nApvFrete, "@E 999,999.99")+"%"},aL[22],,,@nLin)   
	FmtLin({TransForm(SZF->ZF_PESO, "@E 999,999.99"), TransForm(nApvCarga, "@E 999,999.99")+"%"},aL[23],,,@nLin)   
	
	// Observacao
	FmtLin(,aL[24],,,@nLin)   
	FmtLin(,aL[25],,,@nLin)   
	//,FmtLin(,aL[26],,,@nLin)   
	
	// Mensagem
	FmtLin(,aL[27],,,@nLin)   
	FmtLin(,aL[28],,,@nLin)   
	FmtLin(,aL[29],,,@nLin)   
	
	// Termo de Responsabilidade
	FmtLin(,aL[30],,,@nLin)   
	FmtLin(,aL[31],,,@nLin)   
	FmtLin(,aL[32],,,@nLin)   
	FmtLin(,aL[33],,,@nLin)   
	FmtLin(,aL[34],,,@nLin)   
	
	// Assinatura   
	FmtLin(,aL[35],,,@nLin)   
	FmtLin(,aL[36],,,@nLin)
	FmtLin(,aL[37],,,@nLin)   
	FmtLin(,aL[38],,,@nLin)   
	FmtLin(,aL[39],,,@nLin)   
	FmtLin(,aL[40],,,@nLin)   
	FmtLin(,aL[41],,,@nLin)   
	FmtLin(,aL[42],,,@nLin)   
	FmtLin(,aL[43],,,@nLin)   
	                                                             
Next nX
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fecha arquivo temporario                                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
QRY->(dbCloseArea())

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Apresenta relatorio na tela                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()     
    
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Restaura area anterior                                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Restarea( aArea )
Restarea( aAreaSZF )
Restarea( aAreaDA3 )

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ P8LayOut()   ณAutor ณ Juan Jose Pereira    ณDataณ 12/12/96 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Armazena lay-out para o modelo P8                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ MATP8                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fLayout()
Local aL:={}

//CABECALHO PADRAO
Aadd(aL,"+----------------------------------------------------------------------------------------------------------------------------------+") // [01]
Aadd(aL,"| DATA..: ##########                                  ROMANEIO DE EXPEDICAO                                    PAGINA: ##########  |") // [02]
Aadd(aL,"| HORA..: ##########                                         #a. Via                                           CARGA.: ##########  |") // [03]
Aadd(aL,"|==================================================================================================================================|") // [04]
Aadd(aL,"| TRANSPORTADORA: ################################################################################################################ |") // [05]
Aadd(aL,"| VEICULO.......: ############################################### CAPACIDADE....: ################################################ |") // [06]
// ITENS
Aadd(aL,"|==================================================================================================================================|") // [07]
Aadd(aL,"| NOTA FISCAL...: ##############        EMISSAO.......: ##############         | RECEBI DA ####################################### |") // [08]
Aadd(aL,"| PESO BRUTO....: ##############        VR MERCADORIA.: ##############         | OS PRODUTOS CONSTANTES NA NOTA FISCAL AO LADO.    |") // [09]
Aadd(aL,"| VOLUME(S).....: ############################################################ |                                                   |") // [10]
Aadd(aL,"|                                                                              |  _______________________________________________  |") // [11]
Aadd(aL,"| REDESPACHO....: ############################################################ |                                                   |") // [12]
Aadd(aL,"| ENDERECO......: ############################################################ |  NOME: _________________________________________  |") // [13]
Aadd(aL,"|                 ############################################################ |                                                   |") // [14]
Aadd(aL,"| INSTR. ENTREGA: ############################################################ |  DATA: ____/____/____            HORA: ____:____  |") // [15]
Aadd(aL,"| ROTA (GOOGLE).: ############################################################ |                                                   |") // [16]
Aadd(aL,"|----------------------------------------------------------------------------------------------------------------------------------|") // [17]
// TOTAL
Aadd(aL,"|==================================================================================================================================|") // [18]
Aadd(aL,"|                                                     T O T A  L                                                                   |") // [19]
Aadd(aL,"|==================================================================================================================================|") // [20]
Aadd(aL,"|                 VALOR CARGA.: #################   VOLUME(S).....: ############################################################## |") // [21]
Aadd(aL,"|                 VALOR FRETE.: #################   APROV FRETE...: #################                                              |") // [22]
Aadd(aL,"|                 PESO  CARGA.: #################   APROV PESO....: #################                                              |") // [23]
// OBSERVACAO
Aadd(aL,"|==================================================================================================================================|") // [24]
Aadd(aL,"| OBSERVACAO....:                                                                                                                  |") // [25]
Aadd(aL,"|                                                                                                                                  |") // [26]
// MENSAGEM
Aadd(aL,"|----------------------------------------------------------------------------------------------------------------------------------|") // [27]
Aadd(aL,"| ATENCAO.......: NAO EFETUAREMOS PAGAMENTOS SEM A APRESENTACAO DESTE RELATORIO E OS RESPECTIVOS COMPROVANTES DE ENTREGA, ASSIM    |") // [28]     
AADD(AL,"|                 COMO RESSARCIR A EMPRESA POR DANOS OU EXTRAVIO QUE ACARRETAREM PERDA TOTAL OU PARCIAL DO BEM.                    |") // [29]
// TERMO DE RESPONSABILIDADE
Aadd(aL,"|----------------------------------------------------------------------------------------------------------------------------------|") // [30]
Aadd(aL,"| DECLARO.......: A) TER RECEBIDO AS MERCADORIAS EM ORDEM E CONFERIDAS.                                                            |") // [31]
Aadd(aL,"|                 B) TER RECEBIDO OS DEVIDOS ENVELOPES CONTENDO AS RESPECTIVAS FICHAS DE EMERGENCIA ANEXAS AS NOTAS FISCAIS.       |") // [32]
Aadd(aL,"|                 C) TRANSPORTAR OS PRODUTOS EM VEICULOS EM PERFEITAS CONDICOES DE MANUTENCAO E QUE ATENDEM A LEGISLACAO DE        |") // [33]
Aadd(aL,"|                    TRANSPORTES DE PRODUTOS PERIGOSOS.                                                                            |") // [34]
// ASSINATURA
Aadd(aL,"|----------------------------------------------------------------------------------------------------------------------------------|") // [35]
Aadd(aL,"|  E X P E D I C A O                C A R R E G A M E N T O          M O T O R I S T A                P O R T A R I A              |") // [36]
Aadd(aL,"|                                                                                                                                  |") // [37]
Aadd(aL,"| _________________________        _________________________        _________________________        _________________________     |") // [38]
Aadd(aL,"|                                                                                                                                  |") // [39]
Aadd(aL,"| NOME ____________________        NOME ____________________        NOME ____________________        NOME ____________________     |") // [40]
Aadd(aL,"|                                                                                                                                  |") // [41]
Aadd(aL,"| DATA  ____/____/____             DATA  ___/___/____               DATA  ___/___/____               DATA  ___/___/____            |") // [42]
Aadd(aL,"|==================================================================================================================================|") // [43]
Aadd(aL,"| C O N T I N U A ........                                                                                                         |") // [44]
Aadd(aL,"|==================================================================================================================================|") // [45]
//       123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x
//                10        20        30        40        50        60        70        80        90        100       110       120       30
Return(aL)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ P8LayOut()   ณAutor ณ Juan Jose Pereira    ณDataณ 12/12/96 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Armazena lay-out para o modelo P8                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ MATP8                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fCabec()
Local aArea		:= GetArea()
Local aAreaSZF	:= SZF->( GetArea() )
Local aAreaDA3	:= DA3->( GetArea() )
Local aAreaSA4  := SA4->( GetArea() )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza contador de linhas de impressao                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nlin := 1  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza numero da pagina                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPag := ( nPag + 1 )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Imprime Cabecalho                                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
FmtLin(,aL[01],,,@nLin)
FmtLin({DtoC(dDataBase), Strzero(nPag,3), Strzero(nTotPag,3)},aL[02],,,@nLin)
FmtLin({Time(), StrZero(nX,1), cCarga},aL[03],,,@nLin)
FmtLin(,aL[04],,,@nLin)

// Posiona registro de carga
dbSelectArea("SZF")
dbSetOrder(1)
dbSeek( xFilial("SZF") + cCarga )

// Posiona registro de veiculo
dbSelectArea("DA3")
dbSetOrder(3)
dbSeek( xFilial("DA3") + SZF->ZF_VEICULO )

// Posiona registro de transportadora       
dbSelectArea("SA4")
dbSetOrder(1)
dbSeek( xFilial("SA4") + DA3->DA3_TRANSP )

FmtLin({"(" + SA4->A4_COD + ") " + AllTrim(SA4->A4_NOME)  },aL[05],,,@nLin)
FmtLin({AllTrim(DA3->DA3_PLACA), TransForm(DA3->DA3_CAPACM,"@E 999,999.99")},aL[06],,,@nLin)
FmtLin(,aL[07],,,@nLin)    

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Restaura area anterior                                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Restarea( aArea )
Restarea( aAreaSZF )
Restarea( aAreaDA3 )
Restarea( aAreaSA4 )

Return            



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfIDEMPRESAบAutor  ณAlexandre Marson    บ Data ณ  29/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณDevolve nome da empresa referente a nota fiscal             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fIDEmpresa( cID )
Local cRet := ""         

Do Case

	Case AllTrim(cID) == "0107"
		cRet := "JAYS TINTAS E TEXTURAS LTDA"

	Case AllTrim(cID) == "0108"
		cRet := "QUALYCOR COMERCIAL LTDA"

	Case AllTrim(cID) == "0111"
		cRet := "MACRO CORES TINTAS E TEXTURAS LTDA"

	Case AllTrim(cID) $ "0200#0201#0204#0205"
		cRet := "EUROAMERICAN DO BRASIL IMP IND E COM LTD"
		
	Case AllTrim(cID) $ "0203#0301#0303#0304"
		cRet := "QUALY/COMERCIAL LTDA"
	
	Case AllTrim(cID) $ "0801"
		cRet := "MULTICORES INDฺSTRIA E COMษRCIO DE TINTAS LTDA"
	Case AllTrim(cID) $ "0901"
		cRet := "PHOENIX QUIMICA LTDA"

	Otherwise
		cRet := ""                                   
EndCase

Return cRet   
