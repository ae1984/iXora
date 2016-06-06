/* almtvcom.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Зачисление комиссии по АЛМАТВ
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
        18/06/03 nataly 460714 -> 461110, 460716 -> 461120
        12/04/04 kanat поменял алгоритм вычисления комиссии.
        12.04.04 kanat собираются все платежи со статусом 1 (0 - новый, 1 - зачисленый на АРП, 3 - зачисленная комиссия, 2 - отправленный платеж)
                       отправка будет делаться только с после зачисления комиссий с платежей
        16.04.04 kanat добавил условие на deluid в основной foreach
        05/04/06   marinav проставление кодов доходов и департаментов в проводке
*/

{global.i}
{comm-txb.i}
{yes-no.i}
{comm-arp.i}
{get-dep.i}
def var ourcode as integer no-undo.
def var dat as date no-undo.
def var v-tot as deci no-undo.
def var v-users as char init "" no-undo. 
def new shared var s-jh like jh.jh.
def var rcode as int no-undo.
def var rdes  as cha no-undo.
def var v-gl-f as char no-undo.
def var v-gl-u as char no-undo.
def var v-depd as char no-undo.
def var v-dep  as char no-undo.

define temp-table talm no-undo like almatv
    field depd as char      
    field v-gl as char      
    field rid as rowid.

ourcode = comm-cod().
dat = g-today.

update dat label ' Укажите дату ' format '99/99/9999' skip
with side-label row 5 centered frame dataa .
hide frame dataa.

find first sysc where sysc.sysc = 'GLCOMM' no-lock no-error.
if avail sysc then assign v-gl-u = entry(1, sysc.chval) v-gl-f = entry(2, sysc.chval).
              else do:
                  message "Не найдена настройка в SYSC 'GLCOMM'"  view-as alert-box.
                  return.
              end.

for each almatv where almatv.txb = ourcode and almatv.dtfk = dat  and almatv.state = 2 and almatv.deluid = ? no-lock:
    ACCUMULATE almatv.cursfk (total).                                                                              
    v-dep = string(get-dep(almatv.uid, dat)).
    run get-profit (input almatv.uid, input v-dep, output v-depd).
    if v-depd = '' then v-depd = '227'.
    create talm.
    buffer-copy comm.almatv to talm.
    talm.depd = v-depd.
    talm.rid = rowid(comm.almatv).
    talm.v-gl = v-gl-f.
end.

v-tot = (accum total almatv.cursfk).

if v-tot = 0 then do:
    MESSAGE "Необработанные платежи не найдены."
    VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
    TITLE "Внимание".
    RETURN. 
end.

if not comm-arp ('498904301', v-tot) then undo, return.

for each almatv where almatv.txb = ourcode and dtfk = dat and state = 0 and almatv.deluid = ?  break by uid :
    if first-of(uid) then v-users = "~n" + almatv.uid + v-users.
end.

if v-users <> "" then 
    if not yes-no("Внимание", "По следущим кассирам:" +  v-users + 
    "~nплатежи не зачислены на транзитный счет. Продолжить?") then return.


MESSAGE "Сформировать транзакцию на сумму " v-tot " тенге."
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
TITLE "Комиссия за платежи Алма-ТВ" UPDATE choice3 as logical.
case choice3:
   when false then return.
end.        

find first cods where cods.gl  = integer(v-gl-u) and cods.arc = no exclusive-lock no-error.
if avail cods then do trans: cods.lookaaa = yes. end.
find first cods where cods.gl  = integer(v-gl-f) and cods.arc = no exclusive-lock no-error.
if avail cods then do trans: cods.lookaaa = yes. end.


for each talm break by talm.v-gl by talm.depd:
    accumulate talm.cursfk (total by talm.v-gl by talm.depd ).
    if last-of( talm.depd ) and  (accum total by talm.depd talm.cursfk) > 0
    then do:
            
        run trx(
        6, 
        (accum total by talm.depd talm.cursfk), 
        1, 
        '', 
        '498904301', 
        talm.v-gl, 
        '', 
        'Зачисление комиссии на счет доходов',
        '14','16','856').
        
        if return-value = '' then undo, return.           
        s-jh = int(return-value).            
        run jou.

        run cods-com (input integer(talm.v-gl), input talm.depd, input "2").

      /*  run vou_bank(2).*/

    end.
end.

find first cods where cods.gl  = integer(v-gl-u) and cods.arc = no exclusive-lock no-error.
if avail cods and cods.lookaaa = yes then do trans: cods.lookaaa = no. end.
find first cods where cods.gl  = integer(v-gl-f) and cods.arc = no exclusive-lock no-error.
if avail cods and cods.lookaaa = yes then do trans: cods.lookaaa = no. end.
release cods.

for each almatv where almatv.txb = ourcode and dtfk = dat and almatv.deluid = ? and almatv.state = 2 exclusive-lock:
    update almatv.state = 3.
end.
