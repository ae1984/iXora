/* vcrepdout.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        18.05.2004 nadejda - добавлены поля РНН и ОКПО клиента
*/

/* vcrepdout.i Валютный контроль
   Вывод в HTML отчета по задолжникам

   19.12.2002 nadejda
*/
/*07,02,11    Дамир - удаление поля ОКПО
              Добавление столбцов Номер ЛКБК, Дата ЛКБК
              Изменил "ПРОСРОЧКА 180 дней" на "СРОКИ РЕПАТРИАЦИИ" и вывел.
  11,02,11    Дамир - закоментил не нужный сотлбец  "<TD align=""left"">" + t-dolgs.lcnum + "</TD>" skip
  15.02.2011  damir - номер и дата ЛКБК отображаются, которые были сформированы в МТ105
  23,02,2011  damir - строка 113 t-dolgs.cif <> "" то.есть клиентов которые не проходят условие не выводить
  25.02.2011  damir - закоментил 117,118 строки
  03.02.2011  damir - вытащил t-dolgs.namefil из for each
  31.03.2011  damir - выходила ошибка на боевой из стр.54
*/
{sum2strd.i}

def var v-srok as char.
def var v-ncrccod like ncrc.code.
def var v-koldep as integer.
def var v-kolall as integer.
def var v-sumdep as deci.
def var v-sumall as deci.
def var v-numcif as integer.
def var v-numkon as integer.
def var v-psnum as char.
def var v-psnumnum as integer.
def var v-maxdays as integer.
def var v-column as integer.
def var v-colminus as integer.
def var v-cardnum as char.
def var v-carddt as date.
/*def var v-name like ppoint.name.*/
def var v-ctei as int.
def var v-sts as char.

v-column = 12.

if {&sumdolg} then v-column = v-column + 1.
if {&cln} then v-colminus = 2.
if {&ei} then v-column = v-column + 1.


find vcparams where vcparams.parcode = "dayerror" no-lock no-error.
if avail vcparams then v-maxdays = vcparams.valinte.
else v-maxdays = 120.

put stream vcrpt unformatted
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>КЛИЕНТЫ-ЗАДОЛЖНИКИ ПО " skip
   v-title skip
   "<BR>на " + string(v-dte, "99/99/9999") +
   "<BR>по контрактам с " + string(v-dtb, "99/99/9999") + "</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip.

put stream vcrpt unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""1""><B>N</B></FONT></TD>" skip
    /* временно
    "<TD><FONT size=""1""><B>N</B></FONT></TD>" skip*/
    "<TD><FONT size=""1""><B>Код клиента</B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Наименование клиента</B></FONT></TD>" skip
    /*"<TD><FONT size=""1""><B>ОКПО</B></FONT></TD>" skip*/
    "<TD><FONT size=""1""><B>РНН</B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Номер контракта</B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Дата контракта</B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Паспорт сделки</B></FONT></TD>" skip.

if {&ei} then put stream vcrpt unformatted
    "<TD><FONT size=""1""><B>Код экспорта (1)<br>или импорта (2)</B></FONT></TD>" skip.

put stream vcrpt unformatted
    "<TD><FONT size=""1""><B>Вал. кон.</B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Сумма задолженности<BR>в валюте контракта</B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Сумма задолженности<BR>в USD</B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Дни задолж-ти</B></FONT></TD>" skip
    /*"<TD><FONT size=""1""><B>" if {&days120} then "&nbsp;" else "Просроч.?<BR>(" + string(v-maxdays) + " дней)" "</B></FONT></TD>" skip.*/
    "<TD><FONT size=""1""><B>СРОКИ РЕПАТРИАЦИИ</B></FONT></TD>" skip.
if {&sumdolg} then do:
    put stream vcrpt unformatted
    "<TD><FONT size=""1""><B>Сумма просроченная<BR>в USD</B></FONT></TD>" skip.
end.
put stream vcrpt unformatted
    /*"<TD><FONT size=""1""><B>{&rslccell}</B></FONT></TD>" skip*/
    "<TD><FONT size=""1""><B>Статус<BR>конт</B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Номер<B>ЛКБК</B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Дата<BR>ЛКБК</B></FONT></TD>" skip
    "</TR>" skip.
/* сумма просроченных платежей */
v-sumall = 0.
v-kolall = 0.
/* не будем учитывать долги < 1 USD */


