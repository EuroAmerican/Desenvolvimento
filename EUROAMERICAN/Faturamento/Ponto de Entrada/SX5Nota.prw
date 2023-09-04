#Include 'Protheus.Ch'
#Include 'Totvs.Ch'

// PE Seleção Séries tabela 01 no faturamento para selecionar NF... (Fabio)

User Function SX5Nota()

Local lRetorno  := .T.
Local cIniSerie := GetMv("MV_EQ_INSE",,"REQ|REC") // Parâmetro para inibir séries no faturamento

If AllTrim( SX5->X5_CHAVE ) $ cIniSerie
    lRetorno := .F.
EndIf

Return lRetorno