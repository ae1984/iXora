/* ibcchg.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Программа смены получателя на квитанцию
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
        24/07/04 pragma
 * CHANGES
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        20/09/2006 u00568 Evgeniy - переделал dat на date
*/

{comm-txb.i}
{comm-com.i}
{yes-no.i}
{comm-rnn.i}

define shared variable g-today as date.
define shared variable g-ofc as character.

define variable seltxb as integer.
define new shared variable selgrp as integer.
define new shared variable selbn as char.

seltxb = comm-cod().

define variable grpname as character format "x(40)".

define variable v-date1 as date.
define variable v-date2 as date.
define variable v-dnum as integer.
define variable v-rnn as character.
define variable v-sum1 as decimal.
define variable v-sum2 as decimal.
define variable v-fio as character.
define variable v-accnt like commonpl.accnt.
define variable v-counter like commonpl.counter.
define variable v-fioadr like commonpl.fioadr.

def new shared var rnnValid   as logical initial false.
def new shared var doctype as int format ">9".
def new shared var docfio  as char format "x(30)".
def new shared var docadr  as char format "x(50)".
def new shared var docfioadr  as char format "x(80)".
def new shared var docbik  as integer format "999999999".
def new shared var dociik  as integer format "999999999".
def new shared var dockbk  as char format "x(6)".
def new shared var docbn   as char format "x(35)".
def new shared var docbank  as char.
def new shared var dockbe   as char format "x(2)".
def new shared var dockod   as char format "x(2)".
def new shared var docrnn   as char format "x(12)".
def new shared var docrnnnk as char format "x(12)".
def new shared var docrnnbn as char format "x(12)".
def new shared var docnpl   as char format "x(120)".
def new shared var docnum   as integer format ">>>>>>>9".
def new shared var docgrp   as integer.
def new shared var doctgrp  as integer.
def new shared var docarp   as char    format "x(10)".
def new shared var docsum      as decimal format ">>,>>>,>>9.99".
def new shared var doccomsum   as decimal format ">,>>9.99".
def new shared var docprc   as integer  format "9.9999".
def new shared var bsdate   as date.
def new shared var esdate   as date.
def new  shared var docnumber as char.
def new shared var dockts as char init "".


define variable vd as date.
define variable vcount as integer.

define temp-table tmp like commonpl
                  field bn like commonls.bn
                  field rid as rowid.

/* ------------------------------------------ */
vcount = 0.

define variable s-grp as character.


find first tarif2 where tarif2.num  = "1" and tarif2.kod = "10"
                    and tarif2.stat = 'r' no-lock no-error.
if not avail tarif2 or (avail tarif2 and not (can-find (gl where gl.gl = tarif2.kont no-lock))) then
do:
    message "Не могу найти счет комисии по 110 тарифу!" view-as alert-box title "".
    return.
end.


define frame getcode s-grp label "КОД ПЛАТЕЖЕЙ (F2 - выбор)"
             with row 3 centered overlay side-labels.

on HELP of s-grp in frame getcode do:
    run uni_help1 ("comtype", "*").
end.

update s-grp with frame getcode.
hide frame s-grp.

if s-grp <> ? and s-grp <> '' then selgrp = integer (s-grp).
else do:
     message "Ошибка выбора!" view-as alert-box title ''.
     return.
end.

find first commonls where commonls.txb = seltxb and commonls.visible and
                    commonls.grp = selgrp no-lock no-error.
if not available commonls then do:
     message "Ошибка выбора!" view-as alert-box title ''.
     return.
end.

/* selgrp = 1. */

find codfr where codfr.codfr = "comtype" and codfr.code = s-grp no-lock no-error.
grpname = codfr.name [1].


/* ------------------------------------------ */

v-date1 = g-today.
v-date2 = g-today.
v-sum1 = 0.00.
v-sum2 = 999999999.99.
v-dnum = ?.
v-rnn = ''.
v-fio = ''.
v-accnt = ?.
v-fioadr = ''.
v-counter = 0.

