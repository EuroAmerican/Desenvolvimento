#include 'protheus.ch'
#include 'parmtype.ch'
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "ap5mail.ch"
#Include "RwMake.Ch"

#DEFINE ENTER chr(13) + chr(10)

/*/{Protheus.doc} MT410TOK -Valida a inclusão de vendador 
//Rotina visualiza pedido venda
@author Fabio Carneiro 
@since 10/05/2020
@version 1.0
@return Logical, permite ou nao a mudança de linha
@History Ajustado fonte para tratar unidade de expedição - 01/03/2022 - Fabio Carneiro 
@History Ajustado fonte para tratar operações na alteração - 02/08/2022 - Fabio Carneiro 
/*/
User Function MT410TOK()
    
Local _aAreaC5      := SC5->(GetArea())
Local _aAreaC6      := SC6->(GetArea())
Local lRet          := .T.				// Conteudo de retorno
Local nOpc          := PARAMIXB[1]	// Opcao de manutencao
Local _nI           := 0
Local _nY           := 0
Local _nQtdMinima   := 0 
Local _nQtdVenda    := 0
Local _nRetMod      := 0
Local _nQtdeEmb     := 0
Local _cUnExpedicao := 0
Local _cDescProduto := "" 
Local _cUnidMedida  := ""
Local _cMensagem    := ""
Local _cMsg         := ""
Local _cMsgA        := ""
Local _lEnvMail     := SuperGetMv("QE_XLIBMAI",.F.,.T.)
Local _cC5XOPER     := SuperGetMv("QE_XOPER",.F.,"01/06/56")
Local _cEmail       := SuperGetMv("QE_MLUNEXP",.F.,"fabio.santos@euroamerican.com.br;francisco.assis@euroamerican.com.br")	
Local nPosProduto   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPosQtdVen    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})

if ExistBlock("FATVLD01")
        aParam2:= {M->C5_FILIAL,M->C5_CLIENTE,M->C5_LOJACLI}
        lRet:= ExecBlock("FATVLD01",.f.,.f.,aParam2)
endif

If nOpc == 3 
    If M->C5_TIPO == "N"
        If Empty(M->C5_VEND1)
            Alert("Favor incluir o vendedor!")
             lRet := .F.
             Return
         EndIf 
     EndIf     
EndIf 

If nOpc == 4 
    If SC5->C5_TIPO == "N"
        If Empty(SC5->C5_VEND1)
            If Empty(M->C5_VEND1)
                Alert("Favor incluir o vendedor!")
                lRet := .F.
                Return
            EndIf
        EndIf 
    EndIf     
EndIf

//---------------
// INCLUSAO      |
//---------------

