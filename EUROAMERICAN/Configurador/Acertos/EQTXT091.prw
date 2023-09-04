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

aAdd( aAlias, {'AIC'})
aAdd( aAlias, {'CC2'})
aAdd( aAlias, {'CT1'})
aAdd( aAlias, {'CT5'})
aAdd( aAlias, {'CTH'})
aAdd( aAlias, {'CTJ'})
aAdd( aAlias, {'CTM'})
aAdd( aAlias, {'CTN'})
aAdd( aAlias, {'CTO'})
aAdd( aAlias, {'CTS'})
aAdd( aAlias, {'CTT'})
aAdd( aAlias, {'CVD'})
aAdd( aAlias, {'CVE'})
aAdd( aAlias, {'CVF'})
aAdd( aAlias, {'CVN'})
aAdd( aAlias, {'DA0'})
aAdd( aAlias, {'DA1'})
aAdd( aAlias, {'DA3'})
aAdd( aAlias, {'DHL'})
aAdd( aAlias, {'NNR'})
aAdd( aAlias, {'QPJ'})
aAdd( aAlias, {'SA2'})
aAdd( aAlias, {'SA3'})
aAdd( aAlias, {'SA4'})
aAdd( aAlias, {'SA5'})
aAdd( aAlias, {'SAD'})
aAdd( aAlias, {'SAH'})
aAdd( aAlias, {'SAI'})
aAdd( aAlias, {'SAJ'})
aAdd( aAlias, {'SAK'})
aAdd( aAlias, {'SAL'})
aAdd( aAlias, {'SB1'})
aAdd( aAlias, {'SB5'})
aAdd( aAlias, {'SBM'})
aAdd( aAlias, {'SBY'})
aAdd( aAlias, {'SDO'})
aAdd( aAlias, {'SDR'})
aAdd( aAlias, {'SE4'})
aAdd( aAlias, {'SEB'})
aAdd( aAlias, {'SED'})
aAdd( aAlias, {'SG1'})
aAdd( aAlias, {'SG5'})
aAdd( aAlias, {'SM2'})
aAdd( aAlias, {'SM4'})
aAdd( aAlias, {'SY1'})
aAdd( aAlias, {'SZ2'})
aAdd( aAlias, {'SZF'})
aAdd( aAlias, {'SZG'})
aAdd( aAlias, {'SZZ'})
aAdd( aAlias, {'Z18'})
aAdd( aAlias, {'ZZ8'})
aAdd( aAlias, {'ZZ9'})
aAdd( aAlias, {'ZZH'})

//Dicionário Euroamerican...
dbUseArea( .T.,, '\SYSTEM\SX3020.DTC', "SX302", .T.)
dbSelectArea("SX302")
dbUseArea( .T.,, '\SYSTEM\SX2020.DTC', "SX202", .T.)
dbSelectArea("SX202")

//Dicionário Qualycril...
dbUseArea( .T.,, '\SYSTEM\SX3080.DTC', "SX308", .T.)
dbSelectArea("SX308")
dbUseArea( .T.,, '\SYSTEM\SX2080.DTC', "SX208", .T.)
dbSelectArea("SX208")

//Dicionário Jays...
dbUseArea( .T.,, '\SYSTEM\SX3010.DTC', "SX301", .T.)
dbSelectArea("SX301")
dbUseArea( .T.,, '\SYSTEM\SX2020.DTC', "SX201", .T.)
dbSelectArea("SX201")

//Dicionário Metropole...
dbUseArea( .T.,, '\SYSTEM\SX3060.DTC', "SX306", .T.)
dbSelectArea("SX306")
dbUseArea( .T.,, '\SYSTEM\SX2020.DTC', "SX206", .T.)
dbSelectArea("SX206")

//Dicionário Qualyvinil...
dbUseArea( .T.,, '\SYSTEM\SX3030.DTC', "SX303", .T.)
dbSelectArea("SX303")
dbUseArea( .T.,, '\SYSTEM\SX2020.DTC', "SX203", .T.)
dbSelectArea("SX203")

