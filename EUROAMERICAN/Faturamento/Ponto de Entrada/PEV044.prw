User Function PEV044()
Local nParam	:= PARAMIXB[1]
Local aReturn 	:= {}
Do Case
	Case nParam == 1
		AAdd( aReturn, { "ORDERID", "D" } )
		AAdd( aReturn, { "CUSTOMERCODE", "N", { "BRWCUSTOMER", ;
		{ "CCUSTOMERCODE", "CCODE" }, ;
		{ "CCUSTOMERUNIT", "CUNIT" } ;
		}, ;
		{ "CCODE", "CUNIT", "CDESCRIPTION" } } )
		AAdd( aReturn, "CUSTOMERUNIT" )
		AAdd( aReturn, { "DELIVERYCUSTOMER", "N", { "BRWCUSTOMER", ;
		{ "CDELIVERYCUSTOMER", "CCODE" }, ;
		{ "CDELIVERYUNITCODE", "CUNIT" } ;
		}, ;
		{ "CCODE", "CUNIT", "CDESCRIPTION" } } )
		AAdd( aReturn, "DELIVERYUNITCODE" )
		AAdd( aReturn, { "CARRIERCODE", "N", { "GETCARRIER", ;
		{ "CCARRIERCODE", "CCODE" } ;
		}, ;
		{ "CCODE", "CDESCRIPTION" } } )
		AAdd( aReturn, { "PAYMENTPLANCODE", "N", { "BRWPAYMENTPLAN", ;
		{ "CPAYMENTPLANCODE", "CPAYMENTPLANCODE" } ;
		}, ;
		{ "CPAYMENTPLANCODE", "CDESCRIPTIONPAYMENTPLAN" } } )
		AAdd( aReturn, "PRICELISTCODE" )
		AAdd( aReturn, "DISCOUNT1" )
		AAdd( aReturn, "DISCOUNT2" )
		AAdd( aReturn, "DISCOUNT3" )
		AAdd( aReturn, "DISCOUNT4" )
		AAdd( aReturn, "BANKCODE" )
		AAdd( aReturn, { "FINANCIALDISCOUNT", "D" } )
		AAdd( aReturn, { "REGISTERDATE", "D" } )
		AAdd( aReturn, "BIDNUMBER" )
		AAdd( aReturn, { "FREIGHTVALUE", "D" } )
		AAdd( aReturn, { "INSURANCEVALUE", "D" } )
		AAdd( aReturn, { "ADDITIONALEXPENSEVALUE", "D" } )
		AAdd( aReturn, { "INDEPENDENTFREIGHT", "D" } )
		AAdd( aReturn, { "ADJUSTMENTTYPE", "D" } )
		AAdd( aReturn, { "SALESORDERCURRENCY", "D" } )
		AAdd( aReturn, { "NETWEIGHT", "D" } )
		AAdd( aReturn, { "GROSSWEIGHT", "D" } )
		AAdd( aReturn, { "REDELIVERYCARRIERCODE", "D" } )
		AAdd( aReturn, { "FINANCIALINCREASE", "D" } )
		AAdd( aReturn, { "INVOICEMESSAGE", "D" } )
		AAdd( aReturn, { "STANDARDMESSAGE1", "D" } )
		AAdd( aReturn, { "INDEMNITYVALUE", "D" } )
		AAdd( aReturn, { "INDEMNITYPERCENTAGE", "D" } )
	Case nParam == 2
		AAdd( aReturn, { "ORDERITEM", "D", 2 } )
		AAdd( aReturn, { "PRODUCTID", "N", { "GETCATALOG", ;
		{ "CPRODUCTID", "CPRODUCTCODE" } ;
		}, ;
		{ "CPRODUCTCODE", "CDESCRIPTION" }, 13 } )
		AAdd( aReturn, { "PRODUCTDESCRIPTION", "N", 0, .F. } )
		AAdd( aReturn, { "QUANTITY", "N", 3 } )
		AAdd( aReturn, { "NETUNITPRICE", "N", 9, .T. } )
		AAdd( aReturn, { "DISCOUNTPERCENTAGE", "N", 3 } )
		AAdd( aReturn, { "CUSTOMERORDERNUMBER", "N", 5 } )
		AAdd( aReturn, { "NETTOTAL", "N", 0, .F. } )
	EndCase
Return	aReturn
