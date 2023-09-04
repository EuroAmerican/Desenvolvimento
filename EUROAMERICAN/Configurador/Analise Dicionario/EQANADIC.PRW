#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'Colors.Ch'
#Include 'JPeg.Ch'
#Include 'HButton.Ch'
#Include 'DBTree.Ch'
#Include 'Font.Ch'
#Include 'TbiConn.Ch'
#Include 'Ap5Mail.Ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ EQAnaDic º Autor ³ Fabio F. Sousa   º Data ³  27/06/2019   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Analisa inconsistências no Dicionário de Dados...          º±±
±±º          ³ SX1 - Perguntas                                            º±±
±±º          ³ SX2 - Arquivos                                             º±±
±±º          ³ SX3 - Campos                                               º±±
±±º          ³ SX5 - Tabelas                                              º±±
±±º          ³ SX6 - Parâmetros                                           º±±
±±º          ³ SX7 - Gatilhos                                             º±±
±±º          ³ SX9 - Relacionamentos entre Arquivos                       º±±
±±º          ³ SXA - Pastas                                               º±±
±±º          ³ SXB - Consulta Padrão                                      º±±
±±º          ³ SXD - Processo Schedule                                    º±±
±±º          ³ SXG - Tamanho Padrao                                       º±±
±±º          ³ SIX - Índices                                              º±±
±±º          ³ CT0 - Conferência de Entidades Contábeis                   º±±
±±º          ³ USU - Usuários                                             º±±
±±º          ³ GRU - Grupo de Usuários                                    º±±
±±º          ³                                                            º±±
±±º********* ³ Ocorrências: **********************************************º±±
±±º          ³                                                            º±±
±±º          ³ SX1 - Grupo de perguntas vazio                             º±±
±±º          ³ SX1 - Grupo de perguntas duplicado                         º±±
±±º          ³ SX1 - Grupo de Perguntas XXXXXXXXXX-XX com Tamanho Padrão  º±±
±±º          ³       definida não existente para este arquivo: XXXXXX     º±±
±±º          ³ SX1 - Grupo de Perguntas XXXXXXXXXX-XX com tamanho fora da º±±
±±º          ³       especificação do Tamanho Padrão definida: XXX        º±±
±±º          ³ SX1 - Grupo de Perguntas XXXXXXXXXX-XX com máscara fora da º±±
±±º          ³       especificação do Tamanho Padrão definida: XXX        º±±
±±º          ³ SX2 - Arquivo duplicado                                    º±±
±±º          ³ SX2 - Arquivo com mais de 350 campos, atenção, o limite é  º±±
±±º          ³       359                                                  º±±
±±º          ³ SX3 - Campo duplicado                                      º±±
±±º          ³ SX3 - Campo XX_XXXXXX criado sem arquivo no SX2: XXX       º±±
±±º          ³ SX3 - Campo XX_XXXXXX com Pasta definida não existente paraº±±
±±º          ³       este arquivo: X                                      º±±
±±º          ³ SX3 - Campo XX_XXXXXX com Tamanho Padrão definida não      º±±
±±º          ³       existente para este arquivo: XXXXXX                  º±±
±±º          ³ SX3 - Campo XX_XXXXXX com tamanho fora da especificação do º±±
±±º          ³       Tamanho Padrão definida: XXX                         º±±
±±º          ³ SX3 - Campo XX_XXXXXX com máscara fora da especificação do º±±
±±º          ³       Tamanho Padrão definida: XXX                         º±±
±±º          ³ SX3 - Campo XX_XXXXXX com ordem definida inválida: XX      º±±
±±º          ³ SX3 - Campo XX_XXXXXX com ordem definida duplicada no      º±±
±±º          ³       dicionário de dados: XX                              º±±
±±º          ³ SX3 - Campo XX_XXXXXX ordem fora da sequência correta,     º±±
±±º          ³       está: XX e devia está: YY                            º±±
±±º          ³ SX3 - Campo XX_XXXXXX tipo data com tamanho incorreto      º±±
±±º          ³ SX3 - Campo XX_XXXXXX com propriedade vazia                º±±
±±º          ³ SX5 - Tabela duplicada                                     º±±
±±º          ³ SX5 - Tabela existente não possui o pai 00                 º±±
±±º          ³ SX6 - Parâmetro duplicado                                  º±±
±±º          ³ SX6 - Parâmetro com filial XX inexistente para a empresa:  º±±
±±º          ³       XX                                                   º±±
±±º          ³ SX6 - Parâmetro XX_XXXXXX com propriedade vazia            º±±
±±º          ³ SX7 - Gatilho duplicado                                    º±±
±±º          ³ SX7 - Campo do gatilho XX_XXXXXX não existe no dicionário  º±±
±±º          ³       de dados                                             º±±
±±º          ³ SX7 - Campo Domínio do gatilho XX_XXXXXX não existe no     º±±
±±º          ³       dicionário de dadosv                                 º±±
±±º          ³ SX7 - Gatilho definido para Posicionar sem Alias declarado º±±
±±º          ³ SX7 - Gatilho definido para Posicionar com Alias declarado º±±
±±º          ³       e sem ordem de pesquisa válida                       º±±
±±º          ³ SX7 - Gatilho definido para Posicionar com Alias declarado º±±
±±º          ³       e com ordem definida e sem chave para pesquisa       º±±
±±º          ³ SX7 - Gatilho XX_XXXXXX com propriedade vazia              º±±
±±º          ³ SX9 - Relacionamento Entre Arquivos duplicado              º±±
±±º          ³ SX9 - Dominío criado sem arquivo no SX2: XXX               º±±
±±º          ³ SX9 - Contra Dominío criado sem arquivo no SX2: XXX        º±±
±±º          ³ SX9 - Campo: XX_XXXXXX não existente no dicionário de dadosº±±
±±º          ³ SXA - Pastas duplicado                                     º±±
±±º          ³ SXB - Consulta Padrão duplicado                            º±±
±±º          ³ SXD - Controle de Schedule de Processos duplicado          º±±
±±º          ³ SXG - Tamanho Padrão para Campos duplicado                 º±±
±±º          ³ SIX - Índice duplicado                                     º±±
±±º          ³ SIX - Chave do índice igual ao índice: XXX-X               º±±
±±º          ³ SIX - Índice criado sem arquivo no SX2: XXX                º±±
±±º          ³ SIX - Campo: XX_XXXXXX não existente no dicionário de dadosº±±
±±º          ³ SIX - Índice XXXXXX-X com propriedade vazia                º±±
±±º          ³ CT0 - Conferência de Entidades Contábeis duplicada         º±±
±±º          ³ USU - Usuário com mais de um acesso simultâneo Liberado    º±±
±±º          ³ USU - Usuário bloqueado está definido no conteúdo do       º±±
±±º          ³       parâmetro: XX_XXXXXXX                                º±±
±±º          ³ USU - E-mail do Usuário bloqueado está definido no conteúdoº±±
±±º          ³       do parâmetro: XX_XXXXXXX                             º±±
±±º          ³ USU - Usuário com dias a retroceder acima do limite de     º±±
±±º          ³       X.XXX                                                º±±
±±º          ³ USU - Usuário com dias a avançar acima do limite de X.XXX  º±±
±±º          ³ GRU - Grupo de Usuários com dias a retroceder acima do     º±±
±±º          ³       limite de X.XXX                                      º±±
±±º          ³ GRU - Grupo de Usuários com dias a avançar acima do limite º±±
±±º          ³       de X.XXX                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Euroamerican                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function EQAnaDic()

Local oProcess
Local lEnd           := .F.

Private lConfirmado  := .F.
Private lCorrige     := .F.
Private lCriaPai     := .T. // Caso tabela não possua seu respectivo pai (Tabela 00), criar nova para eliminar inconsistências
Private lEMail       := .F. // Envia report das divergências por e-mail
Private cEmail       := Padr( "fabio@xisinformatica.com.br;rodrigo.ferreira@euroamerican.com.br", 100)
Private cExcecoes    := Padr( "ADMINISTRADOR", 100)
Private nLimCpos     := 350 // Limite de campos do SX3 por Arquivo, máximo possível é 359
Private nDiasRet     := 60  // Limite máximo permitido para retroceder dias
Private nDiasAva     := 2   // Limite máximo permitido para avançar dias
Private nMaxSim      := 3   // Máximo de acessos simultâneos por usuário
Private lSX1         := .T.
Private lSX2         := .T.
Private lSX3         := .T.
Private lSX5         := .T.
Private lSX6         := .T.
Private lSX7         := .T.
Private lSX9         := .T.
Private lSXA         := .T.
Private lSXB         := .T.
Private lSXD         := .T.
Private lSXG         := .T.
Private lSIX         := .T.
Private lCT0         := .T.
Private lUSU         := .T.
Private lGRU         := .T.
Private oFontMsg     := TFont():New('Courier new',,-14,.T.)
Private oFontPar     := TFont():New('Arial'      ,,-13,.T.,,,,,,.F.,.T.)
Private oFontPar1    := TFont():New('Arial'      ,,-11,.T.,,,,,,.F.,.F.)
Private oFontRes1    := TFont():New('Courier new',,-11,.F.)
Private oFontRes2    := TFont():New('Courier new',,-16,.T.)
Private oFontRes3    := TFont():New('Arial'      ,,-18,.T.,,,,,,.F.,.F.)

//Default lSchedule := .T.

