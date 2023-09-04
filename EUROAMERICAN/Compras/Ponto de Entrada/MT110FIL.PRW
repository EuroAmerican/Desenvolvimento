/*/{Protheus.doc} MT110FIL
//LOCALIZAÇÃO : Function MATA110 - Função da Solicitação de Compras.
//EM QUE PONTO : Antes da apresentaçao da interface da Mbrowse no inicio da rotina, possibilita compor um string
//contendo uma expressão de Filtro da tabela SC1 para ser passada para MBrowse.
//http://tdn.totvs.com/pages/releaseview.action?pageId=6085441
@author Emerson Paiva
@since 13/04/2018
@version 1.0
@Hystory Inserido os usuarios RUI.TOLOZA ANA.PERLA GABRIELLY.SILVA
@Since 07/06/2021
@Author Fabio carneiro dos Santos 
/*/
User Function MT110FIL()
Local cFiltro := IIF(UPPER(cUserName)$SuperGetMv("EQ_FILSC1",.F.,"ADMINISTRADOR#SANDRA.BARROS#RUI.TOLOZA#ANA.PERLA#GABRIELLY.SILVA"),'','  C1_USER  == __cUserID   ')
Return (cFiltro) 
