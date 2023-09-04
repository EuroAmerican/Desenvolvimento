#include "protheus.ch"

// Função para Montagem do Header e Menus
User Function BePHeader()

Local cRet 		 := ""
Local lUsaTbl 	 :=  Iif(ValType(PARAMIXB) <> "A", .F., PARAMIXB[1])
Local cEnvServer := AllTrim( Upper( GetEnvServer() ) )

cRet += '<!DOCTYPE html>'+CRLF
cRet += '<html lang="pt-br">'+CRLF
cRet += '<head>'+CRLF
cRet += '	<meta charset="utf-8">'+CRLF
cRet += '   <meta name="robots" content="noindex">'+CRLF
//If cEnvServer == "PORTAL_EURO"
//	cRet += '   <title>Portal Protheus Euroamerican</title>'+CRLF
//ElseIf cEnvServer == "PORTAL_QUALY"
//	cRet += '   <title>Portal Protheus Qualycril</title>'+CRLF
//ElseIf cEnvServer == "PORTAL_METROPOLE"
//	cRet += '   <title>Portal Protheus Metropole</title>'+CRLF
//ElseIf cEnvServer == "PORTAL_JAYS"
//	cRet += '   <title>Portal Protheus Jays</title>'+CRLF
//Else
	cRet += '   <title>Portal Protheus Grupo Euroamerican</title>'+CRLF
//EndIf
cRet += '	<meta name="viewport" content="width=device-width, initial-scale=1">'+CRLF

cRet += ' 	<link href="ws/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">'+CRLF
//If cEnvServer == "PORTAL_EURO"
	cRet += '   <link rel="shortcut icon" href="img/favicon_euro.ico">'+CRLF
	cRet += '	'+CRLF
	cRet += '	<link rel="apple-touch-icon-precomposed" sizes="57x57"     href="img/favicon_euroamerican.png" />'+CRLF
	cRet += '	<link rel="apple-touch-icon-precomposed" sizes="114x114"   href="img/favicon_euroamerican.png" />'+CRLF
	cRet += '	<link rel="apple-touch-icon-precomposed" sizes="72x72"     href="img/favicon_euroamerican.png" />'+CRLF
	cRet += '	<link rel="apple-touch-icon-precomposed" sizes="144x144"   href="img/favicon_euroamerican.png" />'+CRLF
	cRet += '	<link rel="apple-touch-icon-precomposed" sizes="60x60"     href="img/favicon_euroamerican.png" />'+CRLF
	cRet += '	<link rel="apple-touch-icon-precomposed" sizes="120x120"   href="img/favicon_euroamerican.png" />'+CRLF
	cRet += '	<link rel="apple-touch-icon-precomposed" sizes="76x76"     href="img/favicon_euroamerican.png" />'+CRLF
	cRet += '	<link rel="apple-touch-icon-precomposed" sizes="152x152"   href="img/favicon_euroamerican.png" />'+CRLF
	cRet += '	<link rel="icon" type="image/png"                          href="img/favicon_euroamerican.png" />'+CRLF
	cRet += '	<link rel="icon" type="image/png"                          href="img/favicon_euroamerican.png" />'+CRLF
	cRet += '	<link rel="icon" type="image/png"                          href="img/favicon_euroamerican.png" />'+CRLF
	cRet += '	<link rel="icon" type="image/png"                          href="img/favicon_euroamerican.png" />'+CRLF
	cRet += '	<link rel="icon" type="image/png"                          href="img/favicon_euroamerican.png" />'+CRLF
