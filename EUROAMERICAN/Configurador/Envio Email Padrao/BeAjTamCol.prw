// Aqui o calculo é efetuado para ajustar tamanho da coluna no 100% do Html, para quando quantidade de colunas
// for maior ou menor que os 100% esperados, assim, adequamos o Html indepente do array...
User Function BeAjTamCol(aColuna)

Local nTotTam := 0
Local nY1     := 0
Local nY2     := 0
Local nY3     := 0

If Len(aColuna) < 1
	Return aColuna
EndIf

aEval( aColuna, {|x| nTotTam += x[2] })

If nTotTam < 100
	// Se a soma de todos as porcentagens menor que cem, distribui a diferença para cada coluna...
	nY2 := (100 - nTotTam) / Len(aColuna)
	For nY1 := 1 To Len(aColuna)
		aColuna[nY1][2] := aColuna[nY1][2] + nY2
	Next
ElseIf nTotTam > 100
	// Se a soma de todas as porcentagens maior que cem, calcular a proporção para chegar no total de cem exato...
	For nY1 := 1 To Len(aColuna)
		aColuna[nY1][2] := (aColuna[nY1][2] * (100 / nTotTam))
	Next
EndIf

Return aColuna
