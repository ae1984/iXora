/* r-f2.p
 * MODULE
        СБ
 * DESCRIPTION
        Отчет о покупке-продаже иностранной валюты
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-8-2
 * BASES
        BANK COMM
 * AUTHOR
        29/08/2012 dmitriy
 * CHANGES
        05/09/2012 dmitriy - для расшифровки по клиентам добавил столбцы "Наименование счета ДТ" и "Наименование счета КТ"
        24/09/2012 dmitriy - перекомпиляция


*/


{global.i}
def new shared var vn-dt as date     no-undo.
def new shared var vn-dtbeg as date  no-undo.
def new shared var v-jss as char     no-undo.
def new shared var tg1000 as int.
def var v-str as char                no-undo.
def var file1 as char format "x(20)" no-undo.

def new shared temp-table tmp-f2
    field strnum as int
    field nom  as char
    field name as char
    field kod  as integer
    field summ as decimal decimals 2
    field usd  as decimal decimals 2
    field eur  as decimal decimals 2
    field rur  as decimal decimals 2.

def new shared temp-table tmp-f2p2
    field nom  as integer
    field name as char
    field kod  as integer
    field summ as decimal decimals 2
    field tgrez   as decimal decimals 2
    field tgnorez  as decimal decimals 2
    field valrez  as decimal decimals 2
    field valnorez  as decimal decimals 2.

def new shared temp-table tmp-d
    field djh as integer.

def new shared temp-table wrk-shifr1
    field jh as int
    field jdt as date
    field trx as char
    field dr4gl as char
    field drgl-name as char
    field dr20aaa as char
    field dr_crc as char
    field cr4gl as char
    field crgl-name as char
    field cr20aaa as char
    field cr_crc as char
    field kod as int
    field kbe as int
    field knp as int
    field sum_crc as deci
    field sum_tng as deci
    field rem as char
    field buy_rate as deci
    field sell_rate as deci
    field buy_kod as int
    field sell_kod as int
    field buy_kod1 as int
    field sell_kod1 as int
    field txb as char
    field purpose as char.



def var v-tngrank   as logi init yes.
def var v-shifr_dil as logi init no.
def var v-shifr_OP  as logi init no.
def var v-shifr_cln as logi init no.

define frame form2
    vn-dtbeg     format  "99/99/9999"  label  "С"
    vn-dt        format  "99/99/9999"  label  "По"                    skip
    v-tngrank    format  "Да/Нет"      label  "В тыс.тенге/тенге   "  skip
    v-shifr_dil  format  "Да/Нет"      label  "Расшифровка диллинг "  skip
    v-shifr_op   format  "Да/Нет"      label  "Расшифровка ОП      "  skip
    v-shifr_cln  format  "Да/Нет"      label  "Расшифровка клиенты "  skip
with side-labels centered row 15 title "Отчет о покупке/продаже ин.валюты".

function month_name returns char (input parm1 as integer).
    def var res as char.
    case parm1:
        when 1 then res = "январь".
        when 2 then res = "февраль".
        when 3 then res = "март".
        when 4 then res = "апрель".
        when 5 then res = "май".
        when 6 then res = "июнь".
        when 7 then res = "июль".
        when 8 then res = "август".
        when 9 then res = "сентябрь".
        when 10 then res = "октябрь".
        when 11 then res = "ноябрь".
        when 12 then res = "декабрь".
    end case.
    return res.
end function.

create tmp-f2. tmp-f2.strnum = 1.   tmp-f2.nom = "1".    tmp-f2.name = "Покупка иностранной валюты банком".   tmp-f2.kod = 110000.
create tmp-f2. tmp-f2.strnum = 2.   tmp-f2.nom = "2".    tmp-f2.name = "в том числе:".                        tmp-f2.kod = 0.
create tmp-f2. tmp-f2.strnum = 3.   tmp-f2.nom = "3".    tmp-f2.name = "у клиентов банка".                    tmp-f2.kod = 110001.
create tmp-f2. tmp-f2.strnum = 4.   tmp-f2.nom = "4".    tmp-f2.name = "на Казахстанской фондовой бирже".     tmp-f2.kod = 110002.
create tmp-f2. tmp-f2.strnum = 5.   tmp-f2.nom = "'4-1". tmp-f2.name = "на межбанковском рынке".              tmp-f2.kod = 110003.
create tmp-f2. tmp-f2.strnum = 6.   tmp-f2.nom = "'4-2". tmp-f2.name = "у населения через обменные пункты".   tmp-f2.kod = 110004.
create tmp-f2. tmp-f2.strnum = 7.   tmp-f2.nom = "5".    tmp-f2.name = "Продажа иностранной валюты банком".   tmp-f2.kod = 120000.
create tmp-f2. tmp-f2.strnum = 8.   tmp-f2.nom = "6".    tmp-f2.name = "в том числе:".                        tmp-f2.kod = 0.
create tmp-f2. tmp-f2.strnum = 9.   tmp-f2.nom = "7".    tmp-f2.name = "клиентам банка".                      tmp-f2.kod = 120001.
create tmp-f2. tmp-f2.strnum = 10.  tmp-f2.nom = "8".    tmp-f2.name = "на Казахстанской фондовой бирже".     tmp-f2.kod = 120002.
create tmp-f2. tmp-f2.strnum = 11.  tmp-f2.nom = "9".    tmp-f2.name = "на межбанковском рынке".              tmp-f2.kod = 120003.
create tmp-f2. tmp-f2.strnum = 12.  tmp-f2.nom = "10".   tmp-f2.name = "у населения через обменные пункты".   tmp-f2.kod = 120004.



