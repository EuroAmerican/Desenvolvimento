#INCLUDE "protheus.ch"
#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          ºAutor  ³                    º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada referente a imagem de identificacao do     º±±
±±º          ³produto. Cadastro de Produtos. Padrão Zebra                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function EQImpMP(cProduto,nQE,nCopias,nResto,cLote,dDtFabr,dDtValid,nPesoLiq,nPesoBrt,cCBNFE,cLoteFor,cNFOrig) //Identificacao de produto

Local sConteudo

Local cTamanho 	:= ''
Local cModelo  	:= ''
Local cCodBar  	:= SB1->B1_CODBAR
Local cCnpj    	:= substr(SM0->M0_CGC,1,2)+"."+substr(SM0->M0_CGC,3,3)+"."+substr(SM0->M0_CGC,6,3)+"/"+substr(SM0->M0_CGC,9,4)+"-"+substr(SM0->M0_CGC,13,2)
Local cFabrLt   := DtoC(dDtFabr) //Iif(SB1->B1_FORDTLT == '1', Substr(DtoC(dDtFabr),4),DtoC(dDtFabr))
Local cValLt	:= DtoC(dDtValid) //Iif(SB1->B1_FORDTLT == '1', Substr(DtoC(dDtValid),4),DtoC(dDtValid))

Local nLinQdr	:= 0 
Local nX		:= 0
Local nY		:= 0
Local nT		:= TamSx3("D3_QUANT")[1]
Local nD		:= TamSx3("D3_QUANT")[2] 
Local nX		:= 0
Local nY		:= 0
Local nZ		:= 0
Local cIderTerm := "INDETERMINADO"

Local cQtdEmb	:= Alltrim(Str(nQE,nT+nD+1,nD))

Local lProp		:= .F.
Local lExistB5	:= .F.

Local aDescObs	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona na Tabela de Complementos de Produtos 		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//dbSelectArea("SB5")
//dbSetOrder(1)
//If dbSeek(xFilial("SB5")+cProduto)
//	lExistB5 := .T.
//EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Mensagem de Segurança no uso de Propelentes	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If lExistB5 .And. !Empty(SB5->B5_FLAMA)
//	lProp	:= .T.
//EndIf