define frame getcom
       grpname label "Платеж" view-as text skip(1)
       v-date1 label "Дата с..."
       v-date2 label "Дата по..."
       v-dnum label "Номер док." format "zzzzzz9"
       v-rnn label "РНН" format "x(12)"
       v-fio label "Часть ФИО" format "x(35)"
       v-accnt label "Лицевой счет"
       v-fioadr label "Счет-извещение" format "x(20)"
       v-counter label "Телефон/Счетчик"
       v-sum1 label "Сумма с..." format "z,zzz,zzz,zzz,zz9.99"
       v-sum2 label "Сумма по..." format "z,zzz,zzz,zzz,zz9.99"
       with row 2 side-labels 1 column centered overlay.

define query qt for tmp.
define browse bt query qt
       displ tmp.date column-label "Дата"
             tmp.dnum column-label "НомДок" format "zzzzzz9"
             tmp.rnn column-label "РНН" format "x(12)"
             tmp.bn column-label "Получатель" format "x(20)"
             tmp.sum column-label "Сумма" format ">>>>>>>>9.99"
       with row 1 centered 15 down title "Выберите платеж".

define frame ft bt help "ENTER - просмотр/редактирование платежа".


on "return" of browse bt do:
  if not available tmp then leave.
  run wpchg (tmp.date, false, tmp.rid, selgrp, output selbn).
  find first commonpl where rowid(commonpl) = to-rowid(substring(return-value,1,10)) no-lock no-error.
  if avail commonpl then do:
  update tmp.bn = selbn
         tmp.sum = commonpl.sum
         tmp.comsum = commonpl.comsum.
  open query qt for each tmp.
  get last qt.
  reposition qt to rowid to-rowid(return-value) no-error.
  end.
end.

 
 
/* ------------------------------------------ */

update grpname
       v-date1
       v-date2
       v-dnum
       v-rnn
       v-fio
       v-accnt
       v-fioadr
       v-counter
       v-sum1
       v-sum2
       with frame getcom.
hide frame getcom.

/*
do vd = v-date1 to v-date2:
displ vd label "Ждите..." with row 5 centered frame waitfr. pause 0.
*/

displ "Ждите..." with row 5 centered frame waitfr. pause 0.

if v-rnn = '' then
for each commonpl where commonpl.txb = seltxb and
                        commonpl.date >= v-date1 and
                        commonpl.date <= v-date2 and
                        commonpl.deluid = ? and
                        commonpl.grp = selgrp /*and
                        commonpl.joudoc <> ?*/
                        no-lock:

    if (v-fio = '' or (v-fio <> '' and commonpl.fio matches "*" + v-fio + "*")) and
       (v-dnum = ? or v-dnum = 0 or commonpl.dnum = v-dnum) and
       (v-accnt = ? or v-accnt = 0 or commonpl.accnt = v-accnt) and
       (v-fioadr = ? or v-fioadr = '' or commonpl.fioadr = v-fioadr) and
       (commonpl.sum >= v-sum1 and commonpl.sum <= v-sum2) then do:

       create tmp.
       buffer-copy commonpl to tmp.

    find first commonls where commonls.txb = seltxb and commonls.grp = selgrp no-lock no-error.

       tmp.rid = rowid (commonpl).
       tmp.bn = commonls.bn.

vcount = vcount + 1.
    end.

end. /* each commonpl */
else
for each commonpl where commonpl.txb = seltxb and
                        commonpl.date >= v-date1 and
                        commonpl.date <= v-date2 and
                        commonpl.rnn = v-rnn and
                        commonpl.deluid = ? and
                        commonpl.grp =  selgrp /*and
                        commonpl.joudoc <> ?*/
                        no-lock:

    if (v-fio = '' or (v-fio <> '' and commonpl.fio matches "*" + v-fio + "*")) and
       (v-dnum = ? or v-dnum = 0 or commonpl.dnum = v-dnum) and
       (v-accnt = ? or v-accnt = 0 or commonpl.accnt = v-accnt) and
       (v-fioadr = ? or v-fioadr = '' or commonpl.fioadr = v-fioadr) and
       (commonpl.sum >= v-sum1 and commonpl.sum <= v-sum2) then do:

       create tmp.
       buffer-copy commonpl to tmp.

    find first commonls where commonls.txb = seltxb and commonls.grp = selgrp no-lock no-error.

       tmp.rid = rowid (commonpl).
       tmp.bn = commonls.bn.

vcount = vcount + 1.
    end.

end. /* each commonpl */
/*
end.
*/

hide frame waitfr. pause 0.

open query qt for each tmp.
enable all with frame ft.
wait-for window-close of current-window focus browse bt.
hide all.
pause 0.
