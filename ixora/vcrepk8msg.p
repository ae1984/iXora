/* vcrepk8msg.p
 * MODULE
        Название модуля
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
        28.05.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
        16.07.2012 damir - подкинул, добавил vcmtform.i, новые форматы МТ 106.
        05.03.2013 damir - Внедрено Т.З. № 1713.
*/


{vc.i}
{global.i}
{vcmtform.i}
{vcrepk8var.i}

def var v-dir as char.
def var v-ipaddr as char.
def var v-exitcod as char.
def var v-text as char.
def var v-filename as char.
def var v-filename0 as char init "vcmsg.txt".
def var v-name as char.
def var v-stroka as char.

/* проверка валидности данных */
def var v-errmsg as char extent 6 init
  ["Найдены клиенты с отсутствующим кодом ОКПО/БИН!",
   "Найдены клиенты с отсутствующей ФОРМОЙ СОБСТВЕННОСТИ!",
   "Найдены клиенты с отсутствующим НАИМЕНОВАНИЕМ!",
   "Найдены контракты с отсутствующим НОМЕРОМ КОНТРАКТА!",
   "Найдены контракты с отсутствующим НАИМЕНОВАНИЕМ ИНОПАРТНЕРА!",
   "Найдены клиенты с отсутствующим КОДОМ РЕГИОНА!"].

def temp-table t-errs
  field type as integer
  field bank as char
  field depart as char
  field cif as char
  field prefix as char
  field name as char
  field ctdate as date
  field ctnum as char
  field partner as char
  index main is primary type bank depart cif ctdate ctnum.

def var v-err as integer.
def var v-data as logi initial yes.
def var v-chk as logi initial no.

for each wrkTemp:
    v-err = 0.
    if wrkTemp.bin = "" then v-err = 1.
    else if wrkTemp.prefix = "" then v-err = 2.
    else if wrkTemp.cname = "" then v-err = 3.
    else if wrkTemp.ctnum = "" then v-err = 4.
    else if wrkTemp.partner = "" then v-err = 5.
    else if wrkTemp.obl = "" then v-err = 6.
end.
if v-err > 0 then do:
    for each wrkTemp no-lock:
        create t-errs.
        assign
        t-errs.type = v-err
        t-errs.bank = wrkTemp.bank
        t-errs.cif = wrkTemp.cif
        t-errs.prefix = wrkTemp.prefix
        t-errs.name = wrkTemp.cname
        t-errs.ctdate = wrkTemp.ctdate
        t-errs.ctnum = wrkTemp.ctnum
        t-errs.partner = trim(trim(wrkTemp.partner)).
    end.
end.

def stream err.

if can-find(first t-errs) then do:
    output stream err to err.htm.
    {html-title.i &title = " " &stream = "stream err" &size-add = "x-"}
    put stream err unformatted
    "<TABLE width=""100%"" align=""center"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip
    "<TR align=""center"" style=""font:bold;font-size=xx-small"">" skip
    "<TD>Банк</TD>"
    "<TD>Департамент</TD>"
    "<TD>Код клиента</TD>"
    "<TD>Форма собств. клиента</TD>"
    "<TD>Наименование клиента</TD>"
    "<TD>Дата контракта</TD>"
    "<TD>Номер контракта</TD>"
    "<TD>Инопартнер</TD>"
    "</TR>" skip.
    for each t-errs break by t-errs.type:
        if first-of(t-errs.type) then
        put stream err unformatted
        "<TR><TD colspan=""8"">&nbsp;</TD></TR>" skip
        "<TR><TD colspan=""8"" style=""font:bold;font-size=small"">" v-errmsg[t-errs.type] "</TD></TR>" skip.

        put stream err unformatted
        "<TR>"
        "<TD>" t-errs.bank "</TD>"
        "<TD>" t-errs.depart "</TD>"
        "<TD>" t-errs.cif "</TD>"
        "<TD>" t-errs.prefix "</TD>"
        "<TD>" t-errs.name "</TD>"
        "<TD>" t-errs.ctdate "</TD>"
        "<TD>" t-errs.ctnum "</TD>"
        "<TD>" t-errs.partner "</TD>"
        "</TR>" skip.
    end.
    put stream err unformatted "</TABLE>" skip.
    {html-end.i &stream = "stream err"}
    output stream err close.
    message skip " Обнаружены критические ошибки в данных !"
            skip " Смотрите протокол ошибок."
            skip(1) " Телеграмма не сформирована !"
            skip(1) view-as alert-box button ok title " ВНИМАНИЕ ! ".
    /*unix silent cptwin err.htm iexplore.*/
    /*return.*/
