/*      run createXMLMessage in ptpsession (output requestH).
      run setText in requestH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
      run appendText in requestH ("<DOC>").  

if v-payment-kz <> " " and v-payment-kz <> "0" then do:
       run appendText in requestH ("<PAYMENT>").
end.
if v-payment-ex <> " "  and v-payment-ex <> "0" then do:
       run appendText in requestH ("<CURRENCY_EXCHANGE>").
end.
if v-payment-cr <> " "  and v-payment-cr <> "0"   then do:
       run appendText in requestH ("<CURRENCY_PAYMENT>").
end.


  
      run appendText in requestH ("<ID>" + v-state + "</ID>").  
      run appendText in requestH ("<STATUS>" + v-sts + "</STATUS>").  
      run appendText in requestH ("<DESCRIPTION>" + v-des + "</DESCRIPTION>").  
      run appendText in requestH ("<TIMESTAMP>" + string(g-today) + " " + string(time, "hh:mm:ss") +  "</TIMESTAMP>").  


if v-payment-kz <> " " and v-payment-kz <> "0" then do:
       run appendText in requestH ("</PAYMENT>").
end.
if v-payment-ex <> " "  and v-payment-ex <> "0" then do:
       run appendText in requestH ("</CURRENCY_EXCHANGE>").
end.
if v-payment-cr <> " "  and v-payment-cr <> "0"   then do:
       run appendText in requestH ("</CURRENCY_PAYMENT>").
end.



      run appendText in requestH ("</DOC>").  
      RUN sendToQueue IN ptpsession ("SYNC2NETBANK", requestH, ?, ?, ?). 
      RUN deleteMessage IN requestH.
*/


      run createXMLMessage in ptpsession (output requestH).
      run setText in requestH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
      run appendText in requestH ("<DOC>").  
if (v-payment-kz <> " " and v-payment-kz <> "0") 
/*
or (v-socialpayment-ps <> " " and v-socialpayment-ps <> "0") or (v-taxpayment-ps <> " " and v-taxpayment-ps <> "0")*/  then do:
       run appendText in requestH ("<PAYMENT>").
end.



if v-payment-ex <> " "  and v-payment-ex <> "0" then do:
       run appendText in requestH ("<CURRENCY_EXCHANGE>").
end.
if v-payment-cr <> " "  and v-payment-cr <> "0"   then do:
       run appendText in requestH ("<CURRENCY_PAYMENT>").
end.


  
      run appendText in requestH ("<ID>" + v-state + "</ID>").  
      run appendText in requestH ("<STATUS>" + v-sts + "</STATUS>").  
      run appendText in requestH ("<DESCRIPTION>" + v-des + "</DESCRIPTION>").  
      run appendText in requestH ("<TIMESTAMP>" + string(g-today) + " " + string(time, "hh:mm:ss") +  "</TIMESTAMP>").  


if (v-payment-kz <> " " and v-payment-kz <> "0")
/* or (v-socialpayment-ps <> " " and v-socialpayment-ps <> "0") or (v-taxpayment-ps <> " " and v-taxpayment-ps <> "0")*/  then do:
       run appendText in requestH ("</PAYMENT>").
end.



if v-payment-ex <> " "  and v-payment-ex <> "0" then do:
       run appendText in requestH ("</CURRENCY_EXCHANGE>").
end.
if v-payment-cr <> " "  and v-payment-cr <> "0"   then do:
       run appendText in requestH ("</CURRENCY_PAYMENT>").
end.



      run appendText in requestH ("</DOC>").  
      RUN sendToQueue IN ptpsession ("SYNC2NETBANK", requestH, ?, ?, ?). 
      RUN deleteMessage IN requestH.
