/* pksendsms2_1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Рассылка СМС-сообщений
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-2-3-12
 * AUTHOR
        09/11/06 Natalya D.
 * CHANGES
        26/08/2009 madiyar - переделал
        01/09/2009 madiyar - исправил ошибку с параметрами addatk
        08/09/2009 madiyar - телефон для справок в Алматы 259-99-99, в остальных городах 59-99-99
        14/09/2009 madiyar - номер пакета в шаренной переменной
        16/09/2009 madiyar - перекомпиляция
        09/10/2009 madiyar - убрал апострофы из сообщения
*/

{mainhead.i}

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

def shared temp-table wrk no-undo
  field bank as char
  field bankn as char
  field cif like cif.cif
  field lon like lon.lon
  field crc as integer
  field name as char
  field sumgr as deci
  field sumgr_kzt as deci
  field mob as char
  field days as integer
  field credtype as char
  field ln as integer
  field sing as char
  field who as char
  field whn as char
  field sts as integer
  index idx is primary name cif
  index idx2 days name.

def shared var v-bb as integer no-undo.

function days2str returns char (input dd as integer).
    def var res as char no-undo.
    def var ss as char no-undo.
    res = trim(string(dd,">>>9")).
    ss = substring(res,length(res),1).
    if ss = '1' then res = res + " den'".
    else
    if (ss = '2') or (ss = '3') or (ss = '4') then res = res + " dnya".
    else res = res + " dnei".
    return res.
end function.

define query q1 for wrk.
def browse b1
    query q1 no-lock
    display
        wrk.sing             label "*" format "x(1)"
        wrk.name             label "ФИО" format "x(49)"
        wrk.lon              label "Ссуд.счет" format "x(10)"
        wrk.days             label "ДниПр" format ">>9"
        wrk.mob              label "СОТОВЫЙ"  format "x(12)"
        wrk.bankn            label "Филиал" format "x(20)"
    with 26 down  title "СПИСОК ЗАЕМЩИКОВ БД" no-labels.

DEFINE BUTTON bsendall    LABEL "Отправить SMS по всему списку".
DEFINE BUTTON bsendsel    LABEL "Отправить SMS выбранным из списка".
DEFINE BUTTON bexit       LABEL "Выход".

def frame f1
    b1 help "<ENTER> -  Выбор "
    skip
    bsendall skip
    bsendsel skip
    bexit
with centered row 3 width 110.

on 'return' of browse b1 do:
  if wrk.sing = '*' then wrk.sing = ''.
  else wrk.sing = '*'.
  browse b1:refresh().
end.

ON CHOOSE OF bsendall IN FRAME f1 do:
    v-bb = next-value(smsbatch).
    for each wrk exclusive-lock.
        wrk.sing = '*'.
        if (wrk.mob = '') or (length(wrk.mob) < 11) or (length(wrk.mob) > 12) then wrk.sts = 2.
        else do:
            run addatk(wrk.mob, wrk.bank, wrk.days, wrk.crc, wrk.sumgr, wrk.sumgr_kzt, wrk.cif, v-bb).
            create pkdebtdat.
            assign pkdebtdat.bank = wrk.bank
                   pkdebtdat.credtype = wrk.credtype
                   pkdebtdat.ln = wrk.ln
                   pkdebtdat.lon = wrk.lon
                   pkdebtdat.rdt = g-today
                   pkdebtdat.rtim = time
                   pkdebtdat.rwho = g-ofc
                   pkdebtdat.action = "sms"
                   pkdebtdat.checkdt = g-today + 5.
            wrk.sts = 1.
        end.
    end.
    message skip " SMS помещены в очередь на отправку! " skip(1) view-as alert-box button ok .
    browse b1:refresh().
end.

ON CHOOSE OF bsendsel IN FRAME f1 do:
    find first wrk where wrk.sing = '*' no-lock no-error.
    if not avail wrk then message skip " Нет выбранных клиентов для рассылки SMS!" skip(1) view-as alert-box button ok title " ОШИБКА ! ".
    else do:
        v-bb = next-value(smsbatch).
        for each wrk where wrk.sing = '*' no-lock.
            if (wrk.mob = '') or (length(wrk.mob) < 11) or (length(wrk.mob) > 12) then wrk.sts = 2.
            else do:
                run addatk(wrk.mob, wrk.bank, wrk.days, wrk.crc, wrk.sumgr, wrk.sumgr_kzt, wrk.cif, v-bb).
                create pkdebtdat.
                assign pkdebtdat.bank = wrk.bank
                       pkdebtdat.credtype = wrk.credtype
                       pkdebtdat.ln = wrk.ln
                       pkdebtdat.lon = wrk.lon
                       pkdebtdat.rdt = g-today
                       pkdebtdat.rtim = time
                       pkdebtdat.rwho = g-ofc
                       pkdebtdat.action = "sms"
                       pkdebtdat.checkdt = g-today + 5.
                wrk.sts = 1.
            end.
        end.
        message skip " SMS помещены в очередь на отправку! " skip(1) view-as alert-box button ok .
        browse b1:refresh().
    end.
end.

/* выход */
on choose of bexit in frame f1 do:
    apply "enter-menubar" to frame f1.
end.

open query q1 for each wrk by wrk.days.

enable all with centered frame f1.
apply "value-changed" to browse b1.
wait-for "enter-menubar" of frame f1.

close query q1.

hide all no-pause.

procedure addatk.
    define input parameter v-mob as char.
    define input parameter v-bank as char.
    define input parameter v-days as int.
    define input parameter v-crc as integer.
    define input parameter v-sum as deci.
    define input parameter v-sum_kzt as deci.
    define input parameter v-cif as char.
    define input parameter v-batchid as integer.
    def var crccode as char no-undo extent 3 init ["KZT","USD","EUR"].
    create smspool.
    smspool.bank  = v-bank.
    smspool.id  = next-value(smsid).
    smspool.tell = v-mob.
    smspool.pdate = today.
    smspool.ptime = time.
    smspool.pwho = g-ofc.
    smspool.state = 2.
    smspool.cif = v-cif.
    smspool.batchid = v-batchid.
    smspool.mess = "U vas zadolzhennost po kreditu " + days2str(v-days) + ". Na " + string(g-today,"99/99/99") + " summa dolga ".
    if v-crc = 1 then smspool.mess = smspool.mess + "KZT" + trim(string(v-sum_kzt,">>>>>>>>9.99")).
    else do:
        if v-sum > 0 then do:
            smspool.mess = smspool.mess + crccode[v-crc] + trim(string(v-sum,">>>>>>>>9.99")).
            if v-sum_kzt > 0 then smspool.mess = smspool.mess + " i ".
        end.
        if v-sum_kzt > 0 then smspool.mess = smspool.mess + "KZT" + trim(string(v-sum_kzt,">>>>>>>>9.99")).
    end.
    smspool.mess = smspool.mess + ". Prosim Vas pogasit dolg. Tel. ".
    if ((s-ourbank = "txb00") or (s-ourbank = "txb16")) then smspool.mess = smspool.mess + "259-99-99".
    else smspool.mess = smspool.mess + "59-99-99".
    smspool.mess = smspool.mess + " AO ""METROCOMBANK""".
end.
