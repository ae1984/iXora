/* incedt.p
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
        --/--/2008 alex
 * BASES
        BANK COMM
 * CHANGES
        16.06.2009 galina - добавила поле Вид операции
        07/10/2009 galina - добавила ручную отправку сообщения о постановке в картотеку для ИР по ОПВ и СО
        27.01.10 marinav - расширение поля счета до 20 знаков
        17/05/2010 galina - перенесла логин офицера для постановки на К-2 ИР ОПВ и СО в справочник
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        13.08.2012 evseev - ТЗ-1454
*/

{mainhead.i}

def var dt1     as date.
def var dt2     as date.
def var v-aaa   like aaa.aaa.
def var v-dep   as char.
def var s-vcourbank as char.
def var v-stat  as char init ["err|paid|pay|returned|blk|K2_sent|recall|wait|accept|"].
def var v-stat2 as char init ["Ошибка|Оплачено||Возвращено|Заблокировано|К-2|Отозвано|Получено после 18:00|Обрабатывается|"].
def var v-sts   as char init ["00|01|03|11|12|13|14|15|16"].
def var v-sts2  as char init ["Обрабатывается|Принят|К-2|Клиент не найден|Счет не найден|Cчет закрыт|Недопустимый КБК|Недопустимый ЕКНП|Неверный РНН"].
def var v-vo   as char init ["03|04|05|07|09"].
def var v-vo2  as char init ["Налог|Налог.дебит.|Тамож|ОПВ|СО"].
def var v-k2 as logical format 'да/нет' init no.

def temp-table t-inc no-undo
    field rdt like inc100.rdt
    field rtm as char
    field num like inc100.num
    field acc like inc100.iik
    field sum like inc100.sum
    field mnu like inc100.mnu
    field sts as char
    field file like inc100.filename
    field bnk as char
    field ref like inc100.ref
    field vo like inc100.vo
    index rdt is primary rdt.

/*def button b-ret label "Возврат в НК".
def button b-acc label "Принять ИР к исполнению".*/
def button b-k2 label "Постановка на картотеку".

def query qp for t-inc.

def browse ps query qp
    display t-inc.rdt label "Дата ИР" format "99/99/9999"
            t-inc.rtm label "Время" format "x(5)"
            t-inc.num label "Номер ИР" format "999999999"
            t-inc.acc label "Номер счета" format "x(21)"
            t-inc.sum label "Сумма" format ">,>>>,>>>,>>9.99"
            t-inc.sts label "Cтатус" format "x(15)"
            t-inc.mnu label "Текущий статус" format "x(15)"
            t-inc.vo label "Вид операции" format "x(15)"
            t-inc.bnk label "Подразделение" format "x(16)"
    with 26 down centered width 120 no-box.

def frame ft ps skip(2) b-k2 /*b-ret b-acc*/ with width 124 row 4 overlay no-label title "Инкассовые распоряжения".

form dt1 label ' Укажите период с' format '99/99/9999'
    dt2 label ' по' format '99/99/9999' skip(1)
    v-dep label ' подразделение...' format "x(25)" skip(1)
    v-aaa label ' номер счета.....' format "x(21)"
    with side-label row 5 width 48 centered frame dat.


on help of v-dep in frame dat do:
    {itemlist.i
        &file = "txb"
        &frame = "row 6 width 25 centered 18 down overlay "
        &where = " txb.consolid = true "
        &flddisp = " txb.info label 'Подразделение' format 'x(23)' "
        &chkey = "info"
        &chtype = "string"
        &index  = "txb"
        &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
    v-dep = txb.info.
    displ v-dep with frame dat.
end.

dt2 = today.
dt1 = date(month(dt2), 1, year(dt2)).

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   run savelog( "inkps", "incedt: There is no record OURBNK in bank.sysc file!").
   return.
end.

s-vcourbank = trim(sysc.chval).

find first txb where txb.bank eq s-vcourbank no-lock no-error.
if avail txb then v-dep = txb.info.
displ v-dep with frame dat.

if s-vcourbank ne "txb00" then update dt1 dt2 v-aaa with frame dat. else update dt1 dt2 v-dep v-aaa with frame dat.

hide frame dat.

for each inc100 where inc100.rdt >= dt1 and inc100.rdt <= dt2 no-lock:
    create t-inc.
    assign t-inc.rdt = inc100.rdt
        t-inc.rtm = string(inc100.rtm, "hh:mm")
        t-inc.num = inc100.num
        t-inc.acc = inc100.iik
        t-inc.sum = inc100.sum
        t-inc.mnu = entry(lookup(inc100.mnu, v-stat, "|"), v-stat2, "|")
        t-inc.file = inc100.filename
        t-inc.ref = inc100.ref
        t-inc.sts = entry(lookup(string(inc100.stat, "99"), v-sts, "|"), v-sts2, "|").
        if lookup(inc100.vo, v-vo, "|") <> 0  then t-inc.vo = inc100.vo + '-' + entry(lookup(inc100.vo, v-vo, "|"), v-vo2, "|").
        find first txb where txb.bank eq inc100.bank no-lock no-error.
        if avail txb then t-inc.bnk = txb.info.
end.


if v-aaa ne "" then do transaction:
    for each t-inc where t-inc.acc ne v-aaa exclusive-lock:
        delete t-inc.
    end.
end. /*transaction*/

on "return" of ps in frame ft do:
    run inkprn(t-inc.num, t-inc.ref).
end.


on "return" of b-k2 in frame ft do:
  find first inc100 where inc100.num = t-inc.num and inc100.iik = t-inc.acc and inc100.mnu = 'blk' no-lock no-error.
  if avail inc100 then do:
    find first sysc where sysc.sysc = 'inkk2' no-lock no-error.
    if avail sysc and sysc.chval <> '' then do:
        /*разрешить только определенному офицеру*/
        if lookup(g-ofc,sysc.chval) = 0 /*(g-ofc <> 'id00092')*/ then do:
           message 'У вас нет прав для постановки ИР на картотеку!' view-as alert-box.
           return.
        end.
        if inc100.vo <> '07' and inc100.vo <> '09' then do:
          message 'Постановка на картотеку в ручную только для ИР по ОПВ и СО!' view-as alert-box.
          return.
        end.

        MESSAGE skip " Отправить сообщение о постановке ИР № " + string(inc100.num,'999999999') + " на картоиеку?" skip(1)
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
        TITLE " ЭЛЕКТРОННЫЙ ДОКУМЕНТООБОРОТ С НК" UPDATE v-k2.

        if v-k2 then do:
           find current inc100 exclusive-lock.
           assign inc100.mnu = 'K2_sent'
           inc100.stat2 = '03'.
           find current inc100 no-lock.
           run 102st03h(inc100.ref).
        end.
    end.
  end.
end.

open query qp for each t-inc where t-inc.bnk eq v-dep no-lock.
enable ps /*b-ret b-acc*/ b-k2 with frame ft.
apply "value-changed" to browse ps.
wait-for window-close of current-window.
pause 0.