end.

/* формирование телеграммы */
/* путь к каталогу исходящих телеграмм */

find vcparams where vcparams.parcode = "mtpathou" no-lock no-error.
if not avail vcparams then do:
    message skip " Не найден параметр mtpathou !"
    skip(1) view-as alert-box button ok title " ОШИБКА ! ".
    return.
end.

v-dir = vcparams.valchar.
v-ipaddr = "Administrator@fs01.metrobank.kz".

/*v-dir = "C:/VC106/".
v-ipaddr = "Administrator@`askhost`".*/

if substr(v-dir, length(v-dir), 1) <> "/" then v-dir = v-dir + "/".
v-dir = v-dir + substr(string(year(g-today), "9999"), 3, 2) + string(month(g-today), "99") +
string(day(g-today), "99") + "/".

/* проверка существования каталога за сегодняшнее число */
output to sendtest.
put "Ok".
output close .

input through value("scp -q sendtest " + v-ipaddr + ":" + v-dir + ";echo $?" ).
repeat :
    import v-exitcod.
end.

unix silent rm -f sendtest.

if v-exitcod <> "0" then do :
    message skip " Не найден каталог " + replace(v-dir, "/", "\\")
    skip(1) view-as alert-box button ok title " ОШИБКА ! ".
    return.
end.

/*находим ОКПО уполномоченного банка*/
find first cmp no-lock no-error.