/*
Else
	cRet += '   <link rel="shortcut icon" href="img/favicon_qualy.ico">'+CRLF
	cRet += '	'+CRLF
	cRet += '	<link rel="apple-touch-icon-precomposed" sizes="57x57"     href="img/favicon_qualycril.png" />'+CRLF
	cRet += '	<link rel="apple-touch-icon-precomposed" sizes="114x114"   href="img/favicon_qualycril.png" />'+CRLF
	cRet += '	<link rel="apple-touch-icon-precomposed" sizes="72x72"     href="img/favicon_qualycril.png" />'+CRLF
	cRet += '	<link rel="apple-touch-icon-precomposed" sizes="144x144"   href="img/favicon_qualycril.png" />'+CRLF
	cRet += '	<link rel="apple-touch-icon-precomposed" sizes="60x60"     href="img/favicon_qualycril.png" />'+CRLF
	cRet += '	<link rel="apple-touch-icon-precomposed" sizes="120x120"   href="img/favicon_qualycril.png" />'+CRLF
	cRet += '	<link rel="apple-touch-icon-precomposed" sizes="76x76"     href="img/favicon_qualycril.png" />'+CRLF
	cRet += '	<link rel="apple-touch-icon-precomposed" sizes="152x152"   href="img/favicon_qualycril.png" />'+CRLF
	cRet += '	<link rel="icon" type="image/png"                          href="img/favicon_qualycril.png" />'+CRLF
	cRet += '	<link rel="icon" type="image/png"                          href="img/favicon_qualycril.png" />'+CRLF
	cRet += '	<link rel="icon" type="image/png"                          href="img/favicon_qualycril.png" />'+CRLF
	cRet += '	<link rel="icon" type="image/png"                          href="img/favicon_qualycril.png" />'+CRLF
	cRet += '	<link rel="icon" type="image/png"                          href="img/favicon_qualycril.png" />'+CRLF
EndIf
*/

cRet += '   <script src="xfiles/js/jquery.min.js"></script>'+CRLF  
cRet += '   <script src="http://cdn.jsdelivr.net/jquery.flot/0.8.3/jquery.flot.min.js"></script>'+CRLF  
cRet += '   <script src="/ws/vendor/bootstrap/js/bootstrap.min.js"></script>'+CRLF
//cRet += '	<link href="portal/vendor/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">'+CRLF
cRet += '	<link href="ws/vendor/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">'+CRLF

////If lUsaTbl
	cRet += '	<script type="text/javascript" language="javascript" src="xfiles/js/jquery.dataTables.min.js"></script>'+CRLF
	cRet += '	<script type="text/javascript" language="javascript" src="xfiles/js/dataTables.bootstrap.min.js"></script>'+CRLF
	cRet += '	<script type="text/javascript" language="javascript" src="xfiles/js/dataTables.responsive.min.js"></script>'+CRLF
	cRet += '	<script type="text/javascript" language="javascript" src="xfiles/js/responsive.boostrap.min.js"></script>'+CRLF

	//cRet += '						<script type="text/javascript" language="javascript" src="https://code.jquery.com/jquery-3.3.1.js"></script>' + CRLF
	//cRet += '						<script type="text/javascript" language="javascript" src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.min.js"></script>' + CRLF
	cRet += '						<script type="text/javascript" language="javascript" src="https://cdn.datatables.net/buttons/1.6.0/js/dataTables.buttons.min.js"></script>' + CRLF
	cRet += '						<script type="text/javascript" language="javascript" src="https://cdn.datatables.net/buttons/1.6.0/js/buttons.flash.min.js"></script>' + CRLF
	cRet += '						<script type="text/javascript" language="javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.1.3/jszip.min.js"></script>' + CRLF
	cRet += '						<script type="text/javascript" language="javascript" src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.53/pdfmake.min.js"></script>' + CRLF
	cRet += '						<script type="text/javascript" language="javascript" src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.53/vfs_fonts.js"></script>' + CRLF
	cRet += '						<script type="text/javascript" language="javascript" src="https://cdn.datatables.net/buttons/1.6.0/js/buttons.html5.min.js"></script>' + CRLF
	cRet += '						<script type="text/javascript" language="javascript" src="https://cdn.datatables.net/buttons/1.6.0/js/buttons.print.min.js"></script>' + CRLF

	cRet += '	<link href="xfiles/css/responsive.bootstrap.min.css" rel="stylesheet">
