#INCLUDE "protheus.ch"
#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �          �Autor  �                    � Data �             ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada referente a imagem de identificacao do     ���
���          �produto. Cadastro de Produtos. Padr�o Zebra                 ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function EQEtHenk() //Identificacao de produto

Local sConteudo

Local cTamanho 	:= ''
Local cModelo  	:= ''
Local cCnpj    	:= substr(SM0->M0_CGC,1,2)+"."+substr(SM0->M0_CGC,3,3)+"."+substr(SM0->M0_CGC,6,3)+"/"+substr(SM0->M0_CGC,9,4)+"-"+substr(SM0->M0_CGC,13,2)

Local nLinQdr	:= 0 
Local nX		:= 0
Local nY		:= 0
Local nT		:= TamSx3("D3_QUANT")[1]
Local nD		:= TamSx3("D3_QUANT")[2] 
Local nX		:= 0
Local nY		:= 0
Local nZ		:= 0

Local lProp		:= .F.
Local lExistB5	:= .F.

Local aDescObs	:= {}
Local aArea  := GetArea()
Local aDados := {}

dbSelectArea("SB1")
dbSetOrder(1)
If SB1->( dbSeek( xFilial("SB1") + SC2->C2_PRODUTO ) )
    If AllTrim( SB1->B1_RASTRO ) <> "N"
        dbSelectArea("SB8")
        dbSetOrder(3) // B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_NUMLOTE, B8_DTVALID 
        If SB8->( dbSeek( xFilial("SB8") + SC2->C2_PRODUTO + SC2->C2_LOCAL + SC2->C2_NUM ) )
            aDados := {}
            aAdd( aDados, IIF(!EMPTY(SB1->B1_U_DESC2),Rtrim(Substr(SB1->B1_U_DESC2,1,25)),Rtrim(Substr(SB1->B1_DESC,1,25))))	// 01 Descri��o
            aAdd( aDados, SB1->B1_COD		)  // 02 C�digo
            aAdd( aDados, SB1->B1_CODBAR	)  // 03 EAN-13
            aAdd( aDados, SB8->B8_LOTECTL	)  // 04 Lote
            aAdd( aDados, SB8->B8_DFABRIC	)  // 05 Fabrica��o
            aAdd( aDados, SB8->B8_DTVALID	)  // 06 Validade
            If AllTrim(SB1->B1_UM) == "KG"
                aAdd( aDados, SB1->B1_PESO * SB1->B1_CONV		)  // 07 Peso L�quido
                aAdd( aDados, SB1->B1_PESBRU * SB1->B1_CONV	        )  // 08 Peso Bruto
            Else
                aAdd( aDados, SB1->B1_PESO		)  // 07 Peso L�quido
                aAdd( aDados, SB1->B1_PESBRU	)  // 08 Peso Bruto
            EndIf
        Else
            aDados := {}
            aAdd( aDados, IIF(!EMPTY(SB1->B1_U_DESC2),Rtrim(Substr(SB1->B1_U_DESC2,1,25)),Rtrim(Substr(SB1->B1_DESC,1,25))))	// 01 Descri��o
            aAdd( aDados, SB1->B1_COD		)  // 02 C�digo
            aAdd( aDados, SB1->B1_CODBAR	)  // 03 EAN-13
            aAdd( aDados, SC2->C2_NUM   	)  // 04 Lote
            aAdd( aDados, dDataBase     	)  // 05 Fabrica��o
            aAdd( aDados, dDataBase + SB1->B1_PRVALID	)  // 06 Validade
            If AllTrim(SB1->B1_UM) == "KG"
                aAdd( aDados, SB1->B1_PESO * SB1->B1_CONV		)  // 07 Peso L�quido
                aAdd( aDados, SB1->B1_PESBRU * SB1->B1_CONV	        )  // 08 Peso Bruto
            Else
                aAdd( aDados, SB1->B1_PESO		)  // 07 Peso L�quido
                aAdd( aDados, SB1->B1_PESBRU	)  // 08 Peso Bruto
            EndIf
        EndIf
    EndIf
EndIf

