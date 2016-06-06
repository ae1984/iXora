/* pksendsms1_1.p
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
        08/09/2009 madiyar - телефон для справок в Алматы 259-99-99, в остальных городах 59-99-99
        14/09/2009 madiyar - номер пакета в шаренной переменной
        16/09/2009 madiyar - перекомпиляция
        11/12/2009 madiyar - отправка сообщений по шаблону
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

def shared var v-dt as date no-undo.
def var v-sts as char no-undo.

def var v-tmp as char no-undo.
def var v-txt as char no-undo.
def var i as integer no-undo.
def var j as integer no-undo.
def var ss as char no-undo.

def shared temp-table wrk no-undo
  field bank as char
  field bankn as char
  field cif like cif.cif
  field lon like lon.lon
  field crc as integer
  field name as char
  field sumgr as deci
  field balanst as deci
  field mob as char
  field days as integer
  field credtype as char
  field ln as integer
  field sing as char
  field who as char
  field whn as char
  field sts as integer
  index idx is primary name cif.

def shared var v-bb as integer no-undo.

def temp-table wrk_tmpl no-undo
  field id as integer
  field tit as char
  field txt as char
  index idx is primary id
  index idx2 is unique tit.

define query q1 for wrk.
def browse b1
    query q1 no-lock
    display
        wrk.sing             label "*" format "x(1)"
        wrk.name             label "ФИО" format "x(55)"
        wrk.lon              label "Ссуд.счет" format "x(10)"
        wrk.mob              label "СОТОВЫЙ"  format "x(12)"
        wrk.bankn            label "Филиал" format "x(20)"
    with 26 down title "СПИСОК ЗАЕМЩИКОВ БД" no-labels.

DEFINE BUTTON bsendall    LABEL "Отправить SMS по всему списку".
DEFINE BUTTON bsendsel    LABEL "Отправить SMS выбранным из списка".
DEFINE BUTTON bsendtxtall LABEL "Отправить SMS-шаблон по всему списку".
DEFINE BUTTON bexit       LABEL "Выход".

def frame f1
    b1 help "<ENTER> -  Выбор "
    skip
    bsendall "                   " bsendtxtall skip
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
        else do: run addatk(no,'',wrk.mob, wrk.bank, wrk.cif, v-bb). wrk.sts = 1. end.
    end.
    message skip " SMS помещены в очередь на отправку! " skip(1) view-as alert-box button ok .
    browse b1:refresh().
end.

ON CHOOSE OF bsendtxtall IN FRAME f1 do:

    v-tmp = ''.
    find first pksysc where pksysc.credtype = '0' and pksysc.sysc = "smstmp" no-lock no-error.
    if avail pksysc then v-tmp = trim(pksysc.chval).
    if v-tmp <> '' then do:
        j = 0.
        empty temp-table wrk_tmpl.
        do i = 1 to num-entries(v-tmp,"|"):
            ss = entry(i,v-tmp,"|").
            if num-entries(ss,"^") = 2 then do:
                j = j + 1.
                create wrk_tmpl.
                assign wrk_tmpl.id = j
                       wrk_tmpl.tit = entry(1,ss,"^")
                       wrk_tmpl.txt = entry(2,ss,"^").
            end.
        end.
        find first wrk_tmpl no-lock no-error.
        if avail wrk_tmpl then do:

            {itemlist.i
                &file = "wrk_tmpl"
                &frame = "row 6 centered scroll 1 20 down overlay "
                &where = " true "
                &flddisp = " wrk_tmpl.tit label 'ИМЯ' format 'x(15)'
                             wrk_tmpl.txt label 'ТЕКСТ' format 'x(40)'
                            "
                &chkey = "tit"
                &chtype = "string"
                &index  = "idx"
                &end = "if keyfunction(lastkey) = 'end-error' then return."
            }
            v-txt = trim(wrk_tmpl.txt).

            if v-txt <> '' then do:
                v-bb = next-value(smsbatch).
                for each wrk exclusive-lock.
                    wrk.sing = '*'.
                    if (wrk.mob = '') or (length(wrk.mob) < 11) or (length(wrk.mob) > 12) then wrk.sts = 2.
                    else do: run addatk(yes,v-txt,wrk.mob, wrk.bank, wrk.cif, v-bb). wrk.sts = 1. end.
                end.
                message skip " SMS помещены в очередь на отправку! " skip(1) view-as alert-box button ok .
                browse b1:refresh().
            end.
            else message "Выбран пустой шаблон!" view-as alert-box.
        end.
        else message "Не найдены шаблоны сообщений!" view-as alert-box.
    end.
    else message "Не найдены шаблоны сообщений!" view-as alert-box.
end.

ON CHOOSE OF bsendsel IN FRAME f1 do:
    find first wrk where wrk.sing = '*' no-lock no-error.
    if not avail wrk then message skip " Нет выбранных клиентов для рассылки SMS!" skip(1) view-as alert-box button ok title " ОШИБКА ! ".
    else do:
        v-bb = next-value(smsbatch).
        for each wrk where wrk.sing = '*' no-lock.
            if (wrk.mob = '') or (length(wrk.mob) < 11) or (length(wrk.mob) > 12) then wrk.sts = 2.
            else do: run addatk(no,'',wrk.mob, wrk.bank, wrk.cif, v-bb). wrk.sts = 1. end.
        end.
        message skip " SMS помещены в очередь на отправку! " skip(1) view-as alert-box button ok .
        browse b1:refresh().
    end.
end.


/* выход */
on choose of bexit in frame f1 do:
   apply "enter-menubar" to frame f1.
end.


open query q1 for each wrk.

enable all with centered frame f1.
apply "value-changed" to browse b1.
wait-for "enter-menubar" of frame f1.

close query q1.

hide all no-pause.

procedure addatk.
    define input parameter v-sendtxt as logi.
    define input parameter v-txt as char.
    define input parameter v-mob as char.
    define input parameter v-bank as char.
    define input parameter v-cif as char.
    define input parameter v-batchid as integer.
    create smspool.
    smspool.bank  = v-bank.
    smspool.id  = next-value(smsid).
    smspool.tell = wrk.mob.
    smspool.pdate = today.
    smspool.ptime = time.
    smspool.pwho = g-ofc.
    smspool.state = 2.
    smspool.cif = v-cif.
    smspool.batchid = v-batchid.
    if v-sendtxt then smspool.mess = v-txt.
    else do:
        smspool.mess = "Uvazhaemyi klient banka! U Vas " + string(v-dt,"99/99/99") + " nastupaet ocherednoi platezh po predostavlennomu Vam kreditu. Tel. dlya spravok ".
        if ((s-ourbank = "txb00") or (s-ourbank = "txb16")) then smspool.mess = smspool.mess + "259-99-99".
        else smspool.mess = smspool.mess + "59-99-99".
        smspool.mess = smspool.mess + " AO ""METROCOMBANK""".
    end.
end.

