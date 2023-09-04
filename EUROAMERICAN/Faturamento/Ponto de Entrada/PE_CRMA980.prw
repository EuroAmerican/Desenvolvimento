#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} CRMA980 
@Obs     Ponto de Entrada MVC - Clientes.
@author Fabio carneiro dos Santos 
@since 03/11/2022
@Version 12.1.33
/*/
User Function CRMA980() 
	
Local aArea       := GetArea()
Local aAreaSA1    := SA1->(GetArea())
Local aAreaSA2    := SA2->(GetArea())
Local aAreas      := {aArea, aAreaSA1,aAreaSA2}
Local aParam      := PARAMIXB
Local oModel      := Nil
Local cIdPonto    := ""
Local cIdModel    := ""
Local nOper       := 0
Local uRetorno    := .T.

Private PulaLinha := chr(13)+chr(10)
Private _cTexto   := '<html>' + PulaLinha
Private _nValor   := 0
Private _cFonte   := 'font-size:10; fonte-family:Arial;'

If aParam == NIL		
	Return .F.
Endif

oModel   := aParam[1]
cIdPonto := aParam[2]
cIdModel := aParam[3]
nOper    := oModel:GetOperation()

If cIdPonto == "MODELCOMMITTTS"

   	If nOper == 3 	

		If cFilAnt == "0803" .And. SA1->A1_XLIBCAD <> "1" 
		
			_cTexto += '<b><font size="3" face="Arial">O Cliente abaixo foi incluído: '+SubStr(cUsuario,7,15)+'</font></b><br><br>'
			_cTexto += '<b><font size="2" face="Arial">Código: '+SA1->A1_COD+'</b><br>'
			_cTexto += '<b><font size="2" face="Arial">Loja: '+SA1->A1_LOJA+'</b><br>' 
			_cTexto += '<b><font size="2" face="Arial">Nome: '+SA1->A1_NOME+'</b><br>'
			_cTexto += '<b><font size="2" face="Arial">Cnpj/Cgc: '+Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")+'</b><br><br>'  
			_cTexto += '<b><font size="2" face="Arial">Cod. Municipio IBGE: '+SA1->A1_COD_MUN+'</b><br>'
			_cTexto += '<b><font size="2" face="Arial">Municipio IBGE: '+SA1->A1_MUN+'</b><br>'
			_cTexto += '<b><font size="2" face="Arial">Estado IBGE: '+SA1->A1_EST+'</b><br><br>'
			_cTexto += '<b><font size="2" face="Arial" Color="Red">Observação: Este cliente necessita de manutenção no campos paga comissão Sim/Não.</font></b><br>'
			_cTexto += '<br><br><b><font size="3" face="Arial" color="Blue">'+AllTrim(SM0->M0_NOME)+' - '+AllTrim(SM0->M0_FILIAL)+'</font></b><br>'
			_cTexto += '</html>'
				
			_cDest := GetMV("QE_M030X08")

			If !Empty(_cDest).And.Len(_cTexto)>30
				U_CPEmail(_cDest,"","Novo Cliente Cadastrado - BASE DE PRODUÇÃO: "+SA1->A1_COD+ "-" + SA1->A1_LOJA,_cTexto,"",.T.)
			EndIf

			SA1->(RecLock("SA1", .F.))
				SA1->A1_XLIBCAD  := "1"
			SA1->(MsUnLock())
		

		ElseIf cFilAnt == "0200" .And. SA1->A1_XLIBCAD <> "1" 

			_cTexto += '<b><font size="3" face="Arial">O Cliente abaixo foi incluído: '+SubStr(cUsuario,7,15)+'</font></b><br><br>'
			_cTexto += '<b><font size="2" face="Arial">Código: '+SA1->A1_COD+'</b><br>'
			_cTexto += '<b><font size="2" face="Arial">Loja: '+SA1->A1_LOJA+'</b><br>' 
			_cTexto += '<b><font size="2" face="Arial">Nome: '+SA1->A1_NOME+'</b><br>'
			_cTexto += '<b><font size="2" face="Arial">Cnpj/Cgc: '+Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")+'</b><br><br>'  
			_cTexto += '<b><font size="2" face="Arial">Cod. Municipio IBGE: '+SA1->A1_COD_MUN+'</b><br>'
			_cTexto += '<b><font size="2" face="Arial">Municipio IBGE: '+SA1->A1_MUN+'</b><br>'
			_cTexto += '<b><font size="2" face="Arial">Estado IBGE: '+SA1->A1_EST+'</b><br><br>'
			_cTexto += '<b><font size="2" face="Arial" Color="Red">Observação: Este cliente necessita de manutenção no campos paga comissão Sim/Não.</font></b><br>'
			_cTexto += '<br><br><b><font size="3" face="Arial" color="Blue">'+AllTrim(SM0->M0_NOME)+' - '+AllTrim(SM0->M0_FILIAL)+'</font></b><br>'
			_cTexto += '</html>'
				
			_cDest := GetMV("QE_M030X02")

			If !Empty(_cDest).And.Len(_cTexto)>30
				U_CPEmail(_cDest,"","Novo Cliente Cadastrado - BASE DE PRODUÇÃO: "+SA1->A1_COD+ "-" + SA1->A1_LOJA,_cTexto,"",.T.)
			EndIf

			SA1->(RecLock("SA1", .F.))
				SA1->A1_XLIBCAD  := "1"
			SA1->(MsUnLock())

		ElseIf cFilAnt == "0901" .And. SA1->A1_XLIBCAD <> "1" 

			_cTexto += '<b><font size="3" face="Arial">O Cliente abaixo foi incluído: '+SubStr(cUsuario,7,15)+'</font></b><br><br>'
			_cTexto += '<b><font size="2" face="Arial">Código: '+SA1->A1_COD+'</b><br>'
			_cTexto += '<b><font size="2" face="Arial">Loja: '+SA1->A1_LOJA+'</b><br>' 
			_cTexto += '<b><font size="2" face="Arial">Nome: '+SA1->A1_NOME+'</b><br>'
			_cTexto += '<b><font size="2" face="Arial">Cnpj/Cgc: '+Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")+'</b><br><br>'  
			_cTexto += '<b><font size="2" face="Arial">Cod. Municipio IBGE: '+SA1->A1_COD_MUN+'</b><br>'
			_cTexto += '<b><font size="2" face="Arial">Municipio IBGE: '+SA1->A1_MUN+'</b><br>'
			_cTexto += '<b><font size="2" face="Arial">Estado IBGE: '+SA1->A1_EST+'</b><br><br>'
			_cTexto += '<b><font size="2" face="Arial" Color="Red">Observação: Este cliente necessita de manutenção no campos paga comissão Sim/Não.</font></b><br>'
			_cTexto += '<br><br><b><font size="3" face="Arial" color="Blue">'+AllTrim(SM0->M0_NOME)+' - '+AllTrim(SM0->M0_FILIAL)+'</font></b><br>'
			_cTexto += '</html>'
				
			_cDest := GetMV("QE_M030X09")

			If !Empty(_cDest).And.Len(_cTexto)>30
				U_CPEmail(_cDest,"","Novo Cliente Cadastrado - BASE DE PRODUÇÃO: "+SA1->A1_COD+ "-" + SA1->A1_LOJA,_cTexto,"",.T.)
			EndIf

			SA1->(RecLock("SA1", .F.))
				SA1->A1_XLIBCAD  := "1"
			SA1->(MsUnLock())

		EndIf
	
	EndIf

EndIf

AEval(aAreas, {|uArea| RestArea(uArea)})

Return uRetorno


