/*/{Protheus.doc} MT410ALT
Ponto de entrada para envio de email quando tem podouto especial 
@type function Ponto de Entrada
@version  1.00
@author mario.antonaccio
@since 17/09/2021
@return character, sem retorno
/*/
User Function MT410ALT()
Local aArea:=GetArea()
Local aPrdEsp:={}
Local i as Numeric
Local cEmail as Character

	SC6->(dbSetOrder(1))
	SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM))
	While SC6->(!EOF()) .And. SC6->C6_NUM == SC5->C5_NUM

		// Produtos Especiais
		If SC6->C6_XGRPESP $ GETMV("QE_GRPPRES")
			AADD(aPrdEsp,{SC6->C6_NUM,SC6->C6_PRODUTO,SC6->C6_DESCRI,SC6->C6_UM,SC6->C6_XGRPESP,SC6->C6_XGRPDSC,SC6->C6_QTDVEN})
		End

		SC6->(dbSkip())

	Enddo

	If  Len(aPrdEsp) > 0 // Validar produto especial - PROJETO : Tratativa de produtos especiais para controlar producao x pedido de vendas
	
		cEmail:=SuperGetMv("QE_MLEPSPV",.F.,"mario.antonaccio@euroamerican.com.br;alexsandro.blasques@qualyvinil.com;rafael.brito@qualyvinil.com.br;gutemberg.reis@qualyvinil.com.br")	

		cMensagem:="<h2>Prezados</h2>"
		cMensagem+="<p>O Pedido <u> <strong>"+SC5->C5_NUM+"</strong> que possue  produto(s) especial(ais):</u></p>"
		cMensagem+="<p>foi <strong> A L T E R A D O </strong> em "+DTOC(dDataBase)+"</p>"
		cMensagem+="<p><strong> FAVOR REVISAR!!! </strong> </p>"
		cMensagem+="<p>"+" "+"</p>"
		cMensagem+='<table border="1" cellpadding="1" cellspacing="1" style="width:500px">'
		cMensagem+="<tbody>"
		cMensagem+="<tr>"
		cMensagem+="	<td>Pedido</td>"  // email Nicolae - 20/09/2021
		cMensagem+="	<td>Produto</td>"
		cMensagem+="	<td>Descricao</td>"
		cMensagem+="	<td>Unid Med</td>"
		cMensagem+="	<td>Grupo</td>" // email Nicolae - 20/09/2021
		cMensagem+="	<td>Desc.Grupo</td>" // email Nicolae - 20/09/2021
		cMensagem+="	<td>Quantidade</td>"
		cMensagem+="</tr>"
		For i:=1 to Len(aPrdEsp)
			cMensagem+="<tr>"
			cMensagem+="<td>"+aPrdEsp[i,1]+"</td>"  // email Nicolae - 20/09/2021
			cMensagem+="<td>"+aPrdEsp[i,2]+"</td>"
			cMensagem+="<td>"+aPrdEsp[i,3]+"</td>"
			cMensagem+="<td>"+aPrdEsp[i,4]+"</td>"
			cMensagem+="<td>"+aPrdEsp[i,5]+"</td>"  // email Nicolae - 20/09/2021
			cMensagem+="<td>"+aPrdEsp[i,6]+"</td>" // email Nicolae - 20/09/2021
			cMensagem+='<td style="text-align: center;">'+Transform(aPrdEsp[i,7],"@E 999,999.9999")+"</td>"
			cMensagem+="</tr>"
		Next
		cMensagem+="</tbody>"
		cMensagem+="</table>"
		cMensagem+="<p>"+" "+"</p>"
		cMensagem+="<p>Atenciosamente</p>"

		U_CPEmail(cEmail," ","Pedido com Produto Especial - Alteracao Pedido",cMensagem,"",.F.)

	End

RestArea(aArea)
Return