////EndIf
	cRet += '	<link rel="shortcut icon" type="image/png" href="/media/images/favicon.png">
	cRet += '	<link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="http://www.datatables.net/rss.xml">
	cRet += '	<link rel="stylesheet" type="text/css" href="/media/css/site-examples.css?_=8ffc0b31bc8d9ff82fbb94689dd1d7ff">
	//cRet += '	<link rel="stylesheet" type="text/css" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
	cRet += '	<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.20/css/dataTables.bootstrap.min.css">
	cRet += '	<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/buttons/1.6.0/css/buttons.bootstrap.min.css">

	/*
	cRet += '							<script>' + CRLF
	cRet += '						$(document).ready(function() {
	cRet += "						    $('#example').DataTable( {
	cRet += "						        dom: 'Bfrtip',
	cRet += '        "paging":   false,
	cRet += '        "ordering": false,
	cRet += '        "info":     false,
	cRet += '						        buttons: [
	cRet += "						            'copy', 'csv', 'excel', 'pdf', 'print'
	cRet += '						        ]
	cRet += '						    } );
	cRet += '						} );
	cRet += '							</script>' + CRLF
	*/

	/*
	cRet += '							<script>' + CRLF
	cRet += '$(document).ready(function() {
	cRet += "    $('#example').DataTable( {
	cRet += "        dom: 'Bfrtip',
	cRet += '        "paging":   false,
	cRet += '        "ordering": false,
	cRet += '        "info":     false,
	cRet += '        buttons: [
	cRet += '            {
	cRet += "                extend: 'pdfHtml5',
	cRet += "                orientation: 'landscape',
	cRet += "                pageSize: 'LEGAL'
	cRet += '            }
	cRet += "        , 'excel']
	cRet += '    } );
	cRet += '} );
	cRet += '							</script>' + CRLF

	cRet += '							<script>' + CRLF
	cRet += '						$(document).ready(function() {
	cRet += "						    $('#example1').DataTable( {
	cRet += "        dom: 'Bfrtip',
	cRet += '        "paging":   false,
	cRet += '        "ordering": false,
	cRet += '        "info":     false,
	cRet += '        buttons: [
	cRet += '            {
	cRet += "                extend: 'pdfHtml5',
	cRet += "                orientation: 'landscape',
	cRet += "                pageSize: 'LEGAL'
	cRet += '            }
	cRet += "        , 'excel']
	cRet += '						    } );
	cRet += '						} );
	cRet += '							</script>' + CRLF

	cRet += '							<script>' + CRLF
	cRet += '						$(document).ready(function() {
	cRet += "						    $('#example2').DataTable( {
	cRet += "        dom: 'Bfrtip',
	cRet += '        "paging":   false,
	cRet += '        "ordering": false,
	cRet += '        "info":     false,
	cRet += '        buttons: [
	cRet += '            {
	cRet += "                extend: 'pdfHtml5',
	cRet += "                orientation: 'landscape',
	cRet += "                pageSize: 'LEGAL'
	cRet += '            }
	cRet += "        , 'excel']
	cRet += '						    } );
	cRet += '						} );
	cRet += '							</script>' + CRLF
	*/