For nX := 1 to nCopias

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia Impressão																		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MSCBBEGIN(1,4)

	MscbWrite('CT~~CD,~CC^~CT~' )
	MscbWrite('^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ' )
	MscbWrite('^XA' )
	MscbWrite('^MMT' )
	MscbWrite('^PW831' )
	MscbWrite('^LL1598' )
	MscbWrite('^LS0' )

	// ============================================================
	//  Grupo Empresa - Ajuste realizado em 31.08.20 (CG)
	// ============================================================

    // cEmpAnt (Substituido por cFilAnt)


	If Left(cFilAnt,2) == '08'
		MscbWrite('^FO672,0^GFA,06144,06144,00016,:Z64:' )
		MscbWrite('eJztlr9v1EgUx2e1SIsEkSkpEP5Psvwn+TO4Ap0tgQTd/gkWNQV0iAIy0RVbprzSjlKkxCigHcjsPN44u573fSa7LIlOh+5GiTWffZ6Z93tszP/jdxoFpeF/Dz5UXNMXogNarLmiJYWKzmC9kL+lb5HfJrmn5QE9XvN7Xk91WCQ588Gy5w/8y4XYj4plIfc/5PcX9cckr5mlvMnKzOZJ3uyV2aNcyPe2yDNglttrrgcuzV1jrJko/9cgf5Tki84/9Pea30V/1uEx+meRzrdZObHZv9b+a59v96J9JO2/OLhYJP8EyK9a+e+CfEzxw6v8/2pwfmYH+oH+2Rb9ry3ffH5NmP/806IQ9cEekvkxqK+uflP9ve9WBJDL+o31vYT6Jqj/17E/TJO/SfWPftwgtxPgYMxUMs9yya0xmeTGmLFka8xIcskzyWbqeZaYFzfTxIE3d4J93v0nZuWC5PgU7OJj9vP8NT6OlXyeeIQcDL7vFTuD+7cDjs8s8QPUv3mC9jZ/Zp3NPYcJ+OskKmiTP0+pHFsjGeNxGuMl+DzGcyLZQXw/xXzIJXNA6ep8qhTXP2C3I7c9W1bFGgNsBM+pCpJ5vVfsNnPFuQf6ukIwn+doB46T7g842Vd3+evleq5+YT9nei7s50xAe9oCuSG054hQ/lTJs66+eo6FJe1dKddzS8hH3fcH2L8l/hV9VDxCDqaYYfz2ZX/ieO2PkB8mjv43DyE/XJE/S/yicjTzsJ6Oo8mC58AeufJ0lrhmfYvTxHOO2PQ0xe+EZ/l5il9MLvD/RMXnZYyPsO9z4br22t8/+WV5rvlNDvlJ5RTzb0TALsP4cePA+K2idZ7s8ZJp1R97XqJ83l6ef7Li4yaPE7ZoxSeVk1zPa+Tnimc1rp/V7jaPO+vz8hrsafIK7G1V/q71h34G9dkQ9h/7A24VW8FHqytizX+trojUfzkpkaH/tDy7LdgVrXki2GflCPrJrdi9BZfx9hbcYn2RnyCr+usuE2Cfw3kUxshkHbJT90PQ90WpuFWs9iN1ntJ3+L7eT7NF9ko/rb9FDgbZm/vAjfkD2GK8XFe+kgtkFY+g41UqbnE917jy10jHC/Ujd482x0v5q6uR68QP/TFkWO8Vc7+L30BJzhPJsX/4McolR3lQTHL9lOD7cEv/GMhpR/4F+8HfeH+Qut+3ywfcdX04/0zp90nJgWkY/43suiOvZn+Z4VI/yMefsH+k5GPFE8VTZZ+OF22S03aGeC93jX+sN5X/fsf81wz5H583nf8Ltf7K74khd/sfob7998DqIMm7yge8xb6brv9/kP/r4zuIOkz9:2E7A' )
	ElseIf Left(cFilAnt,2) == '02'	
		MscbWrite('^FO672,32^GFA,04096,04096,00016,:Z64:' )
		MscbWrite('eJzt109v3EQUAPDnmRBfVrEjKnVFt5kemjMrFMGqtPIe+ufaj+BSJE5IkXpgEVG9goVeWrWHSnCIKOIT9NAP4IqQ3ggSF26YIiQ4UJxdUrLJxo83/7z2IIjoNkhIPCmyf8p45s14ZjwL8H8cUSTF3/vKpuOP/l3H87P5qCParTtx3HPKx0fsVcduPm6+wvGs4bZ3mHlzNvuOA8fCceL4vU/qvubkdyWvuwvPJzzUV5Hp69KivolMe6vhWX01LzQN9cSOO+rCIeTauj/zELK04gY5rrhNbld8itysuEtuTO2l5PmKAQrGpuYgFocqgVjVyijfJd6nu57Kd85LQ5+nZX8alB//oCv7q7JsNan+q1k5GscoP3Gt4hjCZP9rsPP7NOWDKKvSw7EMsIgoX9Wa8iWAF7WF8kXl36RlUnATxHfaJ1Qj615+HPEp3TXlQ95d38dfcSgtF6y30grwNo6k5Xh7p9vRRODPtjw/nyZFhGNbH7twD8k7tn/sUYLFAu70TT7sJmLBsOibfP2TiBOG+32zP/ivUfIMt/umv34iyyfjrhkO/9I9zJ8kB6lxMBCYc5ykZj0Fg3cwZ9Fe6S+/IAuU5WX+wSbgHSYOZOXq/+sgQsa3KXdP5h88gDnyLt37crzEBtD74V+RA9meGCg/oefPavPf8VOOsclfDK6DWCrezaxvpCAKVZ8uP6G/gq2t2vqo/ggfR6uV9iLcO3nf5KN9Xb3sXmmEtumPNA1R2jb9Fagjt94QYywwa5vxImPdkXJeNeLD+9XyiFvUfpKr/JV3Sz+6LZ19BnC1rcon0t9npUH6h9h6wGSBp9ZLb/KH5Iktv7DCs3NUv3XQgozm5zgz6yvwIaX5PI6tP1TrYZRaDzoQRjiUDqU3/JS8Y+eLfx6SjxEPyvm0otbPuPz/MQBqT84/7ZYa01HfjCcfKA+t2Q3lH0tf6MPrZDD7M60PWf8v1rR+5HrcL/2gJd/n0BrunrDW+/n6uTzS61Pv5xtRgGY9K18Ut2g906yCSPktcWu0jz+B3c+XcQuH+C3Y/fxV3MTPCzk0ej8/jtlltieHTg8JLafL7JVTYKORbOfsjXjqaJTz97ul5wXe8Vm/NIswPMOn5mLrm8dqf9TfO68f9PT+ab5/5f5qIrb7r4m23Z9NNO3+bRMiZxXL/TWVN+b7wfuhr2565vuRhQu6If39gE6oTyZm/4cAs5o9cw6Mq1k8izt123xsdGKYKdzH3fPWmmPhOq1bfx+m0XTOA02nP02nQbe8W5/+Hv11Pm6+7nkuhtnisPMYOO8PnP7+KaGsTjo51KKyKFT4zuMLjlv/sPlD+3NoOAc8b71u5vyg8J0fSHMvO152/HbdL6BT30t180bd3nM+oP8X4w/Kieec:F5CF' )
	EndIf
	
	MscbWrite('^FT124,33^A0R,51,50^FH\^FDQuantidade: '+Alltrim(Transform(nQE,PesqPict("SD1","D1_QUANT")))+' '+SB1->B1_UM+'^FS' )
	//MscbWrite('^FT37,33^A0R,51,50^FH\^FD001 / 199^FS' )
	if cValLt == "31/12/49" .Or. Empty(cValLt) 
		MscbWrite('^FT209,34^A0R,51,50^FH\^FDValidade: '+cIderTerm+'^FS' )
	Else
		MscbWrite('^FT209,34^A0R,51,50^FH\^FDValidade: '+cValLt+'^FS' )
	EndIf
	
	MscbWrite('^FT294,35^A0R,51,50^FH\^FDLote Interno: '+Padr(cLote,10)+' - NF: '+cNFOrig+'     - Cod.Forn.: '+AllTrim(SA2->A2_COD)+' / '+Alltrim(SA2->A2_LOJA)+'^FS' )
	MscbWrite('^FT380,37^A0R,51,50^FH\^FDLote Fornecedor: '+cLoteFor+' Recebimento: '+DtoC(SF1->F1_DTDIGIT)+'^FS' )
	MscbWrite('^FT692,450^A0R,129,126^FH\^FD'+PadC(cProduto,25)+'^FS' )
	MscbWrite('^FT465,38^A0R,51,50^FH\^FD'+BeAscHex('Produto: '+SUBSTR(SB1->B1_DESC,1,35))+'^FS' )
	MscbWrite('^FT556,38^A0R,51,50^FH\^FD'+BeAscHex('Fornecedor: '+SA2->A2_NOME)+'^FS' )
	MscbWrite('^BY180,180^FT55,1349^BXR,9,200,0,0,1,~' )
	MscbWrite('^FH\^FD'+BeAscHex(Padr(cProduto,15)+Padr(cLote,10)+DtoS(dDtValid)+cQtdEmb)+'^FS' )
	MscbWrite('^PQ1,0,1,Y^XZ' )
		
	MscbClosePrinter()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza Impressão																		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MSCBInfoEti("Produto","100X50")
	  

	sConteudo:=MSCBEND()
	
