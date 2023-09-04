#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#include "protheus.ch"

#define ENTER chr(13) + chr(10)

User Function MT100LOK()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//| Declaracao de variaveis                                             ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?

Local aArea	   := GetArea()
Local aAreaSF4 := SF4->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSC7 := SC7->(GetArea())
Local aAreaSA2 := SA2->(GetArea())

Local nPosTes := aScan(aHeader, {|x| "D1_TES"		$ x[2]})
Local nPosPed := aScan(aHeader, {|x| "D1_PEDIDO"	$ x[2]})
Local nPosItm := aScan(aHeader, {|x| "D1_ITEMPC"	$ x[2]})
Local nPosNfo := aScan(aHeader, {|x| "D1_NFORI"		$ x[2]})
Local nPosSro := aScan(aHeader, {|x| "D1_SERIORI"	$ x[2]})
Local nPosIto := aScan(aHeader, {|x| "D1_ITEMORI"	$ x[2]})
Local nPosCC  := aScan(aHeader, {|x| "D1_CC"		$ x[2]})
Local nPosObs := aScan(aHeader, {|x| "D1_OBSERV"	$ x[2]})
Local nPosPrd := aScan(aHeader, {|x| "D1_COD"		$ x[2]})
Local nPosLcl := aScan(aHeader, {|x| "D1_LOCAL"		$ x[2]})
Local nPosLot := aScan(aHeader, {|x| "D1_LOTECTL"	$ x[2]})
Local nPosVlr := aScan(aHeader, {|x| "D1_TOTAL"		$ x[2]})
Local nObserv := aScan(aHeader, {|x| "D1_OBSERV"	$ x[2]})
Local nPosRat := aScan(aHeader, {|x| "D1_RATEIO"	$ x[2]})  //Adicionado 05/09/2016
Local nPosLtF := aScan(aHeader, {|x| "D1_LOTEFOR"	$ X[2]})  //Adicionado 09/03/2018
Local nPosFor := aScan(aHeader, {|x| "D1_FORNECE"	$ X[2]})

Local cCICPath	:= "\\srv-004\pub\utils\tools\CICMsg.exe srv-004 workflow 123456"
Local cCICMsg	:= ""
Local cCICUsers	:= "ADMINISTRATOR"

Local lRet    := .T.
Local cQry    := ""


// ============================================================
//  Grupo Empresa - Ajuste realizado em 31.08.20 (CG)
// ============================================================

// cEmpAnt (Substituido por cFilAnt)


BEGIN SEQUENCE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//| Posiciona arquivos                                                  ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
SF4->(dbSetOrder(1))
SF4->(dbSeek(xFilial("SF4") + aCols[n, nPosTes]))

SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1") + aCols[n, nPosPrd]))

SC7->(dbSetOrder(1))
SC7->(dbSeek(xFilial("SC7") + aCols[n, nPosPed] + aCols[n, nPosItm]))

