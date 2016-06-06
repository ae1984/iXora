/* .p
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
        24/01/2012 evseev
 * BASES
        BANK TXB
 * CHANGES
        02/02/2012 evseev - recompile
*/

def  shared var v-gtoday as date no-undo.
def  shared var v-cif-f as char.

def output parameter o-fio as char no-undo.
def output parameter o-doc as char no-undo.
def output parameter o-rnn as char no-undo.

DEFINE QUERY q1 FOR txb.uplcif.
def browse b1 query q1
displ
    txb.uplcif.dop     label 'Счет' format 'x(20)'
    txb.uplcif.coregdt label 'Дата рег.' format '99/99/99'
    txb.uplcif.finday  label 'Дата окон.' format '99/99/99'
    txb.uplcif.badd[1] label 'ФИО' format 'x(20)'
    txb.uplcif.badd[2] label 'Пасп/удов N' format 'x(15)'
with 12 down title ' Доверенное лицо '.

DEFINE BUTTON bsel LABEL "Выбрать".
DEFINE BUTTON bext LABEL "Выход".

def frame fr1
     b1 skip
     bsel
     bext with centered width 90 overlay row 1 top-only.
open query q1 for each txb.uplcif where txb.uplcif.cif = v-cif-f and txb.uplcif.coregdt <= v-gtoday and txb.uplcif.finday >= v-gtoday.



ON CHOOSE OF bext IN FRAME fr1
do:
   o-fio = "".
   o-doc = "".
   o-rnn = "".
   APPLY "WINDOW-CLOSE" TO BROWSE b1.
end.

ON CHOOSE OF bsel IN FRAME fr1
do:
   if avail txb.uplcif then do:
       o-fio = txb.uplcif.badd[1].
       o-doc = txb.uplcif.badd[2] + " " + txb.uplcif.badd[3].
       o-rnn = txb.uplcif.rnn.
   end. else do:
       o-fio = "".
       o-doc = "".
       o-rnn = "".
   end.
   APPLY "WINDOW-CLOSE" TO BROWSE b1.
end.


b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").

ENABLE all with frame fr1 centered overlay top-only.

apply "value-changed" to b1 in frame fr1.

WAIT-FOR WINDOW-CLOSE of frame fr1.

hide frame fr1.