If Len( aDados ) > 0
    AjustSX1()

    If Pergunte("REST992", .T.)
        If mv_par05 == 0
            nCopias := 1
        Else
            nCopias := mv_par05
        EndIf

        For nX := 1 to nCopias
            //dbSelectArea("CB5")
            //dbSetOrder(1)
            //If CB5->(DbSeek(FWxFilial("CB5") + MV_PAR01, .F.))
            //	CB5SetImp(mv_par01)
            //Else
            //	CB5SetImp("000004")
            //EndIF
            cPorta := "LPT1"
            MSCBPRINTER("LPT1",cPorta,,40,.f.)
            MSCBCHKSTATUS(.F.)
            MSCBBEGIN(1,6)

            //MSCBBEGIN(1,4)

            MscbWrite('CT~~CD,~CC^~CT~' )
            MscbWrite('^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ' )
            MscbWrite('^XA' )
            MscbWrite('^MMT' )
            MscbWrite('^PW831' )
            MscbWrite('^LL1598' )
            MscbWrite('^LS0' )

            If mv_par02 == 1
                MscbWrite('^FT767,40^A0R,70,65^FH\^FD' + BeAscHex(AllTrim(mv_par03)) + '^FS')  // Lote
                MscbWrite('^FT707,320^A0R,25,25^FH\^FD' + BeAscHex(AllTrim(mv_par04)) + '^FS')  // Lote
            ElseIf mv_par02 == 3
                MscbWrite('^FT767,40^A0R,70,65^FH\^FD' + BeAscHex(AllTrim(SB1->B1_DESC)) + '^FS')  // Lote
                MscbWrite('^FT707,320^A0R,25,25^FH\^FD' + BeAscHex(AllTrim(mv_par04)) + '^FS')  // Lote
            Else
                MscbWrite('^FT707,320^A0R,25,25^FH\^FD' + BeAscHex(AllTrim(mv_par04)) + '^FS')  // Lote
            EndIf

            MscbWrite('^FT629,320^A0R,25,25^FH\^FD' + BeAscHex(aDados[4]) + '^FS')  // Lote
            //MscbWrite('^FT569,60^A0R,25,25^FH\^FD' + BeAscHex(DTOC(aDados[5])) + '^FS')  // Data Fabrica��o
            //MscbWrite('^FT502,60^A0R,25,25^FH\^FD' + BeAscHex(DTOC(aDados[6])) + '^FS')  // Data Validade
            // A pedido do Alex, foi retirada a data de fabricação e validade do lote para um calculo fixo
            MscbWrite('^FT569,320^A0R,25,25^FH\^FD' + BeAscHex(DTOC(dDataBase)) + '^FS')  // Data Fabrica��o FS/FB ->>> 18/11/2020
            MscbWrite('^FT502,320^A0R,25,25^FH\^FD' + BeAscHex(DTOC(dDataBase+180)) + '^FS')  // Data Validade
            // Retirado as quantidades pois virá da gráfica impressa...
            //MscbWrite('^FT442,60^A0R,25,25^FH\^FD' + BeAscHex(AllTrim(TransForm(aDados[7], "@R 999,999,999.99")) + " Kg") + '^FS')  // Peso L�quido
            //MscbWrite('^FT372,60^A0R,25,25^FH\^FD' + BeAscHex(AllTrim(TransForm(aDados[8], "@R 999,999,999.99")) + " Kg") + '^FS')  // Peso Bruto

            //MscbWrite('^BY3,3,70^FT291,27^BAR,,N,N' + cEof)
            //MscbWrite('^FD' + '' + '^FS' + cEof)
            //MscbWrite('^PQ' + '' + ',0,,Y^XZ' + cEof)

            MSCBEND()
            MscbClosePrinter()
            //MSCBInfoEti("Produto","100X50")
            //sConteudo:=MSCBEND()
        Next
    EndIf
Else
    ApMsgAlert( "OP n�o encerrada ou produto n�o controla lote, para impress�o de etiqueta Helken � obrigat�rio ter OP e controlar Lote!", "Aten��o" )
EndIf

RestArea( aArea )

Return sConteudo

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � BeAscHex	� Autor � Rodrigo Sousa         � Data � 16/12/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Converte Asc para Hexadecimal.							  ���
���          � 					  			  							  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function BeAscHex(cString)

Local cRet 		:= "^FH_^FD"
Local aAcento	:= {}
Local nPos		:= 0
Local nX		:= 0

//���������������������������������������������������������������������Ŀ
//� Define caracteres a serem tratados.									�
//�����������������������������������������������������������������������
aAcento := {{"�","_85"},{"�","_a0"},{"�","_83"},{"�","_c6"},;
			{"�","_b7"},{"�","_b5"},{"�","_b6"},{"�","_c7"},;
			{"�","_8a"},{"�","_82"},{"�","_88"},;
			{"�","_d4"},{"�","_90"},{"�","_d2"},;
			{"�","_8d"},{"�","_a1"},{"�","_8c"},;
			{"�","_de"},{"�","_d6"},{"�","_d7"},;
			{"�","_95"},{"�","_a2"},{"�","_93"},{"�","_e4"},;
			{"�","_e3"},{"�","_e0"},{"�","_e2"},{"�","_e5"},;			
			{"�","_97"},{"�","_a3"},{"�","_96"},;
			{"�","_eb"},{"�","_e9"},{"�","_ea"},;
			{"�","_87"},{"�","_80"},;
			{"�","_a7"},{'"',"_22"},{"@","_40"},{"/","_2f"},;
			{"�","_27"},{" ","_20"},{"|","_0A"}}


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

Static Function AjustSX1()

	Local cAlias   := Alias()
	Local aHelpPor := {}

	//Pergunta 01
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o local de impress�o")
	aAdd(aHelpPor, "das etiquetas")
	U_FATUSX1("REST992","01","Local de Impress�o ?","Local de Impress�o ?","Local de Impress�o ?","MV_CH1","C",6,0,0,"G",'ExistCpo("CB5")',"MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","CB5","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 02
	aHelpPor := {}
	aAdd(aHelpPor, "Imprime Descri��o e IDH Henkel")
	U_FATUSX1("REST992","02","Imprime Descri��o Henkel?","Imprime Descri��o Henkel?","Imprime Descri��o Henkel?","MV_CH2","N",1,0,0,"C",'',"MV_PAR02","Sim","Sim","Sim","","N�o","N�o","N�o","","Produto","Produto","Produto","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 03
	aHelpPor := {}
	aAdd(aHelpPor, "Descri��o Henkel")
	U_FATUSX1("REST992","03","Descri��o","Descri��o","Descri��o","MV_CH3","C",80,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 04
	aHelpPor := {}
	aAdd(aHelpPor, "IDH Henkel")
	U_FATUSX1("REST992","04","IDH","IDH","IDH","MV_CH4","C",20,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 05
	aHelpPor := {}
	aAdd(aHelpPor, "Nr. C�pias")
	U_FATUSX1("REST992","05","Nr. C�pias","Nr. C�pias","Nr. C�pias","MV_CH5","N",3,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	DbSelectArea(cAlias)

Return
