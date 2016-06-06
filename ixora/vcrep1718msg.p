/* vcrep1718msg.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Приложение 17 и 18 - все платежи за месяц по контрактам типа 2
        Вывод временной таблицы в файл
 * RUN

 * CALLER
        vcrep1718.p
 * SCRIPT

 * INHERIT

 * MENU
        15-5-4, 15-4-x-5, 15-4-x-6
 * AUTHOR
        19.11.2002 nadejda
 * BASES
         BANK COMM
 * CHANGES
        19.03.2003 nadejda  - теперь формируется не текстовый файл, а файл телеграммы с копированием на L:\CAPITAL
        18.01.2004 nadejda  - добавлены код региона, адрес и вид платежа в соответствии с новым форматом сообщения МТ-106
        07.06.2005 saltanat - добавлен Признак содержания нулевых показателей NREPORT.
        11.04.2008 galina   - добавлено поле cursdoc-usd в таблицу t-docs;
                            добавлена временная таблица t-docs_total;
                            выводится результирующая сумма платежа по контрактам, если она превышает 50000$
                            одно сообщение содержит одну сумму
        14.04.2008 galina   - перекомпиляция в связи с добавлением vcmsgparam_new.i
        06.05.2008 galina   - вывод ОКПО банка и даты отчета в пустом сообщении
        06.06.2008 galina   - заменить наименование поля REPORTDATE на REPORTMONTH
        29/10/2009 galina   -  заменила общую сумму с 50000 на 100000
        03/11/2010 galina   - не выводим ошибки по платежам, которые не попадают в конечное сообщение
        5/01/2010  aigul    -  поменяла REGION CODE на REGION согласно формату МТ106
        05.04.2011 damir    - добавлены во временной t-docs bin,iin,bnkbin
                            стр.122, если что поменять при тестировании.
        28.04.2011 damir    - поставлены ключи. процедура chbin.i
        05.07.2012 damir    - добавил vcmtform.i, переход на форматы с БИН и ИИН только они пустые, поле //INOUT/.
*/

{vc.i}
{global.i}

{vcmtform.i} /*переход на БИН и ИИН*/

/***/
def var v-dir       as char.
def var v-ipaddr    as char.
def var v-exitcod   as char.
def var v-text      as char.
def var v-filename  as char.
def var v-filename0 as char init "vcmsg.txt".
/***/
def shared var v-god   as integer format "9999".
def shared var v-month as integer format "99".

def shared temp-table t-docs
    field dndate        as date
    field sum           as deci
    field payret        as logi
    field docs          as inte
    field paykind       as char
    field cif           as char
    field prefix        as char
    field name          as char
    field okpo          as char
    field clnsts        as char
    field region        as char
    field addr          as char
    field ctnum         as char
    field ctdate        as date
    field cttype        as char
    field partnprefix   as char
    field partner       as char
    field codval        as char
    field info          as char
    field strsum        as char
    field bank          as char
    field depart        as char
    field cursdoc-usd   as deci
    field bnkbin        as char
    field bin           as char
    field iin           as char
    index main is primary cttype dndate payret sum docs.

def temp-table t-docs_total
    field cif      as char
    field cttype   as char
    field totalsum as deci
    index main is primary cif cttype.

def var v-totalsum  as inte.
def var v-name      as char.
def var v-stroka    as char.

/* проверка валидности данных */