If nOpc == 3 

    If M->C5_TIPO $ "N/D/B"

        For _nI := 1 to Len(aCols)

            _nRetMod         := 0
            _nQtdVenda       := 0
            _nQtdeEmb        := 0
            _nQtdMinima      := 0
            _cUnExpedicao    := Posicione("SB1",1,xFilial("SB1")+aCols[_nI,nPosProduto],"B1_XUNEXP")
            _nQtdMinima      := Posicione("SB1",1,xFilial("SB1")+aCols[_nI,nPosProduto],"B1_XQTDEXP") 
            _cDescProduto    := Posicione("SB1",1,xFilial("SB1")+aCols[_nI,nPosProduto],"B1_DESC") 
            _cUnidMedida     := Posicione("SB1",1,xFilial("SB1")+aCols[_nI,nPosProduto],"B1_UM") 

            If M->C5_XOPER $ _cC5XOPER

                If !Empty(_cUnExpedicao) .And. _nQtdMinima > 0

                    _nRetMod         := MOD(aCols[_nI,nPosQtdVen],_nQtdMinima)
                    _nQtdVenda       := (aCols[_nI,nPosQtdVen]-_nRetMod)
                    _nQtdeEmb        := (_nQtdVenda/_nQtdMinima)

                EndIf 

                If Empty(_cUnExpedicao) .Or. _nQtdMinima == 0

                    _cMsgA := "Existem podutos que está sem unidade de expedição(B1_XUNEXP) e a quantidade minima de embalagem(B1_XQTDEXP) no cadastro do produto  "+ ENTER
                    _cMsgA += "Verificar com os responsaveis da EXPEDIÇÃO, LABORATORIO e OPERAÇÕES para fazer o preenchimento correto destas informações." + ENTER
                    _cMsgA += "Será necessario clicar no botão cancelar e após o cadastro preenchido poderá incluir ou alterar o pedido novamente !!!"
                    _cMsgA += "" + ENTER
                    _cMsgA += "" + ENTER
                    _cMsgA += "" + ENTER
                    _cMsgA += "" + ENTER
                    _cMsgA += "Será Enviado um e-mail aos responsaveis para regularizar o cadastro !!!"

                    Aviso("Atencão - MT410TOK ",_cMsgA, {"Ok"}, 2)

                    lRet := .F.
                    Exit

                EndIf	
                
                If !Empty(_cUnExpedicao) .And. _nQtdMinima > 0

                    If aCols[_nI,nPosQtdVen] <>  _nQtdVenda 

                        _cMsg := "Favor verificar a quantidade digitada do produto "+Alltrim(aCols[_nI,nPosProduto])+" , "
                        _cMsg += "que está fora do cálculo do minimo de embalagem, foi digitado a quantidade de "+Transform(aCols[_nI,nPosQtdVen], "@E 999,999,999.99")+" ! "+ENTER
                        _cMsg += "Portanto, para a regra do minimo de embalagem deverá alterar a quantidade para "+Transform(If(_nQtdVenda < _nQtdMinima,_nQtdMinima,_nQtdVenda), "@E 999,999,999.99")+" de acordo com o volume e espécie !"+ENTER  
                        _cMsg += "Não será permitido prosseguir, sugerimos digitar a quantidade "+Transform(If(_nQtdVenda < _nQtdMinima,_nQtdMinima,_nQtdVenda), "@E 999,999,999.99")+" !"+ENTER 
                        _cMsg += "Caso a quantidade "+Transform(aCols[_nI,nPosQtdVen], "@E 999,999,999.99")+", tenha que ser a digitada, verificar o tipo de venda no cabeçalho do pedido!"+ENTER 

                        Aviso("Atencão - MT410TOK ",_cMsg, {"Ok"}, 2)

                        lRet      := .F.
                        _lEnvMail := .F.

                    EndIf

                EndIf 

            EndIf

        Next _nI
                    
        If M->C5_XOPER $ _cC5XOPER

            If !lRet

                If  _lEnvMail

                    _cMensagem:="<h2>Prezados</h2>"
                    _cMensagem+="<p>Os Produtos abaixo <u> estão sem o preenchimento da unidade de medida expedição e embalagem minima!</u></p>"
                    _cMensagem+="<p>"+" "+"</p>"
                    _cMensagem+='<table border="1" cellpadding="1" cellspacing="1" style="width:500px">'
                    _cMensagem+="<tbody>"
                    _cMensagem+="<tr>"
                    _cMensagem+="<td>Produto</td>"
                    _cMensagem+="<td>Descricao</td>"
                    _cMensagem+="<td>Unid Med</td>"
                    _cMensagem+="</tr>"

                    For _nY := 1 to Len(aCols)

                        _cDescProduto    := Posicione("SB1",1,xFilial("SB1")+aCols[_nY,nPosProduto],"B1_DESC") 
                        _cUnidMedida     := Posicione("SB1",1,xFilial("SB1")+aCols[_nY,nPosProduto],"B1_UM") 
                        _cUnExpedicao    := Posicione("SB1",1,xFilial("SB1")+aCols[_nY,nPosProduto],"B1_XUNEXP")
                        _nQtdMinima      := Posicione("SB1",1,xFilial("SB1")+aCols[_nY,nPosProduto],"B1_XQTDEXP") 

                        If Empty(_cUnExpedicao) .Or. _nQtdMinima == 0

                            _cMensagem+="<tr>"
                            _cMensagem+="<td>"+Alltrim(aCols[_nY,nPosProduto])+"</td>"  
                            _cMensagem+="<td>"+Alltrim(_cDescProduto)+"</td>"
                            _cMensagem+="<td>"+Alltrim(_cUnidMedida)+"</td>"
                            _cMensagem+="</tr>"

                        EndIf

                    Next _nY

                    _cMensagem+="</tbody>"
                    _cMensagem+="</table>"
                    _cMensagem+="<p>"+" "+"</p>"
                    _cMensagem+="<p><u><strong>Observacoes: Somente após preenchimento do cadastro será possivel digitar ou alterar o pedido de Vendas !!! </strong></u></p>"
                    _cMensagem+="<p>"+" "+"</p>"
                    _cMensagem+="<p>Atenciosamente</p>"

                    U_CPEmail(_cEmail," ","Os Produtos encontran-se sem o preenchimento nos campos unidade de expedição(B1_XUNEXP) e embalagem minina(B1_XQTDEXP) no cadastro de produtos ",_cMensagem,"",.F.)
                
                Endif

            EndIf

        EndIf

    EndIf

