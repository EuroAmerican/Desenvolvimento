/*/{Protheus.doc} MT110FIL
//LOCALIZA��O : Function MATA110 - Fun��o da Solicita��o de Compras.
//EM QUE PONTO : Antes da apresenta�ao da interface da Mbrowse no inicio da rotina, possibilita compor um string
//contendo uma express�o de Filtro da tabela SC1 para ser passada para MBrowse.
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