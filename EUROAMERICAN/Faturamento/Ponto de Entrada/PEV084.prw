//O ponto de entrada PEV084 é utilizado para apresentação de campos na tela de orçamentos.

User Function PEV084()
Local cParam    := PARAMIXB[1]
Local aWebCols  := {}
Conout('Passou pelo ponto de entrada PEV084. - Parametro : '+Str(cParam))
//Parametro "N" campo editável e "D" visualização.

Do Case
    Case cParam == 1
    	aAdd( aWebCols, { "BUDGETID", "D" } )
    			aAdd( aWebCols, { "REGISTERDATE", "D" } )
    			aAdd( aWebCols, { "CUSTOMERCODE", "N", 	{ "BRWCUSTOMER", ;
    							{ "CCUSTOMERCODE", "CCODE" }, ;
    							{ "CCUSTOMERUNIT", "CUNIT" } ;
    							}, ;
								{ "CCODE", "CUNIT", "CDESCRIPTION" } } )
		aAdd( aWebCols, "CUSTOMERUNIT" )
		aAdd( aWebCols, { "DELIVERYCUSTOMER", "N", 	{ "BRWCUSTOMER", ;
													{ "CDELIVERYCUSTOMER", "CCODE" }, ;
													{ "CDELIVERYUNITCODE", "CUNIT" } ;
													}, ;
													{ "CCODE", "CUNIT", "CDESCRIPTION" } } )
		aAdd( aWebCols, "DELIVERYUNITCODE" )
		aAdd( aWebCols, { "PAYMENTPLANCODE", "N", { "BRWPAYMENTPLAN", ;
												{ "CPAYMENTPLANCODE", "CPAYMENTPLANCODE" } ;
												}, ;
												{ "CPAYMENTPLANCODE", "CDESCRIPTIONPAYMENTPLAN" } } )
		aAdd( aWebCols, { "PRICELISTCODE", "N" } )
		aAdd( aWebCols, { "DISCOUNT1", "N" } )
		aAdd( aWebCols, { "DISCOUNT2", "D" } )
		aAdd( aWebCols, { "DISCOUNT3", "D" } )
		aAdd( aWebCols, { "DISCOUNT4", "N" } )
		aAdd( aWebCols, "QUOTATIONORORDERID" )
		aAdd( aWebCols, { "FREIGHTVALUE", "D" } )
		aAdd( aWebCols, { "INSURANCEVALUE", "D" } )
		aAdd( aWebCols, { "ADDITIONALEXPENSEVALUE", "D" } )
		aAdd( aWebCols, { "INDEPENDENTFREIGHT", "D" } )
		aAdd( aWebCols, { "EXPIRATIONDATE", "D" } )
		aAdd( aWebCols, { "INDEMNITYVALUE", "D" } )
		aAdd( aWebCols, { "INDEMNITYPERCENTAGE", "D" } )
		aAdd( aWebCols, { "DESCRIPTIONSTATUS", "D" } )
		/*AAdd( aWebCols, { "CARRIERCODE", "N", { "GETCARRIER", ;
							{ "CCARRIERCODE", "CCODE" } ;
								}, ;
							{ "CCODE", "CDESCRIPTION" } } )*/
		aAdd( aWebCols, {"CJ_TRANSP" , "N", { "GETCARRIER", ;
							{ "CCARRIERCODE", "CCODE" } ;
								}, ;
							{ "CCODE", "CDESCRIPTION" } } )
	Case cParam == 2
		aAdd( aWebCols, { "PRODUCTID", "N", { "GETCATALOG", ;
											{ "CPRODUCTID", "CPRODUCTCODE" } ;
											}, ;
											{ "CPRODUCTCODE", "CDESCRIPTION" }, 13 } )
		aAdd( aWebCols, { "PRODUCTDESCRIPTION", "N", 0, .F. } )
		aAdd( aWebCols, { "QUANTITY", "N", 3 } )
		aAdd( aWebCols, { "NETUNITPRICE", "N", 9, .T. } )
		aAdd( aWebCols, { "CUSTOMERBUDGETID", "N", 5 } )
		aAdd( aWebCols, { "NETTOTAL", "N", 0, .F. } )
	EndCase
Return aWebCols
