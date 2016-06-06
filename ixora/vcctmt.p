/* vcctmt.p
 * MODULE
        Название модуля - Автоматическое формирование карточки по нарушению.
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        24.07.2012 damir - добавил nbankBik.i, изменение формата Приложения,выводимого в WORD.
        06.09.2012 damir - перекомпиляция.
*/

{global.i}

{chbin.i} /*Переход на БИН и ИИН*/
{nbankBik.i}

def shared var s-contract like vccontrs.contract.
def shared var s-cif      like vccontrs.cif.

def var v-uninum     as inte init 0.
def var v-cardrdt    as date init ?.
def var v-priznak    as char init "N".
def var v-codenar    as char init "".
def var v-dtvaloper  as date init ?.
def var v-sumvaloper as deci init 0.
def var v-crcoper    as char init "".
def var v-crcdes     as char init "".

def var i         as inte init 0.
def var v-temp    as char init "".
def var v-cifname as char init "" no-undo.
def var v-okpobin as char init "" no-undo.
def var v-rnniin  as char init "" no-undo.
def var v-urfiz   as char init "" no-undo.
def var v-address as char init "" no-undo.
def var v-region  as char init "" no-undo.
def var v-desnar  as char init "" no-undo.
def var v-ctnum   as char init "" no-undo.
def var v-ctdate  as date init ?  no-undo.
def var v-month   as char no-undo init "".
def var v-year    as char no-undo init "".
def var v-sel     as inte no-undo init 0.
def var v-sel2    as char no-undo init "".
def var v-bank    as char no-undo init "".
def var repname   as char init "1.htm".

def stream rep.
output stream rep to value(repname).

def temp-table t-sts
    field code as inte
    field name as char.

def temp-table t-codespr
    field code as char
    field name as char.

def temp-table t-crc
    field code as inte
    field name as char.

def temp-table t-temp
    field code as inte
    field name as char
    field nums as char
    field des  as char
    index idx is primary code ascending.

form
    v-uninum     label "Номер" format "9999999999" skip
    v-cardrdt    label "Дата" format "99/99/9999" skip
    v-priznak    label "Признак по нарушению" validate(v-priznak = "D" or v-priznak = "N","Признак выбранный вами не существует!!!")
    help "Выберите нажав клавишу (F2)" skip
    v-codenar    label "Код вида нарушения" help "Выберите нажав клавишу (F2)" skip
    v-dtvaloper  label "Дата валютной операции" format "99/99/9999" skip
    v-sumvaloper label "Сумма валютной операции" format ">>>>>>>>>>>>>>>>>>>>>>>>>9.99" skip
    v-crcdes     label "Валюта операции" format "x(3)" help "Выберите нажав клавишу (F2)" skip
with side-labels row 20 centered overlay frame cardmt.

find first cif where cif.cif = s-cif no-lock no-error.
if avail cif then do:
    v-cifname = cif.name + " " + cif.prefix.
    if trim(cif.type) = "B" then do:
        v-urfiz = "1".
        if v-bin = yes then v-okpobin = cif.bin.
        else v-okpobin = cif.ssn.
    end.
    else if trim(cif.type) = "P" then do:
        v-urfiz = "2".
        if v-bin = yes then v-rnniin = cif.bin.
        else v-rnniin = cif.jss.
    end.
    v-address = cif.addr[1] + ", " + cif.addr[2].
    find first sub-cod where sub-cod.acc = s-cif and sub-cod.sub = "cln" and sub-cod.d-cod = "regionkz" no-lock no-error.
    if avail sub-cod then do:
        v-region = sub-cod.ccode.
    end.
end.

find first vccontrs where vccontrs.contract = s-contract no-lock no-error.
if avail vccontrs then do:
    v-ctnum  = vccontrs.ctnum.
    v-ctdate = vccontrs.ctdate.
end.

do i = 1 to 2:
    create t-sts.
    t-sts.code = i.
    if i = 1 then t-sts.name = "<N> - новая".
    if i = 2 then t-sts.name = "<D> - действующая".
end.

for each codfr where codfr.codfr = "vcmsg115" no-lock:
    create t-codespr.
    assign
    t-codespr.code = trim(codfr.code)
    t-codespr.name = codfr.name[1].
end.

for each ncrc no-lock:
    create t-crc.
    assign
    t-crc.code = ncrc.crc
    t-crc.name = ncrc.code.
end.

on help of v-priznak in frame cardmt do:
    v-temp = "".
    if v-temp = "" then do:
        for each t-sts no-lock:
            if v-temp <> "" then v-temp = v-temp + " |".
            v-temp = v-temp + string(t-sts.code) + " " + t-sts.name.
        end.
    end.
    run sel2 (" Выберите признак карточки по нарушению", v-temp, output v-sel).
    if v-sel <> 0 then do:
        if v-sel = 1 then v-priznak = "N".
        else if v-sel = 2 then v-priznak = "D".
        displ v-priznak with frame cardmt.
    end.
