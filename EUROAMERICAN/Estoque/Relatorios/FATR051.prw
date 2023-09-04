#include "protheus.ch"
#include "topconn.ch"        
#include "tbiconn.ch"   
#include "rwmake.ch"    

#define ENTER chr(13) + chr(10)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FATR051   º Autor ³Tiago O Beraldi     º Data ³ 08/08/11    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³REQUISICAO DE PRODUTOS - JAYS TINTAS                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFAT                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                     A L T E R A C O E S                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ºProgramador       ºAlteracoes                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º 16-04-12 º ALEXANDRE MARSON º ATENDIMENTO DA SOLICITACAO NRO 011841   º±±
±±º          º                  º                                         º±±
±±º          º                  º                                         º±±
±±º          º                  º                                         º±±
±±º          º                  º                                         º±±
±±º          º                  º                                         º±±
±±º          º                  º                                         º±±
±±º          º                  º                                         º±±
±±º          º                  º                                         º±±
±±º          º                  º                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FATR051()  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Requisição de Produtos"
Local cPict          := ""
Local titulo         := "Requisição de Produtos"

Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd 		     := {}        

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "FATR051"
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "FATR051"
Private	cPerg        := "FATR051"
Private cString		 := "SF2"

dbSelectArea("SF2")
dbSetOrder(1)   
                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria parametros SX1                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fCriaSX1(cPerg)
Pergunte(cPerg, .F.)   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza os parametros com o ultimo numero da requisicao existente  ³
//³ conforme chamado Nro 011841                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MV_PAR01 := GetSXENum("SF2", "F2_DOC")
MV_PAR02 := GetSXENum("SF2", "F2_DOC")


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  08/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo)

Local nOrdem          

Private nLin         := 1        
Private cPag         := "001"

dbSelectArea("SF2")
dbSetOrder(1) 
dbSeek(xFilial("SF2") + mv_par01 + "REQ")

SetRegua(RecCount())  

cNF := SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE

