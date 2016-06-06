/* h-rmzzzv.p
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

/* h-rmzzzv.p  - F2 on VCON */

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
def var v-cur as int .
def temp-table w-rmz like remtrz. 

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display "Отсутствует запись OURBNK в таблице SYSC!".
 pause .
 undo .
 return .
end.
ourbank = sysc.chval.

for each que where que.pid = m_pid and que.con = "W" no-lock ,
 each remtrz where remtrz.remtrz = que.remtrz no-lock  by remtrz.payment  . 
  if remtrz.rsub = v-rsub then do:
     create w-rmz.
     w-rmz.remtrz = remtrz.remtrz .
     w-rmz.sqn = remtrz.sqn.
     w-rmz.fcrc = remtrz.fcrc   .
     w-rmz.amt  = remtrz.amt   .
     w-rmz.tcrc = remtrz.tcrc .
     w-rmz.payment = remtrz.payment .
  end.   
end.

define query q1 for w-rmz.

define browse b1 query q1
              displ
                 w-rmz.remtrz label "Платеж"
                 w-rmz.sqn label "Nr."
                 w-rmz.fcrc label "ВД"
                 w-rmz.amt label "СуммаД"
                 w-rmz.tcrc label "ВК"
                 w-rmz.payment label "СуммаК"
     with centered no-label row 2 10 down no-box.

define frame f1 b1 
help "F1 - 2Пров и акцепт, F2 - возврат на VALCON, ENTER - смотреть"
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

{yes-no.i}
def var yn as log.

on GO of b1 do:
yn = yes-no ("", "Сформировать 2Пров и акцептовать всю очередь?").
if yn then do:  
  for each w-rmz:
     s-remtrz = w-rmz.remtrz.
     run 2ltrxa.
     run l-govcon.
  end.
  message "Сформированы вторые проводки, платежи акцептованы" 
  view-as alert-box.
  apply "window-close" to current-window.
  return.
end.
end.

on HELP of b1 do:
  find first remtrz where remtrz.remtrz = w-rmz.remtrz no-error.
  if avail remtrz then do:
     remtrz.rsub = 'valcon'.
     delete w-rmz.
     v-text = remtrz.remtrz + " возврат VCON -> VALCON".
     run lgps.
  end.
  browse b1:refresh().
  if can-find(first w-rmz) = false then
  do:
      message "Нет платежей на очереди VCON" view-as alert-box.
      hide all.
      message "Нажмите F4".
      return.
  end.
end.

hide all.                                             
open query q1 for each w-rmz no-lock.
enable all with frame f1.

wait-for window-close of current-window.

