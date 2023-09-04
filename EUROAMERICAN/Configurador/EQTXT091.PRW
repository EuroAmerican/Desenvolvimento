#Include 'Totvs.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'
#Include 'Protheus.Ch'
#Include 'RwMake.Ch'

// Analisa diferencias no dicionários entre as empresas com chave de tabela compartilhada entre empresas...
// Arquivos dicionários em DBF das empresas: SX301, SX3020, SX303, SX306 E SX308

User Function EQTXT091()

Processa( {|| fAnaDic()}, "Análise Dicionário")

Return

Static Function fAnaDic()

Local aAlias  := {}
Local aDiverg := {}
Local nLin    := 0

//Dicionário Euroamerican...
dbUseArea( .T.,, '\SYSTEM\SX3020.DTC', "SX302", .T.)
dbSelectArea("SX302")
SX302->( dbSetOrder(2) )
dbUseArea( .T.,, '\SYSTEM\SX2020.DTC', "SX202", .T.)
dbSelectArea("SX202")
SX202->( dbSetOrder(1) )
dbUseArea( .T.,, '\SYSTEM\SIX020.DTC', "SIX02", .T.)
dbSelectArea("SIX02")
SIX02->( dbSetOrder(1) )
dbUseArea( .T.,, '\SYSTEM\SX6020.DTC', "SX602", .T.)
dbSelectArea("SX602")
SX602->( dbSetOrder(1) )
dbUseArea( .T.,, '\SYSTEM\SX7020.DTC', "SX702", .T.)
dbSelectArea("SX702")
SX702->( dbSetOrder(1) )

//Dicionário Qualycril...
dbUseArea( .T.,, '\SYSTEM\SX3080.DTC', "SX308", .T.)
dbSelectArea("SX308")
SX308->( dbSetOrder(2) )
dbUseArea( .T.,, '\SYSTEM\SX2080.DTC', "SX208", .T.)
dbSelectArea("SX208")
SX208->( dbSetOrder(1) )
dbUseArea( .T.,, '\SYSTEM\SIX080.DTC', "SIX08", .T.)
dbSelectArea("SIX08")
SIX08->( dbSetOrder(1) )
dbUseArea( .T.,, '\SYSTEM\SX6080.DTC', "SX608", .T.)
dbSelectArea("SX608")
SX608->( dbSetOrder(1) )
dbUseArea( .T.,, '\SYSTEM\SX7080.DTC', "SX708", .T.)
dbSelectArea("SX708")
SX708->( dbSetOrder(1) )

//Dicionário Jays...
dbUseArea( .T.,, '\SYSTEM\SX3010.DTC', "SX301", .T.)
dbSelectArea("SX301")
SX301->( dbSetOrder(2) )
dbUseArea( .T.,, '\SYSTEM\SX2010.DTC', "SX201", .T.)
dbSelectArea("SX201")
SX201->( dbSetOrder(1) )
dbUseArea( .T.,, '\SYSTEM\SIX010.DTC', "SIX01", .T.)
dbSelectArea("SIX01")
SIX01->( dbSetOrder(1) )
dbUseArea( .T.,, '\SYSTEM\SX6010.DTC', "SX601", .T.)
dbSelectArea("SX601")
SX601->( dbSetOrder(1) )
dbUseArea( .T.,, '\SYSTEM\SX7010.DTC', "SX701", .T.)
dbSelectArea("SX701")
SX701->( dbSetOrder(1) )

//Dicionário Metropole...
dbUseArea( .T.,, '\SYSTEM\SX3060.DTC', "SX306", .T.)
dbSelectArea("SX306")
SX306->( dbSetOrder(2) )
dbUseArea( .T.,, '\SYSTEM\SX2060.DTC', "SX206", .T.)
dbSelectArea("SX206")
SX206->( dbSetOrder(1) )
dbUseArea( .T.,, '\SYSTEM\SIX060.DTC', "SIX06", .T.)
dbSelectArea("SIX06")
SIX06->( dbSetOrder(1) )
dbUseArea( .T.,, '\SYSTEM\SX6060.DTC', "SX606", .T.)
dbSelectArea("SX606")
SX606->( dbSetOrder(1) )
dbUseArea( .T.,, '\SYSTEM\SX7060.DTC', "SX706", .T.)
dbSelectArea("SX706")
SX706->( dbSetOrder(1) )

//Dicionário Qualyvinil...
dbUseArea( .T.,, '\SYSTEM\SX3030.DTC', "SX303", .T.)
dbSelectArea("SX303")
SX303->( dbSetOrder(2) )
dbUseArea( .T.,, '\SYSTEM\SX2030.DTC', "SX203", .T.)
dbSelectArea("SX203")
SX203->( dbSetOrder(1) )
dbUseArea( .T.,, '\SYSTEM\SIX030.DTC', "SIX03", .T.)
dbSelectArea("SIX03")
SIX03->( dbSetOrder(1) )
dbUseArea( .T.,, '\SYSTEM\SX6030.DTC', "SX603", .T.)
dbSelectArea("SX603")
SX603->( dbSetOrder(1) )
dbUseArea( .T.,, '\SYSTEM\SX7030.DTC', "SX703", .T.)
dbSelectArea("SX703")
SX703->( dbSetOrder(1) )

//Dicionário Phoenix...
dbUseArea( .T.,, '\SYSTEM\SX3090.DTC', "SX309", .T.)
dbSelectArea("SX309")
SX309->( dbSetOrder(2) )
dbUseArea( .T.,, '\SYSTEM\SX2090.DTC', "SX209", .T.)
dbSelectArea("SX209")
SX209->( dbSetOrder(1) )
dbUseArea( .T.,, '\SYSTEM\SIX090.DTC', "SIX09", .T.)
dbSelectArea("SIX09")
SIX09->( dbSetOrder(1) )
dbUseArea( .T.,, '\SYSTEM\SX6090.DTC', "SX609", .T.)
dbSelectArea("SX609")
SX609->( dbSetOrder(1) )
dbUseArea( .T.,, '\SYSTEM\SX7090.DTC', "SX709", .T.)
dbSelectArea("SX709")
SX709->( dbSetOrder(1) )

