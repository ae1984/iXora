/* pkprstr.p
 * MODULE
        "Быстрые деньги"
 * DESCRIPTION
        Загрузка, редактирование,удаление проблемных улиц. 
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
        16.11.2004 saltanat
 * CHANGES
        26.09.2005 tsoy убрал из запроса codfr т.к. значение может может быть из bookcode

*/

{global.i} 
{pk.i new}
{yes-no.i}
{pkvalidkrit.i}

def var v-num as inte init 0.
def var v-cod as char.
def var v-msgerr as char.

define frame fr
    troublestr.num     label "N            " format "zzz9"  skip
    troublestr.dop     label "город/поселок" format "x(15)" skip
    troublestr.street validate (valid-krit ('street1', troublestr.street, s-credtype, output v-msgerr), v-msgerr) 
                       label "Улица/Район  " format "x(30)" skip
    troublestr.homenum label "Номер дома   " format "x(15)"
with side-labels title "Проблемные районы" centered row 8.

on help of troublestr.street in frame fr do: 
  run pkh-krit-my ('street1', output v-cod).
  if v-cod <> "" then troublestr.street = entry(1, v-cod).
  displ troublestr.street with frame fr. 
end.

DEFINE QUERY q1 FOR troublestr.
def browse b1 
    query q1 no-lock 
    display 
    troublestr.num     label "N"             format "zzz9"  
    troublestr.dop     label "город/поселок" format "x(15)" 
    troublestr.street      label "Улица/Район"   format "x(30)"
    troublestr.homenum label "Номер дома"    format "x(15)"
with 12 down title "Проблемные районы" overlay.


DEFINE BUTTON badd LABEL "Добавить".        
DEFINE BUTTON bedt LABEL "Редактировать".        
DEFINE BUTTON bdel LABEL "Удалить".        
DEFINE BUTTON bext LABEL "Выход".

def frame fr1
    b1 skip
    badd bedt bdel
    bext with centered overlay row 1 top-only.  

/*  *** Д О Б А В И Т Ь ***  */
ON CHOOSE OF badd IN FRAME fr1
do:
   find last troublestr exclusive-lock no-error.
   if not avail troublestr then v-num = 1.
   else v-num = troublestr.num + 1.  
   create troublestr.
   assign troublestr.num = v-num
          troublestr.who = g-ofc
          troublestr.whn = g-today.
   displ  troublestr.num 
   with frame fr.
   update troublestr.dop 
          troublestr.street
          troublestr.homenum 
   with frame fr.
   run defval.
   /*displ v-cod @ troublestr.street
   with frame fr.*/
   open query q1 for each troublestr no-lock.
   b1:select-row(CURRENT-RESULT-ROW("q1")). 
   hide frame fr.
end.

/*  *** Р Е Д А К Т И Р О В А Т Ь ***  */
ON CHOOSE OF bedt IN FRAME fr1
do:
   find current troublestr exclusive-lock no-error.
   if avail troublestr then do:
   update troublestr.num
          troublestr.dop 
          troublestr.street
          troublestr.homenum 
   with frame fr.
   run defval.
   /*displ v-cod @ troublestr.street
   with frame fr. */
   release troublestr.
   open query q1 for each troublestr no-lock.
   b1:select-row(CURRENT-RESULT-ROW("q1")).
   b1:refresh().
   hide frame fr.
   end.
   else message ' Не выбрана запись для редактирования! '.
end.

/*  *** У Д А Л И Т Ь ***  */
ON CHOOSE OF bdel IN FRAME fr1
do:
   find current troublestr exclusive-lock.
   delete troublestr.
   open query q1 for each troublestr no-lock.
end.

/*  *** В Ы Х О Д ***  */
ON CHOOSE OF bext IN FRAME fr1
do:
   hide frame getlist1.
   APPLY "WINDOW-CLOSE" TO BROWSE b1.
end.

open query q1 for each troublestr no-lock. 
b1:SET-REPOSITIONED-ROW(1,"CONDITIONAL").
ENABLE all with frame fr1 centered overlay top-only.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR WINDOW-CLOSE of frame fr1.
hide frame fr1.




procedure pkh-krit-my.
def input parameter p-kritcod as char.
def output parameter p-cod as char.
def var v-mask as char.

p-cod = "".

find pkkrit where pkkrit.kritcod = p-kritcod no-lock no-error.
if not avail pkkrit then do:
  message " Не найдено описание критерия" p-kritcod.
  pause 5.
  return.
end.

if pkkrit.kritspr = "" then do:
  hide message no-pause.
  message pkkrit.res[1].
end.
else do:
  find bookref where bookref.bookcod = pkkrit.kritspr no-lock no-error.
  if avail bookref then run uni_book (pkkrit.kritspr, "", output p-cod).
  else do:
    run uni_help (pkkrit.kritspr, v-mask, output p-cod).
  end.
end.
end procedure.

procedure defval.
  find pkkrit where pkkrit.kritcod = 'street1' no-lock no-error.
  if pkkrit.kritspr = "" then v-cod = troublestr.street. 
  else do: 
    find bookcod where bookcod.bookcod = pkkrit.kritspr and bookcod.code = troublestr.street no-lock no-error.
    if avail bookcod then v-cod = bookcod.name. 
    else do:
      find codfr where codfr.codfr = pkkrit.kritspr and codfr.code = troublestr.street no-lock no-error.
      if avail codfr then v-cod = codfr.name[1]. 
                     else v-cod = troublestr.street.
    end. 
  end. 
end.