end.

on help of v-codenar in frame cardmt do:
    v-temp = "".
    if v-temp = "" then do:
        for each t-codespr no-lock:
            if v-temp <> "" then v-temp = v-temp + " |".
            v-temp = v-temp + string(t-codespr.code) + " " + t-codespr.name.
        end.
    end.
    run sel4 (" Выберите код вида нарушения", v-temp, output v-sel2).
    if v-sel2 <> "" then do:
        v-codenar = v-sel2.
        displ v-codenar with frame cardmt.
    end.
end.

on help of v-crcdes in frame cardmt do:
    v-temp = "".
    if v-temp = "" then do:
        for each t-crc no-lock:
            if v-temp <> "" then v-temp = v-temp + " |".
            v-temp = v-temp + string(t-crc.code) + " " + t-crc.name.
        end.
    end.
    run sel4 (" Выберите признак лицевой карточки", v-temp, output v-sel2).
    if v-sel2 <> "" then do:
        v-crcoper = v-sel2.
        find first ncrc where ncrc.crc = integer(trim(v-crcoper)) no-lock no-error.
        if avail ncrc then v-crcdes = ncrc.code.
        displ v-crcdes with frame cardmt.
    end.
end.


i = 0.
for each vccardnar where vccardnar.contract = s-contract no-lock break by vccardnar.uninum:
    i = i + 1.
end.

v-cardrdt = g-today.
displ v-cardrdt with frame cardmt.
update v-priznak with frame cardmt.
update v-codenar with frame cardmt.

find first codfr where codfr.codfr = "vcmsg115" and codfr.code = trim(v-codenar) no-lock no-error.
if avail codfr then v-desnar = codfr.name[1].

if v-codenar <> "" then do:
    update v-dtvaloper with frame cardmt.
    update v-sumvaloper with frame cardmt.
    update v-crcdes with frame cardmt.
end.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if avail sysc then v-bank = trim(sysc.chval).

do transaction:
    v-uninum = next-value(vc-mtdocs).
    displ v-uninum with frame cardmt.
    create vccardnar.
    assign
    vccardnar.contract   = s-contract
    vccardnar.uninum     = v-uninum
    vccardnar.rdt        = today
    vccardnar.dndate     = v-cardrdt
    vccardnar.priznak    = v-priznak
    vccardnar.codetype   = integer(trim(v-codenar))
    vccardnar.dtvaloper  = v-dtvaloper
    vccardnar.sumvaloper = v-sumvaloper
    vccardnar.crcoper    = integer(trim(v-crcoper))
    vccardnar.bank       = v-bank
    vccardnar.whn        = g-today
    vccardnar.who        = g-ofc.
end.

do i = 1 to 14:
    create t-temp.
    t-temp.code = i.
    if i = 1 then do:
        t-temp.name = "Наименование (для юридических лиц) ФИО (для физических лиц)".
        t-temp.nums = "11".
        if v-cifname <> "" then t-temp.des = v-cifname.
    end.
    if i = 2 then do:
        t-temp.name = "БИН/ОКПО (для юридических лиц)".
        t-temp.nums = "12".
        if v-okpobin <> "" then t-temp.des = v-okpobin.
    end.
    if i = 3 then do:
        t-temp.name = "ИИН (для физических лиц)".
        t-temp.nums = "13".
        if v-rnniin <> "" then t-temp.des = v-rnniin.
    end.
    if i = 4 then do:
        t-temp.name = "Признак клиента: 1 - юридическое лицо / 2 - физическое лицо".
        t-temp.nums = "14".
        if v-urfiz <> "" then t-temp.des = v-urfiz.
    end.
    if i = 5 then do:
        t-temp.name = "Адрес".
        t-temp.nums = "15".
        if v-address <> "" then t-temp.des = v-address.
    end.
    if i = 6 then do:
        t-temp.name = "Код области".
        t-temp.nums = "16".
        if v-region <> "" then t-temp.des = v-region.
    end.
    if i = 7 then do:
        t-temp.name = "Дата".
        t-temp.nums = "21".
        if v-dtvaloper <> ? then t-temp.des = string(v-dtvaloper,"99/99/9999").
    end.
    if i = 8 then do:
        t-temp.name = "Сумма".
        t-temp.nums = "22".
        if v-sumvaloper <> 0 then t-temp.des = string(v-sumvaloper / 1000,">>>>>>>>>>>9.99").
    end.
    if i = 9 then do:
        t-temp.name = "Валюта".
        t-temp.nums = "23".
        if v-crcdes <> "" then t-temp.des = v-crcdes.
    end.
    if i = 10 then do:
        t-temp.name = "Вид".
        t-temp.nums = "31".
        if v-codenar <> "" then t-temp.des = trim(v-codenar).
    end.
    if i = 11 then do:
        t-temp.name = "Описание нарушения".
        t-temp.nums = "32".
        if v-desnar <> "" then t-temp.des = v-desnar.
    end.
    if i = 12 then do:
        t-temp.name = "Номер контракта".
        t-temp.nums = "33".
        if v-ctnum <> "" then t-temp.des = v-ctnum.
    end.
    if i = 13 then do:
        t-temp.name = "Дата контракта".
        t-temp.nums = "34".
        if v-ctdate <> ? then t-temp.des = string(v-ctdate,"99/99/9999").
    end.
    if i = 14 then do:
        t-temp.name = "Дополнительные сведения".
        t-temp.nums = "35".
    end.
