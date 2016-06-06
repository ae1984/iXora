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
        25/01/2012 evseev
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

DEFINE QUERY q1 FOR txb.cif-heir.
def browse b1 query q1
displ
    txb.cif-heir.aaa       label 'Счет' format 'x(20)'
    txb.cif-heir.fio       label 'ФИО'  format 'x(30)'
    txb.cif-heir.idcard    label 'удов' format 'x(12)'
    txb.cif-heir.jss       label 'РНН' format 'x(12)'
    txb.cif-heir.will-date label 'Дата завещ' format '99/99/99'
    txb.cif-heir.ratio     label 'Соотнош' format 'x(8)'
with 12 down title ' Наследуемые лица '.


DEFINE BUTTON bsel LABEL "Выбрать".
DEFINE BUTTON bext LABEL "Выход".

def frame fr1
     b1 skip
     bsel
     bext with centered width 105 overlay row 1 top-only.

open query q1 for each txb.cif-heir where txb.cif-heir.cif = v-cif-f.


ON CHOOSE OF bext IN FRAME fr1
do:
   o-fio = "".
   o-doc = "".
   o-rnn = "".
   APPLY "WINDOW-CLOSE" TO BROWSE b1.
end.

ON CHOOSE OF bsel IN FRAME fr1
do:
   if avail txb.cif-heir then do:
       o-fio = txb.cif-heir.fio.
       o-doc = txb.cif-heir.idcard.
       o-rnn = txb.cif-heir.jss.
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

