#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'
#Include "RESTFUL.CH"
#Include "FWMVCDEF.CH"

// FS - Ponto de entrada após a gravação do apontamento no ACD...

User Function ACD023PR() //	ExecBlock("ACD023PR",.F.,.F.,{cOp,cOperacao,cRecurso,cOperador,nQtd,cTransac,cLote})

Local aArea       := GetArea()
Local lRetorto    := .T.
Local cOP         := ParamIXB[1]
Local cOperacao   := ParamIXB[2]
Local cRecurso    := ParamIXB[3]
Local nQuant      := ParamIXB[5]
Local cTransac    := ParamIXB[6]
Local cURL        := GetMV("MV_FB_URLE",,"http://10.0.0.90:3000")
Local aHeader     := {}
Local oRestClient := Nil
Local oObjResult  := Nil
/*
// ---------------->>>>>>>>>>>>>>> Chama webservice Restfull do Flowboard...

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona Header para WS...                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aHeader, "Content-Type: application/json" )
aAdd( aHeader, "Accept: application/json" )
aAdd( aHeader, "charset: UTF-8" )

oRestClient  := FWRest():New(Alltrim(cURL))
oRestClient:setPath("/post")

cJson := '{'
cJson += '"op" : "' + AllTrim( cOP ) + '",'
cJson += '"timestamp" : "' + Left( DTOS( dDataBase ), 4) + '-' + SubStr( DTOS( dDataBase ), 5, 2) + '-' + Right( DTOS( dDataBase ), 2) + ' ' + Left( Time(), 5) + ':00",'
cJson += '"cod_recurso" : "' + AllTrim( cRecurso ) + '",'
cJson += '"cod_operacao" : "' + AllTrim( cOperacao ) + '",' 
cJson += '"cod_transacao" : "' + AllTrim( cTransac ) + '",'
cJson += '"cod_parada" : "",'
cJson += '"evento_parada" : ""'
cJson += '}'

oRestClient:SetPostParams(EncodeUTF8(cJson))

If oRestClient:Post( aHeader )
    cError := ""
    nStatus := HTTPGetStatus(@cError)

    If nStatus >= 200 .And. nStatus <= 299
        If Empty(oRestClient:getResult())
            ConOut(nStatus)
        Else
            ConOut(oRestClient:getResult())
        EndIf
    Else
        ConOut(cError)
    EndIf
Else
    //ConOut(oRestClient:getLastError() + CRLF + oRestClient:getResult())
    ConOut(oRestClient:getLastError())
EndIf
*/
RestArea( aArea )

Return lRetorto