def var v-errmsg as char extent 6 init
  ["Найдены клиенты с отсутствующим кодом ОКПО!",
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

/**заполнение таблицы с общей суммой платежей**/
for each t-docs break by t-docs.cif by t-docs.cttype:
    accumulate (t-docs.sum / t-docs.cursdoc-usd) (total by t-docs.cttype).
    if last-of(t-docs.cttype) then do:
        v-totalsum = accum total by t-docs.cttype (t-docs.sum / t-docs.cursdoc-usd).
        if  v-totalsum > 100000 /*(v-totalsum < 100000)*/ then do:
            create t-docs_total.
            assign
            t-docs_total.cif = t-docs.cif
            t-docs_total.cttype = t-docs.cttype
            t-docs_total.totalsum = v-totalsum.
        end.
    end.
end.

for each t-docs:
    v-err = 0.
    if t-docs.okpo = "" then v-err = 1.
    else if t-docs.prefix = "" then v-err = 2.
    else if t-docs.name = "" then v-err = 3.
    else if t-docs.ctnum = "" then v-err = 4.
    else if t-docs.partner = "" then v-err = 5.
    else if t-docs.region = "" then v-err = 6.

    if v-err > 0 then do:
        find first t-docs_total where t-docs.cif = t-docs_total.cif and t-docs.cttype = t-docs_total.cttype no-error.
        if avail t-docs_total then do:
            create t-errs.
            assign
            t-errs.type = v-err
            t-errs.bank = t-docs.bank
            t-errs.depart = t-docs.depart
            t-errs.cif = t-docs.cif
            t-errs.prefix = t-docs.prefix
            t-errs.name = t-docs.name
            t-errs.ctdate = t-docs.ctdate
            t-errs.ctnum = t-docs.ctnum
            t-errs.partner = trim(trim(t-docs.partnprefix) + " " + trim(t-docs.partner)).
        end.
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
    unix silent cptwin err.htm iexplore.
    return.
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


/**заполнение таблицы с общей суммой платежей**/
for each t-docs break by t-docs.cif by t-docs.cttype:
    accumulate (t-docs.sum / t-docs.cursdoc-usd) (total by t-docs.cttype).
    if last-of(t-docs.cttype) then do:
        v-totalsum = accum total by t-docs.cttype (t-docs.sum / t-docs.cursdoc-usd).
        if  v-totalsum > 100000 then do:
            create t-docs_total.
            assign
            t-docs_total.cif = t-docs.cif
            t-docs_total.cttype = t-docs.cttype
            t-docs_total.totalsum = v-totalsum.
        end.
    end.
end.

find first t-docs_total no-lock no-error.
if avail t-docs_total then do:
    for each t-docs_total no-lock:
        find first t-docs where t-docs.cif = t-docs_total.cif and t-docs.cttype = t-docs_total.cttype no-error.

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

                    if t-docs.bnkbin <> "" then do:
                        v-text = "/BANKBIN/" + t-docs.bnkbin.
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

            v-text = "/NAME/" + substr(t-docs.name, 1, 100).
            put stream rpt unformatted v-text skip.

            if t-docs.cttype = "e" then v-text = "1".
            else v-text = "2".
            v-text = "/EISIGN/" + v-text.
            put stream rpt unformatted v-text skip.

            if t-docs.cttype = "e" then v-text = "2".
            else v-text = "1".
            v-text = "//INOUT/" + v-text.
            put stream rpt unformatted v-text skip.

            if t-docs.clnsts = "1" then do:
                if length(t-docs.okpo) < 12 then t-docs.okpo = t-docs.okpo + fill("0", 12 - length(t-docs.okpo)).

                if v-bin = no then do:
                    v-text = "//OKPO/" + t-docs.okpo.
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

                        if t-docs.bin <> "" then do:
                            v-text = "//BIN/" + t-docs.bin.
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
                        v-text = "//OKPO/" + t-docs.okpo.
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
            else if t-docs.clnsts = "2" then do:
                if v-bin = no then do:
                    v-text = "//OKPO/".
                    put stream rpt unformatted v-text skip.

                    v-text = "//RNN/" + t-docs.okpo.
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

                        if t-docs.iin <> "" then do:
                            v-text = "//IIN/" + t-docs.iin.
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

                        v-text = "//RNN/" + t-docs.okpo.
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

            v-text = "//ADDRESS/" + t-docs.addr.
            put stream rpt unformatted v-text skip.

            v-text = "//REGION/" + t-docs.region.
            put stream rpt unformatted v-text skip.

            v-text = "//PFORM/" + substr(t-docs.prefix, 1, 10).
            put stream rpt unformatted v-text skip.

            v-text = "//PSUMM/" + string(t-docs_total.totalsum).
            put stream rpt unformatted v-text skip.

            v-text = "/NOTE/".
            put stream rpt unformatted v-text skip.

            {vcmsgend.i &msg = "106"}
    end.
end.
else do:
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

            if t-docs.bnkbin <> "" then do:
                v-text = "/BANKBIN/" + t-docs.bnkbin.
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

    {vcmsgend.i &msg = "106"}
end.


