/* insedt.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Просмотр документов по РПРО
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
        28/01/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        09/02/2010 galina - косметическое изменение
*/

{mainhead.i}

def var dt1     as date.
def var dt2     as date.
def var v-aaa   as char.
def var v-dep   as char.
def var s-vcourbank as char.
def var v-stat  as char init ["err|returned|blk|recall|wait|accept|"].
def var v-stat2 as char init ["Ошибка|Возвращено|Заблокировано|Отозвано|Получено после 18:00|Обрабатывается|"].
def var v-sts   as char init ["00|01|03|11|12|13|16"].
def var v-sts2  as char init ["Обрабатывается|Принят|К-2|Клиент не найден|Счет не найден|Cчет закрыт|Неверный РНН"].
def var v-type   as char init ["AC|ACP|ASD"].
def var v-type2  as char init ["Налог|ОПВ|СО"].
def var i as integer.
def temp-table t-inc no-undo
    field rdt like insin.rdt
    field rtm as char
    field num like insin.numr
    field acc like insin.iik
    
    field mnu like insin.mnu
    field sts as char
    field bnk as char
    field ref like insin.ref
    field type like insin.type
    index rdt is primary rdt.
    
def buffer b-inc for t-inc.

def query qp for t-inc.

def browse ps query qp
    display t-inc.rdt label "Дата РПРО" format "99/99/9999"
            t-inc.rtm label "Время" format "x(5)"
            t-inc.num label "Номер РПРО" format "999999999"
            t-inc.acc label "Номер счета" format "x(9)"
            
            t-inc.sts label "Cтатус" format "x(15)"
            t-inc.mnu label "Текущий статус" format "x(15)"
            t-inc.type label "Тип РПРО" format "x(15)"
            t-inc.bnk label "Подразделение" format "x(16)"
    with 26 down centered width 120 no-box.

def frame ft ps with width 124 row 4 overlay no-label title "Распоряжения о приостановлении".

form dt1 label ' Укажите период с' format '99/99/9999'
    dt2 label ' по' format '99/99/9999' skip(1)
    v-dep label ' подразделение...' format "x(25)" skip(1)
    v-aaa label ' номер счета.....' format "x(20)"
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

if s-vcourbank ne "txb00" then update dt1 dt2 v-aaa with frame dat.
else update dt1 dt2 v-dep v-aaa with frame dat.

hide frame dat.

for each insin where insin.rdt >= dt1 and insin.rdt <= dt2 no-lock:
    create t-inc.
    assign t-inc.rdt = insin.rdt
        t-inc.rtm = string(insin.rtm, "hh:mm")
        t-inc.num = insin.numr
        t-inc.acc = insin.iik
        t-inc.mnu = entry(lookup(insin.mnu, v-stat, "|"), v-stat2, "|")
        t-inc.ref = insin.ref
        t-inc.sts = entry(lookup(string(insin.stat, "99"), v-sts, "|"), v-sts2, "|").
        if lookup(insin.type, v-type, "|") <> 0  then t-inc.type = insin.type + '-' + entry(lookup(insin.type, v-type, "|"), v-type2, "|").
        find first txb where txb.bank eq insin.bank no-lock no-error.
        if avail txb then t-inc.bnk = txb.info.
end.
for each t-inc:
  if num-entries(t-inc.acc) = 1 then next.
  
  do i = 1 to num-entries(t-inc.acc):
    create b-inc.
    buffer-copy t-inc except t-inc.acc to b-inc.
    b-inc.acc = entry(i,t-inc.acc).
  end.
  delete t-inc.
  
end.


if v-aaa ne "" then do transaction:
    for each t-inc where t-inc.acc ne v-aaa exclusive-lock:
        delete t-inc.
    end.
end. /*transaction*/

on "return" of ps in frame ft do:
    run insprn(t-inc.ref).
end.




open query qp for each t-inc where t-inc.bnk eq v-dep no-lock.
enable ps with frame ft.
apply "value-changed" to browse ps.
wait-for window-close of current-window.
pause 0.