/* vcmsg105out.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        вывод в файл МТ-115
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
         BANK COMM

 * AUTHOR
        23.05.2008 galina
 * CHANGES
        03.03.2009 galina - выводим один слеш перед ОКПО банка
        07.04.2011 damir- добавлены переменные bnkbin,bin,iin в temp-table t-cif,t-cif115
                          добавлены дополнительные поля
        28.04.2011 damir - поставлены ключи. процедура chbin.i
        03.05.2011 damir - исправлены ошибки.возникшие при компиляции
        06.12.2011 damir - убрал chbin.i, добавил vcmtform.i
        */

{vc.i}

{global.i}

{vcmtform.i} /*переход на БИН и ИИН*/


def input parameter p-cardnum    as char.
def input parameter p-cardreason as char.

def var v-dir as char.
def var v-ipaddr as char.
def var v-exitcod as char.
def var v-text as char.
def var v-filename as char.
def var v-filename0 as char init "vcmsg.txt".

def shared temp-table t-cif
    field clcif      like cif.cif
    field clname     like cif.name
    field okpo       as char format "999999999999"
    field rnn        as char format "999999999999"
    field clntype    as char
    field address    as char
    field region     as char
    field psnum      as char
    field psdate     as date
    field bankokpo   as char
    field ctexpimp   as char
    field ctnum      as char
    field ctdate     as date
    field ctsum      as char
    field ctncrc     as char
    field partner    like vcpartners.name
    field countryben as char
    field ctterm     as char
    field cardsend   like vccontrs.cardsend
    field prefix     as char
    field bnkbin     as char
    field bin        as char
    field iin        as char
    index main is primary clcif ctdate ctsum.

  def shared temp-table t-cif115
    field clcif     like cif.cif
    field clname    like cif.name
    field okpo      as char format "999999999999"
    field rnn       as char format "999999999999"
    field clntype   as char
    field address   as char
    field region    as char
    field bankokpo  as char
    field bnkbin    as char
    field bin       as char
    field iin       as char.

def shared var v-god as integer format "9999".
def shared var v-month as integer format "99".
def var i as integer no-undo.
/*def var v-monthname as char init
   "январь,февраль,март,апрель,май,июнь,июль,август,сентябрь,октябрь,ноябрь,декабрь".*/

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

/*v-dir = "C:/VC115/".
v-ipaddr = "Administrator@`askhost`".*/

if substr(v-dir, length(v-dir), 1) <> "/" then v-dir = v-dir + "/".
v-dir = v-dir + substr(string(year(g-today), "9999"), 3, 2) + string(month(g-today), "99") + string(day(g-today), "99") + "/".


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

find first t-cif no-lock no-error.
if avail t-cif then do:
    for each t-cif no-lock:
        {vcmsgparam_new.i &msg = "115"}

        if v-bin = no then do:
            v-text = "/BANKOKPO/" + t-cif.bankokpo + fill("0", 12 - length(t-cif.bankokpo)).
            put stream rpt unformatted v-text skip.
        end.

        if v-bin = yes then do:
            v-text = "/BANKOKPO/".
            put stream rpt unformatted v-text skip.

            if t-cif.bnkbin <> "" then do:
                v-text = "/BANKBIN/" + t-cif.bnkbin.
                put stream rpt unformatted v-text skip.
            end.
            else do:
                v-text = "/BANKBIN/".
                put stream rpt unformatted v-text skip.
            end.
        end.

        v-text = "/CARDNUMBER/" + p-cardnum.
        put stream rpt unformatted v-text skip.

        v-text = "/REPORTMONTH/" + string(v-month, '99') + string(v-god, '9999').
        put stream rpt unformatted v-text skip.

        v-text = "/NAME/" + t-cif.clname.
        put stream rpt unformatted v-text skip.

        if v-bin = no then do:
            v-text = "//OKPO/" + t-cif.okpo + fill("0", 12 - length(t-cif.okpo)).
            put stream rpt unformatted v-text skip.

            v-text = "//RNN/" + t-cif.rnn.
            put stream rpt unformatted v-text skip.
        end.

        if v-bin = yes then do:
            v-text = "//OKPO/".
            put stream rpt unformatted v-text skip.

            v-text = "//RNN/".
            put stream rpt unformatted v-text skip.

            if t-cif.bin <> "" then do:
                v-text = "//BIN/" + t-cif.bin.
                put stream rpt unformatted v-text skip.
            end.
            else do:
                v-text = "//BIN/".
                put stream rpt unformatted v-text skip.
            end.
            if t-cif.iin <> "" then do:
                v-text = "//IIN/" + t-cif.iin.
                put stream rpt unformatted v-text skip.
            end.
            else do:
                v-text = "//IIN/".
                put stream rpt unformatted v-text skip.
            end.
        end.

        v-text = "//SIGN/" + t-cif.clntype.
        put stream rpt unformatted v-text skip.

        v-text = "//ADDRESS/" + t-cif.address.
        put stream rpt unformatted v-text skip.

        v-text = "//REGION/" + t-cif.region.
        put stream rpt unformatted v-text skip.

        v-text = "/CURTRANDATE/".
        put stream rpt unformatted v-text skip.

        v-text = "/CURTRANSUM/".
        put stream rpt unformatted v-text skip.

        v-text = "/CURRENCY/".
        put stream rpt unformatted v-text skip.

        /*do i = 1 to num-entries(p-cardreason):
        v-text = "/REASON/" + entry(i,p-cardreason).
        put stream rpt unformatted v-text skip.
        end.*/

        v-text = "/CONTRACT/" + t-cif.ctnum.
        put stream rpt unformatted v-text skip.

        v-text = "//CDATE/" +  string(day(t-cif.ctdate),'99') + string(month(t-cif.ctdate),'99') + string(year(t-cif.ctdate),'9999').
        put stream rpt unformatted v-text skip.

        v-text = "/ESSENCE/".
        put stream rpt unformatted v-text skip.

        v-text = "/INFRTYPE/" + p-cardreason.
        put stream rpt unformatted v-text skip.

        v-text = "/NOTE/".
        put stream rpt unformatted v-text skip.

        {vcmsgend.i &msg = "115"}
    end.
