#INCLUDE "PROTHEUS.CH" 

User Function MDFeMun() 

Local cEntSai 	:= PARAMIXB[1] //1-Saída/2-Entrada 
Local cSerie	:= PARAMIXB[2] //Série da NF 
Local cNota 	:= PARAMIXB[3] //Número da Nota da NF 
Local cCliFor 	:= PARAMIXB[4] //Cliente/Fornecedor 
Local cLoja 	:= PARAMIXB[5] //Loja 

Local aAreaSA1	:= SA1->(GetArea())

dbSelectArea("SA1")
dbSetOrder(1)
If SA1->(dbSeek(xFilial("SA1")+cCliFor+cLoja)) 
	cRetMun := SA1->A1_COD_MUN 
EndIf 

RestArea(aAreaSA1)

Return cRetMun