for each t-dolgs where t-dolgs.sumusd >= 1 and t-dolgs.cif <> ""
break by t-dolgs.depart by t-dolgs.cifname by t-dolgs.cif by t-dolgs.ctdate
by t-dolgs.ctnum by t-dolgs.contract:



    /*find first  t-dolgs where t-dolgs.sumusd >= 1 and t-dolgs.cif <> "" no-lock no-error.
    if avail t-dolgs then*/
    put stream vcrpt unformatted
        "<TR valign=""top"">" skip
        "<TD colspan="""v-column """ align=""left""><FONT size=""2""><B>"  t-dolgs.namefil  "</B><FONT></TD></TR>" skip.

    /*if first-of(t-dolgs.depart) then do:*/
        /*find first txb.ppoint where txb.ppoint.depart = t-dolgs.depart no-lock no-error.
        if avail txb.ppoint then v-name = txb.ppoint.name. else v-name = "".*/
        /*put stream vcrpt unformatted
        "<TR valign=""top"">" skip
        "<TD colspan="""v-column """ align=""left""><FONT size=""2""><B>"  t-dolgs.namefil  "</B><FONT></TD></TR>" skip.*/
        v-numcif = 0.
        /* сумма просроченных платежей по департаменту */
        v-sumdep = 0.
        v-koldep = 0.
    /*end.*/
    /*временно
    if first-of(t-dolgs.cif) then do:
    v-numcif = v-numcif + 1.
    put stream vcrpt unformatted
    "<TR valign=""top"">" skip
    "<TD align=""left""><B>" string(v-numcif) "</B></TD>" skip
    "<TD colspan=""" v-column - 1 - v-colminus """ align=""left""><B>" + t-dolgs.cifname + " (" + caps(t-dolgs.cif) + ")</B></TD>" skip.
    if {&cln} then
    put stream vcrpt unformatted
    "<TD align=""left""><B>РНН " t-dolgs.cifrnn "</B></TD>" skip
    "<TD align=""left""><B>ОКПО " t-dolgs.cifokpo "</B></TD>" skip.
    put stream vcrpt unformatted
    "</TR>" skip.
    v-numkon = 0.
    end.*/

    v-numkon = v-numkon + 1.

    /* временно */
    put stream vcrpt unformatted
        "<TR valign=""top"">" skip
        "<TD align=""left""><B>" string(v-numkon) "</B></TD>" skip
        "<TD align=""center""><B>" caps(t-dolgs.cif) "</B></TD>" skip
        "<TD align=""left""><B>" t-dolgs.cifname "</B></TD>" skip.
    if {&cln} then put stream vcrpt unformatted
        /*"<TD align=""left""><B>" t-dolgs.cifokpo "</B></TD>" skip*/
        "<TD align=""left""><B>" t-dolgs.cifrnn "</B></TD>" skip.
    else put stream vcrpt unformatted "<TD align=""left""><B> &nbsp; </B></TD>" skip.
    find first vcps where vcps.contract = t-dolgs.contract and vcps.dntype = "01" no-lock no-error.
    if avail vcps then do:
        v-psnum = vcps.dnnum.
        v-psnumnum = vcps.num.
    end.
    else do:
    v-psnum = "отсутствует &nbsp;".
    end.
    find ncrc where ncrc.crc = t-dolgs.ncrc no-lock no-error.
    if avail ncrc then v-ncrccod = ncrc.code.
    else v-ncrccod = "&nbsp;".
    /*if t-dolgs.days > v-maxdays then do:
    if {&days120} then v-srok = "&nbsp;".
    else v-srok = "*".
    v-sumdep = v-sumdep + t-dolgs.sumdolg.
    v-koldep = v-koldep + 1.
    end.
    else v-srok = "&nbsp;". */
    find vccontrs where vccontrs.contract = t-dolgs.contract no-lock no-error.
    if avail vccontrs then v-sts = vccontrs.sts.
    put stream vcrpt unformatted
        /* временно
        "<TR valign=""top"">" skip
        "<TD>&nbsp;</TD>" skip
        "<TD align=""left"">" + string(v-numkon) + "</TD>" skip*/
        "<TD align=""left"">" + t-dolgs.ctnum + "</TD>" skip.
    if t-dolgs.ctdate <> ? then
    put stream vcrpt unformatted
        "<TD align=""left"">" + string(t-dolgs.ctdate, "99/99/9999") + "</TD>" skip.
    else
    put stream vcrpt unformatted
        "<TD align=""left"">&nbsp;</TD>" skip.
    put stream vcrpt unformatted
        "<TD align=""left"">"  v-psnum + string(v-psnumnum) + "," + " " + "N" + " " + string(v-psnumnum) "</TD>" skip.
    if {&ei} then do:
        if t-dolgs.ctei = "E" then v-ctei = 1.
        else v-ctei = 2.
        put stream vcrpt unformatted
            "<TD align=""center"">" v-ctei   "</TD>" skip.
    end.
    else put stream vcrpt unformatted "<TD align=""left""><B> &nbsp; </B></TD>" skip.
    put stream vcrpt unformatted
        "<TD align=""center"">" + v-ncrccod + "</TD>" skip
        "<TD align=""right"">" + sum2strd(t-dolgs.sumcon, 2) + "</TD>" skip
        "<TD align=""right"">" + sum2strd(t-dolgs.sumusd, 2) + "</TD>" skip
        "<TD align=""center"">" + sum2strd(decimal(t-dolgs.days), 0) + "</TD>" skip
        /*"<TD align=""center"">" + v-srok + "</TD>" skip.*/
        "<TD align=""center"">" substr(t-dolgs.ctterm,1,3) + "." + substr(t-dolgs.ctterm,4,5) "</TD>" skip.
    if {&sumdolg} then
    put stream vcrpt unformatted
        "<TD align=""right"">" + sum2strd(t-dolgs.sumdolg, 2) + "</TD>" skip.
    put stream vcrpt unformatted
        /*"<TD align=""left"">" + t-dolgs.lcnum + "</TD>" skip*/
        "<TD align=""center"">" + v-sts + "</TD>" skip
        "<TD>&nbsp;" t-dolgs.cardnum "</TD>" skip
        "<TD>&nbsp;" t-dolgs.carddt "</TD>" skip
        "</TR>" skip.
    accumulate t-dolgs.sumusd  (total count by t-dolgs.depart).
    accumulate t-dolgs.sumdolg (total count by t-dolgs.depart).
    if last-of(t-dolgs.depart) then do:
        put stream vcrpt unformatted
            "<TR valign=""top"">" skip
            "<TD colspan=""5""><FONT size=""2""><B>Всего (колич/сумма)</B></FONT></TD>" skip
            "<TD align=""right""><FONT size=""2""><B>" +
            sum2strd(decimal(accum sub-count by t-dolgs.depart t-dolgs.sumusd), 0) + "</B><FONT></TD>" skip
            "<TD colspan=""2"" align=""right""><FONT size=""2""><B>" +
            sum2strd(accum sub-total by t-dolgs.depart t-dolgs.sumusd, 2) + "</B><FONT></TD>" skip
            "<TD colspan=""" v-column - 8 """>&nbsp;</TD></TR>" skip
            "<TR valign=""top"">" skip
            "<TD colspan=""5""><FONT size=""2""><B>Всего просроч. (колич/сумма)</B></FONT></TD>" skip
            "<TD align=""right""><FONT size=""2""><B>" + sum2strd(decimal(v-koldep), 0) + "</B><FONT></TD>" skip
            "<TD colspan=""2"" align=""right""><FONT size=""2""><B>" + sum2strd(v-sumdep, 2) + "</B><FONT></TD>" skip
            "<TD>&nbsp;" v-column - 8 "</TD></TR>" skip.
            /*"<TD>&nbsp;" v-column "</TD>" skip*/
            v-sumall = v-sumall + v-sumdep.
            v-kolall = v-kolall + v-koldep.
    end.
end.
put stream vcrpt unformatted
    "<TR valign=""top"">" skip
    "<TD colspan=""5""><FONT size=""2""><B>ВСЕГО ПО БАНКУ (колич/сумма)</B></FONT></TD>" skip
    "<TD align=""right""><FONT size=""2""><B>" +
    sum2strd(decimal(accum count t-dolgs.sumusd), 0) + "</B><FONT></TD>" skip
    "<TD colspan=""2"" align=""right""><FONT size=""2""><B>" + sum2strd(accum total t-dolgs.sumusd, 2) + "</B><FONT></TD>" skip
    "<TD colspan=""" v-column - 8 """>&nbsp;</TD></TR>" skip
    "<TR valign=""top"">" skip
    "<TD colspan=""5""><FONT size=""2""><B>ВСЕГО ПРОСРОЧ. (колич/сумма)</B></FONT></TD>" skip
    "<TD align=""right""><FONT size=""2""><B>" + sum2strd(decimal(v-kolall), 0) + "</B><FONT></TD>" skip
    "<TD colspan=""2"" align=""right""><FONT size=""2""><B>" + sum2strd(v-sumall, 2) + "</B><FONT></TD>" skip
    "<TD colspan=""" v-column - 8 """>&nbsp;</TD></TR>" skip
    "<TR><TD colspan=""" v-column """>&nbsp;</TD></TR>" skip.
put stream vcrpt unformatted
    "</TABLE>" skip
    "<BR><BR>" skip.
find first cmp no-lock no-error.
put stream vcrpt unformatted
    "<P><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><B>" skip
cmp.name skip.
find sysc where sysc.sysc = "vc-dep" no-lock no-error.
if avail sysc then
put stream vcrpt unformatted
    "<BR><BR>" + entry(1, sysc.chval) + "<BR>" + entry(2, sysc.chval) skip.
put stream vcrpt unformatted
    "</B></FONT></P>" skip.
{html-end.i}