dbSelectArea("SX202")
SX202->( dbSetOrder(1) )
SX202->( dbGoTop() )
Do While !SX202->( Eof() )
	If aScan( aAlias, {|x| AllTrim( x[1] ) == AllTrim( SX202->X2_CHAVE ) }) == 0
		aAdd( aAlias, { AllTrim( SX202->X2_CHAVE ) })
	EndIf

	SX202->( dbSkip() )
EndDo

dbSelectArea("SX208")
SX208->( dbSetOrder(1) )
SX208->( dbGoTop() )
Do While !SX208->( Eof() )
	If aScan( aAlias, {|x| AllTrim( x[1] ) == AllTrim( SX208->X2_CHAVE ) }) == 0
		aAdd( aAlias, { AllTrim( SX208->X2_CHAVE ) })
	EndIf

	SX208->( dbSkip() )
EndDo

dbSelectArea("SX206")
SX206->( dbSetOrder(1) )
SX206->( dbGoTop() )
Do While !SX206->( Eof() )
	If aScan( aAlias, {|x| AllTrim( x[1] ) == AllTrim( SX206->X2_CHAVE ) }) == 0
		aAdd( aAlias, { AllTrim( SX206->X2_CHAVE ) })
	EndIf

	SX206->( dbSkip() )
EndDo

dbSelectArea("SX201")
SX201->( dbSetOrder(1) )
SX201->( dbGoTop() )
Do While !SX201->( Eof() )
	If aScan( aAlias, {|x| AllTrim( x[1] ) == AllTrim( SX201->X2_CHAVE ) }) == 0
		aAdd( aAlias, { AllTrim( SX201->X2_CHAVE ) })
	EndIf

	SX201->( dbSkip() )
EndDo

dbSelectArea("SX203")
SX203->( dbSetOrder(1) )
SX203->( dbGoTop() )
Do While !SX203->( Eof() )
	If aScan( aAlias, {|x| AllTrim( x[1] ) == AllTrim( SX203->X2_CHAVE ) }) == 0
		aAdd( aAlias, { AllTrim( SX203->X2_CHAVE ) })
	EndIf

	SX203->( dbSkip() )
EndDo

ProcRegua( Len( aAlias ) )

