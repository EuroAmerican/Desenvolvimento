#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

User Function MT120BRW()

// ----------- Elementos contidos por dimensao ------------
// 1. Nome a aparecer no cabecalho                             
// 2. Nome da Rotina associada                                 
// 3. Usado pela rotina                                        
// 4. Tipo de Transa‡„o a ser efetuada                         
//    1 - Pesquisa e Posiciona em um Banco de Dados            
//    2 - Simplesmente Mostra os Campos                        
//    3 - Inclui registros no Bancos de Dados                  
//    4 - Altera o registro corrente                           
//    5 - Remove o registro corrente do Banco de Dados         
//    6 - Altera determinados campos sem incluir novos Regs

aAdd( aRotina, { 'Re-Programação'         , 'U_EQReProgC7()', 0, 4 } )
aAdd( aRotina, { 'Consultar Processos'    , 'U_EQHistC7()'  , 0, 6 } )
//aAdd( aRotina, { 'Forçar Troca Fornecedor', 'U_EQForPed()'  , 0, 6 } )

Return