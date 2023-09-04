#include "rwmake.ch"
#include "topconn.ch"        
#include "tbiconn.ch"   
#include "protheus.ch"  
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGENC003   บ Autor ณPaulo Lopez         บ Data ณ  11/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFILTRO PARA CONSULTA PADRAO ( SXB ) EXIBIDAS PARA OS        บฑฑ
ฑฑบ          ณVENDEDORES EXTERNOS DE MANEIRA QUE CADA UM VISUALIZE        บฑฑ
ฑฑบ          ณAPENAS INFORMACOES ( ORCAMENTOS, PEDIDOS, ETC ) DE          บฑฑ
ฑฑบ          ณCLIENTES DEFINIDOS PARA SUA CARTEIRA DE ATENDIMENTO.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GENERICO                                                   บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function GENC003()                                                 

Local cFiltro  := "@#.T.@#"    
Local aArea    := GetArea()

// Or็amento de Vendas / Saidas
If Upper(Alltrim(FunName())) == "MATA415" 	//Criado filtro SA1SCJ e alterado campo

	If !cUserName  $ "Administrador#Ricardo.Barbosa#fatima.pap#Alessandra.Monea#Thiago.Monea#Robson.Moraes#Joelita.Silva#Luciana.Mota#Daiane.Gomes#Ellen.Ataide#Kely.Souza#Douglas.Moura#Eunice.Godoy#Tatiane.Paz#Marcia.Oliveira#Marina.Gama#Barbara.Reis#Cristiane.Eloy" // ! Vendedores externos 
		cFiltro := "@# A1_VEND $ '" + U_FATX008V() + "' @#"  
	EndIf          
	
EndIf                                                    

RestArea(aArea)

Return cFiltro  