While !SF2->(EOF()) .And. SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE <= xFilial("SF2") + mv_par02 + "REQ"
     
	IncRegua()

	//Filtra Notas Fiscais
	If SF2->F2_SERIE != "REQ"
		SF2->(dbSkip())
		Loop
	EndIf        
	
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica o cancelamento pelo usuario...                             ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao do cabecalho do relatorio. . .                            ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If nLin > 55 .Or. cNF != SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE// Salto de Pagina
      nLin := 1         
      cNF  := SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE
   Endif                        
   
	SA1->(dbSetOrder(1))
    SA1->(dbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA))

	SA3->(dbSetOrder(1))
    SA3->(dbSeek(xFilial("SA3") + SF2->F2_VEND1))
    	
  	SC5->(dbSetOrder(8))                     
    SC5->(dbSeek(xFilial("SC5") + SF2->F2_DOC + SF2->F2_SERIE))

  	SE4->(dbSetOrder(1))                     
    SE4->(dbSeek(xFilial("SE4") + SC5->C5_CONDPAG))
    
	fCabec()
			
	SD2->(dbSetOrder(3))
	SD2->(dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE))
	
	cNota   := SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE
	nTotBrt := 0           
	cQry    := " SELECT	D2_COD CODIGO, " + ENTER
	cQry    += " 		B1_DESC + '-' + B1_UM DESCR, " + ENTER
	cQry    += " 		D2_QUANT QUANT, " + ENTER
	cQry    += " 		D2_TES TES, " + ENTER
	//cQry    += " 		D2_PRCVEN / (1 - (SELECT C6_DESCON FROM SC6010 WHERE D_E_L_E_T_ = '' AND C6_FILIAL = '" + SF2->F2_FILIAL + "' AND D2_PEDIDO + D2_ITEMPV + D2_COD = C6_NUM + C6_ITEM + C6_PRODUTO)/100) PRCVEN, " + ENTER	
	cQry    += " 		D2_PRCVEN PRCVEN, " + ENTER	
	//cQry    += " 		(SELECT C6_DESCON FROM SC6010 WHERE D_E_L_E_T_ = '' AND C6_FILIAL = '" + SF2->F2_FILIAL + "' AND D2_PEDIDO + D2_ITEMPV + D2_COD = C6_NUM + C6_ITEM + C6_PRODUTO) DESCON, " + ENTER
	cQry    += " 		0 DESCON, " + ENTER
	cQry    += " 		D2_TOTAL VALOR " + ENTER
	cQry    += " FROM	" + RetSqlName("SD2") + " SD2, " + RetSqlName("SB1") + " SB1 " + ENTER
	cQry    += " WHERE	SD2.D_E_L_E_T_ = ''" + ENTER
	cQry    += " 		AND SB1.D_E_L_E_T_ = '' " + ENTER
	cQry    += " 		AND B1_COD = D2_COD " + ENTER
	cQry    += " 		AND D2_FILIAL = '" + SF2->F2_FILIAL + "' " + ENTER
	cQry    += " 		AND D2_DOC = '" + SF2->F2_DOC + "' " + ENTER
	cQry    += " 		AND D2_SERIE = '" + SF2->F2_SERIE + "' " + ENTER
	cQry    += " ORDER BY B1_UM, CODIGO " + ENTER		
	
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf
	
	TCQUERY cQry NEW ALIAS QRY
	
	QRY->(dbGoTop())
		
	While !QRY->(EOF()) 
	
		@nLin,00 PSAY PadR(QRY->CODIGO, 17) + Space(1) +;
		              PadR(QRY->DESCR, 44) + Space(1) +;
		              PadL(Transform(QRY->QUANT, "@E 999,999,999.99"), 15) + Space(1) +;
		              PadL(Transform(QRY->PRCVEN, "@E 999,999,999.99"), 16) + Space(1) +;
		              PadL(Transform(QRY->DESCON, "@E 999,999,999.99") + "%", 15) + Space(1) +;
		              PadL(Transform(QRY->VALOR, "@E 999,999,999.99"), 21) 
		              
		              nTotBrt += QRY->PRCVEN * QRY->QUANT
	
		nLin += 1      
		
		If nLin > 55
			@nLin,00 PSAY "======================================================================================================================================"
			nLin := 1         
			fCabec()                                      
		EndIf
		
		cTes := QRY->TES
			              		              		              	                      
		QRY->(dbSkip())
		
	EndDo 
	
	QRY->(dbCloseArea())
	
	@nLin,00 PSAY "======================================================================================================================================"
	nLin += 1
	@nLin,00 PSAY "OPERACAO: " + Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_TEXTO") 
	nLin += 1
	@nLin,00 PSAY "======================================================================================================================================"
	nLin += 1
	@nLin,00 PSAY "SubTotal....:                  R$ " + Transform(nTotBrt, "@E 999,999,999.99")
	nLin += 1
	@nLin,00 PSAY "Desconto....:                  R$ " + Transform(nTotBrt - SF2->F2_VALMERC, "@E 999,999,999.99")
	nLin += 1
	@nLin,00 PSAY "Total.......:                  R$ " + Transform(SF2->F2_VALMERC, "@E 999,999,999.99") + Space(10) + "  ASS. CLIENTE: _________________________________________"
	nLin += 1
	@nLin,00 PSAY "======================================================================================================================================"
	nLin += 1    
	
	SF2->(dbSkip())
	
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FCRIASX1  º Autor ³Tiago O Beraldi     º Data ³  08/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³GERA DICIONARIO DE PERGUNTAS                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                     A L T E R A C O E S                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ºProgramador       ºAlteracoes                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fCriaSX1(cPerg)

Local cKey := ""
Local aHelpEng := {}
Local aHelpPor := {}
Local aHelpSpa := {}
                    
PutSX1(cPerg,"01","De Requisicao      ?","","","mv_ch1","C",09,0,0,"G","",""   ,"","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"02","Até Requisicao     ?","","","mv_ch2","C",09,0,0,"G","",""   ,"","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"03","Tipo da NF          ","","","mv_ch3","N",01,0,0,"C","",""   ,"","","mv_par03","REQ Saida","","","","REQ Entrada","","","","","","","","","","","","","","","","","","")

cKey     := "P." + cPerg + "01."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe a Requisição Inicial.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P." + cPerg + "02."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe a Requisição Final.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

Return    


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FCABEC    º Autor ³Tiago O Beraldi     º Data ³  08/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³GERA DICIONARIO DE PERGUNTAS                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                     A L T E R A C O E S                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ºProgramador       ºAlteracoes                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fCabec()

@nLin,00 PSAY chr(27)+chr(15)
@nLin,00 PSAY "======================================================================================================================================"
nLin += 1
@nLin,00 PSAY "                                                      REQUISICAO DE PRODUTOS                                                          "
nLin += 1
If(Left(cFilAnt,2)$"01")
	@nLin,00 PSAY "                                             Jays Tintas Ltda - Rua Antonio Milena, 1266                                              "
EndIf
nLin += 1
If(Left(cFilAnt,2)$"01")
	@nLin,00 PSAY "                                                         Fone: (16)3996-6330                                                          "