end.

if month(g-today) - 1 = 1       then v-month = "январь".
else if month(g-today) - 1 = 2  then v-month = "февраль".
else if month(g-today) - 1 = 3  then v-month = "март".
else if month(g-today) - 1 = 4  then v-month = "апрель".
else if month(g-today) - 1 = 5  then v-month = "май".
else if month(g-today) - 1 = 6  then v-month = "июнь".
else if month(g-today) - 1 = 7  then v-month = "июль".
else if month(g-today) - 1 = 8  then v-month = "август".
else if month(g-today) - 1 = 9  then v-month = "сентябрь".
else if month(g-today) - 1 = 10 then v-month = "октябрь".
else if month(g-today) - 1 = 11 then v-month = "ноябрь".
else if month(g-today) - 1 = 12 then v-month = "декабрь".

if month(g-today) - 1 = 0 then v-year = string(year(g-today) - 1,"9999").
else v-year = string(year(g-today),"9999").

put stream rep unformatted
    "<P align=""right""><FONT size=2> Приложение 1 <br> к Правилам осуществления <br> валютных операций <br> в Республике Казахстан </P>" skip
    "<P align=""center"">Карточка по нарушению № " string(v-uninum,"9999999999") " <br> отчетный месяц " v-month " год " v-year "</P>" skip
    "<P align=""left"">Наименование уполномоченного банка &nbsp;&nbsp;" v-ful_bnk_ru "</FONT></P>" skip.

put stream rep unformatted
    "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip.

put stream rep unformatted
    "<TR align=""center""><FONT size=2>" skip
    /*"<TD>№</TD>" skip*/
    "<TD width=""5%"">Код <br> строки</TD>" skip
    "<TD width=""42%"">Вид информации</TD>" skip
    "<TD width=""42%"">Информация по <br> нарушению</TD>" skip
    "</FONT></TR>" skip
    "<TR align=""center""><FONT size=2>" skip
    /*"<TD></TD>" skip*/
    "<TD>10</TD>" skip
    "<TD><B>Информация по клиенту банка:</B></TD>" skip
    "<TD></TD>" skip
    "</FONT></TR>" skip.

for each t-temp where t-temp.code >= 1 and t-temp.code <= 6 no-lock use-index idx:
    put stream rep unformatted
        "<TR align=center><FONT size=2>" skip
        /*"<TD align=center>" t-temp.code "</TD>" skip*/
        "<TD>" t-temp.nums "</TD>" skip
        "<TD>" t-temp.name "</TD>" skip
        "<TD>" t-temp.des  "</TD>" skip
        "</FONT></TR>" skip.
end.

put stream rep unformatted
   "<TR align=center><FONT size=2>" skip
   /*"<TD></TD>" skip*/
   "<TD>20</TD>" skip
   "<TD><B>Информация по валютной операции:</B></TD>" skip
   "<TD></TD>" skip
   "</FONT></TR>" skip.

for each t-temp where t-temp.code >= 7 and t-temp.code <= 9 no-lock use-index idx:
    put stream rep unformatted
        "<TR align=center><FONT size=2>" skip
        /*"<TD align=center>" t-temp.code "</TD>" skip*/
        "<TD>" t-temp.nums "</TD>" skip
        "<TD>" t-temp.name "</TD>" skip
        "<TD>" t-temp.des  "</TD>" skip
        "</FONT></TR>" skip.
end.

put stream rep unformatted
   "<TR align=center><FONT size=2>" skip
   /*"<TD></TD>" skip*/
   "<TD>20</TD>" skip
   "<TD><B>Информация по нарушению:</B></TD>" skip
   "<TD></TD>" skip
   "</FONT></TR>" skip.

for each t-temp where t-temp.code >= 10 and t-temp.code <= 14 no-lock use-index idx:
    put stream rep unformatted
        "<TR align=center><FONT size=2>" skip
        /*"<TD>" t-temp.code "</TD>" skip*/
        "<TD>" t-temp.nums "</TD>" skip
        "<TD>" t-temp.name "</TD>" skip
        "<TD>" t-temp.des  "</TD>" skip
        "</FONT></TR>" skip.
end.

put stream rep unformatted
    "</TABLE>" skip.

output stream rep close.

unix silent cptwin value(repname) winword.