//Tratar empresa base 02, ou seja, busca diferença de dicionário de dados da 02 para as demais empresas...
dbSelectArea("SX202")
SX202->( dbGoTop() )
Do While !SX202->( Eof() )
	If !( Right( AllTrim( SX202->X2_ARQUIVO ), 3) $ "000|020" )
		aAdd( aDiverg, { "02", "SX2", "Nome do arquivo fora do padrão: " + AllTrim( SX202->X2_ARQUIVO ) } )
	EndIf

	If !SX208->( dbSeek( SX202->X2_CHAVE ) )
		aAdd( aDiverg, { "02", "SX2", "Chave existente na empresa não existe na empresa 08: " + AllTrim( SX202->X2_CHAVE ) } )
	Else
		If AllTrim( SX202->X2_MODO ) <> AllTrim( SX208->X2_MODO )
			aAdd( aDiverg, { "02", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 08: " + AllTrim( SX202->X2_CHAVE ) } )
		ElseIf AllTrim( SX202->X2_UNICO ) <> AllTrim( SX208->X2_UNICO )
			aAdd( aDiverg, { "02", "SX2", "Chave única da tabela diferença na empresa 08: " + AllTrim( SX202->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX201->( dbSeek( SX202->X2_CHAVE ) )
		aAdd( aDiverg, { "02", "SX2", "Chave existente na empresa não existe na empresa 01: " + AllTrim( SX202->X2_CHAVE ) } )
	Else
		If AllTrim( SX202->X2_MODO ) <> AllTrim( SX201->X2_MODO )
			aAdd( aDiverg, { "02", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 01: " + AllTrim( SX202->X2_CHAVE ) } )
		ElseIf AllTrim( SX202->X2_UNICO ) <> AllTrim( SX201->X2_UNICO )
			aAdd( aDiverg, { "02", "SX2", "Chave única da tabela diferença na empresa 01: " + AllTrim( SX202->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX203->( dbSeek( SX202->X2_CHAVE ) )
		aAdd( aDiverg, { "02", "SX2", "Chave existente na empresa não existe na empresa 03: " + AllTrim( SX202->X2_CHAVE ) } )
	Else
		If AllTrim( SX202->X2_MODO ) <> AllTrim( SX203->X2_MODO )
			aAdd( aDiverg, { "02", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 03: " + AllTrim( SX202->X2_CHAVE ) } )
		ElseIf AllTrim( SX202->X2_UNICO ) <> AllTrim( SX203->X2_UNICO )
			aAdd( aDiverg, { "02", "SX2", "Chave única da tabela diferença na empresa 03: " + AllTrim( SX202->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX206->( dbSeek( SX202->X2_CHAVE ) )
		aAdd( aDiverg, { "02", "SX2", "Chave existente na empresa não existe na empresa 06: " + AllTrim( SX202->X2_CHAVE ) } )
	Else
		If AllTrim( SX202->X2_MODO ) <> AllTrim( SX206->X2_MODO )
			aAdd( aDiverg, { "02", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 06: " + AllTrim( SX202->X2_CHAVE ) } )
		ElseIf AllTrim( SX202->X2_UNICO ) <> AllTrim( SX206->X2_UNICO )
			aAdd( aDiverg, { "02", "SX2", "Chave única da tabela diferença na empresa 06: " + AllTrim( SX202->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX209->( dbSeek( SX202->X2_CHAVE ) )
		aAdd( aDiverg, { "02", "SX2", "Chave existente na empresa não existe na empresa 09: " + AllTrim( SX202->X2_CHAVE ) } )
	Else
 		If AllTrim( SX202->X2_MODO ) <> AllTrim( SX209->X2_MODO )
			aAdd( aDiverg, { "02", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 09: " + AllTrim( SX202->X2_CHAVE ) } )
		ElseIf AllTrim( SX202->X2_UNICO ) <> AllTrim( SX209->X2_UNICO )
			aAdd( aDiverg, { "02", "SX2", "Chave única da tabela diferença na empresa 09: " + AllTrim( SX202->X2_CHAVE ) } )
		EndIf
	EndIf

	SX202->( dbSkip() )
EndDo

dbSelectArea("SX302")
SX302->( dbGoTop() )
Do While !SX302->( Eof() )
	If !SX308->( dbSeek( SX302->X3_CAMPO ) )
		aAdd( aDiverg, { "02", "SX3", "Campo não existe na empresa 08: " + AllTrim( SX302->X3_CAMPO ) } )
	Else
		If AllTrim( SX302->X3_TIPO ) <> AllTrim( SX308->X3_TIPO )
			aAdd( aDiverg, { "02", "SX3", "Tipo do Campo diferente na empresa 08: " + AllTrim( SX302->X3_CAMPO ) } )
		ElseIf SX302->X3_TAMANHO <> SX308->X3_TAMANHO
			aAdd( aDiverg, { "02", "SX3", "Tamanho do Campo diferente na empresa 08: " + AllTrim( SX302->X3_CAMPO ) } )
		ElseIf AllTrim( SX302->X3_CONTEXT ) <> AllTrim( SX308->X3_CONTEXT )
			aAdd( aDiverg, { "02", "SX3", "Contexto do Campo diferente na empresa 08: " + AllTrim( SX302->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX301->( dbSeek( SX302->X3_CAMPO ) )
		aAdd( aDiverg, { "02", "SX3", "Campo não existe na empresa 01: " + AllTrim( SX302->X3_CAMPO ) } )
	Else
		If AllTrim( SX302->X3_TIPO ) <> AllTrim( SX301->X3_TIPO )
			aAdd( aDiverg, { "02", "SX3", "Tipo do Campo diferente na empresa 01: " + AllTrim( SX302->X3_CAMPO ) } )
		ElseIf SX302->X3_TAMANHO <> SX301->X3_TAMANHO
			aAdd( aDiverg, { "02", "SX3", "Tamanho do Campo diferente na empresa 01: " + AllTrim( SX302->X3_CAMPO ) } )
		ElseIf AllTrim( SX302->X3_CONTEXT ) <> AllTrim( SX301->X3_CONTEXT )
			aAdd( aDiverg, { "02", "SX3", "Contexto do Campo diferente na empresa 01: " + AllTrim( SX302->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX303->( dbSeek( SX302->X3_CAMPO ) )
		aAdd( aDiverg, { "02", "SX3", "Campo não existe na empresa 03: " + AllTrim( SX302->X3_CAMPO ) } )
	Else
		If AllTrim( SX302->X3_TIPO ) <> AllTrim( SX303->X3_TIPO )
			aAdd( aDiverg, { "02", "SX3", "Tipo do Campo diferente na empresa 03: " + AllTrim( SX302->X3_CAMPO ) } )
		ElseIf SX302->X3_TAMANHO <> SX303->X3_TAMANHO
			aAdd( aDiverg, { "02", "SX3", "Tamanho do Campo diferente na empresa 03: " + AllTrim( SX302->X3_CAMPO ) } )
		ElseIf AllTrim( SX302->X3_CONTEXT ) <> AllTrim( SX303->X3_CONTEXT )
			aAdd( aDiverg, { "02", "SX3", "Contexto do Campo diferente na empresa 03: " + AllTrim( SX302->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX306->( dbSeek( SX302->X3_CAMPO ) )
		aAdd( aDiverg, { "02", "SX3", "Campo não existe na empresa 06: " + AllTrim( SX302->X3_CAMPO ) } )
	Else
		If AllTrim( SX302->X3_TIPO ) <> AllTrim( SX306->X3_TIPO )
			aAdd( aDiverg, { "02", "SX3", "Tipo do Campo diferente na empresa 06: " + AllTrim( SX302->X3_CAMPO ) } )
		ElseIf SX302->X3_TAMANHO <> SX306->X3_TAMANHO
			aAdd( aDiverg, { "02", "SX3", "Tamanho do Campo diferente na empresa 06: " + AllTrim( SX302->X3_CAMPO ) } )
		ElseIf AllTrim( SX302->X3_CONTEXT ) <> AllTrim( SX306->X3_CONTEXT )
			aAdd( aDiverg, { "02", "SX3", "Contexto do Campo diferente na empresa 06: " + AllTrim( SX302->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX309->( dbSeek( SX302->X3_CAMPO ) )
		aAdd( aDiverg, { "02", "SX3", "Campo não existe na empresa 09: " + AllTrim( SX302->X3_CAMPO ) } )
	Else
		If AllTrim( SX302->X3_TIPO ) <> AllTrim( SX309->X3_TIPO )
			aAdd( aDiverg, { "02", "SX3", "Tipo do Campo diferente na empresa 09: " + AllTrim( SX302->X3_CAMPO ) } )
		ElseIf SX302->X3_TAMANHO <> SX309->X3_TAMANHO
			aAdd( aDiverg, { "02", "SX3", "Tamanho do Campo diferente na empresa 09: " + AllTrim( SX302->X3_CAMPO ) } )
		ElseIf AllTrim( SX302->X3_CONTEXT ) <> AllTrim( SX309->X3_CONTEXT )
			aAdd( aDiverg, { "02", "SX3", "Contexto do Campo diferente na empresa 09: " + AllTrim( SX302->X3_CAMPO ) } )
		EndIf
	EndIf

	SX302->( dbSkip() )
EndDo

dbSelectArea("SIX02")
SIX02->( dbGoTop() )
Do While !SIX02->( Eof() )
	If !SIX08->( dbSeek( SIX02->INDICE + SIX02->ORDEM ) )
		aAdd( aDiverg, { "02", "SIX", "Indice não existe na empresa 08: " + AllTrim( SIX02->INDICE + SIX02->ORDEM ) } )
	Else
		If AllTrim( SIX02->CHAVE ) <> AllTrim( SIX08->CHAVE )
			aAdd( aDiverg, { "02", "SIX", "Chave do indice diferente na empresa 08: " + AllTrim( SIX02->INDICE + SIX02->ORDEM ) } )
		EndIf
	EndIf

	If !SIX01->( dbSeek( SIX02->INDICE + SIX02->ORDEM ) )
		aAdd( aDiverg, { "02", "SIX", "Indice não existe na empresa 01: " + AllTrim( SIX02->INDICE + SIX02->ORDEM ) } )
	Else
		If AllTrim( SIX02->CHAVE ) <> AllTrim( SIX01->CHAVE )
			aAdd( aDiverg, { "02", "SIX", "Chave do indice diferente na empresa 01: " + AllTrim( SIX02->INDICE + SIX02->ORDEM ) } )
		EndIf
	EndIf

	If !SIX03->( dbSeek( SIX02->INDICE + SIX02->ORDEM ) )
		aAdd( aDiverg, { "02", "SIX", "Indice não existe na empresa 03: " + AllTrim( SIX02->INDICE + SIX02->ORDEM ) } )
	Else
		If AllTrim( SIX02->CHAVE ) <> AllTrim( SIX03->CHAVE )
			aAdd( aDiverg, { "02", "SIX", "Chave do indice diferente na empresa 03: " + AllTrim( SIX02->INDICE + SIX02->ORDEM ) } )
		EndIf
	EndIf

	If !SIX06->( dbSeek( SIX02->INDICE + SIX02->ORDEM ) )
		aAdd( aDiverg, { "02", "SIX", "Indice não existe na empresa 06: " + AllTrim( SIX02->INDICE + SIX02->ORDEM ) } )
	Else
		If AllTrim( SIX02->CHAVE ) <> AllTrim( SIX06->CHAVE )
			aAdd( aDiverg, { "02", "SIX", "Chave do indice diferente na empresa 06: " + AllTrim( SIX02->INDICE + SIX02->ORDEM ) } )
		EndIf
	EndIf

	If !SIX09->( dbSeek( SIX02->INDICE + SIX02->ORDEM ) )
		aAdd( aDiverg, { "02", "SIX", "Indice não existe na empresa 09: " + AllTrim( SIX02->INDICE + SIX02->ORDEM ) } )
	Else
		If AllTrim( SIX02->CHAVE ) <> AllTrim( SIX09->CHAVE )
			aAdd( aDiverg, { "02", "SIX", "Chave do indice diferente na empresa 09: " + AllTrim( SIX02->INDICE + SIX02->ORDEM ) } )
		EndIf
	EndIf

	SIX02->( dbSkip() )
EndDo

dbSelectArea("SX602")
SX602->( dbGoTop() )
Do While !SX602->( Eof() )
	If !SX608->( dbSeek( SX602->X6_FIL + SX602->X6_VAR ) )
		aAdd( aDiverg, { "02", "SX6", "Parametro não existe na empresa 08: " + AllTrim( SX602->X6_FIL + SX602->X6_VAR ) } )
	Else
		If AllTrim( SX602->X6_TIPO ) <> AllTrim( SX608->X6_TIPO )
			aAdd( aDiverg, { "02", "SX6", "Tipo do parametro diferente na empresa 08: " + AllTrim( SX602->X6_FIL + SX602->X6_VAR ) } )
		ElseIf AllTrim( SX602->X6_CONTEUD ) <> AllTrim( SX608->X6_CONTEUD )
			aAdd( aDiverg, { "02", "SX6", "Conteudo do parametro diferente na empresa 08: " + AllTrim( SX602->X6_FIL + SX602->X6_VAR ) } )
		EndIf
	EndIf

	If !SX601->( dbSeek( SX602->X6_FIL + SX602->X6_VAR ) )
		aAdd( aDiverg, { "02", "SX6", "Parametro não existe na empresa 01: " + AllTrim( SX602->X6_FIL + SX602->X6_VAR ) } )
	Else
		If AllTrim( SX602->X6_TIPO ) <> AllTrim( SX601->X6_TIPO )
			aAdd( aDiverg, { "02", "SX6", "Tipo do parametro diferente na empresa 01: " + AllTrim( SX602->X6_FIL + SX602->X6_VAR ) } )
		ElseIf AllTrim( SX602->X6_CONTEUD ) <> AllTrim( SX601->X6_CONTEUD )
			aAdd( aDiverg, { "02", "SX6", "Conteudo do parametro diferente na empresa 01: " + AllTrim( SX602->X6_FIL + SX602->X6_VAR ) } )
		EndIf
	EndIf

	If !SX603->( dbSeek( SX602->X6_FIL + SX602->X6_VAR ) )
		aAdd( aDiverg, { "02", "SX6", "Parametro não existe na empresa 03: " + AllTrim( SX602->X6_FIL + SX602->X6_VAR ) } )
	Else
		If AllTrim( SX602->X6_TIPO ) <> AllTrim( SX603->X6_TIPO )
			aAdd( aDiverg, { "02", "SX6", "Tipo do parametro diferente na empresa 03: " + AllTrim( SX602->X6_FIL + SX602->X6_VAR ) } )
		ElseIf AllTrim( SX602->X6_CONTEUD ) <> AllTrim( SX603->X6_CONTEUD )
			aAdd( aDiverg, { "02", "SX6", "Conteudo do parametro diferente na empresa 03: " + AllTrim( SX602->X6_FIL + SX602->X6_VAR ) } )
		EndIf
	EndIf

	If !SX606->( dbSeek( SX602->X6_FIL + SX602->X6_VAR ) )
		aAdd( aDiverg, { "02", "SX6", "Parametro não existe na empresa 06: " + AllTrim( SX602->X6_FIL + SX602->X6_VAR ) } )
	Else
		If AllTrim( SX602->X6_TIPO ) <> AllTrim( SX606->X6_TIPO )
			aAdd( aDiverg, { "02", "SX6", "Tipo do parametro diferente na empresa 06: " + AllTrim( SX602->X6_FIL + SX602->X6_VAR ) } )
		ElseIf AllTrim( SX602->X6_CONTEUD ) <> AllTrim( SX606->X6_CONTEUD )
			aAdd( aDiverg, { "02", "SX6", "Conteudo do parametro diferente na empresa 06: " + AllTrim( SX602->X6_FIL + SX602->X6_VAR ) } )
		EndIf
	EndIf

	If !SX609->( dbSeek( SX602->X6_FIL + SX602->X6_VAR ) )
		aAdd( aDiverg, { "02", "SX6", "Parametro não existe na empresa 09: " + AllTrim( SX602->X6_FIL + SX602->X6_VAR ) } )
	Else
		If AllTrim( SX602->X6_TIPO ) <> AllTrim( SX609->X6_TIPO )
			aAdd( aDiverg, { "02", "SX6", "Tipo do parametro diferente na empresa 09: " + AllTrim( SX602->X6_FIL + SX602->X6_VAR ) } )
		ElseIf AllTrim( SX602->X6_CONTEUD ) <> AllTrim( SX609->X6_CONTEUD )
			aAdd( aDiverg, { "02", "SX6", "Conteudo do parametro diferente na empresa 09: " + AllTrim( SX602->X6_FIL + SX602->X6_VAR ) } )
		EndIf
	EndIf

	SX602->( dbSkip() )
EndDo

//Tratar empresa base 08, ou seja, busca diferença de dicionário de dados da 08 para as demais empresas...
dbSelectArea("SX208")
SX208->( dbGoTop() )
Do While !SX208->( Eof() )
	If !( Right( AllTrim( SX208->X2_ARQUIVO ), 3) $ "000|080" )
		aAdd( aDiverg, { "08", "SX2", "Nome do arquivo fora do padrão: " + AllTrim( SX208->X2_ARQUIVO ) } )
	EndIf

	If !SX202->( dbSeek( SX208->X2_CHAVE ) )
		aAdd( aDiverg, { "08", "SX2", "Chave existente na empresa não existe na empresa 02: " + AllTrim( SX208->X2_CHAVE ) } )
	Else
		If AllTrim( SX208->X2_MODO ) <> AllTrim( SX202->X2_MODO )
			aAdd( aDiverg, { "08", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 02: " + AllTrim( SX208->X2_CHAVE ) } )
		ElseIf AllTrim( SX208->X2_UNICO ) <> AllTrim( SX202->X2_UNICO )
			aAdd( aDiverg, { "08", "SX2", "Chave única da tabela diferença na empresa 02: " + AllTrim( SX208->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX201->( dbSeek( SX208->X2_CHAVE ) )
		aAdd( aDiverg, { "08", "SX2", "Chave existente na empresa não existe na empresa 01: " + AllTrim( SX208->X2_CHAVE ) } )
	Else
		If AllTrim( SX208->X2_MODO ) <> AllTrim( SX201->X2_MODO )
			aAdd( aDiverg, { "08", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 01: " + AllTrim( SX208->X2_CHAVE ) } )
		ElseIf AllTrim( SX208->X2_UNICO ) <> AllTrim( SX201->X2_UNICO )
			aAdd( aDiverg, { "08", "SX2", "Chave única da tabela diferença na empresa 01: " + AllTrim( SX208->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX203->( dbSeek( SX208->X2_CHAVE ) )
		aAdd( aDiverg, { "08", "SX2", "Chave existente na empresa não existe na empresa 03: " + AllTrim( SX208->X2_CHAVE ) } )
	Else
		If AllTrim( SX208->X2_MODO ) <> AllTrim( SX203->X2_MODO )
			aAdd( aDiverg, { "08", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 03: " + AllTrim( SX208->X2_CHAVE ) } )
		ElseIf AllTrim( SX208->X2_UNICO ) <> AllTrim( SX203->X2_UNICO )
			aAdd( aDiverg, { "08", "SX2", "Chave única da tabela diferença na empresa 03: " + AllTrim( SX208->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX206->( dbSeek( SX208->X2_CHAVE ) )
		aAdd( aDiverg, { "08", "SX2", "Chave existente na empresa não existe na empresa 06: " + AllTrim( SX208->X2_CHAVE ) } )
	Else
		If AllTrim( SX208->X2_MODO ) <> AllTrim( SX206->X2_MODO )
			aAdd( aDiverg, { "08", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 06: " + AllTrim( SX208->X2_CHAVE ) } )
		ElseIf AllTrim( SX208->X2_UNICO ) <> AllTrim( SX206->X2_UNICO )
			aAdd( aDiverg, { "08", "SX2", "Chave única da tabela diferença na empresa 06: " + AllTrim( SX208->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX209->( dbSeek( SX208->X2_CHAVE ) )
		aAdd( aDiverg, { "08", "SX2", "Chave existente na empresa não existe na empresa 09: " + AllTrim( SX208->X2_CHAVE ) } )
	Else
 		If AllTrim( SX208->X2_MODO ) <> AllTrim( SX209->X2_MODO )
			aAdd( aDiverg, { "08", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 09: " + AllTrim( SX208->X2_CHAVE ) } )
		ElseIf AllTrim( SX208->X2_UNICO ) <> AllTrim( SX209->X2_UNICO )
			aAdd( aDiverg, { "08", "SX2", "Chave única da tabela diferença na empresa 09: " + AllTrim( SX208->X2_CHAVE ) } )
		EndIf
	EndIf

	SX208->( dbSkip() )
EndDo

dbSelectArea("SX308")
SX308->( dbGoTop() )
Do While !SX308->( Eof() )
	If !SX302->( dbSeek( SX308->X3_CAMPO ) )
		aAdd( aDiverg, { "08", "SX3", "Campo não existe na empresa 02: " + AllTrim( SX308->X3_CAMPO ) } )
	Else
		If AllTrim( SX308->X3_TIPO ) <> AllTrim( SX302->X3_TIPO )
			aAdd( aDiverg, { "08", "SX3", "Tipo do Campo diferente na empresa 02: " + AllTrim( SX308->X3_CAMPO ) } )
		ElseIf SX308->X3_TAMANHO <> SX302->X3_TAMANHO
			aAdd( aDiverg, { "08", "SX3", "Tamanho do Campo diferente na empresa 02: " + AllTrim( SX308->X3_CAMPO ) } )
		ElseIf AllTrim( SX308->X3_CONTEXT ) <> AllTrim( SX302->X3_CONTEXT )
			aAdd( aDiverg, { "08", "SX3", "Contexto do Campo diferente na empresa 02: " + AllTrim( SX308->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX301->( dbSeek( SX308->X3_CAMPO ) )
		aAdd( aDiverg, { "08", "SX3", "Campo não existe na empresa 01: " + AllTrim( SX308->X3_CAMPO ) } )
	Else
		If AllTrim( SX308->X3_TIPO ) <> AllTrim( SX301->X3_TIPO )
			aAdd( aDiverg, { "08", "SX3", "Tipo do Campo diferente na empresa 01: " + AllTrim( SX308->X3_CAMPO ) } )
		ElseIf SX308->X3_TAMANHO <> SX301->X3_TAMANHO
			aAdd( aDiverg, { "08", "SX3", "Tamanho do Campo diferente na empresa 01: " + AllTrim( SX308->X3_CAMPO ) } )
		ElseIf AllTrim( SX308->X3_CONTEXT ) <> AllTrim( SX301->X3_CONTEXT )
			aAdd( aDiverg, { "08", "SX3", "Contexto do Campo diferente na empresa 01: " + AllTrim( SX308->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX303->( dbSeek( SX308->X3_CAMPO ) )
		aAdd( aDiverg, { "08", "SX3", "Campo não existe na empresa 03: " + AllTrim( SX308->X3_CAMPO ) } )
	Else
		If AllTrim( SX308->X3_TIPO ) <> AllTrim( SX303->X3_TIPO )
			aAdd( aDiverg, { "08", "SX3", "Tipo do Campo diferente na empresa 03: " + AllTrim( SX308->X3_CAMPO ) } )
		ElseIf SX308->X3_TAMANHO <> SX303->X3_TAMANHO
			aAdd( aDiverg, { "08", "SX3", "Tamanho do Campo diferente na empresa 03: " + AllTrim( SX308->X3_CAMPO ) } )
		ElseIf AllTrim( SX308->X3_CONTEXT ) <> AllTrim( SX303->X3_CONTEXT )
			aAdd( aDiverg, { "08", "SX3", "Contexto do Campo diferente na empresa 03: " + AllTrim( SX308->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX306->( dbSeek( SX308->X3_CAMPO ) )
		aAdd( aDiverg, { "08", "SX3", "Campo não existe na empresa 06: " + AllTrim( SX308->X3_CAMPO ) } )
	Else
		If AllTrim( SX308->X3_TIPO ) <> AllTrim( SX306->X3_TIPO )
			aAdd( aDiverg, { "08", "SX3", "Tipo do Campo diferente na empresa 06: " + AllTrim( SX308->X3_CAMPO ) } )
		ElseIf SX308->X3_TAMANHO <> SX306->X3_TAMANHO
			aAdd( aDiverg, { "08", "SX3", "Tamanho do Campo diferente na empresa 06: " + AllTrim( SX308->X3_CAMPO ) } )
		ElseIf AllTrim( SX308->X3_CONTEXT ) <> AllTrim( SX306->X3_CONTEXT )
			aAdd( aDiverg, { "08", "SX3", "Contexto do Campo diferente na empresa 06: " + AllTrim( SX308->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX309->( dbSeek( SX308->X3_CAMPO ) )
		aAdd( aDiverg, { "08", "SX3", "Campo não existe na empresa 09: " + AllTrim( SX308->X3_CAMPO ) } )
	Else
		If AllTrim( SX308->X3_TIPO ) <> AllTrim( SX309->X3_TIPO )
			aAdd( aDiverg, { "08", "SX3", "Tipo do Campo diferente na empresa 09: " + AllTrim( SX308->X3_CAMPO ) } )
		ElseIf SX308->X3_TAMANHO <> SX309->X3_TAMANHO
			aAdd( aDiverg, { "08", "SX3", "Tamanho do Campo diferente na empresa 09: " + AllTrim( SX308->X3_CAMPO ) } )
		ElseIf AllTrim( SX308->X3_CONTEXT ) <> AllTrim( SX309->X3_CONTEXT )
			aAdd( aDiverg, { "08", "SX3", "Contexto do Campo diferente na empresa 09: " + AllTrim( SX308->X3_CAMPO ) } )
		EndIf
	EndIf

	SX308->( dbSkip() )
EndDo

dbSelectArea("SIX08")
SIX08->( dbGoTop() )
Do While !SIX08->( Eof() )
	If !SIX02->( dbSeek( SIX08->INDICE + SIX08->ORDEM ) )
		aAdd( aDiverg, { "08", "SIX", "Indice não existe na empresa 02: " + AllTrim( SIX08->INDICE + SIX08->ORDEM ) } )
	Else
		If AllTrim( SIX08->CHAVE ) <> AllTrim( SIX02->CHAVE )
			aAdd( aDiverg, { "08", "SIX", "Chave do indice diferente na empresa 02: " + AllTrim( SIX08->INDICE + SIX08->ORDEM ) } )
		EndIf
	EndIf

	If !SIX01->( dbSeek( SIX08->INDICE + SIX08->ORDEM ) )
		aAdd( aDiverg, { "08", "SIX", "Indice não existe na empresa 01: " + AllTrim( SIX08->INDICE + SIX08->ORDEM ) } )
	Else
		If AllTrim( SIX08->CHAVE ) <> AllTrim( SIX01->CHAVE )
			aAdd( aDiverg, { "08", "SIX", "Chave do indice diferente na empresa 01: " + AllTrim( SIX08->INDICE + SIX08->ORDEM ) } )
		EndIf
	EndIf

	If !SIX03->( dbSeek( SIX08->INDICE + SIX08->ORDEM ) )
		aAdd( aDiverg, { "08", "SIX", "Indice não existe na empresa 03: " + AllTrim( SIX08->INDICE + SIX08->ORDEM ) } )
	Else
		If AllTrim( SIX08->CHAVE ) <> AllTrim( SIX03->CHAVE )
			aAdd( aDiverg, { "08", "SIX", "Chave do indice diferente na empresa 03: " + AllTrim( SIX08->INDICE + SIX08->ORDEM ) } )
		EndIf
	EndIf

	If !SIX06->( dbSeek( SIX08->INDICE + SIX08->ORDEM ) )
		aAdd( aDiverg, { "08", "SIX", "Indice não existe na empresa 06: " + AllTrim( SIX08->INDICE + SIX08->ORDEM ) } )
	Else
		If AllTrim( SIX08->CHAVE ) <> AllTrim( SIX06->CHAVE )
			aAdd( aDiverg, { "08", "SIX", "Chave do indice diferente na empresa 06: " + AllTrim( SIX08->INDICE + SIX08->ORDEM ) } )
		EndIf
	EndIf

	If !SIX09->( dbSeek( SIX08->INDICE + SIX08->ORDEM ) )
		aAdd( aDiverg, { "08", "SIX", "Indice não existe na empresa 09: " + AllTrim( SIX08->INDICE + SIX08->ORDEM ) } )
	Else
		If AllTrim( SIX08->CHAVE ) <> AllTrim( SIX09->CHAVE )
			aAdd( aDiverg, { "08", "SIX", "Chave do indice diferente na empresa 09: " + AllTrim( SIX08->INDICE + SIX08->ORDEM ) } )
		EndIf
	EndIf

	SIX08->( dbSkip() )
EndDo

dbSelectArea("SX608")
SX608->( dbGoTop() )
Do While !SX608->( Eof() )
	If !SX602->( dbSeek( SX608->X6_FIL + SX608->X6_VAR ) )
		aAdd( aDiverg, { "08", "SX6", "Parametro não existe na empresa 02: " + AllTrim( SX608->X6_FIL + SX608->X6_VAR ) } )
	Else
		If AllTrim( SX608->X6_TIPO ) <> AllTrim( SX602->X6_TIPO )
			aAdd( aDiverg, { "08", "SX6", "Tipo do parametro diferente na empresa 02: " + AllTrim( SX608->X6_FIL + SX608->X6_VAR ) } )
		ElseIf AllTrim( SX608->X6_CONTEUD ) <> AllTrim( SX602->X6_CONTEUD )
			aAdd( aDiverg, { "08", "SX6", "Conteudo do parametro diferente na empresa 02: " + AllTrim( SX608->X6_FIL + SX608->X6_VAR ) } )
		EndIf
	EndIf

	If !SX601->( dbSeek( SX608->X6_FIL + SX608->X6_VAR ) )
		aAdd( aDiverg, { "08", "SX6", "Parametro não existe na empresa 01: " + AllTrim( SX608->X6_FIL + SX608->X6_VAR ) } )
	Else
		If AllTrim( SX608->X6_TIPO ) <> AllTrim( SX601->X6_TIPO )
			aAdd( aDiverg, { "08", "SX6", "Tipo do parametro diferente na empresa 01: " + AllTrim( SX608->X6_FIL + SX608->X6_VAR ) } )
		ElseIf AllTrim( SX608->X6_CONTEUD ) <> AllTrim( SX601->X6_CONTEUD )
			aAdd( aDiverg, { "08", "SX6", "Conteudo do parametro diferente na empresa 01: " + AllTrim( SX608->X6_FIL + SX608->X6_VAR ) } )
		EndIf
	EndIf

	If !SX603->( dbSeek( SX608->X6_FIL + SX608->X6_VAR ) )
		aAdd( aDiverg, { "08", "SX6", "Parametro não existe na empresa 03: " + AllTrim( SX608->X6_FIL + SX608->X6_VAR ) } )
	Else
		If AllTrim( SX608->X6_TIPO ) <> AllTrim( SX603->X6_TIPO )
			aAdd( aDiverg, { "08", "SX6", "Tipo do parametro diferente na empresa 03: " + AllTrim( SX608->X6_FIL + SX608->X6_VAR ) } )
		ElseIf AllTrim( SX608->X6_CONTEUD ) <> AllTrim( SX603->X6_CONTEUD )
			aAdd( aDiverg, { "08", "SX6", "Conteudo do parametro diferente na empresa 03: " + AllTrim( SX608->X6_FIL + SX608->X6_VAR ) } )
		EndIf
	EndIf

	If !SX606->( dbSeek( SX608->X6_FIL + SX608->X6_VAR ) )
		aAdd( aDiverg, { "08", "SX6", "Parametro não existe na empresa 06: " + AllTrim( SX608->X6_FIL + SX608->X6_VAR ) } )
	Else
		If AllTrim( SX608->X6_TIPO ) <> AllTrim( SX606->X6_TIPO )
			aAdd( aDiverg, { "08", "SX6", "Tipo do parametro diferente na empresa 06: " + AllTrim( SX608->X6_FIL + SX608->X6_VAR ) } )
		ElseIf AllTrim( SX608->X6_CONTEUD ) <> AllTrim( SX606->X6_CONTEUD )
			aAdd( aDiverg, { "08", "SX6", "Conteudo do parametro diferente na empresa 06: " + AllTrim( SX608->X6_FIL + SX608->X6_VAR ) } )
		EndIf
	EndIf

	If !SX609->( dbSeek( SX608->X6_FIL + SX608->X6_VAR ) )
		aAdd( aDiverg, { "08", "SX6", "Parametro não existe na empresa 09: " + AllTrim( SX608->X6_FIL + SX608->X6_VAR ) } )
	Else
		If AllTrim( SX608->X6_TIPO ) <> AllTrim( SX609->X6_TIPO )
			aAdd( aDiverg, { "08", "SX6", "Tipo do parametro diferente na empresa 09: " + AllTrim( SX608->X6_FIL + SX608->X6_VAR ) } )
		ElseIf AllTrim( SX608->X6_CONTEUD ) <> AllTrim( SX609->X6_CONTEUD )
			aAdd( aDiverg, { "08", "SX6", "Conteudo do parametro diferente na empresa 09: " + AllTrim( SX608->X6_FIL + SX608->X6_VAR ) } )
		EndIf
	EndIf

	SX608->( dbSkip() )
EndDo

//Tratar empresa base 01, ou seja, busca diferença de dicionário de dados da 01 para as demais empresas...
dbSelectArea("SX201")
SX201->( dbGoTop() )
Do While !SX201->( Eof() )
	If !( Right( AllTrim( SX201->X2_ARQUIVO ), 3) $ "000|010" )
		aAdd( aDiverg, { "01", "SX2", "Nome do arquivo fora do padrão: " + AllTrim( SX201->X2_ARQUIVO ) } )
	EndIf

	If !SX202->( dbSeek( SX201->X2_CHAVE ) )
		aAdd( aDiverg, { "01", "SX2", "Chave existente na empresa não existe na empresa 02: " + AllTrim( SX201->X2_CHAVE ) } )
	Else
		If AllTrim( SX201->X2_MODO ) <> AllTrim( SX202->X2_MODO )
			aAdd( aDiverg, { "01", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 02: " + AllTrim( SX201->X2_CHAVE ) } )
		ElseIf AllTrim( SX201->X2_UNICO ) <> AllTrim( SX202->X2_UNICO )
			aAdd( aDiverg, { "01", "SX2", "Chave única da tabela diferença na empresa 02: " + AllTrim( SX201->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX208->( dbSeek( SX201->X2_CHAVE ) )
		aAdd( aDiverg, { "01", "SX2", "Chave existente na empresa não existe na empresa 08: " + AllTrim( SX201->X2_CHAVE ) } )
	Else
		If AllTrim( SX201->X2_MODO ) <> AllTrim( SX208->X2_MODO )
			aAdd( aDiverg, { "01", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 08: " + AllTrim( SX201->X2_CHAVE ) } )
		ElseIf AllTrim( SX201->X2_UNICO ) <> AllTrim( SX208->X2_UNICO )
			aAdd( aDiverg, { "01", "SX2", "Chave única da tabela diferença na empresa 08: " + AllTrim( SX201->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX203->( dbSeek( SX201->X2_CHAVE ) )
		aAdd( aDiverg, { "01", "SX2", "Chave existente na empresa não existe na empresa 03: " + AllTrim( SX201->X2_CHAVE ) } )
	Else
		If AllTrim( SX201->X2_MODO ) <> AllTrim( SX203->X2_MODO )
			aAdd( aDiverg, { "01", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 03: " + AllTrim( SX201->X2_CHAVE ) } )
		ElseIf AllTrim( SX201->X2_UNICO ) <> AllTrim( SX203->X2_UNICO )
			aAdd( aDiverg, { "01", "SX2", "Chave única da tabela diferença na empresa 03: " + AllTrim( SX201->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX206->( dbSeek( SX201->X2_CHAVE ) )
		aAdd( aDiverg, { "01", "SX2", "Chave existente na empresa não existe na empresa 06: " + AllTrim( SX201->X2_CHAVE ) } )
	Else
		If AllTrim( SX201->X2_MODO ) <> AllTrim( SX206->X2_MODO )
			aAdd( aDiverg, { "01", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 06: " + AllTrim( SX201->X2_CHAVE ) } )
		ElseIf AllTrim( SX201->X2_UNICO ) <> AllTrim( SX206->X2_UNICO )
			aAdd( aDiverg, { "01", "SX2", "Chave única da tabela diferença na empresa 06: " + AllTrim( SX201->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX209->( dbSeek( SX201->X2_CHAVE ) )
		aAdd( aDiverg, { "01", "SX2", "Chave existente na empresa não existe na empresa 09: " + AllTrim( SX201->X2_CHAVE ) } )
	Else
 		If AllTrim( SX201->X2_MODO ) <> AllTrim( SX209->X2_MODO )
			aAdd( aDiverg, { "01", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 09: " + AllTrim( SX201->X2_CHAVE ) } )
		ElseIf AllTrim( SX201->X2_UNICO ) <> AllTrim( SX209->X2_UNICO )
			aAdd( aDiverg, { "01", "SX2", "Chave única da tabela diferença na empresa 09: " + AllTrim( SX201->X2_CHAVE ) } )
		EndIf
	EndIf

	SX201->( dbSkip() )
EndDo

dbSelectArea("SX301")
SX301->( dbGoTop() )
Do While !SX301->( Eof() )
	If !SX302->( dbSeek( SX301->X3_CAMPO ) )
		aAdd( aDiverg, { "01", "SX3", "Campo não existe na empresa 02: " + AllTrim( SX301->X3_CAMPO ) } )
	Else
		If AllTrim( SX301->X3_TIPO ) <> AllTrim( SX302->X3_TIPO )
			aAdd( aDiverg, { "01", "SX3", "Tipo do Campo diferente na empresa 02: " + AllTrim( SX301->X3_CAMPO ) } )
		ElseIf SX301->X3_TAMANHO <> SX302->X3_TAMANHO
			aAdd( aDiverg, { "01", "SX3", "Tamanho do Campo diferente na empresa 02: " + AllTrim( SX301->X3_CAMPO ) } )
		ElseIf AllTrim( SX301->X3_CONTEXT ) <> AllTrim( SX302->X3_CONTEXT )
			aAdd( aDiverg, { "01", "SX3", "Contexto do Campo diferente na empresa 02: " + AllTrim( SX301->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX308->( dbSeek( SX301->X3_CAMPO ) )
		aAdd( aDiverg, { "01", "SX3", "Campo não existe na empresa 08: " + AllTrim( SX301->X3_CAMPO ) } )
	Else
		If AllTrim( SX301->X3_TIPO ) <> AllTrim( SX308->X3_TIPO )
			aAdd( aDiverg, { "01", "SX3", "Tipo do Campo diferente na empresa 08: " + AllTrim( SX301->X3_CAMPO ) } )
		ElseIf SX301->X3_TAMANHO <> SX308->X3_TAMANHO
			aAdd( aDiverg, { "01", "SX3", "Tamanho do Campo diferente na empresa 08: " + AllTrim( SX301->X3_CAMPO ) } )
		ElseIf AllTrim( SX301->X3_CONTEXT ) <> AllTrim( SX308->X3_CONTEXT )
			aAdd( aDiverg, { "01", "SX3", "Contexto do Campo diferente na empresa 08: " + AllTrim( SX301->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX303->( dbSeek( SX301->X3_CAMPO ) )
		aAdd( aDiverg, { "01", "SX3", "Campo não existe na empresa 03: " + AllTrim( SX301->X3_CAMPO ) } )
	Else
		If AllTrim( SX301->X3_TIPO ) <> AllTrim( SX303->X3_TIPO )
			aAdd( aDiverg, { "01", "SX3", "Tipo do Campo diferente na empresa 03: " + AllTrim( SX301->X3_CAMPO ) } )
		ElseIf SX301->X3_TAMANHO <> SX303->X3_TAMANHO
			aAdd( aDiverg, { "01", "SX3", "Tamanho do Campo diferente na empresa 03: " + AllTrim( SX301->X3_CAMPO ) } )
		ElseIf AllTrim( SX301->X3_CONTEXT ) <> AllTrim( SX303->X3_CONTEXT )
			aAdd( aDiverg, { "01", "SX3", "Contexto do Campo diferente na empresa 03: " + AllTrim( SX301->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX306->( dbSeek( SX301->X3_CAMPO ) )
		aAdd( aDiverg, { "01", "SX3", "Campo não existe na empresa 06: " + AllTrim( SX301->X3_CAMPO ) } )
	Else
		If AllTrim( SX301->X3_TIPO ) <> AllTrim( SX306->X3_TIPO )
			aAdd( aDiverg, { "01", "SX3", "Tipo do Campo diferente na empresa 06: " + AllTrim( SX301->X3_CAMPO ) } )
		ElseIf SX301->X3_TAMANHO <> SX306->X3_TAMANHO
			aAdd( aDiverg, { "01", "SX3", "Tamanho do Campo diferente na empresa 06: " + AllTrim( SX301->X3_CAMPO ) } )
		ElseIf AllTrim( SX301->X3_CONTEXT ) <> AllTrim( SX306->X3_CONTEXT )
			aAdd( aDiverg, { "01", "SX3", "Contexto do Campo diferente na empresa 06: " + AllTrim( SX301->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX309->( dbSeek( SX301->X3_CAMPO ) )
		aAdd( aDiverg, { "01", "SX3", "Campo não existe na empresa 09: " + AllTrim( SX301->X3_CAMPO ) } )
	Else
		If AllTrim( SX301->X3_TIPO ) <> AllTrim( SX309->X3_TIPO )
			aAdd( aDiverg, { "01", "SX3", "Tipo do Campo diferente na empresa 09: " + AllTrim( SX301->X3_CAMPO ) } )
		ElseIf SX301->X3_TAMANHO <> SX309->X3_TAMANHO
			aAdd( aDiverg, { "01", "SX3", "Tamanho do Campo diferente na empresa 09: " + AllTrim( SX301->X3_CAMPO ) } )
		ElseIf AllTrim( SX301->X3_CONTEXT ) <> AllTrim( SX309->X3_CONTEXT )
			aAdd( aDiverg, { "01", "SX3", "Contexto do Campo diferente na empresa 09: " + AllTrim( SX301->X3_CAMPO ) } )
		EndIf
	EndIf

	SX301->( dbSkip() )
EndDo

dbSelectArea("SIX01")
SIX01->( dbGoTop() )
Do While !SIX01->( Eof() )
	If !SIX02->( dbSeek( SIX01->INDICE + SIX01->ORDEM ) )
		aAdd( aDiverg, { "01", "SIX", "Indice não existe na empresa 02: " + AllTrim( SIX01->INDICE + SIX01->ORDEM ) } )
	Else
		If AllTrim( SIX01->CHAVE ) <> AllTrim( SIX02->CHAVE )
			aAdd( aDiverg, { "01", "SIX", "Chave do indice diferente na empresa 02: " + AllTrim( SIX01->INDICE + SIX01->ORDEM ) } )
		EndIf
	EndIf

	If !SIX08->( dbSeek( SIX01->INDICE + SIX01->ORDEM ) )
		aAdd( aDiverg, { "01", "SIX", "Indice não existe na empresa 08: " + AllTrim( SIX01->INDICE + SIX01->ORDEM ) } )
	Else
		If AllTrim( SIX01->CHAVE ) <> AllTrim( SIX08->CHAVE )
			aAdd( aDiverg, { "01", "SIX", "Chave do indice diferente na empresa 08: " + AllTrim( SIX01->INDICE + SIX01->ORDEM ) } )
		EndIf
	EndIf

	If !SIX03->( dbSeek( SIX01->INDICE + SIX01->ORDEM ) )
		aAdd( aDiverg, { "01", "SIX", "Indice não existe na empresa 03: " + AllTrim( SIX01->INDICE + SIX01->ORDEM ) } )
	Else
		If AllTrim( SIX01->CHAVE ) <> AllTrim( SIX03->CHAVE )
			aAdd( aDiverg, { "01", "SIX", "Chave do indice diferente na empresa 03: " + AllTrim( SIX01->INDICE + SIX01->ORDEM ) } )
		EndIf
	EndIf

	If !SIX06->( dbSeek( SIX01->INDICE + SIX01->ORDEM ) )
		aAdd( aDiverg, { "01", "SIX", "Indice não existe na empresa 06: " + AllTrim( SIX01->INDICE + SIX01->ORDEM ) } )
	Else
		If AllTrim( SIX01->CHAVE ) <> AllTrim( SIX06->CHAVE )
			aAdd( aDiverg, { "01", "SIX", "Chave do indice diferente na empresa 06: " + AllTrim( SIX01->INDICE + SIX01->ORDEM ) } )
		EndIf
	EndIf

	If !SIX09->( dbSeek( SIX01->INDICE + SIX01->ORDEM ) )
		aAdd( aDiverg, { "01", "SIX", "Indice não existe na empresa 09: " + AllTrim( SIX01->INDICE + SIX01->ORDEM ) } )
	Else
		If AllTrim( SIX01->CHAVE ) <> AllTrim( SIX09->CHAVE )
			aAdd( aDiverg, { "01", "SIX", "Chave do indice diferente na empresa 09: " + AllTrim( SIX01->INDICE + SIX01->ORDEM ) } )
		EndIf
	EndIf

	SIX01->( dbSkip() )
EndDo

dbSelectArea("SX601")
SX601->( dbGoTop() )
Do While !SX601->( Eof() )
	If !SX602->( dbSeek( SX601->X6_FIL + SX601->X6_VAR ) )
		aAdd( aDiverg, { "01", "SX6", "Parametro não existe na empresa 02: " + AllTrim( SX601->X6_FIL + SX601->X6_VAR ) } )
	Else
		If AllTrim( SX601->X6_TIPO ) <> AllTrim( SX602->X6_TIPO )
			aAdd( aDiverg, { "01", "SX6", "Tipo do parametro diferente na empresa 02: " + AllTrim( SX601->X6_FIL + SX601->X6_VAR ) } )
		ElseIf AllTrim( SX601->X6_CONTEUD ) <> AllTrim( SX602->X6_CONTEUD )
			aAdd( aDiverg, { "01", "SX6", "Conteudo do parametro diferente na empresa 02: " + AllTrim( SX601->X6_FIL + SX601->X6_VAR ) } )
		EndIf
	EndIf

	If !SX608->( dbSeek( SX601->X6_FIL + SX601->X6_VAR ) )
		aAdd( aDiverg, { "01", "SX6", "Parametro não existe na empresa 08: " + AllTrim( SX601->X6_FIL + SX601->X6_VAR ) } )
	Else
		If AllTrim( SX601->X6_TIPO ) <> AllTrim( SX608->X6_TIPO )
			aAdd( aDiverg, { "01", "SX6", "Tipo do parametro diferente na empresa 08: " + AllTrim( SX601->X6_FIL + SX601->X6_VAR ) } )
		ElseIf AllTrim( SX601->X6_CONTEUD ) <> AllTrim( SX608->X6_CONTEUD )
			aAdd( aDiverg, { "01", "SX6", "Conteudo do parametro diferente na empresa 08: " + AllTrim( SX601->X6_FIL + SX601->X6_VAR ) } )
		EndIf
	EndIf

	If !SX603->( dbSeek( SX601->X6_FIL + SX601->X6_VAR ) )
		aAdd( aDiverg, { "01", "SX6", "Parametro não existe na empresa 03: " + AllTrim( SX601->X6_FIL + SX601->X6_VAR ) } )
	Else
		If AllTrim( SX601->X6_TIPO ) <> AllTrim( SX603->X6_TIPO )
			aAdd( aDiverg, { "01", "SX6", "Tipo do parametro diferente na empresa 03: " + AllTrim( SX601->X6_FIL + SX601->X6_VAR ) } )
		ElseIf AllTrim( SX601->X6_CONTEUD ) <> AllTrim( SX603->X6_CONTEUD )
			aAdd( aDiverg, { "01", "SX6", "Conteudo do parametro diferente na empresa 03: " + AllTrim( SX601->X6_FIL + SX601->X6_VAR ) } )
		EndIf
	EndIf

	If !SX606->( dbSeek( SX601->X6_FIL + SX601->X6_VAR ) )
		aAdd( aDiverg, { "01", "SX6", "Parametro não existe na empresa 06: " + AllTrim( SX601->X6_FIL + SX601->X6_VAR ) } )
	Else
		If AllTrim( SX601->X6_TIPO ) <> AllTrim( SX606->X6_TIPO )
			aAdd( aDiverg, { "01", "SX6", "Tipo do parametro diferente na empresa 06: " + AllTrim( SX601->X6_FIL + SX601->X6_VAR ) } )
		ElseIf AllTrim( SX601->X6_CONTEUD ) <> AllTrim( SX606->X6_CONTEUD )
			aAdd( aDiverg, { "01", "SX6", "Conteudo do parametro diferente na empresa 06: " + AllTrim( SX601->X6_FIL + SX601->X6_VAR ) } )
		EndIf
	EndIf

	If !SX609->( dbSeek( SX601->X6_FIL + SX601->X6_VAR ) )
		aAdd( aDiverg, { "01", "SX6", "Parametro não existe na empresa 09: " + AllTrim( SX601->X6_FIL + SX601->X6_VAR ) } )
	Else
		If AllTrim( SX601->X6_TIPO ) <> AllTrim( SX609->X6_TIPO )
			aAdd( aDiverg, { "01", "SX6", "Tipo do parametro diferente na empresa 09: " + AllTrim( SX601->X6_FIL + SX601->X6_VAR ) } )
		ElseIf AllTrim( SX601->X6_CONTEUD ) <> AllTrim( SX609->X6_CONTEUD )
			aAdd( aDiverg, { "01", "SX6", "Conteudo do parametro diferente na empresa 09: " + AllTrim( SX601->X6_FIL + SX601->X6_VAR ) } )
		EndIf
	EndIf

	SX601->( dbSkip() )
EndDo

//Tratar empresa base 03, ou seja, busca diferença de dicionário de dados da 03 para as demais empresas...
dbSelectArea("SX203")
SX203->( dbGoTop() )
Do While !SX203->( Eof() )
	If !( Right( AllTrim( SX203->X2_ARQUIVO ), 3) $ "000|030" )
		aAdd( aDiverg, { "03", "SX2", "Nome do arquivo fora do padrão: " + AllTrim( SX203->X2_ARQUIVO ) } )
	EndIf

	If !SX202->( dbSeek( SX203->X2_CHAVE ) )
		aAdd( aDiverg, { "03", "SX2", "Chave existente na empresa não existe na empresa 02: " + AllTrim( SX203->X2_CHAVE ) } )
	Else
		If AllTrim( SX203->X2_MODO ) <> AllTrim( SX202->X2_MODO )
			aAdd( aDiverg, { "03", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 02: " + AllTrim( SX203->X2_CHAVE ) } )
		ElseIf AllTrim( SX203->X2_UNICO ) <> AllTrim( SX202->X2_UNICO )
			aAdd( aDiverg, { "03", "SX2", "Chave única da tabela diferença na empresa 02: " + AllTrim( SX203->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX208->( dbSeek( SX203->X2_CHAVE ) )
		aAdd( aDiverg, { "03", "SX2", "Chave existente na empresa não existe na empresa 08: " + AllTrim( SX203->X2_CHAVE ) } )
	Else
		If AllTrim( SX203->X2_MODO ) <> AllTrim( SX208->X2_MODO )
			aAdd( aDiverg, { "03", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 08: " + AllTrim( SX203->X2_CHAVE ) } )
		ElseIf AllTrim( SX203->X2_UNICO ) <> AllTrim( SX208->X2_UNICO )
			aAdd( aDiverg, { "03", "SX2", "Chave única da tabela diferença na empresa 08: " + AllTrim( SX203->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX201->( dbSeek( SX203->X2_CHAVE ) )
		aAdd( aDiverg, { "03", "SX2", "Chave existente na empresa não existe na empresa 01: " + AllTrim( SX203->X2_CHAVE ) } )
	Else
		If AllTrim( SX203->X2_MODO ) <> AllTrim( SX201->X2_MODO )
			aAdd( aDiverg, { "03", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 01: " + AllTrim( SX203->X2_CHAVE ) } )
		ElseIf AllTrim( SX203->X2_UNICO ) <> AllTrim( SX201->X2_UNICO )
			aAdd( aDiverg, { "03", "SX2", "Chave única da tabela diferença na empresa 01: " + AllTrim( SX203->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX206->( dbSeek( SX203->X2_CHAVE ) )
		aAdd( aDiverg, { "03", "SX2", "Chave existente na empresa não existe na empresa 06: " + AllTrim( SX203->X2_CHAVE ) } )
	Else
		If AllTrim( SX203->X2_MODO ) <> AllTrim( SX206->X2_MODO )
			aAdd( aDiverg, { "03", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 06: " + AllTrim( SX203->X2_CHAVE ) } )
		ElseIf AllTrim( SX203->X2_UNICO ) <> AllTrim( SX206->X2_UNICO )
			aAdd( aDiverg, { "03", "SX2", "Chave única da tabela diferença na empresa 06: " + AllTrim( SX203->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX209->( dbSeek( SX203->X2_CHAVE ) )
		aAdd( aDiverg, { "03", "SX2", "Chave existente na empresa não existe na empresa 09: " + AllTrim( SX203->X2_CHAVE ) } )
	Else
 		If AllTrim( SX203->X2_MODO ) <> AllTrim( SX209->X2_MODO )
			aAdd( aDiverg, { "03", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 09: " + AllTrim( SX203->X2_CHAVE ) } )
		ElseIf AllTrim( SX203->X2_UNICO ) <> AllTrim( SX209->X2_UNICO )
			aAdd( aDiverg, { "03", "SX2", "Chave única da tabela diferença na empresa 09: " + AllTrim( SX203->X2_CHAVE ) } )
		EndIf
	EndIf

	SX203->( dbSkip() )
EndDo

dbSelectArea("SX303")
SX303->( dbGoTop() )
Do While !SX303->( Eof() )
	If !SX302->( dbSeek( SX303->X3_CAMPO ) )
		aAdd( aDiverg, { "03", "SX3", "Campo não existe na empresa 02: " + AllTrim( SX303->X3_CAMPO ) } )
	Else
		If AllTrim( SX303->X3_TIPO ) <> AllTrim( SX302->X3_TIPO )
			aAdd( aDiverg, { "03", "SX3", "Tipo do Campo diferente na empresa 02: " + AllTrim( SX303->X3_CAMPO ) } )
		ElseIf SX303->X3_TAMANHO <> SX302->X3_TAMANHO
			aAdd( aDiverg, { "03", "SX3", "Tamanho do Campo diferente na empresa 02: " + AllTrim( SX303->X3_CAMPO ) } )
		ElseIf AllTrim( SX303->X3_CONTEXT ) <> AllTrim( SX302->X3_CONTEXT )
			aAdd( aDiverg, { "03", "SX3", "Contexto do Campo diferente na empresa 02: " + AllTrim( SX303->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX308->( dbSeek( SX303->X3_CAMPO ) )
		aAdd( aDiverg, { "03", "SX3", "Campo não existe na empresa 08: " + AllTrim( SX303->X3_CAMPO ) } )
	Else
		If AllTrim( SX303->X3_TIPO ) <> AllTrim( SX308->X3_TIPO )
			aAdd( aDiverg, { "03", "SX3", "Tipo do Campo diferente na empresa 08: " + AllTrim( SX303->X3_CAMPO ) } )
		ElseIf SX303->X3_TAMANHO <> SX308->X3_TAMANHO
			aAdd( aDiverg, { "03", "SX3", "Tamanho do Campo diferente na empresa 08: " + AllTrim( SX303->X3_CAMPO ) } )
		ElseIf AllTrim( SX303->X3_CONTEXT ) <> AllTrim( SX308->X3_CONTEXT )
			aAdd( aDiverg, { "03", "SX3", "Contexto do Campo diferente na empresa 08: " + AllTrim( SX303->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX301->( dbSeek( SX303->X3_CAMPO ) )
		aAdd( aDiverg, { "03", "SX3", "Campo não existe na empresa 01: " + AllTrim( SX303->X3_CAMPO ) } )
	Else
		If AllTrim( SX303->X3_TIPO ) <> AllTrim( SX301->X3_TIPO )
			aAdd( aDiverg, { "03", "SX3", "Tipo do Campo diferente na empresa 01: " + AllTrim( SX303->X3_CAMPO ) } )
		ElseIf SX303->X3_TAMANHO <> SX301->X3_TAMANHO
			aAdd( aDiverg, { "03", "SX3", "Tamanho do Campo diferente na empresa 01: " + AllTrim( SX303->X3_CAMPO ) } )
		ElseIf AllTrim( SX303->X3_CONTEXT ) <> AllTrim( SX301->X3_CONTEXT )
			aAdd( aDiverg, { "03", "SX3", "Contexto do Campo diferente na empresa 01: " + AllTrim( SX303->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX306->( dbSeek( SX303->X3_CAMPO ) )
		aAdd( aDiverg, { "03", "SX3", "Campo não existe na empresa 06: " + AllTrim( SX303->X3_CAMPO ) } )
	Else
		If AllTrim( SX303->X3_TIPO ) <> AllTrim( SX306->X3_TIPO )
			aAdd( aDiverg, { "03", "SX3", "Tipo do Campo diferente na empresa 06: " + AllTrim( SX303->X3_CAMPO ) } )
		ElseIf SX303->X3_TAMANHO <> SX306->X3_TAMANHO
			aAdd( aDiverg, { "03", "SX3", "Tamanho do Campo diferente na empresa 06: " + AllTrim( SX303->X3_CAMPO ) } )
		ElseIf AllTrim( SX303->X3_CONTEXT ) <> AllTrim( SX306->X3_CONTEXT )
			aAdd( aDiverg, { "03", "SX3", "Contexto do Campo diferente na empresa 06: " + AllTrim( SX303->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX309->( dbSeek( SX303->X3_CAMPO ) )
		aAdd( aDiverg, { "03", "SX3", "Campo não existe na empresa 09: " + AllTrim( SX303->X3_CAMPO ) } )
	Else
		If AllTrim( SX303->X3_TIPO ) <> AllTrim( SX309->X3_TIPO )
			aAdd( aDiverg, { "03", "SX3", "Tipo do Campo diferente na empresa 09: " + AllTrim( SX303->X3_CAMPO ) } )
		ElseIf SX303->X3_TAMANHO <> SX309->X3_TAMANHO
			aAdd( aDiverg, { "03", "SX3", "Tamanho do Campo diferente na empresa 09: " + AllTrim( SX303->X3_CAMPO ) } )
		ElseIf AllTrim( SX303->X3_CONTEXT ) <> AllTrim( SX309->X3_CONTEXT )
			aAdd( aDiverg, { "03", "SX3", "Contexto do Campo diferente na empresa 09: " + AllTrim( SX303->X3_CAMPO ) } )
		EndIf
	EndIf

	SX303->( dbSkip() )
EndDo

dbSelectArea("SIX03")
SIX03->( dbGoTop() )
Do While !SIX03->( Eof() )
	If !SIX02->( dbSeek( SIX03->INDICE + SIX03->ORDEM ) )
		aAdd( aDiverg, { "03", "SIX", "Indice não existe na empresa 02: " + AllTrim( SIX03->INDICE + SIX03->ORDEM ) } )
	Else
		If AllTrim( SIX03->CHAVE ) <> AllTrim( SIX02->CHAVE )
			aAdd( aDiverg, { "03", "SIX", "Chave do indice diferente na empresa 02: " + AllTrim( SIX03->INDICE + SIX03->ORDEM ) } )
		EndIf
	EndIf

	If !SIX08->( dbSeek( SIX03->INDICE + SIX03->ORDEM ) )
		aAdd( aDiverg, { "03", "SIX", "Indice não existe na empresa 08: " + AllTrim( SIX03->INDICE + SIX03->ORDEM ) } )
	Else
		If AllTrim( SIX03->CHAVE ) <> AllTrim( SIX08->CHAVE )
			aAdd( aDiverg, { "03", "SIX", "Chave do indice diferente na empresa 08: " + AllTrim( SIX03->INDICE + SIX03->ORDEM ) } )
		EndIf
	EndIf

	If !SIX01->( dbSeek( SIX03->INDICE + SIX03->ORDEM ) )
		aAdd( aDiverg, { "03", "SIX", "Indice não existe na empresa 01: " + AllTrim( SIX03->INDICE + SIX03->ORDEM ) } )
	Else
		If AllTrim( SIX03->CHAVE ) <> AllTrim( SIX01->CHAVE )
			aAdd( aDiverg, { "03", "SIX", "Chave do indice diferente na empresa 01: " + AllTrim( SIX03->INDICE + SIX03->ORDEM ) } )
		EndIf
	EndIf

	If !SIX06->( dbSeek( SIX03->INDICE + SIX03->ORDEM ) )
		aAdd( aDiverg, { "03", "SIX", "Indice não existe na empresa 06: " + AllTrim( SIX03->INDICE + SIX03->ORDEM ) } )
	Else
		If AllTrim( SIX03->CHAVE ) <> AllTrim( SIX06->CHAVE )
			aAdd( aDiverg, { "03", "SIX", "Chave do indice diferente na empresa 06: " + AllTrim( SIX03->INDICE + SIX03->ORDEM ) } )
		EndIf
	EndIf

	If !SIX09->( dbSeek( SIX03->INDICE + SIX03->ORDEM ) )
		aAdd( aDiverg, { "03", "SIX", "Indice não existe na empresa 09: " + AllTrim( SIX03->INDICE + SIX03->ORDEM ) } )
	Else
		If AllTrim( SIX03->CHAVE ) <> AllTrim( SIX09->CHAVE )
			aAdd( aDiverg, { "03", "SIX", "Chave do indice diferente na empresa 09: " + AllTrim( SIX03->INDICE + SIX03->ORDEM ) } )
		EndIf
	EndIf

	SIX03->( dbSkip() )
EndDo

dbSelectArea("SX603")
SX603->( dbGoTop() )
Do While !SX603->( Eof() )
	If !SX602->( dbSeek( SX603->X6_FIL + SX603->X6_VAR ) )
		aAdd( aDiverg, { "03", "SX6", "Parametro não existe na empresa 02: " + AllTrim( SX603->X6_FIL + SX603->X6_VAR ) } )
	Else
		If AllTrim( SX603->X6_TIPO ) <> AllTrim( SX602->X6_TIPO )
			aAdd( aDiverg, { "03", "SX6", "Tipo do parametro diferente na empresa 02: " + AllTrim( SX603->X6_FIL + SX603->X6_VAR ) } )
		ElseIf AllTrim( SX603->X6_CONTEUD ) <> AllTrim( SX602->X6_CONTEUD )
			aAdd( aDiverg, { "03", "SX6", "Conteudo do parametro diferente na empresa 02: " + AllTrim( SX603->X6_FIL + SX603->X6_VAR ) } )
		EndIf
	EndIf

	If !SX608->( dbSeek( SX603->X6_FIL + SX603->X6_VAR ) )
		aAdd( aDiverg, { "03", "SX6", "Parametro não existe na empresa 08: " + AllTrim( SX603->X6_FIL + SX603->X6_VAR ) } )
	Else
		If AllTrim( SX603->X6_TIPO ) <> AllTrim( SX608->X6_TIPO )
			aAdd( aDiverg, { "03", "SX6", "Tipo do parametro diferente na empresa 08: " + AllTrim( SX603->X6_FIL + SX603->X6_VAR ) } )
		ElseIf AllTrim( SX603->X6_CONTEUD ) <> AllTrim( SX608->X6_CONTEUD )
			aAdd( aDiverg, { "03", "SX6", "Conteudo do parametro diferente na empresa 08: " + AllTrim( SX603->X6_FIL + SX603->X6_VAR ) } )
		EndIf
	EndIf

	If !SX601->( dbSeek( SX603->X6_FIL + SX603->X6_VAR ) )
		aAdd( aDiverg, { "03", "SX6", "Parametro não existe na empresa 01: " + AllTrim( SX603->X6_FIL + SX603->X6_VAR ) } )
	Else
		If AllTrim( SX603->X6_TIPO ) <> AllTrim( SX603->X6_TIPO )
			aAdd( aDiverg, { "03", "SX6", "Tipo do parametro diferente na empresa 01: " + AllTrim( SX603->X6_FIL + SX603->X6_VAR ) } )
		ElseIf AllTrim( SX603->X6_CONTEUD ) <> AllTrim( SX603->X6_CONTEUD )
			aAdd( aDiverg, { "03", "SX6", "Conteudo do parametro diferente na empresa 01: " + AllTrim( SX603->X6_FIL + SX603->X6_VAR ) } )
		EndIf
	EndIf

	If !SX606->( dbSeek( SX603->X6_FIL + SX603->X6_VAR ) )
		aAdd( aDiverg, { "03", "SX6", "Parametro não existe na empresa 06: " + AllTrim( SX603->X6_FIL + SX603->X6_VAR ) } )
	Else
		If AllTrim( SX603->X6_TIPO ) <> AllTrim( SX606->X6_TIPO )
			aAdd( aDiverg, { "03", "SX6", "Tipo do parametro diferente na empresa 06: " + AllTrim( SX603->X6_FIL + SX603->X6_VAR ) } )
		ElseIf AllTrim( SX603->X6_CONTEUD ) <> AllTrim( SX606->X6_CONTEUD )
			aAdd( aDiverg, { "03", "SX6", "Conteudo do parametro diferente na empresa 06: " + AllTrim( SX603->X6_FIL + SX603->X6_VAR ) } )
		EndIf
	EndIf

	If !SX609->( dbSeek( SX603->X6_FIL + SX603->X6_VAR ) )
		aAdd( aDiverg, { "03", "SX6", "Parametro não existe na empresa 09: " + AllTrim( SX603->X6_FIL + SX603->X6_VAR ) } )
	Else
		If AllTrim( SX603->X6_TIPO ) <> AllTrim( SX609->X6_TIPO )
			aAdd( aDiverg, { "03", "SX6", "Tipo do parametro diferente na empresa 09: " + AllTrim( SX603->X6_FIL + SX603->X6_VAR ) } )
		ElseIf AllTrim( SX603->X6_CONTEUD ) <> AllTrim( SX609->X6_CONTEUD )
			aAdd( aDiverg, { "03", "SX6", "Conteudo do parametro diferente na empresa 09: " + AllTrim( SX603->X6_FIL + SX603->X6_VAR ) } )
		EndIf
	EndIf

	SX603->( dbSkip() )
EndDo

//Tratar empresa base 06, ou seja, busca diferença de dicionário de dados da 06 para as demais empresas...
dbSelectArea("SX206")
SX206->( dbGoTop() )
Do While !SX206->( Eof() )
	If !( Right( AllTrim( SX206->X2_ARQUIVO ), 3) $ "000|060" )
		aAdd( aDiverg, { "06", "SX2", "Nome do arquivo fora do padrão: " + AllTrim( SX206->X2_ARQUIVO ) } )
	EndIf

	If !SX202->( dbSeek( SX206->X2_CHAVE ) )
		aAdd( aDiverg, { "06", "SX2", "Chave existente na empresa não existe na empresa 02: " + AllTrim( SX206->X2_CHAVE ) } )
	Else
		If AllTrim( SX206->X2_MODO ) <> AllTrim( SX202->X2_MODO )
			aAdd( aDiverg, { "06", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 02: " + AllTrim( SX206->X2_CHAVE ) } )
		ElseIf AllTrim( SX206->X2_UNICO ) <> AllTrim( SX202->X2_UNICO )
			aAdd( aDiverg, { "06", "SX2", "Chave única da tabela diferença na empresa 02: " + AllTrim( SX206->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX208->( dbSeek( SX206->X2_CHAVE ) )
		aAdd( aDiverg, { "06", "SX2", "Chave existente na empresa não existe na empresa 08: " + AllTrim( SX206->X2_CHAVE ) } )
	Else
		If AllTrim( SX206->X2_MODO ) <> AllTrim( SX208->X2_MODO )
			aAdd( aDiverg, { "06", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 08: " + AllTrim( SX206->X2_CHAVE ) } )
		ElseIf AllTrim( SX206->X2_UNICO ) <> AllTrim( SX208->X2_UNICO )
			aAdd( aDiverg, { "06", "SX2", "Chave única da tabela diferença na empresa 08: " + AllTrim( SX206->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX201->( dbSeek( SX206->X2_CHAVE ) )
		aAdd( aDiverg, { "06", "SX2", "Chave existente na empresa não existe na empresa 01: " + AllTrim( SX206->X2_CHAVE ) } )
	Else
		If AllTrim( SX206->X2_MODO ) <> AllTrim( SX201->X2_MODO )
			aAdd( aDiverg, { "06", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 01: " + AllTrim( SX206->X2_CHAVE ) } )
		ElseIf AllTrim( SX206->X2_UNICO ) <> AllTrim( SX201->X2_UNICO )
			aAdd( aDiverg, { "06", "SX2", "Chave única da tabela diferença na empresa 01: " + AllTrim( SX206->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX203->( dbSeek( SX206->X2_CHAVE ) )
		aAdd( aDiverg, { "06", "SX2", "Chave existente na empresa não existe na empresa 03: " + AllTrim( SX206->X2_CHAVE ) } )
	Else
		If AllTrim( SX206->X2_MODO ) <> AllTrim( SX203->X2_MODO )
			aAdd( aDiverg, { "06", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 03: " + AllTrim( SX206->X2_CHAVE ) } )
		ElseIf AllTrim( SX206->X2_UNICO ) <> AllTrim( SX203->X2_UNICO )
			aAdd( aDiverg, { "06", "SX2", "Chave única da tabela diferença na empresa 03: " + AllTrim( SX206->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX209->( dbSeek( SX206->X2_CHAVE ) )
		aAdd( aDiverg, { "06", "SX2", "Chave existente na empresa não existe na empresa 09: " + AllTrim( SX206->X2_CHAVE ) } )
	Else
 		If AllTrim( SX206->X2_MODO ) <> AllTrim( SX209->X2_MODO )
			aAdd( aDiverg, { "06", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 09: " + AllTrim( SX206->X2_CHAVE ) } )
		ElseIf AllTrim( SX206->X2_UNICO ) <> AllTrim( SX209->X2_UNICO )
			aAdd( aDiverg, { "06", "SX2", "Chave única da tabela diferença na empresa 09: " + AllTrim( SX206->X2_CHAVE ) } )
		EndIf
	EndIf

	SX206->( dbSkip() )
EndDo

dbSelectArea("SX306")
SX306->( dbGoTop() )
Do While !SX306->( Eof() )
	If !SX302->( dbSeek( SX306->X3_CAMPO ) )
		aAdd( aDiverg, { "06", "SX3", "Campo não existe na empresa 02: " + AllTrim( SX306->X3_CAMPO ) } )
	Else
		If AllTrim( SX306->X3_TIPO ) <> AllTrim( SX302->X3_TIPO )
			aAdd( aDiverg, { "06", "SX3", "Tipo do Campo diferente na empresa 02: " + AllTrim( SX306->X3_CAMPO ) } )
		ElseIf SX306->X3_TAMANHO <> SX302->X3_TAMANHO
			aAdd( aDiverg, { "06", "SX3", "Tamanho do Campo diferente na empresa 02: " + AllTrim( SX306->X3_CAMPO ) } )
		ElseIf AllTrim( SX306->X3_CONTEXT ) <> AllTrim( SX302->X3_CONTEXT )
			aAdd( aDiverg, { "06", "SX3", "Contexto do Campo diferente na empresa 02: " + AllTrim( SX306->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX308->( dbSeek( SX306->X3_CAMPO ) )
		aAdd( aDiverg, { "06", "SX3", "Campo não existe na empresa 08: " + AllTrim( SX306->X3_CAMPO ) } )
	Else
		If AllTrim( SX306->X3_TIPO ) <> AllTrim( SX308->X3_TIPO )
			aAdd( aDiverg, { "06", "SX3", "Tipo do Campo diferente na empresa 08: " + AllTrim( SX306->X3_CAMPO ) } )
		ElseIf SX306->X3_TAMANHO <> SX308->X3_TAMANHO
			aAdd( aDiverg, { "06", "SX3", "Tamanho do Campo diferente na empresa 08: " + AllTrim( SX306->X3_CAMPO ) } )
		ElseIf AllTrim( SX306->X3_CONTEXT ) <> AllTrim( SX308->X3_CONTEXT )
			aAdd( aDiverg, { "06", "SX3", "Contexto do Campo diferente na empresa 08: " + AllTrim( SX306->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX301->( dbSeek( SX306->X3_CAMPO ) )
		aAdd( aDiverg, { "06", "SX3", "Campo não existe na empresa 01: " + AllTrim( SX306->X3_CAMPO ) } )
	Else
		If AllTrim( SX306->X3_TIPO ) <> AllTrim( SX301->X3_TIPO )
			aAdd( aDiverg, { "06", "SX3", "Tipo do Campo diferente na empresa 01: " + AllTrim( SX306->X3_CAMPO ) } )
		ElseIf SX306->X3_TAMANHO <> SX301->X3_TAMANHO
			aAdd( aDiverg, { "06", "SX3", "Tamanho do Campo diferente na empresa 01: " + AllTrim( SX306->X3_CAMPO ) } )
		ElseIf AllTrim( SX306->X3_CONTEXT ) <> AllTrim( SX301->X3_CONTEXT )
			aAdd( aDiverg, { "06", "SX3", "Contexto do Campo diferente na empresa 01: " + AllTrim( SX306->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX303->( dbSeek( SX306->X3_CAMPO ) )
		aAdd( aDiverg, { "06", "SX3", "Campo não existe na empresa 03: " + AllTrim( SX306->X3_CAMPO ) } )
	Else
		If AllTrim( SX306->X3_TIPO ) <> AllTrim( SX303->X3_TIPO )
			aAdd( aDiverg, { "06", "SX3", "Tipo do Campo diferente na empresa 03: " + AllTrim( SX306->X3_CAMPO ) } )
		ElseIf SX306->X3_TAMANHO <> SX303->X3_TAMANHO
			aAdd( aDiverg, { "06", "SX3", "Tamanho do Campo diferente na empresa 03: " + AllTrim( SX306->X3_CAMPO ) } )
		ElseIf AllTrim( SX306->X3_CONTEXT ) <> AllTrim( SX303->X3_CONTEXT )
			aAdd( aDiverg, { "06", "SX3", "Contexto do Campo diferente na empresa 03: " + AllTrim( SX306->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX309->( dbSeek( SX306->X3_CAMPO ) )
		aAdd( aDiverg, { "06", "SX3", "Campo não existe na empresa 09: " + AllTrim( SX306->X3_CAMPO ) } )
	Else
		If AllTrim( SX306->X3_TIPO ) <> AllTrim( SX309->X3_TIPO )
			aAdd( aDiverg, { "06", "SX3", "Tipo do Campo diferente na empresa 09: " + AllTrim( SX306->X3_CAMPO ) } )
		ElseIf SX306->X3_TAMANHO <> SX309->X3_TAMANHO
			aAdd( aDiverg, { "06", "SX3", "Tamanho do Campo diferente na empresa 09: " + AllTrim( SX306->X3_CAMPO ) } )
		ElseIf AllTrim( SX306->X3_CONTEXT ) <> AllTrim( SX309->X3_CONTEXT )
			aAdd( aDiverg, { "06", "SX3", "Contexto do Campo diferente na empresa 09: " + AllTrim( SX306->X3_CAMPO ) } )
		EndIf
	EndIf

	SX306->( dbSkip() )
EndDo

dbSelectArea("SIX06")
SIX06->( dbGoTop() )
Do While !SIX06->( Eof() )
	If !SIX02->( dbSeek( SIX06->INDICE + SIX06->ORDEM ) )
		aAdd( aDiverg, { "06", "SIX", "Indice não existe na empresa 02: " + AllTrim( SIX06->INDICE + SIX06->ORDEM ) } )
	Else
		If AllTrim( SIX06->CHAVE ) <> AllTrim( SIX02->CHAVE )
			aAdd( aDiverg, { "06", "SIX", "Chave do indice diferente na empresa 02: " + AllTrim( SIX06->INDICE + SIX06->ORDEM ) } )
		EndIf
	EndIf

	If !SIX08->( dbSeek( SIX06->INDICE + SIX06->ORDEM ) )
		aAdd( aDiverg, { "06", "SIX", "Indice não existe na empresa 08: " + AllTrim( SIX06->INDICE + SIX06->ORDEM ) } )
	Else
		If AllTrim( SIX06->CHAVE ) <> AllTrim( SIX08->CHAVE )
			aAdd( aDiverg, { "06", "SIX", "Chave do indice diferente na empresa 08: " + AllTrim( SIX06->INDICE + SIX06->ORDEM ) } )
		EndIf
	EndIf

	If !SIX01->( dbSeek( SIX06->INDICE + SIX06->ORDEM ) )
		aAdd( aDiverg, { "06", "SIX", "Indice não existe na empresa 01: " + AllTrim( SIX06->INDICE + SIX06->ORDEM ) } )
	Else
		If AllTrim( SIX06->CHAVE ) <> AllTrim( SIX01->CHAVE )
			aAdd( aDiverg, { "06", "SIX", "Chave do indice diferente na empresa 01: " + AllTrim( SIX06->INDICE + SIX06->ORDEM ) } )
		EndIf
	EndIf

	If !SIX03->( dbSeek( SIX06->INDICE + SIX06->ORDEM ) )
		aAdd( aDiverg, { "06", "SIX", "Indice não existe na empresa 03: " + AllTrim( SIX06->INDICE + SIX06->ORDEM ) } )
	Else
		If AllTrim( SIX06->CHAVE ) <> AllTrim( SIX03->CHAVE )
			aAdd( aDiverg, { "06", "SIX", "Chave do indice diferente na empresa 03: " + AllTrim( SIX06->INDICE + SIX06->ORDEM ) } )
		EndIf
	EndIf

	If !SIX09->( dbSeek( SIX06->INDICE + SIX06->ORDEM ) )
		aAdd( aDiverg, { "06", "SIX", "Indice não existe na empresa 09: " + AllTrim( SIX06->INDICE + SIX06->ORDEM ) } )
	Else
		If AllTrim( SIX06->CHAVE ) <> AllTrim( SIX09->CHAVE )
			aAdd( aDiverg, { "06", "SIX", "Chave do indice diferente na empresa 09: " + AllTrim( SIX06->INDICE + SIX06->ORDEM ) } )
		EndIf
	EndIf

	SIX06->( dbSkip() )
EndDo

dbSelectArea("SX606")
SX606->( dbGoTop() )
Do While !SX606->( Eof() )
	If !SX602->( dbSeek( SX606->X6_FIL + SX606->X6_VAR ) )
		aAdd( aDiverg, { "06", "SX6", "Parametro não existe na empresa 02: " + AllTrim( SX606->X6_FIL + SX606->X6_VAR ) } )
	Else
		If AllTrim( SX606->X6_TIPO ) <> AllTrim( SX602->X6_TIPO )
			aAdd( aDiverg, { "06", "SX6", "Tipo do parametro diferente na empresa 02: " + AllTrim( SX606->X6_FIL + SX606->X6_VAR ) } )
		ElseIf AllTrim( SX606->X6_CONTEUD ) <> AllTrim( SX602->X6_CONTEUD )
			aAdd( aDiverg, { "06", "SX6", "Conteudo do parametro diferente na empresa 02: " + AllTrim( SX606->X6_FIL + SX606->X6_VAR ) } )
		EndIf
	EndIf

	If !SX608->( dbSeek( SX606->X6_FIL + SX606->X6_VAR ) )
		aAdd( aDiverg, { "06", "SX6", "Parametro não existe na empresa 08: " + AllTrim( SX606->X6_FIL + SX606->X6_VAR ) } )
	Else
		If AllTrim( SX606->X6_TIPO ) <> AllTrim( SX608->X6_TIPO )
			aAdd( aDiverg, { "06", "SX6", "Tipo do parametro diferente na empresa 08: " + AllTrim( SX606->X6_FIL + SX606->X6_VAR ) } )
		ElseIf AllTrim( SX606->X6_CONTEUD ) <> AllTrim( SX608->X6_CONTEUD )
			aAdd( aDiverg, { "06", "SX6", "Conteudo do parametro diferente na empresa 08: " + AllTrim( SX606->X6_FIL + SX606->X6_VAR ) } )
		EndIf
	EndIf

	If !SX601->( dbSeek( SX606->X6_FIL + SX606->X6_VAR ) )
		aAdd( aDiverg, { "06", "SX6", "Parametro não existe na empresa 01: " + AllTrim( SX606->X6_FIL + SX606->X6_VAR ) } )
	Else
		If AllTrim( SX606->X6_TIPO ) <> AllTrim( SX606->X6_TIPO )
			aAdd( aDiverg, { "06", "SX6", "Tipo do parametro diferente na empresa 01: " + AllTrim( SX606->X6_FIL + SX606->X6_VAR ) } )
		ElseIf AllTrim( SX606->X6_CONTEUD ) <> AllTrim( SX606->X6_CONTEUD )
			aAdd( aDiverg, { "06", "SX6", "Conteudo do parametro diferente na empresa 01: " + AllTrim( SX606->X6_FIL + SX606->X6_VAR ) } )
		EndIf
	EndIf

	If !SX603->( dbSeek( SX606->X6_FIL + SX606->X6_VAR ) )
		aAdd( aDiverg, { "06", "SX6", "Parametro não existe na empresa 03: " + AllTrim( SX606->X6_FIL + SX606->X6_VAR ) } )
	Else
		If AllTrim( SX606->X6_TIPO ) <> AllTrim( SX603->X6_TIPO )
			aAdd( aDiverg, { "06", "SX6", "Tipo do parametro diferente na empresa 03: " + AllTrim( SX606->X6_FIL + SX606->X6_VAR ) } )
		ElseIf AllTrim( SX606->X6_CONTEUD ) <> AllTrim( SX603->X6_CONTEUD )
			aAdd( aDiverg, { "06", "SX6", "Conteudo do parametro diferente na empresa 03: " + AllTrim( SX606->X6_FIL + SX606->X6_VAR ) } )
		EndIf
	EndIf

	If !SX609->( dbSeek( SX606->X6_FIL + SX606->X6_VAR ) )
		aAdd( aDiverg, { "06", "SX6", "Parametro não existe na empresa 09: " + AllTrim( SX606->X6_FIL + SX606->X6_VAR ) } )
	Else
		If AllTrim( SX606->X6_TIPO ) <> AllTrim( SX609->X6_TIPO )
			aAdd( aDiverg, { "06", "SX6", "Tipo do parametro diferente na empresa 09: " + AllTrim( SX606->X6_FIL + SX606->X6_VAR ) } )
		ElseIf AllTrim( SX606->X6_CONTEUD ) <> AllTrim( SX609->X6_CONTEUD )
			aAdd( aDiverg, { "06", "SX6", "Conteudo do parametro diferente na empresa 09: " + AllTrim( SX606->X6_FIL + SX606->X6_VAR ) } )
		EndIf
	EndIf

	SX606->( dbSkip() )
EndDo

//Tratar empresa base 09, ou seja, busca diferença de dicionário de dados da 09 para as demais empresas...
dbSelectArea("SX209")
SX209->( dbGoTop() )
Do While !SX209->( Eof() )
	If !( Right( AllTrim( SX209->X2_ARQUIVO ), 3) $ "000|090" )
		aAdd( aDiverg, { "09", "SX2", "Nome do arquivo fora do padrão: " + AllTrim( SX209->X2_ARQUIVO ) } )
	EndIf

	If !SX202->( dbSeek( SX209->X2_CHAVE ) )
		aAdd( aDiverg, { "09", "SX2", "Chave existente na empresa não existe na empresa 02: " + AllTrim( SX209->X2_CHAVE ) } )
	Else
		If AllTrim( SX209->X2_MODO ) <> AllTrim( SX202->X2_MODO )
			aAdd( aDiverg, { "09", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 02: " + AllTrim( SX209->X2_CHAVE ) } )
		ElseIf AllTrim( SX209->X2_UNICO ) <> AllTrim( SX202->X2_UNICO )
			aAdd( aDiverg, { "09", "SX2", "Chave única da tabela diferença na empresa 02: " + AllTrim( SX209->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX208->( dbSeek( SX209->X2_CHAVE ) )
		aAdd( aDiverg, { "09", "SX2", "Chave existente na empresa não existe na empresa 08: " + AllTrim( SX209->X2_CHAVE ) } )
	Else
		If AllTrim( SX209->X2_MODO ) <> AllTrim( SX208->X2_MODO )
			aAdd( aDiverg, { "09", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 08: " + AllTrim( SX209->X2_CHAVE ) } )
		ElseIf AllTrim( SX209->X2_UNICO ) <> AllTrim( SX208->X2_UNICO )
			aAdd( aDiverg, { "09", "SX2", "Chave única da tabela diferença na empresa 08: " + AllTrim( SX209->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX201->( dbSeek( SX209->X2_CHAVE ) )
		aAdd( aDiverg, { "09", "SX2", "Chave existente na empresa não existe na empresa 01: " + AllTrim( SX209->X2_CHAVE ) } )
	Else
		If AllTrim( SX209->X2_MODO ) <> AllTrim( SX201->X2_MODO )
			aAdd( aDiverg, { "09", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 01: " + AllTrim( SX209->X2_CHAVE ) } )
		ElseIf AllTrim( SX209->X2_UNICO ) <> AllTrim( SX201->X2_UNICO )
			aAdd( aDiverg, { "09", "SX2", "Chave única da tabela diferença na empresa 01: " + AllTrim( SX209->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX203->( dbSeek( SX209->X2_CHAVE ) )
		aAdd( aDiverg, { "09", "SX2", "Chave existente na empresa não existe na empresa 03: " + AllTrim( SX209->X2_CHAVE ) } )
	Else
		If AllTrim( SX209->X2_MODO ) <> AllTrim( SX203->X2_MODO )
			aAdd( aDiverg, { "09", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 03: " + AllTrim( SX209->X2_CHAVE ) } )
		ElseIf AllTrim( SX209->X2_UNICO ) <> AllTrim( SX203->X2_UNICO )
			aAdd( aDiverg, { "09", "SX2", "Chave única da tabela diferença na empresa 03: " + AllTrim( SX209->X2_CHAVE ) } )
		EndIf
	EndIf

	If !SX206->( dbSeek( SX209->X2_CHAVE ) )
		aAdd( aDiverg, { "09", "SX2", "Chave existente na empresa não existe na empresa 06: " + AllTrim( SX209->X2_CHAVE ) } )
	Else
 		If AllTrim( SX209->X2_MODO ) <> AllTrim( SX206->X2_MODO )
			aAdd( aDiverg, { "09", "SX2", "Modo de Compartilhamento da tabela diferença na empresa 06: " + AllTrim( SX209->X2_CHAVE ) } )
		ElseIf AllTrim( SX209->X2_UNICO ) <> AllTrim( SX206->X2_UNICO )
			aAdd( aDiverg, { "09", "SX2", "Chave única da tabela diferença na empresa 06: " + AllTrim( SX209->X2_CHAVE ) } )
		EndIf
	EndIf

	SX209->( dbSkip() )
EndDo

dbSelectArea("SX309")
SX309->( dbGoTop() )
Do While !SX309->( Eof() )
	If !SX302->( dbSeek( SX309->X3_CAMPO ) )
		aAdd( aDiverg, { "09", "SX3", "Campo não existe na empresa 02: " + AllTrim( SX309->X3_CAMPO ) } )
	Else
		If AllTrim( SX309->X3_TIPO ) <> AllTrim( SX302->X3_TIPO )
			aAdd( aDiverg, { "09", "SX3", "Tipo do Campo diferente na empresa 02: " + AllTrim( SX309->X3_CAMPO ) } )
		ElseIf SX309->X3_TAMANHO <> SX302->X3_TAMANHO
			aAdd( aDiverg, { "09", "SX3", "Tamanho do Campo diferente na empresa 02: " + AllTrim( SX309->X3_CAMPO ) } )
		ElseIf AllTrim( SX309->X3_CONTEXT ) <> AllTrim( SX302->X3_CONTEXT )
			aAdd( aDiverg, { "09", "SX3", "Contexto do Campo diferente na empresa 02: " + AllTrim( SX309->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX308->( dbSeek( SX309->X3_CAMPO ) )
		aAdd( aDiverg, { "09", "SX3", "Campo não existe na empresa 08: " + AllTrim( SX309->X3_CAMPO ) } )
	Else
		If AllTrim( SX309->X3_TIPO ) <> AllTrim( SX308->X3_TIPO )
			aAdd( aDiverg, { "09", "SX3", "Tipo do Campo diferente na empresa 08: " + AllTrim( SX309->X3_CAMPO ) } )
		ElseIf SX309->X3_TAMANHO <> SX308->X3_TAMANHO
			aAdd( aDiverg, { "09", "SX3", "Tamanho do Campo diferente na empresa 08: " + AllTrim( SX309->X3_CAMPO ) } )
		ElseIf AllTrim( SX309->X3_CONTEXT ) <> AllTrim( SX308->X3_CONTEXT )
			aAdd( aDiverg, { "09", "SX3", "Contexto do Campo diferente na empresa 08: " + AllTrim( SX309->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX301->( dbSeek( SX309->X3_CAMPO ) )
		aAdd( aDiverg, { "09", "SX3", "Campo não existe na empresa 01: " + AllTrim( SX309->X3_CAMPO ) } )
	Else
		If AllTrim( SX309->X3_TIPO ) <> AllTrim( SX301->X3_TIPO )
			aAdd( aDiverg, { "09", "SX3", "Tipo do Campo diferente na empresa 01: " + AllTrim( SX309->X3_CAMPO ) } )
		ElseIf SX309->X3_TAMANHO <> SX301->X3_TAMANHO
			aAdd( aDiverg, { "09", "SX3", "Tamanho do Campo diferente na empresa 01: " + AllTrim( SX309->X3_CAMPO ) } )
		ElseIf AllTrim( SX309->X3_CONTEXT ) <> AllTrim( SX301->X3_CONTEXT )
			aAdd( aDiverg, { "09", "SX3", "Contexto do Campo diferente na empresa 01: " + AllTrim( SX309->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX303->( dbSeek( SX309->X3_CAMPO ) )
		aAdd( aDiverg, { "09", "SX3", "Campo não existe na empresa 03: " + AllTrim( SX309->X3_CAMPO ) } )
	Else
		If AllTrim( SX309->X3_TIPO ) <> AllTrim( SX303->X3_TIPO )
			aAdd( aDiverg, { "09", "SX3", "Tipo do Campo diferente na empresa 03: " + AllTrim( SX309->X3_CAMPO ) } )
		ElseIf SX309->X3_TAMANHO <> SX303->X3_TAMANHO
			aAdd( aDiverg, { "09", "SX3", "Tamanho do Campo diferente na empresa 03: " + AllTrim( SX309->X3_CAMPO ) } )
		ElseIf AllTrim( SX309->X3_CONTEXT ) <> AllTrim( SX303->X3_CONTEXT )
			aAdd( aDiverg, { "09", "SX3", "Contexto do Campo diferente na empresa 03: " + AllTrim( SX309->X3_CAMPO ) } )
		EndIf
	EndIf

	If !SX306->( dbSeek( SX309->X3_CAMPO ) )
		aAdd( aDiverg, { "09", "SX3", "Campo não existe na empresa 06: " + AllTrim( SX309->X3_CAMPO ) } )
	Else
		If AllTrim( SX309->X3_TIPO ) <> AllTrim( SX306->X3_TIPO )
			aAdd( aDiverg, { "09", "SX3", "Tipo do Campo diferente na empresa 06: " + AllTrim( SX309->X3_CAMPO ) } )
		ElseIf SX309->X3_TAMANHO <> SX306->X3_TAMANHO
			aAdd( aDiverg, { "09", "SX3", "Tamanho do Campo diferente na empresa 06: " + AllTrim( SX309->X3_CAMPO ) } )
		ElseIf AllTrim( SX309->X3_CONTEXT ) <> AllTrim( SX306->X3_CONTEXT )
			aAdd( aDiverg, { "09", "SX3", "Contexto do Campo diferente na empresa 06: " + AllTrim( SX309->X3_CAMPO ) } )
		EndIf
	EndIf

	SX309->( dbSkip() )
EndDo

dbSelectArea("SIX09")
SIX09->( dbGoTop() )
Do While !SIX09->( Eof() )
	If !SIX02->( dbSeek( SIX09->INDICE + SIX09->ORDEM ) )
		aAdd( aDiverg, { "09", "SIX", "Indice não existe na empresa 02: " + AllTrim( SIX09->INDICE + SIX09->ORDEM ) } )
	Else
		If AllTrim( SIX09->CHAVE ) <> AllTrim( SIX02->CHAVE )
			aAdd( aDiverg, { "09", "SIX", "Chave do indice diferente na empresa 02: " + AllTrim( SIX09->INDICE + SIX09->ORDEM ) } )
		EndIf
	EndIf

	If !SIX08->( dbSeek( SIX09->INDICE + SIX09->ORDEM ) )
		aAdd( aDiverg, { "09", "SIX", "Indice não existe na empresa 08: " + AllTrim( SIX09->INDICE + SIX09->ORDEM ) } )
	Else
		If AllTrim( SIX09->CHAVE ) <> AllTrim( SIX08->CHAVE )
			aAdd( aDiverg, { "09", "SIX", "Chave do indice diferente na empresa 08: " + AllTrim( SIX09->INDICE + SIX09->ORDEM ) } )
		EndIf
	EndIf

	If !SIX01->( dbSeek( SIX09->INDICE + SIX09->ORDEM ) )
		aAdd( aDiverg, { "09", "SIX", "Indice não existe na empresa 01: " + AllTrim( SIX09->INDICE + SIX09->ORDEM ) } )
	Else
		If AllTrim( SIX09->CHAVE ) <> AllTrim( SIX01->CHAVE )
			aAdd( aDiverg, { "09", "SIX", "Chave do indice diferente na empresa 01: " + AllTrim( SIX09->INDICE + SIX09->ORDEM ) } )
		EndIf
	EndIf

	If !SIX03->( dbSeek( SIX09->INDICE + SIX09->ORDEM ) )
		aAdd( aDiverg, { "09", "SIX", "Indice não existe na empresa 03: " + AllTrim( SIX09->INDICE + SIX09->ORDEM ) } )
	Else
		If AllTrim( SIX09->CHAVE ) <> AllTrim( SIX03->CHAVE )
			aAdd( aDiverg, { "09", "SIX", "Chave do indice diferente na empresa 03: " + AllTrim( SIX09->INDICE + SIX09->ORDEM ) } )
		EndIf
	EndIf

	If !SIX06->( dbSeek( SIX09->INDICE + SIX09->ORDEM ) )
		aAdd( aDiverg, { "09", "SIX", "Indice não existe na empresa 06: " + AllTrim( SIX09->INDICE + SIX09->ORDEM ) } )
	Else
		If AllTrim( SIX09->CHAVE ) <> AllTrim( SIX06->CHAVE )
			aAdd( aDiverg, { "09", "SIX", "Chave do indice diferente na empresa 06: " + AllTrim( SIX09->INDICE + SIX09->ORDEM ) } )
		EndIf
	EndIf

	SIX09->( dbSkip() )
EndDo

dbSelectArea("SX609")
SX609->( dbGoTop() )
Do While !SX609->( Eof() )
	If !SX602->( dbSeek( SX609->X6_FIL + SX609->X6_VAR ) )
		aAdd( aDiverg, { "09", "SX6", "Parametro não existe na empresa 02: " + AllTrim( SX609->X6_FIL + SX609->X6_VAR ) } )
	Else
		If AllTrim( SX609->X6_TIPO ) <> AllTrim( SX602->X6_TIPO )
			aAdd( aDiverg, { "09", "SX6", "Tipo do parametro diferente na empresa 02: " + AllTrim( SX609->X6_FIL + SX609->X6_VAR ) } )
		ElseIf AllTrim( SX609->X6_CONTEUD ) <> AllTrim( SX602->X6_CONTEUD )
			aAdd( aDiverg, { "09", "SX6", "Conteudo do parametro diferente na empresa 02: " + AllTrim( SX609->X6_FIL + SX609->X6_VAR ) } )
		EndIf
	EndIf

	If !SX608->( dbSeek( SX609->X6_FIL + SX609->X6_VAR ) )
		aAdd( aDiverg, { "09", "SX6", "Parametro não existe na empresa 08: " + AllTrim( SX609->X6_FIL + SX609->X6_VAR ) } )
	Else
		If AllTrim( SX609->X6_TIPO ) <> AllTrim( SX608->X6_TIPO )
			aAdd( aDiverg, { "09", "SX6", "Tipo do parametro diferente na empresa 08: " + AllTrim( SX609->X6_FIL + SX609->X6_VAR ) } )
		ElseIf AllTrim( SX609->X6_CONTEUD ) <> AllTrim( SX608->X6_CONTEUD )
			aAdd( aDiverg, { "09", "SX6", "Conteudo do parametro diferente na empresa 08: " + AllTrim( SX609->X6_FIL + SX609->X6_VAR ) } )
		EndIf
	EndIf

	If !SX601->( dbSeek( SX609->X6_FIL + SX609->X6_VAR ) )
		aAdd( aDiverg, { "09", "SX6", "Parametro não existe na empresa 01: " + AllTrim( SX609->X6_FIL + SX609->X6_VAR ) } )
	Else
		If AllTrim( SX609->X6_TIPO ) <> AllTrim( SX609->X6_TIPO )
			aAdd( aDiverg, { "09", "SX6", "Tipo do parametro diferente na empresa 01: " + AllTrim( SX609->X6_FIL + SX609->X6_VAR ) } )
		ElseIf AllTrim( SX609->X6_CONTEUD ) <> AllTrim( SX609->X6_CONTEUD )
			aAdd( aDiverg, { "09", "SX6", "Conteudo do parametro diferente na empresa 01: " + AllTrim( SX609->X6_FIL + SX609->X6_VAR ) } )
		EndIf
	EndIf

	If !SX603->( dbSeek( SX609->X6_FIL + SX609->X6_VAR ) )
		aAdd( aDiverg, { "09", "SX6", "Parametro não existe na empresa 03: " + AllTrim( SX609->X6_FIL + SX609->X6_VAR ) } )
	Else
		If AllTrim( SX609->X6_TIPO ) <> AllTrim( SX603->X6_TIPO )
			aAdd( aDiverg, { "09", "SX6", "Tipo do parametro diferente na empresa 03: " + AllTrim( SX609->X6_FIL + SX609->X6_VAR ) } )
		ElseIf AllTrim( SX609->X6_CONTEUD ) <> AllTrim( SX603->X6_CONTEUD )
			aAdd( aDiverg, { "09", "SX6", "Conteudo do parametro diferente na empresa 03: " + AllTrim( SX609->X6_FIL + SX609->X6_VAR ) } )
		EndIf
	EndIf

	If !SX606->( dbSeek( SX609->X6_FIL + SX609->X6_VAR ) )
		aAdd( aDiverg, { "09", "SX6", "Parametro não existe na empresa 06: " + AllTrim( SX609->X6_FIL + SX609->X6_VAR ) } )
	Else
		If AllTrim( SX609->X6_TIPO ) <> AllTrim( SX606->X6_TIPO )
			aAdd( aDiverg, { "09", "SX6", "Tipo do parametro diferente na empresa 06: " + AllTrim( SX609->X6_FIL + SX609->X6_VAR ) } )
		ElseIf AllTrim( SX609->X6_CONTEUD ) <> AllTrim( SX606->X6_CONTEUD )
			aAdd( aDiverg, { "09", "SX6", "Conteudo do parametro diferente na empresa 06: " + AllTrim( SX609->X6_FIL + SX609->X6_VAR ) } )
		EndIf
	EndIf

	SX609->( dbSkip() )
EndDo

aEval( aDiverg, { |x| ConOut("[TUDO];" + x[1] + ";" + x[2] + ";" + AllTrim( x[3] )) } )

Return