Next nX

Return sConteudo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ BeAscHex	³ Autor ³ Rodrigo Sousa         ³ Data ³ 16/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Converte Asc para Hexadecimal.							  ³±±
±±³          ³ 					  			  							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function BeAscHex(cString)

Local cRet 		:= "^FH_^FD"
Local aAcento	:= {}
Local nPos		:= 0
Local nX		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define caracteres a serem tratados.									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAcento := {{"à","_85"},{"á","_a0"},{"â","_83"},{"ã","_c6"},;
			{"À","_b7"},{"Á","_b5"},{"Â","_b6"},{"Ã","_c7"},;
			{"è","_8a"},{"é","_82"},{"ê","_88"},;
			{"È","_d4"},{"É","_90"},{"Ê","_d2"},;
			{"ì","_8d"},{"í","_a1"},{"î","_8c"},;
			{"Ì","_de"},{"Í","_d6"},{"Î","_d7"},;
			{"ò","_95"},{"ó","_a2"},{"ô","_93"},{"õ","_e4"},;
			{"Ò","_e3"},{"Ó","_e0"},{"Ô","_e2"},{"Õ","_e5"},;			
			{"ù","_97"},{"ú","_a3"},{"û","_96"},;
			{"Ù","_eb"},{"Ú","_e9"},{"Û","_ea"},;
			{"ç","_87"},{"Ç","_80"},;
			{"°","_a7"},{'"',"_22"},{"@","_40"},{"/","_2f"},;
			{"´","_27"},{" ","_20"},{"|","_0A"}}


For nX := 1 to Len(cString)

	cAux := Substr(cString,nX,1)
	nPos := aScan(aAcento,{|x| x[1] == cAux })
	
	If nPos > 0 
		cRet += aAcento[nPos][2]
	Else
		cRet += cAux 	
	EndIf

Next nX

cRet := cRet+"^FS"

Return cRet