For nLin := 1 To Len( aAlias )
	IncProc( "Processando: " + aAlias[nLin][01] )

	// Euroamerican
	dbSelectArea("SX302")
	dbSetOrder(1)
	If SX302->( dbSeek( aAlias[nLin][01] ) )
		Do While !SX302->( Eof() ) .And. AllTrim( SX302->X3_ARQUIVO ) == AllTrim( aAlias[nLin][01] )
			// Ver se campo existe na 08...
			dbSelectArea("SX308")
			dbSetOrder(2)
			If SX308->( dbSeek( SX302->X3_CAMPO ) )
				If !(SX302->X3_TIPO == SX308->X3_TIPO .And. SX302->X3_TAMANHO == SX308->X3_TAMANHO)
					aAdd( aDiverg, {"Campo " + SX302->X3_CAMPO + " da 02 com tipo ou tamanho diferente na 08"})
				EndIf
			Else
				dbSelectArea("SX208")
				SX208->( dbSetOrder(1) )
				If SX208->( dbSeek( SX302->X3_ARQUIVO ) )
					aAdd( aDiverg, {"Campo " + SX302->X3_CAMPO + " da 02 não existe na 08"})
				EndIf
			EndIf

			// Ver se campo existe na 01...
			dbSelectArea("SX301")
			dbSetOrder(2)
			If SX301->( dbSeek( SX302->X3_CAMPO ) )
				If !(SX302->X3_TIPO == SX301->X3_TIPO .And. SX302->X3_TAMANHO == SX301->X3_TAMANHO)
					aAdd( aDiverg, {"Campo " + SX302->X3_CAMPO + " da 02 com tipo ou tamanho diferente na 01"})
				EndIf
			Else
				dbSelectArea("SX201")
				dbSetOrder(1)
				If SX201->( dbSeek( SX302->X3_ARQUIVO ) )
					aAdd( aDiverg, {"Campo " + SX302->X3_CAMPO + " da 02 não existe na 01"})
				EndIf
			EndIf

			// Ver se campo existe na 06...
			dbSelectArea("SX306")
			dbSetOrder(2)
			If SX306->( dbSeek( SX302->X3_CAMPO ) )
				If !(SX302->X3_TIPO == SX306->X3_TIPO .And. SX302->X3_TAMANHO == SX306->X3_TAMANHO)
					aAdd( aDiverg, {"Campo " + SX302->X3_CAMPO + " da 02 com tipo ou tamanho diferente na 06"})
				EndIf
			Else
				dbSelectArea("SX206")
				dbSetOrder(1)
				If SX206->( dbSeek( SX302->X3_ARQUIVO ) )
					aAdd( aDiverg, {"Campo " + SX302->X3_CAMPO + " da 02 não existe na 06"})
				EndIf
			EndIf

			// Ver se campo existe na 03...
			dbSelectArea("SX303")
			dbSetOrder(2)
			If SX303->( dbSeek( SX302->X3_CAMPO ) )
				If !(SX302->X3_TIPO == SX303->X3_TIPO .And. SX302->X3_TAMANHO == SX303->X3_TAMANHO)
					aAdd( aDiverg, {"Campo " + SX302->X3_CAMPO + " da 02 com tipo ou tamanho diferente na 03"})
				EndIf
			Else
				dbSelectArea("SX203")
				dbSetOrder(1)
				If SX203->( dbSeek( SX302->X3_ARQUIVO ) )
					aAdd( aDiverg, {"Campo " + SX302->X3_CAMPO + " da 02 não existe na 03"})
				EndIf
			EndIf

			SX302->( dbSkip() )
		EndDo
	Else
		aAdd( aDiverg, {"Alias " + aAlias[nLin][01] + " não encontrada no SX3 da empresa 02"})
	EndIf

	// Qualycril
	dbSelectArea("SX308")
	dbSetOrder(1)
	If SX308->( dbSeek( aAlias[nLin][01] ) )
		Do While !SX308->( Eof() ) .And. AllTrim( SX308->X3_ARQUIVO ) == AllTrim( aAlias[nLin][01] )
			// Ver se campo existe na 02...
			dbSelectArea("SX302")
			dbSetOrder(2)
			If SX302->( dbSeek( SX308->X3_CAMPO ) )
				If !(SX308->X3_TIPO == SX302->X3_TIPO .And. SX308->X3_TAMANHO == SX302->X3_TAMANHO)
					aAdd( aDiverg, {"Campo " + SX308->X3_CAMPO + " da 08 com tipo ou tamanho diferente na 02"})
				EndIf
			Else
				dbSelectArea("SX202")
				dbSetOrder(1)
				If SX202->( dbSeek( SX308->X3_ARQUIVO ) )
					aAdd( aDiverg, {"Campo " + SX308->X3_CAMPO + " da 08 não existe na 02"})
				EndIf
			EndIf

			// Ver se campo existe na 01...
			dbSelectArea("SX301")
			dbSetOrder(2)
			If SX301->( dbSeek( SX308->X3_CAMPO ) )
				If !(SX308->X3_TIPO == SX301->X3_TIPO .And. SX308->X3_TAMANHO == SX301->X3_TAMANHO)
					aAdd( aDiverg, {"Campo " + SX308->X3_CAMPO + " da 08 com tipo ou tamanho diferente na 01"})
				EndIf
			Else
				dbSelectArea("SX201")
				dbSetOrder(1)
				If SX201->( dbSeek( SX308->X3_ARQUIVO ) )
					aAdd( aDiverg, {"Campo " + SX308->X3_CAMPO + " da 08 não existe na 01"})
				EndIf
			EndIf

			// Ver se campo existe na 06...
			dbSelectArea("SX306")
			dbSetOrder(2)
			If SX306->( dbSeek( SX308->X3_CAMPO ) )
				If !(SX308->X3_TIPO == SX306->X3_TIPO .And. SX308->X3_TAMANHO == SX306->X3_TAMANHO)
					aAdd( aDiverg, {"Campo " + SX308->X3_CAMPO + " da 08 com tipo ou tamanho diferente na 06"})
				EndIf
			Else
				dbSelectArea("SX206")
				dbSetOrder(1)
				If SX206->( dbSeek( SX308->X3_ARQUIVO ) )
					aAdd( aDiverg, {"Campo " + SX308->X3_CAMPO + " da 08 não existe na 06"})
				EndIf
			EndIf

			// Ver se campo existe na 03...
			dbSelectArea("SX303")
			dbSetOrder(2)
			If SX303->( dbSeek( SX308->X3_CAMPO ) )
				If !(SX308->X3_TIPO == SX303->X3_TIPO .And. SX308->X3_TAMANHO == SX303->X3_TAMANHO)
					aAdd( aDiverg, {"Campo " + SX308->X3_CAMPO + " da 08 com tipo ou tamanho diferente na 03"})
				EndIf
			Else
				dbSelectArea("SX203")
				dbSetOrder(1)
				If SX203->( dbSeek( SX308->X3_ARQUIVO ) )
					aAdd( aDiverg, {"Campo " + SX308->X3_CAMPO + " da 08 não existe na 03"})
				EndIf
			EndIf

			SX308->( dbSkip() )
		EndDo
	Else
		aAdd( aDiverg, {"Alias " + aAlias[nLin][01] + " não encontrada no SX3 da empresa 08"})
	EndIf

	// Jays
	dbSelectArea("SX301")
	dbSetOrder(1)
	If SX301->( dbSeek( aAlias[nLin][01] ) )
		Do While !SX301->( Eof() ) .And. AllTrim( SX301->X3_ARQUIVO ) == AllTrim( aAlias[nLin][01] )
			// Ver se campo existe na 02...
			dbSelectArea("SX302")
			dbSetOrder(2)
			If SX302->( dbSeek( SX301->X3_CAMPO ) )
				If !(SX301->X3_TIPO == SX302->X3_TIPO .And. SX301->X3_TAMANHO == SX302->X3_TAMANHO)
					aAdd( aDiverg, {"Campo " + SX301->X3_CAMPO + " da 01 com tipo ou tamanho diferente na 02"})
				EndIf
			Else
				dbSelectArea("SX202")
				dbSetOrder(1)
				If SX202->( dbSeek( SX301->X3_ARQUIVO ) )
					aAdd( aDiverg, {"Campo " + SX301->X3_CAMPO + " da 01 não existe na 02"})
				EndIf
			EndIf

			// Ver se campo existe na 08...
			dbSelectArea("SX308")
			dbSetOrder(2)
			If SX308->( dbSeek( SX301->X3_CAMPO ) )
				If !(SX301->X3_TIPO == SX308->X3_TIPO .And. SX301->X3_TAMANHO == SX308->X3_TAMANHO)
					aAdd( aDiverg, {"Campo " + SX301->X3_CAMPO + " da 01 com tipo ou tamanho diferente na 08"})
				EndIf
			Else
				dbSelectArea("SX208")
				dbSetOrder(1)
				If SX208->( dbSeek( SX301->X3_ARQUIVO ) )
					aAdd( aDiverg, {"Campo " + SX301->X3_CAMPO + " da 01 não existe na 08"})
				EndIf
			EndIf

			// Ver se campo existe na 06...
			dbSelectArea("SX306")
			dbSetOrder(2)
			If SX306->( dbSeek( SX301->X3_CAMPO ) )
				If !(SX301->X3_TIPO == SX306->X3_TIPO .And. SX301->X3_TAMANHO == SX306->X3_TAMANHO)
					aAdd( aDiverg, {"Campo " + SX301->X3_CAMPO + " da 01 com tipo ou tamanho diferente na 06"})
				EndIf
			Else
				dbSelectArea("SX206")
				dbSetOrder(1)
				If SX206->( dbSeek( SX301->X3_ARQUIVO ) )
					aAdd( aDiverg, {"Campo " + SX301->X3_CAMPO + " da 01 não existe na 06"})
				EndIf
			EndIf

			// Ver se campo existe na 03...
			dbSelectArea("SX303")
			dbSetOrder(2)
			If SX303->( dbSeek( SX301->X3_CAMPO ) )
				If !(SX301->X3_TIPO == SX303->X3_TIPO .And. SX301->X3_TAMANHO == SX303->X3_TAMANHO)
					aAdd( aDiverg, {"Campo " + SX301->X3_CAMPO + " da 01 com tipo ou tamanho diferente na 03"})
				EndIf
			Else
				dbSelectArea("SX203")
				dbSetOrder(1)
				If SX203->( dbSeek( SX301->X3_ARQUIVO ) )
					aAdd( aDiverg, {"Campo " + SX301->X3_CAMPO + " da 01 não existe na 03"})
				EndIf
			EndIf

			SX301->( dbSkip() )
		EndDo
	Else
		aAdd( aDiverg, {"Alias " + aAlias[nLin][01] + " não encontrada no SX3 da empresa 01"})
	EndIf

	// Metropole
	dbSelectArea("SX306")
	dbSetOrder(1)
	If SX306->( dbSeek( aAlias[nLin][01] ) )
		Do While !SX306->( Eof() ) .And. AllTrim( SX306->X3_ARQUIVO ) == AllTrim( aAlias[nLin][01] )
			// Ver se campo existe na 02...
			dbSelectArea("SX302")
			dbSetOrder(2)
			If SX302->( dbSeek( SX306->X3_CAMPO ) )
				If !(SX306->X3_TIPO == SX302->X3_TIPO .And. SX306->X3_TAMANHO == SX302->X3_TAMANHO)
					aAdd( aDiverg, {"Campo " + SX306->X3_CAMPO + " da 06 com tipo ou tamanho diferente na 02"})
				EndIf
			Else
				dbSelectArea("SX202")
				dbSetOrder(1)
				If SX202->( dbSeek( SX306->X3_ARQUIVO ) )
					aAdd( aDiverg, {"Campo " + SX306->X3_CAMPO + " da 06 não existe na 02"})
				EndIf
			EndIf

			// Ver se campo existe na 08...
			dbSelectArea("SX308")
			dbSetOrder(2)
			If SX308->( dbSeek( SX306->X3_CAMPO ) )
				If !(SX306->X3_TIPO == SX308->X3_TIPO .And. SX306->X3_TAMANHO == SX308->X3_TAMANHO)
					aAdd( aDiverg, {"Campo " + SX306->X3_CAMPO + " da 06 com tipo ou tamanho diferente na 08"})
				EndIf
			Else
				dbSelectArea("SX208")
				dbSetOrder(1)
				If SX208->( dbSeek( SX306->X3_ARQUIVO ) )
					aAdd( aDiverg, {"Campo " + SX306->X3_CAMPO + " da 06 não existe na 08"})
				EndIf
			EndIf

			// Ver se campo existe na 01...
			dbSelectArea("SX301")
			dbSetOrder(2)
			If SX301->( dbSeek( SX306->X3_CAMPO ) )
				If !(SX306->X3_TIPO == SX301->X3_TIPO .And. SX306->X3_TAMANHO == SX301->X3_TAMANHO)
					aAdd( aDiverg, {"Campo " + SX306->X3_CAMPO + " da 06 com tipo ou tamanho diferente na 01"})
				EndIf
			Else
				dbSelectArea("SX201")
				dbSetOrder(1)
				If SX201->( dbSeek( SX306->X3_ARQUIVO ) )
					aAdd( aDiverg, {"Campo " + SX306->X3_CAMPO + " da 06 não existe na 01"})
				EndIf
			EndIf

			// Ver se campo existe na 03...
			dbSelectArea("SX303")
			dbSetOrder(2)
			If SX303->( dbSeek( SX306->X3_CAMPO ) )
				If !(SX306->X3_TIPO == SX303->X3_TIPO .And. SX306->X3_TAMANHO == SX303->X3_TAMANHO)
					aAdd( aDiverg, {"Campo " + SX306->X3_CAMPO + " da 06 com tipo ou tamanho diferente na 03"})
				EndIf
			Else
				dbSelectArea("SX203")
				dbSetOrder(1)
				If SX203->( dbSeek( SX306->X3_ARQUIVO ) )
					aAdd( aDiverg, {"Campo " + SX306->X3_CAMPO + " da 06 não existe na 03"})
				EndIf
			EndIf

			SX306->( dbSkip() )
		EndDo
	Else
		aAdd( aDiverg, {"Alias " + aAlias[nLin][01] + " não encontrada no SX3 da empresa 06"})
	EndIf

	// Qualyvinil
	dbSelectArea("SX303")
	dbSetOrder(1)
	If SX303->( dbSeek( aAlias[nLin][01] ) )
		Do While !SX303->( Eof() ) .And. AllTrim( SX303->X3_ARQUIVO ) == AllTrim( aAlias[nLin][01] )
			// Ver se campo existe na 02...
			dbSelectArea("SX302")
			dbSetOrder(2)
			If SX302->( dbSeek( SX303->X3_CAMPO ) )
				If !(SX303->X3_TIPO == SX302->X3_TIPO .And. SX303->X3_TAMANHO == SX302->X3_TAMANHO)
					aAdd( aDiverg, {"Campo " + SX303->X3_CAMPO + " da 03 com tipo ou tamanho diferente na 02"})
				EndIf
			Else
				dbSelectArea("SX202")
				dbSetOrder(1)
				If SX202->( dbSeek( SX303->X3_ARQUIVO ) )
					aAdd( aDiverg, {"Campo " + SX303->X3_CAMPO + " da 03 não existe na 02"})
				EndIf
			EndIf

			// Ver se campo existe na 08...
			dbSelectArea("SX308")
			dbSetOrder(2)
			If SX308->( dbSeek( SX303->X3_CAMPO ) )
				If !(SX303->X3_TIPO == SX308->X3_TIPO .And. SX303->X3_TAMANHO == SX308->X3_TAMANHO)
					aAdd( aDiverg, {"Campo " + SX303->X3_CAMPO + " da 03 com tipo ou tamanho diferente na 08"})
				EndIf
			Else
				dbSelectArea("SX208")
				dbSetOrder(1)
				If SX208->( dbSeek( SX303->X3_ARQUIVO ) )
					aAdd( aDiverg, {"Campo " + SX303->X3_CAMPO + " da 03 não existe na 08"})
				EndIf
			EndIf

			// Ver se campo existe na 01...
			dbSelectArea("SX301")
			dbSetOrder(2)
			If SX301->( dbSeek( SX303->X3_CAMPO ) )
				If !(SX303->X3_TIPO == SX301->X3_TIPO .And. SX303->X3_TAMANHO == SX301->X3_TAMANHO)
					aAdd( aDiverg, {"Campo " + SX303->X3_CAMPO + " da 03 com tipo ou tamanho diferente na 01"})
				EndIf
			Else
				dbSelectArea("SX201")
				dbSetOrder(1)
				If SX201->( dbSeek( SX303->X3_ARQUIVO ) )
					aAdd( aDiverg, {"Campo " + SX303->X3_CAMPO + " da 03 não existe na 01"})
				EndIf
			EndIf

			// Ver se campo existe na 06...
			dbSelectArea("SX306")
			dbSetOrder(2)
			If SX306->( dbSeek( SX303->X3_CAMPO ) )
				If !(SX303->X3_TIPO == SX306->X3_TIPO .And. SX303->X3_TAMANHO == SX306->X3_TAMANHO)
					aAdd( aDiverg, {"Campo " + SX303->X3_CAMPO + " da 03 com tipo ou tamanho diferente na 06"})
				EndIf
			Else
				dbSelectArea("SX206")
				dbSetOrder(1)
				If SX206->( dbSeek( SX303->X3_ARQUIVO ) )
					aAdd( aDiverg, {"Campo " + SX303->X3_CAMPO + " da 03 não existe na 06"})
				EndIf
			EndIf

			SX303->( dbSkip() )
		EndDo
	Else
		aAdd( aDiverg, {"Alias " + aAlias[nLin][01] + " não encontrada no SX3 da empresa 03"})
	EndIf
Next

aEval( aDiverg, { |x| ConOut("FABIO [TUDO] -> " + x[1]) } )

Return