EndIf
nLin += 1
@nLin,00 PSAY "                                            Doc.:" + SF2->F2_DOC + " - Emissao: " + DtoC(SF2->F2_EMISSAO) + " - Pagina: " + cPag
nLin += 1
@nLin,00 PSAY "======================================================================================================================================"
nLin += 1
@nLin,00 PSAY "CLIENTE: " + SA1->A1_COD + "-" + AllTrim(SA1->A1_NOME) + Space(10) + " TELEFONE: (" + AllTrim(SA1->A1_DDD) + ")" + SA1->A1_TEL
nLin += 1
@nLin,00 PSAY "ENDERECO: " + AllTrim(SA1->A1_END) + Space(10) + "  BAIRRO: " + SA1->A1_BAIRRO
nLin += 1
@nLin,00 PSAY "CIDADE: " + SA1->A1_MUN + " ESTADO: " + SA1->A1_EST + Space(10) + " CEP: " + SA1->A1_CEP
nLin += 1
@nLin,00 PSAY "CNPJ: " + Transform(SA1->A1_CGC, "@R 99.999.999/9999-99") + Space(10) + " I.E.: " + SA1->A1_INSCR
nLin += 1
@nLin,00 PSAY "VENDEDOR: " + SF2->F2_VEND1 + "-" + AllTrim(SA3->A3_NOME)
nLin += 1
@nLin,00 PSAY "OBS: " + SC5->C5_OBS
nLin += 1
//@nLin,00 PSAY "PESO BRUTO: " + Transform(SC5->C5_PESOL, "@E 999,999.99") + " PESO LIQ.: " + Transform(SC5->C5_PBRUTO, "@E 999,999.99") + "  VOLUMES: " + Transform(SF2->F2_VOLUME1, "@E 999") + "-" + AllTrim(SF2->F2_ESPECI1) + " / " + Transform(SF2->F2_VOLUME2, "@E 999") + "-" + AllTrim(SF2->F2_ESPECI2) + " / " + Transform(SF2->F2_VOLUME3, "@E 999") + "-" + AllTrim(SF2->F2_ESPECI3) + " / " + Transform(SF2->F2_VOLUME4, "@E 999") + "-" + AllTrim(SF2->F2_ESPECI4)
@nLin,00 PSAY "PESO BRUTO: " + Transform(SF2->F2_PLIQUI, "@E 999,999.99") + " PESO LIQ.: " + Transform(SF2->F2_PBRUTO, "@E 999,999.99") + "  VOLUMES: " + Transform(SF2->F2_VOLUME1, "@E 999") + "-" + AllTrim(SF2->F2_ESPECI1) + " / " + Transform(SF2->F2_VOLUME2, "@E 999") + "-" + AllTrim(SF2->F2_ESPECI2) + " / " + Transform(SF2->F2_VOLUME3, "@E 999") + "-" + AllTrim(SF2->F2_ESPECI3) + " / " + Transform(SF2->F2_VOLUME4, "@E 999") + "-" + AllTrim(SF2->F2_ESPECI4)
nLin += 1
@nLin,00 PSAY "CONDICAO PAGTO.: " + SE4->E4_DESCRI
nLin += 1
@nLin,00 PSAY "======================================================================================================================================"
nLin += 1

SE1->(dbSetOrder(1))
SE1->(dbSeek(xFilial("SE1") + SF2->F2_SERIE + SF2->F2_DOC))

cNota := SF2->F2_FILIAL + SF2->F2_SERIE + SF2->F2_DOC

While !SE1->(EOF()) .And. cNota == SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM
	
	/*cTipo := Iif(SC5->C5_TIPOPAG == "1", "Boleto",;
	Iif(SC5->C5_TIPOPAG == "2", "Cheque a Vista",;
	Iif(SC5->C5_TIPOPAG == "3", "Cheque Pre-Datado",;
	Iif(SC5->C5_TIPOPAG == "4", "Dinheiro", ""))))
	*/
	cTipo := "A vista"
	
	@nLin,00 PSAY cTipo + " - R$ " + AllTrim(Transform(SE1->E1_VALOR, "@E 999,999,999.99")) + " - " + DtoC(SE1->E1_VENCTO)
	nLin += 1
	
	SE1->(dbSkip())
EndDo

@nLin,00 PSAY "======================================================================================================================================"
nLin += 1
@nLin,00 PSAY "[   Codigo      ] [                Descricao                 ] [    Qtde.    ] [   Vl.Unit.   ] [    Desc.%   ] [       Valor       ] "
nLin += 1
@nLin,00 PSAY "======================================================================================================================================"
nLin += 1

Return