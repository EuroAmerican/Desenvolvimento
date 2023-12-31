#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

User Function TSTC7OBSM()

Local cQuery := ""

/*
Analista Paulo Rog�rio
Data: 28/09/2022

---------------------------------------------------------------------------------------------------------------
N�o reativar esse fonte antes de revisar a logica de relacionato de tabelas entre as empresas e Filiais.
---------------------------------------------------------------------------------------------------------------

cQuery := "SELECT SC7.C7_FILIAL, SC7.C7_NUM, SC7.C7_ITEM, CONVERT(VARCHAR(2000),ANT.C7_OBSM) AS ACERTO, CONVERT(VARCHAR(2000),CONVERT(VARBINARY(2000),SC7.C7_OBSM)) AS ERRO " + CRLF
cQuery += "FROM SC7100 AS SC7 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN SC7020 AS ANT WITH (NOLOCK) ON ANT.C7_FILIAL = RIGHT(SC7.C7_FILIAL, 2) " + CRLF
cQuery += "  AND ANT.C7_NUM = SC7.C7_NUM " + CRLF
cQuery += "  AND ANT.C7_ITEM = SC7.C7_ITEM " + CRLF
cQuery += "  AND CONVERT(VARCHAR(2000),ANT.C7_OBSM) <> CONVERT(VARCHAR(2000),CONVERT(VARBINARY(2000),SC7.C7_OBSM)) " + CRLF
cQuery += "  AND CONVERT(VARCHAR(2000),ANT.C7_OBSM) <> '' " + CRLF
cQuery += "  AND CONVERT(VARCHAR(2000),ANT.C7_OBSM) <> '                              '" + CRLF
cQuery += "  AND ANT.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE LEFT(SC7.C7_FILIAL, 2) = '02' " + CRLF
cQuery += "AND SC7.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "UNION ALL " + CRLF
cQuery += "SELECT SC7.C7_FILIAL, SC7.C7_NUM, SC7.C7_ITEM, CONVERT(VARCHAR(2000),ANT.C7_OBSM) AS ACERTO, CONVERT(VARCHAR(2000),CONVERT(VARBINARY(2000),SC7.C7_OBSM)) AS ERRO " + CRLF
cQuery += "FROM SC7100 AS SC7 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SC7")+" AS ANT WITH (NOLOCK) ON ANT.C7_FILIAL = RIGHT(SC7.C7_FILIAL, 2) " + CRLF
cQuery += "  AND ANT.C7_NUM = SC7.C7_NUM " + CRLF
cQuery += "  AND ANT.C7_ITEM = SC7.C7_ITEM " + CRLF
cQuery += "  AND CONVERT(VARCHAR(2000),ANT.C7_OBSM) <> CONVERT(VARCHAR(2000),CONVERT(VARBINARY(2000),SC7.C7_OBSM)) " + CRLF
cQuery += "  AND CONVERT(VARCHAR(2000),ANT.C7_OBSM) <> '' " + CRLF
cQuery += "  AND CONVERT(VARCHAR(2000),ANT.C7_OBSM) <> '                              '" + CRLF
cQuery += "  AND ANT.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE LEFT(SC7.C7_FILIAL, 2) = '08' " + CRLF
cQuery += "AND SC7.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "UNION ALL " + CRLF
cQuery += "SELECT SC7.C7_FILIAL, SC7.C7_NUM, SC7.C7_ITEM, CONVERT(VARCHAR(2000),ANT.C7_OBSM) AS ACERTO, CONVERT(VARCHAR(2000),CONVERT(VARBINARY(2000),SC7.C7_OBSM)) AS ERRO " + CRLF
cQuery += "FROM SC7100 AS SC7 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN SC7010 AS ANT WITH (NOLOCK) ON ANT.C7_FILIAL = RIGHT(SC7.C7_FILIAL, 2) " + CRLF
cQuery += "  AND ANT.C7_NUM = SC7.C7_NUM " + CRLF
cQuery += "  AND ANT.C7_ITEM = SC7.C7_ITEM " + CRLF
cQuery += "  AND CONVERT(VARCHAR(2000),ANT.C7_OBSM) <> CONVERT(VARCHAR(2000),CONVERT(VARBINARY(2000),SC7.C7_OBSM)) " + CRLF
cQuery += "  AND CONVERT(VARCHAR(2000),ANT.C7_OBSM) <> '' " + CRLF
cQuery += "  AND CONVERT(VARCHAR(2000),ANT.C7_OBSM) <> '                              '" + CRLF
cQuery += "  AND ANT.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE LEFT(SC7.C7_FILIAL, 2) = '01' " + CRLF
cQuery += "AND SC7.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "UNION ALL " + CRLF
cQuery += "SELECT SC7.C7_FILIAL, SC7.C7_NUM, SC7.C7_ITEM, CONVERT(VARCHAR(2000),ANT.C7_OBSM) AS ACERTO, CONVERT(VARCHAR(2000),CONVERT(VARBINARY(2000),SC7.C7_OBSM)) AS ERRO " + CRLF
cQuery += "FROM SC7100 AS SC7 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN SC7090 AS ANT WITH (NOLOCK) ON ANT.C7_FILIAL = RIGHT(SC7.C7_FILIAL, 2) " + CRLF
cQuery += "  AND ANT.C7_NUM = SC7.C7_NUM " + CRLF
cQuery += "  AND ANT.C7_ITEM = SC7.C7_ITEM " + CRLF
cQuery += "  AND CONVERT(VARCHAR(2000),ANT.C7_OBSM) <> CONVERT(VARCHAR(2000),CONVERT(VARBINARY(2000),SC7.C7_OBSM)) " + CRLF
cQuery += "  AND CONVERT(VARCHAR(2000),ANT.C7_OBSM) <> '' " + CRLF
cQuery += "  AND CONVERT(VARCHAR(2000),ANT.C7_OBSM) <> '                              '" + CRLF
cQuery += "  AND ANT.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE LEFT(SC7.C7_FILIAL, 2) = '09' " + CRLF
cQuery += "AND SC7.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "UNION ALL " + CRLF
cQuery += "SELECT SC7.C7_FILIAL, SC7.C7_NUM, SC7.C7_ITEM, CONVERT(VARCHAR(2000),ANT.C7_OBSM) AS ACERTO, CONVERT(VARCHAR(2000),CONVERT(VARBINARY(2000),SC7.C7_OBSM)) AS ERRO " + CRLF
cQuery += "FROM SC7100 AS SC7 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN SC7060 AS ANT WITH (NOLOCK) ON ANT.C7_FILIAL = RIGHT(SC7.C7_FILIAL, 2) " + CRLF
cQuery += "  AND ANT.C7_NUM = SC7.C7_NUM " + CRLF
cQuery += "  AND ANT.C7_ITEM = SC7.C7_ITEM " + CRLF
cQuery += "  AND CONVERT(VARCHAR(2000),ANT.C7_OBSM) <> CONVERT(VARCHAR(2000),CONVERT(VARBINARY(2000),SC7.C7_OBSM)) " + CRLF
cQuery += "  AND CONVERT(VARCHAR(2000),ANT.C7_OBSM) <> '' " + CRLF
cQuery += "  AND CONVERT(VARCHAR(2000),ANT.C7_OBSM) <> '                              '" + CRLF
cQuery += "  AND ANT.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE LEFT(SC7.C7_FILIAL, 2) = '06' " + CRLF
cQuery += "AND SC7.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "UNION ALL " + CRLF
cQuery += "SELECT SC7.C7_FILIAL, SC7.C7_NUM, SC7.C7_ITEM, CONVERT(VARCHAR(2000),ANT.C7_OBSM) AS ACERTO, CONVERT(VARCHAR(2000),CONVERT(VARBINARY(2000),SC7.C7_OBSM)) AS ERRO " + CRLF
cQuery += "FROM SC7100 AS SC7 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SC7")+" AS ANT WITH (NOLOCK) ON ANT.C7_FILIAL = RIGHT(SC7.C7_FILIAL, 2) " + CRLF
cQuery += "  AND ANT.C7_NUM = SC7.C7_NUM " + CRLF
cQuery += "  AND ANT.C7_ITEM = SC7.C7_ITEM " + CRLF
cQuery += "  AND CONVERT(VARCHAR(2000),ANT.C7_OBSM) <> CONVERT(VARCHAR(2000),CONVERT(VARBINARY(2000),SC7.C7_OBSM)) " + CRLF
cQuery += "  AND CONVERT(VARCHAR(2000),ANT.C7_OBSM) <> '' " + CRLF
cQuery += "  AND CONVERT(VARCHAR(2000),ANT.C7_OBSM) <> '                              '" + CRLF
cQuery += "  AND ANT.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE LEFT(SC7.C7_FILIAL, 2) = '03' " + CRLF
cQuery += "AND SC7.D_E_L_E_T_ = ' ' " + CRLF

TCQuery cQuery New Alias "TMP001"
dbSelectArea("TMP001")
dbGoTop()

Do While !TMP001->( Eof() )
	dbSelectArea("SC7")
	dbSetOrder(1)
	If SC7->( dbSeek( TMP001->C7_FILIAL + TMP001->C7_NUM + TMP001->C7_ITEM ) )
		RecLock("SC7", .F.)
			SC7->C7_OBSM := AllTrim( TMP001->ACERTO )
		MsUnLock()
	EndIf

	TMP001->( dbSkip() )
EndDo

TMP001->( dbCloseArea() )

Alert('Acabou...')
*/
Return
