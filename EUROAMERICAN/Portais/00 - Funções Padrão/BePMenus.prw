#Include "protheus.ch"

// Função param montar os menus de acordo com o usuario logado
User Function BePMenus()

Local cModAtu    := ""
Local cRet       := ""
Local lOpenLI    := .F.
Local cEnvServer := AllTrim( Upper( GetEnvServer() ) )

cRet += '	<nav class="navbar navbar-inverse sidebar navbar-fixed-top" role="navigation">'+CRLF
cRet += '    <div class="container-fluid">'+CRLF
cRet += '		<!-- Brand and toggle get grouped for better mobile display -->'+CRLF
cRet += '		<div class="navbar-header">'+CRLF
cRet += '			<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-sidebar-navbar-collapse-1">'+CRLF
cRet += '				<span class="sr-only">Toggle navigation</span>'+CRLF
cRet += '				<span class="icon-bar"></span>'+CRLF
cRet += '				<span class="icon-bar"></span>'+CRLF
cRet += '				<span class="icon-bar"></span>'+CRLF
cRet += '			</button>'+CRLF
//If cEnvServer == "PORTAL_EURO"
//	//cRet += '			<a class="navbar-brand" href="https://www.euroamerican.com.br/">Euroamerican</a>'+CRLF
//	cRet += '			Euroamerican'+CRLF
//ElseIf cEnvServer == "PORTAL_QUALY"
//	//cRet += '			<a class="navbar-brand" href="https://www.qualycril.com.br/">Qualycril</a>'+CRLF
//	cRet += '			Qualycril'+CRLF
//ElseIf cEnvServer == "PORTAL_METROPOLE"
//	//cRet += '			<a class="navbar-brand" href="https://www.qualycril.com.br/">Qualycril</a>'+CRLF
//	cRet += '			Metropole'+CRLF
//ElseIf cEnvServer == "PORTAL_JAYS"
//	//cRet += '			<a class="navbar-brand" href="https://www.qualycril.com.br/">Qualycril</a>'+CRLF
//	cRet += '			Jays'+CRLF
//Else
//	//cRet += '			<a class="navbar-brand" href="https://www.qualycril.com.br/">Qualycril</a>'+CRLF
//	cRet += '			Qualyvinil'+CRLF
//EndIf
cRet += '			Grupo Euroamerican'+CRLF
cRet += '		</div>'+CRLF
cRet += '		<!-- Collect the nav links, forms, and other content for toggling -->'+CRLF
cRet += '		<div class="collapse navbar-collapse" id="bs-sidebar-navbar-collapse-1">'+CRLF
cRet += '			<ul class="nav navbar-nav">'+CRLF
cRet += '				<li class="active"><a href="u_BePIndex.apw">Home<span style="font-size:16px;" class="pull-right hidden-xs showopacity glyphicon glyphicon-home"></span></a></li>'+CRLF

dbSelectArea("Z18")
dbSetorder(1)
If dbSeek(xFilial("Z18")+HttpSession->ccodusr)

	Do While !Z18->(Eof()) .And. Z18->Z18_CODUSR == HttpSession->ccodusr

		If cModAtu <> Z18->Z18_CODMOD
			
			cModAtu := Z18->Z18_CODMOD
			
			If lOpenLI
				cRet += '					</ul>'+CRLF
				cRet += '				</li>'+CRLF
				
				lOpenLI := .F.
			EndIf	

			cRet += '				<li class="dropdown">'+CRLF
			cRet += '					<a href="#" class="dropdown-toggle" data-toggle="dropdown">'+Z18->Z18_NOMMOD+'<span class="caret"></span><span style="font-size:16px;" class="pull-right hidden-xs showopacity glyphicon '+Alltrim(Z18->Z18_ICON)+'"></span></a>'+CRLF
			cRet += '					<ul class="dropdown-menu forAnimate" role="menu">'+CRLF
			
			lOpenLI := .T.

		EndIf

		cRet += '						<li><a href="'+Alltrim(Z18->Z18_ROTINA)+'">'+Z18->Z18_DESROT+'</a></li>'+CRLF
	
		Z18->(dbSkip())

	EndDo	

	If lOpenLI
		cRet += '					</ul>'+CRLF
		cRet += '				</li>'+CRLF
		
		lOpenLI := .F.
	EndIf	

EndIf

cRet += '				<li><a href="u_BePLogin.apw">Logout<span style="font-size:16px;" class="pull-right hidden-xs showopacity glyphicon glyphicon-log-out"></span></a></li>'+CRLF
cRet += '			</ul>'+CRLF
cRet += '		</div>'+CRLF
cRet += '	</div>'+CRLF
cRet += '</nav>'+CRLF

Return cRet