SA2->(dbSetOrder(1))
SA2->(dbSeek(xFilial("SA2") + cA100For + cLoja))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//| Empresa Qualycor / jays / Macrocores Excluida                       ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If (Left(cFilAnt,2) == "01" .And. cFilAnt $ "07#08#11")
	lRet := .T.
	Break
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//| Outras validacoes                                                   ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If !(aCols[n][Len(aHeader) + 1]) // Linha Deletada
	
	Do Case
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//| Regras aplicadas para notas tipo [D]EVOLUCAO                        ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		Case cTipo == "D"
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//| Regras aplicadas para notas tipo [N]ORMAL / [B]ENEFICIAMENTO        ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		Case cTipo $ "N#B"  .And. !cA100For $ "016442" //Ignora fornecedor Qualycril
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//| Verifica associacao de pedido de compra                             ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			If SF4->( Found() )
				If SF4->F4_CODIGO $ Alltrim(GetMV("MV_TESPCNF"))  //"101|125|126|127|128"  //nf de servico nao precisa de PC   (TRATAR CODIGO DE TES É NOJENTO VIU PROGRAMADOR!!!)
					lRet := .T.
					Break
					
					//ElseIf SF4->F4_CODIGO $ "147/148/210"	//Regra Compra e Ordem / Conta e Ordem
				ElseIf AllTrim( SF4->F4_CF ) $ "1923/2923/3923"	//Regra Compra e Ordem / Conta e Ordem
					
					cQry := " SELECT D1_DOC AS NFORIG FROM " + RetSqlName("SD1") + " SD1 " + ENTER
					//cQry += " WHERE SD1.D_E_L_E_T_ = '' AND SD1.D1_FILIAL = '"+ xFilial("SD1") + "' AND SD1.D1_TES IN ('066','099','143','144','145','146','205','206','211','308','412') AND SD1.D1_DOC = '" + AllTrim(aCols[n, nObserv]) + "' " + ENTER
					cQry += " WHERE SD1.D_E_L_E_T_ = '' AND SD1.D1_FILIAL = '"+ xFilial("SD1") + "' AND SD1.D1_CF IN ('1120','1551','2120','2551','3120','3551') AND SD1.D1_DOC = '" + AllTrim(aCols[n, nObserv]) + "' " + ENTER
					
					If Select("QRY1") > 0
						QRY1->(dbCloseArea())
					EndIf
					
					TCQUERY cQry NEW ALIAS QRY1
					dbSelectArea("QRY1")
					
					If  ! ( QRY1->NFORIG $ AllTrim(aCols[n, nObserv]) )
						MsgStop("Item compra/venda ordem, necess?io informar NF de remessa no campo observação!")
						lRet := .F.
						Break
					EndIf
					
				ElseIf SF4->F4_CODIGO $ "355"
					//355 Entrada p/ abatimento Financeiro
					
				ElseIf SF4->F4_ESTOQUE == "S" .And. AllTrim(aCols[n, nPosPrd]) $ "ME.0139" .And.  SF4->F4_CODIGO $ "198"
					//Excessão para entrada sem lote
					
				ElseIf SF4->F4_ESTOQUE == "S" .And. ( !(AllTrim(aCols[n, nPosPrd]) $ "XC503244#ME.0241#ME.0044#XC702537#XC702535#XC702534#XC700021#XC700011#XC700010#XC501484#XC100022") .Or. SF4->F4_CODIGO $ "061#177#192" ) .And. Empty(aCols[n,nPosNfo]) .And. Empty(aCols[n,nPosIto]) .And. (Empty(aCols[n, nPosPed]) .Or. Empty(aCols[n, nPosItm]))
					MsgStop("Item sem pedido de compra associado!")
					lRet := .F.
					Break
					
				ElseIf SF4->F4_ESTOQUE == "S" .And. Subs(aCols[n, nPosPrd],1,3)$"ME.#MP." .And. !(AllTrim(aCols[n, nPosPrd]) $ "ME.0006#ME.0044#ME.0052#ME.0059#ME.0060#ME.0061#ME.0085#ME.0086#ME.0116#ME.0117#ME.0118#ME.0122#ME.0123#ME.0160#ME.0236#ME.0304#ME.0313#ME.0317#ME.0319#ME.0322#ME.0323#ME.0324#ME.0328#ME.0329#ME.0340#ME.0349#ME.0350#ME.0353#ME.0382#ME.0383#ME.0390#ME.0391#ME.0392#ME.0393#ME.0394#ME.0395#ME.0527#ME.0541#ME.0550#ME.0551#ME.0557#ME.0559#ME.0560#ME.0583#ME.0602#XC100262" ) .And. Empty(aCols[n, nPosLtF]) .And. !SF4->F4_CODIGO $ "169#093"	//Adicionado 09/03/2018
					MsgStop("Item sem lote do Fornecedor lançado!")
					lRet := .F.
					Break
					
				ElseIf SF4->F4_CODIGO $ "309"
					cQry := " SELECT D1_DOC AS NFORIG FROM " + RetSqlName("SD1") + " SD1 " + ENTER
					cQry += " WHERE SD1.D_E_L_E_T_ = '' AND SD1.D1_FILIAL = '"+ xFilial("SD1") + "' AND SD1.D1_TES IN ('025','043') AND SD1.D1_DOC = '" + AllTrim(aCols[n, nObserv]) + "' " + ENTER
					
					If Select("QRY1") > 0
						QRY1->(dbCloseArea())
					EndIf
					
					TCQUERY cQry NEW ALIAS QRY1
					dbSelectArea("QRY1")
					
					If  ! ( QRY1->NFORIG $ AllTrim(aCols[n, nObserv]) )
						MsgStop("Item consignação de venda, necess?io informar NF de remessa no campo observação!")
						lRet := .F.
						Break
					EndIf
					
				ElseIf ( SF4->F4_DUPLIC == "S" ) .And. (Empty(aCols[n, nPosPed]) .Or. Empty(aCols[n, nPosItm])) .And. !(SF4->F4_CODIGO $ "013" .And. AllTrim(aCols[n, nPosPrd]) $ "XS300169") //Adicionado: 01/09/2016
					MsgStop("Item sem pedido de compra associado!")
					lRet := .F.
					Break
				EndIf
				
			Else
				MsgStop("Item sem pedido de compra associado!")
				lRet := .F.
				Break
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//| Verifica se data de chegada ?a prevista no pedido de compra        ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			If .Not. Empty(aCols[n, nPosPed])
				
				If .Not. SC7->( Found() )
					MsgStop("Pedido de compra nao encontrado!")
					lRet := .F.
					Break
				EndIf
				
				If ( Abs(dDEmissao - SC7->C7_DATPRF) > 3 )
					
					cCICMsg := '"(Workflow) ENTRADA DE NOTA DIFERENTE DO PREVISTO' + ENTER
					cCICMsg += 'Usuario......: ' + Upper( AllTrim(cUserName) ) + ENTER
					cCICMsg += 'Dt Entrada...: ' + DtoC( dDEmissao ) + ENTER
					cCICMsg += 'Dt Previsao..: ' + DtoC( SC7->C7_DATPRF ) + ENTER
					cCICMsg += 'Material.....: ' + RTrim( SB1->B1_COD ) + "-" + RTrim(SB1->B1_DESC) + ENTER
					cCICMsg += 'Valor........: ' + Transform( aCols[n, nPosVlr], "@E 999,999,999.99") + ENTER
					cCICMsg += 'Fornecedor...: ' + SA2->A2_COD + "-" + SA2->A2_LOJA + Space(1) + RTRIM(SA2->A2_NOME) + ENTER
					cCICMsg += 'Empresa......: ' + Left(cFilAnt,2) + Space(1) + Right(cFilAnt,2) + ENTER
					
					//WinExec(cCICPath + Space(1) + cCICUsers + Space(1) + cCICMsg, 0)

				EndIf
			EndIf
			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//| Verifica Preenchimento na Solicitacao de Compra                     ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			If !(SB1->B1_TIPO $ "PA#PI#MP#ME#BN#PR") .And. ( Empty(aCols[n, nPosCC]) .And. aCols[n, nPosRat] <> "1" ) .And. !(AllTrim(aCols[n, nPosTes]) $ "030" )
				MsgStop("Favor inserir o Centro de Custos e a Observação (Finalidade)!")
				lRet := .F.
				Break
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//| Verifica Preenchimento de Lote para CQ                              ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			If SB1->B1_TIPO $ "PA" .And. Empty(aCols[n, nPosLot]) .And. aCols[n, nPosLcl] == "01"
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
				//| Ignora validacao para PC's onde o fornecedor eh a EURO ( 012145 )   ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
				If ( Left(cFilAnt,2) == "03" .And. cA100For == "012145" ) .Or.;
					( AllTrim(cFilAnt) $ "0200#0203#0204#0205" .And. cA100For == "000001" )
					
					lRet := .T.
					Break
				Else
					MsgStop("Favor inserir o Lote do produto!")
					lRet := .F.
					Break
				EndIf
			EndIf
	EndCase