for each wrkTemp no-lock:
    if wrkTemp.amti > 100000 or wrkTemp.amte > 100000 then do:
        v-chk = yes.
        {vcmsgparam_new.i &msg = "106"}

        v-text = "/REPORTMONTH/" + string(v-month, "99") + string(v-god, "9999").
        put stream rpt unformatted v-text skip.

        if v-bin = no then do:
            v-text = "/BANKOKPO/" + trim(cmp.addr[3]).
            put stream rpt unformatted v-text skip.
        end.

        if v-bin = yes then do:
            if v-MTviewbi = yes then do:
                v-text = "/BANKOKPO/".
                put stream rpt unformatted v-text skip.

                if wrkTemp.bbin <> "" then do:
                    v-text = "/BANKBIN/" + wrkTemp.bbin.
                    put stream rpt unformatted v-text skip.
                end.
                else do:
                    v-text = "/BANKBIN/".
                    put stream rpt unformatted v-text skip.
                end.
            end.
            else do:
                v-text = "/BANKOKPO/" + trim(cmp.addr[3]).
                put stream rpt unformatted v-text skip.

                v-text = "/BANKBIN/".
                put stream rpt unformatted v-text skip.
            end.
        end.

        v-text = "/NAME/" + substr(wrkTemp.cname, 1, 100).
        put stream rpt unformatted v-text skip.

        if wrkTemp.ctype = "1" then do:
            if length(wrkTemp.okpo) < 12 then wrkTemp.okpo = wrkTemp.okpo + fill("0", 12 - length(wrkTemp.okpo)).

            if v-bin = no then do:
                v-text = "//OKPO/" + wrkTemp.okpo.
                put stream rpt unformatted v-text skip.

                v-text = "//RNN/".
                put stream rpt unformatted v-text skip.
            end.

            if v-bin = yes then do:
                if v-MTviewbi = yes then do:
                    v-text = "//OKPO/".
                    put stream rpt unformatted v-text skip.

                    v-text = "//RNN/".
                    put stream rpt unformatted v-text skip.

                    if wrkTemp.bin <> "" then do:
                        v-text = "//BIN/" + wrkTemp.bin.
                        put stream rpt unformatted v-text skip.
                    end.
                    else do:
                        v-text = "//BIN/".
                        put stream rpt unformatted v-text skip.
                    end.

                    v-text = "//IIN/".
                    put stream rpt unformatted v-text skip.
                end.
                else do:
                    v-text = "//OKPO/" + wrkTemp.okpo.
                    put stream rpt unformatted v-text skip.

                    v-text = "//RNN/".
                    put stream rpt unformatted v-text skip.

                    v-text = "//BIN/".
                    put stream rpt unformatted v-text skip.

                    v-text = "//IIN/".
                    put stream rpt unformatted v-text skip.
                end.
            end.

            v-text = "//SIGN/"  + "1".
            put stream rpt unformatted v-text skip.
        end.

        else if wrkTemp.ctype = "2" then do:
            if v-bin = no then do:
                v-text = "//OKPO/".
                put stream rpt unformatted v-text skip.

                v-text = "//RNN/" + wrkTemp.rnn.
                put stream rpt unformatted v-text skip.
            end.

            if v-bin = yes then do:
                if v-MTviewbi = yes then do:
                    v-text = "//OKPO/".
                    put stream rpt unformatted v-text skip.

                    v-text = "//RNN/".
                    put stream rpt unformatted v-text skip.

                    v-text = "//BIN/".
                    put stream rpt unformatted v-text skip.

                    if wrkTemp.bin <> "" then do:
                        v-text = "//IIN/" + wrkTemp.bin.
                        put stream rpt unformatted v-text skip.
                    end.
                    else do:
                        v-text = "//IIN/".
                        put stream rpt unformatted v-text skip.
                    end.
                end.
                else do:
                    v-text = "//OKPO/".
                    put stream rpt unformatted v-text skip.

                    v-text = "//RNN/" + wrkTemp.rnn.
                    put stream rpt unformatted v-text skip.

                    v-text = "//BIN/".
                    put stream rpt unformatted v-text skip.

                    v-text = "//IIN/".
                    put stream rpt unformatted v-text skip.
                end.
            end.

            v-text = "//SIGN/"  + "2".
            put stream rpt unformatted v-text skip.
        end.

        v-text = "//ADDRESS/" + wrkTemp.adr.
        put stream rpt unformatted v-text skip.

        v-text = "//REGION/" + wrkTemp.obl.
        put stream rpt unformatted v-text skip.

        if wrkTemp.expimp = "E" then v-text = "1".
        else v-text = "2".
        v-text = "/EISIGN/" + v-text.
        put stream rpt unformatted v-text skip.

        if wrkTemp.expimp = "e" then v-text = "2".
        else v-text = "1".
        v-text = "//INOUT/" + v-text.
        put stream rpt unformatted v-text skip.

        v-text = "//PFORM/" + substr(wrkTemp.prefix, 1, 10).
        put stream rpt unformatted v-text skip.

        if wrkTemp.expimp = "E" then
        v-text = "//PSUMM/" + replace(trim(string(wrkTemp.amte, "->>>>>>>>>>>>>>9.99")),".",",").
        if wrkTemp.expimp = "I" then
        v-text = "//PSUMM/" + replace(trim(string(wrkTemp.amti, "->>>>>>>>>>>>>>9.99")),".",",").
        put stream rpt unformatted v-text skip.

        v-text = "/NOTE/".
        put stream rpt unformatted v-text skip.
        {vcmsgend.i &msg = "106"}
    end.
end.
if v-chk = no then do:
    {vcmsgparam_new.i &msg = "106"}

    v-text = "/REPORTMONTH/" + string(v-month, "99") + string(v-god, "9999").
    put stream rpt unformatted v-text skip.

    if v-bin = no then do:
        v-text = "/BANKOKPO/" + trim(cmp.addr[3]).
        put stream rpt unformatted v-text skip.
    end.

    if v-bin = yes then do:
        if v-MTviewbi = yes then do:
            v-text = "/BANKOKPO/".
            put stream rpt unformatted v-text skip.

            find first sysc where sysc.sysc = "bnkbin" no-lock no-error.
            if avail sysc then v-text = "/BANKBIN/" + sysc.chval.
            put stream rpt unformatted v-text skip.
        end.
        else do:
            v-text = "/BANKOKPO/" + trim(cmp.addr[3]).
            put stream rpt unformatted v-text skip.

            v-text = "/BANKBIN/".
            put stream rpt unformatted v-text skip.
        end.
    end.

    {vcmsgend.i &msg = "106"}
end.