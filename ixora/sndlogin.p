/* sndlogin.p
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
 * BASES
        BANK COMM
 * AUTHOR
        01.09.2004 dpuchkov
 * CHANGES
        21.04.2011 aigul - вывод сотрудников у кого typ не совпадает с рассылкой опорников
*/

def var str_p as char.
define frame getlist1
/* cifsec.cif label "Клиент" skip */
ofcsend.ofc label "Логин офицера" help " F2 - Поиск логина"  skip
with side-labels centered row 8.

{yes-no.i}
{global.i}

DEFINE QUERY q1 FOR ofcsend.

define buffer buf for ofcsend.

def browse b1
     query q1
     displ
     ofcsend.ofc label "  " format "x(25)"
     with 7 down title "Список офицеров" overlay.


/* DEFINE BUTTON bedt LABEL "См.\Изм.".        */
DEFINE BUTTON bnew LABEL "Создать".
DEFINE BUTTON bdel LABEL "Удалить".
DEFINE BUTTON bext LABEL "Выход".

def frame fr1
     b1
     skip
     bnew
     bdel
     bext with centered overlay row 5 top-only.


ON CHOOSE OF bext IN FRAME fr1
do:
   hide frame getlist1.
   APPLY "WINDOW-CLOSE" TO BROWSE b1.
end.

ON CHOOSE OF bdel IN FRAME fr1
do:
   if yes-no ("Внимание!", "Вы действительно хотите удалить запись?")
   then do:
      find buf where rowid (buf) = rowid (ofcsend) exclusive-lock.
      delete buf.
      close query q1.
      open query q1 for each ofcsend where ofcsend.typ = "kurs".
      browse b1:refresh().
   end.
end.

   ON CHOOSE OF bnew IN FRAME fr1
do:
   create ofcsend.
   ofcsend.typ = "kurs".
   update ofcsend.ofc with frame getlist1.

   close query q1.
   open query q1 for each ofcsend where ofcsend.typ = "kurs".
   browse b1:refresh().
end.

open query q1 for each ofcsend where ofcsend.typ = "kurs".

b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").

ENABLE all with frame fr1 centered overlay top-only.

apply "value-changed" to b1 in frame fr1.

WAIT-FOR WINDOW-CLOSE of frame fr1.

hide frame fr1.

