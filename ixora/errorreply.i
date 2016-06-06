/* errorreply.i
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Загрузка платежей в интернет-банкинг.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * BASES
        BANK COMM
 * AUTHOR
        09/10/09 id00004
*/


         /*
       run deleteMessage in requestH. 

       replyH = replyMessage.
       run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
       run appendText in replyH ("<DOC>").

if v-payment-kz <> " " and v-payment-kz <> "0" then do:
       run appendText in replyH ("<PAYMENT>").
end.
if v-payment-ex <> " "  and v-payment-ex <> "0" then do:
       run appendText in replyH ("<CURRENCY_EXCHANGE>").
end.
if v-payment-cr <> " "  and v-payment-cr <> "0"   then do:
       run appendText in replyH ("<CURRENCY_PAYMENT>").
end.




       run appendText in replyH ("<ID>" + v-state + "</ID>"). 
       run appendText in replyH ("<STATUS>" + v-sts + "</STATUS>").


if v-payment-kz <> " " and v-payment-kz <> "0" then do:
       run appendText in replyH ("</PAYMENT>").
end.
if v-payment-ex <> " "  and v-payment-ex <> "0" then do:
       run appendText in replyH ("</CURRENCY_EXCHANGE>").
end.
if v-payment-cr <> " "  and v-payment-cr <> "0"   then do:
       run appendText in replyH ("</CURRENCY_PAYMENT>").
end.


       run appendText in replyH ("<DESCRIPTION>" + v-des + "</DESCRIPTION>").
       run appendText in replyH ("<TIMESTAMP>" + string(g-today) + " " + string(time, "hh:mm:ss") +  "</TIMESTAMP>").
       run appendText in replyH ("</DOC>").  

              */



      run createXMLMessage in ptpsession (output requestH).
      run setText in requestH ("<?xml version=""1.0"" encoding=""UTF-8""?>").






       run appendText in requestH ("<DOC>").

if (v-payment-kz <> " " and v-payment-kz <> "0") or (v-socialpayment-ps <> " " and v-socialpayment-ps <> "0") or (v-taxpayment-ps <> " " and v-taxpayment-ps <> "0")  then do:
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


if (v-payment-kz <> " " and v-payment-kz <> "0") or (v-socialpayment-ps <> " " and v-socialpayment-ps <> "0") or (v-taxpayment-ps <> " " and v-taxpayment-ps <> "0")  then do:
       run appendText in requestH ("</PAYMENT>").
end.



if v-payment-ex <> " "  and v-payment-ex <> "0" then do:
       run appendText in requestH ("</CURRENCY_EXCHANGE>").
end.
if v-payment-cr <> " "  and v-payment-cr <> "0"   then do:
       run appendText in requestH ("</CURRENCY_PAYMENT>").
end.


       run appendText in requestH ("<DESCRIPTION>" + v-des + "</DESCRIPTION>").
       run appendText in requestH ("<TIMESTAMP>" + string(g-today) + " " + string(time, "hh:mm:ss") +  "</TIMESTAMP>").
       run appendText in requestH ("</DOC>").   
      RUN sendToQueue IN ptpsession ("SYNC2NETBANK", requestH, ?, ?, ?). 
      RUN deleteMessage IN requestH.



  