//If !lSchedule
	DEFINE MSDIALOG oDlgCFG TITLE "EQAnaDic - Apontamento de divergências no dicionário de dados" FROM 000, 000  TO 506, 785 PIXEL
	
		aTFolder := {'Geral','Perguntas','Arquivos','Campos','Tabelas','Parâmetros','Gatilhos','Relac. Arquivos','Pastas','Consulta Padrão','Processo Schedule','Tamanho Padrao','Índices','Conf. Ent. Contábeis','Usuários','Grupo de Usuários' }
		oTFolder := TFolder():New( 0,0,aTFolder,,oDlgCFG,,,,.T.,,C(309),C(174))
	
		oGroup:= TGroup():New(C(003),C(005),C(092),C(303), 'Selecione a modalidade de dicionário para auditoria', oTFolder:aDialogs[1],,,.T.)
	
		oCheckSX1 := TCheckBox():New(C(012),C(010),'Processar SX1 - Perguntas',bSETGET(lSX1),oTFolder:aDialogs[1],150,210,,{|| ProcChec( lSX1, 02 )},,,,,,.T.,,,)
		oCheckSX2 := TCheckBox():New(C(022),C(010),'Processar SX2 - Arquivos',bSETGET(lSX2),oTFolder:aDialogs[1],150,210,,{|| ProcChec( lSX2, 03 )},,,,,,.T.,,,)
		oCheckSX3 := TCheckBox():New(C(032),C(010),'Processar SX3 - Campos',bSETGET(lSX3),oTFolder:aDialogs[1],150,210,,{|| ProcChec( lSX3, 04 )},,,,,,.T.,,,)
		oCheckSX5 := TCheckBox():New(C(042),C(010),'Processar SX5 - Tabelas',bSETGET(lSX5),oTFolder:aDialogs[1],150,210,,{|| ProcChec( lSX5, 05 )},,,,,,.T.,,,)
		oCheckSX6 := TCheckBox():New(C(052),C(010),'Processar SX6 - Parâmetros',bSETGET(lSX6),oTFolder:aDialogs[1],150,210,,{|| ProcChec( lSX6, 06 )},,,,,,.T.,,,)
		oCheckSX7 := TCheckBox():New(C(062),C(010),'Processar SX7 - Gatilhos',bSETGET(lSX7),oTFolder:aDialogs[1],150,210,,{|| ProcChec( lSX7, 07 )},,,,,,.T.,,,)
		oCheckSX9 := TCheckBox():New(C(072),C(010),'Processar SX9 - Relacionamentos entre Arquivos',bSETGET(lSX9),oTFolder:aDialogs[1],150,210,,{|| ProcChec( lSX9, 08 )},,,,,,.T.,,,)
		oCheckSXA := TCheckBox():New(C(082),C(010),'Processar SXA - Pastas',bSETGET(lSXA),oTFolder:aDialogs[1],150,210,,{|| ProcChec( lSXA, 09 )},,,,,,.T.,,,)
		oCheckSXB := TCheckBox():New(C(012),C(160),'Processar SXB - Consulta Padrão',bSETGET(lSXB),oTFolder:aDialogs[1],150,210,,{|| ProcChec( lSXB, 10 )},,,,,,.T.,,,)
		oCheckSXD := TCheckBox():New(C(022),C(160),'Processar SXD - Processo Schedule',bSETGET(lSXD),oTFolder:aDialogs[1],150,210,,{|| ProcChec( lSXD, 11 )},,,,,,.T.,,,)
		oCheckSXG := TCheckBox():New(C(032),C(160),'Processar SXG - Tamanho Padrao',bSETGET(lSXG),oTFolder:aDialogs[1],150,210,,{|| ProcChec( lSXG, 12 )},,,,,,.T.,,,)
		oCheckSIX := TCheckBox():New(C(042),C(160),'Processar SIX - Índices',bSETGET(lSIX),oTFolder:aDialogs[1],150,210,,{|| ProcChec( lSIX, 13 )},,,,,,.T.,,,)
		oCheckCT0 := TCheckBox():New(C(052),C(160),'Processar CT0 - Conferência de Entidades Contábeis',bSETGET(lCT0),oTFolder:aDialogs[1],150,210,,{|| ProcChec( lCT0, 14 )},,,,,,.T.,,,)
		oCheckUSU := TCheckBox():New(C(062),C(160),'Processar USU - Usuários',bSETGET(lUSU),oTFolder:aDialogs[1],150,210,,{|| ProcChec( lUSU, 15 )},,,,,,.T.,,,)
		oCheckGRU := TCheckBox():New(C(072),C(160),'Processar GRU - Grupo de Usuários',bSETGET(lGRU),oTFolder:aDialogs[1],150,210,,{|| ProcChec( lGRU, 16 )},,,,,,.T.,,,)
	
		oGroup:= TGroup():New(C(095),C(005),C(159),C(303), 'Parâmetros de processamentos', oTFolder:aDialogs[1],,,.T.)
	
		oCheckPar1 := TCheckBox():New(C(106),C(010),'Gerar correção no dicionário de dados durante o processamento',bSETGET(lCorrige),oTFolder:aDialogs[1],280,210,,{|| },oFontPar,,CLR_HRED,CLR_WHITE,,.T.,,,)
		oCheckPar2 := TCheckBox():New(C(116),C(010),'Criar tabela Pai (Tabela 00) caso haja inconsistência',bSETGET(lCriaPai),oTFolder:aDialogs[1],180,210,,{|| },oFontPar1,,CLR_BLUE,CLR_WHITE,,.T.,,,)
		oSayPar3   := TSay():New(C(128),C(010),{||'Limite de campos do SX3 por Arquivo'},oTFolder:aDialogs[1],,oFontPar1,,,,.T.,CLR_RED,CLR_WHITE,200,20)
		oGetPar3   := TGet():New( C(126),C(128), { | u | If( PCount() == 0, nLimCpos, nLimCpos := u ) },oTFolder:aDialogs[1], C(030), C(007), "@E 999",{|| nLimCpos >= 350 .And. nLimCpos <= 359}, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nLimCpos",,,,.T.)
		oSayPar4   := TSay():New(C(138),C(010),{||'Limite máximo p/ retroceder dias para usuários/grupos'},oTFolder:aDialogs[1],,oFontPar1,,,,.T.,CLR_RED,CLR_WHITE,200,20)
		oGetPar4   := TGet():New( C(136),C(128), { | u | If( PCount() == 0, nDiasRet, nDiasRet := u ) },oTFolder:aDialogs[1], C(030), C(007), "@E 999",{|| nDiasRet <= 1000}, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nDiasRet",,,,.T.)
		oSayPar5   := TSay():New(C(148),C(010),{||'Limite máximo p/ avançar dias para usuários/grupos'},oTFolder:aDialogs[1],,oFontPar1,,,,.T.,CLR_RED,CLR_WHITE,200,20)
		oGetPar5   := TGet():New( C(146),C(128), { | u | If( PCount() == 0, nDiasAva, nDiasAva := u ) },oTFolder:aDialogs[1], C(030), C(007), "@E 999",{|| nDiasAva <= 1000}, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nDiasAva",,,,.T.)
	
		oCheckPar6 := TCheckBox():New(C(116),C(160),'Enviar report das divergências por e-mail',bSETGET(lEMail),oTFolder:aDialogs[1],180,210,,{|| },oFontPar1,,CLR_BLUE,CLR_WHITE,,.T.,,,)
		oSayPar7   := TSay():New(C(128),C(160),{||'E-Mail'},oTFolder:aDialogs[1],,oFontPar1,,,,.T.,CLR_RED,CLR_WHITE,200,20)
		oGetPar7   := TGet():New( C(126),C(185), { | u | If( PCount() == 0, cEmail, cEmail := u ) },oTFolder:aDialogs[1], C(116), C(007), "",{|| .T.}, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cEmail",,,,.T.)
		oSayPar8   := TSay():New(C(138),C(160),{||'Limite máximo de acessos simultâneos'},oTFolder:aDialogs[1],,oFontPar1,,,,.T.,CLR_RED,CLR_WHITE,200,20)
		oGetPar8   := TGet():New( C(136),C(271), { | u | If( PCount() == 0, nMaxSim, nMaxSim := u ) },oTFolder:aDialogs[1], C(030), C(007), "@E 999",{|| nMaxSim >= 2 .And. nMaxSim <= 99}, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nMaxSim",,,,.T.)
		oSayPar9   := TSay():New(C(148),C(160),{||'Exceções Usuários'},oTFolder:aDialogs[1],,oFontPar1,,,,.T.,CLR_RED,CLR_WHITE,200,20)
		oGetPar9   := TGet():New( C(146),C(200), { | u | If( PCount() == 0, cExcecoes, cExcecoes := u ) },oTFolder:aDialogs[1], C(100), C(007), "",{|| .T.}, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cExcecoes",,,,.T.)
	
		oGroup:= TGroup():New(C(003),C(005),C(159),C(303), 'SX1 - Perguntas', oTFolder:aDialogs[2],,,.T.)
		oGroup:= TGroup():New(C(003),C(005),C(159),C(303), 'SX2 - Arquivos', oTFolder:aDialogs[3],,,.T.)
		oGroup:= TGroup():New(C(003),C(005),C(159),C(303), 'SX3 - Campos', oTFolder:aDialogs[4],,,.T.)
		oGroup:= TGroup():New(C(003),C(005),C(159),C(303), 'SX5 - Tabelas', oTFolder:aDialogs[5],,,.T.)
		oGroup:= TGroup():New(C(003),C(005),C(159),C(303), 'SX6 - Parâmetros', oTFolder:aDialogs[6],,,.T.)
		oGroup:= TGroup():New(C(003),C(005),C(159),C(303), 'SX7 - Gatilhos', oTFolder:aDialogs[7],,,.T.)
		oGroup:= TGroup():New(C(003),C(005),C(159),C(303), 'SX9 - Relacionamentos entre Arquivos', oTFolder:aDialogs[8],,,.T.)
		oGroup:= TGroup():New(C(003),C(005),C(159),C(303), 'SXA - Pastas', oTFolder:aDialogs[9],,,.T.)
		oGroup:= TGroup():New(C(003),C(005),C(159),C(303), 'SXB - Consulta Padrão', oTFolder:aDialogs[10],,,.T.)
		oGroup:= TGroup():New(C(003),C(005),C(159),C(303), 'SXD - Processo Schedule', oTFolder:aDialogs[11],,,.T.)
		oGroup:= TGroup():New(C(003),C(005),C(159),C(303), 'SXG - Tamanho Padrao', oTFolder:aDialogs[12],,,.T.)
		oGroup:= TGroup():New(C(003),C(005),C(159),C(303), 'SIX - Índices', oTFolder:aDialogs[13],,,.T.)
		oGroup:= TGroup():New(C(003),C(005),C(159),C(303), 'CT0 - Conferência de Entidades Contábeis', oTFolder:aDialogs[14],,,.T.)
		oGroup:= TGroup():New(C(003),C(005),C(159),C(303), 'USU - Usuários', oTFolder:aDialogs[15],,,.T.)
		oGroup:= TGroup():New(C(003),C(005),C(159),C(303), 'GRU - Grupo de Usuários', oTFolder:aDialogs[16],,,.T.)
	
		oTreeSX1 := DBTree():New(C(012),C(010),C(155),C(298), oTFolder:aDialogs[2],,,.T.,.F.,,'Descrição - Clique <+> para expandir e <-> para recolher detalhes')
		oTreeSX1:BeginUpdate()
		oTreeSX1:AddItem( "Inconsistências"                                      , "001", 'S4WB016N' ,,,,1)
		oTreeSX1:AddItem( ""                                                     , "002", 'CHECKED'  ,,,,2)
		oTreeSX1:AddItem( ""                                                     , "003", 'CHECKED'  ,,,,2)
		oTreeSX1:AddItem( ""                                                     , "004", 'CHECKED'  ,,,,2)
		oTreeSX1:AddItem( ""                                                     , "005", 'CHECKED'  ,,,,2)
		oTreeSX1:AddItem( ""                                                     , "006", 'UNCHECKED',,,,2)
		oTreeSX1:ChangePrompt("Grupo de perguntas vazio","002")
		oTreeSX1:ChangePrompt("Registro duplicado","003")
		oTreeSX1:ChangePrompt("Grupo de Perguntas XXXXXXXXXX-XX com Tamanho Padrão definida não existente para este arquivo: XXXXXX","004")
		oTreeSX1:ChangePrompt("Grupo de Perguntas XXXXXXXXXX-XX com tamanho fora da especificação do Tamanho Padrão definida: XXX","005")
		oTreeSX1:ChangePrompt("Grupo de Perguntas XXXXXXXXXX-XX com máscara fora da especificação do Tamanho Padrão definida: XXX","006")
		oTreeSX1:PTRefresh()
		oTreeSX1:EndUpdate()
	
		oTreeSX2 := DBTree():New(C(012),C(010),C(155),C(298), oTFolder:aDialogs[3],,,.T.,.F.,,'Descrição - Clique <+> para expandir e <-> para recolher detalhes')
		oTreeSX2:BeginUpdate()
		oTreeSX2:AddItem( "Inconsistências"                                      , "001", 'S4WB009N' ,,,,1)
		oTreeSX2:AddItem( ""                                                     , "002", 'CHECKED'  ,,,,2)
		oTreeSX2:AddItem( ""                                                     , "003", 'UNCHECKED',,,,2)
		oTreeSX2:ChangePrompt("Arquivo duplicado","002")
		oTreeSX2:ChangePrompt("Arquivo com mais de XXX campos, atenção, o limite é 359","003")
		oTreeSX2:PTRefresh()
		oTreeSX2:EndUpdate()
	
		oTreeSX3 := DBTree():New(C(012),C(010),C(155),C(298), oTFolder:aDialogs[4],,,.T.,.F.,,'Descrição - Clique <+> para expandir e <-> para recolher detalhes')
		oTreeSX3:BeginUpdate()
		oTreeSX3:AddItem( "Inconsistências"                                      , "001", 'BMPTRG'   ,,,,1)
		oTreeSX3:AddItem( ""                                                     , "002", 'CHECKED'  ,,,,2)
		oTreeSX3:AddItem( ""                                                     , "003", 'CHECKED'  ,,,,2)
		oTreeSX3:AddItem( ""                                                     , "004", 'CHECKED'  ,,,,2)
		oTreeSX3:AddItem( ""                                                     , "005", 'CHECKED'  ,,,,2)
		oTreeSX3:AddItem( ""                                                     , "006", 'CHECKED'  ,,,,2)
		oTreeSX3:AddItem( ""                                                     , "007", 'UNCHECKED',,,,2)
		oTreeSX3:AddItem( ""                                                     , "008", 'CHECKED'  ,,,,2)
		oTreeSX3:AddItem( ""                                                     , "009", 'CHECKED'  ,,,,2)
		oTreeSX3:AddItem( ""                                                     , "010", 'CHECKED'  ,,,,2)
		oTreeSX3:AddItem( ""                                                     , "011", 'UNCHECKED',,,,2)
		oTreeSX3:AddItem( ""                                                     , "012", 'CHECKED'  ,,,,2)
		oTreeSX3:ChangePrompt("Campo duplicado","002")
		oTreeSX3:ChangePrompt("Campo XX_XXXXXX criado sem arquivo no SX2: XXX","003")
		oTreeSX3:ChangePrompt("Campo XX_XXXXXX com Pasta definida não existente para este arquivo: X","004")
		oTreeSX3:ChangePrompt("Campo XX_XXXXXX com Tamanho Padrão definida não existente para este arquivo: XXXXXX","005")
		oTreeSX3:ChangePrompt("Campo XX_XXXXXX com tamanho fora da especificação do Tamanho Padrão definida: XXX","006")
		oTreeSX3:ChangePrompt("Campo XX_XXXXXX com máscara fora da especificação do Tamanho Padrão definida: XXX","007")
		oTreeSX3:ChangePrompt("Campo XX_XXXXXX com ordem definida inválida: XX","008")
		oTreeSX3:ChangePrompt("Campo XX_XXXXXX com ordem definida duplicada no dicionário de dados: XX","009")
		oTreeSX3:ChangePrompt("Campo XX_XXXXXX ordem fora da sequência correta, está: XX e devia está: YY","010")
		oTreeSX3:ChangePrompt("Campo XX_XXXXXX tipo data com tamanho incorreto","011")
		oTreeSX3:ChangePrompt("Campo XX_XXXXXX com propriedade vazia","012")
		oTreeSX3:EndUpdate()
	
		oTreeSX5 := DBTree():New(C(012),C(010),C(155),C(298), oTFolder:aDialogs[5],,,.T.,.F.,,'Descrição - Clique <+> para expandir e <-> para recolher detalhes')
		oTreeSX5:BeginUpdate()
		oTreeSX5:AddItem( "Inconsistências"                                      , "001", 'NOTE'     ,,,,1)
		oTreeSX5:AddItem( ""                                                     , "002", 'CHECKED'  ,,,,2)
		oTreeSX5:AddItem( ""                                                     , "003", 'CHECKED'  ,,,,2)
		oTreeSX5:ChangePrompt("Tabela duplicada","002")
		oTreeSX5:ChangePrompt("Tabela existente não possui o pai 00","003")
		oTreeSX5:EndUpdate()
	
		oTreeSX6 := DBTree():New(C(012),C(010),C(155),C(298), oTFolder:aDialogs[6],,,.T.,.F.,,'Descrição - Clique <+> para expandir e <-> para recolher detalhes')
		oTreeSX6:BeginUpdate()
		oTreeSX6:AddItem( "Inconsistências"                                      , "001", 'LIQCHECK' ,,,,1)
		oTreeSX6:AddItem( ""                                                     , "002", 'CHECKED'  ,,,,2)
		oTreeSX6:AddItem( ""                                                     , "003", 'CHECKED'  ,,,,2)
		oTreeSX6:AddItem( ""                                                     , "004", 'CHECKED'  ,,,,2)
		oTreeSX6:ChangePrompt("Parâmetro duplicado","002")
		oTreeSX6:ChangePrompt("Parâmetro XX_XXXXXX com propriedade vazia","003")
		oTreeSX6:ChangePrompt("Parâmetro com filial XX inexistente para a empresa: XX","004")
		oTreeSX6:EndUpdate()

	
		oTreeSX7 := DBTree():New(C(012),C(010),C(155),C(298), oTFolder:aDialogs[7],,,.T.,.F.,,'Descrição - Clique <+> para expandir e <-> para recolher detalhes')
		oTreeSX7:BeginUpdate()
		oTreeSX7:AddItem( "Inconsistências"                                      , "001", 'SDUPROP'  ,,,,1)
		oTreeSX7:AddItem( ""                                                     , "002", 'CHECKED'  ,,,,2)
		oTreeSX7:AddItem( ""                                                     , "003", 'CHECKED'  ,,,,2)
		oTreeSX7:AddItem( ""                                                     , "004", 'CHECKED'  ,,,,2)
		oTreeSX7:AddItem( ""                                                     , "005", 'CHECKED'  ,,,,2)
		oTreeSX7:AddItem( ""                                                     , "006", 'CHECKED'  ,,,,2)
		oTreeSX7:AddItem( ""                                                     , "007", 'CHECKED'  ,,,,2)
		oTreeSX7:AddItem( ""                                                     , "008", 'CHECKED'  ,,,,2)
		oTreeSX7:ChangePrompt("Gatilho duplicado","002")
		oTreeSX7:ChangePrompt("Campo do gatilho XX_XXXXXX não existe no dicionário de dados","003")
		oTreeSX7:ChangePrompt("Campo Domínio do gatilho XX_XXXXXX não existe no dicionário de dados","004")
		oTreeSX7:ChangePrompt("Gatilho definido para Posicionar sem Alias declarado","005")
		oTreeSX7:ChangePrompt("Gatilho definido para Posicionar com Alias declarado e sem ordem de pesquisa válida","006")
		oTreeSX7:ChangePrompt("Gatilho definido para Posicionar com Alias declarado e com ordem definida e sem chave para pesquisa","007")
		oTreeSX7:ChangePrompt("Gatilho XX_XXXXXX com propriedade vazia","008")
		oTreeSX7:EndUpdate()
	
		oTreeSX9 := DBTree():New(C(012),C(010),C(155),C(298), oTFolder:aDialogs[8],,,.T.,.F.,,'Descrição - Clique <+> para expandir e <-> para recolher detalhes')
		oTreeSX9:BeginUpdate()
		oTreeSX9:AddItem( "Inconsistências"                                      , "001", 'GLOBO'    ,,,,1)
		oTreeSX9:AddItem( ""                                                     , "002", 'CHECKED'  ,,,,2)
		oTreeSX9:AddItem( ""                                                     , "003", 'CHECKED'  ,,,,2)
		oTreeSX9:AddItem( ""                                                     , "004", 'CHECKED'  ,,,,2)
		oTreeSX9:AddItem( ""                                                     , "005", 'CHECKED'  ,,,,2)
		oTreeSX9:ChangePrompt("Relacionamento Entre Arquivos duplicado","002")
		oTreeSX9:ChangePrompt("Dominío criado sem arquivo no SX2: XXX","003")
		oTreeSX9:ChangePrompt("Contra Dominío criado sem arquivo no SX2: XXX","004")
		oTreeSX9:ChangePrompt("Campo: XX_XXXXXX não existente no dicionário de dados","005")
		oTreeSX9:EndUpdate()
	
		oTreeSXA := DBTree():New(C(012),C(010),C(155),C(298), oTFolder:aDialogs[9],,,.T.,.F.,,'Descrição - Clique <+> para expandir e <-> para recolher detalhes')
		oTreeSXA:BeginUpdate()
		oTreeSXA:AddItem( "Inconsistências"                                      , "001", 'FOLDER6'  ,,,,1)
		oTreeSXA:AddItem( ""                                                     , "002", 'CHECKED'  ,,,,2)
		oTreeSXA:ChangePrompt("Pastas duplicado","002")
		oTreeSXA:EndUpdate()
	
		oTreeSXB := DBTree():New(C(012),C(010),C(155),C(298), oTFolder:aDialogs[10],,,.T.,.F.,,'Descrição - Clique <+> para expandir e <-> para recolher detalhes')
		oTreeSXB:BeginUpdate()
		oTreeSXB:AddItem( "Inconsistências"                                      , "001", 'S4WB011N' ,,,,1)
		oTreeSXB:AddItem( ""                                                     , "002", 'CHECKED'  ,,,,2)
		oTreeSXB:ChangePrompt("Consulta Padrão duplicado","002")
		oTreeSXB:EndUpdate()
	
		oTreeSXD := DBTree():New(C(012),C(010),C(155),C(298), oTFolder:aDialogs[11],,,.T.,.F.,,'Descrição - Clique <+> para expandir e <-> para recolher detalhes')
		oTreeSXD:BeginUpdate()
		oTreeSXD:AddItem( "Inconsistências"                                      , "001", 'RELOAD'   ,,,,1)
		oTreeSXD:AddItem( ""                                                     , "002", 'CHECKED'  ,,,,2)
		oTreeSXD:ChangePrompt("Controle de Schedule de Processos duplicado","002")
		oTreeSXD:EndUpdate()
	
		oTreeSXG := DBTree():New(C(012),C(010),C(155),C(298), oTFolder:aDialogs[12],,,.T.,.F.,,'Descrição - Clique <+> para expandir e <-> para recolher detalhes')
		oTreeSXG:BeginUpdate()
		oTreeSXG:AddItem( "Inconsistências"                                      , "001", 'CONTAINR' ,,,,1)
		oTreeSXG:AddItem( ""                                                     , "002", 'CHECKED'  ,,,,2)
		oTreeSXG:ChangePrompt("Tamanho Padrão para Campos duplicado","002")
		oTreeSXG:EndUpdate()
	
		oTreeSIX := DBTree():New(C(012),C(010),C(155),C(298), oTFolder:aDialogs[13],,,.T.,.F.,,'Descrição - Clique <+> para expandir e <-> para recolher detalhes')
		oTreeSIX:BeginUpdate()
		oTreeSIX:AddItem( "Inconsistências"                                      , "001", 'CARGA'    ,,,,1)
		oTreeSIX:AddItem( ""                                                     , "002", 'CHECKED'  ,,,,2)
		oTreeSIX:AddItem( ""                                                     , "003", 'CHECKED'  ,,,,2)
		oTreeSIX:AddItem( ""                                                     , "004", 'CHECKED'  ,,,,2)
		oTreeSIX:AddItem( ""                                                     , "005", 'CHECKED'  ,,,,2)
		oTreeSIX:AddItem( ""                                                     , "006", 'CHECKED'  ,,,,2)
		oTreeSIX:ChangePrompt("Índice duplicado","002")
		oTreeSIX:ChangePrompt("Chave do índice igual ao índice: XXX-X","003")
		oTreeSIX:ChangePrompt("Índice criado sem arquivo no SX2: XXX","004")
		oTreeSIX:ChangePrompt("Campo: XX_XXXXXX não existente no dicionário de dados","005")
		oTreeSIX:ChangePrompt("Índice XXXXXX-X com propriedade vazia","006")
		oTreeSIX:EndUpdate()
	
		oTreeCT0 := DBTree():New(C(012),C(010),C(155),C(298), oTFolder:aDialogs[14],,,.T.,.F.,,'Descrição - Clique <+> para expandir e <-> para recolher detalhes')
		oTreeCT0:BeginUpdate()
		oTreeCT0:AddItem( "Inconsistências"                                      , "001", 'S4WB008N' ,,,,1)
		oTreeCT0:AddItem( ""                                                     , "002", 'CHECKED'  ,,,,2)
		oTreeCT0:ChangePrompt("Conferência de Entidades Contábeis duplicada","002")
		oTreeCT0:EndUpdate()
	
		oTreeUSU := DBTree():New(C(012),C(010),C(155),C(298), oTFolder:aDialogs[15],,,.T.,.F.,,'Descrição - Clique <+> para expandir e <-> para recolher detalhes')
		oTreeUSU:BeginUpdate()
		oTreeUSU:AddItem( "Inconsistências"                                      , "001", 'BMPUSER'  ,,,,1)
		oTreeUSU:AddItem( ""                                                     , "002", 'UNCHECKED',,,,2)
		oTreeUSU:AddItem( ""                                                     , "003", 'UNCHECKED',,,,2)
		oTreeUSU:AddItem( ""                                                     , "004", 'UNCHECKED',,,,2)
		oTreeUSU:AddItem( ""                                                     , "005", 'UNCHECKED',,,,2)
		oTreeUSU:AddItem( ""                                                     , "006", 'UNCHECKED',,,,2)
		oTreeUSU:ChangePrompt("Usuário com mais de X acesso simultâneo Liberado","002")
		oTreeUSU:ChangePrompt("Usuário bloqueado está definido no conteúdo do parâmetro: XX_XXXXXXX","003")
		oTreeUSU:ChangePrompt("E-mail do Usuário bloqueado está definido no conteúdo do parâmetro: XX_XXXXXXX","004")
		oTreeUSU:ChangePrompt("Usuário com dias a retroceder acima do limite de X.XXX","005")
		oTreeUSU:ChangePrompt("Usuário com dias a avançar acima do limite de X.XXX","006")
		oTreeUSU:EndUpdate()
	
		oTreeGRU := DBTree():New(C(012),C(010),C(155),C(298), oTFolder:aDialogs[16],,,.T.,.F.,,'Descrição - Clique <+> para expandir e <-> para recolher detalhes')
		oTreeGRU:BeginUpdate()
		oTreeGRU:AddItem( "Inconsistências"                                      , "001", 'BMPGROUP' ,,,,1)
		oTreeGRU:AddItem( ""                                                     , "002", 'UNCHECKED',,,,2)
		oTreeGRU:AddItem( ""                                                     , "003", 'UNCHECKED',,,,2)
		oTreeGRU:ChangePrompt("Grupo de Usuários com dias a retroceder acima do limite de X.XXX","002")
		oTreeGRU:ChangePrompt("Grupo de Usuários com dias a avançar acima do limite de X.XXX","003")
		oTreeGRU:EndUpdate()
	
		oTMsgBar   := TMsgBar():New(oDlgCFG, "", .F.,.F.,.F.,.F., CLR_BLACK,,oFontMsg,.F.)
		oTMsgItem1 := TMsgItem():New( oTMsgBar,'Euroamerican', 160,,CLR_BLACK,,.T., {||} )
		oTMsgItem2 := TMsgItem():New( oTMsgBar,AllTrim(SM0->M0_NOME) + " / " + AllTrim(SM0->M0_FILIAL), 550,,CLR_BLACK,,.T., {||} )
	
		@ C(176),C(191) Button "Legenda"   Size C(037),C(010) Action (U_XCFGLeg()) PIXEL OF oDlgCFG
		@ C(176),C(231) Button "Cancelar"  Size C(037),C(010) Action (lConfirmado := .F., oDlgCFG:End()) PIXEL OF oDlgCFG
		@ C(176),C(271) Button "Confirmar" Size C(037),C(010) Action (lConfirmado := .T., oDlgCFG:End()) PIXEL OF oDlgCFG
	
	ACTIVATE MSDIALOG oDlgCFG CENTERED
	
	If lCorrige .And. lConfirmado
		If !ApMsgYesNo("Deseja realmente gerar a correção automática do dicionário de dados?", "EQAnaDic - Atenção")
			lCorrige := .F.
		EndIf
	EndIf

	If lConfirmado
		oProcess := MsNewProcess():New( {|lEnd| VERDIVCFG(@oProcess, @lEnd)}, "Verificando divergências no dicionário de dados", "Preparando registros para validações", .T.)
		oProcess:Activate()
	EndIf
//Else
//	lEmail := .T.
//	VERDIVCFG()
//EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VERDIVCFG³ Autor ³ Fabio F. de Sousa     ³ Data ³ 17.02.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicia processamento das análises de divergências conforme  ³±±
±±³          ³ parâmetrizações informadas...                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VERDIVCFG( oProcess, lEnd )

Local aDivergencia := {} // {Dicionário, Chave, Recno, Descrição}
Local aIndices     := {} // {Índice, Ordem, Chave}
Local aCampos      := {} // {Campo}
Local aOrdem       := {} // Contém ordens válidas para o controle de campos SX3 P11 - 359 campos para cada tabela
Local aArqOrdem    := {}
Local aArea        := {}
Local aUsuarios    := {}
Local aGrupos      := {}
Local aGruPar      := {}
Local aSX1         := {}
Local aSX2         := {}
Local aSX3         := {}
Local aSX5         := {}
Local aSX6         := {}
Local aSX7         := {}
Local aSX9         := {}
Local aSXA         := {}
Local aSXB         := {}
Local aSXD         := {}
Local aSXG         := {}
Local aSIX         := {}
Local aCT0         := {}
Local aUSU         := {}
Local aGRU         := {}
Local aEmpFil      := {}
Local lOrdem       := .F.
Local cChaveAnt    := ""
Local cOrdemAnt    := ""
Local cAlias       := ""
Local aAreaSX1     := SX1->( GetArea() )
Local aAreaSX2     := SX2->( GetArea() )
Local aAreaSX3     := SX3->( GetArea() )
Local aAreaSX6     := SX6->( GetArea() )
Local aAreaSX7     := SX7->( GetArea() )
Local aAreaSX9     := SX9->( GetArea() )
Local aAreaSXA     := SXA->( GetArea() )
Local aAreaSXB     := SXB->( GetArea() )
Local aAreaSXD     := SXD->( GetArea() )
Local aAreaSXG     := SXG->( GetArea() )
Local aAreaSIX     := SIX->( GetArea() )
Local nEmpFil      := 0
Local nIndice      := 0
Local nCpo         := 0
Local nDiv         := 0
Local nSX1         := 0
Local nSX2         := 0
Local nSX3         := 0
Local nSX5         := 0
Local nSX6         := 0
Local nSX7         := 0
Local nSX9         := 0
Local nSXA         := 0
Local nSXB         := 0
Local nSXD         := 0
Local nSXG         := 0
Local nSIX         := 0
Local nCT0         := 0
Local nUSU         := 0
Local nGRU         := 0
Local nOrdem       := 0
Local nArq         := 0
Local nContSX3     := 0
Local nUsuario     := 0
Local nGrupo       := 0
/* Variáveis para envio de e-mail */
Local _cServer     := GETMV('MV_WFSMTP')
Local _cAccount    := GETMV('MV_WFACC')
Local _cPassword   := GETMV('MV_WFPASSW')
Local _cEnvia      := GETMV('MV_WFMAIL')
Local _lConect     := .F.
Local _lEnviado    := .F.
Local _lDisConec   := .F.

Private cMensagem  := ""
Private aColunas   := {}
Private aCabec     := {}

aEmpFil := fRetFils( AllTrim( cEmpAnt ) )

//If !lSchedule
	oProcess:SetRegua1( 15 )
//EndIf

SET EXACT ON // FS - 09.06.2015 (Para o padrão Totvs, esta validação é falsa, causando consequências graves em determinadas validações)...

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa dicionário SX1                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If !lSchedule
	oProcess:IncRegua1( "Processando SX1 - Grupo de Perguntas" )
	Sleep( 10 )
//EndIf

If lSX1
	dbSelectArea("SX1")
	SX1->(DbSetOrder(1))
	SX1->(DbGotop())

//	If !lSchedule
		oProcess:SetRegua2( SX1->( RecCount() ) )
//	EndIf

	cChaveAnt := ""
	SX1->(DbGotop())
	
	Do While !SX1->( Eof() )
//		If !lSchedule
			oProcess:IncRegua2("Grupo de Perguntas: " + AllTrim( SX1->X1_GRUPO ) + " Ordem: " + AllTrim( SX1->X1_ORDEM ))
//		EndIf

		// Verificar se há grupo de perguntas em branco
		If Empty( SX1->X1_GRUPO )
			If Len( aDivergencia ) > 0 .And. aScan( aDivergencia, {|x| AllTrim(x[2]) == AllTrim(SX1->X1_GRUPO + SX1->X1_ORDEM) }) <> 0
				nSX1++
				If lCorrige
					RecLock("SX1", .F.)
						SX1->( dbDelete() )
					SX1->( MsUnLock() )
				EndIf
			Else
				aAdd( aDivergencia, { 'SX1', SX1->X1_GRUPO + SX1->X1_ORDEM, SX1->( Recno() ), 'Grupo de perguntas vazio'})
				nSX1++
				If lCorrige
					RecLock("SX1", .F.)
						SX1->( dbDelete() )
					SX1->( MsUnLock() )
				EndIf
			EndIf
		Else
			// Verifica duplicidade no dicionário SX1
			If cChaveAnt == SX1->X1_GRUPO + SX1->X1_ORDEM
				aAdd( aDivergencia, { 'SX1', SX1->X1_GRUPO + SX1->X1_ORDEM, SX1->( Recno() ), 'Grupo de perguntas duplicado'})
				nSX1++
				If lCorrige
					RecLock("SX1", .F.)
						SX1->( dbDelete() )
					SX1->( MsUnLock() )
				EndIf
			Else
				cChaveAnt := SX1->X1_GRUPO + SX1->X1_ORDEM
			EndIf
		EndIf
	
		If !SX1->( Deleted() )
			// Verifica se tamanho padrão definido no campo existe no cadastro de tamanho padrão caso definido
			If AllTrim( Upper( SX1->X1_TIPO ) ) == "C"
				If !Empty( SX1->X1_GRPSXG )
					dbSelectArea("SXG")
					dbSetOrder(1)
					If !SXG->( dbSeek( SX1->X1_GRPSXG ) )
						aAdd( aDivergencia, { 'SX1', SX1->X1_GRUPO + SX1->X1_ORDEM, SX1->( Recno() ), 'Grupo de Perguntas ' + AllTrim( SX1->X1_GRUPO + SX1->X1_ORDEM ) + ' com Tamanho Padrão definida não existente para este arquivo: ' + SX1->X1_GRPSXG })
						nSX1++
						If lCorrige
							If AllTrim(SX1->X1_GRPSXG) == "10"
								RecLock("SX1", .F.)
									SX1->X1_GRPSXG := "010"
								SX1->( MsUnLock() )
							Else
								RecLock("SX1", .F.)
									SX1->X1_GRPSXG := "   "
								SX1->( MsUnLock() )
							EndIf
						EndIf
					Else
						// Verifica se tamanho do campo está dentro da especificação do tamanho padrão do campo
						If SX1->X1_TAMANHO < SXG->XG_SIZEMIN .Or. SX1->X1_TAMANHO > SXG->XG_SIZEMAX
							aAdd( aDivergencia, { 'SX1', SX1->X1_GRUPO + SX1->X1_ORDEM, SX1->( Recno() ), 'Grupo de Perguntas ' + AllTrim( SX1->X1_GRUPO + SX1->X1_ORDEM ) + ' com tamanho fora da especificação do Tamanho Padrão definida: ' + SX1->X1_GRPSXG })
							nSX1++
							If lCorrige
								RecLock("SX1", .F.)
									SX1->X1_GRPSXG := "   "
								SX1->( MsUnLock() )
							EndIf
						Else
							/*
							If !Empty( SXG->XG_PICTURE ) .And. !Empty( SX1->X1_PICTURE )
								// Verifica se máscara do campo está dentro da especificação do tamanho padrão do campo
								If AllTrim( SX1->X1_PICTURE ) <> AllTrim( SXG->XG_PICTURE )
									aAdd( aDivergencia, { 'SX1', SX1->X1_GRUPO + SX1->X1_ORDEM, SX1->( Recno() ), 'Grupo de Perguntas ' + AllTrim( SX1->X1_GRUPO + SX1->X1_ORDEM ) + ' com máscara fora da especificação do Tamanho Padrão definida: ' + SX1->X1_GRPSXG })
									nSX1++
									If lCorrige
										//RecLock("SX1", .F.)
										//	SX1->X1_PICTURE := SXG->XG_PICTURE
										//SX1->( MsUnLock() )
									EndIf
								EndIf
							EndIf
							*/
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	
		SX1->( DbSkip() )
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa dicionário SX2                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If !lSchedule
	oProcess:IncRegua1( "Processando SX2 - Arquivos" )
	Sleep( 10 )
//EndIf

If lSX2
	dbSelectArea("SX2")
	SX2->(DbSetOrder(1))
	SX2->(DbGotop())
	
//	If !lSchedule
		oProcess:SetRegua2( SX2->( RecCount() ) )
//	EndIf

	cChaveAnt := ""
	SX2->(DbGotop())
	
	Do While !SX2->( Eof() )
//		If !lSchedule
			oProcess:IncRegua2("Arquivo: " + AllTrim( SX2->X2_CHAVE ))
//		EndIf

		// Verifica duplicidade no dicionário SX2
		If cChaveAnt == SX2->X2_CHAVE
			aAdd( aDivergencia, { 'SX2', SX2->X2_CHAVE, SX2->( Recno() ), 'Arquivo duplicado'})
			nSX2++
			If lCorrige
				RecLock("SX2", .F.)
					SX2->( dbDelete() )
				SX2->( MsUnLock() )
			EndIf
		Else
			cChaveAnt := SX2->X2_CHAVE
		EndIf
	
		SX2->( DbSkip() )
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa dicionário SX3                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If !lSchedule
	oProcess:IncRegua1( "Processando SX3 - Campos" )
	Sleep( 10 )
//EndIf

If lSX3
	dbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	SX3->(DbGotop())
	
//	If !lSchedule
		oProcess:SetRegua2( SX3->( RecCount() ) )
//	EndIf

	cChaveAnt := ""
	SX3->(DbGotop())
	
	Do While !SX3->( Eof() )
//		If !lSchedule
			oProcess:IncRegua2("Campo: " + AllTrim( SX3->X3_ARQUIVO ) + " - " + AllTrim( SX3->X3_CAMPO ))
//		EndIf

		// Verifica duplicidade no dicionário SX3
		If AllTrim(cChaveAnt) == AllTrim(SX3->X3_CAMPO)
			aAdd( aDivergencia, { 'SX3', SX3->X3_CAMPO, SX3->( Recno() ), 'Campo duplicado'})
			nSX3++
			If lCorrige
				aArea  := SX3->( GetArea() )
				cAlias := SX3->X3_ARQUIVO
				RecLock("SX3", .F.)
					SX3->( dbDelete() )
				SX3->( MsUnLock() )
				X31UPDTABLE( cAlias )
				SX3->( RestArea( aArea ) )
			EndIf
		Else
			cChaveAnt := SX3->X3_CAMPO
		EndIf
	
		If !SX3->( Deleted() )
			// Verifica se arquivo do campo não existe no arquivo
			dbSelectArea("SX2")
			dbSetOrder(1)
			If !SX2->( dbSeek( SX3->X3_ARQUIVO ) )
				aAdd( aDivergencia, { 'SX3', SX3->X3_CAMPO, SX3->( Recno() ), 'Campo ' + AllTrim( SX3->X3_CAMPO ) + ' criado sem arquivo no SX2: ' + SX3->X3_ARQUIVO })
				nSX3++
				If lCorrige
					aArea  := SX3->( GetArea() )
					cAlias := SX3->X3_ARQUIVO
					RecLock("SX3", .F.)
						SX3->( dbDelete() )
					SX3->( MsUnLock() )
					X31UPDTABLE( cAlias )
					SX3->( RestArea( aArea ) )
				EndIf
			EndIf
		EndIf
	
		If !SX3->( Deleted() )
			// Verifica se pasta definida no campo existe no cadastro de pastas caso definido
			If !Empty( SX3->X3_FOLDER ) .And. SX3->X3_FOLDER <> "0"
				dbSelectArea("SXA")
				dbSetOrder(1)
				If !SXA->( dbSeek( SX3->X3_ARQUIVO + SX3->X3_FOLDER ) )
					aAdd( aDivergencia, { 'SX3', SX3->X3_CAMPO, SX3->( Recno() ), 'Campo ' + AllTrim( SX3->X3_CAMPO ) + ' com Pasta definida não existente para este arquivo: ' + SX3->X3_FOLDER })
					nSX3++
					If lCorrige
						RecLock("SX3", .F.)
							SX3->X3_FOLDER := " "
						SX3->( MsUnLock() )
					EndIf
				EndIf
			EndIf
		EndIf
	
		If !SX3->( Deleted() )
			// Verifica se tamanho padrão definido no campo existe no cadastro de tamanho padrão caso definido
			If AllTrim( Upper( SX3->X3_TIPO ) ) == "C"
				If !Empty( SX3->X3_GRPSXG )
					dbSelectArea("SXG")
					dbSetOrder(1)
					If !SXG->( dbSeek( SX3->X3_GRPSXG ) )
						aAdd( aDivergencia, { 'SX3', SX3->X3_CAMPO, SX3->( Recno() ), 'Campo ' + AllTrim( SX3->X3_CAMPO ) + ' com Tamanho Padrão definida não existente para este arquivo: ' + SX3->X3_GRPSXG })
						nSX3++
						If lCorrige
							If AllTrim(SX3->X3_GRPSXG) == "10"
								RecLock("SX3", .F.)
									SX3->X3_GRPSXG := "010"
								SX3->( MsUnLock() )
							Else
								RecLock("SX3", .F.)
									SX3->X3_GRPSXG := "   "
								SX3->( MsUnLock() )
							EndIf
						EndIf
					Else
						// Verifica se tamanho do campo está dentro da especificação do tamanho padrão do campo
						If SX3->X3_TAMANHO < SXG->XG_SIZEMIN .Or. SX3->X3_TAMANHO > SXG->XG_SIZEMAX
							aAdd( aDivergencia, { 'SX3', SX3->X3_CAMPO, SX3->( Recno() ), 'Campo ' + AllTrim( SX3->X3_CAMPO ) + ' com tamanho fora da especificação do Tamanho Padrão definida: ' + SX3->X3_GRPSXG })
							nSX3++
							If lCorrige
								RecLock("SX3", .F.)
									SX3->X3_GRPSXG := "   "
								SX3->( MsUnLock() )
							EndIf
						Else
							/*
							If !Empty( SXG->XG_PICTURE ) .And. !Empty( SX3->X3_PICTURE )
								// Verifica se máscara do campo está dentro da especificação do tamanho padrão do campo
								If AllTrim( SX3->X3_PICTURE ) <> AllTrim( SXG->XG_PICTURE )
									aAdd( aDivergencia, { 'SX3', SX3->X3_CAMPO, SX3->( Recno() ), 'Campo ' + AllTrim( SX3->X3_CAMPO ) + ' com máscara fora da especificação do Tamanho Padrão definida: ' + SX3->X3_GRPSXG })
									nSX3++
									If lCorrige
										//RecLock("SX3", .F.)
										//	SX3->X3_PICTURE := SXG->XG_PICTURE
										//SX3->( MsUnLock() )
									EndIf
								EndIf
							EndIf
							*/
						EndIf
					EndIf
				EndIf
			ElseIf AllTrim( Upper( SX3->X3_TIPO ) ) == "D"
				If SX3->X3_TAMANHO <> 8
					aAdd( aDivergencia, { 'SX3', SX3->X3_CAMPO, SX3->( Recno() ), 'Campo ' + AllTrim( SX3->X3_CAMPO ) + ' tipo data com tamanho incorreto'})
					nSX3++
					If lCorrige
						aArea  := SX3->( GetArea() )
						cAlias := SX3->X3_ARQUIVO
						RecLock("SX3", .F.)
							SX3->X3_TAMANHO := 8
						SX3->( MsUnLock() )
						X31UPDTABLE( cAlias )
						SX3->( RestArea( aArea ) )
					EndIf
				EndIf
			EndIf
		EndIf

		If !SX3->( Deleted() )
			// Verifica se propriedade está vazia
			If Empty( SX3->X3_PROPRI )
				aAdd( aDivergencia, { 'SX3', SX3->X3_CAMPO, SX3->( Recno() ), 'Campo ' + AllTrim( SX3->X3_CAMPO ) + ' com propriedade vazia' })
				nSX3++
				If lCorrige
					RecLock("SX3", .F.)
						If Left(SX3->X3_ARQUIVO, 2) == "SZ" .Or. Left(SX3->X3_ARQUIVO, 1) == "Z"
							SX3->X3_PROPRI := "U"
						Else
							SX3->X3_PROPRI := "S"
						EndIf
					SX3->( MsUnLock() )
				EndIf
			EndIf
		EndIf

		SX3->( DbSkip() )
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carregar as ordens válidas para o campo X3_ORDEM                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aOrdem := {}
	
	For nOrdem := 1 To 359
		aAdd( aOrdem, { RetAsc(AllTrim(Str(nOrdem)),2,.T.) })
	Next
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Analisa dicionário SX3                                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	SX3->(DbGotop())
	
//	If !lSchedule
		oProcess:SetRegua2( SX3->( RecCount() ) )
//	EndIf

	SX3->(DbGotop())
	
	aArqOrdem := {}
	lOrdem    := .F.
	nOrdem    := 0
	cChaveAnt := ""
	cOrdemAnt := ""
	nContSX3  := 0
	
	Do While !SX3->( Eof() )
//		If !lSchedule
			oProcess:IncRegua2("Ordens Cpo.: " + AllTrim( SX3->X3_ARQUIVO ) + " - " + AllTrim( SX3->X3_CAMPO ) + " - " + AllTrim( SX3->X3_ORDEM ))
//		EndIf

		If AllTrim( cChaveAnt ) <> AllTrim( SX3->X3_ARQUIVO )
			If nContSX3 >= nLimCpos
				aAdd( aDivergencia, { 'SX2', cChaveAnt, nContSX3, cChaveAnt + ' Arquivo com mais de ' + AllTrim( Str( nLimCpos ) ) + ' campos, ' + AllTrim( Str( nContSX3 ) ) + ', atenção, o limite é 359'})
				nSX2++
			EndIf
			cChaveAnt := AllTrim( SX3->X3_ARQUIVO )
			cOrdemAnt := ""
			nOrdem    := 0
			nContSX3  := 0
		EndIf
	
		nOrdem++
		nContSX3++
	
		If aScan( aOrdem, {|xY| AllTrim( xY[1] ) == AllTrim( SX3->X3_ORDEM ) }) == 0
			If aScan( aArqOrdem, {|xS| AllTrim( xS[1] ) == AllTrim( SX3->X3_ARQUIVO ) }) == 0
				aAdd( aArqOrdem, { AllTrim( SX3->X3_ARQUIVO ) })
			EndIf
			lOrdem := .T.
			aAdd( aDivergencia, { 'SX3', SX3->X3_CAMPO, SX3->( Recno() ), 'Campo ' + AllTrim( SX3->X3_CAMPO ) + ' com ordem definida inválida: ' + SX3->X3_ORDEM })
			nSX3++
			If lCorrige
				RecLock("SX3", .F.)
					SX3->X3_ORDEM := "XX"
				SX3->( MsUnLock() )
			EndIf
		Else
			If AllTrim( cOrdemAnt ) == AllTrim( SX3->X3_ORDEM )
				If aScan( aArqOrdem, {|xS| AllTrim( xS[1] ) == AllTrim( SX3->X3_ARQUIVO ) }) == 0
					aAdd( aArqOrdem, { AllTrim( SX3->X3_ARQUIVO ) })
				EndIf
				lOrdem := .T.
				aAdd( aDivergencia, { 'SX3', SX3->X3_CAMPO, SX3->( Recno() ), 'Campo ' + AllTrim( SX3->X3_CAMPO ) + ' com ordem definida duplicada no dicionário de dados: ' + SX3->X3_ORDEM })
				nSX3++
			EndIf
			If AllTrim( RetAsc(AllTrim(Str(nOrdem)),2,.T.) ) <> AllTrim( SX3->X3_ORDEM )
				If aScan( aArqOrdem, {|xS| AllTrim( xS[1] ) == AllTrim( SX3->X3_ARQUIVO ) }) == 0
					aAdd( aArqOrdem, { AllTrim( SX3->X3_ARQUIVO ) })
				EndIf
				lOrdem := .T.
				aAdd( aDivergencia, { 'SX3', SX3->X3_CAMPO, SX3->( Recno() ), 'Campo ' + AllTrim( SX3->X3_CAMPO ) + ' com ordem fora da sequência correta, está: ' + SX3->X3_ORDEM + ' e devia está:' + RetAsc(AllTrim(Str(nOrdem)),2,.T.) })
				nSX3++
			EndIf
		EndIf
	
		cOrdemAnt := AllTrim( SX3->X3_ORDEM )
	
		SX3->( DbSkip() )
	EndDo
	
	If lOrdem .And. lCorrige // Refazer a ordem correta dos campos para o arquivo...
		For nArq := 1 To Len( aArqOrdem )
			dbSelectArea("SX3")
			dbSetOrder(1)
			dbSeek( AllTrim( aArqOrdem[nArq][1] ) )
	
			aCampos := {}
			nOrdem  := 0
	
			Do While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == AllTrim( aArqOrdem[nArq][1] )
				nOrdem++
	
				aAdd( aCampos, { SX3->X3_CAMPO, RetAsc(AllTrim(Str(nOrdem)),2,.T.)})
	
				SX3->( dbSkip() )
			EndDo
	
			dbSelectArea("SX3")
			dbSetOrder(2)
	
			For nOrdem := 1 To Len( aCampos )
				If SX3->( dbSeek( AllTrim( aCampos[nOrdem][1] ) ) )
					RecLock("SX3", .F.)
						SX3->X3_ORDEM := AllTrim( aCampos[nOrdem][2] )
					MsUnLock()
				EndIf
			Next
		Next
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa dicionário SX5                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If !lSchedule
	oProcess:IncRegua1( "Processando SX5 - Tabelas" )
	Sleep( 10 )
//EndIf

If lSX5
	cQuery := "SELECT X5_FILIAL, X5_TABELA, X5_CHAVE, MAX(R_E_C_N_O_) AS SX5REC, " + CRLF
	cQuery += "'UPDATE " + RetSqlName("SX5") + " SET D_E_L_E_T_ = ''*'' WHERE X5_FILIAL = ''' + X5_FILIAL + ''' AND X5_TABELA  = ''' + X5_TABELA + ''' AND X5_CHAVE  = ''' + X5_CHAVE + ''' AND D_E_L_E_T_ = '''' AND R_E_C_N_O_ <> ' + CONVERT(VARCHAR(10), MIN(R_E_C_N_O_)) AS INSTRUCAO " + CRLF
	cQuery += "FROM " + RetSqlName("SX5") + " AS SX5 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE X5_FILIAL <> '*' AND SX5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY X5_FILIAL, X5_TABELA, X5_CHAVE " + CRLF
	cQuery += "HAVING COUNT(*) > 1 " + CRLF
	cQuery += "ORDER BY X5_FILIAL, X5_TABELA, X5_CHAVE " + CRLF
	
	TCQuery cQuery New Alias "TMPSX5"
	dbSelectArea("TMPSX5")
	TMPSX5->( dbGoTop() )
	
//	If !lSchedule
		oProcess:SetRegua2( TMPSX5->( RecCount() ) )
//	EndIf

	TMPSX5->( dbGoTop() )

	Do While !TMPSX5->( Eof() )
//		If !lSchedule
			oProcess:IncRegua2("Tabela: " + AllTrim( TMPSX5->X5_TABELA ) + " Chave: " + AllTrim( TMPSX5->X5_CHAVE ))
//		EndIf

		aAdd( aDivergencia, { 'SX5', TMPSX5->X5_FILIAL + TMPSX5->X5_TABELA + TMPSX5->X5_CHAVE, TMPSX5->SX5REC, 'Tabela duplicada'})
		nSX5++
	
		If lCorrige
			TCSQLExec( TMPSX5->INSTRUCAO )
		EndIf
	
		TMPSX5->( DbSkip() )
	EndDo
	
	TMPSX5->( dbCloseArea() )
	
	cQuery := "SELECT X5_FILIAL, X5_TABELA, X5_CHAVE, MAX(R_E_C_N_O_) AS SX5REC " + CRLF
	cQuery += "FROM " + RetSqlName("SX5") + " AS SX5 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE X5_TABELA <> '00' " + CRLF
	cQuery += "AND NOT EXISTS (SELECT X5_FILIAL FROM " + RetSqlName("SX5") + " WITH (NOLOCK) WHERE X5_TABELA = '00' AND X5_CHAVE = SX5.X5_TABELA AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND SX5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY X5_FILIAL, X5_TABELA, X5_CHAVE " + CRLF
	cQuery += "ORDER BY X5_TABELA, X5_CHAVE, X5_FILIAL " + CRLF
	
	TCQuery cQuery New Alias "TMPSX5"
	dbSelectArea("TMPSX5")
	dbGoTop()
	
	Do While !TMPSX5->( Eof() )
		aAdd( aDivergencia, { 'SX5', TMPSX5->X5_FILIAL + ' - ' + TMPSX5->X5_TABELA + ' - ' + TMPSX5->X5_CHAVE, TMPSX5->SX5REC, 'Tabela existente não possui o pai 00'})
		nSX5++
	
		If lCorrige .And. !lCriaPai
			cQuery := "UPDATE " + RetSqlName("SX5") + " SET D_E_L_E_T_ = '*' " + CRLF
			cQuery += "WHERE R_E_C_N_O_ = " + AllTrim( Str( TMPSX5->SX5REC ) ) + CRLF
			cQuery += "AND SX5.D_E_L_E_T_ = ' ' " + CRLF
	
			TCSQLExec( cQuery )
		ElseIf lCorrige .And. lCriaPai
			dbSelectArea("SX5")
			dbSetOrder(1)
			If !SX5->( dbSeek( xFilial("SX5") + "00" + TMPSX5->X5_TABELA ) )
				RecLock( "SX5", .T.)
					SX5->X5_FILIAL  := xFilial("SX5")
					SX5->X5_TABELA  := "00"
					SX5->X5_CHAVE   := TMPSX5->X5_TABELA
					SX5->X5_DESCRI  := "PAI NAO IDENTIFICADO - ABRIR CHAMADO NA TOTVS"
					SX5->X5_DESCSPA := "PAI NAO IDENTIFICADO - ABRIR CHAMADO NA TOTVS"
					SX5->X5_DESCENG := "PAI NAO IDENTIFICADO - ABRIR CHAMADO NA TOTVS"
				MsUnLock()
			EndIf
		EndIf
	
		TMPSX5->( DbSkip() )
	EndDo
	
	TMPSX5->( dbCloseArea() )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa dicionário SX6                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If !lSchedule
	oProcess:IncRegua1( "Processando SX6 - Parâmetros" )
	Sleep( 10 )
//EndIf

If lSX6
	dbSelectArea("SX6")
	SX6->(DbSetOrder(1))
	SX6->(DbGotop())
	
//	If !lSchedule
		oProcess:SetRegua2( SX6->( RecCount() ) )
//	EndIf

	cChaveAnt := ""
	SX6->(DbGotop())
	
	Do While !SX6->( Eof() )
//		If !lSchedule
			oProcess:IncRegua2("Parâmetros: " + AllTrim( SX6->X6_VAR ))
//		EndIf

		// Verifica duplicidade no dicionário SX6
		If cChaveAnt == SX6->X6_FIL + SX6->X6_VAR
			aAdd( aDivergencia, { 'SX6', SX6->X6_FIL + SX6->X6_VAR, SX6->( Recno() ), 'Parâmetro duplicado'})
			nSX6++
			If lCorrige
				RecLock("SX6", .F.)
					SX6->( dbDelete() )
				SX6->( MsUnLock() )
			EndIf
		Else
			cChaveAnt := SX6->X6_FIL + SX6->X6_VAR
		EndIf

		If !SX6->( Deleted() )
			// Verifica se parâmetro está com filial não existente na empresa
			nEmpFil := aScan( aEmpFil, AllTrim( SX6->X6_FIL ) )
			If nEmpFil == 0
				aAdd( aDivergencia, { 'SX6', SX6->X6_FIL + SX6->X6_VAR, SX6->( Recno() ), 'Parâmetro com filial ' + SX6->X6_FIL + ' inexistente para a empresa: ' + cEmpAnt})
				nSX6++
				If lCorrige
					RecLock("SX6", .F.)
						SX6->( dbDelete() )
					SX6->( MsUnLock() )
				EndIf
			EndIf
		EndIf

		If !SX6->( Deleted() )
			// Verifica se propriedade está vazia
			If Empty( SX6->X6_PROPRI )
				aAdd( aDivergencia, { 'SX6', SX6->X6_FIL + SX6->X6_VAR, SX6->( Recno() ), 'Parâmetro ' + AllTrim(SX6->X6_FIL + SX6->X6_VAR) + ' com propriedade vazia'})
				nSX6++
				If lCorrige
					RecLock("SX6", .F.)
						SX6->X6_PROPRI := "S"
					SX6->( MsUnLock() )
				EndIf
			EndIf
		EndIf

		SX6->( DbSkip() )
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa dicionário SX7                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If !lSchedule
	oProcess:IncRegua1( "Processando SX7 - Gatilhos" )
	Sleep( 10 )
//EndIf

If lSX7
	dbSelectArea("SX7")
	SX7->(DbSetOrder(1))
	SX7->(DbGotop())
	
//	If !lSchedule
		oProcess:SetRegua2( SX7->( RecCount() ) )
//	EndIf

	cChaveAnt := ""
	SX7->(DbGotop())
	
	Do While !SX7->( Eof() )
//		If !lSchedule
			oProcess:IncRegua2("Gatilhos: " + AllTrim( SX7->X7_CAMPO ) + " Sequência: " + AllTrim( SX7->X7_SEQUENC ))
//		EndIf

		// Verifica duplicidade no dicionário SX7
		If cChaveAnt == SX7->X7_CAMPO + SX7->X7_SEQUENC
			aAdd( aDivergencia, { 'SX7', SX7->X7_CAMPO + SX7->X7_SEQUENC, SX7->( Recno() ), 'Gatilho duplicado'})
			nSX7++
			If lCorrige
				RecLock("SX7", .F.)
					SX7->( dbDelete() )
				SX7->( MsUnLock() )
			EndIf
		Else
			cChaveAnt := SX7->X7_CAMPO + SX7->X7_SEQUENC
		EndIf
	
		If !SX7->( Deleted() )
			// Verifica se campo existe no dicionário...
			dbSelectArea("SX3")
			dbSetOrder(2)
			If !SX3->( dbSeek( AllTrim(SX7->X7_CAMPO) ) )
				aAdd( aDivergencia, { 'SX7', SX7->X7_CAMPO + SX7->X7_SEQUENC, SX7->( Recno() ), 'Campo do gatilho ' + AllTrim(SX7->X7_CAMPO) + ' não existe no dicionário de dados'})
				nSX7++
				If lCorrige
					RecLock("SX7", .F.)
						SX7->( dbDelete() )
					SX7->( MsUnLock() )
				EndIf
			EndIf
		EndIf
	
		If !SX7->( Deleted() )
			// Verifica se campo domínio existe no dicionário...
			dbSelectArea("SX3")
			dbSetOrder(2)
			If !SX3->( dbSeek( AllTrim(SX7->X7_CDOMIN) ) )
				aAdd( aDivergencia, { 'SX7', SX7->X7_CAMPO + SX7->X7_SEQUENC, SX7->( Recno() ), 'Campo Domínio do gatilho ' + AllTrim(SX7->X7_CDOMIN) + ' não existe no dicionário de dados'})
				nSX7++
				If lCorrige
					RecLock("SX7", .F.)
						SX7->( dbDelete() )
					SX7->( MsUnLock() )
				EndIf
			EndIf
		EndIf
	
		If !SX7->( Deleted() )
			// Verifica se gatilho deve ser posicionado...
			If AllTrim( SX7->X7_SEEK ) == "S"
				If Empty( SX7->X7_ALIAS ) .And. SX7->X7_ORDEM <> 0
					aAdd( aDivergencia, { 'SX7', SX7->X7_CAMPO + SX7->X7_SEQUENC, SX7->( Recno() ), 'Gatilho definido para Posicionar sem Alias declarado'})
					nSX7++
					If lCorrige
						RecLock("SX7", .F.)
							SX7->X7_SEEK := "N"
						SX7->( MsUnLock() )
					EndIf
				ElseIf SX7->X7_ORDEM == 0 .And. !Empty( SX7->X7_ALIAS )
					aAdd( aDivergencia, { 'SX7', SX7->X7_CAMPO + SX7->X7_SEQUENC, SX7->( Recno() ), 'Gatilho definido para Posicionar com Alias declarado e sem ordem de pesquisa válida'})
					nSX7++
					If lCorrige
						RecLock("SX7", .F.)
							SX7->X7_SEEK := "N"
						SX7->( MsUnLock() )
					EndIf
				ElseIf Empty( SX7->X7_CHAVE ) .And. !Empty( SX7->X7_ALIAS ) .And. SX7->X7_ORDEM <> 0
					aAdd( aDivergencia, { 'SX7', SX7->X7_CAMPO + SX7->X7_SEQUENC, SX7->( Recno() ), 'Gatilho definido para Posicionar com Alias declarado e com ordem definida e sem chave para pesquisa'})
					nSX7++
					If lCorrige
						RecLock("SX7", .F.)
							SX7->X7_SEEK := "N"
						SX7->( MsUnLock() )
					EndIf
				EndIf
			EndIf
		EndIf
	
		If !SX7->( Deleted() )
			// Verifica se propriedade está vazia
			If Empty( SX7->X7_PROPRI )
				aAdd( aDivergencia, { 'SX7', SX7->X7_CAMPO + SX7->X7_SEQUENC, SX7->( Recno() ), 'Gatilho ' + AllTrim(SX7->X7_CAMPO + SX7->X7_SEQUENC) + ' com propriedade vazia'})
				nSX7++
				If lCorrige
					RecLock("SX7", .F.)
						SX7->X7_PROPRI := "S"
					SX7->( MsUnLock() )
				EndIf
			EndIf
		EndIf

		SX7->( DbSkip() )
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa dicionário SX9                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If !lSchedule
	oProcess:IncRegua1( "Processando SX9 - Relacionamento Entre Arquivos" )
	Sleep( 10 )
//EndIf

If lSX9
	dbSelectArea("SX9")
	SX9->(DbSetOrder(1))
	SX9->(DbGotop())
	
//	If !lSchedule
		oProcess:SetRegua2( SX9->( RecCount() ) )
//	EndIf

	cChaveAnt := ""
	SX9->(DbGotop())
	
	Do While !SX9->( Eof() )
//		If !lSchedule
			oProcess:IncRegua2("Domínio: " + AllTrim( SX9->X9_DOM ) + " Identificador: " + AllTrim( SX9->X9_IDENT ))
//		EndIf

		// Verifica duplicidade no dicionário SX9
		If cChaveAnt == SX9->X9_DOM + SX9->X9_IDENT + SX9->X9_CDOM + SX9->X9_EXPDOM + SX9->X9_EXPCDOM
			aAdd( aDivergencia, { 'SX9', SX9->X9_DOM + SX9->X9_IDENT + SX9->X9_CDOM + SX9->X9_EXPDOM + SX9->X9_EXPCDOM, SX9->( Recno() ), 'Relacionamento Entre Arquivos duplicado'})
			nSX9++
			If lCorrige
				RecLock("SX9", .F.)
					SX9->( dbDelete() )
				SX9->( MsUnLock() )
			EndIf
		Else
			cChaveAnt := SX9->X9_DOM + SX9->X9_IDENT + SX9->X9_CDOM + SX9->X9_EXPDOM + SX9->X9_EXPCDOM
		EndIf
	
		If !SX9->( Deleted() )
			// Verifica se arquivo do campo não existe no arquivo
			dbSelectArea("SX2")
			dbSetOrder(1)
			If !SX2->( dbSeek( SX9->X9_DOM ) )
				aAdd( aDivergencia, { 'SX9', SX9->X9_DOM + SX9->X9_IDENT + SX9->X9_CDOM + SX9->X9_EXPDOM + SX9->X9_EXPCDOM, SX9->( Recno() ), 'Dominío criado sem arquivo no SX2: ' + SX9->X9_DOM })
				nSX9++
				If lCorrige
					RecLock("SX9", .F.)
						SX9->( dbDelete() )
					SX9->( MsUnLock() )
				EndIf
			EndIf
		EndIf
	
		If !SX9->( Deleted() )
			// Verifica se arquivo do campo não existe no arquivo
			dbSelectArea("SX2")
			dbSetOrder(1)
			If !SX2->( dbSeek( SX9->X9_CDOM ) )
				aAdd( aDivergencia, { 'SX9', SX9->X9_DOM + SX9->X9_IDENT + SX9->X9_CDOM + SX9->X9_EXPDOM + SX9->X9_EXPCDOM, SX9->( Recno() ), 'Contra Dominío criado sem arquivo no SX2: ' + SX9->X9_CDOM })
				nSX9++
				If lCorrige
					RecLock("SX9", .F.)
						SX9->( dbDelete() )
					SX9->( MsUnLock() )
				EndIf
			EndIf
		EndIf
	
		If !SX9->( Deleted() )
			If SX9->X9_DOM <> "SX5" .And. SX9->X9_CDOM <> "SX5"
				aCampos := SoCampo( AllTrim( Upper( SX9->X9_EXPDOM ) ) )
	
				For nCpo := 1 To Len( aCampos )
					// Verifica se campo do índice existe no dicionário...
					dbSelectArea("SX3")
					dbSetOrder(2)
					If !SX3->( dbSeek( AllTrim(aCampos[nCpo][1]) ) )
						aAdd( aDivergencia, { 'SX9', SX9->X9_DOM + SX9->X9_IDENT + SX9->X9_CDOM + SX9->X9_EXPDOM + SX9->X9_EXPCDOM, SX9->( Recno() ), 'Campo: ' + AllTrim(aCampos[nCpo][1]) + ' não existente no dicionário de dados' })
						nSX9++
						If lCorrige
							RecLock("SX9", .F.)
								SX9->( dbDelete() )
							SX9->( MsUnLock() )
						EndIf
					EndIf
				Next
			EndIf
		EndIf
	
		If !SX9->( Deleted() )
			If SX9->X9_DOM <> "SX5" .And. SX9->X9_CDOM <> "SX5"
				aCampos := SoCampo( AllTrim( Upper( SX9->X9_EXPCDOM ) ) )
	
				For nCpo := 1 To Len( aCampos )
					// Verifica se campo do índice existe no dicionário...
					dbSelectArea("SX3")
					dbSetOrder(2)
					If !SX3->( dbSeek( AllTrim(aCampos[nCpo][1]) ) )
						aAdd( aDivergencia, { 'SX9', SX9->X9_DOM + SX9->X9_IDENT + SX9->X9_CDOM + SX9->X9_EXPDOM + SX9->X9_EXPCDOM, SX9->( Recno() ), 'Campo: ' + AllTrim(aCampos[nCpo][1]) + ' não existente no dicionário de dados' })
						nSX9++
						If lCorrige
							RecLock("SX9", .F.)
								SX9->( dbDelete() )
							SX9->( MsUnLock() )
						EndIf
					EndIf
				Next
			EndIf
		EndIf
	
		SX9->( DbSkip() )
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa dicionário SXA                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If !lSchedule
	oProcess:IncRegua1( "Processando SXA - Pastas" )
	Sleep( 10 )
//EndIf

If lSXA
	dbSelectArea("SXA")
	SXA->(DbSetOrder(1))
	SXA->(DbGotop())
	
//	If !lSchedule
		oProcess:SetRegua2( SXA->( RecCount() ) )
//	EndIf

	cChaveAnt := ""
	SXA->(DbGotop())
	
	Do While !SXA->( Eof() )
//		If !lSchedule
			oProcess:IncRegua2("Arquivo: " + AllTrim( SXA->XA_ALIAS ) + " Ordem: " + AllTrim( SXA->XA_ORDEM ))
//		EndIf

		// Verifica duplicidade no dicionário SXA
		If cChaveAnt == SXA->XA_ALIAS + SXA->XA_ORDEM
			aAdd( aDivergencia, { 'SXA', SXA->XA_ALIAS + SXA->XA_ORDEM, SXA->( Recno() ), 'Pastas duplicado'})
			nSXA++
			If lCorrige
				RecLock("SXA", .F.)
					SXA->( dbDelete() )
				SXA->( MsUnLock() )
			EndIf
		Else
			cChaveAnt := SXA->XA_ALIAS + SXA->XA_ORDEM
		EndIf
	
		SXA->( DbSkip() )
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa dicionário SXB                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If !lSchedule
	oProcess:IncRegua1( "Processando SXB - Consulta Padrão" )
	Sleep( 10 )
//EndIf

If lSXB
	dbSelectArea("SXB")
	SXB->(DbSetOrder(1))
	SXB->(DbGotop())
	
//	If !lSchedule
		oProcess:SetRegua2( SXB->( RecCount() ) )
//	EndIf

	cChaveAnt := ""
	SXB->(DbGotop())
	
	Do While !SXB->( Eof() )
//		If !lSchedule
			oProcess:IncRegua2("Alias: " + AllTrim( SXB->XB_ALIAS ) + " Sequência: " + AllTrim( SXB->XB_SEQ ))
//		EndIf

		// Verifica duplicidade no dicionário SXB
		If cChaveAnt == SXB->XB_ALIAS + SXB->XB_TIPO + SXB->XB_SEQ + SXB->XB_COLUNA + SXB->XB_CONTEM + SXB->XB_WCONTEM
			aAdd( aDivergencia, { 'SXB', SXB->XB_ALIAS + SXB->XB_TIPO + SXB->XB_SEQ + SXB->XB_COLUNA + SXB->XB_CONTEM + SXB->XB_WCONTEM, SXB->( Recno() ), 'Consulta Padrão duplicado'})
			nSXB++
			If lCorrige
				RecLock("SXB", .F.)
					SXB->( dbDelete() )
				SXB->( MsUnLock() )
			EndIf
		Else
			cChaveAnt := SXB->XB_ALIAS + SXB->XB_TIPO + SXB->XB_SEQ + SXB->XB_COLUNA + SXB->XB_CONTEM + SXB->XB_WCONTEM
		EndIf
	
		SXB->( DbSkip() )
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa dicionário SXD                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If !lSchedule
	oProcess:IncRegua1( "Processando SXD - Controle de Schedule" )
	Sleep( 10 )
//EndIf

dbSelectArea("SXD")
If lSXD
	SXD->(DbSetOrder(1))
	SXD->(DbGotop())
	
//	If !lSchedule
		oProcess:SetRegua2( SXD->( RecCount() ) )
//	EndIf

	cChaveAnt := ""
	SXD->(DbGotop())
	
	Do While !SXD->( Eof() )
//		If !lSchedule
			oProcess:IncRegua2("Tipo: " + AllTrim( SXD->XD_TIPO ) + " Função: " + AllTrim( SXD->XD_FUNCAO ))
//		EndIf

		// Verifica duplicidade no dicionário SXD
		If cChaveAnt == SXD->XD_TIPO + SXD->XD_FUNCAO + SXD->XD_PERGUNT + SXD->XD_DEVICE
			aAdd( aDivergencia, { 'SXD', SXD->XD_TIPO + SXD->XD_FUNCAO + SXD->XD_PERGUNT + SXD->XD_DEVICE, SXD->( Recno() ), 'Controle de Schedule de Processos duplicado'})
			nSXD++
			If lCorrige
				RecLock("SXD", .F.)
					SXD->( dbDelete() )
				SXD->( MsUnLock() )
			EndIf
		Else
			cChaveAnt := SXD->XD_TIPO + SXD->XD_FUNCAO + SXD->XD_PERGUNT + SXD->XD_DEVICE
		EndIf
	
		SXD->( DbSkip() )
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa dicionário SXG                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If !lSchedule
	oProcess:IncRegua1( "Processando SXG - Tamanho Padrão" )
	Sleep( 10 )
//EndIf

If lSXG
	dbSelectArea("SXG")
	SXG->(DbSetOrder(1))
	SXG->(DbGotop())
	
//	If !lSchedule
		oProcess:SetRegua2( SXG->( RecCount() ) )
//	EndIf

	cChaveAnt := ""
	SXG->(DbGotop())
	
	Do While !SXG->( Eof() )
//		If !lSchedule
			oProcess:IncRegua2("Grupo: " + AllTrim( SXG->XG_GRUPO ))
//		EndIf

		// Verifica duplicidade no dicionário SXG
		If cChaveAnt == SXG->XG_GRUPO
			aAdd( aDivergencia, { 'SXG', SXG->XG_GRUPO, SXG->( Recno() ), 'Tamanho Padrão para Campos duplicado'})
			nSXG++
			If lCorrige
				RecLock("SXG", .F.)
					SXG->( dbDelete() )
				SXG->( MsUnLock() )
			EndIf
		Else
			cChaveAnt := SXG->XG_GRUPO
		EndIf
	
		SXG->( DbSkip() )
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa dicionário SIX                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If !lSchedule
	oProcess:IncRegua1( "Processando SIX - Índices" )
	Sleep( 10 )
//EndIf

If lSIX
	dbSelectArea("SIX")
	SIX->(DbSetOrder(1))
	SIX->(DbGotop())
	
//	If !lSchedule
		oProcess:SetRegua2( SIX->( RecCount() ) )
//	EndIf

	cChaveAnt := ""
	SIX->(DbGotop())
	
	Do While !SIX->( Eof() )
//		If !lSchedule
			oProcess:IncRegua2("Índice: " + AllTrim( SIX->INDICE ) + " Ordem: " + AllTrim( SIX->ORDEM ))
//		EndIf

		// Verifica duplicidade no dicionário SIX
		If cChaveAnt == SIX->INDICE + SIX->ORDEM
			aAdd( aDivergencia, { 'SIX', SIX->INDICE + SIX->ORDEM, SIX->( Recno() ), 'Índice duplicado'})
			nSIX++
			If lCorrige
				cAlias := SIX->INDICE
				RecLock("SIX", .F.)
					SIX->( dbDelete() )
				SIX->( MsUnLock() )
				X31UPDTABLE( cAlias )
			EndIf
		Else
			cChaveAnt := SIX->INDICE + SIX->ORDEM
		EndIf
	
		If Len( aIndices ) > 0
			nIndice := aScan( aIndices, {|y| AllTrim( SIX->CHAVE ) == AllTrim(y[3]) } )
			If nIndice > 0
				aAdd( aDivergencia, { 'SIX', SIX->INDICE + SIX->ORDEM, SIX->( Recno() ), 'Chave do índice igual ao índice: ' + aIndices[nIndice][1] + '-' + aIndices[nIndice][2]})
				nSIX++
			EndIf
		EndIf
	
		aAdd( aIndices, { SIX->INDICE, SIX->ORDEM, SIX->CHAVE } )
	
		If !SIX->( Deleted() )
			// Verifica se o índice possui arquivo
			dbSelectArea("SX2")
			dbSetOrder(1)
			If !SX2->( dbSeek( SIX->INDICE ) )
				aAdd( aDivergencia, { 'SIX', SIX->INDICE + SIX->ORDEM, SIX->( Recno() ), 'Índice criado sem arquivo no SX2: ' + SIX->INDICE })
				nSIX++
				If lCorrige
					cAlias := SIX->INDICE
					RecLock("SIX", .F.)
						SIX->( dbDelete() )
					SIX->( MsUnLock() )
					X31UPDTABLE( cAlias )
				EndIf
			EndIf
		EndIf
	
		If !SIX->( Deleted() )
			aCampos := SoCampo( AllTrim( Upper( SIX->CHAVE ) ) )
	
			For nCpo := 1 To Len( aCampos )
				// Verifica se campo do índice existe no dicionário...
				dbSelectArea("SX3")
				dbSetOrder(2)
				If !SX3->( dbSeek( AllTrim(aCampos[nCpo][1]) ) )
					aAdd( aDivergencia, { 'SIX', SIX->INDICE + SIX->ORDEM, SIX->( Recno() ), 'Campo: ' + AllTrim(aCampos[nCpo][1]) + ' não existente no dicionário de dados' })
					nSIX++
					If lCorrige
						cAlias := SIX->INDICE
						RecLock("SIX", .F.)
							SIX->( dbDelete() )
						SIX->( MsUnLock() )
						X31UPDTABLE( cAlias )
					EndIf
				EndIf
			Next
		EndIf

		If !SIX->( Deleted() )
			// Verifica se propriedade está vazia
			If Empty( SIX->PROPRI )
				aAdd( aDivergencia, { 'SIX', SIX->INDICE + SIX->ORDEM, SIX->( Recno() ), 'Índice ' + AllTrim(SIX->INDICE + SIX->ORDEM) + ' com propriedade vazia'})
				nSIX++
				If lCorrige
					RecLock("SIX", .F.)
						If Left(SIX->INDICE, 2) == "SZ" .Or. Left(SIX->INDICE, 1) == "Z"
							SIX->PROPRI := "S"
						Else
							SIX->PROPRI := "S"
						EndIf
					SIX->( MsUnLock() )
				EndIf
			EndIf
		EndIf

		If !SIX->( Deleted() )
			
		EndIf

		SIX->( DbSkip() )
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa dicionário CT0                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If !lSchedule
	oProcess:IncRegua1( "Processando CT0 - Conferência de Ent. Contábeis" )
	Sleep( 10 )
//EndIf

If lCT0
	cQuery := "SELECT CT0_FILIAL, CT0_ID, MAX(R_E_C_N_O_) AS CT0REC, " + CRLF
	cQuery += "'UPDATE " + RetSqlName("CT0") + " SET D_E_L_E_T_ = ''*'' WHERE CT0_FILIAL = ''' + CT0_FILIAL + ''' AND CT0_ID  = ''' + CT0_ID + ''' AND D_E_L_E_T_ = '''' AND R_E_C_N_O_ <> ' + CONVERT(VARCHAR(10), MIN(R_E_C_N_O_)) AS INSTRUCAO " + CRLF
	cQuery += "FROM " + RetSqlName("CT0") + " AS CT0 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE CT0_FILIAL <> '*' AND CT0.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY CT0_FILIAL, CT0_ID " + CRLF
	cQuery += "HAVING COUNT(*) > 1 " + CRLF
	cQuery += "ORDER BY CT0_FILIAL, CT0_ID " + CRLF
	
	TCQuery cQuery New Alias "TMPCT0"
	dbSelectArea("TMPCT0")
	TMPCT0->( dbGoTop() )
	
//	If !lSchedule
		oProcess:SetRegua2( TMPCT0->( RecCount() ) )
//	EndIf

	TMPCT0->( dbGoTop() )

	Do While !TMPCT0->( Eof() )
//		If !lSchedule
			oProcess:IncRegua2("Identificador: " + AllTrim( TMPCT0->CT0_ID ))
//		EndIf

		aAdd( aDivergencia, { 'CT0', TMPCT0->CT0_FILIAL + TMPCT0->CT0_ID, TMPCT0->CT0REC, 'Conferência de Entidades Contábeis duplicada'})
		nCT0++
	
		If lCorrige
			TCSQLExec( TMPCT0->INSTRUCAO )
		EndIf
	
		TMPCT0->( DbSkip() )
	EndDo
	
	TMPCT0->( dbCloseArea() )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa dicionário Usuários                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If !lSchedule
	oProcess:IncRegua1( "Processando USU - Usuários" )
	Sleep( 10 )
//EndIf

If lUSU
	aUsuarios := AllUsers()
	nUsuario  := 0
	
//	If !lSchedule
		oProcess:SetRegua2( Len( aUsuarios ) )
//	EndIf

	For nUsuario := 1 To Len( aUsuarios )
//		If !lSchedule
			oProcess:IncRegua2("Usuário: " + AllTrim( aUsuarios[nUsuario][1][2] ))
//		EndIf

		If !aUsuarios[nUsuario][1][17]
			If AllTrim( aUsuarios[nUsuario][1][1] ) <> '000000'
				If aUsuarios[nUsuario][1][15] > nMaxSim
					aAdd( aDivergencia, { 'USU', AllTrim( aUsuarios[nUsuario][1][2] ) + " - " + AllTrim( aUsuarios[nUsuario][1][4] ), aUsuarios[nUsuario][1][15], 'Usuário com mais de ' + AllTrim( Str( nMaxSim ) ) + ' acesso simutâneo Liberado'})
					nUSU++
				EndIf
				If aUsuarios[nUsuario][1][23][2] > nDiasRet .And. aUsuarios[nUsuario][1][23][2] <> 9999
					aAdd( aDivergencia, { 'USU', AllTrim( aUsuarios[nUsuario][1][2] ) + " - " + AllTrim( aUsuarios[nUsuario][1][4] ), aUsuarios[nUsuario][1][23][2], 'Usuário com dias a retroceder acima do limite de ' + AllTrim( Str( nDiasRet ) )})
					nUSU++
				EndIf
				If aUsuarios[nUsuario][1][23][3] > nDiasAva .And. aUsuarios[nUsuario][1][23][3] <> 9999
					aAdd( aDivergencia, { 'USU', AllTrim( aUsuarios[nUsuario][1][2] ) + " - " + AllTrim( aUsuarios[nUsuario][1][4] ), aUsuarios[nUsuario][1][23][3], 'Usuário com dias a avançar acima do limite de ' + AllTrim( Str( nDiasAva ) )})
					nUSU++
				EndIf
			EndIf
		Else
			// Exceções...
			If !(AllTrim( Upper( aUsuarios[nUsuario][1][2] ) ) $ AllTrim( cExcecoes) )
				dbSelectArea("SX6")
				SX6->(DbSetOrder(1))
				SX6->(DbGotop())
	
				// Se usuário bloqueado, verificar se há parâmetro definido com o usuário ou e-mail
				Do While !SX6->( Eof() )
					If AllTrim( Upper( aUsuarios[nUsuario][1][2] ) ) $ AllTrim( Upper( SX6->X6_CONTEUD ) )
						aAdd( aDivergencia, { 'USU', AllTrim( aUsuarios[nUsuario][1][2] ) + " - " + AllTrim( aUsuarios[nUsuario][1][4] ), 0, 'Usuário bloqueado está definido no conteúdo do parâmetro: ' + SX6->X6_VAR })
						nUSU++
					Else
						If !Empty( aUsuarios[nUsuario][1][14] )
							If AllTrim( Upper( aUsuarios[nUsuario][1][14] ) ) $ AllTrim( Upper( SX6->X6_CONTEUD ) )
								aAdd( aDivergencia, { 'USU', AllTrim( aUsuarios[nUsuario][1][2] ) + " - " + AllTrim( aUsuarios[nUsuario][1][4] ), 0, 'E-mail do Usuário bloqueado está definido no conteúdo do parâmetro: ' + SX6->X6_VAR })
								nUSU++
							EndIf
						EndIf
					EndIf
	
					SX6->( dbSkip() )
				EndDo
			EndIf
		EndIf
	Next
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualizar GRUPOS...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If !lSchedule
	oProcess:IncRegua1( "Processando GRU - Grupo de Usuários" )
	Sleep( 10 )
//EndIf

If lGRU
	aGrupos := FWSFAllGrps()
	nGrupo  := 0

//	If !lSchedule
		oProcess:SetRegua2( Len( aGrupos ) )
//	EndIf

	For nGrupo := 1 To Len( aGrupos )
//		If !lSchedule
			oProcess:IncRegua2("Grupo: " + AllTrim( aGrupos[nGrupo][2] ))
//		EndIf

		aGruPar := FWGrpParam(aGrupos[nGrupo][2])
	
		If IIf(Empty(aGruPar[2][2]), 0, Val( aGruPar[2][2] )) > nDiasRet .And. IIf(Empty(aGruPar[2][2]), 0, Val( aGruPar[2][2] )) <> 9999
			aAdd( aDivergencia, { 'GRU', AllTrim( aGrupos[nGrupo][2] ) + " - " + AllTrim( aGrupos[nGrupo][2] ), IIf(Empty(aGruPar[2][2]), 0, Val( aGruPar[2][2] )), 'Usuário com dias a retroceder acima do limite de ' + AllTrim( Str( nDiasRet ) )})
			nGRU++
		EndIf
		If IIf(Empty(aGruPar[2][3]), 0, Val( aGruPar[2][3] )) > nDiasAva .And. IIf(Empty(aGruPar[2][3]), 0, Val( aGruPar[2][3] )) <> 9999
			aAdd( aDivergencia, { 'GRU', AllTrim( aGrupos[nGrupo][2] ) + " - " + AllTrim( aGrupos[nGrupo][2] ), IIf(Empty(aGruPar[2][3]), 0, Val( aGruPar[2][3] )), 'Usuário com dias a avançar acima do limite de ' + AllTrim( Str( nDiasAva ) )})
			nGRU++
		EndIf
	Next
EndIf

//If !lSchedule
	// Apresenta resultado das divergências...
	DEFINE MSDIALOG oDlgDiv TITLE "EQAnaDic - Report Dicionário de Dados - Empresa: " + AllTrim(SM0->M0_NOME) + " / " + AllTrim(SM0->M0_FILIAL) FROM 000, 000  TO 506, 785 PIXEL
	
	    @ 0, 0 MSPANEL oTbxPg01 SIZE 0, 0 OF oDlgDiv COLORS 0, 14215660
	    @ 0, 0 MSPANEL oTbxPg02 SIZE 0, 0 OF oDlgDiv COLORS 0, 14215660
	
	    @ C(000),C(000) TOOLBOX oToolBox SIZE C(309),C(174) OF oDlgDiv
	
	    oToolBox:AddGroup(oTbxPg01, "Informações gerais das divergências", )
	    oToolBox:AddGroup(oTbxPg02, "Detalhes das divergências por dicionário de dados", )
	
		oGroup:= TGroup():New(C(003),C(005),C(145),C(303), 'Quantidade de divergências encontradas', oTbxPg01,,,.T.)
	
		oSayResSX1 := TSay():New(C(015),C(012),{||'SX1 - Perguntas...........................: ' + Transform( nSX1, "@R 999,999")},oTbxPg01,,oFontRes1,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
		oSayResSX2 := TSay():New(C(025),C(012),{||'SX2 - Arquivos............................: ' + Transform( nSX2, "@R 999,999")},oTbxPg01,,oFontRes1,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
		oSayResSX3 := TSay():New(C(035),C(012),{||'SX3 - Campos..............................: ' + Transform( nSX3, "@R 999,999")},oTbxPg01,,oFontRes1,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
		oSayResSX5 := TSay():New(C(045),C(012),{||'SX5 - Tabelas.............................: ' + Transform( nSX5, "@R 999,999")},oTbxPg01,,oFontRes1,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
		oSayResSX6 := TSay():New(C(055),C(012),{||'SX6 - Parâmetros..........................: ' + Transform( nSX6, "@R 999,999")},oTbxPg01,,oFontRes1,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
		oSayResSX7 := TSay():New(C(065),C(012),{||'SX7 - Gatilhos............................: ' + Transform( nSX7, "@R 999,999")},oTbxPg01,,oFontRes1,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
		oSayResSX9 := TSay():New(C(075),C(012),{||'SX9 - Relacionamentos entre Arquivos......: ' + Transform( nSX9, "@R 999,999")},oTbxPg01,,oFontRes1,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
		oSayResSXA := TSay():New(C(085),C(012),{||'SXA - Pastas..............................: ' + Transform( nSXA, "@R 999,999")},oTbxPg01,,oFontRes1,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
		oSayResSXB := TSay():New(C(095),C(012),{||'SXB - Consulta Padrão.....................: ' + Transform( nSXB, "@R 999,999")},oTbxPg01,,oFontRes1,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
		oSayResSXD := TSay():New(C(105),C(012),{||'SXD - Processo Schedule...................: ' + Transform( nSXD, "@R 999,999")},oTbxPg01,,oFontRes1,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
		oSayResSXG := TSay():New(C(115),C(012),{||'SXG - Tamanho Padrao......................: ' + Transform( nSXG, "@R 999,999")},oTbxPg01,,oFontRes1,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
		oSayResSIX := TSay():New(C(125),C(012),{||'SIX - Índices.............................: ' + Transform( nSIX, "@R 999,999")},oTbxPg01,,oFontRes1,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
		oSayResCT0 := TSay():New(C(015),C(159),{||'CT0 - Conferência de Entidades Contábeis..: ' + Transform( nCT0, "@R 999,999")},oTbxPg01,,oFontRes1,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
		oSayResUSU := TSay():New(C(025),C(159),{||'USU - Usuários............................: ' + Transform( nUSU, "@R 999,999")},oTbxPg01,,oFontRes1,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
		oSayResGRU := TSay():New(C(035),C(159),{||'GRU - Grupo de Usuários...................: ' + Transform( nGRU, "@R 999,999")},oTbxPg01,,oFontRes1,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
	
		oSayResTOT := TSay():New(C(135),C(012),{||'Total Geral.....................................................: ' + Transform( nSX1 + nSX2 + nSX3 + nSX5 + nSX6 + nSX7 + nSX9 + nSXA + nSXB + nSXD + nSXG + nSIX + nCT0 + nUSU + nGRU, "@R 999,999")},oTbxPg01,,oFontRes2,,,,.T.,CLR_RED,CLR_WHITE,500,20)
	
		aTFolder := {'Perguntas','Arquivos','Campos','Tabelas','Parâmetros','Gatilhos','Relac. Arquivos','Pastas','Consulta Padrão','Processo Schedule','Tamanho Padrao','Índices','Conf. Ent. Contábeis','Usuários','Grupo de Usuários'}
		oTFolder := TFolder():New( 0,0,aTFolder,,oTbxPg02,,,,.T.,,C(309),C(150))
	
		For nDiv := 1 To Len(aDivergencia)
			Do Case
				Case AllTrim(aDivergencia[nDiv][1]) == "SX1"
					aAdd( aSX1, {AllTrim(aDivergencia[nDiv][1]), AllTrim(aDivergencia[nDiv][2]), aDivergencia[nDiv][3], AllTrim(aDivergencia[nDiv][4])})
				Case AllTrim(aDivergencia[nDiv][1]) == "SX2"
					aAdd( aSX2, {AllTrim(aDivergencia[nDiv][1]), AllTrim(aDivergencia[nDiv][2]), aDivergencia[nDiv][3], AllTrim(aDivergencia[nDiv][4])})
				Case AllTrim(aDivergencia[nDiv][1]) == "SX3"
					aAdd( aSX3, {AllTrim(aDivergencia[nDiv][1]), AllTrim(aDivergencia[nDiv][2]), aDivergencia[nDiv][3], AllTrim(aDivergencia[nDiv][4])})
				Case AllTrim(aDivergencia[nDiv][1]) == "SX5"
					aAdd( aSX5, {AllTrim(aDivergencia[nDiv][1]), AllTrim(aDivergencia[nDiv][2]), aDivergencia[nDiv][3], AllTrim(aDivergencia[nDiv][4])})
				Case AllTrim(aDivergencia[nDiv][1]) == "SX6"
					aAdd( aSX6, {AllTrim(aDivergencia[nDiv][1]), AllTrim(aDivergencia[nDiv][2]), aDivergencia[nDiv][3], AllTrim(aDivergencia[nDiv][4])})
				Case AllTrim(aDivergencia[nDiv][1]) == "SX7"
					aAdd( aSX7, {AllTrim(aDivergencia[nDiv][1]), AllTrim(aDivergencia[nDiv][2]), aDivergencia[nDiv][3], AllTrim(aDivergencia[nDiv][4])})
				Case AllTrim(aDivergencia[nDiv][1]) == "SX9"
					aAdd( aSX9, {AllTrim(aDivergencia[nDiv][1]), AllTrim(aDivergencia[nDiv][2]), aDivergencia[nDiv][3], AllTrim(aDivergencia[nDiv][4])})
				Case AllTrim(aDivergencia[nDiv][1]) == "SXA"
					aAdd( aSXA, {AllTrim(aDivergencia[nDiv][1]), AllTrim(aDivergencia[nDiv][2]), aDivergencia[nDiv][3], AllTrim(aDivergencia[nDiv][4])})
				Case AllTrim(aDivergencia[nDiv][1]) == "SXB"
					aAdd( aSXB, {AllTrim(aDivergencia[nDiv][1]), AllTrim(aDivergencia[nDiv][2]), aDivergencia[nDiv][3], AllTrim(aDivergencia[nDiv][4])})
				Case AllTrim(aDivergencia[nDiv][1]) == "SXD"
					aAdd( aSXD, {AllTrim(aDivergencia[nDiv][1]), AllTrim(aDivergencia[nDiv][2]), aDivergencia[nDiv][3], AllTrim(aDivergencia[nDiv][4])})
				Case AllTrim(aDivergencia[nDiv][1]) == "SXG"
					aAdd( aSXG, {AllTrim(aDivergencia[nDiv][1]), AllTrim(aDivergencia[nDiv][2]), aDivergencia[nDiv][3], AllTrim(aDivergencia[nDiv][4])})
				Case AllTrim(aDivergencia[nDiv][1]) == "SIX"
					aAdd( aSIX, {AllTrim(aDivergencia[nDiv][1]), AllTrim(aDivergencia[nDiv][2]), aDivergencia[nDiv][3], AllTrim(aDivergencia[nDiv][4])})
				Case AllTrim(aDivergencia[nDiv][1]) == "CT0"
					aAdd( aCT0, {AllTrim(aDivergencia[nDiv][1]), AllTrim(aDivergencia[nDiv][2]), aDivergencia[nDiv][3], AllTrim(aDivergencia[nDiv][4])})
				Case AllTrim(aDivergencia[nDiv][1]) == "USU"
					aAdd( aUSU, {AllTrim(aDivergencia[nDiv][1]), AllTrim(aDivergencia[nDiv][2]), aDivergencia[nDiv][3], AllTrim(aDivergencia[nDiv][4])})
				Case AllTrim(aDivergencia[nDiv][1]) == "GRU"
					aAdd( aGRU, {AllTrim(aDivergencia[nDiv][1]), AllTrim(aDivergencia[nDiv][2]), aDivergencia[nDiv][3], AllTrim(aDivergencia[nDiv][4])})
			EndCase
		Next
	
		If Len( aSX1 ) == 0
			aAdd( aSX1, {"", "", 0, ""})
		EndIf
		If Len( aSX2 ) == 0
			aAdd( aSX2, {"", "", 0, ""})
		EndIf
		If Len( aSX3 ) == 0
			aAdd( aSX3, {"", "", 0, ""})
		EndIf
		If Len( aSX5 ) == 0
			aAdd( aSX5, {"", "", 0, ""})
		EndIf
		If Len( aSX6 ) == 0
			aAdd( aSX6, {"", "", 0, ""})
		EndIf
		If Len( aSX7 ) == 0
			aAdd( aSX7, {"", "", 0, ""})
		EndIf
		If Len( aSX9 ) == 0
			aAdd( aSX9, {"", "", 0, ""})
		EndIf
		If Len( aSXA ) == 0
			aAdd( aSXA, {"", "", 0, ""})
		EndIf
		If Len( aSXB ) == 0
			aAdd( aSXB, {"", "", 0, ""})
		EndIf
		If Len( aSXD ) == 0
			aAdd( aSXD, {"", "", 0, ""})
		EndIf
		If Len( aSXG ) == 0
			aAdd( aSXG, {"", "", 0, ""})
		EndIf
		If Len( aSIX ) == 0
			aAdd( aSIX, {"", "", 0, ""})
		EndIf
		If Len( aCT0 ) == 0
			aAdd( aCT0, {"", "", 0, ""})
		EndIf
		If Len( aUSU ) == 0
			aAdd( aUSU, {"", "", 0, ""})
		EndIf
		If Len( aGRU ) == 0
			aAdd( aGRU, {"", "", 0, ""})
		EndIf
	
		TBitmap():New(003,003,30,30, 'S4WB016N',,.T.,oTFolder:aDialogs[1],,,,,,,,,.T. )
		oSayResSX1 := TSay():New(C(003),C(016),{||'Divergências em SX1 - Grupo de Perguntas'},oTFolder:aDialogs[1],,oFontRes3,,,,.T.,CLR_HRED,CLR_WHITE,600,20)
		oGroup:= TGroup():New(C(015),C(003),C(136),C(305), 'Report de Divergências', oTFolder:aDialogs[1],,,.T.)
	
		oLbxSX1 := TcBrowse():New(C(022),C(006),C(296),C(113),,,,oTFolder:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)
		oLbxSX1:AddColumn( TcColumn():New("Chave"      ,{ || aSX1[oLbxSX1:nAt,02] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSX1:AddColumn( TcColumn():New("Recno"      ,{ || aSX1[oLbxSX1:nAt,03] }   ,"@E 9,999,999"                              ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )
		oLbxSX1:AddColumn( TcColumn():New("Descrição"  ,{ || aSX1[oLbxSX1:nAt,04] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSX1:SetArray( aSX1 )
	
		TBitmap():New(003,003,30,30, 'S4WB009N',,.T.,oTFolder:aDialogs[2],,,,,,,,,.T. )
		oSayResSX2 := TSay():New(C(003),C(016),{||'Divergências em SX2 - Arquivos'},oTFolder:aDialogs[2],,oFontRes3,,,,.T.,CLR_HRED,CLR_WHITE,600,20)
		oGroup:= TGroup():New(C(015),C(003),C(136),C(305), 'Report de Divergências', oTFolder:aDialogs[2],,,.T.)
	
		oLbxSX2 := TcBrowse():New(C(022),C(006),C(296),C(113),,,,oTFolder:aDialogs[2],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)
		oLbxSX2:AddColumn( TcColumn():New("Chave"      ,{ || aSX2[oLbxSX2:nAt,02] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSX2:AddColumn( TcColumn():New("Recno"      ,{ || aSX2[oLbxSX2:nAt,03] }   ,"@E 9,999,999"                              ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )
		oLbxSX2:AddColumn( TcColumn():New("Descrição"  ,{ || aSX2[oLbxSX2:nAt,04] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSX2:SetArray( aSX2 )
	
		TBitmap():New(003,003,30,30, 'BMPTRG',,.T.,oTFolder:aDialogs[3],,,,,,,,,.T. )
		oSayResSX3 := TSay():New(C(003),C(016),{||'Divergências em SX3 - Campos'},oTFolder:aDialogs[3],,oFontRes3,,,,.T.,CLR_HRED,CLR_WHITE,600,20)
		oGroup:= TGroup():New(C(015),C(003),C(136),C(305), 'Report de Divergências', oTFolder:aDialogs[3],,,.T.)
	
		oLbxSX3 := TcBrowse():New(C(022),C(006),C(296),C(113),,,,oTFolder:aDialogs[3],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)
		oLbxSX3:AddColumn( TcColumn():New("Chave"      ,{ || aSX3[oLbxSX3:nAt,02] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSX3:AddColumn( TcColumn():New("Recno"      ,{ || aSX3[oLbxSX3:nAt,03] }   ,"@E 9,999,999"                              ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )
		oLbxSX3:AddColumn( TcColumn():New("Descrição"  ,{ || aSX3[oLbxSX3:nAt,04] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSX3:SetArray( aSX3 )
	
		TBitmap():New(003,003,30,30, 'NOTE',,.T.,oTFolder:aDialogs[4],,,,,,,,,.T. )
		oSayResSX5 := TSay():New(C(003),C(016),{||'Divergências em SX5 - Tabelas'},oTFolder:aDialogs[4],,oFontRes3,,,,.T.,CLR_HRED,CLR_WHITE,600,20)
		oGroup:= TGroup():New(C(015),C(003),C(136),C(305), 'Report de Divergências', oTFolder:aDialogs[4],,,.T.)
	
		oLbxSX5 := TcBrowse():New(C(022),C(006),C(296),C(113),,,,oTFolder:aDialogs[4],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)
		oLbxSX5:AddColumn( TcColumn():New("Chave"      ,{ || aSX5[oLbxSX5:nAt,02] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSX5:AddColumn( TcColumn():New("Recno"      ,{ || aSX5[oLbxSX5:nAt,03] }   ,"@E 9,999,999"                              ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )
		oLbxSX5:AddColumn( TcColumn():New("Descrição"  ,{ || aSX5[oLbxSX5:nAt,04] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSX5:SetArray( aSX5 )
	
		TBitmap():New(003,003,30,30, 'LIQCHECK',,.T.,oTFolder:aDialogs[5],,,,,,,,,.T. )
		oSayResSX6 := TSay():New(C(003),C(016),{||'Divergências em SX6 - Parâmetros'},oTFolder:aDialogs[5],,oFontRes3,,,,.T.,CLR_HRED,CLR_WHITE,600,20)
		oGroup:= TGroup():New(C(015),C(003),C(136),C(305), 'Report de Divergências', oTFolder:aDialogs[5],,,.T.)
	
		oLbxSX6 := TcBrowse():New(C(022),C(006),C(296),C(113),,,,oTFolder:aDialogs[5],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)
		oLbxSX6:AddColumn( TcColumn():New("Chave"      ,{ || aSX6[oLbxSX6:nAt,02] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSX6:AddColumn( TcColumn():New("Recno"      ,{ || aSX6[oLbxSX6:nAt,03] }   ,"@E 9,999,999"                              ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )
		oLbxSX6:AddColumn( TcColumn():New("Descrição"  ,{ || aSX6[oLbxSX6:nAt,04] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSX6:SetArray( aSX6 )
	
		TBitmap():New(003,003,30,30, 'SDUPROP',,.T.,oTFolder:aDialogs[6],,,,,,,,,.T. )
		oSayResSX7 := TSay():New(C(003),C(016),{||'Divergências em SX7 - Gatilhos'},oTFolder:aDialogs[6],,oFontRes3,,,,.T.,CLR_HRED,CLR_WHITE,600,20)
		oGroup:= TGroup():New(C(015),C(003),C(136),C(305), 'Report de Divergências', oTFolder:aDialogs[6],,,.T.)
	
		oLbxSX7 := TcBrowse():New(C(022),C(006),C(296),C(113),,,,oTFolder:aDialogs[6],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)
		oLbxSX7:AddColumn( TcColumn():New("Chave"      ,{ || aSX7[oLbxSX7:nAt,02] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSX7:AddColumn( TcColumn():New("Recno"      ,{ || aSX7[oLbxSX7:nAt,03] }   ,"@E 9,999,999"                              ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )
		oLbxSX7:AddColumn( TcColumn():New("Descrição"  ,{ || aSX7[oLbxSX7:nAt,04] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSX7:SetArray( aSX7 )
	
		TBitmap():New(003,003,30,30, 'GLOBO',,.T.,oTFolder:aDialogs[7],,,,,,,,,.T. )
		oSayResSX9 := TSay():New(C(003),C(016),{||'Divergências em SX9 - Relacionamentos entre Arquivos'},oTFolder:aDialogs[7],,oFontRes3,,,,.T.,CLR_HRED,CLR_WHITE,600,20)
		oGroup:= TGroup():New(C(015),C(003),C(136),C(305), 'Report de Divergências', oTFolder:aDialogs[7],,,.T.)
	
		oLbxSX9 := TcBrowse():New(C(022),C(006),C(296),C(113),,,,oTFolder:aDialogs[7],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)
		oLbxSX9:AddColumn( TcColumn():New("Chave"      ,{ || aSX9[oLbxSX9:nAt,02] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSX9:AddColumn( TcColumn():New("Recno"      ,{ || aSX9[oLbxSX9:nAt,03] }   ,"@E 9,999,999"                              ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )
		oLbxSX9:AddColumn( TcColumn():New("Descrição"  ,{ || aSX9[oLbxSX9:nAt,04] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSX9:SetArray( aSX9 )
	
		TBitmap():New(003,003,30,30, 'FOLDER6',,.T.,oTFolder:aDialogs[8],,,,,,,,,.T. )
		oSayResSXA := TSay():New(C(003),C(016),{||'Divergências em SXA - Pastas'},oTFolder:aDialogs[8],,oFontRes3,,,,.T.,CLR_HRED,CLR_WHITE,600,20)
		oGroup:= TGroup():New(C(015),C(003),C(136),C(305), 'Report de Divergências', oTFolder:aDialogs[8],,,.T.)
	
		oLbxSXA := TcBrowse():New(C(022),C(006),C(296),C(113),,,,oTFolder:aDialogs[8],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)
		oLbxSXA:AddColumn( TcColumn():New("Chave"      ,{ || aSXA[oLbxSXA:nAt,02] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSXA:AddColumn( TcColumn():New("Recno"      ,{ || aSXA[oLbxSXA:nAt,03] }   ,"@E 9,999,999"                              ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )
		oLbxSXA:AddColumn( TcColumn():New("Descrição"  ,{ || aSXA[oLbxSXA:nAt,04] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSXA:SetArray( aSXA )
	
		TBitmap():New(003,003,30,30, 'S4WB011N',,.T.,oTFolder:aDialogs[9],,,,,,,,,.T. )
		oSayResSXB := TSay():New(C(003),C(016),{||'Divergências em SXB - Consulta Padrão'},oTFolder:aDialogs[9],,oFontRes3,,,,.T.,CLR_HRED,CLR_WHITE,600,20)
		oGroup:= TGroup():New(C(015),C(003),C(136),C(305), 'Report de Divergências', oTFolder:aDialogs[9],,,.T.)
	
		oLbxSXB := TcBrowse():New(C(022),C(006),C(296),C(113),,,,oTFolder:aDialogs[9],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)
		oLbxSXB:AddColumn( TcColumn():New("Chave"      ,{ || aSXB[oLbxSXB:nAt,02] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSXB:AddColumn( TcColumn():New("Recno"      ,{ || aSXB[oLbxSXB:nAt,03] }   ,"@E 9,999,999"                              ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )
		oLbxSXB:AddColumn( TcColumn():New("Descrição"  ,{ || aSXB[oLbxSXB:nAt,04] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSXB:SetArray( aSXB )
	
		TBitmap():New(003,003,30,30, 'RELOAD',,.T.,oTFolder:aDialogs[10],,,,,,,,,.T. )
		oSayResSXD := TSay():New(C(003),C(016),{||'Divergências em SXD - Processos Schedule'},oTFolder:aDialogs[10],,oFontRes3,,,,.T.,CLR_HRED,CLR_WHITE,600,20)
		oGroup:= TGroup():New(C(015),C(003),C(136),C(305), 'Report de Divergências', oTFolder:aDialogs[10],,,.T.)
	
		oLbxSXD := TcBrowse():New(C(022),C(006),C(296),C(113),,,,oTFolder:aDialogs[10],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)
		oLbxSXD:AddColumn( TcColumn():New("Chave"      ,{ || aSXD[oLbxSXD:nAt,02] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSXD:AddColumn( TcColumn():New("Recno"      ,{ || aSXD[oLbxSXD:nAt,03] }   ,"@E 9,999,999"                              ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )
		oLbxSXD:AddColumn( TcColumn():New("Descrição"  ,{ || aSXD[oLbxSXD:nAt,04] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSXD:SetArray( aSXD )
	
		TBitmap():New(003,003,30,30, 'CONTAINR',,.T.,oTFolder:aDialogs[11],,,,,,,,,.T. )
		oSayResSXG := TSay():New(C(003),C(016),{||'Divergências em SXG - Tamanho Padrão'},oTFolder:aDialogs[11],,oFontRes3,,,,.T.,CLR_HRED,CLR_WHITE,600,20)
		oGroup:= TGroup():New(C(015),C(003),C(136),C(305), 'Report de Divergências', oTFolder:aDialogs[11],,,.T.)
	
		oLbxSXG := TcBrowse():New(C(022),C(006),C(296),C(113),,,,oTFolder:aDialogs[11],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)
		oLbxSXG:AddColumn( TcColumn():New("Chave"      ,{ || aSXG[oLbxSXG:nAt,02] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSXG:AddColumn( TcColumn():New("Recno"      ,{ || aSXG[oLbxSXG:nAt,03] }   ,"@E 9,999,999"                              ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )
		oLbxSXG:AddColumn( TcColumn():New("Descrição"  ,{ || aSXG[oLbxSXG:nAt,04] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSXG:SetArray( aSXG )
	
		TBitmap():New(003,003,30,30, 'CARGA',,.T.,oTFolder:aDialogs[12],,,,,,,,,.T. )
		oSayResSIX := TSay():New(C(003),C(016),{||'Divergências em SIX - Índices'},oTFolder:aDialogs[12],,oFontRes3,,,,.T.,CLR_HRED,CLR_WHITE,600,20)
		oGroup:= TGroup():New(C(015),C(003),C(136),C(305), 'Report de Divergências', oTFolder:aDialogs[12],,,.T.)
	
		oLbxSIX := TcBrowse():New(C(022),C(006),C(296),C(113),,,,oTFolder:aDialogs[12],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)
		oLbxSIX:AddColumn( TcColumn():New("Chave"      ,{ || aSIX[oLbxSIX:nAt,02] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSIX:AddColumn( TcColumn():New("Recno"      ,{ || aSIX[oLbxSIX:nAt,03] }   ,"@E 9,999,999"                              ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )
		oLbxSIX:AddColumn( TcColumn():New("Descrição"  ,{ || aSIX[oLbxSIX:nAt,04] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxSIX:SetArray( aSIX )
	
		TBitmap():New(003,003,30,30, 'S4WB008N',,.T.,oTFolder:aDialogs[13],,,,,,,,,.T. )
		oSayResCT0 := TSay():New(C(003),C(016),{||'Divergências em CT0 - Conferências de Entidades Contábeis'},oTFolder:aDialogs[13],,oFontRes3,,,,.T.,CLR_HRED,CLR_WHITE,600,20)
		oGroup:= TGroup():New(C(015),C(003),C(136),C(305), 'Report de Divergências', oTFolder:aDialogs[13],,,.T.)
	
		oLbxCT0 := TcBrowse():New(C(022),C(006),C(296),C(113),,,,oTFolder:aDialogs[13],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)
		oLbxCT0:AddColumn( TcColumn():New("Chave"      ,{ || aCT0[oLbxCT0:nAt,02] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxCT0:AddColumn( TcColumn():New("Recno"      ,{ || aCT0[oLbxCT0:nAt,03] }   ,"@E 9,999,999"                              ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )
		oLbxCT0:AddColumn( TcColumn():New("Descrição"  ,{ || aCT0[oLbxCT0:nAt,04] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxCT0:SetArray( aCT0 )
	
		TBitmap():New(003,003,30,30, 'BMPUSER',,.T.,oTFolder:aDialogs[14],,,,,,,,,.T. )
		oSayResUSU := TSay():New(C(003),C(016),{||'Divergências em USU - Usuários'},oTFolder:aDialogs[14],,oFontRes3,,,,.T.,CLR_HRED,CLR_WHITE,600,20)
		oGroup:= TGroup():New(C(015),C(003),C(136),C(305), 'Report de Divergências', oTFolder:aDialogs[14],,,.T.)
	
		oLbxUSU := TcBrowse():New(C(022),C(006),C(296),C(113),,,,oTFolder:aDialogs[14],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)
		oLbxUSU:AddColumn( TcColumn():New("Chave"      ,{ || aUSU[oLbxUSU:nAt,02] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxUSU:AddColumn( TcColumn():New("Recno"      ,{ || aUSU[oLbxUSU:nAt,03] }   ,"@E 9,999,999"                              ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )
		oLbxUSU:AddColumn( TcColumn():New("Descrição"  ,{ || aUSU[oLbxUSU:nAt,04] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxUSU:SetArray( aUSU )
	
		TBitmap():New(003,003,30,30, 'BMPGROUP',,.T.,oTFolder:aDialogs[15],,,,,,,,,.T. )
		oSayResGRU := TSay():New(C(003),C(016),{||'Divergências em GRU - Grupos de Usuários'},oTFolder:aDialogs[15],,oFontRes3,,,,.T.,CLR_HRED,CLR_WHITE,600,20)
		oGroup:= TGroup():New(C(015),C(003),C(136),C(305), 'Report de Divergências', oTFolder:aDialogs[15],,,.T.)
	
		oLbxGRU := TcBrowse():New(C(022),C(006),C(296),C(113),,,,oTFolder:aDialogs[15],,,,,,,,,,,,.F.,,.T.,,.F.,,,,)
		oLbxGRU:AddColumn( TcColumn():New("Chave"      ,{ || aGRU[oLbxGRU:nAt,02] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxGRU:AddColumn( TcColumn():New("Recno"      ,{ || aGRU[oLbxGRU:nAt,03] }   ,"@E 9,999,999"                              ,,,"RIGHT" ,,.F.,.F.,,,,.F.,) )
		oLbxGRU:AddColumn( TcColumn():New("Descrição"  ,{ || aGRU[oLbxGRU:nAt,04] }   ,"@!"                                        ,,,"LEFT"  ,,.F.,.F.,,,,.F.,) )
		oLbxGRU:SetArray( aGRU )
	
		@ C(176),C(271) Button "Confirmar" Size C(037),C(010) Action (oDlgDiv:End()) PIXEL OF oDlgDiv
	
		oTMsgBar   := TMsgBar():New(oDlgDiv, "", .F.,.F.,.F.,.F., CLR_BLACK,,oFontMsg,.F.)
		oTMsgItem1 := TMsgItem():New( oTMsgBar,'Euroamerican', 160,,CLR_BLACK,,.T., {||} )
		oTMsgItem2 := TMsgItem():New( oTMsgBar,AllTrim(SM0->M0_NOME) + " / " + AllTrim(SM0->M0_FILIAL), 550,,CLR_BLACK,,.T., {||} )
	
	ACTIVATE MSDIALOG oDlgDiv CENTERED
//EndIf

If lEmail
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somente enviar e-mail de notificação se houver divergências no dicionário...         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nSX1 + nSX2 + nSX3 + nSX5 + nSX6 + nSX7 + nSX9 + nSXA + nSXB + nSXD + nSXG + nSIX + nCT0 + nUSU + nGRU) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Estrutura HTML da mensagem...                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMensagem := ''
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define dados de cabelho...                                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCabec := {}
		aAdd( aCabec, {{'<B><Font Size=4 color=white>Divergências em dicionário de dados: ' + DTOC(MSDATE()) + '</Font></B>', '6', 100, 6, 'C'}})
		aAdd( aCabec, {{'<B><Font Size=2 color=black>Usuário</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim(CUSERNAME)  + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Empresa</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + cEmpAnt + ' / ' + AllTrim(SM0->M0_NOME) + '</Font>', '1', 40, 2, 'L'}})
		aAdd( aCabec, {{'<B><Font Size=2 color=black>Observação</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=green>Envolver responsável por Atualização de Versão ou Customização imediatamente, se possível, abrir chamado na Totvs</Font>', '1', 90, 5, 'L'}})
		aAdd( aCabec, {{'<B><Font Size=4 color=yellow>Divergências</Font></B>', '6', 100, 6, 'C'}})
		aAdd( aCabec, {{'<B><Font Size=2 color=black>SX1</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=red>' + Transform( nSX1, "@E 999,999,999")  + '</Font>', '1', 40, 2, 'R'},{'<B><Font Size=2 color=black>SX2</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=red>' + Transform( nSX2, "@E 999,999,999") + '</Font>', '1', 40, 2, 'R'}})
		aAdd( aCabec, {{'<B><Font Size=2 color=black>SX3</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=red>' + Transform( nSX3, "@E 999,999,999")  + '</Font>', '1', 40, 2, 'R'},{'<B><Font Size=2 color=black>SX5</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=red>' + Transform( nSX5, "@E 999,999,999") + '</Font>', '1', 40, 2, 'R'}})
		aAdd( aCabec, {{'<B><Font Size=2 color=black>SX6</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=red>' + Transform( nSX6, "@E 999,999,999")  + '</Font>', '1', 40, 2, 'R'},{'<B><Font Size=2 color=black>SX7</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=red>' + Transform( nSX7, "@E 999,999,999") + '</Font>', '1', 40, 2, 'R'}})
		aAdd( aCabec, {{'<B><Font Size=2 color=black>SX9</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=red>' + Transform( nSX9, "@E 999,999,999")  + '</Font>', '1', 40, 2, 'R'},{'<B><Font Size=2 color=black>SXA</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=red>' + Transform( nSXA, "@E 999,999,999") + '</Font>', '1', 40, 2, 'R'}})
		aAdd( aCabec, {{'<B><Font Size=2 color=black>SXB</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=red>' + Transform( nSXB, "@E 999,999,999")  + '</Font>', '1', 40, 2, 'R'},{'<B><Font Size=2 color=black>SXD</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=red>' + Transform( nSXD, "@E 999,999,999") + '</Font>', '1', 40, 2, 'R'}})
		aAdd( aCabec, {{'<B><Font Size=2 color=black>SXG</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=red>' + Transform( nSXG, "@E 999,999,999")  + '</Font>', '1', 40, 2, 'R'},{'<B><Font Size=2 color=black>SIX</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=red>' + Transform( nSIX, "@E 999,999,999") + '</Font>', '1', 40, 2, 'R'}})
		aAdd( aCabec, {{'<B><Font Size=2 color=black>CT0</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=red>' + Transform( nCT0, "@E 999,999,999")  + '</Font>', '1', 40, 2, 'R'},{'<B><Font Size=2 color=black>USU</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=red>' + Transform( nUSU, "@E 999,999,999") + '</Font>', '1', 40, 2, 'R'}})
		aAdd( aCabec, {{'<B><Font Size=2 color=black>GRU</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=red>' + Transform( nGRU, "@E 999,999,999")  + '</Font>', '1', 40, 2, 'R'}, {'<B><Font Size=2 color=black>TOTAL</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=red>' + Transform( nSX1 + nSX2 + nSX3 + nSX5 + nSX6 + nSX7 + nSX9 + nSXA + nSXB + nSXD + nSXG + nSIX + nCT0 + nUSU + nGRU, "@E 999,999,999") + '</Font>', '1', 40, 2, 'R'}})
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define colunas da tabela...                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aColunas := {}
		aAdd( aColunas, {'Dicionário'				, 10	, 'C'})
		aAdd( aColunas, {'Chave'					, 20	, 'C'})
		aAdd( aColunas, {'Recno'					, 10	, 'C'})
		aAdd( aColunas, {'Descrição'				, 40	, 'C'})
		
		cMensagem += U_BeHtmHead( '', .T., aColunas, aCabec )
		
		For nDiv := 1 To Len(aDivergencia)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime linha de detalhes da tabela...                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aColunas := {}
			aAdd( aColunas, {AllTrim(aDivergencia[nDiv][1])						, 10	, 'C'})
			aAdd( aColunas, {AllTrim(aDivergencia[nDiv][2])						, 20	, 'L'})
			aAdd( aColunas, {Transform(aDivergencia[nDiv][3], "@E 999,999,999")	, 10	, 'R'})
			aAdd( aColunas, {AllTrim(aDivergencia[nDiv][4])						, 40	, 'L'})
		
			If Len( cMensagem ) < 1005572 // O máximo é 1048572
				cMensagem += U_BeHtmDet( aColunas, .T., .F. )
			EndIf
		
		Next
		
		cMensagem += U_BeHtmRod(.T.)
		
		cAssunto := "EQAnaDic - Divergências no dicionário de dados, atuar para correção: " + AllTrim( Transform( nSX1 + nSX2 + nSX3 + nSX5 + nSX6 + nSX7 + nSX9 + nSXA + nSXB + nSXD + nSXG + nSIX + nCT0 + nUSU + nGRU, "@E 999,999,999") ) + " - Empresa: " + cEmpAnt + ' / ' + AllTrim(SM0->M0_NOME)
		cDestino := AllTrim( cEmail )
		
		/*==================================================================================|
		|Envia email.                                                                       |
		|==================================================================================*/
		CONNECT SMTP SERVER _cServer ACCOUNT _cAccount PASSWORD _cPassword Result _lConect
		If _lConect
			SEND MAIL FROM _cEnvia TO cDestino SUBJECT cAssunto BODY cMensagem RESULT _lEnviado
		Else
			_lEnviado := .f.
		EndIf
		DISCONNECT SMTP SERVER Result _lDisConec
	EndIf
EndIf

SET EXACT OFF // FS - 09.06.2015 (Para o padrão Totvs, esta validação é falsa, causando consequências graves em validações condicionais)...

SX1->( RestArea( aAreaSX1 ) )
SX2->( RestArea( aAreaSX2 ) )
SX3->( RestArea( aAreaSX3 ) )
SX6->( RestArea( aAreaSX6 ) )
SX7->( RestArea( aAreaSX7 ) )
SX9->( RestArea( aAreaSX9 ) )
SXA->( RestArea( aAreaSXA ) )
SXB->( RestArea( aAreaSXB ) )
SXD->( RestArea( aAreaSXD ) )
SXG->( RestArea( aAreaSXG ) )
SIX->( RestArea( aAreaSIX ) )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SoCampo  ³ Autor ³ Fabio F. de Sousa     ³ Data ³ 17.02.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna array contendo os campos da string sem funções ou   ³±±
±±³          ³ comandos informado...                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SoCampo( cChave )

Local aRetorno := {}
Local lTemMais := .T.

cChave := Replace( cChave,' ','')
cChave := Replace( cChave,',1,0)' ,'')
cChave := Replace( cChave,',2,0)' ,'')
cChave := Replace( cChave,',3,0)' ,'')
cChave := Replace( cChave,',4,0)' ,'')
cChave := Replace( cChave,',5,2)' ,'')
cChave := Replace( cChave,',6,0)' ,'')
cChave := Replace( cChave,',6,1)' ,'')
cChave := Replace( cChave,',6,2)' ,'')
cChave := Replace( cChave,',7,3)' ,'')
cChave := Replace( cChave,',8,0)' ,'')
cChave := Replace( cChave,',8,4)' ,'')
cChave := Replace( cChave,',9,0)' ,'')
cChave := Replace( cChave,',9,2)' ,'')
cChave := Replace( cChave,',10,0)','')
cChave := Replace( cChave,',12,2)','')
cChave := Replace( cChave,',13,3)','')
cChave := Replace( cChave,',14,0)','')
cChave := Replace( cChave,',14,3)','')
cChave := Replace( cChave,',15,2)','')
cChave := Replace( cChave,',15,5)','')
cChave := Replace( cChave,',17,7)','')
cChave := Replace( cChave,',1)'   ,'')
cChave := Replace( cChave,',2)'   ,'')
cChave := Replace( cChave,',3)'   ,'')
cChave := Replace( cChave,',4)'   ,'')
cChave := Replace( cChave,',5)'   ,'')
cChave := Replace( cChave,',6)'   ,'')
cChave := Replace( cChave,',7)'   ,'')
cChave := Replace( cChave,',8)'   ,'')
cChave := Replace( cChave,',9)'   ,'')
cChave := Replace( cChave,',13)'  ,'')
cChave := Replace( cChave,',14)'  ,'')
cChave := Replace( cChave,',0)'   ,'')
cChave := Replace( cChave,'STR(','')
cChave := Replace( cChave,'DTOS(','')
cChave := Replace( cChave,'STRZERO(','')
cChave := Replace( cChave,')','')

Do While lTemMais
	If At( "+", cChave) == 0
		aAdd( aRetorno, { AllTrim( cChave ) })
		lTemMais := .F.
	Else
		aAdd( aRetorno, { AllTrim( Left(cChave, At( "+", cChave) - 1) ) })
		cChave := SubStr( cChave, At( "+", cChave) + 1, Len(cChave))
	EndIf
EndDo

Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ProcChec ³ Autor ³ Fabio F. de Sousa     ³ Data ³ 17.02.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Habilita ou desabilita objeto de pastas conforme selecionado³±±
±±³          ³ no checkbox para processamentos...                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ProcChec( lMarcado, nItem )

oTFolder:aEnable( nItem, lMarcado)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ XCFGLeg  ³ Autor ³ Fabio F. de Sousa     ³ Data ³ 17.02.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apresenta legenda das inconsistências, se é possível corri- ³±±
±±³          ³ gir automaticamente pela rotina ou não...                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function XCFGLeg()

Local cCadastro := "Inconsistências"
Local aCores    := 	{{ 'CHECKED'  , 'Possível corrigir automaticamente'},;
					 { 'UNCHECKED', 'Necessário correção manual'}}

BrwLegenda( cCadastro, "Legenda", aCores)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fRetFils ³ Autor ³ Fabio F. de Sousa     ³ Data ³ 17.02.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retornar filiais da empresa...                              ³±±
±±³          ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fRetFils( _cEmpresa )

Local aArea    := GetArea()
Local aAreaSM0 := SM0->( GetArea() )
Local aRet     := {}

dbSelectArea("SM0")
dbSetOrder(1)
dbSeek( _cEmpresa )

aAdd( aRet, "" )

Do While !SM0->( Eof() ) .And. SM0->M0_CODIGO == _cEmpresa
	aAdd( aRet, AllTrim( SM0->M0_CODFIL ) )

	SM0->( dbSkip() )
EndDo

SM0->( RestArea( aAreaSM0 ) )
RestArea( aArea )

Return aRet