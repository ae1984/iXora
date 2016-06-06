/* h-rmzzzz.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

/* h-rmzzzz.p - F2 on VALCON */

{global.i}   
{lgps.i }
def var h as int .
h = 12 .

def shared var s-remtrz like remtrz.remtrz .
def shared var v-rsub like remtrz.rsub . 
def shared var eremzed like remtrz.remtrz.
def new shared var v-amt like remtrz.amt .
def new shared var v-cif like cif.cif .
def new shared var v-date as  date .
def new shared var v-ref like remtrz.ref.
def new shared var ourbank like remtrz.sbank.
def new shared var v-sqn like remtrz.sqn  .
def var v-crc like crc.crc.
def temp-table w-rmz like remtrz. 

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display "Отсутствует запись OURBNK в таблице SYSC!".
 pause .
 undo .
 return .
end.
ourbank = sysc.chval.

message "0) все платежи;  1) тенге;  2)валюта" update v-crc.

for each que where que.pid = m_pid and que.con = "W" no-lock ,
 each remtrz where remtrz.remtrz = que.remtrz and
                   (v-crc = 0 or (v-crc = 1 and remtrz.tcrc = 1) or (v-crc = 2 and remtrz.tcrc <> 1))
   no-lock  by remtrz.payment  . 
  if remtrz.rsub = v-rsub then do:
     create w-rmz.
     w-rmz.remtrz = remtrz.remtrz .
     find cursts where sub = 'rmz' and acc = remtrz.remtrz no-error.
     if avail cursts then
     do:
         if cursts.sts = "vdc" then w-rmz.ptype = "БЛ".
         else w-rmz.ptype = "".
     end.
     else w-rmz.ptype = "БЛ"       .
     w-rmz.sqn  = remtrz.sqn       .
     w-rmz.fcrc =    remtrz.fcrc   .
     w-rmz.amt  =    remtrz.amt    .
     w-rmz.tcrc =    remtrz.tcrc   .
     w-rmz.payment = remtrz.payment .
    end.
end.

define query q1 for w-rmz.

define browse b1 query q1
              displ
                 w-rmz.ptype label "Б?" 
                 w-rmz.remtrz label "Платеж"
                 w-rmz.sqn label "Nr."
                 w-rmz.fcrc label "ВД"
                 w-rmz.amt label "СуммаД"
                 w-rmz.tcrc label "ВК"
                 w-rmz.payment label "СуммаК"
     with centered no-label row 2 10 down no-box.

define frame f1 b1 
help "F1-отправить на VCON, F2-блокировка/снять блок, ENTER-смотреть"
with row 2.

on "return" of browse b1 do:
    eremzed = w-rmz.remtrz.
    apply 'window-close' to current-window. 
    return.
end.

on "value-changed" of b1 
do:
           find first remtrz where remtrz.remtrz = w-rmz.remtrz no-lock . 
           find que where que.remtrz = remtrz.remtrz
           no-lock no-error .
           display 
            remtrz.source column-label 'Ист.'
            remtrz.ptype column-label 'Тип'
            remtrz.rdt column-label 'Рег.дата'
            remtrz.valdt1 column-label 'Вал.дата1' 
            remtrz.valdt2 column-label 'Вал.дата2' 
            remtrz.sbank column-label 'Отпр.банк'
            remtrz.rbank column-label 'Получ.банк'
            with row 17  . pause 0 .
         if avail que then display 
          que.pid column-label 'Код'
          que.con column-label 'Сост.'
          with row 17    . pause 0 . 
end.


on "row-display" of b1
do:
           find first remtrz where remtrz.remtrz = w-rmz.remtrz no-lock . 
           find que where que.remtrz = remtrz.remtrz
           no-lock no-error .
           display 
            remtrz.source column-label 'Ист.'
            remtrz.ptype column-label 'Тип'
            remtrz.rdt column-label 'Рег.дата'
            remtrz.valdt1 column-label 'Вал.дата1' 
            remtrz.valdt2 column-label 'Вал.дата2' 
            remtrz.sbank column-label 'Отпр.банк'
            remtrz.rbank column-label 'Получ.банк'
            with row 17  . pause 0 .
         if avail que then display 
          que.pid column-label 'Код'
          que.con column-label 'Сост.'
          with row 17      . pause 0 . 
end.

on GO of b1 do:
  for each w-rmz where ptype = "":
      find first remtrz where remtrz.remtrz = w-rmz.remtrz no-error.
      if avail remtrz then 
      do:
         remtrz.rsub = "vcon".
         v-text = remtrz.remtrz + " отправлен VALCON -> VCON".
         run lgps.
         /*                    vdc = Val.Doc.(C)ontrol needed 
                               vdn = Val.Doc.(N)o control is needed */
         run chgsts ('rmz', w-rmz.remtrz, 'vdn').                      
         delete w-rmz.
      end.
  end.
  if can-find(first w-rmz) then browse b1:refresh().
                           else do:
                                browse b1:refresh().
                                message "На очереди VALCON нет платежей"
                                view-as alert-box.
                                hide all.
                                message "Нажмите F4".
                                return.
                           end.  
end.

on HELP of b1 do:
  if w-rmz.ptype = "" then do:
     run chgsts ("rmz", w-rmz.remtrz, "vdc").
     w-rmz.ptype = "БЛ".
     v-text = w-rmz.remtrz + " документ заблокирован на очереди VALCON".
     run lgps.
  end.
  else do:
     run chgsts ("rmz", w-rmz.remtrz, "vdn").
     w-rmz.ptype = "".
     v-text = w-rmz.remtrz + " отмена блокировки на очереди VALCON".
     run lgps.
  end.
  browse b1:refresh().
end.

hide all.                                             
open query q1 for each w-rmz no-lock.
enable all with frame f1.

wait-for window-close of current-window.