update vn-dtbeg vn-dt v-tngrank v-shifr_dil v-shifr_op v-shifr_cln with frame form2.
assign v-tngrank.

if v-tngrank = yes then tg1000 = 1000.
if v-tngrank =  no then tg1000 = 1.

find first cmp no-lock no-error.


file1 = "r-form2.html".
output to value(file1).
{html-title.i}

put  unformatted
   "<HTML xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"" xmlns="""">" skip
   "<HEAD>"                                       skip
" <!--[if gte mso 9]><xml>"                       skip
" <x:ExcelWorkbook>"                              skip
" <x:ExcelWorksheets>"                            skip
" <x:ExcelWorksheet>"                             skip
" <x:Name>17161</x:Name>"                         skip
" <x:WorksheetOptions>"                           skip
" <x:Selected/>"                                  skip
" <x:DoNotDisplayGridlines/>"                     skip
" <x:TopRowVisible>52</x:TopRowVisible>"          skip
" <x:Panes>"                                      skip
" <x:Pane>"                                       skip
" <x:Number>3</x:Number>"                         skip
" <x:ActiveRow>12</x:ActiveRow>"                  skip
" <x:ActiveCol>24</x:ActiveCol>"                  skip
" </x:Pane>"                                      skip
" </x:Panes>"                                     skip
" <x:ProtectContents>False</x:ProtectContents>"   skip
" <x:ProtectObjects>False</x:ProtectObjects>"     skip
" <x:ProtectScenarios>False</x:ProtectScenarios>" skip
" </x:WorksheetOptions>"                          skip
" </x:ExcelWorksheet>"                            skip
" </x:ExcelWorksheets>"                           skip
" <x:WindowHeight>7305</x:WindowHeight>"          skip
" <x:WindowWidth>14220</x:WindowWidth>"           skip
" <x:WindowTopX>120</x:WindowTopX>"               skip
" <x:WindowTopY>30</x:WindowTopY>"                skip
" <x:ProtectStructure>False</x:ProtectStructure>" skip
" <x:ProtectWindows>False</x:ProtectWindows>"     skip
" </x:ExcelWorkbook>"                             skip
"</xml><![endif]-->"                              skip
"<meta http-equiv=Content-Language content=ru>"   skip.

    put unformatted
        "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""0"" width=""100%"">" skip.
    put unformatted
        "<TR align=""left"" style=""font-size:x-small;"">"
        "<TD></TD><TD></TD><TD></TD><TD></TD><TD></TD>"
        "<TD colspan=""2"">
        Приложение 2<br>к Инструкции о перечне, формах и<br>сроках представления<br>уполномоченными банками<br>отчетности по источникам<br>"
        "спроса и предложения на внутреннем<br>валютном рынке"
        "</TD></TR>".
    put unformatted
        "<TR align=""center"" style=""font-size:small"">"
        "<tr></tr>"
        "<TD colspan=""7"" align=""center"">Форма 2. Отчет о покупке/продаже иностранной валюты банком и его клиентами </TD>"
        "<TR></TR>"
        "</TR>"
        "<TR><TD colspan=""3"" align=""center"" >" cmp.name "</TD>"
        "<TD></TD><TD></TD>"
        "<TD colspan=""2"">за <u>" month_name(month(vn-dtbeg)) "</u> " string(year(vn-dtbeg)) "</TD>"
        "</TR>"
        "<TR style=""font-size:x-small;""><TD colspan=""3"" align=""center"" >(наименование уполномоченного банка)</TD>"
        "<TD></TD><TD></TD>"
        "<TD colspan=""2"">&nbsp&nbsp&nbsp&nbsp&nbsp(месяц)</TD>"
        "</TR>"
        "<TR></TR>"
        "<TD colspan=""7"" align=""center""> Раздел 1. Операции банка с " vn-dtbeg format "99.99.9999" " по " vn-dt format "99.99.9999" "</TD></TR>"
        "<tr></tr>"
        "</TABLE>".

    put unformatted
        "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
        "<TR align=""center"" style=""font-size:x-small;"">" skip
        "<TD rowspan=""2"">№</TD>"     skip
        "<TD rowspan=""2"">Наименование показателя </TD>" skip
        "<TD rowspan=""2"">Код строки</TD>"     skip
        "<TD rowspan=""2"">Всего (тысяч тенге)</TD>"     skip
        "<TD colspan=""3"">из них по видам валют<br>(тысяч единиц иностранной валюты)</TD>"
        "</TR><TR align=""center"">"
        "<TD>USD</TD>"     skip
        "<TD>EUR</TD>"     skip
        "<TD>RUB</TD></TR>".


    put unformatted
        "<TR align=""center"" style=""font-size:x-small;"">" skip
        "<TD>A</TD>"     skip
        "<TD>Б</TD>"     skip
        "<TD>В</TD>"     skip
        "<TD>1</TD>"     skip
        "<TD>2</TD>"     skip
        "<TD>3</TD>"     skip
        "<TD>4</TD>"     skip.

   {r-branch.i &proc = "r-f2p1"}
/*if cmp.cod <> 0 then do:
    find first comm.txb where comm.txb.consolid = true and comm.txb.city = cmp.cod no-lock no-error.
    if avail comm.txb then do:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run r-f2p1.
    end.
    if connected ("txb") then disconnect "txb".
    if connected ("comm") then disconnect "comm".
end.
else do:
    for each comm.txb where comm.txb.consolid = true no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run r-f2p1.
    end.
    if connected ("txb") then disconnect "txb".
    if connected ("comm") then disconnect "comm".
end.*/

def buffer btmp-f2 for tmp-f2.

find first tmp-f2 where tmp-f2.kod = 110000 no-lock no-error.
if avail tmp-f2 then do:
    for each btmp-f2 where btmp-f2.kod > 110000 and btmp-f2.kod < 120000 no-lock:
        if  btmp-f2.usd +  btmp-f2.eur +  btmp-f2.rur > 0 then do:
            tmp-f2.usd = tmp-f2.usd + btmp-f2.usd.
            tmp-f2.eur = tmp-f2.eur + btmp-f2.eur.
            tmp-f2.rur = tmp-f2.rur + btmp-f2.rur.
            tmp-f2.summ = tmp-f2.summ + btmp-f2.summ.
        end.
    end.
end.

find first tmp-f2 where tmp-f2.kod = 120000 no-lock no-error.
if avail tmp-f2 then do:
    for each btmp-f2 where btmp-f2.kod > 120000 no-lock:
        if  btmp-f2.usd +  btmp-f2.eur +  btmp-f2.rur > 0 then do:
            tmp-f2.usd = tmp-f2.usd + btmp-f2.usd.
            tmp-f2.eur = tmp-f2.eur + btmp-f2.eur.
            tmp-f2.rur = tmp-f2.rur + btmp-f2.rur.
            tmp-f2.summ = tmp-f2.summ + btmp-f2.summ.
        end.
    end.
end.


for each tmp-f2 break by tmp-f2.strnum:
    put unformatted
        "<TR align=""center"" style=""font-size:x-small;"">" skip
        "<TD>" tmp-f2.nom  "</TD>" skip
        "<TD align=""left"">" tmp-f2.name "</TD>" skip.
if tmp-f2.kod <> 0 then
    put unformatted
        "<TD>" tmp-f2.kod   "</TD>" skip
        "<TD>" tmp-f2.summ  "</TD>" skip
        "<TD>" tmp-f2.usd   "</TD>" skip
        "<TD>" tmp-f2.eur   "</TD>" skip
        "<TD>" tmp-f2.rur   "</TD>" skip.
else
    put unformatted "<TD></TD>" skip "<TD></TD>" skip "<TD></TD>" skip "<TD></TD>" skip "<TD></TD>" skip.

end.



create tmp-f2p2. tmp-f2p2.kod = 210000. tmp-f2p2.nom = 1.  tmp-f2p2.name = "Покупка иностранной валюты клиентами банка".
create tmp-f2p2. tmp-f2p2.kod = 0.      tmp-f2p2.nom = 2.  tmp-f2p2.name = "в том числе:".
create tmp-f2p2. tmp-f2p2.kod = 211000. tmp-f2p2.nom = 3.  tmp-f2p2.name = "физическими лицами, включая зарегистрированных в качестве <br> хозяйствующих субъектов без образования юридического лица".
create tmp-f2p2. tmp-f2p2.kod = 211400. tmp-f2p2.nom = 4.  tmp-f2p2.name = "из них зачислено на собственные банковские счета <br> клиентов в иностранной валюте".
create tmp-f2p2. tmp-f2p2.kod = 212000. tmp-f2p2.nom = 5.  tmp-f2p2.name = "юридическими лицами".
create tmp-f2p2. tmp-f2p2.kod = 212400. tmp-f2p2.nom = 6.  tmp-f2p2.name = "из них зачислено на собственные банковские счета <br> клиентов в иностранной валюте".
create tmp-f2p2. tmp-f2p2.kod = 0.      tmp-f2p2.nom = 7.  tmp-f2p2.name = "в том числе для целей:".
create tmp-f2p2. tmp-f2p2.kod = 212409. tmp-f2p2.nom = 8.  tmp-f2p2.name = "проведения обменных операций с наличной иностранной валютой".
create tmp-f2p2. tmp-f2p2.kod = 212410. tmp-f2p2.nom = 9.  tmp-f2p2.name = "осуществления платежей и переводов денег в пользу резидентов".
create tmp-f2p2. tmp-f2p2.kod = 0.      tmp-f2p2.nom = 10. tmp-f2p2.name = "в том числе по операциям:".
create tmp-f2p2. tmp-f2p2.kod = 212411. tmp-f2p2.nom = 11. tmp-f2p2.name = "покупка товаров и нематериальных активов".
create tmp-f2p2. tmp-f2p2.kod = 212412. tmp-f2p2.nom = 12. tmp-f2p2.name = "получение услуг".
create tmp-f2p2. tmp-f2p2.kod = 212413. tmp-f2p2.nom = 13. tmp-f2p2.name = "выдача займов".
create tmp-f2p2. tmp-f2p2.kod = 212414. tmp-f2p2.nom = 14. tmp-f2p2.name = "выполнение обязательств по займам".
create tmp-f2p2. tmp-f2p2.kod = 212415. tmp-f2p2.nom = 15. tmp-f2p2.name = "расчеты по операциям с ценными бумагами".
create tmp-f2p2. tmp-f2p2.kod = 212416. tmp-f2p2.nom = 16. tmp-f2p2.name = "размещение на срочных вкладах на срок более 3 месяцев".
create tmp-f2p2. tmp-f2p2.kod = 212417. tmp-f2p2.nom = 17. tmp-f2p2.name = "прочее".
create tmp-f2p2. tmp-f2p2.kod = 212420. tmp-f2p2.nom = 18. tmp-f2p2.name = "осуществление платежей и переводов денег в пользу нерезидентов".
create tmp-f2p2. tmp-f2p2.kod = 0.      tmp-f2p2.nom = 19. tmp-f2p2.name = "в том числе по операциям:".
create tmp-f2p2. tmp-f2p2.kod = 212421. tmp-f2p2.nom = 20. tmp-f2p2.name = "покупка товаров и нематериальных активов".
create tmp-f2p2. tmp-f2p2.kod = 212422. tmp-f2p2.nom = 21. tmp-f2p2.name = "получение услуг".
create tmp-f2p2. tmp-f2p2.kod = 212423. tmp-f2p2.nom = 22. tmp-f2p2.name = "выдача займов".
create tmp-f2p2. tmp-f2p2.kod = 212424. tmp-f2p2.nom = 23. tmp-f2p2.name = "выполнение обязательств по займам ".
create tmp-f2p2. tmp-f2p2.kod = 212425. tmp-f2p2.nom = 24. tmp-f2p2.name = "расчеты по операциям с ценными бумагами".
create tmp-f2p2. tmp-f2p2.kod = 212426. tmp-f2p2.nom = 25. tmp-f2p2.name = "размещение на срочных вкладах на срок более 3 месяцев".
create tmp-f2p2. tmp-f2p2.kod = 212427. tmp-f2p2.nom = 26. tmp-f2p2.name = "прочее".
create tmp-f2p2. tmp-f2p2.kod = 220000. tmp-f2p2.nom = 27. tmp-f2p2.name = "Продажа иностранной валюты клиентами банка".
create tmp-f2p2. tmp-f2p2.kod = 0.      tmp-f2p2.nom = 28. tmp-f2p2.name = "в том числе:".
create tmp-f2p2. tmp-f2p2.kod = 221000. tmp-f2p2.nom = 29. tmp-f2p2.name = "физическими лицами, включая зарегистрированных в качестве хозяйствующих субъектов без образования юридического лица".
create tmp-f2p2. tmp-f2p2.kod = 221400. tmp-f2p2.nom = 30. tmp-f2p2.name = "из них зачислено на собственные банковские счета клиентов в национальной валюте".
create tmp-f2p2. tmp-f2p2.kod = 222000. tmp-f2p2.nom = 31. tmp-f2p2.name = "юридическими лицами".
create tmp-f2p2. tmp-f2p2.kod = 222400. tmp-f2p2.nom = 32. tmp-f2p2.name = "из них зачислено на собственные банковские счета клиентов в национальной валюте".


    put unformatted
        "<TABLE><tr></tr>
        <tr align=""center""> <td colspan=""8"">Раздел 2. Операции клиентов банка</td></tr>"
        "</table>" skip.
    put unformatted
        "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
        "<TR align=""center"" style=""font-size:x-small;"">"
            "<TD rowspan=""4"">№</TD>"
            "<TD rowspan=""4"">Наименование показателя </TD>"
            "<TD rowspan=""4"">Код строки</TD>"
            "<TD rowspan=""4"">Всего</TD>"
            "<TD colspan=""4"">в том числе</TD>"
        "</TR>"
        "<TR align=""center"" valign=""top"" style=""font-size:x-small;"">"
            "<TD colspan=""2"">за тенге</TD>"
            "<TD colspan=""2"">за другую иностранную <br> валюту</TD>"
        "</TR>"
        "<TR align=""center"" style=""font-size:x-small;"">"
            "<TD colspan=""4"">клиентами банка</TD>"
        "</TR>"
        "<TR align=""center"" style=""font-size:x-small;"">"
            "<TD>резидентами </TD>"
            "<TD>нерезидентами</TD>"
            "<TD>резидентами</TD>"
            "<TD>нерезидентами</TD>"
        "</TR>".


    put unformatted
        "<TR align=""center"" style=""font-size:x-small;"">" skip
        "<TD>A</TD>"     skip
        "<TD>Б</TD>"     skip
        "<TD>В</TD>"     skip
        "<TD>1</TD>"     skip
        "<TD>2</TD>"     skip
        "<TD>3</TD>"     skip
        "<TD>4</TD>"     skip
        "<TD>5</TD>"     skip.

if cmp.cod <> 0 then do:
    find first comm.txb where comm.txb.consolid = true and comm.txb.city = cmp.cod no-lock no-error.
    if avail comm.txb then do:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run r-f2p2.
    end.
    if connected ("txb") then disconnect "txb".
    if connected ("comm") then disconnect "comm".
end.
else do:
    for each comm.txb where comm.txb.consolid = true no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run r-f2p2.
    end.
    if connected ("txb") then disconnect "txb".
    if connected ("comm") then disconnect "comm".
end.


for each tmp-f2p2 /*break by tmp-f2p2.nom*/ no-lock:
    if tmp-f2p2.kod <> 0 then
    put unformatted
        "<TR align=""center"" style=""font-size:x-small;"">"
        "<TD>" tmp-f2p2.nom      "</TD>"
        "<TD>" tmp-f2p2.name     "</TD>"
        "<TD>" tmp-f2p2.kod      "</TD>"
        "<TD>" replace(string(tmp-f2p2.summ ), '.',',')    "</TD>"
        "<TD>" replace(string(tmp-f2p2.tgrez), '.',',')    "</TD>"
        "<TD>" replace(string(tmp-f2p2.tgnorez), '.',',')  "</TD>"
        "<TD>" replace(string(tmp-f2p2.valrez), '.',',')   "</TD>"
        "<TD>" replace(string(tmp-f2p2.valnorez), '.',',') "</TD></TR>".
    else
    put unformatted
        "<TR align=""center"" style=""font-size:x-small;"">"
        "<TD>" tmp-f2p2.nom      "</TD>"
        "<TD>" tmp-f2p2.name     "</TD>"
        "<td></td><td></td><td></td><td></td><td></td></TR>".

end.


{html-end.i " "}
output close.
unix silent cptwin value(file1) excel.

run r-transcript.

hide frame form2.


procedure r-transcript:
    if v-shifr_dil = yes then run r-dealing.
    if v-shifr_OP  = yes then run r-OP.
    if v-shifr_cln = yes then run r-client.
end procedure. /* r-transcript*/



procedure r-dealing: /* на момент сдачи ТЗ сделки по диллингу в Иксоре не автоматизированы */

    file1 = "r-dealing.html".
    output to value(file1).
    {html-title.i}

    put  unformatted
       "<HTML xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"" xmlns="""">" skip
       "<HEAD>"                                       skip
    " <!--[if gte mso 9]><xml>"                       skip
    " <x:ExcelWorkbook>"                              skip
    " <x:ExcelWorksheets>"                            skip
    " <x:ExcelWorksheet>"                             skip
    " <x:Name>17161</x:Name>"                         skip
    " <x:WorksheetOptions>"                           skip
    " <x:Selected/>"                                  skip
    " <x:DoNotDisplayGridlines/>"                     skip
    " <x:TopRowVisible>52</x:TopRowVisible>"          skip
    " <x:Panes>"                                      skip
    " <x:Pane>"                                       skip
    " <x:Number>3</x:Number>"                         skip
    " <x:ActiveRow>12</x:ActiveRow>"                  skip
    " <x:ActiveCol>24</x:ActiveCol>"                  skip
    " </x:Pane>"                                      skip
    " </x:Panes>"                                     skip
    " <x:ProtectContents>False</x:ProtectContents>"   skip
    " <x:ProtectObjects>False</x:ProtectObjects>"     skip
    " <x:ProtectScenarios>False</x:ProtectScenarios>" skip
    " </x:WorksheetOptions>"                          skip
    " </x:ExcelWorksheet>"                            skip
    " </x:ExcelWorksheets>"                           skip
    " <x:WindowHeight>7305</x:WindowHeight>"          skip
    " <x:WindowWidth>14220</x:WindowWidth>"           skip
    " <x:WindowTopX>120</x:WindowTopX>"               skip
    " <x:WindowTopY>30</x:WindowTopY>"                skip
    " <x:ProtectStructure>False</x:ProtectStructure>" skip
    " <x:ProtectWindows>False</x:ProtectWindows>"     skip
    " </x:ExcelWorkbook>"                             skip
    "</xml><![endif]-->"                              skip
    "<meta http-equiv=Content-Language content=ru>"   skip.

    put unformatted
        "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""0"" width=""100%"">"
        "<TR align=""center"">Расшифровка ДИЛЛИНГ</tr>"
        "</TABLE>".

    put unformatted
        "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
        "<TR align=""center"" style=""font-size:x-small;"">"
        "<TD>№ транзакции</TD>"
        "<TD>Дата транзакции</TD>"
        "<TD>Шаблон транзакции</TD>"
        "<TD>Контрагент</TD>"
        "<TD>Куплено</TD>"
        "<TD>Курс покупки</TD>"
        "<TD>Куплено <br> (эквивалент в тенге)</TD>"
        "<TD>Валюта покупки</TD>"
        "<TD>Продано</TD>"
        "<TD>Курс продажи</TD>"
        "<TD>Продано <br> (эквивалент в тенге)</TD>"
        "<TD>Валюта продажи</TD>"
        "<TD>КНП</TD>"
        "<TD>Назначение <br> транзакции</TD>"
        "<TD>Код строки <br> (покупка)</TD>"
        "<TD>Код строки <br> (продажа)</TD>"
        "</TR>".


    put unformatted
        "<TR align=""center"" style=""font-size:x-small;"">"
        "<TD>1</TD>"
        "<TD>2</TD>"
        "<TD>3</TD>"
        "<TD>4</TD>"
        "<TD>5</TD>"
        "<TD>6</TD>"
        "<TD>7</TD>"
        "<TD>8</TD>"
        "<TD>9</TD>"
        "<TD>10</TD>"
        "<TD>11</TD>"
        "<TD>12</TD>"
        "<TD>13</TD>"
        "<TD>14</TD>"
        "<TD>15</TD>"
        "<TD>16</TD>"
        "</TR>".



    {html-end.i " "}
    output close.
    unix silent cptwin value(file1) excel.