end.

find first t-cif115 no-lock no-error.
if avail t-cif115 then do:
    for each t-cif115 no-lock:
        {vcmsgparam_new.i &msg = "115"}

        if v-bin = no then do:
            v-text = "//BANKOKPO/" + t-cif115.bankokpo + fill("0", 12 - length(t-cif115.bankokpo)).
            put stream rpt unformatted v-text skip.
        end.

        if v-bin = yes then do:
            v-text = "//BANKOKPO/".
            put stream rpt unformatted v-text skip.

            if t-cif115.bnkbin <> "" then do:
                v-text = "/BANKBIN/" + t-cif115.bnkbin.
                put stream rpt unformatted v-text skip.
            end.
            else do:
                v-text = "/BANKBIN/".
                put stream rpt unformatted v-text skip.
            end.
        end.

        v-text = "/CARDNUMBER/" + p-cardnum.
        put stream rpt unformatted v-text skip.

        v-text = "/REPORTMONTH/" + string(v-month, '99') + string(v-god, '9999').
        put stream rpt unformatted v-text skip.

        v-text = "/NAME/" + t-cif115.clname.
        put stream rpt unformatted v-text skip.

        if v-bin = no then do:
            v-text = "//OKPO/" + t-cif115.okpo + fill("0", 12 - length(t-cif115.okpo)).
            put stream rpt unformatted v-text skip.

            v-text = "//RNN/" + t-cif115.rnn.
            put stream rpt unformatted v-text skip.
        end.

        if v-bin = yes then do:
            v-text = "//OKPO/".
            put stream rpt unformatted v-text skip.

            v-text = "//RNN/".
            put stream rpt unformatted v-text skip.

            if t-cif115.bin <> "" then do:
                v-text = "//BIN/" + t-cif115.bin.
                put stream rpt unformatted v-text skip.
            end.
            else do:
                v-text = "//BIN/".
                put stream rpt unformatted v-text skip.
            end.
            if t-cif115.iin <> "" then do:
                v-text = "//IIN/" + t-cif115.iin.
                put stream rpt unformatted v-text skip.
            end.
            else do:
                v-text = "//IIN/".
                put stream rpt unformatted v-text skip.
            end.
        end.

        v-text = "//SIGN/" + t-cif115.clntype.
        put stream rpt unformatted v-text skip.

        v-text = "//ADDRESS/" + t-cif115.address.
        put stream rpt unformatted v-text skip.

        v-text = "//REGION/" + t-cif115.region.
        put stream rpt unformatted v-text skip.

        v-text = "/CURTRANDATE/".
        put stream rpt unformatted v-text skip.

        v-text = "/CURTRANSUM/".
        put stream rpt unformatted v-text skip.

        v-text = "/CURRENCY/".
        put stream rpt unformatted v-text skip.

        /*do i = 1 to num-entries(p-cardreason):
        v-text = "/REASON/" + entry(i,p-cardreason).
        put stream rpt unformatted v-text skip.
        end.*/

        v-text = "/CONTRACT/".
        put stream rpt unformatted v-text skip.

        v-text = "//CDATE/".
        put stream rpt unformatted v-text skip.

        v-text = "/ESSENCE/".
        put stream rpt unformatted v-text skip.

        v-text = "/INFRTYPE/" + p-cardreason.
        put stream rpt unformatted v-text skip.

        v-text = "/NOTE/".
        put stream rpt unformatted v-text skip.

        {vcmsgend.i &msg = "115"}
    end.
end.

