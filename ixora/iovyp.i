/* iovyp.i
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Загрузка платежей в интернет-банкинг.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - iovyp.p.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * BASES
        BANK COMM
 * AUTHOR
        09/10/09 id00004
        18/08/10 id00004 добавил проверку на символ
        15/02/11 id00004 добавил параметр времени для выписки в MT-JDE
        16/11/11 id00004 добавил обработку параметра t-docout.bank_name
        27/12/2011 id00004 добавил переменную для перехода на ИИН-БИН
        16.11.2012 berdibekov - КОд, КБЕ, РНН
        02.01.2013 damir - Переход на ИИН/БИН. Оптимизация кода.
        28.01.2013 damir - <Доработка выписок, выгружаемых в DBF - файл>. Добавил логирование.
*/
run appendText in replyH ("<DOC>").
run appendText in replyH ("<OPER_CODE>" + trim(string(t-docout.oper_code,">>>>>>>>9")) + "</OPER_CODE>").
run appendText in replyH ("<OPER_DATE>" + trim(string(t-docout.date_doc,"99.99.9999")) + "</OPER_DATE>").

if t-docout.num_doc = "" then run appendText in replyH ("<NUM_DOC>-</NUM_DOC>").
else run appendText in replyH ("<NUM_DOC>" + t-docout.num_doc + "</NUM_DOC>").

if t-docout.deal_code = "" then run appendText in replyH ("<DEAL_CODE>-</DEAL_CODE>").
else run appendText in replyH ("<DEAL_CODE>" + t-docout.deal_code + "</DEAL_CODE>").

t-docout.name =  replace(t-docout.name,"&", "&amp;").
t-docout.bank_name = replace(t-docout.bank_name,"&", "&amp;").
t-docout.des = replace(t-docout.des,"&", "&amp;").
t-docout.des = replace(t-docout.des,"<<", "").
t-docout.des = replace(t-docout.des,">>", "").
t-docout.des = replace(t-docout.des,"", "").

if t-docout.date_doc < 05.07.2012 then do:
    t-docout.bank_bic = replace(t-docout.bank_bic,"fobakzka", "MEOKKZKA").
    t-docout.bank_name = replace(t-docout.bank_name,"fortebank", "МЕТРОКОМБАНК").
end.

run appendText in replyH ("<DEAL_TYPE></DEAL_TYPE>").
run appendText in replyH ("<DATE_DOC>" + string(t-docout.date_doc,"99.99.9999") + "</DATE_DOC>").
run appendText in replyH ("<NAME>" + t-docout.name + "</NAME>").
run appendText in replyH ("<ACCOUNT>" + t-docout.account + "</ACCOUNT>").
run appendText in replyH ("<DEBIT>" + trim(string(t-docout.dam,">>>>>>>>>>>9.99")) + "</DEBIT>").
run appendText in replyH ("<CREDIT>" + trim(string(t-docout.cam,">>>>>>>>>>>9.99")) + "</CREDIT>").
run appendText in replyH ("<BANK_BIC>" + t-docout.bank_bic + "</BANK_BIC>").
run appendText in replyH ("<BANK_NAME>" + t-docout.bank_name + "</BANK_NAME>").
run appendText in replyH ("<PAYMENT_DETAILS><![CDATA[" + t-docout.des + "]]></PAYMENT_DETAILS>").
run appendText in replyH ("<CREATE_TIME>" + substr(string(t-docout.tim, "hh:mm:ss"), 1,2) + substr(string(t-docout.tim, "hh:mm:ss"), 4,2) + "</CREATE_TIME>").
run appendText in replyH ("<CREATE_TIME_VGOK>" + string(t-docout.tim, "hh:mm:ss")  + "</CREATE_TIME_VGOK>").
run appendText in replyH ("<KNP>" + t-docout.knp + "</KNP>").
run appendText in replyH ("<KOD>" + t-docout.kod + "</KOD>").
run appendText in replyH ("<KBE>" + t-docout.kbe + "</KBE>").
run appendText in replyH ("<IDN>" + t-docout.rnn + "</IDN>").
run appendText in replyH ("<CURRENCY_CODE>" + t-docout.crc + "</CURRENCY_CODE>").
run appendText in replyH ("<NOMINALE>" + trim(string(t-docout.nominale,">>>>>>>>>>>9.99"))  + "</NOMINALE>").
run appendText in replyH ("</DOC>").

/*run savelog("iovyp", "iovyp.i  <DOC>. ").
run savelog("iovyp", "iovyp.i  <OPER_CODE>. " + trim(string(t-docout.oper_code,">>>>>>>>9"))).
run savelog("iovyp", "iovyp.i  <OPER_DATE>. " + trim(string(t-docout.date_doc,"99.99.9999"))).
run savelog("iovyp", "iovyp.i  <NUM_DOC>. " + t-docout.num_doc).
run savelog("iovyp", "iovyp.i  <DEAL_CODE>. " + t-docout.deal_code).
run savelog("iovyp", "iovyp.i  <DATE_DOC>. " + string(t-docout.date_doc,"99.99.9999")).
run savelog("iovyp", "iovyp.i  <NAME>. " + t-docout.name).
run savelog("iovyp", "iovyp.i  <ACCOUNT>. " + t-docout.account).
run savelog("iovyp", "iovyp.i  <DEBIT>. " + trim(string(t-docout.dam,">>>>>>>>>>>9.99"))).
run savelog("iovyp", "iovyp.i  <CREDIT>. " + trim(string(t-docout.cam,">>>>>>>>>>>9.99"))).
run savelog("iovyp", "iovyp.i  <BANK_BIC>. " + t-docout.bank_bic).
run savelog("iovyp", "iovyp.i  <BANK_NAME>. " + t-docout.bank_name).
run savelog("iovyp", "iovyp.i  <PAYMENT_DETAILS><![CDATA[. " + t-docout.des).
run savelog("iovyp", "iovyp.i  <CREATE_TIME>. " + substr(string(t-docout.tim, "hh:mm:ss"), 1,2) + substr(string(t-docout.tim, "hh:mm:ss"), 4,2)).
run savelog("iovyp", "iovyp.i  <CREATE_TIME_VGOK>. " + string(t-docout.tim, "hh:mm:ss")).
run savelog("iovyp", "iovyp.i  <KNP>. " + t-docout.knp).
run savelog("iovyp", "iovyp.i  <KOD>. " + t-docout.kod).
run savelog("iovyp", "iovyp.i  <KBE>. " + t-docout.kbe).
run savelog("iovyp", "iovyp.i  <IDN>. " + t-docout.rnn).
run savelog("iovyp", "iovyp.i  <CURRENCY_CODE>. " + t-docout.crc).
run savelog("iovyp", "iovyp.i  <NOMINALE>. " + trim(string(t-docout.nominale,">>>>>>>>>>>9.99"))).
run savelog("iovyp", "iovyp.i  </DOC>. ").*/
