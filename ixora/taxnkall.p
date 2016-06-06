/* taxnkall.p
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
*/

{comm-txb.i}

define temp-table tnk like comm.taxnk.

DEFINE QUERY q1 FOR comm.taxnk.
DEFINE QUERY q2 FOR tnk.

def var ourbank as char.
ourbank = comm-txb().

for each comm.taxnk no-lock use-index rnn break by comm.taxnk.bank :
    if first-of(comm.taxnk.bank) then do:
        create tnk.
        buffer-copy comm.taxnk to tnk.
    end.    
end.

def browse b1 
     query q1 no-lock
     displ comm.taxnk.rnn label "Список РНН НК" format 'x(12)'
           comm.taxnk.name label "Наименование" format 'x(55)' with 13 down title "RNN".

def browse b2 
     query q2 no-lock
     display tnk.bank label "Банк" format 'x(5)'
             tnk.bank label "Область / Город" format 'x(55)' with 14 down title " Список доступных городов/районов ".

def frame fr1 
     b1 with centered overlay view-as dialog-box.

on return of b1 in frame fr1 do:
     apply "endkey" to frame fr1. 
end.  


def frame fr2 
     b2 with centered overlay view-as dialog-box.

on return of b2 in frame fr2 do:
     apply "endkey" to frame fr2. 
end.  


open query q2 for each tnk BY tnk.bank.

if num-results("q1")=0 then
do:
     MESSAGE "2:Записи не найдены." VIEW-AS ALERT-BOX INFORMATION BUTTONS ok TITLE "Не найден РНН НК".
     return.                 
end.

b2:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr2.
apply "value-changed" to b2 in frame fr2.
WAIT-FOR endkey of frame fr2.

hide frame fr2.


open query q1 for each comm.taxnk where comm.taxnk.bank = tnk.bank use-index typegrp.

if num-results("q1")=0 then
do:
     MESSAGE "1:Записи не найдены." VIEW-AS ALERT-BOX INFORMATION BUTTONS ok TITLE "Не найден РНН НК".
     return.                 
end.

b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.


return comm.taxnk.rnn.