EndIf

END SEQUENCE

// Fabio - Valida Custos...
//lRet := BeVldCusto()

RestArea(aAreaSC7)
RestArea(aAreaSA2)
RestArea(aAreaSF4)
RestArea(aAreaSB1)
RestArea(aArea)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³BeVldCusto³ Autor³ Fabio F Sousa         ³ Data ³ 05.12.2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Função para avisar o usuário caso o custo do produto com    ³±±
±±³ 		 ³ variação muito maior (50%) em relação ao custo atual.       ³±±
±±³ 		 ³ Não bloqueio pois a decisão de compra maior do custo pode   ³±±
±±³ 		 ³ ser estratético e com consciente.                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function BeVldCusto()

Local aArea     := GetArea()
Local lRetorno  := .T.
Local nPosItem  := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "D1_ITEM"    })
Local nPosProd  := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "D1_COD"     })
Local nPosLocal := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "D1_LOCAL"   })
Local nPosPreco := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "D1_VUNIT"   })
Local nPosTES   := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "D1_TES"     })
Local nPosCfop 	:= aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "D1_CF"      })
Local nPosLot   := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "D1_LOTECTL" })
Local nPosFor   := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "D1_LOTEFOR" })
Local cLocTran  := AllTrim( GetMv( "MV_LOCTRAN",,"30") )
Local cLocCQ    := AllTrim( GetMv( "MV_CQ",,"01") )
Local cProd     := aCols[n,nPosProd]
Local cTES      := aCols[n,nPosTES]
Local cLoteCTL  := aCols[n,nPosLot]
Local cLoteFor  := aCols[n,nPosFor]
Local cCF       := aCols[n,nPosCfop]

If AllTrim( cTipo ) == "D"
	lRetorno := .T.
	Return lRetorno