cRet += '	'+CRLF
cRet += '   <style type="text/css">'+CRLF
cRet += '   	body,html{'+CRLF
cRet += '		height: 100%;'+CRLF
cRet += '		}'+CRLF
cRet += '		'+CRLF
cRet += '		/* remove outer padding */'+CRLF
cRet += '		.main .row{'+CRLF
cRet += '			padding: 0px;'+CRLF
cRet += '			margin: 0px;'+CRLF
cRet += '		}'+CRLF
cRet += '		'+CRLF
cRet += '		/*Remove rounded coners*/'+CRLF
cRet += '		'+CRLF
cRet += '		nav.sidebar.navbar {'+CRLF
cRet += '			border-radius: 0px;'+CRLF
cRet += '		}'+CRLF
cRet += '		'+CRLF
cRet += '		nav.sidebar, .main{'+CRLF
cRet += '			-webkit-transition: margin 200ms ease-out;'+CRLF
cRet += '		    -moz-transition: margin 200ms ease-out;'+CRLF
cRet += '		    -o-transition: margin 200ms ease-out;'+CRLF
cRet += '		    transition: margin 200ms ease-out;'+CRLF
cRet += '		}'+CRLF
cRet += '		'+CRLF
cRet += '		/* Add gap to nav and right windows.*/'+CRLF
cRet += '		.main{'+CRLF
cRet += '			padding: 10px 10px 0 10px;'+CRLF
cRet += '		}'+CRLF
cRet += '		'+CRLF
cRet += '		/* .....NavBar: Icon only with coloring/layout.....*/'+CRLF
cRet += '		'+CRLF
cRet += '		/*small/medium side display*/'+CRLF
cRet += '		@media (min-width: 768px) {'+CRLF
cRet += '		'+CRLF
cRet += '			/*Allow main to be next to Nav*/'+CRLF
cRet += '			.main{'+CRLF
cRet += '				position: absolute;'+CRLF
cRet += '				width: calc(100% - 40px); /*keeps 100% minus nav size*/'+CRLF
cRet += '				margin-left: 40px;'+CRLF
cRet += '				float: right;'+CRLF
cRet += '			}'+CRLF
cRet += '			'+CRLF
cRet += ' 			/*lets nav bar to be showed on mouseover*/'+CRLF
cRet += '			nav.sidebar:hover + .main{'+CRLF
cRet += '				margin-left: 200px;'+CRLF
cRet += '			}'+CRLF
cRet += '			'+CRLF
cRet += '			/*Center Brand*/'+CRLF
cRet += '			nav.sidebar.navbar.sidebar>.container .navbar-brand, .navbar>.container-fluid .navbar-brand {'+CRLF
cRet += '				margin-left: 0px;'+CRLF
cRet += '			}'+CRLF
cRet += '			/*Center Brand*/'+CRLF
cRet += '			nav.sidebar .navbar-brand, nav.sidebar .navbar-header{'+CRLF
cRet += '				text-align: center;'+CRLF
cRet += '				width: 100%;'+CRLF
cRet += '				margin-left: 0px;'+CRLF
cRet += '			}'+CRLF
cRet += '			'+CRLF
cRet += '			/*Center Icons*/'+CRLF
cRet += '			nav.sidebar a{'+CRLF
cRet += '				padding-right: 13px;'+CRLF
cRet += '			}'+CRLF
cRet += '			'+CRLF
cRet += '			/*adds border top to first nav box */'+CRLF
cRet += '			nav.sidebar .navbar-nav > li:first-child{'+CRLF
cRet += '				border-top: 1px #e5e5e5 solid;'+CRLF
cRet += '			}'+CRLF
cRet += '			'+CRLF
cRet += '			/*adds border to bottom nav boxes*/'+CRLF
cRet += '			nav.sidebar .navbar-nav > li{'+CRLF
cRet += '				border-bottom: 1px #e5e5e5 solid;'+CRLF
cRet += '			}'+CRLF
cRet += '			'+CRLF
cRet += '			/* Colors/style dropdown box*/'+CRLF
cRet += '			nav.sidebar .navbar-nav .open .dropdown-menu {'+CRLF
cRet += '				position: static;'+CRLF
cRet += '				float: none;'+CRLF
cRet += '				width: auto;'+CRLF
cRet += '				margin-top: 0;'+CRLF
cRet += '				background-color: transparent;'+CRLF
cRet += '				border: 0;'+CRLF
cRet += '				-webkit-box-shadow: none;'+CRLF
cRet += '				box-shadow: none;'+CRLF
cRet += '			}'+CRLF
cRet += '			'+CRLF
cRet += '			/*allows nav box to use 100% width*/'+CRLF
cRet += '			nav.sidebar .navbar-collapse, nav.sidebar .container-fluid{'+CRLF
cRet += '				padding: 0 0px 0 0px;'+CRLF
cRet += '			}'+CRLF
cRet += '			'+CRLF
cRet += '			/*colors dropdown box text */'+CRLF
cRet += '			.navbar-inverse .navbar-nav .open .dropdown-menu>li>a {'+CRLF
cRet += '				color: #777;'+CRLF
cRet += '			}'+CRLF
cRet += '			'+CRLF
cRet += '			/*gives sidebar width/height*/'+CRLF
cRet += '			nav.sidebar{'+CRLF
cRet += '				width: 200px;'+CRLF
cRet += '				height: 100%;'+CRLF
cRet += '				margin-left: -160px;'+CRLF
cRet += '				float: left;'+CRLF
cRet += '				z-index: 8000;'+CRLF
cRet += '				margin-bottom: 0px;'+CRLF
cRet += '			}'+CRLF
cRet += '			'+CRLF
cRet += '			/*give sidebar 100% width;*/'+CRLF
cRet += '			nav.sidebar li {'+CRLF
cRet += '				width: 100%;'+CRLF
cRet += '			}'+CRLF
cRet += '			'+CRLF
cRet += '			/* Move nav to full on mouse over*/'+CRLF
cRet += '			nav.sidebar:hover{'+CRLF
cRet += '				margin-left: 0px;'+CRLF
cRet += '			}'+CRLF
cRet += '			/*for hiden things when navbar hidden*/'+CRLF
cRet += '			.forAnimate{'+CRLF
cRet += '				opacity: 0;'+CRLF
cRet += '			}'+CRLF
cRet += '		}'+CRLF
cRet += '		'+CRLF
cRet += '		/* .....NavBar: Fully showing nav bar..... */'+CRLF
cRet += '		'+CRLF
cRet += '		@media (min-width: 1330px) {'+CRLF
cRet += '		'+CRLF
cRet += '			/*Allow main to be next to Nav*/'+CRLF
cRet += '			.main{'+CRLF
cRet += '				width: calc(100% - 200px); /*keeps 100% minus nav size*/'+CRLF
cRet += '				margin-left: 200px;'+CRLF
cRet += '			}'+CRLF
cRet += '			'+CRLF
cRet += '			/*Show all nav*/'+CRLF
cRet += '			nav.sidebar{'+CRLF
cRet += '				margin-left: 0px;'+CRLF
cRet += '				float: left;'+CRLF
cRet += '			}'+CRLF
cRet += '			/*Show hidden items on nav*/'+CRLF
cRet += '			nav.sidebar .forAnimate{'+CRLF
cRet += '				opacity: 1;'+CRLF
cRet += '			}'+CRLF
cRet += '		}'+CRLF
cRet += '		'+CRLF
cRet += '		nav.sidebar .navbar-nav .open .dropdown-menu>li>a:hover, nav.sidebar .navbar-nav .open .dropdown-menu>li>a:focus {'+CRLF
cRet += '			color: #CCC;'+CRLF
cRet += '			background-color: transparent;'+CRLF
cRet += '		}'+CRLF
cRet += '		'+CRLF
cRet += '		nav:hover .forAnimate{'+CRLF
cRet += '			opacity: 1;'+CRLF
cRet += '		}'+CRLF
cRet += '		section{'+CRLF
cRet += '			padding-left: 15px;'+CRLF
cRet += '		}'+CRLF
cRet += '		.jumbotron { '+CRLF
cRet += '			background-color: #ffffff; '+CRLF
cRet += '			color: #eee;'+CRLF
cRet += '		}'+CRLF
cRet += '   </style>'+CRLF
/*
cRet += '   <script type="text/javascript">'+CRLF
cRet += '   	window.alert = function(){};'+CRLF
cRet += '       var defaultCSS = document.getElementById("bootstrap-css");'+CRLF
cRet += '       function changeCSS(css){'+CRLF
cRet += '			if(css) $("head > link").filter(":first").replaceWith("<link rel='+"'"+'stylesheet'+"'"+'href=  "'+"'"+'+ css +'+"'"+'" type="text/css" />); '+CRLF
cRet += '            else $("head > link").filter(":first").replaceWith(defaultCSS); '+CRLF
cRet += '       }'+CRLF
//cRet += '       $( document ).ready(function() {'+CRLF
//cRet += '       	var iframe_height = parseInt($("html").height()); '+CRLF
//cRet += '          	window.parent.postMessage( iframe_height, "http://bootsnipp.com");'+CRLF
//cRet += '       });'+CRLF
cRet += '    </script>'+CRLF
*/
cRet += '</head>'+CRLF
cRet += '<body>'+CRLF

Return cRet