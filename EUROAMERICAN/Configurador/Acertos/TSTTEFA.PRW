#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "protheus.ch"
#include "totvs.ch"

User function TSTTEFA()

dbSelectArea("SM0")
dbSetOrder(1)
If SM0->( dbSeek( "10" + "0803" ) )
	cEmpAtu := cEmpAnt
	cFilAtu := cFilAnt
	RpcClearEnv()  //Limpa o Ambiente
	RpcSetType(3)
	RpcSetEnv( "10", "0803" )
EndIf

dbSelectArea("SM0")
dbSetOrder(1)
If SM0->( dbSeek( cEmpAtu + cFilAtu ) )
	RpcClearEnv()  //Limpa o Ambiente
	RpcSetType(3)
	RpcSetEnv( "10", "0200" )
EndIf

Return