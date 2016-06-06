/* cif-rel.p
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
 * BASES
        BANK COMM
 * CHANGES
        21.12.2004 saltanat - Полностью изменила по новому требованию ТЗ ї1223.
        25/09/2008 galina - счет 20-тизначный
        26/09/2008 galina - явно указала ширину фреймa fr1
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        31.08.2012 evseev - иин/бин
*/

{global.i}
{yes-no.i}

def var yn as log initial false format "да/нет".
def shared var s-cif like cif.cif.

DEFINE QUERY q1 FOR cif-heir.
def browse b1
query q1
displ
    cif-heir.aaa       label 'Счет' format 'x(20)'
    cif-heir.fio       label 'ФИО'  format 'x(15)'
    cif-heir.idcard    label 'удов' format 'x(12)'
    cif-heir.jss       label 'ИИН' format 'x(12)'
    cif-heir.will-date label 'Дата завещ' format '99/99/99'
    cif-heir.ratio     label 'Соотнош' format 'x(8)'
with 12 down title ' Наследуемые лица '.

DEFINE BUTTON bloo LABEL "LOOK".
DEFINE BUTTON bext LABEL "Выход".

def frame fr1
     b1 skip
     bloo
     bext with centered width 90 overlay row 1 top-only.

ON CHOOSE OF bext IN FRAME fr1
do:
   hide frame getlist1.
   APPLY "WINDOW-CLOSE" TO BROWSE b1.
end.

ON CHOOSE OF bloo IN FRAME fr1
do:
find current cif-heir no-lock no-error.
if not avail cif-heir then do: message 'Нет текущей записи!'. pause 3. return. end.
displ
    cif-heir.aaa       label '                  Счет' format 'x(20)' skip
    cif-heir.fio       label '                   ФИО' format 'x(40)' skip
    cif-heir.idcard    label '      Пасп/удов N/дата' format 'x(40)' skip
    cif-heir.jss       label '                   ИИН' format 'x(12)' skip
    cif-heir.will-date label '       Дата выд.завещ.' format '99/99/99' skip
    cif-heir.ratio     label 'Соотношение насл.имущ.' format 'x(40)' skip
with frame fr row 3 overlay top-only side-label col 5 title ' Наследуемое лицо '.
end.
open query q1 for each cif-heir where cif-heir.cif = s-cif.


b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").

ENABLE all with frame fr1 centered overlay top-only.

apply "value-changed" to b1 in frame fr1.

WAIT-FOR WINDOW-CLOSE of frame fr1.

hide frame fr1.