end procedure. /* r-dealing */



procedure r-OP:

    file1 = "r-OP.html".
    output to value(file1).
    {html-title.i}

    put  unformatted
       "<HTML xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"" xmlns="""">" skip
       "<HEAD>"                                       skip
    " <!--[if gte mso 9]><xml>"                       skip
    " <x:ExcelWorkbook>"                              skip
    " <x:ExcelWorksheets>"                            skip
    " <x:ExcelWorksheet>"                             skip
    " <x:Name>17161</x:Name>"                         skip
    " <x:WorksheetOptions>"                           skip
    " <x:Selected/>"                                  skip
    " <x:DoNotDisplayGridlines/>"                     skip
    " <x:TopRowVisible>52</x:TopRowVisible>"          skip
    " <x:Panes>"                                      skip
    " <x:Pane>"                                       skip
    " <x:Number>3</x:Number>"                         skip
    " <x:ActiveRow>12</x:ActiveRow>"                  skip
    " <x:ActiveCol>24</x:ActiveCol>"                  skip
    " </x:Pane>"                                      skip
    " </x:Panes>"                                     skip
    " <x:ProtectContents>False</x:ProtectContents>"   skip
    " <x:ProtectObjects>False</x:ProtectObjects>"     skip
    " <x:ProtectScenarios>False</x:ProtectScenarios>" skip
    " </x:WorksheetOptions>"                          skip
    " </x:ExcelWorksheet>"                            skip
    " </x:ExcelWorksheets>"                           skip
    " <x:WindowHeight>7305</x:WindowHeight>"          skip
    " <x:WindowWidth>14220</x:WindowWidth>"           skip
    " <x:WindowTopX>120</x:WindowTopX>"               skip
    " <x:WindowTopY>30</x:WindowTopY>"                skip
    " <x:ProtectStructure>False</x:ProtectStructure>" skip
    " <x:ProtectWindows>False</x:ProtectWindows>"     skip
    " </x:ExcelWorkbook>"                             skip
    "</xml><![endif]-->"                              skip
    "<meta http-equiv=Content-Language content=ru>"   skip.

    put unformatted
        "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""0"" width=""100%"">"
        "<TR align=""center"">Расшифровка ОП</tr>"
        "</TABLE>".

    put unformatted
        "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
        "<TR align=""center"" valign=""top"">"
        "<TD rowspan=""2"">Филиал</TD>"
        "<TD rowspan=""2"">№ транзакции</TD>"
        "<TD rowspan=""2"">Дата транзакции</TD>"
        "<TD rowspan=""2"">Шаблон <br> транзакции</TD>"
        "<TD rowspan=""2"">Счет ДТ <br> 4-х значный</TD>"
        "<TD rowspan=""2"">Счет ДТ <br> 20-ти значный</TD>"
        "<TD rowspan=""2"">Валюта <br> Дт</TD>"
        "<TD rowspan=""2"">Счет КТ <br> 4-х значный</TD>"
        "<TD rowspan=""2"">Счет КТ <br> 20-ти значный</TD>"
        "<TD rowspan=""2"">Валюта <br> Кт</TD>"
        "<TD rowspan=""2"">КОД</TD>"
        "<TD rowspan=""2"">КБЕ</TD>"
        "<TD rowspan=""2"">КНП</TD>"
        "<TD rowspan=""2"">Сумма <br> транзакции <br> в номинале</TD>"
        "<TD rowspan=""2"">Сумма <br> транзакции <br> в эквиваленте (в тенге)</TD>"
        "<TD rowspan=""2"">Назначение транзакции</TD>"
        "<TD rowspan=""2"">Курс <br> покупки/продажи <br> (ин.валюты) <br> в ОП</TD>"
        "<TD rowspan=""2"">Средневзвешенные курсы</TD>"
        /*"<TD rowspan=""2"">Курс продажи <br> (ин.валюты) <br> в ОП</TD>"*/
        "<TD colspan=""2"">раздел 1</TD>"
        "</TR>"
        "<TR align=""center"">"
        "<TD>Код <br> строки <br> (покупка)</TD>"
        "<TD>Код <br> строки <br> (продажа)</TD>"
        "</TR>".


    put unformatted
        "<TR align=""center"" style=""font-size:x-small;"">"
        "<TD>0</TD>"
        "<TD>1</TD>"
        "<TD>2</TD>"
        "<TD>3</TD>"
        "<TD>4</TD>"
        "<TD>5</TD>"
        "<TD>6</TD>"
        "<TD>7</TD>"
        "<TD>8</TD>"
        "<TD>9</TD>"
        "<TD>10</TD>"
        "<TD>11</TD>"
        "<TD>12</TD>"
        "<TD>13</TD>"
        "<TD>14</TD>"
        "<TD>15</TD>"
        "<TD>16</TD>"
        "<TD>17</TD>"
        "<TD>18</TD>"
        "<TD>19</TD>"
        "</TR>".

    for each wrk-shifr1 where (wrk-shifr1.dr4gl = '1001' or wrk-shifr1.dr4gl = '1005') and wrk-shifr1.cr4gl = '1858' break by wrk-shifr1.jh:
        put unformatted
            "<TR>"
            "<TD>" wrk-shifr1.txb "</TD>"
            "<TD>" wrk-shifr1.jh "</TD>"
            "<TD>" wrk-shifr1.jdt "</TD>"
            "<TD>" wrk-shifr1.trx "</TD>"
            "<TD>" wrk-shifr1.dr4gl "</TD>"
            "<TD>" wrk-shifr1.dr20aaa "</TD>"
            "<TD>" wrk-shifr1.dr_crc "</TD>"
            "<TD>" wrk-shifr1.cr4gl "</TD>"
            "<TD>" wrk-shifr1.cr20aaa "</TD>"
            "<TD>" wrk-shifr1.cr_crc "</TD>"
            "<TD>" wrk-shifr1.kod "</TD>"
            "<TD>" wrk-shifr1.kbe "</TD>"
            "<TD>" wrk-shifr1.knp "</TD>"
            "<TD>" replace(string(wrk-shifr1.sum_crc),".",",") "</TD>"
            "<TD>" replace(string(wrk-shifr1.sum_tng),".",",") "</TD>"
            "<TD>" wrk-shifr1.rem "</TD>"
            "<TD>" replace(string(wrk-shifr1.buy_rate),".",",") "</TD>"
            "<TD>" replace(string(wrk-shifr1.sell_rate),".",",") "</TD>"
            "<TD>" wrk-shifr1.buy_kod "</TD>"
            "<TD>" wrk-shifr1.sell_kod "</TD>"
            "</TR>".
    end.


    {html-end.i " "}
    output close.
    unix silent cptwin value(file1) excel.
end procedure. /* r-OP */




procedure r-client:

    file1 = "r-client.html".
    output to value(file1).
    {html-title.i}

    put  unformatted
       "<HTML xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"" xmlns="""">" skip
       "<HEAD>"                                       skip
    " <!--[if gte mso 9]><xml>"                       skip
    " <x:ExcelWorkbook>"                              skip
    " <x:ExcelWorksheets>"                            skip
    " <x:ExcelWorksheet>"                             skip
    " <x:Name>17161</x:Name>"                         skip
    " <x:WorksheetOptions>"                           skip
    " <x:Selected/>"                                  skip
    " <x:DoNotDisplayGridlines/>"                     skip
    " <x:TopRowVisible>52</x:TopRowVisible>"          skip
    " <x:Panes>"                                      skip
    " <x:Pane>"                                       skip
    " <x:Number>3</x:Number>"                         skip
    " <x:ActiveRow>12</x:ActiveRow>"                  skip
    " <x:ActiveCol>24</x:ActiveCol>"                  skip
    " </x:Pane>"                                      skip
    " </x:Panes>"                                     skip
    " <x:ProtectContents>False</x:ProtectContents>"   skip
    " <x:ProtectObjects>False</x:ProtectObjects>"     skip
    " <x:ProtectScenarios>False</x:ProtectScenarios>" skip
    " </x:WorksheetOptions>"                          skip
    " </x:ExcelWorksheet>"                            skip
    " </x:ExcelWorksheets>"                           skip
    " <x:WindowHeight>7305</x:WindowHeight>"          skip
    " <x:WindowWidth>14220</x:WindowWidth>"           skip
    " <x:WindowTopX>120</x:WindowTopX>"               skip
    " <x:WindowTopY>30</x:WindowTopY>"                skip
    " <x:ProtectStructure>False</x:ProtectStructure>" skip
    " <x:ProtectWindows>False</x:ProtectWindows>"     skip
    " </x:ExcelWorkbook>"                             skip
    "</xml><![endif]-->"                              skip
    "<meta http-equiv=Content-Language content=ru>"   skip.

    put unformatted
        "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""0"" width=""100%"">"
        "<TR align=""center"">Расшифровка КЛИЕНТЫ</tr>"
        "</TABLE>".

    put unformatted
        "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
        "<TR align=""center"" style=""font-size:x-small;"">"
        "<TD rowspan=""2"">Филиал</TD>"
        "<TD rowspan=""2"">№ транзакции</TD>"
        "<TD rowspan=""2"">Дата транзакции</TD>"
        "<TD rowspan=""2"">Шаблон транзакции</TD>"
        "<TD rowspan=""2"">Счет ДТ 4-х значный</TD>"
        "<TD rowspan=""2"">Наименование счета ДТ</TD>"
        "<TD rowspan=""2"">Счет ДТ 20-ти значный</TD>"
        "<TD rowspan=""2"">Валюта Дт</TD>"
        "<TD rowspan=""2"">Счет КТ 4-х значный</TD>"
        "<TD rowspan=""2"">Наименование счета КТ</TD>"
        "<TD rowspan=""2"">Счет КТ 20-ти значный</TD>"
        "<TD rowspan=""2"">Валюта Кт</TD>"
        "<TD rowspan=""2"">КОД</TD>"
        "<TD rowspan=""2"">КБЕ</TD>"
        "<TD rowspan=""2"">КНП</TD>"
        "<TD rowspan=""2"">Сумма транзакции в номинале</TD>"
        "<TD rowspan=""2"">Сумма транзакции в эквиваленте (в тенге)</TD>"
        "<TD rowspan=""2"">Цель покупки валюты</TD>"
        "<TD rowspan=""2"">Назначение транзакции</TD>"
        "<TD colspan=""2"">раздел 1</TD>"
        "<TD colspan=""2"">раздел 2</TD>"
        "</TR>"
        "<TR>"
        "<TD>Код <br> строки <br> (покупка)</TD>"
        "<TD>Код <br> строки <br> (продажа)</TD>"
        "<TD>Код <br> строки <br> (покупка)</TD>"
        "<TD>Код <br> строки <br> (продажа)</TD>"
        "</TR>".

    put unformatted
        "<TR align=""center"" style=""font-size:x-small;"">"
        "<TD>1</TD>"
        "<TD>2</TD>"
        "<TD>3</TD>"
        "<TD>4</TD>"
        "<TD>5</TD>"
        "<TD>6</TD>"
        "<TD>7</TD>"
        "<TD>8</TD>"
        "<TD>9</TD>"
        "<TD>10</TD>"
        "<TD>11</TD>"
        "<TD>12</TD>"
        "<TD>13</TD>"
        "<TD>14</TD>"
        "<TD>15</TD>"
        "<TD>16</TD>"
        "<TD>17</TD>"
        "<TD>18</TD>"
        "<TD>19</TD>"
        "<TD>20</TD>"
        "</TR>".

    for each wrk-shifr1 where wrk-shifr1.dr4gl <> '1001' and wrk-shifr1.dr4gl <> '1005' break by wrk-shifr1.jh:
        put unformatted
            "<TR>"
            "<TD>" wrk-shifr1.txb "</TD>"
            "<TD>" wrk-shifr1.jh "</TD>"
            "<TD>" wrk-shifr1.jdt "</TD>"
            "<TD>" wrk-shifr1.trx "</TD>"
            "<TD>" wrk-shifr1.dr4gl "</TD>"
            "<TD>" wrk-shifr1.drgl-name "</TD>"
            "<TD>" wrk-shifr1.dr20aaa "</TD>"
            "<TD>" wrk-shifr1.dr_crc "</TD>"
            "<TD>" wrk-shifr1.cr4gl "</TD>"
            "<TD>" wrk-shifr1.crgl-name "</TD>"
            "<TD>" wrk-shifr1.cr20aaa "</TD>"
            "<TD>" wrk-shifr1.cr_crc "</TD>"
            "<TD>" wrk-shifr1.kod "</TD>"
            "<TD>" wrk-shifr1.kbe "</TD>"
            "<TD>" wrk-shifr1.knp "</TD>"
            "<TD>" replace(string(wrk-shifr1.sum_crc),".",",") "</TD>"
            "<TD>" replace(string(wrk-shifr1.sum_tng),".",",") "</TD>"
            "<TD>" wrk-shifr1.purpose "</TD>"
            "<TD>" wrk-shifr1.rem "</TD>"
            /*"<TD>" replace(string(wrk-shifr1.buy_rate),".",",") "</TD>"*/
            "<TD>" wrk-shifr1.buy_kod "</TD>"
            "<TD>" wrk-shifr1.sell_kod "</TD>"
            "<TD>" wrk-shifr1.buy_kod1 "</TD>"
            "<TD>" wrk-shifr1.sell_kod1 "</TD>"
            "</TR>".
    end.

    {html-end.i " "}
    output close.
    unix silent cptwin value(file1) excel.
end procedure. /* r-client */