EndIf 

//---------------
// ALTERACAO     |
//---------------

If nOpc == 4 

    If SC5->C5_TIPO $ "N/D/B"

        For _nI := 1 to Len(aCols)

            _nRetMod         := 0
            _nQtdVenda       := 0
            _nQtdeEmb        := 0
            _nQtdMinima      := 0
            _cUnExpedicao    := Posicione("SB1",1,xFilial("SB1")+aCols[_nI,nPosProduto],"B1_XUNEXP")
            _nQtdMinima      := Posicione("SB1",1,xFilial("SB1")+aCols[_nI,nPosProduto],"B1_XQTDEXP") 
            _cDescProduto    := Posicione("SB1",1,xFilial("SB1")+aCols[_nI,nPosProduto],"B1_DESC") 
            _cUnidMedida     := Posicione("SB1",1,xFilial("SB1")+aCols[_nI,nPosProduto],"B1_UM") 

            If M->C5_XOPER $ _cC5XOPER // Alterado para tratar via regmemory - 02/08/2022

                If !Empty(_cUnExpedicao) .And. _nQtdMinima > 0

                    _nRetMod         := MOD(aCols[_nI,nPosQtdVen],_nQtdMinima)
                    _nQtdVenda       := (aCols[_nI,nPosQtdVen]-_nRetMod)
                    _nQtdeEmb        := (_nQtdVenda/_nQtdMinima)

                EndIf 

                If Empty(_cUnExpedicao) .Or. _nQtdMinima == 0

                    _cMsgA := "Existem podutos que está sem unidade de expedição(B1_XUNEXP) e a quantidade minima de embalagem(B1_XQTDEXP) no cadastro do produto  "+ ENTER
                    _cMsgA += "Verificar com os responsaveis da EXPEDIÇÃO, LABORATORIO e OPERAÇÕES para fazer o preenchimento correto destas informações." + ENTER
                    _cMsgA += "Será necessario clicar no botão cancelar e após o cadastro preenchido poderá incluir ou alterar o pedido novamente !!!"
                    _cMsgA += "" + ENTER
                    _cMsgA += "" + ENTER
                    _cMsgA += "" + ENTER
                    _cMsgA += "" + ENTER
                    _cMsgA += "Será Enviado um e-mail aos responsaveis para regularizar o cadastro !!!"

                    Aviso("Atencão - MT410TOK ",_cMsgA, {"Ok"}, 2)

                    lRet := .F.
                    Exit

                EndIf	
                
                If !Empty(_cUnExpedicao) .And. _nQtdMinima > 0

                    If aCols[_nI,nPosQtdVen] <>  _nQtdVenda 

                        _cMsg := "Favor verificar a quantidade digitada do produto "+Alltrim(aCols[_nI,nPosProduto])+" , "
                        _cMsg += "que está fora do cálculo do minimo de embalagem, foi digitado a quantidade de "+Transform(aCols[_nI,nPosQtdVen], "@E 999,999,999.99")+" ! "+ENTER
                        _cMsg += "Portanto, para a regra do minimo de embalagem deverá alterar a quantidade para "+Transform(If(_nQtdVenda < _nQtdMinima,_nQtdMinima,_nQtdVenda), "@E 999,999,999.99")+" de acordo com o volume e espécie !"+ENTER  
                        _cMsg += "Não será permitido prosseguir, sugerimos digitar a quantidade "+Transform(If(_nQtdVenda < _nQtdMinima,_nQtdMinima,_nQtdVenda), "@E 999,999,999.99")+" !"+ENTER 
                        _cMsg += "Caso a quantidade "+Transform(aCols[_nI,nPosQtdVen], "@E 999,999,999.99")+", tenha que ser a digitada, verificar o tipo de venda no cabeçalho do pedido!"+ENTER 

                        Aviso("Atencão - MT410TOK ",_cMsg, {"Ok"}, 2)

                        lRet      := .F.
                        _lEnvMail := .F.

                    EndIf

                EndIf 

            EndIf

        Next _nI
                    
        If M->C5_XOPER $ _cC5XOPER // Alterado para tratar via regmemory - 02/08/2022

            If !lRet

                If  _lEnvMail

                    _cMensagem:="<h2>Prezados</h2>"
                    _cMensagem+="<p>Os Produtos abaixo <u> estão sem o preenchimento da unidade de medida expedição e embalagem minima!</u></p>"
                    _cMensagem+="<p>"+" "+"</p>"
                    _cMensagem+='<table border="1" cellpadding="1" cellspacing="1" style="width:500px">'
                    _cMensagem+="<tbody>"
                    _cMensagem+="<tr>"
                    _cMensagem+="<td>Produto</td>"
                    _cMensagem+="<td>Descricao</td>"
                    _cMensagem+="<td>Unid Med</td>"
                    _cMensagem+="</tr>"

                    For _nY := 1 to Len(aCols)

                        _cDescProduto    := Posicione("SB1",1,xFilial("SB1")+aCols[_nY,nPosProduto],"B1_DESC") 
                        _cUnidMedida     := Posicione("SB1",1,xFilial("SB1")+aCols[_nY,nPosProduto],"B1_UM") 
                        _cUnExpedicao    := Posicione("SB1",1,xFilial("SB1")+aCols[_nY,nPosProduto],"B1_XUNEXP")
                        _nQtdMinima      := Posicione("SB1",1,xFilial("SB1")+aCols[_nY,nPosProduto],"B1_XQTDEXP") 

                        If Empty(_cUnExpedicao) .Or. _nQtdMinima == 0

                            _cMensagem+="<tr>"
                            _cMensagem+="<td>"+Alltrim(aCols[_nY,nPosProduto])+"</td>"  
                            _cMensagem+="<td>"+Alltrim(_cDescProduto)+"</td>"
                            _cMensagem+="<td>"+Alltrim(_cUnidMedida)+"</td>"
                            _cMensagem+="</tr>"

                        EndIf

                    Next _nY

                    _cMensagem+="</tbody>"
                    _cMensagem+="</table>"
                    _cMensagem+="<p>"+" "+"</p>"
                    _cMensagem+="<p><u><strong>Observacoes: Somente após preenchimento do cadastro será possivel digitar ou alterar o pedido de Vendas !!! </strong></u></p>"
                    _cMensagem+="<p>"+" "+"</p>"
                    _cMensagem+="<p>Atenciosamente</p>"

                    U_CPEmail(_cEmail," ","Os Produtos encontran-se sem o preenchimento nos campos unidade de expedição(B1_XUNEXP) e embalagem minina(B1_XQTDEXP) no cadastro de produtos ",_cMensagem,"",.F.)
                
                Endif

            EndIf

        EndIf

    EndIf

EndIf 

RestArea(_aAreaC6)
RestArea(_aAreaC5)

Return(lRet)