EndIf

If AllTrim( aCols[n][nPosLocal] ) == AllTrim( cLocTran )
	ApMsgAlert( 'Local informado (' + AllTrim( aCols[n][nPosLocal] ) +') específico para local em trânsito, informar o local de destino do produto!', 'Atenção' )
	lRetorno := .F.
	RestArea( aArea )
	Return lRetorno
EndIf

If Left( AllTrim( aCols[n][nPosCfop] ), 1) <> "3" .And. lRetorno
	dbSelectArea("SF4")
	dbSetOrder(1)
	If SF4->( dbSeek( xFilial("SF4") + aCols[n][nPosTES] ) )
		If AllTrim( SF4->F4_ESTOQUE ) == "S"
			dbSelectArea("SB2")
			dbSetOrder(1)
			
			If SB2->( dbSeek( xFilial("SB2") + Padr( aCols[n][nPosProd], TamSX3("B2_COD")[1]) + Padr( aCols[n][nPosLocal], TamSX3("B2_LOCAL")[1]) ) )
				If SB2->B2_QATU > 0 .And. SB2->B2_CM1 > 0
					If aCols[n][nPosPreco] > (SB2->B2_CM1 * 1.50)
						Aviso("MT100LOK / BeVldCusto",	"Aviso..."  + CRLF + ;
														"Preço Unitário utilizado para o item " + aCols[n][nPosItem] + " Produto: " + aCols[n][nPosProd] + " maior que variação de (50%) Custo Atual do Produto:" + CRLF + ;
														"Custo Atual: " + Transform( SB2->B2_CM1, "@R 999,999,999.99") + CRLF + ;
														"Confirme se não é Erro ou Problema com Unidade de Medida ou Erro na Digitação ou o Custo está Indevido!",{"Ok"},3)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

dbSelectArea("SB1")
dbSetOrder(1)
SB1->( dbSeek( xFilial("SB1") + cProd ) )

dbSelectArea("SF4")
dbSetOrder(1)
SF4->( dbSeek( xFilial("SF4") + cTES ) )

If !(aCols[n][Len(aHeader)+1])
	If aCols[ n, GDFieldPos("D1_QUANT")] == 0 .And. aCols[ n, GDFieldPos("D1_LOCAL")] $ AllTrim( GetMv("MV_CQ",,"01") )
		If AllTrim( SF4->F4_ESTOQUE ) == "S" .And. AllTrim( SF4->F4_TRANSIT ) <> "S"
			ApMsgAlert( "Não é permitido local de CQ 01 para quantidade igual a zero [0.00]!", "Atenção")
			lRetorno := .F.
		EndIf
	EndIf
EndIf

If AllTrim( SB1->B1_TIPO ) == "PA" .And. AllTrim( cTipo ) == "N" .And. AllTrim( SF4->F4_ESTOQUE ) == "S" .And. AllTrim( SF4->F4_DUPLIC ) == "S" .And. cCF $ "1101/1102/2101/2102/3101/3102"
	Aviso( "Atenção", ' Tipo NF = "N" e Tipo Produto = "PA", não Permitido! ' + CHR(10) + CHR(13)+ "==> Verifique...", {"Ok"}, 2)
	lRetorno := .F.
ElseIf AllTrim( SB1->B1_TIPO ) $ "AI/AF" .AND. AllTrim( cTipo ) == "N"
	If SF4->( dbSeek( xFilial("SF4") + cTES ) )
		If AllTrim( SF4->F4_ESTOQUE ) == "S"
			Aviso( "Atenção", 'TES não deve atualizar estoque para Produto Tipo AI', {"Ok"}, 2)
			lRetorno := .F.
		EndIf
	EndIf
Else
	If SF4->( dbSeek( xFilial("SF4") + cTES ) )
		If AllTrim( SF4->F4_ESTOQUE ) == "S"
			If AllTrim( SB1->B1_TIPO ) == "MO" .Or. AllTrim( SB1->B1_TIPO ) == "SV"
				Aviso( "Atenção", 'Produto Tipo MO não deve atualizar estoque, verifique a TES informada!', {"Ok"}, 2)
				lRetorno := .F.
			Else
				dbSelectArea("SYD")
				dbSetOrder(1)
				If !SYD->( dbSeek( xFilial("SYD") + SB1->B1_POSIPI + SB1->B1_EX_NCM + SB1->B1_EX_NBM ) )
					Aviso( "Atenção", 'NCM do produto não cadastrado ou incorreto!', {"Ok"}, 2)
					lRetorno := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea( aArea )

Return lRetorno